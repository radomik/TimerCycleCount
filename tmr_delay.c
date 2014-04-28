#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <limits.h>

static const char *help = "\
/** Program Wyznacza możliwie optymalne ustawienia timera TMR0 dla PIC16F8x\n\
 *  Użycie:\n\
 *      ./tmr_delay <exp_cycle> <exp_delta> <max_iter>\n\
 *\n\
 * Wyznaczanie odbywa się w oparciu o dwa szkielety procedur opóźniających:\n\
 * @code\n\
 * delay1_Xcykli:                       ; 2 cykle call delay1_\n\
 *      call    init_presc__c_presc     ; 10 cykli (inicjalizacja preskalera)\n\
 *      movlw   c_tmr0                  ; 1 cykl (początkowa wartość rejestru TMR0)\n\
 *      call    delay_tmr0              ; zależy od c_tmr0 i c_presc\n\
 *      < dodatkowe opóźnienie >        ; opcjonalnie\n\
 *      return                          ; 2 cykle\n\
 *\n\
 * delay2_Xcykli:                       ; 2 cykle call delay1_\n\
 *      movlw   c_iter                  ; 1 cykl ( liczba wywołań delay_tmr0 )\n\
 *      movwf   TMRCNT                  ; 1 cykl\n\
 *      call    init_presc__c_presc     ; 10 cykli (inicjalizacja preskalera)\n\
 * loop_delay2_X:                       ; pętla wykonująca się TMRCNT razy\n\
 *      movlw   c_tmr0                  ; 1 cykl\n\
 *      call    delay_tmr0              ; zależy od c_tmr0 i c_presc\n\
 *      decfsz  TMRCNT, f               ; 1 / 2 cykle\n\
 *      goto    loop_delay2_X           ; 2 / 0 cykli\n\
 *      movlw   c_ddel                  ; opcjonalnie - odmierzenie dodatkowego opoznienia  TMR0\n\
 *      call    delay_tmr0              ; opcjonalnie\n\
 *      < dodatkowe opóźnienie >        ; opcjonalnie\n\
 *      return                          ; 2 cykle\n\
 *\n\
 * @endcode\n\
 *\n\
 * Program przyjmuje na wejściu parametry:\n\
 *      argv[1]     - exp_cycle     - oczekiwana liczba cykli opóźnienia całej procedury delay1_ lub delay2_\n\
 *      argv[2]     - exp_delta     - maksymalna liczba cykli opóźnienia jakie należy umieścić w polu: < dodatkowe opóźnienie >\n\
 *      argv[3]     - max_iter      - maksymalna liczba iteracji c_iter w procedurze delay2_\n\
 *\n\
 * Program wyznacza wartości: c_tmr0, c_presc, c_iter, c_ddel oraz < dodatkowe opóźnienie >\n\
 * pozwalające wygenerować zadane opóżnienie\n\
 * dla odpowiedniej procedury opóźniającej\n\
 *  Użycie:\n\
 *      ./tmr_delay <exp_cycle> <exp_delta> <max_iter>\n\
 */";

typedef unsigned int uint;
typedef unsigned char uchar;
typedef unsigned short ushort;

#define PRESCALER_COUNT 	8

static const uint F_CPU_CLOCK = 4;	// cpu clock frequency in MHz

static const uchar DELAY1_CONST_CYCLES = 15;
static const uchar DELAY2_CONST_CYCLES = 16;

static const ushort PRESCALER_VALUES[PRESCALER_COUNT] = {
	2, 4, 8, 16, 32, 64, 128, 256
};

static uint prescaler_correct_0246(ushort reg_tmr0_val);
static uint prescaler_correct_1(ushort reg_tmr0_val);
static uint prescaler_correct_357(ushort reg_tmr0_val);

static uint (*PRESCALER_CORRECT_CB[PRESCALER_COUNT])(ushort reg_tmr0_val) = {
	prescaler_correct_0246,	/*0*/
	prescaler_correct_1,	/*1*/
	prescaler_correct_0246, /*2*/
	prescaler_correct_357,  /*3*/
	prescaler_correct_0246, /*4*/
	prescaler_correct_357,  /*5*/
	prescaler_correct_0246, /*6*/
	prescaler_correct_357  /*7*/
};

static uint prescaler_correct_0246(ushort reg_tmr0_val) {
	const ushort modulus = reg_tmr0_val % 3;
	if (modulus) return 10 + (3 - modulus);
	else return 10;
}
static uint prescaler_correct_1(ushort reg_tmr0_val) {
	return 10 + (reg_tmr0_val+1) % 3;
}
static uint prescaler_correct_357(ushort reg_tmr0_val) {
	const ushort modulus = reg_tmr0_val % 3;
	if (modulus != 2) return 10 + (1 + modulus);
	else return 10;
}

/// @returns T [cykle] = (256 - W)*(4/f_osc)*Presc + poprawka
static uint cycle_delay_tmr0(uchar preskaler_index, 
							 ushort reg_tmr0_val) {
	return (((256 - reg_tmr0_val) << 2) * PRESCALER_VALUES[preskaler_index]) / F_CPU_CLOCK + 
			PRESCALER_CORRECT_CB[preskaler_index](reg_tmr0_val);
}

typedef struct {
	uint	cycle_delta;	// must be first in struct for comparator
	uint	res_cycle;
	uchar	reg_tmr0_val;
	uchar	prescaler_index;
} delay1_data;

static int cmp_delay_data(const void* a, const void* b) {
	return *((uint*)b) - *((uint*)a); // compare descending
}

/// @returns 1 - jeśli znaleziono co najmniej jedno rozwiązanie nie wymagające dodatkowych opóźnień
///          0 - w przeciwnym wypadku
static int calc_delay1(uint exp_cycle, uint exp_cycle_min) {
	size_t		 data_size = PRESCALER_COUNT * 256, data_len = 0;
	delay1_data	 *data = malloc(data_size * sizeof(delay1_data));
	uint 		 res_cycle;
	int ret 	 = 0;
	ushort		 tmr0_val;
	uchar		 presc_ind;
	
	assert(data);
	
	printf("\n### Obliczanie dla procedury delay1_:\n\texp_cycle: %u\n\texp_cycle_min: %u\n",
		exp_cycle, exp_cycle_min);
	
	// foreach prescaler and foreach reg_tmr0 value
	for (presc_ind = 0; presc_ind < PRESCALER_COUNT; presc_ind++) {
		for (tmr0_val = 255; ;) {
			res_cycle = DELAY1_CONST_CYCLES + cycle_delay_tmr0(presc_ind, tmr0_val);
			
			//printf("pres: %hu, tmr0: %hu, res_cycle: %u\n", PRESCALER_VALUES[presc_ind], tmr0_val, res_cycle);
			
			if (res_cycle > exp_cycle) break; // delay increases as tmr0_val decreases
			
			if (res_cycle >= exp_cycle_min) {
				data[data_len].res_cycle = res_cycle;
				data[data_len].cycle_delta = exp_cycle - res_cycle;
				data[data_len].reg_tmr0_val = tmr0_val;
				data[data_len].prescaler_index = presc_ind;
				if (! data[data_len].cycle_delta) ret = 1;
				data_len++;
			}
			
			if (! tmr0_val) break;
			tmr0_val--;
		}
	}
	
	if (! data_len) {
		printf("### Nie znaleziono żadnych rozwiązań dla podanych parametrów i procedury delay1_\n");
	}
	else {
		size_t i;
		qsort(data, data_len, sizeof(delay1_data), cmp_delay_data);
		for (i = 0; i < data_len; i++) {
			printf("TMR0: %3d, PRES: %3hu, CYCLE: %10u, DELTA: %u\n",
				data[i].reg_tmr0_val, PRESCALER_VALUES[data[i].prescaler_index],
				data[i].res_cycle, data[i].cycle_delta);
		}
	}
	
	free(data);
	return ret;
}

typedef struct {
	uint	res_cycle;
	uint	cycle_delta;
	uchar	reg_tmr0_val;
} added_delay;

typedef struct {
	uint	cycle_delta;	// must be first in struct for comparator
	uint	res_cycle;
	ushort	c_iter;
	uchar	reg_tmr0_val;
	uchar	prescaler_index;
	added_delay	 ddel;
} delay2_data;

static int cmp_delay2_data(const void* a, const void* b) {
	const delay2_data *da = (const delay2_data *)a;
	const delay2_data *db = (const delay2_data *)b;
	const uint del_a = (da->ddel.res_cycle) ? da->ddel.cycle_delta : da->cycle_delta;
	const uint del_b = (db->ddel.res_cycle) ? db->ddel.cycle_delta : db->cycle_delta;
	return del_b - del_a;
}

static void calc_delay2(uint exp_cycle, uint exp_cycle_min, uint max_iter, uint exp_delta) {
	size_t		 data_size = PRESCALER_COUNT * 256 * max_iter, data_len = 0;
	delay2_data	 *data = malloc(data_size * sizeof(delay2_data));
	uint 		 res_cycle, tmr0_cycle, cycle_delta;
	ushort		 c_iter, tmr0_val, tmr0_val_2;
	uchar		 presc_ind;
	
	assert(data);
	
	printf("\n### Obliczanie dla procedury delay2_:\n\texp_cycle: %u\n\texp_cycle_min: %u\n\texp_delta: %u\n\tmax_iter: %u\n",
		exp_cycle, exp_cycle_min, exp_delta, max_iter);
	
	// foreach prescaler, foreach reg_tmr0 value and foreach count of iterations
	for (presc_ind = 0; presc_ind < PRESCALER_COUNT; presc_ind++) {
		for (tmr0_val = 255; ;) {
			tmr0_cycle = cycle_delay_tmr0(presc_ind, tmr0_val);
			for (c_iter = 1; c_iter <= max_iter; c_iter++) {
				res_cycle = DELAY2_CONST_CYCLES + 
					(c_iter-1) * (4 + tmr0_cycle) + (3 + tmr0_cycle);
					
				if (res_cycle > exp_cycle) break;
				
				//if (res_cycle >= exp_cycle_min) {
					cycle_delta = exp_cycle - res_cycle;
					data[data_len].res_cycle = res_cycle;
					data[data_len].cycle_delta = cycle_delta;
					data[data_len].reg_tmr0_val = tmr0_val;
					data[data_len].prescaler_index = presc_ind;
					data[data_len].c_iter = c_iter;
					
					data[data_len].ddel.res_cycle = 0;
					if (cycle_delta) { // find extra one delay call after loop
						//printf("\npres: %hu, tmr0: %hu, res_cycle: %u\n", PRESCALER_VALUES[presc_ind], tmr0_val, res_cycle);
			
						for (tmr0_val_2 = 255; ;) {
							res_cycle = 1 + cycle_delay_tmr0(presc_ind, tmr0_val_2);
							
							//printf("\n\tdelta: %u, tmr0_val_2: %hu, res_cycle: %u ",
							//	cycle_delta, tmr0_val_2, res_cycle);
							
							if (res_cycle > cycle_delta) break;
							
							if (( (data[data_len].ddel.res_cycle == 0) || (res_cycle > data[data_len].ddel.res_cycle) ) ) {
								//printf(" >> is new less");
								data[data_len].ddel.res_cycle = res_cycle;
								data[data_len].ddel.cycle_delta = cycle_delta - res_cycle;
								data[data_len].ddel.reg_tmr0_val = tmr0_val_2;
							}
							
							if (! tmr0_val_2) break;
							tmr0_val_2--;
						}
					}
					
					if ((cycle_delta <= exp_delta) || 
						((data[data_len].ddel.res_cycle) && (data[data_len].ddel.cycle_delta <= exp_delta))) {
							data_len++;
						}
				//}
			}
			
			if (! tmr0_val) break;
			tmr0_val--;
		}
	}

	if (! data_len) {
		printf("### Nie znaleziono żadnych rozwiązań dla podanych parametrów i procedury delay2_\n");
	}
	else {
		size_t i;
		qsort(data, data_len, sizeof(delay2_data), cmp_delay2_data);
		for (i = 0; i < data_len; i++) {
			printf("\nTMR0: %3d, PRES: %3hu, C_ITER: %5hu,            CYCLE:     %10u, DELTA:     %u\n",
			data[i].reg_tmr0_val, PRESCALER_VALUES[data[i].prescaler_index],
			data[i].c_iter, data[i].res_cycle, data[i].cycle_delta);
			if (data[i].ddel.res_cycle != 0) {
				printf("Add: movlw .%3d ; call delay_tmr0 on end        NEW_CYCLE: %10u, NEW_DELTA: %u\n",
					data[i].ddel.reg_tmr0_val, data[i].res_cycle+data[i].ddel.res_cycle, data[i].ddel.cycle_delta);
			}
		}
	}
	free(data);
}

int main(int argc, char **argv) {
	if ((argc < 4) || (!strcmp(argv[1], "--help"))) {
		puts(help);
		return 0;
	}
    
    const uint exp_cycle = atoi(argv[1]);
    uint exp_delta = atoi(argv[2]);
    uint max_iter  = atoi(argv[3]);
    
    if (max_iter > 255) max_iter = 255;
    if (! max_iter) max_iter = 1;
    
    if (exp_delta > exp_cycle) {
		exp_delta = exp_cycle - 1;
	}
	
	assert(exp_cycle > 10);
	
	const uint exp_cycle_min = exp_cycle - exp_delta;
	
	int ret = calc_delay1(exp_cycle, exp_cycle_min);
	
	if (! ret) { // calc_delay1() nie znalazł rozwiązania nie wymagającego dodatkowego opoznienia
		calc_delay2(exp_cycle, exp_cycle_min, max_iter, exp_delta);
	}
    
    return 0;
}


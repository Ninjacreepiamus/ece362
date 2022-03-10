
#include "stm32f0xx.h"
#include <math.h>   // for M_PI

void nano_wait(int);

// 16-bits per digit.
// The most significant 8 bits are the digit number.
// The least significant 8 bits are the segments to illuminate.
uint16_t msg[8] = { 0x0000,0x0100,0x0200,0x0300,0x0400,0x0500,0x0600,0x0700 };
extern const char font[];
// Print an 8-character string on the 8 digits
void print(const char str[]);
// Print a floating-point value.
void printfloat(float f);


//============================================================================
// enable_ports()
//============================================================================
void enable_ports(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN | RCC_AHBENR_GPIOCEN;
    //Clear PB0-10
    GPIOB->MODER &= ~(GPIO_MODER_MODER0 | GPIO_MODER_MODER1
                    | GPIO_MODER_MODER2 | GPIO_MODER_MODER3
                    | GPIO_MODER_MODER4 | GPIO_MODER_MODER5
                    | GPIO_MODER_MODER6 | GPIO_MODER_MODER7
                    | GPIO_MODER_MODER8 | GPIO_MODER_MODER9
                    | GPIO_MODER_MODER10);
    //Set PB0-10 as outputs
    GPIOB->MODER |= ( GPIO_MODER_MODER0_0 | GPIO_MODER_MODER1_0
                    | GPIO_MODER_MODER2_0 | GPIO_MODER_MODER3_0
                    | GPIO_MODER_MODER4_0 | GPIO_MODER_MODER5_0
                    | GPIO_MODER_MODER6_0 | GPIO_MODER_MODER7_0
                    | GPIO_MODER_MODER8_0 | GPIO_MODER_MODER9_0
                    | GPIO_MODER_MODER10_0);
    //Clear PC0-7
    GPIOC->MODER &= ~(GPIO_MODER_MODER0 | GPIO_MODER_MODER1
                    | GPIO_MODER_MODER2 | GPIO_MODER_MODER3
                    | GPIO_MODER_MODER4 | GPIO_MODER_MODER5
                    | GPIO_MODER_MODER6 | GPIO_MODER_MODER7);
    //Set PC4-7 as outputs
    GPIOC->MODER |= GPIO_MODER_MODER4_0 | GPIO_MODER_MODER5_0
                    | GPIO_MODER_MODER6_0 | GPIO_MODER_MODER7_0;
    //Set PC4-7 with open-drain
    GPIOC->OTYPER |= GPIO_OTYPER_OT_4 | GPIO_OTYPER_OT_5
                   | GPIO_OTYPER_OT_6 | GPIO_OTYPER_OT_7;
    //Clear PUPDR for PC0-3
    GPIOC->PUPDR &= ~(GPIO_PUPDR_PUPDR0 | GPIO_PUPDR_PUPDR1
                    | GPIO_PUPDR_PUPDR2 | GPIO_PUPDR_PUPDR3);
    //Set PUPDR for PC0-3 to internal high
    GPIOC->PUPDR |= (GPIO_PUPDR_PUPDR0_0 | GPIO_PUPDR_PUPDR1_0
                    | GPIO_PUPDR_PUPDR2_0 | GPIO_PUPDR_PUPDR3_0);
}

//============================================================================
// setup_dma()
//============================================================================
void setup_dma(void)
{
    RCC->AHBENR |= RCC_AHBENR_DMAEN;
    DMA1_Channel5->CCR &= ~DMA_CCR_EN;
    DMA1_Channel5->CPAR = (uint32_t) &(GPIOB -> ODR);
    DMA1_Channel5->CMAR = (uint32_t) msg;//message base address
    DMA1_Channel5->CNDTR = 8;
    DMA1_Channel5->CCR |= DMA_CCR_DIR;
    DMA1_Channel5->CCR |= DMA_CCR_MINC;
    DMA1_Channel5->CCR |= DMA_CCR_MSIZE_0 | DMA_CCR_PSIZE_0 | DMA_CCR_CIRC;
}

//============================================================================
// enable_dma()
//============================================================================
void enable_dma(void)
{
    DMA1_Channel5->CCR |= DMA_CCR_EN;
}

//============================================================================
// init_tim15()
//============================================================================
void init_tim15(void)
{
    RCC->APB2ENR |= RCC_APB2ENR_TIM15EN;
    TIM15->PSC = 24000-1;
    TIM15->ARR = 2-1;
    TIM15->CR1 |= TIM_CR1_CEN;
    TIM15->DIER |= TIM_DIER_UDE;
}

//=============================================================================
// Part 2: Debounced keypad scanning.
//=============================================================================

uint8_t col; // the column being scanned

void drive_column(int);   // energize one of the column outputs
int  read_rows();         // read the four row inputs
void update_history(int col, int rows); // record the buttons of the driven column
char get_key_event(void); // wait for a button event (press or release)
char get_keypress(void);  // wait for only a button press event.
float getfloat(void);     // read a floating-point number from keypad
void show_keys(void);     // demonstrate get_key_event()

//============================================================================
// The Timer 7 ISR
//============================================================================
void TIM7_IRQHandler() {
    TIM7->SR &= ~TIM_SR_UIF;
    int rows = read_rows();
    update_history(col, rows);
    col = (col + 1) & 3;
    drive_column(col);
}

//============================================================================
// init_tim7()
//============================================================================
void init_tim7(void)
{
    RCC->APB1ENR |= RCC_APB1ENR_TIM7EN;
    TIM7->PSC = 24000-1;
    TIM7->ARR = 2-1;
    TIM7->CR1 |= TIM_CR1_CEN;
    TIM7->DIER |= TIM_DIER_UIE;
    NVIC->ISER[0] = (1<<TIM7_IRQn);
}

//=============================================================================
// Part 3: Analog-to-digital conversion for a volume level.
//=============================================================================
int volume = 2400;

//============================================================================
// setup_adc()
//============================================================================
void setup_adc(void)
{
    //Enable the clock to GPIO Port A
    RCC->AHBENR |= RCC_AHBENR_GPIOAEN;
    //Set the configuration for analog operation only for the appropriate pins
    GPIOA->MODER |= GPIO_MODER_MODER1;
    //Enable the clock to the ADC peripheral
    RCC->APB2ENR |= RCC_APB2ENR_ADC1EN;
    //Turn on the "high-speed internal" 14 MHz clock (HSI14)
    RCC->CR2 |= RCC_CR2_HSI14ON;
    //Wait for the 14 MHz clock to be ready
    while(!(RCC->CR2 & RCC_CR2_HSI14RDY));
    //Enable the ADC by setting the ADEN bit in the CR register
    ADC1->CR |= ADC_CR_ADEN;
    //Wait for the ADC to be ready
    while(!(ADC1->ISR & ADC_ISR_ADRDY));
    //Select the corresponding channel for ADC_IN1 in the CHSELR
    ADC1->CHSELR = 0;
    ADC1->CHSELR = 1 << 1;
    //Wait for the ADC to be ready AGAIN
    while(!(ADC1->ISR & ADC_ISR_ADRDY));
}

//============================================================================
// Varables for boxcar averaging.
//============================================================================
#define BCSIZE 32
int bcsum = 0;
int boxcar[BCSIZE];
int bcn = 0;
//============================================================================
// Timer 2 ISR
//============================================================================
void TIM2_IRQHandler() {
    //Acknowledge the interrupt.
    TIM2->SR &= ~TIM_SR_UIF;
    //Start the ADC by turning on the ADSTART bit in the CR.
    ADC1->CR |= ADC_CR_ADSTART;
    //Wait until the EOC bit is set in the ISR.
    while(!(ADC1->ISR & ADC_ISR_EOC));
    //Implement boxcar averaging using the following code:
    bcsum -= boxcar[bcn];
    bcsum += boxcar[bcn] = ADC1->DR;
    bcn += 1;
    if (bcn >= BCSIZE)
        bcn = 0;
    volume = bcsum / BCSIZE;
}

//============================================================================
// init_tim2()
//============================================================================
void init_tim2(void)
{
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;
    TIM2->PSC = 48000-1;
    TIM2->ARR = 100-1;
    TIM2->DIER |= TIM_DIER_UIE;
    NVIC->ISER[0] = (1<<TIM2_IRQn);
    TIM2->CR1 |= TIM_CR1_CEN;
}

//===========================================================================
// Part 4: Create an analog sine wave of a specified frequency
//===========================================================================
void dialer(void);

// Parameters for the wavetable size and expected synthesis rate.
#define N 1000
#define RATE 20000
short int wavetable[N];
int step0 = 0;
int offset0 = 0;
int step1 = 0;
int offset1 = 0;

//===========================================================================
// init_wavetable()
// Write the pattern for a complete cycle of a sine wave into the
// wavetable[] array.
//===========================================================================
void init_wavetable(void)
{
    for(int i=0; i < N; i++)
        wavetable[i] = 32767 * sin(2 * M_PI * i / N);
}

//============================================================================
// set_freq()
//============================================================================
void set_freq(int chan, float f) {
    if (chan == 0) {
        if (f == 0.0) {
            step0 = 0;
            offset0 = 0;
        } else
            step0 = (f * N / RATE) * (1<<16);
    }
    if (chan == 1) {
        if (f == 0.0) {
            step1 = 0;
            offset1 = 0;
        } else
            step1 = (f * N / RATE) * (1<<16);
    }
}

//============================================================================
// Timer 6 ISR
//============================================================================
void TIM6_DAC_IRQHandler() {
    //Acknowledge the interrupt.
    TIM6->SR &= ~TIM_SR_UIF;
    //Other stuff
    offset0 += step0;
    offset1 += step1;
    if (offset0 >= (N << 16))
        offset0 -= (N << 16);
    if (offset1 >= (N << 16))
        offset1 -= (N << 16);
    int sample = wavetable[offset0>>16] + wavetable[offset1>>16];
    sample = ((sample * volume)>>18) + 1200;
    TIM1->CCR4 = sample;
}

//============================================================================
// init_tim6()
//============================================================================
void init_tim6(void)
{
    RCC->APB1ENR |= RCC_APB1ENR_TIM6EN;
    TIM6->PSC = 2-1;
    TIM6->ARR = (48000000) / (2 * RATE);
    TIM6->DIER |= TIM_DIER_UIE;
    //TIM6->CR2 &= ~TIM_CR2_MMS;
    //TIM6->CR2 |= TIM_CR2_MMS_1;
    NVIC->ISER[0] = (1<<TIM6_DAC_IRQn);
    TIM6->CR1 |= TIM_CR1_CEN;
}

void setup_tim3(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOCEN;
    GPIOC->MODER &= ~(GPIO_MODER_MODER6 | GPIO_MODER_MODER7 | GPIO_MODER_MODER8 | GPIO_MODER_MODER9);
    GPIOC->MODER |= GPIO_MODER_MODER6_1 | GPIO_MODER_MODER7_1 | GPIO_MODER_MODER8_1 | GPIO_MODER_MODER9_1;

    RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;
    TIM3->PSC = 48000-1;
    TIM3->ARR = 1000-1;
    TIM3->CCMR1 &= ~(TIM_CCMR1_OC1M | TIM_CCMR1_OC2M);
    TIM3->CCMR1 |= TIM_CCMR1_OC1M_2 | TIM_CCMR1_OC1M_1 | TIM_CCMR1_OC2M_2 | TIM_CCMR1_OC2M_1;
    TIM3->CCMR2 &= ~(TIM_CCMR2_OC3M | TIM_CCMR2_OC4M);
    TIM3->CCMR2 |= TIM_CCMR2_OC3M_2 | TIM_CCMR2_OC3M_1 | TIM_CCMR2_OC4M_2 | TIM_CCMR2_OC4M_1;

    TIM3->CCER |= TIM_CCER_CC1E | TIM_CCER_CC2E | TIM_CCER_CC3E | TIM_CCER_CC4E;
    TIM3->CR1 |= TIM_CR1_CEN;
    TIM3->CCR1 = 800;
    TIM3->CCR2 = 400;
    TIM3->CCR3 = 200;
    TIM3->CCR4 = 100;
}

void setup_tim1(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOAEN;
    GPIOA->MODER &= ~(GPIO_MODER_MODER8 | GPIO_MODER_MODER9 | GPIO_MODER_MODER10 | GPIO_MODER_MODER11);
    GPIOA->MODER |= GPIO_MODER_MODER8_1 | GPIO_MODER_MODER9_1 | GPIO_MODER_MODER10_1 | GPIO_MODER_MODER11_1;
    GPIOA->AFR[1] &= ~0x0000ffff;
    GPIOA->AFR[1] |= 0x00002222;
    RCC->APB2ENR |= RCC_APB2ENR_TIM1EN;
    TIM1->BDTR |= TIM_BDTR_MOE;
    TIM1->PSC = 1-1;
    TIM1->ARR = 2400-1;
    TIM1->CCMR1 &= ~(TIM_CCMR1_OC1M | TIM_CCMR1_OC2M);
    TIM1->CCMR1 |= TIM_CCMR1_OC1M_2 | TIM_CCMR1_OC1M_1 | TIM_CCMR1_OC2M_2 | TIM_CCMR1_OC2M_1;
    TIM1->CCMR2 &= ~(TIM_CCMR2_OC3M | TIM_CCMR2_OC4M);
    TIM1->CCMR2 |= TIM_CCMR2_OC3M_2 | TIM_CCMR2_OC3M_1 | TIM_CCMR2_OC4M_2 | TIM_CCMR2_OC4M_1;
    TIM1->CCMR2 |= TIM_CCMR2_OC4PE;
    TIM1->CCER |= TIM_CCER_CC1E | TIM_CCER_CC2E | TIM_CCER_CC3E | TIM_CCER_CC4E;
    TIM1->CR1 |= TIM_CR1_CEN;
}

int getrgb(void);


void setrgb(int rgb)
{
    TIM1->CCR1 = (100 - ((10 * ((rgb >> 20) & 0xf) + 1 * ((rgb >> 16) & 0xf)))) * 24;
    TIM1->CCR2 = (100 - ((10 * ((rgb >> 12) & 0xf) + 1 * ((rgb >> 8) & 0xf)))) * 24;
    TIM1->CCR3 = (100 - ((10 * ((rgb >> 4) & 0xf) + 1 * ((rgb >> 0) & 0xf)))) * 24;
}

//============================================================================
// All the things you need to test your subroutines.
//============================================================================
int main(void)
{

    // Demonstrate part 1
//#define TEST_TIMER3
#ifdef TEST_TIMER3
    setup_tim3();
    for(;;) { }
#endif

    // Initialize the display to something interesting to get started.
    msg[0] |= font['E'];
    msg[1] |= font['C'];
    msg[2] |= font['E'];
    msg[3] |= font[' '];
    msg[4] |= font['3'];
    msg[5] |= font['6'];
    msg[6] |= font['2'];
    msg[7] |= font[' '];

    enable_ports();
    setup_dma();
    enable_dma();
    init_tim15();
    init_tim7();
    setup_adc();
    init_tim2();
    init_wavetable();
    init_tim6();

    setup_tim1();

    // demonstrate part 2
//#define TEST_TIM1
#ifdef TEST_TIM1
    for(;;) {
        for(float x=10; x<2400; x *= 1.1) {
            TIM1->CCR1 = TIM1->CCR2 = TIM1->CCR3 = 2400-x;
            nano_wait(100000000);
        }
    }
#endif

    // demonstrate part 3
//#define MIX_TONES
#ifdef MIX_TONES
    for(;;) {
        char key = get_keypress();
        if (key == 'A')
            set_freq(0,getfloat());
        if (key == 'B')
            set_freq(1,getfloat());
    }
#endif

    // demonstrate part 4
#define TEST_SETRGB
#ifdef TEST_SETRGB
    for(;;) {
        char key = get_keypress();
        if (key == 'A')
            set_freq(0,getfloat());
        if (key == 'B')
            set_freq(1,getfloat());
        if (key == 'D')
            setrgb(getrgb());
    }
#endif

    // Have fun.
    dialer();
}

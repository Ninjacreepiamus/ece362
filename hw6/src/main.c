#include "stm32f0xx.h"
#include <string.h>

int hrs = 12;
int min = 06;
int sec = 30;
int eighth;

const char font[] = {
        [' '] = 0x00,
        ['0'] = 0x3f,
        ['1'] = 0x06,
        ['2'] = 0x5b,
        ['3'] = 0x4f,
        ['4'] = 0x66,
        ['5'] = 0x6d,
        ['6'] = 0x7d,
        ['7'] = 0x07,
        ['8'] = 0x7f,
        ['9'] = 0x67,
        ['A'] = 0x77,
        ['B'] = 0x7c,
        ['C'] = 0x39,
        ['D'] = 0x5e,
        ['*'] = 0x49,
        ['#'] = 0x76,
        ['.'] = 0x80,
        ['?'] = 0x53,
        ['b'] = 0x7c,
        ['r'] = 0x50,
        ['g'] = 0x6f,
        ['i'] = 0x10,
        ['n'] = 0x54,
        ['u'] = 0x1c,
};

uint16_t digit[8*4];

void set_digit(int n, char c)
{
    digit[n] = (n<<8) | font[c];
}

void set_string(const char *s)
{
    for(int n=0; s[n] != '\0'; n++)
        set_digit(n,s[n]);
}

int main(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
    GPIOB->MODER |= 0x155555;
    set_string("running.");

    // display loop
    /*for(;;) {
        for(int x=0; x < 8; x++) {
            GPIOB->ODR = digit[x];
            for(int n=0; n < 100; n++);
        }
    }*/

    RCC->AHBENR |= RCC_AHBENR_DMA1EN;
    DMA1_Channel2->CMAR = (uint32_t) digit;
    DMA1_Channel2->CPAR = (uint32_t) 0x48000414;
    DMA1_Channel2->CNDTR = 8*4;
    DMA1_Channel2->CCR &= ~(DMA_CCR_MSIZE | DMA_CCR_PSIZE);
    DMA1_Channel2->CCR |= (DMA_CCR_DIR | DMA_CCR_MSIZE_0 | DMA_CCR_PSIZE_0
                         | DMA_CCR_MINC | DMA_CCR_CIRC);
    DMA1_Channel2->CCR |= DMA_CCR_EN;

    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;
    TIM2->PSC = 3000-1;
    TIM2->ARR = 2-1;
    TIM2->DIER |= TIM_DIER_UDE;
    TIM2->CR1 |= TIM_CR1_CEN;

    RCC->APB1ENR |= RCC_APB1ENR_TIM7EN;
    TIM7->PSC = 48000-1;
    TIM7->ARR = 125-1;
    TIM7->DIER |= TIM_DIER_UIE;
    TIM7->CR1 |= TIM_CR1_CEN;
    NVIC->ISER[0] = (1<<TIM7_IRQn);
}

void TIM7_IRQHandler() {
    TIM7->SR &= ~TIM_SR_UIF;

    eighth += 1;
    if (eighth >= 8) { eighth -= 8; sec += 1; }
    if (sec >= 60)   { sec -= 60;   min += 1; }
    if (min >= 60)   { min -= 60;   hrs += 1; }
    if (hrs >= 24)   { hrs -= 24; }
    char time[8];
    sprintf(time, "%02d%02d%02d  ", hrs, min, sec);
    set_string(time);
    if (eighth > 0 && eighth < 4) {
        memcpy(&digit[8*eighth], digit, 2*8);
    }
}

#include "stm32f0xx.h"
//extern int counter;

//Q1: recur [1 point]

unsigned int recur(unsigned int x) {
        if (x < 3)
                return x;
        if ((x & 0xf) == 0)
                return 1 + recur(x - 1);
        return recur(x >> 1) + 2;
}

//Q2: enable_portb [1 point]
void enable_portb() {
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
}

//Q3: enable_portc [1 point]
void enable_portc() {
    RCC->AHBENR |= RCC_AHBENR_GPIOCEN;
}

//Q4: setup_pb3 [1 point]
void setup_pb3() {
    GPIOB->MODER &= ~GPIO_MODER_MODER3;
    GPIOB->PUPDR &= ~GPIO_PUPDR_PUPDR3;
    GPIOB->PUPDR |= GPIO_PUPDR_PUPDR3_1;
}

//Q5: setup_pb4 [1 point]
void setup_pb4() {
    GPIOB->MODER &= ~GPIO_MODER_MODER4;
    GPIOB->PUPDR &= ~GPIO_PUPDR_PUPDR4;
}

//Q6: setup_pc8 [1 point]
void setup_pc8() {
    GPIOC->MODER &= ~GPIO_MODER_MODER8;
    GPIOC->MODER |= GPIO_MODER_MODER8_1;
    GPIOC->OSPEEDR |= GPIO_OSPEEDR_OSPEEDR8;
}

//Q7: setup_pc9 [1 point]
void setup_pc9() {
    GPIOC->MODER &= ~GPIO_MODER_MODER9;
    GPIOC->MODER |= GPIO_MODER_MODER9_1;
    GPIOC->OSPEEDR &= ~GPIO_OSPEEDR_OSPEEDR9;
    GPIOC->OSPEEDR |= GPIO_OSPEEDR_OSPEEDR9_0;
}

//Q8: action8 [1 point]
void action8() {
    if(((GPIOB->IDR & GPIO_IDR_3) == 1) && ((GPIOB->IDR & GPIO_IDR_4) == 0))
    {
        GPIOC->BRR = GPIO_BRR_BR_8;
    }
    else
    {
        GPIOC->BSRR = GPIO_BSRR_BS_8;
    }
}

//Q9: action9 [1 point]
void action9() {
    if(((GPIOB->IDR & GPIO_IDR_3) == 0) && ((GPIOB->IDR & GPIO_IDR_4) == 1))
    {
        GPIOC->BRR = GPIO_BSRR_BS_9;
    }
    else
    {
        GPIOC->BSRR = GPIO_BRR_BR_9;
    }
}

//Q10: External Interrupt Handler [1 point]
void EXTI2_3_IRQHandler() {
    //counter = counter + 1;
    EXTI->PR = (1<<EXTI2_3_IRQn);
}

//Q11: enable_exti [1 point]
void enable_exti() {
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGCOMPEN;
    SYSCFG->EXTICR[2] |= SYSCFG_EXTICR1_EXTI2_PB;
    EXTI->RTSR |= EXTI_RTSR_TR2;
    EXTI->IMR |= EXTI_IMR_MR2;
    NVIC->ISER[0] = (1<<EXTI2_3_IRQn);
}

//Q12: (the interrupt handler for Timer 3) [1 point]
void TIM3_IRQHandler() {
    TIM3->SR &= ~TIM_SR_UIF;
    if((GPIOB->ODR & GPIO_ODR_9) == 1)
    {
        GPIOB->BSRR = GPIO_BSRR_BS_9;
    }
    else
    {
        GPIOB->BRR = GPIO_BRR_BR_9;
    }
}

//Q13: enable_tim3 [1 point]
void enable_tim3() {
    RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;
    TIM3->PSC = 48000-1;
    TIM3->ARR = 250-1;
    TIM3->DIER |= TIM_DIER_UIE;
    NVIC->ISER[0] = (1<<TIM3_IRQn);
}

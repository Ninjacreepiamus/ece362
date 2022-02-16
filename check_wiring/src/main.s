.cpu cortex-m0
.thumb
.syntax unified

// RCC configuration registers
.equ  RCC,      0x40021000
.equ  AHBENR,   0x014
.equ  GPIOCEN,  0x080000
.equ  GPIOBEN,  0x040000
.equ  GPIOAEN,  0x020000
.equ  APB1ENR,  0x01c
.equ  TIM6EN,   1<<4
.equ  TIM7EN,   1<<5
.equ  TIM14EN,  1<<8

// NVIC configuration registers
.equ NVIC, 0xe000e000
.equ ISER, 0x0100
.equ ICER, 0x0180
.equ ISPR, 0x0200
.equ ICPR, 0x0280
.equ IPR,  0x0400
.equ TIM6_DAC_IRQn, 17
.equ TIM7_IRQn,     18
.equ TIM14_IRQn,    19

// Timer configuration registers
.equ TIM6,   0x40001000
.equ TIM7,   0x40001400
.equ TIM14,  0x40002000
.equ TIM_CR1,  0x00
.equ TIM_CR2,  0x04
.equ TIM_DIER, 0x0c
.equ TIM_SR,   0x10
.equ TIM_EGR,  0x14
.equ TIM_CNT,  0x24
.equ TIM_PSC,  0x28
.equ TIM_ARR,  0x2c

// Timer configuration register bits
.equ TIM_CR1_CEN,  1<<0
.equ TIM_DIER_UDE, 1<<8
.equ TIM_DIER_UIE, 1<<0
.equ TIM_SR_UIF,   1<<0

// GPIO configuration registers
.equ  GPIOC,    0x48000800
.equ  GPIOB,    0x48000400
.equ  GPIOA,    0x48000000
.equ  MODER,    0x0
.equ  PUPDR,    0xc
.equ  IDR,      0x10
.equ  ODR,      0x14
.equ  BSRR,     0x18
.equ  BRR,      0x28

.global main
main:
	ldr r0, =RCC
	ldr r1, =

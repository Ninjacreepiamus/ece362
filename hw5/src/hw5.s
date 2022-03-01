.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.equ RCC,       0x40021000
.equ GPIOA,     0x48000000
.equ GPIOB,     0x48000400
.equ GPIOC,     0x48000800
.equ AHBENR,    0x14
.equ APB2ENR,   0x18
.equ APB1ENR,   0x1c
.equ IOPAEN,    0x20000
.equ IOPBEN,    0x40000
.equ IOPCEN,    0x80000
.equ SYSCFGCOMPEN, 1
.equ TIM3EN,    2
.equ MODER,     0
.equ OSPEEDR,   8
.equ PUPDR,     0xc
.equ IDR,       0x10
.equ ODR,       0x14
.equ BSRR,      0x18
.equ BRR,       0x28
.equ PC8,       0x100
.equ PC9,		0x200

// SYSCFG control registers
.equ SYSCFG,    0x40010000
.equ EXTICR1,   0x8
.equ EXTICR2,   0xc
.equ EXTICR3,   0x10
.equ EXTICR4,   0x14

// NVIC control registers
.equ NVIC,      0xe000e000
.equ ISER,      0x100

// External interrupt control registers
.equ EXTI,      0x40010400
.equ IMR,       0x00
.equ RTSR,      0x08
.equ PR,        0x14

.equ TIM3,      0x40000400
.equ TIMCR1,    0x00
.equ DIER,      0x0c
.equ TIMSR,     0x10
.equ PSC,       0x28
.equ ARR,       0x2c

// Popular interrupt numbers
.equ EXTI0_1_IRQn,   5
.equ EXTI2_3_IRQn,   6
.equ EXTI4_15_IRQn,  7
.equ EXTI4_15_IRQn,  7
.equ TIM2_IRQn,      15
.equ TIM3_IRQn,      16
.equ TIM6_DAC_IRQn,  17
.equ TIM7_IRQn,      18
.equ TIM14_IRQn,     19
.equ TIM15_IRQn,     20
.equ TIM16_IRQn,     21
.equ TIM17_IRQn,     22

// Others

.equ B_ENABLE, 	0x00500000
.equ C_ENABLE,	0x00800000
.equ PB3_CLR,	0x000000c0
.equ PB3_EN,	0x00000050
.equ PB4_CLR, 	0x00000300
.equ PC8_CLR,	0x00030000
.equ PC8_EN,	0x00010000
.equ OSPEEDR_8,	0x00030000
.equ PC9_CLR, 	0x000c0000
.equ PC9_OUT,	0x00050000
.equ OSPEEDR_C,	0x000c0000
.equ OSPEEDR_9,	0x00050000

//====================================================================
// Q1
//====================================================================
.global recur
recur:
	push {r4-r7, lr}
	movs r6, r0 // x is in r6
	cmp r6, #3
	bge skipreturn
	//IF BLOCK IS EMPTY

skipreturn:
	movs r5, #0xf
	ands r5, r6
	cmp r5, #0
	bne endifs
	movs r4, r5 // recur x - 1 value
	subs r4, #1
	movs r0, r4
	bl recur
	adds r0, #1
	pop {r4-r7, pc}

endifs:
	movs r4, r5
	lsrs r4, #1
	movs r0, r4
	bl recur
	adds r0, #2
	pop {r4-r7, pc}

//====================================================================
// Q2
//====================================================================
.global enable_portb
enable_portb:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #AHBENR]
	ldr r2, =B_ENABLE
	orrs r1, r2
	str r1, [r0, #AHBENR]

	pop {pc}

//====================================================================
// Q3
//====================================================================
.global enable_portc
enable_portc:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #AHBENR]
	ldr r2, =C_ENABLE
	orrs r1, r2
	str r1, [r0, #AHBENR]

	pop {pc}

//====================================================================
// Q4
//====================================================================
.global setup_pb3
setup_pb3:
	push {lr}
	ldr r0, =GPIOB
	ldr r1, [r0, #MODER]
	ldr r2, =PB3_CLR
	bics r1, r2
	str r1, [r0, #MODER]

	ldr r0, =GPIOB
	ldr r1, [r0, #PUPDR]
	ldr r2, =PB3_CLR
	bics r1, r2
	ldr r2, =PB3_EN
	orrs r1, r2
	str r1, [r0, #PUPDR]

	pop {pc}


//====================================================================
// Q5
//====================================================================
.global setup_pb4
setup_pb4:
	push {lr}
	ldr r0, =GPIOB
	ldr r1, [r0, #MODER]
	ldr r2, =PB4_CLR
	bics r1, r2
	str r1, [r0, #MODER]

	ldr r0, =GPIOB
	ldr r1, [r0, #PUPDR]
	ldr r2, =PB4_CLR
	bics r1, r2
	str r1, [r0, #PUPDR]

	pop {pc}
//====================================================================
// Q6
//====================================================================
.global setup_pc8
setup_pc8:
	push {lr}
	ldr r0, =GPIOC
	ldr r1, [r0, #MODER]
	ldr r2, =PC8_CLR
	bics r1, r2
	ldr r2, =PC8_EN
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r0, =GPIOC
	ldr r1, [r0, #OSPEEDR]
	ldr r2, =OSPEEDR_8
	orrs r1, r2
	str r1, [r0, #OSPEEDR]

	pop {pc}
//====================================================================
// Q7
//====================================================================
.global setup_pc9
setup_pc9:
	push {lr}
	ldr r0, =GPIOC
	ldr r1, [r0, #MODER]
	ldr r2, =PC9_CLR
	bics r1, r2
	ldr r2, =PC9_OUT
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r0, =GPIOC
	ldr r1, [r0, #OSPEEDR]
	ldr r2, =OSPEEDR_C
	bics r1, r2
	ldr r2, =OSPEEDR_9
	orrs r1, r2
	str r1, [r0, #OSPEEDR]

	pop {pc}
//====================================================================
// Q8
//====================================================================
.global action8
action8:
	push {r4, lr}
	ldr r0, =GPIOB
	ldr r1, [r0, #ODR]
	movs r3, r1
	ldr r4, =0xffffffef
	bics r3, r4
	lsrs r3, #4
	cmp r3, #1

	bne conditions
	ldr r4, =0xfffffff7
	movs r3, r1
	bics r3, r4
	lsrs r3, #3
	cmp r3, #0

	bne conditions
	ldr r0, =GPIOC
	ldr r2, =0x00000100
	str r2, [r0, #BSR]
	pop {r4, pc}


conditions:
	ldr r0, =GPIOC
	ldr r2, =0x00000100
	str r2, [r0, #BSRR]

	pop {r4, pc}
//====================================================================
// Q9
//====================================================================
.global action9
action9:
	push {r4, lr}
	ldr r0, =GPIOB
	ldr r1, [r0, #ODR]
	movs r3, r1
	ldr r4, =0xffffffef
	bics r3, r4
	lsrs r3, #4
	cmp r3, #0

	bne conditions
	ldr r4, =0xfffffff7
	movs r3, r1
	bics r3, r4
	lsrs r3, #3
	cmp r3, #1

	bne conditions
	ldr r0, =GPIOC
	ldr r2, =0x00000200
	str r2, [r0, #BSRR]
	pop {r4, pc}


conditions:
	ldr r0, =GPIOC
	ldr r2, =0x00000200
	str r2, [r0, #BSR]

	pop {r4, pc}

//====================================================================
// Q10
//====================================================================
// Do everything needed to write the ISR here...
.global EXTI2_3_IRQHandler
.type EXTI2_3_IRQHandler, %function
EXTI2_3_IRQHandler:
	push {lr}

	pop {pc}
//====================================================================
// Q11
//====================================================================
.global enable_exti
enable_exti:

//====================================================================
// Q12
//====================================================================
// Do everything needed to write the ISR here...
.global TIM3_IRQHandler
.type TIM3_IRQHandler, %function
TIM3_IRQHandler:
	push {lr}

	ldr r2, =GPIOC
	ldr r1, =PC9
	ldr r2, [r1, #ODR]
	eors r2, r1

	ldr r0, =TIM3
	ldr r1, [r0, #TIMSR]
	ldr r3, =0x00000001
	bics r1, r3
	str r1, [r0, #TIMSR]

	pop {pc}
//====================================================================
// Q13
//====================================================================
.global enable_tim3
enable_tim3:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =0x00000002
	orrs r1, r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM3
	ldr r1, =48000-1
	str r1, [r0, #TIM_PSC]
	ldr r1, =250-1
	str r1, [r0, #TIM_ARR]

	ldr r1, [r0, #TIM_DIER]
	ldr r3, =0x00000050
	orrs r1, r3
	str r1, [r0, #TIM_DIER]

	ldr r1, [r0, #TIM_CR1]
	ldr r2, =0x00000001
	orrs r1, r2
	str r1, [r0, #TIM_CR1]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =TIM3_IRQn
	movs r3, #1

	lsls r3, r2
	str r3, [r0, r1]

	pop {pc}

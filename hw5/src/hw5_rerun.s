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

.global counter
.word counter 0

// Prep work for practical

.global tim2_setup
tim2_setup:
	push {lr}
	// Enable timer in APB1ENR
	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =(1<<0)
	orrs r1, r2
	str r1, [r0, #APB1ENR]

	// Write appropriate PSC/ARR values
	ldr r0, =TIM2
	ldr r1, =48000-1
	ldr r2, =500-1
	str r1, [r0, #PSC]
	str r2, [r0, #ARR]

	//Set UIE bit of DIER
	ldr r0, =TIM2
	ldr r1, [r0, #DIER]
	ldr r2, =(1<<0)
	orrs r1, r2
	str r1, [r0, #DIER]

	//Enable counter of TIM2
	ldr r0, =TIM2
	ldr r1, [r0, #TIM2_CR1]
	ldr r2, =(1<<0)
	orrs r1, r2
	str r1, [r0, #TIM2_CR1]

	//Write to NVIC #ISER to unmask interrupt
	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =(1<<TIM2_IRQHandler)
	str r2, [r0, r1]

	pop {pc}

.global TIM2_IRQHandler
.type TIM2_IRQHandler, %function
TIM2_IRQHandler:
	push {lr}
	ldr r0, =TIM2
	ldr r1, [r0, #TIM2_SR]
	ldr r2, =(1<<0) //UIF bit
	bics r1, r2
	str r1, [r0, #TIM2_SR]

	pop {pc}





//====================================================================
// Q1
//====================================================================
.global recur
recur:
	push {r4-r7, lr}
	movs r4, r0
	cmp r4, #3
	bge secondif
	movs r0, r4
	pop {r4-r7, pc}

secondif:
	movs r5, #0xf
	ands r5, r4
	cmp r5, #0
	bne afterifs
	movs r6, r4
	subs r4, r6
	bl recur
	adds r0, #1

	pop {r4-r7, pc}

afterifs:
	movs r5, #1
	lsrs r5, r0, r5
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
	ldr r2, =0x00040000
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
	ldr r2, =0x00080000
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
	ldr r2, =0x000000c0
	bics r1, r2
	ldr r2, =0x00000040
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r1, [r0, #PUPDR]
	ldr r2, =0x000000c0
	bics r1, r2
	ldr r2, =0x00000080
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
	ldr r2, =0x00000300
	bics r1, r2
	str r1, [r0, #MODER]

	ldr r1, [r0, #PUPDR]
	ldr r2, =0x00000300
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
	ldr r2, 0x00030000
	bics r1, r2
	ldr r2, =0x00010000
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r1, [r0, #OSPEEDR]
	ldr r2, =0x00030000
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
	ldr r2, =0x000c0000
	bics r1, r2
	ldr r2, =0x00040000
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r1, [r0, #OSPEEDR]
	ldr r2, =0x000c0000
	bics r1, r2
	ldr r2, =0x00040000
	orrs r1, r2
	str r1, [r0, #OSPEEDR]

	pop {lr
//====================================================================
// Q8
//====================================================================
.global action8
action8:
	push {lr}
	ldr r0, =GPIOB
	ldr r1, [r0, #IDR]
	movs r3, #1
	ands r1, r3
	lsrs r1, #3 // pb3 is 0 or 1

	ldr r2, [r0, #IDR]
	movs r3, #1
	ands r2, r3
	lsrs r2, #4 // pb4 is 0 or 1

	cmp r1, #1
	bne exit	//PB3 not high
	cmp r2, #0
	bne exit	//PB4 not low

	//IF YES, set PC8 to 0
	movs r3, #1
	lsls r3, #8 // shifts 1 to 8s place in BRR
	str r3, [r0, #BRR]

exit:
	//ELSE set PC8 to 1
	movs r3, #1
	lsls r3, #8
	str r3, [r0, #BSRR]

	pop {pc}

//====================================================================
// Q9
//====================================================================
.global action9
action9:
	push {lr}
	ldr r0, =GPIOB
	ldr r1, [r0, #IDR]
	movs r3, #1
	ands r1, r3
	lsrs r1, #3 // pb3 is 0 or 1

	ldr r2, [r0, #IDR]
	movs r3, #1
	ands r2, r3
	lsrs r2, #4 // pb4 is 0 or 1

	cmp r1, #0
	bne exit	//PB3 not high
	cmp r2, #1
	bne exit	//PB4 not low

	//IF YES, set PC8 to 0
	movs r3, #1
	lsls r3, #8 // shifts 1 to 8s place in BRR
	str r3, [r0, #BSRR]

exit:
	//ELSE set PC8 to 1
	movs r3, #1
	lsls r3, #8
	str r3, [r0, #BRR]

	pop {pc}

//====================================================================
// Q10
//====================================================================
// Do everything needed to write the ISR here...
.global EXTI2_3_IRQHandler
.type EXTI2_3_IRQHandler, %function
EXTI2_3_IRQHandler:
	push {lr}
	ldr r0, =counter
	ldr r1, [r0]
	adds r1, #1
	str r1, [r0]

	ldr r0, =NVIC
	ldr r1, =EXTI_PR
	ldr r2, =(1<<EXTI2_3_IRQn)
	str r2, [r0, r1]

	pop {pc}
//====================================================================
// Q11
//====================================================================
.global enable_exti
enable_exti:
	push {lr}
	ldr r0, =RCC
	ldr r1, [r0, #APB2ENR]
	ldr r2, =SYSCFGCOMPEN
	orrs r1, r2
	str r1, [r0, #APB2ENR]

	ldr r0, =SYSCFG
	ldr r1, [r0, #EXTICR1]
	ldr r2, =0x00000100
	orrs r1, r2
	str r1, [r0, #EXTICR1]

	ldr r0, =EXTI
	ldr r1, [r0, #RTSR]
	ldr r2, =0x00000004
	orrs r1, r2
	str r1, [r0, #RTSR]

	ldr r0, =EXTI
	ldr r1, [r0, #IMR]
	ldr r2, =0x00000004
	orrs r1, r2
	str r1, [r0, #IMR]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =(1<<EXTI2_3_IRQn)
	str r2, [r0, r1]

	pop {pc}


//====================================================================
// Q12
//====================================================================
// Do everything needed to write the ISR here...
.global TIM3_IRQHandler
.type TIM3_IRQHandler, %function
TIM3_IRQHandler:
	push {lr}
	ldr r0, =GPIOC
	ldr r1, [r0, #MODER]
	movs r3, #1
	ands r1, r3
	lsrs r1, #9

	cmp r1, #0
	bne high //if high
	ldr r2, =(1<<9) //if low
	str r2, [r0, #BSRR]
	b ender

high:
	ldr r2, =(1<<9)
	str r2, [r0, #BRR]

ender:
	ldr r0, =NVIC
	ldr r1, =EXTI_PR
	ldr r2, =(1<<TIM3_IRQn)
	str r2, [r0, r1]

	pop {pc}

//====================================================================
// Q13
//====================================================================
.global enable_tim3
enable_tim3:
	push {lr}
	ldr r0, =RCC
	ldr r1, =APB1ENR
	ldr r2, =0x00000002
	orrs r1, r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM3
	ldr r1, =4800-1
	str r1, [r0, #PSC]
	ldr r2, =250-1
	str r2, [r0, #ARR]

	ldr r0, =TIM3
	ldr r1, [r0, #DIER]
	ldr r2, =0x00000001
	orrs r1, r2
	str r1, [r0, #DIER]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =(1<<TIM3_IRQn)
	str r2, [r0, r1]

	ldr r0, =TIM3
	ldr r1, [r0, #TIMCR1]
	ldr r2, =0x00000001
	orrs r1, r2
	str r1, [r0, #TIMCR1]

	pop {pc}

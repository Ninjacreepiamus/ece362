.syntax unified
.cpu cortex-m0
.fpu softvfp
.thumb

//==================================================================
// ECE 362 Lab Experiment 4
// Interrupts
//==================================================================

// RCC config registers
.equ  RCC,      0x40021000
.equ  AHBENR,   0x014
.equ  GPIOAEN,  0x20000
.equ  GPIOBEN,  0x40000
.equ  GPIOCEN,  0x80000
.equ  APB2ENR,  0x018
.equ  SYSCFGCOMPEN, 1
.equ  CLEAR_C,	0x000fffff
.equ  OUT_C,	0x00055500
.equ  PUPVAL,	0x000000aa
.equ  PUPCLR,	0x000000ff
.equ  CLEAR_B,	0x00ff03f3
.equ  OUT_B,	0x00550000
.equ  PUPVAL2, 	0x000000a0
.equ  PUPCLR2,	0x000000f0

// GPIO config registers
.equ  GPIOA,    0x48000000
.equ  GPIOB,    0x48000400
.equ  GPIOC,    0x48000800
.equ  MODER,    0
.equ  PUPDR,    0x0c
.equ  IDR,      0x10
.equ  ODR,      0x14
.equ  BSRR,     0x18
.equ  BRR,      0x28

// SYSCFG config registers
.equ SYSCFG, 0x40010000
.equ EXTICR1, 0x08
.equ EXTICR2, 0x0c
.equ EXTICR3, 0x10
.equ EXTICR4, 0x14

// External interrupt config registers
.equ EXTI,  0x40010400
.equ IMR,   0x00
.equ EMR,   0x04
.equ RTSR,  0x08
.equ FTSR,  0x0c
.equ SWIER, 0x10
.equ PR,    0x14

// Variables to register things for EXTI on pin 0
.equ EXTI_RTSR_TR0, 1<<0
.equ EXTI_IMR_MR0,  1<<0
.equ EXTI_PR_PR0,   1<<0
// Variables to register things for EXTI on pin 1
.equ EXTI_RTSR_TR1, 1<<1
.equ EXTI_IMR_MR1,  1<<1
.equ EXTI_PR_PR1,   1<<1
// Variables to register things for EXTI on pin 2
.equ EXTI_RTSR_TR2, 1<<2
.equ EXTI_IMR_MR2,  1<<2
.equ EXTI_PR_PR2,   1<<2
// Variables to register things for EXTI on pin 3
.equ EXTI_RTSR_TR3, 1<<3
.equ EXTI_IMR_MR3,  1<<3
.equ EXTI_PR_PR3,   1<<3
// Variables to register things for EXTI on pin 4
.equ EXTI_RTSR_TR4, 1<<4
.equ EXTI_IMR_MR4,  1<<4
.equ EXTI_PR_PR4,   1<<4

// SysTick counter variables....
.equ STK, 0xe000e010
.equ CSR, 0x00
.equ RVR, 0x04
.equ CVR, 0x08

// NVIC config registers
.equ NVIC, 0xe000e000
.equ ISER, 0x0100
.equ ICER, 0x0180
.equ ISPR, 0x0200
.equ ICPR, 0x0280
.equ IPR,  0x0400
.equ EXTI0_1_IRQn,5  // External interrupt number for pins 0 and 1 is IRQ 5.
.equ EXTI2_3_IRQn,6  // External interrupt number for pins 2 and 3 is IRQ 6.
.equ EXTI4_15_IRQn,7 // External interrupt number for pins 4 - 15 is IRQ 7.

// GPIO config registers
.equ  GPIOC,    0x48000800
.equ  GPIOB,    0x48000400
.equ  GPIOA,    0x48000000
.equ  MODER,    0x00
.equ  PUPDR,    0x0c
.equ  IDR,      0x10
.equ  ODR,      0x14
.equ  BSRR,     0x18
.equ  BRR,      0x28

//==========================================================
// nano_wait
// Loop for approximately the specified number of nanoseconds.
// Write the entire subroutine below.
.global nano_wait
nano_wait:
	subs r0, #83
	bgt nano_wait
	bx lr

//==========================================================
// initc
// Enable the RCC clock for GPIO C and configure pins as 
// described in section 2.2.1.
// Do not modify any other pin configuration.
// Parameters: none
// Write the entire subroutine below.
.global initc
initc:
    push    {lr}
    // Student code goes here
	ldr r0, =RCC
	ldr r1, [r0, #AHBENR]
	ldr r2, =GPIOCEN
	orrs r1, r2
	str r1, [r0, #AHBENR]

	ldr r0, =GPIOC
	ldr r1, [r0, #MODER]
	ldr r3, =CLEAR_C
	bics r1, r3
	ldr r2, =OUT_C
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r1, [r0, #PUPDR]
	ldr r3, =PUPCLR
	bics r1, r3
	ldr r2, =PUPVAL
	orrs r1, r2
	str r1, [r0, #PUPDR]
    // End of student code
    pop     {pc}

//==========================================================
// initb
// Enable the RCC clock for GPIO B and configure pins as 
// described in section 2.2.2
// Do not modify any other pin configuration.
// Parameters: none
// Write the entire subroutine below.
.global initb
initb:
    push    {lr}
    // Student code goes here
	ldr r0, =RCC
	ldr r1, [r0, #AHBENR]
	ldr r2, =GPIOBEN
	orrs r1, r2
	str r1, [r0, #AHBENR]

	ldr r0, =GPIOB
	ldr r1, [r0, #MODER]
	ldr r3, =CLEAR_B
	bics r1, r3
	ldr r2, =OUT_B
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r1, [r0, #PUPDR]
	ldr r3, =PUPCLR2
	bics r1, r3
	ldr r2, =PUPVAL2
	orrs r1, r2
	str r1, [r0, #PUPDR]

    // End of student code
    pop     {pc}

//==========================================================
// togglexn
// Change the ODR value from 0 to 1 or 1 to 0 for a specified
// pin of Port C.
// Parameters: r0 holds the base address of the GPIO port
//                to use
//             r1 holds the pin number to toggle
// Write the entire subroutine below.
.global togglexn
togglexn:
	ldr r3, [r0, #ODR]
	movs r2, #1
	lsls r2, r1
	eors r3, r2
	str r3, [r0, #ODR]
	bx lr

//==========================================================
// Write the EXTI interrupt handler for pins 0 and 1 below.
// Copy the name from startup/startup_stm32.s, create a label
// of that name below, declare it to be global, and declare
// it to be a function.
// It acknowledge the pending bit for pin 0, and it should
// call togglexn(GPIOB, 8).

.global EXTI0_1_IRQHandler
.type EXTI0_1_IRQHandler, %function
EXTI0_1_IRQHandler:
	push {r4-r7, lr}
	ldr r0, =EXTI
	ldr r1, [r0, #PR]
	ldr r2, =EXTI_PR_PR0
	bics r1, r2
	orrs r2, r1
	str r2, [r0, #PR]
	ldr r0, =GPIOB
	movs r1, #8
	bl togglexn
	pop {r4-r7, pc}
//==========================================================
// Write the EXTI interrupt handler for pins 2-3 below.
// It should acknowledge the pending bit for pin2, and it
// should call togglexn(GPIOB, 9).
.global EXTI2_3_IRQHandler
.type EXTI2_3_IRQHandler, %function
EXTI2_3_IRQHandler:
	push {r4-r7, lr}
	ldr r0, =EXTI
	ldr r1, [r0, #PR]
	ldr r2, =EXTI_PR_PR0
	bics r1, r2
	orrs r2, r1
	str r2, [r0, #PR]
	ldr r0, =GPIOB
	movs r1, #9
	bl togglexn
	pop {r4-r7, pc}

//==========================================================
// Write the EXTI interrupt handler for pins 4-15 below.
// It should acknowledge the pending bit for pin4, and it
// should call togglxn(GPIOB, 10).
.global EXTI4_15_IRQHandler
.type EXTI4_15_IRQHandler, %function
EXTI4_15_IRQHandler:
	push {r4-r7, lr}
	ldr r0, =EXTI
	ldr r1, [r0, #PR]
	ldr r2, =EXTI_PR_PR0
	bics r1, r2
	orrs r2, r1
	str r2, [r0, #PR]
	ldr r0, =GPIOB
	movs r1, #10
	bl togglexn
	pop {r4-r7, pc}

//==========================================================
// init_exti
// (1) Enable the SYSCFG subsystem, and select Port B for
//     pins 0, 2, 3, and 4.
// (2) Configure the EXTI_RTSR register so that an EXTI
//     interrupt is generated on the rising edge of
//     pins 0, 2, 3, and 4.
// (3) Configure the EXTI_IMR register so that the EXTI
//     interrupts are unmasked for pins 2, 3, and 4.
// (4) Enable the three interupts for EXTI pins 0-1, 2-3 and 
//     4-15. Don't enable any other interrupts.
// Parameters: none
.global init_exti
init_exti:
	push {r4, r5, lr}
	// Student code goes below
	ldr r0, =RCC
	ldr r1, [r0, APB2ENR]
	ldr r2, =SYSCFGCOMPEN
	orrs r1, r2
	str r1, [r0, APB2ENR]

	ldr r0, =SYSCFG
	ldr r1, [r0, #EXTICR1]
	ldr r2, [r0, #EXTICR2]
	ldr r4, = 0x00001111
	orrs r1, r4
	orrs r2, r4
	str r1, [r0, #EXTICR1]
	str r2, [r0, #EXTICR2]

	//RTSR
	ldr r0, =EXTI
	ldr r1, [r0, #RTSR]
	ldr r2, =EXTI_RTSR_TR0
	ldr r3, =EXTI_RTSR_TR2
	ldr r4, =EXTI_RTSR_TR3
	ldr r5, =EXTI_RTSR_TR4
	orrs r1, r2
	orrs r1, r3
	orrs r1, r4
	orrs r1, r5
	str r1, [r0, #RTSR]

	//IMR
	ldr r1, [r0, #IMR]
	ldr r2, =EXTI_IMR_MR0
	ldr r3, =EXTI_IMR_MR2
	ldr r4, =EXTI_IMR_MR3
	ldr r5, =EXTI_IMR_MR4
	orrs r1, r2
	orrs r1, r3
	orrs r1, r4
	orrs r1, r5
	str r1, [r0, #IMR]

	//ISER
	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =EXTI0_1_IRQn
	ldr r3, =EXTI2_3_IRQn
	ldr r4, =EXTI4_15_IRQn
	movs r5, #1
	lsls r5, r2
	movs r2, r5 // new r2
	movs r5, #1
	lsls r5, r3
	movs r3, r5 // new r3
	movs r5, #1
	lsls r5, r4
	movs r4, r5 // new r4
	orrs r2, r3
	orrs r2, r4
	str r2, [r0, r1]

	// Student code goes above
	pop  {r4, r5, pc}


//==========================================================
// set_col
// Set the specified column level to logic "high.
// Set the other three three columns to logic "low".
.global set_col
set_col:
	push {r4-r7, lr}

	ldr r1, =GPIOC
	ldr r4, [r1, #BSRR]
	movs r2, #0xf
	movs r3, #16
	adds r3, #4
	lsls r2, r3
	str r2, [r1, #BSRR]
	movs r4, #1
	movs r5, #8
	subs r5, r0
	lsls r4, r5
	str r4, [r1, #BSRR]

	pop {r4-r7, pc}

//==========================================================
// The current_col variable.
.data
.global current_col
current_col:
        .word 1
.text


//==========================================================
// SysTick_Handler
// The ISR for the SysTick interrupt.
//
.global SysTick_Handler
.type SysTick_Handler, %function
SysTick_Handler:
	push {r4-r7, lr}
	// Student code goes below
	ldr r0, =GPIOC
	ldr r1, [r0, #IDR]
	movs r6, #0xf
	//row val is r6
	ands r6, r1
	//current_col will be r7

	//Block 1
	ldr r0, =current_col
	ldr r7, [r0]
	cmp r7, #1
	bne elseif1
	movs r2, #0x8
	ands r2, r6
	cmp r2, #0
	beq elseif1
	//Made it through block1
	ldr r0, =GPIOB
	movs r1, #8
	bl togglexn
	b doneif

elseif1:
	//Block 2
	ldr r0, =current_col
	ldr r7, [r0]
	cmp r7, #2
	bne elseif2
	movs r2, #0x4
	ands r2, r6
	cmp r2, #0
	beq elseif2
	//Made it through block2
	ldr r0, =GPIOB
	movs r1, #9
	bl togglexn
	b doneif

elseif2:
	//Block 2
	ldr r0, =current_col
	ldr r7, [r0]
	cmp r7, #3
	bne elseif3
	movs r2, #0x2
	ands r2, r6
	cmp r2, #0
	beq elseif3
	//Made it through block2
	ldr r0, =GPIOB
	movs r1, #10
	bl togglexn
	b doneif

elseif3:
	//Block 3
	ldr r0, =current_col
	ldr r7, [r0]
	cmp r7, #4
	bne doneif
	movs r2, #0x1
	ands r2, r6
	cmp r2, #0
	beq doneif
	//Made it through block3
	ldr r0, =GPIOB
	movs r1, #11
	bl togglexn
	b doneif

doneif:
	adds r7, #1
	ldr r0, =current_col
	str r7, [r0]
	cmp r7, #4
	ble finalif
	ldr r0, =current_col
	movs r7, #1
	str r7, [r0]

finalif:
	ldr r1, =current_col
	ldr r7, [r1]
	movs r0, r7
	bl set_col

	// Student code goes above
	pop  {r4-r7, pc}

//==========================================================
// init_systick
// Enable the SysTick interrupt to occur every 0.5 seconds.
// Parameters: none
.global init_systick
init_systick:
	push {lr}
	// Student code goes below

	ldr r0, =STK
	ldr r1, =0x5b8d7
	str r1, [r0, #RVR]
	ldr r1, [r0, #CSR]
	ldr r2, =0x00000008
	bics r2, r1
	ldr r3, =0x00000003
	orrs r2, r3
	str r2, [r0, #CSR]

	// Student code goes above
	pop  {pc}


//==========================================================
// adjust_priorities
// Set the priority for EXTI pins 2-3 interrupt to 192.
// Set the priority for EXTI pins 4-15 interrupt to 128.
// Do not adjust the priority for any other interrupts.
.global adjust_priorities
adjust_priorities:
	push {lr}
	// Student code goes below

	// Student code goes above
	pop  {pc}

//==========================================================
// The main subroutine will call everything else.
// It will never return.
.global main
main:
	bl autotest // Uncomment when most things are working
	bl initb
	bl initc
	bl init_exti
	bl init_systick
	bl adjust_priorities

endless_loop:
	ldr  r0,=GPIOC
	movs r1,#9
	bl   togglexn
	ldr  r0,=500000000
	bl   nano_wait
	b    endless_loop


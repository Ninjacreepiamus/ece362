.syntax unified
.cpu cortex-m0
.fpu softvfp
.thumb

//==================================================================
// ECE 362 Lab Experiment 3
// General Purpose I/O
//==================================================================

.equ  RCC,      0x40021000
.equ  AHBENR,   0x014
.equ  GPIOAEN,  0x20000
.equ  GPIOBEN,  0x40000
.equ  GPIOCEN,  0x80000
.equ  GPIOA,    0x48000000
.equ  GPIOB,    0x48000400
.equ  GPIOC,    0x48000800
.equ  MODER,    0x00 
.equ  PUPDR,    0x0c
.equ  IDR,      0x10 
.equ  ODR,      0x14
.equ  BSRR,     0x18 
.equ  BRR,      0x28
.equ  OUT_ALL, 0x00550000
.equ  CLEAR_ALL, 0x00ff0303
.equ  CLEAR_C,	0x0000ffff
.equ  OUT_C,	0x00005500
.equ  PUPVAL,	0x000000aa
.equ  PUPCLR,	0x000000ff

//==========================================================
// initb:
// Enable Port B in the RCC AHBENR register and configure
// the pins as described in section 2.1 of the lab
// No parameters.
// No expected return value.
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
	ldr r3, =CLEAR_ALL
	bics r1, r3
	ldr r2, =OUT_ALL
	orrs r1, r2
	str r1, [r0, #MODER]

    // End of student code
    pop     {pc}

//==========================================================
// initc:
// Enable Port C in the RCC AHBENR register and configure
// the pins as described in section 2.2 of the lab
// No parameters.
// No expected return value.
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
// setn:
// Set given pin in GPIOB to given value in ODR
// Param 1 - pin number
// param 2 - value [zero or non-zero]
// No expected retern value.
.global setn
setn:
    push    {r4-r7, lr}
    // Student code goes here
	ldr r2, =GPIOB
	ldr r3, [r2, #ODR]
	cmp r1, #0
	beq zero

	movs r1, #1
	lsls r1, r0
	bics r3, r1
	orrs r3, r1
	str r3, [r2, #ODR]
    pop     {r4-r7, pc}

zero:
	movs r1, #1
	lsls r1, r0
	bics r3, r1
	str r3, [r2, #ODR]

    // End of student code
    pop     {r4-r7, pc}

//==========================================================
// readpin:
// read the pin given in param 1 from GPIOB_IDR
// Param 1 - pin to read
// No expected return value.
.global readpin
readpin:
    push    {r4-r7, lr}
    // Student code goes here
	ldr r2, =GPIOB
	ldr r3, [r2, #IDR]
	lsrs r3, r0
	movs r1, #1
	ands r3, r1
	ldr r1, =0xfffffffe
	bics r3, r1
	movs r0, r3

    // End of student code
    pop     {r4-r7, pc}
//==========================================================
// buttons:
// Check the pushbuttons and turn a light on or off as 
// described in section 2.6 of the lab
// No parameters.
// No return value
.global buttons
buttons:
    push    {lr}
    // Student code goes here
	movs r0, #0
	bl readpin
	movs r2, #8
	movs r3, r0
	movs r1, r3
	movs r0, r2
	bl setn

	movs r0, #4
	bl readpin
	movs r2, #9
	movs r3, r0
	movs r1, r3
	movs r0, r2
	bl setn

    // End of student code
    pop     {pc}

//==========================================================
// keypad:
// Cycle through columns and check rows of keypad to turn
// LEDs on or off as described in section 2.7 of the lab
// No parameters.
// No expected return value.
.global keypad
keypad:
    push    {r4-r7, lr}
    // Student code goes here
    movs r7, #8
forloopcond1:
	cmp r7, #0
	ble fordone1
forloop1:
	ldr r3, =GPIOC
	ldr r2, [r3, #ODR]
	movs r1, #4
	movs r6, r7
	lsls r6, r1
	str r6, [r3, #ODR]

	bl mysleep
	movs r5, #0xf
	ldr r2, [r3, #IDR]
	ands r5, r2 // r value

	cmp r7, #8
	bne if1
	movs r0, #8
	movs r1, #1
	ands r1, r5
	bl setn
	b forinc1
if1:
	cmp r7, #4
	bne if2
	movs r0, #9
	movs r1, #2
	ands r1, r5
	bl setn
	b forinc1
if2:
	cmp r7, #2
	bne else
	movs r0, #10
	movs r1, #4
	ands r1, r5
	bl setn
	b forinc1
else:
	movs r0, #11
	movs r1, #8
	ands r1, r5
	bl setn
	b forinc1
forinc1:
	lsrs r7, #1
	b forloopcond1
fordone1:
    pop     {r4-r7, pc}

//==========================================================
// mysleep:
// a do nothing loop so that row lines can be charged
// as described in section 2.7 of the lab
// No parameters.
// No expected return value.
.global mysleep
mysleep:
    push    {lr}
    // Student code goes here
	movs r1, #0
forcond2:
	cmp r1, #255
	bge fordone2
forinc2:
	adds r1, #1
fordone2:
    // End of student code
    pop     {pc}

//==========================================================
// The main subroutine calls everything else.
// It never returns.
.global main
main:
    push {lr}
    bl   autotest // Uncomment when most things are working
    bl   initb
    bl   initc
// uncomment one of the loops, below, when ready
//loop1:
//    bl   buttons
//    b    loop1
//loop2:
//    bl   keypad
//    b    loop2

    wfi
    pop {pc}

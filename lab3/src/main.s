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
.equ  OUT_8_11, 0x00550000
.equ  OUT_4_7,	0x00005500

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
	ldr r2, =OUT_8_11
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
	ldr r2, =OUT_4_7
	orrs r1, r2
	str r1, [r0, #MODER]

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
    push    {lr}
    // Student code goes here
	ldr r2, =GPIOB
	ldr r3, [r2, #ODR] //r3 is the whole bit structure
	cmp r1, #0
	beq zero

	movs r1, #1
	lsls r1, r0, #16
	orrs r3, r1
	str r3, [r2, #ODR]

zero:
	movs r1, #1
	lsls r1, r0,

    // End of student code
    pop     {pc}

//==========================================================
// readpin:
// read the pin given in param 1 from GPIOB_IDR
// Param 1 - pin to read
// No expected return value.
.global readpin
readpin:
    push    {lr}
    // Student code goes here
	//use tsts and if zero flag is set then branch
    // End of student code
    pop     {pc}

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
    push    {lr}
    // Student code goes here

    // End of student code
    pop     {pc}

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

    // End of student code
    pop     {pc}

//==========================================================
// The main subroutine calls everything else.
// It never returns.
.global main
main:
    push {lr}
    //bl   autotest // Uncomment when most things are working
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

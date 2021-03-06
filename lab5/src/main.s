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

// OTHER STUFF
.equ CLEAR_B,	0x003fffff
.equ SET_B,		0x00155555
.equ CLEAR_C,	0x0003ffff
.equ SET_C,		0x00015500
.equ PUP_CLEAR,	0x000000ff
.equ PUP_SET,	0x000000aa

//============================================================================
// enable_ports() {
// Set up the ports and pins exactly as directed.
// }
.global enable_ports
enable_ports:
	push {r4, lr}
	ldr r0, =RCC
	ldr r1, [r0, #AHBENR]
	ldr r2, =GPIOBEN
	orrs r1, r2
	ldr r3, =GPIOCEN
	orrs r1, r3
	str r1, [r0, #AHBENR]

	ldr r0, =GPIOB
	ldr r1, [r0, #MODER]
	ldr r3, =CLEAR_B
	bics r1, r3
	ldr r2, =SET_B
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r0, =GPIOC
	ldr r1, [r0, #MODER]
	ldr r3, =CLEAR_C
	bics r1, r3
	ldr r2, =SET_C
	orrs r1, r2
	str r1, [r0, #MODER]

	ldr r0, =GPIOC
	ldr r1, [r0, #PUPDR]
	ldr r3, =PUP_CLEAR
	bics r1, r3
	ldr r2, =PUP_SET
	orrs r1, r2
	str r1, [r0, #PUPDR]

	ldr r4, =(1<<1)
	pop {r4, pc}


//============================================================================
// TIM6_ISR() {
//   TIM6->SR &= ~TIM_SR_UIF
//   if (GPIOC->ODR & (1<<8))
//     GPIOC->BRR = 1<<8;
//   else
//     GPIOC->BSRR = 1<<8;
// }

//============================================================================
 .global TIM6_DAC_IRQHandler
 .type TIM6_DAC_IRQHandler, %function
 TIM6_DAC_IRQHandler:
	push {lr}

	ldr r0, =TIM6
	ldr r1, [r0, #TIM_SR]
	ldr r3, =TIM_SR_UIF
	bics r1, r3
	str r1, [r0, #TIM_SR]

	ldr r0, =GPIOC
	ldr r1, [r0, #ODR]
	movs r2, #1
	lsls r2, r2, #8
	ands r1, r2
	cmp r1, #0

	beq elsetim
	str r2, [r0, #BRR]
	pop {pc}

elsetim:
	str r2, [r0, #BSRR]

	pop {pc}

// Implement the setup_tim6 subroutine below.  Follow the instructions in the
// lab text.

.global setup_tim6
setup_tim6:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =TIM6EN
	orrs r1, r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM6
	ldr r1, =48000-1
	str r1, [r0, #TIM_PSC]
	ldr r1, =500-1
	str r1, [r0, #TIM_ARR]

	ldr r1, [r0, #TIM_DIER]
	ldr r3, =TIM_DIER_UIE
	orrs r1, r3
	str r1, [r0, #TIM_DIER]

	ldr r1, [r0, #TIM_CR1]
	ldr r2, =TIM_CR1_CEN
	orrs r1, r2
	str r1, [r0, #TIM_CR1]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =TIM6_DAC_IRQn
	movs r3, #1
	lsls r3, r2
	str r3, [r0, r1]

	pop {pc}



//============================================================================
// void show_char(int col, char ch) {
//   GPIOB->ODR = ((col & 7) << 8) | font[ch];
// }
.global show_char
show_char:

	push {lr}

	movs r3, r0
	movs r2, #7
	ands r3, r2 // n = n & 7
	lsls r3, r3, #8
	ldr r0, =font
	ldrb r2, [r0, r1]
	orrs r3, r2
	ldr r0, =GPIOB
	str r3, [r0, #ODR]

	pop {pc}


//============================================================================
// nano_wait(int x)
// Wait the number of nanoseconds specified by x.
.global nano_wait
nano_wait:
	subs r0,#83
	bgt nano_wait
	bx lr

//============================================================================
// This function is provided for you to fill the LED matrix with AbCdEFg.
// It is a very useful function.  Study it carefully.
.global fill_alpha
fill_alpha:
	push {r4,r5,lr}
	movs r4,#0
fillloop:
	movs r5,#'A' // load the character 'A' (integer value 65)
	adds r5,r4
	movs r0,r4
	movs r1,r5
	bl   show_char
	adds r4,#1
	movs r0,#7
	ands r4,r0
	ldr  r0,=1000000
	bl   nano_wait
	b    fillloop
	pop {r4,r5,pc} // not actually reached

//============================================================================
// void drive_column(int c) {
//   c = c & 3;
//   GPIOC->BSRR = 0xf00000 | (1 << (c + 4));
// }
.global drive_column
drive_column:
	push {lr}
		movs r2, #3
		ands r2, r0 // c = c & 3
		adds r2, #4
		movs r3, #1
		lsls r3, r2
		ldr r1, =0xf00000
		orrs r3, r1

		ldr r0, =GPIOC
		str r3, [r0, #BSRR]

	pop {pc}

//============================================================================
// int read_rows(void) {
//   return GPIOC->IDR & 0xf;
// }
.global read_rows
read_rows:
	push {lr}
		ldr r1, =GPIOC
		ldr r2, [r1, #IDR]
		movs r3, #0xf
		ands r3, r2
		movs r0, r3
	pop {pc}

//============================================================================
// char rows_to_key(int rows) {
//   int n = (col & 0x3) * 4; // or int n = (col << 30) >> 28;
//   do {
//     if (rows & 1)
//       break;
//     n ++;
//     rows = rows >> 1;
//   } while(rows != 0);
//   char c = keymap[n];
//   return c;
// }
.global rows_to_key
rows_to_key:
	push {r4-r7, lr}
	movs r7, r0 //r7 is the rows variable
	movs r2, #0x3
	ldr r3, =col
	ldrb r4, [r3] // r4 is col variable
	movs r5, #4
	ands r2, r4 // col & 0x3
	muls r2, r5 // * 4
	movs r6, r2 // R6 is our INT N

do:
	movs r2, #1
	ands r2, r7 // rows & 1
	cmp r2, #0
	beq elsedo
	b donewithdo

elsedo:
	adds r6, #1 // n++
	movs r2, #1
	lsrs r7, r2 // rows = rows >> 1

while:
	cmp r7, #0
	bne do

donewithdo:
	//r6 is still n
	ldr r1, =keymap
	ldrb r2, [r1, r6]
	movs r0, r2

	pop {r4-r7, pc}


//============================================================================
// TIM7_ISR() {
//    TIM7->SR &= ~TIM_SR_UIF
//    int rows = read_rows();
//    if (rows != 0) {
//        char key = rows_to_key(rows);
//        handle_key(key);
//    }
//    char ch = disp[col];
//    show_char(col, ch);
//    col = (col + 1) & 7;
//    drive_column(col);
// }
 .global TIM7_IRQHandler
 .type TIM7_IRQHandler, %function
 TIM7_IRQHandler:
 	push {r4-r7, lr}
 	ldr r0, =TIM7
	ldr r1, [r0, #TIM_SR]
	ldr r3, =TIM_SR_UIF
	bics r1, r3
	str r1, [r0, #TIM_SR]

 	bl read_rows
 	cmp r0, #0
 	beq skipif
 	bl rows_to_key
 	bl handle_key

 skipif:
 	ldr r0, =col
 	ldrb r3, [r0]
 	movs r0, r3
 	ldr r6, =disp
 	ldrb r0, [r6, r3]
 	movs r1, r0
 	movs r0, r3
 	movs r7, r3
 	bl show_char
 	movs r4, #1
 	adds r4, r7
 	movs r5, #7
 	ands r4, r5
 	ldr r0, =col
 	strb r4, [r0]
 	movs r0, r4
 	bl drive_column

 	pop {r4-r7, pc}

//============================================================================
// Implement the setup_tim7 subroutine below.  Follow the instructions
// in the lab text.
.global setup_tim7
setup_tim7:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =TIM7EN
	orrs r1, r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM6
	ldr r1, =48000-1
	str r1, [r0, #TIM_PSC]
	ldr r1, =4800-1
	str r1, [r0, #TIM_ARR]

	ldr r1, [r0, #TIM_DIER]
	ldr r3, =TIM_DIER_UIE
	orrs r1, r3
	str r1, [r0, #TIM_DIER]

	ldr r1, [r0, #TIM_CR2]
	ldr r2, =TIM_CR1_CEN
	orrs r1, r2
	str r1, [r0, #TIM_CR2]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =TIM7_IRQn
	movs r3, #1
	lsls r3, r2
	str r3, [r0, r1]

	pop {pc}

//============================================================================
// void handle_key(char key)
// {
//     if (key == 'A' || key == 'B' || key == 'D')
//         mode = key;
//     else if (key &gt;= '0' && key &lt;= '9')
//         thrust = key - '0';
// }
.global handle_key
handle_key:
	push {lr}
		cmp r0, #65
		beq firstoption
		cmp r0, #66
		beq firstoption
		cmp r0, #68
		beq firstoption
		b secondoption

secondoption:
	cmp r0, #48
	blt finaldone
	cmp r0, #57
	bgt finaldone
	ldr r1, =thrust
	subs r0, #48
	strb r0, [r1]
	pop {pc}

firstoption:
	ldr r1, =mode
	strb r0, [r1]
	pop {pc}

finaldone:
	pop {pc}


//============================================================================
// void write_display(void)
// {
//     if (mode == 'C')
//         snprintf(disp, 9, "Crashed");
//     else if (mode == 'L')
//         snprintf(disp, 9, "Landed "); // Note the extra space!
//     else if (mode == 'A')
//         snprintf(disp, 9, "ALt%5d", alt);
//     else if (mode == 'B')
//         snprintf(disp, 9, "FUEL %3d", fuel);
//     else if (mode == 'D')
//         snprintf(disp, 9, "Spd %4d", velo);
// }
.global write_display
write_display:
	push {r4-r5, lr}
	ldr r0, =mode
	ldrb r1, [r0]

	cmp r1, #'C'
	beq case1
	cmp r1, #'L'
	beq case2
	cmp r1, #'A'
	beq case3
	cmp r1, #'B'
	beq case4
	cmp r1, #'D'
	beq case5

case1:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =crashed
	bl snprintf
	pop {r4-r5, pc}

case2:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =landed
	bl snprintf
	pop {r4-r5, pc}

case3:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =altitude
	ldr r4, =alt
	ldrh r3, [r4]
	bl snprintf
	pop {r4-r5, pc}

case4:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =fueling
	ldr r4, =fuel
	ldrh r3, [r4]
	bl snprintf
	pop {r4-r5, pc}

case5:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =spd
	ldr r4, =velo
	ldrh r3, [r4]
	bl snprintf
	pop {r4-r5, pc}


//============================================================================
// void update_variables(void)
// {
//     fuel -= thrust;
//     if (fuel &lt;= 0) {
//         thrust = 0;
//         fuel = 0;
//     }
//
//     alt += velo;
//     if (alt &lt;= 0) { // we've reached the surface
//         if (-velo &lt; 10)
//             mode = 'L'; // soft landing
//         else
//             mode = 'C'; // crash landing
//         return;
//     }
//
//     velo += thrust - 5;
// }
.global update_variables
update_variables:
	push {r4-r7, lr}
		ldr r0, =fuel
		movs r7, #0
		ldrsh r1, [r0, r7] //r1 is fuel
		ldr r0, =thrust
		ldrb r2, [r0] // r2 is thrust
		subs r1, r2
		ldr r0, =fuel
		strh r1, [r0]

		cmp r1, #0
		bgt afterif
		movs r1, #0
		movs r2, #0
		ldr r0, =fuel
		strh r1, [r0]
		ldr r0, =thrust
		strb r2, [r0]

afterif:
	ldr r0, =alt
	movs r7, #0
	ldrsh r3, [r0, r7] // r3 is altitude
	ldr r0, =velo
	ldrsh r4, [r0, r7] // r4 is velocity

	adds r3, r4
	ldr r0, =alt
	strh r3, [r0]
	cmp r3, #0
	bgt endofstuff
	movs r5, r4 // neg velocity
	movs r6, #0
	subs r6, r5 // real neg velocity
	cmp r6, #10
	bge checkforc
	//made it through so it is L
	ldr r0, =mode
	movs r5, #'L'
	strb r5, [r0]
	pop {r4-r7, pc}

checkforc:
	ldr r0, =mode
	movs r5, #'C'
	strb r5, [r0]
	pop {r4-r7, pc}

endofstuff:
	adds r4, r2
	subs r4, #5
	ldr r0, =velo
	strh r4, [r0]

	pop {r4-r7, pc}

//============================================================================
// TIM14_ISR() {
//    // acknowledge the interrupt
//    update_variables();
//    write_display();
// }
 .global TIM14_IRQHandler
 .type TIM14_IRQHandler, %function
 TIM14_IRQHandler:
	push {lr}
	ldr r0, =TIM14
	ldr r1, [r0, #TIM_SR]
	ldr r3, =TIM_SR_UIF
	bics r1, r3
	str r1, [r0, #TIM_SR]
	bl update_variables
	bl write_display

	pop {pc}


.global setup_tim14
setup_tim14:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =TIM14EN
	orrs r1, r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM14
	ldr r1, =48000-1
	str r1, [r0, #TIM_PSC]
	ldr r1, =500-1
	str r1, [r0, #TIM_ARR]

	ldr r1, [r0, #TIM_DIER]
	ldr r3, =TIM_DIER_UIE
	orrs r1, r3
	str r1, [r0, #TIM_DIER]

	ldr r1, [r0, #TIM_CR1]
	ldr r2, =TIM_CR1_CEN
	orrs r1, r2
	str r1, [r0, #TIM_CR1]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =TIM14_IRQn
	movs r3, #1
	lsls r3, r2
	str r3, [r0, r1]

	pop {pc}

//============================================================================
// Implement setup_tim14 as directed.


.global login
login: .string "will2253" // Replace with your login.
.balign 2

.global main
main:
	//bl check_wiring
	//bl fill_alpha
	bl autotest
	//bl enable_ports
	//bl setup_tim6
	//bl setup_tim7
	//bl setup_tim14
snooze:
	wfi
	b  snooze
	// Does not return.

//============================================================================
// Map the key numbers in the history array to characters.
// We just use a string for this.
.global keymap
keymap:
.string "DCBA#9630852*741"

//============================================================================
// This table is a *font*.  It provides a mapping between ASCII character
// numbers and the LED segments to illuminate for those characters.
// For instance, the character '2' has an ASCII value 50.  Element 50
// of the font array should be the 8-bit pattern to illuminate segments
// A, B, D, E, and G.  Spread out, those patterns would correspond to:
//   .GFEDCBA
//   01011011 = 0x5b
// Accessing the element 50 of the font table will retrieve the value 0x5b.
//
.global font
font:
.space 32
.byte  0x00 // 32: space
.byte  0x86 // 33: exclamation
.byte  0x22 // 34: double quote
.byte  0x76 // 35: octothorpe
.byte  0x00 // dollar
.byte  0x00 // percent
.byte  0x00 // ampersand
.byte  0x20 // 39: single quote
.byte  0x39 // 40: open paren
.byte  0x0f // 41: close paren
.byte  0x49 // 42: asterisk
.byte  0x00 // plus
.byte  0x10 // 44: comma
.byte  0x40 // 45: minus
.byte  0x80 // 46: period
.byte  0x00 // slash
.byte  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
.byte  0x7f, 0x67
.space 7
// Uppercase alphabet
.byte  0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x6f, 0x76, 0x30, 0x1e, 0x00, 0x38, 0x00
.byte  0x37, 0x3f, 0x73, 0x7b, 0x31, 0x6d, 0x78, 0x3e, 0x00, 0x00, 0x00, 0x6e, 0x00
.byte  0x39 // 91: open square bracket
.byte  0x00 // backslash
.byte  0x0f // 93: close square bracket
.byte  0x00 // circumflex
.byte  0x08 // 95: underscore
.byte  0x20 // 96: backquote
// Lowercase alphabet
.byte  0x5f, 0x7c, 0x58, 0x5e, 0x79, 0x71, 0x6f, 0x74, 0x10, 0x0e, 0x00, 0x30, 0x00
.byte  0x54, 0x5c, 0x73, 0x7b, 0x50, 0x6d, 0x78, 0x1c, 0x00, 0x00, 0x00, 0x6e, 0x00
.balign 2

//============================================================================
// Data structures for this experiment.
//
.data
.global col
.global disp
.global mode
.global thrust
.global fuel
.global alt
.global velo
disp: .string "Hello..."
col: .byte 0
mode: .byte 'A'
thrust: .byte 0
.balign 4
.hword 0 // put this here to make sure next hword is not word-aligned
fuel: .hword 800
.hword 0 // put this here to make sure next hword is not word-aligned
alt: .hword 4500
.hword 0 // put this here to make sure next hword is not word-aligned
velo: .hword 0

.global crashed
crashed: .string "Crashed"

.global landed
landed: .string "Landed "

.global altitude
altitude: .string "ALt%5d"

.global fueling
fueling: .string "FUEL %3d"

.global spd
spd: .string "Spd %4d"

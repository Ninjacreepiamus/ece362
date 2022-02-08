.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.data
.balign 4
.global arr
arr: .word 14, 15, 18, 12, 7, 11, 16, 24, 22, 15, 23, 21, 13, 15, 24, 17

.balign 4
.global value
value: .word 0

.global str
str: .string "HeLlO, 98765 WoRlD! 43210 InTeReStInG!"

.text
.global login
login: .string "will2253" // Make sure you put your login here.
.balign 2

.global main
main:
    //bl autotest
    bl intsub
    bl charsub
    // Put any instructions you want here

.global intsub
intsub:
    movs r1, #0 // Sets counter register to initial value 0
    b forloopcond1 // Moves to condition

forloopcond1:
   cmp r1, #15
   bge forloopafter1

loop1:
    movs r2, #1     // Moves 1 so that it can be anded with counter
    ands r2, r1     // Ands 1 with counter
    cmp r2, #1      // Compares value of (i & 1) and 1
    bne else1

    // IF BLOCK
    ldr r0, =arr    //Load address of array to r0
    movs r3, #4
    muls r3, r1
    ldr r2, [r0, r3]    // Loads arr[i]
    adds r3, #4
    ldr r0, [r0, r3] // Loads arr[i + 1]
    muls r2, r0
    ldr r0, =value
    str r2, [r0] // Stores arr[i + 1] * arr[i] to value

    b forafter1

else1:
    ldr r0, =arr
    movs r3, #4
    muls r3, r1
    ldr r0, [r0, r3]
    movs r3, #3
    muls r3, r0
    ldr r0, =value
    ldr r0, [r0]
    adds r3, r0
    ldr r0, =value
    str r3, [r0]

    b forafter1

forafter1:
    ldr r0, =arr    //Load address of array to r0
    movs r3, #4
    muls r3, r1
    ldr r2, [r0, r3]    // Loads arr[i]
    adds r3, #4
    ldr r0, [r0, r3] // Loads arr[i + 1]
    adds r2, r0 // Desired value stored in r2
    ldr r0, =arr
    subs r3, #4
    str r2, [r0, r3] // Stores desired value in r2

forloopinc1:
    adds r1, #1
    b forloopcond1

forloopafter1:
    bx lr

.global charsub
charsub:
    movs r1, #0 // Sets counter register to initial value 0
    movs r0, #0
    movs r2, #0
    movs r3, #0
    b forloopcond2 // Moves to condition

forloopcond2:
   ldr r0, =str
   ldrb r0, [r0, r1]
   cmp r0, #0
   beq fordone2

loop2:
    movs r2, #0x20   //Register with temp value
    ldr r0, =str
    ldrb r3, [r0, r1]

    bics r3, r2       // Register with ~0x20  r2 = r2 & ~r0 // r2 = 0x20 & ~ arr[x]
    cmp r3, #0x41
    blt forloopinc2

    cmp r3, #0x5a
    bgt forloopinc2

    // IF BLOCK
    ldr r0, =str    //Load address of array to r0
    ldrb r3, [r0, r1]
    eors r3, r2
    strb r3, [r0, r1]

forloopinc2:
    adds r1, #1
    b forloopcond2

fordone2:
    bx lr

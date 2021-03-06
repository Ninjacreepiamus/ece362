.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.text

.global login
login: .string "will2253"
hello_str: .string "Hello, %s!\n"
.balign  2


.global hello
hello:
	push {lr}
	ldr r0, =hello_str
	ldr r1, =login
	bl printf
	pop  {pc}

.global showsub2
showsub2:
	push {lr}
	//r0 is string
	//r1 is a
	//r2 is b
	//r3 is a - b
	movs r3, r1
	movs r1, r0
	movs r2, r3
	ldr r0, =showsub2_str
	subs r3, r1, r2
	bl printf
	pop  {pc}

showsub2_str: .string "%d - %d = %d\n"
.balign  2

.global showsub3
showsub3:
	push {r4, r5, r6, r7, lr}
	movs r4, r0
	movs r5, r1
	movs r6, r2
	movs r1, r4
	movs r2, r5
	movs r3, r6
	ldr r0, =showsub3_str
	movs r4, #0
	subs r4, r1, r2
	subs r4, r3, r4
	push {r4, r5, r6, r7}
	bl printf
	pop {r4, r5, r6, r7}
	pop {r4, r5, r6, r7, pc}


showsub3_str: .string "%d - %d - %d = %d\n"
.balign  2

.global listing
listing:
	push {r4-r7, lr}
	ldr r5, [sp, #20]
	ldr r6, [sp, #24]

	//movs r7, r6
	//movs r6, r5
	movs r4, r3
	movs r3, r2
	movs r2, r1
	movs r1, r0
	ldr r0, =listing_str
	str r4, [sp, #0]
	str r5, [sp, #4]
	str r6, [sp, #8]

	bl printf
	pop {r4-r7, pc}

listing_str: .string "%s %05d %s %d students in %s, %d\n"
.balign  2

.global trivial
trivial:
	push {r4-r7, lr}
	movs r1, r0
	sub sp, #400
forloop5:
	movs r7, #0
forloopcond5:
	ldr r0, [sp, #20]
	//size of temp is 100
	movs r6, #100
	cmp r7, #100
	bge ifblock5

forloopblock5:
	//FOR LOOP BLOCK
	movs r5, #20
	movs r6, #4
	muls r6, r7
	adds r5, r6
	movs r4, #1
	adds r4, r7
	//str r6, [sp, r5]

ifblock5:
	cmp r1, #100
	blt returnstuff
	movs r2, #99
doifstuff:


returnstuff:
	
pop {r4-r7, pc}

.global depth
depth:
	push {r4-r7, lr}
	movs r3, r0 // r3 stores x
	movs r5, r1 // r5 stores original s
	movs r0, r5 // stores s in r0 for parameter
	push {r4-r7}
	bl strlen // computes strlen with value s in r0
	pop {r4-r7}
	movs r6, r0 // this stores strlen length to r6

	cmp r3, #0 // if x == 0 then branch to start pooping
	beq depthdone

	movs r0, r5 // Prepare the r0 for the s parameter
	push {r4-r7}
	bl puts
	pop {r4-r7}
	movs r5, r0 // Updates s value in r5 register from puts
	subs r0, r3, #1 // Subtracts 1 from x and puts it into first param
	movs r1, r5
	push {r4-r7}
	bl depth // recursive call
	pop {r4-r7}
	adds r0, r6 // Adds len and depth recursive call value

	pop {r4-r7, pc}

depthdone:
	movs r0, r6
	pop {r4-r7, pc}

.global collatz
collatz:
	push {r4-r7, lr}
	movs r4, r0 // r4 is our n value

	//IF N == 1
	cmp r4, #1
	beq weredone

	movs r5, #1
	ands r5, r4

	//IF N & 1 == 0
	cmp r5, #0
	bne afterif
	
	// Ready to go inside the IF
	movs r2, r4 // moves current n value to division register
	lsls r0, r2, #1 // stores divided value in parameter register
	
	//Calls collatz recursively
	push {r4-r7}
	bl collatz
	pop {r4-r7}

	adds r0, #1
	pop {r4-r7, pc}

weredone:
	movs r0, #0
	pop {r4-r7, pc}

afterif:
	movs r6, #1
	movs r5, #3
	muls r5, r4
	adds r6, r5
	movs r0, r6
	
	push {r4-r7}
	bl collatz
	pop {r4-r7}
	adds r0, #1

	pop {r4-r7, pc}


.global permute
permute:
	push {lr}

	pop {pc}

.global bizarre
bizarre:
	push {lr}

	pop {pc}

.global easy
easy:
	push {lr}

	pop {pc}


// Add the rest of your subroutines below

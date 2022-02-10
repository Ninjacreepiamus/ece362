.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.text

.global login
login: .string "xyz"
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

showsub2_str: .string "%d * %d = %d\n"
.balign  2

.global showsub3
showsub3:
	push {lr}

	pop {pc}

.global listing
listing:
	push {lr}

	pop {pc}

.global trivial
trivial:
	push {lr}

	pop {pc}

.global depth
depth:
	push {lr}

	pop {pc}

.global collatz
collatz:
	push {lr}

	pop {pc}

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

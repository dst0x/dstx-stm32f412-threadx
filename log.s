	.cpu cortex-m4
	.arch armv7e-m
	.fpu fpv4-sp-d16
	.eabi_attribute 27, 1
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"log.c"
	.text
	.bss
	.align	2
_log_process:
	.space	4
	.size	_log_process, 4
	.align	2
_rtc_get:
	.space	4
	.size	_rtc_get, 4
	.text
	.align	1
	.global	Log_Init
	.syntax unified
	.thumb
	.thumb_func
	.type	Log_Init, %function
Log_Init:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	ldr	r2, .L3
	ldr	r3, [r7, #4]
	str	r3, [r2]
	ldr	r2, .L3+4
	ldr	r3, [r7]
	str	r3, [r2]
	nop
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
.L4:
	.align	2
.L3:
	.word	_log_process
	.word	_rtc_get
	.size	Log_Init, .-Log_Init
	.section	.rodata
	.align	2
.LC0:
	.ascii	"[%d/%m/%Y %H:%M:%S]\000"
	.align	2
.LC1:
	.ascii	"INFO \000"
	.align	2
.LC2:
	.ascii	"WARN \000"
	.align	2
.LC3:
	.ascii	"ERROR\000"
	.align	2
.LC4:
	.ascii	"%s %s: %s().%d: \000"
	.text
	.align	1
	.global	Log_Put
	.syntax unified
	.thumb
	.thumb_func
	.type	Log_Put, %function
Log_Put:
	@ args = 4, pretend = 4, frame = 120
	@ frame_needed = 1, uses_anonymous_args = 1
	push	{r3}
	push	{r7, lr}
	sub	sp, sp, #140
	add	r7, sp, #16
	str	r0, [r7, #12]
	mov	r3, r1
	str	r2, [r7, #4]
	strb	r3, [r7, #11]
	mov	r2, #0
	mov	r3, #0
	strd	r2, [r7, #24]
	ldr	r3, .L21
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L6
	ldr	r3, .L21
	ldr	r3, [r3]
	blx	r3
	mov	r2, r0
	mov	r3, r1
	strd	r2, [r7, #24]
.L6:
	add	r2, r7, #68
	add	r3, r7, #24
	mov	r1, r2
	mov	r0, r3
	bl	localtime_r
	add	r3, r7, #68
	add	r0, r7, #36
	ldr	r2, .L21+4
	movs	r1, #32
	bl	strftime
	ldrb	r3, [r7, #11]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L7
	cmp	r3, #1
	beq	.L8
	b	.L18
.L7:
	ldr	r3, .L21+8
	str	r3, [r7, #116]
	b	.L10
.L8:
	ldr	r3, .L21+12
	str	r3, [r7, #116]
	b	.L10
.L18:
	ldr	r3, .L21+16
	str	r3, [r7, #116]
	nop
.L10:
	add	r2, r7, #36
	ldr	r3, [r7, #4]
	str	r3, [sp, #8]
	ldr	r3, [r7, #12]
	str	r3, [sp, #4]
	ldr	r3, [r7, #116]
	str	r3, [sp]
	mov	r3, r2
	ldr	r2, .L21+20
	mov	r1, #512
	ldr	r0, .L21+24
	bl	snprintf
	str	r0, [r7, #108]
	ldr	r3, [r7, #108]
	cmp	r3, #0
	blt	.L19
	ldr	r3, [r7, #108]
	cmp	r3, #512
	bge	.L19
	add	r3, r7, #136
	str	r3, [r7, #20]
	ldr	r3, [r7, #108]
	ldr	r2, .L21+24
	adds	r0, r3, r2
	ldr	r3, [r7, #108]
	rsb	r1, r3, #512
	ldr	r3, [r7, #20]
	ldr	r2, [r7, #132]
	bl	vsnprintf
	str	r0, [r7, #104]
	ldr	r3, [r7, #104]
	cmp	r3, #0
	blt	.L20
	ldr	r2, [r7, #108]
	ldr	r3, [r7, #104]
	add	r3, r3, r2
	str	r3, [r7, #112]
	ldr	r3, [r7, #112]
	cmp	r3, #510
	bge	.L15
	ldr	r2, .L21+24
	ldr	r3, [r7, #112]
	add	r3, r3, r2
	movs	r2, #13
	strb	r2, [r3]
	ldr	r3, [r7, #112]
	adds	r3, r3, #1
	ldr	r2, .L21+24
	movs	r1, #10
	strb	r1, [r2, r3]
	ldr	r3, [r7, #112]
	adds	r3, r3, #2
	str	r3, [r7, #112]
.L15:
	ldr	r3, .L21+28
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L5
	ldr	r3, .L21+28
	ldr	r3, [r3]
	ldr	r2, [r7, #112]
	uxth	r2, r2
	mov	r1, r2
	ldr	r0, .L21+24
	blx	r3
	b	.L5
.L19:
	nop
	b	.L5
.L20:
	nop
.L5:
	adds	r7, r7, #124
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	add	sp, sp, #4
	bx	lr
.L22:
	.align	2
.L21:
	.word	_rtc_get
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	buffer.0
	.word	_log_process
	.size	Log_Put, .-Log_Put
	.bss
	.align	2
buffer.0:
	.space	512
	.size	buffer.0, 512
	.ident	"GCC: (15:14.2.rel1-1) 14.2.1 20241119"

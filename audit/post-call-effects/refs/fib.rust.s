	.file	"fib.3cf3c199a7428b19-cgu.0"
	.section	.text._RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECs5erIdfibIGj_3fib,"ax",@progbits
	.hidden	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECs5erIdfibIGj_3fib
	.globl	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECs5erIdfibIGj_3fib
	.p2align	4
	.type	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECs5erIdfibIGj_3fib,@function
_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECs5erIdfibIGj_3fib:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	%ecx, %r8d
	movq	%rdx, %rcx
	movq	%rsi, %rdx
	movq	%rdi, (%rsp)
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.0(%rip), %rsi
	movq	%rsp, %rdi
	callq	*_RNvNtCs9k3SxhrAWiO_3std2rt19lang_start_internal@GOTPCREL(%rip)
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECs5erIdfibIGj_3fib, .Lfunc_end0-_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECs5erIdfibIGj_3fib,"ax",@progbits
	.p2align	4
	.type	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECs5erIdfibIGj_3fib,@function
_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECs5erIdfibIGj_3fib:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rdi, %r14
	movq	8(%rdi), %rbx
	movq	16(%rdi), %r15
	testq	%r15, %r15
	je	.LBB1_5
	leaq	8(%rbx), %r12
	movq	_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip), %r13
	jmp	.LBB1_2
	.p2align	4
.LBB1_4:
	addq	$24, %r12
	decq	%r15
	je	.LBB1_5
.LBB1_2:
	movq	-8(%r12), %rsi
	testq	%rsi, %rsi
	je	.LBB1_4
	movq	(%r12), %rdi
	movl	$1, %edx
	callq	*%r13
	jmp	.LBB1_4
.LBB1_5:
	movq	(%r14), %rax
	testq	%rax, %rax
	je	.LBB1_6
	shlq	$3, %rax
	leaq	(%rax,%rax,2), %rsi
	movl	$8, %edx
	movq	%rbx, %rdi
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmpq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB1_6:
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECs5erIdfibIGj_3fib, .Lfunc_end1-_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECs5erIdfibIGj_3fib,"ax",@progbits
	.p2align	4
	.type	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECs5erIdfibIGj_3fib,@function
_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECs5erIdfibIGj_3fib:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rdi, %rbx
	movq	8(%rdi), %r15
	movq	24(%rdi), %rcx
	movq	%rcx, %rax
	subq	%r15, %rax
	movabsq	$-6148914691236517205, %rdx
	mulq	%rdx
	cmpq	%r15, %rcx
	je	.LBB2_5
	movq	%rdx, %r14
	shrq	$4, %r14
	addq	$8, %r15
	movq	_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip), %r12
	jmp	.LBB2_2
	.p2align	4
.LBB2_4:
	addq	$24, %r15
	decq	%r14
	je	.LBB2_5
.LBB2_2:
	movq	-8(%r15), %rsi
	testq	%rsi, %rsi
	je	.LBB2_4
	movq	(%r15), %rdi
	movl	$1, %edx
	callq	*%r12
	jmp	.LBB2_4
.LBB2_5:
	movq	16(%rbx), %rax
	testq	%rax, %rax
	je	.LBB2_6
	movq	(%rbx), %rdi
	shlq	$3, %rax
	leaq	(%rax,%rax,2), %rsi
	movl	$8, %edx
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmpq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB2_6:
	.cfi_def_cfa_offset 48
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECs5erIdfibIGj_3fib, .Lfunc_end2-_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECs5erIdfibIGj_3fib,"ax",@progbits
	.p2align	4
	.type	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECs5erIdfibIGj_3fib,@function
_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECs5erIdfibIGj_3fib:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	callq	*%rdi
	#APP
	#NO_APP
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end3:
	.size	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECs5erIdfibIGj_3fib, .Lfunc_end3-_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECs5erIdfibIGj_3fib,"ax",@progbits
	.p2align	4
	.type	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECs5erIdfibIGj_3fib,@function
_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECs5erIdfibIGj_3fib:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$32, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rsi, %rbx
	movq	%rdi, %r14
	leaq	8(%rsp), %r15
	movq	_RNvXsc_NtCs9k3SxhrAWiO_3std3envNtB5_4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator4next@GOTPCREL(%rip), %r12
	movq	_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip), %r13
	jmp	.LBB4_1
	.p2align	4
.LBB4_4:
	decq	%rbx
	je	.LBB4_5
.LBB4_1:
	movq	%r15, %rdi
	movq	%r14, %rsi
	callq	*%r12
	movq	8(%rsp), %rsi
	testq	%rsi, %rsi
	je	.LBB4_4
	cmpq	$-1, %rsi
	je	.LBB4_6
	movq	16(%rsp), %rdi
	movl	$1, %edx
	callq	*%r13
	jmp	.LBB4_4
.LBB4_5:
	xorl	%ebx, %ebx
.LBB4_6:
	movq	%rbx, %rax
	addq	$32, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECs5erIdfibIGj_3fib, .Lfunc_end4-_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Cs5erIdfibIGj_3fib,"ax",@progbits
	.p2align	4
	.type	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Cs5erIdfibIGj_3fib,@function
_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Cs5erIdfibIGj_3fib:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	(%rdi), %rdi
	callq	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECs5erIdfibIGj_3fib
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end5:
	.size	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Cs5erIdfibIGj_3fib, .Lfunc_end5-_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Cs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCs5erIdfibIGj_3fib,"ax",@progbits
	.p2align	4
	.type	_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCs5erIdfibIGj_3fib,@function
_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCs5erIdfibIGj_3fib:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	(%rdi), %rdi
	callq	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECs5erIdfibIGj_3fib
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end6:
	.size	_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCs5erIdfibIGj_3fib, .Lfunc_end6-_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RNvCs5erIdfibIGj_3fib3fib,"ax",@progbits
	.p2align	4
	.type	_RNvCs5erIdfibIGj_3fib3fib,@function
_RNvCs5erIdfibIGj_3fib3fib:
	.cfi_startproc
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	pushq	%rax
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	xorl	%ebx, %ebx
	cmpq	$2, %rdi
	jl	.LBB7_2
	.p2align	4
.LBB7_1:
	movq	%rdi, %r14
	decq	%rdi
	callq	_RNvCs5erIdfibIGj_3fib3fib
	leaq	-2(%r14), %rdi
	addq	%rax, %rbx
	cmpq	$3, %r14
	ja	.LBB7_1
.LBB7_2:
	addq	%rdi, %rbx
	movq	%rbx, %rax
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end7:
	.size	_RNvCs5erIdfibIGj_3fib3fib, .Lfunc_end7-_RNvCs5erIdfibIGj_3fib3fib
	.cfi_endproc

	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	3, 0x0
.LCPI8_0:
	.quad	0x7fefffffffffffff
.LCPI8_3:
	.quad	0x41cdcd6500000000
.LCPI8_4:
	.quad	0x412e848000000000
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI8_1:
	.long	1127219200
	.long	1160773632
	.long	0
	.long	0
.LCPI8_2:
	.quad	0x4330000000000000
	.quad	0x4530000000000000
	.section	.text._RNvCs5erIdfibIGj_3fib4main,"ax",@progbits
	.hidden	_RNvCs5erIdfibIGj_3fib4main
	.globl	_RNvCs5erIdfibIGj_3fib4main
	.p2align	4
	.type	_RNvCs5erIdfibIGj_3fib4main,@function
_RNvCs5erIdfibIGj_3fib4main:
.Lfunc_begin0:
	.cfi_startproc
	.cfi_personality 155, DW.ref.rust_eh_personality
	.cfi_lsda 27, .Lexception0
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$152, %rsp
	.cfi_def_cfa_offset 208
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	$0, 40(%rsp)
	movq	$8, 48(%rsp)
	movq	$0, 56(%rsp)
.Ltmp0:
	leaq	8(%rsp), %rdi
	callq	*_RNvNtCs9k3SxhrAWiO_3std3env4args@GOTPCREL(%rip)
.Ltmp1:
	movupd	8(%rsp), %xmm0
	movupd	24(%rsp), %xmm1
	movapd	%xmm1, 80(%rsp)
	movapd	%xmm0, 64(%rsp)
	movq	$1, 96(%rsp)
	movl	$5, %ebx
	movl	$1, %esi
	movl	$10, %r13d
	testq	%rsi, %rsi
	je	.LBB8_4
.LBB8_47:
	movq	$0, 96(%rsp)
.Ltmp3:
	leaq	64(%rsp), %rdi
	callq	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECs5erIdfibIGj_3fib
.Ltmp4:
	testq	%rax, %rax
	je	.LBB8_4
	jmp	.LBB8_53
	.p2align	4
.LBB8_2:
	movq	48(%rsp), %rax
	leaq	(,%rbp,2), %rcx
	addq	%rbp, %rcx
	movq	%r14, (%rax,%rcx,8)
	movq	%r15, 8(%rax,%rcx,8)
	movq	%r12, 16(%rax,%rcx,8)
	incq	%rbp
	movq	%rbp, 56(%rsp)
.LBB8_3:
	movq	96(%rsp), %rsi
	testq	%rsi, %rsi
	jne	.LBB8_47
.LBB8_4:
.Ltmp5:
	leaq	128(%rsp), %rdi
	leaq	64(%rsp), %rsi
	callq	*_RNvXsc_NtCs9k3SxhrAWiO_3std3envNtB5_4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator4next@GOTPCREL(%rip)
.Ltmp6:
	movq	128(%rsp), %r14
	cmpq	$-1, %r14
	je	.LBB8_53
	movq	136(%rsp), %r15
	movq	144(%rsp), %r12
	cmpq	$6, %r12
	jne	.LBB8_8
	movl	(%r15), %eax
	movl	$1970416941, %ecx
	xorl	%ecx, %eax
	movzwl	4(%r15), %ecx
	xorl	$29550, %ecx
	orl	%eax, %ecx
	je	.LBB8_10
.LBB8_8:
	movq	56(%rsp), %rbp
	cmpq	40(%rsp), %rbp
	jne	.LBB8_2
.Ltmp8:
	leaq	40(%rsp), %rdi
	callq	*_RNvMs4_NtCs6i54tJFfzR_5alloc7raw_vecINtB5_6RawVecNtNtB7_6string6StringE8grow_oneCs9k3SxhrAWiO_3std@GOTPCREL(%rip)
.Ltmp9:
	jmp	.LBB8_2
	.p2align	4
.LBB8_10:
	movq	96(%rsp), %rsi
	testq	%rsi, %rsi
	jne	.LBB8_50
.LBB8_11:
.Ltmp13:
	leaq	8(%rsp), %rdi
	leaq	64(%rsp), %rsi
	callq	*_RNvXsc_NtCs9k3SxhrAWiO_3std3envNtB5_4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator4next@GOTPCREL(%rip)
.Ltmp14:
	movq	8(%rsp), %rbp
	cmpq	$-1, %rbp
	je	.LBB8_52
	movq	16(%rsp), %r12
	movq	24(%rsp), %rsi
	cmpq	$1, %rsi
	je	.LBB8_16
	testq	%rsi, %rsi
	je	.LBB8_120
	movzbl	(%r12), %ecx
	jmp	.LBB8_18
	.p2align	4
.LBB8_16:
	movzbl	(%r12), %ecx
	movl	$257, %eax
	cmpl	$43, %ecx
	je	.LBB8_83
	cmpl	$45, %ecx
	je	.LBB8_83
.LBB8_18:
	xorl	%eax, %eax
	cmpb	$43, %cl
	sete	%al
	movq	%rsi, %rdx
	subq	%rax, %rdx
	leaq	(%r12,%rax), %rcx
	cmpq	$9, %rdx
	jae	.LBB8_36
	testq	%rdx, %rdx
	je	.LBB8_41
	movzbl	(%rcx), %ebx
	addl	$-48, %ebx
	movl	$257, %eax
	cmpl	$9, %ebx
	ja	.LBB8_83
	cmpq	$1, %rdx
	je	.LBB8_42
	movzbl	1(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_83
	leal	(%rbx,%rbx,4), %edi
	leal	(%rsi,%rdi,2), %ebx
	cmpq	$2, %rdx
	je	.LBB8_42
	movzbl	2(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_83
	leal	(%rbx,%rbx,4), %edi
	leal	(%rsi,%rdi,2), %ebx
	cmpq	$3, %rdx
	je	.LBB8_42
	movzbl	3(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_83
	leal	(%rbx,%rbx,4), %edi
	leal	(%rsi,%rdi,2), %ebx
	cmpq	$4, %rdx
	je	.LBB8_42
	movzbl	4(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_83
	leal	(%rbx,%rbx,4), %edi
	leal	(%rsi,%rdi,2), %ebx
	cmpq	$5, %rdx
	je	.LBB8_42
	movzbl	5(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_83
	leal	(%rbx,%rbx,4), %edi
	leal	(%rsi,%rdi,2), %ebx
	cmpq	$6, %rdx
	je	.LBB8_42
	movzbl	6(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_83
	leal	(%rbx,%rbx,4), %edi
	leal	(%rsi,%rdi,2), %ebx
	cmpq	$7, %rdx
	je	.LBB8_42
	movzbl	7(%rcx), %ecx
	addl	$-48, %ecx
	cmpl	$9, %ecx
	ja	.LBB8_83
	leal	(%rbx,%rbx,4), %eax
	leal	(%rcx,%rax,2), %ebx
	shlq	$32, %rbx
	testb	$1, %bl
	je	.LBB8_43
	jmp	.LBB8_123
	.p2align	4
.LBB8_36:
	negq	%rax
	addq	%rax, %rsi
	negq	%rsi
	xorl	%ebx, %ebx
	xorl	%edi, %edi
	.p2align	4
.LBB8_37:
	movq	%rsi, %rax
	addq	%rdi, %rax
	je	.LBB8_42
	movl	%ebx, %eax
	mull	%r13d
	movzbl	(%rcx,%rdi), %ebx
	jo	.LBB8_49
	addl	$-48, %ebx
	cmpl	$10, %ebx
	jae	.LBB8_116
	incq	%rdi
	addl	%eax, %ebx
	jae	.LBB8_37
	jmp	.LBB8_82
	.p2align	4
.LBB8_41:
	xorl	%ebx, %ebx
	.p2align	4
.LBB8_42:
	shlq	$32, %rbx
	testb	$1, %bl
	jne	.LBB8_123
.LBB8_43:
	testq	%rbp, %rbp
	je	.LBB8_45
	movl	$1, %edx
	movq	%r12, %rdi
	movq	%rbp, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB8_45:
	shrq	$32, %rbx
	testq	%r14, %r14
	je	.LBB8_3
	movl	$1, %edx
	movq	%r15, %rdi
	movq	%r14, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
	movq	96(%rsp), %rsi
	testq	%rsi, %rsi
	je	.LBB8_4
	jmp	.LBB8_47
.LBB8_49:
	addb	$-48, %bl
	xorl	%eax, %eax
	cmpb	$10, %bl
	setb	%al
	shll	$8, %eax
	addq	$257, %rax
	movq	%rax, %rbx
	testb	$1, %bl
	je	.LBB8_43
	jmp	.LBB8_123
.LBB8_50:
	movq	$0, 96(%rsp)
.Ltmp11:
	leaq	64(%rsp), %rdi
	callq	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECs5erIdfibIGj_3fib
.Ltmp12:
	testq	%rax, %rax
	je	.LBB8_11
.LBB8_52:
.Ltmp19:
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.2(%rip), %rdi
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.4(%rip), %rdx
	movl	$20, %esi
	callq	*_RNvNtCsgxBkk5gSRhY_4core6option13expect_failed@GOTPCREL(%rip)
.Ltmp20:
	jmp	.LBB8_115
.LBB8_53:
	cmpq	$0, 56(%rsp)
	je	.LBB8_57
	movq	48(%rsp), %rcx
	movq	8(%rcx), %rax
	movq	16(%rcx), %rcx
	cmpq	$1, %rcx
	je	.LBB8_58
	testq	%rcx, %rcx
	je	.LBB8_122
	movzbl	(%rax), %esi
	jmp	.LBB8_60
.LBB8_57:
	movl	$22, %r15d
	jmp	.LBB8_85
.LBB8_58:
	movzbl	(%rax), %esi
	movb	$1, %dl
	cmpl	$43, %esi
	je	.LBB8_114
	cmpl	$45, %esi
	je	.LBB8_114
.LBB8_60:
	cmpb	$45, %sil
	je	.LBB8_72
	movzbl	%sil, %edx
	cmpl	$43, %edx
	jne	.LBB8_63
	incq	%rax
	decq	%rcx
.LBB8_63:
	xorl	%r15d, %r15d
	cmpq	$16, %rcx
	jae	.LBB8_68
	testq	%rcx, %rcx
	je	.LBB8_85
	xorl	%edx, %edx
	.p2align	4
.LBB8_66:
	movzbl	(%rax,%rdx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_119
	leaq	(%r15,%r15,4), %rdi
	movl	%esi, %esi
	leaq	(%rsi,%rdi,2), %r15
	incq	%rdx
	cmpq	%rdx, %rcx
	jne	.LBB8_66
	jmp	.LBB8_85
	.p2align	4
.LBB8_68:
	imulq	$10, %r15, %r15
	jo	.LBB8_109
	movzbl	(%rax), %edx
	addl	$-48, %edx
	cmpl	$9, %edx
	ja	.LBB8_119
	movl	%edx, %edx
	addq	%rdx, %r15
	jo	.LBB8_110
	incq	%rax
	decq	%rcx
	jne	.LBB8_68
	jmp	.LBB8_85
.LBB8_72:
	leaq	-1(%rcx), %rdx
	cmpq	$17, %rcx
	jae	.LBB8_77
	testq	%rdx, %rdx
	je	.LBB8_84
	movl	$1, %edx
	xorl	%r15d, %r15d
	.p2align	4
.LBB8_75:
	movzbl	(%rax,%rdx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB8_119
	addq	%r15, %r15
	leaq	(%r15,%r15,4), %r15
	movl	%esi, %esi
	subq	%rsi, %r15
	incq	%rdx
	cmpq	%rdx, %rcx
	jne	.LBB8_75
	jmp	.LBB8_85
.LBB8_77:
	incq	%rax
	xorl	%r15d, %r15d
	.p2align	4
.LBB8_78:
	imulq	$10, %r15, %r15
	jo	.LBB8_111
	movzbl	(%rax), %ecx
	addl	$-48, %ecx
	cmpl	$9, %ecx
	ja	.LBB8_119
	movl	%ecx, %ecx
	subq	%rcx, %r15
	jo	.LBB8_113
	incq	%rax
	decq	%rdx
	jne	.LBB8_78
	jmp	.LBB8_85
.LBB8_82:
	movl	$513, %eax
.LBB8_83:
	movb	%ah, 8(%rsp)
.Ltmp16:
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.5(%rip), %rdi
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.11(%rip), %rcx
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.6(%rip), %r8
	leaq	8(%rsp), %rdx
	movl	$25, %esi
	callq	*_RNvNtCsgxBkk5gSRhY_4core6result13unwrap_failed@GOTPCREL(%rip)
.Ltmp17:
	jmp	.LBB8_115
.LBB8_84:
	xorl	%r15d, %r15d
.LBB8_85:
	movq	%r15, 8(%rsp)
	leaq	8(%rsp), %rax
	#APP
	#NO_APP
	movq	8(%rsp), %rdi
	callq	_RNvCs5erIdfibIGj_3fib3fib
	movabsq	$9218868437227405311, %rax
	movq	%rax, 112(%rsp)
	movq	$0, 120(%rsp)
	testl	%ebx, %ebx
	je	.LBB8_92
	movsd	.LCPI8_0(%rip), %xmm0
	movsd	%xmm0, 104(%rsp)
	movq	_RNvMNtCs9k3SxhrAWiO_3std4timeNtB2_7Instant3now@GOTPCREL(%rip), %r12
	leaq	128(%rsp), %r13
	leaq	8(%rsp), %r14
	movq	_RNvMNtCs9k3SxhrAWiO_3std4timeNtB2_7Instant7elapsed@GOTPCREL(%rip), %rbp
	jmp	.LBB8_88
	.p2align	4
.LBB8_87:
	decl	%ebx
	je	.LBB8_92
.LBB8_88:
.Ltmp24:
	callq	*%r12
.Ltmp25:
	movq	%rax, 8(%rsp)
	movl	%edx, 16(%rsp)
	movq	%r15, 128(%rsp)
	#APP
	#NO_APP
	movq	128(%rsp), %rdi
	callq	_RNvCs5erIdfibIGj_3fib3fib
	movq	%rax, 120(%rsp)
.Ltmp26:
	movq	%r14, %rdi
	callq	*%rbp
.Ltmp27:
	movq	%rax, %xmm0
	punpckldq	.LCPI8_1(%rip), %xmm0
	subpd	.LCPI8_2(%rip), %xmm0
	movapd	%xmm0, %xmm1
	unpckhpd	%xmm0, %xmm1
	addsd	%xmm0, %xmm1
	xorps	%xmm0, %xmm0
	cvtsi2sd	%edx, %xmm0
	divsd	.LCPI8_3(%rip), %xmm0
	addsd	%xmm1, %xmm0
	mulsd	.LCPI8_4(%rip), %xmm0
	movsd	104(%rsp), %xmm1
	ucomisd	%xmm0, %xmm1
	jbe	.LBB8_87
	movsd	%xmm0, 112(%rsp)
	movsd	%xmm0, 104(%rsp)
	jmp	.LBB8_87
.LBB8_92:
	leaq	120(%rsp), %rax
	movq	%rax, 8(%rsp)
	movq	_RNvXse_NtNtNtCsgxBkk5gSRhY_4core3fmt3num3impxNtB9_7Display3fmt@GOTPCREL(%rip), %rax
	movq	%rax, 16(%rsp)
.Ltmp29:
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.9(%rip), %rdi
	leaq	8(%rsp), %rsi
	callq	*_RNvNtNtCs9k3SxhrAWiO_3std2io5stdio6__print@GOTPCREL(%rip)
.Ltmp30:
	leaq	112(%rsp), %rax
	movq	%rax, 8(%rsp)
	movq	_RNvXs7_NtNtCsgxBkk5gSRhY_4core3fmt5floatdNtB7_7Display3fmt@GOTPCREL(%rip), %rax
	movq	%rax, 16(%rsp)
.Ltmp31:
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.10(%rip), %rdi
	leaq	8(%rsp), %rsi
	callq	*_RNvNtNtCs9k3SxhrAWiO_3std2io5stdio6__print@GOTPCREL(%rip)
.Ltmp32:
	movq	72(%rsp), %r14
	movq	88(%rsp), %rcx
	movq	%rcx, %rax
	subq	%r14, %rax
	movabsq	$-6148914691236517205, %rdx
	mulq	%rdx
	cmpq	%r14, %rcx
	je	.LBB8_99
	movq	%rdx, %rbx
	shrq	$4, %rbx
	addq	$8, %r14
	jmp	.LBB8_97
	.p2align	4
.LBB8_96:
	addq	$24, %r14
	decq	%rbx
	je	.LBB8_99
.LBB8_97:
	movq	-8(%r14), %rsi
	testq	%rsi, %rsi
	je	.LBB8_96
	movq	(%r14), %rdi
	movl	$1, %edx
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
	jmp	.LBB8_96
.LBB8_99:
	movq	80(%rsp), %rax
	testq	%rax, %rax
	je	.LBB8_101
	movq	64(%rsp), %rdi
	shlq	$3, %rax
	leaq	(%rax,%rax,2), %rsi
	movl	$8, %edx
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB8_101:
	movq	48(%rsp), %rbx
	movq	56(%rsp), %r14
	testq	%r14, %r14
	je	.LBB8_106
	leaq	8(%rbx), %r15
	jmp	.LBB8_104
	.p2align	4
.LBB8_103:
	addq	$24, %r15
	decq	%r14
	je	.LBB8_106
.LBB8_104:
	movq	-8(%r15), %rsi
	testq	%rsi, %rsi
	je	.LBB8_103
	movq	(%r15), %rdi
	movl	$1, %edx
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
	jmp	.LBB8_103
.LBB8_106:
	movq	40(%rsp), %rax
	testq	%rax, %rax
	je	.LBB8_108
	shlq	$3, %rax
	leaq	(%rax,%rax,2), %rsi
	movl	$8, %edx
	movq	%rbx, %rdi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB8_108:
	addq	$152, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB8_109:
	.cfi_def_cfa_offset 208
	movb	$2, %cl
	jmp	.LBB8_112
.LBB8_110:
	movb	$2, %dl
	jmp	.LBB8_114
.LBB8_111:
	movb	$3, %cl
.LBB8_112:
	movzbl	(%rax), %eax
	addb	$-48, %al
	cmpb	$10, %al
	movzbl	%cl, %eax
	movl	$1, %edx
	cmovbl	%eax, %edx
	jmp	.LBB8_114
.LBB8_113:
	movb	$3, %dl
.LBB8_114:
	movb	%dl, 8(%rsp)
.Ltmp22:
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.7(%rip), %rdi
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.11(%rip), %rcx
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.8(%rip), %r8
	leaq	8(%rsp), %rdx
	movl	$20, %esi
	callq	*_RNvNtCsgxBkk5gSRhY_4core6result13unwrap_failed@GOTPCREL(%rip)
.Ltmp23:
.LBB8_115:
	ud2
.LBB8_116:
	movl	$257, %eax
	jmp	.LBB8_83
.LBB8_119:
	movb	$1, %dl
	jmp	.LBB8_114
.LBB8_120:
	movl	$1, %eax
	jmp	.LBB8_83
.LBB8_122:
	xorl	%edx, %edx
	jmp	.LBB8_114
.LBB8_123:
	movq	%rbx, %rax
	jmp	.LBB8_83
.LBB8_124:
.Ltmp2:
	movq	%rax, %rbx
	leaq	40(%rsp), %rdi
	callq	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECs5erIdfibIGj_3fib
	movq	%rbx, %rdi
	callq	_Unwind_Resume@PLT
.LBB8_125:
.Ltmp15:
	jmp	.LBB8_130
.LBB8_126:
.Ltmp10:
	jmp	.LBB8_130
.LBB8_127:
.Ltmp7:
	jmp	.LBB8_132
.LBB8_128:
.Ltmp28:
	jmp	.LBB8_132
.LBB8_129:
.Ltmp21:
.LBB8_130:
	movq	%rax, %rbx
	jmp	.LBB8_135
.LBB8_131:
.Ltmp33:
.LBB8_132:
	movq	%rax, %rbx
	jmp	.LBB8_137
.LBB8_133:
.Ltmp18:
	movq	%rax, %rbx
	testq	%rbp, %rbp
	je	.LBB8_135
	movl	$1, %edx
	movq	%r12, %rdi
	movq	%rbp, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB8_135:
	testq	%r14, %r14
	je	.LBB8_137
	movl	$1, %edx
	movq	%r15, %rdi
	movq	%r14, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB8_137:
	leaq	64(%rsp), %rdi
	callq	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECs5erIdfibIGj_3fib
	leaq	40(%rsp), %rdi
	callq	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECs5erIdfibIGj_3fib
	movq	%rbx, %rdi
	callq	_Unwind_Resume@PLT
.Lfunc_end8:
	.size	_RNvCs5erIdfibIGj_3fib4main, .Lfunc_end8-_RNvCs5erIdfibIGj_3fib4main
	.cfi_endproc
	.section	.gcc_except_table._RNvCs5erIdfibIGj_3fib4main,"a",@progbits
	.p2align	2, 0x0
GCC_except_table8:
.Lexception0:
	.byte	255
	.byte	255
	.byte	1
	.uleb128 .Lcst_end0-.Lcst_begin0
.Lcst_begin0:
	.uleb128 .Ltmp0-.Lfunc_begin0
	.uleb128 .Ltmp1-.Ltmp0
	.uleb128 .Ltmp2-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp3-.Lfunc_begin0
	.uleb128 .Ltmp6-.Ltmp3
	.uleb128 .Ltmp7-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp8-.Lfunc_begin0
	.uleb128 .Ltmp9-.Ltmp8
	.uleb128 .Ltmp10-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp13-.Lfunc_begin0
	.uleb128 .Ltmp12-.Ltmp13
	.uleb128 .Ltmp15-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp19-.Lfunc_begin0
	.uleb128 .Ltmp20-.Ltmp19
	.uleb128 .Ltmp21-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp16-.Lfunc_begin0
	.uleb128 .Ltmp17-.Ltmp16
	.uleb128 .Ltmp18-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp24-.Lfunc_begin0
	.uleb128 .Ltmp27-.Ltmp24
	.uleb128 .Ltmp28-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp29-.Lfunc_begin0
	.uleb128 .Ltmp23-.Ltmp29
	.uleb128 .Ltmp33-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp23-.Lfunc_begin0
	.uleb128 .Lfunc_end8-.Ltmp23
	.byte	0
	.byte	0
.Lcst_end0:
	.p2align	2, 0x0

	.section	.text._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib,"ax",@progbits
	.p2align	4
	.type	_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib,@function
_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib:
	.cfi_startproc
	movq	%rsi, %rax
	movq	(%rdi), %rcx
	movzbl	(%rcx), %ecx
	leaq	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib(%rip), %rdx
	movq	(%rdx,%rcx,8), %rdx
	leaq	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel(%rip), %rdi
	movslq	(%rdi,%rcx,4), %rsi
	addq	%rdi, %rsi
	movq	%rax, %rdi
	jmpq	*_RNvMsa_NtCsgxBkk5gSRhY_4core3fmtNtB5_9Formatter9write_str@GOTPCREL(%rip)
.Lfunc_end9:
	.size	_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib, .Lfunc_end9-_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib
	.cfi_endproc

	.section	.text._RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt,"ax",@progbits
	.p2align	4
	.type	_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt,@function
_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt:
	.cfi_startproc
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, %rax
	movq	%rdi, 16(%rsp)
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.12(%rip), %rcx
	movq	%rcx, (%rsp)
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.13(%rip), %rsi
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.14(%rip), %rcx
	leaq	16(%rsp), %r9
	movl	$13, %edx
	movl	$4, %r8d
	movq	%rax, %rdi
	callq	*_RNvMsa_NtCsgxBkk5gSRhY_4core3fmtNtB5_9Formatter26debug_struct_field1_finish@GOTPCREL(%rip)
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end10:
	.size	_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt, .Lfunc_end10-_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt
	.cfi_endproc

	.section	.text.main,"ax",@progbits
	.globl	main
	.p2align	4
	.type	main,@function
main:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, %rcx
	movslq	%edi, %rdx
	leaq	_RNvCs5erIdfibIGj_3fib4main(%rip), %rax
	movq	%rax, (%rsp)
	leaq	.Lanon.a0904180eda8772164b10ec498e62ed7.0(%rip), %rsi
	movq	%rsp, %rdi
	xorl	%r8d, %r8d
	callq	*_RNvNtCs9k3SxhrAWiO_3std2rt19lang_start_internal@GOTPCREL(%rip)
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end11:
	.size	main, .Lfunc_end11-main
	.cfi_endproc

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.0,@object
	.section	.data.rel.ro..Lanon.a0904180eda8772164b10ec498e62ed7.0,"aw",@progbits
	.p2align	3, 0x0
.Lanon.a0904180eda8772164b10ec498e62ed7.0:
	.asciz	"\000\000\000\000\000\000\000\000\b\000\000\000\000\000\000\000\b\000\000\000\000\000\000"
	.quad	_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCs5erIdfibIGj_3fib
	.quad	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Cs5erIdfibIGj_3fib
	.quad	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Cs5erIdfibIGj_3fib
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.0, 48

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.1,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.1,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.1:
	.ascii	"--runs"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.1, 6

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.2,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.2,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.2:
	.ascii	"--runs needs a value"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.2, 20

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.3,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lanon.a0904180eda8772164b10ec498e62ed7.3:
	.asciz	"bench/equivalents/rust/fib.rs"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.3, 30

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.4,@object
	.section	.data.rel.ro..Lanon.a0904180eda8772164b10ec498e62ed7.4,"aw",@progbits
	.p2align	3, 0x0
.Lanon.a0904180eda8772164b10ec498e62ed7.4:
	.quad	.Lanon.a0904180eda8772164b10ec498e62ed7.3
	.asciz	"\035\000\000\000\000\000\000\000\030\000\000\000 \000\000"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.4, 24

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.5,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.5,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.5:
	.ascii	"--runs must be an integer"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.5, 25

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.6,@object
	.section	.data.rel.ro..Lanon.a0904180eda8772164b10ec498e62ed7.6,"aw",@progbits
	.p2align	3, 0x0
.Lanon.a0904180eda8772164b10ec498e62ed7.6:
	.quad	.Lanon.a0904180eda8772164b10ec498e62ed7.3
	.asciz	"\035\000\000\000\000\000\000\000\030\000\000\000G\000\000"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.6, 24

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.7,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.7,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.7:
	.ascii	"n must be an integer"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.7, 20

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.8,@object
	.section	.data.rel.ro..Lanon.a0904180eda8772164b10ec498e62ed7.8,"aw",@progbits
	.p2align	3, 0x0
.Lanon.a0904180eda8772164b10ec498e62ed7.8:
	.quad	.Lanon.a0904180eda8772164b10ec498e62ed7.3
	.asciz	"\035\000\000\000\000\000\000\000\035\000\000\0006\000\000"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.8, 24

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.9,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lanon.a0904180eda8772164b10ec498e62ed7.9:
	.asciz	"\007value: \300\001\n"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.9, 12

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.10,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.10,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.10:
	.asciz	"\tbest_us: \305 \000\000p\003\000\001\n"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.10, 20

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.11,@object
	.section	.data.rel.ro..Lanon.a0904180eda8772164b10ec498e62ed7.11,"aw",@progbits
	.p2align	3, 0x0
.Lanon.a0904180eda8772164b10ec498e62ed7.11:
	.asciz	"\000\000\000\000\000\000\000\000\001\000\000\000\000\000\000\000\001\000\000\000\000\000\000"
	.quad	_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.11, 32

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.12,@object
	.section	.data.rel.ro..Lanon.a0904180eda8772164b10ec498e62ed7.12,"aw",@progbits
	.p2align	3, 0x0
.Lanon.a0904180eda8772164b10ec498e62ed7.12:
	.asciz	"\000\000\000\000\000\000\000\000\b\000\000\000\000\000\000\000\b\000\000\000\000\000\000"
	.quad	_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.12, 32

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.13,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.13,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.13:
	.ascii	"ParseIntError"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.13, 13

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.14,@object
	.section	.rodata.cst4,"aM",@progbits,4
.Lanon.a0904180eda8772164b10ec498e62ed7.14:
	.ascii	"kind"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.14, 4

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.15,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.15,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.15:
	.ascii	"Empty"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.15, 5

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.16,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.16,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.16:
	.ascii	"InvalidDigit"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.16, 12

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.17,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.17,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.17:
	.ascii	"PosOverflow"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.17, 11

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.18,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.18,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.18:
	.ascii	"NegOverflow"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.18, 11

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.19,@object
	.section	.rodata.cst4,"aM",@progbits,4
.Lanon.a0904180eda8772164b10ec498e62ed7.19:
	.ascii	"Zero"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.19, 4

	.type	.Lanon.a0904180eda8772164b10ec498e62ed7.20,@object
	.section	.rodata..Lanon.a0904180eda8772164b10ec498e62ed7.20,"a",@progbits
.Lanon.a0904180eda8772164b10ec498e62ed7.20:
	.ascii	"NotAPowerOfTwo"
	.size	.Lanon.a0904180eda8772164b10ec498e62ed7.20, 14

	.type	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib,@object
	.section	.rodata..Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib,"a",@progbits
	.p2align	3, 0x0
.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib:
	.quad	5
	.quad	12
	.quad	11
	.quad	11
	.quad	4
	.quad	14
	.size	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib, 48

	.type	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel,@object
	.section	.rodata..Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel,"a",@progbits
	.p2align	2, 0x0
.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel:
	.long	.Lanon.a0904180eda8772164b10ec498e62ed7.15-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel
	.long	.Lanon.a0904180eda8772164b10ec498e62ed7.16-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel
	.long	.Lanon.a0904180eda8772164b10ec498e62ed7.17-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel
	.long	.Lanon.a0904180eda8772164b10ec498e62ed7.18-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel
	.long	.Lanon.a0904180eda8772164b10ec498e62ed7.19-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel
	.long	.Lanon.a0904180eda8772164b10ec498e62ed7.20-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel
	.size	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCs5erIdfibIGj_3fib.24.rel, 24

	.hidden	DW.ref.rust_eh_personality
	.weak	DW.ref.rust_eh_personality
	.section	.data.DW.ref.rust_eh_personality,"awG",@progbits,DW.ref.rust_eh_personality,comdat
	.p2align	3, 0x0
	.type	DW.ref.rust_eh_personality,@object
	.size	DW.ref.rust_eh_personality, 8
DW.ref.rust_eh_personality:
	.quad	rust_eh_personality
	.ident	"rustc version 1.98.1 (48a229cea 2026-09-01)"
	.section	".note.GNU-stack","",@progbits

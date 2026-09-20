	.file	"loop_count.a7caefc76f52729f-cgu.0"
	.section	.text._RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECsep9IqgdOJhb_10loop_count,"ax",@progbits
	.hidden	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECsep9IqgdOJhb_10loop_count
	.globl	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECsep9IqgdOJhb_10loop_count
	.p2align	4
	.type	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECsep9IqgdOJhb_10loop_count,@function
_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECsep9IqgdOJhb_10loop_count:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	%ecx, %r8d
	movq	%rdx, %rcx
	movq	%rsi, %rdx
	movq	%rdi, (%rsp)
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.0(%rip), %rsi
	movq	%rsp, %rdi
	callq	*_RNvNtCs9k3SxhrAWiO_3std2rt19lang_start_internal@GOTPCREL(%rip)
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECsep9IqgdOJhb_10loop_count, .Lfunc_end0-_RINvNtCs9k3SxhrAWiO_3std2rt10lang_startuECsep9IqgdOJhb_10loop_count
	.cfi_endproc

	.section	.text._RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECsep9IqgdOJhb_10loop_count,"ax",@progbits
	.p2align	4
	.type	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECsep9IqgdOJhb_10loop_count,@function
_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECsep9IqgdOJhb_10loop_count:
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
	.size	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECsep9IqgdOJhb_10loop_count, .Lfunc_end1-_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECsep9IqgdOJhb_10loop_count
	.cfi_endproc

	.section	.text._RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECsep9IqgdOJhb_10loop_count,"ax",@progbits
	.p2align	4
	.type	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECsep9IqgdOJhb_10loop_count,@function
_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECsep9IqgdOJhb_10loop_count:
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
	.size	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECsep9IqgdOJhb_10loop_count, .Lfunc_end2-_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECsep9IqgdOJhb_10loop_count
	.cfi_endproc

	.section	.text._RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECsep9IqgdOJhb_10loop_count,"ax",@progbits
	.p2align	4
	.type	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECsep9IqgdOJhb_10loop_count,@function
_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECsep9IqgdOJhb_10loop_count:
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
	.size	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECsep9IqgdOJhb_10loop_count, .Lfunc_end3-_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECsep9IqgdOJhb_10loop_count
	.cfi_endproc

	.section	.text._RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECsep9IqgdOJhb_10loop_count,"ax",@progbits
	.p2align	4
	.type	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECsep9IqgdOJhb_10loop_count,@function
_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECsep9IqgdOJhb_10loop_count:
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
	.size	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECsep9IqgdOJhb_10loop_count, .Lfunc_end4-_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECsep9IqgdOJhb_10loop_count
	.cfi_endproc

	.section	.text._RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Csep9IqgdOJhb_10loop_count,"ax",@progbits
	.p2align	4
	.type	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Csep9IqgdOJhb_10loop_count,@function
_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Csep9IqgdOJhb_10loop_count:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	(%rdi), %rdi
	callq	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECsep9IqgdOJhb_10loop_count
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end5:
	.size	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Csep9IqgdOJhb_10loop_count, .Lfunc_end5-_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Csep9IqgdOJhb_10loop_count
	.cfi_endproc

	.section	.text._RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCsep9IqgdOJhb_10loop_count,"ax",@progbits
	.p2align	4
	.type	_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCsep9IqgdOJhb_10loop_count,@function
_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCsep9IqgdOJhb_10loop_count:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	(%rdi), %rdi
	callq	_RINvNtNtCs9k3SxhrAWiO_3std3sys9backtrace28___rust_begin_short_backtraceFEuuECsep9IqgdOJhb_10loop_count
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end6:
	.size	_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCsep9IqgdOJhb_10loop_count, .Lfunc_end6-_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCsep9IqgdOJhb_10loop_count
	.cfi_endproc

	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	3, 0x0
.LCPI7_0:
	.quad	0x7fefffffffffffff
.LCPI7_3:
	.quad	0x41cdcd6500000000
.LCPI7_4:
	.quad	0x412e848000000000
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI7_1:
	.long	1127219200
	.long	1160773632
	.long	0
	.long	0
.LCPI7_2:
	.quad	0x4330000000000000
	.quad	0x4530000000000000
	.section	.text._RNvCsep9IqgdOJhb_10loop_count4main,"ax",@progbits
	.hidden	_RNvCsep9IqgdOJhb_10loop_count4main
	.globl	_RNvCsep9IqgdOJhb_10loop_count4main
	.p2align	4
	.type	_RNvCsep9IqgdOJhb_10loop_count4main,@function
_RNvCsep9IqgdOJhb_10loop_count4main:
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
	subq	$168, %rsp
	.cfi_def_cfa_offset 224
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	$0, 48(%rsp)
	movq	$8, 56(%rsp)
	movq	$0, 64(%rsp)
.Ltmp0:
	leaq	8(%rsp), %rdi
	callq	*_RNvNtCs9k3SxhrAWiO_3std3env4args@GOTPCREL(%rip)
.Ltmp1:
	movupd	8(%rsp), %xmm0
	movupd	24(%rsp), %xmm1
	movapd	%xmm1, 112(%rsp)
	movapd	%xmm0, 96(%rsp)
	movq	$1, 128(%rsp)
	movl	$5, %r14d
	movl	$1, %esi
	leaq	8(%rsp), %rax
	movq	%rax, 40(%rsp)
	movl	$10, %ebp
	testq	%rsi, %rsi
	je	.LBB7_4
.LBB7_47:
	movq	$0, 128(%rsp)
.Ltmp3:
	leaq	96(%rsp), %rdi
	callq	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECsep9IqgdOJhb_10loop_count
.Ltmp4:
	testq	%rax, %rax
	je	.LBB7_4
	jmp	.LBB7_53
	.p2align	4
.LBB7_2:
	movq	56(%rsp), %rax
	leaq	(,%r13,2), %rcx
	addq	%r13, %rcx
	movq	%r15, (%rax,%rcx,8)
	movq	%r12, 8(%rax,%rcx,8)
	movq	%rbx, 16(%rax,%rcx,8)
	incq	%r13
	movq	%r13, 64(%rsp)
.LBB7_3:
	movq	128(%rsp), %rsi
	testq	%rsi, %rsi
	jne	.LBB7_47
.LBB7_4:
.Ltmp5:
	leaq	72(%rsp), %rdi
	leaq	96(%rsp), %rsi
	callq	*_RNvXsc_NtCs9k3SxhrAWiO_3std3envNtB5_4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator4next@GOTPCREL(%rip)
.Ltmp6:
	movq	72(%rsp), %r15
	cmpq	$-1, %r15
	je	.LBB7_53
	movq	80(%rsp), %r12
	movq	88(%rsp), %rbx
	cmpq	$6, %rbx
	jne	.LBB7_8
	movl	(%r12), %eax
	movl	$1970416941, %ecx
	xorl	%ecx, %eax
	movzwl	4(%r12), %ecx
	xorl	$29550, %ecx
	orl	%eax, %ecx
	je	.LBB7_10
.LBB7_8:
	movq	64(%rsp), %r13
	cmpq	48(%rsp), %r13
	jne	.LBB7_2
.Ltmp8:
	leaq	48(%rsp), %rdi
	callq	*_RNvMs4_NtCs6i54tJFfzR_5alloc7raw_vecINtB5_6RawVecNtNtB7_6string6StringE8grow_oneCs9k3SxhrAWiO_3std@GOTPCREL(%rip)
.Ltmp9:
	jmp	.LBB7_2
	.p2align	4
.LBB7_10:
	movq	128(%rsp), %rsi
	testq	%rsi, %rsi
	jne	.LBB7_50
.LBB7_11:
.Ltmp13:
	leaq	8(%rsp), %rdi
	leaq	96(%rsp), %rsi
	callq	*_RNvXsc_NtCs9k3SxhrAWiO_3std3envNtB5_4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator4next@GOTPCREL(%rip)
.Ltmp14:
	movq	8(%rsp), %rbx
	cmpq	$-1, %rbx
	je	.LBB7_52
	movq	16(%rsp), %r13
	movq	24(%rsp), %rsi
	cmpq	$1, %rsi
	je	.LBB7_16
	testq	%rsi, %rsi
	je	.LBB7_158
	movzbl	(%r13), %ecx
	jmp	.LBB7_18
	.p2align	4
.LBB7_16:
	movzbl	(%r13), %ecx
	movl	$257, %eax
	cmpl	$43, %ecx
	je	.LBB7_85
	cmpl	$45, %ecx
	je	.LBB7_85
.LBB7_18:
	xorl	%eax, %eax
	cmpb	$43, %cl
	sete	%al
	movq	%rsi, %rdx
	subq	%rax, %rdx
	leaq	(%rax,%r13), %rcx
	cmpq	$9, %rdx
	jae	.LBB7_36
	testq	%rdx, %rdx
	je	.LBB7_41
	movzbl	(%rcx), %r14d
	addl	$-48, %r14d
	movl	$257, %eax
	cmpl	$9, %r14d
	ja	.LBB7_85
	cmpq	$1, %rdx
	je	.LBB7_42
	movzbl	1(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_85
	leal	(%r14,%r14,4), %edi
	leal	(%rsi,%rdi,2), %r14d
	cmpq	$2, %rdx
	je	.LBB7_42
	movzbl	2(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_85
	leal	(%r14,%r14,4), %edi
	leal	(%rsi,%rdi,2), %r14d
	cmpq	$3, %rdx
	je	.LBB7_42
	movzbl	3(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_85
	leal	(%r14,%r14,4), %edi
	leal	(%rsi,%rdi,2), %r14d
	cmpq	$4, %rdx
	je	.LBB7_42
	movzbl	4(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_85
	leal	(%r14,%r14,4), %edi
	leal	(%rsi,%rdi,2), %r14d
	cmpq	$5, %rdx
	je	.LBB7_42
	movzbl	5(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_85
	leal	(%r14,%r14,4), %edi
	leal	(%rsi,%rdi,2), %r14d
	cmpq	$6, %rdx
	je	.LBB7_42
	movzbl	6(%rcx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_85
	leal	(%r14,%r14,4), %edi
	leal	(%rsi,%rdi,2), %r14d
	cmpq	$7, %rdx
	je	.LBB7_42
	movzbl	7(%rcx), %ecx
	addl	$-48, %ecx
	cmpl	$9, %ecx
	ja	.LBB7_85
	leal	(%r14,%r14,4), %eax
	leal	(%rcx,%rax,2), %r14d
	shlq	$32, %r14
	testb	$1, %r14b
	je	.LBB7_43
	jmp	.LBB7_165
	.p2align	4
.LBB7_36:
	negq	%rax
	addq	%rax, %rsi
	negq	%rsi
	xorl	%r14d, %r14d
	xorl	%edi, %edi
	.p2align	4
.LBB7_37:
	movq	%rsi, %rax
	addq	%rdi, %rax
	je	.LBB7_42
	movl	%r14d, %eax
	mull	%ebp
	movzbl	(%rcx,%rdi), %r14d
	jo	.LBB7_49
	addl	$-48, %r14d
	cmpl	$10, %r14d
	jae	.LBB7_153
	incq	%rdi
	addl	%eax, %r14d
	jae	.LBB7_37
	jmp	.LBB7_84
	.p2align	4
.LBB7_41:
	xorl	%r14d, %r14d
	.p2align	4
.LBB7_42:
	shlq	$32, %r14
	testb	$1, %r14b
	jne	.LBB7_165
.LBB7_43:
	testq	%rbx, %rbx
	je	.LBB7_45
	movl	$1, %edx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB7_45:
	shrq	$32, %r14
	testq	%r15, %r15
	je	.LBB7_3
	movl	$1, %edx
	movq	%r12, %rdi
	movq	%r15, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
	movq	128(%rsp), %rsi
	testq	%rsi, %rsi
	je	.LBB7_4
	jmp	.LBB7_47
.LBB7_49:
	addb	$-48, %r14b
	xorl	%eax, %eax
	cmpb	$10, %r14b
	setb	%al
	shll	$8, %eax
	addq	$257, %rax
	movq	%rax, %r14
	testb	$1, %r14b
	je	.LBB7_43
	jmp	.LBB7_165
.LBB7_50:
	movq	$0, 128(%rsp)
.Ltmp11:
	leaq	96(%rsp), %rdi
	callq	_RINvYNtNtCs9k3SxhrAWiO_3std3env4ArgsNtNtNtNtCsgxBkk5gSRhY_4core4iter6traits8iterator8Iterator8try_foldINtNtNtBG_3num7nonzero7NonZerojENCNvXs_NvBy_10advance_byB3_NtB2f_13SpecAdvanceBy15spec_advance_by0INtNtBG_6option6OptionB1C_EECsep9IqgdOJhb_10loop_count
.Ltmp12:
	testq	%rax, %rax
	je	.LBB7_11
.LBB7_52:
.Ltmp19:
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.2(%rip), %rdi
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.4(%rip), %rdx
	movl	$20, %esi
	callq	*_RNvNtCsgxBkk5gSRhY_4core6option13expect_failed@GOTPCREL(%rip)
.Ltmp20:
	jmp	.LBB7_152
.LBB7_53:
	movq	64(%rsp), %rax
	testq	%rax, %rax
	je	.LBB7_57
	movq	56(%rsp), %rcx
	movq	8(%rcx), %rdx
	movq	16(%rcx), %rsi
	cmpq	$1, %rsi
	je	.LBB7_58
	testq	%rsi, %rsi
	je	.LBB7_163
	movzbl	(%rdx), %r8d
	jmp	.LBB7_60
.LBB7_57:
	movl	$500, %r15d
	jmp	.LBB7_114
.LBB7_58:
	movzbl	(%rdx), %r8d
	movb	$1, %dil
	cmpl	$43, %r8d
	je	.LBB7_144
	cmpl	$45, %r8d
	je	.LBB7_144
.LBB7_60:
	cmpb	$45, %r8b
	je	.LBB7_72
	movzbl	%r8b, %edi
	cmpl	$43, %edi
	jne	.LBB7_63
	incq	%rdx
	decq	%rsi
.LBB7_63:
	xorl	%r15d, %r15d
	cmpq	$16, %rsi
	jae	.LBB7_68
	testq	%rsi, %rsi
	je	.LBB7_82
	xorl	%edi, %edi
	.p2align	4
.LBB7_66:
	movzbl	(%rdx,%rdi), %r8d
	addl	$-48, %r8d
	cmpl	$9, %r8d
	ja	.LBB7_156
	leaq	(%r15,%r15,4), %r9
	movl	%r8d, %r8d
	leaq	(%r8,%r9,2), %r15
	incq	%rdi
	cmpq	%rdi, %rsi
	jne	.LBB7_66
	jmp	.LBB7_82
	.p2align	4
.LBB7_68:
	imulq	$10, %r15, %r15
	jo	.LBB7_139
	movzbl	(%rdx), %edi
	addl	$-48, %edi
	cmpl	$9, %edi
	ja	.LBB7_156
	movl	%edi, %edi
	addq	%rdi, %r15
	jo	.LBB7_140
	incq	%rdx
	decq	%rsi
	jne	.LBB7_68
	jmp	.LBB7_82
.LBB7_72:
	leaq	-1(%rsi), %rdi
	cmpq	$17, %rsi
	jae	.LBB7_77
	testq	%rdi, %rdi
	je	.LBB7_86
	movl	$1, %edi
	xorl	%r15d, %r15d
	.p2align	4
.LBB7_75:
	movzbl	(%rdx,%rdi), %r8d
	addl	$-48, %r8d
	cmpl	$9, %r8d
	ja	.LBB7_156
	addq	%r15, %r15
	leaq	(%r15,%r15,4), %r15
	movl	%r8d, %r8d
	subq	%r8, %r15
	incq	%rdi
	cmpq	%rdi, %rsi
	jne	.LBB7_75
	jmp	.LBB7_82
.LBB7_77:
	incq	%rdx
	xorl	%r15d, %r15d
	.p2align	4
.LBB7_78:
	imulq	$10, %r15, %r15
	jo	.LBB7_141
	movzbl	(%rdx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_156
	movl	%esi, %esi
	subq	%rsi, %r15
	jo	.LBB7_143
	incq	%rdx
	decq	%rdi
	jne	.LBB7_78
.LBB7_82:
	cmpq	$1, %rax
	jne	.LBB7_87
.LBB7_114:
	xorl	%r12d, %r12d
.LBB7_115:
	movq	%r15, 72(%rsp)
	leaq	72(%rsp), %rax
	#APP
	#NO_APP
	movq	%r12, 8(%rsp)
	leaq	8(%rsp), %rax
	#APP
	#NO_APP
	movq	72(%rsp), %rdi
	movq	8(%rsp), %rsi
	callq	_RNvCsep9IqgdOJhb_10loop_count5drive
	movabsq	$9218868437227405311, %rax
	movq	%rax, 144(%rsp)
	movq	$0, 152(%rsp)
	testl	%r14d, %r14d
	je	.LBB7_122
	movsd	.LCPI7_0(%rip), %xmm0
	movsd	%xmm0, 40(%rsp)
	leaq	72(%rsp), %r13
	leaq	8(%rsp), %rbx
	movq	_RNvMNtCs9k3SxhrAWiO_3std4timeNtB2_7Instant7elapsed@GOTPCREL(%rip), %rbp
	jmp	.LBB7_118
	.p2align	4
.LBB7_117:
	decl	%r14d
	je	.LBB7_122
.LBB7_118:
.Ltmp24:
	callq	*_RNvMNtCs9k3SxhrAWiO_3std4timeNtB2_7Instant3now@GOTPCREL(%rip)
.Ltmp25:
	movq	%rax, 8(%rsp)
	movl	%edx, 16(%rsp)
	movq	%r15, 160(%rsp)
	leaq	160(%rsp), %rax
	#APP
	#NO_APP
	movq	%r12, 72(%rsp)
	#APP
	#NO_APP
	movq	160(%rsp), %rdi
	movq	72(%rsp), %rsi
	callq	_RNvCsep9IqgdOJhb_10loop_count5drive
	movq	%rax, 152(%rsp)
.Ltmp26:
	movq	%rbx, %rdi
	callq	*%rbp
.Ltmp27:
	movq	%rax, %xmm0
	punpckldq	.LCPI7_1(%rip), %xmm0
	subpd	.LCPI7_2(%rip), %xmm0
	movapd	%xmm0, %xmm1
	unpckhpd	%xmm0, %xmm1
	addsd	%xmm0, %xmm1
	xorps	%xmm0, %xmm0
	cvtsi2sd	%edx, %xmm0
	divsd	.LCPI7_3(%rip), %xmm0
	addsd	%xmm1, %xmm0
	mulsd	.LCPI7_4(%rip), %xmm0
	movsd	40(%rsp), %xmm1
	ucomisd	%xmm0, %xmm1
	jbe	.LBB7_117
	movsd	%xmm0, 144(%rsp)
	movsd	%xmm0, 40(%rsp)
	jmp	.LBB7_117
.LBB7_122:
	leaq	152(%rsp), %rax
	movq	%rax, 8(%rsp)
	movq	_RNvXse_NtNtNtCsgxBkk5gSRhY_4core3fmt3num3impxNtB9_7Display3fmt@GOTPCREL(%rip), %rax
	movq	%rax, 16(%rsp)
.Ltmp29:
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.11(%rip), %rdi
	leaq	8(%rsp), %rsi
	callq	*_RNvNtNtCs9k3SxhrAWiO_3std2io5stdio6__print@GOTPCREL(%rip)
.Ltmp30:
	leaq	144(%rsp), %rax
	movq	%rax, 8(%rsp)
	movq	_RNvXs7_NtNtCsgxBkk5gSRhY_4core3fmt5floatdNtB7_7Display3fmt@GOTPCREL(%rip), %rax
	movq	%rax, 16(%rsp)
.Ltmp31:
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.12(%rip), %rdi
	leaq	8(%rsp), %rsi
	callq	*_RNvNtNtCs9k3SxhrAWiO_3std2io5stdio6__print@GOTPCREL(%rip)
.Ltmp32:
	movq	104(%rsp), %r14
	movq	120(%rsp), %rcx
	movq	%rcx, %rax
	subq	%r14, %rax
	movabsq	$-6148914691236517205, %rdx
	mulq	%rdx
	cmpq	%r14, %rcx
	je	.LBB7_129
	movq	%rdx, %rbx
	shrq	$4, %rbx
	addq	$8, %r14
	jmp	.LBB7_127
	.p2align	4
.LBB7_126:
	addq	$24, %r14
	decq	%rbx
	je	.LBB7_129
.LBB7_127:
	movq	-8(%r14), %rsi
	testq	%rsi, %rsi
	je	.LBB7_126
	movq	(%r14), %rdi
	movl	$1, %edx
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
	jmp	.LBB7_126
.LBB7_129:
	movq	112(%rsp), %rax
	testq	%rax, %rax
	je	.LBB7_131
	movq	96(%rsp), %rdi
	shlq	$3, %rax
	leaq	(%rax,%rax,2), %rsi
	movl	$8, %edx
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB7_131:
	movq	56(%rsp), %rbx
	movq	64(%rsp), %r14
	testq	%r14, %r14
	je	.LBB7_136
	leaq	8(%rbx), %r15
	jmp	.LBB7_134
	.p2align	4
.LBB7_133:
	addq	$24, %r15
	decq	%r14
	je	.LBB7_136
.LBB7_134:
	movq	-8(%r15), %rsi
	testq	%rsi, %rsi
	je	.LBB7_133
	movq	(%r15), %rdi
	movl	$1, %edx
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
	jmp	.LBB7_133
.LBB7_136:
	movq	48(%rsp), %rax
	testq	%rax, %rax
	je	.LBB7_138
	shlq	$3, %rax
	leaq	(%rax,%rax,2), %rsi
	movl	$8, %edx
	movq	%rbx, %rdi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB7_138:
	addq	$168, %rsp
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
.LBB7_84:
	.cfi_def_cfa_offset 224
	movl	$513, %eax
.LBB7_85:
	movb	%ah, 8(%rsp)
.Ltmp16:
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.5(%rip), %rdi
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.13(%rip), %rcx
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.6(%rip), %r8
	leaq	8(%rsp), %rdx
	movl	$25, %esi
	callq	*_RNvNtCsgxBkk5gSRhY_4core6result13unwrap_failed@GOTPCREL(%rip)
.Ltmp17:
	jmp	.LBB7_152
.LBB7_86:
	xorl	%r15d, %r15d
	cmpq	$1, %rax
	je	.LBB7_114
.LBB7_87:
	movq	32(%rcx), %rax
	movq	40(%rcx), %rcx
	cmpq	$1, %rcx
	je	.LBB7_90
	testq	%rcx, %rcx
	je	.LBB7_164
	movzbl	(%rax), %esi
	jmp	.LBB7_92
.LBB7_90:
	movzbl	(%rax), %esi
	movb	$1, %dl
	cmpl	$43, %esi
	je	.LBB7_150
	cmpl	$45, %esi
	je	.LBB7_150
.LBB7_92:
	cmpb	$45, %sil
	je	.LBB7_104
	movzbl	%sil, %edx
	cmpl	$43, %edx
	jne	.LBB7_95
	incq	%rax
	decq	%rcx
.LBB7_95:
	xorl	%r12d, %r12d
	cmpq	$16, %rcx
	jae	.LBB7_100
	testq	%rcx, %rcx
	je	.LBB7_115
	xorl	%edx, %edx
	.p2align	4
.LBB7_98:
	movzbl	(%rax,%rdx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_161
	leaq	(%r12,%r12,4), %rdi
	movl	%esi, %esi
	leaq	(%rsi,%rdi,2), %r12
	incq	%rdx
	cmpq	%rdx, %rcx
	jne	.LBB7_98
	jmp	.LBB7_115
	.p2align	4
.LBB7_100:
	imulq	$10, %r12, %r12
	jo	.LBB7_145
	movzbl	(%rax), %edx
	addl	$-48, %edx
	cmpl	$9, %edx
	ja	.LBB7_161
	movl	%edx, %edx
	addq	%rdx, %r12
	jo	.LBB7_146
	incq	%rax
	decq	%rcx
	jne	.LBB7_100
	jmp	.LBB7_115
.LBB7_104:
	leaq	-1(%rcx), %rdx
	cmpq	$17, %rcx
	jae	.LBB7_109
	testq	%rdx, %rdx
	je	.LBB7_114
	movl	$1, %edx
	xorl	%r12d, %r12d
	.p2align	4
.LBB7_107:
	movzbl	(%rax,%rdx), %esi
	addl	$-48, %esi
	cmpl	$9, %esi
	ja	.LBB7_161
	addq	%r12, %r12
	leaq	(%r12,%r12,4), %r12
	movl	%esi, %esi
	subq	%rsi, %r12
	incq	%rdx
	cmpq	%rdx, %rcx
	jne	.LBB7_107
	jmp	.LBB7_115
.LBB7_109:
	incq	%rax
	xorl	%r12d, %r12d
	.p2align	4
.LBB7_110:
	imulq	$10, %r12, %r12
	jo	.LBB7_147
	movzbl	(%rax), %ecx
	addl	$-48, %ecx
	cmpl	$9, %ecx
	ja	.LBB7_161
	movl	%ecx, %ecx
	subq	%rcx, %r12
	jo	.LBB7_149
	incq	%rax
	decq	%rdx
	jne	.LBB7_110
	jmp	.LBB7_115
.LBB7_139:
	movb	$2, %al
	jmp	.LBB7_142
.LBB7_140:
	movb	$2, %dil
	jmp	.LBB7_144
.LBB7_141:
	movb	$3, %al
.LBB7_142:
	movzbl	(%rdx), %ecx
	addb	$-48, %cl
	cmpb	$10, %cl
	movzbl	%al, %eax
	movl	$1, %edi
	cmovbl	%eax, %edi
	jmp	.LBB7_144
.LBB7_143:
	movb	$3, %dil
.LBB7_144:
	movb	%dil, 8(%rsp)
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.8(%rip), %r8
	movl	$20, %esi
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.7(%rip), %rdi
	jmp	.LBB7_151
.LBB7_145:
	movb	$2, %cl
	jmp	.LBB7_148
.LBB7_146:
	movb	$2, %dl
	jmp	.LBB7_150
.LBB7_147:
	movb	$3, %cl
.LBB7_148:
	movzbl	(%rax), %eax
	addb	$-48, %al
	cmpb	$10, %al
	movzbl	%cl, %eax
	movl	$1, %edx
	cmovbl	%eax, %edx
	jmp	.LBB7_150
.LBB7_149:
	movb	$3, %dl
.LBB7_150:
	movb	%dl, 8(%rsp)
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.10(%rip), %r8
	movl	$24, %esi
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.9(%rip), %rdi
.LBB7_151:
.Ltmp22:
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.13(%rip), %rcx
	movq	40(%rsp), %rdx
	callq	*_RNvNtCsgxBkk5gSRhY_4core6result13unwrap_failed@GOTPCREL(%rip)
.Ltmp23:
.LBB7_152:
	ud2
.LBB7_153:
	movl	$257, %eax
	jmp	.LBB7_85
.LBB7_156:
	movb	$1, %dil
	jmp	.LBB7_144
.LBB7_161:
	movb	$1, %dl
	jmp	.LBB7_150
.LBB7_158:
	movl	$1, %eax
	jmp	.LBB7_85
.LBB7_163:
	xorl	%edi, %edi
	jmp	.LBB7_144
.LBB7_164:
	xorl	%edx, %edx
	jmp	.LBB7_150
.LBB7_165:
	movq	%r14, %rax
	jmp	.LBB7_85
.LBB7_166:
.Ltmp2:
	movq	%rax, %r14
	leaq	48(%rsp), %rdi
	callq	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECsep9IqgdOJhb_10loop_count
	movq	%r14, %rdi
	callq	_Unwind_Resume@PLT
.LBB7_167:
.Ltmp15:
	jmp	.LBB7_172
.LBB7_168:
.Ltmp10:
	jmp	.LBB7_172
.LBB7_169:
.Ltmp7:
	jmp	.LBB7_174
.LBB7_170:
.Ltmp28:
	jmp	.LBB7_174
.LBB7_171:
.Ltmp21:
.LBB7_172:
	movq	%rax, %r14
	jmp	.LBB7_177
.LBB7_173:
.Ltmp33:
.LBB7_174:
	movq	%rax, %r14
	jmp	.LBB7_179
.LBB7_175:
.Ltmp18:
	movq	%rax, %r14
	testq	%rbx, %rbx
	je	.LBB7_177
	movl	$1, %edx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB7_177:
	testq	%r15, %r15
	je	.LBB7_179
	movl	$1, %edx
	movq	%r12, %rdi
	movq	%r15, %rsi
	callq	*_RNvCs1njKG4L9aB3_7___rustc14___rust_dealloc@GOTPCREL(%rip)
.LBB7_179:
	leaq	96(%rsp), %rdi
	callq	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtNtNtB4_4iter8adapters4skip4SkipNtNtCs9k3SxhrAWiO_3std3env4ArgsEECsep9IqgdOJhb_10loop_count
	leaq	48(%rsp), %rdi
	callq	_RINvNtCsgxBkk5gSRhY_4core3ptr9drop_glueINtNtCs6i54tJFfzR_5alloc3vec3VecNtNtBG_6string6StringEECsep9IqgdOJhb_10loop_count
	movq	%r14, %rdi
	callq	_Unwind_Resume@PLT
.Lfunc_end7:
	.size	_RNvCsep9IqgdOJhb_10loop_count4main, .Lfunc_end7-_RNvCsep9IqgdOJhb_10loop_count4main
	.cfi_endproc
	.section	.gcc_except_table._RNvCsep9IqgdOJhb_10loop_count4main,"a",@progbits
	.p2align	2, 0x0
GCC_except_table7:
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
	.uleb128 .Ltmp24-.Lfunc_begin0
	.uleb128 .Ltmp27-.Ltmp24
	.uleb128 .Ltmp28-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp29-.Lfunc_begin0
	.uleb128 .Ltmp32-.Ltmp29
	.uleb128 .Ltmp33-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp16-.Lfunc_begin0
	.uleb128 .Ltmp17-.Ltmp16
	.uleb128 .Ltmp18-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp22-.Lfunc_begin0
	.uleb128 .Ltmp23-.Ltmp22
	.uleb128 .Ltmp33-.Lfunc_begin0
	.byte	0
	.uleb128 .Ltmp23-.Lfunc_begin0
	.uleb128 .Lfunc_end7-.Ltmp23
	.byte	0
	.byte	0
.Lcst_end0:
	.p2align	2, 0x0

	.section	.text._RNvCsep9IqgdOJhb_10loop_count4work,"ax",@progbits
	.p2align	4
	.type	_RNvCsep9IqgdOJhb_10loop_count4work,@function
_RNvCsep9IqgdOJhb_10loop_count4work:
	.cfi_startproc
	leaq	(%rdi,%rdi,2), %rax
	addq	$7, %rax
	js	.LBB8_1
	retq
	.p2align	4
.LBB8_1:
	jmp	.LBB8_1
.Lfunc_end8:
	.size	_RNvCsep9IqgdOJhb_10loop_count4work, .Lfunc_end8-_RNvCsep9IqgdOJhb_10loop_count4work
	.cfi_endproc

	.section	.text._RNvCsep9IqgdOJhb_10loop_count5drive,"ax",@progbits
	.p2align	4
	.type	_RNvCsep9IqgdOJhb_10loop_count5drive,@function
_RNvCsep9IqgdOJhb_10loop_count5drive:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rsi, %rbx
	testq	%rdi, %rdi
	jle	.LBB9_4
	movq	%rdi, %r14
	movq	%rdi, %r15
	.p2align	4
.LBB9_2:
	movq	%r15, %rdi
	callq	_RNvCsep9IqgdOJhb_10loop_count4work
	subq	$1, %r15
	ja	.LBB9_2
	leaq	(%rbx,%r14,8), %rbx
	subq	%r14, %rbx
.LBB9_4:
	movq	%rbx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end9:
	.size	_RNvCsep9IqgdOJhb_10loop_count5drive, .Lfunc_end9-_RNvCsep9IqgdOJhb_10loop_count5drive
	.cfi_endproc

	.section	.text._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count,"ax",@progbits
	.p2align	4
	.type	_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count,@function
_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count:
	.cfi_startproc
	movq	%rsi, %rax
	movq	(%rdi), %rcx
	movzbl	(%rcx), %ecx
	leaq	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count(%rip), %rdx
	movq	(%rdx,%rcx,8), %rdx
	leaq	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel(%rip), %rdi
	movslq	(%rdi,%rcx,4), %rsi
	addq	%rdi, %rsi
	movq	%rax, %rdi
	jmpq	*_RNvMsa_NtCsgxBkk5gSRhY_4core3fmtNtB5_9Formatter9write_str@GOTPCREL(%rip)
.Lfunc_end10:
	.size	_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count, .Lfunc_end10-_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count
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
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.14(%rip), %rcx
	movq	%rcx, (%rsp)
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.15(%rip), %rsi
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.16(%rip), %rcx
	leaq	16(%rsp), %r9
	movl	$13, %edx
	movl	$4, %r8d
	movq	%rax, %rdi
	callq	*_RNvMsa_NtCsgxBkk5gSRhY_4core3fmtNtB5_9Formatter26debug_struct_field1_finish@GOTPCREL(%rip)
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end11:
	.size	_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt, .Lfunc_end11-_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt
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
	leaq	_RNvCsep9IqgdOJhb_10loop_count4main(%rip), %rax
	movq	%rax, (%rsp)
	leaq	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.0(%rip), %rsi
	movq	%rsp, %rdi
	xorl	%r8d, %r8d
	callq	*_RNvNtCs9k3SxhrAWiO_3std2rt19lang_start_internal@GOTPCREL(%rip)
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end12:
	.size	main, .Lfunc_end12-main
	.cfi_endproc

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.0,@object
	.section	.data.rel.ro..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.0,"aw",@progbits
	.p2align	3, 0x0
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.0:
	.asciz	"\000\000\000\000\000\000\000\000\b\000\000\000\000\000\000\000\b\000\000\000\000\000\000"
	.quad	_RNSNvYNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0INtNtNtCsgxBkk5gSRhY_4core3ops8function6FnOnceuE9call_once6vtableCsep9IqgdOJhb_10loop_count
	.quad	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Csep9IqgdOJhb_10loop_count
	.quad	_RNCINvNtCs9k3SxhrAWiO_3std2rt10lang_startuE0Csep9IqgdOJhb_10loop_count
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.0, 48

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.1,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.1,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.1:
	.ascii	"--runs"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.1, 6

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.2,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.2,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.2:
	.ascii	"--runs needs a value"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.2, 20

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.3,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.3:
	.asciz	"bench/equivalents/rust/loop_count.rs"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.3, 37

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.4,@object
	.section	.data.rel.ro..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.4,"aw",@progbits
	.p2align	3, 0x0
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.4:
	.quad	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.3
	.asciz	"$\000\000\000\000\000\000\000$\000\000\000 \000\000"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.4, 24

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.5,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.5,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.5:
	.ascii	"--runs must be an integer"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.5, 25

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.6,@object
	.section	.data.rel.ro..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.6,"aw",@progbits
	.p2align	3, 0x0
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.6:
	.quad	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.3
	.asciz	"$\000\000\000\000\000\000\000$\000\000\000G\000\000"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.6, 24

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.7,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.7,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.7:
	.ascii	"i must be an integer"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.7, 20

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.8,@object
	.section	.data.rel.ro..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.8,"aw",@progbits
	.p2align	3, 0x0
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.8:
	.quad	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.3
	.asciz	"$\000\000\000\000\000\000\000)\000\000\0007\000\000"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.8, 24

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.9,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.9,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.9:
	.ascii	"total must be an integer"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.9, 24

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.10,@object
	.section	.data.rel.ro..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.10,"aw",@progbits
	.p2align	3, 0x0
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.10:
	.quad	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.3
	.asciz	"$\000\000\000\000\000\000\000*\000\000\000;\000\000"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.10, 24

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.11,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.11:
	.asciz	"\007value: \300\001\n"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.11, 12

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.12,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.12,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.12:
	.asciz	"\tbest_us: \305 \000\000p\003\000\001\n"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.12, 20

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.13,@object
	.section	.data.rel.ro..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.13,"aw",@progbits
	.p2align	3, 0x0
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.13:
	.asciz	"\000\000\000\000\000\000\000\000\001\000\000\000\000\000\000\000\001\000\000\000\000\000\000"
	.quad	_RNvXsd_NtNtCsgxBkk5gSRhY_4core3num5errorNtB5_13ParseIntErrorNtNtB9_3fmt5Debug3fmt
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.13, 32

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.14,@object
	.section	.data.rel.ro..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.14,"aw",@progbits
	.p2align	3, 0x0
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.14:
	.asciz	"\000\000\000\000\000\000\000\000\b\000\000\000\000\000\000\000\b\000\000\000\000\000\000"
	.quad	_RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.14, 32

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.15,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.15,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.15:
	.ascii	"ParseIntError"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.15, 13

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.16,@object
	.section	.rodata.cst4,"aM",@progbits,4
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.16:
	.ascii	"kind"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.16, 4

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.17,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.17,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.17:
	.ascii	"Empty"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.17, 5

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.18,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.18,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.18:
	.ascii	"InvalidDigit"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.18, 12

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.19,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.19,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.19:
	.ascii	"PosOverflow"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.19, 11

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.20,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.20,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.20:
	.ascii	"NegOverflow"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.20, 11

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.21,@object
	.section	.rodata.cst4,"aM",@progbits,4
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.21:
	.ascii	"Zero"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.21, 4

	.type	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.22,@object
	.section	.rodata..Lanon.f6ecaea0835c828386dad10e4e4ef5f3.22,"a",@progbits
.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.22:
	.ascii	"NotAPowerOfTwo"
	.size	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.22, 14

	.type	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count,@object
	.section	.rodata..Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count,"a",@progbits
	.p2align	3, 0x0
.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count:
	.quad	5
	.quad	12
	.quad	11
	.quad	11
	.quad	4
	.quad	14
	.size	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count, 48

	.type	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel,@object
	.section	.rodata..Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel,"a",@progbits
	.p2align	2, 0x0
.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel:
	.long	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.17-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel
	.long	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.18-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel
	.long	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.19-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel
	.long	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.20-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel
	.long	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.21-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel
	.long	.Lanon.f6ecaea0835c828386dad10e4e4ef5f3.22-.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel
	.size	.Lswitch.table._RNvXs1g_NtCsgxBkk5gSRhY_4core3fmtRNtNtNtB8_3num5error12IntErrorKindNtB6_5Debug3fmtCsep9IqgdOJhb_10loop_count.23.rel, 24

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

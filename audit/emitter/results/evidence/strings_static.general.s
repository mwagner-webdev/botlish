<botlish_fn_7>:
 720:	push   %rbp
 721:	mov    %rsp,%rbp
 724:	sub    $0xa0,%rsp
 72b:	mov    %rbx,0x70(%rsp)
 730:	mov    %r12,0x78(%rsp)
 735:	mov    %r13,0x80(%rsp)
 73d:	mov    %r14,0x88(%rsp)
 745:	mov    %r15,0x90(%rsp)
 74d:	mov    %rdi,0x50(%rsp)
 752:	mov    %rsi,0x58(%rsp)
 757:	movq   $0x0,(%rsp)
 75f:	movq   $0x0,0x8(%rsp)
 768:	movq   $0x0,0x10(%rsp)
 771:	movq   $0x0,0x18(%rsp)
 77a:	movq   $0x0,0x20(%rsp)
 783:	movq   $0x0,0x28(%rsp)
 78c:	movq   $0x0,0x30(%rsp)
 795:	mov    0x50(%rsp),%rdi
 79a:	call   79f <botlish_fn_7+0x7f>
			79b: R_X86_64_PLT32	botlish_fn_6-0x4
 79f:	test   %rax,%rax
 7a2:	je     c28 <botlish_fn_7+0x508>
 7a8:	mov    %rax,(%rsp)
 7ac:	mov    %rax,%r13
 7af:	mov    $0x7,%esi
 7b4:	movq   $0x7,0x8(%rsp)
 7bd:	mov    $0x1,%edx
 7c2:	movq   $0x1,0x10(%rsp)
 7cb:	mov    0x50(%rsp),%rdi
 7d0:	call   7d5 <botlish_fn_7+0xb5>
			7d1: R_X86_64_PLT32	rt_mutarray_create-0x4
 7d5:	test   %rax,%rax
 7d8:	je     c28 <botlish_fn_7+0x508>
 7de:	mov    %rax,0x8(%rsp)
 7e3:	xor    %rbx,%rbx
 7e6:	mov    0x58(%rsp),%rcx
 7eb:	cmp    %rcx,%rbx
 7ee:	mov    %rcx,0x58(%rsp)
 7f3:	jl     86b <botlish_fn_7+0x14b>
 7f9:	mov    %rax,%r12
 7fc:	mov    0x10(%r12),%r9
 801:	mov    0x8(%r9),%r9
 805:	mov    %r9,(%rsp)
 809:	mov    0x10(%r12),%r10
 80e:	mov    (%r10),%r10
 811:	mov    %r10,0x8(%rsp)
 816:	lea    0x40(%rsp),%rdx
 81b:	mov    %r9,0x40(%rsp)
 820:	mov    %r10,0x48(%rsp)
 825:	mov    $0x2,%esi
 82a:	mov    0x50(%rsp),%rdi
 82f:	call   834 <botlish_fn_7+0x114>
			830: R_X86_64_PLT32	rt_list_new-0x4
 834:	test   %rax,%rax
 837:	je     c28 <botlish_fn_7+0x508>
 83d:	mov    0x70(%rsp),%rbx
 842:	mov    0x78(%rsp),%r12
 847:	mov    0x80(%rsp),%r13
 84f:	mov    0x88(%rsp),%r14
 857:	mov    0x90(%rsp),%r15
 85f:	add    $0xa0,%rsp
 866:	mov    %rbp,%rsp
 869:	pop    %rbp
 86a:	ret
 86b:	mov    %rax,%r12
 86e:	mov    %r13,%r14
 871:	mov    0x8(%r14),%rcx
 875:	mov    %rbx,%rax
 878:	and    $0x7,%rax
 87c:	shl    $1,%rax
 87f:	or     $0x1,%rax
 883:	sar    $1,%rax
 886:	cmp    %rcx,%rax
 889:	jb     8b8 <botlish_fn_7+0x198>
 88f:	mov    %rbx,%rdx
 892:	and    $0x7,%rdx
 896:	shl    $1,%rdx
 899:	or     $0x1,%rdx
 89d:	mov    %r14,%rsi
 8a0:	mov    0x50(%rsp),%rdi
 8a5:	call   8aa <botlish_fn_7+0x18a>
			8a6: R_X86_64_PLT32	rt_list_get-0x4
 8aa:	test   %rax,%rax
 8ad:	je     c28 <botlish_fn_7+0x508>
 8b3:	jmp    8c0 <botlish_fn_7+0x1a0>
 8b8:	mov    0x10(%r14),%rcx
 8bc:	mov    (%rcx,%rax,8),%rax
 8c0:	mov    %rax,0x10(%rsp)
 8c5:	lea    0x38(%rsp),%r8
 8ca:	mov    %rax,0x38(%rsp)
 8cf:	mov    $0x8,%esi
 8d4:	mov    0x0(%rip),%rdx        # 8db <botlish_fn_7+0x1bb>
			8d7: R_X86_64_GOTPCREL	botlish_entry_8-0x4
 8db:	mov    $0x1,%ecx
 8e0:	mov    0x50(%rsp),%rdi
 8e5:	call   8ea <botlish_fn_7+0x1ca>
			8e6: R_X86_64_PLT32	rt_closure_new-0x4
 8ea:	mov    %rax,0x10(%rsp)
 8ef:	mov    %rax,%rsi
 8f2:	mov    0x50(%rsp),%rdi
 8f7:	call   8fc <botlish_fn_7+0x1dc>
			8f8: R_X86_64_PLT32	rt_co_create-0x4
 8fc:	mov    %rax,0x68(%rsp)
 901:	mov    %rax,0x10(%rsp)
 906:	mov    0x68(%rsp),%rsi
 90b:	mov    0x50(%rsp),%rdi
 910:	call   915 <botlish_fn_7+0x1f5>
			911: R_X86_64_PLT32	rt_co_start-0x4
 915:	test   %rax,%rax
 918:	mov    %rax,%rcx
 91b:	jne    94b <botlish_fn_7+0x22b>
 921:	mov    0x50(%rsp),%rdi
 926:	call   92b <botlish_fn_7+0x20b>
			927: R_X86_64_PLT32	rt_declared_error-0x4
 92b:	cmp    $0x40000001,%rax
 931:	jne    c28 <botlish_fn_7+0x508>
 937:	mov    0x68(%rsp),%rsi
 93c:	mov    0x50(%rsp),%rdi
 941:	call   946 <botlish_fn_7+0x226>
			942: R_X86_64_PLT32	rt_co_release-0x4
 946:	jmp    c28 <botlish_fn_7+0x508>
 94b:	mov    0x18(%r12),%rax
 950:	test   %rax,%rax
 953:	je     c9b <botlish_fn_7+0x57b>
 959:	mov    0x10(%r12),%rax
 95e:	mov    %rcx,0x10(%rax)
 962:	mov    $0x3,%r15d
 968:	mov    $0x7fffffff,%eax
 96d:	mov    %rax,%r13
 970:	neg    %r13
 973:	cmovs  %rax,%r13
 977:	mov    0x68(%rsp),%rsi
 97c:	mov    0x50(%rsp),%rdi
 981:	call   986 <botlish_fn_7+0x266>
			982: R_X86_64_PLT32	rt_co_done-0x4
 986:	cmp    $0x6,%rax
 98a:	je     c75 <botlish_fn_7+0x555>
 990:	movq   $0x1,0x18(%rsp)
 999:	mov    0x10(%r12),%rax
 99e:	mov    (%rax),%rsi
 9a1:	mov    %rsi,0x20(%rsp)
 9a6:	mov    0x10(%r12),%rax
 9ab:	mov    0x10(%rax),%rdx
 9af:	mov    %rdx,0x28(%rsp)
 9b4:	mov    %rdx,0x60(%rsp)
 9b9:	movq   $0x3f,0x30(%rsp)
 9c2:	test   $0x1,%rsi
 9c9:	je     9f3 <botlish_fn_7+0x2d3>
 9cf:	mov    %rsi,%rax
 9d2:	sar    $1,%rax
 9d5:	imulq  0x31c(%rip)        # cf8 <botlish_fn_7+0x5d8>
 9dc:	seto   %cl
 9df:	or     $0x1,%rax
 9e3:	test   %cl,%cl
 9e5:	jne    9f3 <botlish_fn_7+0x2d3>
 9eb:	mov    %rax,%rsi
 9ee:	jmp    a05 <botlish_fn_7+0x2e5>
 9f3:	mov    $0x3f,%edx
 9f8:	mov    0x50(%rsp),%rdi
 9fd:	call   a02 <botlish_fn_7+0x2e2>
			9fe: R_X86_64_PLT32	rt_int_mul-0x4
 a02:	mov    %rax,%rsi
 a05:	mov    %rsi,0x20(%rsp)
 a0a:	mov    0x60(%rsp),%rdx
 a0f:	mov    %rsi,%rax
 a12:	and    %rdx,%rax
 a15:	test   $0x1,%rax
 a1b:	je     a36 <botlish_fn_7+0x316>
 a21:	lea    -0x1(%rdx),%rax
 a25:	mov    %rsi,%r11
 a28:	add    %rax,%r11
 a2b:	seto   %cl
 a2e:	test   %cl,%cl
 a30:	je     a43 <botlish_fn_7+0x323>
 a36:	mov    0x50(%rsp),%rdi
 a3b:	call   a40 <botlish_fn_7+0x320>
			a3c: R_X86_64_PLT32	rt_int_add-0x4
 a40:	mov    %rax,%r11
 a43:	mov    %r11,0x20(%rsp)
 a48:	movq   $0x3,0x28(%rsp)
 a51:	test   $0x1,%r11
 a58:	jne    a66 <botlish_fn_7+0x346>
 a5e:	mov    %r11,%rsi
 a61:	jmp    a80 <botlish_fn_7+0x360>
 a66:	mov    %r11,%rsi
 a69:	add    $0x2,%rsi
 a6d:	mov    %r11,%r10
 a70:	seto   %r11b
 a74:	test   %r11b,%r11b
 a77:	je     a90 <botlish_fn_7+0x370>
 a7d:	mov    %r10,%rsi
 a80:	mov    %r15,%rdx
 a83:	mov    0x50(%rsp),%rdi
 a88:	call   a8d <botlish_fn_7+0x36d>
			a89: R_X86_64_PLT32	rt_int_add-0x4
 a8d:	mov    %rax,%rsi
 a90:	mov    %rsi,0x20(%rsp)
 a95:	mov    $0xffffffff,%eax
 a9a:	mov    %rax,0x28(%rsp)
 a9f:	test   $0x1,%rsi
 aa6:	jne    af6 <botlish_fn_7+0x3d6>
 aac:	mov    $0xffffffff,%edx
 ab1:	mov    0x50(%rsp),%rdi
 ab6:	call   abb <botlish_fn_7+0x39b>
			ab7: R_X86_64_PLT32	rt_int_mod-0x4
 abb:	test   %rax,%rax
 abe:	jne    aee <botlish_fn_7+0x3ce>
 ac4:	mov    0x50(%rsp),%rdi
 ac9:	call   ace <botlish_fn_7+0x3ae>
			aca: R_X86_64_PLT32	rt_declared_error-0x4
 ace:	cmp    $0x40000001,%rax
 ad4:	jne    c28 <botlish_fn_7+0x508>
 ada:	mov    0x68(%rsp),%rsi
 adf:	mov    0x50(%rsp),%rdi
 ae4:	call   ae9 <botlish_fn_7+0x3c9>
			ae5: R_X86_64_PLT32	rt_co_release-0x4
 ae9:	jmp    c28 <botlish_fn_7+0x508>
 aee:	mov    %rax,%rcx
 af1:	jmp    b34 <botlish_fn_7+0x414>
 af6:	sar    $1,%rsi
 af9:	mov    %rsi,%rax
 afc:	imulq  0x1fd(%rip)        # d00 <botlish_fn_7+0x5e0>
 b03:	lea    (%rdx,%rsi,1),%rax
 b07:	sar    $0x1e,%rax
 b0b:	mov    %rax,%rcx
 b0e:	shr    $0x3f,%rcx
 b12:	add    %rcx,%rax
 b15:	imul   $0x7fffffff,%rax,%rax
 b1c:	sub    %rax,%rsi
 b1f:	lea    (%rsi,%r13,1),%rax
 b23:	test   %rsi,%rsi
 b26:	cmovl  %rax,%rsi
 b2a:	shl    $1,%rsi
 b2d:	or     $0x1,%rsi
 b31:	mov    %rsi,%rcx
 b34:	mov    0x18(%r12),%rax
 b39:	test   %rax,%rax
 b3c:	je     cb2 <botlish_fn_7+0x592>
 b42:	mov    0x10(%r12),%rax
 b47:	mov    %rcx,(%rax)
 b4a:	movq   $0x3,0x18(%rsp)
 b53:	mov    0x10(%r12),%rax
 b58:	mov    0x8(%rax),%rsi
 b5c:	mov    %rsi,0x20(%rsp)
 b61:	movq   $0x3,0x28(%rsp)
 b6a:	test   $0x1,%rsi
 b71:	je     b89 <botlish_fn_7+0x469>
 b77:	mov    %rsi,%rcx
 b7a:	add    $0x2,%rcx
 b7e:	seto   %al
 b81:	test   %al,%al
 b83:	je     b99 <botlish_fn_7+0x479>
 b89:	mov    %r15,%rdx
 b8c:	mov    0x50(%rsp),%rdi
 b91:	call   b96 <botlish_fn_7+0x476>
			b92: R_X86_64_PLT32	rt_int_add-0x4
 b96:	mov    %rax,%rcx
 b99:	mov    0x18(%r12),%rax
 b9e:	test   %rax,%rax
 ba1:	je     cc9 <botlish_fn_7+0x5a9>
 ba7:	mov    0x10(%r12),%rax
 bac:	mov    %rcx,0x8(%rax)
 bb0:	mov    $0x5,%edx
 bb5:	mov    %rdx,0x60(%rsp)
 bba:	movq   $0x5,0x18(%rsp)
 bc3:	mov    0x68(%rsp),%rsi
 bc8:	mov    0x50(%rsp),%rdi
 bcd:	call   bd2 <botlish_fn_7+0x4b2>
			bce: R_X86_64_PLT32	rt_co_resume0-0x4
 bd2:	test   %rax,%rax
 bd5:	mov    %rax,%rcx
 bd8:	jne    c59 <botlish_fn_7+0x539>
 bde:	mov    0x50(%rsp),%rdi
 be3:	call   be8 <botlish_fn_7+0x4c8>
			be4: R_X86_64_PLT32	rt_declared_error-0x4
 be8:	cmp    $0x40000001,%rax
 bee:	jne    c03 <botlish_fn_7+0x4e3>
 bf4:	mov    0x68(%rsp),%rsi
 bf9:	mov    0x50(%rsp),%rdi
 bfe:	call   c03 <botlish_fn_7+0x4e3>
			bff: R_X86_64_PLT32	rt_co_release-0x4
 c03:	mov    0x50(%rsp),%rdi
 c08:	call   c0d <botlish_fn_7+0x4ed>
			c09: R_X86_64_PLT32	rt_declared_error-0x4
 c0d:	cmp    $0x40000001,%rax
 c13:	jne    c28 <botlish_fn_7+0x508>
 c19:	mov    0x68(%rsp),%rsi
 c1e:	mov    0x50(%rsp),%rdi
 c23:	call   c28 <botlish_fn_7+0x508>
			c24: R_X86_64_PLT32	rt_co_release-0x4
 c28:	xor    %rax,%rax
 c2b:	mov    0x70(%rsp),%rbx
 c30:	mov    0x78(%rsp),%r12
 c35:	mov    0x80(%rsp),%r13
 c3d:	mov    0x88(%rsp),%r14
 c45:	mov    0x90(%rsp),%r15
 c4d:	add    $0xa0,%rsp
 c54:	mov    %rbp,%rsp
 c57:	pop    %rbp
 c58:	ret
 c59:	mov    0x18(%r12),%rdx
 c5e:	test   %rdx,%rdx
 c61:	je     cde <botlish_fn_7+0x5be>
 c67:	mov    0x10(%r12),%rsi
 c6c:	mov    %rcx,0x10(%rsi)
 c70:	jmp    977 <botlish_fn_7+0x257>
 c75:	mov    0x68(%rsp),%rsi
 c7a:	mov    0x50(%rsp),%rdi
 c7f:	call   c84 <botlish_fn_7+0x564>
			c80: R_X86_64_PLT32	rt_co_release-0x4
 c84:	add    $0x1,%rbx
 c8b:	mov    %r12,%rax
 c8e:	mov    0x58(%rsp),%rcx
 c93:	mov    %r14,%r13
 c96:	jmp    7eb <botlish_fn_7+0xcb>
 c9b:	mov    $0x5,%edx
 ca0:	mov    %r12,%rsi
 ca3:	mov    0x50(%rsp),%rdi
 ca8:	call   cad <botlish_fn_7+0x58d>
			ca9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 cad:	jmp    962 <botlish_fn_7+0x242>
 cb2:	mov    $0x1,%edx
 cb7:	mov    %r12,%rsi
 cba:	mov    0x50(%rsp),%rdi
 cbf:	call   cc4 <botlish_fn_7+0x5a4>
			cc0: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 cc4:	jmp    b4a <botlish_fn_7+0x42a>
 cc9:	mov    %r15,%rdx
 ccc:	mov    %r12,%rsi
 ccf:	mov    0x50(%rsp),%rdi
 cd4:	call   cd9 <botlish_fn_7+0x5b9>
			cd5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 cd9:	jmp    bb0 <botlish_fn_7+0x490>
 cde:	mov    0x60(%rsp),%rdx
 ce3:	mov    %r12,%rsi
 ce6:	mov    0x50(%rsp),%rdi
 ceb:	call   cf0 <botlish_fn_7+0x5d0>
			cec: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 cf0:	jmp    977 <botlish_fn_7+0x257>
 cf5:	add    %al,(%rax)
 cf7:	add    %bh,(%rsi)
 cf9:	add    %al,(%rax)
 cfb:	add    %al,(%rax)
 cfd:	add    %al,(%rax)
 cff:	add    %al,(%rbx)
 d01:	add    %al,(%rax)
 d03:	add    %al,(%rcx)
 d05:	add    %al,(%rax)
 d07:	.byte 0x80

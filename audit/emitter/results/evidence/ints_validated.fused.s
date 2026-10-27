<botlish_fn_7>:
     6d0:	push   %rbp
     6d1:	mov    %rsp,%rbp
     6d4:	sub    $0x250,%rsp
     6db:	mov    %rbx,0x220(%rsp)
     6e3:	mov    %r12,0x228(%rsp)
     6eb:	mov    %r13,0x230(%rsp)
     6f3:	mov    %r14,0x238(%rsp)
     6fb:	mov    %r15,0x240(%rsp)
     703:	mov    %rdi,0x1a0(%rsp)
     70b:	mov    %rsi,0x1a8(%rsp)
     713:	movq   $0x0,0x10(%rsp)
     71c:	movq   $0x0,0x18(%rsp)
     725:	movq   $0x0,0x20(%rsp)
     72e:	movq   $0x0,0x28(%rsp)
     737:	movq   $0x0,0x30(%rsp)
     740:	movq   $0x0,0x38(%rsp)
     749:	movq   $0x0,0x40(%rsp)
     752:	movq   $0x0,0x48(%rsp)
     75b:	movq   $0x0,0x50(%rsp)
     764:	mov    $0x7,%esi
     769:	movq   $0x7,(%rsp)
     771:	mov    $0x1,%edx
     776:	movq   $0x1,0x8(%rsp)
     77f:	mov    0x1a0(%rsp),%rdi
     787:	call   78c <botlish_fn_7+0xbc>
			788: R_X86_64_PLT32	rt_mutarray_create-0x4
     78c:	test   %rax,%rax
     78f:	je     1db9 <botlish_fn_7+0x16e9>
     795:	mov    %rax,(%rsp)
     799:	mov    %rax,%rdx
     79c:	xor    %rcx,%rcx
     79f:	mov    %rcx,0x1e8(%rsp)
     7a7:	mov    0x1a8(%rsp),%rax
     7af:	cmp    %rax,%rcx
     7b2:	mov    %rax,0x1a8(%rsp)
     7ba:	jl     844 <botlish_fn_7+0x174>
     7c0:	mov    %rdx,%r12
     7c3:	mov    0x10(%r12),%rsi
     7c8:	mov    0x8(%rsi),%rsi
     7cc:	mov    %rsi,0x8(%rsp)
     7d1:	mov    0x10(%r12),%rdi
     7d6:	mov    (%rdi),%rdi
     7d9:	mov    %rdi,(%rsp)
     7dd:	lea    0x118(%rsp),%rdx
     7e5:	mov    %rsi,0x118(%rsp)
     7ed:	mov    %rdi,0x120(%rsp)
     7f5:	mov    $0x2,%esi
     7fa:	mov    0x1a0(%rsp),%rdi
     802:	call   807 <botlish_fn_7+0x137>
			803: R_X86_64_PLT32	rt_list_new-0x4
     807:	test   %rax,%rax
     80a:	je     1db9 <botlish_fn_7+0x16e9>
     810:	mov    0x220(%rsp),%rbx
     818:	mov    0x228(%rsp),%r12
     820:	mov    0x230(%rsp),%r13
     828:	mov    0x238(%rsp),%r14
     830:	mov    0x240(%rsp),%r15
     838:	add    $0x250,%rsp
     83f:	mov    %rbp,%rsp
     842:	pop    %rbp
     843:	ret
     844:	mov    %rdx,%r12
     847:	mov    %rcx,%rsi
     84a:	shl    $1,%rsi
     84d:	mov    %rcx,0x1e8(%rsp)
     855:	or     $0x1,%rsi
     859:	mov    %rsi,0x8(%rsp)
     85e:	mov    0x1a0(%rsp),%rdi
     866:	call   86b <botlish_fn_7+0x19b>
			867: R_X86_64_PLT32	botlish_fn_6-0x4
     86b:	test   %rax,%rax
     86e:	je     1db9 <botlish_fn_7+0x16e9>
     874:	movq   $0xa,0x38(%rsp)
     87d:	movq   $0xa,0x28(%rsp)
     886:	movq   $0xa,0x30(%rsp)
     88f:	mov    %rax,0x8(%rsp)
     894:	mov    %rax,%rsi
     897:	mov    0x1a0(%rsp),%rdi
     89f:	call   8a4 <botlish_fn_7+0x1d4>
			8a0: R_X86_64_PLT32	rt_int_to_str-0x4
     8a4:	mov    %rax,0x218(%rsp)
     8ac:	mov    %rax,0x38(%rsp)
     8b1:	mov    0x8(%rax),%rcx
     8b5:	shl    $1,%rcx
     8b8:	or     $0x1,%rcx
     8bc:	sar    $1,%rcx
     8bf:	test   %rcx,%rcx
     8c2:	mov    %rcx,0x210(%rsp)
     8ca:	jg     8e8 <botlish_fn_7+0x218>
     8d0:	mov    $0xffffffffffffffff,%rsi
     8d7:	movq   $0xffffffffffffffff,0x28(%rsp)
     8e0:	mov    %rsi,%r13
     8e3:	jmp    94b <botlish_fn_7+0x27b>
     8e8:	mov    0x218(%rsp),%rax
     8f0:	movzbq 0x18(%rax),%rax
     8f5:	test   %rax,%rax
     8f8:	jne    920 <botlish_fn_7+0x250>
     8fe:	mov    $0x1,%edx
     903:	mov    0x218(%rsp),%rsi
     90b:	mov    0x1a0(%rsp),%rdi
     913:	call   918 <botlish_fn_7+0x248>
			914: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     918:	mov    %rax,%rsi
     91b:	jmp    935 <botlish_fn_7+0x265>
     920:	mov    0x218(%rsp),%rax
     928:	movzbq 0x19(%rax),%rsi
     92d:	shl    $0x3,%rsi
     931:	or     $0x4,%rsi
     935:	shr    $0x3,%rsi
     939:	mov    $0x1,%r13d
     93f:	shl    $1,%rsi
     942:	or     $0x1,%rsi
     946:	mov    %rsi,0x28(%rsp)
     94b:	movq   $0xa,0x50(%rsp)
     954:	movq   $0xa,0x40(%rsp)
     95d:	movq   $0xa,0x48(%rsp)
     966:	mov    %rsi,%r15
     969:	mov    %rsi,0x1d8(%rsp)
     971:	mov    0x1a0(%rsp),%rdi
     979:	mov    0x10(%rdi),%rax
     97d:	mov    0xa0(%rax),%rbx
     984:	test   $0x1,%rsi
     98b:	mov    %rsi,%r14
     98e:	jne    9c0 <botlish_fn_7+0x2f0>
     994:	mov    $0xffffffffffffffff,%rdx
     99b:	mov    %r14,%rsi
     99e:	mov    0x1a0(%rsp),%rdi
     9a6:	call   9ab <botlish_fn_7+0x2db>
			9a7: R_X86_64_PLT32	rt_int_cmp-0x4
     9ab:	mov    $0x2,%ecx
     9b0:	test   %rax,%rax
     9b3:	cmovl  0x14ad(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     9bb:	jmp    9d4 <botlish_fn_7+0x304>
     9c0:	mov    $0x2,%ecx
     9c5:	mov    %r14,%rsi
     9c8:	cmp    $0xffffffffffffffff,%rsi
     9cc:	cmovl  0x1494(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     9d4:	mov    $0x6,%r8d
     9da:	mov    %r8,0x1f0(%rsp)
     9e2:	cmp    $0x6,%rcx
     9e6:	je     a5b <botlish_fn_7+0x38b>
     9ec:	mov    %r14,%rsi
     9ef:	test   $0x1,%rsi
     9f6:	jne    a26 <botlish_fn_7+0x356>
     9fc:	mov    $0x1ff,%edx
     a01:	mov    %r14,%rsi
     a04:	mov    0x1a0(%rsp),%rdi
     a0c:	call   a11 <botlish_fn_7+0x341>
			a0d: R_X86_64_PLT32	rt_int_cmp-0x4
     a11:	mov    $0x2,%ecx
     a16:	test   %rax,%rax
     a19:	cmovg  0x1447(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     a21:	jmp    a3d <botlish_fn_7+0x36d>
     a26:	mov    $0x2,%ecx
     a2b:	mov    %r14,%rsi
     a2e:	cmp    $0x1ff,%rsi
     a35:	cmovg  0x142b(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     a3d:	cmp    $0x6,%rcx
     a41:	je     a5b <botlish_fn_7+0x38b>
     a47:	mov    %r14,%rsi
     a4a:	mov    %rsi,%rax
     a4d:	sar    $1,%rax
     a50:	movzbq 0x11(%rbx,%rax,1),%rsi
     a56:	jmp    a63 <botlish_fn_7+0x393>
     a5b:	movzbq 0x919(%rbx),%rsi
     a63:	mov    %rsi,%rcx
     a66:	shl    $1,%rcx
     a69:	or     $0x1,%rcx
     a6d:	mov    $0x2,%r9d
     a73:	cmp    $0x13,%rcx
     a77:	cmovl  0x13e9(%rip),%r9        # 1e68 <botlish_fn_7+0x1798>
     a7f:	cmp    $0x6,%r9
     a83:	je     df5 <botlish_fn_7+0x725>
     a89:	mov    %rsi,%rdi
     a8c:	shl    $1,%rdi
     a8f:	mov    %rsi,0x1b8(%rsp)
     a97:	or     $0x1,%rdi
     a9b:	mov    $0x2,%eax
     aa0:	cmp    $0x13,%rdi
     aa4:	cmove  0x13bc(%rip),%rax        # 1e68 <botlish_fn_7+0x1798>
     aac:	cmp    $0x6,%rax
     ab0:	je     d66 <botlish_fn_7+0x696>
     ab6:	mov    %r14,%rsi
     ab9:	test   $0x1,%rsi
     ac0:	jne    af2 <botlish_fn_7+0x422>
     ac6:	mov    $0xffffffffffffffff,%rdx
     acd:	mov    %r14,%rsi
     ad0:	mov    0x1a0(%rsp),%rdi
     ad8:	call   add <botlish_fn_7+0x40d>
			ad9: R_X86_64_PLT32	rt_int_cmp-0x4
     add:	mov    $0x2,%ecx
     ae2:	test   %rax,%rax
     ae5:	cmove  0x137b(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     aed:	jmp    b06 <botlish_fn_7+0x436>
     af2:	mov    $0x2,%ecx
     af7:	mov    %r14,%rsi
     afa:	cmp    $0xffffffffffffffff,%rsi
     afe:	cmove  0x1362(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     b06:	cmp    $0x6,%rcx
     b0a:	je     b89 <botlish_fn_7+0x4b9>
     b10:	mov    0x1a0(%rsp),%rdi
     b18:	mov    0x10(%rdi),%rax
     b1c:	mov    0x90(%rax),%rbx
     b23:	mov    $0x1,%r12d
     b29:	mov    0x1b8(%rsp),%rsi
     b31:	shl    $1,%rsi
     b34:	or     $0x1,%rsi
     b38:	call   b3d <botlish_fn_7+0x46d>
			b39: R_X86_64_PLT32	botlish_fn_1-0x4
     b3d:	mov    0x1a0(%rsp),%rdi
     b45:	mov    0x10(%rdi),%rcx
     b49:	mov    0xc0(%rcx),%rdx
     b50:	lea    0x138(%rsp),%r9
     b58:	mov    %rbx,0x138(%rsp)
     b60:	mov    %rax,0x140(%rsp)
     b68:	mov    %r14,%rsi
     b6b:	mov    %rsi,0x148(%rsp)
     b73:	mov    $0x3,%r8d
     b79:	mov    %r12,%rsi
     b7c:	mov    %r8,%rcx
     b7f:	call   b84 <botlish_fn_7+0x4b4>
			b80: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     b84:	jmp    bec <botlish_fn_7+0x51c>
     b89:	mov    0x1b8(%rsp),%rsi
     b91:	mov    0x1a0(%rsp),%rdi
     b99:	mov    0x10(%rdi),%rax
     b9d:	mov    0x90(%rax),%rbx
     ba4:	shl    $1,%rsi
     ba7:	or     $0x1,%rsi
     bab:	call   bb0 <botlish_fn_7+0x4e0>
			bac: R_X86_64_PLT32	botlish_fn_1-0x4
     bb0:	mov    0x1a0(%rsp),%rdi
     bb8:	mov    0x10(%rdi),%rcx
     bbc:	mov    0xb8(%rcx),%rdx
     bc3:	lea    0x128(%rsp),%r9
     bcb:	mov    %rbx,0x128(%rsp)
     bd3:	mov    %rax,0x130(%rsp)
     bdb:	mov    $0x2,%r8d
     be1:	mov    %r8,%rcx
     be4:	mov    %r8,%rsi
     be7:	call   bec <botlish_fn_7+0x51c>
			be8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     bec:	mov    0x1a0(%rsp),%rdi
     bf4:	call   bf9 <botlish_fn_7+0x529>
			bf5: R_X86_64_PLT32	rt_co_failed-0x4
     bf9:	mov    %rax,0x48(%rsp)
     bfe:	mov    %rax,%rsi
     c01:	mov    0x1a0(%rsp),%rdi
     c09:	call   c0e <botlish_fn_7+0x53e>
			c0a: R_X86_64_PLT32	rt_co_resume0-0x4
     c0e:	test   %rax,%rax
     c11:	je     c33 <botlish_fn_7+0x563>
     c17:	mov    0x1a0(%rsp),%rdi
     c1f:	mov    0x10(%rdi),%rax
     c23:	mov    0x48(%rax),%rsi
     c27:	mov    0x80(%rax),%rdx
     c2e:	call   c33 <botlish_fn_7+0x563>
			c2f: R_X86_64_PLT32	rt_raise-0x4
     c33:	mov    0x1a0(%rsp),%rdi
     c3b:	call   c40 <botlish_fn_7+0x570>
			c3c: R_X86_64_PLT32	rt_declared_error-0x4
     c40:	cmp    $0x1,%rax
     c44:	je     ce5 <botlish_fn_7+0x615>
     c4a:	mov    0x1a0(%rsp),%rdi
     c52:	call   c57 <botlish_fn_7+0x587>
			c53: R_X86_64_PLT32	rt_declared_error-0x4
     c57:	cmp    $0x2,%rax
     c5b:	jne    1db9 <botlish_fn_7+0x16e9>
     c61:	xor    %rbx,%rbx
     c64:	mov    %rbx,%rsi
     c67:	mov    0x1a0(%rsp),%rdi
     c6f:	call   c74 <botlish_fn_7+0x5a4>
			c70: R_X86_64_PLT32	rt_declared_payload-0x4
     c74:	mov    %rax,%r12
     c77:	mov    $0x1,%esi
     c7c:	mov    0x1a0(%rsp),%rdi
     c84:	call   c89 <botlish_fn_7+0x5b9>
			c85: R_X86_64_PLT32	rt_declared_payload-0x4
     c89:	mov    %rax,%r13
     c8c:	mov    0x1a0(%rsp),%rdi
     c94:	call   c99 <botlish_fn_7+0x5c9>
			c95: R_X86_64_PLT32	rt_clear_declared_error-0x4
     c99:	mov    0x1a0(%rsp),%rdi
     ca1:	mov    0x10(%rdi),%rax
     ca5:	mov    0x88(%rax),%rdx
     cac:	lea    0x70(%rsp),%r9
     cb1:	movq   $0x1,0x70(%rsp)
     cba:	mov    %r12,%rax
     cbd:	mov    %rax,0x78(%rsp)
     cc2:	mov    %r13,%rax
     cc5:	mov    %rax,0x80(%rsp)
     ccd:	mov    $0xc,%esi
     cd2:	mov    $0x3,%r8d
     cd8:	mov    %rbx,%rcx
     cdb:	call   ce0 <botlish_fn_7+0x610>
			cdc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     ce0:	jmp    1db9 <botlish_fn_7+0x16e9>
     ce5:	xor    %rbx,%rbx
     ce8:	mov    %rbx,%rsi
     ceb:	mov    0x1a0(%rsp),%rdi
     cf3:	call   cf8 <botlish_fn_7+0x628>
			cf4: R_X86_64_PLT32	rt_declared_payload-0x4
     cf8:	mov    %rax,%r12
     cfb:	mov    $0x1,%esi
     d00:	mov    0x1a0(%rsp),%rdi
     d08:	call   d0d <botlish_fn_7+0x63d>
			d09: R_X86_64_PLT32	rt_declared_payload-0x4
     d0d:	mov    %rax,%r13
     d10:	mov    0x1a0(%rsp),%rdi
     d18:	call   d1d <botlish_fn_7+0x64d>
			d19: R_X86_64_PLT32	rt_clear_declared_error-0x4
     d1d:	mov    0x1a0(%rsp),%rdi
     d25:	mov    0x10(%rdi),%rax
     d29:	mov    0x88(%rax),%rdx
     d30:	lea    0x58(%rsp),%r9
     d35:	movq   $0x1,0x58(%rsp)
     d3e:	mov    %r12,%rax
     d41:	mov    %rax,0x60(%rsp)
     d46:	mov    %r13,%rax
     d49:	mov    %rax,0x68(%rsp)
     d4e:	mov    $0xc,%esi
     d53:	mov    $0x3,%r8d
     d59:	mov    %rbx,%rcx
     d5c:	call   d61 <botlish_fn_7+0x691>
			d5d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     d61:	jmp    1db9 <botlish_fn_7+0x16e9>
     d66:	mov    %r14,%rsi
     d69:	test   $0x1,%rsi
     d70:	jne    da0 <botlish_fn_7+0x6d0>
     d76:	mov    $0x1,%edx
     d7b:	mov    %r14,%rsi
     d7e:	mov    0x1a0(%rsp),%rdi
     d86:	call   d8b <botlish_fn_7+0x6bb>
			d87: R_X86_64_PLT32	rt_int_cmp-0x4
     d8b:	mov    $0x2,%ecx
     d90:	test   %rax,%rax
     d93:	cmovge 0x10cd(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     d9b:	jmp    db6 <botlish_fn_7+0x6e6>
     da0:	mov    $0x2,%ecx
     da5:	mov    %r14,%rsi
     da8:	mov    %r14,%r11
     dab:	test   %r11,%rsi
     dae:	cmovg  0x10b2(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
     db6:	cmp    $0x6,%rcx
     dba:	je     dca <botlish_fn_7+0x6fa>
     dc0:	mov    $0x1,%eax
     dc5:	jmp    dcf <botlish_fn_7+0x6ff>
     dca:	mov    $0x3,%eax
     dcf:	mov    %rax,0x40(%rsp)
     dd4:	mov    $0xffffffffffffffff,%rbx
     ddb:	mov    $0xa,%esi
     de0:	mov    %rsi,0x1b8(%rsp)
     de8:	mov    %rax,0x1c0(%rsp)
     df0:	jmp    e27 <botlish_fn_7+0x757>
     df5:	shl    $1,%rsi
     df8:	or     $0x1,%rsi
     dfc:	mov    %rsi,0x50(%rsp)
     e01:	mov    %rsi,0x1b8(%rsp)
     e09:	mov    $0x1,%eax
     e0e:	mov    %rax,0x1c0(%rsp)
     e16:	movq   $0x1,0x40(%rsp)
     e1f:	mov    0x1c0(%rsp),%rbx
     e27:	mov    0x18(%r12),%rdx
     e2c:	test   %rdx,%rdx
     e2f:	je     1df0 <botlish_fn_7+0x1720>
     e35:	mov    %r15,%rcx
     e38:	mov    0x10(%r12),%rsi
     e3d:	mov    %rcx,0x10(%rsi)
     e41:	xor    %r15,%r15
     e44:	mov    $0xffffffffffffffff,%rdx
     e4b:	mov    %rdx,0x208(%rsp)
     e53:	mov    $0x3,%r8d
     e59:	mov    %r8,0x200(%rsp)
     e61:	mov    $0x2,%r8d
     e67:	mov    %r8,0x1c8(%rsp)
     e6f:	mov    $0x7fffffff,%r8d
     e75:	mov    %r8,%r14
     e78:	neg    %r14
     e7b:	cmovs  %r8,%r14
     e7f:	mov    %r14,0x1f8(%rsp)
     e87:	test   %rbx,%rbx
     e8a:	jl     1d5f <botlish_fn_7+0x168f>
     e90:	movq   $0x1,0x8(%rsp)
     e99:	mov    0x10(%r12),%rax
     e9e:	mov    (%rax),%rsi
     ea1:	mov    %rsi,0x10(%rsp)
     ea6:	mov    0x10(%r12),%rax
     eab:	mov    0x10(%rax),%rdx
     eaf:	mov    %rdx,0x18(%rsp)
     eb4:	mov    %rdx,%r14
     eb7:	movq   $0x3f,0x20(%rsp)
     ec0:	test   $0x1,%rsi
     ec7:	je     ef1 <botlish_fn_7+0x821>
     ecd:	mov    %rsi,%rax
     ed0:	sar    $1,%rax
     ed3:	imulq  0xf96(%rip)        # 1e70 <botlish_fn_7+0x17a0>
     eda:	seto   %cl
     edd:	or     $0x1,%rax
     ee1:	test   %cl,%cl
     ee3:	jne    ef1 <botlish_fn_7+0x821>
     ee9:	mov    %rax,%rsi
     eec:	jmp    f06 <botlish_fn_7+0x836>
     ef1:	mov    $0x3f,%edx
     ef6:	mov    0x1a0(%rsp),%rdi
     efe:	call   f03 <botlish_fn_7+0x833>
			eff: R_X86_64_PLT32	rt_int_mul-0x4
     f03:	mov    %rax,%rsi
     f06:	mov    %rsi,0x10(%rsp)
     f0b:	mov    %r14,%rdx
     f0e:	mov    %rsi,%rax
     f11:	and    %rdx,%rax
     f14:	test   $0x1,%rax
     f1a:	je     f35 <botlish_fn_7+0x865>
     f20:	lea    -0x1(%rdx),%rcx
     f24:	mov    %rsi,%rax
     f27:	add    %rcx,%rax
     f2a:	seto   %cl
     f2d:	test   %cl,%cl
     f2f:	je     f42 <botlish_fn_7+0x872>
     f35:	mov    0x1a0(%rsp),%rdi
     f3d:	call   f42 <botlish_fn_7+0x872>
			f3e: R_X86_64_PLT32	rt_int_add-0x4
     f42:	mov    %rax,0x10(%rsp)
     f47:	movq   $0x3,0x18(%rsp)
     f50:	test   $0x1,%rax
     f56:	jne    f64 <botlish_fn_7+0x894>
     f5c:	mov    %rax,%rsi
     f5f:	jmp    f7c <botlish_fn_7+0x8ac>
     f64:	mov    %rax,%rsi
     f67:	add    $0x2,%rsi
     f6b:	mov    %rax,%rcx
     f6e:	seto   %al
     f71:	test   %al,%al
     f73:	je     f94 <botlish_fn_7+0x8c4>
     f79:	mov    %rcx,%rsi
     f7c:	mov    0x200(%rsp),%rdx
     f84:	mov    0x1a0(%rsp),%rdi
     f8c:	call   f91 <botlish_fn_7+0x8c1>
			f8d: R_X86_64_PLT32	rt_int_add-0x4
     f91:	mov    %rax,%rsi
     f94:	mov    %rsi,0x10(%rsp)
     f99:	mov    $0xffffffff,%eax
     f9e:	mov    %rax,0x18(%rsp)
     fa3:	test   $0x1,%rsi
     faa:	jne    ff1 <botlish_fn_7+0x921>
     fb0:	mov    $0xffffffff,%edx
     fb5:	mov    0x1a0(%rsp),%rdi
     fbd:	call   fc2 <botlish_fn_7+0x8f2>
			fbe: R_X86_64_PLT32	rt_int_mod-0x4
     fc2:	test   %rax,%rax
     fc5:	jne    fe9 <botlish_fn_7+0x919>
     fcb:	mov    0x1a0(%rsp),%rdi
     fd3:	call   fd8 <botlish_fn_7+0x908>
			fd4: R_X86_64_PLT32	rt_declared_error-0x4
     fd8:	cmp    $0x40000001,%rax
     fde:	jne    1db9 <botlish_fn_7+0x16e9>
     fe4:	jmp    1db9 <botlish_fn_7+0x16e9>
     fe9:	mov    %rax,%rcx
     fec:	jmp    1037 <botlish_fn_7+0x967>
     ff1:	sar    $1,%rsi
     ff4:	mov    %rsi,%rax
     ff7:	imulq  0xe7a(%rip)        # 1e78 <botlish_fn_7+0x17a8>
     ffe:	lea    (%rdx,%rsi,1),%rax
    1002:	sar    $0x1e,%rax
    1006:	mov    %rax,%rcx
    1009:	shr    $0x3f,%rcx
    100d:	add    %rcx,%rax
    1010:	imul   $0x7fffffff,%rax,%rax
    1017:	sub    %rax,%rsi
    101a:	mov    0x1f8(%rsp),%rcx
    1022:	lea    (%rsi,%rcx,1),%rax
    1026:	test   %rsi,%rsi
    1029:	cmovl  %rax,%rsi
    102d:	shl    $1,%rsi
    1030:	or     $0x1,%rsi
    1034:	mov    %rsi,%rcx
    1037:	mov    0x18(%r12),%rax
    103c:	test   %rax,%rax
    103f:	je     1e0d <botlish_fn_7+0x173d>
    1045:	mov    0x10(%r12),%rax
    104a:	mov    %rcx,(%rax)
    104d:	movq   $0x3,0x8(%rsp)
    1056:	mov    0x10(%r12),%rcx
    105b:	mov    0x8(%rcx),%rsi
    105f:	mov    %rsi,0x10(%rsp)
    1064:	movq   $0x3,0x18(%rsp)
    106d:	test   $0x1,%rsi
    1074:	je     108e <botlish_fn_7+0x9be>
    107a:	mov    %rsi,%rcx
    107d:	add    $0x2,%rcx
    1081:	seto   %r8b
    1085:	test   %r8b,%r8b
    1088:	je     10a6 <botlish_fn_7+0x9d6>
    108e:	mov    0x200(%rsp),%rdx
    1096:	mov    0x1a0(%rsp),%rdi
    109e:	call   10a3 <botlish_fn_7+0x9d3>
			109f: R_X86_64_PLT32	rt_int_add-0x4
    10a3:	mov    %rax,%rcx
    10a6:	mov    0x18(%r12),%rax
    10ab:	test   %rax,%rax
    10ae:	je     1e27 <botlish_fn_7+0x1757>
    10b4:	mov    0x10(%r12),%rax
    10b9:	mov    %rcx,0x8(%rax)
    10bd:	cmp    $0x1,%r13
    10c1:	je     1148 <botlish_fn_7+0xa78>
    10c7:	cmp    $0xffffffffffffffff,%r13
    10cb:	jne    10de <botlish_fn_7+0xa0e>
    10d1:	mov    0x218(%rsp),%r14
    10d9:	jmp    11ff <botlish_fn_7+0xb2f>
    10de:	mov    $0xa,%esi
    10e3:	mov    0x1a0(%rsp),%rdi
    10eb:	call   10f0 <botlish_fn_7+0xa20>
			10ec: R_X86_64_PLT32	rt_co_resume0-0x4
    10f0:	test   %rax,%rax
    10f3:	jne    1106 <botlish_fn_7+0xa36>
    10f9:	mov    0x1a0(%rsp),%rdi
    1101:	jmp    112a <botlish_fn_7+0xa5a>
    1106:	mov    0x1a0(%rsp),%rdi
    110e:	mov    0x10(%rdi),%rax
    1112:	mov    0x48(%rax),%rsi
    1116:	mov    0x80(%rax),%rdx
    111d:	call   1122 <botlish_fn_7+0xa52>
			111e: R_X86_64_PLT32	rt_raise-0x4
    1122:	mov    0x1a0(%rsp),%rdi
    112a:	mov    0x1a0(%rsp),%rdi
    1132:	call   1137 <botlish_fn_7+0xa67>
			1133: R_X86_64_PLT32	rt_declared_error-0x4
    1137:	cmp    $0x40000001,%rax
    113d:	jne    1db9 <botlish_fn_7+0x16e9>
    1143:	jmp    1db9 <botlish_fn_7+0x16e9>
    1148:	add    $0x1,%r15
    114f:	mov    0x210(%rsp),%rcx
    1157:	cmp    %rcx,%r15
    115a:	jl     118e <botlish_fn_7+0xabe>
    1160:	movq   $0xffffffffffffffff,0x28(%rsp)
    1169:	mov    0x208(%rsp),%r13
    1171:	mov    0x218(%rsp),%r14
    1179:	mov    0x208(%rsp),%rax
    1181:	mov    %rax,0x1d8(%rsp)
    1189:	jmp    11ff <botlish_fn_7+0xb2f>
    118e:	mov    0x218(%rsp),%r14
    1196:	movzbq 0x18(%r14),%rax
    119b:	test   %rax,%rax
    119e:	jne    11c6 <botlish_fn_7+0xaf6>
    11a4:	mov    %r15,%rdx
    11a7:	shl    $1,%rdx
    11aa:	or     $0x1,%rdx
    11ae:	mov    %r14,%rsi
    11b1:	mov    0x1a0(%rsp),%rdi
    11b9:	call   11be <botlish_fn_7+0xaee>
			11ba: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    11be:	mov    %rax,%rcx
    11c1:	jmp    11e1 <botlish_fn_7+0xb11>
    11c6:	mov    %r15,%rcx
    11c9:	shl    $1,%rcx
    11cc:	or     $0x1,%rcx
    11d0:	sar    $1,%rcx
    11d3:	movzbq 0x19(%r14,%rcx,1),%rcx
    11d9:	shl    $0x3,%rcx
    11dd:	or     $0x4,%rcx
    11e1:	shr    $0x3,%rcx
    11e5:	mov    $0x1,%r13d
    11eb:	shl    $1,%rcx
    11ee:	or     $0x1,%rcx
    11f2:	mov    %rcx,0x28(%rsp)
    11f7:	mov    %rcx,0x1d8(%rsp)
    11ff:	test   %r13,%r13
    1202:	jl     1898 <botlish_fn_7+0x11c8>
    1208:	cmp    $0x1,%rbx
    120c:	je     1236 <botlish_fn_7+0xb66>
    1212:	mov    $0xa,%esi
    1217:	cmp    $0xffffffffffffffff,%rbx
    121b:	jne    15e6 <botlish_fn_7+0xf16>
    1221:	mov    0x1d8(%rsp),%rax
    1229:	mov    %rax,0x1b0(%rsp)
    1231:	jmp    185c <botlish_fn_7+0x118c>
    1236:	mov    0x1d8(%rsp),%rsi
    123e:	mov    0x1a0(%rsp),%rdi
    1246:	mov    0x1d8(%rsp),%rax
    124e:	mov    %rax,0x1b0(%rsp)
    1256:	mov    0x1b8(%rsp),%rax
    125e:	mov    %rax,0x1e0(%rsp)
    1266:	mov    0x10(%rdi),%rax
    126a:	mov    0xa0(%rax),%rbx
    1271:	test   $0x1,%rsi
    1278:	mov    %rsi,0x1d0(%rsp)
    1280:	jne    12be <botlish_fn_7+0xbee>
    1286:	mov    0x208(%rsp),%rdx
    128e:	mov    0x1d0(%rsp),%rsi
    1296:	mov    0x1a0(%rsp),%rdi
    129e:	call   12a3 <botlish_fn_7+0xbd3>
			129f: R_X86_64_PLT32	rt_int_cmp-0x4
    12a3:	test   %rax,%rax
    12a6:	mov    0x1c8(%rsp),%r8
    12ae:	mov    %r8,%rcx
    12b1:	cmovl  0xbaf(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
    12b9:	jmp    12dd <botlish_fn_7+0xc0d>
    12be:	mov    0x1d0(%rsp),%rsi
    12c6:	mov    0x1c8(%rsp),%r8
    12ce:	cmp    $0xffffffffffffffff,%rsi
    12d2:	mov    %r8,%rcx
    12d5:	cmovl  0xb8b(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
    12dd:	cmp    $0x6,%rcx
    12e1:	jne    12f4 <botlish_fn_7+0xc24>
    12e7:	mov    0x1b8(%rsp),%rsi
    12ef:	jmp    13c3 <botlish_fn_7+0xcf3>
    12f4:	mov    0x1d0(%rsp),%rsi
    12fc:	test   $0x1,%rsi
    1303:	jne    133e <botlish_fn_7+0xc6e>
    1309:	mov    $0x1ff,%edx
    130e:	mov    0x1d0(%rsp),%rsi
    1316:	mov    0x1a0(%rsp),%rdi
    131e:	call   1323 <botlish_fn_7+0xc53>
			131f: R_X86_64_PLT32	rt_int_cmp-0x4
    1323:	test   %rax,%rax
    1326:	mov    0x1c8(%rsp),%r8
    132e:	mov    %r8,%rdi
    1331:	cmovg  0xb2f(%rip),%rdi        # 1e68 <botlish_fn_7+0x1798>
    1339:	jmp    1360 <botlish_fn_7+0xc90>
    133e:	mov    0x1d0(%rsp),%rsi
    1346:	cmp    $0x1ff,%rsi
    134d:	mov    0x1c8(%rsp),%r8
    1355:	mov    %r8,%rdi
    1358:	cmovg  0xb08(%rip),%rdi        # 1e68 <botlish_fn_7+0x1798>
    1360:	cmp    $0x6,%rdi
    1364:	jne    1377 <botlish_fn_7+0xca7>
    136a:	mov    0x1b8(%rsp),%rsi
    1372:	jmp    13c3 <botlish_fn_7+0xcf3>
    1377:	mov    0x1b8(%rsp),%rsi
    137f:	or     $0x1,%rsi
    1383:	mov    %rsi,0x1b8(%rsp)
    138b:	sar    $1,%rsi
    138e:	mov    %rsi,0x1b8(%rsp)
    1396:	imul   $0x101,%rsi,%rax
    139d:	mov    0x1d0(%rsp),%rsi
    13a5:	mov    %rsi,%rcx
    13a8:	sar    $1,%rcx
    13ab:	lea    0x1(%rax,%rcx,1),%rax
    13b0:	movzbq 0x10(%rbx,%rax,1),%rsi
    13b6:	mov    %rsi,0x1b8(%rsp)
    13be:	jmp    13eb <botlish_fn_7+0xd1b>
    13c3:	or     $0x1,%rsi
    13c7:	mov    %rsi,0x1b8(%rsp)
    13cf:	sar    $1,%rsi
    13d2:	mov    %rsi,0x1b8(%rsp)
    13da:	movzbq 0x919(%rbx,%rsi,1),%rsi
    13e3:	mov    %rsi,0x1b8(%rsp)
    13eb:	mov    0x1b8(%rsp),%rsi
    13f3:	mov    %rsi,%rax
    13f6:	shl    $1,%rax
    13f9:	or     $0x1,%rax
    13fd:	cmp    $0x13,%rax
    1401:	mov    0x1c8(%rsp),%r8
    1409:	mov    %r8,%rax
    140c:	cmovl  0xa54(%rip),%rax        # 1e68 <botlish_fn_7+0x1798>
    1414:	cmp    $0x6,%rax
    1418:	je     181a <botlish_fn_7+0x114a>
    141e:	mov    0x1b8(%rsp),%rsi
    1426:	mov    %rsi,%rax
    1429:	shl    $1,%rax
    142c:	or     $0x1,%rax
    1430:	cmp    $0x13,%rax
    1434:	mov    0x1c8(%rsp),%r8
    143c:	mov    %r8,%rax
    143f:	cmove  0xa21(%rip),%rax        # 1e68 <botlish_fn_7+0x1798>
    1447:	cmp    $0x6,%rax
    144b:	je     1764 <botlish_fn_7+0x1094>
    1451:	mov    0x1d0(%rsp),%rsi
    1459:	test   $0x1,%rsi
    1460:	jne    149e <botlish_fn_7+0xdce>
    1466:	mov    0x208(%rsp),%rdx
    146e:	mov    0x1d0(%rsp),%rsi
    1476:	mov    0x1a0(%rsp),%rdi
    147e:	call   1483 <botlish_fn_7+0xdb3>
			147f: R_X86_64_PLT32	rt_int_cmp-0x4
    1483:	test   %rax,%rax
    1486:	mov    0x1c8(%rsp),%r8
    148e:	mov    %r8,%rax
    1491:	cmove  0x9cf(%rip),%rax        # 1e68 <botlish_fn_7+0x1798>
    1499:	jmp    14bd <botlish_fn_7+0xded>
    149e:	mov    0x1d0(%rsp),%rsi
    14a6:	cmp    $0xffffffffffffffff,%rsi
    14aa:	mov    0x1c8(%rsp),%r8
    14b2:	mov    %r8,%rax
    14b5:	cmove  0x9ab(%rip),%rax        # 1e68 <botlish_fn_7+0x1798>
    14bd:	cmp    $0x6,%rax
    14c1:	je     155c <botlish_fn_7+0xe8c>
    14c7:	mov    0x1a0(%rsp),%rdi
    14cf:	mov    0x10(%rdi),%rax
    14d3:	mov    0x90(%rax),%rbx
    14da:	mov    $0x1,%r12d
    14e0:	mov    0x1b8(%rsp),%rsi
    14e8:	shl    $1,%rsi
    14eb:	mov    %rsi,0x1b8(%rsp)
    14f3:	or     $0x1,%rsi
    14f7:	mov    %rsi,0x1b8(%rsp)
    14ff:	call   1504 <botlish_fn_7+0xe34>
			1500: R_X86_64_PLT32	botlish_fn_1-0x4
    1504:	mov    0x1a0(%rsp),%rdi
    150c:	mov    0x10(%rdi),%rcx
    1510:	mov    0xc0(%rcx),%rdx
    1517:	lea    0x160(%rsp),%r9
    151f:	mov    %rbx,0x160(%rsp)
    1527:	mov    %rax,0x168(%rsp)
    152f:	mov    0x1d0(%rsp),%rsi
    1537:	mov    %rsi,0x170(%rsp)
    153f:	mov    %r12,%rsi
    1542:	mov    0x200(%rsp),%rcx
    154a:	mov    0x200(%rsp),%r8
    1552:	call   1557 <botlish_fn_7+0xe87>
			1553: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1557:	jmp    15d1 <botlish_fn_7+0xf01>
    155c:	mov    0x1a0(%rsp),%rdi
    1564:	mov    0x10(%rdi),%rax
    1568:	mov    0x90(%rax),%rbx
    156f:	mov    0x1b8(%rsp),%rsi
    1577:	shl    $1,%rsi
    157a:	mov    %rsi,0x1b8(%rsp)
    1582:	or     $0x1,%rsi
    1586:	mov    %rsi,0x1b8(%rsp)
    158e:	call   1593 <botlish_fn_7+0xec3>
			158f: R_X86_64_PLT32	botlish_fn_1-0x4
    1593:	mov    0x1a0(%rsp),%rdi
    159b:	mov    0x10(%rdi),%rcx
    159f:	mov    0xb8(%rcx),%rdx
    15a6:	lea    0x150(%rsp),%r9
    15ae:	mov    %rbx,0x150(%rsp)
    15b6:	mov    %rax,0x158(%rsp)
    15be:	mov    0x1c8(%rsp),%r8
    15c6:	mov    %r8,%rcx
    15c9:	mov    %r8,%rsi
    15cc:	call   15d1 <botlish_fn_7+0xf01>
			15cd: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    15d1:	mov    0x1a0(%rsp),%rdi
    15d9:	call   15de <botlish_fn_7+0xf0e>
			15da: R_X86_64_PLT32	rt_co_failed-0x4
    15de:	mov    %rax,0x48(%rsp)
    15e3:	mov    %rax,%rsi
    15e6:	mov    0x1a0(%rsp),%rdi
    15ee:	call   15f3 <botlish_fn_7+0xf23>
			15ef: R_X86_64_PLT32	rt_co_resume0-0x4
    15f3:	test   %rax,%rax
    15f6:	je     1618 <botlish_fn_7+0xf48>
    15fc:	mov    0x1a0(%rsp),%rdi
    1604:	mov    0x10(%rdi),%rax
    1608:	mov    0x48(%rax),%rsi
    160c:	mov    0x80(%rax),%rdx
    1613:	call   1618 <botlish_fn_7+0xf48>
			1614: R_X86_64_PLT32	rt_raise-0x4
    1618:	mov    0x1a0(%rsp),%rdi
    1620:	call   1625 <botlish_fn_7+0xf55>
			1621: R_X86_64_PLT32	rt_declared_error-0x4
    1625:	cmp    $0x1,%rax
    1629:	je     16d5 <botlish_fn_7+0x1005>
    162f:	mov    0x1a0(%rsp),%rdi
    1637:	call   163c <botlish_fn_7+0xf6c>
			1638: R_X86_64_PLT32	rt_declared_error-0x4
    163c:	cmp    $0x2,%rax
    1640:	jne    1db9 <botlish_fn_7+0x16e9>
    1646:	xor    %rbx,%rbx
    1649:	mov    %rbx,%rsi
    164c:	mov    0x1a0(%rsp),%rdi
    1654:	call   1659 <botlish_fn_7+0xf89>
			1655: R_X86_64_PLT32	rt_declared_payload-0x4
    1659:	mov    %rax,%r12
    165c:	mov    $0x1,%esi
    1661:	mov    0x1a0(%rsp),%rdi
    1669:	call   166e <botlish_fn_7+0xf9e>
			166a: R_X86_64_PLT32	rt_declared_payload-0x4
    166e:	mov    %rax,%r13
    1671:	mov    0x1a0(%rsp),%rdi
    1679:	call   167e <botlish_fn_7+0xfae>
			167a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    167e:	mov    0x1a0(%rsp),%rdi
    1686:	mov    0x10(%rdi),%rax
    168a:	mov    0x88(%rax),%rdx
    1691:	lea    0xb8(%rsp),%r9
    1699:	movq   $0x1,0xb8(%rsp)
    16a5:	mov    %r12,%rax
    16a8:	mov    %rax,0xc0(%rsp)
    16b0:	mov    %r13,%rax
    16b3:	mov    %rax,0xc8(%rsp)
    16bb:	mov    $0xc,%esi
    16c0:	mov    %rbx,%rcx
    16c3:	mov    0x200(%rsp),%r8
    16cb:	call   16d0 <botlish_fn_7+0x1000>
			16cc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    16d0:	jmp    1db9 <botlish_fn_7+0x16e9>
    16d5:	xor    %rbx,%rbx
    16d8:	mov    %rbx,%rsi
    16db:	mov    0x1a0(%rsp),%rdi
    16e3:	call   16e8 <botlish_fn_7+0x1018>
			16e4: R_X86_64_PLT32	rt_declared_payload-0x4
    16e8:	mov    %rax,%r12
    16eb:	mov    $0x1,%esi
    16f0:	mov    0x1a0(%rsp),%rdi
    16f8:	call   16fd <botlish_fn_7+0x102d>
			16f9: R_X86_64_PLT32	rt_declared_payload-0x4
    16fd:	mov    %rax,%r13
    1700:	mov    0x1a0(%rsp),%rdi
    1708:	call   170d <botlish_fn_7+0x103d>
			1709: R_X86_64_PLT32	rt_clear_declared_error-0x4
    170d:	mov    0x1a0(%rsp),%rdi
    1715:	mov    0x10(%rdi),%rax
    1719:	mov    0x88(%rax),%rdx
    1720:	lea    0xa0(%rsp),%r9
    1728:	movq   $0x1,0xa0(%rsp)
    1734:	mov    %r12,%rax
    1737:	mov    %rax,0xa8(%rsp)
    173f:	mov    %r13,%rax
    1742:	mov    %rax,0xb0(%rsp)
    174a:	mov    $0xc,%esi
    174f:	mov    %rbx,%rcx
    1752:	mov    0x200(%rsp),%r8
    175a:	call   175f <botlish_fn_7+0x108f>
			175b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    175f:	jmp    1db9 <botlish_fn_7+0x16e9>
    1764:	mov    0x1d0(%rsp),%rsi
    176c:	test   $0x1,%rsi
    1773:	jne    17ae <botlish_fn_7+0x10de>
    1779:	mov    $0x1,%edx
    177e:	mov    0x1d0(%rsp),%rsi
    1786:	mov    0x1a0(%rsp),%rdi
    178e:	call   1793 <botlish_fn_7+0x10c3>
			178f: R_X86_64_PLT32	rt_int_cmp-0x4
    1793:	test   %rax,%rax
    1796:	mov    0x1c8(%rsp),%r8
    179e:	mov    %r8,%rcx
    17a1:	cmovge 0x6bf(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
    17a9:	jmp    17d4 <botlish_fn_7+0x1104>
    17ae:	mov    0x1d0(%rsp),%rax
    17b6:	mov    0x1d0(%rsp),%rsi
    17be:	test   %rax,%rsi
    17c1:	mov    0x1c8(%rsp),%r8
    17c9:	mov    %r8,%rcx
    17cc:	cmovg  0x694(%rip),%rcx        # 1e68 <botlish_fn_7+0x1798>
    17d4:	cmp    $0x6,%rcx
    17d8:	je     17e8 <botlish_fn_7+0x1118>
    17de:	mov    $0x1,%esi
    17e3:	jmp    17f0 <botlish_fn_7+0x1120>
    17e8:	mov    0x200(%rsp),%rsi
    17f0:	mov    %rsi,0x40(%rsp)
    17f5:	mov    0x208(%rsp),%rbx
    17fd:	mov    0x1e0(%rsp),%rax
    1805:	mov    %rax,0x1b8(%rsp)
    180d:	mov    %rsi,0x1c0(%rsp)
    1815:	jmp    185c <botlish_fn_7+0x118c>
    181a:	mov    0x1b8(%rsp),%rsi
    1822:	shl    $1,%rsi
    1825:	mov    %rsi,0x1b8(%rsp)
    182d:	or     $0x1,%rsi
    1831:	mov    %rsi,0x1b8(%rsp)
    1839:	mov    %rsi,0x50(%rsp)
    183e:	mov    $0x1,%esi
    1843:	mov    %rsi,0x1c0(%rsp)
    184b:	movq   $0x1,0x40(%rsp)
    1854:	mov    0x1c0(%rsp),%rbx
    185c:	mov    0x18(%r12),%rax
    1861:	test   %rax,%rax
    1864:	je     1e44 <botlish_fn_7+0x1774>
    186a:	mov    0x1d8(%rsp),%rcx
    1872:	mov    0x10(%r12),%rax
    1877:	mov    %rcx,0x10(%rax)
    187b:	mov    0x1b0(%rsp),%rax
    1883:	mov    %rax,0x1d8(%rsp)
    188b:	mov    %r14,0x218(%rsp)
    1893:	jmp    e87 <botlish_fn_7+0x7b7>
    1898:	cmp    $0x1,%rbx
    189c:	je     18be <botlish_fn_7+0x11ee>
    18a2:	mov    $0xa,%esi
    18a7:	cmp    $0xffffffffffffffff,%rbx
    18ab:	jne    1ab3 <botlish_fn_7+0x13e3>
    18b1:	mov    0x1c0(%rsp),%rsi
    18b9:	jmp    1c7c <botlish_fn_7+0x15ac>
    18be:	mov    0x1a0(%rsp),%rdi
    18c6:	mov    0x10(%rdi),%rax
    18ca:	mov    0xa0(%rax),%rax
    18d1:	mov    0x1c8(%rsp),%rcx
    18d9:	cmp    $0x6,%rcx
    18dd:	jne    18f0 <botlish_fn_7+0x1220>
    18e3:	mov    0x1b8(%rsp),%rsi
    18eb:	jmp    1940 <botlish_fn_7+0x1270>
    18f0:	mov    0x1c8(%rsp),%rsi
    18f8:	cmp    $0x6,%rsi
    18fc:	jne    190f <botlish_fn_7+0x123f>
    1902:	mov    0x1b8(%rsp),%rsi
    190a:	jmp    1940 <botlish_fn_7+0x1270>
    190f:	mov    0x1b8(%rsp),%rsi
    1917:	or     $0x1,%rsi
    191b:	mov    %rsi,0x1b8(%rsp)
    1923:	sar    $1,%rsi
    1926:	mov    %rsi,0x1b8(%rsp)
    192e:	imul   $0x101,%rsi,%rcx
    1935:	movzbq 0x10(%rax,%rcx,1),%rsi
    193b:	jmp    1960 <botlish_fn_7+0x1290>
    1940:	or     $0x1,%rsi
    1944:	mov    %rsi,0x1b8(%rsp)
    194c:	sar    $1,%rsi
    194f:	mov    %rsi,0x1b8(%rsp)
    1957:	movzbq 0x919(%rax,%rsi,1),%rsi
    1960:	mov    %rsi,%rax
    1963:	shl    $1,%rax
    1966:	or     $0x1,%rax
    196a:	cmp    $0x13,%rax
    196e:	mov    0x1c8(%rsp),%r8
    1976:	mov    %r8,%rax
    1979:	cmovl  0x4e7(%rip),%rax        # 1e68 <botlish_fn_7+0x1798>
    1981:	cmp    $0x6,%rax
    1985:	je     1c62 <botlish_fn_7+0x1592>
    198b:	mov    %rsi,%rax
    198e:	shl    $1,%rax
    1991:	or     $0x1,%rax
    1995:	cmp    $0x13,%rax
    1999:	mov    0x1c8(%rsp),%r8
    19a1:	mov    %r8,%rax
    19a4:	cmove  0x4bc(%rip),%rax        # 1e68 <botlish_fn_7+0x1798>
    19ac:	cmp    $0x6,%rax
    19b0:	je     1c34 <botlish_fn_7+0x1564>
    19b6:	mov    0x1f0(%rsp),%r8
    19be:	cmp    $0x6,%r8
    19c2:	je     1a41 <botlish_fn_7+0x1371>
    19c8:	mov    0x1a0(%rsp),%rdi
    19d0:	mov    0x10(%rdi),%rax
    19d4:	mov    0x90(%rax),%rbx
    19db:	mov    $0x1,%r12d
    19e1:	shl    $1,%rsi
    19e4:	or     $0x1,%rsi
    19e8:	call   19ed <botlish_fn_7+0x131d>
			19e9: R_X86_64_PLT32	botlish_fn_1-0x4
    19ed:	mov    0x1a0(%rsp),%rdi
    19f5:	mov    0x10(%rdi),%rcx
    19f9:	mov    0xc0(%rcx),%rdx
    1a00:	lea    0x188(%rsp),%r9
    1a08:	mov    %rbx,0x188(%rsp)
    1a10:	mov    %rax,0x190(%rsp)
    1a18:	movq   $0xffffffffffffffff,0x198(%rsp)
    1a24:	mov    %r12,%rsi
    1a27:	mov    0x200(%rsp),%rcx
    1a2f:	mov    0x200(%rsp),%r8
    1a37:	call   1a3c <botlish_fn_7+0x136c>
			1a38: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1a3c:	jmp    1a9e <botlish_fn_7+0x13ce>
    1a41:	mov    0x1a0(%rsp),%rdi
    1a49:	mov    0x10(%rdi),%rcx
    1a4d:	mov    0x90(%rcx),%rbx
    1a54:	shl    $1,%rsi
    1a57:	or     $0x1,%rsi
    1a5b:	call   1a60 <botlish_fn_7+0x1390>
			1a5c: R_X86_64_PLT32	botlish_fn_1-0x4
    1a60:	mov    0x1a0(%rsp),%rdi
    1a68:	mov    0x10(%rdi),%rcx
    1a6c:	mov    0xb8(%rcx),%rdx
    1a73:	lea    0x178(%rsp),%r9
    1a7b:	mov    %rbx,0x178(%rsp)
    1a83:	mov    %rax,0x180(%rsp)
    1a8b:	mov    0x1c8(%rsp),%r8
    1a93:	mov    %r8,%rcx
    1a96:	mov    %r8,%rsi
    1a99:	call   1a9e <botlish_fn_7+0x13ce>
			1a9a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1a9e:	mov    0x1a0(%rsp),%rdi
    1aa6:	call   1aab <botlish_fn_7+0x13db>
			1aa7: R_X86_64_PLT32	rt_co_failed-0x4
    1aab:	mov    %rax,0x48(%rsp)
    1ab0:	mov    %rax,%rsi
    1ab3:	mov    0x1a0(%rsp),%rdi
    1abb:	call   1ac0 <botlish_fn_7+0x13f0>
			1abc: R_X86_64_PLT32	rt_co_resume0-0x4
    1ac0:	test   %rax,%rax
    1ac3:	je     1ae5 <botlish_fn_7+0x1415>
    1ac9:	mov    0x1a0(%rsp),%rdi
    1ad1:	mov    0x10(%rdi),%r9
    1ad5:	mov    0x48(%r9),%rsi
    1ad9:	mov    0x80(%r9),%rdx
    1ae0:	call   1ae5 <botlish_fn_7+0x1415>
			1ae1: R_X86_64_PLT32	rt_raise-0x4
    1ae5:	mov    0x1a0(%rsp),%rdi
    1aed:	call   1af2 <botlish_fn_7+0x1422>
			1aee: R_X86_64_PLT32	rt_declared_error-0x4
    1af2:	cmp    $0x1,%rax
    1af6:	je     1ba5 <botlish_fn_7+0x14d5>
    1afc:	mov    0x1a0(%rsp),%rdi
    1b04:	call   1b09 <botlish_fn_7+0x1439>
			1b05: R_X86_64_PLT32	rt_declared_error-0x4
    1b09:	cmp    $0x2,%rax
    1b0d:	jne    1db9 <botlish_fn_7+0x16e9>
    1b13:	xor    %r15,%r15
    1b16:	mov    %r15,%rsi
    1b19:	mov    0x1a0(%rsp),%rdi
    1b21:	call   1b26 <botlish_fn_7+0x1456>
			1b22: R_X86_64_PLT32	rt_declared_payload-0x4
    1b26:	mov    %r15,%rbx
    1b29:	mov    %rax,%r12
    1b2c:	mov    $0x1,%esi
    1b31:	mov    0x1a0(%rsp),%rdi
    1b39:	call   1b3e <botlish_fn_7+0x146e>
			1b3a: R_X86_64_PLT32	rt_declared_payload-0x4
    1b3e:	mov    %rax,%r13
    1b41:	mov    0x1a0(%rsp),%rdi
    1b49:	call   1b4e <botlish_fn_7+0x147e>
			1b4a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1b4e:	mov    0x1a0(%rsp),%rdi
    1b56:	mov    0x10(%rdi),%rax
    1b5a:	mov    0x88(%rax),%rdx
    1b61:	lea    0xe8(%rsp),%r9
    1b69:	movq   $0x1,0xe8(%rsp)
    1b75:	mov    %r12,%rax
    1b78:	mov    %rax,0xf0(%rsp)
    1b80:	mov    %r13,%rax
    1b83:	mov    %rax,0xf8(%rsp)
    1b8b:	mov    $0xc,%esi
    1b90:	mov    %rbx,%rcx
    1b93:	mov    0x200(%rsp),%r8
    1b9b:	call   1ba0 <botlish_fn_7+0x14d0>
			1b9c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1ba0:	jmp    1db9 <botlish_fn_7+0x16e9>
    1ba5:	xor    %rbx,%rbx
    1ba8:	mov    %rbx,%rsi
    1bab:	mov    0x1a0(%rsp),%rdi
    1bb3:	call   1bb8 <botlish_fn_7+0x14e8>
			1bb4: R_X86_64_PLT32	rt_declared_payload-0x4
    1bb8:	mov    %rax,%r12
    1bbb:	mov    $0x1,%esi
    1bc0:	mov    0x1a0(%rsp),%rdi
    1bc8:	call   1bcd <botlish_fn_7+0x14fd>
			1bc9: R_X86_64_PLT32	rt_declared_payload-0x4
    1bcd:	mov    %rax,%r15
    1bd0:	mov    0x1a0(%rsp),%rdi
    1bd8:	call   1bdd <botlish_fn_7+0x150d>
			1bd9: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1bdd:	mov    0x1a0(%rsp),%rdi
    1be5:	mov    0x10(%rdi),%rax
    1be9:	mov    0x88(%rax),%rdx
    1bf0:	lea    0xd0(%rsp),%r9
    1bf8:	movq   $0x1,0xd0(%rsp)
    1c04:	mov    %r12,%rax
    1c07:	mov    %rax,0xd8(%rsp)
    1c0f:	mov    %r15,%rax
    1c12:	mov    %rax,0xe0(%rsp)
    1c1a:	mov    $0xc,%esi
    1c1f:	mov    %rbx,%rcx
    1c22:	mov    0x200(%rsp),%r8
    1c2a:	call   1c2f <botlish_fn_7+0x155f>
			1c2b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1c2f:	jmp    1db9 <botlish_fn_7+0x16e9>
    1c34:	mov    0x1c8(%rsp),%rax
    1c3c:	cmp    $0x6,%rax
    1c40:	je     1c50 <botlish_fn_7+0x1580>
    1c46:	mov    $0x1,%esi
    1c4b:	jmp    1c58 <botlish_fn_7+0x1588>
    1c50:	mov    0x200(%rsp),%rsi
    1c58:	mov    %rsi,0x40(%rsp)
    1c5d:	jmp    1c7c <botlish_fn_7+0x15ac>
    1c62:	shl    $1,%rsi
    1c65:	or     $0x1,%rsi
    1c69:	mov    %rsi,0x50(%rsp)
    1c6e:	mov    $0x1,%esi
    1c73:	movq   $0x1,0x40(%rsp)
    1c7c:	test   $0x1,%rsi
    1c83:	jne    1cbb <botlish_fn_7+0x15eb>
    1c89:	mov    $0x1,%edx
    1c8e:	mov    0x1a0(%rsp),%rdi
    1c96:	call   1c9b <botlish_fn_7+0x15cb>
			1c97: R_X86_64_PLT32	rt_int_cmp-0x4
    1c9b:	test   %rax,%rax
    1c9e:	mov    0x1c8(%rsp),%r8
    1ca6:	cmove  0x1ba(%rip),%r8        # 1e68 <botlish_fn_7+0x1798>
    1cae:	mov    %r8,0x1c8(%rsp)
    1cb6:	jmp    1cd7 <botlish_fn_7+0x1607>
    1cbb:	cmp    $0x1,%rsi
    1cbf:	mov    0x1c8(%rsp),%r8
    1cc7:	cmove  0x199(%rip),%r8        # 1e68 <botlish_fn_7+0x1798>
    1ccf:	mov    %r8,0x1c8(%rsp)
    1cd7:	cmp    $0x6,%r8
    1cdb:	je     1d40 <botlish_fn_7+0x1670>
    1ce1:	mov    0x1a0(%rsp),%rdi
    1ce9:	mov    0x10(%rdi),%rdx
    1ced:	mov    0x90(%rdx),%rax
    1cf4:	mov    0x98(%rdx),%rcx
    1cfb:	mov    0x88(%rdx),%rdx
    1d02:	lea    0x100(%rsp),%r9
    1d0a:	movq   $0x1,0x100(%rsp)
    1d16:	mov    %rax,0x108(%rsp)
    1d1e:	mov    %rcx,0x110(%rsp)
    1d26:	mov    $0xc,%esi
    1d2b:	xor    %rcx,%rcx
    1d2e:	mov    0x200(%rsp),%r8
    1d36:	call   1d3b <botlish_fn_7+0x166b>
			1d37: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d3b:	jmp    1db9 <botlish_fn_7+0x16e9>
    1d40:	mov    0x1e8(%rsp),%rcx
    1d48:	add    $0x1,%rcx
    1d4f:	mov    0x1a8(%rsp),%rax
    1d57:	mov    %r12,%rdx
    1d5a:	jmp    7af <botlish_fn_7+0xdf>
    1d5f:	mov    0x1a0(%rsp),%rdi
    1d67:	mov    0x10(%rdi),%rdx
    1d6b:	mov    0x90(%rdx),%rax
    1d72:	mov    0x98(%rdx),%rcx
    1d79:	mov    0x88(%rdx),%rdx
    1d80:	lea    0x88(%rsp),%r9
    1d88:	movq   $0x1,0x88(%rsp)
    1d94:	mov    %rax,0x90(%rsp)
    1d9c:	mov    %rcx,0x98(%rsp)
    1da4:	mov    $0xc,%esi
    1da9:	xor    %rcx,%rcx
    1dac:	mov    0x200(%rsp),%r8
    1db4:	call   1db9 <botlish_fn_7+0x16e9>
			1db5: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1db9:	xor    %rax,%rax
    1dbc:	mov    0x220(%rsp),%rbx
    1dc4:	mov    0x228(%rsp),%r12
    1dcc:	mov    0x230(%rsp),%r13
    1dd4:	mov    0x238(%rsp),%r14
    1ddc:	mov    0x240(%rsp),%r15
    1de4:	add    $0x250,%rsp
    1deb:	mov    %rbp,%rsp
    1dee:	pop    %rbp
    1def:	ret
    1df0:	mov    $0x5,%edx
    1df5:	mov    %r15,%rcx
    1df8:	mov    %r12,%rsi
    1dfb:	mov    0x1a0(%rsp),%rdi
    1e03:	call   1e08 <botlish_fn_7+0x1738>
			1e04: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e08:	jmp    e41 <botlish_fn_7+0x771>
    1e0d:	mov    $0x1,%edx
    1e12:	mov    %r12,%rsi
    1e15:	mov    0x1a0(%rsp),%rdi
    1e1d:	call   1e22 <botlish_fn_7+0x1752>
			1e1e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e22:	jmp    104d <botlish_fn_7+0x97d>
    1e27:	mov    0x200(%rsp),%rdx
    1e2f:	mov    %r12,%rsi
    1e32:	mov    0x1a0(%rsp),%rdi
    1e3a:	call   1e3f <botlish_fn_7+0x176f>
			1e3b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e3f:	jmp    10bd <botlish_fn_7+0x9ed>
    1e44:	mov    $0x5,%edx
    1e49:	mov    0x1d8(%rsp),%rcx
    1e51:	mov    %r12,%rsi
    1e54:	mov    0x1a0(%rsp),%rdi
    1e5c:	call   1e61 <botlish_fn_7+0x1791>
			1e5d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e61:	jmp    187b <botlish_fn_7+0x11ab>
    1e66:	add    %al,(%rax)
    1e68:	(bad)
    1e69:	add    %al,(%rax)
    1e6b:	add    %al,(%rax)
    1e6d:	add    %al,(%rax)
    1e6f:	add    %bh,(%rsi)
    1e71:	add    %al,(%rax)
    1e73:	add    %al,(%rax)
    1e75:	add    %al,(%rax)
    1e77:	add    %al,(%rbx)
    1e79:	add    %al,(%rax)
    1e7b:	add    %al,(%rcx)
    1e7d:	add    %al,(%rax)
    1e7f:	.byte 0x80

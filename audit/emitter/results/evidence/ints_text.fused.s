<botlish_fn_8>:
     7d8:	push   %rbp
     7d9:	mov    %rsp,%rbp
     7dc:	sub    $0x110,%rsp
     7e3:	mov    %rbx,0xe0(%rsp)
     7eb:	mov    %r12,0xe8(%rsp)
     7f3:	mov    %r13,0xf0(%rsp)
     7fb:	mov    %r14,0xf8(%rsp)
     803:	mov    %r15,0x100(%rsp)
     80b:	mov    %rdi,0x98(%rsp)
     813:	mov    %rsi,0xa0(%rsp)
     81b:	movq   $0x0,0x10(%rsp)
     824:	movq   $0x0,0x18(%rsp)
     82d:	movq   $0x0,0x20(%rsp)
     836:	movq   $0x0,0x28(%rsp)
     83f:	movq   $0x0,0x30(%rsp)
     848:	movq   $0x0,0x38(%rsp)
     851:	movq   $0x0,0x40(%rsp)
     85a:	mov    $0x7,%esi
     85f:	movq   $0x7,(%rsp)
     867:	mov    $0x1,%edx
     86c:	movq   $0x1,0x8(%rsp)
     875:	mov    0x98(%rsp),%rdi
     87d:	call   882 <botlish_fn_8+0xaa>
			87e: R_X86_64_PLT32	rt_mutarray_create-0x4
     882:	test   %rax,%rax
     885:	je     1303 <botlish_fn_8+0xb2b>
     88b:	mov    %rax,(%rsp)
     88f:	mov    %rax,%rdx
     892:	xor    %rcx,%rcx
     895:	mov    %rcx,0xb0(%rsp)
     89d:	mov    0xa0(%rsp),%rax
     8a5:	mov    0xb0(%rsp),%rbx
     8ad:	mov    0xb0(%rsp),%r15
     8b5:	cmp    %rax,%rcx
     8b8:	mov    %rax,0xa0(%rsp)
     8c0:	jl     93f <botlish_fn_8+0x167>
     8c6:	mov    %rdx,%r13
     8c9:	mov    0x10(%r13),%rax
     8cd:	mov    0x8(%rax),%rax
     8d1:	mov    %rax,0x8(%rsp)
     8d6:	mov    0x10(%r13),%rcx
     8da:	mov    (%rcx),%rcx
     8dd:	mov    %rcx,(%rsp)
     8e1:	lea    0x48(%rsp),%rdx
     8e6:	mov    %rax,0x48(%rsp)
     8eb:	mov    %rcx,0x50(%rsp)
     8f0:	mov    $0x2,%esi
     8f5:	mov    0x98(%rsp),%rdi
     8fd:	call   902 <botlish_fn_8+0x12a>
			8fe: R_X86_64_PLT32	rt_list_new-0x4
     902:	test   %rax,%rax
     905:	je     1303 <botlish_fn_8+0xb2b>
     90b:	mov    0xe0(%rsp),%rbx
     913:	mov    0xe8(%rsp),%r12
     91b:	mov    0xf0(%rsp),%r13
     923:	mov    0xf8(%rsp),%r14
     92b:	mov    0x100(%rsp),%r15
     933:	add    $0x110,%rsp
     93a:	mov    %rbp,%rsp
     93d:	pop    %rbp
     93e:	ret
     93f:	mov    %rdx,%r13
     942:	mov    %rcx,%rsi
     945:	shl    $1,%rsi
     948:	mov    %rcx,0xb0(%rsp)
     950:	or     $0x1,%rsi
     954:	mov    %rsi,0x8(%rsp)
     959:	mov    0x98(%rsp),%rdi
     961:	call   966 <botlish_fn_8+0x18e>
			962: R_X86_64_PLT32	botlish_fn_7-0x4
     966:	mov    %rax,%rcx
     969:	mov    %rax,%r12
     96c:	test   %rcx,%rax
     96f:	je     1303 <botlish_fn_8+0xb2b>
     975:	movq   $0xa,0x38(%rsp)
     97e:	movq   $0xa,0x40(%rsp)
     987:	movq   $0xa,0x28(%rsp)
     990:	movq   $0xa,0x30(%rsp)
     999:	mov    %r12,%rax
     99c:	mov    %rax,0x10(%rsp)
     9a1:	mov    %r12,%rsi
     9a4:	mov    0x98(%rsp),%rdi
     9ac:	call   9b1 <botlish_fn_8+0x1d9>
			9ad: R_X86_64_PLT32	rt_int_to_str-0x4
     9b1:	mov    %rax,0x38(%rsp)
     9b6:	mov    %rax,0xd8(%rsp)
     9be:	test   $0x1,%r12
     9c5:	jne    9f5 <botlish_fn_8+0x21d>
     9cb:	mov    $0x1,%edx
     9d0:	mov    %r12,%rsi
     9d3:	mov    0x98(%rsp),%rdi
     9db:	call   9e0 <botlish_fn_8+0x208>
			9dc: R_X86_64_PLT32	rt_int_cmp-0x4
     9e0:	mov    $0x2,%ecx
     9e5:	test   %rax,%rax
     9e8:	cmove  0xa68(%rip),%rcx        # 1458 <botlish_fn_8+0xc80>
     9f0:	jmp    a06 <botlish_fn_8+0x22e>
     9f5:	mov    $0x2,%ecx
     9fa:	cmp    $0x1,%r12
     9fe:	cmove  0xa52(%rip),%rcx        # 1458 <botlish_fn_8+0xc80>
     a06:	cmp    $0x6,%rcx
     a0a:	je     c5a <botlish_fn_8+0x482>
     a10:	test   $0x1,%r12
     a17:	jne    a47 <botlish_fn_8+0x26f>
     a1d:	mov    $0x1,%edx
     a22:	mov    %r12,%rsi
     a25:	mov    0x98(%rsp),%rdi
     a2d:	call   a32 <botlish_fn_8+0x25a>
			a2e: R_X86_64_PLT32	rt_int_cmp-0x4
     a32:	mov    $0x2,%ecx
     a37:	test   %rax,%rax
     a3a:	cmovl  0xa16(%rip),%rcx        # 1458 <botlish_fn_8+0xc80>
     a42:	jmp    a5a <botlish_fn_8+0x282>
     a47:	mov    %r12,%rsi
     a4a:	mov    $0x2,%ecx
     a4f:	test   %rsi,%rsi
     a52:	cmovle 0x9fe(%rip),%rcx        # 1458 <botlish_fn_8+0xc80>
     a5a:	cmp    $0x6,%rcx
     a5e:	je     c32 <botlish_fn_8+0x45a>
     a64:	movq   $0x1,0x40(%rsp)
     a6d:	mov    $0x1,%edx
     a72:	mov    0xd8(%rsp),%rsi
     a7a:	mov    0x98(%rsp),%rdi
     a82:	call   a87 <botlish_fn_8+0x2af>
			a83: R_X86_64_PLT32	rt_str_char_at-0x4
     a87:	mov    %rax,%rcx
     a8a:	mov    %rax,0xa8(%rsp)
     a92:	test   %rcx,%rax
     a95:	je     b93 <botlish_fn_8+0x3bb>
     a9b:	mov    0xa8(%rsp),%rax
     aa3:	shr    $0x3,%rax
     aa7:	mov    %rax,0xa8(%rsp)
     aaf:	shl    $1,%rax
     ab2:	mov    %rax,0xa8(%rsp)
     aba:	or     $0x1,%rax
     abe:	mov    %rax,0xa8(%rsp)
     ac6:	mov    0xa8(%rsp),%rsi
     ace:	mov    0x98(%rsp),%rdi
     ad6:	call   adb <botlish_fn_8+0x303>
			ad7: R_X86_64_PLT32	botlish_fn_4-0x4
     adb:	test   %rax,%rax
     ade:	jne    c0c <botlish_fn_8+0x434>
     ae4:	mov    0x98(%rsp),%rdi
     aec:	call   af1 <botlish_fn_8+0x319>
			aed: R_X86_64_PLT32	rt_declared_error-0x4
     af1:	cmp    $0x1,%rax
     af5:	je     b55 <botlish_fn_8+0x37d>
     afb:	mov    0x98(%rsp),%rdi
     b03:	call   b08 <botlish_fn_8+0x330>
			b04: R_X86_64_PLT32	rt_declared_error-0x4
     b08:	cmp    $0x2,%rax
     b0c:	jne    b93 <botlish_fn_8+0x3bb>
     b12:	mov    0x98(%rsp),%rdi
     b1a:	call   b1f <botlish_fn_8+0x347>
			b1b: R_X86_64_PLT32	rt_clear_declared_error-0x4
     b1f:	mov    0x98(%rsp),%rdi
     b27:	mov    0x10(%rdi),%rax
     b2b:	mov    0x70(%rax),%rdx
     b2f:	mov    $0x1,%r8d
     b35:	lea    0x60(%rsp),%r9
     b3a:	movq   $0x1,0x60(%rsp)
     b43:	mov    $0x3,%esi
     b48:	xor    %rcx,%rcx
     b4b:	call   b50 <botlish_fn_8+0x378>
			b4c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     b50:	jmp    b93 <botlish_fn_8+0x3bb>
     b55:	mov    0x98(%rsp),%rdi
     b5d:	call   b62 <botlish_fn_8+0x38a>
			b5e: R_X86_64_PLT32	rt_clear_declared_error-0x4
     b62:	mov    0x98(%rsp),%rdi
     b6a:	mov    0x10(%rdi),%rax
     b6e:	mov    0x70(%rax),%rdx
     b72:	mov    $0x1,%r8d
     b78:	lea    0x58(%rsp),%r9
     b7d:	movq   $0x1,0x58(%rsp)
     b86:	mov    $0x3,%esi
     b8b:	xor    %rcx,%rcx
     b8e:	call   b93 <botlish_fn_8+0x3bb>
			b8f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     b93:	mov    0x98(%rsp),%rdi
     b9b:	call   ba0 <botlish_fn_8+0x3c8>
			b9c: R_X86_64_PLT32	rt_co_failed-0x4
     ba0:	mov    %rax,0x30(%rsp)
     ba5:	mov    %rax,%rsi
     ba8:	mov    0x98(%rsp),%rdi
     bb0:	call   bb5 <botlish_fn_8+0x3dd>
			bb1: R_X86_64_PLT32	rt_co_resume0-0x4
     bb5:	test   %rax,%rax
     bb8:	je     bd7 <botlish_fn_8+0x3ff>
     bbe:	mov    0x98(%rsp),%rdi
     bc6:	mov    0x10(%rdi),%rax
     bca:	mov    0x40(%rax),%rsi
     bce:	mov    0x68(%rax),%rdx
     bd2:	call   bd7 <botlish_fn_8+0x3ff>
			bd3: R_X86_64_PLT32	rt_raise-0x4
     bd7:	mov    0x98(%rsp),%rdi
     bdf:	call   be4 <botlish_fn_8+0x40c>
			be0: R_X86_64_PLT32	rt_declared_error-0x4
     be4:	cmp    $0x40000001,%rax
     bea:	je     1303 <botlish_fn_8+0xb2b>
     bf0:	mov    0x98(%rsp),%rdi
     bf8:	call   bfd <botlish_fn_8+0x425>
			bf9: R_X86_64_PLT32	rt_declared_error-0x4
     bfd:	cmp    $0x3,%rax
     c01:	jne    1303 <botlish_fn_8+0xb2b>
     c07:	jmp    1303 <botlish_fn_8+0xb2b>
     c0c:	mov    0xa8(%rsp),%r14
     c14:	mov    %r14,0x28(%rsp)
     c19:	mov    $0x3,%r12d
     c1f:	mov    $0x1,%r8d
     c25:	mov    %r8,0xb8(%rsp)
     c2d:	jmp    c7d <botlish_fn_8+0x4a5>
     c32:	mov    $0x5b,%r14d
     c38:	movq   $0x5b,0x28(%rsp)
     c41:	mov    $0x2,%r12d
     c47:	mov    $0xa,%r8d
     c4d:	mov    %r8,0xb8(%rsp)
     c55:	jmp    c7d <botlish_fn_8+0x4a5>
     c5a:	mov    $0x61,%r14d
     c60:	movq   $0x61,0x28(%rsp)
     c69:	mov    $0x1,%r12d
     c6f:	mov    $0xa,%r8d
     c75:	mov    %r8,0xb8(%rsp)
     c7d:	mov    0x18(%r13),%rcx
     c81:	test   %rcx,%rcx
     c84:	je     13d5 <botlish_fn_8+0xbfd>
     c8a:	mov    0x10(%r13),%rax
     c8e:	mov    %r14,0x10(%rax)
     c92:	mov    %r14,0xa8(%rsp)
     c9a:	mov    $0x3,%esi
     c9f:	mov    %rsi,0xd0(%rsp)
     ca7:	mov    $0x7fffffff,%eax
     cac:	mov    %rax,%r14
     caf:	neg    %r14
     cb2:	cmovs  %rax,%r14
     cb6:	mov    %r14,0xc8(%rsp)
     cbe:	test   %r12,%r12
     cc1:	jl     13b6 <botlish_fn_8+0xbde>
     cc7:	movq   $0x1,0x8(%rsp)
     cd0:	mov    0x10(%r13),%rax
     cd4:	mov    (%rax),%rsi
     cd7:	mov    %rsi,0x10(%rsp)
     cdc:	mov    0x10(%r13),%rax
     ce0:	mov    0x10(%rax),%rdx
     ce4:	mov    %rdx,0x18(%rsp)
     ce9:	mov    %rdx,%r14
     cec:	movq   $0x3f,0x20(%rsp)
     cf5:	test   $0x1,%rsi
     cfc:	je     d26 <botlish_fn_8+0x54e>
     d02:	mov    %rsi,%rax
     d05:	sar    $1,%rax
     d08:	imulq  0x751(%rip)        # 1460 <botlish_fn_8+0xc88>
     d0f:	seto   %cl
     d12:	or     $0x1,%rax
     d16:	test   %cl,%cl
     d18:	jne    d26 <botlish_fn_8+0x54e>
     d1e:	mov    %rax,%rsi
     d21:	jmp    d3b <botlish_fn_8+0x563>
     d26:	mov    $0x3f,%edx
     d2b:	mov    0x98(%rsp),%rdi
     d33:	call   d38 <botlish_fn_8+0x560>
			d34: R_X86_64_PLT32	rt_int_mul-0x4
     d38:	mov    %rax,%rsi
     d3b:	mov    %rsi,0x10(%rsp)
     d40:	mov    %r14,%rdx
     d43:	mov    %rsi,%rax
     d46:	and    %rdx,%rax
     d49:	test   $0x1,%rax
     d4f:	je     d6c <botlish_fn_8+0x594>
     d55:	lea    -0x1(%rdx),%rdi
     d59:	mov    %rsi,%rax
     d5c:	add    %rdi,%rax
     d5f:	seto   %dil
     d63:	test   %dil,%dil
     d66:	je     d79 <botlish_fn_8+0x5a1>
     d6c:	mov    0x98(%rsp),%rdi
     d74:	call   d79 <botlish_fn_8+0x5a1>
			d75: R_X86_64_PLT32	rt_int_add-0x4
     d79:	mov    %rax,0x10(%rsp)
     d7e:	movq   $0x3,0x18(%rsp)
     d87:	test   $0x1,%rax
     d8d:	jne    d9b <botlish_fn_8+0x5c3>
     d93:	mov    %rax,%rsi
     d96:	jmp    db3 <botlish_fn_8+0x5db>
     d9b:	mov    %rax,%rsi
     d9e:	add    $0x2,%rsi
     da2:	mov    %rax,%rcx
     da5:	seto   %al
     da8:	test   %al,%al
     daa:	je     dcb <botlish_fn_8+0x5f3>
     db0:	mov    %rcx,%rsi
     db3:	mov    0xd0(%rsp),%rdx
     dbb:	mov    0x98(%rsp),%rdi
     dc3:	call   dc8 <botlish_fn_8+0x5f0>
			dc4: R_X86_64_PLT32	rt_int_add-0x4
     dc8:	mov    %rax,%rsi
     dcb:	mov    %rsi,0x10(%rsp)
     dd0:	mov    $0xffffffff,%eax
     dd5:	mov    %rax,0x18(%rsp)
     dda:	test   $0x1,%rsi
     de1:	jne    e28 <botlish_fn_8+0x650>
     de7:	mov    $0xffffffff,%edx
     dec:	mov    0x98(%rsp),%rdi
     df4:	call   df9 <botlish_fn_8+0x621>
			df5: R_X86_64_PLT32	rt_int_mod-0x4
     df9:	test   %rax,%rax
     dfc:	jne    e20 <botlish_fn_8+0x648>
     e02:	mov    0x98(%rsp),%rdi
     e0a:	call   e0f <botlish_fn_8+0x637>
			e0b: R_X86_64_PLT32	rt_declared_error-0x4
     e0f:	cmp    $0x40000001,%rax
     e15:	jne    1303 <botlish_fn_8+0xb2b>
     e1b:	jmp    1303 <botlish_fn_8+0xb2b>
     e20:	mov    %rax,%rcx
     e23:	jmp    e6e <botlish_fn_8+0x696>
     e28:	sar    $1,%rsi
     e2b:	mov    %rsi,%rax
     e2e:	imulq  0x633(%rip)        # 1468 <botlish_fn_8+0xc90>
     e35:	lea    (%rdx,%rsi,1),%rax
     e39:	sar    $0x1e,%rax
     e3d:	mov    %rax,%rcx
     e40:	shr    $0x3f,%rcx
     e44:	add    %rcx,%rax
     e47:	imul   $0x7fffffff,%rax,%rax
     e4e:	sub    %rax,%rsi
     e51:	mov    0xc8(%rsp),%rcx
     e59:	lea    (%rsi,%rcx,1),%rax
     e5d:	test   %rsi,%rsi
     e60:	cmovl  %rax,%rsi
     e64:	shl    $1,%rsi
     e67:	or     $0x1,%rsi
     e6b:	mov    %rsi,%rcx
     e6e:	mov    0x18(%r13),%rax
     e72:	test   %rax,%rax
     e75:	je     13fa <botlish_fn_8+0xc22>
     e7b:	mov    0x10(%r13),%rax
     e7f:	mov    %rcx,(%rax)
     e82:	movq   $0x3,0x8(%rsp)
     e8b:	mov    0x10(%r13),%rax
     e8f:	mov    0x8(%rax),%rsi
     e93:	mov    %rsi,0x10(%rsp)
     e98:	movq   $0x3,0x18(%rsp)
     ea1:	test   $0x1,%rsi
     ea8:	je     ec0 <botlish_fn_8+0x6e8>
     eae:	mov    %rsi,%rcx
     eb1:	add    $0x2,%rcx
     eb5:	seto   %al
     eb8:	test   %al,%al
     eba:	je     ed8 <botlish_fn_8+0x700>
     ec0:	mov    0xd0(%rsp),%rdx
     ec8:	mov    0x98(%rsp),%rdi
     ed0:	call   ed5 <botlish_fn_8+0x6fd>
			ed1: R_X86_64_PLT32	rt_int_add-0x4
     ed5:	mov    %rax,%rcx
     ed8:	mov    0x18(%r13),%rax
     edc:	test   %rax,%rax
     edf:	je     1414 <botlish_fn_8+0xc3c>
     ee5:	mov    0x10(%r13),%rax
     ee9:	mov    %rcx,0x8(%rax)
     eed:	mov    $0x5,%edx
     ef2:	mov    %rdx,0xc0(%rsp)
     efa:	movq   $0x5,0x8(%rsp)
     f03:	cmp    $0x1,%r12
     f07:	je     1364 <botlish_fn_8+0xb8c>
     f0d:	cmp    $0x2,%r12
     f11:	je     1119 <botlish_fn_8+0x941>
     f17:	cmp    $0x3,%r12
     f1b:	je     f5b <botlish_fn_8+0x783>
     f21:	cmp    $0x4,%r12
     f25:	je     f47 <botlish_fn_8+0x76f>
     f2b:	mov    $0xa,%esi
     f30:	cmp    $0xffffffffffffffff,%r12
     f34:	jne    126f <botlish_fn_8+0xa97>
     f3a:	mov    0xd8(%rsp),%r14
     f42:	jmp    138c <botlish_fn_8+0xbb4>
     f47:	add    $0x1,%rbx
     f4e:	mov    0xd8(%rsp),%r14
     f56:	jmp    f83 <botlish_fn_8+0x7ab>
     f5b:	mov    0xd8(%rsp),%r14
     f63:	mov    0x8(%r14),%r15
     f67:	mov    0xb8(%rsp),%r8
     f6f:	mov    %r8,%rdi
     f72:	sar    $1,%rdi
     f75:	lea    0x1(%rdi),%rbx
     f79:	shl    $1,%r15
     f7c:	or     $0x1,%r15
     f80:	sar    $1,%r15
     f83:	cmp    %r15,%rbx
     f86:	jge    136c <botlish_fn_8+0xb94>
     f8c:	movzbq 0x18(%r14),%rax
     f91:	test   %rax,%rax
     f94:	jne    fc1 <botlish_fn_8+0x7e9>
     f9a:	mov    %rbx,%rdx
     f9d:	shl    $1,%rdx
     fa0:	or     $0x1,%rdx
     fa4:	mov    %r14,%rsi
     fa7:	mov    0x98(%rsp),%rdi
     faf:	call   fb4 <botlish_fn_8+0x7dc>
			fb0: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     fb4:	mov    %rax,0xa8(%rsp)
     fbc:	jmp    ff4 <botlish_fn_8+0x81c>
     fc1:	mov    %rbx,%rax
     fc4:	shl    $1,%rax
     fc7:	or     $0x1,%rax
     fcb:	sar    $1,%rax
     fce:	movzbq 0x19(%r14,%rax,1),%rax
     fd4:	mov    %rax,0xa8(%rsp)
     fdc:	shl    $0x3,%rax
     fe0:	mov    %rax,0xa8(%rsp)
     fe8:	or     $0x4,%rax
     fec:	mov    %rax,0xa8(%rsp)
     ff4:	shr    $0x3,%rax
     ff8:	mov    %rax,0xa8(%rsp)
    1000:	shl    $1,%rax
    1003:	mov    %rax,0xa8(%rsp)
    100b:	or     $0x1,%rax
    100f:	mov    %rax,0xa8(%rsp)
    1017:	mov    0xa8(%rsp),%rsi
    101f:	mov    0x98(%rsp),%rdi
    1027:	call   102c <botlish_fn_8+0x854>
			1028: R_X86_64_PLT32	botlish_fn_2-0x4
    102c:	test   %rax,%rax
    102f:	jne    1101 <botlish_fn_8+0x929>
    1035:	mov    0x98(%rsp),%rdi
    103d:	call   1042 <botlish_fn_8+0x86a>
			103e: R_X86_64_PLT32	rt_declared_error-0x4
    1042:	cmp    $0x1,%rax
    1046:	je     10b2 <botlish_fn_8+0x8da>
    104c:	mov    0x98(%rsp),%rdi
    1054:	call   1059 <botlish_fn_8+0x881>
			1055: R_X86_64_PLT32	rt_declared_error-0x4
    1059:	cmp    $0x2,%rax
    105d:	jne    125a <botlish_fn_8+0xa82>
    1063:	mov    0x98(%rsp),%rdi
    106b:	call   1070 <botlish_fn_8+0x898>
			106c: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1070:	mov    0x98(%rsp),%rdi
    1078:	mov    0x10(%rdi),%rax
    107c:	mov    0x70(%rax),%rdx
    1080:	mov    $0x1,%r8d
    1086:	shl    $1,%rbx
    1089:	or     $0x1,%rbx
    108d:	lea    0x90(%rsp),%r9
    1095:	mov    %rbx,0x90(%rsp)
    109d:	xor    %rcx,%rcx
    10a0:	mov    0xd0(%rsp),%rsi
    10a8:	call   10ad <botlish_fn_8+0x8d5>
			10a9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    10ad:	jmp    125a <botlish_fn_8+0xa82>
    10b2:	mov    0x98(%rsp),%rdi
    10ba:	call   10bf <botlish_fn_8+0x8e7>
			10bb: R_X86_64_PLT32	rt_clear_declared_error-0x4
    10bf:	mov    0x98(%rsp),%rdi
    10c7:	mov    0x10(%rdi),%rax
    10cb:	mov    0x70(%rax),%rdx
    10cf:	mov    $0x1,%r8d
    10d5:	shl    $1,%rbx
    10d8:	or     $0x1,%rbx
    10dc:	lea    0x88(%rsp),%r9
    10e4:	mov    %rbx,0x88(%rsp)
    10ec:	xor    %rcx,%rcx
    10ef:	mov    0xd0(%rsp),%rsi
    10f7:	call   10fc <botlish_fn_8+0x924>
			10f8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    10fc:	jmp    125a <botlish_fn_8+0xa82>
    1101:	mov    0xa8(%rsp),%rax
    1109:	mov    %rax,0x28(%rsp)
    110e:	mov    $0x4,%r12d
    1114:	jmp    138c <botlish_fn_8+0xbb4>
    1119:	mov    0xd8(%rsp),%r14
    1121:	movq   $0x3,0x40(%rsp)
    112a:	mov    0xd0(%rsp),%rdx
    1132:	mov    %r14,%rsi
    1135:	mov    0x98(%rsp),%rdi
    113d:	call   1142 <botlish_fn_8+0x96a>
			113e: R_X86_64_PLT32	rt_str_char_at-0x4
    1142:	mov    %rax,%rcx
    1145:	mov    %rax,0xa8(%rsp)
    114d:	test   %rcx,%rax
    1150:	je     125a <botlish_fn_8+0xa82>
    1156:	mov    0xa8(%rsp),%rax
    115e:	shr    $0x3,%rax
    1162:	mov    %rax,0xa8(%rsp)
    116a:	shl    $1,%rax
    116d:	mov    %rax,0xa8(%rsp)
    1175:	or     $0x1,%rax
    1179:	mov    %rax,0xa8(%rsp)
    1181:	mov    0xa8(%rsp),%rsi
    1189:	mov    0x98(%rsp),%rdi
    1191:	call   1196 <botlish_fn_8+0x9be>
			1192: R_X86_64_PLT32	botlish_fn_4-0x4
    1196:	test   %rax,%rax
    1199:	jne    133a <botlish_fn_8+0xb62>
    119f:	mov    0x98(%rsp),%rdi
    11a7:	call   11ac <botlish_fn_8+0x9d4>
			11a8: R_X86_64_PLT32	rt_declared_error-0x4
    11ac:	cmp    $0x1,%rax
    11b0:	je     1219 <botlish_fn_8+0xa41>
    11b6:	mov    0x98(%rsp),%rdi
    11be:	call   11c3 <botlish_fn_8+0x9eb>
			11bf: R_X86_64_PLT32	rt_declared_error-0x4
    11c3:	cmp    $0x2,%rax
    11c7:	jne    125a <botlish_fn_8+0xa82>
    11cd:	mov    0x98(%rsp),%rdi
    11d5:	call   11da <botlish_fn_8+0xa02>
			11d6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    11da:	mov    0x98(%rsp),%rdi
    11e2:	mov    0x10(%rdi),%rax
    11e6:	mov    0x70(%rax),%rdx
    11ea:	lea    0x80(%rsp),%r9
    11f2:	movq   $0x3,0x80(%rsp)
    11fe:	xor    %rcx,%rcx
    1201:	mov    $0x1,%r8d
    1207:	mov    0xd0(%rsp),%rsi
    120f:	call   1214 <botlish_fn_8+0xa3c>
			1210: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1214:	jmp    125a <botlish_fn_8+0xa82>
    1219:	mov    0x98(%rsp),%rdi
    1221:	call   1226 <botlish_fn_8+0xa4e>
			1222: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1226:	mov    0x98(%rsp),%rdi
    122e:	mov    0x10(%rdi),%rax
    1232:	mov    0x70(%rax),%rdx
    1236:	lea    0x78(%rsp),%r9
    123b:	movq   $0x3,0x78(%rsp)
    1244:	xor    %rcx,%rcx
    1247:	mov    $0x1,%r8d
    124d:	mov    0xd0(%rsp),%rsi
    1255:	call   125a <botlish_fn_8+0xa82>
			1256: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    125a:	mov    0x98(%rsp),%rdi
    1262:	call   1267 <botlish_fn_8+0xa8f>
			1263: R_X86_64_PLT32	rt_co_failed-0x4
    1267:	mov    %rax,0x30(%rsp)
    126c:	mov    %rax,%rsi
    126f:	mov    0x98(%rsp),%rdi
    1277:	call   127c <botlish_fn_8+0xaa4>
			1278: R_X86_64_PLT32	rt_co_resume0-0x4
    127c:	test   %rax,%rax
    127f:	je     129e <botlish_fn_8+0xac6>
    1285:	mov    0x98(%rsp),%rdi
    128d:	mov    0x10(%rdi),%rax
    1291:	mov    0x40(%rax),%rsi
    1295:	mov    0x68(%rax),%rdx
    1299:	call   129e <botlish_fn_8+0xac6>
			129a: R_X86_64_PLT32	rt_raise-0x4
    129e:	mov    0x98(%rsp),%rdi
    12a6:	call   12ab <botlish_fn_8+0xad3>
			12a7: R_X86_64_PLT32	rt_declared_error-0x4
    12ab:	cmp    $0x40000001,%rax
    12b1:	je     12e8 <botlish_fn_8+0xb10>
    12b7:	mov    0x98(%rsp),%rdi
    12bf:	call   12c4 <botlish_fn_8+0xaec>
			12c0: R_X86_64_PLT32	rt_declared_error-0x4
    12c4:	cmp    $0x3,%rax
    12c8:	je     12db <botlish_fn_8+0xb03>
    12ce:	mov    0x98(%rsp),%rdi
    12d6:	jmp    12f0 <botlish_fn_8+0xb18>
    12db:	mov    0x98(%rsp),%rdi
    12e3:	jmp    12f0 <botlish_fn_8+0xb18>
    12e8:	mov    0x98(%rsp),%rdi
    12f0:	mov    0x98(%rsp),%rdi
    12f8:	call   12fd <botlish_fn_8+0xb25>
			12f9: R_X86_64_PLT32	rt_declared_error-0x4
    12fd:	cmp    $0x40000001,%rax
    1303:	xor    %rax,%rax
    1306:	mov    0xe0(%rsp),%rbx
    130e:	mov    0xe8(%rsp),%r12
    1316:	mov    0xf0(%rsp),%r13
    131e:	mov    0xf8(%rsp),%r14
    1326:	mov    0x100(%rsp),%r15
    132e:	add    $0x110,%rsp
    1335:	mov    %rbp,%rsp
    1338:	pop    %rbp
    1339:	ret
    133a:	mov    0xa8(%rsp),%rax
    1342:	mov    %rax,0x28(%rsp)
    1347:	mov    0xd0(%rsp),%r12
    134f:	mov    0xd0(%rsp),%rax
    1357:	mov    %rax,0xb8(%rsp)
    135f:	jmp    138c <botlish_fn_8+0xbb4>
    1364:	mov    0xd8(%rsp),%r14
    136c:	mov    $0xffffffffffffffff,%rax
    1373:	mov    %rax,0xa8(%rsp)
    137b:	movq   $0xffffffffffffffff,0x28(%rsp)
    1384:	mov    0xa8(%rsp),%r12
    138c:	mov    0x18(%r13),%r9
    1390:	test   %r9,%r9
    1393:	je     1431 <botlish_fn_8+0xc59>
    1399:	mov    0x10(%r13),%rax
    139d:	mov    0xa8(%rsp),%rcx
    13a5:	mov    %rcx,0x10(%rax)
    13a9:	mov    %r14,0xd8(%rsp)
    13b1:	jmp    cbe <botlish_fn_8+0x4e6>
    13b6:	mov    0xb0(%rsp),%rcx
    13be:	add    $0x1,%rcx
    13c5:	mov    0xa0(%rsp),%rax
    13cd:	mov    %r13,%rdx
    13d0:	jmp    8b5 <botlish_fn_8+0xdd>
    13d5:	mov    $0x5,%edx
    13da:	mov    %r14,%rcx
    13dd:	mov    %r13,%rsi
    13e0:	mov    0x98(%rsp),%rdi
    13e8:	call   13ed <botlish_fn_8+0xc15>
			13e9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    13ed:	mov    %r14,0xa8(%rsp)
    13f5:	jmp    c9a <botlish_fn_8+0x4c2>
    13fa:	mov    $0x1,%edx
    13ff:	mov    %r13,%rsi
    1402:	mov    0x98(%rsp),%rdi
    140a:	call   140f <botlish_fn_8+0xc37>
			140b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    140f:	jmp    e82 <botlish_fn_8+0x6aa>
    1414:	mov    0xd0(%rsp),%rdx
    141c:	mov    %r13,%rsi
    141f:	mov    0x98(%rsp),%rdi
    1427:	call   142c <botlish_fn_8+0xc54>
			1428: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    142c:	jmp    eed <botlish_fn_8+0x715>
    1431:	mov    0xc0(%rsp),%rdx
    1439:	mov    0xa8(%rsp),%rcx
    1441:	mov    %r13,%rsi
    1444:	mov    0x98(%rsp),%rdi
    144c:	call   1451 <botlish_fn_8+0xc79>
			144d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1451:	jmp    13a9 <botlish_fn_8+0xbd1>
    1456:	add    %al,(%rax)
    1458:	(bad)
    1459:	add    %al,(%rax)
    145b:	add    %al,(%rax)
    145d:	add    %al,(%rax)
    145f:	add    %bh,(%rsi)
    1461:	add    %al,(%rax)
    1463:	add    %al,(%rax)
    1465:	add    %al,(%rax)
    1467:	add    %al,(%rbx)
    1469:	add    %al,(%rax)
    146b:	add    %al,(%rcx)
    146d:	add    %al,(%rax)
    146f:	.byte 0x80

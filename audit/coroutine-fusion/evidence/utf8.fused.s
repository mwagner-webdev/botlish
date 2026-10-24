<botlish_fn_3>:
     7a8:	push   %rbp
     7a9:	mov    %rsp,%rbp
     7ac:	sub    $0x160,%rsp
     7b3:	mov    %rbx,0x130(%rsp)
     7bb:	mov    %r12,0x138(%rsp)
     7c3:	mov    %r13,0x140(%rsp)
     7cb:	mov    %r14,0x148(%rsp)
     7d3:	mov    %r15,0x150(%rsp)
     7db:	mov    %rdi,0xb8(%rsp)
     7e3:	movq   $0x0,0x8(%rsp)
     7ec:	movq   $0x0,0x10(%rsp)
     7f5:	movq   $0x0,0x18(%rsp)
     7fe:	movq   $0x0,0x20(%rsp)
     807:	movq   $0x0,0x28(%rsp)
     810:	movq   $0x0,0x30(%rsp)
     819:	movq   $0x0,0x38(%rsp)
     822:	movq   $0x0,0x40(%rsp)
     82b:	mov    %rsi,(%rsp)
     82f:	mov    %rsi,0xc0(%rsp)
     837:	movq   $0xa,0x58(%rsp)
     840:	movq   $0xa,0x60(%rsp)
     849:	movq   $0xa,0x68(%rsp)
     852:	movq   $0xa,0x70(%rsp)
     85b:	movq   $0xa,0x78(%rsp)
     864:	movq   $0xa,0x80(%rsp)
     870:	movq   $0xa,0x48(%rsp)
     879:	movq   $0xa,0x50(%rsp)
     882:	movq   $0x3,0x48(%rsp)
     88b:	mov    $0x3,%edx
     890:	movq   $0x3,0x8(%rsp)
     899:	movq   $0x3,0x10(%rsp)
     8a2:	mov    0xb8(%rsp),%rdi
     8aa:	mov    %rdx,%rsi
     8ad:	call   8b2 <botlish_fn_3+0x10a>
			8ae: R_X86_64_PLT32	rt_mutarray_create-0x4
     8b2:	test   %rax,%rax
     8b5:	je     16e1 <botlish_fn_3+0xf39>
     8bb:	mov    %rax,0x8(%rsp)
     8c0:	mov    %rax,0x120(%rsp)
     8c8:	mov    0xc0(%rsp),%rsi
     8d0:	mov    0xb8(%rsp),%rdi
     8d8:	call   8dd <botlish_fn_3+0x135>
			8d9: R_X86_64_PLT32	rt_list_len-0x4
     8dd:	mov    %rax,%r15
     8e0:	mov    %r15,0x10(%rsp)
     8e5:	mov    %r15,0x118(%rsp)
     8ed:	mov    $0x1,%esi
     8f2:	mov    %rsi,0xe0(%rsp)
     8fa:	movq   $0x1,0x18(%rsp)
     903:	mov    $0xa,%ecx
     908:	mov    %rcx,0xe8(%rsp)
     910:	mov    $0x3,%ebx
     915:	xor    %r13,%r13
     918:	mov    0x118(%rsp),%rcx
     920:	mov    0xe0(%rsp),%r12
     928:	mov    0xe8(%rsp),%rax
     930:	mov    %rax,0xf0(%rsp)
     938:	mov    %rax,0xf8(%rsp)
     940:	mov    %rax,0x100(%rsp)
     948:	mov    %rax,0x108(%rsp)
     950:	mov    %rax,0x110(%rsp)
     958:	mov    %rsi,%rax
     95b:	and    %rcx,%rax
     95e:	mov    %rsi,0xe0(%rsp)
     966:	test   $0x1,%rax
     96c:	jne    9a4 <botlish_fn_3+0x1fc>
     972:	mov    0x118(%rsp),%rdx
     97a:	mov    0xe0(%rsp),%rsi
     982:	mov    0xb8(%rsp),%rdi
     98a:	call   98f <botlish_fn_3+0x1e7>
			98b: R_X86_64_PLT32	rt_int_cmp-0x4
     98f:	mov    $0x2,%ecx
     994:	test   %rax,%rax
     997:	cmovl  0xe31(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     99f:	jmp    9c4 <botlish_fn_3+0x21c>
     9a4:	mov    $0x2,%ecx
     9a9:	mov    0x118(%rsp),%rax
     9b1:	mov    0xe0(%rsp),%rsi
     9b9:	cmp    %rax,%rsi
     9bc:	cmovl  0xe0c(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     9c4:	cmp    $0x6,%rcx
     9c8:	je     a11 <botlish_fn_3+0x269>
     9ce:	mov    0x120(%rsp),%r8
     9d6:	mov    0x10(%r8),%rax
     9da:	mov    (%rax),%rax
     9dd:	mov    0x130(%rsp),%rbx
     9e5:	mov    0x138(%rsp),%r12
     9ed:	mov    0x140(%rsp),%r13
     9f5:	mov    0x148(%rsp),%r14
     9fd:	mov    0x150(%rsp),%r15
     a05:	add    $0x160,%rsp
     a0c:	mov    %rbp,%rsp
     a0f:	pop    %rbp
     a10:	ret
     a11:	mov    0xe0(%rsp),%rsi
     a19:	test   $0x1,%rsi
     a20:	je     a49 <botlish_fn_3+0x2a1>
     a26:	mov    0xc0(%rsp),%rcx
     a2e:	mov    0x8(%rcx),%rcx
     a32:	mov    0xe0(%rsp),%rsi
     a3a:	mov    %rsi,%rax
     a3d:	sar    $1,%rax
     a40:	cmp    %rcx,%rax
     a43:	jb     a87 <botlish_fn_3+0x2df>
     a49:	mov    0xe0(%rsp),%rdx
     a51:	mov    0xc0(%rsp),%rsi
     a59:	mov    0xb8(%rsp),%rdi
     a61:	call   a66 <botlish_fn_3+0x2be>
			a62: R_X86_64_PLT32	rt_list_get-0x4
     a66:	mov    %rax,%rcx
     a69:	mov    %rax,0xd8(%rsp)
     a71:	test   %rcx,%rax
     a74:	je     16e1 <botlish_fn_3+0xf39>
     a7a:	mov    0xd8(%rsp),%rax
     a82:	jmp    a9f <botlish_fn_3+0x2f7>
     a87:	mov    0xc0(%rsp),%rcx
     a8f:	mov    0x10(%rcx),%rcx
     a93:	mov    (%rcx,%rax,8),%rax
     a97:	mov    %rax,0xd8(%rsp)
     a9f:	mov    %rax,0x20(%rsp)
     aa4:	mov    0xd8(%rsp),%rsi
     aac:	mov    0xb8(%rsp),%rdi
     ab4:	call   ab9 <botlish_fn_3+0x311>
			ab5: R_X86_64_PLT32	rt_list_len-0x4
     ab9:	mov    %rax,0x28(%rsp)
     abe:	mov    %rax,%r14
     ac1:	movq   $0x1,0x30(%rsp)
     aca:	xor    %rdx,%rdx
     acd:	mov    0xb8(%rsp),%rdi
     ad5:	mov    %rdx,%rsi
     ad8:	call   add <botlish_fn_3+0x335>
			ad9: R_X86_64_PLT32	rt_list_new-0x4
     add:	test   %rax,%rax
     ae0:	je     16e1 <botlish_fn_3+0xf39>
     ae6:	mov    %rax,0x38(%rsp)
     aeb:	mov    %rax,0xc8(%rsp)
     af3:	mov    $0x1,%esi
     af8:	mov    %rsi,0xd0(%rsp)
     b00:	mov    %r14,%r15
     b03:	mov    %rsi,%rax
     b06:	and    %r15,%rax
     b09:	mov    %rsi,0xd0(%rsp)
     b11:	test   $0x1,%rax
     b17:	jne    b4a <botlish_fn_3+0x3a2>
     b1d:	mov    %r15,%rdx
     b20:	mov    0xd0(%rsp),%rsi
     b28:	mov    0xb8(%rsp),%rdi
     b30:	call   b35 <botlish_fn_3+0x38d>
			b31: R_X86_64_PLT32	rt_int_cmp-0x4
     b35:	mov    $0x2,%ecx
     b3a:	test   %rax,%rax
     b3d:	cmovl  0xc8b(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     b45:	jmp    b62 <botlish_fn_3+0x3ba>
     b4a:	mov    $0x2,%ecx
     b4f:	mov    0xd0(%rsp),%rsi
     b57:	cmp    %r15,%rsi
     b5a:	cmovl  0xc6e(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     b62:	cmp    $0x6,%rcx
     b66:	je     c33 <botlish_fn_3+0x48b>
     b6c:	lea    0xa8(%rsp),%rcx
     b74:	movq   $0x0,0xa8(%rsp)
     b80:	mov    0xc8(%rsp),%rax
     b88:	mov    %rax,0xb0(%rsp)
     b90:	mov    $0x1,%esi
     b95:	mov    $0x2,%edx
     b9a:	mov    0xb8(%rsp),%rdi
     ba2:	call   ba7 <botlish_fn_3+0x3ff>
			ba3: R_X86_64_PLT32	rt_construct-0x4
     ba7:	test   %rax,%rax
     baa:	je     16e1 <botlish_fn_3+0xf39>
     bb0:	movq   $0x3,0x20(%rsp)
     bb9:	mov    0xe0(%rsp),%rsi
     bc1:	test   $0x1,%rsi
     bc8:	je     bf4 <botlish_fn_3+0x44c>
     bce:	mov    0xe0(%rsp),%rsi
     bd6:	add    $0x2,%rsi
     bda:	seto   %dil
     bde:	test   %dil,%dil
     be1:	jne    bf4 <botlish_fn_3+0x44c>
     be7:	mov    %rsi,0xe0(%rsp)
     bef:	jmp    c19 <botlish_fn_3+0x471>
     bf4:	mov    $0x3,%edx
     bf9:	mov    0xe0(%rsp),%rsi
     c01:	mov    0xb8(%rsp),%rdi
     c09:	call   c0e <botlish_fn_3+0x466>
			c0a: R_X86_64_PLT32	rt_int_add-0x4
     c0e:	mov    %rax,%rsi
     c11:	mov    %rax,0xe0(%rsp)
     c19:	mov    %rsi,0x18(%rsp)
     c1e:	mov    0x118(%rsp),%rcx
     c26:	mov    0xe0(%rsp),%rsi
     c2e:	jmp    958 <botlish_fn_3+0x1b0>
     c33:	mov    0xd0(%rsp),%rsi
     c3b:	test   $0x1,%rsi
     c42:	jne    c55 <botlish_fn_3+0x4ad>
     c48:	mov    0xd8(%rsp),%r14
     c50:	jmp    c78 <botlish_fn_3+0x4d0>
     c55:	mov    0xd8(%rsp),%r14
     c5d:	mov    0x8(%r14),%rax
     c61:	mov    0xd0(%rsp),%rsi
     c69:	mov    %rsi,%rcx
     c6c:	sar    $1,%rcx
     c6f:	cmp    %rax,%rcx
     c72:	jb     ca9 <botlish_fn_3+0x501>
     c78:	mov    0xd0(%rsp),%rdx
     c80:	mov    %r14,%rsi
     c83:	mov    0xb8(%rsp),%rdi
     c8b:	call   c90 <botlish_fn_3+0x4e8>
			c8c: R_X86_64_PLT32	rt_list_get-0x4
     c90:	mov    %r14,0xd8(%rsp)
     c98:	test   %rax,%rax
     c9b:	je     16e1 <botlish_fn_3+0xf39>
     ca1:	mov    %rax,%rsi
     ca4:	jmp    cbc <botlish_fn_3+0x514>
     ca9:	mov    %r14,%rax
     cac:	mov    %r14,0xd8(%rsp)
     cb4:	mov    0x10(%rax),%rax
     cb8:	mov    (%rax,%rcx,8),%rsi
     cbc:	cmp    $0x1,%r12
     cc0:	je     1170 <botlish_fn_3+0x9c8>
     cc6:	cmp    $0x2,%r12
     cca:	je     f9e <botlish_fn_3+0x7f6>
     cd0:	cmp    $0x3,%r12
     cd4:	je     e84 <botlish_fn_3+0x6dc>
     cda:	cmp    $0x4,%r12
     cde:	je     d61 <botlish_fn_3+0x5b9>
     ce4:	cmp    $0xffffffffffffffff,%r12
     ce8:	jne    cfb <botlish_fn_3+0x553>
     cee:	mov    0x120(%rsp),%r14
     cf6:	jmp    165d <botlish_fn_3+0xeb5>
     cfb:	mov    $0xa,%esi
     d00:	mov    0xb8(%rsp),%rdi
     d08:	call   d0d <botlish_fn_3+0x565>
			d09: R_X86_64_PLT32	rt_co_resume0-0x4
     d0d:	test   %rax,%rax
     d10:	jne    d23 <botlish_fn_3+0x57b>
     d16:	mov    0xb8(%rsp),%rdi
     d1e:	jmp    d43 <botlish_fn_3+0x59b>
     d23:	mov    0xb8(%rsp),%rdi
     d2b:	mov    0x10(%rdi),%rax
     d2f:	mov    (%rax),%rsi
     d32:	mov    0x18(%rax),%rdx
     d36:	call   d3b <botlish_fn_3+0x593>
			d37: R_X86_64_PLT32	rt_raise-0x4
     d3b:	mov    0xb8(%rsp),%rdi
     d43:	mov    0xb8(%rsp),%rdi
     d4b:	call   d50 <botlish_fn_3+0x5a8>
			d4c: R_X86_64_PLT32	rt_declared_error-0x4
     d50:	cmp    $0x40000001,%rax
     d56:	jne    16e1 <botlish_fn_3+0xf39>
     d5c:	jmp    16e1 <botlish_fn_3+0xf39>
     d61:	mov    0xf8(%rsp),%rbx
     d69:	mov    %rsi,%rax
     d6c:	and    %rbx,%rax
     d6f:	mov    %rsi,%r12
     d72:	test   $0x1,%rax
     d78:	jne    daf <botlish_fn_3+0x607>
     d7e:	mov    %rbx,%rdx
     d81:	mov    %r12,%rsi
     d84:	mov    0xb8(%rsp),%rdi
     d8c:	call   d91 <botlish_fn_3+0x5e9>
			d8d: R_X86_64_PLT32	rt_int_cmp-0x4
     d91:	mov    %rbx,0xf8(%rsp)
     d99:	mov    $0x2,%r11d
     d9f:	test   %rax,%rax
     da2:	cmovge 0xa26(%rip),%r11        # 17d0 <botlish_fn_3+0x1028>
     daa:	jmp    dd3 <botlish_fn_3+0x62b>
     daf:	mov    %rbx,0xf8(%rsp)
     db7:	mov    $0x2,%r11d
     dbd:	mov    0xf8(%rsp),%rcx
     dc5:	mov    %r12,%rsi
     dc8:	cmp    %rcx,%rsi
     dcb:	cmovge 0x9fd(%rip),%r11        # 17d0 <botlish_fn_3+0x1028>
     dd3:	cmp    $0x6,%r11
     dd7:	je     de7 <botlish_fn_3+0x63f>
     ddd:	mov    $0x2,%ecx
     de2:	jmp    e70 <botlish_fn_3+0x6c8>
     de7:	mov    0x110(%rsp),%rbx
     def:	mov    %r12,%rsi
     df2:	mov    %rsi,%rax
     df5:	and    %rbx,%rax
     df8:	test   $0x1,%rax
     dfe:	jne    e34 <botlish_fn_3+0x68c>
     e04:	mov    %r12,%rsi
     e07:	mov    %rbx,%rdx
     e0a:	mov    0xb8(%rsp),%rdi
     e12:	call   e17 <botlish_fn_3+0x66f>
			e13: R_X86_64_PLT32	rt_int_cmp-0x4
     e17:	mov    %rbx,0x110(%rsp)
     e1f:	mov    $0x2,%ecx
     e24:	test   %rax,%rax
     e27:	cmovle 0x9a1(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     e2f:	jmp    e57 <botlish_fn_3+0x6af>
     e34:	mov    %rbx,0x110(%rsp)
     e3c:	mov    $0x2,%ecx
     e41:	mov    0x110(%rsp),%rax
     e49:	mov    %r12,%rsi
     e4c:	cmp    %rax,%rsi
     e4f:	cmovle 0x979(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     e57:	cmp    $0x6,%rcx
     e5b:	je     e6b <botlish_fn_3+0x6c3>
     e61:	mov    $0x2,%ecx
     e66:	jmp    e70 <botlish_fn_3+0x6c8>
     e6b:	mov    $0x6,%ecx
     e70:	cmp    $0x6,%rcx
     e74:	je     1166 <botlish_fn_3+0x9be>
     e7a:	mov    $0x2,%ecx
     e7f:	jmp    15dc <botlish_fn_3+0xe34>
     e84:	mov    0xf0(%rsp),%rbx
     e8c:	mov    %rsi,%r12
     e8f:	and    %rbx,%rsi
     e92:	test   $0x1,%rsi
     e99:	jne    ecf <botlish_fn_3+0x727>
     e9f:	mov    %rbx,%rdx
     ea2:	mov    %r12,%rsi
     ea5:	mov    0xb8(%rsp),%rdi
     ead:	call   eb2 <botlish_fn_3+0x70a>
			eae: R_X86_64_PLT32	rt_int_cmp-0x4
     eb2:	mov    %rbx,0xf0(%rsp)
     eba:	mov    $0x2,%ecx
     ebf:	test   %rax,%rax
     ec2:	cmovge 0x906(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     eca:	jmp    ef2 <botlish_fn_3+0x74a>
     ecf:	mov    %rbx,0xf0(%rsp)
     ed7:	mov    $0x2,%ecx
     edc:	mov    0xf0(%rsp),%rdx
     ee4:	mov    %r12,%rsi
     ee7:	cmp    %rdx,%rsi
     eea:	cmovge 0x8de(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     ef2:	cmp    $0x6,%rcx
     ef6:	je     f06 <botlish_fn_3+0x75e>
     efc:	mov    $0x2,%ecx
     f01:	jmp    f8f <botlish_fn_3+0x7e7>
     f06:	mov    0x108(%rsp),%rbx
     f0e:	mov    %r12,%rsi
     f11:	mov    %rsi,%rax
     f14:	and    %rbx,%rax
     f17:	test   $0x1,%rax
     f1d:	jne    f53 <botlish_fn_3+0x7ab>
     f23:	mov    %r12,%rsi
     f26:	mov    %rbx,%rdx
     f29:	mov    0xb8(%rsp),%rdi
     f31:	call   f36 <botlish_fn_3+0x78e>
			f32: R_X86_64_PLT32	rt_int_cmp-0x4
     f36:	mov    %rbx,0x108(%rsp)
     f3e:	mov    $0x2,%ecx
     f43:	test   %rax,%rax
     f46:	cmovle 0x882(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     f4e:	jmp    f76 <botlish_fn_3+0x7ce>
     f53:	mov    %rbx,0x108(%rsp)
     f5b:	mov    $0x2,%ecx
     f60:	mov    0x108(%rsp),%rax
     f68:	mov    %r12,%rsi
     f6b:	cmp    %rax,%rsi
     f6e:	cmovle 0x85a(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     f76:	cmp    $0x6,%rcx
     f7a:	je     f8a <botlish_fn_3+0x7e2>
     f80:	mov    $0x2,%ecx
     f85:	jmp    f8f <botlish_fn_3+0x7e7>
     f8a:	mov    $0x6,%ecx
     f8f:	cmp    $0x6,%rcx
     f93:	je     110c <botlish_fn_3+0x964>
     f99:	jmp    15d7 <botlish_fn_3+0xe2f>
     f9e:	mov    0xe8(%rsp),%rbx
     fa6:	mov    %rsi,%r12
     fa9:	mov    %rsi,%rax
     fac:	and    %rbx,%rax
     faf:	test   $0x1,%rax
     fb5:	jne    feb <botlish_fn_3+0x843>
     fbb:	mov    %rbx,%rdx
     fbe:	mov    %r12,%rsi
     fc1:	mov    0xb8(%rsp),%rdi
     fc9:	call   fce <botlish_fn_3+0x826>
			fca: R_X86_64_PLT32	rt_int_cmp-0x4
     fce:	mov    %rbx,0xe8(%rsp)
     fd6:	mov    $0x2,%ecx
     fdb:	test   %rax,%rax
     fde:	cmovge 0x7ea(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
     fe6:	jmp    100e <botlish_fn_3+0x866>
     feb:	mov    %rbx,0xe8(%rsp)
     ff3:	mov    $0x2,%ecx
     ff8:	mov    0xe8(%rsp),%rax
    1000:	mov    %r12,%rsi
    1003:	cmp    %rax,%rsi
    1006:	cmovge 0x7c2(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    100e:	cmp    $0x6,%rcx
    1012:	je     1022 <botlish_fn_3+0x87a>
    1018:	mov    $0x2,%ecx
    101d:	jmp    10ab <botlish_fn_3+0x903>
    1022:	mov    0x100(%rsp),%rbx
    102a:	mov    %r12,%rsi
    102d:	mov    %rsi,%rax
    1030:	and    %rbx,%rax
    1033:	test   $0x1,%rax
    1039:	jne    106f <botlish_fn_3+0x8c7>
    103f:	mov    %r12,%rsi
    1042:	mov    %rbx,%rdx
    1045:	mov    0xb8(%rsp),%rdi
    104d:	call   1052 <botlish_fn_3+0x8aa>
			104e: R_X86_64_PLT32	rt_int_cmp-0x4
    1052:	mov    %rbx,0x100(%rsp)
    105a:	mov    $0x2,%ecx
    105f:	test   %rax,%rax
    1062:	cmovle 0x766(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    106a:	jmp    1092 <botlish_fn_3+0x8ea>
    106f:	mov    %rbx,0x100(%rsp)
    1077:	mov    $0x2,%ecx
    107c:	mov    0x100(%rsp),%rax
    1084:	mov    %r12,%rsi
    1087:	cmp    %rax,%rsi
    108a:	cmovle 0x73e(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    1092:	cmp    $0x6,%rcx
    1096:	je     10a6 <botlish_fn_3+0x8fe>
    109c:	mov    $0x2,%ecx
    10a1:	jmp    10ab <botlish_fn_3+0x903>
    10a6:	mov    $0x6,%ecx
    10ab:	cmp    $0x6,%rcx
    10af:	jne    15d7 <botlish_fn_3+0xe2f>
    10b5:	cmp    $0x2,%r13
    10b9:	jl     110c <botlish_fn_3+0x964>
    10bf:	movq   $0x101,0x68(%rsp)
    10c8:	movq   $0x17f,0x70(%rsp)
    10d1:	mov    $0x1,%ebx
    10d6:	movq   $0x1,0x48(%rsp)
    10df:	mov    $0x3,%r12d
    10e5:	mov    $0x101,%ecx
    10ea:	mov    %rcx,0xf0(%rsp)
    10f2:	mov    $0x17f,%ecx
    10f7:	mov    %rcx,0x108(%rsp)
    10ff:	mov    0x120(%rsp),%r14
    1107:	jmp    165d <botlish_fn_3+0xeb5>
    110c:	cmp    $0x3,%r13
    1110:	jl     1166 <botlish_fn_3+0x9be>
    1116:	mov    $0x101,%ecx
    111b:	mov    %rcx,0xf8(%rsp)
    1123:	movq   $0x101,0x78(%rsp)
    112c:	mov    $0x17f,%ecx
    1131:	mov    %rcx,0x110(%rsp)
    1139:	movq   $0x17f,0x80(%rsp)
    1145:	mov    $0x1,%ebx
    114a:	movq   $0x1,0x48(%rsp)
    1153:	mov    $0x4,%r12d
    1159:	mov    0x120(%rsp),%r14
    1161:	jmp    165d <botlish_fn_3+0xeb5>
    1166:	mov    $0x6,%ecx
    116b:	jmp    15dc <botlish_fn_3+0xe34>
    1170:	mov    %rsi,%r12
    1173:	test   $0x1,%rsi
    117a:	jne    11aa <botlish_fn_3+0xa02>
    1180:	mov    $0x101,%edx
    1185:	mov    %r12,%rsi
    1188:	mov    0xb8(%rsp),%rdi
    1190:	call   1195 <botlish_fn_3+0x9ed>
			1191: R_X86_64_PLT32	rt_int_cmp-0x4
    1195:	mov    $0x2,%ecx
    119a:	test   %rax,%rax
    119d:	cmovge 0x62b(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    11a5:	jmp    11c1 <botlish_fn_3+0xa19>
    11aa:	mov    $0x2,%ecx
    11af:	mov    %r12,%rsi
    11b2:	cmp    $0x101,%rsi
    11b9:	cmovge 0x60f(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    11c1:	cmp    $0x6,%rcx
    11c5:	jne    1606 <botlish_fn_3+0xe5e>
    11cb:	mov    %r12,%rsi
    11ce:	test   $0x1,%rsi
    11d5:	jne    1205 <botlish_fn_3+0xa5d>
    11db:	mov    $0x185,%edx
    11e0:	mov    %r12,%rsi
    11e3:	mov    0xb8(%rsp),%rdi
    11eb:	call   11f0 <botlish_fn_3+0xa48>
			11ec: R_X86_64_PLT32	rt_int_cmp-0x4
    11f0:	mov    $0x2,%ecx
    11f5:	test   %rax,%rax
    11f8:	cmovge 0x5d0(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    1200:	jmp    121c <botlish_fn_3+0xa74>
    1205:	mov    $0x2,%ecx
    120a:	mov    %r12,%rsi
    120d:	cmp    $0x185,%rsi
    1214:	cmovge 0x5b4(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    121c:	cmp    $0x6,%rcx
    1220:	je     122e <botlish_fn_3+0xa86>
    1226:	mov    %r12,%rsi
    1229:	jmp    128c <botlish_fn_3+0xae4>
    122e:	mov    %r12,%rsi
    1231:	test   $0x1,%rsi
    1238:	jne    1268 <botlish_fn_3+0xac0>
    123e:	mov    $0x1bf,%edx
    1243:	mov    %r12,%rsi
    1246:	mov    0xb8(%rsp),%rdi
    124e:	call   1253 <botlish_fn_3+0xaab>
			124f: R_X86_64_PLT32	rt_int_cmp-0x4
    1253:	mov    $0x2,%ecx
    1258:	test   %rax,%rax
    125b:	cmovle 0x56d(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    1263:	jmp    127f <botlish_fn_3+0xad7>
    1268:	mov    $0x2,%ecx
    126d:	mov    %r12,%rsi
    1270:	cmp    $0x1bf,%rsi
    1277:	cmovle 0x551(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    127f:	cmp    $0x6,%rcx
    1283:	je     1421 <botlish_fn_3+0xc79>
    1289:	mov    %r12,%rsi
    128c:	test   $0x1,%rsi
    1293:	jne    12c3 <botlish_fn_3+0xb1b>
    1299:	mov    $0x1c1,%edx
    129e:	mov    %r12,%rsi
    12a1:	mov    0xb8(%rsp),%rdi
    12a9:	call   12ae <botlish_fn_3+0xb06>
			12aa: R_X86_64_PLT32	rt_int_cmp-0x4
    12ae:	mov    $0x2,%ecx
    12b3:	test   %rax,%rax
    12b6:	cmovge 0x512(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    12be:	jmp    12da <botlish_fn_3+0xb32>
    12c3:	mov    $0x2,%ecx
    12c8:	mov    %r12,%rsi
    12cb:	cmp    $0x1c1,%rsi
    12d2:	cmovge 0x4f6(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    12da:	cmp    $0x6,%rcx
    12de:	je     12ec <botlish_fn_3+0xb44>
    12e4:	mov    %r12,%rsi
    12e7:	jmp    134a <botlish_fn_3+0xba2>
    12ec:	mov    %r12,%rsi
    12ef:	test   $0x1,%rsi
    12f6:	jne    1326 <botlish_fn_3+0xb7e>
    12fc:	mov    $0x1df,%edx
    1301:	mov    %r12,%rsi
    1304:	mov    0xb8(%rsp),%rdi
    130c:	call   1311 <botlish_fn_3+0xb69>
			130d: R_X86_64_PLT32	rt_int_cmp-0x4
    1311:	mov    $0x2,%ecx
    1316:	test   %rax,%rax
    1319:	cmovle 0x4af(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    1321:	jmp    133d <botlish_fn_3+0xb95>
    1326:	mov    $0x2,%ecx
    132b:	mov    %r12,%rsi
    132e:	cmp    $0x1df,%rsi
    1335:	cmovle 0x493(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    133d:	cmp    $0x6,%rcx
    1341:	je     1413 <botlish_fn_3+0xc6b>
    1347:	mov    %r12,%rsi
    134a:	test   $0x1,%rsi
    1351:	jne    1381 <botlish_fn_3+0xbd9>
    1357:	mov    $0x1e1,%edx
    135c:	mov    %r12,%rsi
    135f:	mov    0xb8(%rsp),%rdi
    1367:	call   136c <botlish_fn_3+0xbc4>
			1368: R_X86_64_PLT32	rt_int_cmp-0x4
    136c:	mov    $0x2,%ecx
    1371:	test   %rax,%rax
    1374:	cmovge 0x454(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    137c:	jmp    1398 <botlish_fn_3+0xbf0>
    1381:	mov    $0x2,%ecx
    1386:	mov    %r12,%rsi
    1389:	cmp    $0x1e1,%rsi
    1390:	cmovge 0x438(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    1398:	cmp    $0x6,%rcx
    139c:	jne    13fd <botlish_fn_3+0xc55>
    13a2:	mov    %r12,%rsi
    13a5:	test   $0x1,%rsi
    13ac:	jne    13dc <botlish_fn_3+0xc34>
    13b2:	mov    $0x1e9,%edx
    13b7:	mov    %r12,%rsi
    13ba:	mov    0xb8(%rsp),%rdi
    13c2:	call   13c7 <botlish_fn_3+0xc1f>
			13c3: R_X86_64_PLT32	rt_int_cmp-0x4
    13c7:	mov    $0x2,%ecx
    13cc:	test   %rax,%rax
    13cf:	cmovle 0x3f9(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    13d7:	jmp    13f3 <botlish_fn_3+0xc4b>
    13dc:	mov    $0x2,%ecx
    13e1:	mov    %r12,%rsi
    13e4:	cmp    $0x1e9,%rsi
    13eb:	cmovle 0x3dd(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    13f3:	cmp    $0x6,%rcx
    13f7:	je     1408 <botlish_fn_3+0xc60>
    13fd:	mov    $0x1,%r13d
    1403:	jmp    1419 <botlish_fn_3+0xc71>
    1408:	mov    $0x7,%r13d
    140e:	jmp    1419 <botlish_fn_3+0xc71>
    1413:	mov    $0x5,%r13d
    1419:	mov    %r12,%rsi
    141c:	jmp    142a <botlish_fn_3+0xc82>
    1421:	mov    $0x3,%r13d
    1427:	mov    %r12,%rsi
    142a:	test   $0x1,%rsi
    1431:	jne    1461 <botlish_fn_3+0xcb9>
    1437:	mov    $0x1c1,%edx
    143c:	mov    %r12,%rsi
    143f:	mov    0xb8(%rsp),%rdi
    1447:	call   144c <botlish_fn_3+0xca4>
			1448: R_X86_64_PLT32	rt_int_cmp-0x4
    144c:	mov    $0x2,%edx
    1451:	test   %rax,%rax
    1454:	cmove  0x374(%rip),%rdx        # 17d0 <botlish_fn_3+0x1028>
    145c:	jmp    1478 <botlish_fn_3+0xcd0>
    1461:	mov    $0x2,%edx
    1466:	mov    %r12,%rsi
    1469:	cmp    $0x1c1,%rsi
    1470:	cmove  0x358(%rip),%rdx        # 17d0 <botlish_fn_3+0x1028>
    1478:	cmp    $0x6,%rdx
    147c:	je     14f6 <botlish_fn_3+0xd4e>
    1482:	mov    %r12,%rsi
    1485:	test   $0x1,%rsi
    148c:	jne    14bc <botlish_fn_3+0xd14>
    1492:	mov    $0x1e1,%edx
    1497:	mov    %r12,%rsi
    149a:	mov    0xb8(%rsp),%rdi
    14a2:	call   14a7 <botlish_fn_3+0xcff>
			14a3: R_X86_64_PLT32	rt_int_cmp-0x4
    14a7:	mov    $0x2,%ecx
    14ac:	test   %rax,%rax
    14af:	cmove  0x319(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    14b7:	jmp    14d3 <botlish_fn_3+0xd2b>
    14bc:	mov    $0x2,%ecx
    14c1:	mov    %r12,%rsi
    14c4:	cmp    $0x1e1,%rsi
    14cb:	cmove  0x2fd(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    14d3:	cmp    $0x6,%rcx
    14d7:	je     14e8 <botlish_fn_3+0xd40>
    14dd:	mov    $0x101,%r14d
    14e3:	jmp    14ee <botlish_fn_3+0xd46>
    14e8:	mov    $0x121,%r14d
    14ee:	mov    %r12,%rsi
    14f1:	jmp    14ff <botlish_fn_3+0xd57>
    14f6:	mov    $0x141,%r14d
    14fc:	mov    %r12,%rsi
    14ff:	test   $0x1,%rsi
    1506:	jne    1536 <botlish_fn_3+0xd8e>
    150c:	mov    $0x1db,%edx
    1511:	mov    %r12,%rsi
    1514:	mov    0xb8(%rsp),%rdi
    151c:	call   1521 <botlish_fn_3+0xd79>
			151d: R_X86_64_PLT32	rt_int_cmp-0x4
    1521:	mov    $0x2,%ecx
    1526:	test   %rax,%rax
    1529:	cmove  0x29f(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    1531:	jmp    154d <botlish_fn_3+0xda5>
    1536:	mov    $0x2,%ecx
    153b:	mov    %r12,%rsi
    153e:	cmp    $0x1db,%rsi
    1545:	cmove  0x283(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    154d:	cmp    $0x6,%rcx
    1551:	je     15c6 <botlish_fn_3+0xe1e>
    1557:	mov    %r12,%rsi
    155a:	test   $0x1,%rsi
    1561:	jne    1591 <botlish_fn_3+0xde9>
    1567:	mov    $0x1e9,%edx
    156c:	mov    %r12,%rsi
    156f:	mov    0xb8(%rsp),%rdi
    1577:	call   157c <botlish_fn_3+0xdd4>
			1578: R_X86_64_PLT32	rt_int_cmp-0x4
    157c:	mov    $0x2,%ecx
    1581:	test   %rax,%rax
    1584:	cmove  0x244(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    158c:	jmp    15a8 <botlish_fn_3+0xe00>
    1591:	mov    $0x2,%ecx
    1596:	mov    %r12,%rsi
    1599:	cmp    $0x1e9,%rsi
    15a0:	cmove  0x228(%rip),%rcx        # 17d0 <botlish_fn_3+0x1028>
    15a8:	cmp    $0x6,%rcx
    15ac:	je     15bc <botlish_fn_3+0xe14>
    15b2:	mov    $0x17f,%edi
    15b7:	jmp    15cb <botlish_fn_3+0xe23>
    15bc:	mov    $0x11f,%edi
    15c1:	jmp    15cb <botlish_fn_3+0xe23>
    15c6:	mov    $0x13f,%edi
    15cb:	sar    $1,%r13
    15ce:	test   %r13,%r13
    15d1:	jg     1627 <botlish_fn_3+0xe7f>
    15d7:	mov    $0x2,%ecx
    15dc:	cmp    $0x6,%rcx
    15e0:	je     1606 <botlish_fn_3+0xe5e>
    15e6:	mov    $0xffffffffffffffff,%rbx
    15ed:	movq   $0xffffffffffffffff,0x48(%rsp)
    15f6:	mov    %rbx,%r12
    15f9:	mov    0x120(%rsp),%r14
    1601:	jmp    165d <botlish_fn_3+0xeb5>
    1606:	mov    $0x3,%ebx
    160b:	movq   $0x3,0x48(%rsp)
    1614:	mov    $0x1,%r12d
    161a:	mov    0x120(%rsp),%r14
    1622:	jmp    165d <botlish_fn_3+0xeb5>
    1627:	mov    %r14,0x58(%rsp)
    162c:	mov    %rdi,0x60(%rsp)
    1631:	mov    $0x1,%ebx
    1636:	movq   $0x1,0x48(%rsp)
    163f:	mov    $0x2,%r12d
    1645:	mov    %rdi,0x100(%rsp)
    164d:	mov    %r14,0xe8(%rsp)
    1655:	mov    0x120(%rsp),%r14
    165d:	mov    0x18(%r14),%r11
    1661:	test   %r11,%r11
    1664:	je     17ac <botlish_fn_3+0x1004>
    166a:	mov    0x10(%r14),%rax
    166e:	mov    %rbx,(%rax)
    1671:	movq   $0xa,0x40(%rsp)
    167a:	lea    0x88(%rsp),%rcx
    1682:	movq   $0x0,0x88(%rsp)
    168e:	mov    0xc8(%rsp),%rax
    1696:	mov    %rax,0x90(%rsp)
    169e:	movq   $0x2,0x98(%rsp)
    16aa:	movq   $0xa,0xa0(%rsp)
    16b6:	mov    $0x3,%esi
    16bb:	mov    $0x4,%edx
    16c0:	mov    0xb8(%rsp),%rdi
    16c8:	call   16cd <botlish_fn_3+0xf25>
			16c9: R_X86_64_PLT32	rt_construct-0x4
    16cd:	mov    %rax,%rcx
    16d0:	mov    %rax,0xc8(%rsp)
    16d8:	test   %rcx,%rax
    16db:	jne    1718 <botlish_fn_3+0xf70>
    16e1:	xor    %rax,%rax
    16e4:	mov    0x130(%rsp),%rbx
    16ec:	mov    0x138(%rsp),%r12
    16f4:	mov    0x140(%rsp),%r13
    16fc:	mov    0x148(%rsp),%r14
    1704:	mov    0x150(%rsp),%r15
    170c:	add    $0x160,%rsp
    1713:	mov    %rbp,%rsp
    1716:	pop    %rbp
    1717:	ret
    1718:	mov    0xc8(%rsp),%rax
    1720:	mov    %rax,0x38(%rsp)
    1725:	movq   $0x3,0x40(%rsp)
    172e:	mov    0xd0(%rsp),%rsi
    1736:	test   $0x1,%rsi
    173d:	je     176d <botlish_fn_3+0xfc5>
    1743:	mov    0xd0(%rsp),%rsi
    174b:	mov    %rsi,%rcx
    174e:	add    $0x2,%rcx
    1752:	seto   %al
    1755:	test   %al,%al
    1757:	jne    176d <botlish_fn_3+0xfc5>
    175d:	mov    %rcx,%rsi
    1760:	mov    %rcx,0xd0(%rsp)
    1768:	jmp    1792 <botlish_fn_3+0xfea>
    176d:	mov    $0x3,%edx
    1772:	mov    0xd0(%rsp),%rsi
    177a:	mov    0xb8(%rsp),%rdi
    1782:	call   1787 <botlish_fn_3+0xfdf>
			1783: R_X86_64_PLT32	rt_int_add-0x4
    1787:	mov    %rax,%rsi
    178a:	mov    %rax,0xd0(%rsp)
    1792:	mov    %rsi,0x30(%rsp)
    1797:	mov    0xd0(%rsp),%rsi
    179f:	mov    %r14,0x120(%rsp)
    17a7:	jmp    b03 <botlish_fn_3+0x35b>
    17ac:	mov    $0x1,%edx
    17b1:	mov    %rbx,%rcx
    17b4:	mov    %r14,%rsi
    17b7:	mov    0xb8(%rsp),%rdi
    17bf:	call   17c4 <botlish_fn_3+0x101c>
			17c0: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    17c4:	jmp    1671 <botlish_fn_3+0xec9>
    17c9:	add    %al,(%rax)
    17cb:	add    %al,(%rax)
    17cd:	add    %al,(%rax)
    17cf:	add    %al,(%rsi)
    17d1:	add    %al,(%rax)
    17d3:	add    %al,(%rax)
    17d5:	add    %al,(%rax)
	...

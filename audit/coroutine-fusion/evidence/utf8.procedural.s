<botlish_fn_2>:
     780:	push   %rbp
     781:	mov    %rsp,%rbp
     784:	sub    $0xf0,%rsp
     78b:	mov    %rbx,0xc0(%rsp)
     793:	mov    %r12,0xc8(%rsp)
     79b:	mov    %r13,0xd0(%rsp)
     7a3:	mov    %r14,0xd8(%rsp)
     7ab:	mov    %r15,0xe0(%rsp)
     7b3:	mov    %rdi,0x88(%rsp)
     7bb:	movq   $0x0,0x18(%rsp)
     7c4:	movq   $0x0,0x20(%rsp)
     7cd:	movq   $0x0,0x28(%rsp)
     7d6:	movq   $0x0,0x30(%rsp)
     7df:	movq   $0x0,0x38(%rsp)
     7e8:	movq   $0x0,0x40(%rsp)
     7f1:	movq   $0x0,0x48(%rsp)
     7fa:	movq   $0x0,0x50(%rsp)
     803:	mov    %rsi,(%rsp)
     807:	mov    %rsi,0x90(%rsp)
     80f:	mov    $0x9,%esi
     814:	movq   $0x9,0x8(%rsp)
     81d:	mov    $0x1,%edx
     822:	movq   $0x1,0x10(%rsp)
     82b:	mov    0x88(%rsp),%rdi
     833:	call   838 <botlish_fn_2+0xb8>
			834: R_X86_64_PLT32	rt_mutarray_create-0x4
     838:	mov    %rax,%rbx
     83b:	mov    %rax,%r9
     83e:	test   %r9,%rax
     841:	je     f1f <botlish_fn_2+0x79f>
     847:	mov    %rbx,%rax
     84a:	mov    %rax,0x8(%rsp)
     84f:	mov    0x18(%rax),%rcx
     853:	test   %rcx,%rcx
     856:	je     153c <botlish_fn_2+0xdbc>
     85c:	mov    %rbx,%rax
     85f:	mov    0x10(%rax),%rcx
     863:	movq   $0x3,(%rcx)
     86a:	mov    0x90(%rsp),%rsi
     872:	mov    0x88(%rsp),%rdi
     87a:	call   87f <botlish_fn_2+0xff>
			87b: R_X86_64_PLT32	rt_list_len-0x4
     87f:	mov    %rax,%r12
     882:	mov    %r12,0x10(%rsp)
     887:	mov    $0x1,%esi
     88c:	mov    %rsi,0x98(%rsp)
     894:	movq   $0x1,0x18(%rsp)
     89d:	mov    %rsi,%rax
     8a0:	and    %r12,%rax
     8a3:	mov    %rsi,0x98(%rsp)
     8ab:	test   $0x1,%rax
     8b1:	jne    8e4 <botlish_fn_2+0x164>
     8b7:	mov    %r12,%rdx
     8ba:	mov    0x98(%rsp),%rsi
     8c2:	mov    0x88(%rsp),%rdi
     8ca:	call   8cf <botlish_fn_2+0x14f>
			8cb: R_X86_64_PLT32	rt_int_cmp-0x4
     8cf:	mov    $0x2,%ecx
     8d4:	test   %rax,%rax
     8d7:	cmovl  0xd69(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     8df:	jmp    8fc <botlish_fn_2+0x17c>
     8e4:	mov    $0x2,%ecx
     8e9:	mov    0x98(%rsp),%rsi
     8f1:	cmp    %r12,%rsi
     8f4:	cmovl  0xd4c(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     8fc:	cmp    $0x6,%rcx
     900:	je     941 <botlish_fn_2+0x1c1>
     906:	mov    0x10(%rbx),%rax
     90a:	mov    (%rax),%rax
     90d:	mov    0xc0(%rsp),%rbx
     915:	mov    0xc8(%rsp),%r12
     91d:	mov    0xd0(%rsp),%r13
     925:	mov    0xd8(%rsp),%r14
     92d:	mov    0xe0(%rsp),%r15
     935:	add    $0xf0,%rsp
     93c:	mov    %rbp,%rsp
     93f:	pop    %rbp
     940:	ret
     941:	mov    0x98(%rsp),%rsi
     949:	test   $0x1,%rsi
     950:	je     979 <botlish_fn_2+0x1f9>
     956:	mov    0x90(%rsp),%rsi
     95e:	mov    0x8(%rsi),%rax
     962:	mov    0x98(%rsp),%rsi
     96a:	mov    %rsi,%rcx
     96d:	sar    $1,%rcx
     970:	cmp    %rax,%rcx
     973:	jb     9a7 <botlish_fn_2+0x227>
     979:	mov    0x98(%rsp),%rdx
     981:	mov    0x90(%rsp),%rsi
     989:	mov    0x88(%rsp),%rdi
     991:	call   996 <botlish_fn_2+0x216>
			992: R_X86_64_PLT32	rt_list_get-0x4
     996:	mov    %rax,%r13
     999:	test   %r13,%r13
     99c:	je     f1f <botlish_fn_2+0x79f>
     9a2:	jmp    9b7 <botlish_fn_2+0x237>
     9a7:	mov    0x90(%rsp),%rsi
     9af:	mov    0x10(%rsi),%rdi
     9b3:	mov    (%rdi,%rcx,8),%r13
     9b7:	mov    %r13,0x20(%rsp)
     9bc:	mov    %r13,%rsi
     9bf:	mov    0x88(%rsp),%rdi
     9c7:	call   9cc <botlish_fn_2+0x24c>
			9c8: R_X86_64_PLT32	rt_list_len-0x4
     9cc:	mov    %rax,%r14
     9cf:	mov    %r14,0x28(%rsp)
     9d4:	movq   $0x1,0x30(%rsp)
     9dd:	xor    %rdx,%rdx
     9e0:	mov    0x88(%rsp),%rdi
     9e8:	mov    %rdx,%rsi
     9eb:	call   9f0 <botlish_fn_2+0x270>
			9ec: R_X86_64_PLT32	rt_list_new-0x4
     9f0:	test   %rax,%rax
     9f3:	mov    %rax,0xb8(%rsp)
     9fb:	je     f1f <botlish_fn_2+0x79f>
     a01:	mov    0xb8(%rsp),%rax
     a09:	mov    %rax,0x38(%rsp)
     a0e:	mov    $0x1,%esi
     a13:	mov    %rsi,0xb0(%rsp)
     a1b:	mov    %rsi,%rax
     a1e:	and    %r14,%rax
     a21:	mov    %rsi,0xb0(%rsp)
     a29:	test   $0x1,%rax
     a2f:	jne    a62 <botlish_fn_2+0x2e2>
     a35:	mov    %r14,%rdx
     a38:	mov    0xb0(%rsp),%rsi
     a40:	mov    0x88(%rsp),%rdi
     a48:	call   a4d <botlish_fn_2+0x2cd>
			a49: R_X86_64_PLT32	rt_int_cmp-0x4
     a4d:	mov    $0x2,%ecx
     a52:	test   %rax,%rax
     a55:	cmovl  0xbeb(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     a5d:	jmp    a7a <botlish_fn_2+0x2fa>
     a62:	mov    $0x2,%ecx
     a67:	mov    0xb0(%rsp),%rsi
     a6f:	cmp    %r14,%rsi
     a72:	cmovl  0xbce(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     a7a:	cmp    $0x6,%rcx
     a7e:	je     b53 <botlish_fn_2+0x3d3>
     a84:	lea    0x78(%rsp),%rcx
     a89:	movq   $0x0,0x78(%rsp)
     a92:	mov    0xb8(%rsp),%rax
     a9a:	mov    %rax,0x80(%rsp)
     aa2:	mov    $0x1,%esi
     aa7:	mov    $0x2,%edx
     aac:	mov    0x88(%rsp),%rdi
     ab4:	call   ab9 <botlish_fn_2+0x339>
			ab5: R_X86_64_PLT32	rt_construct-0x4
     ab9:	test   %rax,%rax
     abc:	je     f1f <botlish_fn_2+0x79f>
     ac2:	mov    $0x3,%edx
     ac7:	movq   $0x3,0x20(%rsp)
     ad0:	mov    0x98(%rsp),%rsi
     ad8:	test   $0x1,%rsi
     adf:	jne    af2 <botlish_fn_2+0x372>
     ae5:	mov    0x98(%rsp),%rsi
     aed:	jmp    b29 <botlish_fn_2+0x3a9>
     af2:	mov    0x98(%rsp),%rsi
     afa:	mov    %rsi,%rcx
     afd:	add    $0x2,%rcx
     b01:	seto   %al
     b04:	test   %al,%al
     b06:	je     b19 <botlish_fn_2+0x399>
     b0c:	mov    0x98(%rsp),%rsi
     b14:	jmp    b29 <botlish_fn_2+0x3a9>
     b19:	mov    %rcx,%rsi
     b1c:	mov    %rcx,0x98(%rsp)
     b24:	jmp    b41 <botlish_fn_2+0x3c1>
     b29:	mov    0x88(%rsp),%rdi
     b31:	call   b36 <botlish_fn_2+0x3b6>
			b32: R_X86_64_PLT32	rt_int_add-0x4
     b36:	mov    %rax,%rsi
     b39:	mov    %rax,0x98(%rsp)
     b41:	mov    %rsi,0x18(%rsp)
     b46:	mov    0x98(%rsp),%rsi
     b4e:	jmp    89d <botlish_fn_2+0x11d>
     b53:	mov    0xb0(%rsp),%rsi
     b5b:	test   $0x1,%rsi
     b62:	je     b83 <botlish_fn_2+0x403>
     b68:	mov    0x8(%r13),%rax
     b6c:	mov    0xb0(%rsp),%rsi
     b74:	mov    %rsi,%rcx
     b77:	sar    $1,%rcx
     b7a:	cmp    %rax,%rcx
     b7d:	jb     bac <botlish_fn_2+0x42c>
     b83:	mov    0xb0(%rsp),%rdx
     b8b:	mov    %r13,%rsi
     b8e:	mov    0x88(%rsp),%rdi
     b96:	call   b9b <botlish_fn_2+0x41b>
			b97: R_X86_64_PLT32	rt_list_get-0x4
     b9b:	test   %rax,%rax
     b9e:	je     f1f <botlish_fn_2+0x79f>
     ba4:	mov    %rax,%r15
     ba7:	jmp    bb7 <botlish_fn_2+0x437>
     bac:	mov    0x10(%r13),%rax
     bb0:	mov    (%rax,%rcx,8),%rsi
     bb4:	mov    %rsi,%r15
     bb7:	mov    0x10(%rbx),%rax
     bbb:	mov    0x8(%rax),%rsi
     bbf:	mov    %rsi,0x40(%rsp)
     bc4:	mov    %rsi,0xa0(%rsp)
     bcc:	mov    0x10(%rbx),%rax
     bd0:	mov    (%rax),%rsi
     bd3:	test   $0x1,%rsi
     bda:	jne    c09 <botlish_fn_2+0x489>
     be0:	mov    $0xffffffffffffffff,%rdx
     be7:	mov    0x88(%rsp),%rdi
     bef:	call   bf4 <botlish_fn_2+0x474>
			bf0: R_X86_64_PLT32	rt_int_cmp-0x4
     bf4:	mov    $0x2,%ecx
     bf9:	test   %rax,%rax
     bfc:	cmove  0xa44(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     c04:	jmp    c1a <botlish_fn_2+0x49a>
     c09:	mov    $0x2,%ecx
     c0e:	cmp    $0xffffffffffffffff,%rsi
     c12:	cmove  0xa2e(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     c1a:	cmp    $0x6,%rcx
     c1e:	je     14ab <botlish_fn_2+0xd2b>
     c24:	mov    0xa0(%rsp),%rsi
     c2c:	test   $0x1,%rsi
     c33:	jne    c68 <botlish_fn_2+0x4e8>
     c39:	mov    $0x1,%edx
     c3e:	mov    0xa0(%rsp),%rsi
     c46:	mov    0x88(%rsp),%rdi
     c4e:	call   c53 <botlish_fn_2+0x4d3>
			c4f: R_X86_64_PLT32	rt_int_cmp-0x4
     c53:	mov    $0x2,%ecx
     c58:	test   %rax,%rax
     c5b:	cmove  0x9e5(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     c63:	jmp    c81 <botlish_fn_2+0x501>
     c68:	mov    $0x2,%ecx
     c6d:	mov    0xa0(%rsp),%rsi
     c75:	cmp    $0x1,%rsi
     c79:	cmove  0x9c7(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     c81:	cmp    $0x6,%rcx
     c85:	je     f68 <botlish_fn_2+0x7e8>
     c8b:	mov    0x10(%rbx),%r9
     c8f:	mov    0x10(%r9),%rdx
     c93:	mov    %r15,%rsi
     c96:	mov    %rsi,%r9
     c99:	and    %rdx,%r9
     c9c:	test   $0x1,%r9
     ca3:	jne    cce <botlish_fn_2+0x54e>
     ca9:	mov    %r15,%rsi
     cac:	mov    0x88(%rsp),%rdi
     cb4:	call   cb9 <botlish_fn_2+0x539>
			cb5: R_X86_64_PLT32	rt_int_cmp-0x4
     cb9:	mov    $0x2,%ecx
     cbe:	test   %rax,%rax
     cc1:	cmovge 0x97f(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     cc9:	jmp    ce1 <botlish_fn_2+0x561>
     cce:	mov    $0x2,%ecx
     cd3:	mov    %r15,%rsi
     cd6:	cmp    %rdx,%rsi
     cd9:	cmovge 0x967(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     ce1:	cmp    $0x6,%rcx
     ce5:	je     cf5 <botlish_fn_2+0x575>
     ceb:	mov    $0x2,%ecx
     cf0:	jmp    d63 <botlish_fn_2+0x5e3>
     cf5:	mov    0x10(%rbx),%rax
     cf9:	mov    0x18(%rax),%rdx
     cfd:	mov    %r15,%rsi
     d00:	mov    %rsi,%rax
     d03:	and    %rdx,%rax
     d06:	test   $0x1,%rax
     d0c:	jne    d37 <botlish_fn_2+0x5b7>
     d12:	mov    %r15,%rsi
     d15:	mov    0x88(%rsp),%rdi
     d1d:	call   d22 <botlish_fn_2+0x5a2>
			d1e: R_X86_64_PLT32	rt_int_cmp-0x4
     d22:	mov    $0x2,%ecx
     d27:	test   %rax,%rax
     d2a:	cmovle 0x916(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     d32:	jmp    d4a <botlish_fn_2+0x5ca>
     d37:	mov    $0x2,%ecx
     d3c:	mov    %r15,%rsi
     d3f:	cmp    %rdx,%rsi
     d42:	cmovle 0x8fe(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     d4a:	cmp    $0x6,%rcx
     d4e:	je     d5e <botlish_fn_2+0x5de>
     d54:	mov    $0x2,%ecx
     d59:	jmp    d63 <botlish_fn_2+0x5e3>
     d5e:	mov    $0x6,%ecx
     d63:	cmp    $0x6,%rcx
     d67:	je     d79 <botlish_fn_2+0x5f9>
     d6d:	mov    $0xffffffffffffffff,%rcx
     d74:	jmp    def <botlish_fn_2+0x66f>
     d79:	mov    0xa0(%rsp),%rsi
     d81:	test   $0x1,%rsi
     d88:	jne    dbd <botlish_fn_2+0x63d>
     d8e:	mov    $0x3,%edx
     d93:	mov    0xa0(%rsp),%rsi
     d9b:	mov    0x88(%rsp),%rdi
     da3:	call   da8 <botlish_fn_2+0x628>
			da4: R_X86_64_PLT32	rt_int_cmp-0x4
     da8:	mov    $0x2,%ecx
     dad:	test   %rax,%rax
     db0:	cmove  0x890(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     db8:	jmp    dd6 <botlish_fn_2+0x656>
     dbd:	mov    $0x2,%ecx
     dc2:	mov    0xa0(%rsp),%rsi
     dca:	cmp    $0x3,%rsi
     dce:	cmove  0x872(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     dd6:	cmp    $0x6,%rcx
     dda:	je     dea <botlish_fn_2+0x66a>
     de0:	mov    $0x1,%ecx
     de5:	jmp    def <botlish_fn_2+0x66f>
     dea:	mov    $0x3,%ecx
     def:	mov    0x18(%rbx),%rax
     df3:	test   %rax,%rax
     df6:	je     155b <botlish_fn_2+0xddb>
     dfc:	mov    0x10(%rbx),%rax
     e00:	mov    %rcx,(%rax)
     e03:	mov    $0x3,%r15d
     e09:	movq   $0x3,0x48(%rsp)
     e12:	movq   $0x3,0x50(%rsp)
     e1b:	mov    0xa0(%rsp),%rsi
     e23:	test   $0x1,%rsi
     e2a:	jne    e3d <botlish_fn_2+0x6bd>
     e30:	mov    0xa0(%rsp),%rsi
     e38:	jmp    e66 <botlish_fn_2+0x6e6>
     e3d:	mov    0xa0(%rsp),%rsi
     e45:	mov    %rsi,%rcx
     e48:	sub    $0x3,%rcx
     e4c:	seto   %al
     e4f:	add    $0x1,%rcx
     e56:	test   %al,%al
     e58:	je     e79 <botlish_fn_2+0x6f9>
     e5e:	mov    0xa0(%rsp),%rsi
     e66:	mov    %r15,%rdx
     e69:	mov    0x88(%rsp),%rdi
     e71:	call   e76 <botlish_fn_2+0x6f6>
			e72: R_X86_64_PLT32	rt_int_sub-0x4
     e76:	mov    %rax,%rcx
     e79:	mov    0x18(%rbx),%rax
     e7d:	test   %rax,%rax
     e80:	je     1575 <botlish_fn_2+0xdf5>
     e86:	mov    0x10(%rbx),%rax
     e8a:	mov    %rcx,0x8(%rax)
     e8e:	mov    0x18(%rbx),%rax
     e92:	test   %rax,%rax
     e95:	je     158d <botlish_fn_2+0xe0d>
     e9b:	mov    0x10(%rbx),%rsi
     e9f:	movq   $0x101,0x10(%rsi)
     ea7:	mov    0x18(%rbx),%rsi
     eab:	test   %rsi,%rsi
     eae:	je     15ac <botlish_fn_2+0xe2c>
     eb4:	mov    0x10(%rbx),%r8
     eb8:	movq   $0x17f,0x18(%r8)
     ec0:	movq   $0xa,0x40(%rsp)
     ec9:	lea    0x58(%rsp),%rcx
     ece:	movq   $0x0,0x58(%rsp)
     ed7:	mov    0xb8(%rsp),%rax
     edf:	mov    %rax,0x60(%rsp)
     ee4:	movq   $0x2,0x68(%rsp)
     eed:	movq   $0xa,0x70(%rsp)
     ef6:	mov    $0x4,%edx
     efb:	mov    %r15,%rsi
     efe:	mov    0x88(%rsp),%rdi
     f06:	call   f0b <botlish_fn_2+0x78b>
			f07: R_X86_64_PLT32	rt_construct-0x4
     f0b:	mov    %rax,%rcx
     f0e:	mov    %rax,0xb8(%rsp)
     f16:	test   %rcx,%rax
     f19:	jne    f56 <botlish_fn_2+0x7d6>
     f1f:	xor    %rax,%rax
     f22:	mov    0xc0(%rsp),%rbx
     f2a:	mov    0xc8(%rsp),%r12
     f32:	mov    0xd0(%rsp),%r13
     f3a:	mov    0xd8(%rsp),%r14
     f42:	mov    0xe0(%rsp),%r15
     f4a:	add    $0xf0,%rsp
     f51:	mov    %rbp,%rsp
     f54:	pop    %rbp
     f55:	ret
     f56:	mov    0xb8(%rsp),%rax
     f5e:	mov    %rax,0x38(%rsp)
     f63:	jmp    14ab <botlish_fn_2+0xd2b>
     f68:	mov    %r15,%rsi
     f6b:	test   $0x1,%rsi
     f72:	jne    fa2 <botlish_fn_2+0x822>
     f78:	mov    $0x101,%edx
     f7d:	mov    %r15,%rsi
     f80:	mov    0x88(%rsp),%rdi
     f88:	call   f8d <botlish_fn_2+0x80d>
			f89: R_X86_64_PLT32	rt_int_cmp-0x4
     f8d:	mov    $0x2,%esi
     f92:	test   %rax,%rax
     f95:	cmovl  0x6ab(%rip),%rsi        # 1648 <botlish_fn_2+0xec8>
     f9d:	jmp    fb9 <botlish_fn_2+0x839>
     fa2:	mov    $0x2,%esi
     fa7:	mov    %r15,%rdi
     faa:	cmp    $0x101,%rdi
     fb1:	cmovl  0x68f(%rip),%rsi        # 1648 <botlish_fn_2+0xec8>
     fb9:	cmp    $0x6,%rsi
     fbd:	je     122a <botlish_fn_2+0xaaa>
     fc3:	mov    %r15,%rsi
     fc6:	test   $0x1,%rsi
     fcd:	jne    ffd <botlish_fn_2+0x87d>
     fd3:	mov    $0x185,%edx
     fd8:	mov    %r15,%rsi
     fdb:	mov    0x88(%rsp),%rdi
     fe3:	call   fe8 <botlish_fn_2+0x868>
			fe4: R_X86_64_PLT32	rt_int_cmp-0x4
     fe8:	mov    $0x2,%ecx
     fed:	test   %rax,%rax
     ff0:	cmovge 0x650(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
     ff8:	jmp    1014 <botlish_fn_2+0x894>
     ffd:	mov    $0x2,%ecx
    1002:	mov    %r15,%rsi
    1005:	cmp    $0x185,%rsi
    100c:	cmovge 0x634(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    1014:	cmp    $0x6,%rcx
    1018:	je     1026 <botlish_fn_2+0x8a6>
    101e:	mov    %r15,%rsi
    1021:	jmp    1084 <botlish_fn_2+0x904>
    1026:	mov    %r15,%rsi
    1029:	test   $0x1,%rsi
    1030:	jne    1060 <botlish_fn_2+0x8e0>
    1036:	mov    $0x1bf,%edx
    103b:	mov    %r15,%rsi
    103e:	mov    0x88(%rsp),%rdi
    1046:	call   104b <botlish_fn_2+0x8cb>
			1047: R_X86_64_PLT32	rt_int_cmp-0x4
    104b:	mov    $0x2,%ecx
    1050:	test   %rax,%rax
    1053:	cmovle 0x5ed(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    105b:	jmp    1077 <botlish_fn_2+0x8f7>
    1060:	mov    $0x2,%ecx
    1065:	mov    %r15,%rsi
    1068:	cmp    $0x1bf,%rsi
    106f:	cmovle 0x5d1(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    1077:	cmp    $0x6,%rcx
    107b:	je     1215 <botlish_fn_2+0xa95>
    1081:	mov    %r15,%rsi
    1084:	test   $0x1,%rsi
    108b:	jne    10bb <botlish_fn_2+0x93b>
    1091:	mov    $0x1c1,%edx
    1096:	mov    %r15,%rsi
    1099:	mov    0x88(%rsp),%rdi
    10a1:	call   10a6 <botlish_fn_2+0x926>
			10a2: R_X86_64_PLT32	rt_int_cmp-0x4
    10a6:	mov    $0x2,%ecx
    10ab:	test   %rax,%rax
    10ae:	cmovge 0x592(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    10b6:	jmp    10d2 <botlish_fn_2+0x952>
    10bb:	mov    $0x2,%ecx
    10c0:	mov    %r15,%rsi
    10c3:	cmp    $0x1c1,%rsi
    10ca:	cmovge 0x576(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    10d2:	cmp    $0x6,%rcx
    10d6:	je     10e4 <botlish_fn_2+0x964>
    10dc:	mov    %r15,%rsi
    10df:	jmp    1142 <botlish_fn_2+0x9c2>
    10e4:	mov    %r15,%rsi
    10e7:	test   $0x1,%rsi
    10ee:	jne    111e <botlish_fn_2+0x99e>
    10f4:	mov    $0x1df,%edx
    10f9:	mov    %r15,%rsi
    10fc:	mov    0x88(%rsp),%rdi
    1104:	call   1109 <botlish_fn_2+0x989>
			1105: R_X86_64_PLT32	rt_int_cmp-0x4
    1109:	mov    $0x2,%esi
    110e:	test   %rax,%rax
    1111:	cmovle 0x52f(%rip),%rsi        # 1648 <botlish_fn_2+0xec8>
    1119:	jmp    1135 <botlish_fn_2+0x9b5>
    111e:	mov    $0x2,%esi
    1123:	mov    %r15,%r9
    1126:	cmp    $0x1df,%r9
    112d:	cmovle 0x513(%rip),%rsi        # 1648 <botlish_fn_2+0xec8>
    1135:	cmp    $0x6,%rsi
    1139:	je     120b <botlish_fn_2+0xa8b>
    113f:	mov    %r15,%rsi
    1142:	test   $0x1,%rsi
    1149:	jne    1179 <botlish_fn_2+0x9f9>
    114f:	mov    $0x1e1,%edx
    1154:	mov    %r15,%rsi
    1157:	mov    0x88(%rsp),%rdi
    115f:	call   1164 <botlish_fn_2+0x9e4>
			1160: R_X86_64_PLT32	rt_int_cmp-0x4
    1164:	mov    $0x2,%ecx
    1169:	test   %rax,%rax
    116c:	cmovge 0x4d4(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    1174:	jmp    1190 <botlish_fn_2+0xa10>
    1179:	mov    $0x2,%ecx
    117e:	mov    %r15,%rsi
    1181:	cmp    $0x1e1,%rsi
    1188:	cmovge 0x4b8(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    1190:	cmp    $0x6,%rcx
    1194:	jne    11f5 <botlish_fn_2+0xa75>
    119a:	mov    %r15,%rsi
    119d:	test   $0x1,%rsi
    11a4:	jne    11d4 <botlish_fn_2+0xa54>
    11aa:	mov    $0x1e9,%edx
    11af:	mov    %r15,%rsi
    11b2:	mov    0x88(%rsp),%rdi
    11ba:	call   11bf <botlish_fn_2+0xa3f>
			11bb: R_X86_64_PLT32	rt_int_cmp-0x4
    11bf:	mov    $0x2,%ecx
    11c4:	test   %rax,%rax
    11c7:	cmovle 0x479(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    11cf:	jmp    11eb <botlish_fn_2+0xa6b>
    11d4:	mov    $0x2,%ecx
    11d9:	mov    %r15,%rsi
    11dc:	cmp    $0x1e9,%rsi
    11e3:	cmovle 0x45d(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    11eb:	cmp    $0x6,%rcx
    11ef:	je     1201 <botlish_fn_2+0xa81>
    11f5:	mov    $0xffffffffffffffff,%rsi
    11fc:	jmp    121a <botlish_fn_2+0xa9a>
    1201:	mov    $0x7,%esi
    1206:	jmp    121a <botlish_fn_2+0xa9a>
    120b:	mov    $0x5,%esi
    1210:	jmp    121a <botlish_fn_2+0xa9a>
    1215:	mov    $0x3,%esi
    121a:	mov    %rsi,0xa0(%rsp)
    1222:	mov    %r15,%rsi
    1225:	jmp    123a <botlish_fn_2+0xaba>
    122a:	mov    $0x1,%esi
    122f:	mov    %rsi,0xa0(%rsp)
    1237:	mov    %r15,%rsi
    123a:	test   $0x1,%rsi
    1241:	jne    1271 <botlish_fn_2+0xaf1>
    1247:	mov    $0x1c1,%edx
    124c:	mov    %r15,%rsi
    124f:	mov    0x88(%rsp),%rdi
    1257:	call   125c <botlish_fn_2+0xadc>
			1258: R_X86_64_PLT32	rt_int_cmp-0x4
    125c:	mov    $0x2,%ecx
    1261:	test   %rax,%rax
    1264:	cmove  0x3dc(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    126c:	jmp    1288 <botlish_fn_2+0xb08>
    1271:	mov    $0x2,%ecx
    1276:	mov    %r15,%rsi
    1279:	cmp    $0x1c1,%rsi
    1280:	cmove  0x3c0(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    1288:	cmp    $0x6,%rcx
    128c:	je     130c <botlish_fn_2+0xb8c>
    1292:	mov    %r15,%rsi
    1295:	test   $0x1,%rsi
    129c:	jne    12cc <botlish_fn_2+0xb4c>
    12a2:	mov    $0x1e1,%edx
    12a7:	mov    %r15,%rsi
    12aa:	mov    0x88(%rsp),%rdi
    12b2:	call   12b7 <botlish_fn_2+0xb37>
			12b3: R_X86_64_PLT32	rt_int_cmp-0x4
    12b7:	mov    $0x2,%ecx
    12bc:	test   %rax,%rax
    12bf:	cmove  0x381(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    12c7:	jmp    12e3 <botlish_fn_2+0xb63>
    12cc:	mov    $0x2,%ecx
    12d1:	mov    %r15,%rsi
    12d4:	cmp    $0x1e1,%rsi
    12db:	cmove  0x365(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    12e3:	cmp    $0x6,%rcx
    12e7:	je     12f7 <botlish_fn_2+0xb77>
    12ed:	mov    $0x101,%ecx
    12f2:	jmp    12fc <botlish_fn_2+0xb7c>
    12f7:	mov    $0x121,%ecx
    12fc:	mov    %r15,%rsi
    12ff:	mov    %rcx,0xa8(%rsp)
    1307:	jmp    131c <botlish_fn_2+0xb9c>
    130c:	mov    $0x141,%ecx
    1311:	mov    %rcx,0xa8(%rsp)
    1319:	mov    %r15,%rsi
    131c:	test   $0x1,%rsi
    1323:	jne    1353 <botlish_fn_2+0xbd3>
    1329:	mov    $0x1db,%edx
    132e:	mov    %r15,%rsi
    1331:	mov    0x88(%rsp),%rdi
    1339:	call   133e <botlish_fn_2+0xbbe>
			133a: R_X86_64_PLT32	rt_int_cmp-0x4
    133e:	mov    $0x2,%ecx
    1343:	test   %rax,%rax
    1346:	cmove  0x2fa(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    134e:	jmp    136a <botlish_fn_2+0xbea>
    1353:	mov    $0x2,%ecx
    1358:	mov    %r15,%rsi
    135b:	cmp    $0x1db,%rsi
    1362:	cmove  0x2de(%rip),%rcx        # 1648 <botlish_fn_2+0xec8>
    136a:	cmp    $0x6,%rcx
    136e:	je     13ee <botlish_fn_2+0xc6e>
    1374:	mov    %r15,%rsi
    1377:	test   $0x1,%rsi
    137e:	jne    13ae <botlish_fn_2+0xc2e>
    1384:	mov    $0x1e9,%edx
    1389:	mov    %r15,%rsi
    138c:	mov    0x88(%rsp),%rdi
    1394:	call   1399 <botlish_fn_2+0xc19>
			1395: R_X86_64_PLT32	rt_int_cmp-0x4
    1399:	mov    $0x2,%esi
    139e:	test   %rax,%rax
    13a1:	cmove  0x29f(%rip),%rsi        # 1648 <botlish_fn_2+0xec8>
    13a9:	jmp    13c5 <botlish_fn_2+0xc45>
    13ae:	mov    $0x2,%esi
    13b3:	mov    %r15,%rdi
    13b6:	cmp    $0x1e9,%rdi
    13bd:	cmove  0x283(%rip),%rsi        # 1648 <botlish_fn_2+0xec8>
    13c5:	cmp    $0x6,%rsi
    13c9:	je     13d9 <botlish_fn_2+0xc59>
    13cf:	mov    $0x17f,%ecx
    13d4:	jmp    13de <botlish_fn_2+0xc5e>
    13d9:	mov    $0x11f,%ecx
    13de:	mov    0xa0(%rsp),%rax
    13e6:	mov    %rcx,%r15
    13e9:	jmp    13fe <botlish_fn_2+0xc7e>
    13ee:	mov    $0x13f,%ecx
    13f3:	mov    %rcx,%r15
    13f6:	mov    0xa0(%rsp),%rax
    13fe:	mov    %rax,%rsi
    1401:	sar    $1,%rsi
    1404:	mov    %rax,0xa0(%rsp)
    140c:	mov    $0xffffffffffffffff,%rcx
    1413:	cmp    $0xffffffffffffffff,%rsi
    1417:	je     1435 <botlish_fn_2+0xcb5>
    141d:	test   %rsi,%rsi
    1420:	je     1430 <botlish_fn_2+0xcb0>
    1426:	mov    $0x1,%ecx
    142b:	jmp    1435 <botlish_fn_2+0xcb5>
    1430:	mov    $0x3,%ecx
    1435:	mov    0x18(%rbx),%rax
    1439:	test   %rax,%rax
    143c:	je     15cb <botlish_fn_2+0xe4b>
    1442:	mov    0x10(%rbx),%rax
    1446:	mov    %rcx,(%rax)
    1449:	mov    0xa0(%rsp),%rsi
    1451:	mov    0x88(%rsp),%rdi
    1459:	call   145e <botlish_fn_2+0xcde>
			145a: R_X86_64_PLT32	botlish_fn_1-0x4
    145e:	mov    %rax,%rcx
    1461:	mov    0x18(%rbx),%rax
    1465:	test   %rax,%rax
    1468:	je     15ed <botlish_fn_2+0xe6d>
    146e:	mov    0x10(%rbx),%rax
    1472:	mov    %rcx,0x8(%rax)
    1476:	mov    0x18(%rbx),%rax
    147a:	test   %rax,%rax
    147d:	je     1607 <botlish_fn_2+0xe87>
    1483:	mov    0xa8(%rsp),%rcx
    148b:	mov    0x10(%rbx),%rax
    148f:	mov    %rcx,0x10(%rax)
    1493:	mov    0x18(%rbx),%rax
    1497:	test   %rax,%rax
    149a:	je     1629 <botlish_fn_2+0xea9>
    14a0:	mov    %r15,%rcx
    14a3:	mov    0x10(%rbx),%rax
    14a7:	mov    %rcx,0x18(%rax)
    14ab:	mov    $0x3,%edx
    14b0:	movq   $0x3,0x40(%rsp)
    14b9:	mov    0xb0(%rsp),%rsi
    14c1:	test   $0x1,%rsi
    14c8:	jne    14db <botlish_fn_2+0xd5b>
    14ce:	mov    0xb0(%rsp),%rsi
    14d6:	jmp    1512 <botlish_fn_2+0xd92>
    14db:	mov    0xb0(%rsp),%rsi
    14e3:	mov    %rsi,%rcx
    14e6:	add    $0x2,%rcx
    14ea:	seto   %al
    14ed:	test   %al,%al
    14ef:	je     1502 <botlish_fn_2+0xd82>
    14f5:	mov    0xb0(%rsp),%rsi
    14fd:	jmp    1512 <botlish_fn_2+0xd92>
    1502:	mov    %rcx,%rsi
    1505:	mov    %rcx,0xb0(%rsp)
    150d:	jmp    152a <botlish_fn_2+0xdaa>
    1512:	mov    0x88(%rsp),%rdi
    151a:	call   151f <botlish_fn_2+0xd9f>
			151b: R_X86_64_PLT32	rt_int_add-0x4
    151f:	mov    %rax,%rsi
    1522:	mov    %rax,0xb0(%rsp)
    152a:	mov    %rsi,0x30(%rsp)
    152f:	mov    0xb0(%rsp),%rsi
    1537:	jmp    a1b <botlish_fn_2+0x29b>
    153c:	mov    $0x1,%edx
    1541:	mov    $0x3,%ecx
    1546:	mov    %rbx,%rsi
    1549:	mov    0x88(%rsp),%rdi
    1551:	call   1556 <botlish_fn_2+0xdd6>
			1552: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1556:	jmp    86a <botlish_fn_2+0xea>
    155b:	mov    $0x1,%edx
    1560:	mov    %rbx,%rsi
    1563:	mov    0x88(%rsp),%rdi
    156b:	call   1570 <botlish_fn_2+0xdf0>
			156c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1570:	jmp    e03 <botlish_fn_2+0x683>
    1575:	mov    %r15,%rdx
    1578:	mov    %rbx,%rsi
    157b:	mov    0x88(%rsp),%rdi
    1583:	call   1588 <botlish_fn_2+0xe08>
			1584: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1588:	jmp    e8e <botlish_fn_2+0x70e>
    158d:	mov    $0x5,%edx
    1592:	mov    $0x101,%ecx
    1597:	mov    %rbx,%rsi
    159a:	mov    0x88(%rsp),%rdi
    15a2:	call   15a7 <botlish_fn_2+0xe27>
			15a3: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    15a7:	jmp    ea7 <botlish_fn_2+0x727>
    15ac:	mov    $0x7,%edx
    15b1:	mov    $0x17f,%ecx
    15b6:	mov    %rbx,%rsi
    15b9:	mov    0x88(%rsp),%rdi
    15c1:	call   15c6 <botlish_fn_2+0xe46>
			15c2: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    15c6:	jmp    ec0 <botlish_fn_2+0x740>
    15cb:	mov    $0x1,%edx
    15d0:	mov    %rbx,%rsi
    15d3:	mov    0x88(%rsp),%rdi
    15db:	call   15e0 <botlish_fn_2+0xe60>
			15dc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    15e0:	mov    0xa0(%rsp),%rsi
    15e8:	jmp    1451 <botlish_fn_2+0xcd1>
    15ed:	mov    $0x3,%edx
    15f2:	mov    %rbx,%rsi
    15f5:	mov    0x88(%rsp),%rdi
    15fd:	call   1602 <botlish_fn_2+0xe82>
			15fe: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1602:	jmp    1476 <botlish_fn_2+0xcf6>
    1607:	mov    $0x5,%edx
    160c:	mov    0xa8(%rsp),%rcx
    1614:	mov    %rbx,%rsi
    1617:	mov    0x88(%rsp),%rdi
    161f:	call   1624 <botlish_fn_2+0xea4>
			1620: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1624:	jmp    1493 <botlish_fn_2+0xd13>
    1629:	mov    $0x7,%edx
    162e:	mov    %r15,%rcx
    1631:	mov    %rbx,%rsi
    1634:	mov    0x88(%rsp),%rdi
    163c:	call   1641 <botlish_fn_2+0xec1>
			163d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1641:	jmp    14ab <botlish_fn_2+0xd2b>
    1646:	add    %al,(%rax)
    1648:	(bad)
    1649:	add    %al,(%rax)
    164b:	add    %al,(%rax)
    164d:	add    %al,(%rax)
	...

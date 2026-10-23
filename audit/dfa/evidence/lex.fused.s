<botlish_fn_13>:
     838:	push   %rbp
     839:	mov    %rsp,%rbp
     83c:	sub    $0x370,%rsp
     843:	mov    %rbx,0x340(%rsp)
     84b:	mov    %r12,0x348(%rsp)
     853:	mov    %r13,0x350(%rsp)
     85b:	mov    %r14,0x358(%rsp)
     863:	mov    %r15,0x360(%rsp)
     86b:	mov    %rdi,0x280(%rsp)
     873:	movq   $0x0,0x8(%rsp)
     87c:	movq   $0x0,0x10(%rsp)
     885:	movq   $0x0,0x18(%rsp)
     88e:	movq   $0x0,0x20(%rsp)
     897:	movq   $0x0,0x28(%rsp)
     8a0:	movq   $0x0,0x30(%rsp)
     8a9:	movq   $0x0,0x38(%rsp)
     8b2:	movq   $0x0,0x40(%rsp)
     8bb:	movq   $0x0,0x80(%rsp)
     8c7:	movq   $0x0,0x88(%rsp)
     8d3:	movq   $0x0,0x90(%rsp)
     8df:	movq   $0x0,0x98(%rsp)
     8eb:	movq   $0x0,0xa0(%rsp)
     8f7:	movq   $0x0,0xa8(%rsp)
     903:	mov    %rdx,(%rsp)
     907:	mov    %rdx,0x290(%rsp)
     90f:	movq   $0xa,0x58(%rsp)
     918:	movq   $0xa,0x60(%rsp)
     921:	movq   $0xa,0x68(%rsp)
     92a:	movq   $0xa,0x70(%rsp)
     933:	movq   $0xa,0x78(%rsp)
     93c:	movq   $0xa,0x48(%rsp)
     945:	movq   $0xa,0x50(%rsp)
     94e:	mov    %rsi,0x58(%rsp)
     953:	mov    %rsi,0x288(%rsp)
     95b:	mov    0x288(%rsp),%rsi
     963:	mov    0x280(%rsp),%rdi
     96b:	call   970 <botlish_fn_13+0x138>
			96c: R_X86_64_PLT32	rt_list_len-0x4
     970:	mov    %rax,0x60(%rsp)
     975:	mov    %rax,0x330(%rsp)
     97d:	mov    $0x1,%esi
     982:	mov    %rsi,0x2d0(%rsp)
     98a:	movq   $0x1,0x68(%rsp)
     993:	xor    %rcx,%rcx
     996:	mov    %rcx,0x2b8(%rsp)
     99e:	mov    $0xa,%eax
     9a3:	mov    %rax,0x2c8(%rsp)
     9ab:	mov    0x330(%rsp),%rbx
     9b3:	mov    0x2b8(%rsp),%rax
     9bb:	mov    %rax,0x2c0(%rsp)
     9c3:	mov    %rsi,%rax
     9c6:	and    %rbx,%rax
     9c9:	mov    %rsi,0x2d0(%rsp)
     9d1:	test   $0x1,%rax
     9d7:	jne    a12 <botlish_fn_13+0x1da>
     9dd:	mov    %rbx,%rdx
     9e0:	mov    0x2d0(%rsp),%rsi
     9e8:	mov    0x280(%rsp),%rdi
     9f0:	call   9f5 <botlish_fn_13+0x1bd>
			9f1: R_X86_64_PLT32	rt_int_cmp-0x4
     9f5:	mov    %rbx,0x330(%rsp)
     9fd:	mov    $0x2,%ecx
     a02:	test   %rax,%rax
     a05:	cmovl  0x6493(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
     a0d:	jmp    a3a <botlish_fn_13+0x202>
     a12:	mov    %rbx,0x330(%rsp)
     a1a:	mov    $0x2,%ecx
     a1f:	mov    0x330(%rsp),%rax
     a27:	mov    0x2d0(%rsp),%rsi
     a2f:	cmp    %rax,%rsi
     a32:	cmovl  0x6466(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
     a3a:	cmp    $0x6,%rcx
     a3e:	je     a8f <botlish_fn_13+0x257>
     a44:	mov    $0xffffffffffffffff,%rax
     a4b:	mov    %rax,0x2b0(%rsp)
     a53:	movq   $0xffffffffffffffff,0x48(%rsp)
     a5c:	mov    $0xa,%eax
     a61:	movq   $0xa,0x78(%rsp)
     a6a:	mov    %rax,0x2a8(%rsp)
     a72:	mov    0x2b0(%rsp),%rcx
     a7a:	mov    %rcx,0x2a0(%rsp)
     a82:	mov    0x2b0(%rsp),%rax
     a8a:	jmp    d89 <botlish_fn_13+0x551>
     a8f:	mov    0x2d0(%rsp),%rsi
     a97:	test   $0x1,%rsi
     a9e:	je     ac7 <botlish_fn_13+0x28f>
     aa4:	mov    0x288(%rsp),%rcx
     aac:	mov    0x8(%rcx),%rcx
     ab0:	mov    0x2d0(%rsp),%rsi
     ab8:	mov    %rsi,%rax
     abb:	sar    $1,%rax
     abe:	cmp    %rcx,%rax
     ac1:	jb     af2 <botlish_fn_13+0x2ba>
     ac7:	mov    0x2d0(%rsp),%rdx
     acf:	mov    0x288(%rsp),%rsi
     ad7:	mov    0x280(%rsp),%rdi
     adf:	call   ae4 <botlish_fn_13+0x2ac>
			ae0: R_X86_64_PLT32	rt_list_get-0x4
     ae4:	test   %rax,%rax
     ae7:	je     bae <botlish_fn_13+0x376>
     aed:	jmp    b02 <botlish_fn_13+0x2ca>
     af2:	mov    0x288(%rsp),%rcx
     afa:	mov    0x10(%rcx),%rcx
     afe:	mov    (%rcx,%rax,8),%rax
     b02:	mov    %rax,0x70(%rsp)
     b07:	mov    0x8(%rax),%rcx
     b0b:	mov    %rcx,0x2c0(%rsp)
     b13:	mov    %rax,0x2c8(%rsp)
     b1b:	xor    %rdx,%rdx
     b1e:	mov    0x280(%rsp),%rdi
     b26:	mov    %rdx,%rsi
     b29:	call   b2e <botlish_fn_13+0x2f6>
			b2a: R_X86_64_PLT32	rt_list_new-0x4
     b2e:	test   %rax,%rax
     b31:	je     bae <botlish_fn_13+0x376>
     b37:	mov    %rax,0x78(%rsp)
     b3c:	mov    0x2c0(%rsp),%rdx
     b44:	shl    $1,%rdx
     b47:	mov    %rdx,0x2c0(%rsp)
     b4f:	or     $0x1,%rdx
     b53:	mov    %rdx,0x2c0(%rsp)
     b5b:	sar    $1,%rdx
     b5e:	mov    %rdx,%rcx
     b61:	mov    %rdx,0x2c0(%rsp)
     b69:	test   %rcx,%rdx
     b6c:	jg     cd7 <botlish_fn_13+0x49f>
     b72:	lea    0x120(%rsp),%rcx
     b7a:	movq   $0x0,0x120(%rsp)
     b86:	mov    %rax,0x128(%rsp)
     b8e:	mov    $0x1,%esi
     b93:	mov    $0x2,%edx
     b98:	mov    0x280(%rsp),%rdi
     ba0:	call   ba5 <botlish_fn_13+0x36d>
			ba1: R_X86_64_PLT32	rt_construct-0x4
     ba5:	test   %rax,%rax
     ba8:	jne    c31 <botlish_fn_13+0x3f9>
     bae:	mov    0x280(%rsp),%rdi
     bb6:	call   bbb <botlish_fn_13+0x383>
			bb7: R_X86_64_PLT32	rt_co_failed-0x4
     bbb:	mov    %rax,0x50(%rsp)
     bc0:	movq   $0xa,0x78(%rsp)
     bc9:	mov    %rax,%rsi
     bcc:	mov    0x280(%rsp),%rdi
     bd4:	call   bd9 <botlish_fn_13+0x3a1>
			bd5: R_X86_64_PLT32	rt_co_resume0-0x4
     bd9:	test   %rax,%rax
     bdc:	jne    bef <botlish_fn_13+0x3b7>
     be2:	mov    0x280(%rsp),%rdi
     bea:	jmp    c13 <botlish_fn_13+0x3db>
     bef:	mov    0x280(%rsp),%rdi
     bf7:	mov    0x10(%rdi),%rax
     bfb:	mov    0x50(%rax),%rsi
     bff:	mov    0x130(%rax),%rdx
     c06:	call   c0b <botlish_fn_13+0x3d3>
			c07: R_X86_64_PLT32	rt_raise-0x4
     c0b:	mov    0x280(%rsp),%rdi
     c13:	mov    0x280(%rsp),%rdi
     c1b:	call   c20 <botlish_fn_13+0x3e8>
			c1c: R_X86_64_PLT32	rt_declared_error-0x4
     c20:	cmp    $0x40000001,%rax
     c26:	jne    6c28 <botlish_fn_13+0x63f0>
     c2c:	jmp    6c28 <botlish_fn_13+0x63f0>
     c31:	mov    $0x3,%edx
     c36:	movq   $0x3,0x38(%rsp)
     c3f:	mov    0x2d0(%rsp),%rsi
     c47:	test   $0x1,%rsi
     c4e:	jne    c61 <botlish_fn_13+0x429>
     c54:	mov    0x2d0(%rsp),%rsi
     c5c:	jmp    c9a <botlish_fn_13+0x462>
     c61:	mov    0x2d0(%rsp),%rsi
     c69:	mov    %rsi,%r9
     c6c:	add    $0x2,%r9
     c70:	seto   %r11b
     c74:	test   %r11b,%r11b
     c77:	je     c8a <botlish_fn_13+0x452>
     c7d:	mov    0x2d0(%rsp),%rsi
     c85:	jmp    c9a <botlish_fn_13+0x462>
     c8a:	mov    %r9,%rsi
     c8d:	mov    %r9,0x2d0(%rsp)
     c95:	jmp    cb2 <botlish_fn_13+0x47a>
     c9a:	mov    0x280(%rsp),%rdi
     ca2:	call   ca7 <botlish_fn_13+0x46f>
			ca3: R_X86_64_PLT32	rt_int_add-0x4
     ca7:	mov    %rax,%rsi
     caa:	mov    %rax,0x2d0(%rsp)
     cb2:	mov    %rsi,0x68(%rsp)
     cb7:	xor    %rcx,%rcx
     cba:	mov    0x330(%rsp),%rbx
     cc2:	mov    0x2d0(%rsp),%rsi
     cca:	mov    %rcx,0x2b8(%rsp)
     cd2:	jmp    9c3 <botlish_fn_13+0x18b>
     cd7:	mov    %rax,0x2a8(%rsp)
     cdf:	mov    0x2c8(%rsp),%rax
     ce7:	movzbq 0x18(%rax),%rax
     cec:	test   %rax,%rax
     cef:	jne    d1c <botlish_fn_13+0x4e4>
     cf5:	mov    $0x1,%edx
     cfa:	mov    0x2c8(%rsp),%rsi
     d02:	mov    0x280(%rsp),%rdi
     d0a:	call   d0f <botlish_fn_13+0x4d7>
			d0b: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     d0f:	mov    %rax,0x2b0(%rsp)
     d17:	jmp    d49 <botlish_fn_13+0x511>
     d1c:	mov    0x2c8(%rsp),%rax
     d24:	movzbq 0x19(%rax),%rax
     d29:	mov    %rax,0x2b0(%rsp)
     d31:	shl    $0x3,%rax
     d35:	mov    %rax,0x2b0(%rsp)
     d3d:	or     $0x4,%rax
     d41:	mov    %rax,0x2b0(%rsp)
     d49:	shr    $0x3,%rax
     d4d:	mov    %rax,0x2b0(%rsp)
     d55:	mov    $0x1,%ecx
     d5a:	mov    %rcx,0x2a0(%rsp)
     d62:	shl    $1,%rax
     d65:	mov    %rax,0x2b0(%rsp)
     d6d:	or     $0x1,%rax
     d71:	mov    %rax,0x2b0(%rsp)
     d79:	mov    %rax,0x48(%rsp)
     d7e:	xor    %rcx,%rcx
     d81:	mov    %rcx,0x2b8(%rsp)
     d89:	mov    %rax,0x8(%rsp)
     d8e:	mov    $0x3,%ebx
     d93:	movq   $0x3,0x10(%rsp)
     d9c:	mov    0x2b0(%rsp),%rdx
     da4:	mov    %rbx,%rsi
     da7:	mov    0x280(%rsp),%rdi
     daf:	call   db4 <botlish_fn_13+0x57c>
			db0: R_X86_64_PLT32	rt_mutarray_create-0x4
     db4:	mov    %rax,%rcx
     db7:	mov    %rbx,0x328(%rsp)
     dbf:	test   %rcx,%rcx
     dc2:	je     6c28 <botlish_fn_13+0x63f0>
     dc8:	mov    %rcx,0x8(%rsp)
     dcd:	mov    %rcx,0x320(%rsp)
     dd5:	movq   $0x3,0x10(%rsp)
     dde:	mov    $0x1,%edx
     de3:	movq   $0x1,0x18(%rsp)
     dec:	mov    0x328(%rsp),%rsi
     df4:	mov    0x280(%rsp),%rdi
     dfc:	call   e01 <botlish_fn_13+0x5c9>
			dfd: R_X86_64_PLT32	rt_mutarray_create-0x4
     e01:	mov    %rax,%r11
     e04:	test   %r11,%r11
     e07:	je     6c28 <botlish_fn_13+0x63f0>
     e0d:	mov    %r11,0x10(%rsp)
     e12:	mov    %r11,0x318(%rsp)
     e1a:	movq   $0x3,0x18(%rsp)
     e23:	mov    $0x1,%edx
     e28:	movq   $0x1,0x20(%rsp)
     e31:	mov    0x328(%rsp),%rsi
     e39:	mov    0x280(%rsp),%rdi
     e41:	call   e46 <botlish_fn_13+0x60e>
			e42: R_X86_64_PLT32	rt_mutarray_create-0x4
     e46:	mov    %rax,%rcx
     e49:	test   %rcx,%rcx
     e4c:	je     6c28 <botlish_fn_13+0x63f0>
     e52:	mov    %rcx,0x18(%rsp)
     e57:	mov    %rcx,0x310(%rsp)
     e5f:	movq   $0x3,0x20(%rsp)
     e68:	mov    $0x2,%edx
     e6d:	movq   $0x2,0x28(%rsp)
     e76:	mov    0x328(%rsp),%rsi
     e7e:	mov    0x280(%rsp),%rdi
     e86:	call   e8b <botlish_fn_13+0x653>
			e87: R_X86_64_PLT32	rt_mutarray_create-0x4
     e8b:	mov    %rax,%r12
     e8e:	test   %r12,%r12
     e91:	mov    %r12,0x308(%rsp)
     e99:	je     6c28 <botlish_fn_13+0x63f0>
     e9f:	mov    0x308(%rsp),%r12
     ea7:	mov    %r12,0x20(%rsp)
     eac:	mov    $0xffffffffffffffff,%rdx
     eb3:	mov    %rdx,0x300(%rsp)
     ebb:	mov    $0x4,%esi
     ec0:	mov    %rsi,0x2f8(%rsp)
     ec8:	mov    0x320(%rsp),%rcx
     ed0:	mov    0x10(%rcx),%rax
     ed4:	mov    (%rax),%rsi
     ed7:	mov    %rsi,%r14
     eda:	mov    %r14,%rsi
     edd:	mov    0x280(%rsp),%rdi
     ee5:	call   eea <botlish_fn_13+0x6b2>
			ee6: R_X86_64_PLT32	botlish_fn_11-0x4
     eea:	cmp    $0x6,%rax
     eee:	je     67c9 <botlish_fn_13+0x5f91>
     ef4:	mov    %r14,%rsi
     ef7:	test   $0x1,%rsi
     efe:	jne    f31 <botlish_fn_13+0x6f9>
     f04:	mov    0x300(%rsp),%rdx
     f0c:	mov    %r14,%rsi
     f0f:	mov    0x280(%rsp),%rdi
     f17:	call   f1c <botlish_fn_13+0x6e4>
			f18: R_X86_64_PLT32	rt_int_cmp-0x4
     f1c:	mov    $0x2,%ecx
     f21:	test   %rax,%rax
     f24:	cmove  0x5f74(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
     f2c:	jmp    f45 <botlish_fn_13+0x70d>
     f31:	mov    $0x2,%ecx
     f36:	mov    %r14,%rsi
     f39:	cmp    $0xffffffffffffffff,%rsi
     f3d:	cmove  0x5f5b(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
     f45:	cmp    $0x6,%rcx
     f49:	je     6740 <botlish_fn_13+0x5f08>
     f4f:	mov    0x318(%rsp),%r11
     f57:	mov    0x10(%r11),%rax
     f5b:	mov    (%rax),%rcx
     f5e:	mov    %rcx,0x28(%rsp)
     f63:	mov    %rcx,0x2f0(%rsp)
     f6b:	movq   $0xa,0x90(%rsp)
     f77:	movq   $0xa,0x98(%rsp)
     f83:	movq   $0xa,0xa0(%rsp)
     f8f:	movq   $0xa,0xa8(%rsp)
     f9b:	movq   $0xa,0x80(%rsp)
     fa7:	movq   $0xa,0x88(%rsp)
     fb3:	mov    %r14,%rsi
     fb6:	test   $0x1,%rsi
     fbd:	jne    fed <botlish_fn_13+0x7b5>
     fc3:	mov    $0xbb,%edx
     fc8:	mov    %r14,%rsi
     fcb:	mov    0x280(%rsp),%rdi
     fd3:	call   fd8 <botlish_fn_13+0x7a0>
			fd4: R_X86_64_PLT32	rt_int_cmp-0x4
     fd8:	mov    $0x2,%ecx
     fdd:	test   %rax,%rax
     fe0:	cmovl  0x5eb8(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
     fe8:	jmp    1004 <botlish_fn_13+0x7cc>
     fed:	mov    $0x2,%ecx
     ff2:	mov    %r14,%rsi
     ff5:	cmp    $0xbb,%rsi
     ffc:	cmovl  0x5e9c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1004:	cmp    $0x6,%rcx
    1008:	je     125c <botlish_fn_13+0xa24>
    100e:	mov    %r14,%rsi
    1011:	test   $0x1,%rsi
    1018:	jne    1048 <botlish_fn_13+0x810>
    101e:	mov    $0xe9,%edx
    1023:	mov    %r14,%rsi
    1026:	mov    0x280(%rsp),%rdi
    102e:	call   1033 <botlish_fn_13+0x7fb>
			102f: R_X86_64_PLT32	rt_int_cmp-0x4
    1033:	mov    $0x2,%ecx
    1038:	test   %rax,%rax
    103b:	cmovl  0x5e5d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1043:	jmp    105f <botlish_fn_13+0x827>
    1048:	mov    $0x2,%ecx
    104d:	mov    %r14,%rsi
    1050:	cmp    $0xe9,%rsi
    1057:	cmovl  0x5e41(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    105f:	cmp    $0x6,%rcx
    1063:	je     11dd <botlish_fn_13+0x9a5>
    1069:	mov    %r14,%rsi
    106c:	test   $0x1,%rsi
    1073:	jne    10a3 <botlish_fn_13+0x86b>
    1079:	mov    $0xf9,%edx
    107e:	mov    %r14,%rsi
    1081:	mov    0x280(%rsp),%rdi
    1089:	call   108e <botlish_fn_13+0x856>
			108a: R_X86_64_PLT32	rt_int_cmp-0x4
    108e:	mov    $0x2,%ecx
    1093:	test   %rax,%rax
    1096:	cmovl  0x5e02(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    109e:	jmp    10ba <botlish_fn_13+0x882>
    10a3:	mov    $0x2,%ecx
    10a8:	mov    %r14,%rsi
    10ab:	cmp    $0xf9,%rsi
    10b2:	cmovl  0x5de6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    10ba:	cmp    $0x6,%rcx
    10be:	je     119d <botlish_fn_13+0x965>
    10c4:	mov    %r14,%rsi
    10c7:	test   $0x1,%rsi
    10ce:	jne    10fe <botlish_fn_13+0x8c6>
    10d4:	mov    $0xfb,%edx
    10d9:	mov    %r14,%rsi
    10dc:	mov    0x280(%rsp),%rdi
    10e4:	call   10e9 <botlish_fn_13+0x8b1>
			10e5: R_X86_64_PLT32	rt_int_cmp-0x4
    10e9:	mov    $0x2,%edx
    10ee:	test   %rax,%rax
    10f1:	cmovl  0x5da7(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    10f9:	jmp    1115 <botlish_fn_13+0x8dd>
    10fe:	mov    $0x2,%edx
    1103:	mov    %r14,%rsi
    1106:	cmp    $0xfb,%rsi
    110d:	cmovl  0x5d8b(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    1115:	cmp    $0x6,%rdx
    1119:	je     1192 <botlish_fn_13+0x95a>
    111f:	mov    %r14,%rsi
    1122:	test   $0x1,%rsi
    1129:	jne    1159 <botlish_fn_13+0x921>
    112f:	mov    $0xfd,%edx
    1134:	mov    %r14,%rsi
    1137:	mov    0x280(%rsp),%rdi
    113f:	call   1144 <botlish_fn_13+0x90c>
			1140: R_X86_64_PLT32	rt_int_cmp-0x4
    1144:	mov    $0x2,%ecx
    1149:	test   %rax,%rax
    114c:	cmovl  0x5d4c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1154:	jmp    1170 <botlish_fn_13+0x938>
    1159:	mov    $0x2,%ecx
    115e:	mov    %r14,%rsi
    1161:	cmp    $0xfd,%rsi
    1168:	cmovl  0x5d30(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1170:	cmp    $0x6,%rcx
    1174:	je     1185 <botlish_fn_13+0x94d>
    117a:	mov    $0xd,%r11d
    1180:	jmp    1436 <botlish_fn_13+0xbfe>
    1185:	mov    0x328(%rsp),%r11
    118d:	jmp    1436 <botlish_fn_13+0xbfe>
    1192:	mov    $0xd,%r11d
    1198:	jmp    1436 <botlish_fn_13+0xbfe>
    119d:	mov    %r14,%rsi
    11a0:	mov    %rsi,%rax
    11a3:	sar    $1,%rax
    11a6:	cmp    $0x75,%rax
    11aa:	jl     11d2 <botlish_fn_13+0x99a>
    11b0:	cmp    $0x7b,%rax
    11b4:	jl     11c7 <botlish_fn_13+0x98f>
    11ba:	mov    0x328(%rsp),%r11
    11c2:	jmp    1436 <botlish_fn_13+0xbfe>
    11c7:	mov    $0xd,%r11d
    11cd:	jmp    1436 <botlish_fn_13+0xbfe>
    11d2:	mov    $0xb,%r11d
    11d8:	jmp    1436 <botlish_fn_13+0xbfe>
    11dd:	mov    %r14,%rsi
    11e0:	mov    %rsi,%rdx
    11e3:	sar    $1,%rdx
    11e6:	cmp    $0x67,%rdx
    11ea:	jl     1225 <botlish_fn_13+0x9ed>
    11f0:	cmp    $0x6e,%rdx
    11f4:	jl     121a <botlish_fn_13+0x9e2>
    11fa:	cmp    $0x6f,%rdx
    11fe:	jl     120f <botlish_fn_13+0x9d7>
    1204:	mov    $0xd,%r11d
    120a:	jmp    1436 <botlish_fn_13+0xbfe>
    120f:	mov    $0xb,%r11d
    1215:	jmp    1436 <botlish_fn_13+0xbfe>
    121a:	mov    $0xd,%r11d
    1220:	jmp    1436 <botlish_fn_13+0xbfe>
    1225:	cmp    $0x5e,%rdx
    1229:	jl     124f <botlish_fn_13+0xa17>
    122f:	cmp    $0x66,%rdx
    1233:	jl     1244 <botlish_fn_13+0xa0c>
    1239:	mov    $0xb,%r11d
    123f:	jmp    1436 <botlish_fn_13+0xbfe>
    1244:	mov    $0xd,%r11d
    124a:	jmp    1436 <botlish_fn_13+0xbfe>
    124f:	mov    0x328(%rsp),%r11
    1257:	jmp    1436 <botlish_fn_13+0xbfe>
    125c:	mov    %r14,%rsi
    125f:	test   $0x1,%rsi
    1266:	jne    1296 <botlish_fn_13+0xa5e>
    126c:	mov    $0x5d,%edx
    1271:	mov    %r14,%rsi
    1274:	mov    0x280(%rsp),%rdi
    127c:	call   1281 <botlish_fn_13+0xa49>
			127d: R_X86_64_PLT32	rt_int_cmp-0x4
    1281:	mov    $0x2,%ecx
    1286:	test   %rax,%rax
    1289:	cmovl  0x5c0f(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1291:	jmp    12aa <botlish_fn_13+0xa72>
    1296:	mov    $0x2,%ecx
    129b:	mov    %r14,%rsi
    129e:	cmp    $0x5d,%rsi
    12a2:	cmovl  0x5bf6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    12aa:	cmp    $0x6,%rcx
    12ae:	je     1335 <botlish_fn_13+0xafd>
    12b4:	mov    %r14,%rsi
    12b7:	mov    %rsi,%rax
    12ba:	sar    $1,%rax
    12bd:	cmp    $0x3b,%rax
    12c1:	jl     12fe <botlish_fn_13+0xac6>
    12c7:	cmp    $0x5b,%rax
    12cb:	jl     12f3 <botlish_fn_13+0xabb>
    12d1:	cmp    $0x5c,%rax
    12d5:	jl     12e6 <botlish_fn_13+0xaae>
    12db:	mov    $0xd,%r11d
    12e1:	jmp    1436 <botlish_fn_13+0xbfe>
    12e6:	mov    0x328(%rsp),%r11
    12ee:	jmp    1436 <botlish_fn_13+0xbfe>
    12f3:	mov    $0xd,%r11d
    12f9:	jmp    1436 <botlish_fn_13+0xbfe>
    12fe:	cmp    $0x30,%rax
    1302:	jl     132a <botlish_fn_13+0xaf2>
    1308:	cmp    $0x3a,%rax
    130c:	jl     131f <botlish_fn_13+0xae7>
    1312:	mov    0x328(%rsp),%r11
    131a:	jmp    1436 <botlish_fn_13+0xbfe>
    131f:	mov    $0x9,%r11d
    1325:	jmp    1436 <botlish_fn_13+0xbfe>
    132a:	mov    $0xd,%r11d
    1330:	jmp    1436 <botlish_fn_13+0xbfe>
    1335:	mov    %r14,%rsi
    1338:	test   $0x1,%rsi
    133f:	jne    136f <botlish_fn_13+0xb37>
    1345:	mov    $0x47,%edx
    134a:	mov    %r14,%rsi
    134d:	mov    0x280(%rsp),%rdi
    1355:	call   135a <botlish_fn_13+0xb22>
			1356: R_X86_64_PLT32	rt_int_cmp-0x4
    135a:	mov    $0x2,%ecx
    135f:	test   %rax,%rax
    1362:	cmovl  0x5b36(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    136a:	jmp    1383 <botlish_fn_13+0xb4b>
    136f:	mov    $0x2,%ecx
    1374:	mov    %r14,%rsi
    1377:	cmp    $0x47,%rsi
    137b:	cmovl  0x5b1d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1383:	cmp    $0x6,%rcx
    1387:	je     13cd <botlish_fn_13+0xb95>
    138d:	mov    %r14,%rsi
    1390:	mov    %rsi,%rax
    1393:	sar    $1,%rax
    1396:	cmp    $0x2c,%rax
    139a:	jl     13c2 <botlish_fn_13+0xb8a>
    13a0:	cmp    $0x2d,%rax
    13a4:	jl     13b5 <botlish_fn_13+0xb7d>
    13aa:	mov    $0x9,%r11d
    13b0:	jmp    1436 <botlish_fn_13+0xbfe>
    13b5:	mov    0x328(%rsp),%r11
    13bd:	jmp    1436 <botlish_fn_13+0xbfe>
    13c2:	mov    $0xd,%r11d
    13c8:	jmp    1436 <botlish_fn_13+0xbfe>
    13cd:	mov    %r14,%rsi
    13d0:	test   $0x1,%rsi
    13d7:	jne    1407 <botlish_fn_13+0xbcf>
    13dd:	mov    $0x45,%edx
    13e2:	mov    %r14,%rsi
    13e5:	mov    0x280(%rsp),%rdi
    13ed:	call   13f2 <botlish_fn_13+0xbba>
			13ee: R_X86_64_PLT32	rt_int_cmp-0x4
    13f2:	mov    $0x2,%ecx
    13f7:	test   %rax,%rax
    13fa:	cmovl  0x5a9e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1402:	jmp    141b <botlish_fn_13+0xbe3>
    1407:	mov    $0x2,%ecx
    140c:	mov    %r14,%rsi
    140f:	cmp    $0x45,%rsi
    1413:	cmovl  0x5a85(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    141b:	cmp    $0x6,%rcx
    141f:	je     1430 <botlish_fn_13+0xbf8>
    1425:	mov    $0x7,%r11d
    142b:	jmp    1436 <botlish_fn_13+0xbfe>
    1430:	mov    $0xd,%r11d
    1436:	sar    $1,%r11
    1439:	cmp    $0x1,%r11
    143d:	je     215d <botlish_fn_13+0x1925>
    1443:	cmp    $0x3,%r11
    1447:	je     1b89 <botlish_fn_13+0x1351>
    144d:	cmp    $0x4,%r11
    1451:	je     187d <botlish_fn_13+0x1045>
    1457:	cmp    $0x5,%r11
    145b:	je     154d <botlish_fn_13+0xd15>
    1461:	mov    %r14,%rsi
    1464:	test   $0x1,%rsi
    146b:	jne    149e <botlish_fn_13+0xc66>
    1471:	mov    0x300(%rsp),%rdx
    1479:	mov    %r14,%rsi
    147c:	mov    0x280(%rsp),%rdi
    1484:	call   1489 <botlish_fn_13+0xc51>
			1485: R_X86_64_PLT32	rt_int_cmp-0x4
    1489:	mov    $0x2,%esi
    148e:	test   %rax,%rax
    1491:	cmove  0x5a07(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    1499:	jmp    14b2 <botlish_fn_13+0xc7a>
    149e:	mov    $0x2,%esi
    14a3:	mov    %r14,%rax
    14a6:	cmp    $0xffffffffffffffff,%rax
    14aa:	cmove  0x59ee(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    14b2:	cmp    $0x6,%rsi
    14b6:	je     150b <botlish_fn_13+0xcd3>
    14bc:	mov    0x280(%rsp),%rdi
    14c4:	mov    0x10(%rdi),%rcx
    14c8:	mov    0x160(%rcx),%rax
    14cf:	mov    0x158(%rcx),%rdx
    14d6:	lea    0x1f8(%rsp),%r9
    14de:	mov    %rax,0x1f8(%rsp)
    14e6:	mov    %r14,%rsi
    14e9:	mov    %rsi,0x200(%rsp)
    14f1:	mov    $0x1,%esi
    14f6:	mov    $0x5,%ecx
    14fb:	mov    $0x2,%r8d
    1501:	call   1506 <botlish_fn_13+0xcce>
			1502: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1506:	jmp    1f62 <botlish_fn_13+0x172a>
    150b:	mov    0x280(%rsp),%rdi
    1513:	mov    0x10(%rdi),%rcx
    1517:	mov    0x160(%rcx),%rax
    151e:	mov    0x150(%rcx),%rdx
    1525:	lea    0x1f0(%rsp),%r9
    152d:	mov    %rax,0x1f0(%rsp)
    1535:	mov    $0x2,%ecx
    153a:	mov    $0x1,%r8d
    1540:	mov    %rcx,%rsi
    1543:	call   1548 <botlish_fn_13+0xd10>
			1544: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1548:	jmp    1f62 <botlish_fn_13+0x172a>
    154d:	mov    %r14,%rsi
    1550:	test   $0x1,%rsi
    1557:	jne    1587 <botlish_fn_13+0xd4f>
    155d:	mov    $0xdd,%edx
    1562:	mov    %r14,%rsi
    1565:	mov    0x280(%rsp),%rdi
    156d:	call   1572 <botlish_fn_13+0xd3a>
			156e: R_X86_64_PLT32	rt_int_cmp-0x4
    1572:	mov    $0x2,%ecx
    1577:	test   %rax,%rax
    157a:	cmovl  0x591e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1582:	jmp    159e <botlish_fn_13+0xd66>
    1587:	mov    $0x2,%ecx
    158c:	mov    %r14,%rsi
    158f:	cmp    $0xdd,%rsi
    1596:	cmovl  0x5902(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    159e:	cmp    $0x6,%rcx
    15a2:	je     169c <botlish_fn_13+0xe64>
    15a8:	mov    %r14,%rsi
    15ab:	test   $0x1,%rsi
    15b2:	jne    15e2 <botlish_fn_13+0xdaa>
    15b8:	mov    $0xe9,%edx
    15bd:	mov    %r14,%rsi
    15c0:	mov    0x280(%rsp),%rdi
    15c8:	call   15cd <botlish_fn_13+0xd95>
			15c9: R_X86_64_PLT32	rt_int_cmp-0x4
    15cd:	mov    $0x2,%ecx
    15d2:	test   %rax,%rax
    15d5:	cmovl  0x58c3(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    15dd:	jmp    15f9 <botlish_fn_13+0xdc1>
    15e2:	mov    $0x2,%ecx
    15e7:	mov    %r14,%rsi
    15ea:	cmp    $0xe9,%rsi
    15f1:	cmovl  0x58a7(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    15f9:	cmp    $0x6,%rcx
    15fd:	je     1675 <botlish_fn_13+0xe3d>
    1603:	mov    %r14,%rsi
    1606:	test   $0x1,%rsi
    160d:	jne    163d <botlish_fn_13+0xe05>
    1613:	mov    $0xeb,%edx
    1618:	mov    %r14,%rsi
    161b:	mov    0x280(%rsp),%rdi
    1623:	call   1628 <botlish_fn_13+0xdf0>
			1624: R_X86_64_PLT32	rt_int_cmp-0x4
    1628:	mov    $0x2,%ecx
    162d:	test   %rax,%rax
    1630:	cmovl  0x5868(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1638:	jmp    1654 <botlish_fn_13+0xe1c>
    163d:	mov    $0x2,%ecx
    1642:	mov    %r14,%rsi
    1645:	cmp    $0xeb,%rsi
    164c:	cmovl  0x584c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1654:	cmp    $0x6,%rcx
    1658:	je     1668 <botlish_fn_13+0xe30>
    165e:	mov    $0x1d,%ebx
    1663:	jmp    1723 <botlish_fn_13+0xeeb>
    1668:	mov    0x328(%rsp),%rbx
    1670:	jmp    1723 <botlish_fn_13+0xeeb>
    1675:	mov    %r14,%rsi
    1678:	mov    %rsi,%r10
    167b:	sar    $1,%r10
    167e:	cmp    $0x6f,%r10
    1682:	jl     1692 <botlish_fn_13+0xe5a>
    1688:	mov    $0x1d,%ebx
    168d:	jmp    1723 <botlish_fn_13+0xeeb>
    1692:	mov    $0x7,%ebx
    1697:	jmp    1723 <botlish_fn_13+0xeeb>
    169c:	mov    %r14,%rsi
    169f:	test   $0x1,%rsi
    16a6:	jne    16d6 <botlish_fn_13+0xe9e>
    16ac:	mov    $0xcd,%edx
    16b1:	mov    %r14,%rsi
    16b4:	mov    0x280(%rsp),%rdi
    16bc:	call   16c1 <botlish_fn_13+0xe89>
			16bd: R_X86_64_PLT32	rt_int_cmp-0x4
    16c1:	mov    $0x2,%ecx
    16c6:	test   %rax,%rax
    16c9:	cmovl  0x57cf(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    16d1:	jmp    16ed <botlish_fn_13+0xeb5>
    16d6:	mov    $0x2,%ecx
    16db:	mov    %r14,%rsi
    16de:	cmp    $0xcd,%rsi
    16e5:	cmovl  0x57b3(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    16ed:	cmp    $0x6,%rcx
    16f1:	je     171e <botlish_fn_13+0xee6>
    16f7:	mov    %r14,%rsi
    16fa:	mov    %rsi,%rax
    16fd:	sar    $1,%rax
    1700:	cmp    $0x67,%rax
    1704:	jl     1714 <botlish_fn_13+0xedc>
    170a:	mov    $0x1d,%ebx
    170f:	jmp    1723 <botlish_fn_13+0xeeb>
    1714:	mov    $0x5,%ebx
    1719:	jmp    1723 <botlish_fn_13+0xeeb>
    171e:	mov    $0x1d,%ebx
    1723:	mov    %rbx,%rsi
    1726:	sar    $1,%rsi
    1729:	cmp    $0xc,%rsi
    172d:	jl     183e <botlish_fn_13+0x1006>
    1733:	cmp    $0xd,%rsi
    1737:	mov    %rsi,%rbx
    173a:	je     2167 <botlish_fn_13+0x192f>
    1740:	mov    %r14,%rsi
    1743:	test   $0x1,%rsi
    174a:	jne    177d <botlish_fn_13+0xf45>
    1750:	mov    0x300(%rsp),%rdx
    1758:	mov    %r14,%rsi
    175b:	mov    0x280(%rsp),%rdi
    1763:	call   1768 <botlish_fn_13+0xf30>
			1764: R_X86_64_PLT32	rt_int_cmp-0x4
    1768:	mov    $0x2,%esi
    176d:	test   %rax,%rax
    1770:	cmove  0x5728(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    1778:	jmp    1791 <botlish_fn_13+0xf59>
    177d:	mov    $0x2,%esi
    1782:	mov    %r14,%rax
    1785:	cmp    $0xffffffffffffffff,%rax
    1789:	cmove  0x570f(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    1791:	cmp    $0x6,%rsi
    1795:	je     17f3 <botlish_fn_13+0xfbb>
    179b:	mov    %rbx,%rsi
    179e:	mov    0x280(%rsp),%rdi
    17a6:	call   17ab <botlish_fn_13+0xf73>
			17a7: R_X86_64_PLT32	botlish_fn_3-0x4
    17ab:	mov    0x280(%rsp),%rdi
    17b3:	mov    0x10(%rdi),%rcx
    17b7:	mov    0x158(%rcx),%rdx
    17be:	lea    0x1e0(%rsp),%r9
    17c6:	mov    %rax,0x1e0(%rsp)
    17ce:	mov    %r14,%rsi
    17d1:	mov    %rsi,0x1e8(%rsp)
    17d9:	mov    $0x1,%esi
    17de:	mov    $0x5,%ecx
    17e3:	mov    $0x2,%r8d
    17e9:	call   17ee <botlish_fn_13+0xfb6>
			17ea: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    17ee:	jmp    1f62 <botlish_fn_13+0x172a>
    17f3:	mov    %rbx,%rsi
    17f6:	mov    0x280(%rsp),%rdi
    17fe:	call   1803 <botlish_fn_13+0xfcb>
			17ff: R_X86_64_PLT32	botlish_fn_3-0x4
    1803:	mov    0x280(%rsp),%rdi
    180b:	mov    0x10(%rdi),%rcx
    180f:	mov    0x150(%rcx),%rdx
    1816:	lea    0x1d8(%rsp),%r9
    181e:	mov    %rax,0x1d8(%rsp)
    1826:	mov    $0x2,%ecx
    182b:	mov    $0x1,%r8d
    1831:	mov    %rcx,%rsi
    1834:	call   1839 <botlish_fn_13+0x1001>
			1835: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1839:	jmp    1f62 <botlish_fn_13+0x172a>
    183e:	mov    %rbx,0xa8(%rsp)
    1846:	mov    $0x6,%r12d
    184c:	movq   $0x6,0x80(%rsp)
    1858:	mov    $0xa,%ecx
    185d:	mov    %rcx,%r13
    1860:	mov    0x2f8(%rsp),%r14
    1868:	mov    %rcx,0x298(%rsp)
    1870:	mov    %rcx,0x2d8(%rsp)
    1878:	jmp    21f6 <botlish_fn_13+0x19be>
    187d:	mov    %r14,%rsi
    1880:	test   $0x1,%rsi
    1887:	jne    18b7 <botlish_fn_13+0x107f>
    188d:	mov    $0x61,%edx
    1892:	mov    %r14,%rsi
    1895:	mov    0x280(%rsp),%rdi
    189d:	call   18a2 <botlish_fn_13+0x106a>
			189e: R_X86_64_PLT32	rt_int_cmp-0x4
    18a2:	mov    $0x2,%ecx
    18a7:	test   %rax,%rax
    18aa:	cmovl  0x55ee(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    18b2:	jmp    18cb <botlish_fn_13+0x1093>
    18b7:	mov    $0x2,%ecx
    18bc:	mov    %r14,%rsi
    18bf:	cmp    $0x61,%rsi
    18c3:	cmovl  0x55d5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    18cb:	cmp    $0x6,%rcx
    18cf:	je     19a6 <botlish_fn_13+0x116e>
    18d5:	mov    %r14,%rsi
    18d8:	test   $0x1,%rsi
    18df:	jne    190f <botlish_fn_13+0x10d7>
    18e5:	mov    $0x63,%edx
    18ea:	mov    %r14,%rsi
    18ed:	mov    0x280(%rsp),%rdi
    18f5:	call   18fa <botlish_fn_13+0x10c2>
			18f6: R_X86_64_PLT32	rt_int_cmp-0x4
    18fa:	mov    $0x2,%ecx
    18ff:	test   %rax,%rax
    1902:	cmovl  0x5596(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    190a:	jmp    1923 <botlish_fn_13+0x10eb>
    190f:	mov    $0x2,%ecx
    1914:	mov    %r14,%rsi
    1917:	cmp    $0x63,%rsi
    191b:	cmovl  0x557d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1923:	cmp    $0x6,%rcx
    1927:	je     199b <botlish_fn_13+0x1163>
    192d:	mov    %r14,%rsi
    1930:	test   $0x1,%rsi
    1937:	jne    1967 <botlish_fn_13+0x112f>
    193d:	mov    $0x75,%edx
    1942:	mov    %r14,%rsi
    1945:	mov    0x280(%rsp),%rdi
    194d:	call   1952 <botlish_fn_13+0x111a>
			194e: R_X86_64_PLT32	rt_int_cmp-0x4
    1952:	mov    $0x2,%ecx
    1957:	test   %rax,%rax
    195a:	cmovl  0x553e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1962:	jmp    197b <botlish_fn_13+0x1143>
    1967:	mov    $0x2,%ecx
    196c:	mov    %r14,%rsi
    196f:	cmp    $0x75,%rsi
    1973:	cmovl  0x5525(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    197b:	cmp    $0x6,%rcx
    197f:	je     1990 <botlish_fn_13+0x1158>
    1985:	mov    $0x17,%r13d
    198b:	jmp    1a2f <botlish_fn_13+0x11f7>
    1990:	mov    $0x7,%r13d
    1996:	jmp    1a2f <botlish_fn_13+0x11f7>
    199b:	mov    $0x5,%r13d
    19a1:	jmp    1a2f <botlish_fn_13+0x11f7>
    19a6:	mov    %r14,%rsi
    19a9:	test   $0x1,%rsi
    19b0:	jne    19e0 <botlish_fn_13+0x11a8>
    19b6:	mov    $0x5b,%edx
    19bb:	mov    %r14,%rsi
    19be:	mov    0x280(%rsp),%rdi
    19c6:	call   19cb <botlish_fn_13+0x1193>
			19c7: R_X86_64_PLT32	rt_int_cmp-0x4
    19cb:	mov    $0x2,%esi
    19d0:	test   %rax,%rax
    19d3:	cmovl  0x54c5(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    19db:	jmp    19f4 <botlish_fn_13+0x11bc>
    19e0:	mov    $0x2,%esi
    19e5:	mov    %r14,%r11
    19e8:	cmp    $0x5b,%r11
    19ec:	cmovl  0x54ac(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    19f4:	cmp    $0x6,%rsi
    19f8:	je     1a29 <botlish_fn_13+0x11f1>
    19fe:	mov    %r14,%rsi
    1a01:	mov    %rsi,%rax
    1a04:	sar    $1,%rax
    1a07:	cmp    $0x2e,%rax
    1a0b:	jl     1a1c <botlish_fn_13+0x11e4>
    1a11:	mov    $0x17,%r13d
    1a17:	jmp    1a2f <botlish_fn_13+0x11f7>
    1a1c:	mov    0x328(%rsp),%r13
    1a24:	jmp    1a2f <botlish_fn_13+0x11f7>
    1a29:	mov    $0x17,%r13d
    1a2f:	mov    %r13,%rsi
    1a32:	sar    $1,%rsi
    1a35:	cmp    $0x9,%rsi
    1a39:	jl     1b4a <botlish_fn_13+0x1312>
    1a3f:	cmp    $0xa,%rsi
    1a43:	mov    %rsi,%rbx
    1a46:	je     2167 <botlish_fn_13+0x192f>
    1a4c:	mov    %r14,%rsi
    1a4f:	test   $0x1,%rsi
    1a56:	jne    1a89 <botlish_fn_13+0x1251>
    1a5c:	mov    0x300(%rsp),%rdx
    1a64:	mov    %r14,%rsi
    1a67:	mov    0x280(%rsp),%rdi
    1a6f:	call   1a74 <botlish_fn_13+0x123c>
			1a70: R_X86_64_PLT32	rt_int_cmp-0x4
    1a74:	mov    $0x2,%ecx
    1a79:	test   %rax,%rax
    1a7c:	cmove  0x541c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1a84:	jmp    1a9d <botlish_fn_13+0x1265>
    1a89:	mov    $0x2,%ecx
    1a8e:	mov    %r14,%rsi
    1a91:	cmp    $0xffffffffffffffff,%rsi
    1a95:	cmove  0x5403(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1a9d:	cmp    $0x6,%rcx
    1aa1:	je     1aff <botlish_fn_13+0x12c7>
    1aa7:	mov    %rbx,%rsi
    1aaa:	mov    0x280(%rsp),%rdi
    1ab2:	call   1ab7 <botlish_fn_13+0x127f>
			1ab3: R_X86_64_PLT32	botlish_fn_1-0x4
    1ab7:	mov    0x280(%rsp),%rdi
    1abf:	mov    0x10(%rdi),%rcx
    1ac3:	mov    0x158(%rcx),%rdx
    1aca:	lea    0x1c8(%rsp),%r9
    1ad2:	mov    %rax,0x1c8(%rsp)
    1ada:	mov    %r14,%rsi
    1add:	mov    %rsi,0x1d0(%rsp)
    1ae5:	mov    $0x1,%esi
    1aea:	mov    $0x5,%ecx
    1aef:	mov    $0x2,%r8d
    1af5:	call   1afa <botlish_fn_13+0x12c2>
			1af6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1afa:	jmp    1f62 <botlish_fn_13+0x172a>
    1aff:	mov    %rbx,%rsi
    1b02:	mov    0x280(%rsp),%rdi
    1b0a:	call   1b0f <botlish_fn_13+0x12d7>
			1b0b: R_X86_64_PLT32	botlish_fn_1-0x4
    1b0f:	mov    0x280(%rsp),%rdi
    1b17:	mov    0x10(%rdi),%rcx
    1b1b:	mov    0x150(%rcx),%rdx
    1b22:	lea    0x1c0(%rsp),%r9
    1b2a:	mov    %rax,0x1c0(%rsp)
    1b32:	mov    $0x2,%ecx
    1b37:	mov    $0x1,%r8d
    1b3d:	mov    %rcx,%rsi
    1b40:	call   1b45 <botlish_fn_13+0x130d>
			1b41: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1b45:	jmp    1f62 <botlish_fn_13+0x172a>
    1b4a:	mov    %r13,0xa0(%rsp)
    1b52:	mov    $0x6,%r12d
    1b58:	movq   $0x6,0x80(%rsp)
    1b64:	mov    $0xa,%ecx
    1b69:	mov    %rcx,%rbx
    1b6c:	mov    0x328(%rsp),%r14
    1b74:	mov    %rcx,0x298(%rsp)
    1b7c:	mov    %rcx,0x2d8(%rsp)
    1b84:	jmp    21f6 <botlish_fn_13+0x19be>
    1b89:	mov    %r14,%rsi
    1b8c:	test   $0x1,%rsi
    1b93:	jne    1bc3 <botlish_fn_13+0x138b>
    1b99:	mov    $0x45,%edx
    1b9e:	mov    %r14,%rsi
    1ba1:	mov    0x280(%rsp),%rdi
    1ba9:	call   1bae <botlish_fn_13+0x1376>
			1baa: R_X86_64_PLT32	rt_int_cmp-0x4
    1bae:	mov    $0x2,%ecx
    1bb3:	test   %rax,%rax
    1bb6:	cmovl  0x52e2(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1bbe:	jmp    1bd7 <botlish_fn_13+0x139f>
    1bc3:	mov    $0x2,%ecx
    1bc8:	mov    %r14,%rsi
    1bcb:	cmp    $0x45,%rsi
    1bcf:	cmovl  0x52c9(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1bd7:	cmp    $0x6,%rcx
    1bdb:	je     1c50 <botlish_fn_13+0x1418>
    1be1:	mov    %r14,%rsi
    1be4:	test   $0x1,%rsi
    1beb:	jne    1c1b <botlish_fn_13+0x13e3>
    1bf1:	mov    $0x47,%edx
    1bf6:	mov    %r14,%rsi
    1bf9:	mov    0x280(%rsp),%rdi
    1c01:	call   1c06 <botlish_fn_13+0x13ce>
			1c02: R_X86_64_PLT32	rt_int_cmp-0x4
    1c06:	mov    $0x2,%ecx
    1c0b:	test   %rax,%rax
    1c0e:	cmovl  0x528a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1c16:	jmp    1c2f <botlish_fn_13+0x13f7>
    1c1b:	mov    $0x2,%ecx
    1c20:	mov    %r14,%rsi
    1c23:	cmp    $0x47,%rsi
    1c27:	cmovl  0x5271(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1c2f:	cmp    $0x6,%rcx
    1c33:	je     1c43 <botlish_fn_13+0x140b>
    1c39:	mov    $0xb,%edx
    1c3e:	jmp    1c55 <botlish_fn_13+0x141d>
    1c43:	mov    0x328(%rsp),%rdx
    1c4b:	jmp    1c55 <botlish_fn_13+0x141d>
    1c50:	mov    $0xb,%edx
    1c55:	mov    %rdx,%rsi
    1c58:	sar    $1,%rsi
    1c5b:	cmp    $0x2,%rsi
    1c5f:	jl     211d <botlish_fn_13+0x18e5>
    1c65:	cmp    $0x2,%rsi
    1c69:	je     210e <botlish_fn_13+0x18d6>
    1c6f:	cmp    $0x4,%rsi
    1c73:	mov    %rsi,%rbx
    1c76:	je     1d7a <botlish_fn_13+0x1542>
    1c7c:	mov    %r14,%rsi
    1c7f:	test   $0x1,%rsi
    1c86:	jne    1cb9 <botlish_fn_13+0x1481>
    1c8c:	mov    0x300(%rsp),%rdx
    1c94:	mov    %r14,%rsi
    1c97:	mov    0x280(%rsp),%rdi
    1c9f:	call   1ca4 <botlish_fn_13+0x146c>
			1ca0: R_X86_64_PLT32	rt_int_cmp-0x4
    1ca4:	mov    $0x2,%ecx
    1ca9:	test   %rax,%rax
    1cac:	cmove  0x51ec(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1cb4:	jmp    1ccd <botlish_fn_13+0x1495>
    1cb9:	mov    $0x2,%ecx
    1cbe:	mov    %r14,%rsi
    1cc1:	cmp    $0xffffffffffffffff,%rsi
    1cc5:	cmove  0x51d3(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1ccd:	cmp    $0x6,%rcx
    1cd1:	je     1d2f <botlish_fn_13+0x14f7>
    1cd7:	mov    %rbx,%rsi
    1cda:	mov    0x280(%rsp),%rdi
    1ce2:	call   1ce7 <botlish_fn_13+0x14af>
			1ce3: R_X86_64_PLT32	botlish_fn_7-0x4
    1ce7:	mov    0x280(%rsp),%rdi
    1cef:	mov    0x10(%rdi),%rcx
    1cf3:	mov    0x158(%rcx),%rdx
    1cfa:	lea    0x1b0(%rsp),%r9
    1d02:	mov    %rax,0x1b0(%rsp)
    1d0a:	mov    %r14,%rsi
    1d0d:	mov    %rsi,0x1b8(%rsp)
    1d15:	mov    $0x1,%esi
    1d1a:	mov    $0x5,%ecx
    1d1f:	mov    $0x2,%r8d
    1d25:	call   1d2a <botlish_fn_13+0x14f2>
			1d26: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d2a:	jmp    1f62 <botlish_fn_13+0x172a>
    1d2f:	mov    %rbx,%rsi
    1d32:	mov    0x280(%rsp),%rdi
    1d3a:	call   1d3f <botlish_fn_13+0x1507>
			1d3b: R_X86_64_PLT32	botlish_fn_7-0x4
    1d3f:	mov    0x280(%rsp),%rdi
    1d47:	mov    0x10(%rdi),%rcx
    1d4b:	mov    0x150(%rcx),%rdx
    1d52:	lea    0x1a8(%rsp),%r9
    1d5a:	mov    %rax,0x1a8(%rsp)
    1d62:	mov    $0x2,%ecx
    1d67:	mov    $0x1,%r8d
    1d6d:	mov    %rcx,%rsi
    1d70:	call   1d75 <botlish_fn_13+0x153d>
			1d71: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d75:	jmp    1f62 <botlish_fn_13+0x172a>
    1d7a:	mov    %r14,%rsi
    1d7d:	test   $0x1,%rsi
    1d84:	jne    1db4 <botlish_fn_13+0x157c>
    1d8a:	mov    $0xb9,%edx
    1d8f:	mov    %r14,%rsi
    1d92:	mov    0x280(%rsp),%rdi
    1d9a:	call   1d9f <botlish_fn_13+0x1567>
			1d9b: R_X86_64_PLT32	rt_int_cmp-0x4
    1d9f:	mov    $0x2,%ecx
    1da4:	test   %rax,%rax
    1da7:	cmovl  0x50f1(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1daf:	jmp    1dcb <botlish_fn_13+0x1593>
    1db4:	mov    $0x2,%ecx
    1db9:	mov    %r14,%rsi
    1dbc:	cmp    $0xb9,%rsi
    1dc3:	cmovl  0x50d5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1dcb:	cmp    $0x6,%rcx
    1dcf:	je     1e47 <botlish_fn_13+0x160f>
    1dd5:	mov    %r14,%rsi
    1dd8:	test   $0x1,%rsi
    1ddf:	jne    1e0f <botlish_fn_13+0x15d7>
    1de5:	mov    $0xbb,%edx
    1dea:	mov    %r14,%rsi
    1ded:	mov    0x280(%rsp),%rdi
    1df5:	call   1dfa <botlish_fn_13+0x15c2>
			1df6: R_X86_64_PLT32	rt_int_cmp-0x4
    1dfa:	mov    $0x2,%ecx
    1dff:	test   %rax,%rax
    1e02:	cmovl  0x5096(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1e0a:	jmp    1e26 <botlish_fn_13+0x15ee>
    1e0f:	mov    $0x2,%ecx
    1e14:	mov    %r14,%rsi
    1e17:	cmp    $0xbb,%rsi
    1e1e:	cmovl  0x507a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1e26:	cmp    $0x6,%rcx
    1e2a:	je     1e3a <botlish_fn_13+0x1602>
    1e30:	mov    $0x11,%ecx
    1e35:	jmp    1e4c <botlish_fn_13+0x1614>
    1e3a:	mov    0x328(%rsp),%rcx
    1e42:	jmp    1e4c <botlish_fn_13+0x1614>
    1e47:	mov    $0x11,%ecx
    1e4c:	mov    %rcx,%rsi
    1e4f:	sar    $1,%rsi
    1e52:	cmp    $0x6,%rsi
    1e56:	jl     20ce <botlish_fn_13+0x1896>
    1e5c:	cmp    $0x6,%rsi
    1e60:	mov    %rsi,%rbx
    1e63:	je     20ad <botlish_fn_13+0x1875>
    1e69:	mov    %r14,%rsi
    1e6c:	test   $0x1,%rsi
    1e73:	jne    1ea6 <botlish_fn_13+0x166e>
    1e79:	mov    0x300(%rsp),%rdx
    1e81:	mov    %r14,%rsi
    1e84:	mov    0x280(%rsp),%rdi
    1e8c:	call   1e91 <botlish_fn_13+0x1659>
			1e8d: R_X86_64_PLT32	rt_int_cmp-0x4
    1e91:	mov    $0x2,%ecx
    1e96:	test   %rax,%rax
    1e99:	cmove  0x4fff(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1ea1:	jmp    1eba <botlish_fn_13+0x1682>
    1ea6:	mov    $0x2,%ecx
    1eab:	mov    %r14,%rsi
    1eae:	cmp    $0xffffffffffffffff,%rsi
    1eb2:	cmove  0x4fe6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    1eba:	cmp    $0x6,%rcx
    1ebe:	je     1f1c <botlish_fn_13+0x16e4>
    1ec4:	mov    %rbx,%rsi
    1ec7:	mov    0x280(%rsp),%rdi
    1ecf:	call   1ed4 <botlish_fn_13+0x169c>
			1ed0: R_X86_64_PLT32	botlish_fn_5-0x4
    1ed4:	mov    0x280(%rsp),%rdi
    1edc:	mov    0x10(%rdi),%rcx
    1ee0:	mov    0x158(%rcx),%rdx
    1ee7:	lea    0x198(%rsp),%r9
    1eef:	mov    %rax,0x198(%rsp)
    1ef7:	mov    %r14,%rsi
    1efa:	mov    %rsi,0x1a0(%rsp)
    1f02:	mov    $0x1,%esi
    1f07:	mov    $0x5,%ecx
    1f0c:	mov    $0x2,%r8d
    1f12:	call   1f17 <botlish_fn_13+0x16df>
			1f13: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1f17:	jmp    1f62 <botlish_fn_13+0x172a>
    1f1c:	mov    %rbx,%rsi
    1f1f:	mov    0x280(%rsp),%rdi
    1f27:	call   1f2c <botlish_fn_13+0x16f4>
			1f28: R_X86_64_PLT32	botlish_fn_5-0x4
    1f2c:	mov    0x280(%rsp),%rdi
    1f34:	mov    0x10(%rdi),%rcx
    1f38:	mov    0x150(%rcx),%rdx
    1f3f:	lea    0x190(%rsp),%r9
    1f47:	mov    %rax,0x190(%rsp)
    1f4f:	mov    $0x2,%ecx
    1f54:	mov    $0x1,%r8d
    1f5a:	mov    %rcx,%rsi
    1f5d:	call   1f62 <botlish_fn_13+0x172a>
			1f5e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1f62:	mov    0x280(%rsp),%rdi
    1f6a:	call   1f6f <botlish_fn_13+0x1737>
			1f6b: R_X86_64_PLT32	rt_co_failed-0x4
    1f6f:	mov    %rax,0x88(%rsp)
    1f77:	mov    %rax,%rsi
    1f7a:	mov    0x280(%rsp),%rdi
    1f82:	call   1f87 <botlish_fn_13+0x174f>
			1f83: R_X86_64_PLT32	rt_co_resume0-0x4
    1f87:	test   %rax,%rax
    1f8a:	je     1fac <botlish_fn_13+0x1774>
    1f90:	mov    0x280(%rsp),%rdi
    1f98:	mov    0x10(%rdi),%rax
    1f9c:	mov    0x50(%rax),%rsi
    1fa0:	mov    0x130(%rax),%rdx
    1fa7:	call   1fac <botlish_fn_13+0x1774>
			1fa8: R_X86_64_PLT32	rt_raise-0x4
    1fac:	mov    0x280(%rsp),%rdi
    1fb4:	call   1fb9 <botlish_fn_13+0x1781>
			1fb5: R_X86_64_PLT32	rt_declared_error-0x4
    1fb9:	cmp    $0x1,%rax
    1fbd:	je     203a <botlish_fn_13+0x1802>
    1fc3:	mov    0x280(%rsp),%rdi
    1fcb:	call   1fd0 <botlish_fn_13+0x1798>
			1fcc: R_X86_64_PLT32	rt_declared_error-0x4
    1fd0:	cmp    $0x2,%rax
    1fd4:	jne    6c28 <botlish_fn_13+0x63f0>
    1fda:	xor    %rsi,%rsi
    1fdd:	mov    0x280(%rsp),%rdi
    1fe5:	call   1fea <botlish_fn_13+0x17b2>
			1fe6: R_X86_64_PLT32	rt_declared_payload-0x4
    1fea:	mov    %rax,%rbx
    1fed:	mov    0x280(%rsp),%rdi
    1ff5:	call   1ffa <botlish_fn_13+0x17c2>
			1ff6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1ffa:	mov    0x280(%rsp),%rdi
    2002:	mov    0x10(%rdi),%rax
    2006:	mov    0x140(%rax),%rdx
    200d:	lea    0xc0(%rsp),%r9
    2015:	mov    %rbx,%rax
    2018:	mov    %rax,0xc0(%rsp)
    2020:	mov    $0x5,%esi
    2025:	mov    $0x2,%ecx
    202a:	mov    $0x1,%r8d
    2030:	call   2035 <botlish_fn_13+0x17fd>
			2031: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2035:	jmp    6c28 <botlish_fn_13+0x63f0>
    203a:	xor    %rsi,%rsi
    203d:	mov    0x280(%rsp),%rdi
    2045:	call   204a <botlish_fn_13+0x1812>
			2046: R_X86_64_PLT32	rt_declared_payload-0x4
    204a:	mov    %rax,%rbx
    204d:	mov    0x280(%rsp),%rdi
    2055:	call   205a <botlish_fn_13+0x1822>
			2056: R_X86_64_PLT32	rt_clear_declared_error-0x4
    205a:	mov    0x280(%rsp),%rdi
    2062:	mov    0x10(%rdi),%rax
    2066:	mov    0x138(%rax),%rdx
    206d:	lea    0xb0(%rsp),%r9
    2075:	mov    0x2f0(%rsp),%rcx
    207d:	mov    %rcx,0xb0(%rsp)
    2085:	mov    %rbx,%rax
    2088:	mov    %rax,0xb8(%rsp)
    2090:	mov    $0x1,%ecx
    2095:	mov    $0x2,%r8d
    209b:	mov    0x2f8(%rsp),%rsi
    20a3:	call   20a8 <botlish_fn_13+0x1870>
			20a4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    20a8:	jmp    6c28 <botlish_fn_13+0x63f0>
    20ad:	movq   $0x3,0x90(%rsp)
    20b9:	mov    0x328(%rsp),%rax
    20c1:	mov    %rax,0x298(%rsp)
    20c9:	jmp    212d <botlish_fn_13+0x18f5>
    20ce:	mov    %rcx,0x98(%rsp)
    20d6:	mov    $0x6,%r12d
    20dc:	movq   $0x6,0x80(%rsp)
    20e8:	mov    $0x1,%r14d
    20ee:	mov    $0xa,%edx
    20f3:	mov    %rdx,%rbx
    20f6:	mov    %rdx,%r13
    20f9:	mov    %rdx,0x298(%rsp)
    2101:	mov    %rcx,0x2d8(%rsp)
    2109:	jmp    21f6 <botlish_fn_13+0x19be>
    210e:	mov    $0xfffffffffffffffd,%rsi
    2115:	mov    %rsi,%r14
    2118:	jmp    2167 <botlish_fn_13+0x192f>
    211d:	mov    %rdx,0x90(%rsp)
    2125:	mov    %rdx,0x298(%rsp)
    212d:	mov    $0x6,%r12d
    2133:	movq   $0x6,0x80(%rsp)
    213f:	mov    $0x2,%r14d
    2145:	mov    $0xa,%ecx
    214a:	mov    %rcx,%rbx
    214d:	mov    %rcx,%r13
    2150:	mov    %rcx,0x2d8(%rsp)
    2158:	jmp    21f6 <botlish_fn_13+0x19be>
    215d:	mov    $0xfffffffffffffffd,%rsi
    2164:	mov    %rsi,%r14
    2167:	mov    %r14,%rsi
    216a:	test   $0x1,%rsi
    2171:	jne    21a4 <botlish_fn_13+0x196c>
    2177:	mov    $0xfffffffffffffffd,%rdx
    217e:	mov    %r14,%rsi
    2181:	mov    0x280(%rsp),%rdi
    2189:	call   218e <botlish_fn_13+0x1956>
			218a: R_X86_64_PLT32	rt_int_cmp-0x4
    218e:	mov    $0x2,%r12d
    2194:	test   %rax,%rax
    2197:	cmove  0x4d01(%rip),%r12        # 6ea0 <botlish_fn_13+0x6668>
    219f:	jmp    21b9 <botlish_fn_13+0x1981>
    21a4:	mov    $0x2,%r12d
    21aa:	mov    %r14,%rsi
    21ad:	cmp    $0xfffffffffffffffd,%rsi
    21b1:	cmove  0x4ce7(%rip),%r12        # 6ea0 <botlish_fn_13+0x6668>
    21b9:	mov    %r12,0x80(%rsp)
    21c1:	mov    $0xa,%ecx
    21c6:	mov    %rcx,0x2d8(%rsp)
    21ce:	mov    0x2d8(%rsp),%rbx
    21d6:	mov    0x2d8(%rsp),%r13
    21de:	mov    0x300(%rsp),%r14
    21e6:	mov    0x2d8(%rsp),%rax
    21ee:	mov    %rax,0x298(%rsp)
    21f6:	mov    0x308(%rsp),%rax
    21fe:	mov    0x18(%rax),%rax
    2202:	test   %rax,%rax
    2205:	je     6db4 <botlish_fn_13+0x657c>
    220b:	mov    0x308(%rsp),%rax
    2213:	mov    0x10(%rax),%rax
    2217:	mov    %r12,(%rax)
    221a:	lea    0x160(%rsp),%rax
    2222:	mov    %rax,0x2e8(%rsp)
    222a:	mov    0x308(%rsp),%rdx
    2232:	mov    0x308(%rsp),%rdx
    223a:	mov    0x10(%rdx),%rax
    223e:	mov    (%rax),%rcx
    2241:	cmp    $0x6,%rcx
    2245:	jne    27f7 <botlish_fn_13+0x1fbf>
    224b:	movq   $0x1,0x30(%rsp)
    2254:	mov    0x318(%rsp),%r11
    225c:	mov    0x10(%r11),%rax
    2260:	mov    (%rax),%rsi
    2263:	mov    %rsi,0x38(%rsp)
    2268:	movq   $0x3,0x40(%rsp)
    2271:	test   $0x1,%rsi
    2278:	je     229d <botlish_fn_13+0x1a65>
    227e:	mov    %rsi,%rcx
    2281:	add    $0x2,%rcx
    2285:	seto   %al
    2288:	test   %al,%al
    228a:	jne    229d <botlish_fn_13+0x1a65>
    2290:	mov    0x318(%rsp),%r11
    2298:	jmp    22bd <botlish_fn_13+0x1a85>
    229d:	mov    0x328(%rsp),%rdx
    22a5:	mov    0x280(%rsp),%rdi
    22ad:	call   22b2 <botlish_fn_13+0x1a7a>
			22ae: R_X86_64_PLT32	rt_int_add-0x4
    22b2:	mov    %rax,%rcx
    22b5:	mov    0x318(%rsp),%r11
    22bd:	mov    0x318(%rsp),%r11
    22c5:	mov    0x18(%r11),%rax
    22c9:	test   %rax,%rax
    22cc:	je     6dd6 <botlish_fn_13+0x659e>
    22d2:	mov    0x318(%rsp),%r11
    22da:	mov    0x10(%r11),%rax
    22de:	mov    %rcx,(%rax)
    22e1:	movq   $0x1,0x30(%rsp)
    22ea:	mov    0x2a0(%rsp),%rcx
    22f2:	cmp    $0x1,%rcx
    22f6:	je     2318 <botlish_fn_13+0x1ae0>
    22fc:	mov    $0xa,%esi
    2301:	cmp    $0xffffffffffffffff,%rcx
    2305:	jne    2639 <botlish_fn_13+0x1e01>
    230b:	mov    %rcx,0x2a0(%rsp)
    2313:	jmp    27cb <botlish_fn_13+0x1f93>
    2318:	movq   $0xa,0x38(%rsp)
    2321:	movq   $0x0,0x160(%rsp)
    232d:	mov    0x2a8(%rsp),%rax
    2335:	mov    %rax,0x168(%rsp)
    233d:	movq   $0x2,0x170(%rsp)
    2349:	movq   $0xa,0x178(%rsp)
    2355:	mov    0x2e8(%rsp),%rcx
    235d:	mov    0x2f8(%rsp),%rdx
    2365:	mov    0x328(%rsp),%rsi
    236d:	mov    0x280(%rsp),%rdi
    2375:	call   237a <botlish_fn_13+0x1b42>
			2376: R_X86_64_PLT32	rt_construct-0x4
    237a:	mov    %rax,%rcx
    237d:	mov    %rax,0x2a8(%rsp)
    2385:	test   %rcx,%rax
    2388:	je     261b <botlish_fn_13+0x1de3>
    238e:	mov    0x2a8(%rsp),%rax
    2396:	mov    %rax,0x78(%rsp)
    239b:	mov    0x2b8(%rsp),%rax
    23a3:	add    $0x1,%rax
    23aa:	mov    %rax,0x2b8(%rsp)
    23b2:	lea    0x180(%rsp),%r15
    23ba:	mov    0x2c0(%rsp),%rdx
    23c2:	cmp    %rdx,%rax
    23c5:	jl     2709 <botlish_fn_13+0x1ed1>
    23cb:	movq   $0x0,0x180(%rsp)
    23d7:	mov    0x2a8(%rsp),%rax
    23df:	mov    %rax,0x188(%rsp)
    23e7:	mov    $0x1,%esi
    23ec:	mov    $0x2,%edx
    23f1:	mov    %r15,%rcx
    23f4:	mov    0x280(%rsp),%rdi
    23fc:	call   2401 <botlish_fn_13+0x1bc9>
			23fd: R_X86_64_PLT32	rt_construct-0x4
    2401:	test   %rax,%rax
    2404:	je     261b <botlish_fn_13+0x1de3>
    240a:	movq   $0x3,0x38(%rsp)
    2413:	mov    0x2d0(%rsp),%rsi
    241b:	test   $0x1,%rsi
    2422:	jne    2435 <botlish_fn_13+0x1bfd>
    2428:	mov    0x2d0(%rsp),%rsi
    2430:	jmp    246c <botlish_fn_13+0x1c34>
    2435:	mov    0x2d0(%rsp),%rsi
    243d:	mov    %rsi,%r10
    2440:	add    $0x2,%r10
    2444:	seto   %al
    2447:	test   %al,%al
    2449:	je     245c <botlish_fn_13+0x1c24>
    244f:	mov    0x2d0(%rsp),%rsi
    2457:	jmp    246c <botlish_fn_13+0x1c34>
    245c:	mov    %r10,%rsi
    245f:	mov    %r10,0x2d0(%rsp)
    2467:	jmp    248c <botlish_fn_13+0x1c54>
    246c:	mov    0x328(%rsp),%rdx
    2474:	mov    0x280(%rsp),%rdi
    247c:	call   2481 <botlish_fn_13+0x1c49>
			247d: R_X86_64_PLT32	rt_int_add-0x4
    2481:	mov    %rax,%rsi
    2484:	mov    %rax,0x2d0(%rsp)
    248c:	mov    %rsi,0x68(%rsp)
    2491:	mov    0x330(%rsp),%rcx
    2499:	mov    0x2d0(%rsp),%rsi
    24a1:	mov    %rsi,%rax
    24a4:	and    %rcx,%rax
    24a7:	test   $0x1,%rax
    24ad:	jne    24e6 <botlish_fn_13+0x1cae>
    24b3:	mov    0x330(%rsp),%rdx
    24bb:	mov    0x2d0(%rsp),%rsi
    24c3:	mov    0x280(%rsp),%rdi
    24cb:	call   24d0 <botlish_fn_13+0x1c98>
			24cc: R_X86_64_PLT32	rt_int_cmp-0x4
    24d0:	mov    $0x2,%r9d
    24d6:	test   %rax,%rax
    24d9:	cmovl  0x49bf(%rip),%r9        # 6ea0 <botlish_fn_13+0x6668>
    24e1:	jmp    2507 <botlish_fn_13+0x1ccf>
    24e6:	mov    $0x2,%r9d
    24ec:	mov    0x330(%rsp),%rcx
    24f4:	mov    0x2d0(%rsp),%rsi
    24fc:	cmp    %rcx,%rsi
    24ff:	cmovl  0x4999(%rip),%r9        # 6ea0 <botlish_fn_13+0x6668>
    2507:	cmp    $0x6,%r9
    250b:	je     254d <botlish_fn_13+0x1d15>
    2511:	movq   $0xffffffffffffffff,0x48(%rsp)
    251a:	mov    $0xa,%eax
    251f:	mov    %rax,0x2a8(%rsp)
    2527:	movq   $0xa,0x78(%rsp)
    2530:	mov    0x300(%rsp),%rax
    2538:	mov    %rax,0x2a0(%rsp)
    2540:	mov    %rax,0x2b0(%rsp)
    2548:	jmp    27cb <botlish_fn_13+0x1f93>
    254d:	mov    0x2d0(%rsp),%rsi
    2555:	test   $0x1,%rsi
    255c:	je     2585 <botlish_fn_13+0x1d4d>
    2562:	mov    0x288(%rsp),%rcx
    256a:	mov    0x8(%rcx),%rax
    256e:	mov    0x2d0(%rsp),%rsi
    2576:	mov    %rsi,%rcx
    2579:	sar    $1,%rcx
    257c:	cmp    %rax,%rcx
    257f:	jb     25c3 <botlish_fn_13+0x1d8b>
    2585:	mov    0x2d0(%rsp),%rdx
    258d:	mov    0x288(%rsp),%rsi
    2595:	mov    0x280(%rsp),%rdi
    259d:	call   25a2 <botlish_fn_13+0x1d6a>
			259e: R_X86_64_PLT32	rt_list_get-0x4
    25a2:	mov    %rax,%rsi
    25a5:	mov    %rax,0x2c8(%rsp)
    25ad:	test   %rsi,%rax
    25b0:	je     261b <botlish_fn_13+0x1de3>
    25b6:	mov    0x2c8(%rsp),%rax
    25be:	jmp    25db <botlish_fn_13+0x1da3>
    25c3:	mov    0x288(%rsp),%rax
    25cb:	mov    0x10(%rax),%rax
    25cf:	mov    (%rax,%rcx,8),%rax
    25d3:	mov    %rax,0x2c8(%rsp)
    25db:	mov    %rax,0x70(%rsp)
    25e0:	mov    0x2c8(%rsp),%rax
    25e8:	mov    0x8(%rax),%rdx
    25ec:	mov    %rdx,0x2c0(%rsp)
    25f4:	xor    %rdx,%rdx
    25f7:	mov    0x280(%rsp),%rdi
    25ff:	mov    %rdx,%rsi
    2602:	call   2607 <botlish_fn_13+0x1dcf>
			2603: R_X86_64_PLT32	rt_list_new-0x4
    2607:	mov    %rax,%r10
    260a:	mov    %rax,0x2a8(%rsp)
    2612:	test   %r10,%rax
    2615:	jne    26b7 <botlish_fn_13+0x1e7f>
    261b:	mov    0x280(%rsp),%rdi
    2623:	call   2628 <botlish_fn_13+0x1df0>
			2624: R_X86_64_PLT32	rt_co_failed-0x4
    2628:	mov    %rax,0x50(%rsp)
    262d:	movq   $0xa,0x78(%rsp)
    2636:	mov    %rax,%rsi
    2639:	mov    0x280(%rsp),%rdi
    2641:	call   2646 <botlish_fn_13+0x1e0e>
			2642: R_X86_64_PLT32	rt_co_resume0-0x4
    2646:	test   %rax,%rax
    2649:	je     266b <botlish_fn_13+0x1e33>
    264f:	mov    0x280(%rsp),%rdi
    2657:	mov    0x10(%rdi),%rax
    265b:	mov    0x50(%rax),%rsi
    265f:	mov    0x130(%rax),%rdx
    2666:	call   266b <botlish_fn_13+0x1e33>
			2667: R_X86_64_PLT32	rt_raise-0x4
    266b:	mov    0x280(%rsp),%rdi
    2673:	call   2678 <botlish_fn_13+0x1e40>
			2674: R_X86_64_PLT32	rt_declared_error-0x4
    2678:	cmp    $0x40000001,%rax
    267e:	je     2691 <botlish_fn_13+0x1e59>
    2684:	mov    0x280(%rsp),%rdi
    268c:	jmp    2699 <botlish_fn_13+0x1e61>
    2691:	mov    0x280(%rsp),%rdi
    2699:	mov    0x280(%rsp),%rdi
    26a1:	call   26a6 <botlish_fn_13+0x1e6e>
			26a2: R_X86_64_PLT32	rt_declared_error-0x4
    26a6:	cmp    $0x40000001,%rax
    26ac:	jne    6c28 <botlish_fn_13+0x63f0>
    26b2:	jmp    6c28 <botlish_fn_13+0x63f0>
    26b7:	mov    0x2a8(%rsp),%rax
    26bf:	mov    %rax,0x78(%rsp)
    26c4:	mov    %rax,%rcx
    26c7:	mov    %rax,0x2b8(%rsp)
    26cf:	xor    %rcx,%rax
    26d2:	mov    0x2c0(%rsp),%rdx
    26da:	mov    %rax,0x2b8(%rsp)
    26e2:	shl    $1,%rdx
    26e5:	mov    %rdx,0x2c0(%rsp)
    26ed:	or     $0x1,%rdx
    26f1:	mov    %rdx,0x2c0(%rsp)
    26f9:	sar    $1,%rdx
    26fc:	mov    %rdx,0x2c0(%rsp)
    2704:	jmp    23c2 <botlish_fn_13+0x1b8a>
    2709:	mov    0x2c8(%rsp),%rax
    2711:	movzbq 0x18(%rax),%rax
    2716:	test   %rax,%rax
    2719:	jne    2753 <botlish_fn_13+0x1f1b>
    271f:	mov    0x2b8(%rsp),%rax
    2727:	mov    %rax,%rdx
    272a:	shl    $1,%rdx
    272d:	or     $0x1,%rdx
    2731:	mov    0x2c8(%rsp),%rsi
    2739:	mov    0x280(%rsp),%rdi
    2741:	call   2746 <botlish_fn_13+0x1f0e>
			2742: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    2746:	mov    %rax,0x2b0(%rsp)
    274e:	jmp    2796 <botlish_fn_13+0x1f5e>
    2753:	mov    0x2b8(%rsp),%rax
    275b:	mov    %rax,%rcx
    275e:	shl    $1,%rcx
    2761:	or     $0x1,%rcx
    2765:	sar    $1,%rcx
    2768:	mov    0x2c8(%rsp),%rax
    2770:	movzbq 0x19(%rax,%rcx,1),%rax
    2776:	mov    %rax,0x2b0(%rsp)
    277e:	shl    $0x3,%rax
    2782:	mov    %rax,0x2b0(%rsp)
    278a:	or     $0x4,%rax
    278e:	mov    %rax,0x2b0(%rsp)
    2796:	shr    $0x3,%rax
    279a:	mov    %rax,0x2b0(%rsp)
    27a2:	mov    $0x1,%ecx
    27a7:	mov    %rcx,0x2a0(%rsp)
    27af:	shl    $1,%rax
    27b2:	mov    %rax,0x2b0(%rsp)
    27ba:	or     $0x1,%rax
    27be:	mov    %rax,0x2b0(%rsp)
    27c6:	mov    %rax,0x48(%rsp)
    27cb:	mov    0x320(%rsp),%rcx
    27d3:	mov    0x18(%rcx),%rdi
    27d7:	test   %rdi,%rdi
    27da:	je     6df5 <botlish_fn_13+0x65bd>
    27e0:	mov    0x320(%rsp),%rcx
    27e8:	mov    0x10(%rcx),%r10
    27ec:	mov    0x2b0(%rsp),%rax
    27f4:	mov    %rax,(%r10)
    27f7:	test   %r14,%r14
    27fa:	jl     66b7 <botlish_fn_13+0x5e7f>
    2800:	mov    0x318(%rsp),%r11
    2808:	mov    0x10(%r11),%rax
    280c:	mov    (%rax),%rsi
    280f:	mov    %rsi,0x30(%rsp)
    2814:	mov    0x2f0(%rsp),%rcx
    281c:	mov    %rsi,%rax
    281f:	and    %rcx,%rax
    2822:	test   $0x1,%rax
    2828:	je     2863 <botlish_fn_13+0x202b>
    282e:	mov    0x2f0(%rsp),%rax
    2836:	mov    %rsi,%rcx
    2839:	sub    %rax,%rcx
    283c:	mov    %rsi,%rdx
    283f:	seto   %al
    2842:	lea    0x1(%rcx),%rsi
    2846:	test   %al,%al
    2848:	je     2856 <botlish_fn_13+0x201e>
    284e:	mov    %rdx,%rsi
    2851:	jmp    2863 <botlish_fn_13+0x202b>
    2856:	mov    0x290(%rsp),%rdx
    285e:	jmp    2883 <botlish_fn_13+0x204b>
    2863:	mov    0x2f0(%rsp),%rdx
    286b:	mov    0x280(%rsp),%rdi
    2873:	call   2878 <botlish_fn_13+0x2040>
			2874: R_X86_64_PLT32	rt_int_sub-0x4
    2878:	mov    0x290(%rsp),%rdx
    2880:	mov    %rax,%rsi
    2883:	mov    %rsi,%rax
    2886:	and    %rdx,%rax
    2889:	mov    %rdx,0x290(%rsp)
    2891:	test   $0x1,%rax
    2897:	jne    28c7 <botlish_fn_13+0x208f>
    289d:	mov    0x290(%rsp),%rdx
    28a5:	mov    0x280(%rsp),%rdi
    28ad:	call   28b2 <botlish_fn_13+0x207a>
			28ae: R_X86_64_PLT32	rt_int_cmp-0x4
    28b2:	mov    $0x2,%ecx
    28b7:	test   %rax,%rax
    28ba:	cmovge 0x45de(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    28c2:	jmp    28df <botlish_fn_13+0x20a7>
    28c7:	mov    $0x2,%ecx
    28cc:	mov    0x290(%rsp),%rdx
    28d4:	cmp    %rdx,%rsi
    28d7:	cmovge 0x45c1(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    28df:	cmp    $0x6,%rcx
    28e3:	je     665f <botlish_fn_13+0x5e27>
    28e9:	mov    0x320(%rsp),%rcx
    28f1:	mov    0x10(%rcx),%rax
    28f5:	mov    (%rax),%rsi
    28f8:	cmp    $0x1,%r14
    28fc:	je     56ee <botlish_fn_13+0x4eb6>
    2902:	cmp    $0x2,%r14
    2906:	je     518f <botlish_fn_13+0x4957>
    290c:	cmp    $0x3,%r14
    2910:	je     3856 <botlish_fn_13+0x301e>
    2916:	cmp    $0x4,%r14
    291a:	je     293c <botlish_fn_13+0x2104>
    2920:	mov    $0xa,%esi
    2925:	cmp    $0xffffffffffffffff,%r14
    2929:	jne    6493 <botlish_fn_13+0x5c5b>
    292f:	mov    0x298(%rsp),%r15
    2937:	jmp    6626 <botlish_fn_13+0x5dee>
    293c:	mov    %rbx,%r12
    293f:	sar    $1,%rbx
    2942:	cmp    $0x6,%rbx
    2946:	jl     30c9 <botlish_fn_13+0x2891>
    294c:	cmp    $0x9,%rbx
    2950:	jl     2e37 <botlish_fn_13+0x25ff>
    2956:	cmp    $0xa,%rbx
    295a:	jl     2d63 <botlish_fn_13+0x252b>
    2960:	cmp    $0xb,%rbx
    2964:	jl     2a3e <botlish_fn_13+0x2206>
    296a:	test   $0x1,%rsi
    2971:	mov    %rsi,%r14
    2974:	jne    29a4 <botlish_fn_13+0x216c>
    297a:	mov    $0xcb,%edx
    297f:	mov    %r14,%rsi
    2982:	mov    0x280(%rsp),%rdi
    298a:	call   298f <botlish_fn_13+0x2157>
			298b: R_X86_64_PLT32	rt_int_cmp-0x4
    298f:	mov    $0x2,%ecx
    2994:	test   %rax,%rax
    2997:	cmovl  0x4501(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    299f:	jmp    29bb <botlish_fn_13+0x2183>
    29a4:	mov    $0x2,%ecx
    29a9:	mov    %r14,%rsi
    29ac:	cmp    $0xcb,%rsi
    29b3:	cmovl  0x44e5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    29bb:	cmp    $0x6,%rcx
    29bf:	je     2a34 <botlish_fn_13+0x21fc>
    29c5:	mov    %r14,%rsi
    29c8:	test   $0x1,%rsi
    29cf:	jne    29ff <botlish_fn_13+0x21c7>
    29d5:	mov    $0xcd,%edx
    29da:	mov    %r14,%rsi
    29dd:	mov    0x280(%rsp),%rdi
    29e5:	call   29ea <botlish_fn_13+0x21b2>
			29e6: R_X86_64_PLT32	rt_int_cmp-0x4
    29ea:	mov    $0x2,%ecx
    29ef:	test   %rax,%rax
    29f2:	cmovl  0x44a6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    29fa:	jmp    2a16 <botlish_fn_13+0x21de>
    29ff:	mov    $0x2,%ecx
    2a04:	mov    %r14,%rsi
    2a07:	cmp    $0xcd,%rsi
    2a0e:	cmovl  0x448a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2a16:	cmp    $0x6,%rcx
    2a1a:	je     2a2a <botlish_fn_13+0x21f2>
    2a20:	mov    $0x33,%ebx
    2a25:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2a2a:	mov    $0x15,%ebx
    2a2f:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2a34:	mov    $0x33,%ebx
    2a39:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2a3e:	mov    %rsi,%r14
    2a41:	test   $0x1,%rsi
    2a48:	jne    2a78 <botlish_fn_13+0x2240>
    2a4e:	mov    $0x41,%edx
    2a53:	mov    %r14,%rsi
    2a56:	mov    0x280(%rsp),%rdi
    2a5e:	call   2a63 <botlish_fn_13+0x222b>
			2a5f: R_X86_64_PLT32	rt_int_cmp-0x4
    2a63:	mov    $0x2,%ecx
    2a68:	test   %rax,%rax
    2a6b:	cmovl  0x442d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2a73:	jmp    2a8c <botlish_fn_13+0x2254>
    2a78:	mov    $0x2,%ecx
    2a7d:	mov    %r14,%rsi
    2a80:	cmp    $0x41,%rsi
    2a84:	cmovl  0x4414(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2a8c:	cmp    $0x6,%rcx
    2a90:	je     2c31 <botlish_fn_13+0x23f9>
    2a96:	mov    %r14,%rsi
    2a99:	test   $0x1,%rsi
    2aa0:	jne    2ad0 <botlish_fn_13+0x2298>
    2aa6:	mov    $0xbb,%edx
    2aab:	mov    %r14,%rsi
    2aae:	mov    0x280(%rsp),%rdi
    2ab6:	call   2abb <botlish_fn_13+0x2283>
			2ab7: R_X86_64_PLT32	rt_int_cmp-0x4
    2abb:	mov    $0x2,%ecx
    2ac0:	test   %rax,%rax
    2ac3:	cmovl  0x43d5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2acb:	jmp    2ae7 <botlish_fn_13+0x22af>
    2ad0:	mov    $0x2,%ecx
    2ad5:	mov    %r14,%rsi
    2ad8:	cmp    $0xbb,%rsi
    2adf:	cmovl  0x43b9(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2ae7:	cmp    $0x6,%rcx
    2aeb:	je     2be2 <botlish_fn_13+0x23aa>
    2af1:	mov    %r14,%rsi
    2af4:	test   $0x1,%rsi
    2afb:	jne    2b2b <botlish_fn_13+0x22f3>
    2b01:	mov    $0xfb,%edx
    2b06:	mov    %r14,%rsi
    2b09:	mov    0x280(%rsp),%rdi
    2b11:	call   2b16 <botlish_fn_13+0x22de>
			2b12: R_X86_64_PLT32	rt_int_cmp-0x4
    2b16:	mov    $0x2,%edi
    2b1b:	test   %rax,%rax
    2b1e:	cmovl  0x437a(%rip),%rdi        # 6ea0 <botlish_fn_13+0x6668>
    2b26:	jmp    2b42 <botlish_fn_13+0x230a>
    2b2b:	mov    $0x2,%edi
    2b30:	mov    %r14,%rsi
    2b33:	cmp    $0xfb,%rsi
    2b3a:	cmovl  0x435e(%rip),%rdi        # 6ea0 <botlish_fn_13+0x6668>
    2b42:	cmp    $0x6,%rdi
    2b46:	je     2bbb <botlish_fn_13+0x2383>
    2b4c:	mov    %r14,%rsi
    2b4f:	test   $0x1,%rsi
    2b56:	jne    2b86 <botlish_fn_13+0x234e>
    2b5c:	mov    $0xfd,%edx
    2b61:	mov    %r14,%rsi
    2b64:	mov    0x280(%rsp),%rdi
    2b6c:	call   2b71 <botlish_fn_13+0x2339>
			2b6d: R_X86_64_PLT32	rt_int_cmp-0x4
    2b71:	mov    $0x2,%ecx
    2b76:	test   %rax,%rax
    2b79:	cmovl  0x431f(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2b81:	jmp    2b9d <botlish_fn_13+0x2365>
    2b86:	mov    $0x2,%ecx
    2b8b:	mov    %r14,%rsi
    2b8e:	cmp    $0xfd,%rsi
    2b95:	cmovl  0x4303(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2b9d:	cmp    $0x6,%rcx
    2ba1:	je     2bb1 <botlish_fn_13+0x2379>
    2ba7:	mov    $0x31,%ebx
    2bac:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2bb1:	mov    $0x1b,%ebx
    2bb6:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2bbb:	mov    %r14,%rsi
    2bbe:	mov    %rsi,%rax
    2bc1:	sar    $1,%rax
    2bc4:	cmp    $0x5e,%rax
    2bc8:	jl     2bd8 <botlish_fn_13+0x23a0>
    2bce:	mov    $0x31,%ebx
    2bd3:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2bd8:	mov    $0x1b,%ebx
    2bdd:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2be2:	mov    %r14,%rsi
    2be5:	mov    %rsi,%rax
    2be8:	sar    $1,%rax
    2beb:	cmp    $0x2c,%rax
    2bef:	jl     2c13 <botlish_fn_13+0x23db>
    2bf5:	cmp    $0x2d,%rax
    2bf9:	jl     2c09 <botlish_fn_13+0x23d1>
    2bff:	mov    $0x31,%ebx
    2c04:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2c09:	mov    $0x1b,%ebx
    2c0e:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2c13:	cmp    $0x21,%rax
    2c17:	jl     2c27 <botlish_fn_13+0x23ef>
    2c1d:	mov    $0x31,%ebx
    2c22:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2c27:	mov    $0x1b,%ebx
    2c2c:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2c31:	mov    %r14,%rsi
    2c34:	test   $0x1,%rsi
    2c3b:	jne    2c6b <botlish_fn_13+0x2433>
    2c41:	mov    $0x13,%edx
    2c46:	mov    %r14,%rsi
    2c49:	mov    0x280(%rsp),%rdi
    2c51:	call   2c56 <botlish_fn_13+0x241e>
			2c52: R_X86_64_PLT32	rt_int_cmp-0x4
    2c56:	mov    $0x2,%ecx
    2c5b:	test   %rax,%rax
    2c5e:	cmovl  0x423a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2c66:	jmp    2c7f <botlish_fn_13+0x2447>
    2c6b:	mov    $0x2,%ecx
    2c70:	mov    %r14,%rsi
    2c73:	cmp    $0x13,%rsi
    2c77:	cmovl  0x4221(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2c7f:	cmp    $0x6,%rcx
    2c83:	je     2cd8 <botlish_fn_13+0x24a0>
    2c89:	mov    %r14,%rsi
    2c8c:	mov    %rsi,%rax
    2c8f:	sar    $1,%rax
    2c92:	cmp    $0xd,%rax
    2c96:	jl     2cba <botlish_fn_13+0x2482>
    2c9c:	cmp    $0xe,%rax
    2ca0:	jl     2cb0 <botlish_fn_13+0x2478>
    2ca6:	mov    $0x31,%ebx
    2cab:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2cb0:	mov    $0x1b,%ebx
    2cb5:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2cba:	cmp    $0xb,%rax
    2cbe:	jl     2cce <botlish_fn_13+0x2496>
    2cc4:	mov    $0x31,%ebx
    2cc9:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2cce:	mov    $0x1b,%ebx
    2cd3:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2cd8:	mov    %r14,%rsi
    2cdb:	test   $0x1,%rsi
    2ce2:	jne    2d15 <botlish_fn_13+0x24dd>
    2ce8:	mov    0x300(%rsp),%rdx
    2cf0:	mov    %r14,%rsi
    2cf3:	mov    0x280(%rsp),%rdi
    2cfb:	call   2d00 <botlish_fn_13+0x24c8>
			2cfc: R_X86_64_PLT32	rt_int_cmp-0x4
    2d00:	mov    $0x2,%ecx
    2d05:	test   %rax,%rax
    2d08:	cmovl  0x4190(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2d10:	jmp    2d29 <botlish_fn_13+0x24f1>
    2d15:	mov    $0x2,%ecx
    2d1a:	mov    %r14,%rsi
    2d1d:	cmp    $0xffffffffffffffff,%rsi
    2d21:	cmovl  0x4177(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2d29:	cmp    $0x6,%rcx
    2d2d:	je     2d59 <botlish_fn_13+0x2521>
    2d33:	mov    %r14,%rsi
    2d36:	mov    %rsi,%rax
    2d39:	sar    $1,%rax
    2d3c:	test   %rax,%rax
    2d3f:	jl     2d4f <botlish_fn_13+0x2517>
    2d45:	mov    $0x31,%ebx
    2d4a:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2d4f:	mov    $0x1b,%ebx
    2d54:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2d59:	mov    $0x31,%ebx
    2d5e:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2d63:	mov    %rsi,%r14
    2d66:	test   $0x1,%rsi
    2d6d:	jne    2d9d <botlish_fn_13+0x2565>
    2d73:	mov    $0xd9,%edx
    2d78:	mov    %r14,%rsi
    2d7b:	mov    0x280(%rsp),%rdi
    2d83:	call   2d88 <botlish_fn_13+0x2550>
			2d84: R_X86_64_PLT32	rt_int_cmp-0x4
    2d88:	mov    $0x2,%ecx
    2d8d:	test   %rax,%rax
    2d90:	cmovl  0x4108(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2d98:	jmp    2db4 <botlish_fn_13+0x257c>
    2d9d:	mov    $0x2,%ecx
    2da2:	mov    %r14,%rsi
    2da5:	cmp    $0xd9,%rsi
    2dac:	cmovl  0x40ec(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2db4:	cmp    $0x6,%rcx
    2db8:	je     2e2d <botlish_fn_13+0x25f5>
    2dbe:	mov    %r14,%rsi
    2dc1:	test   $0x1,%rsi
    2dc8:	jne    2df8 <botlish_fn_13+0x25c0>
    2dce:	mov    $0xdb,%edx
    2dd3:	mov    %r14,%rsi
    2dd6:	mov    0x280(%rsp),%rdi
    2dde:	call   2de3 <botlish_fn_13+0x25ab>
			2ddf: R_X86_64_PLT32	rt_int_cmp-0x4
    2de3:	mov    $0x2,%ecx
    2de8:	test   %rax,%rax
    2deb:	cmovl  0x40ad(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2df3:	jmp    2e0f <botlish_fn_13+0x25d7>
    2df8:	mov    $0x2,%ecx
    2dfd:	mov    %r14,%rsi
    2e00:	cmp    $0xdb,%rsi
    2e07:	cmovl  0x4091(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2e0f:	cmp    $0x6,%rcx
    2e13:	je     2e23 <botlish_fn_13+0x25eb>
    2e19:	mov    $0x2f,%ebx
    2e1e:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2e23:	mov    $0x15,%ebx
    2e28:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2e2d:	mov    $0x2f,%ebx
    2e32:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2e37:	mov    %rsi,%r14
    2e3a:	cmp    $0x7,%rbx
    2e3e:	jl     2ff5 <botlish_fn_13+0x27bd>
    2e44:	cmp    $0x8,%rbx
    2e48:	jl     2f22 <botlish_fn_13+0x26ea>
    2e4e:	mov    %r14,%rsi
    2e51:	test   $0x1,%rsi
    2e58:	jne    2e88 <botlish_fn_13+0x2650>
    2e5e:	mov    $0xe7,%edx
    2e63:	mov    %r14,%rsi
    2e66:	mov    0x280(%rsp),%rdi
    2e6e:	call   2e73 <botlish_fn_13+0x263b>
			2e6f: R_X86_64_PLT32	rt_int_cmp-0x4
    2e73:	mov    $0x2,%ecx
    2e78:	test   %rax,%rax
    2e7b:	cmovl  0x401d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2e83:	jmp    2e9f <botlish_fn_13+0x2667>
    2e88:	mov    $0x2,%ecx
    2e8d:	mov    %r14,%rsi
    2e90:	cmp    $0xe7,%rsi
    2e97:	cmovl  0x4001(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2e9f:	cmp    $0x6,%rcx
    2ea3:	je     2f18 <botlish_fn_13+0x26e0>
    2ea9:	mov    %r14,%rsi
    2eac:	test   $0x1,%rsi
    2eb3:	jne    2ee3 <botlish_fn_13+0x26ab>
    2eb9:	mov    $0xe9,%edx
    2ebe:	mov    %r14,%rsi
    2ec1:	mov    0x280(%rsp),%rdi
    2ec9:	call   2ece <botlish_fn_13+0x2696>
			2eca: R_X86_64_PLT32	rt_int_cmp-0x4
    2ece:	mov    $0x2,%ecx
    2ed3:	test   %rax,%rax
    2ed6:	cmovl  0x3fc2(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2ede:	jmp    2efa <botlish_fn_13+0x26c2>
    2ee3:	mov    $0x2,%ecx
    2ee8:	mov    %r14,%rsi
    2eeb:	cmp    $0xe9,%rsi
    2ef2:	cmovl  0x3fa6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2efa:	cmp    $0x6,%rcx
    2efe:	je     2f0e <botlish_fn_13+0x26d6>
    2f04:	mov    $0x2d,%ebx
    2f09:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2f0e:	mov    $0x17,%ebx
    2f13:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2f18:	mov    $0x2d,%ebx
    2f1d:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2f22:	mov    %r14,%rsi
    2f25:	test   $0x1,%rsi
    2f2c:	jne    2f5c <botlish_fn_13+0x2724>
    2f32:	mov    $0xcb,%edx
    2f37:	mov    %r14,%rsi
    2f3a:	mov    0x280(%rsp),%rdi
    2f42:	call   2f47 <botlish_fn_13+0x270f>
			2f43: R_X86_64_PLT32	rt_int_cmp-0x4
    2f47:	mov    $0x2,%ecx
    2f4c:	test   %rax,%rax
    2f4f:	cmovl  0x3f49(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2f57:	jmp    2f73 <botlish_fn_13+0x273b>
    2f5c:	mov    $0x2,%ecx
    2f61:	mov    %r14,%rsi
    2f64:	cmp    $0xcb,%rsi
    2f6b:	cmovl  0x3f2d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    2f73:	cmp    $0x6,%rcx
    2f77:	je     2feb <botlish_fn_13+0x27b3>
    2f7d:	mov    %r14,%rsi
    2f80:	test   $0x1,%rsi
    2f87:	jne    2fb7 <botlish_fn_13+0x277f>
    2f8d:	mov    $0xcd,%edx
    2f92:	mov    %r14,%rsi
    2f95:	mov    0x280(%rsp),%rdi
    2f9d:	call   2fa2 <botlish_fn_13+0x276a>
			2f9e: R_X86_64_PLT32	rt_int_cmp-0x4
    2fa2:	mov    $0x2,%esi
    2fa7:	test   %rax,%rax
    2faa:	cmovl  0x3eee(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    2fb2:	jmp    2fcd <botlish_fn_13+0x2795>
    2fb7:	mov    $0x2,%esi
    2fbc:	mov    %r14,%rax
    2fbf:	cmp    $0xcd,%rax
    2fc5:	cmovl  0x3ed3(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    2fcd:	cmp    $0x6,%rsi
    2fd1:	je     2fe1 <botlish_fn_13+0x27a9>
    2fd7:	mov    $0x2b,%ebx
    2fdc:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2fe1:	mov    $0x15,%ebx
    2fe6:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2feb:	mov    $0x2b,%ebx
    2ff0:	jmp    36f9 <botlish_fn_13+0x2ec1>
    2ff5:	mov    %r14,%rsi
    2ff8:	test   $0x1,%rsi
    2fff:	jne    302f <botlish_fn_13+0x27f7>
    3005:	mov    $0xd9,%edx
    300a:	mov    %r14,%rsi
    300d:	mov    0x280(%rsp),%rdi
    3015:	call   301a <botlish_fn_13+0x27e2>
			3016: R_X86_64_PLT32	rt_int_cmp-0x4
    301a:	mov    $0x2,%ecx
    301f:	test   %rax,%rax
    3022:	cmovl  0x3e76(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    302a:	jmp    3046 <botlish_fn_13+0x280e>
    302f:	mov    $0x2,%ecx
    3034:	mov    %r14,%rsi
    3037:	cmp    $0xd9,%rsi
    303e:	cmovl  0x3e5a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3046:	cmp    $0x6,%rcx
    304a:	je     30bf <botlish_fn_13+0x2887>
    3050:	mov    %r14,%rsi
    3053:	test   $0x1,%rsi
    305a:	jne    308a <botlish_fn_13+0x2852>
    3060:	mov    $0xdb,%edx
    3065:	mov    %r14,%rsi
    3068:	mov    0x280(%rsp),%rdi
    3070:	call   3075 <botlish_fn_13+0x283d>
			3071: R_X86_64_PLT32	rt_int_cmp-0x4
    3075:	mov    $0x2,%ecx
    307a:	test   %rax,%rax
    307d:	cmovl  0x3e1b(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3085:	jmp    30a1 <botlish_fn_13+0x2869>
    308a:	mov    $0x2,%ecx
    308f:	mov    %r14,%rsi
    3092:	cmp    $0xdb,%rsi
    3099:	cmovl  0x3dff(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    30a1:	cmp    $0x6,%rcx
    30a5:	je     30b5 <botlish_fn_13+0x287d>
    30ab:	mov    $0x29,%ebx
    30b0:	jmp    36f9 <botlish_fn_13+0x2ec1>
    30b5:	mov    $0x13,%ebx
    30ba:	jmp    36f9 <botlish_fn_13+0x2ec1>
    30bf:	mov    $0x29,%ebx
    30c4:	jmp    36f9 <botlish_fn_13+0x2ec1>
    30c9:	mov    %rsi,%r14
    30cc:	cmp    $0x3,%rbx
    30d0:	jl     3368 <botlish_fn_13+0x2b30>
    30d6:	cmp    $0x4,%rbx
    30da:	jl     3294 <botlish_fn_13+0x2a5c>
    30e0:	cmp    $0x5,%rbx
    30e4:	jl     31c0 <botlish_fn_13+0x2988>
    30ea:	mov    %r14,%rsi
    30ed:	test   $0x1,%rsi
    30f4:	jne    3124 <botlish_fn_13+0x28ec>
    30fa:	mov    $0xd9,%edx
    30ff:	mov    %r14,%rsi
    3102:	mov    0x280(%rsp),%rdi
    310a:	call   310f <botlish_fn_13+0x28d7>
			310b: R_X86_64_PLT32	rt_int_cmp-0x4
    310f:	mov    $0x2,%ecx
    3114:	test   %rax,%rax
    3117:	cmovl  0x3d81(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    311f:	jmp    313b <botlish_fn_13+0x2903>
    3124:	mov    $0x2,%ecx
    3129:	mov    %r14,%rsi
    312c:	cmp    $0xd9,%rsi
    3133:	cmovl  0x3d65(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    313b:	cmp    $0x6,%rcx
    313f:	je     31b6 <botlish_fn_13+0x297e>
    3145:	mov    %r14,%rsi
    3148:	test   $0x1,%rsi
    314f:	jne    3180 <botlish_fn_13+0x2948>
    3155:	mov    $0xdb,%edx
    315a:	mov    %r14,%rsi
    315d:	mov    0x280(%rsp),%rdi
    3165:	call   316a <botlish_fn_13+0x2932>
			3166: R_X86_64_PLT32	rt_int_cmp-0x4
    316a:	mov    $0x2,%r10d
    3170:	test   %rax,%rax
    3173:	cmovl  0x3d25(%rip),%r10        # 6ea0 <botlish_fn_13+0x6668>
    317b:	jmp    3198 <botlish_fn_13+0x2960>
    3180:	mov    $0x2,%r10d
    3186:	mov    %r14,%rsi
    3189:	cmp    $0xdb,%rsi
    3190:	cmovl  0x3d08(%rip),%r10        # 6ea0 <botlish_fn_13+0x6668>
    3198:	cmp    $0x6,%r10
    319c:	je     31ac <botlish_fn_13+0x2974>
    31a2:	mov    $0x27,%ebx
    31a7:	jmp    36f9 <botlish_fn_13+0x2ec1>
    31ac:	mov    $0x11,%ebx
    31b1:	jmp    36f9 <botlish_fn_13+0x2ec1>
    31b6:	mov    $0x27,%ebx
    31bb:	jmp    36f9 <botlish_fn_13+0x2ec1>
    31c0:	mov    %r14,%rsi
    31c3:	test   $0x1,%rsi
    31ca:	jne    31fa <botlish_fn_13+0x29c2>
    31d0:	mov    $0xeb,%edx
    31d5:	mov    %r14,%rsi
    31d8:	mov    0x280(%rsp),%rdi
    31e0:	call   31e5 <botlish_fn_13+0x29ad>
			31e1: R_X86_64_PLT32	rt_int_cmp-0x4
    31e5:	mov    $0x2,%ecx
    31ea:	test   %rax,%rax
    31ed:	cmovl  0x3cab(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    31f5:	jmp    3211 <botlish_fn_13+0x29d9>
    31fa:	mov    $0x2,%ecx
    31ff:	mov    %r14,%rsi
    3202:	cmp    $0xeb,%rsi
    3209:	cmovl  0x3c8f(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3211:	cmp    $0x6,%rcx
    3215:	je     328a <botlish_fn_13+0x2a52>
    321b:	mov    %r14,%rsi
    321e:	test   $0x1,%rsi
    3225:	jne    3255 <botlish_fn_13+0x2a1d>
    322b:	mov    $0xed,%edx
    3230:	mov    %r14,%rsi
    3233:	mov    0x280(%rsp),%rdi
    323b:	call   3240 <botlish_fn_13+0x2a08>
			323c: R_X86_64_PLT32	rt_int_cmp-0x4
    3240:	mov    $0x2,%ecx
    3245:	test   %rax,%rax
    3248:	cmovl  0x3c50(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3250:	jmp    326c <botlish_fn_13+0x2a34>
    3255:	mov    $0x2,%ecx
    325a:	mov    %r14,%rsi
    325d:	cmp    $0xed,%rsi
    3264:	cmovl  0x3c34(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    326c:	cmp    $0x6,%rcx
    3270:	je     3280 <botlish_fn_13+0x2a48>
    3276:	mov    $0x25,%ebx
    327b:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3280:	mov    $0xf,%ebx
    3285:	jmp    36f9 <botlish_fn_13+0x2ec1>
    328a:	mov    $0x25,%ebx
    328f:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3294:	mov    %r14,%rsi
    3297:	test   $0x1,%rsi
    329e:	jne    32ce <botlish_fn_13+0x2a96>
    32a4:	mov    $0xeb,%edx
    32a9:	mov    %r14,%rsi
    32ac:	mov    0x280(%rsp),%rdi
    32b4:	call   32b9 <botlish_fn_13+0x2a81>
			32b5: R_X86_64_PLT32	rt_int_cmp-0x4
    32b9:	mov    $0x2,%ecx
    32be:	test   %rax,%rax
    32c1:	cmovl  0x3bd7(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    32c9:	jmp    32e5 <botlish_fn_13+0x2aad>
    32ce:	mov    $0x2,%ecx
    32d3:	mov    %r14,%rsi
    32d6:	cmp    $0xeb,%rsi
    32dd:	cmovl  0x3bbb(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    32e5:	cmp    $0x6,%rcx
    32e9:	je     335e <botlish_fn_13+0x2b26>
    32ef:	mov    %r14,%rsi
    32f2:	test   $0x1,%rsi
    32f9:	jne    3329 <botlish_fn_13+0x2af1>
    32ff:	mov    $0xed,%edx
    3304:	mov    %r14,%rsi
    3307:	mov    0x280(%rsp),%rdi
    330f:	call   3314 <botlish_fn_13+0x2adc>
			3310: R_X86_64_PLT32	rt_int_cmp-0x4
    3314:	mov    $0x2,%ecx
    3319:	test   %rax,%rax
    331c:	cmovl  0x3b7c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3324:	jmp    3340 <botlish_fn_13+0x2b08>
    3329:	mov    $0x2,%ecx
    332e:	mov    %r14,%rsi
    3331:	cmp    $0xed,%rsi
    3338:	cmovl  0x3b60(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3340:	cmp    $0x6,%rcx
    3344:	je     3354 <botlish_fn_13+0x2b1c>
    334a:	mov    $0x23,%ebx
    334f:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3354:	mov    $0xd,%ebx
    3359:	jmp    36f9 <botlish_fn_13+0x2ec1>
    335e:	mov    $0x23,%ebx
    3363:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3368:	test   %rbx,%rbx
    336b:	jle    3523 <botlish_fn_13+0x2ceb>
    3371:	cmp    $0x2,%rbx
    3375:	jl     344f <botlish_fn_13+0x2c17>
    337b:	mov    %r14,%rsi
    337e:	test   $0x1,%rsi
    3385:	jne    33b5 <botlish_fn_13+0x2b7d>
    338b:	mov    $0xc3,%edx
    3390:	mov    %r14,%rsi
    3393:	mov    0x280(%rsp),%rdi
    339b:	call   33a0 <botlish_fn_13+0x2b68>
			339c: R_X86_64_PLT32	rt_int_cmp-0x4
    33a0:	mov    $0x2,%ecx
    33a5:	test   %rax,%rax
    33a8:	cmovl  0x3af0(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    33b0:	jmp    33cc <botlish_fn_13+0x2b94>
    33b5:	mov    $0x2,%ecx
    33ba:	mov    %r14,%rsi
    33bd:	cmp    $0xc3,%rsi
    33c4:	cmovl  0x3ad4(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    33cc:	cmp    $0x6,%rcx
    33d0:	je     3445 <botlish_fn_13+0x2c0d>
    33d6:	mov    %r14,%rsi
    33d9:	test   $0x1,%rsi
    33e0:	jne    3410 <botlish_fn_13+0x2bd8>
    33e6:	mov    $0xc5,%edx
    33eb:	mov    %r14,%rsi
    33ee:	mov    0x280(%rsp),%rdi
    33f6:	call   33fb <botlish_fn_13+0x2bc3>
			33f7: R_X86_64_PLT32	rt_int_cmp-0x4
    33fb:	mov    $0x2,%ecx
    3400:	test   %rax,%rax
    3403:	cmovl  0x3a95(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    340b:	jmp    3427 <botlish_fn_13+0x2bef>
    3410:	mov    $0x2,%ecx
    3415:	mov    %r14,%rsi
    3418:	cmp    $0xc5,%rsi
    341f:	cmovl  0x3a79(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3427:	cmp    $0x6,%rcx
    342b:	je     343b <botlish_fn_13+0x2c03>
    3431:	mov    $0x21,%ebx
    3436:	jmp    36f9 <botlish_fn_13+0x2ec1>
    343b:	mov    $0xb,%ebx
    3440:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3445:	mov    $0x21,%ebx
    344a:	jmp    36f9 <botlish_fn_13+0x2ec1>
    344f:	mov    %r14,%rsi
    3452:	test   $0x1,%rsi
    3459:	jne    3489 <botlish_fn_13+0x2c51>
    345f:	mov    $0xe5,%edx
    3464:	mov    %r14,%rsi
    3467:	mov    0x280(%rsp),%rdi
    346f:	call   3474 <botlish_fn_13+0x2c3c>
			3470: R_X86_64_PLT32	rt_int_cmp-0x4
    3474:	mov    $0x2,%ecx
    3479:	test   %rax,%rax
    347c:	cmovl  0x3a1c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3484:	jmp    34a0 <botlish_fn_13+0x2c68>
    3489:	mov    $0x2,%ecx
    348e:	mov    %r14,%rsi
    3491:	cmp    $0xe5,%rsi
    3498:	cmovl  0x3a00(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    34a0:	cmp    $0x6,%rcx
    34a4:	je     3519 <botlish_fn_13+0x2ce1>
    34aa:	mov    %r14,%rsi
    34ad:	test   $0x1,%rsi
    34b4:	jne    34e4 <botlish_fn_13+0x2cac>
    34ba:	mov    $0xe7,%edx
    34bf:	mov    %r14,%rsi
    34c2:	mov    0x280(%rsp),%rdi
    34ca:	call   34cf <botlish_fn_13+0x2c97>
			34cb: R_X86_64_PLT32	rt_int_cmp-0x4
    34cf:	mov    $0x2,%ecx
    34d4:	test   %rax,%rax
    34d7:	cmovl  0x39c1(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    34df:	jmp    34fb <botlish_fn_13+0x2cc3>
    34e4:	mov    $0x2,%ecx
    34e9:	mov    %r14,%rsi
    34ec:	cmp    $0xe7,%rsi
    34f3:	cmovl  0x39a5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    34fb:	cmp    $0x6,%rcx
    34ff:	je     350f <botlish_fn_13+0x2cd7>
    3505:	mov    $0x1f,%ebx
    350a:	jmp    36f9 <botlish_fn_13+0x2ec1>
    350f:	mov    $0x9,%ebx
    3514:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3519:	mov    $0x1f,%ebx
    351e:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3523:	mov    %r14,%rsi
    3526:	test   $0x1,%rsi
    352d:	jne    355d <botlish_fn_13+0x2d25>
    3533:	mov    $0xdd,%edx
    3538:	mov    %r14,%rsi
    353b:	mov    0x280(%rsp),%rdi
    3543:	call   3548 <botlish_fn_13+0x2d10>
			3544: R_X86_64_PLT32	rt_int_cmp-0x4
    3548:	mov    $0x2,%ecx
    354d:	test   %rax,%rax
    3550:	cmovl  0x3948(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3558:	jmp    3574 <botlish_fn_13+0x2d3c>
    355d:	mov    $0x2,%ecx
    3562:	mov    %r14,%rsi
    3565:	cmp    $0xdd,%rsi
    356c:	cmovl  0x392c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3574:	cmp    $0x6,%rcx
    3578:	je     3672 <botlish_fn_13+0x2e3a>
    357e:	mov    %r14,%rsi
    3581:	test   $0x1,%rsi
    3588:	jne    35b8 <botlish_fn_13+0x2d80>
    358e:	mov    $0xe9,%edx
    3593:	mov    %r14,%rsi
    3596:	mov    0x280(%rsp),%rdi
    359e:	call   35a3 <botlish_fn_13+0x2d6b>
			359f: R_X86_64_PLT32	rt_int_cmp-0x4
    35a3:	mov    $0x2,%ecx
    35a8:	test   %rax,%rax
    35ab:	cmovl  0x38ed(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    35b3:	jmp    35cf <botlish_fn_13+0x2d97>
    35b8:	mov    $0x2,%ecx
    35bd:	mov    %r14,%rsi
    35c0:	cmp    $0xe9,%rsi
    35c7:	cmovl  0x38d1(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    35cf:	cmp    $0x6,%rcx
    35d3:	je     364b <botlish_fn_13+0x2e13>
    35d9:	mov    %r14,%rsi
    35dc:	test   $0x1,%rsi
    35e3:	jne    3613 <botlish_fn_13+0x2ddb>
    35e9:	mov    $0xeb,%edx
    35ee:	mov    %r14,%rsi
    35f1:	mov    0x280(%rsp),%rdi
    35f9:	call   35fe <botlish_fn_13+0x2dc6>
			35fa: R_X86_64_PLT32	rt_int_cmp-0x4
    35fe:	mov    $0x2,%ecx
    3603:	test   %rax,%rax
    3606:	cmovl  0x3892(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    360e:	jmp    362a <botlish_fn_13+0x2df2>
    3613:	mov    $0x2,%ecx
    3618:	mov    %r14,%rsi
    361b:	cmp    $0xeb,%rsi
    3622:	cmovl  0x3876(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    362a:	cmp    $0x6,%rcx
    362e:	je     363e <botlish_fn_13+0x2e06>
    3634:	mov    $0x1d,%ebx
    3639:	jmp    36f9 <botlish_fn_13+0x2ec1>
    363e:	mov    0x328(%rsp),%rbx
    3646:	jmp    36f9 <botlish_fn_13+0x2ec1>
    364b:	mov    %r14,%rsi
    364e:	mov    %rsi,%rax
    3651:	sar    $1,%rax
    3654:	cmp    $0x6f,%rax
    3658:	jl     3668 <botlish_fn_13+0x2e30>
    365e:	mov    $0x1d,%ebx
    3663:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3668:	mov    $0x7,%ebx
    366d:	jmp    36f9 <botlish_fn_13+0x2ec1>
    3672:	mov    %r14,%rsi
    3675:	test   $0x1,%rsi
    367c:	jne    36ac <botlish_fn_13+0x2e74>
    3682:	mov    $0xcd,%edx
    3687:	mov    %r14,%rsi
    368a:	mov    0x280(%rsp),%rdi
    3692:	call   3697 <botlish_fn_13+0x2e5f>
			3693: R_X86_64_PLT32	rt_int_cmp-0x4
    3697:	mov    $0x2,%ecx
    369c:	test   %rax,%rax
    369f:	cmovl  0x37f9(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    36a7:	jmp    36c3 <botlish_fn_13+0x2e8b>
    36ac:	mov    $0x2,%ecx
    36b1:	mov    %r14,%rsi
    36b4:	cmp    $0xcd,%rsi
    36bb:	cmovl  0x37dd(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    36c3:	cmp    $0x6,%rcx
    36c7:	je     36f4 <botlish_fn_13+0x2ebc>
    36cd:	mov    %r14,%rsi
    36d0:	mov    %rsi,%rax
    36d3:	sar    $1,%rax
    36d6:	cmp    $0x67,%rax
    36da:	jl     36ea <botlish_fn_13+0x2eb2>
    36e0:	mov    $0x1d,%ebx
    36e5:	jmp    36f9 <botlish_fn_13+0x2ec1>
    36ea:	mov    $0x5,%ebx
    36ef:	jmp    36f9 <botlish_fn_13+0x2ec1>
    36f4:	mov    $0x1d,%ebx
    36f9:	mov    %rbx,%rsi
    36fc:	sar    $1,%rsi
    36ff:	cmp    $0xc,%rsi
    3703:	jl     3827 <botlish_fn_13+0x2fef>
    3709:	cmp    $0xd,%rsi
    370d:	mov    %rsi,%rbx
    3710:	je     381c <botlish_fn_13+0x2fe4>
    3716:	mov    %r14,%rsi
    3719:	test   $0x1,%rsi
    3720:	jne    3753 <botlish_fn_13+0x2f1b>
    3726:	mov    0x300(%rsp),%rdx
    372e:	mov    %r14,%rsi
    3731:	mov    0x280(%rsp),%rdi
    3739:	call   373e <botlish_fn_13+0x2f06>
			373a: R_X86_64_PLT32	rt_int_cmp-0x4
    373e:	mov    $0x2,%edi
    3743:	test   %rax,%rax
    3746:	cmove  0x3752(%rip),%rdi        # 6ea0 <botlish_fn_13+0x6668>
    374e:	jmp    3767 <botlish_fn_13+0x2f2f>
    3753:	mov    $0x2,%edi
    3758:	mov    %r14,%rsi
    375b:	cmp    $0xffffffffffffffff,%rsi
    375f:	cmove  0x3739(%rip),%rdi        # 6ea0 <botlish_fn_13+0x6668>
    3767:	cmp    $0x6,%rdi
    376b:	je     37d1 <botlish_fn_13+0x2f99>
    3771:	mov    %rbx,%rsi
    3774:	mov    0x280(%rsp),%rdi
    377c:	call   3781 <botlish_fn_13+0x2f49>
			377d: R_X86_64_PLT32	botlish_fn_3-0x4
    3781:	mov    0x280(%rsp),%rdi
    3789:	mov    0x10(%rdi),%rdi
    378d:	mov    0x158(%rdi),%rdx
    3794:	lea    0x258(%rsp),%r9
    379c:	mov    %rax,0x258(%rsp)
    37a4:	mov    %r14,%rsi
    37a7:	mov    %rsi,0x260(%rsp)
    37af:	mov    $0x1,%esi
    37b4:	mov    $0x5,%ecx
    37b9:	mov    $0x2,%r8d
    37bf:	mov    0x280(%rsp),%rdi
    37c7:	call   37cc <botlish_fn_13+0x2f94>
			37c8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    37cc:	jmp    647b <botlish_fn_13+0x5c43>
    37d1:	mov    %rbx,%rsi
    37d4:	mov    0x280(%rsp),%rdi
    37dc:	call   37e1 <botlish_fn_13+0x2fa9>
			37dd: R_X86_64_PLT32	botlish_fn_3-0x4
    37e1:	mov    0x280(%rsp),%rdi
    37e9:	mov    0x10(%rdi),%r10
    37ed:	mov    0x150(%r10),%rdx
    37f4:	lea    0x250(%rsp),%r9
    37fc:	mov    %rax,0x250(%rsp)
    3804:	mov    $0x2,%ecx
    3809:	mov    $0x1,%r8d
    380f:	mov    %rcx,%rsi
    3812:	call   3817 <botlish_fn_13+0x2fdf>
			3813: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3817:	jmp    647b <botlish_fn_13+0x5c43>
    381c:	mov    %r12,%rbx
    381f:	mov    %r13,%r12
    3822:	jmp    5148 <botlish_fn_13+0x4910>
    3827:	mov    %rbx,0xa8(%rsp)
    382f:	mov    $0x6,%r12d
    3835:	movq   $0x6,0x80(%rsp)
    3841:	mov    0x2f8(%rsp),%r14
    3849:	mov    0x298(%rsp),%r15
    3851:	jmp    6626 <botlish_fn_13+0x5dee>
    3856:	mov    %rsi,%r14
    3859:	mov    %r13,%r12
    385c:	sar    $1,%r13
    385f:	cmp    $0x4,%r13
    3863:	jl     4457 <botlish_fn_13+0x3c1f>
    3869:	cmp    $0x6,%r13
    386d:	jl     41a9 <botlish_fn_13+0x3971>
    3873:	cmp    $0x7,%r13
    3877:	jl     3d55 <botlish_fn_13+0x351d>
    387d:	cmp    $0x8,%r13
    3881:	jl     3c84 <botlish_fn_13+0x344c>
    3887:	mov    %r14,%rsi
    388a:	test   $0x1,%rsi
    3891:	jne    38c1 <botlish_fn_13+0x3089>
    3897:	mov    $0x43,%edx
    389c:	mov    %r14,%rsi
    389f:	mov    0x280(%rsp),%rdi
    38a7:	call   38ac <botlish_fn_13+0x3074>
			38a8: R_X86_64_PLT32	rt_int_cmp-0x4
    38ac:	mov    $0x2,%edx
    38b1:	test   %rax,%rax
    38b4:	cmovl  0x35e4(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    38bc:	jmp    38d5 <botlish_fn_13+0x309d>
    38c1:	mov    $0x2,%edx
    38c6:	mov    %r14,%rsi
    38c9:	cmp    $0x43,%rsi
    38cd:	cmovl  0x35cb(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    38d5:	cmp    $0x6,%rdx
    38d9:	je     3ae5 <botlish_fn_13+0x32ad>
    38df:	mov    %r14,%rsi
    38e2:	test   $0x1,%rsi
    38e9:	jne    3919 <botlish_fn_13+0x30e1>
    38ef:	mov    $0x75,%edx
    38f4:	mov    %r14,%rsi
    38f7:	mov    0x280(%rsp),%rdi
    38ff:	call   3904 <botlish_fn_13+0x30cc>
			3900: R_X86_64_PLT32	rt_int_cmp-0x4
    3904:	mov    $0x2,%ecx
    3909:	test   %rax,%rax
    390c:	cmovl  0x358c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3914:	jmp    392d <botlish_fn_13+0x30f5>
    3919:	mov    $0x2,%ecx
    391e:	mov    %r14,%rsi
    3921:	cmp    $0x75,%rsi
    3925:	cmovl  0x3573(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    392d:	cmp    $0x6,%rcx
    3931:	je     3a92 <botlish_fn_13+0x325a>
    3937:	mov    %r14,%rsi
    393a:	test   $0x1,%rsi
    3941:	jne    3971 <botlish_fn_13+0x3139>
    3947:	mov    $0xbd,%edx
    394c:	mov    %r14,%rsi
    394f:	mov    0x280(%rsp),%rdi
    3957:	call   395c <botlish_fn_13+0x3124>
			3958: R_X86_64_PLT32	rt_int_cmp-0x4
    395c:	mov    $0x2,%ecx
    3961:	test   %rax,%rax
    3964:	cmovl  0x3534(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    396c:	jmp    3988 <botlish_fn_13+0x3150>
    3971:	mov    $0x2,%ecx
    3976:	mov    %r14,%rsi
    3979:	cmp    $0xbd,%rsi
    3980:	cmovl  0x3518(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3988:	cmp    $0x6,%rcx
    398c:	je     3a69 <botlish_fn_13+0x3231>
    3992:	mov    %r14,%rsi
    3995:	test   $0x1,%rsi
    399c:	jne    39cc <botlish_fn_13+0x3194>
    39a2:	mov    $0xfb,%edx
    39a7:	mov    %r14,%rsi
    39aa:	mov    0x280(%rsp),%rdi
    39b2:	call   39b7 <botlish_fn_13+0x317f>
			39b3: R_X86_64_PLT32	rt_int_cmp-0x4
    39b7:	mov    $0x2,%ecx
    39bc:	test   %rax,%rax
    39bf:	cmovl  0x34d9(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    39c7:	jmp    39e3 <botlish_fn_13+0x31ab>
    39cc:	mov    $0x2,%ecx
    39d1:	mov    %r14,%rsi
    39d4:	cmp    $0xfb,%rsi
    39db:	cmovl  0x34bd(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    39e3:	cmp    $0x6,%rcx
    39e7:	je     3a5e <botlish_fn_13+0x3226>
    39ed:	mov    %r14,%rsi
    39f0:	test   $0x1,%rsi
    39f7:	jne    3a27 <botlish_fn_13+0x31ef>
    39fd:	mov    $0xfd,%edx
    3a02:	mov    %r14,%rsi
    3a05:	mov    0x280(%rsp),%rdi
    3a0d:	call   3a12 <botlish_fn_13+0x31da>
			3a0e: R_X86_64_PLT32	rt_int_cmp-0x4
    3a12:	mov    $0x2,%ecx
    3a17:	test   %rax,%rax
    3a1a:	cmovl  0x347e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3a22:	jmp    3a3e <botlish_fn_13+0x3206>
    3a27:	mov    $0x2,%ecx
    3a2c:	mov    %r14,%rsi
    3a2f:	cmp    $0xfd,%rsi
    3a36:	cmovl  0x3462(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3a3e:	cmp    $0x6,%rcx
    3a42:	je     3a53 <botlish_fn_13+0x321b>
    3a48:	mov    $0x27,%r13d
    3a4e:	jmp    502d <botlish_fn_13+0x47f5>
    3a53:	mov    $0x15,%r13d
    3a59:	jmp    502d <botlish_fn_13+0x47f5>
    3a5e:	mov    $0x27,%r13d
    3a64:	jmp    502d <botlish_fn_13+0x47f5>
    3a69:	mov    %r14,%rsi
    3a6c:	mov    %rsi,%r10
    3a6f:	sar    $1,%r10
    3a72:	cmp    $0x5d,%r10
    3a76:	jl     3a87 <botlish_fn_13+0x324f>
    3a7c:	mov    $0x15,%r13d
    3a82:	jmp    502d <botlish_fn_13+0x47f5>
    3a87:	mov    $0x27,%r13d
    3a8d:	jmp    502d <botlish_fn_13+0x47f5>
    3a92:	mov    %r14,%rsi
    3a95:	mov    %rsi,%rax
    3a98:	sar    $1,%rax
    3a9b:	cmp    $0x2d,%rax
    3a9f:	jl     3ac5 <botlish_fn_13+0x328d>
    3aa5:	cmp    $0x30,%rax
    3aa9:	jl     3aba <botlish_fn_13+0x3282>
    3aaf:	mov    $0x11,%r13d
    3ab5:	jmp    502d <botlish_fn_13+0x47f5>
    3aba:	mov    $0x27,%r13d
    3ac0:	jmp    502d <botlish_fn_13+0x47f5>
    3ac5:	cmp    $0x2c,%rax
    3ac9:	jl     3ada <botlish_fn_13+0x32a2>
    3acf:	mov    $0x15,%r13d
    3ad5:	jmp    502d <botlish_fn_13+0x47f5>
    3ada:	mov    $0x27,%r13d
    3ae0:	jmp    502d <botlish_fn_13+0x47f5>
    3ae5:	mov    %r14,%rsi
    3ae8:	test   $0x1,%rsi
    3aef:	jne    3b1f <botlish_fn_13+0x32e7>
    3af5:	mov    $0x17,%edx
    3afa:	mov    %r14,%rsi
    3afd:	mov    0x280(%rsp),%rdi
    3b05:	call   3b0a <botlish_fn_13+0x32d2>
			3b06: R_X86_64_PLT32	rt_int_cmp-0x4
    3b0a:	mov    $0x2,%ecx
    3b0f:	test   %rax,%rax
    3b12:	cmovl  0x3386(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3b1a:	jmp    3b33 <botlish_fn_13+0x32fb>
    3b1f:	mov    $0x2,%ecx
    3b24:	mov    %r14,%rsi
    3b27:	cmp    $0x17,%rsi
    3b2b:	cmovl  0x336d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3b33:	cmp    $0x6,%rcx
    3b37:	je     3b90 <botlish_fn_13+0x3358>
    3b3d:	mov    %r14,%rsi
    3b40:	mov    %rsi,%rax
    3b43:	sar    $1,%rax
    3b46:	cmp    $0xe,%rax
    3b4a:	jl     3b70 <botlish_fn_13+0x3338>
    3b50:	cmp    $0x20,%rax
    3b54:	jl     3b65 <botlish_fn_13+0x332d>
    3b5a:	mov    $0x15,%r13d
    3b60:	jmp    502d <botlish_fn_13+0x47f5>
    3b65:	mov    $0x27,%r13d
    3b6b:	jmp    502d <botlish_fn_13+0x47f5>
    3b70:	cmp    $0xd,%rax
    3b74:	jl     3b85 <botlish_fn_13+0x334d>
    3b7a:	mov    $0x15,%r13d
    3b80:	jmp    502d <botlish_fn_13+0x47f5>
    3b85:	mov    $0x27,%r13d
    3b8b:	jmp    502d <botlish_fn_13+0x47f5>
    3b90:	mov    %r14,%rsi
    3b93:	test   $0x1,%rsi
    3b9a:	jne    3bca <botlish_fn_13+0x3392>
    3ba0:	mov    $0x1,%edx
    3ba5:	mov    %r14,%rsi
    3ba8:	mov    0x280(%rsp),%rdi
    3bb0:	call   3bb5 <botlish_fn_13+0x337d>
			3bb1: R_X86_64_PLT32	rt_int_cmp-0x4
    3bb5:	mov    $0x2,%ecx
    3bba:	test   %rax,%rax
    3bbd:	cmovl  0x32db(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3bc5:	jmp    3be0 <botlish_fn_13+0x33a8>
    3bca:	mov    $0x2,%ecx
    3bcf:	mov    %r14,%rsi
    3bd2:	mov    %r14,%r8
    3bd5:	test   %r8,%rsi
    3bd8:	cmovle 0x32c0(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3be0:	cmp    $0x6,%rcx
    3be4:	je     3c13 <botlish_fn_13+0x33db>
    3bea:	mov    %r14,%rsi
    3bed:	mov    %rsi,%rax
    3bf0:	sar    $1,%rax
    3bf3:	cmp    $0x9,%rax
    3bf7:	jl     3c08 <botlish_fn_13+0x33d0>
    3bfd:	mov    $0x15,%r13d
    3c03:	jmp    502d <botlish_fn_13+0x47f5>
    3c08:	mov    $0x27,%r13d
    3c0e:	jmp    502d <botlish_fn_13+0x47f5>
    3c13:	mov    %r14,%rsi
    3c16:	test   $0x1,%rsi
    3c1d:	jne    3c50 <botlish_fn_13+0x3418>
    3c23:	mov    0x300(%rsp),%rdx
    3c2b:	mov    %r14,%rsi
    3c2e:	mov    0x280(%rsp),%rdi
    3c36:	call   3c3b <botlish_fn_13+0x3403>
			3c37: R_X86_64_PLT32	rt_int_cmp-0x4
    3c3b:	mov    $0x2,%ecx
    3c40:	test   %rax,%rax
    3c43:	cmovl  0x3255(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3c4b:	jmp    3c64 <botlish_fn_13+0x342c>
    3c50:	mov    $0x2,%ecx
    3c55:	mov    %r14,%rsi
    3c58:	cmp    $0xffffffffffffffff,%rsi
    3c5c:	cmovl  0x323c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3c64:	cmp    $0x6,%rcx
    3c68:	je     3c79 <botlish_fn_13+0x3441>
    3c6e:	mov    $0x15,%r13d
    3c74:	jmp    502d <botlish_fn_13+0x47f5>
    3c79:	mov    $0x27,%r13d
    3c7f:	jmp    502d <botlish_fn_13+0x47f5>
    3c84:	mov    %r14,%rsi
    3c87:	test   $0x1,%rsi
    3c8e:	jne    3cbe <botlish_fn_13+0x3486>
    3c94:	mov    $0x61,%edx
    3c99:	mov    %r14,%rsi
    3c9c:	mov    0x280(%rsp),%rdi
    3ca4:	call   3ca9 <botlish_fn_13+0x3471>
			3ca5: R_X86_64_PLT32	rt_int_cmp-0x4
    3ca9:	mov    $0x2,%ecx
    3cae:	test   %rax,%rax
    3cb1:	cmovl  0x31e7(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3cb9:	jmp    3cd2 <botlish_fn_13+0x349a>
    3cbe:	mov    $0x2,%ecx
    3cc3:	mov    %r14,%rsi
    3cc6:	cmp    $0x61,%rsi
    3cca:	cmovl  0x31ce(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3cd2:	cmp    $0x6,%rcx
    3cd6:	je     3d4a <botlish_fn_13+0x3512>
    3cdc:	mov    %r14,%rsi
    3cdf:	test   $0x1,%rsi
    3ce6:	jne    3d16 <botlish_fn_13+0x34de>
    3cec:	mov    $0x75,%edx
    3cf1:	mov    %r14,%rsi
    3cf4:	mov    0x280(%rsp),%rdi
    3cfc:	call   3d01 <botlish_fn_13+0x34c9>
			3cfd: R_X86_64_PLT32	rt_int_cmp-0x4
    3d01:	mov    $0x2,%esi
    3d06:	test   %rax,%rax
    3d09:	cmovl  0x318f(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    3d11:	jmp    3d2a <botlish_fn_13+0x34f2>
    3d16:	mov    $0x2,%esi
    3d1b:	mov    %r14,%r10
    3d1e:	cmp    $0x75,%r10
    3d22:	cmovl  0x3176(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    3d2a:	cmp    $0x6,%rsi
    3d2e:	je     3d3f <botlish_fn_13+0x3507>
    3d34:	mov    $0x25,%r13d
    3d3a:	jmp    502d <botlish_fn_13+0x47f5>
    3d3f:	mov    $0x11,%r13d
    3d45:	jmp    502d <botlish_fn_13+0x47f5>
    3d4a:	mov    $0x25,%r13d
    3d50:	jmp    502d <botlish_fn_13+0x47f5>
    3d55:	mov    %r14,%rsi
    3d58:	test   $0x1,%rsi
    3d5f:	jne    3d8f <botlish_fn_13+0x3557>
    3d65:	mov    $0x5b,%edx
    3d6a:	mov    %r14,%rsi
    3d6d:	mov    0x280(%rsp),%rdi
    3d75:	call   3d7a <botlish_fn_13+0x3542>
			3d76: R_X86_64_PLT32	rt_int_cmp-0x4
    3d7a:	mov    $0x2,%ecx
    3d7f:	test   %rax,%rax
    3d82:	cmovl  0x3116(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3d8a:	jmp    3da3 <botlish_fn_13+0x356b>
    3d8f:	mov    $0x2,%ecx
    3d94:	mov    %r14,%rsi
    3d97:	cmp    $0x5b,%rsi
    3d9b:	cmovl  0x30fd(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3da3:	cmp    $0x6,%rcx
    3da7:	je     3fe0 <botlish_fn_13+0x37a8>
    3dad:	mov    %r14,%rsi
    3db0:	test   $0x1,%rsi
    3db7:	jne    3de7 <botlish_fn_13+0x35af>
    3dbd:	mov    $0xbb,%edx
    3dc2:	mov    %r14,%rsi
    3dc5:	mov    0x280(%rsp),%rdi
    3dcd:	call   3dd2 <botlish_fn_13+0x359a>
			3dce: R_X86_64_PLT32	rt_int_cmp-0x4
    3dd2:	mov    $0x2,%ecx
    3dd7:	test   %rax,%rax
    3dda:	cmovl  0x30be(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3de2:	jmp    3dfe <botlish_fn_13+0x35c6>
    3de7:	mov    $0x2,%ecx
    3dec:	mov    %r14,%rsi
    3def:	cmp    $0xbb,%rsi
    3df6:	cmovl  0x30a2(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3dfe:	cmp    $0x6,%rcx
    3e02:	je     3f78 <botlish_fn_13+0x3740>
    3e08:	mov    %r14,%rsi
    3e0b:	test   $0x1,%rsi
    3e12:	jne    3e42 <botlish_fn_13+0x360a>
    3e18:	mov    $0xcd,%edx
    3e1d:	mov    %r14,%rsi
    3e20:	mov    0x280(%rsp),%rdi
    3e28:	call   3e2d <botlish_fn_13+0x35f5>
			3e29: R_X86_64_PLT32	rt_int_cmp-0x4
    3e2d:	mov    $0x2,%ecx
    3e32:	test   %rax,%rax
    3e35:	cmovl  0x3063(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3e3d:	jmp    3e59 <botlish_fn_13+0x3621>
    3e42:	mov    $0x2,%ecx
    3e47:	mov    %r14,%rsi
    3e4a:	cmp    $0xcd,%rsi
    3e51:	cmovl  0x3047(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3e59:	cmp    $0x6,%rcx
    3e5d:	je     3f3a <botlish_fn_13+0x3702>
    3e63:	mov    %r14,%rsi
    3e66:	test   $0x1,%rsi
    3e6d:	jne    3e9d <botlish_fn_13+0x3665>
    3e73:	mov    $0xfb,%edx
    3e78:	mov    %r14,%rsi
    3e7b:	mov    0x280(%rsp),%rdi
    3e83:	call   3e88 <botlish_fn_13+0x3650>
			3e84: R_X86_64_PLT32	rt_int_cmp-0x4
    3e88:	mov    $0x2,%ecx
    3e8d:	test   %rax,%rax
    3e90:	cmovl  0x3008(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3e98:	jmp    3eb4 <botlish_fn_13+0x367c>
    3e9d:	mov    $0x2,%ecx
    3ea2:	mov    %r14,%rsi
    3ea5:	cmp    $0xfb,%rsi
    3eac:	cmovl  0x2fec(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3eb4:	cmp    $0x6,%rcx
    3eb8:	je     3f2f <botlish_fn_13+0x36f7>
    3ebe:	mov    %r14,%rsi
    3ec1:	test   $0x1,%rsi
    3ec8:	jne    3ef8 <botlish_fn_13+0x36c0>
    3ece:	mov    $0xfd,%edx
    3ed3:	mov    %r14,%rsi
    3ed6:	mov    0x280(%rsp),%rdi
    3ede:	call   3ee3 <botlish_fn_13+0x36ab>
			3edf: R_X86_64_PLT32	rt_int_cmp-0x4
    3ee3:	mov    $0x2,%ecx
    3ee8:	test   %rax,%rax
    3eeb:	cmovl  0x2fad(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3ef3:	jmp    3f0f <botlish_fn_13+0x36d7>
    3ef8:	mov    $0x2,%ecx
    3efd:	mov    %r14,%rsi
    3f00:	cmp    $0xfd,%rsi
    3f07:	cmovl  0x2f91(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    3f0f:	cmp    $0x6,%rcx
    3f13:	je     3f24 <botlish_fn_13+0x36ec>
    3f19:	mov    $0x23,%r13d
    3f1f:	jmp    502d <botlish_fn_13+0x47f5>
    3f24:	mov    $0x15,%r13d
    3f2a:	jmp    502d <botlish_fn_13+0x47f5>
    3f2f:	mov    $0x23,%r13d
    3f35:	jmp    502d <botlish_fn_13+0x47f5>
    3f3a:	mov    %r14,%rsi
    3f3d:	mov    %rsi,%rax
    3f40:	sar    $1,%rax
    3f43:	cmp    $0x5e,%rax
    3f47:	jl     3f6d <botlish_fn_13+0x3735>
    3f4d:	cmp    $0x65,%rax
    3f51:	jl     3f62 <botlish_fn_13+0x372a>
    3f57:	mov    $0xb,%r13d
    3f5d:	jmp    502d <botlish_fn_13+0x47f5>
    3f62:	mov    $0x23,%r13d
    3f68:	jmp    502d <botlish_fn_13+0x47f5>
    3f6d:	mov    $0x15,%r13d
    3f73:	jmp    502d <botlish_fn_13+0x47f5>
    3f78:	mov    %r14,%rsi
    3f7b:	mov    %rsi,%rax
    3f7e:	sar    $1,%rax
    3f81:	cmp    $0x3a,%rax
    3f85:	jl     3fc0 <botlish_fn_13+0x3788>
    3f8b:	cmp    $0x45,%rax
    3f8f:	jl     3fb5 <botlish_fn_13+0x377d>
    3f95:	cmp    $0x46,%rax
    3f99:	jl     3faa <botlish_fn_13+0x3772>
    3f9f:	mov    $0x23,%r13d
    3fa5:	jmp    502d <botlish_fn_13+0x47f5>
    3faa:	mov    $0xb,%r13d
    3fb0:	jmp    502d <botlish_fn_13+0x47f5>
    3fb5:	mov    $0x23,%r13d
    3fbb:	jmp    502d <botlish_fn_13+0x47f5>
    3fc0:	cmp    $0x30,%rax
    3fc4:	jl     3fd5 <botlish_fn_13+0x379d>
    3fca:	mov    $0xd,%r13d
    3fd0:	jmp    502d <botlish_fn_13+0x47f5>
    3fd5:	mov    $0x23,%r13d
    3fdb:	jmp    502d <botlish_fn_13+0x47f5>
    3fe0:	mov    %r14,%rsi
    3fe3:	test   $0x1,%rsi
    3fea:	jne    401a <botlish_fn_13+0x37e2>
    3ff0:	mov    $0x1b,%edx
    3ff5:	mov    %r14,%rsi
    3ff8:	mov    0x280(%rsp),%rdi
    4000:	call   4005 <botlish_fn_13+0x37cd>
			4001: R_X86_64_PLT32	rt_int_cmp-0x4
    4005:	mov    $0x2,%ecx
    400a:	test   %rax,%rax
    400d:	cmovl  0x2e8b(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4015:	jmp    402e <botlish_fn_13+0x37f6>
    401a:	mov    $0x2,%ecx
    401f:	mov    %r14,%rsi
    4022:	cmp    $0x1b,%rsi
    4026:	cmovl  0x2e72(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    402e:	cmp    $0x6,%rcx
    4032:	je     40a0 <botlish_fn_13+0x3868>
    4038:	mov    %r14,%rsi
    403b:	mov    %rsi,%rax
    403e:	sar    $1,%rax
    4041:	cmp    $0x20,%rax
    4045:	jl     4080 <botlish_fn_13+0x3848>
    404b:	cmp    $0x21,%rax
    404f:	jl     4075 <botlish_fn_13+0x383d>
    4055:	cmp    $0x2c,%rax
    4059:	jl     406a <botlish_fn_13+0x3832>
    405f:	mov    $0x15,%r13d
    4065:	jmp    502d <botlish_fn_13+0x47f5>
    406a:	mov    $0x23,%r13d
    4070:	jmp    502d <botlish_fn_13+0x47f5>
    4075:	mov    $0x15,%r13d
    407b:	jmp    502d <botlish_fn_13+0x47f5>
    4080:	cmp    $0xe,%rax
    4084:	jl     4095 <botlish_fn_13+0x385d>
    408a:	mov    $0x23,%r13d
    4090:	jmp    502d <botlish_fn_13+0x47f5>
    4095:	mov    $0x15,%r13d
    409b:	jmp    502d <botlish_fn_13+0x47f5>
    40a0:	mov    %r14,%rsi
    40a3:	test   $0x1,%rsi
    40aa:	jne    40da <botlish_fn_13+0x38a2>
    40b0:	mov    $0x1,%edx
    40b5:	mov    %r14,%rsi
    40b8:	mov    0x280(%rsp),%rdi
    40c0:	call   40c5 <botlish_fn_13+0x388d>
			40c1: R_X86_64_PLT32	rt_int_cmp-0x4
    40c5:	mov    $0x2,%ecx
    40ca:	test   %rax,%rax
    40cd:	cmovl  0x2dcb(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    40d5:	jmp    40f0 <botlish_fn_13+0x38b8>
    40da:	mov    $0x2,%ecx
    40df:	mov    %r14,%rax
    40e2:	mov    %r14,%rsi
    40e5:	test   %rax,%rsi
    40e8:	cmovle 0x2db0(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    40f0:	cmp    $0x6,%rcx
    40f4:	je     4138 <botlish_fn_13+0x3900>
    40fa:	mov    %r14,%rsi
    40fd:	mov    %rsi,%rax
    4100:	sar    $1,%rax
    4103:	cmp    $0x9,%rax
    4107:	jl     412d <botlish_fn_13+0x38f5>
    410d:	cmp    $0xb,%rax
    4111:	jl     4122 <botlish_fn_13+0x38ea>
    4117:	mov    $0x23,%r13d
    411d:	jmp    502d <botlish_fn_13+0x47f5>
    4122:	mov    $0x15,%r13d
    4128:	jmp    502d <botlish_fn_13+0x47f5>
    412d:	mov    $0x23,%r13d
    4133:	jmp    502d <botlish_fn_13+0x47f5>
    4138:	mov    %r14,%rsi
    413b:	test   $0x1,%rsi
    4142:	jne    4175 <botlish_fn_13+0x393d>
    4148:	mov    0x300(%rsp),%rdx
    4150:	mov    %r14,%rsi
    4153:	mov    0x280(%rsp),%rdi
    415b:	call   4160 <botlish_fn_13+0x3928>
			415c: R_X86_64_PLT32	rt_int_cmp-0x4
    4160:	mov    $0x2,%ecx
    4165:	test   %rax,%rax
    4168:	cmovl  0x2d30(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4170:	jmp    4189 <botlish_fn_13+0x3951>
    4175:	mov    $0x2,%ecx
    417a:	mov    %r14,%rsi
    417d:	cmp    $0xffffffffffffffff,%rsi
    4181:	cmovl  0x2d17(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4189:	cmp    $0x6,%rcx
    418d:	je     419e <botlish_fn_13+0x3966>
    4193:	mov    $0x15,%r13d
    4199:	jmp    502d <botlish_fn_13+0x47f5>
    419e:	mov    $0x23,%r13d
    41a4:	jmp    502d <botlish_fn_13+0x47f5>
    41a9:	cmp    $0x5,%r13
    41ad:	jl     4386 <botlish_fn_13+0x3b4e>
    41b3:	mov    %r14,%rsi
    41b6:	test   $0x1,%rsi
    41bd:	jne    41ed <botlish_fn_13+0x39b5>
    41c3:	mov    $0x5b,%edx
    41c8:	mov    %r14,%rsi
    41cb:	mov    0x280(%rsp),%rdi
    41d3:	call   41d8 <botlish_fn_13+0x39a0>
			41d4: R_X86_64_PLT32	rt_int_cmp-0x4
    41d8:	mov    $0x2,%esi
    41dd:	test   %rax,%rax
    41e0:	cmovl  0x2cb8(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    41e8:	jmp    4201 <botlish_fn_13+0x39c9>
    41ed:	mov    $0x2,%esi
    41f2:	mov    %r14,%r8
    41f5:	cmp    $0x5b,%r8
    41f9:	cmovl  0x2c9f(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    4201:	cmp    $0x6,%rsi
    4205:	je     42fa <botlish_fn_13+0x3ac2>
    420b:	mov    %r14,%rsi
    420e:	test   $0x1,%rsi
    4215:	jne    4245 <botlish_fn_13+0x3a0d>
    421b:	mov    $0x61,%edx
    4220:	mov    %r14,%rsi
    4223:	mov    0x280(%rsp),%rdi
    422b:	call   4230 <botlish_fn_13+0x39f8>
			422c: R_X86_64_PLT32	rt_int_cmp-0x4
    4230:	mov    $0x2,%ecx
    4235:	test   %rax,%rax
    4238:	cmovl  0x2c60(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4240:	jmp    4259 <botlish_fn_13+0x3a21>
    4245:	mov    $0x2,%ecx
    424a:	mov    %r14,%rsi
    424d:	cmp    $0x61,%rsi
    4251:	cmovl  0x2c47(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4259:	cmp    $0x6,%rcx
    425d:	je     42d1 <botlish_fn_13+0x3a99>
    4263:	mov    %r14,%rsi
    4266:	test   $0x1,%rsi
    426d:	jne    429d <botlish_fn_13+0x3a65>
    4273:	mov    $0x75,%edx
    4278:	mov    %r14,%rsi
    427b:	mov    0x280(%rsp),%rdi
    4283:	call   4288 <botlish_fn_13+0x3a50>
			4284: R_X86_64_PLT32	rt_int_cmp-0x4
    4288:	mov    $0x2,%ecx
    428d:	test   %rax,%rax
    4290:	cmovl  0x2c08(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4298:	jmp    42b1 <botlish_fn_13+0x3a79>
    429d:	mov    $0x2,%ecx
    42a2:	mov    %r14,%rsi
    42a5:	cmp    $0x75,%rsi
    42a9:	cmovl  0x2bef(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    42b1:	cmp    $0x6,%rcx
    42b5:	je     42c6 <botlish_fn_13+0x3a8e>
    42bb:	mov    $0x21,%r13d
    42c1:	jmp    502d <botlish_fn_13+0x47f5>
    42c6:	mov    $0x11,%r13d
    42cc:	jmp    502d <botlish_fn_13+0x47f5>
    42d1:	mov    %r14,%rsi
    42d4:	mov    %rsi,%rdi
    42d7:	sar    $1,%rdi
    42da:	cmp    $0x2e,%rdi
    42de:	jl     42ef <botlish_fn_13+0x3ab7>
    42e4:	mov    $0x21,%r13d
    42ea:	jmp    502d <botlish_fn_13+0x47f5>
    42ef:	mov    $0xf,%r13d
    42f5:	jmp    502d <botlish_fn_13+0x47f5>
    42fa:	mov    %r14,%rsi
    42fd:	test   $0x1,%rsi
    4304:	jne    4334 <botlish_fn_13+0x3afc>
    430a:	mov    $0x57,%edx
    430f:	mov    %r14,%rsi
    4312:	mov    0x280(%rsp),%rdi
    431a:	call   431f <botlish_fn_13+0x3ae7>
			431b: R_X86_64_PLT32	rt_int_cmp-0x4
    431f:	mov    $0x2,%ecx
    4324:	test   %rax,%rax
    4327:	cmovl  0x2b71(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    432f:	jmp    4348 <botlish_fn_13+0x3b10>
    4334:	mov    $0x2,%ecx
    4339:	mov    %r14,%rsi
    433c:	cmp    $0x57,%rsi
    4340:	cmovl  0x2b58(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4348:	cmp    $0x6,%rcx
    434c:	je     437b <botlish_fn_13+0x3b43>
    4352:	mov    %r14,%rsi
    4355:	mov    %rsi,%rax
    4358:	sar    $1,%rax
    435b:	cmp    $0x2c,%rax
    435f:	jl     4370 <botlish_fn_13+0x3b38>
    4365:	mov    $0x21,%r13d
    436b:	jmp    502d <botlish_fn_13+0x47f5>
    4370:	mov    $0xf,%r13d
    4376:	jmp    502d <botlish_fn_13+0x47f5>
    437b:	mov    $0x21,%r13d
    4381:	jmp    502d <botlish_fn_13+0x47f5>
    4386:	mov    %r14,%rsi
    4389:	test   $0x1,%rsi
    4390:	jne    43c0 <botlish_fn_13+0x3b88>
    4396:	mov    $0x61,%edx
    439b:	mov    %r14,%rsi
    439e:	mov    0x280(%rsp),%rdi
    43a6:	call   43ab <botlish_fn_13+0x3b73>
			43a7: R_X86_64_PLT32	rt_int_cmp-0x4
    43ab:	mov    $0x2,%ecx
    43b0:	test   %rax,%rax
    43b3:	cmovl  0x2ae5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    43bb:	jmp    43d4 <botlish_fn_13+0x3b9c>
    43c0:	mov    $0x2,%ecx
    43c5:	mov    %r14,%rsi
    43c8:	cmp    $0x61,%rsi
    43cc:	cmovl  0x2acc(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    43d4:	cmp    $0x6,%rcx
    43d8:	je     444c <botlish_fn_13+0x3c14>
    43de:	mov    %r14,%rsi
    43e1:	test   $0x1,%rsi
    43e8:	jne    4418 <botlish_fn_13+0x3be0>
    43ee:	mov    $0x75,%edx
    43f3:	mov    %r14,%rsi
    43f6:	mov    0x280(%rsp),%rdi
    43fe:	call   4403 <botlish_fn_13+0x3bcb>
			43ff: R_X86_64_PLT32	rt_int_cmp-0x4
    4403:	mov    $0x2,%ecx
    4408:	test   %rax,%rax
    440b:	cmovl  0x2a8d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4413:	jmp    442c <botlish_fn_13+0x3bf4>
    4418:	mov    $0x2,%ecx
    441d:	mov    %r14,%rsi
    4420:	cmp    $0x75,%rsi
    4424:	cmovl  0x2a74(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    442c:	cmp    $0x6,%rcx
    4430:	je     4441 <botlish_fn_13+0x3c09>
    4436:	mov    $0x1f,%r13d
    443c:	jmp    502d <botlish_fn_13+0x47f5>
    4441:	mov    $0xd,%r13d
    4447:	jmp    502d <botlish_fn_13+0x47f5>
    444c:	mov    $0x1f,%r13d
    4452:	jmp    502d <botlish_fn_13+0x47f5>
    4457:	cmp    $0x2,%r13
    445b:	jl     4d3c <botlish_fn_13+0x4504>
    4461:	cmp    $0x3,%r13
    4465:	jl     48e9 <botlish_fn_13+0x40b1>
    446b:	mov    %r14,%rsi
    446e:	test   $0x1,%rsi
    4475:	jne    44a5 <botlish_fn_13+0x3c6d>
    447b:	mov    $0x5d,%edx
    4480:	mov    %r14,%rsi
    4483:	mov    0x280(%rsp),%rdi
    448b:	call   4490 <botlish_fn_13+0x3c58>
			448c: R_X86_64_PLT32	rt_int_cmp-0x4
    4490:	mov    $0x2,%ecx
    4495:	test   %rax,%rax
    4498:	cmovl  0x2a00(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    44a0:	jmp    44b9 <botlish_fn_13+0x3c81>
    44a5:	mov    $0x2,%ecx
    44aa:	mov    %r14,%rsi
    44ad:	cmp    $0x5d,%rsi
    44b1:	cmovl  0x29e7(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    44b9:	cmp    $0x6,%rcx
    44bd:	je     470b <botlish_fn_13+0x3ed3>
    44c3:	mov    %r14,%rsi
    44c6:	test   $0x1,%rsi
    44cd:	jne    44fd <botlish_fn_13+0x3cc5>
    44d3:	mov    $0xbb,%edx
    44d8:	mov    %r14,%rsi
    44db:	mov    0x280(%rsp),%rdi
    44e3:	call   44e8 <botlish_fn_13+0x3cb0>
			44e4: R_X86_64_PLT32	rt_int_cmp-0x4
    44e8:	mov    $0x2,%ecx
    44ed:	test   %rax,%rax
    44f0:	cmovl  0x29a8(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    44f8:	jmp    4514 <botlish_fn_13+0x3cdc>
    44fd:	mov    $0x2,%ecx
    4502:	mov    %r14,%rsi
    4505:	cmp    $0xbb,%rsi
    450c:	cmovl  0x298c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4514:	cmp    $0x6,%rcx
    4518:	je     468e <botlish_fn_13+0x3e56>
    451e:	mov    %r14,%rsi
    4521:	test   $0x1,%rsi
    4528:	jne    4558 <botlish_fn_13+0x3d20>
    452e:	mov    $0xcd,%edx
    4533:	mov    %r14,%rsi
    4536:	mov    0x280(%rsp),%rdi
    453e:	call   4543 <botlish_fn_13+0x3d0b>
			453f: R_X86_64_PLT32	rt_int_cmp-0x4
    4543:	mov    $0x2,%ecx
    4548:	test   %rax,%rax
    454b:	cmovl  0x294d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4553:	jmp    456f <botlish_fn_13+0x3d37>
    4558:	mov    $0x2,%ecx
    455d:	mov    %r14,%rsi
    4560:	cmp    $0xcd,%rsi
    4567:	cmovl  0x2931(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    456f:	cmp    $0x6,%rcx
    4573:	je     4650 <botlish_fn_13+0x3e18>
    4579:	mov    %r14,%rsi
    457c:	test   $0x1,%rsi
    4583:	jne    45b3 <botlish_fn_13+0x3d7b>
    4589:	mov    $0xfb,%edx
    458e:	mov    %r14,%rsi
    4591:	mov    0x280(%rsp),%rdi
    4599:	call   459e <botlish_fn_13+0x3d66>
			459a: R_X86_64_PLT32	rt_int_cmp-0x4
    459e:	mov    $0x2,%ecx
    45a3:	test   %rax,%rax
    45a6:	cmovl  0x28f2(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    45ae:	jmp    45ca <botlish_fn_13+0x3d92>
    45b3:	mov    $0x2,%ecx
    45b8:	mov    %r14,%rsi
    45bb:	cmp    $0xfb,%rsi
    45c2:	cmovl  0x28d6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    45ca:	cmp    $0x6,%rcx
    45ce:	je     4645 <botlish_fn_13+0x3e0d>
    45d4:	mov    %r14,%rsi
    45d7:	test   $0x1,%rsi
    45de:	jne    460e <botlish_fn_13+0x3dd6>
    45e4:	mov    $0xfd,%edx
    45e9:	mov    %r14,%rsi
    45ec:	mov    0x280(%rsp),%rdi
    45f4:	call   45f9 <botlish_fn_13+0x3dc1>
			45f5: R_X86_64_PLT32	rt_int_cmp-0x4
    45f9:	mov    $0x2,%ecx
    45fe:	test   %rax,%rax
    4601:	cmovl  0x2897(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4609:	jmp    4625 <botlish_fn_13+0x3ded>
    460e:	mov    $0x2,%ecx
    4613:	mov    %r14,%rsi
    4616:	cmp    $0xfd,%rsi
    461d:	cmovl  0x287b(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4625:	cmp    $0x6,%rcx
    4629:	je     463a <botlish_fn_13+0x3e02>
    462f:	mov    $0x1d,%r13d
    4635:	jmp    502d <botlish_fn_13+0x47f5>
    463a:	mov    $0x15,%r13d
    4640:	jmp    502d <botlish_fn_13+0x47f5>
    4645:	mov    $0x1d,%r13d
    464b:	jmp    502d <botlish_fn_13+0x47f5>
    4650:	mov    %r14,%rsi
    4653:	mov    %rsi,%rax
    4656:	sar    $1,%rax
    4659:	cmp    $0x5e,%rax
    465d:	jl     4683 <botlish_fn_13+0x3e4b>
    4663:	cmp    $0x65,%rax
    4667:	jl     4678 <botlish_fn_13+0x3e40>
    466d:	mov    $0xb,%r13d
    4673:	jmp    502d <botlish_fn_13+0x47f5>
    4678:	mov    $0x1d,%r13d
    467e:	jmp    502d <botlish_fn_13+0x47f5>
    4683:	mov    $0x15,%r13d
    4689:	jmp    502d <botlish_fn_13+0x47f5>
    468e:	mov    %r14,%rsi
    4691:	mov    %rsi,%rax
    4694:	sar    $1,%rax
    4697:	cmp    $0x3a,%rax
    469b:	jl     46d6 <botlish_fn_13+0x3e9e>
    46a1:	cmp    $0x45,%rax
    46a5:	jl     46cb <botlish_fn_13+0x3e93>
    46ab:	cmp    $0x46,%rax
    46af:	jl     46c0 <botlish_fn_13+0x3e88>
    46b5:	mov    $0x1d,%r13d
    46bb:	jmp    502d <botlish_fn_13+0x47f5>
    46c0:	mov    $0xb,%r13d
    46c6:	jmp    502d <botlish_fn_13+0x47f5>
    46cb:	mov    $0x1d,%r13d
    46d1:	jmp    502d <botlish_fn_13+0x47f5>
    46d6:	cmp    $0x2f,%rax
    46da:	jl     4700 <botlish_fn_13+0x3ec8>
    46e0:	cmp    $0x30,%rax
    46e4:	jl     46f5 <botlish_fn_13+0x3ebd>
    46ea:	mov    $0x7,%r13d
    46f0:	jmp    502d <botlish_fn_13+0x47f5>
    46f5:	mov    $0x1d,%r13d
    46fb:	jmp    502d <botlish_fn_13+0x47f5>
    4700:	mov    $0x9,%r13d
    4706:	jmp    502d <botlish_fn_13+0x47f5>
    470b:	mov    %r14,%rsi
    470e:	test   $0x1,%rsi
    4715:	jne    4745 <botlish_fn_13+0x3f0d>
    471b:	mov    $0x1b,%edx
    4720:	mov    %r14,%rsi
    4723:	mov    0x280(%rsp),%rdi
    472b:	call   4730 <botlish_fn_13+0x3ef8>
			472c: R_X86_64_PLT32	rt_int_cmp-0x4
    4730:	mov    $0x2,%ecx
    4735:	test   %rax,%rax
    4738:	cmovl  0x2760(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4740:	jmp    4759 <botlish_fn_13+0x3f21>
    4745:	mov    $0x2,%ecx
    474a:	mov    %r14,%rsi
    474d:	cmp    $0x1b,%rsi
    4751:	cmovl  0x2747(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4759:	cmp    $0x6,%rcx
    475d:	je     47e0 <botlish_fn_13+0x3fa8>
    4763:	mov    %r14,%rsi
    4766:	mov    %rsi,%rax
    4769:	sar    $1,%rax
    476c:	cmp    $0x21,%rax
    4770:	jl     47ab <botlish_fn_13+0x3f73>
    4776:	cmp    $0x2c,%rax
    477a:	jl     47a0 <botlish_fn_13+0x3f68>
    4780:	cmp    $0x2d,%rax
    4784:	jl     4795 <botlish_fn_13+0x3f5d>
    478a:	mov    $0x1d,%r13d
    4790:	jmp    502d <botlish_fn_13+0x47f5>
    4795:	mov    $0x15,%r13d
    479b:	jmp    502d <botlish_fn_13+0x47f5>
    47a0:	mov    $0x1d,%r13d
    47a6:	jmp    502d <botlish_fn_13+0x47f5>
    47ab:	cmp    $0xe,%rax
    47af:	jl     47d5 <botlish_fn_13+0x3f9d>
    47b5:	cmp    $0x20,%rax
    47b9:	jl     47ca <botlish_fn_13+0x3f92>
    47bf:	mov    $0x15,%r13d
    47c5:	jmp    502d <botlish_fn_13+0x47f5>
    47ca:	mov    $0x1d,%r13d
    47d0:	jmp    502d <botlish_fn_13+0x47f5>
    47d5:	mov    $0x15,%r13d
    47db:	jmp    502d <botlish_fn_13+0x47f5>
    47e0:	mov    %r14,%rsi
    47e3:	test   $0x1,%rsi
    47ea:	jne    481a <botlish_fn_13+0x3fe2>
    47f0:	mov    $0x1,%edx
    47f5:	mov    %r14,%rsi
    47f8:	mov    0x280(%rsp),%rdi
    4800:	call   4805 <botlish_fn_13+0x3fcd>
			4801: R_X86_64_PLT32	rt_int_cmp-0x4
    4805:	mov    $0x2,%esi
    480a:	test   %rax,%rax
    480d:	cmovl  0x268b(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    4815:	jmp    4830 <botlish_fn_13+0x3ff8>
    481a:	mov    $0x2,%esi
    481f:	mov    %r14,%r9
    4822:	mov    %r14,%r10
    4825:	test   %r9,%r10
    4828:	cmovle 0x2670(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    4830:	cmp    $0x6,%rsi
    4834:	je     4878 <botlish_fn_13+0x4040>
    483a:	mov    %r14,%rsi
    483d:	mov    %rsi,%rax
    4840:	sar    $1,%rax
    4843:	cmp    $0x9,%rax
    4847:	jl     486d <botlish_fn_13+0x4035>
    484d:	cmp    $0xb,%rax
    4851:	jl     4862 <botlish_fn_13+0x402a>
    4857:	mov    $0x1d,%r13d
    485d:	jmp    502d <botlish_fn_13+0x47f5>
    4862:	mov    $0x15,%r13d
    4868:	jmp    502d <botlish_fn_13+0x47f5>
    486d:	mov    $0x1d,%r13d
    4873:	jmp    502d <botlish_fn_13+0x47f5>
    4878:	mov    %r14,%rsi
    487b:	test   $0x1,%rsi
    4882:	jne    48b5 <botlish_fn_13+0x407d>
    4888:	mov    0x300(%rsp),%rdx
    4890:	mov    %r14,%rsi
    4893:	mov    0x280(%rsp),%rdi
    489b:	call   48a0 <botlish_fn_13+0x4068>
			489c: R_X86_64_PLT32	rt_int_cmp-0x4
    48a0:	mov    $0x2,%ecx
    48a5:	test   %rax,%rax
    48a8:	cmovl  0x25f0(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    48b0:	jmp    48c9 <botlish_fn_13+0x4091>
    48b5:	mov    $0x2,%ecx
    48ba:	mov    %r14,%rsi
    48bd:	cmp    $0xffffffffffffffff,%rsi
    48c1:	cmovl  0x25d7(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    48c9:	cmp    $0x6,%rcx
    48cd:	je     48de <botlish_fn_13+0x40a6>
    48d3:	mov    $0x15,%r13d
    48d9:	jmp    502d <botlish_fn_13+0x47f5>
    48de:	mov    $0x1d,%r13d
    48e4:	jmp    502d <botlish_fn_13+0x47f5>
    48e9:	mov    %r14,%rsi
    48ec:	test   $0x1,%rsi
    48f3:	jne    4923 <botlish_fn_13+0x40eb>
    48f9:	mov    $0x5b,%edx
    48fe:	mov    %r14,%rsi
    4901:	mov    0x280(%rsp),%rdi
    4909:	call   490e <botlish_fn_13+0x40d6>
			490a: R_X86_64_PLT32	rt_int_cmp-0x4
    490e:	mov    $0x2,%ecx
    4913:	test   %rax,%rax
    4916:	cmovl  0x2582(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    491e:	jmp    4937 <botlish_fn_13+0x40ff>
    4923:	mov    $0x2,%ecx
    4928:	mov    %r14,%rsi
    492b:	cmp    $0x5b,%rsi
    492f:	cmovl  0x2569(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4937:	cmp    $0x6,%rcx
    493b:	je     4b73 <botlish_fn_13+0x433b>
    4941:	mov    %r14,%rsi
    4944:	test   $0x1,%rsi
    494b:	jne    497b <botlish_fn_13+0x4143>
    4951:	mov    $0xbb,%edx
    4956:	mov    %r14,%rsi
    4959:	mov    0x280(%rsp),%rdi
    4961:	call   4966 <botlish_fn_13+0x412e>
			4962: R_X86_64_PLT32	rt_int_cmp-0x4
    4966:	mov    $0x2,%ecx
    496b:	test   %rax,%rax
    496e:	cmovl  0x252a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4976:	jmp    4992 <botlish_fn_13+0x415a>
    497b:	mov    $0x2,%ecx
    4980:	mov    %r14,%rsi
    4983:	cmp    $0xbb,%rsi
    498a:	cmovl  0x250e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4992:	cmp    $0x6,%rcx
    4996:	je     4b0b <botlish_fn_13+0x42d3>
    499c:	mov    %r14,%rsi
    499f:	test   $0x1,%rsi
    49a6:	jne    49d6 <botlish_fn_13+0x419e>
    49ac:	mov    $0xcd,%edx
    49b1:	mov    %r14,%rsi
    49b4:	mov    0x280(%rsp),%rdi
    49bc:	call   49c1 <botlish_fn_13+0x4189>
			49bd: R_X86_64_PLT32	rt_int_cmp-0x4
    49c1:	mov    $0x2,%esi
    49c6:	test   %rax,%rax
    49c9:	cmovl  0x24cf(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    49d1:	jmp    49ec <botlish_fn_13+0x41b4>
    49d6:	mov    $0x2,%esi
    49db:	mov    %r14,%rax
    49de:	cmp    $0xcd,%rax
    49e4:	cmovl  0x24b4(%rip),%rsi        # 6ea0 <botlish_fn_13+0x6668>
    49ec:	cmp    $0x6,%rsi
    49f0:	je     4acd <botlish_fn_13+0x4295>
    49f6:	mov    %r14,%rsi
    49f9:	test   $0x1,%rsi
    4a00:	jne    4a30 <botlish_fn_13+0x41f8>
    4a06:	mov    $0xfb,%edx
    4a0b:	mov    %r14,%rsi
    4a0e:	mov    0x280(%rsp),%rdi
    4a16:	call   4a1b <botlish_fn_13+0x41e3>
			4a17: R_X86_64_PLT32	rt_int_cmp-0x4
    4a1b:	mov    $0x2,%ecx
    4a20:	test   %rax,%rax
    4a23:	cmovl  0x2475(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4a2b:	jmp    4a47 <botlish_fn_13+0x420f>
    4a30:	mov    $0x2,%ecx
    4a35:	mov    %r14,%rsi
    4a38:	cmp    $0xfb,%rsi
    4a3f:	cmovl  0x2459(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4a47:	cmp    $0x6,%rcx
    4a4b:	je     4ac2 <botlish_fn_13+0x428a>
    4a51:	mov    %r14,%rsi
    4a54:	test   $0x1,%rsi
    4a5b:	jne    4a8b <botlish_fn_13+0x4253>
    4a61:	mov    $0xfd,%edx
    4a66:	mov    %r14,%rsi
    4a69:	mov    0x280(%rsp),%rdi
    4a71:	call   4a76 <botlish_fn_13+0x423e>
			4a72: R_X86_64_PLT32	rt_int_cmp-0x4
    4a76:	mov    $0x2,%ecx
    4a7b:	test   %rax,%rax
    4a7e:	cmovl  0x241a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4a86:	jmp    4aa2 <botlish_fn_13+0x426a>
    4a8b:	mov    $0x2,%ecx
    4a90:	mov    %r14,%rsi
    4a93:	cmp    $0xfd,%rsi
    4a9a:	cmovl  0x23fe(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4aa2:	cmp    $0x6,%rcx
    4aa6:	je     4ab7 <botlish_fn_13+0x427f>
    4aac:	mov    $0x1b,%r13d
    4ab2:	jmp    502d <botlish_fn_13+0x47f5>
    4ab7:	mov    $0x15,%r13d
    4abd:	jmp    502d <botlish_fn_13+0x47f5>
    4ac2:	mov    $0x1b,%r13d
    4ac8:	jmp    502d <botlish_fn_13+0x47f5>
    4acd:	mov    %r14,%rsi
    4ad0:	mov    %rsi,%rax
    4ad3:	sar    $1,%rax
    4ad6:	cmp    $0x5e,%rax
    4ada:	jl     4b00 <botlish_fn_13+0x42c8>
    4ae0:	cmp    $0x65,%rax
    4ae4:	jl     4af5 <botlish_fn_13+0x42bd>
    4aea:	mov    $0xb,%r13d
    4af0:	jmp    502d <botlish_fn_13+0x47f5>
    4af5:	mov    $0x1b,%r13d
    4afb:	jmp    502d <botlish_fn_13+0x47f5>
    4b00:	mov    $0x15,%r13d
    4b06:	jmp    502d <botlish_fn_13+0x47f5>
    4b0b:	mov    %r14,%rsi
    4b0e:	mov    %rsi,%rax
    4b11:	sar    $1,%rax
    4b14:	cmp    $0x2f,%rax
    4b18:	jl     4b53 <botlish_fn_13+0x431b>
    4b1e:	cmp    $0x45,%rax
    4b22:	jl     4b48 <botlish_fn_13+0x4310>
    4b28:	cmp    $0x46,%rax
    4b2c:	jl     4b3d <botlish_fn_13+0x4305>
    4b32:	mov    $0x1b,%r13d
    4b38:	jmp    502d <botlish_fn_13+0x47f5>
    4b3d:	mov    $0xb,%r13d
    4b43:	jmp    502d <botlish_fn_13+0x47f5>
    4b48:	mov    $0x1b,%r13d
    4b4e:	jmp    502d <botlish_fn_13+0x47f5>
    4b53:	cmp    $0x2e,%rax
    4b57:	jl     4b68 <botlish_fn_13+0x4330>
    4b5d:	mov    $0x9,%r13d
    4b63:	jmp    502d <botlish_fn_13+0x47f5>
    4b68:	mov    $0x1b,%r13d
    4b6e:	jmp    502d <botlish_fn_13+0x47f5>
    4b73:	mov    %r14,%rsi
    4b76:	test   $0x1,%rsi
    4b7d:	jne    4bad <botlish_fn_13+0x4375>
    4b83:	mov    $0x1b,%edx
    4b88:	mov    %r14,%rsi
    4b8b:	mov    0x280(%rsp),%rdi
    4b93:	call   4b98 <botlish_fn_13+0x4360>
			4b94: R_X86_64_PLT32	rt_int_cmp-0x4
    4b98:	mov    $0x2,%ecx
    4b9d:	test   %rax,%rax
    4ba0:	cmovl  0x22f8(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4ba8:	jmp    4bc1 <botlish_fn_13+0x4389>
    4bad:	mov    $0x2,%ecx
    4bb2:	mov    %r14,%rsi
    4bb5:	cmp    $0x1b,%rsi
    4bb9:	cmovl  0x22df(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4bc1:	cmp    $0x6,%rcx
    4bc5:	je     4c33 <botlish_fn_13+0x43fb>
    4bcb:	mov    %r14,%rsi
    4bce:	mov    %rsi,%rax
    4bd1:	sar    $1,%rax
    4bd4:	cmp    $0x20,%rax
    4bd8:	jl     4c13 <botlish_fn_13+0x43db>
    4bde:	cmp    $0x21,%rax
    4be2:	jl     4c08 <botlish_fn_13+0x43d0>
    4be8:	cmp    $0x2c,%rax
    4bec:	jl     4bfd <botlish_fn_13+0x43c5>
    4bf2:	mov    $0x15,%r13d
    4bf8:	jmp    502d <botlish_fn_13+0x47f5>
    4bfd:	mov    $0x1b,%r13d
    4c03:	jmp    502d <botlish_fn_13+0x47f5>
    4c08:	mov    $0x15,%r13d
    4c0e:	jmp    502d <botlish_fn_13+0x47f5>
    4c13:	cmp    $0xe,%rax
    4c17:	jl     4c28 <botlish_fn_13+0x43f0>
    4c1d:	mov    $0x1b,%r13d
    4c23:	jmp    502d <botlish_fn_13+0x47f5>
    4c28:	mov    $0x15,%r13d
    4c2e:	jmp    502d <botlish_fn_13+0x47f5>
    4c33:	mov    %r14,%rsi
    4c36:	test   $0x1,%rsi
    4c3d:	jne    4c6d <botlish_fn_13+0x4435>
    4c43:	mov    $0x1,%edx
    4c48:	mov    %r14,%rsi
    4c4b:	mov    0x280(%rsp),%rdi
    4c53:	call   4c58 <botlish_fn_13+0x4420>
			4c54: R_X86_64_PLT32	rt_int_cmp-0x4
    4c58:	mov    $0x2,%ecx
    4c5d:	test   %rax,%rax
    4c60:	cmovl  0x2238(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4c68:	jmp    4c83 <botlish_fn_13+0x444b>
    4c6d:	mov    $0x2,%ecx
    4c72:	mov    %r14,%rax
    4c75:	mov    %r14,%rsi
    4c78:	test   %rax,%rsi
    4c7b:	cmovle 0x221d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4c83:	cmp    $0x6,%rcx
    4c87:	je     4ccb <botlish_fn_13+0x4493>
    4c8d:	mov    %r14,%rsi
    4c90:	mov    %rsi,%rax
    4c93:	sar    $1,%rax
    4c96:	cmp    $0x9,%rax
    4c9a:	jl     4cc0 <botlish_fn_13+0x4488>
    4ca0:	cmp    $0xb,%rax
    4ca4:	jl     4cb5 <botlish_fn_13+0x447d>
    4caa:	mov    $0x1b,%r13d
    4cb0:	jmp    502d <botlish_fn_13+0x47f5>
    4cb5:	mov    $0x15,%r13d
    4cbb:	jmp    502d <botlish_fn_13+0x47f5>
    4cc0:	mov    $0x1b,%r13d
    4cc6:	jmp    502d <botlish_fn_13+0x47f5>
    4ccb:	mov    %r14,%rsi
    4cce:	test   $0x1,%rsi
    4cd5:	jne    4d08 <botlish_fn_13+0x44d0>
    4cdb:	mov    0x300(%rsp),%rdx
    4ce3:	mov    %r14,%rsi
    4ce6:	mov    0x280(%rsp),%rdi
    4cee:	call   4cf3 <botlish_fn_13+0x44bb>
			4cef: R_X86_64_PLT32	rt_int_cmp-0x4
    4cf3:	mov    $0x2,%ecx
    4cf8:	test   %rax,%rax
    4cfb:	cmovl  0x219d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4d03:	jmp    4d1c <botlish_fn_13+0x44e4>
    4d08:	mov    $0x2,%ecx
    4d0d:	mov    %r14,%rsi
    4d10:	cmp    $0xffffffffffffffff,%rsi
    4d14:	cmovl  0x2184(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4d1c:	cmp    $0x6,%rcx
    4d20:	je     4d31 <botlish_fn_13+0x44f9>
    4d26:	mov    $0x15,%r13d
    4d2c:	jmp    502d <botlish_fn_13+0x47f5>
    4d31:	mov    $0x1b,%r13d
    4d37:	jmp    502d <botlish_fn_13+0x47f5>
    4d3c:	test   %r13,%r13
    4d3f:	jle    4e79 <botlish_fn_13+0x4641>
    4d45:	mov    %r14,%rsi
    4d48:	test   $0x1,%rsi
    4d4f:	jne    4d7f <botlish_fn_13+0x4547>
    4d55:	mov    $0x63,%edx
    4d5a:	mov    %r14,%rsi
    4d5d:	mov    0x280(%rsp),%rdi
    4d65:	call   4d6a <botlish_fn_13+0x4532>
			4d66: R_X86_64_PLT32	rt_int_cmp-0x4
    4d6a:	mov    $0x2,%ecx
    4d6f:	test   %rax,%rax
    4d72:	cmovl  0x2126(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4d7a:	jmp    4d93 <botlish_fn_13+0x455b>
    4d7f:	mov    $0x2,%ecx
    4d84:	mov    %r14,%rsi
    4d87:	cmp    $0x63,%rsi
    4d8b:	cmovl  0x210d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4d93:	cmp    $0x6,%rcx
    4d97:	je     4e0b <botlish_fn_13+0x45d3>
    4d9d:	mov    %r14,%rsi
    4da0:	test   $0x1,%rsi
    4da7:	jne    4dd7 <botlish_fn_13+0x459f>
    4dad:	mov    $0x75,%edx
    4db2:	mov    %r14,%rsi
    4db5:	mov    0x280(%rsp),%rdi
    4dbd:	call   4dc2 <botlish_fn_13+0x458a>
			4dbe: R_X86_64_PLT32	rt_int_cmp-0x4
    4dc2:	mov    $0x2,%ecx
    4dc7:	test   %rax,%rax
    4dca:	cmovl  0x20ce(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4dd2:	jmp    4deb <botlish_fn_13+0x45b3>
    4dd7:	mov    $0x2,%ecx
    4ddc:	mov    %r14,%rsi
    4ddf:	cmp    $0x75,%rsi
    4de3:	cmovl  0x20b5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4deb:	cmp    $0x6,%rcx
    4def:	je     4e00 <botlish_fn_13+0x45c8>
    4df5:	mov    $0x19,%r13d
    4dfb:	jmp    502d <botlish_fn_13+0x47f5>
    4e00:	mov    $0x7,%r13d
    4e06:	jmp    502d <botlish_fn_13+0x47f5>
    4e0b:	mov    %r14,%rsi
    4e0e:	test   $0x1,%rsi
    4e15:	jne    4e45 <botlish_fn_13+0x460d>
    4e1b:	mov    $0x61,%edx
    4e20:	mov    %r14,%rsi
    4e23:	mov    0x280(%rsp),%rdi
    4e2b:	call   4e30 <botlish_fn_13+0x45f8>
			4e2c: R_X86_64_PLT32	rt_int_cmp-0x4
    4e30:	mov    $0x2,%ecx
    4e35:	test   %rax,%rax
    4e38:	cmovl  0x2060(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4e40:	jmp    4e59 <botlish_fn_13+0x4621>
    4e45:	mov    $0x2,%ecx
    4e4a:	mov    %r14,%rsi
    4e4d:	cmp    $0x61,%rsi
    4e51:	cmovl  0x2047(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4e59:	cmp    $0x6,%rcx
    4e5d:	je     4e6e <botlish_fn_13+0x4636>
    4e63:	mov    $0x5,%r13d
    4e69:	jmp    502d <botlish_fn_13+0x47f5>
    4e6e:	mov    $0x19,%r13d
    4e74:	jmp    502d <botlish_fn_13+0x47f5>
    4e79:	mov    %r14,%rsi
    4e7c:	test   $0x1,%rsi
    4e83:	jne    4eb4 <botlish_fn_13+0x467c>
    4e89:	mov    $0x61,%edx
    4e8e:	mov    %r14,%rsi
    4e91:	mov    0x280(%rsp),%rdi
    4e99:	call   4e9e <botlish_fn_13+0x4666>
			4e9a: R_X86_64_PLT32	rt_int_cmp-0x4
    4e9e:	mov    $0x2,%r11d
    4ea4:	test   %rax,%rax
    4ea7:	cmovl  0x1ff1(%rip),%r11        # 6ea0 <botlish_fn_13+0x6668>
    4eaf:	jmp    4ec9 <botlish_fn_13+0x4691>
    4eb4:	mov    $0x2,%r11d
    4eba:	mov    %r14,%rsi
    4ebd:	cmp    $0x61,%rsi
    4ec1:	cmovl  0x1fd7(%rip),%r11        # 6ea0 <botlish_fn_13+0x6668>
    4ec9:	cmp    $0x6,%r11
    4ecd:	je     4fa4 <botlish_fn_13+0x476c>
    4ed3:	mov    %r14,%rsi
    4ed6:	test   $0x1,%rsi
    4edd:	jne    4f0d <botlish_fn_13+0x46d5>
    4ee3:	mov    $0x63,%edx
    4ee8:	mov    %r14,%rsi
    4eeb:	mov    0x280(%rsp),%rdi
    4ef3:	call   4ef8 <botlish_fn_13+0x46c0>
			4ef4: R_X86_64_PLT32	rt_int_cmp-0x4
    4ef8:	mov    $0x2,%ecx
    4efd:	test   %rax,%rax
    4f00:	cmovl  0x1f98(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4f08:	jmp    4f21 <botlish_fn_13+0x46e9>
    4f0d:	mov    $0x2,%ecx
    4f12:	mov    %r14,%rsi
    4f15:	cmp    $0x63,%rsi
    4f19:	cmovl  0x1f7f(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4f21:	cmp    $0x6,%rcx
    4f25:	je     4f99 <botlish_fn_13+0x4761>
    4f2b:	mov    %r14,%rsi
    4f2e:	test   $0x1,%rsi
    4f35:	jne    4f65 <botlish_fn_13+0x472d>
    4f3b:	mov    $0x75,%edx
    4f40:	mov    %r14,%rsi
    4f43:	mov    0x280(%rsp),%rdi
    4f4b:	call   4f50 <botlish_fn_13+0x4718>
			4f4c: R_X86_64_PLT32	rt_int_cmp-0x4
    4f50:	mov    $0x2,%ecx
    4f55:	test   %rax,%rax
    4f58:	cmovl  0x1f40(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4f60:	jmp    4f79 <botlish_fn_13+0x4741>
    4f65:	mov    $0x2,%ecx
    4f6a:	mov    %r14,%rsi
    4f6d:	cmp    $0x75,%rsi
    4f71:	cmovl  0x1f27(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4f79:	cmp    $0x6,%rcx
    4f7d:	je     4f8e <botlish_fn_13+0x4756>
    4f83:	mov    $0x17,%r13d
    4f89:	jmp    502d <botlish_fn_13+0x47f5>
    4f8e:	mov    $0x7,%r13d
    4f94:	jmp    502d <botlish_fn_13+0x47f5>
    4f99:	mov    $0x5,%r13d
    4f9f:	jmp    502d <botlish_fn_13+0x47f5>
    4fa4:	mov    %r14,%rsi
    4fa7:	test   $0x1,%rsi
    4fae:	jne    4fde <botlish_fn_13+0x47a6>
    4fb4:	mov    $0x5b,%edx
    4fb9:	mov    %r14,%rsi
    4fbc:	mov    0x280(%rsp),%rdi
    4fc4:	call   4fc9 <botlish_fn_13+0x4791>
			4fc5: R_X86_64_PLT32	rt_int_cmp-0x4
    4fc9:	mov    $0x2,%ecx
    4fce:	test   %rax,%rax
    4fd1:	cmovl  0x1ec7(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4fd9:	jmp    4ff2 <botlish_fn_13+0x47ba>
    4fde:	mov    $0x2,%ecx
    4fe3:	mov    %r14,%rsi
    4fe6:	cmp    $0x5b,%rsi
    4fea:	cmovl  0x1eae(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    4ff2:	cmp    $0x6,%rcx
    4ff6:	je     5027 <botlish_fn_13+0x47ef>
    4ffc:	mov    %r14,%rsi
    4fff:	mov    %rsi,%rax
    5002:	sar    $1,%rax
    5005:	cmp    $0x2e,%rax
    5009:	jl     501a <botlish_fn_13+0x47e2>
    500f:	mov    $0x17,%r13d
    5015:	jmp    502d <botlish_fn_13+0x47f5>
    501a:	mov    0x328(%rsp),%r13
    5022:	jmp    502d <botlish_fn_13+0x47f5>
    5027:	mov    $0x17,%r13d
    502d:	mov    %r13,%rsi
    5030:	sar    $1,%rsi
    5033:	cmp    $0x9,%rsi
    5037:	jl     5160 <botlish_fn_13+0x4928>
    503d:	cmp    $0xa,%rsi
    5041:	mov    %rsi,%r13
    5044:	je     5148 <botlish_fn_13+0x4910>
    504a:	mov    %r14,%rsi
    504d:	test   $0x1,%rsi
    5054:	jne    5087 <botlish_fn_13+0x484f>
    505a:	mov    0x300(%rsp),%rdx
    5062:	mov    %r14,%rsi
    5065:	mov    0x280(%rsp),%rdi
    506d:	call   5072 <botlish_fn_13+0x483a>
			506e: R_X86_64_PLT32	rt_int_cmp-0x4
    5072:	mov    $0x2,%ecx
    5077:	test   %rax,%rax
    507a:	cmove  0x1e1e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5082:	jmp    509b <botlish_fn_13+0x4863>
    5087:	mov    $0x2,%ecx
    508c:	mov    %r14,%rsi
    508f:	cmp    $0xffffffffffffffff,%rsi
    5093:	cmove  0x1e05(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    509b:	cmp    $0x6,%rcx
    509f:	je     50fd <botlish_fn_13+0x48c5>
    50a5:	mov    %r13,%rsi
    50a8:	mov    0x280(%rsp),%rdi
    50b0:	call   50b5 <botlish_fn_13+0x487d>
			50b1: R_X86_64_PLT32	botlish_fn_1-0x4
    50b5:	mov    0x280(%rsp),%rdi
    50bd:	mov    0x10(%rdi),%rcx
    50c1:	mov    0x158(%rcx),%rdx
    50c8:	lea    0x240(%rsp),%r9
    50d0:	mov    %rax,0x240(%rsp)
    50d8:	mov    %r14,%rsi
    50db:	mov    %rsi,0x248(%rsp)
    50e3:	mov    $0x1,%esi
    50e8:	mov    $0x5,%ecx
    50ed:	mov    $0x2,%r8d
    50f3:	call   50f8 <botlish_fn_13+0x48c0>
			50f4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    50f8:	jmp    647b <botlish_fn_13+0x5c43>
    50fd:	mov    %r13,%rsi
    5100:	mov    0x280(%rsp),%rdi
    5108:	call   510d <botlish_fn_13+0x48d5>
			5109: R_X86_64_PLT32	botlish_fn_1-0x4
    510d:	mov    0x280(%rsp),%rdi
    5115:	mov    0x10(%rdi),%rcx
    5119:	mov    0x150(%rcx),%rdx
    5120:	lea    0x238(%rsp),%r9
    5128:	mov    %rax,0x238(%rsp)
    5130:	mov    $0x2,%ecx
    5135:	mov    $0x1,%r8d
    513b:	mov    %rcx,%rsi
    513e:	call   5143 <botlish_fn_13+0x490b>
			513f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5143:	jmp    647b <botlish_fn_13+0x5c43>
    5148:	mov    %r12,%r13
    514b:	mov    0x298(%rsp),%rax
    5153:	mov    %rax,0x2e0(%rsp)
    515b:	jmp    5672 <botlish_fn_13+0x4e3a>
    5160:	mov    %r13,0xa0(%rsp)
    5168:	mov    $0x6,%r12d
    516e:	movq   $0x6,0x80(%rsp)
    517a:	mov    0x328(%rsp),%r14
    5182:	mov    0x298(%rsp),%r15
    518a:	jmp    6626 <botlish_fn_13+0x5dee>
    518f:	mov    %rsi,%r14
    5192:	mov    0x298(%rsp),%r15
    519a:	mov    0x298(%rsp),%rax
    51a2:	mov    %rax,0x2e0(%rsp)
    51aa:	sar    $1,%r15
    51ad:	test   %r15,%r15
    51b0:	jle    5463 <botlish_fn_13+0x4c2b>
    51b6:	mov    %r14,%rsi
    51b9:	test   $0x1,%rsi
    51c0:	jne    51f0 <botlish_fn_13+0x49b8>
    51c6:	mov    $0xb9,%edx
    51cb:	mov    %r14,%rsi
    51ce:	mov    0x280(%rsp),%rdi
    51d6:	call   51db <botlish_fn_13+0x49a3>
			51d7: R_X86_64_PLT32	rt_int_cmp-0x4
    51db:	mov    $0x2,%ecx
    51e0:	test   %rax,%rax
    51e3:	cmovl  0x1cb5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    51eb:	jmp    5207 <botlish_fn_13+0x49cf>
    51f0:	mov    $0x2,%ecx
    51f5:	mov    %r14,%rsi
    51f8:	cmp    $0xb9,%rsi
    51ff:	cmovl  0x1c99(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5207:	cmp    $0x6,%rcx
    520b:	je     5370 <botlish_fn_13+0x4b38>
    5211:	mov    %r14,%rsi
    5214:	test   $0x1,%rsi
    521b:	jne    524b <botlish_fn_13+0x4a13>
    5221:	mov    $0x1b001,%edx
    5226:	mov    %r14,%rsi
    5229:	mov    0x280(%rsp),%rdi
    5231:	call   5236 <botlish_fn_13+0x49fe>
			5232: R_X86_64_PLT32	rt_int_cmp-0x4
    5236:	mov    $0x2,%ecx
    523b:	test   %rax,%rax
    523e:	cmovl  0x1c5a(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5246:	jmp    5262 <botlish_fn_13+0x4a2a>
    524b:	mov    $0x2,%ecx
    5250:	mov    %r14,%rsi
    5253:	cmp    $0x1b001,%rsi
    525a:	cmovl  0x1c3e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5262:	cmp    $0x6,%rcx
    5266:	je     5345 <botlish_fn_13+0x4b0d>
    526c:	mov    %r14,%rsi
    526f:	test   $0x1,%rsi
    5276:	jne    52a6 <botlish_fn_13+0x4a6e>
    527c:	mov    $0x1c001,%edx
    5281:	mov    %r14,%rsi
    5284:	mov    0x280(%rsp),%rdi
    528c:	call   5291 <botlish_fn_13+0x4a59>
			528d: R_X86_64_PLT32	rt_int_cmp-0x4
    5291:	mov    $0x2,%ecx
    5296:	test   %rax,%rax
    5299:	cmovl  0x1bff(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    52a1:	jmp    52bd <botlish_fn_13+0x4a85>
    52a6:	mov    $0x2,%ecx
    52ab:	mov    %r14,%rsi
    52ae:	cmp    $0x1c001,%rsi
    52b5:	cmovl  0x1be3(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    52bd:	cmp    $0x6,%rcx
    52c1:	je     533a <botlish_fn_13+0x4b02>
    52c7:	mov    %r14,%rsi
    52ca:	test   $0x1,%rsi
    52d1:	jne    5301 <botlish_fn_13+0x4ac9>
    52d7:	mov    $0x220001,%edx
    52dc:	mov    %r14,%rsi
    52df:	mov    0x280(%rsp),%rdi
    52e7:	call   52ec <botlish_fn_13+0x4ab4>
			52e8: R_X86_64_PLT32	rt_int_cmp-0x4
    52ec:	mov    $0x2,%edx
    52f1:	test   %rax,%rax
    52f4:	cmovl  0x1ba4(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    52fc:	jmp    5318 <botlish_fn_13+0x4ae0>
    5301:	mov    $0x2,%edx
    5306:	mov    %r14,%rsi
    5309:	cmp    $0x220001,%rsi
    5310:	cmovl  0x1b88(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    5318:	cmp    $0x6,%rdx
    531c:	je     532d <botlish_fn_13+0x4af5>
    5322:	mov    $0xd,%r15d
    5328:	jmp    5533 <botlish_fn_13+0x4cfb>
    532d:	mov    0x328(%rsp),%r15
    5335:	jmp    5533 <botlish_fn_13+0x4cfb>
    533a:	mov    $0xd,%r15d
    5340:	jmp    5533 <botlish_fn_13+0x4cfb>
    5345:	mov    %r14,%rsi
    5348:	mov    %rsi,%rax
    534b:	sar    $1,%rax
    534e:	cmp    $0x5d,%rax
    5352:	jl     5365 <botlish_fn_13+0x4b2d>
    5358:	mov    0x328(%rsp),%r15
    5360:	jmp    5533 <botlish_fn_13+0x4cfb>
    5365:	mov    $0x9,%r15d
    536b:	jmp    5533 <botlish_fn_13+0x4cfb>
    5370:	mov    %r14,%rsi
    5373:	test   $0x1,%rsi
    537a:	jne    53aa <botlish_fn_13+0x4b72>
    5380:	mov    $0x45,%edx
    5385:	mov    %r14,%rsi
    5388:	mov    0x280(%rsp),%rdi
    5390:	call   5395 <botlish_fn_13+0x4b5d>
			5391: R_X86_64_PLT32	rt_int_cmp-0x4
    5395:	mov    $0x2,%ecx
    539a:	test   %rax,%rax
    539d:	cmovl  0x1afb(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    53a5:	jmp    53be <botlish_fn_13+0x4b86>
    53aa:	mov    $0x2,%ecx
    53af:	mov    %r14,%rsi
    53b2:	cmp    $0x45,%rsi
    53b6:	cmovl  0x1ae2(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    53be:	cmp    $0x6,%rcx
    53c2:	je     53f3 <botlish_fn_13+0x4bbb>
    53c8:	mov    %r14,%rsi
    53cb:	mov    %rsi,%rax
    53ce:	sar    $1,%rax
    53d1:	cmp    $0x23,%rax
    53d5:	jl     53e8 <botlish_fn_13+0x4bb0>
    53db:	mov    0x328(%rsp),%r15
    53e3:	jmp    5533 <botlish_fn_13+0x4cfb>
    53e8:	mov    $0x5,%r15d
    53ee:	jmp    5533 <botlish_fn_13+0x4cfb>
    53f3:	mov    %r14,%rsi
    53f6:	test   $0x1,%rsi
    53fd:	jne    542d <botlish_fn_13+0x4bf5>
    5403:	mov    $0x41,%edx
    5408:	mov    %r14,%rsi
    540b:	mov    0x280(%rsp),%rdi
    5413:	call   5418 <botlish_fn_13+0x4be0>
			5414: R_X86_64_PLT32	rt_int_cmp-0x4
    5418:	mov    $0x2,%ecx
    541d:	test   %rax,%rax
    5420:	cmovl  0x1a78(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5428:	jmp    5441 <botlish_fn_13+0x4c09>
    542d:	mov    $0x2,%ecx
    5432:	mov    %r14,%rsi
    5435:	cmp    $0x41,%rsi
    5439:	cmovl  0x1a5f(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5441:	cmp    $0x6,%rcx
    5445:	je     5458 <botlish_fn_13+0x4c20>
    544b:	mov    0x328(%rsp),%r15
    5453:	jmp    5533 <botlish_fn_13+0x4cfb>
    5458:	mov    $0xd,%r15d
    545e:	jmp    5533 <botlish_fn_13+0x4cfb>
    5463:	mov    %r14,%rsi
    5466:	test   $0x1,%rsi
    546d:	jne    549d <botlish_fn_13+0x4c65>
    5473:	mov    $0x45,%edx
    5478:	mov    %r14,%rsi
    547b:	mov    0x280(%rsp),%rdi
    5483:	call   5488 <botlish_fn_13+0x4c50>
			5484: R_X86_64_PLT32	rt_int_cmp-0x4
    5488:	mov    $0x2,%ecx
    548d:	test   %rax,%rax
    5490:	cmovl  0x1a08(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5498:	jmp    54b1 <botlish_fn_13+0x4c79>
    549d:	mov    $0x2,%ecx
    54a2:	mov    %r14,%rsi
    54a5:	cmp    $0x45,%rsi
    54a9:	cmovl  0x19ef(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    54b1:	cmp    $0x6,%rcx
    54b5:	je     552d <botlish_fn_13+0x4cf5>
    54bb:	mov    %r14,%rsi
    54be:	test   $0x1,%rsi
    54c5:	jne    54f6 <botlish_fn_13+0x4cbe>
    54cb:	mov    $0x47,%edx
    54d0:	mov    %r14,%rsi
    54d3:	mov    0x280(%rsp),%rdi
    54db:	call   54e0 <botlish_fn_13+0x4ca8>
			54dc: R_X86_64_PLT32	rt_int_cmp-0x4
    54e0:	mov    $0x2,%r11d
    54e6:	test   %rax,%rax
    54e9:	cmovl  0x19af(%rip),%r11        # 6ea0 <botlish_fn_13+0x6668>
    54f1:	jmp    550b <botlish_fn_13+0x4cd3>
    54f6:	mov    $0x2,%r11d
    54fc:	mov    %r14,%rsi
    54ff:	cmp    $0x47,%rsi
    5503:	cmovl  0x1995(%rip),%r11        # 6ea0 <botlish_fn_13+0x6668>
    550b:	cmp    $0x6,%r11
    550f:	je     5520 <botlish_fn_13+0x4ce8>
    5515:	mov    $0xb,%r15d
    551b:	jmp    5533 <botlish_fn_13+0x4cfb>
    5520:	mov    0x328(%rsp),%r15
    5528:	jmp    5533 <botlish_fn_13+0x4cfb>
    552d:	mov    $0xb,%r15d
    5533:	mov    %r15,%rsi
    5536:	sar    $1,%rsi
    5539:	cmp    $0x2,%rsi
    553d:	jl     56e1 <botlish_fn_13+0x4ea9>
    5543:	cmp    $0x2,%rsi
    5547:	je     5668 <botlish_fn_13+0x4e30>
    554d:	cmp    $0x4,%rsi
    5551:	mov    %rsi,%r12
    5554:	je     5658 <botlish_fn_13+0x4e20>
    555a:	mov    %r14,%rsi
    555d:	test   $0x1,%rsi
    5564:	jne    5597 <botlish_fn_13+0x4d5f>
    556a:	mov    0x300(%rsp),%rdx
    5572:	mov    %r14,%rsi
    5575:	mov    0x280(%rsp),%rdi
    557d:	call   5582 <botlish_fn_13+0x4d4a>
			557e: R_X86_64_PLT32	rt_int_cmp-0x4
    5582:	mov    $0x2,%ecx
    5587:	test   %rax,%rax
    558a:	cmove  0x190e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5592:	jmp    55ab <botlish_fn_13+0x4d73>
    5597:	mov    $0x2,%ecx
    559c:	mov    %r14,%rsi
    559f:	cmp    $0xffffffffffffffff,%rsi
    55a3:	cmove  0x18f5(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    55ab:	cmp    $0x6,%rcx
    55af:	je     560d <botlish_fn_13+0x4dd5>
    55b5:	mov    %r12,%rsi
    55b8:	mov    0x280(%rsp),%rdi
    55c0:	call   55c5 <botlish_fn_13+0x4d8d>
			55c1: R_X86_64_PLT32	botlish_fn_7-0x4
    55c5:	mov    0x280(%rsp),%rdi
    55cd:	mov    0x10(%rdi),%rcx
    55d1:	mov    0x158(%rcx),%rdx
    55d8:	lea    0x228(%rsp),%r9
    55e0:	mov    %rax,0x228(%rsp)
    55e8:	mov    %r14,%rsi
    55eb:	mov    %rsi,0x230(%rsp)
    55f3:	mov    $0x1,%esi
    55f8:	mov    $0x5,%ecx
    55fd:	mov    $0x2,%r8d
    5603:	call   5608 <botlish_fn_13+0x4dd0>
			5604: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5608:	jmp    647b <botlish_fn_13+0x5c43>
    560d:	mov    %r12,%rsi
    5610:	mov    0x280(%rsp),%rdi
    5618:	call   561d <botlish_fn_13+0x4de5>
			5619: R_X86_64_PLT32	botlish_fn_7-0x4
    561d:	mov    0x280(%rsp),%rdi
    5625:	mov    0x10(%rdi),%rcx
    5629:	mov    0x150(%rcx),%rdx
    5630:	lea    0x220(%rsp),%r9
    5638:	mov    %rax,0x220(%rsp)
    5640:	mov    $0x2,%ecx
    5645:	mov    $0x1,%r8d
    564b:	mov    %rcx,%rsi
    564e:	call   5653 <botlish_fn_13+0x4e1b>
			564f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5653:	jmp    647b <botlish_fn_13+0x5c43>
    5658:	xor    %rax,%rax
    565b:	mov    0x2e0(%rsp),%r15
    5663:	jmp    5707 <botlish_fn_13+0x4ecf>
    5668:	mov    $0xfffffffffffffffd,%rsi
    566f:	mov    %rsi,%r14
    5672:	mov    %r14,%rsi
    5675:	test   $0x1,%rsi
    567c:	jne    56af <botlish_fn_13+0x4e77>
    5682:	mov    $0xfffffffffffffffd,%rdx
    5689:	mov    %r14,%rsi
    568c:	mov    0x280(%rsp),%rdi
    5694:	call   5699 <botlish_fn_13+0x4e61>
			5695: R_X86_64_PLT32	rt_int_cmp-0x4
    5699:	mov    $0x2,%r12d
    569f:	test   %rax,%rax
    56a2:	cmove  0x17f6(%rip),%r12        # 6ea0 <botlish_fn_13+0x6668>
    56aa:	jmp    56c4 <botlish_fn_13+0x4e8c>
    56af:	mov    $0x2,%r12d
    56b5:	mov    %r14,%rsi
    56b8:	cmp    $0xfffffffffffffffd,%rsi
    56bc:	cmove  0x17dc(%rip),%r12        # 6ea0 <botlish_fn_13+0x6668>
    56c4:	mov    %r12,0x80(%rsp)
    56cc:	mov    0x300(%rsp),%r14
    56d4:	mov    0x2e0(%rsp),%r15
    56dc:	jmp    6626 <botlish_fn_13+0x5dee>
    56e1:	mov    %r15,0x90(%rsp)
    56e9:	jmp    65e1 <botlish_fn_13+0x5da9>
    56ee:	mov    0x2d8(%rsp),%rcx
    56f6:	mov    %rsi,%r14
    56f9:	mov    0x298(%rsp),%r15
    5701:	mov    %rcx,%rax
    5704:	sar    $1,%rax
    5707:	cmp    $0x3,%rax
    570b:	jl     5ca8 <botlish_fn_13+0x5470>
    5711:	cmp    $0x4,%rax
    5715:	jl     5ad3 <botlish_fn_13+0x529b>
    571b:	cmp    $0x5,%rax
    571f:	jl     58fc <botlish_fn_13+0x50c4>
    5725:	mov    %r14,%rsi
    5728:	test   $0x1,%rsi
    572f:	jne    5760 <botlish_fn_13+0x4f28>
    5735:	mov    $0x83,%edx
    573a:	mov    %r14,%rsi
    573d:	mov    0x280(%rsp),%rdi
    5745:	call   574a <botlish_fn_13+0x4f12>
			5746: R_X86_64_PLT32	rt_int_cmp-0x4
    574a:	mov    $0x2,%r8d
    5750:	test   %rax,%rax
    5753:	cmovl  0x1745(%rip),%r8        # 6ea0 <botlish_fn_13+0x6668>
    575b:	jmp    5778 <botlish_fn_13+0x4f40>
    5760:	mov    $0x2,%r8d
    5766:	mov    %r14,%rsi
    5769:	cmp    $0x83,%rsi
    5770:	cmovl  0x1728(%rip),%r8        # 6ea0 <botlish_fn_13+0x6668>
    5778:	cmp    $0x6,%r8
    577c:	je     5873 <botlish_fn_13+0x503b>
    5782:	mov    %r14,%rsi
    5785:	test   $0x1,%rsi
    578c:	jne    57bc <botlish_fn_13+0x4f84>
    5792:	mov    $0xc3,%edx
    5797:	mov    %r14,%rsi
    579a:	mov    0x280(%rsp),%rdi
    57a2:	call   57a7 <botlish_fn_13+0x4f6f>
			57a3: R_X86_64_PLT32	rt_int_cmp-0x4
    57a7:	mov    $0x2,%ecx
    57ac:	test   %rax,%rax
    57af:	cmovl  0x16e9(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    57b7:	jmp    57d3 <botlish_fn_13+0x4f9b>
    57bc:	mov    $0x2,%ecx
    57c1:	mov    %r14,%rsi
    57c4:	cmp    $0xc3,%rsi
    57cb:	cmovl  0x16cd(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    57d3:	cmp    $0x6,%rcx
    57d7:	je     584c <botlish_fn_13+0x5014>
    57dd:	mov    %r14,%rsi
    57e0:	test   $0x1,%rsi
    57e7:	jne    5817 <botlish_fn_13+0x4fdf>
    57ed:	mov    $0xcf,%edx
    57f2:	mov    %r14,%rsi
    57f5:	mov    0x280(%rsp),%rdi
    57fd:	call   5802 <botlish_fn_13+0x4fca>
			57fe: R_X86_64_PLT32	rt_int_cmp-0x4
    5802:	mov    $0x2,%ecx
    5807:	test   %rax,%rax
    580a:	cmovl  0x168e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5812:	jmp    582e <botlish_fn_13+0x4ff6>
    5817:	mov    $0x2,%ecx
    581c:	mov    %r14,%rsi
    581f:	cmp    $0xcf,%rsi
    5826:	cmovl  0x1672(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    582e:	cmp    $0x6,%rcx
    5832:	je     5842 <botlish_fn_13+0x500a>
    5838:	mov    $0x1b,%ecx
    583d:	jmp    6365 <botlish_fn_13+0x5b2d>
    5842:	mov    $0xd,%ecx
    5847:	jmp    6365 <botlish_fn_13+0x5b2d>
    584c:	mov    %r14,%rsi
    584f:	mov    %rsi,%rax
    5852:	sar    $1,%rax
    5855:	cmp    $0x47,%rax
    5859:	jl     5869 <botlish_fn_13+0x5031>
    585f:	mov    $0x1b,%ecx
    5864:	jmp    6365 <botlish_fn_13+0x5b2d>
    5869:	mov    $0xd,%ecx
    586e:	jmp    6365 <botlish_fn_13+0x5b2d>
    5873:	mov    %r14,%rsi
    5876:	test   $0x1,%rsi
    587d:	jne    58ad <botlish_fn_13+0x5075>
    5883:	mov    $0x61,%edx
    5888:	mov    %r14,%rsi
    588b:	mov    0x280(%rsp),%rdi
    5893:	call   5898 <botlish_fn_13+0x5060>
			5894: R_X86_64_PLT32	rt_int_cmp-0x4
    5898:	mov    $0x2,%edx
    589d:	test   %rax,%rax
    58a0:	cmovl  0x15f8(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    58a8:	jmp    58c1 <botlish_fn_13+0x5089>
    58ad:	mov    $0x2,%edx
    58b2:	mov    %r14,%rsi
    58b5:	cmp    $0x61,%rsi
    58b9:	cmovl  0x15df(%rip),%rdx        # 6ea0 <botlish_fn_13+0x6668>
    58c1:	cmp    $0x6,%rdx
    58c5:	je     58f2 <botlish_fn_13+0x50ba>
    58cb:	mov    %r14,%rsi
    58ce:	mov    %rsi,%rax
    58d1:	sar    $1,%rax
    58d4:	cmp    $0x3a,%rax
    58d8:	jl     58e8 <botlish_fn_13+0x50b0>
    58de:	mov    $0x1b,%ecx
    58e3:	jmp    6365 <botlish_fn_13+0x5b2d>
    58e8:	mov    $0xd,%ecx
    58ed:	jmp    6365 <botlish_fn_13+0x5b2d>
    58f2:	mov    $0x1b,%ecx
    58f7:	jmp    6365 <botlish_fn_13+0x5b2d>
    58fc:	mov    %r14,%rsi
    58ff:	test   $0x1,%rsi
    5906:	jne    5936 <botlish_fn_13+0x50fe>
    590c:	mov    $0x83,%edx
    5911:	mov    %r14,%rsi
    5914:	mov    0x280(%rsp),%rdi
    591c:	call   5921 <botlish_fn_13+0x50e9>
			591d: R_X86_64_PLT32	rt_int_cmp-0x4
    5921:	mov    $0x2,%ecx
    5926:	test   %rax,%rax
    5929:	cmovl  0x156f(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5931:	jmp    594d <botlish_fn_13+0x5115>
    5936:	mov    $0x2,%ecx
    593b:	mov    %r14,%rsi
    593e:	cmp    $0x83,%rsi
    5945:	cmovl  0x1553(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    594d:	cmp    $0x6,%rcx
    5951:	je     5a48 <botlish_fn_13+0x5210>
    5957:	mov    %r14,%rsi
    595a:	test   $0x1,%rsi
    5961:	jne    5991 <botlish_fn_13+0x5159>
    5967:	mov    $0xc3,%edx
    596c:	mov    %r14,%rsi
    596f:	mov    0x280(%rsp),%rdi
    5977:	call   597c <botlish_fn_13+0x5144>
			5978: R_X86_64_PLT32	rt_int_cmp-0x4
    597c:	mov    $0x2,%ecx
    5981:	test   %rax,%rax
    5984:	cmovl  0x1514(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    598c:	jmp    59a8 <botlish_fn_13+0x5170>
    5991:	mov    $0x2,%ecx
    5996:	mov    %r14,%rsi
    5999:	cmp    $0xc3,%rsi
    59a0:	cmovl  0x14f8(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    59a8:	cmp    $0x6,%rcx
    59ac:	je     5a21 <botlish_fn_13+0x51e9>
    59b2:	mov    %r14,%rsi
    59b5:	test   $0x1,%rsi
    59bc:	jne    59ec <botlish_fn_13+0x51b4>
    59c2:	mov    $0xcf,%edx
    59c7:	mov    %r14,%rsi
    59ca:	mov    0x280(%rsp),%rdi
    59d2:	call   59d7 <botlish_fn_13+0x519f>
			59d3: R_X86_64_PLT32	rt_int_cmp-0x4
    59d7:	mov    $0x2,%ecx
    59dc:	test   %rax,%rax
    59df:	cmovl  0x14b9(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    59e7:	jmp    5a03 <botlish_fn_13+0x51cb>
    59ec:	mov    $0x2,%ecx
    59f1:	mov    %r14,%rsi
    59f4:	cmp    $0xcf,%rsi
    59fb:	cmovl  0x149d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5a03:	cmp    $0x6,%rcx
    5a07:	je     5a17 <botlish_fn_13+0x51df>
    5a0d:	mov    $0x19,%ecx
    5a12:	jmp    6365 <botlish_fn_13+0x5b2d>
    5a17:	mov    $0xb,%ecx
    5a1c:	jmp    6365 <botlish_fn_13+0x5b2d>
    5a21:	mov    %r14,%rsi
    5a24:	mov    %rsi,%r10
    5a27:	sar    $1,%r10
    5a2a:	cmp    $0x47,%r10
    5a2e:	jl     5a3e <botlish_fn_13+0x5206>
    5a34:	mov    $0x19,%ecx
    5a39:	jmp    6365 <botlish_fn_13+0x5b2d>
    5a3e:	mov    $0xb,%ecx
    5a43:	jmp    6365 <botlish_fn_13+0x5b2d>
    5a48:	mov    %r14,%rsi
    5a4b:	test   $0x1,%rsi
    5a52:	jne    5a83 <botlish_fn_13+0x524b>
    5a58:	mov    $0x61,%edx
    5a5d:	mov    %r14,%rsi
    5a60:	mov    0x280(%rsp),%rdi
    5a68:	call   5a6d <botlish_fn_13+0x5235>
			5a69: R_X86_64_PLT32	rt_int_cmp-0x4
    5a6d:	mov    $0x2,%r11d
    5a73:	test   %rax,%rax
    5a76:	cmovl  0x1422(%rip),%r11        # 6ea0 <botlish_fn_13+0x6668>
    5a7e:	jmp    5a98 <botlish_fn_13+0x5260>
    5a83:	mov    $0x2,%r11d
    5a89:	mov    %r14,%rsi
    5a8c:	cmp    $0x61,%rsi
    5a90:	cmovl  0x1408(%rip),%r11        # 6ea0 <botlish_fn_13+0x6668>
    5a98:	cmp    $0x6,%r11
    5a9c:	je     5ac9 <botlish_fn_13+0x5291>
    5aa2:	mov    %r14,%rsi
    5aa5:	mov    %rsi,%rax
    5aa8:	sar    $1,%rax
    5aab:	cmp    $0x3a,%rax
    5aaf:	jl     5abf <botlish_fn_13+0x5287>
    5ab5:	mov    $0x19,%ecx
    5aba:	jmp    6365 <botlish_fn_13+0x5b2d>
    5abf:	mov    $0xb,%ecx
    5ac4:	jmp    6365 <botlish_fn_13+0x5b2d>
    5ac9:	mov    $0x19,%ecx
    5ace:	jmp    6365 <botlish_fn_13+0x5b2d>
    5ad3:	mov    %r14,%rsi
    5ad6:	test   $0x1,%rsi
    5add:	jne    5b0d <botlish_fn_13+0x52d5>
    5ae3:	mov    $0x83,%edx
    5ae8:	mov    %r14,%rsi
    5aeb:	mov    0x280(%rsp),%rdi
    5af3:	call   5af8 <botlish_fn_13+0x52c0>
			5af4: R_X86_64_PLT32	rt_int_cmp-0x4
    5af8:	mov    $0x2,%ecx
    5afd:	test   %rax,%rax
    5b00:	cmovl  0x1398(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5b08:	jmp    5b24 <botlish_fn_13+0x52ec>
    5b0d:	mov    $0x2,%ecx
    5b12:	mov    %r14,%rsi
    5b15:	cmp    $0x83,%rsi
    5b1c:	cmovl  0x137c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5b24:	cmp    $0x6,%rcx
    5b28:	je     5c1f <botlish_fn_13+0x53e7>
    5b2e:	mov    %r14,%rsi
    5b31:	test   $0x1,%rsi
    5b38:	jne    5b68 <botlish_fn_13+0x5330>
    5b3e:	mov    $0xc3,%edx
    5b43:	mov    %r14,%rsi
    5b46:	mov    0x280(%rsp),%rdi
    5b4e:	call   5b53 <botlish_fn_13+0x531b>
			5b4f: R_X86_64_PLT32	rt_int_cmp-0x4
    5b53:	mov    $0x2,%ecx
    5b58:	test   %rax,%rax
    5b5b:	cmovl  0x133d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5b63:	jmp    5b7f <botlish_fn_13+0x5347>
    5b68:	mov    $0x2,%ecx
    5b6d:	mov    %r14,%rsi
    5b70:	cmp    $0xc3,%rsi
    5b77:	cmovl  0x1321(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5b7f:	cmp    $0x6,%rcx
    5b83:	je     5bf8 <botlish_fn_13+0x53c0>
    5b89:	mov    %r14,%rsi
    5b8c:	test   $0x1,%rsi
    5b93:	jne    5bc3 <botlish_fn_13+0x538b>
    5b99:	mov    $0xcf,%edx
    5b9e:	mov    %r14,%rsi
    5ba1:	mov    0x280(%rsp),%rdi
    5ba9:	call   5bae <botlish_fn_13+0x5376>
			5baa: R_X86_64_PLT32	rt_int_cmp-0x4
    5bae:	mov    $0x2,%ecx
    5bb3:	test   %rax,%rax
    5bb6:	cmovl  0x12e2(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5bbe:	jmp    5bda <botlish_fn_13+0x53a2>
    5bc3:	mov    $0x2,%ecx
    5bc8:	mov    %r14,%rsi
    5bcb:	cmp    $0xcf,%rsi
    5bd2:	cmovl  0x12c6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5bda:	cmp    $0x6,%rcx
    5bde:	je     5bee <botlish_fn_13+0x53b6>
    5be4:	mov    $0x17,%ecx
    5be9:	jmp    6365 <botlish_fn_13+0x5b2d>
    5bee:	mov    $0x9,%ecx
    5bf3:	jmp    6365 <botlish_fn_13+0x5b2d>
    5bf8:	mov    %r14,%rsi
    5bfb:	mov    %rsi,%rax
    5bfe:	sar    $1,%rax
    5c01:	cmp    $0x47,%rax
    5c05:	jl     5c15 <botlish_fn_13+0x53dd>
    5c0b:	mov    $0x17,%ecx
    5c10:	jmp    6365 <botlish_fn_13+0x5b2d>
    5c15:	mov    $0x9,%ecx
    5c1a:	jmp    6365 <botlish_fn_13+0x5b2d>
    5c1f:	mov    %r14,%rsi
    5c22:	test   $0x1,%rsi
    5c29:	jne    5c59 <botlish_fn_13+0x5421>
    5c2f:	mov    $0x61,%edx
    5c34:	mov    %r14,%rsi
    5c37:	mov    0x280(%rsp),%rdi
    5c3f:	call   5c44 <botlish_fn_13+0x540c>
			5c40: R_X86_64_PLT32	rt_int_cmp-0x4
    5c44:	mov    $0x2,%ecx
    5c49:	test   %rax,%rax
    5c4c:	cmovl  0x124c(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5c54:	jmp    5c6d <botlish_fn_13+0x5435>
    5c59:	mov    $0x2,%ecx
    5c5e:	mov    %r14,%rsi
    5c61:	cmp    $0x61,%rsi
    5c65:	cmovl  0x1233(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5c6d:	cmp    $0x6,%rcx
    5c71:	je     5c9e <botlish_fn_13+0x5466>
    5c77:	mov    %r14,%rsi
    5c7a:	mov    %rsi,%r11
    5c7d:	sar    $1,%r11
    5c80:	cmp    $0x3a,%r11
    5c84:	jl     5c94 <botlish_fn_13+0x545c>
    5c8a:	mov    $0x17,%ecx
    5c8f:	jmp    6365 <botlish_fn_13+0x5b2d>
    5c94:	mov    $0x9,%ecx
    5c99:	jmp    6365 <botlish_fn_13+0x5b2d>
    5c9e:	mov    $0x17,%ecx
    5ca3:	jmp    6365 <botlish_fn_13+0x5b2d>
    5ca8:	test   %rax,%rax
    5cab:	jle    6293 <botlish_fn_13+0x5a5b>
    5cb1:	cmp    $0x2,%rax
    5cb5:	jl     5e92 <botlish_fn_13+0x565a>
    5cbb:	mov    %r14,%rsi
    5cbe:	test   $0x1,%rsi
    5cc5:	jne    5cf5 <botlish_fn_13+0x54bd>
    5ccb:	mov    $0x83,%edx
    5cd0:	mov    %r14,%rsi
    5cd3:	mov    0x280(%rsp),%rdi
    5cdb:	call   5ce0 <botlish_fn_13+0x54a8>
			5cdc: R_X86_64_PLT32	rt_int_cmp-0x4
    5ce0:	mov    $0x2,%ecx
    5ce5:	test   %rax,%rax
    5ce8:	cmovl  0x11b0(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5cf0:	jmp    5d0c <botlish_fn_13+0x54d4>
    5cf5:	mov    $0x2,%ecx
    5cfa:	mov    %r14,%rsi
    5cfd:	cmp    $0x83,%rsi
    5d04:	cmovl  0x1194(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5d0c:	cmp    $0x6,%rcx
    5d10:	je     5e09 <botlish_fn_13+0x55d1>
    5d16:	mov    %r14,%rsi
    5d19:	test   $0x1,%rsi
    5d20:	jne    5d50 <botlish_fn_13+0x5518>
    5d26:	mov    $0xc3,%edx
    5d2b:	mov    %r14,%rsi
    5d2e:	mov    0x280(%rsp),%rdi
    5d36:	call   5d3b <botlish_fn_13+0x5503>
			5d37: R_X86_64_PLT32	rt_int_cmp-0x4
    5d3b:	mov    $0x2,%ecx
    5d40:	test   %rax,%rax
    5d43:	cmovl  0x1155(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5d4b:	jmp    5d67 <botlish_fn_13+0x552f>
    5d50:	mov    $0x2,%ecx
    5d55:	mov    %r14,%rsi
    5d58:	cmp    $0xc3,%rsi
    5d5f:	cmovl  0x1139(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5d67:	cmp    $0x6,%rcx
    5d6b:	je     5de2 <botlish_fn_13+0x55aa>
    5d71:	mov    %r14,%rsi
    5d74:	test   $0x1,%rsi
    5d7b:	jne    5dac <botlish_fn_13+0x5574>
    5d81:	mov    $0xcf,%edx
    5d86:	mov    %r14,%rsi
    5d89:	mov    0x280(%rsp),%rdi
    5d91:	call   5d96 <botlish_fn_13+0x555e>
			5d92: R_X86_64_PLT32	rt_int_cmp-0x4
    5d96:	mov    $0x2,%r10d
    5d9c:	test   %rax,%rax
    5d9f:	cmovl  0x10f9(%rip),%r10        # 6ea0 <botlish_fn_13+0x6668>
    5da7:	jmp    5dc4 <botlish_fn_13+0x558c>
    5dac:	mov    $0x2,%r10d
    5db2:	mov    %r14,%rsi
    5db5:	cmp    $0xcf,%rsi
    5dbc:	cmovl  0x10dc(%rip),%r10        # 6ea0 <botlish_fn_13+0x6668>
    5dc4:	cmp    $0x6,%r10
    5dc8:	je     5dd8 <botlish_fn_13+0x55a0>
    5dce:	mov    $0x15,%ecx
    5dd3:	jmp    6365 <botlish_fn_13+0x5b2d>
    5dd8:	mov    $0x7,%ecx
    5ddd:	jmp    6365 <botlish_fn_13+0x5b2d>
    5de2:	mov    %r14,%rsi
    5de5:	mov    %rsi,%rax
    5de8:	sar    $1,%rax
    5deb:	cmp    $0x47,%rax
    5def:	jl     5dff <botlish_fn_13+0x55c7>
    5df5:	mov    $0x15,%ecx
    5dfa:	jmp    6365 <botlish_fn_13+0x5b2d>
    5dff:	mov    $0x7,%ecx
    5e04:	jmp    6365 <botlish_fn_13+0x5b2d>
    5e09:	mov    %r14,%rsi
    5e0c:	test   $0x1,%rsi
    5e13:	jne    5e43 <botlish_fn_13+0x560b>
    5e19:	mov    $0x61,%edx
    5e1e:	mov    %r14,%rsi
    5e21:	mov    0x280(%rsp),%rdi
    5e29:	call   5e2e <botlish_fn_13+0x55f6>
			5e2a: R_X86_64_PLT32	rt_int_cmp-0x4
    5e2e:	mov    $0x2,%ecx
    5e33:	test   %rax,%rax
    5e36:	cmovl  0x1062(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5e3e:	jmp    5e57 <botlish_fn_13+0x561f>
    5e43:	mov    $0x2,%ecx
    5e48:	mov    %r14,%rsi
    5e4b:	cmp    $0x61,%rsi
    5e4f:	cmovl  0x1049(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5e57:	cmp    $0x6,%rcx
    5e5b:	je     5e88 <botlish_fn_13+0x5650>
    5e61:	mov    %r14,%rsi
    5e64:	mov    %rsi,%rdx
    5e67:	sar    $1,%rdx
    5e6a:	cmp    $0x3a,%rdx
    5e6e:	jl     5e7e <botlish_fn_13+0x5646>
    5e74:	mov    $0x15,%ecx
    5e79:	jmp    6365 <botlish_fn_13+0x5b2d>
    5e7e:	mov    $0x7,%ecx
    5e83:	jmp    6365 <botlish_fn_13+0x5b2d>
    5e88:	mov    $0x15,%ecx
    5e8d:	jmp    6365 <botlish_fn_13+0x5b2d>
    5e92:	mov    %r14,%rsi
    5e95:	test   $0x1,%rsi
    5e9c:	jne    5ecc <botlish_fn_13+0x5694>
    5ea2:	mov    $0xcd,%edx
    5ea7:	mov    %r14,%rsi
    5eaa:	mov    0x280(%rsp),%rdi
    5eb2:	call   5eb7 <botlish_fn_13+0x567f>
			5eb3: R_X86_64_PLT32	rt_int_cmp-0x4
    5eb7:	mov    $0x2,%ecx
    5ebc:	test   %rax,%rax
    5ebf:	cmovl  0xfd9(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5ec7:	jmp    5ee3 <botlish_fn_13+0x56ab>
    5ecc:	mov    $0x2,%ecx
    5ed1:	mov    %r14,%rsi
    5ed4:	cmp    $0xcd,%rsi
    5edb:	cmovl  0xfbd(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5ee3:	cmp    $0x6,%rcx
    5ee7:	je     60ed <botlish_fn_13+0x58b5>
    5eed:	mov    %r14,%rsi
    5ef0:	test   $0x1,%rsi
    5ef7:	jne    5f27 <botlish_fn_13+0x56ef>
    5efd:	mov    $0xe5,%edx
    5f02:	mov    %r14,%rsi
    5f05:	mov    0x280(%rsp),%rdi
    5f0d:	call   5f12 <botlish_fn_13+0x56da>
			5f0e: R_X86_64_PLT32	rt_int_cmp-0x4
    5f12:	mov    $0x2,%ecx
    5f17:	test   %rax,%rax
    5f1a:	cmovl  0xf7e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5f22:	jmp    5f3e <botlish_fn_13+0x5706>
    5f27:	mov    $0x2,%ecx
    5f2c:	mov    %r14,%rsi
    5f2f:	cmp    $0xe5,%rsi
    5f36:	cmovl  0xf62(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5f3e:	cmp    $0x6,%rcx
    5f42:	je     609e <botlish_fn_13+0x5866>
    5f48:	mov    %r14,%rsi
    5f4b:	test   $0x1,%rsi
    5f52:	jne    5f82 <botlish_fn_13+0x574a>
    5f58:	mov    $0xe9,%edx
    5f5d:	mov    %r14,%rsi
    5f60:	mov    0x280(%rsp),%rdi
    5f68:	call   5f6d <botlish_fn_13+0x5735>
			5f69: R_X86_64_PLT32	rt_int_cmp-0x4
    5f6d:	mov    $0x2,%ecx
    5f72:	test   %rax,%rax
    5f75:	cmovl  0xf23(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5f7d:	jmp    5f99 <botlish_fn_13+0x5761>
    5f82:	mov    $0x2,%ecx
    5f87:	mov    %r14,%rsi
    5f8a:	cmp    $0xe9,%rsi
    5f91:	cmovl  0xf07(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5f99:	cmp    $0x6,%rcx
    5f9d:	je     6077 <botlish_fn_13+0x583f>
    5fa3:	mov    %r14,%rsi
    5fa6:	test   $0x1,%rsi
    5fad:	jne    5fdd <botlish_fn_13+0x57a5>
    5fb3:	mov    $0xeb,%edx
    5fb8:	mov    %r14,%rsi
    5fbb:	mov    0x280(%rsp),%rdi
    5fc3:	call   5fc8 <botlish_fn_13+0x5790>
			5fc4: R_X86_64_PLT32	rt_int_cmp-0x4
    5fc8:	mov    $0x2,%ecx
    5fcd:	test   %rax,%rax
    5fd0:	cmovl  0xec8(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5fd8:	jmp    5ff4 <botlish_fn_13+0x57bc>
    5fdd:	mov    $0x2,%ecx
    5fe2:	mov    %r14,%rsi
    5fe5:	cmp    $0xeb,%rsi
    5fec:	cmovl  0xeac(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    5ff4:	cmp    $0x6,%rcx
    5ff8:	je     606d <botlish_fn_13+0x5835>
    5ffe:	mov    %r14,%rsi
    6001:	test   $0x1,%rsi
    6008:	jne    6038 <botlish_fn_13+0x5800>
    600e:	mov    $0xed,%edx
    6013:	mov    %r14,%rsi
    6016:	mov    0x280(%rsp),%rdi
    601e:	call   6023 <botlish_fn_13+0x57eb>
			601f: R_X86_64_PLT32	rt_int_cmp-0x4
    6023:	mov    $0x2,%ecx
    6028:	test   %rax,%rax
    602b:	cmovl  0xe6d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    6033:	jmp    604f <botlish_fn_13+0x5817>
    6038:	mov    $0x2,%ecx
    603d:	mov    %r14,%rsi
    6040:	cmp    $0xed,%rsi
    6047:	cmovl  0xe51(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    604f:	cmp    $0x6,%rcx
    6053:	je     6063 <botlish_fn_13+0x582b>
    6059:	mov    $0x13,%ecx
    605e:	jmp    6365 <botlish_fn_13+0x5b2d>
    6063:	mov    $0x5,%ecx
    6068:	jmp    6365 <botlish_fn_13+0x5b2d>
    606d:	mov    $0xd,%ecx
    6072:	jmp    6365 <botlish_fn_13+0x5b2d>
    6077:	mov    %r14,%rsi
    607a:	mov    %rsi,%rax
    607d:	sar    $1,%rax
    6080:	cmp    $0x73,%rax
    6084:	jl     6094 <botlish_fn_13+0x585c>
    608a:	mov    $0x13,%ecx
    608f:	jmp    6365 <botlish_fn_13+0x5b2d>
    6094:	mov    $0xd,%ecx
    6099:	jmp    6365 <botlish_fn_13+0x5b2d>
    609e:	mov    %r14,%rsi
    60a1:	mov    %rsi,%rax
    60a4:	sar    $1,%rax
    60a7:	cmp    $0x6e,%rax
    60ab:	jl     60cf <botlish_fn_13+0x5897>
    60b1:	cmp    $0x6f,%rax
    60b5:	jl     60c5 <botlish_fn_13+0x588d>
    60bb:	mov    $0x13,%ecx
    60c0:	jmp    6365 <botlish_fn_13+0x5b2d>
    60c5:	mov    $0xd,%ecx
    60ca:	jmp    6365 <botlish_fn_13+0x5b2d>
    60cf:	cmp    $0x67,%rax
    60d3:	jl     60e3 <botlish_fn_13+0x58ab>
    60d9:	mov    $0x13,%ecx
    60de:	jmp    6365 <botlish_fn_13+0x5b2d>
    60e3:	mov    $0xd,%ecx
    60e8:	jmp    6365 <botlish_fn_13+0x5b2d>
    60ed:	mov    %r14,%rsi
    60f0:	test   $0x1,%rsi
    60f7:	jne    6127 <botlish_fn_13+0x58ef>
    60fd:	mov    $0x61,%edx
    6102:	mov    %r14,%rsi
    6105:	mov    0x280(%rsp),%rdi
    610d:	call   6112 <botlish_fn_13+0x58da>
			610e: R_X86_64_PLT32	rt_int_cmp-0x4
    6112:	mov    $0x2,%ecx
    6117:	test   %rax,%rax
    611a:	cmovl  0xd7e(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    6122:	jmp    613b <botlish_fn_13+0x5903>
    6127:	mov    $0x2,%ecx
    612c:	mov    %r14,%rsi
    612f:	cmp    $0x61,%rsi
    6133:	cmovl  0xd65(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    613b:	cmp    $0x6,%rcx
    613f:	je     61a8 <botlish_fn_13+0x5970>
    6145:	mov    %r14,%rsi
    6148:	mov    %rsi,%rax
    614b:	sar    $1,%rax
    614e:	cmp    $0x5d,%rax
    6152:	jl     618a <botlish_fn_13+0x5952>
    6158:	cmp    $0x62,%rax
    615c:	jl     6180 <botlish_fn_13+0x5948>
    6162:	cmp    $0x63,%rax
    6166:	jl     6176 <botlish_fn_13+0x593e>
    616c:	mov    $0x13,%ecx
    6171:	jmp    6365 <botlish_fn_13+0x5b2d>
    6176:	mov    $0xd,%ecx
    617b:	jmp    6365 <botlish_fn_13+0x5b2d>
    6180:	mov    $0x13,%ecx
    6185:	jmp    6365 <botlish_fn_13+0x5b2d>
    618a:	cmp    $0x5c,%rax
    618e:	jl     619e <botlish_fn_13+0x5966>
    6194:	mov    $0xd,%ecx
    6199:	jmp    6365 <botlish_fn_13+0x5b2d>
    619e:	mov    $0x13,%ecx
    61a3:	jmp    6365 <botlish_fn_13+0x5b2d>
    61a8:	mov    %r14,%rsi
    61ab:	test   $0x1,%rsi
    61b2:	jne    61e2 <botlish_fn_13+0x59aa>
    61b8:	mov    $0x47,%edx
    61bd:	mov    %r14,%rsi
    61c0:	mov    0x280(%rsp),%rdi
    61c8:	call   61cd <botlish_fn_13+0x5995>
			61c9: R_X86_64_PLT32	rt_int_cmp-0x4
    61cd:	mov    $0x2,%ecx
    61d2:	test   %rax,%rax
    61d5:	cmovl  0xcc3(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    61dd:	jmp    61f6 <botlish_fn_13+0x59be>
    61e2:	mov    $0x2,%ecx
    61e7:	mov    %r14,%rsi
    61ea:	cmp    $0x47,%rsi
    61ee:	cmovl  0xcaa(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    61f6:	cmp    $0x6,%rcx
    61fa:	je     6227 <botlish_fn_13+0x59ef>
    6200:	mov    %r14,%rsi
    6203:	mov    %rsi,%rax
    6206:	sar    $1,%rax
    6209:	cmp    $0x2f,%rax
    620d:	jl     621d <botlish_fn_13+0x59e5>
    6213:	mov    $0xd,%ecx
    6218:	jmp    6365 <botlish_fn_13+0x5b2d>
    621d:	mov    $0x13,%ecx
    6222:	jmp    6365 <botlish_fn_13+0x5b2d>
    6227:	mov    %r14,%rsi
    622a:	test   $0x1,%rsi
    6231:	jne    6261 <botlish_fn_13+0x5a29>
    6237:	mov    $0x45,%edx
    623c:	mov    %r14,%rsi
    623f:	mov    0x280(%rsp),%rdi
    6247:	call   624c <botlish_fn_13+0x5a14>
			6248: R_X86_64_PLT32	rt_int_cmp-0x4
    624c:	mov    $0x2,%ecx
    6251:	test   %rax,%rax
    6254:	cmovl  0xc44(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    625c:	jmp    6275 <botlish_fn_13+0x5a3d>
    6261:	mov    $0x2,%ecx
    6266:	mov    %r14,%rsi
    6269:	cmp    $0x45,%rsi
    626d:	cmovl  0xc2b(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    6275:	cmp    $0x6,%rcx
    6279:	je     6289 <botlish_fn_13+0x5a51>
    627f:	mov    $0xd,%ecx
    6284:	jmp    6365 <botlish_fn_13+0x5b2d>
    6289:	mov    $0x13,%ecx
    628e:	jmp    6365 <botlish_fn_13+0x5b2d>
    6293:	mov    %r14,%rsi
    6296:	test   $0x1,%rsi
    629d:	jne    62cd <botlish_fn_13+0x5a95>
    62a3:	mov    $0xb9,%edx
    62a8:	mov    %r14,%rsi
    62ab:	mov    0x280(%rsp),%rdi
    62b3:	call   62b8 <botlish_fn_13+0x5a80>
			62b4: R_X86_64_PLT32	rt_int_cmp-0x4
    62b8:	mov    $0x2,%ecx
    62bd:	test   %rax,%rax
    62c0:	cmovl  0xbd8(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    62c8:	jmp    62e4 <botlish_fn_13+0x5aac>
    62cd:	mov    $0x2,%ecx
    62d2:	mov    %r14,%rsi
    62d5:	cmp    $0xb9,%rsi
    62dc:	cmovl  0xbbc(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    62e4:	cmp    $0x6,%rcx
    62e8:	je     6360 <botlish_fn_13+0x5b28>
    62ee:	mov    %r14,%rsi
    62f1:	test   $0x1,%rsi
    62f8:	jne    6328 <botlish_fn_13+0x5af0>
    62fe:	mov    $0xbb,%edx
    6303:	mov    %r14,%rsi
    6306:	mov    0x280(%rsp),%rdi
    630e:	call   6313 <botlish_fn_13+0x5adb>
			630f: R_X86_64_PLT32	rt_int_cmp-0x4
    6313:	mov    $0x2,%ecx
    6318:	test   %rax,%rax
    631b:	cmovl  0xb7d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    6323:	jmp    633f <botlish_fn_13+0x5b07>
    6328:	mov    $0x2,%ecx
    632d:	mov    %r14,%rsi
    6330:	cmp    $0xbb,%rsi
    6337:	cmovl  0xb61(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    633f:	cmp    $0x6,%rcx
    6343:	je     6353 <botlish_fn_13+0x5b1b>
    6349:	mov    $0x11,%ecx
    634e:	jmp    6365 <botlish_fn_13+0x5b2d>
    6353:	mov    0x328(%rsp),%rcx
    635b:	jmp    6365 <botlish_fn_13+0x5b2d>
    6360:	mov    $0x11,%ecx
    6365:	mov    %rcx,%rsi
    6368:	sar    $1,%rsi
    636b:	cmp    $0x6,%rsi
    636f:	jl     65fe <botlish_fn_13+0x5dc6>
    6375:	cmp    $0x6,%rsi
    6379:	mov    %rsi,%r12
    637c:	je     65cd <botlish_fn_13+0x5d95>
    6382:	mov    %r14,%rsi
    6385:	test   $0x1,%rsi
    638c:	jne    63bf <botlish_fn_13+0x5b87>
    6392:	mov    0x300(%rsp),%rdx
    639a:	mov    %r14,%rsi
    639d:	mov    0x280(%rsp),%rdi
    63a5:	call   63aa <botlish_fn_13+0x5b72>
			63a6: R_X86_64_PLT32	rt_int_cmp-0x4
    63aa:	mov    $0x2,%ecx
    63af:	test   %rax,%rax
    63b2:	cmove  0xae6(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    63ba:	jmp    63d3 <botlish_fn_13+0x5b9b>
    63bf:	mov    $0x2,%ecx
    63c4:	mov    %r14,%rsi
    63c7:	cmp    $0xffffffffffffffff,%rsi
    63cb:	cmove  0xacd(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    63d3:	cmp    $0x6,%rcx
    63d7:	je     6435 <botlish_fn_13+0x5bfd>
    63dd:	mov    %r12,%rsi
    63e0:	mov    0x280(%rsp),%rdi
    63e8:	call   63ed <botlish_fn_13+0x5bb5>
			63e9: R_X86_64_PLT32	botlish_fn_5-0x4
    63ed:	mov    0x280(%rsp),%rdi
    63f5:	mov    0x10(%rdi),%rcx
    63f9:	mov    0x158(%rcx),%rdx
    6400:	lea    0x210(%rsp),%r9
    6408:	mov    %rax,0x210(%rsp)
    6410:	mov    %r14,%rsi
    6413:	mov    %rsi,0x218(%rsp)
    641b:	mov    $0x1,%esi
    6420:	mov    $0x5,%ecx
    6425:	mov    $0x2,%r8d
    642b:	call   6430 <botlish_fn_13+0x5bf8>
			642c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6430:	jmp    647b <botlish_fn_13+0x5c43>
    6435:	mov    %r12,%rsi
    6438:	mov    0x280(%rsp),%rdi
    6440:	call   6445 <botlish_fn_13+0x5c0d>
			6441: R_X86_64_PLT32	botlish_fn_5-0x4
    6445:	mov    0x280(%rsp),%rdi
    644d:	mov    0x10(%rdi),%rcx
    6451:	mov    0x150(%rcx),%rdx
    6458:	lea    0x208(%rsp),%r9
    6460:	mov    %rax,0x208(%rsp)
    6468:	mov    $0x2,%ecx
    646d:	mov    $0x1,%r8d
    6473:	mov    %rcx,%rsi
    6476:	call   647b <botlish_fn_13+0x5c43>
			6477: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    647b:	mov    0x280(%rsp),%rdi
    6483:	call   6488 <botlish_fn_13+0x5c50>
			6484: R_X86_64_PLT32	rt_co_failed-0x4
    6488:	mov    %rax,0x88(%rsp)
    6490:	mov    %rax,%rsi
    6493:	mov    0x280(%rsp),%rdi
    649b:	call   64a0 <botlish_fn_13+0x5c68>
			649c: R_X86_64_PLT32	rt_co_resume0-0x4
    64a0:	test   %rax,%rax
    64a3:	je     64c5 <botlish_fn_13+0x5c8d>
    64a9:	mov    0x280(%rsp),%rdi
    64b1:	mov    0x10(%rdi),%rax
    64b5:	mov    0x50(%rax),%rsi
    64b9:	mov    0x130(%rax),%rdx
    64c0:	call   64c5 <botlish_fn_13+0x5c8d>
			64c1: R_X86_64_PLT32	rt_raise-0x4
    64c5:	mov    0x280(%rsp),%rdi
    64cd:	call   64d2 <botlish_fn_13+0x5c9a>
			64ce: R_X86_64_PLT32	rt_declared_error-0x4
    64d2:	cmp    $0x1,%rax
    64d6:	je     6553 <botlish_fn_13+0x5d1b>
    64dc:	mov    0x280(%rsp),%rdi
    64e4:	call   64e9 <botlish_fn_13+0x5cb1>
			64e5: R_X86_64_PLT32	rt_declared_error-0x4
    64e9:	cmp    $0x2,%rax
    64ed:	jne    6c28 <botlish_fn_13+0x63f0>
    64f3:	xor    %rsi,%rsi
    64f6:	mov    0x280(%rsp),%rdi
    64fe:	call   6503 <botlish_fn_13+0x5ccb>
			64ff: R_X86_64_PLT32	rt_declared_payload-0x4
    6503:	mov    %rax,%rbx
    6506:	mov    0x280(%rsp),%rdi
    650e:	call   6513 <botlish_fn_13+0x5cdb>
			650f: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6513:	mov    0x280(%rsp),%rdi
    651b:	mov    0x10(%rdi),%rax
    651f:	mov    0x140(%rax),%rdx
    6526:	lea    0xe8(%rsp),%r9
    652e:	mov    %rbx,%rax
    6531:	mov    %rax,0xe8(%rsp)
    6539:	mov    $0x5,%esi
    653e:	mov    $0x2,%ecx
    6543:	mov    $0x1,%r8d
    6549:	call   654e <botlish_fn_13+0x5d16>
			654a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    654e:	jmp    6c28 <botlish_fn_13+0x63f0>
    6553:	xor    %rsi,%rsi
    6556:	mov    0x280(%rsp),%rdi
    655e:	call   6563 <botlish_fn_13+0x5d2b>
			655f: R_X86_64_PLT32	rt_declared_payload-0x4
    6563:	mov    %rax,%rbx
    6566:	mov    0x280(%rsp),%rdi
    656e:	call   6573 <botlish_fn_13+0x5d3b>
			656f: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6573:	mov    0x318(%rsp),%r11
    657b:	mov    0x10(%r11),%rax
    657f:	mov    (%rax),%rcx
    6582:	mov    0x280(%rsp),%rdi
    658a:	mov    0x10(%rdi),%rax
    658e:	mov    0x138(%rax),%rdx
    6595:	lea    0xd8(%rsp),%r9
    659d:	mov    %rcx,0xd8(%rsp)
    65a5:	mov    %rbx,%rax
    65a8:	mov    %rax,0xe0(%rsp)
    65b0:	mov    $0x1,%ecx
    65b5:	mov    $0x2,%r8d
    65bb:	mov    0x2f8(%rsp),%rsi
    65c3:	call   65c8 <botlish_fn_13+0x5d90>
			65c4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    65c8:	jmp    6c28 <botlish_fn_13+0x63f0>
    65cd:	movq   $0x3,0x90(%rsp)
    65d9:	mov    0x328(%rsp),%r15
    65e1:	mov    $0x6,%r12d
    65e7:	movq   $0x6,0x80(%rsp)
    65f3:	mov    $0x2,%r14d
    65f9:	jmp    6626 <botlish_fn_13+0x5dee>
    65fe:	mov    %rcx,0x98(%rsp)
    6606:	mov    $0x6,%r12d
    660c:	movq   $0x6,0x80(%rsp)
    6618:	mov    $0x1,%r14d
    661e:	mov    %rcx,0x2d8(%rsp)
    6626:	mov    0x308(%rsp),%rax
    662e:	mov    0x18(%rax),%rdi
    6632:	test   %rdi,%rdi
    6635:	je     6e1c <botlish_fn_13+0x65e4>
    663b:	mov    0x308(%rsp),%rax
    6643:	mov    0x10(%rax),%r10
    6647:	mov    %r12,(%r10)
    664a:	mov    0x308(%rsp),%rdx
    6652:	mov    %r15,0x298(%rsp)
    665a:	jmp    2232 <botlish_fn_13+0x19fa>
    665f:	mov    0x280(%rsp),%rdi
    6667:	mov    0x10(%rdi),%rax
    666b:	mov    0x148(%rax),%rdx
    6672:	lea    0xc8(%rsp),%r9
    667a:	mov    0x2f0(%rsp),%rcx
    6682:	mov    %rcx,0xc8(%rsp)
    668a:	mov    0x290(%rsp),%rax
    6692:	mov    %rax,0xd0(%rsp)
    669a:	mov    $0x8,%esi
    669f:	mov    $0x2,%r8d
    66a5:	mov    0x328(%rsp),%rcx
    66ad:	call   66b2 <botlish_fn_13+0x5e7a>
			66ae: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    66b2:	jmp    6c28 <botlish_fn_13+0x63f0>
    66b7:	movq   $0x1,0x28(%rsp)
    66c0:	mov    0x310(%rsp),%r12
    66c8:	mov    0x10(%r12),%rax
    66cd:	mov    (%rax),%rsi
    66d0:	mov    %rsi,0x30(%rsp)
    66d5:	movq   $0x3,0x38(%rsp)
    66de:	test   $0x1,%rsi
    66e5:	je     66fd <botlish_fn_13+0x5ec5>
    66eb:	mov    %rsi,%rcx
    66ee:	add    $0x2,%rcx
    66f2:	seto   %al
    66f5:	test   %al,%al
    66f7:	je     6715 <botlish_fn_13+0x5edd>
    66fd:	mov    0x328(%rsp),%rdx
    6705:	mov    0x280(%rsp),%rdi
    670d:	call   6712 <botlish_fn_13+0x5eda>
			670e: R_X86_64_PLT32	rt_int_add-0x4
    6712:	mov    %rax,%rcx
    6715:	mov    0x18(%r12),%rax
    671a:	test   %rax,%rax
    671d:	je     6e3e <botlish_fn_13+0x6606>
    6723:	mov    0x10(%r12),%rax
    6728:	mov    %rcx,(%rax)
    672b:	mov    0x320(%rsp),%rcx
    6733:	mov    %r12,0x310(%rsp)
    673b:	jmp    ed0 <botlish_fn_13+0x698>
    6740:	mov    0x310(%rsp),%r12
    6748:	mov    0x10(%r12),%rax
    674d:	mov    (%rax),%rax
    6750:	mov    %rax,(%rsp)
    6754:	mov    0x318(%rsp),%r11
    675c:	mov    0x10(%r11),%rcx
    6760:	mov    (%rcx),%rdx
    6763:	mov    %rdx,0x8(%rsp)
    6768:	lea    0xf0(%rsp),%rcx
    6770:	mov    %rax,0xf0(%rsp)
    6778:	mov    %rdx,0xf8(%rsp)
    6780:	xor    %rsi,%rsi
    6783:	mov    $0x2,%edx
    6788:	mov    0x280(%rsp),%rdi
    6790:	call   6795 <botlish_fn_13+0x5f5d>
			6791: R_X86_64_PLT32	rt_struct_new-0x4
    6795:	mov    0x340(%rsp),%rbx
    679d:	mov    0x348(%rsp),%r12
    67a5:	mov    0x350(%rsp),%r13
    67ad:	mov    0x358(%rsp),%r14
    67b5:	mov    0x360(%rsp),%r15
    67bd:	add    $0x370,%rsp
    67c4:	mov    %rbp,%rsp
    67c7:	pop    %rbp
    67c8:	ret
    67c9:	mov    0x310(%rsp),%r12
    67d1:	movq   $0x1,0x28(%rsp)
    67da:	mov    0x318(%rsp),%r11
    67e2:	mov    0x10(%r11),%rax
    67e6:	mov    (%rax),%rsi
    67e9:	mov    %rsi,0x30(%rsp)
    67ee:	movq   $0x3,0x38(%rsp)
    67f7:	test   $0x1,%rsi
    67fe:	je     6823 <botlish_fn_13+0x5feb>
    6804:	mov    %rsi,%rcx
    6807:	add    $0x2,%rcx
    680b:	seto   %al
    680e:	test   %al,%al
    6810:	jne    6823 <botlish_fn_13+0x5feb>
    6816:	mov    0x318(%rsp),%r11
    681e:	jmp    6843 <botlish_fn_13+0x600b>
    6823:	mov    0x328(%rsp),%rdx
    682b:	mov    0x280(%rsp),%rdi
    6833:	call   6838 <botlish_fn_13+0x6000>
			6834: R_X86_64_PLT32	rt_int_add-0x4
    6838:	mov    %rax,%rcx
    683b:	mov    0x318(%rsp),%r11
    6843:	mov    0x318(%rsp),%r11
    684b:	mov    0x18(%r11),%rax
    684f:	test   %rax,%rax
    6852:	je     6e58 <botlish_fn_13+0x6620>
    6858:	mov    0x318(%rsp),%r11
    6860:	mov    0x10(%r11),%rax
    6864:	mov    %rcx,(%rax)
    6867:	movq   $0x1,0x28(%rsp)
    6870:	mov    0x2a0(%rsp),%rbx
    6878:	cmp    $0x1,%rbx
    687c:	je     6896 <botlish_fn_13+0x605e>
    6882:	mov    $0xa,%esi
    6887:	cmp    $0xffffffffffffffff,%rbx
    688b:	je     6d6b <botlish_fn_13+0x6533>
    6891:	jmp    6bb5 <botlish_fn_13+0x637d>
    6896:	movq   $0xa,0x38(%rsp)
    689f:	lea    0x130(%rsp),%rcx
    68a7:	movq   $0x0,0x130(%rsp)
    68b3:	mov    0x2a8(%rsp),%rax
    68bb:	mov    %rax,0x138(%rsp)
    68c3:	movq   $0x2,0x140(%rsp)
    68cf:	movq   $0xa,0x148(%rsp)
    68db:	mov    0x2f8(%rsp),%rdx
    68e3:	mov    0x328(%rsp),%rsi
    68eb:	mov    0x280(%rsp),%rdi
    68f3:	call   68f8 <botlish_fn_13+0x60c0>
			68f4: R_X86_64_PLT32	rt_construct-0x4
    68f8:	mov    %rax,%rcx
    68fb:	mov    %rax,0x2a8(%rsp)
    6903:	test   %rcx,%rax
    6906:	je     6b97 <botlish_fn_13+0x635f>
    690c:	mov    0x2a8(%rsp),%rax
    6914:	mov    %rax,0x78(%rsp)
    6919:	mov    0x2b8(%rsp),%rax
    6921:	add    $0x1,%rax
    6928:	mov    %rax,0x2b8(%rsp)
    6930:	lea    0x150(%rsp),%rbx
    6938:	mov    0x2c0(%rsp),%rdx
    6940:	cmp    %rdx,%rax
    6943:	jl     6cb1 <botlish_fn_13+0x6479>
    6949:	movq   $0x0,0x150(%rsp)
    6955:	mov    0x2a8(%rsp),%rax
    695d:	mov    %rax,0x158(%rsp)
    6965:	mov    $0x1,%esi
    696a:	mov    $0x2,%edx
    696f:	mov    %rbx,%rcx
    6972:	mov    0x280(%rsp),%rdi
    697a:	call   697f <botlish_fn_13+0x6147>
			697b: R_X86_64_PLT32	rt_construct-0x4
    697f:	test   %rax,%rax
    6982:	je     6b97 <botlish_fn_13+0x635f>
    6988:	movq   $0x3,0x38(%rsp)
    6991:	mov    0x2d0(%rsp),%rsi
    6999:	test   $0x1,%rsi
    69a0:	jne    69b3 <botlish_fn_13+0x617b>
    69a6:	mov    0x2d0(%rsp),%rsi
    69ae:	jmp    69ea <botlish_fn_13+0x61b2>
    69b3:	mov    0x2d0(%rsp),%rsi
    69bb:	mov    %rsi,%rcx
    69be:	add    $0x2,%rcx
    69c2:	seto   %al
    69c5:	test   %al,%al
    69c7:	je     69da <botlish_fn_13+0x61a2>
    69cd:	mov    0x2d0(%rsp),%rsi
    69d5:	jmp    69ea <botlish_fn_13+0x61b2>
    69da:	mov    %rcx,%rsi
    69dd:	mov    %rcx,0x2d0(%rsp)
    69e5:	jmp    6a0a <botlish_fn_13+0x61d2>
    69ea:	mov    0x328(%rsp),%rdx
    69f2:	mov    0x280(%rsp),%rdi
    69fa:	call   69ff <botlish_fn_13+0x61c7>
			69fb: R_X86_64_PLT32	rt_int_add-0x4
    69ff:	mov    %rax,%rsi
    6a02:	mov    %rax,0x2d0(%rsp)
    6a0a:	mov    %rsi,0x68(%rsp)
    6a0f:	mov    0x330(%rsp),%rcx
    6a17:	mov    0x2d0(%rsp),%rsi
    6a1f:	mov    %rsi,%rax
    6a22:	and    %rcx,%rax
    6a25:	test   $0x1,%rax
    6a2b:	jne    6a63 <botlish_fn_13+0x622b>
    6a31:	mov    0x330(%rsp),%rdx
    6a39:	mov    0x2d0(%rsp),%rsi
    6a41:	mov    0x280(%rsp),%rdi
    6a49:	call   6a4e <botlish_fn_13+0x6216>
			6a4a: R_X86_64_PLT32	rt_int_cmp-0x4
    6a4e:	mov    $0x2,%ecx
    6a53:	test   %rax,%rax
    6a56:	cmovl  0x442(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    6a5e:	jmp    6a83 <botlish_fn_13+0x624b>
    6a63:	mov    $0x2,%ecx
    6a68:	mov    0x330(%rsp),%rax
    6a70:	mov    0x2d0(%rsp),%rsi
    6a78:	cmp    %rax,%rsi
    6a7b:	cmovl  0x41d(%rip),%rcx        # 6ea0 <botlish_fn_13+0x6668>
    6a83:	cmp    $0x6,%rcx
    6a87:	je     6ac9 <botlish_fn_13+0x6291>
    6a8d:	movq   $0xffffffffffffffff,0x48(%rsp)
    6a96:	mov    $0xa,%eax
    6a9b:	mov    %rax,0x2a8(%rsp)
    6aa3:	movq   $0xa,0x78(%rsp)
    6aac:	mov    0x300(%rsp),%rbx
    6ab4:	mov    0x300(%rsp),%rax
    6abc:	mov    %rax,0x2b0(%rsp)
    6ac4:	jmp    6d6b <botlish_fn_13+0x6533>
    6ac9:	mov    0x2d0(%rsp),%rsi
    6ad1:	test   $0x1,%rsi
    6ad8:	je     6b01 <botlish_fn_13+0x62c9>
    6ade:	mov    0x288(%rsp),%rcx
    6ae6:	mov    0x8(%rcx),%rax
    6aea:	mov    0x2d0(%rsp),%rsi
    6af2:	mov    %rsi,%rcx
    6af5:	sar    $1,%rcx
    6af8:	cmp    %rax,%rcx
    6afb:	jb     6b3f <botlish_fn_13+0x6307>
    6b01:	mov    0x2d0(%rsp),%rdx
    6b09:	mov    0x288(%rsp),%rsi
    6b11:	mov    0x280(%rsp),%rdi
    6b19:	call   6b1e <botlish_fn_13+0x62e6>
			6b1a: R_X86_64_PLT32	rt_list_get-0x4
    6b1e:	mov    %rax,%rcx
    6b21:	mov    %rax,0x2c8(%rsp)
    6b29:	test   %rcx,%rax
    6b2c:	je     6b97 <botlish_fn_13+0x635f>
    6b32:	mov    0x2c8(%rsp),%rax
    6b3a:	jmp    6b57 <botlish_fn_13+0x631f>
    6b3f:	mov    0x288(%rsp),%rax
    6b47:	mov    0x10(%rax),%rax
    6b4b:	mov    (%rax,%rcx,8),%rax
    6b4f:	mov    %rax,0x2c8(%rsp)
    6b57:	mov    %rax,0x70(%rsp)
    6b5c:	mov    0x2c8(%rsp),%rax
    6b64:	mov    0x8(%rax),%rdx
    6b68:	mov    %rdx,0x2c0(%rsp)
    6b70:	xor    %rdx,%rdx
    6b73:	mov    0x280(%rsp),%rdi
    6b7b:	mov    %rdx,%rsi
    6b7e:	call   6b83 <botlish_fn_13+0x634b>
			6b7f: R_X86_64_PLT32	rt_list_new-0x4
    6b83:	mov    %rax,%rcx
    6b86:	mov    %rax,0x2a8(%rsp)
    6b8e:	test   %rcx,%rax
    6b91:	jne    6c5f <botlish_fn_13+0x6427>
    6b97:	mov    0x280(%rsp),%rdi
    6b9f:	call   6ba4 <botlish_fn_13+0x636c>
			6ba0: R_X86_64_PLT32	rt_co_failed-0x4
    6ba4:	mov    %rax,0x50(%rsp)
    6ba9:	movq   $0xa,0x78(%rsp)
    6bb2:	mov    %rax,%rsi
    6bb5:	mov    0x280(%rsp),%rdi
    6bbd:	call   6bc2 <botlish_fn_13+0x638a>
			6bbe: R_X86_64_PLT32	rt_co_resume0-0x4
    6bc2:	test   %rax,%rax
    6bc5:	je     6be7 <botlish_fn_13+0x63af>
    6bcb:	mov    0x280(%rsp),%rdi
    6bd3:	mov    0x10(%rdi),%r8
    6bd7:	mov    0x50(%r8),%rsi
    6bdb:	mov    0x130(%r8),%rdx
    6be2:	call   6be7 <botlish_fn_13+0x63af>
			6be3: R_X86_64_PLT32	rt_raise-0x4
    6be7:	mov    0x280(%rsp),%rdi
    6bef:	call   6bf4 <botlish_fn_13+0x63bc>
			6bf0: R_X86_64_PLT32	rt_declared_error-0x4
    6bf4:	cmp    $0x40000001,%rax
    6bfa:	je     6c0d <botlish_fn_13+0x63d5>
    6c00:	mov    0x280(%rsp),%rdi
    6c08:	jmp    6c15 <botlish_fn_13+0x63dd>
    6c0d:	mov    0x280(%rsp),%rdi
    6c15:	mov    0x280(%rsp),%rdi
    6c1d:	call   6c22 <botlish_fn_13+0x63ea>
			6c1e: R_X86_64_PLT32	rt_declared_error-0x4
    6c22:	cmp    $0x40000001,%rax
    6c28:	xor    %rax,%rax
    6c2b:	mov    0x340(%rsp),%rbx
    6c33:	mov    0x348(%rsp),%r12
    6c3b:	mov    0x350(%rsp),%r13
    6c43:	mov    0x358(%rsp),%r14
    6c4b:	mov    0x360(%rsp),%r15
    6c53:	add    $0x370,%rsp
    6c5a:	mov    %rbp,%rsp
    6c5d:	pop    %rbp
    6c5e:	ret
    6c5f:	mov    0x2a8(%rsp),%rax
    6c67:	mov    %rax,0x78(%rsp)
    6c6c:	mov    %rax,%rsi
    6c6f:	mov    %rax,0x2b8(%rsp)
    6c77:	xor    %rsi,%rax
    6c7a:	mov    0x2c0(%rsp),%rdx
    6c82:	mov    %rax,0x2b8(%rsp)
    6c8a:	shl    $1,%rdx
    6c8d:	mov    %rdx,0x2c0(%rsp)
    6c95:	or     $0x1,%rdx
    6c99:	mov    %rdx,0x2c0(%rsp)
    6ca1:	sar    $1,%rdx
    6ca4:	mov    %rdx,0x2c0(%rsp)
    6cac:	jmp    6940 <botlish_fn_13+0x6108>
    6cb1:	mov    0x2c8(%rsp),%rax
    6cb9:	movzbq 0x18(%rax),%rax
    6cbe:	test   %rax,%rax
    6cc1:	jne    6cfb <botlish_fn_13+0x64c3>
    6cc7:	mov    0x2b8(%rsp),%rax
    6ccf:	mov    %rax,%rdx
    6cd2:	shl    $1,%rdx
    6cd5:	or     $0x1,%rdx
    6cd9:	mov    0x2c8(%rsp),%rsi
    6ce1:	mov    0x280(%rsp),%rdi
    6ce9:	call   6cee <botlish_fn_13+0x64b6>
			6cea: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    6cee:	mov    %rax,0x2b0(%rsp)
    6cf6:	jmp    6d3e <botlish_fn_13+0x6506>
    6cfb:	mov    0x2b8(%rsp),%rax
    6d03:	mov    %rax,%rcx
    6d06:	shl    $1,%rcx
    6d09:	or     $0x1,%rcx
    6d0d:	sar    $1,%rcx
    6d10:	mov    0x2c8(%rsp),%rax
    6d18:	movzbq 0x19(%rax,%rcx,1),%rax
    6d1e:	mov    %rax,0x2b0(%rsp)
    6d26:	shl    $0x3,%rax
    6d2a:	mov    %rax,0x2b0(%rsp)
    6d32:	or     $0x4,%rax
    6d36:	mov    %rax,0x2b0(%rsp)
    6d3e:	shr    $0x3,%rax
    6d42:	mov    %rax,0x2b0(%rsp)
    6d4a:	mov    $0x1,%ebx
    6d4f:	shl    $1,%rax
    6d52:	mov    %rax,0x2b0(%rsp)
    6d5a:	or     $0x1,%rax
    6d5e:	mov    %rax,0x2b0(%rsp)
    6d66:	mov    %rax,0x48(%rsp)
    6d6b:	mov    0x320(%rsp),%rcx
    6d73:	mov    0x18(%rcx),%rax
    6d77:	test   %rax,%rax
    6d7a:	je     6e77 <botlish_fn_13+0x663f>
    6d80:	mov    0x320(%rsp),%rcx
    6d88:	mov    0x10(%rcx),%rax
    6d8c:	mov    0x2b0(%rsp),%rcx
    6d94:	mov    %rcx,(%rax)
    6d97:	mov    0x320(%rsp),%rcx
    6d9f:	mov    %rbx,0x2a0(%rsp)
    6da7:	mov    %r12,0x310(%rsp)
    6daf:	jmp    ed0 <botlish_fn_13+0x698>
    6db4:	mov    $0x1,%edx
    6db9:	mov    %r12,%rcx
    6dbc:	mov    0x308(%rsp),%rsi
    6dc4:	mov    0x280(%rsp),%rdi
    6dcc:	call   6dd1 <botlish_fn_13+0x6599>
			6dcd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6dd1:	jmp    221a <botlish_fn_13+0x19e2>
    6dd6:	mov    $0x1,%edx
    6ddb:	mov    0x318(%rsp),%rsi
    6de3:	mov    0x280(%rsp),%rdi
    6deb:	call   6df0 <botlish_fn_13+0x65b8>
			6dec: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6df0:	jmp    22e1 <botlish_fn_13+0x1aa9>
    6df5:	mov    $0x1,%edx
    6dfa:	mov    0x2b0(%rsp),%rcx
    6e02:	mov    0x320(%rsp),%rsi
    6e0a:	mov    0x280(%rsp),%rdi
    6e12:	call   6e17 <botlish_fn_13+0x65df>
			6e13: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e17:	jmp    27f7 <botlish_fn_13+0x1fbf>
    6e1c:	mov    $0x1,%edx
    6e21:	mov    %r12,%rcx
    6e24:	mov    0x308(%rsp),%rsi
    6e2c:	mov    0x280(%rsp),%rdi
    6e34:	call   6e39 <botlish_fn_13+0x6601>
			6e35: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e39:	jmp    664a <botlish_fn_13+0x5e12>
    6e3e:	mov    $0x1,%edx
    6e43:	mov    %r12,%rsi
    6e46:	mov    0x280(%rsp),%rdi
    6e4e:	call   6e53 <botlish_fn_13+0x661b>
			6e4f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e53:	jmp    672b <botlish_fn_13+0x5ef3>
    6e58:	mov    $0x1,%edx
    6e5d:	mov    0x318(%rsp),%rsi
    6e65:	mov    0x280(%rsp),%rdi
    6e6d:	call   6e72 <botlish_fn_13+0x663a>
			6e6e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e72:	jmp    6867 <botlish_fn_13+0x602f>
    6e77:	mov    $0x1,%edx
    6e7c:	mov    0x2b0(%rsp),%rcx
    6e84:	mov    0x320(%rsp),%rsi
    6e8c:	mov    0x280(%rsp),%rdi
    6e94:	call   6e99 <botlish_fn_13+0x6661>
			6e95: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e99:	jmp    6d97 <botlish_fn_13+0x655f>
    6e9e:	add    %al,(%rax)
    6ea0:	(bad)
    6ea1:	add    %al,(%rax)
    6ea3:	add    %al,(%rax)
    6ea5:	add    %al,(%rax)
	...

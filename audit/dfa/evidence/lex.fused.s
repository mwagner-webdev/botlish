<botlish_fn_13>:
     838:	push   %rbp
     839:	mov    %rsp,%rbp
     83c:	sub    $0x2c0,%rsp
     843:	mov    %rbx,0x290(%rsp)
     84b:	mov    %r12,0x298(%rsp)
     853:	mov    %r13,0x2a0(%rsp)
     85b:	mov    %r14,0x2a8(%rsp)
     863:	mov    %r15,0x2b0(%rsp)
     86b:	mov    %rdi,0x1e8(%rsp)
     873:	movq   $0x0,0x8(%rsp)
     87c:	movq   $0x0,0x10(%rsp)
     885:	movq   $0x0,0x18(%rsp)
     88e:	movq   $0x0,0x20(%rsp)
     897:	movq   $0x0,0x28(%rsp)
     8a0:	movq   $0x0,0x30(%rsp)
     8a9:	movq   $0x0,0x38(%rsp)
     8b2:	movq   $0x0,0x40(%rsp)
     8bb:	movq   $0x0,0x78(%rsp)
     8c4:	movq   $0x0,0x80(%rsp)
     8d0:	movq   $0x0,0x88(%rsp)
     8dc:	movq   $0x0,0x90(%rsp)
     8e8:	movq   $0x0,0x98(%rsp)
     8f4:	movq   $0x0,0xa0(%rsp)
     900:	mov    %rdx,(%rsp)
     904:	mov    %rdx,0x1f8(%rsp)
     90c:	movq   $0xa,0x58(%rsp)
     915:	movq   $0xa,0x60(%rsp)
     91e:	movq   $0xa,0x68(%rsp)
     927:	movq   $0xa,0x70(%rsp)
     930:	movq   $0xa,0x48(%rsp)
     939:	movq   $0xa,0x50(%rsp)
     942:	mov    %rsi,0x58(%rsp)
     947:	mov    %rsi,0x1f0(%rsp)
     94f:	mov    0x1f0(%rsp),%rsi
     957:	mov    0x1e8(%rsp),%rdi
     95f:	call   964 <botlish_fn_13+0x12c>
			960: R_X86_64_PLT32	rt_list_len-0x4
     964:	mov    %rax,0x60(%rsp)
     969:	mov    %rax,0x288(%rsp)
     971:	mov    $0x1,%esi
     976:	mov    %rsi,0x230(%rsp)
     97e:	movq   $0x1,0x68(%rsp)
     987:	xor    %rax,%rax
     98a:	mov    %rax,0x218(%rsp)
     992:	mov    $0xa,%eax
     997:	mov    %rax,0x228(%rsp)
     99f:	mov    0x288(%rsp),%rbx
     9a7:	mov    0x218(%rsp),%rax
     9af:	mov    %rax,0x220(%rsp)
     9b7:	mov    %rsi,%rax
     9ba:	and    %rbx,%rax
     9bd:	mov    %rsi,0x230(%rsp)
     9c5:	test   $0x1,%rax
     9cb:	jne    a06 <botlish_fn_13+0x1ce>
     9d1:	mov    %rbx,%rdx
     9d4:	mov    0x230(%rsp),%rsi
     9dc:	mov    0x1e8(%rsp),%rdi
     9e4:	call   9e9 <botlish_fn_13+0x1b1>
			9e5: R_X86_64_PLT32	rt_int_cmp-0x4
     9e9:	mov    %rbx,0x288(%rsp)
     9f1:	mov    $0x2,%esi
     9f6:	test   %rax,%rax
     9f9:	cmovl  0x6197(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
     a01:	jmp    a2e <botlish_fn_13+0x1f6>
     a06:	mov    %rbx,0x288(%rsp)
     a0e:	mov    $0x2,%esi
     a13:	mov    0x230(%rsp),%rax
     a1b:	mov    0x288(%rsp),%rcx
     a23:	cmp    %rcx,%rax
     a26:	cmovl  0x616a(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
     a2e:	cmp    $0x6,%rsi
     a32:	je     a65 <botlish_fn_13+0x22d>
     a38:	mov    $0xffffffffffffffff,%rax
     a3f:	mov    %rax,0x210(%rsp)
     a47:	movq   $0xffffffffffffffff,0x48(%rsp)
     a50:	mov    0x210(%rsp),%rcx
     a58:	mov    %rcx,0x208(%rsp)
     a60:	jmp    ce3 <botlish_fn_13+0x4ab>
     a65:	mov    0x230(%rsp),%rsi
     a6d:	test   $0x1,%rsi
     a74:	je     a9d <botlish_fn_13+0x265>
     a7a:	mov    0x1f0(%rsp),%rsi
     a82:	mov    0x8(%rsi),%rcx
     a86:	mov    0x230(%rsp),%rsi
     a8e:	mov    %rsi,%rax
     a91:	sar    $1,%rax
     a94:	cmp    %rcx,%rax
     a97:	jb     b55 <botlish_fn_13+0x31d>
     a9d:	mov    0x230(%rsp),%rdx
     aa5:	mov    0x1f0(%rsp),%rsi
     aad:	mov    0x1e8(%rsp),%rdi
     ab5:	call   aba <botlish_fn_13+0x282>
			ab6: R_X86_64_PLT32	rt_list_get-0x4
     aba:	mov    %rax,%rcx
     abd:	mov    %rax,0x228(%rsp)
     ac5:	test   %rcx,%rax
     ac8:	jne    b48 <botlish_fn_13+0x310>
     ace:	mov    0x1e8(%rsp),%rdi
     ad6:	call   adb <botlish_fn_13+0x2a3>
			ad7: R_X86_64_PLT32	rt_co_failed-0x4
     adb:	mov    %rax,0x50(%rsp)
     ae0:	mov    %rax,%rsi
     ae3:	mov    0x1e8(%rsp),%rdi
     aeb:	call   af0 <botlish_fn_13+0x2b8>
			aec: R_X86_64_PLT32	rt_co_resume0-0x4
     af0:	test   %rax,%rax
     af3:	jne    b06 <botlish_fn_13+0x2ce>
     af9:	mov    0x1e8(%rsp),%rdi
     b01:	jmp    b2a <botlish_fn_13+0x2f2>
     b06:	mov    0x1e8(%rsp),%rdi
     b0e:	mov    0x10(%rdi),%rax
     b12:	mov    0x50(%rax),%rsi
     b16:	mov    0x130(%rax),%rdx
     b1d:	call   b22 <botlish_fn_13+0x2ea>
			b1e: R_X86_64_PLT32	rt_raise-0x4
     b22:	mov    0x1e8(%rsp),%rdi
     b2a:	mov    0x1e8(%rsp),%rdi
     b32:	call   b37 <botlish_fn_13+0x2ff>
			b33: R_X86_64_PLT32	rt_declared_error-0x4
     b37:	cmp    $0x40000001,%rax
     b3d:	jne    68f3 <botlish_fn_13+0x60bb>
     b43:	jmp    68f3 <botlish_fn_13+0x60bb>
     b48:	mov    0x228(%rsp),%rax
     b50:	jmp    b6d <botlish_fn_13+0x335>
     b55:	mov    0x1f0(%rsp),%rsi
     b5d:	mov    0x10(%rsi),%rcx
     b61:	mov    (%rcx,%rax,8),%rax
     b65:	mov    %rax,0x228(%rsp)
     b6d:	mov    %rax,0x70(%rsp)
     b72:	mov    0x228(%rsp),%rax
     b7a:	mov    0x8(%rax),%r11
     b7e:	shl    $1,%r11
     b81:	or     $0x1,%r11
     b85:	sar    $1,%r11
     b88:	test   %r11,%r11
     b8b:	mov    %r11,0x220(%rsp)
     b93:	jg     c39 <botlish_fn_13+0x401>
     b99:	mov    $0x3,%edx
     b9e:	movq   $0x3,0x38(%rsp)
     ba7:	mov    0x230(%rsp),%rsi
     baf:	test   $0x1,%rsi
     bb6:	jne    bc9 <botlish_fn_13+0x391>
     bbc:	mov    0x230(%rsp),%rsi
     bc4:	jmp    bfc <botlish_fn_13+0x3c4>
     bc9:	mov    0x230(%rsp),%rsi
     bd1:	add    $0x2,%rsi
     bd5:	seto   %dil
     bd9:	test   %dil,%dil
     bdc:	je     bef <botlish_fn_13+0x3b7>
     be2:	mov    0x230(%rsp),%rsi
     bea:	jmp    bfc <botlish_fn_13+0x3c4>
     bef:	mov    %rsi,0x230(%rsp)
     bf7:	jmp    c14 <botlish_fn_13+0x3dc>
     bfc:	mov    0x1e8(%rsp),%rdi
     c04:	call   c09 <botlish_fn_13+0x3d1>
			c05: R_X86_64_PLT32	rt_int_add-0x4
     c09:	mov    %rax,%rsi
     c0c:	mov    %rax,0x230(%rsp)
     c14:	mov    %rsi,0x68(%rsp)
     c19:	xor    %rcx,%rcx
     c1c:	mov    0x288(%rsp),%rbx
     c24:	mov    0x230(%rsp),%rsi
     c2c:	mov    %rcx,0x218(%rsp)
     c34:	jmp    9b7 <botlish_fn_13+0x17f>
     c39:	mov    0x228(%rsp),%rax
     c41:	movzbq 0x18(%rax),%rax
     c46:	test   %rax,%rax
     c49:	jne    c76 <botlish_fn_13+0x43e>
     c4f:	mov    $0x1,%edx
     c54:	mov    0x228(%rsp),%rsi
     c5c:	mov    0x1e8(%rsp),%rdi
     c64:	call   c69 <botlish_fn_13+0x431>
			c65: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     c69:	mov    %rax,0x210(%rsp)
     c71:	jmp    ca3 <botlish_fn_13+0x46b>
     c76:	mov    0x228(%rsp),%rax
     c7e:	movzbq 0x19(%rax),%rax
     c83:	mov    %rax,0x210(%rsp)
     c8b:	shl    $0x3,%rax
     c8f:	mov    %rax,0x210(%rsp)
     c97:	or     $0x4,%rax
     c9b:	mov    %rax,0x210(%rsp)
     ca3:	shr    $0x3,%rax
     ca7:	mov    %rax,0x210(%rsp)
     caf:	mov    $0x1,%ecx
     cb4:	mov    %rcx,0x208(%rsp)
     cbc:	shl    $1,%rax
     cbf:	mov    %rax,0x210(%rsp)
     cc7:	or     $0x1,%rax
     ccb:	mov    %rax,0x210(%rsp)
     cd3:	mov    %rax,0x48(%rsp)
     cd8:	xor    %rcx,%rcx
     cdb:	mov    %rcx,0x218(%rsp)
     ce3:	mov    %rax,0x8(%rsp)
     ce8:	mov    $0x3,%ebx
     ced:	movq   $0x3,0x10(%rsp)
     cf6:	mov    0x210(%rsp),%rdx
     cfe:	mov    %rbx,%rsi
     d01:	mov    0x1e8(%rsp),%rdi
     d09:	call   d0e <botlish_fn_13+0x4d6>
			d0a: R_X86_64_PLT32	rt_mutarray_create-0x4
     d0e:	mov    %rax,%rcx
     d11:	mov    %rbx,0x280(%rsp)
     d19:	test   %rcx,%rcx
     d1c:	je     68f3 <botlish_fn_13+0x60bb>
     d22:	mov    %rcx,0x8(%rsp)
     d27:	mov    %rcx,0x278(%rsp)
     d2f:	movq   $0x3,0x10(%rsp)
     d38:	mov    $0x1,%edx
     d3d:	movq   $0x1,0x18(%rsp)
     d46:	mov    0x280(%rsp),%rsi
     d4e:	mov    0x1e8(%rsp),%rdi
     d56:	call   d5b <botlish_fn_13+0x523>
			d57: R_X86_64_PLT32	rt_mutarray_create-0x4
     d5b:	mov    %rax,%rcx
     d5e:	test   %rcx,%rcx
     d61:	je     68f3 <botlish_fn_13+0x60bb>
     d67:	mov    %rcx,0x10(%rsp)
     d6c:	mov    %rcx,0x270(%rsp)
     d74:	movq   $0x3,0x18(%rsp)
     d7d:	mov    $0x1,%edx
     d82:	movq   $0x1,0x20(%rsp)
     d8b:	mov    0x280(%rsp),%rsi
     d93:	mov    0x1e8(%rsp),%rdi
     d9b:	call   da0 <botlish_fn_13+0x568>
			d9c: R_X86_64_PLT32	rt_mutarray_create-0x4
     da0:	mov    %rax,%rcx
     da3:	test   %rcx,%rcx
     da6:	je     68f3 <botlish_fn_13+0x60bb>
     dac:	mov    %rcx,0x18(%rsp)
     db1:	mov    %rcx,0x268(%rsp)
     db9:	movq   $0x3,0x20(%rsp)
     dc2:	mov    $0x2,%edx
     dc7:	movq   $0x2,0x28(%rsp)
     dd0:	mov    0x280(%rsp),%rsi
     dd8:	mov    0x1e8(%rsp),%rdi
     de0:	call   de5 <botlish_fn_13+0x5ad>
			de1: R_X86_64_PLT32	rt_mutarray_create-0x4
     de5:	mov    %rax,%rbx
     de8:	test   %rbx,%rbx
     deb:	mov    %rbx,0x260(%rsp)
     df3:	je     68f3 <botlish_fn_13+0x60bb>
     df9:	mov    0x260(%rsp),%rbx
     e01:	mov    %rbx,0x20(%rsp)
     e06:	mov    $0xffffffffffffffff,%rdx
     e0d:	mov    %rdx,0x258(%rsp)
     e15:	mov    $0x4,%esi
     e1a:	mov    %rsi,0x250(%rsp)
     e22:	mov    0x278(%rsp),%rcx
     e2a:	mov    0x10(%rcx),%rax
     e2e:	mov    (%rax),%rsi
     e31:	mov    %rsi,%r14
     e34:	mov    %r14,%rsi
     e37:	mov    0x1e8(%rsp),%rdi
     e3f:	call   e44 <botlish_fn_13+0x60c>
			e40: R_X86_64_PLT32	botlish_fn_11-0x4
     e44:	cmp    $0x6,%rax
     e48:	je     65e2 <botlish_fn_13+0x5daa>
     e4e:	mov    %r14,%rsi
     e51:	test   $0x1,%rsi
     e58:	jne    e8c <botlish_fn_13+0x654>
     e5e:	mov    0x258(%rsp),%rdx
     e66:	mov    %r14,%rsi
     e69:	mov    0x1e8(%rsp),%rdi
     e71:	call   e76 <botlish_fn_13+0x63e>
			e72: R_X86_64_PLT32	rt_int_cmp-0x4
     e76:	mov    $0x2,%r10d
     e7c:	test   %rax,%rax
     e7f:	cmove  0x5d11(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
     e87:	jmp    ea1 <botlish_fn_13+0x669>
     e8c:	mov    $0x2,%r10d
     e92:	mov    %r14,%rsi
     e95:	cmp    $0xffffffffffffffff,%rsi
     e99:	cmove  0x5cf7(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
     ea1:	cmp    $0x6,%r10
     ea5:	je     655a <botlish_fn_13+0x5d22>
     eab:	mov    0x270(%rsp),%rcx
     eb3:	mov    0x10(%rcx),%rax
     eb7:	mov    (%rax),%rcx
     eba:	mov    %rcx,0x28(%rsp)
     ebf:	mov    %rcx,0x248(%rsp)
     ec7:	movq   $0xa,0x88(%rsp)
     ed3:	movq   $0xa,0x90(%rsp)
     edf:	movq   $0xa,0x98(%rsp)
     eeb:	movq   $0xa,0xa0(%rsp)
     ef7:	movq   $0xa,0x78(%rsp)
     f00:	movq   $0xa,0x80(%rsp)
     f0c:	mov    %r14,%rsi
     f0f:	test   $0x1,%rsi
     f16:	jne    f46 <botlish_fn_13+0x70e>
     f1c:	mov    $0xbb,%edx
     f21:	mov    %r14,%rsi
     f24:	mov    0x1e8(%rsp),%rdi
     f2c:	call   f31 <botlish_fn_13+0x6f9>
			f2d: R_X86_64_PLT32	rt_int_cmp-0x4
     f31:	mov    $0x2,%ecx
     f36:	test   %rax,%rax
     f39:	cmovl  0x5c57(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
     f41:	jmp    f5d <botlish_fn_13+0x725>
     f46:	mov    $0x2,%ecx
     f4b:	mov    %r14,%rsi
     f4e:	cmp    $0xbb,%rsi
     f55:	cmovl  0x5c3b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
     f5d:	cmp    $0x6,%rcx
     f61:	je     11ac <botlish_fn_13+0x974>
     f67:	mov    %r14,%rsi
     f6a:	test   $0x1,%rsi
     f71:	jne    fa1 <botlish_fn_13+0x769>
     f77:	mov    $0xe9,%edx
     f7c:	mov    %r14,%rsi
     f7f:	mov    0x1e8(%rsp),%rdi
     f87:	call   f8c <botlish_fn_13+0x754>
			f88: R_X86_64_PLT32	rt_int_cmp-0x4
     f8c:	mov    $0x2,%ecx
     f91:	test   %rax,%rax
     f94:	cmovl  0x5bfc(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
     f9c:	jmp    fb8 <botlish_fn_13+0x780>
     fa1:	mov    $0x2,%ecx
     fa6:	mov    %r14,%rsi
     fa9:	cmp    $0xe9,%rsi
     fb0:	cmovl  0x5be0(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
     fb8:	cmp    $0x6,%rcx
     fbc:	je     1132 <botlish_fn_13+0x8fa>
     fc2:	mov    %r14,%rsi
     fc5:	test   $0x1,%rsi
     fcc:	jne    ffc <botlish_fn_13+0x7c4>
     fd2:	mov    $0xf9,%edx
     fd7:	mov    %r14,%rsi
     fda:	mov    0x1e8(%rsp),%rdi
     fe2:	call   fe7 <botlish_fn_13+0x7af>
			fe3: R_X86_64_PLT32	rt_int_cmp-0x4
     fe7:	mov    $0x2,%ecx
     fec:	test   %rax,%rax
     fef:	cmovl  0x5ba1(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
     ff7:	jmp    1013 <botlish_fn_13+0x7db>
     ffc:	mov    $0x2,%ecx
    1001:	mov    %r14,%rsi
    1004:	cmp    $0xf9,%rsi
    100b:	cmovl  0x5b85(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1013:	cmp    $0x6,%rcx
    1017:	je     10f4 <botlish_fn_13+0x8bc>
    101d:	mov    %r14,%rsi
    1020:	test   $0x1,%rsi
    1027:	jne    1057 <botlish_fn_13+0x81f>
    102d:	mov    $0xfb,%edx
    1032:	mov    %r14,%rsi
    1035:	mov    0x1e8(%rsp),%rdi
    103d:	call   1042 <botlish_fn_13+0x80a>
			103e: R_X86_64_PLT32	rt_int_cmp-0x4
    1042:	mov    $0x2,%ecx
    1047:	test   %rax,%rax
    104a:	cmovl  0x5b46(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1052:	jmp    106e <botlish_fn_13+0x836>
    1057:	mov    $0x2,%ecx
    105c:	mov    %r14,%rsi
    105f:	cmp    $0xfb,%rsi
    1066:	cmovl  0x5b2a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    106e:	cmp    $0x6,%rcx
    1072:	je     10ea <botlish_fn_13+0x8b2>
    1078:	mov    %r14,%rsi
    107b:	test   $0x1,%rsi
    1082:	jne    10b2 <botlish_fn_13+0x87a>
    1088:	mov    $0xfd,%edx
    108d:	mov    %r14,%rsi
    1090:	mov    0x1e8(%rsp),%rdi
    1098:	call   109d <botlish_fn_13+0x865>
			1099: R_X86_64_PLT32	rt_int_cmp-0x4
    109d:	mov    $0x2,%ecx
    10a2:	test   %rax,%rax
    10a5:	cmovl  0x5aeb(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    10ad:	jmp    10c9 <botlish_fn_13+0x891>
    10b2:	mov    $0x2,%ecx
    10b7:	mov    %r14,%rsi
    10ba:	cmp    $0xfd,%rsi
    10c1:	cmovl  0x5acf(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    10c9:	cmp    $0x6,%rcx
    10cd:	je     10dd <botlish_fn_13+0x8a5>
    10d3:	mov    $0xd,%esi
    10d8:	jmp    137e <botlish_fn_13+0xb46>
    10dd:	mov    0x280(%rsp),%rsi
    10e5:	jmp    137e <botlish_fn_13+0xb46>
    10ea:	mov    $0xd,%esi
    10ef:	jmp    137e <botlish_fn_13+0xb46>
    10f4:	mov    %r14,%rsi
    10f7:	mov    %rsi,%rax
    10fa:	sar    $1,%rax
    10fd:	cmp    $0x75,%rax
    1101:	jl     1128 <botlish_fn_13+0x8f0>
    1107:	cmp    $0x7b,%rax
    110b:	jl     111e <botlish_fn_13+0x8e6>
    1111:	mov    0x280(%rsp),%rsi
    1119:	jmp    137e <botlish_fn_13+0xb46>
    111e:	mov    $0xd,%esi
    1123:	jmp    137e <botlish_fn_13+0xb46>
    1128:	mov    $0xb,%esi
    112d:	jmp    137e <botlish_fn_13+0xb46>
    1132:	mov    %r14,%rsi
    1135:	mov    %rsi,%rax
    1138:	sar    $1,%rax
    113b:	cmp    $0x67,%rax
    113f:	jl     1177 <botlish_fn_13+0x93f>
    1145:	cmp    $0x6e,%rax
    1149:	jl     116d <botlish_fn_13+0x935>
    114f:	cmp    $0x6f,%rax
    1153:	jl     1163 <botlish_fn_13+0x92b>
    1159:	mov    $0xd,%esi
    115e:	jmp    137e <botlish_fn_13+0xb46>
    1163:	mov    $0xb,%esi
    1168:	jmp    137e <botlish_fn_13+0xb46>
    116d:	mov    $0xd,%esi
    1172:	jmp    137e <botlish_fn_13+0xb46>
    1177:	cmp    $0x5e,%rax
    117b:	jl     119f <botlish_fn_13+0x967>
    1181:	cmp    $0x66,%rax
    1185:	jl     1195 <botlish_fn_13+0x95d>
    118b:	mov    $0xb,%esi
    1190:	jmp    137e <botlish_fn_13+0xb46>
    1195:	mov    $0xd,%esi
    119a:	jmp    137e <botlish_fn_13+0xb46>
    119f:	mov    0x280(%rsp),%rsi
    11a7:	jmp    137e <botlish_fn_13+0xb46>
    11ac:	mov    %r14,%rsi
    11af:	test   $0x1,%rsi
    11b6:	jne    11e6 <botlish_fn_13+0x9ae>
    11bc:	mov    $0x5d,%edx
    11c1:	mov    %r14,%rsi
    11c4:	mov    0x1e8(%rsp),%rdi
    11cc:	call   11d1 <botlish_fn_13+0x999>
			11cd: R_X86_64_PLT32	rt_int_cmp-0x4
    11d1:	mov    $0x2,%ecx
    11d6:	test   %rax,%rax
    11d9:	cmovl  0x59b7(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    11e1:	jmp    11fa <botlish_fn_13+0x9c2>
    11e6:	mov    $0x2,%ecx
    11eb:	mov    %r14,%rsi
    11ee:	cmp    $0x5d,%rsi
    11f2:	cmovl  0x599e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    11fa:	cmp    $0x6,%rcx
    11fe:	je     1281 <botlish_fn_13+0xa49>
    1204:	mov    %r14,%rsi
    1207:	mov    %rsi,%rax
    120a:	sar    $1,%rax
    120d:	cmp    $0x3b,%rax
    1211:	jl     124c <botlish_fn_13+0xa14>
    1217:	cmp    $0x5b,%rax
    121b:	jl     1242 <botlish_fn_13+0xa0a>
    1221:	cmp    $0x5c,%rax
    1225:	jl     1235 <botlish_fn_13+0x9fd>
    122b:	mov    $0xd,%esi
    1230:	jmp    137e <botlish_fn_13+0xb46>
    1235:	mov    0x280(%rsp),%rsi
    123d:	jmp    137e <botlish_fn_13+0xb46>
    1242:	mov    $0xd,%esi
    1247:	jmp    137e <botlish_fn_13+0xb46>
    124c:	cmp    $0x30,%rax
    1250:	jl     1277 <botlish_fn_13+0xa3f>
    1256:	cmp    $0x3a,%rax
    125a:	jl     126d <botlish_fn_13+0xa35>
    1260:	mov    0x280(%rsp),%rsi
    1268:	jmp    137e <botlish_fn_13+0xb46>
    126d:	mov    $0x9,%esi
    1272:	jmp    137e <botlish_fn_13+0xb46>
    1277:	mov    $0xd,%esi
    127c:	jmp    137e <botlish_fn_13+0xb46>
    1281:	mov    %r14,%rsi
    1284:	test   $0x1,%rsi
    128b:	jne    12bb <botlish_fn_13+0xa83>
    1291:	mov    $0x47,%edx
    1296:	mov    %r14,%rsi
    1299:	mov    0x1e8(%rsp),%rdi
    12a1:	call   12a6 <botlish_fn_13+0xa6e>
			12a2: R_X86_64_PLT32	rt_int_cmp-0x4
    12a6:	mov    $0x2,%edx
    12ab:	test   %rax,%rax
    12ae:	cmovl  0x58e2(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    12b6:	jmp    12cf <botlish_fn_13+0xa97>
    12bb:	mov    $0x2,%edx
    12c0:	mov    %r14,%rsi
    12c3:	cmp    $0x47,%rsi
    12c7:	cmovl  0x58c9(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    12cf:	cmp    $0x6,%rdx
    12d3:	je     1317 <botlish_fn_13+0xadf>
    12d9:	mov    %r14,%rsi
    12dc:	mov    %rsi,%rax
    12df:	sar    $1,%rax
    12e2:	cmp    $0x2c,%rax
    12e6:	jl     130d <botlish_fn_13+0xad5>
    12ec:	cmp    $0x2d,%rax
    12f0:	jl     1300 <botlish_fn_13+0xac8>
    12f6:	mov    $0x9,%esi
    12fb:	jmp    137e <botlish_fn_13+0xb46>
    1300:	mov    0x280(%rsp),%rsi
    1308:	jmp    137e <botlish_fn_13+0xb46>
    130d:	mov    $0xd,%esi
    1312:	jmp    137e <botlish_fn_13+0xb46>
    1317:	mov    %r14,%rsi
    131a:	test   $0x1,%rsi
    1321:	jne    1351 <botlish_fn_13+0xb19>
    1327:	mov    $0x45,%edx
    132c:	mov    %r14,%rsi
    132f:	mov    0x1e8(%rsp),%rdi
    1337:	call   133c <botlish_fn_13+0xb04>
			1338: R_X86_64_PLT32	rt_int_cmp-0x4
    133c:	mov    $0x2,%ecx
    1341:	test   %rax,%rax
    1344:	cmovl  0x584c(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    134c:	jmp    1365 <botlish_fn_13+0xb2d>
    1351:	mov    $0x2,%ecx
    1356:	mov    %r14,%rsi
    1359:	cmp    $0x45,%rsi
    135d:	cmovl  0x5833(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1365:	cmp    $0x6,%rcx
    1369:	je     1379 <botlish_fn_13+0xb41>
    136f:	mov    $0x7,%esi
    1374:	jmp    137e <botlish_fn_13+0xb46>
    1379:	mov    $0xd,%esi
    137e:	sar    $1,%rsi
    1381:	cmp    $0x1,%rsi
    1385:	je     209f <botlish_fn_13+0x1867>
    138b:	cmp    $0x3,%rsi
    138f:	je     1ace <botlish_fn_13+0x1296>
    1395:	cmp    $0x4,%rsi
    1399:	je     17c6 <botlish_fn_13+0xf8e>
    139f:	cmp    $0x5,%rsi
    13a3:	je     1495 <botlish_fn_13+0xc5d>
    13a9:	mov    %r14,%rsi
    13ac:	test   $0x1,%rsi
    13b3:	jne    13e6 <botlish_fn_13+0xbae>
    13b9:	mov    0x258(%rsp),%rdx
    13c1:	mov    %r14,%rsi
    13c4:	mov    0x1e8(%rsp),%rdi
    13cc:	call   13d1 <botlish_fn_13+0xb99>
			13cd: R_X86_64_PLT32	rt_int_cmp-0x4
    13d1:	mov    $0x2,%ecx
    13d6:	test   %rax,%rax
    13d9:	cmove  0x57b7(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    13e1:	jmp    13fa <botlish_fn_13+0xbc2>
    13e6:	mov    $0x2,%ecx
    13eb:	mov    %r14,%rsi
    13ee:	cmp    $0xffffffffffffffff,%rsi
    13f2:	cmove  0x579e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    13fa:	cmp    $0x6,%rcx
    13fe:	je     1453 <botlish_fn_13+0xc1b>
    1404:	mov    0x1e8(%rsp),%rdi
    140c:	mov    0x10(%rdi),%rcx
    1410:	mov    0x160(%rcx),%rax
    1417:	mov    0x158(%rcx),%rdx
    141e:	lea    0x160(%rsp),%r9
    1426:	mov    %rax,0x160(%rsp)
    142e:	mov    %r14,%rsi
    1431:	mov    %rsi,0x168(%rsp)
    1439:	mov    $0x1,%esi
    143e:	mov    $0x5,%ecx
    1443:	mov    $0x2,%r8d
    1449:	call   144e <botlish_fn_13+0xc16>
			144a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    144e:	jmp    1eab <botlish_fn_13+0x1673>
    1453:	mov    0x1e8(%rsp),%rdi
    145b:	mov    0x10(%rdi),%rcx
    145f:	mov    0x160(%rcx),%rax
    1466:	mov    0x150(%rcx),%rdx
    146d:	lea    0x158(%rsp),%r9
    1475:	mov    %rax,0x158(%rsp)
    147d:	mov    $0x2,%ecx
    1482:	mov    $0x1,%r8d
    1488:	mov    %rcx,%rsi
    148b:	call   1490 <botlish_fn_13+0xc58>
			148c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1490:	jmp    1eab <botlish_fn_13+0x1673>
    1495:	mov    %r14,%rsi
    1498:	test   $0x1,%rsi
    149f:	jne    14cf <botlish_fn_13+0xc97>
    14a5:	mov    $0xdd,%edx
    14aa:	mov    %r14,%rsi
    14ad:	mov    0x1e8(%rsp),%rdi
    14b5:	call   14ba <botlish_fn_13+0xc82>
			14b6: R_X86_64_PLT32	rt_int_cmp-0x4
    14ba:	mov    $0x2,%ecx
    14bf:	test   %rax,%rax
    14c2:	cmovl  0x56ce(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    14ca:	jmp    14e6 <botlish_fn_13+0xcae>
    14cf:	mov    $0x2,%ecx
    14d4:	mov    %r14,%rsi
    14d7:	cmp    $0xdd,%rsi
    14de:	cmovl  0x56b2(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    14e6:	cmp    $0x6,%rcx
    14ea:	je     15e6 <botlish_fn_13+0xdae>
    14f0:	mov    %r14,%rsi
    14f3:	test   $0x1,%rsi
    14fa:	jne    152b <botlish_fn_13+0xcf3>
    1500:	mov    $0xe9,%edx
    1505:	mov    %r14,%rsi
    1508:	mov    0x1e8(%rsp),%rdi
    1510:	call   1515 <botlish_fn_13+0xcdd>
			1511: R_X86_64_PLT32	rt_int_cmp-0x4
    1515:	mov    $0x2,%r10d
    151b:	test   %rax,%rax
    151e:	cmovl  0x5672(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    1526:	jmp    1543 <botlish_fn_13+0xd0b>
    152b:	mov    $0x2,%r10d
    1531:	mov    %r14,%rsi
    1534:	cmp    $0xe9,%rsi
    153b:	cmovl  0x5655(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    1543:	cmp    $0x6,%r10
    1547:	je     15c0 <botlish_fn_13+0xd88>
    154d:	mov    %r14,%rsi
    1550:	test   $0x1,%rsi
    1557:	jne    1587 <botlish_fn_13+0xd4f>
    155d:	mov    $0xeb,%edx
    1562:	mov    %r14,%rsi
    1565:	mov    0x1e8(%rsp),%rdi
    156d:	call   1572 <botlish_fn_13+0xd3a>
			156e: R_X86_64_PLT32	rt_int_cmp-0x4
    1572:	mov    $0x2,%ecx
    1577:	test   %rax,%rax
    157a:	cmovl  0x5616(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1582:	jmp    159e <botlish_fn_13+0xd66>
    1587:	mov    $0x2,%ecx
    158c:	mov    %r14,%rsi
    158f:	cmp    $0xeb,%rsi
    1596:	cmovl  0x55fa(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    159e:	cmp    $0x6,%rcx
    15a2:	je     15b3 <botlish_fn_13+0xd7b>
    15a8:	mov    $0x1d,%r13d
    15ae:	jmp    1670 <botlish_fn_13+0xe38>
    15b3:	mov    0x280(%rsp),%r13
    15bb:	jmp    1670 <botlish_fn_13+0xe38>
    15c0:	mov    %r14,%rsi
    15c3:	sar    $1,%rsi
    15c6:	cmp    $0x6f,%rsi
    15ca:	jl     15db <botlish_fn_13+0xda3>
    15d0:	mov    $0x1d,%r13d
    15d6:	jmp    1670 <botlish_fn_13+0xe38>
    15db:	mov    $0x7,%r13d
    15e1:	jmp    1670 <botlish_fn_13+0xe38>
    15e6:	mov    %r14,%rsi
    15e9:	test   $0x1,%rsi
    15f0:	jne    1620 <botlish_fn_13+0xde8>
    15f6:	mov    $0xcd,%edx
    15fb:	mov    %r14,%rsi
    15fe:	mov    0x1e8(%rsp),%rdi
    1606:	call   160b <botlish_fn_13+0xdd3>
			1607: R_X86_64_PLT32	rt_int_cmp-0x4
    160b:	mov    $0x2,%ecx
    1610:	test   %rax,%rax
    1613:	cmovl  0x557d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    161b:	jmp    1637 <botlish_fn_13+0xdff>
    1620:	mov    $0x2,%ecx
    1625:	mov    %r14,%rsi
    1628:	cmp    $0xcd,%rsi
    162f:	cmovl  0x5561(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1637:	cmp    $0x6,%rcx
    163b:	je     166a <botlish_fn_13+0xe32>
    1641:	mov    %r14,%rsi
    1644:	mov    %rsi,%rax
    1647:	sar    $1,%rax
    164a:	cmp    $0x67,%rax
    164e:	jl     165f <botlish_fn_13+0xe27>
    1654:	mov    $0x1d,%r13d
    165a:	jmp    1670 <botlish_fn_13+0xe38>
    165f:	mov    $0x5,%r13d
    1665:	jmp    1670 <botlish_fn_13+0xe38>
    166a:	mov    $0x1d,%r13d
    1670:	mov    %r13,%rsi
    1673:	sar    $1,%rsi
    1676:	cmp    $0xc,%rsi
    167a:	jl     178b <botlish_fn_13+0xf53>
    1680:	cmp    $0xd,%rsi
    1684:	mov    %rsi,%rbx
    1687:	je     20a9 <botlish_fn_13+0x1871>
    168d:	mov    %r14,%rsi
    1690:	test   $0x1,%rsi
    1697:	jne    16ca <botlish_fn_13+0xe92>
    169d:	mov    0x258(%rsp),%rdx
    16a5:	mov    %r14,%rsi
    16a8:	mov    0x1e8(%rsp),%rdi
    16b0:	call   16b5 <botlish_fn_13+0xe7d>
			16b1: R_X86_64_PLT32	rt_int_cmp-0x4
    16b5:	mov    $0x2,%ecx
    16ba:	test   %rax,%rax
    16bd:	cmove  0x54d3(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    16c5:	jmp    16de <botlish_fn_13+0xea6>
    16ca:	mov    $0x2,%ecx
    16cf:	mov    %r14,%rsi
    16d2:	cmp    $0xffffffffffffffff,%rsi
    16d6:	cmove  0x54ba(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    16de:	cmp    $0x6,%rcx
    16e2:	je     1740 <botlish_fn_13+0xf08>
    16e8:	mov    %rbx,%rsi
    16eb:	mov    0x1e8(%rsp),%rdi
    16f3:	call   16f8 <botlish_fn_13+0xec0>
			16f4: R_X86_64_PLT32	botlish_fn_3-0x4
    16f8:	mov    0x1e8(%rsp),%rdi
    1700:	mov    0x10(%rdi),%rcx
    1704:	mov    0x158(%rcx),%rdx
    170b:	lea    0x148(%rsp),%r9
    1713:	mov    %rax,0x148(%rsp)
    171b:	mov    %r14,%rsi
    171e:	mov    %rsi,0x150(%rsp)
    1726:	mov    $0x1,%esi
    172b:	mov    $0x5,%ecx
    1730:	mov    $0x2,%r8d
    1736:	call   173b <botlish_fn_13+0xf03>
			1737: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    173b:	jmp    1eab <botlish_fn_13+0x1673>
    1740:	mov    %rbx,%rsi
    1743:	mov    0x1e8(%rsp),%rdi
    174b:	call   1750 <botlish_fn_13+0xf18>
			174c: R_X86_64_PLT32	botlish_fn_3-0x4
    1750:	mov    0x1e8(%rsp),%rdi
    1758:	mov    0x10(%rdi),%rcx
    175c:	mov    0x150(%rcx),%rdx
    1763:	lea    0x140(%rsp),%r9
    176b:	mov    %rax,0x140(%rsp)
    1773:	mov    $0x2,%ecx
    1778:	mov    $0x1,%r8d
    177e:	mov    %rcx,%rsi
    1781:	call   1786 <botlish_fn_13+0xf4e>
			1782: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1786:	jmp    1eab <botlish_fn_13+0x1673>
    178b:	mov    %r13,0xa0(%rsp)
    1793:	mov    $0x6,%ebx
    1798:	movq   $0x6,0x78(%rsp)
    17a1:	mov    $0xa,%ecx
    17a6:	mov    %rcx,%r12
    17a9:	mov    0x250(%rsp),%r14
    17b1:	mov    %rcx,0x200(%rsp)
    17b9:	mov    %rcx,0x238(%rsp)
    17c1:	jmp    2133 <botlish_fn_13+0x18fb>
    17c6:	mov    %r14,%rsi
    17c9:	test   $0x1,%rsi
    17d0:	jne    1800 <botlish_fn_13+0xfc8>
    17d6:	mov    $0x61,%edx
    17db:	mov    %r14,%rsi
    17de:	mov    0x1e8(%rsp),%rdi
    17e6:	call   17eb <botlish_fn_13+0xfb3>
			17e7: R_X86_64_PLT32	rt_int_cmp-0x4
    17eb:	mov    $0x2,%ecx
    17f0:	test   %rax,%rax
    17f3:	cmovl  0x539d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    17fb:	jmp    1814 <botlish_fn_13+0xfdc>
    1800:	mov    $0x2,%ecx
    1805:	mov    %r14,%rsi
    1808:	cmp    $0x61,%rsi
    180c:	cmovl  0x5384(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1814:	cmp    $0x6,%rcx
    1818:	je     18ef <botlish_fn_13+0x10b7>
    181e:	mov    %r14,%rsi
    1821:	test   $0x1,%rsi
    1828:	jne    1858 <botlish_fn_13+0x1020>
    182e:	mov    $0x63,%edx
    1833:	mov    %r14,%rsi
    1836:	mov    0x1e8(%rsp),%rdi
    183e:	call   1843 <botlish_fn_13+0x100b>
			183f: R_X86_64_PLT32	rt_int_cmp-0x4
    1843:	mov    $0x2,%ecx
    1848:	test   %rax,%rax
    184b:	cmovl  0x5345(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1853:	jmp    186c <botlish_fn_13+0x1034>
    1858:	mov    $0x2,%ecx
    185d:	mov    %r14,%rsi
    1860:	cmp    $0x63,%rsi
    1864:	cmovl  0x532c(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    186c:	cmp    $0x6,%rcx
    1870:	je     18e4 <botlish_fn_13+0x10ac>
    1876:	mov    %r14,%rsi
    1879:	test   $0x1,%rsi
    1880:	jne    18b0 <botlish_fn_13+0x1078>
    1886:	mov    $0x75,%edx
    188b:	mov    %r14,%rsi
    188e:	mov    0x1e8(%rsp),%rdi
    1896:	call   189b <botlish_fn_13+0x1063>
			1897: R_X86_64_PLT32	rt_int_cmp-0x4
    189b:	mov    $0x2,%ecx
    18a0:	test   %rax,%rax
    18a3:	cmovl  0x52ed(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    18ab:	jmp    18c4 <botlish_fn_13+0x108c>
    18b0:	mov    $0x2,%ecx
    18b5:	mov    %r14,%rsi
    18b8:	cmp    $0x75,%rsi
    18bc:	cmovl  0x52d4(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    18c4:	cmp    $0x6,%rcx
    18c8:	je     18d9 <botlish_fn_13+0x10a1>
    18ce:	mov    $0x17,%r12d
    18d4:	jmp    1978 <botlish_fn_13+0x1140>
    18d9:	mov    $0x7,%r12d
    18df:	jmp    1978 <botlish_fn_13+0x1140>
    18e4:	mov    $0x5,%r12d
    18ea:	jmp    1978 <botlish_fn_13+0x1140>
    18ef:	mov    %r14,%rsi
    18f2:	test   $0x1,%rsi
    18f9:	jne    1929 <botlish_fn_13+0x10f1>
    18ff:	mov    $0x5b,%edx
    1904:	mov    %r14,%rsi
    1907:	mov    0x1e8(%rsp),%rdi
    190f:	call   1914 <botlish_fn_13+0x10dc>
			1910: R_X86_64_PLT32	rt_int_cmp-0x4
    1914:	mov    $0x2,%ecx
    1919:	test   %rax,%rax
    191c:	cmovl  0x5274(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1924:	jmp    193d <botlish_fn_13+0x1105>
    1929:	mov    $0x2,%ecx
    192e:	mov    %r14,%rsi
    1931:	cmp    $0x5b,%rsi
    1935:	cmovl  0x525b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    193d:	cmp    $0x6,%rcx
    1941:	je     1972 <botlish_fn_13+0x113a>
    1947:	mov    %r14,%rsi
    194a:	mov    %rsi,%rax
    194d:	sar    $1,%rax
    1950:	cmp    $0x2e,%rax
    1954:	jl     1965 <botlish_fn_13+0x112d>
    195a:	mov    $0x17,%r12d
    1960:	jmp    1978 <botlish_fn_13+0x1140>
    1965:	mov    0x280(%rsp),%r12
    196d:	jmp    1978 <botlish_fn_13+0x1140>
    1972:	mov    $0x17,%r12d
    1978:	mov    %r12,%rsi
    197b:	sar    $1,%rsi
    197e:	cmp    $0x9,%rsi
    1982:	jl     1a93 <botlish_fn_13+0x125b>
    1988:	cmp    $0xa,%rsi
    198c:	mov    %rsi,%rbx
    198f:	je     20a9 <botlish_fn_13+0x1871>
    1995:	mov    %r14,%rsi
    1998:	test   $0x1,%rsi
    199f:	jne    19d2 <botlish_fn_13+0x119a>
    19a5:	mov    0x258(%rsp),%rdx
    19ad:	mov    %r14,%rsi
    19b0:	mov    0x1e8(%rsp),%rdi
    19b8:	call   19bd <botlish_fn_13+0x1185>
			19b9: R_X86_64_PLT32	rt_int_cmp-0x4
    19bd:	mov    $0x2,%ecx
    19c2:	test   %rax,%rax
    19c5:	cmove  0x51cb(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    19cd:	jmp    19e6 <botlish_fn_13+0x11ae>
    19d2:	mov    $0x2,%ecx
    19d7:	mov    %r14,%rsi
    19da:	cmp    $0xffffffffffffffff,%rsi
    19de:	cmove  0x51b2(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    19e6:	cmp    $0x6,%rcx
    19ea:	je     1a48 <botlish_fn_13+0x1210>
    19f0:	mov    %rbx,%rsi
    19f3:	mov    0x1e8(%rsp),%rdi
    19fb:	call   1a00 <botlish_fn_13+0x11c8>
			19fc: R_X86_64_PLT32	botlish_fn_1-0x4
    1a00:	mov    0x1e8(%rsp),%rdi
    1a08:	mov    0x10(%rdi),%rcx
    1a0c:	mov    0x158(%rcx),%rdx
    1a13:	lea    0x130(%rsp),%r9
    1a1b:	mov    %rax,0x130(%rsp)
    1a23:	mov    %r14,%rsi
    1a26:	mov    %rsi,0x138(%rsp)
    1a2e:	mov    $0x1,%esi
    1a33:	mov    $0x5,%ecx
    1a38:	mov    $0x2,%r8d
    1a3e:	call   1a43 <botlish_fn_13+0x120b>
			1a3f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1a43:	jmp    1eab <botlish_fn_13+0x1673>
    1a48:	mov    %rbx,%rsi
    1a4b:	mov    0x1e8(%rsp),%rdi
    1a53:	call   1a58 <botlish_fn_13+0x1220>
			1a54: R_X86_64_PLT32	botlish_fn_1-0x4
    1a58:	mov    0x1e8(%rsp),%rdi
    1a60:	mov    0x10(%rdi),%rcx
    1a64:	mov    0x150(%rcx),%rdx
    1a6b:	lea    0x128(%rsp),%r9
    1a73:	mov    %rax,0x128(%rsp)
    1a7b:	mov    $0x2,%ecx
    1a80:	mov    $0x1,%r8d
    1a86:	mov    %rcx,%rsi
    1a89:	call   1a8e <botlish_fn_13+0x1256>
			1a8a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1a8e:	jmp    1eab <botlish_fn_13+0x1673>
    1a93:	mov    %r12,0x98(%rsp)
    1a9b:	mov    $0x6,%ebx
    1aa0:	movq   $0x6,0x78(%rsp)
    1aa9:	mov    $0xa,%ecx
    1aae:	mov    %rcx,%r13
    1ab1:	mov    0x280(%rsp),%r14
    1ab9:	mov    %rcx,0x200(%rsp)
    1ac1:	mov    %rcx,0x238(%rsp)
    1ac9:	jmp    2133 <botlish_fn_13+0x18fb>
    1ace:	mov    %r14,%rsi
    1ad1:	test   $0x1,%rsi
    1ad8:	jne    1b08 <botlish_fn_13+0x12d0>
    1ade:	mov    $0x45,%edx
    1ae3:	mov    %r14,%rsi
    1ae6:	mov    0x1e8(%rsp),%rdi
    1aee:	call   1af3 <botlish_fn_13+0x12bb>
			1aef: R_X86_64_PLT32	rt_int_cmp-0x4
    1af3:	mov    $0x2,%ecx
    1af8:	test   %rax,%rax
    1afb:	cmovl  0x5095(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1b03:	jmp    1b1c <botlish_fn_13+0x12e4>
    1b08:	mov    $0x2,%ecx
    1b0d:	mov    %r14,%rsi
    1b10:	cmp    $0x45,%rsi
    1b14:	cmovl  0x507c(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1b1c:	cmp    $0x6,%rcx
    1b20:	je     1b96 <botlish_fn_13+0x135e>
    1b26:	mov    %r14,%rsi
    1b29:	test   $0x1,%rsi
    1b30:	jne    1b60 <botlish_fn_13+0x1328>
    1b36:	mov    $0x47,%edx
    1b3b:	mov    %r14,%rsi
    1b3e:	mov    0x1e8(%rsp),%rdi
    1b46:	call   1b4b <botlish_fn_13+0x1313>
			1b47: R_X86_64_PLT32	rt_int_cmp-0x4
    1b4b:	mov    $0x2,%ecx
    1b50:	test   %rax,%rax
    1b53:	cmovl  0x503d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1b5b:	jmp    1b74 <botlish_fn_13+0x133c>
    1b60:	mov    $0x2,%ecx
    1b65:	mov    %r14,%rsi
    1b68:	cmp    $0x47,%rsi
    1b6c:	cmovl  0x5024(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1b74:	cmp    $0x6,%rcx
    1b78:	je     1b89 <botlish_fn_13+0x1351>
    1b7e:	mov    $0xb,%r8d
    1b84:	jmp    1b9c <botlish_fn_13+0x1364>
    1b89:	mov    0x280(%rsp),%r8
    1b91:	jmp    1b9c <botlish_fn_13+0x1364>
    1b96:	mov    $0xb,%r8d
    1b9c:	mov    %r8,%rsi
    1b9f:	sar    $1,%rsi
    1ba2:	cmp    $0x2,%rsi
    1ba6:	jl     2063 <botlish_fn_13+0x182b>
    1bac:	cmp    $0x2,%rsi
    1bb0:	je     2054 <botlish_fn_13+0x181c>
    1bb6:	cmp    $0x4,%rsi
    1bba:	mov    %rsi,%rbx
    1bbd:	je     1cc3 <botlish_fn_13+0x148b>
    1bc3:	mov    %r14,%rsi
    1bc6:	test   $0x1,%rsi
    1bcd:	jne    1c01 <botlish_fn_13+0x13c9>
    1bd3:	mov    0x258(%rsp),%rdx
    1bdb:	mov    %r14,%rsi
    1bde:	mov    0x1e8(%rsp),%rdi
    1be6:	call   1beb <botlish_fn_13+0x13b3>
			1be7: R_X86_64_PLT32	rt_int_cmp-0x4
    1beb:	mov    $0x2,%r10d
    1bf1:	test   %rax,%rax
    1bf4:	cmove  0x4f9c(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    1bfc:	jmp    1c16 <botlish_fn_13+0x13de>
    1c01:	mov    $0x2,%r10d
    1c07:	mov    %r14,%rsi
    1c0a:	cmp    $0xffffffffffffffff,%rsi
    1c0e:	cmove  0x4f82(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    1c16:	cmp    $0x6,%r10
    1c1a:	je     1c78 <botlish_fn_13+0x1440>
    1c20:	mov    %rbx,%rsi
    1c23:	mov    0x1e8(%rsp),%rdi
    1c2b:	call   1c30 <botlish_fn_13+0x13f8>
			1c2c: R_X86_64_PLT32	botlish_fn_7-0x4
    1c30:	mov    0x1e8(%rsp),%rdi
    1c38:	mov    0x10(%rdi),%rcx
    1c3c:	mov    0x158(%rcx),%rdx
    1c43:	lea    0x118(%rsp),%r9
    1c4b:	mov    %rax,0x118(%rsp)
    1c53:	mov    %r14,%rsi
    1c56:	mov    %rsi,0x120(%rsp)
    1c5e:	mov    $0x1,%esi
    1c63:	mov    $0x5,%ecx
    1c68:	mov    $0x2,%r8d
    1c6e:	call   1c73 <botlish_fn_13+0x143b>
			1c6f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1c73:	jmp    1eab <botlish_fn_13+0x1673>
    1c78:	mov    %rbx,%rsi
    1c7b:	mov    0x1e8(%rsp),%rdi
    1c83:	call   1c88 <botlish_fn_13+0x1450>
			1c84: R_X86_64_PLT32	botlish_fn_7-0x4
    1c88:	mov    0x1e8(%rsp),%rdi
    1c90:	mov    0x10(%rdi),%rcx
    1c94:	mov    0x150(%rcx),%rdx
    1c9b:	lea    0x110(%rsp),%r9
    1ca3:	mov    %rax,0x110(%rsp)
    1cab:	mov    $0x2,%ecx
    1cb0:	mov    $0x1,%r8d
    1cb6:	mov    %rcx,%rsi
    1cb9:	call   1cbe <botlish_fn_13+0x1486>
			1cba: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1cbe:	jmp    1eab <botlish_fn_13+0x1673>
    1cc3:	mov    %r14,%rsi
    1cc6:	test   $0x1,%rsi
    1ccd:	jne    1cfd <botlish_fn_13+0x14c5>
    1cd3:	mov    $0xb9,%edx
    1cd8:	mov    %r14,%rsi
    1cdb:	mov    0x1e8(%rsp),%rdi
    1ce3:	call   1ce8 <botlish_fn_13+0x14b0>
			1ce4: R_X86_64_PLT32	rt_int_cmp-0x4
    1ce8:	mov    $0x2,%ecx
    1ced:	test   %rax,%rax
    1cf0:	cmovl  0x4ea0(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1cf8:	jmp    1d14 <botlish_fn_13+0x14dc>
    1cfd:	mov    $0x2,%ecx
    1d02:	mov    %r14,%rsi
    1d05:	cmp    $0xb9,%rsi
    1d0c:	cmovl  0x4e84(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1d14:	cmp    $0x6,%rcx
    1d18:	je     1d90 <botlish_fn_13+0x1558>
    1d1e:	mov    %r14,%rsi
    1d21:	test   $0x1,%rsi
    1d28:	jne    1d58 <botlish_fn_13+0x1520>
    1d2e:	mov    $0xbb,%edx
    1d33:	mov    %r14,%rsi
    1d36:	mov    0x1e8(%rsp),%rdi
    1d3e:	call   1d43 <botlish_fn_13+0x150b>
			1d3f: R_X86_64_PLT32	rt_int_cmp-0x4
    1d43:	mov    $0x2,%ecx
    1d48:	test   %rax,%rax
    1d4b:	cmovl  0x4e45(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1d53:	jmp    1d6f <botlish_fn_13+0x1537>
    1d58:	mov    $0x2,%ecx
    1d5d:	mov    %r14,%rsi
    1d60:	cmp    $0xbb,%rsi
    1d67:	cmovl  0x4e29(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1d6f:	cmp    $0x6,%rcx
    1d73:	je     1d83 <botlish_fn_13+0x154b>
    1d79:	mov    $0x11,%ecx
    1d7e:	jmp    1d95 <botlish_fn_13+0x155d>
    1d83:	mov    0x280(%rsp),%rcx
    1d8b:	jmp    1d95 <botlish_fn_13+0x155d>
    1d90:	mov    $0x11,%ecx
    1d95:	mov    %rcx,%rsi
    1d98:	sar    $1,%rsi
    1d9b:	cmp    $0x6,%rsi
    1d9f:	jl     2017 <botlish_fn_13+0x17df>
    1da5:	cmp    $0x6,%rsi
    1da9:	mov    %rsi,%rbx
    1dac:	je     1ff6 <botlish_fn_13+0x17be>
    1db2:	mov    %r14,%rsi
    1db5:	test   $0x1,%rsi
    1dbc:	jne    1def <botlish_fn_13+0x15b7>
    1dc2:	mov    0x258(%rsp),%rdx
    1dca:	mov    %r14,%rsi
    1dcd:	mov    0x1e8(%rsp),%rdi
    1dd5:	call   1dda <botlish_fn_13+0x15a2>
			1dd6: R_X86_64_PLT32	rt_int_cmp-0x4
    1dda:	mov    $0x2,%ecx
    1ddf:	test   %rax,%rax
    1de2:	cmove  0x4dae(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1dea:	jmp    1e03 <botlish_fn_13+0x15cb>
    1def:	mov    $0x2,%ecx
    1df4:	mov    %r14,%rsi
    1df7:	cmp    $0xffffffffffffffff,%rsi
    1dfb:	cmove  0x4d95(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    1e03:	cmp    $0x6,%rcx
    1e07:	je     1e65 <botlish_fn_13+0x162d>
    1e0d:	mov    %rbx,%rsi
    1e10:	mov    0x1e8(%rsp),%rdi
    1e18:	call   1e1d <botlish_fn_13+0x15e5>
			1e19: R_X86_64_PLT32	botlish_fn_5-0x4
    1e1d:	mov    0x1e8(%rsp),%rdi
    1e25:	mov    0x10(%rdi),%rcx
    1e29:	mov    0x158(%rcx),%rdx
    1e30:	lea    0x100(%rsp),%r9
    1e38:	mov    %rax,0x100(%rsp)
    1e40:	mov    %r14,%rsi
    1e43:	mov    %rsi,0x108(%rsp)
    1e4b:	mov    $0x1,%esi
    1e50:	mov    $0x5,%ecx
    1e55:	mov    $0x2,%r8d
    1e5b:	call   1e60 <botlish_fn_13+0x1628>
			1e5c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1e60:	jmp    1eab <botlish_fn_13+0x1673>
    1e65:	mov    %rbx,%rsi
    1e68:	mov    0x1e8(%rsp),%rdi
    1e70:	call   1e75 <botlish_fn_13+0x163d>
			1e71: R_X86_64_PLT32	botlish_fn_5-0x4
    1e75:	mov    0x1e8(%rsp),%rdi
    1e7d:	mov    0x10(%rdi),%rcx
    1e81:	mov    0x150(%rcx),%rdx
    1e88:	lea    0xf8(%rsp),%r9
    1e90:	mov    %rax,0xf8(%rsp)
    1e98:	mov    $0x2,%ecx
    1e9d:	mov    $0x1,%r8d
    1ea3:	mov    %rcx,%rsi
    1ea6:	call   1eab <botlish_fn_13+0x1673>
			1ea7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1eab:	mov    0x1e8(%rsp),%rdi
    1eb3:	call   1eb8 <botlish_fn_13+0x1680>
			1eb4: R_X86_64_PLT32	rt_co_failed-0x4
    1eb8:	mov    %rax,0x80(%rsp)
    1ec0:	mov    %rax,%rsi
    1ec3:	mov    0x1e8(%rsp),%rdi
    1ecb:	call   1ed0 <botlish_fn_13+0x1698>
			1ecc: R_X86_64_PLT32	rt_co_resume0-0x4
    1ed0:	test   %rax,%rax
    1ed3:	je     1ef5 <botlish_fn_13+0x16bd>
    1ed9:	mov    0x1e8(%rsp),%rdi
    1ee1:	mov    0x10(%rdi),%rax
    1ee5:	mov    0x50(%rax),%rsi
    1ee9:	mov    0x130(%rax),%rdx
    1ef0:	call   1ef5 <botlish_fn_13+0x16bd>
			1ef1: R_X86_64_PLT32	rt_raise-0x4
    1ef5:	mov    0x1e8(%rsp),%rdi
    1efd:	call   1f02 <botlish_fn_13+0x16ca>
			1efe: R_X86_64_PLT32	rt_declared_error-0x4
    1f02:	cmp    $0x1,%rax
    1f06:	je     1f83 <botlish_fn_13+0x174b>
    1f0c:	mov    0x1e8(%rsp),%rdi
    1f14:	call   1f19 <botlish_fn_13+0x16e1>
			1f15: R_X86_64_PLT32	rt_declared_error-0x4
    1f19:	cmp    $0x2,%rax
    1f1d:	jne    68f3 <botlish_fn_13+0x60bb>
    1f23:	xor    %rsi,%rsi
    1f26:	mov    0x1e8(%rsp),%rdi
    1f2e:	call   1f33 <botlish_fn_13+0x16fb>
			1f2f: R_X86_64_PLT32	rt_declared_payload-0x4
    1f33:	mov    %rax,%r12
    1f36:	mov    0x1e8(%rsp),%rdi
    1f3e:	call   1f43 <botlish_fn_13+0x170b>
			1f3f: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1f43:	mov    0x1e8(%rsp),%rdi
    1f4b:	mov    0x10(%rdi),%rax
    1f4f:	mov    0x140(%rax),%rdx
    1f56:	lea    0xb8(%rsp),%r9
    1f5e:	mov    %r12,%rax
    1f61:	mov    %rax,0xb8(%rsp)
    1f69:	mov    $0x5,%esi
    1f6e:	mov    $0x2,%ecx
    1f73:	mov    $0x1,%r8d
    1f79:	call   1f7e <botlish_fn_13+0x1746>
			1f7a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1f7e:	jmp    68f3 <botlish_fn_13+0x60bb>
    1f83:	xor    %rsi,%rsi
    1f86:	mov    0x1e8(%rsp),%rdi
    1f8e:	call   1f93 <botlish_fn_13+0x175b>
			1f8f: R_X86_64_PLT32	rt_declared_payload-0x4
    1f93:	mov    %rax,%r13
    1f96:	mov    0x1e8(%rsp),%rdi
    1f9e:	call   1fa3 <botlish_fn_13+0x176b>
			1f9f: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1fa3:	mov    0x1e8(%rsp),%rdi
    1fab:	mov    0x10(%rdi),%rax
    1faf:	mov    0x138(%rax),%rdx
    1fb6:	lea    0xa8(%rsp),%r9
    1fbe:	mov    0x248(%rsp),%rcx
    1fc6:	mov    %rcx,0xa8(%rsp)
    1fce:	mov    %r13,%rax
    1fd1:	mov    %rax,0xb0(%rsp)
    1fd9:	mov    $0x1,%ecx
    1fde:	mov    $0x2,%r8d
    1fe4:	mov    0x250(%rsp),%rsi
    1fec:	call   1ff1 <botlish_fn_13+0x17b9>
			1fed: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1ff1:	jmp    68f3 <botlish_fn_13+0x60bb>
    1ff6:	movq   $0x3,0x88(%rsp)
    2002:	mov    0x280(%rsp),%rax
    200a:	mov    %rax,0x200(%rsp)
    2012:	jmp    2073 <botlish_fn_13+0x183b>
    2017:	mov    %rcx,0x90(%rsp)
    201f:	mov    $0x6,%ebx
    2024:	movq   $0x6,0x78(%rsp)
    202d:	mov    $0x1,%r14d
    2033:	mov    $0xa,%r8d
    2039:	mov    %r8,%r12
    203c:	mov    %r8,%r13
    203f:	mov    %r8,0x200(%rsp)
    2047:	mov    %rcx,0x238(%rsp)
    204f:	jmp    2133 <botlish_fn_13+0x18fb>
    2054:	mov    $0xfffffffffffffffd,%rsi
    205b:	mov    %rsi,%r14
    205e:	jmp    20a9 <botlish_fn_13+0x1871>
    2063:	mov    %r8,0x88(%rsp)
    206b:	mov    %r8,0x200(%rsp)
    2073:	mov    $0x6,%ebx
    2078:	movq   $0x6,0x78(%rsp)
    2081:	mov    $0x2,%r14d
    2087:	mov    $0xa,%ecx
    208c:	mov    %rcx,%r12
    208f:	mov    %rcx,%r13
    2092:	mov    %rcx,0x238(%rsp)
    209a:	jmp    2133 <botlish_fn_13+0x18fb>
    209f:	mov    $0xfffffffffffffffd,%rsi
    20a6:	mov    %rsi,%r14
    20a9:	mov    %r14,%rsi
    20ac:	test   $0x1,%rsi
    20b3:	jne    20e5 <botlish_fn_13+0x18ad>
    20b9:	mov    $0xfffffffffffffffd,%rdx
    20c0:	mov    %r14,%rsi
    20c3:	mov    0x1e8(%rsp),%rdi
    20cb:	call   20d0 <botlish_fn_13+0x1898>
			20cc: R_X86_64_PLT32	rt_int_cmp-0x4
    20d0:	mov    $0x2,%ebx
    20d5:	test   %rax,%rax
    20d8:	cmove  0x4ab8(%rip),%rbx        # 6b98 <botlish_fn_13+0x6360>
    20e0:	jmp    20f9 <botlish_fn_13+0x18c1>
    20e5:	mov    $0x2,%ebx
    20ea:	mov    %r14,%rsi
    20ed:	cmp    $0xfffffffffffffffd,%rsi
    20f1:	cmove  0x4a9f(%rip),%rbx        # 6b98 <botlish_fn_13+0x6360>
    20f9:	mov    %rbx,0x78(%rsp)
    20fe:	mov    $0xa,%ecx
    2103:	mov    %rcx,0x238(%rsp)
    210b:	mov    0x238(%rsp),%r12
    2113:	mov    0x238(%rsp),%r13
    211b:	mov    0x258(%rsp),%r14
    2123:	mov    0x238(%rsp),%rax
    212b:	mov    %rax,0x200(%rsp)
    2133:	mov    0x260(%rsp),%rax
    213b:	mov    0x18(%rax),%r8
    213f:	test   %r8,%r8
    2142:	je     6aa9 <botlish_fn_13+0x6271>
    2148:	mov    0x260(%rsp),%rax
    2150:	mov    0x10(%rax),%r11
    2154:	mov    %rbx,(%r11)
    2157:	mov    0x260(%rsp),%rax
    215f:	mov    0x260(%rsp),%rax
    2167:	mov    0x10(%rax),%rax
    216b:	mov    (%rax),%rax
    216e:	cmp    $0x6,%rax
    2172:	jne    2600 <botlish_fn_13+0x1dc8>
    2178:	movq   $0x1,0x30(%rsp)
    2181:	mov    0x270(%rsp),%rcx
    2189:	mov    0x10(%rcx),%rax
    218d:	mov    (%rax),%rsi
    2190:	mov    %rsi,0x38(%rsp)
    2195:	movq   $0x3,0x40(%rsp)
    219e:	test   $0x1,%rsi
    21a5:	je     21ca <botlish_fn_13+0x1992>
    21ab:	mov    %rsi,%rcx
    21ae:	add    $0x2,%rcx
    21b2:	seto   %al
    21b5:	test   %al,%al
    21b7:	jne    21ca <botlish_fn_13+0x1992>
    21bd:	mov    0x270(%rsp),%rax
    21c5:	jmp    21ea <botlish_fn_13+0x19b2>
    21ca:	mov    0x280(%rsp),%rdx
    21d2:	mov    0x1e8(%rsp),%rdi
    21da:	call   21df <botlish_fn_13+0x19a7>
			21db: R_X86_64_PLT32	rt_int_add-0x4
    21df:	mov    %rax,%rcx
    21e2:	mov    0x270(%rsp),%rax
    21ea:	mov    0x270(%rsp),%rax
    21f2:	mov    0x18(%rax),%rax
    21f6:	test   %rax,%rax
    21f9:	je     6acb <botlish_fn_13+0x6293>
    21ff:	mov    0x270(%rsp),%rax
    2207:	mov    0x10(%rax),%rax
    220b:	mov    %rcx,(%rax)
    220e:	movq   $0x1,0x30(%rsp)
    2217:	mov    0x208(%rsp),%rcx
    221f:	cmp    $0x1,%rcx
    2223:	je     2245 <botlish_fn_13+0x1a0d>
    2229:	mov    $0xa,%esi
    222e:	cmp    $0xffffffffffffffff,%rcx
    2232:	jne    2416 <botlish_fn_13+0x1bde>
    2238:	mov    %rcx,0x208(%rsp)
    2240:	jmp    25d4 <botlish_fn_13+0x1d9c>
    2245:	mov    0x218(%rsp),%rax
    224d:	add    $0x1,%rax
    2254:	mov    %rax,0x218(%rsp)
    225c:	mov    0x220(%rsp),%r15
    2264:	cmp    %r15,%rax
    2267:	jl     2512 <botlish_fn_13+0x1cda>
    226d:	movq   $0x3,0x38(%rsp)
    2276:	mov    0x230(%rsp),%rsi
    227e:	test   $0x1,%rsi
    2285:	jne    2298 <botlish_fn_13+0x1a60>
    228b:	mov    0x230(%rsp),%rsi
    2293:	jmp    22cf <botlish_fn_13+0x1a97>
    2298:	mov    0x230(%rsp),%rsi
    22a0:	mov    %rsi,%rcx
    22a3:	add    $0x2,%rcx
    22a7:	seto   %al
    22aa:	test   %al,%al
    22ac:	je     22bf <botlish_fn_13+0x1a87>
    22b2:	mov    0x230(%rsp),%rsi
    22ba:	jmp    22cf <botlish_fn_13+0x1a97>
    22bf:	mov    %rcx,%rsi
    22c2:	mov    %rcx,0x230(%rsp)
    22ca:	jmp    22ef <botlish_fn_13+0x1ab7>
    22cf:	mov    0x280(%rsp),%rdx
    22d7:	mov    0x1e8(%rsp),%rdi
    22df:	call   22e4 <botlish_fn_13+0x1aac>
			22e0: R_X86_64_PLT32	rt_int_add-0x4
    22e4:	mov    %rax,%rsi
    22e7:	mov    %rax,0x230(%rsp)
    22ef:	mov    %rsi,0x68(%rsp)
    22f4:	mov    0x288(%rsp),%rcx
    22fc:	mov    0x230(%rsp),%rsi
    2304:	mov    %rsi,%rax
    2307:	and    %rcx,%rax
    230a:	test   $0x1,%rax
    2310:	jne    2348 <botlish_fn_13+0x1b10>
    2316:	mov    0x288(%rsp),%rdx
    231e:	mov    0x230(%rsp),%rsi
    2326:	mov    0x1e8(%rsp),%rdi
    232e:	call   2333 <botlish_fn_13+0x1afb>
			232f: R_X86_64_PLT32	rt_int_cmp-0x4
    2333:	mov    $0x2,%ecx
    2338:	test   %rax,%rax
    233b:	cmovl  0x4855(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2343:	jmp    2368 <botlish_fn_13+0x1b30>
    2348:	mov    $0x2,%ecx
    234d:	mov    0x288(%rsp),%rax
    2355:	mov    0x230(%rsp),%rsi
    235d:	cmp    %rax,%rsi
    2360:	cmovl  0x4830(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2368:	cmp    $0x6,%rcx
    236c:	je     2398 <botlish_fn_13+0x1b60>
    2372:	movq   $0xffffffffffffffff,0x48(%rsp)
    237b:	mov    0x258(%rsp),%rax
    2383:	mov    %rax,0x208(%rsp)
    238b:	mov    %rax,0x210(%rsp)
    2393:	jmp    25d4 <botlish_fn_13+0x1d9c>
    2398:	mov    0x230(%rsp),%rsi
    23a0:	test   $0x1,%rsi
    23a7:	je     23d0 <botlish_fn_13+0x1b98>
    23ad:	mov    0x1f0(%rsp),%rsi
    23b5:	mov    0x8(%rsi),%rcx
    23b9:	mov    0x230(%rsp),%rsi
    23c1:	mov    %rsi,%rax
    23c4:	sar    $1,%rax
    23c7:	cmp    %rcx,%rax
    23ca:	jb     24a1 <botlish_fn_13+0x1c69>
    23d0:	mov    0x230(%rsp),%rdx
    23d8:	mov    0x1f0(%rsp),%rsi
    23e0:	mov    0x1e8(%rsp),%rdi
    23e8:	call   23ed <botlish_fn_13+0x1bb5>
			23e9: R_X86_64_PLT32	rt_list_get-0x4
    23ed:	mov    %rax,%rcx
    23f0:	mov    %rax,0x228(%rsp)
    23f8:	test   %rcx,%rax
    23fb:	jne    2494 <botlish_fn_13+0x1c5c>
    2401:	mov    0x1e8(%rsp),%rdi
    2409:	call   240e <botlish_fn_13+0x1bd6>
			240a: R_X86_64_PLT32	rt_co_failed-0x4
    240e:	mov    %rax,0x50(%rsp)
    2413:	mov    %rax,%rsi
    2416:	mov    0x1e8(%rsp),%rdi
    241e:	call   2423 <botlish_fn_13+0x1beb>
			241f: R_X86_64_PLT32	rt_co_resume0-0x4
    2423:	test   %rax,%rax
    2426:	je     2448 <botlish_fn_13+0x1c10>
    242c:	mov    0x1e8(%rsp),%rdi
    2434:	mov    0x10(%rdi),%rax
    2438:	mov    0x50(%rax),%rsi
    243c:	mov    0x130(%rax),%rdx
    2443:	call   2448 <botlish_fn_13+0x1c10>
			2444: R_X86_64_PLT32	rt_raise-0x4
    2448:	mov    0x1e8(%rsp),%rdi
    2450:	call   2455 <botlish_fn_13+0x1c1d>
			2451: R_X86_64_PLT32	rt_declared_error-0x4
    2455:	cmp    $0x40000001,%rax
    245b:	je     246e <botlish_fn_13+0x1c36>
    2461:	mov    0x1e8(%rsp),%rdi
    2469:	jmp    2476 <botlish_fn_13+0x1c3e>
    246e:	mov    0x1e8(%rsp),%rdi
    2476:	mov    0x1e8(%rsp),%rdi
    247e:	call   2483 <botlish_fn_13+0x1c4b>
			247f: R_X86_64_PLT32	rt_declared_error-0x4
    2483:	cmp    $0x40000001,%rax
    2489:	jne    68f3 <botlish_fn_13+0x60bb>
    248f:	jmp    68f3 <botlish_fn_13+0x60bb>
    2494:	mov    0x228(%rsp),%rax
    249c:	jmp    24b9 <botlish_fn_13+0x1c81>
    24a1:	mov    0x1f0(%rsp),%rsi
    24a9:	mov    0x10(%rsi),%rcx
    24ad:	mov    (%rcx,%rax,8),%rax
    24b1:	mov    %rax,0x228(%rsp)
    24b9:	mov    %rax,0x70(%rsp)
    24be:	mov    0x228(%rsp),%rax
    24c6:	mov    0x8(%rax),%r15
    24ca:	mov    %r15,0x220(%rsp)
    24d2:	mov    %r10,%rax
    24d5:	mov    %r10,%rcx
    24d8:	mov    %r10,0x218(%rsp)
    24e0:	xor    %rcx,%rax
    24e3:	mov    %rax,0x218(%rsp)
    24eb:	shl    $1,%r15
    24ee:	mov    %r15,0x220(%rsp)
    24f6:	or     $0x1,%r15
    24fa:	mov    %r15,0x220(%rsp)
    2502:	sar    $1,%r15
    2505:	mov    %r15,0x220(%rsp)
    250d:	jmp    2264 <botlish_fn_13+0x1a2c>
    2512:	mov    0x228(%rsp),%rax
    251a:	movzbq 0x18(%rax),%rax
    251f:	test   %rax,%rax
    2522:	jne    255c <botlish_fn_13+0x1d24>
    2528:	mov    0x218(%rsp),%rax
    2530:	mov    %rax,%rdx
    2533:	shl    $1,%rdx
    2536:	or     $0x1,%rdx
    253a:	mov    0x228(%rsp),%rsi
    2542:	mov    0x1e8(%rsp),%rdi
    254a:	call   254f <botlish_fn_13+0x1d17>
			254b: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    254f:	mov    %rax,0x210(%rsp)
    2557:	jmp    259f <botlish_fn_13+0x1d67>
    255c:	mov    0x218(%rsp),%rax
    2564:	mov    %rax,%rcx
    2567:	shl    $1,%rcx
    256a:	or     $0x1,%rcx
    256e:	sar    $1,%rcx
    2571:	mov    0x228(%rsp),%rax
    2579:	movzbq 0x19(%rax,%rcx,1),%rax
    257f:	mov    %rax,0x210(%rsp)
    2587:	shl    $0x3,%rax
    258b:	mov    %rax,0x210(%rsp)
    2593:	or     $0x4,%rax
    2597:	mov    %rax,0x210(%rsp)
    259f:	shr    $0x3,%rax
    25a3:	mov    %rax,0x210(%rsp)
    25ab:	mov    $0x1,%ecx
    25b0:	mov    %rcx,0x208(%rsp)
    25b8:	shl    $1,%rax
    25bb:	mov    %rax,0x210(%rsp)
    25c3:	or     $0x1,%rax
    25c7:	mov    %rax,0x210(%rsp)
    25cf:	mov    %rax,0x48(%rsp)
    25d4:	mov    0x278(%rsp),%rcx
    25dc:	mov    0x18(%rcx),%rax
    25e0:	test   %rax,%rax
    25e3:	je     6aea <botlish_fn_13+0x62b2>
    25e9:	mov    0x278(%rsp),%rcx
    25f1:	mov    0x10(%rcx),%rax
    25f5:	mov    0x210(%rsp),%rcx
    25fd:	mov    %rcx,(%rax)
    2600:	test   %r14,%r14
    2603:	jl     64d4 <botlish_fn_13+0x5c9c>
    2609:	mov    0x270(%rsp),%rcx
    2611:	mov    0x10(%rcx),%rax
    2615:	mov    (%rax),%rsi
    2618:	mov    %rsi,0x30(%rsp)
    261d:	mov    0x248(%rsp),%rcx
    2625:	mov    %rsi,%rax
    2628:	and    %rcx,%rax
    262b:	test   $0x1,%rax
    2631:	je     266c <botlish_fn_13+0x1e34>
    2637:	mov    0x248(%rsp),%rax
    263f:	mov    %rsi,%rcx
    2642:	sub    %rax,%rcx
    2645:	mov    %rsi,%rdx
    2648:	seto   %al
    264b:	lea    0x1(%rcx),%rsi
    264f:	test   %al,%al
    2651:	je     265f <botlish_fn_13+0x1e27>
    2657:	mov    %rdx,%rsi
    265a:	jmp    266c <botlish_fn_13+0x1e34>
    265f:	mov    0x1f8(%rsp),%rdx
    2667:	jmp    268c <botlish_fn_13+0x1e54>
    266c:	mov    0x248(%rsp),%rdx
    2674:	mov    0x1e8(%rsp),%rdi
    267c:	call   2681 <botlish_fn_13+0x1e49>
			267d: R_X86_64_PLT32	rt_int_sub-0x4
    2681:	mov    0x1f8(%rsp),%rdx
    2689:	mov    %rax,%rsi
    268c:	mov    %rsi,%rcx
    268f:	and    %rdx,%rcx
    2692:	mov    %rdx,0x1f8(%rsp)
    269a:	test   $0x1,%rcx
    26a1:	jne    26d1 <botlish_fn_13+0x1e99>
    26a7:	mov    0x1f8(%rsp),%rdx
    26af:	mov    0x1e8(%rsp),%rdi
    26b7:	call   26bc <botlish_fn_13+0x1e84>
			26b8: R_X86_64_PLT32	rt_int_cmp-0x4
    26bc:	mov    $0x2,%ecx
    26c1:	test   %rax,%rax
    26c4:	cmovge 0x44cc(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    26cc:	jmp    26e9 <botlish_fn_13+0x1eb1>
    26d1:	mov    $0x2,%ecx
    26d6:	mov    0x1f8(%rsp),%rdx
    26de:	cmp    %rdx,%rsi
    26e1:	cmovge 0x44af(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    26e9:	cmp    $0x6,%rcx
    26ed:	je     647c <botlish_fn_13+0x5c44>
    26f3:	mov    0x278(%rsp),%rcx
    26fb:	mov    0x10(%rcx),%r10
    26ff:	mov    (%r10),%rsi
    2702:	cmp    $0x1,%r14
    2706:	je     5518 <botlish_fn_13+0x4ce0>
    270c:	cmp    $0x2,%r14
    2710:	je     4fc1 <botlish_fn_13+0x4789>
    2716:	cmp    $0x3,%r14
    271a:	je     368a <botlish_fn_13+0x2e52>
    2720:	cmp    $0x4,%r14
    2724:	je     2746 <botlish_fn_13+0x1f0e>
    272a:	mov    $0xa,%esi
    272f:	cmp    $0xffffffffffffffff,%r14
    2733:	jne    62b8 <botlish_fn_13+0x5a80>
    2739:	mov    0x200(%rsp),%r15
    2741:	jmp    6443 <botlish_fn_13+0x5c0b>
    2746:	mov    %r13,%rbx
    2749:	sar    $1,%r13
    274c:	cmp    $0x6,%r13
    2750:	jl     2ef5 <botlish_fn_13+0x26bd>
    2756:	cmp    $0x9,%r13
    275a:	jl     2c58 <botlish_fn_13+0x2420>
    2760:	cmp    $0xa,%r13
    2764:	jl     2b81 <botlish_fn_13+0x2349>
    276a:	cmp    $0xb,%r13
    276e:	jl     284b <botlish_fn_13+0x2013>
    2774:	test   $0x1,%rsi
    277b:	mov    %rsi,%r14
    277e:	jne    27ae <botlish_fn_13+0x1f76>
    2784:	mov    $0xcb,%edx
    2789:	mov    %r14,%rsi
    278c:	mov    0x1e8(%rsp),%rdi
    2794:	call   2799 <botlish_fn_13+0x1f61>
			2795: R_X86_64_PLT32	rt_int_cmp-0x4
    2799:	mov    $0x2,%ecx
    279e:	test   %rax,%rax
    27a1:	cmovl  0x43ef(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    27a9:	jmp    27c5 <botlish_fn_13+0x1f8d>
    27ae:	mov    $0x2,%ecx
    27b3:	mov    %r14,%rsi
    27b6:	cmp    $0xcb,%rsi
    27bd:	cmovl  0x43d3(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    27c5:	cmp    $0x6,%rcx
    27c9:	je     2840 <botlish_fn_13+0x2008>
    27cf:	mov    %r14,%rsi
    27d2:	test   $0x1,%rsi
    27d9:	jne    2809 <botlish_fn_13+0x1fd1>
    27df:	mov    $0xcd,%edx
    27e4:	mov    %r14,%rsi
    27e7:	mov    0x1e8(%rsp),%rdi
    27ef:	call   27f4 <botlish_fn_13+0x1fbc>
			27f0: R_X86_64_PLT32	rt_int_cmp-0x4
    27f4:	mov    $0x2,%ecx
    27f9:	test   %rax,%rax
    27fc:	cmovl  0x4394(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2804:	jmp    2820 <botlish_fn_13+0x1fe8>
    2809:	mov    $0x2,%ecx
    280e:	mov    %r14,%rsi
    2811:	cmp    $0xcd,%rsi
    2818:	cmovl  0x4378(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2820:	cmp    $0x6,%rcx
    2824:	je     2835 <botlish_fn_13+0x1ffd>
    282a:	mov    $0x33,%r13d
    2830:	jmp    3539 <botlish_fn_13+0x2d01>
    2835:	mov    $0x15,%r13d
    283b:	jmp    3539 <botlish_fn_13+0x2d01>
    2840:	mov    $0x33,%r13d
    2846:	jmp    3539 <botlish_fn_13+0x2d01>
    284b:	mov    %rsi,%r14
    284e:	test   $0x1,%rsi
    2855:	jne    2885 <botlish_fn_13+0x204d>
    285b:	mov    $0x41,%edx
    2860:	mov    %r14,%rsi
    2863:	mov    0x1e8(%rsp),%rdi
    286b:	call   2870 <botlish_fn_13+0x2038>
			286c: R_X86_64_PLT32	rt_int_cmp-0x4
    2870:	mov    $0x2,%ecx
    2875:	test   %rax,%rax
    2878:	cmovl  0x4318(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2880:	jmp    2899 <botlish_fn_13+0x2061>
    2885:	mov    $0x2,%ecx
    288a:	mov    %r14,%rsi
    288d:	cmp    $0x41,%rsi
    2891:	cmovl  0x42ff(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2899:	cmp    $0x6,%rcx
    289d:	je     2a48 <botlish_fn_13+0x2210>
    28a3:	mov    %r14,%rsi
    28a6:	test   $0x1,%rsi
    28ad:	jne    28dd <botlish_fn_13+0x20a5>
    28b3:	mov    $0xbb,%edx
    28b8:	mov    %r14,%rsi
    28bb:	mov    0x1e8(%rsp),%rdi
    28c3:	call   28c8 <botlish_fn_13+0x2090>
			28c4: R_X86_64_PLT32	rt_int_cmp-0x4
    28c8:	mov    $0x2,%ecx
    28cd:	test   %rax,%rax
    28d0:	cmovl  0x42c0(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    28d8:	jmp    28f4 <botlish_fn_13+0x20bc>
    28dd:	mov    $0x2,%ecx
    28e2:	mov    %r14,%rsi
    28e5:	cmp    $0xbb,%rsi
    28ec:	cmovl  0x42a4(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    28f4:	cmp    $0x6,%rcx
    28f8:	je     29f5 <botlish_fn_13+0x21bd>
    28fe:	mov    %r14,%rsi
    2901:	test   $0x1,%rsi
    2908:	jne    2938 <botlish_fn_13+0x2100>
    290e:	mov    $0xfb,%edx
    2913:	mov    %r14,%rsi
    2916:	mov    0x1e8(%rsp),%rdi
    291e:	call   2923 <botlish_fn_13+0x20eb>
			291f: R_X86_64_PLT32	rt_int_cmp-0x4
    2923:	mov    $0x2,%ecx
    2928:	test   %rax,%rax
    292b:	cmovl  0x4265(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2933:	jmp    294f <botlish_fn_13+0x2117>
    2938:	mov    $0x2,%ecx
    293d:	mov    %r14,%rsi
    2940:	cmp    $0xfb,%rsi
    2947:	cmovl  0x4249(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    294f:	cmp    $0x6,%rcx
    2953:	je     29cc <botlish_fn_13+0x2194>
    2959:	mov    %r14,%rsi
    295c:	test   $0x1,%rsi
    2963:	jne    2994 <botlish_fn_13+0x215c>
    2969:	mov    $0xfd,%edx
    296e:	mov    %r14,%rsi
    2971:	mov    0x1e8(%rsp),%rdi
    2979:	call   297e <botlish_fn_13+0x2146>
			297a: R_X86_64_PLT32	rt_int_cmp-0x4
    297e:	mov    $0x2,%r10d
    2984:	test   %rax,%rax
    2987:	cmovl  0x4209(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    298f:	jmp    29ac <botlish_fn_13+0x2174>
    2994:	mov    $0x2,%r10d
    299a:	mov    %r14,%rsi
    299d:	cmp    $0xfd,%rsi
    29a4:	cmovl  0x41ec(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    29ac:	cmp    $0x6,%r10
    29b0:	je     29c1 <botlish_fn_13+0x2189>
    29b6:	mov    $0x31,%r13d
    29bc:	jmp    3539 <botlish_fn_13+0x2d01>
    29c1:	mov    $0x1b,%r13d
    29c7:	jmp    3539 <botlish_fn_13+0x2d01>
    29cc:	mov    %r14,%rsi
    29cf:	mov    %rsi,%rax
    29d2:	sar    $1,%rax
    29d5:	cmp    $0x5e,%rax
    29d9:	jl     29ea <botlish_fn_13+0x21b2>
    29df:	mov    $0x31,%r13d
    29e5:	jmp    3539 <botlish_fn_13+0x2d01>
    29ea:	mov    $0x1b,%r13d
    29f0:	jmp    3539 <botlish_fn_13+0x2d01>
    29f5:	mov    %r14,%rsi
    29f8:	mov    %rsi,%rcx
    29fb:	sar    $1,%rcx
    29fe:	cmp    $0x2c,%rcx
    2a02:	jl     2a28 <botlish_fn_13+0x21f0>
    2a08:	cmp    $0x2d,%rcx
    2a0c:	jl     2a1d <botlish_fn_13+0x21e5>
    2a12:	mov    $0x31,%r13d
    2a18:	jmp    3539 <botlish_fn_13+0x2d01>
    2a1d:	mov    $0x1b,%r13d
    2a23:	jmp    3539 <botlish_fn_13+0x2d01>
    2a28:	cmp    $0x21,%rcx
    2a2c:	jl     2a3d <botlish_fn_13+0x2205>
    2a32:	mov    $0x31,%r13d
    2a38:	jmp    3539 <botlish_fn_13+0x2d01>
    2a3d:	mov    $0x1b,%r13d
    2a43:	jmp    3539 <botlish_fn_13+0x2d01>
    2a48:	mov    %r14,%rsi
    2a4b:	test   $0x1,%rsi
    2a52:	jne    2a82 <botlish_fn_13+0x224a>
    2a58:	mov    $0x13,%edx
    2a5d:	mov    %r14,%rsi
    2a60:	mov    0x1e8(%rsp),%rdi
    2a68:	call   2a6d <botlish_fn_13+0x2235>
			2a69: R_X86_64_PLT32	rt_int_cmp-0x4
    2a6d:	mov    $0x2,%ecx
    2a72:	test   %rax,%rax
    2a75:	cmovl  0x411b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2a7d:	jmp    2a96 <botlish_fn_13+0x225e>
    2a82:	mov    $0x2,%ecx
    2a87:	mov    %r14,%rsi
    2a8a:	cmp    $0x13,%rsi
    2a8e:	cmovl  0x4102(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2a96:	cmp    $0x6,%rcx
    2a9a:	je     2af3 <botlish_fn_13+0x22bb>
    2aa0:	mov    %r14,%rsi
    2aa3:	mov    %rsi,%rcx
    2aa6:	sar    $1,%rcx
    2aa9:	cmp    $0xd,%rcx
    2aad:	jl     2ad3 <botlish_fn_13+0x229b>
    2ab3:	cmp    $0xe,%rcx
    2ab7:	jl     2ac8 <botlish_fn_13+0x2290>
    2abd:	mov    $0x31,%r13d
    2ac3:	jmp    3539 <botlish_fn_13+0x2d01>
    2ac8:	mov    $0x1b,%r13d
    2ace:	jmp    3539 <botlish_fn_13+0x2d01>
    2ad3:	cmp    $0xb,%rcx
    2ad7:	jl     2ae8 <botlish_fn_13+0x22b0>
    2add:	mov    $0x31,%r13d
    2ae3:	jmp    3539 <botlish_fn_13+0x2d01>
    2ae8:	mov    $0x1b,%r13d
    2aee:	jmp    3539 <botlish_fn_13+0x2d01>
    2af3:	mov    %r14,%rsi
    2af6:	test   $0x1,%rsi
    2afd:	jne    2b30 <botlish_fn_13+0x22f8>
    2b03:	mov    0x258(%rsp),%rdx
    2b0b:	mov    %r14,%rsi
    2b0e:	mov    0x1e8(%rsp),%rdi
    2b16:	call   2b1b <botlish_fn_13+0x22e3>
			2b17: R_X86_64_PLT32	rt_int_cmp-0x4
    2b1b:	mov    $0x2,%ecx
    2b20:	test   %rax,%rax
    2b23:	cmovl  0x406d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2b2b:	jmp    2b44 <botlish_fn_13+0x230c>
    2b30:	mov    $0x2,%ecx
    2b35:	mov    %r14,%rsi
    2b38:	cmp    $0xffffffffffffffff,%rsi
    2b3c:	cmovl  0x4054(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2b44:	cmp    $0x6,%rcx
    2b48:	je     2b76 <botlish_fn_13+0x233e>
    2b4e:	mov    %r14,%rsi
    2b51:	mov    %rsi,%rax
    2b54:	sar    $1,%rax
    2b57:	test   %rax,%rax
    2b5a:	jl     2b6b <botlish_fn_13+0x2333>
    2b60:	mov    $0x31,%r13d
    2b66:	jmp    3539 <botlish_fn_13+0x2d01>
    2b6b:	mov    $0x1b,%r13d
    2b71:	jmp    3539 <botlish_fn_13+0x2d01>
    2b76:	mov    $0x31,%r13d
    2b7c:	jmp    3539 <botlish_fn_13+0x2d01>
    2b81:	mov    %rsi,%r14
    2b84:	test   $0x1,%rsi
    2b8b:	jne    2bbb <botlish_fn_13+0x2383>
    2b91:	mov    $0xd9,%edx
    2b96:	mov    %r14,%rsi
    2b99:	mov    0x1e8(%rsp),%rdi
    2ba1:	call   2ba6 <botlish_fn_13+0x236e>
			2ba2: R_X86_64_PLT32	rt_int_cmp-0x4
    2ba6:	mov    $0x2,%ecx
    2bab:	test   %rax,%rax
    2bae:	cmovl  0x3fe2(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2bb6:	jmp    2bd2 <botlish_fn_13+0x239a>
    2bbb:	mov    $0x2,%ecx
    2bc0:	mov    %r14,%rsi
    2bc3:	cmp    $0xd9,%rsi
    2bca:	cmovl  0x3fc6(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2bd2:	cmp    $0x6,%rcx
    2bd6:	je     2c4d <botlish_fn_13+0x2415>
    2bdc:	mov    %r14,%rsi
    2bdf:	test   $0x1,%rsi
    2be6:	jne    2c16 <botlish_fn_13+0x23de>
    2bec:	mov    $0xdb,%edx
    2bf1:	mov    %r14,%rsi
    2bf4:	mov    0x1e8(%rsp),%rdi
    2bfc:	call   2c01 <botlish_fn_13+0x23c9>
			2bfd: R_X86_64_PLT32	rt_int_cmp-0x4
    2c01:	mov    $0x2,%ecx
    2c06:	test   %rax,%rax
    2c09:	cmovl  0x3f87(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2c11:	jmp    2c2d <botlish_fn_13+0x23f5>
    2c16:	mov    $0x2,%ecx
    2c1b:	mov    %r14,%rsi
    2c1e:	cmp    $0xdb,%rsi
    2c25:	cmovl  0x3f6b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2c2d:	cmp    $0x6,%rcx
    2c31:	je     2c42 <botlish_fn_13+0x240a>
    2c37:	mov    $0x2f,%r13d
    2c3d:	jmp    3539 <botlish_fn_13+0x2d01>
    2c42:	mov    $0x15,%r13d
    2c48:	jmp    3539 <botlish_fn_13+0x2d01>
    2c4d:	mov    $0x2f,%r13d
    2c53:	jmp    3539 <botlish_fn_13+0x2d01>
    2c58:	mov    %rsi,%r14
    2c5b:	cmp    $0x7,%r13
    2c5f:	jl     2e1c <botlish_fn_13+0x25e4>
    2c65:	cmp    $0x8,%r13
    2c69:	jl     2d45 <botlish_fn_13+0x250d>
    2c6f:	mov    %r14,%rsi
    2c72:	test   $0x1,%rsi
    2c79:	jne    2ca9 <botlish_fn_13+0x2471>
    2c7f:	mov    $0xe7,%edx
    2c84:	mov    %r14,%rsi
    2c87:	mov    0x1e8(%rsp),%rdi
    2c8f:	call   2c94 <botlish_fn_13+0x245c>
			2c90: R_X86_64_PLT32	rt_int_cmp-0x4
    2c94:	mov    $0x2,%esi
    2c99:	test   %rax,%rax
    2c9c:	cmovl  0x3ef4(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    2ca4:	jmp    2cbf <botlish_fn_13+0x2487>
    2ca9:	mov    $0x2,%esi
    2cae:	mov    %r14,%rax
    2cb1:	cmp    $0xe7,%rax
    2cb7:	cmovl  0x3ed9(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    2cbf:	cmp    $0x6,%rsi
    2cc3:	je     2d3a <botlish_fn_13+0x2502>
    2cc9:	mov    %r14,%rsi
    2ccc:	test   $0x1,%rsi
    2cd3:	jne    2d03 <botlish_fn_13+0x24cb>
    2cd9:	mov    $0xe9,%edx
    2cde:	mov    %r14,%rsi
    2ce1:	mov    0x1e8(%rsp),%rdi
    2ce9:	call   2cee <botlish_fn_13+0x24b6>
			2cea: R_X86_64_PLT32	rt_int_cmp-0x4
    2cee:	mov    $0x2,%ecx
    2cf3:	test   %rax,%rax
    2cf6:	cmovl  0x3e9a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2cfe:	jmp    2d1a <botlish_fn_13+0x24e2>
    2d03:	mov    $0x2,%ecx
    2d08:	mov    %r14,%rsi
    2d0b:	cmp    $0xe9,%rsi
    2d12:	cmovl  0x3e7e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2d1a:	cmp    $0x6,%rcx
    2d1e:	je     2d2f <botlish_fn_13+0x24f7>
    2d24:	mov    $0x2d,%r13d
    2d2a:	jmp    3539 <botlish_fn_13+0x2d01>
    2d2f:	mov    $0x17,%r13d
    2d35:	jmp    3539 <botlish_fn_13+0x2d01>
    2d3a:	mov    $0x2d,%r13d
    2d40:	jmp    3539 <botlish_fn_13+0x2d01>
    2d45:	mov    %r14,%rsi
    2d48:	test   $0x1,%rsi
    2d4f:	jne    2d7f <botlish_fn_13+0x2547>
    2d55:	mov    $0xcb,%edx
    2d5a:	mov    %r14,%rsi
    2d5d:	mov    0x1e8(%rsp),%rdi
    2d65:	call   2d6a <botlish_fn_13+0x2532>
			2d66: R_X86_64_PLT32	rt_int_cmp-0x4
    2d6a:	mov    $0x2,%ecx
    2d6f:	test   %rax,%rax
    2d72:	cmovl  0x3e1e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2d7a:	jmp    2d96 <botlish_fn_13+0x255e>
    2d7f:	mov    $0x2,%ecx
    2d84:	mov    %r14,%rsi
    2d87:	cmp    $0xcb,%rsi
    2d8e:	cmovl  0x3e02(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2d96:	cmp    $0x6,%rcx
    2d9a:	je     2e11 <botlish_fn_13+0x25d9>
    2da0:	mov    %r14,%rsi
    2da3:	test   $0x1,%rsi
    2daa:	jne    2dda <botlish_fn_13+0x25a2>
    2db0:	mov    $0xcd,%edx
    2db5:	mov    %r14,%rsi
    2db8:	mov    0x1e8(%rsp),%rdi
    2dc0:	call   2dc5 <botlish_fn_13+0x258d>
			2dc1: R_X86_64_PLT32	rt_int_cmp-0x4
    2dc5:	mov    $0x2,%ecx
    2dca:	test   %rax,%rax
    2dcd:	cmovl  0x3dc3(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2dd5:	jmp    2df1 <botlish_fn_13+0x25b9>
    2dda:	mov    $0x2,%ecx
    2ddf:	mov    %r14,%rsi
    2de2:	cmp    $0xcd,%rsi
    2de9:	cmovl  0x3da7(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2df1:	cmp    $0x6,%rcx
    2df5:	je     2e06 <botlish_fn_13+0x25ce>
    2dfb:	mov    $0x2b,%r13d
    2e01:	jmp    3539 <botlish_fn_13+0x2d01>
    2e06:	mov    $0x15,%r13d
    2e0c:	jmp    3539 <botlish_fn_13+0x2d01>
    2e11:	mov    $0x2b,%r13d
    2e17:	jmp    3539 <botlish_fn_13+0x2d01>
    2e1c:	mov    %r14,%rsi
    2e1f:	test   $0x1,%rsi
    2e26:	jne    2e57 <botlish_fn_13+0x261f>
    2e2c:	mov    $0xd9,%edx
    2e31:	mov    %r14,%rsi
    2e34:	mov    0x1e8(%rsp),%rdi
    2e3c:	call   2e41 <botlish_fn_13+0x2609>
			2e3d: R_X86_64_PLT32	rt_int_cmp-0x4
    2e41:	mov    $0x2,%r8d
    2e47:	test   %rax,%rax
    2e4a:	cmovl  0x3d46(%rip),%r8        # 6b98 <botlish_fn_13+0x6360>
    2e52:	jmp    2e6f <botlish_fn_13+0x2637>
    2e57:	mov    $0x2,%r8d
    2e5d:	mov    %r14,%rsi
    2e60:	cmp    $0xd9,%rsi
    2e67:	cmovl  0x3d29(%rip),%r8        # 6b98 <botlish_fn_13+0x6360>
    2e6f:	cmp    $0x6,%r8
    2e73:	je     2eea <botlish_fn_13+0x26b2>
    2e79:	mov    %r14,%rsi
    2e7c:	test   $0x1,%rsi
    2e83:	jne    2eb3 <botlish_fn_13+0x267b>
    2e89:	mov    $0xdb,%edx
    2e8e:	mov    %r14,%rsi
    2e91:	mov    0x1e8(%rsp),%rdi
    2e99:	call   2e9e <botlish_fn_13+0x2666>
			2e9a: R_X86_64_PLT32	rt_int_cmp-0x4
    2e9e:	mov    $0x2,%ecx
    2ea3:	test   %rax,%rax
    2ea6:	cmovl  0x3cea(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2eae:	jmp    2eca <botlish_fn_13+0x2692>
    2eb3:	mov    $0x2,%ecx
    2eb8:	mov    %r14,%rsi
    2ebb:	cmp    $0xdb,%rsi
    2ec2:	cmovl  0x3cce(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2eca:	cmp    $0x6,%rcx
    2ece:	je     2edf <botlish_fn_13+0x26a7>
    2ed4:	mov    $0x29,%r13d
    2eda:	jmp    3539 <botlish_fn_13+0x2d01>
    2edf:	mov    $0x13,%r13d
    2ee5:	jmp    3539 <botlish_fn_13+0x2d01>
    2eea:	mov    $0x29,%r13d
    2ef0:	jmp    3539 <botlish_fn_13+0x2d01>
    2ef5:	mov    %rsi,%r14
    2ef8:	cmp    $0x3,%r13
    2efc:	jl     319b <botlish_fn_13+0x2963>
    2f02:	cmp    $0x4,%r13
    2f06:	jl     30c4 <botlish_fn_13+0x288c>
    2f0c:	cmp    $0x5,%r13
    2f10:	jl     2fed <botlish_fn_13+0x27b5>
    2f16:	mov    %r14,%rsi
    2f19:	test   $0x1,%rsi
    2f20:	jne    2f50 <botlish_fn_13+0x2718>
    2f26:	mov    $0xd9,%edx
    2f2b:	mov    %r14,%rsi
    2f2e:	mov    0x1e8(%rsp),%rdi
    2f36:	call   2f3b <botlish_fn_13+0x2703>
			2f37: R_X86_64_PLT32	rt_int_cmp-0x4
    2f3b:	mov    $0x2,%ecx
    2f40:	test   %rax,%rax
    2f43:	cmovl  0x3c4d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2f4b:	jmp    2f67 <botlish_fn_13+0x272f>
    2f50:	mov    $0x2,%ecx
    2f55:	mov    %r14,%rsi
    2f58:	cmp    $0xd9,%rsi
    2f5f:	cmovl  0x3c31(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2f67:	cmp    $0x6,%rcx
    2f6b:	je     2fe2 <botlish_fn_13+0x27aa>
    2f71:	mov    %r14,%rsi
    2f74:	test   $0x1,%rsi
    2f7b:	jne    2fab <botlish_fn_13+0x2773>
    2f81:	mov    $0xdb,%edx
    2f86:	mov    %r14,%rsi
    2f89:	mov    0x1e8(%rsp),%rdi
    2f91:	call   2f96 <botlish_fn_13+0x275e>
			2f92: R_X86_64_PLT32	rt_int_cmp-0x4
    2f96:	mov    $0x2,%ecx
    2f9b:	test   %rax,%rax
    2f9e:	cmovl  0x3bf2(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2fa6:	jmp    2fc2 <botlish_fn_13+0x278a>
    2fab:	mov    $0x2,%ecx
    2fb0:	mov    %r14,%rsi
    2fb3:	cmp    $0xdb,%rsi
    2fba:	cmovl  0x3bd6(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    2fc2:	cmp    $0x6,%rcx
    2fc6:	je     2fd7 <botlish_fn_13+0x279f>
    2fcc:	mov    $0x27,%r13d
    2fd2:	jmp    3539 <botlish_fn_13+0x2d01>
    2fd7:	mov    $0x11,%r13d
    2fdd:	jmp    3539 <botlish_fn_13+0x2d01>
    2fe2:	mov    $0x27,%r13d
    2fe8:	jmp    3539 <botlish_fn_13+0x2d01>
    2fed:	mov    %r14,%rsi
    2ff0:	test   $0x1,%rsi
    2ff7:	jne    3027 <botlish_fn_13+0x27ef>
    2ffd:	mov    $0xeb,%edx
    3002:	mov    %r14,%rsi
    3005:	mov    0x1e8(%rsp),%rdi
    300d:	call   3012 <botlish_fn_13+0x27da>
			300e: R_X86_64_PLT32	rt_int_cmp-0x4
    3012:	mov    $0x2,%ecx
    3017:	test   %rax,%rax
    301a:	cmovl  0x3b76(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3022:	jmp    303e <botlish_fn_13+0x2806>
    3027:	mov    $0x2,%ecx
    302c:	mov    %r14,%rsi
    302f:	cmp    $0xeb,%rsi
    3036:	cmovl  0x3b5a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    303e:	cmp    $0x6,%rcx
    3042:	je     30b9 <botlish_fn_13+0x2881>
    3048:	mov    %r14,%rsi
    304b:	test   $0x1,%rsi
    3052:	jne    3082 <botlish_fn_13+0x284a>
    3058:	mov    $0xed,%edx
    305d:	mov    %r14,%rsi
    3060:	mov    0x1e8(%rsp),%rdi
    3068:	call   306d <botlish_fn_13+0x2835>
			3069: R_X86_64_PLT32	rt_int_cmp-0x4
    306d:	mov    $0x2,%ecx
    3072:	test   %rax,%rax
    3075:	cmovl  0x3b1b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    307d:	jmp    3099 <botlish_fn_13+0x2861>
    3082:	mov    $0x2,%ecx
    3087:	mov    %r14,%rsi
    308a:	cmp    $0xed,%rsi
    3091:	cmovl  0x3aff(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3099:	cmp    $0x6,%rcx
    309d:	je     30ae <botlish_fn_13+0x2876>
    30a3:	mov    $0x25,%r13d
    30a9:	jmp    3539 <botlish_fn_13+0x2d01>
    30ae:	mov    $0xf,%r13d
    30b4:	jmp    3539 <botlish_fn_13+0x2d01>
    30b9:	mov    $0x25,%r13d
    30bf:	jmp    3539 <botlish_fn_13+0x2d01>
    30c4:	mov    %r14,%rsi
    30c7:	test   $0x1,%rsi
    30ce:	jne    30fe <botlish_fn_13+0x28c6>
    30d4:	mov    $0xeb,%edx
    30d9:	mov    %r14,%rsi
    30dc:	mov    0x1e8(%rsp),%rdi
    30e4:	call   30e9 <botlish_fn_13+0x28b1>
			30e5: R_X86_64_PLT32	rt_int_cmp-0x4
    30e9:	mov    $0x2,%ecx
    30ee:	test   %rax,%rax
    30f1:	cmovl  0x3a9f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    30f9:	jmp    3115 <botlish_fn_13+0x28dd>
    30fe:	mov    $0x2,%ecx
    3103:	mov    %r14,%rsi
    3106:	cmp    $0xeb,%rsi
    310d:	cmovl  0x3a83(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3115:	cmp    $0x6,%rcx
    3119:	je     3190 <botlish_fn_13+0x2958>
    311f:	mov    %r14,%rsi
    3122:	test   $0x1,%rsi
    3129:	jne    3159 <botlish_fn_13+0x2921>
    312f:	mov    $0xed,%edx
    3134:	mov    %r14,%rsi
    3137:	mov    0x1e8(%rsp),%rdi
    313f:	call   3144 <botlish_fn_13+0x290c>
			3140: R_X86_64_PLT32	rt_int_cmp-0x4
    3144:	mov    $0x2,%ecx
    3149:	test   %rax,%rax
    314c:	cmovl  0x3a44(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3154:	jmp    3170 <botlish_fn_13+0x2938>
    3159:	mov    $0x2,%ecx
    315e:	mov    %r14,%rsi
    3161:	cmp    $0xed,%rsi
    3168:	cmovl  0x3a28(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3170:	cmp    $0x6,%rcx
    3174:	je     3185 <botlish_fn_13+0x294d>
    317a:	mov    $0x23,%r13d
    3180:	jmp    3539 <botlish_fn_13+0x2d01>
    3185:	mov    $0xd,%r13d
    318b:	jmp    3539 <botlish_fn_13+0x2d01>
    3190:	mov    $0x23,%r13d
    3196:	jmp    3539 <botlish_fn_13+0x2d01>
    319b:	test   %r13,%r13
    319e:	jle    335b <botlish_fn_13+0x2b23>
    31a4:	cmp    $0x2,%r13
    31a8:	jl     3285 <botlish_fn_13+0x2a4d>
    31ae:	mov    %r14,%rsi
    31b1:	test   $0x1,%rsi
    31b8:	jne    31e8 <botlish_fn_13+0x29b0>
    31be:	mov    $0xc3,%edx
    31c3:	mov    %r14,%rsi
    31c6:	mov    0x1e8(%rsp),%rdi
    31ce:	call   31d3 <botlish_fn_13+0x299b>
			31cf: R_X86_64_PLT32	rt_int_cmp-0x4
    31d3:	mov    $0x2,%ecx
    31d8:	test   %rax,%rax
    31db:	cmovl  0x39b5(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    31e3:	jmp    31ff <botlish_fn_13+0x29c7>
    31e8:	mov    $0x2,%ecx
    31ed:	mov    %r14,%rsi
    31f0:	cmp    $0xc3,%rsi
    31f7:	cmovl  0x3999(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    31ff:	cmp    $0x6,%rcx
    3203:	je     327a <botlish_fn_13+0x2a42>
    3209:	mov    %r14,%rsi
    320c:	test   $0x1,%rsi
    3213:	jne    3243 <botlish_fn_13+0x2a0b>
    3219:	mov    $0xc5,%edx
    321e:	mov    %r14,%rsi
    3221:	mov    0x1e8(%rsp),%rdi
    3229:	call   322e <botlish_fn_13+0x29f6>
			322a: R_X86_64_PLT32	rt_int_cmp-0x4
    322e:	mov    $0x2,%ecx
    3233:	test   %rax,%rax
    3236:	cmovl  0x395a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    323e:	jmp    325a <botlish_fn_13+0x2a22>
    3243:	mov    $0x2,%ecx
    3248:	mov    %r14,%rsi
    324b:	cmp    $0xc5,%rsi
    3252:	cmovl  0x393e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    325a:	cmp    $0x6,%rcx
    325e:	je     326f <botlish_fn_13+0x2a37>
    3264:	mov    $0x21,%r13d
    326a:	jmp    3539 <botlish_fn_13+0x2d01>
    326f:	mov    $0xb,%r13d
    3275:	jmp    3539 <botlish_fn_13+0x2d01>
    327a:	mov    $0x21,%r13d
    3280:	jmp    3539 <botlish_fn_13+0x2d01>
    3285:	mov    %r14,%rsi
    3288:	test   $0x1,%rsi
    328f:	jne    32bf <botlish_fn_13+0x2a87>
    3295:	mov    $0xe5,%edx
    329a:	mov    %r14,%rsi
    329d:	mov    0x1e8(%rsp),%rdi
    32a5:	call   32aa <botlish_fn_13+0x2a72>
			32a6: R_X86_64_PLT32	rt_int_cmp-0x4
    32aa:	mov    $0x2,%ecx
    32af:	test   %rax,%rax
    32b2:	cmovl  0x38de(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    32ba:	jmp    32d6 <botlish_fn_13+0x2a9e>
    32bf:	mov    $0x2,%ecx
    32c4:	mov    %r14,%rsi
    32c7:	cmp    $0xe5,%rsi
    32ce:	cmovl  0x38c2(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    32d6:	cmp    $0x6,%rcx
    32da:	je     3350 <botlish_fn_13+0x2b18>
    32e0:	mov    %r14,%rsi
    32e3:	test   $0x1,%rsi
    32ea:	jne    331a <botlish_fn_13+0x2ae2>
    32f0:	mov    $0xe7,%edx
    32f5:	mov    %r14,%rsi
    32f8:	mov    0x1e8(%rsp),%rdi
    3300:	call   3305 <botlish_fn_13+0x2acd>
			3301: R_X86_64_PLT32	rt_int_cmp-0x4
    3305:	mov    $0x2,%esi
    330a:	test   %rax,%rax
    330d:	cmovl  0x3883(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    3315:	jmp    3330 <botlish_fn_13+0x2af8>
    331a:	mov    $0x2,%esi
    331f:	mov    %r14,%rax
    3322:	cmp    $0xe7,%rax
    3328:	cmovl  0x3868(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    3330:	cmp    $0x6,%rsi
    3334:	je     3345 <botlish_fn_13+0x2b0d>
    333a:	mov    $0x1f,%r13d
    3340:	jmp    3539 <botlish_fn_13+0x2d01>
    3345:	mov    $0x9,%r13d
    334b:	jmp    3539 <botlish_fn_13+0x2d01>
    3350:	mov    $0x1f,%r13d
    3356:	jmp    3539 <botlish_fn_13+0x2d01>
    335b:	mov    %r14,%rsi
    335e:	test   $0x1,%rsi
    3365:	jne    3395 <botlish_fn_13+0x2b5d>
    336b:	mov    $0xdd,%edx
    3370:	mov    %r14,%rsi
    3373:	mov    0x1e8(%rsp),%rdi
    337b:	call   3380 <botlish_fn_13+0x2b48>
			337c: R_X86_64_PLT32	rt_int_cmp-0x4
    3380:	mov    $0x2,%ecx
    3385:	test   %rax,%rax
    3388:	cmovl  0x3808(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3390:	jmp    33ac <botlish_fn_13+0x2b74>
    3395:	mov    $0x2,%ecx
    339a:	mov    %r14,%rsi
    339d:	cmp    $0xdd,%rsi
    33a4:	cmovl  0x37ec(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    33ac:	cmp    $0x6,%rcx
    33b0:	je     34ad <botlish_fn_13+0x2c75>
    33b6:	mov    %r14,%rsi
    33b9:	test   $0x1,%rsi
    33c0:	jne    33f0 <botlish_fn_13+0x2bb8>
    33c6:	mov    $0xe9,%edx
    33cb:	mov    %r14,%rsi
    33ce:	mov    0x1e8(%rsp),%rdi
    33d6:	call   33db <botlish_fn_13+0x2ba3>
			33d7: R_X86_64_PLT32	rt_int_cmp-0x4
    33db:	mov    $0x2,%ecx
    33e0:	test   %rax,%rax
    33e3:	cmovl  0x37ad(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    33eb:	jmp    3407 <botlish_fn_13+0x2bcf>
    33f0:	mov    $0x2,%ecx
    33f5:	mov    %r14,%rsi
    33f8:	cmp    $0xe9,%rsi
    33ff:	cmovl  0x3791(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3407:	cmp    $0x6,%rcx
    340b:	je     3484 <botlish_fn_13+0x2c4c>
    3411:	mov    %r14,%rsi
    3414:	test   $0x1,%rsi
    341b:	jne    344b <botlish_fn_13+0x2c13>
    3421:	mov    $0xeb,%edx
    3426:	mov    %r14,%rsi
    3429:	mov    0x1e8(%rsp),%rdi
    3431:	call   3436 <botlish_fn_13+0x2bfe>
			3432: R_X86_64_PLT32	rt_int_cmp-0x4
    3436:	mov    $0x2,%ecx
    343b:	test   %rax,%rax
    343e:	cmovl  0x3752(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3446:	jmp    3462 <botlish_fn_13+0x2c2a>
    344b:	mov    $0x2,%ecx
    3450:	mov    %r14,%rsi
    3453:	cmp    $0xeb,%rsi
    345a:	cmovl  0x3736(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3462:	cmp    $0x6,%rcx
    3466:	je     3477 <botlish_fn_13+0x2c3f>
    346c:	mov    $0x1d,%r13d
    3472:	jmp    3539 <botlish_fn_13+0x2d01>
    3477:	mov    0x280(%rsp),%r13
    347f:	jmp    3539 <botlish_fn_13+0x2d01>
    3484:	mov    %r14,%rsi
    3487:	mov    %rsi,%rdi
    348a:	sar    $1,%rdi
    348d:	cmp    $0x6f,%rdi
    3491:	jl     34a2 <botlish_fn_13+0x2c6a>
    3497:	mov    $0x1d,%r13d
    349d:	jmp    3539 <botlish_fn_13+0x2d01>
    34a2:	mov    $0x7,%r13d
    34a8:	jmp    3539 <botlish_fn_13+0x2d01>
    34ad:	mov    %r14,%rsi
    34b0:	test   $0x1,%rsi
    34b7:	jne    34e8 <botlish_fn_13+0x2cb0>
    34bd:	mov    $0xcd,%edx
    34c2:	mov    %r14,%rsi
    34c5:	mov    0x1e8(%rsp),%rdi
    34cd:	call   34d2 <botlish_fn_13+0x2c9a>
			34ce: R_X86_64_PLT32	rt_int_cmp-0x4
    34d2:	mov    $0x2,%r8d
    34d8:	test   %rax,%rax
    34db:	cmovl  0x36b5(%rip),%r8        # 6b98 <botlish_fn_13+0x6360>
    34e3:	jmp    3500 <botlish_fn_13+0x2cc8>
    34e8:	mov    $0x2,%r8d
    34ee:	mov    %r14,%rsi
    34f1:	cmp    $0xcd,%rsi
    34f8:	cmovl  0x3698(%rip),%r8        # 6b98 <botlish_fn_13+0x6360>
    3500:	cmp    $0x6,%r8
    3504:	je     3533 <botlish_fn_13+0x2cfb>
    350a:	mov    %r14,%rsi
    350d:	mov    %rsi,%rax
    3510:	sar    $1,%rax
    3513:	cmp    $0x67,%rax
    3517:	jl     3528 <botlish_fn_13+0x2cf0>
    351d:	mov    $0x1d,%r13d
    3523:	jmp    3539 <botlish_fn_13+0x2d01>
    3528:	mov    $0x5,%r13d
    352e:	jmp    3539 <botlish_fn_13+0x2d01>
    3533:	mov    $0x1d,%r13d
    3539:	mov    %r13,%rsi
    353c:	sar    $1,%rsi
    353f:	cmp    $0xc,%rsi
    3543:	jl     365f <botlish_fn_13+0x2e27>
    3549:	cmp    $0xd,%rsi
    354d:	mov    %rsi,%r13
    3550:	je     3654 <botlish_fn_13+0x2e1c>
    3556:	mov    %r14,%rsi
    3559:	test   $0x1,%rsi
    3560:	jne    3593 <botlish_fn_13+0x2d5b>
    3566:	mov    0x258(%rsp),%rdx
    356e:	mov    %r14,%rsi
    3571:	mov    0x1e8(%rsp),%rdi
    3579:	call   357e <botlish_fn_13+0x2d46>
			357a: R_X86_64_PLT32	rt_int_cmp-0x4
    357e:	mov    $0x2,%ecx
    3583:	test   %rax,%rax
    3586:	cmove  0x360a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    358e:	jmp    35a7 <botlish_fn_13+0x2d6f>
    3593:	mov    $0x2,%ecx
    3598:	mov    %r14,%rsi
    359b:	cmp    $0xffffffffffffffff,%rsi
    359f:	cmove  0x35f1(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    35a7:	cmp    $0x6,%rcx
    35ab:	je     3609 <botlish_fn_13+0x2dd1>
    35b1:	mov    %r13,%rsi
    35b4:	mov    0x1e8(%rsp),%rdi
    35bc:	call   35c1 <botlish_fn_13+0x2d89>
			35bd: R_X86_64_PLT32	botlish_fn_3-0x4
    35c1:	mov    0x1e8(%rsp),%rdi
    35c9:	mov    0x10(%rdi),%rcx
    35cd:	mov    0x158(%rcx),%rdx
    35d4:	lea    0x1c0(%rsp),%r9
    35dc:	mov    %rax,0x1c0(%rsp)
    35e4:	mov    %r14,%rsi
    35e7:	mov    %rsi,0x1c8(%rsp)
    35ef:	mov    $0x1,%esi
    35f4:	mov    $0x5,%ecx
    35f9:	mov    $0x2,%r8d
    35ff:	call   3604 <botlish_fn_13+0x2dcc>
			3600: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3604:	jmp    62a0 <botlish_fn_13+0x5a68>
    3609:	mov    %r13,%rsi
    360c:	mov    0x1e8(%rsp),%rdi
    3614:	call   3619 <botlish_fn_13+0x2de1>
			3615: R_X86_64_PLT32	botlish_fn_3-0x4
    3619:	mov    0x1e8(%rsp),%rdi
    3621:	mov    0x10(%rdi),%rcx
    3625:	mov    0x150(%rcx),%rdx
    362c:	lea    0x1b8(%rsp),%r9
    3634:	mov    %rax,0x1b8(%rsp)
    363c:	mov    $0x2,%ecx
    3641:	mov    $0x1,%r8d
    3647:	mov    %rcx,%rsi
    364a:	call   364f <botlish_fn_13+0x2e17>
			364b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    364f:	jmp    62a0 <botlish_fn_13+0x5a68>
    3654:	mov    %rbx,%r13
    3657:	mov    %r12,%rbx
    365a:	jmp    4f7e <botlish_fn_13+0x4746>
    365f:	mov    %r13,0xa0(%rsp)
    3667:	mov    $0x6,%ebx
    366c:	movq   $0x6,0x78(%rsp)
    3675:	mov    0x250(%rsp),%r14
    367d:	mov    0x200(%rsp),%r15
    3685:	jmp    6443 <botlish_fn_13+0x5c0b>
    368a:	mov    %rsi,%r14
    368d:	mov    %r12,%rbx
    3690:	sar    $1,%r12
    3693:	cmp    $0x4,%r12
    3697:	jl     428a <botlish_fn_13+0x3a52>
    369d:	cmp    $0x6,%r12
    36a1:	jl     3fda <botlish_fn_13+0x37a2>
    36a7:	cmp    $0x7,%r12
    36ab:	jl     3b89 <botlish_fn_13+0x3351>
    36b1:	cmp    $0x8,%r12
    36b5:	jl     3ab8 <botlish_fn_13+0x3280>
    36bb:	mov    %r14,%rsi
    36be:	test   $0x1,%rsi
    36c5:	jne    36f5 <botlish_fn_13+0x2ebd>
    36cb:	mov    $0x43,%edx
    36d0:	mov    %r14,%rsi
    36d3:	mov    0x1e8(%rsp),%rdi
    36db:	call   36e0 <botlish_fn_13+0x2ea8>
			36dc: R_X86_64_PLT32	rt_int_cmp-0x4
    36e0:	mov    $0x2,%ecx
    36e5:	test   %rax,%rax
    36e8:	cmovl  0x34a8(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    36f0:	jmp    3709 <botlish_fn_13+0x2ed1>
    36f5:	mov    $0x2,%ecx
    36fa:	mov    %r14,%rsi
    36fd:	cmp    $0x43,%rsi
    3701:	cmovl  0x348f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3709:	cmp    $0x6,%rcx
    370d:	je     3919 <botlish_fn_13+0x30e1>
    3713:	mov    %r14,%rsi
    3716:	test   $0x1,%rsi
    371d:	jne    374d <botlish_fn_13+0x2f15>
    3723:	mov    $0x75,%edx
    3728:	mov    %r14,%rsi
    372b:	mov    0x1e8(%rsp),%rdi
    3733:	call   3738 <botlish_fn_13+0x2f00>
			3734: R_X86_64_PLT32	rt_int_cmp-0x4
    3738:	mov    $0x2,%ecx
    373d:	test   %rax,%rax
    3740:	cmovl  0x3450(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3748:	jmp    3761 <botlish_fn_13+0x2f29>
    374d:	mov    $0x2,%ecx
    3752:	mov    %r14,%rsi
    3755:	cmp    $0x75,%rsi
    3759:	cmovl  0x3437(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3761:	cmp    $0x6,%rcx
    3765:	je     38c6 <botlish_fn_13+0x308e>
    376b:	mov    %r14,%rsi
    376e:	test   $0x1,%rsi
    3775:	jne    37a5 <botlish_fn_13+0x2f6d>
    377b:	mov    $0xbd,%edx
    3780:	mov    %r14,%rsi
    3783:	mov    0x1e8(%rsp),%rdi
    378b:	call   3790 <botlish_fn_13+0x2f58>
			378c: R_X86_64_PLT32	rt_int_cmp-0x4
    3790:	mov    $0x2,%ecx
    3795:	test   %rax,%rax
    3798:	cmovl  0x33f8(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    37a0:	jmp    37bc <botlish_fn_13+0x2f84>
    37a5:	mov    $0x2,%ecx
    37aa:	mov    %r14,%rsi
    37ad:	cmp    $0xbd,%rsi
    37b4:	cmovl  0x33dc(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    37bc:	cmp    $0x6,%rcx
    37c0:	je     389d <botlish_fn_13+0x3065>
    37c6:	mov    %r14,%rsi
    37c9:	test   $0x1,%rsi
    37d0:	jne    3800 <botlish_fn_13+0x2fc8>
    37d6:	mov    $0xfb,%edx
    37db:	mov    %r14,%rsi
    37de:	mov    0x1e8(%rsp),%rdi
    37e6:	call   37eb <botlish_fn_13+0x2fb3>
			37e7: R_X86_64_PLT32	rt_int_cmp-0x4
    37eb:	mov    $0x2,%ecx
    37f0:	test   %rax,%rax
    37f3:	cmovl  0x339d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    37fb:	jmp    3817 <botlish_fn_13+0x2fdf>
    3800:	mov    $0x2,%ecx
    3805:	mov    %r14,%rsi
    3808:	cmp    $0xfb,%rsi
    380f:	cmovl  0x3381(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3817:	cmp    $0x6,%rcx
    381b:	je     3892 <botlish_fn_13+0x305a>
    3821:	mov    %r14,%rsi
    3824:	test   $0x1,%rsi
    382b:	jne    385b <botlish_fn_13+0x3023>
    3831:	mov    $0xfd,%edx
    3836:	mov    %r14,%rsi
    3839:	mov    0x1e8(%rsp),%rdi
    3841:	call   3846 <botlish_fn_13+0x300e>
			3842: R_X86_64_PLT32	rt_int_cmp-0x4
    3846:	mov    $0x2,%ecx
    384b:	test   %rax,%rax
    384e:	cmovl  0x3342(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3856:	jmp    3872 <botlish_fn_13+0x303a>
    385b:	mov    $0x2,%ecx
    3860:	mov    %r14,%rsi
    3863:	cmp    $0xfd,%rsi
    386a:	cmovl  0x3326(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3872:	cmp    $0x6,%rcx
    3876:	je     3887 <botlish_fn_13+0x304f>
    387c:	mov    $0x27,%r12d
    3882:	jmp    4e63 <botlish_fn_13+0x462b>
    3887:	mov    $0x15,%r12d
    388d:	jmp    4e63 <botlish_fn_13+0x462b>
    3892:	mov    $0x27,%r12d
    3898:	jmp    4e63 <botlish_fn_13+0x462b>
    389d:	mov    %r14,%rsi
    38a0:	mov    %rsi,%rax
    38a3:	sar    $1,%rax
    38a6:	cmp    $0x5d,%rax
    38aa:	jl     38bb <botlish_fn_13+0x3083>
    38b0:	mov    $0x15,%r12d
    38b6:	jmp    4e63 <botlish_fn_13+0x462b>
    38bb:	mov    $0x27,%r12d
    38c1:	jmp    4e63 <botlish_fn_13+0x462b>
    38c6:	mov    %r14,%rsi
    38c9:	mov    %rsi,%rcx
    38cc:	sar    $1,%rcx
    38cf:	cmp    $0x2d,%rcx
    38d3:	jl     38f9 <botlish_fn_13+0x30c1>
    38d9:	cmp    $0x30,%rcx
    38dd:	jl     38ee <botlish_fn_13+0x30b6>
    38e3:	mov    $0x11,%r12d
    38e9:	jmp    4e63 <botlish_fn_13+0x462b>
    38ee:	mov    $0x27,%r12d
    38f4:	jmp    4e63 <botlish_fn_13+0x462b>
    38f9:	cmp    $0x2c,%rcx
    38fd:	jl     390e <botlish_fn_13+0x30d6>
    3903:	mov    $0x15,%r12d
    3909:	jmp    4e63 <botlish_fn_13+0x462b>
    390e:	mov    $0x27,%r12d
    3914:	jmp    4e63 <botlish_fn_13+0x462b>
    3919:	mov    %r14,%rsi
    391c:	test   $0x1,%rsi
    3923:	jne    3953 <botlish_fn_13+0x311b>
    3929:	mov    $0x17,%edx
    392e:	mov    %r14,%rsi
    3931:	mov    0x1e8(%rsp),%rdi
    3939:	call   393e <botlish_fn_13+0x3106>
			393a: R_X86_64_PLT32	rt_int_cmp-0x4
    393e:	mov    $0x2,%ecx
    3943:	test   %rax,%rax
    3946:	cmovl  0x324a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    394e:	jmp    3967 <botlish_fn_13+0x312f>
    3953:	mov    $0x2,%ecx
    3958:	mov    %r14,%rsi
    395b:	cmp    $0x17,%rsi
    395f:	cmovl  0x3231(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3967:	cmp    $0x6,%rcx
    396b:	je     39c4 <botlish_fn_13+0x318c>
    3971:	mov    %r14,%rsi
    3974:	mov    %rsi,%rcx
    3977:	sar    $1,%rcx
    397a:	cmp    $0xe,%rcx
    397e:	jl     39a4 <botlish_fn_13+0x316c>
    3984:	cmp    $0x20,%rcx
    3988:	jl     3999 <botlish_fn_13+0x3161>
    398e:	mov    $0x15,%r12d
    3994:	jmp    4e63 <botlish_fn_13+0x462b>
    3999:	mov    $0x27,%r12d
    399f:	jmp    4e63 <botlish_fn_13+0x462b>
    39a4:	cmp    $0xd,%rcx
    39a8:	jl     39b9 <botlish_fn_13+0x3181>
    39ae:	mov    $0x15,%r12d
    39b4:	jmp    4e63 <botlish_fn_13+0x462b>
    39b9:	mov    $0x27,%r12d
    39bf:	jmp    4e63 <botlish_fn_13+0x462b>
    39c4:	mov    %r14,%rsi
    39c7:	test   $0x1,%rsi
    39ce:	jne    39fe <botlish_fn_13+0x31c6>
    39d4:	mov    $0x1,%edx
    39d9:	mov    %r14,%rsi
    39dc:	mov    0x1e8(%rsp),%rdi
    39e4:	call   39e9 <botlish_fn_13+0x31b1>
			39e5: R_X86_64_PLT32	rt_int_cmp-0x4
    39e9:	mov    $0x2,%esi
    39ee:	test   %rax,%rax
    39f1:	cmovl  0x319f(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    39f9:	jmp    3a14 <botlish_fn_13+0x31dc>
    39fe:	mov    $0x2,%esi
    3a03:	mov    %r14,%rdi
    3a06:	mov    %r14,%r8
    3a09:	test   %r8,%rdi
    3a0c:	cmovle 0x3184(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    3a14:	cmp    $0x6,%rsi
    3a18:	je     3a47 <botlish_fn_13+0x320f>
    3a1e:	mov    %r14,%rsi
    3a21:	mov    %rsi,%rax
    3a24:	sar    $1,%rax
    3a27:	cmp    $0x9,%rax
    3a2b:	jl     3a3c <botlish_fn_13+0x3204>
    3a31:	mov    $0x15,%r12d
    3a37:	jmp    4e63 <botlish_fn_13+0x462b>
    3a3c:	mov    $0x27,%r12d
    3a42:	jmp    4e63 <botlish_fn_13+0x462b>
    3a47:	mov    %r14,%rsi
    3a4a:	test   $0x1,%rsi
    3a51:	jne    3a84 <botlish_fn_13+0x324c>
    3a57:	mov    0x258(%rsp),%rdx
    3a5f:	mov    %r14,%rsi
    3a62:	mov    0x1e8(%rsp),%rdi
    3a6a:	call   3a6f <botlish_fn_13+0x3237>
			3a6b: R_X86_64_PLT32	rt_int_cmp-0x4
    3a6f:	mov    $0x2,%ecx
    3a74:	test   %rax,%rax
    3a77:	cmovl  0x3119(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3a7f:	jmp    3a98 <botlish_fn_13+0x3260>
    3a84:	mov    $0x2,%ecx
    3a89:	mov    %r14,%rsi
    3a8c:	cmp    $0xffffffffffffffff,%rsi
    3a90:	cmovl  0x3100(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3a98:	cmp    $0x6,%rcx
    3a9c:	je     3aad <botlish_fn_13+0x3275>
    3aa2:	mov    $0x15,%r12d
    3aa8:	jmp    4e63 <botlish_fn_13+0x462b>
    3aad:	mov    $0x27,%r12d
    3ab3:	jmp    4e63 <botlish_fn_13+0x462b>
    3ab8:	mov    %r14,%rsi
    3abb:	test   $0x1,%rsi
    3ac2:	jne    3af2 <botlish_fn_13+0x32ba>
    3ac8:	mov    $0x61,%edx
    3acd:	mov    %r14,%rsi
    3ad0:	mov    0x1e8(%rsp),%rdi
    3ad8:	call   3add <botlish_fn_13+0x32a5>
			3ad9: R_X86_64_PLT32	rt_int_cmp-0x4
    3add:	mov    $0x2,%ecx
    3ae2:	test   %rax,%rax
    3ae5:	cmovl  0x30ab(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3aed:	jmp    3b06 <botlish_fn_13+0x32ce>
    3af2:	mov    $0x2,%ecx
    3af7:	mov    %r14,%rsi
    3afa:	cmp    $0x61,%rsi
    3afe:	cmovl  0x3092(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3b06:	cmp    $0x6,%rcx
    3b0a:	je     3b7e <botlish_fn_13+0x3346>
    3b10:	mov    %r14,%rsi
    3b13:	test   $0x1,%rsi
    3b1a:	jne    3b4a <botlish_fn_13+0x3312>
    3b20:	mov    $0x75,%edx
    3b25:	mov    %r14,%rsi
    3b28:	mov    0x1e8(%rsp),%rdi
    3b30:	call   3b35 <botlish_fn_13+0x32fd>
			3b31: R_X86_64_PLT32	rt_int_cmp-0x4
    3b35:	mov    $0x2,%ecx
    3b3a:	test   %rax,%rax
    3b3d:	cmovl  0x3053(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3b45:	jmp    3b5e <botlish_fn_13+0x3326>
    3b4a:	mov    $0x2,%ecx
    3b4f:	mov    %r14,%rsi
    3b52:	cmp    $0x75,%rsi
    3b56:	cmovl  0x303a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3b5e:	cmp    $0x6,%rcx
    3b62:	je     3b73 <botlish_fn_13+0x333b>
    3b68:	mov    $0x25,%r12d
    3b6e:	jmp    4e63 <botlish_fn_13+0x462b>
    3b73:	mov    $0x11,%r12d
    3b79:	jmp    4e63 <botlish_fn_13+0x462b>
    3b7e:	mov    $0x25,%r12d
    3b84:	jmp    4e63 <botlish_fn_13+0x462b>
    3b89:	mov    %r14,%rsi
    3b8c:	test   $0x1,%rsi
    3b93:	jne    3bc3 <botlish_fn_13+0x338b>
    3b99:	mov    $0x5b,%edx
    3b9e:	mov    %r14,%rsi
    3ba1:	mov    0x1e8(%rsp),%rdi
    3ba9:	call   3bae <botlish_fn_13+0x3376>
			3baa: R_X86_64_PLT32	rt_int_cmp-0x4
    3bae:	mov    $0x2,%ecx
    3bb3:	test   %rax,%rax
    3bb6:	cmovl  0x2fda(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3bbe:	jmp    3bd7 <botlish_fn_13+0x339f>
    3bc3:	mov    $0x2,%ecx
    3bc8:	mov    %r14,%rsi
    3bcb:	cmp    $0x5b,%rsi
    3bcf:	cmovl  0x2fc1(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3bd7:	cmp    $0x6,%rcx
    3bdb:	je     3e11 <botlish_fn_13+0x35d9>
    3be1:	mov    %r14,%rsi
    3be4:	test   $0x1,%rsi
    3beb:	jne    3c1b <botlish_fn_13+0x33e3>
    3bf1:	mov    $0xbb,%edx
    3bf6:	mov    %r14,%rsi
    3bf9:	mov    0x1e8(%rsp),%rdi
    3c01:	call   3c06 <botlish_fn_13+0x33ce>
			3c02: R_X86_64_PLT32	rt_int_cmp-0x4
    3c06:	mov    $0x2,%ecx
    3c0b:	test   %rax,%rax
    3c0e:	cmovl  0x2f82(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3c16:	jmp    3c32 <botlish_fn_13+0x33fa>
    3c1b:	mov    $0x2,%ecx
    3c20:	mov    %r14,%rsi
    3c23:	cmp    $0xbb,%rsi
    3c2a:	cmovl  0x2f66(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3c32:	cmp    $0x6,%rcx
    3c36:	je     3dac <botlish_fn_13+0x3574>
    3c3c:	mov    %r14,%rsi
    3c3f:	test   $0x1,%rsi
    3c46:	jne    3c76 <botlish_fn_13+0x343e>
    3c4c:	mov    $0xcd,%edx
    3c51:	mov    %r14,%rsi
    3c54:	mov    0x1e8(%rsp),%rdi
    3c5c:	call   3c61 <botlish_fn_13+0x3429>
			3c5d: R_X86_64_PLT32	rt_int_cmp-0x4
    3c61:	mov    $0x2,%ecx
    3c66:	test   %rax,%rax
    3c69:	cmovl  0x2f27(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3c71:	jmp    3c8d <botlish_fn_13+0x3455>
    3c76:	mov    $0x2,%ecx
    3c7b:	mov    %r14,%rsi
    3c7e:	cmp    $0xcd,%rsi
    3c85:	cmovl  0x2f0b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3c8d:	cmp    $0x6,%rcx
    3c91:	je     3d6e <botlish_fn_13+0x3536>
    3c97:	mov    %r14,%rsi
    3c9a:	test   $0x1,%rsi
    3ca1:	jne    3cd1 <botlish_fn_13+0x3499>
    3ca7:	mov    $0xfb,%edx
    3cac:	mov    %r14,%rsi
    3caf:	mov    0x1e8(%rsp),%rdi
    3cb7:	call   3cbc <botlish_fn_13+0x3484>
			3cb8: R_X86_64_PLT32	rt_int_cmp-0x4
    3cbc:	mov    $0x2,%ecx
    3cc1:	test   %rax,%rax
    3cc4:	cmovl  0x2ecc(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3ccc:	jmp    3ce8 <botlish_fn_13+0x34b0>
    3cd1:	mov    $0x2,%ecx
    3cd6:	mov    %r14,%rsi
    3cd9:	cmp    $0xfb,%rsi
    3ce0:	cmovl  0x2eb0(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3ce8:	cmp    $0x6,%rcx
    3cec:	je     3d63 <botlish_fn_13+0x352b>
    3cf2:	mov    %r14,%rsi
    3cf5:	test   $0x1,%rsi
    3cfc:	jne    3d2c <botlish_fn_13+0x34f4>
    3d02:	mov    $0xfd,%edx
    3d07:	mov    %r14,%rsi
    3d0a:	mov    0x1e8(%rsp),%rdi
    3d12:	call   3d17 <botlish_fn_13+0x34df>
			3d13: R_X86_64_PLT32	rt_int_cmp-0x4
    3d17:	mov    $0x2,%edx
    3d1c:	test   %rax,%rax
    3d1f:	cmovl  0x2e71(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    3d27:	jmp    3d43 <botlish_fn_13+0x350b>
    3d2c:	mov    $0x2,%edx
    3d31:	mov    %r14,%rsi
    3d34:	cmp    $0xfd,%rsi
    3d3b:	cmovl  0x2e55(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    3d43:	cmp    $0x6,%rdx
    3d47:	je     3d58 <botlish_fn_13+0x3520>
    3d4d:	mov    $0x23,%r12d
    3d53:	jmp    4e63 <botlish_fn_13+0x462b>
    3d58:	mov    $0x15,%r12d
    3d5e:	jmp    4e63 <botlish_fn_13+0x462b>
    3d63:	mov    $0x23,%r12d
    3d69:	jmp    4e63 <botlish_fn_13+0x462b>
    3d6e:	mov    %r14,%rsi
    3d71:	mov    %rsi,%rcx
    3d74:	sar    $1,%rcx
    3d77:	cmp    $0x5e,%rcx
    3d7b:	jl     3da1 <botlish_fn_13+0x3569>
    3d81:	cmp    $0x65,%rcx
    3d85:	jl     3d96 <botlish_fn_13+0x355e>
    3d8b:	mov    $0xb,%r12d
    3d91:	jmp    4e63 <botlish_fn_13+0x462b>
    3d96:	mov    $0x23,%r12d
    3d9c:	jmp    4e63 <botlish_fn_13+0x462b>
    3da1:	mov    $0x15,%r12d
    3da7:	jmp    4e63 <botlish_fn_13+0x462b>
    3dac:	mov    %r14,%rsi
    3daf:	sar    $1,%rsi
    3db2:	cmp    $0x3a,%rsi
    3db6:	jl     3df1 <botlish_fn_13+0x35b9>
    3dbc:	cmp    $0x45,%rsi
    3dc0:	jl     3de6 <botlish_fn_13+0x35ae>
    3dc6:	cmp    $0x46,%rsi
    3dca:	jl     3ddb <botlish_fn_13+0x35a3>
    3dd0:	mov    $0x23,%r12d
    3dd6:	jmp    4e63 <botlish_fn_13+0x462b>
    3ddb:	mov    $0xb,%r12d
    3de1:	jmp    4e63 <botlish_fn_13+0x462b>
    3de6:	mov    $0x23,%r12d
    3dec:	jmp    4e63 <botlish_fn_13+0x462b>
    3df1:	cmp    $0x30,%rsi
    3df5:	jl     3e06 <botlish_fn_13+0x35ce>
    3dfb:	mov    $0xd,%r12d
    3e01:	jmp    4e63 <botlish_fn_13+0x462b>
    3e06:	mov    $0x23,%r12d
    3e0c:	jmp    4e63 <botlish_fn_13+0x462b>
    3e11:	mov    %r14,%rsi
    3e14:	test   $0x1,%rsi
    3e1b:	jne    3e4b <botlish_fn_13+0x3613>
    3e21:	mov    $0x1b,%edx
    3e26:	mov    %r14,%rsi
    3e29:	mov    0x1e8(%rsp),%rdi
    3e31:	call   3e36 <botlish_fn_13+0x35fe>
			3e32: R_X86_64_PLT32	rt_int_cmp-0x4
    3e36:	mov    $0x2,%ecx
    3e3b:	test   %rax,%rax
    3e3e:	cmovl  0x2d52(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3e46:	jmp    3e5f <botlish_fn_13+0x3627>
    3e4b:	mov    $0x2,%ecx
    3e50:	mov    %r14,%rsi
    3e53:	cmp    $0x1b,%rsi
    3e57:	cmovl  0x2d39(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3e5f:	cmp    $0x6,%rcx
    3e63:	je     3ed1 <botlish_fn_13+0x3699>
    3e69:	mov    %r14,%rsi
    3e6c:	mov    %rsi,%rcx
    3e6f:	sar    $1,%rcx
    3e72:	cmp    $0x20,%rcx
    3e76:	jl     3eb1 <botlish_fn_13+0x3679>
    3e7c:	cmp    $0x21,%rcx
    3e80:	jl     3ea6 <botlish_fn_13+0x366e>
    3e86:	cmp    $0x2c,%rcx
    3e8a:	jl     3e9b <botlish_fn_13+0x3663>
    3e90:	mov    $0x15,%r12d
    3e96:	jmp    4e63 <botlish_fn_13+0x462b>
    3e9b:	mov    $0x23,%r12d
    3ea1:	jmp    4e63 <botlish_fn_13+0x462b>
    3ea6:	mov    $0x15,%r12d
    3eac:	jmp    4e63 <botlish_fn_13+0x462b>
    3eb1:	cmp    $0xe,%rcx
    3eb5:	jl     3ec6 <botlish_fn_13+0x368e>
    3ebb:	mov    $0x23,%r12d
    3ec1:	jmp    4e63 <botlish_fn_13+0x462b>
    3ec6:	mov    $0x15,%r12d
    3ecc:	jmp    4e63 <botlish_fn_13+0x462b>
    3ed1:	mov    %r14,%rsi
    3ed4:	test   $0x1,%rsi
    3edb:	jne    3f0b <botlish_fn_13+0x36d3>
    3ee1:	mov    $0x1,%edx
    3ee6:	mov    %r14,%rsi
    3ee9:	mov    0x1e8(%rsp),%rdi
    3ef1:	call   3ef6 <botlish_fn_13+0x36be>
			3ef2: R_X86_64_PLT32	rt_int_cmp-0x4
    3ef6:	mov    $0x2,%ecx
    3efb:	test   %rax,%rax
    3efe:	cmovl  0x2c92(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3f06:	jmp    3f21 <botlish_fn_13+0x36e9>
    3f0b:	mov    $0x2,%ecx
    3f10:	mov    %r14,%rsi
    3f13:	mov    %r14,%r9
    3f16:	test   %r9,%rsi
    3f19:	cmovle 0x2c77(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3f21:	cmp    $0x6,%rcx
    3f25:	je     3f69 <botlish_fn_13+0x3731>
    3f2b:	mov    %r14,%rsi
    3f2e:	mov    %rsi,%rcx
    3f31:	sar    $1,%rcx
    3f34:	cmp    $0x9,%rcx
    3f38:	jl     3f5e <botlish_fn_13+0x3726>
    3f3e:	cmp    $0xb,%rcx
    3f42:	jl     3f53 <botlish_fn_13+0x371b>
    3f48:	mov    $0x23,%r12d
    3f4e:	jmp    4e63 <botlish_fn_13+0x462b>
    3f53:	mov    $0x15,%r12d
    3f59:	jmp    4e63 <botlish_fn_13+0x462b>
    3f5e:	mov    $0x23,%r12d
    3f64:	jmp    4e63 <botlish_fn_13+0x462b>
    3f69:	mov    %r14,%rsi
    3f6c:	test   $0x1,%rsi
    3f73:	jne    3fa6 <botlish_fn_13+0x376e>
    3f79:	mov    0x258(%rsp),%rdx
    3f81:	mov    %r14,%rsi
    3f84:	mov    0x1e8(%rsp),%rdi
    3f8c:	call   3f91 <botlish_fn_13+0x3759>
			3f8d: R_X86_64_PLT32	rt_int_cmp-0x4
    3f91:	mov    $0x2,%ecx
    3f96:	test   %rax,%rax
    3f99:	cmovl  0x2bf7(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3fa1:	jmp    3fba <botlish_fn_13+0x3782>
    3fa6:	mov    $0x2,%ecx
    3fab:	mov    %r14,%rsi
    3fae:	cmp    $0xffffffffffffffff,%rsi
    3fb2:	cmovl  0x2bde(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    3fba:	cmp    $0x6,%rcx
    3fbe:	je     3fcf <botlish_fn_13+0x3797>
    3fc4:	mov    $0x15,%r12d
    3fca:	jmp    4e63 <botlish_fn_13+0x462b>
    3fcf:	mov    $0x23,%r12d
    3fd5:	jmp    4e63 <botlish_fn_13+0x462b>
    3fda:	cmp    $0x5,%r12
    3fde:	jl     41b9 <botlish_fn_13+0x3981>
    3fe4:	mov    %r14,%rsi
    3fe7:	test   $0x1,%rsi
    3fee:	jne    401e <botlish_fn_13+0x37e6>
    3ff4:	mov    $0x5b,%edx
    3ff9:	mov    %r14,%rsi
    3ffc:	mov    0x1e8(%rsp),%rdi
    4004:	call   4009 <botlish_fn_13+0x37d1>
			4005: R_X86_64_PLT32	rt_int_cmp-0x4
    4009:	mov    $0x2,%ecx
    400e:	test   %rax,%rax
    4011:	cmovl  0x2b7f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4019:	jmp    4032 <botlish_fn_13+0x37fa>
    401e:	mov    $0x2,%ecx
    4023:	mov    %r14,%rsi
    4026:	cmp    $0x5b,%rsi
    402a:	cmovl  0x2b66(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4032:	cmp    $0x6,%rcx
    4036:	je     412d <botlish_fn_13+0x38f5>
    403c:	mov    %r14,%rsi
    403f:	test   $0x1,%rsi
    4046:	jne    4077 <botlish_fn_13+0x383f>
    404c:	mov    $0x61,%edx
    4051:	mov    %r14,%rsi
    4054:	mov    0x1e8(%rsp),%rdi
    405c:	call   4061 <botlish_fn_13+0x3829>
			405d: R_X86_64_PLT32	rt_int_cmp-0x4
    4061:	mov    $0x2,%r9d
    4067:	test   %rax,%rax
    406a:	cmovl  0x2b26(%rip),%r9        # 6b98 <botlish_fn_13+0x6360>
    4072:	jmp    408c <botlish_fn_13+0x3854>
    4077:	mov    $0x2,%r9d
    407d:	mov    %r14,%rsi
    4080:	cmp    $0x61,%rsi
    4084:	cmovl  0x2b0c(%rip),%r9        # 6b98 <botlish_fn_13+0x6360>
    408c:	cmp    $0x6,%r9
    4090:	je     4104 <botlish_fn_13+0x38cc>
    4096:	mov    %r14,%rsi
    4099:	test   $0x1,%rsi
    40a0:	jne    40d0 <botlish_fn_13+0x3898>
    40a6:	mov    $0x75,%edx
    40ab:	mov    %r14,%rsi
    40ae:	mov    0x1e8(%rsp),%rdi
    40b6:	call   40bb <botlish_fn_13+0x3883>
			40b7: R_X86_64_PLT32	rt_int_cmp-0x4
    40bb:	mov    $0x2,%ecx
    40c0:	test   %rax,%rax
    40c3:	cmovl  0x2acd(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    40cb:	jmp    40e4 <botlish_fn_13+0x38ac>
    40d0:	mov    $0x2,%ecx
    40d5:	mov    %r14,%rsi
    40d8:	cmp    $0x75,%rsi
    40dc:	cmovl  0x2ab4(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    40e4:	cmp    $0x6,%rcx
    40e8:	je     40f9 <botlish_fn_13+0x38c1>
    40ee:	mov    $0x21,%r12d
    40f4:	jmp    4e63 <botlish_fn_13+0x462b>
    40f9:	mov    $0x11,%r12d
    40ff:	jmp    4e63 <botlish_fn_13+0x462b>
    4104:	mov    %r14,%rsi
    4107:	mov    %rsi,%rax
    410a:	sar    $1,%rax
    410d:	cmp    $0x2e,%rax
    4111:	jl     4122 <botlish_fn_13+0x38ea>
    4117:	mov    $0x21,%r12d
    411d:	jmp    4e63 <botlish_fn_13+0x462b>
    4122:	mov    $0xf,%r12d
    4128:	jmp    4e63 <botlish_fn_13+0x462b>
    412d:	mov    %r14,%rsi
    4130:	test   $0x1,%rsi
    4137:	jne    4167 <botlish_fn_13+0x392f>
    413d:	mov    $0x57,%edx
    4142:	mov    %r14,%rsi
    4145:	mov    0x1e8(%rsp),%rdi
    414d:	call   4152 <botlish_fn_13+0x391a>
			414e: R_X86_64_PLT32	rt_int_cmp-0x4
    4152:	mov    $0x2,%ecx
    4157:	test   %rax,%rax
    415a:	cmovl  0x2a36(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4162:	jmp    417b <botlish_fn_13+0x3943>
    4167:	mov    $0x2,%ecx
    416c:	mov    %r14,%rsi
    416f:	cmp    $0x57,%rsi
    4173:	cmovl  0x2a1d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    417b:	cmp    $0x6,%rcx
    417f:	je     41ae <botlish_fn_13+0x3976>
    4185:	mov    %r14,%rsi
    4188:	mov    %rsi,%rax
    418b:	sar    $1,%rax
    418e:	cmp    $0x2c,%rax
    4192:	jl     41a3 <botlish_fn_13+0x396b>
    4198:	mov    $0x21,%r12d
    419e:	jmp    4e63 <botlish_fn_13+0x462b>
    41a3:	mov    $0xf,%r12d
    41a9:	jmp    4e63 <botlish_fn_13+0x462b>
    41ae:	mov    $0x21,%r12d
    41b4:	jmp    4e63 <botlish_fn_13+0x462b>
    41b9:	mov    %r14,%rsi
    41bc:	test   $0x1,%rsi
    41c3:	jne    41f3 <botlish_fn_13+0x39bb>
    41c9:	mov    $0x61,%edx
    41ce:	mov    %r14,%rsi
    41d1:	mov    0x1e8(%rsp),%rdi
    41d9:	call   41de <botlish_fn_13+0x39a6>
			41da: R_X86_64_PLT32	rt_int_cmp-0x4
    41de:	mov    $0x2,%esi
    41e3:	test   %rax,%rax
    41e6:	cmovl  0x29aa(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    41ee:	jmp    4207 <botlish_fn_13+0x39cf>
    41f3:	mov    $0x2,%esi
    41f8:	mov    %r14,%rax
    41fb:	cmp    $0x61,%rax
    41ff:	cmovl  0x2991(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    4207:	cmp    $0x6,%rsi
    420b:	je     427f <botlish_fn_13+0x3a47>
    4211:	mov    %r14,%rsi
    4214:	test   $0x1,%rsi
    421b:	jne    424b <botlish_fn_13+0x3a13>
    4221:	mov    $0x75,%edx
    4226:	mov    %r14,%rsi
    4229:	mov    0x1e8(%rsp),%rdi
    4231:	call   4236 <botlish_fn_13+0x39fe>
			4232: R_X86_64_PLT32	rt_int_cmp-0x4
    4236:	mov    $0x2,%ecx
    423b:	test   %rax,%rax
    423e:	cmovl  0x2952(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4246:	jmp    425f <botlish_fn_13+0x3a27>
    424b:	mov    $0x2,%ecx
    4250:	mov    %r14,%rsi
    4253:	cmp    $0x75,%rsi
    4257:	cmovl  0x2939(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    425f:	cmp    $0x6,%rcx
    4263:	je     4274 <botlish_fn_13+0x3a3c>
    4269:	mov    $0x1f,%r12d
    426f:	jmp    4e63 <botlish_fn_13+0x462b>
    4274:	mov    $0xd,%r12d
    427a:	jmp    4e63 <botlish_fn_13+0x462b>
    427f:	mov    $0x1f,%r12d
    4285:	jmp    4e63 <botlish_fn_13+0x462b>
    428a:	cmp    $0x2,%r12
    428e:	jl     4b74 <botlish_fn_13+0x433c>
    4294:	cmp    $0x3,%r12
    4298:	jl     471c <botlish_fn_13+0x3ee4>
    429e:	mov    %r14,%rsi
    42a1:	test   $0x1,%rsi
    42a8:	jne    42d8 <botlish_fn_13+0x3aa0>
    42ae:	mov    $0x5d,%edx
    42b3:	mov    %r14,%rsi
    42b6:	mov    0x1e8(%rsp),%rdi
    42be:	call   42c3 <botlish_fn_13+0x3a8b>
			42bf: R_X86_64_PLT32	rt_int_cmp-0x4
    42c3:	mov    $0x2,%ecx
    42c8:	test   %rax,%rax
    42cb:	cmovl  0x28c5(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    42d3:	jmp    42ec <botlish_fn_13+0x3ab4>
    42d8:	mov    $0x2,%ecx
    42dd:	mov    %r14,%rsi
    42e0:	cmp    $0x5d,%rsi
    42e4:	cmovl  0x28ac(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    42ec:	cmp    $0x6,%rcx
    42f0:	je     453e <botlish_fn_13+0x3d06>
    42f6:	mov    %r14,%rsi
    42f9:	test   $0x1,%rsi
    4300:	jne    4330 <botlish_fn_13+0x3af8>
    4306:	mov    $0xbb,%edx
    430b:	mov    %r14,%rsi
    430e:	mov    0x1e8(%rsp),%rdi
    4316:	call   431b <botlish_fn_13+0x3ae3>
			4317: R_X86_64_PLT32	rt_int_cmp-0x4
    431b:	mov    $0x2,%ecx
    4320:	test   %rax,%rax
    4323:	cmovl  0x286d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    432b:	jmp    4347 <botlish_fn_13+0x3b0f>
    4330:	mov    $0x2,%ecx
    4335:	mov    %r14,%rsi
    4338:	cmp    $0xbb,%rsi
    433f:	cmovl  0x2851(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4347:	cmp    $0x6,%rcx
    434b:	je     44c1 <botlish_fn_13+0x3c89>
    4351:	mov    %r14,%rsi
    4354:	test   $0x1,%rsi
    435b:	jne    438b <botlish_fn_13+0x3b53>
    4361:	mov    $0xcd,%edx
    4366:	mov    %r14,%rsi
    4369:	mov    0x1e8(%rsp),%rdi
    4371:	call   4376 <botlish_fn_13+0x3b3e>
			4372: R_X86_64_PLT32	rt_int_cmp-0x4
    4376:	mov    $0x2,%ecx
    437b:	test   %rax,%rax
    437e:	cmovl  0x2812(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4386:	jmp    43a2 <botlish_fn_13+0x3b6a>
    438b:	mov    $0x2,%ecx
    4390:	mov    %r14,%rsi
    4393:	cmp    $0xcd,%rsi
    439a:	cmovl  0x27f6(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    43a2:	cmp    $0x6,%rcx
    43a6:	je     4483 <botlish_fn_13+0x3c4b>
    43ac:	mov    %r14,%rsi
    43af:	test   $0x1,%rsi
    43b6:	jne    43e6 <botlish_fn_13+0x3bae>
    43bc:	mov    $0xfb,%edx
    43c1:	mov    %r14,%rsi
    43c4:	mov    0x1e8(%rsp),%rdi
    43cc:	call   43d1 <botlish_fn_13+0x3b99>
			43cd: R_X86_64_PLT32	rt_int_cmp-0x4
    43d1:	mov    $0x2,%ecx
    43d6:	test   %rax,%rax
    43d9:	cmovl  0x27b7(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    43e1:	jmp    43fd <botlish_fn_13+0x3bc5>
    43e6:	mov    $0x2,%ecx
    43eb:	mov    %r14,%rsi
    43ee:	cmp    $0xfb,%rsi
    43f5:	cmovl  0x279b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    43fd:	cmp    $0x6,%rcx
    4401:	je     4478 <botlish_fn_13+0x3c40>
    4407:	mov    %r14,%rsi
    440a:	test   $0x1,%rsi
    4411:	jne    4441 <botlish_fn_13+0x3c09>
    4417:	mov    $0xfd,%edx
    441c:	mov    %r14,%rsi
    441f:	mov    0x1e8(%rsp),%rdi
    4427:	call   442c <botlish_fn_13+0x3bf4>
			4428: R_X86_64_PLT32	rt_int_cmp-0x4
    442c:	mov    $0x2,%ecx
    4431:	test   %rax,%rax
    4434:	cmovl  0x275c(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    443c:	jmp    4458 <botlish_fn_13+0x3c20>
    4441:	mov    $0x2,%ecx
    4446:	mov    %r14,%rsi
    4449:	cmp    $0xfd,%rsi
    4450:	cmovl  0x2740(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4458:	cmp    $0x6,%rcx
    445c:	je     446d <botlish_fn_13+0x3c35>
    4462:	mov    $0x1d,%r12d
    4468:	jmp    4e63 <botlish_fn_13+0x462b>
    446d:	mov    $0x15,%r12d
    4473:	jmp    4e63 <botlish_fn_13+0x462b>
    4478:	mov    $0x1d,%r12d
    447e:	jmp    4e63 <botlish_fn_13+0x462b>
    4483:	mov    %r14,%rsi
    4486:	mov    %rsi,%rcx
    4489:	sar    $1,%rcx
    448c:	cmp    $0x5e,%rcx
    4490:	jl     44b6 <botlish_fn_13+0x3c7e>
    4496:	cmp    $0x65,%rcx
    449a:	jl     44ab <botlish_fn_13+0x3c73>
    44a0:	mov    $0xb,%r12d
    44a6:	jmp    4e63 <botlish_fn_13+0x462b>
    44ab:	mov    $0x1d,%r12d
    44b1:	jmp    4e63 <botlish_fn_13+0x462b>
    44b6:	mov    $0x15,%r12d
    44bc:	jmp    4e63 <botlish_fn_13+0x462b>
    44c1:	mov    %r14,%rsi
    44c4:	mov    %rsi,%rcx
    44c7:	sar    $1,%rcx
    44ca:	cmp    $0x3a,%rcx
    44ce:	jl     4509 <botlish_fn_13+0x3cd1>
    44d4:	cmp    $0x45,%rcx
    44d8:	jl     44fe <botlish_fn_13+0x3cc6>
    44de:	cmp    $0x46,%rcx
    44e2:	jl     44f3 <botlish_fn_13+0x3cbb>
    44e8:	mov    $0x1d,%r12d
    44ee:	jmp    4e63 <botlish_fn_13+0x462b>
    44f3:	mov    $0xb,%r12d
    44f9:	jmp    4e63 <botlish_fn_13+0x462b>
    44fe:	mov    $0x1d,%r12d
    4504:	jmp    4e63 <botlish_fn_13+0x462b>
    4509:	cmp    $0x2f,%rcx
    450d:	jl     4533 <botlish_fn_13+0x3cfb>
    4513:	cmp    $0x30,%rcx
    4517:	jl     4528 <botlish_fn_13+0x3cf0>
    451d:	mov    $0x7,%r12d
    4523:	jmp    4e63 <botlish_fn_13+0x462b>
    4528:	mov    $0x1d,%r12d
    452e:	jmp    4e63 <botlish_fn_13+0x462b>
    4533:	mov    $0x9,%r12d
    4539:	jmp    4e63 <botlish_fn_13+0x462b>
    453e:	mov    %r14,%rsi
    4541:	test   $0x1,%rsi
    4548:	jne    4578 <botlish_fn_13+0x3d40>
    454e:	mov    $0x1b,%edx
    4553:	mov    %r14,%rsi
    4556:	mov    0x1e8(%rsp),%rdi
    455e:	call   4563 <botlish_fn_13+0x3d2b>
			455f: R_X86_64_PLT32	rt_int_cmp-0x4
    4563:	mov    $0x2,%ecx
    4568:	test   %rax,%rax
    456b:	cmovl  0x2625(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4573:	jmp    458c <botlish_fn_13+0x3d54>
    4578:	mov    $0x2,%ecx
    457d:	mov    %r14,%rsi
    4580:	cmp    $0x1b,%rsi
    4584:	cmovl  0x260c(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    458c:	cmp    $0x6,%rcx
    4590:	je     4613 <botlish_fn_13+0x3ddb>
    4596:	mov    %r14,%rsi
    4599:	mov    %rsi,%rcx
    459c:	sar    $1,%rcx
    459f:	cmp    $0x21,%rcx
    45a3:	jl     45de <botlish_fn_13+0x3da6>
    45a9:	cmp    $0x2c,%rcx
    45ad:	jl     45d3 <botlish_fn_13+0x3d9b>
    45b3:	cmp    $0x2d,%rcx
    45b7:	jl     45c8 <botlish_fn_13+0x3d90>
    45bd:	mov    $0x1d,%r12d
    45c3:	jmp    4e63 <botlish_fn_13+0x462b>
    45c8:	mov    $0x15,%r12d
    45ce:	jmp    4e63 <botlish_fn_13+0x462b>
    45d3:	mov    $0x1d,%r12d
    45d9:	jmp    4e63 <botlish_fn_13+0x462b>
    45de:	cmp    $0xe,%rcx
    45e2:	jl     4608 <botlish_fn_13+0x3dd0>
    45e8:	cmp    $0x20,%rcx
    45ec:	jl     45fd <botlish_fn_13+0x3dc5>
    45f2:	mov    $0x15,%r12d
    45f8:	jmp    4e63 <botlish_fn_13+0x462b>
    45fd:	mov    $0x1d,%r12d
    4603:	jmp    4e63 <botlish_fn_13+0x462b>
    4608:	mov    $0x15,%r12d
    460e:	jmp    4e63 <botlish_fn_13+0x462b>
    4613:	mov    %r14,%rsi
    4616:	test   $0x1,%rsi
    461d:	jne    464d <botlish_fn_13+0x3e15>
    4623:	mov    $0x1,%edx
    4628:	mov    %r14,%rsi
    462b:	mov    0x1e8(%rsp),%rdi
    4633:	call   4638 <botlish_fn_13+0x3e00>
			4634: R_X86_64_PLT32	rt_int_cmp-0x4
    4638:	mov    $0x2,%ecx
    463d:	test   %rax,%rax
    4640:	cmovl  0x2550(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4648:	jmp    4663 <botlish_fn_13+0x3e2b>
    464d:	mov    $0x2,%ecx
    4652:	mov    %r14,%rsi
    4655:	mov    %r14,%rdi
    4658:	test   %rdi,%rsi
    465b:	cmovle 0x2535(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4663:	cmp    $0x6,%rcx
    4667:	je     46ab <botlish_fn_13+0x3e73>
    466d:	mov    %r14,%rsi
    4670:	mov    %rsi,%rcx
    4673:	sar    $1,%rcx
    4676:	cmp    $0x9,%rcx
    467a:	jl     46a0 <botlish_fn_13+0x3e68>
    4680:	cmp    $0xb,%rcx
    4684:	jl     4695 <botlish_fn_13+0x3e5d>
    468a:	mov    $0x1d,%r12d
    4690:	jmp    4e63 <botlish_fn_13+0x462b>
    4695:	mov    $0x15,%r12d
    469b:	jmp    4e63 <botlish_fn_13+0x462b>
    46a0:	mov    $0x1d,%r12d
    46a6:	jmp    4e63 <botlish_fn_13+0x462b>
    46ab:	mov    %r14,%rsi
    46ae:	test   $0x1,%rsi
    46b5:	jne    46e8 <botlish_fn_13+0x3eb0>
    46bb:	mov    0x258(%rsp),%rdx
    46c3:	mov    %r14,%rsi
    46c6:	mov    0x1e8(%rsp),%rdi
    46ce:	call   46d3 <botlish_fn_13+0x3e9b>
			46cf: R_X86_64_PLT32	rt_int_cmp-0x4
    46d3:	mov    $0x2,%ecx
    46d8:	test   %rax,%rax
    46db:	cmovl  0x24b5(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    46e3:	jmp    46fc <botlish_fn_13+0x3ec4>
    46e8:	mov    $0x2,%ecx
    46ed:	mov    %r14,%rsi
    46f0:	cmp    $0xffffffffffffffff,%rsi
    46f4:	cmovl  0x249c(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    46fc:	cmp    $0x6,%rcx
    4700:	je     4711 <botlish_fn_13+0x3ed9>
    4706:	mov    $0x15,%r12d
    470c:	jmp    4e63 <botlish_fn_13+0x462b>
    4711:	mov    $0x1d,%r12d
    4717:	jmp    4e63 <botlish_fn_13+0x462b>
    471c:	mov    %r14,%rsi
    471f:	test   $0x1,%rsi
    4726:	jne    4757 <botlish_fn_13+0x3f1f>
    472c:	mov    $0x5b,%edx
    4731:	mov    %r14,%rsi
    4734:	mov    0x1e8(%rsp),%rdi
    473c:	call   4741 <botlish_fn_13+0x3f09>
			473d: R_X86_64_PLT32	rt_int_cmp-0x4
    4741:	mov    $0x2,%r10d
    4747:	test   %rax,%rax
    474a:	cmovl  0x2446(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    4752:	jmp    476c <botlish_fn_13+0x3f34>
    4757:	mov    $0x2,%r10d
    475d:	mov    %r14,%rsi
    4760:	cmp    $0x5b,%rsi
    4764:	cmovl  0x242c(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    476c:	cmp    $0x6,%r10
    4770:	je     49ab <botlish_fn_13+0x4173>
    4776:	mov    %r14,%rsi
    4779:	test   $0x1,%rsi
    4780:	jne    47b0 <botlish_fn_13+0x3f78>
    4786:	mov    $0xbb,%edx
    478b:	mov    %r14,%rsi
    478e:	mov    0x1e8(%rsp),%rdi
    4796:	call   479b <botlish_fn_13+0x3f63>
			4797: R_X86_64_PLT32	rt_int_cmp-0x4
    479b:	mov    $0x2,%ecx
    47a0:	test   %rax,%rax
    47a3:	cmovl  0x23ed(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    47ab:	jmp    47c7 <botlish_fn_13+0x3f8f>
    47b0:	mov    $0x2,%ecx
    47b5:	mov    %r14,%rsi
    47b8:	cmp    $0xbb,%rsi
    47bf:	cmovl  0x23d1(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    47c7:	cmp    $0x6,%rcx
    47cb:	je     4943 <botlish_fn_13+0x410b>
    47d1:	mov    %r14,%rsi
    47d4:	test   $0x1,%rsi
    47db:	jne    480b <botlish_fn_13+0x3fd3>
    47e1:	mov    $0xcd,%edx
    47e6:	mov    %r14,%rsi
    47e9:	mov    0x1e8(%rsp),%rdi
    47f1:	call   47f6 <botlish_fn_13+0x3fbe>
			47f2: R_X86_64_PLT32	rt_int_cmp-0x4
    47f6:	mov    $0x2,%ecx
    47fb:	test   %rax,%rax
    47fe:	cmovl  0x2392(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4806:	jmp    4822 <botlish_fn_13+0x3fea>
    480b:	mov    $0x2,%ecx
    4810:	mov    %r14,%rsi
    4813:	cmp    $0xcd,%rsi
    481a:	cmovl  0x2376(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4822:	cmp    $0x6,%rcx
    4826:	je     4905 <botlish_fn_13+0x40cd>
    482c:	mov    %r14,%rsi
    482f:	test   $0x1,%rsi
    4836:	jne    4867 <botlish_fn_13+0x402f>
    483c:	mov    $0xfb,%edx
    4841:	mov    %r14,%rsi
    4844:	mov    0x1e8(%rsp),%rdi
    484c:	call   4851 <botlish_fn_13+0x4019>
			484d: R_X86_64_PLT32	rt_int_cmp-0x4
    4851:	mov    $0x2,%r10d
    4857:	test   %rax,%rax
    485a:	cmovl  0x2336(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    4862:	jmp    487f <botlish_fn_13+0x4047>
    4867:	mov    $0x2,%r10d
    486d:	mov    %r14,%rsi
    4870:	cmp    $0xfb,%rsi
    4877:	cmovl  0x2319(%rip),%r10        # 6b98 <botlish_fn_13+0x6360>
    487f:	cmp    $0x6,%r10
    4883:	je     48fa <botlish_fn_13+0x40c2>
    4889:	mov    %r14,%rsi
    488c:	test   $0x1,%rsi
    4893:	jne    48c3 <botlish_fn_13+0x408b>
    4899:	mov    $0xfd,%edx
    489e:	mov    %r14,%rsi
    48a1:	mov    0x1e8(%rsp),%rdi
    48a9:	call   48ae <botlish_fn_13+0x4076>
			48aa: R_X86_64_PLT32	rt_int_cmp-0x4
    48ae:	mov    $0x2,%ecx
    48b3:	test   %rax,%rax
    48b6:	cmovl  0x22da(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    48be:	jmp    48da <botlish_fn_13+0x40a2>
    48c3:	mov    $0x2,%ecx
    48c8:	mov    %r14,%rsi
    48cb:	cmp    $0xfd,%rsi
    48d2:	cmovl  0x22be(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    48da:	cmp    $0x6,%rcx
    48de:	je     48ef <botlish_fn_13+0x40b7>
    48e4:	mov    $0x1b,%r12d
    48ea:	jmp    4e63 <botlish_fn_13+0x462b>
    48ef:	mov    $0x15,%r12d
    48f5:	jmp    4e63 <botlish_fn_13+0x462b>
    48fa:	mov    $0x1b,%r12d
    4900:	jmp    4e63 <botlish_fn_13+0x462b>
    4905:	mov    %r14,%rsi
    4908:	mov    %rsi,%rcx
    490b:	sar    $1,%rcx
    490e:	cmp    $0x5e,%rcx
    4912:	jl     4938 <botlish_fn_13+0x4100>
    4918:	cmp    $0x65,%rcx
    491c:	jl     492d <botlish_fn_13+0x40f5>
    4922:	mov    $0xb,%r12d
    4928:	jmp    4e63 <botlish_fn_13+0x462b>
    492d:	mov    $0x1b,%r12d
    4933:	jmp    4e63 <botlish_fn_13+0x462b>
    4938:	mov    $0x15,%r12d
    493e:	jmp    4e63 <botlish_fn_13+0x462b>
    4943:	mov    %r14,%rsi
    4946:	mov    %rsi,%rcx
    4949:	sar    $1,%rcx
    494c:	cmp    $0x2f,%rcx
    4950:	jl     498b <botlish_fn_13+0x4153>
    4956:	cmp    $0x45,%rcx
    495a:	jl     4980 <botlish_fn_13+0x4148>
    4960:	cmp    $0x46,%rcx
    4964:	jl     4975 <botlish_fn_13+0x413d>
    496a:	mov    $0x1b,%r12d
    4970:	jmp    4e63 <botlish_fn_13+0x462b>
    4975:	mov    $0xb,%r12d
    497b:	jmp    4e63 <botlish_fn_13+0x462b>
    4980:	mov    $0x1b,%r12d
    4986:	jmp    4e63 <botlish_fn_13+0x462b>
    498b:	cmp    $0x2e,%rcx
    498f:	jl     49a0 <botlish_fn_13+0x4168>
    4995:	mov    $0x9,%r12d
    499b:	jmp    4e63 <botlish_fn_13+0x462b>
    49a0:	mov    $0x1b,%r12d
    49a6:	jmp    4e63 <botlish_fn_13+0x462b>
    49ab:	mov    %r14,%rsi
    49ae:	test   $0x1,%rsi
    49b5:	jne    49e5 <botlish_fn_13+0x41ad>
    49bb:	mov    $0x1b,%edx
    49c0:	mov    %r14,%rsi
    49c3:	mov    0x1e8(%rsp),%rdi
    49cb:	call   49d0 <botlish_fn_13+0x4198>
			49cc: R_X86_64_PLT32	rt_int_cmp-0x4
    49d0:	mov    $0x2,%ecx
    49d5:	test   %rax,%rax
    49d8:	cmovl  0x21b8(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    49e0:	jmp    49f9 <botlish_fn_13+0x41c1>
    49e5:	mov    $0x2,%ecx
    49ea:	mov    %r14,%rsi
    49ed:	cmp    $0x1b,%rsi
    49f1:	cmovl  0x219f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    49f9:	cmp    $0x6,%rcx
    49fd:	je     4a6b <botlish_fn_13+0x4233>
    4a03:	mov    %r14,%rsi
    4a06:	mov    %rsi,%rcx
    4a09:	sar    $1,%rcx
    4a0c:	cmp    $0x20,%rcx
    4a10:	jl     4a4b <botlish_fn_13+0x4213>
    4a16:	cmp    $0x21,%rcx
    4a1a:	jl     4a40 <botlish_fn_13+0x4208>
    4a20:	cmp    $0x2c,%rcx
    4a24:	jl     4a35 <botlish_fn_13+0x41fd>
    4a2a:	mov    $0x15,%r12d
    4a30:	jmp    4e63 <botlish_fn_13+0x462b>
    4a35:	mov    $0x1b,%r12d
    4a3b:	jmp    4e63 <botlish_fn_13+0x462b>
    4a40:	mov    $0x15,%r12d
    4a46:	jmp    4e63 <botlish_fn_13+0x462b>
    4a4b:	cmp    $0xe,%rcx
    4a4f:	jl     4a60 <botlish_fn_13+0x4228>
    4a55:	mov    $0x1b,%r12d
    4a5b:	jmp    4e63 <botlish_fn_13+0x462b>
    4a60:	mov    $0x15,%r12d
    4a66:	jmp    4e63 <botlish_fn_13+0x462b>
    4a6b:	mov    %r14,%rsi
    4a6e:	test   $0x1,%rsi
    4a75:	jne    4aa5 <botlish_fn_13+0x426d>
    4a7b:	mov    $0x1,%edx
    4a80:	mov    %r14,%rsi
    4a83:	mov    0x1e8(%rsp),%rdi
    4a8b:	call   4a90 <botlish_fn_13+0x4258>
			4a8c: R_X86_64_PLT32	rt_int_cmp-0x4
    4a90:	mov    $0x2,%ecx
    4a95:	test   %rax,%rax
    4a98:	cmovl  0x20f8(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4aa0:	jmp    4abb <botlish_fn_13+0x4283>
    4aa5:	mov    $0x2,%ecx
    4aaa:	mov    %r14,%rax
    4aad:	mov    %r14,%rsi
    4ab0:	test   %rax,%rsi
    4ab3:	cmovle 0x20dd(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4abb:	cmp    $0x6,%rcx
    4abf:	je     4b03 <botlish_fn_13+0x42cb>
    4ac5:	mov    %r14,%rsi
    4ac8:	mov    %rsi,%rcx
    4acb:	sar    $1,%rcx
    4ace:	cmp    $0x9,%rcx
    4ad2:	jl     4af8 <botlish_fn_13+0x42c0>
    4ad8:	cmp    $0xb,%rcx
    4adc:	jl     4aed <botlish_fn_13+0x42b5>
    4ae2:	mov    $0x1b,%r12d
    4ae8:	jmp    4e63 <botlish_fn_13+0x462b>
    4aed:	mov    $0x15,%r12d
    4af3:	jmp    4e63 <botlish_fn_13+0x462b>
    4af8:	mov    $0x1b,%r12d
    4afe:	jmp    4e63 <botlish_fn_13+0x462b>
    4b03:	mov    %r14,%rsi
    4b06:	test   $0x1,%rsi
    4b0d:	jne    4b40 <botlish_fn_13+0x4308>
    4b13:	mov    0x258(%rsp),%rdx
    4b1b:	mov    %r14,%rsi
    4b1e:	mov    0x1e8(%rsp),%rdi
    4b26:	call   4b2b <botlish_fn_13+0x42f3>
			4b27: R_X86_64_PLT32	rt_int_cmp-0x4
    4b2b:	mov    $0x2,%esi
    4b30:	test   %rax,%rax
    4b33:	cmovl  0x205d(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    4b3b:	jmp    4b54 <botlish_fn_13+0x431c>
    4b40:	mov    $0x2,%esi
    4b45:	mov    %r14,%rdi
    4b48:	cmp    $0xffffffffffffffff,%rdi
    4b4c:	cmovl  0x2044(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    4b54:	cmp    $0x6,%rsi
    4b58:	je     4b69 <botlish_fn_13+0x4331>
    4b5e:	mov    $0x15,%r12d
    4b64:	jmp    4e63 <botlish_fn_13+0x462b>
    4b69:	mov    $0x1b,%r12d
    4b6f:	jmp    4e63 <botlish_fn_13+0x462b>
    4b74:	test   %r12,%r12
    4b77:	jle    4cb1 <botlish_fn_13+0x4479>
    4b7d:	mov    %r14,%rsi
    4b80:	test   $0x1,%rsi
    4b87:	jne    4bb7 <botlish_fn_13+0x437f>
    4b8d:	mov    $0x63,%edx
    4b92:	mov    %r14,%rsi
    4b95:	mov    0x1e8(%rsp),%rdi
    4b9d:	call   4ba2 <botlish_fn_13+0x436a>
			4b9e: R_X86_64_PLT32	rt_int_cmp-0x4
    4ba2:	mov    $0x2,%ecx
    4ba7:	test   %rax,%rax
    4baa:	cmovl  0x1fe6(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4bb2:	jmp    4bcb <botlish_fn_13+0x4393>
    4bb7:	mov    $0x2,%ecx
    4bbc:	mov    %r14,%rsi
    4bbf:	cmp    $0x63,%rsi
    4bc3:	cmovl  0x1fcd(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4bcb:	cmp    $0x6,%rcx
    4bcf:	je     4c43 <botlish_fn_13+0x440b>
    4bd5:	mov    %r14,%rsi
    4bd8:	test   $0x1,%rsi
    4bdf:	jne    4c0f <botlish_fn_13+0x43d7>
    4be5:	mov    $0x75,%edx
    4bea:	mov    %r14,%rsi
    4bed:	mov    0x1e8(%rsp),%rdi
    4bf5:	call   4bfa <botlish_fn_13+0x43c2>
			4bf6: R_X86_64_PLT32	rt_int_cmp-0x4
    4bfa:	mov    $0x2,%ecx
    4bff:	test   %rax,%rax
    4c02:	cmovl  0x1f8e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4c0a:	jmp    4c23 <botlish_fn_13+0x43eb>
    4c0f:	mov    $0x2,%ecx
    4c14:	mov    %r14,%rsi
    4c17:	cmp    $0x75,%rsi
    4c1b:	cmovl  0x1f75(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4c23:	cmp    $0x6,%rcx
    4c27:	je     4c38 <botlish_fn_13+0x4400>
    4c2d:	mov    $0x19,%r12d
    4c33:	jmp    4e63 <botlish_fn_13+0x462b>
    4c38:	mov    $0x7,%r12d
    4c3e:	jmp    4e63 <botlish_fn_13+0x462b>
    4c43:	mov    %r14,%rsi
    4c46:	test   $0x1,%rsi
    4c4d:	jne    4c7d <botlish_fn_13+0x4445>
    4c53:	mov    $0x61,%edx
    4c58:	mov    %r14,%rsi
    4c5b:	mov    0x1e8(%rsp),%rdi
    4c63:	call   4c68 <botlish_fn_13+0x4430>
			4c64: R_X86_64_PLT32	rt_int_cmp-0x4
    4c68:	mov    $0x2,%ecx
    4c6d:	test   %rax,%rax
    4c70:	cmovl  0x1f20(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4c78:	jmp    4c91 <botlish_fn_13+0x4459>
    4c7d:	mov    $0x2,%ecx
    4c82:	mov    %r14,%rsi
    4c85:	cmp    $0x61,%rsi
    4c89:	cmovl  0x1f07(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4c91:	cmp    $0x6,%rcx
    4c95:	je     4ca6 <botlish_fn_13+0x446e>
    4c9b:	mov    $0x5,%r12d
    4ca1:	jmp    4e63 <botlish_fn_13+0x462b>
    4ca6:	mov    $0x19,%r12d
    4cac:	jmp    4e63 <botlish_fn_13+0x462b>
    4cb1:	mov    %r14,%rsi
    4cb4:	test   $0x1,%rsi
    4cbb:	jne    4ceb <botlish_fn_13+0x44b3>
    4cc1:	mov    $0x61,%edx
    4cc6:	mov    %r14,%rsi
    4cc9:	mov    0x1e8(%rsp),%rdi
    4cd1:	call   4cd6 <botlish_fn_13+0x449e>
			4cd2: R_X86_64_PLT32	rt_int_cmp-0x4
    4cd6:	mov    $0x2,%ecx
    4cdb:	test   %rax,%rax
    4cde:	cmovl  0x1eb2(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4ce6:	jmp    4cff <botlish_fn_13+0x44c7>
    4ceb:	mov    $0x2,%ecx
    4cf0:	mov    %r14,%rsi
    4cf3:	cmp    $0x61,%rsi
    4cf7:	cmovl  0x1e99(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4cff:	cmp    $0x6,%rcx
    4d03:	je     4dda <botlish_fn_13+0x45a2>
    4d09:	mov    %r14,%rsi
    4d0c:	test   $0x1,%rsi
    4d13:	jne    4d43 <botlish_fn_13+0x450b>
    4d19:	mov    $0x63,%edx
    4d1e:	mov    %r14,%rsi
    4d21:	mov    0x1e8(%rsp),%rdi
    4d29:	call   4d2e <botlish_fn_13+0x44f6>
			4d2a: R_X86_64_PLT32	rt_int_cmp-0x4
    4d2e:	mov    $0x2,%ecx
    4d33:	test   %rax,%rax
    4d36:	cmovl  0x1e5a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4d3e:	jmp    4d57 <botlish_fn_13+0x451f>
    4d43:	mov    $0x2,%ecx
    4d48:	mov    %r14,%rsi
    4d4b:	cmp    $0x63,%rsi
    4d4f:	cmovl  0x1e41(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4d57:	cmp    $0x6,%rcx
    4d5b:	je     4dcf <botlish_fn_13+0x4597>
    4d61:	mov    %r14,%rsi
    4d64:	test   $0x1,%rsi
    4d6b:	jne    4d9b <botlish_fn_13+0x4563>
    4d71:	mov    $0x75,%edx
    4d76:	mov    %r14,%rsi
    4d79:	mov    0x1e8(%rsp),%rdi
    4d81:	call   4d86 <botlish_fn_13+0x454e>
			4d82: R_X86_64_PLT32	rt_int_cmp-0x4
    4d86:	mov    $0x2,%ecx
    4d8b:	test   %rax,%rax
    4d8e:	cmovl  0x1e02(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4d96:	jmp    4daf <botlish_fn_13+0x4577>
    4d9b:	mov    $0x2,%ecx
    4da0:	mov    %r14,%rsi
    4da3:	cmp    $0x75,%rsi
    4da7:	cmovl  0x1de9(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4daf:	cmp    $0x6,%rcx
    4db3:	je     4dc4 <botlish_fn_13+0x458c>
    4db9:	mov    $0x17,%r12d
    4dbf:	jmp    4e63 <botlish_fn_13+0x462b>
    4dc4:	mov    $0x7,%r12d
    4dca:	jmp    4e63 <botlish_fn_13+0x462b>
    4dcf:	mov    $0x5,%r12d
    4dd5:	jmp    4e63 <botlish_fn_13+0x462b>
    4dda:	mov    %r14,%rsi
    4ddd:	test   $0x1,%rsi
    4de4:	jne    4e14 <botlish_fn_13+0x45dc>
    4dea:	mov    $0x5b,%edx
    4def:	mov    %r14,%rsi
    4df2:	mov    0x1e8(%rsp),%rdi
    4dfa:	call   4dff <botlish_fn_13+0x45c7>
			4dfb: R_X86_64_PLT32	rt_int_cmp-0x4
    4dff:	mov    $0x2,%ecx
    4e04:	test   %rax,%rax
    4e07:	cmovl  0x1d89(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4e0f:	jmp    4e28 <botlish_fn_13+0x45f0>
    4e14:	mov    $0x2,%ecx
    4e19:	mov    %r14,%rsi
    4e1c:	cmp    $0x5b,%rsi
    4e20:	cmovl  0x1d70(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4e28:	cmp    $0x6,%rcx
    4e2c:	je     4e5d <botlish_fn_13+0x4625>
    4e32:	mov    %r14,%rsi
    4e35:	mov    %rsi,%rax
    4e38:	sar    $1,%rax
    4e3b:	cmp    $0x2e,%rax
    4e3f:	jl     4e50 <botlish_fn_13+0x4618>
    4e45:	mov    $0x17,%r12d
    4e4b:	jmp    4e63 <botlish_fn_13+0x462b>
    4e50:	mov    0x280(%rsp),%r12
    4e58:	jmp    4e63 <botlish_fn_13+0x462b>
    4e5d:	mov    $0x17,%r12d
    4e63:	mov    %r12,%rsi
    4e66:	sar    $1,%rsi
    4e69:	cmp    $0x9,%rsi
    4e6d:	jl     4f96 <botlish_fn_13+0x475e>
    4e73:	cmp    $0xa,%rsi
    4e77:	mov    %rsi,%r12
    4e7a:	je     4f7e <botlish_fn_13+0x4746>
    4e80:	mov    %r14,%rsi
    4e83:	test   $0x1,%rsi
    4e8a:	jne    4ebd <botlish_fn_13+0x4685>
    4e90:	mov    0x258(%rsp),%rdx
    4e98:	mov    %r14,%rsi
    4e9b:	mov    0x1e8(%rsp),%rdi
    4ea3:	call   4ea8 <botlish_fn_13+0x4670>
			4ea4: R_X86_64_PLT32	rt_int_cmp-0x4
    4ea8:	mov    $0x2,%ecx
    4ead:	test   %rax,%rax
    4eb0:	cmove  0x1ce0(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4eb8:	jmp    4ed1 <botlish_fn_13+0x4699>
    4ebd:	mov    $0x2,%ecx
    4ec2:	mov    %r14,%rsi
    4ec5:	cmp    $0xffffffffffffffff,%rsi
    4ec9:	cmove  0x1cc7(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    4ed1:	cmp    $0x6,%rcx
    4ed5:	je     4f33 <botlish_fn_13+0x46fb>
    4edb:	mov    %r12,%rsi
    4ede:	mov    0x1e8(%rsp),%rdi
    4ee6:	call   4eeb <botlish_fn_13+0x46b3>
			4ee7: R_X86_64_PLT32	botlish_fn_1-0x4
    4eeb:	mov    0x1e8(%rsp),%rdi
    4ef3:	mov    0x10(%rdi),%rcx
    4ef7:	mov    0x158(%rcx),%rdx
    4efe:	lea    0x1a8(%rsp),%r9
    4f06:	mov    %rax,0x1a8(%rsp)
    4f0e:	mov    %r14,%rsi
    4f11:	mov    %rsi,0x1b0(%rsp)
    4f19:	mov    $0x1,%esi
    4f1e:	mov    $0x5,%ecx
    4f23:	mov    $0x2,%r8d
    4f29:	call   4f2e <botlish_fn_13+0x46f6>
			4f2a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4f2e:	jmp    62a0 <botlish_fn_13+0x5a68>
    4f33:	mov    %r12,%rsi
    4f36:	mov    0x1e8(%rsp),%rdi
    4f3e:	call   4f43 <botlish_fn_13+0x470b>
			4f3f: R_X86_64_PLT32	botlish_fn_1-0x4
    4f43:	mov    0x1e8(%rsp),%rdi
    4f4b:	mov    0x10(%rdi),%rcx
    4f4f:	mov    0x150(%rcx),%rdx
    4f56:	lea    0x1a0(%rsp),%r9
    4f5e:	mov    %rax,0x1a0(%rsp)
    4f66:	mov    $0x2,%ecx
    4f6b:	mov    $0x1,%r8d
    4f71:	mov    %rcx,%rsi
    4f74:	call   4f79 <botlish_fn_13+0x4741>
			4f75: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4f79:	jmp    62a0 <botlish_fn_13+0x5a68>
    4f7e:	mov    %rbx,%r12
    4f81:	mov    0x200(%rsp),%rax
    4f89:	mov    %rax,0x240(%rsp)
    4f91:	jmp    54a1 <botlish_fn_13+0x4c69>
    4f96:	mov    %r12,0x98(%rsp)
    4f9e:	mov    $0x6,%ebx
    4fa3:	movq   $0x6,0x78(%rsp)
    4fac:	mov    0x280(%rsp),%r14
    4fb4:	mov    0x200(%rsp),%r15
    4fbc:	jmp    6443 <botlish_fn_13+0x5c0b>
    4fc1:	mov    %rsi,%r14
    4fc4:	mov    0x200(%rsp),%r15
    4fcc:	mov    0x200(%rsp),%rax
    4fd4:	mov    %rax,0x240(%rsp)
    4fdc:	sar    $1,%r15
    4fdf:	test   %r15,%r15
    4fe2:	jle    5294 <botlish_fn_13+0x4a5c>
    4fe8:	mov    %r14,%rsi
    4feb:	test   $0x1,%rsi
    4ff2:	jne    5022 <botlish_fn_13+0x47ea>
    4ff8:	mov    $0xb9,%edx
    4ffd:	mov    %r14,%rsi
    5000:	mov    0x1e8(%rsp),%rdi
    5008:	call   500d <botlish_fn_13+0x47d5>
			5009: R_X86_64_PLT32	rt_int_cmp-0x4
    500d:	mov    $0x2,%esi
    5012:	test   %rax,%rax
    5015:	cmovl  0x1b7b(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    501d:	jmp    5038 <botlish_fn_13+0x4800>
    5022:	mov    $0x2,%esi
    5027:	mov    %r14,%rax
    502a:	cmp    $0xb9,%rax
    5030:	cmovl  0x1b60(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    5038:	cmp    $0x6,%rsi
    503c:	je     51a1 <botlish_fn_13+0x4969>
    5042:	mov    %r14,%rsi
    5045:	test   $0x1,%rsi
    504c:	jne    507c <botlish_fn_13+0x4844>
    5052:	mov    $0x1b001,%edx
    5057:	mov    %r14,%rsi
    505a:	mov    0x1e8(%rsp),%rdi
    5062:	call   5067 <botlish_fn_13+0x482f>
			5063: R_X86_64_PLT32	rt_int_cmp-0x4
    5067:	mov    $0x2,%ecx
    506c:	test   %rax,%rax
    506f:	cmovl  0x1b21(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5077:	jmp    5093 <botlish_fn_13+0x485b>
    507c:	mov    $0x2,%ecx
    5081:	mov    %r14,%rsi
    5084:	cmp    $0x1b001,%rsi
    508b:	cmovl  0x1b05(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5093:	cmp    $0x6,%rcx
    5097:	je     5176 <botlish_fn_13+0x493e>
    509d:	mov    %r14,%rsi
    50a0:	test   $0x1,%rsi
    50a7:	jne    50d7 <botlish_fn_13+0x489f>
    50ad:	mov    $0x1c001,%edx
    50b2:	mov    %r14,%rsi
    50b5:	mov    0x1e8(%rsp),%rdi
    50bd:	call   50c2 <botlish_fn_13+0x488a>
			50be: R_X86_64_PLT32	rt_int_cmp-0x4
    50c2:	mov    $0x2,%ecx
    50c7:	test   %rax,%rax
    50ca:	cmovl  0x1ac6(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    50d2:	jmp    50ee <botlish_fn_13+0x48b6>
    50d7:	mov    $0x2,%ecx
    50dc:	mov    %r14,%rsi
    50df:	cmp    $0x1c001,%rsi
    50e6:	cmovl  0x1aaa(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    50ee:	cmp    $0x6,%rcx
    50f2:	je     516b <botlish_fn_13+0x4933>
    50f8:	mov    %r14,%rsi
    50fb:	test   $0x1,%rsi
    5102:	jne    5132 <botlish_fn_13+0x48fa>
    5108:	mov    $0x220001,%edx
    510d:	mov    %r14,%rsi
    5110:	mov    0x1e8(%rsp),%rdi
    5118:	call   511d <botlish_fn_13+0x48e5>
			5119: R_X86_64_PLT32	rt_int_cmp-0x4
    511d:	mov    $0x2,%ecx
    5122:	test   %rax,%rax
    5125:	cmovl  0x1a6b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    512d:	jmp    5149 <botlish_fn_13+0x4911>
    5132:	mov    $0x2,%ecx
    5137:	mov    %r14,%rsi
    513a:	cmp    $0x220001,%rsi
    5141:	cmovl  0x1a4f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5149:	cmp    $0x6,%rcx
    514d:	je     515e <botlish_fn_13+0x4926>
    5153:	mov    $0xd,%r15d
    5159:	jmp    5362 <botlish_fn_13+0x4b2a>
    515e:	mov    0x280(%rsp),%r15
    5166:	jmp    5362 <botlish_fn_13+0x4b2a>
    516b:	mov    $0xd,%r15d
    5171:	jmp    5362 <botlish_fn_13+0x4b2a>
    5176:	mov    %r14,%rsi
    5179:	mov    %rsi,%rcx
    517c:	sar    $1,%rcx
    517f:	cmp    $0x5d,%rcx
    5183:	jl     5196 <botlish_fn_13+0x495e>
    5189:	mov    0x280(%rsp),%r15
    5191:	jmp    5362 <botlish_fn_13+0x4b2a>
    5196:	mov    $0x9,%r15d
    519c:	jmp    5362 <botlish_fn_13+0x4b2a>
    51a1:	mov    %r14,%rsi
    51a4:	test   $0x1,%rsi
    51ab:	jne    51db <botlish_fn_13+0x49a3>
    51b1:	mov    $0x45,%edx
    51b6:	mov    %r14,%rsi
    51b9:	mov    0x1e8(%rsp),%rdi
    51c1:	call   51c6 <botlish_fn_13+0x498e>
			51c2: R_X86_64_PLT32	rt_int_cmp-0x4
    51c6:	mov    $0x2,%ecx
    51cb:	test   %rax,%rax
    51ce:	cmovl  0x19c2(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    51d6:	jmp    51ef <botlish_fn_13+0x49b7>
    51db:	mov    $0x2,%ecx
    51e0:	mov    %r14,%rsi
    51e3:	cmp    $0x45,%rsi
    51e7:	cmovl  0x19a9(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    51ef:	cmp    $0x6,%rcx
    51f3:	je     5224 <botlish_fn_13+0x49ec>
    51f9:	mov    %r14,%rsi
    51fc:	mov    %rsi,%rax
    51ff:	sar    $1,%rax
    5202:	cmp    $0x23,%rax
    5206:	jl     5219 <botlish_fn_13+0x49e1>
    520c:	mov    0x280(%rsp),%r15
    5214:	jmp    5362 <botlish_fn_13+0x4b2a>
    5219:	mov    $0x5,%r15d
    521f:	jmp    5362 <botlish_fn_13+0x4b2a>
    5224:	mov    %r14,%rsi
    5227:	test   $0x1,%rsi
    522e:	jne    525e <botlish_fn_13+0x4a26>
    5234:	mov    $0x41,%edx
    5239:	mov    %r14,%rsi
    523c:	mov    0x1e8(%rsp),%rdi
    5244:	call   5249 <botlish_fn_13+0x4a11>
			5245: R_X86_64_PLT32	rt_int_cmp-0x4
    5249:	mov    $0x2,%ecx
    524e:	test   %rax,%rax
    5251:	cmovl  0x193f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5259:	jmp    5272 <botlish_fn_13+0x4a3a>
    525e:	mov    $0x2,%ecx
    5263:	mov    %r14,%rsi
    5266:	cmp    $0x41,%rsi
    526a:	cmovl  0x1926(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5272:	cmp    $0x6,%rcx
    5276:	je     5289 <botlish_fn_13+0x4a51>
    527c:	mov    0x280(%rsp),%r15
    5284:	jmp    5362 <botlish_fn_13+0x4b2a>
    5289:	mov    $0xd,%r15d
    528f:	jmp    5362 <botlish_fn_13+0x4b2a>
    5294:	mov    %r14,%rsi
    5297:	test   $0x1,%rsi
    529e:	jne    52ce <botlish_fn_13+0x4a96>
    52a4:	mov    $0x45,%edx
    52a9:	mov    %r14,%rsi
    52ac:	mov    0x1e8(%rsp),%rdi
    52b4:	call   52b9 <botlish_fn_13+0x4a81>
			52b5: R_X86_64_PLT32	rt_int_cmp-0x4
    52b9:	mov    $0x2,%ecx
    52be:	test   %rax,%rax
    52c1:	cmovl  0x18cf(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    52c9:	jmp    52e2 <botlish_fn_13+0x4aaa>
    52ce:	mov    $0x2,%ecx
    52d3:	mov    %r14,%rsi
    52d6:	cmp    $0x45,%rsi
    52da:	cmovl  0x18b6(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    52e2:	cmp    $0x6,%rcx
    52e6:	je     535c <botlish_fn_13+0x4b24>
    52ec:	mov    %r14,%rsi
    52ef:	test   $0x1,%rsi
    52f6:	jne    5326 <botlish_fn_13+0x4aee>
    52fc:	mov    $0x47,%edx
    5301:	mov    %r14,%rsi
    5304:	mov    0x1e8(%rsp),%rdi
    530c:	call   5311 <botlish_fn_13+0x4ad9>
			530d: R_X86_64_PLT32	rt_int_cmp-0x4
    5311:	mov    $0x2,%edx
    5316:	test   %rax,%rax
    5319:	cmovl  0x1877(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    5321:	jmp    533a <botlish_fn_13+0x4b02>
    5326:	mov    $0x2,%edx
    532b:	mov    %r14,%rsi
    532e:	cmp    $0x47,%rsi
    5332:	cmovl  0x185e(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    533a:	cmp    $0x6,%rdx
    533e:	je     534f <botlish_fn_13+0x4b17>
    5344:	mov    $0xb,%r15d
    534a:	jmp    5362 <botlish_fn_13+0x4b2a>
    534f:	mov    0x280(%rsp),%r15
    5357:	jmp    5362 <botlish_fn_13+0x4b2a>
    535c:	mov    $0xb,%r15d
    5362:	mov    %r15,%rsi
    5365:	sar    $1,%rsi
    5368:	cmp    $0x2,%rsi
    536c:	jl     550b <botlish_fn_13+0x4cd3>
    5372:	cmp    $0x2,%rsi
    5376:	je     5497 <botlish_fn_13+0x4c5f>
    537c:	cmp    $0x4,%rsi
    5380:	mov    %rsi,%rbx
    5383:	je     5487 <botlish_fn_13+0x4c4f>
    5389:	mov    %r14,%rsi
    538c:	test   $0x1,%rsi
    5393:	jne    53c6 <botlish_fn_13+0x4b8e>
    5399:	mov    0x258(%rsp),%rdx
    53a1:	mov    %r14,%rsi
    53a4:	mov    0x1e8(%rsp),%rdi
    53ac:	call   53b1 <botlish_fn_13+0x4b79>
			53ad: R_X86_64_PLT32	rt_int_cmp-0x4
    53b1:	mov    $0x2,%edi
    53b6:	test   %rax,%rax
    53b9:	cmove  0x17d7(%rip),%rdi        # 6b98 <botlish_fn_13+0x6360>
    53c1:	jmp    53da <botlish_fn_13+0x4ba2>
    53c6:	mov    $0x2,%edi
    53cb:	mov    %r14,%rsi
    53ce:	cmp    $0xffffffffffffffff,%rsi
    53d2:	cmove  0x17be(%rip),%rdi        # 6b98 <botlish_fn_13+0x6360>
    53da:	cmp    $0x6,%rdi
    53de:	je     543c <botlish_fn_13+0x4c04>
    53e4:	mov    %rbx,%rsi
    53e7:	mov    0x1e8(%rsp),%rdi
    53ef:	call   53f4 <botlish_fn_13+0x4bbc>
			53f0: R_X86_64_PLT32	botlish_fn_7-0x4
    53f4:	mov    0x1e8(%rsp),%rdi
    53fc:	mov    0x10(%rdi),%rsi
    5400:	mov    0x158(%rsi),%rdx
    5407:	lea    0x190(%rsp),%r9
    540f:	mov    %rax,0x190(%rsp)
    5417:	mov    %r14,%rsi
    541a:	mov    %rsi,0x198(%rsp)
    5422:	mov    $0x1,%esi
    5427:	mov    $0x5,%ecx
    542c:	mov    $0x2,%r8d
    5432:	call   5437 <botlish_fn_13+0x4bff>
			5433: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5437:	jmp    62a0 <botlish_fn_13+0x5a68>
    543c:	mov    %rbx,%rsi
    543f:	mov    0x1e8(%rsp),%rdi
    5447:	call   544c <botlish_fn_13+0x4c14>
			5448: R_X86_64_PLT32	botlish_fn_7-0x4
    544c:	mov    0x1e8(%rsp),%rdi
    5454:	mov    0x10(%rdi),%r9
    5458:	mov    0x150(%r9),%rdx
    545f:	lea    0x188(%rsp),%r9
    5467:	mov    %rax,0x188(%rsp)
    546f:	mov    $0x2,%ecx
    5474:	mov    $0x1,%r8d
    547a:	mov    %rcx,%rsi
    547d:	call   5482 <botlish_fn_13+0x4c4a>
			547e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5482:	jmp    62a0 <botlish_fn_13+0x5a68>
    5487:	xor    %rcx,%rcx
    548a:	mov    0x240(%rsp),%r15
    5492:	jmp    5531 <botlish_fn_13+0x4cf9>
    5497:	mov    $0xfffffffffffffffd,%rsi
    549e:	mov    %rsi,%r14
    54a1:	mov    %r14,%rsi
    54a4:	test   $0x1,%rsi
    54ab:	jne    54dd <botlish_fn_13+0x4ca5>
    54b1:	mov    $0xfffffffffffffffd,%rdx
    54b8:	mov    %r14,%rsi
    54bb:	mov    0x1e8(%rsp),%rdi
    54c3:	call   54c8 <botlish_fn_13+0x4c90>
			54c4: R_X86_64_PLT32	rt_int_cmp-0x4
    54c8:	mov    $0x2,%ebx
    54cd:	test   %rax,%rax
    54d0:	cmove  0x16c0(%rip),%rbx        # 6b98 <botlish_fn_13+0x6360>
    54d8:	jmp    54f1 <botlish_fn_13+0x4cb9>
    54dd:	mov    $0x2,%ebx
    54e2:	mov    %r14,%rsi
    54e5:	cmp    $0xfffffffffffffffd,%rsi
    54e9:	cmove  0x16a7(%rip),%rbx        # 6b98 <botlish_fn_13+0x6360>
    54f1:	mov    %rbx,0x78(%rsp)
    54f6:	mov    0x258(%rsp),%r14
    54fe:	mov    0x240(%rsp),%r15
    5506:	jmp    6443 <botlish_fn_13+0x5c0b>
    550b:	mov    %r15,0x88(%rsp)
    5513:	jmp    6406 <botlish_fn_13+0x5bce>
    5518:	mov    0x238(%rsp),%rax
    5520:	mov    %rsi,%r14
    5523:	mov    0x200(%rsp),%r15
    552b:	mov    %rax,%rcx
    552e:	sar    $1,%rcx
    5531:	cmp    $0x3,%rcx
    5535:	jl     5ad0 <botlish_fn_13+0x5298>
    553b:	cmp    $0x4,%rcx
    553f:	jl     58f9 <botlish_fn_13+0x50c1>
    5545:	cmp    $0x5,%rcx
    5549:	jl     5724 <botlish_fn_13+0x4eec>
    554f:	mov    %r14,%rsi
    5552:	test   $0x1,%rsi
    5559:	jne    5589 <botlish_fn_13+0x4d51>
    555f:	mov    $0x83,%edx
    5564:	mov    %r14,%rsi
    5567:	mov    0x1e8(%rsp),%rdi
    556f:	call   5574 <botlish_fn_13+0x4d3c>
			5570: R_X86_64_PLT32	rt_int_cmp-0x4
    5574:	mov    $0x2,%ecx
    5579:	test   %rax,%rax
    557c:	cmovl  0x1614(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5584:	jmp    55a0 <botlish_fn_13+0x4d68>
    5589:	mov    $0x2,%ecx
    558e:	mov    %r14,%rsi
    5591:	cmp    $0x83,%rsi
    5598:	cmovl  0x15f8(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    55a0:	cmp    $0x6,%rcx
    55a4:	je     569b <botlish_fn_13+0x4e63>
    55aa:	mov    %r14,%rsi
    55ad:	test   $0x1,%rsi
    55b4:	jne    55e4 <botlish_fn_13+0x4dac>
    55ba:	mov    $0xc3,%edx
    55bf:	mov    %r14,%rsi
    55c2:	mov    0x1e8(%rsp),%rdi
    55ca:	call   55cf <botlish_fn_13+0x4d97>
			55cb: R_X86_64_PLT32	rt_int_cmp-0x4
    55cf:	mov    $0x2,%ecx
    55d4:	test   %rax,%rax
    55d7:	cmovl  0x15b9(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    55df:	jmp    55fb <botlish_fn_13+0x4dc3>
    55e4:	mov    $0x2,%ecx
    55e9:	mov    %r14,%rsi
    55ec:	cmp    $0xc3,%rsi
    55f3:	cmovl  0x159d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    55fb:	cmp    $0x6,%rcx
    55ff:	je     5674 <botlish_fn_13+0x4e3c>
    5605:	mov    %r14,%rsi
    5608:	test   $0x1,%rsi
    560f:	jne    563f <botlish_fn_13+0x4e07>
    5615:	mov    $0xcf,%edx
    561a:	mov    %r14,%rsi
    561d:	mov    0x1e8(%rsp),%rdi
    5625:	call   562a <botlish_fn_13+0x4df2>
			5626: R_X86_64_PLT32	rt_int_cmp-0x4
    562a:	mov    $0x2,%ecx
    562f:	test   %rax,%rax
    5632:	cmovl  0x155e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    563a:	jmp    5656 <botlish_fn_13+0x4e1e>
    563f:	mov    $0x2,%ecx
    5644:	mov    %r14,%rsi
    5647:	cmp    $0xcf,%rsi
    564e:	cmovl  0x1542(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5656:	cmp    $0x6,%rcx
    565a:	je     566a <botlish_fn_13+0x4e32>
    5660:	mov    $0x1b,%ecx
    5665:	jmp    618a <botlish_fn_13+0x5952>
    566a:	mov    $0xd,%ecx
    566f:	jmp    618a <botlish_fn_13+0x5952>
    5674:	mov    %r14,%rsi
    5677:	mov    %rsi,%rax
    567a:	sar    $1,%rax
    567d:	cmp    $0x47,%rax
    5681:	jl     5691 <botlish_fn_13+0x4e59>
    5687:	mov    $0x1b,%ecx
    568c:	jmp    618a <botlish_fn_13+0x5952>
    5691:	mov    $0xd,%ecx
    5696:	jmp    618a <botlish_fn_13+0x5952>
    569b:	mov    %r14,%rsi
    569e:	test   $0x1,%rsi
    56a5:	jne    56d5 <botlish_fn_13+0x4e9d>
    56ab:	mov    $0x61,%edx
    56b0:	mov    %r14,%rsi
    56b3:	mov    0x1e8(%rsp),%rdi
    56bb:	call   56c0 <botlish_fn_13+0x4e88>
			56bc: R_X86_64_PLT32	rt_int_cmp-0x4
    56c0:	mov    $0x2,%ecx
    56c5:	test   %rax,%rax
    56c8:	cmovl  0x14c8(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    56d0:	jmp    56e9 <botlish_fn_13+0x4eb1>
    56d5:	mov    $0x2,%ecx
    56da:	mov    %r14,%rsi
    56dd:	cmp    $0x61,%rsi
    56e1:	cmovl  0x14af(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    56e9:	cmp    $0x6,%rcx
    56ed:	je     571a <botlish_fn_13+0x4ee2>
    56f3:	mov    %r14,%rsi
    56f6:	mov    %rsi,%rax
    56f9:	sar    $1,%rax
    56fc:	cmp    $0x3a,%rax
    5700:	jl     5710 <botlish_fn_13+0x4ed8>
    5706:	mov    $0x1b,%ecx
    570b:	jmp    618a <botlish_fn_13+0x5952>
    5710:	mov    $0xd,%ecx
    5715:	jmp    618a <botlish_fn_13+0x5952>
    571a:	mov    $0x1b,%ecx
    571f:	jmp    618a <botlish_fn_13+0x5952>
    5724:	mov    %r14,%rsi
    5727:	test   $0x1,%rsi
    572e:	jne    575e <botlish_fn_13+0x4f26>
    5734:	mov    $0x83,%edx
    5739:	mov    %r14,%rsi
    573c:	mov    0x1e8(%rsp),%rdi
    5744:	call   5749 <botlish_fn_13+0x4f11>
			5745: R_X86_64_PLT32	rt_int_cmp-0x4
    5749:	mov    $0x2,%edi
    574e:	test   %rax,%rax
    5751:	cmovl  0x143f(%rip),%rdi        # 6b98 <botlish_fn_13+0x6360>
    5759:	jmp    5775 <botlish_fn_13+0x4f3d>
    575e:	mov    $0x2,%edi
    5763:	mov    %r14,%rsi
    5766:	cmp    $0x83,%rsi
    576d:	cmovl  0x1423(%rip),%rdi        # 6b98 <botlish_fn_13+0x6360>
    5775:	cmp    $0x6,%rdi
    5779:	je     5870 <botlish_fn_13+0x5038>
    577f:	mov    %r14,%rsi
    5782:	test   $0x1,%rsi
    5789:	jne    57b9 <botlish_fn_13+0x4f81>
    578f:	mov    $0xc3,%edx
    5794:	mov    %r14,%rsi
    5797:	mov    0x1e8(%rsp),%rdi
    579f:	call   57a4 <botlish_fn_13+0x4f6c>
			57a0: R_X86_64_PLT32	rt_int_cmp-0x4
    57a4:	mov    $0x2,%ecx
    57a9:	test   %rax,%rax
    57ac:	cmovl  0x13e4(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    57b4:	jmp    57d0 <botlish_fn_13+0x4f98>
    57b9:	mov    $0x2,%ecx
    57be:	mov    %r14,%rsi
    57c1:	cmp    $0xc3,%rsi
    57c8:	cmovl  0x13c8(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    57d0:	cmp    $0x6,%rcx
    57d4:	je     5849 <botlish_fn_13+0x5011>
    57da:	mov    %r14,%rsi
    57dd:	test   $0x1,%rsi
    57e4:	jne    5814 <botlish_fn_13+0x4fdc>
    57ea:	mov    $0xcf,%edx
    57ef:	mov    %r14,%rsi
    57f2:	mov    0x1e8(%rsp),%rdi
    57fa:	call   57ff <botlish_fn_13+0x4fc7>
			57fb: R_X86_64_PLT32	rt_int_cmp-0x4
    57ff:	mov    $0x2,%ecx
    5804:	test   %rax,%rax
    5807:	cmovl  0x1389(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    580f:	jmp    582b <botlish_fn_13+0x4ff3>
    5814:	mov    $0x2,%ecx
    5819:	mov    %r14,%rsi
    581c:	cmp    $0xcf,%rsi
    5823:	cmovl  0x136d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    582b:	cmp    $0x6,%rcx
    582f:	je     583f <botlish_fn_13+0x5007>
    5835:	mov    $0x19,%ecx
    583a:	jmp    618a <botlish_fn_13+0x5952>
    583f:	mov    $0xb,%ecx
    5844:	jmp    618a <botlish_fn_13+0x5952>
    5849:	mov    %r14,%rsi
    584c:	mov    %rsi,%rax
    584f:	sar    $1,%rax
    5852:	cmp    $0x47,%rax
    5856:	jl     5866 <botlish_fn_13+0x502e>
    585c:	mov    $0x19,%ecx
    5861:	jmp    618a <botlish_fn_13+0x5952>
    5866:	mov    $0xb,%ecx
    586b:	jmp    618a <botlish_fn_13+0x5952>
    5870:	mov    %r14,%rsi
    5873:	test   $0x1,%rsi
    587a:	jne    58aa <botlish_fn_13+0x5072>
    5880:	mov    $0x61,%edx
    5885:	mov    %r14,%rsi
    5888:	mov    0x1e8(%rsp),%rdi
    5890:	call   5895 <botlish_fn_13+0x505d>
			5891: R_X86_64_PLT32	rt_int_cmp-0x4
    5895:	mov    $0x2,%ecx
    589a:	test   %rax,%rax
    589d:	cmovl  0x12f3(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    58a5:	jmp    58be <botlish_fn_13+0x5086>
    58aa:	mov    $0x2,%ecx
    58af:	mov    %r14,%rsi
    58b2:	cmp    $0x61,%rsi
    58b6:	cmovl  0x12da(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    58be:	cmp    $0x6,%rcx
    58c2:	je     58ef <botlish_fn_13+0x50b7>
    58c8:	mov    %r14,%rsi
    58cb:	mov    %rsi,%rax
    58ce:	sar    $1,%rax
    58d1:	cmp    $0x3a,%rax
    58d5:	jl     58e5 <botlish_fn_13+0x50ad>
    58db:	mov    $0x19,%ecx
    58e0:	jmp    618a <botlish_fn_13+0x5952>
    58e5:	mov    $0xb,%ecx
    58ea:	jmp    618a <botlish_fn_13+0x5952>
    58ef:	mov    $0x19,%ecx
    58f4:	jmp    618a <botlish_fn_13+0x5952>
    58f9:	mov    %r14,%rsi
    58fc:	test   $0x1,%rsi
    5903:	jne    5933 <botlish_fn_13+0x50fb>
    5909:	mov    $0x83,%edx
    590e:	mov    %r14,%rsi
    5911:	mov    0x1e8(%rsp),%rdi
    5919:	call   591e <botlish_fn_13+0x50e6>
			591a: R_X86_64_PLT32	rt_int_cmp-0x4
    591e:	mov    $0x2,%ecx
    5923:	test   %rax,%rax
    5926:	cmovl  0x126a(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    592e:	jmp    594a <botlish_fn_13+0x5112>
    5933:	mov    $0x2,%ecx
    5938:	mov    %r14,%rsi
    593b:	cmp    $0x83,%rsi
    5942:	cmovl  0x124e(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    594a:	cmp    $0x6,%rcx
    594e:	je     5a45 <botlish_fn_13+0x520d>
    5954:	mov    %r14,%rsi
    5957:	test   $0x1,%rsi
    595e:	jne    598e <botlish_fn_13+0x5156>
    5964:	mov    $0xc3,%edx
    5969:	mov    %r14,%rsi
    596c:	mov    0x1e8(%rsp),%rdi
    5974:	call   5979 <botlish_fn_13+0x5141>
			5975: R_X86_64_PLT32	rt_int_cmp-0x4
    5979:	mov    $0x2,%ecx
    597e:	test   %rax,%rax
    5981:	cmovl  0x120f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5989:	jmp    59a5 <botlish_fn_13+0x516d>
    598e:	mov    $0x2,%ecx
    5993:	mov    %r14,%rsi
    5996:	cmp    $0xc3,%rsi
    599d:	cmovl  0x11f3(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    59a5:	cmp    $0x6,%rcx
    59a9:	je     5a1e <botlish_fn_13+0x51e6>
    59af:	mov    %r14,%rsi
    59b2:	test   $0x1,%rsi
    59b9:	jne    59e9 <botlish_fn_13+0x51b1>
    59bf:	mov    $0xcf,%edx
    59c4:	mov    %r14,%rsi
    59c7:	mov    0x1e8(%rsp),%rdi
    59cf:	call   59d4 <botlish_fn_13+0x519c>
			59d0: R_X86_64_PLT32	rt_int_cmp-0x4
    59d4:	mov    $0x2,%ecx
    59d9:	test   %rax,%rax
    59dc:	cmovl  0x11b4(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    59e4:	jmp    5a00 <botlish_fn_13+0x51c8>
    59e9:	mov    $0x2,%ecx
    59ee:	mov    %r14,%rsi
    59f1:	cmp    $0xcf,%rsi
    59f8:	cmovl  0x1198(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5a00:	cmp    $0x6,%rcx
    5a04:	je     5a14 <botlish_fn_13+0x51dc>
    5a0a:	mov    $0x17,%ecx
    5a0f:	jmp    618a <botlish_fn_13+0x5952>
    5a14:	mov    $0x9,%ecx
    5a19:	jmp    618a <botlish_fn_13+0x5952>
    5a1e:	mov    %r14,%rsi
    5a21:	mov    %rsi,%rax
    5a24:	sar    $1,%rax
    5a27:	cmp    $0x47,%rax
    5a2b:	jl     5a3b <botlish_fn_13+0x5203>
    5a31:	mov    $0x17,%ecx
    5a36:	jmp    618a <botlish_fn_13+0x5952>
    5a3b:	mov    $0x9,%ecx
    5a40:	jmp    618a <botlish_fn_13+0x5952>
    5a45:	mov    %r14,%rsi
    5a48:	test   $0x1,%rsi
    5a4f:	jne    5a80 <botlish_fn_13+0x5248>
    5a55:	mov    $0x61,%edx
    5a5a:	mov    %r14,%rsi
    5a5d:	mov    0x1e8(%rsp),%rdi
    5a65:	call   5a6a <botlish_fn_13+0x5232>
			5a66: R_X86_64_PLT32	rt_int_cmp-0x4
    5a6a:	mov    $0x2,%r11d
    5a70:	test   %rax,%rax
    5a73:	cmovl  0x111d(%rip),%r11        # 6b98 <botlish_fn_13+0x6360>
    5a7b:	jmp    5a95 <botlish_fn_13+0x525d>
    5a80:	mov    $0x2,%r11d
    5a86:	mov    %r14,%rsi
    5a89:	cmp    $0x61,%rsi
    5a8d:	cmovl  0x1103(%rip),%r11        # 6b98 <botlish_fn_13+0x6360>
    5a95:	cmp    $0x6,%r11
    5a99:	je     5ac6 <botlish_fn_13+0x528e>
    5a9f:	mov    %r14,%rsi
    5aa2:	mov    %rsi,%rax
    5aa5:	sar    $1,%rax
    5aa8:	cmp    $0x3a,%rax
    5aac:	jl     5abc <botlish_fn_13+0x5284>
    5ab2:	mov    $0x17,%ecx
    5ab7:	jmp    618a <botlish_fn_13+0x5952>
    5abc:	mov    $0x9,%ecx
    5ac1:	jmp    618a <botlish_fn_13+0x5952>
    5ac6:	mov    $0x17,%ecx
    5acb:	jmp    618a <botlish_fn_13+0x5952>
    5ad0:	test   %rcx,%rcx
    5ad3:	jle    60b8 <botlish_fn_13+0x5880>
    5ad9:	cmp    $0x2,%rcx
    5add:	jl     5cb8 <botlish_fn_13+0x5480>
    5ae3:	mov    %r14,%rsi
    5ae6:	test   $0x1,%rsi
    5aed:	jne    5b1d <botlish_fn_13+0x52e5>
    5af3:	mov    $0x83,%edx
    5af8:	mov    %r14,%rsi
    5afb:	mov    0x1e8(%rsp),%rdi
    5b03:	call   5b08 <botlish_fn_13+0x52d0>
			5b04: R_X86_64_PLT32	rt_int_cmp-0x4
    5b08:	mov    $0x2,%ecx
    5b0d:	test   %rax,%rax
    5b10:	cmovl  0x1080(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5b18:	jmp    5b34 <botlish_fn_13+0x52fc>
    5b1d:	mov    $0x2,%ecx
    5b22:	mov    %r14,%rsi
    5b25:	cmp    $0x83,%rsi
    5b2c:	cmovl  0x1064(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5b34:	cmp    $0x6,%rcx
    5b38:	je     5c2f <botlish_fn_13+0x53f7>
    5b3e:	mov    %r14,%rsi
    5b41:	test   $0x1,%rsi
    5b48:	jne    5b78 <botlish_fn_13+0x5340>
    5b4e:	mov    $0xc3,%edx
    5b53:	mov    %r14,%rsi
    5b56:	mov    0x1e8(%rsp),%rdi
    5b5e:	call   5b63 <botlish_fn_13+0x532b>
			5b5f: R_X86_64_PLT32	rt_int_cmp-0x4
    5b63:	mov    $0x2,%ecx
    5b68:	test   %rax,%rax
    5b6b:	cmovl  0x1025(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5b73:	jmp    5b8f <botlish_fn_13+0x5357>
    5b78:	mov    $0x2,%ecx
    5b7d:	mov    %r14,%rsi
    5b80:	cmp    $0xc3,%rsi
    5b87:	cmovl  0x1009(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5b8f:	cmp    $0x6,%rcx
    5b93:	je     5c08 <botlish_fn_13+0x53d0>
    5b99:	mov    %r14,%rsi
    5b9c:	test   $0x1,%rsi
    5ba3:	jne    5bd3 <botlish_fn_13+0x539b>
    5ba9:	mov    $0xcf,%edx
    5bae:	mov    %r14,%rsi
    5bb1:	mov    0x1e8(%rsp),%rdi
    5bb9:	call   5bbe <botlish_fn_13+0x5386>
			5bba: R_X86_64_PLT32	rt_int_cmp-0x4
    5bbe:	mov    $0x2,%ecx
    5bc3:	test   %rax,%rax
    5bc6:	cmovl  0xfca(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5bce:	jmp    5bea <botlish_fn_13+0x53b2>
    5bd3:	mov    $0x2,%ecx
    5bd8:	mov    %r14,%rsi
    5bdb:	cmp    $0xcf,%rsi
    5be2:	cmovl  0xfae(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5bea:	cmp    $0x6,%rcx
    5bee:	je     5bfe <botlish_fn_13+0x53c6>
    5bf4:	mov    $0x15,%ecx
    5bf9:	jmp    618a <botlish_fn_13+0x5952>
    5bfe:	mov    $0x7,%ecx
    5c03:	jmp    618a <botlish_fn_13+0x5952>
    5c08:	mov    %r14,%rsi
    5c0b:	mov    %rsi,%rax
    5c0e:	sar    $1,%rax
    5c11:	cmp    $0x47,%rax
    5c15:	jl     5c25 <botlish_fn_13+0x53ed>
    5c1b:	mov    $0x15,%ecx
    5c20:	jmp    618a <botlish_fn_13+0x5952>
    5c25:	mov    $0x7,%ecx
    5c2a:	jmp    618a <botlish_fn_13+0x5952>
    5c2f:	mov    %r14,%rsi
    5c32:	test   $0x1,%rsi
    5c39:	jne    5c69 <botlish_fn_13+0x5431>
    5c3f:	mov    $0x61,%edx
    5c44:	mov    %r14,%rsi
    5c47:	mov    0x1e8(%rsp),%rdi
    5c4f:	call   5c54 <botlish_fn_13+0x541c>
			5c50: R_X86_64_PLT32	rt_int_cmp-0x4
    5c54:	mov    $0x2,%ecx
    5c59:	test   %rax,%rax
    5c5c:	cmovl  0xf34(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5c64:	jmp    5c7d <botlish_fn_13+0x5445>
    5c69:	mov    $0x2,%ecx
    5c6e:	mov    %r14,%rsi
    5c71:	cmp    $0x61,%rsi
    5c75:	cmovl  0xf1b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5c7d:	cmp    $0x6,%rcx
    5c81:	je     5cae <botlish_fn_13+0x5476>
    5c87:	mov    %r14,%rsi
    5c8a:	mov    %rsi,%rax
    5c8d:	sar    $1,%rax
    5c90:	cmp    $0x3a,%rax
    5c94:	jl     5ca4 <botlish_fn_13+0x546c>
    5c9a:	mov    $0x15,%ecx
    5c9f:	jmp    618a <botlish_fn_13+0x5952>
    5ca4:	mov    $0x7,%ecx
    5ca9:	jmp    618a <botlish_fn_13+0x5952>
    5cae:	mov    $0x15,%ecx
    5cb3:	jmp    618a <botlish_fn_13+0x5952>
    5cb8:	mov    %r14,%rsi
    5cbb:	test   $0x1,%rsi
    5cc2:	jne    5cf2 <botlish_fn_13+0x54ba>
    5cc8:	mov    $0xcd,%edx
    5ccd:	mov    %r14,%rsi
    5cd0:	mov    0x1e8(%rsp),%rdi
    5cd8:	call   5cdd <botlish_fn_13+0x54a5>
			5cd9: R_X86_64_PLT32	rt_int_cmp-0x4
    5cdd:	mov    $0x2,%ecx
    5ce2:	test   %rax,%rax
    5ce5:	cmovl  0xeab(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5ced:	jmp    5d09 <botlish_fn_13+0x54d1>
    5cf2:	mov    $0x2,%ecx
    5cf7:	mov    %r14,%rsi
    5cfa:	cmp    $0xcd,%rsi
    5d01:	cmovl  0xe8f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5d09:	cmp    $0x6,%rcx
    5d0d:	je     5f12 <botlish_fn_13+0x56da>
    5d13:	mov    %r14,%rsi
    5d16:	test   $0x1,%rsi
    5d1d:	jne    5d4d <botlish_fn_13+0x5515>
    5d23:	mov    $0xe5,%edx
    5d28:	mov    %r14,%rsi
    5d2b:	mov    0x1e8(%rsp),%rdi
    5d33:	call   5d38 <botlish_fn_13+0x5500>
			5d34: R_X86_64_PLT32	rt_int_cmp-0x4
    5d38:	mov    $0x2,%ecx
    5d3d:	test   %rax,%rax
    5d40:	cmovl  0xe50(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5d48:	jmp    5d64 <botlish_fn_13+0x552c>
    5d4d:	mov    $0x2,%ecx
    5d52:	mov    %r14,%rsi
    5d55:	cmp    $0xe5,%rsi
    5d5c:	cmovl  0xe34(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5d64:	cmp    $0x6,%rcx
    5d68:	je     5ec3 <botlish_fn_13+0x568b>
    5d6e:	mov    %r14,%rsi
    5d71:	test   $0x1,%rsi
    5d78:	jne    5da8 <botlish_fn_13+0x5570>
    5d7e:	mov    $0xe9,%edx
    5d83:	mov    %r14,%rsi
    5d86:	mov    0x1e8(%rsp),%rdi
    5d8e:	call   5d93 <botlish_fn_13+0x555b>
			5d8f: R_X86_64_PLT32	rt_int_cmp-0x4
    5d93:	mov    $0x2,%esi
    5d98:	test   %rax,%rax
    5d9b:	cmovl  0xdf5(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    5da3:	jmp    5dbe <botlish_fn_13+0x5586>
    5da8:	mov    $0x2,%esi
    5dad:	mov    %r14,%rax
    5db0:	cmp    $0xe9,%rax
    5db6:	cmovl  0xdda(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    5dbe:	cmp    $0x6,%rsi
    5dc2:	je     5e9c <botlish_fn_13+0x5664>
    5dc8:	mov    %r14,%rsi
    5dcb:	test   $0x1,%rsi
    5dd2:	jne    5e02 <botlish_fn_13+0x55ca>
    5dd8:	mov    $0xeb,%edx
    5ddd:	mov    %r14,%rsi
    5de0:	mov    0x1e8(%rsp),%rdi
    5de8:	call   5ded <botlish_fn_13+0x55b5>
			5de9: R_X86_64_PLT32	rt_int_cmp-0x4
    5ded:	mov    $0x2,%ecx
    5df2:	test   %rax,%rax
    5df5:	cmovl  0xd9b(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5dfd:	jmp    5e19 <botlish_fn_13+0x55e1>
    5e02:	mov    $0x2,%ecx
    5e07:	mov    %r14,%rsi
    5e0a:	cmp    $0xeb,%rsi
    5e11:	cmovl  0xd7f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5e19:	cmp    $0x6,%rcx
    5e1d:	je     5e92 <botlish_fn_13+0x565a>
    5e23:	mov    %r14,%rsi
    5e26:	test   $0x1,%rsi
    5e2d:	jne    5e5d <botlish_fn_13+0x5625>
    5e33:	mov    $0xed,%edx
    5e38:	mov    %r14,%rsi
    5e3b:	mov    0x1e8(%rsp),%rdi
    5e43:	call   5e48 <botlish_fn_13+0x5610>
			5e44: R_X86_64_PLT32	rt_int_cmp-0x4
    5e48:	mov    $0x2,%ecx
    5e4d:	test   %rax,%rax
    5e50:	cmovl  0xd40(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5e58:	jmp    5e74 <botlish_fn_13+0x563c>
    5e5d:	mov    $0x2,%ecx
    5e62:	mov    %r14,%rsi
    5e65:	cmp    $0xed,%rsi
    5e6c:	cmovl  0xd24(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    5e74:	cmp    $0x6,%rcx
    5e78:	je     5e88 <botlish_fn_13+0x5650>
    5e7e:	mov    $0x13,%ecx
    5e83:	jmp    618a <botlish_fn_13+0x5952>
    5e88:	mov    $0x5,%ecx
    5e8d:	jmp    618a <botlish_fn_13+0x5952>
    5e92:	mov    $0xd,%ecx
    5e97:	jmp    618a <botlish_fn_13+0x5952>
    5e9c:	mov    %r14,%rsi
    5e9f:	mov    %rsi,%rax
    5ea2:	sar    $1,%rax
    5ea5:	cmp    $0x73,%rax
    5ea9:	jl     5eb9 <botlish_fn_13+0x5681>
    5eaf:	mov    $0x13,%ecx
    5eb4:	jmp    618a <botlish_fn_13+0x5952>
    5eb9:	mov    $0xd,%ecx
    5ebe:	jmp    618a <botlish_fn_13+0x5952>
    5ec3:	mov    %r14,%rsi
    5ec6:	mov    %rsi,%rcx
    5ec9:	sar    $1,%rcx
    5ecc:	cmp    $0x6e,%rcx
    5ed0:	jl     5ef4 <botlish_fn_13+0x56bc>
    5ed6:	cmp    $0x6f,%rcx
    5eda:	jl     5eea <botlish_fn_13+0x56b2>
    5ee0:	mov    $0x13,%ecx
    5ee5:	jmp    618a <botlish_fn_13+0x5952>
    5eea:	mov    $0xd,%ecx
    5eef:	jmp    618a <botlish_fn_13+0x5952>
    5ef4:	cmp    $0x67,%rcx
    5ef8:	jl     5f08 <botlish_fn_13+0x56d0>
    5efe:	mov    $0x13,%ecx
    5f03:	jmp    618a <botlish_fn_13+0x5952>
    5f08:	mov    $0xd,%ecx
    5f0d:	jmp    618a <botlish_fn_13+0x5952>
    5f12:	mov    %r14,%rsi
    5f15:	test   $0x1,%rsi
    5f1c:	jne    5f4c <botlish_fn_13+0x5714>
    5f22:	mov    $0x61,%edx
    5f27:	mov    %r14,%rsi
    5f2a:	mov    0x1e8(%rsp),%rdi
    5f32:	call   5f37 <botlish_fn_13+0x56ff>
			5f33: R_X86_64_PLT32	rt_int_cmp-0x4
    5f37:	mov    $0x2,%esi
    5f3c:	test   %rax,%rax
    5f3f:	cmovl  0xc51(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    5f47:	jmp    5f60 <botlish_fn_13+0x5728>
    5f4c:	mov    $0x2,%esi
    5f51:	mov    %r14,%rax
    5f54:	cmp    $0x61,%rax
    5f58:	cmovl  0xc38(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    5f60:	cmp    $0x6,%rsi
    5f64:	je     5fcd <botlish_fn_13+0x5795>
    5f6a:	mov    %r14,%rsi
    5f6d:	mov    %rsi,%rcx
    5f70:	sar    $1,%rcx
    5f73:	cmp    $0x5d,%rcx
    5f77:	jl     5faf <botlish_fn_13+0x5777>
    5f7d:	cmp    $0x62,%rcx
    5f81:	jl     5fa5 <botlish_fn_13+0x576d>
    5f87:	cmp    $0x63,%rcx
    5f8b:	jl     5f9b <botlish_fn_13+0x5763>
    5f91:	mov    $0x13,%ecx
    5f96:	jmp    618a <botlish_fn_13+0x5952>
    5f9b:	mov    $0xd,%ecx
    5fa0:	jmp    618a <botlish_fn_13+0x5952>
    5fa5:	mov    $0x13,%ecx
    5faa:	jmp    618a <botlish_fn_13+0x5952>
    5faf:	cmp    $0x5c,%rcx
    5fb3:	jl     5fc3 <botlish_fn_13+0x578b>
    5fb9:	mov    $0xd,%ecx
    5fbe:	jmp    618a <botlish_fn_13+0x5952>
    5fc3:	mov    $0x13,%ecx
    5fc8:	jmp    618a <botlish_fn_13+0x5952>
    5fcd:	mov    %r14,%rsi
    5fd0:	test   $0x1,%rsi
    5fd7:	jne    6007 <botlish_fn_13+0x57cf>
    5fdd:	mov    $0x47,%edx
    5fe2:	mov    %r14,%rsi
    5fe5:	mov    0x1e8(%rsp),%rdi
    5fed:	call   5ff2 <botlish_fn_13+0x57ba>
			5fee: R_X86_64_PLT32	rt_int_cmp-0x4
    5ff2:	mov    $0x2,%ecx
    5ff7:	test   %rax,%rax
    5ffa:	cmovl  0xb96(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    6002:	jmp    601b <botlish_fn_13+0x57e3>
    6007:	mov    $0x2,%ecx
    600c:	mov    %r14,%rsi
    600f:	cmp    $0x47,%rsi
    6013:	cmovl  0xb7d(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    601b:	cmp    $0x6,%rcx
    601f:	je     604c <botlish_fn_13+0x5814>
    6025:	mov    %r14,%rsi
    6028:	mov    %rsi,%rax
    602b:	sar    $1,%rax
    602e:	cmp    $0x2f,%rax
    6032:	jl     6042 <botlish_fn_13+0x580a>
    6038:	mov    $0xd,%ecx
    603d:	jmp    618a <botlish_fn_13+0x5952>
    6042:	mov    $0x13,%ecx
    6047:	jmp    618a <botlish_fn_13+0x5952>
    604c:	mov    %r14,%rsi
    604f:	test   $0x1,%rsi
    6056:	jne    6086 <botlish_fn_13+0x584e>
    605c:	mov    $0x45,%edx
    6061:	mov    %r14,%rsi
    6064:	mov    0x1e8(%rsp),%rdi
    606c:	call   6071 <botlish_fn_13+0x5839>
			606d: R_X86_64_PLT32	rt_int_cmp-0x4
    6071:	mov    $0x2,%edx
    6076:	test   %rax,%rax
    6079:	cmovl  0xb17(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    6081:	jmp    609a <botlish_fn_13+0x5862>
    6086:	mov    $0x2,%edx
    608b:	mov    %r14,%rsi
    608e:	cmp    $0x45,%rsi
    6092:	cmovl  0xafe(%rip),%rdx        # 6b98 <botlish_fn_13+0x6360>
    609a:	cmp    $0x6,%rdx
    609e:	je     60ae <botlish_fn_13+0x5876>
    60a4:	mov    $0xd,%ecx
    60a9:	jmp    618a <botlish_fn_13+0x5952>
    60ae:	mov    $0x13,%ecx
    60b3:	jmp    618a <botlish_fn_13+0x5952>
    60b8:	mov    %r14,%rsi
    60bb:	test   $0x1,%rsi
    60c2:	jne    60f2 <botlish_fn_13+0x58ba>
    60c8:	mov    $0xb9,%edx
    60cd:	mov    %r14,%rsi
    60d0:	mov    0x1e8(%rsp),%rdi
    60d8:	call   60dd <botlish_fn_13+0x58a5>
			60d9: R_X86_64_PLT32	rt_int_cmp-0x4
    60dd:	mov    $0x2,%ecx
    60e2:	test   %rax,%rax
    60e5:	cmovl  0xaab(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    60ed:	jmp    6109 <botlish_fn_13+0x58d1>
    60f2:	mov    $0x2,%ecx
    60f7:	mov    %r14,%rsi
    60fa:	cmp    $0xb9,%rsi
    6101:	cmovl  0xa8f(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    6109:	cmp    $0x6,%rcx
    610d:	je     6185 <botlish_fn_13+0x594d>
    6113:	mov    %r14,%rsi
    6116:	test   $0x1,%rsi
    611d:	jne    614d <botlish_fn_13+0x5915>
    6123:	mov    $0xbb,%edx
    6128:	mov    %r14,%rsi
    612b:	mov    0x1e8(%rsp),%rdi
    6133:	call   6138 <botlish_fn_13+0x5900>
			6134: R_X86_64_PLT32	rt_int_cmp-0x4
    6138:	mov    $0x2,%ecx
    613d:	test   %rax,%rax
    6140:	cmovl  0xa50(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    6148:	jmp    6164 <botlish_fn_13+0x592c>
    614d:	mov    $0x2,%ecx
    6152:	mov    %r14,%rsi
    6155:	cmp    $0xbb,%rsi
    615c:	cmovl  0xa34(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    6164:	cmp    $0x6,%rcx
    6168:	je     6178 <botlish_fn_13+0x5940>
    616e:	mov    $0x11,%ecx
    6173:	jmp    618a <botlish_fn_13+0x5952>
    6178:	mov    0x280(%rsp),%rcx
    6180:	jmp    618a <botlish_fn_13+0x5952>
    6185:	mov    $0x11,%ecx
    618a:	mov    %rcx,%rsi
    618d:	sar    $1,%rsi
    6190:	cmp    $0x6,%rsi
    6194:	jl     641f <botlish_fn_13+0x5be7>
    619a:	cmp    $0x6,%rsi
    619e:	mov    %rsi,%rbx
    61a1:	je     63f2 <botlish_fn_13+0x5bba>
    61a7:	mov    %r14,%rsi
    61aa:	test   $0x1,%rsi
    61b1:	jne    61e4 <botlish_fn_13+0x59ac>
    61b7:	mov    0x258(%rsp),%rdx
    61bf:	mov    %r14,%rsi
    61c2:	mov    0x1e8(%rsp),%rdi
    61ca:	call   61cf <botlish_fn_13+0x5997>
			61cb: R_X86_64_PLT32	rt_int_cmp-0x4
    61cf:	mov    $0x2,%esi
    61d4:	test   %rax,%rax
    61d7:	cmove  0x9b9(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    61df:	jmp    61f8 <botlish_fn_13+0x59c0>
    61e4:	mov    $0x2,%esi
    61e9:	mov    %r14,%rax
    61ec:	cmp    $0xffffffffffffffff,%rax
    61f0:	cmove  0x9a0(%rip),%rsi        # 6b98 <botlish_fn_13+0x6360>
    61f8:	cmp    $0x6,%rsi
    61fc:	je     625a <botlish_fn_13+0x5a22>
    6202:	mov    %rbx,%rsi
    6205:	mov    0x1e8(%rsp),%rdi
    620d:	call   6212 <botlish_fn_13+0x59da>
			620e: R_X86_64_PLT32	botlish_fn_5-0x4
    6212:	mov    0x1e8(%rsp),%rdi
    621a:	mov    0x10(%rdi),%r11
    621e:	mov    0x158(%r11),%rdx
    6225:	lea    0x178(%rsp),%r9
    622d:	mov    %rax,0x178(%rsp)
    6235:	mov    %r14,%rsi
    6238:	mov    %rsi,0x180(%rsp)
    6240:	mov    $0x1,%esi
    6245:	mov    $0x5,%ecx
    624a:	mov    $0x2,%r8d
    6250:	call   6255 <botlish_fn_13+0x5a1d>
			6251: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6255:	jmp    62a0 <botlish_fn_13+0x5a68>
    625a:	mov    %rbx,%rsi
    625d:	mov    0x1e8(%rsp),%rdi
    6265:	call   626a <botlish_fn_13+0x5a32>
			6266: R_X86_64_PLT32	botlish_fn_5-0x4
    626a:	mov    0x1e8(%rsp),%rdi
    6272:	mov    0x10(%rdi),%rcx
    6276:	mov    0x150(%rcx),%rdx
    627d:	lea    0x170(%rsp),%r9
    6285:	mov    %rax,0x170(%rsp)
    628d:	mov    $0x2,%ecx
    6292:	mov    $0x1,%r8d
    6298:	mov    %rcx,%rsi
    629b:	call   62a0 <botlish_fn_13+0x5a68>
			629c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    62a0:	mov    0x1e8(%rsp),%rdi
    62a8:	call   62ad <botlish_fn_13+0x5a75>
			62a9: R_X86_64_PLT32	rt_co_failed-0x4
    62ad:	mov    %rax,0x80(%rsp)
    62b5:	mov    %rax,%rsi
    62b8:	mov    0x1e8(%rsp),%rdi
    62c0:	call   62c5 <botlish_fn_13+0x5a8d>
			62c1: R_X86_64_PLT32	rt_co_resume0-0x4
    62c5:	test   %rax,%rax
    62c8:	je     62ea <botlish_fn_13+0x5ab2>
    62ce:	mov    0x1e8(%rsp),%rdi
    62d6:	mov    0x10(%rdi),%rax
    62da:	mov    0x50(%rax),%rsi
    62de:	mov    0x130(%rax),%rdx
    62e5:	call   62ea <botlish_fn_13+0x5ab2>
			62e6: R_X86_64_PLT32	rt_raise-0x4
    62ea:	mov    0x1e8(%rsp),%rdi
    62f2:	call   62f7 <botlish_fn_13+0x5abf>
			62f3: R_X86_64_PLT32	rt_declared_error-0x4
    62f7:	cmp    $0x1,%rax
    62fb:	je     6378 <botlish_fn_13+0x5b40>
    6301:	mov    0x1e8(%rsp),%rdi
    6309:	call   630e <botlish_fn_13+0x5ad6>
			630a: R_X86_64_PLT32	rt_declared_error-0x4
    630e:	cmp    $0x2,%rax
    6312:	jne    68f3 <botlish_fn_13+0x60bb>
    6318:	xor    %rsi,%rsi
    631b:	mov    0x1e8(%rsp),%rdi
    6323:	call   6328 <botlish_fn_13+0x5af0>
			6324: R_X86_64_PLT32	rt_declared_payload-0x4
    6328:	mov    %rax,%r15
    632b:	mov    0x1e8(%rsp),%rdi
    6333:	call   6338 <botlish_fn_13+0x5b00>
			6334: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6338:	mov    0x1e8(%rsp),%rdi
    6340:	mov    0x10(%rdi),%rax
    6344:	mov    0x140(%rax),%rdx
    634b:	lea    0xe0(%rsp),%r9
    6353:	mov    %r15,%rax
    6356:	mov    %rax,0xe0(%rsp)
    635e:	mov    $0x5,%esi
    6363:	mov    $0x2,%ecx
    6368:	mov    $0x1,%r8d
    636e:	call   6373 <botlish_fn_13+0x5b3b>
			636f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6373:	jmp    68f3 <botlish_fn_13+0x60bb>
    6378:	xor    %rsi,%rsi
    637b:	mov    0x1e8(%rsp),%rdi
    6383:	call   6388 <botlish_fn_13+0x5b50>
			6384: R_X86_64_PLT32	rt_declared_payload-0x4
    6388:	mov    %rax,%rbx
    638b:	mov    0x1e8(%rsp),%rdi
    6393:	call   6398 <botlish_fn_13+0x5b60>
			6394: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6398:	mov    0x270(%rsp),%rcx
    63a0:	mov    0x10(%rcx),%rax
    63a4:	mov    (%rax),%rcx
    63a7:	mov    0x1e8(%rsp),%rdi
    63af:	mov    0x10(%rdi),%rax
    63b3:	mov    0x138(%rax),%rdx
    63ba:	lea    0xd0(%rsp),%r9
    63c2:	mov    %rcx,0xd0(%rsp)
    63ca:	mov    %rbx,%rax
    63cd:	mov    %rax,0xd8(%rsp)
    63d5:	mov    $0x1,%ecx
    63da:	mov    $0x2,%r8d
    63e0:	mov    0x250(%rsp),%rsi
    63e8:	call   63ed <botlish_fn_13+0x5bb5>
			63e9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    63ed:	jmp    68f3 <botlish_fn_13+0x60bb>
    63f2:	movq   $0x3,0x88(%rsp)
    63fe:	mov    0x280(%rsp),%r15
    6406:	mov    $0x6,%ebx
    640b:	movq   $0x6,0x78(%rsp)
    6414:	mov    $0x2,%r14d
    641a:	jmp    6443 <botlish_fn_13+0x5c0b>
    641f:	mov    %rcx,0x90(%rsp)
    6427:	mov    $0x6,%ebx
    642c:	movq   $0x6,0x78(%rsp)
    6435:	mov    $0x1,%r14d
    643b:	mov    %rcx,0x238(%rsp)
    6443:	mov    0x260(%rsp),%rsi
    644b:	mov    0x18(%rsi),%rax
    644f:	test   %rax,%rax
    6452:	je     6b11 <botlish_fn_13+0x62d9>
    6458:	mov    0x260(%rsp),%rax
    6460:	mov    0x10(%rax),%rax
    6464:	mov    %rbx,(%rax)
    6467:	mov    0x260(%rsp),%rax
    646f:	mov    %r15,0x200(%rsp)
    6477:	jmp    215f <botlish_fn_13+0x1927>
    647c:	mov    0x1e8(%rsp),%rdi
    6484:	mov    0x10(%rdi),%rax
    6488:	mov    0x148(%rax),%rdx
    648f:	lea    0xc0(%rsp),%r9
    6497:	mov    0x248(%rsp),%rcx
    649f:	mov    %rcx,0xc0(%rsp)
    64a7:	mov    0x1f8(%rsp),%rax
    64af:	mov    %rax,0xc8(%rsp)
    64b7:	mov    $0x8,%esi
    64bc:	mov    $0x2,%r8d
    64c2:	mov    0x280(%rsp),%rcx
    64ca:	call   64cf <botlish_fn_13+0x5c97>
			64cb: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    64cf:	jmp    68f3 <botlish_fn_13+0x60bb>
    64d4:	movq   $0x1,0x28(%rsp)
    64dd:	mov    0x268(%rsp),%rbx
    64e5:	mov    0x10(%rbx),%rax
    64e9:	mov    (%rax),%rsi
    64ec:	mov    %rsi,0x30(%rsp)
    64f1:	movq   $0x3,0x38(%rsp)
    64fa:	test   $0x1,%rsi
    6501:	je     6519 <botlish_fn_13+0x5ce1>
    6507:	mov    %rsi,%rcx
    650a:	add    $0x2,%rcx
    650e:	seto   %al
    6511:	test   %al,%al
    6513:	je     6531 <botlish_fn_13+0x5cf9>
    6519:	mov    0x280(%rsp),%rdx
    6521:	mov    0x1e8(%rsp),%rdi
    6529:	call   652e <botlish_fn_13+0x5cf6>
			652a: R_X86_64_PLT32	rt_int_add-0x4
    652e:	mov    %rax,%rcx
    6531:	mov    0x18(%rbx),%rsi
    6535:	test   %rsi,%rsi
    6538:	je     6b33 <botlish_fn_13+0x62fb>
    653e:	mov    0x10(%rbx),%rdi
    6542:	mov    %rcx,(%rdi)
    6545:	mov    0x278(%rsp),%rcx
    654d:	mov    %rbx,0x268(%rsp)
    6555:	jmp    e2a <botlish_fn_13+0x5f2>
    655a:	mov    0x268(%rsp),%rbx
    6562:	mov    0x10(%rbx),%rax
    6566:	mov    (%rax),%rax
    6569:	mov    %rax,(%rsp)
    656d:	mov    0x270(%rsp),%rcx
    6575:	mov    0x10(%rcx),%rcx
    6579:	mov    (%rcx),%rdx
    657c:	mov    %rdx,0x8(%rsp)
    6581:	lea    0xe8(%rsp),%rcx
    6589:	mov    %rax,0xe8(%rsp)
    6591:	mov    %rdx,0xf0(%rsp)
    6599:	xor    %rsi,%rsi
    659c:	mov    $0x2,%edx
    65a1:	mov    0x1e8(%rsp),%rdi
    65a9:	call   65ae <botlish_fn_13+0x5d76>
			65aa: R_X86_64_PLT32	rt_struct_new-0x4
    65ae:	mov    0x290(%rsp),%rbx
    65b6:	mov    0x298(%rsp),%r12
    65be:	mov    0x2a0(%rsp),%r13
    65c6:	mov    0x2a8(%rsp),%r14
    65ce:	mov    0x2b0(%rsp),%r15
    65d6:	add    $0x2c0,%rsp
    65dd:	mov    %rbp,%rsp
    65e0:	pop    %rbp
    65e1:	ret
    65e2:	mov    0x268(%rsp),%rbx
    65ea:	movq   $0x1,0x28(%rsp)
    65f3:	mov    0x270(%rsp),%rcx
    65fb:	mov    0x10(%rcx),%rax
    65ff:	mov    (%rax),%rsi
    6602:	mov    %rsi,0x30(%rsp)
    6607:	movq   $0x3,0x38(%rsp)
    6610:	test   $0x1,%rsi
    6617:	je     663c <botlish_fn_13+0x5e04>
    661d:	mov    %rsi,%rcx
    6620:	add    $0x2,%rcx
    6624:	seto   %al
    6627:	test   %al,%al
    6629:	jne    663c <botlish_fn_13+0x5e04>
    662f:	mov    0x270(%rsp),%rax
    6637:	jmp    665c <botlish_fn_13+0x5e24>
    663c:	mov    0x280(%rsp),%rdx
    6644:	mov    0x1e8(%rsp),%rdi
    664c:	call   6651 <botlish_fn_13+0x5e19>
			664d: R_X86_64_PLT32	rt_int_add-0x4
    6651:	mov    %rax,%rcx
    6654:	mov    0x270(%rsp),%rax
    665c:	mov    0x270(%rsp),%rax
    6664:	mov    0x18(%rax),%rax
    6668:	test   %rax,%rax
    666b:	je     6b4d <botlish_fn_13+0x6315>
    6671:	mov    0x270(%rsp),%rax
    6679:	mov    0x10(%rax),%rax
    667d:	mov    %rcx,(%rax)
    6680:	movq   $0x1,0x28(%rsp)
    6689:	mov    0x208(%rsp),%r12
    6691:	cmp    $0x1,%r12
    6695:	je     66af <botlish_fn_13+0x5e77>
    669b:	mov    $0xa,%esi
    66a0:	cmp    $0xffffffffffffffff,%r12
    66a4:	je     6a60 <botlish_fn_13+0x6228>
    66aa:	jmp    6880 <botlish_fn_13+0x6048>
    66af:	mov    0x218(%rsp),%r14
    66b7:	add    $0x1,%r14
    66be:	mov    %r14,0x218(%rsp)
    66c6:	mov    0x220(%rsp),%r15
    66ce:	cmp    %r15,%r14
    66d1:	jl     69a5 <botlish_fn_13+0x616d>
    66d7:	movq   $0x3,0x38(%rsp)
    66e0:	mov    0x230(%rsp),%rsi
    66e8:	test   $0x1,%rsi
    66ef:	jne    6702 <botlish_fn_13+0x5eca>
    66f5:	mov    0x230(%rsp),%rsi
    66fd:	jmp    6739 <botlish_fn_13+0x5f01>
    6702:	mov    0x230(%rsp),%rsi
    670a:	mov    %rsi,%rcx
    670d:	add    $0x2,%rcx
    6711:	seto   %al
    6714:	test   %al,%al
    6716:	je     6729 <botlish_fn_13+0x5ef1>
    671c:	mov    0x230(%rsp),%rsi
    6724:	jmp    6739 <botlish_fn_13+0x5f01>
    6729:	mov    %rcx,%rsi
    672c:	mov    %rcx,0x230(%rsp)
    6734:	jmp    6759 <botlish_fn_13+0x5f21>
    6739:	mov    0x280(%rsp),%rdx
    6741:	mov    0x1e8(%rsp),%rdi
    6749:	call   674e <botlish_fn_13+0x5f16>
			674a: R_X86_64_PLT32	rt_int_add-0x4
    674e:	mov    %rax,%rsi
    6751:	mov    %rax,0x230(%rsp)
    6759:	mov    %rsi,0x68(%rsp)
    675e:	mov    0x288(%rsp),%rcx
    6766:	mov    0x230(%rsp),%rsi
    676e:	mov    %rsi,%rax
    6771:	and    %rcx,%rax
    6774:	test   $0x1,%rax
    677a:	jne    67b2 <botlish_fn_13+0x5f7a>
    6780:	mov    0x288(%rsp),%rdx
    6788:	mov    0x230(%rsp),%rsi
    6790:	mov    0x1e8(%rsp),%rdi
    6798:	call   679d <botlish_fn_13+0x5f65>
			6799: R_X86_64_PLT32	rt_int_cmp-0x4
    679d:	mov    $0x2,%ecx
    67a2:	test   %rax,%rax
    67a5:	cmovl  0x3eb(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    67ad:	jmp    67d2 <botlish_fn_13+0x5f9a>
    67b2:	mov    $0x2,%ecx
    67b7:	mov    0x230(%rsp),%rax
    67bf:	mov    0x288(%rsp),%rsi
    67c7:	cmp    %rsi,%rax
    67ca:	cmovl  0x3c6(%rip),%rcx        # 6b98 <botlish_fn_13+0x6360>
    67d2:	cmp    $0x6,%rcx
    67d6:	je     6802 <botlish_fn_13+0x5fca>
    67dc:	movq   $0xffffffffffffffff,0x48(%rsp)
    67e5:	mov    0x258(%rsp),%r12
    67ed:	mov    0x258(%rsp),%rax
    67f5:	mov    %rax,0x210(%rsp)
    67fd:	jmp    6a60 <botlish_fn_13+0x6228>
    6802:	mov    0x230(%rsp),%rsi
    680a:	test   $0x1,%rsi
    6811:	je     683a <botlish_fn_13+0x6002>
    6817:	mov    0x1f0(%rsp),%rsi
    681f:	mov    0x8(%rsi),%rcx
    6823:	mov    0x230(%rsp),%rsi
    682b:	mov    %rsi,%rax
    682e:	sar    $1,%rax
    6831:	cmp    %rcx,%rax
    6834:	jb     6937 <botlish_fn_13+0x60ff>
    683a:	mov    0x230(%rsp),%rdx
    6842:	mov    0x1f0(%rsp),%rsi
    684a:	mov    0x1e8(%rsp),%rdi
    6852:	call   6857 <botlish_fn_13+0x601f>
			6853: R_X86_64_PLT32	rt_list_get-0x4
    6857:	mov    %rax,%rcx
    685a:	mov    %rax,0x228(%rsp)
    6862:	test   %rcx,%rax
    6865:	jne    692a <botlish_fn_13+0x60f2>
    686b:	mov    0x1e8(%rsp),%rdi
    6873:	call   6878 <botlish_fn_13+0x6040>
			6874: R_X86_64_PLT32	rt_co_failed-0x4
    6878:	mov    %rax,0x50(%rsp)
    687d:	mov    %rax,%rsi
    6880:	mov    0x1e8(%rsp),%rdi
    6888:	call   688d <botlish_fn_13+0x6055>
			6889: R_X86_64_PLT32	rt_co_resume0-0x4
    688d:	test   %rax,%rax
    6890:	je     68b2 <botlish_fn_13+0x607a>
    6896:	mov    0x1e8(%rsp),%rdi
    689e:	mov    0x10(%rdi),%rax
    68a2:	mov    0x50(%rax),%rsi
    68a6:	mov    0x130(%rax),%rdx
    68ad:	call   68b2 <botlish_fn_13+0x607a>
			68ae: R_X86_64_PLT32	rt_raise-0x4
    68b2:	mov    0x1e8(%rsp),%rdi
    68ba:	call   68bf <botlish_fn_13+0x6087>
			68bb: R_X86_64_PLT32	rt_declared_error-0x4
    68bf:	cmp    $0x40000001,%rax
    68c5:	je     68d8 <botlish_fn_13+0x60a0>
    68cb:	mov    0x1e8(%rsp),%rdi
    68d3:	jmp    68e0 <botlish_fn_13+0x60a8>
    68d8:	mov    0x1e8(%rsp),%rdi
    68e0:	mov    0x1e8(%rsp),%rdi
    68e8:	call   68ed <botlish_fn_13+0x60b5>
			68e9: R_X86_64_PLT32	rt_declared_error-0x4
    68ed:	cmp    $0x40000001,%rax
    68f3:	xor    %rax,%rax
    68f6:	mov    0x290(%rsp),%rbx
    68fe:	mov    0x298(%rsp),%r12
    6906:	mov    0x2a0(%rsp),%r13
    690e:	mov    0x2a8(%rsp),%r14
    6916:	mov    0x2b0(%rsp),%r15
    691e:	add    $0x2c0,%rsp
    6925:	mov    %rbp,%rsp
    6928:	pop    %rbp
    6929:	ret
    692a:	mov    0x228(%rsp),%rax
    6932:	jmp    694f <botlish_fn_13+0x6117>
    6937:	mov    0x1f0(%rsp),%rsi
    693f:	mov    0x10(%rsi),%rcx
    6943:	mov    (%rcx,%rax,8),%rax
    6947:	mov    %rax,0x228(%rsp)
    694f:	mov    %rax,0x70(%rsp)
    6954:	mov    0x228(%rsp),%rax
    695c:	mov    0x8(%rax),%r15
    6960:	mov    %r15,0x220(%rsp)
    6968:	mov    %r14,%rax
    696b:	mov    %r14,0x218(%rsp)
    6973:	xor    %rax,%r14
    6976:	mov    %r14,0x218(%rsp)
    697e:	shl    $1,%r15
    6981:	mov    %r15,0x220(%rsp)
    6989:	or     $0x1,%r15
    698d:	mov    %r15,0x220(%rsp)
    6995:	sar    $1,%r15
    6998:	mov    %r15,0x220(%rsp)
    69a0:	jmp    66ce <botlish_fn_13+0x5e96>
    69a5:	mov    0x228(%rsp),%rax
    69ad:	movzbq 0x18(%rax),%rax
    69b2:	test   %rax,%rax
    69b5:	jne    69ef <botlish_fn_13+0x61b7>
    69bb:	mov    0x218(%rsp),%r14
    69c3:	mov    %r14,%rdx
    69c6:	shl    $1,%rdx
    69c9:	or     $0x1,%rdx
    69cd:	mov    0x228(%rsp),%rsi
    69d5:	mov    0x1e8(%rsp),%rdi
    69dd:	call   69e2 <botlish_fn_13+0x61aa>
			69de: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    69e2:	mov    %rax,0x210(%rsp)
    69ea:	jmp    6a32 <botlish_fn_13+0x61fa>
    69ef:	mov    0x218(%rsp),%r14
    69f7:	mov    %r14,%rcx
    69fa:	shl    $1,%rcx
    69fd:	or     $0x1,%rcx
    6a01:	sar    $1,%rcx
    6a04:	mov    0x228(%rsp),%rax
    6a0c:	movzbq 0x19(%rax,%rcx,1),%rax
    6a12:	mov    %rax,0x210(%rsp)
    6a1a:	shl    $0x3,%rax
    6a1e:	mov    %rax,0x210(%rsp)
    6a26:	or     $0x4,%rax
    6a2a:	mov    %rax,0x210(%rsp)
    6a32:	shr    $0x3,%rax
    6a36:	mov    %rax,0x210(%rsp)
    6a3e:	mov    $0x1,%r12d
    6a44:	shl    $1,%rax
    6a47:	mov    %rax,0x210(%rsp)
    6a4f:	or     $0x1,%rax
    6a53:	mov    %rax,0x210(%rsp)
    6a5b:	mov    %rax,0x48(%rsp)
    6a60:	mov    0x278(%rsp),%rcx
    6a68:	mov    0x18(%rcx),%rax
    6a6c:	test   %rax,%rax
    6a6f:	je     6b6c <botlish_fn_13+0x6334>
    6a75:	mov    0x278(%rsp),%rcx
    6a7d:	mov    0x10(%rcx),%rax
    6a81:	mov    0x210(%rsp),%rcx
    6a89:	mov    %rcx,(%rax)
    6a8c:	mov    0x278(%rsp),%rcx
    6a94:	mov    %r12,0x208(%rsp)
    6a9c:	mov    %rbx,0x268(%rsp)
    6aa4:	jmp    e2a <botlish_fn_13+0x5f2>
    6aa9:	mov    $0x1,%edx
    6aae:	mov    %rbx,%rcx
    6ab1:	mov    0x260(%rsp),%rsi
    6ab9:	mov    0x1e8(%rsp),%rdi
    6ac1:	call   6ac6 <botlish_fn_13+0x628e>
			6ac2: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6ac6:	jmp    2157 <botlish_fn_13+0x191f>
    6acb:	mov    $0x1,%edx
    6ad0:	mov    0x270(%rsp),%rsi
    6ad8:	mov    0x1e8(%rsp),%rdi
    6ae0:	call   6ae5 <botlish_fn_13+0x62ad>
			6ae1: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6ae5:	jmp    220e <botlish_fn_13+0x19d6>
    6aea:	mov    $0x1,%edx
    6aef:	mov    0x210(%rsp),%rcx
    6af7:	mov    0x278(%rsp),%rsi
    6aff:	mov    0x1e8(%rsp),%rdi
    6b07:	call   6b0c <botlish_fn_13+0x62d4>
			6b08: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6b0c:	jmp    2600 <botlish_fn_13+0x1dc8>
    6b11:	mov    $0x1,%edx
    6b16:	mov    %rbx,%rcx
    6b19:	mov    0x260(%rsp),%rsi
    6b21:	mov    0x1e8(%rsp),%rdi
    6b29:	call   6b2e <botlish_fn_13+0x62f6>
			6b2a: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6b2e:	jmp    6467 <botlish_fn_13+0x5c2f>
    6b33:	mov    $0x1,%edx
    6b38:	mov    %rbx,%rsi
    6b3b:	mov    0x1e8(%rsp),%rdi
    6b43:	call   6b48 <botlish_fn_13+0x6310>
			6b44: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6b48:	jmp    6545 <botlish_fn_13+0x5d0d>
    6b4d:	mov    $0x1,%edx
    6b52:	mov    0x270(%rsp),%rsi
    6b5a:	mov    0x1e8(%rsp),%rdi
    6b62:	call   6b67 <botlish_fn_13+0x632f>
			6b63: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6b67:	jmp    6680 <botlish_fn_13+0x5e48>
    6b6c:	mov    $0x1,%edx
    6b71:	mov    0x210(%rsp),%rcx
    6b79:	mov    0x278(%rsp),%rsi
    6b81:	mov    0x1e8(%rsp),%rdi
    6b89:	call   6b8e <botlish_fn_13+0x6356>
			6b8a: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6b8e:	jmp    6a8c <botlish_fn_13+0x6254>
    6b93:	add    %al,(%rax)
    6b95:	add    %al,(%rax)
    6b97:	add    %al,(%rsi)
    6b99:	add    %al,(%rax)
    6b9b:	add    %al,(%rax)
    6b9d:	add    %al,(%rax)
	...

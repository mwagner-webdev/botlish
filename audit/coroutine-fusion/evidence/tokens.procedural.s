<botlish_fn_6>:
 8c0:	push   %rbp
 8c1:	mov    %rsp,%rbp
 8c4:	sub    $0xb0,%rsp
 8cb:	mov    %rbx,0x80(%rsp)
 8d3:	mov    %r12,0x88(%rsp)
 8db:	mov    %r13,0x90(%rsp)
 8e3:	mov    %r14,0x98(%rsp)
 8eb:	mov    %r15,0xa0(%rsp)
 8f3:	mov    %rdi,%r15
 8f6:	movq   $0x0,0x20(%rsp)
 8ff:	movq   $0x0,0x28(%rsp)
 908:	movq   $0x0,0x30(%rsp)
 911:	movq   $0x0,0x38(%rsp)
 91a:	movq   $0x0,0x40(%rsp)
 923:	mov    %rsi,(%rsp)
 927:	mov    0x8(%rsi),%r12
 92b:	mov    %rsi,0x68(%rsp)
 930:	mov    $0x1,%edx
 935:	shl    $1,%r12
 938:	mov    %r12,%r9
 93b:	or     $0x1,%r9
 93f:	mov    %r9,0x8(%rsp)
 944:	mov    $0x3,%esi
 949:	movq   $0x3,0x10(%rsp)
 952:	movq   $0x1,0x18(%rsp)
 95b:	mov    %r15,%rdi
 95e:	call   963 <botlish_fn_6+0xa3>
			95f: R_X86_64_PLT32	rt_mutarray_create-0x4
 963:	test   %rax,%rax
 966:	je     ec5 <botlish_fn_6+0x605>
 96c:	mov    %rax,0x10(%rsp)
 971:	mov    %rax,%r13
 974:	mov    $0x9,%esi
 979:	movq   $0x9,0x18(%rsp)
 982:	mov    $0x1,%edx
 987:	movq   $0x1,0x20(%rsp)
 990:	mov    %r15,%rdi
 993:	call   998 <botlish_fn_6+0xd8>
			994: R_X86_64_PLT32	rt_mutarray_create-0x4
 998:	test   %rax,%rax
 99b:	je     ec5 <botlish_fn_6+0x605>
 9a1:	mov    %rax,0x18(%rsp)
 9a6:	mov    %rax,%r14
 9a9:	mov    %r13,%rbx
 9ac:	mov    0x10(%rbx),%rax
 9b0:	mov    (%rax),%rsi
 9b3:	mov    %rsi,0x20(%rsp)
 9b8:	mov    %rsi,0x70(%rsp)
 9bd:	mov    %r12,%rdx
 9c0:	or     $0x1,%rdx
 9c4:	mov    0x70(%rsp),%rcx
 9c9:	mov    0x68(%rsp),%rsi
 9ce:	mov    %r15,%rdi
 9d1:	call   9d6 <botlish_fn_6+0x116>
			9d2: R_X86_64_PLT32	botlish_fn_2-0x4
 9d6:	test   %rdx,%rdx
 9d9:	je     ec5 <botlish_fn_6+0x605>
 9df:	cmp    $0xffffffffffffffff,%rax
 9e3:	je     e5e <botlish_fn_6+0x59e>
 9e9:	cmp    $0x2d,%rax
 9ed:	mov    %rax,%r13
 9f0:	jne    9fe <botlish_fn_6+0x13e>
 9f6:	mov    %r14,%r13
 9f9:	jmp    cf6 <botlish_fn_6+0x436>
 9fe:	mov    %r13,%rsi
 a01:	mov    %r15,%rdi
 a04:	call   a09 <botlish_fn_6+0x149>
			a05: R_X86_64_PLT32	botlish_fn_1-0x4
 a09:	cmp    $0x6,%rax
 a0d:	jne    a1b <botlish_fn_6+0x15b>
 a13:	mov    %r14,%r13
 a16:	jmp    cf6 <botlish_fn_6+0x436>
 a1b:	mov    %r13,%rax
 a1e:	cmp    $0x22,%rax
 a22:	je     b40 <botlish_fn_6+0x280>
 a28:	cmp    $0x7b,%rax
 a2c:	je     a6c <botlish_fn_6+0x1ac>
 a32:	cmp    $0x7d,%rax
 a36:	je     a6c <botlish_fn_6+0x1ac>
 a3c:	cmp    $0x5b,%rax
 a40:	je     a6c <botlish_fn_6+0x1ac>
 a46:	cmp    $0x5d,%rax
 a4a:	je     a6c <botlish_fn_6+0x1ac>
 a50:	cmp    $0x3a,%rax
 a54:	je     a6c <botlish_fn_6+0x1ac>
 a5a:	cmp    $0x2c,%rax
 a5e:	je     a6c <botlish_fn_6+0x1ac>
 a64:	mov    %r14,%r13
 a67:	jmp    ad2 <botlish_fn_6+0x212>
 a6c:	movq   $0x5,0x28(%rsp)
 a75:	mov    %r14,%r13
 a78:	mov    0x10(%r13),%rax
 a7c:	mov    0x10(%rax),%rsi
 a80:	mov    %rsi,0x30(%rsp)
 a85:	movq   $0x3,0x38(%rsp)
 a8e:	test   $0x1,%rsi
 a95:	je     aad <botlish_fn_6+0x1ed>
 a9b:	mov    %rsi,%rcx
 a9e:	add    $0x2,%rcx
 aa2:	seto   %al
 aa5:	test   %al,%al
 aa7:	je     abd <botlish_fn_6+0x1fd>
 aad:	mov    $0x3,%edx
 ab2:	mov    %r15,%rdi
 ab5:	call   aba <botlish_fn_6+0x1fa>
			ab6: R_X86_64_PLT32	rt_int_add-0x4
 aba:	mov    %rax,%rcx
 abd:	mov    0x18(%r13),%rsi
 ac1:	test   %rsi,%rsi
 ac4:	je     f30 <botlish_fn_6+0x670>
 aca:	mov    0x10(%r13),%rdi
 ace:	mov    %rcx,0x10(%rdi)
 ad2:	movq   $0x1,0x28(%rsp)
 adb:	movq   $0x3,0x30(%rsp)
 ae4:	mov    0x70(%rsp),%rsi
 ae9:	test   $0x1,%rsi
 af0:	je     b0d <botlish_fn_6+0x24d>
 af6:	mov    0x70(%rsp),%rsi
 afb:	mov    %rsi,%rcx
 afe:	add    $0x2,%rcx
 b02:	seto   %al
 b05:	test   %al,%al
 b07:	je     b22 <botlish_fn_6+0x262>
 b0d:	mov    $0x3,%edx
 b12:	mov    0x70(%rsp),%rsi
 b17:	mov    %r15,%rdi
 b1a:	call   b1f <botlish_fn_6+0x25f>
			b1b: R_X86_64_PLT32	rt_int_add-0x4
 b1f:	mov    %rax,%rcx
 b22:	mov    0x18(%rbx),%rax
 b26:	test   %rax,%rax
 b29:	je     f45 <botlish_fn_6+0x685>
 b2f:	mov    0x10(%rbx),%rax
 b33:	mov    %rcx,(%rax)
 b36:	mov    $0xa,%esi
 b3b:	jmp    e56 <botlish_fn_6+0x596>
 b40:	mov    %r14,%r13
 b43:	movq   $0x3,0x28(%rsp)
 b4c:	mov    0x70(%rsp),%rsi
 b51:	test   $0x1,%rsi
 b58:	je     b75 <botlish_fn_6+0x2b5>
 b5e:	mov    0x70(%rsp),%rsi
 b63:	mov    %rsi,%rcx
 b66:	add    $0x2,%rcx
 b6a:	seto   %al
 b6d:	test   %al,%al
 b6f:	je     b8a <botlish_fn_6+0x2ca>
 b75:	mov    $0x3,%edx
 b7a:	mov    0x70(%rsp),%rsi
 b7f:	mov    %r15,%rdi
 b82:	call   b87 <botlish_fn_6+0x2c7>
			b83: R_X86_64_PLT32	rt_int_add-0x4
 b87:	mov    %rax,%rcx
 b8a:	mov    %rcx,0x28(%rsp)
 b8f:	mov    %r12,%rdx
 b92:	or     $0x1,%rdx
 b96:	mov    0x68(%rsp),%rsi
 b9b:	mov    %r15,%rdi
 b9e:	call   ba3 <botlish_fn_6+0x2e3>
			b9f: R_X86_64_PLT32	botlish_fn_5-0x4
 ba3:	test   %rax,%rax
 ba6:	je     ec5 <botlish_fn_6+0x605>
 bac:	mov    %rax,0x28(%rsp)
 bb1:	mov    %rax,%r14
 bb4:	movq   $0x3,0x30(%rsp)
 bbd:	mov    0x10(%r13),%rax
 bc1:	mov    0x8(%rax),%rsi
 bc5:	mov    %rsi,0x38(%rsp)
 bca:	movq   $0x3,0x40(%rsp)
 bd3:	test   $0x1,%rsi
 bda:	je     bf2 <botlish_fn_6+0x332>
 be0:	mov    %rsi,%rcx
 be3:	add    $0x2,%rcx
 be7:	seto   %al
 bea:	test   %al,%al
 bec:	je     c02 <botlish_fn_6+0x342>
 bf2:	mov    $0x3,%edx
 bf7:	mov    %r15,%rdi
 bfa:	call   bff <botlish_fn_6+0x33f>
			bfb: R_X86_64_PLT32	rt_int_add-0x4
 bff:	mov    %rax,%rcx
 c02:	mov    0x18(%r13),%rax
 c06:	test   %rax,%rax
 c09:	je     f5a <botlish_fn_6+0x69a>
 c0f:	mov    0x10(%r13),%rax
 c13:	mov    %rcx,0x8(%rax)
 c17:	movq   $0x7,0x30(%rsp)
 c20:	mov    0x10(%r13),%rax
 c24:	mov    0x18(%rax),%rsi
 c28:	mov    %rsi,0x38(%rsp)
 c2d:	mov    %rsi,%rax
 c30:	and    %r14,%rax
 c33:	test   $0x1,%rax
 c39:	je     c5f <botlish_fn_6+0x39f>
 c3f:	lea    -0x1(%r14),%rcx
 c43:	mov    %rsi,%rax
 c46:	add    %rcx,%rax
 c49:	mov    %rax,%rcx
 c4c:	seto   %al
 c4f:	test   %al,%al
 c51:	jne    c5f <botlish_fn_6+0x39f>
 c57:	mov    %rcx,%rsi
 c5a:	jmp    c6d <botlish_fn_6+0x3ad>
 c5f:	mov    %r14,%rdx
 c62:	mov    %r15,%rdi
 c65:	call   c6a <botlish_fn_6+0x3aa>
			c66: R_X86_64_PLT32	rt_int_add-0x4
 c6a:	mov    %rax,%rsi
 c6d:	mov    %rsi,0x38(%rsp)
 c72:	mov    0x70(%rsp),%rax
 c77:	mov    %rsi,%rdi
 c7a:	and    %rax,%rdi
 c7d:	test   $0x1,%rdi
 c84:	jne    c94 <botlish_fn_6+0x3d4>
 c8a:	mov    0x70(%rsp),%rdx
 c8f:	jmp    cb5 <botlish_fn_6+0x3f5>
 c94:	mov    0x70(%rsp),%rax
 c99:	mov    %rsi,%rdi
 c9c:	sub    %rax,%rdi
 c9f:	seto   %r8b
 ca3:	lea    0x1(%rdi),%rcx
 ca7:	test   %r8b,%r8b
 caa:	je     cc0 <botlish_fn_6+0x400>
 cb0:	mov    0x70(%rsp),%rdx
 cb5:	mov    %r15,%rdi
 cb8:	call   cbd <botlish_fn_6+0x3fd>
			cb9: R_X86_64_PLT32	rt_int_sub-0x4
 cbd:	mov    %rax,%rcx
 cc0:	mov    0x18(%r13),%rax
 cc4:	test   %rax,%rax
 cc7:	je     f6f <botlish_fn_6+0x6af>
 ccd:	mov    0x10(%r13),%rax
 cd1:	mov    %rcx,0x18(%rax)
 cd5:	mov    0x18(%rbx),%rax
 cd9:	test   %rax,%rax
 cdc:	je     f84 <botlish_fn_6+0x6c4>
 ce2:	mov    %r14,%rcx
 ce5:	mov    0x10(%rbx),%rax
 ce9:	mov    %rcx,(%rax)
 cec:	mov    $0xa,%esi
 cf1:	jmp    e56 <botlish_fn_6+0x596>
 cf6:	mov    %r12,%rdx
 cf9:	or     $0x1,%rdx
 cfd:	mov    0x70(%rsp),%rcx
 d02:	mov    0x68(%rsp),%rsi
 d07:	mov    %r15,%rdi
 d0a:	call   d0f <botlish_fn_6+0x44f>
			d0b: R_X86_64_PLT32	botlish_fn_4-0x4
 d0f:	test   %rax,%rax
 d12:	je     ec5 <botlish_fn_6+0x605>
 d18:	mov    %rax,0x28(%rsp)
 d1d:	mov    %rax,%r14
 d20:	movq   $0x1,0x30(%rsp)
 d29:	mov    0x10(%r13),%rax
 d2d:	mov    (%rax),%rsi
 d30:	mov    %rsi,0x38(%rsp)
 d35:	movq   $0x3,0x40(%rsp)
 d3e:	test   $0x1,%rsi
 d45:	je     d5d <botlish_fn_6+0x49d>
 d4b:	mov    %rsi,%rcx
 d4e:	add    $0x2,%rcx
 d52:	seto   %al
 d55:	test   %al,%al
 d57:	je     d6d <botlish_fn_6+0x4ad>
 d5d:	mov    $0x3,%edx
 d62:	mov    %r15,%rdi
 d65:	call   d6a <botlish_fn_6+0x4aa>
			d66: R_X86_64_PLT32	rt_int_add-0x4
 d6a:	mov    %rax,%rcx
 d6d:	mov    0x18(%r13),%rax
 d71:	test   %rax,%rax
 d74:	je     f9c <botlish_fn_6+0x6dc>
 d7a:	mov    0x10(%r13),%rax
 d7e:	mov    %rcx,(%rax)
 d81:	movq   $0x7,0x30(%rsp)
 d8a:	mov    0x10(%r13),%rax
 d8e:	mov    0x18(%rax),%rsi
 d92:	mov    %rsi,0x38(%rsp)
 d97:	mov    %rsi,%rax
 d9a:	and    %r14,%rax
 d9d:	test   $0x1,%rax
 da3:	je     dc9 <botlish_fn_6+0x509>
 da9:	lea    -0x1(%r14),%rcx
 dad:	mov    %rsi,%rax
 db0:	add    %rcx,%rax
 db3:	mov    %rax,%rcx
 db6:	seto   %al
 db9:	test   %al,%al
 dbb:	jne    dc9 <botlish_fn_6+0x509>
 dc1:	mov    %rcx,%rsi
 dc4:	jmp    dd7 <botlish_fn_6+0x517>
 dc9:	mov    %r14,%rdx
 dcc:	mov    %r15,%rdi
 dcf:	call   dd4 <botlish_fn_6+0x514>
			dd0: R_X86_64_PLT32	rt_int_add-0x4
 dd4:	mov    %rax,%rsi
 dd7:	mov    %rsi,0x38(%rsp)
 ddc:	mov    0x70(%rsp),%rdx
 de1:	mov    %rsi,%rax
 de4:	and    %rdx,%rax
 de7:	test   $0x1,%rax
 ded:	jne    dfd <botlish_fn_6+0x53d>
 df3:	mov    0x70(%rsp),%rdx
 df8:	jmp    e1f <botlish_fn_6+0x55f>
 dfd:	mov    0x70(%rsp),%rdx
 e02:	mov    %rsi,%rcx
 e05:	sub    %rdx,%rcx
 e08:	seto   %al
 e0b:	add    $0x1,%rcx
 e12:	test   %al,%al
 e14:	je     e2a <botlish_fn_6+0x56a>
 e1a:	mov    0x70(%rsp),%rdx
 e1f:	mov    %r15,%rdi
 e22:	call   e27 <botlish_fn_6+0x567>
			e23: R_X86_64_PLT32	rt_int_sub-0x4
 e27:	mov    %rax,%rcx
 e2a:	mov    0x18(%r13),%rax
 e2e:	test   %rax,%rax
 e31:	je     fb1 <botlish_fn_6+0x6f1>
 e37:	mov    0x10(%r13),%rsi
 e3b:	mov    %rcx,0x18(%rsi)
 e3f:	mov    0x18(%rbx),%rsi
 e43:	test   %rsi,%rsi
 e46:	je     fc6 <botlish_fn_6+0x706>
 e4c:	mov    %r14,%rcx
 e4f:	mov    0x10(%rbx),%r8
 e53:	mov    %rcx,(%r8)
 e56:	mov    %r13,%r14
 e59:	jmp    9ac <botlish_fn_6+0xec>
 e5e:	mov    %r14,%r13
 e61:	mov    0x10(%r13),%rax
 e65:	mov    (%rax),%rax
 e68:	mov    %rax,(%rsp)
 e6c:	mov    0x10(%r13),%rcx
 e70:	mov    0x8(%rcx),%rcx
 e74:	mov    %rcx,0x8(%rsp)
 e79:	mov    0x10(%r13),%rdx
 e7d:	mov    0x10(%rdx),%rdx
 e81:	mov    %rdx,0x10(%rsp)
 e86:	mov    0x10(%r13),%rsi
 e8a:	mov    0x18(%rsi),%rsi
 e8e:	mov    %rsi,0x18(%rsp)
 e93:	lea    0x48(%rsp),%rdi
 e98:	mov    %rax,0x48(%rsp)
 e9d:	mov    %rcx,0x50(%rsp)
 ea2:	mov    %rdx,0x58(%rsp)
 ea7:	mov    %rsi,0x60(%rsp)
 eac:	mov    $0x4,%esi
 eb1:	mov    %rdi,%rdx
 eb4:	mov    %r15,%rdi
 eb7:	call   ebc <botlish_fn_6+0x5fc>
			eb8: R_X86_64_PLT32	rt_list_new-0x4
 ebc:	test   %rax,%rax
 ebf:	jne    efc <botlish_fn_6+0x63c>
 ec5:	xor    %rax,%rax
 ec8:	mov    0x80(%rsp),%rbx
 ed0:	mov    0x88(%rsp),%r12
 ed8:	mov    0x90(%rsp),%r13
 ee0:	mov    0x98(%rsp),%r14
 ee8:	mov    0xa0(%rsp),%r15
 ef0:	add    $0xb0,%rsp
 ef7:	mov    %rbp,%rsp
 efa:	pop    %rbp
 efb:	ret
 efc:	mov    0x80(%rsp),%rbx
 f04:	mov    0x88(%rsp),%r12
 f0c:	mov    0x90(%rsp),%r13
 f14:	mov    0x98(%rsp),%r14
 f1c:	mov    0xa0(%rsp),%r15
 f24:	add    $0xb0,%rsp
 f2b:	mov    %rbp,%rsp
 f2e:	pop    %rbp
 f2f:	ret
 f30:	mov    $0x5,%edx
 f35:	mov    %r13,%rsi
 f38:	mov    %r15,%rdi
 f3b:	call   f40 <botlish_fn_6+0x680>
			f3c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 f40:	jmp    ad2 <botlish_fn_6+0x212>
 f45:	mov    $0x1,%edx
 f4a:	mov    %rbx,%rsi
 f4d:	mov    %r15,%rdi
 f50:	call   f55 <botlish_fn_6+0x695>
			f51: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 f55:	jmp    b36 <botlish_fn_6+0x276>
 f5a:	mov    $0x3,%edx
 f5f:	mov    %r13,%rsi
 f62:	mov    %r15,%rdi
 f65:	call   f6a <botlish_fn_6+0x6aa>
			f66: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 f6a:	jmp    c17 <botlish_fn_6+0x357>
 f6f:	mov    $0x7,%edx
 f74:	mov    %r13,%rsi
 f77:	mov    %r15,%rdi
 f7a:	call   f7f <botlish_fn_6+0x6bf>
			f7b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 f7f:	jmp    cd5 <botlish_fn_6+0x415>
 f84:	mov    $0x1,%edx
 f89:	mov    %r14,%rcx
 f8c:	mov    %rbx,%rsi
 f8f:	mov    %r15,%rdi
 f92:	call   f97 <botlish_fn_6+0x6d7>
			f93: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 f97:	jmp    cec <botlish_fn_6+0x42c>
 f9c:	mov    $0x1,%edx
 fa1:	mov    %r13,%rsi
 fa4:	mov    %r15,%rdi
 fa7:	call   fac <botlish_fn_6+0x6ec>
			fa8: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 fac:	jmp    d81 <botlish_fn_6+0x4c1>
 fb1:	mov    $0x7,%edx
 fb6:	mov    %r13,%rsi
 fb9:	mov    %r15,%rdi
 fbc:	call   fc1 <botlish_fn_6+0x701>
			fbd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 fc1:	jmp    e3f <botlish_fn_6+0x57f>
 fc6:	mov    $0x1,%edx
 fcb:	mov    %r14,%rcx
 fce:	mov    %rbx,%rsi
 fd1:	mov    %r15,%rdi
 fd4:	call   fd9 <botlish_fn_6+0x719>
			fd5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 fd9:	jmp    e56 <botlish_fn_6+0x596>

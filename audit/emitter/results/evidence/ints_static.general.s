<botlish_fn_7>:
    1960:	push   %rbp
    1961:	mov    %rsp,%rbp
    1964:	sub    $0x90,%rsp
    196b:	mov    %rbx,0x60(%rsp)
    1970:	mov    %r12,0x68(%rsp)
    1975:	mov    %r13,0x70(%rsp)
    197a:	mov    %r14,0x78(%rsp)
    197f:	mov    %r15,0x80(%rsp)
    1987:	mov    %rsi,%r12
    198a:	mov    %rdi,%r15
    198d:	movq   $0x0,0x10(%rsp)
    1996:	movq   $0x0,0x18(%rsp)
    199f:	movq   $0x0,0x20(%rsp)
    19a8:	movq   $0x0,0x28(%rsp)
    19b1:	mov    $0x7,%esi
    19b6:	movq   $0x7,(%rsp)
    19be:	mov    $0x1,%edx
    19c3:	movq   $0x1,0x8(%rsp)
    19cc:	mov    %r15,%rdi
    19cf:	call   19d4 <botlish_fn_7+0x74>
			19d0: R_X86_64_PLT32	rt_mutarray_create-0x4
    19d4:	test   %rax,%rax
    19d7:	je     1db9 <botlish_fn_7+0x459>
    19dd:	mov    %rax,(%rsp)
    19e1:	xor    %rbx,%rbx
    19e4:	mov    %r12,%r13
    19e7:	cmp    %r13,%rbx
    19ea:	jl     1a5a <botlish_fn_7+0xfa>
    19f0:	mov    %rax,%r12
    19f3:	mov    0x10(%r12),%rax
    19f8:	mov    0x8(%rax),%rax
    19fc:	mov    %rax,0x8(%rsp)
    1a01:	mov    0x10(%r12),%rcx
    1a06:	mov    (%rcx),%rcx
    1a09:	mov    %rcx,(%rsp)
    1a0d:	lea    0x38(%rsp),%rdx
    1a12:	mov    %rax,0x38(%rsp)
    1a17:	mov    %rcx,0x40(%rsp)
    1a1c:	mov    $0x2,%esi
    1a21:	mov    %r15,%rdi
    1a24:	call   1a29 <botlish_fn_7+0xc9>
			1a25: R_X86_64_PLT32	rt_list_new-0x4
    1a29:	test   %rax,%rax
    1a2c:	je     1db9 <botlish_fn_7+0x459>
    1a32:	mov    0x60(%rsp),%rbx
    1a37:	mov    0x68(%rsp),%r12
    1a3c:	mov    0x70(%rsp),%r13
    1a41:	mov    0x78(%rsp),%r14
    1a46:	mov    0x80(%rsp),%r15
    1a4e:	add    $0x90,%rsp
    1a55:	mov    %rbp,%rsp
    1a58:	pop    %rbp
    1a59:	ret
    1a5a:	mov    %rax,%r12
    1a5d:	mov    %rbx,%rsi
    1a60:	shl    $1,%rsi
    1a63:	or     $0x1,%rsi
    1a67:	mov    %rsi,0x8(%rsp)
    1a6c:	mov    %r15,%rdi
    1a6f:	call   1a74 <botlish_fn_7+0x114>
			1a70: R_X86_64_PLT32	botlish_fn_6-0x4
    1a74:	test   %rax,%rax
    1a77:	je     1db9 <botlish_fn_7+0x459>
    1a7d:	mov    %rax,0x8(%rsp)
    1a82:	lea    0x30(%rsp),%r8
    1a87:	mov    %rax,0x30(%rsp)
    1a8c:	mov    $0x8,%esi
    1a91:	mov    0x0(%rip),%rdx        # 1a98 <botlish_fn_7+0x138>
			1a94: R_X86_64_GOTPCREL	botlish_entry_8-0x4
    1a98:	mov    $0x1,%ecx
    1a9d:	mov    %r15,%rdi
    1aa0:	call   1aa5 <botlish_fn_7+0x145>
			1aa1: R_X86_64_PLT32	rt_closure_new-0x4
    1aa5:	mov    %rax,0x8(%rsp)
    1aaa:	mov    %rax,%rsi
    1aad:	mov    %r15,%rdi
    1ab0:	call   1ab5 <botlish_fn_7+0x155>
			1ab1: R_X86_64_PLT32	rt_co_create-0x4
    1ab5:	mov    %rax,0x50(%rsp)
    1aba:	mov    %rax,0x8(%rsp)
    1abf:	mov    0x50(%rsp),%rsi
    1ac4:	mov    %r15,%rdi
    1ac7:	call   1acc <botlish_fn_7+0x16c>
			1ac8: R_X86_64_PLT32	rt_co_start-0x4
    1acc:	test   %rax,%rax
    1acf:	mov    %rax,%rcx
    1ad2:	jne    1afe <botlish_fn_7+0x19e>
    1ad8:	mov    %r15,%rdi
    1adb:	call   1ae0 <botlish_fn_7+0x180>
			1adc: R_X86_64_PLT32	rt_declared_error-0x4
    1ae0:	cmp    $0x40000001,%rax
    1ae6:	jne    1db9 <botlish_fn_7+0x459>
    1aec:	mov    0x50(%rsp),%rsi
    1af1:	mov    %r15,%rdi
    1af4:	call   1af9 <botlish_fn_7+0x199>
			1af5: R_X86_64_PLT32	rt_co_release-0x4
    1af9:	jmp    1db9 <botlish_fn_7+0x459>
    1afe:	mov    0x18(%r12),%rax
    1b03:	test   %rax,%rax
    1b06:	je     1e1c <botlish_fn_7+0x4bc>
    1b0c:	mov    0x10(%r12),%rax
    1b11:	mov    %rcx,0x10(%rax)
    1b15:	mov    $0x7fffffff,%eax
    1b1a:	mov    %rax,%r14
    1b1d:	neg    %r14
    1b20:	cmovs  %rax,%r14
    1b24:	mov    0x50(%rsp),%rsi
    1b29:	mov    %r15,%rdi
    1b2c:	call   1b31 <botlish_fn_7+0x1d1>
			1b2d: R_X86_64_PLT32	rt_co_done-0x4
    1b31:	cmp    $0x6,%rax
    1b35:	je     1e00 <botlish_fn_7+0x4a0>
    1b3b:	movq   $0x1,0x10(%rsp)
    1b44:	mov    0x10(%r12),%rax
    1b49:	mov    (%rax),%rsi
    1b4c:	mov    %rsi,0x18(%rsp)
    1b51:	mov    0x10(%r12),%rax
    1b56:	mov    0x10(%rax),%rdx
    1b5a:	mov    %rdx,0x20(%rsp)
    1b5f:	mov    %rdx,0x48(%rsp)
    1b64:	movq   $0x3f,0x28(%rsp)
    1b6d:	test   $0x1,%rsi
    1b74:	je     1b9e <botlish_fn_7+0x23e>
    1b7a:	mov    %rsi,%rax
    1b7d:	sar    $1,%rax
    1b80:	imulq  0x2e9(%rip)        # 1e70 <botlish_fn_7+0x510>
    1b87:	seto   %cl
    1b8a:	or     $0x1,%rax
    1b8e:	test   %cl,%cl
    1b90:	jne    1b9e <botlish_fn_7+0x23e>
    1b96:	mov    %rax,%rsi
    1b99:	jmp    1bae <botlish_fn_7+0x24e>
    1b9e:	mov    $0x3f,%edx
    1ba3:	mov    %r15,%rdi
    1ba6:	call   1bab <botlish_fn_7+0x24b>
			1ba7: R_X86_64_PLT32	rt_int_mul-0x4
    1bab:	mov    %rax,%rsi
    1bae:	mov    %rsi,0x18(%rsp)
    1bb3:	mov    0x48(%rsp),%rdx
    1bb8:	mov    %rsi,%rax
    1bbb:	and    %rdx,%rax
    1bbe:	test   $0x1,%rax
    1bc4:	je     1bdf <botlish_fn_7+0x27f>
    1bca:	lea    -0x1(%rdx),%rcx
    1bce:	mov    %rsi,%rax
    1bd1:	add    %rcx,%rax
    1bd4:	seto   %cl
    1bd7:	test   %cl,%cl
    1bd9:	je     1be7 <botlish_fn_7+0x287>
    1bdf:	mov    %r15,%rdi
    1be2:	call   1be7 <botlish_fn_7+0x287>
			1be3: R_X86_64_PLT32	rt_int_add-0x4
    1be7:	mov    %rax,0x18(%rsp)
    1bec:	movq   $0x3,0x20(%rsp)
    1bf5:	test   $0x1,%rax
    1bfb:	jne    1c09 <botlish_fn_7+0x2a9>
    1c01:	mov    %rax,%rcx
    1c04:	jmp    1c1e <botlish_fn_7+0x2be>
    1c09:	mov    %rax,%rsi
    1c0c:	add    $0x2,%rsi
    1c10:	mov    %rax,%rcx
    1c13:	seto   %al
    1c16:	test   %al,%al
    1c18:	je     1c31 <botlish_fn_7+0x2d1>
    1c1e:	mov    $0x3,%edx
    1c23:	mov    %rcx,%rsi
    1c26:	mov    %r15,%rdi
    1c29:	call   1c2e <botlish_fn_7+0x2ce>
			1c2a: R_X86_64_PLT32	rt_int_add-0x4
    1c2e:	mov    %rax,%rsi
    1c31:	mov    %rsi,0x18(%rsp)
    1c36:	mov    $0xffffffff,%eax
    1c3b:	mov    %rax,0x20(%rsp)
    1c40:	test   $0x1,%rsi
    1c47:	jne    1c91 <botlish_fn_7+0x331>
    1c4d:	mov    $0xffffffff,%edx
    1c52:	mov    %r15,%rdi
    1c55:	call   1c5a <botlish_fn_7+0x2fa>
			1c56: R_X86_64_PLT32	rt_int_mod-0x4
    1c5a:	test   %rax,%rax
    1c5d:	jne    1c89 <botlish_fn_7+0x329>
    1c63:	mov    %r15,%rdi
    1c66:	call   1c6b <botlish_fn_7+0x30b>
			1c67: R_X86_64_PLT32	rt_declared_error-0x4
    1c6b:	cmp    $0x40000001,%rax
    1c71:	jne    1db9 <botlish_fn_7+0x459>
    1c77:	mov    0x50(%rsp),%rsi
    1c7c:	mov    %r15,%rdi
    1c7f:	call   1c84 <botlish_fn_7+0x324>
			1c80: R_X86_64_PLT32	rt_co_release-0x4
    1c84:	jmp    1db9 <botlish_fn_7+0x459>
    1c89:	mov    %rax,%rcx
    1c8c:	jmp    1ccf <botlish_fn_7+0x36f>
    1c91:	sar    $1,%rsi
    1c94:	mov    %rsi,%rax
    1c97:	imulq  0x1da(%rip)        # 1e78 <botlish_fn_7+0x518>
    1c9e:	lea    (%rdx,%rsi,1),%rdi
    1ca2:	sar    $0x1e,%rdi
    1ca6:	mov    %rdi,%r8
    1ca9:	shr    $0x3f,%r8
    1cad:	add    %r8,%rdi
    1cb0:	imul   $0x7fffffff,%rdi,%rdi
    1cb7:	sub    %rdi,%rsi
    1cba:	lea    (%rsi,%r14,1),%rdi
    1cbe:	test   %rsi,%rsi
    1cc1:	cmovl  %rdi,%rsi
    1cc5:	shl    $1,%rsi
    1cc8:	or     $0x1,%rsi
    1ccc:	mov    %rsi,%rcx
    1ccf:	mov    0x18(%r12),%r9
    1cd4:	test   %r9,%r9
    1cd7:	je     1e31 <botlish_fn_7+0x4d1>
    1cdd:	mov    0x10(%r12),%rax
    1ce2:	mov    %rcx,(%rax)
    1ce5:	movq   $0x3,0x10(%rsp)
    1cee:	mov    0x10(%r12),%rax
    1cf3:	mov    0x8(%rax),%rsi
    1cf7:	mov    %rsi,0x18(%rsp)
    1cfc:	movq   $0x3,0x20(%rsp)
    1d05:	test   $0x1,%rsi
    1d0c:	je     1d24 <botlish_fn_7+0x3c4>
    1d12:	mov    %rsi,%rcx
    1d15:	add    $0x2,%rcx
    1d19:	seto   %al
    1d1c:	test   %al,%al
    1d1e:	je     1d34 <botlish_fn_7+0x3d4>
    1d24:	mov    $0x3,%edx
    1d29:	mov    %r15,%rdi
    1d2c:	call   1d31 <botlish_fn_7+0x3d1>
			1d2d: R_X86_64_PLT32	rt_int_add-0x4
    1d31:	mov    %rax,%rcx
    1d34:	mov    0x18(%r12),%rax
    1d39:	test   %rax,%rax
    1d3c:	je     1e46 <botlish_fn_7+0x4e6>
    1d42:	mov    0x10(%r12),%rax
    1d47:	mov    %rcx,0x8(%rax)
    1d4b:	mov    $0x5,%edx
    1d50:	mov    %rdx,0x48(%rsp)
    1d55:	movq   $0x5,0x10(%rsp)
    1d5e:	mov    0x50(%rsp),%rsi
    1d63:	mov    %r15,%rdi
    1d66:	call   1d6b <botlish_fn_7+0x40b>
			1d67: R_X86_64_PLT32	rt_co_resume0-0x4
    1d6b:	test   %rax,%rax
    1d6e:	mov    %rax,%rcx
    1d71:	jne    1de4 <botlish_fn_7+0x484>
    1d77:	mov    %r15,%rdi
    1d7a:	call   1d7f <botlish_fn_7+0x41f>
			1d7b: R_X86_64_PLT32	rt_declared_error-0x4
    1d7f:	cmp    $0x40000001,%rax
    1d85:	jne    1d98 <botlish_fn_7+0x438>
    1d8b:	mov    0x50(%rsp),%rsi
    1d90:	mov    %r15,%rdi
    1d93:	call   1d98 <botlish_fn_7+0x438>
			1d94: R_X86_64_PLT32	rt_co_release-0x4
    1d98:	mov    %r15,%rdi
    1d9b:	call   1da0 <botlish_fn_7+0x440>
			1d9c: R_X86_64_PLT32	rt_declared_error-0x4
    1da0:	cmp    $0x40000001,%rax
    1da6:	jne    1db9 <botlish_fn_7+0x459>
    1dac:	mov    0x50(%rsp),%rsi
    1db1:	mov    %r15,%rdi
    1db4:	call   1db9 <botlish_fn_7+0x459>
			1db5: R_X86_64_PLT32	rt_co_release-0x4
    1db9:	xor    %rax,%rax
    1dbc:	mov    0x60(%rsp),%rbx
    1dc1:	mov    0x68(%rsp),%r12
    1dc6:	mov    0x70(%rsp),%r13
    1dcb:	mov    0x78(%rsp),%r14
    1dd0:	mov    0x80(%rsp),%r15
    1dd8:	add    $0x90,%rsp
    1ddf:	mov    %rbp,%rsp
    1de2:	pop    %rbp
    1de3:	ret
    1de4:	mov    0x18(%r12),%rax
    1de9:	test   %rax,%rax
    1dec:	je     1e5b <botlish_fn_7+0x4fb>
    1df2:	mov    0x10(%r12),%rax
    1df7:	mov    %rcx,0x10(%rax)
    1dfb:	jmp    1b24 <botlish_fn_7+0x1c4>
    1e00:	mov    0x50(%rsp),%rsi
    1e05:	mov    %r15,%rdi
    1e08:	call   1e0d <botlish_fn_7+0x4ad>
			1e09: R_X86_64_PLT32	rt_co_release-0x4
    1e0d:	add    $0x1,%rbx
    1e14:	mov    %r12,%rax
    1e17:	jmp    19e7 <botlish_fn_7+0x87>
    1e1c:	mov    $0x5,%edx
    1e21:	mov    %r12,%rsi
    1e24:	mov    %r15,%rdi
    1e27:	call   1e2c <botlish_fn_7+0x4cc>
			1e28: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e2c:	jmp    1b15 <botlish_fn_7+0x1b5>
    1e31:	mov    $0x1,%edx
    1e36:	mov    %r12,%rsi
    1e39:	mov    %r15,%rdi
    1e3c:	call   1e41 <botlish_fn_7+0x4e1>
			1e3d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e41:	jmp    1ce5 <botlish_fn_7+0x385>
    1e46:	mov    $0x3,%edx
    1e4b:	mov    %r12,%rsi
    1e4e:	mov    %r15,%rdi
    1e51:	call   1e56 <botlish_fn_7+0x4f6>
			1e52: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e56:	jmp    1d4b <botlish_fn_7+0x3eb>
    1e5b:	mov    0x48(%rsp),%rdx
    1e60:	mov    %r12,%rsi
    1e63:	mov    %r15,%rdi
    1e66:	call   1e6b <botlish_fn_7+0x50b>
			1e67: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1e6b:	jmp    1b24 <botlish_fn_7+0x1c4>
    1e70:	ds add %al,(%rax)
    1e73:	add    %al,(%rax)
    1e75:	add    %al,(%rax)
    1e77:	add    %al,(%rbx)
    1e79:	add    %al,(%rax)
    1e7b:	add    %al,(%rcx)
    1e7d:	add    %al,(%rax)
    1e7f:	.byte 0x80

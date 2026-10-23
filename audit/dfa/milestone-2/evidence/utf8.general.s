<botlish_fn_6>:
 994:	push   %rbp
 995:	mov    %rsp,%rbp
 998:	sub    $0x50,%rsp
 99c:	mov    %rbx,0x30(%rsp)
 9a1:	mov    %r12,0x38(%rsp)
 9a6:	mov    %r13,0x40(%rsp)
 9ab:	mov    %r14,0x48(%rsp)
 9b0:	mov    %rsi,%rbx
 9b3:	mov    %rdi,%r13
 9b6:	movq   $0x0,0x8(%rsp)
 9bf:	xor    %rsi,%rsi
 9c2:	mov    %r13,%rdi
 9c5:	call   9ca <botlish_fn_6+0x36>
			9c6: R_X86_64_PLT32	botlish_fn_5-0x4
 9ca:	mov    %rax,(%rsp)
 9ce:	lea    0x10(%rsp),%r8
 9d3:	mov    %rax,0x10(%rsp)
 9d8:	mov    $0x7,%esi
 9dd:	mov    0x0(%rip),%rdx        # 9e4 <botlish_fn_6+0x50>
			9e0: R_X86_64_GOTPCREL	botlish_entry_7-0x4
 9e4:	mov    $0x1,%ecx
 9e9:	mov    %r13,%rdi
 9ec:	call   9f1 <botlish_fn_6+0x5d>
			9ed: R_X86_64_PLT32	rt_closure_new-0x4
 9f1:	mov    %rax,(%rsp)
 9f5:	mov    %rax,%rsi
 9f8:	mov    %r13,%rdi
 9fb:	call   a00 <botlish_fn_6+0x6c>
			9fc: R_X86_64_PLT32	rt_co_create-0x4
 a00:	mov    %rax,%r14
 a03:	mov    %rax,(%rsp)
 a07:	mov    %r14,%rsi
 a0a:	mov    %r13,%rdi
 a0d:	call   a12 <botlish_fn_6+0x7e>
			a0e: R_X86_64_PLT32	rt_co_start-0x4
 a12:	test   %rax,%rax
 a15:	jne    a5f <botlish_fn_6+0xcb>
 a1b:	mov    %r13,%rdi
 a1e:	call   a23 <botlish_fn_6+0x8f>
			a1f: R_X86_64_PLT32	rt_declared_error-0x4
 a23:	cmp    $0x2,%rax
 a27:	je     a4f <botlish_fn_6+0xbb>
 a2d:	mov    %r13,%rdi
 a30:	call   a35 <botlish_fn_6+0xa1>
			a31: R_X86_64_PLT32	rt_declared_error-0x4
 a35:	cmp    $0x1,%rax
 a39:	jne    be9 <botlish_fn_6+0x255>
 a3f:	mov    %r14,%rsi
 a42:	mov    %r13,%rdi
 a45:	call   a4a <botlish_fn_6+0xb6>
			a46: R_X86_64_PLT32	rt_co_release-0x4
 a4a:	jmp    be9 <botlish_fn_6+0x255>
 a4f:	mov    %r14,%rsi
 a52:	mov    %r13,%rdi
 a55:	call   a5a <botlish_fn_6+0xc6>
			a56: R_X86_64_PLT32	rt_co_release-0x4
 a5a:	jmp    be9 <botlish_fn_6+0x255>
 a5f:	mov    $0x1,%r12d
 a65:	cmp    %rbx,%r12
 a68:	jl     b64 <botlish_fn_6+0x1d0>
 a6e:	movq   $0xffffffffffffffff,0x8(%rsp)
 a77:	lea    0x20(%rsp),%rcx
 a7c:	movq   $0xffffffffffffffff,0x20(%rsp)
 a85:	xor    %rsi,%rsi
 a88:	mov    $0x1,%edx
 a8d:	mov    %r13,%rdi
 a90:	call   a95 <botlish_fn_6+0x101>
			a91: R_X86_64_PLT32	rt_struct_new-0x4
 a95:	mov    %rax,0x8(%rsp)
 a9a:	mov    %rax,%rdx
 a9d:	mov    %r14,%rsi
 aa0:	mov    %r13,%rdi
 aa3:	call   aa8 <botlish_fn_6+0x114>
			aa4: R_X86_64_PLT32	rt_co_resume-0x4
 aa8:	test   %rax,%rax
 aab:	jne    af5 <botlish_fn_6+0x161>
 ab1:	mov    %r13,%rdi
 ab4:	call   ab9 <botlish_fn_6+0x125>
			ab5: R_X86_64_PLT32	rt_declared_error-0x4
 ab9:	cmp    $0x2,%rax
 abd:	je     ae5 <botlish_fn_6+0x151>
 ac3:	mov    %r13,%rdi
 ac6:	call   acb <botlish_fn_6+0x137>
			ac7: R_X86_64_PLT32	rt_declared_error-0x4
 acb:	cmp    $0x1,%rax
 acf:	jne    be9 <botlish_fn_6+0x255>
 ad5:	mov    %r14,%rsi
 ad8:	mov    %r13,%rdi
 adb:	call   ae0 <botlish_fn_6+0x14c>
			adc: R_X86_64_PLT32	rt_co_release-0x4
 ae0:	jmp    be9 <botlish_fn_6+0x255>
 ae5:	mov    %r14,%rsi
 ae8:	mov    %r13,%rdi
 aeb:	call   af0 <botlish_fn_6+0x15c>
			aec: R_X86_64_PLT32	rt_co_release-0x4
 af0:	jmp    be9 <botlish_fn_6+0x255>
 af5:	mov    %r14,%rsi
 af8:	mov    %r13,%rdi
 afb:	call   b00 <botlish_fn_6+0x16c>
			afc: R_X86_64_PLT32	rt_co_done-0x4
 b00:	cmp    $0x6,%rax
 b04:	je     b37 <botlish_fn_6+0x1a3>
 b0a:	mov    %r14,%rsi
 b0d:	mov    %r13,%rdi
 b10:	call   b15 <botlish_fn_6+0x181>
			b11: R_X86_64_PLT32	rt_co_release-0x4
 b15:	mov    $0x1,%eax
 b1a:	mov    0x30(%rsp),%rbx
 b1f:	mov    0x38(%rsp),%r12
 b24:	mov    0x40(%rsp),%r13
 b29:	mov    0x48(%rsp),%r14
 b2e:	add    $0x50,%rsp
 b32:	mov    %rbp,%rsp
 b35:	pop    %rbp
 b36:	ret
 b37:	mov    %r14,%rsi
 b3a:	mov    %r13,%rdi
 b3d:	call   b42 <botlish_fn_6+0x1ae>
			b3e: R_X86_64_PLT32	rt_co_release-0x4
 b42:	mov    $0x3,%eax
 b47:	mov    0x30(%rsp),%rbx
 b4c:	mov    0x38(%rsp),%r12
 b51:	mov    0x40(%rsp),%r13
 b56:	mov    0x48(%rsp),%r14
 b5b:	add    $0x50,%rsp
 b5f:	mov    %rbp,%rsp
 b62:	pop    %rbp
 b63:	ret
 b64:	mov    %r12,%rsi
 b67:	mov    %r13,%rdi
 b6a:	call   b6f <botlish_fn_6+0x1db>
			b6b: R_X86_64_PLT32	botlish_fn_5-0x4
 b6f:	mov    %rax,0x8(%rsp)
 b74:	lea    0x18(%rsp),%rcx
 b79:	mov    %rax,0x18(%rsp)
 b7e:	xor    %rsi,%rsi
 b81:	mov    $0x1,%edx
 b86:	mov    %r13,%rdi
 b89:	call   b8e <botlish_fn_6+0x1fa>
			b8a: R_X86_64_PLT32	rt_struct_new-0x4
 b8e:	mov    %rax,0x8(%rsp)
 b93:	mov    %rax,%rdx
 b96:	mov    %r14,%rsi
 b99:	mov    %r13,%rdi
 b9c:	call   ba1 <botlish_fn_6+0x20d>
			b9d: R_X86_64_PLT32	rt_co_resume-0x4
 ba1:	test   %rax,%rax
 ba4:	jne    c09 <botlish_fn_6+0x275>
 baa:	mov    %r13,%rdi
 bad:	call   bb2 <botlish_fn_6+0x21e>
			bae: R_X86_64_PLT32	rt_declared_error-0x4
 bb2:	cmp    $0x2,%rax
 bb6:	je     bde <botlish_fn_6+0x24a>
 bbc:	mov    %r13,%rdi
 bbf:	call   bc4 <botlish_fn_6+0x230>
			bc0: R_X86_64_PLT32	rt_declared_error-0x4
 bc4:	cmp    $0x1,%rax
 bc8:	jne    be9 <botlish_fn_6+0x255>
 bce:	mov    %r14,%rsi
 bd1:	mov    %r13,%rdi
 bd4:	call   bd9 <botlish_fn_6+0x245>
			bd5: R_X86_64_PLT32	rt_co_release-0x4
 bd9:	jmp    be9 <botlish_fn_6+0x255>
 bde:	mov    %r14,%rsi
 be1:	mov    %r13,%rdi
 be4:	call   be9 <botlish_fn_6+0x255>
			be5: R_X86_64_PLT32	rt_co_release-0x4
 be9:	xor    %rax,%rax
 bec:	mov    0x30(%rsp),%rbx
 bf1:	mov    0x38(%rsp),%r12
 bf6:	mov    0x40(%rsp),%r13
 bfb:	mov    0x48(%rsp),%r14
 c00:	add    $0x50,%rsp
 c04:	mov    %rbp,%rsp
 c07:	pop    %rbp
 c08:	ret
 c09:	add    $0x1,%r12
 c10:	jmp    a65 <botlish_fn_6+0xd1>

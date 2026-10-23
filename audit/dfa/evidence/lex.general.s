<botlish_fn_13>:
    4788:	push   %rbp
    4789:	mov    %rsp,%rbp
    478c:	sub    $0x140,%rsp
    4793:	mov    %rbx,0x110(%rsp)
    479b:	mov    %r12,0x118(%rsp)
    47a3:	mov    %r13,0x120(%rsp)
    47ab:	mov    %r14,0x128(%rsp)
    47b3:	mov    %r15,0x130(%rsp)
    47bb:	mov    %rdi,0xc0(%rsp)
    47c3:	movq   $0x0,0x10(%rsp)
    47cc:	movq   $0x0,0x18(%rsp)
    47d5:	movq   $0x0,0x20(%rsp)
    47de:	movq   $0x0,0x28(%rsp)
    47e7:	movq   $0x0,0x30(%rsp)
    47f0:	movq   $0x0,0x38(%rsp)
    47f9:	movq   $0x0,0x40(%rsp)
    4802:	movq   $0x0,0x48(%rsp)
    480b:	movq   $0x0,0x50(%rsp)
    4814:	mov    %rsi,(%rsp)
    4818:	mov    %rdx,0x8(%rsp)
    481d:	mov    %rdx,0xc8(%rsp)
    4825:	lea    0x58(%rsp),%r8
    482a:	mov    %rsi,0x58(%rsp)
    482f:	mov    $0xe,%esi
    4834:	mov    0x0(%rip),%rdx        # 483b <botlish_fn_13+0xb3>
			4837: R_X86_64_GOTPCREL	botlish_entry_14-0x4
    483b:	mov    $0x1,%ecx
    4840:	mov    0xc0(%rsp),%rdi
    4848:	call   484d <botlish_fn_13+0xc5>
			4849: R_X86_64_PLT32	rt_closure_new-0x4
    484d:	mov    %rax,(%rsp)
    4851:	mov    %rax,%rsi
    4854:	mov    0xc0(%rsp),%rdi
    485c:	call   4861 <botlish_fn_13+0xd9>
			485d: R_X86_64_PLT32	rt_co_create-0x4
    4861:	mov    %rax,0x108(%rsp)
    4869:	mov    %rax,(%rsp)
    486d:	mov    0x108(%rsp),%rsi
    4875:	mov    0xc0(%rsp),%rdi
    487d:	call   4882 <botlish_fn_13+0xfa>
			487e: R_X86_64_PLT32	rt_co_start-0x4
    4882:	test   %rax,%rax
    4885:	jne    48be <botlish_fn_13+0x136>
    488b:	mov    0xc0(%rsp),%rdi
    4893:	call   4898 <botlish_fn_13+0x110>
			4894: R_X86_64_PLT32	rt_declared_error-0x4
    4898:	cmp    $0x40000001,%rax
    489e:	jne    52d4 <botlish_fn_13+0xb4c>
    48a4:	mov    0x108(%rsp),%rsi
    48ac:	mov    0xc0(%rsp),%rdi
    48b4:	call   48b9 <botlish_fn_13+0x131>
			48b5: R_X86_64_PLT32	rt_co_release-0x4
    48b9:	jmp    52d4 <botlish_fn_13+0xb4c>
    48be:	mov    %rax,0x10(%rsp)
    48c3:	mov    %rax,%rdx
    48c6:	mov    $0x3,%esi
    48cb:	movq   $0x3,0x18(%rsp)
    48d4:	mov    0xc0(%rsp),%rdi
    48dc:	call   48e1 <botlish_fn_13+0x159>
			48dd: R_X86_64_PLT32	rt_mutarray_create-0x4
    48e1:	test   %rax,%rax
    48e4:	je     52d4 <botlish_fn_13+0xb4c>
    48ea:	mov    %rax,0x10(%rsp)
    48ef:	mov    %rax,%r13
    48f2:	mov    $0x3,%esi
    48f7:	movq   $0x3,0x18(%rsp)
    4900:	mov    $0x1,%edx
    4905:	movq   $0x1,0x20(%rsp)
    490e:	mov    0xc0(%rsp),%rdi
    4916:	call   491b <botlish_fn_13+0x193>
			4917: R_X86_64_PLT32	rt_mutarray_create-0x4
    491b:	test   %rax,%rax
    491e:	je     52d4 <botlish_fn_13+0xb4c>
    4924:	mov    %rax,0x18(%rsp)
    4929:	mov    %rax,0x100(%rsp)
    4931:	mov    $0x3,%esi
    4936:	movq   $0x3,0x20(%rsp)
    493f:	mov    $0x1,%edx
    4944:	movq   $0x1,0x28(%rsp)
    494d:	mov    0xc0(%rsp),%rdi
    4955:	call   495a <botlish_fn_13+0x1d2>
			4956: R_X86_64_PLT32	rt_mutarray_create-0x4
    495a:	mov    %rax,%rcx
    495d:	test   %rcx,%rcx
    4960:	je     52d4 <botlish_fn_13+0xb4c>
    4966:	mov    %rcx,0x20(%rsp)
    496b:	mov    %rcx,0xf8(%rsp)
    4973:	mov    $0x3,%esi
    4978:	movq   $0x3,0x28(%rsp)
    4981:	mov    $0x2,%edx
    4986:	movq   $0x2,0x30(%rsp)
    498f:	mov    0xc0(%rsp),%rdi
    4997:	call   499c <botlish_fn_13+0x214>
			4998: R_X86_64_PLT32	rt_mutarray_create-0x4
    499c:	mov    %rax,%r12
    499f:	test   %r12,%r12
    49a2:	je     52d4 <botlish_fn_13+0xb4c>
    49a8:	mov    %r12,0x28(%rsp)
    49ad:	mov    $0xffffffffffffffff,%r14
    49b4:	mov    %r14,0xf0(%rsp)
    49bc:	lea    0x60(%rsp),%r15
    49c1:	mov    %r15,0xe8(%rsp)
    49c9:	mov    0x0(%rip),%rbx        # 49d0 <botlish_fn_13+0x248>
			49cc: R_X86_64_GOTPCREL	botlish_entry_15-0x4
    49d0:	mov    %rbx,0xe0(%rsp)
    49d8:	mov    0x10(%r13),%rdx
    49dc:	mov    (%rdx),%r15
    49df:	mov    %r15,0x30(%rsp)
    49e4:	mov    %r15,%rsi
    49e7:	mov    0xc0(%rsp),%rdi
    49ef:	call   49f4 <botlish_fn_13+0x26c>
			49f0: R_X86_64_PLT32	botlish_fn_11-0x4
    49f4:	cmp    $0x6,%rax
    49f8:	je     51d0 <botlish_fn_13+0xa48>
    49fe:	test   $0x1,%r15
    4a05:	jne    4a38 <botlish_fn_13+0x2b0>
    4a0b:	mov    0xf0(%rsp),%rdx
    4a13:	mov    %r15,%rsi
    4a16:	mov    0xc0(%rsp),%rdi
    4a1e:	call   4a23 <botlish_fn_13+0x29b>
			4a1f: R_X86_64_PLT32	rt_int_cmp-0x4
    4a23:	mov    $0x2,%ecx
    4a28:	test   %rax,%rax
    4a2b:	cmove  0x9c5(%rip),%rcx        # 53f8 <botlish_fn_13+0xc70>
    4a33:	jmp    4a49 <botlish_fn_13+0x2c1>
    4a38:	mov    $0x2,%ecx
    4a3d:	cmp    $0xffffffffffffffff,%r15
    4a41:	cmove  0x9af(%rip),%rcx        # 53f8 <botlish_fn_13+0xc70>
    4a49:	cmp    $0x6,%rcx
    4a4d:	je     5133 <botlish_fn_13+0x9ab>
    4a53:	mov    0x100(%rsp),%rbx
    4a5b:	mov    0x10(%rbx),%rax
    4a5f:	mov    (%rax),%r14
    4a62:	mov    %r14,0x38(%rsp)
    4a67:	mov    %r15,0x60(%rsp)
    4a6c:	mov    $0xf,%esi
    4a71:	mov    $0x1,%ecx
    4a76:	mov    0xe0(%rsp),%rdx
    4a7e:	mov    0xc0(%rsp),%rdi
    4a86:	mov    0xe8(%rsp),%r8
    4a8e:	call   4a93 <botlish_fn_13+0x30b>
			4a8f: R_X86_64_PLT32	rt_closure_new-0x4
    4a93:	mov    %rax,0x30(%rsp)
    4a98:	mov    %rax,%rsi
    4a9b:	mov    0xc0(%rsp),%rdi
    4aa3:	call   4aa8 <botlish_fn_13+0x320>
			4aa4: R_X86_64_PLT32	rt_co_create-0x4
    4aa8:	mov    %rax,0xd8(%rsp)
    4ab0:	mov    %rax,0x30(%rsp)
    4ab5:	mov    0xd8(%rsp),%rsi
    4abd:	mov    0xc0(%rsp),%rdi
    4ac5:	call   4aca <botlish_fn_13+0x342>
			4ac6: R_X86_64_PLT32	rt_co_start-0x4
    4aca:	test   %rax,%rax
    4acd:	mov    %rax,%rcx
    4ad0:	jne    4c11 <botlish_fn_13+0x489>
    4ad6:	mov    0xc0(%rsp),%rdi
    4ade:	call   4ae3 <botlish_fn_13+0x35b>
			4adf: R_X86_64_PLT32	rt_declared_error-0x4
    4ae3:	cmp    $0x1,%rax
    4ae7:	je     4b88 <botlish_fn_13+0x400>
    4aed:	mov    0xc0(%rsp),%rdi
    4af5:	call   4afa <botlish_fn_13+0x372>
			4af6: R_X86_64_PLT32	rt_declared_error-0x4
    4afa:	cmp    $0x2,%rax
    4afe:	jne    52d4 <botlish_fn_13+0xb4c>
    4b04:	xor    %rsi,%rsi
    4b07:	mov    0xc0(%rsp),%rdi
    4b0f:	call   4b14 <botlish_fn_13+0x38c>
			4b10: R_X86_64_PLT32	rt_declared_payload-0x4
    4b14:	mov    %rax,%rbx
    4b17:	mov    0xc0(%rsp),%rdi
    4b1f:	call   4b24 <botlish_fn_13+0x39c>
			4b20: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4b24:	mov    0x108(%rsp),%rsi
    4b2c:	mov    0xc0(%rsp),%rdi
    4b34:	call   4b39 <botlish_fn_13+0x3b1>
			4b35: R_X86_64_PLT32	rt_co_release-0x4
    4b39:	mov    0xd8(%rsp),%rsi
    4b41:	mov    0xc0(%rsp),%rdi
    4b49:	call   4b4e <botlish_fn_13+0x3c6>
			4b4a: R_X86_64_PLT32	rt_co_release-0x4
    4b4e:	mov    0xc0(%rsp),%rdi
    4b56:	mov    0x10(%rdi),%rax
    4b5a:	mov    0x110(%rax),%rdx
    4b61:	lea    0x78(%rsp),%r9
    4b66:	mov    %rbx,%rax
    4b69:	mov    %rax,0x78(%rsp)
    4b6e:	mov    $0x5,%esi
    4b73:	mov    $0x2,%ecx
    4b78:	mov    $0x1,%r8d
    4b7e:	call   4b83 <botlish_fn_13+0x3fb>
			4b7f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4b83:	jmp    52d4 <botlish_fn_13+0xb4c>
    4b88:	xor    %rsi,%rsi
    4b8b:	mov    0xc0(%rsp),%rdi
    4b93:	call   4b98 <botlish_fn_13+0x410>
			4b94: R_X86_64_PLT32	rt_declared_payload-0x4
    4b98:	mov    %rax,%rbx
    4b9b:	mov    0xc0(%rsp),%rdi
    4ba3:	call   4ba8 <botlish_fn_13+0x420>
			4ba4: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4ba8:	mov    0x108(%rsp),%rsi
    4bb0:	mov    0xc0(%rsp),%rdi
    4bb8:	call   4bbd <botlish_fn_13+0x435>
			4bb9: R_X86_64_PLT32	rt_co_release-0x4
    4bbd:	mov    0xd8(%rsp),%rsi
    4bc5:	mov    0xc0(%rsp),%rdi
    4bcd:	call   4bd2 <botlish_fn_13+0x44a>
			4bce: R_X86_64_PLT32	rt_co_release-0x4
    4bd2:	mov    0xc0(%rsp),%rdi
    4bda:	mov    0x10(%rdi),%rax
    4bde:	mov    0x108(%rax),%rdx
    4be5:	lea    0x68(%rsp),%r9
    4bea:	mov    %r14,0x68(%rsp)
    4bef:	mov    %rbx,%rax
    4bf2:	mov    %rax,0x70(%rsp)
    4bf7:	mov    $0x4,%esi
    4bfc:	mov    $0x1,%ecx
    4c01:	mov    $0x2,%r8d
    4c07:	call   4c0c <botlish_fn_13+0x484>
			4c08: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4c0c:	jmp    52d4 <botlish_fn_13+0xb4c>
    4c11:	mov    0x18(%r12),%rax
    4c16:	test   %rax,%rax
    4c19:	je     533c <botlish_fn_13+0xbb4>
    4c1f:	mov    0x10(%r12),%rax
    4c24:	mov    %rcx,(%rax)
    4c27:	mov    0x10(%r12),%rax
    4c2c:	mov    (%rax),%rax
    4c2f:	cmp    $0x6,%rax
    4c33:	jne    4d68 <botlish_fn_13+0x5e0>
    4c39:	movq   $0x1,0x40(%rsp)
    4c42:	mov    0x10(%rbx),%rax
    4c46:	mov    (%rax),%rsi
    4c49:	mov    %rsi,0x48(%rsp)
    4c4e:	movq   $0x3,0x50(%rsp)
    4c57:	test   $0x1,%rsi
    4c5e:	je     4c76 <botlish_fn_13+0x4ee>
    4c64:	mov    %rsi,%rcx
    4c67:	add    $0x2,%rcx
    4c6b:	seto   %al
    4c6e:	test   %al,%al
    4c70:	je     4c8b <botlish_fn_13+0x503>
    4c76:	mov    $0x3,%edx
    4c7b:	mov    0xc0(%rsp),%rdi
    4c83:	call   4c88 <botlish_fn_13+0x500>
			4c84: R_X86_64_PLT32	rt_int_add-0x4
    4c88:	mov    %rax,%rcx
    4c8b:	mov    0x18(%rbx),%rax
    4c8f:	test   %rax,%rax
    4c92:	je     5356 <botlish_fn_13+0xbce>
    4c98:	mov    0x10(%rbx),%rax
    4c9c:	mov    %rcx,(%rax)
    4c9f:	movq   $0x1,0x40(%rsp)
    4ca8:	mov    0x108(%rsp),%rsi
    4cb0:	mov    0xc0(%rsp),%rdi
    4cb8:	call   4cbd <botlish_fn_13+0x535>
			4cb9: R_X86_64_PLT32	rt_co_resume0-0x4
    4cbd:	test   %rax,%rax
    4cc0:	mov    %rax,%rcx
    4cc3:	jne    4d54 <botlish_fn_13+0x5cc>
    4cc9:	mov    0xc0(%rsp),%rdi
    4cd1:	call   4cd6 <botlish_fn_13+0x54e>
			4cd2: R_X86_64_PLT32	rt_declared_error-0x4
    4cd6:	cmp    $0x40000001,%rax
    4cdc:	jne    4d0c <botlish_fn_13+0x584>
    4ce2:	mov    0x108(%rsp),%rsi
    4cea:	mov    0xc0(%rsp),%rdi
    4cf2:	call   4cf7 <botlish_fn_13+0x56f>
			4cf3: R_X86_64_PLT32	rt_co_release-0x4
    4cf7:	mov    0xd8(%rsp),%rsi
    4cff:	mov    0xc0(%rsp),%rdi
    4d07:	call   4d0c <botlish_fn_13+0x584>
			4d08: R_X86_64_PLT32	rt_co_release-0x4
    4d0c:	mov    0xc0(%rsp),%rdi
    4d14:	call   4d19 <botlish_fn_13+0x591>
			4d15: R_X86_64_PLT32	rt_declared_error-0x4
    4d19:	cmp    $0x40000001,%rax
    4d1f:	jne    52d4 <botlish_fn_13+0xb4c>
    4d25:	mov    0x108(%rsp),%rsi
    4d2d:	mov    0xc0(%rsp),%rdi
    4d35:	call   4d3a <botlish_fn_13+0x5b2>
			4d36: R_X86_64_PLT32	rt_co_release-0x4
    4d3a:	mov    0xd8(%rsp),%rsi
    4d42:	mov    0xc0(%rsp),%rdi
    4d4a:	call   4d4f <botlish_fn_13+0x5c7>
			4d4b: R_X86_64_PLT32	rt_co_release-0x4
    4d4f:	jmp    52d4 <botlish_fn_13+0xb4c>
    4d54:	mov    0x18(%r13),%rax
    4d58:	test   %rax,%rax
    4d5b:	je     5370 <botlish_fn_13+0xbe8>
    4d61:	mov    0x10(%r13),%rax
    4d65:	mov    %rcx,(%rax)
    4d68:	mov    0xd8(%rsp),%rsi
    4d70:	mov    0xc0(%rsp),%rdi
    4d78:	call   4d7d <botlish_fn_13+0x5f5>
			4d79: R_X86_64_PLT32	rt_co_done-0x4
    4d7d:	cmp    $0x6,%rax
    4d81:	je     508b <botlish_fn_13+0x903>
    4d87:	mov    0x10(%rbx),%rax
    4d8b:	mov    (%rax),%rsi
    4d8e:	mov    %rsi,0x40(%rsp)
    4d93:	mov    %rsi,%rax
    4d96:	and    %r14,%rax
    4d99:	test   $0x1,%rax
    4d9f:	je     4dd2 <botlish_fn_13+0x64a>
    4da5:	mov    %rsi,%rcx
    4da8:	sub    %r14,%rcx
    4dab:	mov    %rsi,%rdx
    4dae:	seto   %al
    4db1:	lea    0x1(%rcx),%rsi
    4db5:	test   %al,%al
    4db7:	je     4dc5 <botlish_fn_13+0x63d>
    4dbd:	mov    %rdx,%rsi
    4dc0:	jmp    4dd2 <botlish_fn_13+0x64a>
    4dc5:	mov    0xc8(%rsp),%r15
    4dcd:	jmp    4ded <botlish_fn_13+0x665>
    4dd2:	mov    %r14,%rdx
    4dd5:	mov    0xc0(%rsp),%rdi
    4ddd:	call   4de2 <botlish_fn_13+0x65a>
			4dde: R_X86_64_PLT32	rt_int_sub-0x4
    4de2:	mov    %rax,%rsi
    4de5:	mov    0xc8(%rsp),%r15
    4ded:	mov    %rsi,%rax
    4df0:	and    %r15,%rax
    4df3:	test   $0x1,%rax
    4df9:	jne    4e24 <botlish_fn_13+0x69c>
    4dff:	mov    %r15,%rdx
    4e02:	mov    0xc0(%rsp),%rdi
    4e0a:	call   4e0f <botlish_fn_13+0x687>
			4e0b: R_X86_64_PLT32	rt_int_cmp-0x4
    4e0f:	mov    $0x2,%ecx
    4e14:	test   %rax,%rax
    4e17:	cmovge 0x5d9(%rip),%rcx        # 53f8 <botlish_fn_13+0xc70>
    4e1f:	jmp    4e34 <botlish_fn_13+0x6ac>
    4e24:	mov    $0x2,%ecx
    4e29:	cmp    %r15,%rsi
    4e2c:	cmovge 0x5c4(%rip),%rcx        # 53f8 <botlish_fn_13+0xc70>
    4e34:	cmp    $0x6,%rcx
    4e38:	je     501c <botlish_fn_13+0x894>
    4e3e:	mov    0x10(%r13),%rax
    4e42:	mov    (%rax),%rcx
    4e45:	mov    %rcx,0x40(%rsp)
    4e4a:	lea    0x90(%rsp),%rax
    4e52:	mov    %rcx,0x90(%rsp)
    4e5a:	mov    $0x4,%esi
    4e5f:	mov    %rsi,0xd0(%rsp)
    4e67:	mov    $0x1,%edx
    4e6c:	mov    %rax,%rcx
    4e6f:	mov    0xc0(%rsp),%rdi
    4e77:	call   4e7c <botlish_fn_13+0x6f4>
			4e78: R_X86_64_PLT32	rt_struct_new-0x4
    4e7c:	mov    %rax,0x40(%rsp)
    4e81:	mov    %rax,%rdx
    4e84:	mov    0xd8(%rsp),%rsi
    4e8c:	mov    0xc0(%rsp),%rdi
    4e94:	call   4e99 <botlish_fn_13+0x711>
			4e95: R_X86_64_PLT32	rt_co_resume-0x4
    4e99:	test   %rax,%rax
    4e9c:	mov    %rax,%rcx
    4e9f:	jne    4ff9 <botlish_fn_13+0x871>
    4ea5:	mov    0xc0(%rsp),%rdi
    4ead:	call   4eb2 <botlish_fn_13+0x72a>
			4eae: R_X86_64_PLT32	rt_declared_error-0x4
    4eb2:	cmp    $0x1,%rax
    4eb6:	je     4f5d <botlish_fn_13+0x7d5>
    4ebc:	mov    0xc0(%rsp),%rdi
    4ec4:	call   4ec9 <botlish_fn_13+0x741>
			4ec5: R_X86_64_PLT32	rt_declared_error-0x4
    4ec9:	cmp    $0x2,%rax
    4ecd:	jne    52d4 <botlish_fn_13+0xb4c>
    4ed3:	xor    %rsi,%rsi
    4ed6:	mov    0xc0(%rsp),%rdi
    4ede:	call   4ee3 <botlish_fn_13+0x75b>
			4edf: R_X86_64_PLT32	rt_declared_payload-0x4
    4ee3:	mov    %rax,%rbx
    4ee6:	mov    0xc0(%rsp),%rdi
    4eee:	call   4ef3 <botlish_fn_13+0x76b>
			4eef: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4ef3:	mov    0x108(%rsp),%rsi
    4efb:	mov    0xc0(%rsp),%rdi
    4f03:	call   4f08 <botlish_fn_13+0x780>
			4f04: R_X86_64_PLT32	rt_co_release-0x4
    4f08:	mov    0xd8(%rsp),%rsi
    4f10:	mov    0xc0(%rsp),%rdi
    4f18:	call   4f1d <botlish_fn_13+0x795>
			4f19: R_X86_64_PLT32	rt_co_release-0x4
    4f1d:	mov    0xc0(%rsp),%rdi
    4f25:	mov    0x10(%rdi),%rax
    4f29:	mov    0x110(%rax),%rdx
    4f30:	lea    0xa8(%rsp),%r9
    4f38:	mov    %rbx,%rax
    4f3b:	mov    %rax,0xa8(%rsp)
    4f43:	mov    $0x5,%esi
    4f48:	mov    $0x2,%ecx
    4f4d:	mov    $0x1,%r8d
    4f53:	call   4f58 <botlish_fn_13+0x7d0>
			4f54: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4f58:	jmp    52d4 <botlish_fn_13+0xb4c>
    4f5d:	xor    %rsi,%rsi
    4f60:	mov    0xc0(%rsp),%rdi
    4f68:	call   4f6d <botlish_fn_13+0x7e5>
			4f69: R_X86_64_PLT32	rt_declared_payload-0x4
    4f6d:	mov    %rax,%r12
    4f70:	mov    0xc0(%rsp),%rdi
    4f78:	call   4f7d <botlish_fn_13+0x7f5>
			4f79: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4f7d:	mov    0x108(%rsp),%rsi
    4f85:	mov    0xc0(%rsp),%rdi
    4f8d:	call   4f92 <botlish_fn_13+0x80a>
			4f8e: R_X86_64_PLT32	rt_co_release-0x4
    4f92:	mov    0xd8(%rsp),%rsi
    4f9a:	mov    0xc0(%rsp),%rdi
    4fa2:	call   4fa7 <botlish_fn_13+0x81f>
			4fa3: R_X86_64_PLT32	rt_co_release-0x4
    4fa7:	mov    0x10(%rbx),%rax
    4fab:	mov    (%rax),%rcx
    4fae:	mov    0xc0(%rsp),%rdi
    4fb6:	mov    0x10(%rdi),%rax
    4fba:	mov    0x108(%rax),%rdx
    4fc1:	lea    0x98(%rsp),%r9
    4fc9:	mov    %rcx,0x98(%rsp)
    4fd1:	mov    %r12,%rax
    4fd4:	mov    %rax,0xa0(%rsp)
    4fdc:	mov    $0x1,%ecx
    4fe1:	mov    $0x2,%r8d
    4fe7:	mov    0xd0(%rsp),%rsi
    4fef:	call   4ff4 <botlish_fn_13+0x86c>
			4ff0: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4ff4:	jmp    52d4 <botlish_fn_13+0xb4c>
    4ff9:	mov    0x18(%r12),%rax
    4ffe:	test   %rax,%rax
    5001:	je     538a <botlish_fn_13+0xc02>
    5007:	mov    0x10(%r12),%rax
    500c:	mov    %rcx,(%rax)
    500f:	mov    %r15,0xc8(%rsp)
    5017:	jmp    4c27 <botlish_fn_13+0x49f>
    501c:	mov    0x108(%rsp),%rsi
    5024:	mov    0xc0(%rsp),%rdi
    502c:	call   5031 <botlish_fn_13+0x8a9>
			502d: R_X86_64_PLT32	rt_co_release-0x4
    5031:	mov    0xd8(%rsp),%rsi
    5039:	mov    0xc0(%rsp),%rdi
    5041:	call   5046 <botlish_fn_13+0x8be>
			5042: R_X86_64_PLT32	rt_co_release-0x4
    5046:	mov    0xc0(%rsp),%rdi
    504e:	mov    0x10(%rdi),%rdx
    5052:	mov    0x118(%rdx),%rdx
    5059:	lea    0x80(%rsp),%r9
    5061:	mov    %r14,0x80(%rsp)
    5069:	mov    %r15,0x88(%rsp)
    5071:	mov    $0x8,%esi
    5076:	mov    $0x3,%ecx
    507b:	mov    $0x2,%r8d
    5081:	call   5086 <botlish_fn_13+0x8fe>
			5082: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5086:	jmp    52d4 <botlish_fn_13+0xb4c>
    508b:	mov    0xc8(%rsp),%r15
    5093:	mov    0xd8(%rsp),%rsi
    509b:	mov    0xc0(%rsp),%rdi
    50a3:	call   50a8 <botlish_fn_13+0x920>
			50a4: R_X86_64_PLT32	rt_co_release-0x4
    50a8:	movq   $0x1,0x30(%rsp)
    50b1:	mov    0xf8(%rsp),%r14
    50b9:	mov    0x10(%r14),%rdi
    50bd:	mov    (%rdi),%rsi
    50c0:	mov    %rsi,0x38(%rsp)
    50c5:	movq   $0x3,0x40(%rsp)
    50ce:	test   $0x1,%rsi
    50d5:	je     50ed <botlish_fn_13+0x965>
    50db:	mov    %rsi,%rcx
    50de:	add    $0x2,%rcx
    50e2:	seto   %al
    50e5:	test   %al,%al
    50e7:	je     5102 <botlish_fn_13+0x97a>
    50ed:	mov    $0x3,%edx
    50f2:	mov    0xc0(%rsp),%rdi
    50fa:	call   50ff <botlish_fn_13+0x977>
			50fb: R_X86_64_PLT32	rt_int_add-0x4
    50ff:	mov    %rax,%rcx
    5102:	mov    0x18(%r14),%rax
    5106:	test   %rax,%rax
    5109:	je     53a4 <botlish_fn_13+0xc1c>
    510f:	mov    0x10(%r14),%rax
    5113:	mov    %rcx,(%rax)
    5116:	mov    %r15,0xc8(%rsp)
    511e:	mov    %r14,0xf8(%rsp)
    5126:	mov    %rbx,0x100(%rsp)
    512e:	jmp    49d8 <botlish_fn_13+0x250>
    5133:	mov    0x100(%rsp),%rbx
    513b:	mov    0xf8(%rsp),%r14
    5143:	mov    0x108(%rsp),%rsi
    514b:	mov    0xc0(%rsp),%rdi
    5153:	call   5158 <botlish_fn_13+0x9d0>
			5154: R_X86_64_PLT32	rt_co_release-0x4
    5158:	mov    0x10(%r14),%rax
    515c:	mov    (%rax),%rax
    515f:	mov    %rax,(%rsp)
    5163:	mov    0x10(%rbx),%rcx
    5167:	mov    (%rcx),%rdx
    516a:	mov    %rdx,0x8(%rsp)
    516f:	lea    0xb0(%rsp),%rcx
    5177:	mov    %rax,0xb0(%rsp)
    517f:	mov    %rdx,0xb8(%rsp)
    5187:	xor    %rsi,%rsi
    518a:	mov    $0x2,%edx
    518f:	mov    0xc0(%rsp),%rdi
    5197:	call   519c <botlish_fn_13+0xa14>
			5198: R_X86_64_PLT32	rt_struct_new-0x4
    519c:	mov    0x110(%rsp),%rbx
    51a4:	mov    0x118(%rsp),%r12
    51ac:	mov    0x120(%rsp),%r13
    51b4:	mov    0x128(%rsp),%r14
    51bc:	mov    0x130(%rsp),%r15
    51c4:	add    $0x140,%rsp
    51cb:	mov    %rbp,%rsp
    51ce:	pop    %rbp
    51cf:	ret
    51d0:	mov    0x100(%rsp),%rbx
    51d8:	mov    0xf8(%rsp),%r14
    51e0:	mov    0xc8(%rsp),%r15
    51e8:	movq   $0x1,0x30(%rsp)
    51f1:	mov    0x10(%rbx),%rax
    51f5:	mov    (%rax),%rsi
    51f8:	mov    %rsi,0x38(%rsp)
    51fd:	movq   $0x3,0x40(%rsp)
    5206:	test   $0x1,%rsi
    520d:	je     5225 <botlish_fn_13+0xa9d>
    5213:	mov    %rsi,%rcx
    5216:	add    $0x2,%rcx
    521a:	seto   %al
    521d:	test   %al,%al
    521f:	je     523a <botlish_fn_13+0xab2>
    5225:	mov    $0x3,%edx
    522a:	mov    0xc0(%rsp),%rdi
    5232:	call   5237 <botlish_fn_13+0xaaf>
			5233: R_X86_64_PLT32	rt_int_add-0x4
    5237:	mov    %rax,%rcx
    523a:	mov    0x18(%rbx),%rax
    523e:	test   %rax,%rax
    5241:	je     53be <botlish_fn_13+0xc36>
    5247:	mov    0x10(%rbx),%rax
    524b:	mov    %rcx,(%rax)
    524e:	movq   $0x1,0x30(%rsp)
    5257:	mov    0x108(%rsp),%rsi
    525f:	mov    0xc0(%rsp),%rdi
    5267:	call   526c <botlish_fn_13+0xae4>
			5268: R_X86_64_PLT32	rt_co_resume0-0x4
    526c:	test   %rax,%rax
    526f:	mov    %rax,%rcx
    5272:	jne    530b <botlish_fn_13+0xb83>
    5278:	mov    0xc0(%rsp),%rdi
    5280:	call   5285 <botlish_fn_13+0xafd>
			5281: R_X86_64_PLT32	rt_declared_error-0x4
    5285:	cmp    $0x40000001,%rax
    528b:	jne    52a6 <botlish_fn_13+0xb1e>
    5291:	mov    0x108(%rsp),%rsi
    5299:	mov    0xc0(%rsp),%rdi
    52a1:	call   52a6 <botlish_fn_13+0xb1e>
			52a2: R_X86_64_PLT32	rt_co_release-0x4
    52a6:	mov    0xc0(%rsp),%rdi
    52ae:	call   52b3 <botlish_fn_13+0xb2b>
			52af: R_X86_64_PLT32	rt_declared_error-0x4
    52b3:	cmp    $0x40000001,%rax
    52b9:	jne    52d4 <botlish_fn_13+0xb4c>
    52bf:	mov    0x108(%rsp),%rsi
    52c7:	mov    0xc0(%rsp),%rdi
    52cf:	call   52d4 <botlish_fn_13+0xb4c>
			52d0: R_X86_64_PLT32	rt_co_release-0x4
    52d4:	xor    %rax,%rax
    52d7:	mov    0x110(%rsp),%rbx
    52df:	mov    0x118(%rsp),%r12
    52e7:	mov    0x120(%rsp),%r13
    52ef:	mov    0x128(%rsp),%r14
    52f7:	mov    0x130(%rsp),%r15
    52ff:	add    $0x140,%rsp
    5306:	mov    %rbp,%rsp
    5309:	pop    %rbp
    530a:	ret
    530b:	mov    0x18(%r13),%rax
    530f:	test   %rax,%rax
    5312:	je     53d8 <botlish_fn_13+0xc50>
    5318:	mov    0x10(%r13),%rdx
    531c:	mov    %rcx,(%rdx)
    531f:	mov    %r15,0xc8(%rsp)
    5327:	mov    %r14,0xf8(%rsp)
    532f:	mov    %rbx,0x100(%rsp)
    5337:	jmp    49d8 <botlish_fn_13+0x250>
    533c:	mov    $0x1,%edx
    5341:	mov    %r12,%rsi
    5344:	mov    0xc0(%rsp),%rdi
    534c:	call   5351 <botlish_fn_13+0xbc9>
			534d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5351:	jmp    4c27 <botlish_fn_13+0x49f>
    5356:	mov    $0x1,%edx
    535b:	mov    %rbx,%rsi
    535e:	mov    0xc0(%rsp),%rdi
    5366:	call   536b <botlish_fn_13+0xbe3>
			5367: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    536b:	jmp    4c9f <botlish_fn_13+0x517>
    5370:	mov    $0x1,%edx
    5375:	mov    %r13,%rsi
    5378:	mov    0xc0(%rsp),%rdi
    5380:	call   5385 <botlish_fn_13+0xbfd>
			5381: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5385:	jmp    4d68 <botlish_fn_13+0x5e0>
    538a:	mov    $0x1,%edx
    538f:	mov    %r12,%rsi
    5392:	mov    0xc0(%rsp),%rdi
    539a:	call   539f <botlish_fn_13+0xc17>
			539b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    539f:	jmp    500f <botlish_fn_13+0x887>
    53a4:	mov    $0x1,%edx
    53a9:	mov    %r14,%rsi
    53ac:	mov    0xc0(%rsp),%rdi
    53b4:	call   53b9 <botlish_fn_13+0xc31>
			53b5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    53b9:	jmp    5116 <botlish_fn_13+0x98e>
    53be:	mov    $0x1,%edx
    53c3:	mov    %rbx,%rsi
    53c6:	mov    0xc0(%rsp),%rdi
    53ce:	call   53d3 <botlish_fn_13+0xc4b>
			53cf: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    53d3:	jmp    524e <botlish_fn_13+0xac6>
    53d8:	mov    $0x1,%edx
    53dd:	mov    %r13,%rsi
    53e0:	mov    0xc0(%rsp),%rdi
    53e8:	call   53ed <botlish_fn_13+0xc65>
			53e9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    53ed:	jmp    531f <botlish_fn_13+0xb97>
    53f2:	add    %al,(%rax)
    53f4:	add    %al,(%rax)
    53f6:	add    %al,(%rax)
    53f8:	(bad)
    53f9:	add    %al,(%rax)
    53fb:	add    %al,(%rax)
    53fd:	add    %al,(%rax)
	...

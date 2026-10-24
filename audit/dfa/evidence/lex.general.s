<botlish_fn_13>:
    4698:	push   %rbp
    4699:	mov    %rsp,%rbp
    469c:	sub    $0x140,%rsp
    46a3:	mov    %rbx,0x110(%rsp)
    46ab:	mov    %r12,0x118(%rsp)
    46b3:	mov    %r13,0x120(%rsp)
    46bb:	mov    %r14,0x128(%rsp)
    46c3:	mov    %r15,0x130(%rsp)
    46cb:	mov    %rdi,0xc0(%rsp)
    46d3:	movq   $0x0,0x10(%rsp)
    46dc:	movq   $0x0,0x18(%rsp)
    46e5:	movq   $0x0,0x20(%rsp)
    46ee:	movq   $0x0,0x28(%rsp)
    46f7:	movq   $0x0,0x30(%rsp)
    4700:	movq   $0x0,0x38(%rsp)
    4709:	movq   $0x0,0x40(%rsp)
    4712:	movq   $0x0,0x48(%rsp)
    471b:	movq   $0x0,0x50(%rsp)
    4724:	mov    %rsi,(%rsp)
    4728:	mov    %rdx,0x8(%rsp)
    472d:	mov    %rdx,0xc8(%rsp)
    4735:	lea    0x58(%rsp),%r8
    473a:	mov    %rsi,0x58(%rsp)
    473f:	mov    $0xe,%esi
    4744:	mov    0x0(%rip),%rdx        # 474b <botlish_fn_13+0xb3>
			4747: R_X86_64_GOTPCREL	botlish_entry_14-0x4
    474b:	mov    $0x1,%ecx
    4750:	mov    0xc0(%rsp),%rdi
    4758:	call   475d <botlish_fn_13+0xc5>
			4759: R_X86_64_PLT32	rt_closure_new-0x4
    475d:	mov    %rax,(%rsp)
    4761:	mov    %rax,%rsi
    4764:	mov    0xc0(%rsp),%rdi
    476c:	call   4771 <botlish_fn_13+0xd9>
			476d: R_X86_64_PLT32	rt_co_create-0x4
    4771:	mov    %rax,0x108(%rsp)
    4779:	mov    %rax,(%rsp)
    477d:	mov    0x108(%rsp),%rsi
    4785:	mov    0xc0(%rsp),%rdi
    478d:	call   4792 <botlish_fn_13+0xfa>
			478e: R_X86_64_PLT32	rt_co_start-0x4
    4792:	test   %rax,%rax
    4795:	jne    47ce <botlish_fn_13+0x136>
    479b:	mov    0xc0(%rsp),%rdi
    47a3:	call   47a8 <botlish_fn_13+0x110>
			47a4: R_X86_64_PLT32	rt_declared_error-0x4
    47a8:	cmp    $0x40000001,%rax
    47ae:	jne    51e4 <botlish_fn_13+0xb4c>
    47b4:	mov    0x108(%rsp),%rsi
    47bc:	mov    0xc0(%rsp),%rdi
    47c4:	call   47c9 <botlish_fn_13+0x131>
			47c5: R_X86_64_PLT32	rt_co_release-0x4
    47c9:	jmp    51e4 <botlish_fn_13+0xb4c>
    47ce:	mov    %rax,0x10(%rsp)
    47d3:	mov    %rax,%rdx
    47d6:	mov    $0x3,%esi
    47db:	movq   $0x3,0x18(%rsp)
    47e4:	mov    0xc0(%rsp),%rdi
    47ec:	call   47f1 <botlish_fn_13+0x159>
			47ed: R_X86_64_PLT32	rt_mutarray_create-0x4
    47f1:	test   %rax,%rax
    47f4:	je     51e4 <botlish_fn_13+0xb4c>
    47fa:	mov    %rax,0x10(%rsp)
    47ff:	mov    %rax,%r13
    4802:	mov    $0x3,%esi
    4807:	movq   $0x3,0x18(%rsp)
    4810:	mov    $0x1,%edx
    4815:	movq   $0x1,0x20(%rsp)
    481e:	mov    0xc0(%rsp),%rdi
    4826:	call   482b <botlish_fn_13+0x193>
			4827: R_X86_64_PLT32	rt_mutarray_create-0x4
    482b:	test   %rax,%rax
    482e:	je     51e4 <botlish_fn_13+0xb4c>
    4834:	mov    %rax,0x18(%rsp)
    4839:	mov    %rax,0x100(%rsp)
    4841:	mov    $0x3,%esi
    4846:	movq   $0x3,0x20(%rsp)
    484f:	mov    $0x1,%edx
    4854:	movq   $0x1,0x28(%rsp)
    485d:	mov    0xc0(%rsp),%rdi
    4865:	call   486a <botlish_fn_13+0x1d2>
			4866: R_X86_64_PLT32	rt_mutarray_create-0x4
    486a:	mov    %rax,%rcx
    486d:	test   %rcx,%rcx
    4870:	je     51e4 <botlish_fn_13+0xb4c>
    4876:	mov    %rcx,0x20(%rsp)
    487b:	mov    %rcx,0xf8(%rsp)
    4883:	mov    $0x3,%esi
    4888:	movq   $0x3,0x28(%rsp)
    4891:	mov    $0x2,%edx
    4896:	movq   $0x2,0x30(%rsp)
    489f:	mov    0xc0(%rsp),%rdi
    48a7:	call   48ac <botlish_fn_13+0x214>
			48a8: R_X86_64_PLT32	rt_mutarray_create-0x4
    48ac:	mov    %rax,%r12
    48af:	test   %r12,%r12
    48b2:	je     51e4 <botlish_fn_13+0xb4c>
    48b8:	mov    %r12,0x28(%rsp)
    48bd:	mov    $0xffffffffffffffff,%r14
    48c4:	mov    %r14,0xf0(%rsp)
    48cc:	lea    0x60(%rsp),%r15
    48d1:	mov    %r15,0xe8(%rsp)
    48d9:	mov    0x0(%rip),%rbx        # 48e0 <botlish_fn_13+0x248>
			48dc: R_X86_64_GOTPCREL	botlish_entry_15-0x4
    48e0:	mov    %rbx,0xe0(%rsp)
    48e8:	mov    0x10(%r13),%rdx
    48ec:	mov    (%rdx),%r15
    48ef:	mov    %r15,0x30(%rsp)
    48f4:	mov    %r15,%rsi
    48f7:	mov    0xc0(%rsp),%rdi
    48ff:	call   4904 <botlish_fn_13+0x26c>
			4900: R_X86_64_PLT32	botlish_fn_11-0x4
    4904:	cmp    $0x6,%rax
    4908:	je     50e0 <botlish_fn_13+0xa48>
    490e:	test   $0x1,%r15
    4915:	jne    4948 <botlish_fn_13+0x2b0>
    491b:	mov    0xf0(%rsp),%rdx
    4923:	mov    %r15,%rsi
    4926:	mov    0xc0(%rsp),%rdi
    492e:	call   4933 <botlish_fn_13+0x29b>
			492f: R_X86_64_PLT32	rt_int_cmp-0x4
    4933:	mov    $0x2,%ecx
    4938:	test   %rax,%rax
    493b:	cmove  0x9c5(%rip),%rcx        # 5308 <botlish_fn_13+0xc70>
    4943:	jmp    4959 <botlish_fn_13+0x2c1>
    4948:	mov    $0x2,%ecx
    494d:	cmp    $0xffffffffffffffff,%r15
    4951:	cmove  0x9af(%rip),%rcx        # 5308 <botlish_fn_13+0xc70>
    4959:	cmp    $0x6,%rcx
    495d:	je     5043 <botlish_fn_13+0x9ab>
    4963:	mov    0x100(%rsp),%rbx
    496b:	mov    0x10(%rbx),%rax
    496f:	mov    (%rax),%r14
    4972:	mov    %r14,0x38(%rsp)
    4977:	mov    %r15,0x60(%rsp)
    497c:	mov    $0xf,%esi
    4981:	mov    $0x1,%ecx
    4986:	mov    0xe0(%rsp),%rdx
    498e:	mov    0xc0(%rsp),%rdi
    4996:	mov    0xe8(%rsp),%r8
    499e:	call   49a3 <botlish_fn_13+0x30b>
			499f: R_X86_64_PLT32	rt_closure_new-0x4
    49a3:	mov    %rax,0x30(%rsp)
    49a8:	mov    %rax,%rsi
    49ab:	mov    0xc0(%rsp),%rdi
    49b3:	call   49b8 <botlish_fn_13+0x320>
			49b4: R_X86_64_PLT32	rt_co_create-0x4
    49b8:	mov    %rax,0xd8(%rsp)
    49c0:	mov    %rax,0x30(%rsp)
    49c5:	mov    0xd8(%rsp),%rsi
    49cd:	mov    0xc0(%rsp),%rdi
    49d5:	call   49da <botlish_fn_13+0x342>
			49d6: R_X86_64_PLT32	rt_co_start-0x4
    49da:	test   %rax,%rax
    49dd:	mov    %rax,%rcx
    49e0:	jne    4b21 <botlish_fn_13+0x489>
    49e6:	mov    0xc0(%rsp),%rdi
    49ee:	call   49f3 <botlish_fn_13+0x35b>
			49ef: R_X86_64_PLT32	rt_declared_error-0x4
    49f3:	cmp    $0x1,%rax
    49f7:	je     4a98 <botlish_fn_13+0x400>
    49fd:	mov    0xc0(%rsp),%rdi
    4a05:	call   4a0a <botlish_fn_13+0x372>
			4a06: R_X86_64_PLT32	rt_declared_error-0x4
    4a0a:	cmp    $0x2,%rax
    4a0e:	jne    51e4 <botlish_fn_13+0xb4c>
    4a14:	xor    %rsi,%rsi
    4a17:	mov    0xc0(%rsp),%rdi
    4a1f:	call   4a24 <botlish_fn_13+0x38c>
			4a20: R_X86_64_PLT32	rt_declared_payload-0x4
    4a24:	mov    %rax,%rbx
    4a27:	mov    0xc0(%rsp),%rdi
    4a2f:	call   4a34 <botlish_fn_13+0x39c>
			4a30: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4a34:	mov    0x108(%rsp),%rsi
    4a3c:	mov    0xc0(%rsp),%rdi
    4a44:	call   4a49 <botlish_fn_13+0x3b1>
			4a45: R_X86_64_PLT32	rt_co_release-0x4
    4a49:	mov    0xd8(%rsp),%rsi
    4a51:	mov    0xc0(%rsp),%rdi
    4a59:	call   4a5e <botlish_fn_13+0x3c6>
			4a5a: R_X86_64_PLT32	rt_co_release-0x4
    4a5e:	mov    0xc0(%rsp),%rdi
    4a66:	mov    0x10(%rdi),%rax
    4a6a:	mov    0x110(%rax),%rdx
    4a71:	lea    0x78(%rsp),%r9
    4a76:	mov    %rbx,%rax
    4a79:	mov    %rax,0x78(%rsp)
    4a7e:	mov    $0x5,%esi
    4a83:	mov    $0x2,%ecx
    4a88:	mov    $0x1,%r8d
    4a8e:	call   4a93 <botlish_fn_13+0x3fb>
			4a8f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4a93:	jmp    51e4 <botlish_fn_13+0xb4c>
    4a98:	xor    %rsi,%rsi
    4a9b:	mov    0xc0(%rsp),%rdi
    4aa3:	call   4aa8 <botlish_fn_13+0x410>
			4aa4: R_X86_64_PLT32	rt_declared_payload-0x4
    4aa8:	mov    %rax,%rbx
    4aab:	mov    0xc0(%rsp),%rdi
    4ab3:	call   4ab8 <botlish_fn_13+0x420>
			4ab4: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4ab8:	mov    0x108(%rsp),%rsi
    4ac0:	mov    0xc0(%rsp),%rdi
    4ac8:	call   4acd <botlish_fn_13+0x435>
			4ac9: R_X86_64_PLT32	rt_co_release-0x4
    4acd:	mov    0xd8(%rsp),%rsi
    4ad5:	mov    0xc0(%rsp),%rdi
    4add:	call   4ae2 <botlish_fn_13+0x44a>
			4ade: R_X86_64_PLT32	rt_co_release-0x4
    4ae2:	mov    0xc0(%rsp),%rdi
    4aea:	mov    0x10(%rdi),%rax
    4aee:	mov    0x108(%rax),%rdx
    4af5:	lea    0x68(%rsp),%r9
    4afa:	mov    %r14,0x68(%rsp)
    4aff:	mov    %rbx,%rax
    4b02:	mov    %rax,0x70(%rsp)
    4b07:	mov    $0x4,%esi
    4b0c:	mov    $0x1,%ecx
    4b11:	mov    $0x2,%r8d
    4b17:	call   4b1c <botlish_fn_13+0x484>
			4b18: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4b1c:	jmp    51e4 <botlish_fn_13+0xb4c>
    4b21:	mov    0x18(%r12),%rax
    4b26:	test   %rax,%rax
    4b29:	je     524c <botlish_fn_13+0xbb4>
    4b2f:	mov    0x10(%r12),%rax
    4b34:	mov    %rcx,(%rax)
    4b37:	mov    0x10(%r12),%rax
    4b3c:	mov    (%rax),%rax
    4b3f:	cmp    $0x6,%rax
    4b43:	jne    4c78 <botlish_fn_13+0x5e0>
    4b49:	movq   $0x1,0x40(%rsp)
    4b52:	mov    0x10(%rbx),%rax
    4b56:	mov    (%rax),%rsi
    4b59:	mov    %rsi,0x48(%rsp)
    4b5e:	movq   $0x3,0x50(%rsp)
    4b67:	test   $0x1,%rsi
    4b6e:	je     4b86 <botlish_fn_13+0x4ee>
    4b74:	mov    %rsi,%rcx
    4b77:	add    $0x2,%rcx
    4b7b:	seto   %al
    4b7e:	test   %al,%al
    4b80:	je     4b9b <botlish_fn_13+0x503>
    4b86:	mov    $0x3,%edx
    4b8b:	mov    0xc0(%rsp),%rdi
    4b93:	call   4b98 <botlish_fn_13+0x500>
			4b94: R_X86_64_PLT32	rt_int_add-0x4
    4b98:	mov    %rax,%rcx
    4b9b:	mov    0x18(%rbx),%rax
    4b9f:	test   %rax,%rax
    4ba2:	je     5266 <botlish_fn_13+0xbce>
    4ba8:	mov    0x10(%rbx),%rax
    4bac:	mov    %rcx,(%rax)
    4baf:	movq   $0x1,0x40(%rsp)
    4bb8:	mov    0x108(%rsp),%rsi
    4bc0:	mov    0xc0(%rsp),%rdi
    4bc8:	call   4bcd <botlish_fn_13+0x535>
			4bc9: R_X86_64_PLT32	rt_co_resume0-0x4
    4bcd:	test   %rax,%rax
    4bd0:	mov    %rax,%rcx
    4bd3:	jne    4c64 <botlish_fn_13+0x5cc>
    4bd9:	mov    0xc0(%rsp),%rdi
    4be1:	call   4be6 <botlish_fn_13+0x54e>
			4be2: R_X86_64_PLT32	rt_declared_error-0x4
    4be6:	cmp    $0x40000001,%rax
    4bec:	jne    4c1c <botlish_fn_13+0x584>
    4bf2:	mov    0x108(%rsp),%rsi
    4bfa:	mov    0xc0(%rsp),%rdi
    4c02:	call   4c07 <botlish_fn_13+0x56f>
			4c03: R_X86_64_PLT32	rt_co_release-0x4
    4c07:	mov    0xd8(%rsp),%rsi
    4c0f:	mov    0xc0(%rsp),%rdi
    4c17:	call   4c1c <botlish_fn_13+0x584>
			4c18: R_X86_64_PLT32	rt_co_release-0x4
    4c1c:	mov    0xc0(%rsp),%rdi
    4c24:	call   4c29 <botlish_fn_13+0x591>
			4c25: R_X86_64_PLT32	rt_declared_error-0x4
    4c29:	cmp    $0x40000001,%rax
    4c2f:	jne    51e4 <botlish_fn_13+0xb4c>
    4c35:	mov    0x108(%rsp),%rsi
    4c3d:	mov    0xc0(%rsp),%rdi
    4c45:	call   4c4a <botlish_fn_13+0x5b2>
			4c46: R_X86_64_PLT32	rt_co_release-0x4
    4c4a:	mov    0xd8(%rsp),%rsi
    4c52:	mov    0xc0(%rsp),%rdi
    4c5a:	call   4c5f <botlish_fn_13+0x5c7>
			4c5b: R_X86_64_PLT32	rt_co_release-0x4
    4c5f:	jmp    51e4 <botlish_fn_13+0xb4c>
    4c64:	mov    0x18(%r13),%rax
    4c68:	test   %rax,%rax
    4c6b:	je     5280 <botlish_fn_13+0xbe8>
    4c71:	mov    0x10(%r13),%rax
    4c75:	mov    %rcx,(%rax)
    4c78:	mov    0xd8(%rsp),%rsi
    4c80:	mov    0xc0(%rsp),%rdi
    4c88:	call   4c8d <botlish_fn_13+0x5f5>
			4c89: R_X86_64_PLT32	rt_co_done-0x4
    4c8d:	cmp    $0x6,%rax
    4c91:	je     4f9b <botlish_fn_13+0x903>
    4c97:	mov    0x10(%rbx),%rax
    4c9b:	mov    (%rax),%rsi
    4c9e:	mov    %rsi,0x40(%rsp)
    4ca3:	mov    %rsi,%rax
    4ca6:	and    %r14,%rax
    4ca9:	test   $0x1,%rax
    4caf:	je     4ce2 <botlish_fn_13+0x64a>
    4cb5:	mov    %rsi,%rcx
    4cb8:	sub    %r14,%rcx
    4cbb:	mov    %rsi,%rdx
    4cbe:	seto   %al
    4cc1:	lea    0x1(%rcx),%rsi
    4cc5:	test   %al,%al
    4cc7:	je     4cd5 <botlish_fn_13+0x63d>
    4ccd:	mov    %rdx,%rsi
    4cd0:	jmp    4ce2 <botlish_fn_13+0x64a>
    4cd5:	mov    0xc8(%rsp),%r15
    4cdd:	jmp    4cfd <botlish_fn_13+0x665>
    4ce2:	mov    %r14,%rdx
    4ce5:	mov    0xc0(%rsp),%rdi
    4ced:	call   4cf2 <botlish_fn_13+0x65a>
			4cee: R_X86_64_PLT32	rt_int_sub-0x4
    4cf2:	mov    %rax,%rsi
    4cf5:	mov    0xc8(%rsp),%r15
    4cfd:	mov    %rsi,%rax
    4d00:	and    %r15,%rax
    4d03:	test   $0x1,%rax
    4d09:	jne    4d34 <botlish_fn_13+0x69c>
    4d0f:	mov    %r15,%rdx
    4d12:	mov    0xc0(%rsp),%rdi
    4d1a:	call   4d1f <botlish_fn_13+0x687>
			4d1b: R_X86_64_PLT32	rt_int_cmp-0x4
    4d1f:	mov    $0x2,%ecx
    4d24:	test   %rax,%rax
    4d27:	cmovge 0x5d9(%rip),%rcx        # 5308 <botlish_fn_13+0xc70>
    4d2f:	jmp    4d44 <botlish_fn_13+0x6ac>
    4d34:	mov    $0x2,%ecx
    4d39:	cmp    %r15,%rsi
    4d3c:	cmovge 0x5c4(%rip),%rcx        # 5308 <botlish_fn_13+0xc70>
    4d44:	cmp    $0x6,%rcx
    4d48:	je     4f2c <botlish_fn_13+0x894>
    4d4e:	mov    0x10(%r13),%rax
    4d52:	mov    (%rax),%rcx
    4d55:	mov    %rcx,0x40(%rsp)
    4d5a:	lea    0x90(%rsp),%rax
    4d62:	mov    %rcx,0x90(%rsp)
    4d6a:	mov    $0x4,%esi
    4d6f:	mov    %rsi,0xd0(%rsp)
    4d77:	mov    $0x1,%edx
    4d7c:	mov    %rax,%rcx
    4d7f:	mov    0xc0(%rsp),%rdi
    4d87:	call   4d8c <botlish_fn_13+0x6f4>
			4d88: R_X86_64_PLT32	rt_struct_new-0x4
    4d8c:	mov    %rax,0x40(%rsp)
    4d91:	mov    %rax,%rdx
    4d94:	mov    0xd8(%rsp),%rsi
    4d9c:	mov    0xc0(%rsp),%rdi
    4da4:	call   4da9 <botlish_fn_13+0x711>
			4da5: R_X86_64_PLT32	rt_co_resume-0x4
    4da9:	test   %rax,%rax
    4dac:	mov    %rax,%rcx
    4daf:	jne    4f09 <botlish_fn_13+0x871>
    4db5:	mov    0xc0(%rsp),%rdi
    4dbd:	call   4dc2 <botlish_fn_13+0x72a>
			4dbe: R_X86_64_PLT32	rt_declared_error-0x4
    4dc2:	cmp    $0x1,%rax
    4dc6:	je     4e6d <botlish_fn_13+0x7d5>
    4dcc:	mov    0xc0(%rsp),%rdi
    4dd4:	call   4dd9 <botlish_fn_13+0x741>
			4dd5: R_X86_64_PLT32	rt_declared_error-0x4
    4dd9:	cmp    $0x2,%rax
    4ddd:	jne    51e4 <botlish_fn_13+0xb4c>
    4de3:	xor    %rsi,%rsi
    4de6:	mov    0xc0(%rsp),%rdi
    4dee:	call   4df3 <botlish_fn_13+0x75b>
			4def: R_X86_64_PLT32	rt_declared_payload-0x4
    4df3:	mov    %rax,%rbx
    4df6:	mov    0xc0(%rsp),%rdi
    4dfe:	call   4e03 <botlish_fn_13+0x76b>
			4dff: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4e03:	mov    0x108(%rsp),%rsi
    4e0b:	mov    0xc0(%rsp),%rdi
    4e13:	call   4e18 <botlish_fn_13+0x780>
			4e14: R_X86_64_PLT32	rt_co_release-0x4
    4e18:	mov    0xd8(%rsp),%rsi
    4e20:	mov    0xc0(%rsp),%rdi
    4e28:	call   4e2d <botlish_fn_13+0x795>
			4e29: R_X86_64_PLT32	rt_co_release-0x4
    4e2d:	mov    0xc0(%rsp),%rdi
    4e35:	mov    0x10(%rdi),%rax
    4e39:	mov    0x110(%rax),%rdx
    4e40:	lea    0xa8(%rsp),%r9
    4e48:	mov    %rbx,%rax
    4e4b:	mov    %rax,0xa8(%rsp)
    4e53:	mov    $0x5,%esi
    4e58:	mov    $0x2,%ecx
    4e5d:	mov    $0x1,%r8d
    4e63:	call   4e68 <botlish_fn_13+0x7d0>
			4e64: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4e68:	jmp    51e4 <botlish_fn_13+0xb4c>
    4e6d:	xor    %rsi,%rsi
    4e70:	mov    0xc0(%rsp),%rdi
    4e78:	call   4e7d <botlish_fn_13+0x7e5>
			4e79: R_X86_64_PLT32	rt_declared_payload-0x4
    4e7d:	mov    %rax,%r12
    4e80:	mov    0xc0(%rsp),%rdi
    4e88:	call   4e8d <botlish_fn_13+0x7f5>
			4e89: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4e8d:	mov    0x108(%rsp),%rsi
    4e95:	mov    0xc0(%rsp),%rdi
    4e9d:	call   4ea2 <botlish_fn_13+0x80a>
			4e9e: R_X86_64_PLT32	rt_co_release-0x4
    4ea2:	mov    0xd8(%rsp),%rsi
    4eaa:	mov    0xc0(%rsp),%rdi
    4eb2:	call   4eb7 <botlish_fn_13+0x81f>
			4eb3: R_X86_64_PLT32	rt_co_release-0x4
    4eb7:	mov    0x10(%rbx),%rax
    4ebb:	mov    (%rax),%rcx
    4ebe:	mov    0xc0(%rsp),%rdi
    4ec6:	mov    0x10(%rdi),%rax
    4eca:	mov    0x108(%rax),%rdx
    4ed1:	lea    0x98(%rsp),%r9
    4ed9:	mov    %rcx,0x98(%rsp)
    4ee1:	mov    %r12,%rax
    4ee4:	mov    %rax,0xa0(%rsp)
    4eec:	mov    $0x1,%ecx
    4ef1:	mov    $0x2,%r8d
    4ef7:	mov    0xd0(%rsp),%rsi
    4eff:	call   4f04 <botlish_fn_13+0x86c>
			4f00: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4f04:	jmp    51e4 <botlish_fn_13+0xb4c>
    4f09:	mov    0x18(%r12),%rax
    4f0e:	test   %rax,%rax
    4f11:	je     529a <botlish_fn_13+0xc02>
    4f17:	mov    0x10(%r12),%rax
    4f1c:	mov    %rcx,(%rax)
    4f1f:	mov    %r15,0xc8(%rsp)
    4f27:	jmp    4b37 <botlish_fn_13+0x49f>
    4f2c:	mov    0x108(%rsp),%rsi
    4f34:	mov    0xc0(%rsp),%rdi
    4f3c:	call   4f41 <botlish_fn_13+0x8a9>
			4f3d: R_X86_64_PLT32	rt_co_release-0x4
    4f41:	mov    0xd8(%rsp),%rsi
    4f49:	mov    0xc0(%rsp),%rdi
    4f51:	call   4f56 <botlish_fn_13+0x8be>
			4f52: R_X86_64_PLT32	rt_co_release-0x4
    4f56:	mov    0xc0(%rsp),%rdi
    4f5e:	mov    0x10(%rdi),%rdx
    4f62:	mov    0x118(%rdx),%rdx
    4f69:	lea    0x80(%rsp),%r9
    4f71:	mov    %r14,0x80(%rsp)
    4f79:	mov    %r15,0x88(%rsp)
    4f81:	mov    $0x8,%esi
    4f86:	mov    $0x3,%ecx
    4f8b:	mov    $0x2,%r8d
    4f91:	call   4f96 <botlish_fn_13+0x8fe>
			4f92: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4f96:	jmp    51e4 <botlish_fn_13+0xb4c>
    4f9b:	mov    0xc8(%rsp),%r15
    4fa3:	mov    0xd8(%rsp),%rsi
    4fab:	mov    0xc0(%rsp),%rdi
    4fb3:	call   4fb8 <botlish_fn_13+0x920>
			4fb4: R_X86_64_PLT32	rt_co_release-0x4
    4fb8:	movq   $0x1,0x30(%rsp)
    4fc1:	mov    0xf8(%rsp),%r14
    4fc9:	mov    0x10(%r14),%rdi
    4fcd:	mov    (%rdi),%rsi
    4fd0:	mov    %rsi,0x38(%rsp)
    4fd5:	movq   $0x3,0x40(%rsp)
    4fde:	test   $0x1,%rsi
    4fe5:	je     4ffd <botlish_fn_13+0x965>
    4feb:	mov    %rsi,%rcx
    4fee:	add    $0x2,%rcx
    4ff2:	seto   %al
    4ff5:	test   %al,%al
    4ff7:	je     5012 <botlish_fn_13+0x97a>
    4ffd:	mov    $0x3,%edx
    5002:	mov    0xc0(%rsp),%rdi
    500a:	call   500f <botlish_fn_13+0x977>
			500b: R_X86_64_PLT32	rt_int_add-0x4
    500f:	mov    %rax,%rcx
    5012:	mov    0x18(%r14),%rax
    5016:	test   %rax,%rax
    5019:	je     52b4 <botlish_fn_13+0xc1c>
    501f:	mov    0x10(%r14),%rax
    5023:	mov    %rcx,(%rax)
    5026:	mov    %r15,0xc8(%rsp)
    502e:	mov    %r14,0xf8(%rsp)
    5036:	mov    %rbx,0x100(%rsp)
    503e:	jmp    48e8 <botlish_fn_13+0x250>
    5043:	mov    0x100(%rsp),%rbx
    504b:	mov    0xf8(%rsp),%r14
    5053:	mov    0x108(%rsp),%rsi
    505b:	mov    0xc0(%rsp),%rdi
    5063:	call   5068 <botlish_fn_13+0x9d0>
			5064: R_X86_64_PLT32	rt_co_release-0x4
    5068:	mov    0x10(%r14),%rax
    506c:	mov    (%rax),%rax
    506f:	mov    %rax,(%rsp)
    5073:	mov    0x10(%rbx),%rcx
    5077:	mov    (%rcx),%rdx
    507a:	mov    %rdx,0x8(%rsp)
    507f:	lea    0xb0(%rsp),%rcx
    5087:	mov    %rax,0xb0(%rsp)
    508f:	mov    %rdx,0xb8(%rsp)
    5097:	xor    %rsi,%rsi
    509a:	mov    $0x2,%edx
    509f:	mov    0xc0(%rsp),%rdi
    50a7:	call   50ac <botlish_fn_13+0xa14>
			50a8: R_X86_64_PLT32	rt_struct_new-0x4
    50ac:	mov    0x110(%rsp),%rbx
    50b4:	mov    0x118(%rsp),%r12
    50bc:	mov    0x120(%rsp),%r13
    50c4:	mov    0x128(%rsp),%r14
    50cc:	mov    0x130(%rsp),%r15
    50d4:	add    $0x140,%rsp
    50db:	mov    %rbp,%rsp
    50de:	pop    %rbp
    50df:	ret
    50e0:	mov    0x100(%rsp),%rbx
    50e8:	mov    0xf8(%rsp),%r14
    50f0:	mov    0xc8(%rsp),%r15
    50f8:	movq   $0x1,0x30(%rsp)
    5101:	mov    0x10(%rbx),%rax
    5105:	mov    (%rax),%rsi
    5108:	mov    %rsi,0x38(%rsp)
    510d:	movq   $0x3,0x40(%rsp)
    5116:	test   $0x1,%rsi
    511d:	je     5135 <botlish_fn_13+0xa9d>
    5123:	mov    %rsi,%rcx
    5126:	add    $0x2,%rcx
    512a:	seto   %al
    512d:	test   %al,%al
    512f:	je     514a <botlish_fn_13+0xab2>
    5135:	mov    $0x3,%edx
    513a:	mov    0xc0(%rsp),%rdi
    5142:	call   5147 <botlish_fn_13+0xaaf>
			5143: R_X86_64_PLT32	rt_int_add-0x4
    5147:	mov    %rax,%rcx
    514a:	mov    0x18(%rbx),%rax
    514e:	test   %rax,%rax
    5151:	je     52ce <botlish_fn_13+0xc36>
    5157:	mov    0x10(%rbx),%rax
    515b:	mov    %rcx,(%rax)
    515e:	movq   $0x1,0x30(%rsp)
    5167:	mov    0x108(%rsp),%rsi
    516f:	mov    0xc0(%rsp),%rdi
    5177:	call   517c <botlish_fn_13+0xae4>
			5178: R_X86_64_PLT32	rt_co_resume0-0x4
    517c:	test   %rax,%rax
    517f:	mov    %rax,%rcx
    5182:	jne    521b <botlish_fn_13+0xb83>
    5188:	mov    0xc0(%rsp),%rdi
    5190:	call   5195 <botlish_fn_13+0xafd>
			5191: R_X86_64_PLT32	rt_declared_error-0x4
    5195:	cmp    $0x40000001,%rax
    519b:	jne    51b6 <botlish_fn_13+0xb1e>
    51a1:	mov    0x108(%rsp),%rsi
    51a9:	mov    0xc0(%rsp),%rdi
    51b1:	call   51b6 <botlish_fn_13+0xb1e>
			51b2: R_X86_64_PLT32	rt_co_release-0x4
    51b6:	mov    0xc0(%rsp),%rdi
    51be:	call   51c3 <botlish_fn_13+0xb2b>
			51bf: R_X86_64_PLT32	rt_declared_error-0x4
    51c3:	cmp    $0x40000001,%rax
    51c9:	jne    51e4 <botlish_fn_13+0xb4c>
    51cf:	mov    0x108(%rsp),%rsi
    51d7:	mov    0xc0(%rsp),%rdi
    51df:	call   51e4 <botlish_fn_13+0xb4c>
			51e0: R_X86_64_PLT32	rt_co_release-0x4
    51e4:	xor    %rax,%rax
    51e7:	mov    0x110(%rsp),%rbx
    51ef:	mov    0x118(%rsp),%r12
    51f7:	mov    0x120(%rsp),%r13
    51ff:	mov    0x128(%rsp),%r14
    5207:	mov    0x130(%rsp),%r15
    520f:	add    $0x140,%rsp
    5216:	mov    %rbp,%rsp
    5219:	pop    %rbp
    521a:	ret
    521b:	mov    0x18(%r13),%rax
    521f:	test   %rax,%rax
    5222:	je     52e8 <botlish_fn_13+0xc50>
    5228:	mov    0x10(%r13),%rdx
    522c:	mov    %rcx,(%rdx)
    522f:	mov    %r15,0xc8(%rsp)
    5237:	mov    %r14,0xf8(%rsp)
    523f:	mov    %rbx,0x100(%rsp)
    5247:	jmp    48e8 <botlish_fn_13+0x250>
    524c:	mov    $0x1,%edx
    5251:	mov    %r12,%rsi
    5254:	mov    0xc0(%rsp),%rdi
    525c:	call   5261 <botlish_fn_13+0xbc9>
			525d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5261:	jmp    4b37 <botlish_fn_13+0x49f>
    5266:	mov    $0x1,%edx
    526b:	mov    %rbx,%rsi
    526e:	mov    0xc0(%rsp),%rdi
    5276:	call   527b <botlish_fn_13+0xbe3>
			5277: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    527b:	jmp    4baf <botlish_fn_13+0x517>
    5280:	mov    $0x1,%edx
    5285:	mov    %r13,%rsi
    5288:	mov    0xc0(%rsp),%rdi
    5290:	call   5295 <botlish_fn_13+0xbfd>
			5291: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5295:	jmp    4c78 <botlish_fn_13+0x5e0>
    529a:	mov    $0x1,%edx
    529f:	mov    %r12,%rsi
    52a2:	mov    0xc0(%rsp),%rdi
    52aa:	call   52af <botlish_fn_13+0xc17>
			52ab: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    52af:	jmp    4f1f <botlish_fn_13+0x887>
    52b4:	mov    $0x1,%edx
    52b9:	mov    %r14,%rsi
    52bc:	mov    0xc0(%rsp),%rdi
    52c4:	call   52c9 <botlish_fn_13+0xc31>
			52c5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    52c9:	jmp    5026 <botlish_fn_13+0x98e>
    52ce:	mov    $0x1,%edx
    52d3:	mov    %rbx,%rsi
    52d6:	mov    0xc0(%rsp),%rdi
    52de:	call   52e3 <botlish_fn_13+0xc4b>
			52df: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    52e3:	jmp    515e <botlish_fn_13+0xac6>
    52e8:	mov    $0x1,%edx
    52ed:	mov    %r13,%rsi
    52f0:	mov    0xc0(%rsp),%rdi
    52f8:	call   52fd <botlish_fn_13+0xc65>
			52f9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    52fd:	jmp    522f <botlish_fn_13+0xb97>
    5302:	add    %al,(%rax)
    5304:	add    %al,(%rax)
    5306:	add    %al,(%rax)
    5308:	(bad)
    5309:	add    %al,(%rax)
    530b:	add    %al,(%rax)
    530d:	add    %al,(%rax)
	...

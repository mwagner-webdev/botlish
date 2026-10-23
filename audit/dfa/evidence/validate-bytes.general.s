<botlish_fn_19>:
    6618:	push   %rbp
    6619:	mov    %rsp,%rbp
    661c:	sub    $0x1a0,%rsp
    6623:	mov    %rbx,0x170(%rsp)
    662b:	mov    %r12,0x178(%rsp)
    6633:	mov    %r13,0x180(%rsp)
    663b:	mov    %r14,0x188(%rsp)
    6643:	mov    %r15,0x190(%rsp)
    664b:	mov    %rdi,0x108(%rsp)
    6653:	movq   $0x0,0x18(%rsp)
    665c:	movq   $0x0,0x20(%rsp)
    6665:	movq   $0x0,0x28(%rsp)
    666e:	movq   $0x0,0x30(%rsp)
    6677:	movq   $0x0,0x38(%rsp)
    6680:	movq   $0x0,0x40(%rsp)
    6689:	movq   $0x0,0x48(%rsp)
    6692:	movq   $0x0,0x50(%rsp)
    669b:	movq   $0x0,0x58(%rsp)
    66a4:	movq   $0x0,0x60(%rsp)
    66ad:	mov    %rsi,(%rsp)
    66b1:	mov    %rdx,0x8(%rsp)
    66b6:	mov    %rdx,%r12
    66b9:	mov    %rcx,0x10(%rsp)
    66be:	mov    %rcx,0x110(%rsp)
    66c6:	lea    0x68(%rsp),%r8
    66cb:	mov    %rsi,0x68(%rsp)
    66d0:	mov    $0x14,%esi
    66d5:	mov    0x0(%rip),%rdx        # 66dc <botlish_fn_19+0xc4>
			66d8: R_X86_64_GOTPCREL	botlish_entry_20-0x4
    66dc:	mov    $0x1,%ecx
    66e1:	mov    0x108(%rsp),%rdi
    66e9:	call   66ee <botlish_fn_19+0xd6>
			66ea: R_X86_64_PLT32	rt_closure_new-0x4
    66ee:	mov    %rax,(%rsp)
    66f2:	mov    %rax,%rsi
    66f5:	mov    0x108(%rsp),%rdi
    66fd:	call   6702 <botlish_fn_19+0xea>
			66fe: R_X86_64_PLT32	rt_co_create-0x4
    6702:	mov    %rax,0x160(%rsp)
    670a:	mov    %rax,(%rsp)
    670e:	mov    0x160(%rsp),%rsi
    6716:	mov    0x108(%rsp),%rdi
    671e:	call   6723 <botlish_fn_19+0x10b>
			671f: R_X86_64_PLT32	rt_co_start-0x4
    6723:	test   %rax,%rax
    6726:	je     74bd <botlish_fn_19+0xea5>
    672c:	mov    %rax,0x18(%rsp)
    6731:	mov    %rax,%rbx
    6734:	lea    0x70(%rsp),%r8
    6739:	mov    %r12,%rdx
    673c:	mov    %rdx,0x70(%rsp)
    6741:	mov    $0x15,%esi
    6746:	mov    0x0(%rip),%rdx        # 674d <botlish_fn_19+0x135>
			6749: R_X86_64_GOTPCREL	botlish_entry_21-0x4
    674d:	mov    $0x1,%ecx
    6752:	mov    0x108(%rsp),%rdi
    675a:	call   675f <botlish_fn_19+0x147>
			675b: R_X86_64_PLT32	rt_closure_new-0x4
    675f:	mov    %rax,0x8(%rsp)
    6764:	mov    %rax,%rsi
    6767:	mov    0x108(%rsp),%rdi
    676f:	call   6774 <botlish_fn_19+0x15c>
			6770: R_X86_64_PLT32	rt_co_create-0x4
    6774:	mov    %rax,0x158(%rsp)
    677c:	mov    %rax,0x8(%rsp)
    6781:	mov    0x158(%rsp),%rsi
    6789:	mov    0x108(%rsp),%rdi
    6791:	call   6796 <botlish_fn_19+0x17e>
			6792: R_X86_64_PLT32	rt_co_start-0x4
    6796:	test   %rax,%rax
    6799:	jne    682b <botlish_fn_19+0x213>
    679f:	mov    0x108(%rsp),%rdi
    67a7:	call   67ac <botlish_fn_19+0x194>
			67a8: R_X86_64_PLT32	rt_declared_error-0x4
    67ac:	cmp    $0x6,%rax
    67b0:	je     67fc <botlish_fn_19+0x1e4>
    67b6:	mov    0x108(%rsp),%rdi
    67be:	call   67c3 <botlish_fn_19+0x1ab>
			67bf: R_X86_64_PLT32	rt_declared_error-0x4
    67c3:	cmp    $0x7,%rax
    67c7:	jne    74bd <botlish_fn_19+0xea5>
    67cd:	mov    0x160(%rsp),%rsi
    67d5:	mov    0x108(%rsp),%rdi
    67dd:	call   67e2 <botlish_fn_19+0x1ca>
			67de: R_X86_64_PLT32	rt_co_release-0x4
    67e2:	mov    0x158(%rsp),%rsi
    67ea:	mov    0x108(%rsp),%rdi
    67f2:	call   67f7 <botlish_fn_19+0x1df>
			67f3: R_X86_64_PLT32	rt_co_release-0x4
    67f7:	jmp    74bd <botlish_fn_19+0xea5>
    67fc:	mov    0x160(%rsp),%rsi
    6804:	mov    0x108(%rsp),%rdi
    680c:	call   6811 <botlish_fn_19+0x1f9>
			680d: R_X86_64_PLT32	rt_co_release-0x4
    6811:	mov    0x158(%rsp),%rsi
    6819:	mov    0x108(%rsp),%rdi
    6821:	call   6826 <botlish_fn_19+0x20e>
			6822: R_X86_64_PLT32	rt_co_release-0x4
    6826:	jmp    74bd <botlish_fn_19+0xea5>
    682b:	mov    $0x3,%esi
    6830:	movq   $0x3,0x20(%rsp)
    6839:	mov    %rbx,%rdx
    683c:	mov    0x108(%rsp),%rdi
    6844:	call   6849 <botlish_fn_19+0x231>
			6845: R_X86_64_PLT32	rt_mutarray_create-0x4
    6849:	test   %rax,%rax
    684c:	je     74bd <botlish_fn_19+0xea5>
    6852:	mov    %rax,0x18(%rsp)
    6857:	mov    %rax,%r13
    685a:	mov    $0x3,%esi
    685f:	movq   $0x3,0x20(%rsp)
    6868:	mov    $0x1,%edx
    686d:	movq   $0x1,0x28(%rsp)
    6876:	mov    0x108(%rsp),%rdi
    687e:	call   6883 <botlish_fn_19+0x26b>
			687f: R_X86_64_PLT32	rt_mutarray_create-0x4
    6883:	test   %rax,%rax
    6886:	je     74bd <botlish_fn_19+0xea5>
    688c:	mov    %rax,0x20(%rsp)
    6891:	mov    %rax,0x150(%rsp)
    6899:	mov    $0x3,%esi
    689e:	movq   $0x3,0x28(%rsp)
    68a7:	mov    $0x1,%edx
    68ac:	movq   $0x1,0x30(%rsp)
    68b5:	mov    0x108(%rsp),%rdi
    68bd:	call   68c2 <botlish_fn_19+0x2aa>
			68be: R_X86_64_PLT32	rt_mutarray_create-0x4
    68c2:	mov    %rax,%rcx
    68c5:	test   %rcx,%rcx
    68c8:	je     74bd <botlish_fn_19+0xea5>
    68ce:	mov    %rcx,0x28(%rsp)
    68d3:	mov    %rcx,0x148(%rsp)
    68db:	mov    $0x3,%esi
    68e0:	movq   $0x3,0x30(%rsp)
    68e9:	mov    $0x2,%edx
    68ee:	movq   $0x2,0x38(%rsp)
    68f7:	mov    0x108(%rsp),%rdi
    68ff:	call   6904 <botlish_fn_19+0x2ec>
			6900: R_X86_64_PLT32	rt_mutarray_create-0x4
    6904:	mov    %rax,%r12
    6907:	test   %r12,%r12
    690a:	je     74bd <botlish_fn_19+0xea5>
    6910:	mov    %r12,0x30(%rsp)
    6915:	mov    $0xffffffffffffffff,%r14
    691c:	mov    %r14,0x140(%rsp)
    6924:	lea    0x90(%rsp),%r15
    692c:	mov    %r15,0x138(%rsp)
    6934:	mov    0x0(%rip),%rbx        # 693b <botlish_fn_19+0x323>
			6937: R_X86_64_GOTPCREL	botlish_entry_22-0x4
    693b:	mov    %rbx,0x130(%rsp)
    6943:	mov    0x10(%r13),%rax
    6947:	mov    (%rax),%rsi
    694a:	mov    %rsi,0x38(%rsp)
    694f:	mov    %rsi,0x128(%rsp)
    6957:	mov    0x128(%rsp),%rsi
    695f:	mov    0x108(%rsp),%rdi
    6967:	call   696c <botlish_fn_19+0x354>
			6968: R_X86_64_PLT32	botlish_fn_13-0x4
    696c:	cmp    $0x6,%rax
    6970:	je     73da <botlish_fn_19+0xdc2>
    6976:	mov    0x150(%rsp),%rbx
    697e:	mov    0x10(%rbx),%rax
    6982:	mov    (%rax),%r14
    6985:	mov    %r14,0x40(%rsp)
    698a:	mov    0x128(%rsp),%rsi
    6992:	test   $0x1,%rsi
    6999:	jne    69d1 <botlish_fn_19+0x3b9>
    699f:	mov    0x140(%rsp),%rdx
    69a7:	mov    0x128(%rsp),%rsi
    69af:	mov    0x108(%rsp),%rdi
    69b7:	call   69bc <botlish_fn_19+0x3a4>
			69b8: R_X86_64_PLT32	rt_int_cmp-0x4
    69bc:	mov    $0x2,%ecx
    69c1:	test   %rax,%rax
    69c4:	cmove  0xc0c(%rip),%rcx        # 75d8 <botlish_fn_19+0xfc0>
    69cc:	jmp    69ea <botlish_fn_19+0x3d2>
    69d1:	mov    $0x2,%ecx
    69d6:	mov    0x128(%rsp),%rsi
    69de:	cmp    $0xffffffffffffffff,%rsi
    69e2:	cmove  0xbee(%rip),%rcx        # 75d8 <botlish_fn_19+0xfc0>
    69ea:	cmp    $0x6,%rcx
    69ee:	je     7240 <botlish_fn_19+0xc28>
    69f4:	mov    0x128(%rsp),%rsi
    69fc:	mov    %rsi,0x90(%rsp)
    6a04:	mov    $0x16,%esi
    6a09:	mov    $0x1,%ecx
    6a0e:	mov    0x130(%rsp),%rdx
    6a16:	mov    0x108(%rsp),%rdi
    6a1e:	mov    0x138(%rsp),%r8
    6a26:	call   6a2b <botlish_fn_19+0x413>
			6a27: R_X86_64_PLT32	rt_closure_new-0x4
    6a2b:	mov    %rax,0x48(%rsp)
    6a30:	mov    %rax,%rsi
    6a33:	mov    0x108(%rsp),%rdi
    6a3b:	call   6a40 <botlish_fn_19+0x428>
			6a3c: R_X86_64_PLT32	rt_co_create-0x4
    6a40:	mov    %rax,0x120(%rsp)
    6a48:	mov    %rax,0x48(%rsp)
    6a4d:	mov    0x120(%rsp),%rsi
    6a55:	mov    0x108(%rsp),%rdi
    6a5d:	call   6a62 <botlish_fn_19+0x44a>
			6a5e: R_X86_64_PLT32	rt_co_start-0x4
    6a62:	test   %rax,%rax
    6a65:	mov    %rax,%rcx
    6a68:	jne    6be0 <botlish_fn_19+0x5c8>
    6a6e:	mov    0x108(%rsp),%rdi
    6a76:	call   6a7b <botlish_fn_19+0x463>
			6a77: R_X86_64_PLT32	rt_declared_error-0x4
    6a7b:	cmp    $0x1,%rax
    6a7f:	je     6b3b <botlish_fn_19+0x523>
    6a85:	mov    0x108(%rsp),%rdi
    6a8d:	call   6a92 <botlish_fn_19+0x47a>
			6a8e: R_X86_64_PLT32	rt_declared_error-0x4
    6a92:	cmp    $0x2,%rax
    6a96:	jne    74bd <botlish_fn_19+0xea5>
    6a9c:	xor    %rsi,%rsi
    6a9f:	mov    0x108(%rsp),%rdi
    6aa7:	call   6aac <botlish_fn_19+0x494>
			6aa8: R_X86_64_PLT32	rt_declared_payload-0x4
    6aac:	mov    %rax,%rbx
    6aaf:	mov    0x108(%rsp),%rdi
    6ab7:	call   6abc <botlish_fn_19+0x4a4>
			6ab8: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6abc:	mov    0x160(%rsp),%rsi
    6ac4:	mov    0x108(%rsp),%rdi
    6acc:	call   6ad1 <botlish_fn_19+0x4b9>
			6acd: R_X86_64_PLT32	rt_co_release-0x4
    6ad1:	mov    0x158(%rsp),%rsi
    6ad9:	mov    0x108(%rsp),%rdi
    6ae1:	call   6ae6 <botlish_fn_19+0x4ce>
			6ae2: R_X86_64_PLT32	rt_co_release-0x4
    6ae6:	mov    0x120(%rsp),%rsi
    6aee:	mov    0x108(%rsp),%rdi
    6af6:	call   6afb <botlish_fn_19+0x4e3>
			6af7: R_X86_64_PLT32	rt_co_release-0x4
    6afb:	mov    0x108(%rsp),%rdi
    6b03:	mov    0x10(%rdi),%rax
    6b07:	mov    0x1a0(%rax),%rdx
    6b0e:	lea    0xa8(%rsp),%r9
    6b16:	mov    %rbx,%rax
    6b19:	mov    %rax,0xa8(%rsp)
    6b21:	mov    $0x5,%esi
    6b26:	mov    $0x3,%ecx
    6b2b:	mov    $0x1,%r8d
    6b31:	call   6b36 <botlish_fn_19+0x51e>
			6b32: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6b36:	jmp    74bd <botlish_fn_19+0xea5>
    6b3b:	xor    %rsi,%rsi
    6b3e:	mov    0x108(%rsp),%rdi
    6b46:	call   6b4b <botlish_fn_19+0x533>
			6b47: R_X86_64_PLT32	rt_declared_payload-0x4
    6b4b:	mov    %rax,%rbx
    6b4e:	mov    0x108(%rsp),%rdi
    6b56:	call   6b5b <botlish_fn_19+0x543>
			6b57: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6b5b:	mov    0x160(%rsp),%rsi
    6b63:	mov    0x108(%rsp),%rdi
    6b6b:	call   6b70 <botlish_fn_19+0x558>
			6b6c: R_X86_64_PLT32	rt_co_release-0x4
    6b70:	mov    0x158(%rsp),%rsi
    6b78:	mov    0x108(%rsp),%rdi
    6b80:	call   6b85 <botlish_fn_19+0x56d>
			6b81: R_X86_64_PLT32	rt_co_release-0x4
    6b85:	mov    0x120(%rsp),%rsi
    6b8d:	mov    0x108(%rsp),%rdi
    6b95:	call   6b9a <botlish_fn_19+0x582>
			6b96: R_X86_64_PLT32	rt_co_release-0x4
    6b9a:	mov    0x108(%rsp),%rdi
    6ba2:	mov    0x10(%rdi),%rax
    6ba6:	mov    0x198(%rax),%rdx
    6bad:	lea    0x98(%rsp),%r9
    6bb5:	mov    %r14,0x98(%rsp)
    6bbd:	mov    %rbx,%rax
    6bc0:	mov    %rax,0xa0(%rsp)
    6bc8:	mov    $0x4,%esi
    6bcd:	mov    $0x2,%r8d
    6bd3:	mov    %r8,%rcx
    6bd6:	call   6bdb <botlish_fn_19+0x5c3>
			6bd7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6bdb:	jmp    74bd <botlish_fn_19+0xea5>
    6be0:	mov    0x18(%r12),%rax
    6be5:	test   %rax,%rax
    6be8:	je     751d <botlish_fn_19+0xf05>
    6bee:	mov    0x10(%r12),%rax
    6bf3:	mov    %rcx,(%rax)
    6bf6:	mov    0x10(%r12),%rax
    6bfb:	mov    (%rax),%rax
    6bfe:	cmp    $0x6,%rax
    6c02:	jne    6d09 <botlish_fn_19+0x6f1>
    6c08:	movq   $0x1,0x50(%rsp)
    6c11:	mov    0x10(%rbx),%rax
    6c15:	mov    (%rax),%rsi
    6c18:	mov    %rsi,0x58(%rsp)
    6c1d:	movq   $0x3,0x60(%rsp)
    6c26:	test   $0x1,%rsi
    6c2d:	je     6c45 <botlish_fn_19+0x62d>
    6c33:	mov    %rsi,%rcx
    6c36:	add    $0x2,%rcx
    6c3a:	seto   %al
    6c3d:	test   %al,%al
    6c3f:	je     6c5a <botlish_fn_19+0x642>
    6c45:	mov    $0x3,%edx
    6c4a:	mov    0x108(%rsp),%rdi
    6c52:	call   6c57 <botlish_fn_19+0x63f>
			6c53: R_X86_64_PLT32	rt_int_add-0x4
    6c57:	mov    %rax,%rcx
    6c5a:	mov    0x18(%rbx),%rax
    6c5e:	test   %rax,%rax
    6c61:	je     7537 <botlish_fn_19+0xf1f>
    6c67:	mov    0x10(%rbx),%rax
    6c6b:	mov    %rcx,(%rax)
    6c6e:	movq   $0x1,0x50(%rsp)
    6c77:	mov    0x160(%rsp),%rsi
    6c7f:	mov    0x108(%rsp),%rdi
    6c87:	call   6c8c <botlish_fn_19+0x674>
			6c88: R_X86_64_PLT32	rt_co_resume0-0x4
    6c8c:	test   %rax,%rax
    6c8f:	mov    %rax,%rcx
    6c92:	jne    6cf5 <botlish_fn_19+0x6dd>
    6c98:	mov    0x108(%rsp),%rdi
    6ca0:	call   6ca5 <botlish_fn_19+0x68d>
			6ca1: R_X86_64_PLT32	rt_declared_error-0x4
    6ca5:	cmp    $0x40000001,%rax
    6cab:	jne    74bd <botlish_fn_19+0xea5>
    6cb1:	mov    0x160(%rsp),%rsi
    6cb9:	mov    0x108(%rsp),%rdi
    6cc1:	call   6cc6 <botlish_fn_19+0x6ae>
			6cc2: R_X86_64_PLT32	rt_co_release-0x4
    6cc6:	mov    0x158(%rsp),%rsi
    6cce:	mov    0x108(%rsp),%rdi
    6cd6:	call   6cdb <botlish_fn_19+0x6c3>
			6cd7: R_X86_64_PLT32	rt_co_release-0x4
    6cdb:	mov    0x120(%rsp),%rsi
    6ce3:	mov    0x108(%rsp),%rdi
    6ceb:	call   6cf0 <botlish_fn_19+0x6d8>
			6cec: R_X86_64_PLT32	rt_co_release-0x4
    6cf0:	jmp    74bd <botlish_fn_19+0xea5>
    6cf5:	mov    0x18(%r13),%rax
    6cf9:	test   %rax,%rax
    6cfc:	je     7551 <botlish_fn_19+0xf39>
    6d02:	mov    0x10(%r13),%rax
    6d06:	mov    %rcx,(%rax)
    6d09:	mov    0x120(%rsp),%rsi
    6d11:	mov    0x108(%rsp),%rdi
    6d19:	call   6d1e <botlish_fn_19+0x706>
			6d1a: R_X86_64_PLT32	rt_co_done-0x4
    6d1e:	cmp    $0x6,%rax
    6d22:	je     7069 <botlish_fn_19+0xa51>
    6d28:	mov    0x10(%rbx),%rsi
    6d2c:	mov    (%rsi),%rsi
    6d2f:	mov    %rsi,0x50(%rsp)
    6d34:	mov    %rsi,%rdi
    6d37:	and    %r14,%rdi
    6d3a:	test   $0x1,%rdi
    6d41:	je     6d76 <botlish_fn_19+0x75e>
    6d47:	mov    %rsi,%rdi
    6d4a:	sub    %r14,%rdi
    6d4d:	mov    %rsi,%rax
    6d50:	seto   %r9b
    6d54:	lea    0x1(%rdi),%rsi
    6d58:	test   %r9b,%r9b
    6d5b:	je     6d69 <botlish_fn_19+0x751>
    6d61:	mov    %rax,%rsi
    6d64:	jmp    6d76 <botlish_fn_19+0x75e>
    6d69:	mov    0x110(%rsp),%r15
    6d71:	jmp    6d91 <botlish_fn_19+0x779>
    6d76:	mov    %r14,%rdx
    6d79:	mov    0x108(%rsp),%rdi
    6d81:	call   6d86 <botlish_fn_19+0x76e>
			6d82: R_X86_64_PLT32	rt_int_sub-0x4
    6d86:	mov    %rax,%rsi
    6d89:	mov    0x110(%rsp),%r15
    6d91:	mov    %rsi,%rax
    6d94:	and    %r15,%rax
    6d97:	test   $0x1,%rax
    6d9d:	jne    6dc8 <botlish_fn_19+0x7b0>
    6da3:	mov    %r15,%rdx
    6da6:	mov    0x108(%rsp),%rdi
    6dae:	call   6db3 <botlish_fn_19+0x79b>
			6daf: R_X86_64_PLT32	rt_int_cmp-0x4
    6db3:	mov    $0x2,%ecx
    6db8:	test   %rax,%rax
    6dbb:	cmovge 0x815(%rip),%rcx        # 75d8 <botlish_fn_19+0xfc0>
    6dc3:	jmp    6dd8 <botlish_fn_19+0x7c0>
    6dc8:	mov    $0x2,%ecx
    6dcd:	cmp    %r15,%rsi
    6dd0:	cmovge 0x800(%rip),%rcx        # 75d8 <botlish_fn_19+0xfc0>
    6dd8:	cmp    $0x6,%rcx
    6ddc:	je     6fe5 <botlish_fn_19+0x9cd>
    6de2:	mov    0x10(%r13),%rax
    6de6:	mov    (%rax),%rax
    6de9:	mov    %rax,0x50(%rsp)
    6dee:	lea    0xc0(%rsp),%rcx
    6df6:	mov    %rax,0xc0(%rsp)
    6dfe:	mov    $0x5,%esi
    6e03:	mov    %rsi,0x118(%rsp)
    6e0b:	mov    $0x1,%edx
    6e10:	mov    0x108(%rsp),%rdi
    6e18:	call   6e1d <botlish_fn_19+0x805>
			6e19: R_X86_64_PLT32	rt_struct_new-0x4
    6e1d:	mov    %rax,0x50(%rsp)
    6e22:	mov    %rax,%rdx
    6e25:	mov    0x120(%rsp),%rsi
    6e2d:	mov    0x108(%rsp),%rdi
    6e35:	call   6e3a <botlish_fn_19+0x822>
			6e36: R_X86_64_PLT32	rt_co_resume-0x4
    6e3a:	test   %rax,%rax
    6e3d:	mov    %rax,%rcx
    6e40:	jne    6fc2 <botlish_fn_19+0x9aa>
    6e46:	mov    0x108(%rsp),%rdi
    6e4e:	call   6e53 <botlish_fn_19+0x83b>
			6e4f: R_X86_64_PLT32	rt_declared_error-0x4
    6e53:	cmp    $0x1,%rax
    6e57:	je     6f16 <botlish_fn_19+0x8fe>
    6e5d:	mov    0x108(%rsp),%rdi
    6e65:	call   6e6a <botlish_fn_19+0x852>
			6e66: R_X86_64_PLT32	rt_declared_error-0x4
    6e6a:	cmp    $0x2,%rax
    6e6e:	jne    74bd <botlish_fn_19+0xea5>
    6e74:	xor    %rsi,%rsi
    6e77:	mov    0x108(%rsp),%rdi
    6e7f:	call   6e84 <botlish_fn_19+0x86c>
			6e80: R_X86_64_PLT32	rt_declared_payload-0x4
    6e84:	mov    %rax,%rbx
    6e87:	mov    0x108(%rsp),%rdi
    6e8f:	call   6e94 <botlish_fn_19+0x87c>
			6e90: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6e94:	mov    0x160(%rsp),%rsi
    6e9c:	mov    0x108(%rsp),%rdi
    6ea4:	call   6ea9 <botlish_fn_19+0x891>
			6ea5: R_X86_64_PLT32	rt_co_release-0x4
    6ea9:	mov    0x158(%rsp),%rsi
    6eb1:	mov    0x108(%rsp),%rdi
    6eb9:	call   6ebe <botlish_fn_19+0x8a6>
			6eba: R_X86_64_PLT32	rt_co_release-0x4
    6ebe:	mov    0x120(%rsp),%rsi
    6ec6:	mov    0x108(%rsp),%rdi
    6ece:	call   6ed3 <botlish_fn_19+0x8bb>
			6ecf: R_X86_64_PLT32	rt_co_release-0x4
    6ed3:	mov    0x108(%rsp),%rdi
    6edb:	mov    0x10(%rdi),%rax
    6edf:	mov    0x1a0(%rax),%rdx
    6ee6:	lea    0xd8(%rsp),%r9
    6eee:	mov    %rbx,%rax
    6ef1:	mov    %rax,0xd8(%rsp)
    6ef9:	mov    $0x3,%ecx
    6efe:	mov    $0x1,%r8d
    6f04:	mov    0x118(%rsp),%rsi
    6f0c:	call   6f11 <botlish_fn_19+0x8f9>
			6f0d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6f11:	jmp    74bd <botlish_fn_19+0xea5>
    6f16:	xor    %rsi,%rsi
    6f19:	mov    0x108(%rsp),%rdi
    6f21:	call   6f26 <botlish_fn_19+0x90e>
			6f22: R_X86_64_PLT32	rt_declared_payload-0x4
    6f26:	mov    %rax,%r12
    6f29:	mov    0x108(%rsp),%rdi
    6f31:	call   6f36 <botlish_fn_19+0x91e>
			6f32: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6f36:	mov    0x160(%rsp),%rsi
    6f3e:	mov    0x108(%rsp),%rdi
    6f46:	call   6f4b <botlish_fn_19+0x933>
			6f47: R_X86_64_PLT32	rt_co_release-0x4
    6f4b:	mov    0x158(%rsp),%rsi
    6f53:	mov    0x108(%rsp),%rdi
    6f5b:	call   6f60 <botlish_fn_19+0x948>
			6f5c: R_X86_64_PLT32	rt_co_release-0x4
    6f60:	mov    0x120(%rsp),%rsi
    6f68:	mov    0x108(%rsp),%rdi
    6f70:	call   6f75 <botlish_fn_19+0x95d>
			6f71: R_X86_64_PLT32	rt_co_release-0x4
    6f75:	mov    0x10(%rbx),%rax
    6f79:	mov    (%rax),%rcx
    6f7c:	mov    0x108(%rsp),%rdi
    6f84:	mov    0x10(%rdi),%rax
    6f88:	mov    0x198(%rax),%rdx
    6f8f:	lea    0xc8(%rsp),%r9
    6f97:	mov    %rcx,0xc8(%rsp)
    6f9f:	mov    %r12,%rax
    6fa2:	mov    %rax,0xd0(%rsp)
    6faa:	mov    $0x4,%esi
    6faf:	mov    $0x2,%r8d
    6fb5:	mov    %r8,%rcx
    6fb8:	call   6fbd <botlish_fn_19+0x9a5>
			6fb9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6fbd:	jmp    74bd <botlish_fn_19+0xea5>
    6fc2:	mov    0x18(%r12),%rax
    6fc7:	test   %rax,%rax
    6fca:	je     756b <botlish_fn_19+0xf53>
    6fd0:	mov    0x10(%r12),%rax
    6fd5:	mov    %rcx,(%rax)
    6fd8:	mov    %r15,0x110(%rsp)
    6fe0:	jmp    6bf6 <botlish_fn_19+0x5de>
    6fe5:	mov    0x160(%rsp),%rsi
    6fed:	mov    0x108(%rsp),%rdi
    6ff5:	call   6ffa <botlish_fn_19+0x9e2>
			6ff6: R_X86_64_PLT32	rt_co_release-0x4
    6ffa:	mov    0x158(%rsp),%rsi
    7002:	mov    0x108(%rsp),%rdi
    700a:	call   700f <botlish_fn_19+0x9f7>
			700b: R_X86_64_PLT32	rt_co_release-0x4
    700f:	mov    0x120(%rsp),%rsi
    7017:	mov    0x108(%rsp),%rdi
    701f:	call   7024 <botlish_fn_19+0xa0c>
			7020: R_X86_64_PLT32	rt_co_release-0x4
    7024:	mov    0x108(%rsp),%rdi
    702c:	mov    0x10(%rdi),%rax
    7030:	mov    0x1a8(%rax),%rdx
    7037:	lea    0xb0(%rsp),%r9
    703f:	mov    %r14,0xb0(%rsp)
    7047:	mov    %r15,0xb8(%rsp)
    704f:	mov    $0x8,%esi
    7054:	mov    $0x4,%ecx
    7059:	mov    $0x2,%r8d
    705f:	call   7064 <botlish_fn_19+0xa4c>
			7060: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7064:	jmp    74bd <botlish_fn_19+0xea5>
    7069:	mov    0x110(%rsp),%r15
    7071:	mov    0x120(%rsp),%rsi
    7079:	mov    0x108(%rsp),%rdi
    7081:	call   7086 <botlish_fn_19+0xa6e>
			7082: R_X86_64_PLT32	rt_co_release-0x4
    7086:	mov    0x128(%rsp),%rsi
    708e:	mov    0x108(%rsp),%rdi
    7096:	call   709b <botlish_fn_19+0xa83>
			7097: R_X86_64_PLT32	botlish_fn_14-0x4
    709b:	mov    %rax,0x38(%rsp)
    70a0:	mov    0x10(%rbx),%rcx
    70a4:	mov    (%rcx),%rcx
    70a7:	mov    %rcx,0x48(%rsp)
    70ac:	lea    0xe0(%rsp),%rdi
    70b4:	mov    %rax,0xe0(%rsp)
    70bc:	mov    %r14,0xe8(%rsp)
    70c4:	mov    %rcx,0xf0(%rsp)
    70cc:	mov    $0x1,%esi
    70d1:	mov    $0x3,%edx
    70d6:	mov    %rdi,%rcx
    70d9:	mov    0x108(%rsp),%rdi
    70e1:	call   70e6 <botlish_fn_19+0xace>
			70e2: R_X86_64_PLT32	rt_struct_new-0x4
    70e6:	mov    %rax,0x38(%rsp)
    70eb:	mov    %rax,%rdx
    70ee:	mov    0x158(%rsp),%rsi
    70f6:	mov    0x108(%rsp),%rdi
    70fe:	call   7103 <botlish_fn_19+0xaeb>
			70ff: R_X86_64_PLT32	rt_co_resume-0x4
    7103:	test   %rax,%rax
    7106:	jne    7198 <botlish_fn_19+0xb80>
    710c:	mov    0x108(%rsp),%rdi
    7114:	call   7119 <botlish_fn_19+0xb01>
			7115: R_X86_64_PLT32	rt_declared_error-0x4
    7119:	cmp    $0x6,%rax
    711d:	je     7169 <botlish_fn_19+0xb51>
    7123:	mov    0x108(%rsp),%rdi
    712b:	call   7130 <botlish_fn_19+0xb18>
			712c: R_X86_64_PLT32	rt_declared_error-0x4
    7130:	cmp    $0x7,%rax
    7134:	jne    74bd <botlish_fn_19+0xea5>
    713a:	mov    0x160(%rsp),%rsi
    7142:	mov    0x108(%rsp),%rdi
    714a:	call   714f <botlish_fn_19+0xb37>
			714b: R_X86_64_PLT32	rt_co_release-0x4
    714f:	mov    0x158(%rsp),%rsi
    7157:	mov    0x108(%rsp),%rdi
    715f:	call   7164 <botlish_fn_19+0xb4c>
			7160: R_X86_64_PLT32	rt_co_release-0x4
    7164:	jmp    74bd <botlish_fn_19+0xea5>
    7169:	mov    0x160(%rsp),%rsi
    7171:	mov    0x108(%rsp),%rdi
    7179:	call   717e <botlish_fn_19+0xb66>
			717a: R_X86_64_PLT32	rt_co_release-0x4
    717e:	mov    0x158(%rsp),%rsi
    7186:	mov    0x108(%rsp),%rdi
    718e:	call   7193 <botlish_fn_19+0xb7b>
			718f: R_X86_64_PLT32	rt_co_release-0x4
    7193:	jmp    74bd <botlish_fn_19+0xea5>
    7198:	movq   $0x1,0x38(%rsp)
    71a1:	mov    0x148(%rsp),%rdx
    71a9:	mov    0x10(%rdx),%rsi
    71ad:	mov    (%rsi),%rsi
    71b0:	mov    %rsi,0x40(%rsp)
    71b5:	movq   $0x3,0x48(%rsp)
    71be:	test   $0x1,%rsi
    71c5:	je     71ea <botlish_fn_19+0xbd2>
    71cb:	mov    %rsi,%rcx
    71ce:	add    $0x2,%rcx
    71d2:	seto   %al
    71d5:	test   %al,%al
    71d7:	jne    71ea <botlish_fn_19+0xbd2>
    71dd:	mov    0x148(%rsp),%rdx
    71e5:	jmp    7207 <botlish_fn_19+0xbef>
    71ea:	mov    $0x3,%edx
    71ef:	mov    0x108(%rsp),%rdi
    71f7:	call   71fc <botlish_fn_19+0xbe4>
			71f8: R_X86_64_PLT32	rt_int_add-0x4
    71fc:	mov    %rax,%rcx
    71ff:	mov    0x148(%rsp),%rdx
    7207:	mov    0x148(%rsp),%rdx
    720f:	mov    0x18(%rdx),%rax
    7213:	test   %rax,%rax
    7216:	je     7585 <botlish_fn_19+0xf6d>
    721c:	mov    0x148(%rsp),%rdx
    7224:	mov    0x10(%rdx),%rax
    7228:	mov    %rcx,(%rax)
    722b:	mov    %r15,0x110(%rsp)
    7233:	mov    %rbx,0x150(%rsp)
    723b:	jmp    6943 <botlish_fn_19+0x32b>
    7240:	movq   $0x132,0x10(%rsp)
    7249:	lea    0x78(%rsp),%rcx
    724e:	movq   $0x132,0x78(%rsp)
    7257:	mov    %r14,0x80(%rsp)
    725f:	mov    %r14,0x88(%rsp)
    7267:	mov    $0x1,%esi
    726c:	mov    $0x3,%edx
    7271:	mov    0x108(%rsp),%rdi
    7279:	call   727e <botlish_fn_19+0xc66>
			727a: R_X86_64_PLT32	rt_struct_new-0x4
    727e:	mov    %rax,0x10(%rsp)
    7283:	mov    %rax,%rdx
    7286:	mov    0x158(%rsp),%rsi
    728e:	mov    0x108(%rsp),%rdi
    7296:	call   729b <botlish_fn_19+0xc83>
			7297: R_X86_64_PLT32	rt_co_resume-0x4
    729b:	test   %rax,%rax
    729e:	jne    7330 <botlish_fn_19+0xd18>
    72a4:	mov    0x108(%rsp),%rdi
    72ac:	call   72b1 <botlish_fn_19+0xc99>
			72ad: R_X86_64_PLT32	rt_declared_error-0x4
    72b1:	cmp    $0x6,%rax
    72b5:	je     7301 <botlish_fn_19+0xce9>
    72bb:	mov    0x108(%rsp),%rdi
    72c3:	call   72c8 <botlish_fn_19+0xcb0>
			72c4: R_X86_64_PLT32	rt_declared_error-0x4
    72c8:	cmp    $0x7,%rax
    72cc:	jne    74bd <botlish_fn_19+0xea5>
    72d2:	mov    0x160(%rsp),%rsi
    72da:	mov    0x108(%rsp),%rdi
    72e2:	call   72e7 <botlish_fn_19+0xccf>
			72e3: R_X86_64_PLT32	rt_co_release-0x4
    72e7:	mov    0x158(%rsp),%rsi
    72ef:	mov    0x108(%rsp),%rdi
    72f7:	call   72fc <botlish_fn_19+0xce4>
			72f8: R_X86_64_PLT32	rt_co_release-0x4
    72fc:	jmp    74bd <botlish_fn_19+0xea5>
    7301:	mov    0x160(%rsp),%rsi
    7309:	mov    0x108(%rsp),%rdi
    7311:	call   7316 <botlish_fn_19+0xcfe>
			7312: R_X86_64_PLT32	rt_co_release-0x4
    7316:	mov    0x158(%rsp),%rsi
    731e:	mov    0x108(%rsp),%rdi
    7326:	call   732b <botlish_fn_19+0xd13>
			7327: R_X86_64_PLT32	rt_co_release-0x4
    732b:	jmp    74bd <botlish_fn_19+0xea5>
    7330:	mov    0x160(%rsp),%rsi
    7338:	mov    0x108(%rsp),%rdi
    7340:	call   7345 <botlish_fn_19+0xd2d>
			7341: R_X86_64_PLT32	rt_co_release-0x4
    7345:	mov    0x158(%rsp),%rsi
    734d:	mov    0x108(%rsp),%rdi
    7355:	call   735a <botlish_fn_19+0xd42>
			7356: R_X86_64_PLT32	rt_co_release-0x4
    735a:	mov    0x148(%rsp),%rdx
    7362:	mov    0x10(%rdx),%rax
    7366:	mov    (%rax),%rax
    7369:	mov    %rax,(%rsp)
    736d:	mov    0x10(%rbx),%rcx
    7371:	mov    (%rcx),%rdx
    7374:	mov    %rdx,0x8(%rsp)
    7379:	lea    0xf8(%rsp),%rcx
    7381:	mov    %rax,0xf8(%rsp)
    7389:	mov    %rdx,0x100(%rsp)
    7391:	xor    %rsi,%rsi
    7394:	mov    $0x2,%edx
    7399:	mov    0x108(%rsp),%rdi
    73a1:	call   73a6 <botlish_fn_19+0xd8e>
			73a2: R_X86_64_PLT32	rt_struct_new-0x4
    73a6:	mov    0x170(%rsp),%rbx
    73ae:	mov    0x178(%rsp),%r12
    73b6:	mov    0x180(%rsp),%r13
    73be:	mov    0x188(%rsp),%r14
    73c6:	mov    0x190(%rsp),%r15
    73ce:	add    $0x1a0,%rsp
    73d5:	mov    %rbp,%rsp
    73d8:	pop    %rbp
    73d9:	ret
    73da:	mov    0x150(%rsp),%rbx
    73e2:	mov    0x110(%rsp),%r15
    73ea:	movq   $0x1,0x38(%rsp)
    73f3:	mov    0x10(%rbx),%rax
    73f7:	mov    (%rax),%rsi
    73fa:	mov    %rsi,0x40(%rsp)
    73ff:	movq   $0x3,0x48(%rsp)
    7408:	test   $0x1,%rsi
    740f:	je     7427 <botlish_fn_19+0xe0f>
    7415:	mov    %rsi,%rcx
    7418:	add    $0x2,%rcx
    741c:	seto   %al
    741f:	test   %al,%al
    7421:	je     743c <botlish_fn_19+0xe24>
    7427:	mov    $0x3,%edx
    742c:	mov    0x108(%rsp),%rdi
    7434:	call   7439 <botlish_fn_19+0xe21>
			7435: R_X86_64_PLT32	rt_int_add-0x4
    7439:	mov    %rax,%rcx
    743c:	mov    0x18(%rbx),%rax
    7440:	test   %rax,%rax
    7443:	je     75a4 <botlish_fn_19+0xf8c>
    7449:	mov    0x10(%rbx),%rax
    744d:	mov    %rcx,(%rax)
    7450:	movq   $0x1,0x38(%rsp)
    7459:	mov    0x160(%rsp),%rsi
    7461:	mov    0x108(%rsp),%rdi
    7469:	call   746e <botlish_fn_19+0xe56>
			746a: R_X86_64_PLT32	rt_co_resume0-0x4
    746e:	test   %rax,%rax
    7471:	mov    %rax,%rcx
    7474:	jne    74f4 <botlish_fn_19+0xedc>
    747a:	mov    0x108(%rsp),%rdi
    7482:	call   7487 <botlish_fn_19+0xe6f>
			7483: R_X86_64_PLT32	rt_declared_error-0x4
    7487:	cmp    $0x40000001,%rax
    748d:	jne    74bd <botlish_fn_19+0xea5>
    7493:	mov    0x160(%rsp),%rsi
    749b:	mov    0x108(%rsp),%rdi
    74a3:	call   74a8 <botlish_fn_19+0xe90>
			74a4: R_X86_64_PLT32	rt_co_release-0x4
    74a8:	mov    0x158(%rsp),%rsi
    74b0:	mov    0x108(%rsp),%rdi
    74b8:	call   74bd <botlish_fn_19+0xea5>
			74b9: R_X86_64_PLT32	rt_co_release-0x4
    74bd:	xor    %rax,%rax
    74c0:	mov    0x170(%rsp),%rbx
    74c8:	mov    0x178(%rsp),%r12
    74d0:	mov    0x180(%rsp),%r13
    74d8:	mov    0x188(%rsp),%r14
    74e0:	mov    0x190(%rsp),%r15
    74e8:	add    $0x1a0,%rsp
    74ef:	mov    %rbp,%rsp
    74f2:	pop    %rbp
    74f3:	ret
    74f4:	mov    0x18(%r13),%rdi
    74f8:	test   %rdi,%rdi
    74fb:	je     75be <botlish_fn_19+0xfa6>
    7501:	mov    0x10(%r13),%r10
    7505:	mov    %rcx,(%r10)
    7508:	mov    %r15,0x110(%rsp)
    7510:	mov    %rbx,0x150(%rsp)
    7518:	jmp    6943 <botlish_fn_19+0x32b>
    751d:	mov    $0x1,%edx
    7522:	mov    %r12,%rsi
    7525:	mov    0x108(%rsp),%rdi
    752d:	call   7532 <botlish_fn_19+0xf1a>
			752e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    7532:	jmp    6bf6 <botlish_fn_19+0x5de>
    7537:	mov    $0x1,%edx
    753c:	mov    %rbx,%rsi
    753f:	mov    0x108(%rsp),%rdi
    7547:	call   754c <botlish_fn_19+0xf34>
			7548: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    754c:	jmp    6c6e <botlish_fn_19+0x656>
    7551:	mov    $0x1,%edx
    7556:	mov    %r13,%rsi
    7559:	mov    0x108(%rsp),%rdi
    7561:	call   7566 <botlish_fn_19+0xf4e>
			7562: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    7566:	jmp    6d09 <botlish_fn_19+0x6f1>
    756b:	mov    $0x1,%edx
    7570:	mov    %r12,%rsi
    7573:	mov    0x108(%rsp),%rdi
    757b:	call   7580 <botlish_fn_19+0xf68>
			757c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    7580:	jmp    6fd8 <botlish_fn_19+0x9c0>
    7585:	mov    $0x1,%edx
    758a:	mov    0x148(%rsp),%rsi
    7592:	mov    0x108(%rsp),%rdi
    759a:	call   759f <botlish_fn_19+0xf87>
			759b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    759f:	jmp    722b <botlish_fn_19+0xc13>
    75a4:	mov    $0x1,%edx
    75a9:	mov    %rbx,%rsi
    75ac:	mov    0x108(%rsp),%rdi
    75b4:	call   75b9 <botlish_fn_19+0xfa1>
			75b5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    75b9:	jmp    7450 <botlish_fn_19+0xe38>
    75be:	mov    $0x1,%edx
    75c3:	mov    %r13,%rsi
    75c6:	mov    0x108(%rsp),%rdi
    75ce:	call   75d3 <botlish_fn_19+0xfbb>
			75cf: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    75d3:	jmp    7508 <botlish_fn_19+0xef0>
    75d8:	(bad)
    75d9:	add    %al,(%rax)
    75db:	add    %al,(%rax)
    75dd:	add    %al,(%rax)
	...

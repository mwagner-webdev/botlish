<botlish_fn_19>:
    64c0:	push   %rbp
    64c1:	mov    %rsp,%rbp
    64c4:	sub    $0x1a0,%rsp
    64cb:	mov    %rbx,0x170(%rsp)
    64d3:	mov    %r12,0x178(%rsp)
    64db:	mov    %r13,0x180(%rsp)
    64e3:	mov    %r14,0x188(%rsp)
    64eb:	mov    %r15,0x190(%rsp)
    64f3:	mov    %rdi,0x108(%rsp)
    64fb:	movq   $0x0,0x18(%rsp)
    6504:	movq   $0x0,0x20(%rsp)
    650d:	movq   $0x0,0x28(%rsp)
    6516:	movq   $0x0,0x30(%rsp)
    651f:	movq   $0x0,0x38(%rsp)
    6528:	movq   $0x0,0x40(%rsp)
    6531:	movq   $0x0,0x48(%rsp)
    653a:	movq   $0x0,0x50(%rsp)
    6543:	movq   $0x0,0x58(%rsp)
    654c:	movq   $0x0,0x60(%rsp)
    6555:	mov    %rsi,(%rsp)
    6559:	mov    %rdx,0x8(%rsp)
    655e:	mov    %rdx,%r12
    6561:	mov    %rcx,0x10(%rsp)
    6566:	mov    %rcx,0x110(%rsp)
    656e:	lea    0x68(%rsp),%r8
    6573:	mov    %rsi,0x68(%rsp)
    6578:	mov    $0x14,%esi
    657d:	mov    0x0(%rip),%rdx        # 6584 <botlish_fn_19+0xc4>
			6580: R_X86_64_GOTPCREL	botlish_entry_20-0x4
    6584:	mov    $0x1,%ecx
    6589:	mov    0x108(%rsp),%rdi
    6591:	call   6596 <botlish_fn_19+0xd6>
			6592: R_X86_64_PLT32	rt_closure_new-0x4
    6596:	mov    %rax,(%rsp)
    659a:	mov    %rax,%rsi
    659d:	mov    0x108(%rsp),%rdi
    65a5:	call   65aa <botlish_fn_19+0xea>
			65a6: R_X86_64_PLT32	rt_co_create-0x4
    65aa:	mov    %rax,0x160(%rsp)
    65b2:	mov    %rax,(%rsp)
    65b6:	mov    0x160(%rsp),%rsi
    65be:	mov    0x108(%rsp),%rdi
    65c6:	call   65cb <botlish_fn_19+0x10b>
			65c7: R_X86_64_PLT32	rt_co_start-0x4
    65cb:	test   %rax,%rax
    65ce:	je     7365 <botlish_fn_19+0xea5>
    65d4:	mov    %rax,0x18(%rsp)
    65d9:	mov    %rax,%rbx
    65dc:	lea    0x70(%rsp),%r8
    65e1:	mov    %r12,%rdx
    65e4:	mov    %rdx,0x70(%rsp)
    65e9:	mov    $0x15,%esi
    65ee:	mov    0x0(%rip),%rdx        # 65f5 <botlish_fn_19+0x135>
			65f1: R_X86_64_GOTPCREL	botlish_entry_21-0x4
    65f5:	mov    $0x1,%ecx
    65fa:	mov    0x108(%rsp),%rdi
    6602:	call   6607 <botlish_fn_19+0x147>
			6603: R_X86_64_PLT32	rt_closure_new-0x4
    6607:	mov    %rax,0x8(%rsp)
    660c:	mov    %rax,%rsi
    660f:	mov    0x108(%rsp),%rdi
    6617:	call   661c <botlish_fn_19+0x15c>
			6618: R_X86_64_PLT32	rt_co_create-0x4
    661c:	mov    %rax,0x158(%rsp)
    6624:	mov    %rax,0x8(%rsp)
    6629:	mov    0x158(%rsp),%rsi
    6631:	mov    0x108(%rsp),%rdi
    6639:	call   663e <botlish_fn_19+0x17e>
			663a: R_X86_64_PLT32	rt_co_start-0x4
    663e:	test   %rax,%rax
    6641:	jne    66d3 <botlish_fn_19+0x213>
    6647:	mov    0x108(%rsp),%rdi
    664f:	call   6654 <botlish_fn_19+0x194>
			6650: R_X86_64_PLT32	rt_declared_error-0x4
    6654:	cmp    $0x6,%rax
    6658:	je     66a4 <botlish_fn_19+0x1e4>
    665e:	mov    0x108(%rsp),%rdi
    6666:	call   666b <botlish_fn_19+0x1ab>
			6667: R_X86_64_PLT32	rt_declared_error-0x4
    666b:	cmp    $0x7,%rax
    666f:	jne    7365 <botlish_fn_19+0xea5>
    6675:	mov    0x160(%rsp),%rsi
    667d:	mov    0x108(%rsp),%rdi
    6685:	call   668a <botlish_fn_19+0x1ca>
			6686: R_X86_64_PLT32	rt_co_release-0x4
    668a:	mov    0x158(%rsp),%rsi
    6692:	mov    0x108(%rsp),%rdi
    669a:	call   669f <botlish_fn_19+0x1df>
			669b: R_X86_64_PLT32	rt_co_release-0x4
    669f:	jmp    7365 <botlish_fn_19+0xea5>
    66a4:	mov    0x160(%rsp),%rsi
    66ac:	mov    0x108(%rsp),%rdi
    66b4:	call   66b9 <botlish_fn_19+0x1f9>
			66b5: R_X86_64_PLT32	rt_co_release-0x4
    66b9:	mov    0x158(%rsp),%rsi
    66c1:	mov    0x108(%rsp),%rdi
    66c9:	call   66ce <botlish_fn_19+0x20e>
			66ca: R_X86_64_PLT32	rt_co_release-0x4
    66ce:	jmp    7365 <botlish_fn_19+0xea5>
    66d3:	mov    $0x3,%esi
    66d8:	movq   $0x3,0x20(%rsp)
    66e1:	mov    %rbx,%rdx
    66e4:	mov    0x108(%rsp),%rdi
    66ec:	call   66f1 <botlish_fn_19+0x231>
			66ed: R_X86_64_PLT32	rt_mutarray_create-0x4
    66f1:	test   %rax,%rax
    66f4:	je     7365 <botlish_fn_19+0xea5>
    66fa:	mov    %rax,0x18(%rsp)
    66ff:	mov    %rax,%r13
    6702:	mov    $0x3,%esi
    6707:	movq   $0x3,0x20(%rsp)
    6710:	mov    $0x1,%edx
    6715:	movq   $0x1,0x28(%rsp)
    671e:	mov    0x108(%rsp),%rdi
    6726:	call   672b <botlish_fn_19+0x26b>
			6727: R_X86_64_PLT32	rt_mutarray_create-0x4
    672b:	test   %rax,%rax
    672e:	je     7365 <botlish_fn_19+0xea5>
    6734:	mov    %rax,0x20(%rsp)
    6739:	mov    %rax,0x150(%rsp)
    6741:	mov    $0x3,%esi
    6746:	movq   $0x3,0x28(%rsp)
    674f:	mov    $0x1,%edx
    6754:	movq   $0x1,0x30(%rsp)
    675d:	mov    0x108(%rsp),%rdi
    6765:	call   676a <botlish_fn_19+0x2aa>
			6766: R_X86_64_PLT32	rt_mutarray_create-0x4
    676a:	mov    %rax,%rcx
    676d:	test   %rcx,%rcx
    6770:	je     7365 <botlish_fn_19+0xea5>
    6776:	mov    %rcx,0x28(%rsp)
    677b:	mov    %rcx,0x148(%rsp)
    6783:	mov    $0x3,%esi
    6788:	movq   $0x3,0x30(%rsp)
    6791:	mov    $0x2,%edx
    6796:	movq   $0x2,0x38(%rsp)
    679f:	mov    0x108(%rsp),%rdi
    67a7:	call   67ac <botlish_fn_19+0x2ec>
			67a8: R_X86_64_PLT32	rt_mutarray_create-0x4
    67ac:	mov    %rax,%r12
    67af:	test   %r12,%r12
    67b2:	je     7365 <botlish_fn_19+0xea5>
    67b8:	mov    %r12,0x30(%rsp)
    67bd:	mov    $0xffffffffffffffff,%r14
    67c4:	mov    %r14,0x140(%rsp)
    67cc:	lea    0x90(%rsp),%r15
    67d4:	mov    %r15,0x138(%rsp)
    67dc:	mov    0x0(%rip),%rbx        # 67e3 <botlish_fn_19+0x323>
			67df: R_X86_64_GOTPCREL	botlish_entry_22-0x4
    67e3:	mov    %rbx,0x130(%rsp)
    67eb:	mov    0x10(%r13),%rax
    67ef:	mov    (%rax),%rsi
    67f2:	mov    %rsi,0x38(%rsp)
    67f7:	mov    %rsi,0x128(%rsp)
    67ff:	mov    0x128(%rsp),%rsi
    6807:	mov    0x108(%rsp),%rdi
    680f:	call   6814 <botlish_fn_19+0x354>
			6810: R_X86_64_PLT32	botlish_fn_13-0x4
    6814:	cmp    $0x6,%rax
    6818:	je     7282 <botlish_fn_19+0xdc2>
    681e:	mov    0x150(%rsp),%rbx
    6826:	mov    0x10(%rbx),%rax
    682a:	mov    (%rax),%r14
    682d:	mov    %r14,0x40(%rsp)
    6832:	mov    0x128(%rsp),%rsi
    683a:	test   $0x1,%rsi
    6841:	jne    6879 <botlish_fn_19+0x3b9>
    6847:	mov    0x140(%rsp),%rdx
    684f:	mov    0x128(%rsp),%rsi
    6857:	mov    0x108(%rsp),%rdi
    685f:	call   6864 <botlish_fn_19+0x3a4>
			6860: R_X86_64_PLT32	rt_int_cmp-0x4
    6864:	mov    $0x2,%ecx
    6869:	test   %rax,%rax
    686c:	cmove  0xc0c(%rip),%rcx        # 7480 <botlish_fn_19+0xfc0>
    6874:	jmp    6892 <botlish_fn_19+0x3d2>
    6879:	mov    $0x2,%ecx
    687e:	mov    0x128(%rsp),%rsi
    6886:	cmp    $0xffffffffffffffff,%rsi
    688a:	cmove  0xbee(%rip),%rcx        # 7480 <botlish_fn_19+0xfc0>
    6892:	cmp    $0x6,%rcx
    6896:	je     70e8 <botlish_fn_19+0xc28>
    689c:	mov    0x128(%rsp),%rsi
    68a4:	mov    %rsi,0x90(%rsp)
    68ac:	mov    $0x16,%esi
    68b1:	mov    $0x1,%ecx
    68b6:	mov    0x130(%rsp),%rdx
    68be:	mov    0x108(%rsp),%rdi
    68c6:	mov    0x138(%rsp),%r8
    68ce:	call   68d3 <botlish_fn_19+0x413>
			68cf: R_X86_64_PLT32	rt_closure_new-0x4
    68d3:	mov    %rax,0x48(%rsp)
    68d8:	mov    %rax,%rsi
    68db:	mov    0x108(%rsp),%rdi
    68e3:	call   68e8 <botlish_fn_19+0x428>
			68e4: R_X86_64_PLT32	rt_co_create-0x4
    68e8:	mov    %rax,0x120(%rsp)
    68f0:	mov    %rax,0x48(%rsp)
    68f5:	mov    0x120(%rsp),%rsi
    68fd:	mov    0x108(%rsp),%rdi
    6905:	call   690a <botlish_fn_19+0x44a>
			6906: R_X86_64_PLT32	rt_co_start-0x4
    690a:	test   %rax,%rax
    690d:	mov    %rax,%rcx
    6910:	jne    6a88 <botlish_fn_19+0x5c8>
    6916:	mov    0x108(%rsp),%rdi
    691e:	call   6923 <botlish_fn_19+0x463>
			691f: R_X86_64_PLT32	rt_declared_error-0x4
    6923:	cmp    $0x1,%rax
    6927:	je     69e3 <botlish_fn_19+0x523>
    692d:	mov    0x108(%rsp),%rdi
    6935:	call   693a <botlish_fn_19+0x47a>
			6936: R_X86_64_PLT32	rt_declared_error-0x4
    693a:	cmp    $0x2,%rax
    693e:	jne    7365 <botlish_fn_19+0xea5>
    6944:	xor    %rsi,%rsi
    6947:	mov    0x108(%rsp),%rdi
    694f:	call   6954 <botlish_fn_19+0x494>
			6950: R_X86_64_PLT32	rt_declared_payload-0x4
    6954:	mov    %rax,%rbx
    6957:	mov    0x108(%rsp),%rdi
    695f:	call   6964 <botlish_fn_19+0x4a4>
			6960: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6964:	mov    0x160(%rsp),%rsi
    696c:	mov    0x108(%rsp),%rdi
    6974:	call   6979 <botlish_fn_19+0x4b9>
			6975: R_X86_64_PLT32	rt_co_release-0x4
    6979:	mov    0x158(%rsp),%rsi
    6981:	mov    0x108(%rsp),%rdi
    6989:	call   698e <botlish_fn_19+0x4ce>
			698a: R_X86_64_PLT32	rt_co_release-0x4
    698e:	mov    0x120(%rsp),%rsi
    6996:	mov    0x108(%rsp),%rdi
    699e:	call   69a3 <botlish_fn_19+0x4e3>
			699f: R_X86_64_PLT32	rt_co_release-0x4
    69a3:	mov    0x108(%rsp),%rdi
    69ab:	mov    0x10(%rdi),%rax
    69af:	mov    0x1a0(%rax),%rdx
    69b6:	lea    0xa8(%rsp),%r9
    69be:	mov    %rbx,%rax
    69c1:	mov    %rax,0xa8(%rsp)
    69c9:	mov    $0x5,%esi
    69ce:	mov    $0x3,%ecx
    69d3:	mov    $0x1,%r8d
    69d9:	call   69de <botlish_fn_19+0x51e>
			69da: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    69de:	jmp    7365 <botlish_fn_19+0xea5>
    69e3:	xor    %rsi,%rsi
    69e6:	mov    0x108(%rsp),%rdi
    69ee:	call   69f3 <botlish_fn_19+0x533>
			69ef: R_X86_64_PLT32	rt_declared_payload-0x4
    69f3:	mov    %rax,%rbx
    69f6:	mov    0x108(%rsp),%rdi
    69fe:	call   6a03 <botlish_fn_19+0x543>
			69ff: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6a03:	mov    0x160(%rsp),%rsi
    6a0b:	mov    0x108(%rsp),%rdi
    6a13:	call   6a18 <botlish_fn_19+0x558>
			6a14: R_X86_64_PLT32	rt_co_release-0x4
    6a18:	mov    0x158(%rsp),%rsi
    6a20:	mov    0x108(%rsp),%rdi
    6a28:	call   6a2d <botlish_fn_19+0x56d>
			6a29: R_X86_64_PLT32	rt_co_release-0x4
    6a2d:	mov    0x120(%rsp),%rsi
    6a35:	mov    0x108(%rsp),%rdi
    6a3d:	call   6a42 <botlish_fn_19+0x582>
			6a3e: R_X86_64_PLT32	rt_co_release-0x4
    6a42:	mov    0x108(%rsp),%rdi
    6a4a:	mov    0x10(%rdi),%rax
    6a4e:	mov    0x198(%rax),%rdx
    6a55:	lea    0x98(%rsp),%r9
    6a5d:	mov    %r14,0x98(%rsp)
    6a65:	mov    %rbx,%rax
    6a68:	mov    %rax,0xa0(%rsp)
    6a70:	mov    $0x4,%esi
    6a75:	mov    $0x2,%r8d
    6a7b:	mov    %r8,%rcx
    6a7e:	call   6a83 <botlish_fn_19+0x5c3>
			6a7f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6a83:	jmp    7365 <botlish_fn_19+0xea5>
    6a88:	mov    0x18(%r12),%rax
    6a8d:	test   %rax,%rax
    6a90:	je     73c5 <botlish_fn_19+0xf05>
    6a96:	mov    0x10(%r12),%rax
    6a9b:	mov    %rcx,(%rax)
    6a9e:	mov    0x10(%r12),%rax
    6aa3:	mov    (%rax),%rax
    6aa6:	cmp    $0x6,%rax
    6aaa:	jne    6bb1 <botlish_fn_19+0x6f1>
    6ab0:	movq   $0x1,0x50(%rsp)
    6ab9:	mov    0x10(%rbx),%rax
    6abd:	mov    (%rax),%rsi
    6ac0:	mov    %rsi,0x58(%rsp)
    6ac5:	movq   $0x3,0x60(%rsp)
    6ace:	test   $0x1,%rsi
    6ad5:	je     6aed <botlish_fn_19+0x62d>
    6adb:	mov    %rsi,%rcx
    6ade:	add    $0x2,%rcx
    6ae2:	seto   %al
    6ae5:	test   %al,%al
    6ae7:	je     6b02 <botlish_fn_19+0x642>
    6aed:	mov    $0x3,%edx
    6af2:	mov    0x108(%rsp),%rdi
    6afa:	call   6aff <botlish_fn_19+0x63f>
			6afb: R_X86_64_PLT32	rt_int_add-0x4
    6aff:	mov    %rax,%rcx
    6b02:	mov    0x18(%rbx),%rax
    6b06:	test   %rax,%rax
    6b09:	je     73df <botlish_fn_19+0xf1f>
    6b0f:	mov    0x10(%rbx),%rax
    6b13:	mov    %rcx,(%rax)
    6b16:	movq   $0x1,0x50(%rsp)
    6b1f:	mov    0x160(%rsp),%rsi
    6b27:	mov    0x108(%rsp),%rdi
    6b2f:	call   6b34 <botlish_fn_19+0x674>
			6b30: R_X86_64_PLT32	rt_co_resume0-0x4
    6b34:	test   %rax,%rax
    6b37:	mov    %rax,%rcx
    6b3a:	jne    6b9d <botlish_fn_19+0x6dd>
    6b40:	mov    0x108(%rsp),%rdi
    6b48:	call   6b4d <botlish_fn_19+0x68d>
			6b49: R_X86_64_PLT32	rt_declared_error-0x4
    6b4d:	cmp    $0x40000001,%rax
    6b53:	jne    7365 <botlish_fn_19+0xea5>
    6b59:	mov    0x160(%rsp),%rsi
    6b61:	mov    0x108(%rsp),%rdi
    6b69:	call   6b6e <botlish_fn_19+0x6ae>
			6b6a: R_X86_64_PLT32	rt_co_release-0x4
    6b6e:	mov    0x158(%rsp),%rsi
    6b76:	mov    0x108(%rsp),%rdi
    6b7e:	call   6b83 <botlish_fn_19+0x6c3>
			6b7f: R_X86_64_PLT32	rt_co_release-0x4
    6b83:	mov    0x120(%rsp),%rsi
    6b8b:	mov    0x108(%rsp),%rdi
    6b93:	call   6b98 <botlish_fn_19+0x6d8>
			6b94: R_X86_64_PLT32	rt_co_release-0x4
    6b98:	jmp    7365 <botlish_fn_19+0xea5>
    6b9d:	mov    0x18(%r13),%rax
    6ba1:	test   %rax,%rax
    6ba4:	je     73f9 <botlish_fn_19+0xf39>
    6baa:	mov    0x10(%r13),%rax
    6bae:	mov    %rcx,(%rax)
    6bb1:	mov    0x120(%rsp),%rsi
    6bb9:	mov    0x108(%rsp),%rdi
    6bc1:	call   6bc6 <botlish_fn_19+0x706>
			6bc2: R_X86_64_PLT32	rt_co_done-0x4
    6bc6:	cmp    $0x6,%rax
    6bca:	je     6f11 <botlish_fn_19+0xa51>
    6bd0:	mov    0x10(%rbx),%rsi
    6bd4:	mov    (%rsi),%rsi
    6bd7:	mov    %rsi,0x50(%rsp)
    6bdc:	mov    %rsi,%rdi
    6bdf:	and    %r14,%rdi
    6be2:	test   $0x1,%rdi
    6be9:	je     6c1e <botlish_fn_19+0x75e>
    6bef:	mov    %rsi,%rdi
    6bf2:	sub    %r14,%rdi
    6bf5:	mov    %rsi,%rax
    6bf8:	seto   %r9b
    6bfc:	lea    0x1(%rdi),%rsi
    6c00:	test   %r9b,%r9b
    6c03:	je     6c11 <botlish_fn_19+0x751>
    6c09:	mov    %rax,%rsi
    6c0c:	jmp    6c1e <botlish_fn_19+0x75e>
    6c11:	mov    0x110(%rsp),%r15
    6c19:	jmp    6c39 <botlish_fn_19+0x779>
    6c1e:	mov    %r14,%rdx
    6c21:	mov    0x108(%rsp),%rdi
    6c29:	call   6c2e <botlish_fn_19+0x76e>
			6c2a: R_X86_64_PLT32	rt_int_sub-0x4
    6c2e:	mov    %rax,%rsi
    6c31:	mov    0x110(%rsp),%r15
    6c39:	mov    %rsi,%rax
    6c3c:	and    %r15,%rax
    6c3f:	test   $0x1,%rax
    6c45:	jne    6c70 <botlish_fn_19+0x7b0>
    6c4b:	mov    %r15,%rdx
    6c4e:	mov    0x108(%rsp),%rdi
    6c56:	call   6c5b <botlish_fn_19+0x79b>
			6c57: R_X86_64_PLT32	rt_int_cmp-0x4
    6c5b:	mov    $0x2,%ecx
    6c60:	test   %rax,%rax
    6c63:	cmovge 0x815(%rip),%rcx        # 7480 <botlish_fn_19+0xfc0>
    6c6b:	jmp    6c80 <botlish_fn_19+0x7c0>
    6c70:	mov    $0x2,%ecx
    6c75:	cmp    %r15,%rsi
    6c78:	cmovge 0x800(%rip),%rcx        # 7480 <botlish_fn_19+0xfc0>
    6c80:	cmp    $0x6,%rcx
    6c84:	je     6e8d <botlish_fn_19+0x9cd>
    6c8a:	mov    0x10(%r13),%rax
    6c8e:	mov    (%rax),%rax
    6c91:	mov    %rax,0x50(%rsp)
    6c96:	lea    0xc0(%rsp),%rcx
    6c9e:	mov    %rax,0xc0(%rsp)
    6ca6:	mov    $0x5,%esi
    6cab:	mov    %rsi,0x118(%rsp)
    6cb3:	mov    $0x1,%edx
    6cb8:	mov    0x108(%rsp),%rdi
    6cc0:	call   6cc5 <botlish_fn_19+0x805>
			6cc1: R_X86_64_PLT32	rt_struct_new-0x4
    6cc5:	mov    %rax,0x50(%rsp)
    6cca:	mov    %rax,%rdx
    6ccd:	mov    0x120(%rsp),%rsi
    6cd5:	mov    0x108(%rsp),%rdi
    6cdd:	call   6ce2 <botlish_fn_19+0x822>
			6cde: R_X86_64_PLT32	rt_co_resume-0x4
    6ce2:	test   %rax,%rax
    6ce5:	mov    %rax,%rcx
    6ce8:	jne    6e6a <botlish_fn_19+0x9aa>
    6cee:	mov    0x108(%rsp),%rdi
    6cf6:	call   6cfb <botlish_fn_19+0x83b>
			6cf7: R_X86_64_PLT32	rt_declared_error-0x4
    6cfb:	cmp    $0x1,%rax
    6cff:	je     6dbe <botlish_fn_19+0x8fe>
    6d05:	mov    0x108(%rsp),%rdi
    6d0d:	call   6d12 <botlish_fn_19+0x852>
			6d0e: R_X86_64_PLT32	rt_declared_error-0x4
    6d12:	cmp    $0x2,%rax
    6d16:	jne    7365 <botlish_fn_19+0xea5>
    6d1c:	xor    %rsi,%rsi
    6d1f:	mov    0x108(%rsp),%rdi
    6d27:	call   6d2c <botlish_fn_19+0x86c>
			6d28: R_X86_64_PLT32	rt_declared_payload-0x4
    6d2c:	mov    %rax,%rbx
    6d2f:	mov    0x108(%rsp),%rdi
    6d37:	call   6d3c <botlish_fn_19+0x87c>
			6d38: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6d3c:	mov    0x160(%rsp),%rsi
    6d44:	mov    0x108(%rsp),%rdi
    6d4c:	call   6d51 <botlish_fn_19+0x891>
			6d4d: R_X86_64_PLT32	rt_co_release-0x4
    6d51:	mov    0x158(%rsp),%rsi
    6d59:	mov    0x108(%rsp),%rdi
    6d61:	call   6d66 <botlish_fn_19+0x8a6>
			6d62: R_X86_64_PLT32	rt_co_release-0x4
    6d66:	mov    0x120(%rsp),%rsi
    6d6e:	mov    0x108(%rsp),%rdi
    6d76:	call   6d7b <botlish_fn_19+0x8bb>
			6d77: R_X86_64_PLT32	rt_co_release-0x4
    6d7b:	mov    0x108(%rsp),%rdi
    6d83:	mov    0x10(%rdi),%rax
    6d87:	mov    0x1a0(%rax),%rdx
    6d8e:	lea    0xd8(%rsp),%r9
    6d96:	mov    %rbx,%rax
    6d99:	mov    %rax,0xd8(%rsp)
    6da1:	mov    $0x3,%ecx
    6da6:	mov    $0x1,%r8d
    6dac:	mov    0x118(%rsp),%rsi
    6db4:	call   6db9 <botlish_fn_19+0x8f9>
			6db5: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6db9:	jmp    7365 <botlish_fn_19+0xea5>
    6dbe:	xor    %rsi,%rsi
    6dc1:	mov    0x108(%rsp),%rdi
    6dc9:	call   6dce <botlish_fn_19+0x90e>
			6dca: R_X86_64_PLT32	rt_declared_payload-0x4
    6dce:	mov    %rax,%r12
    6dd1:	mov    0x108(%rsp),%rdi
    6dd9:	call   6dde <botlish_fn_19+0x91e>
			6dda: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6dde:	mov    0x160(%rsp),%rsi
    6de6:	mov    0x108(%rsp),%rdi
    6dee:	call   6df3 <botlish_fn_19+0x933>
			6def: R_X86_64_PLT32	rt_co_release-0x4
    6df3:	mov    0x158(%rsp),%rsi
    6dfb:	mov    0x108(%rsp),%rdi
    6e03:	call   6e08 <botlish_fn_19+0x948>
			6e04: R_X86_64_PLT32	rt_co_release-0x4
    6e08:	mov    0x120(%rsp),%rsi
    6e10:	mov    0x108(%rsp),%rdi
    6e18:	call   6e1d <botlish_fn_19+0x95d>
			6e19: R_X86_64_PLT32	rt_co_release-0x4
    6e1d:	mov    0x10(%rbx),%rax
    6e21:	mov    (%rax),%rcx
    6e24:	mov    0x108(%rsp),%rdi
    6e2c:	mov    0x10(%rdi),%rax
    6e30:	mov    0x198(%rax),%rdx
    6e37:	lea    0xc8(%rsp),%r9
    6e3f:	mov    %rcx,0xc8(%rsp)
    6e47:	mov    %r12,%rax
    6e4a:	mov    %rax,0xd0(%rsp)
    6e52:	mov    $0x4,%esi
    6e57:	mov    $0x2,%r8d
    6e5d:	mov    %r8,%rcx
    6e60:	call   6e65 <botlish_fn_19+0x9a5>
			6e61: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6e65:	jmp    7365 <botlish_fn_19+0xea5>
    6e6a:	mov    0x18(%r12),%rax
    6e6f:	test   %rax,%rax
    6e72:	je     7413 <botlish_fn_19+0xf53>
    6e78:	mov    0x10(%r12),%rax
    6e7d:	mov    %rcx,(%rax)
    6e80:	mov    %r15,0x110(%rsp)
    6e88:	jmp    6a9e <botlish_fn_19+0x5de>
    6e8d:	mov    0x160(%rsp),%rsi
    6e95:	mov    0x108(%rsp),%rdi
    6e9d:	call   6ea2 <botlish_fn_19+0x9e2>
			6e9e: R_X86_64_PLT32	rt_co_release-0x4
    6ea2:	mov    0x158(%rsp),%rsi
    6eaa:	mov    0x108(%rsp),%rdi
    6eb2:	call   6eb7 <botlish_fn_19+0x9f7>
			6eb3: R_X86_64_PLT32	rt_co_release-0x4
    6eb7:	mov    0x120(%rsp),%rsi
    6ebf:	mov    0x108(%rsp),%rdi
    6ec7:	call   6ecc <botlish_fn_19+0xa0c>
			6ec8: R_X86_64_PLT32	rt_co_release-0x4
    6ecc:	mov    0x108(%rsp),%rdi
    6ed4:	mov    0x10(%rdi),%rax
    6ed8:	mov    0x1a8(%rax),%rdx
    6edf:	lea    0xb0(%rsp),%r9
    6ee7:	mov    %r14,0xb0(%rsp)
    6eef:	mov    %r15,0xb8(%rsp)
    6ef7:	mov    $0x8,%esi
    6efc:	mov    $0x4,%ecx
    6f01:	mov    $0x2,%r8d
    6f07:	call   6f0c <botlish_fn_19+0xa4c>
			6f08: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6f0c:	jmp    7365 <botlish_fn_19+0xea5>
    6f11:	mov    0x110(%rsp),%r15
    6f19:	mov    0x120(%rsp),%rsi
    6f21:	mov    0x108(%rsp),%rdi
    6f29:	call   6f2e <botlish_fn_19+0xa6e>
			6f2a: R_X86_64_PLT32	rt_co_release-0x4
    6f2e:	mov    0x128(%rsp),%rsi
    6f36:	mov    0x108(%rsp),%rdi
    6f3e:	call   6f43 <botlish_fn_19+0xa83>
			6f3f: R_X86_64_PLT32	botlish_fn_14-0x4
    6f43:	mov    %rax,0x38(%rsp)
    6f48:	mov    0x10(%rbx),%rcx
    6f4c:	mov    (%rcx),%rcx
    6f4f:	mov    %rcx,0x48(%rsp)
    6f54:	lea    0xe0(%rsp),%rdi
    6f5c:	mov    %rax,0xe0(%rsp)
    6f64:	mov    %r14,0xe8(%rsp)
    6f6c:	mov    %rcx,0xf0(%rsp)
    6f74:	mov    $0x1,%esi
    6f79:	mov    $0x3,%edx
    6f7e:	mov    %rdi,%rcx
    6f81:	mov    0x108(%rsp),%rdi
    6f89:	call   6f8e <botlish_fn_19+0xace>
			6f8a: R_X86_64_PLT32	rt_struct_new-0x4
    6f8e:	mov    %rax,0x38(%rsp)
    6f93:	mov    %rax,%rdx
    6f96:	mov    0x158(%rsp),%rsi
    6f9e:	mov    0x108(%rsp),%rdi
    6fa6:	call   6fab <botlish_fn_19+0xaeb>
			6fa7: R_X86_64_PLT32	rt_co_resume-0x4
    6fab:	test   %rax,%rax
    6fae:	jne    7040 <botlish_fn_19+0xb80>
    6fb4:	mov    0x108(%rsp),%rdi
    6fbc:	call   6fc1 <botlish_fn_19+0xb01>
			6fbd: R_X86_64_PLT32	rt_declared_error-0x4
    6fc1:	cmp    $0x6,%rax
    6fc5:	je     7011 <botlish_fn_19+0xb51>
    6fcb:	mov    0x108(%rsp),%rdi
    6fd3:	call   6fd8 <botlish_fn_19+0xb18>
			6fd4: R_X86_64_PLT32	rt_declared_error-0x4
    6fd8:	cmp    $0x7,%rax
    6fdc:	jne    7365 <botlish_fn_19+0xea5>
    6fe2:	mov    0x160(%rsp),%rsi
    6fea:	mov    0x108(%rsp),%rdi
    6ff2:	call   6ff7 <botlish_fn_19+0xb37>
			6ff3: R_X86_64_PLT32	rt_co_release-0x4
    6ff7:	mov    0x158(%rsp),%rsi
    6fff:	mov    0x108(%rsp),%rdi
    7007:	call   700c <botlish_fn_19+0xb4c>
			7008: R_X86_64_PLT32	rt_co_release-0x4
    700c:	jmp    7365 <botlish_fn_19+0xea5>
    7011:	mov    0x160(%rsp),%rsi
    7019:	mov    0x108(%rsp),%rdi
    7021:	call   7026 <botlish_fn_19+0xb66>
			7022: R_X86_64_PLT32	rt_co_release-0x4
    7026:	mov    0x158(%rsp),%rsi
    702e:	mov    0x108(%rsp),%rdi
    7036:	call   703b <botlish_fn_19+0xb7b>
			7037: R_X86_64_PLT32	rt_co_release-0x4
    703b:	jmp    7365 <botlish_fn_19+0xea5>
    7040:	movq   $0x1,0x38(%rsp)
    7049:	mov    0x148(%rsp),%rdx
    7051:	mov    0x10(%rdx),%rsi
    7055:	mov    (%rsi),%rsi
    7058:	mov    %rsi,0x40(%rsp)
    705d:	movq   $0x3,0x48(%rsp)
    7066:	test   $0x1,%rsi
    706d:	je     7092 <botlish_fn_19+0xbd2>
    7073:	mov    %rsi,%rcx
    7076:	add    $0x2,%rcx
    707a:	seto   %al
    707d:	test   %al,%al
    707f:	jne    7092 <botlish_fn_19+0xbd2>
    7085:	mov    0x148(%rsp),%rdx
    708d:	jmp    70af <botlish_fn_19+0xbef>
    7092:	mov    $0x3,%edx
    7097:	mov    0x108(%rsp),%rdi
    709f:	call   70a4 <botlish_fn_19+0xbe4>
			70a0: R_X86_64_PLT32	rt_int_add-0x4
    70a4:	mov    %rax,%rcx
    70a7:	mov    0x148(%rsp),%rdx
    70af:	mov    0x148(%rsp),%rdx
    70b7:	mov    0x18(%rdx),%rax
    70bb:	test   %rax,%rax
    70be:	je     742d <botlish_fn_19+0xf6d>
    70c4:	mov    0x148(%rsp),%rdx
    70cc:	mov    0x10(%rdx),%rax
    70d0:	mov    %rcx,(%rax)
    70d3:	mov    %r15,0x110(%rsp)
    70db:	mov    %rbx,0x150(%rsp)
    70e3:	jmp    67eb <botlish_fn_19+0x32b>
    70e8:	movq   $0x132,0x10(%rsp)
    70f1:	lea    0x78(%rsp),%rcx
    70f6:	movq   $0x132,0x78(%rsp)
    70ff:	mov    %r14,0x80(%rsp)
    7107:	mov    %r14,0x88(%rsp)
    710f:	mov    $0x1,%esi
    7114:	mov    $0x3,%edx
    7119:	mov    0x108(%rsp),%rdi
    7121:	call   7126 <botlish_fn_19+0xc66>
			7122: R_X86_64_PLT32	rt_struct_new-0x4
    7126:	mov    %rax,0x10(%rsp)
    712b:	mov    %rax,%rdx
    712e:	mov    0x158(%rsp),%rsi
    7136:	mov    0x108(%rsp),%rdi
    713e:	call   7143 <botlish_fn_19+0xc83>
			713f: R_X86_64_PLT32	rt_co_resume-0x4
    7143:	test   %rax,%rax
    7146:	jne    71d8 <botlish_fn_19+0xd18>
    714c:	mov    0x108(%rsp),%rdi
    7154:	call   7159 <botlish_fn_19+0xc99>
			7155: R_X86_64_PLT32	rt_declared_error-0x4
    7159:	cmp    $0x6,%rax
    715d:	je     71a9 <botlish_fn_19+0xce9>
    7163:	mov    0x108(%rsp),%rdi
    716b:	call   7170 <botlish_fn_19+0xcb0>
			716c: R_X86_64_PLT32	rt_declared_error-0x4
    7170:	cmp    $0x7,%rax
    7174:	jne    7365 <botlish_fn_19+0xea5>
    717a:	mov    0x160(%rsp),%rsi
    7182:	mov    0x108(%rsp),%rdi
    718a:	call   718f <botlish_fn_19+0xccf>
			718b: R_X86_64_PLT32	rt_co_release-0x4
    718f:	mov    0x158(%rsp),%rsi
    7197:	mov    0x108(%rsp),%rdi
    719f:	call   71a4 <botlish_fn_19+0xce4>
			71a0: R_X86_64_PLT32	rt_co_release-0x4
    71a4:	jmp    7365 <botlish_fn_19+0xea5>
    71a9:	mov    0x160(%rsp),%rsi
    71b1:	mov    0x108(%rsp),%rdi
    71b9:	call   71be <botlish_fn_19+0xcfe>
			71ba: R_X86_64_PLT32	rt_co_release-0x4
    71be:	mov    0x158(%rsp),%rsi
    71c6:	mov    0x108(%rsp),%rdi
    71ce:	call   71d3 <botlish_fn_19+0xd13>
			71cf: R_X86_64_PLT32	rt_co_release-0x4
    71d3:	jmp    7365 <botlish_fn_19+0xea5>
    71d8:	mov    0x160(%rsp),%rsi
    71e0:	mov    0x108(%rsp),%rdi
    71e8:	call   71ed <botlish_fn_19+0xd2d>
			71e9: R_X86_64_PLT32	rt_co_release-0x4
    71ed:	mov    0x158(%rsp),%rsi
    71f5:	mov    0x108(%rsp),%rdi
    71fd:	call   7202 <botlish_fn_19+0xd42>
			71fe: R_X86_64_PLT32	rt_co_release-0x4
    7202:	mov    0x148(%rsp),%rdx
    720a:	mov    0x10(%rdx),%rax
    720e:	mov    (%rax),%rax
    7211:	mov    %rax,(%rsp)
    7215:	mov    0x10(%rbx),%rcx
    7219:	mov    (%rcx),%rdx
    721c:	mov    %rdx,0x8(%rsp)
    7221:	lea    0xf8(%rsp),%rcx
    7229:	mov    %rax,0xf8(%rsp)
    7231:	mov    %rdx,0x100(%rsp)
    7239:	xor    %rsi,%rsi
    723c:	mov    $0x2,%edx
    7241:	mov    0x108(%rsp),%rdi
    7249:	call   724e <botlish_fn_19+0xd8e>
			724a: R_X86_64_PLT32	rt_struct_new-0x4
    724e:	mov    0x170(%rsp),%rbx
    7256:	mov    0x178(%rsp),%r12
    725e:	mov    0x180(%rsp),%r13
    7266:	mov    0x188(%rsp),%r14
    726e:	mov    0x190(%rsp),%r15
    7276:	add    $0x1a0,%rsp
    727d:	mov    %rbp,%rsp
    7280:	pop    %rbp
    7281:	ret
    7282:	mov    0x150(%rsp),%rbx
    728a:	mov    0x110(%rsp),%r15
    7292:	movq   $0x1,0x38(%rsp)
    729b:	mov    0x10(%rbx),%rax
    729f:	mov    (%rax),%rsi
    72a2:	mov    %rsi,0x40(%rsp)
    72a7:	movq   $0x3,0x48(%rsp)
    72b0:	test   $0x1,%rsi
    72b7:	je     72cf <botlish_fn_19+0xe0f>
    72bd:	mov    %rsi,%rcx
    72c0:	add    $0x2,%rcx
    72c4:	seto   %al
    72c7:	test   %al,%al
    72c9:	je     72e4 <botlish_fn_19+0xe24>
    72cf:	mov    $0x3,%edx
    72d4:	mov    0x108(%rsp),%rdi
    72dc:	call   72e1 <botlish_fn_19+0xe21>
			72dd: R_X86_64_PLT32	rt_int_add-0x4
    72e1:	mov    %rax,%rcx
    72e4:	mov    0x18(%rbx),%rax
    72e8:	test   %rax,%rax
    72eb:	je     744c <botlish_fn_19+0xf8c>
    72f1:	mov    0x10(%rbx),%rax
    72f5:	mov    %rcx,(%rax)
    72f8:	movq   $0x1,0x38(%rsp)
    7301:	mov    0x160(%rsp),%rsi
    7309:	mov    0x108(%rsp),%rdi
    7311:	call   7316 <botlish_fn_19+0xe56>
			7312: R_X86_64_PLT32	rt_co_resume0-0x4
    7316:	test   %rax,%rax
    7319:	mov    %rax,%rcx
    731c:	jne    739c <botlish_fn_19+0xedc>
    7322:	mov    0x108(%rsp),%rdi
    732a:	call   732f <botlish_fn_19+0xe6f>
			732b: R_X86_64_PLT32	rt_declared_error-0x4
    732f:	cmp    $0x40000001,%rax
    7335:	jne    7365 <botlish_fn_19+0xea5>
    733b:	mov    0x160(%rsp),%rsi
    7343:	mov    0x108(%rsp),%rdi
    734b:	call   7350 <botlish_fn_19+0xe90>
			734c: R_X86_64_PLT32	rt_co_release-0x4
    7350:	mov    0x158(%rsp),%rsi
    7358:	mov    0x108(%rsp),%rdi
    7360:	call   7365 <botlish_fn_19+0xea5>
			7361: R_X86_64_PLT32	rt_co_release-0x4
    7365:	xor    %rax,%rax
    7368:	mov    0x170(%rsp),%rbx
    7370:	mov    0x178(%rsp),%r12
    7378:	mov    0x180(%rsp),%r13
    7380:	mov    0x188(%rsp),%r14
    7388:	mov    0x190(%rsp),%r15
    7390:	add    $0x1a0,%rsp
    7397:	mov    %rbp,%rsp
    739a:	pop    %rbp
    739b:	ret
    739c:	mov    0x18(%r13),%rdi
    73a0:	test   %rdi,%rdi
    73a3:	je     7466 <botlish_fn_19+0xfa6>
    73a9:	mov    0x10(%r13),%r10
    73ad:	mov    %rcx,(%r10)
    73b0:	mov    %r15,0x110(%rsp)
    73b8:	mov    %rbx,0x150(%rsp)
    73c0:	jmp    67eb <botlish_fn_19+0x32b>
    73c5:	mov    $0x1,%edx
    73ca:	mov    %r12,%rsi
    73cd:	mov    0x108(%rsp),%rdi
    73d5:	call   73da <botlish_fn_19+0xf1a>
			73d6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    73da:	jmp    6a9e <botlish_fn_19+0x5de>
    73df:	mov    $0x1,%edx
    73e4:	mov    %rbx,%rsi
    73e7:	mov    0x108(%rsp),%rdi
    73ef:	call   73f4 <botlish_fn_19+0xf34>
			73f0: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    73f4:	jmp    6b16 <botlish_fn_19+0x656>
    73f9:	mov    $0x1,%edx
    73fe:	mov    %r13,%rsi
    7401:	mov    0x108(%rsp),%rdi
    7409:	call   740e <botlish_fn_19+0xf4e>
			740a: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    740e:	jmp    6bb1 <botlish_fn_19+0x6f1>
    7413:	mov    $0x1,%edx
    7418:	mov    %r12,%rsi
    741b:	mov    0x108(%rsp),%rdi
    7423:	call   7428 <botlish_fn_19+0xf68>
			7424: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    7428:	jmp    6e80 <botlish_fn_19+0x9c0>
    742d:	mov    $0x1,%edx
    7432:	mov    0x148(%rsp),%rsi
    743a:	mov    0x108(%rsp),%rdi
    7442:	call   7447 <botlish_fn_19+0xf87>
			7443: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    7447:	jmp    70d3 <botlish_fn_19+0xc13>
    744c:	mov    $0x1,%edx
    7451:	mov    %rbx,%rsi
    7454:	mov    0x108(%rsp),%rdi
    745c:	call   7461 <botlish_fn_19+0xfa1>
			745d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    7461:	jmp    72f8 <botlish_fn_19+0xe38>
    7466:	mov    $0x1,%edx
    746b:	mov    %r13,%rsi
    746e:	mov    0x108(%rsp),%rdi
    7476:	call   747b <botlish_fn_19+0xfbb>
			7477: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    747b:	jmp    73b0 <botlish_fn_19+0xef0>
    7480:	(bad)
    7481:	add    %al,(%rax)
    7483:	add    %al,(%rax)
    7485:	add    %al,(%rax)
	...

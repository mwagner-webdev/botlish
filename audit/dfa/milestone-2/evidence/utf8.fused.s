<botlish_fn_6>:
     430:	push   %rbp
     431:	mov    %rsp,%rbp
     434:	sub    $0x130,%rsp
     43b:	mov    %rbx,0x100(%rsp)
     443:	mov    %r12,0x108(%rsp)
     44b:	mov    %r13,0x110(%rsp)
     453:	mov    %r14,0x118(%rsp)
     45b:	mov    %r15,0x120(%rsp)
     463:	mov    %rdi,0xc8(%rsp)
     46b:	mov    %rsi,0xd0(%rsp)
     473:	xor    %rsi,%rsi
     476:	mov    0xc8(%rsp),%rdi
     47e:	call   483 <botlish_fn_6+0x53>
			47f: R_X86_64_PLT32	botlish_fn_5-0x4
     483:	mov    %rax,%r13
     486:	movq   $0xa,(%rsp)
     48e:	mov    0xc8(%rsp),%rdi
     496:	mov    0x10(%rdi),%r10
     49a:	mov    0x68(%r10),%r12
     49e:	mov    %r13,%rax
     4a1:	test   $0x1,%rax
     4a7:	jne    4dc <botlish_fn_6+0xac>
     4ad:	mov    $0xffffffffffffffff,%rdx
     4b4:	mov    %r13,%rsi
     4b7:	mov    0xc8(%rsp),%rdi
     4bf:	call   4c4 <botlish_fn_6+0x94>
			4c0: R_X86_64_PLT32	rt_int_cmp-0x4
     4c4:	mov    $0x2,%ecx
     4c9:	test   %rax,%rax
     4cc:	cmovl  0xe6c(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     4d4:	mov    %r13,%r14
     4d7:	jmp    4f0 <botlish_fn_6+0xc0>
     4dc:	mov    $0x2,%ecx
     4e1:	mov    %r13,%r14
     4e4:	cmp    $0xffffffffffffffff,%r14
     4e8:	cmovl  0xe50(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     4f0:	mov    $0x6,%eax
     4f5:	mov    %rax,0xe0(%rsp)
     4fd:	cmp    $0x6,%rcx
     501:	je     56d <botlish_fn_6+0x13d>
     507:	test   $0x1,%r14
     50e:	jne    53e <botlish_fn_6+0x10e>
     514:	mov    $0x1ff,%edx
     519:	mov    %r14,%rsi
     51c:	mov    0xc8(%rsp),%rdi
     524:	call   529 <botlish_fn_6+0xf9>
			525: R_X86_64_PLT32	rt_int_cmp-0x4
     529:	mov    $0x2,%ecx
     52e:	test   %rax,%rax
     531:	cmovg  0xe07(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     539:	jmp    552 <botlish_fn_6+0x122>
     53e:	mov    $0x2,%ecx
     543:	cmp    $0x1ff,%r14
     54a:	cmovg  0xdee(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     552:	cmp    $0x6,%rcx
     556:	je     56d <botlish_fn_6+0x13d>
     55c:	mov    %r14,%rax
     55f:	sar    $1,%rax
     562:	movzbq 0x11(%r12,%rax,1),%rbx
     568:	jmp    576 <botlish_fn_6+0x146>
     56d:	movzbq 0x111(%r12),%rbx
     576:	mov    %rbx,%rcx
     579:	shl    $1,%rcx
     57c:	or     $0x1,%rcx
     580:	mov    $0x2,%r10d
     586:	cmp    $0x3,%rcx
     58a:	cmovl  0xdae(%rip),%r10        # 1340 <botlish_fn_6+0xf10>
     592:	cmp    $0x6,%r10
     596:	je     93d <botlish_fn_6+0x50d>
     59c:	mov    %rbx,%rdx
     59f:	shl    $1,%rdx
     5a2:	or     $0x1,%rdx
     5a6:	mov    $0x2,%ecx
     5ab:	cmp    $0x3,%rdx
     5af:	cmove  0xd89(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     5b7:	cmp    $0x6,%rcx
     5bb:	je     91b <botlish_fn_6+0x4eb>
     5c1:	shl    $1,%rbx
     5c4:	or     $0x1,%rbx
     5c8:	mov    $0x2,%ecx
     5cd:	cmp    $0x5,%rbx
     5d1:	cmove  0xd67(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     5d9:	cmp    $0x6,%rcx
     5dd:	je     630 <botlish_fn_6+0x200>
     5e3:	mov    0xc8(%rsp),%rdi
     5eb:	mov    0x10(%rdi),%rdx
     5ef:	mov    0xa0(%rdx),%rcx
     5f6:	mov    0xa8(%rdx),%rsi
     5fd:	mov    0x98(%rdx),%rdx
     604:	lea    0x30(%rsp),%r9
     609:	mov    %rcx,0x30(%rsp)
     60e:	mov    %rsi,0x38(%rsp)
     613:	mov    %r14,0x40(%rsp)
     618:	mov    $0x1,%ecx
     61d:	mov    $0x3,%r8d
     623:	mov    %rcx,%rsi
     626:	call   62b <botlish_fn_6+0x1fb>
			627: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     62b:	jmp    879 <botlish_fn_6+0x449>
     630:	mov    0xc8(%rsp),%rdi
     638:	mov    0x10(%rdi),%rax
     63c:	mov    0x80(%rax),%rbx
     643:	test   $0x1,%r14
     64a:	jne    67c <botlish_fn_6+0x24c>
     650:	mov    $0xffffffffffffffff,%rdx
     657:	mov    %r14,%rsi
     65a:	mov    0xc8(%rsp),%rdi
     662:	call   667 <botlish_fn_6+0x237>
			663: R_X86_64_PLT32	rt_int_cmp-0x4
     667:	mov    $0x2,%ecx
     66c:	test   %rax,%rax
     66f:	cmovl  0xcc9(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     677:	jmp    68d <botlish_fn_6+0x25d>
     67c:	mov    $0x2,%ecx
     681:	cmp    $0xffffffffffffffff,%r14
     685:	cmovl  0xcb3(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     68d:	cmp    $0x6,%rcx
     691:	je     6ff <botlish_fn_6+0x2cf>
     697:	test   $0x1,%r14
     69e:	jne    6cf <botlish_fn_6+0x29f>
     6a4:	mov    $0x1ff,%edx
     6a9:	mov    %r14,%rsi
     6ac:	mov    0xc8(%rsp),%rdi
     6b4:	call   6b9 <botlish_fn_6+0x289>
			6b5: R_X86_64_PLT32	rt_int_cmp-0x4
     6b9:	mov    $0x2,%r9d
     6bf:	test   %rax,%rax
     6c2:	cmovg  0xc76(%rip),%r9        # 1340 <botlish_fn_6+0xf10>
     6ca:	jmp    6e4 <botlish_fn_6+0x2b4>
     6cf:	mov    $0x2,%r9d
     6d5:	cmp    $0x1ff,%r14
     6dc:	cmovg  0xc5c(%rip),%r9        # 1340 <botlish_fn_6+0xf10>
     6e4:	cmp    $0x6,%r9
     6e8:	je     6ff <botlish_fn_6+0x2cf>
     6ee:	mov    %r14,%rsi
     6f1:	sar    $1,%rsi
     6f4:	movzbq 0x11(%rbx,%rsi,1),%rsi
     6fa:	jmp    707 <botlish_fn_6+0x2d7>
     6ff:	movzbq 0x818(%rbx),%rsi
     707:	mov    %rsi,%rdi
     70a:	shl    $1,%rdi
     70d:	or     $0x1,%rdi
     711:	mov    $0x2,%ecx
     716:	cmp    $0x11,%rdi
     71a:	cmovl  0xc1e(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     722:	cmp    $0x6,%rcx
     726:	je     8f9 <botlish_fn_6+0x4c9>
     72c:	mov    %rsi,%rdx
     72f:	shl    $1,%rdx
     732:	mov    %rsi,0xf0(%rsp)
     73a:	or     $0x1,%rdx
     73e:	mov    $0x2,%ecx
     743:	cmp    $0x11,%rdx
     747:	cmove  0xbf1(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     74f:	cmp    $0x6,%rcx
     753:	je     8ef <botlish_fn_6+0x4bf>
     759:	test   $0x1,%r14
     760:	jne    795 <botlish_fn_6+0x365>
     766:	mov    $0xffffffffffffffff,%rdx
     76d:	mov    %r14,%rsi
     770:	mov    0xc8(%rsp),%rdi
     778:	call   77d <botlish_fn_6+0x34d>
			779: R_X86_64_PLT32	rt_int_cmp-0x4
     77d:	mov    $0x2,%ecx
     782:	test   %rax,%rax
     785:	cmove  0xbb3(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     78d:	mov    %r14,%r13
     790:	jmp    7a9 <botlish_fn_6+0x379>
     795:	mov    $0x2,%ecx
     79a:	cmp    $0xffffffffffffffff,%r14
     79e:	mov    %r14,%r13
     7a1:	cmove  0xb97(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     7a9:	cmp    $0x6,%rcx
     7ad:	je     81f <botlish_fn_6+0x3ef>
     7b3:	mov    0xc8(%rsp),%rdi
     7bb:	mov    0x10(%rdi),%rax
     7bf:	mov    0x88(%rax),%r12
     7c6:	mov    $0x1,%ebx
     7cb:	mov    0xf0(%rsp),%rsi
     7d3:	shl    $1,%rsi
     7d6:	or     $0x1,%rsi
     7da:	call   7df <botlish_fn_6+0x3af>
			7db: R_X86_64_PLT32	botlish_fn_1-0x4
     7df:	mov    0xc8(%rsp),%rdi
     7e7:	mov    0x10(%rdi),%rcx
     7eb:	mov    0x98(%rcx),%rdx
     7f2:	lea    0x18(%rsp),%r9
     7f7:	mov    %r12,0x18(%rsp)
     7fc:	mov    %rax,0x20(%rsp)
     801:	mov    %r13,%rax
     804:	mov    %rax,0x28(%rsp)
     809:	mov    $0x3,%r8d
     80f:	mov    %rbx,%rcx
     812:	mov    %rcx,%rsi
     815:	call   81a <botlish_fn_6+0x3ea>
			816: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     81a:	jmp    879 <botlish_fn_6+0x449>
     81f:	mov    0xf0(%rsp),%rsi
     827:	mov    0xc8(%rsp),%rdi
     82f:	mov    0x10(%rdi),%rax
     833:	mov    0x88(%rax),%rbx
     83a:	shl    $1,%rsi
     83d:	or     $0x1,%rsi
     841:	call   846 <botlish_fn_6+0x416>
			842: R_X86_64_PLT32	botlish_fn_1-0x4
     846:	mov    0xc8(%rsp),%rdi
     84e:	mov    0x10(%rdi),%rcx
     852:	mov    0x90(%rcx),%rdx
     859:	lea    0x8(%rsp),%r9
     85e:	mov    %rbx,0x8(%rsp)
     863:	mov    %rax,0x10(%rsp)
     868:	mov    $0x2,%r8d
     86e:	mov    %r8,%rcx
     871:	mov    %r8,%rsi
     874:	call   879 <botlish_fn_6+0x449>
			875: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     879:	mov    0xc8(%rsp),%rdi
     881:	call   886 <botlish_fn_6+0x456>
			882: R_X86_64_PLT32	rt_co_failed-0x4
     886:	mov    %rax,(%rsp)
     88a:	mov    %rax,%rsi
     88d:	mov    0xc8(%rsp),%rdi
     895:	call   89a <botlish_fn_6+0x46a>
			896: R_X86_64_PLT32	rt_co_resume0-0x4
     89a:	test   %rax,%rax
     89d:	je     8bc <botlish_fn_6+0x48c>
     8a3:	mov    0xc8(%rsp),%rdi
     8ab:	mov    0x10(%rdi),%rax
     8af:	mov    0x40(%rax),%rsi
     8b3:	mov    0x60(%rax),%rdx
     8b7:	call   8bc <botlish_fn_6+0x48c>
			8b8: R_X86_64_PLT32	rt_raise-0x4
     8bc:	mov    0xc8(%rsp),%rdi
     8c4:	call   8c9 <botlish_fn_6+0x499>
			8c5: R_X86_64_PLT32	rt_declared_error-0x4
     8c9:	cmp    $0x2,%rax
     8cd:	je     12b8 <botlish_fn_6+0xe88>
     8d3:	mov    0xc8(%rsp),%rdi
     8db:	call   8e0 <botlish_fn_6+0x4b0>
			8dc: R_X86_64_PLT32	rt_declared_error-0x4
     8e0:	cmp    $0x1,%rax
     8e4:	jne    12b8 <botlish_fn_6+0xe88>
     8ea:	jmp    12b8 <botlish_fn_6+0xe88>
     8ef:	mov    $0x1,%ebx
     8f4:	jmp    944 <botlish_fn_6+0x514>
     8f9:	mov    $0x1,%r13d
     8ff:	shl    $1,%rsi
     902:	or     $0x1,%rsi
     906:	mov    $0xa,%ebx
     90b:	mov    %r13,%r14
     90e:	mov    %rsi,0xf0(%rsp)
     916:	jmp    95d <botlish_fn_6+0x52d>
     91b:	mov    $0x1,%r13d
     921:	mov    $0xffffffffffffffff,%r14
     928:	mov    $0xa,%esi
     92d:	mov    %rsi,%rbx
     930:	mov    %rsi,0xf0(%rsp)
     938:	jmp    95d <botlish_fn_6+0x52d>
     93d:	shl    $1,%rbx
     940:	or     $0x1,%rbx
     944:	mov    $0x1,%r13d
     94a:	mov    $0x2,%r14d
     950:	mov    $0xa,%esi
     955:	mov    %rsi,0xf0(%rsp)
     95d:	mov    $0x1,%eax
     962:	mov    %rax,0xd8(%rsp)
     96a:	mov    0xd0(%rsp),%rcx
     972:	mov    0xd8(%rsp),%r15
     97a:	cmp    %rcx,%r15
     97d:	mov    %rcx,0xd0(%rsp)
     985:	jl     d7d <botlish_fn_6+0x94d>
     98b:	cmp    $0x1,%r14
     98f:	je     ad6 <botlish_fn_6+0x6a6>
     995:	mov    $0x2,%eax
     99a:	cmp    $0x2,%r14
     99e:	je     9b8 <botlish_fn_6+0x588>
     9a4:	mov    $0xa,%esi
     9a9:	cmp    $0xffffffffffffffff,%r14
     9ad:	je     d02 <botlish_fn_6+0x8d2>
     9b3:	jmp    c86 <botlish_fn_6+0x856>
     9b8:	mov    0xc8(%rsp),%rdi
     9c0:	mov    0x10(%rdi),%r9
     9c4:	mov    0x68(%r9),%r9
     9c8:	mov    %rax,%rcx
     9cb:	cmp    $0x6,%rcx
     9cf:	je     9ec <botlish_fn_6+0x5bc>
     9d5:	mov    %rax,%rcx
     9d8:	cmp    $0x6,%rcx
     9dc:	je     9ec <botlish_fn_6+0x5bc>
     9e2:	movzbq 0x10(%r9),%r10
     9e7:	jmp    9f4 <botlish_fn_6+0x5c4>
     9ec:	movzbq 0x111(%r9),%r10
     9f4:	mov    %r10,%rcx
     9f7:	shl    $1,%rcx
     9fa:	or     $0x1,%rcx
     9fe:	cmp    $0x3,%rcx
     a02:	mov    %rax,%r11
     a05:	cmovl  0x933(%rip),%r11        # 1340 <botlish_fn_6+0xf10>
     a0d:	cmp    $0x6,%r11
     a11:	je     ce8 <botlish_fn_6+0x8b8>
     a17:	mov    %r10,%rcx
     a1a:	shl    $1,%rcx
     a1d:	or     $0x1,%rcx
     a21:	cmp    $0x3,%rcx
     a25:	mov    %rax,%rcx
     a28:	cmove  0x910(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     a30:	cmp    $0x6,%rcx
     a34:	je     ac4 <botlish_fn_6+0x694>
     a3a:	shl    $1,%r10
     a3d:	or     $0x1,%r10
     a41:	cmp    $0x5,%r10
     a45:	cmove  0x8f3(%rip),%rax        # 1340 <botlish_fn_6+0xf10>
     a4d:	cmp    $0x6,%rax
     a51:	je     ab4 <botlish_fn_6+0x684>
     a57:	mov    0xc8(%rsp),%rdi
     a5f:	mov    0x10(%rdi),%rdx
     a63:	mov    0xa0(%rdx),%rax
     a6a:	mov    0xa8(%rdx),%rcx
     a71:	mov    0x98(%rdx),%rdx
     a78:	lea    0xb0(%rsp),%r9
     a80:	mov    %rax,0xb0(%rsp)
     a88:	mov    %rcx,0xb8(%rsp)
     a90:	movq   $0xffffffffffffffff,0xc0(%rsp)
     a9c:	mov    $0x1,%ecx
     aa1:	mov    $0x3,%r8d
     aa7:	mov    %rcx,%rsi
     aaa:	call   aaf <botlish_fn_6+0x67f>
			aab: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     aaf:	jmp    c72 <botlish_fn_6+0x842>
     ab4:	xor    %r12,%r12
     ab7:	mov    0xc8(%rsp),%rdi
     abf:	jmp    ae9 <botlish_fn_6+0x6b9>
     ac4:	mov    $0x1,%r13d
     aca:	mov    $0xffffffffffffffff,%r14
     ad1:	jmp    d02 <botlish_fn_6+0x8d2>
     ad6:	mov    0xf0(%rsp),%r12
     ade:	sar    $1,%r12
     ae1:	mov    0xc8(%rsp),%rdi
     ae9:	mov    0xc8(%rsp),%rdi
     af1:	mov    0x10(%rdi),%rax
     af5:	mov    0x80(%rax),%rax
     afc:	mov    $0x2,%ecx
     b01:	cmp    $0x6,%rcx
     b05:	je     b36 <botlish_fn_6+0x706>
     b0b:	mov    $0x2,%esi
     b10:	cmp    $0x6,%rsi
     b14:	je     b36 <botlish_fn_6+0x706>
     b1a:	shl    $1,%r12
     b1d:	or     $0x1,%r12
     b21:	sar    $1,%r12
     b24:	imul   $0x101,%r12,%rcx
     b2b:	movzbq 0x10(%rax,%rcx,1),%rsi
     b31:	jmp    b49 <botlish_fn_6+0x719>
     b36:	shl    $1,%r12
     b39:	or     $0x1,%r12
     b3d:	sar    $1,%r12
     b40:	movzbq 0x818(%rax,%r12,1),%rsi
     b49:	mov    %rsi,%rcx
     b4c:	shl    $1,%rcx
     b4f:	or     $0x1,%rcx
     b53:	mov    $0x2,%eax
     b58:	cmp    $0x11,%rcx
     b5c:	cmovl  0x7dc(%rip),%rax        # 1340 <botlish_fn_6+0xf10>
     b64:	cmp    $0x6,%rax
     b68:	je     cf9 <botlish_fn_6+0x8c9>
     b6e:	mov    %rsi,%rcx
     b71:	shl    $1,%rcx
     b74:	or     $0x1,%rcx
     b78:	mov    $0x2,%eax
     b7d:	cmp    $0x11,%rcx
     b81:	cmove  0x7b7(%rip),%rax        # 1340 <botlish_fn_6+0xf10>
     b89:	cmp    $0x6,%rax
     b8d:	je     ce8 <botlish_fn_6+0x8b8>
     b93:	mov    0xe0(%rsp),%rcx
     b9b:	cmp    $0x6,%rcx
     b9f:	je     c17 <botlish_fn_6+0x7e7>
     ba5:	mov    0xc8(%rsp),%rdi
     bad:	mov    0x10(%rdi),%r10
     bb1:	mov    0x88(%r10),%r12
     bb8:	mov    $0x1,%r13d
     bbe:	shl    $1,%rsi
     bc1:	or     $0x1,%rsi
     bc5:	call   bca <botlish_fn_6+0x79a>
			bc6: R_X86_64_PLT32	botlish_fn_1-0x4
     bca:	mov    0xc8(%rsp),%rdi
     bd2:	mov    0x10(%rdi),%r10
     bd6:	mov    0x98(%r10),%rdx
     bdd:	lea    0x98(%rsp),%r9
     be5:	mov    %r12,0x98(%rsp)
     bed:	mov    %rax,0xa0(%rsp)
     bf5:	movq   $0xffffffffffffffff,0xa8(%rsp)
     c01:	mov    $0x3,%r8d
     c07:	mov    %r13,%rcx
     c0a:	mov    %rcx,%rsi
     c0d:	call   c12 <botlish_fn_6+0x7e2>
			c0e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     c12:	jmp    c72 <botlish_fn_6+0x842>
     c17:	mov    0xc8(%rsp),%rdi
     c1f:	mov    0x10(%rdi),%rax
     c23:	mov    0x88(%rax),%r14
     c2a:	shl    $1,%rsi
     c2d:	or     $0x1,%rsi
     c31:	call   c36 <botlish_fn_6+0x806>
			c32: R_X86_64_PLT32	botlish_fn_1-0x4
     c36:	mov    0xc8(%rsp),%rdi
     c3e:	mov    0x10(%rdi),%rcx
     c42:	mov    0x90(%rcx),%rdx
     c49:	lea    0x88(%rsp),%r9
     c51:	mov    %r14,0x88(%rsp)
     c59:	mov    %rax,0x90(%rsp)
     c61:	mov    $0x2,%r8d
     c67:	mov    %r8,%rcx
     c6a:	mov    %r8,%rsi
     c6d:	call   c72 <botlish_fn_6+0x842>
			c6e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     c72:	mov    0xc8(%rsp),%rdi
     c7a:	call   c7f <botlish_fn_6+0x84f>
			c7b: R_X86_64_PLT32	rt_co_failed-0x4
     c7f:	mov    %rax,(%rsp)
     c83:	mov    %rax,%rsi
     c86:	mov    0xc8(%rsp),%rdi
     c8e:	call   c93 <botlish_fn_6+0x863>
			c8f: R_X86_64_PLT32	rt_co_resume0-0x4
     c93:	test   %rax,%rax
     c96:	je     cb5 <botlish_fn_6+0x885>
     c9c:	mov    0xc8(%rsp),%rdi
     ca4:	mov    0x10(%rdi),%rax
     ca8:	mov    0x40(%rax),%rsi
     cac:	mov    0x60(%rax),%rdx
     cb0:	call   cb5 <botlish_fn_6+0x885>
			cb1: R_X86_64_PLT32	rt_raise-0x4
     cb5:	mov    0xc8(%rsp),%rdi
     cbd:	call   cc2 <botlish_fn_6+0x892>
			cbe: R_X86_64_PLT32	rt_declared_error-0x4
     cc2:	cmp    $0x2,%rax
     cc6:	je     12b8 <botlish_fn_6+0xe88>
     ccc:	mov    0xc8(%rsp),%rdi
     cd4:	call   cd9 <botlish_fn_6+0x8a9>
			cd5: R_X86_64_PLT32	rt_declared_error-0x4
     cd9:	cmp    $0x1,%rax
     cdd:	jne    12b8 <botlish_fn_6+0xe88>
     ce3:	jmp    12b8 <botlish_fn_6+0xe88>
     ce8:	mov    $0x1,%r13d
     cee:	mov    $0x2,%r14d
     cf4:	jmp    d02 <botlish_fn_6+0x8d2>
     cf9:	mov    $0x1,%r13d
     cff:	mov    %r13,%r14
     d02:	test   %r14,%r14
     d05:	jl     d44 <botlish_fn_6+0x914>
     d0b:	mov    $0x1,%eax
     d10:	mov    0x100(%rsp),%rbx
     d18:	mov    0x108(%rsp),%r12
     d20:	mov    0x110(%rsp),%r13
     d28:	mov    0x118(%rsp),%r14
     d30:	mov    0x120(%rsp),%r15
     d38:	add    $0x130,%rsp
     d3f:	mov    %rbp,%rsp
     d42:	pop    %rbp
     d43:	ret
     d44:	mov    $0x3,%eax
     d49:	mov    0x100(%rsp),%rbx
     d51:	mov    0x108(%rsp),%r12
     d59:	mov    0x110(%rsp),%r13
     d61:	mov    0x118(%rsp),%r14
     d69:	mov    0x120(%rsp),%r15
     d71:	add    $0x130,%rsp
     d78:	mov    %rbp,%rsp
     d7b:	pop    %rbp
     d7c:	ret
     d7d:	mov    0xf0(%rsp),%r12
     d85:	mov    %r15,%rsi
     d88:	mov    0xc8(%rsp),%rdi
     d90:	call   d95 <botlish_fn_6+0x965>
			d91: R_X86_64_PLT32	botlish_fn_5-0x4
     d95:	mov    %r15,0xd8(%rsp)
     d9d:	mov    %rax,0xe8(%rsp)
     da5:	cmp    $0x1,%r14
     da9:	je     fb8 <botlish_fn_6+0xb88>
     daf:	mov    $0x2,%r15d
     db5:	cmp    $0x2,%r14
     db9:	je     dd3 <botlish_fn_6+0x9a3>
     dbf:	mov    $0xa,%esi
     dc4:	cmp    $0xffffffffffffffff,%r14
     dc8:	je     1318 <botlish_fn_6+0xee8>
     dce:	jmp    1261 <botlish_fn_6+0xe31>
     dd3:	mov    0xc8(%rsp),%rdi
     ddb:	mov    0x10(%rdi),%rax
     ddf:	mov    0x68(%rax),%r13
     de3:	mov    0xe8(%rsp),%rax
     deb:	test   $0x1,%rax
     df1:	jne    e26 <botlish_fn_6+0x9f6>
     df7:	mov    $0xffffffffffffffff,%rdx
     dfe:	mov    0xe8(%rsp),%rsi
     e06:	mov    0xc8(%rsp),%rdi
     e0e:	call   e13 <botlish_fn_6+0x9e3>
			e0f: R_X86_64_PLT32	rt_int_cmp-0x4
     e13:	test   %rax,%rax
     e16:	mov    %r15,%rcx
     e19:	cmovl  0x51f(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     e21:	jmp    e3d <botlish_fn_6+0xa0d>
     e26:	mov    0xe8(%rsp),%rax
     e2e:	cmp    $0xffffffffffffffff,%rax
     e32:	mov    %r15,%rcx
     e35:	cmovl  0x503(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     e3d:	cmp    $0x6,%rcx
     e41:	je     ec4 <botlish_fn_6+0xa94>
     e47:	mov    0xe8(%rsp),%rax
     e4f:	test   $0x1,%rax
     e55:	jne    e88 <botlish_fn_6+0xa58>
     e5b:	mov    $0x1ff,%edx
     e60:	mov    0xe8(%rsp),%rsi
     e68:	mov    0xc8(%rsp),%rdi
     e70:	call   e75 <botlish_fn_6+0xa45>
			e71: R_X86_64_PLT32	rt_int_cmp-0x4
     e75:	test   %rax,%rax
     e78:	mov    %r15,%rcx
     e7b:	cmovg  0x4bd(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     e83:	jmp    ea1 <botlish_fn_6+0xa71>
     e88:	mov    0xe8(%rsp),%rax
     e90:	cmp    $0x1ff,%rax
     e96:	mov    %r15,%rcx
     e99:	cmovg  0x49f(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
     ea1:	cmp    $0x6,%rcx
     ea5:	je     ec4 <botlish_fn_6+0xa94>
     eab:	mov    0xe8(%rsp),%rax
     eb3:	mov    %rax,%r8
     eb6:	sar    $1,%r8
     eb9:	movzbq 0x11(%r13,%r8,1),%rcx
     ebf:	jmp    ecc <botlish_fn_6+0xa9c>
     ec4:	movzbq 0x111(%r13),%rcx
     ecc:	mov    %rcx,%r10
     ecf:	shl    $1,%r10
     ed2:	or     $0x1,%r10
     ed6:	cmp    $0x3,%r10
     eda:	mov    %r15,%r11
     edd:	cmovl  0x45b(%rip),%r11        # 1340 <botlish_fn_6+0xf10>
     ee5:	cmp    $0x6,%r11
     ee9:	je     fa9 <botlish_fn_6+0xb79>
     eef:	mov    %rcx,%rdx
     ef2:	shl    $1,%rdx
     ef5:	or     $0x1,%rdx
     ef9:	cmp    $0x3,%rdx
     efd:	mov    %r15,%rax
     f00:	cmove  0x438(%rip),%rax        # 1340 <botlish_fn_6+0xf10>
     f08:	cmp    $0x6,%rax
     f0c:	je     f97 <botlish_fn_6+0xb67>
     f12:	shl    $1,%rcx
     f15:	or     $0x1,%rcx
     f19:	cmp    $0x5,%rcx
     f1d:	cmove  0x41b(%rip),%r15        # 1340 <botlish_fn_6+0xf10>
     f25:	cmp    $0x6,%r15
     f29:	je     f87 <botlish_fn_6+0xb57>
     f2f:	mov    0xc8(%rsp),%rdi
     f37:	mov    0x10(%rdi),%rdx
     f3b:	mov    0xa0(%rdx),%rcx
     f42:	mov    0xa8(%rdx),%rsi
     f49:	mov    0x98(%rdx),%rdx
     f50:	lea    0x70(%rsp),%r9
     f55:	mov    %rcx,0x70(%rsp)
     f5a:	mov    %rsi,0x78(%rsp)
     f5f:	mov    0xe8(%rsp),%rax
     f67:	mov    %rax,0x80(%rsp)
     f6f:	mov    $0x1,%ecx
     f74:	mov    $0x3,%r8d
     f7a:	mov    %rcx,%rsi
     f7d:	call   f82 <botlish_fn_6+0xb52>
			f7e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     f82:	jmp    124d <botlish_fn_6+0xe1d>
     f87:	xor    %r13,%r13
     f8a:	mov    0xc8(%rsp),%rdi
     f92:	jmp    fc6 <botlish_fn_6+0xb96>
     f97:	mov    $0x1,%r13d
     f9d:	mov    $0xffffffffffffffff,%r14
     fa4:	jmp    1318 <botlish_fn_6+0xee8>
     fa9:	shl    $1,%rcx
     fac:	or     $0x1,%rcx
     fb0:	mov    %rcx,%rbx
     fb3:	jmp    12f4 <botlish_fn_6+0xec4>
     fb8:	mov    %r12,%r13
     fbb:	sar    $1,%r13
     fbe:	mov    0xc8(%rsp),%rdi
     fc6:	mov    0xc8(%rsp),%rdi
     fce:	mov    0x10(%rdi),%rax
     fd2:	mov    0x80(%rax),%r14
     fd9:	mov    0xe8(%rsp),%rax
     fe1:	test   $0x1,%rax
     fe7:	jne    1026 <botlish_fn_6+0xbf6>
     fed:	mov    $0xffffffffffffffff,%rdx
     ff4:	mov    0xe8(%rsp),%rsi
     ffc:	mov    0xc8(%rsp),%rdi
    1004:	call   1009 <botlish_fn_6+0xbd9>
			1005: R_X86_64_PLT32	rt_int_cmp-0x4
    1009:	mov    $0x2,%esi
    100e:	test   %rax,%rax
    1011:	cmovl  0x327(%rip),%rsi        # 1340 <botlish_fn_6+0xf10>
    1019:	mov    0xe8(%rsp),%r15
    1021:	jmp    103f <botlish_fn_6+0xc0f>
    1026:	mov    $0x2,%esi
    102b:	mov    0xe8(%rsp),%r15
    1033:	cmp    $0xffffffffffffffff,%r15
    1037:	cmovl  0x301(%rip),%rsi        # 1340 <botlish_fn_6+0xf10>
    103f:	cmp    $0x6,%rsi
    1043:	je     10c5 <botlish_fn_6+0xc95>
    1049:	test   $0x1,%r15
    1050:	jne    1080 <botlish_fn_6+0xc50>
    1056:	mov    $0x1ff,%edx
    105b:	mov    %r15,%rsi
    105e:	mov    0xc8(%rsp),%rdi
    1066:	call   106b <botlish_fn_6+0xc3b>
			1067: R_X86_64_PLT32	rt_int_cmp-0x4
    106b:	mov    $0x2,%ecx
    1070:	test   %rax,%rax
    1073:	cmovg  0x2c5(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
    107b:	jmp    1094 <botlish_fn_6+0xc64>
    1080:	mov    $0x2,%ecx
    1085:	cmp    $0x1ff,%r15
    108c:	cmovg  0x2ac(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
    1094:	cmp    $0x6,%rcx
    1098:	je     10c5 <botlish_fn_6+0xc95>
    109e:	shl    $1,%r13
    10a1:	or     $0x1,%r13
    10a5:	sar    $1,%r13
    10a8:	imul   $0x101,%r13,%rax
    10af:	mov    %r15,%rcx
    10b2:	sar    $1,%rcx
    10b5:	lea    0x1(%rax,%rcx,1),%rax
    10ba:	movzbq 0x10(%r14,%rax,1),%rsi
    10c0:	jmp    10d8 <botlish_fn_6+0xca8>
    10c5:	shl    $1,%r13
    10c8:	or     $0x1,%r13
    10cc:	sar    $1,%r13
    10cf:	movzbq 0x818(%r14,%r13,1),%rsi
    10d8:	mov    %rsi,%rdx
    10db:	shl    $1,%rdx
    10de:	or     $0x1,%rdx
    10e2:	mov    $0x2,%ecx
    10e7:	cmp    $0x11,%rdx
    10eb:	cmovl  0x24d(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
    10f3:	cmp    $0x6,%rcx
    10f7:	je     1305 <botlish_fn_6+0xed5>
    10fd:	mov    %rsi,%rdx
    1100:	shl    $1,%rdx
    1103:	mov    %rsi,%rbx
    1106:	or     $0x1,%rdx
    110a:	mov    $0x2,%ecx
    110f:	cmp    $0x11,%rdx
    1113:	cmove  0x225(%rip),%rcx        # 1340 <botlish_fn_6+0xf10>
    111b:	cmp    $0x6,%rcx
    111f:	je     12ef <botlish_fn_6+0xebf>
    1125:	test   $0x1,%r15
    112c:	jne    1167 <botlish_fn_6+0xd37>
    1132:	mov    $0xffffffffffffffff,%rdx
    1139:	mov    %r15,%rsi
    113c:	mov    0xc8(%rsp),%rdi
    1144:	call   1149 <botlish_fn_6+0xd19>
			1145: R_X86_64_PLT32	rt_int_cmp-0x4
    1149:	mov    $0x2,%r9d
    114f:	test   %rax,%rax
    1152:	cmove  0x1e6(%rip),%r9        # 1340 <botlish_fn_6+0xf10>
    115a:	mov    %r15,0xe8(%rsp)
    1162:	jmp    1181 <botlish_fn_6+0xd51>
    1167:	mov    $0x2,%r9d
    116d:	cmp    $0xffffffffffffffff,%r15
    1171:	mov    %r15,0xe8(%rsp)
    1179:	cmove  0x1bf(%rip),%r9        # 1340 <botlish_fn_6+0xf10>
    1181:	cmp    $0x6,%r9
    1185:	je     11f8 <botlish_fn_6+0xdc8>
    118b:	mov    0xc8(%rsp),%rdi
    1193:	mov    0x10(%rdi),%r11
    1197:	mov    0x88(%r11),%r13
    119e:	mov    $0x1,%r12d
    11a4:	mov    %rbx,%rsi
    11a7:	shl    $1,%rsi
    11aa:	or     $0x1,%rsi
    11ae:	call   11b3 <botlish_fn_6+0xd83>
			11af: R_X86_64_PLT32	botlish_fn_1-0x4
    11b3:	mov    0xc8(%rsp),%rdi
    11bb:	mov    0x10(%rdi),%r11
    11bf:	mov    0x98(%r11),%rdx
    11c6:	lea    0x58(%rsp),%r9
    11cb:	mov    %r13,0x58(%rsp)
    11d0:	mov    %rax,0x60(%rsp)
    11d5:	mov    0xe8(%rsp),%rax
    11dd:	mov    %rax,0x68(%rsp)
    11e2:	mov    $0x3,%r8d
    11e8:	mov    %r12,%rcx
    11eb:	mov    %rcx,%rsi
    11ee:	call   11f3 <botlish_fn_6+0xdc3>
			11ef: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    11f3:	jmp    124d <botlish_fn_6+0xe1d>
    11f8:	mov    %rbx,%rsi
    11fb:	mov    0xc8(%rsp),%rdi
    1203:	mov    0x10(%rdi),%rax
    1207:	mov    0x88(%rax),%r15
    120e:	shl    $1,%rsi
    1211:	or     $0x1,%rsi
    1215:	call   121a <botlish_fn_6+0xdea>
			1216: R_X86_64_PLT32	botlish_fn_1-0x4
    121a:	mov    0xc8(%rsp),%rdi
    1222:	mov    0x10(%rdi),%rcx
    1226:	mov    0x90(%rcx),%rdx
    122d:	lea    0x48(%rsp),%r9
    1232:	mov    %r15,0x48(%rsp)
    1237:	mov    %rax,0x50(%rsp)
    123c:	mov    $0x2,%r8d
    1242:	mov    %r8,%rcx
    1245:	mov    %r8,%rsi
    1248:	call   124d <botlish_fn_6+0xe1d>
			1249: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    124d:	mov    0xc8(%rsp),%rdi
    1255:	call   125a <botlish_fn_6+0xe2a>
			1256: R_X86_64_PLT32	rt_co_failed-0x4
    125a:	mov    %rax,(%rsp)
    125e:	mov    %rax,%rsi
    1261:	mov    0xc8(%rsp),%rdi
    1269:	call   126e <botlish_fn_6+0xe3e>
			126a: R_X86_64_PLT32	rt_co_resume0-0x4
    126e:	test   %rax,%rax
    1271:	je     1290 <botlish_fn_6+0xe60>
    1277:	mov    0xc8(%rsp),%rdi
    127f:	mov    0x10(%rdi),%rax
    1283:	mov    0x40(%rax),%rsi
    1287:	mov    0x60(%rax),%rdx
    128b:	call   1290 <botlish_fn_6+0xe60>
			128c: R_X86_64_PLT32	rt_raise-0x4
    1290:	mov    0xc8(%rsp),%rdi
    1298:	call   129d <botlish_fn_6+0xe6d>
			1299: R_X86_64_PLT32	rt_declared_error-0x4
    129d:	cmp    $0x2,%rax
    12a1:	je     12b8 <botlish_fn_6+0xe88>
    12a7:	mov    0xc8(%rsp),%rdi
    12af:	call   12b4 <botlish_fn_6+0xe84>
			12b0: R_X86_64_PLT32	rt_declared_error-0x4
    12b4:	cmp    $0x1,%rax
    12b8:	xor    %rax,%rax
    12bb:	mov    0x100(%rsp),%rbx
    12c3:	mov    0x108(%rsp),%r12
    12cb:	mov    0x110(%rsp),%r13
    12d3:	mov    0x118(%rsp),%r14
    12db:	mov    0x120(%rsp),%r15
    12e3:	add    $0x130,%rsp
    12ea:	mov    %rbp,%rsp
    12ed:	pop    %rbp
    12ee:	ret
    12ef:	mov    $0x1,%ebx
    12f4:	mov    $0x1,%r13d
    12fa:	mov    $0x2,%r14d
    1300:	jmp    1318 <botlish_fn_6+0xee8>
    1305:	mov    $0x1,%r13d
    130b:	shl    $1,%rsi
    130e:	or     $0x1,%rsi
    1312:	mov    %rsi,%r12
    1315:	mov    %r13,%r14
    1318:	mov    0xd8(%rsp),%rcx
    1320:	add    $0x1,%rcx
    1327:	mov    %r12,0xf0(%rsp)
    132f:	mov    %rcx,%r15
    1332:	mov    0xd0(%rsp),%rcx
    133a:	jmp    97a <botlish_fn_6+0x54a>
    133f:	add    %al,(%rsi)
    1341:	add    %al,(%rax)
    1343:	add    %al,(%rax)
    1345:	add    %al,(%rax)
	...

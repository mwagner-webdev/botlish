<botlish_fn_4>:
 530:	push   %rbp
 531:	mov    %rsp,%rbp
 534:	sub    $0x90,%rsp
 53b:	mov    %rbx,0x60(%rsp)
 540:	mov    %r12,0x68(%rsp)
 545:	mov    %r13,0x70(%rsp)
 54a:	mov    %r14,0x78(%rsp)
 54f:	mov    %r15,0x80(%rsp)
 557:	mov    %rsi,%r12
 55a:	mov    %rdi,%r15
 55d:	movq   $0x0,0x10(%rsp)
 566:	movq   $0x0,0x18(%rsp)
 56f:	movq   $0x0,0x20(%rsp)
 578:	movq   $0x0,0x28(%rsp)
 581:	mov    $0x7,%esi
 586:	movq   $0x7,(%rsp)
 58e:	mov    $0x1,%edx
 593:	movq   $0x1,0x8(%rsp)
 59c:	mov    %r15,%rdi
 59f:	call   5a4 <botlish_fn_4+0x74>
			5a0: R_X86_64_PLT32	rt_mutarray_create-0x4
 5a4:	test   %rax,%rax
 5a7:	je     97f <botlish_fn_4+0x44f>
 5ad:	mov    %rax,(%rsp)
 5b1:	xor    %rbx,%rbx
 5b4:	mov    %r12,%r13
 5b7:	cmp    %r13,%rbx
 5ba:	jl     62a <botlish_fn_4+0xfa>
 5c0:	mov    %rax,%r12
 5c3:	mov    0x10(%r12),%rax
 5c8:	mov    0x8(%rax),%rax
 5cc:	mov    %rax,0x8(%rsp)
 5d1:	mov    0x10(%r12),%rcx
 5d6:	mov    (%rcx),%rcx
 5d9:	mov    %rcx,(%rsp)
 5dd:	lea    0x38(%rsp),%rdx
 5e2:	mov    %rax,0x38(%rsp)
 5e7:	mov    %rcx,0x40(%rsp)
 5ec:	mov    $0x2,%esi
 5f1:	mov    %r15,%rdi
 5f4:	call   5f9 <botlish_fn_4+0xc9>
			5f5: R_X86_64_PLT32	rt_list_new-0x4
 5f9:	test   %rax,%rax
 5fc:	je     97f <botlish_fn_4+0x44f>
 602:	mov    0x60(%rsp),%rbx
 607:	mov    0x68(%rsp),%r12
 60c:	mov    0x70(%rsp),%r13
 611:	mov    0x78(%rsp),%r14
 616:	mov    0x80(%rsp),%r15
 61e:	add    $0x90,%rsp
 625:	mov    %rbp,%rsp
 628:	pop    %rbp
 629:	ret
 62a:	mov    %rax,%r12
 62d:	mov    %rbx,%rsi
 630:	shl    $1,%rsi
 633:	or     $0x1,%rsi
 637:	mov    %rsi,0x8(%rsp)
 63c:	mov    %r15,%rdi
 63f:	call   644 <botlish_fn_4+0x114>
			640: R_X86_64_PLT32	botlish_fn_3-0x4
 644:	test   %rax,%rax
 647:	je     97f <botlish_fn_4+0x44f>
 64d:	mov    %rax,0x8(%rsp)
 652:	lea    0x30(%rsp),%r8
 657:	mov    %rax,0x30(%rsp)
 65c:	mov    $0x5,%esi
 661:	mov    0x0(%rip),%rdx        # 668 <botlish_fn_4+0x138>
			664: R_X86_64_GOTPCREL	botlish_entry_5-0x4
 668:	mov    $0x1,%ecx
 66d:	mov    %r15,%rdi
 670:	call   675 <botlish_fn_4+0x145>
			671: R_X86_64_PLT32	rt_closure_new-0x4
 675:	mov    %rax,0x8(%rsp)
 67a:	mov    %rax,%rsi
 67d:	mov    %r15,%rdi
 680:	call   685 <botlish_fn_4+0x155>
			681: R_X86_64_PLT32	rt_co_create-0x4
 685:	mov    %rax,0x50(%rsp)
 68a:	mov    %rax,0x8(%rsp)
 68f:	mov    0x50(%rsp),%rsi
 694:	mov    %r15,%rdi
 697:	call   69c <botlish_fn_4+0x16c>
			698: R_X86_64_PLT32	rt_co_start-0x4
 69c:	test   %rax,%rax
 69f:	mov    %rax,%rcx
 6a2:	jne    6ce <botlish_fn_4+0x19e>
 6a8:	mov    %r15,%rdi
 6ab:	call   6b0 <botlish_fn_4+0x180>
			6ac: R_X86_64_PLT32	rt_declared_error-0x4
 6b0:	cmp    $0x40000001,%rax
 6b6:	jne    97f <botlish_fn_4+0x44f>
 6bc:	mov    0x50(%rsp),%rsi
 6c1:	mov    %r15,%rdi
 6c4:	call   6c9 <botlish_fn_4+0x199>
			6c5: R_X86_64_PLT32	rt_co_release-0x4
 6c9:	jmp    97f <botlish_fn_4+0x44f>
 6ce:	mov    0x18(%r12),%rax
 6d3:	test   %rax,%rax
 6d6:	je     9e2 <botlish_fn_4+0x4b2>
 6dc:	mov    0x10(%r12),%rax
 6e1:	mov    %rcx,0x10(%rax)
 6e5:	mov    $0x7fffffff,%eax
 6ea:	mov    %rax,%r14
 6ed:	neg    %r14
 6f0:	cmovs  %rax,%r14
 6f4:	mov    0x50(%rsp),%rsi
 6f9:	mov    %r15,%rdi
 6fc:	call   701 <botlish_fn_4+0x1d1>
			6fd: R_X86_64_PLT32	rt_co_done-0x4
 701:	cmp    $0x6,%rax
 705:	je     9c6 <botlish_fn_4+0x496>
 70b:	movq   $0x1,0x10(%rsp)
 714:	mov    0x10(%r12),%rax
 719:	mov    (%rax),%rsi
 71c:	mov    %rsi,0x18(%rsp)
 721:	mov    0x10(%r12),%rax
 726:	mov    0x10(%rax),%rdx
 72a:	mov    %rdx,0x20(%rsp)
 72f:	mov    %rdx,0x48(%rsp)
 734:	movq   $0x3f,0x28(%rsp)
 73d:	test   $0x1,%rsi
 744:	je     76e <botlish_fn_4+0x23e>
 74a:	mov    %rsi,%rax
 74d:	sar    $1,%rax
 750:	imulq  0x2e1(%rip)        # a38 <botlish_fn_4+0x508>
 757:	seto   %cl
 75a:	or     $0x1,%rax
 75e:	test   %cl,%cl
 760:	jne    76e <botlish_fn_4+0x23e>
 766:	mov    %rax,%rsi
 769:	jmp    77e <botlish_fn_4+0x24e>
 76e:	mov    $0x3f,%edx
 773:	mov    %r15,%rdi
 776:	call   77b <botlish_fn_4+0x24b>
			777: R_X86_64_PLT32	rt_int_mul-0x4
 77b:	mov    %rax,%rsi
 77e:	mov    %rsi,0x18(%rsp)
 783:	mov    0x48(%rsp),%rdx
 788:	mov    %rsi,%rax
 78b:	and    %rdx,%rax
 78e:	test   $0x1,%rax
 794:	je     7af <botlish_fn_4+0x27f>
 79a:	lea    -0x1(%rdx),%rcx
 79e:	mov    %rsi,%rax
 7a1:	add    %rcx,%rax
 7a4:	seto   %cl
 7a7:	test   %cl,%cl
 7a9:	je     7b7 <botlish_fn_4+0x287>
 7af:	mov    %r15,%rdi
 7b2:	call   7b7 <botlish_fn_4+0x287>
			7b3: R_X86_64_PLT32	rt_int_add-0x4
 7b7:	mov    %rax,0x18(%rsp)
 7bc:	movq   $0x3,0x20(%rsp)
 7c5:	test   $0x1,%rax
 7cb:	jne    7d9 <botlish_fn_4+0x2a9>
 7d1:	mov    %rax,%rcx
 7d4:	jmp    7ee <botlish_fn_4+0x2be>
 7d9:	mov    %rax,%rsi
 7dc:	add    $0x2,%rsi
 7e0:	mov    %rax,%rcx
 7e3:	seto   %al
 7e6:	test   %al,%al
 7e8:	je     801 <botlish_fn_4+0x2d1>
 7ee:	mov    $0x3,%edx
 7f3:	mov    %rcx,%rsi
 7f6:	mov    %r15,%rdi
 7f9:	call   7fe <botlish_fn_4+0x2ce>
			7fa: R_X86_64_PLT32	rt_int_add-0x4
 7fe:	mov    %rax,%rsi
 801:	mov    %rsi,0x18(%rsp)
 806:	mov    $0xffffffff,%eax
 80b:	mov    %rax,0x20(%rsp)
 810:	test   $0x1,%rsi
 817:	jne    861 <botlish_fn_4+0x331>
 81d:	mov    $0xffffffff,%edx
 822:	mov    %r15,%rdi
 825:	call   82a <botlish_fn_4+0x2fa>
			826: R_X86_64_PLT32	rt_int_mod-0x4
 82a:	test   %rax,%rax
 82d:	jne    859 <botlish_fn_4+0x329>
 833:	mov    %r15,%rdi
 836:	call   83b <botlish_fn_4+0x30b>
			837: R_X86_64_PLT32	rt_declared_error-0x4
 83b:	cmp    $0x40000001,%rax
 841:	jne    97f <botlish_fn_4+0x44f>
 847:	mov    0x50(%rsp),%rsi
 84c:	mov    %r15,%rdi
 84f:	call   854 <botlish_fn_4+0x324>
			850: R_X86_64_PLT32	rt_co_release-0x4
 854:	jmp    97f <botlish_fn_4+0x44f>
 859:	mov    %rax,%rcx
 85c:	jmp    89f <botlish_fn_4+0x36f>
 861:	sar    $1,%rsi
 864:	mov    %rsi,%rax
 867:	imulq  0x1d2(%rip)        # a40 <botlish_fn_4+0x510>
 86e:	lea    (%rdx,%rsi,1),%rdi
 872:	sar    $0x1e,%rdi
 876:	mov    %rdi,%r8
 879:	shr    $0x3f,%r8
 87d:	add    %r8,%rdi
 880:	imul   $0x7fffffff,%rdi,%rdi
 887:	sub    %rdi,%rsi
 88a:	lea    (%rsi,%r14,1),%rdi
 88e:	test   %rsi,%rsi
 891:	cmovl  %rdi,%rsi
 895:	shl    $1,%rsi
 898:	or     $0x1,%rsi
 89c:	mov    %rsi,%rcx
 89f:	mov    0x18(%r12),%r9
 8a4:	test   %r9,%r9
 8a7:	je     9f7 <botlish_fn_4+0x4c7>
 8ad:	mov    0x10(%r12),%rax
 8b2:	mov    %rcx,(%rax)
 8b5:	movq   $0x3,0x10(%rsp)
 8be:	mov    0x10(%r12),%rax
 8c3:	mov    0x8(%rax),%rsi
 8c7:	mov    %rsi,0x18(%rsp)
 8cc:	movq   $0x3,0x20(%rsp)
 8d5:	test   $0x1,%rsi
 8dc:	je     8f4 <botlish_fn_4+0x3c4>
 8e2:	mov    %rsi,%rcx
 8e5:	add    $0x2,%rcx
 8e9:	seto   %al
 8ec:	test   %al,%al
 8ee:	je     904 <botlish_fn_4+0x3d4>
 8f4:	mov    $0x3,%edx
 8f9:	mov    %r15,%rdi
 8fc:	call   901 <botlish_fn_4+0x3d1>
			8fd: R_X86_64_PLT32	rt_int_add-0x4
 901:	mov    %rax,%rcx
 904:	mov    0x18(%r12),%rax
 909:	test   %rax,%rax
 90c:	je     a0c <botlish_fn_4+0x4dc>
 912:	mov    0x10(%r12),%rax
 917:	mov    %rcx,0x8(%rax)
 91b:	movq   $0x5,0x10(%rsp)
 924:	mov    0x50(%rsp),%rsi
 929:	mov    %r15,%rdi
 92c:	call   931 <botlish_fn_4+0x401>
			92d: R_X86_64_PLT32	rt_co_resume0-0x4
 931:	test   %rax,%rax
 934:	mov    %rax,%rcx
 937:	jne    9aa <botlish_fn_4+0x47a>
 93d:	mov    %r15,%rdi
 940:	call   945 <botlish_fn_4+0x415>
			941: R_X86_64_PLT32	rt_declared_error-0x4
 945:	cmp    $0x40000001,%rax
 94b:	jne    95e <botlish_fn_4+0x42e>
 951:	mov    0x50(%rsp),%rsi
 956:	mov    %r15,%rdi
 959:	call   95e <botlish_fn_4+0x42e>
			95a: R_X86_64_PLT32	rt_co_release-0x4
 95e:	mov    %r15,%rdi
 961:	call   966 <botlish_fn_4+0x436>
			962: R_X86_64_PLT32	rt_declared_error-0x4
 966:	cmp    $0x40000001,%rax
 96c:	jne    97f <botlish_fn_4+0x44f>
 972:	mov    0x50(%rsp),%rsi
 977:	mov    %r15,%rdi
 97a:	call   97f <botlish_fn_4+0x44f>
			97b: R_X86_64_PLT32	rt_co_release-0x4
 97f:	xor    %rax,%rax
 982:	mov    0x60(%rsp),%rbx
 987:	mov    0x68(%rsp),%r12
 98c:	mov    0x70(%rsp),%r13
 991:	mov    0x78(%rsp),%r14
 996:	mov    0x80(%rsp),%r15
 99e:	add    $0x90,%rsp
 9a5:	mov    %rbp,%rsp
 9a8:	pop    %rbp
 9a9:	ret
 9aa:	mov    0x18(%r12),%rax
 9af:	test   %rax,%rax
 9b2:	je     a21 <botlish_fn_4+0x4f1>
 9b8:	mov    0x10(%r12),%rax
 9bd:	mov    %rcx,0x10(%rax)
 9c1:	jmp    6f4 <botlish_fn_4+0x1c4>
 9c6:	mov    0x50(%rsp),%rsi
 9cb:	mov    %r15,%rdi
 9ce:	call   9d3 <botlish_fn_4+0x4a3>
			9cf: R_X86_64_PLT32	rt_co_release-0x4
 9d3:	add    $0x1,%rbx
 9da:	mov    %r12,%rax
 9dd:	jmp    5b7 <botlish_fn_4+0x87>
 9e2:	mov    $0x5,%edx
 9e7:	mov    %r12,%rsi
 9ea:	mov    %r15,%rdi
 9ed:	call   9f2 <botlish_fn_4+0x4c2>
			9ee: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 9f2:	jmp    6e5 <botlish_fn_4+0x1b5>
 9f7:	mov    $0x1,%edx
 9fc:	mov    %r12,%rsi
 9ff:	mov    %r15,%rdi
 a02:	call   a07 <botlish_fn_4+0x4d7>
			a03: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 a07:	jmp    8b5 <botlish_fn_4+0x385>
 a0c:	mov    $0x3,%edx
 a11:	mov    %r12,%rsi
 a14:	mov    %r15,%rdi
 a17:	call   a1c <botlish_fn_4+0x4ec>
			a18: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 a1c:	jmp    91b <botlish_fn_4+0x3eb>
 a21:	mov    $0x5,%edx
 a26:	mov    %r12,%rsi
 a29:	mov    %r15,%rdi
 a2c:	call   a31 <botlish_fn_4+0x501>
			a2d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 a31:	jmp    6f4 <botlish_fn_4+0x1c4>
 a36:	add    %al,(%rax)
 a38:	ds add %al,(%rax)
 a3b:	add    %al,(%rax)
 a3d:	add    %al,(%rax)
 a3f:	add    %al,(%rbx)
 a41:	add    %al,(%rax)
 a43:	add    %al,(%rcx)
 a45:	add    %al,(%rax)
 a47:	.byte 0x80

<botlish_fn_4>:
 428:	push   %rbp
 429:	mov    %rsp,%rbp
 42c:	sub    $0xd0,%rsp
 433:	mov    %rbx,0xa0(%rsp)
 43b:	mov    %r12,0xa8(%rsp)
 443:	mov    %r13,0xb0(%rsp)
 44b:	mov    %r14,0xb8(%rsp)
 453:	mov    %r15,0xc0(%rsp)
 45b:	mov    %rdi,0x50(%rsp)
 460:	mov    %rsi,0x58(%rsp)
 465:	movq   $0x0,0x10(%rsp)
 46e:	movq   $0x0,0x18(%rsp)
 477:	movq   $0x0,0x20(%rsp)
 480:	movq   $0x0,0x28(%rsp)
 489:	movq   $0x0,0x30(%rsp)
 492:	movq   $0x0,0x38(%rsp)
 49b:	mov    $0x7,%esi
 4a0:	movq   $0x7,(%rsp)
 4a8:	mov    $0x1,%edx
 4ad:	movq   $0x1,0x8(%rsp)
 4b6:	mov    0x50(%rsp),%rdi
 4bb:	call   4c0 <botlish_fn_4+0x98>
			4bc: R_X86_64_PLT32	rt_mutarray_create-0x4
 4c0:	test   %rax,%rax
 4c3:	je     983 <botlish_fn_4+0x55b>
 4c9:	mov    %rax,(%rsp)
 4cd:	mov    %rax,%rdx
 4d0:	xor    %rcx,%rcx
 4d3:	mov    %rcx,0x68(%rsp)
 4d8:	mov    0x58(%rsp),%rax
 4dd:	cmp    %rax,%rcx
 4e0:	mov    %rax,0x58(%rsp)
 4e5:	jl     563 <botlish_fn_4+0x13b>
 4eb:	mov    %rdx,%r12
 4ee:	mov    0x10(%r12),%rax
 4f3:	mov    0x8(%rax),%rax
 4f7:	mov    %rax,0x8(%rsp)
 4fc:	mov    0x10(%r12),%rcx
 501:	mov    (%rcx),%rcx
 504:	mov    %rcx,(%rsp)
 508:	lea    0x40(%rsp),%rdx
 50d:	mov    %rax,0x40(%rsp)
 512:	mov    %rcx,0x48(%rsp)
 517:	mov    $0x2,%esi
 51c:	mov    0x50(%rsp),%rdi
 521:	call   526 <botlish_fn_4+0xfe>
			522: R_X86_64_PLT32	rt_list_new-0x4
 526:	test   %rax,%rax
 529:	je     983 <botlish_fn_4+0x55b>
 52f:	mov    0xa0(%rsp),%rbx
 537:	mov    0xa8(%rsp),%r12
 53f:	mov    0xb0(%rsp),%r13
 547:	mov    0xb8(%rsp),%r14
 54f:	mov    0xc0(%rsp),%r15
 557:	add    $0xd0,%rsp
 55e:	mov    %rbp,%rsp
 561:	pop    %rbp
 562:	ret
 563:	mov    %rdx,%r12
 566:	mov    %rcx,%rsi
 569:	shl    $1,%rsi
 56c:	mov    %rcx,0x68(%rsp)
 571:	or     $0x1,%rsi
 575:	mov    %rsi,0x8(%rsp)
 57a:	mov    0x50(%rsp),%rdi
 57f:	call   584 <botlish_fn_4+0x15c>
			580: R_X86_64_PLT32	botlish_fn_3-0x4
 584:	test   %rax,%rax
 587:	je     983 <botlish_fn_4+0x55b>
 58d:	movq   $0xa,0x38(%rsp)
 596:	movq   $0xa,0x28(%rsp)
 59f:	movq   $0xa,0x30(%rsp)
 5a8:	mov    %rax,0x10(%rsp)
 5ad:	mov    %rax,%rsi
 5b0:	mov    0x50(%rsp),%rdi
 5b5:	call   5ba <botlish_fn_4+0x192>
			5b6: R_X86_64_PLT32	rt_int_to_str-0x4
 5ba:	mov    %rax,0x38(%rsp)
 5bf:	mov    0x8(%rax),%r14
 5c3:	mov    %rax,0x90(%rsp)
 5cb:	shl    $1,%r14
 5ce:	or     $0x1,%r14
 5d2:	sar    $1,%r14
 5d5:	test   %r14,%r14
 5d8:	jg     5fd <botlish_fn_4+0x1d5>
 5de:	mov    $0xffffffffffffffff,%rax
 5e5:	mov    %rax,0x60(%rsp)
 5ea:	movq   $0xffffffffffffffff,0x28(%rsp)
 5f3:	mov    0x60(%rsp),%rbx
 5f8:	jmp    67f <botlish_fn_4+0x257>
 5fd:	mov    0x90(%rsp),%rbx
 605:	movzbq 0x18(%rbx),%rax
 60a:	test   %rax,%rax
 60d:	jne    637 <botlish_fn_4+0x20f>
 613:	mov    $0x1,%edx
 618:	mov    %rbx,%rsi
 61b:	mov    0x50(%rsp),%rdi
 620:	call   625 <botlish_fn_4+0x1fd>
			621: R_X86_64_PLT32	rt_str_char_at_proven-0x4
 625:	mov    %rax,0x60(%rsp)
 62a:	mov    %rbx,0x90(%rsp)
 632:	jmp    65b <botlish_fn_4+0x233>
 637:	movzbq 0x19(%rbx),%rax
 63c:	mov    %rax,0x60(%rsp)
 641:	mov    %rbx,0x90(%rsp)
 649:	shl    $0x3,%rax
 64d:	mov    %rax,0x60(%rsp)
 652:	or     $0x4,%rax
 656:	mov    %rax,0x60(%rsp)
 65b:	shr    $0x3,%rax
 65f:	mov    %rax,0x60(%rsp)
 664:	mov    $0x1,%ebx
 669:	shl    $1,%rax
 66c:	mov    %rax,0x60(%rsp)
 671:	or     $0x1,%rax
 675:	mov    %rax,0x60(%rsp)
 67a:	mov    %rax,0x28(%rsp)
 67f:	mov    0x18(%r12),%rdi
 684:	test   %rdi,%rdi
 687:	je     abc <botlish_fn_4+0x694>
 68d:	mov    0x10(%r12),%r10
 692:	mov    0x60(%rsp),%rax
 697:	mov    %rax,0x10(%r10)
 69b:	xor    %r15,%r15
 69e:	mov    $0xffffffffffffffff,%rax
 6a5:	mov    %rax,0x88(%rsp)
 6ad:	mov    $0x3,%eax
 6b2:	mov    %rax,0x80(%rsp)
 6ba:	mov    $0x7fffffff,%eax
 6bf:	mov    %rax,%r13
 6c2:	neg    %r13
 6c5:	cmovs  %rax,%r13
 6c9:	mov    %r13,0x78(%rsp)
 6ce:	test   %rbx,%rbx
 6d1:	jl     aa3 <botlish_fn_4+0x67b>
 6d7:	movq   $0x1,0x8(%rsp)
 6e0:	mov    0x10(%r12),%rax
 6e5:	mov    (%rax),%rsi
 6e8:	mov    %rsi,0x10(%rsp)
 6ed:	mov    0x10(%r12),%rax
 6f2:	mov    0x10(%rax),%rdx
 6f6:	mov    %rdx,0x18(%rsp)
 6fb:	mov    %rdx,%r13
 6fe:	movq   $0x3f,0x20(%rsp)
 707:	test   $0x1,%rsi
 70e:	je     738 <botlish_fn_4+0x310>
 714:	mov    %rsi,%rax
 717:	sar    $1,%rax
 71a:	imulq  0x407(%rip)        # b28 <botlish_fn_4+0x700>
 721:	seto   %cl
 724:	or     $0x1,%rax
 728:	test   %cl,%cl
 72a:	jne    738 <botlish_fn_4+0x310>
 730:	mov    %rax,%rsi
 733:	jmp    74a <botlish_fn_4+0x322>
 738:	mov    $0x3f,%edx
 73d:	mov    0x50(%rsp),%rdi
 742:	call   747 <botlish_fn_4+0x31f>
			743: R_X86_64_PLT32	rt_int_mul-0x4
 747:	mov    %rax,%rsi
 74a:	mov    %rsi,0x10(%rsp)
 74f:	mov    %r13,%rdx
 752:	mov    %rsi,%rax
 755:	and    %rdx,%rax
 758:	test   $0x1,%rax
 75e:	je     779 <botlish_fn_4+0x351>
 764:	lea    -0x1(%rdx),%rcx
 768:	mov    %rsi,%rax
 76b:	add    %rcx,%rax
 76e:	seto   %cl
 771:	test   %cl,%cl
 773:	je     783 <botlish_fn_4+0x35b>
 779:	mov    0x50(%rsp),%rdi
 77e:	call   783 <botlish_fn_4+0x35b>
			77f: R_X86_64_PLT32	rt_int_add-0x4
 783:	mov    %rax,0x10(%rsp)
 788:	movq   $0x3,0x18(%rsp)
 791:	test   $0x1,%rax
 797:	jne    7a5 <botlish_fn_4+0x37d>
 79d:	mov    %rax,%rsi
 7a0:	jmp    7bd <botlish_fn_4+0x395>
 7a5:	mov    %rax,%rsi
 7a8:	add    $0x2,%rsi
 7ac:	mov    %rax,%rcx
 7af:	seto   %al
 7b2:	test   %al,%al
 7b4:	je     7d2 <botlish_fn_4+0x3aa>
 7ba:	mov    %rcx,%rsi
 7bd:	mov    0x80(%rsp),%rdx
 7c5:	mov    0x50(%rsp),%rdi
 7ca:	call   7cf <botlish_fn_4+0x3a7>
			7cb: R_X86_64_PLT32	rt_int_add-0x4
 7cf:	mov    %rax,%rsi
 7d2:	mov    %rsi,0x10(%rsp)
 7d7:	mov    $0xffffffff,%eax
 7dc:	mov    %rax,0x18(%rsp)
 7e1:	test   $0x1,%rsi
 7e8:	jne    829 <botlish_fn_4+0x401>
 7ee:	mov    $0xffffffff,%edx
 7f3:	mov    0x50(%rsp),%rdi
 7f8:	call   7fd <botlish_fn_4+0x3d5>
			7f9: R_X86_64_PLT32	rt_int_mod-0x4
 7fd:	test   %rax,%rax
 800:	jne    821 <botlish_fn_4+0x3f9>
 806:	mov    0x50(%rsp),%rdi
 80b:	call   810 <botlish_fn_4+0x3e8>
			80c: R_X86_64_PLT32	rt_declared_error-0x4
 810:	cmp    $0x40000001,%rax
 816:	jne    983 <botlish_fn_4+0x55b>
 81c:	jmp    983 <botlish_fn_4+0x55b>
 821:	mov    %rax,%rcx
 824:	jmp    86c <botlish_fn_4+0x444>
 829:	sar    $1,%rsi
 82c:	mov    %rsi,%rax
 82f:	imulq  0x2fa(%rip)        # b30 <botlish_fn_4+0x708>
 836:	lea    (%rdx,%rsi,1),%rax
 83a:	sar    $0x1e,%rax
 83e:	mov    %rax,%rcx
 841:	shr    $0x3f,%rcx
 845:	add    %rcx,%rax
 848:	imul   $0x7fffffff,%rax,%rax
 84f:	sub    %rax,%rsi
 852:	mov    0x78(%rsp),%rcx
 857:	lea    (%rsi,%rcx,1),%rax
 85b:	test   %rsi,%rsi
 85e:	cmovl  %rax,%rsi
 862:	shl    $1,%rsi
 865:	or     $0x1,%rsi
 869:	mov    %rsi,%rcx
 86c:	mov    0x18(%r12),%rax
 871:	test   %rax,%rax
 874:	je     ad8 <botlish_fn_4+0x6b0>
 87a:	mov    0x10(%r12),%rdx
 87f:	mov    %rcx,(%rdx)
 882:	movq   $0x3,0x8(%rsp)
 88b:	mov    0x10(%r12),%rsi
 890:	mov    0x8(%rsi),%rsi
 894:	mov    %rsi,0x10(%rsp)
 899:	movq   $0x3,0x18(%rsp)
 8a2:	test   $0x1,%rsi
 8a9:	je     8c1 <botlish_fn_4+0x499>
 8af:	mov    %rsi,%rcx
 8b2:	add    $0x2,%rcx
 8b6:	seto   %al
 8b9:	test   %al,%al
 8bb:	je     8d6 <botlish_fn_4+0x4ae>
 8c1:	mov    0x80(%rsp),%rdx
 8c9:	mov    0x50(%rsp),%rdi
 8ce:	call   8d3 <botlish_fn_4+0x4ab>
			8cf: R_X86_64_PLT32	rt_int_add-0x4
 8d3:	mov    %rax,%rcx
 8d6:	mov    0x18(%r12),%rax
 8db:	test   %rax,%rax
 8de:	je     aef <botlish_fn_4+0x6c7>
 8e4:	mov    0x10(%r12),%rax
 8e9:	mov    %rcx,0x8(%rax)
 8ed:	mov    $0x5,%edx
 8f2:	mov    %rdx,0x70(%rsp)
 8f7:	movq   $0x5,0x8(%rsp)
 900:	cmp    $0x1,%rbx
 904:	je     9ba <botlish_fn_4+0x592>
 90a:	cmp    $0xffffffffffffffff,%rbx
 90e:	jne    921 <botlish_fn_4+0x4f9>
 914:	mov    0x90(%rsp),%r13
 91c:	jmp    a7a <botlish_fn_4+0x652>
 921:	mov    $0xa,%esi
 926:	mov    0x50(%rsp),%rdi
 92b:	call   930 <botlish_fn_4+0x508>
			92c: R_X86_64_PLT32	rt_co_resume0-0x4
 930:	test   %rax,%rax
 933:	je     94e <botlish_fn_4+0x526>
 939:	mov    0x50(%rsp),%rdi
 93e:	mov    0x10(%rdi),%rax
 942:	mov    (%rax),%rsi
 945:	mov    0x28(%rax),%rdx
 949:	call   94e <botlish_fn_4+0x526>
			94a: R_X86_64_PLT32	rt_raise-0x4
 94e:	mov    0x50(%rsp),%rdi
 953:	call   958 <botlish_fn_4+0x530>
			954: R_X86_64_PLT32	rt_declared_error-0x4
 958:	cmp    $0x40000001,%rax
 95e:	je     96e <botlish_fn_4+0x546>
 964:	mov    0x50(%rsp),%rdi
 969:	jmp    973 <botlish_fn_4+0x54b>
 96e:	mov    0x50(%rsp),%rdi
 973:	mov    0x50(%rsp),%rdi
 978:	call   97d <botlish_fn_4+0x555>
			979: R_X86_64_PLT32	rt_declared_error-0x4
 97d:	cmp    $0x40000001,%rax
 983:	xor    %rax,%rax
 986:	mov    0xa0(%rsp),%rbx
 98e:	mov    0xa8(%rsp),%r12
 996:	mov    0xb0(%rsp),%r13
 99e:	mov    0xb8(%rsp),%r14
 9a6:	mov    0xc0(%rsp),%r15
 9ae:	add    $0xd0,%rsp
 9b5:	mov    %rbp,%rsp
 9b8:	pop    %rbp
 9b9:	ret
 9ba:	add    $0x1,%r15
 9c1:	cmp    %r14,%r15
 9c4:	jl     9f5 <botlish_fn_4+0x5cd>
 9ca:	movq   $0xffffffffffffffff,0x28(%rsp)
 9d3:	mov    0x88(%rsp),%rbx
 9db:	mov    0x90(%rsp),%r13
 9e3:	mov    0x88(%rsp),%rax
 9eb:	mov    %rax,0x60(%rsp)
 9f0:	jmp    a7a <botlish_fn_4+0x652>
 9f5:	mov    0x90(%rsp),%r13
 9fd:	movzbq 0x18(%r13),%rax
 a02:	test   %rax,%rax
 a05:	jne    a2c <botlish_fn_4+0x604>
 a0b:	mov    %r15,%rdx
 a0e:	shl    $1,%rdx
 a11:	or     $0x1,%rdx
 a15:	mov    %r13,%rsi
 a18:	mov    0x50(%rsp),%rdi
 a1d:	call   a22 <botlish_fn_4+0x5fa>
			a1e: R_X86_64_PLT32	rt_str_char_at_proven-0x4
 a22:	mov    %rax,0x60(%rsp)
 a27:	jmp    a56 <botlish_fn_4+0x62e>
 a2c:	mov    %r15,%rax
 a2f:	shl    $1,%rax
 a32:	or     $0x1,%rax
 a36:	sar    $1,%rax
 a39:	movzbq 0x19(%r13,%rax,1),%rax
 a3f:	mov    %rax,0x60(%rsp)
 a44:	shl    $0x3,%rax
 a48:	mov    %rax,0x60(%rsp)
 a4d:	or     $0x4,%rax
 a51:	mov    %rax,0x60(%rsp)
 a56:	shr    $0x3,%rax
 a5a:	mov    %rax,0x60(%rsp)
 a5f:	mov    $0x1,%ebx
 a64:	shl    $1,%rax
 a67:	mov    %rax,0x60(%rsp)
 a6c:	or     $0x1,%rax
 a70:	mov    %rax,0x60(%rsp)
 a75:	mov    %rax,0x28(%rsp)
 a7a:	mov    0x18(%r12),%rcx
 a7f:	test   %rcx,%rcx
 a82:	je     b09 <botlish_fn_4+0x6e1>
 a88:	mov    0x10(%r12),%rax
 a8d:	mov    0x60(%rsp),%rcx
 a92:	mov    %rcx,0x10(%rax)
 a96:	mov    %r13,0x90(%rsp)
 a9e:	jmp    6ce <botlish_fn_4+0x2a6>
 aa3:	mov    0x68(%rsp),%rcx
 aa8:	add    $0x1,%rcx
 aaf:	mov    0x58(%rsp),%rax
 ab4:	mov    %r12,%rdx
 ab7:	jmp    4dd <botlish_fn_4+0xb5>
 abc:	mov    $0x5,%edx
 ac1:	mov    0x60(%rsp),%rcx
 ac6:	mov    %r12,%rsi
 ac9:	mov    0x50(%rsp),%rdi
 ace:	call   ad3 <botlish_fn_4+0x6ab>
			acf: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 ad3:	jmp    69b <botlish_fn_4+0x273>
 ad8:	mov    $0x1,%edx
 add:	mov    %r12,%rsi
 ae0:	mov    0x50(%rsp),%rdi
 ae5:	call   aea <botlish_fn_4+0x6c2>
			ae6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 aea:	jmp    882 <botlish_fn_4+0x45a>
 aef:	mov    0x80(%rsp),%rdx
 af7:	mov    %r12,%rsi
 afa:	mov    0x50(%rsp),%rdi
 aff:	call   b04 <botlish_fn_4+0x6dc>
			b00: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 b04:	jmp    8ed <botlish_fn_4+0x4c5>
 b09:	mov    0x70(%rsp),%rdx
 b0e:	mov    0x60(%rsp),%rcx
 b13:	mov    %r12,%rsi
 b16:	mov    0x50(%rsp),%rdi
 b1b:	call   b20 <botlish_fn_4+0x6f8>
			b1c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 b20:	jmp    a96 <botlish_fn_4+0x66e>
 b25:	add    %al,(%rax)
 b27:	add    %bh,(%rsi)
 b29:	add    %al,(%rax)
 b2b:	add    %al,(%rax)
 b2d:	add    %al,(%rax)
 b2f:	add    %al,(%rbx)
 b31:	add    %al,(%rax)
 b33:	add    %al,(%rcx)
 b35:	add    %al,(%rax)
 b37:	.byte 0x80

<botlish_fn_7>:
 318:	push   %rbp
 319:	mov    %rsp,%rbp
 31c:	sub    $0xf0,%rsp
 323:	mov    %rbx,0xc0(%rsp)
 32b:	mov    %r12,0xc8(%rsp)
 333:	mov    %r13,0xd0(%rsp)
 33b:	mov    %r14,0xd8(%rsp)
 343:	mov    %r15,0xe0(%rsp)
 34b:	mov    %rdi,0x60(%rsp)
 350:	mov    %rsi,0x68(%rsp)
 355:	movq   $0x0,(%rsp)
 35d:	movq   $0x0,0x8(%rsp)
 366:	movq   $0x0,0x10(%rsp)
 36f:	movq   $0x0,0x18(%rsp)
 378:	movq   $0x0,0x20(%rsp)
 381:	movq   $0x0,0x28(%rsp)
 38a:	movq   $0x0,0x30(%rsp)
 393:	movq   $0x0,0x38(%rsp)
 39c:	movq   $0x0,0x40(%rsp)
 3a5:	movq   $0x0,0x48(%rsp)
 3ae:	mov    0x60(%rsp),%rdi
 3b3:	call   3b8 <botlish_fn_7+0xa0>
			3b4: R_X86_64_PLT32	botlish_fn_6-0x4
 3b8:	test   %rax,%rax
 3bb:	je     995 <botlish_fn_7+0x67d>
 3c1:	mov    %rax,(%rsp)
 3c5:	mov    %rax,0xb8(%rsp)
 3cd:	mov    $0x7,%esi
 3d2:	movq   $0x7,0x8(%rsp)
 3db:	mov    $0x1,%edx
 3e0:	movq   $0x1,0x10(%rsp)
 3e9:	mov    0x60(%rsp),%rdi
 3ee:	call   3f3 <botlish_fn_7+0xdb>
			3ef: R_X86_64_PLT32	rt_mutarray_create-0x4
 3f3:	test   %rax,%rax
 3f6:	je     995 <botlish_fn_7+0x67d>
 3fc:	mov    %rax,0x8(%rsp)
 401:	mov    %rax,0xb0(%rsp)
 409:	xor    %rdi,%rdi
 40c:	mov    %rdi,0x80(%rsp)
 414:	mov    0x68(%rsp),%r8
 419:	mov    0x80(%rsp),%r14
 421:	mov    0x80(%rsp),%rax
 429:	mov    %rax,0x78(%rsp)
 42e:	mov    %rax,0x88(%rsp)
 436:	cmp    %r8,%rdi
 439:	mov    %r8,0x68(%rsp)
 43e:	jl     4bf <botlish_fn_7+0x1a7>
 444:	mov    0xb0(%rsp),%rcx
 44c:	mov    0x10(%rcx),%rax
 450:	mov    0x8(%rax),%rax
 454:	mov    %rax,(%rsp)
 458:	mov    0x10(%rcx),%rcx
 45c:	mov    (%rcx),%rcx
 45f:	mov    %rcx,0x8(%rsp)
 464:	lea    0x50(%rsp),%rdx
 469:	mov    %rax,0x50(%rsp)
 46e:	mov    %rcx,0x58(%rsp)
 473:	mov    $0x2,%esi
 478:	mov    0x60(%rsp),%rdi
 47d:	call   482 <botlish_fn_7+0x16a>
			47e: R_X86_64_PLT32	rt_list_new-0x4
 482:	test   %rax,%rax
 485:	je     995 <botlish_fn_7+0x67d>
 48b:	mov    0xc0(%rsp),%rbx
 493:	mov    0xc8(%rsp),%r12
 49b:	mov    0xd0(%rsp),%r13
 4a3:	mov    0xd8(%rsp),%r14
 4ab:	mov    0xe0(%rsp),%r15
 4b3:	add    $0xf0,%rsp
 4ba:	mov    %rbp,%rsp
 4bd:	pop    %rbp
 4be:	ret
 4bf:	mov    0xb8(%rsp),%rbx
 4c7:	mov    0x8(%rbx),%rsi
 4cb:	mov    %rdi,%rdx
 4ce:	and    $0x7,%rdx
 4d2:	shl    $1,%rdx
 4d5:	or     $0x1,%rdx
 4d9:	sar    $1,%rdx
 4dc:	cmp    %rsi,%rdx
 4df:	jb     51e <botlish_fn_7+0x206>
 4e5:	mov    %rdi,%rdx
 4e8:	and    $0x7,%rdx
 4ec:	mov    %rdi,0x80(%rsp)
 4f4:	shl    $1,%rdx
 4f7:	or     $0x1,%rdx
 4fb:	mov    %rbx,%rsi
 4fe:	mov    0x60(%rsp),%rdi
 503:	call   508 <botlish_fn_7+0x1f0>
			504: R_X86_64_PLT32	rt_list_get-0x4
 508:	mov    %rbx,0xb8(%rsp)
 510:	test   %rax,%rax
 513:	je     995 <botlish_fn_7+0x67d>
 519:	jmp    539 <botlish_fn_7+0x221>
 51e:	mov    %rbx,%rcx
 521:	mov    %rdi,0x80(%rsp)
 529:	mov    %rbx,0xb8(%rsp)
 531:	mov    0x10(%rcx),%r11
 535:	mov    (%r11,%rdx,8),%rax
 539:	movq   $0xa,0x40(%rsp)
 542:	movq   $0xa,0x48(%rsp)
 54b:	movq   $0xa,0x30(%rsp)
 554:	movq   $0xa,0x38(%rsp)
 55d:	mov    %rax,0x40(%rsp)
 562:	mov    %rax,%r15
 565:	movq   $0x45,0x30(%rsp)
 56e:	mov    0xb0(%rsp),%rcx
 576:	mov    0x18(%rcx),%rax
 57a:	test   %rax,%rax
 57d:	je     e88 <botlish_fn_7+0xb70>
 583:	mov    0xb0(%rsp),%rcx
 58b:	mov    0x10(%rcx),%rax
 58f:	movq   $0x45,0x10(%rax)
 597:	mov    $0x1,%ebx
 59c:	mov    $0xa,%eax
 5a1:	mov    %rax,0x70(%rsp)
 5a6:	mov    $0x45,%r12d
 5ac:	mov    $0x10,%eax
 5b1:	mov    %rax,0xa8(%rsp)
 5b9:	mov    $0x3,%eax
 5be:	mov    %rax,0xa0(%rsp)
 5c6:	mov    $0x2,%eax
 5cb:	mov    %rax,0x98(%rsp)
 5d3:	mov    $0x7fffffff,%eax
 5d8:	mov    %rax,%rcx
 5db:	neg    %rcx
 5de:	cmovs  %rax,%rcx
 5e2:	mov    %rcx,0x90(%rsp)
 5ea:	test   %rbx,%rbx
 5ed:	jl     e65 <botlish_fn_7+0xb4d>
 5f3:	movq   $0x1,0x10(%rsp)
 5fc:	mov    0xb0(%rsp),%rcx
 604:	mov    0x10(%rcx),%rax
 608:	mov    (%rax),%rsi
 60b:	mov    %rsi,0x18(%rsp)
 610:	mov    0xb0(%rsp),%rcx
 618:	mov    0x10(%rcx),%rax
 61c:	mov    0x10(%rax),%rdx
 620:	mov    %rdx,0x20(%rsp)
 625:	mov    %rdx,%r13
 628:	movq   $0x3f,0x28(%rsp)
 631:	test   $0x1,%rsi
 638:	je     662 <botlish_fn_7+0x34a>
 63e:	mov    %rsi,%rax
 641:	sar    $1,%rax
 644:	imulq  0x8bd(%rip)        # f08 <botlish_fn_7+0xbf0>
 64b:	seto   %cl
 64e:	or     $0x1,%rax
 652:	test   %cl,%cl
 654:	jne    662 <botlish_fn_7+0x34a>
 65a:	mov    %rax,%rsi
 65d:	jmp    674 <botlish_fn_7+0x35c>
 662:	mov    $0x3f,%edx
 667:	mov    0x60(%rsp),%rdi
 66c:	call   671 <botlish_fn_7+0x359>
			66d: R_X86_64_PLT32	rt_int_mul-0x4
 671:	mov    %rax,%rsi
 674:	mov    %rsi,0x18(%rsp)
 679:	mov    %r13,%rdx
 67c:	mov    %rsi,%rax
 67f:	and    %rdx,%rax
 682:	test   $0x1,%rax
 688:	je     6a3 <botlish_fn_7+0x38b>
 68e:	lea    -0x1(%rdx),%rcx
 692:	mov    %rsi,%rax
 695:	add    %rcx,%rax
 698:	seto   %cl
 69b:	test   %cl,%cl
 69d:	je     6ad <botlish_fn_7+0x395>
 6a3:	mov    0x60(%rsp),%rdi
 6a8:	call   6ad <botlish_fn_7+0x395>
			6a9: R_X86_64_PLT32	rt_int_add-0x4
 6ad:	mov    %rax,0x18(%rsp)
 6b2:	movq   $0x3,0x20(%rsp)
 6bb:	test   $0x1,%rax
 6c1:	jne    6cf <botlish_fn_7+0x3b7>
 6c7:	mov    %rax,%rsi
 6ca:	jmp    6e7 <botlish_fn_7+0x3cf>
 6cf:	mov    %rax,%rsi
 6d2:	add    $0x2,%rsi
 6d6:	mov    %rax,%rcx
 6d9:	seto   %al
 6dc:	test   %al,%al
 6de:	je     6fc <botlish_fn_7+0x3e4>
 6e4:	mov    %rcx,%rsi
 6e7:	mov    0xa0(%rsp),%rdx
 6ef:	mov    0x60(%rsp),%rdi
 6f4:	call   6f9 <botlish_fn_7+0x3e1>
			6f5: R_X86_64_PLT32	rt_int_add-0x4
 6f9:	mov    %rax,%rsi
 6fc:	mov    %rsi,0x18(%rsp)
 701:	mov    $0xffffffff,%edi
 706:	mov    %rdi,0x20(%rsp)
 70b:	test   $0x1,%rsi
 712:	jne    75b <botlish_fn_7+0x443>
 718:	mov    $0xffffffff,%edx
 71d:	mov    0x60(%rsp),%rdi
 722:	call   727 <botlish_fn_7+0x40f>
			723: R_X86_64_PLT32	rt_int_mod-0x4
 727:	test   %rax,%rax
 72a:	jne    74b <botlish_fn_7+0x433>
 730:	mov    0x60(%rsp),%rdi
 735:	call   73a <botlish_fn_7+0x422>
			736: R_X86_64_PLT32	rt_declared_error-0x4
 73a:	cmp    $0x40000001,%rax
 740:	jne    995 <botlish_fn_7+0x67d>
 746:	jmp    995 <botlish_fn_7+0x67d>
 74b:	mov    %rax,%rcx
 74e:	mov    0xb0(%rsp),%r8
 756:	jmp    7a9 <botlish_fn_7+0x491>
 75b:	sar    $1,%rsi
 75e:	mov    %rsi,%rax
 761:	imulq  0x7a8(%rip)        # f10 <botlish_fn_7+0xbf8>
 768:	lea    (%rdx,%rsi,1),%rax
 76c:	sar    $0x1e,%rax
 770:	mov    %rax,%rcx
 773:	shr    $0x3f,%rcx
 777:	add    %rcx,%rax
 77a:	imul   $0x7fffffff,%rax,%rax
 781:	sub    %rax,%rsi
 784:	mov    0x90(%rsp),%rcx
 78c:	lea    (%rsi,%rcx,1),%rax
 790:	test   %rsi,%rsi
 793:	cmovl  %rax,%rsi
 797:	shl    $1,%rsi
 79a:	or     $0x1,%rsi
 79e:	mov    %rsi,%rcx
 7a1:	mov    0xb0(%rsp),%r8
 7a9:	mov    0xb0(%rsp),%r8
 7b1:	mov    0x18(%r8),%rax
 7b5:	test   %rax,%rax
 7b8:	je     ea9 <botlish_fn_7+0xb91>
 7be:	mov    0xb0(%rsp),%rax
 7c6:	mov    0x10(%rax),%rax
 7ca:	mov    %rcx,(%rax)
 7cd:	movq   $0x3,0x10(%rsp)
 7d6:	mov    0xb0(%rsp),%rcx
 7de:	mov    0x10(%rcx),%rcx
 7e2:	mov    $0x8,%r13d
 7e8:	mov    0x8(%rcx),%rsi
 7ec:	mov    %rsi,0x18(%rsp)
 7f1:	movq   $0x3,0x20(%rsp)
 7fa:	test   $0x1,%rsi
 801:	je     826 <botlish_fn_7+0x50e>
 807:	mov    %rsi,%rcx
 80a:	add    $0x2,%rcx
 80e:	seto   %al
 811:	test   %al,%al
 813:	jne    826 <botlish_fn_7+0x50e>
 819:	mov    0xb0(%rsp),%rax
 821:	jmp    843 <botlish_fn_7+0x52b>
 826:	mov    0xa0(%rsp),%rdx
 82e:	mov    0x60(%rsp),%rdi
 833:	call   838 <botlish_fn_7+0x520>
			834: R_X86_64_PLT32	rt_int_add-0x4
 838:	mov    %rax,%rcx
 83b:	mov    0xb0(%rsp),%rax
 843:	mov    0xb0(%rsp),%rax
 84b:	mov    0x18(%rax),%rax
 84f:	test   %rax,%rax
 852:	je     ec5 <botlish_fn_7+0xbad>
 858:	mov    0xb0(%rsp),%rax
 860:	mov    0x10(%rax),%rax
 864:	mov    %rcx,0x8(%rax)
 868:	cmp    $0x1,%rbx
 86c:	je     d10 <botlish_fn_7+0x9f8>
 872:	cmp    $0x2,%rbx
 876:	je     cee <botlish_fn_7+0x9d6>
 87c:	cmp    $0x3,%rbx
 880:	je     cd5 <botlish_fn_7+0x9bd>
 886:	cmp    $0x4,%rbx
 88a:	je     baf <botlish_fn_7+0x897>
 890:	cmp    $0x5,%rbx
 894:	je     b95 <botlish_fn_7+0x87d>
 89a:	cmp    $0x6,%rbx
 89e:	je     b83 <botlish_fn_7+0x86b>
 8a4:	cmp    $0x7,%rbx
 8a8:	je     b71 <botlish_fn_7+0x859>
 8ae:	cmp    $0x8,%rbx
 8b2:	je     b5f <botlish_fn_7+0x847>
 8b8:	cmp    $0x9,%rbx
 8bc:	je     b4d <botlish_fn_7+0x835>
 8c2:	cmp    $0xa,%rbx
 8c6:	je     b24 <botlish_fn_7+0x80c>
 8cc:	cmp    $0xb,%rbx
 8d0:	je     afb <botlish_fn_7+0x7e3>
 8d6:	cmp    $0xc,%rbx
 8da:	je     a8e <botlish_fn_7+0x776>
 8e0:	cmp    $0xd,%rbx
 8e4:	je     a10 <botlish_fn_7+0x6f8>
 8ea:	cmp    $0xe,%rbx
 8ee:	je     a10 <botlish_fn_7+0x6f8>
 8f4:	cmp    $0xf,%rbx
 8f8:	je     9fe <botlish_fn_7+0x6e6>
 8fe:	cmp    $0x10,%rbx
 902:	je     9fe <botlish_fn_7+0x6e6>
 908:	cmp    $0x11,%rbx
 90c:	je     9ec <botlish_fn_7+0x6d4>
 912:	cmp    $0x12,%rbx
 916:	je     9cc <botlish_fn_7+0x6b4>
 91c:	cmp    $0xffffffffffffffff,%rbx
 920:	jne    933 <botlish_fn_7+0x61b>
 926:	mov    %r15,%r13
 929:	mov    0x78(%rsp),%r15
 92e:	jmp    e33 <botlish_fn_7+0xb1b>
 933:	mov    $0xa,%esi
 938:	mov    0x60(%rsp),%rdi
 93d:	call   942 <botlish_fn_7+0x62a>
			93e: R_X86_64_PLT32	rt_co_resume0-0x4
 942:	test   %rax,%rax
 945:	je     960 <botlish_fn_7+0x648>
 94b:	mov    0x60(%rsp),%rdi
 950:	mov    0x10(%rdi),%rax
 954:	mov    (%rax),%rsi
 957:	mov    0x70(%rax),%rdx
 95b:	call   960 <botlish_fn_7+0x648>
			95c: R_X86_64_PLT32	rt_raise-0x4
 960:	mov    0x60(%rsp),%rdi
 965:	call   96a <botlish_fn_7+0x652>
			966: R_X86_64_PLT32	rt_declared_error-0x4
 96a:	cmp    $0x40000001,%rax
 970:	je     980 <botlish_fn_7+0x668>
 976:	mov    0x60(%rsp),%rdi
 97b:	jmp    985 <botlish_fn_7+0x66d>
 980:	mov    0x60(%rsp),%rdi
 985:	mov    0x60(%rsp),%rdi
 98a:	call   98f <botlish_fn_7+0x677>
			98b: R_X86_64_PLT32	rt_declared_error-0x4
 98f:	cmp    $0x40000001,%rax
 995:	xor    %rax,%rax
 998:	mov    0xc0(%rsp),%rbx
 9a0:	mov    0xc8(%rsp),%r12
 9a8:	mov    0xd0(%rsp),%r13
 9b0:	mov    0xd8(%rsp),%r14
 9b8:	mov    0xe0(%rsp),%r15
 9c0:	add    $0xf0,%rsp
 9c7:	mov    %rbp,%rsp
 9ca:	pop    %rbp
 9cb:	ret
 9cc:	mov    $0xffffffffffffffff,%r12
 9d3:	movq   $0xffffffffffffffff,0x30(%rsp)
 9dc:	mov    %r15,%r13
 9df:	mov    0x78(%rsp),%r15
 9e4:	mov    %r12,%rbx
 9e7:	jmp    e33 <botlish_fn_7+0xb1b>
 9ec:	mov    $0xa,%eax
 9f1:	mov    0x88(%rsp),%rcx
 9f9:	jmp    ba2 <botlish_fn_7+0x88a>
 9fe:	mov    $0xa,%eax
 a03:	mov    0x88(%rsp),%rcx
 a0b:	jmp    b9d <botlish_fn_7+0x885>
 a10:	mov    $0xf,%ebx
 a15:	mov    0x88(%rsp),%rcx
 a1d:	mov    %rcx,%rax
 a20:	and    $0xf,%rax
 a24:	cmp    $0xa,%rax
 a28:	jl     a62 <botlish_fn_7+0x74a>
 a2e:	mov    %rcx,%rax
 a31:	and    $0xf,%rax
 a35:	lea    0x57(%rax),%r12
 a39:	shl    $1,%r12
 a3c:	or     $0x1,%r12
 a40:	mov    %r12,0x30(%rsp)
 a45:	mov    %rcx,0x88(%rsp)
 a4d:	mov    %r15,%r13
 a50:	mov    0x78(%rsp),%r15
 a55:	mov    0xa8(%rsp),%rbx
 a5d:	jmp    e33 <botlish_fn_7+0xb1b>
 a62:	mov    %rcx,%rax
 a65:	and    $0xf,%rax
 a69:	lea    0x30(%rax),%r12
 a6d:	shl    $1,%r12
 a70:	or     $0x1,%r12
 a74:	mov    %r12,0x30(%rsp)
 a79:	mov    %rcx,0x88(%rsp)
 a81:	mov    %r15,%r13
 a84:	mov    0x78(%rsp),%r15
 a89:	jmp    e33 <botlish_fn_7+0xb1b>
 a8e:	mov    0x88(%rsp),%rcx
 a96:	mov    %rcx,%rax
 a99:	sar    $0x4,%rax
 a9d:	cmp    $0xa,%rax
 aa1:	jl     ad1 <botlish_fn_7+0x7b9>
 aa7:	lea    0x57(%rax),%r12
 aab:	shl    $1,%r12
 aae:	or     $0x1,%r12
 ab2:	mov    %r12,0x30(%rsp)
 ab7:	mov    $0xe,%ebx
 abc:	mov    %rcx,0x88(%rsp)
 ac4:	mov    %r15,%r13
 ac7:	mov    0x78(%rsp),%r15
 acc:	jmp    e33 <botlish_fn_7+0xb1b>
 ad1:	lea    0x30(%rax),%r12
 ad5:	shl    $1,%r12
 ad8:	or     $0x1,%r12
 adc:	mov    %r12,0x30(%rsp)
 ae1:	mov    $0xd,%ebx
 ae6:	mov    %rcx,0x88(%rsp)
 aee:	mov    %r15,%r13
 af1:	mov    0x78(%rsp),%r15
 af6:	jmp    e33 <botlish_fn_7+0xb1b>
 afb:	mov    0x88(%rsp),%rcx
 b03:	mov    $0x61,%r12d
 b09:	movq   $0x61,0x30(%rsp)
 b12:	mov    $0xc,%ebx
 b17:	mov    %r15,%r13
 b1a:	mov    0x78(%rsp),%r15
 b1f:	jmp    e33 <botlish_fn_7+0xb1b>
 b24:	mov    0x88(%rsp),%rcx
 b2c:	mov    $0x61,%r12d
 b32:	movq   $0x61,0x30(%rsp)
 b3b:	mov    $0xb,%ebx
 b40:	mov    %r15,%r13
 b43:	mov    0x78(%rsp),%r15
 b48:	jmp    e33 <botlish_fn_7+0xb1b>
 b4d:	mov    0x88(%rsp),%rcx
 b55:	mov    $0xa,%eax
 b5a:	jmp    b9d <botlish_fn_7+0x885>
 b5f:	mov    0x88(%rsp),%rcx
 b67:	mov    $0xa,%eax
 b6c:	jmp    b9d <botlish_fn_7+0x885>
 b71:	mov    0x88(%rsp),%rcx
 b79:	mov    $0xa,%eax
 b7e:	jmp    b9d <botlish_fn_7+0x885>
 b83:	mov    0x88(%rsp),%rcx
 b8b:	mov    $0xa,%eax
 b90:	jmp    b9d <botlish_fn_7+0x885>
 b95:	mov    0x88(%rsp),%rcx
 b9d:	mov    $0xa,%eax
 ba2:	mov    %rcx,0x88(%rsp)
 baa:	jmp    cd5 <botlish_fn_7+0x9bd>
 baf:	mov    0x88(%rsp),%rcx
 bb7:	cmp    $0x8,%rcx
 bbb:	je     cac <botlish_fn_7+0x994>
 bc1:	mov    $0x9,%ebx
 bc6:	cmp    $0x9,%rcx
 bca:	je     c83 <botlish_fn_7+0x96b>
 bd0:	cmp    $0xa,%rcx
 bd4:	je     c5a <botlish_fn_7+0x942>
 bda:	cmp    $0xc,%rcx
 bde:	je     c33 <botlish_fn_7+0x91b>
 be4:	cmp    $0xd,%rcx
 be8:	mov    %rcx,0x88(%rsp)
 bf0:	je     c17 <botlish_fn_7+0x8ff>
 bf6:	mov    $0xeb,%r12d
 bfc:	movq   $0xeb,0x30(%rsp)
 c05:	mov    $0xa,%ebx
 c0a:	mov    %r15,%r13
 c0d:	mov    0x78(%rsp),%r15
 c12:	jmp    e33 <botlish_fn_7+0xb1b>
 c17:	mov    $0xe5,%r12d
 c1d:	movq   $0xe5,0x30(%rsp)
 c26:	mov    %r15,%r13
 c29:	mov    0x78(%rsp),%r15
 c2e:	jmp    e33 <botlish_fn_7+0xb1b>
 c33:	mov    %rcx,0x88(%rsp)
 c3b:	mov    $0xcd,%r12d
 c41:	movq   $0xcd,0x30(%rsp)
 c4a:	mov    %r13,%rbx
 c4d:	mov    %r15,%r13
 c50:	mov    0x78(%rsp),%r15
 c55:	jmp    e33 <botlish_fn_7+0xb1b>
 c5a:	mov    %rcx,0x88(%rsp)
 c62:	mov    $0xdd,%r12d
 c68:	movq   $0xdd,0x30(%rsp)
 c71:	mov    $0x7,%ebx
 c76:	mov    %r15,%r13
 c79:	mov    0x78(%rsp),%r15
 c7e:	jmp    e33 <botlish_fn_7+0xb1b>
 c83:	mov    %rcx,0x88(%rsp)
 c8b:	mov    $0xe9,%r12d
 c91:	movq   $0xe9,0x30(%rsp)
 c9a:	mov    $0x6,%ebx
 c9f:	mov    %r15,%r13
 ca2:	mov    0x78(%rsp),%r15
 ca7:	jmp    e33 <botlish_fn_7+0xb1b>
 cac:	mov    %rcx,0x88(%rsp)
 cb4:	mov    $0xc5,%r12d
 cba:	movq   $0xc5,0x30(%rsp)
 cc3:	mov    $0x5,%ebx
 cc8:	mov    %r15,%r13
 ccb:	mov    0x78(%rsp),%r15
 cd0:	jmp    e33 <botlish_fn_7+0xb1b>
 cd5:	add    $0x1,%r14
 cdc:	mov    %r15,%r13
 cdf:	mov    0x78(%rsp),%r15
 ce4:	mov    0x70(%rsp),%rax
 ce9:	jmp    d29 <botlish_fn_7+0xa11>
 cee:	mov    0x70(%rsp),%rax
 cf3:	mov    %rax,0x30(%rsp)
 cf8:	mov    %r15,%r13
 cfb:	mov    0x78(%rsp),%r15
 d00:	mov    %rax,%r12
 d03:	mov    0xa0(%rsp),%rbx
 d0b:	jmp    e33 <botlish_fn_7+0xb1b>
 d10:	mov    0x70(%rsp),%rax
 d15:	mov    %r15,%r13
 d18:	mov    0x8(%r13),%r15
 d1c:	xor    %r14,%r14
 d1f:	shl    $1,%r15
 d22:	or     $0x1,%r15
 d26:	sar    $1,%r15
 d29:	cmp    %r15,%r14
 d2c:	jl     d50 <botlish_fn_7+0xa38>
 d32:	mov    $0x45,%r12d
 d38:	movq   $0x45,0x30(%rsp)
 d41:	mov    $0x12,%ebx
 d46:	mov    %rax,0x70(%rsp)
 d4b:	jmp    e33 <botlish_fn_7+0xb1b>
 d50:	movzbq 0x18(%r13),%rax
 d55:	test   %rax,%rax
 d58:	jne    d7a <botlish_fn_7+0xa62>
 d5e:	mov    %r14,%rdx
 d61:	shl    $1,%rdx
 d64:	or     $0x1,%rdx
 d68:	mov    %r13,%rsi
 d6b:	mov    0x60(%rsp),%rdi
 d70:	call   d75 <botlish_fn_7+0xa5d>
			d71: R_X86_64_PLT32	rt_str_char_at_proven-0x4
 d75:	jmp    d95 <botlish_fn_7+0xa7d>
 d7a:	mov    %r14,%rax
 d7d:	shl    $1,%rax
 d80:	or     $0x1,%rax
 d84:	sar    $1,%rax
 d87:	movzbq 0x19(%r13,%rax,1),%rax
 d8d:	shl    $0x3,%rax
 d91:	or     $0x4,%rax
 d95:	shr    $0x3,%rax
 d99:	shl    $1,%rax
 d9c:	or     $0x1,%rax
 da0:	mov    %rax,0x48(%rsp)
 da5:	mov    %rax,%rcx
 da8:	sar    $1,%rcx
 dab:	cmp    $0x22,%rcx
 daf:	jne    dbf <botlish_fn_7+0xaa7>
 db5:	mov    %rax,0x70(%rsp)
 dba:	jmp    e1c <botlish_fn_7+0xb04>
 dbf:	cmp    $0x5c,%rcx
 dc3:	jne    dd3 <botlish_fn_7+0xabb>
 dc9:	mov    %rax,0x70(%rsp)
 dce:	jmp    e1c <botlish_fn_7+0xb04>
 dd3:	cmp    $0x20,%rcx
 dd7:	jl     df6 <botlish_fn_7+0xade>
 ddd:	mov    %rax,0x30(%rsp)
 de2:	mov    %rax,0x70(%rsp)
 de7:	mov    $0x11,%ebx
 dec:	mov    0x70(%rsp),%r12
 df1:	jmp    e33 <botlish_fn_7+0xb1b>
 df6:	mov    %rax,0x70(%rsp)
 dfb:	mov    $0xb9,%r12d
 e01:	movq   $0xb9,0x30(%rsp)
 e0a:	mov    $0x4,%ebx
 e0f:	mov    %rcx,0x88(%rsp)
 e17:	jmp    e33 <botlish_fn_7+0xb1b>
 e1c:	mov    $0xb9,%r12d
 e22:	movq   $0xb9,0x30(%rsp)
 e2b:	mov    0x98(%rsp),%rbx
 e33:	mov    0xb0(%rsp),%rcx
 e3b:	mov    0x18(%rcx),%rcx
 e3f:	test   %rcx,%rcx
 e42:	je     ee4 <botlish_fn_7+0xbcc>
 e48:	mov    0xb0(%rsp),%rcx
 e50:	mov    0x10(%rcx),%rsi
 e54:	mov    %r12,0x10(%rsi)
 e58:	mov    %r15,0x78(%rsp)
 e5d:	mov    %r13,%r15
 e60:	jmp    5ea <botlish_fn_7+0x2d2>
 e65:	mov    0x78(%rsp),%r15
 e6a:	mov    0x80(%rsp),%rdi
 e72:	add    $0x1,%rdi
 e79:	mov    0x68(%rsp),%r8
 e7e:	mov    %r15,0x78(%rsp)
 e83:	jmp    436 <botlish_fn_7+0x11e>
 e88:	mov    $0x5,%edx
 e8d:	mov    $0x45,%ecx
 e92:	mov    0xb0(%rsp),%rsi
 e9a:	mov    0x60(%rsp),%rdi
 e9f:	call   ea4 <botlish_fn_7+0xb8c>
			ea0: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 ea4:	jmp    597 <botlish_fn_7+0x27f>
 ea9:	mov    $0x1,%edx
 eae:	mov    0xb0(%rsp),%rsi
 eb6:	mov    0x60(%rsp),%rdi
 ebb:	call   ec0 <botlish_fn_7+0xba8>
			ebc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 ec0:	jmp    7cd <botlish_fn_7+0x4b5>
 ec5:	mov    0xa0(%rsp),%rdx
 ecd:	mov    0xb0(%rsp),%rsi
 ed5:	mov    0x60(%rsp),%rdi
 eda:	call   edf <botlish_fn_7+0xbc7>
			edb: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 edf:	jmp    868 <botlish_fn_7+0x550>
 ee4:	mov    $0x5,%edx
 ee9:	mov    %r12,%rcx
 eec:	mov    0xb0(%rsp),%rsi
 ef4:	mov    0x60(%rsp),%rdi
 ef9:	call   efe <botlish_fn_7+0xbe6>
			efa: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 efe:	jmp    e58 <botlish_fn_7+0xb40>
 f03:	add    %al,(%rax)
 f05:	add    %al,(%rax)
 f07:	add    %bh,(%rsi)
 f09:	add    %al,(%rax)
 f0b:	add    %al,(%rax)
 f0d:	add    %al,(%rax)
 f0f:	add    %al,(%rbx)
 f11:	add    %al,(%rax)
 f13:	add    %al,(%rcx)
 f15:	add    %al,(%rax)
 f17:	.byte 0x80

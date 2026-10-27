<botlish_fn_37>:
    5290:	push   %rbp
    5291:	mov    %rsp,%rbp
    5294:	sub    $0x150,%rsp
    529b:	mov    %rbx,0x120(%rsp)
    52a3:	mov    %r12,0x128(%rsp)
    52ab:	mov    %r13,0x130(%rsp)
    52b3:	mov    %r14,0x138(%rsp)
    52bb:	mov    %r15,0x140(%rsp)
    52c3:	mov    %rdi,%r13
    52c6:	movq   $0x0,(%rsp)
    52ce:	movq   $0x0,0x8(%rsp)
    52d7:	movq   $0x0,0x10(%rsp)
    52e0:	movq   $0x0,0x18(%rsp)
    52e9:	movq   $0x0,0x20(%rsp)
    52f2:	movq   $0x0,0x28(%rsp)
    52fb:	movq   $0x0,0x30(%rsp)
    5304:	mov    %r13,%rdi
    5307:	call   530c <botlish_fn_37+0x7c>
			5308: R_X86_64_PLT32	botlish_fn_36-0x4
    530c:	test   %rax,%rax
    530f:	je     5bdc <botlish_fn_37+0x94c>
    5315:	mov    %rax,(%rsp)
    5319:	mov    %rax,%r12
    531c:	mov    $0x7,%esi
    5321:	movq   $0x7,0x8(%rsp)
    532a:	mov    $0x1,%edx
    532f:	movq   $0x1,0x10(%rsp)
    5338:	mov    %r13,%rdi
    533b:	call   5340 <botlish_fn_37+0xb0>
			533c: R_X86_64_PLT32	rt_mutarray_create-0x4
    5340:	mov    %rax,%rbx
    5343:	test   %rbx,%rbx
    5346:	je     5bdc <botlish_fn_37+0x94c>
    534c:	mov    %rbx,0x8(%rsp)
    5351:	lea    0x38(%rsp),%r8
    5356:	mov    %r12,%rax
    5359:	mov    %rax,0x38(%rsp)
    535e:	mov    $0x26,%esi
    5363:	mov    0x0(%rip),%rdx        # 536a <botlish_fn_37+0xda>
			5366: R_X86_64_GOTPCREL	botlish_entry_38-0x4
    536a:	mov    $0x1,%ecx
    536f:	mov    %r13,%rdi
    5372:	call   5377 <botlish_fn_37+0xe7>
			5373: R_X86_64_PLT32	rt_closure_new-0x4
    5377:	mov    %rax,(%rsp)
    537b:	mov    %rax,%rsi
    537e:	mov    %r13,%rdi
    5381:	call   5386 <botlish_fn_37+0xf6>
			5382: R_X86_64_PLT32	rt_co_create-0x4
    5386:	mov    %rax,0x110(%rsp)
    538e:	mov    %rax,(%rsp)
    5392:	mov    0x110(%rsp),%rsi
    539a:	mov    %r13,%rdi
    539d:	call   53a2 <botlish_fn_37+0x112>
			539e: R_X86_64_PLT32	rt_co_start-0x4
    53a2:	test   %rax,%rax
    53a5:	jne    53d4 <botlish_fn_37+0x144>
    53ab:	mov    %r13,%rdi
    53ae:	call   53b3 <botlish_fn_37+0x123>
			53af: R_X86_64_PLT32	rt_declared_error-0x4
    53b3:	cmp    $0x40000001,%rax
    53b9:	jne    5bdc <botlish_fn_37+0x94c>
    53bf:	mov    0x110(%rsp),%rsi
    53c7:	mov    %r13,%rdi
    53ca:	call   53cf <botlish_fn_37+0x13f>
			53cb: R_X86_64_PLT32	rt_co_release-0x4
    53cf:	jmp    5bdc <botlish_fn_37+0x94c>
    53d4:	mov    %rax,0x10(%rsp)
    53d9:	lea    0x40(%rsp),%r8
    53de:	mov    %rax,0x40(%rsp)
    53e3:	mov    %rax,%r12
    53e6:	mov    $0x27,%esi
    53eb:	mov    0x0(%rip),%rdx        # 53f2 <botlish_fn_37+0x162>
			53ee: R_X86_64_GOTPCREL	botlish_entry_39-0x4
    53f2:	mov    $0x1,%ecx
    53f7:	mov    %r13,%rdi
    53fa:	call   53ff <botlish_fn_37+0x16f>
			53fb: R_X86_64_PLT32	rt_closure_new-0x4
    53ff:	mov    %rax,0x18(%rsp)
    5404:	mov    %rax,%rsi
    5407:	mov    %r13,%rdi
    540a:	call   540f <botlish_fn_37+0x17f>
			540b: R_X86_64_PLT32	rt_co_create-0x4
    540f:	mov    %rax,%r14
    5412:	mov    %rax,0x18(%rsp)
    5417:	mov    %r14,%rsi
    541a:	mov    %r13,%rdi
    541d:	call   5422 <botlish_fn_37+0x192>
			541e: R_X86_64_PLT32	rt_co_start-0x4
    5422:	test   %rax,%rax
    5425:	jne    5562 <botlish_fn_37+0x2d2>
    542b:	mov    %r13,%rdi
    542e:	call   5433 <botlish_fn_37+0x1a3>
			542f: R_X86_64_PLT32	rt_declared_error-0x4
    5433:	cmp    $0x1,%rax
    5437:	je     54d7 <botlish_fn_37+0x247>
    543d:	mov    %r13,%rdi
    5440:	call   5445 <botlish_fn_37+0x1b5>
			5441: R_X86_64_PLT32	rt_declared_error-0x4
    5445:	cmp    $0x2,%rax
    5449:	jne    5bdc <botlish_fn_37+0x94c>
    544f:	xor    %rbx,%rbx
    5452:	mov    %rbx,%rsi
    5455:	mov    %r13,%rdi
    5458:	call   545d <botlish_fn_37+0x1cd>
			5459: R_X86_64_PLT32	rt_declared_payload-0x4
    545d:	mov    %rax,%r12
    5460:	mov    $0x1,%esi
    5465:	mov    %r13,%rdi
    5468:	call   546d <botlish_fn_37+0x1dd>
			5469: R_X86_64_PLT32	rt_declared_payload-0x4
    546d:	mov    %rax,%r15
    5470:	mov    %r13,%rdi
    5473:	call   5478 <botlish_fn_37+0x1e8>
			5474: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5478:	mov    0x110(%rsp),%rsi
    5480:	mov    %r13,%rdi
    5483:	call   5488 <botlish_fn_37+0x1f8>
			5484: R_X86_64_PLT32	rt_co_release-0x4
    5488:	mov    %r14,%rsi
    548b:	mov    %r13,%rdi
    548e:	call   5493 <botlish_fn_37+0x203>
			548f: R_X86_64_PLT32	rt_co_release-0x4
    5493:	mov    %r13,%rdi
    5496:	mov    0x10(%rdi),%rax
    549a:	mov    0x1d8(%rax),%rdx
    54a1:	lea    0x60(%rsp),%r9
    54a6:	movq   $0x1,0x60(%rsp)
    54af:	mov    %r12,%rax
    54b2:	mov    %rax,0x68(%rsp)
    54b7:	mov    %r15,%rax
    54ba:	mov    %rax,0x70(%rsp)
    54bf:	mov    $0xc,%esi
    54c4:	mov    $0x3,%r8d
    54ca:	mov    %rbx,%rcx
    54cd:	call   54d2 <botlish_fn_37+0x242>
			54ce: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    54d2:	jmp    5bdc <botlish_fn_37+0x94c>
    54d7:	xor    %rbx,%rbx
    54da:	mov    %rbx,%rsi
    54dd:	mov    %r13,%rdi
    54e0:	call   54e5 <botlish_fn_37+0x255>
			54e1: R_X86_64_PLT32	rt_declared_payload-0x4
    54e5:	mov    %rbx,%r12
    54e8:	mov    %rax,%rbx
    54eb:	mov    $0x1,%esi
    54f0:	mov    %r13,%rdi
    54f3:	call   54f8 <botlish_fn_37+0x268>
			54f4: R_X86_64_PLT32	rt_declared_payload-0x4
    54f8:	mov    %rax,%r15
    54fb:	mov    %r13,%rdi
    54fe:	call   5503 <botlish_fn_37+0x273>
			54ff: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5503:	mov    0x110(%rsp),%rsi
    550b:	mov    %r13,%rdi
    550e:	call   5513 <botlish_fn_37+0x283>
			550f: R_X86_64_PLT32	rt_co_release-0x4
    5513:	mov    %r14,%rsi
    5516:	mov    %r13,%rdi
    5519:	call   551e <botlish_fn_37+0x28e>
			551a: R_X86_64_PLT32	rt_co_release-0x4
    551e:	mov    %r13,%rdi
    5521:	mov    0x10(%rdi),%rax
    5525:	mov    0x1d8(%rax),%rdx
    552c:	lea    0x48(%rsp),%r9
    5531:	movq   $0x1,0x48(%rsp)
    553a:	mov    %rbx,%rax
    553d:	mov    %rax,0x50(%rsp)
    5542:	mov    %r15,%rax
    5545:	mov    %rax,0x58(%rsp)
    554a:	mov    $0xc,%esi
    554f:	mov    $0x3,%r8d
    5555:	mov    %r12,%rcx
    5558:	call   555d <botlish_fn_37+0x2cd>
			5559: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    555d:	jmp    5bdc <botlish_fn_37+0x94c>
    5562:	mov    0x18(%rbx),%rax
    5566:	test   %rax,%rax
    5569:	je     5c47 <botlish_fn_37+0x9b7>
    556f:	mov    %r12,%rcx
    5572:	mov    0x10(%rbx),%rax
    5576:	mov    %rbx,%rdx
    5579:	mov    %rcx,0x10(%rax)
    557d:	mov    $0x3,%r8d
    5583:	mov    %r8,%r15
    5586:	mov    $0x2,%esi
    558b:	mov    %rsi,0x108(%rsp)
    5593:	mov    $0x7fffffff,%eax
    5598:	mov    %rax,%r12
    559b:	neg    %r12
    559e:	cmovs  %rax,%r12
    55a2:	movq   $0x1,0x10(%rsp)
    55ab:	mov    %rdx,%rbx
    55ae:	mov    0x10(%rbx),%rcx
    55b2:	mov    (%rcx),%rsi
    55b5:	mov    %rsi,0x20(%rsp)
    55ba:	mov    0x10(%rbx),%rdi
    55be:	mov    0x10(%rdi),%rdx
    55c2:	mov    %rdx,0x28(%rsp)
    55c7:	mov    %rdx,0x100(%rsp)
    55cf:	movq   $0x3f,0x30(%rsp)
    55d8:	test   $0x1,%rsi
    55df:	je     560b <botlish_fn_37+0x37b>
    55e5:	mov    %rsi,%rax
    55e8:	sar    $1,%rax
    55eb:	imulq  0x6b6(%rip)        # 5ca8 <botlish_fn_37+0xa18>
    55f2:	seto   %r10b
    55f6:	or     $0x1,%rax
    55fa:	test   %r10b,%r10b
    55fd:	jne    560b <botlish_fn_37+0x37b>
    5603:	mov    %rax,%rsi
    5606:	jmp    561b <botlish_fn_37+0x38b>
    560b:	mov    $0x3f,%edx
    5610:	mov    %r13,%rdi
    5613:	call   5618 <botlish_fn_37+0x388>
			5614: R_X86_64_PLT32	rt_int_mul-0x4
    5618:	mov    %rax,%rsi
    561b:	mov    %rsi,0x20(%rsp)
    5620:	mov    0x100(%rsp),%rdx
    5628:	mov    %rsi,%rax
    562b:	and    %rdx,%rax
    562e:	test   $0x1,%rax
    5634:	je     564f <botlish_fn_37+0x3bf>
    563a:	lea    -0x1(%rdx),%rcx
    563e:	mov    %rsi,%rax
    5641:	add    %rcx,%rax
    5644:	seto   %cl
    5647:	test   %cl,%cl
    5649:	je     5657 <botlish_fn_37+0x3c7>
    564f:	mov    %r13,%rdi
    5652:	call   5657 <botlish_fn_37+0x3c7>
			5653: R_X86_64_PLT32	rt_int_add-0x4
    5657:	mov    %rax,0x20(%rsp)
    565c:	movq   $0x3,0x28(%rsp)
    5665:	test   $0x1,%rax
    566b:	jne    5679 <botlish_fn_37+0x3e9>
    5671:	mov    %rax,%rsi
    5674:	jmp    5691 <botlish_fn_37+0x401>
    5679:	mov    %rax,%rsi
    567c:	add    $0x2,%rsi
    5680:	mov    %rax,%r11
    5683:	seto   %al
    5686:	test   %al,%al
    5688:	je     569f <botlish_fn_37+0x40f>
    568e:	mov    %r11,%rsi
    5691:	mov    %r15,%rdx
    5694:	mov    %r13,%rdi
    5697:	call   569c <botlish_fn_37+0x40c>
			5698: R_X86_64_PLT32	rt_int_add-0x4
    569c:	mov    %rax,%rsi
    569f:	mov    %rsi,0x20(%rsp)
    56a4:	mov    $0xffffffff,%eax
    56a9:	mov    %rax,0x28(%rsp)
    56ae:	test   $0x1,%rsi
    56b5:	jne    570d <botlish_fn_37+0x47d>
    56bb:	mov    $0xffffffff,%edx
    56c0:	mov    %r13,%rdi
    56c3:	call   56c8 <botlish_fn_37+0x438>
			56c4: R_X86_64_PLT32	rt_int_mod-0x4
    56c8:	test   %rax,%rax
    56cb:	jne    5705 <botlish_fn_37+0x475>
    56d1:	mov    %r13,%rdi
    56d4:	call   56d9 <botlish_fn_37+0x449>
			56d5: R_X86_64_PLT32	rt_declared_error-0x4
    56d9:	cmp    $0x40000001,%rax
    56df:	jne    5bdc <botlish_fn_37+0x94c>
    56e5:	mov    0x110(%rsp),%rsi
    56ed:	mov    %r13,%rdi
    56f0:	call   56f5 <botlish_fn_37+0x465>
			56f1: R_X86_64_PLT32	rt_co_release-0x4
    56f5:	mov    %r14,%rsi
    56f8:	mov    %r13,%rdi
    56fb:	call   5700 <botlish_fn_37+0x470>
			56fc: R_X86_64_PLT32	rt_co_release-0x4
    5700:	jmp    5bdc <botlish_fn_37+0x94c>
    5705:	mov    %rax,%rcx
    5708:	jmp    574b <botlish_fn_37+0x4bb>
    570d:	sar    $1,%rsi
    5710:	mov    %rsi,%rax
    5713:	imulq  0x596(%rip)        # 5cb0 <botlish_fn_37+0xa20>
    571a:	lea    (%rdx,%rsi,1),%rax
    571e:	sar    $0x1e,%rax
    5722:	mov    %rax,%rcx
    5725:	shr    $0x3f,%rcx
    5729:	add    %rcx,%rax
    572c:	imul   $0x7fffffff,%rax,%rax
    5733:	sub    %rax,%rsi
    5736:	lea    (%rsi,%r12,1),%rax
    573a:	test   %rsi,%rsi
    573d:	cmovl  %rax,%rsi
    5741:	shl    $1,%rsi
    5744:	or     $0x1,%rsi
    5748:	mov    %rsi,%rcx
    574b:	mov    0x18(%rbx),%rax
    574f:	test   %rax,%rax
    5752:	je     5c62 <botlish_fn_37+0x9d2>
    5758:	mov    0x10(%rbx),%rax
    575c:	mov    %rcx,(%rax)
    575f:	movq   $0x3,0x10(%rsp)
    5768:	mov    0x10(%rbx),%rax
    576c:	mov    0x8(%rax),%rsi
    5770:	mov    %rsi,0x20(%rsp)
    5775:	movq   $0x3,0x28(%rsp)
    577e:	test   $0x1,%rsi
    5785:	je     579d <botlish_fn_37+0x50d>
    578b:	mov    %rsi,%rcx
    578e:	add    $0x2,%rcx
    5792:	seto   %al
    5795:	test   %al,%al
    5797:	je     57ab <botlish_fn_37+0x51b>
    579d:	mov    %r15,%rdx
    57a0:	mov    %r13,%rdi
    57a3:	call   57a8 <botlish_fn_37+0x518>
			57a4: R_X86_64_PLT32	rt_int_add-0x4
    57a8:	mov    %rax,%rcx
    57ab:	mov    0x18(%rbx),%rax
    57af:	test   %rax,%rax
    57b2:	je     5c77 <botlish_fn_37+0x9e7>
    57b8:	mov    0x10(%rbx),%rsi
    57bc:	mov    %rcx,0x8(%rsi)
    57c0:	mov    0x110(%rsp),%rsi
    57c8:	mov    %r13,%rdi
    57cb:	call   57d0 <botlish_fn_37+0x540>
			57cc: R_X86_64_PLT32	rt_co_resume0-0x4
    57d0:	test   %rax,%rax
    57d3:	jne    580d <botlish_fn_37+0x57d>
    57d9:	mov    %r13,%rdi
    57dc:	call   57e1 <botlish_fn_37+0x551>
			57dd: R_X86_64_PLT32	rt_declared_error-0x4
    57e1:	cmp    $0x40000001,%rax
    57e7:	jne    5bdc <botlish_fn_37+0x94c>
    57ed:	mov    0x110(%rsp),%rsi
    57f5:	mov    %r13,%rdi
    57f8:	call   57fd <botlish_fn_37+0x56d>
			57f9: R_X86_64_PLT32	rt_co_release-0x4
    57fd:	mov    %r14,%rsi
    5800:	mov    %r13,%rdi
    5803:	call   5808 <botlish_fn_37+0x578>
			5804: R_X86_64_PLT32	rt_co_release-0x4
    5808:	jmp    5bdc <botlish_fn_37+0x94c>
    580d:	mov    %rax,0x10(%rsp)
    5812:	mov    %rax,0x100(%rsp)
    581a:	mov    0x110(%rsp),%rsi
    5822:	mov    %r13,%rdi
    5825:	call   582a <botlish_fn_37+0x59a>
			5826: R_X86_64_PLT32	rt_co_done-0x4
    582a:	cmp    $0x6,%rax
    582e:	je     59f7 <botlish_fn_37+0x767>
    5834:	lea    0x78(%rsp),%rcx
    5839:	mov    0x100(%rsp),%rax
    5841:	mov    %rax,0x78(%rsp)
    5846:	mov    $0x1,%edx
    584b:	mov    %r13,%rdi
    584e:	mov    %rdx,%rsi
    5851:	call   5856 <botlish_fn_37+0x5c6>
			5852: R_X86_64_PLT32	rt_struct_new-0x4
    5856:	mov    %rax,0x20(%rsp)
    585b:	mov    %rax,%rdx
    585e:	mov    %r14,%rsi
    5861:	mov    %r13,%rdi
    5864:	call   5869 <botlish_fn_37+0x5d9>
			5865: R_X86_64_PLT32	rt_co_resume-0x4
    5869:	test   %rax,%rax
    586c:	jne    59d2 <botlish_fn_37+0x742>
    5872:	mov    %r13,%rdi
    5875:	call   587a <botlish_fn_37+0x5ea>
			5876: R_X86_64_PLT32	rt_declared_error-0x4
    587a:	cmp    $0x1,%rax
    587e:	je     5934 <botlish_fn_37+0x6a4>
    5884:	mov    %r13,%rdi
    5887:	call   588c <botlish_fn_37+0x5fc>
			5888: R_X86_64_PLT32	rt_declared_error-0x4
    588c:	cmp    $0x2,%rax
    5890:	jne    5bdc <botlish_fn_37+0x94c>
    5896:	xor    %rbx,%rbx
    5899:	mov    %rbx,%rsi
    589c:	mov    %r13,%rdi
    589f:	call   58a4 <botlish_fn_37+0x614>
			58a0: R_X86_64_PLT32	rt_declared_payload-0x4
    58a4:	mov    %rbx,%r12
    58a7:	mov    %rax,%rbx
    58aa:	mov    $0x1,%esi
    58af:	mov    %r13,%rdi
    58b2:	call   58b7 <botlish_fn_37+0x627>
			58b3: R_X86_64_PLT32	rt_declared_payload-0x4
    58b7:	mov    %rax,0xf8(%rsp)
    58bf:	mov    %r13,%rdi
    58c2:	call   58c7 <botlish_fn_37+0x637>
			58c3: R_X86_64_PLT32	rt_clear_declared_error-0x4
    58c7:	mov    0x110(%rsp),%rsi
    58cf:	mov    %r13,%rdi
    58d2:	call   58d7 <botlish_fn_37+0x647>
			58d3: R_X86_64_PLT32	rt_co_release-0x4
    58d7:	mov    %r14,%rsi
    58da:	mov    %r13,%rdi
    58dd:	call   58e2 <botlish_fn_37+0x652>
			58de: R_X86_64_PLT32	rt_co_release-0x4
    58e2:	mov    %r13,%rdi
    58e5:	mov    0x10(%rdi),%rax
    58e9:	mov    0x1d8(%rax),%rdx
    58f0:	lea    0x98(%rsp),%r9
    58f8:	movq   $0x1,0x98(%rsp)
    5904:	mov    %rbx,%rax
    5907:	mov    %rax,0xa0(%rsp)
    590f:	mov    0xf8(%rsp),%rax
    5917:	mov    %rax,0xa8(%rsp)
    591f:	mov    $0xc,%esi
    5924:	mov    %r12,%rcx
    5927:	mov    %r15,%r8
    592a:	call   592f <botlish_fn_37+0x69f>
			592b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    592f:	jmp    5bdc <botlish_fn_37+0x94c>
    5934:	xor    %rbx,%rbx
    5937:	mov    %rbx,%rsi
    593a:	mov    %r13,%rdi
    593d:	call   5942 <botlish_fn_37+0x6b2>
			593e: R_X86_64_PLT32	rt_declared_payload-0x4
    5942:	mov    %rbx,%r12
    5945:	mov    %rax,%rbx
    5948:	mov    $0x1,%esi
    594d:	mov    %r13,%rdi
    5950:	call   5955 <botlish_fn_37+0x6c5>
			5951: R_X86_64_PLT32	rt_declared_payload-0x4
    5955:	mov    %rax,0xf8(%rsp)
    595d:	mov    %r13,%rdi
    5960:	call   5965 <botlish_fn_37+0x6d5>
			5961: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5965:	mov    0x110(%rsp),%rsi
    596d:	mov    %r13,%rdi
    5970:	call   5975 <botlish_fn_37+0x6e5>
			5971: R_X86_64_PLT32	rt_co_release-0x4
    5975:	mov    %r14,%rsi
    5978:	mov    %r13,%rdi
    597b:	call   5980 <botlish_fn_37+0x6f0>
			597c: R_X86_64_PLT32	rt_co_release-0x4
    5980:	mov    %r13,%rdi
    5983:	mov    0x10(%rdi),%rax
    5987:	mov    0x1d8(%rax),%rdx
    598e:	lea    0x80(%rsp),%r9
    5996:	movq   $0x1,0x80(%rsp)
    59a2:	mov    %rbx,%rax
    59a5:	mov    %rax,0x88(%rsp)
    59ad:	mov    0xf8(%rsp),%rax
    59b5:	mov    %rax,0x90(%rsp)
    59bd:	mov    $0xc,%esi
    59c2:	mov    %r12,%rcx
    59c5:	mov    %r15,%r8
    59c8:	call   59cd <botlish_fn_37+0x73d>
			59c9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    59cd:	jmp    5bdc <botlish_fn_37+0x94c>
    59d2:	mov    0x18(%rbx),%rax
    59d6:	test   %rax,%rax
    59d9:	je     5c8a <botlish_fn_37+0x9fa>
    59df:	mov    0x100(%rsp),%rcx
    59e7:	mov    0x10(%rbx),%rax
    59eb:	mov    %rcx,0x10(%rax)
    59ef:	mov    %rbx,%rdx
    59f2:	jmp    55a2 <botlish_fn_37+0x312>
    59f7:	mov    0x110(%rsp),%rsi
    59ff:	mov    %r13,%rdi
    5a02:	call   5a07 <botlish_fn_37+0x777>
			5a03: R_X86_64_PLT32	rt_co_release-0x4
    5a07:	movq   $0xffffffffffffffff,(%rsp)
    5a0f:	lea    0xb0(%rsp),%rcx
    5a17:	movq   $0xffffffffffffffff,0xb0(%rsp)
    5a23:	mov    $0x1,%edx
    5a28:	mov    %r13,%rdi
    5a2b:	mov    %rdx,%rsi
    5a2e:	call   5a33 <botlish_fn_37+0x7a3>
			5a2f: R_X86_64_PLT32	rt_struct_new-0x4
    5a33:	mov    %rax,(%rsp)
    5a37:	mov    %rax,%rdx
    5a3a:	mov    %r14,%rsi
    5a3d:	mov    %r13,%rdi
    5a40:	call   5a45 <botlish_fn_37+0x7b5>
			5a41: R_X86_64_PLT32	rt_co_resume-0x4
    5a45:	test   %rax,%rax
    5a48:	jne    5b88 <botlish_fn_37+0x8f8>
    5a4e:	mov    %r13,%rdi
    5a51:	call   5a56 <botlish_fn_37+0x7c6>
			5a52: R_X86_64_PLT32	rt_declared_error-0x4
    5a56:	cmp    $0x1,%rax
    5a5a:	je     5afd <botlish_fn_37+0x86d>
    5a60:	mov    %r13,%rdi
    5a63:	call   5a68 <botlish_fn_37+0x7d8>
			5a64: R_X86_64_PLT32	rt_declared_error-0x4
    5a68:	cmp    $0x2,%rax
    5a6c:	jne    5bdc <botlish_fn_37+0x94c>
    5a72:	xor    %rbx,%rbx
    5a75:	mov    %rbx,%rsi
    5a78:	mov    %r13,%rdi
    5a7b:	call   5a80 <botlish_fn_37+0x7f0>
			5a7c: R_X86_64_PLT32	rt_declared_payload-0x4
    5a80:	mov    %rax,%r12
    5a83:	mov    $0x1,%esi
    5a88:	mov    %r13,%rdi
    5a8b:	call   5a90 <botlish_fn_37+0x800>
			5a8c: R_X86_64_PLT32	rt_declared_payload-0x4
    5a90:	mov    %rax,0xf8(%rsp)
    5a98:	mov    %r13,%rdi
    5a9b:	call   5aa0 <botlish_fn_37+0x810>
			5a9c: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5aa0:	mov    %r14,%rsi
    5aa3:	mov    %r13,%rdi
    5aa6:	call   5aab <botlish_fn_37+0x81b>
			5aa7: R_X86_64_PLT32	rt_co_release-0x4
    5aab:	mov    %r13,%rdi
    5aae:	mov    0x10(%rdi),%rax
    5ab2:	mov    0x1d8(%rax),%rdx
    5ab9:	lea    0xd0(%rsp),%r9
    5ac1:	movq   $0x1,0xd0(%rsp)
    5acd:	mov    %r12,%rax
    5ad0:	mov    %rax,0xd8(%rsp)
    5ad8:	mov    0xf8(%rsp),%rax
    5ae0:	mov    %rax,0xe0(%rsp)
    5ae8:	mov    $0xc,%esi
    5aed:	mov    %rbx,%rcx
    5af0:	mov    %r15,%r8
    5af3:	call   5af8 <botlish_fn_37+0x868>
			5af4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5af8:	jmp    5bdc <botlish_fn_37+0x94c>
    5afd:	xor    %rbx,%rbx
    5b00:	mov    %rbx,%rsi
    5b03:	mov    %r13,%rdi
    5b06:	call   5b0b <botlish_fn_37+0x87b>
			5b07: R_X86_64_PLT32	rt_declared_payload-0x4
    5b0b:	mov    %rax,%r12
    5b0e:	mov    $0x1,%esi
    5b13:	mov    %r13,%rdi
    5b16:	call   5b1b <botlish_fn_37+0x88b>
			5b17: R_X86_64_PLT32	rt_declared_payload-0x4
    5b1b:	mov    %rax,0xf8(%rsp)
    5b23:	mov    %r13,%rdi
    5b26:	call   5b2b <botlish_fn_37+0x89b>
			5b27: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5b2b:	mov    %r14,%rsi
    5b2e:	mov    %r13,%rdi
    5b31:	call   5b36 <botlish_fn_37+0x8a6>
			5b32: R_X86_64_PLT32	rt_co_release-0x4
    5b36:	mov    %r13,%rdi
    5b39:	mov    0x10(%rdi),%rax
    5b3d:	mov    0x1d8(%rax),%rdx
    5b44:	lea    0xb8(%rsp),%r9
    5b4c:	movq   $0x1,0xb8(%rsp)
    5b58:	mov    %r12,%rax
    5b5b:	mov    %rax,0xc0(%rsp)
    5b63:	mov    0xf8(%rsp),%rax
    5b6b:	mov    %rax,0xc8(%rsp)
    5b73:	mov    $0xc,%esi
    5b78:	mov    %rbx,%rcx
    5b7b:	mov    %r15,%r8
    5b7e:	call   5b83 <botlish_fn_37+0x8f3>
			5b7f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5b83:	jmp    5bdc <botlish_fn_37+0x94c>
    5b88:	mov    %r14,%rsi
    5b8b:	mov    %r13,%rdi
    5b8e:	call   5b93 <botlish_fn_37+0x903>
			5b8f: R_X86_64_PLT32	rt_co_release-0x4
    5b93:	mov    0x10(%rbx),%rax
    5b97:	mov    0x8(%rax),%rax
    5b9b:	mov    %rax,(%rsp)
    5b9f:	mov    0x10(%rbx),%rcx
    5ba3:	mov    (%rcx),%rcx
    5ba6:	mov    %rcx,0x8(%rsp)
    5bab:	lea    0xe8(%rsp),%rdx
    5bb3:	mov    %rax,0xe8(%rsp)
    5bbb:	mov    %rcx,0xf0(%rsp)
    5bc3:	mov    0x108(%rsp),%rsi
    5bcb:	mov    %r13,%rdi
    5bce:	call   5bd3 <botlish_fn_37+0x943>
			5bcf: R_X86_64_PLT32	rt_list_new-0x4
    5bd3:	test   %rax,%rax
    5bd6:	jne    5c13 <botlish_fn_37+0x983>
    5bdc:	xor    %rax,%rax
    5bdf:	mov    0x120(%rsp),%rbx
    5be7:	mov    0x128(%rsp),%r12
    5bef:	mov    0x130(%rsp),%r13
    5bf7:	mov    0x138(%rsp),%r14
    5bff:	mov    0x140(%rsp),%r15
    5c07:	add    $0x150,%rsp
    5c0e:	mov    %rbp,%rsp
    5c11:	pop    %rbp
    5c12:	ret
    5c13:	mov    0x120(%rsp),%rbx
    5c1b:	mov    0x128(%rsp),%r12
    5c23:	mov    0x130(%rsp),%r13
    5c2b:	mov    0x138(%rsp),%r14
    5c33:	mov    0x140(%rsp),%r15
    5c3b:	add    $0x150,%rsp
    5c42:	mov    %rbp,%rsp
    5c45:	pop    %rbp
    5c46:	ret
    5c47:	mov    $0x5,%edx
    5c4c:	mov    %r12,%rcx
    5c4f:	mov    %rbx,%rsi
    5c52:	mov    %r13,%rdi
    5c55:	call   5c5a <botlish_fn_37+0x9ca>
			5c56: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5c5a:	mov    %rbx,%rdx
    5c5d:	jmp    557d <botlish_fn_37+0x2ed>
    5c62:	mov    $0x1,%edx
    5c67:	mov    %rbx,%rsi
    5c6a:	mov    %r13,%rdi
    5c6d:	call   5c72 <botlish_fn_37+0x9e2>
			5c6e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5c72:	jmp    575f <botlish_fn_37+0x4cf>
    5c77:	mov    %r15,%rdx
    5c7a:	mov    %rbx,%rsi
    5c7d:	mov    %r13,%rdi
    5c80:	call   5c85 <botlish_fn_37+0x9f5>
			5c81: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5c85:	jmp    57c0 <botlish_fn_37+0x530>
    5c8a:	mov    $0x5,%edx
    5c8f:	mov    0x100(%rsp),%rcx
    5c97:	mov    %rbx,%rsi
    5c9a:	mov    %r13,%rdi
    5c9d:	call   5ca2 <botlish_fn_37+0xa12>
			5c9e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5ca2:	jmp    59ef <botlish_fn_37+0x75f>
    5ca7:	add    %bh,(%rsi)
    5ca9:	add    %al,(%rax)
    5cab:	add    %al,(%rax)
    5cad:	add    %al,(%rax)
    5caf:	add    %al,(%rbx)
    5cb1:	add    %al,(%rax)
    5cb3:	add    %al,(%rcx)
    5cb5:	add    %al,(%rax)
    5cb7:	.byte 0x80

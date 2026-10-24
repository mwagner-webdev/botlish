<botlish_fn_2>:
  68:	push   %rbp
  69:	mov    %rsp,%rbp
  6c:	sub    $0x90,%rsp
  73:	mov    %rbx,0x60(%rsp)
  78:	mov    %r12,0x68(%rsp)
  7d:	mov    %r13,0x70(%rsp)
  82:	mov    %r14,0x78(%rsp)
  87:	mov    %r15,0x80(%rsp)
  8f:	mov    %rdi,0x38(%rsp)
  94:	mov    %rsi,0x40(%rsp)
  99:	movq   $0x0,(%rsp)
  a1:	movq   $0x0,0x8(%rsp)
  aa:	movq   $0x0,0x10(%rsp)
  b3:	movq   $0xa,0x30(%rsp)
  bc:	movq   $0xa,0x20(%rsp)
  c5:	movq   $0xa,0x28(%rsp)
  ce:	movq   $0x55,0x18(%rsp)
  d7:	mov    $0x3,%esi
  dc:	movq   $0x3,0x20(%rsp)
  e5:	mov    $0x55,%edx
  ea:	mov    0x38(%rsp),%rdi
  ef:	call   f4 <botlish_fn_2+0x8c>
			f0: R_X86_64_PLT32	rt_mutarray_create-0x4
  f4:	mov    %rax,%rcx
  f7:	mov    %rax,0x58(%rsp)
  fc:	test   %rcx,%rax
  ff:	jne    144 <botlish_fn_2+0xdc>
 105:	mov    0x38(%rsp),%rdi
 10a:	call   10f <botlish_fn_2+0xa7>
			10b: R_X86_64_PLT32	rt_co_failed-0x4
 10f:	mov    %rax,0x28(%rsp)
 114:	mov    %rax,%rsi
 117:	mov    0x38(%rsp),%rdi
 11c:	call   121 <botlish_fn_2+0xb9>
			11d: R_X86_64_PLT32	rt_co_resume0-0x4
 121:	test   %rax,%rax
 124:	je     64d <botlish_fn_2+0x5e5>
 12a:	mov    0x38(%rsp),%rdi
 12f:	mov    0x10(%rdi),%rax
 133:	mov    (%rax),%rsi
 136:	mov    0x10(%rax),%rdx
 13a:	call   13f <botlish_fn_2+0xd7>
			13b: R_X86_64_PLT32	rt_raise-0x4
 13f:	jmp    64d <botlish_fn_2+0x5e5>
 144:	mov    0x58(%rsp),%rax
 149:	mov    %rax,0x30(%rsp)
 14e:	mov    0x40(%rsp),%rax
 153:	mov    %rax,%rbx
 156:	shl    $1,%rbx
 159:	or     $0x1,%rbx
 15d:	sar    $1,%rbx
 160:	test   %rbx,%rbx
 163:	jg     181 <botlish_fn_2+0x119>
 169:	mov    $0xffffffffffffffff,%r12
 170:	movq   $0xffffffffffffffff,0x20(%rsp)
 179:	mov    %r12,%rcx
 17c:	jmp    2e3 <botlish_fn_2+0x27b>
 181:	mov    0x58(%rsp),%rax
 186:	mov    0x10(%rax),%rax
 18a:	mov    (%rax),%rsi
 18d:	mov    %rsi,0x18(%rsp)
 192:	mov    $0x838c9cdb,%eax
 197:	mov    %rax,0x20(%rsp)
 19c:	test   $0x1,%rsi
 1a3:	je     1c5 <botlish_fn_2+0x15d>
 1a9:	mov    %rsi,%rax
 1ac:	sar    $1,%rax
 1af:	imulq  0x782(%rip)        # 938 <botlish_fn_2+0x8d0>
 1b6:	seto   %cl
 1b9:	or     $0x1,%rax
 1bd:	test   %cl,%cl
 1bf:	je     1d4 <botlish_fn_2+0x16c>
 1c5:	mov    $0x838c9cdb,%edx
 1ca:	mov    0x38(%rsp),%rdi
 1cf:	call   1d4 <botlish_fn_2+0x16c>
			1d0: R_X86_64_PLT32	rt_int_mul-0x4
 1d4:	mov    %rax,0x18(%rsp)
 1d9:	movq   $0x6073,0x20(%rsp)
 1e2:	test   $0x1,%rax
 1e8:	jne    1f6 <botlish_fn_2+0x18e>
 1ee:	mov    %rax,%rcx
 1f1:	jmp    20e <botlish_fn_2+0x1a6>
 1f6:	mov    %rax,%rsi
 1f9:	add    $0x6072,%rsi
 200:	mov    %rax,%rcx
 203:	seto   %al
 206:	test   %al,%al
 208:	je     223 <botlish_fn_2+0x1bb>
 20e:	mov    $0x6073,%edx
 213:	mov    %rcx,%rsi
 216:	mov    0x38(%rsp),%rdi
 21b:	call   220 <botlish_fn_2+0x1b8>
			21c: R_X86_64_PLT32	rt_int_add-0x4
 220:	mov    %rax,%rsi
 223:	mov    %rsi,0x18(%rsp)
 228:	mov    $0xffffffff,%eax
 22d:	mov    %rax,0x20(%rsp)
 232:	test   $0x1,%rsi
 239:	jne    25b <botlish_fn_2+0x1f3>
 23f:	mov    $0xffffffff,%edx
 244:	mov    0x38(%rsp),%rdi
 249:	call   24e <botlish_fn_2+0x1e6>
			24a: R_X86_64_PLT32	rt_int_and-0x4
 24e:	mov    %rax,%r12
 251:	mov    0x58(%rsp),%rax
 256:	jmp    26a <botlish_fn_2+0x202>
 25b:	and    0x6de(%rip),%rsi        # 940 <botlish_fn_2+0x8d8>
 262:	mov    0x58(%rsp),%rax
 267:	mov    %rsi,%r12
 26a:	mov    0x58(%rsp),%rax
 26f:	mov    0x18(%rax),%rax
 273:	test   %rax,%rax
 276:	je     8ba <botlish_fn_2+0x852>
 27c:	mov    0x58(%rsp),%rax
 281:	mov    %r12,0x48(%rsp)
 286:	mov    0x10(%rax),%rax
 28a:	mov    0x48(%rsp),%rcx
 28f:	mov    %rcx,(%rax)
 292:	mov    $0x1,%r12d
 298:	sar    $1,%rcx
 29b:	mov    %rcx,%rax
 29e:	imulq  0x6a3(%rip)        # 948 <botlish_fn_2+0x8e0>
 2a5:	sar    $0x7,%rdx
 2a9:	mov    %rdx,%rax
 2ac:	shr    $0x3f,%rax
 2b0:	add    %rax,%rdx
 2b3:	mov    $0x3e8,%eax
 2b8:	imul   $0x3e8,%rdx,%rdx
 2bf:	sub    %rdx,%rcx
 2c2:	mov    %rax,%rdx
 2c5:	neg    %rdx
 2c8:	cmovs  %rax,%rdx
 2cc:	lea    (%rcx,%rdx,1),%rax
 2d0:	test   %rcx,%rcx
 2d3:	cmovl  %rax,%rcx
 2d7:	shl    $1,%rcx
 2da:	or     $0x1,%rcx
 2de:	mov    %rcx,0x20(%rsp)
 2e3:	mov    %rcx,(%rsp)
 2e7:	mov    %rcx,0x48(%rsp)
 2ec:	mov    $0x3,%esi
 2f1:	movq   $0x3,0x8(%rsp)
 2fa:	mov    0x48(%rsp),%rdx
 2ff:	mov    0x38(%rsp),%rdi
 304:	call   309 <botlish_fn_2+0x2a1>
			305: R_X86_64_PLT32	rt_mutarray_create-0x4
 309:	test   %rax,%rax
 30c:	je     64d <botlish_fn_2+0x5e5>
 312:	mov    %rax,(%rsp)
 316:	mov    %rax,%rcx
 319:	mov    $0x1,%r14d
 31f:	xor    %r13,%r13
 322:	mov    0x40(%rsp),%rax
 327:	cmp    %rax,%r14
 32a:	jl     5c6 <botlish_fn_2+0x55e>
 330:	mov    %rcx,%r15
 333:	mov    0x10(%r15),%r11
 337:	mov    (%r11),%rsi
 33a:	mov    %rsi,(%rsp)
 33e:	mov    %rsi,%r14
 341:	cmp    $0x1,%r12
 345:	je     391 <botlish_fn_2+0x329>
 34b:	cmp    $0xffffffffffffffff,%r12
 34f:	jne    35f <botlish_fn_2+0x2f7>
 355:	mov    0x48(%rsp),%rdx
 35a:	jmp    544 <botlish_fn_2+0x4dc>
 35f:	mov    $0xa,%esi
 364:	mov    0x38(%rsp),%rdi
 369:	call   36e <botlish_fn_2+0x306>
			36a: R_X86_64_PLT32	rt_co_resume0-0x4
 36e:	test   %rax,%rax
 371:	je     64d <botlish_fn_2+0x5e5>
 377:	mov    0x38(%rsp),%rdi
 37c:	mov    0x10(%rdi),%rax
 380:	mov    (%rax),%rsi
 383:	mov    0x10(%rax),%rdx
 387:	call   38c <botlish_fn_2+0x324>
			388: R_X86_64_PLT32	rt_raise-0x4
 38c:	jmp    64d <botlish_fn_2+0x5e5>
 391:	lea    0x1(%r13),%rax
 395:	cmp    %rbx,%rax
 398:	jl     3b8 <botlish_fn_2+0x350>
 39e:	mov    $0xffffffffffffffff,%rdx
 3a5:	mov    %rdx,0x48(%rsp)
 3aa:	movq   $0xffffffffffffffff,0x20(%rsp)
 3b3:	jmp    544 <botlish_fn_2+0x4dc>
 3b8:	mov    0x58(%rsp),%rbx
 3bd:	mov    0x10(%rbx),%rax
 3c1:	mov    (%rax),%rsi
 3c4:	mov    %rsi,0x18(%rsp)
 3c9:	mov    $0x838c9cdb,%edx
 3ce:	mov    %rdx,0x20(%rsp)
 3d3:	mov    %rdx,%rdi
 3d6:	test   $0x1,%rsi
 3dd:	jne    3eb <botlish_fn_2+0x383>
 3e3:	mov    %rdi,%rdx
 3e6:	jmp    417 <botlish_fn_2+0x3af>
 3eb:	mov    %rsi,%rax
 3ee:	sar    $1,%rax
 3f1:	imulq  0x540(%rip)        # 938 <botlish_fn_2+0x8d0>
 3f8:	seto   %cl
 3fb:	or     $0x1,%rax
 3ff:	test   %cl,%cl
 401:	je     40f <botlish_fn_2+0x3a7>
 407:	mov    %rdi,%rdx
 40a:	jmp    417 <botlish_fn_2+0x3af>
 40f:	mov    %rax,%r10
 412:	jmp    424 <botlish_fn_2+0x3bc>
 417:	mov    0x38(%rsp),%rdi
 41c:	call   421 <botlish_fn_2+0x3b9>
			41d: R_X86_64_PLT32	rt_int_mul-0x4
 421:	mov    %rax,%r10
 424:	mov    %r10,0x18(%rsp)
 429:	mov    $0x6073,%edx
 42e:	movq   $0x6073,0x20(%rsp)
 437:	test   $0x1,%r10
 43e:	jne    44c <botlish_fn_2+0x3e4>
 444:	mov    %r10,%rsi
 447:	jmp    467 <botlish_fn_2+0x3ff>
 44c:	mov    %r10,%rsi
 44f:	add    $0x6072,%rsi
 456:	mov    %r10,%rcx
 459:	seto   %al
 45c:	test   %al,%al
 45e:	je     474 <botlish_fn_2+0x40c>
 464:	mov    %rcx,%rsi
 467:	mov    0x38(%rsp),%rdi
 46c:	call   471 <botlish_fn_2+0x409>
			46d: R_X86_64_PLT32	rt_int_add-0x4
 471:	mov    %rax,%rsi
 474:	mov    %rsi,0x18(%rsp)
 479:	mov    $0xffffffff,%edx
 47e:	mov    %rdx,0x20(%rsp)
 483:	test   $0x1,%rsi
 48a:	jne    4a4 <botlish_fn_2+0x43c>
 490:	mov    0x38(%rsp),%rdi
 495:	call   49a <botlish_fn_2+0x432>
			496: R_X86_64_PLT32	rt_int_and-0x4
 49a:	mov    %rax,0x48(%rsp)
 49f:	jmp    4b0 <botlish_fn_2+0x448>
 4a4:	and    0x495(%rip),%rsi        # 940 <botlish_fn_2+0x8d8>
 4ab:	mov    %rsi,0x48(%rsp)
 4b0:	mov    0x18(%rbx),%rax
 4b4:	mov    %rbx,0x58(%rsp)
 4b9:	test   %rax,%rax
 4bc:	je     8e0 <botlish_fn_2+0x878>
 4c2:	mov    0x58(%rsp),%rsi
 4c7:	mov    0x10(%rsi),%rax
 4cb:	mov    0x48(%rsp),%rdx
 4d0:	mov    %rdx,(%rax)
 4d3:	sar    $1,%rdx
 4d6:	mov    %rdx,0x48(%rsp)
 4db:	mov    0x48(%rsp),%rax
 4e0:	imulq  0x461(%rip)        # 948 <botlish_fn_2+0x8e0>
 4e7:	sar    $0x7,%rdx
 4eb:	mov    %rdx,%rax
 4ee:	shr    $0x3f,%rax
 4f2:	lea    (%rdx,%rax,1),%rcx
 4f6:	mov    $0x3e8,%eax
 4fb:	imul   $0x3e8,%rcx,%rcx
 502:	mov    0x48(%rsp),%rdx
 507:	sub    %rcx,%rdx
 50a:	mov    %rdx,0x48(%rsp)
 50f:	mov    %rax,%rcx
 512:	neg    %rcx
 515:	cmovs  %rax,%rcx
 519:	lea    (%rdx,%rcx,1),%rax
 51d:	mov    0x48(%rsp),%rcx
 522:	test   %rcx,%rdx
 525:	cmovl  %rax,%rdx
 529:	mov    %rdx,0x48(%rsp)
 52e:	shl    $1,%rdx
 531:	mov    %rdx,0x48(%rsp)
 536:	or     $0x1,%rdx
 53a:	mov    %rdx,0x48(%rsp)
 53f:	mov    %rdx,0x20(%rsp)
 544:	mov    %rdx,0x8(%rsp)
 549:	mov    0x48(%rsp),%rdx
 54e:	mov    %r14,%rsi
 551:	mov    %rsi,%rcx
 554:	and    %rdx,%rcx
 557:	test   $0x1,%rcx
 55e:	jne    573 <botlish_fn_2+0x50b>
 564:	mov    0x48(%rsp),%rdx
 569:	mov    0x38(%rsp),%rdi
 56e:	jmp    599 <botlish_fn_2+0x531>
 573:	mov    0x48(%rsp),%rdx
 578:	lea    -0x1(%rdx),%rdi
 57c:	mov    %rsi,%rax
 57f:	add    %rdi,%rax
 582:	seto   %dil
 586:	test   %dil,%dil
 589:	je     59e <botlish_fn_2+0x536>
 58f:	mov    0x48(%rsp),%rdx
 594:	mov    0x38(%rsp),%rdi
 599:	call   59e <botlish_fn_2+0x536>
			59a: R_X86_64_PLT32	rt_int_add-0x4
 59e:	mov    0x60(%rsp),%rbx
 5a3:	mov    0x68(%rsp),%r12
 5a8:	mov    0x70(%rsp),%r13
 5ad:	mov    0x78(%rsp),%r14
 5b2:	mov    0x80(%rsp),%r15
 5ba:	add    $0x90,%rsp
 5c1:	mov    %rbp,%rsp
 5c4:	pop    %rbp
 5c5:	ret
 5c6:	mov    %rcx,%r15
 5c9:	movq   $0x1,0x8(%rsp)
 5d2:	mov    0x10(%r15),%r11
 5d6:	mov    (%r11),%rsi
 5d9:	mov    %rsi,0x10(%rsp)
 5de:	mov    %rsi,0x50(%rsp)
 5e3:	cmp    $0x1,%r12
 5e7:	je     678 <botlish_fn_2+0x610>
 5ed:	cmp    $0xffffffffffffffff,%r12
 5f1:	jne    601 <botlish_fn_2+0x599>
 5f7:	mov    0x48(%rsp),%rdx
 5fc:	jmp    842 <botlish_fn_2+0x7da>
 601:	mov    $0xa,%esi
 606:	mov    0x38(%rsp),%rdi
 60b:	call   610 <botlish_fn_2+0x5a8>
			60c: R_X86_64_PLT32	rt_co_resume0-0x4
 610:	test   %rax,%rax
 613:	jne    623 <botlish_fn_2+0x5bb>
 619:	mov    0x38(%rsp),%rdi
 61e:	jmp    63d <botlish_fn_2+0x5d5>
 623:	mov    0x38(%rsp),%rdi
 628:	mov    0x10(%rdi),%rax
 62c:	mov    (%rax),%rsi
 62f:	mov    0x10(%rax),%rdx
 633:	call   638 <botlish_fn_2+0x5d0>
			634: R_X86_64_PLT32	rt_raise-0x4
 638:	mov    0x38(%rsp),%rdi
 63d:	mov    0x38(%rsp),%rdi
 642:	call   647 <botlish_fn_2+0x5df>
			643: R_X86_64_PLT32	rt_declared_error-0x4
 647:	cmp    $0x40000001,%rax
 64d:	xor    %rax,%rax
 650:	mov    0x60(%rsp),%rbx
 655:	mov    0x68(%rsp),%r12
 65a:	mov    0x70(%rsp),%r13
 65f:	mov    0x78(%rsp),%r14
 664:	mov    0x80(%rsp),%r15
 66c:	add    $0x90,%rsp
 673:	mov    %rbp,%rsp
 676:	pop    %rbp
 677:	ret
 678:	add    $0x1,%r13
 67f:	cmp    %rbx,%r13
 682:	jl     6a7 <botlish_fn_2+0x63f>
 688:	mov    $0xffffffffffffffff,%rdx
 68f:	mov    %rdx,0x48(%rsp)
 694:	movq   $0xffffffffffffffff,0x20(%rsp)
 69d:	mov    0x48(%rsp),%r12
 6a2:	jmp    842 <botlish_fn_2+0x7da>
 6a7:	mov    0x58(%rsp),%rsi
 6ac:	mov    0x10(%rsi),%rax
 6b0:	mov    (%rax),%rsi
 6b3:	mov    %rsi,0x18(%rsp)
 6b8:	mov    $0x838c9cdb,%edx
 6bd:	mov    %rdx,0x20(%rsp)
 6c2:	mov    %rdx,%rdi
 6c5:	test   $0x1,%rsi
 6cc:	jne    6da <botlish_fn_2+0x672>
 6d2:	mov    %rdi,%rdx
 6d5:	jmp    6f9 <botlish_fn_2+0x691>
 6da:	mov    %rsi,%rax
 6dd:	sar    $1,%rax
 6e0:	imulq  0x251(%rip)        # 938 <botlish_fn_2+0x8d0>
 6e7:	seto   %cl
 6ea:	or     $0x1,%rax
 6ee:	test   %cl,%cl
 6f0:	je     703 <botlish_fn_2+0x69b>
 6f6:	mov    %rdi,%rdx
 6f9:	mov    0x38(%rsp),%rdi
 6fe:	call   703 <botlish_fn_2+0x69b>
			6ff: R_X86_64_PLT32	rt_int_mul-0x4
 703:	mov    %rax,0x18(%rsp)
 708:	mov    $0x6073,%edx
 70d:	movq   $0x6073,0x20(%rsp)
 716:	test   $0x1,%rax
 71c:	jne    72a <botlish_fn_2+0x6c2>
 722:	mov    %rax,%rsi
 725:	jmp    745 <botlish_fn_2+0x6dd>
 72a:	mov    %rax,%rsi
 72d:	add    $0x6072,%rsi
 734:	mov    %rax,%rcx
 737:	seto   %al
 73a:	test   %al,%al
 73c:	je     752 <botlish_fn_2+0x6ea>
 742:	mov    %rcx,%rsi
 745:	mov    0x38(%rsp),%rdi
 74a:	call   74f <botlish_fn_2+0x6e7>
			74b: R_X86_64_PLT32	rt_int_add-0x4
 74f:	mov    %rax,%rsi
 752:	mov    %rsi,0x18(%rsp)
 757:	mov    $0xffffffff,%edx
 75c:	mov    %rdx,0x20(%rsp)
 761:	test   $0x1,%rsi
 768:	jne    787 <botlish_fn_2+0x71f>
 76e:	mov    0x38(%rsp),%rdi
 773:	call   778 <botlish_fn_2+0x710>
			774: R_X86_64_PLT32	rt_int_and-0x4
 778:	mov    0x58(%rsp),%rsi
 77d:	mov    %rax,0x48(%rsp)
 782:	jmp    798 <botlish_fn_2+0x730>
 787:	and    0x1b2(%rip),%rsi        # 940 <botlish_fn_2+0x8d8>
 78e:	mov    %rsi,0x48(%rsp)
 793:	mov    0x58(%rsp),%rsi
 798:	mov    0x58(%rsp),%rsi
 79d:	mov    0x18(%rsi),%rax
 7a1:	test   %rax,%rax
 7a4:	je     903 <botlish_fn_2+0x89b>
 7aa:	mov    0x58(%rsp),%rsi
 7af:	mov    0x10(%rsi),%rcx
 7b3:	mov    0x48(%rsp),%rdx
 7b8:	mov    %rdx,(%rcx)
 7bb:	mov    $0x1,%r12d
 7c1:	mov    0x48(%rsp),%rdx
 7c6:	sar    $1,%rdx
 7c9:	mov    %rdx,0x48(%rsp)
 7ce:	mov    0x48(%rsp),%rax
 7d3:	imulq  0x16e(%rip)        # 948 <botlish_fn_2+0x8e0>
 7da:	sar    $0x7,%rdx
 7de:	mov    %rdx,%rsi
 7e1:	shr    $0x3f,%rsi
 7e5:	add    %rdx,%rsi
 7e8:	mov    $0x3e8,%edx
 7ed:	imul   $0x3e8,%rsi,%rsi
 7f4:	mov    0x48(%rsp),%rdi
 7f9:	sub    %rsi,%rdi
 7fc:	mov    %rdi,0x48(%rsp)
 801:	mov    %rdx,%rsi
 804:	neg    %rsi
 807:	cmovs  %rdx,%rsi
 80b:	mov    0x48(%rsp),%rdx
 810:	add    %rsi,%rdx
 813:	mov    0x48(%rsp),%rax
 818:	mov    0x48(%rsp),%r11
 81d:	test   %r11,%rax
 820:	cmovl  %rdx,%rax
 824:	mov    %rax,%rdx
 827:	mov    %rax,0x48(%rsp)
 82c:	shl    $1,%rdx
 82f:	mov    %rdx,0x48(%rsp)
 834:	or     $0x1,%rdx
 838:	mov    %rdx,0x48(%rsp)
 83d:	mov    %rdx,0x20(%rsp)
 842:	mov    %rdx,0x18(%rsp)
 847:	mov    0x48(%rsp),%rdx
 84c:	mov    0x50(%rsp),%rsi
 851:	mov    %rsi,%rdi
 854:	and    %rdx,%rdi
 857:	test   $0x1,%rdi
 85e:	je     880 <botlish_fn_2+0x818>
 864:	mov    0x48(%rsp),%rdx
 869:	lea    -0x1(%rdx),%r9
 86d:	mov    %rsi,%rcx
 870:	add    %r9,%rcx
 873:	seto   %r10b
 877:	test   %r10b,%r10b
 87a:	je     892 <botlish_fn_2+0x82a>
 880:	mov    0x48(%rsp),%rdx
 885:	mov    0x38(%rsp),%rdi
 88a:	call   88f <botlish_fn_2+0x827>
			88b: R_X86_64_PLT32	rt_int_add-0x4
 88f:	mov    %rax,%rcx
 892:	mov    0x18(%r15),%rax
 896:	test   %rax,%rax
 899:	je     921 <botlish_fn_2+0x8b9>
 89f:	mov    0x10(%r15),%rax
 8a3:	mov    %rcx,(%rax)
 8a6:	add    $0x1,%r14
 8ad:	mov    0x40(%rsp),%rax
 8b2:	mov    %r15,%rcx
 8b5:	jmp    327 <botlish_fn_2+0x2bf>
 8ba:	mov    $0x1,%edx
 8bf:	mov    %r12,%rcx
 8c2:	mov    0x58(%rsp),%rsi
 8c7:	mov    0x38(%rsp),%rdi
 8cc:	call   8d1 <botlish_fn_2+0x869>
			8cd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 8d1:	mov    %r12,0x48(%rsp)
 8d6:	mov    0x48(%rsp),%rcx
 8db:	jmp    292 <botlish_fn_2+0x22a>
 8e0:	mov    $0x1,%edx
 8e5:	mov    0x58(%rsp),%rsi
 8ea:	mov    0x48(%rsp),%rcx
 8ef:	mov    0x38(%rsp),%rdi
 8f4:	call   8f9 <botlish_fn_2+0x891>
			8f5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 8f9:	mov    0x48(%rsp),%rdx
 8fe:	jmp    4d3 <botlish_fn_2+0x46b>
 903:	mov    $0x1,%edx
 908:	mov    0x48(%rsp),%rcx
 90d:	mov    0x58(%rsp),%rsi
 912:	mov    0x38(%rsp),%rdi
 917:	call   91c <botlish_fn_2+0x8b4>
			918: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 91c:	jmp    7bb <botlish_fn_2+0x753>
 921:	mov    $0x1,%edx
 926:	mov    %r15,%rsi
 929:	mov    0x38(%rsp),%rdi
 92e:	call   933 <botlish_fn_2+0x8cb>
			92f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 933:	jmp    8a6 <botlish_fn_2+0x83e>
 938:	ficompl 0x83(%rsp,%rcx,4)
 93f:	add    %bh,%bh
 941:	(bad)
 942:	(bad)
 943:	incl   (%rax)
 945:	add    %al,(%rax)
 947:	add    %cl,%bh
 949:	notl   -0x1d(%rbx)
 94c:	movsl  %ds:(%rsi),%es:(%rdi)
 94d:	fwait
 94e:	.byte 0xc4
 94f:	.byte 0x20

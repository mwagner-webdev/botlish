<botlish_fn_6>:
     318:	push   %rbp
     319:	mov    %rsp,%rbp
     31c:	sub    $0xf0,%rsp
     323:	mov    %rbx,0xc0(%rsp)
     32b:	mov    %r12,0xc8(%rsp)
     333:	mov    %r13,0xd0(%rsp)
     33b:	mov    %r14,0xd8(%rsp)
     343:	mov    %r15,0xe0(%rsp)
     34b:	mov    %rdi,0x98(%rsp)
     353:	mov    %rsi,0xa0(%rsp)
     35b:	xor    %rsi,%rsi
     35e:	mov    0x98(%rsp),%rdi
     366:	call   36b <botlish_fn_6+0x53>
			367: R_X86_64_PLT32	botlish_fn_5-0x4
     36b:	mov    %rax,%r13
     36e:	movq   $0xa,(%rsp)
     376:	mov    %r13,%rax
     379:	test   $0x1,%rax
     37f:	jne    3af <botlish_fn_6+0x97>
     385:	mov    $0x101,%edx
     38a:	mov    %r13,%rsi
     38d:	mov    0x98(%rsp),%rdi
     395:	call   39a <botlish_fn_6+0x82>
			396: R_X86_64_PLT32	rt_int_cmp-0x4
     39a:	mov    $0x2,%ecx
     39f:	test   %rax,%rax
     3a2:	cmovl  0x1ade(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     3aa:	jmp    3c5 <botlish_fn_6+0xad>
     3af:	mov    $0x2,%ecx
     3b4:	mov    %r13,%rax
     3b7:	cmp    $0x101,%rax
     3bd:	cmovl  0x1ac3(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     3c5:	mov    $0x6,%eax
     3ca:	mov    %rax,0xb0(%rsp)
     3d2:	cmp    $0x6,%rcx
     3d6:	je     4af <botlish_fn_6+0x197>
     3dc:	mov    %r13,%rax
     3df:	test   $0x1,%rax
     3e5:	jne    415 <botlish_fn_6+0xfd>
     3eb:	mov    $0x185,%edx
     3f0:	mov    %r13,%rsi
     3f3:	mov    0x98(%rsp),%rdi
     3fb:	call   400 <botlish_fn_6+0xe8>
			3fc: R_X86_64_PLT32	rt_int_cmp-0x4
     400:	mov    $0x2,%ecx
     405:	test   %rax,%rax
     408:	cmovl  0x1a78(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     410:	jmp    42b <botlish_fn_6+0x113>
     415:	mov    $0x2,%ecx
     41a:	mov    %r13,%rax
     41d:	cmp    $0x185,%rax
     423:	cmovl  0x1a5d(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     42b:	cmp    $0x6,%rcx
     42f:	je     4a4 <botlish_fn_6+0x18c>
     435:	mov    %r13,%rax
     438:	test   $0x1,%rax
     43e:	jne    46e <botlish_fn_6+0x156>
     444:	mov    $0x1eb,%edx
     449:	mov    %r13,%rsi
     44c:	mov    0x98(%rsp),%rdi
     454:	call   459 <botlish_fn_6+0x141>
			455: R_X86_64_PLT32	rt_int_cmp-0x4
     459:	mov    $0x2,%esi
     45e:	test   %rax,%rax
     461:	cmovl  0x1a1f(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
     469:	jmp    484 <botlish_fn_6+0x16c>
     46e:	mov    $0x2,%esi
     473:	mov    %r13,%rax
     476:	cmp    $0x1eb,%rax
     47c:	cmovl  0x1a04(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
     484:	cmp    $0x6,%rsi
     488:	je     499 <botlish_fn_6+0x181>
     48e:	mov    $0x9,%r12d
     494:	jmp    533 <botlish_fn_6+0x21b>
     499:	mov    $0x7,%r12d
     49f:	jmp    533 <botlish_fn_6+0x21b>
     4a4:	mov    $0x9,%r12d
     4aa:	jmp    533 <botlish_fn_6+0x21b>
     4af:	mov    %r13,%rax
     4b2:	test   $0x1,%rax
     4b8:	jne    4ea <botlish_fn_6+0x1d2>
     4be:	mov    $0xffffffffffffffff,%rdx
     4c5:	mov    %r13,%rsi
     4c8:	mov    0x98(%rsp),%rdi
     4d0:	call   4d5 <botlish_fn_6+0x1bd>
			4d1: R_X86_64_PLT32	rt_int_cmp-0x4
     4d5:	mov    $0x2,%ecx
     4da:	test   %rax,%rax
     4dd:	cmovl  0x19a3(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     4e5:	jmp    4fe <botlish_fn_6+0x1e6>
     4ea:	mov    $0x2,%ecx
     4ef:	mov    %r13,%rax
     4f2:	cmp    $0xffffffffffffffff,%rax
     4f6:	cmovl  0x198a(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     4fe:	cmp    $0x6,%rcx
     502:	je     52d <botlish_fn_6+0x215>
     508:	mov    %r13,%rax
     50b:	sar    $1,%rax
     50e:	test   %rax,%rax
     511:	jl     522 <botlish_fn_6+0x20a>
     517:	mov    $0x1,%r12d
     51d:	jmp    533 <botlish_fn_6+0x21b>
     522:	mov    $0x5,%r12d
     528:	jmp    533 <botlish_fn_6+0x21b>
     52d:	mov    $0x9,%r12d
     533:	mov    %r12,%rcx
     536:	sar    $1,%rcx
     539:	test   %rcx,%rcx
     53c:	jle    add <botlish_fn_6+0x7c5>
     542:	mov    $0x2,%r8d
     548:	mov    %r8,%r12
     54b:	cmp    $0x2,%rcx
     54f:	je     a75 <botlish_fn_6+0x75d>
     555:	cmp    $0x3,%rcx
     559:	je     629 <botlish_fn_6+0x311>
     55f:	mov    %r13,%rax
     562:	test   $0x1,%rax
     568:	jne    59b <botlish_fn_6+0x283>
     56e:	mov    $0xffffffffffffffff,%rdx
     575:	mov    %r13,%rsi
     578:	mov    0x98(%rsp),%rdi
     580:	call   585 <botlish_fn_6+0x26d>
			581: R_X86_64_PLT32	rt_int_cmp-0x4
     585:	test   %rax,%rax
     588:	mov    %r12,%r8
     58b:	mov    %r8,%rcx
     58e:	cmove  0x18f2(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     596:	jmp    5b0 <botlish_fn_6+0x298>
     59b:	mov    %r13,%rax
     59e:	cmp    $0xffffffffffffffff,%rax
     5a2:	mov    %r12,%r8
     5a5:	mov    %r8,%rcx
     5a8:	cmove  0x18d8(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     5b0:	cmp    $0x6,%rcx
     5b4:	je     5f5 <botlish_fn_6+0x2dd>
     5ba:	mov    0x98(%rsp),%rdi
     5c2:	mov    0x10(%rdi),%rax
     5c6:	mov    0x78(%rax),%rcx
     5ca:	mov    0x70(%rax),%rdx
     5ce:	lea    0x28(%rsp),%r9
     5d3:	mov    %rcx,0x28(%rsp)
     5d8:	mov    %r13,%rax
     5db:	mov    %rax,0x30(%rsp)
     5e0:	mov    $0x1,%esi
     5e5:	mov    %r12,%r8
     5e8:	mov    %r8,%rcx
     5eb:	call   5f0 <botlish_fn_6+0x2d8>
			5ec: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     5f0:	jmp    9db <botlish_fn_6+0x6c3>
     5f5:	mov    0x98(%rsp),%rdi
     5fd:	mov    0x10(%rdi),%rcx
     601:	mov    0x78(%rcx),%rax
     605:	mov    0x68(%rcx),%rdx
     609:	lea    0x20(%rsp),%r9
     60e:	mov    %rax,0x20(%rsp)
     613:	mov    $0x1,%r8d
     619:	mov    %r12,%rsi
     61c:	mov    %r8,%rcx
     61f:	call   624 <botlish_fn_6+0x30c>
			620: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     624:	jmp    9db <botlish_fn_6+0x6c3>
     629:	mov    %r13,%rax
     62c:	test   $0x1,%rax
     632:	jne    663 <botlish_fn_6+0x34b>
     638:	mov    $0x1dd,%edx
     63d:	mov    %r13,%rsi
     640:	mov    0x98(%rsp),%rdi
     648:	call   64d <botlish_fn_6+0x335>
			649: R_X86_64_PLT32	rt_int_cmp-0x4
     64d:	test   %rax,%rax
     650:	mov    %r12,%rsi
     653:	mov    %rsi,%rcx
     656:	cmovl  0x182a(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     65e:	jmp    67a <botlish_fn_6+0x362>
     663:	mov    %r13,%rax
     666:	cmp    $0x1dd,%rax
     66c:	mov    %r12,%rsi
     66f:	mov    %rsi,%rcx
     672:	cmovl  0x180e(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     67a:	cmp    $0x6,%rcx
     67e:	je     7d3 <botlish_fn_6+0x4bb>
     684:	mov    %r13,%rax
     687:	test   $0x1,%rax
     68d:	jne    6be <botlish_fn_6+0x3a6>
     693:	mov    $0x1e3,%edx
     698:	mov    %r13,%rsi
     69b:	mov    0x98(%rsp),%rdi
     6a3:	call   6a8 <botlish_fn_6+0x390>
			6a4: R_X86_64_PLT32	rt_int_cmp-0x4
     6a8:	test   %rax,%rax
     6ab:	mov    %r12,%rsi
     6ae:	mov    %rsi,%rcx
     6b1:	cmovl  0x17cf(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     6b9:	jmp    6d5 <botlish_fn_6+0x3bd>
     6be:	mov    %r13,%rax
     6c1:	cmp    $0x1e3,%rax
     6c7:	mov    %r12,%rsi
     6ca:	mov    %rsi,%rcx
     6cd:	cmovl  0x17b3(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     6d5:	cmp    $0x6,%rcx
     6d9:	je     7ad <botlish_fn_6+0x495>
     6df:	mov    %r13,%rax
     6e2:	test   $0x1,%rax
     6e8:	jne    716 <botlish_fn_6+0x3fe>
     6ee:	mov    $0x1e9,%edx
     6f3:	mov    %r13,%rsi
     6f6:	mov    0x98(%rsp),%rdi
     6fe:	call   703 <botlish_fn_6+0x3eb>
			6ff: R_X86_64_PLT32	rt_int_cmp-0x4
     703:	test   %rax,%rax
     706:	mov    %r12,%rsi
     709:	cmovl  0x1777(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
     711:	jmp    72a <botlish_fn_6+0x412>
     716:	mov    %r13,%rax
     719:	cmp    $0x1e9,%rax
     71f:	mov    %r12,%rsi
     722:	cmovl  0x175e(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
     72a:	cmp    $0x6,%rsi
     72e:	je     7a3 <botlish_fn_6+0x48b>
     734:	mov    %r13,%rax
     737:	test   $0x1,%rax
     73d:	jne    76e <botlish_fn_6+0x456>
     743:	mov    $0x1eb,%edx
     748:	mov    %r13,%rsi
     74b:	mov    0x98(%rsp),%rdi
     753:	call   758 <botlish_fn_6+0x440>
			754: R_X86_64_PLT32	rt_int_cmp-0x4
     758:	test   %rax,%rax
     75b:	mov    %r12,%rsi
     75e:	mov    %rsi,%rcx
     761:	cmovl  0x171f(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     769:	jmp    785 <botlish_fn_6+0x46d>
     76e:	mov    %r13,%rax
     771:	cmp    $0x1eb,%rax
     777:	mov    %r12,%rsi
     77a:	mov    %rsi,%rcx
     77d:	cmovl  0x1703(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     785:	cmp    $0x6,%rcx
     789:	je     799 <botlish_fn_6+0x481>
     78f:	mov    $0x15,%ebx
     794:	jmp    8d9 <botlish_fn_6+0x5c1>
     799:	mov    $0xf,%ebx
     79e:	jmp    8d9 <botlish_fn_6+0x5c1>
     7a3:	mov    $0xd,%ebx
     7a8:	jmp    8d9 <botlish_fn_6+0x5c1>
     7ad:	mov    %r13,%rax
     7b0:	sar    $1,%rax
     7b3:	cmp    $0xf0,%rax
     7b9:	jl     7c9 <botlish_fn_6+0x4b1>
     7bf:	mov    $0xb,%ebx
     7c4:	jmp    8d9 <botlish_fn_6+0x5c1>
     7c9:	mov    $0x7,%ebx
     7ce:	jmp    8d9 <botlish_fn_6+0x5c1>
     7d3:	mov    %r13,%rax
     7d6:	test   $0x1,%rax
     7dc:	jne    80d <botlish_fn_6+0x4f5>
     7e2:	mov    $0x1c1,%edx
     7e7:	mov    %r13,%rsi
     7ea:	mov    0x98(%rsp),%rdi
     7f2:	call   7f7 <botlish_fn_6+0x4df>
			7f3: R_X86_64_PLT32	rt_int_cmp-0x4
     7f7:	test   %rax,%rax
     7fa:	mov    %r12,%rsi
     7fd:	mov    %rsi,%rcx
     800:	cmovl  0x1680(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     808:	jmp    824 <botlish_fn_6+0x50c>
     80d:	mov    %r13,%rax
     810:	cmp    $0x1c1,%rax
     816:	mov    %r12,%rsi
     819:	mov    %rsi,%rcx
     81c:	cmovl  0x1664(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     824:	cmp    $0x6,%rcx
     828:	je     86f <botlish_fn_6+0x557>
     82e:	mov    %r13,%rax
     831:	mov    %rax,%rcx
     834:	sar    $1,%rcx
     837:	cmp    $0xe1,%rcx
     83e:	jl     865 <botlish_fn_6+0x54d>
     844:	cmp    $0xed,%rcx
     84b:	jl     85b <botlish_fn_6+0x543>
     851:	mov    $0x9,%ebx
     856:	jmp    8d9 <botlish_fn_6+0x5c1>
     85b:	mov    $0x7,%ebx
     860:	jmp    8d9 <botlish_fn_6+0x5c1>
     865:	mov    $0x5,%ebx
     86a:	jmp    8d9 <botlish_fn_6+0x5c1>
     86f:	mov    %r13,%rax
     872:	test   $0x1,%rax
     878:	jne    8a9 <botlish_fn_6+0x591>
     87e:	mov    $0x185,%edx
     883:	mov    %r13,%rsi
     886:	mov    0x98(%rsp),%rdi
     88e:	call   893 <botlish_fn_6+0x57b>
			88f: R_X86_64_PLT32	rt_int_cmp-0x4
     893:	test   %rax,%rax
     896:	mov    %r12,%rsi
     899:	mov    %rsi,%rcx
     89c:	cmovl  0x15e4(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     8a4:	jmp    8c0 <botlish_fn_6+0x5a8>
     8a9:	mov    %r13,%rax
     8ac:	cmp    $0x185,%rax
     8b2:	mov    %r12,%rsi
     8b5:	mov    %rsi,%rcx
     8b8:	cmovl  0x15c8(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     8c0:	cmp    $0x6,%rcx
     8c4:	je     8d4 <botlish_fn_6+0x5bc>
     8ca:	mov    $0x3,%ebx
     8cf:	jmp    8d9 <botlish_fn_6+0x5c1>
     8d4:	mov    $0x15,%ebx
     8d9:	mov    %rbx,%rsi
     8dc:	sar    $1,%rsi
     8df:	cmp    $0x8,%rsi
     8e3:	jl     a5c <botlish_fn_6+0x744>
     8e9:	cmp    $0x8,%rsi
     8ed:	mov    %rsi,%rbx
     8f0:	je     a51 <botlish_fn_6+0x739>
     8f6:	mov    %r13,%rax
     8f9:	test   $0x1,%rax
     8ff:	jne    932 <botlish_fn_6+0x61a>
     905:	mov    $0xffffffffffffffff,%rdx
     90c:	mov    %r13,%rsi
     90f:	mov    0x98(%rsp),%rdi
     917:	call   91c <botlish_fn_6+0x604>
			918: R_X86_64_PLT32	rt_int_cmp-0x4
     91c:	test   %rax,%rax
     91f:	mov    %r12,%rsi
     922:	mov    %rsi,%rcx
     925:	cmove  0x155b(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     92d:	jmp    947 <botlish_fn_6+0x62f>
     932:	mov    %r13,%rax
     935:	cmp    $0xffffffffffffffff,%rax
     939:	mov    %r12,%rsi
     93c:	mov    %rsi,%rcx
     93f:	cmove  0x1541(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
     947:	cmp    $0x6,%rcx
     94b:	je     9a0 <botlish_fn_6+0x688>
     951:	mov    %rbx,%rsi
     954:	mov    0x98(%rsp),%rdi
     95c:	call   961 <botlish_fn_6+0x649>
			95d: R_X86_64_PLT32	botlish_fn_1-0x4
     961:	mov    0x98(%rsp),%rdi
     969:	mov    0x10(%rdi),%rdi
     96d:	mov    0x70(%rdi),%rdx
     971:	lea    0x10(%rsp),%r9
     976:	mov    %rax,0x10(%rsp)
     97b:	mov    %r13,%rax
     97e:	mov    %rax,0x18(%rsp)
     983:	mov    $0x1,%esi
     988:	mov    %r12,%r8
     98b:	mov    0x98(%rsp),%rdi
     993:	mov    %r8,%rcx
     996:	call   99b <botlish_fn_6+0x683>
			997: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     99b:	jmp    9db <botlish_fn_6+0x6c3>
     9a0:	mov    %rbx,%rsi
     9a3:	mov    0x98(%rsp),%rdi
     9ab:	call   9b0 <botlish_fn_6+0x698>
			9ac: R_X86_64_PLT32	botlish_fn_1-0x4
     9b0:	mov    0x98(%rsp),%rdi
     9b8:	mov    0x10(%rdi),%r10
     9bc:	mov    0x68(%r10),%rdx
     9c0:	lea    0x8(%rsp),%r9
     9c5:	mov    %rax,0x8(%rsp)
     9ca:	mov    $0x1,%r8d
     9d0:	mov    %r12,%rsi
     9d3:	mov    %r8,%rcx
     9d6:	call   9db <botlish_fn_6+0x6c3>
			9d7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     9db:	mov    0x98(%rsp),%rdi
     9e3:	call   9e8 <botlish_fn_6+0x6d0>
			9e4: R_X86_64_PLT32	rt_co_failed-0x4
     9e8:	mov    %rax,(%rsp)
     9ec:	mov    %rax,%rsi
     9ef:	mov    0x98(%rsp),%rdi
     9f7:	call   9fc <botlish_fn_6+0x6e4>
			9f8: R_X86_64_PLT32	rt_co_resume0-0x4
     9fc:	test   %rax,%rax
     9ff:	je     a1e <botlish_fn_6+0x706>
     a05:	mov    0x98(%rsp),%rdi
     a0d:	mov    0x10(%rdi),%rax
     a11:	mov    0x40(%rax),%rsi
     a15:	mov    0x60(%rax),%rdx
     a19:	call   a1e <botlish_fn_6+0x706>
			a1a: R_X86_64_PLT32	rt_raise-0x4
     a1e:	mov    0x98(%rsp),%rdi
     a26:	call   a2b <botlish_fn_6+0x713>
			a27: R_X86_64_PLT32	rt_declared_error-0x4
     a2b:	cmp    $0x2,%rax
     a2f:	je     1dfe <botlish_fn_6+0x1ae6>
     a35:	mov    0x98(%rsp),%rdi
     a3d:	call   a42 <botlish_fn_6+0x72a>
			a3e: R_X86_64_PLT32	rt_declared_error-0x4
     a42:	cmp    $0x1,%rax
     a46:	jne    1dfe <botlish_fn_6+0x1ae6>
     a4c:	jmp    1dfe <botlish_fn_6+0x1ae6>
     a51:	mov    $0x1,%r12d
     a57:	jmp    add <botlish_fn_6+0x7c5>
     a5c:	mov    $0x1,%r14d
     a62:	mov    $0xa,%r12d
     a68:	mov    0xb0(%rsp),%r15
     a70:	jmp    af0 <botlish_fn_6+0x7d8>
     a75:	mov    %r13,%rax
     a78:	test   $0x1,%rax
     a7e:	mov    %rax,%r13
     a81:	jne    ab4 <botlish_fn_6+0x79c>
     a87:	mov    $0xfffffffffffffffd,%rdx
     a8e:	mov    %r13,%rsi
     a91:	mov    0x98(%rsp),%rdi
     a99:	call   a9e <botlish_fn_6+0x786>
			a9a: R_X86_64_PLT32	rt_int_cmp-0x4
     a9e:	test   %rax,%rax
     aa1:	mov    %r12,%r8
     aa4:	mov    %r8,%r15
     aa7:	cmove  0x13d9(%rip),%r15        # 1e88 <botlish_fn_6+0x1b70>
     aaf:	jmp    ac9 <botlish_fn_6+0x7b1>
     ab4:	mov    %r13,%rsi
     ab7:	cmp    $0xfffffffffffffffd,%rsi
     abb:	mov    %r12,%r8
     abe:	mov    %r8,%r15
     ac1:	cmove  0x13bf(%rip),%r15        # 1e88 <botlish_fn_6+0x1b70>
     ac9:	mov    $0xffffffffffffffff,%r14
     ad0:	mov    $0xa,%ebx
     ad5:	mov    %rbx,%r12
     ad8:	jmp    af0 <botlish_fn_6+0x7d8>
     add:	mov    $0x2,%r14d
     ae3:	mov    $0xa,%ebx
     ae8:	mov    0xb0(%rsp),%r15
     af0:	mov    $0x1,%ecx
     af5:	mov    %rcx,0xa8(%rsp)
     afd:	mov    0xa0(%rsp),%rsi
     b05:	mov    0xa8(%rsp),%r13
     b0d:	cmp    %rsi,%r13
     b10:	mov    %rsi,0xa0(%rsp)
     b18:	jl     10a7 <botlish_fn_6+0xd8f>
     b1e:	cmp    $0x1,%r14
     b22:	je     c99 <botlish_fn_6+0x981>
     b28:	mov    $0x2,%r8d
     b2e:	cmp    $0x2,%r14
     b32:	je     b4c <botlish_fn_6+0x834>
     b38:	mov    $0xa,%esi
     b3d:	cmp    $0xffffffffffffffff,%r14
     b41:	je     102c <botlish_fn_6+0xd14>
     b47:	jmp    f99 <botlish_fn_6+0xc81>
     b4c:	mov    0xb0(%rsp),%rax
     b54:	cmp    $0x6,%rax
     b58:	je     ba0 <botlish_fn_6+0x888>
     b5e:	mov    0xb0(%rsp),%rax
     b66:	cmp    $0x6,%rax
     b6a:	je     b96 <botlish_fn_6+0x87e>
     b70:	mov    0xb0(%rsp),%rax
     b78:	cmp    $0x6,%rax
     b7c:	je     b8c <botlish_fn_6+0x874>
     b82:	mov    $0x9,%ecx
     b87:	jmp    bbc <botlish_fn_6+0x8a4>
     b8c:	mov    $0x7,%ecx
     b91:	jmp    bbc <botlish_fn_6+0x8a4>
     b96:	mov    $0x9,%ecx
     b9b:	jmp    bbc <botlish_fn_6+0x8a4>
     ba0:	mov    %r8,%rax
     ba3:	cmp    $0x6,%rax
     ba7:	je     bb7 <botlish_fn_6+0x89f>
     bad:	mov    $0x5,%ecx
     bb2:	jmp    bbc <botlish_fn_6+0x8a4>
     bb7:	mov    $0x9,%ecx
     bbc:	sar    $1,%rcx
     bbf:	test   %rcx,%rcx
     bc2:	jle    c8c <botlish_fn_6+0x974>
     bc8:	cmp    $0x2,%rcx
     bcc:	je     c7a <botlish_fn_6+0x962>
     bd2:	cmp    $0x3,%rcx
     bd6:	je     c6a <botlish_fn_6+0x952>
     bdc:	mov    0xb0(%rsp),%rcx
     be4:	cmp    $0x6,%rcx
     be8:	je     c30 <botlish_fn_6+0x918>
     bee:	mov    0x98(%rsp),%rdi
     bf6:	mov    0x10(%rdi),%rcx
     bfa:	mov    0x78(%rcx),%rax
     bfe:	mov    0x70(%rcx),%rdx
     c02:	lea    0x88(%rsp),%r9
     c0a:	mov    %rax,0x88(%rsp)
     c12:	movq   $0xffffffffffffffff,0x90(%rsp)
     c1e:	mov    $0x1,%esi
     c23:	mov    %r8,%rcx
     c26:	call   c2b <botlish_fn_6+0x913>
			c27: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     c2b:	jmp    f85 <botlish_fn_6+0xc6d>
     c30:	mov    %r8,%rsi
     c33:	mov    0x98(%rsp),%rdi
     c3b:	mov    0x10(%rdi),%rcx
     c3f:	mov    0x78(%rcx),%rax
     c43:	mov    0x68(%rcx),%rdx
     c47:	lea    0x80(%rsp),%r9
     c4f:	mov    %rax,0x80(%rsp)
     c57:	mov    $0x1,%r8d
     c5d:	mov    %r8,%rcx
     c60:	call   c65 <botlish_fn_6+0x94d>
			c61: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     c65:	jmp    f85 <botlish_fn_6+0xc6d>
     c6a:	mov    0xb0(%rsp),%rcx
     c72:	xor    %rbx,%rbx
     c75:	jmp    ca4 <botlish_fn_6+0x98c>
     c7a:	mov    %r8,%rsi
     c7d:	mov    %rsi,%r15
     c80:	mov    $0xffffffffffffffff,%r14
     c87:	jmp    102c <botlish_fn_6+0xd14>
     c8c:	mov    0xb0(%rsp),%rcx
     c94:	jmp    1003 <botlish_fn_6+0xceb>
     c99:	mov    0xb0(%rsp),%rcx
     ca1:	sar    $1,%rbx
     ca4:	cmp    $0x4,%rbx
     ca8:	jl     d9d <botlish_fn_6+0xa85>
     cae:	cmp    $0x6,%rbx
     cb2:	jl     d23 <botlish_fn_6+0xa0b>
     cb8:	mov    $0x7,%esi
     cbd:	cmp    $0x7,%rbx
     cc1:	jl     cf5 <botlish_fn_6+0x9dd>
     cc7:	mov    %rcx,%rax
     cca:	cmp    $0x6,%rax
     cce:	je     ceb <botlish_fn_6+0x9d3>
     cd4:	mov    %rcx,%rax
     cd7:	cmp    $0x6,%rax
     cdb:	je     ee2 <botlish_fn_6+0xbca>
     ce1:	mov    $0x23,%esi
     ce6:	jmp    ee2 <botlish_fn_6+0xbca>
     ceb:	mov    $0x23,%esi
     cf0:	jmp    ee2 <botlish_fn_6+0xbca>
     cf5:	mov    %rcx,%rax
     cf8:	cmp    $0x6,%rax
     cfc:	je     d19 <botlish_fn_6+0xa01>
     d02:	mov    %rcx,%rax
     d05:	cmp    $0x6,%rax
     d09:	je     ee2 <botlish_fn_6+0xbca>
     d0f:	mov    $0x21,%esi
     d14:	jmp    ee2 <botlish_fn_6+0xbca>
     d19:	mov    $0x21,%esi
     d1e:	jmp    ee2 <botlish_fn_6+0xbca>
     d23:	cmp    $0x5,%rbx
     d27:	jl     d65 <botlish_fn_6+0xa4d>
     d2d:	mov    %rcx,%rax
     d30:	cmp    $0x6,%rax
     d34:	je     d5b <botlish_fn_6+0xa43>
     d3a:	mov    %rcx,%rax
     d3d:	cmp    $0x6,%rax
     d41:	je     d51 <botlish_fn_6+0xa39>
     d47:	mov    $0x1f,%esi
     d4c:	jmp    ee2 <botlish_fn_6+0xbca>
     d51:	mov    $0x7,%esi
     d56:	jmp    ee2 <botlish_fn_6+0xbca>
     d5b:	mov    $0x1f,%esi
     d60:	jmp    ee2 <botlish_fn_6+0xbca>
     d65:	mov    %rcx,%rdx
     d68:	cmp    $0x6,%rdx
     d6c:	je     d93 <botlish_fn_6+0xa7b>
     d72:	mov    %rcx,%rdi
     d75:	cmp    $0x6,%rdi
     d79:	je     d89 <botlish_fn_6+0xa71>
     d7f:	mov    $0x1d,%esi
     d84:	jmp    ee2 <botlish_fn_6+0xbca>
     d89:	mov    $0x3,%esi
     d8e:	jmp    ee2 <botlish_fn_6+0xbca>
     d93:	mov    $0x1d,%esi
     d98:	jmp    ee2 <botlish_fn_6+0xbca>
     d9d:	cmp    $0x2,%rbx
     da1:	jl     e12 <botlish_fn_6+0xafa>
     da7:	mov    $0x3,%esi
     dac:	cmp    $0x3,%rbx
     db0:	jl     de4 <botlish_fn_6+0xacc>
     db6:	mov    %rcx,%rax
     db9:	cmp    $0x6,%rax
     dbd:	je     dda <botlish_fn_6+0xac2>
     dc3:	mov    %rcx,%rax
     dc6:	cmp    $0x6,%rax
     dca:	je     ee2 <botlish_fn_6+0xbca>
     dd0:	mov    $0x1b,%esi
     dd5:	jmp    ee2 <botlish_fn_6+0xbca>
     dda:	mov    $0x1b,%esi
     ddf:	jmp    ee2 <botlish_fn_6+0xbca>
     de4:	mov    %rcx,%rax
     de7:	cmp    $0x6,%rax
     deb:	je     e08 <botlish_fn_6+0xaf0>
     df1:	mov    %rcx,%rax
     df4:	cmp    $0x6,%rax
     df8:	je     ee2 <botlish_fn_6+0xbca>
     dfe:	mov    $0x19,%esi
     e03:	jmp    ee2 <botlish_fn_6+0xbca>
     e08:	mov    $0x19,%esi
     e0d:	jmp    ee2 <botlish_fn_6+0xbca>
     e12:	test   %rbx,%rbx
     e15:	jle    e53 <botlish_fn_6+0xb3b>
     e1b:	mov    %rcx,%rax
     e1e:	cmp    $0x6,%rax
     e22:	je     e49 <botlish_fn_6+0xb31>
     e28:	mov    %rcx,%rax
     e2b:	cmp    $0x6,%rax
     e2f:	je     e3f <botlish_fn_6+0xb27>
     e35:	mov    $0x17,%esi
     e3a:	jmp    ee2 <botlish_fn_6+0xbca>
     e3f:	mov    $0x11,%esi
     e44:	jmp    ee2 <botlish_fn_6+0xbca>
     e49:	mov    $0x17,%esi
     e4e:	jmp    ee2 <botlish_fn_6+0xbca>
     e53:	mov    %rcx,%rax
     e56:	cmp    $0x6,%rax
     e5a:	je     eaf <botlish_fn_6+0xb97>
     e60:	mov    %rcx,%rax
     e63:	cmp    $0x6,%rax
     e67:	je     ea5 <botlish_fn_6+0xb8d>
     e6d:	mov    %rcx,%rax
     e70:	cmp    $0x6,%rax
     e74:	je     e9b <botlish_fn_6+0xb83>
     e7a:	mov    %rcx,%rsi
     e7d:	cmp    $0x6,%rsi
     e81:	je     e91 <botlish_fn_6+0xb79>
     e87:	mov    $0x15,%esi
     e8c:	jmp    ee2 <botlish_fn_6+0xbca>
     e91:	mov    $0xf,%esi
     e96:	jmp    ee2 <botlish_fn_6+0xbca>
     e9b:	mov    $0xd,%esi
     ea0:	jmp    ee2 <botlish_fn_6+0xbca>
     ea5:	mov    $0x7,%esi
     eaa:	jmp    ee2 <botlish_fn_6+0xbca>
     eaf:	mov    %rcx,%rax
     eb2:	cmp    $0x6,%rax
     eb6:	je     ec6 <botlish_fn_6+0xbae>
     ebc:	mov    $0x5,%esi
     ec1:	jmp    ee2 <botlish_fn_6+0xbca>
     ec6:	mov    %rcx,%rax
     ec9:	cmp    $0x6,%rax
     ecd:	je     edd <botlish_fn_6+0xbc5>
     ed3:	mov    $0x3,%esi
     ed8:	jmp    ee2 <botlish_fn_6+0xbca>
     edd:	mov    $0x15,%esi
     ee2:	sar    $1,%rsi
     ee5:	cmp    $0x8,%rsi
     ee9:	jl     1016 <botlish_fn_6+0xcfe>
     eef:	cmp    $0x8,%rsi
     ef3:	je     ffb <botlish_fn_6+0xce3>
     ef9:	cmp    $0x6,%rcx
     efd:	je     f4b <botlish_fn_6+0xc33>
     f03:	mov    0x98(%rsp),%rdi
     f0b:	call   f10 <botlish_fn_6+0xbf8>
			f0c: R_X86_64_PLT32	botlish_fn_1-0x4
     f10:	mov    0x98(%rsp),%rdi
     f18:	mov    0x10(%rdi),%rcx
     f1c:	mov    0x70(%rcx),%rdx
     f20:	lea    0x70(%rsp),%r9
     f25:	mov    %rax,0x70(%rsp)
     f2a:	movq   $0xffffffffffffffff,0x78(%rsp)
     f33:	mov    $0x1,%esi
     f38:	mov    $0x2,%r8d
     f3e:	mov    %r8,%rcx
     f41:	call   f46 <botlish_fn_6+0xc2e>
			f42: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     f46:	jmp    f85 <botlish_fn_6+0xc6d>
     f4b:	mov    0x98(%rsp),%rdi
     f53:	call   f58 <botlish_fn_6+0xc40>
			f54: R_X86_64_PLT32	botlish_fn_1-0x4
     f58:	mov    0x98(%rsp),%rdi
     f60:	mov    0x10(%rdi),%rcx
     f64:	mov    0x68(%rcx),%rdx
     f68:	lea    0x68(%rsp),%r9
     f6d:	mov    %rax,0x68(%rsp)
     f72:	mov    $0x2,%esi
     f77:	mov    $0x1,%r8d
     f7d:	mov    %r8,%rcx
     f80:	call   f85 <botlish_fn_6+0xc6d>
			f81: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     f85:	mov    0x98(%rsp),%rdi
     f8d:	call   f92 <botlish_fn_6+0xc7a>
			f8e: R_X86_64_PLT32	rt_co_failed-0x4
     f92:	mov    %rax,(%rsp)
     f96:	mov    %rax,%rsi
     f99:	mov    0x98(%rsp),%rdi
     fa1:	call   fa6 <botlish_fn_6+0xc8e>
			fa2: R_X86_64_PLT32	rt_co_resume0-0x4
     fa6:	test   %rax,%rax
     fa9:	je     fc8 <botlish_fn_6+0xcb0>
     faf:	mov    0x98(%rsp),%rdi
     fb7:	mov    0x10(%rdi),%rax
     fbb:	mov    0x40(%rax),%rsi
     fbf:	mov    0x60(%rax),%rdx
     fc3:	call   fc8 <botlish_fn_6+0xcb0>
			fc4: R_X86_64_PLT32	rt_raise-0x4
     fc8:	mov    0x98(%rsp),%rdi
     fd0:	call   fd5 <botlish_fn_6+0xcbd>
			fd1: R_X86_64_PLT32	rt_declared_error-0x4
     fd5:	cmp    $0x2,%rax
     fd9:	je     1dfe <botlish_fn_6+0x1ae6>
     fdf:	mov    0x98(%rsp),%rdi
     fe7:	call   fec <botlish_fn_6+0xcd4>
			fe8: R_X86_64_PLT32	rt_declared_error-0x4
     fec:	cmp    $0x1,%rax
     ff0:	jne    1dfe <botlish_fn_6+0x1ae6>
     ff6:	jmp    1dfe <botlish_fn_6+0x1ae6>
     ffb:	mov    %rcx,0xb0(%rsp)
    1003:	mov    $0x2,%r14d
    1009:	mov    0xb0(%rsp),%r15
    1011:	jmp    102c <botlish_fn_6+0xd14>
    1016:	mov    %rcx,0xb0(%rsp)
    101e:	mov    $0x1,%r14d
    1024:	mov    0xb0(%rsp),%r15
    102c:	test   %r14,%r14
    102f:	jl     106e <botlish_fn_6+0xd56>
    1035:	mov    $0x1,%eax
    103a:	mov    0xc0(%rsp),%rbx
    1042:	mov    0xc8(%rsp),%r12
    104a:	mov    0xd0(%rsp),%r13
    1052:	mov    0xd8(%rsp),%r14
    105a:	mov    0xe0(%rsp),%r15
    1062:	add    $0xf0,%rsp
    1069:	mov    %rbp,%rsp
    106c:	pop    %rbp
    106d:	ret
    106e:	mov    $0x3,%eax
    1073:	mov    0xc0(%rsp),%rbx
    107b:	mov    0xc8(%rsp),%r12
    1083:	mov    0xd0(%rsp),%r13
    108b:	mov    0xd8(%rsp),%r14
    1093:	mov    0xe0(%rsp),%r15
    109b:	add    $0xf0,%rsp
    10a2:	mov    %rbp,%rsp
    10a5:	pop    %rbp
    10a6:	ret
    10a7:	mov    %r13,%rsi
    10aa:	mov    0x98(%rsp),%rdi
    10b2:	call   10b7 <botlish_fn_6+0xd9f>
			10b3: R_X86_64_PLT32	botlish_fn_5-0x4
    10b7:	mov    %r13,0xa8(%rsp)
    10bf:	mov    %rax,0xb8(%rsp)
    10c7:	cmp    $0x1,%r14
    10cb:	je     146e <botlish_fn_6+0x1156>
    10d1:	mov    $0x2,%r8d
    10d7:	mov    %r8,%r13
    10da:	cmp    $0x2,%r14
    10de:	je     10f8 <botlish_fn_6+0xde0>
    10e4:	mov    $0xa,%esi
    10e9:	cmp    $0xffffffffffffffff,%r14
    10ed:	je     1e62 <botlish_fn_6+0x1b4a>
    10f3:	jmp    1da7 <botlish_fn_6+0x1a8f>
    10f8:	mov    0xb8(%rsp),%rax
    1100:	test   $0x1,%rax
    1106:	jne    113c <botlish_fn_6+0xe24>
    110c:	mov    $0x101,%edx
    1111:	mov    0xb8(%rsp),%rsi
    1119:	mov    0x98(%rsp),%rdi
    1121:	call   1126 <botlish_fn_6+0xe0e>
			1122: R_X86_64_PLT32	rt_int_cmp-0x4
    1126:	test   %rax,%rax
    1129:	mov    %r13,%r8
    112c:	mov    %r8,%rcx
    112f:	cmovl  0xd51(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1137:	jmp    1158 <botlish_fn_6+0xe40>
    113c:	mov    0xb8(%rsp),%rax
    1144:	cmp    $0x101,%rax
    114a:	mov    %r13,%r8
    114d:	mov    %r8,%rcx
    1150:	cmovl  0xd30(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1158:	cmp    $0x6,%rcx
    115c:	je     1257 <botlish_fn_6+0xf3f>
    1162:	mov    0xb8(%rsp),%rax
    116a:	test   $0x1,%rax
    1170:	jne    11a6 <botlish_fn_6+0xe8e>
    1176:	mov    $0x185,%edx
    117b:	mov    0xb8(%rsp),%rsi
    1183:	mov    0x98(%rsp),%rdi
    118b:	call   1190 <botlish_fn_6+0xe78>
			118c: R_X86_64_PLT32	rt_int_cmp-0x4
    1190:	test   %rax,%rax
    1193:	mov    %r13,%r8
    1196:	mov    %r8,%rcx
    1199:	cmovl  0xce7(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    11a1:	jmp    11c2 <botlish_fn_6+0xeaa>
    11a6:	mov    0xb8(%rsp),%rax
    11ae:	cmp    $0x185,%rax
    11b4:	mov    %r13,%r8
    11b7:	mov    %r8,%rcx
    11ba:	cmovl  0xcc6(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    11c2:	cmp    $0x6,%rcx
    11c6:	je     124c <botlish_fn_6+0xf34>
    11cc:	mov    0xb8(%rsp),%rax
    11d4:	test   $0x1,%rax
    11da:	jne    1210 <botlish_fn_6+0xef8>
    11e0:	mov    $0x1eb,%edx
    11e5:	mov    0xb8(%rsp),%rsi
    11ed:	mov    0x98(%rsp),%rdi
    11f5:	call   11fa <botlish_fn_6+0xee2>
			11f6: R_X86_64_PLT32	rt_int_cmp-0x4
    11fa:	test   %rax,%rax
    11fd:	mov    %r13,%r8
    1200:	mov    %r8,%rdx
    1203:	cmovl  0xc7d(%rip),%rdx        # 1e88 <botlish_fn_6+0x1b70>
    120b:	jmp    122c <botlish_fn_6+0xf14>
    1210:	mov    0xb8(%rsp),%rax
    1218:	cmp    $0x1eb,%rax
    121e:	mov    %r13,%r8
    1221:	mov    %r8,%rdx
    1224:	cmovl  0xc5c(%rip),%rdx        # 1e88 <botlish_fn_6+0x1b70>
    122c:	cmp    $0x6,%rdx
    1230:	je     1241 <botlish_fn_6+0xf29>
    1236:	mov    $0x9,%r8d
    123c:	jmp    12f1 <botlish_fn_6+0xfd9>
    1241:	mov    $0x7,%r8d
    1247:	jmp    12f1 <botlish_fn_6+0xfd9>
    124c:	mov    $0x9,%r8d
    1252:	jmp    12f1 <botlish_fn_6+0xfd9>
    1257:	mov    0xb8(%rsp),%rax
    125f:	test   $0x1,%rax
    1265:	jne    129d <botlish_fn_6+0xf85>
    126b:	mov    $0xffffffffffffffff,%rdx
    1272:	mov    0xb8(%rsp),%rsi
    127a:	mov    0x98(%rsp),%rdi
    1282:	call   1287 <botlish_fn_6+0xf6f>
			1283: R_X86_64_PLT32	rt_int_cmp-0x4
    1287:	test   %rax,%rax
    128a:	mov    %r13,%r8
    128d:	mov    %r8,%rcx
    1290:	cmovl  0xbf0(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1298:	jmp    12b7 <botlish_fn_6+0xf9f>
    129d:	mov    0xb8(%rsp),%rax
    12a5:	cmp    $0xffffffffffffffff,%rax
    12a9:	mov    %r13,%r8
    12ac:	mov    %r8,%rcx
    12af:	cmovl  0xbd1(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    12b7:	cmp    $0x6,%rcx
    12bb:	je     12eb <botlish_fn_6+0xfd3>
    12c1:	mov    0xb8(%rsp),%rax
    12c9:	sar    $1,%rax
    12cc:	test   %rax,%rax
    12cf:	jl     12e0 <botlish_fn_6+0xfc8>
    12d5:	mov    $0x1,%r8d
    12db:	jmp    12f1 <botlish_fn_6+0xfd9>
    12e0:	mov    $0x5,%r8d
    12e6:	jmp    12f1 <botlish_fn_6+0xfd9>
    12eb:	mov    $0x9,%r8d
    12f1:	mov    %r8,%rcx
    12f4:	sar    $1,%rcx
    12f7:	test   %rcx,%rcx
    12fa:	jle    1e3b <botlish_fn_6+0x1b23>
    1300:	cmp    $0x2,%rcx
    1304:	je     1402 <botlish_fn_6+0x10ea>
    130a:	cmp    $0x3,%rcx
    130e:	je     13f2 <botlish_fn_6+0x10da>
    1314:	mov    0xb8(%rsp),%rax
    131c:	test   $0x1,%rax
    1322:	jne    135a <botlish_fn_6+0x1042>
    1328:	mov    $0xffffffffffffffff,%rdx
    132f:	mov    0xb8(%rsp),%rsi
    1337:	mov    0x98(%rsp),%rdi
    133f:	call   1344 <botlish_fn_6+0x102c>
			1340: R_X86_64_PLT32	rt_int_cmp-0x4
    1344:	test   %rax,%rax
    1347:	mov    %r13,%r8
    134a:	mov    %r8,%rcx
    134d:	cmove  0xb33(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1355:	jmp    1374 <botlish_fn_6+0x105c>
    135a:	mov    0xb8(%rsp),%rax
    1362:	cmp    $0xffffffffffffffff,%rax
    1366:	mov    %r13,%r8
    1369:	mov    %r8,%rcx
    136c:	cmove  0xb14(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1374:	cmp    $0x6,%rcx
    1378:	je     13be <botlish_fn_6+0x10a6>
    137e:	mov    0x98(%rsp),%rdi
    1386:	mov    0x10(%rdi),%rdx
    138a:	mov    0x78(%rdx),%rcx
    138e:	mov    0x70(%rdx),%rdx
    1392:	lea    0x58(%rsp),%r9
    1397:	mov    %rcx,0x58(%rsp)
    139c:	mov    0xb8(%rsp),%rax
    13a4:	mov    %rax,0x60(%rsp)
    13a9:	mov    $0x1,%esi
    13ae:	mov    %r13,%r8
    13b1:	mov    %r8,%rcx
    13b4:	call   13b9 <botlish_fn_6+0x10a1>
			13b5: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    13b9:	jmp    1d93 <botlish_fn_6+0x1a7b>
    13be:	mov    0x98(%rsp),%rdi
    13c6:	mov    0x10(%rdi),%rcx
    13ca:	mov    0x78(%rcx),%rax
    13ce:	mov    0x68(%rcx),%rdx
    13d2:	lea    0x50(%rsp),%r9
    13d7:	mov    %rax,0x50(%rsp)
    13dc:	mov    $0x1,%r8d
    13e2:	mov    %r13,%rsi
    13e5:	mov    %r8,%rcx
    13e8:	call   13ed <botlish_fn_6+0x10d5>
			13e9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    13ed:	jmp    1d93 <botlish_fn_6+0x1a7b>
    13f2:	xor    %rcx,%rcx
    13f5:	mov    0xb8(%rsp),%rsi
    13fd:	jmp    147c <botlish_fn_6+0x1164>
    1402:	mov    0xb8(%rsp),%rax
    140a:	test   $0x1,%rax
    1410:	jne    1448 <botlish_fn_6+0x1130>
    1416:	mov    $0xfffffffffffffffd,%rdx
    141d:	mov    0xb8(%rsp),%rsi
    1425:	mov    0x98(%rsp),%rdi
    142d:	call   1432 <botlish_fn_6+0x111a>
			142e: R_X86_64_PLT32	rt_int_cmp-0x4
    1432:	test   %rax,%rax
    1435:	mov    %r13,%rsi
    1438:	mov    %rsi,%r15
    143b:	cmove  0xa45(%rip),%r15        # 1e88 <botlish_fn_6+0x1b70>
    1443:	jmp    1462 <botlish_fn_6+0x114a>
    1448:	mov    0xb8(%rsp),%rsi
    1450:	cmp    $0xfffffffffffffffd,%rsi
    1454:	mov    %r13,%rsi
    1457:	mov    %rsi,%r15
    145a:	cmove  0xa26(%rip),%r15        # 1e88 <botlish_fn_6+0x1b70>
    1462:	mov    $0xffffffffffffffff,%r14
    1469:	jmp    1e62 <botlish_fn_6+0x1b4a>
    146e:	mov    0xb8(%rsp),%rsi
    1476:	mov    %rbx,%rcx
    1479:	sar    $1,%rcx
    147c:	cmp    $0x4,%rcx
    1480:	jl     17de <botlish_fn_6+0x14c6>
    1486:	cmp    $0x6,%rcx
    148a:	jl     163b <botlish_fn_6+0x1323>
    1490:	mov    $0x7,%r13d
    1496:	cmp    $0x7,%rcx
    149a:	jl     1578 <botlish_fn_6+0x1260>
    14a0:	test   $0x1,%rsi
    14a7:	mov    %rsi,0xb8(%rsp)
    14af:	jne    14e7 <botlish_fn_6+0x11cf>
    14b5:	mov    $0x101,%edx
    14ba:	mov    0xb8(%rsp),%r15
    14c2:	mov    %r15,%rsi
    14c5:	mov    0x98(%rsp),%rdi
    14cd:	call   14d2 <botlish_fn_6+0x11ba>
			14ce: R_X86_64_PLT32	rt_int_cmp-0x4
    14d2:	mov    $0x2,%ecx
    14d7:	test   %rax,%rax
    14da:	cmovl  0x9a6(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    14e2:	jmp    1503 <botlish_fn_6+0x11eb>
    14e7:	mov    0xb8(%rsp),%r15
    14ef:	mov    $0x2,%ecx
    14f4:	cmp    $0x101,%r15
    14fb:	cmovl  0x985(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1503:	cmp    $0x6,%rcx
    1507:	je     156d <botlish_fn_6+0x1255>
    150d:	test   $0x1,%r15
    1514:	jne    1544 <botlish_fn_6+0x122c>
    151a:	mov    $0x121,%edx
    151f:	mov    %r15,%rsi
    1522:	mov    0x98(%rsp),%rdi
    152a:	call   152f <botlish_fn_6+0x1217>
			152b: R_X86_64_PLT32	rt_int_cmp-0x4
    152f:	mov    $0x2,%ecx
    1534:	test   %rax,%rax
    1537:	cmovl  0x949(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    153f:	jmp    1558 <botlish_fn_6+0x1240>
    1544:	mov    $0x2,%ecx
    1549:	cmp    $0x121,%r15
    1550:	cmovl  0x930(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1558:	cmp    $0x6,%rcx
    155c:	je     1c9e <botlish_fn_6+0x1986>
    1562:	mov    $0x23,%r13d
    1568:	jmp    1c9e <botlish_fn_6+0x1986>
    156d:	mov    $0x23,%r13d
    1573:	jmp    1c9e <botlish_fn_6+0x1986>
    1578:	mov    %rsi,%r15
    157b:	test   $0x1,%r15
    1582:	jne    15b2 <botlish_fn_6+0x129a>
    1588:	mov    $0x101,%edx
    158d:	mov    %r15,%rsi
    1590:	mov    0x98(%rsp),%rdi
    1598:	call   159d <botlish_fn_6+0x1285>
			1599: R_X86_64_PLT32	rt_int_cmp-0x4
    159d:	mov    $0x2,%ecx
    15a2:	test   %rax,%rax
    15a5:	cmovl  0x8db(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    15ad:	jmp    15c6 <botlish_fn_6+0x12ae>
    15b2:	mov    $0x2,%ecx
    15b7:	cmp    $0x101,%r15
    15be:	cmovl  0x8c2(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    15c6:	cmp    $0x6,%rcx
    15ca:	je     1630 <botlish_fn_6+0x1318>
    15d0:	test   $0x1,%r15
    15d7:	jne    1607 <botlish_fn_6+0x12ef>
    15dd:	mov    $0x181,%edx
    15e2:	mov    %r15,%rsi
    15e5:	mov    0x98(%rsp),%rdi
    15ed:	call   15f2 <botlish_fn_6+0x12da>
			15ee: R_X86_64_PLT32	rt_int_cmp-0x4
    15f2:	mov    $0x2,%ecx
    15f7:	test   %rax,%rax
    15fa:	cmovl  0x886(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1602:	jmp    161b <botlish_fn_6+0x1303>
    1607:	mov    $0x2,%ecx
    160c:	cmp    $0x181,%r15
    1613:	cmovl  0x86d(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    161b:	cmp    $0x6,%rcx
    161f:	je     1c9e <botlish_fn_6+0x1986>
    1625:	mov    $0x21,%r13d
    162b:	jmp    1c9e <botlish_fn_6+0x1986>
    1630:	mov    $0x21,%r13d
    1636:	jmp    1c9e <botlish_fn_6+0x1986>
    163b:	mov    %rsi,%r15
    163e:	cmp    $0x5,%rcx
    1642:	jl     1713 <botlish_fn_6+0x13fb>
    1648:	test   $0x1,%r15
    164f:	jne    167f <botlish_fn_6+0x1367>
    1655:	mov    $0x121,%edx
    165a:	mov    %r15,%rsi
    165d:	mov    0x98(%rsp),%rdi
    1665:	call   166a <botlish_fn_6+0x1352>
			1666: R_X86_64_PLT32	rt_int_cmp-0x4
    166a:	mov    $0x2,%ecx
    166f:	test   %rax,%rax
    1672:	cmovl  0x80e(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    167a:	jmp    1693 <botlish_fn_6+0x137b>
    167f:	mov    $0x2,%ecx
    1684:	cmp    $0x121,%r15
    168b:	cmovl  0x7f5(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1693:	cmp    $0x6,%rcx
    1697:	je     1708 <botlish_fn_6+0x13f0>
    169d:	test   $0x1,%r15
    16a4:	jne    16d4 <botlish_fn_6+0x13bc>
    16aa:	mov    $0x181,%edx
    16af:	mov    %r15,%rsi
    16b2:	mov    0x98(%rsp),%rdi
    16ba:	call   16bf <botlish_fn_6+0x13a7>
			16bb: R_X86_64_PLT32	rt_int_cmp-0x4
    16bf:	mov    $0x2,%ecx
    16c4:	test   %rax,%rax
    16c7:	cmovl  0x7b9(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    16cf:	jmp    16e8 <botlish_fn_6+0x13d0>
    16d4:	mov    $0x2,%ecx
    16d9:	cmp    $0x181,%r15
    16e0:	cmovl  0x7a0(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    16e8:	cmp    $0x6,%rcx
    16ec:	je     16fd <botlish_fn_6+0x13e5>
    16f2:	mov    $0x1f,%r13d
    16f8:	jmp    1c9e <botlish_fn_6+0x1986>
    16fd:	mov    $0x7,%r13d
    1703:	jmp    1c9e <botlish_fn_6+0x1986>
    1708:	mov    $0x1f,%r13d
    170e:	jmp    1c9e <botlish_fn_6+0x1986>
    1713:	test   $0x1,%r15
    171a:	jne    174a <botlish_fn_6+0x1432>
    1720:	mov    $0x101,%edx
    1725:	mov    %r15,%rsi
    1728:	mov    0x98(%rsp),%rdi
    1730:	call   1735 <botlish_fn_6+0x141d>
			1731: R_X86_64_PLT32	rt_int_cmp-0x4
    1735:	mov    $0x2,%esi
    173a:	test   %rax,%rax
    173d:	cmovl  0x743(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
    1745:	jmp    175e <botlish_fn_6+0x1446>
    174a:	mov    $0x2,%esi
    174f:	cmp    $0x101,%r15
    1756:	cmovl  0x72a(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
    175e:	cmp    $0x6,%rsi
    1762:	je     17d3 <botlish_fn_6+0x14bb>
    1768:	test   $0x1,%r15
    176f:	jne    179f <botlish_fn_6+0x1487>
    1775:	mov    $0x141,%edx
    177a:	mov    %r15,%rsi
    177d:	mov    0x98(%rsp),%rdi
    1785:	call   178a <botlish_fn_6+0x1472>
			1786: R_X86_64_PLT32	rt_int_cmp-0x4
    178a:	mov    $0x2,%ecx
    178f:	test   %rax,%rax
    1792:	cmovl  0x6ee(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    179a:	jmp    17b3 <botlish_fn_6+0x149b>
    179f:	mov    $0x2,%ecx
    17a4:	cmp    $0x141,%r15
    17ab:	cmovl  0x6d5(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    17b3:	cmp    $0x6,%rcx
    17b7:	je     17c8 <botlish_fn_6+0x14b0>
    17bd:	mov    $0x1d,%r13d
    17c3:	jmp    1c9e <botlish_fn_6+0x1986>
    17c8:	mov    $0x3,%r13d
    17ce:	jmp    1c9e <botlish_fn_6+0x1986>
    17d3:	mov    $0x1d,%r13d
    17d9:	jmp    1c9e <botlish_fn_6+0x1986>
    17de:	mov    %rsi,%r15
    17e1:	mov    $0x2,%r14d
    17e7:	cmp    $0x2,%rcx
    17eb:	jl     1965 <botlish_fn_6+0x164d>
    17f1:	mov    $0x3,%r13d
    17f7:	cmp    $0x3,%rcx
    17fb:	jl     18b3 <botlish_fn_6+0x159b>
    1801:	test   $0x1,%r15
    1808:	jne    1836 <botlish_fn_6+0x151e>
    180e:	mov    $0x101,%edx
    1813:	mov    %r15,%rsi
    1816:	mov    0x98(%rsp),%rdi
    181e:	call   1823 <botlish_fn_6+0x150b>
			181f: R_X86_64_PLT32	rt_int_cmp-0x4
    1823:	test   %rax,%rax
    1826:	mov    %r14,%rcx
    1829:	cmovl  0x657(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1831:	jmp    1848 <botlish_fn_6+0x1530>
    1836:	cmp    $0x101,%r15
    183d:	mov    %r14,%rcx
    1840:	cmovl  0x640(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1848:	cmp    $0x6,%rcx
    184c:	je     18a8 <botlish_fn_6+0x1590>
    1852:	test   $0x1,%r15
    1859:	jne    1884 <botlish_fn_6+0x156c>
    185f:	mov    $0x181,%edx
    1864:	mov    %r15,%rsi
    1867:	mov    0x98(%rsp),%rdi
    186f:	call   1874 <botlish_fn_6+0x155c>
			1870: R_X86_64_PLT32	rt_int_cmp-0x4
    1874:	test   %rax,%rax
    1877:	cmovl  0x609(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    187f:	jmp    1893 <botlish_fn_6+0x157b>
    1884:	cmp    $0x181,%r15
    188b:	cmovl  0x5f5(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1893:	cmp    $0x6,%r14
    1897:	je     1c9e <botlish_fn_6+0x1986>
    189d:	mov    $0x1b,%r13d
    18a3:	jmp    1c9e <botlish_fn_6+0x1986>
    18a8:	mov    $0x1b,%r13d
    18ae:	jmp    1c9e <botlish_fn_6+0x1986>
    18b3:	test   $0x1,%r15
    18ba:	jne    18e8 <botlish_fn_6+0x15d0>
    18c0:	mov    $0x141,%edx
    18c5:	mov    %r15,%rsi
    18c8:	mov    0x98(%rsp),%rdi
    18d0:	call   18d5 <botlish_fn_6+0x15bd>
			18d1: R_X86_64_PLT32	rt_int_cmp-0x4
    18d5:	test   %rax,%rax
    18d8:	mov    %r14,%rsi
    18db:	cmovl  0x5a5(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
    18e3:	jmp    18fa <botlish_fn_6+0x15e2>
    18e8:	cmp    $0x141,%r15
    18ef:	mov    %r14,%rsi
    18f2:	cmovl  0x58e(%rip),%rsi        # 1e88 <botlish_fn_6+0x1b70>
    18fa:	cmp    $0x6,%rsi
    18fe:	je     195a <botlish_fn_6+0x1642>
    1904:	test   $0x1,%r15
    190b:	jne    1936 <botlish_fn_6+0x161e>
    1911:	mov    $0x181,%edx
    1916:	mov    %r15,%rsi
    1919:	mov    0x98(%rsp),%rdi
    1921:	call   1926 <botlish_fn_6+0x160e>
			1922: R_X86_64_PLT32	rt_int_cmp-0x4
    1926:	test   %rax,%rax
    1929:	cmovl  0x557(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1931:	jmp    1945 <botlish_fn_6+0x162d>
    1936:	cmp    $0x181,%r15
    193d:	cmovl  0x543(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1945:	cmp    $0x6,%r14
    1949:	je     1c9e <botlish_fn_6+0x1986>
    194f:	mov    $0x19,%r13d
    1955:	jmp    1c9e <botlish_fn_6+0x1986>
    195a:	mov    $0x19,%r13d
    1960:	jmp    1c9e <botlish_fn_6+0x1986>
    1965:	test   %rcx,%rcx
    1968:	jle    1a2b <botlish_fn_6+0x1713>
    196e:	test   $0x1,%r15
    1975:	jne    19a3 <botlish_fn_6+0x168b>
    197b:	mov    $0x101,%edx
    1980:	mov    %r15,%rsi
    1983:	mov    0x98(%rsp),%rdi
    198b:	call   1990 <botlish_fn_6+0x1678>
			198c: R_X86_64_PLT32	rt_int_cmp-0x4
    1990:	test   %rax,%rax
    1993:	mov    %r14,%rax
    1996:	cmovl  0x4ea(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    199e:	jmp    19b5 <botlish_fn_6+0x169d>
    19a3:	cmp    $0x101,%r15
    19aa:	mov    %r14,%rax
    19ad:	cmovl  0x4d3(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    19b5:	cmp    $0x6,%rax
    19b9:	je     1a20 <botlish_fn_6+0x1708>
    19bf:	test   $0x1,%r15
    19c6:	jne    19f1 <botlish_fn_6+0x16d9>
    19cc:	mov    $0x181,%edx
    19d1:	mov    %r15,%rsi
    19d4:	mov    0x98(%rsp),%rdi
    19dc:	call   19e1 <botlish_fn_6+0x16c9>
			19dd: R_X86_64_PLT32	rt_int_cmp-0x4
    19e1:	test   %rax,%rax
    19e4:	cmovl  0x49c(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    19ec:	jmp    1a00 <botlish_fn_6+0x16e8>
    19f1:	cmp    $0x181,%r15
    19f8:	cmovl  0x488(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1a00:	cmp    $0x6,%r14
    1a04:	je     1a15 <botlish_fn_6+0x16fd>
    1a0a:	mov    $0x17,%r13d
    1a10:	jmp    1c9e <botlish_fn_6+0x1986>
    1a15:	mov    $0x11,%r13d
    1a1b:	jmp    1c9e <botlish_fn_6+0x1986>
    1a20:	mov    $0x17,%r13d
    1a26:	jmp    1c9e <botlish_fn_6+0x1986>
    1a2b:	test   $0x1,%r15
    1a32:	jne    1a60 <botlish_fn_6+0x1748>
    1a38:	mov    $0x1dd,%edx
    1a3d:	mov    %r15,%rsi
    1a40:	mov    0x98(%rsp),%rdi
    1a48:	call   1a4d <botlish_fn_6+0x1735>
			1a49: R_X86_64_PLT32	rt_int_cmp-0x4
    1a4d:	test   %rax,%rax
    1a50:	mov    %r14,%rax
    1a53:	cmovl  0x42d(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    1a5b:	jmp    1a72 <botlish_fn_6+0x175a>
    1a60:	cmp    $0x1dd,%r15
    1a67:	mov    %r14,%rax
    1a6a:	cmovl  0x416(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    1a72:	cmp    $0x6,%rax
    1a76:	je     1bb2 <botlish_fn_6+0x189a>
    1a7c:	test   $0x1,%r15
    1a83:	jne    1ab1 <botlish_fn_6+0x1799>
    1a89:	mov    $0x1e3,%edx
    1a8e:	mov    %r15,%rsi
    1a91:	mov    0x98(%rsp),%rdi
    1a99:	call   1a9e <botlish_fn_6+0x1786>
			1a9a: R_X86_64_PLT32	rt_int_cmp-0x4
    1a9e:	test   %rax,%rax
    1aa1:	mov    %r14,%r8
    1aa4:	cmovl  0x3dc(%rip),%r8        # 1e88 <botlish_fn_6+0x1b70>
    1aac:	jmp    1ac3 <botlish_fn_6+0x17ab>
    1ab1:	cmp    $0x1e3,%r15
    1ab8:	mov    %r14,%r8
    1abb:	cmovl  0x3c5(%rip),%r8        # 1e88 <botlish_fn_6+0x1b70>
    1ac3:	cmp    $0x6,%r8
    1ac7:	je     1b8a <botlish_fn_6+0x1872>
    1acd:	test   $0x1,%r15
    1ad4:	jne    1b02 <botlish_fn_6+0x17ea>
    1ada:	mov    $0x1e9,%edx
    1adf:	mov    %r15,%rsi
    1ae2:	mov    0x98(%rsp),%rdi
    1aea:	call   1aef <botlish_fn_6+0x17d7>
			1aeb: R_X86_64_PLT32	rt_int_cmp-0x4
    1aef:	test   %rax,%rax
    1af2:	mov    %r14,%rax
    1af5:	cmovl  0x38b(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    1afd:	jmp    1b14 <botlish_fn_6+0x17fc>
    1b02:	cmp    $0x1e9,%r15
    1b09:	mov    %r14,%rax
    1b0c:	cmovl  0x374(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    1b14:	cmp    $0x6,%rax
    1b18:	je     1b7f <botlish_fn_6+0x1867>
    1b1e:	test   $0x1,%r15
    1b25:	jne    1b50 <botlish_fn_6+0x1838>
    1b2b:	mov    $0x1eb,%edx
    1b30:	mov    %r15,%rsi
    1b33:	mov    0x98(%rsp),%rdi
    1b3b:	call   1b40 <botlish_fn_6+0x1828>
			1b3c: R_X86_64_PLT32	rt_int_cmp-0x4
    1b40:	test   %rax,%rax
    1b43:	cmovl  0x33d(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1b4b:	jmp    1b5f <botlish_fn_6+0x1847>
    1b50:	cmp    $0x1eb,%r15
    1b57:	cmovl  0x329(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1b5f:	cmp    $0x6,%r14
    1b63:	je     1b74 <botlish_fn_6+0x185c>
    1b69:	mov    $0x15,%r13d
    1b6f:	jmp    1c9e <botlish_fn_6+0x1986>
    1b74:	mov    $0xf,%r13d
    1b7a:	jmp    1c9e <botlish_fn_6+0x1986>
    1b7f:	mov    $0xd,%r13d
    1b85:	jmp    1c9e <botlish_fn_6+0x1986>
    1b8a:	mov    %r15,%rax
    1b8d:	sar    $1,%rax
    1b90:	cmp    $0xf0,%rax
    1b96:	jl     1ba7 <botlish_fn_6+0x188f>
    1b9c:	mov    $0xb,%r13d
    1ba2:	jmp    1c9e <botlish_fn_6+0x1986>
    1ba7:	mov    $0x7,%r13d
    1bad:	jmp    1c9e <botlish_fn_6+0x1986>
    1bb2:	test   $0x1,%r15
    1bb9:	jne    1be7 <botlish_fn_6+0x18cf>
    1bbf:	mov    $0x1c1,%edx
    1bc4:	mov    %r15,%rsi
    1bc7:	mov    0x98(%rsp),%rdi
    1bcf:	call   1bd4 <botlish_fn_6+0x18bc>
			1bd0: R_X86_64_PLT32	rt_int_cmp-0x4
    1bd4:	test   %rax,%rax
    1bd7:	mov    %r14,%rax
    1bda:	cmovl  0x2a6(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    1be2:	jmp    1bf9 <botlish_fn_6+0x18e1>
    1be7:	cmp    $0x1c1,%r15
    1bee:	mov    %r14,%rax
    1bf1:	cmovl  0x28f(%rip),%rax        # 1e88 <botlish_fn_6+0x1b70>
    1bf9:	cmp    $0x6,%rax
    1bfd:	je     1c42 <botlish_fn_6+0x192a>
    1c03:	mov    %r15,%rax
    1c06:	sar    $1,%rax
    1c09:	cmp    $0xe1,%rax
    1c0f:	jl     1c37 <botlish_fn_6+0x191f>
    1c15:	cmp    $0xed,%rax
    1c1b:	jl     1c2c <botlish_fn_6+0x1914>
    1c21:	mov    $0x9,%r13d
    1c27:	jmp    1c9e <botlish_fn_6+0x1986>
    1c2c:	mov    $0x7,%r13d
    1c32:	jmp    1c9e <botlish_fn_6+0x1986>
    1c37:	mov    $0x5,%r13d
    1c3d:	jmp    1c9e <botlish_fn_6+0x1986>
    1c42:	test   $0x1,%r15
    1c49:	jne    1c74 <botlish_fn_6+0x195c>
    1c4f:	mov    $0x185,%edx
    1c54:	mov    %r15,%rsi
    1c57:	mov    0x98(%rsp),%rdi
    1c5f:	call   1c64 <botlish_fn_6+0x194c>
			1c60: R_X86_64_PLT32	rt_int_cmp-0x4
    1c64:	test   %rax,%rax
    1c67:	cmovl  0x219(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1c6f:	jmp    1c83 <botlish_fn_6+0x196b>
    1c74:	cmp    $0x185,%r15
    1c7b:	cmovl  0x205(%rip),%r14        # 1e88 <botlish_fn_6+0x1b70>
    1c83:	cmp    $0x6,%r14
    1c87:	je     1c98 <botlish_fn_6+0x1980>
    1c8d:	mov    $0x3,%r13d
    1c93:	jmp    1c9e <botlish_fn_6+0x1986>
    1c98:	mov    $0x15,%r13d
    1c9e:	mov    %r13,%rsi
    1ca1:	sar    $1,%rsi
    1ca4:	cmp    $0x8,%rsi
    1ca8:	jl     1e51 <botlish_fn_6+0x1b39>
    1cae:	cmp    $0x8,%rsi
    1cb2:	mov    %rsi,%r12
    1cb5:	je     1e35 <botlish_fn_6+0x1b1d>
    1cbb:	test   $0x1,%r15
    1cc2:	jne    1cf4 <botlish_fn_6+0x19dc>
    1cc8:	mov    $0xffffffffffffffff,%rdx
    1ccf:	mov    %r15,%rsi
    1cd2:	mov    0x98(%rsp),%rdi
    1cda:	call   1cdf <botlish_fn_6+0x19c7>
			1cdb: R_X86_64_PLT32	rt_int_cmp-0x4
    1cdf:	mov    $0x2,%ecx
    1ce4:	test   %rax,%rax
    1ce7:	cmove  0x199(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1cef:	jmp    1d05 <botlish_fn_6+0x19ed>
    1cf4:	mov    $0x2,%ecx
    1cf9:	cmp    $0xffffffffffffffff,%r15
    1cfd:	cmove  0x183(%rip),%rcx        # 1e88 <botlish_fn_6+0x1b70>
    1d05:	cmp    $0x6,%rcx
    1d09:	je     1d56 <botlish_fn_6+0x1a3e>
    1d0f:	mov    %r12,%rsi
    1d12:	mov    0x98(%rsp),%rdi
    1d1a:	call   1d1f <botlish_fn_6+0x1a07>
			1d1b: R_X86_64_PLT32	botlish_fn_1-0x4
    1d1f:	mov    0x98(%rsp),%rdi
    1d27:	mov    0x10(%rdi),%r8
    1d2b:	mov    0x70(%r8),%rdx
    1d2f:	lea    0x40(%rsp),%r9
    1d34:	mov    %rax,0x40(%rsp)
    1d39:	mov    %r15,0x48(%rsp)
    1d3e:	mov    $0x1,%esi
    1d43:	mov    $0x2,%r8d
    1d49:	mov    %r8,%rcx
    1d4c:	call   1d51 <botlish_fn_6+0x1a39>
			1d4d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d51:	jmp    1d93 <botlish_fn_6+0x1a7b>
    1d56:	mov    %r12,%rsi
    1d59:	mov    0x98(%rsp),%rdi
    1d61:	call   1d66 <botlish_fn_6+0x1a4e>
			1d62: R_X86_64_PLT32	botlish_fn_1-0x4
    1d66:	mov    0x98(%rsp),%rdi
    1d6e:	mov    0x10(%rdi),%r11
    1d72:	mov    0x68(%r11),%rdx
    1d76:	lea    0x38(%rsp),%r9
    1d7b:	mov    %rax,0x38(%rsp)
    1d80:	mov    $0x2,%esi
    1d85:	mov    $0x1,%r8d
    1d8b:	mov    %r8,%rcx
    1d8e:	call   1d93 <botlish_fn_6+0x1a7b>
			1d8f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d93:	mov    0x98(%rsp),%rdi
    1d9b:	call   1da0 <botlish_fn_6+0x1a88>
			1d9c: R_X86_64_PLT32	rt_co_failed-0x4
    1da0:	mov    %rax,(%rsp)
    1da4:	mov    %rax,%rsi
    1da7:	mov    0x98(%rsp),%rdi
    1daf:	call   1db4 <botlish_fn_6+0x1a9c>
			1db0: R_X86_64_PLT32	rt_co_resume0-0x4
    1db4:	test   %rax,%rax
    1db7:	je     1dd6 <botlish_fn_6+0x1abe>
    1dbd:	mov    0x98(%rsp),%rdi
    1dc5:	mov    0x10(%rdi),%rax
    1dc9:	mov    0x40(%rax),%rsi
    1dcd:	mov    0x60(%rax),%rdx
    1dd1:	call   1dd6 <botlish_fn_6+0x1abe>
			1dd2: R_X86_64_PLT32	rt_raise-0x4
    1dd6:	mov    0x98(%rsp),%rdi
    1dde:	call   1de3 <botlish_fn_6+0x1acb>
			1ddf: R_X86_64_PLT32	rt_declared_error-0x4
    1de3:	cmp    $0x2,%rax
    1de7:	je     1dfe <botlish_fn_6+0x1ae6>
    1ded:	mov    0x98(%rsp),%rdi
    1df5:	call   1dfa <botlish_fn_6+0x1ae2>
			1df6: R_X86_64_PLT32	rt_declared_error-0x4
    1dfa:	cmp    $0x1,%rax
    1dfe:	xor    %rax,%rax
    1e01:	mov    0xc0(%rsp),%rbx
    1e09:	mov    0xc8(%rsp),%r12
    1e11:	mov    0xd0(%rsp),%r13
    1e19:	mov    0xd8(%rsp),%r14
    1e21:	mov    0xe0(%rsp),%r15
    1e29:	add    $0xf0,%rsp
    1e30:	mov    %rbp,%rsp
    1e33:	pop    %rbp
    1e34:	ret
    1e35:	mov    $0x1,%r8d
    1e3b:	mov    $0x2,%r14d
    1e41:	mov    %r8,%r12
    1e44:	mov    0xb0(%rsp),%r15
    1e4c:	jmp    1e62 <botlish_fn_6+0x1b4a>
    1e51:	mov    $0x1,%r14d
    1e57:	mov    %r13,%rbx
    1e5a:	mov    0xb0(%rsp),%r15
    1e62:	mov    0xa8(%rsp),%rcx
    1e6a:	add    $0x1,%rcx
    1e71:	mov    0xa0(%rsp),%rsi
    1e79:	mov    %rcx,%r13
    1e7c:	jmp    b0d <botlish_fn_6+0x7f5>
    1e81:	add    %al,(%rax)
    1e83:	add    %al,(%rax)
    1e85:	add    %al,(%rax)
    1e87:	add    %al,(%rsi)
    1e89:	add    %al,(%rax)
    1e8b:	add    %al,(%rax)
    1e8d:	add    %al,(%rax)
	...

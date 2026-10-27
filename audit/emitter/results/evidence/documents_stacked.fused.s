<botlish_fn_24>:
    1f40:	push   %rbp
    1f41:	mov    %rsp,%rbp
    1f44:	sub    $0x330,%rsp
    1f4b:	mov    %rbx,0x300(%rsp)
    1f53:	mov    %r12,0x308(%rsp)
    1f5b:	mov    %r13,0x310(%rsp)
    1f63:	mov    %r14,0x318(%rsp)
    1f6b:	mov    %r15,0x320(%rsp)
    1f73:	mov    %rdi,0x1b8(%rsp)
    1f7b:	movq   $0x0,(%rsp)
    1f83:	movq   $0x0,0x8(%rsp)
    1f8c:	movq   $0x0,0x10(%rsp)
    1f95:	movq   $0x0,0x18(%rsp)
    1f9e:	movq   $0x0,0x20(%rsp)
    1fa7:	movq   $0x0,0x28(%rsp)
    1fb0:	movq   $0x0,0x30(%rsp)
    1fb9:	movq   $0x0,0x38(%rsp)
    1fc2:	movq   $0x0,0x40(%rsp)
    1fcb:	movq   $0x0,0x48(%rsp)
    1fd4:	movq   $0x0,0x50(%rsp)
    1fdd:	movq   $0x0,0x58(%rsp)
    1fe6:	movq   $0x0,0x60(%rsp)
    1fef:	movq   $0x0,0x68(%rsp)
    1ff8:	movq   $0x0,0x70(%rsp)
    2001:	movq   $0x0,0x78(%rsp)
    200a:	movq   $0x0,0x80(%rsp)
    2016:	movq   $0x0,0x88(%rsp)
    2022:	movq   $0x0,0x90(%rsp)
    202e:	movq   $0x0,0x98(%rsp)
    203a:	movq   $0x0,0xa0(%rsp)
    2046:	movq   $0x0,0xa8(%rsp)
    2052:	movq   $0x0,0xb0(%rsp)
    205e:	movq   $0x0,0xb8(%rsp)
    206a:	movq   $0x0,0xc0(%rsp)
    2076:	movq   $0x0,0xc8(%rsp)
    2082:	movq   $0x0,0xd0(%rsp)
    208e:	movq   $0x0,0xd8(%rsp)
    209a:	movq   $0x0,0xe0(%rsp)
    20a6:	movq   $0x0,0xe8(%rsp)
    20b2:	movq   $0x0,0xf0(%rsp)
    20be:	movq   $0x0,0xf8(%rsp)
    20ca:	movq   $0x0,0x100(%rsp)
    20d6:	movq   $0x0,0x108(%rsp)
    20e2:	movq   $0x0,0x110(%rsp)
    20ee:	mov    0x1b8(%rsp),%rdi
    20f6:	call   20fb <botlish_fn_24+0x1bb>
			20f7: R_X86_64_PLT32	botlish_fn_23-0x4
    20fb:	test   %rax,%rax
    20fe:	je     583a <botlish_fn_24+0x38fa>
    2104:	mov    %rax,(%rsp)
    2108:	mov    %rax,%r12
    210b:	mov    $0x7,%esi
    2110:	movq   $0x7,0x8(%rsp)
    2119:	mov    $0x1,%edx
    211e:	movq   $0x1,0x10(%rsp)
    2127:	mov    0x1b8(%rsp),%rdi
    212f:	call   2134 <botlish_fn_24+0x1f4>
			2130: R_X86_64_PLT32	rt_mutarray_create-0x4
    2134:	test   %rax,%rax
    2137:	je     583a <botlish_fn_24+0x38fa>
    213d:	mov    %rax,0x8(%rsp)
    2142:	mov    %rax,0x2f8(%rsp)
    214a:	movq   $0xa,0x38(%rsp)
    2153:	movq   $0xa,0x40(%rsp)
    215c:	movq   $0xa,0x48(%rsp)
    2165:	movq   $0xa,0x50(%rsp)
    216e:	movq   $0xa,0x58(%rsp)
    2177:	movq   $0xa,0x60(%rsp)
    2180:	movq   $0xa,0x68(%rsp)
    2189:	movq   $0xa,0x70(%rsp)
    2192:	movq   $0xa,0x78(%rsp)
    219b:	movq   $0xa,0x80(%rsp)
    21a7:	movq   $0xa,0x88(%rsp)
    21b3:	movq   $0xa,0x90(%rsp)
    21bf:	movq   $0xa,0x98(%rsp)
    21cb:	movq   $0xa,0xa0(%rsp)
    21d7:	movq   $0xa,0xa8(%rsp)
    21e3:	movq   $0xa,0xb0(%rsp)
    21ef:	movq   $0xa,0xb8(%rsp)
    21fb:	movq   $0xa,0xc0(%rsp)
    2207:	movq   $0xa,0xc8(%rsp)
    2213:	movq   $0xa,0xd0(%rsp)
    221f:	movq   $0xa,0xd8(%rsp)
    222b:	movq   $0xa,0xe0(%rsp)
    2237:	movq   $0xa,0xe8(%rsp)
    2243:	movq   $0xa,0xf0(%rsp)
    224f:	movq   $0xa,0xf8(%rsp)
    225b:	movq   $0xa,0x100(%rsp)
    2267:	movq   $0xa,0x108(%rsp)
    2273:	movq   $0xa,0x110(%rsp)
    227f:	movq   $0xa,0x28(%rsp)
    2288:	movq   $0xa,0x30(%rsp)
    2291:	mov    %r12,%rax
    2294:	mov    %rax,0x10(%rsp)
    2299:	mov    $0x1,%ebx
    229e:	movq   $0x1,0x18(%rsp)
    22a7:	lea    0x128(%rsp),%rcx
    22af:	mov    %rax,0x128(%rsp)
    22b7:	mov    %rax,%r12
    22ba:	movq   $0x1,0x130(%rsp)
    22c6:	mov    $0x2,%edx
    22cb:	mov    %rbx,%rsi
    22ce:	mov    0x1b8(%rsp),%rdi
    22d6:	call   22db <botlish_fn_24+0x39b>
			22d7: R_X86_64_PLT32	rt_struct_new-0x4
    22db:	mov    %rax,0x18(%rsp)
    22e0:	lea    0x138(%rsp),%rdx
    22e8:	mov    %rax,0x138(%rsp)
    22f0:	mov    %rbx,%rsi
    22f3:	mov    0x1b8(%rsp),%rdi
    22fb:	call   2300 <botlish_fn_24+0x3c0>
			22fc: R_X86_64_PLT32	rt_list_new-0x4
    2300:	test   %rax,%rax
    2303:	je     2739 <botlish_fn_24+0x7f9>
    2309:	mov    %rax,0x18(%rsp)
    230e:	mov    %rax,%rsi
    2311:	mov    0x1b8(%rsp),%rdi
    2319:	call   231e <botlish_fn_24+0x3de>
			231a: R_X86_64_PLT32	rt_mv_from_list-0x4
    231e:	mov    %rax,0x38(%rsp)
    2323:	mov    %rax,0x2f0(%rsp)
    232b:	mov    0x2f0(%rsp),%rsi
    2333:	mov    0x1b8(%rsp),%rdi
    233b:	call   2340 <botlish_fn_24+0x400>
			233c: R_X86_64_PLT32	rt_mv_pop-0x4
    2340:	test   %rax,%rax
    2343:	je     2739 <botlish_fn_24+0x7f9>
    2349:	mov    $0x3,%esi
    234e:	movq   $0x3,0x18(%rsp)
    2357:	mov    %r12,%rdx
    235a:	mov    0x1b8(%rsp),%rdi
    2362:	call   2367 <botlish_fn_24+0x427>
			2363: R_X86_64_PLT32	rt_mutarray_create-0x4
    2367:	test   %rax,%rax
    236a:	je     2739 <botlish_fn_24+0x7f9>
    2370:	mov    %rax,0x40(%rsp)
    2375:	mov    0x10(%rax),%rcx
    2379:	mov    %rax,0x2e8(%rsp)
    2381:	mov    (%rcx),%rcx
    2384:	mov    %rcx,0x48(%rsp)
    2389:	mov    0x18(%rcx),%rax
    238d:	mov    %rcx,0x268(%rsp)
    2395:	mov    (%rax),%rcx
    2398:	cmp    $0xb2,%rcx
    239f:	je     29c5 <botlish_fn_24+0xa85>
    23a5:	cmp    $0xd2,%rcx
    23ac:	je     29c5 <botlish_fn_24+0xa85>
    23b2:	cmp    $0x12,%rcx
    23b6:	je     296e <botlish_fn_24+0xa2e>
    23bc:	cmp    $0x52,%rcx
    23c0:	je     2917 <botlish_fn_24+0x9d7>
    23c6:	cmp    $0x32,%rcx
    23ca:	je     28c0 <botlish_fn_24+0x980>
    23d0:	cmp    $0x72,%rcx
    23d4:	je     2435 <botlish_fn_24+0x4f5>
    23da:	mov    0x10(%rax),%rcx
    23de:	mov    %rcx,0xf8(%rsp)
    23e6:	mov    $0x45,%r15d
    23ec:	movq   $0x45,0x28(%rsp)
    23f5:	mov    $0x2b,%r14d
    23fb:	mov    $0xa,%ebx
    2400:	mov    %rbx,0x1f0(%rsp)
    2408:	mov    %rbx,0x218(%rsp)
    2410:	mov    %rbx,0x220(%rsp)
    2418:	mov    %rcx,0x238(%rsp)
    2420:	mov    %rbx,0x298(%rsp)
    2428:	mov    %rbx,0x2a0(%rsp)
    2430:	jmp    2a7b <botlish_fn_24+0xb3b>
    2435:	mov    0x8(%rax),%rbx
    2439:	mov    %rbx,0x70(%rsp)
    243e:	test   $0x1,%rbx
    2445:	jne    247d <botlish_fn_24+0x53d>
    244b:	mov    $0x1,%edx
    2450:	mov    %rbx,%rsi
    2453:	mov    0x1b8(%rsp),%rdi
    245b:	call   2460 <botlish_fn_24+0x520>
			245c: R_X86_64_PLT32	rt_int_cmp-0x4
    2460:	mov    %rbx,0x1f0(%rsp)
    2468:	mov    $0x2,%ecx
    246d:	test   %rax,%rax
    2470:	cmove  0x3538(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    2478:	jmp    2496 <botlish_fn_24+0x556>
    247d:	mov    %rbx,0x1f0(%rsp)
    2485:	mov    $0x2,%ecx
    248a:	cmp    $0x1,%rbx
    248e:	cmove  0x351a(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    2496:	cmp    $0x6,%rcx
    249a:	je     2871 <botlish_fn_24+0x931>
    24a0:	test   $0x1,%rbx
    24a7:	jne    24df <botlish_fn_24+0x59f>
    24ad:	mov    $0x1,%edx
    24b2:	mov    %rbx,%rsi
    24b5:	mov    0x1b8(%rsp),%rdi
    24bd:	call   24c2 <botlish_fn_24+0x582>
			24be: R_X86_64_PLT32	rt_int_cmp-0x4
    24c2:	mov    %rbx,0x1f0(%rsp)
    24ca:	mov    $0x2,%edx
    24cf:	test   %rax,%rax
    24d2:	cmovl  0x34d6(%rip),%rdx        # 59b0 <botlish_fn_24+0x3a70>
    24da:	jmp    2507 <botlish_fn_24+0x5c7>
    24df:	mov    %rbx,0x1f0(%rsp)
    24e7:	mov    $0x2,%edx
    24ec:	mov    0x1f0(%rsp),%rax
    24f4:	mov    0x1f0(%rsp),%rcx
    24fc:	test   %rax,%rcx
    24ff:	cmovle 0x34a9(%rip),%rdx        # 59b0 <botlish_fn_24+0x3a70>
    2507:	cmp    $0x6,%rdx
    250b:	je     282a <botlish_fn_24+0x8ea>
    2511:	mov    0x1f0(%rsp),%rcx
    2519:	mov    %rcx,0xb8(%rsp)
    2521:	movq   $0x3,0x10(%rsp)
    252a:	lea    0x158(%rsp),%rdx
    2532:	movq   $0x3,0x158(%rsp)
    253e:	mov    $0x1,%esi
    2543:	mov    0x1b8(%rsp),%rdi
    254b:	call   2550 <botlish_fn_24+0x610>
			254c: R_X86_64_PLT32	rt_list_new-0x4
    2550:	test   %rax,%rax
    2553:	je     2739 <botlish_fn_24+0x7f9>
    2559:	mov    %rax,0x10(%rsp)
    255e:	mov    %rax,%rsi
    2561:	mov    0x1b8(%rsp),%rdi
    2569:	call   256e <botlish_fn_24+0x62e>
			256a: R_X86_64_PLT32	rt_mv_from_list-0x4
    256e:	mov    %rax,0xc0(%rsp)
    2576:	mov    %rax,0x2a0(%rsp)
    257e:	mov    0x2a0(%rsp),%rsi
    2586:	mov    0x1b8(%rsp),%rdi
    258e:	call   2593 <botlish_fn_24+0x653>
			258f: R_X86_64_PLT32	rt_mv_len-0x4
    2593:	sar    $1,%rax
    2596:	sub    $0x1,%rax
    259a:	shl    $1,%rax
    259d:	mov    %rax,%rdx
    25a0:	or     $0x1,%rdx
    25a4:	mov    0x2a0(%rsp),%rsi
    25ac:	mov    0x1b8(%rsp),%rdi
    25b4:	call   25b9 <botlish_fn_24+0x679>
			25b5: R_X86_64_PLT32	rt_mv_at-0x4
    25b9:	mov    %rax,%rcx
    25bc:	mov    %rax,%rsi
    25bf:	test   %rcx,%rax
    25c2:	je     2739 <botlish_fn_24+0x7f9>
    25c8:	mov    %rsi,%rax
    25cb:	mov    %rax,0x10(%rsp)
    25d0:	movq   $0x15,0x18(%rsp)
    25d9:	test   $0x1,%rax
    25df:	je     2614 <botlish_fn_24+0x6d4>
    25e5:	mov    %rsi,%rax
    25e8:	sar    $1,%rax
    25eb:	imulq  0x33c6(%rip)        # 59b8 <botlish_fn_24+0x3a78>
    25f2:	seto   %cl
    25f5:	or     $0x1,%rax
    25f9:	test   %cl,%cl
    25fb:	jne    2614 <botlish_fn_24+0x6d4>
    2601:	mov    %rsi,%r12
    2604:	mov    %rax,%rsi
    2607:	mov    0x1f0(%rsp),%rcx
    260f:	jmp    2634 <botlish_fn_24+0x6f4>
    2614:	mov    $0x15,%edx
    2619:	mov    %rsi,%r12
    261c:	mov    0x1b8(%rsp),%rdi
    2624:	call   2629 <botlish_fn_24+0x6e9>
			2625: R_X86_64_PLT32	rt_int_mul-0x4
    2629:	mov    0x1f0(%rsp),%rcx
    2631:	mov    %rax,%rsi
    2634:	mov    0x1f0(%rsp),%rcx
    263c:	mov    %rsi,%rax
    263f:	and    %rcx,%rax
    2642:	test   $0x1,%rax
    2648:	jne    2678 <botlish_fn_24+0x738>
    264e:	mov    0x1f0(%rsp),%rdx
    2656:	mov    0x1b8(%rsp),%rdi
    265e:	call   2663 <botlish_fn_24+0x723>
			265f: R_X86_64_PLT32	rt_int_cmp-0x4
    2663:	mov    $0x2,%ecx
    2668:	test   %rax,%rax
    266b:	cmovg  0x333d(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    2673:	jmp    2690 <botlish_fn_24+0x750>
    2678:	mov    $0x2,%ecx
    267d:	mov    0x1f0(%rsp),%rax
    2685:	cmp    %rax,%rsi
    2688:	cmovg  0x3320(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    2690:	cmp    $0x6,%rcx
    2694:	je     2710 <botlish_fn_24+0x7d0>
    269a:	movq   $0x15,0x18(%rsp)
    26a3:	test   $0x1,%r12
    26aa:	jne    26b8 <botlish_fn_24+0x778>
    26b0:	mov    %r12,%rsi
    26b3:	jmp    26e1 <botlish_fn_24+0x7a1>
    26b8:	mov    %r12,%rax
    26bb:	sar    $1,%rax
    26be:	mov    %r12,%rsi
    26c1:	imulq  0x32f0(%rip)        # 59b8 <botlish_fn_24+0x3a78>
    26c8:	seto   %r8b
    26cc:	or     $0x1,%rax
    26d0:	test   %r8b,%r8b
    26d3:	jne    26e1 <botlish_fn_24+0x7a1>
    26d9:	mov    %rax,%rdx
    26dc:	jmp    26f6 <botlish_fn_24+0x7b6>
    26e1:	mov    $0x15,%edx
    26e6:	mov    0x1b8(%rsp),%rdi
    26ee:	call   26f3 <botlish_fn_24+0x7b3>
			26ef: R_X86_64_PLT32	rt_int_mul-0x4
    26f3:	mov    %rax,%rdx
    26f6:	mov    0x2a0(%rsp),%rsi
    26fe:	mov    0x1b8(%rsp),%rdi
    2706:	call   270b <botlish_fn_24+0x7cb>
			2707: R_X86_64_PLT32	rt_mv_push-0x4
    270b:	jmp    257e <botlish_fn_24+0x63e>
    2710:	mov    0x2a0(%rsp),%rsi
    2718:	mov    0x1b8(%rsp),%rdi
    2720:	call   2725 <botlish_fn_24+0x7e5>
			2721: R_X86_64_PLT32	rt_mv_pop-0x4
    2725:	mov    %rax,%rsi
    2728:	mov    %rax,0x220(%rsp)
    2730:	test   %rsi,%rax
    2733:	jne    27b2 <botlish_fn_24+0x872>
    2739:	mov    0x1b8(%rsp),%rdi
    2741:	call   2746 <botlish_fn_24+0x806>
			2742: R_X86_64_PLT32	rt_co_failed-0x4
    2746:	mov    %rax,0x30(%rsp)
    274b:	mov    %rax,%rsi
    274e:	mov    0x1b8(%rsp),%rdi
    2756:	call   275b <botlish_fn_24+0x81b>
			2757: R_X86_64_PLT32	rt_co_resume0-0x4
    275b:	test   %rax,%rax
    275e:	jne    2771 <botlish_fn_24+0x831>
    2764:	mov    0x1b8(%rsp),%rdi
    276c:	jmp    2794 <botlish_fn_24+0x854>
    2771:	mov    0x1b8(%rsp),%rdi
    2779:	mov    0x10(%rdi),%rax
    277d:	mov    (%rax),%rsi
    2780:	mov    0xf0(%rax),%rdx
    2787:	call   278c <botlish_fn_24+0x84c>
			2788: R_X86_64_PLT32	rt_raise-0x4
    278c:	mov    0x1b8(%rsp),%rdi
    2794:	mov    0x1b8(%rsp),%rdi
    279c:	call   27a1 <botlish_fn_24+0x861>
			279d: R_X86_64_PLT32	rt_declared_error-0x4
    27a1:	cmp    $0x40000001,%rax
    27a7:	jne    583a <botlish_fn_24+0x38fa>
    27ad:	jmp    583a <botlish_fn_24+0x38fa>
    27b2:	mov    0x220(%rsp),%rax
    27ba:	mov    %rax,0xc8(%rsp)
    27c2:	mov    0x220(%rsp),%rdx
    27ca:	mov    0x1f0(%rsp),%rsi
    27d2:	mov    0x1b8(%rsp),%rdi
    27da:	call   27df <botlish_fn_24+0x89f>
			27db: R_X86_64_PLT32	botlish_fn_2-0x4
    27df:	mov    %rax,0x218(%rsp)
    27e7:	mov    %rax,0xd0(%rsp)
    27ef:	sar    $1,%rax
    27f2:	lea    0x30(%rax),%r15
    27f6:	shl    $1,%r15
    27f9:	or     $0x1,%r15
    27fd:	mov    %r15,0x28(%rsp)
    2802:	mov    $0x29,%r14d
    2808:	mov    $0xa,%ecx
    280d:	mov    %rcx,0x238(%rsp)
    2815:	mov    0x1f0(%rsp),%rax
    281d:	mov    %rax,0x298(%rsp)
    2825:	jmp    2a7b <botlish_fn_24+0xb3b>
    282a:	mov    $0x5b,%r15d
    2830:	movq   $0x5b,0x28(%rsp)
    2839:	mov    $0x26,%r14d
    283f:	mov    $0xa,%eax
    2844:	mov    %rax,0x218(%rsp)
    284c:	mov    %rax,0x220(%rsp)
    2854:	mov    %rax,0x238(%rsp)
    285c:	mov    %rax,0x298(%rsp)
    2864:	mov    %rax,0x2a0(%rsp)
    286c:	jmp    2a7b <botlish_fn_24+0xb3b>
    2871:	mov    %rbx,0x1f0(%rsp)
    2879:	mov    $0x61,%r15d
    287f:	movq   $0x61,0x28(%rsp)
    2888:	mov    $0x25,%r14d
    288e:	mov    $0xa,%eax
    2893:	mov    %rax,0x218(%rsp)
    289b:	mov    %rax,0x220(%rsp)
    28a3:	mov    %rax,0x238(%rsp)
    28ab:	mov    %rax,0x298(%rsp)
    28b3:	mov    %rax,0x2a0(%rsp)
    28bb:	jmp    2a7b <botlish_fn_24+0xb3b>
    28c0:	mov    $0xcd,%r15d
    28c6:	movq   $0xcd,0x28(%rsp)
    28cf:	mov    $0x20,%r14d
    28d5:	mov    $0xa,%ecx
    28da:	mov    %rcx,0x1f0(%rsp)
    28e2:	mov    0x1f0(%rsp),%rax
    28ea:	mov    %rax,0x218(%rsp)
    28f2:	mov    %rax,0x220(%rsp)
    28fa:	mov    %rax,0x238(%rsp)
    2902:	mov    %rax,0x298(%rsp)
    290a:	mov    %rax,0x2a0(%rsp)
    2912:	jmp    2a7b <botlish_fn_24+0xb3b>
    2917:	mov    $0xe9,%r15d
    291d:	movq   $0xe9,0x28(%rsp)
    2926:	mov    $0x1c,%r14d
    292c:	mov    $0xa,%ecx
    2931:	mov    %rcx,0x1f0(%rsp)
    2939:	mov    0x1f0(%rsp),%rax
    2941:	mov    %rax,0x218(%rsp)
    2949:	mov    %rax,0x220(%rsp)
    2951:	mov    %rax,0x238(%rsp)
    2959:	mov    %rax,0x298(%rsp)
    2961:	mov    %rax,0x2a0(%rsp)
    2969:	jmp    2a7b <botlish_fn_24+0xb3b>
    296e:	mov    $0xdd,%r15d
    2974:	movq   $0xdd,0x28(%rsp)
    297d:	mov    $0x18,%r14d
    2983:	mov    $0xa,%ecx
    2988:	mov    %rcx,0x1f0(%rsp)
    2990:	mov    0x1f0(%rsp),%rax
    2998:	mov    %rax,0x218(%rsp)
    29a0:	mov    %rax,0x220(%rsp)
    29a8:	mov    %rax,0x238(%rsp)
    29b0:	mov    %rax,0x298(%rsp)
    29b8:	mov    %rax,0x2a0(%rsp)
    29c0:	jmp    2a7b <botlish_fn_24+0xb3b>
    29c5:	cmp    $0xb2,%rcx
    29cc:	je     2a29 <botlish_fn_24+0xae9>
    29d2:	mov    $0xf7,%r15d
    29d8:	movq   $0xf7,0x28(%rsp)
    29e1:	mov    $0x2,%r14d
    29e7:	mov    $0xa,%ecx
    29ec:	mov    %rcx,0x1f0(%rsp)
    29f4:	mov    0x1f0(%rsp),%rax
    29fc:	mov    %rax,0x218(%rsp)
    2a04:	mov    %rax,0x220(%rsp)
    2a0c:	mov    %rax,0x238(%rsp)
    2a14:	mov    %rax,0x298(%rsp)
    2a1c:	mov    %rax,0x2a0(%rsp)
    2a24:	jmp    2a7b <botlish_fn_24+0xb3b>
    2a29:	mov    $0xb7,%r15d
    2a2f:	movq   $0xb7,0x28(%rsp)
    2a38:	mov    $0x1,%r14d
    2a3e:	mov    $0xa,%ecx
    2a43:	mov    %rcx,0x1f0(%rsp)
    2a4b:	mov    0x1f0(%rsp),%rax
    2a53:	mov    %rax,0x218(%rsp)
    2a5b:	mov    %rax,0x220(%rsp)
    2a63:	mov    %rax,0x238(%rsp)
    2a6b:	mov    %rax,0x298(%rsp)
    2a73:	mov    %rax,0x2a0(%rsp)
    2a7b:	mov    0x2f8(%rsp),%rcx
    2a83:	mov    0x18(%rcx),%rax
    2a87:	test   %rax,%rax
    2a8a:	je     58a5 <botlish_fn_24+0x3965>
    2a90:	mov    0x2f8(%rsp),%rcx
    2a98:	mov    0x10(%rcx),%rax
    2a9c:	mov    %r15,0x10(%rax)
    2aa0:	mov    $0xa,%eax
    2aa5:	mov    %rax,0x1d8(%rsp)
    2aad:	xor    %rax,%rax
    2ab0:	mov    %rax,0x1e8(%rsp)
    2ab8:	mov    $0x10,%eax
    2abd:	mov    %rax,0x2e0(%rsp)
    2ac5:	mov    $0x7fffffff,%eax
    2aca:	mov    %rax,%r13
    2acd:	neg    %r13
    2ad0:	cmovs  %rax,%r13
    2ad4:	mov    %r13,0x2d8(%rsp)
    2adc:	mov    0x1e8(%rsp),%r13
    2ae4:	mov    0x1e8(%rsp),%rax
    2aec:	mov    %rax,0x1c0(%rsp)
    2af4:	mov    %rax,0x1c8(%rsp)
    2afc:	mov    0x1d8(%rsp),%rax
    2b04:	mov    %rax,0x1d0(%rsp)
    2b0c:	mov    %rax,0x1e0(%rsp)
    2b14:	mov    %rax,0x1f8(%rsp)
    2b1c:	mov    %rax,0x200(%rsp)
    2b24:	mov    %rax,0x208(%rsp)
    2b2c:	mov    %rax,0x210(%rsp)
    2b34:	mov    %rax,0x228(%rsp)
    2b3c:	mov    %rax,0x230(%rsp)
    2b44:	mov    %rax,0x240(%rsp)
    2b4c:	mov    0x1e8(%rsp),%rax
    2b54:	mov    %rax,0x248(%rsp)
    2b5c:	mov    0x1d8(%rsp),%rax
    2b64:	mov    %rax,0x250(%rsp)
    2b6c:	mov    %rax,0x258(%rsp)
    2b74:	mov    0x1e8(%rsp),%rax
    2b7c:	mov    %rax,0x260(%rsp)
    2b84:	mov    %rax,0x270(%rsp)
    2b8c:	mov    0x1d8(%rsp),%rax
    2b94:	mov    %rax,0x278(%rsp)
    2b9c:	mov    %rax,0x280(%rsp)
    2ba4:	mov    %rax,0x288(%rsp)
    2bac:	mov    %rax,0x290(%rsp)
    2bb4:	mov    %rax,0x2a8(%rsp)
    2bbc:	mov    %rax,0x2b0(%rsp)
    2bc4:	mov    0x1e8(%rsp),%rax
    2bcc:	mov    %rax,0x2b8(%rsp)
    2bd4:	mov    %rax,0x2c0(%rsp)
    2bdc:	mov    0x1d8(%rsp),%rax
    2be4:	mov    %rax,0x2c8(%rsp)
    2bec:	test   %r14,%r14
    2bef:	jl     57e7 <botlish_fn_24+0x38a7>
    2bf5:	movq   $0x1,(%rsp)
    2bfd:	mov    0x2f8(%rsp),%rcx
    2c05:	mov    0x10(%rcx),%rax
    2c09:	mov    (%rax),%rsi
    2c0c:	mov    %rsi,0x10(%rsp)
    2c11:	mov    0x2f8(%rsp),%rcx
    2c19:	mov    0x10(%rcx),%rax
    2c1d:	mov    0x10(%rax),%rdx
    2c21:	mov    %rdx,0x18(%rsp)
    2c26:	mov    %rdx,%rbx
    2c29:	movq   $0x3f,0x20(%rsp)
    2c32:	test   $0x1,%rsi
    2c39:	je     2c65 <botlish_fn_24+0xd25>
    2c3f:	mov    %rsi,%rax
    2c42:	sar    $1,%rax
    2c45:	imulq  0x2d74(%rip)        # 59c0 <botlish_fn_24+0x3a80>
    2c4c:	seto   %dil
    2c50:	or     $0x1,%rax
    2c54:	test   %dil,%dil
    2c57:	jne    2c65 <botlish_fn_24+0xd25>
    2c5d:	mov    %rax,%rsi
    2c60:	jmp    2c7a <botlish_fn_24+0xd3a>
    2c65:	mov    $0x3f,%edx
    2c6a:	mov    0x1b8(%rsp),%rdi
    2c72:	call   2c77 <botlish_fn_24+0xd37>
			2c73: R_X86_64_PLT32	rt_int_mul-0x4
    2c77:	mov    %rax,%rsi
    2c7a:	mov    %rsi,0x10(%rsp)
    2c7f:	mov    %rbx,%rdx
    2c82:	mov    %rsi,%r11
    2c85:	and    %rdx,%r11
    2c88:	test   $0x1,%r11
    2c8f:	je     2caa <botlish_fn_24+0xd6a>
    2c95:	lea    -0x1(%rdx),%rcx
    2c99:	mov    %rsi,%rax
    2c9c:	add    %rcx,%rax
    2c9f:	seto   %cl
    2ca2:	test   %cl,%cl
    2ca4:	je     2cb7 <botlish_fn_24+0xd77>
    2caa:	mov    0x1b8(%rsp),%rdi
    2cb2:	call   2cb7 <botlish_fn_24+0xd77>
			2cb3: R_X86_64_PLT32	rt_int_add-0x4
    2cb7:	mov    %rax,0x10(%rsp)
    2cbc:	movq   $0x3,0x18(%rsp)
    2cc5:	test   $0x1,%rax
    2ccb:	jne    2cd9 <botlish_fn_24+0xd99>
    2cd1:	mov    %rax,%rcx
    2cd4:	jmp    2cee <botlish_fn_24+0xdae>
    2cd9:	mov    %rax,%rsi
    2cdc:	add    $0x2,%rsi
    2ce0:	mov    %rax,%rcx
    2ce3:	seto   %al
    2ce6:	test   %al,%al
    2ce8:	je     2d06 <botlish_fn_24+0xdc6>
    2cee:	mov    $0x3,%edx
    2cf3:	mov    %rcx,%rsi
    2cf6:	mov    0x1b8(%rsp),%rdi
    2cfe:	call   2d03 <botlish_fn_24+0xdc3>
			2cff: R_X86_64_PLT32	rt_int_add-0x4
    2d03:	mov    %rax,%rsi
    2d06:	mov    %rsi,0x10(%rsp)
    2d0b:	mov    $0xffffffff,%eax
    2d10:	mov    %rax,0x18(%rsp)
    2d15:	test   $0x1,%rsi
    2d1c:	jne    2d6b <botlish_fn_24+0xe2b>
    2d22:	mov    $0xffffffff,%edx
    2d27:	mov    0x1b8(%rsp),%rdi
    2d2f:	call   2d34 <botlish_fn_24+0xdf4>
			2d30: R_X86_64_PLT32	rt_int_mod-0x4
    2d34:	test   %rax,%rax
    2d37:	jne    2d5b <botlish_fn_24+0xe1b>
    2d3d:	mov    0x1b8(%rsp),%rdi
    2d45:	call   2d4a <botlish_fn_24+0xe0a>
			2d46: R_X86_64_PLT32	rt_declared_error-0x4
    2d4a:	cmp    $0x40000001,%rax
    2d50:	jne    583a <botlish_fn_24+0x38fa>
    2d56:	jmp    583a <botlish_fn_24+0x38fa>
    2d5b:	mov    %rax,%rcx
    2d5e:	mov    0x2f8(%rsp),%rax
    2d66:	jmp    2db9 <botlish_fn_24+0xe79>
    2d6b:	sar    $1,%rsi
    2d6e:	mov    %rsi,%rax
    2d71:	imulq  0x2c50(%rip)        # 59c8 <botlish_fn_24+0x3a88>
    2d78:	lea    (%rdx,%rsi,1),%rax
    2d7c:	sar    $0x1e,%rax
    2d80:	mov    %rax,%rcx
    2d83:	shr    $0x3f,%rcx
    2d87:	add    %rcx,%rax
    2d8a:	imul   $0x7fffffff,%rax,%rax
    2d91:	sub    %rax,%rsi
    2d94:	mov    0x2d8(%rsp),%rcx
    2d9c:	lea    (%rsi,%rcx,1),%rax
    2da0:	test   %rsi,%rsi
    2da3:	cmovl  %rax,%rsi
    2da7:	shl    $1,%rsi
    2daa:	or     $0x1,%rsi
    2dae:	mov    0x2f8(%rsp),%rax
    2db6:	mov    %rsi,%rcx
    2db9:	mov    0x2f8(%rsp),%rax
    2dc1:	mov    0x18(%rax),%rax
    2dc5:	test   %rax,%rax
    2dc8:	je     58c7 <botlish_fn_24+0x3987>
    2dce:	mov    0x2f8(%rsp),%rax
    2dd6:	mov    0x10(%rax),%rax
    2dda:	mov    %rcx,(%rax)
    2ddd:	movq   $0x3,(%rsp)
    2de5:	mov    0x2f8(%rsp),%rcx
    2ded:	mov    0x10(%rcx),%rax
    2df1:	mov    0x8(%rax),%rsi
    2df5:	mov    %rsi,0x10(%rsp)
    2dfa:	movq   $0x3,0x18(%rsp)
    2e03:	test   $0x1,%rsi
    2e0a:	je     2e2f <botlish_fn_24+0xeef>
    2e10:	mov    %rsi,%rcx
    2e13:	add    $0x2,%rcx
    2e17:	seto   %al
    2e1a:	test   %al,%al
    2e1c:	jne    2e2f <botlish_fn_24+0xeef>
    2e22:	mov    0x2f8(%rsp),%rax
    2e2a:	jmp    2e4c <botlish_fn_24+0xf0c>
    2e2f:	mov    $0x3,%edx
    2e34:	mov    0x1b8(%rsp),%rdi
    2e3c:	call   2e41 <botlish_fn_24+0xf01>
			2e3d: R_X86_64_PLT32	rt_int_add-0x4
    2e41:	mov    %rax,%rcx
    2e44:	mov    0x2f8(%rsp),%rax
    2e4c:	mov    0x2f8(%rsp),%rax
    2e54:	mov    0x18(%rax),%rax
    2e58:	test   %rax,%rax
    2e5b:	je     58e6 <botlish_fn_24+0x39a6>
    2e61:	mov    0x2f8(%rsp),%rax
    2e69:	mov    0x10(%rax),%rax
    2e6d:	mov    %rcx,0x8(%rax)
    2e71:	mov    $0x5,%edx
    2e76:	mov    %rdx,0x2d0(%rsp)
    2e7e:	movq   $0x5,(%rsp)
    2e86:	cmp    $0x1,%r14
    2e8a:	je     5080 <botlish_fn_24+0x3140>
    2e90:	cmp    $0x2,%r14
    2e94:	je     506b <botlish_fn_24+0x312b>
    2e9a:	cmp    $0x3,%r14
    2e9e:	je     4ef0 <botlish_fn_24+0x2fb0>
    2ea4:	cmp    $0x4,%r14
    2ea8:	je     4ec3 <botlish_fn_24+0x2f83>
    2eae:	cmp    $0x5,%r14
    2eb2:	je     4ea7 <botlish_fn_24+0x2f67>
    2eb8:	cmp    $0x6,%r14
    2ebc:	je     4d51 <botlish_fn_24+0x2e11>
    2ec2:	cmp    $0x7,%r14
    2ec6:	je     4d47 <botlish_fn_24+0x2e07>
    2ecc:	cmp    $0x8,%r14
    2ed0:	je     4d42 <botlish_fn_24+0x2e02>
    2ed6:	cmp    $0x9,%r14
    2eda:	je     4d38 <botlish_fn_24+0x2df8>
    2ee0:	cmp    $0xa,%r14
    2ee4:	je     4d2e <botlish_fn_24+0x2dee>
    2eea:	cmp    $0xb,%r14
    2eee:	je     4d24 <botlish_fn_24+0x2de4>
    2ef4:	cmp    $0xc,%r14
    2ef8:	je     4cfa <botlish_fn_24+0x2dba>
    2efe:	cmp    $0xd,%r14
    2f02:	je     4cd0 <botlish_fn_24+0x2d90>
    2f08:	cmp    $0xe,%r14
    2f0c:	je     4c5f <botlish_fn_24+0x2d1f>
    2f12:	cmp    $0xf,%r14
    2f16:	je     4bf0 <botlish_fn_24+0x2cb0>
    2f1c:	cmp    $0x10,%r14
    2f20:	je     4bf0 <botlish_fn_24+0x2cb0>
    2f26:	cmp    $0x11,%r14
    2f2a:	je     4be6 <botlish_fn_24+0x2ca6>
    2f30:	cmp    $0x12,%r14
    2f34:	je     4be6 <botlish_fn_24+0x2ca6>
    2f3a:	cmp    $0x13,%r14
    2f3e:	je     4bdc <botlish_fn_24+0x2c9c>
    2f44:	cmp    $0x14,%r14
    2f48:	je     4bb2 <botlish_fn_24+0x2c72>
    2f4e:	mov    $0x15,%ebx
    2f53:	cmp    $0x15,%r14
    2f57:	je     4b9d <botlish_fn_24+0x2c5d>
    2f5d:	cmp    $0x16,%r14
    2f61:	je     49fe <botlish_fn_24+0x2abe>
    2f67:	cmp    $0x17,%r14
    2f6b:	je     49fe <botlish_fn_24+0x2abe>
    2f71:	cmp    $0x18,%r14
    2f75:	je     49d4 <botlish_fn_24+0x2a94>
    2f7b:	cmp    $0x19,%r14
    2f7f:	je     49aa <botlish_fn_24+0x2a6a>
    2f85:	cmp    $0x1a,%r14
    2f89:	je     4980 <botlish_fn_24+0x2a40>
    2f8f:	cmp    $0x1b,%r14
    2f93:	je     49fe <botlish_fn_24+0x2abe>
    2f99:	cmp    $0x1c,%r14
    2f9d:	je     4956 <botlish_fn_24+0x2a16>
    2fa3:	cmp    $0x1d,%r14
    2fa7:	je     492c <botlish_fn_24+0x29ec>
    2fad:	cmp    $0x1e,%r14
    2fb1:	je     4902 <botlish_fn_24+0x29c2>
    2fb7:	cmp    $0x1f,%r14
    2fbb:	je     48f8 <botlish_fn_24+0x29b8>
    2fc1:	cmp    $0x20,%r14
    2fc5:	je     48ce <botlish_fn_24+0x298e>
    2fcb:	cmp    $0x21,%r14
    2fcf:	je     48a4 <botlish_fn_24+0x2964>
    2fd5:	cmp    $0x22,%r14
    2fd9:	je     487a <botlish_fn_24+0x293a>
    2fdf:	cmp    $0x23,%r14
    2fe3:	je     4850 <botlish_fn_24+0x2910>
    2fe9:	cmp    $0x24,%r14
    2fed:	je     4846 <botlish_fn_24+0x2906>
    2ff3:	cmp    $0x25,%r14
    2ff7:	je     483c <botlish_fn_24+0x28fc>
    2ffd:	cmp    $0x26,%r14
    3001:	je     4532 <botlish_fn_24+0x25f2>
    3007:	cmp    $0x27,%r14
    300b:	je     4339 <botlish_fn_24+0x23f9>
    3011:	cmp    $0x28,%r14
    3015:	je     421f <botlish_fn_24+0x22df>
    301b:	cmp    $0x29,%r14
    301f:	je     4021 <botlish_fn_24+0x20e1>
    3025:	cmp    $0x2a,%r14
    3029:	je     3f07 <botlish_fn_24+0x1fc7>
    302f:	cmp    $0x2b,%r14
    3033:	je     3d3e <botlish_fn_24+0x1dfe>
    3039:	cmp    $0x2c,%r14
    303d:	je     3d0b <botlish_fn_24+0x1dcb>
    3043:	cmp    $0x2d,%r14
    3047:	je     3cdf <botlish_fn_24+0x1d9f>
    304d:	cmp    $0x2e,%r14
    3051:	je     3b81 <botlish_fn_24+0x1c41>
    3057:	cmp    $0x2f,%r14
    305b:	je     3b67 <botlish_fn_24+0x1c27>
    3061:	cmp    $0x30,%r14
    3065:	je     3b54 <botlish_fn_24+0x1c14>
    306b:	cmp    $0x31,%r14
    306f:	je     3b41 <botlish_fn_24+0x1c01>
    3075:	cmp    $0x32,%r14
    3079:	je     3b2e <botlish_fn_24+0x1bee>
    307f:	cmp    $0x33,%r14
    3083:	je     3b1b <botlish_fn_24+0x1bdb>
    3089:	cmp    $0x34,%r14
    308d:	je     3ae9 <botlish_fn_24+0x1ba9>
    3093:	cmp    $0x35,%r14
    3097:	je     3ab7 <botlish_fn_24+0x1b77>
    309d:	cmp    $0x36,%r14
    30a1:	je     3a38 <botlish_fn_24+0x1af8>
    30a7:	cmp    $0x37,%r14
    30ab:	je     39b9 <botlish_fn_24+0x1a79>
    30b1:	cmp    $0x38,%r14
    30b5:	je     39b9 <botlish_fn_24+0x1a79>
    30bb:	cmp    $0x39,%r14
    30bf:	je     39a6 <botlish_fn_24+0x1a66>
    30c5:	cmp    $0x3a,%r14
    30c9:	je     39a6 <botlish_fn_24+0x1a66>
    30cf:	cmp    $0x3b,%r14
    30d3:	je     3994 <botlish_fn_24+0x1a54>
    30d9:	cmp    $0x3c,%r14
    30dd:	je     398a <botlish_fn_24+0x1a4a>
    30e3:	cmp    $0x3d,%r14
    30e7:	je     3774 <botlish_fn_24+0x1834>
    30ed:	cmp    $0x3e,%r14
    30f1:	je     35b9 <botlish_fn_24+0x1679>
    30f7:	cmp    $0x3f,%r14
    30fb:	je     3586 <botlish_fn_24+0x1646>
    3101:	cmp    $0x40,%r14
    3105:	je     3562 <botlish_fn_24+0x1622>
    310b:	cmp    $0x41,%r14
    310f:	je     3404 <botlish_fn_24+0x14c4>
    3115:	cmp    $0x42,%r14
    3119:	je     33e9 <botlish_fn_24+0x14a9>
    311f:	cmp    $0x43,%r14
    3123:	je     33d7 <botlish_fn_24+0x1497>
    3129:	cmp    $0x44,%r14
    312d:	je     33c5 <botlish_fn_24+0x1485>
    3133:	cmp    $0x45,%r14
    3137:	je     33b3 <botlish_fn_24+0x1473>
    313d:	cmp    $0x46,%r14
    3141:	je     33a1 <botlish_fn_24+0x1461>
    3147:	cmp    $0x47,%r14
    314b:	je     336f <botlish_fn_24+0x142f>
    3151:	cmp    $0x48,%r14
    3155:	je     333d <botlish_fn_24+0x13fd>
    315b:	cmp    $0x49,%r14
    315f:	je     32be <botlish_fn_24+0x137e>
    3165:	cmp    $0x4a,%r14
    3169:	je     323f <botlish_fn_24+0x12ff>
    316f:	cmp    $0x4b,%r14
    3173:	je     323f <botlish_fn_24+0x12ff>
    3179:	cmp    $0x4c,%r14
    317d:	je     322d <botlish_fn_24+0x12ed>
    3183:	cmp    $0x4d,%r14
    3187:	je     322d <botlish_fn_24+0x12ed>
    318d:	cmp    $0x4e,%r14
    3191:	je     321a <botlish_fn_24+0x12da>
    3197:	cmp    $0x4f,%r14
    319b:	je     31f0 <botlish_fn_24+0x12b0>
    31a1:	cmp    $0x50,%r14
    31a5:	je     31e3 <botlish_fn_24+0x12a3>
    31ab:	cmp    $0x51,%r14
    31af:	je     49fe <botlish_fn_24+0x2abe>
    31b5:	cmp    $0x52,%r14
    31b9:	je     49fe <botlish_fn_24+0x2abe>
    31bf:	mov    $0xa,%esi
    31c4:	cmp    $0xffffffffffffffff,%r14
    31c8:	jne    56fa <botlish_fn_24+0x37ba>
    31ce:	mov    0x268(%rsp),%rbx
    31d6:	mov    0x270(%rsp),%r12
    31de:	jmp    57ad <botlish_fn_24+0x386d>
    31e3:	mov    0x2c8(%rsp),%rax
    31eb:	jmp    3798 <botlish_fn_24+0x1858>
    31f0:	mov    $0x75,%r15d
    31f6:	movq   $0x75,0x28(%rsp)
    31ff:	mov    $0x50,%r14d
    3205:	mov    0x268(%rsp),%rbx
    320d:	mov    0x270(%rsp),%r12
    3215:	jmp    57ad <botlish_fn_24+0x386d>
    321a:	mov    $0xa,%r11d
    3220:	mov    0x260(%rsp),%rcx
    3228:	jmp    33f7 <botlish_fn_24+0x14b7>
    322d:	mov    $0xa,%eax
    3232:	mov    0x260(%rsp),%rcx
    323a:	jmp    33f1 <botlish_fn_24+0x14b1>
    323f:	mov    0x260(%rsp),%rcx
    3247:	mov    %rcx,%rax
    324a:	and    $0xf,%rax
    324e:	cmp    $0xa,%rax
    3252:	jl     328b <botlish_fn_24+0x134b>
    3258:	lea    0x57(%rax),%r15
    325c:	shl    $1,%r15
    325f:	or     $0x1,%r15
    3263:	mov    %r15,0x28(%rsp)
    3268:	mov    $0x4d,%r14d
    326e:	mov    0x268(%rsp),%rbx
    3276:	mov    0x270(%rsp),%r12
    327e:	mov    %rcx,0x260(%rsp)
    3286:	jmp    57ad <botlish_fn_24+0x386d>
    328b:	lea    0x30(%rax),%r15
    328f:	shl    $1,%r15
    3292:	or     $0x1,%r15
    3296:	mov    %r15,0x28(%rsp)
    329b:	mov    $0x4c,%r14d
    32a1:	mov    0x268(%rsp),%rbx
    32a9:	mov    0x270(%rsp),%r12
    32b1:	mov    %rcx,0x260(%rsp)
    32b9:	jmp    57ad <botlish_fn_24+0x386d>
    32be:	mov    0x260(%rsp),%rcx
    32c6:	mov    %rcx,%rdi
    32c9:	sar    $0x4,%rdi
    32cd:	cmp    $0xa,%rdi
    32d1:	jl     330a <botlish_fn_24+0x13ca>
    32d7:	lea    0x57(%rdi),%r15
    32db:	shl    $1,%r15
    32de:	or     $0x1,%r15
    32e2:	mov    %r15,0x28(%rsp)
    32e7:	mov    $0x4b,%r14d
    32ed:	mov    0x268(%rsp),%rbx
    32f5:	mov    0x270(%rsp),%r12
    32fd:	mov    %rcx,0x260(%rsp)
    3305:	jmp    57ad <botlish_fn_24+0x386d>
    330a:	lea    0x30(%rdi),%r15
    330e:	shl    $1,%r15
    3311:	or     $0x1,%r15
    3315:	mov    %r15,0x28(%rsp)
    331a:	mov    $0x4a,%r14d
    3320:	mov    0x268(%rsp),%rbx
    3328:	mov    0x270(%rsp),%r12
    3330:	mov    %rcx,0x260(%rsp)
    3338:	jmp    57ad <botlish_fn_24+0x386d>
    333d:	mov    0x260(%rsp),%rcx
    3345:	mov    $0x61,%r15d
    334b:	movq   $0x61,0x28(%rsp)
    3354:	mov    $0x49,%r14d
    335a:	mov    0x268(%rsp),%rbx
    3362:	mov    0x270(%rsp),%r12
    336a:	jmp    57ad <botlish_fn_24+0x386d>
    336f:	mov    0x260(%rsp),%rcx
    3377:	mov    $0x61,%r15d
    337d:	movq   $0x61,0x28(%rsp)
    3386:	mov    $0x48,%r14d
    338c:	mov    0x268(%rsp),%rbx
    3394:	mov    0x270(%rsp),%r12
    339c:	jmp    57ad <botlish_fn_24+0x386d>
    33a1:	mov    0x260(%rsp),%rcx
    33a9:	mov    $0xa,%eax
    33ae:	jmp    33f1 <botlish_fn_24+0x14b1>
    33b3:	mov    0x260(%rsp),%rcx
    33bb:	mov    $0xa,%eax
    33c0:	jmp    33f1 <botlish_fn_24+0x14b1>
    33c5:	mov    0x260(%rsp),%rcx
    33cd:	mov    $0xa,%eax
    33d2:	jmp    33f1 <botlish_fn_24+0x14b1>
    33d7:	mov    0x260(%rsp),%rcx
    33df:	mov    $0xa,%eax
    33e4:	jmp    33f1 <botlish_fn_24+0x14b1>
    33e9:	mov    0x260(%rsp),%rcx
    33f1:	mov    $0xa,%r11d
    33f7:	mov    %rcx,0x260(%rsp)
    33ff:	jmp    3562 <botlish_fn_24+0x1622>
    3404:	mov    0x260(%rsp),%rcx
    340c:	cmp    $0x8,%rcx
    3410:	je     3530 <botlish_fn_24+0x15f0>
    3416:	cmp    $0x9,%rcx
    341a:	je     34fe <botlish_fn_24+0x15be>
    3420:	cmp    $0xa,%rcx
    3424:	je     34cc <botlish_fn_24+0x158c>
    342a:	cmp    $0xc,%rcx
    342e:	je     349a <botlish_fn_24+0x155a>
    3434:	cmp    $0xd,%rcx
    3438:	mov    %rcx,0x260(%rsp)
    3440:	je     3470 <botlish_fn_24+0x1530>
    3446:	mov    $0xeb,%r15d
    344c:	movq   $0xeb,0x28(%rsp)
    3455:	mov    $0x47,%r14d
    345b:	mov    0x268(%rsp),%rbx
    3463:	mov    0x270(%rsp),%r12
    346b:	jmp    57ad <botlish_fn_24+0x386d>
    3470:	mov    $0xe5,%r15d
    3476:	movq   $0xe5,0x28(%rsp)
    347f:	mov    $0x46,%r14d
    3485:	mov    0x268(%rsp),%rbx
    348d:	mov    0x270(%rsp),%r12
    3495:	jmp    57ad <botlish_fn_24+0x386d>
    349a:	mov    %rcx,0x260(%rsp)
    34a2:	mov    $0xcd,%r15d
    34a8:	movq   $0xcd,0x28(%rsp)
    34b1:	mov    $0x45,%r14d
    34b7:	mov    0x268(%rsp),%rbx
    34bf:	mov    0x270(%rsp),%r12
    34c7:	jmp    57ad <botlish_fn_24+0x386d>
    34cc:	mov    %rcx,0x260(%rsp)
    34d4:	mov    $0xdd,%r15d
    34da:	movq   $0xdd,0x28(%rsp)
    34e3:	mov    $0x44,%r14d
    34e9:	mov    0x268(%rsp),%rbx
    34f1:	mov    0x270(%rsp),%r12
    34f9:	jmp    57ad <botlish_fn_24+0x386d>
    34fe:	mov    %rcx,0x260(%rsp)
    3506:	mov    $0xe9,%r15d
    350c:	movq   $0xe9,0x28(%rsp)
    3515:	mov    $0x43,%r14d
    351b:	mov    0x268(%rsp),%rbx
    3523:	mov    0x270(%rsp),%r12
    352b:	jmp    57ad <botlish_fn_24+0x386d>
    3530:	mov    %rcx,0x260(%rsp)
    3538:	mov    $0xc5,%r15d
    353e:	movq   $0xc5,0x28(%rsp)
    3547:	mov    $0x42,%r14d
    354d:	mov    0x268(%rsp),%rbx
    3555:	mov    0x270(%rsp),%r12
    355d:	jmp    57ad <botlish_fn_24+0x386d>
    3562:	mov    0x1c0(%rsp),%rcx
    356a:	add    $0x1,%rcx
    3571:	mov    0x1d0(%rsp),%rax
    3579:	mov    0x1c8(%rsp),%rdx
    3581:	jmp    35da <botlish_fn_24+0x169a>
    3586:	mov    0x1d0(%rsp),%rax
    358e:	mov    0x1c0(%rsp),%rcx
    3596:	mov    %rax,0x28(%rsp)
    359b:	mov    $0x40,%r14d
    35a1:	mov    0x268(%rsp),%rbx
    35a9:	mov    0x270(%rsp),%r12
    35b1:	mov    %rax,%r15
    35b4:	jmp    57ad <botlish_fn_24+0x386d>
    35b9:	mov    0x1d0(%rsp),%rax
    35c1:	mov    0x258(%rsp),%rcx
    35c9:	mov    0x8(%rcx),%rdx
    35cd:	xor    %rcx,%rcx
    35d0:	shl    $1,%rdx
    35d3:	or     $0x1,%rdx
    35d7:	sar    $1,%rdx
    35da:	cmp    %rdx,%rcx
    35dd:	mov    %rdx,0x1c8(%rsp)
    35e5:	jl     3625 <botlish_fn_24+0x16e5>
    35eb:	mov    $0x45,%r15d
    35f1:	movq   $0x45,0x28(%rsp)
    35fa:	mov    $0x4f,%r14d
    3600:	mov    0x268(%rsp),%rbx
    3608:	mov    0x270(%rsp),%r12
    3610:	mov    %rcx,0x1c0(%rsp)
    3618:	mov    %rax,0x1d0(%rsp)
    3620:	jmp    57ad <botlish_fn_24+0x386d>
    3625:	mov    0x258(%rsp),%rax
    362d:	movzbq 0x18(%rax),%rax
    3632:	test   %rax,%rax
    3635:	jne    3667 <botlish_fn_24+0x1727>
    363b:	mov    %rcx,%rdx
    363e:	shl    $1,%rdx
    3641:	mov    %rcx,0x1c0(%rsp)
    3649:	or     $0x1,%rdx
    364d:	mov    0x258(%rsp),%rsi
    3655:	mov    0x1b8(%rsp),%rdi
    365d:	call   3662 <botlish_fn_24+0x1722>
			365e: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    3662:	jmp    368f <botlish_fn_24+0x174f>
    3667:	mov    %rcx,0x1c0(%rsp)
    366f:	shl    $1,%rcx
    3672:	or     $0x1,%rcx
    3676:	sar    $1,%rcx
    3679:	mov    0x258(%rsp),%rax
    3681:	movzbq 0x19(%rax,%rcx,1),%rax
    3687:	shl    $0x3,%rax
    368b:	or     $0x4,%rax
    368f:	shr    $0x3,%rax
    3693:	shl    $1,%rax
    3696:	or     $0x1,%rax
    369a:	mov    %rax,0x110(%rsp)
    36a2:	mov    %rax,%rsi
    36a5:	sar    $1,%rsi
    36a8:	cmp    $0x22,%rsi
    36ac:	jne    36bf <botlish_fn_24+0x177f>
    36b2:	mov    %rax,0x1d0(%rsp)
    36ba:	jmp    374a <botlish_fn_24+0x180a>
    36bf:	cmp    $0x5c,%rsi
    36c3:	jne    36d6 <botlish_fn_24+0x1796>
    36c9:	mov    %rax,0x1d0(%rsp)
    36d1:	jmp    374a <botlish_fn_24+0x180a>
    36d6:	cmp    $0x20,%rsi
    36da:	jl     3710 <botlish_fn_24+0x17d0>
    36e0:	mov    %rax,0x28(%rsp)
    36e5:	mov    %rax,0x1d0(%rsp)
    36ed:	mov    $0x4e,%r14d
    36f3:	mov    0x268(%rsp),%rbx
    36fb:	mov    0x270(%rsp),%r12
    3703:	mov    0x1d0(%rsp),%r15
    370b:	jmp    57ad <botlish_fn_24+0x386d>
    3710:	mov    %rax,0x1d0(%rsp)
    3718:	mov    $0xb9,%r15d
    371e:	movq   $0xb9,0x28(%rsp)
    3727:	mov    $0x41,%r14d
    372d:	mov    0x268(%rsp),%rbx
    3735:	mov    0x270(%rsp),%r12
    373d:	mov    %rsi,0x260(%rsp)
    3745:	jmp    57ad <botlish_fn_24+0x386d>
    374a:	mov    $0xb9,%r15d
    3750:	movq   $0xb9,0x28(%rsp)
    3759:	mov    $0x3f,%r14d
    375f:	mov    0x268(%rsp),%rbx
    3767:	mov    0x270(%rsp),%r12
    376f:	jmp    57ad <botlish_fn_24+0x386d>
    3774:	mov    0x250(%rsp),%rcx
    377c:	mov    0x18(%rcx),%rax
    3780:	mov    (%rax),%rcx
    3783:	cmp    $0xd2,%rcx
    378a:	je     38e6 <botlish_fn_24+0x19a6>
    3790:	mov    0x2c8(%rsp),%rax
    3798:	mov    0x18(%rax),%rcx
    379c:	mov    %rax,0x2c8(%rsp)
    37a4:	mov    0x8(%rcx),%rsi
    37a8:	mov    %rsi,0x10(%rsp)
    37ad:	movq   $0x3,0x18(%rsp)
    37b6:	test   $0x1,%rsi
    37bd:	je     37d5 <botlish_fn_24+0x1895>
    37c3:	mov    %rsi,%rax
    37c6:	add    $0x2,%rax
    37ca:	seto   %cl
    37cd:	test   %cl,%cl
    37cf:	je     37e7 <botlish_fn_24+0x18a7>
    37d5:	mov    $0x3,%edx
    37da:	mov    0x1b8(%rsp),%rdi
    37e2:	call   37e7 <botlish_fn_24+0x18a7>
			37e3: R_X86_64_PLT32	rt_int_add-0x4
    37e7:	mov    %rax,0x10(%rsp)
    37ec:	lea    0x1a8(%rsp),%rcx
    37f4:	mov    0x250(%rsp),%rdx
    37fc:	mov    %rdx,0x1a8(%rsp)
    3804:	mov    %rax,0x1b0(%rsp)
    380c:	mov    $0x1,%esi
    3811:	mov    $0x2,%edx
    3816:	mov    0x1b8(%rsp),%rdi
    381e:	call   3823 <botlish_fn_24+0x18e3>
			381f: R_X86_64_PLT32	rt_struct_new-0x4
    3823:	mov    %rax,%rdx
    3826:	mov    0x2f0(%rsp),%rsi
    382e:	mov    0x1b8(%rsp),%rdi
    3836:	call   383b <botlish_fn_24+0x18fb>
			3837: R_X86_64_PLT32	rt_mv_push-0x4
    383b:	mov    0x250(%rsp),%rcx
    3843:	mov    0x18(%rcx),%rax
    3847:	mov    0x18(%rax),%rsi
    384b:	mov    0x2c8(%rsp),%rax
    3853:	mov    0x18(%rax),%rax
    3857:	mov    0x8(%rax),%rdx
    385b:	test   $0x1,%rdx
    3862:	je     387b <botlish_fn_24+0x193b>
    3868:	mov    0x8(%rsi),%rcx
    386c:	mov    %rdx,%rax
    386f:	sar    $1,%rax
    3872:	cmp    %rcx,%rax
    3875:	jb     38a1 <botlish_fn_24+0x1961>
    387b:	mov    0x1b8(%rsp),%rdi
    3883:	call   3888 <botlish_fn_24+0x1948>
			3884: R_X86_64_PLT32	rt_list_get-0x4
    3888:	test   %rax,%rax
    388b:	je     56e5 <botlish_fn_24+0x37a5>
    3891:	mov    %rax,%rcx
    3894:	mov    0x2e8(%rsp),%r12
    389c:	jmp    38b1 <botlish_fn_24+0x1971>
    38a1:	mov    0x10(%rsi),%rcx
    38a5:	mov    (%rcx,%rax,8),%rcx
    38a9:	mov    0x2e8(%rsp),%r12
    38b1:	mov    0x18(%r12),%rdx
    38b6:	test   %rdx,%rdx
    38b9:	je     5905 <botlish_fn_24+0x39c5>
    38bf:	mov    %r12,%r8
    38c2:	mov    %r12,0x2e8(%rsp)
    38ca:	mov    0x10(%r8),%rax
    38ce:	mov    %rcx,(%rax)
    38d1:	mov    0x2e8(%rsp),%r8
    38d9:	mov    0x270(%rsp),%r12
    38e1:	jmp    51d7 <botlish_fn_24+0x3297>
    38e6:	mov    0x20(%rax),%rsi
    38ea:	mov    0x2c8(%rsp),%rax
    38f2:	mov    0x18(%rax),%rax
    38f6:	mov    0x8(%rax),%rdx
    38fa:	test   $0x1,%rdx
    3901:	je     391a <botlish_fn_24+0x19da>
    3907:	mov    0x8(%rsi),%rcx
    390b:	mov    %rdx,%rax
    390e:	sar    $1,%rax
    3911:	cmp    %rcx,%rax
    3914:	jb     3948 <botlish_fn_24+0x1a08>
    391a:	mov    0x1b8(%rsp),%rdi
    3922:	call   3927 <botlish_fn_24+0x19e7>
			3923: R_X86_64_PLT32	rt_list_get-0x4
    3927:	mov    %rax,%rcx
    392a:	mov    %rax,0x258(%rsp)
    3932:	test   %rcx,%rax
    3935:	je     56e5 <botlish_fn_24+0x37a5>
    393b:	mov    0x258(%rsp),%rax
    3943:	jmp    3958 <botlish_fn_24+0x1a18>
    3948:	mov    0x10(%rsi),%rdx
    394c:	mov    (%rdx,%rax,8),%rax
    3950:	mov    %rax,0x258(%rsp)
    3958:	mov    %rax,0x108(%rsp)
    3960:	mov    $0x45,%r15d
    3966:	movq   $0x45,0x28(%rsp)
    396f:	mov    $0x3e,%r14d
    3975:	mov    0x268(%rsp),%rbx
    397d:	mov    0x270(%rsp),%r12
    3985:	jmp    57ad <botlish_fn_24+0x386d>
    398a:	mov    $0xa,%edx
    398f:	jmp    49fe <botlish_fn_24+0x2abe>
    3994:	mov    $0xa,%esi
    3999:	mov    0x248(%rsp),%rcx
    39a1:	jmp    3b74 <botlish_fn_24+0x1c34>
    39a6:	mov    $0xa,%r10d
    39ac:	mov    0x248(%rsp),%rcx
    39b4:	jmp    3b6f <botlish_fn_24+0x1c2f>
    39b9:	mov    0x248(%rsp),%rcx
    39c1:	mov    %rcx,%rax
    39c4:	and    $0xf,%rax
    39c8:	cmp    $0xa,%rax
    39cc:	jl     3a05 <botlish_fn_24+0x1ac5>
    39d2:	lea    0x57(%rax),%r15
    39d6:	shl    $1,%r15
    39d9:	or     $0x1,%r15
    39dd:	mov    %r15,0x28(%rsp)
    39e2:	mov    $0x3a,%r14d
    39e8:	mov    0x268(%rsp),%rbx
    39f0:	mov    0x270(%rsp),%r12
    39f8:	mov    %rcx,0x248(%rsp)
    3a00:	jmp    57ad <botlish_fn_24+0x386d>
    3a05:	lea    0x30(%rax),%r15
    3a09:	shl    $1,%r15
    3a0c:	or     $0x1,%r15
    3a10:	mov    %r15,0x28(%rsp)
    3a15:	mov    $0x39,%r14d
    3a1b:	mov    0x268(%rsp),%rbx
    3a23:	mov    0x270(%rsp),%r12
    3a2b:	mov    %rcx,0x248(%rsp)
    3a33:	jmp    57ad <botlish_fn_24+0x386d>
    3a38:	mov    0x248(%rsp),%rcx
    3a40:	mov    %rcx,%rax
    3a43:	sar    $0x4,%rax
    3a47:	cmp    $0xa,%rax
    3a4b:	jl     3a84 <botlish_fn_24+0x1b44>
    3a51:	lea    0x57(%rax),%r15
    3a55:	shl    $1,%r15
    3a58:	or     $0x1,%r15
    3a5c:	mov    %r15,0x28(%rsp)
    3a61:	mov    $0x38,%r14d
    3a67:	mov    0x268(%rsp),%rbx
    3a6f:	mov    0x270(%rsp),%r12
    3a77:	mov    %rcx,0x248(%rsp)
    3a7f:	jmp    57ad <botlish_fn_24+0x386d>
    3a84:	lea    0x30(%rax),%r15
    3a88:	shl    $1,%r15
    3a8b:	or     $0x1,%r15
    3a8f:	mov    %r15,0x28(%rsp)
    3a94:	mov    $0x37,%r14d
    3a9a:	mov    0x268(%rsp),%rbx
    3aa2:	mov    0x270(%rsp),%r12
    3aaa:	mov    %rcx,0x248(%rsp)
    3ab2:	jmp    57ad <botlish_fn_24+0x386d>
    3ab7:	mov    0x248(%rsp),%rcx
    3abf:	mov    $0x61,%r15d
    3ac5:	movq   $0x61,0x28(%rsp)
    3ace:	mov    $0x36,%r14d
    3ad4:	mov    0x268(%rsp),%rbx
    3adc:	mov    0x270(%rsp),%r12
    3ae4:	jmp    57ad <botlish_fn_24+0x386d>
    3ae9:	mov    0x248(%rsp),%rcx
    3af1:	mov    $0x61,%r15d
    3af7:	movq   $0x61,0x28(%rsp)
    3b00:	mov    $0x35,%r14d
    3b06:	mov    0x268(%rsp),%rbx
    3b0e:	mov    0x270(%rsp),%r12
    3b16:	jmp    57ad <botlish_fn_24+0x386d>
    3b1b:	mov    0x248(%rsp),%rcx
    3b23:	mov    $0xa,%r10d
    3b29:	jmp    3b6f <botlish_fn_24+0x1c2f>
    3b2e:	mov    0x248(%rsp),%rcx
    3b36:	mov    $0xa,%r10d
    3b3c:	jmp    3b6f <botlish_fn_24+0x1c2f>
    3b41:	mov    0x248(%rsp),%rcx
    3b49:	mov    $0xa,%r10d
    3b4f:	jmp    3b6f <botlish_fn_24+0x1c2f>
    3b54:	mov    0x248(%rsp),%rcx
    3b5c:	mov    $0xa,%r10d
    3b62:	jmp    3b6f <botlish_fn_24+0x1c2f>
    3b67:	mov    0x248(%rsp),%rcx
    3b6f:	mov    $0xa,%esi
    3b74:	mov    %rcx,0x248(%rsp)
    3b7c:	jmp    3cdf <botlish_fn_24+0x1d9f>
    3b81:	mov    0x248(%rsp),%rcx
    3b89:	cmp    $0x8,%rcx
    3b8d:	je     3cad <botlish_fn_24+0x1d6d>
    3b93:	cmp    $0x9,%rcx
    3b97:	je     3c7b <botlish_fn_24+0x1d3b>
    3b9d:	cmp    $0xa,%rcx
    3ba1:	je     3c49 <botlish_fn_24+0x1d09>
    3ba7:	cmp    $0xc,%rcx
    3bab:	je     3c17 <botlish_fn_24+0x1cd7>
    3bb1:	cmp    $0xd,%rcx
    3bb5:	mov    %rcx,0x248(%rsp)
    3bbd:	je     3bed <botlish_fn_24+0x1cad>
    3bc3:	mov    $0xeb,%r15d
    3bc9:	movq   $0xeb,0x28(%rsp)
    3bd2:	mov    $0x34,%r14d
    3bd8:	mov    0x268(%rsp),%rbx
    3be0:	mov    0x270(%rsp),%r12
    3be8:	jmp    57ad <botlish_fn_24+0x386d>
    3bed:	mov    $0xe5,%r15d
    3bf3:	movq   $0xe5,0x28(%rsp)
    3bfc:	mov    $0x33,%r14d
    3c02:	mov    0x268(%rsp),%rbx
    3c0a:	mov    0x270(%rsp),%r12
    3c12:	jmp    57ad <botlish_fn_24+0x386d>
    3c17:	mov    %rcx,0x248(%rsp)
    3c1f:	mov    $0xcd,%r15d
    3c25:	movq   $0xcd,0x28(%rsp)
    3c2e:	mov    $0x32,%r14d
    3c34:	mov    0x268(%rsp),%rbx
    3c3c:	mov    0x270(%rsp),%r12
    3c44:	jmp    57ad <botlish_fn_24+0x386d>
    3c49:	mov    %rcx,0x248(%rsp)
    3c51:	mov    $0xdd,%r15d
    3c57:	movq   $0xdd,0x28(%rsp)
    3c60:	mov    $0x31,%r14d
    3c66:	mov    0x268(%rsp),%rbx
    3c6e:	mov    0x270(%rsp),%r12
    3c76:	jmp    57ad <botlish_fn_24+0x386d>
    3c7b:	mov    %rcx,0x248(%rsp)
    3c83:	mov    $0xe9,%r15d
    3c89:	movq   $0xe9,0x28(%rsp)
    3c92:	mov    $0x30,%r14d
    3c98:	mov    0x268(%rsp),%rbx
    3ca0:	mov    0x270(%rsp),%r12
    3ca8:	jmp    57ad <botlish_fn_24+0x386d>
    3cad:	mov    %rcx,0x248(%rsp)
    3cb5:	mov    $0xc5,%r15d
    3cbb:	movq   $0xc5,0x28(%rsp)
    3cc4:	mov    $0x2f,%r14d
    3cca:	mov    0x268(%rsp),%rbx
    3cd2:	mov    0x270(%rsp),%r12
    3cda:	jmp    57ad <botlish_fn_24+0x386d>
    3cdf:	mov    0x2b8(%rsp),%rcx
    3ce7:	add    $0x1,%rcx
    3cee:	mov    0x240(%rsp),%rax
    3cf6:	mov    0x2c0(%rsp),%rdx
    3cfe:	mov    0x238(%rsp),%rbx
    3d06:	jmp    3d5f <botlish_fn_24+0x1e1f>
    3d0b:	mov    0x240(%rsp),%rax
    3d13:	mov    0x2b8(%rsp),%rcx
    3d1b:	mov    %rax,0x28(%rsp)
    3d20:	mov    $0x2d,%r14d
    3d26:	mov    0x268(%rsp),%rbx
    3d2e:	mov    0x270(%rsp),%r12
    3d36:	mov    %rax,%r15
    3d39:	jmp    57ad <botlish_fn_24+0x386d>
    3d3e:	mov    0x240(%rsp),%rax
    3d46:	mov    0x238(%rsp),%rbx
    3d4e:	mov    0x8(%rbx),%rdx
    3d52:	xor    %rcx,%rcx
    3d55:	shl    $1,%rdx
    3d58:	or     $0x1,%rdx
    3d5c:	sar    $1,%rdx
    3d5f:	cmp    %rdx,%rcx
    3d62:	mov    %rdx,0x2c0(%rsp)
    3d6a:	jl     3db2 <botlish_fn_24+0x1e72>
    3d70:	mov    $0x45,%r15d
    3d76:	movq   $0x45,0x28(%rsp)
    3d7f:	mov    $0x3c,%r14d
    3d85:	mov    %rcx,0x2b8(%rsp)
    3d8d:	mov    %rax,0x240(%rsp)
    3d95:	mov    %rbx,0x238(%rsp)
    3d9d:	mov    0x270(%rsp),%r12
    3da5:	mov    0x268(%rsp),%rbx
    3dad:	jmp    57ad <botlish_fn_24+0x386d>
    3db2:	movzbq 0x18(%rbx),%rax
    3db7:	test   %rax,%rax
    3dba:	jne    3def <botlish_fn_24+0x1eaf>
    3dc0:	mov    %rcx,%rdx
    3dc3:	shl    $1,%rdx
    3dc6:	mov    %rcx,0x2b8(%rsp)
    3dce:	or     $0x1,%rdx
    3dd2:	mov    %rbx,%rsi
    3dd5:	mov    0x1b8(%rsp),%rdi
    3ddd:	call   3de2 <botlish_fn_24+0x1ea2>
			3dde: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    3de2:	mov    %rbx,0x238(%rsp)
    3dea:	jmp    3e22 <botlish_fn_24+0x1ee2>
    3def:	mov    %rbx,0x238(%rsp)
    3df7:	mov    %rcx,0x2b8(%rsp)
    3dff:	mov    %rcx,%rax
    3e02:	shl    $1,%rax
    3e05:	or     $0x1,%rax
    3e09:	sar    $1,%rax
    3e0c:	mov    0x238(%rsp),%rcx
    3e14:	movzbq 0x19(%rcx,%rax,1),%rax
    3e1a:	shl    $0x3,%rax
    3e1e:	or     $0x4,%rax
    3e22:	shr    $0x3,%rax
    3e26:	shl    $1,%rax
    3e29:	or     $0x1,%rax
    3e2d:	mov    %rax,0x100(%rsp)
    3e35:	mov    %rax,%rcx
    3e38:	sar    $1,%rcx
    3e3b:	cmp    $0x22,%rcx
    3e3f:	jne    3e52 <botlish_fn_24+0x1f12>
    3e45:	mov    %rax,0x240(%rsp)
    3e4d:	jmp    3edd <botlish_fn_24+0x1f9d>
    3e52:	cmp    $0x5c,%rcx
    3e56:	jne    3e69 <botlish_fn_24+0x1f29>
    3e5c:	mov    %rax,0x240(%rsp)
    3e64:	jmp    3edd <botlish_fn_24+0x1f9d>
    3e69:	cmp    $0x20,%rcx
    3e6d:	jl     3ea3 <botlish_fn_24+0x1f63>
    3e73:	mov    %rax,0x28(%rsp)
    3e78:	mov    %rax,0x240(%rsp)
    3e80:	mov    $0x3b,%r14d
    3e86:	mov    0x268(%rsp),%rbx
    3e8e:	mov    0x270(%rsp),%r12
    3e96:	mov    0x240(%rsp),%r15
    3e9e:	jmp    57ad <botlish_fn_24+0x386d>
    3ea3:	mov    %rax,0x240(%rsp)
    3eab:	mov    $0xb9,%r15d
    3eb1:	movq   $0xb9,0x28(%rsp)
    3eba:	mov    $0x2e,%r14d
    3ec0:	mov    0x268(%rsp),%rbx
    3ec8:	mov    0x270(%rsp),%r12
    3ed0:	mov    %rcx,0x248(%rsp)
    3ed8:	jmp    57ad <botlish_fn_24+0x386d>
    3edd:	mov    $0xb9,%r15d
    3ee3:	movq   $0xb9,0x28(%rsp)
    3eec:	mov    $0x2c,%r14d
    3ef2:	mov    0x268(%rsp),%rbx
    3efa:	mov    0x270(%rsp),%r12
    3f02:	jmp    57ad <botlish_fn_24+0x386d>
    3f07:	movq   $0x1,0x10(%rsp)
    3f10:	mov    0x228(%rsp),%rax
    3f18:	mov    0x230(%rsp),%rcx
    3f20:	mov    %rax,%rdx
    3f23:	and    %rcx,%rdx
    3f26:	test   $0x1,%rdx
    3f2d:	je     3f67 <botlish_fn_24+0x2027>
    3f33:	mov    0x228(%rsp),%rax
    3f3b:	sar    $1,%rax
    3f3e:	mov    0x230(%rsp),%rcx
    3f46:	add    $0xffffffffffffffff,%rcx
    3f4d:	imul   %rcx
    3f50:	seto   %cl
    3f53:	or     $0x1,%rax
    3f57:	test   %cl,%cl
    3f59:	jne    3f67 <botlish_fn_24+0x2027>
    3f5f:	mov    %rax,%rdx
    3f62:	jmp    3f87 <botlish_fn_24+0x2047>
    3f67:	mov    0x230(%rsp),%rdx
    3f6f:	mov    0x228(%rsp),%rsi
    3f77:	mov    0x1b8(%rsp),%rdi
    3f7f:	call   3f84 <botlish_fn_24+0x2044>
			3f80: R_X86_64_PLT32	rt_int_mul-0x4
    3f84:	mov    %rax,%rdx
    3f87:	mov    %rdx,0x18(%rsp)
    3f8c:	mov    0x2a8(%rsp),%r12
    3f94:	mov    %r12,%rax
    3f97:	and    %rdx,%rax
    3f9a:	test   $0x1,%rax
    3fa0:	je     3fd5 <botlish_fn_24+0x2095>
    3fa6:	mov    %r12,%rcx
    3fa9:	sub    %rdx,%rcx
    3fac:	seto   %sil
    3fb0:	add    $0x1,%rcx
    3fb7:	test   %sil,%sil
    3fba:	jne    3fd5 <botlish_fn_24+0x2095>
    3fc0:	mov    0x2b0(%rsp),%rax
    3fc8:	mov    %r12,0x2a8(%rsp)
    3fd0:	jmp    3ff8 <botlish_fn_24+0x20b8>
    3fd5:	mov    %r12,%rsi
    3fd8:	mov    0x1b8(%rsp),%rdi
    3fe0:	call   3fe5 <botlish_fn_24+0x20a5>
			3fe1: R_X86_64_PLT32	rt_int_sub-0x4
    3fe5:	mov    %r12,0x2a8(%rsp)
    3fed:	mov    %rax,%rcx
    3ff0:	mov    0x2b0(%rsp),%rax
    3ff8:	mov    0x18(%rax),%rdx
    3ffc:	mov    %rax,0x2b0(%rsp)
    4004:	test   %rdx,%rdx
    4007:	je     5927 <botlish_fn_24+0x39e7>
    400d:	mov    0x2b0(%rsp),%rax
    4015:	mov    0x10(%rax),%rax
    4019:	mov    %rcx,(%rax)
    401c:	jmp    4143 <botlish_fn_24+0x2203>
    4021:	movq   $0x3,0x10(%rsp)
    402a:	mov    0x218(%rsp),%rax
    4032:	mov    0x220(%rsp),%rcx
    403a:	mov    %rax,%rdx
    403d:	and    %rcx,%rdx
    4040:	test   $0x1,%rdx
    4047:	je     4080 <botlish_fn_24+0x2140>
    404d:	mov    0x218(%rsp),%rax
    4055:	sar    $1,%rax
    4058:	mov    0x220(%rsp),%rcx
    4060:	lea    -0x1(%rcx),%rsi
    4064:	imul   %rsi
    4067:	seto   %sil
    406b:	or     $0x1,%rax
    406f:	test   %sil,%sil
    4072:	jne    4080 <botlish_fn_24+0x2140>
    4078:	mov    %rax,%rdx
    407b:	jmp    40a0 <botlish_fn_24+0x2160>
    4080:	mov    0x220(%rsp),%rdx
    4088:	mov    0x218(%rsp),%rsi
    4090:	mov    0x1b8(%rsp),%rdi
    4098:	call   409d <botlish_fn_24+0x215d>
			4099: R_X86_64_PLT32	rt_int_mul-0x4
    409d:	mov    %rax,%rdx
    40a0:	mov    %rdx,0x18(%rsp)
    40a5:	mov    0x298(%rsp),%rbx
    40ad:	mov    %rbx,%r8
    40b0:	and    %rdx,%r8
    40b3:	test   $0x1,%r8
    40ba:	je     40ed <botlish_fn_24+0x21ad>
    40c0:	mov    %rbx,%r10
    40c3:	sub    %rdx,%r10
    40c6:	mov    %rdx,%rax
    40c9:	seto   %cl
    40cc:	lea    0x1(%r10),%rdx
    40d0:	test   %cl,%cl
    40d2:	je     40e0 <botlish_fn_24+0x21a0>
    40d8:	mov    %rax,%rdx
    40db:	jmp    40ed <botlish_fn_24+0x21ad>
    40e0:	mov    %rbx,0x298(%rsp)
    40e8:	jmp    4108 <botlish_fn_24+0x21c8>
    40ed:	mov    %rbx,%rsi
    40f0:	mov    0x1b8(%rsp),%rdi
    40f8:	call   40fd <botlish_fn_24+0x21bd>
			40f9: R_X86_64_PLT32	rt_int_sub-0x4
    40fd:	mov    %rbx,0x298(%rsp)
    4105:	mov    %rax,%rdx
    4108:	mov    %rdx,0x18(%rsp)
    410d:	mov    $0x3,%esi
    4112:	mov    0x1b8(%rsp),%rdi
    411a:	call   411f <botlish_fn_24+0x21df>
			411b: R_X86_64_PLT32	rt_mutarray_create-0x4
    411f:	mov    %rax,%rcx
    4122:	mov    %rax,0x2b0(%rsp)
    412a:	test   %rcx,%rax
    412d:	je     56e5 <botlish_fn_24+0x37a5>
    4133:	mov    0x2b0(%rsp),%rax
    413b:	mov    %rax,0xd8(%rsp)
    4143:	mov    0x2a0(%rsp),%rsi
    414b:	mov    0x1b8(%rsp),%rdi
    4153:	call   4158 <botlish_fn_24+0x2218>
			4154: R_X86_64_PLT32	rt_mv_empty-0x4
    4158:	cmp    $0x6,%rax
    415c:	je     4215 <botlish_fn_24+0x22d5>
    4162:	mov    0x2a0(%rsp),%rsi
    416a:	mov    0x1b8(%rsp),%rdi
    4172:	call   4177 <botlish_fn_24+0x2237>
			4173: R_X86_64_PLT32	rt_mv_pop-0x4
    4177:	mov    %rax,%rcx
    417a:	mov    %rax,0x230(%rsp)
    4182:	test   %rcx,%rax
    4185:	je     56e5 <botlish_fn_24+0x37a5>
    418b:	mov    0x230(%rsp),%rax
    4193:	mov    %rax,0xe0(%rsp)
    419b:	mov    0x2b0(%rsp),%rax
    41a3:	mov    0x10(%rax),%rax
    41a7:	mov    (%rax),%r10
    41aa:	mov    %r10,0x2a8(%rsp)
    41b2:	mov    %r10,0xe8(%rsp)
    41ba:	mov    0x230(%rsp),%rdx
    41c2:	mov    0x2a8(%rsp),%rsi
    41ca:	mov    0x1b8(%rsp),%rdi
    41d2:	call   41d7 <botlish_fn_24+0x2297>
			41d3: R_X86_64_PLT32	botlish_fn_1-0x4
    41d7:	mov    %rax,0x228(%rsp)
    41df:	mov    %rax,0xf0(%rsp)
    41e7:	sar    $1,%rax
    41ea:	lea    0x30(%rax),%r15
    41ee:	shl    $1,%r15
    41f1:	or     $0x1,%r15
    41f5:	mov    %r15,0x28(%rsp)
    41fa:	mov    $0x2a,%r14d
    4200:	mov    0x268(%rsp),%rbx
    4208:	mov    0x270(%rsp),%r12
    4210:	jmp    57ad <botlish_fn_24+0x386d>
    4215:	mov    $0xa,%eax
    421a:	jmp    483c <botlish_fn_24+0x28fc>
    421f:	movq   $0x1,0x10(%rsp)
    4228:	mov    0x208(%rsp),%rax
    4230:	mov    0x210(%rsp),%rcx
    4238:	mov    %rax,%rdx
    423b:	and    %rcx,%rdx
    423e:	test   $0x1,%rdx
    4245:	je     427f <botlish_fn_24+0x233f>
    424b:	mov    0x208(%rsp),%rax
    4253:	sar    $1,%rax
    4256:	mov    0x210(%rsp),%rcx
    425e:	add    $0xffffffffffffffff,%rcx
    4265:	imul   %rcx
    4268:	seto   %cl
    426b:	or     $0x1,%rax
    426f:	test   %cl,%cl
    4271:	jne    427f <botlish_fn_24+0x233f>
    4277:	mov    %rax,%rdx
    427a:	jmp    429f <botlish_fn_24+0x235f>
    427f:	mov    0x210(%rsp),%rdx
    4287:	mov    0x208(%rsp),%rsi
    428f:	mov    0x1b8(%rsp),%rdi
    4297:	call   429c <botlish_fn_24+0x235c>
			4298: R_X86_64_PLT32	rt_int_mul-0x4
    429c:	mov    %rax,%rdx
    429f:	mov    %rdx,0x18(%rsp)
    42a4:	mov    0x288(%rsp),%rbx
    42ac:	mov    %rbx,%rax
    42af:	and    %rdx,%rax
    42b2:	test   $0x1,%rax
    42b8:	je     42ed <botlish_fn_24+0x23ad>
    42be:	mov    %rbx,%rcx
    42c1:	sub    %rdx,%rcx
    42c4:	seto   %sil
    42c8:	add    $0x1,%rcx
    42cf:	test   %sil,%sil
    42d2:	jne    42ed <botlish_fn_24+0x23ad>
    42d8:	mov    0x290(%rsp),%rax
    42e0:	mov    %rbx,0x288(%rsp)
    42e8:	jmp    4310 <botlish_fn_24+0x23d0>
    42ed:	mov    %rbx,%rsi
    42f0:	mov    0x1b8(%rsp),%rdi
    42f8:	call   42fd <botlish_fn_24+0x23bd>
			42f9: R_X86_64_PLT32	rt_int_sub-0x4
    42fd:	mov    %rbx,0x288(%rsp)
    4305:	mov    %rax,%rcx
    4308:	mov    0x290(%rsp),%rax
    4310:	mov    0x18(%rax),%rdx
    4314:	mov    %rax,0x290(%rsp)
    431c:	test   %rdx,%rdx
    431f:	je     5946 <botlish_fn_24+0x3a06>
    4325:	mov    0x290(%rsp),%rax
    432d:	mov    0x10(%rax),%rax
    4331:	mov    %rcx,(%rax)
    4334:	jmp    4456 <botlish_fn_24+0x2516>
    4339:	movq   $0x3,0x10(%rsp)
    4342:	mov    0x200(%rsp),%rbx
    434a:	mov    0x1f8(%rsp),%r12
    4352:	mov    %r12,%rax
    4355:	and    %rbx,%rax
    4358:	test   $0x1,%rax
    435e:	je     4398 <botlish_fn_24+0x2458>
    4364:	mov    %r12,%rax
    4367:	sar    $1,%rax
    436a:	lea    -0x1(%rbx),%rcx
    436e:	imul   %rcx
    4371:	seto   %cl
    4374:	or     $0x1,%rax
    4378:	test   %cl,%cl
    437a:	jne    4398 <botlish_fn_24+0x2458>
    4380:	mov    %rax,%rdx
    4383:	mov    %r12,0x1f8(%rsp)
    438b:	mov    %rbx,0x200(%rsp)
    4393:	jmp    43be <botlish_fn_24+0x247e>
    4398:	mov    %rbx,%rdx
    439b:	mov    %r12,%rsi
    439e:	mov    0x1b8(%rsp),%rdi
    43a6:	call   43ab <botlish_fn_24+0x246b>
			43a7: R_X86_64_PLT32	rt_int_mul-0x4
    43ab:	mov    %r12,0x1f8(%rsp)
    43b3:	mov    %rbx,0x200(%rsp)
    43bb:	mov    %rax,%rdx
    43be:	mov    %rdx,0x18(%rsp)
    43c3:	mov    0x278(%rsp),%rax
    43cb:	mov    %rax,%rsi
    43ce:	and    %rdx,%rsi
    43d1:	test   $0x1,%rsi
    43d8:	je     4403 <botlish_fn_24+0x24c3>
    43de:	mov    0x278(%rsp),%rax
    43e6:	mov    %rax,%rdi
    43e9:	sub    %rdx,%rdi
    43ec:	mov    %rdx,%rax
    43ef:	seto   %r9b
    43f3:	lea    0x1(%rdi),%rdx
    43f7:	test   %r9b,%r9b
    43fa:	je     441b <botlish_fn_24+0x24db>
    4400:	mov    %rax,%rdx
    4403:	mov    0x278(%rsp),%rsi
    440b:	mov    0x1b8(%rsp),%rdi
    4413:	call   4418 <botlish_fn_24+0x24d8>
			4414: R_X86_64_PLT32	rt_int_sub-0x4
    4418:	mov    %rax,%rdx
    441b:	mov    %rdx,0x18(%rsp)
    4420:	mov    $0x3,%esi
    4425:	mov    0x1b8(%rsp),%rdi
    442d:	call   4432 <botlish_fn_24+0x24f2>
			442e: R_X86_64_PLT32	rt_mutarray_create-0x4
    4432:	mov    %rax,%rcx
    4435:	mov    %rax,0x290(%rsp)
    443d:	test   %rcx,%rax
    4440:	je     56e5 <botlish_fn_24+0x37a5>
    4446:	mov    0x290(%rsp),%rax
    444e:	mov    %rax,0x98(%rsp)
    4456:	mov    0x280(%rsp),%rsi
    445e:	mov    0x1b8(%rsp),%rdi
    4466:	call   446b <botlish_fn_24+0x252b>
			4467: R_X86_64_PLT32	rt_mv_empty-0x4
    446b:	cmp    $0x6,%rax
    446f:	je     4528 <botlish_fn_24+0x25e8>
    4475:	mov    0x280(%rsp),%rsi
    447d:	mov    0x1b8(%rsp),%rdi
    4485:	call   448a <botlish_fn_24+0x254a>
			4486: R_X86_64_PLT32	rt_mv_pop-0x4
    448a:	mov    %rax,%rcx
    448d:	mov    %rax,0x210(%rsp)
    4495:	test   %rcx,%rax
    4498:	je     56e5 <botlish_fn_24+0x37a5>
    449e:	mov    0x210(%rsp),%rax
    44a6:	mov    %rax,0xa0(%rsp)
    44ae:	mov    0x290(%rsp),%rax
    44b6:	mov    0x10(%rax),%rax
    44ba:	mov    (%rax),%r8
    44bd:	mov    %r8,0x288(%rsp)
    44c5:	mov    %r8,0xa8(%rsp)
    44cd:	mov    0x210(%rsp),%rdx
    44d5:	mov    0x288(%rsp),%rsi
    44dd:	mov    0x1b8(%rsp),%rdi
    44e5:	call   44ea <botlish_fn_24+0x25aa>
			44e6: R_X86_64_PLT32	botlish_fn_1-0x4
    44ea:	mov    %rax,0x208(%rsp)
    44f2:	mov    %rax,0xb0(%rsp)
    44fa:	sar    $1,%rax
    44fd:	lea    0x30(%rax),%r15
    4501:	shl    $1,%r15
    4504:	or     $0x1,%r15
    4508:	mov    %r15,0x28(%rsp)
    450d:	mov    $0x28,%r14d
    4513:	mov    0x268(%rsp),%rbx
    451b:	mov    0x270(%rsp),%r12
    4523:	jmp    57ad <botlish_fn_24+0x386d>
    4528:	mov    $0xa,%eax
    452d:	jmp    483c <botlish_fn_24+0x28fc>
    4532:	movq   $0x1,0x10(%rsp)
    453b:	mov    0x1f0(%rsp),%rcx
    4543:	test   $0x1,%rcx
    454a:	je     4587 <botlish_fn_24+0x2647>
    4550:	mov    $0x1,%eax
    4555:	mov    0x1f0(%rsp),%rcx
    455d:	sub    %rcx,%rax
    4560:	seto   %cl
    4563:	add    $0x1,%rax
    456a:	mov    %rax,0x278(%rsp)
    4572:	test   %cl,%cl
    4574:	jne    4587 <botlish_fn_24+0x2647>
    457a:	mov    0x278(%rsp),%rax
    4582:	jmp    45a9 <botlish_fn_24+0x2669>
    4587:	mov    $0x1,%esi
    458c:	mov    0x1f0(%rsp),%rdx
    4594:	mov    0x1b8(%rsp),%rdi
    459c:	call   45a1 <botlish_fn_24+0x2661>
			459d: R_X86_64_PLT32	rt_int_sub-0x4
    45a1:	mov    %rax,0x278(%rsp)
    45a9:	mov    %rax,0x78(%rsp)
    45ae:	movq   $0x3,0x10(%rsp)
    45b7:	lea    0x198(%rsp),%rdx
    45bf:	movq   $0x3,0x198(%rsp)
    45cb:	mov    $0x1,%esi
    45d0:	mov    0x1b8(%rsp),%rdi
    45d8:	call   45dd <botlish_fn_24+0x269d>
			45d9: R_X86_64_PLT32	rt_list_new-0x4
    45dd:	test   %rax,%rax
    45e0:	je     56e5 <botlish_fn_24+0x37a5>
    45e6:	mov    %rax,0x10(%rsp)
    45eb:	mov    %rax,%rsi
    45ee:	mov    0x1b8(%rsp),%rdi
    45f6:	call   45fb <botlish_fn_24+0x26bb>
			45f7: R_X86_64_PLT32	rt_mv_from_list-0x4
    45fb:	mov    %rax,0x280(%rsp)
    4603:	mov    %rax,0x80(%rsp)
    460b:	mov    0x280(%rsp),%rsi
    4613:	mov    0x1b8(%rsp),%rdi
    461b:	call   4620 <botlish_fn_24+0x26e0>
			461c: R_X86_64_PLT32	rt_mv_len-0x4
    4620:	sar    $1,%rax
    4623:	sub    $0x1,%rax
    4627:	shl    $1,%rax
    462a:	mov    %rax,%rdx
    462d:	or     $0x1,%rdx
    4631:	mov    0x280(%rsp),%rsi
    4639:	mov    0x1b8(%rsp),%rdi
    4641:	call   4646 <botlish_fn_24+0x2706>
			4642: R_X86_64_PLT32	rt_mv_at-0x4
    4646:	mov    %rax,%rcx
    4649:	mov    %rax,%rsi
    464c:	test   %rcx,%rax
    464f:	je     56e5 <botlish_fn_24+0x37a5>
    4655:	mov    %rsi,%rax
    4658:	mov    %rax,0x10(%rsp)
    465d:	movq   $0x15,0x18(%rsp)
    4666:	test   $0x1,%rax
    466c:	jne    467a <botlish_fn_24+0x273a>
    4672:	mov    %rsi,%r12
    4675:	jmp    46b1 <botlish_fn_24+0x2771>
    467a:	mov    %rsi,%rax
    467d:	sar    $1,%rax
    4680:	imulq  0x1331(%rip)        # 59b8 <botlish_fn_24+0x3a78>
    4687:	seto   %cl
    468a:	or     $0x1,%rax
    468e:	test   %cl,%cl
    4690:	je     469e <botlish_fn_24+0x275e>
    4696:	mov    %rsi,%r12
    4699:	jmp    46b1 <botlish_fn_24+0x2771>
    469e:	mov    %rsi,%r12
    46a1:	mov    %rax,%rsi
    46a4:	mov    0x278(%rsp),%rax
    46ac:	jmp    46cf <botlish_fn_24+0x278f>
    46b1:	mov    %rbx,%rdx
    46b4:	mov    %r12,%rsi
    46b7:	mov    0x1b8(%rsp),%rdi
    46bf:	call   46c4 <botlish_fn_24+0x2784>
			46c0: R_X86_64_PLT32	rt_int_mul-0x4
    46c4:	mov    %rax,%rsi
    46c7:	mov    0x278(%rsp),%rax
    46cf:	mov    0x278(%rsp),%rax
    46d7:	mov    %rsi,%rdx
    46da:	and    %rax,%rdx
    46dd:	test   $0x1,%rdx
    46e4:	jne    4714 <botlish_fn_24+0x27d4>
    46ea:	mov    0x278(%rsp),%rdx
    46f2:	mov    0x1b8(%rsp),%rdi
    46fa:	call   46ff <botlish_fn_24+0x27bf>
			46fb: R_X86_64_PLT32	rt_int_cmp-0x4
    46ff:	mov    $0x2,%ecx
    4704:	test   %rax,%rax
    4707:	cmovg  0x12a1(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    470f:	jmp    472c <botlish_fn_24+0x27ec>
    4714:	mov    $0x2,%ecx
    4719:	mov    0x278(%rsp),%rax
    4721:	cmp    %rax,%rsi
    4724:	cmovg  0x1284(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    472c:	cmp    $0x6,%rcx
    4730:	je     47a8 <botlish_fn_24+0x2868>
    4736:	movq   $0x15,0x18(%rsp)
    473f:	test   $0x1,%r12
    4746:	jne    4754 <botlish_fn_24+0x2814>
    474c:	mov    %r12,%rsi
    474f:	jmp    477b <botlish_fn_24+0x283b>
    4754:	mov    %r12,%rax
    4757:	sar    $1,%rax
    475a:	mov    %r12,%rsi
    475d:	imulq  0x1254(%rip)        # 59b8 <botlish_fn_24+0x3a78>
    4764:	seto   %cl
    4767:	or     $0x1,%rax
    476b:	test   %cl,%cl
    476d:	jne    477b <botlish_fn_24+0x283b>
    4773:	mov    %rax,%rdx
    4776:	jmp    478e <botlish_fn_24+0x284e>
    477b:	mov    %rbx,%rdx
    477e:	mov    0x1b8(%rsp),%rdi
    4786:	call   478b <botlish_fn_24+0x284b>
			4787: R_X86_64_PLT32	rt_int_mul-0x4
    478b:	mov    %rax,%rdx
    478e:	mov    0x280(%rsp),%rsi
    4796:	mov    0x1b8(%rsp),%rdi
    479e:	call   47a3 <botlish_fn_24+0x2863>
			479f: R_X86_64_PLT32	rt_mv_push-0x4
    47a3:	jmp    460b <botlish_fn_24+0x26cb>
    47a8:	mov    0x280(%rsp),%rsi
    47b0:	mov    0x1b8(%rsp),%rdi
    47b8:	call   47bd <botlish_fn_24+0x287d>
			47b9: R_X86_64_PLT32	rt_mv_pop-0x4
    47bd:	mov    %rax,%rcx
    47c0:	mov    %rax,0x200(%rsp)
    47c8:	test   %rcx,%rax
    47cb:	je     56e5 <botlish_fn_24+0x37a5>
    47d1:	mov    0x200(%rsp),%rax
    47d9:	mov    %rax,0x88(%rsp)
    47e1:	mov    0x200(%rsp),%rdx
    47e9:	mov    0x278(%rsp),%rsi
    47f1:	mov    0x1b8(%rsp),%rdi
    47f9:	call   47fe <botlish_fn_24+0x28be>
			47fa: R_X86_64_PLT32	botlish_fn_2-0x4
    47fe:	mov    %rax,0x1f8(%rsp)
    4806:	mov    %rax,0x90(%rsp)
    480e:	sar    $1,%rax
    4811:	lea    0x30(%rax),%r15
    4815:	shl    $1,%r15
    4818:	or     $0x1,%r15
    481c:	mov    %r15,0x28(%rsp)
    4821:	mov    $0x27,%r14d
    4827:	mov    0x268(%rsp),%rbx
    482f:	mov    0x270(%rsp),%r12
    4837:	jmp    57ad <botlish_fn_24+0x386d>
    483c:	mov    $0xa,%edx
    4841:	jmp    49fe <botlish_fn_24+0x2abe>
    4846:	mov    $0xa,%edx
    484b:	jmp    49fe <botlish_fn_24+0x2abe>
    4850:	mov    $0xcb,%r15d
    4856:	movq   $0xcb,0x28(%rsp)
    485f:	mov    $0x24,%r14d
    4865:	mov    0x268(%rsp),%rbx
    486d:	mov    0x270(%rsp),%r12
    4875:	jmp    57ad <botlish_fn_24+0x386d>
    487a:	mov    $0xe7,%r15d
    4880:	movq   $0xe7,0x28(%rsp)
    4889:	mov    $0x23,%r14d
    488f:	mov    0x268(%rsp),%rbx
    4897:	mov    0x270(%rsp),%r12
    489f:	jmp    57ad <botlish_fn_24+0x386d>
    48a4:	mov    $0xd9,%r15d
    48aa:	movq   $0xd9,0x28(%rsp)
    48b3:	mov    $0x22,%r14d
    48b9:	mov    0x268(%rsp),%rbx
    48c1:	mov    0x270(%rsp),%r12
    48c9:	jmp    57ad <botlish_fn_24+0x386d>
    48ce:	mov    $0xc3,%r15d
    48d4:	movq   $0xc3,0x28(%rsp)
    48dd:	mov    $0x21,%r14d
    48e3:	mov    0x268(%rsp),%rbx
    48eb:	mov    0x270(%rsp),%r12
    48f3:	jmp    57ad <botlish_fn_24+0x386d>
    48f8:	mov    $0xa,%edx
    48fd:	jmp    49fe <botlish_fn_24+0x2abe>
    4902:	mov    $0xcb,%r15d
    4908:	movq   $0xcb,0x28(%rsp)
    4911:	mov    $0x1f,%r14d
    4917:	mov    0x268(%rsp),%rbx
    491f:	mov    0x270(%rsp),%r12
    4927:	jmp    57ad <botlish_fn_24+0x386d>
    492c:	mov    $0xeb,%r15d
    4932:	movq   $0xeb,0x28(%rsp)
    493b:	mov    $0x1e,%r14d
    4941:	mov    0x268(%rsp),%rbx
    4949:	mov    0x270(%rsp),%r12
    4951:	jmp    57ad <botlish_fn_24+0x386d>
    4956:	mov    $0xe5,%r15d
    495c:	movq   $0xe5,0x28(%rsp)
    4965:	mov    $0x1d,%r14d
    496b:	mov    0x268(%rsp),%rbx
    4973:	mov    0x270(%rsp),%r12
    497b:	jmp    57ad <botlish_fn_24+0x386d>
    4980:	mov    $0xd9,%r15d
    4986:	movq   $0xd9,0x28(%rsp)
    498f:	mov    $0x1b,%r14d
    4995:	mov    0x268(%rsp),%rbx
    499d:	mov    0x270(%rsp),%r12
    49a5:	jmp    57ad <botlish_fn_24+0x386d>
    49aa:	mov    $0xd9,%r15d
    49b0:	movq   $0xd9,0x28(%rsp)
    49b9:	mov    $0x1a,%r14d
    49bf:	mov    0x268(%rsp),%rbx
    49c7:	mov    0x270(%rsp),%r12
    49cf:	jmp    57ad <botlish_fn_24+0x386d>
    49d4:	mov    $0xeb,%r15d
    49da:	movq   $0xeb,0x28(%rsp)
    49e3:	mov    $0x19,%r14d
    49e9:	mov    0x268(%rsp),%rbx
    49f1:	mov    0x270(%rsp),%r12
    49f9:	jmp    57ad <botlish_fn_24+0x386d>
    49fe:	mov    0x2f0(%rsp),%rsi
    4a06:	mov    0x1b8(%rsp),%rdi
    4a0e:	call   4a13 <botlish_fn_24+0x2ad3>
			4a0f: R_X86_64_PLT32	rt_mv_empty-0x4
    4a13:	cmp    $0x6,%rax
    4a17:	je     4b75 <botlish_fn_24+0x2c35>
    4a1d:	mov    0x2f0(%rsp),%rsi
    4a25:	mov    0x1b8(%rsp),%rdi
    4a2d:	call   4a32 <botlish_fn_24+0x2af2>
			4a2e: R_X86_64_PLT32	rt_mv_pop-0x4
    4a32:	mov    %rax,%rcx
    4a35:	mov    %rax,0x2c8(%rsp)
    4a3d:	test   %rcx,%rax
    4a40:	je     56e5 <botlish_fn_24+0x37a5>
    4a46:	mov    0x2c8(%rsp),%rax
    4a4e:	mov    %rax,0x50(%rsp)
    4a53:	mov    0x18(%rax),%r10
    4a57:	mov    (%r10),%rcx
    4a5a:	mov    %rcx,0x250(%rsp)
    4a62:	mov    %rcx,0x58(%rsp)
    4a67:	mov    0x18(%rax),%r11
    4a6b:	mov    0x8(%r11),%rsi
    4a6f:	mov    %rsi,%rbx
    4a72:	mov    0x250(%rsp),%rsi
    4a7a:	mov    0x1b8(%rsp),%rdi
    4a82:	call   4a87 <botlish_fn_24+0x2b47>
			4a83: R_X86_64_PLT32	botlish_fn_19-0x4
    4a87:	mov    %rbx,%rsi
    4a8a:	mov    %rsi,%r11
    4a8d:	and    %rax,%r11
    4a90:	mov    %rax,%rdx
    4a93:	test   $0x1,%r11
    4a9a:	jne    4ac2 <botlish_fn_24+0x2b82>
    4aa0:	mov    0x1b8(%rsp),%rdi
    4aa8:	call   4aad <botlish_fn_24+0x2b6d>
			4aa9: R_X86_64_PLT32	rt_int_cmp-0x4
    4aad:	mov    $0x2,%ecx
    4ab2:	test   %rax,%rax
    4ab5:	cmovl  0xef3(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    4abd:	jmp    4ad2 <botlish_fn_24+0x2b92>
    4ac2:	mov    $0x2,%ecx
    4ac7:	cmp    %rdx,%rsi
    4aca:	cmovl  0xede(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    4ad2:	cmp    $0x6,%rcx
    4ad6:	je     4b4b <botlish_fn_24+0x2c0b>
    4adc:	mov    0x250(%rsp),%rcx
    4ae4:	mov    0x18(%rcx),%rax
    4ae8:	mov    (%rax),%rax
    4aeb:	cmp    $0xb2,%rax
    4af1:	je     4b21 <botlish_fn_24+0x2be1>
    4af7:	mov    $0xfb,%r15d
    4afd:	movq   $0xfb,0x28(%rsp)
    4b06:	mov    $0x52,%r14d
    4b0c:	mov    0x268(%rsp),%rbx
    4b14:	mov    0x270(%rsp),%r12
    4b1c:	jmp    57ad <botlish_fn_24+0x386d>
    4b21:	mov    $0xbb,%r15d
    4b27:	movq   $0xbb,0x28(%rsp)
    4b30:	mov    $0x51,%r14d
    4b36:	mov    0x268(%rsp),%rbx
    4b3e:	mov    0x270(%rsp),%r12
    4b46:	jmp    57ad <botlish_fn_24+0x386d>
    4b4b:	mov    $0x59,%r15d
    4b51:	movq   $0x59,0x28(%rsp)
    4b5a:	mov    $0x3d,%r14d
    4b60:	mov    0x268(%rsp),%rbx
    4b68:	mov    0x270(%rsp),%r12
    4b70:	jmp    57ad <botlish_fn_24+0x386d>
    4b75:	mov    $0xffffffffffffffff,%r15
    4b7c:	movq   $0xffffffffffffffff,0x28(%rsp)
    4b85:	mov    0x268(%rsp),%rbx
    4b8d:	mov    0x270(%rsp),%r12
    4b95:	mov    %r15,%r14
    4b98:	jmp    57ad <botlish_fn_24+0x386d>
    4b9d:	mov    0x268(%rsp),%rbx
    4ba5:	mov    0x270(%rsp),%r12
    4bad:	jmp    5108 <botlish_fn_24+0x31c8>
    4bb2:	mov    $0x75,%r15d
    4bb8:	movq   $0x75,0x28(%rsp)
    4bc1:	mov    $0x15,%r14d
    4bc7:	mov    0x268(%rsp),%rbx
    4bcf:	mov    0x270(%rsp),%r12
    4bd7:	jmp    57ad <botlish_fn_24+0x386d>
    4bdc:	mov    $0xa,%eax
    4be1:	jmp    4ea7 <botlish_fn_24+0x2f67>
    4be6:	mov    $0xa,%eax
    4beb:	jmp    4d47 <botlish_fn_24+0x2e07>
    4bf0:	mov    0x1e8(%rsp),%rcx
    4bf8:	mov    %rcx,%rax
    4bfb:	and    $0xf,%rax
    4bff:	cmp    $0xa,%rax
    4c03:	jl     4c34 <botlish_fn_24+0x2cf4>
    4c09:	lea    0x57(%rax),%r15
    4c0d:	shl    $1,%r15
    4c10:	or     $0x1,%r15
    4c14:	mov    %r15,0x28(%rsp)
    4c19:	mov    $0x12,%r14d
    4c1f:	mov    0x268(%rsp),%rbx
    4c27:	mov    0x270(%rsp),%r12
    4c2f:	jmp    57ad <botlish_fn_24+0x386d>
    4c34:	lea    0x30(%rax),%r15
    4c38:	shl    $1,%r15
    4c3b:	or     $0x1,%r15
    4c3f:	mov    %r15,0x28(%rsp)
    4c44:	mov    $0x11,%r14d
    4c4a:	mov    0x268(%rsp),%rbx
    4c52:	mov    0x270(%rsp),%r12
    4c5a:	jmp    57ad <botlish_fn_24+0x386d>
    4c5f:	mov    0x1e8(%rsp),%rcx
    4c67:	mov    %rcx,%rax
    4c6a:	sar    $0x4,%rax
    4c6e:	cmp    $0xa,%rax
    4c72:	jl     4ca5 <botlish_fn_24+0x2d65>
    4c78:	lea    0x57(%rax),%r15
    4c7c:	shl    $1,%r15
    4c7f:	or     $0x1,%r15
    4c83:	mov    %r15,0x28(%rsp)
    4c88:	mov    0x268(%rsp),%rbx
    4c90:	mov    0x270(%rsp),%r12
    4c98:	mov    0x2e0(%rsp),%r14
    4ca0:	jmp    57ad <botlish_fn_24+0x386d>
    4ca5:	lea    0x30(%rax),%r15
    4ca9:	shl    $1,%r15
    4cac:	or     $0x1,%r15
    4cb0:	mov    %r15,0x28(%rsp)
    4cb5:	mov    $0xf,%r14d
    4cbb:	mov    0x268(%rsp),%rbx
    4cc3:	mov    0x270(%rsp),%r12
    4ccb:	jmp    57ad <botlish_fn_24+0x386d>
    4cd0:	mov    $0x61,%r15d
    4cd6:	movq   $0x61,0x28(%rsp)
    4cdf:	mov    $0xe,%r14d
    4ce5:	mov    0x268(%rsp),%rbx
    4ced:	mov    0x270(%rsp),%r12
    4cf5:	jmp    57ad <botlish_fn_24+0x386d>
    4cfa:	mov    $0x61,%r15d
    4d00:	movq   $0x61,0x28(%rsp)
    4d09:	mov    $0xd,%r14d
    4d0f:	mov    0x268(%rsp),%rbx
    4d17:	mov    0x270(%rsp),%r12
    4d1f:	jmp    57ad <botlish_fn_24+0x386d>
    4d24:	mov    $0xa,%eax
    4d29:	jmp    4d47 <botlish_fn_24+0x2e07>
    4d2e:	mov    $0xa,%eax
    4d33:	jmp    4d47 <botlish_fn_24+0x2e07>
    4d38:	mov    $0xa,%eax
    4d3d:	jmp    4d47 <botlish_fn_24+0x2e07>
    4d42:	mov    $0xa,%eax
    4d47:	mov    $0xa,%eax
    4d4c:	jmp    4ea7 <botlish_fn_24+0x2f67>
    4d51:	mov    0x1e8(%rsp),%rcx
    4d59:	cmp    $0x8,%rcx
    4d5d:	je     4e7d <botlish_fn_24+0x2f3d>
    4d63:	mov    $0x9,%r14d
    4d69:	mov    0x1e8(%rsp),%rcx
    4d71:	cmp    $0x9,%rcx
    4d75:	je     4e53 <botlish_fn_24+0x2f13>
    4d7b:	mov    0x1e8(%rsp),%rcx
    4d83:	cmp    $0xa,%rcx
    4d87:	je     4e2f <botlish_fn_24+0x2eef>
    4d8d:	mov    $0xc,%r14d
    4d93:	mov    0x1e8(%rsp),%rcx
    4d9b:	cmp    $0xc,%rcx
    4d9f:	je     4e05 <botlish_fn_24+0x2ec5>
    4da5:	mov    0x1e8(%rsp),%rcx
    4dad:	cmp    $0xd,%rcx
    4db1:	je     4ddb <botlish_fn_24+0x2e9b>
    4db7:	mov    $0xeb,%r15d
    4dbd:	movq   $0xeb,0x28(%rsp)
    4dc6:	mov    0x268(%rsp),%rbx
    4dce:	mov    0x270(%rsp),%r12
    4dd6:	jmp    57ad <botlish_fn_24+0x386d>
    4ddb:	mov    $0xe5,%r15d
    4de1:	movq   $0xe5,0x28(%rsp)
    4dea:	mov    $0xb,%r14d
    4df0:	mov    0x268(%rsp),%rbx
    4df8:	mov    0x270(%rsp),%r12
    4e00:	jmp    57ad <botlish_fn_24+0x386d>
    4e05:	mov    $0xcd,%r15d
    4e0b:	movq   $0xcd,0x28(%rsp)
    4e14:	mov    $0xa,%r14d
    4e1a:	mov    0x268(%rsp),%rbx
    4e22:	mov    0x270(%rsp),%r12
    4e2a:	jmp    57ad <botlish_fn_24+0x386d>
    4e2f:	mov    $0xdd,%r15d
    4e35:	movq   $0xdd,0x28(%rsp)
    4e3e:	mov    0x268(%rsp),%rbx
    4e46:	mov    0x270(%rsp),%r12
    4e4e:	jmp    57ad <botlish_fn_24+0x386d>
    4e53:	mov    $0xe9,%r15d
    4e59:	movq   $0xe9,0x28(%rsp)
    4e62:	mov    $0x8,%r14d
    4e68:	mov    0x268(%rsp),%rbx
    4e70:	mov    0x270(%rsp),%r12
    4e78:	jmp    57ad <botlish_fn_24+0x386d>
    4e7d:	mov    $0xc5,%r15d
    4e83:	movq   $0xc5,0x28(%rsp)
    4e8c:	mov    $0x7,%r14d
    4e92:	mov    0x268(%rsp),%rbx
    4e9a:	mov    0x270(%rsp),%r12
    4ea2:	jmp    57ad <botlish_fn_24+0x386d>
    4ea7:	add    $0x1,%r13
    4eae:	mov    0x1e0(%rsp),%rax
    4eb6:	mov    0x270(%rsp),%r12
    4ebe:	jmp    4f11 <botlish_fn_24+0x2fd1>
    4ec3:	mov    0x1e0(%rsp),%rax
    4ecb:	mov    %rax,0x28(%rsp)
    4ed0:	mov    0x268(%rsp),%rbx
    4ed8:	mov    0x270(%rsp),%r12
    4ee0:	mov    0x2d0(%rsp),%r14
    4ee8:	mov    %rax,%r15
    4eeb:	jmp    57ad <botlish_fn_24+0x386d>
    4ef0:	mov    0x1e0(%rsp),%rax
    4ef8:	mov    0x1d8(%rsp),%rcx
    4f00:	mov    0x8(%rcx),%r12
    4f04:	xor    %r13,%r13
    4f07:	shl    $1,%r12
    4f0a:	or     $0x1,%r12
    4f0e:	sar    $1,%r12
    4f11:	cmp    %r12,%r13
    4f14:	jl     4f44 <botlish_fn_24+0x3004>
    4f1a:	mov    $0x45,%r15d
    4f20:	movq   $0x45,0x28(%rsp)
    4f29:	mov    $0x14,%r14d
    4f2f:	mov    0x268(%rsp),%rbx
    4f37:	mov    %rax,0x1e0(%rsp)
    4f3f:	jmp    57ad <botlish_fn_24+0x386d>
    4f44:	mov    0x1d8(%rsp),%rax
    4f4c:	movzbq 0x18(%rax),%rax
    4f51:	test   %rax,%rax
    4f54:	jne    4f7e <botlish_fn_24+0x303e>
    4f5a:	mov    %r13,%rdx
    4f5d:	shl    $1,%rdx
    4f60:	or     $0x1,%rdx
    4f64:	mov    0x1d8(%rsp),%rsi
    4f6c:	mov    0x1b8(%rsp),%rdi
    4f74:	call   4f79 <botlish_fn_24+0x3039>
			4f75: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    4f79:	jmp    4fa1 <botlish_fn_24+0x3061>
    4f7e:	mov    %r13,%rax
    4f81:	shl    $1,%rax
    4f84:	or     $0x1,%rax
    4f88:	sar    $1,%rax
    4f8b:	mov    0x1d8(%rsp),%rcx
    4f93:	movzbq 0x19(%rcx,%rax,1),%rax
    4f99:	shl    $0x3,%rax
    4f9d:	or     $0x4,%rax
    4fa1:	shr    $0x3,%rax
    4fa5:	shl    $1,%rax
    4fa8:	or     $0x1,%rax
    4fac:	mov    %rax,0x68(%rsp)
    4fb1:	mov    %rax,%rcx
    4fb4:	sar    $1,%rcx
    4fb7:	cmp    $0x22,%rcx
    4fbb:	jne    4fce <botlish_fn_24+0x308e>
    4fc1:	mov    %rax,0x1e0(%rsp)
    4fc9:	jmp    5049 <botlish_fn_24+0x3109>
    4fce:	cmp    $0x5c,%rcx
    4fd2:	jne    4fe5 <botlish_fn_24+0x30a5>
    4fd8:	mov    %rax,0x1e0(%rsp)
    4fe0:	jmp    5049 <botlish_fn_24+0x3109>
    4fe5:	cmp    $0x20,%rcx
    4fe9:	jl     5017 <botlish_fn_24+0x30d7>
    4fef:	mov    %rax,0x28(%rsp)
    4ff4:	mov    %rax,0x1e0(%rsp)
    4ffc:	mov    $0x13,%r14d
    5002:	mov    0x268(%rsp),%rbx
    500a:	mov    0x1e0(%rsp),%r15
    5012:	jmp    57ad <botlish_fn_24+0x386d>
    5017:	mov    %rax,0x1e0(%rsp)
    501f:	mov    $0xb9,%r15d
    5025:	movq   $0xb9,0x28(%rsp)
    502e:	mov    $0x6,%r14d
    5034:	mov    0x268(%rsp),%rbx
    503c:	mov    %rcx,0x1e8(%rsp)
    5044:	jmp    57ad <botlish_fn_24+0x386d>
    5049:	mov    $0xb9,%r15d
    504f:	movq   $0xb9,0x28(%rsp)
    5058:	mov    $0x4,%r14d
    505e:	mov    0x268(%rsp),%rbx
    5066:	jmp    57ad <botlish_fn_24+0x386d>
    506b:	mov    0x270(%rsp),%r12
    5073:	mov    0x268(%rsp),%rbx
    507b:	jmp    5090 <botlish_fn_24+0x3150>
    5080:	mov    0x270(%rsp),%r12
    5088:	mov    0x268(%rsp),%rbx
    5090:	mov    %rbx,%rsi
    5093:	mov    0x1b8(%rsp),%rdi
    509b:	call   50a0 <botlish_fn_24+0x3160>
			509c: R_X86_64_PLT32	botlish_fn_19-0x4
    50a0:	sar    $1,%rax
    50a3:	test   %rax,%rax
    50a6:	jg     50f4 <botlish_fn_24+0x31b4>
    50ac:	mov    0x18(%rbx),%r8
    50b0:	mov    (%r8),%r8
    50b3:	cmp    $0xb2,%r8
    50ba:	je     50da <botlish_fn_24+0x319a>
    50c0:	mov    $0xfb,%r15d
    50c6:	movq   $0xfb,0x28(%rsp)
    50cf:	mov    $0x17,%r14d
    50d5:	jmp    57ad <botlish_fn_24+0x386d>
    50da:	mov    $0xbb,%r15d
    50e0:	movq   $0xbb,0x28(%rsp)
    50e9:	mov    $0x16,%r14d
    50ef:	jmp    57ad <botlish_fn_24+0x386d>
    50f4:	mov    0x18(%rbx),%rax
    50f8:	mov    (%rax),%rcx
    50fb:	cmp    $0xd2,%rcx
    5102:	je     56ae <botlish_fn_24+0x376e>
    5108:	movq   $0x3,0x10(%rsp)
    5111:	lea    0x188(%rsp),%rcx
    5119:	mov    %rbx,0x188(%rsp)
    5121:	movq   $0x3,0x190(%rsp)
    512d:	mov    $0x1,%esi
    5132:	mov    $0x2,%edx
    5137:	mov    0x1b8(%rsp),%rdi
    513f:	call   5144 <botlish_fn_24+0x3204>
			5140: R_X86_64_PLT32	rt_struct_new-0x4
    5144:	mov    %rax,%rdx
    5147:	mov    0x2f0(%rsp),%rsi
    514f:	mov    0x1b8(%rsp),%rdi
    5157:	call   515c <botlish_fn_24+0x321c>
			5158: R_X86_64_PLT32	rt_mv_push-0x4
    515c:	mov    0x18(%rbx),%rax
    5160:	mov    0x18(%rax),%rsi
    5164:	mov    0x8(%rsi),%rax
    5168:	test   %rax,%rax
    516b:	jne    519c <botlish_fn_24+0x325c>
    5171:	mov    $0x1,%edx
    5176:	mov    0x1b8(%rsp),%rdi
    517e:	call   5183 <botlish_fn_24+0x3243>
			517f: R_X86_64_PLT32	rt_list_get-0x4
    5183:	test   %rax,%rax
    5186:	je     56e5 <botlish_fn_24+0x37a5>
    518c:	mov    %rax,%rcx
    518f:	mov    0x2e8(%rsp),%r8
    5197:	jmp    51ab <botlish_fn_24+0x326b>
    519c:	mov    0x10(%rsi),%rax
    51a0:	mov    (%rax),%rcx
    51a3:	mov    0x2e8(%rsp),%r8
    51ab:	mov    0x2e8(%rsp),%r8
    51b3:	mov    0x18(%r8),%rax
    51b7:	test   %rax,%rax
    51ba:	je     5965 <botlish_fn_24+0x3a25>
    51c0:	mov    0x2e8(%rsp),%r8
    51c8:	mov    0x10(%r8),%rax
    51cc:	mov    %rcx,(%rax)
    51cf:	mov    0x2e8(%rsp),%r8
    51d7:	mov    0x2e8(%rsp),%r8
    51df:	mov    0x10(%r8),%rax
    51e3:	mov    (%rax),%rbx
    51e6:	mov    %rbx,0x48(%rsp)
    51eb:	mov    0x18(%rbx),%rax
    51ef:	mov    (%rax),%rcx
    51f2:	cmp    $0xb2,%rcx
    51f9:	je     566d <botlish_fn_24+0x372d>
    51ff:	cmp    $0xd2,%rcx
    5206:	je     566d <botlish_fn_24+0x372d>
    520c:	cmp    $0x12,%rcx
    5210:	je     5653 <botlish_fn_24+0x3713>
    5216:	cmp    $0x52,%rcx
    521a:	je     5639 <botlish_fn_24+0x36f9>
    5220:	cmp    $0x32,%rcx
    5224:	je     561f <botlish_fn_24+0x36df>
    522a:	cmp    $0x72,%rcx
    522e:	je     5262 <botlish_fn_24+0x3322>
    5234:	mov    0x10(%rax),%rcx
    5238:	mov    %rcx,0x238(%rsp)
    5240:	mov    %rcx,0xf8(%rsp)
    5248:	mov    $0x45,%r15d
    524e:	movq   $0x45,0x28(%rsp)
    5257:	mov    $0x2b,%r14d
    525d:	jmp    57ad <botlish_fn_24+0x386d>
    5262:	mov    0x8(%rax),%rcx
    5266:	mov    %rcx,0x1f0(%rsp)
    526e:	mov    %rcx,0x70(%rsp)
    5273:	mov    0x1f0(%rsp),%rcx
    527b:	test   $0x1,%rcx
    5282:	jne    52b7 <botlish_fn_24+0x3377>
    5288:	mov    $0x1,%edx
    528d:	mov    0x1f0(%rsp),%rsi
    5295:	mov    0x1b8(%rsp),%rdi
    529d:	call   52a2 <botlish_fn_24+0x3362>
			529e: R_X86_64_PLT32	rt_int_cmp-0x4
    52a2:	mov    $0x2,%ecx
    52a7:	test   %rax,%rax
    52aa:	cmove  0x6fe(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    52b2:	jmp    52d0 <botlish_fn_24+0x3390>
    52b7:	mov    $0x2,%ecx
    52bc:	mov    0x1f0(%rsp),%rax
    52c4:	cmp    $0x1,%rax
    52c8:	cmove  0x6e0(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    52d0:	cmp    $0x6,%rcx
    52d4:	je     5605 <botlish_fn_24+0x36c5>
    52da:	mov    0x1f0(%rsp),%rcx
    52e2:	test   $0x1,%rcx
    52e9:	jne    531e <botlish_fn_24+0x33de>
    52ef:	mov    $0x1,%edx
    52f4:	mov    0x1f0(%rsp),%rsi
    52fc:	mov    0x1b8(%rsp),%rdi
    5304:	call   5309 <botlish_fn_24+0x33c9>
			5305: R_X86_64_PLT32	rt_int_cmp-0x4
    5309:	mov    $0x2,%ecx
    530e:	test   %rax,%rax
    5311:	cmovl  0x697(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    5319:	jmp    533e <botlish_fn_24+0x33fe>
    531e:	mov    $0x2,%ecx
    5323:	mov    0x1f0(%rsp),%r10
    532b:	mov    0x1f0(%rsp),%r11
    5333:	test   %r10,%r11
    5336:	cmovle 0x672(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    533e:	cmp    $0x6,%rcx
    5342:	je     55eb <botlish_fn_24+0x36ab>
    5348:	mov    0x1f0(%rsp),%rcx
    5350:	mov    %rcx,0xb8(%rsp)
    5358:	movq   $0x3,0x10(%rsp)
    5361:	lea    0x1a0(%rsp),%rdx
    5369:	movq   $0x3,0x1a0(%rsp)
    5375:	mov    $0x1,%esi
    537a:	mov    0x1b8(%rsp),%rdi
    5382:	call   5387 <botlish_fn_24+0x3447>
			5383: R_X86_64_PLT32	rt_list_new-0x4
    5387:	test   %rax,%rax
    538a:	je     56e5 <botlish_fn_24+0x37a5>
    5390:	mov    %rax,0x10(%rsp)
    5395:	mov    %rax,%rsi
    5398:	mov    0x1b8(%rsp),%rdi
    53a0:	call   53a5 <botlish_fn_24+0x3465>
			53a1: R_X86_64_PLT32	rt_mv_from_list-0x4
    53a5:	mov    %rax,0x2a0(%rsp)
    53ad:	mov    %rax,0xc0(%rsp)
    53b5:	mov    $0x15,%r14d
    53bb:	mov    0x2a0(%rsp),%rsi
    53c3:	mov    0x1b8(%rsp),%rdi
    53cb:	call   53d0 <botlish_fn_24+0x3490>
			53cc: R_X86_64_PLT32	rt_mv_len-0x4
    53d0:	sar    $1,%rax
    53d3:	sub    $0x1,%rax
    53d7:	shl    $1,%rax
    53da:	mov    %rax,%rdx
    53dd:	or     $0x1,%rdx
    53e1:	mov    0x2a0(%rsp),%rsi
    53e9:	mov    0x1b8(%rsp),%rdi
    53f1:	call   53f6 <botlish_fn_24+0x34b6>
			53f2: R_X86_64_PLT32	rt_mv_at-0x4
    53f6:	mov    %rax,%rcx
    53f9:	mov    %rax,%rsi
    53fc:	test   %rcx,%rax
    53ff:	je     56e5 <botlish_fn_24+0x37a5>
    5405:	mov    %rsi,%rax
    5408:	mov    %rax,0x10(%rsp)
    540d:	movq   $0x15,0x18(%rsp)
    5416:	test   $0x1,%rax
    541c:	jne    542a <botlish_fn_24+0x34ea>
    5422:	mov    %rsi,%r15
    5425:	jmp    5461 <botlish_fn_24+0x3521>
    542a:	mov    %rsi,%rax
    542d:	sar    $1,%rax
    5430:	imulq  0x581(%rip)        # 59b8 <botlish_fn_24+0x3a78>
    5437:	seto   %cl
    543a:	or     $0x1,%rax
    543e:	test   %cl,%cl
    5440:	je     544e <botlish_fn_24+0x350e>
    5446:	mov    %rsi,%r15
    5449:	jmp    5461 <botlish_fn_24+0x3521>
    544e:	mov    %rsi,%r15
    5451:	mov    %rax,%rsi
    5454:	mov    0x1f0(%rsp),%rcx
    545c:	jmp    547f <botlish_fn_24+0x353f>
    5461:	mov    %r14,%rdx
    5464:	mov    %r15,%rsi
    5467:	mov    0x1b8(%rsp),%rdi
    546f:	call   5474 <botlish_fn_24+0x3534>
			5470: R_X86_64_PLT32	rt_int_mul-0x4
    5474:	mov    0x1f0(%rsp),%rcx
    547c:	mov    %rax,%rsi
    547f:	mov    0x1f0(%rsp),%rcx
    5487:	mov    %rsi,%rax
    548a:	and    %rcx,%rax
    548d:	test   $0x1,%rax
    5493:	jne    54c3 <botlish_fn_24+0x3583>
    5499:	mov    0x1f0(%rsp),%rdx
    54a1:	mov    0x1b8(%rsp),%rdi
    54a9:	call   54ae <botlish_fn_24+0x356e>
			54aa: R_X86_64_PLT32	rt_int_cmp-0x4
    54ae:	mov    $0x2,%ecx
    54b3:	test   %rax,%rax
    54b6:	cmovg  0x4f2(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    54be:	jmp    54db <botlish_fn_24+0x359b>
    54c3:	mov    $0x2,%ecx
    54c8:	mov    0x1f0(%rsp),%rdi
    54d0:	cmp    %rdi,%rsi
    54d3:	cmovg  0x4d5(%rip),%rcx        # 59b0 <botlish_fn_24+0x3a70>
    54db:	cmp    $0x6,%rcx
    54df:	je     5557 <botlish_fn_24+0x3617>
    54e5:	movq   $0x15,0x18(%rsp)
    54ee:	test   $0x1,%r15
    54f5:	jne    5503 <botlish_fn_24+0x35c3>
    54fb:	mov    %r15,%rsi
    54fe:	jmp    552a <botlish_fn_24+0x35ea>
    5503:	mov    %r15,%rax
    5506:	sar    $1,%rax
    5509:	mov    %r15,%rsi
    550c:	imulq  0x4a5(%rip)        # 59b8 <botlish_fn_24+0x3a78>
    5513:	seto   %cl
    5516:	or     $0x1,%rax
    551a:	test   %cl,%cl
    551c:	jne    552a <botlish_fn_24+0x35ea>
    5522:	mov    %rax,%rdx
    5525:	jmp    553d <botlish_fn_24+0x35fd>
    552a:	mov    %r14,%rdx
    552d:	mov    0x1b8(%rsp),%rdi
    5535:	call   553a <botlish_fn_24+0x35fa>
			5536: R_X86_64_PLT32	rt_int_mul-0x4
    553a:	mov    %rax,%rdx
    553d:	mov    0x2a0(%rsp),%rsi
    5545:	mov    0x1b8(%rsp),%rdi
    554d:	call   5552 <botlish_fn_24+0x3612>
			554e: R_X86_64_PLT32	rt_mv_push-0x4
    5552:	jmp    53bb <botlish_fn_24+0x347b>
    5557:	mov    0x2a0(%rsp),%rsi
    555f:	mov    0x1b8(%rsp),%rdi
    5567:	call   556c <botlish_fn_24+0x362c>
			5568: R_X86_64_PLT32	rt_mv_pop-0x4
    556c:	mov    %rax,%rdx
    556f:	mov    %rax,0x220(%rsp)
    5577:	test   %rdx,%rax
    557a:	je     56e5 <botlish_fn_24+0x37a5>
    5580:	mov    0x220(%rsp),%rax
    5588:	mov    %rax,0xc8(%rsp)
    5590:	mov    0x220(%rsp),%rdx
    5598:	mov    0x1f0(%rsp),%rsi
    55a0:	mov    0x1b8(%rsp),%rdi
    55a8:	call   55ad <botlish_fn_24+0x366d>
			55a9: R_X86_64_PLT32	botlish_fn_2-0x4
    55ad:	mov    %rax,0x218(%rsp)
    55b5:	mov    %rax,0xd0(%rsp)
    55bd:	sar    $1,%rax
    55c0:	lea    0x30(%rax),%r15
    55c4:	shl    $1,%r15
    55c7:	or     $0x1,%r15
    55cb:	mov    %r15,0x28(%rsp)
    55d0:	mov    $0x29,%r14d
    55d6:	mov    0x1f0(%rsp),%rax
    55de:	mov    %rax,0x298(%rsp)
    55e6:	jmp    57ad <botlish_fn_24+0x386d>
    55eb:	mov    $0x5b,%r15d
    55f1:	movq   $0x5b,0x28(%rsp)
    55fa:	mov    $0x26,%r14d
    5600:	jmp    57ad <botlish_fn_24+0x386d>
    5605:	mov    $0x61,%r15d
    560b:	movq   $0x61,0x28(%rsp)
    5614:	mov    $0x25,%r14d
    561a:	jmp    57ad <botlish_fn_24+0x386d>
    561f:	mov    $0xcd,%r15d
    5625:	movq   $0xcd,0x28(%rsp)
    562e:	mov    $0x20,%r14d
    5634:	jmp    57ad <botlish_fn_24+0x386d>
    5639:	mov    $0xe9,%r15d
    563f:	movq   $0xe9,0x28(%rsp)
    5648:	mov    $0x1c,%r14d
    564e:	jmp    57ad <botlish_fn_24+0x386d>
    5653:	mov    $0xdd,%r15d
    5659:	movq   $0xdd,0x28(%rsp)
    5662:	mov    $0x18,%r14d
    5668:	jmp    57ad <botlish_fn_24+0x386d>
    566d:	cmp    $0xb2,%rcx
    5674:	je     5694 <botlish_fn_24+0x3754>
    567a:	mov    $0xf7,%r15d
    5680:	movq   $0xf7,0x28(%rsp)
    5689:	mov    $0x2,%r14d
    568f:	jmp    57ad <botlish_fn_24+0x386d>
    5694:	mov    $0xb7,%r15d
    569a:	movq   $0xb7,0x28(%rsp)
    56a3:	mov    $0x1,%r14d
    56a9:	jmp    57ad <botlish_fn_24+0x386d>
    56ae:	mov    0x20(%rax),%rsi
    56b2:	mov    0x8(%rsi),%rax
    56b6:	test   %rax,%rax
    56b9:	jne    5784 <botlish_fn_24+0x3844>
    56bf:	mov    $0x1,%edx
    56c4:	mov    0x1b8(%rsp),%rdi
    56cc:	call   56d1 <botlish_fn_24+0x3791>
			56cd: R_X86_64_PLT32	rt_list_get-0x4
    56d1:	mov    %rax,%rcx
    56d4:	mov    %rax,0x1d8(%rsp)
    56dc:	test   %rcx,%rax
    56df:	jne    5777 <botlish_fn_24+0x3837>
    56e5:	mov    0x1b8(%rsp),%rdi
    56ed:	call   56f2 <botlish_fn_24+0x37b2>
			56ee: R_X86_64_PLT32	rt_co_failed-0x4
    56f2:	mov    %rax,0x30(%rsp)
    56f7:	mov    %rax,%rsi
    56fa:	mov    0x1b8(%rsp),%rdi
    5702:	call   5707 <botlish_fn_24+0x37c7>
			5703: R_X86_64_PLT32	rt_co_resume0-0x4
    5707:	test   %rax,%rax
    570a:	je     572b <botlish_fn_24+0x37eb>
    5710:	mov    0x1b8(%rsp),%rdi
    5718:	mov    0x10(%rdi),%rax
    571c:	mov    (%rax),%rsi
    571f:	mov    0xf0(%rax),%rdx
    5726:	call   572b <botlish_fn_24+0x37eb>
			5727: R_X86_64_PLT32	rt_raise-0x4
    572b:	mov    0x1b8(%rsp),%rdi
    5733:	call   5738 <botlish_fn_24+0x37f8>
			5734: R_X86_64_PLT32	rt_declared_error-0x4
    5738:	cmp    $0x40000001,%rax
    573e:	je     5751 <botlish_fn_24+0x3811>
    5744:	mov    0x1b8(%rsp),%rdi
    574c:	jmp    5759 <botlish_fn_24+0x3819>
    5751:	mov    0x1b8(%rsp),%rdi
    5759:	mov    0x1b8(%rsp),%rdi
    5761:	call   5766 <botlish_fn_24+0x3826>
			5762: R_X86_64_PLT32	rt_declared_error-0x4
    5766:	cmp    $0x40000001,%rax
    576c:	jne    583a <botlish_fn_24+0x38fa>
    5772:	jmp    583a <botlish_fn_24+0x38fa>
    5777:	mov    0x1d8(%rsp),%rax
    577f:	jmp    5793 <botlish_fn_24+0x3853>
    5784:	mov    0x10(%rsi),%rax
    5788:	mov    (%rax),%rax
    578b:	mov    %rax,0x1d8(%rsp)
    5793:	mov    %rax,0x60(%rsp)
    5798:	mov    $0x45,%r15d
    579e:	movq   $0x45,0x28(%rsp)
    57a7:	mov    $0x3,%r14d
    57ad:	mov    0x2f8(%rsp),%rcx
    57b5:	mov    0x18(%rcx),%rax
    57b9:	test   %rax,%rax
    57bc:	je     5984 <botlish_fn_24+0x3a44>
    57c2:	mov    0x2f8(%rsp),%rcx
    57ca:	mov    0x10(%rcx),%rax
    57ce:	mov    %r15,0x10(%rax)
    57d2:	mov    %rbx,0x268(%rsp)
    57da:	mov    %r12,0x270(%rsp)
    57e2:	jmp    2bec <botlish_fn_24+0xcac>
    57e7:	mov    0x2f8(%rsp),%rcx
    57ef:	mov    0x10(%rcx),%rax
    57f3:	mov    0x8(%rax),%rax
    57f7:	mov    %rax,(%rsp)
    57fb:	mov    0x10(%rcx),%rcx
    57ff:	mov    (%rcx),%rcx
    5802:	mov    %rcx,0x8(%rsp)
    5807:	lea    0x118(%rsp),%rdx
    580f:	mov    %rax,0x118(%rsp)
    5817:	mov    %rcx,0x120(%rsp)
    581f:	mov    $0x2,%esi
    5824:	mov    0x1b8(%rsp),%rdi
    582c:	call   5831 <botlish_fn_24+0x38f1>
			582d: R_X86_64_PLT32	rt_list_new-0x4
    5831:	test   %rax,%rax
    5834:	jne    5871 <botlish_fn_24+0x3931>
    583a:	xor    %rax,%rax
    583d:	mov    0x300(%rsp),%rbx
    5845:	mov    0x308(%rsp),%r12
    584d:	mov    0x310(%rsp),%r13
    5855:	mov    0x318(%rsp),%r14
    585d:	mov    0x320(%rsp),%r15
    5865:	add    $0x330,%rsp
    586c:	mov    %rbp,%rsp
    586f:	pop    %rbp
    5870:	ret
    5871:	mov    0x300(%rsp),%rbx
    5879:	mov    0x308(%rsp),%r12
    5881:	mov    0x310(%rsp),%r13
    5889:	mov    0x318(%rsp),%r14
    5891:	mov    0x320(%rsp),%r15
    5899:	add    $0x330,%rsp
    58a0:	mov    %rbp,%rsp
    58a3:	pop    %rbp
    58a4:	ret
    58a5:	mov    $0x5,%edx
    58aa:	mov    %r15,%rcx
    58ad:	mov    0x2f8(%rsp),%rsi
    58b5:	mov    0x1b8(%rsp),%rdi
    58bd:	call   58c2 <botlish_fn_24+0x3982>
			58be: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    58c2:	jmp    2aa0 <botlish_fn_24+0xb60>
    58c7:	mov    $0x1,%edx
    58cc:	mov    0x2f8(%rsp),%rsi
    58d4:	mov    0x1b8(%rsp),%rdi
    58dc:	call   58e1 <botlish_fn_24+0x39a1>
			58dd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    58e1:	jmp    2ddd <botlish_fn_24+0xe9d>
    58e6:	mov    $0x3,%edx
    58eb:	mov    0x2f8(%rsp),%rsi
    58f3:	mov    0x1b8(%rsp),%rdi
    58fb:	call   5900 <botlish_fn_24+0x39c0>
			58fc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5900:	jmp    2e71 <botlish_fn_24+0xf31>
    5905:	mov    $0x1,%edx
    590a:	mov    %r12,%rsi
    590d:	mov    0x1b8(%rsp),%rdi
    5915:	call   591a <botlish_fn_24+0x39da>
			5916: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    591a:	mov    %r12,0x2e8(%rsp)
    5922:	jmp    38d1 <botlish_fn_24+0x1991>
    5927:	mov    $0x1,%edx
    592c:	mov    0x2b0(%rsp),%rsi
    5934:	mov    0x1b8(%rsp),%rdi
    593c:	call   5941 <botlish_fn_24+0x3a01>
			593d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5941:	jmp    4143 <botlish_fn_24+0x2203>
    5946:	mov    $0x1,%edx
    594b:	mov    0x290(%rsp),%rsi
    5953:	mov    0x1b8(%rsp),%rdi
    595b:	call   5960 <botlish_fn_24+0x3a20>
			595c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5960:	jmp    4456 <botlish_fn_24+0x2516>
    5965:	mov    $0x1,%edx
    596a:	mov    0x2e8(%rsp),%rsi
    5972:	mov    0x1b8(%rsp),%rdi
    597a:	call   597f <botlish_fn_24+0x3a3f>
			597b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    597f:	jmp    51cf <botlish_fn_24+0x328f>
    5984:	mov    0x2d0(%rsp),%rdx
    598c:	mov    %r15,%rcx
    598f:	mov    0x2f8(%rsp),%rsi
    5997:	mov    0x1b8(%rsp),%rdi
    599f:	call   59a4 <botlish_fn_24+0x3a64>
			59a0: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    59a4:	jmp    57d2 <botlish_fn_24+0x3892>
    59a9:	add    %al,(%rax)
    59ab:	add    %al,(%rax)
    59ad:	add    %al,(%rax)
    59af:	add    %al,(%rsi)
    59b1:	add    %al,(%rax)
    59b3:	add    %al,(%rax)
    59b5:	add    %al,(%rax)
    59b7:	add    %dl,(%rax,%rax,1)
    59ba:	add    %al,(%rax)
    59bc:	add    %al,(%rax)
    59be:	add    %al,(%rax)
    59c0:	ds add %al,(%rax)
    59c3:	add    %al,(%rax)
    59c5:	add    %al,(%rax)
    59c7:	add    %al,(%rbx)
    59c9:	add    %al,(%rax)
    59cb:	add    %al,(%rcx)
    59cd:	add    %al,(%rax)
    59cf:	.byte 0x80

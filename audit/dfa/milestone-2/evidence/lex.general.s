<botlish_fn_13>:
    20c8:	push   %rbp
    20c9:	mov    %rsp,%rbp
    20cc:	sub    $0x160,%rsp
    20d3:	mov    %rbx,0x130(%rsp)
    20db:	mov    %r12,0x138(%rsp)
    20e3:	mov    %r13,0x140(%rsp)
    20eb:	mov    %r14,0x148(%rsp)
    20f3:	mov    %r15,0x150(%rsp)
    20fb:	mov    %rdi,0xe0(%rsp)
    2103:	movq   $0x0,0x10(%rsp)
    210c:	movq   $0x0,0x18(%rsp)
    2115:	movq   $0x0,0x20(%rsp)
    211e:	movq   $0x0,0x28(%rsp)
    2127:	movq   $0x0,0x30(%rsp)
    2130:	mov    %rsi,(%rsp)
    2134:	mov    %rdx,0x8(%rsp)
    2139:	mov    %rdx,%rbx
    213c:	lea    0x38(%rsp),%r8
    2141:	mov    %rsi,0x38(%rsp)
    2146:	mov    $0xe,%esi
    214b:	mov    0x0(%rip),%rdx        # 2152 <botlish_fn_13+0x8a>
			214e: R_X86_64_GOTPCREL	botlish_entry_14-0x4
    2152:	mov    $0x1,%ecx
    2157:	mov    0xe0(%rsp),%rdi
    215f:	call   2164 <botlish_fn_13+0x9c>
			2160: R_X86_64_PLT32	rt_closure_new-0x4
    2164:	mov    %rax,(%rsp)
    2168:	mov    %rax,%rsi
    216b:	mov    0xe0(%rsp),%rdi
    2173:	call   2178 <botlish_fn_13+0xb0>
			2174: R_X86_64_PLT32	rt_co_create-0x4
    2178:	mov    %rax,0x120(%rsp)
    2180:	mov    %rax,(%rsp)
    2184:	mov    0x120(%rsp),%rsi
    218c:	mov    0xe0(%rsp),%rdi
    2194:	call   2199 <botlish_fn_13+0xd1>
			2195: R_X86_64_PLT32	rt_co_start-0x4
    2199:	test   %rax,%rax
    219c:	jne    21d5 <botlish_fn_13+0x10d>
    21a2:	mov    0xe0(%rsp),%rdi
    21aa:	call   21af <botlish_fn_13+0xe7>
			21ab: R_X86_64_PLT32	rt_declared_error-0x4
    21af:	cmp    $0x40000001,%rax
    21b5:	jne    2cf4 <botlish_fn_13+0xc2c>
    21bb:	mov    0x120(%rsp),%rsi
    21c3:	mov    0xe0(%rsp),%rdi
    21cb:	call   21d0 <botlish_fn_13+0x108>
			21cc: R_X86_64_PLT32	rt_co_release-0x4
    21d0:	jmp    2cf4 <botlish_fn_13+0xc2c>
    21d5:	mov    %rax,0x10(%rsp)
    21da:	mov    %rax,%r12
    21dd:	mov    $0x9,%esi
    21e2:	movq   $0x9,0x18(%rsp)
    21eb:	mov    $0x1,%edx
    21f0:	movq   $0x1,0x20(%rsp)
    21f9:	mov    0xe0(%rsp),%rdi
    2201:	call   2206 <botlish_fn_13+0x13e>
			2202: R_X86_64_PLT32	rt_mutarray_create-0x4
    2206:	mov    %rax,%rcx
    2209:	mov    %rax,%r13
    220c:	test   %rcx,%rax
    220f:	je     2cf4 <botlish_fn_13+0xc2c>
    2215:	mov    %r13,%rax
    2218:	mov    %rax,0x18(%rsp)
    221d:	mov    0x18(%rax),%rcx
    2221:	test   %rcx,%rcx
    2224:	je     2dd3 <botlish_fn_13+0xd0b>
    222a:	mov    %r13,%rax
    222d:	mov    %r12,%rcx
    2230:	mov    0x10(%rax),%rsi
    2234:	mov    %rcx,0x8(%rsi)
    2238:	mov    $0x8,%esi
    223d:	mov    %rsi,0x118(%rsp)
    2245:	mov    $0xffffffffffffffff,%r12
    224c:	lea    0x40(%rsp),%r14
    2251:	mov    %r14,0x110(%rsp)
    2259:	mov    0x0(%rip),%rdi        # 2260 <botlish_fn_13+0x198>
			225c: R_X86_64_GOTPCREL	botlish_entry_15-0x4
    2260:	mov    %rdi,0x108(%rsp)
    2268:	mov    %r13,%r15
    226b:	mov    0x10(%r15),%r8
    226f:	mov    (%r8),%rsi
    2272:	mov    %rsi,0x10(%rsp)
    2277:	mov    %rsi,0x100(%rsp)
    227f:	mov    0x10(%r15),%r10
    2283:	mov    0x8(%r10),%r13
    2287:	mov    %r13,0x20(%rsp)
    228c:	test   $0x1,%r13
    2293:	jne    22c1 <botlish_fn_13+0x1f9>
    2299:	mov    %r12,%rdx
    229c:	mov    %r13,%rsi
    229f:	mov    0xe0(%rsp),%rdi
    22a7:	call   22ac <botlish_fn_13+0x1e4>
			22a8: R_X86_64_PLT32	rt_int_cmp-0x4
    22ac:	mov    $0x2,%esi
    22b1:	test   %rax,%rax
    22b4:	cmove  0xc2c(%rip),%rsi        # 2ee8 <botlish_fn_13+0xe20>
    22bc:	jmp    22d2 <botlish_fn_13+0x20a>
    22c1:	mov    $0x2,%esi
    22c6:	cmp    $0xffffffffffffffff,%r13
    22ca:	cmove  0xc16(%rip),%rsi        # 2ee8 <botlish_fn_13+0xe20>
    22d2:	cmp    $0x6,%rsi
    22d6:	je     2d45 <botlish_fn_13+0xc7d>
    22dc:	mov    %r13,%rsi
    22df:	mov    0xe0(%rsp),%rdi
    22e7:	call   22ec <botlish_fn_13+0x224>
			22e8: R_X86_64_PLT32	botlish_fn_11-0x4
    22ec:	cmp    $0x6,%rax
    22f0:	je     2be9 <botlish_fn_13+0xb21>
    22f6:	mov    %r13,0x40(%rsp)
    22fb:	mov    $0xf,%esi
    2300:	mov    $0x1,%ecx
    2305:	mov    0x108(%rsp),%rdx
    230d:	mov    0xe0(%rsp),%rdi
    2315:	mov    0x110(%rsp),%r8
    231d:	call   2322 <botlish_fn_13+0x25a>
			231e: R_X86_64_PLT32	rt_closure_new-0x4
    2322:	mov    %rax,0x20(%rsp)
    2327:	mov    %rax,%rsi
    232a:	mov    0xe0(%rsp),%rdi
    2332:	call   2337 <botlish_fn_13+0x26f>
			2333: R_X86_64_PLT32	rt_co_create-0x4
    2337:	mov    %rax,0xf8(%rsp)
    233f:	mov    %rax,0x20(%rsp)
    2344:	mov    0xf8(%rsp),%rsi
    234c:	mov    0xe0(%rsp),%rdi
    2354:	call   2359 <botlish_fn_13+0x291>
			2355: R_X86_64_PLT32	rt_co_start-0x4
    2359:	test   %rax,%rax
    235c:	mov    %rax,%rcx
    235f:	jne    250b <botlish_fn_13+0x443>
    2365:	mov    0xe0(%rsp),%rdi
    236d:	call   2372 <botlish_fn_13+0x2aa>
			236e: R_X86_64_PLT32	rt_declared_error-0x4
    2372:	cmp    $0x1,%rax
    2376:	je     2441 <botlish_fn_13+0x379>
    237c:	mov    0xe0(%rsp),%rdi
    2384:	call   2389 <botlish_fn_13+0x2c1>
			2385: R_X86_64_PLT32	rt_declared_error-0x4
    2389:	cmp    $0x2,%rax
    238d:	jne    2cf4 <botlish_fn_13+0xc2c>
    2393:	xor    %rsi,%rsi
    2396:	mov    0xe0(%rsp),%rdi
    239e:	call   23a3 <botlish_fn_13+0x2db>
			239f: R_X86_64_PLT32	rt_declared_payload-0x4
    23a3:	mov    %rax,%rbx
    23a6:	mov    $0x1,%esi
    23ab:	mov    0xe0(%rsp),%rdi
    23b3:	call   23b8 <botlish_fn_13+0x2f0>
			23b4: R_X86_64_PLT32	rt_declared_payload-0x4
    23b8:	mov    %rax,%r12
    23bb:	mov    0xe0(%rsp),%rdi
    23c3:	call   23c8 <botlish_fn_13+0x300>
			23c4: R_X86_64_PLT32	rt_clear_declared_error-0x4
    23c8:	mov    0x120(%rsp),%rsi
    23d0:	mov    0xe0(%rsp),%rdi
    23d8:	call   23dd <botlish_fn_13+0x315>
			23d9: R_X86_64_PLT32	rt_co_release-0x4
    23dd:	mov    0xf8(%rsp),%rsi
    23e5:	mov    0xe0(%rsp),%rdi
    23ed:	call   23f2 <botlish_fn_13+0x32a>
			23ee: R_X86_64_PLT32	rt_co_release-0x4
    23f2:	mov    0xe0(%rsp),%rdi
    23fa:	mov    0x10(%rdi),%rax
    23fe:	mov    0x158(%rax),%rdx
    2405:	lea    0x68(%rsp),%r9
    240a:	mov    0x100(%rsp),%rsi
    2412:	mov    %rsi,0x68(%rsp)
    2417:	mov    %rbx,%rax
    241a:	mov    %rax,0x70(%rsp)
    241f:	mov    %r12,%rax
    2422:	mov    %rax,0x78(%rsp)
    2427:	mov    $0x5,%esi
    242c:	mov    $0x2,%ecx
    2431:	mov    $0x3,%r8d
    2437:	call   243c <botlish_fn_13+0x374>
			2438: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    243c:	jmp    2cf4 <botlish_fn_13+0xc2c>
    2441:	xor    %rsi,%rsi
    2444:	mov    0xe0(%rsp),%rdi
    244c:	call   2451 <botlish_fn_13+0x389>
			244d: R_X86_64_PLT32	rt_declared_payload-0x4
    2451:	mov    %rax,%r12
    2454:	mov    $0x1,%ebx
    2459:	mov    %rbx,%rsi
    245c:	mov    0xe0(%rsp),%rdi
    2464:	call   2469 <botlish_fn_13+0x3a1>
			2465: R_X86_64_PLT32	rt_declared_payload-0x4
    2469:	mov    %rax,%r13
    246c:	mov    $0x2,%esi
    2471:	mov    0xe0(%rsp),%rdi
    2479:	call   247e <botlish_fn_13+0x3b6>
			247a: R_X86_64_PLT32	rt_declared_payload-0x4
    247e:	mov    %rax,%r14
    2481:	mov    0xe0(%rsp),%rdi
    2489:	call   248e <botlish_fn_13+0x3c6>
			248a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    248e:	mov    0x120(%rsp),%rsi
    2496:	mov    0xe0(%rsp),%rdi
    249e:	call   24a3 <botlish_fn_13+0x3db>
			249f: R_X86_64_PLT32	rt_co_release-0x4
    24a3:	mov    0xf8(%rsp),%rsi
    24ab:	mov    0xe0(%rsp),%rdi
    24b3:	call   24b8 <botlish_fn_13+0x3f0>
			24b4: R_X86_64_PLT32	rt_co_release-0x4
    24b8:	mov    0xe0(%rsp),%rdi
    24c0:	mov    0x10(%rdi),%rax
    24c4:	mov    0x150(%rax),%rdx
    24cb:	lea    0x48(%rsp),%r9
    24d0:	mov    0x100(%rsp),%rsi
    24d8:	mov    %rsi,0x48(%rsp)
    24dd:	mov    %r12,%rax
    24e0:	mov    %rax,0x50(%rsp)
    24e5:	mov    %r13,%rax
    24e8:	mov    %rax,0x58(%rsp)
    24ed:	mov    %r14,%rax
    24f0:	mov    %rax,0x60(%rsp)
    24f5:	mov    $0x4,%r8d
    24fb:	mov    %rbx,%rcx
    24fe:	mov    %r8,%rsi
    2501:	call   2506 <botlish_fn_13+0x43e>
			2502: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2506:	jmp    2cf4 <botlish_fn_13+0xc2c>
    250b:	mov    0x18(%r15),%rax
    250f:	test   %rax,%rax
    2512:	je     2df0 <botlish_fn_13+0xd28>
    2518:	mov    0x10(%r15),%rax
    251c:	mov    %rcx,0x18(%rax)
    2520:	mov    $0x3,%r8d
    2526:	mov    %r8,0xf0(%rsp)
    252e:	mov    0xf8(%rsp),%rsi
    2536:	mov    0xe0(%rsp),%rdi
    253e:	call   2543 <botlish_fn_13+0x47b>
			253f: R_X86_64_PLT32	rt_co_done-0x4
    2543:	cmp    $0x6,%rax
    2547:	je     2997 <botlish_fn_13+0x8cf>
    254d:	mov    0x10(%r15),%rax
    2551:	mov    (%rax),%rsi
    2554:	mov    %rsi,0x28(%rsp)
    2559:	movq   $0x3,0x30(%rsp)
    2562:	test   $0x1,%rsi
    2569:	je     258c <botlish_fn_13+0x4c4>
    256f:	mov    %rsi,%rax
    2572:	add    $0x2,%rax
    2576:	mov    %rax,%r13
    2579:	seto   %cl
    257c:	test   %cl,%cl
    257e:	jne    258c <botlish_fn_13+0x4c4>
    2584:	mov    %r13,%rax
    2587:	jmp    25a4 <botlish_fn_13+0x4dc>
    258c:	mov    0xf0(%rsp),%rdx
    2594:	mov    0xe0(%rsp),%rdi
    259c:	call   25a1 <botlish_fn_13+0x4d9>
			259d: R_X86_64_PLT32	rt_int_add-0x4
    25a1:	mov    %rax,%r13
    25a4:	mov    %rax,0x28(%rsp)
    25a9:	mov    0x18(%r15),%rsi
    25ad:	test   %rsi,%rsi
    25b0:	je     2e0a <botlish_fn_13+0xd42>
    25b6:	mov    0x10(%r15),%rsi
    25ba:	mov    %r13,%rax
    25bd:	mov    %rax,(%rsi)
    25c0:	mov    0x120(%rsp),%rsi
    25c8:	mov    0xe0(%rsp),%rdi
    25d0:	call   25d5 <botlish_fn_13+0x50d>
			25d1: R_X86_64_PLT32	rt_co_resume0-0x4
    25d5:	mov    %rax,%rcx
    25d8:	mov    %rax,%r14
    25db:	test   %rcx,%rax
    25de:	jne    262c <botlish_fn_13+0x564>
    25e4:	mov    0xe0(%rsp),%rdi
    25ec:	call   25f1 <botlish_fn_13+0x529>
			25ed: R_X86_64_PLT32	rt_declared_error-0x4
    25f1:	cmp    $0x40000001,%rax
    25f7:	jne    2cf4 <botlish_fn_13+0xc2c>
    25fd:	mov    0x120(%rsp),%rsi
    2605:	mov    0xe0(%rsp),%rdi
    260d:	call   2612 <botlish_fn_13+0x54a>
			260e: R_X86_64_PLT32	rt_co_release-0x4
    2612:	mov    0xf8(%rsp),%rsi
    261a:	mov    0xe0(%rsp),%rdi
    2622:	call   2627 <botlish_fn_13+0x55f>
			2623: R_X86_64_PLT32	rt_co_release-0x4
    2627:	jmp    2cf4 <botlish_fn_13+0xc2c>
    262c:	mov    %r14,%rax
    262f:	mov    %rax,0x30(%rsp)
    2634:	mov    0x18(%r15),%rcx
    2638:	test   %rcx,%rcx
    263b:	je     2e27 <botlish_fn_13+0xd5f>
    2641:	mov    0x10(%r15),%rcx
    2645:	mov    %r14,%rax
    2648:	mov    %rax,0x8(%rcx)
    264c:	mov    0x100(%rsp),%rsi
    2654:	mov    %r13,%rax
    2657:	and    %rsi,%rax
    265a:	test   $0x1,%rax
    2660:	je     2683 <botlish_fn_13+0x5bb>
    2666:	mov    0x100(%rsp),%rsi
    266e:	mov    %r13,%rdx
    2671:	sub    %rsi,%rdx
    2674:	seto   %cl
    2677:	lea    0x1(%rdx),%rsi
    267b:	test   %cl,%cl
    267d:	je     269e <botlish_fn_13+0x5d6>
    2683:	mov    0x100(%rsp),%rdx
    268b:	mov    %r13,%rsi
    268e:	mov    0xe0(%rsp),%rdi
    2696:	call   269b <botlish_fn_13+0x5d3>
			2697: R_X86_64_PLT32	rt_int_sub-0x4
    269b:	mov    %rax,%rsi
    269e:	mov    %rsi,%rax
    26a1:	and    %rbx,%rax
    26a4:	test   $0x1,%rax
    26aa:	jne    26d5 <botlish_fn_13+0x60d>
    26b0:	mov    %rbx,%rdx
    26b3:	mov    0xe0(%rsp),%rdi
    26bb:	call   26c0 <botlish_fn_13+0x5f8>
			26bc: R_X86_64_PLT32	rt_int_cmp-0x4
    26c0:	mov    $0x2,%ecx
    26c5:	test   %rax,%rax
    26c8:	cmovge 0x818(%rip),%rcx        # 2ee8 <botlish_fn_13+0xe20>
    26d0:	jmp    26e5 <botlish_fn_13+0x61d>
    26d5:	mov    $0x2,%ecx
    26da:	cmp    %rbx,%rsi
    26dd:	cmovge 0x803(%rip),%rcx        # 2ee8 <botlish_fn_13+0xe20>
    26e5:	cmp    $0x6,%rcx
    26e9:	je     291a <botlish_fn_13+0x852>
    26ef:	lea    0x90(%rsp),%rcx
    26f7:	mov    %r14,%rax
    26fa:	mov    %rax,0x90(%rsp)
    2702:	mov    $0x4,%r14d
    2708:	mov    $0x1,%edx
    270d:	mov    %r14,%rsi
    2710:	mov    0xe0(%rsp),%rdi
    2718:	call   271d <botlish_fn_13+0x655>
			2719: R_X86_64_PLT32	rt_struct_new-0x4
    271d:	mov    %rax,0x30(%rsp)
    2722:	mov    %rax,%rdx
    2725:	mov    0xf8(%rsp),%rsi
    272d:	mov    0xe0(%rsp),%rdi
    2735:	call   273a <botlish_fn_13+0x672>
			2736: R_X86_64_PLT32	rt_co_resume-0x4
    273a:	test   %rax,%rax
    273d:	mov    %rax,%rcx
    2740:	jne    2900 <botlish_fn_13+0x838>
    2746:	mov    0xe0(%rsp),%rdi
    274e:	call   2753 <botlish_fn_13+0x68b>
			274f: R_X86_64_PLT32	rt_declared_error-0x4
    2753:	cmp    $0x1,%rax
    2757:	je     2828 <botlish_fn_13+0x760>
    275d:	mov    0xe0(%rsp),%rdi
    2765:	call   276a <botlish_fn_13+0x6a2>
			2766: R_X86_64_PLT32	rt_declared_error-0x4
    276a:	cmp    $0x2,%rax
    276e:	jne    2cf4 <botlish_fn_13+0xc2c>
    2774:	xor    %rsi,%rsi
    2777:	mov    0xe0(%rsp),%rdi
    277f:	call   2784 <botlish_fn_13+0x6bc>
			2780: R_X86_64_PLT32	rt_declared_payload-0x4
    2784:	mov    %rax,%r12
    2787:	mov    $0x1,%esi
    278c:	mov    0xe0(%rsp),%rdi
    2794:	call   2799 <botlish_fn_13+0x6d1>
			2795: R_X86_64_PLT32	rt_declared_payload-0x4
    2799:	mov    %rax,%rbx
    279c:	mov    0xe0(%rsp),%rdi
    27a4:	call   27a9 <botlish_fn_13+0x6e1>
			27a5: R_X86_64_PLT32	rt_clear_declared_error-0x4
    27a9:	mov    0x120(%rsp),%rsi
    27b1:	mov    0xe0(%rsp),%rdi
    27b9:	call   27be <botlish_fn_13+0x6f6>
			27ba: R_X86_64_PLT32	rt_co_release-0x4
    27be:	mov    0xf8(%rsp),%rsi
    27c6:	mov    0xe0(%rsp),%rdi
    27ce:	call   27d3 <botlish_fn_13+0x70b>
			27cf: R_X86_64_PLT32	rt_co_release-0x4
    27d3:	mov    0xe0(%rsp),%rdi
    27db:	mov    0x10(%rdi),%rax
    27df:	mov    0x158(%rax),%rdx
    27e6:	lea    0xb8(%rsp),%r9
    27ee:	mov    %r13,0xb8(%rsp)
    27f6:	mov    %r12,%rax
    27f9:	mov    %rax,0xc0(%rsp)
    2801:	mov    %rbx,%rax
    2804:	mov    %rax,0xc8(%rsp)
    280c:	mov    $0x5,%esi
    2811:	mov    $0x2,%ecx
    2816:	mov    0xf0(%rsp),%r8
    281e:	call   2823 <botlish_fn_13+0x75b>
			281f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2823:	jmp    2cf4 <botlish_fn_13+0xc2c>
    2828:	xor    %rsi,%rsi
    282b:	mov    0xe0(%rsp),%rdi
    2833:	call   2838 <botlish_fn_13+0x770>
			2834: R_X86_64_PLT32	rt_declared_payload-0x4
    2838:	mov    %rax,%r12
    283b:	mov    $0x1,%ebx
    2840:	mov    %rbx,%rsi
    2843:	mov    0xe0(%rsp),%rdi
    284b:	call   2850 <botlish_fn_13+0x788>
			284c: R_X86_64_PLT32	rt_declared_payload-0x4
    2850:	mov    %rax,%r15
    2853:	mov    $0x2,%esi
    2858:	mov    0xe0(%rsp),%rdi
    2860:	call   2865 <botlish_fn_13+0x79d>
			2861: R_X86_64_PLT32	rt_declared_payload-0x4
    2865:	mov    %rax,0xe8(%rsp)
    286d:	mov    0xe0(%rsp),%rdi
    2875:	call   287a <botlish_fn_13+0x7b2>
			2876: R_X86_64_PLT32	rt_clear_declared_error-0x4
    287a:	mov    0x120(%rsp),%rsi
    2882:	mov    0xe0(%rsp),%rdi
    288a:	call   288f <botlish_fn_13+0x7c7>
			288b: R_X86_64_PLT32	rt_co_release-0x4
    288f:	mov    0xf8(%rsp),%rsi
    2897:	mov    0xe0(%rsp),%rdi
    289f:	call   28a4 <botlish_fn_13+0x7dc>
			28a0: R_X86_64_PLT32	rt_co_release-0x4
    28a4:	mov    0xe0(%rsp),%rdi
    28ac:	mov    0x10(%rdi),%rax
    28b0:	mov    0x150(%rax),%rdx
    28b7:	lea    0x98(%rsp),%r9
    28bf:	mov    %r13,0x98(%rsp)
    28c7:	mov    %r12,%rax
    28ca:	mov    %rax,0xa0(%rsp)
    28d2:	mov    %r15,%rax
    28d5:	mov    %rax,0xa8(%rsp)
    28dd:	mov    0xe8(%rsp),%rax
    28e5:	mov    %rax,0xb0(%rsp)
    28ed:	mov    %rbx,%rcx
    28f0:	mov    %r14,%r8
    28f3:	mov    %r8,%rsi
    28f6:	call   28fb <botlish_fn_13+0x833>
			28f7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    28fb:	jmp    2cf4 <botlish_fn_13+0xc2c>
    2900:	mov    0x18(%r15),%rax
    2904:	test   %rax,%rax
    2907:	je     2e47 <botlish_fn_13+0xd7f>
    290d:	mov    0x10(%r15),%rax
    2911:	mov    %rcx,0x18(%rax)
    2915:	jmp    252e <botlish_fn_13+0x466>
    291a:	mov    0x120(%rsp),%rsi
    2922:	mov    0xe0(%rsp),%rdi
    292a:	call   292f <botlish_fn_13+0x867>
			292b: R_X86_64_PLT32	rt_co_release-0x4
    292f:	mov    0xf8(%rsp),%rsi
    2937:	mov    0xe0(%rsp),%rdi
    293f:	call   2944 <botlish_fn_13+0x87c>
			2940: R_X86_64_PLT32	rt_co_release-0x4
    2944:	mov    0xe0(%rsp),%rdi
    294c:	mov    0x10(%rdi),%rsi
    2950:	mov    0x160(%rsi),%rdx
    2957:	lea    0x80(%rsp),%r9
    295f:	mov    0x100(%rsp),%rsi
    2967:	mov    %rsi,0x80(%rsp)
    296f:	mov    %rbx,0x88(%rsp)
    2977:	mov    $0x2,%r8d
    297d:	mov    0xf0(%rsp),%rcx
    2985:	mov    0x118(%rsp),%rsi
    298d:	call   2992 <botlish_fn_13+0x8ca>
			298e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2992:	jmp    2cf4 <botlish_fn_13+0xc2c>
    2997:	mov    0xf8(%rsp),%rsi
    299f:	mov    0xe0(%rsp),%rdi
    29a7:	call   29ac <botlish_fn_13+0x8e4>
			29a8: R_X86_64_PLT32	rt_co_release-0x4
    29ac:	mov    0x10(%r15),%rdi
    29b0:	mov    0x18(%rdi),%rsi
    29b4:	test   $0x1,%rsi
    29bb:	jne    29e8 <botlish_fn_13+0x920>
    29c1:	mov    $0x1,%edx
    29c6:	mov    0xe0(%rsp),%rdi
    29ce:	call   29d3 <botlish_fn_13+0x90b>
			29cf: R_X86_64_PLT32	rt_int_cmp-0x4
    29d3:	mov    $0x2,%esi
    29d8:	test   %rax,%rax
    29db:	cmove  0x505(%rip),%rsi        # 2ee8 <botlish_fn_13+0xe20>
    29e3:	jmp    29fc <botlish_fn_13+0x934>
    29e8:	mov    %rsi,%r11
    29eb:	mov    $0x2,%esi
    29f0:	cmp    $0x1,%r11
    29f4:	cmove  0x4ec(%rip),%rsi        # 2ee8 <botlish_fn_13+0xe20>
    29fc:	cmp    $0x6,%rsi
    2a00:	jne    2b64 <botlish_fn_13+0xa9c>
    2a06:	mov    0x10(%r15),%rax
    2a0a:	mov    0x8(%rax),%rsi
    2a0e:	test   $0x1,%rsi
    2a15:	jne    2a40 <botlish_fn_13+0x978>
    2a1b:	mov    %r12,%rdx
    2a1e:	mov    0xe0(%rsp),%rdi
    2a26:	call   2a2b <botlish_fn_13+0x963>
			2a27: R_X86_64_PLT32	rt_int_cmp-0x4
    2a2b:	mov    $0x2,%ecx
    2a30:	test   %rax,%rax
    2a33:	cmove  0x4ad(%rip),%rcx        # 2ee8 <botlish_fn_13+0xe20>
    2a3b:	jmp    2a51 <botlish_fn_13+0x989>
    2a40:	mov    $0x2,%ecx
    2a45:	cmp    $0xffffffffffffffff,%rsi
    2a49:	cmove  0x497(%rip),%rcx        # 2ee8 <botlish_fn_13+0xe20>
    2a51:	cmp    $0x6,%rcx
    2a55:	je     2b64 <botlish_fn_13+0xa9c>
    2a5b:	movq   $0x1,0x10(%rsp)
    2a64:	mov    0x10(%r15),%rax
    2a68:	mov    (%rax),%rsi
    2a6b:	mov    %rsi,0x20(%rsp)
    2a70:	movq   $0x3,0x28(%rsp)
    2a79:	test   $0x1,%rsi
    2a80:	je     2a98 <botlish_fn_13+0x9d0>
    2a86:	mov    %rsi,%rcx
    2a89:	add    $0x2,%rcx
    2a8d:	seto   %al
    2a90:	test   %al,%al
    2a92:	je     2ab0 <botlish_fn_13+0x9e8>
    2a98:	mov    0xf0(%rsp),%rdx
    2aa0:	mov    0xe0(%rsp),%rdi
    2aa8:	call   2aad <botlish_fn_13+0x9e5>
			2aa9: R_X86_64_PLT32	rt_int_add-0x4
    2aad:	mov    %rax,%rcx
    2ab0:	mov    0x18(%r15),%rax
    2ab4:	test   %rax,%rax
    2ab7:	je     2e61 <botlish_fn_13+0xd99>
    2abd:	mov    0x10(%r15),%rax
    2ac1:	mov    %rcx,(%rax)
    2ac4:	movq   $0x3,0x10(%rsp)
    2acd:	mov    0x120(%rsp),%rsi
    2ad5:	mov    0xe0(%rsp),%rdi
    2add:	call   2ae2 <botlish_fn_13+0xa1a>
			2ade: R_X86_64_PLT32	rt_co_resume0-0x4
    2ae2:	test   %rax,%rax
    2ae5:	mov    %rax,%rcx
    2ae8:	jne    2b4f <botlish_fn_13+0xa87>
    2aee:	mov    0xe0(%rsp),%rdi
    2af6:	call   2afb <botlish_fn_13+0xa33>
			2af7: R_X86_64_PLT32	rt_declared_error-0x4
    2afb:	cmp    $0x40000001,%rax
    2b01:	jne    2b1c <botlish_fn_13+0xa54>
    2b07:	mov    0x120(%rsp),%rsi
    2b0f:	mov    0xe0(%rsp),%rdi
    2b17:	call   2b1c <botlish_fn_13+0xa54>
			2b18: R_X86_64_PLT32	rt_co_release-0x4
    2b1c:	mov    0xe0(%rsp),%rdi
    2b24:	call   2b29 <botlish_fn_13+0xa61>
			2b25: R_X86_64_PLT32	rt_declared_error-0x4
    2b29:	cmp    $0x40000001,%rax
    2b2f:	jne    2cf4 <botlish_fn_13+0xc2c>
    2b35:	mov    0x120(%rsp),%rsi
    2b3d:	mov    0xe0(%rsp),%rdi
    2b45:	call   2b4a <botlish_fn_13+0xa82>
			2b46: R_X86_64_PLT32	rt_co_release-0x4
    2b4a:	jmp    2cf4 <botlish_fn_13+0xc2c>
    2b4f:	mov    0x18(%r15),%rax
    2b53:	test   %rax,%rax
    2b56:	je     2e7b <botlish_fn_13+0xdb3>
    2b5c:	mov    0x10(%r15),%rax
    2b60:	mov    %rcx,0x8(%rax)
    2b64:	mov    $0x5,%r13d
    2b6a:	movq   $0x5,0x10(%rsp)
    2b73:	mov    0x10(%r15),%rsi
    2b77:	mov    0x10(%rsi),%rsi
    2b7b:	mov    %rsi,0x20(%rsp)
    2b80:	movq   $0x3,0x28(%rsp)
    2b89:	test   $0x1,%rsi
    2b90:	jne    2ba3 <botlish_fn_13+0xadb>
    2b96:	mov    0xf0(%rsp),%rdx
    2b9e:	jmp    2bbf <botlish_fn_13+0xaf7>
    2ba3:	mov    %rsi,%rcx
    2ba6:	add    $0x2,%rcx
    2baa:	seto   %r10b
    2bae:	test   %r10b,%r10b
    2bb1:	je     2bcf <botlish_fn_13+0xb07>
    2bb7:	mov    0xf0(%rsp),%rdx
    2bbf:	mov    0xe0(%rsp),%rdi
    2bc7:	call   2bcc <botlish_fn_13+0xb04>
			2bc8: R_X86_64_PLT32	rt_int_add-0x4
    2bcc:	mov    %rax,%rcx
    2bcf:	mov    0x18(%r15),%rax
    2bd3:	test   %rax,%rax
    2bd6:	je     2e98 <botlish_fn_13+0xdd0>
    2bdc:	mov    0x10(%r15),%rax
    2be0:	mov    %rcx,0x10(%rax)
    2be4:	jmp    226b <botlish_fn_13+0x1a3>
    2be9:	movq   $0x1,0x20(%rsp)
    2bf2:	mov    $0x3,%edx
    2bf7:	mov    %rdx,%r13
    2bfa:	movq   $0x3,0x28(%rsp)
    2c03:	mov    0x100(%rsp),%rsi
    2c0b:	test   $0x1,%rsi
    2c12:	jne    2c25 <botlish_fn_13+0xb5d>
    2c18:	mov    0x100(%rsp),%rsi
    2c20:	jmp    2c47 <botlish_fn_13+0xb7f>
    2c25:	mov    0x100(%rsp),%rsi
    2c2d:	mov    %rsi,%rcx
    2c30:	add    $0x2,%rcx
    2c34:	seto   %al
    2c37:	test   %al,%al
    2c39:	je     2c5a <botlish_fn_13+0xb92>
    2c3f:	mov    0x100(%rsp),%rsi
    2c47:	mov    %r13,%rdx
    2c4a:	mov    0xe0(%rsp),%rdi
    2c52:	call   2c57 <botlish_fn_13+0xb8f>
			2c53: R_X86_64_PLT32	rt_int_add-0x4
    2c57:	mov    %rax,%rcx
    2c5a:	mov    0x18(%r15),%rax
    2c5e:	test   %rax,%rax
    2c61:	je     2eb0 <botlish_fn_13+0xde8>
    2c67:	mov    0x10(%r15),%rax
    2c6b:	mov    %rcx,(%rax)
    2c6e:	movq   $0x3,0x10(%rsp)
    2c77:	mov    0x120(%rsp),%rsi
    2c7f:	mov    0xe0(%rsp),%rdi
    2c87:	call   2c8c <botlish_fn_13+0xbc4>
			2c88: R_X86_64_PLT32	rt_co_resume0-0x4
    2c8c:	test   %rax,%rax
    2c8f:	mov    %rax,%rcx
    2c92:	jne    2d2b <botlish_fn_13+0xc63>
    2c98:	mov    0xe0(%rsp),%rdi
    2ca0:	call   2ca5 <botlish_fn_13+0xbdd>
			2ca1: R_X86_64_PLT32	rt_declared_error-0x4
    2ca5:	cmp    $0x40000001,%rax
    2cab:	jne    2cc6 <botlish_fn_13+0xbfe>
    2cb1:	mov    0x120(%rsp),%rsi
    2cb9:	mov    0xe0(%rsp),%rdi
    2cc1:	call   2cc6 <botlish_fn_13+0xbfe>
			2cc2: R_X86_64_PLT32	rt_co_release-0x4
    2cc6:	mov    0xe0(%rsp),%rdi
    2cce:	call   2cd3 <botlish_fn_13+0xc0b>
			2ccf: R_X86_64_PLT32	rt_declared_error-0x4
    2cd3:	cmp    $0x40000001,%rax
    2cd9:	jne    2cf4 <botlish_fn_13+0xc2c>
    2cdf:	mov    0x120(%rsp),%rsi
    2ce7:	mov    0xe0(%rsp),%rdi
    2cef:	call   2cf4 <botlish_fn_13+0xc2c>
			2cf0: R_X86_64_PLT32	rt_co_release-0x4
    2cf4:	xor    %rax,%rax
    2cf7:	mov    0x130(%rsp),%rbx
    2cff:	mov    0x138(%rsp),%r12
    2d07:	mov    0x140(%rsp),%r13
    2d0f:	mov    0x148(%rsp),%r14
    2d17:	mov    0x150(%rsp),%r15
    2d1f:	add    $0x160,%rsp
    2d26:	mov    %rbp,%rsp
    2d29:	pop    %rbp
    2d2a:	ret
    2d2b:	mov    0x18(%r15),%rax
    2d2f:	test   %rax,%rax
    2d32:	je     2eca <botlish_fn_13+0xe02>
    2d38:	mov    0x10(%r15),%rax
    2d3c:	mov    %rcx,0x8(%rax)
    2d40:	jmp    226b <botlish_fn_13+0x1a3>
    2d45:	mov    0x120(%rsp),%rsi
    2d4d:	mov    0xe0(%rsp),%rdi
    2d55:	call   2d5a <botlish_fn_13+0xc92>
			2d56: R_X86_64_PLT32	rt_co_release-0x4
    2d5a:	mov    0x10(%r15),%rax
    2d5e:	mov    0x10(%rax),%rax
    2d62:	mov    %rax,(%rsp)
    2d66:	mov    0x10(%r15),%rcx
    2d6a:	mov    (%rcx),%rdx
    2d6d:	mov    %rdx,0x8(%rsp)
    2d72:	lea    0xd0(%rsp),%rcx
    2d7a:	mov    %rax,0xd0(%rsp)
    2d82:	mov    %rdx,0xd8(%rsp)
    2d8a:	xor    %rsi,%rsi
    2d8d:	mov    $0x2,%edx
    2d92:	mov    0xe0(%rsp),%rdi
    2d9a:	call   2d9f <botlish_fn_13+0xcd7>
			2d9b: R_X86_64_PLT32	rt_struct_new-0x4
    2d9f:	mov    0x130(%rsp),%rbx
    2da7:	mov    0x138(%rsp),%r12
    2daf:	mov    0x140(%rsp),%r13
    2db7:	mov    0x148(%rsp),%r14
    2dbf:	mov    0x150(%rsp),%r15
    2dc7:	add    $0x160,%rsp
    2dce:	mov    %rbp,%rsp
    2dd1:	pop    %rbp
    2dd2:	ret
    2dd3:	mov    $0x3,%edx
    2dd8:	mov    %r12,%rcx
    2ddb:	mov    %r13,%rsi
    2dde:	mov    0xe0(%rsp),%rdi
    2de6:	call   2deb <botlish_fn_13+0xd23>
			2de7: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2deb:	jmp    2238 <botlish_fn_13+0x170>
    2df0:	mov    $0x7,%edx
    2df5:	mov    %r15,%rsi
    2df8:	mov    0xe0(%rsp),%rdi
    2e00:	call   2e05 <botlish_fn_13+0xd3d>
			2e01: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2e05:	jmp    2520 <botlish_fn_13+0x458>
    2e0a:	mov    $0x1,%edx
    2e0f:	mov    %r13,%rcx
    2e12:	mov    %r15,%rsi
    2e15:	mov    0xe0(%rsp),%rdi
    2e1d:	call   2e22 <botlish_fn_13+0xd5a>
			2e1e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2e22:	jmp    25c0 <botlish_fn_13+0x4f8>
    2e27:	mov    %r14,%rcx
    2e2a:	mov    0xf0(%rsp),%rdx
    2e32:	mov    %r15,%rsi
    2e35:	mov    0xe0(%rsp),%rdi
    2e3d:	call   2e42 <botlish_fn_13+0xd7a>
			2e3e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2e42:	jmp    264c <botlish_fn_13+0x584>
    2e47:	mov    $0x7,%edx
    2e4c:	mov    %r15,%rsi
    2e4f:	mov    0xe0(%rsp),%rdi
    2e57:	call   2e5c <botlish_fn_13+0xd94>
			2e58: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2e5c:	jmp    252e <botlish_fn_13+0x466>
    2e61:	mov    $0x1,%edx
    2e66:	mov    %r15,%rsi
    2e69:	mov    0xe0(%rsp),%rdi
    2e71:	call   2e76 <botlish_fn_13+0xdae>
			2e72: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2e76:	jmp    2ac4 <botlish_fn_13+0x9fc>
    2e7b:	mov    0xf0(%rsp),%rdx
    2e83:	mov    %r15,%rsi
    2e86:	mov    0xe0(%rsp),%rdi
    2e8e:	call   2e93 <botlish_fn_13+0xdcb>
			2e8f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2e93:	jmp    2b64 <botlish_fn_13+0xa9c>
    2e98:	mov    %r13,%rdx
    2e9b:	mov    %r15,%rsi
    2e9e:	mov    0xe0(%rsp),%rdi
    2ea6:	call   2eab <botlish_fn_13+0xde3>
			2ea7: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2eab:	jmp    226b <botlish_fn_13+0x1a3>
    2eb0:	mov    $0x1,%edx
    2eb5:	mov    %r15,%rsi
    2eb8:	mov    0xe0(%rsp),%rdi
    2ec0:	call   2ec5 <botlish_fn_13+0xdfd>
			2ec1: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2ec5:	jmp    2c6e <botlish_fn_13+0xba6>
    2eca:	mov    %r13,%rdx
    2ecd:	mov    %r15,%rsi
    2ed0:	mov    0xe0(%rsp),%rdi
    2ed8:	call   2edd <botlish_fn_13+0xe15>
			2ed9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    2edd:	jmp    226b <botlish_fn_13+0x1a3>
    2ee2:	add    %al,(%rax)
    2ee4:	add    %al,(%rax)
    2ee6:	add    %al,(%rax)
    2ee8:	(bad)
    2ee9:	add    %al,(%rax)
    2eeb:	add    %al,(%rax)
    2eed:	add    %al,(%rax)
	...

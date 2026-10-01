; extracted from: git show bf40b58:audit/native-scalar-asm/bench/refined-checks.asm
; compiler revision (that regeneration's README.md): 569ca4ed71c8744dcf39b7754725af7011f76517

0000000000002310 <botlish_fn_24: check<generic>>:
    2310:	push   rbp
    2311:	mov    rbp,rsp
    2314:	sub    rsp,0x80
    231b:	mov    QWORD PTR [rsp+0x50],rbx
    2320:	mov    QWORD PTR [rsp+0x58],r12
    2325:	mov    QWORD PTR [rsp+0x60],r13
    232a:	mov    QWORD PTR [rsp+0x68],r14
    232f:	mov    QWORD PTR [rsp+0x70],r15
    2334:	mov    r14,rdi
    2337:	mov    QWORD PTR [rsp+0x28],0x0
    2340:	mov    QWORD PTR [rsp+0x30],0x0
    2349:	mov    QWORD PTR [rsp],rsi
    234d:	mov    r15,rsi
    2350:	mov    QWORD PTR [rsp+0x8],rdx
    2355:	mov    QWORD PTR [rsp+0x10],rcx
    235a:	mov    r12,rcx
    235d:	mov    QWORD PTR [rsp+0x18],r8
    2362:	mov    r13,r8
    2365:	mov    QWORD PTR [rsp+0x20],r9
    236a:	mov    rbx,r9
    236d:	mov    QWORD PTR [rsp+0x38],rdx
    2372:	test   rsi,0x1
    2379:	mov    r15,rsi
    237c:	jne    23a7 <botlish_fn_24+0x97>
    2382:	mov    edx,0x1
    2387:	mov    rsi,r15
    238a:	mov    rdi,r14
    238d:	call   2392 <botlish_fn_24+0x82>
			238e: R_X86_64_PLT32	rt_int_cmp-0x4
    2392:	mov    ecx,0x2
    2397:	test   rax,rax
    239a:	cmovle rcx,QWORD PTR [rip+0x19e]        # 2540 <botlish_fn_24+0x230>
    23a2:	jmp    23bb <botlish_fn_24+0xab>
    23a7:	mov    ecx,0x2
    23ac:	mov    rsi,r15
    23af:	cmp    rsi,0x1
    23b3:	cmovle rcx,QWORD PTR [rip+0x185]        # 2540 <botlish_fn_24+0x230>
    23bb:	cmp    rcx,0x6
    23bf:	je     250f <botlish_fn_24+0x1ff>
    23c5:	mov    rdx,r12
    23c8:	mov    rsi,rbx
    23cb:	mov    rdi,r14
    23ce:	call   23d3 <botlish_fn_24+0xc3>
			23cf: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_emailish<generic>
    23d3:	test   rax,rax
    23d6:	jne    2404 <botlish_fn_24+0xf4>
    23dc:	xor    rax,rax
    23df:	mov    rbx,QWORD PTR [rsp+0x50]
    23e4:	mov    r12,QWORD PTR [rsp+0x58]
    23e9:	mov    r13,QWORD PTR [rsp+0x60]
    23ee:	mov    r14,QWORD PTR [rsp+0x68]
    23f3:	mov    r15,QWORD PTR [rsp+0x70]
    23f8:	add    rsp,0x80
    23ff:	mov    rsp,rbp
    2402:	pop    rbp
    2403:	ret
    2404:	cmp    rax,0x6
    2408:	je     2426 <botlish_fn_24+0x116>
    240e:	mov    edx,0x1
    2413:	mov    QWORD PTR [rsp+0x28],0x1
    241c:	mov    QWORD PTR [rsp+0x40],rdx
    2421:	jmp    2439 <botlish_fn_24+0x129>
    2426:	mov    edx,0x3
    242b:	mov    QWORD PTR [rsp+0x40],rdx
    2430:	mov    QWORD PTR [rsp+0x28],0x3
    2439:	mov    edx,0x3
    243e:	mov    QWORD PTR [rsp+0x30],0x3
    2447:	mov    rsi,r15
    244a:	test   rsi,0x1
    2451:	jne    245f <botlish_fn_24+0x14f>
    2457:	mov    rsi,r15
    245a:	jmp    248e <botlish_fn_24+0x17e>
    245f:	mov    rsi,r15
    2462:	mov    rax,rsi
    2465:	sub    rax,0x3
    2469:	seto   cl
    246c:	add    rax,0x1
    2473:	test   cl,cl
    2475:	je     2483 <botlish_fn_24+0x173>
    247b:	mov    rsi,r15
    247e:	jmp    248e <botlish_fn_24+0x17e>
    2483:	mov    rsi,rax
    2486:	mov    r15,rax
    2489:	jmp    249c <botlish_fn_24+0x18c>
    248e:	mov    rdi,r14
    2491:	call   2496 <botlish_fn_24+0x186>
			2492: R_X86_64_PLT32	rt_int_sub-0x4
    2496:	mov    rsi,rax
    2499:	mov    r15,rax
    249c:	mov    QWORD PTR [rsp],rsi
    24a0:	mov    rdx,QWORD PTR [rsp+0x40]
    24a5:	mov    rsi,QWORD PTR [rsp+0x38]
    24aa:	mov    rdi,rsi
    24ad:	and    rdi,rdx
    24b0:	test   rdi,0x1
    24b7:	je     24dc <botlish_fn_24+0x1cc>
    24bd:	lea    r8,[rdx-0x1]
    24c1:	mov    rax,rsi
    24c4:	add    rax,r8
    24c7:	seto   r9b
    24cb:	test   r9b,r9b
    24ce:	jne    24dc <botlish_fn_24+0x1cc>
    24d4:	mov    rsi,r15
    24d7:	jmp    24e7 <botlish_fn_24+0x1d7>
    24dc:	mov    rdi,r14
    24df:	call   24e4 <botlish_fn_24+0x1d4>
			24e0: R_X86_64_PLT32	rt_int_add-0x4
    24e4:	mov    rsi,r15
    24e7:	mov    rsi,r15
    24ea:	mov    QWORD PTR [rsp],rsi
    24ee:	mov    QWORD PTR [rsp+0x8],rax
    24f3:	mov    QWORD PTR [rsp+0x10],r12
    24f8:	mov    r8,r13
    24fb:	mov    QWORD PTR [rsp+0x18],r8
    2500:	mov    QWORD PTR [rsp+0x20],rbx
    2505:	mov    QWORD PTR [rsp+0x38],rax
    250a:	jmp    2372 <botlish_fn_24+0x62>
    250f:	mov    rax,QWORD PTR [rsp+0x38]
    2514:	mov    rbx,QWORD PTR [rsp+0x50]
    2519:	mov    r12,QWORD PTR [rsp+0x58]
    251e:	mov    r13,QWORD PTR [rsp+0x60]
    2523:	mov    r14,QWORD PTR [rsp+0x68]
    2528:	mov    r15,QWORD PTR [rsp+0x70]
    252d:	add    rsp,0x80
    2534:	mov    rsp,rbp
    2537:	pop    rbp
    2538:	ret
    2539:	add    BYTE PTR [rax],al
    253b:	add    BYTE PTR [rax],al
    253d:	add    BYTE PTR [rax],al
    253f:	add    BYTE PTR [rsi],al
    2541:	add    BYTE PTR [rax],al
    2543:	add    BYTE PTR [rax],al
    2545:	add    BYTE PTR [rax],al
	...

0000000000002548 <botlish_entry_24: check<generic>>:
    2548:	push   rbp
    2549:	mov    rbp,rsp
    254c:	mov    rsi,QWORD PTR [rdx]
    254f:	mov    r10,QWORD PTR [rdx+0x8]
    2553:	mov    rcx,QWORD PTR [rdx+0x10]
    2557:	mov    r8,QWORD PTR [rdx+0x18]
    255b:	mov    r9,QWORD PTR [rdx+0x20]
    255f:	mov    rdx,r10
    2562:	call   2567 <botlish_entry_24+0x1f>
			2563: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<generic>
    2567:	mov    rsp,rbp
    256a:	pop    rbp
    256b:	ret

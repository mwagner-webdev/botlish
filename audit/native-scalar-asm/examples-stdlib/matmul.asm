; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5271  (per function: 944 857 609 732 718 844 567)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> dot<list<int>, list<list<int>>, int, int, int, int>
;   botlish_fn_2 / botlish_entry_2 -> product_row<list<int>, list<list<int>>, int, int, list<never>>
;   botlish_fn_3 / botlish_entry_3 -> product_row<list<int>, list<list<int>>, int, int, list<int>>
;   botlish_fn_4 / botlish_entry_4 -> product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
;   botlish_fn_5 / botlish_entry_5 -> product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
;   botlish_fn_6 / botlish_entry_6 -> matmul<list<list<int>>, list<list<int>>>


matmul.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0xc0
       b:	mov    QWORD PTR [rsp+0x90],rbx
      13:	mov    QWORD PTR [rsp+0x98],r12
      1b:	mov    QWORD PTR [rsp+0xa0],r13
      23:	mov    QWORD PTR [rsp+0xa8],r14
      2b:	mov    QWORD PTR [rsp+0xb0],r15
      33:	mov    r12,QWORD PTR [rdi]
      36:	mov    rax,QWORD PTR [rdi+0x8]
      3a:	lea    rcx,[r12+0x28]
      3f:	cmp    rcx,rax
      42:	ja     329 <botlish_fn_0+0x329>
      48:	lea    rax,[r12+0x28]
      4d:	mov    QWORD PTR [rdi],rax
      50:	mov    r13,rdi
      53:	mov    QWORD PTR [r12],0x0
      5b:	mov    QWORD PTR [r12+0x8],0x0
      64:	mov    QWORD PTR [r12+0x10],0x0
      6d:	mov    QWORD PTR [r12+0x18],0x0
      76:	mov    QWORD PTR [r12+0x20],0x0
      7f:	mov    esi,0x3
      84:	mov    QWORD PTR [r12],0x3
      8c:	mov    QWORD PTR [r12+0x8],0x5
      95:	mov    QWORD PTR [r12+0x10],0x7
      9e:	lea    rdx,[rsp]
      a2:	mov    QWORD PTR [rsp],0x3
      aa:	mov    QWORD PTR [rsp+0x8],0x5
      b3:	mov    QWORD PTR [rsp+0x10],0x7
      bc:	mov    rdi,r13
      bf:	call   c4 <botlish_fn_0+0xc4>
			c0: R_X86_64_PLT32	rt_list_new-0x4
      c4:	test   rax,rax
      c7:	jne    d5 <botlish_fn_0+0xd5>
      cd:	mov    rdi,r13
      d0:	jmp    2b2 <botlish_fn_0+0x2b2>
      d5:	mov    QWORD PTR [r12],rax
      d9:	mov    rbx,rax
      dc:	mov    QWORD PTR [r12+0x8],0x9
      e5:	mov    QWORD PTR [r12+0x10],0xb
      ee:	mov    QWORD PTR [r12+0x18],0xd
      f7:	lea    rdx,[rsp+0x18]
      fc:	mov    QWORD PTR [rsp+0x18],0x9
     105:	mov    QWORD PTR [rsp+0x20],0xb
     10e:	mov    QWORD PTR [rsp+0x28],0xd
     117:	mov    esi,0x3
     11c:	mov    rdi,r13
     11f:	call   124 <botlish_fn_0+0x124>
			120: R_X86_64_PLT32	rt_list_new-0x4
     124:	test   rax,rax
     127:	jne    135 <botlish_fn_0+0x135>
     12d:	mov    rdi,r13
     130:	jmp    2b2 <botlish_fn_0+0x2b2>
     135:	mov    QWORD PTR [r12+0x8],rax
     13a:	lea    rdx,[rsp+0x30]
     13f:	mov    rcx,rbx
     142:	mov    QWORD PTR [rsp+0x30],rcx
     147:	mov    QWORD PTR [rsp+0x38],rax
     14c:	mov    esi,0x2
     151:	mov    rdi,r13
     154:	call   159 <botlish_fn_0+0x159>
			155: R_X86_64_PLT32	rt_list_new-0x4
     159:	test   rax,rax
     15c:	jne    16a <botlish_fn_0+0x16a>
     162:	mov    rdi,r13
     165:	jmp    2b2 <botlish_fn_0+0x2b2>
     16a:	mov    QWORD PTR [r12],rax
     16e:	mov    r14,rax
     171:	mov    QWORD PTR [r12+0x8],0xf
     17a:	mov    QWORD PTR [r12+0x10],0x11
     183:	lea    rdx,[rsp+0x40]
     188:	mov    QWORD PTR [rsp+0x40],0xf
     191:	mov    QWORD PTR [rsp+0x48],0x11
     19a:	mov    esi,0x2
     19f:	mov    rdi,r13
     1a2:	call   1a7 <botlish_fn_0+0x1a7>
			1a3: R_X86_64_PLT32	rt_list_new-0x4
     1a7:	mov    rbx,rax
     1aa:	test   rbx,rbx
     1ad:	jne    1bb <botlish_fn_0+0x1bb>
     1b3:	mov    rdi,r13
     1b6:	jmp    2b2 <botlish_fn_0+0x2b2>
     1bb:	mov    QWORD PTR [r12+0x8],rbx
     1c0:	mov    QWORD PTR [r12+0x10],0x13
     1c9:	mov    QWORD PTR [r12+0x18],0x15
     1d2:	lea    rdx,[rsp+0x50]
     1d7:	mov    QWORD PTR [rsp+0x50],0x13
     1e0:	mov    QWORD PTR [rsp+0x58],0x15
     1e9:	mov    esi,0x2
     1ee:	mov    rdi,r13
     1f1:	call   1f6 <botlish_fn_0+0x1f6>
			1f2: R_X86_64_PLT32	rt_list_new-0x4
     1f6:	test   rax,rax
     1f9:	jne    207 <botlish_fn_0+0x207>
     1ff:	mov    rdi,r13
     202:	jmp    2b2 <botlish_fn_0+0x2b2>
     207:	mov    QWORD PTR [r12+0x10],rax
     20c:	mov    r15,rax
     20f:	mov    QWORD PTR [r12+0x18],0x17
     218:	mov    QWORD PTR [r12+0x20],0x19
     221:	lea    rdx,[rsp+0x60]
     226:	mov    QWORD PTR [rsp+0x60],0x17
     22f:	mov    QWORD PTR [rsp+0x68],0x19
     238:	mov    esi,0x2
     23d:	mov    rdi,r13
     240:	call   245 <botlish_fn_0+0x245>
			241: R_X86_64_PLT32	rt_list_new-0x4
     245:	test   rax,rax
     248:	jne    256 <botlish_fn_0+0x256>
     24e:	mov    rdi,r13
     251:	jmp    2b2 <botlish_fn_0+0x2b2>
     256:	mov    QWORD PTR [r12+0x18],rax
     25b:	lea    rdx,[rsp+0x70]
     260:	mov    QWORD PTR [rsp+0x70],rbx
     265:	mov    rcx,r15
     268:	mov    QWORD PTR [rsp+0x78],rcx
     26d:	mov    QWORD PTR [rsp+0x80],rax
     275:	mov    esi,0x3
     27a:	mov    rdi,r13
     27d:	call   282 <botlish_fn_0+0x282>
			27e: R_X86_64_PLT32	rt_list_new-0x4
     282:	test   rax,rax
     285:	jne    293 <botlish_fn_0+0x293>
     28b:	mov    rdi,r13
     28e:	jmp    2b2 <botlish_fn_0+0x2b2>
     293:	mov    QWORD PTR [r12+0x8],rax
     298:	mov    rdx,rax
     29b:	mov    rsi,r14
     29e:	mov    rdi,r13
     2a1:	call   2a6 <botlish_fn_0+0x2a6>
			2a2: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
     2a6:	test   rax,rax
     2a9:	jne    2ef <botlish_fn_0+0x2ef>
     2af:	mov    rdi,r13
     2b2:	mov    rdi,r13
     2b5:	mov    QWORD PTR [rdi],r12
     2b8:	xor    rax,rax
     2bb:	mov    rbx,QWORD PTR [rsp+0x90]
     2c3:	mov    r12,QWORD PTR [rsp+0x98]
     2cb:	mov    r13,QWORD PTR [rsp+0xa0]
     2d3:	mov    r14,QWORD PTR [rsp+0xa8]
     2db:	mov    r15,QWORD PTR [rsp+0xb0]
     2e3:	add    rsp,0xc0
     2ea:	mov    rsp,rbp
     2ed:	pop    rbp
     2ee:	ret
     2ef:	mov    rdi,r13
     2f2:	mov    QWORD PTR [rdi],r12
     2f5:	mov    rbx,QWORD PTR [rsp+0x90]
     2fd:	mov    r12,QWORD PTR [rsp+0x98]
     305:	mov    r13,QWORD PTR [rsp+0xa0]
     30d:	mov    r14,QWORD PTR [rsp+0xa8]
     315:	mov    r15,QWORD PTR [rsp+0xb0]
     31d:	add    rsp,0xc0
     324:	mov    rsp,rbp
     327:	pop    rbp
     328:	ret
     329:	mov    r13,rdi
     32c:	call   331 <botlish_fn_0+0x331>
			32d: R_X86_64_PLT32	rt_stack_overflow-0x4
     331:	xor    rax,rax
     334:	mov    rbx,QWORD PTR [rsp+0x90]
     33c:	mov    r12,QWORD PTR [rsp+0x98]
     344:	mov    r13,QWORD PTR [rsp+0xa0]
     34c:	mov    r14,QWORD PTR [rsp+0xa8]
     354:	mov    r15,QWORD PTR [rsp+0xb0]
     35c:	add    rsp,0xc0
     363:	mov    rsp,rbp
     366:	pop    rbp
     367:	ret

0000000000000368 <botlish_entry_0: <program entry>>:
     368:	push   rbp
     369:	mov    rbp,rsp
     36c:	call   371 <botlish_entry_0+0x9>
			36d: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     371:	mov    rsp,rbp
     374:	pop    rbp
     375:	ret

0000000000000376 <botlish_fn_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     376:	push   rbp
     377:	mov    rbp,rsp
     37a:	sub    rsp,0x60
     37e:	mov    QWORD PTR [rsp+0x30],rbx
     383:	mov    QWORD PTR [rsp+0x38],r12
     388:	mov    QWORD PTR [rsp+0x40],r13
     38d:	mov    QWORD PTR [rsp+0x48],r14
     392:	mov    QWORD PTR [rsp+0x50],r15
     397:	mov    r10,QWORD PTR [rbp+0x10]
     39b:	mov    r14,QWORD PTR [rdi]
     39e:	mov    r11,QWORD PTR [rdi+0x8]
     3a2:	lea    rax,[r14+0x30]
     3a6:	cmp    rax,r11
     3a9:	ja     63d <botlish_fn_1+0x2c7>
     3af:	lea    r11,[r14+0x30]
     3b3:	mov    QWORD PTR [rdi],r11
     3b6:	mov    QWORD PTR [rsp],rdi
     3ba:	mov    QWORD PTR [r14],0x0
     3c1:	mov    QWORD PTR [r14+0x8],0x0
     3c9:	mov    QWORD PTR [r14+0x10],0x0
     3d1:	mov    QWORD PTR [r14+0x18],0x0
     3d9:	mov    QWORD PTR [r14+0x20],0x0
     3e1:	mov    QWORD PTR [r14+0x28],0x0
     3e9:	mov    QWORD PTR [r14],rsi
     3ec:	mov    QWORD PTR [r14+0x8],rdx
     3f0:	mov    r15,rdx
     3f3:	mov    QWORD PTR [r14+0x10],rcx
     3f7:	mov    QWORD PTR [r14+0x18],r10
     3fb:	sar    r8,1
     3fe:	sar    r9,1
     401:	mov    QWORD PTR [rsp+0x20],r9
     406:	mov    rax,rcx
     409:	sar    rax,1
     40c:	mov    r12,rcx
     40f:	mov    QWORD PTR [rsp+0x18],rax
     414:	mov    rcx,QWORD PTR [rsp+0x20]
     419:	mov    rbx,r8
     41c:	mov    QWORD PTR [rsp+0x8],r10
     421:	cmp    rbx,rcx
     424:	mov    QWORD PTR [rsp+0x20],rcx
     429:	je     60f <botlish_fn_1+0x299>
     42f:	mov    r13,rsi
     432:	mov    rcx,QWORD PTR [r13+0x8]
     436:	mov    rax,rbx
     439:	shl    rax,1
     43c:	or     rax,0x1
     440:	sar    rax,1
     443:	cmp    rax,rcx
     446:	jb     47c <botlish_fn_1+0x106>
     44c:	mov    rdx,rbx
     44f:	shl    rdx,1
     452:	or     rdx,0x1
     456:	mov    rsi,r13
     459:	mov    rdi,QWORD PTR [rsp]
     45d:	call   462 <botlish_fn_1+0xec>
			45e: R_X86_64_PLT32	rt_list_get-0x4
     462:	test   rax,rax
     465:	jne    474 <botlish_fn_1+0xfe>
     46b:	mov    rdi,QWORD PTR [rsp]
     46f:	jmp    517 <botlish_fn_1+0x1a1>
     474:	mov    rsi,rax
     477:	jmp    484 <botlish_fn_1+0x10e>
     47c:	mov    rcx,QWORD PTR [r13+0x10]
     480:	mov    rsi,QWORD PTR [rcx+rax*8]
     484:	mov    QWORD PTR [r14+0x20],rsi
     488:	mov    QWORD PTR [rsp+0x10],rsi
     48d:	mov    rcx,QWORD PTR [r15+0x8]
     491:	mov    rax,rbx
     494:	shl    rax,1
     497:	or     rax,0x1
     49b:	sar    rax,1
     49e:	cmp    rax,rcx
     4a1:	jb     4d7 <botlish_fn_1+0x161>
     4a7:	mov    rdx,rbx
     4aa:	shl    rdx,1
     4ad:	or     rdx,0x1
     4b1:	mov    rsi,r15
     4b4:	mov    rdi,QWORD PTR [rsp]
     4b8:	call   4bd <botlish_fn_1+0x147>
			4b9: R_X86_64_PLT32	rt_list_get-0x4
     4bd:	test   rax,rax
     4c0:	jne    4cf <botlish_fn_1+0x159>
     4c6:	mov    rdi,QWORD PTR [rsp]
     4ca:	jmp    517 <botlish_fn_1+0x1a1>
     4cf:	mov    rsi,rax
     4d2:	jmp    4df <botlish_fn_1+0x169>
     4d7:	mov    rcx,QWORD PTR [r15+0x10]
     4db:	mov    rsi,QWORD PTR [rcx+rax*8]
     4df:	test   r12,0x1
     4e6:	je     4fe <botlish_fn_1+0x188>
     4ec:	mov    rax,QWORD PTR [rsi+0x8]
     4f0:	mov    rcx,QWORD PTR [rsp+0x18]
     4f5:	cmp    rcx,rax
     4f8:	jb     54b <botlish_fn_1+0x1d5>
     4fe:	mov    rdx,r12
     501:	mov    rdi,QWORD PTR [rsp]
     505:	call   50a <botlish_fn_1+0x194>
			506: R_X86_64_PLT32	rt_list_get-0x4
     50a:	test   rax,rax
     50d:	jne    543 <botlish_fn_1+0x1cd>
     513:	mov    rdi,QWORD PTR [rsp]
     517:	mov    rdi,QWORD PTR [rsp]
     51b:	mov    QWORD PTR [rdi],r14
     51e:	xor    rax,rax
     521:	mov    rbx,QWORD PTR [rsp+0x30]
     526:	mov    r12,QWORD PTR [rsp+0x38]
     52b:	mov    r13,QWORD PTR [rsp+0x40]
     530:	mov    r14,QWORD PTR [rsp+0x48]
     535:	mov    r15,QWORD PTR [rsp+0x50]
     53a:	add    rsp,0x60
     53e:	mov    rsp,rbp
     541:	pop    rbp
     542:	ret
     543:	mov    rdx,rax
     546:	jmp    558 <botlish_fn_1+0x1e2>
     54b:	mov    rax,QWORD PTR [rsi+0x10]
     54f:	mov    rcx,QWORD PTR [rsp+0x18]
     554:	mov    rdx,QWORD PTR [rax+rcx*8]
     558:	mov    QWORD PTR [r14+0x28],rdx
     55c:	mov    rsi,QWORD PTR [rsp+0x10]
     561:	mov    rax,rsi
     564:	and    rax,rdx
     567:	test   rax,0x1
     56d:	je     5a2 <botlish_fn_1+0x22c>
     573:	mov    rax,rsi
     576:	sar    rax,1
     579:	lea    rcx,[rdx-0x1]
     57d:	mov    rdi,rdx
     580:	imul   rcx
     583:	seto   cl
     586:	or     rax,0x1
     58a:	test   cl,cl
     58c:	je     59a <botlish_fn_1+0x224>
     592:	mov    rdx,rdi
     595:	jmp    5a2 <botlish_fn_1+0x22c>
     59a:	mov    rdx,rax
     59d:	jmp    5ae <botlish_fn_1+0x238>
     5a2:	mov    rdi,QWORD PTR [rsp]
     5a6:	call   5ab <botlish_fn_1+0x235>
			5a7: R_X86_64_PLT32	rt_int_mul-0x4
     5ab:	mov    rdx,rax
     5ae:	mov    QWORD PTR [r14+0x20],rdx
     5b2:	mov    rsi,QWORD PTR [rsp+0x8]
     5b7:	mov    rax,rsi
     5ba:	and    rax,rdx
     5bd:	test   rax,0x1
     5c3:	je     5de <botlish_fn_1+0x268>
     5c9:	lea    rcx,[rdx-0x1]
     5cd:	mov    rax,rsi
     5d0:	add    rax,rcx
     5d3:	seto   cl
     5d6:	test   cl,cl
     5d8:	je     5e7 <botlish_fn_1+0x271>
     5de:	mov    rdi,QWORD PTR [rsp]
     5e2:	call   5e7 <botlish_fn_1+0x271>
			5e3: R_X86_64_PLT32	rt_int_add-0x4
     5e7:	mov    QWORD PTR [r14],r13
     5ea:	mov    QWORD PTR [r14+0x8],r15
     5ee:	mov    QWORD PTR [r14+0x10],r12
     5f2:	mov    QWORD PTR [r14+0x18],rax
     5f6:	add    rbx,0x1
     5fd:	mov    rcx,QWORD PTR [rsp+0x20]
     602:	mov    rsi,r13
     605:	mov    QWORD PTR [rsp+0x8],rax
     60a:	jmp    421 <botlish_fn_1+0xab>
     60f:	mov    rdi,QWORD PTR [rsp]
     613:	mov    QWORD PTR [rdi],r14
     616:	mov    rax,QWORD PTR [rsp+0x8]
     61b:	mov    rbx,QWORD PTR [rsp+0x30]
     620:	mov    r12,QWORD PTR [rsp+0x38]
     625:	mov    r13,QWORD PTR [rsp+0x40]
     62a:	mov    r14,QWORD PTR [rsp+0x48]
     62f:	mov    r15,QWORD PTR [rsp+0x50]
     634:	add    rsp,0x60
     638:	mov    rsp,rbp
     63b:	pop    rbp
     63c:	ret
     63d:	mov    QWORD PTR [rsp],rdi
     641:	call   646 <botlish_fn_1+0x2d0>
			642: R_X86_64_PLT32	rt_stack_overflow-0x4
     646:	xor    rax,rax
     649:	mov    rbx,QWORD PTR [rsp+0x30]
     64e:	mov    r12,QWORD PTR [rsp+0x38]
     653:	mov    r13,QWORD PTR [rsp+0x40]
     658:	mov    r14,QWORD PTR [rsp+0x48]
     65d:	mov    r15,QWORD PTR [rsp+0x50]
     662:	add    rsp,0x60
     666:	mov    rsp,rbp
     669:	pop    rbp
     66a:	ret

000000000000066b <botlish_entry_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     66b:	push   rbp
     66c:	mov    rbp,rsp
     66f:	sub    rsp,0x10
     673:	mov    rsi,QWORD PTR [rdx]
     676:	mov    r10,QWORD PTR [rdx+0x8]
     67a:	mov    rcx,QWORD PTR [rdx+0x10]
     67e:	mov    r8,QWORD PTR [rdx+0x18]
     682:	mov    r9,QWORD PTR [rdx+0x20]
     686:	mov    r11,QWORD PTR [rdx+0x28]
     68a:	mov    QWORD PTR [rsp],r11
     68e:	mov    rdx,r10
     691:	call   696 <botlish_entry_1+0x2b>
			692: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     696:	add    rsp,0x10
     69a:	mov    rsp,rbp
     69d:	pop    rbp
     69e:	ret

000000000000069f <botlish_fn_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     69f:	push   rbp
     6a0:	mov    rbp,rsp
     6a3:	sub    rsp,0x60
     6a7:	mov    QWORD PTR [rsp+0x30],rbx
     6ac:	mov    QWORD PTR [rsp+0x38],r12
     6b1:	mov    QWORD PTR [rsp+0x40],r13
     6b6:	mov    QWORD PTR [rsp+0x48],r14
     6bb:	mov    QWORD PTR [rsp+0x50],r15
     6c0:	mov    r13,QWORD PTR [rdi]
     6c3:	mov    rax,QWORD PTR [rdi+0x8]
     6c7:	lea    r10,[r13+0x40]
     6cb:	cmp    r10,rax
     6ce:	ja     899 <botlish_fn_2+0x1fa>
     6d4:	lea    rax,[r13+0x40]
     6d8:	mov    QWORD PTR [rdi],rax
     6db:	mov    r14,rdi
     6de:	mov    QWORD PTR [r13+0x0],0x0
     6e6:	mov    QWORD PTR [r13+0x8],0x0
     6ee:	mov    QWORD PTR [r13+0x10],0x0
     6f6:	mov    QWORD PTR [r13+0x18],0x0
     6fe:	mov    QWORD PTR [r13+0x20],0x0
     706:	mov    QWORD PTR [r13+0x28],0x0
     70e:	mov    QWORD PTR [r13+0x30],0x0
     716:	mov    QWORD PTR [r13+0x38],0x0
     71e:	mov    QWORD PTR [r13+0x0],rsi
     722:	mov    QWORD PTR [rsp+0x10],rsi
     727:	mov    QWORD PTR [r13+0x8],rdx
     72b:	mov    QWORD PTR [rsp+0x18],rdx
     730:	mov    QWORD PTR [r13+0x10],rcx
     734:	mov    QWORD PTR [r13+0x18],r8
     738:	mov    QWORD PTR [r13+0x20],r9
     73c:	mov    QWORD PTR [rsp+0x28],r9
     741:	mov    rbx,rcx
     744:	sar    rbx,1
     747:	mov    QWORD PTR [rsp+0x20],rcx
     74c:	mov    rax,r8
     74f:	sar    rax,1
     752:	mov    r15,r8
     755:	cmp    rbx,rax
     758:	je     86c <botlish_fn_2+0x1cd>
     75e:	mov    r12d,0x1
     764:	mov    QWORD PTR [r13+0x28],0x1
     76c:	mov    rsi,QWORD PTR [rsp+0x10]
     771:	mov    rdi,r14
     774:	call   779 <botlish_fn_2+0xda>
			775: R_X86_64_PLT32	rt_list_len-0x4
     779:	mov    QWORD PTR [r13+0x30],rax
     77d:	mov    QWORD PTR [r13+0x38],0x1
     785:	mov    QWORD PTR [rsp],r12
     789:	mov    rcx,QWORD PTR [rsp+0x20]
     78e:	mov    r8,r12
     791:	mov    r9,rax
     794:	mov    rdx,QWORD PTR [rsp+0x18]
     799:	mov    rsi,QWORD PTR [rsp+0x10]
     79e:	mov    rdi,r14
     7a1:	call   7a6 <botlish_fn_2+0x107>
			7a2: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     7a6:	test   rax,rax
     7a9:	jne    7b7 <botlish_fn_2+0x118>
     7af:	mov    rdi,r14
     7b2:	jmp    819 <botlish_fn_2+0x17a>
     7b7:	mov    QWORD PTR [r13+0x10],rax
     7bb:	mov    rdx,rax
     7be:	lea    rcx,[rbx+0x1]
     7c2:	shl    rcx,1
     7c5:	or     rcx,0x1
     7c9:	mov    QWORD PTR [r13+0x28],rcx
     7cd:	mov    rbx,rcx
     7d0:	mov    rsi,QWORD PTR [rsp+0x28]
     7d5:	mov    rdi,r14
     7d8:	call   7dd <botlish_fn_2+0x13e>
			7d9: R_X86_64_PLT32	rt_list_append-0x4
     7dd:	test   rax,rax
     7e0:	jne    7ee <botlish_fn_2+0x14f>
     7e6:	mov    rdi,r14
     7e9:	jmp    819 <botlish_fn_2+0x17a>
     7ee:	mov    QWORD PTR [r13+0x10],rax
     7f2:	mov    rcx,rbx
     7f5:	mov    rdx,QWORD PTR [rsp+0x18]
     7fa:	mov    rsi,QWORD PTR [rsp+0x10]
     7ff:	mov    r8,r15
     802:	mov    r9,rax
     805:	mov    rdi,r14
     808:	call   80d <botlish_fn_2+0x16e>
			809: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     80d:	test   rax,rax
     810:	jne    844 <botlish_fn_2+0x1a5>
     816:	mov    rdi,r14
     819:	mov    rdi,r14
     81c:	mov    QWORD PTR [rdi],r13
     81f:	xor    rax,rax
     822:	mov    rbx,QWORD PTR [rsp+0x30]
     827:	mov    r12,QWORD PTR [rsp+0x38]
     82c:	mov    r13,QWORD PTR [rsp+0x40]
     831:	mov    r14,QWORD PTR [rsp+0x48]
     836:	mov    r15,QWORD PTR [rsp+0x50]
     83b:	add    rsp,0x60
     83f:	mov    rsp,rbp
     842:	pop    rbp
     843:	ret
     844:	mov    rdi,r14
     847:	mov    QWORD PTR [rdi],r13
     84a:	mov    rbx,QWORD PTR [rsp+0x30]
     84f:	mov    r12,QWORD PTR [rsp+0x38]
     854:	mov    r13,QWORD PTR [rsp+0x40]
     859:	mov    r14,QWORD PTR [rsp+0x48]
     85e:	mov    r15,QWORD PTR [rsp+0x50]
     863:	add    rsp,0x60
     867:	mov    rsp,rbp
     86a:	pop    rbp
     86b:	ret
     86c:	mov    rdi,r14
     86f:	mov    QWORD PTR [rdi],r13
     872:	mov    rax,QWORD PTR [rsp+0x28]
     877:	mov    rbx,QWORD PTR [rsp+0x30]
     87c:	mov    r12,QWORD PTR [rsp+0x38]
     881:	mov    r13,QWORD PTR [rsp+0x40]
     886:	mov    r14,QWORD PTR [rsp+0x48]
     88b:	mov    r15,QWORD PTR [rsp+0x50]
     890:	add    rsp,0x60
     894:	mov    rsp,rbp
     897:	pop    rbp
     898:	ret
     899:	mov    r14,rdi
     89c:	call   8a1 <botlish_fn_2+0x202>
			89d: R_X86_64_PLT32	rt_stack_overflow-0x4
     8a1:	xor    rax,rax
     8a4:	mov    rbx,QWORD PTR [rsp+0x30]
     8a9:	mov    r12,QWORD PTR [rsp+0x38]
     8ae:	mov    r13,QWORD PTR [rsp+0x40]
     8b3:	mov    r14,QWORD PTR [rsp+0x48]
     8b8:	mov    r15,QWORD PTR [rsp+0x50]
     8bd:	add    rsp,0x60
     8c1:	mov    rsp,rbp
     8c4:	pop    rbp
     8c5:	ret

00000000000008c6 <botlish_entry_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     8c6:	push   rbp
     8c7:	mov    rbp,rsp
     8ca:	mov    rsi,QWORD PTR [rdx]
     8cd:	mov    r10,QWORD PTR [rdx+0x8]
     8d1:	mov    rcx,QWORD PTR [rdx+0x10]
     8d5:	mov    r8,QWORD PTR [rdx+0x18]
     8d9:	mov    r9,QWORD PTR [rdx+0x20]
     8dd:	mov    rdx,r10
     8e0:	call   8e5 <botlish_entry_2+0x1f>
			8e1: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     8e5:	mov    rsp,rbp
     8e8:	pop    rbp
     8e9:	ret
     8ea:	add    BYTE PTR [rax],al
     8ec:	add    BYTE PTR [rax],al
	...

00000000000008f0 <botlish_fn_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     8f0:	push   rbp
     8f1:	mov    rbp,rsp
     8f4:	sub    rsp,0x60
     8f8:	mov    QWORD PTR [rsp+0x30],rbx
     8fd:	mov    QWORD PTR [rsp+0x38],r12
     902:	mov    QWORD PTR [rsp+0x40],r13
     907:	mov    QWORD PTR [rsp+0x48],r14
     90c:	mov    QWORD PTR [rsp+0x50],r15
     911:	mov    r10,r8
     914:	mov    r14,QWORD PTR [rdi]
     917:	mov    rax,QWORD PTR [rdi+0x8]
     91b:	lea    r8,[r14+0x38]
     91f:	cmp    r8,rax
     922:	ja     b51 <botlish_fn_3+0x261>
     928:	lea    rax,[r14+0x38]
     92c:	mov    QWORD PTR [rdi],rax
     92f:	mov    r15,rdi
     932:	mov    QWORD PTR [r14],0x0
     939:	mov    QWORD PTR [r14+0x8],0x0
     941:	mov    QWORD PTR [r14+0x10],0x0
     949:	mov    QWORD PTR [r14+0x18],0x0
     951:	mov    QWORD PTR [r14+0x20],0x0
     959:	mov    QWORD PTR [r14+0x28],0x0
     961:	mov    QWORD PTR [r14+0x30],0x0
     969:	mov    QWORD PTR [r14],rsi
     96c:	mov    r12,rsi
     96f:	mov    QWORD PTR [r14+0x8],rdx
     973:	mov    QWORD PTR [rsp+0x10],rdx
     978:	mov    QWORD PTR [r14+0x10],rcx
     97c:	mov    QWORD PTR [r14+0x18],r9
     980:	mov    rbx,r10
     983:	mov    rsi,rcx
     986:	mov    QWORD PTR [rsp+0x20],r9
     98b:	mov    rax,rbx
     98e:	or     rax,0x1
     992:	mov    rcx,rsi
     995:	and    rcx,rax
     998:	mov    QWORD PTR [rsp+0x18],rsi
     99d:	test   rcx,0x1
     9a4:	jne    9d3 <botlish_fn_3+0xe3>
     9aa:	mov    rdx,rbx
     9ad:	or     rdx,0x1
     9b1:	mov    rsi,QWORD PTR [rsp+0x18]
     9b6:	mov    rdi,r15
     9b9:	call   9be <botlish_fn_3+0xce>
			9ba: R_X86_64_PLT32	rt_int_cmp-0x4
     9be:	mov    ecx,0x2
     9c3:	test   rax,rax
     9c6:	cmove  rcx,QWORD PTR [rip+0x1b2]        # b80 <botlish_fn_3+0x290>
     9ce:	jmp    9ef <botlish_fn_3+0xff>
     9d3:	mov    rax,rbx
     9d6:	or     rax,0x1
     9da:	mov    ecx,0x2
     9df:	mov    rsi,QWORD PTR [rsp+0x18]
     9e4:	cmp    rsi,rax
     9e7:	cmove  rcx,QWORD PTR [rip+0x191]        # b80 <botlish_fn_3+0x290>
     9ef:	cmp    rcx,0x6
     9f3:	je     b24 <botlish_fn_3+0x234>
     9f9:	mov    r13d,0x1
     9ff:	mov    QWORD PTR [r14+0x20],0x1
     a07:	mov    rsi,r12
     a0a:	mov    rdi,r15
     a0d:	call   a12 <botlish_fn_3+0x122>
			a0e: R_X86_64_PLT32	rt_list_len-0x4
     a12:	mov    QWORD PTR [r14+0x28],rax
     a16:	mov    QWORD PTR [r14+0x30],0x1
     a1e:	mov    QWORD PTR [rsp],r13
     a22:	mov    r9,rax
     a25:	mov    r8,r13
     a28:	mov    r13,QWORD PTR [rsp+0x10]
     a2d:	mov    rcx,QWORD PTR [rsp+0x18]
     a32:	mov    rdx,r13
     a35:	mov    rsi,r12
     a38:	mov    rdi,r15
     a3b:	call   a40 <botlish_fn_3+0x150>
			a3c: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     a40:	test   rax,rax
     a43:	jne    a51 <botlish_fn_3+0x161>
     a49:	mov    rdi,r15
     a4c:	jmp    ad6 <botlish_fn_3+0x1e6>
     a51:	mov    QWORD PTR [r14+0x20],rax
     a55:	mov    QWORD PTR [rsp+0x28],rax
     a5a:	mov    QWORD PTR [r14+0x28],0x3
     a62:	mov    rsi,QWORD PTR [rsp+0x18]
     a67:	test   rsi,0x1
     a6e:	je     a9a <botlish_fn_3+0x1aa>
     a74:	mov    rsi,QWORD PTR [rsp+0x18]
     a79:	mov    r8,rsi
     a7c:	add    r8,0x2
     a80:	seto   r10b
     a84:	test   r10b,r10b
     a87:	jne    a9a <botlish_fn_3+0x1aa>
     a8d:	mov    rsi,r8
     a90:	mov    QWORD PTR [rsp+0x18],r8
     a95:	jmp    ab4 <botlish_fn_3+0x1c4>
     a9a:	mov    edx,0x3
     a9f:	mov    rsi,QWORD PTR [rsp+0x18]
     aa4:	mov    rdi,r15
     aa7:	call   aac <botlish_fn_3+0x1bc>
			aa8: R_X86_64_PLT32	rt_int_add-0x4
     aac:	mov    rsi,rax
     aaf:	mov    QWORD PTR [rsp+0x18],rax
     ab4:	mov    QWORD PTR [r14+0x10],rsi
     ab8:	mov    rdx,QWORD PTR [rsp+0x28]
     abd:	mov    rsi,QWORD PTR [rsp+0x20]
     ac2:	mov    rdi,r15
     ac5:	call   aca <botlish_fn_3+0x1da>
			ac6: R_X86_64_PLT32	rt_list_append-0x4
     aca:	test   rax,rax
     acd:	jne    b01 <botlish_fn_3+0x211>
     ad3:	mov    rdi,r15
     ad6:	mov    rdi,r15
     ad9:	mov    QWORD PTR [rdi],r14
     adc:	xor    rax,rax
     adf:	mov    rbx,QWORD PTR [rsp+0x30]
     ae4:	mov    r12,QWORD PTR [rsp+0x38]
     ae9:	mov    r13,QWORD PTR [rsp+0x40]
     aee:	mov    r14,QWORD PTR [rsp+0x48]
     af3:	mov    r15,QWORD PTR [rsp+0x50]
     af8:	add    rsp,0x60
     afc:	mov    rsp,rbp
     aff:	pop    rbp
     b00:	ret
     b01:	mov    QWORD PTR [r14],r12
     b04:	mov    QWORD PTR [r14+0x8],r13
     b08:	mov    rsi,QWORD PTR [rsp+0x18]
     b0d:	mov    QWORD PTR [r14+0x10],rsi
     b11:	mov    QWORD PTR [r14+0x18],rax
     b15:	mov    QWORD PTR [rsp+0x10],r13
     b1a:	mov    QWORD PTR [rsp+0x20],rax
     b1f:	jmp    98b <botlish_fn_3+0x9b>
     b24:	mov    rdi,r15
     b27:	mov    QWORD PTR [rdi],r14
     b2a:	mov    rax,QWORD PTR [rsp+0x20]
     b2f:	mov    rbx,QWORD PTR [rsp+0x30]
     b34:	mov    r12,QWORD PTR [rsp+0x38]
     b39:	mov    r13,QWORD PTR [rsp+0x40]
     b3e:	mov    r14,QWORD PTR [rsp+0x48]
     b43:	mov    r15,QWORD PTR [rsp+0x50]
     b48:	add    rsp,0x60
     b4c:	mov    rsp,rbp
     b4f:	pop    rbp
     b50:	ret
     b51:	mov    r15,rdi
     b54:	call   b59 <botlish_fn_3+0x269>
			b55: R_X86_64_PLT32	rt_stack_overflow-0x4
     b59:	xor    rax,rax
     b5c:	mov    rbx,QWORD PTR [rsp+0x30]
     b61:	mov    r12,QWORD PTR [rsp+0x38]
     b66:	mov    r13,QWORD PTR [rsp+0x40]
     b6b:	mov    r14,QWORD PTR [rsp+0x48]
     b70:	mov    r15,QWORD PTR [rsp+0x50]
     b75:	add    rsp,0x60
     b79:	mov    rsp,rbp
     b7c:	pop    rbp
     b7d:	ret
     b7e:	add    BYTE PTR [rax],al
     b80:	(bad)
     b81:	add    BYTE PTR [rax],al
     b83:	add    BYTE PTR [rax],al
     b85:	add    BYTE PTR [rax],al
	...

0000000000000b88 <botlish_entry_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     b88:	push   rbp
     b89:	mov    rbp,rsp
     b8c:	mov    rsi,QWORD PTR [rdx]
     b8f:	mov    r10,QWORD PTR [rdx+0x8]
     b93:	mov    rcx,QWORD PTR [rdx+0x10]
     b97:	mov    r8,QWORD PTR [rdx+0x18]
     b9b:	mov    r9,QWORD PTR [rdx+0x20]
     b9f:	mov    rdx,r10
     ba2:	call   ba7 <botlish_entry_3+0x1f>
			ba3: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     ba7:	mov    rsp,rbp
     baa:	pop    rbp
     bab:	ret

0000000000000bac <botlish_fn_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     bac:	push   rbp
     bad:	mov    rbp,rsp
     bb0:	sub    rsp,0x50
     bb4:	mov    QWORD PTR [rsp+0x20],rbx
     bb9:	mov    QWORD PTR [rsp+0x28],r12
     bbe:	mov    QWORD PTR [rsp+0x30],r13
     bc3:	mov    QWORD PTR [rsp+0x38],r14
     bc8:	mov    QWORD PTR [rsp+0x40],r15
     bcd:	mov    rbx,rcx
     bd0:	mov    r12,QWORD PTR [rdi]
     bd3:	mov    rax,QWORD PTR [rdi+0x8]
     bd7:	lea    rcx,[r12+0x38]
     bdc:	cmp    rcx,rax
     bdf:	ja     e0d <botlish_fn_4+0x261>
     be5:	lea    rax,[r12+0x38]
     bea:	mov    QWORD PTR [rdi],rax
     bed:	mov    r13,rdi
     bf0:	mov    QWORD PTR [r12],0x0
     bf8:	mov    QWORD PTR [r12+0x8],0x0
     c01:	mov    QWORD PTR [r12+0x10],0x0
     c0a:	mov    QWORD PTR [r12+0x18],0x0
     c13:	mov    QWORD PTR [r12+0x20],0x0
     c1c:	mov    QWORD PTR [r12+0x28],0x0
     c25:	mov    QWORD PTR [r12+0x30],0x0
     c2e:	mov    QWORD PTR [r12],rsi
     c32:	mov    QWORD PTR [rsp],rsi
     c36:	mov    QWORD PTR [r12+0x8],rdx
     c3b:	mov    r15,rdx
     c3e:	mov    QWORD PTR [r12+0x10],r8
     c43:	mov    r14,r8
     c46:	mov    QWORD PTR [r12+0x18],r9
     c4b:	mov    QWORD PTR [rsp+0x8],r9
     c50:	mov    rsi,QWORD PTR [rsp]
     c54:	mov    rdi,r13
     c57:	call   c5c <botlish_fn_4+0xb0>
			c58: R_X86_64_PLT32	rt_list_len-0x4
     c5c:	mov    rcx,rbx
     c5f:	sar    rbx,1
     c62:	sar    rax,1
     c65:	cmp    rbx,rax
     c68:	je     de0 <botlish_fn_4+0x234>
     c6e:	test   rcx,0x1
     c75:	jne    c83 <botlish_fn_4+0xd7>
     c7b:	mov    rdx,rcx
     c7e:	jmp    c97 <botlish_fn_4+0xeb>
     c83:	mov    rsi,QWORD PTR [rsp]
     c87:	mov    rax,QWORD PTR [rsi+0x8]
     c8b:	cmp    rbx,rax
     c8e:	jb     cbc <botlish_fn_4+0x110>
     c94:	mov    rdx,rcx
     c97:	mov    rsi,QWORD PTR [rsp]
     c9b:	mov    rdi,r13
     c9e:	call   ca3 <botlish_fn_4+0xf7>
			c9f: R_X86_64_PLT32	rt_list_get-0x4
     ca3:	test   rax,rax
     ca6:	jne    cb4 <botlish_fn_4+0x108>
     cac:	mov    rdi,r13
     caf:	jmp    d8d <botlish_fn_4+0x1e1>
     cb4:	mov    rsi,rax
     cb7:	jmp    cc8 <botlish_fn_4+0x11c>
     cbc:	mov    rsi,QWORD PTR [rsp]
     cc0:	mov    rax,QWORD PTR [rsi+0x10]
     cc4:	mov    rsi,QWORD PTR [rax+rbx*8]
     cc8:	mov    QWORD PTR [r12+0x20],rsi
     ccd:	mov    QWORD PTR [rsp+0x10],rsi
     cd2:	mov    QWORD PTR [r12+0x28],0x1
     cdb:	xor    rdx,rdx
     cde:	mov    rdi,r13
     ce1:	mov    rsi,rdx
     ce4:	call   ce9 <botlish_fn_4+0x13d>
			ce5: R_X86_64_PLT32	rt_list_new-0x4
     ce9:	test   rax,rax
     cec:	jne    cfa <botlish_fn_4+0x14e>
     cf2:	mov    rdi,r13
     cf5:	jmp    d8d <botlish_fn_4+0x1e1>
     cfa:	mov    QWORD PTR [r12+0x30],rax
     cff:	mov    r9,rax
     d02:	mov    ecx,0x1
     d07:	mov    rsi,QWORD PTR [rsp+0x10]
     d0c:	mov    rdx,r15
     d0f:	mov    rdi,r13
     d12:	mov    r8,r14
     d15:	call   d1a <botlish_fn_4+0x16e>
			d16: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     d1a:	test   rax,rax
     d1d:	jne    d2b <botlish_fn_4+0x17f>
     d23:	mov    rdi,r13
     d26:	jmp    d8d <botlish_fn_4+0x1e1>
     d2b:	mov    QWORD PTR [r12+0x20],rax
     d30:	mov    rdx,rax
     d33:	lea    rcx,[rbx+0x1]
     d37:	shl    rcx,1
     d3a:	or     rcx,0x1
     d3e:	mov    QWORD PTR [r12+0x28],rcx
     d43:	mov    rbx,rcx
     d46:	mov    rsi,QWORD PTR [rsp+0x8]
     d4b:	mov    rdi,r13
     d4e:	call   d53 <botlish_fn_4+0x1a7>
			d4f: R_X86_64_PLT32	rt_list_append-0x4
     d53:	test   rax,rax
     d56:	jne    d64 <botlish_fn_4+0x1b8>
     d5c:	mov    rdi,r13
     d5f:	jmp    d8d <botlish_fn_4+0x1e1>
     d64:	mov    QWORD PTR [r12+0x18],rax
     d69:	mov    rcx,rbx
     d6c:	mov    rdx,r15
     d6f:	mov    rsi,QWORD PTR [rsp]
     d73:	mov    r8,r14
     d76:	mov    r9,rax
     d79:	mov    rdi,r13
     d7c:	call   d81 <botlish_fn_4+0x1d5>
			d7d: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
     d81:	test   rax,rax
     d84:	jne    db8 <botlish_fn_4+0x20c>
     d8a:	mov    rdi,r13
     d8d:	mov    rdi,r13
     d90:	mov    QWORD PTR [rdi],r12
     d93:	xor    rax,rax
     d96:	mov    rbx,QWORD PTR [rsp+0x20]
     d9b:	mov    r12,QWORD PTR [rsp+0x28]
     da0:	mov    r13,QWORD PTR [rsp+0x30]
     da5:	mov    r14,QWORD PTR [rsp+0x38]
     daa:	mov    r15,QWORD PTR [rsp+0x40]
     daf:	add    rsp,0x50
     db3:	mov    rsp,rbp
     db6:	pop    rbp
     db7:	ret
     db8:	mov    rdi,r13
     dbb:	mov    QWORD PTR [rdi],r12
     dbe:	mov    rbx,QWORD PTR [rsp+0x20]
     dc3:	mov    r12,QWORD PTR [rsp+0x28]
     dc8:	mov    r13,QWORD PTR [rsp+0x30]
     dcd:	mov    r14,QWORD PTR [rsp+0x38]
     dd2:	mov    r15,QWORD PTR [rsp+0x40]
     dd7:	add    rsp,0x50
     ddb:	mov    rsp,rbp
     dde:	pop    rbp
     ddf:	ret
     de0:	mov    rdi,r13
     de3:	mov    QWORD PTR [rdi],r12
     de6:	mov    rax,QWORD PTR [rsp+0x8]
     deb:	mov    rbx,QWORD PTR [rsp+0x20]
     df0:	mov    r12,QWORD PTR [rsp+0x28]
     df5:	mov    r13,QWORD PTR [rsp+0x30]
     dfa:	mov    r14,QWORD PTR [rsp+0x38]
     dff:	mov    r15,QWORD PTR [rsp+0x40]
     e04:	add    rsp,0x50
     e08:	mov    rsp,rbp
     e0b:	pop    rbp
     e0c:	ret
     e0d:	mov    r13,rdi
     e10:	call   e15 <botlish_fn_4+0x269>
			e11: R_X86_64_PLT32	rt_stack_overflow-0x4
     e15:	xor    rax,rax
     e18:	mov    rbx,QWORD PTR [rsp+0x20]
     e1d:	mov    r12,QWORD PTR [rsp+0x28]
     e22:	mov    r13,QWORD PTR [rsp+0x30]
     e27:	mov    r14,QWORD PTR [rsp+0x38]
     e2c:	mov    r15,QWORD PTR [rsp+0x40]
     e31:	add    rsp,0x50
     e35:	mov    rsp,rbp
     e38:	pop    rbp
     e39:	ret

0000000000000e3a <botlish_entry_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     e3a:	push   rbp
     e3b:	mov    rbp,rsp
     e3e:	mov    rsi,QWORD PTR [rdx]
     e41:	mov    r10,QWORD PTR [rdx+0x8]
     e45:	mov    rcx,QWORD PTR [rdx+0x10]
     e49:	mov    r8,QWORD PTR [rdx+0x18]
     e4d:	mov    r9,QWORD PTR [rdx+0x20]
     e51:	mov    rdx,r10
     e54:	call   e59 <botlish_entry_4+0x1f>
			e55: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
     e59:	mov    rsp,rbp
     e5c:	pop    rbp
     e5d:	ret
	...

0000000000000e60 <botlish_fn_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
     e60:	push   rbp
     e61:	mov    rbp,rsp
     e64:	sub    rsp,0x50
     e68:	mov    QWORD PTR [rsp+0x20],rbx
     e6d:	mov    QWORD PTR [rsp+0x28],r12
     e72:	mov    QWORD PTR [rsp+0x30],r13
     e77:	mov    QWORD PTR [rsp+0x38],r14
     e7c:	mov    QWORD PTR [rsp+0x40],r15
     e81:	mov    rbx,r8
     e84:	mov    r14,QWORD PTR [rdi]
     e87:	mov    rax,QWORD PTR [rdi+0x8]
     e8b:	lea    r8,[r14+0x40]
     e8f:	cmp    r8,rax
     e92:	ja     111f <botlish_fn_5+0x2bf>
     e98:	lea    rax,[r14+0x40]
     e9c:	mov    QWORD PTR [rdi],rax
     e9f:	mov    r15,rdi
     ea2:	mov    QWORD PTR [r14],0x0
     ea9:	mov    QWORD PTR [r14+0x8],0x0
     eb1:	mov    QWORD PTR [r14+0x10],0x0
     eb9:	mov    QWORD PTR [r14+0x18],0x0
     ec1:	mov    QWORD PTR [r14+0x20],0x0
     ec9:	mov    QWORD PTR [r14+0x28],0x0
     ed1:	mov    QWORD PTR [r14+0x30],0x0
     ed9:	mov    QWORD PTR [r14+0x38],0x0
     ee1:	mov    QWORD PTR [r14],rsi
     ee4:	mov    QWORD PTR [r14+0x8],rdx
     ee8:	mov    r13,rdx
     eeb:	mov    QWORD PTR [r14+0x10],rcx
     eef:	mov    QWORD PTR [r14+0x18],r9
     ef3:	mov    r12,rsi
     ef6:	mov    QWORD PTR [rsp],rcx
     efa:	mov    QWORD PTR [rsp+0x8],r9
     eff:	mov    rsi,r12
     f02:	mov    rdi,r15
     f05:	call   f0a <botlish_fn_5+0xaa>
			f06: R_X86_64_PLT32	rt_list_len-0x4
     f0a:	mov    rsi,QWORD PTR [rsp]
     f0e:	mov    rcx,rsi
     f11:	and    rcx,rax
     f14:	mov    rdx,rax
     f17:	test   rcx,0x1
     f1e:	jne    f45 <botlish_fn_5+0xe5>
     f24:	mov    rsi,QWORD PTR [rsp]
     f28:	mov    rdi,r15
     f2b:	call   f30 <botlish_fn_5+0xd0>
			f2c: R_X86_64_PLT32	rt_int_cmp-0x4
     f30:	mov    ecx,0x2
     f35:	test   rax,rax
     f38:	cmove  rcx,QWORD PTR [rip+0x210]        # 1150 <botlish_fn_5+0x2f0>
     f40:	jmp    f59 <botlish_fn_5+0xf9>
     f45:	mov    ecx,0x2
     f4a:	mov    rsi,QWORD PTR [rsp]
     f4e:	cmp    rsi,rdx
     f51:	cmove  rcx,QWORD PTR [rip+0x1f7]        # 1150 <botlish_fn_5+0x2f0>
     f59:	cmp    rcx,0x6
     f5d:	je     10f2 <botlish_fn_5+0x292>
     f63:	mov    rsi,QWORD PTR [rsp]
     f67:	test   rsi,0x1
     f6e:	je     f8c <botlish_fn_5+0x12c>
     f74:	mov    r10,QWORD PTR [r12+0x8]
     f79:	mov    rsi,QWORD PTR [rsp]
     f7d:	mov    r9,rsi
     f80:	sar    r9,1
     f83:	cmp    r9,r10
     f86:	jb     fb4 <botlish_fn_5+0x154>
     f8c:	mov    rdx,QWORD PTR [rsp]
     f90:	mov    rsi,r12
     f93:	mov    rdi,r15
     f96:	call   f9b <botlish_fn_5+0x13b>
			f97: R_X86_64_PLT32	rt_list_get-0x4
     f9b:	test   rax,rax
     f9e:	jne    fac <botlish_fn_5+0x14c>
     fa4:	mov    rdi,r15
     fa7:	jmp    10aa <botlish_fn_5+0x24a>
     fac:	mov    rsi,rax
     faf:	jmp    fbd <botlish_fn_5+0x15d>
     fb4:	mov    rax,QWORD PTR [r12+0x10]
     fb9:	mov    rsi,QWORD PTR [rax+r9*8]
     fbd:	mov    QWORD PTR [r14+0x20],rsi
     fc1:	mov    QWORD PTR [rsp+0x10],rsi
     fc6:	mov    QWORD PTR [r14+0x28],0x1
     fce:	mov    rax,rbx
     fd1:	or     rax,0x1
     fd5:	mov    QWORD PTR [r14+0x30],rax
     fd9:	xor    rdx,rdx
     fdc:	mov    rdi,r15
     fdf:	mov    rsi,rdx
     fe2:	call   fe7 <botlish_fn_5+0x187>
			fe3: R_X86_64_PLT32	rt_list_new-0x4
     fe7:	test   rax,rax
     fea:	jne    ff8 <botlish_fn_5+0x198>
     ff0:	mov    rdi,r15
     ff3:	jmp    10aa <botlish_fn_5+0x24a>
     ff8:	mov    QWORD PTR [r14+0x38],rax
     ffc:	mov    r9,rax
     fff:	mov    ecx,0x1
    1004:	mov    r8,rbx
    1007:	or     r8,0x1
    100b:	mov    rsi,QWORD PTR [rsp+0x10]
    1010:	mov    rdx,r13
    1013:	mov    rdi,r15
    1016:	call   101b <botlish_fn_5+0x1bb>
			1017: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
    101b:	test   rax,rax
    101e:	jne    102c <botlish_fn_5+0x1cc>
    1024:	mov    rdi,r15
    1027:	jmp    10aa <botlish_fn_5+0x24a>
    102c:	mov    QWORD PTR [r14+0x20],rax
    1030:	mov    QWORD PTR [rsp+0x10],rax
    1035:	mov    QWORD PTR [r14+0x28],0x3
    103d:	mov    rsi,QWORD PTR [rsp]
    1041:	test   rsi,0x1
    1048:	je     1070 <botlish_fn_5+0x210>
    104e:	mov    rsi,QWORD PTR [rsp]
    1052:	mov    rax,rsi
    1055:	add    rax,0x2
    1059:	seto   cl
    105c:	test   cl,cl
    105e:	jne    1070 <botlish_fn_5+0x210>
    1064:	mov    rsi,rax
    1067:	mov    QWORD PTR [rsp],rax
    106b:	jmp    1088 <botlish_fn_5+0x228>
    1070:	mov    edx,0x3
    1075:	mov    rsi,QWORD PTR [rsp]
    1079:	mov    rdi,r15
    107c:	call   1081 <botlish_fn_5+0x221>
			107d: R_X86_64_PLT32	rt_int_add-0x4
    1081:	mov    rsi,rax
    1084:	mov    QWORD PTR [rsp],rax
    1088:	mov    QWORD PTR [r14+0x10],rsi
    108c:	mov    rdx,QWORD PTR [rsp+0x10]
    1091:	mov    rsi,QWORD PTR [rsp+0x8]
    1096:	mov    rdi,r15
    1099:	call   109e <botlish_fn_5+0x23e>
			109a: R_X86_64_PLT32	rt_list_append-0x4
    109e:	test   rax,rax
    10a1:	jne    10d5 <botlish_fn_5+0x275>
    10a7:	mov    rdi,r15
    10aa:	mov    rdi,r15
    10ad:	mov    QWORD PTR [rdi],r14
    10b0:	xor    rax,rax
    10b3:	mov    rbx,QWORD PTR [rsp+0x20]
    10b8:	mov    r12,QWORD PTR [rsp+0x28]
    10bd:	mov    r13,QWORD PTR [rsp+0x30]
    10c2:	mov    r14,QWORD PTR [rsp+0x38]
    10c7:	mov    r15,QWORD PTR [rsp+0x40]
    10cc:	add    rsp,0x50
    10d0:	mov    rsp,rbp
    10d3:	pop    rbp
    10d4:	ret
    10d5:	mov    QWORD PTR [r14],r12
    10d8:	mov    QWORD PTR [r14+0x8],r13
    10dc:	mov    rsi,QWORD PTR [rsp]
    10e0:	mov    QWORD PTR [r14+0x10],rsi
    10e4:	mov    QWORD PTR [r14+0x18],rax
    10e8:	mov    QWORD PTR [rsp+0x8],rax
    10ed:	jmp    eff <botlish_fn_5+0x9f>
    10f2:	mov    rdi,r15
    10f5:	mov    QWORD PTR [rdi],r14
    10f8:	mov    rax,QWORD PTR [rsp+0x8]
    10fd:	mov    rbx,QWORD PTR [rsp+0x20]
    1102:	mov    r12,QWORD PTR [rsp+0x28]
    1107:	mov    r13,QWORD PTR [rsp+0x30]
    110c:	mov    r14,QWORD PTR [rsp+0x38]
    1111:	mov    r15,QWORD PTR [rsp+0x40]
    1116:	add    rsp,0x50
    111a:	mov    rsp,rbp
    111d:	pop    rbp
    111e:	ret
    111f:	mov    r15,rdi
    1122:	call   1127 <botlish_fn_5+0x2c7>
			1123: R_X86_64_PLT32	rt_stack_overflow-0x4
    1127:	xor    rax,rax
    112a:	mov    rbx,QWORD PTR [rsp+0x20]
    112f:	mov    r12,QWORD PTR [rsp+0x28]
    1134:	mov    r13,QWORD PTR [rsp+0x30]
    1139:	mov    r14,QWORD PTR [rsp+0x38]
    113e:	mov    r15,QWORD PTR [rsp+0x40]
    1143:	add    rsp,0x50
    1147:	mov    rsp,rbp
    114a:	pop    rbp
    114b:	ret
    114c:	add    BYTE PTR [rax],al
    114e:	add    BYTE PTR [rax],al
    1150:	(bad)
    1151:	add    BYTE PTR [rax],al
    1153:	add    BYTE PTR [rax],al
    1155:	add    BYTE PTR [rax],al
	...

0000000000001158 <botlish_entry_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
    1158:	push   rbp
    1159:	mov    rbp,rsp
    115c:	mov    rsi,QWORD PTR [rdx]
    115f:	mov    r10,QWORD PTR [rdx+0x8]
    1163:	mov    rcx,QWORD PTR [rdx+0x10]
    1167:	mov    r8,QWORD PTR [rdx+0x18]
    116b:	mov    r9,QWORD PTR [rdx+0x20]
    116f:	mov    rdx,r10
    1172:	call   1177 <botlish_entry_5+0x1f>
			1173: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
    1177:	mov    rsp,rbp
    117a:	pop    rbp
    117b:	ret

000000000000117c <botlish_fn_6: matmul<list<list<int>>, list<list<int>>>>:
    117c:	push   rbp
    117d:	mov    rbp,rsp
    1180:	sub    rsp,0x30
    1184:	mov    QWORD PTR [rsp],rbx
    1188:	mov    QWORD PTR [rsp+0x8],r12
    118d:	mov    QWORD PTR [rsp+0x10],r13
    1192:	mov    QWORD PTR [rsp+0x18],r14
    1197:	mov    QWORD PTR [rsp+0x20],r15
    119c:	mov    r12,QWORD PTR [rdi]
    119f:	mov    rax,QWORD PTR [rdi+0x8]
    11a3:	lea    rcx,[r12+0x28]
    11a8:	cmp    rcx,rax
    11ab:	ja     1347 <botlish_fn_6+0x1cb>
    11b1:	lea    rax,[r12+0x28]
    11b6:	mov    QWORD PTR [rdi],rax
    11b9:	mov    r13,rdi
    11bc:	mov    QWORD PTR [r12],0x0
    11c4:	mov    QWORD PTR [r12+0x8],0x0
    11cd:	mov    QWORD PTR [r12+0x10],0x0
    11d6:	mov    QWORD PTR [r12+0x18],0x0
    11df:	mov    QWORD PTR [r12+0x20],0x0
    11e8:	mov    QWORD PTR [r12],rsi
    11ec:	mov    r14,rsi
    11ef:	mov    QWORD PTR [r12+0x8],rdx
    11f4:	mov    rbx,rdx
    11f7:	mov    rsi,r14
    11fa:	mov    rdi,r13
    11fd:	call   1202 <botlish_fn_6+0x86>
			11fe: R_X86_64_PLT32	rt_list_len-0x4
    1202:	sar    rax,1
    1205:	test   rax,rax
    1208:	je     12dc <botlish_fn_6+0x160>
    120e:	mov    QWORD PTR [r12+0x10],0x1
    1217:	mov    rax,QWORD PTR [rbx+0x8]
    121b:	test   rax,rax
    121e:	jne    124d <botlish_fn_6+0xd1>
    1224:	mov    edx,0x1
    1229:	mov    rsi,rbx
    122c:	mov    rdi,r13
    122f:	call   1234 <botlish_fn_6+0xb8>
			1230: R_X86_64_PLT32	rt_list_get-0x4
    1234:	test   rax,rax
    1237:	jne    1245 <botlish_fn_6+0xc9>
    123d:	mov    rdi,r13
    1240:	jmp    12f6 <botlish_fn_6+0x17a>
    1245:	mov    rsi,rax
    1248:	jmp    1257 <botlish_fn_6+0xdb>
    124d:	mov    rdx,rbx
    1250:	mov    rax,QWORD PTR [rdx+0x10]
    1254:	mov    rsi,QWORD PTR [rax]
    1257:	mov    rdi,r13
    125a:	call   125f <botlish_fn_6+0xe3>
			125b: R_X86_64_PLT32	rt_list_len-0x4
    125f:	mov    QWORD PTR [r12+0x18],rax
    1264:	mov    r15,rax
    1267:	xor    rdx,rdx
    126a:	mov    rdi,r13
    126d:	mov    rsi,rdx
    1270:	call   1275 <botlish_fn_6+0xf9>
			1271: R_X86_64_PLT32	rt_list_new-0x4
    1275:	test   rax,rax
    1278:	jne    1286 <botlish_fn_6+0x10a>
    127e:	mov    rdi,r13
    1281:	jmp    12f6 <botlish_fn_6+0x17a>
    1286:	mov    QWORD PTR [r12+0x20],rax
    128b:	mov    r9,rax
    128e:	mov    ecx,0x1
    1293:	mov    rdx,rbx
    1296:	mov    rsi,r14
    1299:	mov    r8,r15
    129c:	mov    rdi,r13
    129f:	call   12a4 <botlish_fn_6+0x128>
			12a0: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
    12a4:	test   rax,rax
    12a7:	jne    12b5 <botlish_fn_6+0x139>
    12ad:	mov    rdi,r13
    12b0:	jmp    12f6 <botlish_fn_6+0x17a>
    12b5:	mov    rdi,r13
    12b8:	mov    QWORD PTR [rdi],r12
    12bb:	mov    rbx,QWORD PTR [rsp]
    12bf:	mov    r12,QWORD PTR [rsp+0x8]
    12c4:	mov    r13,QWORD PTR [rsp+0x10]
    12c9:	mov    r14,QWORD PTR [rsp+0x18]
    12ce:	mov    r15,QWORD PTR [rsp+0x20]
    12d3:	add    rsp,0x30
    12d7:	mov    rsp,rbp
    12da:	pop    rbp
    12db:	ret
    12dc:	xor    rdx,rdx
    12df:	mov    rdi,r13
    12e2:	mov    rsi,rdx
    12e5:	call   12ea <botlish_fn_6+0x16e>
			12e6: R_X86_64_PLT32	rt_list_new-0x4
    12ea:	test   rax,rax
    12ed:	jne    1320 <botlish_fn_6+0x1a4>
    12f3:	mov    rdi,r13
    12f6:	mov    rdi,r13
    12f9:	mov    QWORD PTR [rdi],r12
    12fc:	xor    rax,rax
    12ff:	mov    rbx,QWORD PTR [rsp]
    1303:	mov    r12,QWORD PTR [rsp+0x8]
    1308:	mov    r13,QWORD PTR [rsp+0x10]
    130d:	mov    r14,QWORD PTR [rsp+0x18]
    1312:	mov    r15,QWORD PTR [rsp+0x20]
    1317:	add    rsp,0x30
    131b:	mov    rsp,rbp
    131e:	pop    rbp
    131f:	ret
    1320:	mov    rdi,r13
    1323:	mov    QWORD PTR [rdi],r12
    1326:	mov    rbx,QWORD PTR [rsp]
    132a:	mov    r12,QWORD PTR [rsp+0x8]
    132f:	mov    r13,QWORD PTR [rsp+0x10]
    1334:	mov    r14,QWORD PTR [rsp+0x18]
    1339:	mov    r15,QWORD PTR [rsp+0x20]
    133e:	add    rsp,0x30
    1342:	mov    rsp,rbp
    1345:	pop    rbp
    1346:	ret
    1347:	mov    r13,rdi
    134a:	call   134f <botlish_fn_6+0x1d3>
			134b: R_X86_64_PLT32	rt_stack_overflow-0x4
    134f:	xor    rax,rax
    1352:	mov    rbx,QWORD PTR [rsp]
    1356:	mov    r12,QWORD PTR [rsp+0x8]
    135b:	mov    r13,QWORD PTR [rsp+0x10]
    1360:	mov    r14,QWORD PTR [rsp+0x18]
    1365:	mov    r15,QWORD PTR [rsp+0x20]
    136a:	add    rsp,0x30
    136e:	mov    rsp,rbp
    1371:	pop    rbp
    1372:	ret

0000000000001373 <botlish_entry_6: matmul<list<list<int>>, list<list<int>>>>:
    1373:	push   rbp
    1374:	mov    rbp,rsp
    1377:	mov    rsi,QWORD PTR [rdx]
    137a:	mov    rdx,QWORD PTR [rdx+0x8]
    137e:	call   1383 <botlish_entry_6+0x10>
			137f: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
    1383:	mov    rsp,rbp
    1386:	pop    rbp
    1387:	ret

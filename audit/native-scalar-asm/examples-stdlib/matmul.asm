; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5140  (per function: 948 703 623 756 694 852 564)
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
       4:	sub    rsp,0xe0
       b:	mov    QWORD PTR [rsp+0xb0],rbx
      13:	mov    QWORD PTR [rsp+0xb8],r12
      1b:	mov    QWORD PTR [rsp+0xc0],r13
      23:	mov    QWORD PTR [rsp+0xc8],r14
      2b:	mov    QWORD PTR [rsp+0xd0],r15
      33:	mov    rbx,QWORD PTR [rdi]
      36:	mov    rax,QWORD PTR [rdi+0x8]
      3a:	lea    rcx,[rbx+0x8]
      3e:	cmp    rcx,rax
      41:	ja     32e <botlish_fn_0+0x32e>
      47:	lea    rax,[rbx+0x8]
      4b:	mov    QWORD PTR [rdi],rax
      4e:	mov    r12,rdi
      51:	mov    QWORD PTR [rbx],0x0
      58:	mov    QWORD PTR [rsp+0x18],0x0
      61:	mov    QWORD PTR [rsp+0x20],0x0
      6a:	mov    esi,0x3
      6f:	mov    QWORD PTR [rsp],0x3
      77:	mov    QWORD PTR [rsp+0x8],0x5
      80:	mov    QWORD PTR [rsp+0x10],0x7
      89:	lea    rdx,[rsp+0x28]
      8e:	mov    QWORD PTR [rsp+0x28],0x3
      97:	mov    QWORD PTR [rsp+0x30],0x5
      a0:	mov    QWORD PTR [rsp+0x38],0x7
      a9:	mov    rdi,r12
      ac:	call   b1 <botlish_fn_0+0xb1>
			ad: R_X86_64_PLT32	rt_list_new-0x4
      b1:	test   rax,rax
      b4:	jne    c2 <botlish_fn_0+0xc2>
      ba:	mov    rdi,r12
      bd:	jmp    2b7 <botlish_fn_0+0x2b7>
      c2:	mov    QWORD PTR [rsp],rax
      c6:	mov    r13,rax
      c9:	mov    QWORD PTR [rsp+0x8],0x9
      d2:	mov    QWORD PTR [rsp+0x10],0xb
      db:	mov    QWORD PTR [rsp+0x18],0xd
      e4:	lea    rdx,[rsp+0x40]
      e9:	mov    QWORD PTR [rsp+0x40],0x9
      f2:	mov    QWORD PTR [rsp+0x48],0xb
      fb:	mov    QWORD PTR [rsp+0x50],0xd
     104:	mov    esi,0x3
     109:	mov    rdi,r12
     10c:	call   111 <botlish_fn_0+0x111>
			10d: R_X86_64_PLT32	rt_list_new-0x4
     111:	test   rax,rax
     114:	jne    122 <botlish_fn_0+0x122>
     11a:	mov    rdi,r12
     11d:	jmp    2b7 <botlish_fn_0+0x2b7>
     122:	mov    QWORD PTR [rsp+0x8],rax
     127:	lea    rdx,[rsp+0x58]
     12c:	mov    rcx,r13
     12f:	mov    QWORD PTR [rsp+0x58],rcx
     134:	mov    QWORD PTR [rsp+0x60],rax
     139:	mov    esi,0x2
     13e:	mov    rdi,r12
     141:	call   146 <botlish_fn_0+0x146>
			142: R_X86_64_PLT32	rt_list_new-0x4
     146:	test   rax,rax
     149:	jne    157 <botlish_fn_0+0x157>
     14f:	mov    rdi,r12
     152:	jmp    2b7 <botlish_fn_0+0x2b7>
     157:	mov    QWORD PTR [rsp],rax
     15b:	mov    r13,rax
     15e:	mov    QWORD PTR [rsp+0x8],0xf
     167:	mov    QWORD PTR [rsp+0x10],0x11
     170:	lea    rdx,[rsp+0x68]
     175:	mov    QWORD PTR [rsp+0x68],0xf
     17e:	mov    QWORD PTR [rsp+0x70],0x11
     187:	mov    esi,0x2
     18c:	mov    rdi,r12
     18f:	call   194 <botlish_fn_0+0x194>
			190: R_X86_64_PLT32	rt_list_new-0x4
     194:	test   rax,rax
     197:	jne    1a5 <botlish_fn_0+0x1a5>
     19d:	mov    rdi,r12
     1a0:	jmp    2b7 <botlish_fn_0+0x2b7>
     1a5:	mov    QWORD PTR [rsp+0x8],rax
     1aa:	mov    r14,rax
     1ad:	mov    QWORD PTR [rsp+0x10],0x13
     1b6:	mov    QWORD PTR [rsp+0x18],0x15
     1bf:	lea    rdx,[rsp+0x78]
     1c4:	mov    QWORD PTR [rsp+0x78],0x13
     1cd:	mov    QWORD PTR [rsp+0x80],0x15
     1d9:	mov    esi,0x2
     1de:	mov    rdi,r12
     1e1:	call   1e6 <botlish_fn_0+0x1e6>
			1e2: R_X86_64_PLT32	rt_list_new-0x4
     1e6:	test   rax,rax
     1e9:	jne    1f7 <botlish_fn_0+0x1f7>
     1ef:	mov    rdi,r12
     1f2:	jmp    2b7 <botlish_fn_0+0x2b7>
     1f7:	mov    QWORD PTR [rsp+0x10],rax
     1fc:	mov    r15,rax
     1ff:	mov    QWORD PTR [rsp+0x18],0x17
     208:	mov    QWORD PTR [rsp+0x20],0x19
     211:	lea    rdx,[rsp+0x88]
     219:	mov    QWORD PTR [rsp+0x88],0x17
     225:	mov    QWORD PTR [rsp+0x90],0x19
     231:	mov    esi,0x2
     236:	mov    rdi,r12
     239:	call   23e <botlish_fn_0+0x23e>
			23a: R_X86_64_PLT32	rt_list_new-0x4
     23e:	test   rax,rax
     241:	jne    24f <botlish_fn_0+0x24f>
     247:	mov    rdi,r12
     24a:	jmp    2b7 <botlish_fn_0+0x2b7>
     24f:	mov    QWORD PTR [rsp+0x18],rax
     254:	lea    rdx,[rsp+0x98]
     25c:	mov    rcx,r14
     25f:	mov    QWORD PTR [rsp+0x98],rcx
     267:	mov    rcx,r15
     26a:	mov    QWORD PTR [rsp+0xa0],rcx
     272:	mov    QWORD PTR [rsp+0xa8],rax
     27a:	mov    esi,0x3
     27f:	mov    rdi,r12
     282:	call   287 <botlish_fn_0+0x287>
			283: R_X86_64_PLT32	rt_list_new-0x4
     287:	test   rax,rax
     28a:	jne    298 <botlish_fn_0+0x298>
     290:	mov    rdi,r12
     293:	jmp    2b7 <botlish_fn_0+0x2b7>
     298:	mov    QWORD PTR [rsp+0x8],rax
     29d:	mov    rdx,rax
     2a0:	mov    rsi,r13
     2a3:	mov    rdi,r12
     2a6:	call   2ab <botlish_fn_0+0x2ab>
			2a7: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
     2ab:	test   rax,rax
     2ae:	jne    2f4 <botlish_fn_0+0x2f4>
     2b4:	mov    rdi,r12
     2b7:	mov    rdi,r12
     2ba:	mov    QWORD PTR [rdi],rbx
     2bd:	xor    rax,rax
     2c0:	mov    rbx,QWORD PTR [rsp+0xb0]
     2c8:	mov    r12,QWORD PTR [rsp+0xb8]
     2d0:	mov    r13,QWORD PTR [rsp+0xc0]
     2d8:	mov    r14,QWORD PTR [rsp+0xc8]
     2e0:	mov    r15,QWORD PTR [rsp+0xd0]
     2e8:	add    rsp,0xe0
     2ef:	mov    rsp,rbp
     2f2:	pop    rbp
     2f3:	ret
     2f4:	mov    rdi,r12
     2f7:	mov    QWORD PTR [rdi],rbx
     2fa:	mov    rbx,QWORD PTR [rsp+0xb0]
     302:	mov    r12,QWORD PTR [rsp+0xb8]
     30a:	mov    r13,QWORD PTR [rsp+0xc0]
     312:	mov    r14,QWORD PTR [rsp+0xc8]
     31a:	mov    r15,QWORD PTR [rsp+0xd0]
     322:	add    rsp,0xe0
     329:	mov    rsp,rbp
     32c:	pop    rbp
     32d:	ret
     32e:	mov    r12,rdi
     331:	call   336 <botlish_fn_0+0x336>
			332: R_X86_64_PLT32	rt_stack_overflow-0x4
     336:	xor    rax,rax
     339:	mov    rbx,QWORD PTR [rsp+0xb0]
     341:	mov    r12,QWORD PTR [rsp+0xb8]
     349:	mov    r13,QWORD PTR [rsp+0xc0]
     351:	mov    r14,QWORD PTR [rsp+0xc8]
     359:	mov    r15,QWORD PTR [rsp+0xd0]
     361:	add    rsp,0xe0
     368:	mov    rsp,rbp
     36b:	pop    rbp
     36c:	ret

000000000000036d <botlish_entry_0: <program entry>>:
     36d:	push   rbp
     36e:	mov    rbp,rsp
     371:	call   376 <botlish_entry_0+0x9>
			372: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     376:	mov    rsp,rbp
     379:	pop    rbp
     37a:	ret

000000000000037b <botlish_fn_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     37b:	push   rbp
     37c:	mov    rbp,rsp
     37f:	sub    rsp,0x80
     386:	mov    QWORD PTR [rsp+0x50],rbx
     38b:	mov    QWORD PTR [rsp+0x58],r12
     390:	mov    QWORD PTR [rsp+0x60],r13
     395:	mov    QWORD PTR [rsp+0x68],r14
     39a:	mov    QWORD PTR [rsp+0x70],r15
     39f:	mov    QWORD PTR [rsp+0x30],rdi
     3a4:	mov    rdi,QWORD PTR [rbp+0x10]
     3a8:	mov    QWORD PTR [rsp],rsi
     3ac:	mov    r10,rsi
     3af:	mov    QWORD PTR [rsp+0x8],rdx
     3b4:	mov    r13,rdx
     3b7:	mov    QWORD PTR [rsp+0x10],rcx
     3bc:	mov    QWORD PTR [rsp+0x18],rdi
     3c1:	sar    r8,1
     3c4:	sar    r9,1
     3c7:	mov    QWORD PTR [rsp+0x48],r9
     3cc:	mov    rbx,rcx
     3cf:	sar    rbx,1
     3d2:	mov    r14,rcx
     3d5:	mov    rsi,QWORD PTR [rsp+0x48]
     3da:	mov    r12,r8
     3dd:	mov    QWORD PTR [rsp+0x38],rdi
     3e2:	cmp    r12,rsi
     3e5:	mov    QWORD PTR [rsp+0x48],rsi
     3ea:	je     5b8 <botlish_fn_1+0x23d>
     3f0:	mov    r15,r10
     3f3:	mov    rsi,QWORD PTR [r15+0x8]
     3f7:	mov    rcx,r12
     3fa:	shl    rcx,1
     3fd:	or     rcx,0x1
     401:	sar    rcx,1
     404:	cmp    rcx,rsi
     407:	jb     435 <botlish_fn_1+0xba>
     40d:	mov    rdx,r12
     410:	shl    rdx,1
     413:	or     rdx,0x1
     417:	mov    rsi,r15
     41a:	mov    rdi,QWORD PTR [rsp+0x30]
     41f:	call   424 <botlish_fn_1+0xa9>
			420: R_X86_64_PLT32	rt_list_get-0x4
     424:	test   rax,rax
     427:	je     4c1 <botlish_fn_1+0x146>
     42d:	mov    rsi,rax
     430:	jmp    43d <botlish_fn_1+0xc2>
     435:	mov    r9,QWORD PTR [r15+0x10]
     439:	mov    rsi,QWORD PTR [r9+rcx*8]
     43d:	mov    QWORD PTR [rsp+0x20],rsi
     442:	mov    QWORD PTR [rsp+0x40],rsi
     447:	mov    rax,QWORD PTR [r13+0x8]
     44b:	mov    r10,r12
     44e:	shl    r10,1
     451:	or     r10,0x1
     455:	sar    r10,1
     458:	cmp    r10,rax
     45b:	jb     489 <botlish_fn_1+0x10e>
     461:	mov    rdx,r12
     464:	shl    rdx,1
     467:	or     rdx,0x1
     46b:	mov    rsi,r13
     46e:	mov    rdi,QWORD PTR [rsp+0x30]
     473:	call   478 <botlish_fn_1+0xfd>
			474: R_X86_64_PLT32	rt_list_get-0x4
     478:	test   rax,rax
     47b:	je     4c1 <botlish_fn_1+0x146>
     481:	mov    rsi,rax
     484:	jmp    491 <botlish_fn_1+0x116>
     489:	mov    rax,QWORD PTR [r13+0x10]
     48d:	mov    rsi,QWORD PTR [rax+r10*8]
     491:	test   r14,0x1
     498:	je     4ab <botlish_fn_1+0x130>
     49e:	mov    rax,QWORD PTR [rsi+0x8]
     4a2:	cmp    rbx,rax
     4a5:	jb     4f1 <botlish_fn_1+0x176>
     4ab:	mov    rdx,r14
     4ae:	mov    rdi,QWORD PTR [rsp+0x30]
     4b3:	call   4b8 <botlish_fn_1+0x13d>
			4b4: R_X86_64_PLT32	rt_list_get-0x4
     4b8:	test   rax,rax
     4bb:	jne    4e9 <botlish_fn_1+0x16e>
     4c1:	xor    rax,rax
     4c4:	mov    rbx,QWORD PTR [rsp+0x50]
     4c9:	mov    r12,QWORD PTR [rsp+0x58]
     4ce:	mov    r13,QWORD PTR [rsp+0x60]
     4d3:	mov    r14,QWORD PTR [rsp+0x68]
     4d8:	mov    r15,QWORD PTR [rsp+0x70]
     4dd:	add    rsp,0x80
     4e4:	mov    rsp,rbp
     4e7:	pop    rbp
     4e8:	ret
     4e9:	mov    rdx,rax
     4ec:	jmp    4f9 <botlish_fn_1+0x17e>
     4f1:	mov    rax,QWORD PTR [rsi+0x10]
     4f5:	mov    rdx,QWORD PTR [rax+rbx*8]
     4f9:	mov    QWORD PTR [rsp+0x28],rdx
     4fe:	mov    rsi,QWORD PTR [rsp+0x40]
     503:	mov    rax,rsi
     506:	and    rax,rdx
     509:	test   rax,0x1
     50f:	je     544 <botlish_fn_1+0x1c9>
     515:	mov    rax,rsi
     518:	sar    rax,1
     51b:	lea    rcx,[rdx-0x1]
     51f:	mov    rdi,rdx
     522:	imul   rcx
     525:	seto   cl
     528:	or     rax,0x1
     52c:	test   cl,cl
     52e:	je     53c <botlish_fn_1+0x1c1>
     534:	mov    rdx,rdi
     537:	jmp    544 <botlish_fn_1+0x1c9>
     53c:	mov    rdx,rax
     53f:	jmp    551 <botlish_fn_1+0x1d6>
     544:	mov    rdi,QWORD PTR [rsp+0x30]
     549:	call   54e <botlish_fn_1+0x1d3>
			54a: R_X86_64_PLT32	rt_int_mul-0x4
     54e:	mov    rdx,rax
     551:	mov    QWORD PTR [rsp+0x20],rdx
     556:	mov    rsi,QWORD PTR [rsp+0x38]
     55b:	mov    rax,rsi
     55e:	and    rax,rdx
     561:	test   rax,0x1
     567:	je     582 <botlish_fn_1+0x207>
     56d:	lea    rcx,[rdx-0x1]
     571:	mov    rax,rsi
     574:	add    rax,rcx
     577:	seto   cl
     57a:	test   cl,cl
     57c:	je     58c <botlish_fn_1+0x211>
     582:	mov    rdi,QWORD PTR [rsp+0x30]
     587:	call   58c <botlish_fn_1+0x211>
			588: R_X86_64_PLT32	rt_int_add-0x4
     58c:	mov    QWORD PTR [rsp],r15
     590:	mov    QWORD PTR [rsp+0x8],r13
     595:	mov    QWORD PTR [rsp+0x10],r14
     59a:	mov    QWORD PTR [rsp+0x18],rax
     59f:	add    r12,0x1
     5a6:	mov    rsi,QWORD PTR [rsp+0x48]
     5ab:	mov    r10,r15
     5ae:	mov    QWORD PTR [rsp+0x38],rax
     5b3:	jmp    3e2 <botlish_fn_1+0x67>
     5b8:	mov    rax,QWORD PTR [rsp+0x38]
     5bd:	mov    rbx,QWORD PTR [rsp+0x50]
     5c2:	mov    r12,QWORD PTR [rsp+0x58]
     5c7:	mov    r13,QWORD PTR [rsp+0x60]
     5cc:	mov    r14,QWORD PTR [rsp+0x68]
     5d1:	mov    r15,QWORD PTR [rsp+0x70]
     5d6:	add    rsp,0x80
     5dd:	mov    rsp,rbp
     5e0:	pop    rbp
     5e1:	ret

00000000000005e2 <botlish_entry_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     5e2:	push   rbp
     5e3:	mov    rbp,rsp
     5e6:	sub    rsp,0x10
     5ea:	mov    rsi,QWORD PTR [rdx]
     5ed:	mov    r10,QWORD PTR [rdx+0x8]
     5f1:	mov    rcx,QWORD PTR [rdx+0x10]
     5f5:	mov    r8,QWORD PTR [rdx+0x18]
     5f9:	mov    r9,QWORD PTR [rdx+0x20]
     5fd:	mov    r11,QWORD PTR [rdx+0x28]
     601:	mov    QWORD PTR [rsp],r11
     605:	mov    rdx,r10
     608:	call   60d <botlish_entry_1+0x2b>
			609: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     60d:	add    rsp,0x10
     611:	mov    rsp,rbp
     614:	pop    rbp
     615:	ret

0000000000000616 <botlish_fn_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     616:	push   rbp
     617:	mov    rbp,rsp
     61a:	sub    rsp,0xa0
     621:	mov    QWORD PTR [rsp+0x70],rbx
     626:	mov    QWORD PTR [rsp+0x78],r12
     62b:	mov    QWORD PTR [rsp+0x80],r13
     633:	mov    QWORD PTR [rsp+0x88],r14
     63b:	mov    QWORD PTR [rsp+0x90],r15
     643:	mov    r13,QWORD PTR [rdi]
     646:	mov    rax,QWORD PTR [rdi+0x8]
     64a:	lea    r10,[r13+0x8]
     64e:	cmp    r10,rax
     651:	ja     813 <botlish_fn_2+0x1fd>
     657:	lea    rax,[r13+0x8]
     65b:	mov    QWORD PTR [rdi],rax
     65e:	mov    r14,rdi
     661:	mov    QWORD PTR [r13+0x0],0x0
     669:	mov    QWORD PTR [rsp+0x10],rsi
     66e:	mov    QWORD PTR [rsp+0x50],rsi
     673:	mov    QWORD PTR [rsp+0x18],rdx
     678:	mov    QWORD PTR [rsp+0x58],rdx
     67d:	mov    QWORD PTR [rsp+0x20],rcx
     682:	mov    QWORD PTR [rsp+0x28],r8
     687:	mov    QWORD PTR [rsp+0x30],r9
     68c:	mov    QWORD PTR [rsp+0x68],r9
     691:	mov    rbx,rcx
     694:	sar    rbx,1
     697:	mov    QWORD PTR [rsp+0x60],rcx
     69c:	mov    rax,r8
     69f:	sar    rax,1
     6a2:	mov    r15,r8
     6a5:	cmp    rbx,rax
     6a8:	je     7da <botlish_fn_2+0x1c4>
     6ae:	mov    r12d,0x1
     6b4:	mov    QWORD PTR [rsp+0x38],0x1
     6bd:	mov    rsi,QWORD PTR [rsp+0x50]
     6c2:	mov    rdi,r14
     6c5:	call   6ca <botlish_fn_2+0xb4>
			6c6: R_X86_64_PLT32	rt_list_len-0x4
     6ca:	mov    QWORD PTR [rsp+0x40],rax
     6cf:	mov    QWORD PTR [rsp+0x48],0x1
     6d8:	mov    QWORD PTR [rsp],r12
     6dc:	mov    rcx,QWORD PTR [rsp+0x60]
     6e1:	mov    r8,r12
     6e4:	mov    r9,rax
     6e7:	mov    rdx,QWORD PTR [rsp+0x58]
     6ec:	mov    rsi,QWORD PTR [rsp+0x50]
     6f1:	mov    rdi,r14
     6f4:	call   6f9 <botlish_fn_2+0xe3>
			6f5: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     6f9:	test   rax,rax
     6fc:	jne    70a <botlish_fn_2+0xf4>
     702:	mov    rdi,r14
     705:	jmp    76f <botlish_fn_2+0x159>
     70a:	mov    QWORD PTR [rsp+0x20],rax
     70f:	mov    rdx,rax
     712:	lea    rcx,[rbx+0x1]
     716:	shl    rcx,1
     719:	or     rcx,0x1
     71d:	mov    QWORD PTR [rsp+0x38],rcx
     722:	mov    rbx,rcx
     725:	mov    rsi,QWORD PTR [rsp+0x68]
     72a:	mov    rdi,r14
     72d:	call   732 <botlish_fn_2+0x11c>
			72e: R_X86_64_PLT32	rt_list_append-0x4
     732:	test   rax,rax
     735:	jne    743 <botlish_fn_2+0x12d>
     73b:	mov    rdi,r14
     73e:	jmp    76f <botlish_fn_2+0x159>
     743:	mov    QWORD PTR [rsp+0x20],rax
     748:	mov    rcx,rbx
     74b:	mov    rdx,QWORD PTR [rsp+0x58]
     750:	mov    rsi,QWORD PTR [rsp+0x50]
     755:	mov    r8,r15
     758:	mov    r9,rax
     75b:	mov    rdi,r14
     75e:	call   763 <botlish_fn_2+0x14d>
			75f: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     763:	test   rax,rax
     766:	jne    7a6 <botlish_fn_2+0x190>
     76c:	mov    rdi,r14
     76f:	mov    rdi,r14
     772:	mov    QWORD PTR [rdi],r13
     775:	xor    rax,rax
     778:	mov    rbx,QWORD PTR [rsp+0x70]
     77d:	mov    r12,QWORD PTR [rsp+0x78]
     782:	mov    r13,QWORD PTR [rsp+0x80]
     78a:	mov    r14,QWORD PTR [rsp+0x88]
     792:	mov    r15,QWORD PTR [rsp+0x90]
     79a:	add    rsp,0xa0
     7a1:	mov    rsp,rbp
     7a4:	pop    rbp
     7a5:	ret
     7a6:	mov    rdi,r14
     7a9:	mov    QWORD PTR [rdi],r13
     7ac:	mov    rbx,QWORD PTR [rsp+0x70]
     7b1:	mov    r12,QWORD PTR [rsp+0x78]
     7b6:	mov    r13,QWORD PTR [rsp+0x80]
     7be:	mov    r14,QWORD PTR [rsp+0x88]
     7c6:	mov    r15,QWORD PTR [rsp+0x90]
     7ce:	add    rsp,0xa0
     7d5:	mov    rsp,rbp
     7d8:	pop    rbp
     7d9:	ret
     7da:	mov    rdi,r14
     7dd:	mov    QWORD PTR [rdi],r13
     7e0:	mov    rax,QWORD PTR [rsp+0x68]
     7e5:	mov    rbx,QWORD PTR [rsp+0x70]
     7ea:	mov    r12,QWORD PTR [rsp+0x78]
     7ef:	mov    r13,QWORD PTR [rsp+0x80]
     7f7:	mov    r14,QWORD PTR [rsp+0x88]
     7ff:	mov    r15,QWORD PTR [rsp+0x90]
     807:	add    rsp,0xa0
     80e:	mov    rsp,rbp
     811:	pop    rbp
     812:	ret
     813:	mov    r14,rdi
     816:	call   81b <botlish_fn_2+0x205>
			817: R_X86_64_PLT32	rt_stack_overflow-0x4
     81b:	xor    rax,rax
     81e:	mov    rbx,QWORD PTR [rsp+0x70]
     823:	mov    r12,QWORD PTR [rsp+0x78]
     828:	mov    r13,QWORD PTR [rsp+0x80]
     830:	mov    r14,QWORD PTR [rsp+0x88]
     838:	mov    r15,QWORD PTR [rsp+0x90]
     840:	add    rsp,0xa0
     847:	mov    rsp,rbp
     84a:	pop    rbp
     84b:	ret

000000000000084c <botlish_entry_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     84c:	push   rbp
     84d:	mov    rbp,rsp
     850:	mov    rsi,QWORD PTR [rdx]
     853:	mov    r10,QWORD PTR [rdx+0x8]
     857:	mov    rcx,QWORD PTR [rdx+0x10]
     85b:	mov    r8,QWORD PTR [rdx+0x18]
     85f:	mov    r9,QWORD PTR [rdx+0x20]
     863:	mov    rdx,r10
     866:	call   86b <botlish_entry_2+0x1f>
			867: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     86b:	mov    rsp,rbp
     86e:	pop    rbp
     86f:	ret

0000000000000870 <botlish_fn_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     870:	push   rbp
     871:	mov    rbp,rsp
     874:	sub    rsp,0x90
     87b:	mov    QWORD PTR [rsp+0x60],rbx
     880:	mov    QWORD PTR [rsp+0x68],r12
     885:	mov    QWORD PTR [rsp+0x70],r13
     88a:	mov    QWORD PTR [rsp+0x78],r14
     88f:	mov    QWORD PTR [rsp+0x80],r15
     897:	mov    r10,r8
     89a:	mov    r12,QWORD PTR [rdi]
     89d:	mov    rax,QWORD PTR [rdi+0x8]
     8a1:	lea    r8,[r12+0x8]
     8a6:	cmp    r8,rax
     8a9:	ja     aca <botlish_fn_3+0x25a>
     8af:	lea    rax,[r12+0x8]
     8b4:	mov    QWORD PTR [rdi],rax
     8b7:	mov    QWORD PTR [rsp+0x48],rdi
     8bc:	mov    QWORD PTR [r12],0x0
     8c4:	mov    QWORD PTR [rsp+0x10],rsi
     8c9:	mov    r13,rsi
     8cc:	mov    QWORD PTR [rsp+0x18],rdx
     8d1:	mov    r15,rdx
     8d4:	mov    QWORD PTR [rsp+0x20],rcx
     8d9:	mov    QWORD PTR [rsp+0x28],r9
     8de:	mov    rbx,r10
     8e1:	mov    rsi,rcx
     8e4:	mov    QWORD PTR [rsp+0x58],r9
     8e9:	mov    rax,rbx
     8ec:	or     rax,0x1
     8f0:	mov    rcx,rsi
     8f3:	and    rcx,rax
     8f6:	mov    QWORD PTR [rsp+0x50],rsi
     8fb:	test   rcx,0x1
     902:	jne    933 <botlish_fn_3+0xc3>
     908:	mov    rdx,rbx
     90b:	or     rdx,0x1
     90f:	mov    rsi,QWORD PTR [rsp+0x50]
     914:	mov    rdi,QWORD PTR [rsp+0x48]
     919:	call   91e <botlish_fn_3+0xae>
			91a: R_X86_64_PLT32	rt_int_cmp-0x4
     91e:	mov    ecx,0x2
     923:	test   rax,rax
     926:	cmove  rcx,QWORD PTR [rip+0x1d2]        # b00 <botlish_fn_3+0x290>
     92e:	jmp    94f <botlish_fn_3+0xdf>
     933:	mov    rax,rbx
     936:	or     rax,0x1
     93a:	mov    ecx,0x2
     93f:	mov    rsi,QWORD PTR [rsp+0x50]
     944:	cmp    rsi,rax
     947:	cmove  rcx,QWORD PTR [rip+0x1b1]        # b00 <botlish_fn_3+0x290>
     94f:	cmp    rcx,0x6
     953:	je     a95 <botlish_fn_3+0x225>
     959:	mov    r14d,0x1
     95f:	mov    QWORD PTR [rsp+0x30],0x1
     968:	mov    rsi,r13
     96b:	mov    rdi,QWORD PTR [rsp+0x48]
     970:	call   975 <botlish_fn_3+0x105>
			971: R_X86_64_PLT32	rt_list_len-0x4
     975:	mov    QWORD PTR [rsp+0x38],rax
     97a:	mov    QWORD PTR [rsp+0x40],0x1
     983:	mov    QWORD PTR [rsp],r14
     987:	mov    r8,r14
     98a:	mov    r9,rax
     98d:	mov    rcx,QWORD PTR [rsp+0x50]
     992:	mov    rdx,r15
     995:	mov    rsi,r13
     998:	mov    rdi,QWORD PTR [rsp+0x48]
     99d:	call   9a2 <botlish_fn_3+0x132>
			99e: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     9a2:	test   rax,rax
     9a5:	jne    9b5 <botlish_fn_3+0x145>
     9ab:	mov    rdi,QWORD PTR [rsp+0x48]
     9b0:	jmp    a3f <botlish_fn_3+0x1cf>
     9b5:	mov    QWORD PTR [rsp+0x30],rax
     9ba:	mov    r14,rax
     9bd:	mov    QWORD PTR [rsp+0x38],0x3
     9c6:	mov    rsi,QWORD PTR [rsp+0x50]
     9cb:	test   rsi,0x1
     9d2:	je     9fe <botlish_fn_3+0x18e>
     9d8:	mov    rsi,QWORD PTR [rsp+0x50]
     9dd:	mov    rdx,rsi
     9e0:	add    rdx,0x2
     9e4:	seto   sil
     9e8:	test   sil,sil
     9eb:	jne    9fe <botlish_fn_3+0x18e>
     9f1:	mov    rsi,rdx
     9f4:	mov    QWORD PTR [rsp+0x50],rdx
     9f9:	jmp    a1a <botlish_fn_3+0x1aa>
     9fe:	mov    edx,0x3
     a03:	mov    rsi,QWORD PTR [rsp+0x50]
     a08:	mov    rdi,QWORD PTR [rsp+0x48]
     a0d:	call   a12 <botlish_fn_3+0x1a2>
			a0e: R_X86_64_PLT32	rt_int_add-0x4
     a12:	mov    rsi,rax
     a15:	mov    QWORD PTR [rsp+0x50],rax
     a1a:	mov    QWORD PTR [rsp+0x20],rsi
     a1f:	mov    rdx,r14
     a22:	mov    rsi,QWORD PTR [rsp+0x58]
     a27:	mov    rdi,QWORD PTR [rsp+0x48]
     a2c:	call   a31 <botlish_fn_3+0x1c1>
			a2d: R_X86_64_PLT32	rt_list_append-0x4
     a31:	test   rax,rax
     a34:	jne    a72 <botlish_fn_3+0x202>
     a3a:	mov    rdi,QWORD PTR [rsp+0x48]
     a3f:	mov    rdi,QWORD PTR [rsp+0x48]
     a44:	mov    QWORD PTR [rdi],r12
     a47:	xor    rax,rax
     a4a:	mov    rbx,QWORD PTR [rsp+0x60]
     a4f:	mov    r12,QWORD PTR [rsp+0x68]
     a54:	mov    r13,QWORD PTR [rsp+0x70]
     a59:	mov    r14,QWORD PTR [rsp+0x78]
     a5e:	mov    r15,QWORD PTR [rsp+0x80]
     a66:	add    rsp,0x90
     a6d:	mov    rsp,rbp
     a70:	pop    rbp
     a71:	ret
     a72:	mov    QWORD PTR [rsp+0x10],r13
     a77:	mov    QWORD PTR [rsp+0x18],r15
     a7c:	mov    rsi,QWORD PTR [rsp+0x50]
     a81:	mov    QWORD PTR [rsp+0x20],rsi
     a86:	mov    QWORD PTR [rsp+0x28],rax
     a8b:	mov    QWORD PTR [rsp+0x58],rax
     a90:	jmp    8e9 <botlish_fn_3+0x79>
     a95:	mov    rdi,QWORD PTR [rsp+0x48]
     a9a:	mov    QWORD PTR [rdi],r12
     a9d:	mov    rax,QWORD PTR [rsp+0x58]
     aa2:	mov    rbx,QWORD PTR [rsp+0x60]
     aa7:	mov    r12,QWORD PTR [rsp+0x68]
     aac:	mov    r13,QWORD PTR [rsp+0x70]
     ab1:	mov    r14,QWORD PTR [rsp+0x78]
     ab6:	mov    r15,QWORD PTR [rsp+0x80]
     abe:	add    rsp,0x90
     ac5:	mov    rsp,rbp
     ac8:	pop    rbp
     ac9:	ret
     aca:	mov    QWORD PTR [rsp+0x48],rdi
     acf:	call   ad4 <botlish_fn_3+0x264>
			ad0: R_X86_64_PLT32	rt_stack_overflow-0x4
     ad4:	xor    rax,rax
     ad7:	mov    rbx,QWORD PTR [rsp+0x60]
     adc:	mov    r12,QWORD PTR [rsp+0x68]
     ae1:	mov    r13,QWORD PTR [rsp+0x70]
     ae6:	mov    r14,QWORD PTR [rsp+0x78]
     aeb:	mov    r15,QWORD PTR [rsp+0x80]
     af3:	add    rsp,0x90
     afa:	mov    rsp,rbp
     afd:	pop    rbp
     afe:	ret
     aff:	add    BYTE PTR [rsi],al
     b01:	add    BYTE PTR [rax],al
     b03:	add    BYTE PTR [rax],al
     b05:	add    BYTE PTR [rax],al
	...

0000000000000b08 <botlish_entry_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     b08:	push   rbp
     b09:	mov    rbp,rsp
     b0c:	mov    rsi,QWORD PTR [rdx]
     b0f:	mov    r10,QWORD PTR [rdx+0x8]
     b13:	mov    rcx,QWORD PTR [rdx+0x10]
     b17:	mov    r8,QWORD PTR [rdx+0x18]
     b1b:	mov    r9,QWORD PTR [rdx+0x20]
     b1f:	mov    rdx,r10
     b22:	call   b27 <botlish_entry_3+0x1f>
			b23: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     b27:	mov    rsp,rbp
     b2a:	pop    rbp
     b2b:	ret

0000000000000b2c <botlish_fn_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     b2c:	push   rbp
     b2d:	mov    rbp,rsp
     b30:	sub    rsp,0x80
     b37:	mov    QWORD PTR [rsp+0x50],rbx
     b3c:	mov    QWORD PTR [rsp+0x58],r12
     b41:	mov    QWORD PTR [rsp+0x60],r13
     b46:	mov    QWORD PTR [rsp+0x68],r14
     b4b:	mov    QWORD PTR [rsp+0x70],r15
     b50:	mov    rbx,rcx
     b53:	mov    r12,QWORD PTR [rdi]
     b56:	mov    rax,QWORD PTR [rdi+0x8]
     b5a:	lea    rcx,[r12+0x8]
     b5f:	cmp    rcx,rax
     b62:	ja     d72 <botlish_fn_4+0x246>
     b68:	lea    rax,[r12+0x8]
     b6d:	mov    QWORD PTR [rdi],rax
     b70:	mov    r13,rdi
     b73:	mov    QWORD PTR [r12],0x0
     b7b:	mov    QWORD PTR [rsp+0x30],0x0
     b84:	mov    QWORD PTR [rsp],rsi
     b88:	mov    QWORD PTR [rsp+0x38],rsi
     b8d:	mov    QWORD PTR [rsp+0x8],rdx
     b92:	mov    r15,rdx
     b95:	mov    QWORD PTR [rsp+0x10],r8
     b9a:	mov    r14,r8
     b9d:	mov    QWORD PTR [rsp+0x18],r9
     ba2:	mov    QWORD PTR [rsp+0x40],r9
     ba7:	mov    rsi,QWORD PTR [rsp+0x38]
     bac:	mov    rdi,r13
     baf:	call   bb4 <botlish_fn_4+0x88>
			bb0: R_X86_64_PLT32	rt_list_len-0x4
     bb4:	mov    rcx,rbx
     bb7:	sar    rbx,1
     bba:	sar    rax,1
     bbd:	cmp    rbx,rax
     bc0:	je     d42 <botlish_fn_4+0x216>
     bc6:	test   rcx,0x1
     bcd:	jne    bdb <botlish_fn_4+0xaf>
     bd3:	mov    rdx,rcx
     bd6:	jmp    bf0 <botlish_fn_4+0xc4>
     bdb:	mov    rsi,QWORD PTR [rsp+0x38]
     be0:	mov    rax,QWORD PTR [rsi+0x8]
     be4:	cmp    rbx,rax
     be7:	jb     c16 <botlish_fn_4+0xea>
     bed:	mov    rdx,rcx
     bf0:	mov    rsi,QWORD PTR [rsp+0x38]
     bf5:	mov    rdi,r13
     bf8:	call   bfd <botlish_fn_4+0xd1>
			bf9: R_X86_64_PLT32	rt_list_get-0x4
     bfd:	test   rax,rax
     c00:	jne    c0e <botlish_fn_4+0xe2>
     c06:	mov    rdi,r13
     c09:	jmp    ce9 <botlish_fn_4+0x1bd>
     c0e:	mov    rsi,rax
     c11:	jmp    c23 <botlish_fn_4+0xf7>
     c16:	mov    rsi,QWORD PTR [rsp+0x38]
     c1b:	mov    rax,QWORD PTR [rsi+0x10]
     c1f:	mov    rsi,QWORD PTR [rax+rbx*8]
     c23:	mov    QWORD PTR [rsp+0x20],rsi
     c28:	mov    QWORD PTR [rsp+0x48],rsi
     c2d:	mov    QWORD PTR [rsp+0x28],0x1
     c36:	xor    rdx,rdx
     c39:	mov    rdi,r13
     c3c:	mov    rsi,rdx
     c3f:	call   c44 <botlish_fn_4+0x118>
			c40: R_X86_64_PLT32	rt_list_new-0x4
     c44:	test   rax,rax
     c47:	jne    c55 <botlish_fn_4+0x129>
     c4d:	mov    rdi,r13
     c50:	jmp    ce9 <botlish_fn_4+0x1bd>
     c55:	mov    QWORD PTR [rsp+0x30],rax
     c5a:	mov    r9,rax
     c5d:	mov    ecx,0x1
     c62:	mov    rsi,QWORD PTR [rsp+0x48]
     c67:	mov    rdx,r15
     c6a:	mov    rdi,r13
     c6d:	mov    r8,r14
     c70:	call   c75 <botlish_fn_4+0x149>
			c71: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     c75:	test   rax,rax
     c78:	jne    c86 <botlish_fn_4+0x15a>
     c7e:	mov    rdi,r13
     c81:	jmp    ce9 <botlish_fn_4+0x1bd>
     c86:	mov    QWORD PTR [rsp+0x20],rax
     c8b:	mov    rdx,rax
     c8e:	lea    rcx,[rbx+0x1]
     c92:	shl    rcx,1
     c95:	or     rcx,0x1
     c99:	mov    QWORD PTR [rsp+0x28],rcx
     c9e:	mov    rbx,rcx
     ca1:	mov    rsi,QWORD PTR [rsp+0x40]
     ca6:	mov    rdi,r13
     ca9:	call   cae <botlish_fn_4+0x182>
			caa: R_X86_64_PLT32	rt_list_append-0x4
     cae:	test   rax,rax
     cb1:	jne    cbf <botlish_fn_4+0x193>
     cb7:	mov    rdi,r13
     cba:	jmp    ce9 <botlish_fn_4+0x1bd>
     cbf:	mov    QWORD PTR [rsp+0x18],rax
     cc4:	mov    rcx,rbx
     cc7:	mov    rdx,r15
     cca:	mov    rsi,QWORD PTR [rsp+0x38]
     ccf:	mov    r8,r14
     cd2:	mov    r9,rax
     cd5:	mov    rdi,r13
     cd8:	call   cdd <botlish_fn_4+0x1b1>
			cd9: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
     cdd:	test   rax,rax
     ce0:	jne    d17 <botlish_fn_4+0x1eb>
     ce6:	mov    rdi,r13
     ce9:	mov    rdi,r13
     cec:	mov    QWORD PTR [rdi],r12
     cef:	xor    rax,rax
     cf2:	mov    rbx,QWORD PTR [rsp+0x50]
     cf7:	mov    r12,QWORD PTR [rsp+0x58]
     cfc:	mov    r13,QWORD PTR [rsp+0x60]
     d01:	mov    r14,QWORD PTR [rsp+0x68]
     d06:	mov    r15,QWORD PTR [rsp+0x70]
     d0b:	add    rsp,0x80
     d12:	mov    rsp,rbp
     d15:	pop    rbp
     d16:	ret
     d17:	mov    rdi,r13
     d1a:	mov    QWORD PTR [rdi],r12
     d1d:	mov    rbx,QWORD PTR [rsp+0x50]
     d22:	mov    r12,QWORD PTR [rsp+0x58]
     d27:	mov    r13,QWORD PTR [rsp+0x60]
     d2c:	mov    r14,QWORD PTR [rsp+0x68]
     d31:	mov    r15,QWORD PTR [rsp+0x70]
     d36:	add    rsp,0x80
     d3d:	mov    rsp,rbp
     d40:	pop    rbp
     d41:	ret
     d42:	mov    rdi,r13
     d45:	mov    QWORD PTR [rdi],r12
     d48:	mov    rax,QWORD PTR [rsp+0x40]
     d4d:	mov    rbx,QWORD PTR [rsp+0x50]
     d52:	mov    r12,QWORD PTR [rsp+0x58]
     d57:	mov    r13,QWORD PTR [rsp+0x60]
     d5c:	mov    r14,QWORD PTR [rsp+0x68]
     d61:	mov    r15,QWORD PTR [rsp+0x70]
     d66:	add    rsp,0x80
     d6d:	mov    rsp,rbp
     d70:	pop    rbp
     d71:	ret
     d72:	mov    r13,rdi
     d75:	call   d7a <botlish_fn_4+0x24e>
			d76: R_X86_64_PLT32	rt_stack_overflow-0x4
     d7a:	xor    rax,rax
     d7d:	mov    rbx,QWORD PTR [rsp+0x50]
     d82:	mov    r12,QWORD PTR [rsp+0x58]
     d87:	mov    r13,QWORD PTR [rsp+0x60]
     d8c:	mov    r14,QWORD PTR [rsp+0x68]
     d91:	mov    r15,QWORD PTR [rsp+0x70]
     d96:	add    rsp,0x80
     d9d:	mov    rsp,rbp
     da0:	pop    rbp
     da1:	ret

0000000000000da2 <botlish_entry_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     da2:	push   rbp
     da3:	mov    rbp,rsp
     da6:	mov    rsi,QWORD PTR [rdx]
     da9:	mov    r10,QWORD PTR [rdx+0x8]
     dad:	mov    rcx,QWORD PTR [rdx+0x10]
     db1:	mov    r8,QWORD PTR [rdx+0x18]
     db5:	mov    r9,QWORD PTR [rdx+0x20]
     db9:	mov    rdx,r10
     dbc:	call   dc1 <botlish_entry_4+0x1f>
			dbd: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
     dc1:	mov    rsp,rbp
     dc4:	pop    rbp
     dc5:	ret
	...

0000000000000dc8 <botlish_fn_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
     dc8:	push   rbp
     dc9:	mov    rbp,rsp
     dcc:	sub    rsp,0x90
     dd3:	mov    QWORD PTR [rsp+0x60],rbx
     dd8:	mov    QWORD PTR [rsp+0x68],r12
     ddd:	mov    QWORD PTR [rsp+0x70],r13
     de2:	mov    QWORD PTR [rsp+0x78],r14
     de7:	mov    QWORD PTR [rsp+0x80],r15
     def:	mov    r12,r8
     df2:	mov    r14,QWORD PTR [rdi]
     df5:	mov    rax,QWORD PTR [rdi+0x8]
     df9:	lea    r8,[r14+0x8]
     dfd:	cmp    r8,rax
     e00:	ja     1081 <botlish_fn_5+0x2b9>
     e06:	lea    rax,[r14+0x8]
     e0a:	mov    QWORD PTR [rdi],rax
     e0d:	mov    r15,rdi
     e10:	mov    QWORD PTR [r14],0x0
     e17:	mov    QWORD PTR [rsp+0x38],0x0
     e20:	mov    QWORD PTR [rsp],rsi
     e24:	mov    QWORD PTR [rsp+0x8],rdx
     e29:	mov    r13,rdx
     e2c:	mov    QWORD PTR [rsp+0x10],rcx
     e31:	mov    QWORD PTR [rsp+0x18],r9
     e36:	mov    rbx,rsi
     e39:	mov    QWORD PTR [rsp+0x40],rcx
     e3e:	mov    QWORD PTR [rsp+0x48],r9
     e43:	mov    rsi,rbx
     e46:	mov    rdi,r15
     e49:	call   e4e <botlish_fn_5+0x86>
			e4a: R_X86_64_PLT32	rt_list_len-0x4
     e4e:	mov    rsi,QWORD PTR [rsp+0x40]
     e53:	mov    rcx,rsi
     e56:	and    rcx,rax
     e59:	mov    rdx,rax
     e5c:	test   rcx,0x1
     e63:	jne    e8b <botlish_fn_5+0xc3>
     e69:	mov    rsi,QWORD PTR [rsp+0x40]
     e6e:	mov    rdi,r15
     e71:	call   e76 <botlish_fn_5+0xae>
			e72: R_X86_64_PLT32	rt_int_cmp-0x4
     e76:	mov    ecx,0x2
     e7b:	test   rax,rax
     e7e:	cmove  rcx,QWORD PTR [rip+0x232]        # 10b8 <botlish_fn_5+0x2f0>
     e86:	jmp    ea0 <botlish_fn_5+0xd8>
     e8b:	mov    ecx,0x2
     e90:	mov    rsi,QWORD PTR [rsp+0x40]
     e95:	cmp    rsi,rdx
     e98:	cmove  rcx,QWORD PTR [rip+0x218]        # 10b8 <botlish_fn_5+0x2f0>
     ea0:	cmp    rcx,0x6
     ea4:	je     104e <botlish_fn_5+0x286>
     eaa:	mov    rsi,QWORD PTR [rsp+0x40]
     eaf:	test   rsi,0x1
     eb6:	je     ed1 <botlish_fn_5+0x109>
     ebc:	mov    rdi,QWORD PTR [rbx+0x8]
     ec0:	mov    rsi,QWORD PTR [rsp+0x40]
     ec5:	sar    rsi,1
     ec8:	cmp    rsi,rdi
     ecb:	jb     efa <botlish_fn_5+0x132>
     ed1:	mov    rdx,QWORD PTR [rsp+0x40]
     ed6:	mov    rsi,rbx
     ed9:	mov    rdi,r15
     edc:	call   ee1 <botlish_fn_5+0x119>
			edd: R_X86_64_PLT32	rt_list_get-0x4
     ee1:	test   rax,rax
     ee4:	jne    ef2 <botlish_fn_5+0x12a>
     eea:	mov    rdi,r15
     eed:	jmp    ffb <botlish_fn_5+0x233>
     ef2:	mov    rsi,rax
     ef5:	jmp    f02 <botlish_fn_5+0x13a>
     efa:	mov    r10,QWORD PTR [rbx+0x10]
     efe:	mov    rsi,QWORD PTR [r10+rsi*8]
     f02:	mov    QWORD PTR [rsp+0x20],rsi
     f07:	mov    QWORD PTR [rsp+0x50],rsi
     f0c:	mov    QWORD PTR [rsp+0x28],0x1
     f15:	mov    rax,r12
     f18:	or     rax,0x1
     f1c:	mov    QWORD PTR [rsp+0x30],rax
     f21:	xor    rdx,rdx
     f24:	mov    rdi,r15
     f27:	mov    rsi,rdx
     f2a:	call   f2f <botlish_fn_5+0x167>
			f2b: R_X86_64_PLT32	rt_list_new-0x4
     f2f:	test   rax,rax
     f32:	jne    f40 <botlish_fn_5+0x178>
     f38:	mov    rdi,r15
     f3b:	jmp    ffb <botlish_fn_5+0x233>
     f40:	mov    QWORD PTR [rsp+0x38],rax
     f45:	mov    r9,rax
     f48:	mov    ecx,0x1
     f4d:	mov    r8,r12
     f50:	or     r8,0x1
     f54:	mov    rsi,QWORD PTR [rsp+0x50]
     f59:	mov    rdx,r13
     f5c:	mov    rdi,r15
     f5f:	call   f64 <botlish_fn_5+0x19c>
			f60: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     f64:	test   rax,rax
     f67:	jne    f75 <botlish_fn_5+0x1ad>
     f6d:	mov    rdi,r15
     f70:	jmp    ffb <botlish_fn_5+0x233>
     f75:	mov    QWORD PTR [rsp+0x20],rax
     f7a:	mov    QWORD PTR [rsp+0x50],rax
     f7f:	mov    QWORD PTR [rsp+0x28],0x3
     f88:	mov    rsi,QWORD PTR [rsp+0x40]
     f8d:	test   rsi,0x1
     f94:	je     fbe <botlish_fn_5+0x1f6>
     f9a:	mov    rsi,QWORD PTR [rsp+0x40]
     f9f:	mov    rax,rsi
     fa2:	add    rax,0x2
     fa6:	seto   cl
     fa9:	test   cl,cl
     fab:	jne    fbe <botlish_fn_5+0x1f6>
     fb1:	mov    rsi,rax
     fb4:	mov    QWORD PTR [rsp+0x40],rax
     fb9:	jmp    fd8 <botlish_fn_5+0x210>
     fbe:	mov    edx,0x3
     fc3:	mov    rsi,QWORD PTR [rsp+0x40]
     fc8:	mov    rdi,r15
     fcb:	call   fd0 <botlish_fn_5+0x208>
			fcc: R_X86_64_PLT32	rt_int_add-0x4
     fd0:	mov    rsi,rax
     fd3:	mov    QWORD PTR [rsp+0x40],rax
     fd8:	mov    QWORD PTR [rsp+0x10],rsi
     fdd:	mov    rdx,QWORD PTR [rsp+0x50]
     fe2:	mov    rsi,QWORD PTR [rsp+0x48]
     fe7:	mov    rdi,r15
     fea:	call   fef <botlish_fn_5+0x227>
			feb: R_X86_64_PLT32	rt_list_append-0x4
     fef:	test   rax,rax
     ff2:	jne    102c <botlish_fn_5+0x264>
     ff8:	mov    rdi,r15
     ffb:	mov    rdi,r15
     ffe:	mov    QWORD PTR [rdi],r14
    1001:	xor    rax,rax
    1004:	mov    rbx,QWORD PTR [rsp+0x60]
    1009:	mov    r12,QWORD PTR [rsp+0x68]
    100e:	mov    r13,QWORD PTR [rsp+0x70]
    1013:	mov    r14,QWORD PTR [rsp+0x78]
    1018:	mov    r15,QWORD PTR [rsp+0x80]
    1020:	add    rsp,0x90
    1027:	mov    rsp,rbp
    102a:	pop    rbp
    102b:	ret
    102c:	mov    QWORD PTR [rsp],rbx
    1030:	mov    QWORD PTR [rsp+0x8],r13
    1035:	mov    rsi,QWORD PTR [rsp+0x40]
    103a:	mov    QWORD PTR [rsp+0x10],rsi
    103f:	mov    QWORD PTR [rsp+0x18],rax
    1044:	mov    QWORD PTR [rsp+0x48],rax
    1049:	jmp    e43 <botlish_fn_5+0x7b>
    104e:	mov    rdi,r15
    1051:	mov    QWORD PTR [rdi],r14
    1054:	mov    rax,QWORD PTR [rsp+0x48]
    1059:	mov    rbx,QWORD PTR [rsp+0x60]
    105e:	mov    r12,QWORD PTR [rsp+0x68]
    1063:	mov    r13,QWORD PTR [rsp+0x70]
    1068:	mov    r14,QWORD PTR [rsp+0x78]
    106d:	mov    r15,QWORD PTR [rsp+0x80]
    1075:	add    rsp,0x90
    107c:	mov    rsp,rbp
    107f:	pop    rbp
    1080:	ret
    1081:	mov    r15,rdi
    1084:	call   1089 <botlish_fn_5+0x2c1>
			1085: R_X86_64_PLT32	rt_stack_overflow-0x4
    1089:	xor    rax,rax
    108c:	mov    rbx,QWORD PTR [rsp+0x60]
    1091:	mov    r12,QWORD PTR [rsp+0x68]
    1096:	mov    r13,QWORD PTR [rsp+0x70]
    109b:	mov    r14,QWORD PTR [rsp+0x78]
    10a0:	mov    r15,QWORD PTR [rsp+0x80]
    10a8:	add    rsp,0x90
    10af:	mov    rsp,rbp
    10b2:	pop    rbp
    10b3:	ret
    10b4:	add    BYTE PTR [rax],al
    10b6:	add    BYTE PTR [rax],al
    10b8:	(bad)
    10b9:	add    BYTE PTR [rax],al
    10bb:	add    BYTE PTR [rax],al
    10bd:	add    BYTE PTR [rax],al
	...

00000000000010c0 <botlish_entry_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
    10c0:	push   rbp
    10c1:	mov    rbp,rsp
    10c4:	mov    rsi,QWORD PTR [rdx]
    10c7:	mov    r10,QWORD PTR [rdx+0x8]
    10cb:	mov    rcx,QWORD PTR [rdx+0x10]
    10cf:	mov    r8,QWORD PTR [rdx+0x18]
    10d3:	mov    r9,QWORD PTR [rdx+0x20]
    10d7:	mov    rdx,r10
    10da:	call   10df <botlish_entry_5+0x1f>
			10db: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
    10df:	mov    rsp,rbp
    10e2:	pop    rbp
    10e3:	ret

00000000000010e4 <botlish_fn_6: matmul<list<list<int>>, list<list<int>>>>:
    10e4:	push   rbp
    10e5:	mov    rbp,rsp
    10e8:	sub    rsp,0x60
    10ec:	mov    QWORD PTR [rsp+0x30],rbx
    10f1:	mov    QWORD PTR [rsp+0x38],r12
    10f6:	mov    QWORD PTR [rsp+0x40],r13
    10fb:	mov    QWORD PTR [rsp+0x48],r14
    1100:	mov    QWORD PTR [rsp+0x50],r15
    1105:	mov    r12,QWORD PTR [rdi]
    1108:	mov    rax,QWORD PTR [rdi+0x8]
    110c:	lea    rcx,[r12+0x8]
    1111:	cmp    rcx,rax
    1114:	ja     12aa <botlish_fn_6+0x1c6>
    111a:	lea    rax,[r12+0x8]
    111f:	mov    QWORD PTR [rdi],rax
    1122:	mov    r13,rdi
    1125:	mov    QWORD PTR [r12],0x0
    112d:	mov    QWORD PTR [rsp+0x10],0x0
    1136:	mov    QWORD PTR [rsp+0x18],0x0
    113f:	mov    QWORD PTR [rsp+0x20],0x0
    1148:	mov    QWORD PTR [rsp],rsi
    114c:	mov    r14,rsi
    114f:	mov    QWORD PTR [rsp+0x8],rdx
    1154:	mov    rbx,rdx
    1157:	mov    rsi,r14
    115a:	mov    rdi,r13
    115d:	call   1162 <botlish_fn_6+0x7e>
			115e: R_X86_64_PLT32	rt_list_len-0x4
    1162:	sar    rax,1
    1165:	test   rax,rax
    1168:	je     123d <botlish_fn_6+0x159>
    116e:	mov    QWORD PTR [rsp+0x10],0x1
    1177:	mov    rax,QWORD PTR [rbx+0x8]
    117b:	test   rax,rax
    117e:	jne    11ad <botlish_fn_6+0xc9>
    1184:	mov    edx,0x1
    1189:	mov    rsi,rbx
    118c:	mov    rdi,r13
    118f:	call   1194 <botlish_fn_6+0xb0>
			1190: R_X86_64_PLT32	rt_list_get-0x4
    1194:	test   rax,rax
    1197:	jne    11a5 <botlish_fn_6+0xc1>
    119d:	mov    rdi,r13
    11a0:	jmp    1257 <botlish_fn_6+0x173>
    11a5:	mov    rsi,rax
    11a8:	jmp    11b7 <botlish_fn_6+0xd3>
    11ad:	mov    rdx,rbx
    11b0:	mov    rax,QWORD PTR [rdx+0x10]
    11b4:	mov    rsi,QWORD PTR [rax]
    11b7:	mov    rdi,r13
    11ba:	call   11bf <botlish_fn_6+0xdb>
			11bb: R_X86_64_PLT32	rt_list_len-0x4
    11bf:	mov    QWORD PTR [rsp+0x18],rax
    11c4:	mov    r15,rax
    11c7:	xor    rdx,rdx
    11ca:	mov    rdi,r13
    11cd:	mov    rsi,rdx
    11d0:	call   11d5 <botlish_fn_6+0xf1>
			11d1: R_X86_64_PLT32	rt_list_new-0x4
    11d5:	test   rax,rax
    11d8:	jne    11e6 <botlish_fn_6+0x102>
    11de:	mov    rdi,r13
    11e1:	jmp    1257 <botlish_fn_6+0x173>
    11e6:	mov    QWORD PTR [rsp+0x20],rax
    11eb:	mov    r9,rax
    11ee:	mov    ecx,0x1
    11f3:	mov    rdx,rbx
    11f6:	mov    rsi,r14
    11f9:	mov    r8,r15
    11fc:	mov    rdi,r13
    11ff:	call   1204 <botlish_fn_6+0x120>
			1200: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
    1204:	test   rax,rax
    1207:	jne    1215 <botlish_fn_6+0x131>
    120d:	mov    rdi,r13
    1210:	jmp    1257 <botlish_fn_6+0x173>
    1215:	mov    rdi,r13
    1218:	mov    QWORD PTR [rdi],r12
    121b:	mov    rbx,QWORD PTR [rsp+0x30]
    1220:	mov    r12,QWORD PTR [rsp+0x38]
    1225:	mov    r13,QWORD PTR [rsp+0x40]
    122a:	mov    r14,QWORD PTR [rsp+0x48]
    122f:	mov    r15,QWORD PTR [rsp+0x50]
    1234:	add    rsp,0x60
    1238:	mov    rsp,rbp
    123b:	pop    rbp
    123c:	ret
    123d:	xor    rdx,rdx
    1240:	mov    rdi,r13
    1243:	mov    rsi,rdx
    1246:	call   124b <botlish_fn_6+0x167>
			1247: R_X86_64_PLT32	rt_list_new-0x4
    124b:	test   rax,rax
    124e:	jne    1282 <botlish_fn_6+0x19e>
    1254:	mov    rdi,r13
    1257:	mov    rdi,r13
    125a:	mov    QWORD PTR [rdi],r12
    125d:	xor    rax,rax
    1260:	mov    rbx,QWORD PTR [rsp+0x30]
    1265:	mov    r12,QWORD PTR [rsp+0x38]
    126a:	mov    r13,QWORD PTR [rsp+0x40]
    126f:	mov    r14,QWORD PTR [rsp+0x48]
    1274:	mov    r15,QWORD PTR [rsp+0x50]
    1279:	add    rsp,0x60
    127d:	mov    rsp,rbp
    1280:	pop    rbp
    1281:	ret
    1282:	mov    rdi,r13
    1285:	mov    QWORD PTR [rdi],r12
    1288:	mov    rbx,QWORD PTR [rsp+0x30]
    128d:	mov    r12,QWORD PTR [rsp+0x38]
    1292:	mov    r13,QWORD PTR [rsp+0x40]
    1297:	mov    r14,QWORD PTR [rsp+0x48]
    129c:	mov    r15,QWORD PTR [rsp+0x50]
    12a1:	add    rsp,0x60
    12a5:	mov    rsp,rbp
    12a8:	pop    rbp
    12a9:	ret
    12aa:	mov    r13,rdi
    12ad:	call   12b2 <botlish_fn_6+0x1ce>
			12ae: R_X86_64_PLT32	rt_stack_overflow-0x4
    12b2:	xor    rax,rax
    12b5:	mov    rbx,QWORD PTR [rsp+0x30]
    12ba:	mov    r12,QWORD PTR [rsp+0x38]
    12bf:	mov    r13,QWORD PTR [rsp+0x40]
    12c4:	mov    r14,QWORD PTR [rsp+0x48]
    12c9:	mov    r15,QWORD PTR [rsp+0x50]
    12ce:	add    rsp,0x60
    12d2:	mov    rsp,rbp
    12d5:	pop    rbp
    12d6:	ret

00000000000012d7 <botlish_entry_6: matmul<list<list<int>>, list<list<int>>>>:
    12d7:	push   rbp
    12d8:	mov    rbp,rsp
    12db:	mov    rsi,QWORD PTR [rdx]
    12de:	mov    rdx,QWORD PTR [rdx+0x8]
    12e2:	call   12e7 <botlish_entry_6+0x10>
			12e3: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
    12e7:	mov    rsp,rbp
    12ea:	pop    rbp
    12eb:	ret

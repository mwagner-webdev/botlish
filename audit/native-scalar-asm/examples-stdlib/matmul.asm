; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4959  (per function: 917 818 544 676 665 788 551)
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
      42:	ja     30f <botlish_fn_0+0x30f>
      48:	lea    rax,[r12+0x28]
      4d:	mov    QWORD PTR [rdi],rax
      50:	mov    r13,rdi
      53:	mov    QWORD PTR [r12+0x18],0x0
      5c:	mov    QWORD PTR [r12+0x20],0x0
      65:	mov    esi,0x3
      6a:	mov    QWORD PTR [r12],0x3
      72:	mov    QWORD PTR [r12+0x8],0x5
      7b:	mov    QWORD PTR [r12+0x10],0x7
      84:	lea    rdx,[rsp]
      88:	mov    QWORD PTR [rsp],0x3
      90:	mov    QWORD PTR [rsp+0x8],0x5
      99:	mov    QWORD PTR [rsp+0x10],0x7
      a2:	mov    rdi,r13
      a5:	call   aa <botlish_fn_0+0xaa>
			a6: R_X86_64_PLT32	rt_list_new-0x4
      aa:	test   rax,rax
      ad:	jne    bb <botlish_fn_0+0xbb>
      b3:	mov    rdi,r13
      b6:	jmp    298 <botlish_fn_0+0x298>
      bb:	mov    QWORD PTR [r12],rax
      bf:	mov    rbx,rax
      c2:	mov    QWORD PTR [r12+0x8],0x9
      cb:	mov    QWORD PTR [r12+0x10],0xb
      d4:	mov    QWORD PTR [r12+0x18],0xd
      dd:	lea    rdx,[rsp+0x18]
      e2:	mov    QWORD PTR [rsp+0x18],0x9
      eb:	mov    QWORD PTR [rsp+0x20],0xb
      f4:	mov    QWORD PTR [rsp+0x28],0xd
      fd:	mov    esi,0x3
     102:	mov    rdi,r13
     105:	call   10a <botlish_fn_0+0x10a>
			106: R_X86_64_PLT32	rt_list_new-0x4
     10a:	test   rax,rax
     10d:	jne    11b <botlish_fn_0+0x11b>
     113:	mov    rdi,r13
     116:	jmp    298 <botlish_fn_0+0x298>
     11b:	mov    QWORD PTR [r12+0x8],rax
     120:	lea    rdx,[rsp+0x30]
     125:	mov    rcx,rbx
     128:	mov    QWORD PTR [rsp+0x30],rcx
     12d:	mov    QWORD PTR [rsp+0x38],rax
     132:	mov    esi,0x2
     137:	mov    rdi,r13
     13a:	call   13f <botlish_fn_0+0x13f>
			13b: R_X86_64_PLT32	rt_list_new-0x4
     13f:	test   rax,rax
     142:	jne    150 <botlish_fn_0+0x150>
     148:	mov    rdi,r13
     14b:	jmp    298 <botlish_fn_0+0x298>
     150:	mov    QWORD PTR [r12],rax
     154:	mov    r14,rax
     157:	mov    QWORD PTR [r12+0x8],0xf
     160:	mov    QWORD PTR [r12+0x10],0x11
     169:	lea    rdx,[rsp+0x40]
     16e:	mov    QWORD PTR [rsp+0x40],0xf
     177:	mov    QWORD PTR [rsp+0x48],0x11
     180:	mov    esi,0x2
     185:	mov    rdi,r13
     188:	call   18d <botlish_fn_0+0x18d>
			189: R_X86_64_PLT32	rt_list_new-0x4
     18d:	mov    rbx,rax
     190:	test   rbx,rbx
     193:	jne    1a1 <botlish_fn_0+0x1a1>
     199:	mov    rdi,r13
     19c:	jmp    298 <botlish_fn_0+0x298>
     1a1:	mov    QWORD PTR [r12+0x8],rbx
     1a6:	mov    QWORD PTR [r12+0x10],0x13
     1af:	mov    QWORD PTR [r12+0x18],0x15
     1b8:	lea    rdx,[rsp+0x50]
     1bd:	mov    QWORD PTR [rsp+0x50],0x13
     1c6:	mov    QWORD PTR [rsp+0x58],0x15
     1cf:	mov    esi,0x2
     1d4:	mov    rdi,r13
     1d7:	call   1dc <botlish_fn_0+0x1dc>
			1d8: R_X86_64_PLT32	rt_list_new-0x4
     1dc:	test   rax,rax
     1df:	jne    1ed <botlish_fn_0+0x1ed>
     1e5:	mov    rdi,r13
     1e8:	jmp    298 <botlish_fn_0+0x298>
     1ed:	mov    QWORD PTR [r12+0x10],rax
     1f2:	mov    r15,rax
     1f5:	mov    QWORD PTR [r12+0x18],0x17
     1fe:	mov    QWORD PTR [r12+0x20],0x19
     207:	lea    rdx,[rsp+0x60]
     20c:	mov    QWORD PTR [rsp+0x60],0x17
     215:	mov    QWORD PTR [rsp+0x68],0x19
     21e:	mov    esi,0x2
     223:	mov    rdi,r13
     226:	call   22b <botlish_fn_0+0x22b>
			227: R_X86_64_PLT32	rt_list_new-0x4
     22b:	test   rax,rax
     22e:	jne    23c <botlish_fn_0+0x23c>
     234:	mov    rdi,r13
     237:	jmp    298 <botlish_fn_0+0x298>
     23c:	mov    QWORD PTR [r12+0x18],rax
     241:	lea    rdx,[rsp+0x70]
     246:	mov    QWORD PTR [rsp+0x70],rbx
     24b:	mov    rcx,r15
     24e:	mov    QWORD PTR [rsp+0x78],rcx
     253:	mov    QWORD PTR [rsp+0x80],rax
     25b:	mov    esi,0x3
     260:	mov    rdi,r13
     263:	call   268 <botlish_fn_0+0x268>
			264: R_X86_64_PLT32	rt_list_new-0x4
     268:	test   rax,rax
     26b:	jne    279 <botlish_fn_0+0x279>
     271:	mov    rdi,r13
     274:	jmp    298 <botlish_fn_0+0x298>
     279:	mov    QWORD PTR [r12+0x8],rax
     27e:	mov    rdx,rax
     281:	mov    rsi,r14
     284:	mov    rdi,r13
     287:	call   28c <botlish_fn_0+0x28c>
			288: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
     28c:	test   rax,rax
     28f:	jne    2d5 <botlish_fn_0+0x2d5>
     295:	mov    rdi,r13
     298:	mov    rdi,r13
     29b:	mov    QWORD PTR [rdi],r12
     29e:	xor    rax,rax
     2a1:	mov    rbx,QWORD PTR [rsp+0x90]
     2a9:	mov    r12,QWORD PTR [rsp+0x98]
     2b1:	mov    r13,QWORD PTR [rsp+0xa0]
     2b9:	mov    r14,QWORD PTR [rsp+0xa8]
     2c1:	mov    r15,QWORD PTR [rsp+0xb0]
     2c9:	add    rsp,0xc0
     2d0:	mov    rsp,rbp
     2d3:	pop    rbp
     2d4:	ret
     2d5:	mov    rdi,r13
     2d8:	mov    QWORD PTR [rdi],r12
     2db:	mov    rbx,QWORD PTR [rsp+0x90]
     2e3:	mov    r12,QWORD PTR [rsp+0x98]
     2eb:	mov    r13,QWORD PTR [rsp+0xa0]
     2f3:	mov    r14,QWORD PTR [rsp+0xa8]
     2fb:	mov    r15,QWORD PTR [rsp+0xb0]
     303:	add    rsp,0xc0
     30a:	mov    rsp,rbp
     30d:	pop    rbp
     30e:	ret
     30f:	mov    r13,rdi
     312:	call   317 <botlish_fn_0+0x317>
			313: R_X86_64_PLT32	rt_stack_overflow-0x4
     317:	xor    rax,rax
     31a:	mov    rbx,QWORD PTR [rsp+0x90]
     322:	mov    r12,QWORD PTR [rsp+0x98]
     32a:	mov    r13,QWORD PTR [rsp+0xa0]
     332:	mov    r14,QWORD PTR [rsp+0xa8]
     33a:	mov    r15,QWORD PTR [rsp+0xb0]
     342:	add    rsp,0xc0
     349:	mov    rsp,rbp
     34c:	pop    rbp
     34d:	ret

000000000000034e <botlish_entry_0: <program entry>>:
     34e:	push   rbp
     34f:	mov    rbp,rsp
     352:	call   357 <botlish_entry_0+0x9>
			353: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     357:	mov    rsp,rbp
     35a:	pop    rbp
     35b:	ret

000000000000035c <botlish_fn_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     35c:	push   rbp
     35d:	mov    rbp,rsp
     360:	sub    rsp,0x90
     367:	mov    QWORD PTR [rsp+0x60],rbx
     36c:	mov    QWORD PTR [rsp+0x68],r12
     371:	mov    QWORD PTR [rsp+0x70],r13
     376:	mov    QWORD PTR [rsp+0x78],r14
     37b:	mov    QWORD PTR [rsp+0x80],r15
     383:	mov    r10,QWORD PTR [rbp+0x10]
     387:	mov    r12,QWORD PTR [rdi+0x20]
     38b:	mov    QWORD PTR [rsp+0x58],r12
     390:	mov    rbx,QWORD PTR [rdi+0x28]
     394:	mov    QWORD PTR [rsp+0x50],rbx
     399:	lea    rax,[rsp]
     39d:	mov    QWORD PTR [rdi+0x20],rax
     3a1:	mov    QWORD PTR [rdi+0x28],0x6
     3a9:	mov    QWORD PTR [rsp],rsi
     3ad:	mov    r11,rsi
     3b0:	mov    QWORD PTR [rsp+0x8],rdx
     3b5:	mov    r12,rdx
     3b8:	mov    QWORD PTR [rsp+0x10],rcx
     3bd:	mov    QWORD PTR [rsp+0x18],r10
     3c2:	sar    r8,1
     3c5:	sar    r9,1
     3c8:	mov    QWORD PTR [rsp+0x48],r9
     3cd:	mov    rsi,rcx
     3d0:	sar    rsi,1
     3d3:	mov    rbx,rcx
     3d6:	mov    QWORD PTR [rsp+0x40],rsi
     3db:	mov    rcx,QWORD PTR [rsp+0x48]
     3e0:	mov    r15,r8
     3e3:	mov    QWORD PTR [rsp+0x30],r10
     3e8:	cmp    r15,rcx
     3eb:	mov    QWORD PTR [rsp+0x48],rcx
     3f0:	je     5ef <botlish_fn_1+0x293>
     3f6:	mov    r14,r11
     3f9:	mov    r8,QWORD PTR [r14+0x8]
     3fd:	mov    rsi,r15
     400:	shl    rsi,1
     403:	or     rsi,0x1
     407:	sar    rsi,1
     40a:	cmp    rsi,r8
     40d:	jb     443 <botlish_fn_1+0xe7>
     413:	mov    rdx,r15
     416:	shl    rdx,1
     419:	or     rdx,0x1
     41d:	mov    r13,rdi
     420:	mov    rsi,r14
     423:	call   428 <botlish_fn_1+0xcc>
			424: R_X86_64_PLT32	rt_list_get-0x4
     428:	test   rax,rax
     42b:	jne    43b <botlish_fn_1+0xdf>
     431:	mov    rcx,QWORD PTR [rsp+0x58]
     436:	jmp    4e4 <botlish_fn_1+0x188>
     43b:	mov    rsi,rax
     43e:	jmp    44e <botlish_fn_1+0xf2>
     443:	mov    r13,rdi
     446:	mov    rax,QWORD PTR [r14+0x10]
     44a:	mov    rsi,QWORD PTR [rax+rsi*8]
     44e:	mov    QWORD PTR [rsp+0x20],rsi
     453:	mov    QWORD PTR [rsp+0x38],rsi
     458:	mov    rcx,QWORD PTR [r12+0x8]
     45d:	mov    rax,r15
     460:	shl    rax,1
     463:	or     rax,0x1
     467:	sar    rax,1
     46a:	cmp    rax,rcx
     46d:	jb     4a3 <botlish_fn_1+0x147>
     473:	mov    rdx,r15
     476:	shl    rdx,1
     479:	or     rdx,0x1
     47d:	mov    rsi,r12
     480:	mov    rdi,r13
     483:	call   488 <botlish_fn_1+0x12c>
			484: R_X86_64_PLT32	rt_list_get-0x4
     488:	test   rax,rax
     48b:	jne    49b <botlish_fn_1+0x13f>
     491:	mov    rcx,QWORD PTR [rsp+0x58]
     496:	jmp    4e4 <botlish_fn_1+0x188>
     49b:	mov    rsi,rax
     49e:	jmp    4ac <botlish_fn_1+0x150>
     4a3:	mov    rcx,QWORD PTR [r12+0x10]
     4a8:	mov    rsi,QWORD PTR [rcx+rax*8]
     4ac:	test   rbx,0x1
     4b3:	je     4cb <botlish_fn_1+0x16f>
     4b9:	mov    rax,QWORD PTR [rsi+0x8]
     4bd:	mov    rcx,QWORD PTR [rsp+0x40]
     4c2:	cmp    rcx,rax
     4c5:	jb     524 <botlish_fn_1+0x1c8>
     4cb:	mov    rdx,rbx
     4ce:	mov    rdi,r13
     4d1:	call   4d6 <botlish_fn_1+0x17a>
			4d2: R_X86_64_PLT32	rt_list_get-0x4
     4d6:	test   rax,rax
     4d9:	jne    51c <botlish_fn_1+0x1c0>
     4df:	mov    rcx,QWORD PTR [rsp+0x58]
     4e4:	mov    QWORD PTR [r13+0x20],rcx
     4e8:	mov    rcx,QWORD PTR [rsp+0x50]
     4ed:	mov    QWORD PTR [r13+0x28],rcx
     4f1:	xor    rax,rax
     4f4:	mov    rbx,QWORD PTR [rsp+0x60]
     4f9:	mov    r12,QWORD PTR [rsp+0x68]
     4fe:	mov    r13,QWORD PTR [rsp+0x70]
     503:	mov    r14,QWORD PTR [rsp+0x78]
     508:	mov    r15,QWORD PTR [rsp+0x80]
     510:	add    rsp,0x90
     517:	mov    rsp,rbp
     51a:	pop    rbp
     51b:	ret
     51c:	mov    rdx,rax
     51f:	jmp    531 <botlish_fn_1+0x1d5>
     524:	mov    rax,QWORD PTR [rsi+0x10]
     528:	mov    rcx,QWORD PTR [rsp+0x40]
     52d:	mov    rdx,QWORD PTR [rax+rcx*8]
     531:	mov    QWORD PTR [rsp+0x28],rdx
     536:	mov    rsi,QWORD PTR [rsp+0x38]
     53b:	mov    rax,rsi
     53e:	and    rax,rdx
     541:	test   rax,0x1
     547:	je     57c <botlish_fn_1+0x220>
     54d:	mov    rax,rsi
     550:	sar    rax,1
     553:	lea    rcx,[rdx-0x1]
     557:	mov    rdi,rdx
     55a:	imul   rcx
     55d:	seto   cl
     560:	or     rax,0x1
     564:	test   cl,cl
     566:	je     574 <botlish_fn_1+0x218>
     56c:	mov    rdx,rdi
     56f:	jmp    57c <botlish_fn_1+0x220>
     574:	mov    rdx,rax
     577:	jmp    587 <botlish_fn_1+0x22b>
     57c:	mov    rdi,r13
     57f:	call   584 <botlish_fn_1+0x228>
			580: R_X86_64_PLT32	rt_int_mul-0x4
     584:	mov    rdx,rax
     587:	mov    QWORD PTR [rsp+0x20],rdx
     58c:	mov    rsi,QWORD PTR [rsp+0x30]
     591:	mov    rax,rsi
     594:	and    rax,rdx
     597:	test   rax,0x1
     59d:	je     5b8 <botlish_fn_1+0x25c>
     5a3:	lea    rcx,[rdx-0x1]
     5a7:	mov    rax,rsi
     5aa:	add    rax,rcx
     5ad:	seto   cl
     5b0:	test   cl,cl
     5b2:	je     5c0 <botlish_fn_1+0x264>
     5b8:	mov    rdi,r13
     5bb:	call   5c0 <botlish_fn_1+0x264>
			5bc: R_X86_64_PLT32	rt_int_add-0x4
     5c0:	mov    QWORD PTR [rsp],r14
     5c4:	mov    QWORD PTR [rsp+0x8],r12
     5c9:	mov    QWORD PTR [rsp+0x10],rbx
     5ce:	mov    QWORD PTR [rsp+0x18],rax
     5d3:	add    r15,0x1
     5da:	mov    rcx,QWORD PTR [rsp+0x48]
     5df:	mov    rdi,r13
     5e2:	mov    r11,r14
     5e5:	mov    QWORD PTR [rsp+0x30],rax
     5ea:	jmp    3e8 <botlish_fn_1+0x8c>
     5ef:	mov    rcx,QWORD PTR [rsp+0x58]
     5f4:	mov    r13,rdi
     5f7:	mov    QWORD PTR [r13+0x20],rcx
     5fb:	mov    rcx,QWORD PTR [rsp+0x50]
     600:	mov    QWORD PTR [r13+0x28],rcx
     604:	mov    rax,QWORD PTR [rsp+0x30]
     609:	mov    rbx,QWORD PTR [rsp+0x60]
     60e:	mov    r12,QWORD PTR [rsp+0x68]
     613:	mov    r13,QWORD PTR [rsp+0x70]
     618:	mov    r14,QWORD PTR [rsp+0x78]
     61d:	mov    r15,QWORD PTR [rsp+0x80]
     625:	add    rsp,0x90
     62c:	mov    rsp,rbp
     62f:	pop    rbp
     630:	ret

0000000000000631 <botlish_entry_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     631:	push   rbp
     632:	mov    rbp,rsp
     635:	sub    rsp,0x10
     639:	mov    rsi,QWORD PTR [rdx]
     63c:	mov    r10,QWORD PTR [rdx+0x8]
     640:	mov    rcx,QWORD PTR [rdx+0x10]
     644:	mov    r8,QWORD PTR [rdx+0x18]
     648:	mov    r9,QWORD PTR [rdx+0x20]
     64c:	mov    r11,QWORD PTR [rdx+0x28]
     650:	mov    QWORD PTR [rsp],r11
     654:	mov    rdx,r10
     657:	call   65c <botlish_entry_1+0x2b>
			658: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     65c:	add    rsp,0x10
     660:	mov    rsp,rbp
     663:	pop    rbp
     664:	ret

0000000000000665 <botlish_fn_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     665:	push   rbp
     666:	mov    rbp,rsp
     669:	sub    rsp,0x60
     66d:	mov    QWORD PTR [rsp+0x30],rbx
     672:	mov    QWORD PTR [rsp+0x38],r12
     677:	mov    QWORD PTR [rsp+0x40],r13
     67c:	mov    QWORD PTR [rsp+0x48],r14
     681:	mov    QWORD PTR [rsp+0x50],r15
     686:	mov    r13,QWORD PTR [rdi]
     689:	mov    rax,QWORD PTR [rdi+0x8]
     68d:	lea    r10,[r13+0x40]
     691:	cmp    r10,rax
     694:	ja     81f <botlish_fn_2+0x1ba>
     69a:	lea    rax,[r13+0x40]
     69e:	mov    QWORD PTR [rdi],rax
     6a1:	mov    r14,rdi
     6a4:	mov    QWORD PTR [r13+0x0],rsi
     6a8:	mov    QWORD PTR [rsp+0x10],rsi
     6ad:	mov    QWORD PTR [r13+0x8],rdx
     6b1:	mov    QWORD PTR [rsp+0x18],rdx
     6b6:	mov    QWORD PTR [r13+0x10],rcx
     6ba:	mov    QWORD PTR [r13+0x18],r8
     6be:	mov    QWORD PTR [r13+0x20],r9
     6c2:	mov    QWORD PTR [rsp+0x28],r9
     6c7:	mov    rbx,rcx
     6ca:	sar    rbx,1
     6cd:	mov    QWORD PTR [rsp+0x20],rcx
     6d2:	mov    rax,r8
     6d5:	sar    rax,1
     6d8:	mov    r15,r8
     6db:	cmp    rbx,rax
     6de:	je     7f2 <botlish_fn_2+0x18d>
     6e4:	mov    r12d,0x1
     6ea:	mov    QWORD PTR [r13+0x28],0x1
     6f2:	mov    rsi,QWORD PTR [rsp+0x10]
     6f7:	mov    rdi,r14
     6fa:	call   6ff <botlish_fn_2+0x9a>
			6fb: R_X86_64_PLT32	rt_list_len-0x4
     6ff:	mov    QWORD PTR [r13+0x30],rax
     703:	mov    QWORD PTR [r13+0x38],0x1
     70b:	mov    QWORD PTR [rsp],r12
     70f:	mov    rcx,QWORD PTR [rsp+0x20]
     714:	mov    r8,r12
     717:	mov    r9,rax
     71a:	mov    rdx,QWORD PTR [rsp+0x18]
     71f:	mov    rsi,QWORD PTR [rsp+0x10]
     724:	mov    rdi,r14
     727:	call   72c <botlish_fn_2+0xc7>
			728: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     72c:	test   rax,rax
     72f:	jne    73d <botlish_fn_2+0xd8>
     735:	mov    rdi,r14
     738:	jmp    79f <botlish_fn_2+0x13a>
     73d:	mov    QWORD PTR [r13+0x10],rax
     741:	mov    rdx,rax
     744:	lea    rcx,[rbx+0x1]
     748:	shl    rcx,1
     74b:	or     rcx,0x1
     74f:	mov    QWORD PTR [r13+0x28],rcx
     753:	mov    rbx,rcx
     756:	mov    rsi,QWORD PTR [rsp+0x28]
     75b:	mov    rdi,r14
     75e:	call   763 <botlish_fn_2+0xfe>
			75f: R_X86_64_PLT32	rt_list_append-0x4
     763:	test   rax,rax
     766:	jne    774 <botlish_fn_2+0x10f>
     76c:	mov    rdi,r14
     76f:	jmp    79f <botlish_fn_2+0x13a>
     774:	mov    QWORD PTR [r13+0x10],rax
     778:	mov    rcx,rbx
     77b:	mov    rdx,QWORD PTR [rsp+0x18]
     780:	mov    rsi,QWORD PTR [rsp+0x10]
     785:	mov    r8,r15
     788:	mov    r9,rax
     78b:	mov    rdi,r14
     78e:	call   793 <botlish_fn_2+0x12e>
			78f: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     793:	test   rax,rax
     796:	jne    7ca <botlish_fn_2+0x165>
     79c:	mov    rdi,r14
     79f:	mov    rdi,r14
     7a2:	mov    QWORD PTR [rdi],r13
     7a5:	xor    rax,rax
     7a8:	mov    rbx,QWORD PTR [rsp+0x30]
     7ad:	mov    r12,QWORD PTR [rsp+0x38]
     7b2:	mov    r13,QWORD PTR [rsp+0x40]
     7b7:	mov    r14,QWORD PTR [rsp+0x48]
     7bc:	mov    r15,QWORD PTR [rsp+0x50]
     7c1:	add    rsp,0x60
     7c5:	mov    rsp,rbp
     7c8:	pop    rbp
     7c9:	ret
     7ca:	mov    rdi,r14
     7cd:	mov    QWORD PTR [rdi],r13
     7d0:	mov    rbx,QWORD PTR [rsp+0x30]
     7d5:	mov    r12,QWORD PTR [rsp+0x38]
     7da:	mov    r13,QWORD PTR [rsp+0x40]
     7df:	mov    r14,QWORD PTR [rsp+0x48]
     7e4:	mov    r15,QWORD PTR [rsp+0x50]
     7e9:	add    rsp,0x60
     7ed:	mov    rsp,rbp
     7f0:	pop    rbp
     7f1:	ret
     7f2:	mov    rdi,r14
     7f5:	mov    QWORD PTR [rdi],r13
     7f8:	mov    rax,QWORD PTR [rsp+0x28]
     7fd:	mov    rbx,QWORD PTR [rsp+0x30]
     802:	mov    r12,QWORD PTR [rsp+0x38]
     807:	mov    r13,QWORD PTR [rsp+0x40]
     80c:	mov    r14,QWORD PTR [rsp+0x48]
     811:	mov    r15,QWORD PTR [rsp+0x50]
     816:	add    rsp,0x60
     81a:	mov    rsp,rbp
     81d:	pop    rbp
     81e:	ret
     81f:	mov    r14,rdi
     822:	call   827 <botlish_fn_2+0x1c2>
			823: R_X86_64_PLT32	rt_stack_overflow-0x4
     827:	xor    rax,rax
     82a:	mov    rbx,QWORD PTR [rsp+0x30]
     82f:	mov    r12,QWORD PTR [rsp+0x38]
     834:	mov    r13,QWORD PTR [rsp+0x40]
     839:	mov    r14,QWORD PTR [rsp+0x48]
     83e:	mov    r15,QWORD PTR [rsp+0x50]
     843:	add    rsp,0x60
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
     874:	sub    rsp,0x60
     878:	mov    QWORD PTR [rsp+0x30],rbx
     87d:	mov    QWORD PTR [rsp+0x38],r12
     882:	mov    QWORD PTR [rsp+0x40],r13
     887:	mov    QWORD PTR [rsp+0x48],r14
     88c:	mov    QWORD PTR [rsp+0x50],r15
     891:	mov    r10,r8
     894:	mov    r13,QWORD PTR [rdi]
     897:	mov    rax,QWORD PTR [rdi+0x8]
     89b:	lea    r8,[r13+0x38]
     89f:	cmp    r8,rax
     8a2:	ja     a9c <botlish_fn_3+0x22c>
     8a8:	lea    rax,[r13+0x38]
     8ac:	mov    QWORD PTR [rdi],rax
     8af:	mov    r15,rdi
     8b2:	mov    QWORD PTR [r13+0x0],rsi
     8b6:	mov    r12,rsi
     8b9:	mov    QWORD PTR [r13+0x8],rdx
     8bd:	mov    QWORD PTR [rsp+0x10],rdx
     8c2:	mov    QWORD PTR [r13+0x10],rcx
     8c6:	mov    QWORD PTR [r13+0x18],r9
     8ca:	mov    rbx,r10
     8cd:	mov    rsi,rcx
     8d0:	mov    QWORD PTR [rsp+0x20],r9
     8d5:	mov    rax,rbx
     8d8:	or     rax,0x1
     8dc:	mov    rcx,rsi
     8df:	and    rcx,rax
     8e2:	mov    QWORD PTR [rsp+0x18],rsi
     8e7:	test   rcx,0x1
     8ee:	jne    91d <botlish_fn_3+0xad>
     8f4:	mov    rdx,rbx
     8f7:	or     rdx,0x1
     8fb:	mov    rsi,QWORD PTR [rsp+0x18]
     900:	mov    rdi,r15
     903:	call   908 <botlish_fn_3+0x98>
			904: R_X86_64_PLT32	rt_int_cmp-0x4
     908:	mov    ecx,0x2
     90d:	test   rax,rax
     910:	cmove  rcx,QWORD PTR [rip+0x1b8]        # ad0 <botlish_fn_3+0x260>
     918:	jmp    939 <botlish_fn_3+0xc9>
     91d:	mov    rax,rbx
     920:	or     rax,0x1
     924:	mov    ecx,0x2
     929:	mov    rsi,QWORD PTR [rsp+0x18]
     92e:	cmp    rsi,rax
     931:	cmove  rcx,QWORD PTR [rip+0x197]        # ad0 <botlish_fn_3+0x260>
     939:	cmp    rcx,0x6
     93d:	je     a6f <botlish_fn_3+0x1ff>
     943:	mov    r14d,0x1
     949:	mov    QWORD PTR [r13+0x20],0x1
     951:	mov    rsi,r12
     954:	mov    rdi,r15
     957:	call   95c <botlish_fn_3+0xec>
			958: R_X86_64_PLT32	rt_list_len-0x4
     95c:	mov    QWORD PTR [r13+0x28],rax
     960:	mov    QWORD PTR [r13+0x30],0x1
     968:	mov    QWORD PTR [rsp],r14
     96c:	mov    r9,rax
     96f:	mov    r8,r14
     972:	mov    r14,QWORD PTR [rsp+0x10]
     977:	mov    rcx,QWORD PTR [rsp+0x18]
     97c:	mov    rdx,r14
     97f:	mov    rsi,r12
     982:	mov    rdi,r15
     985:	call   98a <botlish_fn_3+0x11a>
			986: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     98a:	test   rax,rax
     98d:	jne    99b <botlish_fn_3+0x12b>
     993:	mov    rdi,r15
     996:	jmp    a20 <botlish_fn_3+0x1b0>
     99b:	mov    QWORD PTR [r13+0x20],rax
     99f:	mov    QWORD PTR [rsp+0x28],rax
     9a4:	mov    QWORD PTR [r13+0x28],0x3
     9ac:	mov    rsi,QWORD PTR [rsp+0x18]
     9b1:	test   rsi,0x1
     9b8:	je     9e4 <botlish_fn_3+0x174>
     9be:	mov    rsi,QWORD PTR [rsp+0x18]
     9c3:	mov    rcx,rsi
     9c6:	add    rcx,0x2
     9ca:	seto   sil
     9ce:	test   sil,sil
     9d1:	jne    9e4 <botlish_fn_3+0x174>
     9d7:	mov    rsi,rcx
     9da:	mov    QWORD PTR [rsp+0x18],rcx
     9df:	jmp    9fe <botlish_fn_3+0x18e>
     9e4:	mov    edx,0x3
     9e9:	mov    rsi,QWORD PTR [rsp+0x18]
     9ee:	mov    rdi,r15
     9f1:	call   9f6 <botlish_fn_3+0x186>
			9f2: R_X86_64_PLT32	rt_int_add-0x4
     9f6:	mov    rsi,rax
     9f9:	mov    QWORD PTR [rsp+0x18],rax
     9fe:	mov    QWORD PTR [r13+0x10],rsi
     a02:	mov    rdx,QWORD PTR [rsp+0x28]
     a07:	mov    rsi,QWORD PTR [rsp+0x20]
     a0c:	mov    rdi,r15
     a0f:	call   a14 <botlish_fn_3+0x1a4>
			a10: R_X86_64_PLT32	rt_list_append-0x4
     a14:	test   rax,rax
     a17:	jne    a4b <botlish_fn_3+0x1db>
     a1d:	mov    rdi,r15
     a20:	mov    rdi,r15
     a23:	mov    QWORD PTR [rdi],r13
     a26:	xor    rax,rax
     a29:	mov    rbx,QWORD PTR [rsp+0x30]
     a2e:	mov    r12,QWORD PTR [rsp+0x38]
     a33:	mov    r13,QWORD PTR [rsp+0x40]
     a38:	mov    r14,QWORD PTR [rsp+0x48]
     a3d:	mov    r15,QWORD PTR [rsp+0x50]
     a42:	add    rsp,0x60
     a46:	mov    rsp,rbp
     a49:	pop    rbp
     a4a:	ret
     a4b:	mov    QWORD PTR [r13+0x0],r12
     a4f:	mov    QWORD PTR [r13+0x8],r14
     a53:	mov    rsi,QWORD PTR [rsp+0x18]
     a58:	mov    QWORD PTR [r13+0x10],rsi
     a5c:	mov    QWORD PTR [r13+0x18],rax
     a60:	mov    QWORD PTR [rsp+0x10],r14
     a65:	mov    QWORD PTR [rsp+0x20],rax
     a6a:	jmp    8d5 <botlish_fn_3+0x65>
     a6f:	mov    rdi,r15
     a72:	mov    QWORD PTR [rdi],r13
     a75:	mov    rax,QWORD PTR [rsp+0x20]
     a7a:	mov    rbx,QWORD PTR [rsp+0x30]
     a7f:	mov    r12,QWORD PTR [rsp+0x38]
     a84:	mov    r13,QWORD PTR [rsp+0x40]
     a89:	mov    r14,QWORD PTR [rsp+0x48]
     a8e:	mov    r15,QWORD PTR [rsp+0x50]
     a93:	add    rsp,0x60
     a97:	mov    rsp,rbp
     a9a:	pop    rbp
     a9b:	ret
     a9c:	mov    r15,rdi
     a9f:	call   aa4 <botlish_fn_3+0x234>
			aa0: R_X86_64_PLT32	rt_stack_overflow-0x4
     aa4:	xor    rax,rax
     aa7:	mov    rbx,QWORD PTR [rsp+0x30]
     aac:	mov    r12,QWORD PTR [rsp+0x38]
     ab1:	mov    r13,QWORD PTR [rsp+0x40]
     ab6:	mov    r14,QWORD PTR [rsp+0x48]
     abb:	mov    r15,QWORD PTR [rsp+0x50]
     ac0:	add    rsp,0x60
     ac4:	mov    rsp,rbp
     ac7:	pop    rbp
     ac8:	ret
     ac9:	add    BYTE PTR [rax],al
     acb:	add    BYTE PTR [rax],al
     acd:	add    BYTE PTR [rax],al
     acf:	add    BYTE PTR [rsi],al
     ad1:	add    BYTE PTR [rax],al
     ad3:	add    BYTE PTR [rax],al
     ad5:	add    BYTE PTR [rax],al
	...

0000000000000ad8 <botlish_entry_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     ad8:	push   rbp
     ad9:	mov    rbp,rsp
     adc:	mov    rsi,QWORD PTR [rdx]
     adf:	mov    r10,QWORD PTR [rdx+0x8]
     ae3:	mov    rcx,QWORD PTR [rdx+0x10]
     ae7:	mov    r8,QWORD PTR [rdx+0x18]
     aeb:	mov    r9,QWORD PTR [rdx+0x20]
     aef:	mov    rdx,r10
     af2:	call   af7 <botlish_entry_3+0x1f>
			af3: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     af7:	mov    rsp,rbp
     afa:	pop    rbp
     afb:	ret

0000000000000afc <botlish_fn_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     afc:	push   rbp
     afd:	mov    rbp,rsp
     b00:	sub    rsp,0x50
     b04:	mov    QWORD PTR [rsp+0x20],rbx
     b09:	mov    QWORD PTR [rsp+0x28],r12
     b0e:	mov    QWORD PTR [rsp+0x30],r13
     b13:	mov    QWORD PTR [rsp+0x38],r14
     b18:	mov    QWORD PTR [rsp+0x40],r15
     b1d:	mov    rbx,rcx
     b20:	mov    r12,QWORD PTR [rdi]
     b23:	mov    rax,QWORD PTR [rdi+0x8]
     b27:	lea    rcx,[r12+0x38]
     b2c:	cmp    rcx,rax
     b2f:	ja     d28 <botlish_fn_4+0x22c>
     b35:	lea    rax,[r12+0x38]
     b3a:	mov    QWORD PTR [rdi],rax
     b3d:	mov    r13,rdi
     b40:	mov    QWORD PTR [r12+0x30],0x0
     b49:	mov    QWORD PTR [r12],rsi
     b4d:	mov    QWORD PTR [rsp],rsi
     b51:	mov    QWORD PTR [r12+0x8],rdx
     b56:	mov    r15,rdx
     b59:	mov    QWORD PTR [r12+0x10],r8
     b5e:	mov    r14,r8
     b61:	mov    QWORD PTR [r12+0x18],r9
     b66:	mov    QWORD PTR [rsp+0x8],r9
     b6b:	mov    rsi,QWORD PTR [rsp]
     b6f:	mov    rdi,r13
     b72:	call   b77 <botlish_fn_4+0x7b>
			b73: R_X86_64_PLT32	rt_list_len-0x4
     b77:	mov    rcx,rbx
     b7a:	sar    rbx,1
     b7d:	sar    rax,1
     b80:	cmp    rbx,rax
     b83:	je     cfb <botlish_fn_4+0x1ff>
     b89:	test   rcx,0x1
     b90:	jne    b9e <botlish_fn_4+0xa2>
     b96:	mov    rdx,rcx
     b99:	jmp    bb2 <botlish_fn_4+0xb6>
     b9e:	mov    rsi,QWORD PTR [rsp]
     ba2:	mov    rax,QWORD PTR [rsi+0x8]
     ba6:	cmp    rbx,rax
     ba9:	jb     bd7 <botlish_fn_4+0xdb>
     baf:	mov    rdx,rcx
     bb2:	mov    rsi,QWORD PTR [rsp]
     bb6:	mov    rdi,r13
     bb9:	call   bbe <botlish_fn_4+0xc2>
			bba: R_X86_64_PLT32	rt_list_get-0x4
     bbe:	test   rax,rax
     bc1:	jne    bcf <botlish_fn_4+0xd3>
     bc7:	mov    rdi,r13
     bca:	jmp    ca8 <botlish_fn_4+0x1ac>
     bcf:	mov    rsi,rax
     bd2:	jmp    be3 <botlish_fn_4+0xe7>
     bd7:	mov    rsi,QWORD PTR [rsp]
     bdb:	mov    rax,QWORD PTR [rsi+0x10]
     bdf:	mov    rsi,QWORD PTR [rax+rbx*8]
     be3:	mov    QWORD PTR [r12+0x20],rsi
     be8:	mov    QWORD PTR [rsp+0x10],rsi
     bed:	mov    QWORD PTR [r12+0x28],0x1
     bf6:	xor    rdx,rdx
     bf9:	mov    rdi,r13
     bfc:	mov    rsi,rdx
     bff:	call   c04 <botlish_fn_4+0x108>
			c00: R_X86_64_PLT32	rt_list_new-0x4
     c04:	test   rax,rax
     c07:	jne    c15 <botlish_fn_4+0x119>
     c0d:	mov    rdi,r13
     c10:	jmp    ca8 <botlish_fn_4+0x1ac>
     c15:	mov    QWORD PTR [r12+0x30],rax
     c1a:	mov    r9,rax
     c1d:	mov    ecx,0x1
     c22:	mov    rsi,QWORD PTR [rsp+0x10]
     c27:	mov    rdx,r15
     c2a:	mov    rdi,r13
     c2d:	mov    r8,r14
     c30:	call   c35 <botlish_fn_4+0x139>
			c31: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     c35:	test   rax,rax
     c38:	jne    c46 <botlish_fn_4+0x14a>
     c3e:	mov    rdi,r13
     c41:	jmp    ca8 <botlish_fn_4+0x1ac>
     c46:	mov    QWORD PTR [r12+0x20],rax
     c4b:	mov    rdx,rax
     c4e:	lea    rcx,[rbx+0x1]
     c52:	shl    rcx,1
     c55:	or     rcx,0x1
     c59:	mov    QWORD PTR [r12+0x28],rcx
     c5e:	mov    rbx,rcx
     c61:	mov    rsi,QWORD PTR [rsp+0x8]
     c66:	mov    rdi,r13
     c69:	call   c6e <botlish_fn_4+0x172>
			c6a: R_X86_64_PLT32	rt_list_append-0x4
     c6e:	test   rax,rax
     c71:	jne    c7f <botlish_fn_4+0x183>
     c77:	mov    rdi,r13
     c7a:	jmp    ca8 <botlish_fn_4+0x1ac>
     c7f:	mov    QWORD PTR [r12+0x18],rax
     c84:	mov    rcx,rbx
     c87:	mov    rdx,r15
     c8a:	mov    rsi,QWORD PTR [rsp]
     c8e:	mov    r8,r14
     c91:	mov    r9,rax
     c94:	mov    rdi,r13
     c97:	call   c9c <botlish_fn_4+0x1a0>
			c98: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
     c9c:	test   rax,rax
     c9f:	jne    cd3 <botlish_fn_4+0x1d7>
     ca5:	mov    rdi,r13
     ca8:	mov    rdi,r13
     cab:	mov    QWORD PTR [rdi],r12
     cae:	xor    rax,rax
     cb1:	mov    rbx,QWORD PTR [rsp+0x20]
     cb6:	mov    r12,QWORD PTR [rsp+0x28]
     cbb:	mov    r13,QWORD PTR [rsp+0x30]
     cc0:	mov    r14,QWORD PTR [rsp+0x38]
     cc5:	mov    r15,QWORD PTR [rsp+0x40]
     cca:	add    rsp,0x50
     cce:	mov    rsp,rbp
     cd1:	pop    rbp
     cd2:	ret
     cd3:	mov    rdi,r13
     cd6:	mov    QWORD PTR [rdi],r12
     cd9:	mov    rbx,QWORD PTR [rsp+0x20]
     cde:	mov    r12,QWORD PTR [rsp+0x28]
     ce3:	mov    r13,QWORD PTR [rsp+0x30]
     ce8:	mov    r14,QWORD PTR [rsp+0x38]
     ced:	mov    r15,QWORD PTR [rsp+0x40]
     cf2:	add    rsp,0x50
     cf6:	mov    rsp,rbp
     cf9:	pop    rbp
     cfa:	ret
     cfb:	mov    rdi,r13
     cfe:	mov    QWORD PTR [rdi],r12
     d01:	mov    rax,QWORD PTR [rsp+0x8]
     d06:	mov    rbx,QWORD PTR [rsp+0x20]
     d0b:	mov    r12,QWORD PTR [rsp+0x28]
     d10:	mov    r13,QWORD PTR [rsp+0x30]
     d15:	mov    r14,QWORD PTR [rsp+0x38]
     d1a:	mov    r15,QWORD PTR [rsp+0x40]
     d1f:	add    rsp,0x50
     d23:	mov    rsp,rbp
     d26:	pop    rbp
     d27:	ret
     d28:	mov    r13,rdi
     d2b:	call   d30 <botlish_fn_4+0x234>
			d2c: R_X86_64_PLT32	rt_stack_overflow-0x4
     d30:	xor    rax,rax
     d33:	mov    rbx,QWORD PTR [rsp+0x20]
     d38:	mov    r12,QWORD PTR [rsp+0x28]
     d3d:	mov    r13,QWORD PTR [rsp+0x30]
     d42:	mov    r14,QWORD PTR [rsp+0x38]
     d47:	mov    r15,QWORD PTR [rsp+0x40]
     d4c:	add    rsp,0x50
     d50:	mov    rsp,rbp
     d53:	pop    rbp
     d54:	ret

0000000000000d55 <botlish_entry_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     d55:	push   rbp
     d56:	mov    rbp,rsp
     d59:	mov    rsi,QWORD PTR [rdx]
     d5c:	mov    r10,QWORD PTR [rdx+0x8]
     d60:	mov    rcx,QWORD PTR [rdx+0x10]
     d64:	mov    r8,QWORD PTR [rdx+0x18]
     d68:	mov    r9,QWORD PTR [rdx+0x20]
     d6c:	mov    rdx,r10
     d6f:	call   d74 <botlish_entry_4+0x1f>
			d70: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
     d74:	mov    rsp,rbp
     d77:	pop    rbp
     d78:	ret
     d79:	add    BYTE PTR [rax],al
     d7b:	add    BYTE PTR [rax],al
     d7d:	add    BYTE PTR [rax],al
	...

0000000000000d80 <botlish_fn_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
     d80:	push   rbp
     d81:	mov    rbp,rsp
     d84:	sub    rsp,0x50
     d88:	mov    QWORD PTR [rsp+0x20],rbx
     d8d:	mov    QWORD PTR [rsp+0x28],r12
     d92:	mov    QWORD PTR [rsp+0x30],r13
     d97:	mov    QWORD PTR [rsp+0x38],r14
     d9c:	mov    QWORD PTR [rsp+0x40],r15
     da1:	mov    r12,r8
     da4:	mov    r14,QWORD PTR [rdi]
     da7:	mov    rax,QWORD PTR [rdi+0x8]
     dab:	lea    r8,[r14+0x40]
     daf:	cmp    r8,rax
     db2:	ja     1006 <botlish_fn_5+0x286>
     db8:	lea    rax,[r14+0x40]
     dbc:	mov    QWORD PTR [rdi],rax
     dbf:	mov    r15,rdi
     dc2:	mov    QWORD PTR [r14+0x38],0x0
     dca:	mov    QWORD PTR [r14],rsi
     dcd:	mov    QWORD PTR [r14+0x8],rdx
     dd1:	mov    r13,rdx
     dd4:	mov    QWORD PTR [r14+0x10],rcx
     dd8:	mov    QWORD PTR [r14+0x18],r9
     ddc:	mov    rbx,rsi
     ddf:	mov    QWORD PTR [rsp],rcx
     de3:	mov    QWORD PTR [rsp+0x8],r9
     de8:	mov    rsi,rbx
     deb:	mov    rdi,r15
     dee:	call   df3 <botlish_fn_5+0x73>
			def: R_X86_64_PLT32	rt_list_len-0x4
     df3:	mov    rsi,QWORD PTR [rsp]
     df7:	mov    rcx,rsi
     dfa:	and    rcx,rax
     dfd:	mov    rdx,rax
     e00:	test   rcx,0x1
     e07:	jne    e2e <botlish_fn_5+0xae>
     e0d:	mov    rsi,QWORD PTR [rsp]
     e11:	mov    rdi,r15
     e14:	call   e19 <botlish_fn_5+0x99>
			e15: R_X86_64_PLT32	rt_int_cmp-0x4
     e19:	mov    ecx,0x2
     e1e:	test   rax,rax
     e21:	cmove  rcx,QWORD PTR [rip+0x20f]        # 1038 <botlish_fn_5+0x2b8>
     e29:	jmp    e42 <botlish_fn_5+0xc2>
     e2e:	mov    ecx,0x2
     e33:	mov    rsi,QWORD PTR [rsp]
     e37:	cmp    rsi,rdx
     e3a:	cmove  rcx,QWORD PTR [rip+0x1f6]        # 1038 <botlish_fn_5+0x2b8>
     e42:	cmp    rcx,0x6
     e46:	je     fd9 <botlish_fn_5+0x259>
     e4c:	mov    rsi,QWORD PTR [rsp]
     e50:	test   rsi,0x1
     e57:	je     e74 <botlish_fn_5+0xf4>
     e5d:	mov    rsi,QWORD PTR [rbx+0x8]
     e61:	mov    rax,QWORD PTR [rsp]
     e65:	mov    rdx,rax
     e68:	sar    rdx,1
     e6b:	cmp    rdx,rsi
     e6e:	jb     e9c <botlish_fn_5+0x11c>
     e74:	mov    rdx,QWORD PTR [rsp]
     e78:	mov    rsi,rbx
     e7b:	mov    rdi,r15
     e7e:	call   e83 <botlish_fn_5+0x103>
			e7f: R_X86_64_PLT32	rt_list_get-0x4
     e83:	test   rax,rax
     e86:	jne    e94 <botlish_fn_5+0x114>
     e8c:	mov    rdi,r15
     e8f:	jmp    f91 <botlish_fn_5+0x211>
     e94:	mov    rsi,rax
     e97:	jmp    ea4 <botlish_fn_5+0x124>
     e9c:	mov    r9,QWORD PTR [rbx+0x10]
     ea0:	mov    rsi,QWORD PTR [r9+rdx*8]
     ea4:	mov    QWORD PTR [r14+0x20],rsi
     ea8:	mov    QWORD PTR [rsp+0x10],rsi
     ead:	mov    QWORD PTR [r14+0x28],0x1
     eb5:	mov    rax,r12
     eb8:	or     rax,0x1
     ebc:	mov    QWORD PTR [r14+0x30],rax
     ec0:	xor    rdx,rdx
     ec3:	mov    rdi,r15
     ec6:	mov    rsi,rdx
     ec9:	call   ece <botlish_fn_5+0x14e>
			eca: R_X86_64_PLT32	rt_list_new-0x4
     ece:	test   rax,rax
     ed1:	jne    edf <botlish_fn_5+0x15f>
     ed7:	mov    rdi,r15
     eda:	jmp    f91 <botlish_fn_5+0x211>
     edf:	mov    QWORD PTR [r14+0x38],rax
     ee3:	mov    r9,rax
     ee6:	mov    ecx,0x1
     eeb:	mov    r8,r12
     eee:	or     r8,0x1
     ef2:	mov    rsi,QWORD PTR [rsp+0x10]
     ef7:	mov    rdx,r13
     efa:	mov    rdi,r15
     efd:	call   f02 <botlish_fn_5+0x182>
			efe: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     f02:	test   rax,rax
     f05:	jne    f13 <botlish_fn_5+0x193>
     f0b:	mov    rdi,r15
     f0e:	jmp    f91 <botlish_fn_5+0x211>
     f13:	mov    QWORD PTR [r14+0x20],rax
     f17:	mov    QWORD PTR [rsp+0x10],rax
     f1c:	mov    QWORD PTR [r14+0x28],0x3
     f24:	mov    rsi,QWORD PTR [rsp]
     f28:	test   rsi,0x1
     f2f:	je     f57 <botlish_fn_5+0x1d7>
     f35:	mov    rsi,QWORD PTR [rsp]
     f39:	mov    rax,rsi
     f3c:	add    rax,0x2
     f40:	seto   cl
     f43:	test   cl,cl
     f45:	jne    f57 <botlish_fn_5+0x1d7>
     f4b:	mov    rsi,rax
     f4e:	mov    QWORD PTR [rsp],rax
     f52:	jmp    f6f <botlish_fn_5+0x1ef>
     f57:	mov    edx,0x3
     f5c:	mov    rsi,QWORD PTR [rsp]
     f60:	mov    rdi,r15
     f63:	call   f68 <botlish_fn_5+0x1e8>
			f64: R_X86_64_PLT32	rt_int_add-0x4
     f68:	mov    rsi,rax
     f6b:	mov    QWORD PTR [rsp],rax
     f6f:	mov    QWORD PTR [r14+0x10],rsi
     f73:	mov    rdx,QWORD PTR [rsp+0x10]
     f78:	mov    rsi,QWORD PTR [rsp+0x8]
     f7d:	mov    rdi,r15
     f80:	call   f85 <botlish_fn_5+0x205>
			f81: R_X86_64_PLT32	rt_list_append-0x4
     f85:	test   rax,rax
     f88:	jne    fbc <botlish_fn_5+0x23c>
     f8e:	mov    rdi,r15
     f91:	mov    rdi,r15
     f94:	mov    QWORD PTR [rdi],r14
     f97:	xor    rax,rax
     f9a:	mov    rbx,QWORD PTR [rsp+0x20]
     f9f:	mov    r12,QWORD PTR [rsp+0x28]
     fa4:	mov    r13,QWORD PTR [rsp+0x30]
     fa9:	mov    r14,QWORD PTR [rsp+0x38]
     fae:	mov    r15,QWORD PTR [rsp+0x40]
     fb3:	add    rsp,0x50
     fb7:	mov    rsp,rbp
     fba:	pop    rbp
     fbb:	ret
     fbc:	mov    QWORD PTR [r14],rbx
     fbf:	mov    QWORD PTR [r14+0x8],r13
     fc3:	mov    rsi,QWORD PTR [rsp]
     fc7:	mov    QWORD PTR [r14+0x10],rsi
     fcb:	mov    QWORD PTR [r14+0x18],rax
     fcf:	mov    QWORD PTR [rsp+0x8],rax
     fd4:	jmp    de8 <botlish_fn_5+0x68>
     fd9:	mov    rdi,r15
     fdc:	mov    QWORD PTR [rdi],r14
     fdf:	mov    rax,QWORD PTR [rsp+0x8]
     fe4:	mov    rbx,QWORD PTR [rsp+0x20]
     fe9:	mov    r12,QWORD PTR [rsp+0x28]
     fee:	mov    r13,QWORD PTR [rsp+0x30]
     ff3:	mov    r14,QWORD PTR [rsp+0x38]
     ff8:	mov    r15,QWORD PTR [rsp+0x40]
     ffd:	add    rsp,0x50
    1001:	mov    rsp,rbp
    1004:	pop    rbp
    1005:	ret
    1006:	mov    r15,rdi
    1009:	call   100e <botlish_fn_5+0x28e>
			100a: R_X86_64_PLT32	rt_stack_overflow-0x4
    100e:	xor    rax,rax
    1011:	mov    rbx,QWORD PTR [rsp+0x20]
    1016:	mov    r12,QWORD PTR [rsp+0x28]
    101b:	mov    r13,QWORD PTR [rsp+0x30]
    1020:	mov    r14,QWORD PTR [rsp+0x38]
    1025:	mov    r15,QWORD PTR [rsp+0x40]
    102a:	add    rsp,0x50
    102e:	mov    rsp,rbp
    1031:	pop    rbp
    1032:	ret
    1033:	add    BYTE PTR [rax],al
    1035:	add    BYTE PTR [rax],al
    1037:	add    BYTE PTR [rsi],al
    1039:	add    BYTE PTR [rax],al
    103b:	add    BYTE PTR [rax],al
    103d:	add    BYTE PTR [rax],al
	...

0000000000001040 <botlish_entry_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
    1040:	push   rbp
    1041:	mov    rbp,rsp
    1044:	mov    rsi,QWORD PTR [rdx]
    1047:	mov    r10,QWORD PTR [rdx+0x8]
    104b:	mov    rcx,QWORD PTR [rdx+0x10]
    104f:	mov    r8,QWORD PTR [rdx+0x18]
    1053:	mov    r9,QWORD PTR [rdx+0x20]
    1057:	mov    rdx,r10
    105a:	call   105f <botlish_entry_5+0x1f>
			105b: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
    105f:	mov    rsp,rbp
    1062:	pop    rbp
    1063:	ret

0000000000001064 <botlish_fn_6: matmul<list<list<int>>, list<list<int>>>>:
    1064:	push   rbp
    1065:	mov    rbp,rsp
    1068:	sub    rsp,0x30
    106c:	mov    QWORD PTR [rsp],rbx
    1070:	mov    QWORD PTR [rsp+0x8],r12
    1075:	mov    QWORD PTR [rsp+0x10],r13
    107a:	mov    QWORD PTR [rsp+0x18],r14
    107f:	mov    QWORD PTR [rsp+0x20],r15
    1084:	mov    r12,QWORD PTR [rdi]
    1087:	mov    rax,QWORD PTR [rdi+0x8]
    108b:	lea    rcx,[r12+0x28]
    1090:	cmp    rcx,rax
    1093:	ja     121e <botlish_fn_6+0x1ba>
    1099:	lea    rax,[r12+0x28]
    109e:	mov    QWORD PTR [rdi],rax
    10a1:	mov    r13,rdi
    10a4:	mov    QWORD PTR [r12+0x10],0x0
    10ad:	mov    QWORD PTR [r12+0x18],0x0
    10b6:	mov    QWORD PTR [r12+0x20],0x0
    10bf:	mov    QWORD PTR [r12],rsi
    10c3:	mov    r14,rsi
    10c6:	mov    QWORD PTR [r12+0x8],rdx
    10cb:	mov    rbx,rdx
    10ce:	mov    rsi,r14
    10d1:	mov    rdi,r13
    10d4:	call   10d9 <botlish_fn_6+0x75>
			10d5: R_X86_64_PLT32	rt_list_len-0x4
    10d9:	sar    rax,1
    10dc:	test   rax,rax
    10df:	je     11b3 <botlish_fn_6+0x14f>
    10e5:	mov    QWORD PTR [r12+0x10],0x1
    10ee:	mov    rax,QWORD PTR [rbx+0x8]
    10f2:	test   rax,rax
    10f5:	jne    1124 <botlish_fn_6+0xc0>
    10fb:	mov    edx,0x1
    1100:	mov    rsi,rbx
    1103:	mov    rdi,r13
    1106:	call   110b <botlish_fn_6+0xa7>
			1107: R_X86_64_PLT32	rt_list_get-0x4
    110b:	test   rax,rax
    110e:	jne    111c <botlish_fn_6+0xb8>
    1114:	mov    rdi,r13
    1117:	jmp    11cd <botlish_fn_6+0x169>
    111c:	mov    rsi,rax
    111f:	jmp    112e <botlish_fn_6+0xca>
    1124:	mov    rdx,rbx
    1127:	mov    rax,QWORD PTR [rdx+0x10]
    112b:	mov    rsi,QWORD PTR [rax]
    112e:	mov    rdi,r13
    1131:	call   1136 <botlish_fn_6+0xd2>
			1132: R_X86_64_PLT32	rt_list_len-0x4
    1136:	mov    QWORD PTR [r12+0x18],rax
    113b:	mov    r15,rax
    113e:	xor    rdx,rdx
    1141:	mov    rdi,r13
    1144:	mov    rsi,rdx
    1147:	call   114c <botlish_fn_6+0xe8>
			1148: R_X86_64_PLT32	rt_list_new-0x4
    114c:	test   rax,rax
    114f:	jne    115d <botlish_fn_6+0xf9>
    1155:	mov    rdi,r13
    1158:	jmp    11cd <botlish_fn_6+0x169>
    115d:	mov    QWORD PTR [r12+0x20],rax
    1162:	mov    r9,rax
    1165:	mov    ecx,0x1
    116a:	mov    rdx,rbx
    116d:	mov    rsi,r14
    1170:	mov    r8,r15
    1173:	mov    rdi,r13
    1176:	call   117b <botlish_fn_6+0x117>
			1177: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
    117b:	test   rax,rax
    117e:	jne    118c <botlish_fn_6+0x128>
    1184:	mov    rdi,r13
    1187:	jmp    11cd <botlish_fn_6+0x169>
    118c:	mov    rdi,r13
    118f:	mov    QWORD PTR [rdi],r12
    1192:	mov    rbx,QWORD PTR [rsp]
    1196:	mov    r12,QWORD PTR [rsp+0x8]
    119b:	mov    r13,QWORD PTR [rsp+0x10]
    11a0:	mov    r14,QWORD PTR [rsp+0x18]
    11a5:	mov    r15,QWORD PTR [rsp+0x20]
    11aa:	add    rsp,0x30
    11ae:	mov    rsp,rbp
    11b1:	pop    rbp
    11b2:	ret
    11b3:	xor    rdx,rdx
    11b6:	mov    rdi,r13
    11b9:	mov    rsi,rdx
    11bc:	call   11c1 <botlish_fn_6+0x15d>
			11bd: R_X86_64_PLT32	rt_list_new-0x4
    11c1:	test   rax,rax
    11c4:	jne    11f7 <botlish_fn_6+0x193>
    11ca:	mov    rdi,r13
    11cd:	mov    rdi,r13
    11d0:	mov    QWORD PTR [rdi],r12
    11d3:	xor    rax,rax
    11d6:	mov    rbx,QWORD PTR [rsp]
    11da:	mov    r12,QWORD PTR [rsp+0x8]
    11df:	mov    r13,QWORD PTR [rsp+0x10]
    11e4:	mov    r14,QWORD PTR [rsp+0x18]
    11e9:	mov    r15,QWORD PTR [rsp+0x20]
    11ee:	add    rsp,0x30
    11f2:	mov    rsp,rbp
    11f5:	pop    rbp
    11f6:	ret
    11f7:	mov    rdi,r13
    11fa:	mov    QWORD PTR [rdi],r12
    11fd:	mov    rbx,QWORD PTR [rsp]
    1201:	mov    r12,QWORD PTR [rsp+0x8]
    1206:	mov    r13,QWORD PTR [rsp+0x10]
    120b:	mov    r14,QWORD PTR [rsp+0x18]
    1210:	mov    r15,QWORD PTR [rsp+0x20]
    1215:	add    rsp,0x30
    1219:	mov    rsp,rbp
    121c:	pop    rbp
    121d:	ret
    121e:	mov    r13,rdi
    1221:	call   1226 <botlish_fn_6+0x1c2>
			1222: R_X86_64_PLT32	rt_stack_overflow-0x4
    1226:	xor    rax,rax
    1229:	mov    rbx,QWORD PTR [rsp]
    122d:	mov    r12,QWORD PTR [rsp+0x8]
    1232:	mov    r13,QWORD PTR [rsp+0x10]
    1237:	mov    r14,QWORD PTR [rsp+0x18]
    123c:	mov    r15,QWORD PTR [rsp+0x20]
    1241:	add    rsp,0x30
    1245:	mov    rsp,rbp
    1248:	pop    rbp
    1249:	ret

000000000000124a <botlish_entry_6: matmul<list<list<int>>, list<list<int>>>>:
    124a:	push   rbp
    124b:	mov    rbp,rsp
    124e:	mov    rsi,QWORD PTR [rdx]
    1251:	mov    rdx,QWORD PTR [rdx+0x8]
    1255:	call   125a <botlish_entry_6+0x10>
			1256: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
    125a:	mov    rsp,rbp
    125d:	pop    rbp
    125e:	ret

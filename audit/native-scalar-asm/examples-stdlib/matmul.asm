; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4511  (per function: 750 706 513 751 580 831 380)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> dot<List[int], List[List[int]], int, int, int, int>
;   botlish_fn_2 / botlish_entry_2 -> product_row<List[int], List[List[int]], int, int, List[never]>
;   botlish_fn_3 / botlish_entry_3 -> product_row<List[int], List[List[int]], int, int, List[int]>
;   botlish_fn_4 / botlish_entry_4 -> product_rows<List[List[int]], List[List[int]], int, int, List[never]>
;   botlish_fn_5 / botlish_entry_5 -> product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
;   botlish_fn_6 / botlish_entry_6 -> matmul<List[List[int]], List[List[int]]>


matmul.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0xd0
       b:	mov    QWORD PTR [rsp+0xb0],rbx
      13:	mov    QWORD PTR [rsp+0xb8],r12
      1b:	mov    QWORD PTR [rsp+0xc0],r13
      23:	mov    QWORD PTR [rsp+0xc8],r14
      2b:	mov    rbx,rdi
      2e:	mov    QWORD PTR [rsp+0x18],0x0
      37:	mov    QWORD PTR [rsp+0x20],0x0
      40:	mov    esi,0x3
      45:	mov    QWORD PTR [rsp],0x3
      4d:	mov    QWORD PTR [rsp+0x8],0x5
      56:	mov    QWORD PTR [rsp+0x10],0x7
      5f:	lea    rdx,[rsp+0x28]
      64:	mov    QWORD PTR [rsp+0x28],0x3
      6d:	mov    QWORD PTR [rsp+0x30],0x5
      76:	mov    QWORD PTR [rsp+0x38],0x7
      7f:	mov    rdi,rbx
      82:	call   87 <botlish_fn_0+0x87>
			83: R_X86_64_PLT32	rt_list_new-0x4
      87:	test   rax,rax
      8a:	je     252 <botlish_fn_0+0x252>
      90:	mov    QWORD PTR [rsp],rax
      94:	mov    r12,rax
      97:	mov    QWORD PTR [rsp+0x8],0x9
      a0:	mov    QWORD PTR [rsp+0x10],0xb
      a9:	mov    QWORD PTR [rsp+0x18],0xd
      b2:	lea    rdx,[rsp+0x40]
      b7:	mov    QWORD PTR [rsp+0x40],0x9
      c0:	mov    QWORD PTR [rsp+0x48],0xb
      c9:	mov    QWORD PTR [rsp+0x50],0xd
      d2:	mov    esi,0x3
      d7:	mov    rdi,rbx
      da:	call   df <botlish_fn_0+0xdf>
			db: R_X86_64_PLT32	rt_list_new-0x4
      df:	test   rax,rax
      e2:	je     252 <botlish_fn_0+0x252>
      e8:	mov    QWORD PTR [rsp+0x8],rax
      ed:	lea    rdx,[rsp+0x58]
      f2:	mov    rsi,r12
      f5:	mov    QWORD PTR [rsp+0x58],rsi
      fa:	mov    QWORD PTR [rsp+0x60],rax
      ff:	mov    esi,0x2
     104:	mov    rdi,rbx
     107:	call   10c <botlish_fn_0+0x10c>
			108: R_X86_64_PLT32	rt_list_new-0x4
     10c:	test   rax,rax
     10f:	je     252 <botlish_fn_0+0x252>
     115:	mov    QWORD PTR [rsp],rax
     119:	mov    r12,rax
     11c:	mov    QWORD PTR [rsp+0x8],0xf
     125:	mov    QWORD PTR [rsp+0x10],0x11
     12e:	lea    rdx,[rsp+0x68]
     133:	mov    QWORD PTR [rsp+0x68],0xf
     13c:	mov    QWORD PTR [rsp+0x70],0x11
     145:	mov    esi,0x2
     14a:	mov    rdi,rbx
     14d:	call   152 <botlish_fn_0+0x152>
			14e: R_X86_64_PLT32	rt_list_new-0x4
     152:	test   rax,rax
     155:	je     252 <botlish_fn_0+0x252>
     15b:	mov    QWORD PTR [rsp+0x8],rax
     160:	mov    r13,rax
     163:	mov    QWORD PTR [rsp+0x10],0x13
     16c:	mov    QWORD PTR [rsp+0x18],0x15
     175:	lea    rdx,[rsp+0x78]
     17a:	mov    QWORD PTR [rsp+0x78],0x13
     183:	mov    QWORD PTR [rsp+0x80],0x15
     18f:	mov    esi,0x2
     194:	mov    rdi,rbx
     197:	call   19c <botlish_fn_0+0x19c>
			198: R_X86_64_PLT32	rt_list_new-0x4
     19c:	test   rax,rax
     19f:	je     252 <botlish_fn_0+0x252>
     1a5:	mov    QWORD PTR [rsp+0x10],rax
     1aa:	mov    r14,rax
     1ad:	mov    QWORD PTR [rsp+0x18],0x17
     1b6:	mov    QWORD PTR [rsp+0x20],0x19
     1bf:	lea    rdx,[rsp+0x88]
     1c7:	mov    QWORD PTR [rsp+0x88],0x17
     1d3:	mov    QWORD PTR [rsp+0x90],0x19
     1df:	mov    esi,0x2
     1e4:	mov    rdi,rbx
     1e7:	call   1ec <botlish_fn_0+0x1ec>
			1e8: R_X86_64_PLT32	rt_list_new-0x4
     1ec:	test   rax,rax
     1ef:	je     252 <botlish_fn_0+0x252>
     1f5:	mov    QWORD PTR [rsp+0x18],rax
     1fa:	lea    rdx,[rsp+0x98]
     202:	mov    rcx,r13
     205:	mov    QWORD PTR [rsp+0x98],rcx
     20d:	mov    rcx,r14
     210:	mov    QWORD PTR [rsp+0xa0],rcx
     218:	mov    QWORD PTR [rsp+0xa8],rax
     220:	mov    esi,0x3
     225:	mov    rdi,rbx
     228:	call   22d <botlish_fn_0+0x22d>
			229: R_X86_64_PLT32	rt_list_new-0x4
     22d:	test   rax,rax
     230:	je     252 <botlish_fn_0+0x252>
     236:	mov    QWORD PTR [rsp+0x8],rax
     23b:	mov    rdx,rax
     23e:	mov    rsi,r12
     241:	mov    rdi,rbx
     244:	call   249 <botlish_fn_0+0x249>
			245: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<List[List[int]], List[List[int]]>
     249:	test   rax,rax
     24c:	jne    281 <botlish_fn_0+0x281>
     252:	xor    rax,rax
     255:	mov    rbx,QWORD PTR [rsp+0xb0]
     25d:	mov    r12,QWORD PTR [rsp+0xb8]
     265:	mov    r13,QWORD PTR [rsp+0xc0]
     26d:	mov    r14,QWORD PTR [rsp+0xc8]
     275:	add    rsp,0xd0
     27c:	mov    rsp,rbp
     27f:	pop    rbp
     280:	ret
     281:	mov    rbx,QWORD PTR [rsp+0xb0]
     289:	mov    r12,QWORD PTR [rsp+0xb8]
     291:	mov    r13,QWORD PTR [rsp+0xc0]
     299:	mov    r14,QWORD PTR [rsp+0xc8]
     2a1:	add    rsp,0xd0
     2a8:	mov    rsp,rbp
     2ab:	pop    rbp
     2ac:	ret

00000000000002ad <botlish_entry_0: <program entry>>:
     2ad:	push   rbp
     2ae:	mov    rbp,rsp
     2b1:	call   2b6 <botlish_entry_0+0x9>
			2b2: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     2b6:	mov    rsp,rbp
     2b9:	pop    rbp
     2ba:	ret

00000000000002bb <botlish_fn_1: dot<List[int], List[List[int]], int, int, int, int>>:
     2bb:	push   rbp
     2bc:	mov    rbp,rsp
     2bf:	sub    rsp,0x80
     2c6:	mov    QWORD PTR [rsp+0x50],rbx
     2cb:	mov    QWORD PTR [rsp+0x58],r12
     2d0:	mov    QWORD PTR [rsp+0x60],r13
     2d5:	mov    QWORD PTR [rsp+0x68],r14
     2da:	mov    QWORD PTR [rsp+0x70],r15
     2df:	mov    QWORD PTR [rsp+0x30],rdi
     2e4:	mov    QWORD PTR [rsp+0x38],r9
     2e9:	mov    rdi,QWORD PTR [rbp+0x10]
     2ed:	mov    QWORD PTR [rsp],rsi
     2f1:	mov    QWORD PTR [rsp+0x8],rdx
     2f6:	mov    r14,rdx
     2f9:	mov    QWORD PTR [rsp+0x10],rcx
     2fe:	mov    QWORD PTR [rsp+0x18],rdi
     303:	mov    rbx,rcx
     306:	sar    rbx,1
     309:	mov    r15,rcx
     30c:	mov    rcx,QWORD PTR [rsp+0x38]
     311:	mov    r12,r8
     314:	mov    QWORD PTR [rsp+0x40],rdi
     319:	cmp    r12,rcx
     31c:	mov    QWORD PTR [rsp+0x38],rcx
     321:	je     4ef <botlish_fn_1+0x234>
     327:	mov    r13,rsi
     32a:	mov    rcx,QWORD PTR [r13+0x8]
     32e:	mov    rax,r12
     331:	shl    rax,1
     334:	or     rax,0x1
     338:	sar    rax,1
     33b:	cmp    rax,rcx
     33e:	jb     36c <botlish_fn_1+0xb1>
     344:	mov    rdx,r12
     347:	shl    rdx,1
     34a:	or     rdx,0x1
     34e:	mov    rsi,r13
     351:	mov    rdi,QWORD PTR [rsp+0x30]
     356:	call   35b <botlish_fn_1+0xa0>
			357: R_X86_64_PLT32	rt_list_get-0x4
     35b:	test   rax,rax
     35e:	je     3f8 <botlish_fn_1+0x13d>
     364:	mov    rsi,rax
     367:	jmp    374 <botlish_fn_1+0xb9>
     36c:	mov    rdi,QWORD PTR [r13+0x10]
     370:	mov    rsi,QWORD PTR [rdi+rax*8]
     374:	mov    QWORD PTR [rsp+0x20],rsi
     379:	mov    QWORD PTR [rsp+0x48],rsi
     37e:	mov    r10,QWORD PTR [r14+0x8]
     382:	mov    r8,r12
     385:	shl    r8,1
     388:	or     r8,0x1
     38c:	sar    r8,1
     38f:	cmp    r8,r10
     392:	jb     3c0 <botlish_fn_1+0x105>
     398:	mov    rdx,r12
     39b:	shl    rdx,1
     39e:	or     rdx,0x1
     3a2:	mov    rsi,r14
     3a5:	mov    rdi,QWORD PTR [rsp+0x30]
     3aa:	call   3af <botlish_fn_1+0xf4>
			3ab: R_X86_64_PLT32	rt_list_get-0x4
     3af:	test   rax,rax
     3b2:	je     3f8 <botlish_fn_1+0x13d>
     3b8:	mov    rsi,rax
     3bb:	jmp    3c8 <botlish_fn_1+0x10d>
     3c0:	mov    rax,QWORD PTR [r14+0x10]
     3c4:	mov    rsi,QWORD PTR [rax+r8*8]
     3c8:	test   r15,0x1
     3cf:	je     3e2 <botlish_fn_1+0x127>
     3d5:	mov    rax,QWORD PTR [rsi+0x8]
     3d9:	cmp    rbx,rax
     3dc:	jb     428 <botlish_fn_1+0x16d>
     3e2:	mov    rdx,r15
     3e5:	mov    rdi,QWORD PTR [rsp+0x30]
     3ea:	call   3ef <botlish_fn_1+0x134>
			3eb: R_X86_64_PLT32	rt_list_get-0x4
     3ef:	test   rax,rax
     3f2:	jne    420 <botlish_fn_1+0x165>
     3f8:	xor    rax,rax
     3fb:	mov    rbx,QWORD PTR [rsp+0x50]
     400:	mov    r12,QWORD PTR [rsp+0x58]
     405:	mov    r13,QWORD PTR [rsp+0x60]
     40a:	mov    r14,QWORD PTR [rsp+0x68]
     40f:	mov    r15,QWORD PTR [rsp+0x70]
     414:	add    rsp,0x80
     41b:	mov    rsp,rbp
     41e:	pop    rbp
     41f:	ret
     420:	mov    rdx,rax
     423:	jmp    430 <botlish_fn_1+0x175>
     428:	mov    rax,QWORD PTR [rsi+0x10]
     42c:	mov    rdx,QWORD PTR [rax+rbx*8]
     430:	mov    QWORD PTR [rsp+0x28],rdx
     435:	mov    rsi,QWORD PTR [rsp+0x48]
     43a:	mov    rax,rsi
     43d:	and    rax,rdx
     440:	test   rax,0x1
     446:	je     47b <botlish_fn_1+0x1c0>
     44c:	mov    rax,rsi
     44f:	sar    rax,1
     452:	lea    rcx,[rdx-0x1]
     456:	mov    r10,rdx
     459:	imul   rcx
     45c:	seto   cl
     45f:	or     rax,0x1
     463:	test   cl,cl
     465:	je     473 <botlish_fn_1+0x1b8>
     46b:	mov    rdx,r10
     46e:	jmp    47b <botlish_fn_1+0x1c0>
     473:	mov    rdx,rax
     476:	jmp    488 <botlish_fn_1+0x1cd>
     47b:	mov    rdi,QWORD PTR [rsp+0x30]
     480:	call   485 <botlish_fn_1+0x1ca>
			481: R_X86_64_PLT32	rt_int_mul-0x4
     485:	mov    rdx,rax
     488:	mov    QWORD PTR [rsp+0x20],rdx
     48d:	mov    rsi,QWORD PTR [rsp+0x40]
     492:	mov    rax,rsi
     495:	and    rax,rdx
     498:	test   rax,0x1
     49e:	je     4b9 <botlish_fn_1+0x1fe>
     4a4:	lea    rcx,[rdx-0x1]
     4a8:	mov    rax,rsi
     4ab:	add    rax,rcx
     4ae:	seto   cl
     4b1:	test   cl,cl
     4b3:	je     4c3 <botlish_fn_1+0x208>
     4b9:	mov    rdi,QWORD PTR [rsp+0x30]
     4be:	call   4c3 <botlish_fn_1+0x208>
			4bf: R_X86_64_PLT32	rt_int_add-0x4
     4c3:	mov    QWORD PTR [rsp],r13
     4c7:	mov    QWORD PTR [rsp+0x8],r14
     4cc:	mov    QWORD PTR [rsp+0x10],r15
     4d1:	mov    QWORD PTR [rsp+0x18],rax
     4d6:	add    r12,0x1
     4dd:	mov    rcx,QWORD PTR [rsp+0x38]
     4e2:	mov    rsi,r13
     4e5:	mov    QWORD PTR [rsp+0x40],rax
     4ea:	jmp    319 <botlish_fn_1+0x5e>
     4ef:	mov    rax,QWORD PTR [rsp+0x40]
     4f4:	mov    rbx,QWORD PTR [rsp+0x50]
     4f9:	mov    r12,QWORD PTR [rsp+0x58]
     4fe:	mov    r13,QWORD PTR [rsp+0x60]
     503:	mov    r14,QWORD PTR [rsp+0x68]
     508:	mov    r15,QWORD PTR [rsp+0x70]
     50d:	add    rsp,0x80
     514:	mov    rsp,rbp
     517:	pop    rbp
     518:	ret

0000000000000519 <botlish_entry_1: dot<List[int], List[List[int]], int, int, int, int>>:
     519:	push   rbp
     51a:	mov    rbp,rsp
     51d:	sub    rsp,0x10
     521:	mov    rsi,QWORD PTR [rdx]
     524:	mov    r11,QWORD PTR [rdx+0x8]
     528:	mov    rcx,QWORD PTR [rdx+0x10]
     52c:	mov    r8,QWORD PTR [rdx+0x18]
     530:	mov    r9,QWORD PTR [rdx+0x20]
     534:	mov    rax,QWORD PTR [rdx+0x28]
     538:	sar    r8,1
     53b:	sar    r9,1
     53e:	mov    QWORD PTR [rsp],rax
     542:	mov    rdx,r11
     545:	call   54a <botlish_entry_1+0x31>
			546: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     54a:	add    rsp,0x10
     54e:	mov    rsp,rbp
     551:	pop    rbp
     552:	ret

0000000000000553 <botlish_fn_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     553:	push   rbp
     554:	mov    rbp,rsp
     557:	sub    rsp,0xa0
     55e:	mov    QWORD PTR [rsp+0x70],rbx
     563:	mov    QWORD PTR [rsp+0x78],r12
     568:	mov    QWORD PTR [rsp+0x80],r13
     570:	mov    QWORD PTR [rsp+0x88],r14
     578:	mov    QWORD PTR [rsp+0x90],r15
     580:	mov    r15,rdi
     583:	mov    QWORD PTR [rsp+0x10],rsi
     588:	mov    r14,rsi
     58b:	mov    QWORD PTR [rsp+0x18],rdx
     590:	mov    r13,rdx
     593:	mov    QWORD PTR [rsp+0x20],r9
     598:	mov    QWORD PTR [rsp+0x60],r9
     59d:	cmp    rcx,r8
     5a0:	mov    r12,r8
     5a3:	je     6e9 <botlish_fn_2+0x196>
     5a9:	mov    ebx,0x1
     5ae:	mov    rax,rcx
     5b1:	shl    rax,1
     5b4:	mov    QWORD PTR [rsp+0x58],rcx
     5b9:	or     rax,0x1
     5bd:	mov    QWORD PTR [rsp+0x28],rax
     5c2:	mov    QWORD PTR [rsp+0x68],rax
     5c7:	mov    rsi,r14
     5ca:	mov    rdi,r15
     5cd:	call   5d2 <botlish_fn_2+0x7f>
			5ce: R_X86_64_PLT32	rt_list_len-0x4
     5d2:	mov    QWORD PTR [rsp+0x30],0x1
     5db:	xor    r8,r8
     5de:	mov    r9,rax
     5e1:	sar    r9,1
     5e4:	mov    QWORD PTR [rsp],rbx
     5e8:	mov    rcx,QWORD PTR [rsp+0x68]
     5ed:	mov    rdx,r13
     5f0:	mov    rsi,r14
     5f3:	mov    rdi,r15
     5f6:	call   5fb <botlish_fn_2+0xa8>
			5f7: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     5fb:	test   rax,rax
     5fe:	je     68a <botlish_fn_2+0x137>
     604:	mov    QWORD PTR [rsp+0x28],rax
     609:	mov    rcx,QWORD PTR [rsp+0x58]
     60e:	add    rcx,0x1
     615:	shl    rcx,1
     618:	or     rcx,0x1
     61c:	mov    QWORD PTR [rsp+0x30],rcx
     621:	mov    rbx,rcx
     624:	lea    rcx,[rsp+0x38]
     629:	mov    QWORD PTR [rsp+0x38],0x0
     632:	mov    r9,QWORD PTR [rsp+0x60]
     637:	mov    QWORD PTR [rsp+0x40],r9
     63c:	mov    QWORD PTR [rsp+0x48],0x2
     645:	mov    QWORD PTR [rsp+0x50],rax
     64a:	mov    esi,0x3
     64f:	mov    edx,0x4
     654:	mov    rdi,r15
     657:	call   65c <botlish_fn_2+0x109>
			658: R_X86_64_PLT32	rt_construct-0x4
     65c:	test   rax,rax
     65f:	je     68a <botlish_fn_2+0x137>
     665:	mov    QWORD PTR [rsp+0x20],rax
     66a:	mov    rcx,rbx
     66d:	mov    rdx,r13
     670:	mov    rsi,r14
     673:	mov    rdi,r15
     676:	mov    r8,r12
     679:	mov    r9,rax
     67c:	call   681 <botlish_fn_2+0x12e>
			67d: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     681:	test   rax,rax
     684:	jne    6bb <botlish_fn_2+0x168>
     68a:	xor    rax,rax
     68d:	mov    rbx,QWORD PTR [rsp+0x70]
     692:	mov    r12,QWORD PTR [rsp+0x78]
     697:	mov    r13,QWORD PTR [rsp+0x80]
     69f:	mov    r14,QWORD PTR [rsp+0x88]
     6a7:	mov    r15,QWORD PTR [rsp+0x90]
     6af:	add    rsp,0xa0
     6b6:	mov    rsp,rbp
     6b9:	pop    rbp
     6ba:	ret
     6bb:	mov    rbx,QWORD PTR [rsp+0x70]
     6c0:	mov    r12,QWORD PTR [rsp+0x78]
     6c5:	mov    r13,QWORD PTR [rsp+0x80]
     6cd:	mov    r14,QWORD PTR [rsp+0x88]
     6d5:	mov    r15,QWORD PTR [rsp+0x90]
     6dd:	add    rsp,0xa0
     6e4:	mov    rsp,rbp
     6e7:	pop    rbp
     6e8:	ret
     6e9:	mov    rax,QWORD PTR [rsp+0x60]
     6ee:	mov    rbx,QWORD PTR [rsp+0x70]
     6f3:	mov    r12,QWORD PTR [rsp+0x78]
     6f8:	mov    r13,QWORD PTR [rsp+0x80]
     700:	mov    r14,QWORD PTR [rsp+0x88]
     708:	mov    r15,QWORD PTR [rsp+0x90]
     710:	add    rsp,0xa0
     717:	mov    rsp,rbp
     71a:	pop    rbp
     71b:	ret

000000000000071c <botlish_entry_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     71c:	push   rbp
     71d:	mov    rbp,rsp
     720:	mov    rsi,QWORD PTR [rdx]
     723:	mov    r10,QWORD PTR [rdx+0x8]
     727:	mov    rcx,QWORD PTR [rdx+0x10]
     72b:	mov    r8,QWORD PTR [rdx+0x18]
     72f:	mov    r9,QWORD PTR [rdx+0x20]
     733:	sar    rcx,1
     736:	sar    r8,1
     739:	mov    rdx,r10
     73c:	call   741 <botlish_entry_2+0x25>
			73d: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     741:	mov    rsp,rbp
     744:	pop    rbp
     745:	ret
	...

0000000000000748 <botlish_fn_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     748:	push   rbp
     749:	mov    rbp,rsp
     74c:	sub    rsp,0xc0
     753:	mov    QWORD PTR [rsp+0x90],rbx
     75b:	mov    QWORD PTR [rsp+0x98],r12
     763:	mov    QWORD PTR [rsp+0xa0],r13
     76b:	mov    QWORD PTR [rsp+0xa8],r14
     773:	mov    QWORD PTR [rsp+0xb0],r15
     77b:	mov    r15,rdi
     77e:	mov    QWORD PTR [rsp+0x30],0x0
     787:	mov    QWORD PTR [rsp+0x38],0x0
     790:	mov    QWORD PTR [rsp+0x10],rsi
     795:	mov    r12,rsi
     798:	mov    QWORD PTR [rsp+0x18],rdx
     79d:	mov    r13,rdx
     7a0:	mov    QWORD PTR [rsp+0x20],rcx
     7a5:	mov    QWORD PTR [rsp+0x28],r9
     7aa:	mov    QWORD PTR [rsp+0x78],r9
     7af:	shl    r8,1
     7b2:	lea    r14,[rsp+0x50]
     7b7:	mov    rbx,r8
     7ba:	mov    rsi,rcx
     7bd:	mov    rax,rbx
     7c0:	or     rax,0x1
     7c4:	mov    rcx,rsi
     7c7:	and    rcx,rax
     7ca:	mov    QWORD PTR [rsp+0x70],rsi
     7cf:	test   rcx,0x1
     7d6:	jne    805 <botlish_fn_3+0xbd>
     7dc:	mov    rdx,rbx
     7df:	or     rdx,0x1
     7e3:	mov    rsi,QWORD PTR [rsp+0x70]
     7e8:	mov    rdi,r15
     7eb:	call   7f0 <botlish_fn_3+0xa8>
			7ec: R_X86_64_PLT32	rt_int_cmp-0x4
     7f0:	mov    ecx,0x2
     7f5:	test   rax,rax
     7f8:	cmove  rcx,QWORD PTR [rip+0x1e8]        # 9e8 <botlish_fn_3+0x2a0>
     800:	jmp    821 <botlish_fn_3+0xd9>
     805:	mov    rax,rbx
     808:	or     rax,0x1
     80c:	mov    ecx,0x2
     811:	mov    rsi,QWORD PTR [rsp+0x70]
     816:	cmp    rsi,rax
     819:	cmove  rcx,QWORD PTR [rip+0x1c7]        # 9e8 <botlish_fn_3+0x2a0>
     821:	cmp    rcx,0x6
     825:	je     944 <botlish_fn_3+0x1fc>
     82b:	mov    rsi,r12
     82e:	mov    rdi,r15
     831:	call   836 <botlish_fn_3+0xee>
			832: R_X86_64_PLT32	rt_list_len-0x4
     836:	mov    ecx,0x1
     83b:	mov    QWORD PTR [rsp+0x30],0x1
     844:	xor    r8,r8
     847:	mov    r9,rax
     84a:	sar    r9,1
     84d:	mov    QWORD PTR [rsp],rcx
     851:	mov    rcx,QWORD PTR [rsp+0x70]
     856:	mov    rdx,r13
     859:	mov    rsi,r12
     85c:	mov    rdi,r15
     85f:	call   864 <botlish_fn_3+0x11c>
			860: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     864:	test   rax,rax
     867:	je     977 <botlish_fn_3+0x22f>
     86d:	mov    QWORD PTR [rsp+0x30],rax
     872:	mov    QWORD PTR [rsp+0x80],rax
     87a:	mov    QWORD PTR [rsp+0x38],0x3
     883:	mov    rsi,QWORD PTR [rsp+0x70]
     888:	test   rsi,0x1
     88f:	je     8bb <botlish_fn_3+0x173>
     895:	mov    rsi,QWORD PTR [rsp+0x70]
     89a:	mov    rdx,rsi
     89d:	add    rdx,0x2
     8a1:	seto   sil
     8a5:	test   sil,sil
     8a8:	jne    8bb <botlish_fn_3+0x173>
     8ae:	mov    rsi,rdx
     8b1:	mov    QWORD PTR [rsp+0x70],rdx
     8b6:	jmp    8d5 <botlish_fn_3+0x18d>
     8bb:	mov    edx,0x3
     8c0:	mov    rsi,QWORD PTR [rsp+0x70]
     8c5:	mov    rdi,r15
     8c8:	call   8cd <botlish_fn_3+0x185>
			8c9: R_X86_64_PLT32	rt_int_add-0x4
     8cd:	mov    rsi,rax
     8d0:	mov    QWORD PTR [rsp+0x70],rax
     8d5:	mov    QWORD PTR [rsp+0x20],rsi
     8da:	mov    QWORD PTR [rsp+0x50],0x0
     8e3:	mov    r9,QWORD PTR [rsp+0x78]
     8e8:	mov    QWORD PTR [rsp+0x58],r9
     8ed:	mov    QWORD PTR [rsp+0x60],0x2
     8f6:	mov    rax,QWORD PTR [rsp+0x80]
     8fe:	mov    QWORD PTR [rsp+0x68],rax
     903:	mov    esi,0x3
     908:	mov    edx,0x4
     90d:	mov    rcx,r14
     910:	mov    rdi,r15
     913:	call   918 <botlish_fn_3+0x1d0>
			914: R_X86_64_PLT32	rt_construct-0x4
     918:	test   rax,rax
     91b:	je     977 <botlish_fn_3+0x22f>
     921:	mov    QWORD PTR [rsp+0x10],r12
     926:	mov    QWORD PTR [rsp+0x18],r13
     92b:	mov    rsi,QWORD PTR [rsp+0x70]
     930:	mov    QWORD PTR [rsp+0x20],rsi
     935:	mov    QWORD PTR [rsp+0x28],rax
     93a:	mov    QWORD PTR [rsp+0x78],rax
     93f:	jmp    7bd <botlish_fn_3+0x75>
     944:	mov    r9,QWORD PTR [rsp+0x78]
     949:	lea    rcx,[rsp+0x40]
     94e:	mov    QWORD PTR [rsp+0x40],0x0
     957:	mov    QWORD PTR [rsp+0x48],r9
     95c:	mov    esi,0x1
     961:	mov    edx,0x2
     966:	mov    rdi,r15
     969:	call   96e <botlish_fn_3+0x226>
			96a: R_X86_64_PLT32	rt_construct-0x4
     96e:	test   rax,rax
     971:	jne    9ae <botlish_fn_3+0x266>
     977:	xor    rax,rax
     97a:	mov    rbx,QWORD PTR [rsp+0x90]
     982:	mov    r12,QWORD PTR [rsp+0x98]
     98a:	mov    r13,QWORD PTR [rsp+0xa0]
     992:	mov    r14,QWORD PTR [rsp+0xa8]
     99a:	mov    r15,QWORD PTR [rsp+0xb0]
     9a2:	add    rsp,0xc0
     9a9:	mov    rsp,rbp
     9ac:	pop    rbp
     9ad:	ret
     9ae:	mov    rbx,QWORD PTR [rsp+0x90]
     9b6:	mov    r12,QWORD PTR [rsp+0x98]
     9be:	mov    r13,QWORD PTR [rsp+0xa0]
     9c6:	mov    r14,QWORD PTR [rsp+0xa8]
     9ce:	mov    r15,QWORD PTR [rsp+0xb0]
     9d6:	add    rsp,0xc0
     9dd:	mov    rsp,rbp
     9e0:	pop    rbp
     9e1:	ret
     9e2:	add    BYTE PTR [rax],al
     9e4:	add    BYTE PTR [rax],al
     9e6:	add    BYTE PTR [rax],al
     9e8:	(bad)
     9e9:	add    BYTE PTR [rax],al
     9eb:	add    BYTE PTR [rax],al
     9ed:	add    BYTE PTR [rax],al
	...

00000000000009f0 <botlish_entry_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     9f0:	push   rbp
     9f1:	mov    rbp,rsp
     9f4:	mov    rsi,QWORD PTR [rdx]
     9f7:	mov    r10,QWORD PTR [rdx+0x8]
     9fb:	mov    rcx,QWORD PTR [rdx+0x10]
     9ff:	mov    r8,QWORD PTR [rdx+0x18]
     a03:	mov    r9,QWORD PTR [rdx+0x20]
     a07:	sar    r8,1
     a0a:	mov    rdx,r10
     a0d:	call   a12 <botlish_entry_3+0x22>
			a0e: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     a12:	mov    rsp,rbp
     a15:	pop    rbp
     a16:	ret

0000000000000a17 <botlish_fn_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     a17:	push   rbp
     a18:	mov    rbp,rsp
     a1b:	sub    rsp,0x90
     a22:	mov    QWORD PTR [rsp+0x60],rbx
     a27:	mov    QWORD PTR [rsp+0x68],r12
     a2c:	mov    QWORD PTR [rsp+0x70],r13
     a31:	mov    QWORD PTR [rsp+0x78],r14
     a36:	mov    QWORD PTR [rsp+0x80],r15
     a3e:	mov    rbx,rcx
     a41:	mov    r12,r8
     a44:	mov    r15,rdi
     a47:	mov    QWORD PTR [rsp+0x20],0x0
     a50:	mov    QWORD PTR [rsp],rsi
     a54:	mov    r14,rsi
     a57:	mov    QWORD PTR [rsp+0x8],rdx
     a5c:	mov    r13,rdx
     a5f:	mov    QWORD PTR [rsp+0x10],r9
     a64:	mov    QWORD PTR [rsp+0x48],r9
     a69:	mov    rsi,r14
     a6c:	mov    rdi,r15
     a6f:	call   a74 <botlish_fn_4+0x5d>
			a70: R_X86_64_PLT32	rt_list_len-0x4
     a74:	sar    rax,1
     a77:	cmp    rbx,rax
     a7a:	je     be7 <botlish_fn_4+0x1d0>
     a80:	mov    rsi,r14
     a83:	mov    rcx,QWORD PTR [rsi+0x8]
     a87:	mov    rax,rbx
     a8a:	shl    rax,1
     a8d:	or     rax,0x1
     a91:	sar    rax,1
     a94:	cmp    rax,rcx
     a97:	jb     ac3 <botlish_fn_4+0xac>
     a9d:	mov    rdx,rbx
     aa0:	shl    rdx,1
     aa3:	or     rdx,0x1
     aa7:	mov    rsi,r14
     aaa:	mov    rdi,r15
     aad:	call   ab2 <botlish_fn_4+0x9b>
			aae: R_X86_64_PLT32	rt_list_get-0x4
     ab2:	test   rax,rax
     ab5:	je     b94 <botlish_fn_4+0x17d>
     abb:	mov    rsi,rax
     abe:	jmp    ace <botlish_fn_4+0xb7>
     ac3:	mov    rsi,r14
     ac6:	mov    rcx,QWORD PTR [rsi+0x10]
     aca:	mov    rsi,QWORD PTR [rcx+rax*8]
     ace:	mov    QWORD PTR [rsp+0x18],rsi
     ad3:	mov    QWORD PTR [rsp+0x50],rsi
     ad8:	xor    rdx,rdx
     adb:	mov    rdi,r15
     ade:	mov    rsi,rdx
     ae1:	call   ae6 <botlish_fn_4+0xcf>
			ae2: R_X86_64_PLT32	rt_list_new-0x4
     ae6:	test   rax,rax
     ae9:	je     b94 <botlish_fn_4+0x17d>
     aef:	mov    QWORD PTR [rsp+0x20],rax
     af4:	mov    r9,rax
     af7:	xor    rcx,rcx
     afa:	mov    rsi,QWORD PTR [rsp+0x50]
     aff:	mov    rdx,r13
     b02:	mov    rdi,r15
     b05:	mov    r8,r12
     b08:	call   b0d <botlish_fn_4+0xf6>
			b09: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     b0d:	test   rax,rax
     b10:	je     b94 <botlish_fn_4+0x17d>
     b16:	mov    QWORD PTR [rsp+0x18],rax
     b1b:	lea    rcx,[rbx+0x1]
     b1f:	shl    rcx,1
     b22:	or     rcx,0x1
     b26:	mov    QWORD PTR [rsp+0x20],rcx
     b2b:	mov    rbx,rcx
     b2e:	lea    rcx,[rsp+0x28]
     b33:	mov    QWORD PTR [rsp+0x28],0x0
     b3c:	mov    r9,QWORD PTR [rsp+0x48]
     b41:	mov    QWORD PTR [rsp+0x30],r9
     b46:	mov    QWORD PTR [rsp+0x38],0x2
     b4f:	mov    QWORD PTR [rsp+0x40],rax
     b54:	mov    esi,0x3
     b59:	mov    edx,0x4
     b5e:	mov    rdi,r15
     b61:	call   b66 <botlish_fn_4+0x14f>
			b62: R_X86_64_PLT32	rt_construct-0x4
     b66:	test   rax,rax
     b69:	je     b94 <botlish_fn_4+0x17d>
     b6f:	mov    QWORD PTR [rsp+0x10],rax
     b74:	mov    rcx,rbx
     b77:	mov    rdx,r13
     b7a:	mov    rsi,r14
     b7d:	mov    rdi,r15
     b80:	mov    r8,r12
     b83:	mov    r9,rax
     b86:	call   b8b <botlish_fn_4+0x174>
			b87: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
     b8b:	test   rax,rax
     b8e:	jne    bbf <botlish_fn_4+0x1a8>
     b94:	xor    rax,rax
     b97:	mov    rbx,QWORD PTR [rsp+0x60]
     b9c:	mov    r12,QWORD PTR [rsp+0x68]
     ba1:	mov    r13,QWORD PTR [rsp+0x70]
     ba6:	mov    r14,QWORD PTR [rsp+0x78]
     bab:	mov    r15,QWORD PTR [rsp+0x80]
     bb3:	add    rsp,0x90
     bba:	mov    rsp,rbp
     bbd:	pop    rbp
     bbe:	ret
     bbf:	mov    rbx,QWORD PTR [rsp+0x60]
     bc4:	mov    r12,QWORD PTR [rsp+0x68]
     bc9:	mov    r13,QWORD PTR [rsp+0x70]
     bce:	mov    r14,QWORD PTR [rsp+0x78]
     bd3:	mov    r15,QWORD PTR [rsp+0x80]
     bdb:	add    rsp,0x90
     be2:	mov    rsp,rbp
     be5:	pop    rbp
     be6:	ret
     be7:	mov    rax,QWORD PTR [rsp+0x48]
     bec:	mov    rbx,QWORD PTR [rsp+0x60]
     bf1:	mov    r12,QWORD PTR [rsp+0x68]
     bf6:	mov    r13,QWORD PTR [rsp+0x70]
     bfb:	mov    r14,QWORD PTR [rsp+0x78]
     c00:	mov    r15,QWORD PTR [rsp+0x80]
     c08:	add    rsp,0x90
     c0f:	mov    rsp,rbp
     c12:	pop    rbp
     c13:	ret

0000000000000c14 <botlish_entry_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     c14:	push   rbp
     c15:	mov    rbp,rsp
     c18:	mov    rsi,QWORD PTR [rdx]
     c1b:	mov    r10,QWORD PTR [rdx+0x8]
     c1f:	mov    rcx,QWORD PTR [rdx+0x10]
     c23:	mov    r8,QWORD PTR [rdx+0x18]
     c27:	mov    r9,QWORD PTR [rdx+0x20]
     c2b:	sar    rcx,1
     c2e:	sar    r8,1
     c31:	mov    rdx,r10
     c34:	call   c39 <botlish_entry_4+0x25>
			c35: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
     c39:	mov    rsp,rbp
     c3c:	pop    rbp
     c3d:	ret
	...

0000000000000c40 <botlish_fn_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
     c40:	push   rbp
     c41:	mov    rbp,rsp
     c44:	sub    rsp,0xb0
     c4b:	mov    QWORD PTR [rsp+0x80],rbx
     c53:	mov    QWORD PTR [rsp+0x88],r12
     c5b:	mov    QWORD PTR [rsp+0x90],r13
     c63:	mov    QWORD PTR [rsp+0x98],r14
     c6b:	mov    QWORD PTR [rsp+0xa0],r15
     c73:	mov    r14,rdi
     c76:	mov    r15,r8
     c79:	mov    QWORD PTR [rsp+0x20],0x0
     c82:	mov    QWORD PTR [rsp+0x28],0x0
     c8b:	mov    QWORD PTR [rsp],rsi
     c8f:	mov    QWORD PTR [rsp+0x8],rdx
     c94:	mov    r12,rdx
     c97:	mov    QWORD PTR [rsp+0x10],rcx
     c9c:	mov    QWORD PTR [rsp+0x18],r9
     ca1:	mov    QWORD PTR [rsp+0x68],r9
     ca6:	lea    r13,[rsp+0x40]
     cab:	mov    rbx,rsi
     cae:	mov    QWORD PTR [rsp+0x60],rcx
     cb3:	mov    rsi,rbx
     cb6:	mov    rdi,r14
     cb9:	call   cbe <botlish_fn_5+0x7e>
			cba: R_X86_64_PLT32	rt_list_len-0x4
     cbe:	mov    rsi,QWORD PTR [rsp+0x60]
     cc3:	mov    rcx,rsi
     cc6:	and    rcx,rax
     cc9:	mov    rdx,rax
     ccc:	test   rcx,0x1
     cd3:	jne    cfb <botlish_fn_5+0xbb>
     cd9:	mov    rsi,QWORD PTR [rsp+0x60]
     cde:	mov    rdi,r14
     ce1:	call   ce6 <botlish_fn_5+0xa6>
			ce2: R_X86_64_PLT32	rt_int_cmp-0x4
     ce6:	mov    ecx,0x2
     ceb:	test   rax,rax
     cee:	cmove  rcx,QWORD PTR [rip+0x232]        # f28 <botlish_fn_5+0x2e8>
     cf6:	jmp    d10 <botlish_fn_5+0xd0>
     cfb:	mov    ecx,0x2
     d00:	mov    rsi,QWORD PTR [rsp+0x60]
     d05:	cmp    rsi,rdx
     d08:	cmove  rcx,QWORD PTR [rip+0x218]        # f28 <botlish_fn_5+0x2e8>
     d10:	cmp    rcx,0x6
     d14:	je     e83 <botlish_fn_5+0x243>
     d1a:	mov    rsi,QWORD PTR [rsp+0x60]
     d1f:	test   rsi,0x1
     d26:	je     d44 <botlish_fn_5+0x104>
     d2c:	mov    rcx,QWORD PTR [rbx+0x8]
     d30:	mov    rsi,QWORD PTR [rsp+0x60]
     d35:	mov    rax,rsi
     d38:	sar    rax,1
     d3b:	cmp    rax,rcx
     d3e:	jb     d65 <botlish_fn_5+0x125>
     d44:	mov    rdx,QWORD PTR [rsp+0x60]
     d49:	mov    rsi,rbx
     d4c:	mov    rdi,r14
     d4f:	call   d54 <botlish_fn_5+0x114>
			d50: R_X86_64_PLT32	rt_list_get-0x4
     d54:	test   rax,rax
     d57:	je     eb6 <botlish_fn_5+0x276>
     d5d:	mov    rsi,rax
     d60:	jmp    d6d <botlish_fn_5+0x12d>
     d65:	mov    rsi,QWORD PTR [rbx+0x10]
     d69:	mov    rsi,QWORD PTR [rsi+rax*8]
     d6d:	mov    QWORD PTR [rsp+0x20],rsi
     d72:	mov    QWORD PTR [rsp+0x70],rsi
     d77:	xor    rdx,rdx
     d7a:	mov    rdi,r14
     d7d:	mov    rsi,rdx
     d80:	call   d85 <botlish_fn_5+0x145>
			d81: R_X86_64_PLT32	rt_list_new-0x4
     d85:	test   rax,rax
     d88:	je     eb6 <botlish_fn_5+0x276>
     d8e:	mov    QWORD PTR [rsp+0x28],rax
     d93:	mov    r9,rax
     d96:	xor    rcx,rcx
     d99:	mov    rsi,QWORD PTR [rsp+0x70]
     d9e:	mov    rdx,r12
     da1:	mov    rdi,r14
     da4:	mov    r8,r15
     da7:	call   dac <botlish_fn_5+0x16c>
			da8: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     dac:	test   rax,rax
     daf:	je     eb6 <botlish_fn_5+0x276>
     db5:	mov    QWORD PTR [rsp+0x20],rax
     dba:	mov    QWORD PTR [rsp+0x70],rax
     dbf:	mov    QWORD PTR [rsp+0x28],0x3
     dc8:	mov    rsi,QWORD PTR [rsp+0x60]
     dcd:	test   rsi,0x1
     dd4:	je     dfe <botlish_fn_5+0x1be>
     dda:	mov    rsi,QWORD PTR [rsp+0x60]
     ddf:	mov    rcx,rsi
     de2:	add    rcx,0x2
     de6:	seto   al
     de9:	test   al,al
     deb:	jne    dfe <botlish_fn_5+0x1be>
     df1:	mov    rsi,rcx
     df4:	mov    QWORD PTR [rsp+0x60],rcx
     df9:	jmp    e18 <botlish_fn_5+0x1d8>
     dfe:	mov    edx,0x3
     e03:	mov    rsi,QWORD PTR [rsp+0x60]
     e08:	mov    rdi,r14
     e0b:	call   e10 <botlish_fn_5+0x1d0>
			e0c: R_X86_64_PLT32	rt_int_add-0x4
     e10:	mov    rsi,rax
     e13:	mov    QWORD PTR [rsp+0x60],rax
     e18:	mov    QWORD PTR [rsp+0x10],rsi
     e1d:	mov    QWORD PTR [rsp+0x40],0x0
     e26:	mov    r9,QWORD PTR [rsp+0x68]
     e2b:	mov    QWORD PTR [rsp+0x48],r9
     e30:	mov    QWORD PTR [rsp+0x50],0x2
     e39:	mov    rax,QWORD PTR [rsp+0x70]
     e3e:	mov    QWORD PTR [rsp+0x58],rax
     e43:	mov    esi,0x3
     e48:	mov    edx,0x4
     e4d:	mov    rcx,r13
     e50:	mov    rdi,r14
     e53:	call   e58 <botlish_fn_5+0x218>
			e54: R_X86_64_PLT32	rt_construct-0x4
     e58:	test   rax,rax
     e5b:	je     eb6 <botlish_fn_5+0x276>
     e61:	mov    QWORD PTR [rsp],rbx
     e65:	mov    QWORD PTR [rsp+0x8],r12
     e6a:	mov    rsi,QWORD PTR [rsp+0x60]
     e6f:	mov    QWORD PTR [rsp+0x10],rsi
     e74:	mov    QWORD PTR [rsp+0x18],rax
     e79:	mov    QWORD PTR [rsp+0x68],rax
     e7e:	jmp    cb3 <botlish_fn_5+0x73>
     e83:	mov    r9,QWORD PTR [rsp+0x68]
     e88:	lea    rcx,[rsp+0x30]
     e8d:	mov    QWORD PTR [rsp+0x30],0x0
     e96:	mov    QWORD PTR [rsp+0x38],r9
     e9b:	mov    esi,0x1
     ea0:	mov    edx,0x2
     ea5:	mov    rdi,r14
     ea8:	call   ead <botlish_fn_5+0x26d>
			ea9: R_X86_64_PLT32	rt_construct-0x4
     ead:	test   rax,rax
     eb0:	jne    eed <botlish_fn_5+0x2ad>
     eb6:	xor    rax,rax
     eb9:	mov    rbx,QWORD PTR [rsp+0x80]
     ec1:	mov    r12,QWORD PTR [rsp+0x88]
     ec9:	mov    r13,QWORD PTR [rsp+0x90]
     ed1:	mov    r14,QWORD PTR [rsp+0x98]
     ed9:	mov    r15,QWORD PTR [rsp+0xa0]
     ee1:	add    rsp,0xb0
     ee8:	mov    rsp,rbp
     eeb:	pop    rbp
     eec:	ret
     eed:	mov    rbx,QWORD PTR [rsp+0x80]
     ef5:	mov    r12,QWORD PTR [rsp+0x88]
     efd:	mov    r13,QWORD PTR [rsp+0x90]
     f05:	mov    r14,QWORD PTR [rsp+0x98]
     f0d:	mov    r15,QWORD PTR [rsp+0xa0]
     f15:	add    rsp,0xb0
     f1c:	mov    rsp,rbp
     f1f:	pop    rbp
     f20:	ret
     f21:	add    BYTE PTR [rax],al
     f23:	add    BYTE PTR [rax],al
     f25:	add    BYTE PTR [rax],al
     f27:	add    BYTE PTR [rsi],al
     f29:	add    BYTE PTR [rax],al
     f2b:	add    BYTE PTR [rax],al
     f2d:	add    BYTE PTR [rax],al
	...

0000000000000f30 <botlish_entry_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
     f30:	push   rbp
     f31:	mov    rbp,rsp
     f34:	mov    rsi,QWORD PTR [rdx]
     f37:	mov    r10,QWORD PTR [rdx+0x8]
     f3b:	mov    rcx,QWORD PTR [rdx+0x10]
     f3f:	mov    r8,QWORD PTR [rdx+0x18]
     f43:	mov    r9,QWORD PTR [rdx+0x20]
     f47:	sar    r8,1
     f4a:	mov    rdx,r10
     f4d:	call   f52 <botlish_entry_5+0x22>
			f4e: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
     f52:	mov    rsp,rbp
     f55:	pop    rbp
     f56:	ret

0000000000000f57 <botlish_fn_6: matmul<List[List[int]], List[List[int]]>>:
     f57:	push   rbp
     f58:	mov    rbp,rsp
     f5b:	sub    rsp,0x40
     f5f:	mov    QWORD PTR [rsp+0x20],rbx
     f64:	mov    QWORD PTR [rsp+0x28],r12
     f69:	mov    QWORD PTR [rsp+0x30],r13
     f6e:	mov    QWORD PTR [rsp+0x38],r14
     f73:	mov    r12,rdi
     f76:	mov    QWORD PTR [rsp+0x10],0x0
     f7f:	mov    QWORD PTR [rsp],rsi
     f83:	mov    r13,rsi
     f86:	mov    QWORD PTR [rsp+0x8],rdx
     f8b:	mov    rbx,rdx
     f8e:	mov    rsi,r13
     f91:	mov    rdi,r12
     f94:	call   f99 <botlish_fn_6+0x42>
			f95: R_X86_64_PLT32	rt_list_len-0x4
     f99:	sar    rax,1
     f9c:	test   rax,rax
     f9f:	je     1047 <botlish_fn_6+0xf0>
     fa5:	mov    rax,QWORD PTR [rbx+0x8]
     fa9:	test   rax,rax
     fac:	jne    fd3 <botlish_fn_6+0x7c>
     fb2:	mov    edx,0x1
     fb7:	mov    rsi,rbx
     fba:	mov    rdi,r12
     fbd:	call   fc2 <botlish_fn_6+0x6b>
			fbe: R_X86_64_PLT32	rt_list_get-0x4
     fc2:	test   rax,rax
     fc5:	je     105e <botlish_fn_6+0x107>
     fcb:	mov    rsi,rax
     fce:	jmp    fdd <botlish_fn_6+0x86>
     fd3:	mov    rdx,rbx
     fd6:	mov    rax,QWORD PTR [rdx+0x10]
     fda:	mov    rsi,QWORD PTR [rax]
     fdd:	mov    rdi,r12
     fe0:	call   fe5 <botlish_fn_6+0x8e>
			fe1: R_X86_64_PLT32	rt_list_len-0x4
     fe5:	mov    r14,rax
     fe8:	xor    rdx,rdx
     feb:	mov    rdi,r12
     fee:	mov    rsi,rdx
     ff1:	call   ff6 <botlish_fn_6+0x9f>
			ff2: R_X86_64_PLT32	rt_list_new-0x4
     ff6:	test   rax,rax
     ff9:	je     105e <botlish_fn_6+0x107>
     fff:	mov    QWORD PTR [rsp+0x10],rax
    1004:	mov    r9,rax
    1007:	xor    rcx,rcx
    100a:	mov    rax,r14
    100d:	mov    r8,rax
    1010:	sar    r8,1
    1013:	mov    rdx,rbx
    1016:	mov    rsi,r13
    1019:	mov    rdi,r12
    101c:	call   1021 <botlish_fn_6+0xca>
			101d: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
    1021:	test   rax,rax
    1024:	je     105e <botlish_fn_6+0x107>
    102a:	mov    rbx,QWORD PTR [rsp+0x20]
    102f:	mov    r12,QWORD PTR [rsp+0x28]
    1034:	mov    r13,QWORD PTR [rsp+0x30]
    1039:	mov    r14,QWORD PTR [rsp+0x38]
    103e:	add    rsp,0x40
    1042:	mov    rsp,rbp
    1045:	pop    rbp
    1046:	ret
    1047:	xor    rdx,rdx
    104a:	mov    rdi,r12
    104d:	mov    rsi,rdx
    1050:	call   1055 <botlish_fn_6+0xfe>
			1051: R_X86_64_PLT32	rt_list_new-0x4
    1055:	test   rax,rax
    1058:	jne    107e <botlish_fn_6+0x127>
    105e:	xor    rax,rax
    1061:	mov    rbx,QWORD PTR [rsp+0x20]
    1066:	mov    r12,QWORD PTR [rsp+0x28]
    106b:	mov    r13,QWORD PTR [rsp+0x30]
    1070:	mov    r14,QWORD PTR [rsp+0x38]
    1075:	add    rsp,0x40
    1079:	mov    rsp,rbp
    107c:	pop    rbp
    107d:	ret
    107e:	mov    rbx,QWORD PTR [rsp+0x20]
    1083:	mov    r12,QWORD PTR [rsp+0x28]
    1088:	mov    r13,QWORD PTR [rsp+0x30]
    108d:	mov    r14,QWORD PTR [rsp+0x38]
    1092:	add    rsp,0x40
    1096:	mov    rsp,rbp
    1099:	pop    rbp
    109a:	ret

000000000000109b <botlish_entry_6: matmul<List[List[int]], List[List[int]]>>:
    109b:	push   rbp
    109c:	mov    rbp,rsp
    109f:	mov    rsi,QWORD PTR [rdx]
    10a2:	mov    rdx,QWORD PTR [rdx+0x8]
    10a6:	call   10ab <botlish_entry_6+0x10>
			10a7: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<List[List[int]], List[List[int]]>
    10ab:	mov    rsp,rbp
    10ae:	pop    rbp
    10af:	ret

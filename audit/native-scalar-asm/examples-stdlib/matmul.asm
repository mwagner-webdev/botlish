; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4734  (per function: 750 703 556 812 613 892 408)
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
     2e4:	mov    rdi,QWORD PTR [rbp+0x10]
     2e8:	mov    QWORD PTR [rsp],rsi
     2ec:	mov    r10,rsi
     2ef:	mov    QWORD PTR [rsp+0x8],rdx
     2f4:	mov    r13,rdx
     2f7:	mov    QWORD PTR [rsp+0x10],rcx
     2fc:	mov    QWORD PTR [rsp+0x18],rdi
     301:	sar    r8,1
     304:	sar    r9,1
     307:	mov    QWORD PTR [rsp+0x48],r9
     30c:	mov    rbx,rcx
     30f:	sar    rbx,1
     312:	mov    r14,rcx
     315:	mov    rsi,QWORD PTR [rsp+0x48]
     31a:	mov    r12,r8
     31d:	mov    QWORD PTR [rsp+0x38],rdi
     322:	cmp    r12,rsi
     325:	mov    QWORD PTR [rsp+0x48],rsi
     32a:	je     4f8 <botlish_fn_1+0x23d>
     330:	mov    r15,r10
     333:	mov    rsi,QWORD PTR [r15+0x8]
     337:	mov    rcx,r12
     33a:	shl    rcx,1
     33d:	or     rcx,0x1
     341:	sar    rcx,1
     344:	cmp    rcx,rsi
     347:	jb     375 <botlish_fn_1+0xba>
     34d:	mov    rdx,r12
     350:	shl    rdx,1
     353:	or     rdx,0x1
     357:	mov    rsi,r15
     35a:	mov    rdi,QWORD PTR [rsp+0x30]
     35f:	call   364 <botlish_fn_1+0xa9>
			360: R_X86_64_PLT32	rt_list_get-0x4
     364:	test   rax,rax
     367:	je     401 <botlish_fn_1+0x146>
     36d:	mov    rsi,rax
     370:	jmp    37d <botlish_fn_1+0xc2>
     375:	mov    r9,QWORD PTR [r15+0x10]
     379:	mov    rsi,QWORD PTR [r9+rcx*8]
     37d:	mov    QWORD PTR [rsp+0x20],rsi
     382:	mov    QWORD PTR [rsp+0x40],rsi
     387:	mov    rax,QWORD PTR [r13+0x8]
     38b:	mov    r10,r12
     38e:	shl    r10,1
     391:	or     r10,0x1
     395:	sar    r10,1
     398:	cmp    r10,rax
     39b:	jb     3c9 <botlish_fn_1+0x10e>
     3a1:	mov    rdx,r12
     3a4:	shl    rdx,1
     3a7:	or     rdx,0x1
     3ab:	mov    rsi,r13
     3ae:	mov    rdi,QWORD PTR [rsp+0x30]
     3b3:	call   3b8 <botlish_fn_1+0xfd>
			3b4: R_X86_64_PLT32	rt_list_get-0x4
     3b8:	test   rax,rax
     3bb:	je     401 <botlish_fn_1+0x146>
     3c1:	mov    rsi,rax
     3c4:	jmp    3d1 <botlish_fn_1+0x116>
     3c9:	mov    rax,QWORD PTR [r13+0x10]
     3cd:	mov    rsi,QWORD PTR [rax+r10*8]
     3d1:	test   r14,0x1
     3d8:	je     3eb <botlish_fn_1+0x130>
     3de:	mov    rax,QWORD PTR [rsi+0x8]
     3e2:	cmp    rbx,rax
     3e5:	jb     431 <botlish_fn_1+0x176>
     3eb:	mov    rdx,r14
     3ee:	mov    rdi,QWORD PTR [rsp+0x30]
     3f3:	call   3f8 <botlish_fn_1+0x13d>
			3f4: R_X86_64_PLT32	rt_list_get-0x4
     3f8:	test   rax,rax
     3fb:	jne    429 <botlish_fn_1+0x16e>
     401:	xor    rax,rax
     404:	mov    rbx,QWORD PTR [rsp+0x50]
     409:	mov    r12,QWORD PTR [rsp+0x58]
     40e:	mov    r13,QWORD PTR [rsp+0x60]
     413:	mov    r14,QWORD PTR [rsp+0x68]
     418:	mov    r15,QWORD PTR [rsp+0x70]
     41d:	add    rsp,0x80
     424:	mov    rsp,rbp
     427:	pop    rbp
     428:	ret
     429:	mov    rdx,rax
     42c:	jmp    439 <botlish_fn_1+0x17e>
     431:	mov    rax,QWORD PTR [rsi+0x10]
     435:	mov    rdx,QWORD PTR [rax+rbx*8]
     439:	mov    QWORD PTR [rsp+0x28],rdx
     43e:	mov    rsi,QWORD PTR [rsp+0x40]
     443:	mov    rax,rsi
     446:	and    rax,rdx
     449:	test   rax,0x1
     44f:	je     484 <botlish_fn_1+0x1c9>
     455:	mov    rax,rsi
     458:	sar    rax,1
     45b:	lea    rcx,[rdx-0x1]
     45f:	mov    rdi,rdx
     462:	imul   rcx
     465:	seto   cl
     468:	or     rax,0x1
     46c:	test   cl,cl
     46e:	je     47c <botlish_fn_1+0x1c1>
     474:	mov    rdx,rdi
     477:	jmp    484 <botlish_fn_1+0x1c9>
     47c:	mov    rdx,rax
     47f:	jmp    491 <botlish_fn_1+0x1d6>
     484:	mov    rdi,QWORD PTR [rsp+0x30]
     489:	call   48e <botlish_fn_1+0x1d3>
			48a: R_X86_64_PLT32	rt_int_mul-0x4
     48e:	mov    rdx,rax
     491:	mov    QWORD PTR [rsp+0x20],rdx
     496:	mov    rsi,QWORD PTR [rsp+0x38]
     49b:	mov    rax,rsi
     49e:	and    rax,rdx
     4a1:	test   rax,0x1
     4a7:	je     4c2 <botlish_fn_1+0x207>
     4ad:	lea    rcx,[rdx-0x1]
     4b1:	mov    rax,rsi
     4b4:	add    rax,rcx
     4b7:	seto   cl
     4ba:	test   cl,cl
     4bc:	je     4cc <botlish_fn_1+0x211>
     4c2:	mov    rdi,QWORD PTR [rsp+0x30]
     4c7:	call   4cc <botlish_fn_1+0x211>
			4c8: R_X86_64_PLT32	rt_int_add-0x4
     4cc:	mov    QWORD PTR [rsp],r15
     4d0:	mov    QWORD PTR [rsp+0x8],r13
     4d5:	mov    QWORD PTR [rsp+0x10],r14
     4da:	mov    QWORD PTR [rsp+0x18],rax
     4df:	add    r12,0x1
     4e6:	mov    rsi,QWORD PTR [rsp+0x48]
     4eb:	mov    r10,r15
     4ee:	mov    QWORD PTR [rsp+0x38],rax
     4f3:	jmp    322 <botlish_fn_1+0x67>
     4f8:	mov    rax,QWORD PTR [rsp+0x38]
     4fd:	mov    rbx,QWORD PTR [rsp+0x50]
     502:	mov    r12,QWORD PTR [rsp+0x58]
     507:	mov    r13,QWORD PTR [rsp+0x60]
     50c:	mov    r14,QWORD PTR [rsp+0x68]
     511:	mov    r15,QWORD PTR [rsp+0x70]
     516:	add    rsp,0x80
     51d:	mov    rsp,rbp
     520:	pop    rbp
     521:	ret

0000000000000522 <botlish_entry_1: dot<List[int], List[List[int]], int, int, int, int>>:
     522:	push   rbp
     523:	mov    rbp,rsp
     526:	sub    rsp,0x10
     52a:	mov    rsi,QWORD PTR [rdx]
     52d:	mov    r10,QWORD PTR [rdx+0x8]
     531:	mov    rcx,QWORD PTR [rdx+0x10]
     535:	mov    r8,QWORD PTR [rdx+0x18]
     539:	mov    r9,QWORD PTR [rdx+0x20]
     53d:	mov    r11,QWORD PTR [rdx+0x28]
     541:	mov    QWORD PTR [rsp],r11
     545:	mov    rdx,r10
     548:	call   54d <botlish_entry_1+0x2b>
			549: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     54d:	add    rsp,0x10
     551:	mov    rsp,rbp
     554:	pop    rbp
     555:	ret

0000000000000556 <botlish_fn_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     556:	push   rbp
     557:	mov    rbp,rsp
     55a:	sub    rsp,0xc0
     561:	mov    QWORD PTR [rsp+0x90],rbx
     569:	mov    QWORD PTR [rsp+0x98],r12
     571:	mov    QWORD PTR [rsp+0xa0],r13
     579:	mov    QWORD PTR [rsp+0xa8],r14
     581:	mov    QWORD PTR [rsp+0xb0],r15
     589:	mov    QWORD PTR [rsp+0x70],rdi
     58e:	mov    QWORD PTR [rsp+0x10],rsi
     593:	mov    r15,rsi
     596:	mov    QWORD PTR [rsp+0x18],rdx
     59b:	mov    r14,rdx
     59e:	mov    QWORD PTR [rsp+0x20],rcx
     5a3:	mov    QWORD PTR [rsp+0x28],r8
     5a8:	mov    QWORD PTR [rsp+0x30],r9
     5ad:	mov    QWORD PTR [rsp+0x80],r9
     5b5:	mov    rbx,rcx
     5b8:	sar    rbx,1
     5bb:	mov    QWORD PTR [rsp+0x78],rcx
     5c0:	mov    rax,r8
     5c3:	sar    rax,1
     5c6:	mov    r13,r8
     5c9:	cmp    rbx,rax
     5cc:	je     714 <botlish_fn_2+0x1be>
     5d2:	mov    r12d,0x1
     5d8:	mov    QWORD PTR [rsp+0x38],0x1
     5e1:	mov    rsi,r15
     5e4:	mov    rdi,QWORD PTR [rsp+0x70]
     5e9:	call   5ee <botlish_fn_2+0x98>
			5ea: R_X86_64_PLT32	rt_list_len-0x4
     5ee:	mov    QWORD PTR [rsp+0x40],rax
     5f3:	mov    QWORD PTR [rsp+0x48],0x1
     5fc:	mov    QWORD PTR [rsp],r12
     600:	mov    rcx,QWORD PTR [rsp+0x78]
     605:	mov    r8,r12
     608:	mov    r9,rax
     60b:	mov    rdx,r14
     60e:	mov    rsi,r15
     611:	mov    rdi,QWORD PTR [rsp+0x70]
     616:	call   61b <botlish_fn_2+0xc5>
			617: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     61b:	test   rax,rax
     61e:	je     6a9 <botlish_fn_2+0x153>
     624:	mov    QWORD PTR [rsp+0x20],rax
     629:	lea    rcx,[rbx+0x1]
     62d:	shl    rcx,1
     630:	or     rcx,0x1
     634:	mov    QWORD PTR [rsp+0x38],rcx
     639:	mov    rbx,rcx
     63c:	lea    rcx,[rsp+0x50]
     641:	mov    QWORD PTR [rsp+0x50],0x0
     64a:	mov    r9,QWORD PTR [rsp+0x80]
     652:	mov    QWORD PTR [rsp+0x58],r9
     657:	mov    QWORD PTR [rsp+0x60],0x2
     660:	mov    QWORD PTR [rsp+0x68],rax
     665:	mov    esi,0x3
     66a:	mov    edx,0x4
     66f:	mov    rdi,QWORD PTR [rsp+0x70]
     674:	call   679 <botlish_fn_2+0x123>
			675: R_X86_64_PLT32	rt_construct-0x4
     679:	test   rax,rax
     67c:	je     6a9 <botlish_fn_2+0x153>
     682:	mov    QWORD PTR [rsp+0x20],rax
     687:	mov    rcx,rbx
     68a:	mov    rdx,r14
     68d:	mov    rsi,r15
     690:	mov    rdi,QWORD PTR [rsp+0x70]
     695:	mov    r8,r13
     698:	mov    r9,rax
     69b:	call   6a0 <botlish_fn_2+0x14a>
			69c: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     6a0:	test   rax,rax
     6a3:	jne    6e0 <botlish_fn_2+0x18a>
     6a9:	xor    rax,rax
     6ac:	mov    rbx,QWORD PTR [rsp+0x90]
     6b4:	mov    r12,QWORD PTR [rsp+0x98]
     6bc:	mov    r13,QWORD PTR [rsp+0xa0]
     6c4:	mov    r14,QWORD PTR [rsp+0xa8]
     6cc:	mov    r15,QWORD PTR [rsp+0xb0]
     6d4:	add    rsp,0xc0
     6db:	mov    rsp,rbp
     6de:	pop    rbp
     6df:	ret
     6e0:	mov    rbx,QWORD PTR [rsp+0x90]
     6e8:	mov    r12,QWORD PTR [rsp+0x98]
     6f0:	mov    r13,QWORD PTR [rsp+0xa0]
     6f8:	mov    r14,QWORD PTR [rsp+0xa8]
     700:	mov    r15,QWORD PTR [rsp+0xb0]
     708:	add    rsp,0xc0
     70f:	mov    rsp,rbp
     712:	pop    rbp
     713:	ret
     714:	mov    rax,QWORD PTR [rsp+0x80]
     71c:	mov    rbx,QWORD PTR [rsp+0x90]
     724:	mov    r12,QWORD PTR [rsp+0x98]
     72c:	mov    r13,QWORD PTR [rsp+0xa0]
     734:	mov    r14,QWORD PTR [rsp+0xa8]
     73c:	mov    r15,QWORD PTR [rsp+0xb0]
     744:	add    rsp,0xc0
     74b:	mov    rsp,rbp
     74e:	pop    rbp
     74f:	ret

0000000000000750 <botlish_entry_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     750:	push   rbp
     751:	mov    rbp,rsp
     754:	mov    rsi,QWORD PTR [rdx]
     757:	mov    r10,QWORD PTR [rdx+0x8]
     75b:	mov    rcx,QWORD PTR [rdx+0x10]
     75f:	mov    r8,QWORD PTR [rdx+0x18]
     763:	mov    r9,QWORD PTR [rdx+0x20]
     767:	mov    rdx,r10
     76a:	call   76f <botlish_entry_2+0x1f>
			76b: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     76f:	mov    rsp,rbp
     772:	pop    rbp
     773:	ret
     774:	add    BYTE PTR [rax],al
	...

0000000000000778 <botlish_fn_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     778:	push   rbp
     779:	mov    rbp,rsp
     77c:	sub    rsp,0xd0
     783:	mov    QWORD PTR [rsp+0xa0],rbx
     78b:	mov    QWORD PTR [rsp+0xa8],r12
     793:	mov    QWORD PTR [rsp+0xb0],r13
     79b:	mov    QWORD PTR [rsp+0xb8],r14
     7a3:	mov    QWORD PTR [rsp+0xc0],r15
     7ab:	mov    r15,rdi
     7ae:	mov    QWORD PTR [rsp+0x30],0x0
     7b7:	mov    QWORD PTR [rsp+0x38],0x0
     7c0:	mov    QWORD PTR [rsp+0x40],0x0
     7c9:	mov    QWORD PTR [rsp+0x10],rsi
     7ce:	mov    r12,rsi
     7d1:	mov    QWORD PTR [rsp+0x18],rdx
     7d6:	mov    QWORD PTR [rsp+0x78],rdx
     7db:	mov    QWORD PTR [rsp+0x20],rcx
     7e0:	mov    QWORD PTR [rsp+0x28],r9
     7e5:	mov    QWORD PTR [rsp+0x88],r9
     7ed:	lea    r14,[rsp+0x58]
     7f2:	mov    rbx,r8
     7f5:	mov    rsi,rcx
     7f8:	mov    rax,rbx
     7fb:	or     rax,0x1
     7ff:	mov    rcx,rsi
     802:	and    rcx,rax
     805:	mov    QWORD PTR [rsp+0x80],rsi
     80d:	test   rcx,0x1
     814:	jne    846 <botlish_fn_3+0xce>
     81a:	mov    rdx,rbx
     81d:	or     rdx,0x1
     821:	mov    rsi,QWORD PTR [rsp+0x80]
     829:	mov    rdi,r15
     82c:	call   831 <botlish_fn_3+0xb9>
			82d: R_X86_64_PLT32	rt_int_cmp-0x4
     831:	mov    ecx,0x2
     836:	test   rax,rax
     839:	cmove  rcx,QWORD PTR [rip+0x21f]        # a60 <botlish_fn_3+0x2e8>
     841:	jmp    865 <botlish_fn_3+0xed>
     846:	mov    rax,rbx
     849:	or     rax,0x1
     84d:	mov    ecx,0x2
     852:	mov    rsi,QWORD PTR [rsp+0x80]
     85a:	cmp    rsi,rax
     85d:	cmove  rcx,QWORD PTR [rip+0x1fb]        # a60 <botlish_fn_3+0x2e8>
     865:	cmp    rcx,0x6
     869:	je     9b9 <botlish_fn_3+0x241>
     86f:	mov    r13d,0x1
     875:	mov    QWORD PTR [rsp+0x30],0x1
     87e:	mov    rsi,r12
     881:	mov    rdi,r15
     884:	call   889 <botlish_fn_3+0x111>
			885: R_X86_64_PLT32	rt_list_len-0x4
     889:	mov    QWORD PTR [rsp+0x38],rax
     88e:	mov    QWORD PTR [rsp+0x40],0x1
     897:	mov    QWORD PTR [rsp],r13
     89b:	mov    r9,rax
     89e:	mov    r8,r13
     8a1:	mov    r13,QWORD PTR [rsp+0x78]
     8a6:	mov    rcx,QWORD PTR [rsp+0x80]
     8ae:	mov    rdx,r13
     8b1:	mov    rsi,r12
     8b4:	mov    rdi,r15
     8b7:	call   8bc <botlish_fn_3+0x144>
			8b8: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     8bc:	test   rax,rax
     8bf:	je     9ef <botlish_fn_3+0x277>
     8c5:	mov    QWORD PTR [rsp+0x30],rax
     8ca:	mov    QWORD PTR [rsp+0x90],rax
     8d2:	mov    QWORD PTR [rsp+0x38],0x3
     8db:	mov    rsi,QWORD PTR [rsp+0x80]
     8e3:	test   rsi,0x1
     8ea:	je     91c <botlish_fn_3+0x1a4>
     8f0:	mov    rsi,QWORD PTR [rsp+0x80]
     8f8:	mov    rcx,rsi
     8fb:	add    rcx,0x2
     8ff:	seto   sil
     903:	test   sil,sil
     906:	jne    91c <botlish_fn_3+0x1a4>
     90c:	mov    rsi,rcx
     90f:	mov    QWORD PTR [rsp+0x80],rcx
     917:	jmp    93c <botlish_fn_3+0x1c4>
     91c:	mov    edx,0x3
     921:	mov    rsi,QWORD PTR [rsp+0x80]
     929:	mov    rdi,r15
     92c:	call   931 <botlish_fn_3+0x1b9>
			92d: R_X86_64_PLT32	rt_int_add-0x4
     931:	mov    rsi,rax
     934:	mov    QWORD PTR [rsp+0x80],rax
     93c:	mov    QWORD PTR [rsp+0x20],rsi
     941:	mov    QWORD PTR [rsp+0x58],0x0
     94a:	mov    r9,QWORD PTR [rsp+0x88]
     952:	mov    QWORD PTR [rsp+0x60],r9
     957:	mov    QWORD PTR [rsp+0x68],0x2
     960:	mov    rax,QWORD PTR [rsp+0x90]
     968:	mov    QWORD PTR [rsp+0x70],rax
     96d:	mov    esi,0x3
     972:	mov    edx,0x4
     977:	mov    rcx,r14
     97a:	mov    rdi,r15
     97d:	call   982 <botlish_fn_3+0x20a>
			97e: R_X86_64_PLT32	rt_construct-0x4
     982:	test   rax,rax
     985:	je     9ef <botlish_fn_3+0x277>
     98b:	mov    QWORD PTR [rsp+0x10],r12
     990:	mov    QWORD PTR [rsp+0x18],r13
     995:	mov    rsi,QWORD PTR [rsp+0x80]
     99d:	mov    QWORD PTR [rsp+0x20],rsi
     9a2:	mov    QWORD PTR [rsp+0x28],rax
     9a7:	mov    QWORD PTR [rsp+0x78],r13
     9ac:	mov    QWORD PTR [rsp+0x88],rax
     9b4:	jmp    7f8 <botlish_fn_3+0x80>
     9b9:	mov    r9,QWORD PTR [rsp+0x88]
     9c1:	lea    rcx,[rsp+0x48]
     9c6:	mov    QWORD PTR [rsp+0x48],0x0
     9cf:	mov    QWORD PTR [rsp+0x50],r9
     9d4:	mov    esi,0x1
     9d9:	mov    edx,0x2
     9de:	mov    rdi,r15
     9e1:	call   9e6 <botlish_fn_3+0x26e>
			9e2: R_X86_64_PLT32	rt_construct-0x4
     9e6:	test   rax,rax
     9e9:	jne    a26 <botlish_fn_3+0x2ae>
     9ef:	xor    rax,rax
     9f2:	mov    rbx,QWORD PTR [rsp+0xa0]
     9fa:	mov    r12,QWORD PTR [rsp+0xa8]
     a02:	mov    r13,QWORD PTR [rsp+0xb0]
     a0a:	mov    r14,QWORD PTR [rsp+0xb8]
     a12:	mov    r15,QWORD PTR [rsp+0xc0]
     a1a:	add    rsp,0xd0
     a21:	mov    rsp,rbp
     a24:	pop    rbp
     a25:	ret
     a26:	mov    rbx,QWORD PTR [rsp+0xa0]
     a2e:	mov    r12,QWORD PTR [rsp+0xa8]
     a36:	mov    r13,QWORD PTR [rsp+0xb0]
     a3e:	mov    r14,QWORD PTR [rsp+0xb8]
     a46:	mov    r15,QWORD PTR [rsp+0xc0]
     a4e:	add    rsp,0xd0
     a55:	mov    rsp,rbp
     a58:	pop    rbp
     a59:	ret
     a5a:	add    BYTE PTR [rax],al
     a5c:	add    BYTE PTR [rax],al
     a5e:	add    BYTE PTR [rax],al
     a60:	(bad)
     a61:	add    BYTE PTR [rax],al
     a63:	add    BYTE PTR [rax],al
     a65:	add    BYTE PTR [rax],al
	...

0000000000000a68 <botlish_entry_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     a68:	push   rbp
     a69:	mov    rbp,rsp
     a6c:	mov    rsi,QWORD PTR [rdx]
     a6f:	mov    r10,QWORD PTR [rdx+0x8]
     a73:	mov    rcx,QWORD PTR [rdx+0x10]
     a77:	mov    r8,QWORD PTR [rdx+0x18]
     a7b:	mov    r9,QWORD PTR [rdx+0x20]
     a7f:	mov    rdx,r10
     a82:	call   a87 <botlish_entry_3+0x1f>
			a83: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     a87:	mov    rsp,rbp
     a8a:	pop    rbp
     a8b:	ret

0000000000000a8c <botlish_fn_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     a8c:	push   rbp
     a8d:	mov    rbp,rsp
     a90:	sub    rsp,0xa0
     a97:	mov    QWORD PTR [rsp+0x70],rbx
     a9c:	mov    QWORD PTR [rsp+0x78],r12
     aa1:	mov    QWORD PTR [rsp+0x80],r13
     aa9:	mov    QWORD PTR [rsp+0x88],r14
     ab1:	mov    QWORD PTR [rsp+0x90],r15
     ab9:	mov    rbx,rcx
     abc:	mov    r15,rdi
     abf:	mov    QWORD PTR [rsp+0x30],0x0
     ac8:	mov    QWORD PTR [rsp],rsi
     acc:	mov    r14,rsi
     acf:	mov    QWORD PTR [rsp+0x8],rdx
     ad4:	mov    r13,rdx
     ad7:	mov    QWORD PTR [rsp+0x10],r8
     adc:	mov    r12,r8
     adf:	mov    QWORD PTR [rsp+0x18],r9
     ae4:	mov    QWORD PTR [rsp+0x58],r9
     ae9:	mov    rsi,r14
     aec:	mov    rdi,r15
     aef:	call   af4 <botlish_fn_4+0x68>
			af0: R_X86_64_PLT32	rt_list_len-0x4
     af4:	mov    rcx,rbx
     af7:	sar    rbx,1
     afa:	sar    rax,1
     afd:	cmp    rbx,rax
     b00:	je     c85 <botlish_fn_4+0x1f9>
     b06:	test   rcx,0x1
     b0d:	jne    b1b <botlish_fn_4+0x8f>
     b13:	mov    rdx,rcx
     b16:	jmp    b2e <botlish_fn_4+0xa2>
     b1b:	mov    rsi,r14
     b1e:	mov    rax,QWORD PTR [rsi+0x8]
     b22:	cmp    rbx,rax
     b25:	jb     b4a <botlish_fn_4+0xbe>
     b2b:	mov    rdx,rcx
     b2e:	mov    rsi,r14
     b31:	mov    rdi,r15
     b34:	call   b39 <botlish_fn_4+0xad>
			b35: R_X86_64_PLT32	rt_list_get-0x4
     b39:	test   rax,rax
     b3c:	je     c26 <botlish_fn_4+0x19a>
     b42:	mov    rsi,rax
     b45:	jmp    b55 <botlish_fn_4+0xc9>
     b4a:	mov    rsi,r14
     b4d:	mov    rax,QWORD PTR [rsi+0x10]
     b51:	mov    rsi,QWORD PTR [rax+rbx*8]
     b55:	mov    QWORD PTR [rsp+0x20],rsi
     b5a:	mov    QWORD PTR [rsp+0x60],rsi
     b5f:	mov    QWORD PTR [rsp+0x28],0x1
     b68:	xor    rdx,rdx
     b6b:	mov    rdi,r15
     b6e:	mov    rsi,rdx
     b71:	call   b76 <botlish_fn_4+0xea>
			b72: R_X86_64_PLT32	rt_list_new-0x4
     b76:	test   rax,rax
     b79:	je     c26 <botlish_fn_4+0x19a>
     b7f:	mov    QWORD PTR [rsp+0x30],rax
     b84:	mov    r9,rax
     b87:	mov    ecx,0x1
     b8c:	mov    rsi,QWORD PTR [rsp+0x60]
     b91:	mov    rdx,r13
     b94:	mov    rdi,r15
     b97:	mov    r8,r12
     b9a:	call   b9f <botlish_fn_4+0x113>
			b9b: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     b9f:	test   rax,rax
     ba2:	je     c26 <botlish_fn_4+0x19a>
     ba8:	mov    QWORD PTR [rsp+0x20],rax
     bad:	lea    rcx,[rbx+0x1]
     bb1:	shl    rcx,1
     bb4:	or     rcx,0x1
     bb8:	mov    QWORD PTR [rsp+0x28],rcx
     bbd:	mov    rbx,rcx
     bc0:	lea    rcx,[rsp+0x38]
     bc5:	mov    QWORD PTR [rsp+0x38],0x0
     bce:	mov    r9,QWORD PTR [rsp+0x58]
     bd3:	mov    QWORD PTR [rsp+0x40],r9
     bd8:	mov    QWORD PTR [rsp+0x48],0x2
     be1:	mov    QWORD PTR [rsp+0x50],rax
     be6:	mov    esi,0x3
     beb:	mov    edx,0x4
     bf0:	mov    rdi,r15
     bf3:	call   bf8 <botlish_fn_4+0x16c>
			bf4: R_X86_64_PLT32	rt_construct-0x4
     bf8:	test   rax,rax
     bfb:	je     c26 <botlish_fn_4+0x19a>
     c01:	mov    QWORD PTR [rsp+0x18],rax
     c06:	mov    rcx,rbx
     c09:	mov    rdx,r13
     c0c:	mov    rsi,r14
     c0f:	mov    rdi,r15
     c12:	mov    r8,r12
     c15:	mov    r9,rax
     c18:	call   c1d <botlish_fn_4+0x191>
			c19: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
     c1d:	test   rax,rax
     c20:	jne    c57 <botlish_fn_4+0x1cb>
     c26:	xor    rax,rax
     c29:	mov    rbx,QWORD PTR [rsp+0x70]
     c2e:	mov    r12,QWORD PTR [rsp+0x78]
     c33:	mov    r13,QWORD PTR [rsp+0x80]
     c3b:	mov    r14,QWORD PTR [rsp+0x88]
     c43:	mov    r15,QWORD PTR [rsp+0x90]
     c4b:	add    rsp,0xa0
     c52:	mov    rsp,rbp
     c55:	pop    rbp
     c56:	ret
     c57:	mov    rbx,QWORD PTR [rsp+0x70]
     c5c:	mov    r12,QWORD PTR [rsp+0x78]
     c61:	mov    r13,QWORD PTR [rsp+0x80]
     c69:	mov    r14,QWORD PTR [rsp+0x88]
     c71:	mov    r15,QWORD PTR [rsp+0x90]
     c79:	add    rsp,0xa0
     c80:	mov    rsp,rbp
     c83:	pop    rbp
     c84:	ret
     c85:	mov    rax,QWORD PTR [rsp+0x58]
     c8a:	mov    rbx,QWORD PTR [rsp+0x70]
     c8f:	mov    r12,QWORD PTR [rsp+0x78]
     c94:	mov    r13,QWORD PTR [rsp+0x80]
     c9c:	mov    r14,QWORD PTR [rsp+0x88]
     ca4:	mov    r15,QWORD PTR [rsp+0x90]
     cac:	add    rsp,0xa0
     cb3:	mov    rsp,rbp
     cb6:	pop    rbp
     cb7:	ret

0000000000000cb8 <botlish_entry_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     cb8:	push   rbp
     cb9:	mov    rbp,rsp
     cbc:	mov    rsi,QWORD PTR [rdx]
     cbf:	mov    r10,QWORD PTR [rdx+0x8]
     cc3:	mov    rcx,QWORD PTR [rdx+0x10]
     cc7:	mov    r8,QWORD PTR [rdx+0x18]
     ccb:	mov    r9,QWORD PTR [rdx+0x20]
     ccf:	mov    rdx,r10
     cd2:	call   cd7 <botlish_entry_4+0x1f>
			cd3: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
     cd7:	mov    rsp,rbp
     cda:	pop    rbp
     cdb:	ret
     cdc:	add    BYTE PTR [rax],al
	...

0000000000000ce0 <botlish_fn_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
     ce0:	push   rbp
     ce1:	mov    rbp,rsp
     ce4:	sub    rsp,0xc0
     ceb:	mov    QWORD PTR [rsp+0x90],rbx
     cf3:	mov    QWORD PTR [rsp+0x98],r12
     cfb:	mov    QWORD PTR [rsp+0xa0],r13
     d03:	mov    QWORD PTR [rsp+0xa8],r14
     d0b:	mov    QWORD PTR [rsp+0xb0],r15
     d13:	mov    r12,r8
     d16:	mov    r15,rdi
     d19:	mov    QWORD PTR [rsp+0x20],0x0
     d22:	mov    QWORD PTR [rsp+0x28],0x0
     d2b:	mov    QWORD PTR [rsp+0x30],0x0
     d34:	mov    QWORD PTR [rsp+0x38],0x0
     d3d:	mov    QWORD PTR [rsp],rsi
     d41:	mov    QWORD PTR [rsp+0x8],rdx
     d46:	mov    r13,rdx
     d49:	mov    QWORD PTR [rsp+0x10],rcx
     d4e:	mov    QWORD PTR [rsp+0x18],r9
     d53:	mov    QWORD PTR [rsp+0x78],r9
     d58:	lea    r14,[rsp+0x50]
     d5d:	mov    rbx,rsi
     d60:	mov    QWORD PTR [rsp+0x70],rcx
     d65:	mov    rsi,rbx
     d68:	mov    rdi,r15
     d6b:	call   d70 <botlish_fn_5+0x90>
			d6c: R_X86_64_PLT32	rt_list_len-0x4
     d70:	mov    rsi,QWORD PTR [rsp+0x70]
     d75:	mov    rcx,rsi
     d78:	and    rcx,rax
     d7b:	mov    rdx,rax
     d7e:	test   rcx,0x1
     d85:	jne    dad <botlish_fn_5+0xcd>
     d8b:	mov    rsi,QWORD PTR [rsp+0x70]
     d90:	mov    rdi,r15
     d93:	call   d98 <botlish_fn_5+0xb8>
			d94: R_X86_64_PLT32	rt_int_cmp-0x4
     d98:	mov    ecx,0x2
     d9d:	test   rax,rax
     da0:	cmove  rcx,QWORD PTR [rip+0x258]        # 1000 <botlish_fn_5+0x320>
     da8:	jmp    dc2 <botlish_fn_5+0xe2>
     dad:	mov    ecx,0x2
     db2:	mov    rsi,QWORD PTR [rsp+0x70]
     db7:	cmp    rsi,rdx
     dba:	cmove  rcx,QWORD PTR [rip+0x23e]        # 1000 <botlish_fn_5+0x320>
     dc2:	cmp    rcx,0x6
     dc6:	je     f5c <botlish_fn_5+0x27c>
     dcc:	mov    rsi,QWORD PTR [rsp+0x70]
     dd1:	test   rsi,0x1
     dd8:	je     df6 <botlish_fn_5+0x116>
     dde:	mov    rsi,QWORD PTR [rbx+0x8]
     de2:	mov    rax,QWORD PTR [rsp+0x70]
     de7:	mov    rdx,rax
     dea:	sar    rdx,1
     ded:	cmp    rdx,rsi
     df0:	jb     e17 <botlish_fn_5+0x137>
     df6:	mov    rdx,QWORD PTR [rsp+0x70]
     dfb:	mov    rsi,rbx
     dfe:	mov    rdi,r15
     e01:	call   e06 <botlish_fn_5+0x126>
			e02: R_X86_64_PLT32	rt_list_get-0x4
     e06:	test   rax,rax
     e09:	je     f8f <botlish_fn_5+0x2af>
     e0f:	mov    rsi,rax
     e12:	jmp    e1f <botlish_fn_5+0x13f>
     e17:	mov    r9,QWORD PTR [rbx+0x10]
     e1b:	mov    rsi,QWORD PTR [r9+rdx*8]
     e1f:	mov    QWORD PTR [rsp+0x20],rsi
     e24:	mov    QWORD PTR [rsp+0x80],rsi
     e2c:	mov    QWORD PTR [rsp+0x28],0x1
     e35:	mov    rax,r12
     e38:	or     rax,0x1
     e3c:	mov    QWORD PTR [rsp+0x30],rax
     e41:	xor    rdx,rdx
     e44:	mov    rdi,r15
     e47:	mov    rsi,rdx
     e4a:	call   e4f <botlish_fn_5+0x16f>
			e4b: R_X86_64_PLT32	rt_list_new-0x4
     e4f:	test   rax,rax
     e52:	je     f8f <botlish_fn_5+0x2af>
     e58:	mov    QWORD PTR [rsp+0x38],rax
     e5d:	mov    r9,rax
     e60:	mov    ecx,0x1
     e65:	mov    r8,r12
     e68:	or     r8,0x1
     e6c:	mov    rsi,QWORD PTR [rsp+0x80]
     e74:	mov    rdx,r13
     e77:	mov    rdi,r15
     e7a:	call   e7f <botlish_fn_5+0x19f>
			e7b: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     e7f:	test   rax,rax
     e82:	je     f8f <botlish_fn_5+0x2af>
     e88:	mov    QWORD PTR [rsp+0x20],rax
     e8d:	mov    QWORD PTR [rsp+0x80],rax
     e95:	mov    QWORD PTR [rsp+0x28],0x3
     e9e:	mov    rsi,QWORD PTR [rsp+0x70]
     ea3:	test   rsi,0x1
     eaa:	je     ed4 <botlish_fn_5+0x1f4>
     eb0:	mov    rsi,QWORD PTR [rsp+0x70]
     eb5:	mov    rcx,rsi
     eb8:	add    rcx,0x2
     ebc:	seto   al
     ebf:	test   al,al
     ec1:	jne    ed4 <botlish_fn_5+0x1f4>
     ec7:	mov    rsi,rcx
     eca:	mov    QWORD PTR [rsp+0x70],rcx
     ecf:	jmp    eee <botlish_fn_5+0x20e>
     ed4:	mov    edx,0x3
     ed9:	mov    rsi,QWORD PTR [rsp+0x70]
     ede:	mov    rdi,r15
     ee1:	call   ee6 <botlish_fn_5+0x206>
			ee2: R_X86_64_PLT32	rt_int_add-0x4
     ee6:	mov    rsi,rax
     ee9:	mov    QWORD PTR [rsp+0x70],rax
     eee:	mov    QWORD PTR [rsp+0x10],rsi
     ef3:	mov    QWORD PTR [rsp+0x50],0x0
     efc:	mov    r9,QWORD PTR [rsp+0x78]
     f01:	mov    QWORD PTR [rsp+0x58],r9
     f06:	mov    QWORD PTR [rsp+0x60],0x2
     f0f:	mov    rax,QWORD PTR [rsp+0x80]
     f17:	mov    QWORD PTR [rsp+0x68],rax
     f1c:	mov    esi,0x3
     f21:	mov    edx,0x4
     f26:	mov    rcx,r14
     f29:	mov    rdi,r15
     f2c:	call   f31 <botlish_fn_5+0x251>
			f2d: R_X86_64_PLT32	rt_construct-0x4
     f31:	test   rax,rax
     f34:	je     f8f <botlish_fn_5+0x2af>
     f3a:	mov    QWORD PTR [rsp],rbx
     f3e:	mov    QWORD PTR [rsp+0x8],r13
     f43:	mov    rsi,QWORD PTR [rsp+0x70]
     f48:	mov    QWORD PTR [rsp+0x10],rsi
     f4d:	mov    QWORD PTR [rsp+0x18],rax
     f52:	mov    QWORD PTR [rsp+0x78],rax
     f57:	jmp    d65 <botlish_fn_5+0x85>
     f5c:	mov    r9,QWORD PTR [rsp+0x78]
     f61:	lea    rcx,[rsp+0x40]
     f66:	mov    QWORD PTR [rsp+0x40],0x0
     f6f:	mov    QWORD PTR [rsp+0x48],r9
     f74:	mov    esi,0x1
     f79:	mov    edx,0x2
     f7e:	mov    rdi,r15
     f81:	call   f86 <botlish_fn_5+0x2a6>
			f82: R_X86_64_PLT32	rt_construct-0x4
     f86:	test   rax,rax
     f89:	jne    fc6 <botlish_fn_5+0x2e6>
     f8f:	xor    rax,rax
     f92:	mov    rbx,QWORD PTR [rsp+0x90]
     f9a:	mov    r12,QWORD PTR [rsp+0x98]
     fa2:	mov    r13,QWORD PTR [rsp+0xa0]
     faa:	mov    r14,QWORD PTR [rsp+0xa8]
     fb2:	mov    r15,QWORD PTR [rsp+0xb0]
     fba:	add    rsp,0xc0
     fc1:	mov    rsp,rbp
     fc4:	pop    rbp
     fc5:	ret
     fc6:	mov    rbx,QWORD PTR [rsp+0x90]
     fce:	mov    r12,QWORD PTR [rsp+0x98]
     fd6:	mov    r13,QWORD PTR [rsp+0xa0]
     fde:	mov    r14,QWORD PTR [rsp+0xa8]
     fe6:	mov    r15,QWORD PTR [rsp+0xb0]
     fee:	add    rsp,0xc0
     ff5:	mov    rsp,rbp
     ff8:	pop    rbp
     ff9:	ret
     ffa:	add    BYTE PTR [rax],al
     ffc:	add    BYTE PTR [rax],al
     ffe:	add    BYTE PTR [rax],al
    1000:	(bad)
    1001:	add    BYTE PTR [rax],al
    1003:	add    BYTE PTR [rax],al
    1005:	add    BYTE PTR [rax],al
	...

0000000000001008 <botlish_entry_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
    1008:	push   rbp
    1009:	mov    rbp,rsp
    100c:	mov    rsi,QWORD PTR [rdx]
    100f:	mov    r10,QWORD PTR [rdx+0x8]
    1013:	mov    rcx,QWORD PTR [rdx+0x10]
    1017:	mov    r8,QWORD PTR [rdx+0x18]
    101b:	mov    r9,QWORD PTR [rdx+0x20]
    101f:	mov    rdx,r10
    1022:	call   1027 <botlish_entry_5+0x1f>
			1023: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
    1027:	mov    rsp,rbp
    102a:	pop    rbp
    102b:	ret

000000000000102c <botlish_fn_6: matmul<List[List[int]], List[List[int]]>>:
    102c:	push   rbp
    102d:	mov    rbp,rsp
    1030:	sub    rsp,0x50
    1034:	mov    QWORD PTR [rsp+0x30],rbx
    1039:	mov    QWORD PTR [rsp+0x38],r12
    103e:	mov    QWORD PTR [rsp+0x40],r13
    1043:	mov    QWORD PTR [rsp+0x48],r14
    1048:	mov    r12,rdi
    104b:	mov    QWORD PTR [rsp+0x10],0x0
    1054:	mov    QWORD PTR [rsp+0x18],0x0
    105d:	mov    QWORD PTR [rsp+0x20],0x0
    1066:	mov    QWORD PTR [rsp],rsi
    106a:	mov    r13,rsi
    106d:	mov    QWORD PTR [rsp+0x8],rdx
    1072:	mov    rbx,rdx
    1075:	mov    rsi,r13
    1078:	mov    rdi,r12
    107b:	call   1080 <botlish_fn_6+0x54>
			107c: R_X86_64_PLT32	rt_list_len-0x4
    1080:	sar    rax,1
    1083:	test   rax,rax
    1086:	je     1138 <botlish_fn_6+0x10c>
    108c:	mov    QWORD PTR [rsp+0x10],0x1
    1095:	mov    rax,QWORD PTR [rbx+0x8]
    1099:	test   rax,rax
    109c:	jne    10c3 <botlish_fn_6+0x97>
    10a2:	mov    edx,0x1
    10a7:	mov    rsi,rbx
    10aa:	mov    rdi,r12
    10ad:	call   10b2 <botlish_fn_6+0x86>
			10ae: R_X86_64_PLT32	rt_list_get-0x4
    10b2:	test   rax,rax
    10b5:	je     114f <botlish_fn_6+0x123>
    10bb:	mov    rsi,rax
    10be:	jmp    10cd <botlish_fn_6+0xa1>
    10c3:	mov    rdx,rbx
    10c6:	mov    rax,QWORD PTR [rdx+0x10]
    10ca:	mov    rsi,QWORD PTR [rax]
    10cd:	mov    rdi,r12
    10d0:	call   10d5 <botlish_fn_6+0xa9>
			10d1: R_X86_64_PLT32	rt_list_len-0x4
    10d5:	mov    QWORD PTR [rsp+0x18],rax
    10da:	mov    r14,rax
    10dd:	xor    rdx,rdx
    10e0:	mov    rdi,r12
    10e3:	mov    rsi,rdx
    10e6:	call   10eb <botlish_fn_6+0xbf>
			10e7: R_X86_64_PLT32	rt_list_new-0x4
    10eb:	test   rax,rax
    10ee:	je     114f <botlish_fn_6+0x123>
    10f4:	mov    QWORD PTR [rsp+0x20],rax
    10f9:	mov    r9,rax
    10fc:	mov    ecx,0x1
    1101:	mov    rdx,rbx
    1104:	mov    rsi,r13
    1107:	mov    rdi,r12
    110a:	mov    r8,r14
    110d:	call   1112 <botlish_fn_6+0xe6>
			110e: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
    1112:	test   rax,rax
    1115:	je     114f <botlish_fn_6+0x123>
    111b:	mov    rbx,QWORD PTR [rsp+0x30]
    1120:	mov    r12,QWORD PTR [rsp+0x38]
    1125:	mov    r13,QWORD PTR [rsp+0x40]
    112a:	mov    r14,QWORD PTR [rsp+0x48]
    112f:	add    rsp,0x50
    1133:	mov    rsp,rbp
    1136:	pop    rbp
    1137:	ret
    1138:	xor    rdx,rdx
    113b:	mov    rdi,r12
    113e:	mov    rsi,rdx
    1141:	call   1146 <botlish_fn_6+0x11a>
			1142: R_X86_64_PLT32	rt_list_new-0x4
    1146:	test   rax,rax
    1149:	jne    116f <botlish_fn_6+0x143>
    114f:	xor    rax,rax
    1152:	mov    rbx,QWORD PTR [rsp+0x30]
    1157:	mov    r12,QWORD PTR [rsp+0x38]
    115c:	mov    r13,QWORD PTR [rsp+0x40]
    1161:	mov    r14,QWORD PTR [rsp+0x48]
    1166:	add    rsp,0x50
    116a:	mov    rsp,rbp
    116d:	pop    rbp
    116e:	ret
    116f:	mov    rbx,QWORD PTR [rsp+0x30]
    1174:	mov    r12,QWORD PTR [rsp+0x38]
    1179:	mov    r13,QWORD PTR [rsp+0x40]
    117e:	mov    r14,QWORD PTR [rsp+0x48]
    1183:	add    rsp,0x50
    1187:	mov    rsp,rbp
    118a:	pop    rbp
    118b:	ret

000000000000118c <botlish_entry_6: matmul<List[List[int]], List[List[int]]>>:
    118c:	push   rbp
    118d:	mov    rbp,rsp
    1190:	mov    rsi,QWORD PTR [rdx]
    1193:	mov    rdx,QWORD PTR [rdx+0x8]
    1197:	call   119c <botlish_entry_6+0x10>
			1198: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<List[List[int]], List[List[int]]>
    119c:	mov    rsp,rbp
    119f:	pop    rbp
    11a0:	ret

; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4160  (per function: 750 703 483 596 536 684 408)
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
 55a:	sub    rsp,0xa0
 561:	mov    QWORD PTR [rsp+0x70],rbx
 566:	mov    QWORD PTR [rsp+0x78],r12
 56b:	mov    QWORD PTR [rsp+0x80],r13
 573:	mov    QWORD PTR [rsp+0x88],r14
 57b:	mov    QWORD PTR [rsp+0x90],r15
 583:	mov    QWORD PTR [rsp+0x50],rdi
 588:	mov    QWORD PTR [rsp+0x10],rsi
 58d:	mov    r15,rsi
 590:	mov    QWORD PTR [rsp+0x18],rdx
 595:	mov    r14,rdx
 598:	mov    QWORD PTR [rsp+0x20],rcx
 59d:	mov    QWORD PTR [rsp+0x28],r8
 5a2:	mov    QWORD PTR [rsp+0x30],r9
 5a7:	mov    QWORD PTR [rsp+0x60],r9
 5ac:	mov    r12,rcx
 5af:	sar    r12,1
 5b2:	mov    QWORD PTR [rsp+0x58],rcx
 5b7:	mov    rax,r8
 5ba:	sar    rax,1
 5bd:	mov    r13,r8
 5c0:	cmp    r12,rax
 5c3:	je     6d4 <botlish_fn_2+0x17e>
 5c9:	mov    ebx,0x1
 5ce:	mov    QWORD PTR [rsp+0x38],0x1
 5d7:	mov    rsi,r15
 5da:	mov    rdi,QWORD PTR [rsp+0x50]
 5df:	call   5e4 <botlish_fn_2+0x8e>
			5e0: R_X86_64_PLT32	rt_list_len-0x4
 5e4:	mov    QWORD PTR [rsp+0x40],rax
 5e9:	mov    QWORD PTR [rsp+0x48],0x1
 5f2:	mov    QWORD PTR [rsp],rbx
 5f6:	mov    rcx,QWORD PTR [rsp+0x58]
 5fb:	mov    r8,rbx
 5fe:	mov    r9,rax
 601:	mov    rdx,r14
 604:	mov    rsi,r15
 607:	mov    rdi,QWORD PTR [rsp+0x50]
 60c:	call   611 <botlish_fn_2+0xbb>
			60d: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
 611:	test   rax,rax
 614:	je     675 <botlish_fn_2+0x11f>
 61a:	mov    QWORD PTR [rsp+0x20],rax
 61f:	mov    rdx,rax
 622:	lea    rcx,[r12+0x1]
 627:	shl    rcx,1
 62a:	or     rcx,0x1
 62e:	mov    QWORD PTR [rsp+0x38],rcx
 633:	mov    rbx,rcx
 636:	mov    rsi,QWORD PTR [rsp+0x60]
 63b:	mov    rdi,QWORD PTR [rsp+0x50]
 640:	call   645 <botlish_fn_2+0xef>
			641: R_X86_64_PLT32	rt_list_append-0x4
 645:	test   rax,rax
 648:	je     675 <botlish_fn_2+0x11f>
 64e:	mov    QWORD PTR [rsp+0x20],rax
 653:	mov    rcx,rbx
 656:	mov    rdx,r14
 659:	mov    rsi,r15
 65c:	mov    rdi,QWORD PTR [rsp+0x50]
 661:	mov    r8,r13
 664:	mov    r9,rax
 667:	call   66c <botlish_fn_2+0x116>
			668: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
 66c:	test   rax,rax
 66f:	jne    6a6 <botlish_fn_2+0x150>
 675:	xor    rax,rax
 678:	mov    rbx,QWORD PTR [rsp+0x70]
 67d:	mov    r12,QWORD PTR [rsp+0x78]
 682:	mov    r13,QWORD PTR [rsp+0x80]
 68a:	mov    r14,QWORD PTR [rsp+0x88]
 692:	mov    r15,QWORD PTR [rsp+0x90]
 69a:	add    rsp,0xa0
 6a1:	mov    rsp,rbp
 6a4:	pop    rbp
 6a5:	ret
 6a6:	mov    rbx,QWORD PTR [rsp+0x70]
 6ab:	mov    r12,QWORD PTR [rsp+0x78]
 6b0:	mov    r13,QWORD PTR [rsp+0x80]
 6b8:	mov    r14,QWORD PTR [rsp+0x88]
 6c0:	mov    r15,QWORD PTR [rsp+0x90]
 6c8:	add    rsp,0xa0
 6cf:	mov    rsp,rbp
 6d2:	pop    rbp
 6d3:	ret
 6d4:	mov    rax,QWORD PTR [rsp+0x60]
 6d9:	mov    rbx,QWORD PTR [rsp+0x70]
 6de:	mov    r12,QWORD PTR [rsp+0x78]
 6e3:	mov    r13,QWORD PTR [rsp+0x80]
 6eb:	mov    r14,QWORD PTR [rsp+0x88]
 6f3:	mov    r15,QWORD PTR [rsp+0x90]
 6fb:	add    rsp,0xa0
 702:	mov    rsp,rbp
 705:	pop    rbp
 706:	ret

0000000000000707 <botlish_entry_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
 707:	push   rbp
 708:	mov    rbp,rsp
 70b:	mov    rsi,QWORD PTR [rdx]
 70e:	mov    r10,QWORD PTR [rdx+0x8]
 712:	mov    rcx,QWORD PTR [rdx+0x10]
 716:	mov    r8,QWORD PTR [rdx+0x18]
 71a:	mov    r9,QWORD PTR [rdx+0x20]
 71e:	mov    rdx,r10
 721:	call   726 <botlish_entry_2+0x1f>
			722: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
 726:	mov    rsp,rbp
 729:	pop    rbp
 72a:	ret
 72b:	add    BYTE PTR [rax],al
 72d:	add    BYTE PTR [rax],al
	...

0000000000000730 <botlish_fn_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
 730:	push   rbp
 731:	mov    rbp,rsp
 734:	sub    rsp,0x90
 73b:	mov    QWORD PTR [rsp+0x60],rbx
 740:	mov    QWORD PTR [rsp+0x68],r12
 745:	mov    QWORD PTR [rsp+0x70],r13
 74a:	mov    QWORD PTR [rsp+0x78],r14
 74f:	mov    QWORD PTR [rsp+0x80],r15
 757:	mov    r15,rdi
 75a:	mov    QWORD PTR [rsp+0x10],rsi
 75f:	mov    rbx,rsi
 762:	mov    QWORD PTR [rsp+0x18],rdx
 767:	mov    r14,rdx
 76a:	mov    QWORD PTR [rsp+0x20],rcx
 76f:	mov    QWORD PTR [rsp+0x28],r9
 774:	mov    rsi,rcx
 777:	mov    r13,r8
 77a:	mov    QWORD PTR [rsp+0x50],r9
 77f:	mov    rax,r13
 782:	or     rax,0x1
 786:	mov    rcx,rsi
 789:	and    rcx,rax
 78c:	mov    QWORD PTR [rsp+0x48],rsi
 791:	test   rcx,0x1
 798:	jne    7c7 <botlish_fn_3+0x97>
 79e:	mov    rdx,r13
 7a1:	or     rdx,0x1
 7a5:	mov    rsi,QWORD PTR [rsp+0x48]
 7aa:	mov    rdi,r15
 7ad:	call   7b2 <botlish_fn_3+0x82>
			7ae: R_X86_64_PLT32	rt_int_cmp-0x4
 7b2:	mov    ecx,0x2
 7b7:	test   rax,rax
 7ba:	cmove  rcx,QWORD PTR [rip+0x17e]        # 940 <botlish_fn_3+0x210>
 7c2:	jmp    7e3 <botlish_fn_3+0xb3>
 7c7:	mov    rax,r13
 7ca:	or     rax,0x1
 7ce:	mov    ecx,0x2
 7d3:	mov    rsi,QWORD PTR [rsp+0x48]
 7d8:	cmp    rsi,rax
 7db:	cmove  rcx,QWORD PTR [rip+0x15d]        # 940 <botlish_fn_3+0x210>
 7e3:	cmp    rcx,0x6
 7e7:	je     90e <botlish_fn_3+0x1de>
 7ed:	mov    r12d,0x1
 7f3:	mov    QWORD PTR [rsp+0x30],0x1
 7fc:	mov    rsi,rbx
 7ff:	mov    rdi,r15
 802:	call   807 <botlish_fn_3+0xd7>
			803: R_X86_64_PLT32	rt_list_len-0x4
 807:	mov    QWORD PTR [rsp+0x38],rax
 80c:	mov    QWORD PTR [rsp+0x40],0x1
 815:	mov    QWORD PTR [rsp],r12
 819:	mov    r9,rax
 81c:	mov    r8,r12
 81f:	mov    r12,r14
 822:	mov    rcx,QWORD PTR [rsp+0x48]
 827:	mov    rdx,r12
 82a:	mov    rsi,rbx
 82d:	mov    rdi,r15
 830:	call   835 <botlish_fn_3+0x105>
			831: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
 835:	test   rax,rax
 838:	je     8bd <botlish_fn_3+0x18d>
 83e:	mov    QWORD PTR [rsp+0x30],rax
 843:	mov    r14,rax
 846:	mov    QWORD PTR [rsp+0x38],0x3
 84f:	mov    rsi,QWORD PTR [rsp+0x48]
 854:	test   rsi,0x1
 85b:	je     885 <botlish_fn_3+0x155>
 861:	mov    rsi,QWORD PTR [rsp+0x48]
 866:	mov    rax,rsi
 869:	add    rax,0x2
 86d:	seto   cl
 870:	test   cl,cl
 872:	jne    885 <botlish_fn_3+0x155>
 878:	mov    rsi,rax
 87b:	mov    QWORD PTR [rsp+0x48],rax
 880:	jmp    89f <botlish_fn_3+0x16f>
 885:	mov    edx,0x3
 88a:	mov    rsi,QWORD PTR [rsp+0x48]
 88f:	mov    rdi,r15
 892:	call   897 <botlish_fn_3+0x167>
			893: R_X86_64_PLT32	rt_int_add-0x4
 897:	mov    rsi,rax
 89a:	mov    QWORD PTR [rsp+0x48],rax
 89f:	mov    QWORD PTR [rsp+0x20],rsi
 8a4:	mov    rdx,r14
 8a7:	mov    rsi,QWORD PTR [rsp+0x50]
 8ac:	mov    rdi,r15
 8af:	call   8b4 <botlish_fn_3+0x184>
			8b0: R_X86_64_PLT32	rt_list_append-0x4
 8b4:	test   rax,rax
 8b7:	jne    8e8 <botlish_fn_3+0x1b8>
 8bd:	xor    rax,rax
 8c0:	mov    rbx,QWORD PTR [rsp+0x60]
 8c5:	mov    r12,QWORD PTR [rsp+0x68]
 8ca:	mov    r13,QWORD PTR [rsp+0x70]
 8cf:	mov    r14,QWORD PTR [rsp+0x78]
 8d4:	mov    r15,QWORD PTR [rsp+0x80]
 8dc:	add    rsp,0x90
 8e3:	mov    rsp,rbp
 8e6:	pop    rbp
 8e7:	ret
 8e8:	mov    QWORD PTR [rsp+0x10],rbx
 8ed:	mov    QWORD PTR [rsp+0x18],r12
 8f2:	mov    rsi,QWORD PTR [rsp+0x48]
 8f7:	mov    QWORD PTR [rsp+0x20],rsi
 8fc:	mov    QWORD PTR [rsp+0x28],rax
 901:	mov    r14,r12
 904:	mov    QWORD PTR [rsp+0x50],rax
 909:	jmp    77f <botlish_fn_3+0x4f>
 90e:	mov    rax,QWORD PTR [rsp+0x50]
 913:	mov    rbx,QWORD PTR [rsp+0x60]
 918:	mov    r12,QWORD PTR [rsp+0x68]
 91d:	mov    r13,QWORD PTR [rsp+0x70]
 922:	mov    r14,QWORD PTR [rsp+0x78]
 927:	mov    r15,QWORD PTR [rsp+0x80]
 92f:	add    rsp,0x90
 936:	mov    rsp,rbp
 939:	pop    rbp
 93a:	ret
 93b:	add    BYTE PTR [rax],al
 93d:	add    BYTE PTR [rax],al
 93f:	add    BYTE PTR [rsi],al
 941:	add    BYTE PTR [rax],al
 943:	add    BYTE PTR [rax],al
 945:	add    BYTE PTR [rax],al
	...

0000000000000948 <botlish_entry_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
 948:	push   rbp
 949:	mov    rbp,rsp
 94c:	mov    rsi,QWORD PTR [rdx]
 94f:	mov    r10,QWORD PTR [rdx+0x8]
 953:	mov    rcx,QWORD PTR [rdx+0x10]
 957:	mov    r8,QWORD PTR [rdx+0x18]
 95b:	mov    r9,QWORD PTR [rdx+0x20]
 95f:	mov    rdx,r10
 962:	call   967 <botlish_entry_3+0x1f>
			963: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
 967:	mov    rsp,rbp
 96a:	pop    rbp
 96b:	ret

000000000000096c <botlish_fn_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
 96c:	push   rbp
 96d:	mov    rbp,rsp
 970:	sub    rsp,0x80
 977:	mov    QWORD PTR [rsp+0x50],rbx
 97c:	mov    QWORD PTR [rsp+0x58],r12
 981:	mov    QWORD PTR [rsp+0x60],r13
 986:	mov    QWORD PTR [rsp+0x68],r14
 98b:	mov    QWORD PTR [rsp+0x70],r15
 990:	mov    rbx,rcx
 993:	mov    r15,rdi
 996:	mov    QWORD PTR [rsp+0x30],0x0
 99f:	mov    QWORD PTR [rsp],rsi
 9a3:	mov    r14,rsi
 9a6:	mov    QWORD PTR [rsp+0x8],rdx
 9ab:	mov    r13,rdx
 9ae:	mov    QWORD PTR [rsp+0x10],r8
 9b3:	mov    r12,r8
 9b6:	mov    QWORD PTR [rsp+0x18],r9
 9bb:	mov    QWORD PTR [rsp+0x38],r9
 9c0:	mov    rsi,r14
 9c3:	mov    rdi,r15
 9c6:	call   9cb <botlish_fn_4+0x5f>
			9c7: R_X86_64_PLT32	rt_list_len-0x4
 9cb:	mov    rcx,rbx
 9ce:	sar    rbx,1
 9d1:	sar    rax,1
 9d4:	cmp    rbx,rax
 9d7:	je     b22 <botlish_fn_4+0x1b6>
 9dd:	test   rcx,0x1
 9e4:	jne    9f2 <botlish_fn_4+0x86>
 9ea:	mov    rdx,rcx
 9ed:	jmp    a05 <botlish_fn_4+0x99>
 9f2:	mov    rsi,r14
 9f5:	mov    rax,QWORD PTR [rsi+0x8]
 9f9:	cmp    rbx,rax
 9fc:	jb     a21 <botlish_fn_4+0xb5>
 a02:	mov    rdx,rcx
 a05:	mov    rsi,r14
 a08:	mov    rdi,r15
 a0b:	call   a10 <botlish_fn_4+0xa4>
			a0c: R_X86_64_PLT32	rt_list_get-0x4
 a10:	test   rax,rax
 a13:	je     ad5 <botlish_fn_4+0x169>
 a19:	mov    rsi,rax
 a1c:	jmp    a2c <botlish_fn_4+0xc0>
 a21:	mov    rsi,r14
 a24:	mov    rax,QWORD PTR [rsi+0x10]
 a28:	mov    rsi,QWORD PTR [rax+rbx*8]
 a2c:	mov    QWORD PTR [rsp+0x20],rsi
 a31:	mov    QWORD PTR [rsp+0x40],rsi
 a36:	mov    QWORD PTR [rsp+0x28],0x1
 a3f:	xor    rdx,rdx
 a42:	mov    rdi,r15
 a45:	mov    rsi,rdx
 a48:	call   a4d <botlish_fn_4+0xe1>
			a49: R_X86_64_PLT32	rt_list_new-0x4
 a4d:	test   rax,rax
 a50:	je     ad5 <botlish_fn_4+0x169>
 a56:	mov    QWORD PTR [rsp+0x30],rax
 a5b:	mov    r9,rax
 a5e:	mov    ecx,0x1
 a63:	mov    rsi,QWORD PTR [rsp+0x40]
 a68:	mov    rdx,r13
 a6b:	mov    rdi,r15
 a6e:	mov    r8,r12
 a71:	call   a76 <botlish_fn_4+0x10a>
			a72: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
 a76:	test   rax,rax
 a79:	je     ad5 <botlish_fn_4+0x169>
 a7f:	mov    QWORD PTR [rsp+0x20],rax
 a84:	mov    rdx,rax
 a87:	lea    rcx,[rbx+0x1]
 a8b:	shl    rcx,1
 a8e:	or     rcx,0x1
 a92:	mov    QWORD PTR [rsp+0x28],rcx
 a97:	mov    rbx,rcx
 a9a:	mov    rsi,QWORD PTR [rsp+0x38]
 a9f:	mov    rdi,r15
 aa2:	call   aa7 <botlish_fn_4+0x13b>
			aa3: R_X86_64_PLT32	rt_list_append-0x4
 aa7:	test   rax,rax
 aaa:	je     ad5 <botlish_fn_4+0x169>
 ab0:	mov    QWORD PTR [rsp+0x18],rax
 ab5:	mov    rcx,rbx
 ab8:	mov    rdx,r13
 abb:	mov    rsi,r14
 abe:	mov    rdi,r15
 ac1:	mov    r8,r12
 ac4:	mov    r9,rax
 ac7:	call   acc <botlish_fn_4+0x160>
			ac8: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
 acc:	test   rax,rax
 acf:	jne    afd <botlish_fn_4+0x191>
 ad5:	xor    rax,rax
 ad8:	mov    rbx,QWORD PTR [rsp+0x50]
 add:	mov    r12,QWORD PTR [rsp+0x58]
 ae2:	mov    r13,QWORD PTR [rsp+0x60]
 ae7:	mov    r14,QWORD PTR [rsp+0x68]
 aec:	mov    r15,QWORD PTR [rsp+0x70]
 af1:	add    rsp,0x80
 af8:	mov    rsp,rbp
 afb:	pop    rbp
 afc:	ret
 afd:	mov    rbx,QWORD PTR [rsp+0x50]
 b02:	mov    r12,QWORD PTR [rsp+0x58]
 b07:	mov    r13,QWORD PTR [rsp+0x60]
 b0c:	mov    r14,QWORD PTR [rsp+0x68]
 b11:	mov    r15,QWORD PTR [rsp+0x70]
 b16:	add    rsp,0x80
 b1d:	mov    rsp,rbp
 b20:	pop    rbp
 b21:	ret
 b22:	mov    rax,QWORD PTR [rsp+0x38]
 b27:	mov    rbx,QWORD PTR [rsp+0x50]
 b2c:	mov    r12,QWORD PTR [rsp+0x58]
 b31:	mov    r13,QWORD PTR [rsp+0x60]
 b36:	mov    r14,QWORD PTR [rsp+0x68]
 b3b:	mov    r15,QWORD PTR [rsp+0x70]
 b40:	add    rsp,0x80
 b47:	mov    rsp,rbp
 b4a:	pop    rbp
 b4b:	ret

0000000000000b4c <botlish_entry_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
 b4c:	push   rbp
 b4d:	mov    rbp,rsp
 b50:	mov    rsi,QWORD PTR [rdx]
 b53:	mov    r10,QWORD PTR [rdx+0x8]
 b57:	mov    rcx,QWORD PTR [rdx+0x10]
 b5b:	mov    r8,QWORD PTR [rdx+0x18]
 b5f:	mov    r9,QWORD PTR [rdx+0x20]
 b63:	mov    rdx,r10
 b66:	call   b6b <botlish_entry_4+0x1f>
			b67: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
 b6b:	mov    rsp,rbp
 b6e:	pop    rbp
 b6f:	ret

0000000000000b70 <botlish_fn_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
 b70:	push   rbp
 b71:	mov    rbp,rsp
 b74:	sub    rsp,0x90
 b7b:	mov    QWORD PTR [rsp+0x60],rbx
 b80:	mov    QWORD PTR [rsp+0x68],r12
 b85:	mov    QWORD PTR [rsp+0x70],r13
 b8a:	mov    QWORD PTR [rsp+0x78],r14
 b8f:	mov    QWORD PTR [rsp+0x80],r15
 b97:	mov    rbx,r8
 b9a:	mov    r14,rdi
 b9d:	mov    QWORD PTR [rsp+0x38],0x0
 ba6:	mov    QWORD PTR [rsp],rsi
 baa:	mov    QWORD PTR [rsp+0x8],rdx
 baf:	mov    r13,rdx
 bb2:	mov    QWORD PTR [rsp+0x10],rcx
 bb7:	mov    QWORD PTR [rsp+0x18],r9
 bbc:	mov    r12,rsi
 bbf:	mov    QWORD PTR [rsp+0x40],rcx
 bc4:	mov    QWORD PTR [rsp+0x48],r9
 bc9:	mov    rsi,r12
 bcc:	mov    rdi,r14
 bcf:	call   bd4 <botlish_fn_5+0x64>
			bd0: R_X86_64_PLT32	rt_list_len-0x4
 bd4:	mov    rsi,QWORD PTR [rsp+0x40]
 bd9:	mov    rcx,rsi
 bdc:	and    rcx,rax
 bdf:	mov    rdx,rax
 be2:	test   rcx,0x1
 be9:	jne    c11 <botlish_fn_5+0xa1>
 bef:	mov    rsi,QWORD PTR [rsp+0x40]
 bf4:	mov    rdi,r14
 bf7:	call   bfc <botlish_fn_5+0x8c>
			bf8: R_X86_64_PLT32	rt_int_cmp-0x4
 bfc:	mov    ecx,0x2
 c01:	test   rax,rax
 c04:	cmove  rcx,QWORD PTR [rip+0x1e4]        # df0 <botlish_fn_5+0x280>
 c0c:	jmp    c26 <botlish_fn_5+0xb6>
 c11:	mov    ecx,0x2
 c16:	mov    rsi,QWORD PTR [rsp+0x40]
 c1b:	cmp    rsi,rdx
 c1e:	cmove  rcx,QWORD PTR [rip+0x1ca]        # df0 <botlish_fn_5+0x280>
 c26:	cmp    rcx,0x6
 c2a:	je     dc0 <botlish_fn_5+0x250>
 c30:	mov    rsi,QWORD PTR [rsp+0x40]
 c35:	test   rsi,0x1
 c3c:	je     c5b <botlish_fn_5+0xeb>
 c42:	mov    rcx,QWORD PTR [r12+0x8]
 c47:	mov    rsi,QWORD PTR [rsp+0x40]
 c4c:	mov    rax,rsi
 c4f:	sar    rax,1
 c52:	cmp    rax,rcx
 c55:	jb     c7c <botlish_fn_5+0x10c>
 c5b:	mov    rdx,QWORD PTR [rsp+0x40]
 c60:	mov    rsi,r12
 c63:	mov    rdi,r14
 c66:	call   c6b <botlish_fn_5+0xfb>
			c67: R_X86_64_PLT32	rt_list_get-0x4
 c6b:	test   rax,rax
 c6e:	je     d6d <botlish_fn_5+0x1fd>
 c74:	mov    rsi,rax
 c77:	jmp    c85 <botlish_fn_5+0x115>
 c7c:	mov    rcx,QWORD PTR [r12+0x10]
 c81:	mov    rsi,QWORD PTR [rcx+rax*8]
 c85:	mov    QWORD PTR [rsp+0x20],rsi
 c8a:	mov    QWORD PTR [rsp+0x50],rsi
 c8f:	mov    QWORD PTR [rsp+0x28],0x1
 c98:	mov    r15,rbx
 c9b:	mov    rdx,r15
 c9e:	or     rdx,0x1
 ca2:	mov    QWORD PTR [rsp+0x30],rdx
 ca7:	xor    rdx,rdx
 caa:	mov    rdi,r14
 cad:	mov    rsi,rdx
 cb0:	call   cb5 <botlish_fn_5+0x145>
			cb1: R_X86_64_PLT32	rt_list_new-0x4
 cb5:	test   rax,rax
 cb8:	je     d6d <botlish_fn_5+0x1fd>
 cbe:	mov    QWORD PTR [rsp+0x38],rax
 cc3:	mov    r9,rax
 cc6:	mov    ecx,0x1
 ccb:	mov    r8,r15
 cce:	or     r8,0x1
 cd2:	mov    rbx,r13
 cd5:	mov    rsi,QWORD PTR [rsp+0x50]
 cda:	mov    rdx,rbx
 cdd:	mov    rdi,r14
 ce0:	call   ce5 <botlish_fn_5+0x175>
			ce1: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
 ce5:	test   rax,rax
 ce8:	je     d6d <botlish_fn_5+0x1fd>
 cee:	mov    QWORD PTR [rsp+0x20],rax
 cf3:	mov    r13,rax
 cf6:	mov    QWORD PTR [rsp+0x28],0x3
 cff:	mov    rsi,QWORD PTR [rsp+0x40]
 d04:	test   rsi,0x1
 d0b:	je     d35 <botlish_fn_5+0x1c5>
 d11:	mov    rsi,QWORD PTR [rsp+0x40]
 d16:	mov    rax,rsi
 d19:	add    rax,0x2
 d1d:	seto   cl
 d20:	test   cl,cl
 d22:	jne    d35 <botlish_fn_5+0x1c5>
 d28:	mov    rsi,rax
 d2b:	mov    QWORD PTR [rsp+0x40],rax
 d30:	jmp    d4f <botlish_fn_5+0x1df>
 d35:	mov    edx,0x3
 d3a:	mov    rsi,QWORD PTR [rsp+0x40]
 d3f:	mov    rdi,r14
 d42:	call   d47 <botlish_fn_5+0x1d7>
			d43: R_X86_64_PLT32	rt_int_add-0x4
 d47:	mov    rsi,rax
 d4a:	mov    QWORD PTR [rsp+0x40],rax
 d4f:	mov    QWORD PTR [rsp+0x10],rsi
 d54:	mov    rdx,r13
 d57:	mov    rsi,QWORD PTR [rsp+0x48]
 d5c:	mov    rdi,r14
 d5f:	call   d64 <botlish_fn_5+0x1f4>
			d60: R_X86_64_PLT32	rt_list_append-0x4
 d64:	test   rax,rax
 d67:	jne    d98 <botlish_fn_5+0x228>
 d6d:	xor    rax,rax
 d70:	mov    rbx,QWORD PTR [rsp+0x60]
 d75:	mov    r12,QWORD PTR [rsp+0x68]
 d7a:	mov    r13,QWORD PTR [rsp+0x70]
 d7f:	mov    r14,QWORD PTR [rsp+0x78]
 d84:	mov    r15,QWORD PTR [rsp+0x80]
 d8c:	add    rsp,0x90
 d93:	mov    rsp,rbp
 d96:	pop    rbp
 d97:	ret
 d98:	mov    QWORD PTR [rsp],r12
 d9c:	mov    QWORD PTR [rsp+0x8],rbx
 da1:	mov    rsi,QWORD PTR [rsp+0x40]
 da6:	mov    QWORD PTR [rsp+0x10],rsi
 dab:	mov    QWORD PTR [rsp+0x18],rax
 db0:	mov    QWORD PTR [rsp+0x48],rax
 db5:	mov    r13,rbx
 db8:	mov    rbx,r15
 dbb:	jmp    bc9 <botlish_fn_5+0x59>
 dc0:	mov    rax,QWORD PTR [rsp+0x48]
 dc5:	mov    rbx,QWORD PTR [rsp+0x60]
 dca:	mov    r12,QWORD PTR [rsp+0x68]
 dcf:	mov    r13,QWORD PTR [rsp+0x70]
 dd4:	mov    r14,QWORD PTR [rsp+0x78]
 dd9:	mov    r15,QWORD PTR [rsp+0x80]
 de1:	add    rsp,0x90
 de8:	mov    rsp,rbp
 deb:	pop    rbp
 dec:	ret
 ded:	add    BYTE PTR [rax],al
 def:	add    BYTE PTR [rsi],al
 df1:	add    BYTE PTR [rax],al
 df3:	add    BYTE PTR [rax],al
 df5:	add    BYTE PTR [rax],al
	...

0000000000000df8 <botlish_entry_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
 df8:	push   rbp
 df9:	mov    rbp,rsp
 dfc:	mov    rsi,QWORD PTR [rdx]
 dff:	mov    r10,QWORD PTR [rdx+0x8]
 e03:	mov    rcx,QWORD PTR [rdx+0x10]
 e07:	mov    r8,QWORD PTR [rdx+0x18]
 e0b:	mov    r9,QWORD PTR [rdx+0x20]
 e0f:	mov    rdx,r10
 e12:	call   e17 <botlish_entry_5+0x1f>
			e13: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
 e17:	mov    rsp,rbp
 e1a:	pop    rbp
 e1b:	ret

0000000000000e1c <botlish_fn_6: matmul<List[List[int]], List[List[int]]>>:
 e1c:	push   rbp
 e1d:	mov    rbp,rsp
 e20:	sub    rsp,0x50
 e24:	mov    QWORD PTR [rsp+0x30],rbx
 e29:	mov    QWORD PTR [rsp+0x38],r12
 e2e:	mov    QWORD PTR [rsp+0x40],r13
 e33:	mov    QWORD PTR [rsp+0x48],r14
 e38:	mov    r12,rdi
 e3b:	mov    QWORD PTR [rsp+0x10],0x0
 e44:	mov    QWORD PTR [rsp+0x18],0x0
 e4d:	mov    QWORD PTR [rsp+0x20],0x0
 e56:	mov    QWORD PTR [rsp],rsi
 e5a:	mov    r13,rsi
 e5d:	mov    QWORD PTR [rsp+0x8],rdx
 e62:	mov    rbx,rdx
 e65:	mov    rsi,r13
 e68:	mov    rdi,r12
 e6b:	call   e70 <botlish_fn_6+0x54>
			e6c: R_X86_64_PLT32	rt_list_len-0x4
 e70:	sar    rax,1
 e73:	test   rax,rax
 e76:	je     f28 <botlish_fn_6+0x10c>
 e7c:	mov    QWORD PTR [rsp+0x10],0x1
 e85:	mov    rax,QWORD PTR [rbx+0x8]
 e89:	test   rax,rax
 e8c:	jne    eb3 <botlish_fn_6+0x97>
 e92:	mov    edx,0x1
 e97:	mov    rsi,rbx
 e9a:	mov    rdi,r12
 e9d:	call   ea2 <botlish_fn_6+0x86>
			e9e: R_X86_64_PLT32	rt_list_get-0x4
 ea2:	test   rax,rax
 ea5:	je     f3f <botlish_fn_6+0x123>
 eab:	mov    rsi,rax
 eae:	jmp    ebd <botlish_fn_6+0xa1>
 eb3:	mov    rdx,rbx
 eb6:	mov    rax,QWORD PTR [rdx+0x10]
 eba:	mov    rsi,QWORD PTR [rax]
 ebd:	mov    rdi,r12
 ec0:	call   ec5 <botlish_fn_6+0xa9>
			ec1: R_X86_64_PLT32	rt_list_len-0x4
 ec5:	mov    QWORD PTR [rsp+0x18],rax
 eca:	mov    r14,rax
 ecd:	xor    rdx,rdx
 ed0:	mov    rdi,r12
 ed3:	mov    rsi,rdx
 ed6:	call   edb <botlish_fn_6+0xbf>
			ed7: R_X86_64_PLT32	rt_list_new-0x4
 edb:	test   rax,rax
 ede:	je     f3f <botlish_fn_6+0x123>
 ee4:	mov    QWORD PTR [rsp+0x20],rax
 ee9:	mov    r9,rax
 eec:	mov    ecx,0x1
 ef1:	mov    rdx,rbx
 ef4:	mov    rsi,r13
 ef7:	mov    rdi,r12
 efa:	mov    r8,r14
 efd:	call   f02 <botlish_fn_6+0xe6>
			efe: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
 f02:	test   rax,rax
 f05:	je     f3f <botlish_fn_6+0x123>
 f0b:	mov    rbx,QWORD PTR [rsp+0x30]
 f10:	mov    r12,QWORD PTR [rsp+0x38]
 f15:	mov    r13,QWORD PTR [rsp+0x40]
 f1a:	mov    r14,QWORD PTR [rsp+0x48]
 f1f:	add    rsp,0x50
 f23:	mov    rsp,rbp
 f26:	pop    rbp
 f27:	ret
 f28:	xor    rdx,rdx
 f2b:	mov    rdi,r12
 f2e:	mov    rsi,rdx
 f31:	call   f36 <botlish_fn_6+0x11a>
			f32: R_X86_64_PLT32	rt_list_new-0x4
 f36:	test   rax,rax
 f39:	jne    f5f <botlish_fn_6+0x143>
 f3f:	xor    rax,rax
 f42:	mov    rbx,QWORD PTR [rsp+0x30]
 f47:	mov    r12,QWORD PTR [rsp+0x38]
 f4c:	mov    r13,QWORD PTR [rsp+0x40]
 f51:	mov    r14,QWORD PTR [rsp+0x48]
 f56:	add    rsp,0x50
 f5a:	mov    rsp,rbp
 f5d:	pop    rbp
 f5e:	ret
 f5f:	mov    rbx,QWORD PTR [rsp+0x30]
 f64:	mov    r12,QWORD PTR [rsp+0x38]
 f69:	mov    r13,QWORD PTR [rsp+0x40]
 f6e:	mov    r14,QWORD PTR [rsp+0x48]
 f73:	add    rsp,0x50
 f77:	mov    rsp,rbp
 f7a:	pop    rbp
 f7b:	ret

0000000000000f7c <botlish_entry_6: matmul<List[List[int]], List[List[int]]>>:
 f7c:	push   rbp
 f7d:	mov    rbp,rsp
 f80:	mov    rsi,QWORD PTR [rdx]
 f83:	mov    rdx,QWORD PTR [rdx+0x8]
 f87:	call   f8c <botlish_entry_6+0x10>
			f88: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<List[List[int]], List[List[int]]>
 f8c:	mov    rsp,rbp
 f8f:	pop    rbp
 f90:	ret

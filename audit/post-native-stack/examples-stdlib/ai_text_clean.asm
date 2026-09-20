; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3056  (per function: 505 994 714 736 107)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> cleaner_emoji<str>
;   botlish_fn_2 / botlish_entry_2 -> clean_char<str>
;   botlish_fn_3 / botlish_entry_3 -> clean_from<str, int, str>
;   botlish_fn_4 / botlish_entry_4 -> clean_ai_text<str>


ai_text_clean.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0xa0
   b:	mov    QWORD PTR [rsp+0x70],rbx
  10:	mov    QWORD PTR [rsp+0x78],r12
  15:	mov    QWORD PTR [rsp+0x80],r13
  1d:	mov    QWORD PTR [rsp+0x88],r14
  25:	mov    QWORD PTR [rsp+0x90],r15
  2d:	mov    QWORD PTR [rsp+0x8],0x0
  36:	mov    QWORD PTR [rsp+0x10],0x0
  3f:	mov    QWORD PTR [rsp+0x18],0x0
  48:	mov    QWORD PTR [rsp+0x20],0x0
  51:	mov    QWORD PTR [rsp+0x28],0x0
  5a:	mov    rax,QWORD PTR [rdi+0x10]
  5e:	mov    rbx,rdi
  61:	mov    rsi,QWORD PTR [rax]
  64:	mov    QWORD PTR [rsp],rsi
  68:	call   6d <botlish_fn_0+0x6d>
			69: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  6d:	test   rax,rax
  70:	je     184 <botlish_fn_0+0x184>
  76:	mov    QWORD PTR [rsp],rax
  7a:	mov    rdi,rbx
  7d:	mov    r12,rax
  80:	mov    rax,QWORD PTR [rdi+0x10]
  84:	mov    rsi,QWORD PTR [rax+0x8]
  88:	mov    QWORD PTR [rsp+0x8],rsi
  8d:	call   92 <botlish_fn_0+0x92>
			8e: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  92:	test   rax,rax
  95:	je     184 <botlish_fn_0+0x184>
  9b:	mov    QWORD PTR [rsp+0x8],rax
  a0:	mov    rdi,rbx
  a3:	mov    r13,rax
  a6:	mov    rax,QWORD PTR [rdi+0x10]
  aa:	mov    rsi,QWORD PTR [rax+0x10]
  ae:	mov    QWORD PTR [rsp+0x10],rsi
  b3:	call   b8 <botlish_fn_0+0xb8>
			b4: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  b8:	test   rax,rax
  bb:	je     184 <botlish_fn_0+0x184>
  c1:	mov    QWORD PTR [rsp+0x10],rax
  c6:	mov    rdi,rbx
  c9:	mov    r14,rax
  cc:	mov    rax,QWORD PTR [rdi+0x10]
  d0:	mov    rsi,QWORD PTR [rax+0x18]
  d4:	mov    QWORD PTR [rsp+0x18],rsi
  d9:	call   de <botlish_fn_0+0xde>
			da: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  de:	test   rax,rax
  e1:	je     184 <botlish_fn_0+0x184>
  e7:	mov    QWORD PTR [rsp+0x18],rax
  ec:	mov    rdi,rbx
  ef:	mov    r15,rax
  f2:	mov    rax,QWORD PTR [rdi+0x10]
  f6:	mov    rsi,QWORD PTR [rax+0x20]
  fa:	mov    QWORD PTR [rsp+0x20],rsi
  ff:	call   104 <botlish_fn_0+0x104>
			100: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 104:	test   rax,rax
 107:	je     184 <botlish_fn_0+0x184>
 10d:	mov    QWORD PTR [rsp+0x20],rax
 112:	mov    rdi,rbx
 115:	mov    QWORD PTR [rsp+0x60],rax
 11a:	mov    rax,QWORD PTR [rdi+0x10]
 11e:	mov    rsi,QWORD PTR [rax+0x28]
 122:	mov    QWORD PTR [rsp+0x28],rsi
 127:	call   12c <botlish_fn_0+0x12c>
			128: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 12c:	test   rax,rax
 12f:	je     184 <botlish_fn_0+0x184>
 135:	mov    QWORD PTR [rsp+0x28],rax
 13a:	lea    rdx,[rsp+0x30]
 13f:	mov    rcx,r12
 142:	mov    QWORD PTR [rsp+0x30],rcx
 147:	mov    rcx,r13
 14a:	mov    QWORD PTR [rsp+0x38],rcx
 14f:	mov    rcx,r14
 152:	mov    QWORD PTR [rsp+0x40],rcx
 157:	mov    rcx,r15
 15a:	mov    QWORD PTR [rsp+0x48],rcx
 15f:	mov    rcx,QWORD PTR [rsp+0x60]
 164:	mov    QWORD PTR [rsp+0x50],rcx
 169:	mov    QWORD PTR [rsp+0x58],rax
 16e:	mov    esi,0x6
 173:	mov    rdi,rbx
 176:	call   17b <botlish_fn_0+0x17b>
			177: R_X86_64_PLT32	rt_list_new-0x4
 17b:	test   rax,rax
 17e:	jne    1b5 <botlish_fn_0+0x1b5>
 184:	xor    rax,rax
 187:	mov    rbx,QWORD PTR [rsp+0x70]
 18c:	mov    r12,QWORD PTR [rsp+0x78]
 191:	mov    r13,QWORD PTR [rsp+0x80]
 199:	mov    r14,QWORD PTR [rsp+0x88]
 1a1:	mov    r15,QWORD PTR [rsp+0x90]
 1a9:	add    rsp,0xa0
 1b0:	mov    rsp,rbp
 1b3:	pop    rbp
 1b4:	ret
 1b5:	mov    rbx,QWORD PTR [rsp+0x70]
 1ba:	mov    r12,QWORD PTR [rsp+0x78]
 1bf:	mov    r13,QWORD PTR [rsp+0x80]
 1c7:	mov    r14,QWORD PTR [rsp+0x88]
 1cf:	mov    r15,QWORD PTR [rsp+0x90]
 1d7:	add    rsp,0xa0
 1de:	mov    rsp,rbp
 1e1:	pop    rbp
 1e2:	ret

00000000000001e3 <botlish_entry_0: <program entry>>:
 1e3:	push   rbp
 1e4:	mov    rbp,rsp
 1e7:	call   1ec <botlish_entry_0+0x9>
			1e8: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 1ec:	mov    rsp,rbp
 1ef:	pop    rbp
 1f0:	ret

00000000000001f1 <botlish_fn_1: cleaner_emoji<str>>:
 1f1:	push   rbp
 1f2:	mov    rbp,rsp
 1f5:	sub    rsp,0x10
 1f9:	mov    QWORD PTR [rsp],rbx
 1fd:	mov    QWORD PTR [rsp+0x8],r12
 202:	mov    r12,rsi
 205:	mov    rax,QWORD PTR [rdi+0x10]
 209:	mov    rsi,QWORD PTR [rax+0x30]
 20d:	mov    edx,0x1
 212:	mov    ecx,0x3
 217:	mov    rbx,rdi
 21a:	mov    r8,r12
 21d:	call   222 <botlish_fn_1+0x31>
			21e: R_X86_64_PLT32	rt_str_region_eq-0x4
 222:	cmp    rax,0x6
 226:	je     267 <botlish_fn_1+0x76>
 22c:	mov    rax,QWORD PTR [rbx+0x10]
 230:	mov    rsi,QWORD PTR [rax+0x38]
 234:	mov    edx,0x1
 239:	mov    ecx,0x3
 23e:	mov    rdi,rbx
 241:	mov    r8,r12
 244:	call   249 <botlish_fn_1+0x58>
			245: R_X86_64_PLT32	rt_str_region_eq-0x4
 249:	cmp    rax,0x6
 24d:	je     25d <botlish_fn_1+0x6c>
 253:	mov    ecx,0x2
 258:	jmp    26c <botlish_fn_1+0x7b>
 25d:	mov    ecx,0x6
 262:	jmp    26c <botlish_fn_1+0x7b>
 267:	mov    ecx,0x6
 26c:	cmp    rcx,0x6
 270:	je     2b1 <botlish_fn_1+0xc0>
 276:	mov    rdx,QWORD PTR [rbx+0x10]
 27a:	mov    rsi,QWORD PTR [rdx+0x40]
 27e:	mov    edx,0x1
 283:	mov    ecx,0x3
 288:	mov    rdi,rbx
 28b:	mov    r8,r12
 28e:	call   293 <botlish_fn_1+0xa2>
			28f: R_X86_64_PLT32	rt_str_region_eq-0x4
 293:	cmp    rax,0x6
 297:	je     2a7 <botlish_fn_1+0xb6>
 29d:	mov    ecx,0x2
 2a2:	jmp    2b6 <botlish_fn_1+0xc5>
 2a7:	mov    ecx,0x6
 2ac:	jmp    2b6 <botlish_fn_1+0xc5>
 2b1:	mov    ecx,0x6
 2b6:	cmp    rcx,0x6
 2ba:	je     2fb <botlish_fn_1+0x10a>
 2c0:	mov    r10,QWORD PTR [rbx+0x10]
 2c4:	mov    rsi,QWORD PTR [r10+0x48]
 2c8:	mov    edx,0x1
 2cd:	mov    ecx,0x3
 2d2:	mov    rdi,rbx
 2d5:	mov    r8,r12
 2d8:	call   2dd <botlish_fn_1+0xec>
			2d9: R_X86_64_PLT32	rt_str_region_eq-0x4
 2dd:	cmp    rax,0x6
 2e1:	je     2f1 <botlish_fn_1+0x100>
 2e7:	mov    ecx,0x2
 2ec:	jmp    300 <botlish_fn_1+0x10f>
 2f1:	mov    ecx,0x6
 2f6:	jmp    300 <botlish_fn_1+0x10f>
 2fb:	mov    ecx,0x6
 300:	cmp    rcx,0x6
 304:	je     347 <botlish_fn_1+0x156>
 30a:	mov    rax,QWORD PTR [rbx+0x10]
 30e:	mov    rsi,QWORD PTR [rax+0x50]
 312:	mov    edx,0x1
 317:	mov    ecx,0x3
 31c:	mov    rdi,rbx
 31f:	mov    r8,r12
 322:	call   327 <botlish_fn_1+0x136>
			323: R_X86_64_PLT32	rt_str_region_eq-0x4
 327:	cmp    rax,0x6
 32b:	je     33c <botlish_fn_1+0x14b>
 331:	mov    r10d,0x2
 337:	jmp    34d <botlish_fn_1+0x15c>
 33c:	mov    r10d,0x6
 342:	jmp    34d <botlish_fn_1+0x15c>
 347:	mov    r10d,0x6
 34d:	cmp    r10,0x6
 351:	je     392 <botlish_fn_1+0x1a1>
 357:	mov    rax,QWORD PTR [rbx+0x10]
 35b:	mov    rsi,QWORD PTR [rax+0x58]
 35f:	mov    edx,0x1
 364:	mov    ecx,0x3
 369:	mov    rdi,rbx
 36c:	mov    r8,r12
 36f:	call   374 <botlish_fn_1+0x183>
			370: R_X86_64_PLT32	rt_str_region_eq-0x4
 374:	cmp    rax,0x6
 378:	je     388 <botlish_fn_1+0x197>
 37e:	mov    ecx,0x2
 383:	jmp    397 <botlish_fn_1+0x1a6>
 388:	mov    ecx,0x6
 38d:	jmp    397 <botlish_fn_1+0x1a6>
 392:	mov    ecx,0x6
 397:	cmp    rcx,0x6
 39b:	je     3dc <botlish_fn_1+0x1eb>
 3a1:	mov    rax,QWORD PTR [rbx+0x10]
 3a5:	mov    rsi,QWORD PTR [rax+0x60]
 3a9:	mov    edx,0x1
 3ae:	mov    ecx,0x3
 3b3:	mov    rdi,rbx
 3b6:	mov    r8,r12
 3b9:	call   3be <botlish_fn_1+0x1cd>
			3ba: R_X86_64_PLT32	rt_str_region_eq-0x4
 3be:	cmp    rax,0x6
 3c2:	je     3d2 <botlish_fn_1+0x1e1>
 3c8:	mov    ecx,0x2
 3cd:	jmp    3e1 <botlish_fn_1+0x1f0>
 3d2:	mov    ecx,0x6
 3d7:	jmp    3e1 <botlish_fn_1+0x1f0>
 3dc:	mov    ecx,0x6
 3e1:	cmp    rcx,0x6
 3e5:	je     426 <botlish_fn_1+0x235>
 3eb:	mov    rax,QWORD PTR [rbx+0x10]
 3ef:	mov    rsi,QWORD PTR [rax+0x68]
 3f3:	mov    edx,0x1
 3f8:	mov    ecx,0x3
 3fd:	mov    rdi,rbx
 400:	mov    r8,r12
 403:	call   408 <botlish_fn_1+0x217>
			404: R_X86_64_PLT32	rt_str_region_eq-0x4
 408:	cmp    rax,0x6
 40c:	je     41c <botlish_fn_1+0x22b>
 412:	mov    ecx,0x2
 417:	jmp    42b <botlish_fn_1+0x23a>
 41c:	mov    ecx,0x6
 421:	jmp    42b <botlish_fn_1+0x23a>
 426:	mov    ecx,0x6
 42b:	cmp    rcx,0x6
 42f:	je     470 <botlish_fn_1+0x27f>
 435:	mov    rax,QWORD PTR [rbx+0x10]
 439:	mov    rsi,QWORD PTR [rax+0x70]
 43d:	mov    edx,0x1
 442:	mov    ecx,0x3
 447:	mov    rdi,rbx
 44a:	mov    r8,r12
 44d:	call   452 <botlish_fn_1+0x261>
			44e: R_X86_64_PLT32	rt_str_region_eq-0x4
 452:	cmp    rax,0x6
 456:	je     466 <botlish_fn_1+0x275>
 45c:	mov    ecx,0x2
 461:	jmp    475 <botlish_fn_1+0x284>
 466:	mov    ecx,0x6
 46b:	jmp    475 <botlish_fn_1+0x284>
 470:	mov    ecx,0x6
 475:	cmp    rcx,0x6
 479:	je     4ba <botlish_fn_1+0x2c9>
 47f:	mov    rax,QWORD PTR [rbx+0x10]
 483:	mov    rsi,QWORD PTR [rax+0x78]
 487:	mov    edx,0x1
 48c:	mov    ecx,0x3
 491:	mov    rdi,rbx
 494:	mov    r8,r12
 497:	call   49c <botlish_fn_1+0x2ab>
			498: R_X86_64_PLT32	rt_str_region_eq-0x4
 49c:	cmp    rax,0x6
 4a0:	je     4b0 <botlish_fn_1+0x2bf>
 4a6:	mov    ecx,0x2
 4ab:	jmp    4bf <botlish_fn_1+0x2ce>
 4b0:	mov    ecx,0x6
 4b5:	jmp    4bf <botlish_fn_1+0x2ce>
 4ba:	mov    ecx,0x6
 4bf:	cmp    rcx,0x6
 4c3:	je     507 <botlish_fn_1+0x316>
 4c9:	mov    rsi,QWORD PTR [rbx+0x10]
 4cd:	mov    rsi,QWORD PTR [rsi+0x80]
 4d4:	mov    edx,0x1
 4d9:	mov    ecx,0x3
 4de:	mov    rdi,rbx
 4e1:	mov    r8,r12
 4e4:	call   4e9 <botlish_fn_1+0x2f8>
			4e5: R_X86_64_PLT32	rt_str_region_eq-0x4
 4e9:	cmp    rax,0x6
 4ed:	je     4fd <botlish_fn_1+0x30c>
 4f3:	mov    ecx,0x2
 4f8:	jmp    50c <botlish_fn_1+0x31b>
 4fd:	mov    ecx,0x6
 502:	jmp    50c <botlish_fn_1+0x31b>
 507:	mov    ecx,0x6
 50c:	cmp    rcx,0x6
 510:	je     554 <botlish_fn_1+0x363>
 516:	mov    r11,QWORD PTR [rbx+0x10]
 51a:	mov    rsi,QWORD PTR [r11+0x88]
 521:	mov    edx,0x1
 526:	mov    ecx,0x3
 52b:	mov    rdi,rbx
 52e:	mov    r8,r12
 531:	call   536 <botlish_fn_1+0x345>
			532: R_X86_64_PLT32	rt_str_region_eq-0x4
 536:	cmp    rax,0x6
 53a:	je     54a <botlish_fn_1+0x359>
 540:	mov    eax,0x2
 545:	jmp    559 <botlish_fn_1+0x368>
 54a:	mov    eax,0x6
 54f:	jmp    559 <botlish_fn_1+0x368>
 554:	mov    eax,0x6
 559:	mov    rbx,QWORD PTR [rsp]
 55d:	mov    r12,QWORD PTR [rsp+0x8]
 562:	add    rsp,0x10
 566:	mov    rsp,rbp
 569:	pop    rbp
 56a:	ret

000000000000056b <botlish_entry_1: cleaner_emoji<str>>:
 56b:	push   rbp
 56c:	mov    rbp,rsp
 56f:	mov    rsi,QWORD PTR [rdx]
 572:	call   577 <botlish_entry_1+0xc>
			573: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 577:	mov    rsp,rbp
 57a:	pop    rbp
 57b:	ret

000000000000057c <botlish_fn_2: clean_char<str>>:
 57c:	push   rbp
 57d:	mov    rbp,rsp
 580:	sub    rsp,0x20
 584:	mov    QWORD PTR [rsp+0x10],rbx
 589:	mov    QWORD PTR [rsp+0x18],r12
 58e:	mov    QWORD PTR [rsp],rsi
 592:	mov    rbx,rsi
 595:	mov    r12,rdi
 598:	mov    rsi,rbx
 59b:	call   5a0 <botlish_fn_2+0x24>
			59c: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 5a0:	test   rax,rax
 5a3:	jne    5bf <botlish_fn_2+0x43>
 5a9:	xor    rax,rax
 5ac:	mov    rbx,QWORD PTR [rsp+0x10]
 5b1:	mov    r12,QWORD PTR [rsp+0x18]
 5b6:	add    rsp,0x20
 5ba:	mov    rsp,rbp
 5bd:	pop    rbp
 5be:	ret
 5bf:	cmp    rax,0x6
 5c3:	je     7f1 <botlish_fn_2+0x275>
 5c9:	mov    r10,QWORD PTR [r12+0x10]
 5ce:	mov    rsi,QWORD PTR [r10+0x98]
 5d5:	mov    edx,0x1
 5da:	mov    ecx,0x3
 5df:	mov    rdi,r12
 5e2:	mov    r8,rbx
 5e5:	call   5ea <botlish_fn_2+0x6e>
			5e6: R_X86_64_PLT32	rt_str_region_eq-0x4
 5ea:	cmp    rax,0x6
 5ee:	je     633 <botlish_fn_2+0xb7>
 5f4:	mov    rax,QWORD PTR [r12+0x10]
 5f9:	mov    rsi,QWORD PTR [rax+0xa0]
 600:	mov    edx,0x1
 605:	mov    ecx,0x3
 60a:	mov    rdi,r12
 60d:	mov    r8,rbx
 610:	call   615 <botlish_fn_2+0x99>
			611: R_X86_64_PLT32	rt_str_region_eq-0x4
 615:	cmp    rax,0x6
 619:	je     629 <botlish_fn_2+0xad>
 61f:	mov    ecx,0x2
 624:	jmp    638 <botlish_fn_2+0xbc>
 629:	mov    ecx,0x6
 62e:	jmp    638 <botlish_fn_2+0xbc>
 633:	mov    ecx,0x6
 638:	cmp    rcx,0x6
 63c:	je     7d2 <botlish_fn_2+0x256>
 642:	mov    rax,QWORD PTR [r12+0x10]
 647:	mov    rsi,QWORD PTR [rax+0xb0]
 64e:	mov    edx,0x1
 653:	mov    ecx,0x3
 658:	mov    rdi,r12
 65b:	mov    r8,rbx
 65e:	call   663 <botlish_fn_2+0xe7>
			65f: R_X86_64_PLT32	rt_str_region_eq-0x4
 663:	cmp    rax,0x6
 667:	je     6ac <botlish_fn_2+0x130>
 66d:	mov    rax,QWORD PTR [r12+0x10]
 672:	mov    rsi,QWORD PTR [rax+0xb8]
 679:	mov    edx,0x1
 67e:	mov    ecx,0x3
 683:	mov    rdi,r12
 686:	mov    r8,rbx
 689:	call   68e <botlish_fn_2+0x112>
			68a: R_X86_64_PLT32	rt_str_region_eq-0x4
 68e:	cmp    rax,0x6
 692:	je     6a2 <botlish_fn_2+0x126>
 698:	mov    ecx,0x2
 69d:	jmp    6b1 <botlish_fn_2+0x135>
 6a2:	mov    ecx,0x6
 6a7:	jmp    6b1 <botlish_fn_2+0x135>
 6ac:	mov    ecx,0x6
 6b1:	cmp    rcx,0x6
 6b5:	je     7b3 <botlish_fn_2+0x237>
 6bb:	mov    rax,QWORD PTR [r12+0x10]
 6c0:	mov    rsi,QWORD PTR [rax+0xc8]
 6c7:	mov    edx,0x1
 6cc:	mov    ecx,0x3
 6d1:	mov    rdi,r12
 6d4:	mov    r8,rbx
 6d7:	call   6dc <botlish_fn_2+0x160>
			6d8: R_X86_64_PLT32	rt_str_region_eq-0x4
 6dc:	cmp    rax,0x6
 6e0:	je     725 <botlish_fn_2+0x1a9>
 6e6:	mov    rax,QWORD PTR [r12+0x10]
 6eb:	mov    rsi,QWORD PTR [rax+0xd0]
 6f2:	mov    edx,0x1
 6f7:	mov    ecx,0x3
 6fc:	mov    rdi,r12
 6ff:	mov    r8,rbx
 702:	call   707 <botlish_fn_2+0x18b>
			703: R_X86_64_PLT32	rt_str_region_eq-0x4
 707:	cmp    rax,0x6
 70b:	je     71b <botlish_fn_2+0x19f>
 711:	mov    ecx,0x2
 716:	jmp    72a <botlish_fn_2+0x1ae>
 71b:	mov    ecx,0x6
 720:	jmp    72a <botlish_fn_2+0x1ae>
 725:	mov    ecx,0x6
 72a:	cmp    rcx,0x6
 72e:	je     794 <botlish_fn_2+0x218>
 734:	mov    rax,QWORD PTR [r12+0x10]
 739:	mov    rsi,QWORD PTR [rax+0xe0]
 740:	mov    edx,0x1
 745:	mov    ecx,0x3
 74a:	mov    rdi,r12
 74d:	mov    r8,rbx
 750:	call   755 <botlish_fn_2+0x1d9>
			751: R_X86_64_PLT32	rt_str_region_eq-0x4
 755:	cmp    rax,0x6
 759:	je     775 <botlish_fn_2+0x1f9>
 75f:	mov    rax,rbx
 762:	mov    rbx,QWORD PTR [rsp+0x10]
 767:	mov    r12,QWORD PTR [rsp+0x18]
 76c:	add    rsp,0x20
 770:	mov    rsp,rbp
 773:	pop    rbp
 774:	ret
 775:	mov    rax,QWORD PTR [r12+0x10]
 77a:	mov    rax,QWORD PTR [rax+0xe8]
 781:	mov    rbx,QWORD PTR [rsp+0x10]
 786:	mov    r12,QWORD PTR [rsp+0x18]
 78b:	add    rsp,0x20
 78f:	mov    rsp,rbp
 792:	pop    rbp
 793:	ret
 794:	mov    rax,QWORD PTR [r12+0x10]
 799:	mov    rax,QWORD PTR [rax+0xd8]
 7a0:	mov    rbx,QWORD PTR [rsp+0x10]
 7a5:	mov    r12,QWORD PTR [rsp+0x18]
 7aa:	add    rsp,0x20
 7ae:	mov    rsp,rbp
 7b1:	pop    rbp
 7b2:	ret
 7b3:	mov    rax,QWORD PTR [r12+0x10]
 7b8:	mov    rax,QWORD PTR [rax+0xc0]
 7bf:	mov    rbx,QWORD PTR [rsp+0x10]
 7c4:	mov    r12,QWORD PTR [rsp+0x18]
 7c9:	add    rsp,0x20
 7cd:	mov    rsp,rbp
 7d0:	pop    rbp
 7d1:	ret
 7d2:	mov    rax,QWORD PTR [r12+0x10]
 7d7:	mov    rax,QWORD PTR [rax+0xa8]
 7de:	mov    rbx,QWORD PTR [rsp+0x10]
 7e3:	mov    r12,QWORD PTR [rsp+0x18]
 7e8:	add    rsp,0x20
 7ec:	mov    rsp,rbp
 7ef:	pop    rbp
 7f0:	ret
 7f1:	mov    rax,QWORD PTR [r12+0x10]
 7f6:	mov    rax,QWORD PTR [rax+0x90]
 7fd:	mov    rbx,QWORD PTR [rsp+0x10]
 802:	mov    r12,QWORD PTR [rsp+0x18]
 807:	add    rsp,0x20
 80b:	mov    rsp,rbp
 80e:	pop    rbp
 80f:	ret

0000000000000810 <botlish_entry_2: clean_char<str>>:
 810:	push   rbp
 811:	mov    rbp,rsp
 814:	mov    rsi,QWORD PTR [rdx]
 817:	call   81c <botlish_entry_2+0xc>
			818: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 81c:	mov    rsp,rbp
 81f:	pop    rbp
 820:	ret
 821:	add    BYTE PTR [rax],al
 823:	add    BYTE PTR [rax],al
 825:	add    BYTE PTR [rax],al
	...

0000000000000828 <botlish_fn_3: clean_from<str, int, str>>:
 828:	push   rbp
 829:	mov    rbp,rsp
 82c:	sub    rsp,0x70
 830:	mov    QWORD PTR [rsp+0x40],rbx
 835:	mov    QWORD PTR [rsp+0x48],r12
 83a:	mov    QWORD PTR [rsp+0x50],r13
 83f:	mov    QWORD PTR [rsp+0x58],r14
 844:	mov    QWORD PTR [rsp+0x60],r15
 849:	mov    QWORD PTR [rsp+0x20],0x0
 852:	mov    QWORD PTR [rsp+0x28],0x0
 85b:	mov    QWORD PTR [rsp],rsi
 85f:	mov    QWORD PTR [rsp+0x8],rcx
 864:	mov    QWORD PTR [rsp+0x10],r8
 869:	mov    rbx,rsi
 86c:	mov    r13,rdi
 86f:	mov    r14,r8
 872:	mov    r15,rcx
 875:	mov    QWORD PTR [rsp+0x30],rdx
 87a:	mov    rsi,rbx
 87d:	mov    rdi,r13
 880:	call   885 <botlish_fn_3+0x5d>
			881: R_X86_64_PLT32	rt_str_len-0x4
 885:	mov    rsi,QWORD PTR [rsp+0x30]
 88a:	mov    rcx,rsi
 88d:	and    rcx,rax
 890:	mov    rdx,rax
 893:	test   rcx,0x1
 89a:	jne    8c2 <botlish_fn_3+0x9a>
 8a0:	mov    rsi,QWORD PTR [rsp+0x30]
 8a5:	mov    rdi,r13
 8a8:	call   8ad <botlish_fn_3+0x85>
			8a9: R_X86_64_PLT32	rt_int_cmp-0x4
 8ad:	mov    ecx,0x2
 8b2:	test   rax,rax
 8b5:	cmovge rcx,QWORD PTR [rip+0x1fb]        # ab8 <botlish_fn_3+0x290>
 8bd:	jmp    8d7 <botlish_fn_3+0xaf>
 8c2:	mov    ecx,0x2
 8c7:	mov    rsi,QWORD PTR [rsp+0x30]
 8cc:	cmp    rsi,rdx
 8cf:	cmovge rcx,QWORD PTR [rip+0x1e1]        # ab8 <botlish_fn_3+0x290>
 8d7:	cmp    rcx,0x6
 8db:	je     a8d <botlish_fn_3+0x265>
 8e1:	mov    rsi,QWORD PTR [rsp+0x30]
 8e6:	mov    rax,rsi
 8e9:	sar    rax,1
 8ec:	lea    r12,[rax+0x1]
 8f0:	shl    r12,1
 8f3:	or     r12,0x1
 8f7:	mov    QWORD PTR [rsp+0x18],r12
 8fc:	mov    rsi,rbx
 8ff:	mov    rdi,r13
 902:	call   907 <botlish_fn_3+0xdf>
			903: R_X86_64_PLT32	rt_str_len-0x4
 907:	mov    rsi,QWORD PTR [rsp+0x30]
 90c:	mov    rcx,rsi
 90f:	and    rcx,rax
 912:	mov    rdx,rax
 915:	test   rcx,0x1
 91c:	jne    944 <botlish_fn_3+0x11c>
 922:	mov    rsi,QWORD PTR [rsp+0x30]
 927:	mov    rdi,r13
 92a:	call   92f <botlish_fn_3+0x107>
			92b: R_X86_64_PLT32	rt_int_cmp-0x4
 92f:	mov    ecx,0x2
 934:	test   rax,rax
 937:	cmovge rcx,QWORD PTR [rip+0x179]        # ab8 <botlish_fn_3+0x290>
 93f:	jmp    959 <botlish_fn_3+0x131>
 944:	mov    ecx,0x2
 949:	mov    rsi,QWORD PTR [rsp+0x30]
 94e:	cmp    rsi,rdx
 951:	cmovge rcx,QWORD PTR [rip+0x15f]        # ab8 <botlish_fn_3+0x290>
 959:	cmp    rcx,0x6
 95d:	je     a05 <botlish_fn_3+0x1dd>
 963:	mov    rdx,r14
 966:	mov    rsi,rbx
 969:	mov    rdi,r13
 96c:	call   971 <botlish_fn_3+0x149>
			96d: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 971:	mov    QWORD PTR [rsp+0x20],rax
 976:	mov    QWORD PTR [rsp+0x30],rax
 97b:	mov    rsi,QWORD PTR [rsp+0x30]
 980:	mov    rdi,r13
 983:	call   988 <botlish_fn_3+0x160>
			984: R_X86_64_PLT32	rt_str_byte_len-0x4
 988:	mov    QWORD PTR [rsp+0x28],rax
 98d:	mov    rsi,r14
 990:	mov    rdi,rsi
 993:	and    rdi,rax
 996:	test   rdi,0x1
 99d:	jne    9ae <botlish_fn_3+0x186>
 9a3:	mov    rdx,rax
 9a6:	mov    rsi,r14
 9a9:	jmp    9e0 <botlish_fn_3+0x1b8>
 9ae:	lea    r10,[rax-0x1]
 9b2:	mov    rdx,rax
 9b5:	mov    rsi,r14
 9b8:	mov    r9,rsi
 9bb:	add    r9,r10
 9be:	seto   r11b
 9c2:	test   r11b,r11b
 9c5:	je     9d3 <botlish_fn_3+0x1ab>
 9cb:	mov    rsi,r14
 9ce:	jmp    9e0 <botlish_fn_3+0x1b8>
 9d3:	mov    rax,QWORD PTR [rsp+0x30]
 9d8:	mov    r14,r9
 9db:	jmp    9f0 <botlish_fn_3+0x1c8>
 9e0:	mov    rdi,r13
 9e3:	call   9e8 <botlish_fn_3+0x1c0>
			9e4: R_X86_64_PLT32	rt_int_add-0x4
 9e8:	mov    r14,rax
 9eb:	mov    rax,QWORD PTR [rsp+0x30]
 9f0:	mov    QWORD PTR [rsp+0x10],rax
 9f5:	mov    rsi,r14
 9f8:	mov    QWORD PTR [rsp+0x20],rsi
 9fd:	mov    rsi,rax
 a00:	jmp    a1d <botlish_fn_3+0x1f5>
 a05:	mov    rax,QWORD PTR [r13+0x10]
 a09:	mov    rsi,QWORD PTR [rax+0x90]
 a10:	mov    QWORD PTR [rsp+0x10],rsi
 a15:	mov    rax,r14
 a18:	mov    QWORD PTR [rsp+0x20],rax
 a1d:	mov    rdi,r13
 a20:	call   a25 <botlish_fn_3+0x1fd>
			a21: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 a25:	test   rax,rax
 a28:	je     a4a <botlish_fn_3+0x222>
 a2e:	mov    QWORD PTR [rsp+0x10],rax
 a33:	mov    rdx,rax
 a36:	mov    rsi,r15
 a39:	mov    rdi,r13
 a3c:	call   a41 <botlish_fn_3+0x219>
			a3d: R_X86_64_PLT32	rt_str_cat-0x4
 a41:	test   rax,rax
 a44:	jne    a6f <botlish_fn_3+0x247>
 a4a:	xor    rax,rax
 a4d:	mov    rbx,QWORD PTR [rsp+0x40]
 a52:	mov    r12,QWORD PTR [rsp+0x48]
 a57:	mov    r13,QWORD PTR [rsp+0x50]
 a5c:	mov    r14,QWORD PTR [rsp+0x58]
 a61:	mov    r15,QWORD PTR [rsp+0x60]
 a66:	add    rsp,0x70
 a6a:	mov    rsp,rbp
 a6d:	pop    rbp
 a6e:	ret
 a6f:	mov    QWORD PTR [rsp],rbx
 a73:	mov    QWORD PTR [rsp+0x8],rax
 a78:	mov    rsi,r14
 a7b:	mov    QWORD PTR [rsp+0x10],rsi
 a80:	mov    r15,rax
 a83:	mov    QWORD PTR [rsp+0x30],r12
 a88:	jmp    87a <botlish_fn_3+0x52>
 a8d:	mov    rax,r15
 a90:	mov    rbx,QWORD PTR [rsp+0x40]
 a95:	mov    r12,QWORD PTR [rsp+0x48]
 a9a:	mov    r13,QWORD PTR [rsp+0x50]
 a9f:	mov    r14,QWORD PTR [rsp+0x58]
 aa4:	mov    r15,QWORD PTR [rsp+0x60]
 aa9:	add    rsp,0x70
 aad:	mov    rsp,rbp
 ab0:	pop    rbp
 ab1:	ret
 ab2:	add    BYTE PTR [rax],al
 ab4:	add    BYTE PTR [rax],al
 ab6:	add    BYTE PTR [rax],al
 ab8:	(bad)
 ab9:	add    BYTE PTR [rax],al
 abb:	add    BYTE PTR [rax],al
 abd:	add    BYTE PTR [rax],al
	...

0000000000000ac0 <botlish_entry_3: clean_from<str, int, str>>:
 ac0:	push   rbp
 ac1:	mov    rbp,rsp
 ac4:	mov    rsi,QWORD PTR [rdx]
 ac7:	mov    r9,QWORD PTR [rdx+0x8]
 acb:	mov    rcx,QWORD PTR [rdx+0x10]
 acf:	mov    r8,QWORD PTR [rdx+0x18]
 ad3:	mov    rdx,r9
 ad6:	call   adb <botlish_entry_3+0x1b>
			ad7: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 adb:	mov    rsp,rbp
 ade:	pop    rbp
 adf:	ret

0000000000000ae0 <botlish_fn_4: clean_ai_text<str>>:
 ae0:	push   rbp
 ae1:	mov    rbp,rsp
 ae4:	sub    rsp,0x20
 ae8:	mov    QWORD PTR [rsp],rsi
 aec:	mov    r8d,0x1
 af2:	mov    QWORD PTR [rsp+0x8],0x1
 afb:	mov    r11,QWORD PTR [rdi+0x10]
 aff:	mov    rcx,QWORD PTR [r11+0x90]
 b06:	mov    QWORD PTR [rsp+0x10],rcx
 b0b:	mov    QWORD PTR [rsp+0x18],0x1
 b14:	mov    rdx,r8
 b17:	call   b1c <botlish_fn_4+0x3c>
			b18: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 b1c:	test   rax,rax
 b1f:	jne    b31 <botlish_fn_4+0x51>
 b25:	xor    rax,rax
 b28:	add    rsp,0x20
 b2c:	mov    rsp,rbp
 b2f:	pop    rbp
 b30:	ret
 b31:	add    rsp,0x20
 b35:	mov    rsp,rbp
 b38:	pop    rbp
 b39:	ret

0000000000000b3a <botlish_entry_4: clean_ai_text<str>>:
 b3a:	push   rbp
 b3b:	mov    rbp,rsp
 b3e:	mov    rsi,QWORD PTR [rdx]
 b41:	call   b46 <botlish_entry_4+0xc>
			b42: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 b46:	mov    rsp,rbp
 b49:	pop    rbp
 b4a:	ret

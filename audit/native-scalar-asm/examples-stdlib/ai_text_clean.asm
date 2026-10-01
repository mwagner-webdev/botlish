; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3078  (per function: 505 994 723 758 98)
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
 580:	sub    rsp,0x10
 584:	mov    QWORD PTR [rsp],rbx
 588:	mov    QWORD PTR [rsp+0x8],r12
 58d:	mov    rbx,rsi
 590:	mov    r12,rdi
 593:	mov    rsi,rbx
 596:	call   59b <botlish_fn_2+0x1f>
			597: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 59b:	cmp    rax,0x6
 59f:	je     7c8 <botlish_fn_2+0x24c>
 5a5:	mov    rsi,QWORD PTR [r12+0x10]
 5aa:	mov    rsi,QWORD PTR [rsi+0x98]
 5b1:	mov    edx,0x1
 5b6:	mov    ecx,0x3
 5bb:	mov    rdi,r12
 5be:	mov    r8,rbx
 5c1:	call   5c6 <botlish_fn_2+0x4a>
			5c2: R_X86_64_PLT32	rt_str_region_eq-0x4
 5c6:	cmp    rax,0x6
 5ca:	je     60f <botlish_fn_2+0x93>
 5d0:	mov    rsi,QWORD PTR [r12+0x10]
 5d5:	mov    rsi,QWORD PTR [rsi+0xa0]
 5dc:	mov    edx,0x1
 5e1:	mov    ecx,0x3
 5e6:	mov    rdi,r12
 5e9:	mov    r8,rbx
 5ec:	call   5f1 <botlish_fn_2+0x75>
			5ed: R_X86_64_PLT32	rt_str_region_eq-0x4
 5f1:	cmp    rax,0x6
 5f5:	je     605 <botlish_fn_2+0x89>
 5fb:	mov    ecx,0x2
 600:	jmp    614 <botlish_fn_2+0x98>
 605:	mov    ecx,0x6
 60a:	jmp    614 <botlish_fn_2+0x98>
 60f:	mov    ecx,0x6
 614:	cmp    rcx,0x6
 618:	je     7aa <botlish_fn_2+0x22e>
 61e:	mov    rax,QWORD PTR [r12+0x10]
 623:	mov    rsi,QWORD PTR [rax+0xb0]
 62a:	mov    edx,0x1
 62f:	mov    ecx,0x3
 634:	mov    rdi,r12
 637:	mov    r8,rbx
 63a:	call   63f <botlish_fn_2+0xc3>
			63b: R_X86_64_PLT32	rt_str_region_eq-0x4
 63f:	cmp    rax,0x6
 643:	je     688 <botlish_fn_2+0x10c>
 649:	mov    rax,QWORD PTR [r12+0x10]
 64e:	mov    rsi,QWORD PTR [rax+0xb8]
 655:	mov    edx,0x1
 65a:	mov    ecx,0x3
 65f:	mov    rdi,r12
 662:	mov    r8,rbx
 665:	call   66a <botlish_fn_2+0xee>
			666: R_X86_64_PLT32	rt_str_region_eq-0x4
 66a:	cmp    rax,0x6
 66e:	je     67e <botlish_fn_2+0x102>
 674:	mov    ecx,0x2
 679:	jmp    68d <botlish_fn_2+0x111>
 67e:	mov    ecx,0x6
 683:	jmp    68d <botlish_fn_2+0x111>
 688:	mov    ecx,0x6
 68d:	cmp    rcx,0x6
 691:	je     78c <botlish_fn_2+0x210>
 697:	mov    rax,QWORD PTR [r12+0x10]
 69c:	mov    rsi,QWORD PTR [rax+0xc8]
 6a3:	mov    edx,0x1
 6a8:	mov    ecx,0x3
 6ad:	mov    rdi,r12
 6b0:	mov    r8,rbx
 6b3:	call   6b8 <botlish_fn_2+0x13c>
			6b4: R_X86_64_PLT32	rt_str_region_eq-0x4
 6b8:	cmp    rax,0x6
 6bc:	je     701 <botlish_fn_2+0x185>
 6c2:	mov    rax,QWORD PTR [r12+0x10]
 6c7:	mov    rsi,QWORD PTR [rax+0xd0]
 6ce:	mov    edx,0x1
 6d3:	mov    ecx,0x3
 6d8:	mov    rdi,r12
 6db:	mov    r8,rbx
 6de:	call   6e3 <botlish_fn_2+0x167>
			6df: R_X86_64_PLT32	rt_str_region_eq-0x4
 6e3:	cmp    rax,0x6
 6e7:	je     6f7 <botlish_fn_2+0x17b>
 6ed:	mov    ecx,0x2
 6f2:	jmp    706 <botlish_fn_2+0x18a>
 6f7:	mov    ecx,0x6
 6fc:	jmp    706 <botlish_fn_2+0x18a>
 701:	mov    ecx,0x6
 706:	cmp    rcx,0x6
 70a:	je     76e <botlish_fn_2+0x1f2>
 710:	mov    rax,QWORD PTR [r12+0x10]
 715:	mov    rsi,QWORD PTR [rax+0xe0]
 71c:	mov    edx,0x1
 721:	mov    ecx,0x3
 726:	mov    rdi,r12
 729:	mov    r8,rbx
 72c:	call   731 <botlish_fn_2+0x1b5>
			72d: R_X86_64_PLT32	rt_str_region_eq-0x4
 731:	cmp    rax,0x6
 735:	je     750 <botlish_fn_2+0x1d4>
 73b:	mov    rax,rbx
 73e:	mov    rbx,QWORD PTR [rsp]
 742:	mov    r12,QWORD PTR [rsp+0x8]
 747:	add    rsp,0x10
 74b:	mov    rsp,rbp
 74e:	pop    rbp
 74f:	ret
 750:	mov    rax,QWORD PTR [r12+0x10]
 755:	mov    rax,QWORD PTR [rax+0xe8]
 75c:	mov    rbx,QWORD PTR [rsp]
 760:	mov    r12,QWORD PTR [rsp+0x8]
 765:	add    rsp,0x10
 769:	mov    rsp,rbp
 76c:	pop    rbp
 76d:	ret
 76e:	mov    rax,QWORD PTR [r12+0x10]
 773:	mov    rax,QWORD PTR [rax+0xd8]
 77a:	mov    rbx,QWORD PTR [rsp]
 77e:	mov    r12,QWORD PTR [rsp+0x8]
 783:	add    rsp,0x10
 787:	mov    rsp,rbp
 78a:	pop    rbp
 78b:	ret
 78c:	mov    rax,QWORD PTR [r12+0x10]
 791:	mov    rax,QWORD PTR [rax+0xc0]
 798:	mov    rbx,QWORD PTR [rsp]
 79c:	mov    r12,QWORD PTR [rsp+0x8]
 7a1:	add    rsp,0x10
 7a5:	mov    rsp,rbp
 7a8:	pop    rbp
 7a9:	ret
 7aa:	mov    rax,QWORD PTR [r12+0x10]
 7af:	mov    rax,QWORD PTR [rax+0xa8]
 7b6:	mov    rbx,QWORD PTR [rsp]
 7ba:	mov    r12,QWORD PTR [rsp+0x8]
 7bf:	add    rsp,0x10
 7c3:	mov    rsp,rbp
 7c6:	pop    rbp
 7c7:	ret
 7c8:	mov    rax,QWORD PTR [r12+0x10]
 7cd:	mov    rax,QWORD PTR [rax+0x90]
 7d4:	mov    rbx,QWORD PTR [rsp]
 7d8:	mov    r12,QWORD PTR [rsp+0x8]
 7dd:	add    rsp,0x10
 7e1:	mov    rsp,rbp
 7e4:	pop    rbp
 7e5:	ret

00000000000007e6 <botlish_entry_2: clean_char<str>>:
 7e6:	push   rbp
 7e7:	mov    rbp,rsp
 7ea:	sub    rsp,0x10
 7ee:	mov    QWORD PTR [rsp],r12
 7f2:	mov    r12,rdi
 7f5:	mov    rsi,QWORD PTR [rdx]
 7f8:	call   7fd <botlish_entry_2+0x17>
			7f9: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 7fd:	mov    r8,QWORD PTR [rip+0x0]        # 804 <botlish_entry_2+0x1e>
			800: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
 804:	mov    rsi,rax
 807:	mov    rdi,r12
 80a:	call   r8
 80d:	mov    r12,QWORD PTR [rsp]
 811:	add    rsp,0x10
 815:	mov    rsp,rbp
 818:	pop    rbp
 819:	ret
 81a:	add    BYTE PTR [rax],al
 81c:	add    BYTE PTR [rax],al
	...

0000000000000820 <botlish_fn_3: clean_from<str, int, str>>:
 820:	push   rbp
 821:	mov    rbp,rsp
 824:	sub    rsp,0xa0
 82b:	mov    QWORD PTR [rsp+0x70],rbx
 830:	mov    QWORD PTR [rsp+0x78],r12
 835:	mov    QWORD PTR [rsp+0x80],r13
 83d:	mov    QWORD PTR [rsp+0x88],r14
 845:	mov    QWORD PTR [rsp+0x90],r15
 84d:	mov    r12,rdx
 850:	mov    r14,rdi
 853:	mov    QWORD PTR [rsp+0x18],0x0
 85c:	mov    QWORD PTR [rsp+0x20],0x0
 865:	mov    QWORD PTR [rsp],rsi
 869:	mov    QWORD PTR [rsp+0x8],rcx
 86e:	mov    r15,rcx
 871:	mov    QWORD PTR [rsp+0x10],r8
 876:	lea    r13,[rsp+0x38]
 87b:	mov    rbx,rsi
 87e:	mov    QWORD PTR [rsp+0x58],r8
 883:	mov    rsi,rbx
 886:	mov    rdi,r14
 889:	call   88e <botlish_fn_3+0x6e>
			88a: R_X86_64_PLT32	rt_str_len-0x4
 88e:	sar    rax,1
 891:	cmp    r12,rax
 894:	jge    a20 <botlish_fn_3+0x200>
 89a:	mov    rsi,rbx
 89d:	mov    rdi,r14
 8a0:	call   8a5 <botlish_fn_3+0x85>
			8a1: R_X86_64_PLT32	rt_str_len-0x4
 8a5:	mov    rsi,r12
 8a8:	shl    rsi,1
 8ab:	or     rsi,0x1
 8af:	mov    rcx,rsi
 8b2:	and    rcx,rax
 8b5:	mov    rdx,rax
 8b8:	test   rcx,0x1
 8bf:	jne    8e2 <botlish_fn_3+0xc2>
 8c5:	mov    rdi,r14
 8c8:	call   8cd <botlish_fn_3+0xad>
			8c9: R_X86_64_PLT32	rt_int_cmp-0x4
 8cd:	mov    ecx,0x2
 8d2:	test   rax,rax
 8d5:	cmovge rcx,QWORD PTR [rip+0x1db]        # ab8 <botlish_fn_3+0x298>
 8dd:	jmp    8f2 <botlish_fn_3+0xd2>
 8e2:	mov    ecx,0x2
 8e7:	cmp    rsi,rdx
 8ea:	cmovge rcx,QWORD PTR [rip+0x1c6]        # ab8 <botlish_fn_3+0x298>
 8f2:	cmp    rcx,0x6
 8f6:	je     99c <botlish_fn_3+0x17c>
 8fc:	mov    rdx,QWORD PTR [rsp+0x58]
 901:	mov    rsi,rbx
 904:	mov    rdi,r14
 907:	call   90c <botlish_fn_3+0xec>
			908: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 90c:	mov    QWORD PTR [rsp+0x18],rax
 911:	mov    QWORD PTR [rsp+0x60],rax
 916:	mov    rsi,QWORD PTR [rsp+0x60]
 91b:	mov    rdi,r14
 91e:	call   923 <botlish_fn_3+0x103>
			91f: R_X86_64_PLT32	rt_str_byte_len-0x4
 923:	mov    QWORD PTR [rsp+0x20],rax
 928:	mov    rsi,QWORD PTR [rsp+0x58]
 92d:	mov    rdx,rsi
 930:	and    rdx,rax
 933:	test   rdx,0x1
 93a:	jne    94d <botlish_fn_3+0x12d>
 940:	mov    rdx,rax
 943:	mov    rsi,QWORD PTR [rsp+0x58]
 948:	jmp    97d <botlish_fn_3+0x15d>
 94d:	lea    rdi,[rax-0x1]
 951:	mov    rdx,rax
 954:	mov    rsi,QWORD PTR [rsp+0x58]
 959:	add    rsi,rdi
 95c:	seto   dil
 960:	test   dil,dil
 963:	je     973 <botlish_fn_3+0x153>
 969:	mov    rsi,QWORD PTR [rsp+0x58]
 96e:	jmp    97d <botlish_fn_3+0x15d>
 973:	mov    QWORD PTR [rsp+0x58],rsi
 978:	jmp    98d <botlish_fn_3+0x16d>
 97d:	mov    rdi,r14
 980:	call   985 <botlish_fn_3+0x165>
			981: R_X86_64_PLT32	rt_int_add-0x4
 985:	mov    rsi,rax
 988:	mov    QWORD PTR [rsp+0x58],rax
 98d:	mov    QWORD PTR [rsp+0x10],rsi
 992:	mov    rsi,QWORD PTR [rsp+0x60]
 997:	jmp    9b4 <botlish_fn_3+0x194>
 99c:	mov    rdi,r14
 99f:	mov    rax,QWORD PTR [rdi+0x10]
 9a3:	mov    rsi,QWORD PTR [rax+0x90]
 9aa:	mov    rax,QWORD PTR [rsp+0x58]
 9af:	mov    QWORD PTR [rsp+0x10],rax
 9b4:	mov    rdi,r14
 9b7:	call   9bc <botlish_fn_3+0x19c>
			9b8: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 9bc:	mov    QWORD PTR [rsp+0x18],rax
 9c1:	mov    QWORD PTR [rsp+0x38],0x0
 9ca:	mov    rcx,r15
 9cd:	mov    QWORD PTR [rsp+0x40],rcx
 9d2:	mov    QWORD PTR [rsp+0x48],0x0
 9db:	mov    QWORD PTR [rsp+0x50],rax
 9e0:	mov    esi,0x2
 9e5:	mov    edx,0x4
 9ea:	mov    rcx,r13
 9ed:	mov    rdi,r14
 9f0:	call   9f5 <botlish_fn_3+0x1d5>
			9f1: R_X86_64_PLT32	rt_construct-0x4
 9f5:	test   rax,rax
 9f8:	je     a52 <botlish_fn_3+0x232>
 9fe:	mov    QWORD PTR [rsp],rbx
 a02:	mov    QWORD PTR [rsp+0x8],rax
 a07:	mov    rsi,QWORD PTR [rsp+0x58]
 a0c:	mov    QWORD PTR [rsp+0x10],rsi
 a11:	add    r12,0x1
 a18:	mov    r15,rax
 a1b:	jmp    883 <botlish_fn_3+0x63>
 a20:	mov    rcx,r15
 a23:	xor    rsi,rsi
 a26:	lea    rax,[rsp+0x28]
 a2b:	mov    QWORD PTR [rsp+0x28],0x0
 a34:	mov    QWORD PTR [rsp+0x30],rcx
 a39:	mov    edx,0x2
 a3e:	mov    rcx,rax
 a41:	mov    rdi,r14
 a44:	call   a49 <botlish_fn_3+0x229>
			a45: R_X86_64_PLT32	rt_construct-0x4
 a49:	test   rax,rax
 a4c:	jne    a83 <botlish_fn_3+0x263>
 a52:	xor    rax,rax
 a55:	mov    rbx,QWORD PTR [rsp+0x70]
 a5a:	mov    r12,QWORD PTR [rsp+0x78]
 a5f:	mov    r13,QWORD PTR [rsp+0x80]
 a67:	mov    r14,QWORD PTR [rsp+0x88]
 a6f:	mov    r15,QWORD PTR [rsp+0x90]
 a77:	add    rsp,0xa0
 a7e:	mov    rsp,rbp
 a81:	pop    rbp
 a82:	ret
 a83:	mov    rbx,QWORD PTR [rsp+0x70]
 a88:	mov    r12,QWORD PTR [rsp+0x78]
 a8d:	mov    r13,QWORD PTR [rsp+0x80]
 a95:	mov    r14,QWORD PTR [rsp+0x88]
 a9d:	mov    r15,QWORD PTR [rsp+0x90]
 aa5:	add    rsp,0xa0
 aac:	mov    rsp,rbp
 aaf:	pop    rbp
 ab0:	ret
 ab1:	add    BYTE PTR [rax],al
 ab3:	add    BYTE PTR [rax],al
 ab5:	add    BYTE PTR [rax],al
 ab7:	add    BYTE PTR [rsi],al
 ab9:	add    BYTE PTR [rax],al
 abb:	add    BYTE PTR [rax],al
 abd:	add    BYTE PTR [rax],al
	...

0000000000000ac0 <botlish_entry_3: clean_from<str, int, str>>:
 ac0:	push   rbp
 ac1:	mov    rbp,rsp
 ac4:	mov    rsi,QWORD PTR [rdx]
 ac7:	mov    r8,QWORD PTR [rdx+0x8]
 acb:	mov    r9,r8
 ace:	mov    rcx,QWORD PTR [rdx+0x10]
 ad2:	mov    r8,QWORD PTR [rdx+0x18]
 ad6:	mov    rdx,r9
 ad9:	sar    rdx,1
 adc:	call   ae1 <botlish_entry_3+0x21>
			add: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 ae1:	mov    rsp,rbp
 ae4:	pop    rbp
 ae5:	ret

0000000000000ae6 <botlish_fn_4: clean_ai_text<str>>:
 ae6:	push   rbp
 ae7:	mov    rbp,rsp
 aea:	sub    rsp,0x20
 aee:	mov    QWORD PTR [rsp],rsi
 af2:	mov    rax,QWORD PTR [rdi+0x10]
 af6:	mov    rcx,QWORD PTR [rax+0x90]
 afd:	mov    QWORD PTR [rsp+0x8],rcx
 b02:	mov    r8d,0x1
 b08:	mov    QWORD PTR [rsp+0x10],0x1
 b11:	xor    rdx,rdx
 b14:	call   b19 <botlish_fn_4+0x33>
			b15: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 b19:	test   rax,rax
 b1c:	jne    b2e <botlish_fn_4+0x48>
 b22:	xor    rax,rax
 b25:	add    rsp,0x20
 b29:	mov    rsp,rbp
 b2c:	pop    rbp
 b2d:	ret
 b2e:	add    rsp,0x20
 b32:	mov    rsp,rbp
 b35:	pop    rbp
 b36:	ret

0000000000000b37 <botlish_entry_4: clean_ai_text<str>>:
 b37:	push   rbp
 b38:	mov    rbp,rsp
 b3b:	mov    rsi,QWORD PTR [rdx]
 b3e:	call   b43 <botlish_entry_4+0xc>
			b3f: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 b43:	mov    rsp,rbp
 b46:	pop    rbp
 b47:	ret

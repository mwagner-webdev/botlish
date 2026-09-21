; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3003  (per function: 505 994 685 712 107)
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
 7ea:	mov    rsi,QWORD PTR [rdx]
 7ed:	call   7f2 <botlish_entry_2+0xc>
			7ee: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 7f2:	mov    rsp,rbp
 7f5:	pop    rbp
 7f6:	ret
	...

00000000000007f8 <botlish_fn_3: clean_from<str, int, str>>:
 7f8:	push   rbp
 7f9:	mov    rbp,rsp
 7fc:	sub    rsp,0x70
 800:	mov    QWORD PTR [rsp+0x40],rbx
 805:	mov    QWORD PTR [rsp+0x48],r12
 80a:	mov    QWORD PTR [rsp+0x50],r13
 80f:	mov    QWORD PTR [rsp+0x58],r14
 814:	mov    QWORD PTR [rsp+0x60],r15
 819:	mov    QWORD PTR [rsp+0x20],0x0
 822:	mov    QWORD PTR [rsp+0x28],0x0
 82b:	mov    QWORD PTR [rsp],rsi
 82f:	mov    QWORD PTR [rsp+0x8],rcx
 834:	mov    QWORD PTR [rsp+0x10],r8
 839:	mov    rbx,rsi
 83c:	mov    r13,rdi
 83f:	mov    r14,rcx
 842:	mov    r15,r8
 845:	mov    QWORD PTR [rsp+0x30],rdx
 84a:	mov    rsi,rbx
 84d:	mov    rdi,r13
 850:	call   855 <botlish_fn_3+0x5d>
			851: R_X86_64_PLT32	rt_str_len-0x4
 855:	mov    rsi,QWORD PTR [rsp+0x30]
 85a:	mov    rcx,rsi
 85d:	and    rcx,rax
 860:	mov    rdx,rax
 863:	test   rcx,0x1
 86a:	jne    892 <botlish_fn_3+0x9a>
 870:	mov    rsi,QWORD PTR [rsp+0x30]
 875:	mov    rdi,r13
 878:	call   87d <botlish_fn_3+0x85>
			879: R_X86_64_PLT32	rt_int_cmp-0x4
 87d:	mov    ecx,0x2
 882:	test   rax,rax
 885:	cmovge rcx,QWORD PTR [rip+0x1db]        # a68 <botlish_fn_3+0x270>
 88d:	jmp    8a7 <botlish_fn_3+0xaf>
 892:	mov    ecx,0x2
 897:	mov    rsi,QWORD PTR [rsp+0x30]
 89c:	cmp    rsi,rdx
 89f:	cmovge rcx,QWORD PTR [rip+0x1c1]        # a68 <botlish_fn_3+0x270>
 8a7:	cmp    rcx,0x6
 8ab:	je     a43 <botlish_fn_3+0x24b>
 8b1:	mov    rsi,QWORD PTR [rsp+0x30]
 8b6:	mov    rax,rsi
 8b9:	sar    rax,1
 8bc:	lea    r12,[rax+0x1]
 8c0:	shl    r12,1
 8c3:	or     r12,0x1
 8c7:	mov    QWORD PTR [rsp+0x18],r12
 8cc:	mov    rsi,rbx
 8cf:	mov    rdi,r13
 8d2:	call   8d7 <botlish_fn_3+0xdf>
			8d3: R_X86_64_PLT32	rt_str_len-0x4
 8d7:	mov    rsi,QWORD PTR [rsp+0x30]
 8dc:	mov    rcx,rsi
 8df:	and    rcx,rax
 8e2:	mov    rdx,rax
 8e5:	test   rcx,0x1
 8ec:	jne    914 <botlish_fn_3+0x11c>
 8f2:	mov    rsi,QWORD PTR [rsp+0x30]
 8f7:	mov    rdi,r13
 8fa:	call   8ff <botlish_fn_3+0x107>
			8fb: R_X86_64_PLT32	rt_int_cmp-0x4
 8ff:	mov    ecx,0x2
 904:	test   rax,rax
 907:	cmovge rcx,QWORD PTR [rip+0x159]        # a68 <botlish_fn_3+0x270>
 90f:	jmp    929 <botlish_fn_3+0x131>
 914:	mov    ecx,0x2
 919:	mov    rsi,QWORD PTR [rsp+0x30]
 91e:	cmp    rsi,rdx
 921:	cmovge rcx,QWORD PTR [rip+0x13f]        # a68 <botlish_fn_3+0x270>
 929:	cmp    rcx,0x6
 92d:	je     9c9 <botlish_fn_3+0x1d1>
 933:	mov    rdx,r15
 936:	mov    rsi,rbx
 939:	mov    rdi,r13
 93c:	call   941 <botlish_fn_3+0x149>
			93d: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 941:	mov    QWORD PTR [rsp+0x20],rax
 946:	mov    QWORD PTR [rsp+0x30],rax
 94b:	mov    rsi,QWORD PTR [rsp+0x30]
 950:	mov    rdi,r13
 953:	call   958 <botlish_fn_3+0x160>
			954: R_X86_64_PLT32	rt_str_byte_len-0x4
 958:	mov    QWORD PTR [rsp+0x28],rax
 95d:	mov    rsi,r15
 960:	mov    r8,rsi
 963:	and    r8,rax
 966:	test   r8,0x1
 96d:	jne    97e <botlish_fn_3+0x186>
 973:	mov    rdx,rax
 976:	mov    rsi,r15
 979:	jmp    9ac <botlish_fn_3+0x1b4>
 97e:	lea    r11,[rax-0x1]
 982:	mov    rdx,rax
 985:	mov    rsi,r15
 988:	mov    r10,rsi
 98b:	add    r10,r11
 98e:	seto   al
 991:	test   al,al
 993:	je     9a1 <botlish_fn_3+0x1a9>
 999:	mov    rsi,r15
 99c:	jmp    9ac <botlish_fn_3+0x1b4>
 9a1:	mov    rsi,r10
 9a4:	mov    r15,r10
 9a7:	jmp    9ba <botlish_fn_3+0x1c2>
 9ac:	mov    rdi,r13
 9af:	call   9b4 <botlish_fn_3+0x1bc>
			9b0: R_X86_64_PLT32	rt_int_add-0x4
 9b4:	mov    rsi,rax
 9b7:	mov    r15,rax
 9ba:	mov    QWORD PTR [rsp+0x10],rsi
 9bf:	mov    rsi,QWORD PTR [rsp+0x30]
 9c4:	jmp    9dc <botlish_fn_3+0x1e4>
 9c9:	mov    rax,QWORD PTR [r13+0x10]
 9cd:	mov    rsi,QWORD PTR [rax+0x90]
 9d4:	mov    rax,r15
 9d7:	mov    QWORD PTR [rsp+0x10],rax
 9dc:	mov    rdi,r13
 9df:	call   9e4 <botlish_fn_3+0x1ec>
			9e0: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 9e4:	mov    QWORD PTR [rsp+0x20],rax
 9e9:	mov    rdx,rax
 9ec:	mov    rsi,r14
 9ef:	mov    rdi,r13
 9f2:	call   9f7 <botlish_fn_3+0x1ff>
			9f3: R_X86_64_PLT32	rt_str_cat-0x4
 9f7:	test   rax,rax
 9fa:	jne    a25 <botlish_fn_3+0x22d>
 a00:	xor    rax,rax
 a03:	mov    rbx,QWORD PTR [rsp+0x40]
 a08:	mov    r12,QWORD PTR [rsp+0x48]
 a0d:	mov    r13,QWORD PTR [rsp+0x50]
 a12:	mov    r14,QWORD PTR [rsp+0x58]
 a17:	mov    r15,QWORD PTR [rsp+0x60]
 a1c:	add    rsp,0x70
 a20:	mov    rsp,rbp
 a23:	pop    rbp
 a24:	ret
 a25:	mov    QWORD PTR [rsp],rbx
 a29:	mov    QWORD PTR [rsp+0x8],rax
 a2e:	mov    rsi,r15
 a31:	mov    QWORD PTR [rsp+0x10],rsi
 a36:	mov    r14,rax
 a39:	mov    QWORD PTR [rsp+0x30],r12
 a3e:	jmp    84a <botlish_fn_3+0x52>
 a43:	mov    rax,r14
 a46:	mov    rbx,QWORD PTR [rsp+0x40]
 a4b:	mov    r12,QWORD PTR [rsp+0x48]
 a50:	mov    r13,QWORD PTR [rsp+0x50]
 a55:	mov    r14,QWORD PTR [rsp+0x58]
 a5a:	mov    r15,QWORD PTR [rsp+0x60]
 a5f:	add    rsp,0x70
 a63:	mov    rsp,rbp
 a66:	pop    rbp
 a67:	ret
 a68:	(bad)
 a69:	add    BYTE PTR [rax],al
 a6b:	add    BYTE PTR [rax],al
 a6d:	add    BYTE PTR [rax],al
	...

0000000000000a70 <botlish_entry_3: clean_from<str, int, str>>:
 a70:	push   rbp
 a71:	mov    rbp,rsp
 a74:	mov    rsi,QWORD PTR [rdx]
 a77:	mov    r9,QWORD PTR [rdx+0x8]
 a7b:	mov    rcx,QWORD PTR [rdx+0x10]
 a7f:	mov    r8,QWORD PTR [rdx+0x18]
 a83:	mov    rdx,r9
 a86:	call   a8b <botlish_entry_3+0x1b>
			a87: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 a8b:	mov    rsp,rbp
 a8e:	pop    rbp
 a8f:	ret

0000000000000a90 <botlish_fn_4: clean_ai_text<str>>:
 a90:	push   rbp
 a91:	mov    rbp,rsp
 a94:	sub    rsp,0x20
 a98:	mov    QWORD PTR [rsp],rsi
 a9c:	mov    r8d,0x1
 aa2:	mov    QWORD PTR [rsp+0x8],0x1
 aab:	mov    r11,QWORD PTR [rdi+0x10]
 aaf:	mov    rcx,QWORD PTR [r11+0x90]
 ab6:	mov    QWORD PTR [rsp+0x10],rcx
 abb:	mov    QWORD PTR [rsp+0x18],0x1
 ac4:	mov    rdx,r8
 ac7:	call   acc <botlish_fn_4+0x3c>
			ac8: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 acc:	test   rax,rax
 acf:	jne    ae1 <botlish_fn_4+0x51>
 ad5:	xor    rax,rax
 ad8:	add    rsp,0x20
 adc:	mov    rsp,rbp
 adf:	pop    rbp
 ae0:	ret
 ae1:	add    rsp,0x20
 ae5:	mov    rsp,rbp
 ae8:	pop    rbp
 ae9:	ret

0000000000000aea <botlish_entry_4: clean_ai_text<str>>:
 aea:	push   rbp
 aeb:	mov    rbp,rsp
 aee:	mov    rsi,QWORD PTR [rdx]
 af1:	call   af6 <botlish_entry_4+0xc>
			af2: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 af6:	mov    rsp,rbp
 af9:	pop    rbp
 afa:	ret

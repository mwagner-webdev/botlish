; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3663  (per function: 620 1093 858 856 236)
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
   4:	sub    rsp,0x70
   8:	mov    QWORD PTR [rsp+0x40],rbx
   d:	mov    QWORD PTR [rsp+0x48],r12
  12:	mov    QWORD PTR [rsp+0x50],r13
  17:	mov    QWORD PTR [rsp+0x58],r14
  1c:	mov    QWORD PTR [rsp+0x60],r15
  21:	mov    r15,QWORD PTR [rdi]
  24:	mov    rax,QWORD PTR [rdi+0x8]
  28:	lea    rcx,[r15+0x30]
  2c:	cmp    rcx,rax
  2f:	ja     221 <botlish_fn_0+0x221>
  35:	lea    rax,[r15+0x30]
  39:	mov    QWORD PTR [rdi],rax
  3c:	mov    QWORD PTR [r15],0x0
  43:	mov    QWORD PTR [r15+0x8],0x0
  4b:	mov    QWORD PTR [r15+0x10],0x0
  53:	mov    QWORD PTR [r15+0x18],0x0
  5b:	mov    QWORD PTR [r15+0x20],0x0
  63:	mov    QWORD PTR [r15+0x28],0x0
  6b:	mov    rax,QWORD PTR [rdi+0x10]
  6f:	mov    QWORD PTR [rsp+0x30],rdi
  74:	mov    rsi,QWORD PTR [rax]
  77:	mov    QWORD PTR [r15],rsi
  7a:	call   7f <botlish_fn_0+0x7f>
			7b: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  7f:	mov    rbx,rax
  82:	test   rbx,rbx
  85:	jne    95 <botlish_fn_0+0x95>
  8b:	mov    rdi,QWORD PTR [rsp+0x30]
  90:	jmp    1ca <botlish_fn_0+0x1ca>
  95:	mov    QWORD PTR [r15],rbx
  98:	mov    rdi,QWORD PTR [rsp+0x30]
  9d:	mov    rax,QWORD PTR [rdi+0x10]
  a1:	mov    rsi,QWORD PTR [rax+0x8]
  a5:	mov    QWORD PTR [r15+0x8],rsi
  a9:	call   ae <botlish_fn_0+0xae>
			aa: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  ae:	mov    r12,rax
  b1:	test   r12,r12
  b4:	jne    c4 <botlish_fn_0+0xc4>
  ba:	mov    rdi,QWORD PTR [rsp+0x30]
  bf:	jmp    1ca <botlish_fn_0+0x1ca>
  c4:	mov    QWORD PTR [r15+0x8],r12
  c8:	mov    rdi,QWORD PTR [rsp+0x30]
  cd:	mov    rax,QWORD PTR [rdi+0x10]
  d1:	mov    rsi,QWORD PTR [rax+0x10]
  d5:	mov    QWORD PTR [r15+0x10],rsi
  d9:	call   de <botlish_fn_0+0xde>
			da: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  de:	mov    r13,rax
  e1:	test   r13,r13
  e4:	jne    f4 <botlish_fn_0+0xf4>
  ea:	mov    rdi,QWORD PTR [rsp+0x30]
  ef:	jmp    1ca <botlish_fn_0+0x1ca>
  f4:	mov    QWORD PTR [r15+0x10],r13
  f8:	mov    rdi,QWORD PTR [rsp+0x30]
  fd:	mov    rax,QWORD PTR [rdi+0x10]
 101:	mov    rsi,QWORD PTR [rax+0x18]
 105:	mov    QWORD PTR [r15+0x18],rsi
 109:	call   10e <botlish_fn_0+0x10e>
			10a: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 10e:	mov    r14,rax
 111:	test   r14,r14
 114:	jne    124 <botlish_fn_0+0x124>
 11a:	mov    rdi,QWORD PTR [rsp+0x30]
 11f:	jmp    1ca <botlish_fn_0+0x1ca>
 124:	mov    QWORD PTR [r15+0x18],r14
 128:	mov    rdi,QWORD PTR [rsp+0x30]
 12d:	mov    rax,QWORD PTR [rdi+0x10]
 131:	mov    rsi,QWORD PTR [rax+0x20]
 135:	mov    QWORD PTR [r15+0x20],rsi
 139:	call   13e <botlish_fn_0+0x13e>
			13a: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 13e:	test   rax,rax
 141:	jne    151 <botlish_fn_0+0x151>
 147:	mov    rdi,QWORD PTR [rsp+0x30]
 14c:	jmp    1ca <botlish_fn_0+0x1ca>
 151:	mov    QWORD PTR [r15+0x20],rax
 155:	mov    rdi,QWORD PTR [rsp+0x30]
 15a:	mov    QWORD PTR [rsp+0x38],rax
 15f:	mov    rsi,QWORD PTR [rdi+0x10]
 163:	mov    rsi,QWORD PTR [rsi+0x28]
 167:	mov    QWORD PTR [r15+0x28],rsi
 16b:	call   170 <botlish_fn_0+0x170>
			16c: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 170:	test   rax,rax
 173:	jne    183 <botlish_fn_0+0x183>
 179:	mov    rdi,QWORD PTR [rsp+0x30]
 17e:	jmp    1ca <botlish_fn_0+0x1ca>
 183:	mov    QWORD PTR [r15+0x28],rax
 187:	lea    rdx,[rsp]
 18b:	mov    QWORD PTR [rsp],rbx
 18f:	mov    QWORD PTR [rsp+0x8],r12
 194:	mov    QWORD PTR [rsp+0x10],r13
 199:	mov    QWORD PTR [rsp+0x18],r14
 19e:	mov    rcx,QWORD PTR [rsp+0x38]
 1a3:	mov    QWORD PTR [rsp+0x20],rcx
 1a8:	mov    QWORD PTR [rsp+0x28],rax
 1ad:	mov    esi,0x6
 1b2:	mov    rdi,QWORD PTR [rsp+0x30]
 1b7:	call   1bc <botlish_fn_0+0x1bc>
			1b8: R_X86_64_PLT32	rt_list_new-0x4
 1bc:	test   rax,rax
 1bf:	jne    1f7 <botlish_fn_0+0x1f7>
 1c5:	mov    rdi,QWORD PTR [rsp+0x30]
 1ca:	mov    rdi,QWORD PTR [rsp+0x30]
 1cf:	mov    QWORD PTR [rdi],r15
 1d2:	xor    rax,rax
 1d5:	mov    rbx,QWORD PTR [rsp+0x40]
 1da:	mov    r12,QWORD PTR [rsp+0x48]
 1df:	mov    r13,QWORD PTR [rsp+0x50]
 1e4:	mov    r14,QWORD PTR [rsp+0x58]
 1e9:	mov    r15,QWORD PTR [rsp+0x60]
 1ee:	add    rsp,0x70
 1f2:	mov    rsp,rbp
 1f5:	pop    rbp
 1f6:	ret
 1f7:	mov    rdi,QWORD PTR [rsp+0x30]
 1fc:	mov    QWORD PTR [rdi],r15
 1ff:	mov    rbx,QWORD PTR [rsp+0x40]
 204:	mov    r12,QWORD PTR [rsp+0x48]
 209:	mov    r13,QWORD PTR [rsp+0x50]
 20e:	mov    r14,QWORD PTR [rsp+0x58]
 213:	mov    r15,QWORD PTR [rsp+0x60]
 218:	add    rsp,0x70
 21c:	mov    rsp,rbp
 21f:	pop    rbp
 220:	ret
 221:	mov    QWORD PTR [rsp+0x30],rdi
 226:	call   22b <botlish_fn_0+0x22b>
			227: R_X86_64_PLT32	rt_stack_overflow-0x4
 22b:	xor    rax,rax
 22e:	mov    rbx,QWORD PTR [rsp+0x40]
 233:	mov    r12,QWORD PTR [rsp+0x48]
 238:	mov    r13,QWORD PTR [rsp+0x50]
 23d:	mov    r14,QWORD PTR [rsp+0x58]
 242:	mov    r15,QWORD PTR [rsp+0x60]
 247:	add    rsp,0x70
 24b:	mov    rsp,rbp
 24e:	pop    rbp
 24f:	ret

0000000000000250 <botlish_entry_0: <program entry>>:
 250:	push   rbp
 251:	mov    rbp,rsp
 254:	call   259 <botlish_entry_0+0x9>
			255: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 259:	mov    rsp,rbp
 25c:	pop    rbp
 25d:	ret

000000000000025e <botlish_fn_1: cleaner_emoji<str>>:
 25e:	push   rbp
 25f:	mov    rbp,rsp
 262:	sub    rsp,0x20
 266:	mov    QWORD PTR [rsp],rbx
 26a:	mov    QWORD PTR [rsp+0x8],r12
 26f:	mov    QWORD PTR [rsp+0x10],r13
 274:	mov    r13,rsi
 277:	mov    rbx,QWORD PTR [rdi]
 27a:	mov    rax,QWORD PTR [rdi+0x8]
 27e:	lea    rcx,[rbx+0x8]
 282:	cmp    rcx,rax
 285:	ja     610 <botlish_fn_1+0x3b2>
 28b:	lea    rax,[rbx+0x8]
 28f:	mov    QWORD PTR [rdi],rax
 292:	mov    QWORD PTR [rbx],0x0
 299:	mov    rsi,QWORD PTR [rdi+0x10]
 29d:	mov    r12,rdi
 2a0:	mov    rsi,QWORD PTR [rsi+0x30]
 2a4:	mov    edx,0x1
 2a9:	mov    ecx,0x3
 2ae:	mov    r8,r13
 2b1:	call   2b6 <botlish_fn_1+0x58>
			2b2: R_X86_64_PLT32	rt_str_region_eq-0x4
 2b6:	cmp    rax,0x6
 2ba:	je     2fb <botlish_fn_1+0x9d>
 2c0:	mov    rdi,r12
 2c3:	mov    rsi,QWORD PTR [rdi+0x10]
 2c7:	mov    rsi,QWORD PTR [rsi+0x38]
 2cb:	mov    edx,0x1
 2d0:	mov    ecx,0x3
 2d5:	mov    r8,r13
 2d8:	call   2dd <botlish_fn_1+0x7f>
			2d9: R_X86_64_PLT32	rt_str_region_eq-0x4
 2dd:	cmp    rax,0x6
 2e1:	je     2f1 <botlish_fn_1+0x93>
 2e7:	mov    eax,0x2
 2ec:	jmp    300 <botlish_fn_1+0xa2>
 2f1:	mov    eax,0x6
 2f6:	jmp    300 <botlish_fn_1+0xa2>
 2fb:	mov    eax,0x6
 300:	cmp    rax,0x6
 304:	je     345 <botlish_fn_1+0xe7>
 30a:	mov    rdi,r12
 30d:	mov    rax,QWORD PTR [rdi+0x10]
 311:	mov    rsi,QWORD PTR [rax+0x40]
 315:	mov    edx,0x1
 31a:	mov    ecx,0x3
 31f:	mov    r8,r13
 322:	call   327 <botlish_fn_1+0xc9>
			323: R_X86_64_PLT32	rt_str_region_eq-0x4
 327:	cmp    rax,0x6
 32b:	je     33b <botlish_fn_1+0xdd>
 331:	mov    eax,0x2
 336:	jmp    34a <botlish_fn_1+0xec>
 33b:	mov    eax,0x6
 340:	jmp    34a <botlish_fn_1+0xec>
 345:	mov    eax,0x6
 34a:	cmp    rax,0x6
 34e:	je     38f <botlish_fn_1+0x131>
 354:	mov    rdi,r12
 357:	mov    rax,QWORD PTR [rdi+0x10]
 35b:	mov    rsi,QWORD PTR [rax+0x48]
 35f:	mov    edx,0x1
 364:	mov    ecx,0x3
 369:	mov    r8,r13
 36c:	call   371 <botlish_fn_1+0x113>
			36d: R_X86_64_PLT32	rt_str_region_eq-0x4
 371:	cmp    rax,0x6
 375:	je     385 <botlish_fn_1+0x127>
 37b:	mov    eax,0x2
 380:	jmp    394 <botlish_fn_1+0x136>
 385:	mov    eax,0x6
 38a:	jmp    394 <botlish_fn_1+0x136>
 38f:	mov    eax,0x6
 394:	cmp    rax,0x6
 398:	je     3d9 <botlish_fn_1+0x17b>
 39e:	mov    rdi,r12
 3a1:	mov    rax,QWORD PTR [rdi+0x10]
 3a5:	mov    rsi,QWORD PTR [rax+0x50]
 3a9:	mov    edx,0x1
 3ae:	mov    ecx,0x3
 3b3:	mov    r8,r13
 3b6:	call   3bb <botlish_fn_1+0x15d>
			3b7: R_X86_64_PLT32	rt_str_region_eq-0x4
 3bb:	cmp    rax,0x6
 3bf:	je     3cf <botlish_fn_1+0x171>
 3c5:	mov    eax,0x2
 3ca:	jmp    3de <botlish_fn_1+0x180>
 3cf:	mov    eax,0x6
 3d4:	jmp    3de <botlish_fn_1+0x180>
 3d9:	mov    eax,0x6
 3de:	cmp    rax,0x6
 3e2:	je     423 <botlish_fn_1+0x1c5>
 3e8:	mov    rdi,r12
 3eb:	mov    rax,QWORD PTR [rdi+0x10]
 3ef:	mov    rsi,QWORD PTR [rax+0x58]
 3f3:	mov    edx,0x1
 3f8:	mov    ecx,0x3
 3fd:	mov    r8,r13
 400:	call   405 <botlish_fn_1+0x1a7>
			401: R_X86_64_PLT32	rt_str_region_eq-0x4
 405:	cmp    rax,0x6
 409:	je     419 <botlish_fn_1+0x1bb>
 40f:	mov    eax,0x2
 414:	jmp    428 <botlish_fn_1+0x1ca>
 419:	mov    eax,0x6
 41e:	jmp    428 <botlish_fn_1+0x1ca>
 423:	mov    eax,0x6
 428:	cmp    rax,0x6
 42c:	je     46d <botlish_fn_1+0x20f>
 432:	mov    rdi,r12
 435:	mov    rax,QWORD PTR [rdi+0x10]
 439:	mov    rsi,QWORD PTR [rax+0x60]
 43d:	mov    edx,0x1
 442:	mov    ecx,0x3
 447:	mov    r8,r13
 44a:	call   44f <botlish_fn_1+0x1f1>
			44b: R_X86_64_PLT32	rt_str_region_eq-0x4
 44f:	cmp    rax,0x6
 453:	je     463 <botlish_fn_1+0x205>
 459:	mov    eax,0x2
 45e:	jmp    472 <botlish_fn_1+0x214>
 463:	mov    eax,0x6
 468:	jmp    472 <botlish_fn_1+0x214>
 46d:	mov    eax,0x6
 472:	cmp    rax,0x6
 476:	je     4b9 <botlish_fn_1+0x25b>
 47c:	mov    rdi,r12
 47f:	mov    rax,QWORD PTR [rdi+0x10]
 483:	mov    rsi,QWORD PTR [rax+0x68]
 487:	mov    edx,0x1
 48c:	mov    ecx,0x3
 491:	mov    r8,r13
 494:	call   499 <botlish_fn_1+0x23b>
			495: R_X86_64_PLT32	rt_str_region_eq-0x4
 499:	cmp    rax,0x6
 49d:	je     4ae <botlish_fn_1+0x250>
 4a3:	mov    r9d,0x2
 4a9:	jmp    4bf <botlish_fn_1+0x261>
 4ae:	mov    r9d,0x6
 4b4:	jmp    4bf <botlish_fn_1+0x261>
 4b9:	mov    r9d,0x6
 4bf:	cmp    r9,0x6
 4c3:	je     504 <botlish_fn_1+0x2a6>
 4c9:	mov    rdi,r12
 4cc:	mov    rax,QWORD PTR [rdi+0x10]
 4d0:	mov    rsi,QWORD PTR [rax+0x70]
 4d4:	mov    edx,0x1
 4d9:	mov    ecx,0x3
 4de:	mov    r8,r13
 4e1:	call   4e6 <botlish_fn_1+0x288>
			4e2: R_X86_64_PLT32	rt_str_region_eq-0x4
 4e6:	cmp    rax,0x6
 4ea:	je     4fa <botlish_fn_1+0x29c>
 4f0:	mov    eax,0x2
 4f5:	jmp    509 <botlish_fn_1+0x2ab>
 4fa:	mov    eax,0x6
 4ff:	jmp    509 <botlish_fn_1+0x2ab>
 504:	mov    eax,0x6
 509:	cmp    rax,0x6
 50d:	je     54e <botlish_fn_1+0x2f0>
 513:	mov    rdi,r12
 516:	mov    rsi,QWORD PTR [rdi+0x10]
 51a:	mov    rsi,QWORD PTR [rsi+0x78]
 51e:	mov    edx,0x1
 523:	mov    ecx,0x3
 528:	mov    r8,r13
 52b:	call   530 <botlish_fn_1+0x2d2>
			52c: R_X86_64_PLT32	rt_str_region_eq-0x4
 530:	cmp    rax,0x6
 534:	je     544 <botlish_fn_1+0x2e6>
 53a:	mov    eax,0x2
 53f:	jmp    553 <botlish_fn_1+0x2f5>
 544:	mov    eax,0x6
 549:	jmp    553 <botlish_fn_1+0x2f5>
 54e:	mov    eax,0x6
 553:	cmp    rax,0x6
 557:	je     59b <botlish_fn_1+0x33d>
 55d:	mov    rdi,r12
 560:	mov    rax,QWORD PTR [rdi+0x10]
 564:	mov    rsi,QWORD PTR [rax+0x80]
 56b:	mov    edx,0x1
 570:	mov    ecx,0x3
 575:	mov    r8,r13
 578:	call   57d <botlish_fn_1+0x31f>
			579: R_X86_64_PLT32	rt_str_region_eq-0x4
 57d:	cmp    rax,0x6
 581:	je     591 <botlish_fn_1+0x333>
 587:	mov    eax,0x2
 58c:	jmp    5a0 <botlish_fn_1+0x342>
 591:	mov    eax,0x6
 596:	jmp    5a0 <botlish_fn_1+0x342>
 59b:	mov    eax,0x6
 5a0:	cmp    rax,0x6
 5a4:	je     5eb <botlish_fn_1+0x38d>
 5aa:	mov    rdi,r12
 5ad:	mov    rax,QWORD PTR [rdi+0x10]
 5b1:	mov    rsi,QWORD PTR [rax+0x88]
 5b8:	mov    edx,0x1
 5bd:	mov    ecx,0x3
 5c2:	mov    r8,r13
 5c5:	call   5ca <botlish_fn_1+0x36c>
			5c6: R_X86_64_PLT32	rt_str_region_eq-0x4
 5ca:	cmp    rax,0x6
 5ce:	je     5de <botlish_fn_1+0x380>
 5d4:	mov    eax,0x2
 5d9:	jmp    5e3 <botlish_fn_1+0x385>
 5de:	mov    eax,0x6
 5e3:	mov    rdi,r12
 5e6:	jmp    5f3 <botlish_fn_1+0x395>
 5eb:	mov    eax,0x6
 5f0:	mov    rdi,r12
 5f3:	mov    rdi,r12
 5f6:	mov    QWORD PTR [rdi],rbx
 5f9:	mov    rbx,QWORD PTR [rsp]
 5fd:	mov    r12,QWORD PTR [rsp+0x8]
 602:	mov    r13,QWORD PTR [rsp+0x10]
 607:	add    rsp,0x20
 60b:	mov    rsp,rbp
 60e:	pop    rbp
 60f:	ret
 610:	mov    r12,rdi
 613:	call   618 <botlish_fn_1+0x3ba>
			614: R_X86_64_PLT32	rt_stack_overflow-0x4
 618:	xor    rax,rax
 61b:	mov    rbx,QWORD PTR [rsp]
 61f:	mov    r12,QWORD PTR [rsp+0x8]
 624:	mov    r13,QWORD PTR [rsp+0x10]
 629:	add    rsp,0x20
 62d:	mov    rsp,rbp
 630:	pop    rbp
 631:	ret

0000000000000632 <botlish_entry_1: cleaner_emoji<str>>:
 632:	push   rbp
 633:	mov    rbp,rsp
 636:	mov    rsi,QWORD PTR [rdx]
 639:	call   63e <botlish_entry_1+0xc>
			63a: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 63e:	mov    rsp,rbp
 641:	pop    rbp
 642:	ret

0000000000000643 <botlish_fn_2: clean_char<str>>:
 643:	push   rbp
 644:	mov    rbp,rsp
 647:	sub    rsp,0x20
 64b:	mov    QWORD PTR [rsp],r12
 64f:	mov    QWORD PTR [rsp+0x8],r13
 654:	mov    QWORD PTR [rsp+0x10],r14
 659:	mov    r12,QWORD PTR [rdi]
 65c:	mov    r9,QWORD PTR [rdi+0x8]
 660:	lea    r10,[r12+0x8]
 665:	cmp    r10,r9
 668:	ja     935 <botlish_fn_2+0x2f2>
 66e:	lea    r11,[r12+0x8]
 673:	mov    QWORD PTR [rdi],r11
 676:	mov    r13,rdi
 679:	mov    QWORD PTR [r12],rsi
 67d:	mov    r14,rsi
 680:	mov    rsi,r14
 683:	mov    rdi,r13
 686:	call   68b <botlish_fn_2+0x48>
			687: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 68b:	test   rax,rax
 68e:	jne    6b4 <botlish_fn_2+0x71>
 694:	mov    rdi,r13
 697:	mov    QWORD PTR [rdi],r12
 69a:	xor    rax,rax
 69d:	mov    r12,QWORD PTR [rsp]
 6a1:	mov    r13,QWORD PTR [rsp+0x8]
 6a6:	mov    r14,QWORD PTR [rsp+0x10]
 6ab:	add    rsp,0x20
 6af:	mov    rsp,rbp
 6b2:	pop    rbp
 6b3:	ret
 6b4:	cmp    rax,0x6
 6b8:	je     90d <botlish_fn_2+0x2ca>
 6be:	mov    rdi,r13
 6c1:	mov    rax,QWORD PTR [rdi+0x10]
 6c5:	mov    rsi,QWORD PTR [rax+0x98]
 6cc:	mov    edx,0x1
 6d1:	mov    ecx,0x3
 6d6:	mov    r8,r14
 6d9:	call   6de <botlish_fn_2+0x9b>
			6da: R_X86_64_PLT32	rt_str_region_eq-0x4
 6de:	cmp    rax,0x6
 6e2:	je     726 <botlish_fn_2+0xe3>
 6e8:	mov    rdi,r13
 6eb:	mov    rax,QWORD PTR [rdi+0x10]
 6ef:	mov    rsi,QWORD PTR [rax+0xa0]
 6f6:	mov    edx,0x1
 6fb:	mov    ecx,0x3
 700:	mov    r8,r14
 703:	call   708 <botlish_fn_2+0xc5>
			704: R_X86_64_PLT32	rt_str_region_eq-0x4
 708:	cmp    rax,0x6
 70c:	je     71c <botlish_fn_2+0xd9>
 712:	mov    ecx,0x2
 717:	jmp    72b <botlish_fn_2+0xe8>
 71c:	mov    ecx,0x6
 721:	jmp    72b <botlish_fn_2+0xe8>
 726:	mov    ecx,0x6
 72b:	cmp    rcx,0x6
 72f:	je     8e5 <botlish_fn_2+0x2a2>
 735:	mov    rdi,r13
 738:	mov    rax,QWORD PTR [rdi+0x10]
 73c:	mov    rsi,QWORD PTR [rax+0xb0]
 743:	mov    edx,0x1
 748:	mov    ecx,0x3
 74d:	mov    r8,r14
 750:	call   755 <botlish_fn_2+0x112>
			751: R_X86_64_PLT32	rt_str_region_eq-0x4
 755:	cmp    rax,0x6
 759:	je     79d <botlish_fn_2+0x15a>
 75f:	mov    rdi,r13
 762:	mov    rax,QWORD PTR [rdi+0x10]
 766:	mov    rsi,QWORD PTR [rax+0xb8]
 76d:	mov    edx,0x1
 772:	mov    ecx,0x3
 777:	mov    r8,r14
 77a:	call   77f <botlish_fn_2+0x13c>
			77b: R_X86_64_PLT32	rt_str_region_eq-0x4
 77f:	cmp    rax,0x6
 783:	je     793 <botlish_fn_2+0x150>
 789:	mov    ecx,0x2
 78e:	jmp    7a2 <botlish_fn_2+0x15f>
 793:	mov    ecx,0x6
 798:	jmp    7a2 <botlish_fn_2+0x15f>
 79d:	mov    ecx,0x6
 7a2:	cmp    rcx,0x6
 7a6:	je     8bd <botlish_fn_2+0x27a>
 7ac:	mov    rdi,r13
 7af:	mov    rax,QWORD PTR [rdi+0x10]
 7b3:	mov    rsi,QWORD PTR [rax+0xc8]
 7ba:	mov    edx,0x1
 7bf:	mov    ecx,0x3
 7c4:	mov    r8,r14
 7c7:	call   7cc <botlish_fn_2+0x189>
			7c8: R_X86_64_PLT32	rt_str_region_eq-0x4
 7cc:	cmp    rax,0x6
 7d0:	je     814 <botlish_fn_2+0x1d1>
 7d6:	mov    rdi,r13
 7d9:	mov    rax,QWORD PTR [rdi+0x10]
 7dd:	mov    rsi,QWORD PTR [rax+0xd0]
 7e4:	mov    edx,0x1
 7e9:	mov    ecx,0x3
 7ee:	mov    r8,r14
 7f1:	call   7f6 <botlish_fn_2+0x1b3>
			7f2: R_X86_64_PLT32	rt_str_region_eq-0x4
 7f6:	cmp    rax,0x6
 7fa:	je     80a <botlish_fn_2+0x1c7>
 800:	mov    ecx,0x2
 805:	jmp    819 <botlish_fn_2+0x1d6>
 80a:	mov    ecx,0x6
 80f:	jmp    819 <botlish_fn_2+0x1d6>
 814:	mov    ecx,0x6
 819:	cmp    rcx,0x6
 81d:	je     895 <botlish_fn_2+0x252>
 823:	mov    rdi,r13
 826:	mov    rax,QWORD PTR [rdi+0x10]
 82a:	mov    rsi,QWORD PTR [rax+0xe0]
 831:	mov    edx,0x1
 836:	mov    ecx,0x3
 83b:	mov    r8,r14
 83e:	call   843 <botlish_fn_2+0x200>
			83f: R_X86_64_PLT32	rt_str_region_eq-0x4
 843:	cmp    rax,0x6
 847:	je     86d <botlish_fn_2+0x22a>
 84d:	mov    rdi,r13
 850:	mov    QWORD PTR [rdi],r12
 853:	mov    rax,r14
 856:	mov    r12,QWORD PTR [rsp]
 85a:	mov    r13,QWORD PTR [rsp+0x8]
 85f:	mov    r14,QWORD PTR [rsp+0x10]
 864:	add    rsp,0x20
 868:	mov    rsp,rbp
 86b:	pop    rbp
 86c:	ret
 86d:	mov    rdi,r13
 870:	mov    rax,QWORD PTR [rdi+0x10]
 874:	mov    rax,QWORD PTR [rax+0xe8]
 87b:	mov    QWORD PTR [rdi],r12
 87e:	mov    r12,QWORD PTR [rsp]
 882:	mov    r13,QWORD PTR [rsp+0x8]
 887:	mov    r14,QWORD PTR [rsp+0x10]
 88c:	add    rsp,0x20
 890:	mov    rsp,rbp
 893:	pop    rbp
 894:	ret
 895:	mov    rdi,r13
 898:	mov    rax,QWORD PTR [rdi+0x10]
 89c:	mov    rax,QWORD PTR [rax+0xd8]
 8a3:	mov    QWORD PTR [rdi],r12
 8a6:	mov    r12,QWORD PTR [rsp]
 8aa:	mov    r13,QWORD PTR [rsp+0x8]
 8af:	mov    r14,QWORD PTR [rsp+0x10]
 8b4:	add    rsp,0x20
 8b8:	mov    rsp,rbp
 8bb:	pop    rbp
 8bc:	ret
 8bd:	mov    rdi,r13
 8c0:	mov    rax,QWORD PTR [rdi+0x10]
 8c4:	mov    rax,QWORD PTR [rax+0xc0]
 8cb:	mov    QWORD PTR [rdi],r12
 8ce:	mov    r12,QWORD PTR [rsp]
 8d2:	mov    r13,QWORD PTR [rsp+0x8]
 8d7:	mov    r14,QWORD PTR [rsp+0x10]
 8dc:	add    rsp,0x20
 8e0:	mov    rsp,rbp
 8e3:	pop    rbp
 8e4:	ret
 8e5:	mov    rdi,r13
 8e8:	mov    rdx,QWORD PTR [rdi+0x10]
 8ec:	mov    rax,QWORD PTR [rdx+0xa8]
 8f3:	mov    QWORD PTR [rdi],r12
 8f6:	mov    r12,QWORD PTR [rsp]
 8fa:	mov    r13,QWORD PTR [rsp+0x8]
 8ff:	mov    r14,QWORD PTR [rsp+0x10]
 904:	add    rsp,0x20
 908:	mov    rsp,rbp
 90b:	pop    rbp
 90c:	ret
 90d:	mov    rdi,r13
 910:	mov    rsi,QWORD PTR [rdi+0x10]
 914:	mov    rax,QWORD PTR [rsi+0x90]
 91b:	mov    QWORD PTR [rdi],r12
 91e:	mov    r12,QWORD PTR [rsp]
 922:	mov    r13,QWORD PTR [rsp+0x8]
 927:	mov    r14,QWORD PTR [rsp+0x10]
 92c:	add    rsp,0x20
 930:	mov    rsp,rbp
 933:	pop    rbp
 934:	ret
 935:	mov    r13,rdi
 938:	call   93d <botlish_fn_2+0x2fa>
			939: R_X86_64_PLT32	rt_stack_overflow-0x4
 93d:	xor    rax,rax
 940:	mov    r12,QWORD PTR [rsp]
 944:	mov    r13,QWORD PTR [rsp+0x8]
 949:	mov    r14,QWORD PTR [rsp+0x10]
 94e:	add    rsp,0x20
 952:	mov    rsp,rbp
 955:	pop    rbp
 956:	ret

0000000000000957 <botlish_entry_2: clean_char<str>>:
 957:	push   rbp
 958:	mov    rbp,rsp
 95b:	mov    rsi,QWORD PTR [rdx]
 95e:	call   963 <botlish_entry_2+0xc>
			95f: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 963:	mov    rsp,rbp
 966:	pop    rbp
 967:	ret

0000000000000968 <botlish_fn_3: clean_from<str, int, str>>:
 968:	push   rbp
 969:	mov    rbp,rsp
 96c:	sub    rsp,0x40
 970:	mov    QWORD PTR [rsp+0x10],rbx
 975:	mov    QWORD PTR [rsp+0x18],r12
 97a:	mov    QWORD PTR [rsp+0x20],r13
 97f:	mov    QWORD PTR [rsp+0x28],r14
 984:	mov    QWORD PTR [rsp+0x30],r15
 989:	mov    rbx,QWORD PTR [rdi]
 98c:	mov    rax,QWORD PTR [rdi+0x8]
 990:	lea    r9,[rbx+0x30]
 994:	cmp    r9,rax
 997:	ja     c2f <botlish_fn_3+0x2c7>
 99d:	lea    rax,[rbx+0x30]
 9a1:	mov    QWORD PTR [rdi],rax
 9a4:	mov    r14,rdi
 9a7:	mov    QWORD PTR [rbx],0x0
 9ae:	mov    QWORD PTR [rbx+0x8],0x0
 9b6:	mov    QWORD PTR [rbx+0x10],0x0
 9be:	mov    QWORD PTR [rbx+0x18],0x0
 9c6:	mov    QWORD PTR [rbx+0x20],0x0
 9ce:	mov    QWORD PTR [rbx+0x28],0x0
 9d6:	mov    QWORD PTR [rbx],rsi
 9d9:	mov    QWORD PTR [rbx+0x8],rcx
 9dd:	mov    QWORD PTR [rbx+0x10],r8
 9e1:	mov    r12,rsi
 9e4:	mov    r15,r8
 9e7:	mov    QWORD PTR [rsp],rdx
 9eb:	mov    QWORD PTR [rsp+0x8],rcx
 9f0:	mov    rsi,r12
 9f3:	mov    rdi,r14
 9f6:	call   9fb <botlish_fn_3+0x93>
			9f7: R_X86_64_PLT32	rt_str_len-0x4
 9fb:	mov    rsi,QWORD PTR [rsp]
 9ff:	mov    rcx,rsi
 a02:	and    rcx,rax
 a05:	mov    rdx,rax
 a08:	test   rcx,0x1
 a0f:	jne    a36 <botlish_fn_3+0xce>
 a15:	mov    rsi,QWORD PTR [rsp]
 a19:	mov    rdi,r14
 a1c:	call   a21 <botlish_fn_3+0xb9>
			a1d: R_X86_64_PLT32	rt_int_cmp-0x4
 a21:	mov    ecx,0x2
 a26:	test   rax,rax
 a29:	cmovge rcx,QWORD PTR [rip+0x22f]        # c60 <botlish_fn_3+0x2f8>
 a31:	jmp    a4a <botlish_fn_3+0xe2>
 a36:	mov    ecx,0x2
 a3b:	mov    rsi,QWORD PTR [rsp]
 a3f:	cmp    rsi,rdx
 a42:	cmovge rcx,QWORD PTR [rip+0x216]        # c60 <botlish_fn_3+0x2f8>
 a4a:	cmp    rcx,0x6
 a4e:	je     c02 <botlish_fn_3+0x29a>
 a54:	mov    rsi,QWORD PTR [rsp]
 a58:	mov    r10,rsi
 a5b:	sar    r10,1
 a5e:	lea    r13,[r10+0x1]
 a62:	shl    r13,1
 a65:	or     r13,0x1
 a69:	mov    QWORD PTR [rbx+0x18],r13
 a6d:	mov    rsi,r12
 a70:	mov    rdi,r14
 a73:	call   a78 <botlish_fn_3+0x110>
			a74: R_X86_64_PLT32	rt_str_len-0x4
 a78:	mov    rsi,QWORD PTR [rsp]
 a7c:	mov    r11,rsi
 a7f:	and    r11,rax
 a82:	mov    rdx,rax
 a85:	test   r11,0x1
 a8c:	jne    ab3 <botlish_fn_3+0x14b>
 a92:	mov    rsi,QWORD PTR [rsp]
 a96:	mov    rdi,r14
 a99:	call   a9e <botlish_fn_3+0x136>
			a9a: R_X86_64_PLT32	rt_int_cmp-0x4
 a9e:	mov    ecx,0x2
 aa3:	test   rax,rax
 aa6:	cmovge rcx,QWORD PTR [rip+0x1b2]        # c60 <botlish_fn_3+0x2f8>
 aae:	jmp    ac7 <botlish_fn_3+0x15f>
 ab3:	mov    ecx,0x2
 ab8:	mov    rsi,QWORD PTR [rsp]
 abc:	cmp    rsi,rdx
 abf:	cmovge rcx,QWORD PTR [rip+0x199]        # c60 <botlish_fn_3+0x2f8>
 ac7:	cmp    rcx,0x6
 acb:	je     b69 <botlish_fn_3+0x201>
 ad1:	mov    rdx,r15
 ad4:	mov    rsi,r12
 ad7:	mov    rdi,r14
 ada:	call   adf <botlish_fn_3+0x177>
			adb: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 adf:	mov    QWORD PTR [rbx+0x20],rax
 ae3:	mov    QWORD PTR [rsp],rax
 ae7:	mov    rsi,QWORD PTR [rsp]
 aeb:	mov    rdi,r14
 aee:	call   af3 <botlish_fn_3+0x18b>
			aef: R_X86_64_PLT32	rt_str_byte_len-0x4
 af3:	mov    QWORD PTR [rbx+0x28],rax
 af7:	mov    rsi,r15
 afa:	mov    rcx,rsi
 afd:	and    rcx,rax
 b00:	test   rcx,0x1
 b07:	jne    b18 <botlish_fn_3+0x1b0>
 b0d:	mov    rdx,rax
 b10:	mov    rsi,r15
 b13:	jmp    b47 <botlish_fn_3+0x1df>
 b18:	lea    rcx,[rax-0x1]
 b1c:	mov    rdx,rax
 b1f:	mov    rsi,r15
 b22:	mov    rax,rsi
 b25:	add    rax,rcx
 b28:	seto   cl
 b2b:	test   cl,cl
 b2d:	je     b3b <botlish_fn_3+0x1d3>
 b33:	mov    rsi,r15
 b36:	jmp    b47 <botlish_fn_3+0x1df>
 b3b:	mov    r15,rax
 b3e:	mov    rax,QWORD PTR [rsp]
 b42:	jmp    b56 <botlish_fn_3+0x1ee>
 b47:	mov    rdi,r14
 b4a:	call   b4f <botlish_fn_3+0x1e7>
			b4b: R_X86_64_PLT32	rt_int_add-0x4
 b4f:	mov    r15,rax
 b52:	mov    rax,QWORD PTR [rsp]
 b56:	mov    QWORD PTR [rbx+0x10],rax
 b5a:	mov    rsi,r15
 b5d:	mov    QWORD PTR [rbx+0x20],rsi
 b61:	mov    rsi,rax
 b64:	jmp    b82 <botlish_fn_3+0x21a>
 b69:	mov    rdi,r14
 b6c:	mov    rax,QWORD PTR [rdi+0x10]
 b70:	mov    rsi,QWORD PTR [rax+0x90]
 b77:	mov    QWORD PTR [rbx+0x10],rsi
 b7b:	mov    rax,r15
 b7e:	mov    QWORD PTR [rbx+0x20],rax
 b82:	mov    rdi,r14
 b85:	call   b8a <botlish_fn_3+0x222>
			b86: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 b8a:	test   rax,rax
 b8d:	jne    b9b <botlish_fn_3+0x233>
 b93:	mov    rdi,r14
 b96:	jmp    bbb <botlish_fn_3+0x253>
 b9b:	mov    QWORD PTR [rbx+0x10],rax
 b9f:	mov    rdx,rax
 ba2:	mov    rsi,QWORD PTR [rsp+0x8]
 ba7:	mov    rdi,r14
 baa:	call   baf <botlish_fn_3+0x247>
			bab: R_X86_64_PLT32	rt_str_cat-0x4
 baf:	test   rax,rax
 bb2:	jne    be6 <botlish_fn_3+0x27e>
 bb8:	mov    rdi,r14
 bbb:	mov    rdi,r14
 bbe:	mov    QWORD PTR [rdi],rbx
 bc1:	xor    rax,rax
 bc4:	mov    rbx,QWORD PTR [rsp+0x10]
 bc9:	mov    r12,QWORD PTR [rsp+0x18]
 bce:	mov    r13,QWORD PTR [rsp+0x20]
 bd3:	mov    r14,QWORD PTR [rsp+0x28]
 bd8:	mov    r15,QWORD PTR [rsp+0x30]
 bdd:	add    rsp,0x40
 be1:	mov    rsp,rbp
 be4:	pop    rbp
 be5:	ret
 be6:	mov    QWORD PTR [rbx],r12
 be9:	mov    QWORD PTR [rbx+0x8],rax
 bed:	mov    rsi,r15
 bf0:	mov    QWORD PTR [rbx+0x10],rsi
 bf4:	mov    QWORD PTR [rsp],r13
 bf8:	mov    QWORD PTR [rsp+0x8],rax
 bfd:	jmp    9f0 <botlish_fn_3+0x88>
 c02:	mov    rdi,r14
 c05:	mov    QWORD PTR [rdi],rbx
 c08:	mov    rax,QWORD PTR [rsp+0x8]
 c0d:	mov    rbx,QWORD PTR [rsp+0x10]
 c12:	mov    r12,QWORD PTR [rsp+0x18]
 c17:	mov    r13,QWORD PTR [rsp+0x20]
 c1c:	mov    r14,QWORD PTR [rsp+0x28]
 c21:	mov    r15,QWORD PTR [rsp+0x30]
 c26:	add    rsp,0x40
 c2a:	mov    rsp,rbp
 c2d:	pop    rbp
 c2e:	ret
 c2f:	mov    r14,rdi
 c32:	call   c37 <botlish_fn_3+0x2cf>
			c33: R_X86_64_PLT32	rt_stack_overflow-0x4
 c37:	xor    rax,rax
 c3a:	mov    rbx,QWORD PTR [rsp+0x10]
 c3f:	mov    r12,QWORD PTR [rsp+0x18]
 c44:	mov    r13,QWORD PTR [rsp+0x20]
 c49:	mov    r14,QWORD PTR [rsp+0x28]
 c4e:	mov    r15,QWORD PTR [rsp+0x30]
 c53:	add    rsp,0x40
 c57:	mov    rsp,rbp
 c5a:	pop    rbp
 c5b:	ret
 c5c:	add    BYTE PTR [rax],al
 c5e:	add    BYTE PTR [rax],al
 c60:	(bad)
 c61:	add    BYTE PTR [rax],al
 c63:	add    BYTE PTR [rax],al
 c65:	add    BYTE PTR [rax],al
	...

0000000000000c68 <botlish_entry_3: clean_from<str, int, str>>:
 c68:	push   rbp
 c69:	mov    rbp,rsp
 c6c:	mov    rsi,QWORD PTR [rdx]
 c6f:	mov    r9,QWORD PTR [rdx+0x8]
 c73:	mov    rcx,QWORD PTR [rdx+0x10]
 c77:	mov    r8,QWORD PTR [rdx+0x18]
 c7b:	mov    rdx,r9
 c7e:	call   c83 <botlish_entry_3+0x1b>
			c7f: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 c83:	mov    rsp,rbp
 c86:	pop    rbp
 c87:	ret

0000000000000c88 <botlish_fn_4: clean_ai_text<str>>:
 c88:	push   rbp
 c89:	mov    rbp,rsp
 c8c:	sub    rsp,0x10
 c90:	mov    QWORD PTR [rsp],rbx
 c94:	mov    QWORD PTR [rsp+0x8],r15
 c99:	mov    r15,QWORD PTR [rdi]
 c9c:	mov    rax,QWORD PTR [rdi+0x8]
 ca0:	lea    rcx,[r15+0x20]
 ca4:	cmp    rcx,rax
 ca7:	ja     d42 <botlish_fn_4+0xba>
 cad:	lea    rax,[r15+0x20]
 cb1:	mov    QWORD PTR [rdi],rax
 cb4:	mov    QWORD PTR [r15],0x0
 cbb:	mov    QWORD PTR [r15+0x8],0x0
 cc3:	mov    QWORD PTR [r15+0x10],0x0
 ccb:	mov    QWORD PTR [r15+0x18],0x0
 cd3:	mov    QWORD PTR [r15],rsi
 cd6:	mov    r8d,0x1
 cdc:	mov    QWORD PTR [r15+0x8],0x1
 ce4:	mov    rax,QWORD PTR [rdi+0x10]
 ce8:	mov    rbx,rdi
 ceb:	mov    rcx,QWORD PTR [rax+0x90]
 cf2:	mov    QWORD PTR [r15+0x10],rcx
 cf6:	mov    QWORD PTR [r15+0x18],0x1
 cfe:	mov    rdx,r8
 d01:	call   d06 <botlish_fn_4+0x7e>
			d02: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 d06:	test   rax,rax
 d09:	jne    d2a <botlish_fn_4+0xa2>
 d0f:	mov    rdi,rbx
 d12:	mov    QWORD PTR [rdi],r15
 d15:	xor    rax,rax
 d18:	mov    rbx,QWORD PTR [rsp]
 d1c:	mov    r15,QWORD PTR [rsp+0x8]
 d21:	add    rsp,0x10
 d25:	mov    rsp,rbp
 d28:	pop    rbp
 d29:	ret
 d2a:	mov    rdi,rbx
 d2d:	mov    QWORD PTR [rdi],r15
 d30:	mov    rbx,QWORD PTR [rsp]
 d34:	mov    r15,QWORD PTR [rsp+0x8]
 d39:	add    rsp,0x10
 d3d:	mov    rsp,rbp
 d40:	pop    rbp
 d41:	ret
 d42:	call   d47 <botlish_fn_4+0xbf>
			d43: R_X86_64_PLT32	rt_stack_overflow-0x4
 d47:	xor    rax,rax
 d4a:	mov    rbx,QWORD PTR [rsp]
 d4e:	mov    r15,QWORD PTR [rsp+0x8]
 d53:	add    rsp,0x10
 d57:	mov    rsp,rbp
 d5a:	pop    rbp
 d5b:	ret

0000000000000d5c <botlish_entry_4: clean_ai_text<str>>:
 d5c:	push   rbp
 d5d:	mov    rbp,rsp
 d60:	mov    rsi,QWORD PTR [rdx]
 d63:	call   d68 <botlish_entry_4+0xc>
			d64: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 d68:	mov    rsp,rbp
 d6b:	pop    rbp
 d6c:	ret

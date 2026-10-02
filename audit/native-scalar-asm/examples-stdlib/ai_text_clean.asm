; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2425  (per function: 505 547 493 776 104)
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
 1f5:	cmp    rsi,0x1f600
 1fc:	je     225 <botlish_fn_1+0x34>
 202:	cmp    rsi,0x1f602
 209:	je     21a <botlish_fn_1+0x29>
 20f:	mov    r8d,0x2
 215:	jmp    22b <botlish_fn_1+0x3a>
 21a:	mov    r8d,0x6
 220:	jmp    22b <botlish_fn_1+0x3a>
 225:	mov    r8d,0x6
 22b:	mov    eax,0x6
 230:	cmp    r8,0x6
 234:	je     259 <botlish_fn_1+0x68>
 23a:	cmp    rsi,0x1f642
 241:	je     251 <botlish_fn_1+0x60>
 247:	mov    ecx,0x2
 24c:	jmp    25c <botlish_fn_1+0x6b>
 251:	mov    rcx,rax
 254:	jmp    25c <botlish_fn_1+0x6b>
 259:	mov    rcx,rax
 25c:	cmp    rcx,0x6
 260:	je     285 <botlish_fn_1+0x94>
 266:	cmp    rsi,0x1f60d
 26d:	je     27d <botlish_fn_1+0x8c>
 273:	mov    ecx,0x2
 278:	jmp    288 <botlish_fn_1+0x97>
 27d:	mov    rcx,rax
 280:	jmp    288 <botlish_fn_1+0x97>
 285:	mov    rcx,rax
 288:	cmp    rcx,0x6
 28c:	je     2b1 <botlish_fn_1+0xc0>
 292:	cmp    rsi,0x1f525
 299:	je     2a9 <botlish_fn_1+0xb8>
 29f:	mov    ecx,0x2
 2a4:	jmp    2b4 <botlish_fn_1+0xc3>
 2a9:	mov    rcx,rax
 2ac:	jmp    2b4 <botlish_fn_1+0xc3>
 2b1:	mov    rcx,rax
 2b4:	cmp    rcx,0x6
 2b8:	je     2dd <botlish_fn_1+0xec>
 2be:	cmp    rsi,0x1f680
 2c5:	je     2d5 <botlish_fn_1+0xe4>
 2cb:	mov    ecx,0x2
 2d0:	jmp    2e0 <botlish_fn_1+0xef>
 2d5:	mov    rcx,rax
 2d8:	jmp    2e0 <botlish_fn_1+0xef>
 2dd:	mov    rcx,rax
 2e0:	cmp    rcx,0x6
 2e4:	je     309 <botlish_fn_1+0x118>
 2ea:	cmp    rsi,0x2705
 2f1:	je     301 <botlish_fn_1+0x110>
 2f7:	mov    edi,0x2
 2fc:	jmp    30c <botlish_fn_1+0x11b>
 301:	mov    rdi,rax
 304:	jmp    30c <botlish_fn_1+0x11b>
 309:	mov    rdi,rax
 30c:	cmp    rdi,0x6
 310:	je     335 <botlish_fn_1+0x144>
 316:	cmp    rsi,0x274c
 31d:	je     32d <botlish_fn_1+0x13c>
 323:	mov    ecx,0x2
 328:	jmp    338 <botlish_fn_1+0x147>
 32d:	mov    rcx,rax
 330:	jmp    338 <botlish_fn_1+0x147>
 335:	mov    rcx,rax
 338:	cmp    rcx,0x6
 33c:	je     361 <botlish_fn_1+0x170>
 342:	cmp    rsi,0x1f389
 349:	je     359 <botlish_fn_1+0x168>
 34f:	mov    ecx,0x2
 354:	jmp    364 <botlish_fn_1+0x173>
 359:	mov    rcx,rax
 35c:	jmp    364 <botlish_fn_1+0x173>
 361:	mov    rcx,rax
 364:	cmp    rcx,0x6
 368:	je     38d <botlish_fn_1+0x19c>
 36e:	cmp    rsi,0x1f916
 375:	je     385 <botlish_fn_1+0x194>
 37b:	mov    ecx,0x2
 380:	jmp    390 <botlish_fn_1+0x19f>
 385:	mov    rcx,rax
 388:	jmp    390 <botlish_fn_1+0x19f>
 38d:	mov    rcx,rax
 390:	cmp    rcx,0x6
 394:	je     3b9 <botlish_fn_1+0x1c8>
 39a:	cmp    rsi,0x1f44d
 3a1:	je     3b1 <botlish_fn_1+0x1c0>
 3a7:	mov    ecx,0x2
 3ac:	jmp    3bc <botlish_fn_1+0x1cb>
 3b1:	mov    rcx,rax
 3b4:	jmp    3bc <botlish_fn_1+0x1cb>
 3b9:	mov    rcx,rax
 3bc:	cmp    rcx,0x6
 3c0:	je     3d8 <botlish_fn_1+0x1e7>
 3c6:	cmp    rsi,0x1f4a1
 3cd:	je     3d8 <botlish_fn_1+0x1e7>
 3d3:	mov    eax,0x2
 3d8:	mov    rsp,rbp
 3db:	pop    rbp
 3dc:	ret

00000000000003dd <botlish_entry_1: cleaner_emoji<str>>:
 3dd:	push   rbp
 3de:	mov    rbp,rsp
 3e1:	sub    rsp,0x10
 3e5:	mov    QWORD PTR [rsp],r12
 3e9:	mov    r12,rdi
 3ec:	mov    rsi,QWORD PTR [rdx]
 3ef:	mov    r8,QWORD PTR [rip+0x0]        # 3f6 <botlish_entry_1+0x19>
			3f2: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 3f6:	call   r8
 3f9:	mov    rsi,rax
 3fc:	mov    rdi,r12
 3ff:	call   404 <botlish_entry_1+0x27>
			400: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 404:	mov    r12,QWORD PTR [rsp]
 408:	add    rsp,0x10
 40c:	mov    rsp,rbp
 40f:	pop    rbp
 410:	ret

0000000000000411 <botlish_fn_2: clean_char<str>>:
 411:	push   rbp
 412:	mov    rbp,rsp
 415:	sub    rsp,0x10
 419:	mov    QWORD PTR [rsp],rbx
 41d:	mov    QWORD PTR [rsp+0x8],r12
 422:	mov    r12,rdi
 425:	mov    rbx,rsi
 428:	mov    rdi,r12
 42b:	call   430 <botlish_fn_2+0x1f>
			42c: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 430:	cmp    rax,0x6
 434:	je     58f <botlish_fn_2+0x17e>
 43a:	cmp    rbx,0x2013
 441:	je     468 <botlish_fn_2+0x57>
 447:	cmp    rbx,0x2014
 44e:	je     45e <botlish_fn_2+0x4d>
 454:	mov    ecx,0x2
 459:	jmp    46d <botlish_fn_2+0x5c>
 45e:	mov    ecx,0x6
 463:	jmp    46d <botlish_fn_2+0x5c>
 468:	mov    ecx,0x6
 46d:	cmp    rcx,0x6
 471:	je     572 <botlish_fn_2+0x161>
 477:	cmp    rbx,0x2018
 47e:	je     4a5 <botlish_fn_2+0x94>
 484:	cmp    rbx,0x2019
 48b:	je     49b <botlish_fn_2+0x8a>
 491:	mov    ecx,0x2
 496:	jmp    4aa <botlish_fn_2+0x99>
 49b:	mov    ecx,0x6
 4a0:	jmp    4aa <botlish_fn_2+0x99>
 4a5:	mov    ecx,0x6
 4aa:	cmp    rcx,0x6
 4ae:	je     555 <botlish_fn_2+0x144>
 4b4:	cmp    rbx,0x201c
 4bb:	je     4e2 <botlish_fn_2+0xd1>
 4c1:	cmp    rbx,0x201d
 4c8:	je     4d8 <botlish_fn_2+0xc7>
 4ce:	mov    ecx,0x2
 4d3:	jmp    4e7 <botlish_fn_2+0xd6>
 4d8:	mov    ecx,0x6
 4dd:	jmp    4e7 <botlish_fn_2+0xd6>
 4e2:	mov    ecx,0x6
 4e7:	cmp    rcx,0x6
 4eb:	je     538 <botlish_fn_2+0x127>
 4f1:	cmp    rbx,0x2026
 4f8:	je     51b <botlish_fn_2+0x10a>
 4fe:	mov    rsi,rbx
 501:	mov    rdi,r12
 504:	call   509 <botlish_fn_2+0xf8>
			505: R_X86_64_PLT32	rt_short_to_str-0x4
 509:	mov    rbx,QWORD PTR [rsp]
 50d:	mov    r12,QWORD PTR [rsp+0x8]
 512:	add    rsp,0x10
 516:	mov    rsp,rbp
 519:	pop    rbp
 51a:	ret
 51b:	mov    rdi,r12
 51e:	mov    rdi,QWORD PTR [rdi+0x10]
 522:	mov    rax,QWORD PTR [rdi+0x50]
 526:	mov    rbx,QWORD PTR [rsp]
 52a:	mov    r12,QWORD PTR [rsp+0x8]
 52f:	add    rsp,0x10
 533:	mov    rsp,rbp
 536:	pop    rbp
 537:	ret
 538:	mov    rdi,r12
 53b:	mov    r8,QWORD PTR [rdi+0x10]
 53f:	mov    rax,QWORD PTR [r8+0x48]
 543:	mov    rbx,QWORD PTR [rsp]
 547:	mov    r12,QWORD PTR [rsp+0x8]
 54c:	add    rsp,0x10
 550:	mov    rsp,rbp
 553:	pop    rbp
 554:	ret
 555:	mov    rdi,r12
 558:	mov    r9,QWORD PTR [rdi+0x10]
 55c:	mov    rax,QWORD PTR [r9+0x40]
 560:	mov    rbx,QWORD PTR [rsp]
 564:	mov    r12,QWORD PTR [rsp+0x8]
 569:	add    rsp,0x10
 56d:	mov    rsp,rbp
 570:	pop    rbp
 571:	ret
 572:	mov    rdi,r12
 575:	mov    r10,QWORD PTR [rdi+0x10]
 579:	mov    rax,QWORD PTR [r10+0x38]
 57d:	mov    rbx,QWORD PTR [rsp]
 581:	mov    r12,QWORD PTR [rsp+0x8]
 586:	add    rsp,0x10
 58a:	mov    rsp,rbp
 58d:	pop    rbp
 58e:	ret
 58f:	mov    rdi,r12
 592:	mov    r11,QWORD PTR [rdi+0x10]
 596:	mov    rax,QWORD PTR [r11+0x30]
 59a:	mov    rbx,QWORD PTR [rsp]
 59e:	mov    r12,QWORD PTR [rsp+0x8]
 5a3:	add    rsp,0x10
 5a7:	mov    rsp,rbp
 5aa:	pop    rbp
 5ab:	ret

00000000000005ac <botlish_entry_2: clean_char<str>>:
 5ac:	push   rbp
 5ad:	mov    rbp,rsp
 5b0:	sub    rsp,0x10
 5b4:	mov    QWORD PTR [rsp],r12
 5b8:	mov    r12,rdi
 5bb:	mov    rsi,QWORD PTR [rdx]
 5be:	mov    r8,QWORD PTR [rip+0x0]        # 5c5 <botlish_entry_2+0x19>
			5c1: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 5c5:	call   r8
 5c8:	mov    rsi,rax
 5cb:	mov    rdi,r12
 5ce:	call   5d3 <botlish_entry_2+0x27>
			5cf: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 5d3:	mov    r8,QWORD PTR [rip+0x0]        # 5da <botlish_entry_2+0x2e>
			5d6: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
 5da:	mov    rsi,rax
 5dd:	mov    rdi,r12
 5e0:	call   r8
 5e3:	mov    r12,QWORD PTR [rsp]
 5e7:	add    rsp,0x10
 5eb:	mov    rsp,rbp
 5ee:	pop    rbp
 5ef:	ret

00000000000005f0 <botlish_fn_3: clean_from<str, int, str>>:
 5f0:	push   rbp
 5f1:	mov    rbp,rsp
 5f4:	sub    rsp,0xa0
 5fb:	mov    QWORD PTR [rsp+0x70],rbx
 600:	mov    QWORD PTR [rsp+0x78],r12
 605:	mov    QWORD PTR [rsp+0x80],r13
 60d:	mov    QWORD PTR [rsp+0x88],r14
 615:	mov    QWORD PTR [rsp+0x90],r15
 61d:	mov    r14,rdi
 620:	mov    QWORD PTR [rsp+0x18],0x0
 629:	mov    QWORD PTR [rsp+0x20],0x0
 632:	mov    QWORD PTR [rsp],rsi
 636:	mov    QWORD PTR [rsp+0x8],rcx
 63b:	mov    r15,rcx
 63e:	mov    QWORD PTR [rsp+0x10],r8
 643:	sar    rdx,1
 646:	mov    r12,rdx
 649:	lea    r13,[rsp+0x38]
 64e:	mov    rbx,rsi
 651:	mov    QWORD PTR [rsp+0x60],r8
 656:	mov    rsi,rbx
 659:	mov    rdi,r14
 65c:	call   661 <botlish_fn_3+0x71>
			65d: R_X86_64_PLT32	rt_str_len-0x4
 661:	sar    rax,1
 664:	cmp    r12,rax
 667:	jge    805 <botlish_fn_3+0x215>
 66d:	mov    rsi,rbx
 670:	mov    rdi,r14
 673:	call   678 <botlish_fn_3+0x88>
			674: R_X86_64_PLT32	rt_str_len-0x4
 678:	mov    rsi,r12
 67b:	shl    rsi,1
 67e:	or     rsi,0x1
 682:	mov    rcx,rsi
 685:	and    rcx,rax
 688:	mov    rdx,rax
 68b:	test   rcx,0x1
 692:	jne    6b5 <botlish_fn_3+0xc5>
 698:	mov    rdi,r14
 69b:	call   6a0 <botlish_fn_3+0xb0>
			69c: R_X86_64_PLT32	rt_int_cmp-0x4
 6a0:	mov    ecx,0x2
 6a5:	test   rax,rax
 6a8:	cmovge rcx,QWORD PTR [rip+0x1e8]        # 898 <botlish_fn_3+0x2a8>
 6b0:	jmp    6c5 <botlish_fn_3+0xd5>
 6b5:	mov    ecx,0x2
 6ba:	cmp    rsi,rdx
 6bd:	cmovge rcx,QWORD PTR [rip+0x1d3]        # 898 <botlish_fn_3+0x2a8>
 6c5:	cmp    rcx,0x6
 6c9:	je     772 <botlish_fn_3+0x182>
 6cf:	mov    rdx,QWORD PTR [rsp+0x60]
 6d4:	mov    rsi,rbx
 6d7:	mov    rdi,r14
 6da:	call   6df <botlish_fn_3+0xef>
			6db: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 6df:	mov    QWORD PTR [rsp+0x18],rax
 6e4:	mov    QWORD PTR [rsp+0x58],rax
 6e9:	mov    rsi,QWORD PTR [rsp+0x58]
 6ee:	mov    rdi,r14
 6f1:	call   6f6 <botlish_fn_3+0x106>
			6f2: R_X86_64_PLT32	rt_str_byte_len-0x4
 6f6:	mov    QWORD PTR [rsp+0x20],rax
 6fb:	mov    rsi,QWORD PTR [rsp+0x60]
 700:	and    rsi,rax
 703:	test   rsi,0x1
 70a:	jne    71d <botlish_fn_3+0x12d>
 710:	mov    rdx,rax
 713:	mov    rsi,QWORD PTR [rsp+0x60]
 718:	jmp    753 <botlish_fn_3+0x163>
 71d:	lea    r9,[rax-0x1]
 721:	mov    rdx,rax
 724:	mov    rsi,QWORD PTR [rsp+0x60]
 729:	mov    r8,rsi
 72c:	add    r8,r9
 72f:	seto   r10b
 733:	test   r10b,r10b
 736:	je     746 <botlish_fn_3+0x156>
 73c:	mov    rsi,QWORD PTR [rsp+0x60]
 741:	jmp    753 <botlish_fn_3+0x163>
 746:	mov    rsi,r8
 749:	mov    QWORD PTR [rsp+0x60],r8
 74e:	jmp    763 <botlish_fn_3+0x173>
 753:	mov    rdi,r14
 756:	call   75b <botlish_fn_3+0x16b>
			757: R_X86_64_PLT32	rt_int_add-0x4
 75b:	mov    rsi,rax
 75e:	mov    QWORD PTR [rsp+0x60],rax
 763:	mov    QWORD PTR [rsp+0x10],rsi
 768:	mov    rax,QWORD PTR [rsp+0x58]
 76d:	jmp    787 <botlish_fn_3+0x197>
 772:	mov    rdi,r14
 775:	mov    rax,QWORD PTR [rdi+0x10]
 779:	mov    rax,QWORD PTR [rax+0x30]
 77d:	mov    rsi,QWORD PTR [rsp+0x60]
 782:	mov    QWORD PTR [rsp+0x10],rsi
 787:	mov    rcx,QWORD PTR [rax+0x8]
 78b:	mov    esi,DWORD PTR [rax+0x14]
 78e:	test   rcx,rcx
 791:	cmove  rsi,QWORD PTR [rip+0x107]        # 8a0 <botlish_fn_3+0x2b0>
 799:	mov    rdi,r14
 79c:	call   7a1 <botlish_fn_3+0x1b1>
			79d: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 7a1:	mov    QWORD PTR [rsp+0x18],rax
 7a6:	mov    QWORD PTR [rsp+0x38],0x0
 7af:	mov    rcx,r15
 7b2:	mov    QWORD PTR [rsp+0x40],rcx
 7b7:	mov    QWORD PTR [rsp+0x48],0x0
 7c0:	mov    QWORD PTR [rsp+0x50],rax
 7c5:	mov    esi,0x2
 7ca:	mov    edx,0x4
 7cf:	mov    rcx,r13
 7d2:	mov    rdi,r14
 7d5:	call   7da <botlish_fn_3+0x1ea>
			7d6: R_X86_64_PLT32	rt_construct-0x4
 7da:	test   rax,rax
 7dd:	je     837 <botlish_fn_3+0x247>
 7e3:	mov    QWORD PTR [rsp],rbx
 7e7:	mov    QWORD PTR [rsp+0x8],rax
 7ec:	mov    rsi,QWORD PTR [rsp+0x60]
 7f1:	mov    QWORD PTR [rsp+0x10],rsi
 7f6:	add    r12,0x1
 7fd:	mov    r15,rax
 800:	jmp    656 <botlish_fn_3+0x66>
 805:	mov    rcx,r15
 808:	xor    rsi,rsi
 80b:	lea    rax,[rsp+0x28]
 810:	mov    QWORD PTR [rsp+0x28],0x0
 819:	mov    QWORD PTR [rsp+0x30],rcx
 81e:	mov    edx,0x2
 823:	mov    rcx,rax
 826:	mov    rdi,r14
 829:	call   82e <botlish_fn_3+0x23e>
			82a: R_X86_64_PLT32	rt_construct-0x4
 82e:	test   rax,rax
 831:	jne    868 <botlish_fn_3+0x278>
 837:	xor    rax,rax
 83a:	mov    rbx,QWORD PTR [rsp+0x70]
 83f:	mov    r12,QWORD PTR [rsp+0x78]
 844:	mov    r13,QWORD PTR [rsp+0x80]
 84c:	mov    r14,QWORD PTR [rsp+0x88]
 854:	mov    r15,QWORD PTR [rsp+0x90]
 85c:	add    rsp,0xa0
 863:	mov    rsp,rbp
 866:	pop    rbp
 867:	ret
 868:	mov    rbx,QWORD PTR [rsp+0x70]
 86d:	mov    r12,QWORD PTR [rsp+0x78]
 872:	mov    r13,QWORD PTR [rsp+0x80]
 87a:	mov    r14,QWORD PTR [rsp+0x88]
 882:	mov    r15,QWORD PTR [rsp+0x90]
 88a:	add    rsp,0xa0
 891:	mov    rsp,rbp
 894:	pop    rbp
 895:	ret
 896:	add    BYTE PTR [rax],al
 898:	(bad)
 899:	add    BYTE PTR [rax],al
 89b:	add    BYTE PTR [rax],al
 89d:	add    BYTE PTR [rax],al
 89f:	add    bh,bh
 8a1:	(bad)
 8a2:	(bad)
 8a3:	(bad)
 8a4:	(bad)
 8a5:	(bad)
 8a6:	(bad)
 8a7:	.byte 0xff

00000000000008a8 <botlish_entry_3: clean_from<str, int, str>>:
 8a8:	push   rbp
 8a9:	mov    rbp,rsp
 8ac:	mov    rsi,QWORD PTR [rdx]
 8af:	mov    r9,QWORD PTR [rdx+0x8]
 8b3:	mov    rcx,QWORD PTR [rdx+0x10]
 8b7:	mov    r8,QWORD PTR [rdx+0x18]
 8bb:	mov    rdx,r9
 8be:	call   8c3 <botlish_entry_3+0x1b>
			8bf: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 8c3:	mov    rsp,rbp
 8c6:	pop    rbp
 8c7:	ret

00000000000008c8 <botlish_fn_4: clean_ai_text<str>>:
 8c8:	push   rbp
 8c9:	mov    rbp,rsp
 8cc:	sub    rsp,0x20
 8d0:	mov    QWORD PTR [rsp],rsi
 8d4:	mov    r8d,0x1
 8da:	mov    QWORD PTR [rsp+0x8],0x1
 8e3:	mov    r11,QWORD PTR [rdi+0x10]
 8e7:	mov    rcx,QWORD PTR [r11+0x30]
 8eb:	mov    QWORD PTR [rsp+0x10],rcx
 8f0:	mov    QWORD PTR [rsp+0x18],0x1
 8f9:	mov    rdx,r8
 8fc:	call   901 <botlish_fn_4+0x39>
			8fd: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 901:	test   rax,rax
 904:	jne    916 <botlish_fn_4+0x4e>
 90a:	xor    rax,rax
 90d:	add    rsp,0x20
 911:	mov    rsp,rbp
 914:	pop    rbp
 915:	ret
 916:	add    rsp,0x20
 91a:	mov    rsp,rbp
 91d:	pop    rbp
 91e:	ret

000000000000091f <botlish_entry_4: clean_ai_text<str>>:
 91f:	push   rbp
 920:	mov    rbp,rsp
 923:	mov    rsi,QWORD PTR [rdx]
 926:	call   92b <botlish_entry_4+0xc>
			927: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 92b:	mov    rsp,rbp
 92e:	pop    rbp
 92f:	ret

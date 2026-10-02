; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2473  (per function: 505 547 541 776 104)
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
 422:	mov    rbx,rsi
 425:	mov    r12,rdi
 428:	mov    rsi,rbx
 42b:	mov    rdi,r12
 42e:	call   433 <botlish_fn_2+0x22>
			42f: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 433:	cmp    rax,0x6
 437:	je     5c0 <botlish_fn_2+0x1af>
 43d:	mov    rsi,rbx
 440:	cmp    rsi,0x2013
 447:	je     46e <botlish_fn_2+0x5d>
 44d:	cmp    rsi,0x2014
 454:	je     464 <botlish_fn_2+0x53>
 45a:	mov    eax,0x2
 45f:	jmp    473 <botlish_fn_2+0x62>
 464:	mov    eax,0x6
 469:	jmp    473 <botlish_fn_2+0x62>
 46e:	mov    eax,0x6
 473:	cmp    rax,0x6
 477:	je     5a3 <botlish_fn_2+0x192>
 47d:	cmp    rsi,0x2018
 484:	je     4ab <botlish_fn_2+0x9a>
 48a:	cmp    rsi,0x2019
 491:	je     4a1 <botlish_fn_2+0x90>
 497:	mov    eax,0x2
 49c:	jmp    4b0 <botlish_fn_2+0x9f>
 4a1:	mov    eax,0x6
 4a6:	jmp    4b0 <botlish_fn_2+0x9f>
 4ab:	mov    eax,0x6
 4b0:	cmp    rax,0x6
 4b4:	je     586 <botlish_fn_2+0x175>
 4ba:	cmp    rsi,0x201c
 4c1:	je     4e8 <botlish_fn_2+0xd7>
 4c7:	cmp    rsi,0x201d
 4ce:	je     4de <botlish_fn_2+0xcd>
 4d4:	mov    eax,0x2
 4d9:	jmp    4ed <botlish_fn_2+0xdc>
 4de:	mov    eax,0x6
 4e3:	jmp    4ed <botlish_fn_2+0xdc>
 4e8:	mov    eax,0x6
 4ed:	cmp    rax,0x6
 4f1:	je     569 <botlish_fn_2+0x158>
 4f7:	cmp    rsi,0x2026
 4fe:	je     54c <botlish_fn_2+0x13b>
 504:	lea    r10,[rsi+0x1]
 508:	cmp    r10,0x101
 50f:	jb     51d <botlish_fn_2+0x10c>
 515:	mov    rdi,r12
 518:	jmp    535 <botlish_fn_2+0x124>
 51d:	lea    rax,[rsi+0x1]
 521:	mov    rdi,r12
 524:	mov    rax,QWORD PTR [rdi+rax*8+0x648]
 52c:	test   rax,rax
 52f:	jne    53a <botlish_fn_2+0x129>
 535:	call   53a <botlish_fn_2+0x129>
			536: R_X86_64_PLT32	rt_short_to_str-0x4
 53a:	mov    rbx,QWORD PTR [rsp]
 53e:	mov    r12,QWORD PTR [rsp+0x8]
 543:	add    rsp,0x10
 547:	mov    rsp,rbp
 54a:	pop    rbp
 54b:	ret
 54c:	mov    rdi,r12
 54f:	mov    rax,QWORD PTR [rdi+0x10]
 553:	mov    rax,QWORD PTR [rax+0x50]
 557:	mov    rbx,QWORD PTR [rsp]
 55b:	mov    r12,QWORD PTR [rsp+0x8]
 560:	add    rsp,0x10
 564:	mov    rsp,rbp
 567:	pop    rbp
 568:	ret
 569:	mov    rdi,r12
 56c:	mov    rax,QWORD PTR [rdi+0x10]
 570:	mov    rax,QWORD PTR [rax+0x48]
 574:	mov    rbx,QWORD PTR [rsp]
 578:	mov    r12,QWORD PTR [rsp+0x8]
 57d:	add    rsp,0x10
 581:	mov    rsp,rbp
 584:	pop    rbp
 585:	ret
 586:	mov    rdi,r12
 589:	mov    rax,QWORD PTR [rdi+0x10]
 58d:	mov    rax,QWORD PTR [rax+0x40]
 591:	mov    rbx,QWORD PTR [rsp]
 595:	mov    r12,QWORD PTR [rsp+0x8]
 59a:	add    rsp,0x10
 59e:	mov    rsp,rbp
 5a1:	pop    rbp
 5a2:	ret
 5a3:	mov    rdi,r12
 5a6:	mov    rax,QWORD PTR [rdi+0x10]
 5aa:	mov    rax,QWORD PTR [rax+0x38]
 5ae:	mov    rbx,QWORD PTR [rsp]
 5b2:	mov    r12,QWORD PTR [rsp+0x8]
 5b7:	add    rsp,0x10
 5bb:	mov    rsp,rbp
 5be:	pop    rbp
 5bf:	ret
 5c0:	mov    rdi,r12
 5c3:	mov    rax,QWORD PTR [rdi+0x10]
 5c7:	mov    rax,QWORD PTR [rax+0x30]
 5cb:	mov    rbx,QWORD PTR [rsp]
 5cf:	mov    r12,QWORD PTR [rsp+0x8]
 5d4:	add    rsp,0x10
 5d8:	mov    rsp,rbp
 5db:	pop    rbp
 5dc:	ret

00000000000005dd <botlish_entry_2: clean_char<str>>:
 5dd:	push   rbp
 5de:	mov    rbp,rsp
 5e1:	sub    rsp,0x10
 5e5:	mov    QWORD PTR [rsp],r12
 5e9:	mov    r12,rdi
 5ec:	mov    rsi,QWORD PTR [rdx]
 5ef:	mov    r8,QWORD PTR [rip+0x0]        # 5f6 <botlish_entry_2+0x19>
			5f2: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 5f6:	call   r8
 5f9:	mov    rsi,rax
 5fc:	mov    rdi,r12
 5ff:	call   604 <botlish_entry_2+0x27>
			600: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 604:	mov    r8,QWORD PTR [rip+0x0]        # 60b <botlish_entry_2+0x2e>
			607: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
 60b:	mov    rsi,rax
 60e:	mov    rdi,r12
 611:	call   r8
 614:	mov    r12,QWORD PTR [rsp]
 618:	add    rsp,0x10
 61c:	mov    rsp,rbp
 61f:	pop    rbp
 620:	ret
 621:	add    BYTE PTR [rax],al
 623:	add    BYTE PTR [rax],al
 625:	add    BYTE PTR [rax],al
	...

0000000000000628 <botlish_fn_3: clean_from<str, int, str>>:
 628:	push   rbp
 629:	mov    rbp,rsp
 62c:	sub    rsp,0xa0
 633:	mov    QWORD PTR [rsp+0x70],rbx
 638:	mov    QWORD PTR [rsp+0x78],r12
 63d:	mov    QWORD PTR [rsp+0x80],r13
 645:	mov    QWORD PTR [rsp+0x88],r14
 64d:	mov    QWORD PTR [rsp+0x90],r15
 655:	mov    r14,rdi
 658:	mov    QWORD PTR [rsp+0x18],0x0
 661:	mov    QWORD PTR [rsp+0x20],0x0
 66a:	mov    QWORD PTR [rsp],rsi
 66e:	mov    QWORD PTR [rsp+0x8],rcx
 673:	mov    r15,rcx
 676:	mov    QWORD PTR [rsp+0x10],r8
 67b:	sar    rdx,1
 67e:	mov    r12,rdx
 681:	lea    r13,[rsp+0x38]
 686:	mov    rbx,rsi
 689:	mov    QWORD PTR [rsp+0x60],r8
 68e:	mov    rsi,rbx
 691:	mov    rdi,r14
 694:	call   699 <botlish_fn_3+0x71>
			695: R_X86_64_PLT32	rt_str_len-0x4
 699:	sar    rax,1
 69c:	cmp    r12,rax
 69f:	jge    83d <botlish_fn_3+0x215>
 6a5:	mov    rsi,rbx
 6a8:	mov    rdi,r14
 6ab:	call   6b0 <botlish_fn_3+0x88>
			6ac: R_X86_64_PLT32	rt_str_len-0x4
 6b0:	mov    rsi,r12
 6b3:	shl    rsi,1
 6b6:	or     rsi,0x1
 6ba:	mov    rcx,rsi
 6bd:	and    rcx,rax
 6c0:	mov    rdx,rax
 6c3:	test   rcx,0x1
 6ca:	jne    6ed <botlish_fn_3+0xc5>
 6d0:	mov    rdi,r14
 6d3:	call   6d8 <botlish_fn_3+0xb0>
			6d4: R_X86_64_PLT32	rt_int_cmp-0x4
 6d8:	mov    ecx,0x2
 6dd:	test   rax,rax
 6e0:	cmovge rcx,QWORD PTR [rip+0x1e8]        # 8d0 <botlish_fn_3+0x2a8>
 6e8:	jmp    6fd <botlish_fn_3+0xd5>
 6ed:	mov    ecx,0x2
 6f2:	cmp    rsi,rdx
 6f5:	cmovge rcx,QWORD PTR [rip+0x1d3]        # 8d0 <botlish_fn_3+0x2a8>
 6fd:	cmp    rcx,0x6
 701:	je     7aa <botlish_fn_3+0x182>
 707:	mov    rdx,QWORD PTR [rsp+0x60]
 70c:	mov    rsi,rbx
 70f:	mov    rdi,r14
 712:	call   717 <botlish_fn_3+0xef>
			713: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 717:	mov    QWORD PTR [rsp+0x18],rax
 71c:	mov    QWORD PTR [rsp+0x58],rax
 721:	mov    rsi,QWORD PTR [rsp+0x58]
 726:	mov    rdi,r14
 729:	call   72e <botlish_fn_3+0x106>
			72a: R_X86_64_PLT32	rt_str_byte_len-0x4
 72e:	mov    QWORD PTR [rsp+0x20],rax
 733:	mov    rsi,QWORD PTR [rsp+0x60]
 738:	and    rsi,rax
 73b:	test   rsi,0x1
 742:	jne    755 <botlish_fn_3+0x12d>
 748:	mov    rdx,rax
 74b:	mov    rsi,QWORD PTR [rsp+0x60]
 750:	jmp    78b <botlish_fn_3+0x163>
 755:	lea    r9,[rax-0x1]
 759:	mov    rdx,rax
 75c:	mov    rsi,QWORD PTR [rsp+0x60]
 761:	mov    r8,rsi
 764:	add    r8,r9
 767:	seto   r10b
 76b:	test   r10b,r10b
 76e:	je     77e <botlish_fn_3+0x156>
 774:	mov    rsi,QWORD PTR [rsp+0x60]
 779:	jmp    78b <botlish_fn_3+0x163>
 77e:	mov    rsi,r8
 781:	mov    QWORD PTR [rsp+0x60],r8
 786:	jmp    79b <botlish_fn_3+0x173>
 78b:	mov    rdi,r14
 78e:	call   793 <botlish_fn_3+0x16b>
			78f: R_X86_64_PLT32	rt_int_add-0x4
 793:	mov    rsi,rax
 796:	mov    QWORD PTR [rsp+0x60],rax
 79b:	mov    QWORD PTR [rsp+0x10],rsi
 7a0:	mov    rax,QWORD PTR [rsp+0x58]
 7a5:	jmp    7bf <botlish_fn_3+0x197>
 7aa:	mov    rdi,r14
 7ad:	mov    rax,QWORD PTR [rdi+0x10]
 7b1:	mov    rax,QWORD PTR [rax+0x30]
 7b5:	mov    rsi,QWORD PTR [rsp+0x60]
 7ba:	mov    QWORD PTR [rsp+0x10],rsi
 7bf:	mov    rcx,QWORD PTR [rax+0x8]
 7c3:	mov    esi,DWORD PTR [rax+0x14]
 7c6:	test   rcx,rcx
 7c9:	cmove  rsi,QWORD PTR [rip+0x107]        # 8d8 <botlish_fn_3+0x2b0>
 7d1:	mov    rdi,r14
 7d4:	call   7d9 <botlish_fn_3+0x1b1>
			7d5: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 7d9:	mov    QWORD PTR [rsp+0x18],rax
 7de:	mov    QWORD PTR [rsp+0x38],0x0
 7e7:	mov    rcx,r15
 7ea:	mov    QWORD PTR [rsp+0x40],rcx
 7ef:	mov    QWORD PTR [rsp+0x48],0x0
 7f8:	mov    QWORD PTR [rsp+0x50],rax
 7fd:	mov    esi,0x2
 802:	mov    edx,0x4
 807:	mov    rcx,r13
 80a:	mov    rdi,r14
 80d:	call   812 <botlish_fn_3+0x1ea>
			80e: R_X86_64_PLT32	rt_construct-0x4
 812:	test   rax,rax
 815:	je     86f <botlish_fn_3+0x247>
 81b:	mov    QWORD PTR [rsp],rbx
 81f:	mov    QWORD PTR [rsp+0x8],rax
 824:	mov    rsi,QWORD PTR [rsp+0x60]
 829:	mov    QWORD PTR [rsp+0x10],rsi
 82e:	add    r12,0x1
 835:	mov    r15,rax
 838:	jmp    68e <botlish_fn_3+0x66>
 83d:	mov    rcx,r15
 840:	xor    rsi,rsi
 843:	lea    rax,[rsp+0x28]
 848:	mov    QWORD PTR [rsp+0x28],0x0
 851:	mov    QWORD PTR [rsp+0x30],rcx
 856:	mov    edx,0x2
 85b:	mov    rcx,rax
 85e:	mov    rdi,r14
 861:	call   866 <botlish_fn_3+0x23e>
			862: R_X86_64_PLT32	rt_construct-0x4
 866:	test   rax,rax
 869:	jne    8a0 <botlish_fn_3+0x278>
 86f:	xor    rax,rax
 872:	mov    rbx,QWORD PTR [rsp+0x70]
 877:	mov    r12,QWORD PTR [rsp+0x78]
 87c:	mov    r13,QWORD PTR [rsp+0x80]
 884:	mov    r14,QWORD PTR [rsp+0x88]
 88c:	mov    r15,QWORD PTR [rsp+0x90]
 894:	add    rsp,0xa0
 89b:	mov    rsp,rbp
 89e:	pop    rbp
 89f:	ret
 8a0:	mov    rbx,QWORD PTR [rsp+0x70]
 8a5:	mov    r12,QWORD PTR [rsp+0x78]
 8aa:	mov    r13,QWORD PTR [rsp+0x80]
 8b2:	mov    r14,QWORD PTR [rsp+0x88]
 8ba:	mov    r15,QWORD PTR [rsp+0x90]
 8c2:	add    rsp,0xa0
 8c9:	mov    rsp,rbp
 8cc:	pop    rbp
 8cd:	ret
 8ce:	add    BYTE PTR [rax],al
 8d0:	(bad)
 8d1:	add    BYTE PTR [rax],al
 8d3:	add    BYTE PTR [rax],al
 8d5:	add    BYTE PTR [rax],al
 8d7:	add    bh,bh
 8d9:	(bad)
 8da:	(bad)
 8db:	(bad)
 8dc:	(bad)
 8dd:	(bad)
 8de:	(bad)
 8df:	.byte 0xff

00000000000008e0 <botlish_entry_3: clean_from<str, int, str>>:
 8e0:	push   rbp
 8e1:	mov    rbp,rsp
 8e4:	mov    rsi,QWORD PTR [rdx]
 8e7:	mov    r9,QWORD PTR [rdx+0x8]
 8eb:	mov    rcx,QWORD PTR [rdx+0x10]
 8ef:	mov    r8,QWORD PTR [rdx+0x18]
 8f3:	mov    rdx,r9
 8f6:	call   8fb <botlish_entry_3+0x1b>
			8f7: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 8fb:	mov    rsp,rbp
 8fe:	pop    rbp
 8ff:	ret

0000000000000900 <botlish_fn_4: clean_ai_text<str>>:
 900:	push   rbp
 901:	mov    rbp,rsp
 904:	sub    rsp,0x20
 908:	mov    QWORD PTR [rsp],rsi
 90c:	mov    r8d,0x1
 912:	mov    QWORD PTR [rsp+0x8],0x1
 91b:	mov    r11,QWORD PTR [rdi+0x10]
 91f:	mov    rcx,QWORD PTR [r11+0x30]
 923:	mov    QWORD PTR [rsp+0x10],rcx
 928:	mov    QWORD PTR [rsp+0x18],0x1
 931:	mov    rdx,r8
 934:	call   939 <botlish_fn_4+0x39>
			935: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 939:	test   rax,rax
 93c:	jne    94e <botlish_fn_4+0x4e>
 942:	xor    rax,rax
 945:	add    rsp,0x20
 949:	mov    rsp,rbp
 94c:	pop    rbp
 94d:	ret
 94e:	add    rsp,0x20
 952:	mov    rsp,rbp
 955:	pop    rbp
 956:	ret

0000000000000957 <botlish_entry_4: clean_ai_text<str>>:
 957:	push   rbp
 958:	mov    rbp,rsp
 95b:	mov    rsi,QWORD PTR [rdx]
 95e:	call   963 <botlish_entry_4+0xc>
			95f: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 963:	mov    rsp,rbp
 966:	pop    rbp
 967:	ret

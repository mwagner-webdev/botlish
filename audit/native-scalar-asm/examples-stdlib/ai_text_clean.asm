; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2611  (per function: 147 547 492 816 103 506)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> cleaner_emoji<str>
;   botlish_fn_2 / botlish_entry_2 -> clean_char<str>
;   botlish_fn_3 / botlish_entry_3 -> clean_from<str, int, str>
;   botlish_fn_4 / botlish_entry_4 -> clean_ai_text<str>
;   botlish_fn_5 / botlish_entry_5 -> sample<generic>


ai_text_clean.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    QWORD PTR [rsp],r12
   c:	mov    r12,rdi
   f:	mov    rdi,r12
  12:	call   17 <botlish_fn_0+0x17>
			13: R_X86_64_PLT32	botlish_fn_5-0x4 ; sample<generic>
  17:	test   rax,rax
  1a:	jne    63 <botlish_fn_0+0x63>
  20:	mov    rdi,r12
  23:	call   28 <botlish_fn_0+0x28>
			24: R_X86_64_PLT32	rt_declared_error-0x4
  28:	cmp    rax,0x40000002
  2e:	jne    53 <botlish_fn_0+0x53>
  34:	mov    rdi,r12
  37:	call   3c <botlish_fn_0+0x3c>
			38: R_X86_64_PLT32	rt_clear_declared_error-0x4
  3c:	xor    rdx,rdx
  3f:	mov    rdi,r12
  42:	mov    rsi,rdx
  45:	call   4a <botlish_fn_0+0x4a>
			46: R_X86_64_PLT32	rt_list_new-0x4
  4a:	test   rax,rax
  4d:	jne    63 <botlish_fn_0+0x63>
  53:	xor    rax,rax
  56:	mov    r12,QWORD PTR [rsp]
  5a:	add    rsp,0x10
  5e:	mov    rsp,rbp
  61:	pop    rbp
  62:	ret
  63:	mov    r12,QWORD PTR [rsp]
  67:	add    rsp,0x10
  6b:	mov    rsp,rbp
  6e:	pop    rbp
  6f:	ret

0000000000000070 <botlish_entry_0: <program entry>>:
  70:	push   rbp
  71:	mov    rbp,rsp
  74:	call   79 <botlish_entry_0+0x9>
			75: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  79:	mov    rsp,rbp
  7c:	pop    rbp
  7d:	ret

000000000000007e <botlish_fn_1: cleaner_emoji<str>>:
  7e:	push   rbp
  7f:	mov    rbp,rsp
  82:	cmp    rsi,0x1f600
  89:	je     b2 <botlish_fn_1+0x34>
  8f:	cmp    rsi,0x1f602
  96:	je     a7 <botlish_fn_1+0x29>
  9c:	mov    r8d,0x2
  a2:	jmp    b8 <botlish_fn_1+0x3a>
  a7:	mov    r8d,0x6
  ad:	jmp    b8 <botlish_fn_1+0x3a>
  b2:	mov    r8d,0x6
  b8:	mov    eax,0x6
  bd:	cmp    r8,0x6
  c1:	je     e6 <botlish_fn_1+0x68>
  c7:	cmp    rsi,0x1f642
  ce:	je     de <botlish_fn_1+0x60>
  d4:	mov    ecx,0x2
  d9:	jmp    e9 <botlish_fn_1+0x6b>
  de:	mov    rcx,rax
  e1:	jmp    e9 <botlish_fn_1+0x6b>
  e6:	mov    rcx,rax
  e9:	cmp    rcx,0x6
  ed:	je     112 <botlish_fn_1+0x94>
  f3:	cmp    rsi,0x1f60d
  fa:	je     10a <botlish_fn_1+0x8c>
 100:	mov    ecx,0x2
 105:	jmp    115 <botlish_fn_1+0x97>
 10a:	mov    rcx,rax
 10d:	jmp    115 <botlish_fn_1+0x97>
 112:	mov    rcx,rax
 115:	cmp    rcx,0x6
 119:	je     13e <botlish_fn_1+0xc0>
 11f:	cmp    rsi,0x1f525
 126:	je     136 <botlish_fn_1+0xb8>
 12c:	mov    ecx,0x2
 131:	jmp    141 <botlish_fn_1+0xc3>
 136:	mov    rcx,rax
 139:	jmp    141 <botlish_fn_1+0xc3>
 13e:	mov    rcx,rax
 141:	cmp    rcx,0x6
 145:	je     16a <botlish_fn_1+0xec>
 14b:	cmp    rsi,0x1f680
 152:	je     162 <botlish_fn_1+0xe4>
 158:	mov    ecx,0x2
 15d:	jmp    16d <botlish_fn_1+0xef>
 162:	mov    rcx,rax
 165:	jmp    16d <botlish_fn_1+0xef>
 16a:	mov    rcx,rax
 16d:	cmp    rcx,0x6
 171:	je     196 <botlish_fn_1+0x118>
 177:	cmp    rsi,0x2705
 17e:	je     18e <botlish_fn_1+0x110>
 184:	mov    edi,0x2
 189:	jmp    199 <botlish_fn_1+0x11b>
 18e:	mov    rdi,rax
 191:	jmp    199 <botlish_fn_1+0x11b>
 196:	mov    rdi,rax
 199:	cmp    rdi,0x6
 19d:	je     1c2 <botlish_fn_1+0x144>
 1a3:	cmp    rsi,0x274c
 1aa:	je     1ba <botlish_fn_1+0x13c>
 1b0:	mov    ecx,0x2
 1b5:	jmp    1c5 <botlish_fn_1+0x147>
 1ba:	mov    rcx,rax
 1bd:	jmp    1c5 <botlish_fn_1+0x147>
 1c2:	mov    rcx,rax
 1c5:	cmp    rcx,0x6
 1c9:	je     1ee <botlish_fn_1+0x170>
 1cf:	cmp    rsi,0x1f389
 1d6:	je     1e6 <botlish_fn_1+0x168>
 1dc:	mov    ecx,0x2
 1e1:	jmp    1f1 <botlish_fn_1+0x173>
 1e6:	mov    rcx,rax
 1e9:	jmp    1f1 <botlish_fn_1+0x173>
 1ee:	mov    rcx,rax
 1f1:	cmp    rcx,0x6
 1f5:	je     21a <botlish_fn_1+0x19c>
 1fb:	cmp    rsi,0x1f916
 202:	je     212 <botlish_fn_1+0x194>
 208:	mov    ecx,0x2
 20d:	jmp    21d <botlish_fn_1+0x19f>
 212:	mov    rcx,rax
 215:	jmp    21d <botlish_fn_1+0x19f>
 21a:	mov    rcx,rax
 21d:	cmp    rcx,0x6
 221:	je     246 <botlish_fn_1+0x1c8>
 227:	cmp    rsi,0x1f44d
 22e:	je     23e <botlish_fn_1+0x1c0>
 234:	mov    ecx,0x2
 239:	jmp    249 <botlish_fn_1+0x1cb>
 23e:	mov    rcx,rax
 241:	jmp    249 <botlish_fn_1+0x1cb>
 246:	mov    rcx,rax
 249:	cmp    rcx,0x6
 24d:	je     265 <botlish_fn_1+0x1e7>
 253:	cmp    rsi,0x1f4a1
 25a:	je     265 <botlish_fn_1+0x1e7>
 260:	mov    eax,0x2
 265:	mov    rsp,rbp
 268:	pop    rbp
 269:	ret

000000000000026a <botlish_entry_1: cleaner_emoji<str>>:
 26a:	push   rbp
 26b:	mov    rbp,rsp
 26e:	sub    rsp,0x10
 272:	mov    QWORD PTR [rsp],r12
 276:	mov    r12,rdi
 279:	mov    rsi,QWORD PTR [rdx]
 27c:	mov    r8,QWORD PTR [rip+0x0]        # 283 <botlish_entry_1+0x19>
			27f: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 283:	call   r8
 286:	mov    rsi,rax
 289:	mov    rdi,r12
 28c:	call   291 <botlish_entry_1+0x27>
			28d: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 291:	mov    r12,QWORD PTR [rsp]
 295:	add    rsp,0x10
 299:	mov    rsp,rbp
 29c:	pop    rbp
 29d:	ret

000000000000029e <botlish_fn_2: clean_char<str>>:
 29e:	push   rbp
 29f:	mov    rbp,rsp
 2a2:	sub    rsp,0x10
 2a6:	mov    QWORD PTR [rsp],rbx
 2aa:	mov    QWORD PTR [rsp+0x8],r12
 2af:	mov    r12,rdi
 2b2:	mov    rbx,rsi
 2b5:	mov    rdi,r12
 2b8:	call   2bd <botlish_fn_2+0x1f>
			2b9: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 2bd:	cmp    rax,0x6
 2c1:	je     41c <botlish_fn_2+0x17e>
 2c7:	cmp    rbx,0x2013
 2ce:	je     2f5 <botlish_fn_2+0x57>
 2d4:	cmp    rbx,0x2014
 2db:	je     2eb <botlish_fn_2+0x4d>
 2e1:	mov    ecx,0x2
 2e6:	jmp    2fa <botlish_fn_2+0x5c>
 2eb:	mov    ecx,0x6
 2f0:	jmp    2fa <botlish_fn_2+0x5c>
 2f5:	mov    ecx,0x6
 2fa:	cmp    rcx,0x6
 2fe:	je     3ff <botlish_fn_2+0x161>
 304:	cmp    rbx,0x2018
 30b:	je     332 <botlish_fn_2+0x94>
 311:	cmp    rbx,0x2019
 318:	je     328 <botlish_fn_2+0x8a>
 31e:	mov    ecx,0x2
 323:	jmp    337 <botlish_fn_2+0x99>
 328:	mov    ecx,0x6
 32d:	jmp    337 <botlish_fn_2+0x99>
 332:	mov    ecx,0x6
 337:	cmp    rcx,0x6
 33b:	je     3e2 <botlish_fn_2+0x144>
 341:	cmp    rbx,0x201c
 348:	je     36f <botlish_fn_2+0xd1>
 34e:	cmp    rbx,0x201d
 355:	je     365 <botlish_fn_2+0xc7>
 35b:	mov    ecx,0x2
 360:	jmp    374 <botlish_fn_2+0xd6>
 365:	mov    ecx,0x6
 36a:	jmp    374 <botlish_fn_2+0xd6>
 36f:	mov    ecx,0x6
 374:	cmp    rcx,0x6
 378:	je     3c5 <botlish_fn_2+0x127>
 37e:	cmp    rbx,0x2026
 385:	je     3a8 <botlish_fn_2+0x10a>
 38b:	mov    rsi,rbx
 38e:	mov    rdi,r12
 391:	call   396 <botlish_fn_2+0xf8>
			392: R_X86_64_PLT32	rt_short_to_str-0x4
 396:	mov    rbx,QWORD PTR [rsp]
 39a:	mov    r12,QWORD PTR [rsp+0x8]
 39f:	add    rsp,0x10
 3a3:	mov    rsp,rbp
 3a6:	pop    rbp
 3a7:	ret
 3a8:	mov    rdi,r12
 3ab:	mov    rdi,QWORD PTR [rdi+0x10]
 3af:	mov    rax,QWORD PTR [rdi+0x20]
 3b3:	mov    rbx,QWORD PTR [rsp]
 3b7:	mov    r12,QWORD PTR [rsp+0x8]
 3bc:	add    rsp,0x10
 3c0:	mov    rsp,rbp
 3c3:	pop    rbp
 3c4:	ret
 3c5:	mov    rdi,r12
 3c8:	mov    r8,QWORD PTR [rdi+0x10]
 3cc:	mov    rax,QWORD PTR [r8+0x18]
 3d0:	mov    rbx,QWORD PTR [rsp]
 3d4:	mov    r12,QWORD PTR [rsp+0x8]
 3d9:	add    rsp,0x10
 3dd:	mov    rsp,rbp
 3e0:	pop    rbp
 3e1:	ret
 3e2:	mov    rdi,r12
 3e5:	mov    r9,QWORD PTR [rdi+0x10]
 3e9:	mov    rax,QWORD PTR [r9+0x10]
 3ed:	mov    rbx,QWORD PTR [rsp]
 3f1:	mov    r12,QWORD PTR [rsp+0x8]
 3f6:	add    rsp,0x10
 3fa:	mov    rsp,rbp
 3fd:	pop    rbp
 3fe:	ret
 3ff:	mov    rdi,r12
 402:	mov    r10,QWORD PTR [rdi+0x10]
 406:	mov    rax,QWORD PTR [r10+0x8]
 40a:	mov    rbx,QWORD PTR [rsp]
 40e:	mov    r12,QWORD PTR [rsp+0x8]
 413:	add    rsp,0x10
 417:	mov    rsp,rbp
 41a:	pop    rbp
 41b:	ret
 41c:	mov    rdi,r12
 41f:	mov    r11,QWORD PTR [rdi+0x10]
 423:	mov    rax,QWORD PTR [r11]
 426:	mov    rbx,QWORD PTR [rsp]
 42a:	mov    r12,QWORD PTR [rsp+0x8]
 42f:	add    rsp,0x10
 433:	mov    rsp,rbp
 436:	pop    rbp
 437:	ret

0000000000000438 <botlish_entry_2: clean_char<str>>:
 438:	push   rbp
 439:	mov    rbp,rsp
 43c:	sub    rsp,0x10
 440:	mov    QWORD PTR [rsp],r12
 444:	mov    r12,rdi
 447:	mov    rsi,QWORD PTR [rdx]
 44a:	mov    r8,QWORD PTR [rip+0x0]        # 451 <botlish_entry_2+0x19>
			44d: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 451:	call   r8
 454:	mov    rsi,rax
 457:	mov    rdi,r12
 45a:	call   45f <botlish_entry_2+0x27>
			45b: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 45f:	mov    r8,QWORD PTR [rip+0x0]        # 466 <botlish_entry_2+0x2e>
			462: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
 466:	mov    rsi,rax
 469:	mov    rdi,r12
 46c:	call   r8
 46f:	mov    r12,QWORD PTR [rsp]
 473:	add    rsp,0x10
 477:	mov    rsp,rbp
 47a:	pop    rbp
 47b:	ret
 47c:	add    BYTE PTR [rax],al
	...

0000000000000480 <botlish_fn_3: clean_from<str, int, str>>:
 480:	push   rbp
 481:	mov    rbp,rsp
 484:	sub    rsp,0xa0
 48b:	mov    QWORD PTR [rsp+0x70],rbx
 490:	mov    QWORD PTR [rsp+0x78],r12
 495:	mov    QWORD PTR [rsp+0x80],r13
 49d:	mov    QWORD PTR [rsp+0x88],r14
 4a5:	mov    QWORD PTR [rsp+0x90],r15
 4ad:	mov    r14,rdi
 4b0:	mov    QWORD PTR [rsp+0x18],0x0
 4b9:	mov    QWORD PTR [rsp+0x20],0x0
 4c2:	mov    QWORD PTR [rsp],rsi
 4c6:	mov    QWORD PTR [rsp+0x8],rcx
 4cb:	mov    r15,rcx
 4ce:	mov    QWORD PTR [rsp+0x10],r8
 4d3:	sar    rdx,1
 4d6:	mov    r12,rdx
 4d9:	lea    r13,[rsp+0x38]
 4de:	mov    rbx,rsi
 4e1:	mov    QWORD PTR [rsp+0x58],r8
 4e6:	mov    rsi,rbx
 4e9:	mov    rdi,r14
 4ec:	call   4f1 <botlish_fn_3+0x71>
			4ed: R_X86_64_PLT32	rt_str_len-0x4
 4f1:	sar    rax,1
 4f4:	cmp    r12,rax
 4f7:	jge    6c0 <botlish_fn_3+0x240>
 4fd:	mov    rsi,rbx
 500:	mov    rdi,r14
 503:	call   508 <botlish_fn_3+0x88>
			504: R_X86_64_PLT32	rt_str_len-0x4
 508:	mov    rsi,r12
 50b:	shl    rsi,1
 50e:	or     rsi,0x1
 512:	mov    rcx,rsi
 515:	and    rcx,rax
 518:	mov    rdx,rax
 51b:	test   rcx,0x1
 522:	jne    545 <botlish_fn_3+0xc5>
 528:	mov    rdi,r14
 52b:	call   530 <botlish_fn_3+0xb0>
			52c: R_X86_64_PLT32	rt_int_cmp-0x4
 530:	mov    ecx,0x2
 535:	test   rax,rax
 538:	cmovge rcx,QWORD PTR [rip+0x218]        # 758 <botlish_fn_3+0x2d8>
 540:	jmp    555 <botlish_fn_3+0xd5>
 545:	mov    ecx,0x2
 54a:	cmp    rsi,rdx
 54d:	cmovge rcx,QWORD PTR [rip+0x203]        # 758 <botlish_fn_3+0x2d8>
 555:	cmp    rcx,0x6
 559:	je     603 <botlish_fn_3+0x183>
 55f:	mov    rdx,QWORD PTR [rsp+0x58]
 564:	mov    rsi,rbx
 567:	mov    rdi,r14
 56a:	call   56f <botlish_fn_3+0xef>
			56b: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 56f:	mov    QWORD PTR [rsp+0x18],rax
 574:	mov    QWORD PTR [rsp+0x60],rax
 579:	mov    rsi,QWORD PTR [rsp+0x60]
 57e:	mov    rdi,r14
 581:	call   586 <botlish_fn_3+0x106>
			582: R_X86_64_PLT32	rt_str_byte_len-0x4
 586:	mov    QWORD PTR [rsp+0x20],rax
 58b:	mov    rsi,QWORD PTR [rsp+0x58]
 590:	mov    r8,rsi
 593:	and    r8,rax
 596:	test   r8,0x1
 59d:	jne    5b0 <botlish_fn_3+0x130>
 5a3:	mov    rdx,rax
 5a6:	mov    rsi,QWORD PTR [rsp+0x58]
 5ab:	jmp    5e4 <botlish_fn_3+0x164>
 5b0:	lea    r11,[rax-0x1]
 5b4:	mov    rdx,rax
 5b7:	mov    rsi,QWORD PTR [rsp+0x58]
 5bc:	mov    r10,rsi
 5bf:	add    r10,r11
 5c2:	seto   al
 5c5:	test   al,al
 5c7:	je     5d7 <botlish_fn_3+0x157>
 5cd:	mov    rsi,QWORD PTR [rsp+0x58]
 5d2:	jmp    5e4 <botlish_fn_3+0x164>
 5d7:	mov    rsi,r10
 5da:	mov    QWORD PTR [rsp+0x58],r10
 5df:	jmp    5f4 <botlish_fn_3+0x174>
 5e4:	mov    rdi,r14
 5e7:	call   5ec <botlish_fn_3+0x16c>
			5e8: R_X86_64_PLT32	rt_int_add-0x4
 5ec:	mov    rsi,rax
 5ef:	mov    QWORD PTR [rsp+0x58],rax
 5f4:	mov    QWORD PTR [rsp+0x10],rsi
 5f9:	mov    rsi,QWORD PTR [rsp+0x60]
 5fe:	jmp    617 <botlish_fn_3+0x197>
 603:	mov    rdi,r14
 606:	mov    rax,QWORD PTR [rdi+0x10]
 60a:	mov    rsi,QWORD PTR [rax]
 60d:	mov    rax,QWORD PTR [rsp+0x58]
 612:	mov    QWORD PTR [rsp+0x10],rax
 617:	mov    rax,QWORD PTR [rsi+0x8]
 61b:	mov    rcx,rsi
 61e:	mov    rsi,0xffffffffffffffff
 625:	test   rax,rax
 628:	je     654 <botlish_fn_3+0x1d4>
 62e:	mov    rsi,rcx
 631:	movzx  rax,BYTE PTR [rsi+0x18]
 636:	test   rax,rax
 639:	jne    64f <botlish_fn_3+0x1cf>
 63f:	mov    rdi,r14
 642:	call   647 <botlish_fn_3+0x1c7>
			643: R_X86_64_PLT32	rt_str_to_short-0x4
 647:	mov    rsi,rax
 64a:	jmp    654 <botlish_fn_3+0x1d4>
 64f:	movzx  rsi,BYTE PTR [rsi+0x19]
 654:	mov    rdi,r14
 657:	call   65c <botlish_fn_3+0x1dc>
			658: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 65c:	mov    QWORD PTR [rsp+0x18],rax
 661:	mov    QWORD PTR [rsp+0x38],0x0
 66a:	mov    rcx,r15
 66d:	mov    QWORD PTR [rsp+0x40],rcx
 672:	mov    QWORD PTR [rsp+0x48],0x0
 67b:	mov    QWORD PTR [rsp+0x50],rax
 680:	mov    esi,0x2
 685:	mov    edx,0x4
 68a:	mov    rcx,r13
 68d:	mov    rdi,r14
 690:	call   695 <botlish_fn_3+0x215>
			691: R_X86_64_PLT32	rt_construct-0x4
 695:	test   rax,rax
 698:	je     6f2 <botlish_fn_3+0x272>
 69e:	mov    QWORD PTR [rsp],rbx
 6a2:	mov    QWORD PTR [rsp+0x8],rax
 6a7:	mov    rsi,QWORD PTR [rsp+0x58]
 6ac:	mov    QWORD PTR [rsp+0x10],rsi
 6b1:	add    r12,0x1
 6b8:	mov    r15,rax
 6bb:	jmp    4e6 <botlish_fn_3+0x66>
 6c0:	mov    rcx,r15
 6c3:	xor    rsi,rsi
 6c6:	lea    rax,[rsp+0x28]
 6cb:	mov    QWORD PTR [rsp+0x28],0x0
 6d4:	mov    QWORD PTR [rsp+0x30],rcx
 6d9:	mov    edx,0x2
 6de:	mov    rcx,rax
 6e1:	mov    rdi,r14
 6e4:	call   6e9 <botlish_fn_3+0x269>
			6e5: R_X86_64_PLT32	rt_construct-0x4
 6e9:	test   rax,rax
 6ec:	jne    723 <botlish_fn_3+0x2a3>
 6f2:	xor    rax,rax
 6f5:	mov    rbx,QWORD PTR [rsp+0x70]
 6fa:	mov    r12,QWORD PTR [rsp+0x78]
 6ff:	mov    r13,QWORD PTR [rsp+0x80]
 707:	mov    r14,QWORD PTR [rsp+0x88]
 70f:	mov    r15,QWORD PTR [rsp+0x90]
 717:	add    rsp,0xa0
 71e:	mov    rsp,rbp
 721:	pop    rbp
 722:	ret
 723:	mov    rbx,QWORD PTR [rsp+0x70]
 728:	mov    r12,QWORD PTR [rsp+0x78]
 72d:	mov    r13,QWORD PTR [rsp+0x80]
 735:	mov    r14,QWORD PTR [rsp+0x88]
 73d:	mov    r15,QWORD PTR [rsp+0x90]
 745:	add    rsp,0xa0
 74c:	mov    rsp,rbp
 74f:	pop    rbp
 750:	ret
 751:	add    BYTE PTR [rax],al
 753:	add    BYTE PTR [rax],al
 755:	add    BYTE PTR [rax],al
 757:	add    BYTE PTR [rsi],al
 759:	add    BYTE PTR [rax],al
 75b:	add    BYTE PTR [rax],al
 75d:	add    BYTE PTR [rax],al
	...

0000000000000760 <botlish_entry_3: clean_from<str, int, str>>:
 760:	push   rbp
 761:	mov    rbp,rsp
 764:	mov    rsi,QWORD PTR [rdx]
 767:	mov    r9,QWORD PTR [rdx+0x8]
 76b:	mov    rcx,QWORD PTR [rdx+0x10]
 76f:	mov    r8,QWORD PTR [rdx+0x18]
 773:	mov    rdx,r9
 776:	call   77b <botlish_entry_3+0x1b>
			777: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 77b:	mov    rsp,rbp
 77e:	pop    rbp
 77f:	ret

0000000000000780 <botlish_fn_4: clean_ai_text<str>>:
 780:	push   rbp
 781:	mov    rbp,rsp
 784:	sub    rsp,0x20
 788:	mov    QWORD PTR [rsp],rsi
 78c:	mov    r8d,0x1
 792:	mov    QWORD PTR [rsp+0x8],0x1
 79b:	mov    r11,QWORD PTR [rdi+0x10]
 79f:	mov    rcx,QWORD PTR [r11]
 7a2:	mov    QWORD PTR [rsp+0x10],rcx
 7a7:	mov    QWORD PTR [rsp+0x18],0x1
 7b0:	mov    rdx,r8
 7b3:	call   7b8 <botlish_fn_4+0x38>
			7b4: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 7b8:	test   rax,rax
 7bb:	jne    7cd <botlish_fn_4+0x4d>
 7c1:	xor    rax,rax
 7c4:	add    rsp,0x20
 7c8:	mov    rsp,rbp
 7cb:	pop    rbp
 7cc:	ret
 7cd:	add    rsp,0x20
 7d1:	mov    rsp,rbp
 7d4:	pop    rbp
 7d5:	ret

00000000000007d6 <botlish_entry_4: clean_ai_text<str>>:
 7d6:	push   rbp
 7d7:	mov    rbp,rsp
 7da:	mov    rsi,QWORD PTR [rdx]
 7dd:	call   7e2 <botlish_entry_4+0xc>
			7de: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 7e2:	mov    rsp,rbp
 7e5:	pop    rbp
 7e6:	ret

00000000000007e7 <botlish_fn_5: sample<generic>>:
 7e7:	push   rbp
 7e8:	mov    rbp,rsp
 7eb:	sub    rsp,0xa0
 7f2:	mov    QWORD PTR [rsp+0x70],rbx
 7f7:	mov    QWORD PTR [rsp+0x78],r12
 7fc:	mov    QWORD PTR [rsp+0x80],r13
 804:	mov    QWORD PTR [rsp+0x88],r14
 80c:	mov    QWORD PTR [rsp+0x90],r15
 814:	mov    QWORD PTR [rsp+0x8],0x0
 81d:	mov    QWORD PTR [rsp+0x10],0x0
 826:	mov    QWORD PTR [rsp+0x18],0x0
 82f:	mov    QWORD PTR [rsp+0x20],0x0
 838:	mov    QWORD PTR [rsp+0x28],0x0
 841:	mov    rax,QWORD PTR [rdi+0x10]
 845:	mov    rbx,rdi
 848:	mov    rsi,QWORD PTR [rax+0x28]
 84c:	mov    QWORD PTR [rsp],rsi
 850:	call   855 <botlish_fn_5+0x6e>
			851: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 855:	test   rax,rax
 858:	je     96c <botlish_fn_5+0x185>
 85e:	mov    QWORD PTR [rsp],rax
 862:	mov    rdi,rbx
 865:	mov    r12,rax
 868:	mov    rax,QWORD PTR [rdi+0x10]
 86c:	mov    rsi,QWORD PTR [rax+0x30]
 870:	mov    QWORD PTR [rsp+0x8],rsi
 875:	call   87a <botlish_fn_5+0x93>
			876: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 87a:	test   rax,rax
 87d:	je     96c <botlish_fn_5+0x185>
 883:	mov    QWORD PTR [rsp+0x8],rax
 888:	mov    rdi,rbx
 88b:	mov    r13,rax
 88e:	mov    rax,QWORD PTR [rdi+0x10]
 892:	mov    rsi,QWORD PTR [rax+0x38]
 896:	mov    QWORD PTR [rsp+0x10],rsi
 89b:	call   8a0 <botlish_fn_5+0xb9>
			89c: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8a0:	test   rax,rax
 8a3:	je     96c <botlish_fn_5+0x185>
 8a9:	mov    QWORD PTR [rsp+0x10],rax
 8ae:	mov    rdi,rbx
 8b1:	mov    r14,rax
 8b4:	mov    rax,QWORD PTR [rdi+0x10]
 8b8:	mov    rsi,QWORD PTR [rax+0x40]
 8bc:	mov    QWORD PTR [rsp+0x18],rsi
 8c1:	call   8c6 <botlish_fn_5+0xdf>
			8c2: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8c6:	test   rax,rax
 8c9:	je     96c <botlish_fn_5+0x185>
 8cf:	mov    QWORD PTR [rsp+0x18],rax
 8d4:	mov    rdi,rbx
 8d7:	mov    r15,rax
 8da:	mov    rax,QWORD PTR [rdi+0x10]
 8de:	mov    rsi,QWORD PTR [rax+0x48]
 8e2:	mov    QWORD PTR [rsp+0x20],rsi
 8e7:	call   8ec <botlish_fn_5+0x105>
			8e8: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8ec:	test   rax,rax
 8ef:	je     96c <botlish_fn_5+0x185>
 8f5:	mov    QWORD PTR [rsp+0x20],rax
 8fa:	mov    rdi,rbx
 8fd:	mov    QWORD PTR [rsp+0x60],rax
 902:	mov    rax,QWORD PTR [rdi+0x10]
 906:	mov    rsi,QWORD PTR [rax+0x50]
 90a:	mov    QWORD PTR [rsp+0x28],rsi
 90f:	call   914 <botlish_fn_5+0x12d>
			910: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 914:	test   rax,rax
 917:	je     96c <botlish_fn_5+0x185>
 91d:	mov    QWORD PTR [rsp+0x28],rax
 922:	lea    rdx,[rsp+0x30]
 927:	mov    rcx,r12
 92a:	mov    QWORD PTR [rsp+0x30],rcx
 92f:	mov    rcx,r13
 932:	mov    QWORD PTR [rsp+0x38],rcx
 937:	mov    rcx,r14
 93a:	mov    QWORD PTR [rsp+0x40],rcx
 93f:	mov    rcx,r15
 942:	mov    QWORD PTR [rsp+0x48],rcx
 947:	mov    rcx,QWORD PTR [rsp+0x60]
 94c:	mov    QWORD PTR [rsp+0x50],rcx
 951:	mov    QWORD PTR [rsp+0x58],rax
 956:	mov    esi,0x6
 95b:	mov    rdi,rbx
 95e:	call   963 <botlish_fn_5+0x17c>
			95f: R_X86_64_PLT32	rt_list_new-0x4
 963:	test   rax,rax
 966:	jne    99d <botlish_fn_5+0x1b6>
 96c:	xor    rax,rax
 96f:	mov    rbx,QWORD PTR [rsp+0x70]
 974:	mov    r12,QWORD PTR [rsp+0x78]
 979:	mov    r13,QWORD PTR [rsp+0x80]
 981:	mov    r14,QWORD PTR [rsp+0x88]
 989:	mov    r15,QWORD PTR [rsp+0x90]
 991:	add    rsp,0xa0
 998:	mov    rsp,rbp
 99b:	pop    rbp
 99c:	ret
 99d:	mov    rbx,QWORD PTR [rsp+0x70]
 9a2:	mov    r12,QWORD PTR [rsp+0x78]
 9a7:	mov    r13,QWORD PTR [rsp+0x80]
 9af:	mov    r14,QWORD PTR [rsp+0x88]
 9b7:	mov    r15,QWORD PTR [rsp+0x90]
 9bf:	add    rsp,0xa0
 9c6:	mov    rsp,rbp
 9c9:	pop    rbp
 9ca:	ret

00000000000009cb <botlish_entry_5: sample<generic>>:
 9cb:	push   rbp
 9cc:	mov    rbp,rsp
 9cf:	call   9d4 <botlish_entry_5+0x9>
			9d0: R_X86_64_PLT32	botlish_fn_5-0x4 ; sample<generic>
 9d4:	mov    rsp,rbp
 9d7:	pop    rbp
 9d8:	ret

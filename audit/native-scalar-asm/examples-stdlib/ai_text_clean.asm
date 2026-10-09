; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2641  (per function: 147 509 624 752 103 506)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> cleaner_emoji<UnicodeChar>
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

000000000000007e <botlish_fn_1: cleaner_emoji<UnicodeChar>>:
  7e:	push   rbp
  7f:	mov    rbp,rsp
  82:	cmp    rsi,0xfb004
  89:	je     b2 <botlish_fn_1+0x34>
  8f:	cmp    rsi,0xfb014
  96:	je     a7 <botlish_fn_1+0x29>
  9c:	mov    r8d,0x2
  a2:	jmp    b8 <botlish_fn_1+0x3a>
  a7:	mov    r8d,0x6
  ad:	jmp    b8 <botlish_fn_1+0x3a>
  b2:	mov    r8d,0x6
  b8:	mov    eax,0x6
  bd:	cmp    r8,0x6
  c1:	je     e6 <botlish_fn_1+0x68>
  c7:	cmp    rsi,0xfb214
  ce:	je     de <botlish_fn_1+0x60>
  d4:	mov    ecx,0x2
  d9:	jmp    e9 <botlish_fn_1+0x6b>
  de:	mov    rcx,rax
  e1:	jmp    e9 <botlish_fn_1+0x6b>
  e6:	mov    rcx,rax
  e9:	cmp    rcx,0x6
  ed:	je     112 <botlish_fn_1+0x94>
  f3:	cmp    rsi,0xfb06c
  fa:	je     10a <botlish_fn_1+0x8c>
 100:	mov    ecx,0x2
 105:	jmp    115 <botlish_fn_1+0x97>
 10a:	mov    rcx,rax
 10d:	jmp    115 <botlish_fn_1+0x97>
 112:	mov    rcx,rax
 115:	cmp    rcx,0x6
 119:	je     13e <botlish_fn_1+0xc0>
 11f:	cmp    rsi,0xfa92c
 126:	je     136 <botlish_fn_1+0xb8>
 12c:	mov    ecx,0x2
 131:	jmp    141 <botlish_fn_1+0xc3>
 136:	mov    rcx,rax
 139:	jmp    141 <botlish_fn_1+0xc3>
 13e:	mov    rcx,rax
 141:	cmp    rcx,0x6
 145:	je     16a <botlish_fn_1+0xec>
 14b:	cmp    rsi,0xfb404
 152:	je     162 <botlish_fn_1+0xe4>
 158:	mov    ecx,0x2
 15d:	jmp    16d <botlish_fn_1+0xef>
 162:	mov    rcx,rax
 165:	jmp    16d <botlish_fn_1+0xef>
 16a:	mov    rcx,rax
 16d:	cmp    rcx,0x6
 171:	je     196 <botlish_fn_1+0x118>
 177:	cmp    rsi,0x1382c
 17e:	je     18e <botlish_fn_1+0x110>
 184:	mov    edi,0x2
 189:	jmp    199 <botlish_fn_1+0x11b>
 18e:	mov    rdi,rax
 191:	jmp    199 <botlish_fn_1+0x11b>
 196:	mov    rdi,rax
 199:	cmp    rdi,0x6
 19d:	je     1c2 <botlish_fn_1+0x144>
 1a3:	cmp    rsi,0x13a64
 1aa:	je     1ba <botlish_fn_1+0x13c>
 1b0:	mov    ecx,0x2
 1b5:	jmp    1c5 <botlish_fn_1+0x147>
 1ba:	mov    rcx,rax
 1bd:	jmp    1c5 <botlish_fn_1+0x147>
 1c2:	mov    rcx,rax
 1c5:	cmp    rcx,0x6
 1c9:	je     1ee <botlish_fn_1+0x170>
 1cf:	cmp    rsi,0xf9c4c
 1d6:	je     1e6 <botlish_fn_1+0x168>
 1dc:	mov    ecx,0x2
 1e1:	jmp    1f1 <botlish_fn_1+0x173>
 1e6:	mov    rcx,rax
 1e9:	jmp    1f1 <botlish_fn_1+0x173>
 1ee:	mov    rcx,rax
 1f1:	cmp    rcx,0x6
 1f5:	je     21a <botlish_fn_1+0x19c>
 1fb:	cmp    rsi,0xfc8b4
 202:	je     212 <botlish_fn_1+0x194>
 208:	mov    ecx,0x2
 20d:	jmp    21d <botlish_fn_1+0x19f>
 212:	mov    rcx,rax
 215:	jmp    21d <botlish_fn_1+0x19f>
 21a:	mov    rcx,rax
 21d:	cmp    rcx,0x6
 221:	je     246 <botlish_fn_1+0x1c8>
 227:	cmp    rsi,0xfa26c
 22e:	je     23e <botlish_fn_1+0x1c0>
 234:	mov    ecx,0x2
 239:	jmp    249 <botlish_fn_1+0x1cb>
 23e:	mov    rcx,rax
 241:	jmp    249 <botlish_fn_1+0x1cb>
 246:	mov    rcx,rax
 249:	cmp    rcx,0x6
 24d:	je     265 <botlish_fn_1+0x1e7>
 253:	cmp    rsi,0xfa50c
 25a:	je     265 <botlish_fn_1+0x1e7>
 260:	mov    eax,0x2
 265:	mov    rsp,rbp
 268:	pop    rbp
 269:	ret

000000000000026a <botlish_entry_1: cleaner_emoji<UnicodeChar>>:
 26a:	push   rbp
 26b:	mov    rbp,rsp
 26e:	mov    rsi,QWORD PTR [rdx]
 271:	call   276 <botlish_entry_1+0xc>
			272: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<UnicodeChar>
 276:	mov    rsp,rbp
 279:	pop    rbp
 27a:	ret

000000000000027b <botlish_fn_2: clean_char<str>>:
 27b:	push   rbp
 27c:	mov    rbp,rsp
 27f:	sub    rsp,0x20
 283:	mov    QWORD PTR [rsp],rbx
 287:	mov    QWORD PTR [rsp+0x8],r12
 28c:	mov    QWORD PTR [rsp+0x10],r13
 291:	mov    r12,rdi
 294:	cmp    rsi,0xffffffffffffffff
 298:	mov    rbx,rsi
 29b:	setne  al
 29e:	movzx  rax,al
 2a2:	test   rax,rax
 2a5:	jg     2b6 <botlish_fn_2+0x3b>
 2ab:	mov    rsi,rbx
 2ae:	mov    rdi,r12
 2b1:	jmp    3d2 <botlish_fn_2+0x157>
 2b6:	mov    rsi,rbx
 2b9:	mov    rdi,r12
 2bc:	call   2c1 <botlish_fn_2+0x46>
			2bd: R_X86_64_PLT32	rt_short_to_str-0x4
 2c1:	movzx  rcx,BYTE PTR [rax+0x18]
 2c6:	mov    rsi,rax
 2c9:	test   rcx,rcx
 2cc:	jne    2e7 <botlish_fn_2+0x6c>
 2d2:	mov    edx,0x1
 2d7:	mov    rdi,r12
 2da:	call   2df <botlish_fn_2+0x64>
			2db: R_X86_64_PLT32	rt_str_char_at_proven-0x4
 2df:	mov    r13,rax
 2e2:	jmp    2f7 <botlish_fn_2+0x7c>
 2e7:	movzx  rax,BYTE PTR [rsi+0x19]
 2ec:	shl    rax,0x3
 2f0:	or     rax,0x4
 2f4:	mov    r13,rax
 2f7:	mov    rsi,r13
 2fa:	mov    rdi,r12
 2fd:	call   302 <botlish_fn_2+0x87>
			2fe: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<UnicodeChar>
 302:	cmp    rax,0x6
 306:	je     479 <botlish_fn_2+0x1fe>
 30c:	mov    rax,r13
 30f:	cmp    rax,0x1009c
 315:	je     33b <botlish_fn_2+0xc0>
 31b:	cmp    rax,0x100a4
 321:	je     331 <botlish_fn_2+0xb6>
 327:	mov    ecx,0x2
 32c:	jmp    340 <botlish_fn_2+0xc5>
 331:	mov    ecx,0x6
 336:	jmp    340 <botlish_fn_2+0xc5>
 33b:	mov    ecx,0x6
 340:	cmp    rcx,0x6
 344:	je     457 <botlish_fn_2+0x1dc>
 34a:	cmp    rax,0x100c4
 350:	je     376 <botlish_fn_2+0xfb>
 356:	cmp    rax,0x100cc
 35c:	je     36c <botlish_fn_2+0xf1>
 362:	mov    ecx,0x2
 367:	jmp    37b <botlish_fn_2+0x100>
 36c:	mov    ecx,0x6
 371:	jmp    37b <botlish_fn_2+0x100>
 376:	mov    ecx,0x6
 37b:	cmp    rcx,0x6
 37f:	je     435 <botlish_fn_2+0x1ba>
 385:	cmp    rax,0x100e4
 38b:	je     3b1 <botlish_fn_2+0x136>
 391:	cmp    rax,0x100ec
 397:	je     3a7 <botlish_fn_2+0x12c>
 39d:	mov    ecx,0x2
 3a2:	jmp    3b6 <botlish_fn_2+0x13b>
 3a7:	mov    ecx,0x6
 3ac:	jmp    3b6 <botlish_fn_2+0x13b>
 3b1:	mov    ecx,0x6
 3b6:	cmp    rcx,0x6
 3ba:	je     413 <botlish_fn_2+0x198>
 3c0:	cmp    rax,0x10134
 3c6:	je     3f1 <botlish_fn_2+0x176>
 3cc:	mov    rsi,rbx
 3cf:	mov    rdi,r12
 3d2:	mov    rdi,r12
 3d5:	call   3da <botlish_fn_2+0x15f>
			3d6: R_X86_64_PLT32	rt_short_to_str-0x4
 3da:	mov    rbx,QWORD PTR [rsp]
 3de:	mov    r12,QWORD PTR [rsp+0x8]
 3e3:	mov    r13,QWORD PTR [rsp+0x10]
 3e8:	add    rsp,0x20
 3ec:	mov    rsp,rbp
 3ef:	pop    rbp
 3f0:	ret
 3f1:	mov    rdi,r12
 3f4:	mov    rax,QWORD PTR [rdi+0x10]
 3f8:	mov    rax,QWORD PTR [rax+0x20]
 3fc:	mov    rbx,QWORD PTR [rsp]
 400:	mov    r12,QWORD PTR [rsp+0x8]
 405:	mov    r13,QWORD PTR [rsp+0x10]
 40a:	add    rsp,0x20
 40e:	mov    rsp,rbp
 411:	pop    rbp
 412:	ret
 413:	mov    rdi,r12
 416:	mov    rax,QWORD PTR [rdi+0x10]
 41a:	mov    rax,QWORD PTR [rax+0x18]
 41e:	mov    rbx,QWORD PTR [rsp]
 422:	mov    r12,QWORD PTR [rsp+0x8]
 427:	mov    r13,QWORD PTR [rsp+0x10]
 42c:	add    rsp,0x20
 430:	mov    rsp,rbp
 433:	pop    rbp
 434:	ret
 435:	mov    rdi,r12
 438:	mov    rax,QWORD PTR [rdi+0x10]
 43c:	mov    rax,QWORD PTR [rax+0x10]
 440:	mov    rbx,QWORD PTR [rsp]
 444:	mov    r12,QWORD PTR [rsp+0x8]
 449:	mov    r13,QWORD PTR [rsp+0x10]
 44e:	add    rsp,0x20
 452:	mov    rsp,rbp
 455:	pop    rbp
 456:	ret
 457:	mov    rdi,r12
 45a:	mov    rax,QWORD PTR [rdi+0x10]
 45e:	mov    rax,QWORD PTR [rax+0x8]
 462:	mov    rbx,QWORD PTR [rsp]
 466:	mov    r12,QWORD PTR [rsp+0x8]
 46b:	mov    r13,QWORD PTR [rsp+0x10]
 470:	add    rsp,0x20
 474:	mov    rsp,rbp
 477:	pop    rbp
 478:	ret
 479:	mov    rdi,r12
 47c:	mov    rax,QWORD PTR [rdi+0x10]
 480:	mov    rax,QWORD PTR [rax]
 483:	mov    rbx,QWORD PTR [rsp]
 487:	mov    r12,QWORD PTR [rsp+0x8]
 48c:	mov    r13,QWORD PTR [rsp+0x10]
 491:	add    rsp,0x20
 495:	mov    rsp,rbp
 498:	pop    rbp
 499:	ret

000000000000049a <botlish_entry_2: clean_char<str>>:
 49a:	push   rbp
 49b:	mov    rbp,rsp
 49e:	sub    rsp,0x10
 4a2:	mov    QWORD PTR [rsp],r12
 4a6:	mov    r12,rdi
 4a9:	mov    rsi,QWORD PTR [rdx]
 4ac:	mov    r8,QWORD PTR [rip+0x0]        # 4b3 <botlish_entry_2+0x19>
			4af: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 4b3:	call   r8
 4b6:	mov    rsi,rax
 4b9:	mov    rdi,r12
 4bc:	call   4c1 <botlish_entry_2+0x27>
			4bd: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 4c1:	mov    r8,QWORD PTR [rip+0x0]        # 4c8 <botlish_entry_2+0x2e>
			4c4: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
 4c8:	mov    rsi,rax
 4cb:	mov    rdi,r12
 4ce:	call   r8
 4d1:	mov    r12,QWORD PTR [rsp]
 4d5:	add    rsp,0x10
 4d9:	mov    rsp,rbp
 4dc:	pop    rbp
 4dd:	ret
	...

00000000000004e0 <botlish_fn_3: clean_from<str, int, str>>:
 4e0:	push   rbp
 4e1:	mov    rbp,rsp
 4e4:	sub    rsp,0xa0
 4eb:	mov    QWORD PTR [rsp+0x70],rbx
 4f0:	mov    QWORD PTR [rsp+0x78],r12
 4f5:	mov    QWORD PTR [rsp+0x80],r13
 4fd:	mov    QWORD PTR [rsp+0x88],r14
 505:	mov    QWORD PTR [rsp+0x90],r15
 50d:	mov    r14,rdi
 510:	mov    QWORD PTR [rsp+0x18],0x0
 519:	mov    QWORD PTR [rsp+0x20],0x0
 522:	mov    QWORD PTR [rsp],rsi
 526:	mov    QWORD PTR [rsp+0x8],rcx
 52b:	mov    r15,rcx
 52e:	mov    QWORD PTR [rsp+0x10],r8
 533:	sar    rdx,1
 536:	lea    r13,[rsp+0x38]
 53b:	mov    rbx,rsi
 53e:	mov    QWORD PTR [rsp+0x58],r8
 543:	mov    rax,QWORD PTR [rbx+0x8]
 547:	shl    rax,1
 54a:	or     rax,0x1
 54e:	sar    rax,1
 551:	mov    r12,rdx
 554:	cmp    r12,rax
 557:	jge    6ef <botlish_fn_3+0x20f>
 55d:	mov    rax,QWORD PTR [rbx+0x8]
 561:	mov    rcx,r12
 564:	shl    rcx,1
 567:	or     rcx,0x1
 56b:	shl    rax,1
 56e:	or     rax,0x1
 572:	mov    edx,0x2
 577:	cmp    rcx,rax
 57a:	cmovge rdx,QWORD PTR [rip+0x1fe]        # 780 <botlish_fn_3+0x2a0>
 582:	cmp    rdx,0x6
 586:	je     62f <botlish_fn_3+0x14f>
 58c:	mov    rdx,QWORD PTR [rsp+0x58]
 591:	mov    rsi,rbx
 594:	mov    rdi,r14
 597:	call   59c <botlish_fn_3+0xbc>
			598: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 59c:	mov    QWORD PTR [rsp+0x18],rax
 5a1:	mov    QWORD PTR [rsp+0x60],rax
 5a6:	mov    rsi,QWORD PTR [rsp+0x60]
 5ab:	mov    rdi,r14
 5ae:	call   5b3 <botlish_fn_3+0xd3>
			5af: R_X86_64_PLT32	rt_str_byte_len-0x4
 5b3:	mov    QWORD PTR [rsp+0x20],rax
 5b8:	mov    rsi,QWORD PTR [rsp+0x58]
 5bd:	and    rsi,rax
 5c0:	test   rsi,0x1
 5c7:	jne    5da <botlish_fn_3+0xfa>
 5cd:	mov    rdx,rax
 5d0:	mov    rsi,QWORD PTR [rsp+0x58]
 5d5:	jmp    610 <botlish_fn_3+0x130>
 5da:	lea    r8,[rax-0x1]
 5de:	mov    rdx,rax
 5e1:	mov    rsi,QWORD PTR [rsp+0x58]
 5e6:	mov    rdi,rsi
 5e9:	add    rdi,r8
 5ec:	seto   r9b
 5f0:	test   r9b,r9b
 5f3:	je     603 <botlish_fn_3+0x123>
 5f9:	mov    rsi,QWORD PTR [rsp+0x58]
 5fe:	jmp    610 <botlish_fn_3+0x130>
 603:	mov    rsi,rdi
 606:	mov    QWORD PTR [rsp+0x58],rdi
 60b:	jmp    620 <botlish_fn_3+0x140>
 610:	mov    rdi,r14
 613:	call   618 <botlish_fn_3+0x138>
			614: R_X86_64_PLT32	rt_int_add-0x4
 618:	mov    rsi,rax
 61b:	mov    QWORD PTR [rsp+0x58],rax
 620:	mov    QWORD PTR [rsp+0x10],rsi
 625:	mov    rsi,QWORD PTR [rsp+0x60]
 62a:	jmp    643 <botlish_fn_3+0x163>
 62f:	mov    rdi,r14
 632:	mov    rax,QWORD PTR [rdi+0x10]
 636:	mov    rsi,QWORD PTR [rax]
 639:	mov    rax,QWORD PTR [rsp+0x58]
 63e:	mov    QWORD PTR [rsp+0x10],rax
 643:	mov    rax,QWORD PTR [rsi+0x8]
 647:	mov    rcx,rsi
 64a:	mov    rsi,0xffffffffffffffff
 651:	test   rax,rax
 654:	je     680 <botlish_fn_3+0x1a0>
 65a:	mov    rsi,rcx
 65d:	movzx  rax,BYTE PTR [rsi+0x18]
 662:	test   rax,rax
 665:	jne    67b <botlish_fn_3+0x19b>
 66b:	mov    rdi,r14
 66e:	call   673 <botlish_fn_3+0x193>
			66f: R_X86_64_PLT32	rt_str_to_short-0x4
 673:	mov    rsi,rax
 676:	jmp    680 <botlish_fn_3+0x1a0>
 67b:	movzx  rsi,BYTE PTR [rsi+0x19]
 680:	mov    rdi,r14
 683:	call   688 <botlish_fn_3+0x1a8>
			684: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 688:	mov    QWORD PTR [rsp+0x18],rax
 68d:	mov    QWORD PTR [rsp+0x38],0x0
 696:	mov    rcx,r15
 699:	mov    QWORD PTR [rsp+0x40],rcx
 69e:	mov    QWORD PTR [rsp+0x48],0x0
 6a7:	mov    QWORD PTR [rsp+0x50],rax
 6ac:	mov    esi,0x2
 6b1:	mov    edx,0x4
 6b6:	mov    rcx,r13
 6b9:	mov    rdi,r14
 6bc:	call   6c1 <botlish_fn_3+0x1e1>
			6bd: R_X86_64_PLT32	rt_construct-0x4
 6c1:	test   rax,rax
 6c4:	je     721 <botlish_fn_3+0x241>
 6ca:	mov    QWORD PTR [rsp],rbx
 6ce:	mov    QWORD PTR [rsp+0x8],rax
 6d3:	mov    rsi,QWORD PTR [rsp+0x58]
 6d8:	mov    QWORD PTR [rsp+0x10],rsi
 6dd:	add    r12,0x1
 6e4:	mov    rdx,r12
 6e7:	mov    r15,rax
 6ea:	jmp    543 <botlish_fn_3+0x63>
 6ef:	mov    rcx,r15
 6f2:	xor    rsi,rsi
 6f5:	lea    rax,[rsp+0x28]
 6fa:	mov    QWORD PTR [rsp+0x28],0x0
 703:	mov    QWORD PTR [rsp+0x30],rcx
 708:	mov    edx,0x2
 70d:	mov    rcx,rax
 710:	mov    rdi,r14
 713:	call   718 <botlish_fn_3+0x238>
			714: R_X86_64_PLT32	rt_construct-0x4
 718:	test   rax,rax
 71b:	jne    752 <botlish_fn_3+0x272>
 721:	xor    rax,rax
 724:	mov    rbx,QWORD PTR [rsp+0x70]
 729:	mov    r12,QWORD PTR [rsp+0x78]
 72e:	mov    r13,QWORD PTR [rsp+0x80]
 736:	mov    r14,QWORD PTR [rsp+0x88]
 73e:	mov    r15,QWORD PTR [rsp+0x90]
 746:	add    rsp,0xa0
 74d:	mov    rsp,rbp
 750:	pop    rbp
 751:	ret
 752:	mov    rbx,QWORD PTR [rsp+0x70]
 757:	mov    r12,QWORD PTR [rsp+0x78]
 75c:	mov    r13,QWORD PTR [rsp+0x80]
 764:	mov    r14,QWORD PTR [rsp+0x88]
 76c:	mov    r15,QWORD PTR [rsp+0x90]
 774:	add    rsp,0xa0
 77b:	mov    rsp,rbp
 77e:	pop    rbp
 77f:	ret
 780:	(bad)
 781:	add    BYTE PTR [rax],al
 783:	add    BYTE PTR [rax],al
 785:	add    BYTE PTR [rax],al
	...

0000000000000788 <botlish_entry_3: clean_from<str, int, str>>:
 788:	push   rbp
 789:	mov    rbp,rsp
 78c:	mov    rsi,QWORD PTR [rdx]
 78f:	mov    r9,QWORD PTR [rdx+0x8]
 793:	mov    rcx,QWORD PTR [rdx+0x10]
 797:	mov    r8,QWORD PTR [rdx+0x18]
 79b:	mov    rdx,r9
 79e:	call   7a3 <botlish_entry_3+0x1b>
			79f: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 7a3:	mov    rsp,rbp
 7a6:	pop    rbp
 7a7:	ret

00000000000007a8 <botlish_fn_4: clean_ai_text<str>>:
 7a8:	push   rbp
 7a9:	mov    rbp,rsp
 7ac:	sub    rsp,0x20
 7b0:	mov    QWORD PTR [rsp],rsi
 7b4:	mov    r8d,0x1
 7ba:	mov    QWORD PTR [rsp+0x8],0x1
 7c3:	mov    r11,QWORD PTR [rdi+0x10]
 7c7:	mov    rcx,QWORD PTR [r11]
 7ca:	mov    QWORD PTR [rsp+0x10],rcx
 7cf:	mov    QWORD PTR [rsp+0x18],0x1
 7d8:	mov    rdx,r8
 7db:	call   7e0 <botlish_fn_4+0x38>
			7dc: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 7e0:	test   rax,rax
 7e3:	jne    7f5 <botlish_fn_4+0x4d>
 7e9:	xor    rax,rax
 7ec:	add    rsp,0x20
 7f0:	mov    rsp,rbp
 7f3:	pop    rbp
 7f4:	ret
 7f5:	add    rsp,0x20
 7f9:	mov    rsp,rbp
 7fc:	pop    rbp
 7fd:	ret

00000000000007fe <botlish_entry_4: clean_ai_text<str>>:
 7fe:	push   rbp
 7ff:	mov    rbp,rsp
 802:	mov    rsi,QWORD PTR [rdx]
 805:	call   80a <botlish_entry_4+0xc>
			806: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 80a:	mov    rsp,rbp
 80d:	pop    rbp
 80e:	ret

000000000000080f <botlish_fn_5: sample<generic>>:
 80f:	push   rbp
 810:	mov    rbp,rsp
 813:	sub    rsp,0xa0
 81a:	mov    QWORD PTR [rsp+0x70],rbx
 81f:	mov    QWORD PTR [rsp+0x78],r12
 824:	mov    QWORD PTR [rsp+0x80],r13
 82c:	mov    QWORD PTR [rsp+0x88],r14
 834:	mov    QWORD PTR [rsp+0x90],r15
 83c:	mov    QWORD PTR [rsp+0x8],0x0
 845:	mov    QWORD PTR [rsp+0x10],0x0
 84e:	mov    QWORD PTR [rsp+0x18],0x0
 857:	mov    QWORD PTR [rsp+0x20],0x0
 860:	mov    QWORD PTR [rsp+0x28],0x0
 869:	mov    rax,QWORD PTR [rdi+0x10]
 86d:	mov    rbx,rdi
 870:	mov    rsi,QWORD PTR [rax+0x28]
 874:	mov    QWORD PTR [rsp],rsi
 878:	call   87d <botlish_fn_5+0x6e>
			879: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 87d:	test   rax,rax
 880:	je     994 <botlish_fn_5+0x185>
 886:	mov    QWORD PTR [rsp],rax
 88a:	mov    rdi,rbx
 88d:	mov    r12,rax
 890:	mov    rax,QWORD PTR [rdi+0x10]
 894:	mov    rsi,QWORD PTR [rax+0x30]
 898:	mov    QWORD PTR [rsp+0x8],rsi
 89d:	call   8a2 <botlish_fn_5+0x93>
			89e: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8a2:	test   rax,rax
 8a5:	je     994 <botlish_fn_5+0x185>
 8ab:	mov    QWORD PTR [rsp+0x8],rax
 8b0:	mov    rdi,rbx
 8b3:	mov    r13,rax
 8b6:	mov    rax,QWORD PTR [rdi+0x10]
 8ba:	mov    rsi,QWORD PTR [rax+0x38]
 8be:	mov    QWORD PTR [rsp+0x10],rsi
 8c3:	call   8c8 <botlish_fn_5+0xb9>
			8c4: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8c8:	test   rax,rax
 8cb:	je     994 <botlish_fn_5+0x185>
 8d1:	mov    QWORD PTR [rsp+0x10],rax
 8d6:	mov    rdi,rbx
 8d9:	mov    r14,rax
 8dc:	mov    rax,QWORD PTR [rdi+0x10]
 8e0:	mov    rsi,QWORD PTR [rax+0x40]
 8e4:	mov    QWORD PTR [rsp+0x18],rsi
 8e9:	call   8ee <botlish_fn_5+0xdf>
			8ea: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8ee:	test   rax,rax
 8f1:	je     994 <botlish_fn_5+0x185>
 8f7:	mov    QWORD PTR [rsp+0x18],rax
 8fc:	mov    rdi,rbx
 8ff:	mov    r15,rax
 902:	mov    rax,QWORD PTR [rdi+0x10]
 906:	mov    rsi,QWORD PTR [rax+0x48]
 90a:	mov    QWORD PTR [rsp+0x20],rsi
 90f:	call   914 <botlish_fn_5+0x105>
			910: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 914:	test   rax,rax
 917:	je     994 <botlish_fn_5+0x185>
 91d:	mov    QWORD PTR [rsp+0x20],rax
 922:	mov    rdi,rbx
 925:	mov    QWORD PTR [rsp+0x60],rax
 92a:	mov    rax,QWORD PTR [rdi+0x10]
 92e:	mov    rsi,QWORD PTR [rax+0x50]
 932:	mov    QWORD PTR [rsp+0x28],rsi
 937:	call   93c <botlish_fn_5+0x12d>
			938: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 93c:	test   rax,rax
 93f:	je     994 <botlish_fn_5+0x185>
 945:	mov    QWORD PTR [rsp+0x28],rax
 94a:	lea    rdx,[rsp+0x30]
 94f:	mov    rcx,r12
 952:	mov    QWORD PTR [rsp+0x30],rcx
 957:	mov    rcx,r13
 95a:	mov    QWORD PTR [rsp+0x38],rcx
 95f:	mov    rcx,r14
 962:	mov    QWORD PTR [rsp+0x40],rcx
 967:	mov    rcx,r15
 96a:	mov    QWORD PTR [rsp+0x48],rcx
 96f:	mov    rcx,QWORD PTR [rsp+0x60]
 974:	mov    QWORD PTR [rsp+0x50],rcx
 979:	mov    QWORD PTR [rsp+0x58],rax
 97e:	mov    esi,0x6
 983:	mov    rdi,rbx
 986:	call   98b <botlish_fn_5+0x17c>
			987: R_X86_64_PLT32	rt_list_new-0x4
 98b:	test   rax,rax
 98e:	jne    9c5 <botlish_fn_5+0x1b6>
 994:	xor    rax,rax
 997:	mov    rbx,QWORD PTR [rsp+0x70]
 99c:	mov    r12,QWORD PTR [rsp+0x78]
 9a1:	mov    r13,QWORD PTR [rsp+0x80]
 9a9:	mov    r14,QWORD PTR [rsp+0x88]
 9b1:	mov    r15,QWORD PTR [rsp+0x90]
 9b9:	add    rsp,0xa0
 9c0:	mov    rsp,rbp
 9c3:	pop    rbp
 9c4:	ret
 9c5:	mov    rbx,QWORD PTR [rsp+0x70]
 9ca:	mov    r12,QWORD PTR [rsp+0x78]
 9cf:	mov    r13,QWORD PTR [rsp+0x80]
 9d7:	mov    r14,QWORD PTR [rsp+0x88]
 9df:	mov    r15,QWORD PTR [rsp+0x90]
 9e7:	add    rsp,0xa0
 9ee:	mov    rsp,rbp
 9f1:	pop    rbp
 9f2:	ret

00000000000009f3 <botlish_entry_5: sample<generic>>:
 9f3:	push   rbp
 9f4:	mov    rbp,rsp
 9f7:	call   9fc <botlish_entry_5+0x9>
			9f8: R_X86_64_PLT32	botlish_fn_5-0x4 ; sample<generic>
 9fc:	mov    rsp,rbp
 9ff:	pop    rbp
 a00:	ret

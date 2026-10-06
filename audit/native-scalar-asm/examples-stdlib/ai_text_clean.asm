; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2547  (per function: 147 547 492 752 103 506)
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
 4d6:	lea    r13,[rsp+0x38]
 4db:	mov    rbx,rsi
 4de:	mov    QWORD PTR [rsp+0x58],r8
 4e3:	mov    rax,QWORD PTR [rbx+0x8]
 4e7:	shl    rax,1
 4ea:	or     rax,0x1
 4ee:	sar    rax,1
 4f1:	mov    r12,rdx
 4f4:	cmp    r12,rax
 4f7:	jge    68f <botlish_fn_3+0x20f>
 4fd:	mov    rax,QWORD PTR [rbx+0x8]
 501:	mov    rcx,r12
 504:	shl    rcx,1
 507:	or     rcx,0x1
 50b:	shl    rax,1
 50e:	or     rax,0x1
 512:	mov    edx,0x2
 517:	cmp    rcx,rax
 51a:	cmovge rdx,QWORD PTR [rip+0x1fe]        # 720 <botlish_fn_3+0x2a0>
 522:	cmp    rdx,0x6
 526:	je     5cf <botlish_fn_3+0x14f>
 52c:	mov    rdx,QWORD PTR [rsp+0x58]
 531:	mov    rsi,rbx
 534:	mov    rdi,r14
 537:	call   53c <botlish_fn_3+0xbc>
			538: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 53c:	mov    QWORD PTR [rsp+0x18],rax
 541:	mov    QWORD PTR [rsp+0x60],rax
 546:	mov    rsi,QWORD PTR [rsp+0x60]
 54b:	mov    rdi,r14
 54e:	call   553 <botlish_fn_3+0xd3>
			54f: R_X86_64_PLT32	rt_str_byte_len-0x4
 553:	mov    QWORD PTR [rsp+0x20],rax
 558:	mov    rsi,QWORD PTR [rsp+0x58]
 55d:	and    rsi,rax
 560:	test   rsi,0x1
 567:	jne    57a <botlish_fn_3+0xfa>
 56d:	mov    rdx,rax
 570:	mov    rsi,QWORD PTR [rsp+0x58]
 575:	jmp    5b0 <botlish_fn_3+0x130>
 57a:	lea    r8,[rax-0x1]
 57e:	mov    rdx,rax
 581:	mov    rsi,QWORD PTR [rsp+0x58]
 586:	mov    rdi,rsi
 589:	add    rdi,r8
 58c:	seto   r9b
 590:	test   r9b,r9b
 593:	je     5a3 <botlish_fn_3+0x123>
 599:	mov    rsi,QWORD PTR [rsp+0x58]
 59e:	jmp    5b0 <botlish_fn_3+0x130>
 5a3:	mov    rsi,rdi
 5a6:	mov    QWORD PTR [rsp+0x58],rdi
 5ab:	jmp    5c0 <botlish_fn_3+0x140>
 5b0:	mov    rdi,r14
 5b3:	call   5b8 <botlish_fn_3+0x138>
			5b4: R_X86_64_PLT32	rt_int_add-0x4
 5b8:	mov    rsi,rax
 5bb:	mov    QWORD PTR [rsp+0x58],rax
 5c0:	mov    QWORD PTR [rsp+0x10],rsi
 5c5:	mov    rsi,QWORD PTR [rsp+0x60]
 5ca:	jmp    5e3 <botlish_fn_3+0x163>
 5cf:	mov    rdi,r14
 5d2:	mov    rax,QWORD PTR [rdi+0x10]
 5d6:	mov    rsi,QWORD PTR [rax]
 5d9:	mov    rax,QWORD PTR [rsp+0x58]
 5de:	mov    QWORD PTR [rsp+0x10],rax
 5e3:	mov    rax,QWORD PTR [rsi+0x8]
 5e7:	mov    rcx,rsi
 5ea:	mov    rsi,0xffffffffffffffff
 5f1:	test   rax,rax
 5f4:	je     620 <botlish_fn_3+0x1a0>
 5fa:	mov    rsi,rcx
 5fd:	movzx  rax,BYTE PTR [rsi+0x18]
 602:	test   rax,rax
 605:	jne    61b <botlish_fn_3+0x19b>
 60b:	mov    rdi,r14
 60e:	call   613 <botlish_fn_3+0x193>
			60f: R_X86_64_PLT32	rt_str_to_short-0x4
 613:	mov    rsi,rax
 616:	jmp    620 <botlish_fn_3+0x1a0>
 61b:	movzx  rsi,BYTE PTR [rsi+0x19]
 620:	mov    rdi,r14
 623:	call   628 <botlish_fn_3+0x1a8>
			624: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 628:	mov    QWORD PTR [rsp+0x18],rax
 62d:	mov    QWORD PTR [rsp+0x38],0x0
 636:	mov    rcx,r15
 639:	mov    QWORD PTR [rsp+0x40],rcx
 63e:	mov    QWORD PTR [rsp+0x48],0x0
 647:	mov    QWORD PTR [rsp+0x50],rax
 64c:	mov    esi,0x2
 651:	mov    edx,0x4
 656:	mov    rcx,r13
 659:	mov    rdi,r14
 65c:	call   661 <botlish_fn_3+0x1e1>
			65d: R_X86_64_PLT32	rt_construct-0x4
 661:	test   rax,rax
 664:	je     6c1 <botlish_fn_3+0x241>
 66a:	mov    QWORD PTR [rsp],rbx
 66e:	mov    QWORD PTR [rsp+0x8],rax
 673:	mov    rsi,QWORD PTR [rsp+0x58]
 678:	mov    QWORD PTR [rsp+0x10],rsi
 67d:	add    r12,0x1
 684:	mov    rdx,r12
 687:	mov    r15,rax
 68a:	jmp    4e3 <botlish_fn_3+0x63>
 68f:	mov    rcx,r15
 692:	xor    rsi,rsi
 695:	lea    rax,[rsp+0x28]
 69a:	mov    QWORD PTR [rsp+0x28],0x0
 6a3:	mov    QWORD PTR [rsp+0x30],rcx
 6a8:	mov    edx,0x2
 6ad:	mov    rcx,rax
 6b0:	mov    rdi,r14
 6b3:	call   6b8 <botlish_fn_3+0x238>
			6b4: R_X86_64_PLT32	rt_construct-0x4
 6b8:	test   rax,rax
 6bb:	jne    6f2 <botlish_fn_3+0x272>
 6c1:	xor    rax,rax
 6c4:	mov    rbx,QWORD PTR [rsp+0x70]
 6c9:	mov    r12,QWORD PTR [rsp+0x78]
 6ce:	mov    r13,QWORD PTR [rsp+0x80]
 6d6:	mov    r14,QWORD PTR [rsp+0x88]
 6de:	mov    r15,QWORD PTR [rsp+0x90]
 6e6:	add    rsp,0xa0
 6ed:	mov    rsp,rbp
 6f0:	pop    rbp
 6f1:	ret
 6f2:	mov    rbx,QWORD PTR [rsp+0x70]
 6f7:	mov    r12,QWORD PTR [rsp+0x78]
 6fc:	mov    r13,QWORD PTR [rsp+0x80]
 704:	mov    r14,QWORD PTR [rsp+0x88]
 70c:	mov    r15,QWORD PTR [rsp+0x90]
 714:	add    rsp,0xa0
 71b:	mov    rsp,rbp
 71e:	pop    rbp
 71f:	ret
 720:	(bad)
 721:	add    BYTE PTR [rax],al
 723:	add    BYTE PTR [rax],al
 725:	add    BYTE PTR [rax],al
	...

0000000000000728 <botlish_entry_3: clean_from<str, int, str>>:
 728:	push   rbp
 729:	mov    rbp,rsp
 72c:	mov    rsi,QWORD PTR [rdx]
 72f:	mov    r9,QWORD PTR [rdx+0x8]
 733:	mov    rcx,QWORD PTR [rdx+0x10]
 737:	mov    r8,QWORD PTR [rdx+0x18]
 73b:	mov    rdx,r9
 73e:	call   743 <botlish_entry_3+0x1b>
			73f: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 743:	mov    rsp,rbp
 746:	pop    rbp
 747:	ret

0000000000000748 <botlish_fn_4: clean_ai_text<str>>:
 748:	push   rbp
 749:	mov    rbp,rsp
 74c:	sub    rsp,0x20
 750:	mov    QWORD PTR [rsp],rsi
 754:	mov    r8d,0x1
 75a:	mov    QWORD PTR [rsp+0x8],0x1
 763:	mov    r11,QWORD PTR [rdi+0x10]
 767:	mov    rcx,QWORD PTR [r11]
 76a:	mov    QWORD PTR [rsp+0x10],rcx
 76f:	mov    QWORD PTR [rsp+0x18],0x1
 778:	mov    rdx,r8
 77b:	call   780 <botlish_fn_4+0x38>
			77c: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 780:	test   rax,rax
 783:	jne    795 <botlish_fn_4+0x4d>
 789:	xor    rax,rax
 78c:	add    rsp,0x20
 790:	mov    rsp,rbp
 793:	pop    rbp
 794:	ret
 795:	add    rsp,0x20
 799:	mov    rsp,rbp
 79c:	pop    rbp
 79d:	ret

000000000000079e <botlish_entry_4: clean_ai_text<str>>:
 79e:	push   rbp
 79f:	mov    rbp,rsp
 7a2:	mov    rsi,QWORD PTR [rdx]
 7a5:	call   7aa <botlish_entry_4+0xc>
			7a6: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 7aa:	mov    rsp,rbp
 7ad:	pop    rbp
 7ae:	ret

00000000000007af <botlish_fn_5: sample<generic>>:
 7af:	push   rbp
 7b0:	mov    rbp,rsp
 7b3:	sub    rsp,0xa0
 7ba:	mov    QWORD PTR [rsp+0x70],rbx
 7bf:	mov    QWORD PTR [rsp+0x78],r12
 7c4:	mov    QWORD PTR [rsp+0x80],r13
 7cc:	mov    QWORD PTR [rsp+0x88],r14
 7d4:	mov    QWORD PTR [rsp+0x90],r15
 7dc:	mov    QWORD PTR [rsp+0x8],0x0
 7e5:	mov    QWORD PTR [rsp+0x10],0x0
 7ee:	mov    QWORD PTR [rsp+0x18],0x0
 7f7:	mov    QWORD PTR [rsp+0x20],0x0
 800:	mov    QWORD PTR [rsp+0x28],0x0
 809:	mov    rax,QWORD PTR [rdi+0x10]
 80d:	mov    rbx,rdi
 810:	mov    rsi,QWORD PTR [rax+0x28]
 814:	mov    QWORD PTR [rsp],rsi
 818:	call   81d <botlish_fn_5+0x6e>
			819: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 81d:	test   rax,rax
 820:	je     934 <botlish_fn_5+0x185>
 826:	mov    QWORD PTR [rsp],rax
 82a:	mov    rdi,rbx
 82d:	mov    r12,rax
 830:	mov    rax,QWORD PTR [rdi+0x10]
 834:	mov    rsi,QWORD PTR [rax+0x30]
 838:	mov    QWORD PTR [rsp+0x8],rsi
 83d:	call   842 <botlish_fn_5+0x93>
			83e: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 842:	test   rax,rax
 845:	je     934 <botlish_fn_5+0x185>
 84b:	mov    QWORD PTR [rsp+0x8],rax
 850:	mov    rdi,rbx
 853:	mov    r13,rax
 856:	mov    rax,QWORD PTR [rdi+0x10]
 85a:	mov    rsi,QWORD PTR [rax+0x38]
 85e:	mov    QWORD PTR [rsp+0x10],rsi
 863:	call   868 <botlish_fn_5+0xb9>
			864: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 868:	test   rax,rax
 86b:	je     934 <botlish_fn_5+0x185>
 871:	mov    QWORD PTR [rsp+0x10],rax
 876:	mov    rdi,rbx
 879:	mov    r14,rax
 87c:	mov    rax,QWORD PTR [rdi+0x10]
 880:	mov    rsi,QWORD PTR [rax+0x40]
 884:	mov    QWORD PTR [rsp+0x18],rsi
 889:	call   88e <botlish_fn_5+0xdf>
			88a: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 88e:	test   rax,rax
 891:	je     934 <botlish_fn_5+0x185>
 897:	mov    QWORD PTR [rsp+0x18],rax
 89c:	mov    rdi,rbx
 89f:	mov    r15,rax
 8a2:	mov    rax,QWORD PTR [rdi+0x10]
 8a6:	mov    rsi,QWORD PTR [rax+0x48]
 8aa:	mov    QWORD PTR [rsp+0x20],rsi
 8af:	call   8b4 <botlish_fn_5+0x105>
			8b0: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8b4:	test   rax,rax
 8b7:	je     934 <botlish_fn_5+0x185>
 8bd:	mov    QWORD PTR [rsp+0x20],rax
 8c2:	mov    rdi,rbx
 8c5:	mov    QWORD PTR [rsp+0x60],rax
 8ca:	mov    rax,QWORD PTR [rdi+0x10]
 8ce:	mov    rsi,QWORD PTR [rax+0x50]
 8d2:	mov    QWORD PTR [rsp+0x28],rsi
 8d7:	call   8dc <botlish_fn_5+0x12d>
			8d8: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 8dc:	test   rax,rax
 8df:	je     934 <botlish_fn_5+0x185>
 8e5:	mov    QWORD PTR [rsp+0x28],rax
 8ea:	lea    rdx,[rsp+0x30]
 8ef:	mov    rcx,r12
 8f2:	mov    QWORD PTR [rsp+0x30],rcx
 8f7:	mov    rcx,r13
 8fa:	mov    QWORD PTR [rsp+0x38],rcx
 8ff:	mov    rcx,r14
 902:	mov    QWORD PTR [rsp+0x40],rcx
 907:	mov    rcx,r15
 90a:	mov    QWORD PTR [rsp+0x48],rcx
 90f:	mov    rcx,QWORD PTR [rsp+0x60]
 914:	mov    QWORD PTR [rsp+0x50],rcx
 919:	mov    QWORD PTR [rsp+0x58],rax
 91e:	mov    esi,0x6
 923:	mov    rdi,rbx
 926:	call   92b <botlish_fn_5+0x17c>
			927: R_X86_64_PLT32	rt_list_new-0x4
 92b:	test   rax,rax
 92e:	jne    965 <botlish_fn_5+0x1b6>
 934:	xor    rax,rax
 937:	mov    rbx,QWORD PTR [rsp+0x70]
 93c:	mov    r12,QWORD PTR [rsp+0x78]
 941:	mov    r13,QWORD PTR [rsp+0x80]
 949:	mov    r14,QWORD PTR [rsp+0x88]
 951:	mov    r15,QWORD PTR [rsp+0x90]
 959:	add    rsp,0xa0
 960:	mov    rsp,rbp
 963:	pop    rbp
 964:	ret
 965:	mov    rbx,QWORD PTR [rsp+0x70]
 96a:	mov    r12,QWORD PTR [rsp+0x78]
 96f:	mov    r13,QWORD PTR [rsp+0x80]
 977:	mov    r14,QWORD PTR [rsp+0x88]
 97f:	mov    r15,QWORD PTR [rsp+0x90]
 987:	add    rsp,0xa0
 98e:	mov    rsp,rbp
 991:	pop    rbp
 992:	ret

0000000000000993 <botlish_entry_5: sample<generic>>:
 993:	push   rbp
 994:	mov    rbp,rsp
 997:	call   99c <botlish_entry_5+0x9>
			998: R_X86_64_PLT32	botlish_fn_5-0x4 ; sample<generic>
 99c:	mov    rsp,rbp
 99f:	pop    rbp
 9a0:	ret

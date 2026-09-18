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
  2f:	ja     225 <botlish_fn_0+0x225>
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
  90:	jmp    1ce <botlish_fn_0+0x1ce>
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
  bf:	jmp    1ce <botlish_fn_0+0x1ce>
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
  ef:	jmp    1ce <botlish_fn_0+0x1ce>
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
 11f:	jmp    1ce <botlish_fn_0+0x1ce>
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
 14c:	jmp    1ce <botlish_fn_0+0x1ce>
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
 17e:	jmp    1ce <botlish_fn_0+0x1ce>
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
 1b2:	mov    rax,QWORD PTR [rip+0x0]        # 1b9 <botlish_fn_0+0x1b9>
			1b5: R_X86_64_GOTPCREL	rt_list_new-0x4
 1b9:	mov    rdi,QWORD PTR [rsp+0x30]
 1be:	call   rax
 1c0:	test   rax,rax
 1c3:	jne    1fb <botlish_fn_0+0x1fb>
 1c9:	mov    rdi,QWORD PTR [rsp+0x30]
 1ce:	mov    rdi,QWORD PTR [rsp+0x30]
 1d3:	mov    QWORD PTR [rdi],r15
 1d6:	xor    rax,rax
 1d9:	mov    rbx,QWORD PTR [rsp+0x40]
 1de:	mov    r12,QWORD PTR [rsp+0x48]
 1e3:	mov    r13,QWORD PTR [rsp+0x50]
 1e8:	mov    r14,QWORD PTR [rsp+0x58]
 1ed:	mov    r15,QWORD PTR [rsp+0x60]
 1f2:	add    rsp,0x70
 1f6:	mov    rsp,rbp
 1f9:	pop    rbp
 1fa:	ret
 1fb:	mov    rdi,QWORD PTR [rsp+0x30]
 200:	mov    QWORD PTR [rdi],r15
 203:	mov    rbx,QWORD PTR [rsp+0x40]
 208:	mov    r12,QWORD PTR [rsp+0x48]
 20d:	mov    r13,QWORD PTR [rsp+0x50]
 212:	mov    r14,QWORD PTR [rsp+0x58]
 217:	mov    r15,QWORD PTR [rsp+0x60]
 21c:	add    rsp,0x70
 220:	mov    rsp,rbp
 223:	pop    rbp
 224:	ret
 225:	mov    QWORD PTR [rsp+0x30],rdi
 22a:	mov    rax,QWORD PTR [rip+0x0]        # 231 <botlish_fn_0+0x231>
			22d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 231:	call   rax
 233:	xor    rax,rax
 236:	mov    rbx,QWORD PTR [rsp+0x40]
 23b:	mov    r12,QWORD PTR [rsp+0x48]
 240:	mov    r13,QWORD PTR [rsp+0x50]
 245:	mov    r14,QWORD PTR [rsp+0x58]
 24a:	mov    r15,QWORD PTR [rsp+0x60]
 24f:	add    rsp,0x70
 253:	mov    rsp,rbp
 256:	pop    rbp
 257:	ret

0000000000000258 <botlish_entry_0: <program entry>>:
 258:	push   rbp
 259:	mov    rbp,rsp
 25c:	call   261 <botlish_entry_0+0x9>
			25d: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 261:	mov    rsp,rbp
 264:	pop    rbp
 265:	ret

0000000000000266 <botlish_fn_1: cleaner_emoji<str>>:
 266:	push   rbp
 267:	mov    rbp,rsp
 26a:	sub    rsp,0x20
 26e:	mov    QWORD PTR [rsp],r12
 272:	mov    QWORD PTR [rsp+0x8],r13
 277:	mov    QWORD PTR [rsp+0x10],r15
 27c:	mov    r15,rsi
 27f:	mov    r12,QWORD PTR [rdi]
 282:	mov    r11,QWORD PTR [rdi+0x8]
 286:	lea    rax,[r12+0x8]
 28b:	cmp    rax,r11
 28e:	ja     64d <botlish_fn_1+0x3e7>
 294:	lea    rax,[r12+0x8]
 299:	mov    QWORD PTR [rdi],rax
 29c:	mov    QWORD PTR [r12],0x0
 2a4:	mov    rax,QWORD PTR [rdi+0x10]
 2a8:	mov    r13,rdi
 2ab:	mov    rsi,QWORD PTR [rax+0x30]
 2af:	mov    edx,0x1
 2b4:	mov    ecx,0x3
 2b9:	mov    rax,QWORD PTR [rip+0x0]        # 2c0 <botlish_fn_1+0x5a>
			2bc: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 2c0:	mov    r8,r15
 2c3:	call   rax
 2c5:	cmp    rax,0x6
 2c9:	je     30e <botlish_fn_1+0xa8>
 2cf:	mov    rdi,r13
 2d2:	mov    rax,QWORD PTR [rdi+0x10]
 2d6:	mov    rsi,QWORD PTR [rax+0x38]
 2da:	mov    edx,0x1
 2df:	mov    ecx,0x3
 2e4:	mov    rax,QWORD PTR [rip+0x0]        # 2eb <botlish_fn_1+0x85>
			2e7: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 2eb:	mov    r8,r15
 2ee:	call   rax
 2f0:	cmp    rax,0x6
 2f4:	je     304 <botlish_fn_1+0x9e>
 2fa:	mov    eax,0x2
 2ff:	jmp    313 <botlish_fn_1+0xad>
 304:	mov    eax,0x6
 309:	jmp    313 <botlish_fn_1+0xad>
 30e:	mov    eax,0x6
 313:	cmp    rax,0x6
 317:	je     35c <botlish_fn_1+0xf6>
 31d:	mov    rdi,r13
 320:	mov    rax,QWORD PTR [rdi+0x10]
 324:	mov    rsi,QWORD PTR [rax+0x40]
 328:	mov    edx,0x1
 32d:	mov    ecx,0x3
 332:	mov    rax,QWORD PTR [rip+0x0]        # 339 <botlish_fn_1+0xd3>
			335: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 339:	mov    r8,r15
 33c:	call   rax
 33e:	cmp    rax,0x6
 342:	je     352 <botlish_fn_1+0xec>
 348:	mov    eax,0x2
 34d:	jmp    361 <botlish_fn_1+0xfb>
 352:	mov    eax,0x6
 357:	jmp    361 <botlish_fn_1+0xfb>
 35c:	mov    eax,0x6
 361:	cmp    rax,0x6
 365:	je     3aa <botlish_fn_1+0x144>
 36b:	mov    rdi,r13
 36e:	mov    rax,QWORD PTR [rdi+0x10]
 372:	mov    rsi,QWORD PTR [rax+0x48]
 376:	mov    edx,0x1
 37b:	mov    ecx,0x3
 380:	mov    rax,QWORD PTR [rip+0x0]        # 387 <botlish_fn_1+0x121>
			383: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 387:	mov    r8,r15
 38a:	call   rax
 38c:	cmp    rax,0x6
 390:	je     3a0 <botlish_fn_1+0x13a>
 396:	mov    esi,0x2
 39b:	jmp    3af <botlish_fn_1+0x149>
 3a0:	mov    esi,0x6
 3a5:	jmp    3af <botlish_fn_1+0x149>
 3aa:	mov    esi,0x6
 3af:	cmp    rsi,0x6
 3b3:	je     3f8 <botlish_fn_1+0x192>
 3b9:	mov    rdi,r13
 3bc:	mov    rax,QWORD PTR [rdi+0x10]
 3c0:	mov    rsi,QWORD PTR [rax+0x50]
 3c4:	mov    edx,0x1
 3c9:	mov    ecx,0x3
 3ce:	mov    rax,QWORD PTR [rip+0x0]        # 3d5 <botlish_fn_1+0x16f>
			3d1: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 3d5:	mov    r8,r15
 3d8:	call   rax
 3da:	cmp    rax,0x6
 3de:	je     3ee <botlish_fn_1+0x188>
 3e4:	mov    eax,0x2
 3e9:	jmp    3fd <botlish_fn_1+0x197>
 3ee:	mov    eax,0x6
 3f3:	jmp    3fd <botlish_fn_1+0x197>
 3f8:	mov    eax,0x6
 3fd:	cmp    rax,0x6
 401:	je     446 <botlish_fn_1+0x1e0>
 407:	mov    rdi,r13
 40a:	mov    rax,QWORD PTR [rdi+0x10]
 40e:	mov    rsi,QWORD PTR [rax+0x58]
 412:	mov    edx,0x1
 417:	mov    ecx,0x3
 41c:	mov    rax,QWORD PTR [rip+0x0]        # 423 <botlish_fn_1+0x1bd>
			41f: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 423:	mov    r8,r15
 426:	call   rax
 428:	cmp    rax,0x6
 42c:	je     43c <botlish_fn_1+0x1d6>
 432:	mov    eax,0x2
 437:	jmp    44b <botlish_fn_1+0x1e5>
 43c:	mov    eax,0x6
 441:	jmp    44b <botlish_fn_1+0x1e5>
 446:	mov    eax,0x6
 44b:	cmp    rax,0x6
 44f:	je     494 <botlish_fn_1+0x22e>
 455:	mov    rdi,r13
 458:	mov    rax,QWORD PTR [rdi+0x10]
 45c:	mov    rsi,QWORD PTR [rax+0x60]
 460:	mov    edx,0x1
 465:	mov    ecx,0x3
 46a:	mov    rax,QWORD PTR [rip+0x0]        # 471 <botlish_fn_1+0x20b>
			46d: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 471:	mov    r8,r15
 474:	call   rax
 476:	cmp    rax,0x6
 47a:	je     48a <botlish_fn_1+0x224>
 480:	mov    eax,0x2
 485:	jmp    499 <botlish_fn_1+0x233>
 48a:	mov    eax,0x6
 48f:	jmp    499 <botlish_fn_1+0x233>
 494:	mov    eax,0x6
 499:	cmp    rax,0x6
 49d:	je     4e3 <botlish_fn_1+0x27d>
 4a3:	mov    rdi,r13
 4a6:	mov    rsi,QWORD PTR [rdi+0x10]
 4aa:	mov    rsi,QWORD PTR [rsi+0x68]
 4ae:	mov    edx,0x1
 4b3:	mov    ecx,0x3
 4b8:	mov    r9,QWORD PTR [rip+0x0]        # 4bf <botlish_fn_1+0x259>
			4bb: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 4bf:	mov    r8,r15
 4c2:	call   r9
 4c5:	cmp    rax,0x6
 4c9:	je     4d9 <botlish_fn_1+0x273>
 4cf:	mov    eax,0x2
 4d4:	jmp    4e8 <botlish_fn_1+0x282>
 4d9:	mov    eax,0x6
 4de:	jmp    4e8 <botlish_fn_1+0x282>
 4e3:	mov    eax,0x6
 4e8:	cmp    rax,0x6
 4ec:	je     532 <botlish_fn_1+0x2cc>
 4f2:	mov    rdi,r13
 4f5:	mov    r11,QWORD PTR [rdi+0x10]
 4f9:	mov    rsi,QWORD PTR [r11+0x70]
 4fd:	mov    edx,0x1
 502:	mov    ecx,0x3
 507:	mov    r11,QWORD PTR [rip+0x0]        # 50e <botlish_fn_1+0x2a8>
			50a: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 50e:	mov    r8,r15
 511:	call   r11
 514:	cmp    rax,0x6
 518:	je     528 <botlish_fn_1+0x2c2>
 51e:	mov    eax,0x2
 523:	jmp    537 <botlish_fn_1+0x2d1>
 528:	mov    eax,0x6
 52d:	jmp    537 <botlish_fn_1+0x2d1>
 532:	mov    eax,0x6
 537:	cmp    rax,0x6
 53b:	je     580 <botlish_fn_1+0x31a>
 541:	mov    rdi,r13
 544:	mov    rax,QWORD PTR [rdi+0x10]
 548:	mov    rsi,QWORD PTR [rax+0x78]
 54c:	mov    edx,0x1
 551:	mov    ecx,0x3
 556:	mov    rax,QWORD PTR [rip+0x0]        # 55d <botlish_fn_1+0x2f7>
			559: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 55d:	mov    r8,r15
 560:	call   rax
 562:	cmp    rax,0x6
 566:	je     576 <botlish_fn_1+0x310>
 56c:	mov    eax,0x2
 571:	jmp    585 <botlish_fn_1+0x31f>
 576:	mov    eax,0x6
 57b:	jmp    585 <botlish_fn_1+0x31f>
 580:	mov    eax,0x6
 585:	cmp    rax,0x6
 589:	je     5d3 <botlish_fn_1+0x36d>
 58f:	mov    rdi,r13
 592:	mov    rax,QWORD PTR [rdi+0x10]
 596:	mov    rsi,QWORD PTR [rax+0x80]
 59d:	mov    edx,0x1
 5a2:	mov    ecx,0x3
 5a7:	mov    rax,QWORD PTR [rip+0x0]        # 5ae <botlish_fn_1+0x348>
			5aa: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 5ae:	mov    r8,r15
 5b1:	call   rax
 5b3:	cmp    rax,0x6
 5b7:	je     5c8 <botlish_fn_1+0x362>
 5bd:	mov    r11d,0x2
 5c3:	jmp    5d9 <botlish_fn_1+0x373>
 5c8:	mov    r11d,0x6
 5ce:	jmp    5d9 <botlish_fn_1+0x373>
 5d3:	mov    r11d,0x6
 5d9:	cmp    r11,0x6
 5dd:	je     628 <botlish_fn_1+0x3c2>
 5e3:	mov    rdi,r13
 5e6:	mov    rax,QWORD PTR [rdi+0x10]
 5ea:	mov    rsi,QWORD PTR [rax+0x88]
 5f1:	mov    edx,0x1
 5f6:	mov    ecx,0x3
 5fb:	mov    rax,QWORD PTR [rip+0x0]        # 602 <botlish_fn_1+0x39c>
			5fe: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 602:	mov    r8,r15
 605:	call   rax
 607:	cmp    rax,0x6
 60b:	je     61b <botlish_fn_1+0x3b5>
 611:	mov    eax,0x2
 616:	jmp    620 <botlish_fn_1+0x3ba>
 61b:	mov    eax,0x6
 620:	mov    rdi,r13
 623:	jmp    630 <botlish_fn_1+0x3ca>
 628:	mov    eax,0x6
 62d:	mov    rdi,r13
 630:	mov    rdi,r13
 633:	mov    QWORD PTR [rdi],r12
 636:	mov    r12,QWORD PTR [rsp]
 63a:	mov    r13,QWORD PTR [rsp+0x8]
 63f:	mov    r15,QWORD PTR [rsp+0x10]
 644:	add    rsp,0x20
 648:	mov    rsp,rbp
 64b:	pop    rbp
 64c:	ret
 64d:	mov    r13,rdi
 650:	mov    rax,QWORD PTR [rip+0x0]        # 657 <botlish_fn_1+0x3f1>
			653: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 657:	call   rax
 659:	xor    rax,rax
 65c:	mov    r12,QWORD PTR [rsp]
 660:	mov    r13,QWORD PTR [rsp+0x8]
 665:	mov    r15,QWORD PTR [rsp+0x10]
 66a:	add    rsp,0x20
 66e:	mov    rsp,rbp
 671:	pop    rbp
 672:	ret

0000000000000673 <botlish_entry_1: cleaner_emoji<str>>:
 673:	push   rbp
 674:	mov    rbp,rsp
 677:	mov    rsi,QWORD PTR [rdx]
 67a:	call   67f <botlish_entry_1+0xc>
			67b: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 67f:	mov    rsp,rbp
 682:	pop    rbp
 683:	ret

0000000000000684 <botlish_fn_2: clean_char<str>>:
 684:	push   rbp
 685:	mov    rbp,rsp
 688:	sub    rsp,0x20
 68c:	mov    QWORD PTR [rsp],rbx
 690:	mov    QWORD PTR [rsp+0x8],r12
 695:	mov    QWORD PTR [rsp+0x10],r13
 69a:	mov    rbx,QWORD PTR [rdi]
 69d:	mov    rax,QWORD PTR [rdi+0x8]
 6a1:	lea    rcx,[rbx+0x8]
 6a5:	cmp    rcx,rax
 6a8:	ja     98f <botlish_fn_2+0x30b>
 6ae:	lea    rax,[rbx+0x8]
 6b2:	mov    QWORD PTR [rdi],rax
 6b5:	mov    r12,rdi
 6b8:	mov    QWORD PTR [rbx],rsi
 6bb:	mov    r13,rsi
 6be:	mov    rsi,r13
 6c1:	mov    rdi,r12
 6c4:	call   6c9 <botlish_fn_2+0x45>
			6c5: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 6c9:	test   rax,rax
 6cc:	jne    6f2 <botlish_fn_2+0x6e>
 6d2:	mov    rdi,r12
 6d5:	mov    QWORD PTR [rdi],rbx
 6d8:	xor    rax,rax
 6db:	mov    rbx,QWORD PTR [rsp]
 6df:	mov    r12,QWORD PTR [rsp+0x8]
 6e4:	mov    r13,QWORD PTR [rsp+0x10]
 6e9:	add    rsp,0x20
 6ed:	mov    rsp,rbp
 6f0:	pop    rbp
 6f1:	ret
 6f2:	cmp    rax,0x6
 6f6:	je     967 <botlish_fn_2+0x2e3>
 6fc:	mov    rdi,r12
 6ff:	mov    rax,QWORD PTR [rdi+0x10]
 703:	mov    rsi,QWORD PTR [rax+0x98]
 70a:	mov    edx,0x1
 70f:	mov    ecx,0x3
 714:	mov    rax,QWORD PTR [rip+0x0]        # 71b <botlish_fn_2+0x97>
			717: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 71b:	mov    r8,r13
 71e:	call   rax
 720:	cmp    rax,0x6
 724:	je     76c <botlish_fn_2+0xe8>
 72a:	mov    rdi,r12
 72d:	mov    rax,QWORD PTR [rdi+0x10]
 731:	mov    rsi,QWORD PTR [rax+0xa0]
 738:	mov    edx,0x1
 73d:	mov    ecx,0x3
 742:	mov    rax,QWORD PTR [rip+0x0]        # 749 <botlish_fn_2+0xc5>
			745: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 749:	mov    r8,r13
 74c:	call   rax
 74e:	cmp    rax,0x6
 752:	je     762 <botlish_fn_2+0xde>
 758:	mov    ecx,0x2
 75d:	jmp    771 <botlish_fn_2+0xed>
 762:	mov    ecx,0x6
 767:	jmp    771 <botlish_fn_2+0xed>
 76c:	mov    ecx,0x6
 771:	cmp    rcx,0x6
 775:	je     93f <botlish_fn_2+0x2bb>
 77b:	mov    rdi,r12
 77e:	mov    rax,QWORD PTR [rdi+0x10]
 782:	mov    rsi,QWORD PTR [rax+0xb0]
 789:	mov    edx,0x1
 78e:	mov    ecx,0x3
 793:	mov    rax,QWORD PTR [rip+0x0]        # 79a <botlish_fn_2+0x116>
			796: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 79a:	mov    r8,r13
 79d:	call   rax
 79f:	cmp    rax,0x6
 7a3:	je     7eb <botlish_fn_2+0x167>
 7a9:	mov    rdi,r12
 7ac:	mov    rax,QWORD PTR [rdi+0x10]
 7b0:	mov    rsi,QWORD PTR [rax+0xb8]
 7b7:	mov    edx,0x1
 7bc:	mov    ecx,0x3
 7c1:	mov    rax,QWORD PTR [rip+0x0]        # 7c8 <botlish_fn_2+0x144>
			7c4: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 7c8:	mov    r8,r13
 7cb:	call   rax
 7cd:	cmp    rax,0x6
 7d1:	je     7e1 <botlish_fn_2+0x15d>
 7d7:	mov    esi,0x2
 7dc:	jmp    7f0 <botlish_fn_2+0x16c>
 7e1:	mov    esi,0x6
 7e6:	jmp    7f0 <botlish_fn_2+0x16c>
 7eb:	mov    esi,0x6
 7f0:	cmp    rsi,0x6
 7f4:	je     917 <botlish_fn_2+0x293>
 7fa:	mov    rdi,r12
 7fd:	mov    rax,QWORD PTR [rdi+0x10]
 801:	mov    rsi,QWORD PTR [rax+0xc8]
 808:	mov    edx,0x1
 80d:	mov    ecx,0x3
 812:	mov    rax,QWORD PTR [rip+0x0]        # 819 <botlish_fn_2+0x195>
			815: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 819:	mov    r8,r13
 81c:	call   rax
 81e:	cmp    rax,0x6
 822:	je     86a <botlish_fn_2+0x1e6>
 828:	mov    rdi,r12
 82b:	mov    rax,QWORD PTR [rdi+0x10]
 82f:	mov    rsi,QWORD PTR [rax+0xd0]
 836:	mov    edx,0x1
 83b:	mov    ecx,0x3
 840:	mov    rax,QWORD PTR [rip+0x0]        # 847 <botlish_fn_2+0x1c3>
			843: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 847:	mov    r8,r13
 84a:	call   rax
 84c:	cmp    rax,0x6
 850:	je     860 <botlish_fn_2+0x1dc>
 856:	mov    ecx,0x2
 85b:	jmp    86f <botlish_fn_2+0x1eb>
 860:	mov    ecx,0x6
 865:	jmp    86f <botlish_fn_2+0x1eb>
 86a:	mov    ecx,0x6
 86f:	cmp    rcx,0x6
 873:	je     8ef <botlish_fn_2+0x26b>
 879:	mov    rdi,r12
 87c:	mov    rax,QWORD PTR [rdi+0x10]
 880:	mov    rsi,QWORD PTR [rax+0xe0]
 887:	mov    edx,0x1
 88c:	mov    ecx,0x3
 891:	mov    rax,QWORD PTR [rip+0x0]        # 898 <botlish_fn_2+0x214>
			894: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 898:	mov    r8,r13
 89b:	call   rax
 89d:	cmp    rax,0x6
 8a1:	je     8c7 <botlish_fn_2+0x243>
 8a7:	mov    rdi,r12
 8aa:	mov    QWORD PTR [rdi],rbx
 8ad:	mov    rax,r13
 8b0:	mov    rbx,QWORD PTR [rsp]
 8b4:	mov    r12,QWORD PTR [rsp+0x8]
 8b9:	mov    r13,QWORD PTR [rsp+0x10]
 8be:	add    rsp,0x20
 8c2:	mov    rsp,rbp
 8c5:	pop    rbp
 8c6:	ret
 8c7:	mov    rdi,r12
 8ca:	mov    rsi,QWORD PTR [rdi+0x10]
 8ce:	mov    rax,QWORD PTR [rsi+0xe8]
 8d5:	mov    QWORD PTR [rdi],rbx
 8d8:	mov    rbx,QWORD PTR [rsp]
 8dc:	mov    r12,QWORD PTR [rsp+0x8]
 8e1:	mov    r13,QWORD PTR [rsp+0x10]
 8e6:	add    rsp,0x20
 8ea:	mov    rsp,rbp
 8ed:	pop    rbp
 8ee:	ret
 8ef:	mov    rdi,r12
 8f2:	mov    rsi,QWORD PTR [rdi+0x10]
 8f6:	mov    rax,QWORD PTR [rsi+0xd8]
 8fd:	mov    QWORD PTR [rdi],rbx
 900:	mov    rbx,QWORD PTR [rsp]
 904:	mov    r12,QWORD PTR [rsp+0x8]
 909:	mov    r13,QWORD PTR [rsp+0x10]
 90e:	add    rsp,0x20
 912:	mov    rsp,rbp
 915:	pop    rbp
 916:	ret
 917:	mov    rdi,r12
 91a:	mov    r8,QWORD PTR [rdi+0x10]
 91e:	mov    rax,QWORD PTR [r8+0xc0]
 925:	mov    QWORD PTR [rdi],rbx
 928:	mov    rbx,QWORD PTR [rsp]
 92c:	mov    r12,QWORD PTR [rsp+0x8]
 931:	mov    r13,QWORD PTR [rsp+0x10]
 936:	add    rsp,0x20
 93a:	mov    rsp,rbp
 93d:	pop    rbp
 93e:	ret
 93f:	mov    rdi,r12
 942:	mov    r10,QWORD PTR [rdi+0x10]
 946:	mov    rax,QWORD PTR [r10+0xa8]
 94d:	mov    QWORD PTR [rdi],rbx
 950:	mov    rbx,QWORD PTR [rsp]
 954:	mov    r12,QWORD PTR [rsp+0x8]
 959:	mov    r13,QWORD PTR [rsp+0x10]
 95e:	add    rsp,0x20
 962:	mov    rsp,rbp
 965:	pop    rbp
 966:	ret
 967:	mov    rdi,r12
 96a:	mov    rax,QWORD PTR [rdi+0x10]
 96e:	mov    rax,QWORD PTR [rax+0x90]
 975:	mov    QWORD PTR [rdi],rbx
 978:	mov    rbx,QWORD PTR [rsp]
 97c:	mov    r12,QWORD PTR [rsp+0x8]
 981:	mov    r13,QWORD PTR [rsp+0x10]
 986:	add    rsp,0x20
 98a:	mov    rsp,rbp
 98d:	pop    rbp
 98e:	ret
 98f:	mov    r12,rdi
 992:	mov    rax,QWORD PTR [rip+0x0]        # 999 <botlish_fn_2+0x315>
			995: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 999:	call   rax
 99b:	xor    rax,rax
 99e:	mov    rbx,QWORD PTR [rsp]
 9a2:	mov    r12,QWORD PTR [rsp+0x8]
 9a7:	mov    r13,QWORD PTR [rsp+0x10]
 9ac:	add    rsp,0x20
 9b0:	mov    rsp,rbp
 9b3:	pop    rbp
 9b4:	ret

00000000000009b5 <botlish_entry_2: clean_char<str>>:
 9b5:	push   rbp
 9b6:	mov    rbp,rsp
 9b9:	mov    rsi,QWORD PTR [rdx]
 9bc:	call   9c1 <botlish_entry_2+0xc>
			9bd: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 9c1:	mov    rsp,rbp
 9c4:	pop    rbp
 9c5:	ret
	...

00000000000009c8 <botlish_fn_3: clean_from<str, int, str>>:
 9c8:	push   rbp
 9c9:	mov    rbp,rsp
 9cc:	sub    rsp,0x40
 9d0:	mov    QWORD PTR [rsp+0x10],rbx
 9d5:	mov    QWORD PTR [rsp+0x18],r12
 9da:	mov    QWORD PTR [rsp+0x20],r13
 9df:	mov    QWORD PTR [rsp+0x28],r14
 9e4:	mov    QWORD PTR [rsp+0x30],r15
 9e9:	mov    r14,QWORD PTR [rdi]
 9ec:	mov    rax,QWORD PTR [rdi+0x8]
 9f0:	lea    r9,[r14+0x30]
 9f4:	cmp    r9,rax
 9f7:	ja     ca5 <botlish_fn_3+0x2dd>
 9fd:	lea    rax,[r14+0x30]
 a01:	mov    QWORD PTR [rdi],rax
 a04:	mov    r15,rdi
 a07:	mov    QWORD PTR [r14],0x0
 a0e:	mov    QWORD PTR [r14+0x8],0x0
 a16:	mov    QWORD PTR [r14+0x10],0x0
 a1e:	mov    QWORD PTR [r14+0x18],0x0
 a26:	mov    QWORD PTR [r14+0x20],0x0
 a2e:	mov    QWORD PTR [r14+0x28],0x0
 a36:	mov    QWORD PTR [r14],rsi
 a39:	mov    QWORD PTR [r14+0x8],rcx
 a3d:	mov    QWORD PTR [r14+0x10],r8
 a41:	mov    r13,rdx
 a44:	mov    QWORD PTR [rsp],rcx
 a48:	mov    QWORD PTR [rsp+0x8],r8
 a4d:	mov    r10,QWORD PTR [rip+0x0]        # a54 <botlish_fn_3+0x8c>
			a50: R_X86_64_GOTPCREL	rt_str_len-0x4
 a54:	mov    rbx,rsi
 a57:	mov    rdi,r15
 a5a:	call   r10
 a5d:	mov    rsi,r13
 a60:	mov    r10,rsi
 a63:	and    r10,rax
 a66:	mov    rdx,rax
 a69:	test   r10,0x1
 a70:	jne    a9a <botlish_fn_3+0xd2>
 a76:	mov    rax,QWORD PTR [rip+0x0]        # a7d <botlish_fn_3+0xb5>
			a79: R_X86_64_GOTPCREL	rt_int_cmp-0x4
 a7d:	mov    rsi,r13
 a80:	mov    rdi,r15
 a83:	call   rax
 a85:	mov    ecx,0x2
 a8a:	test   rax,rax
 a8d:	cmovge rcx,QWORD PTR [rip+0x243]        # cd8 <botlish_fn_3+0x310>
 a95:	jmp    aad <botlish_fn_3+0xe5>
 a9a:	mov    ecx,0x2
 a9f:	mov    rsi,r13
 aa2:	cmp    rsi,rdx
 aa5:	cmovge rcx,QWORD PTR [rip+0x22b]        # cd8 <botlish_fn_3+0x310>
 aad:	cmp    rcx,0x6
 ab1:	je     c79 <botlish_fn_3+0x2b1>
 ab7:	mov    rsi,r13
 aba:	mov    rax,rsi
 abd:	sar    rax,1
 ac0:	lea    r12,[rax+0x1]
 ac4:	shl    r12,1
 ac7:	or     r12,0x1
 acb:	mov    QWORD PTR [r14+0x18],r12
 acf:	mov    rax,QWORD PTR [rip+0x0]        # ad6 <botlish_fn_3+0x10e>
			ad2: R_X86_64_GOTPCREL	rt_str_len-0x4
 ad6:	mov    rsi,rbx
 ad9:	mov    rdi,r15
 adc:	call   rax
 ade:	mov    rsi,r13
 ae1:	mov    rcx,rsi
 ae4:	and    rcx,rax
 ae7:	mov    rdx,rax
 aea:	test   rcx,0x1
 af1:	jne    b1b <botlish_fn_3+0x153>
 af7:	mov    rax,QWORD PTR [rip+0x0]        # afe <botlish_fn_3+0x136>
			afa: R_X86_64_GOTPCREL	rt_int_cmp-0x4
 afe:	mov    rsi,r13
 b01:	mov    rdi,r15
 b04:	call   rax
 b06:	mov    ecx,0x2
 b0b:	test   rax,rax
 b0e:	cmovge rcx,QWORD PTR [rip+0x1c2]        # cd8 <botlish_fn_3+0x310>
 b16:	jmp    b2e <botlish_fn_3+0x166>
 b1b:	mov    ecx,0x2
 b20:	mov    rsi,r13
 b23:	cmp    rsi,rdx
 b26:	cmovge rcx,QWORD PTR [rip+0x1aa]        # cd8 <botlish_fn_3+0x310>
 b2e:	cmp    rcx,0x6
 b32:	je     bd8 <botlish_fn_3+0x210>
 b38:	mov    rax,QWORD PTR [rip+0x0]        # b3f <botlish_fn_3+0x177>
			b3b: R_X86_64_GOTPCREL	rt_str_decode_char_at-0x4
 b3f:	mov    rdx,QWORD PTR [rsp+0x8]
 b44:	mov    rsi,rbx
 b47:	mov    rdi,r15
 b4a:	call   rax
 b4c:	mov    r13,rax
 b4f:	mov    QWORD PTR [r14+0x20],r13
 b53:	mov    rax,QWORD PTR [rip+0x0]        # b5a <botlish_fn_3+0x192>
			b56: R_X86_64_GOTPCREL	rt_str_byte_len-0x4
 b5a:	mov    rsi,r13
 b5d:	mov    rdi,r15
 b60:	call   rax
 b62:	mov    QWORD PTR [r14+0x28],rax
 b66:	mov    rsi,QWORD PTR [rsp+0x8]
 b6b:	mov    rcx,rsi
 b6e:	and    rcx,rax
 b71:	test   rcx,0x1
 b78:	jne    b86 <botlish_fn_3+0x1be>
 b7e:	mov    rdx,rax
 b81:	jmp    bad <botlish_fn_3+0x1e5>
 b86:	lea    rcx,[rax-0x1]
 b8a:	mov    rdx,rax
 b8d:	mov    rsi,QWORD PTR [rsp+0x8]
 b92:	mov    rax,rsi
 b95:	add    rax,rcx
 b98:	seto   cl
 b9b:	test   cl,cl
 b9d:	jne    bad <botlish_fn_3+0x1e5>
 ba3:	mov    QWORD PTR [rsp+0x8],rax
 ba8:	jmp    bc3 <botlish_fn_3+0x1fb>
 bad:	mov    rax,QWORD PTR [rip+0x0]        # bb4 <botlish_fn_3+0x1ec>
			bb0: R_X86_64_GOTPCREL	rt_int_add-0x4
 bb4:	mov    rsi,QWORD PTR [rsp+0x8]
 bb9:	mov    rdi,r15
 bbc:	call   rax
 bbe:	mov    QWORD PTR [rsp+0x8],rax
 bc3:	mov    QWORD PTR [r14+0x10],r13
 bc7:	mov    rsi,QWORD PTR [rsp+0x8]
 bcc:	mov    QWORD PTR [r14+0x20],rsi
 bd0:	mov    rsi,r13
 bd3:	jmp    bf3 <botlish_fn_3+0x22b>
 bd8:	mov    rdi,r15
 bdb:	mov    rax,QWORD PTR [rdi+0x10]
 bdf:	mov    rsi,QWORD PTR [rax+0x90]
 be6:	mov    QWORD PTR [r14+0x10],rsi
 bea:	mov    rax,QWORD PTR [rsp+0x8]
 bef:	mov    QWORD PTR [r14+0x20],rax
 bf3:	mov    rdi,r15
 bf6:	call   bfb <botlish_fn_3+0x233>
			bf7: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 bfb:	test   rax,rax
 bfe:	jne    c0c <botlish_fn_3+0x244>
 c04:	mov    rdi,r15
 c07:	jmp    c2f <botlish_fn_3+0x267>
 c0c:	mov    QWORD PTR [r14+0x10],rax
 c10:	mov    rdx,rax
 c13:	mov    rax,QWORD PTR [rip+0x0]        # c1a <botlish_fn_3+0x252>
			c16: R_X86_64_GOTPCREL	rt_str_cat-0x4
 c1a:	mov    rsi,QWORD PTR [rsp]
 c1e:	mov    rdi,r15
 c21:	call   rax
 c23:	test   rax,rax
 c26:	jne    c5a <botlish_fn_3+0x292>
 c2c:	mov    rdi,r15
 c2f:	mov    rdi,r15
 c32:	mov    QWORD PTR [rdi],r14
 c35:	xor    rax,rax
 c38:	mov    rbx,QWORD PTR [rsp+0x10]
 c3d:	mov    r12,QWORD PTR [rsp+0x18]
 c42:	mov    r13,QWORD PTR [rsp+0x20]
 c47:	mov    r14,QWORD PTR [rsp+0x28]
 c4c:	mov    r15,QWORD PTR [rsp+0x30]
 c51:	add    rsp,0x40
 c55:	mov    rsp,rbp
 c58:	pop    rbp
 c59:	ret
 c5a:	mov    QWORD PTR [r14],rbx
 c5d:	mov    QWORD PTR [r14+0x8],rax
 c61:	mov    rsi,QWORD PTR [rsp+0x8]
 c66:	mov    QWORD PTR [r14+0x10],rsi
 c6a:	mov    rsi,rbx
 c6d:	mov    r13,r12
 c70:	mov    QWORD PTR [rsp],rax
 c74:	jmp    a4d <botlish_fn_3+0x85>
 c79:	mov    rdi,r15
 c7c:	mov    QWORD PTR [rdi],r14
 c7f:	mov    rax,QWORD PTR [rsp]
 c83:	mov    rbx,QWORD PTR [rsp+0x10]
 c88:	mov    r12,QWORD PTR [rsp+0x18]
 c8d:	mov    r13,QWORD PTR [rsp+0x20]
 c92:	mov    r14,QWORD PTR [rsp+0x28]
 c97:	mov    r15,QWORD PTR [rsp+0x30]
 c9c:	add    rsp,0x40
 ca0:	mov    rsp,rbp
 ca3:	pop    rbp
 ca4:	ret
 ca5:	mov    r15,rdi
 ca8:	mov    rax,QWORD PTR [rip+0x0]        # caf <botlish_fn_3+0x2e7>
			cab: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 caf:	call   rax
 cb1:	xor    rax,rax
 cb4:	mov    rbx,QWORD PTR [rsp+0x10]
 cb9:	mov    r12,QWORD PTR [rsp+0x18]
 cbe:	mov    r13,QWORD PTR [rsp+0x20]
 cc3:	mov    r14,QWORD PTR [rsp+0x28]
 cc8:	mov    r15,QWORD PTR [rsp+0x30]
 ccd:	add    rsp,0x40
 cd1:	mov    rsp,rbp
 cd4:	pop    rbp
 cd5:	ret
 cd6:	add    BYTE PTR [rax],al
 cd8:	(bad)
 cd9:	add    BYTE PTR [rax],al
 cdb:	add    BYTE PTR [rax],al
 cdd:	add    BYTE PTR [rax],al
	...

0000000000000ce0 <botlish_entry_3: clean_from<str, int, str>>:
 ce0:	push   rbp
 ce1:	mov    rbp,rsp
 ce4:	mov    rsi,QWORD PTR [rdx]
 ce7:	mov    r9,QWORD PTR [rdx+0x8]
 ceb:	mov    rcx,QWORD PTR [rdx+0x10]
 cef:	mov    r8,QWORD PTR [rdx+0x18]
 cf3:	mov    rdx,r9
 cf6:	call   cfb <botlish_entry_3+0x1b>
			cf7: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 cfb:	mov    rsp,rbp
 cfe:	pop    rbp
 cff:	ret

0000000000000d00 <botlish_fn_4: clean_ai_text<str>>:
 d00:	push   rbp
 d01:	mov    rbp,rsp
 d04:	sub    rsp,0x10
 d08:	mov    QWORD PTR [rsp],rbx
 d0c:	mov    QWORD PTR [rsp+0x8],r12
 d11:	mov    rbx,QWORD PTR [rdi]
 d14:	mov    rax,QWORD PTR [rdi+0x8]
 d18:	lea    rcx,[rbx+0x20]
 d1c:	cmp    rcx,rax
 d1f:	ja     dba <botlish_fn_4+0xba>
 d25:	lea    rax,[rbx+0x20]
 d29:	mov    QWORD PTR [rdi],rax
 d2c:	mov    QWORD PTR [rbx],0x0
 d33:	mov    QWORD PTR [rbx+0x8],0x0
 d3b:	mov    QWORD PTR [rbx+0x10],0x0
 d43:	mov    QWORD PTR [rbx+0x18],0x0
 d4b:	mov    QWORD PTR [rbx],rsi
 d4e:	mov    r8d,0x1
 d54:	mov    QWORD PTR [rbx+0x8],0x1
 d5c:	mov    rax,QWORD PTR [rdi+0x10]
 d60:	mov    r12,rdi
 d63:	mov    rcx,QWORD PTR [rax+0x90]
 d6a:	mov    QWORD PTR [rbx+0x10],rcx
 d6e:	mov    QWORD PTR [rbx+0x18],0x1
 d76:	mov    rdx,r8
 d79:	call   d7e <botlish_fn_4+0x7e>
			d7a: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 d7e:	test   rax,rax
 d81:	jne    da2 <botlish_fn_4+0xa2>
 d87:	mov    rdi,r12
 d8a:	mov    QWORD PTR [rdi],rbx
 d8d:	xor    rax,rax
 d90:	mov    rbx,QWORD PTR [rsp]
 d94:	mov    r12,QWORD PTR [rsp+0x8]
 d99:	add    rsp,0x10
 d9d:	mov    rsp,rbp
 da0:	pop    rbp
 da1:	ret
 da2:	mov    rdi,r12
 da5:	mov    QWORD PTR [rdi],rbx
 da8:	mov    rbx,QWORD PTR [rsp]
 dac:	mov    r12,QWORD PTR [rsp+0x8]
 db1:	add    rsp,0x10
 db5:	mov    rsp,rbp
 db8:	pop    rbp
 db9:	ret
 dba:	mov    rax,QWORD PTR [rip+0x0]        # dc1 <botlish_fn_4+0xc1>
			dbd: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 dc1:	call   rax
 dc3:	xor    rax,rax
 dc6:	mov    rbx,QWORD PTR [rsp]
 dca:	mov    r12,QWORD PTR [rsp+0x8]
 dcf:	add    rsp,0x10
 dd3:	mov    rsp,rbp
 dd6:	pop    rbp
 dd7:	ret

0000000000000dd8 <botlish_entry_4: clean_ai_text<str>>:
 dd8:	push   rbp
 dd9:	mov    rbp,rsp
 ddc:	mov    rsi,QWORD PTR [rdx]
 ddf:	call   de4 <botlish_entry_4+0xc>
			de0: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 de4:	mov    rsp,rbp
 de7:	pop    rbp
 de8:	ret

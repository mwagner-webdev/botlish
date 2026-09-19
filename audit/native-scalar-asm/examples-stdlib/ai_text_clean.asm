; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3585  (per function: 613 1085 858 824 205)
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
  21:	mov    r14,QWORD PTR [rdi]
  24:	mov    rax,QWORD PTR [rdi+0x8]
  28:	lea    rcx,[r14+0x30]
  2c:	cmp    rcx,rax
  2f:	ja     21a <botlish_fn_0+0x21a>
  35:	lea    rax,[r14+0x30]
  39:	mov    QWORD PTR [rdi],rax
  3c:	mov    QWORD PTR [r14+0x8],0x0
  44:	mov    QWORD PTR [r14+0x10],0x0
  4c:	mov    QWORD PTR [r14+0x18],0x0
  54:	mov    QWORD PTR [r14+0x20],0x0
  5c:	mov    QWORD PTR [r14+0x28],0x0
  64:	mov    rax,QWORD PTR [rdi+0x10]
  68:	mov    QWORD PTR [rsp+0x30],rdi
  6d:	mov    rsi,QWORD PTR [rax]
  70:	mov    QWORD PTR [r14],rsi
  73:	call   78 <botlish_fn_0+0x78>
			74: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  78:	mov    rbx,rax
  7b:	test   rbx,rbx
  7e:	jne    8e <botlish_fn_0+0x8e>
  84:	mov    rdi,QWORD PTR [rsp+0x30]
  89:	jmp    1c3 <botlish_fn_0+0x1c3>
  8e:	mov    QWORD PTR [r14],rbx
  91:	mov    rdi,QWORD PTR [rsp+0x30]
  96:	mov    rax,QWORD PTR [rdi+0x10]
  9a:	mov    rsi,QWORD PTR [rax+0x8]
  9e:	mov    QWORD PTR [r14+0x8],rsi
  a2:	call   a7 <botlish_fn_0+0xa7>
			a3: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  a7:	mov    r12,rax
  aa:	test   r12,r12
  ad:	jne    bd <botlish_fn_0+0xbd>
  b3:	mov    rdi,QWORD PTR [rsp+0x30]
  b8:	jmp    1c3 <botlish_fn_0+0x1c3>
  bd:	mov    QWORD PTR [r14+0x8],r12
  c1:	mov    rdi,QWORD PTR [rsp+0x30]
  c6:	mov    rax,QWORD PTR [rdi+0x10]
  ca:	mov    rsi,QWORD PTR [rax+0x10]
  ce:	mov    QWORD PTR [r14+0x10],rsi
  d2:	call   d7 <botlish_fn_0+0xd7>
			d3: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  d7:	mov    r15,rax
  da:	test   r15,r15
  dd:	jne    ed <botlish_fn_0+0xed>
  e3:	mov    rdi,QWORD PTR [rsp+0x30]
  e8:	jmp    1c3 <botlish_fn_0+0x1c3>
  ed:	mov    QWORD PTR [r14+0x10],r15
  f1:	mov    rdi,QWORD PTR [rsp+0x30]
  f6:	mov    rax,QWORD PTR [rdi+0x10]
  fa:	mov    rsi,QWORD PTR [rax+0x18]
  fe:	mov    QWORD PTR [r14+0x18],rsi
 102:	call   107 <botlish_fn_0+0x107>
			103: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 107:	mov    r13,rax
 10a:	test   r13,r13
 10d:	jne    11d <botlish_fn_0+0x11d>
 113:	mov    rdi,QWORD PTR [rsp+0x30]
 118:	jmp    1c3 <botlish_fn_0+0x1c3>
 11d:	mov    QWORD PTR [r14+0x18],r13
 121:	mov    rdi,QWORD PTR [rsp+0x30]
 126:	mov    rax,QWORD PTR [rdi+0x10]
 12a:	mov    rsi,QWORD PTR [rax+0x20]
 12e:	mov    QWORD PTR [r14+0x20],rsi
 132:	call   137 <botlish_fn_0+0x137>
			133: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 137:	test   rax,rax
 13a:	jne    14a <botlish_fn_0+0x14a>
 140:	mov    rdi,QWORD PTR [rsp+0x30]
 145:	jmp    1c3 <botlish_fn_0+0x1c3>
 14a:	mov    QWORD PTR [r14+0x20],rax
 14e:	mov    rdi,QWORD PTR [rsp+0x30]
 153:	mov    QWORD PTR [rsp+0x38],rax
 158:	mov    rdx,QWORD PTR [rdi+0x10]
 15c:	mov    rsi,QWORD PTR [rdx+0x28]
 160:	mov    QWORD PTR [r14+0x28],rsi
 164:	call   169 <botlish_fn_0+0x169>
			165: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 169:	test   rax,rax
 16c:	jne    17c <botlish_fn_0+0x17c>
 172:	mov    rdi,QWORD PTR [rsp+0x30]
 177:	jmp    1c3 <botlish_fn_0+0x1c3>
 17c:	mov    QWORD PTR [r14+0x28],rax
 180:	lea    rdx,[rsp]
 184:	mov    QWORD PTR [rsp],rbx
 188:	mov    QWORD PTR [rsp+0x8],r12
 18d:	mov    QWORD PTR [rsp+0x10],r15
 192:	mov    QWORD PTR [rsp+0x18],r13
 197:	mov    rcx,QWORD PTR [rsp+0x38]
 19c:	mov    QWORD PTR [rsp+0x20],rcx
 1a1:	mov    QWORD PTR [rsp+0x28],rax
 1a6:	mov    esi,0x6
 1ab:	mov    rdi,QWORD PTR [rsp+0x30]
 1b0:	call   1b5 <botlish_fn_0+0x1b5>
			1b1: R_X86_64_PLT32	rt_list_new-0x4
 1b5:	test   rax,rax
 1b8:	jne    1f0 <botlish_fn_0+0x1f0>
 1be:	mov    rdi,QWORD PTR [rsp+0x30]
 1c3:	mov    rdi,QWORD PTR [rsp+0x30]
 1c8:	mov    QWORD PTR [rdi],r14
 1cb:	xor    rax,rax
 1ce:	mov    rbx,QWORD PTR [rsp+0x40]
 1d3:	mov    r12,QWORD PTR [rsp+0x48]
 1d8:	mov    r13,QWORD PTR [rsp+0x50]
 1dd:	mov    r14,QWORD PTR [rsp+0x58]
 1e2:	mov    r15,QWORD PTR [rsp+0x60]
 1e7:	add    rsp,0x70
 1eb:	mov    rsp,rbp
 1ee:	pop    rbp
 1ef:	ret
 1f0:	mov    rdi,QWORD PTR [rsp+0x30]
 1f5:	mov    QWORD PTR [rdi],r14
 1f8:	mov    rbx,QWORD PTR [rsp+0x40]
 1fd:	mov    r12,QWORD PTR [rsp+0x48]
 202:	mov    r13,QWORD PTR [rsp+0x50]
 207:	mov    r14,QWORD PTR [rsp+0x58]
 20c:	mov    r15,QWORD PTR [rsp+0x60]
 211:	add    rsp,0x70
 215:	mov    rsp,rbp
 218:	pop    rbp
 219:	ret
 21a:	mov    QWORD PTR [rsp+0x30],rdi
 21f:	call   224 <botlish_fn_0+0x224>
			220: R_X86_64_PLT32	rt_stack_overflow-0x4
 224:	xor    rax,rax
 227:	mov    rbx,QWORD PTR [rsp+0x40]
 22c:	mov    r12,QWORD PTR [rsp+0x48]
 231:	mov    r13,QWORD PTR [rsp+0x50]
 236:	mov    r14,QWORD PTR [rsp+0x58]
 23b:	mov    r15,QWORD PTR [rsp+0x60]
 240:	add    rsp,0x70
 244:	mov    rsp,rbp
 247:	pop    rbp
 248:	ret

0000000000000249 <botlish_entry_0: <program entry>>:
 249:	push   rbp
 24a:	mov    rbp,rsp
 24d:	call   252 <botlish_entry_0+0x9>
			24e: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 252:	mov    rsp,rbp
 255:	pop    rbp
 256:	ret

0000000000000257 <botlish_fn_1: cleaner_emoji<str>>:
 257:	push   rbp
 258:	mov    rbp,rsp
 25b:	sub    rsp,0x20
 25f:	mov    QWORD PTR [rsp],rbx
 263:	mov    QWORD PTR [rsp+0x8],r12
 268:	mov    QWORD PTR [rsp+0x10],r13
 26d:	mov    r13,rsi
 270:	mov    rbx,QWORD PTR [rdi]
 273:	mov    rax,QWORD PTR [rdi+0x8]
 277:	lea    rcx,[rbx+0x8]
 27b:	cmp    rcx,rax
 27e:	ja     602 <botlish_fn_1+0x3ab>
 284:	lea    rax,[rbx+0x8]
 288:	mov    QWORD PTR [rdi],rax
 28b:	mov    rdx,QWORD PTR [rdi+0x10]
 28f:	mov    r12,rdi
 292:	mov    rsi,QWORD PTR [rdx+0x30]
 296:	mov    edx,0x1
 29b:	mov    ecx,0x3
 2a0:	mov    r8,r13
 2a3:	call   2a8 <botlish_fn_1+0x51>
			2a4: R_X86_64_PLT32	rt_str_region_eq-0x4
 2a8:	cmp    rax,0x6
 2ac:	je     2ed <botlish_fn_1+0x96>
 2b2:	mov    rdi,r12
 2b5:	mov    rsi,QWORD PTR [rdi+0x10]
 2b9:	mov    rsi,QWORD PTR [rsi+0x38]
 2bd:	mov    edx,0x1
 2c2:	mov    ecx,0x3
 2c7:	mov    r8,r13
 2ca:	call   2cf <botlish_fn_1+0x78>
			2cb: R_X86_64_PLT32	rt_str_region_eq-0x4
 2cf:	cmp    rax,0x6
 2d3:	je     2e3 <botlish_fn_1+0x8c>
 2d9:	mov    eax,0x2
 2de:	jmp    2f2 <botlish_fn_1+0x9b>
 2e3:	mov    eax,0x6
 2e8:	jmp    2f2 <botlish_fn_1+0x9b>
 2ed:	mov    eax,0x6
 2f2:	cmp    rax,0x6
 2f6:	je     337 <botlish_fn_1+0xe0>
 2fc:	mov    rdi,r12
 2ff:	mov    rax,QWORD PTR [rdi+0x10]
 303:	mov    rsi,QWORD PTR [rax+0x40]
 307:	mov    edx,0x1
 30c:	mov    ecx,0x3
 311:	mov    r8,r13
 314:	call   319 <botlish_fn_1+0xc2>
			315: R_X86_64_PLT32	rt_str_region_eq-0x4
 319:	cmp    rax,0x6
 31d:	je     32d <botlish_fn_1+0xd6>
 323:	mov    eax,0x2
 328:	jmp    33c <botlish_fn_1+0xe5>
 32d:	mov    eax,0x6
 332:	jmp    33c <botlish_fn_1+0xe5>
 337:	mov    eax,0x6
 33c:	cmp    rax,0x6
 340:	je     381 <botlish_fn_1+0x12a>
 346:	mov    rdi,r12
 349:	mov    rax,QWORD PTR [rdi+0x10]
 34d:	mov    rsi,QWORD PTR [rax+0x48]
 351:	mov    edx,0x1
 356:	mov    ecx,0x3
 35b:	mov    r8,r13
 35e:	call   363 <botlish_fn_1+0x10c>
			35f: R_X86_64_PLT32	rt_str_region_eq-0x4
 363:	cmp    rax,0x6
 367:	je     377 <botlish_fn_1+0x120>
 36d:	mov    eax,0x2
 372:	jmp    386 <botlish_fn_1+0x12f>
 377:	mov    eax,0x6
 37c:	jmp    386 <botlish_fn_1+0x12f>
 381:	mov    eax,0x6
 386:	cmp    rax,0x6
 38a:	je     3cb <botlish_fn_1+0x174>
 390:	mov    rdi,r12
 393:	mov    rax,QWORD PTR [rdi+0x10]
 397:	mov    rsi,QWORD PTR [rax+0x50]
 39b:	mov    edx,0x1
 3a0:	mov    ecx,0x3
 3a5:	mov    r8,r13
 3a8:	call   3ad <botlish_fn_1+0x156>
			3a9: R_X86_64_PLT32	rt_str_region_eq-0x4
 3ad:	cmp    rax,0x6
 3b1:	je     3c1 <botlish_fn_1+0x16a>
 3b7:	mov    eax,0x2
 3bc:	jmp    3d0 <botlish_fn_1+0x179>
 3c1:	mov    eax,0x6
 3c6:	jmp    3d0 <botlish_fn_1+0x179>
 3cb:	mov    eax,0x6
 3d0:	cmp    rax,0x6
 3d4:	je     415 <botlish_fn_1+0x1be>
 3da:	mov    rdi,r12
 3dd:	mov    rax,QWORD PTR [rdi+0x10]
 3e1:	mov    rsi,QWORD PTR [rax+0x58]
 3e5:	mov    edx,0x1
 3ea:	mov    ecx,0x3
 3ef:	mov    r8,r13
 3f2:	call   3f7 <botlish_fn_1+0x1a0>
			3f3: R_X86_64_PLT32	rt_str_region_eq-0x4
 3f7:	cmp    rax,0x6
 3fb:	je     40b <botlish_fn_1+0x1b4>
 401:	mov    eax,0x2
 406:	jmp    41a <botlish_fn_1+0x1c3>
 40b:	mov    eax,0x6
 410:	jmp    41a <botlish_fn_1+0x1c3>
 415:	mov    eax,0x6
 41a:	cmp    rax,0x6
 41e:	je     45f <botlish_fn_1+0x208>
 424:	mov    rdi,r12
 427:	mov    rax,QWORD PTR [rdi+0x10]
 42b:	mov    rsi,QWORD PTR [rax+0x60]
 42f:	mov    edx,0x1
 434:	mov    ecx,0x3
 439:	mov    r8,r13
 43c:	call   441 <botlish_fn_1+0x1ea>
			43d: R_X86_64_PLT32	rt_str_region_eq-0x4
 441:	cmp    rax,0x6
 445:	je     455 <botlish_fn_1+0x1fe>
 44b:	mov    eax,0x2
 450:	jmp    464 <botlish_fn_1+0x20d>
 455:	mov    eax,0x6
 45a:	jmp    464 <botlish_fn_1+0x20d>
 45f:	mov    eax,0x6
 464:	cmp    rax,0x6
 468:	je     4ab <botlish_fn_1+0x254>
 46e:	mov    rdi,r12
 471:	mov    rax,QWORD PTR [rdi+0x10]
 475:	mov    rsi,QWORD PTR [rax+0x68]
 479:	mov    edx,0x1
 47e:	mov    ecx,0x3
 483:	mov    r8,r13
 486:	call   48b <botlish_fn_1+0x234>
			487: R_X86_64_PLT32	rt_str_region_eq-0x4
 48b:	cmp    rax,0x6
 48f:	je     4a0 <botlish_fn_1+0x249>
 495:	mov    r8d,0x2
 49b:	jmp    4b1 <botlish_fn_1+0x25a>
 4a0:	mov    r8d,0x6
 4a6:	jmp    4b1 <botlish_fn_1+0x25a>
 4ab:	mov    r8d,0x6
 4b1:	cmp    r8,0x6
 4b5:	je     4f6 <botlish_fn_1+0x29f>
 4bb:	mov    rdi,r12
 4be:	mov    rax,QWORD PTR [rdi+0x10]
 4c2:	mov    rsi,QWORD PTR [rax+0x70]
 4c6:	mov    edx,0x1
 4cb:	mov    ecx,0x3
 4d0:	mov    r8,r13
 4d3:	call   4d8 <botlish_fn_1+0x281>
			4d4: R_X86_64_PLT32	rt_str_region_eq-0x4
 4d8:	cmp    rax,0x6
 4dc:	je     4ec <botlish_fn_1+0x295>
 4e2:	mov    eax,0x2
 4e7:	jmp    4fb <botlish_fn_1+0x2a4>
 4ec:	mov    eax,0x6
 4f1:	jmp    4fb <botlish_fn_1+0x2a4>
 4f6:	mov    eax,0x6
 4fb:	cmp    rax,0x6
 4ff:	je     540 <botlish_fn_1+0x2e9>
 505:	mov    rdi,r12
 508:	mov    rsi,QWORD PTR [rdi+0x10]
 50c:	mov    rsi,QWORD PTR [rsi+0x78]
 510:	mov    edx,0x1
 515:	mov    ecx,0x3
 51a:	mov    r8,r13
 51d:	call   522 <botlish_fn_1+0x2cb>
			51e: R_X86_64_PLT32	rt_str_region_eq-0x4
 522:	cmp    rax,0x6
 526:	je     536 <botlish_fn_1+0x2df>
 52c:	mov    eax,0x2
 531:	jmp    545 <botlish_fn_1+0x2ee>
 536:	mov    eax,0x6
 53b:	jmp    545 <botlish_fn_1+0x2ee>
 540:	mov    eax,0x6
 545:	cmp    rax,0x6
 549:	je     58d <botlish_fn_1+0x336>
 54f:	mov    rdi,r12
 552:	mov    rax,QWORD PTR [rdi+0x10]
 556:	mov    rsi,QWORD PTR [rax+0x80]
 55d:	mov    edx,0x1
 562:	mov    ecx,0x3
 567:	mov    r8,r13
 56a:	call   56f <botlish_fn_1+0x318>
			56b: R_X86_64_PLT32	rt_str_region_eq-0x4
 56f:	cmp    rax,0x6
 573:	je     583 <botlish_fn_1+0x32c>
 579:	mov    eax,0x2
 57e:	jmp    592 <botlish_fn_1+0x33b>
 583:	mov    eax,0x6
 588:	jmp    592 <botlish_fn_1+0x33b>
 58d:	mov    eax,0x6
 592:	cmp    rax,0x6
 596:	je     5dd <botlish_fn_1+0x386>
 59c:	mov    rdi,r12
 59f:	mov    rax,QWORD PTR [rdi+0x10]
 5a3:	mov    rsi,QWORD PTR [rax+0x88]
 5aa:	mov    edx,0x1
 5af:	mov    ecx,0x3
 5b4:	mov    r8,r13
 5b7:	call   5bc <botlish_fn_1+0x365>
			5b8: R_X86_64_PLT32	rt_str_region_eq-0x4
 5bc:	cmp    rax,0x6
 5c0:	je     5d0 <botlish_fn_1+0x379>
 5c6:	mov    eax,0x2
 5cb:	jmp    5d5 <botlish_fn_1+0x37e>
 5d0:	mov    eax,0x6
 5d5:	mov    rdi,r12
 5d8:	jmp    5e5 <botlish_fn_1+0x38e>
 5dd:	mov    eax,0x6
 5e2:	mov    rdi,r12
 5e5:	mov    rdi,r12
 5e8:	mov    QWORD PTR [rdi],rbx
 5eb:	mov    rbx,QWORD PTR [rsp]
 5ef:	mov    r12,QWORD PTR [rsp+0x8]
 5f4:	mov    r13,QWORD PTR [rsp+0x10]
 5f9:	add    rsp,0x20
 5fd:	mov    rsp,rbp
 600:	pop    rbp
 601:	ret
 602:	mov    r12,rdi
 605:	call   60a <botlish_fn_1+0x3b3>
			606: R_X86_64_PLT32	rt_stack_overflow-0x4
 60a:	xor    rax,rax
 60d:	mov    rbx,QWORD PTR [rsp]
 611:	mov    r12,QWORD PTR [rsp+0x8]
 616:	mov    r13,QWORD PTR [rsp+0x10]
 61b:	add    rsp,0x20
 61f:	mov    rsp,rbp
 622:	pop    rbp
 623:	ret

0000000000000624 <botlish_entry_1: cleaner_emoji<str>>:
 624:	push   rbp
 625:	mov    rbp,rsp
 628:	mov    rsi,QWORD PTR [rdx]
 62b:	call   630 <botlish_entry_1+0xc>
			62c: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 630:	mov    rsp,rbp
 633:	pop    rbp
 634:	ret

0000000000000635 <botlish_fn_2: clean_char<str>>:
 635:	push   rbp
 636:	mov    rbp,rsp
 639:	sub    rsp,0x20
 63d:	mov    QWORD PTR [rsp],r12
 641:	mov    QWORD PTR [rsp+0x8],r13
 646:	mov    QWORD PTR [rsp+0x10],r14
 64b:	mov    r12,QWORD PTR [rdi]
 64e:	mov    r9,QWORD PTR [rdi+0x8]
 652:	lea    r10,[r12+0x8]
 657:	cmp    r10,r9
 65a:	ja     927 <botlish_fn_2+0x2f2>
 660:	lea    r11,[r12+0x8]
 665:	mov    QWORD PTR [rdi],r11
 668:	mov    r13,rdi
 66b:	mov    QWORD PTR [r12],rsi
 66f:	mov    r14,rsi
 672:	mov    rsi,r14
 675:	mov    rdi,r13
 678:	call   67d <botlish_fn_2+0x48>
			679: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 67d:	test   rax,rax
 680:	jne    6a6 <botlish_fn_2+0x71>
 686:	mov    rdi,r13
 689:	mov    QWORD PTR [rdi],r12
 68c:	xor    rax,rax
 68f:	mov    r12,QWORD PTR [rsp]
 693:	mov    r13,QWORD PTR [rsp+0x8]
 698:	mov    r14,QWORD PTR [rsp+0x10]
 69d:	add    rsp,0x20
 6a1:	mov    rsp,rbp
 6a4:	pop    rbp
 6a5:	ret
 6a6:	cmp    rax,0x6
 6aa:	je     8ff <botlish_fn_2+0x2ca>
 6b0:	mov    rdi,r13
 6b3:	mov    rax,QWORD PTR [rdi+0x10]
 6b7:	mov    rsi,QWORD PTR [rax+0x98]
 6be:	mov    edx,0x1
 6c3:	mov    ecx,0x3
 6c8:	mov    r8,r14
 6cb:	call   6d0 <botlish_fn_2+0x9b>
			6cc: R_X86_64_PLT32	rt_str_region_eq-0x4
 6d0:	cmp    rax,0x6
 6d4:	je     718 <botlish_fn_2+0xe3>
 6da:	mov    rdi,r13
 6dd:	mov    rax,QWORD PTR [rdi+0x10]
 6e1:	mov    rsi,QWORD PTR [rax+0xa0]
 6e8:	mov    edx,0x1
 6ed:	mov    ecx,0x3
 6f2:	mov    r8,r14
 6f5:	call   6fa <botlish_fn_2+0xc5>
			6f6: R_X86_64_PLT32	rt_str_region_eq-0x4
 6fa:	cmp    rax,0x6
 6fe:	je     70e <botlish_fn_2+0xd9>
 704:	mov    ecx,0x2
 709:	jmp    71d <botlish_fn_2+0xe8>
 70e:	mov    ecx,0x6
 713:	jmp    71d <botlish_fn_2+0xe8>
 718:	mov    ecx,0x6
 71d:	cmp    rcx,0x6
 721:	je     8d7 <botlish_fn_2+0x2a2>
 727:	mov    rdi,r13
 72a:	mov    rax,QWORD PTR [rdi+0x10]
 72e:	mov    rsi,QWORD PTR [rax+0xb0]
 735:	mov    edx,0x1
 73a:	mov    ecx,0x3
 73f:	mov    r8,r14
 742:	call   747 <botlish_fn_2+0x112>
			743: R_X86_64_PLT32	rt_str_region_eq-0x4
 747:	cmp    rax,0x6
 74b:	je     78f <botlish_fn_2+0x15a>
 751:	mov    rdi,r13
 754:	mov    rax,QWORD PTR [rdi+0x10]
 758:	mov    rsi,QWORD PTR [rax+0xb8]
 75f:	mov    edx,0x1
 764:	mov    ecx,0x3
 769:	mov    r8,r14
 76c:	call   771 <botlish_fn_2+0x13c>
			76d: R_X86_64_PLT32	rt_str_region_eq-0x4
 771:	cmp    rax,0x6
 775:	je     785 <botlish_fn_2+0x150>
 77b:	mov    ecx,0x2
 780:	jmp    794 <botlish_fn_2+0x15f>
 785:	mov    ecx,0x6
 78a:	jmp    794 <botlish_fn_2+0x15f>
 78f:	mov    ecx,0x6
 794:	cmp    rcx,0x6
 798:	je     8af <botlish_fn_2+0x27a>
 79e:	mov    rdi,r13
 7a1:	mov    rax,QWORD PTR [rdi+0x10]
 7a5:	mov    rsi,QWORD PTR [rax+0xc8]
 7ac:	mov    edx,0x1
 7b1:	mov    ecx,0x3
 7b6:	mov    r8,r14
 7b9:	call   7be <botlish_fn_2+0x189>
			7ba: R_X86_64_PLT32	rt_str_region_eq-0x4
 7be:	cmp    rax,0x6
 7c2:	je     806 <botlish_fn_2+0x1d1>
 7c8:	mov    rdi,r13
 7cb:	mov    rax,QWORD PTR [rdi+0x10]
 7cf:	mov    rsi,QWORD PTR [rax+0xd0]
 7d6:	mov    edx,0x1
 7db:	mov    ecx,0x3
 7e0:	mov    r8,r14
 7e3:	call   7e8 <botlish_fn_2+0x1b3>
			7e4: R_X86_64_PLT32	rt_str_region_eq-0x4
 7e8:	cmp    rax,0x6
 7ec:	je     7fc <botlish_fn_2+0x1c7>
 7f2:	mov    ecx,0x2
 7f7:	jmp    80b <botlish_fn_2+0x1d6>
 7fc:	mov    ecx,0x6
 801:	jmp    80b <botlish_fn_2+0x1d6>
 806:	mov    ecx,0x6
 80b:	cmp    rcx,0x6
 80f:	je     887 <botlish_fn_2+0x252>
 815:	mov    rdi,r13
 818:	mov    rax,QWORD PTR [rdi+0x10]
 81c:	mov    rsi,QWORD PTR [rax+0xe0]
 823:	mov    edx,0x1
 828:	mov    ecx,0x3
 82d:	mov    r8,r14
 830:	call   835 <botlish_fn_2+0x200>
			831: R_X86_64_PLT32	rt_str_region_eq-0x4
 835:	cmp    rax,0x6
 839:	je     85f <botlish_fn_2+0x22a>
 83f:	mov    rdi,r13
 842:	mov    QWORD PTR [rdi],r12
 845:	mov    rax,r14
 848:	mov    r12,QWORD PTR [rsp]
 84c:	mov    r13,QWORD PTR [rsp+0x8]
 851:	mov    r14,QWORD PTR [rsp+0x10]
 856:	add    rsp,0x20
 85a:	mov    rsp,rbp
 85d:	pop    rbp
 85e:	ret
 85f:	mov    rdi,r13
 862:	mov    rax,QWORD PTR [rdi+0x10]
 866:	mov    rax,QWORD PTR [rax+0xe8]
 86d:	mov    QWORD PTR [rdi],r12
 870:	mov    r12,QWORD PTR [rsp]
 874:	mov    r13,QWORD PTR [rsp+0x8]
 879:	mov    r14,QWORD PTR [rsp+0x10]
 87e:	add    rsp,0x20
 882:	mov    rsp,rbp
 885:	pop    rbp
 886:	ret
 887:	mov    rdi,r13
 88a:	mov    rax,QWORD PTR [rdi+0x10]
 88e:	mov    rax,QWORD PTR [rax+0xd8]
 895:	mov    QWORD PTR [rdi],r12
 898:	mov    r12,QWORD PTR [rsp]
 89c:	mov    r13,QWORD PTR [rsp+0x8]
 8a1:	mov    r14,QWORD PTR [rsp+0x10]
 8a6:	add    rsp,0x20
 8aa:	mov    rsp,rbp
 8ad:	pop    rbp
 8ae:	ret
 8af:	mov    rdi,r13
 8b2:	mov    rax,QWORD PTR [rdi+0x10]
 8b6:	mov    rax,QWORD PTR [rax+0xc0]
 8bd:	mov    QWORD PTR [rdi],r12
 8c0:	mov    r12,QWORD PTR [rsp]
 8c4:	mov    r13,QWORD PTR [rsp+0x8]
 8c9:	mov    r14,QWORD PTR [rsp+0x10]
 8ce:	add    rsp,0x20
 8d2:	mov    rsp,rbp
 8d5:	pop    rbp
 8d6:	ret
 8d7:	mov    rdi,r13
 8da:	mov    rdx,QWORD PTR [rdi+0x10]
 8de:	mov    rax,QWORD PTR [rdx+0xa8]
 8e5:	mov    QWORD PTR [rdi],r12
 8e8:	mov    r12,QWORD PTR [rsp]
 8ec:	mov    r13,QWORD PTR [rsp+0x8]
 8f1:	mov    r14,QWORD PTR [rsp+0x10]
 8f6:	add    rsp,0x20
 8fa:	mov    rsp,rbp
 8fd:	pop    rbp
 8fe:	ret
 8ff:	mov    rdi,r13
 902:	mov    rsi,QWORD PTR [rdi+0x10]
 906:	mov    rax,QWORD PTR [rsi+0x90]
 90d:	mov    QWORD PTR [rdi],r12
 910:	mov    r12,QWORD PTR [rsp]
 914:	mov    r13,QWORD PTR [rsp+0x8]
 919:	mov    r14,QWORD PTR [rsp+0x10]
 91e:	add    rsp,0x20
 922:	mov    rsp,rbp
 925:	pop    rbp
 926:	ret
 927:	mov    r13,rdi
 92a:	call   92f <botlish_fn_2+0x2fa>
			92b: R_X86_64_PLT32	rt_stack_overflow-0x4
 92f:	xor    rax,rax
 932:	mov    r12,QWORD PTR [rsp]
 936:	mov    r13,QWORD PTR [rsp+0x8]
 93b:	mov    r14,QWORD PTR [rsp+0x10]
 940:	add    rsp,0x20
 944:	mov    rsp,rbp
 947:	pop    rbp
 948:	ret

0000000000000949 <botlish_entry_2: clean_char<str>>:
 949:	push   rbp
 94a:	mov    rbp,rsp
 94d:	mov    rsi,QWORD PTR [rdx]
 950:	call   955 <botlish_entry_2+0xc>
			951: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 955:	mov    rsp,rbp
 958:	pop    rbp
 959:	ret
 95a:	add    BYTE PTR [rax],al
 95c:	add    BYTE PTR [rax],al
	...

0000000000000960 <botlish_fn_3: clean_from<str, int, str>>:
 960:	push   rbp
 961:	mov    rbp,rsp
 964:	sub    rsp,0x40
 968:	mov    QWORD PTR [rsp+0x10],rbx
 96d:	mov    QWORD PTR [rsp+0x18],r12
 972:	mov    QWORD PTR [rsp+0x20],r13
 977:	mov    QWORD PTR [rsp+0x28],r14
 97c:	mov    QWORD PTR [rsp+0x30],r15
 981:	mov    rbx,QWORD PTR [rdi]
 984:	mov    rax,QWORD PTR [rdi+0x8]
 988:	lea    r9,[rbx+0x30]
 98c:	cmp    r9,rax
 98f:	ja     c05 <botlish_fn_3+0x2a5>
 995:	lea    rax,[rbx+0x30]
 999:	mov    QWORD PTR [rdi],rax
 99c:	mov    r14,rdi
 99f:	mov    QWORD PTR [rbx+0x20],0x0
 9a7:	mov    QWORD PTR [rbx+0x28],0x0
 9af:	mov    QWORD PTR [rbx],rsi
 9b2:	mov    QWORD PTR [rbx+0x8],rcx
 9b6:	mov    QWORD PTR [rbx+0x10],r8
 9ba:	mov    r12,rsi
 9bd:	mov    r15,r8
 9c0:	mov    QWORD PTR [rsp],rdx
 9c4:	mov    QWORD PTR [rsp+0x8],rcx
 9c9:	mov    rsi,r12
 9cc:	mov    rdi,r14
 9cf:	call   9d4 <botlish_fn_3+0x74>
			9d0: R_X86_64_PLT32	rt_str_len-0x4
 9d4:	mov    rsi,QWORD PTR [rsp]
 9d8:	mov    rcx,rsi
 9db:	and    rcx,rax
 9de:	mov    rdx,rax
 9e1:	test   rcx,0x1
 9e8:	jne    a0f <botlish_fn_3+0xaf>
 9ee:	mov    rsi,QWORD PTR [rsp]
 9f2:	mov    rdi,r14
 9f5:	call   9fa <botlish_fn_3+0x9a>
			9f6: R_X86_64_PLT32	rt_int_cmp-0x4
 9fa:	mov    ecx,0x2
 9ff:	test   rax,rax
 a02:	cmovge rcx,QWORD PTR [rip+0x22e]        # c38 <botlish_fn_3+0x2d8>
 a0a:	jmp    a23 <botlish_fn_3+0xc3>
 a0f:	mov    ecx,0x2
 a14:	mov    rsi,QWORD PTR [rsp]
 a18:	cmp    rsi,rdx
 a1b:	cmovge rcx,QWORD PTR [rip+0x215]        # c38 <botlish_fn_3+0x2d8>
 a23:	cmp    rcx,0x6
 a27:	je     bd8 <botlish_fn_3+0x278>
 a2d:	mov    rsi,QWORD PTR [rsp]
 a31:	sar    rsi,1
 a34:	lea    r13,[rsi+0x1]
 a38:	shl    r13,1
 a3b:	or     r13,0x1
 a3f:	mov    QWORD PTR [rbx+0x18],r13
 a43:	mov    rsi,r12
 a46:	mov    rdi,r14
 a49:	call   a4e <botlish_fn_3+0xee>
			a4a: R_X86_64_PLT32	rt_str_len-0x4
 a4e:	mov    rsi,QWORD PTR [rsp]
 a52:	mov    rdi,rsi
 a55:	and    rdi,rax
 a58:	mov    rdx,rax
 a5b:	test   rdi,0x1
 a62:	jne    a89 <botlish_fn_3+0x129>
 a68:	mov    rsi,QWORD PTR [rsp]
 a6c:	mov    rdi,r14
 a6f:	call   a74 <botlish_fn_3+0x114>
			a70: R_X86_64_PLT32	rt_int_cmp-0x4
 a74:	mov    ecx,0x2
 a79:	test   rax,rax
 a7c:	cmovge rcx,QWORD PTR [rip+0x1b4]        # c38 <botlish_fn_3+0x2d8>
 a84:	jmp    a9d <botlish_fn_3+0x13d>
 a89:	mov    ecx,0x2
 a8e:	mov    rsi,QWORD PTR [rsp]
 a92:	cmp    rsi,rdx
 a95:	cmovge rcx,QWORD PTR [rip+0x19b]        # c38 <botlish_fn_3+0x2d8>
 a9d:	cmp    rcx,0x6
 aa1:	je     b3f <botlish_fn_3+0x1df>
 aa7:	mov    rdx,r15
 aaa:	mov    rsi,r12
 aad:	mov    rdi,r14
 ab0:	call   ab5 <botlish_fn_3+0x155>
			ab1: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 ab5:	mov    QWORD PTR [rbx+0x20],rax
 ab9:	mov    QWORD PTR [rsp],rax
 abd:	mov    rsi,QWORD PTR [rsp]
 ac1:	mov    rdi,r14
 ac4:	call   ac9 <botlish_fn_3+0x169>
			ac5: R_X86_64_PLT32	rt_str_byte_len-0x4
 ac9:	mov    QWORD PTR [rbx+0x28],rax
 acd:	mov    rsi,r15
 ad0:	mov    rcx,rsi
 ad3:	and    rcx,rax
 ad6:	test   rcx,0x1
 add:	jne    aee <botlish_fn_3+0x18e>
 ae3:	mov    rdx,rax
 ae6:	mov    rsi,r15
 ae9:	jmp    b1d <botlish_fn_3+0x1bd>
 aee:	lea    rcx,[rax-0x1]
 af2:	mov    rdx,rax
 af5:	mov    rsi,r15
 af8:	mov    rax,rsi
 afb:	add    rax,rcx
 afe:	seto   cl
 b01:	test   cl,cl
 b03:	je     b11 <botlish_fn_3+0x1b1>
 b09:	mov    rsi,r15
 b0c:	jmp    b1d <botlish_fn_3+0x1bd>
 b11:	mov    r15,rax
 b14:	mov    rax,QWORD PTR [rsp]
 b18:	jmp    b2c <botlish_fn_3+0x1cc>
 b1d:	mov    rdi,r14
 b20:	call   b25 <botlish_fn_3+0x1c5>
			b21: R_X86_64_PLT32	rt_int_add-0x4
 b25:	mov    r15,rax
 b28:	mov    rax,QWORD PTR [rsp]
 b2c:	mov    QWORD PTR [rbx+0x10],rax
 b30:	mov    rsi,r15
 b33:	mov    QWORD PTR [rbx+0x20],rsi
 b37:	mov    rsi,rax
 b3a:	jmp    b58 <botlish_fn_3+0x1f8>
 b3f:	mov    rdi,r14
 b42:	mov    rax,QWORD PTR [rdi+0x10]
 b46:	mov    rsi,QWORD PTR [rax+0x90]
 b4d:	mov    QWORD PTR [rbx+0x10],rsi
 b51:	mov    rax,r15
 b54:	mov    QWORD PTR [rbx+0x20],rax
 b58:	mov    rdi,r14
 b5b:	call   b60 <botlish_fn_3+0x200>
			b5c: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 b60:	test   rax,rax
 b63:	jne    b71 <botlish_fn_3+0x211>
 b69:	mov    rdi,r14
 b6c:	jmp    b91 <botlish_fn_3+0x231>
 b71:	mov    QWORD PTR [rbx+0x10],rax
 b75:	mov    rdx,rax
 b78:	mov    rsi,QWORD PTR [rsp+0x8]
 b7d:	mov    rdi,r14
 b80:	call   b85 <botlish_fn_3+0x225>
			b81: R_X86_64_PLT32	rt_str_cat-0x4
 b85:	test   rax,rax
 b88:	jne    bbc <botlish_fn_3+0x25c>
 b8e:	mov    rdi,r14
 b91:	mov    rdi,r14
 b94:	mov    QWORD PTR [rdi],rbx
 b97:	xor    rax,rax
 b9a:	mov    rbx,QWORD PTR [rsp+0x10]
 b9f:	mov    r12,QWORD PTR [rsp+0x18]
 ba4:	mov    r13,QWORD PTR [rsp+0x20]
 ba9:	mov    r14,QWORD PTR [rsp+0x28]
 bae:	mov    r15,QWORD PTR [rsp+0x30]
 bb3:	add    rsp,0x40
 bb7:	mov    rsp,rbp
 bba:	pop    rbp
 bbb:	ret
 bbc:	mov    QWORD PTR [rbx],r12
 bbf:	mov    QWORD PTR [rbx+0x8],rax
 bc3:	mov    rsi,r15
 bc6:	mov    QWORD PTR [rbx+0x10],rsi
 bca:	mov    QWORD PTR [rsp],r13
 bce:	mov    QWORD PTR [rsp+0x8],rax
 bd3:	jmp    9c9 <botlish_fn_3+0x69>
 bd8:	mov    rdi,r14
 bdb:	mov    QWORD PTR [rdi],rbx
 bde:	mov    rax,QWORD PTR [rsp+0x8]
 be3:	mov    rbx,QWORD PTR [rsp+0x10]
 be8:	mov    r12,QWORD PTR [rsp+0x18]
 bed:	mov    r13,QWORD PTR [rsp+0x20]
 bf2:	mov    r14,QWORD PTR [rsp+0x28]
 bf7:	mov    r15,QWORD PTR [rsp+0x30]
 bfc:	add    rsp,0x40
 c00:	mov    rsp,rbp
 c03:	pop    rbp
 c04:	ret
 c05:	mov    r14,rdi
 c08:	call   c0d <botlish_fn_3+0x2ad>
			c09: R_X86_64_PLT32	rt_stack_overflow-0x4
 c0d:	xor    rax,rax
 c10:	mov    rbx,QWORD PTR [rsp+0x10]
 c15:	mov    r12,QWORD PTR [rsp+0x18]
 c1a:	mov    r13,QWORD PTR [rsp+0x20]
 c1f:	mov    r14,QWORD PTR [rsp+0x28]
 c24:	mov    r15,QWORD PTR [rsp+0x30]
 c29:	add    rsp,0x40
 c2d:	mov    rsp,rbp
 c30:	pop    rbp
 c31:	ret
 c32:	add    BYTE PTR [rax],al
 c34:	add    BYTE PTR [rax],al
 c36:	add    BYTE PTR [rax],al
 c38:	(bad)
 c39:	add    BYTE PTR [rax],al
 c3b:	add    BYTE PTR [rax],al
 c3d:	add    BYTE PTR [rax],al
	...

0000000000000c40 <botlish_entry_3: clean_from<str, int, str>>:
 c40:	push   rbp
 c41:	mov    rbp,rsp
 c44:	mov    rsi,QWORD PTR [rdx]
 c47:	mov    r9,QWORD PTR [rdx+0x8]
 c4b:	mov    rcx,QWORD PTR [rdx+0x10]
 c4f:	mov    r8,QWORD PTR [rdx+0x18]
 c53:	mov    rdx,r9
 c56:	call   c5b <botlish_entry_3+0x1b>
			c57: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 c5b:	mov    rsp,rbp
 c5e:	pop    rbp
 c5f:	ret

0000000000000c60 <botlish_fn_4: clean_ai_text<str>>:
 c60:	push   rbp
 c61:	mov    rbp,rsp
 c64:	sub    rsp,0x10
 c68:	mov    QWORD PTR [rsp],rbx
 c6c:	mov    QWORD PTR [rsp+0x8],r15
 c71:	mov    r15,QWORD PTR [rdi]
 c74:	mov    rax,QWORD PTR [rdi+0x8]
 c78:	lea    rcx,[r15+0x20]
 c7c:	cmp    rcx,rax
 c7f:	ja     cfb <botlish_fn_4+0x9b>
 c85:	lea    rax,[r15+0x20]
 c89:	mov    QWORD PTR [rdi],rax
 c8c:	mov    QWORD PTR [r15],rsi
 c8f:	mov    r8d,0x1
 c95:	mov    QWORD PTR [r15+0x8],0x1
 c9d:	mov    rax,QWORD PTR [rdi+0x10]
 ca1:	mov    rbx,rdi
 ca4:	mov    rcx,QWORD PTR [rax+0x90]
 cab:	mov    QWORD PTR [r15+0x10],rcx
 caf:	mov    QWORD PTR [r15+0x18],0x1
 cb7:	mov    rdx,r8
 cba:	call   cbf <botlish_fn_4+0x5f>
			cbb: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 cbf:	test   rax,rax
 cc2:	jne    ce3 <botlish_fn_4+0x83>
 cc8:	mov    rdi,rbx
 ccb:	mov    QWORD PTR [rdi],r15
 cce:	xor    rax,rax
 cd1:	mov    rbx,QWORD PTR [rsp]
 cd5:	mov    r15,QWORD PTR [rsp+0x8]
 cda:	add    rsp,0x10
 cde:	mov    rsp,rbp
 ce1:	pop    rbp
 ce2:	ret
 ce3:	mov    rdi,rbx
 ce6:	mov    QWORD PTR [rdi],r15
 ce9:	mov    rbx,QWORD PTR [rsp]
 ced:	mov    r15,QWORD PTR [rsp+0x8]
 cf2:	add    rsp,0x10
 cf6:	mov    rsp,rbp
 cf9:	pop    rbp
 cfa:	ret
 cfb:	call   d00 <botlish_fn_4+0xa0>
			cfc: R_X86_64_PLT32	rt_stack_overflow-0x4
 d00:	xor    rax,rax
 d03:	mov    rbx,QWORD PTR [rsp]
 d07:	mov    r15,QWORD PTR [rsp+0x8]
 d0c:	add    rsp,0x10
 d10:	mov    rsp,rbp
 d13:	pop    rbp
 d14:	ret

0000000000000d15 <botlish_entry_4: clean_ai_text<str>>:
 d15:	push   rbp
 d16:	mov    rbp,rsp
 d19:	mov    rsi,QWORD PTR [rdx]
 d1c:	call   d21 <botlish_entry_4+0xc>
			d1d: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 d21:	mov    rsp,rbp
 d24:	pop    rbp
 d25:	ret

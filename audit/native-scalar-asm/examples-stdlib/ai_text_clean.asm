; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3494  (per function: 613 994 858 824 205)
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
 25b:	sub    rsp,0x10
 25f:	mov    QWORD PTR [rsp],rbx
 263:	mov    QWORD PTR [rsp+0x8],r12
 268:	mov    r12,rsi
 26b:	mov    rax,QWORD PTR [rdi+0x10]
 26f:	mov    rsi,QWORD PTR [rax+0x30]
 273:	mov    edx,0x1
 278:	mov    ecx,0x3
 27d:	mov    rbx,rdi
 280:	mov    r8,r12
 283:	call   288 <botlish_fn_1+0x31>
			284: R_X86_64_PLT32	rt_str_region_eq-0x4
 288:	cmp    rax,0x6
 28c:	je     2cd <botlish_fn_1+0x76>
 292:	mov    rax,QWORD PTR [rbx+0x10]
 296:	mov    rsi,QWORD PTR [rax+0x38]
 29a:	mov    edx,0x1
 29f:	mov    ecx,0x3
 2a4:	mov    rdi,rbx
 2a7:	mov    r8,r12
 2aa:	call   2af <botlish_fn_1+0x58>
			2ab: R_X86_64_PLT32	rt_str_region_eq-0x4
 2af:	cmp    rax,0x6
 2b3:	je     2c3 <botlish_fn_1+0x6c>
 2b9:	mov    ecx,0x2
 2be:	jmp    2d2 <botlish_fn_1+0x7b>
 2c3:	mov    ecx,0x6
 2c8:	jmp    2d2 <botlish_fn_1+0x7b>
 2cd:	mov    ecx,0x6
 2d2:	cmp    rcx,0x6
 2d6:	je     317 <botlish_fn_1+0xc0>
 2dc:	mov    rdx,QWORD PTR [rbx+0x10]
 2e0:	mov    rsi,QWORD PTR [rdx+0x40]
 2e4:	mov    edx,0x1
 2e9:	mov    ecx,0x3
 2ee:	mov    rdi,rbx
 2f1:	mov    r8,r12
 2f4:	call   2f9 <botlish_fn_1+0xa2>
			2f5: R_X86_64_PLT32	rt_str_region_eq-0x4
 2f9:	cmp    rax,0x6
 2fd:	je     30d <botlish_fn_1+0xb6>
 303:	mov    ecx,0x2
 308:	jmp    31c <botlish_fn_1+0xc5>
 30d:	mov    ecx,0x6
 312:	jmp    31c <botlish_fn_1+0xc5>
 317:	mov    ecx,0x6
 31c:	cmp    rcx,0x6
 320:	je     361 <botlish_fn_1+0x10a>
 326:	mov    r10,QWORD PTR [rbx+0x10]
 32a:	mov    rsi,QWORD PTR [r10+0x48]
 32e:	mov    edx,0x1
 333:	mov    ecx,0x3
 338:	mov    rdi,rbx
 33b:	mov    r8,r12
 33e:	call   343 <botlish_fn_1+0xec>
			33f: R_X86_64_PLT32	rt_str_region_eq-0x4
 343:	cmp    rax,0x6
 347:	je     357 <botlish_fn_1+0x100>
 34d:	mov    ecx,0x2
 352:	jmp    366 <botlish_fn_1+0x10f>
 357:	mov    ecx,0x6
 35c:	jmp    366 <botlish_fn_1+0x10f>
 361:	mov    ecx,0x6
 366:	cmp    rcx,0x6
 36a:	je     3ad <botlish_fn_1+0x156>
 370:	mov    rax,QWORD PTR [rbx+0x10]
 374:	mov    rsi,QWORD PTR [rax+0x50]
 378:	mov    edx,0x1
 37d:	mov    ecx,0x3
 382:	mov    rdi,rbx
 385:	mov    r8,r12
 388:	call   38d <botlish_fn_1+0x136>
			389: R_X86_64_PLT32	rt_str_region_eq-0x4
 38d:	cmp    rax,0x6
 391:	je     3a2 <botlish_fn_1+0x14b>
 397:	mov    r10d,0x2
 39d:	jmp    3b3 <botlish_fn_1+0x15c>
 3a2:	mov    r10d,0x6
 3a8:	jmp    3b3 <botlish_fn_1+0x15c>
 3ad:	mov    r10d,0x6
 3b3:	cmp    r10,0x6
 3b7:	je     3f8 <botlish_fn_1+0x1a1>
 3bd:	mov    rax,QWORD PTR [rbx+0x10]
 3c1:	mov    rsi,QWORD PTR [rax+0x58]
 3c5:	mov    edx,0x1
 3ca:	mov    ecx,0x3
 3cf:	mov    rdi,rbx
 3d2:	mov    r8,r12
 3d5:	call   3da <botlish_fn_1+0x183>
			3d6: R_X86_64_PLT32	rt_str_region_eq-0x4
 3da:	cmp    rax,0x6
 3de:	je     3ee <botlish_fn_1+0x197>
 3e4:	mov    ecx,0x2
 3e9:	jmp    3fd <botlish_fn_1+0x1a6>
 3ee:	mov    ecx,0x6
 3f3:	jmp    3fd <botlish_fn_1+0x1a6>
 3f8:	mov    ecx,0x6
 3fd:	cmp    rcx,0x6
 401:	je     442 <botlish_fn_1+0x1eb>
 407:	mov    rax,QWORD PTR [rbx+0x10]
 40b:	mov    rsi,QWORD PTR [rax+0x60]
 40f:	mov    edx,0x1
 414:	mov    ecx,0x3
 419:	mov    rdi,rbx
 41c:	mov    r8,r12
 41f:	call   424 <botlish_fn_1+0x1cd>
			420: R_X86_64_PLT32	rt_str_region_eq-0x4
 424:	cmp    rax,0x6
 428:	je     438 <botlish_fn_1+0x1e1>
 42e:	mov    ecx,0x2
 433:	jmp    447 <botlish_fn_1+0x1f0>
 438:	mov    ecx,0x6
 43d:	jmp    447 <botlish_fn_1+0x1f0>
 442:	mov    ecx,0x6
 447:	cmp    rcx,0x6
 44b:	je     48c <botlish_fn_1+0x235>
 451:	mov    rax,QWORD PTR [rbx+0x10]
 455:	mov    rsi,QWORD PTR [rax+0x68]
 459:	mov    edx,0x1
 45e:	mov    ecx,0x3
 463:	mov    rdi,rbx
 466:	mov    r8,r12
 469:	call   46e <botlish_fn_1+0x217>
			46a: R_X86_64_PLT32	rt_str_region_eq-0x4
 46e:	cmp    rax,0x6
 472:	je     482 <botlish_fn_1+0x22b>
 478:	mov    ecx,0x2
 47d:	jmp    491 <botlish_fn_1+0x23a>
 482:	mov    ecx,0x6
 487:	jmp    491 <botlish_fn_1+0x23a>
 48c:	mov    ecx,0x6
 491:	cmp    rcx,0x6
 495:	je     4d6 <botlish_fn_1+0x27f>
 49b:	mov    rax,QWORD PTR [rbx+0x10]
 49f:	mov    rsi,QWORD PTR [rax+0x70]
 4a3:	mov    edx,0x1
 4a8:	mov    ecx,0x3
 4ad:	mov    rdi,rbx
 4b0:	mov    r8,r12
 4b3:	call   4b8 <botlish_fn_1+0x261>
			4b4: R_X86_64_PLT32	rt_str_region_eq-0x4
 4b8:	cmp    rax,0x6
 4bc:	je     4cc <botlish_fn_1+0x275>
 4c2:	mov    ecx,0x2
 4c7:	jmp    4db <botlish_fn_1+0x284>
 4cc:	mov    ecx,0x6
 4d1:	jmp    4db <botlish_fn_1+0x284>
 4d6:	mov    ecx,0x6
 4db:	cmp    rcx,0x6
 4df:	je     520 <botlish_fn_1+0x2c9>
 4e5:	mov    rax,QWORD PTR [rbx+0x10]
 4e9:	mov    rsi,QWORD PTR [rax+0x78]
 4ed:	mov    edx,0x1
 4f2:	mov    ecx,0x3
 4f7:	mov    rdi,rbx
 4fa:	mov    r8,r12
 4fd:	call   502 <botlish_fn_1+0x2ab>
			4fe: R_X86_64_PLT32	rt_str_region_eq-0x4
 502:	cmp    rax,0x6
 506:	je     516 <botlish_fn_1+0x2bf>
 50c:	mov    ecx,0x2
 511:	jmp    525 <botlish_fn_1+0x2ce>
 516:	mov    ecx,0x6
 51b:	jmp    525 <botlish_fn_1+0x2ce>
 520:	mov    ecx,0x6
 525:	cmp    rcx,0x6
 529:	je     56d <botlish_fn_1+0x316>
 52f:	mov    rsi,QWORD PTR [rbx+0x10]
 533:	mov    rsi,QWORD PTR [rsi+0x80]
 53a:	mov    edx,0x1
 53f:	mov    ecx,0x3
 544:	mov    rdi,rbx
 547:	mov    r8,r12
 54a:	call   54f <botlish_fn_1+0x2f8>
			54b: R_X86_64_PLT32	rt_str_region_eq-0x4
 54f:	cmp    rax,0x6
 553:	je     563 <botlish_fn_1+0x30c>
 559:	mov    ecx,0x2
 55e:	jmp    572 <botlish_fn_1+0x31b>
 563:	mov    ecx,0x6
 568:	jmp    572 <botlish_fn_1+0x31b>
 56d:	mov    ecx,0x6
 572:	cmp    rcx,0x6
 576:	je     5ba <botlish_fn_1+0x363>
 57c:	mov    r11,QWORD PTR [rbx+0x10]
 580:	mov    rsi,QWORD PTR [r11+0x88]
 587:	mov    edx,0x1
 58c:	mov    ecx,0x3
 591:	mov    rdi,rbx
 594:	mov    r8,r12
 597:	call   59c <botlish_fn_1+0x345>
			598: R_X86_64_PLT32	rt_str_region_eq-0x4
 59c:	cmp    rax,0x6
 5a0:	je     5b0 <botlish_fn_1+0x359>
 5a6:	mov    eax,0x2
 5ab:	jmp    5bf <botlish_fn_1+0x368>
 5b0:	mov    eax,0x6
 5b5:	jmp    5bf <botlish_fn_1+0x368>
 5ba:	mov    eax,0x6
 5bf:	mov    rbx,QWORD PTR [rsp]
 5c3:	mov    r12,QWORD PTR [rsp+0x8]
 5c8:	add    rsp,0x10
 5cc:	mov    rsp,rbp
 5cf:	pop    rbp
 5d0:	ret

00000000000005d1 <botlish_entry_1: cleaner_emoji<str>>:
 5d1:	push   rbp
 5d2:	mov    rbp,rsp
 5d5:	mov    rsi,QWORD PTR [rdx]
 5d8:	call   5dd <botlish_entry_1+0xc>
			5d9: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 5dd:	mov    rsp,rbp
 5e0:	pop    rbp
 5e1:	ret

00000000000005e2 <botlish_fn_2: clean_char<str>>:
 5e2:	push   rbp
 5e3:	mov    rbp,rsp
 5e6:	sub    rsp,0x20
 5ea:	mov    QWORD PTR [rsp],r12
 5ee:	mov    QWORD PTR [rsp+0x8],r13
 5f3:	mov    QWORD PTR [rsp+0x10],r14
 5f8:	mov    r12,QWORD PTR [rdi]
 5fb:	mov    r9,QWORD PTR [rdi+0x8]
 5ff:	lea    r10,[r12+0x8]
 604:	cmp    r10,r9
 607:	ja     8d4 <botlish_fn_2+0x2f2>
 60d:	lea    r11,[r12+0x8]
 612:	mov    QWORD PTR [rdi],r11
 615:	mov    r13,rdi
 618:	mov    QWORD PTR [r12],rsi
 61c:	mov    r14,rsi
 61f:	mov    rsi,r14
 622:	mov    rdi,r13
 625:	call   62a <botlish_fn_2+0x48>
			626: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 62a:	test   rax,rax
 62d:	jne    653 <botlish_fn_2+0x71>
 633:	mov    rdi,r13
 636:	mov    QWORD PTR [rdi],r12
 639:	xor    rax,rax
 63c:	mov    r12,QWORD PTR [rsp]
 640:	mov    r13,QWORD PTR [rsp+0x8]
 645:	mov    r14,QWORD PTR [rsp+0x10]
 64a:	add    rsp,0x20
 64e:	mov    rsp,rbp
 651:	pop    rbp
 652:	ret
 653:	cmp    rax,0x6
 657:	je     8ac <botlish_fn_2+0x2ca>
 65d:	mov    rdi,r13
 660:	mov    rax,QWORD PTR [rdi+0x10]
 664:	mov    rsi,QWORD PTR [rax+0x98]
 66b:	mov    edx,0x1
 670:	mov    ecx,0x3
 675:	mov    r8,r14
 678:	call   67d <botlish_fn_2+0x9b>
			679: R_X86_64_PLT32	rt_str_region_eq-0x4
 67d:	cmp    rax,0x6
 681:	je     6c5 <botlish_fn_2+0xe3>
 687:	mov    rdi,r13
 68a:	mov    rax,QWORD PTR [rdi+0x10]
 68e:	mov    rsi,QWORD PTR [rax+0xa0]
 695:	mov    edx,0x1
 69a:	mov    ecx,0x3
 69f:	mov    r8,r14
 6a2:	call   6a7 <botlish_fn_2+0xc5>
			6a3: R_X86_64_PLT32	rt_str_region_eq-0x4
 6a7:	cmp    rax,0x6
 6ab:	je     6bb <botlish_fn_2+0xd9>
 6b1:	mov    ecx,0x2
 6b6:	jmp    6ca <botlish_fn_2+0xe8>
 6bb:	mov    ecx,0x6
 6c0:	jmp    6ca <botlish_fn_2+0xe8>
 6c5:	mov    ecx,0x6
 6ca:	cmp    rcx,0x6
 6ce:	je     884 <botlish_fn_2+0x2a2>
 6d4:	mov    rdi,r13
 6d7:	mov    rax,QWORD PTR [rdi+0x10]
 6db:	mov    rsi,QWORD PTR [rax+0xb0]
 6e2:	mov    edx,0x1
 6e7:	mov    ecx,0x3
 6ec:	mov    r8,r14
 6ef:	call   6f4 <botlish_fn_2+0x112>
			6f0: R_X86_64_PLT32	rt_str_region_eq-0x4
 6f4:	cmp    rax,0x6
 6f8:	je     73c <botlish_fn_2+0x15a>
 6fe:	mov    rdi,r13
 701:	mov    rax,QWORD PTR [rdi+0x10]
 705:	mov    rsi,QWORD PTR [rax+0xb8]
 70c:	mov    edx,0x1
 711:	mov    ecx,0x3
 716:	mov    r8,r14
 719:	call   71e <botlish_fn_2+0x13c>
			71a: R_X86_64_PLT32	rt_str_region_eq-0x4
 71e:	cmp    rax,0x6
 722:	je     732 <botlish_fn_2+0x150>
 728:	mov    ecx,0x2
 72d:	jmp    741 <botlish_fn_2+0x15f>
 732:	mov    ecx,0x6
 737:	jmp    741 <botlish_fn_2+0x15f>
 73c:	mov    ecx,0x6
 741:	cmp    rcx,0x6
 745:	je     85c <botlish_fn_2+0x27a>
 74b:	mov    rdi,r13
 74e:	mov    rax,QWORD PTR [rdi+0x10]
 752:	mov    rsi,QWORD PTR [rax+0xc8]
 759:	mov    edx,0x1
 75e:	mov    ecx,0x3
 763:	mov    r8,r14
 766:	call   76b <botlish_fn_2+0x189>
			767: R_X86_64_PLT32	rt_str_region_eq-0x4
 76b:	cmp    rax,0x6
 76f:	je     7b3 <botlish_fn_2+0x1d1>
 775:	mov    rdi,r13
 778:	mov    rax,QWORD PTR [rdi+0x10]
 77c:	mov    rsi,QWORD PTR [rax+0xd0]
 783:	mov    edx,0x1
 788:	mov    ecx,0x3
 78d:	mov    r8,r14
 790:	call   795 <botlish_fn_2+0x1b3>
			791: R_X86_64_PLT32	rt_str_region_eq-0x4
 795:	cmp    rax,0x6
 799:	je     7a9 <botlish_fn_2+0x1c7>
 79f:	mov    ecx,0x2
 7a4:	jmp    7b8 <botlish_fn_2+0x1d6>
 7a9:	mov    ecx,0x6
 7ae:	jmp    7b8 <botlish_fn_2+0x1d6>
 7b3:	mov    ecx,0x6
 7b8:	cmp    rcx,0x6
 7bc:	je     834 <botlish_fn_2+0x252>
 7c2:	mov    rdi,r13
 7c5:	mov    rax,QWORD PTR [rdi+0x10]
 7c9:	mov    rsi,QWORD PTR [rax+0xe0]
 7d0:	mov    edx,0x1
 7d5:	mov    ecx,0x3
 7da:	mov    r8,r14
 7dd:	call   7e2 <botlish_fn_2+0x200>
			7de: R_X86_64_PLT32	rt_str_region_eq-0x4
 7e2:	cmp    rax,0x6
 7e6:	je     80c <botlish_fn_2+0x22a>
 7ec:	mov    rdi,r13
 7ef:	mov    QWORD PTR [rdi],r12
 7f2:	mov    rax,r14
 7f5:	mov    r12,QWORD PTR [rsp]
 7f9:	mov    r13,QWORD PTR [rsp+0x8]
 7fe:	mov    r14,QWORD PTR [rsp+0x10]
 803:	add    rsp,0x20
 807:	mov    rsp,rbp
 80a:	pop    rbp
 80b:	ret
 80c:	mov    rdi,r13
 80f:	mov    rax,QWORD PTR [rdi+0x10]
 813:	mov    rax,QWORD PTR [rax+0xe8]
 81a:	mov    QWORD PTR [rdi],r12
 81d:	mov    r12,QWORD PTR [rsp]
 821:	mov    r13,QWORD PTR [rsp+0x8]
 826:	mov    r14,QWORD PTR [rsp+0x10]
 82b:	add    rsp,0x20
 82f:	mov    rsp,rbp
 832:	pop    rbp
 833:	ret
 834:	mov    rdi,r13
 837:	mov    rax,QWORD PTR [rdi+0x10]
 83b:	mov    rax,QWORD PTR [rax+0xd8]
 842:	mov    QWORD PTR [rdi],r12
 845:	mov    r12,QWORD PTR [rsp]
 849:	mov    r13,QWORD PTR [rsp+0x8]
 84e:	mov    r14,QWORD PTR [rsp+0x10]
 853:	add    rsp,0x20
 857:	mov    rsp,rbp
 85a:	pop    rbp
 85b:	ret
 85c:	mov    rdi,r13
 85f:	mov    rax,QWORD PTR [rdi+0x10]
 863:	mov    rax,QWORD PTR [rax+0xc0]
 86a:	mov    QWORD PTR [rdi],r12
 86d:	mov    r12,QWORD PTR [rsp]
 871:	mov    r13,QWORD PTR [rsp+0x8]
 876:	mov    r14,QWORD PTR [rsp+0x10]
 87b:	add    rsp,0x20
 87f:	mov    rsp,rbp
 882:	pop    rbp
 883:	ret
 884:	mov    rdi,r13
 887:	mov    rdx,QWORD PTR [rdi+0x10]
 88b:	mov    rax,QWORD PTR [rdx+0xa8]
 892:	mov    QWORD PTR [rdi],r12
 895:	mov    r12,QWORD PTR [rsp]
 899:	mov    r13,QWORD PTR [rsp+0x8]
 89e:	mov    r14,QWORD PTR [rsp+0x10]
 8a3:	add    rsp,0x20
 8a7:	mov    rsp,rbp
 8aa:	pop    rbp
 8ab:	ret
 8ac:	mov    rdi,r13
 8af:	mov    rsi,QWORD PTR [rdi+0x10]
 8b3:	mov    rax,QWORD PTR [rsi+0x90]
 8ba:	mov    QWORD PTR [rdi],r12
 8bd:	mov    r12,QWORD PTR [rsp]
 8c1:	mov    r13,QWORD PTR [rsp+0x8]
 8c6:	mov    r14,QWORD PTR [rsp+0x10]
 8cb:	add    rsp,0x20
 8cf:	mov    rsp,rbp
 8d2:	pop    rbp
 8d3:	ret
 8d4:	mov    r13,rdi
 8d7:	call   8dc <botlish_fn_2+0x2fa>
			8d8: R_X86_64_PLT32	rt_stack_overflow-0x4
 8dc:	xor    rax,rax
 8df:	mov    r12,QWORD PTR [rsp]
 8e3:	mov    r13,QWORD PTR [rsp+0x8]
 8e8:	mov    r14,QWORD PTR [rsp+0x10]
 8ed:	add    rsp,0x20
 8f1:	mov    rsp,rbp
 8f4:	pop    rbp
 8f5:	ret

00000000000008f6 <botlish_entry_2: clean_char<str>>:
 8f6:	push   rbp
 8f7:	mov    rbp,rsp
 8fa:	mov    rsi,QWORD PTR [rdx]
 8fd:	call   902 <botlish_entry_2+0xc>
			8fe: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 902:	mov    rsp,rbp
 905:	pop    rbp
 906:	ret
	...

0000000000000908 <botlish_fn_3: clean_from<str, int, str>>:
 908:	push   rbp
 909:	mov    rbp,rsp
 90c:	sub    rsp,0x40
 910:	mov    QWORD PTR [rsp+0x10],rbx
 915:	mov    QWORD PTR [rsp+0x18],r12
 91a:	mov    QWORD PTR [rsp+0x20],r13
 91f:	mov    QWORD PTR [rsp+0x28],r14
 924:	mov    QWORD PTR [rsp+0x30],r15
 929:	mov    rbx,QWORD PTR [rdi]
 92c:	mov    rax,QWORD PTR [rdi+0x8]
 930:	lea    r9,[rbx+0x30]
 934:	cmp    r9,rax
 937:	ja     bad <botlish_fn_3+0x2a5>
 93d:	lea    rax,[rbx+0x30]
 941:	mov    QWORD PTR [rdi],rax
 944:	mov    r14,rdi
 947:	mov    QWORD PTR [rbx+0x20],0x0
 94f:	mov    QWORD PTR [rbx+0x28],0x0
 957:	mov    QWORD PTR [rbx],rsi
 95a:	mov    QWORD PTR [rbx+0x8],rcx
 95e:	mov    QWORD PTR [rbx+0x10],r8
 962:	mov    r12,rsi
 965:	mov    r15,r8
 968:	mov    QWORD PTR [rsp],rdx
 96c:	mov    QWORD PTR [rsp+0x8],rcx
 971:	mov    rsi,r12
 974:	mov    rdi,r14
 977:	call   97c <botlish_fn_3+0x74>
			978: R_X86_64_PLT32	rt_str_len-0x4
 97c:	mov    rsi,QWORD PTR [rsp]
 980:	mov    rcx,rsi
 983:	and    rcx,rax
 986:	mov    rdx,rax
 989:	test   rcx,0x1
 990:	jne    9b7 <botlish_fn_3+0xaf>
 996:	mov    rsi,QWORD PTR [rsp]
 99a:	mov    rdi,r14
 99d:	call   9a2 <botlish_fn_3+0x9a>
			99e: R_X86_64_PLT32	rt_int_cmp-0x4
 9a2:	mov    ecx,0x2
 9a7:	test   rax,rax
 9aa:	cmovge rcx,QWORD PTR [rip+0x22e]        # be0 <botlish_fn_3+0x2d8>
 9b2:	jmp    9cb <botlish_fn_3+0xc3>
 9b7:	mov    ecx,0x2
 9bc:	mov    rsi,QWORD PTR [rsp]
 9c0:	cmp    rsi,rdx
 9c3:	cmovge rcx,QWORD PTR [rip+0x215]        # be0 <botlish_fn_3+0x2d8>
 9cb:	cmp    rcx,0x6
 9cf:	je     b80 <botlish_fn_3+0x278>
 9d5:	mov    rsi,QWORD PTR [rsp]
 9d9:	sar    rsi,1
 9dc:	lea    r13,[rsi+0x1]
 9e0:	shl    r13,1
 9e3:	or     r13,0x1
 9e7:	mov    QWORD PTR [rbx+0x18],r13
 9eb:	mov    rsi,r12
 9ee:	mov    rdi,r14
 9f1:	call   9f6 <botlish_fn_3+0xee>
			9f2: R_X86_64_PLT32	rt_str_len-0x4
 9f6:	mov    rsi,QWORD PTR [rsp]
 9fa:	mov    rdi,rsi
 9fd:	and    rdi,rax
 a00:	mov    rdx,rax
 a03:	test   rdi,0x1
 a0a:	jne    a31 <botlish_fn_3+0x129>
 a10:	mov    rsi,QWORD PTR [rsp]
 a14:	mov    rdi,r14
 a17:	call   a1c <botlish_fn_3+0x114>
			a18: R_X86_64_PLT32	rt_int_cmp-0x4
 a1c:	mov    ecx,0x2
 a21:	test   rax,rax
 a24:	cmovge rcx,QWORD PTR [rip+0x1b4]        # be0 <botlish_fn_3+0x2d8>
 a2c:	jmp    a45 <botlish_fn_3+0x13d>
 a31:	mov    ecx,0x2
 a36:	mov    rsi,QWORD PTR [rsp]
 a3a:	cmp    rsi,rdx
 a3d:	cmovge rcx,QWORD PTR [rip+0x19b]        # be0 <botlish_fn_3+0x2d8>
 a45:	cmp    rcx,0x6
 a49:	je     ae7 <botlish_fn_3+0x1df>
 a4f:	mov    rdx,r15
 a52:	mov    rsi,r12
 a55:	mov    rdi,r14
 a58:	call   a5d <botlish_fn_3+0x155>
			a59: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 a5d:	mov    QWORD PTR [rbx+0x20],rax
 a61:	mov    QWORD PTR [rsp],rax
 a65:	mov    rsi,QWORD PTR [rsp]
 a69:	mov    rdi,r14
 a6c:	call   a71 <botlish_fn_3+0x169>
			a6d: R_X86_64_PLT32	rt_str_byte_len-0x4
 a71:	mov    QWORD PTR [rbx+0x28],rax
 a75:	mov    rsi,r15
 a78:	mov    rcx,rsi
 a7b:	and    rcx,rax
 a7e:	test   rcx,0x1
 a85:	jne    a96 <botlish_fn_3+0x18e>
 a8b:	mov    rdx,rax
 a8e:	mov    rsi,r15
 a91:	jmp    ac5 <botlish_fn_3+0x1bd>
 a96:	lea    rcx,[rax-0x1]
 a9a:	mov    rdx,rax
 a9d:	mov    rsi,r15
 aa0:	mov    rax,rsi
 aa3:	add    rax,rcx
 aa6:	seto   cl
 aa9:	test   cl,cl
 aab:	je     ab9 <botlish_fn_3+0x1b1>
 ab1:	mov    rsi,r15
 ab4:	jmp    ac5 <botlish_fn_3+0x1bd>
 ab9:	mov    r15,rax
 abc:	mov    rax,QWORD PTR [rsp]
 ac0:	jmp    ad4 <botlish_fn_3+0x1cc>
 ac5:	mov    rdi,r14
 ac8:	call   acd <botlish_fn_3+0x1c5>
			ac9: R_X86_64_PLT32	rt_int_add-0x4
 acd:	mov    r15,rax
 ad0:	mov    rax,QWORD PTR [rsp]
 ad4:	mov    QWORD PTR [rbx+0x10],rax
 ad8:	mov    rsi,r15
 adb:	mov    QWORD PTR [rbx+0x20],rsi
 adf:	mov    rsi,rax
 ae2:	jmp    b00 <botlish_fn_3+0x1f8>
 ae7:	mov    rdi,r14
 aea:	mov    rax,QWORD PTR [rdi+0x10]
 aee:	mov    rsi,QWORD PTR [rax+0x90]
 af5:	mov    QWORD PTR [rbx+0x10],rsi
 af9:	mov    rax,r15
 afc:	mov    QWORD PTR [rbx+0x20],rax
 b00:	mov    rdi,r14
 b03:	call   b08 <botlish_fn_3+0x200>
			b04: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 b08:	test   rax,rax
 b0b:	jne    b19 <botlish_fn_3+0x211>
 b11:	mov    rdi,r14
 b14:	jmp    b39 <botlish_fn_3+0x231>
 b19:	mov    QWORD PTR [rbx+0x10],rax
 b1d:	mov    rdx,rax
 b20:	mov    rsi,QWORD PTR [rsp+0x8]
 b25:	mov    rdi,r14
 b28:	call   b2d <botlish_fn_3+0x225>
			b29: R_X86_64_PLT32	rt_str_cat-0x4
 b2d:	test   rax,rax
 b30:	jne    b64 <botlish_fn_3+0x25c>
 b36:	mov    rdi,r14
 b39:	mov    rdi,r14
 b3c:	mov    QWORD PTR [rdi],rbx
 b3f:	xor    rax,rax
 b42:	mov    rbx,QWORD PTR [rsp+0x10]
 b47:	mov    r12,QWORD PTR [rsp+0x18]
 b4c:	mov    r13,QWORD PTR [rsp+0x20]
 b51:	mov    r14,QWORD PTR [rsp+0x28]
 b56:	mov    r15,QWORD PTR [rsp+0x30]
 b5b:	add    rsp,0x40
 b5f:	mov    rsp,rbp
 b62:	pop    rbp
 b63:	ret
 b64:	mov    QWORD PTR [rbx],r12
 b67:	mov    QWORD PTR [rbx+0x8],rax
 b6b:	mov    rsi,r15
 b6e:	mov    QWORD PTR [rbx+0x10],rsi
 b72:	mov    QWORD PTR [rsp],r13
 b76:	mov    QWORD PTR [rsp+0x8],rax
 b7b:	jmp    971 <botlish_fn_3+0x69>
 b80:	mov    rdi,r14
 b83:	mov    QWORD PTR [rdi],rbx
 b86:	mov    rax,QWORD PTR [rsp+0x8]
 b8b:	mov    rbx,QWORD PTR [rsp+0x10]
 b90:	mov    r12,QWORD PTR [rsp+0x18]
 b95:	mov    r13,QWORD PTR [rsp+0x20]
 b9a:	mov    r14,QWORD PTR [rsp+0x28]
 b9f:	mov    r15,QWORD PTR [rsp+0x30]
 ba4:	add    rsp,0x40
 ba8:	mov    rsp,rbp
 bab:	pop    rbp
 bac:	ret
 bad:	mov    r14,rdi
 bb0:	call   bb5 <botlish_fn_3+0x2ad>
			bb1: R_X86_64_PLT32	rt_stack_overflow-0x4
 bb5:	xor    rax,rax
 bb8:	mov    rbx,QWORD PTR [rsp+0x10]
 bbd:	mov    r12,QWORD PTR [rsp+0x18]
 bc2:	mov    r13,QWORD PTR [rsp+0x20]
 bc7:	mov    r14,QWORD PTR [rsp+0x28]
 bcc:	mov    r15,QWORD PTR [rsp+0x30]
 bd1:	add    rsp,0x40
 bd5:	mov    rsp,rbp
 bd8:	pop    rbp
 bd9:	ret
 bda:	add    BYTE PTR [rax],al
 bdc:	add    BYTE PTR [rax],al
 bde:	add    BYTE PTR [rax],al
 be0:	(bad)
 be1:	add    BYTE PTR [rax],al
 be3:	add    BYTE PTR [rax],al
 be5:	add    BYTE PTR [rax],al
	...

0000000000000be8 <botlish_entry_3: clean_from<str, int, str>>:
 be8:	push   rbp
 be9:	mov    rbp,rsp
 bec:	mov    rsi,QWORD PTR [rdx]
 bef:	mov    r9,QWORD PTR [rdx+0x8]
 bf3:	mov    rcx,QWORD PTR [rdx+0x10]
 bf7:	mov    r8,QWORD PTR [rdx+0x18]
 bfb:	mov    rdx,r9
 bfe:	call   c03 <botlish_entry_3+0x1b>
			bff: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 c03:	mov    rsp,rbp
 c06:	pop    rbp
 c07:	ret

0000000000000c08 <botlish_fn_4: clean_ai_text<str>>:
 c08:	push   rbp
 c09:	mov    rbp,rsp
 c0c:	sub    rsp,0x10
 c10:	mov    QWORD PTR [rsp],rbx
 c14:	mov    QWORD PTR [rsp+0x8],r15
 c19:	mov    r15,QWORD PTR [rdi]
 c1c:	mov    rax,QWORD PTR [rdi+0x8]
 c20:	lea    rcx,[r15+0x20]
 c24:	cmp    rcx,rax
 c27:	ja     ca3 <botlish_fn_4+0x9b>
 c2d:	lea    rax,[r15+0x20]
 c31:	mov    QWORD PTR [rdi],rax
 c34:	mov    QWORD PTR [r15],rsi
 c37:	mov    r8d,0x1
 c3d:	mov    QWORD PTR [r15+0x8],0x1
 c45:	mov    rax,QWORD PTR [rdi+0x10]
 c49:	mov    rbx,rdi
 c4c:	mov    rcx,QWORD PTR [rax+0x90]
 c53:	mov    QWORD PTR [r15+0x10],rcx
 c57:	mov    QWORD PTR [r15+0x18],0x1
 c5f:	mov    rdx,r8
 c62:	call   c67 <botlish_fn_4+0x5f>
			c63: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 c67:	test   rax,rax
 c6a:	jne    c8b <botlish_fn_4+0x83>
 c70:	mov    rdi,rbx
 c73:	mov    QWORD PTR [rdi],r15
 c76:	xor    rax,rax
 c79:	mov    rbx,QWORD PTR [rsp]
 c7d:	mov    r15,QWORD PTR [rsp+0x8]
 c82:	add    rsp,0x10
 c86:	mov    rsp,rbp
 c89:	pop    rbp
 c8a:	ret
 c8b:	mov    rdi,rbx
 c8e:	mov    QWORD PTR [rdi],r15
 c91:	mov    rbx,QWORD PTR [rsp]
 c95:	mov    r15,QWORD PTR [rsp+0x8]
 c9a:	add    rsp,0x10
 c9e:	mov    rsp,rbp
 ca1:	pop    rbp
 ca2:	ret
 ca3:	call   ca8 <botlish_fn_4+0xa0>
			ca4: R_X86_64_PLT32	rt_stack_overflow-0x4
 ca8:	xor    rax,rax
 cab:	mov    rbx,QWORD PTR [rsp]
 caf:	mov    r15,QWORD PTR [rsp+0x8]
 cb4:	add    rsp,0x10
 cb8:	mov    rsp,rbp
 cbb:	pop    rbp
 cbc:	ret

0000000000000cbd <botlish_entry_4: clean_ai_text<str>>:
 cbd:	push   rbp
 cbe:	mov    rbp,rsp
 cc1:	mov    rsi,QWORD PTR [rdx]
 cc4:	call   cc9 <botlish_entry_4+0xc>
			cc5: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 cc9:	mov    rsp,rbp
 ccc:	pop    rbp
 ccd:	ret

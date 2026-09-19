; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3625  (per function: 669 994 878 864 220)
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
  2d:	mov    rbx,QWORD PTR [rdi]
  30:	mov    rax,QWORD PTR [rdi+0x8]
  34:	lea    rcx,[rbx+0x8]
  38:	cmp    rcx,rax
  3b:	ja     248 <botlish_fn_0+0x248>
  41:	lea    rax,[rbx+0x8]
  45:	mov    QWORD PTR [rdi],rax
  48:	mov    QWORD PTR [rbx],0x0
  4f:	mov    QWORD PTR [rsp+0x8],0x0
  58:	mov    QWORD PTR [rsp+0x10],0x0
  61:	mov    QWORD PTR [rsp+0x18],0x0
  6a:	mov    QWORD PTR [rsp+0x20],0x0
  73:	mov    QWORD PTR [rsp+0x28],0x0
  7c:	mov    rax,QWORD PTR [rdi+0x10]
  80:	mov    r12,rdi
  83:	mov    rsi,QWORD PTR [rax]
  86:	mov    QWORD PTR [rsp],rsi
  8a:	call   8f <botlish_fn_0+0x8f>
			8b: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  8f:	test   rax,rax
  92:	jne    a0 <botlish_fn_0+0xa0>
  98:	mov    rdi,r12
  9b:	jmp    1dd <botlish_fn_0+0x1dd>
  a0:	mov    QWORD PTR [rsp],rax
  a4:	mov    rdi,r12
  a7:	mov    r13,rax
  aa:	mov    rax,QWORD PTR [rdi+0x10]
  ae:	mov    rsi,QWORD PTR [rax+0x8]
  b2:	mov    QWORD PTR [rsp+0x8],rsi
  b7:	call   bc <botlish_fn_0+0xbc>
			b8: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  bc:	test   rax,rax
  bf:	jne    cd <botlish_fn_0+0xcd>
  c5:	mov    rdi,r12
  c8:	jmp    1dd <botlish_fn_0+0x1dd>
  cd:	mov    QWORD PTR [rsp+0x8],rax
  d2:	mov    rdi,r12
  d5:	mov    r14,rax
  d8:	mov    rax,QWORD PTR [rdi+0x10]
  dc:	mov    rsi,QWORD PTR [rax+0x10]
  e0:	mov    QWORD PTR [rsp+0x10],rsi
  e5:	call   ea <botlish_fn_0+0xea>
			e6: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
  ea:	test   rax,rax
  ed:	jne    fb <botlish_fn_0+0xfb>
  f3:	mov    rdi,r12
  f6:	jmp    1dd <botlish_fn_0+0x1dd>
  fb:	mov    QWORD PTR [rsp+0x10],rax
 100:	mov    rdi,r12
 103:	mov    r15,rax
 106:	mov    rax,QWORD PTR [rdi+0x10]
 10a:	mov    rsi,QWORD PTR [rax+0x18]
 10e:	mov    QWORD PTR [rsp+0x18],rsi
 113:	call   118 <botlish_fn_0+0x118>
			114: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 118:	test   rax,rax
 11b:	jne    129 <botlish_fn_0+0x129>
 121:	mov    rdi,r12
 124:	jmp    1dd <botlish_fn_0+0x1dd>
 129:	mov    QWORD PTR [rsp+0x18],rax
 12e:	mov    rdi,r12
 131:	mov    QWORD PTR [rsp+0x68],rax
 136:	mov    rax,QWORD PTR [rdi+0x10]
 13a:	mov    rsi,QWORD PTR [rax+0x20]
 13e:	mov    QWORD PTR [rsp+0x20],rsi
 143:	call   148 <botlish_fn_0+0x148>
			144: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 148:	test   rax,rax
 14b:	jne    159 <botlish_fn_0+0x159>
 151:	mov    rdi,r12
 154:	jmp    1dd <botlish_fn_0+0x1dd>
 159:	mov    QWORD PTR [rsp+0x20],rax
 15e:	mov    rdi,r12
 161:	mov    QWORD PTR [rsp+0x60],rax
 166:	mov    rsi,QWORD PTR [rdi+0x10]
 16a:	mov    rsi,QWORD PTR [rsi+0x28]
 16e:	mov    QWORD PTR [rsp+0x28],rsi
 173:	call   178 <botlish_fn_0+0x178>
			174: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 178:	test   rax,rax
 17b:	jne    189 <botlish_fn_0+0x189>
 181:	mov    rdi,r12
 184:	jmp    1dd <botlish_fn_0+0x1dd>
 189:	mov    QWORD PTR [rsp+0x28],rax
 18e:	lea    rdx,[rsp+0x30]
 193:	mov    rcx,r13
 196:	mov    QWORD PTR [rsp+0x30],rcx
 19b:	mov    rcx,r14
 19e:	mov    QWORD PTR [rsp+0x38],rcx
 1a3:	mov    rcx,r15
 1a6:	mov    QWORD PTR [rsp+0x40],rcx
 1ab:	mov    rcx,QWORD PTR [rsp+0x68]
 1b0:	mov    QWORD PTR [rsp+0x48],rcx
 1b5:	mov    rcx,QWORD PTR [rsp+0x60]
 1ba:	mov    QWORD PTR [rsp+0x50],rcx
 1bf:	mov    QWORD PTR [rsp+0x58],rax
 1c4:	mov    esi,0x6
 1c9:	mov    rdi,r12
 1cc:	call   1d1 <botlish_fn_0+0x1d1>
			1cd: R_X86_64_PLT32	rt_list_new-0x4
 1d1:	test   rax,rax
 1d4:	jne    214 <botlish_fn_0+0x214>
 1da:	mov    rdi,r12
 1dd:	mov    rdi,r12
 1e0:	mov    QWORD PTR [rdi],rbx
 1e3:	xor    rax,rax
 1e6:	mov    rbx,QWORD PTR [rsp+0x70]
 1eb:	mov    r12,QWORD PTR [rsp+0x78]
 1f0:	mov    r13,QWORD PTR [rsp+0x80]
 1f8:	mov    r14,QWORD PTR [rsp+0x88]
 200:	mov    r15,QWORD PTR [rsp+0x90]
 208:	add    rsp,0xa0
 20f:	mov    rsp,rbp
 212:	pop    rbp
 213:	ret
 214:	mov    rdi,r12
 217:	mov    QWORD PTR [rdi],rbx
 21a:	mov    rbx,QWORD PTR [rsp+0x70]
 21f:	mov    r12,QWORD PTR [rsp+0x78]
 224:	mov    r13,QWORD PTR [rsp+0x80]
 22c:	mov    r14,QWORD PTR [rsp+0x88]
 234:	mov    r15,QWORD PTR [rsp+0x90]
 23c:	add    rsp,0xa0
 243:	mov    rsp,rbp
 246:	pop    rbp
 247:	ret
 248:	mov    r12,rdi
 24b:	call   250 <botlish_fn_0+0x250>
			24c: R_X86_64_PLT32	rt_stack_overflow-0x4
 250:	xor    rax,rax
 253:	mov    rbx,QWORD PTR [rsp+0x70]
 258:	mov    r12,QWORD PTR [rsp+0x78]
 25d:	mov    r13,QWORD PTR [rsp+0x80]
 265:	mov    r14,QWORD PTR [rsp+0x88]
 26d:	mov    r15,QWORD PTR [rsp+0x90]
 275:	add    rsp,0xa0
 27c:	mov    rsp,rbp
 27f:	pop    rbp
 280:	ret

0000000000000281 <botlish_entry_0: <program entry>>:
 281:	push   rbp
 282:	mov    rbp,rsp
 285:	call   28a <botlish_entry_0+0x9>
			286: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 28a:	mov    rsp,rbp
 28d:	pop    rbp
 28e:	ret

000000000000028f <botlish_fn_1: cleaner_emoji<str>>:
 28f:	push   rbp
 290:	mov    rbp,rsp
 293:	sub    rsp,0x10
 297:	mov    QWORD PTR [rsp],rbx
 29b:	mov    QWORD PTR [rsp+0x8],r12
 2a0:	mov    r12,rsi
 2a3:	mov    rax,QWORD PTR [rdi+0x10]
 2a7:	mov    rsi,QWORD PTR [rax+0x30]
 2ab:	mov    edx,0x1
 2b0:	mov    ecx,0x3
 2b5:	mov    rbx,rdi
 2b8:	mov    r8,r12
 2bb:	call   2c0 <botlish_fn_1+0x31>
			2bc: R_X86_64_PLT32	rt_str_region_eq-0x4
 2c0:	cmp    rax,0x6
 2c4:	je     305 <botlish_fn_1+0x76>
 2ca:	mov    rax,QWORD PTR [rbx+0x10]
 2ce:	mov    rsi,QWORD PTR [rax+0x38]
 2d2:	mov    edx,0x1
 2d7:	mov    ecx,0x3
 2dc:	mov    rdi,rbx
 2df:	mov    r8,r12
 2e2:	call   2e7 <botlish_fn_1+0x58>
			2e3: R_X86_64_PLT32	rt_str_region_eq-0x4
 2e7:	cmp    rax,0x6
 2eb:	je     2fb <botlish_fn_1+0x6c>
 2f1:	mov    ecx,0x2
 2f6:	jmp    30a <botlish_fn_1+0x7b>
 2fb:	mov    ecx,0x6
 300:	jmp    30a <botlish_fn_1+0x7b>
 305:	mov    ecx,0x6
 30a:	cmp    rcx,0x6
 30e:	je     34f <botlish_fn_1+0xc0>
 314:	mov    rdx,QWORD PTR [rbx+0x10]
 318:	mov    rsi,QWORD PTR [rdx+0x40]
 31c:	mov    edx,0x1
 321:	mov    ecx,0x3
 326:	mov    rdi,rbx
 329:	mov    r8,r12
 32c:	call   331 <botlish_fn_1+0xa2>
			32d: R_X86_64_PLT32	rt_str_region_eq-0x4
 331:	cmp    rax,0x6
 335:	je     345 <botlish_fn_1+0xb6>
 33b:	mov    ecx,0x2
 340:	jmp    354 <botlish_fn_1+0xc5>
 345:	mov    ecx,0x6
 34a:	jmp    354 <botlish_fn_1+0xc5>
 34f:	mov    ecx,0x6
 354:	cmp    rcx,0x6
 358:	je     399 <botlish_fn_1+0x10a>
 35e:	mov    r10,QWORD PTR [rbx+0x10]
 362:	mov    rsi,QWORD PTR [r10+0x48]
 366:	mov    edx,0x1
 36b:	mov    ecx,0x3
 370:	mov    rdi,rbx
 373:	mov    r8,r12
 376:	call   37b <botlish_fn_1+0xec>
			377: R_X86_64_PLT32	rt_str_region_eq-0x4
 37b:	cmp    rax,0x6
 37f:	je     38f <botlish_fn_1+0x100>
 385:	mov    ecx,0x2
 38a:	jmp    39e <botlish_fn_1+0x10f>
 38f:	mov    ecx,0x6
 394:	jmp    39e <botlish_fn_1+0x10f>
 399:	mov    ecx,0x6
 39e:	cmp    rcx,0x6
 3a2:	je     3e5 <botlish_fn_1+0x156>
 3a8:	mov    rax,QWORD PTR [rbx+0x10]
 3ac:	mov    rsi,QWORD PTR [rax+0x50]
 3b0:	mov    edx,0x1
 3b5:	mov    ecx,0x3
 3ba:	mov    rdi,rbx
 3bd:	mov    r8,r12
 3c0:	call   3c5 <botlish_fn_1+0x136>
			3c1: R_X86_64_PLT32	rt_str_region_eq-0x4
 3c5:	cmp    rax,0x6
 3c9:	je     3da <botlish_fn_1+0x14b>
 3cf:	mov    r10d,0x2
 3d5:	jmp    3eb <botlish_fn_1+0x15c>
 3da:	mov    r10d,0x6
 3e0:	jmp    3eb <botlish_fn_1+0x15c>
 3e5:	mov    r10d,0x6
 3eb:	cmp    r10,0x6
 3ef:	je     430 <botlish_fn_1+0x1a1>
 3f5:	mov    rax,QWORD PTR [rbx+0x10]
 3f9:	mov    rsi,QWORD PTR [rax+0x58]
 3fd:	mov    edx,0x1
 402:	mov    ecx,0x3
 407:	mov    rdi,rbx
 40a:	mov    r8,r12
 40d:	call   412 <botlish_fn_1+0x183>
			40e: R_X86_64_PLT32	rt_str_region_eq-0x4
 412:	cmp    rax,0x6
 416:	je     426 <botlish_fn_1+0x197>
 41c:	mov    ecx,0x2
 421:	jmp    435 <botlish_fn_1+0x1a6>
 426:	mov    ecx,0x6
 42b:	jmp    435 <botlish_fn_1+0x1a6>
 430:	mov    ecx,0x6
 435:	cmp    rcx,0x6
 439:	je     47a <botlish_fn_1+0x1eb>
 43f:	mov    rax,QWORD PTR [rbx+0x10]
 443:	mov    rsi,QWORD PTR [rax+0x60]
 447:	mov    edx,0x1
 44c:	mov    ecx,0x3
 451:	mov    rdi,rbx
 454:	mov    r8,r12
 457:	call   45c <botlish_fn_1+0x1cd>
			458: R_X86_64_PLT32	rt_str_region_eq-0x4
 45c:	cmp    rax,0x6
 460:	je     470 <botlish_fn_1+0x1e1>
 466:	mov    ecx,0x2
 46b:	jmp    47f <botlish_fn_1+0x1f0>
 470:	mov    ecx,0x6
 475:	jmp    47f <botlish_fn_1+0x1f0>
 47a:	mov    ecx,0x6
 47f:	cmp    rcx,0x6
 483:	je     4c4 <botlish_fn_1+0x235>
 489:	mov    rax,QWORD PTR [rbx+0x10]
 48d:	mov    rsi,QWORD PTR [rax+0x68]
 491:	mov    edx,0x1
 496:	mov    ecx,0x3
 49b:	mov    rdi,rbx
 49e:	mov    r8,r12
 4a1:	call   4a6 <botlish_fn_1+0x217>
			4a2: R_X86_64_PLT32	rt_str_region_eq-0x4
 4a6:	cmp    rax,0x6
 4aa:	je     4ba <botlish_fn_1+0x22b>
 4b0:	mov    ecx,0x2
 4b5:	jmp    4c9 <botlish_fn_1+0x23a>
 4ba:	mov    ecx,0x6
 4bf:	jmp    4c9 <botlish_fn_1+0x23a>
 4c4:	mov    ecx,0x6
 4c9:	cmp    rcx,0x6
 4cd:	je     50e <botlish_fn_1+0x27f>
 4d3:	mov    rax,QWORD PTR [rbx+0x10]
 4d7:	mov    rsi,QWORD PTR [rax+0x70]
 4db:	mov    edx,0x1
 4e0:	mov    ecx,0x3
 4e5:	mov    rdi,rbx
 4e8:	mov    r8,r12
 4eb:	call   4f0 <botlish_fn_1+0x261>
			4ec: R_X86_64_PLT32	rt_str_region_eq-0x4
 4f0:	cmp    rax,0x6
 4f4:	je     504 <botlish_fn_1+0x275>
 4fa:	mov    ecx,0x2
 4ff:	jmp    513 <botlish_fn_1+0x284>
 504:	mov    ecx,0x6
 509:	jmp    513 <botlish_fn_1+0x284>
 50e:	mov    ecx,0x6
 513:	cmp    rcx,0x6
 517:	je     558 <botlish_fn_1+0x2c9>
 51d:	mov    rax,QWORD PTR [rbx+0x10]
 521:	mov    rsi,QWORD PTR [rax+0x78]
 525:	mov    edx,0x1
 52a:	mov    ecx,0x3
 52f:	mov    rdi,rbx
 532:	mov    r8,r12
 535:	call   53a <botlish_fn_1+0x2ab>
			536: R_X86_64_PLT32	rt_str_region_eq-0x4
 53a:	cmp    rax,0x6
 53e:	je     54e <botlish_fn_1+0x2bf>
 544:	mov    ecx,0x2
 549:	jmp    55d <botlish_fn_1+0x2ce>
 54e:	mov    ecx,0x6
 553:	jmp    55d <botlish_fn_1+0x2ce>
 558:	mov    ecx,0x6
 55d:	cmp    rcx,0x6
 561:	je     5a5 <botlish_fn_1+0x316>
 567:	mov    rsi,QWORD PTR [rbx+0x10]
 56b:	mov    rsi,QWORD PTR [rsi+0x80]
 572:	mov    edx,0x1
 577:	mov    ecx,0x3
 57c:	mov    rdi,rbx
 57f:	mov    r8,r12
 582:	call   587 <botlish_fn_1+0x2f8>
			583: R_X86_64_PLT32	rt_str_region_eq-0x4
 587:	cmp    rax,0x6
 58b:	je     59b <botlish_fn_1+0x30c>
 591:	mov    ecx,0x2
 596:	jmp    5aa <botlish_fn_1+0x31b>
 59b:	mov    ecx,0x6
 5a0:	jmp    5aa <botlish_fn_1+0x31b>
 5a5:	mov    ecx,0x6
 5aa:	cmp    rcx,0x6
 5ae:	je     5f2 <botlish_fn_1+0x363>
 5b4:	mov    r11,QWORD PTR [rbx+0x10]
 5b8:	mov    rsi,QWORD PTR [r11+0x88]
 5bf:	mov    edx,0x1
 5c4:	mov    ecx,0x3
 5c9:	mov    rdi,rbx
 5cc:	mov    r8,r12
 5cf:	call   5d4 <botlish_fn_1+0x345>
			5d0: R_X86_64_PLT32	rt_str_region_eq-0x4
 5d4:	cmp    rax,0x6
 5d8:	je     5e8 <botlish_fn_1+0x359>
 5de:	mov    eax,0x2
 5e3:	jmp    5f7 <botlish_fn_1+0x368>
 5e8:	mov    eax,0x6
 5ed:	jmp    5f7 <botlish_fn_1+0x368>
 5f2:	mov    eax,0x6
 5f7:	mov    rbx,QWORD PTR [rsp]
 5fb:	mov    r12,QWORD PTR [rsp+0x8]
 600:	add    rsp,0x10
 604:	mov    rsp,rbp
 607:	pop    rbp
 608:	ret

0000000000000609 <botlish_entry_1: cleaner_emoji<str>>:
 609:	push   rbp
 60a:	mov    rbp,rsp
 60d:	mov    rsi,QWORD PTR [rdx]
 610:	call   615 <botlish_entry_1+0xc>
			611: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 615:	mov    rsp,rbp
 618:	pop    rbp
 619:	ret

000000000000061a <botlish_fn_2: clean_char<str>>:
 61a:	push   rbp
 61b:	mov    rbp,rsp
 61e:	sub    rsp,0x30
 622:	mov    QWORD PTR [rsp+0x10],r12
 627:	mov    QWORD PTR [rsp+0x18],r13
 62c:	mov    QWORD PTR [rsp+0x20],r14
 631:	mov    r12,QWORD PTR [rdi]
 634:	mov    r9,QWORD PTR [rdi+0x8]
 638:	lea    r10,[r12+0x8]
 63d:	cmp    r10,r9
 640:	ja     91c <botlish_fn_2+0x302>
 646:	lea    r11,[r12+0x8]
 64b:	mov    QWORD PTR [rdi],r11
 64e:	mov    r13,rdi
 651:	mov    QWORD PTR [r12],0x0
 659:	mov    QWORD PTR [rsp],rsi
 65d:	mov    r14,rsi
 660:	mov    rsi,r14
 663:	mov    rdi,r13
 666:	call   66b <botlish_fn_2+0x51>
			667: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<str>
 66b:	test   rax,rax
 66e:	jne    695 <botlish_fn_2+0x7b>
 674:	mov    rdi,r13
 677:	mov    QWORD PTR [rdi],r12
 67a:	xor    rax,rax
 67d:	mov    r12,QWORD PTR [rsp+0x10]
 682:	mov    r13,QWORD PTR [rsp+0x18]
 687:	mov    r14,QWORD PTR [rsp+0x20]
 68c:	add    rsp,0x30
 690:	mov    rsp,rbp
 693:	pop    rbp
 694:	ret
 695:	cmp    rax,0x6
 699:	je     8f3 <botlish_fn_2+0x2d9>
 69f:	mov    rdi,r13
 6a2:	mov    rax,QWORD PTR [rdi+0x10]
 6a6:	mov    rsi,QWORD PTR [rax+0x98]
 6ad:	mov    edx,0x1
 6b2:	mov    ecx,0x3
 6b7:	mov    r8,r14
 6ba:	call   6bf <botlish_fn_2+0xa5>
			6bb: R_X86_64_PLT32	rt_str_region_eq-0x4
 6bf:	cmp    rax,0x6
 6c3:	je     707 <botlish_fn_2+0xed>
 6c9:	mov    rdi,r13
 6cc:	mov    rax,QWORD PTR [rdi+0x10]
 6d0:	mov    rsi,QWORD PTR [rax+0xa0]
 6d7:	mov    edx,0x1
 6dc:	mov    ecx,0x3
 6e1:	mov    r8,r14
 6e4:	call   6e9 <botlish_fn_2+0xcf>
			6e5: R_X86_64_PLT32	rt_str_region_eq-0x4
 6e9:	cmp    rax,0x6
 6ed:	je     6fd <botlish_fn_2+0xe3>
 6f3:	mov    ecx,0x2
 6f8:	jmp    70c <botlish_fn_2+0xf2>
 6fd:	mov    ecx,0x6
 702:	jmp    70c <botlish_fn_2+0xf2>
 707:	mov    ecx,0x6
 70c:	cmp    rcx,0x6
 710:	je     8ca <botlish_fn_2+0x2b0>
 716:	mov    rdi,r13
 719:	mov    rax,QWORD PTR [rdi+0x10]
 71d:	mov    rsi,QWORD PTR [rax+0xb0]
 724:	mov    edx,0x1
 729:	mov    ecx,0x3
 72e:	mov    r8,r14
 731:	call   736 <botlish_fn_2+0x11c>
			732: R_X86_64_PLT32	rt_str_region_eq-0x4
 736:	cmp    rax,0x6
 73a:	je     77e <botlish_fn_2+0x164>
 740:	mov    rdi,r13
 743:	mov    rax,QWORD PTR [rdi+0x10]
 747:	mov    rsi,QWORD PTR [rax+0xb8]
 74e:	mov    edx,0x1
 753:	mov    ecx,0x3
 758:	mov    r8,r14
 75b:	call   760 <botlish_fn_2+0x146>
			75c: R_X86_64_PLT32	rt_str_region_eq-0x4
 760:	cmp    rax,0x6
 764:	je     774 <botlish_fn_2+0x15a>
 76a:	mov    ecx,0x2
 76f:	jmp    783 <botlish_fn_2+0x169>
 774:	mov    ecx,0x6
 779:	jmp    783 <botlish_fn_2+0x169>
 77e:	mov    ecx,0x6
 783:	cmp    rcx,0x6
 787:	je     8a1 <botlish_fn_2+0x287>
 78d:	mov    rdi,r13
 790:	mov    rax,QWORD PTR [rdi+0x10]
 794:	mov    rsi,QWORD PTR [rax+0xc8]
 79b:	mov    edx,0x1
 7a0:	mov    ecx,0x3
 7a5:	mov    r8,r14
 7a8:	call   7ad <botlish_fn_2+0x193>
			7a9: R_X86_64_PLT32	rt_str_region_eq-0x4
 7ad:	cmp    rax,0x6
 7b1:	je     7f5 <botlish_fn_2+0x1db>
 7b7:	mov    rdi,r13
 7ba:	mov    rax,QWORD PTR [rdi+0x10]
 7be:	mov    rsi,QWORD PTR [rax+0xd0]
 7c5:	mov    edx,0x1
 7ca:	mov    ecx,0x3
 7cf:	mov    r8,r14
 7d2:	call   7d7 <botlish_fn_2+0x1bd>
			7d3: R_X86_64_PLT32	rt_str_region_eq-0x4
 7d7:	cmp    rax,0x6
 7db:	je     7eb <botlish_fn_2+0x1d1>
 7e1:	mov    ecx,0x2
 7e6:	jmp    7fa <botlish_fn_2+0x1e0>
 7eb:	mov    ecx,0x6
 7f0:	jmp    7fa <botlish_fn_2+0x1e0>
 7f5:	mov    ecx,0x6
 7fa:	cmp    rcx,0x6
 7fe:	je     878 <botlish_fn_2+0x25e>
 804:	mov    rdi,r13
 807:	mov    rax,QWORD PTR [rdi+0x10]
 80b:	mov    rsi,QWORD PTR [rax+0xe0]
 812:	mov    edx,0x1
 817:	mov    ecx,0x3
 81c:	mov    r8,r14
 81f:	call   824 <botlish_fn_2+0x20a>
			820: R_X86_64_PLT32	rt_str_region_eq-0x4
 824:	cmp    rax,0x6
 828:	je     84f <botlish_fn_2+0x235>
 82e:	mov    rdi,r13
 831:	mov    QWORD PTR [rdi],r12
 834:	mov    rax,r14
 837:	mov    r12,QWORD PTR [rsp+0x10]
 83c:	mov    r13,QWORD PTR [rsp+0x18]
 841:	mov    r14,QWORD PTR [rsp+0x20]
 846:	add    rsp,0x30
 84a:	mov    rsp,rbp
 84d:	pop    rbp
 84e:	ret
 84f:	mov    rdi,r13
 852:	mov    rax,QWORD PTR [rdi+0x10]
 856:	mov    rax,QWORD PTR [rax+0xe8]
 85d:	mov    QWORD PTR [rdi],r12
 860:	mov    r12,QWORD PTR [rsp+0x10]
 865:	mov    r13,QWORD PTR [rsp+0x18]
 86a:	mov    r14,QWORD PTR [rsp+0x20]
 86f:	add    rsp,0x30
 873:	mov    rsp,rbp
 876:	pop    rbp
 877:	ret
 878:	mov    rdi,r13
 87b:	mov    rax,QWORD PTR [rdi+0x10]
 87f:	mov    rax,QWORD PTR [rax+0xd8]
 886:	mov    QWORD PTR [rdi],r12
 889:	mov    r12,QWORD PTR [rsp+0x10]
 88e:	mov    r13,QWORD PTR [rsp+0x18]
 893:	mov    r14,QWORD PTR [rsp+0x20]
 898:	add    rsp,0x30
 89c:	mov    rsp,rbp
 89f:	pop    rbp
 8a0:	ret
 8a1:	mov    rdi,r13
 8a4:	mov    rcx,QWORD PTR [rdi+0x10]
 8a8:	mov    rax,QWORD PTR [rcx+0xc0]
 8af:	mov    QWORD PTR [rdi],r12
 8b2:	mov    r12,QWORD PTR [rsp+0x10]
 8b7:	mov    r13,QWORD PTR [rsp+0x18]
 8bc:	mov    r14,QWORD PTR [rsp+0x20]
 8c1:	add    rsp,0x30
 8c5:	mov    rsp,rbp
 8c8:	pop    rbp
 8c9:	ret
 8ca:	mov    rdi,r13
 8cd:	mov    rsi,QWORD PTR [rdi+0x10]
 8d1:	mov    rax,QWORD PTR [rsi+0xa8]
 8d8:	mov    QWORD PTR [rdi],r12
 8db:	mov    r12,QWORD PTR [rsp+0x10]
 8e0:	mov    r13,QWORD PTR [rsp+0x18]
 8e5:	mov    r14,QWORD PTR [rsp+0x20]
 8ea:	add    rsp,0x30
 8ee:	mov    rsp,rbp
 8f1:	pop    rbp
 8f2:	ret
 8f3:	mov    rdi,r13
 8f6:	mov    rsi,QWORD PTR [rdi+0x10]
 8fa:	mov    rax,QWORD PTR [rsi+0x90]
 901:	mov    QWORD PTR [rdi],r12
 904:	mov    r12,QWORD PTR [rsp+0x10]
 909:	mov    r13,QWORD PTR [rsp+0x18]
 90e:	mov    r14,QWORD PTR [rsp+0x20]
 913:	add    rsp,0x30
 917:	mov    rsp,rbp
 91a:	pop    rbp
 91b:	ret
 91c:	mov    r13,rdi
 91f:	call   924 <botlish_fn_2+0x30a>
			920: R_X86_64_PLT32	rt_stack_overflow-0x4
 924:	xor    rax,rax
 927:	mov    r12,QWORD PTR [rsp+0x10]
 92c:	mov    r13,QWORD PTR [rsp+0x18]
 931:	mov    r14,QWORD PTR [rsp+0x20]
 936:	add    rsp,0x30
 93a:	mov    rsp,rbp
 93d:	pop    rbp
 93e:	ret

000000000000093f <botlish_entry_2: clean_char<str>>:
 93f:	push   rbp
 940:	mov    rbp,rsp
 943:	mov    rsi,QWORD PTR [rdx]
 946:	call   94b <botlish_entry_2+0xc>
			947: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 94b:	mov    rsp,rbp
 94e:	pop    rbp
 94f:	ret

0000000000000950 <botlish_fn_3: clean_from<str, int, str>>:
 950:	push   rbp
 951:	mov    rbp,rsp
 954:	sub    rsp,0x70
 958:	mov    QWORD PTR [rsp+0x40],rbx
 95d:	mov    QWORD PTR [rsp+0x48],r12
 962:	mov    QWORD PTR [rsp+0x50],r13
 967:	mov    QWORD PTR [rsp+0x58],r14
 96c:	mov    QWORD PTR [rsp+0x60],r15
 971:	mov    rbx,QWORD PTR [rdi]
 974:	mov    rax,QWORD PTR [rdi+0x8]
 978:	lea    r9,[rbx+0x8]
 97c:	cmp    r9,rax
 97f:	ja     c1c <botlish_fn_3+0x2cc>
 985:	lea    rax,[rbx+0x8]
 989:	mov    QWORD PTR [rdi],rax
 98c:	mov    r14,rdi
 98f:	mov    QWORD PTR [rbx],0x0
 996:	mov    QWORD PTR [rsp+0x20],0x0
 99f:	mov    QWORD PTR [rsp+0x28],0x0
 9a8:	mov    QWORD PTR [rsp],rsi
 9ac:	mov    QWORD PTR [rsp+0x8],rcx
 9b1:	mov    QWORD PTR [rsp+0x10],r8
 9b6:	mov    r12,rsi
 9b9:	mov    r15,r8
 9bc:	mov    QWORD PTR [rsp+0x30],rdx
 9c1:	mov    QWORD PTR [rsp+0x38],rcx
 9c6:	mov    rsi,r12
 9c9:	mov    rdi,r14
 9cc:	call   9d1 <botlish_fn_3+0x81>
			9cd: R_X86_64_PLT32	rt_str_len-0x4
 9d1:	mov    rsi,QWORD PTR [rsp+0x30]
 9d6:	mov    rcx,rsi
 9d9:	and    rcx,rax
 9dc:	mov    rdx,rax
 9df:	test   rcx,0x1
 9e6:	jne    a0e <botlish_fn_3+0xbe>
 9ec:	mov    rsi,QWORD PTR [rsp+0x30]
 9f1:	mov    rdi,r14
 9f4:	call   9f9 <botlish_fn_3+0xa9>
			9f5: R_X86_64_PLT32	rt_int_cmp-0x4
 9f9:	mov    ecx,0x2
 9fe:	test   rax,rax
 a01:	cmovge rcx,QWORD PTR [rip+0x247]        # c50 <botlish_fn_3+0x300>
 a09:	jmp    a23 <botlish_fn_3+0xd3>
 a0e:	mov    ecx,0x2
 a13:	mov    rsi,QWORD PTR [rsp+0x30]
 a18:	cmp    rsi,rdx
 a1b:	cmovge rcx,QWORD PTR [rip+0x22d]        # c50 <botlish_fn_3+0x300>
 a23:	cmp    rcx,0x6
 a27:	je     bef <botlish_fn_3+0x29f>
 a2d:	mov    rsi,QWORD PTR [rsp+0x30]
 a32:	mov    rdi,rsi
 a35:	sar    rdi,1
 a38:	lea    r13,[rdi+0x1]
 a3c:	shl    r13,1
 a3f:	or     r13,0x1
 a43:	mov    QWORD PTR [rsp+0x18],r13
 a48:	mov    rsi,r12
 a4b:	mov    rdi,r14
 a4e:	call   a53 <botlish_fn_3+0x103>
			a4f: R_X86_64_PLT32	rt_str_len-0x4
 a53:	mov    rsi,QWORD PTR [rsp+0x30]
 a58:	mov    r8,rsi
 a5b:	and    r8,rax
 a5e:	mov    rdx,rax
 a61:	test   r8,0x1
 a68:	jne    a90 <botlish_fn_3+0x140>
 a6e:	mov    rsi,QWORD PTR [rsp+0x30]
 a73:	mov    rdi,r14
 a76:	call   a7b <botlish_fn_3+0x12b>
			a77: R_X86_64_PLT32	rt_int_cmp-0x4
 a7b:	mov    ecx,0x2
 a80:	test   rax,rax
 a83:	cmovge rcx,QWORD PTR [rip+0x1c5]        # c50 <botlish_fn_3+0x300>
 a8b:	jmp    aa5 <botlish_fn_3+0x155>
 a90:	mov    ecx,0x2
 a95:	mov    rsi,QWORD PTR [rsp+0x30]
 a9a:	cmp    rsi,rdx
 a9d:	cmovge rcx,QWORD PTR [rip+0x1ab]        # c50 <botlish_fn_3+0x300>
 aa5:	cmp    rcx,0x6
 aa9:	je     b4f <botlish_fn_3+0x1ff>
 aaf:	mov    rdx,r15
 ab2:	mov    rsi,r12
 ab5:	mov    rdi,r14
 ab8:	call   abd <botlish_fn_3+0x16d>
			ab9: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 abd:	mov    QWORD PTR [rsp+0x20],rax
 ac2:	mov    QWORD PTR [rsp+0x30],rax
 ac7:	mov    rsi,QWORD PTR [rsp+0x30]
 acc:	mov    rdi,r14
 acf:	call   ad4 <botlish_fn_3+0x184>
			ad0: R_X86_64_PLT32	rt_str_byte_len-0x4
 ad4:	mov    QWORD PTR [rsp+0x28],rax
 ad9:	mov    rsi,r15
 adc:	mov    rcx,rsi
 adf:	and    rcx,rax
 ae2:	test   rcx,0x1
 ae9:	jne    afa <botlish_fn_3+0x1aa>
 aef:	mov    rdx,rax
 af2:	mov    rsi,r15
 af5:	jmp    b2a <botlish_fn_3+0x1da>
 afa:	lea    rcx,[rax-0x1]
 afe:	mov    rdx,rax
 b01:	mov    rsi,r15
 b04:	mov    rax,rsi
 b07:	add    rax,rcx
 b0a:	seto   cl
 b0d:	test   cl,cl
 b0f:	je     b1d <botlish_fn_3+0x1cd>
 b15:	mov    rsi,r15
 b18:	jmp    b2a <botlish_fn_3+0x1da>
 b1d:	mov    r15,rax
 b20:	mov    rax,QWORD PTR [rsp+0x30]
 b25:	jmp    b3a <botlish_fn_3+0x1ea>
 b2a:	mov    rdi,r14
 b2d:	call   b32 <botlish_fn_3+0x1e2>
			b2e: R_X86_64_PLT32	rt_int_add-0x4
 b32:	mov    r15,rax
 b35:	mov    rax,QWORD PTR [rsp+0x30]
 b3a:	mov    QWORD PTR [rsp+0x10],rax
 b3f:	mov    rsi,r15
 b42:	mov    QWORD PTR [rsp+0x20],rsi
 b47:	mov    rsi,rax
 b4a:	jmp    b6a <botlish_fn_3+0x21a>
 b4f:	mov    rdi,r14
 b52:	mov    rax,QWORD PTR [rdi+0x10]
 b56:	mov    rsi,QWORD PTR [rax+0x90]
 b5d:	mov    QWORD PTR [rsp+0x10],rsi
 b62:	mov    rax,r15
 b65:	mov    QWORD PTR [rsp+0x20],rax
 b6a:	mov    rdi,r14
 b6d:	call   b72 <botlish_fn_3+0x222>
			b6e: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 b72:	test   rax,rax
 b75:	jne    b83 <botlish_fn_3+0x233>
 b7b:	mov    rdi,r14
 b7e:	jmp    ba4 <botlish_fn_3+0x254>
 b83:	mov    QWORD PTR [rsp+0x10],rax
 b88:	mov    rdx,rax
 b8b:	mov    rsi,QWORD PTR [rsp+0x38]
 b90:	mov    rdi,r14
 b93:	call   b98 <botlish_fn_3+0x248>
			b94: R_X86_64_PLT32	rt_str_cat-0x4
 b98:	test   rax,rax
 b9b:	jne    bcf <botlish_fn_3+0x27f>
 ba1:	mov    rdi,r14
 ba4:	mov    rdi,r14
 ba7:	mov    QWORD PTR [rdi],rbx
 baa:	xor    rax,rax
 bad:	mov    rbx,QWORD PTR [rsp+0x40]
 bb2:	mov    r12,QWORD PTR [rsp+0x48]
 bb7:	mov    r13,QWORD PTR [rsp+0x50]
 bbc:	mov    r14,QWORD PTR [rsp+0x58]
 bc1:	mov    r15,QWORD PTR [rsp+0x60]
 bc6:	add    rsp,0x70
 bca:	mov    rsp,rbp
 bcd:	pop    rbp
 bce:	ret
 bcf:	mov    QWORD PTR [rsp],r12
 bd3:	mov    QWORD PTR [rsp+0x8],rax
 bd8:	mov    rsi,r15
 bdb:	mov    QWORD PTR [rsp+0x10],rsi
 be0:	mov    QWORD PTR [rsp+0x30],r13
 be5:	mov    QWORD PTR [rsp+0x38],rax
 bea:	jmp    9c6 <botlish_fn_3+0x76>
 bef:	mov    rdi,r14
 bf2:	mov    QWORD PTR [rdi],rbx
 bf5:	mov    rax,QWORD PTR [rsp+0x38]
 bfa:	mov    rbx,QWORD PTR [rsp+0x40]
 bff:	mov    r12,QWORD PTR [rsp+0x48]
 c04:	mov    r13,QWORD PTR [rsp+0x50]
 c09:	mov    r14,QWORD PTR [rsp+0x58]
 c0e:	mov    r15,QWORD PTR [rsp+0x60]
 c13:	add    rsp,0x70
 c17:	mov    rsp,rbp
 c1a:	pop    rbp
 c1b:	ret
 c1c:	mov    r14,rdi
 c1f:	call   c24 <botlish_fn_3+0x2d4>
			c20: R_X86_64_PLT32	rt_stack_overflow-0x4
 c24:	xor    rax,rax
 c27:	mov    rbx,QWORD PTR [rsp+0x40]
 c2c:	mov    r12,QWORD PTR [rsp+0x48]
 c31:	mov    r13,QWORD PTR [rsp+0x50]
 c36:	mov    r14,QWORD PTR [rsp+0x58]
 c3b:	mov    r15,QWORD PTR [rsp+0x60]
 c40:	add    rsp,0x70
 c44:	mov    rsp,rbp
 c47:	pop    rbp
 c48:	ret
 c49:	add    BYTE PTR [rax],al
 c4b:	add    BYTE PTR [rax],al
 c4d:	add    BYTE PTR [rax],al
 c4f:	add    BYTE PTR [rsi],al
 c51:	add    BYTE PTR [rax],al
 c53:	add    BYTE PTR [rax],al
 c55:	add    BYTE PTR [rax],al
	...

0000000000000c58 <botlish_entry_3: clean_from<str, int, str>>:
 c58:	push   rbp
 c59:	mov    rbp,rsp
 c5c:	mov    rsi,QWORD PTR [rdx]
 c5f:	mov    r9,QWORD PTR [rdx+0x8]
 c63:	mov    rcx,QWORD PTR [rdx+0x10]
 c67:	mov    r8,QWORD PTR [rdx+0x18]
 c6b:	mov    rdx,r9
 c6e:	call   c73 <botlish_entry_3+0x1b>
			c6f: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 c73:	mov    rsp,rbp
 c76:	pop    rbp
 c77:	ret

0000000000000c78 <botlish_fn_4: clean_ai_text<str>>:
 c78:	push   rbp
 c79:	mov    rbp,rsp
 c7c:	sub    rsp,0x30
 c80:	mov    QWORD PTR [rsp+0x20],rbx
 c85:	mov    QWORD PTR [rsp+0x28],r15
 c8a:	mov    r15,QWORD PTR [rdi]
 c8d:	mov    rax,QWORD PTR [rdi+0x8]
 c91:	lea    rcx,[r15+0x8]
 c95:	cmp    rcx,rax
 c98:	ja     d21 <botlish_fn_4+0xa9>
 c9e:	lea    rax,[r15+0x8]
 ca2:	mov    QWORD PTR [rdi],rax
 ca5:	mov    QWORD PTR [r15],0x0
 cac:	mov    QWORD PTR [rsp],rsi
 cb0:	mov    r8d,0x1
 cb6:	mov    QWORD PTR [rsp+0x8],0x1
 cbf:	mov    rax,QWORD PTR [rdi+0x10]
 cc3:	mov    rbx,rdi
 cc6:	mov    rcx,QWORD PTR [rax+0x90]
 ccd:	mov    QWORD PTR [rsp+0x10],rcx
 cd2:	mov    QWORD PTR [rsp+0x18],0x1
 cdb:	mov    rdx,r8
 cde:	call   ce3 <botlish_fn_4+0x6b>
			cdf: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 ce3:	test   rax,rax
 ce6:	jne    d08 <botlish_fn_4+0x90>
 cec:	mov    rdi,rbx
 cef:	mov    QWORD PTR [rdi],r15
 cf2:	xor    rax,rax
 cf5:	mov    rbx,QWORD PTR [rsp+0x20]
 cfa:	mov    r15,QWORD PTR [rsp+0x28]
 cff:	add    rsp,0x30
 d03:	mov    rsp,rbp
 d06:	pop    rbp
 d07:	ret
 d08:	mov    rdi,rbx
 d0b:	mov    QWORD PTR [rdi],r15
 d0e:	mov    rbx,QWORD PTR [rsp+0x20]
 d13:	mov    r15,QWORD PTR [rsp+0x28]
 d18:	add    rsp,0x30
 d1c:	mov    rsp,rbp
 d1f:	pop    rbp
 d20:	ret
 d21:	call   d26 <botlish_fn_4+0xae>
			d22: R_X86_64_PLT32	rt_stack_overflow-0x4
 d26:	xor    rax,rax
 d29:	mov    rbx,QWORD PTR [rsp+0x20]
 d2e:	mov    r15,QWORD PTR [rsp+0x28]
 d33:	add    rsp,0x30
 d37:	mov    rsp,rbp
 d3a:	pop    rbp
 d3b:	ret

0000000000000d3c <botlish_entry_4: clean_ai_text<str>>:
 d3c:	push   rbp
 d3d:	mov    rbp,rsp
 d40:	mov    rsi,QWORD PTR [rdx]
 d43:	call   d48 <botlish_entry_4+0xc>
			d44: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 d48:	mov    rsp,rbp
 d4b:	pop    rbp
 d4c:	ret

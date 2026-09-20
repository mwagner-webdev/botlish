; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2822  (per function: 736 476 1204 406)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> matches_at<str, str, int>
;   botlish_fn_2 / botlish_entry_2 -> replace_from<str, str, str, int, int, str>
;   botlish_fn_3 / botlish_entry_3 -> replace<str, str, str>


string_replace.asm.o:     file format elf64-x86-64


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
  3b:	ja     288 <botlish_fn_0+0x288>
  41:	lea    rax,[rbx+0x8]
  45:	mov    QWORD PTR [rdi],rax
  48:	mov    QWORD PTR [rbx],0x0
  4f:	mov    QWORD PTR [rsp+0x18],0x0
  58:	mov    QWORD PTR [rsp+0x20],0x0
  61:	mov    QWORD PTR [rsp+0x28],0x0
  6a:	mov    QWORD PTR [rsp+0x30],0x0
  73:	mov    rax,QWORD PTR [rdi+0x10]
  77:	mov    rsi,QWORD PTR [rax]
  7a:	mov    QWORD PTR [rsp],rsi
  7e:	mov    rax,QWORD PTR [rdi+0x10]
  82:	mov    rdx,QWORD PTR [rax+0x8]
  86:	mov    QWORD PTR [rsp+0x8],rdx
  8b:	mov    rax,QWORD PTR [rdi+0x10]
  8f:	mov    r12,rdi
  92:	mov    rcx,QWORD PTR [rax+0x10]
  96:	mov    QWORD PTR [rsp+0x10],rcx
  9b:	call   a0 <botlish_fn_0+0xa0>
			9c: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  a0:	test   rax,rax
  a3:	jne    b1 <botlish_fn_0+0xb1>
  a9:	mov    rdi,r12
  ac:	jmp    21d <botlish_fn_0+0x21d>
  b1:	mov    QWORD PTR [rsp],rax
  b5:	mov    rdi,r12
  b8:	mov    r13,rax
  bb:	mov    rcx,QWORD PTR [rdi+0x10]
  bf:	mov    rsi,QWORD PTR [rcx]
  c2:	mov    QWORD PTR [rsp+0x8],rsi
  c7:	mov    rdx,QWORD PTR [rdi+0x10]
  cb:	mov    rdx,QWORD PTR [rdx+0x18]
  cf:	mov    QWORD PTR [rsp+0x10],rdx
  d4:	mov    rdi,QWORD PTR [rdi+0x10]
  d8:	mov    rcx,QWORD PTR [rdi+0x20]
  dc:	mov    QWORD PTR [rsp+0x18],rcx
  e1:	mov    rdi,r12
  e4:	call   e9 <botlish_fn_0+0xe9>
			e5: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  e9:	test   rax,rax
  ec:	jne    fa <botlish_fn_0+0xfa>
  f2:	mov    rdi,r12
  f5:	jmp    21d <botlish_fn_0+0x21d>
  fa:	mov    QWORD PTR [rsp+0x8],rax
  ff:	mov    rdi,r12
 102:	mov    r14,rax
 105:	mov    r8,QWORD PTR [rdi+0x10]
 109:	mov    rsi,QWORD PTR [r8+0x28]
 10d:	mov    QWORD PTR [rsp+0x10],rsi
 112:	mov    r9,QWORD PTR [rdi+0x10]
 116:	mov    rdx,QWORD PTR [r9+0x30]
 11a:	mov    QWORD PTR [rsp+0x18],rdx
 11f:	mov    r10,QWORD PTR [rdi+0x10]
 123:	mov    rcx,QWORD PTR [r10+0x18]
 127:	mov    QWORD PTR [rsp+0x20],rcx
 12c:	call   131 <botlish_fn_0+0x131>
			12d: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 131:	test   rax,rax
 134:	jne    142 <botlish_fn_0+0x142>
 13a:	mov    rdi,r12
 13d:	jmp    21d <botlish_fn_0+0x21d>
 142:	mov    QWORD PTR [rsp+0x10],rax
 147:	mov    rdi,r12
 14a:	mov    r15,rax
 14d:	mov    rax,QWORD PTR [rdi+0x10]
 151:	mov    rsi,QWORD PTR [rax+0x38]
 155:	mov    QWORD PTR [rsp+0x18],rsi
 15a:	mov    rax,QWORD PTR [rdi+0x10]
 15e:	mov    rdx,QWORD PTR [rax]
 161:	mov    QWORD PTR [rsp+0x20],rdx
 166:	mov    rax,QWORD PTR [rdi+0x10]
 16a:	mov    rcx,QWORD PTR [rax+0x40]
 16e:	mov    QWORD PTR [rsp+0x28],rcx
 173:	call   178 <botlish_fn_0+0x178>
			174: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 178:	test   rax,rax
 17b:	jne    189 <botlish_fn_0+0x189>
 181:	mov    rdi,r12
 184:	jmp    21d <botlish_fn_0+0x21d>
 189:	mov    QWORD PTR [rsp+0x18],rax
 18e:	mov    rdi,r12
 191:	mov    QWORD PTR [rsp+0x60],rax
 196:	mov    rax,QWORD PTR [rdi+0x10]
 19a:	mov    rsi,QWORD PTR [rax+0x40]
 19e:	mov    QWORD PTR [rsp+0x20],rsi
 1a3:	mov    rax,QWORD PTR [rdi+0x10]
 1a7:	mov    rdx,QWORD PTR [rax+0x8]
 1ab:	mov    QWORD PTR [rsp+0x28],rdx
 1b0:	mov    rax,QWORD PTR [rdi+0x10]
 1b4:	mov    rcx,QWORD PTR [rax+0x10]
 1b8:	mov    QWORD PTR [rsp+0x30],rcx
 1bd:	call   1c2 <botlish_fn_0+0x1c2>
			1be: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 1c2:	test   rax,rax
 1c5:	jne    1d3 <botlish_fn_0+0x1d3>
 1cb:	mov    rdi,r12
 1ce:	jmp    21d <botlish_fn_0+0x21d>
 1d3:	mov    QWORD PTR [rsp+0x20],rax
 1d8:	lea    rdx,[rsp+0x38]
 1dd:	mov    rcx,r13
 1e0:	mov    QWORD PTR [rsp+0x38],rcx
 1e5:	mov    rcx,r14
 1e8:	mov    QWORD PTR [rsp+0x40],rcx
 1ed:	mov    rcx,r15
 1f0:	mov    QWORD PTR [rsp+0x48],rcx
 1f5:	mov    rcx,QWORD PTR [rsp+0x60]
 1fa:	mov    QWORD PTR [rsp+0x50],rcx
 1ff:	mov    QWORD PTR [rsp+0x58],rax
 204:	mov    esi,0x5
 209:	mov    rdi,r12
 20c:	call   211 <botlish_fn_0+0x211>
			20d: R_X86_64_PLT32	rt_list_new-0x4
 211:	test   rax,rax
 214:	jne    254 <botlish_fn_0+0x254>
 21a:	mov    rdi,r12
 21d:	mov    rdi,r12
 220:	mov    QWORD PTR [rdi],rbx
 223:	xor    rax,rax
 226:	mov    rbx,QWORD PTR [rsp+0x70]
 22b:	mov    r12,QWORD PTR [rsp+0x78]
 230:	mov    r13,QWORD PTR [rsp+0x80]
 238:	mov    r14,QWORD PTR [rsp+0x88]
 240:	mov    r15,QWORD PTR [rsp+0x90]
 248:	add    rsp,0xa0
 24f:	mov    rsp,rbp
 252:	pop    rbp
 253:	ret
 254:	mov    rdi,r12
 257:	mov    QWORD PTR [rdi],rbx
 25a:	mov    rbx,QWORD PTR [rsp+0x70]
 25f:	mov    r12,QWORD PTR [rsp+0x78]
 264:	mov    r13,QWORD PTR [rsp+0x80]
 26c:	mov    r14,QWORD PTR [rsp+0x88]
 274:	mov    r15,QWORD PTR [rsp+0x90]
 27c:	add    rsp,0xa0
 283:	mov    rsp,rbp
 286:	pop    rbp
 287:	ret
 288:	mov    r12,rdi
 28b:	call   290 <botlish_fn_0+0x290>
			28c: R_X86_64_PLT32	rt_stack_overflow-0x4
 290:	xor    rax,rax
 293:	mov    rbx,QWORD PTR [rsp+0x70]
 298:	mov    r12,QWORD PTR [rsp+0x78]
 29d:	mov    r13,QWORD PTR [rsp+0x80]
 2a5:	mov    r14,QWORD PTR [rsp+0x88]
 2ad:	mov    r15,QWORD PTR [rsp+0x90]
 2b5:	add    rsp,0xa0
 2bc:	mov    rsp,rbp
 2bf:	pop    rbp
 2c0:	ret

00000000000002c1 <botlish_entry_0: <program entry>>:
 2c1:	push   rbp
 2c2:	mov    rbp,rsp
 2c5:	call   2ca <botlish_entry_0+0x9>
			2c6: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 2ca:	mov    rsp,rbp
 2cd:	pop    rbp
 2ce:	ret
	...

00000000000002d0 <botlish_fn_1: matches_at<str, str, int>>:
 2d0:	push   rbp
 2d1:	mov    rbp,rsp
 2d4:	sub    rsp,0x50
 2d8:	mov    QWORD PTR [rsp+0x20],rbx
 2dd:	mov    QWORD PTR [rsp+0x28],r12
 2e2:	mov    QWORD PTR [rsp+0x30],r13
 2e7:	mov    QWORD PTR [rsp+0x38],r14
 2ec:	mov    QWORD PTR [rsp+0x40],r15
 2f1:	mov    r15,rdi
 2f4:	mov    QWORD PTR [rsp],rsi
 2f8:	mov    r14,rsi
 2fb:	mov    QWORD PTR [rsp+0x8],rdx
 300:	mov    r13,rdx
 303:	mov    QWORD PTR [rsp+0x10],rcx
 308:	mov    rbx,rcx
 30b:	mov    rsi,r13
 30e:	mov    rdi,r15
 311:	call   316 <botlish_fn_1+0x46>
			312: R_X86_64_PLT32	rt_str_len-0x4
 316:	mov    QWORD PTR [rsp+0x18],rax
 31b:	mov    rcx,rbx
 31e:	and    rcx,rax
 321:	test   rcx,0x1
 328:	jne    336 <botlish_fn_1+0x66>
 32e:	mov    rdx,rax
 331:	jmp    351 <botlish_fn_1+0x81>
 336:	lea    rcx,[rax-0x1]
 33a:	mov    rdx,rax
 33d:	mov    rax,rbx
 340:	add    rax,rcx
 343:	mov    r12,rax
 346:	seto   al
 349:	test   al,al
 34b:	je     35f <botlish_fn_1+0x8f>
 351:	mov    rsi,rbx
 354:	mov    rdi,r15
 357:	call   35c <botlish_fn_1+0x8c>
			358: R_X86_64_PLT32	rt_int_add-0x4
 35c:	mov    r12,rax
 35f:	mov    rsi,r14
 362:	mov    rdi,r15
 365:	call   36a <botlish_fn_1+0x9a>
			366: R_X86_64_PLT32	rt_str_len-0x4
 36a:	mov    rcx,r12
 36d:	and    rcx,rax
 370:	mov    rdx,rax
 373:	test   rcx,0x1
 37a:	jne    3a0 <botlish_fn_1+0xd0>
 380:	mov    rsi,r12
 383:	mov    rdi,r15
 386:	call   38b <botlish_fn_1+0xbb>
			387: R_X86_64_PLT32	rt_int_cmp-0x4
 38b:	mov    ecx,0x2
 390:	test   rax,rax
 393:	cmovg  rcx,QWORD PTR [rip+0xc5]        # 460 <botlish_fn_1+0x190>
 39b:	jmp    3b3 <botlish_fn_1+0xe3>
 3a0:	mov    ecx,0x2
 3a5:	mov    r8,r12
 3a8:	cmp    r8,rdx
 3ab:	cmovg  rcx,QWORD PTR [rip+0xad]        # 460 <botlish_fn_1+0x190>
 3b3:	cmp    rcx,0x6
 3b7:	je     432 <botlish_fn_1+0x162>
 3bd:	mov    rcx,r12
 3c0:	mov    rdx,rbx
 3c3:	mov    rsi,r14
 3c6:	mov    rdi,r15
 3c9:	call   3ce <botlish_fn_1+0xfe>
			3ca: R_X86_64_PLT32	rt_str_region_check-0x4
 3ce:	test   rax,rax
 3d1:	jne    3fc <botlish_fn_1+0x12c>
 3d7:	xor    rax,rax
 3da:	mov    rbx,QWORD PTR [rsp+0x20]
 3df:	mov    r12,QWORD PTR [rsp+0x28]
 3e4:	mov    r13,QWORD PTR [rsp+0x30]
 3e9:	mov    r14,QWORD PTR [rsp+0x38]
 3ee:	mov    r15,QWORD PTR [rsp+0x40]
 3f3:	add    rsp,0x50
 3f7:	mov    rsp,rbp
 3fa:	pop    rbp
 3fb:	ret
 3fc:	mov    rcx,r12
 3ff:	mov    rdx,rbx
 402:	mov    rsi,r14
 405:	mov    rdi,r15
 408:	mov    r8,r13
 40b:	call   410 <botlish_fn_1+0x140>
			40c: R_X86_64_PLT32	rt_str_region_eq-0x4
 410:	mov    rbx,QWORD PTR [rsp+0x20]
 415:	mov    r12,QWORD PTR [rsp+0x28]
 41a:	mov    r13,QWORD PTR [rsp+0x30]
 41f:	mov    r14,QWORD PTR [rsp+0x38]
 424:	mov    r15,QWORD PTR [rsp+0x40]
 429:	add    rsp,0x50
 42d:	mov    rsp,rbp
 430:	pop    rbp
 431:	ret
 432:	mov    eax,0x2
 437:	mov    rbx,QWORD PTR [rsp+0x20]
 43c:	mov    r12,QWORD PTR [rsp+0x28]
 441:	mov    r13,QWORD PTR [rsp+0x30]
 446:	mov    r14,QWORD PTR [rsp+0x38]
 44b:	mov    r15,QWORD PTR [rsp+0x40]
 450:	add    rsp,0x50
 454:	mov    rsp,rbp
 457:	pop    rbp
 458:	ret
 459:	add    BYTE PTR [rax],al
 45b:	add    BYTE PTR [rax],al
 45d:	add    BYTE PTR [rax],al
 45f:	add    BYTE PTR [rsi],al
 461:	add    BYTE PTR [rax],al
 463:	add    BYTE PTR [rax],al
 465:	add    BYTE PTR [rax],al
	...

0000000000000468 <botlish_entry_1: matches_at<str, str, int>>:
 468:	push   rbp
 469:	mov    rbp,rsp
 46c:	mov    rsi,QWORD PTR [rdx]
 46f:	mov    r8,QWORD PTR [rdx+0x8]
 473:	mov    rcx,QWORD PTR [rdx+0x10]
 477:	mov    rdx,r8
 47a:	call   47f <botlish_entry_1+0x17>
			47b: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 47f:	mov    rsp,rbp
 482:	pop    rbp
 483:	ret
 484:	add    BYTE PTR [rax],al
	...

0000000000000488 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 488:	push   rbp
 489:	mov    rbp,rsp
 48c:	sub    rsp,0x90
 493:	mov    QWORD PTR [rsp+0x60],rbx
 498:	mov    QWORD PTR [rsp+0x68],r12
 49d:	mov    QWORD PTR [rsp+0x70],r13
 4a2:	mov    QWORD PTR [rsp+0x78],r14
 4a7:	mov    QWORD PTR [rsp+0x80],r15
 4af:	mov    r10,QWORD PTR [rbp+0x10]
 4b3:	mov    r12,QWORD PTR [rdi]
 4b6:	mov    rax,QWORD PTR [rdi+0x8]
 4ba:	lea    r11,[r12+0x8]
 4bf:	cmp    r11,rax
 4c2:	ja     874 <botlish_fn_2+0x3ec>
 4c8:	lea    rax,[r12+0x8]
 4cd:	mov    QWORD PTR [rdi],rax
 4d0:	mov    r14,rdi
 4d3:	mov    QWORD PTR [r12],0x0
 4db:	mov    QWORD PTR [rsp],rsi
 4df:	mov    r15,rsi
 4e2:	mov    QWORD PTR [rsp+0x8],rdx
 4e7:	mov    QWORD PTR [rsp+0x10],rcx
 4ec:	mov    rbx,rcx
 4ef:	mov    QWORD PTR [rsp+0x18],r8
 4f4:	mov    QWORD PTR [rsp+0x20],r9
 4f9:	mov    QWORD PTR [rsp+0x28],r10
 4fe:	mov    QWORD PTR [rsp+0x48],r10
 503:	mov    r13,rdx
 506:	mov    QWORD PTR [rsp+0x38],r8
 50b:	mov    QWORD PTR [rsp+0x40],r9
 510:	mov    rsi,r13
 513:	mov    rdi,r14
 516:	call   51b <botlish_fn_2+0x93>
			517: R_X86_64_PLT32	rt_str_len-0x4
 51b:	mov    QWORD PTR [rsp+0x30],rax
 520:	mov    rsi,QWORD PTR [rsp+0x38]
 525:	mov    rdi,rsi
 528:	and    rdi,rax
 52b:	test   rdi,0x1
 532:	jne    545 <botlish_fn_2+0xbd>
 538:	mov    rdx,rax
 53b:	mov    QWORD PTR [rsp+0x38],rsi
 540:	jmp    569 <botlish_fn_2+0xe1>
 545:	lea    rdi,[rax-0x1]
 549:	mov    rdx,rax
 54c:	mov    rax,rsi
 54f:	add    rax,rdi
 552:	mov    QWORD PTR [rsp+0x38],rsi
 557:	mov    QWORD PTR [rsp+0x50],rax
 55c:	seto   dil
 560:	test   dil,dil
 563:	je     57b <botlish_fn_2+0xf3>
 569:	mov    rsi,QWORD PTR [rsp+0x38]
 56e:	mov    rdi,r14
 571:	call   576 <botlish_fn_2+0xee>
			572: R_X86_64_PLT32	rt_int_add-0x4
 576:	mov    QWORD PTR [rsp+0x50],rax
 57b:	mov    rsi,r15
 57e:	mov    rdi,r14
 581:	call   586 <botlish_fn_2+0xfe>
			582: R_X86_64_PLT32	rt_str_len-0x4
 586:	mov    rsi,QWORD PTR [rsp+0x50]
 58b:	mov    r11,rsi
 58e:	and    r11,rax
 591:	mov    rdx,rax
 594:	test   r11,0x1
 59b:	jne    5be <botlish_fn_2+0x136>
 5a1:	mov    rdi,r14
 5a4:	call   5a9 <botlish_fn_2+0x121>
			5a5: R_X86_64_PLT32	rt_int_cmp-0x4
 5a9:	mov    ecx,0x2
 5ae:	test   rax,rax
 5b1:	cmovg  rcx,QWORD PTR [rip+0x2ef]        # 8a8 <botlish_fn_2+0x420>
 5b9:	jmp    5ce <botlish_fn_2+0x146>
 5be:	mov    ecx,0x2
 5c3:	cmp    rsi,rdx
 5c6:	cmovg  rcx,QWORD PTR [rip+0x2da]        # 8a8 <botlish_fn_2+0x420>
 5ce:	cmp    rcx,0x6
 5d2:	je     7c1 <botlish_fn_2+0x339>
 5d8:	mov    rcx,QWORD PTR [rsp+0x38]
 5dd:	mov    rdx,r13
 5e0:	mov    rsi,r15
 5e3:	mov    rdi,r14
 5e6:	call   5eb <botlish_fn_2+0x163>
			5e7: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 5eb:	test   rax,rax
 5ee:	jne    5fc <botlish_fn_2+0x174>
 5f4:	mov    rdi,r14
 5f7:	jmp    815 <botlish_fn_2+0x38d>
 5fc:	cmp    rax,0x6
 600:	je     693 <botlish_fn_2+0x20b>
 606:	mov    QWORD PTR [rsp+0x30],0x3
 60f:	mov    rsi,QWORD PTR [rsp+0x38]
 614:	test   rsi,0x1
 61b:	je     645 <botlish_fn_2+0x1bd>
 621:	mov    rsi,QWORD PTR [rsp+0x38]
 626:	mov    rax,rsi
 629:	add    rax,0x2
 62d:	seto   cl
 630:	test   cl,cl
 632:	jne    645 <botlish_fn_2+0x1bd>
 638:	mov    rsi,r15
 63b:	mov    QWORD PTR [rsp+0x38],rax
 640:	jmp    65f <botlish_fn_2+0x1d7>
 645:	mov    edx,0x3
 64a:	mov    rsi,QWORD PTR [rsp+0x38]
 64f:	mov    rdi,r14
 652:	call   657 <botlish_fn_2+0x1cf>
			653: R_X86_64_PLT32	rt_int_add-0x4
 657:	mov    rsi,r15
 65a:	mov    QWORD PTR [rsp+0x38],rax
 65f:	mov    rsi,r15
 662:	mov    QWORD PTR [rsp],rsi
 666:	mov    QWORD PTR [rsp+0x8],r13
 66b:	mov    QWORD PTR [rsp+0x10],rbx
 670:	mov    rsi,QWORD PTR [rsp+0x38]
 675:	mov    QWORD PTR [rsp+0x18],rsi
 67a:	mov    rdx,QWORD PTR [rsp+0x40]
 67f:	mov    QWORD PTR [rsp+0x20],rdx
 684:	mov    rsi,QWORD PTR [rsp+0x48]
 689:	mov    QWORD PTR [rsp+0x28],rsi
 68e:	jmp    510 <botlish_fn_2+0x88>
 693:	mov    rdx,QWORD PTR [rsp+0x40]
 698:	mov    rcx,QWORD PTR [rsp+0x38]
 69d:	mov    rsi,r15
 6a0:	mov    rdi,r14
 6a3:	call   6a8 <botlish_fn_2+0x220>
			6a4: R_X86_64_PLT32	rt_substr-0x4
 6a8:	test   rax,rax
 6ab:	jne    6b9 <botlish_fn_2+0x231>
 6b1:	mov    rdi,r14
 6b4:	jmp    815 <botlish_fn_2+0x38d>
 6b9:	mov    QWORD PTR [rsp+0x20],rax
 6be:	mov    rdx,rax
 6c1:	mov    rsi,QWORD PTR [rsp+0x48]
 6c6:	mov    rdi,r14
 6c9:	call   6ce <botlish_fn_2+0x246>
			6ca: R_X86_64_PLT32	rt_str_cat-0x4
 6ce:	test   rax,rax
 6d1:	jne    6df <botlish_fn_2+0x257>
 6d7:	mov    rdi,r14
 6da:	jmp    815 <botlish_fn_2+0x38d>
 6df:	mov    QWORD PTR [rsp+0x20],rax
 6e4:	mov    QWORD PTR [rsp+0x50],rax
 6e9:	mov    rsi,r13
 6ec:	mov    rdi,r14
 6ef:	call   6f4 <botlish_fn_2+0x26c>
			6f0: R_X86_64_PLT32	rt_str_len-0x4
 6f4:	mov    QWORD PTR [rsp+0x28],rax
 6f9:	mov    rsi,QWORD PTR [rsp+0x38]
 6fe:	mov    rcx,rsi
 701:	and    rcx,rax
 704:	test   rcx,0x1
 70b:	jne    71e <botlish_fn_2+0x296>
 711:	mov    rdx,rax
 714:	mov    rsi,QWORD PTR [rsp+0x38]
 719:	jmp    752 <botlish_fn_2+0x2ca>
 71e:	lea    rcx,[rax-0x1]
 722:	mov    rdx,rax
 725:	mov    rsi,QWORD PTR [rsp+0x38]
 72a:	mov    rax,rsi
 72d:	add    rax,rcx
 730:	seto   cl
 733:	test   cl,cl
 735:	je     745 <botlish_fn_2+0x2bd>
 73b:	mov    rsi,QWORD PTR [rsp+0x38]
 740:	jmp    752 <botlish_fn_2+0x2ca>
 745:	mov    rsi,rax
 748:	mov    QWORD PTR [rsp+0x38],rax
 74d:	jmp    762 <botlish_fn_2+0x2da>
 752:	mov    rdi,r14
 755:	call   75a <botlish_fn_2+0x2d2>
			756: R_X86_64_PLT32	rt_int_add-0x4
 75a:	mov    rsi,rax
 75d:	mov    QWORD PTR [rsp+0x38],rax
 762:	mov    QWORD PTR [rsp+0x18],rsi
 767:	mov    rsi,QWORD PTR [rsp+0x50]
 76c:	mov    rdx,rbx
 76f:	mov    rdi,r14
 772:	call   777 <botlish_fn_2+0x2ef>
			773: R_X86_64_PLT32	rt_str_cat-0x4
 777:	test   rax,rax
 77a:	jne    788 <botlish_fn_2+0x300>
 780:	mov    rdi,r14
 783:	jmp    815 <botlish_fn_2+0x38d>
 788:	mov    rsi,r15
 78b:	mov    QWORD PTR [rsp],rsi
 78f:	mov    QWORD PTR [rsp+0x8],r13
 794:	mov    QWORD PTR [rsp+0x10],rbx
 799:	mov    rsi,QWORD PTR [rsp+0x38]
 79e:	mov    QWORD PTR [rsp+0x18],rsi
 7a3:	mov    QWORD PTR [rsp+0x20],rsi
 7a8:	mov    QWORD PTR [rsp+0x28],rax
 7ad:	mov    rcx,QWORD PTR [rsp+0x38]
 7b2:	mov    QWORD PTR [rsp+0x40],rcx
 7b7:	mov    QWORD PTR [rsp+0x48],rax
 7bc:	jmp    510 <botlish_fn_2+0x88>
 7c1:	mov    rsi,r15
 7c4:	mov    rdi,r14
 7c7:	call   7cc <botlish_fn_2+0x344>
			7c8: R_X86_64_PLT32	rt_str_len-0x4
 7cc:	mov    QWORD PTR [rsp+0x8],rax
 7d1:	mov    rcx,rax
 7d4:	mov    rdx,QWORD PTR [rsp+0x40]
 7d9:	mov    rsi,r15
 7dc:	mov    rdi,r14
 7df:	call   7e4 <botlish_fn_2+0x35c>
			7e0: R_X86_64_PLT32	rt_substr-0x4
 7e4:	test   rax,rax
 7e7:	jne    7f5 <botlish_fn_2+0x36d>
 7ed:	mov    rdi,r14
 7f0:	jmp    815 <botlish_fn_2+0x38d>
 7f5:	mov    QWORD PTR [rsp],rax
 7f9:	mov    rdx,rax
 7fc:	mov    rsi,QWORD PTR [rsp+0x48]
 801:	mov    rdi,r14
 804:	call   809 <botlish_fn_2+0x381>
			805: R_X86_64_PLT32	rt_str_cat-0x4
 809:	test   rax,rax
 80c:	jne    846 <botlish_fn_2+0x3be>
 812:	mov    rdi,r14
 815:	mov    rdi,r14
 818:	mov    QWORD PTR [rdi],r12
 81b:	xor    rax,rax
 81e:	mov    rbx,QWORD PTR [rsp+0x60]
 823:	mov    r12,QWORD PTR [rsp+0x68]
 828:	mov    r13,QWORD PTR [rsp+0x70]
 82d:	mov    r14,QWORD PTR [rsp+0x78]
 832:	mov    r15,QWORD PTR [rsp+0x80]
 83a:	add    rsp,0x90
 841:	mov    rsp,rbp
 844:	pop    rbp
 845:	ret
 846:	mov    rdi,r14
 849:	mov    QWORD PTR [rdi],r12
 84c:	mov    rbx,QWORD PTR [rsp+0x60]
 851:	mov    r12,QWORD PTR [rsp+0x68]
 856:	mov    r13,QWORD PTR [rsp+0x70]
 85b:	mov    r14,QWORD PTR [rsp+0x78]
 860:	mov    r15,QWORD PTR [rsp+0x80]
 868:	add    rsp,0x90
 86f:	mov    rsp,rbp
 872:	pop    rbp
 873:	ret
 874:	mov    r14,rdi
 877:	call   87c <botlish_fn_2+0x3f4>
			878: R_X86_64_PLT32	rt_stack_overflow-0x4
 87c:	xor    rax,rax
 87f:	mov    rbx,QWORD PTR [rsp+0x60]
 884:	mov    r12,QWORD PTR [rsp+0x68]
 889:	mov    r13,QWORD PTR [rsp+0x70]
 88e:	mov    r14,QWORD PTR [rsp+0x78]
 893:	mov    r15,QWORD PTR [rsp+0x80]
 89b:	add    rsp,0x90
 8a2:	mov    rsp,rbp
 8a5:	pop    rbp
 8a6:	ret
 8a7:	add    BYTE PTR [rsi],al
 8a9:	add    BYTE PTR [rax],al
 8ab:	add    BYTE PTR [rax],al
 8ad:	add    BYTE PTR [rax],al
	...

00000000000008b0 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 8b0:	push   rbp
 8b1:	mov    rbp,rsp
 8b4:	sub    rsp,0x10
 8b8:	mov    rsi,QWORD PTR [rdx]
 8bb:	mov    r10,QWORD PTR [rdx+0x8]
 8bf:	mov    rcx,QWORD PTR [rdx+0x10]
 8c3:	mov    r8,QWORD PTR [rdx+0x18]
 8c7:	mov    r9,QWORD PTR [rdx+0x20]
 8cb:	mov    r11,QWORD PTR [rdx+0x28]
 8cf:	mov    QWORD PTR [rsp],r11
 8d3:	mov    rdx,r10
 8d6:	call   8db <botlish_entry_2+0x2b>
			8d7: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 8db:	add    rsp,0x10
 8df:	mov    rsp,rbp
 8e2:	pop    rbp
 8e3:	ret

00000000000008e4 <botlish_fn_3: replace<str, str, str>>:
 8e4:	push   rbp
 8e5:	mov    rbp,rsp
 8e8:	sub    rsp,0x70
 8ec:	mov    QWORD PTR [rsp+0x40],rbx
 8f1:	mov    QWORD PTR [rsp+0x48],r12
 8f6:	mov    QWORD PTR [rsp+0x50],r13
 8fb:	mov    QWORD PTR [rsp+0x58],r14
 900:	mov    QWORD PTR [rsp+0x60],r15
 905:	mov    r13,rsi
 908:	mov    r15,rdx
 90b:	mov    rbx,QWORD PTR [rdi]
 90e:	mov    rax,QWORD PTR [rdi+0x8]
 912:	lea    rdx,[rbx+0x8]
 916:	cmp    rdx,rax
 919:	ja     a23 <botlish_fn_3+0x13f>
 91f:	lea    rax,[rbx+0x8]
 923:	mov    QWORD PTR [rdi],rax
 926:	mov    r12,rdi
 929:	mov    QWORD PTR [rbx],0x0
 930:	mov    rsi,r13
 933:	mov    QWORD PTR [rsp+0x10],rsi
 938:	mov    rdx,r15
 93b:	mov    QWORD PTR [rsp+0x18],rdx
 940:	mov    QWORD PTR [rsp+0x20],rcx
 945:	mov    r14,rcx
 948:	mov    rsi,r15
 94b:	mov    rdi,r12
 94e:	call   953 <botlish_fn_3+0x6f>
			94f: R_X86_64_PLT32	rt_str_len-0x4
 953:	sar    rax,1
 956:	test   rax,rax
 959:	je     9f8 <botlish_fn_3+0x114>
 95f:	mov    r9d,0x1
 965:	mov    QWORD PTR [rsp+0x28],0x1
 96e:	mov    QWORD PTR [rsp+0x30],0x1
 977:	mov    rdi,r12
 97a:	mov    rax,QWORD PTR [rdi+0x10]
 97e:	mov    rax,QWORD PTR [rax+0x40]
 982:	mov    QWORD PTR [rsp+0x38],rax
 987:	mov    QWORD PTR [rsp],rax
 98b:	mov    rcx,r14
 98e:	mov    rdx,r15
 991:	mov    rsi,r13
 994:	mov    r8,r9
 997:	call   99c <botlish_fn_3+0xb8>
			998: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 99c:	test   rax,rax
 99f:	jne    9d0 <botlish_fn_3+0xec>
 9a5:	mov    rdi,r12
 9a8:	mov    QWORD PTR [rdi],rbx
 9ab:	xor    rax,rax
 9ae:	mov    rbx,QWORD PTR [rsp+0x40]
 9b3:	mov    r12,QWORD PTR [rsp+0x48]
 9b8:	mov    r13,QWORD PTR [rsp+0x50]
 9bd:	mov    r14,QWORD PTR [rsp+0x58]
 9c2:	mov    r15,QWORD PTR [rsp+0x60]
 9c7:	add    rsp,0x70
 9cb:	mov    rsp,rbp
 9ce:	pop    rbp
 9cf:	ret
 9d0:	mov    rdi,r12
 9d3:	mov    QWORD PTR [rdi],rbx
 9d6:	mov    rbx,QWORD PTR [rsp+0x40]
 9db:	mov    r12,QWORD PTR [rsp+0x48]
 9e0:	mov    r13,QWORD PTR [rsp+0x50]
 9e5:	mov    r14,QWORD PTR [rsp+0x58]
 9ea:	mov    r15,QWORD PTR [rsp+0x60]
 9ef:	add    rsp,0x70
 9f3:	mov    rsp,rbp
 9f6:	pop    rbp
 9f7:	ret
 9f8:	mov    rdi,r12
 9fb:	mov    QWORD PTR [rdi],rbx
 9fe:	mov    rax,r13
 a01:	mov    rbx,QWORD PTR [rsp+0x40]
 a06:	mov    r12,QWORD PTR [rsp+0x48]
 a0b:	mov    r13,QWORD PTR [rsp+0x50]
 a10:	mov    r14,QWORD PTR [rsp+0x58]
 a15:	mov    r15,QWORD PTR [rsp+0x60]
 a1a:	add    rsp,0x70
 a1e:	mov    rsp,rbp
 a21:	pop    rbp
 a22:	ret
 a23:	mov    r12,rdi
 a26:	call   a2b <botlish_fn_3+0x147>
			a27: R_X86_64_PLT32	rt_stack_overflow-0x4
 a2b:	xor    rax,rax
 a2e:	mov    rbx,QWORD PTR [rsp+0x40]
 a33:	mov    r12,QWORD PTR [rsp+0x48]
 a38:	mov    r13,QWORD PTR [rsp+0x50]
 a3d:	mov    r14,QWORD PTR [rsp+0x58]
 a42:	mov    r15,QWORD PTR [rsp+0x60]
 a47:	add    rsp,0x70
 a4b:	mov    rsp,rbp
 a4e:	pop    rbp
 a4f:	ret

0000000000000a50 <botlish_entry_3: replace<str, str, str>>:
 a50:	push   rbp
 a51:	mov    rbp,rsp
 a54:	mov    rsi,QWORD PTR [rdx]
 a57:	mov    r8,QWORD PTR [rdx+0x8]
 a5b:	mov    rcx,QWORD PTR [rdx+0x10]
 a5f:	mov    rdx,r8
 a62:	call   a67 <botlish_entry_3+0x17>
			a63: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a67:	mov    rsp,rbp
 a6a:	pop    rbp
 a6b:	ret

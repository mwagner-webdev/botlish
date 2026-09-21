; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2322  (per function: 561 476 1012 273)
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
   4:	sub    rsp,0x90
   b:	mov    QWORD PTR [rsp+0x60],rbx
  10:	mov    QWORD PTR [rsp+0x68],r12
  15:	mov    QWORD PTR [rsp+0x70],r13
  1a:	mov    QWORD PTR [rsp+0x78],r14
  1f:	mov    QWORD PTR [rsp+0x80],r15
  27:	mov    QWORD PTR [rsp+0x18],0x0
  30:	mov    QWORD PTR [rsp+0x20],0x0
  39:	mov    QWORD PTR [rsp+0x28],0x0
  42:	mov    QWORD PTR [rsp+0x30],0x0
  4b:	mov    rax,QWORD PTR [rdi+0x10]
  4f:	mov    rsi,QWORD PTR [rax]
  52:	mov    QWORD PTR [rsp],rsi
  56:	mov    rax,QWORD PTR [rdi+0x10]
  5a:	mov    rdx,QWORD PTR [rax+0x8]
  5e:	mov    QWORD PTR [rsp+0x8],rdx
  63:	mov    rax,QWORD PTR [rdi+0x10]
  67:	mov    rbx,rdi
  6a:	mov    rcx,QWORD PTR [rax+0x10]
  6e:	mov    QWORD PTR [rsp+0x10],rcx
  73:	call   78 <botlish_fn_0+0x78>
			74: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  78:	test   rax,rax
  7b:	je     1c9 <botlish_fn_0+0x1c9>
  81:	mov    QWORD PTR [rsp],rax
  85:	mov    rdi,rbx
  88:	mov    r12,rax
  8b:	mov    rax,QWORD PTR [rdi+0x10]
  8f:	mov    rsi,QWORD PTR [rax]
  92:	mov    QWORD PTR [rsp+0x8],rsi
  97:	mov    rax,QWORD PTR [rdi+0x10]
  9b:	mov    rdx,QWORD PTR [rax+0x18]
  9f:	mov    QWORD PTR [rsp+0x10],rdx
  a4:	mov    rax,QWORD PTR [rdi+0x10]
  a8:	mov    rcx,QWORD PTR [rax+0x20]
  ac:	mov    QWORD PTR [rsp+0x18],rcx
  b1:	call   b6 <botlish_fn_0+0xb6>
			b2: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  b6:	test   rax,rax
  b9:	je     1c9 <botlish_fn_0+0x1c9>
  bf:	mov    QWORD PTR [rsp+0x8],rax
  c4:	mov    rdi,rbx
  c7:	mov    r13,rax
  ca:	mov    rax,QWORD PTR [rdi+0x10]
  ce:	mov    rsi,QWORD PTR [rax+0x28]
  d2:	mov    QWORD PTR [rsp+0x10],rsi
  d7:	mov    rax,QWORD PTR [rdi+0x10]
  db:	mov    rdx,QWORD PTR [rax+0x30]
  df:	mov    QWORD PTR [rsp+0x18],rdx
  e4:	mov    rax,QWORD PTR [rdi+0x10]
  e8:	mov    rcx,QWORD PTR [rax+0x18]
  ec:	mov    QWORD PTR [rsp+0x20],rcx
  f1:	call   f6 <botlish_fn_0+0xf6>
			f2: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  f6:	test   rax,rax
  f9:	je     1c9 <botlish_fn_0+0x1c9>
  ff:	mov    QWORD PTR [rsp+0x10],rax
 104:	mov    rdi,rbx
 107:	mov    r14,rax
 10a:	mov    rsi,QWORD PTR [rdi+0x10]
 10e:	mov    rsi,QWORD PTR [rsi+0x38]
 112:	mov    QWORD PTR [rsp+0x18],rsi
 117:	mov    rdi,QWORD PTR [rdi+0x10]
 11b:	mov    rdx,QWORD PTR [rdi]
 11e:	mov    QWORD PTR [rsp+0x20],rdx
 123:	mov    rdi,rbx
 126:	mov    rdi,QWORD PTR [rdi+0x10]
 12a:	mov    rcx,QWORD PTR [rdi+0x40]
 12e:	mov    QWORD PTR [rsp+0x28],rcx
 133:	mov    rdi,rbx
 136:	call   13b <botlish_fn_0+0x13b>
			137: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 13b:	test   rax,rax
 13e:	je     1c9 <botlish_fn_0+0x1c9>
 144:	mov    QWORD PTR [rsp+0x18],rax
 149:	mov    rdi,rbx
 14c:	mov    r15,rax
 14f:	mov    r11,QWORD PTR [rdi+0x10]
 153:	mov    rsi,QWORD PTR [r11+0x40]
 157:	mov    QWORD PTR [rsp+0x20],rsi
 15c:	mov    rax,QWORD PTR [rdi+0x10]
 160:	mov    rdx,QWORD PTR [rax+0x8]
 164:	mov    QWORD PTR [rsp+0x28],rdx
 169:	mov    rax,QWORD PTR [rdi+0x10]
 16d:	mov    rcx,QWORD PTR [rax+0x10]
 171:	mov    QWORD PTR [rsp+0x30],rcx
 176:	call   17b <botlish_fn_0+0x17b>
			177: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 17b:	test   rax,rax
 17e:	je     1c9 <botlish_fn_0+0x1c9>
 184:	mov    QWORD PTR [rsp+0x20],rax
 189:	lea    rdx,[rsp+0x38]
 18e:	mov    r8,r12
 191:	mov    QWORD PTR [rsp+0x38],r8
 196:	mov    r11,r13
 199:	mov    QWORD PTR [rsp+0x40],r11
 19e:	mov    rcx,r14
 1a1:	mov    QWORD PTR [rsp+0x48],rcx
 1a6:	mov    rcx,r15
 1a9:	mov    QWORD PTR [rsp+0x50],rcx
 1ae:	mov    QWORD PTR [rsp+0x58],rax
 1b3:	mov    esi,0x5
 1b8:	mov    rdi,rbx
 1bb:	call   1c0 <botlish_fn_0+0x1c0>
			1bc: R_X86_64_PLT32	rt_list_new-0x4
 1c0:	test   rax,rax
 1c3:	jne    1f4 <botlish_fn_0+0x1f4>
 1c9:	xor    rax,rax
 1cc:	mov    rbx,QWORD PTR [rsp+0x60]
 1d1:	mov    r12,QWORD PTR [rsp+0x68]
 1d6:	mov    r13,QWORD PTR [rsp+0x70]
 1db:	mov    r14,QWORD PTR [rsp+0x78]
 1e0:	mov    r15,QWORD PTR [rsp+0x80]
 1e8:	add    rsp,0x90
 1ef:	mov    rsp,rbp
 1f2:	pop    rbp
 1f3:	ret
 1f4:	mov    rbx,QWORD PTR [rsp+0x60]
 1f9:	mov    r12,QWORD PTR [rsp+0x68]
 1fe:	mov    r13,QWORD PTR [rsp+0x70]
 203:	mov    r14,QWORD PTR [rsp+0x78]
 208:	mov    r15,QWORD PTR [rsp+0x80]
 210:	add    rsp,0x90
 217:	mov    rsp,rbp
 21a:	pop    rbp
 21b:	ret

000000000000021c <botlish_entry_0: <program entry>>:
 21c:	push   rbp
 21d:	mov    rbp,rsp
 220:	call   225 <botlish_entry_0+0x9>
			221: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 225:	mov    rsp,rbp
 228:	pop    rbp
 229:	ret
 22a:	add    BYTE PTR [rax],al
 22c:	add    BYTE PTR [rax],al
	...

0000000000000230 <botlish_fn_1: matches_at<str, str, int>>:
 230:	push   rbp
 231:	mov    rbp,rsp
 234:	sub    rsp,0x50
 238:	mov    QWORD PTR [rsp+0x20],rbx
 23d:	mov    QWORD PTR [rsp+0x28],r12
 242:	mov    QWORD PTR [rsp+0x30],r13
 247:	mov    QWORD PTR [rsp+0x38],r14
 24c:	mov    QWORD PTR [rsp+0x40],r15
 251:	mov    r15,rdi
 254:	mov    QWORD PTR [rsp],rsi
 258:	mov    r14,rsi
 25b:	mov    QWORD PTR [rsp+0x8],rdx
 260:	mov    r13,rdx
 263:	mov    QWORD PTR [rsp+0x10],rcx
 268:	mov    rbx,rcx
 26b:	mov    rsi,r13
 26e:	mov    rdi,r15
 271:	call   276 <botlish_fn_1+0x46>
			272: R_X86_64_PLT32	rt_str_len-0x4
 276:	mov    QWORD PTR [rsp+0x18],rax
 27b:	mov    rcx,rbx
 27e:	and    rcx,rax
 281:	test   rcx,0x1
 288:	jne    296 <botlish_fn_1+0x66>
 28e:	mov    rdx,rax
 291:	jmp    2b1 <botlish_fn_1+0x81>
 296:	lea    rcx,[rax-0x1]
 29a:	mov    rdx,rax
 29d:	mov    rax,rbx
 2a0:	add    rax,rcx
 2a3:	mov    r12,rax
 2a6:	seto   al
 2a9:	test   al,al
 2ab:	je     2bf <botlish_fn_1+0x8f>
 2b1:	mov    rsi,rbx
 2b4:	mov    rdi,r15
 2b7:	call   2bc <botlish_fn_1+0x8c>
			2b8: R_X86_64_PLT32	rt_int_add-0x4
 2bc:	mov    r12,rax
 2bf:	mov    rsi,r14
 2c2:	mov    rdi,r15
 2c5:	call   2ca <botlish_fn_1+0x9a>
			2c6: R_X86_64_PLT32	rt_str_len-0x4
 2ca:	mov    rcx,r12
 2cd:	and    rcx,rax
 2d0:	mov    rdx,rax
 2d3:	test   rcx,0x1
 2da:	jne    300 <botlish_fn_1+0xd0>
 2e0:	mov    rsi,r12
 2e3:	mov    rdi,r15
 2e6:	call   2eb <botlish_fn_1+0xbb>
			2e7: R_X86_64_PLT32	rt_int_cmp-0x4
 2eb:	mov    ecx,0x2
 2f0:	test   rax,rax
 2f3:	cmovg  rcx,QWORD PTR [rip+0xc5]        # 3c0 <botlish_fn_1+0x190>
 2fb:	jmp    313 <botlish_fn_1+0xe3>
 300:	mov    ecx,0x2
 305:	mov    r8,r12
 308:	cmp    r8,rdx
 30b:	cmovg  rcx,QWORD PTR [rip+0xad]        # 3c0 <botlish_fn_1+0x190>
 313:	cmp    rcx,0x6
 317:	je     392 <botlish_fn_1+0x162>
 31d:	mov    rcx,r12
 320:	mov    rdx,rbx
 323:	mov    rsi,r14
 326:	mov    rdi,r15
 329:	call   32e <botlish_fn_1+0xfe>
			32a: R_X86_64_PLT32	rt_str_region_check-0x4
 32e:	test   rax,rax
 331:	jne    35c <botlish_fn_1+0x12c>
 337:	xor    rax,rax
 33a:	mov    rbx,QWORD PTR [rsp+0x20]
 33f:	mov    r12,QWORD PTR [rsp+0x28]
 344:	mov    r13,QWORD PTR [rsp+0x30]
 349:	mov    r14,QWORD PTR [rsp+0x38]
 34e:	mov    r15,QWORD PTR [rsp+0x40]
 353:	add    rsp,0x50
 357:	mov    rsp,rbp
 35a:	pop    rbp
 35b:	ret
 35c:	mov    rcx,r12
 35f:	mov    rdx,rbx
 362:	mov    rsi,r14
 365:	mov    rdi,r15
 368:	mov    r8,r13
 36b:	call   370 <botlish_fn_1+0x140>
			36c: R_X86_64_PLT32	rt_str_region_eq-0x4
 370:	mov    rbx,QWORD PTR [rsp+0x20]
 375:	mov    r12,QWORD PTR [rsp+0x28]
 37a:	mov    r13,QWORD PTR [rsp+0x30]
 37f:	mov    r14,QWORD PTR [rsp+0x38]
 384:	mov    r15,QWORD PTR [rsp+0x40]
 389:	add    rsp,0x50
 38d:	mov    rsp,rbp
 390:	pop    rbp
 391:	ret
 392:	mov    eax,0x2
 397:	mov    rbx,QWORD PTR [rsp+0x20]
 39c:	mov    r12,QWORD PTR [rsp+0x28]
 3a1:	mov    r13,QWORD PTR [rsp+0x30]
 3a6:	mov    r14,QWORD PTR [rsp+0x38]
 3ab:	mov    r15,QWORD PTR [rsp+0x40]
 3b0:	add    rsp,0x50
 3b4:	mov    rsp,rbp
 3b7:	pop    rbp
 3b8:	ret
 3b9:	add    BYTE PTR [rax],al
 3bb:	add    BYTE PTR [rax],al
 3bd:	add    BYTE PTR [rax],al
 3bf:	add    BYTE PTR [rsi],al
 3c1:	add    BYTE PTR [rax],al
 3c3:	add    BYTE PTR [rax],al
 3c5:	add    BYTE PTR [rax],al
	...

00000000000003c8 <botlish_entry_1: matches_at<str, str, int>>:
 3c8:	push   rbp
 3c9:	mov    rbp,rsp
 3cc:	mov    rsi,QWORD PTR [rdx]
 3cf:	mov    r8,QWORD PTR [rdx+0x8]
 3d3:	mov    rcx,QWORD PTR [rdx+0x10]
 3d7:	mov    rdx,r8
 3da:	call   3df <botlish_entry_1+0x17>
			3db: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 3df:	mov    rsp,rbp
 3e2:	pop    rbp
 3e3:	ret
 3e4:	add    BYTE PTR [rax],al
	...

00000000000003e8 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 3e8:	push   rbp
 3e9:	mov    rbp,rsp
 3ec:	sub    rsp,0x80
 3f3:	mov    QWORD PTR [rsp+0x50],rbx
 3f8:	mov    QWORD PTR [rsp+0x58],r12
 3fd:	mov    QWORD PTR [rsp+0x60],r13
 402:	mov    QWORD PTR [rsp+0x68],r14
 407:	mov    QWORD PTR [rsp+0x70],r15
 40c:	mov    r13,rdi
 40f:	mov    r10,QWORD PTR [rbp+0x10]
 413:	mov    QWORD PTR [rsp],rsi
 417:	mov    r14,rsi
 41a:	mov    QWORD PTR [rsp+0x8],rdx
 41f:	mov    QWORD PTR [rsp+0x10],rcx
 424:	mov    rbx,rcx
 427:	mov    QWORD PTR [rsp+0x18],r8
 42c:	mov    QWORD PTR [rsp+0x20],r9
 431:	mov    QWORD PTR [rsp+0x28],r10
 436:	mov    QWORD PTR [rsp+0x40],r10
 43b:	mov    r12,rdx
 43e:	mov    r15,r8
 441:	mov    QWORD PTR [rsp+0x38],r9
 446:	mov    rsi,r12
 449:	mov    rdi,r13
 44c:	call   451 <botlish_fn_2+0x69>
			44d: R_X86_64_PLT32	rt_str_len-0x4
 451:	mov    QWORD PTR [rsp+0x30],rax
 456:	mov    rsi,r15
 459:	mov    rcx,rsi
 45c:	and    rcx,rax
 45f:	test   rcx,0x1
 466:	jne    477 <botlish_fn_2+0x8f>
 46c:	mov    rdx,rax
 46f:	mov    r15,rsi
 472:	jmp    497 <botlish_fn_2+0xaf>
 477:	lea    rcx,[rax-0x1]
 47b:	mov    rdx,rax
 47e:	mov    rax,rsi
 481:	add    rax,rcx
 484:	mov    r15,rsi
 487:	mov    QWORD PTR [rsp+0x48],rax
 48c:	seto   al
 48f:	test   al,al
 491:	je     4a7 <botlish_fn_2+0xbf>
 497:	mov    rsi,r15
 49a:	mov    rdi,r13
 49d:	call   4a2 <botlish_fn_2+0xba>
			49e: R_X86_64_PLT32	rt_int_add-0x4
 4a2:	mov    QWORD PTR [rsp+0x48],rax
 4a7:	mov    rsi,r14
 4aa:	mov    rdi,r13
 4ad:	call   4b2 <botlish_fn_2+0xca>
			4ae: R_X86_64_PLT32	rt_str_len-0x4
 4b2:	mov    rsi,QWORD PTR [rsp+0x48]
 4b7:	mov    rcx,rsi
 4ba:	and    rcx,rax
 4bd:	mov    rdx,rax
 4c0:	test   rcx,0x1
 4c7:	jne    4ea <botlish_fn_2+0x102>
 4cd:	mov    rdi,r13
 4d0:	call   4d5 <botlish_fn_2+0xed>
			4d1: R_X86_64_PLT32	rt_int_cmp-0x4
 4d5:	mov    ecx,0x2
 4da:	test   rax,rax
 4dd:	cmovg  rcx,QWORD PTR [rip+0x25b]        # 740 <botlish_fn_2+0x358>
 4e5:	jmp    4fa <botlish_fn_2+0x112>
 4ea:	mov    ecx,0x2
 4ef:	cmp    rsi,rdx
 4f2:	cmovg  rcx,QWORD PTR [rip+0x246]        # 740 <botlish_fn_2+0x358>
 4fa:	cmp    rcx,0x6
 4fe:	je     6aa <botlish_fn_2+0x2c2>
 504:	mov    rcx,r15
 507:	mov    rdx,r12
 50a:	mov    rsi,r14
 50d:	mov    rdi,r13
 510:	call   515 <botlish_fn_2+0x12d>
			511: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 515:	test   rax,rax
 518:	je     6f3 <botlish_fn_2+0x30b>
 51e:	cmp    rax,0x6
 522:	je     5a9 <botlish_fn_2+0x1c1>
 528:	mov    QWORD PTR [rsp+0x30],0x3
 531:	mov    rsi,r15
 534:	test   rsi,0x1
 53b:	je     561 <botlish_fn_2+0x179>
 541:	mov    rsi,r15
 544:	mov    rax,rsi
 547:	add    rax,0x2
 54b:	seto   cl
 54e:	test   cl,cl
 550:	jne    561 <botlish_fn_2+0x179>
 556:	mov    rsi,r14
 559:	mov    r15,rax
 55c:	jmp    577 <botlish_fn_2+0x18f>
 561:	mov    edx,0x3
 566:	mov    rsi,r15
 569:	mov    rdi,r13
 56c:	call   571 <botlish_fn_2+0x189>
			56d: R_X86_64_PLT32	rt_int_add-0x4
 571:	mov    rsi,r14
 574:	mov    r15,rax
 577:	mov    rsi,r14
 57a:	mov    QWORD PTR [rsp],rsi
 57e:	mov    QWORD PTR [rsp+0x8],r12
 583:	mov    QWORD PTR [rsp+0x10],rbx
 588:	mov    rsi,r15
 58b:	mov    QWORD PTR [rsp+0x18],rsi
 590:	mov    rdx,QWORD PTR [rsp+0x38]
 595:	mov    QWORD PTR [rsp+0x20],rdx
 59a:	mov    rsi,QWORD PTR [rsp+0x40]
 59f:	mov    QWORD PTR [rsp+0x28],rsi
 5a4:	jmp    446 <botlish_fn_2+0x5e>
 5a9:	mov    rdx,QWORD PTR [rsp+0x38]
 5ae:	mov    rcx,r15
 5b1:	mov    rsi,r14
 5b4:	mov    rdi,r13
 5b7:	call   5bc <botlish_fn_2+0x1d4>
			5b8: R_X86_64_PLT32	rt_substr-0x4
 5bc:	test   rax,rax
 5bf:	je     6f3 <botlish_fn_2+0x30b>
 5c5:	mov    QWORD PTR [rsp+0x20],rax
 5ca:	mov    rdx,rax
 5cd:	mov    rsi,QWORD PTR [rsp+0x40]
 5d2:	mov    rdi,r13
 5d5:	call   5da <botlish_fn_2+0x1f2>
			5d6: R_X86_64_PLT32	rt_str_cat-0x4
 5da:	test   rax,rax
 5dd:	je     6f3 <botlish_fn_2+0x30b>
 5e3:	mov    QWORD PTR [rsp+0x20],rax
 5e8:	mov    QWORD PTR [rsp+0x48],rax
 5ed:	mov    rsi,r12
 5f0:	mov    rdi,r13
 5f3:	call   5f8 <botlish_fn_2+0x210>
			5f4: R_X86_64_PLT32	rt_str_len-0x4
 5f8:	mov    QWORD PTR [rsp+0x28],rax
 5fd:	mov    rsi,r15
 600:	mov    rcx,rsi
 603:	and    rcx,rax
 606:	test   rcx,0x1
 60d:	jne    61e <botlish_fn_2+0x236>
 613:	mov    rdx,rax
 616:	mov    rsi,r15
 619:	jmp    64c <botlish_fn_2+0x264>
 61e:	lea    rcx,[rax-0x1]
 622:	mov    rdx,rax
 625:	mov    rsi,r15
 628:	mov    rax,rsi
 62b:	add    rax,rcx
 62e:	seto   cl
 631:	test   cl,cl
 633:	je     641 <botlish_fn_2+0x259>
 639:	mov    rsi,r15
 63c:	jmp    64c <botlish_fn_2+0x264>
 641:	mov    rsi,rax
 644:	mov    r15,rax
 647:	jmp    65a <botlish_fn_2+0x272>
 64c:	mov    rdi,r13
 64f:	call   654 <botlish_fn_2+0x26c>
			650: R_X86_64_PLT32	rt_int_add-0x4
 654:	mov    rsi,rax
 657:	mov    r15,rax
 65a:	mov    QWORD PTR [rsp+0x18],rsi
 65f:	mov    rsi,QWORD PTR [rsp+0x48]
 664:	mov    rdx,rbx
 667:	mov    rdi,r13
 66a:	call   66f <botlish_fn_2+0x287>
			66b: R_X86_64_PLT32	rt_str_cat-0x4
 66f:	test   rax,rax
 672:	je     6f3 <botlish_fn_2+0x30b>
 678:	mov    rsi,r14
 67b:	mov    QWORD PTR [rsp],rsi
 67f:	mov    QWORD PTR [rsp+0x8],r12
 684:	mov    QWORD PTR [rsp+0x10],rbx
 689:	mov    rsi,r15
 68c:	mov    QWORD PTR [rsp+0x18],rsi
 691:	mov    QWORD PTR [rsp+0x20],rsi
 696:	mov    QWORD PTR [rsp+0x28],rax
 69b:	mov    QWORD PTR [rsp+0x38],r15
 6a0:	mov    QWORD PTR [rsp+0x40],rax
 6a5:	jmp    446 <botlish_fn_2+0x5e>
 6aa:	mov    rsi,r14
 6ad:	mov    rdi,r13
 6b0:	call   6b5 <botlish_fn_2+0x2cd>
			6b1: R_X86_64_PLT32	rt_str_len-0x4
 6b5:	mov    QWORD PTR [rsp+0x8],rax
 6ba:	mov    rcx,rax
 6bd:	mov    rdx,QWORD PTR [rsp+0x38]
 6c2:	mov    rsi,r14
 6c5:	mov    rdi,r13
 6c8:	call   6cd <botlish_fn_2+0x2e5>
			6c9: R_X86_64_PLT32	rt_substr-0x4
 6cd:	test   rax,rax
 6d0:	je     6f3 <botlish_fn_2+0x30b>
 6d6:	mov    QWORD PTR [rsp],rax
 6da:	mov    rdx,rax
 6dd:	mov    rsi,QWORD PTR [rsp+0x40]
 6e2:	mov    rdi,r13
 6e5:	call   6ea <botlish_fn_2+0x302>
			6e6: R_X86_64_PLT32	rt_str_cat-0x4
 6ea:	test   rax,rax
 6ed:	jne    71b <botlish_fn_2+0x333>
 6f3:	xor    rax,rax
 6f6:	mov    rbx,QWORD PTR [rsp+0x50]
 6fb:	mov    r12,QWORD PTR [rsp+0x58]
 700:	mov    r13,QWORD PTR [rsp+0x60]
 705:	mov    r14,QWORD PTR [rsp+0x68]
 70a:	mov    r15,QWORD PTR [rsp+0x70]
 70f:	add    rsp,0x80
 716:	mov    rsp,rbp
 719:	pop    rbp
 71a:	ret
 71b:	mov    rbx,QWORD PTR [rsp+0x50]
 720:	mov    r12,QWORD PTR [rsp+0x58]
 725:	mov    r13,QWORD PTR [rsp+0x60]
 72a:	mov    r14,QWORD PTR [rsp+0x68]
 72f:	mov    r15,QWORD PTR [rsp+0x70]
 734:	add    rsp,0x80
 73b:	mov    rsp,rbp
 73e:	pop    rbp
 73f:	ret
 740:	(bad)
 741:	add    BYTE PTR [rax],al
 743:	add    BYTE PTR [rax],al
 745:	add    BYTE PTR [rax],al
	...

0000000000000748 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 748:	push   rbp
 749:	mov    rbp,rsp
 74c:	sub    rsp,0x10
 750:	mov    rsi,QWORD PTR [rdx]
 753:	mov    r10,QWORD PTR [rdx+0x8]
 757:	mov    rcx,QWORD PTR [rdx+0x10]
 75b:	mov    r8,QWORD PTR [rdx+0x18]
 75f:	mov    r9,QWORD PTR [rdx+0x20]
 763:	mov    r11,QWORD PTR [rdx+0x28]
 767:	mov    QWORD PTR [rsp],r11
 76b:	mov    rdx,r10
 76e:	call   773 <botlish_entry_2+0x2b>
			76f: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 773:	add    rsp,0x10
 777:	mov    rsp,rbp
 77a:	pop    rbp
 77b:	ret

000000000000077c <botlish_fn_3: replace<str, str, str>>:
 77c:	push   rbp
 77d:	mov    rbp,rsp
 780:	sub    rsp,0x60
 784:	mov    QWORD PTR [rsp+0x40],rbx
 789:	mov    QWORD PTR [rsp+0x48],r12
 78e:	mov    QWORD PTR [rsp+0x50],r13
 793:	mov    QWORD PTR [rsp+0x58],r14
 798:	mov    r12,rdx
 79b:	mov    r13,rsi
 79e:	mov    QWORD PTR [rsp+0x10],rsi
 7a3:	mov    QWORD PTR [rsp+0x18],rdx
 7a8:	mov    QWORD PTR [rsp+0x20],rcx
 7ad:	mov    r14,rcx
 7b0:	mov    rbx,rdi
 7b3:	mov    rsi,r12
 7b6:	call   7bb <botlish_fn_3+0x3f>
			7b7: R_X86_64_PLT32	rt_str_len-0x4
 7bb:	sar    rax,1
 7be:	test   rax,rax
 7c1:	je     84a <botlish_fn_3+0xce>
 7c7:	mov    r9d,0x1
 7cd:	mov    QWORD PTR [rsp+0x28],0x1
 7d6:	mov    QWORD PTR [rsp+0x30],0x1
 7df:	mov    rax,QWORD PTR [rbx+0x10]
 7e3:	mov    rax,QWORD PTR [rax+0x40]
 7e7:	mov    QWORD PTR [rsp+0x38],rax
 7ec:	mov    QWORD PTR [rsp],rax
 7f0:	mov    rcx,r14
 7f3:	mov    rdx,r12
 7f6:	mov    rsi,r13
 7f9:	mov    rdi,rbx
 7fc:	mov    r8,r9
 7ff:	call   804 <botlish_fn_3+0x88>
			800: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 804:	test   rax,rax
 807:	jne    82d <botlish_fn_3+0xb1>
 80d:	xor    rax,rax
 810:	mov    rbx,QWORD PTR [rsp+0x40]
 815:	mov    r12,QWORD PTR [rsp+0x48]
 81a:	mov    r13,QWORD PTR [rsp+0x50]
 81f:	mov    r14,QWORD PTR [rsp+0x58]
 824:	add    rsp,0x60
 828:	mov    rsp,rbp
 82b:	pop    rbp
 82c:	ret
 82d:	mov    rbx,QWORD PTR [rsp+0x40]
 832:	mov    r12,QWORD PTR [rsp+0x48]
 837:	mov    r13,QWORD PTR [rsp+0x50]
 83c:	mov    r14,QWORD PTR [rsp+0x58]
 841:	add    rsp,0x60
 845:	mov    rsp,rbp
 848:	pop    rbp
 849:	ret
 84a:	mov    rax,r13
 84d:	mov    rbx,QWORD PTR [rsp+0x40]
 852:	mov    r12,QWORD PTR [rsp+0x48]
 857:	mov    r13,QWORD PTR [rsp+0x50]
 85c:	mov    r14,QWORD PTR [rsp+0x58]
 861:	add    rsp,0x60
 865:	mov    rsp,rbp
 868:	pop    rbp
 869:	ret

000000000000086a <botlish_entry_3: replace<str, str, str>>:
 86a:	push   rbp
 86b:	mov    rbp,rsp
 86e:	mov    rsi,QWORD PTR [rdx]
 871:	mov    r8,QWORD PTR [rdx+0x8]
 875:	mov    rcx,QWORD PTR [rdx+0x10]
 879:	mov    rdx,r8
 87c:	call   881 <botlish_entry_3+0x17>
			87d: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 881:	mov    rsp,rbp
 884:	pop    rbp
 885:	ret

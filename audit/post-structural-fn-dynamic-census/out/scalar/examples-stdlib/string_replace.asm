; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2618  (per function: 561 476 1308 273)
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
 3ec:	sub    rsp,0x100
 3f3:	mov    QWORD PTR [rsp+0xd0],rbx
 3fb:	mov    QWORD PTR [rsp+0xd8],r12
 403:	mov    QWORD PTR [rsp+0xe0],r13
 40b:	mov    QWORD PTR [rsp+0xe8],r14
 413:	mov    QWORD PTR [rsp+0xf0],r15
 41b:	mov    QWORD PTR [rsp+0xa8],rdi
 423:	mov    rax,QWORD PTR [rbp+0x10]
 427:	mov    QWORD PTR [rsp],rsi
 42b:	mov    r13,rsi
 42e:	mov    QWORD PTR [rsp+0x8],rdx
 433:	mov    QWORD PTR [rsp+0x10],rcx
 438:	mov    r14,rcx
 43b:	mov    QWORD PTR [rsp+0x18],r8
 440:	mov    QWORD PTR [rsp+0x20],r9
 445:	mov    r15,r9
 448:	mov    QWORD PTR [rsp+0x28],rax
 44d:	mov    QWORD PTR [rsp+0xb8],rax
 455:	lea    rbx,[rsp+0x68]
 45a:	mov    r12,rdx
 45d:	mov    QWORD PTR [rsp+0xb0],r8
 465:	mov    rsi,r12
 468:	mov    rdi,QWORD PTR [rsp+0xa8]
 470:	call   475 <botlish_fn_2+0x8d>
			471: R_X86_64_PLT32	rt_str_len-0x4
 475:	mov    QWORD PTR [rsp+0x30],rax
 47a:	mov    rsi,QWORD PTR [rsp+0xb0]
 482:	mov    rcx,rsi
 485:	and    rcx,rax
 488:	test   rcx,0x1
 48f:	jne    4a5 <botlish_fn_2+0xbd>
 495:	mov    rdx,rax
 498:	mov    QWORD PTR [rsp+0xb0],rsi
 4a0:	jmp    4d0 <botlish_fn_2+0xe8>
 4a5:	lea    rcx,[rax-0x1]
 4a9:	mov    rdi,rax
 4ac:	mov    rax,rsi
 4af:	add    rax,rcx
 4b2:	mov    QWORD PTR [rsp+0xb0],rsi
 4ba:	mov    QWORD PTR [rsp+0xc0],rax
 4c2:	seto   dl
 4c5:	test   dl,dl
 4c7:	je     4ed <botlish_fn_2+0x105>
 4cd:	mov    rdx,rdi
 4d0:	mov    rsi,QWORD PTR [rsp+0xb0]
 4d8:	mov    rdi,QWORD PTR [rsp+0xa8]
 4e0:	call   4e5 <botlish_fn_2+0xfd>
			4e1: R_X86_64_PLT32	rt_int_add-0x4
 4e5:	mov    QWORD PTR [rsp+0xc0],rax
 4ed:	mov    rsi,r13
 4f0:	mov    rdi,QWORD PTR [rsp+0xa8]
 4f8:	call   4fd <botlish_fn_2+0x115>
			4f9: R_X86_64_PLT32	rt_str_len-0x4
 4fd:	mov    rsi,QWORD PTR [rsp+0xc0]
 505:	mov    rdi,rsi
 508:	and    rdi,rax
 50b:	mov    rdx,rax
 50e:	test   rdi,0x1
 515:	jne    53d <botlish_fn_2+0x155>
 51b:	mov    rdi,QWORD PTR [rsp+0xa8]
 523:	call   528 <botlish_fn_2+0x140>
			524: R_X86_64_PLT32	rt_int_cmp-0x4
 528:	mov    ecx,0x2
 52d:	test   rax,rax
 530:	cmovg  rcx,QWORD PTR [rip+0x338]        # 870 <botlish_fn_2+0x488>
 538:	jmp    54d <botlish_fn_2+0x165>
 53d:	mov    ecx,0x2
 542:	cmp    rsi,rdx
 545:	cmovg  rcx,QWORD PTR [rip+0x323]        # 870 <botlish_fn_2+0x488>
 54d:	cmp    rcx,0x6
 551:	je     77a <botlish_fn_2+0x392>
 557:	mov    rcx,QWORD PTR [rsp+0xb0]
 55f:	mov    rdx,r12
 562:	mov    rsi,r13
 565:	mov    rdi,QWORD PTR [rsp+0xa8]
 56d:	call   572 <botlish_fn_2+0x18a>
			56e: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 572:	test   rax,rax
 575:	je     802 <botlish_fn_2+0x41a>
 57b:	cmp    rax,0x6
 57f:	je     61e <botlish_fn_2+0x236>
 585:	mov    QWORD PTR [rsp+0x30],0x3
 58e:	mov    rsi,QWORD PTR [rsp+0xb0]
 596:	test   rsi,0x1
 59d:	je     5ca <botlish_fn_2+0x1e2>
 5a3:	mov    rsi,QWORD PTR [rsp+0xb0]
 5ab:	mov    rax,rsi
 5ae:	add    rax,0x2
 5b2:	seto   cl
 5b5:	test   cl,cl
 5b7:	jne    5ca <botlish_fn_2+0x1e2>
 5bd:	mov    QWORD PTR [rsp+0xb0],rax
 5c5:	jmp    5ec <botlish_fn_2+0x204>
 5ca:	mov    edx,0x3
 5cf:	mov    rsi,QWORD PTR [rsp+0xb0]
 5d7:	mov    rdi,QWORD PTR [rsp+0xa8]
 5df:	call   5e4 <botlish_fn_2+0x1fc>
			5e0: R_X86_64_PLT32	rt_int_add-0x4
 5e4:	mov    QWORD PTR [rsp+0xb0],rax
 5ec:	mov    QWORD PTR [rsp],r13
 5f0:	mov    QWORD PTR [rsp+0x8],r12
 5f5:	mov    QWORD PTR [rsp+0x10],r14
 5fa:	mov    rsi,QWORD PTR [rsp+0xb0]
 602:	mov    QWORD PTR [rsp+0x18],rsi
 607:	mov    QWORD PTR [rsp+0x20],r15
 60c:	mov    rax,QWORD PTR [rsp+0xb8]
 614:	mov    QWORD PTR [rsp+0x28],rax
 619:	jmp    465 <botlish_fn_2+0x7d>
 61e:	mov    rcx,QWORD PTR [rsp+0xb0]
 626:	mov    rdx,r15
 629:	mov    rsi,r13
 62c:	mov    rdi,QWORD PTR [rsp+0xa8]
 634:	call   639 <botlish_fn_2+0x251>
			635: R_X86_64_PLT32	rt_str_region_check-0x4
 639:	test   rax,rax
 63c:	je     802 <botlish_fn_2+0x41a>
 642:	mov    rsi,r12
 645:	mov    rdi,QWORD PTR [rsp+0xa8]
 64d:	call   652 <botlish_fn_2+0x26a>
			64e: R_X86_64_PLT32	rt_str_len-0x4
 652:	mov    QWORD PTR [rsp+0x30],rax
 657:	mov    rsi,QWORD PTR [rsp+0xb0]
 65f:	mov    rcx,rsi
 662:	and    rcx,rax
 665:	test   rcx,0x1
 66c:	jne    67a <botlish_fn_2+0x292>
 672:	mov    rdx,rax
 675:	jmp    69a <botlish_fn_2+0x2b2>
 67a:	lea    rcx,[rax-0x1]
 67e:	mov    rdx,rax
 681:	mov    rsi,QWORD PTR [rsp+0xb0]
 689:	mov    rax,rsi
 68c:	add    rax,rcx
 68f:	seto   cl
 692:	test   cl,cl
 694:	je     6af <botlish_fn_2+0x2c7>
 69a:	mov    rsi,QWORD PTR [rsp+0xb0]
 6a2:	mov    rdi,QWORD PTR [rsp+0xa8]
 6aa:	call   6af <botlish_fn_2+0x2c7>
			6ab: R_X86_64_PLT32	rt_int_add-0x4
 6af:	mov    QWORD PTR [rsp+0x30],rax
 6b4:	mov    QWORD PTR [rsp+0xc0],rax
 6bc:	mov    QWORD PTR [rsp+0x68],0x0
 6c5:	mov    rax,QWORD PTR [rsp+0xb8]
 6cd:	mov    QWORD PTR [rsp+0x70],rax
 6d2:	mov    QWORD PTR [rsp+0x78],0x1
 6db:	mov    QWORD PTR [rsp+0x80],r13
 6e3:	mov    QWORD PTR [rsp+0x88],r15
 6eb:	mov    rsi,QWORD PTR [rsp+0xb0]
 6f3:	mov    QWORD PTR [rsp+0x90],rsi
 6fb:	mov    QWORD PTR [rsp+0x98],0x0
 707:	mov    QWORD PTR [rsp+0xa0],r14
 70f:	mov    esi,0x2
 714:	mov    edx,0x8
 719:	mov    rcx,rbx
 71c:	mov    rdi,QWORD PTR [rsp+0xa8]
 724:	call   729 <botlish_fn_2+0x341>
			725: R_X86_64_PLT32	rt_construct-0x4
 729:	mov    rcx,rax
 72c:	mov    QWORD PTR [rsp+0xb8],rax
 734:	test   rax,rcx
 737:	je     802 <botlish_fn_2+0x41a>
 73d:	mov    QWORD PTR [rsp],r13
 741:	mov    QWORD PTR [rsp+0x8],r12
 746:	mov    QWORD PTR [rsp+0x10],r14
 74b:	mov    rcx,QWORD PTR [rsp+0xc0]
 753:	mov    QWORD PTR [rsp+0x18],rcx
 758:	mov    QWORD PTR [rsp+0x20],rcx
 75d:	mov    rax,QWORD PTR [rsp+0xb8]
 765:	mov    QWORD PTR [rsp+0x28],rax
 76a:	mov    r15,rcx
 76d:	mov    QWORD PTR [rsp+0xb0],rcx
 775:	jmp    465 <botlish_fn_2+0x7d>
 77a:	mov    rsi,r13
 77d:	mov    rdi,QWORD PTR [rsp+0xa8]
 785:	call   78a <botlish_fn_2+0x3a2>
			786: R_X86_64_PLT32	rt_str_len-0x4
 78a:	mov    rbx,rax
 78d:	mov    QWORD PTR [rsp+0x8],rbx
 792:	mov    rcx,rbx
 795:	mov    rdx,r15
 798:	mov    rsi,r13
 79b:	mov    rdi,QWORD PTR [rsp+0xa8]
 7a3:	call   7a8 <botlish_fn_2+0x3c0>
			7a4: R_X86_64_PLT32	rt_str_region_check-0x4
 7a8:	test   rax,rax
 7ab:	je     802 <botlish_fn_2+0x41a>
 7b1:	xor    rsi,rsi
 7b4:	lea    rcx,[rsp+0x38]
 7b9:	mov    QWORD PTR [rsp+0x38],0x0
 7c2:	mov    rax,QWORD PTR [rsp+0xb8]
 7ca:	mov    QWORD PTR [rsp+0x40],rax
 7cf:	mov    QWORD PTR [rsp+0x48],0x1
 7d8:	mov    QWORD PTR [rsp+0x50],r13
 7dd:	mov    QWORD PTR [rsp+0x58],r15
 7e2:	mov    QWORD PTR [rsp+0x60],rbx
 7e7:	mov    edx,0x6
 7ec:	mov    rdi,QWORD PTR [rsp+0xa8]
 7f4:	call   7f9 <botlish_fn_2+0x411>
			7f5: R_X86_64_PLT32	rt_construct-0x4
 7f9:	test   rax,rax
 7fc:	jne    839 <botlish_fn_2+0x451>
 802:	xor    rax,rax
 805:	mov    rbx,QWORD PTR [rsp+0xd0]
 80d:	mov    r12,QWORD PTR [rsp+0xd8]
 815:	mov    r13,QWORD PTR [rsp+0xe0]
 81d:	mov    r14,QWORD PTR [rsp+0xe8]
 825:	mov    r15,QWORD PTR [rsp+0xf0]
 82d:	add    rsp,0x100
 834:	mov    rsp,rbp
 837:	pop    rbp
 838:	ret
 839:	mov    rbx,QWORD PTR [rsp+0xd0]
 841:	mov    r12,QWORD PTR [rsp+0xd8]
 849:	mov    r13,QWORD PTR [rsp+0xe0]
 851:	mov    r14,QWORD PTR [rsp+0xe8]
 859:	mov    r15,QWORD PTR [rsp+0xf0]
 861:	add    rsp,0x100
 868:	mov    rsp,rbp
 86b:	pop    rbp
 86c:	ret
 86d:	add    BYTE PTR [rax],al
 86f:	add    BYTE PTR [rsi],al
 871:	add    BYTE PTR [rax],al
 873:	add    BYTE PTR [rax],al
 875:	add    BYTE PTR [rax],al
	...

0000000000000878 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 878:	push   rbp
 879:	mov    rbp,rsp
 87c:	sub    rsp,0x10
 880:	mov    rsi,QWORD PTR [rdx]
 883:	mov    r10,QWORD PTR [rdx+0x8]
 887:	mov    rcx,QWORD PTR [rdx+0x10]
 88b:	mov    r8,QWORD PTR [rdx+0x18]
 88f:	mov    r9,QWORD PTR [rdx+0x20]
 893:	mov    r11,QWORD PTR [rdx+0x28]
 897:	mov    QWORD PTR [rsp],r11
 89b:	mov    rdx,r10
 89e:	call   8a3 <botlish_entry_2+0x2b>
			89f: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 8a3:	add    rsp,0x10
 8a7:	mov    rsp,rbp
 8aa:	pop    rbp
 8ab:	ret

00000000000008ac <botlish_fn_3: replace<str, str, str>>:
 8ac:	push   rbp
 8ad:	mov    rbp,rsp
 8b0:	sub    rsp,0x60
 8b4:	mov    QWORD PTR [rsp+0x40],rbx
 8b9:	mov    QWORD PTR [rsp+0x48],r12
 8be:	mov    QWORD PTR [rsp+0x50],r13
 8c3:	mov    QWORD PTR [rsp+0x58],r14
 8c8:	mov    r12,rdx
 8cb:	mov    r13,rsi
 8ce:	mov    QWORD PTR [rsp+0x10],rsi
 8d3:	mov    QWORD PTR [rsp+0x18],rdx
 8d8:	mov    QWORD PTR [rsp+0x20],rcx
 8dd:	mov    r14,rcx
 8e0:	mov    rbx,rdi
 8e3:	mov    rsi,r12
 8e6:	call   8eb <botlish_fn_3+0x3f>
			8e7: R_X86_64_PLT32	rt_str_len-0x4
 8eb:	sar    rax,1
 8ee:	test   rax,rax
 8f1:	je     97a <botlish_fn_3+0xce>
 8f7:	mov    r9d,0x1
 8fd:	mov    QWORD PTR [rsp+0x28],0x1
 906:	mov    QWORD PTR [rsp+0x30],0x1
 90f:	mov    rax,QWORD PTR [rbx+0x10]
 913:	mov    rax,QWORD PTR [rax+0x40]
 917:	mov    QWORD PTR [rsp+0x38],rax
 91c:	mov    QWORD PTR [rsp],rax
 920:	mov    rcx,r14
 923:	mov    rdx,r12
 926:	mov    rsi,r13
 929:	mov    rdi,rbx
 92c:	mov    r8,r9
 92f:	call   934 <botlish_fn_3+0x88>
			930: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 934:	test   rax,rax
 937:	jne    95d <botlish_fn_3+0xb1>
 93d:	xor    rax,rax
 940:	mov    rbx,QWORD PTR [rsp+0x40]
 945:	mov    r12,QWORD PTR [rsp+0x48]
 94a:	mov    r13,QWORD PTR [rsp+0x50]
 94f:	mov    r14,QWORD PTR [rsp+0x58]
 954:	add    rsp,0x60
 958:	mov    rsp,rbp
 95b:	pop    rbp
 95c:	ret
 95d:	mov    rbx,QWORD PTR [rsp+0x40]
 962:	mov    r12,QWORD PTR [rsp+0x48]
 967:	mov    r13,QWORD PTR [rsp+0x50]
 96c:	mov    r14,QWORD PTR [rsp+0x58]
 971:	add    rsp,0x60
 975:	mov    rsp,rbp
 978:	pop    rbp
 979:	ret
 97a:	mov    rax,r13
 97d:	mov    rbx,QWORD PTR [rsp+0x40]
 982:	mov    r12,QWORD PTR [rsp+0x48]
 987:	mov    r13,QWORD PTR [rsp+0x50]
 98c:	mov    r14,QWORD PTR [rsp+0x58]
 991:	add    rsp,0x60
 995:	mov    rsp,rbp
 998:	pop    rbp
 999:	ret

000000000000099a <botlish_entry_3: replace<str, str, str>>:
 99a:	push   rbp
 99b:	mov    rbp,rsp
 99e:	mov    rsi,QWORD PTR [rdx]
 9a1:	mov    r8,QWORD PTR [rdx+0x8]
 9a5:	mov    rcx,QWORD PTR [rdx+0x10]
 9a9:	mov    rdx,r8
 9ac:	call   9b1 <botlish_entry_3+0x17>
			9ad: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 9b1:	mov    rsp,rbp
 9b4:	pop    rbp
 9b5:	ret

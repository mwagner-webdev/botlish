; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2776  (per function: 520 476 1451 329)
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
  27:	mov    QWORD PTR [rsp+0x10],0x0
  30:	mov    QWORD PTR [rsp+0x18],0x0
  39:	mov    QWORD PTR [rsp+0x20],0x0
  42:	mov    QWORD PTR [rsp+0x28],0x0
  4b:	mov    rax,QWORD PTR [rdi+0x10]
  4f:	mov    rsi,QWORD PTR [rax]
  52:	mov    QWORD PTR [rsp],rsi
  56:	mov    rax,QWORD PTR [rdi+0x10]
  5a:	mov    rbx,rdi
  5d:	mov    rdx,QWORD PTR [rax+0x8]
  61:	mov    QWORD PTR [rsp+0x8],rdx
  66:	mov    ecx,0x79
  6b:	call   70 <botlish_fn_0+0x70>
			6c: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  70:	test   rax,rax
  73:	je     1a0 <botlish_fn_0+0x1a0>
  79:	mov    QWORD PTR [rsp],rax
  7d:	mov    rdi,rbx
  80:	mov    r12,rax
  83:	mov    rax,QWORD PTR [rdi+0x10]
  87:	mov    rsi,QWORD PTR [rax]
  8a:	mov    QWORD PTR [rsp+0x8],rsi
  8f:	mov    rax,QWORD PTR [rdi+0x10]
  93:	mov    rdx,QWORD PTR [rax+0x10]
  97:	mov    QWORD PTR [rsp+0x10],rdx
  9c:	mov    ecx,0x58
  a1:	call   a6 <botlish_fn_0+0xa6>
			a2: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  a6:	test   rax,rax
  a9:	je     1a0 <botlish_fn_0+0x1a0>
  af:	mov    QWORD PTR [rsp+0x8],rax
  b4:	mov    rdi,rbx
  b7:	mov    r13,rax
  ba:	mov    rax,QWORD PTR [rdi+0x10]
  be:	mov    rsi,QWORD PTR [rax+0x18]
  c2:	mov    QWORD PTR [rsp+0x10],rsi
  c7:	mov    rax,QWORD PTR [rdi+0x10]
  cb:	mov    rdx,QWORD PTR [rax+0x20]
  cf:	mov    QWORD PTR [rsp+0x18],rdx
  d4:	mov    ecx,0x62
  d9:	call   de <botlish_fn_0+0xde>
			da: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  de:	test   rax,rax
  e1:	je     1a0 <botlish_fn_0+0x1a0>
  e7:	mov    QWORD PTR [rsp+0x10],rax
  ec:	mov    rdi,rbx
  ef:	mov    r14,rax
  f2:	mov    rax,QWORD PTR [rdi+0x10]
  f6:	mov    rsi,QWORD PTR [rax+0x28]
  fa:	mov    QWORD PTR [rsp+0x18],rsi
  ff:	mov    rax,QWORD PTR [rdi+0x10]
 103:	mov    rdx,QWORD PTR [rax]
 106:	mov    QWORD PTR [rsp+0x20],rdx
 10b:	mov    rcx,0xffffffffffffffff
 112:	call   117 <botlish_fn_0+0x117>
			113: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 117:	test   rax,rax
 11a:	je     1a0 <botlish_fn_0+0x1a0>
 120:	mov    QWORD PTR [rsp+0x18],rax
 125:	mov    rdi,rbx
 128:	mov    r15,rax
 12b:	mov    rdx,QWORD PTR [rdi+0x10]
 12f:	mov    rsi,QWORD PTR [rdx+0x30]
 133:	mov    QWORD PTR [rsp+0x20],rsi
 138:	mov    rdi,QWORD PTR [rdi+0x10]
 13c:	mov    rdx,QWORD PTR [rdi+0x8]
 140:	mov    QWORD PTR [rsp+0x28],rdx
 145:	mov    ecx,0x79
 14a:	mov    rdi,rbx
 14d:	call   152 <botlish_fn_0+0x152>
			14e: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 152:	test   rax,rax
 155:	je     1a0 <botlish_fn_0+0x1a0>
 15b:	mov    QWORD PTR [rsp+0x20],rax
 160:	lea    rdx,[rsp+0x30]
 165:	mov    rcx,r12
 168:	mov    QWORD PTR [rsp+0x30],rcx
 16d:	mov    rcx,r13
 170:	mov    QWORD PTR [rsp+0x38],rcx
 175:	mov    rcx,r14
 178:	mov    QWORD PTR [rsp+0x40],rcx
 17d:	mov    rcx,r15
 180:	mov    QWORD PTR [rsp+0x48],rcx
 185:	mov    QWORD PTR [rsp+0x50],rax
 18a:	mov    esi,0x5
 18f:	mov    rdi,rbx
 192:	call   197 <botlish_fn_0+0x197>
			193: R_X86_64_PLT32	rt_list_new-0x4
 197:	test   rax,rax
 19a:	jne    1cb <botlish_fn_0+0x1cb>
 1a0:	xor    rax,rax
 1a3:	mov    rbx,QWORD PTR [rsp+0x60]
 1a8:	mov    r12,QWORD PTR [rsp+0x68]
 1ad:	mov    r13,QWORD PTR [rsp+0x70]
 1b2:	mov    r14,QWORD PTR [rsp+0x78]
 1b7:	mov    r15,QWORD PTR [rsp+0x80]
 1bf:	add    rsp,0x90
 1c6:	mov    rsp,rbp
 1c9:	pop    rbp
 1ca:	ret
 1cb:	mov    rbx,QWORD PTR [rsp+0x60]
 1d0:	mov    r12,QWORD PTR [rsp+0x68]
 1d5:	mov    r13,QWORD PTR [rsp+0x70]
 1da:	mov    r14,QWORD PTR [rsp+0x78]
 1df:	mov    r15,QWORD PTR [rsp+0x80]
 1e7:	add    rsp,0x90
 1ee:	mov    rsp,rbp
 1f1:	pop    rbp
 1f2:	ret

00000000000001f3 <botlish_entry_0: <program entry>>:
 1f3:	push   rbp
 1f4:	mov    rbp,rsp
 1f7:	call   1fc <botlish_entry_0+0x9>
			1f8: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 1fc:	mov    rsp,rbp
 1ff:	pop    rbp
 200:	ret
 201:	add    BYTE PTR [rax],al
 203:	add    BYTE PTR [rax],al
 205:	add    BYTE PTR [rax],al
	...

0000000000000208 <botlish_fn_1: matches_at<str, str, int>>:
 208:	push   rbp
 209:	mov    rbp,rsp
 20c:	sub    rsp,0x50
 210:	mov    QWORD PTR [rsp+0x20],rbx
 215:	mov    QWORD PTR [rsp+0x28],r12
 21a:	mov    QWORD PTR [rsp+0x30],r13
 21f:	mov    QWORD PTR [rsp+0x38],r14
 224:	mov    QWORD PTR [rsp+0x40],r15
 229:	mov    r15,rdi
 22c:	mov    QWORD PTR [rsp],rsi
 230:	mov    r14,rsi
 233:	mov    QWORD PTR [rsp+0x8],rdx
 238:	mov    r13,rdx
 23b:	mov    QWORD PTR [rsp+0x10],rcx
 240:	mov    rbx,rcx
 243:	mov    rsi,r13
 246:	mov    rdi,r15
 249:	call   24e <botlish_fn_1+0x46>
			24a: R_X86_64_PLT32	rt_str_len-0x4
 24e:	mov    QWORD PTR [rsp+0x18],rax
 253:	mov    rcx,rbx
 256:	and    rcx,rax
 259:	test   rcx,0x1
 260:	jne    26e <botlish_fn_1+0x66>
 266:	mov    rdx,rax
 269:	jmp    289 <botlish_fn_1+0x81>
 26e:	lea    rcx,[rax-0x1]
 272:	mov    rdx,rax
 275:	mov    rax,rbx
 278:	add    rax,rcx
 27b:	mov    r12,rax
 27e:	seto   al
 281:	test   al,al
 283:	je     297 <botlish_fn_1+0x8f>
 289:	mov    rsi,rbx
 28c:	mov    rdi,r15
 28f:	call   294 <botlish_fn_1+0x8c>
			290: R_X86_64_PLT32	rt_int_add-0x4
 294:	mov    r12,rax
 297:	mov    rsi,r14
 29a:	mov    rdi,r15
 29d:	call   2a2 <botlish_fn_1+0x9a>
			29e: R_X86_64_PLT32	rt_str_len-0x4
 2a2:	mov    rcx,r12
 2a5:	and    rcx,rax
 2a8:	mov    rdx,rax
 2ab:	test   rcx,0x1
 2b2:	jne    2d8 <botlish_fn_1+0xd0>
 2b8:	mov    rsi,r12
 2bb:	mov    rdi,r15
 2be:	call   2c3 <botlish_fn_1+0xbb>
			2bf: R_X86_64_PLT32	rt_int_cmp-0x4
 2c3:	mov    ecx,0x2
 2c8:	test   rax,rax
 2cb:	cmovg  rcx,QWORD PTR [rip+0xc5]        # 398 <botlish_fn_1+0x190>
 2d3:	jmp    2eb <botlish_fn_1+0xe3>
 2d8:	mov    ecx,0x2
 2dd:	mov    r8,r12
 2e0:	cmp    r8,rdx
 2e3:	cmovg  rcx,QWORD PTR [rip+0xad]        # 398 <botlish_fn_1+0x190>
 2eb:	cmp    rcx,0x6
 2ef:	je     36a <botlish_fn_1+0x162>
 2f5:	mov    rcx,r12
 2f8:	mov    rdx,rbx
 2fb:	mov    rsi,r14
 2fe:	mov    rdi,r15
 301:	call   306 <botlish_fn_1+0xfe>
			302: R_X86_64_PLT32	rt_str_region_check-0x4
 306:	test   rax,rax
 309:	jne    334 <botlish_fn_1+0x12c>
 30f:	xor    rax,rax
 312:	mov    rbx,QWORD PTR [rsp+0x20]
 317:	mov    r12,QWORD PTR [rsp+0x28]
 31c:	mov    r13,QWORD PTR [rsp+0x30]
 321:	mov    r14,QWORD PTR [rsp+0x38]
 326:	mov    r15,QWORD PTR [rsp+0x40]
 32b:	add    rsp,0x50
 32f:	mov    rsp,rbp
 332:	pop    rbp
 333:	ret
 334:	mov    rcx,r12
 337:	mov    rdx,rbx
 33a:	mov    rsi,r14
 33d:	mov    rdi,r15
 340:	mov    r8,r13
 343:	call   348 <botlish_fn_1+0x140>
			344: R_X86_64_PLT32	rt_str_region_eq-0x4
 348:	mov    rbx,QWORD PTR [rsp+0x20]
 34d:	mov    r12,QWORD PTR [rsp+0x28]
 352:	mov    r13,QWORD PTR [rsp+0x30]
 357:	mov    r14,QWORD PTR [rsp+0x38]
 35c:	mov    r15,QWORD PTR [rsp+0x40]
 361:	add    rsp,0x50
 365:	mov    rsp,rbp
 368:	pop    rbp
 369:	ret
 36a:	mov    eax,0x2
 36f:	mov    rbx,QWORD PTR [rsp+0x20]
 374:	mov    r12,QWORD PTR [rsp+0x28]
 379:	mov    r13,QWORD PTR [rsp+0x30]
 37e:	mov    r14,QWORD PTR [rsp+0x38]
 383:	mov    r15,QWORD PTR [rsp+0x40]
 388:	add    rsp,0x50
 38c:	mov    rsp,rbp
 38f:	pop    rbp
 390:	ret
 391:	add    BYTE PTR [rax],al
 393:	add    BYTE PTR [rax],al
 395:	add    BYTE PTR [rax],al
 397:	add    BYTE PTR [rsi],al
 399:	add    BYTE PTR [rax],al
 39b:	add    BYTE PTR [rax],al
 39d:	add    BYTE PTR [rax],al
	...

00000000000003a0 <botlish_entry_1: matches_at<str, str, int>>:
 3a0:	push   rbp
 3a1:	mov    rbp,rsp
 3a4:	mov    rsi,QWORD PTR [rdx]
 3a7:	mov    r8,QWORD PTR [rdx+0x8]
 3ab:	mov    rcx,QWORD PTR [rdx+0x10]
 3af:	mov    rdx,r8
 3b2:	call   3b7 <botlish_entry_1+0x17>
			3b3: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 3b7:	mov    rsp,rbp
 3ba:	pop    rbp
 3bb:	ret
 3bc:	add    BYTE PTR [rax],al
	...

00000000000003c0 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 3c0:	push   rbp
 3c1:	mov    rbp,rsp
 3c4:	sub    rsp,0x100
 3cb:	mov    QWORD PTR [rsp+0xd0],rbx
 3d3:	mov    QWORD PTR [rsp+0xd8],r12
 3db:	mov    QWORD PTR [rsp+0xe0],r13
 3e3:	mov    QWORD PTR [rsp+0xe8],r14
 3eb:	mov    QWORD PTR [rsp+0xf0],r15
 3f3:	mov    QWORD PTR [rsp+0xa8],rdi
 3fb:	mov    rax,QWORD PTR [rbp+0x10]
 3ff:	mov    QWORD PTR [rsp+0x30],0x0
 408:	mov    QWORD PTR [rsp],rsi
 40c:	mov    r14,rsi
 40f:	mov    QWORD PTR [rsp+0x8],rdx
 414:	mov    QWORD PTR [rsp+0x10],r8
 419:	mov    QWORD PTR [rsp+0x18],r9
 41e:	mov    r15,r9
 421:	mov    QWORD PTR [rsp+0x20],rax
 426:	mov    QWORD PTR [rsp+0xc0],rax
 42e:	lea    rbx,[rcx+0x1]
 432:	mov    QWORD PTR [rsp+0xb0],rcx
 43a:	lea    r12,[rsp+0x68]
 43f:	mov    r13,rdx
 442:	mov    QWORD PTR [rsp+0xb8],r8
 44a:	mov    rsi,r13
 44d:	mov    rdi,QWORD PTR [rsp+0xa8]
 455:	call   45a <botlish_fn_2+0x9a>
			456: R_X86_64_PLT32	rt_str_len-0x4
 45a:	mov    QWORD PTR [rsp+0x28],rax
 45f:	mov    rsi,QWORD PTR [rsp+0xb8]
 467:	mov    rdx,rsi
 46a:	and    rdx,rax
 46d:	test   rdx,0x1
 474:	jne    48a <botlish_fn_2+0xca>
 47a:	mov    rdx,rax
 47d:	mov    QWORD PTR [rsp+0xb8],rsi
 485:	jmp    4b4 <botlish_fn_2+0xf4>
 48a:	lea    rdi,[rax-0x1]
 48e:	mov    rdx,rax
 491:	mov    rax,rsi
 494:	add    rax,rdi
 497:	mov    QWORD PTR [rsp+0xb8],rsi
 49f:	mov    QWORD PTR [rsp+0xc8],rax
 4a7:	seto   sil
 4ab:	test   sil,sil
 4ae:	je     4d1 <botlish_fn_2+0x111>
 4b4:	mov    rsi,QWORD PTR [rsp+0xb8]
 4bc:	mov    rdi,QWORD PTR [rsp+0xa8]
 4c4:	call   4c9 <botlish_fn_2+0x109>
			4c5: R_X86_64_PLT32	rt_int_add-0x4
 4c9:	mov    QWORD PTR [rsp+0xc8],rax
 4d1:	mov    rsi,r14
 4d4:	mov    rdi,QWORD PTR [rsp+0xa8]
 4dc:	call   4e1 <botlish_fn_2+0x121>
			4dd: R_X86_64_PLT32	rt_str_len-0x4
 4e1:	mov    rsi,QWORD PTR [rsp+0xc8]
 4e9:	mov    r10,rsi
 4ec:	and    r10,rax
 4ef:	mov    rdx,rax
 4f2:	test   r10,0x1
 4f9:	jne    521 <botlish_fn_2+0x161>
 4ff:	mov    rdi,QWORD PTR [rsp+0xa8]
 507:	call   50c <botlish_fn_2+0x14c>
			508: R_X86_64_PLT32	rt_int_cmp-0x4
 50c:	mov    ecx,0x2
 511:	test   rax,rax
 514:	cmovg  rcx,QWORD PTR [rip+0x374]        # 890 <botlish_fn_2+0x4d0>
 51c:	jmp    531 <botlish_fn_2+0x171>
 521:	mov    ecx,0x2
 526:	cmp    rsi,rdx
 529:	cmovg  rcx,QWORD PTR [rip+0x35f]        # 890 <botlish_fn_2+0x4d0>
 531:	cmp    rcx,0x6
 535:	je     794 <botlish_fn_2+0x3d4>
 53b:	mov    rcx,QWORD PTR [rsp+0xb8]
 543:	mov    rdx,r13
 546:	mov    rsi,r14
 549:	mov    rdi,QWORD PTR [rsp+0xa8]
 551:	call   556 <botlish_fn_2+0x196>
			552: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 556:	test   rax,rax
 559:	je     81f <botlish_fn_2+0x45f>
 55f:	cmp    rax,0x6
 563:	je     5fd <botlish_fn_2+0x23d>
 569:	mov    QWORD PTR [rsp+0x28],0x3
 572:	mov    rsi,QWORD PTR [rsp+0xb8]
 57a:	test   rsi,0x1
 581:	je     5ae <botlish_fn_2+0x1ee>
 587:	mov    rsi,QWORD PTR [rsp+0xb8]
 58f:	mov    rax,rsi
 592:	add    rax,0x2
 596:	seto   cl
 599:	test   cl,cl
 59b:	jne    5ae <botlish_fn_2+0x1ee>
 5a1:	mov    QWORD PTR [rsp+0xb8],rax
 5a9:	jmp    5d0 <botlish_fn_2+0x210>
 5ae:	mov    edx,0x3
 5b3:	mov    rsi,QWORD PTR [rsp+0xb8]
 5bb:	mov    rdi,QWORD PTR [rsp+0xa8]
 5c3:	call   5c8 <botlish_fn_2+0x208>
			5c4: R_X86_64_PLT32	rt_int_add-0x4
 5c8:	mov    QWORD PTR [rsp+0xb8],rax
 5d0:	mov    QWORD PTR [rsp],r14
 5d4:	mov    QWORD PTR [rsp+0x8],r13
 5d9:	mov    rsi,QWORD PTR [rsp+0xb8]
 5e1:	mov    QWORD PTR [rsp+0x10],rsi
 5e6:	mov    QWORD PTR [rsp+0x18],r15
 5eb:	mov    rax,QWORD PTR [rsp+0xc0]
 5f3:	mov    QWORD PTR [rsp+0x20],rax
 5f8:	jmp    44a <botlish_fn_2+0x8a>
 5fd:	mov    rcx,QWORD PTR [rsp+0xb8]
 605:	mov    rdx,r15
 608:	mov    rsi,r14
 60b:	mov    rdi,QWORD PTR [rsp+0xa8]
 613:	call   618 <botlish_fn_2+0x258>
			614: R_X86_64_PLT32	rt_str_region_check-0x4
 618:	test   rax,rax
 61b:	je     81f <botlish_fn_2+0x45f>
 621:	mov    rsi,r13
 624:	mov    rdi,QWORD PTR [rsp+0xa8]
 62c:	call   631 <botlish_fn_2+0x271>
			62d: R_X86_64_PLT32	rt_str_len-0x4
 631:	mov    QWORD PTR [rsp+0x28],rax
 636:	mov    rsi,QWORD PTR [rsp+0xb8]
 63e:	mov    rcx,rsi
 641:	and    rcx,rax
 644:	test   rcx,0x1
 64b:	jne    659 <botlish_fn_2+0x299>
 651:	mov    rdx,rax
 654:	jmp    679 <botlish_fn_2+0x2b9>
 659:	lea    rcx,[rax-0x1]
 65d:	mov    rdx,rax
 660:	mov    rsi,QWORD PTR [rsp+0xb8]
 668:	mov    rax,rsi
 66b:	add    rax,rcx
 66e:	seto   cl
 671:	test   cl,cl
 673:	je     68e <botlish_fn_2+0x2ce>
 679:	mov    rsi,QWORD PTR [rsp+0xb8]
 681:	mov    rdi,QWORD PTR [rsp+0xa8]
 689:	call   68e <botlish_fn_2+0x2ce>
			68a: R_X86_64_PLT32	rt_int_add-0x4
 68e:	mov    QWORD PTR [rsp+0x28],rax
 693:	mov    QWORD PTR [rsp+0xc8],rax
 69b:	cmp    rbx,0x101
 6a2:	jae    6c1 <botlish_fn_2+0x301>
 6a8:	mov    rdi,QWORD PTR [rsp+0xa8]
 6b0:	mov    rax,QWORD PTR [rdi+rbx*8+0x648]
 6b8:	test   rax,rax
 6bb:	jne    6d6 <botlish_fn_2+0x316>
 6c1:	mov    rsi,QWORD PTR [rsp+0xb0]
 6c9:	mov    rdi,QWORD PTR [rsp+0xa8]
 6d1:	call   6d6 <botlish_fn_2+0x316>
			6d2: R_X86_64_PLT32	rt_short_to_str-0x4
 6d6:	mov    QWORD PTR [rsp+0x30],rax
 6db:	mov    QWORD PTR [rsp+0x68],0x0
 6e4:	mov    rcx,QWORD PTR [rsp+0xc0]
 6ec:	mov    QWORD PTR [rsp+0x70],rcx
 6f1:	mov    QWORD PTR [rsp+0x78],0x1
 6fa:	mov    QWORD PTR [rsp+0x80],r14
 702:	mov    QWORD PTR [rsp+0x88],r15
 70a:	mov    rsi,QWORD PTR [rsp+0xb8]
 712:	mov    QWORD PTR [rsp+0x90],rsi
 71a:	mov    QWORD PTR [rsp+0x98],0x0
 726:	mov    QWORD PTR [rsp+0xa0],rax
 72e:	mov    esi,0x2
 733:	mov    edx,0x8
 738:	mov    rcx,r12
 73b:	mov    rdi,QWORD PTR [rsp+0xa8]
 743:	call   748 <botlish_fn_2+0x388>
			744: R_X86_64_PLT32	rt_construct-0x4
 748:	mov    rdi,rax
 74b:	mov    QWORD PTR [rsp+0xc0],rax
 753:	test   rax,rdi
 756:	je     81f <botlish_fn_2+0x45f>
 75c:	mov    QWORD PTR [rsp],r14
 760:	mov    QWORD PTR [rsp+0x8],r13
 765:	mov    rax,QWORD PTR [rsp+0xc8]
 76d:	mov    QWORD PTR [rsp+0x10],rax
 772:	mov    QWORD PTR [rsp+0x18],rax
 777:	mov    rcx,QWORD PTR [rsp+0xc0]
 77f:	mov    QWORD PTR [rsp+0x20],rcx
 784:	mov    r15,rax
 787:	mov    QWORD PTR [rsp+0xb8],rax
 78f:	jmp    44a <botlish_fn_2+0x8a>
 794:	mov    rsi,r14
 797:	mov    rdi,QWORD PTR [rsp+0xa8]
 79f:	call   7a4 <botlish_fn_2+0x3e4>
			7a0: R_X86_64_PLT32	rt_str_len-0x4
 7a4:	mov    QWORD PTR [rsp+0x8],rax
 7a9:	mov    rbx,rax
 7ac:	mov    rcx,rbx
 7af:	mov    rdx,r15
 7b2:	mov    rsi,r14
 7b5:	mov    rdi,QWORD PTR [rsp+0xa8]
 7bd:	call   7c2 <botlish_fn_2+0x402>
			7be: R_X86_64_PLT32	rt_str_region_check-0x4
 7c2:	test   rax,rax
 7c5:	je     81f <botlish_fn_2+0x45f>
 7cb:	xor    rsi,rsi
 7ce:	lea    rcx,[rsp+0x38]
 7d3:	mov    QWORD PTR [rsp+0x38],0x0
 7dc:	mov    rax,QWORD PTR [rsp+0xc0]
 7e4:	mov    QWORD PTR [rsp+0x40],rax
 7e9:	mov    QWORD PTR [rsp+0x48],0x1
 7f2:	mov    QWORD PTR [rsp+0x50],r14
 7f7:	mov    QWORD PTR [rsp+0x58],r15
 7fc:	mov    rax,rbx
 7ff:	mov    QWORD PTR [rsp+0x60],rax
 804:	mov    edx,0x6
 809:	mov    rdi,QWORD PTR [rsp+0xa8]
 811:	call   816 <botlish_fn_2+0x456>
			812: R_X86_64_PLT32	rt_construct-0x4
 816:	test   rax,rax
 819:	jne    856 <botlish_fn_2+0x496>
 81f:	xor    rax,rax
 822:	mov    rbx,QWORD PTR [rsp+0xd0]
 82a:	mov    r12,QWORD PTR [rsp+0xd8]
 832:	mov    r13,QWORD PTR [rsp+0xe0]
 83a:	mov    r14,QWORD PTR [rsp+0xe8]
 842:	mov    r15,QWORD PTR [rsp+0xf0]
 84a:	add    rsp,0x100
 851:	mov    rsp,rbp
 854:	pop    rbp
 855:	ret
 856:	mov    rbx,QWORD PTR [rsp+0xd0]
 85e:	mov    r12,QWORD PTR [rsp+0xd8]
 866:	mov    r13,QWORD PTR [rsp+0xe0]
 86e:	mov    r14,QWORD PTR [rsp+0xe8]
 876:	mov    r15,QWORD PTR [rsp+0xf0]
 87e:	add    rsp,0x100
 885:	mov    rsp,rbp
 888:	pop    rbp
 889:	ret
 88a:	add    BYTE PTR [rax],al
 88c:	add    BYTE PTR [rax],al
 88e:	add    BYTE PTR [rax],al
 890:	(bad)
 891:	add    BYTE PTR [rax],al
 893:	add    BYTE PTR [rax],al
 895:	add    BYTE PTR [rax],al
	...

0000000000000898 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 898:	push   rbp
 899:	mov    rbp,rsp
 89c:	sub    rsp,0x30
 8a0:	mov    QWORD PTR [rsp+0x10],rbx
 8a5:	mov    QWORD PTR [rsp+0x18],r12
 8aa:	mov    QWORD PTR [rsp+0x20],r13
 8af:	mov    QWORD PTR [rsp+0x28],r14
 8b4:	mov    r14,rdi
 8b7:	mov    r13,QWORD PTR [rdx]
 8ba:	mov    r12,QWORD PTR [rdx+0x8]
 8be:	mov    rsi,QWORD PTR [rdx+0x10]
 8c2:	mov    rbx,rdx
 8c5:	mov    r11,QWORD PTR [rip+0x0]        # 8cc <botlish_entry_2+0x34>
			8c8: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 8cc:	call   r11
 8cf:	mov    rdx,rbx
 8d2:	mov    r8,QWORD PTR [rdx+0x18]
 8d6:	mov    r9,QWORD PTR [rdx+0x20]
 8da:	mov    r11,QWORD PTR [rdx+0x28]
 8de:	mov    QWORD PTR [rsp],r11
 8e2:	mov    rcx,rax
 8e5:	mov    rdx,r12
 8e8:	mov    rsi,r13
 8eb:	mov    rdi,r14
 8ee:	call   8f3 <botlish_entry_2+0x5b>
			8ef: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 8f3:	mov    rbx,QWORD PTR [rsp+0x10]
 8f8:	mov    r12,QWORD PTR [rsp+0x18]
 8fd:	mov    r13,QWORD PTR [rsp+0x20]
 902:	mov    r14,QWORD PTR [rsp+0x28]
 907:	add    rsp,0x30
 90b:	mov    rsp,rbp
 90e:	pop    rbp
 90f:	ret

0000000000000910 <botlish_fn_3: replace<str, str, str>>:
 910:	push   rbp
 911:	mov    rbp,rsp
 914:	sub    rsp,0x60
 918:	mov    QWORD PTR [rsp+0x40],rbx
 91d:	mov    QWORD PTR [rsp+0x48],r12
 922:	mov    QWORD PTR [rsp+0x50],r13
 927:	mov    QWORD PTR [rsp+0x58],r14
 92c:	mov    r12,rdx
 92f:	mov    r13,rsi
 932:	mov    r14,rcx
 935:	mov    QWORD PTR [rsp+0x10],rsi
 93a:	mov    QWORD PTR [rsp+0x18],rdx
 93f:	mov    rbx,rdi
 942:	mov    rsi,r12
 945:	call   94a <botlish_fn_3+0x3a>
			946: R_X86_64_PLT32	rt_str_len-0x4
 94a:	sar    rax,1
 94d:	test   rax,rax
 950:	je     9d9 <botlish_fn_3+0xc9>
 956:	mov    r9d,0x1
 95c:	mov    QWORD PTR [rsp+0x20],0x1
 965:	mov    QWORD PTR [rsp+0x28],0x1
 96e:	mov    rax,QWORD PTR [rbx+0x10]
 972:	mov    rax,QWORD PTR [rax+0x30]
 976:	mov    QWORD PTR [rsp+0x30],rax
 97b:	mov    QWORD PTR [rsp],rax
 97f:	mov    rcx,r14
 982:	mov    rdx,r12
 985:	mov    rsi,r13
 988:	mov    rdi,rbx
 98b:	mov    r8,r9
 98e:	call   993 <botlish_fn_3+0x83>
			98f: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 993:	test   rax,rax
 996:	jne    9bc <botlish_fn_3+0xac>
 99c:	xor    rax,rax
 99f:	mov    rbx,QWORD PTR [rsp+0x40]
 9a4:	mov    r12,QWORD PTR [rsp+0x48]
 9a9:	mov    r13,QWORD PTR [rsp+0x50]
 9ae:	mov    r14,QWORD PTR [rsp+0x58]
 9b3:	add    rsp,0x60
 9b7:	mov    rsp,rbp
 9ba:	pop    rbp
 9bb:	ret
 9bc:	mov    rbx,QWORD PTR [rsp+0x40]
 9c1:	mov    r12,QWORD PTR [rsp+0x48]
 9c6:	mov    r13,QWORD PTR [rsp+0x50]
 9cb:	mov    r14,QWORD PTR [rsp+0x58]
 9d0:	add    rsp,0x60
 9d4:	mov    rsp,rbp
 9d7:	pop    rbp
 9d8:	ret
 9d9:	mov    rax,r13
 9dc:	mov    rbx,QWORD PTR [rsp+0x40]
 9e1:	mov    r12,QWORD PTR [rsp+0x48]
 9e6:	mov    r13,QWORD PTR [rsp+0x50]
 9eb:	mov    r14,QWORD PTR [rsp+0x58]
 9f0:	add    rsp,0x60
 9f4:	mov    rsp,rbp
 9f7:	pop    rbp
 9f8:	ret

00000000000009f9 <botlish_entry_3: replace<str, str, str>>:
 9f9:	push   rbp
 9fa:	mov    rbp,rsp
 9fd:	sub    rsp,0x20
 a01:	mov    QWORD PTR [rsp],r12
 a05:	mov    QWORD PTR [rsp+0x8],r13
 a0a:	mov    QWORD PTR [rsp+0x10],r14
 a0f:	mov    r14,rdi
 a12:	mov    r13,QWORD PTR [rdx]
 a15:	mov    r12,QWORD PTR [rdx+0x8]
 a19:	mov    rsi,QWORD PTR [rdx+0x10]
 a1d:	mov    r8,QWORD PTR [rip+0x0]        # a24 <botlish_entry_3+0x2b>
			a20: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 a24:	call   r8
 a27:	mov    rcx,rax
 a2a:	mov    rdx,r12
 a2d:	mov    rsi,r13
 a30:	mov    rdi,r14
 a33:	call   a38 <botlish_entry_3+0x3f>
			a34: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a38:	mov    r12,QWORD PTR [rsp]
 a3c:	mov    r13,QWORD PTR [rsp+0x8]
 a41:	mov    r14,QWORD PTR [rsp+0x10]
 a46:	add    rsp,0x20
 a4a:	mov    rsp,rbp
 a4d:	pop    rbp
 a4e:	ret

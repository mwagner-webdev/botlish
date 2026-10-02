; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2787  (per function: 471 625 1404 287)
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
   4:	sub    rsp,0x80
   b:	mov    QWORD PTR [rsp+0x50],rbx
  10:	mov    QWORD PTR [rsp+0x58],r12
  15:	mov    QWORD PTR [rsp+0x60],r13
  1a:	mov    QWORD PTR [rsp+0x68],r14
  1f:	mov    QWORD PTR [rsp+0x70],r15
  24:	mov    QWORD PTR [rsp+0x8],0x0
  2d:	mov    QWORD PTR [rsp+0x10],0x0
  36:	mov    QWORD PTR [rsp+0x18],0x0
  3f:	mov    QWORD PTR [rsp+0x20],0x0
  48:	mov    rax,QWORD PTR [rdi+0x10]
  4c:	mov    rbx,rdi
  4f:	mov    rcx,QWORD PTR [rax]
  52:	mov    QWORD PTR [rsp],rcx
  56:	mov    esi,0xe3e2e1
  5b:	mov    edx,0xf8
  60:	call   65 <botlish_fn_0+0x65>
			61: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  65:	test   rax,rax
  68:	je     174 <botlish_fn_0+0x174>
  6e:	mov    QWORD PTR [rsp],rax
  72:	mov    rdi,rbx
  75:	mov    r12,rax
  78:	mov    rax,QWORD PTR [rdi+0x10]
  7c:	mov    rcx,QWORD PTR [rax+0x8]
  80:	mov    QWORD PTR [rsp+0x8],rcx
  85:	mov    esi,0xe3e2e1
  8a:	mov    edx,0xe2
  8f:	call   94 <botlish_fn_0+0x94>
			90: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  94:	test   rax,rax
  97:	je     174 <botlish_fn_0+0x174>
  9d:	mov    QWORD PTR [rsp+0x8],rax
  a2:	mov    rdi,rbx
  a5:	mov    r13,rax
  a8:	mov    rax,QWORD PTR [rdi+0x10]
  ac:	mov    rcx,QWORD PTR [rax+0x10]
  b0:	mov    QWORD PTR [rsp+0x10],rcx
  b5:	mov    esi,0xe1e1e1e1
  ba:	mov    edx,0xe1e1
  bf:	call   c4 <botlish_fn_0+0xc4>
			c0: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  c4:	test   rax,rax
  c7:	je     174 <botlish_fn_0+0x174>
  cd:	mov    QWORD PTR [rsp+0x10],rax
  d2:	mov    rdi,rbx
  d5:	mov    r14,rax
  d8:	mov    rax,QWORD PTR [rdi+0x10]
  dc:	mov    rcx,QWORD PTR [rax+0x18]
  e0:	mov    QWORD PTR [rsp+0x18],rcx
  e5:	movabs rsi,0xe3e2e1e3e2e1
  ef:	mov    edx,0xe3e2e1
  f4:	call   f9 <botlish_fn_0+0xf9>
			f5: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  f9:	test   rax,rax
  fc:	je     174 <botlish_fn_0+0x174>
 102:	mov    QWORD PTR [rsp+0x18],rax
 107:	mov    rdi,rbx
 10a:	mov    r15,rax
 10d:	mov    rax,QWORD PTR [rdi+0x10]
 111:	mov    rcx,QWORD PTR [rax]
 114:	mov    QWORD PTR [rsp+0x20],rcx
 119:	xor    rsi,rsi
 11c:	mov    edx,0xf8
 121:	call   126 <botlish_fn_0+0x126>
			122: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 126:	test   rax,rax
 129:	je     174 <botlish_fn_0+0x174>
 12f:	mov    QWORD PTR [rsp+0x20],rax
 134:	lea    rdx,[rsp+0x28]
 139:	mov    rcx,r12
 13c:	mov    QWORD PTR [rsp+0x28],rcx
 141:	mov    rcx,r13
 144:	mov    QWORD PTR [rsp+0x30],rcx
 149:	mov    rcx,r14
 14c:	mov    QWORD PTR [rsp+0x38],rcx
 151:	mov    rcx,r15
 154:	mov    QWORD PTR [rsp+0x40],rcx
 159:	mov    QWORD PTR [rsp+0x48],rax
 15e:	mov    esi,0x5
 163:	mov    rdi,rbx
 166:	call   16b <botlish_fn_0+0x16b>
			167: R_X86_64_PLT32	rt_list_new-0x4
 16b:	test   rax,rax
 16e:	jne    19c <botlish_fn_0+0x19c>
 174:	xor    rax,rax
 177:	mov    rbx,QWORD PTR [rsp+0x50]
 17c:	mov    r12,QWORD PTR [rsp+0x58]
 181:	mov    r13,QWORD PTR [rsp+0x60]
 186:	mov    r14,QWORD PTR [rsp+0x68]
 18b:	mov    r15,QWORD PTR [rsp+0x70]
 190:	add    rsp,0x80
 197:	mov    rsp,rbp
 19a:	pop    rbp
 19b:	ret
 19c:	mov    rbx,QWORD PTR [rsp+0x50]
 1a1:	mov    r12,QWORD PTR [rsp+0x58]
 1a6:	mov    r13,QWORD PTR [rsp+0x60]
 1ab:	mov    r14,QWORD PTR [rsp+0x68]
 1b0:	mov    r15,QWORD PTR [rsp+0x70]
 1b5:	add    rsp,0x80
 1bc:	mov    rsp,rbp
 1bf:	pop    rbp
 1c0:	ret

00000000000001c1 <botlish_entry_0: <program entry>>:
 1c1:	push   rbp
 1c2:	mov    rbp,rsp
 1c5:	call   1ca <botlish_entry_0+0x9>
			1c6: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 1ca:	mov    rsp,rbp
 1cd:	pop    rbp
 1ce:	ret
	...

00000000000001d0 <botlish_fn_1: matches_at<str, str, int>>:
 1d0:	push   rbp
 1d1:	mov    rbp,rsp
 1d4:	sub    rsp,0x50
 1d8:	mov    QWORD PTR [rsp+0x20],rbx
 1dd:	mov    QWORD PTR [rsp+0x28],r12
 1e2:	mov    QWORD PTR [rsp+0x30],r13
 1e7:	mov    QWORD PTR [rsp+0x38],r14
 1ec:	mov    QWORD PTR [rsp+0x40],r15
 1f1:	mov    r12,rsi
 1f4:	mov    r13,rcx
 1f7:	mov    r14,rdi
 1fa:	mov    r15,rdx
 1fd:	mov    QWORD PTR [rsp+0x10],0x0
 206:	mov    QWORD PTR [rsp],rcx
 20a:	mov    edx,0x47
 20f:	mov    rcx,0xffffffffffffffff
 216:	mov    rdi,r15
 219:	bsr    rax,rdi
 21d:	cmove  rax,rcx
 221:	mov    ecx,0x3f
 226:	sub    rcx,rax
 229:	sub    rdx,rcx
 22c:	shr    rdx,0x3
 230:	shl    rdx,1
 233:	mov    rax,rdx
 236:	or     rax,0x1
 23a:	mov    QWORD PTR [rsp+0x8],rax
 23f:	mov    rcx,r13
 242:	and    rcx,rax
 245:	test   rcx,0x1
 24c:	je     26d <botlish_fn_1+0x9d>
 252:	mov    rax,rdx
 255:	and    rax,0xfffffffffffffffe
 259:	mov    rcx,r13
 25c:	mov    rbx,rcx
 25f:	add    rbx,rax
 262:	seto   al
 265:	test   al,al
 267:	je     27f <botlish_fn_1+0xaf>
 26d:	or     rdx,0x1
 271:	mov    rsi,r13
 274:	mov    rdi,r14
 277:	call   27c <botlish_fn_1+0xac>
			278: R_X86_64_PLT32	rt_int_add-0x4
 27c:	mov    rbx,rax
 27f:	mov    QWORD PTR [rsp+0x8],rbx
 284:	mov    rcx,0xffffffffffffffff
 28b:	bsr    rdx,r12
 28f:	cmove  rdx,rcx
 293:	mov    ecx,0x3f
 298:	sub    rcx,rdx
 29b:	mov    edx,0x47
 2a0:	sub    rdx,rcx
 2a3:	shr    rdx,0x3
 2a7:	shl    rdx,1
 2aa:	or     rdx,0x1
 2ae:	mov    rax,rbx
 2b1:	and    rax,rdx
 2b4:	test   rax,0x1
 2ba:	jne    2e0 <botlish_fn_1+0x110>
 2c0:	mov    rsi,rbx
 2c3:	mov    rdi,r14
 2c6:	call   2cb <botlish_fn_1+0xfb>
			2c7: R_X86_64_PLT32	rt_int_cmp-0x4
 2cb:	mov    ecx,0x2
 2d0:	test   rax,rax
 2d3:	cmovg  rcx,QWORD PTR [rip+0xdd]        # 3b8 <botlish_fn_1+0x1e8>
 2db:	jmp    2f3 <botlish_fn_1+0x123>
 2e0:	mov    ecx,0x2
 2e5:	mov    rax,rbx
 2e8:	cmp    rax,rdx
 2eb:	cmovg  rcx,QWORD PTR [rip+0xc5]        # 3b8 <botlish_fn_1+0x1e8>
 2f3:	cmp    rcx,0x6
 2f7:	je     390 <botlish_fn_1+0x1c0>
 2fd:	mov    rsi,r12
 300:	mov    rdi,r14
 303:	call   308 <botlish_fn_1+0x138>
			304: R_X86_64_PLT32	rt_ascii_to_str-0x4
 308:	mov    QWORD PTR [rsp+0x10],rax
 30d:	mov    r12,rax
 310:	mov    rcx,rbx
 313:	mov    rdx,r13
 316:	mov    rsi,r12
 319:	mov    rdi,r14
 31c:	call   321 <botlish_fn_1+0x151>
			31d: R_X86_64_PLT32	rt_str_region_check-0x4
 321:	test   rax,rax
 324:	jne    34f <botlish_fn_1+0x17f>
 32a:	xor    rax,rax
 32d:	mov    rbx,QWORD PTR [rsp+0x20]
 332:	mov    r12,QWORD PTR [rsp+0x28]
 337:	mov    r13,QWORD PTR [rsp+0x30]
 33c:	mov    r14,QWORD PTR [rsp+0x38]
 341:	mov    r15,QWORD PTR [rsp+0x40]
 346:	add    rsp,0x50
 34a:	mov    rsp,rbp
 34d:	pop    rbp
 34e:	ret
 34f:	mov    rsi,r15
 352:	mov    rdi,r14
 355:	call   35a <botlish_fn_1+0x18a>
			356: R_X86_64_PLT32	rt_ascii_to_str-0x4
 35a:	mov    rcx,rbx
 35d:	mov    rdx,r13
 360:	mov    rsi,r12
 363:	mov    rdi,r14
 366:	mov    r8,rax
 369:	call   36e <botlish_fn_1+0x19e>
			36a: R_X86_64_PLT32	rt_str_region_eq-0x4
 36e:	mov    rbx,QWORD PTR [rsp+0x20]
 373:	mov    r12,QWORD PTR [rsp+0x28]
 378:	mov    r13,QWORD PTR [rsp+0x30]
 37d:	mov    r14,QWORD PTR [rsp+0x38]
 382:	mov    r15,QWORD PTR [rsp+0x40]
 387:	add    rsp,0x50
 38b:	mov    rsp,rbp
 38e:	pop    rbp
 38f:	ret
 390:	mov    eax,0x2
 395:	mov    rbx,QWORD PTR [rsp+0x20]
 39a:	mov    r12,QWORD PTR [rsp+0x28]
 39f:	mov    r13,QWORD PTR [rsp+0x30]
 3a4:	mov    r14,QWORD PTR [rsp+0x38]
 3a9:	mov    r15,QWORD PTR [rsp+0x40]
 3ae:	add    rsp,0x50
 3b2:	mov    rsp,rbp
 3b5:	pop    rbp
 3b6:	ret
 3b7:	add    BYTE PTR [rsi],al
 3b9:	add    BYTE PTR [rax],al
 3bb:	add    BYTE PTR [rax],al
 3bd:	add    BYTE PTR [rax],al
	...

00000000000003c0 <botlish_entry_1: matches_at<str, str, int>>:
 3c0:	push   rbp
 3c1:	mov    rbp,rsp
 3c4:	sub    rsp,0x20
 3c8:	mov    QWORD PTR [rsp],rbx
 3cc:	mov    QWORD PTR [rsp+0x8],r12
 3d1:	mov    QWORD PTR [rsp+0x10],r13
 3d6:	mov    QWORD PTR [rsp+0x18],r14
 3db:	mov    r12,rdi
 3de:	mov    rsi,QWORD PTR [rdx]
 3e1:	mov    r14,rdx
 3e4:	mov    r10,QWORD PTR [rip+0x0]        # 3eb <botlish_entry_1+0x2b>
			3e7: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 3eb:	call   r10
 3ee:	mov    rbx,r14
 3f1:	mov    r13,rax
 3f4:	mov    rsi,QWORD PTR [rbx+0x8]
 3f8:	mov    r10,QWORD PTR [rip+0x0]        # 3ff <botlish_entry_1+0x3f>
			3fb: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 3ff:	mov    rdi,r12
 402:	call   r10
 405:	mov    rcx,QWORD PTR [rbx+0x10]
 409:	mov    rdx,rax
 40c:	mov    rsi,r13
 40f:	mov    rdi,r12
 412:	call   417 <botlish_entry_1+0x57>
			413: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 417:	mov    rbx,QWORD PTR [rsp]
 41b:	mov    r12,QWORD PTR [rsp+0x8]
 420:	mov    r13,QWORD PTR [rsp+0x10]
 425:	mov    r14,QWORD PTR [rsp+0x18]
 42a:	add    rsp,0x20
 42e:	mov    rsp,rbp
 431:	pop    rbp
 432:	ret
 433:	add    BYTE PTR [rax],al
 435:	add    BYTE PTR [rax],al
	...

0000000000000438 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 438:	push   rbp
 439:	mov    rbp,rsp
 43c:	sub    rsp,0x110
 443:	mov    QWORD PTR [rsp+0xe0],rbx
 44b:	mov    QWORD PTR [rsp+0xe8],r12
 453:	mov    QWORD PTR [rsp+0xf0],r13
 45b:	mov    QWORD PTR [rsp+0xf8],r14
 463:	mov    QWORD PTR [rsp+0x100],r15
 46b:	mov    QWORD PTR [rsp+0xa0],rdi
 473:	mov    rax,QWORD PTR [rbp+0x10]
 477:	mov    QWORD PTR [rsp+0x28],0x0
 480:	mov    QWORD PTR [rsp],rcx
 484:	mov    r13,rcx
 487:	mov    QWORD PTR [rsp+0x8],r8
 48c:	mov    QWORD PTR [rsp+0x10],r9
 491:	mov    r12,r9
 494:	mov    QWORD PTR [rsp+0x18],rax
 499:	mov    QWORD PTR [rsp+0xc0],rax
 4a1:	mov    r15d,0x47
 4a7:	mov    rcx,0xffffffffffffffff
 4ae:	bsr    rax,rdx
 4b2:	mov    QWORD PTR [rsp+0xb0],rdx
 4ba:	cmove  rax,rcx
 4be:	mov    ecx,0x3f
 4c3:	sub    rcx,rax
 4c6:	mov    rbx,r15
 4c9:	sub    rbx,rcx
 4cc:	shr    rbx,0x3
 4d0:	shl    rbx,1
 4d3:	mov    rcx,0xffffffffffffffff
 4da:	bsr    rax,rsi
 4de:	mov    QWORD PTR [rsp+0xa8],rsi
 4e6:	cmove  rax,rcx
 4ea:	mov    ecx,0x3f
 4ef:	sub    rcx,rax
 4f2:	sub    r15,rcx
 4f5:	shr    r15,0x3
 4f9:	shl    r15,1
 4fc:	lea    rax,[rsp+0x60]
 501:	mov    QWORD PTR [rsp+0xd0],rax
 509:	mov    rax,r8
 50c:	mov    rcx,rbx
 50f:	or     rcx,0x1
 513:	mov    QWORD PTR [rsp+0x20],rcx
 518:	mov    r14,rax
 51b:	and    r14,rcx
 51e:	test   r14,0x1
 525:	jne    538 <botlish_fn_2+0x100>
 52b:	mov    QWORD PTR [rsp+0xb8],rax
 533:	jmp    558 <botlish_fn_2+0x120>
 538:	mov    rcx,rbx
 53b:	and    rcx,0xfffffffffffffffe
 53f:	mov    rsi,rax
 542:	add    rsi,rcx
 545:	mov    QWORD PTR [rsp+0xb8],rax
 54d:	seto   al
 550:	test   al,al
 552:	je     577 <botlish_fn_2+0x13f>
 558:	mov    rdx,rbx
 55b:	or     rdx,0x1
 55f:	mov    rsi,QWORD PTR [rsp+0xb8]
 567:	mov    rdi,QWORD PTR [rsp+0xa0]
 56f:	call   574 <botlish_fn_2+0x13c>
			570: R_X86_64_PLT32	rt_int_add-0x4
 574:	mov    rsi,rax
 577:	mov    rax,r15
 57a:	or     rax,0x1
 57e:	mov    rcx,rsi
 581:	and    rcx,rax
 584:	test   rcx,0x1
 58b:	jne    5ba <botlish_fn_2+0x182>
 591:	mov    rdx,r15
 594:	or     rdx,0x1
 598:	mov    rdi,QWORD PTR [rsp+0xa0]
 5a0:	call   5a5 <botlish_fn_2+0x16d>
			5a1: R_X86_64_PLT32	rt_int_cmp-0x4
 5a5:	mov    ecx,0x2
 5aa:	test   rax,rax
 5ad:	cmovg  rcx,QWORD PTR [rip+0x35b]        # 910 <botlish_fn_2+0x4d8>
 5b5:	jmp    5d1 <botlish_fn_2+0x199>
 5ba:	mov    rax,r15
 5bd:	or     rax,0x1
 5c1:	mov    ecx,0x2
 5c6:	cmp    rsi,rax
 5c9:	cmovg  rcx,QWORD PTR [rip+0x33f]        # 910 <botlish_fn_2+0x4d8>
 5d1:	cmp    rcx,0x6
 5d5:	je     808 <botlish_fn_2+0x3d0>
 5db:	mov    rcx,QWORD PTR [rsp+0xb8]
 5e3:	mov    rdx,QWORD PTR [rsp+0xb0]
 5eb:	mov    rsi,QWORD PTR [rsp+0xa8]
 5f3:	mov    rdi,QWORD PTR [rsp+0xa0]
 5fb:	call   600 <botlish_fn_2+0x1c8>
			5fc: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 600:	test   rax,rax
 603:	je     8a1 <botlish_fn_2+0x469>
 609:	cmp    rax,0x6
 60d:	je     6aa <botlish_fn_2+0x272>
 613:	mov    QWORD PTR [rsp+0x20],0x3
 61c:	mov    rsi,QWORD PTR [rsp+0xb8]
 624:	test   rsi,0x1
 62b:	je     658 <botlish_fn_2+0x220>
 631:	mov    rsi,QWORD PTR [rsp+0xb8]
 639:	mov    rax,rsi
 63c:	add    rax,0x2
 640:	seto   cl
 643:	test   cl,cl
 645:	jne    658 <botlish_fn_2+0x220>
 64b:	mov    QWORD PTR [rsp+0xb8],rax
 653:	jmp    67a <botlish_fn_2+0x242>
 658:	mov    edx,0x3
 65d:	mov    rsi,QWORD PTR [rsp+0xb8]
 665:	mov    rdi,QWORD PTR [rsp+0xa0]
 66d:	call   672 <botlish_fn_2+0x23a>
			66e: R_X86_64_PLT32	rt_int_add-0x4
 672:	mov    QWORD PTR [rsp+0xb8],rax
 67a:	mov    QWORD PTR [rsp],r13
 67e:	mov    rsi,QWORD PTR [rsp+0xb8]
 686:	mov    QWORD PTR [rsp+0x8],rsi
 68b:	mov    QWORD PTR [rsp+0x10],r12
 690:	mov    rax,QWORD PTR [rsp+0xc0]
 698:	mov    QWORD PTR [rsp+0x18],rax
 69d:	mov    rax,QWORD PTR [rsp+0xb8]
 6a5:	jmp    50c <botlish_fn_2+0xd4>
 6aa:	mov    rsi,QWORD PTR [rsp+0xa8]
 6b2:	mov    rdi,QWORD PTR [rsp+0xa0]
 6ba:	call   6bf <botlish_fn_2+0x287>
			6bb: R_X86_64_PLT32	rt_ascii_to_str-0x4
 6bf:	mov    QWORD PTR [rsp+0x20],rax
 6c4:	mov    QWORD PTR [rsp+0xc8],rax
 6cc:	mov    rcx,QWORD PTR [rsp+0xb8]
 6d4:	mov    rdx,r12
 6d7:	mov    rsi,QWORD PTR [rsp+0xc8]
 6df:	mov    rdi,QWORD PTR [rsp+0xa0]
 6e7:	call   6ec <botlish_fn_2+0x2b4>
			6e8: R_X86_64_PLT32	rt_str_region_check-0x4
 6ec:	test   rax,rax
 6ef:	je     8a1 <botlish_fn_2+0x469>
 6f5:	mov    rax,rbx
 6f8:	or     rax,0x1
 6fc:	mov    QWORD PTR [rsp+0x28],rax
 701:	test   r14,0x1
 708:	je     730 <botlish_fn_2+0x2f8>
 70e:	mov    rdx,rbx
 711:	and    rdx,0xfffffffffffffffe
 715:	mov    rsi,QWORD PTR [rsp+0xb8]
 71d:	mov    rax,rsi
 720:	add    rax,rdx
 723:	seto   sil
 727:	test   sil,sil
 72a:	je     74c <botlish_fn_2+0x314>
 730:	mov    rdx,rbx
 733:	or     rdx,0x1
 737:	mov    rsi,QWORD PTR [rsp+0xb8]
 73f:	mov    rdi,QWORD PTR [rsp+0xa0]
 747:	call   74c <botlish_fn_2+0x314>
			748: R_X86_64_PLT32	rt_int_add-0x4
 74c:	mov    QWORD PTR [rsp+0x28],rax
 751:	mov    r14,rax
 754:	mov    QWORD PTR [rsp+0x60],0x0
 75d:	mov    rax,QWORD PTR [rsp+0xc0]
 765:	mov    QWORD PTR [rsp+0x68],rax
 76a:	mov    QWORD PTR [rsp+0x70],0x1
 773:	mov    rax,QWORD PTR [rsp+0xc8]
 77b:	mov    QWORD PTR [rsp+0x78],rax
 780:	mov    QWORD PTR [rsp+0x80],r12
 788:	mov    rsi,QWORD PTR [rsp+0xb8]
 790:	mov    QWORD PTR [rsp+0x88],rsi
 798:	mov    QWORD PTR [rsp+0x90],0x0
 7a4:	mov    QWORD PTR [rsp+0x98],r13
 7ac:	mov    esi,0x2
 7b1:	mov    edx,0x8
 7b6:	mov    rcx,QWORD PTR [rsp+0xd0]
 7be:	mov    rdi,QWORD PTR [rsp+0xa0]
 7c6:	call   7cb <botlish_fn_2+0x393>
			7c7: R_X86_64_PLT32	rt_construct-0x4
 7cb:	mov    rcx,rax
 7ce:	mov    QWORD PTR [rsp+0xc0],rax
 7d6:	test   rax,rcx
 7d9:	je     8a1 <botlish_fn_2+0x469>
 7df:	mov    QWORD PTR [rsp],r13
 7e3:	mov    rcx,r14
 7e6:	mov    QWORD PTR [rsp+0x8],rcx
 7eb:	mov    QWORD PTR [rsp+0x10],rcx
 7f0:	mov    rax,QWORD PTR [rsp+0xc0]
 7f8:	mov    QWORD PTR [rsp+0x18],rax
 7fd:	mov    rax,rcx
 800:	mov    r12,rcx
 803:	jmp    50c <botlish_fn_2+0xd4>
 808:	mov    rsi,QWORD PTR [rsp+0xa8]
 810:	mov    rdi,QWORD PTR [rsp+0xa0]
 818:	call   81d <botlish_fn_2+0x3e5>
			819: R_X86_64_PLT32	rt_ascii_to_str-0x4
 81d:	mov    rbx,rax
 820:	mov    QWORD PTR [rsp],rbx
 824:	mov    rcx,r15
 827:	or     rcx,0x1
 82b:	mov    QWORD PTR [rsp+0x8],rcx
 830:	mov    rdx,r12
 833:	mov    rsi,rbx
 836:	mov    rdi,QWORD PTR [rsp+0xa0]
 83e:	call   843 <botlish_fn_2+0x40b>
			83f: R_X86_64_PLT32	rt_str_region_check-0x4
 843:	test   rax,rax
 846:	je     8a1 <botlish_fn_2+0x469>
 84c:	xor    rsi,rsi
 84f:	lea    rcx,[rsp+0x30]
 854:	mov    QWORD PTR [rsp+0x30],0x0
 85d:	mov    rax,QWORD PTR [rsp+0xc0]
 865:	mov    QWORD PTR [rsp+0x38],rax
 86a:	mov    QWORD PTR [rsp+0x40],0x1
 873:	mov    QWORD PTR [rsp+0x48],rbx
 878:	mov    QWORD PTR [rsp+0x50],r12
 87d:	or     r15,0x1
 881:	mov    QWORD PTR [rsp+0x58],r15
 886:	mov    edx,0x6
 88b:	mov    rdi,QWORD PTR [rsp+0xa0]
 893:	call   898 <botlish_fn_2+0x460>
			894: R_X86_64_PLT32	rt_construct-0x4
 898:	test   rax,rax
 89b:	jne    8d8 <botlish_fn_2+0x4a0>
 8a1:	xor    rax,rax
 8a4:	mov    rbx,QWORD PTR [rsp+0xe0]
 8ac:	mov    r12,QWORD PTR [rsp+0xe8]
 8b4:	mov    r13,QWORD PTR [rsp+0xf0]
 8bc:	mov    r14,QWORD PTR [rsp+0xf8]
 8c4:	mov    r15,QWORD PTR [rsp+0x100]
 8cc:	add    rsp,0x110
 8d3:	mov    rsp,rbp
 8d6:	pop    rbp
 8d7:	ret
 8d8:	mov    rbx,QWORD PTR [rsp+0xe0]
 8e0:	mov    r12,QWORD PTR [rsp+0xe8]
 8e8:	mov    r13,QWORD PTR [rsp+0xf0]
 8f0:	mov    r14,QWORD PTR [rsp+0xf8]
 8f8:	mov    r15,QWORD PTR [rsp+0x100]
 900:	add    rsp,0x110
 907:	mov    rsp,rbp
 90a:	pop    rbp
 90b:	ret
 90c:	add    BYTE PTR [rax],al
 90e:	add    BYTE PTR [rax],al
 910:	(bad)
 911:	add    BYTE PTR [rax],al
 913:	add    BYTE PTR [rax],al
 915:	add    BYTE PTR [rax],al
	...

0000000000000918 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 918:	push   rbp
 919:	mov    rbp,rsp
 91c:	sub    rsp,0x30
 920:	mov    QWORD PTR [rsp+0x10],rbx
 925:	mov    QWORD PTR [rsp+0x18],r12
 92a:	mov    QWORD PTR [rsp+0x20],r15
 92f:	mov    r15,rdi
 932:	mov    rsi,QWORD PTR [rdx]
 935:	mov    rbx,rdx
 938:	mov    rax,QWORD PTR [rip+0x0]        # 93f <botlish_entry_2+0x27>
			93b: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 93f:	call   rax
 941:	mov    r12,rax
 944:	mov    rsi,QWORD PTR [rbx+0x8]
 948:	mov    rax,QWORD PTR [rip+0x0]        # 94f <botlish_entry_2+0x37>
			94b: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 94f:	mov    rdi,r15
 952:	call   rax
 954:	mov    rcx,QWORD PTR [rbx+0x10]
 958:	mov    r8,QWORD PTR [rbx+0x18]
 95c:	mov    r9,QWORD PTR [rbx+0x20]
 960:	mov    rdx,QWORD PTR [rbx+0x28]
 964:	mov    QWORD PTR [rsp],rdx
 968:	mov    rdx,rax
 96b:	mov    rsi,r12
 96e:	mov    rdi,r15
 971:	call   976 <botlish_entry_2+0x5e>
			972: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 976:	mov    rbx,QWORD PTR [rsp+0x10]
 97b:	mov    r12,QWORD PTR [rsp+0x18]
 980:	mov    r15,QWORD PTR [rsp+0x20]
 985:	add    rsp,0x30
 989:	mov    rsp,rbp
 98c:	pop    rbp
 98d:	ret

000000000000098e <botlish_fn_3: replace<str, str, str>>:
 98e:	push   rbp
 98f:	mov    rbp,rsp
 992:	sub    rsp,0x30
 996:	mov    QWORD PTR [rsp+0x18],0x0
 99f:	mov    QWORD PTR [rsp+0x20],0x0
 9a8:	mov    QWORD PTR [rsp+0x28],0x0
 9b1:	mov    QWORD PTR [rsp+0x10],rcx
 9b6:	mov    eax,0x47
 9bb:	mov    r9,0xffffffffffffffff
 9c2:	bsr    r8,rdx
 9c6:	cmove  r8,r9
 9ca:	mov    r9d,0x3f
 9d0:	sub    r9,r8
 9d3:	sub    rax,r9
 9d6:	shr    rax,0x3
 9da:	test   rax,rax
 9dd:	je     a32 <botlish_fn_3+0xa4>
 9e3:	mov    r9d,0x1
 9e9:	mov    QWORD PTR [rsp+0x18],0x1
 9f2:	mov    QWORD PTR [rsp+0x20],0x1
 9fb:	mov    rax,QWORD PTR [rdi+0x10]
 9ff:	mov    rax,QWORD PTR [rax+0x18]
 a03:	mov    QWORD PTR [rsp+0x28],rax
 a08:	mov    QWORD PTR [rsp],rax
 a0c:	mov    r8,r9
 a0f:	call   a14 <botlish_fn_3+0x86>
			a10: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 a14:	test   rax,rax
 a17:	jne    a29 <botlish_fn_3+0x9b>
 a1d:	xor    rax,rax
 a20:	add    rsp,0x30
 a24:	mov    rsp,rbp
 a27:	pop    rbp
 a28:	ret
 a29:	add    rsp,0x30
 a2d:	mov    rsp,rbp
 a30:	pop    rbp
 a31:	ret
 a32:	call   a37 <botlish_fn_3+0xa9>
			a33: R_X86_64_PLT32	rt_ascii_to_str-0x4
 a37:	add    rsp,0x30
 a3b:	mov    rsp,rbp
 a3e:	pop    rbp
 a3f:	ret

0000000000000a40 <botlish_entry_3: replace<str, str, str>>:
 a40:	push   rbp
 a41:	mov    rbp,rsp
 a44:	sub    rsp,0x20
 a48:	mov    QWORD PTR [rsp],rbx
 a4c:	mov    QWORD PTR [rsp+0x8],r12
 a51:	mov    QWORD PTR [rsp+0x10],r13
 a56:	mov    QWORD PTR [rsp+0x18],r14
 a5b:	mov    r12,rdi
 a5e:	mov    rsi,QWORD PTR [rdx]
 a61:	mov    r14,rdx
 a64:	mov    r10,QWORD PTR [rip+0x0]        # a6b <botlish_entry_3+0x2b>
			a67: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 a6b:	call   r10
 a6e:	mov    rbx,r14
 a71:	mov    r13,rax
 a74:	mov    rsi,QWORD PTR [rbx+0x8]
 a78:	mov    r10,QWORD PTR [rip+0x0]        # a7f <botlish_entry_3+0x3f>
			a7b: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 a7f:	mov    rdi,r12
 a82:	call   r10
 a85:	mov    rcx,QWORD PTR [rbx+0x10]
 a89:	mov    rdx,rax
 a8c:	mov    rsi,r13
 a8f:	mov    rdi,r12
 a92:	call   a97 <botlish_entry_3+0x57>
			a93: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a97:	mov    rbx,QWORD PTR [rsp]
 a9b:	mov    r12,QWORD PTR [rsp+0x8]
 aa0:	mov    r13,QWORD PTR [rsp+0x10]
 aa5:	mov    r14,QWORD PTR [rsp+0x18]
 aaa:	add    rsp,0x20
 aae:	mov    rsp,rbp
 ab1:	pop    rbp
 ab2:	ret

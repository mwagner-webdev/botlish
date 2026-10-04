; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 3011  (per function: 224 625 1404 286 472)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> matches_at<str, str, int>
;   botlish_fn_2 / botlish_entry_2 -> replace_from<str, str, str, int, int, str>
;   botlish_fn_3 / botlish_entry_3 -> replace<str, str, str>
;   botlish_fn_4 / botlish_entry_4 -> sample<generic>


string_replace.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    QWORD PTR [rsp],rbx
   c:	mov    rbx,rdi
   f:	mov    rdi,rbx
  12:	call   17 <botlish_fn_0+0x17>
			13: R_X86_64_PLT32	botlish_fn_4-0x4 ; sample<generic>
  17:	test   rax,rax
  1a:	jne    9b <botlish_fn_0+0x9b>
  20:	mov    rdi,rbx
  23:	call   28 <botlish_fn_0+0x28>
			24: R_X86_64_PLT32	rt_declared_error-0x4
  28:	cmp    rax,0x40000002
  2e:	je     6c <botlish_fn_0+0x6c>
  34:	mov    rdi,rbx
  37:	call   3c <botlish_fn_0+0x3c>
			38: R_X86_64_PLT32	rt_declared_error-0x4
  3c:	cmp    rax,0x40000003
  42:	jne    8b <botlish_fn_0+0x8b>
  48:	mov    rdi,rbx
  4b:	call   50 <botlish_fn_0+0x50>
			4c: R_X86_64_PLT32	rt_clear_declared_error-0x4
  50:	xor    rdx,rdx
  53:	mov    rdi,rbx
  56:	mov    rsi,rdx
  59:	call   5e <botlish_fn_0+0x5e>
			5a: R_X86_64_PLT32	rt_list_new-0x4
  5e:	test   rax,rax
  61:	je     8b <botlish_fn_0+0x8b>
  67:	jmp    9b <botlish_fn_0+0x9b>
  6c:	mov    rdi,rbx
  6f:	call   74 <botlish_fn_0+0x74>
			70: R_X86_64_PLT32	rt_clear_declared_error-0x4
  74:	xor    rdx,rdx
  77:	mov    rdi,rbx
  7a:	mov    rsi,rdx
  7d:	call   82 <botlish_fn_0+0x82>
			7e: R_X86_64_PLT32	rt_list_new-0x4
  82:	test   rax,rax
  85:	jne    9b <botlish_fn_0+0x9b>
  8b:	xor    rax,rax
  8e:	mov    rbx,QWORD PTR [rsp]
  92:	add    rsp,0x10
  96:	mov    rsp,rbp
  99:	pop    rbp
  9a:	ret
  9b:	mov    rbx,QWORD PTR [rsp]
  9f:	add    rsp,0x10
  a3:	mov    rsp,rbp
  a6:	pop    rbp
  a7:	ret

00000000000000a8 <botlish_entry_0: <program entry>>:
  a8:	push   rbp
  a9:	mov    rbp,rsp
  ac:	call   b1 <botlish_entry_0+0x9>
			ad: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  b1:	mov    rsp,rbp
  b4:	pop    rbp
  b5:	ret
	...

00000000000000b8 <botlish_fn_1: matches_at<str, str, int>>:
  b8:	push   rbp
  b9:	mov    rbp,rsp
  bc:	sub    rsp,0x50
  c0:	mov    QWORD PTR [rsp+0x20],rbx
  c5:	mov    QWORD PTR [rsp+0x28],r12
  ca:	mov    QWORD PTR [rsp+0x30],r13
  cf:	mov    QWORD PTR [rsp+0x38],r14
  d4:	mov    QWORD PTR [rsp+0x40],r15
  d9:	mov    r12,rsi
  dc:	mov    r13,rcx
  df:	mov    r14,rdi
  e2:	mov    r15,rdx
  e5:	mov    QWORD PTR [rsp+0x10],0x0
  ee:	mov    QWORD PTR [rsp],rcx
  f2:	mov    edx,0x47
  f7:	mov    rcx,0xffffffffffffffff
  fe:	mov    rdi,r15
 101:	bsr    rax,rdi
 105:	cmove  rax,rcx
 109:	mov    ecx,0x3f
 10e:	sub    rcx,rax
 111:	sub    rdx,rcx
 114:	shr    rdx,0x3
 118:	shl    rdx,1
 11b:	mov    rax,rdx
 11e:	or     rax,0x1
 122:	mov    QWORD PTR [rsp+0x8],rax
 127:	mov    rcx,r13
 12a:	and    rcx,rax
 12d:	test   rcx,0x1
 134:	je     155 <botlish_fn_1+0x9d>
 13a:	mov    rax,rdx
 13d:	and    rax,0xfffffffffffffffe
 141:	mov    rcx,r13
 144:	mov    rbx,rcx
 147:	add    rbx,rax
 14a:	seto   al
 14d:	test   al,al
 14f:	je     167 <botlish_fn_1+0xaf>
 155:	or     rdx,0x1
 159:	mov    rsi,r13
 15c:	mov    rdi,r14
 15f:	call   164 <botlish_fn_1+0xac>
			160: R_X86_64_PLT32	rt_int_add-0x4
 164:	mov    rbx,rax
 167:	mov    QWORD PTR [rsp+0x8],rbx
 16c:	mov    rcx,0xffffffffffffffff
 173:	bsr    rdx,r12
 177:	cmove  rdx,rcx
 17b:	mov    ecx,0x3f
 180:	sub    rcx,rdx
 183:	mov    edx,0x47
 188:	sub    rdx,rcx
 18b:	shr    rdx,0x3
 18f:	shl    rdx,1
 192:	or     rdx,0x1
 196:	mov    rax,rbx
 199:	and    rax,rdx
 19c:	test   rax,0x1
 1a2:	jne    1c8 <botlish_fn_1+0x110>
 1a8:	mov    rsi,rbx
 1ab:	mov    rdi,r14
 1ae:	call   1b3 <botlish_fn_1+0xfb>
			1af: R_X86_64_PLT32	rt_int_cmp-0x4
 1b3:	mov    ecx,0x2
 1b8:	test   rax,rax
 1bb:	cmovg  rcx,QWORD PTR [rip+0xdd]        # 2a0 <botlish_fn_1+0x1e8>
 1c3:	jmp    1db <botlish_fn_1+0x123>
 1c8:	mov    ecx,0x2
 1cd:	mov    rax,rbx
 1d0:	cmp    rax,rdx
 1d3:	cmovg  rcx,QWORD PTR [rip+0xc5]        # 2a0 <botlish_fn_1+0x1e8>
 1db:	cmp    rcx,0x6
 1df:	je     278 <botlish_fn_1+0x1c0>
 1e5:	mov    rsi,r12
 1e8:	mov    rdi,r14
 1eb:	call   1f0 <botlish_fn_1+0x138>
			1ec: R_X86_64_PLT32	rt_ascii_to_str-0x4
 1f0:	mov    QWORD PTR [rsp+0x10],rax
 1f5:	mov    r12,rax
 1f8:	mov    rcx,rbx
 1fb:	mov    rdx,r13
 1fe:	mov    rsi,r12
 201:	mov    rdi,r14
 204:	call   209 <botlish_fn_1+0x151>
			205: R_X86_64_PLT32	rt_str_region_check-0x4
 209:	test   rax,rax
 20c:	jne    237 <botlish_fn_1+0x17f>
 212:	xor    rax,rax
 215:	mov    rbx,QWORD PTR [rsp+0x20]
 21a:	mov    r12,QWORD PTR [rsp+0x28]
 21f:	mov    r13,QWORD PTR [rsp+0x30]
 224:	mov    r14,QWORD PTR [rsp+0x38]
 229:	mov    r15,QWORD PTR [rsp+0x40]
 22e:	add    rsp,0x50
 232:	mov    rsp,rbp
 235:	pop    rbp
 236:	ret
 237:	mov    rsi,r15
 23a:	mov    rdi,r14
 23d:	call   242 <botlish_fn_1+0x18a>
			23e: R_X86_64_PLT32	rt_ascii_to_str-0x4
 242:	mov    rcx,rbx
 245:	mov    rdx,r13
 248:	mov    rsi,r12
 24b:	mov    rdi,r14
 24e:	mov    r8,rax
 251:	call   256 <botlish_fn_1+0x19e>
			252: R_X86_64_PLT32	rt_str_region_eq-0x4
 256:	mov    rbx,QWORD PTR [rsp+0x20]
 25b:	mov    r12,QWORD PTR [rsp+0x28]
 260:	mov    r13,QWORD PTR [rsp+0x30]
 265:	mov    r14,QWORD PTR [rsp+0x38]
 26a:	mov    r15,QWORD PTR [rsp+0x40]
 26f:	add    rsp,0x50
 273:	mov    rsp,rbp
 276:	pop    rbp
 277:	ret
 278:	mov    eax,0x2
 27d:	mov    rbx,QWORD PTR [rsp+0x20]
 282:	mov    r12,QWORD PTR [rsp+0x28]
 287:	mov    r13,QWORD PTR [rsp+0x30]
 28c:	mov    r14,QWORD PTR [rsp+0x38]
 291:	mov    r15,QWORD PTR [rsp+0x40]
 296:	add    rsp,0x50
 29a:	mov    rsp,rbp
 29d:	pop    rbp
 29e:	ret
 29f:	add    BYTE PTR [rsi],al
 2a1:	add    BYTE PTR [rax],al
 2a3:	add    BYTE PTR [rax],al
 2a5:	add    BYTE PTR [rax],al
	...

00000000000002a8 <botlish_entry_1: matches_at<str, str, int>>:
 2a8:	push   rbp
 2a9:	mov    rbp,rsp
 2ac:	sub    rsp,0x20
 2b0:	mov    QWORD PTR [rsp],rbx
 2b4:	mov    QWORD PTR [rsp+0x8],r12
 2b9:	mov    QWORD PTR [rsp+0x10],r13
 2be:	mov    QWORD PTR [rsp+0x18],r14
 2c3:	mov    r12,rdi
 2c6:	mov    rsi,QWORD PTR [rdx]
 2c9:	mov    r14,rdx
 2cc:	mov    r10,QWORD PTR [rip+0x0]        # 2d3 <botlish_entry_1+0x2b>
			2cf: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 2d3:	call   r10
 2d6:	mov    rbx,r14
 2d9:	mov    r13,rax
 2dc:	mov    rsi,QWORD PTR [rbx+0x8]
 2e0:	mov    r10,QWORD PTR [rip+0x0]        # 2e7 <botlish_entry_1+0x3f>
			2e3: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 2e7:	mov    rdi,r12
 2ea:	call   r10
 2ed:	mov    rcx,QWORD PTR [rbx+0x10]
 2f1:	mov    rdx,rax
 2f4:	mov    rsi,r13
 2f7:	mov    rdi,r12
 2fa:	call   2ff <botlish_entry_1+0x57>
			2fb: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 2ff:	mov    rbx,QWORD PTR [rsp]
 303:	mov    r12,QWORD PTR [rsp+0x8]
 308:	mov    r13,QWORD PTR [rsp+0x10]
 30d:	mov    r14,QWORD PTR [rsp+0x18]
 312:	add    rsp,0x20
 316:	mov    rsp,rbp
 319:	pop    rbp
 31a:	ret
 31b:	add    BYTE PTR [rax],al
 31d:	add    BYTE PTR [rax],al
	...

0000000000000320 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 320:	push   rbp
 321:	mov    rbp,rsp
 324:	sub    rsp,0x110
 32b:	mov    QWORD PTR [rsp+0xe0],rbx
 333:	mov    QWORD PTR [rsp+0xe8],r12
 33b:	mov    QWORD PTR [rsp+0xf0],r13
 343:	mov    QWORD PTR [rsp+0xf8],r14
 34b:	mov    QWORD PTR [rsp+0x100],r15
 353:	mov    QWORD PTR [rsp+0xa0],rdi
 35b:	mov    rax,QWORD PTR [rbp+0x10]
 35f:	mov    QWORD PTR [rsp+0x28],0x0
 368:	mov    QWORD PTR [rsp],rcx
 36c:	mov    r13,rcx
 36f:	mov    QWORD PTR [rsp+0x8],r8
 374:	mov    QWORD PTR [rsp+0x10],r9
 379:	mov    r12,r9
 37c:	mov    QWORD PTR [rsp+0x18],rax
 381:	mov    QWORD PTR [rsp+0xc0],rax
 389:	mov    r15d,0x47
 38f:	mov    rcx,0xffffffffffffffff
 396:	bsr    rax,rdx
 39a:	mov    QWORD PTR [rsp+0xb0],rdx
 3a2:	cmove  rax,rcx
 3a6:	mov    ecx,0x3f
 3ab:	sub    rcx,rax
 3ae:	mov    rbx,r15
 3b1:	sub    rbx,rcx
 3b4:	shr    rbx,0x3
 3b8:	shl    rbx,1
 3bb:	mov    rcx,0xffffffffffffffff
 3c2:	bsr    rax,rsi
 3c6:	mov    QWORD PTR [rsp+0xa8],rsi
 3ce:	cmove  rax,rcx
 3d2:	mov    ecx,0x3f
 3d7:	sub    rcx,rax
 3da:	sub    r15,rcx
 3dd:	shr    r15,0x3
 3e1:	shl    r15,1
 3e4:	lea    rax,[rsp+0x60]
 3e9:	mov    QWORD PTR [rsp+0xd0],rax
 3f1:	mov    rax,r8
 3f4:	mov    rcx,rbx
 3f7:	or     rcx,0x1
 3fb:	mov    QWORD PTR [rsp+0x20],rcx
 400:	mov    r14,rax
 403:	and    r14,rcx
 406:	test   r14,0x1
 40d:	jne    420 <botlish_fn_2+0x100>
 413:	mov    QWORD PTR [rsp+0xb8],rax
 41b:	jmp    440 <botlish_fn_2+0x120>
 420:	mov    rcx,rbx
 423:	and    rcx,0xfffffffffffffffe
 427:	mov    rsi,rax
 42a:	add    rsi,rcx
 42d:	mov    QWORD PTR [rsp+0xb8],rax
 435:	seto   al
 438:	test   al,al
 43a:	je     45f <botlish_fn_2+0x13f>
 440:	mov    rdx,rbx
 443:	or     rdx,0x1
 447:	mov    rsi,QWORD PTR [rsp+0xb8]
 44f:	mov    rdi,QWORD PTR [rsp+0xa0]
 457:	call   45c <botlish_fn_2+0x13c>
			458: R_X86_64_PLT32	rt_int_add-0x4
 45c:	mov    rsi,rax
 45f:	mov    rax,r15
 462:	or     rax,0x1
 466:	mov    rcx,rsi
 469:	and    rcx,rax
 46c:	test   rcx,0x1
 473:	jne    4a2 <botlish_fn_2+0x182>
 479:	mov    rdx,r15
 47c:	or     rdx,0x1
 480:	mov    rdi,QWORD PTR [rsp+0xa0]
 488:	call   48d <botlish_fn_2+0x16d>
			489: R_X86_64_PLT32	rt_int_cmp-0x4
 48d:	mov    ecx,0x2
 492:	test   rax,rax
 495:	cmovg  rcx,QWORD PTR [rip+0x35b]        # 7f8 <botlish_fn_2+0x4d8>
 49d:	jmp    4b9 <botlish_fn_2+0x199>
 4a2:	mov    rax,r15
 4a5:	or     rax,0x1
 4a9:	mov    ecx,0x2
 4ae:	cmp    rsi,rax
 4b1:	cmovg  rcx,QWORD PTR [rip+0x33f]        # 7f8 <botlish_fn_2+0x4d8>
 4b9:	cmp    rcx,0x6
 4bd:	je     6f0 <botlish_fn_2+0x3d0>
 4c3:	mov    rcx,QWORD PTR [rsp+0xb8]
 4cb:	mov    rdx,QWORD PTR [rsp+0xb0]
 4d3:	mov    rsi,QWORD PTR [rsp+0xa8]
 4db:	mov    rdi,QWORD PTR [rsp+0xa0]
 4e3:	call   4e8 <botlish_fn_2+0x1c8>
			4e4: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 4e8:	test   rax,rax
 4eb:	je     789 <botlish_fn_2+0x469>
 4f1:	cmp    rax,0x6
 4f5:	je     592 <botlish_fn_2+0x272>
 4fb:	mov    QWORD PTR [rsp+0x20],0x3
 504:	mov    rsi,QWORD PTR [rsp+0xb8]
 50c:	test   rsi,0x1
 513:	je     540 <botlish_fn_2+0x220>
 519:	mov    rsi,QWORD PTR [rsp+0xb8]
 521:	mov    rax,rsi
 524:	add    rax,0x2
 528:	seto   cl
 52b:	test   cl,cl
 52d:	jne    540 <botlish_fn_2+0x220>
 533:	mov    QWORD PTR [rsp+0xb8],rax
 53b:	jmp    562 <botlish_fn_2+0x242>
 540:	mov    edx,0x3
 545:	mov    rsi,QWORD PTR [rsp+0xb8]
 54d:	mov    rdi,QWORD PTR [rsp+0xa0]
 555:	call   55a <botlish_fn_2+0x23a>
			556: R_X86_64_PLT32	rt_int_add-0x4
 55a:	mov    QWORD PTR [rsp+0xb8],rax
 562:	mov    QWORD PTR [rsp],r13
 566:	mov    rsi,QWORD PTR [rsp+0xb8]
 56e:	mov    QWORD PTR [rsp+0x8],rsi
 573:	mov    QWORD PTR [rsp+0x10],r12
 578:	mov    rax,QWORD PTR [rsp+0xc0]
 580:	mov    QWORD PTR [rsp+0x18],rax
 585:	mov    rax,QWORD PTR [rsp+0xb8]
 58d:	jmp    3f4 <botlish_fn_2+0xd4>
 592:	mov    rsi,QWORD PTR [rsp+0xa8]
 59a:	mov    rdi,QWORD PTR [rsp+0xa0]
 5a2:	call   5a7 <botlish_fn_2+0x287>
			5a3: R_X86_64_PLT32	rt_ascii_to_str-0x4
 5a7:	mov    QWORD PTR [rsp+0x20],rax
 5ac:	mov    QWORD PTR [rsp+0xc8],rax
 5b4:	mov    rcx,QWORD PTR [rsp+0xb8]
 5bc:	mov    rdx,r12
 5bf:	mov    rsi,QWORD PTR [rsp+0xc8]
 5c7:	mov    rdi,QWORD PTR [rsp+0xa0]
 5cf:	call   5d4 <botlish_fn_2+0x2b4>
			5d0: R_X86_64_PLT32	rt_str_region_check-0x4
 5d4:	test   rax,rax
 5d7:	je     789 <botlish_fn_2+0x469>
 5dd:	mov    rax,rbx
 5e0:	or     rax,0x1
 5e4:	mov    QWORD PTR [rsp+0x28],rax
 5e9:	test   r14,0x1
 5f0:	je     618 <botlish_fn_2+0x2f8>
 5f6:	mov    rdx,rbx
 5f9:	and    rdx,0xfffffffffffffffe
 5fd:	mov    rsi,QWORD PTR [rsp+0xb8]
 605:	mov    rax,rsi
 608:	add    rax,rdx
 60b:	seto   sil
 60f:	test   sil,sil
 612:	je     634 <botlish_fn_2+0x314>
 618:	mov    rdx,rbx
 61b:	or     rdx,0x1
 61f:	mov    rsi,QWORD PTR [rsp+0xb8]
 627:	mov    rdi,QWORD PTR [rsp+0xa0]
 62f:	call   634 <botlish_fn_2+0x314>
			630: R_X86_64_PLT32	rt_int_add-0x4
 634:	mov    QWORD PTR [rsp+0x28],rax
 639:	mov    r14,rax
 63c:	mov    QWORD PTR [rsp+0x60],0x0
 645:	mov    rax,QWORD PTR [rsp+0xc0]
 64d:	mov    QWORD PTR [rsp+0x68],rax
 652:	mov    QWORD PTR [rsp+0x70],0x1
 65b:	mov    rax,QWORD PTR [rsp+0xc8]
 663:	mov    QWORD PTR [rsp+0x78],rax
 668:	mov    QWORD PTR [rsp+0x80],r12
 670:	mov    rsi,QWORD PTR [rsp+0xb8]
 678:	mov    QWORD PTR [rsp+0x88],rsi
 680:	mov    QWORD PTR [rsp+0x90],0x0
 68c:	mov    QWORD PTR [rsp+0x98],r13
 694:	mov    esi,0x2
 699:	mov    edx,0x8
 69e:	mov    rcx,QWORD PTR [rsp+0xd0]
 6a6:	mov    rdi,QWORD PTR [rsp+0xa0]
 6ae:	call   6b3 <botlish_fn_2+0x393>
			6af: R_X86_64_PLT32	rt_construct-0x4
 6b3:	mov    rcx,rax
 6b6:	mov    QWORD PTR [rsp+0xc0],rax
 6be:	test   rax,rcx
 6c1:	je     789 <botlish_fn_2+0x469>
 6c7:	mov    QWORD PTR [rsp],r13
 6cb:	mov    rcx,r14
 6ce:	mov    QWORD PTR [rsp+0x8],rcx
 6d3:	mov    QWORD PTR [rsp+0x10],rcx
 6d8:	mov    rax,QWORD PTR [rsp+0xc0]
 6e0:	mov    QWORD PTR [rsp+0x18],rax
 6e5:	mov    rax,rcx
 6e8:	mov    r12,rcx
 6eb:	jmp    3f4 <botlish_fn_2+0xd4>
 6f0:	mov    rsi,QWORD PTR [rsp+0xa8]
 6f8:	mov    rdi,QWORD PTR [rsp+0xa0]
 700:	call   705 <botlish_fn_2+0x3e5>
			701: R_X86_64_PLT32	rt_ascii_to_str-0x4
 705:	mov    rbx,rax
 708:	mov    QWORD PTR [rsp],rbx
 70c:	mov    rcx,r15
 70f:	or     rcx,0x1
 713:	mov    QWORD PTR [rsp+0x8],rcx
 718:	mov    rdx,r12
 71b:	mov    rsi,rbx
 71e:	mov    rdi,QWORD PTR [rsp+0xa0]
 726:	call   72b <botlish_fn_2+0x40b>
			727: R_X86_64_PLT32	rt_str_region_check-0x4
 72b:	test   rax,rax
 72e:	je     789 <botlish_fn_2+0x469>
 734:	xor    rsi,rsi
 737:	lea    rcx,[rsp+0x30]
 73c:	mov    QWORD PTR [rsp+0x30],0x0
 745:	mov    rax,QWORD PTR [rsp+0xc0]
 74d:	mov    QWORD PTR [rsp+0x38],rax
 752:	mov    QWORD PTR [rsp+0x40],0x1
 75b:	mov    QWORD PTR [rsp+0x48],rbx
 760:	mov    QWORD PTR [rsp+0x50],r12
 765:	or     r15,0x1
 769:	mov    QWORD PTR [rsp+0x58],r15
 76e:	mov    edx,0x6
 773:	mov    rdi,QWORD PTR [rsp+0xa0]
 77b:	call   780 <botlish_fn_2+0x460>
			77c: R_X86_64_PLT32	rt_construct-0x4
 780:	test   rax,rax
 783:	jne    7c0 <botlish_fn_2+0x4a0>
 789:	xor    rax,rax
 78c:	mov    rbx,QWORD PTR [rsp+0xe0]
 794:	mov    r12,QWORD PTR [rsp+0xe8]
 79c:	mov    r13,QWORD PTR [rsp+0xf0]
 7a4:	mov    r14,QWORD PTR [rsp+0xf8]
 7ac:	mov    r15,QWORD PTR [rsp+0x100]
 7b4:	add    rsp,0x110
 7bb:	mov    rsp,rbp
 7be:	pop    rbp
 7bf:	ret
 7c0:	mov    rbx,QWORD PTR [rsp+0xe0]
 7c8:	mov    r12,QWORD PTR [rsp+0xe8]
 7d0:	mov    r13,QWORD PTR [rsp+0xf0]
 7d8:	mov    r14,QWORD PTR [rsp+0xf8]
 7e0:	mov    r15,QWORD PTR [rsp+0x100]
 7e8:	add    rsp,0x110
 7ef:	mov    rsp,rbp
 7f2:	pop    rbp
 7f3:	ret
 7f4:	add    BYTE PTR [rax],al
 7f6:	add    BYTE PTR [rax],al
 7f8:	(bad)
 7f9:	add    BYTE PTR [rax],al
 7fb:	add    BYTE PTR [rax],al
 7fd:	add    BYTE PTR [rax],al
	...

0000000000000800 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 800:	push   rbp
 801:	mov    rbp,rsp
 804:	sub    rsp,0x30
 808:	mov    QWORD PTR [rsp+0x10],rbx
 80d:	mov    QWORD PTR [rsp+0x18],r12
 812:	mov    QWORD PTR [rsp+0x20],r15
 817:	mov    r15,rdi
 81a:	mov    rsi,QWORD PTR [rdx]
 81d:	mov    rbx,rdx
 820:	mov    rax,QWORD PTR [rip+0x0]        # 827 <botlish_entry_2+0x27>
			823: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 827:	call   rax
 829:	mov    r12,rax
 82c:	mov    rsi,QWORD PTR [rbx+0x8]
 830:	mov    rax,QWORD PTR [rip+0x0]        # 837 <botlish_entry_2+0x37>
			833: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 837:	mov    rdi,r15
 83a:	call   rax
 83c:	mov    rcx,QWORD PTR [rbx+0x10]
 840:	mov    r8,QWORD PTR [rbx+0x18]
 844:	mov    r9,QWORD PTR [rbx+0x20]
 848:	mov    rdx,QWORD PTR [rbx+0x28]
 84c:	mov    QWORD PTR [rsp],rdx
 850:	mov    rdx,rax
 853:	mov    rsi,r12
 856:	mov    rdi,r15
 859:	call   85e <botlish_entry_2+0x5e>
			85a: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 85e:	mov    rbx,QWORD PTR [rsp+0x10]
 863:	mov    r12,QWORD PTR [rsp+0x18]
 868:	mov    r15,QWORD PTR [rsp+0x20]
 86d:	add    rsp,0x30
 871:	mov    rsp,rbp
 874:	pop    rbp
 875:	ret

0000000000000876 <botlish_fn_3: replace<str, str, str>>:
 876:	push   rbp
 877:	mov    rbp,rsp
 87a:	sub    rsp,0x30
 87e:	mov    QWORD PTR [rsp+0x18],0x0
 887:	mov    QWORD PTR [rsp+0x20],0x0
 890:	mov    QWORD PTR [rsp+0x28],0x0
 899:	mov    QWORD PTR [rsp+0x10],rcx
 89e:	mov    eax,0x47
 8a3:	mov    r9,0xffffffffffffffff
 8aa:	bsr    r8,rdx
 8ae:	cmove  r8,r9
 8b2:	mov    r9d,0x3f
 8b8:	sub    r9,r8
 8bb:	sub    rax,r9
 8be:	shr    rax,0x3
 8c2:	test   rax,rax
 8c5:	je     919 <botlish_fn_3+0xa3>
 8cb:	mov    r9d,0x1
 8d1:	mov    QWORD PTR [rsp+0x18],0x1
 8da:	mov    QWORD PTR [rsp+0x20],0x1
 8e3:	mov    rax,QWORD PTR [rdi+0x10]
 8e7:	mov    rax,QWORD PTR [rax]
 8ea:	mov    QWORD PTR [rsp+0x28],rax
 8ef:	mov    QWORD PTR [rsp],rax
 8f3:	mov    r8,r9
 8f6:	call   8fb <botlish_fn_3+0x85>
			8f7: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 8fb:	test   rax,rax
 8fe:	jne    910 <botlish_fn_3+0x9a>
 904:	xor    rax,rax
 907:	add    rsp,0x30
 90b:	mov    rsp,rbp
 90e:	pop    rbp
 90f:	ret
 910:	add    rsp,0x30
 914:	mov    rsp,rbp
 917:	pop    rbp
 918:	ret
 919:	call   91e <botlish_fn_3+0xa8>
			91a: R_X86_64_PLT32	rt_ascii_to_str-0x4
 91e:	add    rsp,0x30
 922:	mov    rsp,rbp
 925:	pop    rbp
 926:	ret

0000000000000927 <botlish_entry_3: replace<str, str, str>>:
 927:	push   rbp
 928:	mov    rbp,rsp
 92b:	sub    rsp,0x20
 92f:	mov    QWORD PTR [rsp],rbx
 933:	mov    QWORD PTR [rsp+0x8],r12
 938:	mov    QWORD PTR [rsp+0x10],r13
 93d:	mov    QWORD PTR [rsp+0x18],r14
 942:	mov    r12,rdi
 945:	mov    rsi,QWORD PTR [rdx]
 948:	mov    r14,rdx
 94b:	mov    r10,QWORD PTR [rip+0x0]        # 952 <botlish_entry_3+0x2b>
			94e: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 952:	call   r10
 955:	mov    rbx,r14
 958:	mov    r13,rax
 95b:	mov    rsi,QWORD PTR [rbx+0x8]
 95f:	mov    r10,QWORD PTR [rip+0x0]        # 966 <botlish_entry_3+0x3f>
			962: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
 966:	mov    rdi,r12
 969:	call   r10
 96c:	mov    rcx,QWORD PTR [rbx+0x10]
 970:	mov    rdx,rax
 973:	mov    rsi,r13
 976:	mov    rdi,r12
 979:	call   97e <botlish_entry_3+0x57>
			97a: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 97e:	mov    rbx,QWORD PTR [rsp]
 982:	mov    r12,QWORD PTR [rsp+0x8]
 987:	mov    r13,QWORD PTR [rsp+0x10]
 98c:	mov    r14,QWORD PTR [rsp+0x18]
 991:	add    rsp,0x20
 995:	mov    rsp,rbp
 998:	pop    rbp
 999:	ret

000000000000099a <botlish_fn_4: sample<generic>>:
 99a:	push   rbp
 99b:	mov    rbp,rsp
 99e:	sub    rsp,0x80
 9a5:	mov    QWORD PTR [rsp+0x50],rbx
 9aa:	mov    QWORD PTR [rsp+0x58],r12
 9af:	mov    QWORD PTR [rsp+0x60],r13
 9b4:	mov    QWORD PTR [rsp+0x68],r14
 9b9:	mov    QWORD PTR [rsp+0x70],r15
 9be:	mov    QWORD PTR [rsp+0x8],0x0
 9c7:	mov    QWORD PTR [rsp+0x10],0x0
 9d0:	mov    QWORD PTR [rsp+0x18],0x0
 9d9:	mov    QWORD PTR [rsp+0x20],0x0
 9e2:	mov    rax,QWORD PTR [rdi+0x10]
 9e6:	mov    rbx,rdi
 9e9:	mov    rcx,QWORD PTR [rax+0x8]
 9ed:	mov    QWORD PTR [rsp],rcx
 9f1:	mov    esi,0xe3e2e1
 9f6:	mov    edx,0xf8
 9fb:	call   a00 <botlish_fn_4+0x66>
			9fc: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a00:	test   rax,rax
 a03:	je     b0f <botlish_fn_4+0x175>
 a09:	mov    QWORD PTR [rsp],rax
 a0d:	mov    rdi,rbx
 a10:	mov    r12,rax
 a13:	mov    rax,QWORD PTR [rdi+0x10]
 a17:	mov    rcx,QWORD PTR [rax+0x10]
 a1b:	mov    QWORD PTR [rsp+0x8],rcx
 a20:	mov    esi,0xe3e2e1
 a25:	mov    edx,0xe2
 a2a:	call   a2f <botlish_fn_4+0x95>
			a2b: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a2f:	test   rax,rax
 a32:	je     b0f <botlish_fn_4+0x175>
 a38:	mov    QWORD PTR [rsp+0x8],rax
 a3d:	mov    rdi,rbx
 a40:	mov    r13,rax
 a43:	mov    rax,QWORD PTR [rdi+0x10]
 a47:	mov    rcx,QWORD PTR [rax+0x18]
 a4b:	mov    QWORD PTR [rsp+0x10],rcx
 a50:	mov    esi,0xe1e1e1e1
 a55:	mov    edx,0xe1e1
 a5a:	call   a5f <botlish_fn_4+0xc5>
			a5b: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a5f:	test   rax,rax
 a62:	je     b0f <botlish_fn_4+0x175>
 a68:	mov    QWORD PTR [rsp+0x10],rax
 a6d:	mov    rdi,rbx
 a70:	mov    r14,rax
 a73:	mov    rax,QWORD PTR [rdi+0x10]
 a77:	mov    rcx,QWORD PTR [rax]
 a7a:	mov    QWORD PTR [rsp+0x18],rcx
 a7f:	movabs rsi,0xe3e2e1e3e2e1
 a89:	mov    edx,0xe3e2e1
 a8e:	call   a93 <botlish_fn_4+0xf9>
			a8f: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a93:	test   rax,rax
 a96:	je     b0f <botlish_fn_4+0x175>
 a9c:	mov    QWORD PTR [rsp+0x18],rax
 aa1:	mov    rdi,rbx
 aa4:	mov    r15,rax
 aa7:	mov    rax,QWORD PTR [rdi+0x10]
 aab:	mov    rcx,QWORD PTR [rax+0x8]
 aaf:	mov    QWORD PTR [rsp+0x20],rcx
 ab4:	xor    rsi,rsi
 ab7:	mov    edx,0xf8
 abc:	call   ac1 <botlish_fn_4+0x127>
			abd: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 ac1:	test   rax,rax
 ac4:	je     b0f <botlish_fn_4+0x175>
 aca:	mov    QWORD PTR [rsp+0x20],rax
 acf:	lea    rdx,[rsp+0x28]
 ad4:	mov    rcx,r12
 ad7:	mov    QWORD PTR [rsp+0x28],rcx
 adc:	mov    rcx,r13
 adf:	mov    QWORD PTR [rsp+0x30],rcx
 ae4:	mov    rcx,r14
 ae7:	mov    QWORD PTR [rsp+0x38],rcx
 aec:	mov    rcx,r15
 aef:	mov    QWORD PTR [rsp+0x40],rcx
 af4:	mov    QWORD PTR [rsp+0x48],rax
 af9:	mov    esi,0x5
 afe:	mov    rdi,rbx
 b01:	call   b06 <botlish_fn_4+0x16c>
			b02: R_X86_64_PLT32	rt_list_new-0x4
 b06:	test   rax,rax
 b09:	jne    b37 <botlish_fn_4+0x19d>
 b0f:	xor    rax,rax
 b12:	mov    rbx,QWORD PTR [rsp+0x50]
 b17:	mov    r12,QWORD PTR [rsp+0x58]
 b1c:	mov    r13,QWORD PTR [rsp+0x60]
 b21:	mov    r14,QWORD PTR [rsp+0x68]
 b26:	mov    r15,QWORD PTR [rsp+0x70]
 b2b:	add    rsp,0x80
 b32:	mov    rsp,rbp
 b35:	pop    rbp
 b36:	ret
 b37:	mov    rbx,QWORD PTR [rsp+0x50]
 b3c:	mov    r12,QWORD PTR [rsp+0x58]
 b41:	mov    r13,QWORD PTR [rsp+0x60]
 b46:	mov    r14,QWORD PTR [rsp+0x68]
 b4b:	mov    r15,QWORD PTR [rsp+0x70]
 b50:	add    rsp,0x80
 b57:	mov    rsp,rbp
 b5a:	pop    rbp
 b5b:	ret

0000000000000b5c <botlish_entry_4: sample<generic>>:
 b5c:	push   rbp
 b5d:	mov    rbp,rsp
 b60:	call   b65 <botlish_entry_4+0x9>
			b61: R_X86_64_PLT32	botlish_fn_4-0x4 ; sample<generic>
 b65:	mov    rsp,rbp
 b68:	pop    rbp
 b69:	ret

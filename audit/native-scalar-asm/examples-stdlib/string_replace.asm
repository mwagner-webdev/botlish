; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2737  (per function: 673 540 1132 392)
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
   4:	sub    rsp,0x60
   8:	mov    QWORD PTR [rsp+0x30],rbx
   d:	mov    QWORD PTR [rsp+0x38],r12
  12:	mov    QWORD PTR [rsp+0x40],r13
  17:	mov    QWORD PTR [rsp+0x48],r14
  1c:	mov    QWORD PTR [rsp+0x50],r15
  21:	mov    r15,QWORD PTR [rdi]
  24:	mov    rax,QWORD PTR [rdi+0x8]
  28:	lea    rcx,[r15+0x38]
  2c:	cmp    rcx,rax
  2f:	ja     256 <botlish_fn_0+0x256>
  35:	lea    rax,[r15+0x38]
  39:	mov    QWORD PTR [rdi],rax
  3c:	mov    QWORD PTR [r15+0x18],0x0
  44:	mov    QWORD PTR [r15+0x20],0x0
  4c:	mov    QWORD PTR [r15+0x28],0x0
  54:	mov    QWORD PTR [r15+0x30],0x0
  5c:	mov    rax,QWORD PTR [rdi+0x10]
  60:	mov    rsi,QWORD PTR [rax]
  63:	mov    QWORD PTR [r15],rsi
  66:	mov    rax,QWORD PTR [rdi+0x10]
  6a:	mov    rdx,QWORD PTR [rax+0x8]
  6e:	mov    QWORD PTR [r15+0x8],rdx
  72:	mov    rax,QWORD PTR [rdi+0x10]
  76:	mov    QWORD PTR [rsp+0x28],rdi
  7b:	mov    rcx,QWORD PTR [rax+0x10]
  7f:	mov    QWORD PTR [r15+0x10],rcx
  83:	call   88 <botlish_fn_0+0x88>
			84: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  88:	mov    rbx,rax
  8b:	test   rbx,rbx
  8e:	jne    9e <botlish_fn_0+0x9e>
  94:	mov    rdi,QWORD PTR [rsp+0x28]
  99:	jmp    1ff <botlish_fn_0+0x1ff>
  9e:	mov    QWORD PTR [r15],rbx
  a1:	mov    rdi,QWORD PTR [rsp+0x28]
  a6:	mov    rax,QWORD PTR [rdi+0x10]
  aa:	mov    rsi,QWORD PTR [rax]
  ad:	mov    QWORD PTR [r15+0x8],rsi
  b1:	mov    rcx,QWORD PTR [rdi+0x10]
  b5:	mov    rdx,QWORD PTR [rcx+0x18]
  b9:	mov    QWORD PTR [r15+0x10],rdx
  bd:	mov    rdi,QWORD PTR [rdi+0x10]
  c1:	mov    rcx,QWORD PTR [rdi+0x20]
  c5:	mov    QWORD PTR [r15+0x18],rcx
  c9:	mov    rdi,QWORD PTR [rsp+0x28]
  ce:	call   d3 <botlish_fn_0+0xd3>
			cf: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  d3:	mov    r12,rax
  d6:	test   r12,r12
  d9:	jne    e9 <botlish_fn_0+0xe9>
  df:	mov    rdi,QWORD PTR [rsp+0x28]
  e4:	jmp    1ff <botlish_fn_0+0x1ff>
  e9:	mov    QWORD PTR [r15+0x8],r12
  ed:	mov    rdi,QWORD PTR [rsp+0x28]
  f2:	mov    rdi,QWORD PTR [rdi+0x10]
  f6:	mov    rsi,QWORD PTR [rdi+0x28]
  fa:	mov    QWORD PTR [r15+0x10],rsi
  fe:	mov    rdi,QWORD PTR [rsp+0x28]
 103:	mov    r8,QWORD PTR [rdi+0x10]
 107:	mov    rdx,QWORD PTR [r8+0x30]
 10b:	mov    QWORD PTR [r15+0x18],rdx
 10f:	mov    r9,QWORD PTR [rdi+0x10]
 113:	mov    rcx,QWORD PTR [r9+0x18]
 117:	mov    QWORD PTR [r15+0x20],rcx
 11b:	call   120 <botlish_fn_0+0x120>
			11c: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 120:	mov    r13,rax
 123:	test   r13,r13
 126:	jne    136 <botlish_fn_0+0x136>
 12c:	mov    rdi,QWORD PTR [rsp+0x28]
 131:	jmp    1ff <botlish_fn_0+0x1ff>
 136:	mov    QWORD PTR [r15+0x10],r13
 13a:	mov    rdi,QWORD PTR [rsp+0x28]
 13f:	mov    rax,QWORD PTR [rdi+0x10]
 143:	mov    rsi,QWORD PTR [rax+0x38]
 147:	mov    QWORD PTR [r15+0x18],rsi
 14b:	mov    rax,QWORD PTR [rdi+0x10]
 14f:	mov    rdx,QWORD PTR [rax]
 152:	mov    QWORD PTR [r15+0x20],rdx
 156:	mov    rax,QWORD PTR [rdi+0x10]
 15a:	mov    rcx,QWORD PTR [rax+0x40]
 15e:	mov    QWORD PTR [r15+0x28],rcx
 162:	call   167 <botlish_fn_0+0x167>
			163: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 167:	mov    r14,rax
 16a:	test   r14,r14
 16d:	jne    17d <botlish_fn_0+0x17d>
 173:	mov    rdi,QWORD PTR [rsp+0x28]
 178:	jmp    1ff <botlish_fn_0+0x1ff>
 17d:	mov    QWORD PTR [r15+0x18],r14
 181:	mov    rdi,QWORD PTR [rsp+0x28]
 186:	mov    rax,QWORD PTR [rdi+0x10]
 18a:	mov    rsi,QWORD PTR [rax+0x40]
 18e:	mov    QWORD PTR [r15+0x20],rsi
 192:	mov    rax,QWORD PTR [rdi+0x10]
 196:	mov    rdx,QWORD PTR [rax+0x8]
 19a:	mov    QWORD PTR [r15+0x28],rdx
 19e:	mov    rax,QWORD PTR [rdi+0x10]
 1a2:	mov    rcx,QWORD PTR [rax+0x10]
 1a6:	mov    QWORD PTR [r15+0x30],rcx
 1aa:	call   1af <botlish_fn_0+0x1af>
			1ab: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 1af:	test   rax,rax
 1b2:	jne    1c2 <botlish_fn_0+0x1c2>
 1b8:	mov    rdi,QWORD PTR [rsp+0x28]
 1bd:	jmp    1ff <botlish_fn_0+0x1ff>
 1c2:	mov    QWORD PTR [r15+0x20],rax
 1c6:	lea    rdx,[rsp]
 1ca:	mov    QWORD PTR [rsp],rbx
 1ce:	mov    QWORD PTR [rsp+0x8],r12
 1d3:	mov    QWORD PTR [rsp+0x10],r13
 1d8:	mov    QWORD PTR [rsp+0x18],r14
 1dd:	mov    QWORD PTR [rsp+0x20],rax
 1e2:	mov    esi,0x5
 1e7:	mov    rdi,QWORD PTR [rsp+0x28]
 1ec:	call   1f1 <botlish_fn_0+0x1f1>
			1ed: R_X86_64_PLT32	rt_list_new-0x4
 1f1:	test   rax,rax
 1f4:	jne    22c <botlish_fn_0+0x22c>
 1fa:	mov    rdi,QWORD PTR [rsp+0x28]
 1ff:	mov    rdi,QWORD PTR [rsp+0x28]
 204:	mov    QWORD PTR [rdi],r15
 207:	xor    rax,rax
 20a:	mov    rbx,QWORD PTR [rsp+0x30]
 20f:	mov    r12,QWORD PTR [rsp+0x38]
 214:	mov    r13,QWORD PTR [rsp+0x40]
 219:	mov    r14,QWORD PTR [rsp+0x48]
 21e:	mov    r15,QWORD PTR [rsp+0x50]
 223:	add    rsp,0x60
 227:	mov    rsp,rbp
 22a:	pop    rbp
 22b:	ret
 22c:	mov    rdi,QWORD PTR [rsp+0x28]
 231:	mov    QWORD PTR [rdi],r15
 234:	mov    rbx,QWORD PTR [rsp+0x30]
 239:	mov    r12,QWORD PTR [rsp+0x38]
 23e:	mov    r13,QWORD PTR [rsp+0x40]
 243:	mov    r14,QWORD PTR [rsp+0x48]
 248:	mov    r15,QWORD PTR [rsp+0x50]
 24d:	add    rsp,0x60
 251:	mov    rsp,rbp
 254:	pop    rbp
 255:	ret
 256:	mov    QWORD PTR [rsp+0x28],rdi
 25b:	call   260 <botlish_fn_0+0x260>
			25c: R_X86_64_PLT32	rt_stack_overflow-0x4
 260:	xor    rax,rax
 263:	mov    rbx,QWORD PTR [rsp+0x30]
 268:	mov    r12,QWORD PTR [rsp+0x38]
 26d:	mov    r13,QWORD PTR [rsp+0x40]
 272:	mov    r14,QWORD PTR [rsp+0x48]
 277:	mov    r15,QWORD PTR [rsp+0x50]
 27c:	add    rsp,0x60
 280:	mov    rsp,rbp
 283:	pop    rbp
 284:	ret

0000000000000285 <botlish_entry_0: <program entry>>:
 285:	push   rbp
 286:	mov    rbp,rsp
 289:	call   28e <botlish_entry_0+0x9>
			28a: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 28e:	mov    rsp,rbp
 291:	pop    rbp
 292:	ret
 293:	add    BYTE PTR [rax],al
 295:	add    BYTE PTR [rax],al
	...

0000000000000298 <botlish_fn_1: matches_at<str, str, int>>:
 298:	push   rbp
 299:	mov    rbp,rsp
 29c:	sub    rsp,0x60
 2a0:	mov    QWORD PTR [rsp+0x30],rbx
 2a5:	mov    QWORD PTR [rsp+0x38],r12
 2aa:	mov    QWORD PTR [rsp+0x40],r13
 2af:	mov    QWORD PTR [rsp+0x48],r14
 2b4:	mov    QWORD PTR [rsp+0x50],r15
 2b9:	mov    rbx,QWORD PTR [rdi+0x20]
 2bd:	mov    r14,QWORD PTR [rdi+0x28]
 2c1:	lea    rax,[rsp]
 2c5:	mov    QWORD PTR [rdi+0x20],rax
 2c9:	mov    QWORD PTR [rdi+0x28],0x4
 2d1:	mov    QWORD PTR [rsp],rsi
 2d5:	mov    QWORD PTR [rsp+0x20],rsi
 2da:	mov    QWORD PTR [rsp+0x8],rdx
 2df:	mov    QWORD PTR [rsp+0x28],rdx
 2e4:	mov    QWORD PTR [rsp+0x10],rcx
 2e9:	mov    r13,rcx
 2ec:	mov    r12,rdi
 2ef:	mov    rsi,QWORD PTR [rsp+0x28]
 2f4:	call   2f9 <botlish_fn_1+0x61>
			2f5: R_X86_64_PLT32	rt_str_len-0x4
 2f9:	mov    QWORD PTR [rsp+0x18],rax
 2fe:	mov    rcx,r13
 301:	and    rcx,rax
 304:	test   rcx,0x1
 30b:	jne    319 <botlish_fn_1+0x81>
 311:	mov    rdx,rax
 314:	jmp    334 <botlish_fn_1+0x9c>
 319:	lea    rcx,[rax-0x1]
 31d:	mov    rdx,rax
 320:	mov    rax,r13
 323:	add    rax,rcx
 326:	mov    r15,rax
 329:	seto   al
 32c:	test   al,al
 32e:	je     342 <botlish_fn_1+0xaa>
 334:	mov    rsi,r13
 337:	mov    rdi,r12
 33a:	call   33f <botlish_fn_1+0xa7>
			33b: R_X86_64_PLT32	rt_int_add-0x4
 33f:	mov    r15,rax
 342:	mov    rsi,QWORD PTR [rsp+0x20]
 347:	mov    rdi,r12
 34a:	call   34f <botlish_fn_1+0xb7>
			34b: R_X86_64_PLT32	rt_str_len-0x4
 34f:	mov    rcx,r15
 352:	and    rcx,rax
 355:	mov    rdx,rax
 358:	test   rcx,0x1
 35f:	jne    385 <botlish_fn_1+0xed>
 365:	mov    rsi,r15
 368:	mov    rdi,r12
 36b:	call   370 <botlish_fn_1+0xd8>
			36c: R_X86_64_PLT32	rt_int_cmp-0x4
 370:	mov    ecx,0x2
 375:	test   rax,rax
 378:	cmovg  rcx,QWORD PTR [rip+0xe8]        # 468 <botlish_fn_1+0x1d0>
 380:	jmp    398 <botlish_fn_1+0x100>
 385:	mov    ecx,0x2
 38a:	mov    rax,r15
 38d:	cmp    rax,rdx
 390:	cmovg  rcx,QWORD PTR [rip+0xd0]        # 468 <botlish_fn_1+0x1d0>
 398:	cmp    rcx,0x6
 39c:	je     431 <botlish_fn_1+0x199>
 3a2:	mov    rcx,r15
 3a5:	mov    rdx,r13
 3a8:	mov    rsi,QWORD PTR [rsp+0x20]
 3ad:	mov    rdi,r12
 3b0:	call   3b5 <botlish_fn_1+0x11d>
			3b1: R_X86_64_PLT32	rt_str_region_check-0x4
 3b5:	test   rax,rax
 3b8:	jne    3ed <botlish_fn_1+0x155>
 3be:	mov    QWORD PTR [r12+0x20],rbx
 3c3:	mov    QWORD PTR [r12+0x28],r14
 3c8:	xor    rax,rax
 3cb:	mov    rbx,QWORD PTR [rsp+0x30]
 3d0:	mov    r12,QWORD PTR [rsp+0x38]
 3d5:	mov    r13,QWORD PTR [rsp+0x40]
 3da:	mov    r14,QWORD PTR [rsp+0x48]
 3df:	mov    r15,QWORD PTR [rsp+0x50]
 3e4:	add    rsp,0x60
 3e8:	mov    rsp,rbp
 3eb:	pop    rbp
 3ec:	ret
 3ed:	mov    rcx,r15
 3f0:	mov    rdx,r13
 3f3:	mov    rsi,QWORD PTR [rsp+0x20]
 3f8:	mov    r8,QWORD PTR [rsp+0x28]
 3fd:	mov    rdi,r12
 400:	call   405 <botlish_fn_1+0x16d>
			401: R_X86_64_PLT32	rt_str_region_eq-0x4
 405:	mov    QWORD PTR [r12+0x20],rbx
 40a:	mov    QWORD PTR [r12+0x28],r14
 40f:	mov    rbx,QWORD PTR [rsp+0x30]
 414:	mov    r12,QWORD PTR [rsp+0x38]
 419:	mov    r13,QWORD PTR [rsp+0x40]
 41e:	mov    r14,QWORD PTR [rsp+0x48]
 423:	mov    r15,QWORD PTR [rsp+0x50]
 428:	add    rsp,0x60
 42c:	mov    rsp,rbp
 42f:	pop    rbp
 430:	ret
 431:	mov    QWORD PTR [r12+0x20],rbx
 436:	mov    QWORD PTR [r12+0x28],r14
 43b:	mov    eax,0x2
 440:	mov    rbx,QWORD PTR [rsp+0x30]
 445:	mov    r12,QWORD PTR [rsp+0x38]
 44a:	mov    r13,QWORD PTR [rsp+0x40]
 44f:	mov    r14,QWORD PTR [rsp+0x48]
 454:	mov    r15,QWORD PTR [rsp+0x50]
 459:	add    rsp,0x60
 45d:	mov    rsp,rbp
 460:	pop    rbp
 461:	ret
 462:	add    BYTE PTR [rax],al
 464:	add    BYTE PTR [rax],al
 466:	add    BYTE PTR [rax],al
 468:	(bad)
 469:	add    BYTE PTR [rax],al
 46b:	add    BYTE PTR [rax],al
 46d:	add    BYTE PTR [rax],al
	...

0000000000000470 <botlish_entry_1: matches_at<str, str, int>>:
 470:	push   rbp
 471:	mov    rbp,rsp
 474:	mov    rsi,QWORD PTR [rdx]
 477:	mov    r8,QWORD PTR [rdx+0x8]
 47b:	mov    rcx,QWORD PTR [rdx+0x10]
 47f:	mov    rdx,r8
 482:	call   487 <botlish_entry_1+0x17>
			483: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 487:	mov    rsp,rbp
 48a:	pop    rbp
 48b:	ret
 48c:	add    BYTE PTR [rax],al
	...

0000000000000490 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 490:	push   rbp
 491:	mov    rbp,rsp
 494:	sub    rsp,0x50
 498:	mov    QWORD PTR [rsp+0x20],rbx
 49d:	mov    QWORD PTR [rsp+0x28],r12
 4a2:	mov    QWORD PTR [rsp+0x30],r13
 4a7:	mov    QWORD PTR [rsp+0x38],r14
 4ac:	mov    QWORD PTR [rsp+0x40],r15
 4b1:	mov    r10,QWORD PTR [rbp+0x10]
 4b5:	mov    r13,QWORD PTR [rdi]
 4b8:	mov    rax,QWORD PTR [rdi+0x8]
 4bc:	lea    r11,[r13+0x38]
 4c0:	cmp    r11,rax
 4c3:	ja     835 <botlish_fn_2+0x3a5>
 4c9:	lea    rax,[r13+0x38]
 4cd:	mov    QWORD PTR [rdi],rax
 4d0:	mov    r14,rdi
 4d3:	mov    QWORD PTR [r13+0x0],rsi
 4d7:	mov    r15,rsi
 4da:	mov    QWORD PTR [r13+0x8],rdx
 4de:	mov    QWORD PTR [r13+0x10],rcx
 4e2:	mov    rbx,rcx
 4e5:	mov    QWORD PTR [r13+0x18],r8
 4e9:	mov    QWORD PTR [r13+0x20],r9
 4ed:	mov    QWORD PTR [r13+0x28],r10
 4f1:	mov    QWORD PTR [rsp+0x10],r10
 4f6:	mov    r12,rdx
 4f9:	mov    QWORD PTR [rsp],r8
 4fd:	mov    QWORD PTR [rsp+0x8],r9
 502:	mov    rsi,r12
 505:	mov    rdi,r14
 508:	call   50d <botlish_fn_2+0x7d>
			509: R_X86_64_PLT32	rt_str_len-0x4
 50d:	mov    QWORD PTR [r13+0x30],rax
 511:	mov    rsi,QWORD PTR [rsp]
 515:	mov    rdx,rsi
 518:	and    rdx,rax
 51b:	test   rdx,0x1
 522:	jne    534 <botlish_fn_2+0xa4>
 528:	mov    rdx,rax
 52b:	mov    QWORD PTR [rsp],rsi
 52f:	jmp    557 <botlish_fn_2+0xc7>
 534:	lea    rdi,[rax-0x1]
 538:	mov    rdx,rax
 53b:	mov    rax,rsi
 53e:	add    rax,rdi
 541:	mov    QWORD PTR [rsp],rsi
 545:	mov    QWORD PTR [rsp+0x18],rax
 54a:	seto   sil
 54e:	test   sil,sil
 551:	je     568 <botlish_fn_2+0xd8>
 557:	mov    rsi,QWORD PTR [rsp]
 55b:	mov    rdi,r14
 55e:	call   563 <botlish_fn_2+0xd3>
			55f: R_X86_64_PLT32	rt_int_add-0x4
 563:	mov    QWORD PTR [rsp+0x18],rax
 568:	mov    rsi,r15
 56b:	mov    rdi,r14
 56e:	call   573 <botlish_fn_2+0xe3>
			56f: R_X86_64_PLT32	rt_str_len-0x4
 573:	mov    rsi,QWORD PTR [rsp+0x18]
 578:	mov    r10,rsi
 57b:	and    r10,rax
 57e:	mov    rdx,rax
 581:	test   r10,0x1
 588:	jne    5ab <botlish_fn_2+0x11b>
 58e:	mov    rdi,r14
 591:	call   596 <botlish_fn_2+0x106>
			592: R_X86_64_PLT32	rt_int_cmp-0x4
 596:	mov    ecx,0x2
 59b:	test   rax,rax
 59e:	cmovg  rcx,QWORD PTR [rip+0x2c2]        # 868 <botlish_fn_2+0x3d8>
 5a6:	jmp    5bb <botlish_fn_2+0x12b>
 5ab:	mov    ecx,0x2
 5b0:	cmp    rsi,rdx
 5b3:	cmovg  rcx,QWORD PTR [rip+0x2ad]        # 868 <botlish_fn_2+0x3d8>
 5bb:	cmp    rcx,0x6
 5bf:	je     78f <botlish_fn_2+0x2ff>
 5c5:	mov    rcx,QWORD PTR [rsp]
 5c9:	mov    rdx,r12
 5cc:	mov    rsi,r15
 5cf:	mov    rdi,r14
 5d2:	call   5d7 <botlish_fn_2+0x147>
			5d3: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 5d7:	test   rax,rax
 5da:	jne    5e8 <botlish_fn_2+0x158>
 5e0:	mov    rdi,r14
 5e3:	jmp    7e2 <botlish_fn_2+0x352>
 5e8:	cmp    rax,0x6
 5ec:	je     673 <botlish_fn_2+0x1e3>
 5f2:	mov    QWORD PTR [r13+0x30],0x3
 5fa:	mov    rsi,QWORD PTR [rsp]
 5fe:	test   rsi,0x1
 605:	je     62d <botlish_fn_2+0x19d>
 60b:	mov    rsi,QWORD PTR [rsp]
 60f:	mov    rax,rsi
 612:	add    rax,0x2
 616:	seto   cl
 619:	test   cl,cl
 61b:	jne    62d <botlish_fn_2+0x19d>
 621:	mov    rsi,r15
 624:	mov    QWORD PTR [rsp],rax
 628:	jmp    645 <botlish_fn_2+0x1b5>
 62d:	mov    edx,0x3
 632:	mov    rsi,QWORD PTR [rsp]
 636:	mov    rdi,r14
 639:	call   63e <botlish_fn_2+0x1ae>
			63a: R_X86_64_PLT32	rt_int_add-0x4
 63e:	mov    rsi,r15
 641:	mov    QWORD PTR [rsp],rax
 645:	mov    rsi,r15
 648:	mov    QWORD PTR [r13+0x0],rsi
 64c:	mov    QWORD PTR [r13+0x8],r12
 650:	mov    QWORD PTR [r13+0x10],rbx
 654:	mov    rsi,QWORD PTR [rsp]
 658:	mov    QWORD PTR [r13+0x18],rsi
 65c:	mov    rdx,QWORD PTR [rsp+0x8]
 661:	mov    QWORD PTR [r13+0x20],rdx
 665:	mov    rsi,QWORD PTR [rsp+0x10]
 66a:	mov    QWORD PTR [r13+0x28],rsi
 66e:	jmp    502 <botlish_fn_2+0x72>
 673:	mov    rdx,QWORD PTR [rsp+0x8]
 678:	mov    rcx,QWORD PTR [rsp]
 67c:	mov    rsi,r15
 67f:	mov    rdi,r14
 682:	call   687 <botlish_fn_2+0x1f7>
			683: R_X86_64_PLT32	rt_substr-0x4
 687:	test   rax,rax
 68a:	jne    698 <botlish_fn_2+0x208>
 690:	mov    rdi,r14
 693:	jmp    7e2 <botlish_fn_2+0x352>
 698:	mov    QWORD PTR [r13+0x20],rax
 69c:	mov    rdx,rax
 69f:	mov    rsi,QWORD PTR [rsp+0x10]
 6a4:	mov    rdi,r14
 6a7:	call   6ac <botlish_fn_2+0x21c>
			6a8: R_X86_64_PLT32	rt_str_cat-0x4
 6ac:	test   rax,rax
 6af:	jne    6bd <botlish_fn_2+0x22d>
 6b5:	mov    rdi,r14
 6b8:	jmp    7e2 <botlish_fn_2+0x352>
 6bd:	mov    QWORD PTR [r13+0x20],rax
 6c1:	mov    QWORD PTR [rsp+0x18],rax
 6c6:	mov    rsi,r12
 6c9:	mov    rdi,r14
 6cc:	call   6d1 <botlish_fn_2+0x241>
			6cd: R_X86_64_PLT32	rt_str_len-0x4
 6d1:	mov    QWORD PTR [r13+0x28],rax
 6d5:	mov    rsi,QWORD PTR [rsp]
 6d9:	mov    rcx,rsi
 6dc:	and    rcx,rax
 6df:	test   rcx,0x1
 6e6:	jne    6f8 <botlish_fn_2+0x268>
 6ec:	mov    rdx,rax
 6ef:	mov    rsi,QWORD PTR [rsp]
 6f3:	jmp    729 <botlish_fn_2+0x299>
 6f8:	lea    rcx,[rax-0x1]
 6fc:	mov    rdx,rax
 6ff:	mov    rsi,QWORD PTR [rsp]
 703:	mov    rax,rsi
 706:	add    rax,rcx
 709:	seto   cl
 70c:	test   cl,cl
 70e:	je     71d <botlish_fn_2+0x28d>
 714:	mov    rsi,QWORD PTR [rsp]
 718:	jmp    729 <botlish_fn_2+0x299>
 71d:	mov    rsi,rax
 720:	mov    QWORD PTR [rsp],rax
 724:	jmp    738 <botlish_fn_2+0x2a8>
 729:	mov    rdi,r14
 72c:	call   731 <botlish_fn_2+0x2a1>
			72d: R_X86_64_PLT32	rt_int_add-0x4
 731:	mov    rsi,rax
 734:	mov    QWORD PTR [rsp],rax
 738:	mov    QWORD PTR [r13+0x18],rsi
 73c:	mov    rsi,QWORD PTR [rsp+0x18]
 741:	mov    rdx,rbx
 744:	mov    rdi,r14
 747:	call   74c <botlish_fn_2+0x2bc>
			748: R_X86_64_PLT32	rt_str_cat-0x4
 74c:	test   rax,rax
 74f:	jne    75d <botlish_fn_2+0x2cd>
 755:	mov    rdi,r14
 758:	jmp    7e2 <botlish_fn_2+0x352>
 75d:	mov    rsi,r15
 760:	mov    QWORD PTR [r13+0x0],rsi
 764:	mov    QWORD PTR [r13+0x8],r12
 768:	mov    QWORD PTR [r13+0x10],rbx
 76c:	mov    rsi,QWORD PTR [rsp]
 770:	mov    QWORD PTR [r13+0x18],rsi
 774:	mov    QWORD PTR [r13+0x20],rsi
 778:	mov    QWORD PTR [r13+0x28],rax
 77c:	mov    rcx,QWORD PTR [rsp]
 780:	mov    QWORD PTR [rsp+0x8],rcx
 785:	mov    QWORD PTR [rsp+0x10],rax
 78a:	jmp    502 <botlish_fn_2+0x72>
 78f:	mov    rsi,r15
 792:	mov    rdi,r14
 795:	call   79a <botlish_fn_2+0x30a>
			796: R_X86_64_PLT32	rt_str_len-0x4
 79a:	mov    QWORD PTR [r13+0x8],rax
 79e:	mov    rcx,rax
 7a1:	mov    rdx,QWORD PTR [rsp+0x8]
 7a6:	mov    rsi,r15
 7a9:	mov    rdi,r14
 7ac:	call   7b1 <botlish_fn_2+0x321>
			7ad: R_X86_64_PLT32	rt_substr-0x4
 7b1:	test   rax,rax
 7b4:	jne    7c2 <botlish_fn_2+0x332>
 7ba:	mov    rdi,r14
 7bd:	jmp    7e2 <botlish_fn_2+0x352>
 7c2:	mov    QWORD PTR [r13+0x0],rax
 7c6:	mov    rdx,rax
 7c9:	mov    rsi,QWORD PTR [rsp+0x10]
 7ce:	mov    rdi,r14
 7d1:	call   7d6 <botlish_fn_2+0x346>
			7d2: R_X86_64_PLT32	rt_str_cat-0x4
 7d6:	test   rax,rax
 7d9:	jne    80d <botlish_fn_2+0x37d>
 7df:	mov    rdi,r14
 7e2:	mov    rdi,r14
 7e5:	mov    QWORD PTR [rdi],r13
 7e8:	xor    rax,rax
 7eb:	mov    rbx,QWORD PTR [rsp+0x20]
 7f0:	mov    r12,QWORD PTR [rsp+0x28]
 7f5:	mov    r13,QWORD PTR [rsp+0x30]
 7fa:	mov    r14,QWORD PTR [rsp+0x38]
 7ff:	mov    r15,QWORD PTR [rsp+0x40]
 804:	add    rsp,0x50
 808:	mov    rsp,rbp
 80b:	pop    rbp
 80c:	ret
 80d:	mov    rdi,r14
 810:	mov    QWORD PTR [rdi],r13
 813:	mov    rbx,QWORD PTR [rsp+0x20]
 818:	mov    r12,QWORD PTR [rsp+0x28]
 81d:	mov    r13,QWORD PTR [rsp+0x30]
 822:	mov    r14,QWORD PTR [rsp+0x38]
 827:	mov    r15,QWORD PTR [rsp+0x40]
 82c:	add    rsp,0x50
 830:	mov    rsp,rbp
 833:	pop    rbp
 834:	ret
 835:	mov    r14,rdi
 838:	call   83d <botlish_fn_2+0x3ad>
			839: R_X86_64_PLT32	rt_stack_overflow-0x4
 83d:	xor    rax,rax
 840:	mov    rbx,QWORD PTR [rsp+0x20]
 845:	mov    r12,QWORD PTR [rsp+0x28]
 84a:	mov    r13,QWORD PTR [rsp+0x30]
 84f:	mov    r14,QWORD PTR [rsp+0x38]
 854:	mov    r15,QWORD PTR [rsp+0x40]
 859:	add    rsp,0x50
 85d:	mov    rsp,rbp
 860:	pop    rbp
 861:	ret
 862:	add    BYTE PTR [rax],al
 864:	add    BYTE PTR [rax],al
 866:	add    BYTE PTR [rax],al
 868:	(bad)
 869:	add    BYTE PTR [rax],al
 86b:	add    BYTE PTR [rax],al
 86d:	add    BYTE PTR [rax],al
	...

0000000000000870 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 870:	push   rbp
 871:	mov    rbp,rsp
 874:	sub    rsp,0x10
 878:	mov    rsi,QWORD PTR [rdx]
 87b:	mov    r10,QWORD PTR [rdx+0x8]
 87f:	mov    rcx,QWORD PTR [rdx+0x10]
 883:	mov    r8,QWORD PTR [rdx+0x18]
 887:	mov    r9,QWORD PTR [rdx+0x20]
 88b:	mov    r11,QWORD PTR [rdx+0x28]
 88f:	mov    QWORD PTR [rsp],r11
 893:	mov    rdx,r10
 896:	call   89b <botlish_entry_2+0x2b>
			897: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 89b:	add    rsp,0x10
 89f:	mov    rsp,rbp
 8a2:	pop    rbp
 8a3:	ret

00000000000008a4 <botlish_fn_3: replace<str, str, str>>:
 8a4:	push   rbp
 8a5:	mov    rbp,rsp
 8a8:	sub    rsp,0x40
 8ac:	mov    QWORD PTR [rsp+0x10],rbx
 8b1:	mov    QWORD PTR [rsp+0x18],r12
 8b6:	mov    QWORD PTR [rsp+0x20],r13
 8bb:	mov    QWORD PTR [rsp+0x28],r14
 8c0:	mov    QWORD PTR [rsp+0x30],r15
 8c5:	mov    r13,rsi
 8c8:	mov    r15,rdx
 8cb:	mov    rbx,QWORD PTR [rdi]
 8ce:	mov    rax,QWORD PTR [rdi+0x8]
 8d2:	lea    rdx,[rbx+0x30]
 8d6:	cmp    rdx,rax
 8d9:	ja     9d5 <botlish_fn_3+0x131>
 8df:	lea    rax,[rbx+0x30]
 8e3:	mov    QWORD PTR [rdi],rax
 8e6:	mov    rsi,r13
 8e9:	mov    r12,rdi
 8ec:	mov    QWORD PTR [rbx],rsi
 8ef:	mov    rdx,r15
 8f2:	mov    QWORD PTR [rbx+0x8],rdx
 8f6:	mov    QWORD PTR [rbx+0x10],rcx
 8fa:	mov    r14,rcx
 8fd:	mov    rsi,r15
 900:	mov    rdi,r12
 903:	call   908 <botlish_fn_3+0x64>
			904: R_X86_64_PLT32	rt_str_len-0x4
 908:	sar    rax,1
 90b:	test   rax,rax
 90e:	je     9aa <botlish_fn_3+0x106>
 914:	mov    r9d,0x1
 91a:	mov    QWORD PTR [rbx+0x18],0x1
 922:	mov    QWORD PTR [rbx+0x20],0x1
 92a:	mov    rdi,r12
 92d:	mov    rax,QWORD PTR [rdi+0x10]
 931:	mov    rax,QWORD PTR [rax+0x40]
 935:	mov    QWORD PTR [rbx+0x28],rax
 939:	mov    QWORD PTR [rsp],rax
 93d:	mov    rcx,r14
 940:	mov    rdx,r15
 943:	mov    rsi,r13
 946:	mov    r8,r9
 949:	call   94e <botlish_fn_3+0xaa>
			94a: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 94e:	test   rax,rax
 951:	jne    982 <botlish_fn_3+0xde>
 957:	mov    rdi,r12
 95a:	mov    QWORD PTR [rdi],rbx
 95d:	xor    rax,rax
 960:	mov    rbx,QWORD PTR [rsp+0x10]
 965:	mov    r12,QWORD PTR [rsp+0x18]
 96a:	mov    r13,QWORD PTR [rsp+0x20]
 96f:	mov    r14,QWORD PTR [rsp+0x28]
 974:	mov    r15,QWORD PTR [rsp+0x30]
 979:	add    rsp,0x40
 97d:	mov    rsp,rbp
 980:	pop    rbp
 981:	ret
 982:	mov    rdi,r12
 985:	mov    QWORD PTR [rdi],rbx
 988:	mov    rbx,QWORD PTR [rsp+0x10]
 98d:	mov    r12,QWORD PTR [rsp+0x18]
 992:	mov    r13,QWORD PTR [rsp+0x20]
 997:	mov    r14,QWORD PTR [rsp+0x28]
 99c:	mov    r15,QWORD PTR [rsp+0x30]
 9a1:	add    rsp,0x40
 9a5:	mov    rsp,rbp
 9a8:	pop    rbp
 9a9:	ret
 9aa:	mov    rdi,r12
 9ad:	mov    QWORD PTR [rdi],rbx
 9b0:	mov    rax,r13
 9b3:	mov    rbx,QWORD PTR [rsp+0x10]
 9b8:	mov    r12,QWORD PTR [rsp+0x18]
 9bd:	mov    r13,QWORD PTR [rsp+0x20]
 9c2:	mov    r14,QWORD PTR [rsp+0x28]
 9c7:	mov    r15,QWORD PTR [rsp+0x30]
 9cc:	add    rsp,0x40
 9d0:	mov    rsp,rbp
 9d3:	pop    rbp
 9d4:	ret
 9d5:	mov    r12,rdi
 9d8:	call   9dd <botlish_fn_3+0x139>
			9d9: R_X86_64_PLT32	rt_stack_overflow-0x4
 9dd:	xor    rax,rax
 9e0:	mov    rbx,QWORD PTR [rsp+0x10]
 9e5:	mov    r12,QWORD PTR [rsp+0x18]
 9ea:	mov    r13,QWORD PTR [rsp+0x20]
 9ef:	mov    r14,QWORD PTR [rsp+0x28]
 9f4:	mov    r15,QWORD PTR [rsp+0x30]
 9f9:	add    rsp,0x40
 9fd:	mov    rsp,rbp
 a00:	pop    rbp
 a01:	ret

0000000000000a02 <botlish_entry_3: replace<str, str, str>>:
 a02:	push   rbp
 a03:	mov    rbp,rsp
 a06:	mov    rsi,QWORD PTR [rdx]
 a09:	mov    r8,QWORD PTR [rdx+0x8]
 a0d:	mov    rcx,QWORD PTR [rdx+0x10]
 a11:	mov    rdx,r8
 a14:	call   a19 <botlish_entry_3+0x17>
			a15: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a19:	mov    rsp,rbp
 a1c:	pop    rbp
 a1d:	ret

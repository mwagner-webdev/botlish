; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2777  (per function: 673 580 1132 392)
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
 29c:	sub    rsp,0x40
 2a0:	mov    QWORD PTR [rsp+0x10],rbx
 2a5:	mov    QWORD PTR [rsp+0x18],r12
 2aa:	mov    QWORD PTR [rsp+0x20],r13
 2af:	mov    QWORD PTR [rsp+0x28],r14
 2b4:	mov    QWORD PTR [rsp+0x30],r15
 2b9:	mov    r12,QWORD PTR [rdi]
 2bc:	mov    rax,QWORD PTR [rdi+0x8]
 2c0:	lea    r8,[r12+0x20]
 2c5:	cmp    r8,rax
 2c8:	ja     454 <botlish_fn_1+0x1bc>
 2ce:	lea    rax,[r12+0x20]
 2d3:	mov    QWORD PTR [rdi],rax
 2d6:	mov    r14,rdi
 2d9:	mov    QWORD PTR [r12],rsi
 2dd:	mov    QWORD PTR [rsp],rsi
 2e1:	mov    QWORD PTR [r12+0x8],rdx
 2e6:	mov    r15,rdx
 2e9:	mov    QWORD PTR [r12+0x10],rcx
 2ee:	mov    rbx,rcx
 2f1:	mov    rsi,r15
 2f4:	mov    rdi,r14
 2f7:	call   2fc <botlish_fn_1+0x64>
			2f8: R_X86_64_PLT32	rt_str_len-0x4
 2fc:	mov    QWORD PTR [r12+0x18],rax
 301:	mov    rcx,rbx
 304:	and    rcx,rax
 307:	test   rcx,0x1
 30e:	jne    31c <botlish_fn_1+0x84>
 314:	mov    rdx,rax
 317:	jmp    337 <botlish_fn_1+0x9f>
 31c:	lea    rcx,[rax-0x1]
 320:	mov    rdx,rax
 323:	mov    rax,rbx
 326:	add    rax,rcx
 329:	mov    r13,rax
 32c:	seto   al
 32f:	test   al,al
 331:	je     345 <botlish_fn_1+0xad>
 337:	mov    rsi,rbx
 33a:	mov    rdi,r14
 33d:	call   342 <botlish_fn_1+0xaa>
			33e: R_X86_64_PLT32	rt_int_add-0x4
 342:	mov    r13,rax
 345:	mov    rsi,QWORD PTR [rsp]
 349:	mov    rdi,r14
 34c:	call   351 <botlish_fn_1+0xb9>
			34d: R_X86_64_PLT32	rt_str_len-0x4
 351:	mov    rcx,r13
 354:	and    rcx,rax
 357:	mov    rdx,rax
 35a:	test   rcx,0x1
 361:	jne    387 <botlish_fn_1+0xef>
 367:	mov    rsi,r13
 36a:	mov    rdi,r14
 36d:	call   372 <botlish_fn_1+0xda>
			36e: R_X86_64_PLT32	rt_int_cmp-0x4
 372:	mov    ecx,0x2
 377:	test   rax,rax
 37a:	cmovg  rcx,QWORD PTR [rip+0x106]        # 488 <botlish_fn_1+0x1f0>
 382:	jmp    39a <botlish_fn_1+0x102>
 387:	mov    ecx,0x2
 38c:	mov    rax,r13
 38f:	cmp    rax,rdx
 392:	cmovg  rcx,QWORD PTR [rip+0xee]        # 488 <botlish_fn_1+0x1f0>
 39a:	cmp    rcx,0x6
 39e:	je     427 <botlish_fn_1+0x18f>
 3a4:	mov    rcx,r13
 3a7:	mov    rdx,rbx
 3aa:	mov    rsi,QWORD PTR [rsp]
 3ae:	mov    rdi,r14
 3b1:	call   3b6 <botlish_fn_1+0x11e>
			3b2: R_X86_64_PLT32	rt_str_region_check-0x4
 3b6:	test   rax,rax
 3b9:	jne    3ea <botlish_fn_1+0x152>
 3bf:	mov    rdi,r14
 3c2:	mov    QWORD PTR [rdi],r12
 3c5:	xor    rax,rax
 3c8:	mov    rbx,QWORD PTR [rsp+0x10]
 3cd:	mov    r12,QWORD PTR [rsp+0x18]
 3d2:	mov    r13,QWORD PTR [rsp+0x20]
 3d7:	mov    r14,QWORD PTR [rsp+0x28]
 3dc:	mov    r15,QWORD PTR [rsp+0x30]
 3e1:	add    rsp,0x40
 3e5:	mov    rsp,rbp
 3e8:	pop    rbp
 3e9:	ret
 3ea:	mov    rcx,r13
 3ed:	mov    rdx,rbx
 3f0:	mov    rsi,QWORD PTR [rsp]
 3f4:	mov    r8,r15
 3f7:	mov    rdi,r14
 3fa:	call   3ff <botlish_fn_1+0x167>
			3fb: R_X86_64_PLT32	rt_str_region_eq-0x4
 3ff:	mov    rdi,r14
 402:	mov    QWORD PTR [rdi],r12
 405:	mov    rbx,QWORD PTR [rsp+0x10]
 40a:	mov    r12,QWORD PTR [rsp+0x18]
 40f:	mov    r13,QWORD PTR [rsp+0x20]
 414:	mov    r14,QWORD PTR [rsp+0x28]
 419:	mov    r15,QWORD PTR [rsp+0x30]
 41e:	add    rsp,0x40
 422:	mov    rsp,rbp
 425:	pop    rbp
 426:	ret
 427:	mov    rdi,r14
 42a:	mov    QWORD PTR [rdi],r12
 42d:	mov    eax,0x2
 432:	mov    rbx,QWORD PTR [rsp+0x10]
 437:	mov    r12,QWORD PTR [rsp+0x18]
 43c:	mov    r13,QWORD PTR [rsp+0x20]
 441:	mov    r14,QWORD PTR [rsp+0x28]
 446:	mov    r15,QWORD PTR [rsp+0x30]
 44b:	add    rsp,0x40
 44f:	mov    rsp,rbp
 452:	pop    rbp
 453:	ret
 454:	mov    r14,rdi
 457:	call   45c <botlish_fn_1+0x1c4>
			458: R_X86_64_PLT32	rt_stack_overflow-0x4
 45c:	xor    rax,rax
 45f:	mov    rbx,QWORD PTR [rsp+0x10]
 464:	mov    r12,QWORD PTR [rsp+0x18]
 469:	mov    r13,QWORD PTR [rsp+0x20]
 46e:	mov    r14,QWORD PTR [rsp+0x28]
 473:	mov    r15,QWORD PTR [rsp+0x30]
 478:	add    rsp,0x40
 47c:	mov    rsp,rbp
 47f:	pop    rbp
 480:	ret
 481:	add    BYTE PTR [rax],al
 483:	add    BYTE PTR [rax],al
 485:	add    BYTE PTR [rax],al
 487:	add    BYTE PTR [rsi],al
 489:	add    BYTE PTR [rax],al
 48b:	add    BYTE PTR [rax],al
 48d:	add    BYTE PTR [rax],al
	...

0000000000000490 <botlish_entry_1: matches_at<str, str, int>>:
 490:	push   rbp
 491:	mov    rbp,rsp
 494:	mov    rsi,QWORD PTR [rdx]
 497:	mov    r8,QWORD PTR [rdx+0x8]
 49b:	mov    rcx,QWORD PTR [rdx+0x10]
 49f:	mov    rdx,r8
 4a2:	call   4a7 <botlish_entry_1+0x17>
			4a3: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 4a7:	mov    rsp,rbp
 4aa:	pop    rbp
 4ab:	ret
 4ac:	add    BYTE PTR [rax],al
	...

00000000000004b0 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 4b0:	push   rbp
 4b1:	mov    rbp,rsp
 4b4:	sub    rsp,0x50
 4b8:	mov    QWORD PTR [rsp+0x20],rbx
 4bd:	mov    QWORD PTR [rsp+0x28],r12
 4c2:	mov    QWORD PTR [rsp+0x30],r13
 4c7:	mov    QWORD PTR [rsp+0x38],r14
 4cc:	mov    QWORD PTR [rsp+0x40],r15
 4d1:	mov    r10,QWORD PTR [rbp+0x10]
 4d5:	mov    r13,QWORD PTR [rdi]
 4d8:	mov    rax,QWORD PTR [rdi+0x8]
 4dc:	lea    r11,[r13+0x38]
 4e0:	cmp    r11,rax
 4e3:	ja     855 <botlish_fn_2+0x3a5>
 4e9:	lea    rax,[r13+0x38]
 4ed:	mov    QWORD PTR [rdi],rax
 4f0:	mov    r14,rdi
 4f3:	mov    QWORD PTR [r13+0x0],rsi
 4f7:	mov    r15,rsi
 4fa:	mov    QWORD PTR [r13+0x8],rdx
 4fe:	mov    QWORD PTR [r13+0x10],rcx
 502:	mov    rbx,rcx
 505:	mov    QWORD PTR [r13+0x18],r8
 509:	mov    QWORD PTR [r13+0x20],r9
 50d:	mov    QWORD PTR [r13+0x28],r10
 511:	mov    QWORD PTR [rsp+0x10],r10
 516:	mov    r12,rdx
 519:	mov    QWORD PTR [rsp],r8
 51d:	mov    QWORD PTR [rsp+0x8],r9
 522:	mov    rsi,r12
 525:	mov    rdi,r14
 528:	call   52d <botlish_fn_2+0x7d>
			529: R_X86_64_PLT32	rt_str_len-0x4
 52d:	mov    QWORD PTR [r13+0x30],rax
 531:	mov    rsi,QWORD PTR [rsp]
 535:	mov    rdx,rsi
 538:	and    rdx,rax
 53b:	test   rdx,0x1
 542:	jne    554 <botlish_fn_2+0xa4>
 548:	mov    rdx,rax
 54b:	mov    QWORD PTR [rsp],rsi
 54f:	jmp    577 <botlish_fn_2+0xc7>
 554:	lea    rdi,[rax-0x1]
 558:	mov    rdx,rax
 55b:	mov    rax,rsi
 55e:	add    rax,rdi
 561:	mov    QWORD PTR [rsp],rsi
 565:	mov    QWORD PTR [rsp+0x18],rax
 56a:	seto   sil
 56e:	test   sil,sil
 571:	je     588 <botlish_fn_2+0xd8>
 577:	mov    rsi,QWORD PTR [rsp]
 57b:	mov    rdi,r14
 57e:	call   583 <botlish_fn_2+0xd3>
			57f: R_X86_64_PLT32	rt_int_add-0x4
 583:	mov    QWORD PTR [rsp+0x18],rax
 588:	mov    rsi,r15
 58b:	mov    rdi,r14
 58e:	call   593 <botlish_fn_2+0xe3>
			58f: R_X86_64_PLT32	rt_str_len-0x4
 593:	mov    rsi,QWORD PTR [rsp+0x18]
 598:	mov    r10,rsi
 59b:	and    r10,rax
 59e:	mov    rdx,rax
 5a1:	test   r10,0x1
 5a8:	jne    5cb <botlish_fn_2+0x11b>
 5ae:	mov    rdi,r14
 5b1:	call   5b6 <botlish_fn_2+0x106>
			5b2: R_X86_64_PLT32	rt_int_cmp-0x4
 5b6:	mov    ecx,0x2
 5bb:	test   rax,rax
 5be:	cmovg  rcx,QWORD PTR [rip+0x2c2]        # 888 <botlish_fn_2+0x3d8>
 5c6:	jmp    5db <botlish_fn_2+0x12b>
 5cb:	mov    ecx,0x2
 5d0:	cmp    rsi,rdx
 5d3:	cmovg  rcx,QWORD PTR [rip+0x2ad]        # 888 <botlish_fn_2+0x3d8>
 5db:	cmp    rcx,0x6
 5df:	je     7af <botlish_fn_2+0x2ff>
 5e5:	mov    rcx,QWORD PTR [rsp]
 5e9:	mov    rdx,r12
 5ec:	mov    rsi,r15
 5ef:	mov    rdi,r14
 5f2:	call   5f7 <botlish_fn_2+0x147>
			5f3: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 5f7:	test   rax,rax
 5fa:	jne    608 <botlish_fn_2+0x158>
 600:	mov    rdi,r14
 603:	jmp    802 <botlish_fn_2+0x352>
 608:	cmp    rax,0x6
 60c:	je     693 <botlish_fn_2+0x1e3>
 612:	mov    QWORD PTR [r13+0x30],0x3
 61a:	mov    rsi,QWORD PTR [rsp]
 61e:	test   rsi,0x1
 625:	je     64d <botlish_fn_2+0x19d>
 62b:	mov    rsi,QWORD PTR [rsp]
 62f:	mov    rax,rsi
 632:	add    rax,0x2
 636:	seto   cl
 639:	test   cl,cl
 63b:	jne    64d <botlish_fn_2+0x19d>
 641:	mov    rsi,r15
 644:	mov    QWORD PTR [rsp],rax
 648:	jmp    665 <botlish_fn_2+0x1b5>
 64d:	mov    edx,0x3
 652:	mov    rsi,QWORD PTR [rsp]
 656:	mov    rdi,r14
 659:	call   65e <botlish_fn_2+0x1ae>
			65a: R_X86_64_PLT32	rt_int_add-0x4
 65e:	mov    rsi,r15
 661:	mov    QWORD PTR [rsp],rax
 665:	mov    rsi,r15
 668:	mov    QWORD PTR [r13+0x0],rsi
 66c:	mov    QWORD PTR [r13+0x8],r12
 670:	mov    QWORD PTR [r13+0x10],rbx
 674:	mov    rsi,QWORD PTR [rsp]
 678:	mov    QWORD PTR [r13+0x18],rsi
 67c:	mov    rdx,QWORD PTR [rsp+0x8]
 681:	mov    QWORD PTR [r13+0x20],rdx
 685:	mov    rsi,QWORD PTR [rsp+0x10]
 68a:	mov    QWORD PTR [r13+0x28],rsi
 68e:	jmp    522 <botlish_fn_2+0x72>
 693:	mov    rdx,QWORD PTR [rsp+0x8]
 698:	mov    rcx,QWORD PTR [rsp]
 69c:	mov    rsi,r15
 69f:	mov    rdi,r14
 6a2:	call   6a7 <botlish_fn_2+0x1f7>
			6a3: R_X86_64_PLT32	rt_substr-0x4
 6a7:	test   rax,rax
 6aa:	jne    6b8 <botlish_fn_2+0x208>
 6b0:	mov    rdi,r14
 6b3:	jmp    802 <botlish_fn_2+0x352>
 6b8:	mov    QWORD PTR [r13+0x20],rax
 6bc:	mov    rdx,rax
 6bf:	mov    rsi,QWORD PTR [rsp+0x10]
 6c4:	mov    rdi,r14
 6c7:	call   6cc <botlish_fn_2+0x21c>
			6c8: R_X86_64_PLT32	rt_str_cat-0x4
 6cc:	test   rax,rax
 6cf:	jne    6dd <botlish_fn_2+0x22d>
 6d5:	mov    rdi,r14
 6d8:	jmp    802 <botlish_fn_2+0x352>
 6dd:	mov    QWORD PTR [r13+0x20],rax
 6e1:	mov    QWORD PTR [rsp+0x18],rax
 6e6:	mov    rsi,r12
 6e9:	mov    rdi,r14
 6ec:	call   6f1 <botlish_fn_2+0x241>
			6ed: R_X86_64_PLT32	rt_str_len-0x4
 6f1:	mov    QWORD PTR [r13+0x28],rax
 6f5:	mov    rsi,QWORD PTR [rsp]
 6f9:	mov    rcx,rsi
 6fc:	and    rcx,rax
 6ff:	test   rcx,0x1
 706:	jne    718 <botlish_fn_2+0x268>
 70c:	mov    rdx,rax
 70f:	mov    rsi,QWORD PTR [rsp]
 713:	jmp    749 <botlish_fn_2+0x299>
 718:	lea    rcx,[rax-0x1]
 71c:	mov    rdx,rax
 71f:	mov    rsi,QWORD PTR [rsp]
 723:	mov    rax,rsi
 726:	add    rax,rcx
 729:	seto   cl
 72c:	test   cl,cl
 72e:	je     73d <botlish_fn_2+0x28d>
 734:	mov    rsi,QWORD PTR [rsp]
 738:	jmp    749 <botlish_fn_2+0x299>
 73d:	mov    rsi,rax
 740:	mov    QWORD PTR [rsp],rax
 744:	jmp    758 <botlish_fn_2+0x2a8>
 749:	mov    rdi,r14
 74c:	call   751 <botlish_fn_2+0x2a1>
			74d: R_X86_64_PLT32	rt_int_add-0x4
 751:	mov    rsi,rax
 754:	mov    QWORD PTR [rsp],rax
 758:	mov    QWORD PTR [r13+0x18],rsi
 75c:	mov    rsi,QWORD PTR [rsp+0x18]
 761:	mov    rdx,rbx
 764:	mov    rdi,r14
 767:	call   76c <botlish_fn_2+0x2bc>
			768: R_X86_64_PLT32	rt_str_cat-0x4
 76c:	test   rax,rax
 76f:	jne    77d <botlish_fn_2+0x2cd>
 775:	mov    rdi,r14
 778:	jmp    802 <botlish_fn_2+0x352>
 77d:	mov    rsi,r15
 780:	mov    QWORD PTR [r13+0x0],rsi
 784:	mov    QWORD PTR [r13+0x8],r12
 788:	mov    QWORD PTR [r13+0x10],rbx
 78c:	mov    rsi,QWORD PTR [rsp]
 790:	mov    QWORD PTR [r13+0x18],rsi
 794:	mov    QWORD PTR [r13+0x20],rsi
 798:	mov    QWORD PTR [r13+0x28],rax
 79c:	mov    rcx,QWORD PTR [rsp]
 7a0:	mov    QWORD PTR [rsp+0x8],rcx
 7a5:	mov    QWORD PTR [rsp+0x10],rax
 7aa:	jmp    522 <botlish_fn_2+0x72>
 7af:	mov    rsi,r15
 7b2:	mov    rdi,r14
 7b5:	call   7ba <botlish_fn_2+0x30a>
			7b6: R_X86_64_PLT32	rt_str_len-0x4
 7ba:	mov    QWORD PTR [r13+0x8],rax
 7be:	mov    rcx,rax
 7c1:	mov    rdx,QWORD PTR [rsp+0x8]
 7c6:	mov    rsi,r15
 7c9:	mov    rdi,r14
 7cc:	call   7d1 <botlish_fn_2+0x321>
			7cd: R_X86_64_PLT32	rt_substr-0x4
 7d1:	test   rax,rax
 7d4:	jne    7e2 <botlish_fn_2+0x332>
 7da:	mov    rdi,r14
 7dd:	jmp    802 <botlish_fn_2+0x352>
 7e2:	mov    QWORD PTR [r13+0x0],rax
 7e6:	mov    rdx,rax
 7e9:	mov    rsi,QWORD PTR [rsp+0x10]
 7ee:	mov    rdi,r14
 7f1:	call   7f6 <botlish_fn_2+0x346>
			7f2: R_X86_64_PLT32	rt_str_cat-0x4
 7f6:	test   rax,rax
 7f9:	jne    82d <botlish_fn_2+0x37d>
 7ff:	mov    rdi,r14
 802:	mov    rdi,r14
 805:	mov    QWORD PTR [rdi],r13
 808:	xor    rax,rax
 80b:	mov    rbx,QWORD PTR [rsp+0x20]
 810:	mov    r12,QWORD PTR [rsp+0x28]
 815:	mov    r13,QWORD PTR [rsp+0x30]
 81a:	mov    r14,QWORD PTR [rsp+0x38]
 81f:	mov    r15,QWORD PTR [rsp+0x40]
 824:	add    rsp,0x50
 828:	mov    rsp,rbp
 82b:	pop    rbp
 82c:	ret
 82d:	mov    rdi,r14
 830:	mov    QWORD PTR [rdi],r13
 833:	mov    rbx,QWORD PTR [rsp+0x20]
 838:	mov    r12,QWORD PTR [rsp+0x28]
 83d:	mov    r13,QWORD PTR [rsp+0x30]
 842:	mov    r14,QWORD PTR [rsp+0x38]
 847:	mov    r15,QWORD PTR [rsp+0x40]
 84c:	add    rsp,0x50
 850:	mov    rsp,rbp
 853:	pop    rbp
 854:	ret
 855:	mov    r14,rdi
 858:	call   85d <botlish_fn_2+0x3ad>
			859: R_X86_64_PLT32	rt_stack_overflow-0x4
 85d:	xor    rax,rax
 860:	mov    rbx,QWORD PTR [rsp+0x20]
 865:	mov    r12,QWORD PTR [rsp+0x28]
 86a:	mov    r13,QWORD PTR [rsp+0x30]
 86f:	mov    r14,QWORD PTR [rsp+0x38]
 874:	mov    r15,QWORD PTR [rsp+0x40]
 879:	add    rsp,0x50
 87d:	mov    rsp,rbp
 880:	pop    rbp
 881:	ret
 882:	add    BYTE PTR [rax],al
 884:	add    BYTE PTR [rax],al
 886:	add    BYTE PTR [rax],al
 888:	(bad)
 889:	add    BYTE PTR [rax],al
 88b:	add    BYTE PTR [rax],al
 88d:	add    BYTE PTR [rax],al
	...

0000000000000890 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 890:	push   rbp
 891:	mov    rbp,rsp
 894:	sub    rsp,0x10
 898:	mov    rsi,QWORD PTR [rdx]
 89b:	mov    r10,QWORD PTR [rdx+0x8]
 89f:	mov    rcx,QWORD PTR [rdx+0x10]
 8a3:	mov    r8,QWORD PTR [rdx+0x18]
 8a7:	mov    r9,QWORD PTR [rdx+0x20]
 8ab:	mov    r11,QWORD PTR [rdx+0x28]
 8af:	mov    QWORD PTR [rsp],r11
 8b3:	mov    rdx,r10
 8b6:	call   8bb <botlish_entry_2+0x2b>
			8b7: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 8bb:	add    rsp,0x10
 8bf:	mov    rsp,rbp
 8c2:	pop    rbp
 8c3:	ret

00000000000008c4 <botlish_fn_3: replace<str, str, str>>:
 8c4:	push   rbp
 8c5:	mov    rbp,rsp
 8c8:	sub    rsp,0x40
 8cc:	mov    QWORD PTR [rsp+0x10],rbx
 8d1:	mov    QWORD PTR [rsp+0x18],r12
 8d6:	mov    QWORD PTR [rsp+0x20],r13
 8db:	mov    QWORD PTR [rsp+0x28],r14
 8e0:	mov    QWORD PTR [rsp+0x30],r15
 8e5:	mov    r13,rsi
 8e8:	mov    r15,rdx
 8eb:	mov    rbx,QWORD PTR [rdi]
 8ee:	mov    rax,QWORD PTR [rdi+0x8]
 8f2:	lea    rdx,[rbx+0x30]
 8f6:	cmp    rdx,rax
 8f9:	ja     9f5 <botlish_fn_3+0x131>
 8ff:	lea    rax,[rbx+0x30]
 903:	mov    QWORD PTR [rdi],rax
 906:	mov    rsi,r13
 909:	mov    r12,rdi
 90c:	mov    QWORD PTR [rbx],rsi
 90f:	mov    rdx,r15
 912:	mov    QWORD PTR [rbx+0x8],rdx
 916:	mov    QWORD PTR [rbx+0x10],rcx
 91a:	mov    r14,rcx
 91d:	mov    rsi,r15
 920:	mov    rdi,r12
 923:	call   928 <botlish_fn_3+0x64>
			924: R_X86_64_PLT32	rt_str_len-0x4
 928:	sar    rax,1
 92b:	test   rax,rax
 92e:	je     9ca <botlish_fn_3+0x106>
 934:	mov    r9d,0x1
 93a:	mov    QWORD PTR [rbx+0x18],0x1
 942:	mov    QWORD PTR [rbx+0x20],0x1
 94a:	mov    rdi,r12
 94d:	mov    rax,QWORD PTR [rdi+0x10]
 951:	mov    rax,QWORD PTR [rax+0x40]
 955:	mov    QWORD PTR [rbx+0x28],rax
 959:	mov    QWORD PTR [rsp],rax
 95d:	mov    rcx,r14
 960:	mov    rdx,r15
 963:	mov    rsi,r13
 966:	mov    r8,r9
 969:	call   96e <botlish_fn_3+0xaa>
			96a: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 96e:	test   rax,rax
 971:	jne    9a2 <botlish_fn_3+0xde>
 977:	mov    rdi,r12
 97a:	mov    QWORD PTR [rdi],rbx
 97d:	xor    rax,rax
 980:	mov    rbx,QWORD PTR [rsp+0x10]
 985:	mov    r12,QWORD PTR [rsp+0x18]
 98a:	mov    r13,QWORD PTR [rsp+0x20]
 98f:	mov    r14,QWORD PTR [rsp+0x28]
 994:	mov    r15,QWORD PTR [rsp+0x30]
 999:	add    rsp,0x40
 99d:	mov    rsp,rbp
 9a0:	pop    rbp
 9a1:	ret
 9a2:	mov    rdi,r12
 9a5:	mov    QWORD PTR [rdi],rbx
 9a8:	mov    rbx,QWORD PTR [rsp+0x10]
 9ad:	mov    r12,QWORD PTR [rsp+0x18]
 9b2:	mov    r13,QWORD PTR [rsp+0x20]
 9b7:	mov    r14,QWORD PTR [rsp+0x28]
 9bc:	mov    r15,QWORD PTR [rsp+0x30]
 9c1:	add    rsp,0x40
 9c5:	mov    rsp,rbp
 9c8:	pop    rbp
 9c9:	ret
 9ca:	mov    rdi,r12
 9cd:	mov    QWORD PTR [rdi],rbx
 9d0:	mov    rax,r13
 9d3:	mov    rbx,QWORD PTR [rsp+0x10]
 9d8:	mov    r12,QWORD PTR [rsp+0x18]
 9dd:	mov    r13,QWORD PTR [rsp+0x20]
 9e2:	mov    r14,QWORD PTR [rsp+0x28]
 9e7:	mov    r15,QWORD PTR [rsp+0x30]
 9ec:	add    rsp,0x40
 9f0:	mov    rsp,rbp
 9f3:	pop    rbp
 9f4:	ret
 9f5:	mov    r12,rdi
 9f8:	call   9fd <botlish_fn_3+0x139>
			9f9: R_X86_64_PLT32	rt_stack_overflow-0x4
 9fd:	xor    rax,rax
 a00:	mov    rbx,QWORD PTR [rsp+0x10]
 a05:	mov    r12,QWORD PTR [rsp+0x18]
 a0a:	mov    r13,QWORD PTR [rsp+0x20]
 a0f:	mov    r14,QWORD PTR [rsp+0x28]
 a14:	mov    r15,QWORD PTR [rsp+0x30]
 a19:	add    rsp,0x40
 a1d:	mov    rsp,rbp
 a20:	pop    rbp
 a21:	ret

0000000000000a22 <botlish_entry_3: replace<str, str, str>>:
 a22:	push   rbp
 a23:	mov    rbp,rsp
 a26:	mov    rsi,QWORD PTR [rdx]
 a29:	mov    r8,QWORD PTR [rdx+0x8]
 a2d:	mov    rcx,QWORD PTR [rdx+0x10]
 a31:	mov    rdx,r8
 a34:	call   a39 <botlish_entry_3+0x17>
			a35: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 a39:	mov    rsp,rbp
 a3c:	pop    rbp
 a3d:	ret

; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2943  (per function: 696 612 1196 439)
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
  2f:	ja     271 <botlish_fn_0+0x271>
  35:	lea    rax,[r15+0x38]
  39:	mov    QWORD PTR [rdi],rax
  3c:	mov    QWORD PTR [r15],0x0
  43:	mov    QWORD PTR [r15+0x8],0x0
  4b:	mov    QWORD PTR [r15+0x10],0x0
  53:	mov    QWORD PTR [r15+0x18],0x0
  5b:	mov    QWORD PTR [r15+0x20],0x0
  63:	mov    QWORD PTR [r15+0x28],0x0
  6b:	mov    QWORD PTR [r15+0x30],0x0
  73:	mov    rax,QWORD PTR [rdi+0x10]
  77:	mov    rsi,QWORD PTR [rax]
  7a:	mov    QWORD PTR [r15],rsi
  7d:	mov    rax,QWORD PTR [rdi+0x10]
  81:	mov    rdx,QWORD PTR [rax+0x8]
  85:	mov    QWORD PTR [r15+0x8],rdx
  89:	mov    rax,QWORD PTR [rdi+0x10]
  8d:	mov    QWORD PTR [rsp+0x28],rdi
  92:	mov    rcx,QWORD PTR [rax+0x10]
  96:	mov    QWORD PTR [r15+0x10],rcx
  9a:	call   9f <botlish_fn_0+0x9f>
			9b: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  9f:	mov    rbx,rax
  a2:	test   rbx,rbx
  a5:	jne    b5 <botlish_fn_0+0xb5>
  ab:	mov    rdi,QWORD PTR [rsp+0x28]
  b0:	jmp    21a <botlish_fn_0+0x21a>
  b5:	mov    QWORD PTR [r15],rbx
  b8:	mov    rdi,QWORD PTR [rsp+0x28]
  bd:	mov    rsi,QWORD PTR [rdi+0x10]
  c1:	mov    rsi,QWORD PTR [rsi]
  c4:	mov    QWORD PTR [r15+0x8],rsi
  c8:	mov    rdi,QWORD PTR [rdi+0x10]
  cc:	mov    rdx,QWORD PTR [rdi+0x18]
  d0:	mov    QWORD PTR [r15+0x10],rdx
  d4:	mov    rdi,QWORD PTR [rsp+0x28]
  d9:	mov    rdi,QWORD PTR [rdi+0x10]
  dd:	mov    rcx,QWORD PTR [rdi+0x20]
  e1:	mov    QWORD PTR [r15+0x18],rcx
  e5:	mov    rdi,QWORD PTR [rsp+0x28]
  ea:	call   ef <botlish_fn_0+0xef>
			eb: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  ef:	mov    r12,rax
  f2:	test   r12,r12
  f5:	jne    105 <botlish_fn_0+0x105>
  fb:	mov    rdi,QWORD PTR [rsp+0x28]
 100:	jmp    21a <botlish_fn_0+0x21a>
 105:	mov    QWORD PTR [r15+0x8],r12
 109:	mov    rdi,QWORD PTR [rsp+0x28]
 10e:	mov    rax,QWORD PTR [rdi+0x10]
 112:	mov    rsi,QWORD PTR [rax+0x28]
 116:	mov    QWORD PTR [r15+0x10],rsi
 11a:	mov    rax,QWORD PTR [rdi+0x10]
 11e:	mov    rdx,QWORD PTR [rax+0x30]
 122:	mov    QWORD PTR [r15+0x18],rdx
 126:	mov    rax,QWORD PTR [rdi+0x10]
 12a:	mov    rcx,QWORD PTR [rax+0x18]
 12e:	mov    QWORD PTR [r15+0x20],rcx
 132:	call   137 <botlish_fn_0+0x137>
			133: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 137:	mov    r13,rax
 13a:	test   r13,r13
 13d:	jne    14d <botlish_fn_0+0x14d>
 143:	mov    rdi,QWORD PTR [rsp+0x28]
 148:	jmp    21a <botlish_fn_0+0x21a>
 14d:	mov    QWORD PTR [r15+0x10],r13
 151:	mov    rdi,QWORD PTR [rsp+0x28]
 156:	mov    rax,QWORD PTR [rdi+0x10]
 15a:	mov    rsi,QWORD PTR [rax+0x38]
 15e:	mov    QWORD PTR [r15+0x18],rsi
 162:	mov    rax,QWORD PTR [rdi+0x10]
 166:	mov    rdx,QWORD PTR [rax]
 169:	mov    QWORD PTR [r15+0x20],rdx
 16d:	mov    rax,QWORD PTR [rdi+0x10]
 171:	mov    rcx,QWORD PTR [rax+0x40]
 175:	mov    QWORD PTR [r15+0x28],rcx
 179:	call   17e <botlish_fn_0+0x17e>
			17a: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 17e:	mov    r14,rax
 181:	test   r14,r14
 184:	jne    194 <botlish_fn_0+0x194>
 18a:	mov    rdi,QWORD PTR [rsp+0x28]
 18f:	jmp    21a <botlish_fn_0+0x21a>
 194:	mov    QWORD PTR [r15+0x18],r14
 198:	mov    rdi,QWORD PTR [rsp+0x28]
 19d:	mov    rax,QWORD PTR [rdi+0x10]
 1a1:	mov    rsi,QWORD PTR [rax+0x40]
 1a5:	mov    QWORD PTR [r15+0x20],rsi
 1a9:	mov    rax,QWORD PTR [rdi+0x10]
 1ad:	mov    rdx,QWORD PTR [rax+0x8]
 1b1:	mov    QWORD PTR [r15+0x28],rdx
 1b5:	mov    rax,QWORD PTR [rdi+0x10]
 1b9:	mov    rcx,QWORD PTR [rax+0x10]
 1bd:	mov    QWORD PTR [r15+0x30],rcx
 1c1:	call   1c6 <botlish_fn_0+0x1c6>
			1c2: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 1c6:	test   rax,rax
 1c9:	jne    1d9 <botlish_fn_0+0x1d9>
 1cf:	mov    rdi,QWORD PTR [rsp+0x28]
 1d4:	jmp    21a <botlish_fn_0+0x21a>
 1d9:	mov    QWORD PTR [r15+0x20],rax
 1dd:	lea    rdx,[rsp]
 1e1:	mov    QWORD PTR [rsp],rbx
 1e5:	mov    QWORD PTR [rsp+0x8],r12
 1ea:	mov    QWORD PTR [rsp+0x10],r13
 1ef:	mov    QWORD PTR [rsp+0x18],r14
 1f4:	mov    QWORD PTR [rsp+0x20],rax
 1f9:	mov    esi,0x5
 1fe:	mov    rax,QWORD PTR [rip+0x0]        # 205 <botlish_fn_0+0x205>
			201: R_X86_64_GOTPCREL	rt_list_new-0x4
 205:	mov    rdi,QWORD PTR [rsp+0x28]
 20a:	call   rax
 20c:	test   rax,rax
 20f:	jne    247 <botlish_fn_0+0x247>
 215:	mov    rdi,QWORD PTR [rsp+0x28]
 21a:	mov    rdi,QWORD PTR [rsp+0x28]
 21f:	mov    QWORD PTR [rdi],r15
 222:	xor    rax,rax
 225:	mov    rbx,QWORD PTR [rsp+0x30]
 22a:	mov    r12,QWORD PTR [rsp+0x38]
 22f:	mov    r13,QWORD PTR [rsp+0x40]
 234:	mov    r14,QWORD PTR [rsp+0x48]
 239:	mov    r15,QWORD PTR [rsp+0x50]
 23e:	add    rsp,0x60
 242:	mov    rsp,rbp
 245:	pop    rbp
 246:	ret
 247:	mov    rdi,QWORD PTR [rsp+0x28]
 24c:	mov    QWORD PTR [rdi],r15
 24f:	mov    rbx,QWORD PTR [rsp+0x30]
 254:	mov    r12,QWORD PTR [rsp+0x38]
 259:	mov    r13,QWORD PTR [rsp+0x40]
 25e:	mov    r14,QWORD PTR [rsp+0x48]
 263:	mov    r15,QWORD PTR [rsp+0x50]
 268:	add    rsp,0x60
 26c:	mov    rsp,rbp
 26f:	pop    rbp
 270:	ret
 271:	mov    QWORD PTR [rsp+0x28],rdi
 276:	mov    rax,QWORD PTR [rip+0x0]        # 27d <botlish_fn_0+0x27d>
			279: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 27d:	call   rax
 27f:	xor    rax,rax
 282:	mov    rbx,QWORD PTR [rsp+0x30]
 287:	mov    r12,QWORD PTR [rsp+0x38]
 28c:	mov    r13,QWORD PTR [rsp+0x40]
 291:	mov    r14,QWORD PTR [rsp+0x48]
 296:	mov    r15,QWORD PTR [rsp+0x50]
 29b:	add    rsp,0x60
 29f:	mov    rsp,rbp
 2a2:	pop    rbp
 2a3:	ret

00000000000002a4 <botlish_entry_0: <program entry>>:
 2a4:	push   rbp
 2a5:	mov    rbp,rsp
 2a8:	call   2ad <botlish_entry_0+0x9>
			2a9: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 2ad:	mov    rsp,rbp
 2b0:	pop    rbp
 2b1:	ret
 2b2:	add    BYTE PTR [rax],al
 2b4:	add    BYTE PTR [rax],al
	...

00000000000002b8 <botlish_fn_1: matches_at<str, str, int>>:
 2b8:	push   rbp
 2b9:	mov    rbp,rsp
 2bc:	sub    rsp,0x40
 2c0:	mov    QWORD PTR [rsp+0x10],rbx
 2c5:	mov    QWORD PTR [rsp+0x18],r12
 2ca:	mov    QWORD PTR [rsp+0x20],r13
 2cf:	mov    QWORD PTR [rsp+0x28],r14
 2d4:	mov    QWORD PTR [rsp+0x30],r15
 2d9:	mov    r12,QWORD PTR [rdi]
 2dc:	mov    rax,QWORD PTR [rdi+0x8]
 2e0:	lea    r8,[r12+0x20]
 2e5:	cmp    r8,rax
 2e8:	ja     4b1 <botlish_fn_1+0x1f9>
 2ee:	lea    rax,[r12+0x20]
 2f3:	mov    QWORD PTR [rdi],rax
 2f6:	mov    r14,rdi
 2f9:	mov    QWORD PTR [r12],0x0
 301:	mov    QWORD PTR [r12+0x8],0x0
 30a:	mov    QWORD PTR [r12+0x10],0x0
 313:	mov    QWORD PTR [r12+0x18],0x0
 31c:	mov    QWORD PTR [r12],rsi
 320:	mov    QWORD PTR [rsp],rsi
 324:	mov    QWORD PTR [r12+0x8],rdx
 329:	mov    r15,rdx
 32c:	mov    QWORD PTR [r12+0x10],rcx
 331:	mov    rbx,rcx
 334:	mov    rax,QWORD PTR [rip+0x0]        # 33b <botlish_fn_1+0x83>
			337: R_X86_64_GOTPCREL	rt_str_len-0x4
 33b:	mov    rsi,r15
 33e:	mov    rdi,r14
 341:	call   rax
 343:	mov    QWORD PTR [r12+0x18],rax
 348:	mov    rcx,rbx
 34b:	and    rcx,rax
 34e:	test   rcx,0x1
 355:	jne    363 <botlish_fn_1+0xab>
 35b:	mov    rdx,rax
 35e:	jmp    37e <botlish_fn_1+0xc6>
 363:	lea    rcx,[rax-0x1]
 367:	mov    rdx,rax
 36a:	mov    rax,rbx
 36d:	add    rax,rcx
 370:	mov    r13,rax
 373:	seto   al
 376:	test   al,al
 378:	je     390 <botlish_fn_1+0xd8>
 37e:	mov    rax,QWORD PTR [rip+0x0]        # 385 <botlish_fn_1+0xcd>
			381: R_X86_64_GOTPCREL	rt_int_add-0x4
 385:	mov    rsi,rbx
 388:	mov    rdi,r14
 38b:	call   rax
 38d:	mov    r13,rax
 390:	mov    rax,QWORD PTR [rip+0x0]        # 397 <botlish_fn_1+0xdf>
			393: R_X86_64_GOTPCREL	rt_str_len-0x4
 397:	mov    rsi,QWORD PTR [rsp]
 39b:	mov    rdi,r14
 39e:	call   rax
 3a0:	mov    rcx,r13
 3a3:	and    rcx,rax
 3a6:	mov    rdx,rax
 3a9:	test   rcx,0x1
 3b0:	jne    3da <botlish_fn_1+0x122>
 3b6:	mov    rax,QWORD PTR [rip+0x0]        # 3bd <botlish_fn_1+0x105>
			3b9: R_X86_64_GOTPCREL	rt_int_cmp-0x4
 3bd:	mov    rsi,r13
 3c0:	mov    rdi,r14
 3c3:	call   rax
 3c5:	mov    ecx,0x2
 3ca:	test   rax,rax
 3cd:	cmovg  rcx,QWORD PTR [rip+0x113]        # 4e8 <botlish_fn_1+0x230>
 3d5:	jmp    3ed <botlish_fn_1+0x135>
 3da:	mov    ecx,0x2
 3df:	mov    rax,r13
 3e2:	cmp    rax,rdx
 3e5:	cmovg  rcx,QWORD PTR [rip+0xfb]        # 4e8 <botlish_fn_1+0x230>
 3ed:	cmp    rcx,0x6
 3f1:	je     484 <botlish_fn_1+0x1cc>
 3f7:	mov    r8,QWORD PTR [rip+0x0]        # 3fe <botlish_fn_1+0x146>
			3fa: R_X86_64_GOTPCREL	rt_str_region_check-0x4
 3fe:	mov    rcx,r13
 401:	mov    rdx,rbx
 404:	mov    rsi,QWORD PTR [rsp]
 408:	mov    rdi,r14
 40b:	call   r8
 40e:	test   rax,rax
 411:	jne    442 <botlish_fn_1+0x18a>
 417:	mov    rdi,r14
 41a:	mov    QWORD PTR [rdi],r12
 41d:	xor    rax,rax
 420:	mov    rbx,QWORD PTR [rsp+0x10]
 425:	mov    r12,QWORD PTR [rsp+0x18]
 42a:	mov    r13,QWORD PTR [rsp+0x20]
 42f:	mov    r14,QWORD PTR [rsp+0x28]
 434:	mov    r15,QWORD PTR [rsp+0x30]
 439:	add    rsp,0x40
 43d:	mov    rsp,rbp
 440:	pop    rbp
 441:	ret
 442:	mov    r9,QWORD PTR [rip+0x0]        # 449 <botlish_fn_1+0x191>
			445: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
 449:	mov    rcx,r13
 44c:	mov    rdx,rbx
 44f:	mov    rsi,QWORD PTR [rsp]
 453:	mov    r8,r15
 456:	mov    rdi,r14
 459:	call   r9
 45c:	mov    rdi,r14
 45f:	mov    QWORD PTR [rdi],r12
 462:	mov    rbx,QWORD PTR [rsp+0x10]
 467:	mov    r12,QWORD PTR [rsp+0x18]
 46c:	mov    r13,QWORD PTR [rsp+0x20]
 471:	mov    r14,QWORD PTR [rsp+0x28]
 476:	mov    r15,QWORD PTR [rsp+0x30]
 47b:	add    rsp,0x40
 47f:	mov    rsp,rbp
 482:	pop    rbp
 483:	ret
 484:	mov    rdi,r14
 487:	mov    QWORD PTR [rdi],r12
 48a:	mov    eax,0x2
 48f:	mov    rbx,QWORD PTR [rsp+0x10]
 494:	mov    r12,QWORD PTR [rsp+0x18]
 499:	mov    r13,QWORD PTR [rsp+0x20]
 49e:	mov    r14,QWORD PTR [rsp+0x28]
 4a3:	mov    r15,QWORD PTR [rsp+0x30]
 4a8:	add    rsp,0x40
 4ac:	mov    rsp,rbp
 4af:	pop    rbp
 4b0:	ret
 4b1:	mov    r14,rdi
 4b4:	mov    rax,QWORD PTR [rip+0x0]        # 4bb <botlish_fn_1+0x203>
			4b7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 4bb:	call   rax
 4bd:	xor    rax,rax
 4c0:	mov    rbx,QWORD PTR [rsp+0x10]
 4c5:	mov    r12,QWORD PTR [rsp+0x18]
 4ca:	mov    r13,QWORD PTR [rsp+0x20]
 4cf:	mov    r14,QWORD PTR [rsp+0x28]
 4d4:	mov    r15,QWORD PTR [rsp+0x30]
 4d9:	add    rsp,0x40
 4dd:	mov    rsp,rbp
 4e0:	pop    rbp
 4e1:	ret
 4e2:	add    BYTE PTR [rax],al
 4e4:	add    BYTE PTR [rax],al
 4e6:	add    BYTE PTR [rax],al
 4e8:	(bad)
 4e9:	add    BYTE PTR [rax],al
 4eb:	add    BYTE PTR [rax],al
 4ed:	add    BYTE PTR [rax],al
	...

00000000000004f0 <botlish_entry_1: matches_at<str, str, int>>:
 4f0:	push   rbp
 4f1:	mov    rbp,rsp
 4f4:	mov    rsi,QWORD PTR [rdx]
 4f7:	mov    r8,QWORD PTR [rdx+0x8]
 4fb:	mov    rcx,QWORD PTR [rdx+0x10]
 4ff:	mov    rdx,r8
 502:	call   507 <botlish_entry_1+0x17>
			503: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 507:	mov    rsp,rbp
 50a:	pop    rbp
 50b:	ret
 50c:	add    BYTE PTR [rax],al
	...

0000000000000510 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 510:	push   rbp
 511:	mov    rbp,rsp
 514:	sub    rsp,0x50
 518:	mov    QWORD PTR [rsp+0x20],rbx
 51d:	mov    QWORD PTR [rsp+0x28],r12
 522:	mov    QWORD PTR [rsp+0x30],r13
 527:	mov    QWORD PTR [rsp+0x38],r14
 52c:	mov    QWORD PTR [rsp+0x40],r15
 531:	mov    r10,QWORD PTR [rbp+0x10]
 535:	mov    r13,QWORD PTR [rdi]
 538:	mov    r11,QWORD PTR [rdi+0x8]
 53c:	lea    rax,[r13+0x38]
 540:	cmp    rax,r11
 543:	ja     91f <botlish_fn_2+0x40f>
 549:	lea    r11,[r13+0x38]
 54d:	mov    QWORD PTR [rdi],r11
 550:	mov    r14,rdi
 553:	mov    QWORD PTR [r13+0x0],0x0
 55b:	mov    QWORD PTR [r13+0x8],0x0
 563:	mov    QWORD PTR [r13+0x10],0x0
 56b:	mov    QWORD PTR [r13+0x18],0x0
 573:	mov    QWORD PTR [r13+0x20],0x0
 57b:	mov    QWORD PTR [r13+0x28],0x0
 583:	mov    QWORD PTR [r13+0x30],0x0
 58b:	mov    QWORD PTR [r13+0x0],rsi
 58f:	mov    r15,rsi
 592:	mov    QWORD PTR [r13+0x8],rdx
 596:	mov    QWORD PTR [r13+0x10],rcx
 59a:	mov    r12,rcx
 59d:	mov    QWORD PTR [r13+0x18],r8
 5a1:	mov    QWORD PTR [r13+0x20],r9
 5a5:	mov    QWORD PTR [r13+0x28],r10
 5a9:	mov    QWORD PTR [rsp+0x10],r10
 5ae:	mov    QWORD PTR [rsp],r8
 5b2:	mov    QWORD PTR [rsp+0x8],r9
 5b7:	mov    rax,QWORD PTR [rip+0x0]        # 5be <botlish_fn_2+0xae>
			5ba: R_X86_64_GOTPCREL	rt_str_len-0x4
 5be:	mov    rbx,rdx
 5c1:	mov    rsi,rbx
 5c4:	mov    rdi,r14
 5c7:	call   rax
 5c9:	mov    QWORD PTR [r13+0x30],rax
 5cd:	mov    rsi,QWORD PTR [rsp]
 5d1:	mov    rcx,rsi
 5d4:	and    rcx,rax
 5d7:	test   rcx,0x1
 5de:	jne    5f0 <botlish_fn_2+0xe0>
 5e4:	mov    rdx,rax
 5e7:	mov    QWORD PTR [rsp],rsi
 5eb:	jmp    611 <botlish_fn_2+0x101>
 5f0:	lea    rcx,[rax-0x1]
 5f4:	mov    rdx,rax
 5f7:	mov    rax,rsi
 5fa:	add    rax,rcx
 5fd:	mov    QWORD PTR [rsp],rsi
 601:	mov    QWORD PTR [rsp+0x18],rax
 606:	seto   al
 609:	test   al,al
 60b:	je     626 <botlish_fn_2+0x116>
 611:	mov    rax,QWORD PTR [rip+0x0]        # 618 <botlish_fn_2+0x108>
			614: R_X86_64_GOTPCREL	rt_int_add-0x4
 618:	mov    rsi,QWORD PTR [rsp]
 61c:	mov    rdi,r14
 61f:	call   rax
 621:	mov    QWORD PTR [rsp+0x18],rax
 626:	mov    rax,QWORD PTR [rip+0x0]        # 62d <botlish_fn_2+0x11d>
			629: R_X86_64_GOTPCREL	rt_str_len-0x4
 62d:	mov    rsi,r15
 630:	mov    rdi,r14
 633:	call   rax
 635:	mov    rsi,QWORD PTR [rsp+0x18]
 63a:	mov    rcx,rsi
 63d:	and    rcx,rax
 640:	mov    rdx,rax
 643:	test   rcx,0x1
 64a:	jne    671 <botlish_fn_2+0x161>
 650:	mov    rax,QWORD PTR [rip+0x0]        # 657 <botlish_fn_2+0x147>
			653: R_X86_64_GOTPCREL	rt_int_cmp-0x4
 657:	mov    rdi,r14
 65a:	call   rax
 65c:	mov    ecx,0x2
 661:	test   rax,rax
 664:	cmovg  rcx,QWORD PTR [rip+0x2e4]        # 950 <botlish_fn_2+0x440>
 66c:	jmp    681 <botlish_fn_2+0x171>
 671:	mov    ecx,0x2
 676:	cmp    rsi,rdx
 679:	cmovg  rcx,QWORD PTR [rip+0x2cf]        # 950 <botlish_fn_2+0x440>
 681:	cmp    rcx,0x6
 685:	je     86c <botlish_fn_2+0x35c>
 68b:	mov    rcx,QWORD PTR [rsp]
 68f:	mov    rdx,rbx
 692:	mov    rsi,r15
 695:	mov    rdi,r14
 698:	call   69d <botlish_fn_2+0x18d>
			699: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 69d:	test   rax,rax
 6a0:	jne    6ae <botlish_fn_2+0x19e>
 6a6:	mov    rdi,r14
 6a9:	jmp    8cc <botlish_fn_2+0x3bc>
 6ae:	cmp    rax,0x6
 6b2:	je     740 <botlish_fn_2+0x230>
 6b8:	mov    QWORD PTR [r13+0x30],0x3
 6c0:	mov    rsi,QWORD PTR [rsp]
 6c4:	test   rsi,0x1
 6cb:	je     6f3 <botlish_fn_2+0x1e3>
 6d1:	mov    rsi,QWORD PTR [rsp]
 6d5:	mov    rax,rsi
 6d8:	add    rax,0x2
 6dc:	seto   cl
 6df:	test   cl,cl
 6e1:	jne    6f3 <botlish_fn_2+0x1e3>
 6e7:	mov    rsi,r15
 6ea:	mov    QWORD PTR [rsp],rax
 6ee:	jmp    70f <botlish_fn_2+0x1ff>
 6f3:	mov    edx,0x3
 6f8:	mov    rax,QWORD PTR [rip+0x0]        # 6ff <botlish_fn_2+0x1ef>
			6fb: R_X86_64_GOTPCREL	rt_int_add-0x4
 6ff:	mov    rsi,QWORD PTR [rsp]
 703:	mov    rdi,r14
 706:	call   rax
 708:	mov    rsi,r15
 70b:	mov    QWORD PTR [rsp],rax
 70f:	mov    rsi,r15
 712:	mov    QWORD PTR [r13+0x0],rsi
 716:	mov    QWORD PTR [r13+0x8],rbx
 71a:	mov    QWORD PTR [r13+0x10],r12
 71e:	mov    rsi,QWORD PTR [rsp]
 722:	mov    QWORD PTR [r13+0x18],rsi
 726:	mov    rdx,QWORD PTR [rsp+0x8]
 72b:	mov    QWORD PTR [r13+0x20],rdx
 72f:	mov    rsi,QWORD PTR [rsp+0x10]
 734:	mov    QWORD PTR [r13+0x28],rsi
 738:	mov    rdx,rbx
 73b:	jmp    5b7 <botlish_fn_2+0xa7>
 740:	mov    rdx,QWORD PTR [rsp+0x8]
 745:	mov    rax,QWORD PTR [rip+0x0]        # 74c <botlish_fn_2+0x23c>
			748: R_X86_64_GOTPCREL	rt_substr-0x4
 74c:	mov    rcx,QWORD PTR [rsp]
 750:	mov    rsi,r15
 753:	mov    rdi,r14
 756:	call   rax
 758:	test   rax,rax
 75b:	jne    769 <botlish_fn_2+0x259>
 761:	mov    rdi,r14
 764:	jmp    8cc <botlish_fn_2+0x3bc>
 769:	mov    QWORD PTR [r13+0x20],rax
 76d:	mov    rdx,rax
 770:	mov    r8,QWORD PTR [rip+0x0]        # 777 <botlish_fn_2+0x267>
			773: R_X86_64_GOTPCREL	rt_str_cat-0x4
 777:	mov    rsi,QWORD PTR [rsp+0x10]
 77c:	mov    rdi,r14
 77f:	call   r8
 782:	test   rax,rax
 785:	jne    793 <botlish_fn_2+0x283>
 78b:	mov    rdi,r14
 78e:	jmp    8cc <botlish_fn_2+0x3bc>
 793:	mov    QWORD PTR [r13+0x20],rax
 797:	mov    QWORD PTR [rsp+0x18],rax
 79c:	mov    r8,QWORD PTR [rip+0x0]        # 7a3 <botlish_fn_2+0x293>
			79f: R_X86_64_GOTPCREL	rt_str_len-0x4
 7a3:	mov    rsi,rbx
 7a6:	mov    rdi,r14
 7a9:	call   r8
 7ac:	mov    QWORD PTR [r13+0x28],rax
 7b0:	mov    rsi,QWORD PTR [rsp]
 7b4:	mov    r8,rsi
 7b7:	and    r8,rax
 7ba:	test   r8,0x1
 7c1:	jne    7cf <botlish_fn_2+0x2bf>
 7c7:	mov    rdx,rax
 7ca:	jmp    7f7 <botlish_fn_2+0x2e7>
 7cf:	lea    r11,[rax-0x1]
 7d3:	mov    rdx,rax
 7d6:	mov    rsi,QWORD PTR [rsp]
 7da:	mov    r10,rsi
 7dd:	add    r10,r11
 7e0:	seto   al
 7e3:	test   al,al
 7e5:	jne    7f7 <botlish_fn_2+0x2e7>
 7eb:	mov    rsi,r10
 7ee:	mov    QWORD PTR [rsp],r10
 7f2:	jmp    80e <botlish_fn_2+0x2fe>
 7f7:	mov    rax,QWORD PTR [rip+0x0]        # 7fe <botlish_fn_2+0x2ee>
			7fa: R_X86_64_GOTPCREL	rt_int_add-0x4
 7fe:	mov    rsi,QWORD PTR [rsp]
 802:	mov    rdi,r14
 805:	call   rax
 807:	mov    rsi,rax
 80a:	mov    QWORD PTR [rsp],rax
 80e:	mov    QWORD PTR [r13+0x18],rsi
 812:	mov    rax,QWORD PTR [rip+0x0]        # 819 <botlish_fn_2+0x309>
			815: R_X86_64_GOTPCREL	rt_str_cat-0x4
 819:	mov    rsi,QWORD PTR [rsp+0x18]
 81e:	mov    rdx,r12
 821:	mov    rdi,r14
 824:	call   rax
 826:	test   rax,rax
 829:	jne    837 <botlish_fn_2+0x327>
 82f:	mov    rdi,r14
 832:	jmp    8cc <botlish_fn_2+0x3bc>
 837:	mov    rsi,r15
 83a:	mov    QWORD PTR [r13+0x0],rsi
 83e:	mov    QWORD PTR [r13+0x8],rbx
 842:	mov    QWORD PTR [r13+0x10],r12
 846:	mov    rsi,QWORD PTR [rsp]
 84a:	mov    QWORD PTR [r13+0x18],rsi
 84e:	mov    QWORD PTR [r13+0x20],rsi
 852:	mov    QWORD PTR [r13+0x28],rax
 856:	mov    rdx,rbx
 859:	mov    rcx,QWORD PTR [rsp]
 85d:	mov    QWORD PTR [rsp+0x8],rcx
 862:	mov    QWORD PTR [rsp+0x10],rax
 867:	jmp    5b7 <botlish_fn_2+0xa7>
 86c:	mov    rax,QWORD PTR [rip+0x0]        # 873 <botlish_fn_2+0x363>
			86f: R_X86_64_GOTPCREL	rt_str_len-0x4
 873:	mov    rsi,r15
 876:	mov    rdi,r14
 879:	call   rax
 87b:	mov    QWORD PTR [r13+0x8],rax
 87f:	mov    r8,QWORD PTR [rip+0x0]        # 886 <botlish_fn_2+0x376>
			882: R_X86_64_GOTPCREL	rt_substr-0x4
 886:	mov    rcx,rax
 889:	mov    rdx,QWORD PTR [rsp+0x8]
 88e:	mov    rsi,r15
 891:	mov    rdi,r14
 894:	call   r8
 897:	test   rax,rax
 89a:	jne    8a8 <botlish_fn_2+0x398>
 8a0:	mov    rdi,r14
 8a3:	jmp    8cc <botlish_fn_2+0x3bc>
 8a8:	mov    QWORD PTR [r13+0x0],rax
 8ac:	mov    rdx,rax
 8af:	mov    rax,QWORD PTR [rip+0x0]        # 8b6 <botlish_fn_2+0x3a6>
			8b2: R_X86_64_GOTPCREL	rt_str_cat-0x4
 8b6:	mov    rsi,QWORD PTR [rsp+0x10]
 8bb:	mov    rdi,r14
 8be:	call   rax
 8c0:	test   rax,rax
 8c3:	jne    8f7 <botlish_fn_2+0x3e7>
 8c9:	mov    rdi,r14
 8cc:	mov    rdi,r14
 8cf:	mov    QWORD PTR [rdi],r13
 8d2:	xor    rax,rax
 8d5:	mov    rbx,QWORD PTR [rsp+0x20]
 8da:	mov    r12,QWORD PTR [rsp+0x28]
 8df:	mov    r13,QWORD PTR [rsp+0x30]
 8e4:	mov    r14,QWORD PTR [rsp+0x38]
 8e9:	mov    r15,QWORD PTR [rsp+0x40]
 8ee:	add    rsp,0x50
 8f2:	mov    rsp,rbp
 8f5:	pop    rbp
 8f6:	ret
 8f7:	mov    rdi,r14
 8fa:	mov    QWORD PTR [rdi],r13
 8fd:	mov    rbx,QWORD PTR [rsp+0x20]
 902:	mov    r12,QWORD PTR [rsp+0x28]
 907:	mov    r13,QWORD PTR [rsp+0x30]
 90c:	mov    r14,QWORD PTR [rsp+0x38]
 911:	mov    r15,QWORD PTR [rsp+0x40]
 916:	add    rsp,0x50
 91a:	mov    rsp,rbp
 91d:	pop    rbp
 91e:	ret
 91f:	mov    r14,rdi
 922:	mov    rax,QWORD PTR [rip+0x0]        # 929 <botlish_fn_2+0x419>
			925: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 929:	call   rax
 92b:	xor    rax,rax
 92e:	mov    rbx,QWORD PTR [rsp+0x20]
 933:	mov    r12,QWORD PTR [rsp+0x28]
 938:	mov    r13,QWORD PTR [rsp+0x30]
 93d:	mov    r14,QWORD PTR [rsp+0x38]
 942:	mov    r15,QWORD PTR [rsp+0x40]
 947:	add    rsp,0x50
 94b:	mov    rsp,rbp
 94e:	pop    rbp
 94f:	ret
 950:	(bad)
 951:	add    BYTE PTR [rax],al
 953:	add    BYTE PTR [rax],al
 955:	add    BYTE PTR [rax],al
	...

0000000000000958 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 958:	push   rbp
 959:	mov    rbp,rsp
 95c:	sub    rsp,0x10
 960:	mov    rsi,QWORD PTR [rdx]
 963:	mov    r10,QWORD PTR [rdx+0x8]
 967:	mov    rcx,QWORD PTR [rdx+0x10]
 96b:	mov    r8,QWORD PTR [rdx+0x18]
 96f:	mov    r9,QWORD PTR [rdx+0x20]
 973:	mov    r11,QWORD PTR [rdx+0x28]
 977:	mov    QWORD PTR [rsp],r11
 97b:	mov    rdx,r10
 97e:	call   983 <botlish_entry_2+0x2b>
			97f: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 983:	add    rsp,0x10
 987:	mov    rsp,rbp
 98a:	pop    rbp
 98b:	ret

000000000000098c <botlish_fn_3: replace<str, str, str>>:
 98c:	push   rbp
 98d:	mov    rbp,rsp
 990:	sub    rsp,0x40
 994:	mov    QWORD PTR [rsp+0x10],rbx
 999:	mov    QWORD PTR [rsp+0x18],r12
 99e:	mov    QWORD PTR [rsp+0x20],r13
 9a3:	mov    QWORD PTR [rsp+0x28],r14
 9a8:	mov    QWORD PTR [rsp+0x30],r15
 9ad:	mov    r13,rsi
 9b0:	mov    r15,rdx
 9b3:	mov    rbx,QWORD PTR [rdi]
 9b6:	mov    rax,QWORD PTR [rdi+0x8]
 9ba:	lea    rdx,[rbx+0x30]
 9be:	cmp    rdx,rax
 9c1:	ja     af0 <botlish_fn_3+0x164>
 9c7:	lea    rax,[rbx+0x30]
 9cb:	mov    QWORD PTR [rdi],rax
 9ce:	mov    r12,rdi
 9d1:	mov    QWORD PTR [rbx],0x0
 9d8:	mov    QWORD PTR [rbx+0x8],0x0
 9e0:	mov    QWORD PTR [rbx+0x10],0x0
 9e8:	mov    QWORD PTR [rbx+0x18],0x0
 9f0:	mov    QWORD PTR [rbx+0x20],0x0
 9f8:	mov    QWORD PTR [rbx+0x28],0x0
 a00:	mov    rsi,r13
 a03:	mov    QWORD PTR [rbx],rsi
 a06:	mov    rdx,r15
 a09:	mov    QWORD PTR [rbx+0x8],rdx
 a0d:	mov    QWORD PTR [rbx+0x10],rcx
 a11:	mov    r14,rcx
 a14:	mov    rax,QWORD PTR [rip+0x0]        # a1b <botlish_fn_3+0x8f>
			a17: R_X86_64_GOTPCREL	rt_str_len-0x4
 a1b:	mov    rsi,r15
 a1e:	mov    rdi,r12
 a21:	call   rax
 a23:	sar    rax,1
 a26:	test   rax,rax
 a29:	je     ac5 <botlish_fn_3+0x139>
 a2f:	mov    r9d,0x1
 a35:	mov    QWORD PTR [rbx+0x18],0x1
 a3d:	mov    QWORD PTR [rbx+0x20],0x1
 a45:	mov    rdi,r12
 a48:	mov    rax,QWORD PTR [rdi+0x10]
 a4c:	mov    rax,QWORD PTR [rax+0x40]
 a50:	mov    QWORD PTR [rbx+0x28],rax
 a54:	mov    QWORD PTR [rsp],rax
 a58:	mov    rcx,r14
 a5b:	mov    rdx,r15
 a5e:	mov    rsi,r13
 a61:	mov    r8,r9
 a64:	call   a69 <botlish_fn_3+0xdd>
			a65: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 a69:	test   rax,rax
 a6c:	jne    a9d <botlish_fn_3+0x111>
 a72:	mov    rdi,r12
 a75:	mov    QWORD PTR [rdi],rbx
 a78:	xor    rax,rax
 a7b:	mov    rbx,QWORD PTR [rsp+0x10]
 a80:	mov    r12,QWORD PTR [rsp+0x18]
 a85:	mov    r13,QWORD PTR [rsp+0x20]
 a8a:	mov    r14,QWORD PTR [rsp+0x28]
 a8f:	mov    r15,QWORD PTR [rsp+0x30]
 a94:	add    rsp,0x40
 a98:	mov    rsp,rbp
 a9b:	pop    rbp
 a9c:	ret
 a9d:	mov    rdi,r12
 aa0:	mov    QWORD PTR [rdi],rbx
 aa3:	mov    rbx,QWORD PTR [rsp+0x10]
 aa8:	mov    r12,QWORD PTR [rsp+0x18]
 aad:	mov    r13,QWORD PTR [rsp+0x20]
 ab2:	mov    r14,QWORD PTR [rsp+0x28]
 ab7:	mov    r15,QWORD PTR [rsp+0x30]
 abc:	add    rsp,0x40
 ac0:	mov    rsp,rbp
 ac3:	pop    rbp
 ac4:	ret
 ac5:	mov    rdi,r12
 ac8:	mov    QWORD PTR [rdi],rbx
 acb:	mov    rax,r13
 ace:	mov    rbx,QWORD PTR [rsp+0x10]
 ad3:	mov    r12,QWORD PTR [rsp+0x18]
 ad8:	mov    r13,QWORD PTR [rsp+0x20]
 add:	mov    r14,QWORD PTR [rsp+0x28]
 ae2:	mov    r15,QWORD PTR [rsp+0x30]
 ae7:	add    rsp,0x40
 aeb:	mov    rsp,rbp
 aee:	pop    rbp
 aef:	ret
 af0:	mov    r12,rdi
 af3:	mov    rax,QWORD PTR [rip+0x0]        # afa <botlish_fn_3+0x16e>
			af6: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 afa:	call   rax
 afc:	xor    rax,rax
 aff:	mov    rbx,QWORD PTR [rsp+0x10]
 b04:	mov    r12,QWORD PTR [rsp+0x18]
 b09:	mov    r13,QWORD PTR [rsp+0x20]
 b0e:	mov    r14,QWORD PTR [rsp+0x28]
 b13:	mov    r15,QWORD PTR [rsp+0x30]
 b18:	add    rsp,0x40
 b1c:	mov    rsp,rbp
 b1f:	pop    rbp
 b20:	ret

0000000000000b21 <botlish_entry_3: replace<str, str, str>>:
 b21:	push   rbp
 b22:	mov    rbp,rsp
 b25:	mov    rsi,QWORD PTR [rdx]
 b28:	mov    r8,QWORD PTR [rdx+0x8]
 b2c:	mov    rcx,QWORD PTR [rdx+0x10]
 b30:	mov    rdx,r8
 b33:	call   b38 <botlish_entry_3+0x17>
			b34: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 b38:	mov    rsp,rbp
 b3b:	pop    rbp
 b3c:	ret

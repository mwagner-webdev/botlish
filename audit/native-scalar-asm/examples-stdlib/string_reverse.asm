; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 1172  (per function: 530 430 212)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> reverse_from<str, int, str>
;   botlish_fn_2 / botlish_entry_2 -> reverse_chars<str>


string_reverse.asm.o:     file format elf64-x86-64


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
  21:	mov    r14,QWORD PTR [rdi]
  24:	mov    rax,QWORD PTR [rdi+0x8]
  28:	lea    rcx,[r14+0x28]
  2c:	cmp    rcx,rax
  2f:	ja     1cd <botlish_fn_0+0x1cd>
  35:	lea    rax,[r14+0x28]
  39:	mov    QWORD PTR [rdi],rax
  3c:	mov    QWORD PTR [r14],0x0
  43:	mov    QWORD PTR [r14+0x8],0x0
  4b:	mov    QWORD PTR [r14+0x10],0x0
  53:	mov    QWORD PTR [r14+0x18],0x0
  5b:	mov    QWORD PTR [r14+0x20],0x0
  63:	mov    rax,QWORD PTR [rdi+0x10]
  67:	mov    r15,rdi
  6a:	mov    rsi,QWORD PTR [rax]
  6d:	mov    QWORD PTR [r14],rsi
  70:	call   75 <botlish_fn_0+0x75>
			71: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  75:	mov    rbx,rax
  78:	test   rbx,rbx
  7b:	jne    89 <botlish_fn_0+0x89>
  81:	mov    rdi,r15
  84:	jmp    17a <botlish_fn_0+0x17a>
  89:	mov    QWORD PTR [r14],rbx
  8c:	mov    rdi,r15
  8f:	mov    rax,QWORD PTR [rdi+0x10]
  93:	mov    rsi,QWORD PTR [rax+0x8]
  97:	mov    QWORD PTR [r14+0x8],rsi
  9b:	call   a0 <botlish_fn_0+0xa0>
			9c: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  a0:	mov    r12,rax
  a3:	test   r12,r12
  a6:	jne    b4 <botlish_fn_0+0xb4>
  ac:	mov    rdi,r15
  af:	jmp    17a <botlish_fn_0+0x17a>
  b4:	mov    QWORD PTR [r14+0x8],r12
  b8:	mov    rdi,r15
  bb:	mov    rax,QWORD PTR [rdi+0x10]
  bf:	mov    rsi,QWORD PTR [rax+0x10]
  c3:	mov    QWORD PTR [r14+0x10],rsi
  c7:	call   cc <botlish_fn_0+0xcc>
			c8: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  cc:	mov    r13,rax
  cf:	test   r13,r13
  d2:	jne    e0 <botlish_fn_0+0xe0>
  d8:	mov    rdi,r15
  db:	jmp    17a <botlish_fn_0+0x17a>
  e0:	mov    QWORD PTR [r14+0x10],r13
  e4:	mov    rdi,r15
  e7:	mov    rax,QWORD PTR [rdi+0x10]
  eb:	mov    rsi,QWORD PTR [rax+0x18]
  ef:	mov    QWORD PTR [r14+0x18],rsi
  f3:	call   f8 <botlish_fn_0+0xf8>
			f4: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  f8:	test   rax,rax
  fb:	jne    109 <botlish_fn_0+0x109>
 101:	mov    rdi,r15
 104:	jmp    17a <botlish_fn_0+0x17a>
 109:	mov    QWORD PTR [r14+0x18],rax
 10d:	mov    rdi,r15
 110:	mov    QWORD PTR [rsp+0x28],rax
 115:	mov    rax,QWORD PTR [rdi+0x10]
 119:	mov    rsi,QWORD PTR [rax+0x20]
 11d:	mov    QWORD PTR [r14+0x20],rsi
 121:	call   126 <botlish_fn_0+0x126>
			122: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 126:	test   rax,rax
 129:	jne    137 <botlish_fn_0+0x137>
 12f:	mov    rdi,r15
 132:	jmp    17a <botlish_fn_0+0x17a>
 137:	mov    QWORD PTR [r14+0x20],rax
 13b:	lea    rdx,[rsp]
 13f:	mov    QWORD PTR [rsp],rbx
 143:	mov    QWORD PTR [rsp+0x8],r12
 148:	mov    QWORD PTR [rsp+0x10],r13
 14d:	mov    rcx,QWORD PTR [rsp+0x28]
 152:	mov    QWORD PTR [rsp+0x18],rcx
 157:	mov    QWORD PTR [rsp+0x20],rax
 15c:	mov    esi,0x5
 161:	mov    r8,QWORD PTR [rip+0x0]        # 168 <botlish_fn_0+0x168>
			164: R_X86_64_GOTPCREL	rt_list_new-0x4
 168:	mov    rdi,r15
 16b:	call   r8
 16e:	test   rax,rax
 171:	jne    1a5 <botlish_fn_0+0x1a5>
 177:	mov    rdi,r15
 17a:	mov    rdi,r15
 17d:	mov    QWORD PTR [rdi],r14
 180:	xor    rax,rax
 183:	mov    rbx,QWORD PTR [rsp+0x30]
 188:	mov    r12,QWORD PTR [rsp+0x38]
 18d:	mov    r13,QWORD PTR [rsp+0x40]
 192:	mov    r14,QWORD PTR [rsp+0x48]
 197:	mov    r15,QWORD PTR [rsp+0x50]
 19c:	add    rsp,0x60
 1a0:	mov    rsp,rbp
 1a3:	pop    rbp
 1a4:	ret
 1a5:	mov    rdi,r15
 1a8:	mov    QWORD PTR [rdi],r14
 1ab:	mov    rbx,QWORD PTR [rsp+0x30]
 1b0:	mov    r12,QWORD PTR [rsp+0x38]
 1b5:	mov    r13,QWORD PTR [rsp+0x40]
 1ba:	mov    r14,QWORD PTR [rsp+0x48]
 1bf:	mov    r15,QWORD PTR [rsp+0x50]
 1c4:	add    rsp,0x60
 1c8:	mov    rsp,rbp
 1cb:	pop    rbp
 1cc:	ret
 1cd:	mov    r15,rdi
 1d0:	mov    rax,QWORD PTR [rip+0x0]        # 1d7 <botlish_fn_0+0x1d7>
			1d3: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 1d7:	call   rax
 1d9:	xor    rax,rax
 1dc:	mov    rbx,QWORD PTR [rsp+0x30]
 1e1:	mov    r12,QWORD PTR [rsp+0x38]
 1e6:	mov    r13,QWORD PTR [rsp+0x40]
 1eb:	mov    r14,QWORD PTR [rsp+0x48]
 1f0:	mov    r15,QWORD PTR [rsp+0x50]
 1f5:	add    rsp,0x60
 1f9:	mov    rsp,rbp
 1fc:	pop    rbp
 1fd:	ret

00000000000001fe <botlish_entry_0: <program entry>>:
 1fe:	push   rbp
 1ff:	mov    rbp,rsp
 202:	call   207 <botlish_entry_0+0x9>
			203: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 207:	mov    rsp,rbp
 20a:	pop    rbp
 20b:	ret

000000000000020c <botlish_fn_1: reverse_from<str, int, str>>:
 20c:	push   rbp
 20d:	mov    rbp,rsp
 210:	sub    rsp,0x30
 214:	mov    QWORD PTR [rsp],rbx
 218:	mov    QWORD PTR [rsp+0x8],r12
 21d:	mov    QWORD PTR [rsp+0x10],r13
 222:	mov    QWORD PTR [rsp+0x18],r14
 227:	mov    QWORD PTR [rsp+0x20],r15
 22c:	mov    r13,QWORD PTR [rdi]
 22f:	mov    rax,QWORD PTR [rdi+0x8]
 233:	lea    r8,[r13+0x20]
 237:	cmp    r8,rax
 23a:	ja     362 <botlish_fn_1+0x156>
 240:	lea    rax,[r13+0x20]
 244:	mov    QWORD PTR [rdi],rax
 247:	mov    r14,rdi
 24a:	mov    QWORD PTR [r13+0x0],0x0
 252:	mov    QWORD PTR [r13+0x8],0x0
 25a:	mov    QWORD PTR [r13+0x10],0x0
 262:	mov    QWORD PTR [r13+0x18],0x0
 26a:	mov    QWORD PTR [r13+0x0],rsi
 26e:	mov    QWORD PTR [r13+0x8],rcx
 272:	sar    rdx,1
 275:	mov    r12,rdx
 278:	mov    r15,rcx
 27b:	mov    rax,QWORD PTR [rip+0x0]        # 282 <botlish_fn_1+0x76>
			27e: R_X86_64_GOTPCREL	rt_str_len-0x4
 282:	mov    rbx,rsi
 285:	mov    rdi,r14
 288:	call   rax
 28a:	sar    rax,1
 28d:	cmp    r12,rax
 290:	je     338 <botlish_fn_1+0x12c>
 296:	mov    rdx,r12
 299:	shl    rdx,1
 29c:	or     rdx,0x1
 2a0:	mov    QWORD PTR [r13+0x10],rdx
 2a4:	add    r12,0x1
 2ab:	mov    rcx,r12
 2ae:	shl    rcx,1
 2b1:	or     rcx,0x1
 2b5:	mov    QWORD PTR [r13+0x18],rcx
 2b9:	mov    rax,QWORD PTR [rip+0x0]        # 2c0 <botlish_fn_1+0xb4>
			2bc: R_X86_64_GOTPCREL	rt_substr-0x4
 2c0:	mov    rsi,rbx
 2c3:	mov    rdi,r14
 2c6:	call   rax
 2c8:	test   rax,rax
 2cb:	jne    2d9 <botlish_fn_1+0xcd>
 2d1:	mov    rdi,r14
 2d4:	jmp    2fb <botlish_fn_1+0xef>
 2d9:	mov    QWORD PTR [r13+0x10],rax
 2dd:	mov    rsi,rax
 2e0:	mov    rax,QWORD PTR [rip+0x0]        # 2e7 <botlish_fn_1+0xdb>
			2e3: R_X86_64_GOTPCREL	rt_str_cat-0x4
 2e7:	mov    rdx,r15
 2ea:	mov    rdi,r14
 2ed:	call   rax
 2ef:	test   rax,rax
 2f2:	jne    325 <botlish_fn_1+0x119>
 2f8:	mov    rdi,r14
 2fb:	mov    rdi,r14
 2fe:	mov    QWORD PTR [rdi],r13
 301:	xor    rax,rax
 304:	mov    rbx,QWORD PTR [rsp]
 308:	mov    r12,QWORD PTR [rsp+0x8]
 30d:	mov    r13,QWORD PTR [rsp+0x10]
 312:	mov    r14,QWORD PTR [rsp+0x18]
 317:	mov    r15,QWORD PTR [rsp+0x20]
 31c:	add    rsp,0x30
 320:	mov    rsp,rbp
 323:	pop    rbp
 324:	ret
 325:	mov    QWORD PTR [r13+0x0],rbx
 329:	mov    QWORD PTR [r13+0x8],rax
 32d:	mov    rsi,rbx
 330:	mov    r15,rax
 333:	jmp    27b <botlish_fn_1+0x6f>
 338:	mov    rdi,r14
 33b:	mov    QWORD PTR [rdi],r13
 33e:	mov    rax,r15
 341:	mov    rbx,QWORD PTR [rsp]
 345:	mov    r12,QWORD PTR [rsp+0x8]
 34a:	mov    r13,QWORD PTR [rsp+0x10]
 34f:	mov    r14,QWORD PTR [rsp+0x18]
 354:	mov    r15,QWORD PTR [rsp+0x20]
 359:	add    rsp,0x30
 35d:	mov    rsp,rbp
 360:	pop    rbp
 361:	ret
 362:	mov    r14,rdi
 365:	mov    rax,QWORD PTR [rip+0x0]        # 36c <botlish_fn_1+0x160>
			368: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 36c:	call   rax
 36e:	xor    rax,rax
 371:	mov    rbx,QWORD PTR [rsp]
 375:	mov    r12,QWORD PTR [rsp+0x8]
 37a:	mov    r13,QWORD PTR [rsp+0x10]
 37f:	mov    r14,QWORD PTR [rsp+0x18]
 384:	mov    r15,QWORD PTR [rsp+0x20]
 389:	add    rsp,0x30
 38d:	mov    rsp,rbp
 390:	pop    rbp
 391:	ret

0000000000000392 <botlish_entry_1: reverse_from<str, int, str>>:
 392:	push   rbp
 393:	mov    rbp,rsp
 396:	mov    rsi,QWORD PTR [rdx]
 399:	mov    r8,QWORD PTR [rdx+0x8]
 39d:	mov    rcx,QWORD PTR [rdx+0x10]
 3a1:	mov    rdx,r8
 3a4:	call   3a9 <botlish_entry_1+0x17>
			3a5: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 3a9:	mov    rsp,rbp
 3ac:	pop    rbp
 3ad:	ret

00000000000003ae <botlish_fn_2: reverse_chars<str>>:
 3ae:	push   rbp
 3af:	mov    rbp,rsp
 3b2:	sub    rsp,0x10
 3b6:	mov    QWORD PTR [rsp],rbx
 3ba:	mov    QWORD PTR [rsp+0x8],r12
 3bf:	mov    rbx,QWORD PTR [rdi]
 3c2:	mov    rax,QWORD PTR [rdi+0x8]
 3c6:	lea    rcx,[rbx+0x18]
 3ca:	cmp    rcx,rax
 3cd:	ja     450 <botlish_fn_2+0xa2>
 3d3:	lea    rax,[rbx+0x18]
 3d7:	mov    QWORD PTR [rdi],rax
 3da:	mov    QWORD PTR [rbx],0x0
 3e1:	mov    QWORD PTR [rbx+0x8],0x0
 3e9:	mov    QWORD PTR [rbx+0x10],0x0
 3f1:	mov    QWORD PTR [rbx],rsi
 3f4:	mov    edx,0x1
 3f9:	mov    QWORD PTR [rbx+0x8],0x1
 401:	mov    rax,QWORD PTR [rdi+0x10]
 405:	mov    r12,rdi
 408:	mov    rcx,QWORD PTR [rax]
 40b:	mov    QWORD PTR [rbx+0x10],rcx
 40f:	call   414 <botlish_fn_2+0x66>
			410: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 414:	test   rax,rax
 417:	jne    438 <botlish_fn_2+0x8a>
 41d:	mov    rdi,r12
 420:	mov    QWORD PTR [rdi],rbx
 423:	xor    rax,rax
 426:	mov    rbx,QWORD PTR [rsp]
 42a:	mov    r12,QWORD PTR [rsp+0x8]
 42f:	add    rsp,0x10
 433:	mov    rsp,rbp
 436:	pop    rbp
 437:	ret
 438:	mov    rdi,r12
 43b:	mov    QWORD PTR [rdi],rbx
 43e:	mov    rbx,QWORD PTR [rsp]
 442:	mov    r12,QWORD PTR [rsp+0x8]
 447:	add    rsp,0x10
 44b:	mov    rsp,rbp
 44e:	pop    rbp
 44f:	ret
 450:	mov    rax,QWORD PTR [rip+0x0]        # 457 <botlish_fn_2+0xa9>
			453: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 457:	call   rax
 459:	xor    rax,rax
 45c:	mov    rbx,QWORD PTR [rsp]
 460:	mov    r12,QWORD PTR [rsp+0x8]
 465:	add    rsp,0x10
 469:	mov    rsp,rbp
 46c:	pop    rbp
 46d:	ret

000000000000046e <botlish_entry_2: reverse_chars<str>>:
 46e:	push   rbp
 46f:	mov    rbp,rsp
 472:	mov    rsi,QWORD PTR [rdx]
 475:	call   47a <botlish_entry_2+0xc>
			476: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 47a:	mov    rsp,rbp
 47d:	pop    rbp
 47e:	ret

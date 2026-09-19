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
  2f:	ja     1c8 <botlish_fn_0+0x1c8>
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
  84:	jmp    175 <botlish_fn_0+0x175>
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
  af:	jmp    175 <botlish_fn_0+0x175>
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
  db:	jmp    175 <botlish_fn_0+0x175>
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
 104:	jmp    175 <botlish_fn_0+0x175>
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
 132:	jmp    175 <botlish_fn_0+0x175>
 137:	mov    QWORD PTR [r14+0x20],rax
 13b:	lea    rdx,[rsp]
 13f:	mov    QWORD PTR [rsp],rbx
 143:	mov    QWORD PTR [rsp+0x8],r12
 148:	mov    QWORD PTR [rsp+0x10],r13
 14d:	mov    rcx,QWORD PTR [rsp+0x28]
 152:	mov    QWORD PTR [rsp+0x18],rcx
 157:	mov    QWORD PTR [rsp+0x20],rax
 15c:	mov    esi,0x5
 161:	mov    rdi,r15
 164:	call   169 <botlish_fn_0+0x169>
			165: R_X86_64_PLT32	rt_list_new-0x4
 169:	test   rax,rax
 16c:	jne    1a0 <botlish_fn_0+0x1a0>
 172:	mov    rdi,r15
 175:	mov    rdi,r15
 178:	mov    QWORD PTR [rdi],r14
 17b:	xor    rax,rax
 17e:	mov    rbx,QWORD PTR [rsp+0x30]
 183:	mov    r12,QWORD PTR [rsp+0x38]
 188:	mov    r13,QWORD PTR [rsp+0x40]
 18d:	mov    r14,QWORD PTR [rsp+0x48]
 192:	mov    r15,QWORD PTR [rsp+0x50]
 197:	add    rsp,0x60
 19b:	mov    rsp,rbp
 19e:	pop    rbp
 19f:	ret
 1a0:	mov    rdi,r15
 1a3:	mov    QWORD PTR [rdi],r14
 1a6:	mov    rbx,QWORD PTR [rsp+0x30]
 1ab:	mov    r12,QWORD PTR [rsp+0x38]
 1b0:	mov    r13,QWORD PTR [rsp+0x40]
 1b5:	mov    r14,QWORD PTR [rsp+0x48]
 1ba:	mov    r15,QWORD PTR [rsp+0x50]
 1bf:	add    rsp,0x60
 1c3:	mov    rsp,rbp
 1c6:	pop    rbp
 1c7:	ret
 1c8:	mov    r15,rdi
 1cb:	call   1d0 <botlish_fn_0+0x1d0>
			1cc: R_X86_64_PLT32	rt_stack_overflow-0x4
 1d0:	xor    rax,rax
 1d3:	mov    rbx,QWORD PTR [rsp+0x30]
 1d8:	mov    r12,QWORD PTR [rsp+0x38]
 1dd:	mov    r13,QWORD PTR [rsp+0x40]
 1e2:	mov    r14,QWORD PTR [rsp+0x48]
 1e7:	mov    r15,QWORD PTR [rsp+0x50]
 1ec:	add    rsp,0x60
 1f0:	mov    rsp,rbp
 1f3:	pop    rbp
 1f4:	ret

00000000000001f5 <botlish_entry_0: <program entry>>:
 1f5:	push   rbp
 1f6:	mov    rbp,rsp
 1f9:	call   1fe <botlish_entry_0+0x9>
			1fa: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 1fe:	mov    rsp,rbp
 201:	pop    rbp
 202:	ret

0000000000000203 <botlish_fn_1: reverse_from<str, int, str>>:
 203:	push   rbp
 204:	mov    rbp,rsp
 207:	sub    rsp,0x30
 20b:	mov    QWORD PTR [rsp],rbx
 20f:	mov    QWORD PTR [rsp+0x8],r12
 214:	mov    QWORD PTR [rsp+0x10],r13
 219:	mov    QWORD PTR [rsp+0x18],r14
 21e:	mov    QWORD PTR [rsp+0x20],r15
 223:	mov    r13,QWORD PTR [rdi]
 226:	mov    rax,QWORD PTR [rdi+0x8]
 22a:	lea    r8,[r13+0x20]
 22e:	cmp    r8,rax
 231:	ja     34d <botlish_fn_1+0x14a>
 237:	lea    rax,[r13+0x20]
 23b:	mov    QWORD PTR [rdi],rax
 23e:	mov    r14,rdi
 241:	mov    QWORD PTR [r13+0x0],0x0
 249:	mov    QWORD PTR [r13+0x8],0x0
 251:	mov    QWORD PTR [r13+0x10],0x0
 259:	mov    QWORD PTR [r13+0x18],0x0
 261:	mov    QWORD PTR [r13+0x0],rsi
 265:	mov    QWORD PTR [r13+0x8],rcx
 269:	sar    rdx,1
 26c:	mov    r12,rdx
 26f:	mov    rbx,rsi
 272:	mov    r15,rcx
 275:	mov    rsi,rbx
 278:	mov    rdi,r14
 27b:	call   280 <botlish_fn_1+0x7d>
			27c: R_X86_64_PLT32	rt_str_len-0x4
 280:	sar    rax,1
 283:	cmp    r12,rax
 286:	je     323 <botlish_fn_1+0x120>
 28c:	mov    rdx,r12
 28f:	shl    rdx,1
 292:	or     rdx,0x1
 296:	mov    QWORD PTR [r13+0x10],rdx
 29a:	add    r12,0x1
 2a1:	mov    rcx,r12
 2a4:	shl    rcx,1
 2a7:	or     rcx,0x1
 2ab:	mov    QWORD PTR [r13+0x18],rcx
 2af:	mov    rsi,rbx
 2b2:	mov    rdi,r14
 2b5:	call   2ba <botlish_fn_1+0xb7>
			2b6: R_X86_64_PLT32	rt_substr-0x4
 2ba:	test   rax,rax
 2bd:	jne    2cb <botlish_fn_1+0xc8>
 2c3:	mov    rdi,r14
 2c6:	jmp    2e9 <botlish_fn_1+0xe6>
 2cb:	mov    QWORD PTR [r13+0x10],rax
 2cf:	mov    rdx,r15
 2d2:	mov    rsi,rax
 2d5:	mov    rdi,r14
 2d8:	call   2dd <botlish_fn_1+0xda>
			2d9: R_X86_64_PLT32	rt_str_cat-0x4
 2dd:	test   rax,rax
 2e0:	jne    313 <botlish_fn_1+0x110>
 2e6:	mov    rdi,r14
 2e9:	mov    rdi,r14
 2ec:	mov    QWORD PTR [rdi],r13
 2ef:	xor    rax,rax
 2f2:	mov    rbx,QWORD PTR [rsp]
 2f6:	mov    r12,QWORD PTR [rsp+0x8]
 2fb:	mov    r13,QWORD PTR [rsp+0x10]
 300:	mov    r14,QWORD PTR [rsp+0x18]
 305:	mov    r15,QWORD PTR [rsp+0x20]
 30a:	add    rsp,0x30
 30e:	mov    rsp,rbp
 311:	pop    rbp
 312:	ret
 313:	mov    QWORD PTR [r13+0x0],rbx
 317:	mov    QWORD PTR [r13+0x8],rax
 31b:	mov    r15,rax
 31e:	jmp    275 <botlish_fn_1+0x72>
 323:	mov    rdi,r14
 326:	mov    QWORD PTR [rdi],r13
 329:	mov    rax,r15
 32c:	mov    rbx,QWORD PTR [rsp]
 330:	mov    r12,QWORD PTR [rsp+0x8]
 335:	mov    r13,QWORD PTR [rsp+0x10]
 33a:	mov    r14,QWORD PTR [rsp+0x18]
 33f:	mov    r15,QWORD PTR [rsp+0x20]
 344:	add    rsp,0x30
 348:	mov    rsp,rbp
 34b:	pop    rbp
 34c:	ret
 34d:	mov    r14,rdi
 350:	call   355 <botlish_fn_1+0x152>
			351: R_X86_64_PLT32	rt_stack_overflow-0x4
 355:	xor    rax,rax
 358:	mov    rbx,QWORD PTR [rsp]
 35c:	mov    r12,QWORD PTR [rsp+0x8]
 361:	mov    r13,QWORD PTR [rsp+0x10]
 366:	mov    r14,QWORD PTR [rsp+0x18]
 36b:	mov    r15,QWORD PTR [rsp+0x20]
 370:	add    rsp,0x30
 374:	mov    rsp,rbp
 377:	pop    rbp
 378:	ret

0000000000000379 <botlish_entry_1: reverse_from<str, int, str>>:
 379:	push   rbp
 37a:	mov    rbp,rsp
 37d:	mov    rsi,QWORD PTR [rdx]
 380:	mov    r8,QWORD PTR [rdx+0x8]
 384:	mov    rcx,QWORD PTR [rdx+0x10]
 388:	mov    rdx,r8
 38b:	call   390 <botlish_entry_1+0x17>
			38c: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 390:	mov    rsp,rbp
 393:	pop    rbp
 394:	ret

0000000000000395 <botlish_fn_2: reverse_chars<str>>:
 395:	push   rbp
 396:	mov    rbp,rsp
 399:	sub    rsp,0x10
 39d:	mov    QWORD PTR [rsp],rbx
 3a1:	mov    QWORD PTR [rsp+0x8],r15
 3a6:	mov    r15,QWORD PTR [rdi]
 3a9:	mov    rax,QWORD PTR [rdi+0x8]
 3ad:	lea    rcx,[r15+0x18]
 3b1:	cmp    rcx,rax
 3b4:	ja     437 <botlish_fn_2+0xa2>
 3ba:	lea    rax,[r15+0x18]
 3be:	mov    QWORD PTR [rdi],rax
 3c1:	mov    QWORD PTR [r15],0x0
 3c8:	mov    QWORD PTR [r15+0x8],0x0
 3d0:	mov    QWORD PTR [r15+0x10],0x0
 3d8:	mov    QWORD PTR [r15],rsi
 3db:	mov    edx,0x1
 3e0:	mov    QWORD PTR [r15+0x8],0x1
 3e8:	mov    rax,QWORD PTR [rdi+0x10]
 3ec:	mov    rbx,rdi
 3ef:	mov    rcx,QWORD PTR [rax]
 3f2:	mov    QWORD PTR [r15+0x10],rcx
 3f6:	call   3fb <botlish_fn_2+0x66>
			3f7: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 3fb:	test   rax,rax
 3fe:	jne    41f <botlish_fn_2+0x8a>
 404:	mov    rdi,rbx
 407:	mov    QWORD PTR [rdi],r15
 40a:	xor    rax,rax
 40d:	mov    rbx,QWORD PTR [rsp]
 411:	mov    r15,QWORD PTR [rsp+0x8]
 416:	add    rsp,0x10
 41a:	mov    rsp,rbp
 41d:	pop    rbp
 41e:	ret
 41f:	mov    rdi,rbx
 422:	mov    QWORD PTR [rdi],r15
 425:	mov    rbx,QWORD PTR [rsp]
 429:	mov    r15,QWORD PTR [rsp+0x8]
 42e:	add    rsp,0x10
 432:	mov    rsp,rbp
 435:	pop    rbp
 436:	ret
 437:	call   43c <botlish_fn_2+0xa7>
			438: R_X86_64_PLT32	rt_stack_overflow-0x4
 43c:	xor    rax,rax
 43f:	mov    rbx,QWORD PTR [rsp]
 443:	mov    r15,QWORD PTR [rsp+0x8]
 448:	add    rsp,0x10
 44c:	mov    rsp,rbp
 44f:	pop    rbp
 450:	ret

0000000000000451 <botlish_entry_2: reverse_chars<str>>:
 451:	push   rbp
 452:	mov    rbp,rsp
 455:	mov    rsi,QWORD PTR [rdx]
 458:	call   45d <botlish_entry_2+0xc>
			459: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 45d:	mov    rsp,rbp
 460:	pop    rbp
 461:	ret

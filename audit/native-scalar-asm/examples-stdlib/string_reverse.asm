; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 1208  (per function: 224 476 90 418)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> reverse_from<str, int, str>
;   botlish_fn_2 / botlish_entry_2 -> reverse_chars<str>
;   botlish_fn_3 / botlish_entry_3 -> sample<generic>


string_reverse.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    QWORD PTR [rsp],rbx
   c:	mov    rbx,rdi
   f:	mov    rdi,rbx
  12:	call   17 <botlish_fn_0+0x17>
			13: R_X86_64_PLT32	botlish_fn_3-0x4 ; sample<generic>
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

00000000000000b6 <botlish_fn_1: reverse_from<str, int, str>>:
  b6:	push   rbp
  b7:	mov    rbp,rsp
  ba:	sub    rsp,0xa0
  c1:	mov    QWORD PTR [rsp+0x70],rbx
  c6:	mov    QWORD PTR [rsp+0x78],r12
  cb:	mov    QWORD PTR [rsp+0x80],r13
  d3:	mov    QWORD PTR [rsp+0x88],r14
  db:	mov    QWORD PTR [rsp+0x90],r15
  e3:	mov    QWORD PTR [rsp+0x60],rdi
  e8:	mov    QWORD PTR [rsp+0x10],0x0
  f1:	mov    QWORD PTR [rsp+0x18],0x0
  fa:	mov    QWORD PTR [rsp],rsi
  fe:	mov    QWORD PTR [rsp+0x8],rcx
 103:	mov    QWORD PTR [rsp+0x68],rcx
 108:	sar    rdx,1
 10b:	lea    r15,[rsp+0x30]
 110:	mov    rbx,rsi
 113:	mov    rax,QWORD PTR [rbx+0x8]
 117:	shl    rax,1
 11a:	or     rax,0x1
 11e:	sar    rax,1
 121:	mov    r12,rdx
 124:	cmp    r12,rax
 127:	je     1cf <botlish_fn_1+0x119>
 12d:	mov    r13,r12
 130:	shl    r13,1
 133:	or     r13,0x1
 137:	mov    QWORD PTR [rsp+0x10],r13
 13c:	add    r12,0x1
 143:	mov    r14,r12
 146:	shl    r14,1
 149:	or     r14,0x1
 14d:	mov    QWORD PTR [rsp+0x18],r14
 152:	mov    rcx,r14
 155:	mov    rdx,r13
 158:	mov    rsi,rbx
 15b:	mov    rdi,QWORD PTR [rsp+0x60]
 160:	call   165 <botlish_fn_1+0xaf>
			161: R_X86_64_PLT32	rt_str_region_check-0x4
 165:	test   rax,rax
 168:	je     205 <botlish_fn_1+0x14f>
 16e:	mov    QWORD PTR [rsp+0x30],0x1
 177:	mov    QWORD PTR [rsp+0x38],rbx
 17c:	mov    QWORD PTR [rsp+0x40],r13
 181:	mov    QWORD PTR [rsp+0x48],r14
 186:	mov    QWORD PTR [rsp+0x50],0x0
 18f:	mov    rcx,QWORD PTR [rsp+0x68]
 194:	mov    QWORD PTR [rsp+0x58],rcx
 199:	mov    esi,0x2
 19e:	mov    edx,0x6
 1a3:	mov    rcx,r15
 1a6:	mov    rdi,QWORD PTR [rsp+0x60]
 1ab:	call   1b0 <botlish_fn_1+0xfa>
			1ac: R_X86_64_PLT32	rt_construct-0x4
 1b0:	test   rax,rax
 1b3:	je     205 <botlish_fn_1+0x14f>
 1b9:	mov    QWORD PTR [rsp],rbx
 1bd:	mov    QWORD PTR [rsp+0x8],rax
 1c2:	mov    rdx,r12
 1c5:	mov    QWORD PTR [rsp+0x68],rax
 1ca:	jmp    113 <botlish_fn_1+0x5d>
 1cf:	mov    rcx,QWORD PTR [rsp+0x68]
 1d4:	xor    rsi,rsi
 1d7:	lea    rax,[rsp+0x20]
 1dc:	mov    QWORD PTR [rsp+0x20],0x0
 1e5:	mov    QWORD PTR [rsp+0x28],rcx
 1ea:	mov    edx,0x2
 1ef:	mov    rcx,rax
 1f2:	mov    rdi,QWORD PTR [rsp+0x60]
 1f7:	call   1fc <botlish_fn_1+0x146>
			1f8: R_X86_64_PLT32	rt_construct-0x4
 1fc:	test   rax,rax
 1ff:	jne    236 <botlish_fn_1+0x180>
 205:	xor    rax,rax
 208:	mov    rbx,QWORD PTR [rsp+0x70]
 20d:	mov    r12,QWORD PTR [rsp+0x78]
 212:	mov    r13,QWORD PTR [rsp+0x80]
 21a:	mov    r14,QWORD PTR [rsp+0x88]
 222:	mov    r15,QWORD PTR [rsp+0x90]
 22a:	add    rsp,0xa0
 231:	mov    rsp,rbp
 234:	pop    rbp
 235:	ret
 236:	mov    rbx,QWORD PTR [rsp+0x70]
 23b:	mov    r12,QWORD PTR [rsp+0x78]
 240:	mov    r13,QWORD PTR [rsp+0x80]
 248:	mov    r14,QWORD PTR [rsp+0x88]
 250:	mov    r15,QWORD PTR [rsp+0x90]
 258:	add    rsp,0xa0
 25f:	mov    rsp,rbp
 262:	pop    rbp
 263:	ret

0000000000000264 <botlish_entry_1: reverse_from<str, int, str>>:
 264:	push   rbp
 265:	mov    rbp,rsp
 268:	mov    rsi,QWORD PTR [rdx]
 26b:	mov    r8,QWORD PTR [rdx+0x8]
 26f:	mov    rcx,QWORD PTR [rdx+0x10]
 273:	mov    rdx,r8
 276:	call   27b <botlish_entry_1+0x17>
			277: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 27b:	mov    rsp,rbp
 27e:	pop    rbp
 27f:	ret

0000000000000280 <botlish_fn_2: reverse_chars<str>>:
 280:	push   rbp
 281:	mov    rbp,rsp
 284:	sub    rsp,0x20
 288:	mov    QWORD PTR [rsp],rsi
 28c:	mov    edx,0x1
 291:	mov    QWORD PTR [rsp+0x8],0x1
 29a:	mov    r11,QWORD PTR [rdi+0x10]
 29e:	mov    rcx,QWORD PTR [r11]
 2a1:	mov    QWORD PTR [rsp+0x10],rcx
 2a6:	call   2ab <botlish_fn_2+0x2b>
			2a7: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 2ab:	test   rax,rax
 2ae:	jne    2c0 <botlish_fn_2+0x40>
 2b4:	xor    rax,rax
 2b7:	add    rsp,0x20
 2bb:	mov    rsp,rbp
 2be:	pop    rbp
 2bf:	ret
 2c0:	add    rsp,0x20
 2c4:	mov    rsp,rbp
 2c7:	pop    rbp
 2c8:	ret

00000000000002c9 <botlish_entry_2: reverse_chars<str>>:
 2c9:	push   rbp
 2ca:	mov    rbp,rsp
 2cd:	mov    rsi,QWORD PTR [rdx]
 2d0:	call   2d5 <botlish_entry_2+0xc>
			2d1: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 2d5:	mov    rsp,rbp
 2d8:	pop    rbp
 2d9:	ret

00000000000002da <botlish_fn_3: sample<generic>>:
 2da:	push   rbp
 2db:	mov    rbp,rsp
 2de:	sub    rsp,0x80
 2e5:	mov    QWORD PTR [rsp+0x50],rbx
 2ea:	mov    QWORD PTR [rsp+0x58],r12
 2ef:	mov    QWORD PTR [rsp+0x60],r13
 2f4:	mov    QWORD PTR [rsp+0x68],r14
 2f9:	mov    QWORD PTR [rsp+0x70],r15
 2fe:	mov    QWORD PTR [rsp+0x8],0x0
 307:	mov    QWORD PTR [rsp+0x10],0x0
 310:	mov    QWORD PTR [rsp+0x18],0x0
 319:	mov    QWORD PTR [rsp+0x20],0x0
 322:	mov    rax,QWORD PTR [rdi+0x10]
 326:	mov    rbx,rdi
 329:	mov    rsi,QWORD PTR [rax]
 32c:	mov    QWORD PTR [rsp],rsi
 330:	call   335 <botlish_fn_3+0x5b>
			331: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 335:	test   rax,rax
 338:	je     41a <botlish_fn_3+0x140>
 33e:	mov    QWORD PTR [rsp],rax
 342:	mov    rdi,rbx
 345:	mov    r12,rax
 348:	mov    rax,QWORD PTR [rdi+0x10]
 34c:	mov    rsi,QWORD PTR [rax+0x8]
 350:	mov    QWORD PTR [rsp+0x8],rsi
 355:	call   35a <botlish_fn_3+0x80>
			356: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 35a:	test   rax,rax
 35d:	je     41a <botlish_fn_3+0x140>
 363:	mov    QWORD PTR [rsp+0x8],rax
 368:	mov    rdi,rbx
 36b:	mov    r13,rax
 36e:	mov    rax,QWORD PTR [rdi+0x10]
 372:	mov    rsi,QWORD PTR [rax+0x10]
 376:	mov    QWORD PTR [rsp+0x10],rsi
 37b:	call   380 <botlish_fn_3+0xa6>
			37c: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 380:	test   rax,rax
 383:	je     41a <botlish_fn_3+0x140>
 389:	mov    QWORD PTR [rsp+0x10],rax
 38e:	mov    rdi,rbx
 391:	mov    r14,rax
 394:	mov    rax,QWORD PTR [rdi+0x10]
 398:	mov    rsi,QWORD PTR [rax+0x18]
 39c:	mov    QWORD PTR [rsp+0x18],rsi
 3a1:	call   3a6 <botlish_fn_3+0xcc>
			3a2: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 3a6:	test   rax,rax
 3a9:	je     41a <botlish_fn_3+0x140>
 3af:	mov    QWORD PTR [rsp+0x18],rax
 3b4:	mov    rdi,rbx
 3b7:	mov    r15,rax
 3ba:	mov    rax,QWORD PTR [rdi+0x10]
 3be:	mov    rsi,QWORD PTR [rax+0x20]
 3c2:	mov    QWORD PTR [rsp+0x20],rsi
 3c7:	call   3cc <botlish_fn_3+0xf2>
			3c8: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 3cc:	test   rax,rax
 3cf:	je     41a <botlish_fn_3+0x140>
 3d5:	mov    QWORD PTR [rsp+0x20],rax
 3da:	lea    rdx,[rsp+0x28]
 3df:	mov    rcx,r12
 3e2:	mov    QWORD PTR [rsp+0x28],rcx
 3e7:	mov    rcx,r13
 3ea:	mov    QWORD PTR [rsp+0x30],rcx
 3ef:	mov    rcx,r14
 3f2:	mov    QWORD PTR [rsp+0x38],rcx
 3f7:	mov    rcx,r15
 3fa:	mov    QWORD PTR [rsp+0x40],rcx
 3ff:	mov    QWORD PTR [rsp+0x48],rax
 404:	mov    esi,0x5
 409:	mov    rdi,rbx
 40c:	call   411 <botlish_fn_3+0x137>
			40d: R_X86_64_PLT32	rt_list_new-0x4
 411:	test   rax,rax
 414:	jne    442 <botlish_fn_3+0x168>
 41a:	xor    rax,rax
 41d:	mov    rbx,QWORD PTR [rsp+0x50]
 422:	mov    r12,QWORD PTR [rsp+0x58]
 427:	mov    r13,QWORD PTR [rsp+0x60]
 42c:	mov    r14,QWORD PTR [rsp+0x68]
 431:	mov    r15,QWORD PTR [rsp+0x70]
 436:	add    rsp,0x80
 43d:	mov    rsp,rbp
 440:	pop    rbp
 441:	ret
 442:	mov    rbx,QWORD PTR [rsp+0x50]
 447:	mov    r12,QWORD PTR [rsp+0x58]
 44c:	mov    r13,QWORD PTR [rsp+0x60]
 451:	mov    r14,QWORD PTR [rsp+0x68]
 456:	mov    r15,QWORD PTR [rsp+0x70]
 45b:	add    rsp,0x80
 462:	mov    rsp,rbp
 465:	pop    rbp
 466:	ret

0000000000000467 <botlish_entry_3: sample<generic>>:
 467:	push   rbp
 468:	mov    rbp,rsp
 46b:	call   470 <botlish_entry_3+0x9>
			46c: R_X86_64_PLT32	botlish_fn_3-0x4 ; sample<generic>
 470:	mov    rsp,rbp
 473:	pop    rbp
 474:	ret

; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 1214  (per function: 224 482 90 418)
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
 10b:	mov    r12,rdx
 10e:	lea    r15,[rsp+0x30]
 113:	mov    rbx,rsi
 116:	mov    rsi,rbx
 119:	mov    rdi,QWORD PTR [rsp+0x60]
 11e:	call   123 <botlish_fn_1+0x6d>
			11f: R_X86_64_PLT32	rt_str_len-0x4
 123:	sar    rax,1
 126:	cmp    r12,rax
 129:	je     1ce <botlish_fn_1+0x118>
 12f:	mov    r13,r12
 132:	shl    r13,1
 135:	or     r13,0x1
 139:	mov    QWORD PTR [rsp+0x10],r13
 13e:	add    r12,0x1
 145:	mov    r14,r12
 148:	shl    r14,1
 14b:	or     r14,0x1
 14f:	mov    QWORD PTR [rsp+0x18],r14
 154:	mov    rcx,r14
 157:	mov    rdx,r13
 15a:	mov    rsi,rbx
 15d:	mov    rdi,QWORD PTR [rsp+0x60]
 162:	call   167 <botlish_fn_1+0xb1>
			163: R_X86_64_PLT32	rt_str_region_check-0x4
 167:	test   rax,rax
 16a:	je     204 <botlish_fn_1+0x14e>
 170:	mov    QWORD PTR [rsp+0x30],0x1
 179:	mov    QWORD PTR [rsp+0x38],rbx
 17e:	mov    QWORD PTR [rsp+0x40],r13
 183:	mov    QWORD PTR [rsp+0x48],r14
 188:	mov    QWORD PTR [rsp+0x50],0x0
 191:	mov    rcx,QWORD PTR [rsp+0x68]
 196:	mov    QWORD PTR [rsp+0x58],rcx
 19b:	mov    esi,0x2
 1a0:	mov    edx,0x6
 1a5:	mov    rcx,r15
 1a8:	mov    rdi,QWORD PTR [rsp+0x60]
 1ad:	call   1b2 <botlish_fn_1+0xfc>
			1ae: R_X86_64_PLT32	rt_construct-0x4
 1b2:	test   rax,rax
 1b5:	je     204 <botlish_fn_1+0x14e>
 1bb:	mov    QWORD PTR [rsp],rbx
 1bf:	mov    QWORD PTR [rsp+0x8],rax
 1c4:	mov    QWORD PTR [rsp+0x68],rax
 1c9:	jmp    116 <botlish_fn_1+0x60>
 1ce:	mov    rcx,QWORD PTR [rsp+0x68]
 1d3:	xor    rsi,rsi
 1d6:	lea    rax,[rsp+0x20]
 1db:	mov    QWORD PTR [rsp+0x20],0x0
 1e4:	mov    QWORD PTR [rsp+0x28],rcx
 1e9:	mov    edx,0x2
 1ee:	mov    rcx,rax
 1f1:	mov    rdi,QWORD PTR [rsp+0x60]
 1f6:	call   1fb <botlish_fn_1+0x145>
			1f7: R_X86_64_PLT32	rt_construct-0x4
 1fb:	test   rax,rax
 1fe:	jne    235 <botlish_fn_1+0x17f>
 204:	xor    rax,rax
 207:	mov    rbx,QWORD PTR [rsp+0x70]
 20c:	mov    r12,QWORD PTR [rsp+0x78]
 211:	mov    r13,QWORD PTR [rsp+0x80]
 219:	mov    r14,QWORD PTR [rsp+0x88]
 221:	mov    r15,QWORD PTR [rsp+0x90]
 229:	add    rsp,0xa0
 230:	mov    rsp,rbp
 233:	pop    rbp
 234:	ret
 235:	mov    rbx,QWORD PTR [rsp+0x70]
 23a:	mov    r12,QWORD PTR [rsp+0x78]
 23f:	mov    r13,QWORD PTR [rsp+0x80]
 247:	mov    r14,QWORD PTR [rsp+0x88]
 24f:	mov    r15,QWORD PTR [rsp+0x90]
 257:	add    rsp,0xa0
 25e:	mov    rsp,rbp
 261:	pop    rbp
 262:	ret

0000000000000263 <botlish_entry_1: reverse_from<str, int, str>>:
 263:	push   rbp
 264:	mov    rbp,rsp
 267:	mov    rsi,QWORD PTR [rdx]
 26a:	mov    r8,QWORD PTR [rdx+0x8]
 26e:	mov    rcx,QWORD PTR [rdx+0x10]
 272:	mov    rdx,r8
 275:	call   27a <botlish_entry_1+0x17>
			276: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 27a:	mov    rsp,rbp
 27d:	pop    rbp
 27e:	ret

000000000000027f <botlish_fn_2: reverse_chars<str>>:
 27f:	push   rbp
 280:	mov    rbp,rsp
 283:	sub    rsp,0x20
 287:	mov    QWORD PTR [rsp],rsi
 28b:	mov    edx,0x1
 290:	mov    QWORD PTR [rsp+0x8],0x1
 299:	mov    r11,QWORD PTR [rdi+0x10]
 29d:	mov    rcx,QWORD PTR [r11]
 2a0:	mov    QWORD PTR [rsp+0x10],rcx
 2a5:	call   2aa <botlish_fn_2+0x2b>
			2a6: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 2aa:	test   rax,rax
 2ad:	jne    2bf <botlish_fn_2+0x40>
 2b3:	xor    rax,rax
 2b6:	add    rsp,0x20
 2ba:	mov    rsp,rbp
 2bd:	pop    rbp
 2be:	ret
 2bf:	add    rsp,0x20
 2c3:	mov    rsp,rbp
 2c6:	pop    rbp
 2c7:	ret

00000000000002c8 <botlish_entry_2: reverse_chars<str>>:
 2c8:	push   rbp
 2c9:	mov    rbp,rsp
 2cc:	mov    rsi,QWORD PTR [rdx]
 2cf:	call   2d4 <botlish_entry_2+0xc>
			2d0: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 2d4:	mov    rsp,rbp
 2d7:	pop    rbp
 2d8:	ret

00000000000002d9 <botlish_fn_3: sample<generic>>:
 2d9:	push   rbp
 2da:	mov    rbp,rsp
 2dd:	sub    rsp,0x80
 2e4:	mov    QWORD PTR [rsp+0x50],rbx
 2e9:	mov    QWORD PTR [rsp+0x58],r12
 2ee:	mov    QWORD PTR [rsp+0x60],r13
 2f3:	mov    QWORD PTR [rsp+0x68],r14
 2f8:	mov    QWORD PTR [rsp+0x70],r15
 2fd:	mov    QWORD PTR [rsp+0x8],0x0
 306:	mov    QWORD PTR [rsp+0x10],0x0
 30f:	mov    QWORD PTR [rsp+0x18],0x0
 318:	mov    QWORD PTR [rsp+0x20],0x0
 321:	mov    rax,QWORD PTR [rdi+0x10]
 325:	mov    rbx,rdi
 328:	mov    rsi,QWORD PTR [rax]
 32b:	mov    QWORD PTR [rsp],rsi
 32f:	call   334 <botlish_fn_3+0x5b>
			330: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 334:	test   rax,rax
 337:	je     419 <botlish_fn_3+0x140>
 33d:	mov    QWORD PTR [rsp],rax
 341:	mov    rdi,rbx
 344:	mov    r12,rax
 347:	mov    rax,QWORD PTR [rdi+0x10]
 34b:	mov    rsi,QWORD PTR [rax+0x8]
 34f:	mov    QWORD PTR [rsp+0x8],rsi
 354:	call   359 <botlish_fn_3+0x80>
			355: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 359:	test   rax,rax
 35c:	je     419 <botlish_fn_3+0x140>
 362:	mov    QWORD PTR [rsp+0x8],rax
 367:	mov    rdi,rbx
 36a:	mov    r13,rax
 36d:	mov    rax,QWORD PTR [rdi+0x10]
 371:	mov    rsi,QWORD PTR [rax+0x10]
 375:	mov    QWORD PTR [rsp+0x10],rsi
 37a:	call   37f <botlish_fn_3+0xa6>
			37b: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 37f:	test   rax,rax
 382:	je     419 <botlish_fn_3+0x140>
 388:	mov    QWORD PTR [rsp+0x10],rax
 38d:	mov    rdi,rbx
 390:	mov    r14,rax
 393:	mov    rax,QWORD PTR [rdi+0x10]
 397:	mov    rsi,QWORD PTR [rax+0x18]
 39b:	mov    QWORD PTR [rsp+0x18],rsi
 3a0:	call   3a5 <botlish_fn_3+0xcc>
			3a1: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 3a5:	test   rax,rax
 3a8:	je     419 <botlish_fn_3+0x140>
 3ae:	mov    QWORD PTR [rsp+0x18],rax
 3b3:	mov    rdi,rbx
 3b6:	mov    r15,rax
 3b9:	mov    rax,QWORD PTR [rdi+0x10]
 3bd:	mov    rsi,QWORD PTR [rax+0x20]
 3c1:	mov    QWORD PTR [rsp+0x20],rsi
 3c6:	call   3cb <botlish_fn_3+0xf2>
			3c7: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 3cb:	test   rax,rax
 3ce:	je     419 <botlish_fn_3+0x140>
 3d4:	mov    QWORD PTR [rsp+0x20],rax
 3d9:	lea    rdx,[rsp+0x28]
 3de:	mov    rcx,r12
 3e1:	mov    QWORD PTR [rsp+0x28],rcx
 3e6:	mov    rcx,r13
 3e9:	mov    QWORD PTR [rsp+0x30],rcx
 3ee:	mov    rcx,r14
 3f1:	mov    QWORD PTR [rsp+0x38],rcx
 3f6:	mov    rcx,r15
 3f9:	mov    QWORD PTR [rsp+0x40],rcx
 3fe:	mov    QWORD PTR [rsp+0x48],rax
 403:	mov    esi,0x5
 408:	mov    rdi,rbx
 40b:	call   410 <botlish_fn_3+0x137>
			40c: R_X86_64_PLT32	rt_list_new-0x4
 410:	test   rax,rax
 413:	jne    441 <botlish_fn_3+0x168>
 419:	xor    rax,rax
 41c:	mov    rbx,QWORD PTR [rsp+0x50]
 421:	mov    r12,QWORD PTR [rsp+0x58]
 426:	mov    r13,QWORD PTR [rsp+0x60]
 42b:	mov    r14,QWORD PTR [rsp+0x68]
 430:	mov    r15,QWORD PTR [rsp+0x70]
 435:	add    rsp,0x80
 43c:	mov    rsp,rbp
 43f:	pop    rbp
 440:	ret
 441:	mov    rbx,QWORD PTR [rsp+0x50]
 446:	mov    r12,QWORD PTR [rsp+0x58]
 44b:	mov    r13,QWORD PTR [rsp+0x60]
 450:	mov    r14,QWORD PTR [rsp+0x68]
 455:	mov    r15,QWORD PTR [rsp+0x70]
 45a:	add    rsp,0x80
 461:	mov    rsp,rbp
 464:	pop    rbp
 465:	ret

0000000000000466 <botlish_entry_3: sample<generic>>:
 466:	push   rbp
 467:	mov    rbp,rsp
 46a:	call   46f <botlish_entry_3+0x9>
			46b: R_X86_64_PLT32	botlish_fn_3-0x4 ; sample<generic>
 46f:	mov    rsp,rbp
 472:	pop    rbp
 473:	ret

; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 990  (per function: 418 482 90)
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
  4f:	mov    rsi,QWORD PTR [rax]
  52:	mov    QWORD PTR [rsp],rsi
  56:	call   5b <botlish_fn_0+0x5b>
			57: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  5b:	test   rax,rax
  5e:	je     140 <botlish_fn_0+0x140>
  64:	mov    QWORD PTR [rsp],rax
  68:	mov    rdi,rbx
  6b:	mov    r12,rax
  6e:	mov    rax,QWORD PTR [rdi+0x10]
  72:	mov    rsi,QWORD PTR [rax+0x8]
  76:	mov    QWORD PTR [rsp+0x8],rsi
  7b:	call   80 <botlish_fn_0+0x80>
			7c: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  80:	test   rax,rax
  83:	je     140 <botlish_fn_0+0x140>
  89:	mov    QWORD PTR [rsp+0x8],rax
  8e:	mov    rdi,rbx
  91:	mov    r13,rax
  94:	mov    rax,QWORD PTR [rdi+0x10]
  98:	mov    rsi,QWORD PTR [rax+0x10]
  9c:	mov    QWORD PTR [rsp+0x10],rsi
  a1:	call   a6 <botlish_fn_0+0xa6>
			a2: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  a6:	test   rax,rax
  a9:	je     140 <botlish_fn_0+0x140>
  af:	mov    QWORD PTR [rsp+0x10],rax
  b4:	mov    rdi,rbx
  b7:	mov    r14,rax
  ba:	mov    rax,QWORD PTR [rdi+0x10]
  be:	mov    rsi,QWORD PTR [rax+0x18]
  c2:	mov    QWORD PTR [rsp+0x18],rsi
  c7:	call   cc <botlish_fn_0+0xcc>
			c8: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  cc:	test   rax,rax
  cf:	je     140 <botlish_fn_0+0x140>
  d5:	mov    QWORD PTR [rsp+0x18],rax
  da:	mov    rdi,rbx
  dd:	mov    r15,rax
  e0:	mov    rax,QWORD PTR [rdi+0x10]
  e4:	mov    rsi,QWORD PTR [rax+0x20]
  e8:	mov    QWORD PTR [rsp+0x20],rsi
  ed:	call   f2 <botlish_fn_0+0xf2>
			ee: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  f2:	test   rax,rax
  f5:	je     140 <botlish_fn_0+0x140>
  fb:	mov    QWORD PTR [rsp+0x20],rax
 100:	lea    rdx,[rsp+0x28]
 105:	mov    rcx,r12
 108:	mov    QWORD PTR [rsp+0x28],rcx
 10d:	mov    rcx,r13
 110:	mov    QWORD PTR [rsp+0x30],rcx
 115:	mov    rcx,r14
 118:	mov    QWORD PTR [rsp+0x38],rcx
 11d:	mov    rcx,r15
 120:	mov    QWORD PTR [rsp+0x40],rcx
 125:	mov    QWORD PTR [rsp+0x48],rax
 12a:	mov    esi,0x5
 12f:	mov    rdi,rbx
 132:	call   137 <botlish_fn_0+0x137>
			133: R_X86_64_PLT32	rt_list_new-0x4
 137:	test   rax,rax
 13a:	jne    168 <botlish_fn_0+0x168>
 140:	xor    rax,rax
 143:	mov    rbx,QWORD PTR [rsp+0x50]
 148:	mov    r12,QWORD PTR [rsp+0x58]
 14d:	mov    r13,QWORD PTR [rsp+0x60]
 152:	mov    r14,QWORD PTR [rsp+0x68]
 157:	mov    r15,QWORD PTR [rsp+0x70]
 15c:	add    rsp,0x80
 163:	mov    rsp,rbp
 166:	pop    rbp
 167:	ret
 168:	mov    rbx,QWORD PTR [rsp+0x50]
 16d:	mov    r12,QWORD PTR [rsp+0x58]
 172:	mov    r13,QWORD PTR [rsp+0x60]
 177:	mov    r14,QWORD PTR [rsp+0x68]
 17c:	mov    r15,QWORD PTR [rsp+0x70]
 181:	add    rsp,0x80
 188:	mov    rsp,rbp
 18b:	pop    rbp
 18c:	ret

000000000000018d <botlish_entry_0: <program entry>>:
 18d:	push   rbp
 18e:	mov    rbp,rsp
 191:	call   196 <botlish_entry_0+0x9>
			192: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 196:	mov    rsp,rbp
 199:	pop    rbp
 19a:	ret

000000000000019b <botlish_fn_1: reverse_from<str, int, str>>:
 19b:	push   rbp
 19c:	mov    rbp,rsp
 19f:	sub    rsp,0xa0
 1a6:	mov    QWORD PTR [rsp+0x70],rbx
 1ab:	mov    QWORD PTR [rsp+0x78],r12
 1b0:	mov    QWORD PTR [rsp+0x80],r13
 1b8:	mov    QWORD PTR [rsp+0x88],r14
 1c0:	mov    QWORD PTR [rsp+0x90],r15
 1c8:	mov    QWORD PTR [rsp+0x60],rdi
 1cd:	mov    QWORD PTR [rsp+0x10],0x0
 1d6:	mov    QWORD PTR [rsp+0x18],0x0
 1df:	mov    QWORD PTR [rsp],rsi
 1e3:	mov    QWORD PTR [rsp+0x8],rcx
 1e8:	mov    QWORD PTR [rsp+0x68],rcx
 1ed:	sar    rdx,1
 1f0:	mov    r12,rdx
 1f3:	lea    r15,[rsp+0x30]
 1f8:	mov    rbx,rsi
 1fb:	mov    rsi,rbx
 1fe:	mov    rdi,QWORD PTR [rsp+0x60]
 203:	call   208 <botlish_fn_1+0x6d>
			204: R_X86_64_PLT32	rt_str_len-0x4
 208:	sar    rax,1
 20b:	cmp    r12,rax
 20e:	je     2b3 <botlish_fn_1+0x118>
 214:	mov    r13,r12
 217:	shl    r13,1
 21a:	or     r13,0x1
 21e:	mov    QWORD PTR [rsp+0x10],r13
 223:	add    r12,0x1
 22a:	mov    r14,r12
 22d:	shl    r14,1
 230:	or     r14,0x1
 234:	mov    QWORD PTR [rsp+0x18],r14
 239:	mov    rcx,r14
 23c:	mov    rdx,r13
 23f:	mov    rsi,rbx
 242:	mov    rdi,QWORD PTR [rsp+0x60]
 247:	call   24c <botlish_fn_1+0xb1>
			248: R_X86_64_PLT32	rt_str_region_check-0x4
 24c:	test   rax,rax
 24f:	je     2e9 <botlish_fn_1+0x14e>
 255:	mov    QWORD PTR [rsp+0x30],0x1
 25e:	mov    QWORD PTR [rsp+0x38],rbx
 263:	mov    QWORD PTR [rsp+0x40],r13
 268:	mov    QWORD PTR [rsp+0x48],r14
 26d:	mov    QWORD PTR [rsp+0x50],0x0
 276:	mov    rcx,QWORD PTR [rsp+0x68]
 27b:	mov    QWORD PTR [rsp+0x58],rcx
 280:	mov    esi,0x2
 285:	mov    edx,0x6
 28a:	mov    rcx,r15
 28d:	mov    rdi,QWORD PTR [rsp+0x60]
 292:	call   297 <botlish_fn_1+0xfc>
			293: R_X86_64_PLT32	rt_construct-0x4
 297:	test   rax,rax
 29a:	je     2e9 <botlish_fn_1+0x14e>
 2a0:	mov    QWORD PTR [rsp],rbx
 2a4:	mov    QWORD PTR [rsp+0x8],rax
 2a9:	mov    QWORD PTR [rsp+0x68],rax
 2ae:	jmp    1fb <botlish_fn_1+0x60>
 2b3:	mov    rcx,QWORD PTR [rsp+0x68]
 2b8:	xor    rsi,rsi
 2bb:	lea    rax,[rsp+0x20]
 2c0:	mov    QWORD PTR [rsp+0x20],0x0
 2c9:	mov    QWORD PTR [rsp+0x28],rcx
 2ce:	mov    edx,0x2
 2d3:	mov    rcx,rax
 2d6:	mov    rdi,QWORD PTR [rsp+0x60]
 2db:	call   2e0 <botlish_fn_1+0x145>
			2dc: R_X86_64_PLT32	rt_construct-0x4
 2e0:	test   rax,rax
 2e3:	jne    31a <botlish_fn_1+0x17f>
 2e9:	xor    rax,rax
 2ec:	mov    rbx,QWORD PTR [rsp+0x70]
 2f1:	mov    r12,QWORD PTR [rsp+0x78]
 2f6:	mov    r13,QWORD PTR [rsp+0x80]
 2fe:	mov    r14,QWORD PTR [rsp+0x88]
 306:	mov    r15,QWORD PTR [rsp+0x90]
 30e:	add    rsp,0xa0
 315:	mov    rsp,rbp
 318:	pop    rbp
 319:	ret
 31a:	mov    rbx,QWORD PTR [rsp+0x70]
 31f:	mov    r12,QWORD PTR [rsp+0x78]
 324:	mov    r13,QWORD PTR [rsp+0x80]
 32c:	mov    r14,QWORD PTR [rsp+0x88]
 334:	mov    r15,QWORD PTR [rsp+0x90]
 33c:	add    rsp,0xa0
 343:	mov    rsp,rbp
 346:	pop    rbp
 347:	ret

0000000000000348 <botlish_entry_1: reverse_from<str, int, str>>:
 348:	push   rbp
 349:	mov    rbp,rsp
 34c:	mov    rsi,QWORD PTR [rdx]
 34f:	mov    r8,QWORD PTR [rdx+0x8]
 353:	mov    rcx,QWORD PTR [rdx+0x10]
 357:	mov    rdx,r8
 35a:	call   35f <botlish_entry_1+0x17>
			35b: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 35f:	mov    rsp,rbp
 362:	pop    rbp
 363:	ret

0000000000000364 <botlish_fn_2: reverse_chars<str>>:
 364:	push   rbp
 365:	mov    rbp,rsp
 368:	sub    rsp,0x20
 36c:	mov    QWORD PTR [rsp],rsi
 370:	mov    edx,0x1
 375:	mov    QWORD PTR [rsp+0x8],0x1
 37e:	mov    r11,QWORD PTR [rdi+0x10]
 382:	mov    rcx,QWORD PTR [r11]
 385:	mov    QWORD PTR [rsp+0x10],rcx
 38a:	call   38f <botlish_fn_2+0x2b>
			38b: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 38f:	test   rax,rax
 392:	jne    3a4 <botlish_fn_2+0x40>
 398:	xor    rax,rax
 39b:	add    rsp,0x20
 39f:	mov    rsp,rbp
 3a2:	pop    rbp
 3a3:	ret
 3a4:	add    rsp,0x20
 3a8:	mov    rsp,rbp
 3ab:	pop    rbp
 3ac:	ret

00000000000003ad <botlish_entry_2: reverse_chars<str>>:
 3ad:	push   rbp
 3ae:	mov    rbp,rsp
 3b1:	mov    rsi,QWORD PTR [rdx]
 3b4:	call   3b9 <botlish_entry_2+0xc>
			3b5: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 3b9:	mov    rsp,rbp
 3bc:	pop    rbp
 3bd:	ret

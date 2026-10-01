; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 979  (per function: 418 482 79)
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
 1c8:	mov    r12,rdx
 1cb:	mov    QWORD PTR [rsp+0x60],rdi
 1d0:	mov    QWORD PTR [rsp+0x10],0x0
 1d9:	mov    QWORD PTR [rsp+0x18],0x0
 1e2:	mov    QWORD PTR [rsp],rsi
 1e6:	mov    QWORD PTR [rsp+0x8],rcx
 1eb:	mov    QWORD PTR [rsp+0x68],rcx
 1f0:	lea    r15,[rsp+0x30]
 1f5:	mov    rbx,rsi
 1f8:	mov    rsi,rbx
 1fb:	mov    rdi,QWORD PTR [rsp+0x60]
 200:	call   205 <botlish_fn_1+0x6a>
			201: R_X86_64_PLT32	rt_str_len-0x4
 205:	sar    rax,1
 208:	cmp    r12,rax
 20b:	je     2b0 <botlish_fn_1+0x115>
 211:	mov    r13,r12
 214:	shl    r13,1
 217:	or     r13,0x1
 21b:	mov    QWORD PTR [rsp+0x10],r13
 220:	add    r12,0x1
 227:	mov    r14,r12
 22a:	shl    r14,1
 22d:	or     r14,0x1
 231:	mov    QWORD PTR [rsp+0x18],r14
 236:	mov    rcx,r14
 239:	mov    rdx,r13
 23c:	mov    rsi,rbx
 23f:	mov    rdi,QWORD PTR [rsp+0x60]
 244:	call   249 <botlish_fn_1+0xae>
			245: R_X86_64_PLT32	rt_str_region_check-0x4
 249:	test   rax,rax
 24c:	je     2e6 <botlish_fn_1+0x14b>
 252:	mov    QWORD PTR [rsp+0x30],0x1
 25b:	mov    QWORD PTR [rsp+0x38],rbx
 260:	mov    QWORD PTR [rsp+0x40],r13
 265:	mov    QWORD PTR [rsp+0x48],r14
 26a:	mov    QWORD PTR [rsp+0x50],0x0
 273:	mov    rcx,QWORD PTR [rsp+0x68]
 278:	mov    QWORD PTR [rsp+0x58],rcx
 27d:	mov    esi,0x2
 282:	mov    edx,0x6
 287:	mov    rcx,r15
 28a:	mov    rdi,QWORD PTR [rsp+0x60]
 28f:	call   294 <botlish_fn_1+0xf9>
			290: R_X86_64_PLT32	rt_construct-0x4
 294:	test   rax,rax
 297:	je     2e6 <botlish_fn_1+0x14b>
 29d:	mov    QWORD PTR [rsp],rbx
 2a1:	mov    QWORD PTR [rsp+0x8],rax
 2a6:	mov    QWORD PTR [rsp+0x68],rax
 2ab:	jmp    1f8 <botlish_fn_1+0x5d>
 2b0:	mov    rcx,QWORD PTR [rsp+0x68]
 2b5:	xor    rsi,rsi
 2b8:	lea    rax,[rsp+0x20]
 2bd:	mov    QWORD PTR [rsp+0x20],0x0
 2c6:	mov    QWORD PTR [rsp+0x28],rcx
 2cb:	mov    edx,0x2
 2d0:	mov    rcx,rax
 2d3:	mov    rdi,QWORD PTR [rsp+0x60]
 2d8:	call   2dd <botlish_fn_1+0x142>
			2d9: R_X86_64_PLT32	rt_construct-0x4
 2dd:	test   rax,rax
 2e0:	jne    317 <botlish_fn_1+0x17c>
 2e6:	xor    rax,rax
 2e9:	mov    rbx,QWORD PTR [rsp+0x70]
 2ee:	mov    r12,QWORD PTR [rsp+0x78]
 2f3:	mov    r13,QWORD PTR [rsp+0x80]
 2fb:	mov    r14,QWORD PTR [rsp+0x88]
 303:	mov    r15,QWORD PTR [rsp+0x90]
 30b:	add    rsp,0xa0
 312:	mov    rsp,rbp
 315:	pop    rbp
 316:	ret
 317:	mov    rbx,QWORD PTR [rsp+0x70]
 31c:	mov    r12,QWORD PTR [rsp+0x78]
 321:	mov    r13,QWORD PTR [rsp+0x80]
 329:	mov    r14,QWORD PTR [rsp+0x88]
 331:	mov    r15,QWORD PTR [rsp+0x90]
 339:	add    rsp,0xa0
 340:	mov    rsp,rbp
 343:	pop    rbp
 344:	ret

0000000000000345 <botlish_entry_1: reverse_from<str, int, str>>:
 345:	push   rbp
 346:	mov    rbp,rsp
 349:	mov    rsi,QWORD PTR [rdx]
 34c:	mov    r10,rdx
 34f:	mov    rdx,QWORD PTR [r10+0x8]
 353:	mov    rcx,QWORD PTR [r10+0x10]
 357:	sar    rdx,1
 35a:	call   35f <botlish_entry_1+0x1a>
			35b: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 35f:	mov    rsp,rbp
 362:	pop    rbp
 363:	ret

0000000000000364 <botlish_fn_2: reverse_chars<str>>:
 364:	push   rbp
 365:	mov    rbp,rsp
 368:	sub    rsp,0x10
 36c:	mov    QWORD PTR [rsp],rsi
 370:	mov    r11,QWORD PTR [rdi+0x10]
 374:	mov    rcx,QWORD PTR [r11]
 377:	mov    QWORD PTR [rsp+0x8],rcx
 37c:	xor    rdx,rdx
 37f:	call   384 <botlish_fn_2+0x20>
			380: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 384:	test   rax,rax
 387:	jne    399 <botlish_fn_2+0x35>
 38d:	xor    rax,rax
 390:	add    rsp,0x10
 394:	mov    rsp,rbp
 397:	pop    rbp
 398:	ret
 399:	add    rsp,0x10
 39d:	mov    rsp,rbp
 3a0:	pop    rbp
 3a1:	ret

00000000000003a2 <botlish_entry_2: reverse_chars<str>>:
 3a2:	push   rbp
 3a3:	mov    rbp,rsp
 3a6:	mov    rsi,QWORD PTR [rdx]
 3a9:	call   3ae <botlish_entry_2+0xc>
			3aa: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 3ae:	mov    rsp,rbp
 3b1:	pop    rbp
 3b2:	ret

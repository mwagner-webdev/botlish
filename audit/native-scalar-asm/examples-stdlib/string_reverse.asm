; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 1072  (per function: 579 290 203)
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
   4:	sub    rsp,0x90
   b:	mov    QWORD PTR [rsp+0x60],rbx
  10:	mov    QWORD PTR [rsp+0x68],r12
  15:	mov    QWORD PTR [rsp+0x70],r13
  1a:	mov    QWORD PTR [rsp+0x78],r14
  1f:	mov    QWORD PTR [rsp+0x80],r15
  27:	mov    rbx,QWORD PTR [rdi]
  2a:	mov    rax,QWORD PTR [rdi+0x8]
  2e:	lea    rcx,[rbx+0x8]
  32:	cmp    rcx,rax
  35:	ja     1f3 <botlish_fn_0+0x1f3>
  3b:	lea    rax,[rbx+0x8]
  3f:	mov    QWORD PTR [rdi],rax
  42:	mov    QWORD PTR [rbx],0x0
  49:	mov    QWORD PTR [rsp+0x8],0x0
  52:	mov    QWORD PTR [rsp+0x10],0x0
  5b:	mov    QWORD PTR [rsp+0x18],0x0
  64:	mov    QWORD PTR [rsp+0x20],0x0
  6d:	mov    rax,QWORD PTR [rdi+0x10]
  71:	mov    r12,rdi
  74:	mov    rsi,QWORD PTR [rax]
  77:	mov    QWORD PTR [rsp],rsi
  7b:	call   80 <botlish_fn_0+0x80>
			7c: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  80:	test   rax,rax
  83:	jne    91 <botlish_fn_0+0x91>
  89:	mov    rdi,r12
  8c:	jmp    194 <botlish_fn_0+0x194>
  91:	mov    QWORD PTR [rsp],rax
  95:	mov    rdi,r12
  98:	mov    r13,rax
  9b:	mov    rax,QWORD PTR [rdi+0x10]
  9f:	mov    rsi,QWORD PTR [rax+0x8]
  a3:	mov    QWORD PTR [rsp+0x8],rsi
  a8:	call   ad <botlish_fn_0+0xad>
			a9: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  ad:	test   rax,rax
  b0:	jne    be <botlish_fn_0+0xbe>
  b6:	mov    rdi,r12
  b9:	jmp    194 <botlish_fn_0+0x194>
  be:	mov    QWORD PTR [rsp+0x8],rax
  c3:	mov    rdi,r12
  c6:	mov    r14,rax
  c9:	mov    rax,QWORD PTR [rdi+0x10]
  cd:	mov    rsi,QWORD PTR [rax+0x10]
  d1:	mov    QWORD PTR [rsp+0x10],rsi
  d6:	call   db <botlish_fn_0+0xdb>
			d7: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  db:	test   rax,rax
  de:	jne    ec <botlish_fn_0+0xec>
  e4:	mov    rdi,r12
  e7:	jmp    194 <botlish_fn_0+0x194>
  ec:	mov    QWORD PTR [rsp+0x10],rax
  f1:	mov    rdi,r12
  f4:	mov    r15,rax
  f7:	mov    rax,QWORD PTR [rdi+0x10]
  fb:	mov    rsi,QWORD PTR [rax+0x18]
  ff:	mov    QWORD PTR [rsp+0x18],rsi
 104:	call   109 <botlish_fn_0+0x109>
			105: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 109:	test   rax,rax
 10c:	jne    11a <botlish_fn_0+0x11a>
 112:	mov    rdi,r12
 115:	jmp    194 <botlish_fn_0+0x194>
 11a:	mov    QWORD PTR [rsp+0x18],rax
 11f:	mov    rdi,r12
 122:	mov    QWORD PTR [rsp+0x50],rax
 127:	mov    rax,QWORD PTR [rdi+0x10]
 12b:	mov    rsi,QWORD PTR [rax+0x20]
 12f:	mov    QWORD PTR [rsp+0x20],rsi
 134:	call   139 <botlish_fn_0+0x139>
			135: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 139:	test   rax,rax
 13c:	jne    14a <botlish_fn_0+0x14a>
 142:	mov    rdi,r12
 145:	jmp    194 <botlish_fn_0+0x194>
 14a:	mov    QWORD PTR [rsp+0x20],rax
 14f:	lea    rdx,[rsp+0x28]
 154:	mov    rcx,r13
 157:	mov    QWORD PTR [rsp+0x28],rcx
 15c:	mov    rcx,r14
 15f:	mov    QWORD PTR [rsp+0x30],rcx
 164:	mov    rcx,r15
 167:	mov    QWORD PTR [rsp+0x38],rcx
 16c:	mov    rcx,QWORD PTR [rsp+0x50]
 171:	mov    QWORD PTR [rsp+0x40],rcx
 176:	mov    QWORD PTR [rsp+0x48],rax
 17b:	mov    esi,0x5
 180:	mov    rdi,r12
 183:	call   188 <botlish_fn_0+0x188>
			184: R_X86_64_PLT32	rt_list_new-0x4
 188:	test   rax,rax
 18b:	jne    1c5 <botlish_fn_0+0x1c5>
 191:	mov    rdi,r12
 194:	mov    rdi,r12
 197:	mov    QWORD PTR [rdi],rbx
 19a:	xor    rax,rax
 19d:	mov    rbx,QWORD PTR [rsp+0x60]
 1a2:	mov    r12,QWORD PTR [rsp+0x68]
 1a7:	mov    r13,QWORD PTR [rsp+0x70]
 1ac:	mov    r14,QWORD PTR [rsp+0x78]
 1b1:	mov    r15,QWORD PTR [rsp+0x80]
 1b9:	add    rsp,0x90
 1c0:	mov    rsp,rbp
 1c3:	pop    rbp
 1c4:	ret
 1c5:	mov    rdi,r12
 1c8:	mov    QWORD PTR [rdi],rbx
 1cb:	mov    rbx,QWORD PTR [rsp+0x60]
 1d0:	mov    r12,QWORD PTR [rsp+0x68]
 1d5:	mov    r13,QWORD PTR [rsp+0x70]
 1da:	mov    r14,QWORD PTR [rsp+0x78]
 1df:	mov    r15,QWORD PTR [rsp+0x80]
 1e7:	add    rsp,0x90
 1ee:	mov    rsp,rbp
 1f1:	pop    rbp
 1f2:	ret
 1f3:	mov    r12,rdi
 1f6:	call   1fb <botlish_fn_0+0x1fb>
			1f7: R_X86_64_PLT32	rt_stack_overflow-0x4
 1fb:	xor    rax,rax
 1fe:	mov    rbx,QWORD PTR [rsp+0x60]
 203:	mov    r12,QWORD PTR [rsp+0x68]
 208:	mov    r13,QWORD PTR [rsp+0x70]
 20d:	mov    r14,QWORD PTR [rsp+0x78]
 212:	mov    r15,QWORD PTR [rsp+0x80]
 21a:	add    rsp,0x90
 221:	mov    rsp,rbp
 224:	pop    rbp
 225:	ret

0000000000000226 <botlish_entry_0: <program entry>>:
 226:	push   rbp
 227:	mov    rbp,rsp
 22a:	call   22f <botlish_entry_0+0x9>
			22b: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 22f:	mov    rsp,rbp
 232:	pop    rbp
 233:	ret

0000000000000234 <botlish_fn_1: reverse_from<str, int, str>>:
 234:	push   rbp
 235:	mov    rbp,rsp
 238:	sub    rsp,0x40
 23c:	mov    QWORD PTR [rsp+0x20],rbx
 241:	mov    QWORD PTR [rsp+0x28],r12
 246:	mov    QWORD PTR [rsp+0x30],r13
 24b:	mov    QWORD PTR [rsp+0x38],r14
 250:	mov    r13,rdi
 253:	mov    QWORD PTR [rsp],rsi
 257:	mov    QWORD PTR [rsp+0x8],rcx
 25c:	sar    rdx,1
 25f:	mov    rbx,rdx
 262:	mov    r12,rsi
 265:	mov    r14,rcx
 268:	mov    rsi,r12
 26b:	mov    rdi,r13
 26e:	call   273 <botlish_fn_1+0x3f>
			26f: R_X86_64_PLT32	rt_str_len-0x4
 273:	sar    rax,1
 276:	cmp    rbx,rax
 279:	je     305 <botlish_fn_1+0xd1>
 27f:	mov    rdx,rbx
 282:	shl    rdx,1
 285:	or     rdx,0x1
 289:	mov    QWORD PTR [rsp+0x10],rdx
 28e:	add    rbx,0x1
 295:	mov    rcx,rbx
 298:	shl    rcx,1
 29b:	or     rcx,0x1
 29f:	mov    QWORD PTR [rsp+0x18],rcx
 2a4:	mov    rsi,r12
 2a7:	mov    rdi,r13
 2aa:	call   2af <botlish_fn_1+0x7b>
			2ab: R_X86_64_PLT32	rt_substr-0x4
 2af:	test   rax,rax
 2b2:	je     2d4 <botlish_fn_1+0xa0>
 2b8:	mov    QWORD PTR [rsp+0x10],rax
 2bd:	mov    rdx,r14
 2c0:	mov    rsi,rax
 2c3:	mov    rdi,r13
 2c6:	call   2cb <botlish_fn_1+0x97>
			2c7: R_X86_64_PLT32	rt_str_cat-0x4
 2cb:	test   rax,rax
 2ce:	jne    2f4 <botlish_fn_1+0xc0>
 2d4:	xor    rax,rax
 2d7:	mov    rbx,QWORD PTR [rsp+0x20]
 2dc:	mov    r12,QWORD PTR [rsp+0x28]
 2e1:	mov    r13,QWORD PTR [rsp+0x30]
 2e6:	mov    r14,QWORD PTR [rsp+0x38]
 2eb:	add    rsp,0x40
 2ef:	mov    rsp,rbp
 2f2:	pop    rbp
 2f3:	ret
 2f4:	mov    QWORD PTR [rsp],r12
 2f8:	mov    QWORD PTR [rsp+0x8],rax
 2fd:	mov    r14,rax
 300:	jmp    268 <botlish_fn_1+0x34>
 305:	mov    rax,r14
 308:	mov    rbx,QWORD PTR [rsp+0x20]
 30d:	mov    r12,QWORD PTR [rsp+0x28]
 312:	mov    r13,QWORD PTR [rsp+0x30]
 317:	mov    r14,QWORD PTR [rsp+0x38]
 31c:	add    rsp,0x40
 320:	mov    rsp,rbp
 323:	pop    rbp
 324:	ret

0000000000000325 <botlish_entry_1: reverse_from<str, int, str>>:
 325:	push   rbp
 326:	mov    rbp,rsp
 329:	mov    rsi,QWORD PTR [rdx]
 32c:	mov    r8,QWORD PTR [rdx+0x8]
 330:	mov    rcx,QWORD PTR [rdx+0x10]
 334:	mov    rdx,r8
 337:	call   33c <botlish_entry_1+0x17>
			338: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 33c:	mov    rsp,rbp
 33f:	pop    rbp
 340:	ret

0000000000000341 <botlish_fn_2: reverse_chars<str>>:
 341:	push   rbp
 342:	mov    rbp,rsp
 345:	sub    rsp,0x30
 349:	mov    QWORD PTR [rsp+0x20],rbx
 34e:	mov    QWORD PTR [rsp+0x28],r15
 353:	mov    r15,QWORD PTR [rdi]
 356:	mov    rax,QWORD PTR [rdi+0x8]
 35a:	lea    rcx,[r15+0x8]
 35e:	cmp    rcx,rax
 361:	ja     3d9 <botlish_fn_2+0x98>
 367:	lea    rax,[r15+0x8]
 36b:	mov    QWORD PTR [rdi],rax
 36e:	mov    QWORD PTR [r15],0x0
 375:	mov    QWORD PTR [rsp],rsi
 379:	mov    edx,0x1
 37e:	mov    QWORD PTR [rsp+0x8],0x1
 387:	mov    rax,QWORD PTR [rdi+0x10]
 38b:	mov    rbx,rdi
 38e:	mov    rcx,QWORD PTR [rax]
 391:	mov    QWORD PTR [rsp+0x10],rcx
 396:	call   39b <botlish_fn_2+0x5a>
			397: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 39b:	test   rax,rax
 39e:	jne    3c0 <botlish_fn_2+0x7f>
 3a4:	mov    rdi,rbx
 3a7:	mov    QWORD PTR [rdi],r15
 3aa:	xor    rax,rax
 3ad:	mov    rbx,QWORD PTR [rsp+0x20]
 3b2:	mov    r15,QWORD PTR [rsp+0x28]
 3b7:	add    rsp,0x30
 3bb:	mov    rsp,rbp
 3be:	pop    rbp
 3bf:	ret
 3c0:	mov    rdi,rbx
 3c3:	mov    QWORD PTR [rdi],r15
 3c6:	mov    rbx,QWORD PTR [rsp+0x20]
 3cb:	mov    r15,QWORD PTR [rsp+0x28]
 3d0:	add    rsp,0x30
 3d4:	mov    rsp,rbp
 3d7:	pop    rbp
 3d8:	ret
 3d9:	call   3de <botlish_fn_2+0x9d>
			3da: R_X86_64_PLT32	rt_stack_overflow-0x4
 3de:	xor    rax,rax
 3e1:	mov    rbx,QWORD PTR [rsp+0x20]
 3e6:	mov    r15,QWORD PTR [rsp+0x28]
 3eb:	add    rsp,0x30
 3ef:	mov    rsp,rbp
 3f2:	pop    rbp
 3f3:	ret

00000000000003f4 <botlish_entry_2: reverse_chars<str>>:
 3f4:	push   rbp
 3f5:	mov    rbp,rsp
 3f8:	mov    rsi,QWORD PTR [rdx]
 3fb:	call   400 <botlish_entry_2+0xc>
			3fc: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 400:	mov    rsp,rbp
 403:	pop    rbp
 404:	ret

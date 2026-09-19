; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 1110  (per function: 523 398 189)
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
  2f:	ja     1c1 <botlish_fn_0+0x1c1>
  35:	lea    rax,[r14+0x28]
  39:	mov    QWORD PTR [rdi],rax
  3c:	mov    QWORD PTR [r14+0x8],0x0
  44:	mov    QWORD PTR [r14+0x10],0x0
  4c:	mov    QWORD PTR [r14+0x18],0x0
  54:	mov    QWORD PTR [r14+0x20],0x0
  5c:	mov    rax,QWORD PTR [rdi+0x10]
  60:	mov    r15,rdi
  63:	mov    rsi,QWORD PTR [rax]
  66:	mov    QWORD PTR [r14],rsi
  69:	call   6e <botlish_fn_0+0x6e>
			6a: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  6e:	mov    rbx,rax
  71:	test   rbx,rbx
  74:	jne    82 <botlish_fn_0+0x82>
  7a:	mov    rdi,r15
  7d:	jmp    16e <botlish_fn_0+0x16e>
  82:	mov    QWORD PTR [r14],rbx
  85:	mov    rdi,r15
  88:	mov    rax,QWORD PTR [rdi+0x10]
  8c:	mov    rsi,QWORD PTR [rax+0x8]
  90:	mov    QWORD PTR [r14+0x8],rsi
  94:	call   99 <botlish_fn_0+0x99>
			95: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  99:	mov    r12,rax
  9c:	test   r12,r12
  9f:	jne    ad <botlish_fn_0+0xad>
  a5:	mov    rdi,r15
  a8:	jmp    16e <botlish_fn_0+0x16e>
  ad:	mov    QWORD PTR [r14+0x8],r12
  b1:	mov    rdi,r15
  b4:	mov    rax,QWORD PTR [rdi+0x10]
  b8:	mov    rsi,QWORD PTR [rax+0x10]
  bc:	mov    QWORD PTR [r14+0x10],rsi
  c0:	call   c5 <botlish_fn_0+0xc5>
			c1: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  c5:	mov    r13,rax
  c8:	test   r13,r13
  cb:	jne    d9 <botlish_fn_0+0xd9>
  d1:	mov    rdi,r15
  d4:	jmp    16e <botlish_fn_0+0x16e>
  d9:	mov    QWORD PTR [r14+0x10],r13
  dd:	mov    rdi,r15
  e0:	mov    rax,QWORD PTR [rdi+0x10]
  e4:	mov    rsi,QWORD PTR [rax+0x18]
  e8:	mov    QWORD PTR [r14+0x18],rsi
  ec:	call   f1 <botlish_fn_0+0xf1>
			ed: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
  f1:	test   rax,rax
  f4:	jne    102 <botlish_fn_0+0x102>
  fa:	mov    rdi,r15
  fd:	jmp    16e <botlish_fn_0+0x16e>
 102:	mov    QWORD PTR [r14+0x18],rax
 106:	mov    rdi,r15
 109:	mov    QWORD PTR [rsp+0x28],rax
 10e:	mov    rax,QWORD PTR [rdi+0x10]
 112:	mov    rsi,QWORD PTR [rax+0x20]
 116:	mov    QWORD PTR [r14+0x20],rsi
 11a:	call   11f <botlish_fn_0+0x11f>
			11b: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 11f:	test   rax,rax
 122:	jne    130 <botlish_fn_0+0x130>
 128:	mov    rdi,r15
 12b:	jmp    16e <botlish_fn_0+0x16e>
 130:	mov    QWORD PTR [r14+0x20],rax
 134:	lea    rdx,[rsp]
 138:	mov    QWORD PTR [rsp],rbx
 13c:	mov    QWORD PTR [rsp+0x8],r12
 141:	mov    QWORD PTR [rsp+0x10],r13
 146:	mov    rcx,QWORD PTR [rsp+0x28]
 14b:	mov    QWORD PTR [rsp+0x18],rcx
 150:	mov    QWORD PTR [rsp+0x20],rax
 155:	mov    esi,0x5
 15a:	mov    rdi,r15
 15d:	call   162 <botlish_fn_0+0x162>
			15e: R_X86_64_PLT32	rt_list_new-0x4
 162:	test   rax,rax
 165:	jne    199 <botlish_fn_0+0x199>
 16b:	mov    rdi,r15
 16e:	mov    rdi,r15
 171:	mov    QWORD PTR [rdi],r14
 174:	xor    rax,rax
 177:	mov    rbx,QWORD PTR [rsp+0x30]
 17c:	mov    r12,QWORD PTR [rsp+0x38]
 181:	mov    r13,QWORD PTR [rsp+0x40]
 186:	mov    r14,QWORD PTR [rsp+0x48]
 18b:	mov    r15,QWORD PTR [rsp+0x50]
 190:	add    rsp,0x60
 194:	mov    rsp,rbp
 197:	pop    rbp
 198:	ret
 199:	mov    rdi,r15
 19c:	mov    QWORD PTR [rdi],r14
 19f:	mov    rbx,QWORD PTR [rsp+0x30]
 1a4:	mov    r12,QWORD PTR [rsp+0x38]
 1a9:	mov    r13,QWORD PTR [rsp+0x40]
 1ae:	mov    r14,QWORD PTR [rsp+0x48]
 1b3:	mov    r15,QWORD PTR [rsp+0x50]
 1b8:	add    rsp,0x60
 1bc:	mov    rsp,rbp
 1bf:	pop    rbp
 1c0:	ret
 1c1:	mov    r15,rdi
 1c4:	call   1c9 <botlish_fn_0+0x1c9>
			1c5: R_X86_64_PLT32	rt_stack_overflow-0x4
 1c9:	xor    rax,rax
 1cc:	mov    rbx,QWORD PTR [rsp+0x30]
 1d1:	mov    r12,QWORD PTR [rsp+0x38]
 1d6:	mov    r13,QWORD PTR [rsp+0x40]
 1db:	mov    r14,QWORD PTR [rsp+0x48]
 1e0:	mov    r15,QWORD PTR [rsp+0x50]
 1e5:	add    rsp,0x60
 1e9:	mov    rsp,rbp
 1ec:	pop    rbp
 1ed:	ret

00000000000001ee <botlish_entry_0: <program entry>>:
 1ee:	push   rbp
 1ef:	mov    rbp,rsp
 1f2:	call   1f7 <botlish_entry_0+0x9>
			1f3: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 1f7:	mov    rsp,rbp
 1fa:	pop    rbp
 1fb:	ret

00000000000001fc <botlish_fn_1: reverse_from<str, int, str>>:
 1fc:	push   rbp
 1fd:	mov    rbp,rsp
 200:	sub    rsp,0x30
 204:	mov    QWORD PTR [rsp],rbx
 208:	mov    QWORD PTR [rsp+0x8],r12
 20d:	mov    QWORD PTR [rsp+0x10],r13
 212:	mov    QWORD PTR [rsp+0x18],r14
 217:	mov    QWORD PTR [rsp+0x20],r15
 21c:	mov    r13,QWORD PTR [rdi]
 21f:	mov    rax,QWORD PTR [rdi+0x8]
 223:	lea    r8,[r13+0x20]
 227:	cmp    r8,rax
 22a:	ja     326 <botlish_fn_1+0x12a>
 230:	lea    rax,[r13+0x20]
 234:	mov    QWORD PTR [rdi],rax
 237:	mov    r14,rdi
 23a:	mov    QWORD PTR [r13+0x0],rsi
 23e:	mov    QWORD PTR [r13+0x8],rcx
 242:	sar    rdx,1
 245:	mov    r12,rdx
 248:	mov    rbx,rsi
 24b:	mov    r15,rcx
 24e:	mov    rsi,rbx
 251:	mov    rdi,r14
 254:	call   259 <botlish_fn_1+0x5d>
			255: R_X86_64_PLT32	rt_str_len-0x4
 259:	sar    rax,1
 25c:	cmp    r12,rax
 25f:	je     2fc <botlish_fn_1+0x100>
 265:	mov    rdx,r12
 268:	shl    rdx,1
 26b:	or     rdx,0x1
 26f:	mov    QWORD PTR [r13+0x10],rdx
 273:	add    r12,0x1
 27a:	mov    rcx,r12
 27d:	shl    rcx,1
 280:	or     rcx,0x1
 284:	mov    QWORD PTR [r13+0x18],rcx
 288:	mov    rsi,rbx
 28b:	mov    rdi,r14
 28e:	call   293 <botlish_fn_1+0x97>
			28f: R_X86_64_PLT32	rt_substr-0x4
 293:	test   rax,rax
 296:	jne    2a4 <botlish_fn_1+0xa8>
 29c:	mov    rdi,r14
 29f:	jmp    2c2 <botlish_fn_1+0xc6>
 2a4:	mov    QWORD PTR [r13+0x10],rax
 2a8:	mov    rdx,r15
 2ab:	mov    rsi,rax
 2ae:	mov    rdi,r14
 2b1:	call   2b6 <botlish_fn_1+0xba>
			2b2: R_X86_64_PLT32	rt_str_cat-0x4
 2b6:	test   rax,rax
 2b9:	jne    2ec <botlish_fn_1+0xf0>
 2bf:	mov    rdi,r14
 2c2:	mov    rdi,r14
 2c5:	mov    QWORD PTR [rdi],r13
 2c8:	xor    rax,rax
 2cb:	mov    rbx,QWORD PTR [rsp]
 2cf:	mov    r12,QWORD PTR [rsp+0x8]
 2d4:	mov    r13,QWORD PTR [rsp+0x10]
 2d9:	mov    r14,QWORD PTR [rsp+0x18]
 2de:	mov    r15,QWORD PTR [rsp+0x20]
 2e3:	add    rsp,0x30
 2e7:	mov    rsp,rbp
 2ea:	pop    rbp
 2eb:	ret
 2ec:	mov    QWORD PTR [r13+0x0],rbx
 2f0:	mov    QWORD PTR [r13+0x8],rax
 2f4:	mov    r15,rax
 2f7:	jmp    24e <botlish_fn_1+0x52>
 2fc:	mov    rdi,r14
 2ff:	mov    QWORD PTR [rdi],r13
 302:	mov    rax,r15
 305:	mov    rbx,QWORD PTR [rsp]
 309:	mov    r12,QWORD PTR [rsp+0x8]
 30e:	mov    r13,QWORD PTR [rsp+0x10]
 313:	mov    r14,QWORD PTR [rsp+0x18]
 318:	mov    r15,QWORD PTR [rsp+0x20]
 31d:	add    rsp,0x30
 321:	mov    rsp,rbp
 324:	pop    rbp
 325:	ret
 326:	mov    r14,rdi
 329:	call   32e <botlish_fn_1+0x132>
			32a: R_X86_64_PLT32	rt_stack_overflow-0x4
 32e:	xor    rax,rax
 331:	mov    rbx,QWORD PTR [rsp]
 335:	mov    r12,QWORD PTR [rsp+0x8]
 33a:	mov    r13,QWORD PTR [rsp+0x10]
 33f:	mov    r14,QWORD PTR [rsp+0x18]
 344:	mov    r15,QWORD PTR [rsp+0x20]
 349:	add    rsp,0x30
 34d:	mov    rsp,rbp
 350:	pop    rbp
 351:	ret

0000000000000352 <botlish_entry_1: reverse_from<str, int, str>>:
 352:	push   rbp
 353:	mov    rbp,rsp
 356:	mov    rsi,QWORD PTR [rdx]
 359:	mov    r8,QWORD PTR [rdx+0x8]
 35d:	mov    rcx,QWORD PTR [rdx+0x10]
 361:	mov    rdx,r8
 364:	call   369 <botlish_entry_1+0x17>
			365: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 369:	mov    rsp,rbp
 36c:	pop    rbp
 36d:	ret

000000000000036e <botlish_fn_2: reverse_chars<str>>:
 36e:	push   rbp
 36f:	mov    rbp,rsp
 372:	sub    rsp,0x10
 376:	mov    QWORD PTR [rsp],rbx
 37a:	mov    QWORD PTR [rsp+0x8],r15
 37f:	mov    r15,QWORD PTR [rdi]
 382:	mov    rax,QWORD PTR [rdi+0x8]
 386:	lea    rcx,[r15+0x18]
 38a:	cmp    rcx,rax
 38d:	ja     3f9 <botlish_fn_2+0x8b>
 393:	lea    rax,[r15+0x18]
 397:	mov    QWORD PTR [rdi],rax
 39a:	mov    QWORD PTR [r15],rsi
 39d:	mov    edx,0x1
 3a2:	mov    QWORD PTR [r15+0x8],0x1
 3aa:	mov    rax,QWORD PTR [rdi+0x10]
 3ae:	mov    rbx,rdi
 3b1:	mov    rcx,QWORD PTR [rax]
 3b4:	mov    QWORD PTR [r15+0x10],rcx
 3b8:	call   3bd <botlish_fn_2+0x4f>
			3b9: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 3bd:	test   rax,rax
 3c0:	jne    3e1 <botlish_fn_2+0x73>
 3c6:	mov    rdi,rbx
 3c9:	mov    QWORD PTR [rdi],r15
 3cc:	xor    rax,rax
 3cf:	mov    rbx,QWORD PTR [rsp]
 3d3:	mov    r15,QWORD PTR [rsp+0x8]
 3d8:	add    rsp,0x10
 3dc:	mov    rsp,rbp
 3df:	pop    rbp
 3e0:	ret
 3e1:	mov    rdi,rbx
 3e4:	mov    QWORD PTR [rdi],r15
 3e7:	mov    rbx,QWORD PTR [rsp]
 3eb:	mov    r15,QWORD PTR [rsp+0x8]
 3f0:	add    rsp,0x10
 3f4:	mov    rsp,rbp
 3f7:	pop    rbp
 3f8:	ret
 3f9:	call   3fe <botlish_fn_2+0x90>
			3fa: R_X86_64_PLT32	rt_stack_overflow-0x4
 3fe:	xor    rax,rax
 401:	mov    rbx,QWORD PTR [rsp]
 405:	mov    r15,QWORD PTR [rsp+0x8]
 40a:	add    rsp,0x10
 40e:	mov    rsp,rbp
 411:	pop    rbp
 412:	ret

0000000000000413 <botlish_entry_2: reverse_chars<str>>:
 413:	push   rbp
 414:	mov    rbp,rsp
 417:	mov    rsi,QWORD PTR [rdx]
 41a:	call   41f <botlish_entry_2+0xc>
			41b: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 41f:	mov    rsp,rbp
 422:	pop    rbp
 423:	ret

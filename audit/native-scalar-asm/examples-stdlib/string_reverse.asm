; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 1069  (per function: 523 357 189)
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
 200:	sub    rsp,0x60
 204:	mov    QWORD PTR [rsp+0x30],rbx
 209:	mov    QWORD PTR [rsp+0x38],r12
 20e:	mov    QWORD PTR [rsp+0x40],r13
 213:	mov    QWORD PTR [rsp+0x48],r14
 218:	mov    QWORD PTR [rsp+0x50],r15
 21d:	mov    rbx,QWORD PTR [rdi+0x20]
 221:	mov    r15,QWORD PTR [rdi+0x28]
 225:	lea    rax,[rsp]
 229:	mov    QWORD PTR [rdi+0x20],rax
 22d:	mov    QWORD PTR [rdi+0x28],0x4
 235:	mov    QWORD PTR [rsp],rsi
 239:	mov    QWORD PTR [rsp+0x8],rcx
 23e:	sar    rdx,1
 241:	mov    r14,rdx
 244:	mov    r12,rdi
 247:	mov    r13,rsi
 24a:	mov    QWORD PTR [rsp+0x20],rcx
 24f:	mov    rsi,r13
 252:	mov    rdi,r12
 255:	call   25a <botlish_fn_1+0x5e>
			256: R_X86_64_PLT32	rt_str_len-0x4
 25a:	sar    rax,1
 25d:	cmp    r14,rax
 260:	je     2ff <botlish_fn_1+0x103>
 266:	mov    rdx,r14
 269:	shl    rdx,1
 26c:	or     rdx,0x1
 270:	mov    QWORD PTR [rsp+0x10],rdx
 275:	add    r14,0x1
 27c:	mov    rcx,r14
 27f:	shl    rcx,1
 282:	or     rcx,0x1
 286:	mov    QWORD PTR [rsp+0x18],rcx
 28b:	mov    rsi,r13
 28e:	mov    rdi,r12
 291:	call   296 <botlish_fn_1+0x9a>
			292: R_X86_64_PLT32	rt_substr-0x4
 296:	test   rax,rax
 299:	je     2bd <botlish_fn_1+0xc1>
 29f:	mov    QWORD PTR [rsp+0x10],rax
 2a4:	mov    rdx,QWORD PTR [rsp+0x20]
 2a9:	mov    rsi,rax
 2ac:	mov    rdi,r12
 2af:	call   2b4 <botlish_fn_1+0xb8>
			2b0: R_X86_64_PLT32	rt_str_cat-0x4
 2b4:	test   rax,rax
 2b7:	jne    2ec <botlish_fn_1+0xf0>
 2bd:	mov    QWORD PTR [r12+0x20],rbx
 2c2:	mov    QWORD PTR [r12+0x28],r15
 2c7:	xor    rax,rax
 2ca:	mov    rbx,QWORD PTR [rsp+0x30]
 2cf:	mov    r12,QWORD PTR [rsp+0x38]
 2d4:	mov    r13,QWORD PTR [rsp+0x40]
 2d9:	mov    r14,QWORD PTR [rsp+0x48]
 2de:	mov    r15,QWORD PTR [rsp+0x50]
 2e3:	add    rsp,0x60
 2e7:	mov    rsp,rbp
 2ea:	pop    rbp
 2eb:	ret
 2ec:	mov    QWORD PTR [rsp],r13
 2f0:	mov    QWORD PTR [rsp+0x8],rax
 2f5:	mov    QWORD PTR [rsp+0x20],rax
 2fa:	jmp    24f <botlish_fn_1+0x53>
 2ff:	mov    QWORD PTR [r12+0x20],rbx
 304:	mov    QWORD PTR [r12+0x28],r15
 309:	mov    rax,QWORD PTR [rsp+0x20]
 30e:	mov    rbx,QWORD PTR [rsp+0x30]
 313:	mov    r12,QWORD PTR [rsp+0x38]
 318:	mov    r13,QWORD PTR [rsp+0x40]
 31d:	mov    r14,QWORD PTR [rsp+0x48]
 322:	mov    r15,QWORD PTR [rsp+0x50]
 327:	add    rsp,0x60
 32b:	mov    rsp,rbp
 32e:	pop    rbp
 32f:	ret

0000000000000330 <botlish_entry_1: reverse_from<str, int, str>>:
 330:	push   rbp
 331:	mov    rbp,rsp
 334:	mov    rsi,QWORD PTR [rdx]
 337:	mov    r8,QWORD PTR [rdx+0x8]
 33b:	mov    rcx,QWORD PTR [rdx+0x10]
 33f:	mov    rdx,r8
 342:	call   347 <botlish_entry_1+0x17>
			343: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 347:	mov    rsp,rbp
 34a:	pop    rbp
 34b:	ret

000000000000034c <botlish_fn_2: reverse_chars<str>>:
 34c:	push   rbp
 34d:	mov    rbp,rsp
 350:	sub    rsp,0x10
 354:	mov    QWORD PTR [rsp],rbx
 358:	mov    QWORD PTR [rsp+0x8],r15
 35d:	mov    r15,QWORD PTR [rdi]
 360:	mov    rax,QWORD PTR [rdi+0x8]
 364:	lea    rcx,[r15+0x18]
 368:	cmp    rcx,rax
 36b:	ja     3d7 <botlish_fn_2+0x8b>
 371:	lea    rax,[r15+0x18]
 375:	mov    QWORD PTR [rdi],rax
 378:	mov    QWORD PTR [r15],rsi
 37b:	mov    edx,0x1
 380:	mov    QWORD PTR [r15+0x8],0x1
 388:	mov    rax,QWORD PTR [rdi+0x10]
 38c:	mov    rbx,rdi
 38f:	mov    rcx,QWORD PTR [rax]
 392:	mov    QWORD PTR [r15+0x10],rcx
 396:	call   39b <botlish_fn_2+0x4f>
			397: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 39b:	test   rax,rax
 39e:	jne    3bf <botlish_fn_2+0x73>
 3a4:	mov    rdi,rbx
 3a7:	mov    QWORD PTR [rdi],r15
 3aa:	xor    rax,rax
 3ad:	mov    rbx,QWORD PTR [rsp]
 3b1:	mov    r15,QWORD PTR [rsp+0x8]
 3b6:	add    rsp,0x10
 3ba:	mov    rsp,rbp
 3bd:	pop    rbp
 3be:	ret
 3bf:	mov    rdi,rbx
 3c2:	mov    QWORD PTR [rdi],r15
 3c5:	mov    rbx,QWORD PTR [rsp]
 3c9:	mov    r15,QWORD PTR [rsp+0x8]
 3ce:	add    rsp,0x10
 3d2:	mov    rsp,rbp
 3d5:	pop    rbp
 3d6:	ret
 3d7:	call   3dc <botlish_fn_2+0x90>
			3d8: R_X86_64_PLT32	rt_stack_overflow-0x4
 3dc:	xor    rax,rax
 3df:	mov    rbx,QWORD PTR [rsp]
 3e3:	mov    r15,QWORD PTR [rsp+0x8]
 3e8:	add    rsp,0x10
 3ec:	mov    rsp,rbp
 3ef:	pop    rbp
 3f0:	ret

00000000000003f1 <botlish_entry_2: reverse_chars<str>>:
 3f1:	push   rbp
 3f2:	mov    rbp,rsp
 3f5:	mov    rsi,QWORD PTR [rdx]
 3f8:	call   3fd <botlish_entry_2+0xc>
			3f9: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 3fd:	mov    rsp,rbp
 400:	pop    rbp
 401:	ret

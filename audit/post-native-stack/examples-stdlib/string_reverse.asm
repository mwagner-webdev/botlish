; source:  examples/stdlib/string_reverse.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 798  (per function: 418 290 90)
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
 19f:	sub    rsp,0x40
 1a3:	mov    QWORD PTR [rsp+0x20],rbx
 1a8:	mov    QWORD PTR [rsp+0x28],r12
 1ad:	mov    QWORD PTR [rsp+0x30],r13
 1b2:	mov    QWORD PTR [rsp+0x38],r14
 1b7:	mov    r13,rdi
 1ba:	mov    QWORD PTR [rsp],rsi
 1be:	mov    QWORD PTR [rsp+0x8],rcx
 1c3:	sar    rdx,1
 1c6:	mov    rbx,rdx
 1c9:	mov    r12,rsi
 1cc:	mov    r14,rcx
 1cf:	mov    rsi,r12
 1d2:	mov    rdi,r13
 1d5:	call   1da <botlish_fn_1+0x3f>
			1d6: R_X86_64_PLT32	rt_str_len-0x4
 1da:	sar    rax,1
 1dd:	cmp    rbx,rax
 1e0:	je     26c <botlish_fn_1+0xd1>
 1e6:	mov    rdx,rbx
 1e9:	shl    rdx,1
 1ec:	or     rdx,0x1
 1f0:	mov    QWORD PTR [rsp+0x10],rdx
 1f5:	add    rbx,0x1
 1fc:	mov    rcx,rbx
 1ff:	shl    rcx,1
 202:	or     rcx,0x1
 206:	mov    QWORD PTR [rsp+0x18],rcx
 20b:	mov    rsi,r12
 20e:	mov    rdi,r13
 211:	call   216 <botlish_fn_1+0x7b>
			212: R_X86_64_PLT32	rt_substr-0x4
 216:	test   rax,rax
 219:	je     23b <botlish_fn_1+0xa0>
 21f:	mov    QWORD PTR [rsp+0x10],rax
 224:	mov    rdx,r14
 227:	mov    rsi,rax
 22a:	mov    rdi,r13
 22d:	call   232 <botlish_fn_1+0x97>
			22e: R_X86_64_PLT32	rt_str_cat-0x4
 232:	test   rax,rax
 235:	jne    25b <botlish_fn_1+0xc0>
 23b:	xor    rax,rax
 23e:	mov    rbx,QWORD PTR [rsp+0x20]
 243:	mov    r12,QWORD PTR [rsp+0x28]
 248:	mov    r13,QWORD PTR [rsp+0x30]
 24d:	mov    r14,QWORD PTR [rsp+0x38]
 252:	add    rsp,0x40
 256:	mov    rsp,rbp
 259:	pop    rbp
 25a:	ret
 25b:	mov    QWORD PTR [rsp],r12
 25f:	mov    QWORD PTR [rsp+0x8],rax
 264:	mov    r14,rax
 267:	jmp    1cf <botlish_fn_1+0x34>
 26c:	mov    rax,r14
 26f:	mov    rbx,QWORD PTR [rsp+0x20]
 274:	mov    r12,QWORD PTR [rsp+0x28]
 279:	mov    r13,QWORD PTR [rsp+0x30]
 27e:	mov    r14,QWORD PTR [rsp+0x38]
 283:	add    rsp,0x40
 287:	mov    rsp,rbp
 28a:	pop    rbp
 28b:	ret

000000000000028c <botlish_entry_1: reverse_from<str, int, str>>:
 28c:	push   rbp
 28d:	mov    rbp,rsp
 290:	mov    rsi,QWORD PTR [rdx]
 293:	mov    r8,QWORD PTR [rdx+0x8]
 297:	mov    rcx,QWORD PTR [rdx+0x10]
 29b:	mov    rdx,r8
 29e:	call   2a3 <botlish_entry_1+0x17>
			29f: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 2a3:	mov    rsp,rbp
 2a6:	pop    rbp
 2a7:	ret

00000000000002a8 <botlish_fn_2: reverse_chars<str>>:
 2a8:	push   rbp
 2a9:	mov    rbp,rsp
 2ac:	sub    rsp,0x20
 2b0:	mov    QWORD PTR [rsp],rsi
 2b4:	mov    edx,0x1
 2b9:	mov    QWORD PTR [rsp+0x8],0x1
 2c2:	mov    r11,QWORD PTR [rdi+0x10]
 2c6:	mov    rcx,QWORD PTR [r11]
 2c9:	mov    QWORD PTR [rsp+0x10],rcx
 2ce:	call   2d3 <botlish_fn_2+0x2b>
			2cf: R_X86_64_PLT32	botlish_fn_1-0x4 ; reverse_from<str, int, str>
 2d3:	test   rax,rax
 2d6:	jne    2e8 <botlish_fn_2+0x40>
 2dc:	xor    rax,rax
 2df:	add    rsp,0x20
 2e3:	mov    rsp,rbp
 2e6:	pop    rbp
 2e7:	ret
 2e8:	add    rsp,0x20
 2ec:	mov    rsp,rbp
 2ef:	pop    rbp
 2f0:	ret

00000000000002f1 <botlish_entry_2: reverse_chars<str>>:
 2f1:	push   rbp
 2f2:	mov    rbp,rsp
 2f5:	mov    rsi,QWORD PTR [rdx]
 2f8:	call   2fd <botlish_entry_2+0xc>
			2f9: R_X86_64_PLT32	botlish_fn_2-0x4 ; reverse_chars<str>
 2fd:	mov    rsp,rbp
 300:	pop    rbp
 301:	ret

; source:  bench/loop-count.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 745  (per function: 187 97 461)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> work<int>
;   botlish_fn_2 / botlish_entry_2 -> drive<int, int>


loop-count.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    QWORD PTR [rsp],r13
   c:	mov    QWORD PTR [rsp+0x8],r14
  11:	mov    r13,QWORD PTR [rdi]
  14:	mov    rax,QWORD PTR [rdi+0x8]
  18:	lea    rcx,[r13+0x10]
  1c:	cmp    rcx,rax
  1f:	ja     8d <botlish_fn_0+0x8d>
  25:	lea    rax,[r13+0x10]
  29:	mov    QWORD PTR [rdi],rax
  2c:	mov    r14,rdi
  2f:	mov    esi,0x3e9
  34:	mov    QWORD PTR [r13+0x0],0x3e9
  3c:	mov    edx,0x1
  41:	mov    QWORD PTR [r13+0x8],0x1
  49:	mov    rdi,r14
  4c:	call   51 <botlish_fn_0+0x51>
			4d: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
  51:	test   rax,rax
  54:	jne    75 <botlish_fn_0+0x75>
  5a:	mov    rdi,r14
  5d:	mov    QWORD PTR [rdi],r13
  60:	xor    rax,rax
  63:	mov    r13,QWORD PTR [rsp]
  67:	mov    r14,QWORD PTR [rsp+0x8]
  6c:	add    rsp,0x10
  70:	mov    rsp,rbp
  73:	pop    rbp
  74:	ret
  75:	mov    rdi,r14
  78:	mov    QWORD PTR [rdi],r13
  7b:	mov    r13,QWORD PTR [rsp]
  7f:	mov    r14,QWORD PTR [rsp+0x8]
  84:	add    rsp,0x10
  88:	mov    rsp,rbp
  8b:	pop    rbp
  8c:	ret
  8d:	call   92 <botlish_fn_0+0x92>
			8e: R_X86_64_PLT32	rt_stack_overflow-0x4
  92:	xor    rax,rax
  95:	mov    r13,QWORD PTR [rsp]
  99:	mov    r14,QWORD PTR [rsp+0x8]
  9e:	add    rsp,0x10
  a2:	mov    rsp,rbp
  a5:	pop    rbp
  a6:	ret

00000000000000a7 <botlish_entry_0: <program entry>>:
  a7:	push   rbp
  a8:	mov    rbp,rsp
  ab:	call   b0 <botlish_entry_0+0x9>
			ac: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  b0:	mov    rsp,rbp
  b3:	pop    rbp
  b4:	ret

00000000000000b5 <botlish_fn_1: work<int>>:
  b5:	push   rbp
  b6:	mov    rbp,rsp
  b9:	mov    rax,QWORD PTR [rdi]
  bc:	mov    rcx,QWORD PTR [rdi+0x8]
  c0:	lea    rdx,[rax+0x8]
  c4:	cmp    rdx,rcx
  c7:	ja     f1 <botlish_fn_1+0x3c>
  cd:	sar    rsi,1
  d0:	imul   rcx,rsi,0x3
  d4:	add    rcx,0x7
  db:	test   rcx,rcx
  de:	jl     db <botlish_fn_1+0x26>
  e4:	mov    QWORD PTR [rdi],rax
  e7:	mov    eax,0xf
  ec:	mov    rsp,rbp
  ef:	pop    rbp
  f0:	ret
  f1:	call   f6 <botlish_fn_1+0x41>
			f2: R_X86_64_PLT32	rt_stack_overflow-0x4
  f6:	xor    rax,rax
  f9:	mov    rsp,rbp
  fc:	pop    rbp
  fd:	ret

00000000000000fe <botlish_entry_1: work<int>>:
  fe:	push   rbp
  ff:	mov    rbp,rsp
 102:	mov    rsi,QWORD PTR [rdx]
 105:	call   10a <botlish_entry_1+0xc>
			106: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 10a:	mov    rsp,rbp
 10d:	pop    rbp
 10e:	ret
	...

0000000000000110 <botlish_fn_2: drive<int, int>>:
 110:	push   rbp
 111:	mov    rbp,rsp
 114:	sub    rsp,0x30
 118:	mov    QWORD PTR [rsp],rbx
 11c:	mov    QWORD PTR [rsp+0x8],r12
 121:	mov    QWORD PTR [rsp+0x10],r13
 126:	mov    QWORD PTR [rsp+0x18],r14
 12b:	mov    QWORD PTR [rsp+0x20],r15
 130:	mov    r13,QWORD PTR [rdi]
 133:	mov    rax,QWORD PTR [rdi+0x8]
 137:	lea    rcx,[r13+0x18]
 13b:	cmp    rcx,rax
 13e:	ja     27b <botlish_fn_2+0x16b>
 144:	lea    rax,[r13+0x18]
 148:	mov    QWORD PTR [rdi],rax
 14b:	mov    r14,rdi
 14e:	mov    QWORD PTR [r13+0x0],rsi
 152:	mov    QWORD PTR [r13+0x8],rdx
 156:	mov    r12,rsi
 159:	mov    r15,rdx
 15c:	test   r12,0x1
 163:	jne    18e <botlish_fn_2+0x7e>
 169:	mov    edx,0x1
 16e:	mov    rsi,r12
 171:	mov    rdi,r14
 174:	call   179 <botlish_fn_2+0x69>
			175: R_X86_64_PLT32	rt_int_cmp-0x4
 179:	mov    ecx,0x2
 17e:	test   rax,rax
 181:	cmovle rcx,QWORD PTR [rip+0x11f]        # 2a8 <botlish_fn_2+0x198>
 189:	jmp    19f <botlish_fn_2+0x8f>
 18e:	mov    ecx,0x2
 193:	cmp    r12,0x1
 197:	cmovle rcx,QWORD PTR [rip+0x109]        # 2a8 <botlish_fn_2+0x198>
 19f:	cmp    rcx,0x6
 1a3:	je     251 <botlish_fn_2+0x141>
 1a9:	mov    rbx,r12
 1ac:	sar    rbx,1
 1af:	sub    rbx,0x1
 1b3:	shl    rbx,1
 1b6:	or     rbx,0x1
 1ba:	mov    QWORD PTR [r13+0x10],rbx
 1be:	mov    rsi,r12
 1c1:	mov    rdi,r14
 1c4:	call   1c9 <botlish_fn_2+0xb9>
			1c5: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 1c9:	test   rax,rax
 1cc:	jne    1fc <botlish_fn_2+0xec>
 1d2:	mov    rdi,r14
 1d5:	mov    QWORD PTR [rdi],r13
 1d8:	xor    rax,rax
 1db:	mov    rbx,QWORD PTR [rsp]
 1df:	mov    r12,QWORD PTR [rsp+0x8]
 1e4:	mov    r13,QWORD PTR [rsp+0x10]
 1e9:	mov    r14,QWORD PTR [rsp+0x18]
 1ee:	mov    r15,QWORD PTR [rsp+0x20]
 1f3:	add    rsp,0x30
 1f7:	mov    rsp,rbp
 1fa:	pop    rbp
 1fb:	ret
 1fc:	mov    QWORD PTR [r13+0x0],rax
 200:	mov    rsi,r15
 203:	mov    rcx,rsi
 206:	and    rcx,rax
 209:	test   rcx,0x1
 210:	jne    21e <botlish_fn_2+0x10e>
 216:	mov    rdx,rax
 219:	jmp    236 <botlish_fn_2+0x126>
 21e:	lea    rcx,[rax-0x1]
 222:	mov    rdx,rax
 225:	mov    rax,rsi
 228:	add    rax,rcx
 22b:	seto   cl
 22e:	test   cl,cl
 230:	je     23e <botlish_fn_2+0x12e>
 236:	mov    rdi,r14
 239:	call   23e <botlish_fn_2+0x12e>
			23a: R_X86_64_PLT32	rt_int_add-0x4
 23e:	mov    QWORD PTR [r13+0x0],rbx
 242:	mov    QWORD PTR [r13+0x8],rax
 246:	mov    r12,rbx
 249:	mov    r15,rax
 24c:	jmp    15c <botlish_fn_2+0x4c>
 251:	mov    rdi,r14
 254:	mov    QWORD PTR [rdi],r13
 257:	mov    rax,r15
 25a:	mov    rbx,QWORD PTR [rsp]
 25e:	mov    r12,QWORD PTR [rsp+0x8]
 263:	mov    r13,QWORD PTR [rsp+0x10]
 268:	mov    r14,QWORD PTR [rsp+0x18]
 26d:	mov    r15,QWORD PTR [rsp+0x20]
 272:	add    rsp,0x30
 276:	mov    rsp,rbp
 279:	pop    rbp
 27a:	ret
 27b:	mov    r14,rdi
 27e:	call   283 <botlish_fn_2+0x173>
			27f: R_X86_64_PLT32	rt_stack_overflow-0x4
 283:	xor    rax,rax
 286:	mov    rbx,QWORD PTR [rsp]
 28a:	mov    r12,QWORD PTR [rsp+0x8]
 28f:	mov    r13,QWORD PTR [rsp+0x10]
 294:	mov    r14,QWORD PTR [rsp+0x18]
 299:	mov    r15,QWORD PTR [rsp+0x20]
 29e:	add    rsp,0x30
 2a2:	mov    rsp,rbp
 2a5:	pop    rbp
 2a6:	ret
 2a7:	add    BYTE PTR [rsi],al
 2a9:	add    BYTE PTR [rax],al
 2ab:	add    BYTE PTR [rax],al
 2ad:	add    BYTE PTR [rax],al
	...

00000000000002b0 <botlish_entry_2: drive<int, int>>:
 2b0:	push   rbp
 2b1:	mov    rbp,rsp
 2b4:	mov    rsi,QWORD PTR [rdx]
 2b7:	mov    rdx,QWORD PTR [rdx+0x8]
 2bb:	call   2c0 <botlish_entry_2+0x10>
			2bc: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 2c0:	mov    rsp,rbp
 2c3:	pop    rbp
 2c4:	ret

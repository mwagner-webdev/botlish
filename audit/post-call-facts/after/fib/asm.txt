; source:  bench/fib.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 463  (per function: 70 393)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> fib<int>


fib.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    esi,0x2d
   d:	mov    QWORD PTR [rsp],0x2d
  15:	call   1a <botlish_fn_0+0x1a>
			16: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  1a:	test   rax,rax
  1d:	jne    2f <botlish_fn_0+0x2f>
  23:	xor    rax,rax
  26:	add    rsp,0x10
  2a:	mov    rsp,rbp
  2d:	pop    rbp
  2e:	ret
  2f:	add    rsp,0x10
  33:	mov    rsp,rbp
  36:	pop    rbp
  37:	ret

0000000000000038 <botlish_entry_0: <program entry>>:
  38:	push   rbp
  39:	mov    rbp,rsp
  3c:	call   41 <botlish_entry_0+0x9>
			3d: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  41:	mov    rsp,rbp
  44:	pop    rbp
  45:	ret
	...

0000000000000048 <botlish_fn_1: fib<int>>:
  48:	push   rbp
  49:	mov    rbp,rsp
  4c:	sub    rsp,0x30
  50:	mov    QWORD PTR [rsp+0x10],rbx
  55:	mov    QWORD PTR [rsp+0x18],r12
  5a:	mov    QWORD PTR [rsp+0x20],r13
  5f:	mov    rbx,rdi
  62:	mov    QWORD PTR [rsp+0x8],0x0
  6b:	test   rsi,0x1
  72:	mov    r12,rsi
  75:	jne    a1 <botlish_fn_1+0x59>
  7b:	mov    edx,0x5
  80:	mov    rsi,r12
  83:	mov    rdi,rbx
  86:	call   8b <botlish_fn_1+0x43>
			87: R_X86_64_PLT32	rt_int_cmp-0x4
  8b:	mov    r9d,0x2
  91:	test   rax,rax
  94:	cmovl  r9,QWORD PTR [rip+0x114]        # 1b0 <botlish_fn_1+0x168>
  9c:	jmp    b6 <botlish_fn_1+0x6e>
  a1:	mov    r9d,0x2
  a7:	mov    rsi,r12
  aa:	cmp    rsi,0x5
  ae:	cmovl  r9,QWORD PTR [rip+0xfa]        # 1b0 <botlish_fn_1+0x168>
  b6:	cmp    r9,0x6
  ba:	je     18f <botlish_fn_1+0x147>
  c0:	mov    rsi,r12
  c3:	sar    rsi,1
  c6:	mov    r12,rsi
  c9:	sub    rsi,0x1
  cd:	shl    rsi,1
  d0:	or     rsi,0x1
  d4:	mov    QWORD PTR [rsp],rsi
  d8:	mov    rdi,rbx
  db:	call   e0 <botlish_fn_1+0x98>
			dc: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  e0:	test   rax,rax
  e3:	je     11d <botlish_fn_1+0xd5>
  e9:	mov    QWORD PTR [rsp],rax
  ed:	mov    rsi,r12
  f0:	mov    r13,rax
  f3:	sub    rsi,0x2
  f7:	mov    r12,rsi
  fa:	shl    rsi,1
  fd:	mov    r12,rsi
 100:	or     rsi,0x1
 104:	mov    r12,rsi
 107:	mov    QWORD PTR [rsp+0x8],rsi
 10c:	mov    rdi,rbx
 10f:	call   114 <botlish_fn_1+0xcc>
			110: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 114:	test   rax,rax
 117:	jne    138 <botlish_fn_1+0xf0>
 11d:	xor    rax,rax
 120:	mov    rbx,QWORD PTR [rsp+0x10]
 125:	mov    r12,QWORD PTR [rsp+0x18]
 12a:	mov    r13,QWORD PTR [rsp+0x20]
 12f:	add    rsp,0x30
 133:	mov    rsp,rbp
 136:	pop    rbp
 137:	ret
 138:	mov    QWORD PTR [rsp+0x8],rax
 13d:	mov    rcx,r13
 140:	mov    rdx,rcx
 143:	and    rdx,rax
 146:	test   rdx,0x1
 14d:	jne    161 <botlish_fn_1+0x119>
 153:	mov    rdx,rax
 156:	mov    rsi,rcx
 159:	mov    rdi,rbx
 15c:	jmp    185 <botlish_fn_1+0x13d>
 161:	lea    rdx,[rax-0x1]
 165:	mov    rsi,rax
 168:	mov    rax,rcx
 16b:	add    rax,rdx
 16e:	mov    r13,rcx
 171:	seto   cl
 174:	test   cl,cl
 176:	je     192 <botlish_fn_1+0x14a>
 17c:	mov    rdi,rbx
 17f:	mov    rdx,rsi
 182:	mov    rsi,r13
 185:	call   18a <botlish_fn_1+0x142>
			186: R_X86_64_PLT32	rt_int_add-0x4
 18a:	jmp    192 <botlish_fn_1+0x14a>
 18f:	mov    rax,r12
 192:	mov    rbx,QWORD PTR [rsp+0x10]
 197:	mov    r12,QWORD PTR [rsp+0x18]
 19c:	mov    r13,QWORD PTR [rsp+0x20]
 1a1:	add    rsp,0x30
 1a5:	mov    rsp,rbp
 1a8:	pop    rbp
 1a9:	ret
 1aa:	add    BYTE PTR [rax],al
 1ac:	add    BYTE PTR [rax],al
 1ae:	add    BYTE PTR [rax],al
 1b0:	(bad)
 1b1:	add    BYTE PTR [rax],al
 1b3:	add    BYTE PTR [rax],al
 1b5:	add    BYTE PTR [rax],al
	...

00000000000001b8 <botlish_entry_1: fib<int>>:
 1b8:	push   rbp
 1b9:	mov    rbp,rsp
 1bc:	mov    rsi,QWORD PTR [rdx]
 1bf:	call   1c4 <botlish_entry_1+0xc>
			1c0: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 1c4:	mov    rsp,rbp
 1c7:	pop    rbp
 1c8:	ret

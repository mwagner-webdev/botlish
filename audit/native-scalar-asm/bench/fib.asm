; source:  bench/fib.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 700  (per function: 187 513)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> fib<int>


fib.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x20
   8:	mov    QWORD PTR [rsp+0x10],r12
   d:	mov    QWORD PTR [rsp+0x18],r13
  12:	mov    r12,QWORD PTR [rdi]
  15:	mov    rax,QWORD PTR [rdi+0x8]
  19:	lea    rcx,[r12+0x8]
  1e:	cmp    rcx,rax
  21:	ja     8d <botlish_fn_0+0x8d>
  27:	lea    rax,[r12+0x8]
  2c:	mov    QWORD PTR [rdi],rax
  2f:	mov    r13,rdi
  32:	mov    QWORD PTR [r12],0x0
  3a:	mov    esi,0x2d
  3f:	mov    QWORD PTR [rsp],0x2d
  47:	mov    rdi,r13
  4a:	call   4f <botlish_fn_0+0x4f>
			4b: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  4f:	test   rax,rax
  52:	jne    74 <botlish_fn_0+0x74>
  58:	mov    rdi,r13
  5b:	mov    QWORD PTR [rdi],r12
  5e:	xor    rax,rax
  61:	mov    r12,QWORD PTR [rsp+0x10]
  66:	mov    r13,QWORD PTR [rsp+0x18]
  6b:	add    rsp,0x20
  6f:	mov    rsp,rbp
  72:	pop    rbp
  73:	ret
  74:	mov    rdi,r13
  77:	mov    QWORD PTR [rdi],r12
  7a:	mov    r12,QWORD PTR [rsp+0x10]
  7f:	mov    r13,QWORD PTR [rsp+0x18]
  84:	add    rsp,0x20
  88:	mov    rsp,rbp
  8b:	pop    rbp
  8c:	ret
  8d:	call   92 <botlish_fn_0+0x92>
			8e: R_X86_64_PLT32	rt_stack_overflow-0x4
  92:	xor    rax,rax
  95:	mov    r12,QWORD PTR [rsp+0x10]
  9a:	mov    r13,QWORD PTR [rsp+0x18]
  9f:	add    rsp,0x20
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
	...

00000000000000b8 <botlish_fn_1: fib<int>>:
  b8:	push   rbp
  b9:	mov    rbp,rsp
  bc:	sub    rsp,0x30
  c0:	mov    QWORD PTR [rsp+0x10],rbx
  c5:	mov    QWORD PTR [rsp+0x18],r12
  ca:	mov    QWORD PTR [rsp+0x20],r13
  cf:	mov    QWORD PTR [rsp+0x28],r14
  d4:	mov    rbx,QWORD PTR [rdi]
  d7:	mov    rax,QWORD PTR [rdi+0x8]
  db:	lea    rcx,[rbx+0x8]
  df:	cmp    rcx,rax
  e2:	ja     263 <botlish_fn_1+0x1ab>
  e8:	lea    rax,[rbx+0x8]
  ec:	mov    QWORD PTR [rdi],rax
  ef:	mov    r12,rdi
  f2:	mov    QWORD PTR [rbx],0x0
  f9:	mov    QWORD PTR [rsp+0x8],0x0
 102:	test   rsi,0x1
 109:	mov    r13,rsi
 10c:	jne    137 <botlish_fn_1+0x7f>
 112:	mov    edx,0x5
 117:	mov    rsi,r13
 11a:	mov    rdi,r12
 11d:	call   122 <botlish_fn_1+0x6a>
			11e: R_X86_64_PLT32	rt_int_cmp-0x4
 122:	mov    ecx,0x2
 127:	test   rax,rax
 12a:	cmovl  rcx,QWORD PTR [rip+0x15e]        # 290 <botlish_fn_1+0x1d8>
 132:	jmp    14b <botlish_fn_1+0x93>
 137:	mov    ecx,0x2
 13c:	mov    rsi,r13
 13f:	cmp    rsi,0x5
 143:	cmovl  rcx,QWORD PTR [rip+0x145]        # 290 <botlish_fn_1+0x1d8>
 14b:	cmp    rcx,0x6
 14f:	je     23a <botlish_fn_1+0x182>
 155:	mov    rsi,r13
 158:	sar    rsi,1
 15b:	mov    r13,rsi
 15e:	sub    rsi,0x1
 162:	shl    rsi,1
 165:	or     rsi,0x1
 169:	mov    QWORD PTR [rsp],rsi
 16d:	mov    rdi,r12
 170:	call   175 <botlish_fn_1+0xbd>
			171: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 175:	test   rax,rax
 178:	jne    186 <botlish_fn_1+0xce>
 17e:	mov    rdi,r12
 181:	jmp    1bd <botlish_fn_1+0x105>
 186:	mov    QWORD PTR [rsp],rax
 18a:	mov    rsi,r13
 18d:	mov    r14,rax
 190:	sub    rsi,0x2
 194:	mov    r13,rsi
 197:	shl    rsi,1
 19a:	mov    r13,rsi
 19d:	or     rsi,0x1
 1a1:	mov    r13,rsi
 1a4:	mov    QWORD PTR [rsp+0x8],rsi
 1a9:	mov    rdi,r12
 1ac:	call   1b1 <botlish_fn_1+0xf9>
			1ad: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 1b1:	test   rax,rax
 1b4:	jne    1e3 <botlish_fn_1+0x12b>
 1ba:	mov    rdi,r12
 1bd:	mov    rdi,r12
 1c0:	mov    QWORD PTR [rdi],rbx
 1c3:	xor    rax,rax
 1c6:	mov    rbx,QWORD PTR [rsp+0x10]
 1cb:	mov    r12,QWORD PTR [rsp+0x18]
 1d0:	mov    r13,QWORD PTR [rsp+0x20]
 1d5:	mov    r14,QWORD PTR [rsp+0x28]
 1da:	add    rsp,0x30
 1de:	mov    rsp,rbp
 1e1:	pop    rbp
 1e2:	ret
 1e3:	mov    QWORD PTR [rsp+0x8],rax
 1e8:	mov    rcx,r14
 1eb:	mov    rdx,rcx
 1ee:	and    rdx,rax
 1f1:	test   rdx,0x1
 1f8:	jne    209 <botlish_fn_1+0x151>
 1fe:	mov    rdx,rax
 201:	mov    rsi,rcx
 204:	jmp    22a <botlish_fn_1+0x172>
 209:	lea    rdx,[rax-0x1]
 20d:	mov    rsi,rax
 210:	mov    rax,rcx
 213:	add    rax,rdx
 216:	mov    r14,rcx
 219:	seto   cl
 21c:	test   cl,cl
 21e:	je     232 <botlish_fn_1+0x17a>
 224:	mov    rdx,rsi
 227:	mov    rsi,r14
 22a:	mov    rdi,r12
 22d:	call   232 <botlish_fn_1+0x17a>
			22e: R_X86_64_PLT32	rt_int_add-0x4
 232:	mov    rdi,r12
 235:	jmp    240 <botlish_fn_1+0x188>
 23a:	mov    rax,r13
 23d:	mov    rdi,r12
 240:	mov    rdi,r12
 243:	mov    QWORD PTR [rdi],rbx
 246:	mov    rbx,QWORD PTR [rsp+0x10]
 24b:	mov    r12,QWORD PTR [rsp+0x18]
 250:	mov    r13,QWORD PTR [rsp+0x20]
 255:	mov    r14,QWORD PTR [rsp+0x28]
 25a:	add    rsp,0x30
 25e:	mov    rsp,rbp
 261:	pop    rbp
 262:	ret
 263:	mov    r12,rdi
 266:	call   26b <botlish_fn_1+0x1b3>
			267: R_X86_64_PLT32	rt_stack_overflow-0x4
 26b:	xor    rax,rax
 26e:	mov    rbx,QWORD PTR [rsp+0x10]
 273:	mov    r12,QWORD PTR [rsp+0x18]
 278:	mov    r13,QWORD PTR [rsp+0x20]
 27d:	mov    r14,QWORD PTR [rsp+0x28]
 282:	add    rsp,0x30
 286:	mov    rsp,rbp
 289:	pop    rbp
 28a:	ret
 28b:	add    BYTE PTR [rax],al
 28d:	add    BYTE PTR [rax],al
 28f:	add    BYTE PTR [rsi],al
 291:	add    BYTE PTR [rax],al
 293:	add    BYTE PTR [rax],al
 295:	add    BYTE PTR [rax],al
	...

0000000000000298 <botlish_entry_1: fib<int>>:
 298:	push   rbp
 299:	mov    rbp,rsp
 29c:	mov    rsi,QWORD PTR [rdx]
 29f:	call   2a4 <botlish_entry_1+0xc>
			2a0: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 2a4:	mov    rsp,rbp
 2a7:	pop    rbp
 2a8:	ret

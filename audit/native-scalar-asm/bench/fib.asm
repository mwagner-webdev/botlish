; source:  bench/fib.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 680  (per function: 175 505)
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
   8:	mov    QWORD PTR [rsp],r13
   c:	mov    QWORD PTR [rsp+0x8],r14
  11:	mov    r13,QWORD PTR [rdi]
  14:	mov    rax,QWORD PTR [rdi+0x8]
  18:	lea    rcx,[r13+0x8]
  1c:	cmp    rcx,rax
  1f:	ja     80 <botlish_fn_0+0x80>
  25:	lea    rax,[r13+0x8]
  29:	mov    QWORD PTR [rdi],rax
  2c:	mov    r14,rdi
  2f:	mov    esi,0x25
  34:	mov    QWORD PTR [r13+0x0],0x25
  3c:	mov    rdi,r14
  3f:	call   44 <botlish_fn_0+0x44>
			40: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  44:	test   rax,rax
  47:	jne    68 <botlish_fn_0+0x68>
  4d:	mov    rdi,r14
  50:	mov    QWORD PTR [rdi],r13
  53:	xor    rax,rax
  56:	mov    r13,QWORD PTR [rsp]
  5a:	mov    r14,QWORD PTR [rsp+0x8]
  5f:	add    rsp,0x10
  63:	mov    rsp,rbp
  66:	pop    rbp
  67:	ret
  68:	mov    rdi,r14
  6b:	mov    QWORD PTR [rdi],r13
  6e:	mov    r13,QWORD PTR [rsp]
  72:	mov    r14,QWORD PTR [rsp+0x8]
  77:	add    rsp,0x10
  7b:	mov    rsp,rbp
  7e:	pop    rbp
  7f:	ret
  80:	mov    rax,QWORD PTR [rip+0x0]        # 87 <botlish_fn_0+0x87>
			83: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
  87:	call   rax
  89:	xor    rax,rax
  8c:	mov    r13,QWORD PTR [rsp]
  90:	mov    r14,QWORD PTR [rsp+0x8]
  95:	add    rsp,0x10
  99:	mov    rsp,rbp
  9c:	pop    rbp
  9d:	ret

000000000000009e <botlish_entry_0: <program entry>>:
  9e:	push   rbp
  9f:	mov    rbp,rsp
  a2:	call   a7 <botlish_entry_0+0x9>
			a3: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  a7:	mov    rsp,rbp
  aa:	pop    rbp
  ab:	ret
  ac:	add    BYTE PTR [rax],al
	...

00000000000000b0 <botlish_fn_1: fib<int>>:
  b0:	push   rbp
  b1:	mov    rbp,rsp
  b4:	sub    rsp,0x20
  b8:	mov    QWORD PTR [rsp],rbx
  bc:	mov    QWORD PTR [rsp+0x8],r12
  c1:	mov    QWORD PTR [rsp+0x10],r13
  c6:	mov    QWORD PTR [rsp+0x18],r14
  cb:	mov    rbx,QWORD PTR [rdi]
  ce:	mov    rax,QWORD PTR [rdi+0x8]
  d2:	lea    rcx,[rbx+0x10]
  d6:	cmp    rcx,rax
  d9:	ja     25b <botlish_fn_1+0x1ab>
  df:	lea    rax,[rbx+0x10]
  e3:	mov    QWORD PTR [rdi],rax
  e6:	mov    r12,rdi
  e9:	mov    QWORD PTR [rbx],0x0
  f0:	mov    QWORD PTR [rbx+0x8],0x0
  f8:	test   rsi,0x1
  ff:	mov    r13,rsi
 102:	jne    131 <botlish_fn_1+0x81>
 108:	mov    edx,0x5
 10d:	mov    rax,QWORD PTR [rip+0x0]        # 114 <botlish_fn_1+0x64>
			110: R_X86_64_GOTPCREL	rt_int_cmp-0x4
 114:	mov    rsi,r13
 117:	mov    rdi,r12
 11a:	call   rax
 11c:	mov    ecx,0x2
 121:	test   rax,rax
 124:	cmovl  rcx,QWORD PTR [rip+0x15c]        # 288 <botlish_fn_1+0x1d8>
 12c:	jmp    145 <botlish_fn_1+0x95>
 131:	mov    ecx,0x2
 136:	mov    rsi,r13
 139:	cmp    rsi,0x5
 13d:	cmovl  rcx,QWORD PTR [rip+0x143]        # 288 <botlish_fn_1+0x1d8>
 145:	cmp    rcx,0x6
 149:	je     233 <botlish_fn_1+0x183>
 14f:	mov    rsi,r13
 152:	sar    rsi,1
 155:	mov    r13,rsi
 158:	sub    rsi,0x1
 15c:	shl    rsi,1
 15f:	or     rsi,0x1
 163:	mov    QWORD PTR [rbx],rsi
 166:	mov    rdi,r12
 169:	call   16e <botlish_fn_1+0xbe>
			16a: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 16e:	test   rax,rax
 171:	jne    17f <botlish_fn_1+0xcf>
 177:	mov    rdi,r12
 17a:	jmp    1b4 <botlish_fn_1+0x104>
 17f:	mov    QWORD PTR [rbx],rax
 182:	mov    rsi,r13
 185:	mov    r14,rax
 188:	sub    rsi,0x2
 18c:	mov    r13,rsi
 18f:	shl    rsi,1
 192:	mov    r13,rsi
 195:	or     rsi,0x1
 199:	mov    r13,rsi
 19c:	mov    QWORD PTR [rbx+0x8],rsi
 1a0:	mov    rdi,r12
 1a3:	call   1a8 <botlish_fn_1+0xf8>
			1a4: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 1a8:	test   rax,rax
 1ab:	jne    1d9 <botlish_fn_1+0x129>
 1b1:	mov    rdi,r12
 1b4:	mov    rdi,r12
 1b7:	mov    QWORD PTR [rdi],rbx
 1ba:	xor    rax,rax
 1bd:	mov    rbx,QWORD PTR [rsp]
 1c1:	mov    r12,QWORD PTR [rsp+0x8]
 1c6:	mov    r13,QWORD PTR [rsp+0x10]
 1cb:	mov    r14,QWORD PTR [rsp+0x18]
 1d0:	add    rsp,0x20
 1d4:	mov    rsp,rbp
 1d7:	pop    rbp
 1d8:	ret
 1d9:	mov    QWORD PTR [rbx+0x8],rax
 1dd:	mov    rcx,r14
 1e0:	mov    rdx,rcx
 1e3:	and    rdx,rax
 1e6:	test   rdx,0x1
 1ed:	jne    1fe <botlish_fn_1+0x14e>
 1f3:	mov    rdx,rax
 1f6:	mov    r14,rcx
 1f9:	jmp    21b <botlish_fn_1+0x16b>
 1fe:	lea    rsi,[rax-0x1]
 202:	mov    rdx,rax
 205:	mov    rax,rcx
 208:	add    rax,rsi
 20b:	mov    r14,rcx
 20e:	seto   sil
 212:	test   sil,sil
 215:	je     22b <botlish_fn_1+0x17b>
 21b:	mov    r8,QWORD PTR [rip+0x0]        # 222 <botlish_fn_1+0x172>
			21e: R_X86_64_GOTPCREL	rt_int_add-0x4
 222:	mov    rsi,r14
 225:	mov    rdi,r12
 228:	call   r8
 22b:	mov    rdi,r12
 22e:	jmp    239 <botlish_fn_1+0x189>
 233:	mov    rax,r13
 236:	mov    rdi,r12
 239:	mov    rdi,r12
 23c:	mov    QWORD PTR [rdi],rbx
 23f:	mov    rbx,QWORD PTR [rsp]
 243:	mov    r12,QWORD PTR [rsp+0x8]
 248:	mov    r13,QWORD PTR [rsp+0x10]
 24d:	mov    r14,QWORD PTR [rsp+0x18]
 252:	add    rsp,0x20
 256:	mov    rsp,rbp
 259:	pop    rbp
 25a:	ret
 25b:	mov    r12,rdi
 25e:	mov    rax,QWORD PTR [rip+0x0]        # 265 <botlish_fn_1+0x1b5>
			261: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 265:	call   rax
 267:	xor    rax,rax
 26a:	mov    rbx,QWORD PTR [rsp]
 26e:	mov    r12,QWORD PTR [rsp+0x8]
 273:	mov    r13,QWORD PTR [rsp+0x10]
 278:	mov    r14,QWORD PTR [rsp+0x18]
 27d:	add    rsp,0x20
 281:	mov    rsp,rbp
 284:	pop    rbp
 285:	ret
 286:	add    BYTE PTR [rax],al
 288:	(bad)
 289:	add    BYTE PTR [rax],al
 28b:	add    BYTE PTR [rax],al
 28d:	add    BYTE PTR [rax],al
	...

0000000000000290 <botlish_entry_1: fib<int>>:
 290:	push   rbp
 291:	mov    rbp,rsp
 294:	mov    rsi,QWORD PTR [rdx]
 297:	call   29c <botlish_entry_1+0xc>
			298: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 29c:	mov    rsp,rbp
 29f:	pop    rbp
 2a0:	ret

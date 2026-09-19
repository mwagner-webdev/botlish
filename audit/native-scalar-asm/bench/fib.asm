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
   8:	mov    QWORD PTR [rsp],r12
   c:	mov    QWORD PTR [rsp+0x8],r13
  11:	mov    r12,QWORD PTR [rdi]
  14:	mov    rax,QWORD PTR [rdi+0x8]
  18:	lea    rcx,[r12+0x8]
  1d:	cmp    rcx,rax
  20:	ja     82 <botlish_fn_0+0x82>
  26:	lea    rax,[r12+0x8]
  2b:	mov    QWORD PTR [rdi],rax
  2e:	mov    r13,rdi
  31:	mov    esi,0x2d
  36:	mov    QWORD PTR [r12],0x2d
  3e:	mov    rdi,r13
  41:	call   46 <botlish_fn_0+0x46>
			42: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  46:	test   rax,rax
  49:	jne    6a <botlish_fn_0+0x6a>
  4f:	mov    rdi,r13
  52:	mov    QWORD PTR [rdi],r12
  55:	xor    rax,rax
  58:	mov    r12,QWORD PTR [rsp]
  5c:	mov    r13,QWORD PTR [rsp+0x8]
  61:	add    rsp,0x10
  65:	mov    rsp,rbp
  68:	pop    rbp
  69:	ret
  6a:	mov    rdi,r13
  6d:	mov    QWORD PTR [rdi],r12
  70:	mov    r12,QWORD PTR [rsp]
  74:	mov    r13,QWORD PTR [rsp+0x8]
  79:	add    rsp,0x10
  7d:	mov    rsp,rbp
  80:	pop    rbp
  81:	ret
  82:	call   87 <botlish_fn_0+0x87>
			83: R_X86_64_PLT32	rt_stack_overflow-0x4
  87:	xor    rax,rax
  8a:	mov    r12,QWORD PTR [rsp]
  8e:	mov    r13,QWORD PTR [rsp+0x8]
  93:	add    rsp,0x10
  97:	mov    rsp,rbp
  9a:	pop    rbp
  9b:	ret

000000000000009c <botlish_entry_0: <program entry>>:
  9c:	push   rbp
  9d:	mov    rbp,rsp
  a0:	call   a5 <botlish_entry_0+0x9>
			a1: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  a5:	mov    rsp,rbp
  a8:	pop    rbp
  a9:	ret
  aa:	add    BYTE PTR [rax],al
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
  d9:	ja     24c <botlish_fn_1+0x19c>
  df:	lea    rax,[rbx+0x10]
  e3:	mov    QWORD PTR [rdi],rax
  e6:	mov    r12,rdi
  e9:	mov    QWORD PTR [rbx+0x8],0x0
  f1:	test   rsi,0x1
  f8:	mov    r13,rsi
  fb:	jne    126 <botlish_fn_1+0x76>
 101:	mov    edx,0x5
 106:	mov    rsi,r13
 109:	mov    rdi,r12
 10c:	call   111 <botlish_fn_1+0x61>
			10d: R_X86_64_PLT32	rt_int_cmp-0x4
 111:	mov    ecx,0x2
 116:	test   rax,rax
 119:	cmovl  rcx,QWORD PTR [rip+0x157]        # 278 <botlish_fn_1+0x1c8>
 121:	jmp    13a <botlish_fn_1+0x8a>
 126:	mov    ecx,0x2
 12b:	mov    rsi,r13
 12e:	cmp    rsi,0x5
 132:	cmovl  rcx,QWORD PTR [rip+0x13e]        # 278 <botlish_fn_1+0x1c8>
 13a:	cmp    rcx,0x6
 13e:	je     224 <botlish_fn_1+0x174>
 144:	mov    rsi,r13
 147:	sar    rsi,1
 14a:	mov    r13,rsi
 14d:	sub    rsi,0x1
 151:	shl    rsi,1
 154:	or     rsi,0x1
 158:	mov    QWORD PTR [rbx],rsi
 15b:	mov    rdi,r12
 15e:	call   163 <botlish_fn_1+0xb3>
			15f: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 163:	test   rax,rax
 166:	jne    174 <botlish_fn_1+0xc4>
 16c:	mov    rdi,r12
 16f:	jmp    1a9 <botlish_fn_1+0xf9>
 174:	mov    QWORD PTR [rbx],rax
 177:	mov    rsi,r13
 17a:	mov    r14,rax
 17d:	sub    rsi,0x2
 181:	mov    r13,rsi
 184:	shl    rsi,1
 187:	mov    r13,rsi
 18a:	or     rsi,0x1
 18e:	mov    r13,rsi
 191:	mov    QWORD PTR [rbx+0x8],rsi
 195:	mov    rdi,r12
 198:	call   19d <botlish_fn_1+0xed>
			199: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 19d:	test   rax,rax
 1a0:	jne    1ce <botlish_fn_1+0x11e>
 1a6:	mov    rdi,r12
 1a9:	mov    rdi,r12
 1ac:	mov    QWORD PTR [rdi],rbx
 1af:	xor    rax,rax
 1b2:	mov    rbx,QWORD PTR [rsp]
 1b6:	mov    r12,QWORD PTR [rsp+0x8]
 1bb:	mov    r13,QWORD PTR [rsp+0x10]
 1c0:	mov    r14,QWORD PTR [rsp+0x18]
 1c5:	add    rsp,0x20
 1c9:	mov    rsp,rbp
 1cc:	pop    rbp
 1cd:	ret
 1ce:	mov    QWORD PTR [rbx+0x8],rax
 1d2:	mov    rcx,r14
 1d5:	mov    rdx,rcx
 1d8:	and    rdx,rax
 1db:	test   rdx,0x1
 1e2:	jne    1f3 <botlish_fn_1+0x143>
 1e8:	mov    rdx,rax
 1eb:	mov    rsi,rcx
 1ee:	jmp    214 <botlish_fn_1+0x164>
 1f3:	lea    rdx,[rax-0x1]
 1f7:	mov    rsi,rax
 1fa:	mov    rax,rcx
 1fd:	add    rax,rdx
 200:	mov    r14,rcx
 203:	seto   cl
 206:	test   cl,cl
 208:	je     21c <botlish_fn_1+0x16c>
 20e:	mov    rdx,rsi
 211:	mov    rsi,r14
 214:	mov    rdi,r12
 217:	call   21c <botlish_fn_1+0x16c>
			218: R_X86_64_PLT32	rt_int_add-0x4
 21c:	mov    rdi,r12
 21f:	jmp    22a <botlish_fn_1+0x17a>
 224:	mov    rax,r13
 227:	mov    rdi,r12
 22a:	mov    rdi,r12
 22d:	mov    QWORD PTR [rdi],rbx
 230:	mov    rbx,QWORD PTR [rsp]
 234:	mov    r12,QWORD PTR [rsp+0x8]
 239:	mov    r13,QWORD PTR [rsp+0x10]
 23e:	mov    r14,QWORD PTR [rsp+0x18]
 243:	add    rsp,0x20
 247:	mov    rsp,rbp
 24a:	pop    rbp
 24b:	ret
 24c:	mov    r12,rdi
 24f:	call   254 <botlish_fn_1+0x1a4>
			250: R_X86_64_PLT32	rt_stack_overflow-0x4
 254:	xor    rax,rax
 257:	mov    rbx,QWORD PTR [rsp]
 25b:	mov    r12,QWORD PTR [rsp+0x8]
 260:	mov    r13,QWORD PTR [rsp+0x10]
 265:	mov    r14,QWORD PTR [rsp+0x18]
 26a:	add    rsp,0x20
 26e:	mov    rsp,rbp
 271:	pop    rbp
 272:	ret
 273:	add    BYTE PTR [rax],al
 275:	add    BYTE PTR [rax],al
 277:	add    BYTE PTR [rsi],al
 279:	add    BYTE PTR [rax],al
 27b:	add    BYTE PTR [rax],al
 27d:	add    BYTE PTR [rax],al
	...

0000000000000280 <botlish_entry_1: fib<int>>:
 280:	push   rbp
 281:	mov    rbp,rsp
 284:	mov    rsi,QWORD PTR [rdx]
 287:	call   28c <botlish_entry_1+0xc>
			288: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 28c:	mov    rsp,rbp
 28f:	pop    rbp
 290:	ret

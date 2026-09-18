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
  31:	mov    esi,0x39
  36:	mov    QWORD PTR [r12],0x39
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
  d9:	ja     253 <botlish_fn_1+0x1a3>
  df:	lea    rax,[rbx+0x10]
  e3:	mov    QWORD PTR [rdi],rax
  e6:	mov    r12,rdi
  e9:	mov    QWORD PTR [rbx],0x0
  f0:	mov    QWORD PTR [rbx+0x8],0x0
  f8:	test   rsi,0x1
  ff:	mov    r13,rsi
 102:	jne    12d <botlish_fn_1+0x7d>
 108:	mov    edx,0x5
 10d:	mov    rsi,r13
 110:	mov    rdi,r12
 113:	call   118 <botlish_fn_1+0x68>
			114: R_X86_64_PLT32	rt_int_cmp-0x4
 118:	mov    ecx,0x2
 11d:	test   rax,rax
 120:	cmovl  rcx,QWORD PTR [rip+0x158]        # 280 <botlish_fn_1+0x1d0>
 128:	jmp    141 <botlish_fn_1+0x91>
 12d:	mov    ecx,0x2
 132:	mov    rsi,r13
 135:	cmp    rsi,0x5
 139:	cmovl  rcx,QWORD PTR [rip+0x13f]        # 280 <botlish_fn_1+0x1d0>
 141:	cmp    rcx,0x6
 145:	je     22b <botlish_fn_1+0x17b>
 14b:	mov    rsi,r13
 14e:	sar    rsi,1
 151:	mov    r13,rsi
 154:	sub    rsi,0x1
 158:	shl    rsi,1
 15b:	or     rsi,0x1
 15f:	mov    QWORD PTR [rbx],rsi
 162:	mov    rdi,r12
 165:	call   16a <botlish_fn_1+0xba>
			166: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 16a:	test   rax,rax
 16d:	jne    17b <botlish_fn_1+0xcb>
 173:	mov    rdi,r12
 176:	jmp    1b0 <botlish_fn_1+0x100>
 17b:	mov    QWORD PTR [rbx],rax
 17e:	mov    rsi,r13
 181:	mov    r14,rax
 184:	sub    rsi,0x2
 188:	mov    r13,rsi
 18b:	shl    rsi,1
 18e:	mov    r13,rsi
 191:	or     rsi,0x1
 195:	mov    r13,rsi
 198:	mov    QWORD PTR [rbx+0x8],rsi
 19c:	mov    rdi,r12
 19f:	call   1a4 <botlish_fn_1+0xf4>
			1a0: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 1a4:	test   rax,rax
 1a7:	jne    1d5 <botlish_fn_1+0x125>
 1ad:	mov    rdi,r12
 1b0:	mov    rdi,r12
 1b3:	mov    QWORD PTR [rdi],rbx
 1b6:	xor    rax,rax
 1b9:	mov    rbx,QWORD PTR [rsp]
 1bd:	mov    r12,QWORD PTR [rsp+0x8]
 1c2:	mov    r13,QWORD PTR [rsp+0x10]
 1c7:	mov    r14,QWORD PTR [rsp+0x18]
 1cc:	add    rsp,0x20
 1d0:	mov    rsp,rbp
 1d3:	pop    rbp
 1d4:	ret
 1d5:	mov    QWORD PTR [rbx+0x8],rax
 1d9:	mov    rcx,r14
 1dc:	mov    rdx,rcx
 1df:	and    rdx,rax
 1e2:	test   rdx,0x1
 1e9:	jne    1fa <botlish_fn_1+0x14a>
 1ef:	mov    rdx,rax
 1f2:	mov    rsi,rcx
 1f5:	jmp    21b <botlish_fn_1+0x16b>
 1fa:	lea    rdx,[rax-0x1]
 1fe:	mov    rsi,rax
 201:	mov    rax,rcx
 204:	add    rax,rdx
 207:	mov    r14,rcx
 20a:	seto   cl
 20d:	test   cl,cl
 20f:	je     223 <botlish_fn_1+0x173>
 215:	mov    rdx,rsi
 218:	mov    rsi,r14
 21b:	mov    rdi,r12
 21e:	call   223 <botlish_fn_1+0x173>
			21f: R_X86_64_PLT32	rt_int_add-0x4
 223:	mov    rdi,r12
 226:	jmp    231 <botlish_fn_1+0x181>
 22b:	mov    rax,r13
 22e:	mov    rdi,r12
 231:	mov    rdi,r12
 234:	mov    QWORD PTR [rdi],rbx
 237:	mov    rbx,QWORD PTR [rsp]
 23b:	mov    r12,QWORD PTR [rsp+0x8]
 240:	mov    r13,QWORD PTR [rsp+0x10]
 245:	mov    r14,QWORD PTR [rsp+0x18]
 24a:	add    rsp,0x20
 24e:	mov    rsp,rbp
 251:	pop    rbp
 252:	ret
 253:	mov    r12,rdi
 256:	call   25b <botlish_fn_1+0x1ab>
			257: R_X86_64_PLT32	rt_stack_overflow-0x4
 25b:	xor    rax,rax
 25e:	mov    rbx,QWORD PTR [rsp]
 262:	mov    r12,QWORD PTR [rsp+0x8]
 267:	mov    r13,QWORD PTR [rsp+0x10]
 26c:	mov    r14,QWORD PTR [rsp+0x18]
 271:	add    rsp,0x20
 275:	mov    rsp,rbp
 278:	pop    rbp
 279:	ret
 27a:	add    BYTE PTR [rax],al
 27c:	add    BYTE PTR [rax],al
 27e:	add    BYTE PTR [rax],al
 280:	(bad)
 281:	add    BYTE PTR [rax],al
 283:	add    BYTE PTR [rax],al
 285:	add    BYTE PTR [rax],al
	...

0000000000000288 <botlish_entry_1: fib<int>>:
 288:	push   rbp
 289:	mov    rbp,rsp
 28c:	mov    rsi,QWORD PTR [rdx]
 28f:	call   294 <botlish_entry_1+0xc>
			290: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 294:	mov    rsp,rbp
 297:	pop    rbp
 298:	ret

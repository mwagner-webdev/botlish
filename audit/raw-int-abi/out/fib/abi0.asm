
abi0.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program><generic>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	mov    esi,0x2d
   9:	call   e <botlish_fn_0+0xe>
			a: R_X86_64_PLT32	botlish_fn_1-0x4
   e:	mov    rsp,rbp
  11:	pop    rbp
  12:	ret

0000000000000013 <botlish_entry_0: <program><generic>>:
  13:	push   rbp
  14:	mov    rbp,rsp
  17:	call   1c <botlish_entry_0+0x9>
			18: R_X86_64_PLT32	botlish_fn_0-0x4
  1c:	mov    rsp,rbp
  1f:	pop    rbp
  20:	ret

0000000000000021 <botlish_fn_1: fib<int>>:
  21:	push   rbp
  22:	mov    rbp,rsp
  25:	sub    rsp,0x10
  29:	mov    QWORD PTR [rsp],rbx
  2d:	mov    QWORD PTR [rsp+0x8],r12
  32:	mov    rbx,rdi
  35:	mov    r11,rsi
  38:	sar    r11,1
  3b:	cmp    r11,0x2
  3f:	jl     8f <botlish_fn_1+0x6e>
  45:	mov    rsi,r11
  48:	sub    rsi,0x1
  4c:	mov    r12,r11
  4f:	shl    rsi,1
  52:	or     rsi,0x1
  56:	mov    rdi,rbx
  59:	call   5e <botlish_fn_1+0x3d>
			5a: R_X86_64_PLT32	botlish_fn_1-0x4
  5e:	mov    rsi,r12
  61:	mov    r12,rax
  64:	sub    rsi,0x2
  68:	shl    rsi,1
  6b:	or     rsi,0x1
  6f:	mov    rdi,rbx
  72:	call   77 <botlish_fn_1+0x56>
			73: R_X86_64_PLT32	botlish_fn_1-0x4
  77:	mov    rcx,r12
  7a:	sar    rcx,1
  7d:	sar    rax,1
  80:	add    rax,rcx
  83:	shl    rax,1
  86:	or     rax,0x1
  8a:	jmp    92 <botlish_fn_1+0x71>
  8f:	mov    rax,rsi
  92:	mov    rbx,QWORD PTR [rsp]
  96:	mov    r12,QWORD PTR [rsp+0x8]
  9b:	add    rsp,0x10
  9f:	mov    rsp,rbp
  a2:	pop    rbp
  a3:	ret

00000000000000a4 <botlish_entry_1: fib<int>>:
  a4:	push   rbp
  a5:	mov    rbp,rsp
  a8:	mov    rsi,QWORD PTR [rdx]
  ab:	call   b0 <botlish_entry_1+0xc>
			ac: R_X86_64_PLT32	botlish_fn_1-0x4
  b0:	mov    rsp,rbp
  b3:	pop    rbp
  b4:	ret


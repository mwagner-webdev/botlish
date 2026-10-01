
opt0.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program><generic>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    esi,0x2d
   d:	mov    QWORD PTR [rsp],0x2d
  15:	call   1a <botlish_fn_0+0x1a>
			16: R_X86_64_PLT32	botlish_fn_1-0x4
  1a:	add    rsp,0x10
  1e:	mov    rsp,rbp
  21:	pop    rbp
  22:	ret

0000000000000023 <botlish_entry_0: <program><generic>>:
  23:	push   rbp
  24:	mov    rbp,rsp
  27:	call   2c <botlish_entry_0+0x9>
			28: R_X86_64_PLT32	botlish_fn_0-0x4
  2c:	mov    rsp,rbp
  2f:	pop    rbp
  30:	ret

0000000000000031 <botlish_fn_1: fib<int>>:
  31:	push   rbp
  32:	mov    rbp,rsp
  35:	sub    rsp,0x30
  39:	mov    QWORD PTR [rsp+0x10],rbx
  3e:	mov    QWORD PTR [rsp+0x18],r12
  43:	mov    QWORD PTR [rsp+0x20],r13
  48:	mov    rbx,rdi
  4b:	mov    QWORD PTR [rsp+0x8],0x0
  54:	mov    rax,rsi
  57:	sar    rax,1
  5a:	cmp    rax,0x2
  5e:	jl     f7 <botlish_fn_1+0xc6>
  64:	mov    rsi,rax
  67:	sub    rsi,0x1
  6b:	mov    r13,rax
  6e:	shl    rsi,1
  71:	or     rsi,0x1
  75:	mov    QWORD PTR [rsp],rsi
  79:	mov    rdi,rbx
  7c:	call   81 <botlish_fn_1+0x50>
			7d: R_X86_64_PLT32	botlish_fn_1-0x4
  81:	mov    r12,rax
  84:	mov    QWORD PTR [rsp],rax
  88:	mov    rsi,r13
  8b:	sub    rsi,0x2
  8f:	shl    rsi,1
  92:	or     rsi,0x1
  96:	mov    QWORD PTR [rsp+0x8],rsi
  9b:	mov    rdi,rbx
  9e:	call   a3 <botlish_fn_1+0x72>
			9f: R_X86_64_PLT32	botlish_fn_1-0x4
  a3:	mov    QWORD PTR [rsp+0x8],rax
  a8:	mov    rcx,r12
  ab:	and    rcx,rax
  ae:	test   rcx,0x1
  b5:	jne    c9 <botlish_fn_1+0x98>
  bb:	mov    rdx,rax
  be:	mov    rsi,r12
  c1:	mov    rdi,rbx
  c4:	jmp    ed <botlish_fn_1+0xbc>
  c9:	lea    rcx,[rax-0x1]
  cd:	mov    rdx,r12
  d0:	mov    rsi,rax
  d3:	mov    rax,rdx
  d6:	add    rax,rcx
  d9:	seto   cl
  dc:	test   cl,cl
  de:	je     fa <botlish_fn_1+0xc9>
  e4:	mov    rdi,rbx
  e7:	mov    rdx,rsi
  ea:	mov    rsi,r12
  ed:	call   f2 <botlish_fn_1+0xc1>
			ee: R_X86_64_PLT32	rt_int_add-0x4
  f2:	jmp    fa <botlish_fn_1+0xc9>
  f7:	mov    rax,rsi
  fa:	mov    rbx,QWORD PTR [rsp+0x10]
  ff:	mov    r12,QWORD PTR [rsp+0x18]
 104:	mov    r13,QWORD PTR [rsp+0x20]
 109:	add    rsp,0x30
 10d:	mov    rsp,rbp
 110:	pop    rbp
 111:	ret

0000000000000112 <botlish_entry_1: fib<int>>:
 112:	push   rbp
 113:	mov    rbp,rsp
 116:	mov    rsi,QWORD PTR [rdx]
 119:	call   11e <botlish_entry_1+0xc>
			11a: R_X86_64_PLT32	botlish_fn_1-0x4
 11e:	mov    rsp,rbp
 121:	pop    rbp
 122:	ret


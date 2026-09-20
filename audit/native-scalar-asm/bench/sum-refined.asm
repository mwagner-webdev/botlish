; source:  bench/sum-refined.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 344  (per function: 84 162 98)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> sum<int, int>
;   botlish_fn_2 / botlish_entry_2 -> step<int>


sum-refined.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    esi,0x321
   d:	mov    QWORD PTR [rsp],0x321
  15:	mov    edx,0x1
  1a:	mov    QWORD PTR [rsp+0x8],0x1
  23:	call   28 <botlish_fn_0+0x28>
			24: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
  28:	test   rax,rax
  2b:	jne    3d <botlish_fn_0+0x3d>
  31:	xor    rax,rax
  34:	add    rsp,0x10
  38:	mov    rsp,rbp
  3b:	pop    rbp
  3c:	ret
  3d:	add    rsp,0x10
  41:	mov    rsp,rbp
  44:	pop    rbp
  45:	ret

0000000000000046 <botlish_entry_0: <program entry>>:
  46:	push   rbp
  47:	mov    rbp,rsp
  4a:	call   4f <botlish_entry_0+0x9>
			4b: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  4f:	mov    rsp,rbp
  52:	pop    rbp
  53:	ret

0000000000000054 <botlish_fn_1: sum<int, int>>:
  54:	push   rbp
  55:	mov    rbp,rsp
  58:	sub    rsp,0x20
  5c:	mov    QWORD PTR [rsp+0x10],rbx
  61:	mov    QWORD PTR [rsp+0x18],r15
  66:	mov    r15,rdi
  69:	mov    QWORD PTR [rsp],rdx
  6d:	sar    rsi,1
  70:	mov    rax,rsi
  73:	mov    rsi,rdx
  76:	mov    rbx,rax
  79:	test   rbx,rbx
  7c:	je     cb <botlish_fn_1+0x77>
  82:	mov    rdx,rbx
  85:	shl    rdx,1
  88:	or     rdx,0x1
  8c:	mov    QWORD PTR [rsp+0x8],rdx
  91:	mov    rdi,r15
  94:	call   99 <botlish_fn_1+0x45>
			95: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
  99:	test   rax,rax
  9c:	jne    b8 <botlish_fn_1+0x64>
  a2:	xor    rax,rax
  a5:	mov    rbx,QWORD PTR [rsp+0x10]
  aa:	mov    r15,QWORD PTR [rsp+0x18]
  af:	add    rsp,0x20
  b3:	mov    rsp,rbp
  b6:	pop    rbp
  b7:	ret
  b8:	mov    QWORD PTR [rsp],rax
  bc:	sub    rbx,0x1
  c0:	mov    rsi,rax
  c3:	mov    rax,rbx
  c6:	jmp    76 <botlish_fn_1+0x22>
  cb:	mov    rax,rsi
  ce:	mov    rbx,QWORD PTR [rsp+0x10]
  d3:	mov    r15,QWORD PTR [rsp+0x18]
  d8:	add    rsp,0x20
  dc:	mov    rsp,rbp
  df:	pop    rbp
  e0:	ret

00000000000000e1 <botlish_entry_1: sum<int, int>>:
  e1:	push   rbp
  e2:	mov    rbp,rsp
  e5:	mov    rsi,QWORD PTR [rdx]
  e8:	mov    rdx,QWORD PTR [rdx+0x8]
  ec:	call   f1 <botlish_entry_1+0x10>
			ed: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
  f1:	mov    rsp,rbp
  f4:	pop    rbp
  f5:	ret

00000000000000f6 <botlish_fn_2: step<int>>:
  f6:	push   rbp
  f7:	mov    rbp,rsp
  fa:	sub    rsp,0x10
  fe:	mov    QWORD PTR [rsp],rsi
 102:	mov    QWORD PTR [rsp+0x8],rdx
 107:	mov    rax,rsi
 10a:	and    rax,rdx
 10d:	test   rax,0x1
 113:	je     12e <botlish_fn_2+0x38>
 119:	lea    rcx,[rdx-0x1]
 11d:	mov    rax,rsi
 120:	add    rax,rcx
 123:	seto   cl
 126:	test   cl,cl
 128:	je     133 <botlish_fn_2+0x3d>
 12e:	call   133 <botlish_fn_2+0x3d>
			12f: R_X86_64_PLT32	rt_int_add-0x4
 133:	add    rsp,0x10
 137:	mov    rsp,rbp
 13a:	pop    rbp
 13b:	ret

000000000000013c <botlish_entry_2: step<int>>:
 13c:	push   rbp
 13d:	mov    rbp,rsp
 140:	mov    rsi,QWORD PTR [rdx]
 143:	mov    rdx,QWORD PTR [rdx+0x8]
 147:	call   14c <botlish_entry_2+0x10>
			148: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
 14c:	mov    rsp,rbp
 14f:	pop    rbp
 150:	ret

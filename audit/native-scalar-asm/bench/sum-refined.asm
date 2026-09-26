; source:  bench/sum-refined.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 286  (per function: 63 125 98)
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
  28:	add    rsp,0x10
  2c:	mov    rsp,rbp
  2f:	pop    rbp
  30:	ret

0000000000000031 <botlish_entry_0: <program entry>>:
  31:	push   rbp
  32:	mov    rbp,rsp
  35:	call   3a <botlish_entry_0+0x9>
			36: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  3a:	mov    rsp,rbp
  3d:	pop    rbp
  3e:	ret

000000000000003f <botlish_fn_1: sum<int, int>>:
  3f:	push   rbp
  40:	mov    rbp,rsp
  43:	sub    rsp,0x20
  47:	mov    QWORD PTR [rsp+0x10],r13
  4c:	mov    QWORD PTR [rsp+0x18],r14
  51:	mov    r13,rdi
  54:	mov    QWORD PTR [rsp],rdx
  58:	sar    rsi,1
  5b:	mov    r14,rsi
  5e:	mov    rsi,rdx
  61:	test   r14,r14
  64:	je     91 <botlish_fn_1+0x52>
  6a:	mov    rdx,r14
  6d:	shl    rdx,1
  70:	or     rdx,0x1
  74:	mov    QWORD PTR [rsp+0x8],rdx
  79:	mov    rdi,r13
  7c:	call   81 <botlish_fn_1+0x42>
			7d: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
  81:	mov    QWORD PTR [rsp],rax
  85:	sub    r14,0x1
  89:	mov    rsi,rax
  8c:	jmp    61 <botlish_fn_1+0x22>
  91:	mov    rax,rsi
  94:	mov    r13,QWORD PTR [rsp+0x10]
  99:	mov    r14,QWORD PTR [rsp+0x18]
  9e:	add    rsp,0x20
  a2:	mov    rsp,rbp
  a5:	pop    rbp
  a6:	ret

00000000000000a7 <botlish_entry_1: sum<int, int>>:
  a7:	push   rbp
  a8:	mov    rbp,rsp
  ab:	mov    rsi,QWORD PTR [rdx]
  ae:	mov    rdx,QWORD PTR [rdx+0x8]
  b2:	call   b7 <botlish_entry_1+0x10>
			b3: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
  b7:	mov    rsp,rbp
  ba:	pop    rbp
  bb:	ret

00000000000000bc <botlish_fn_2: step<int>>:
  bc:	push   rbp
  bd:	mov    rbp,rsp
  c0:	sub    rsp,0x10
  c4:	mov    QWORD PTR [rsp],rsi
  c8:	mov    QWORD PTR [rsp+0x8],rdx
  cd:	mov    rax,rsi
  d0:	and    rax,rdx
  d3:	test   rax,0x1
  d9:	je     f4 <botlish_fn_2+0x38>
  df:	lea    rcx,[rdx-0x1]
  e3:	mov    rax,rsi
  e6:	add    rax,rcx
  e9:	seto   cl
  ec:	test   cl,cl
  ee:	je     f9 <botlish_fn_2+0x3d>
  f4:	call   f9 <botlish_fn_2+0x3d>
			f5: R_X86_64_PLT32	rt_int_add-0x4
  f9:	add    rsp,0x10
  fd:	mov    rsp,rbp
 100:	pop    rbp
 101:	ret

0000000000000102 <botlish_entry_2: step<int>>:
 102:	push   rbp
 103:	mov    rbp,rsp
 106:	mov    rsi,QWORD PTR [rdx]
 109:	mov    rdx,QWORD PTR [rdx+0x8]
 10d:	call   112 <botlish_entry_2+0x10>
			10e: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
 112:	mov    rsp,rbp
 115:	pop    rbp
 116:	ret

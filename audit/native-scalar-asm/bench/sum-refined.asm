; source:  bench/sum-refined.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 292  (per function: 63 131 98)
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
  4c:	mov    QWORD PTR [rsp+0x18],r15
  51:	mov    r13,rdi
  54:	mov    QWORD PTR [rsp],rdx
  58:	sar    rsi,1
  5b:	mov    r11,rsi
  5e:	mov    rsi,rdx
  61:	mov    r15,r11
  64:	test   r15,r15
  67:	je     97 <botlish_fn_1+0x58>
  6d:	mov    rdx,r15
  70:	shl    rdx,1
  73:	or     rdx,0x1
  77:	mov    QWORD PTR [rsp+0x8],rdx
  7c:	mov    rdi,r13
  7f:	call   84 <botlish_fn_1+0x45>
			80: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
  84:	mov    QWORD PTR [rsp],rax
  88:	sub    r15,0x1
  8c:	mov    rsi,rax
  8f:	mov    r11,r15
  92:	jmp    61 <botlish_fn_1+0x22>
  97:	mov    rax,rsi
  9a:	mov    r13,QWORD PTR [rsp+0x10]
  9f:	mov    r15,QWORD PTR [rsp+0x18]
  a4:	add    rsp,0x20
  a8:	mov    rsp,rbp
  ab:	pop    rbp
  ac:	ret

00000000000000ad <botlish_entry_1: sum<int, int>>:
  ad:	push   rbp
  ae:	mov    rbp,rsp
  b1:	mov    rsi,QWORD PTR [rdx]
  b4:	mov    rdx,QWORD PTR [rdx+0x8]
  b8:	call   bd <botlish_entry_1+0x10>
			b9: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
  bd:	mov    rsp,rbp
  c0:	pop    rbp
  c1:	ret

00000000000000c2 <botlish_fn_2: step<int>>:
  c2:	push   rbp
  c3:	mov    rbp,rsp
  c6:	sub    rsp,0x10
  ca:	mov    QWORD PTR [rsp],rsi
  ce:	mov    QWORD PTR [rsp+0x8],rdx
  d3:	mov    rax,rsi
  d6:	and    rax,rdx
  d9:	test   rax,0x1
  df:	je     fa <botlish_fn_2+0x38>
  e5:	lea    rcx,[rdx-0x1]
  e9:	mov    rax,rsi
  ec:	add    rax,rcx
  ef:	seto   cl
  f2:	test   cl,cl
  f4:	je     ff <botlish_fn_2+0x3d>
  fa:	call   ff <botlish_fn_2+0x3d>
			fb: R_X86_64_PLT32	rt_int_add-0x4
  ff:	add    rsp,0x10
 103:	mov    rsp,rbp
 106:	pop    rbp
 107:	ret

0000000000000108 <botlish_entry_2: step<int>>:
 108:	push   rbp
 109:	mov    rbp,rsp
 10c:	mov    rsi,QWORD PTR [rdx]
 10f:	mov    rdx,QWORD PTR [rdx+0x8]
 113:	call   118 <botlish_entry_2+0x10>
			114: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
 118:	mov    rsp,rbp
 11b:	pop    rbp
 11c:	ret

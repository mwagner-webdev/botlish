; source:  bench/sum-refined.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 277  (per function: 54 125 98)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> refined_sum<int, int>
;   botlish_fn_2 / botlish_entry_2 -> step<int>


sum-refined.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    edx,0x1
   d:	mov    QWORD PTR [rsp],0x1
  15:	mov    esi,0x190
  1a:	call   1f <botlish_fn_0+0x1f>
			1b: R_X86_64_PLT32	botlish_fn_1-0x4 ; refined_sum<int, int>
  1f:	add    rsp,0x10
  23:	mov    rsp,rbp
  26:	pop    rbp
  27:	ret

0000000000000028 <botlish_entry_0: <program entry>>:
  28:	push   rbp
  29:	mov    rbp,rsp
  2c:	call   31 <botlish_entry_0+0x9>
			2d: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  31:	mov    rsp,rbp
  34:	pop    rbp
  35:	ret

0000000000000036 <botlish_fn_1: refined_sum<int, int>>:
  36:	push   rbp
  37:	mov    rbp,rsp
  3a:	sub    rsp,0x20
  3e:	mov    QWORD PTR [rsp+0x10],r12
  43:	mov    QWORD PTR [rsp+0x18],r13
  48:	mov    r13,rdi
  4b:	mov    QWORD PTR [rsp],rdx
  4f:	mov    r12,rsi
  52:	mov    rsi,rdx
  55:	test   r12,r12
  58:	je     85 <botlish_fn_1+0x4f>
  5e:	mov    rdx,r12
  61:	shl    rdx,1
  64:	or     rdx,0x1
  68:	mov    QWORD PTR [rsp+0x8],rdx
  6d:	mov    rdi,r13
  70:	call   75 <botlish_fn_1+0x3f>
			71: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
  75:	mov    QWORD PTR [rsp],rax
  79:	sub    r12,0x1
  7d:	mov    rsi,rax
  80:	jmp    55 <botlish_fn_1+0x1f>
  85:	mov    rax,rsi
  88:	mov    r12,QWORD PTR [rsp+0x10]
  8d:	mov    r13,QWORD PTR [rsp+0x18]
  92:	add    rsp,0x20
  96:	mov    rsp,rbp
  99:	pop    rbp
  9a:	ret

000000000000009b <botlish_entry_1: refined_sum<int, int>>:
  9b:	push   rbp
  9c:	mov    rbp,rsp
  9f:	mov    rsi,QWORD PTR [rdx]
  a2:	mov    rdx,QWORD PTR [rdx+0x8]
  a6:	sar    rsi,1
  a9:	call   ae <botlish_entry_1+0x13>
			aa: R_X86_64_PLT32	botlish_fn_1-0x4 ; refined_sum<int, int>
  ae:	mov    rsp,rbp
  b1:	pop    rbp
  b2:	ret

00000000000000b3 <botlish_fn_2: step<int>>:
  b3:	push   rbp
  b4:	mov    rbp,rsp
  b7:	sub    rsp,0x10
  bb:	mov    QWORD PTR [rsp],rsi
  bf:	mov    QWORD PTR [rsp+0x8],rdx
  c4:	mov    rax,rsi
  c7:	and    rax,rdx
  ca:	test   rax,0x1
  d0:	je     eb <botlish_fn_2+0x38>
  d6:	lea    rcx,[rdx-0x1]
  da:	mov    rax,rsi
  dd:	add    rax,rcx
  e0:	seto   cl
  e3:	test   cl,cl
  e5:	je     f0 <botlish_fn_2+0x3d>
  eb:	call   f0 <botlish_fn_2+0x3d>
			ec: R_X86_64_PLT32	rt_int_add-0x4
  f0:	add    rsp,0x10
  f4:	mov    rsp,rbp
  f7:	pop    rbp
  f8:	ret

00000000000000f9 <botlish_entry_2: step<int>>:
  f9:	push   rbp
  fa:	mov    rbp,rsp
  fd:	mov    rsi,QWORD PTR [rdx]
 100:	mov    rdx,QWORD PTR [rdx+0x8]
 104:	call   109 <botlish_entry_2+0x10>
			105: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<int>
 109:	mov    rsp,rbp
 10c:	pop    rbp
 10d:	ret

; source:  bench/loop-count.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 281  (per function: 54 41 186)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> work<int>
;   botlish_fn_2 / botlish_entry_2 -> drive<int, int>


loop-count.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    edx,0x1
   d:	mov    QWORD PTR [rsp],0x1
  15:	mov    esi,0x1f4
  1a:	call   1f <botlish_fn_0+0x1f>
			1b: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
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

0000000000000036 <botlish_fn_1: work<int>>:
  36:	push   rbp
  37:	mov    rbp,rsp
  3a:	mov    eax,0x7
  3f:	mov    rsp,rbp
  42:	pop    rbp
  43:	ret

0000000000000044 <botlish_entry_1: work<int>>:
  44:	push   rbp
  45:	mov    rbp,rsp
  48:	mov    rsi,QWORD PTR [rdx]
  4b:	sar    rsi,1
  4e:	call   53 <botlish_entry_1+0xf>
			4f: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  53:	shl    rax,1
  56:	or     rax,0x1
  5a:	mov    rsp,rbp
  5d:	pop    rbp
  5e:	ret

000000000000005f <botlish_fn_2: drive<int, int>>:
  5f:	push   rbp
  60:	mov    rbp,rsp
  63:	sub    rsp,0x30
  67:	mov    QWORD PTR [rsp+0x10],rbx
  6c:	mov    QWORD PTR [rsp+0x18],r12
  71:	mov    QWORD PTR [rsp+0x20],r15
  76:	mov    rbx,rdi
  79:	mov    QWORD PTR [rsp],rdx
  7d:	mov    r12,rdx
  80:	mov    r15,rsi
  83:	test   r15,r15
  86:	jle    df <botlish_fn_2+0x80>
  8c:	mov    rsi,r15
  8f:	mov    rdi,rbx
  92:	call   97 <botlish_fn_2+0x38>
			93: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  97:	mov    QWORD PTR [rsp+0x8],0xf
  a0:	mov    rsi,r12
  a3:	test   rsi,0x1
  aa:	je     c2 <botlish_fn_2+0x63>
  b0:	mov    rax,rsi
  b3:	add    rax,0xe
  b7:	seto   cl
  ba:	test   cl,cl
  bc:	je     cf <botlish_fn_2+0x70>
  c2:	mov    edx,0xf
  c7:	mov    rdi,rbx
  ca:	call   cf <botlish_fn_2+0x70>
			cb: R_X86_64_PLT32	rt_int_add-0x4
  cf:	mov    QWORD PTR [rsp],rax
  d3:	sub    r15,0x1
  d7:	mov    r12,rax
  da:	jmp    83 <botlish_fn_2+0x24>
  df:	mov    rax,r12
  e2:	mov    rbx,QWORD PTR [rsp+0x10]
  e7:	mov    r12,QWORD PTR [rsp+0x18]
  ec:	mov    r15,QWORD PTR [rsp+0x20]
  f1:	add    rsp,0x30
  f5:	mov    rsp,rbp
  f8:	pop    rbp
  f9:	ret

00000000000000fa <botlish_entry_2: drive<int, int>>:
  fa:	push   rbp
  fb:	mov    rbp,rsp
  fe:	mov    rsi,QWORD PTR [rdx]
 101:	mov    rdx,QWORD PTR [rdx+0x8]
 105:	sar    rsi,1
 108:	call   10d <botlish_entry_2+0x13>
			109: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 10d:	mov    rsp,rbp
 110:	pop    rbp
 111:	ret

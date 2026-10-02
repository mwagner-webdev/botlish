; source:  bench/loop-count.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 274  (per function: 54 34 186)
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
  3a:	mov    eax,0xf
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
  53:	mov    rsp,rbp
  56:	pop    rbp
  57:	ret

0000000000000058 <botlish_fn_2: drive<int, int>>:
  58:	push   rbp
  59:	mov    rbp,rsp
  5c:	sub    rsp,0x30
  60:	mov    QWORD PTR [rsp+0x10],rbx
  65:	mov    QWORD PTR [rsp+0x18],r12
  6a:	mov    QWORD PTR [rsp+0x20],r15
  6f:	mov    rbx,rdi
  72:	mov    QWORD PTR [rsp],rdx
  76:	mov    r12,rdx
  79:	mov    r15,rsi
  7c:	test   r15,r15
  7f:	jle    d8 <botlish_fn_2+0x80>
  85:	mov    rsi,r15
  88:	mov    rdi,rbx
  8b:	call   90 <botlish_fn_2+0x38>
			8c: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  90:	mov    QWORD PTR [rsp+0x8],0xf
  99:	mov    rsi,r12
  9c:	test   rsi,0x1
  a3:	je     bb <botlish_fn_2+0x63>
  a9:	mov    rax,rsi
  ac:	add    rax,0xe
  b0:	seto   cl
  b3:	test   cl,cl
  b5:	je     c8 <botlish_fn_2+0x70>
  bb:	mov    edx,0xf
  c0:	mov    rdi,rbx
  c3:	call   c8 <botlish_fn_2+0x70>
			c4: R_X86_64_PLT32	rt_int_add-0x4
  c8:	mov    QWORD PTR [rsp],rax
  cc:	sub    r15,0x1
  d0:	mov    r12,rax
  d3:	jmp    7c <botlish_fn_2+0x24>
  d8:	mov    rax,r12
  db:	mov    rbx,QWORD PTR [rsp+0x10]
  e0:	mov    r12,QWORD PTR [rsp+0x18]
  e5:	mov    r15,QWORD PTR [rsp+0x20]
  ea:	add    rsp,0x30
  ee:	mov    rsp,rbp
  f1:	pop    rbp
  f2:	ret

00000000000000f3 <botlish_entry_2: drive<int, int>>:
  f3:	push   rbp
  f4:	mov    rbp,rsp
  f7:	mov    rsi,QWORD PTR [rdx]
  fa:	mov    rdx,QWORD PTR [rdx+0x8]
  fe:	sar    rsi,1
 101:	call   106 <botlish_entry_2+0x13>
			102: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 106:	mov    rsp,rbp
 109:	pop    rbp
 10a:	ret

; source:  bench/loop-count.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 287  (per function: 63 31 193)
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
   8:	mov    esi,0x3e9
   d:	mov    QWORD PTR [rsp],0x3e9
  15:	mov    edx,0x1
  1a:	mov    QWORD PTR [rsp+0x8],0x1
  23:	call   28 <botlish_fn_0+0x28>
			24: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
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

000000000000003f <botlish_fn_1: work<int>>:
  3f:	push   rbp
  40:	mov    rbp,rsp
  43:	mov    eax,0xf
  48:	mov    rsp,rbp
  4b:	pop    rbp
  4c:	ret

000000000000004d <botlish_entry_1: work<int>>:
  4d:	push   rbp
  4e:	mov    rbp,rsp
  51:	mov    rsi,QWORD PTR [rdx]
  54:	call   59 <botlish_entry_1+0xc>
			55: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  59:	mov    rsp,rbp
  5c:	pop    rbp
  5d:	ret

000000000000005e <botlish_fn_2: drive<int, int>>:
  5e:	push   rbp
  5f:	mov    rbp,rsp
  62:	sub    rsp,0x30
  66:	mov    QWORD PTR [rsp+0x10],rbx
  6b:	mov    QWORD PTR [rsp+0x18],r12
  70:	mov    QWORD PTR [rsp+0x20],r13
  75:	mov    r12,rdi
  78:	mov    QWORD PTR [rsp],rdx
  7c:	sar    rsi,1
  7f:	mov    rbx,rsi
  82:	mov    r13,rdx
  85:	test   rbx,rbx
  88:	jle    e8 <botlish_fn_2+0x8a>
  8e:	mov    rsi,rbx
  91:	shl    rsi,1
  94:	or     rsi,0x1
  98:	mov    rdi,r12
  9b:	call   a0 <botlish_fn_2+0x42>
			9c: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  a0:	mov    QWORD PTR [rsp+0x8],0xf
  a9:	mov    rsi,r13
  ac:	test   rsi,0x1
  b3:	je     cb <botlish_fn_2+0x6d>
  b9:	mov    rax,rsi
  bc:	add    rax,0xe
  c0:	seto   cl
  c3:	test   cl,cl
  c5:	je     d8 <botlish_fn_2+0x7a>
  cb:	mov    edx,0xf
  d0:	mov    rdi,r12
  d3:	call   d8 <botlish_fn_2+0x7a>
			d4: R_X86_64_PLT32	rt_int_add-0x4
  d8:	mov    QWORD PTR [rsp],rax
  dc:	sub    rbx,0x1
  e0:	mov    r13,rax
  e3:	jmp    85 <botlish_fn_2+0x27>
  e8:	mov    rax,r13
  eb:	mov    rbx,QWORD PTR [rsp+0x10]
  f0:	mov    r12,QWORD PTR [rsp+0x18]
  f5:	mov    r13,QWORD PTR [rsp+0x20]
  fa:	add    rsp,0x30
  fe:	mov    rsp,rbp
 101:	pop    rbp
 102:	ret

0000000000000103 <botlish_entry_2: drive<int, int>>:
 103:	push   rbp
 104:	mov    rbp,rsp
 107:	mov    rsi,QWORD PTR [rdx]
 10a:	mov    rdx,QWORD PTR [rdx+0x8]
 10e:	call   113 <botlish_entry_2+0x10>
			10f: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 113:	mov    rsp,rbp
 116:	pop    rbp
 117:	ret

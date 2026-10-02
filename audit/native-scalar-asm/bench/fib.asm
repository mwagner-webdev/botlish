; source:  bench/fib.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 181  (per function: 40 141)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> fib<int>


fib.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	mov    esi,0x16
   9:	call   e <botlish_fn_0+0xe>
			a: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
   e:	shl    rax,1
  11:	or     rax,0x1
  15:	mov    rsp,rbp
  18:	pop    rbp
  19:	ret

000000000000001a <botlish_entry_0: <program entry>>:
  1a:	push   rbp
  1b:	mov    rbp,rsp
  1e:	call   23 <botlish_entry_0+0x9>
			1f: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  23:	mov    rsp,rbp
  26:	pop    rbp
  27:	ret

0000000000000028 <botlish_fn_1: fib<int>>:
  28:	push   rbp
  29:	mov    rbp,rsp
  2c:	sub    rsp,0x20
  30:	mov    QWORD PTR [rsp],r12
  34:	mov    QWORD PTR [rsp+0x8],r13
  39:	mov    QWORD PTR [rsp+0x10],r15
  3e:	mov    r13,rdi
  41:	cmp    rsi,0x2
  45:	mov    r12,rsi
  48:	jl     7d <botlish_fn_1+0x55>
  4e:	mov    rax,r12
  51:	mov    rsi,rax
  54:	sub    rsi,0x1
  58:	mov    rdi,r13
  5b:	call   60 <botlish_fn_1+0x38>
			5c: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  60:	mov    rsi,r12
  63:	mov    r15,rax
  66:	sub    rsi,0x2
  6a:	mov    rdi,r13
  6d:	call   72 <botlish_fn_1+0x4a>
			6e: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  72:	mov    rcx,r15
  75:	add    rax,rcx
  78:	jmp    83 <botlish_fn_1+0x5b>
  7d:	mov    rsi,r12
  80:	mov    rax,rsi
  83:	mov    r12,QWORD PTR [rsp]
  87:	mov    r13,QWORD PTR [rsp+0x8]
  8c:	mov    r15,QWORD PTR [rsp+0x10]
  91:	add    rsp,0x20
  95:	mov    rsp,rbp
  98:	pop    rbp
  99:	ret

000000000000009a <botlish_entry_1: fib<int>>:
  9a:	push   rbp
  9b:	mov    rbp,rsp
  9e:	mov    rsi,QWORD PTR [rdx]
  a1:	sar    rsi,1
  a4:	call   a9 <botlish_entry_1+0xf>
			a5: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  a9:	shl    rax,1
  ac:	or     rax,0x1
  b0:	mov    rsp,rbp
  b3:	pop    rbp
  b4:	ret

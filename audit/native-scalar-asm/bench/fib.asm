; source:  bench/fib.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 394  (per function: 49 345)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> fib<int>


fib.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    esi,0x2d
   d:	mov    QWORD PTR [rsp],0x2d
  15:	call   1a <botlish_fn_0+0x1a>
			16: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  1a:	add    rsp,0x10
  1e:	mov    rsp,rbp
  21:	pop    rbp
  22:	ret

0000000000000023 <botlish_entry_0: <program entry>>:
  23:	push   rbp
  24:	mov    rbp,rsp
  27:	call   2c <botlish_entry_0+0x9>
			28: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  2c:	mov    rsp,rbp
  2f:	pop    rbp
  30:	ret
  31:	add    BYTE PTR [rax],al
  33:	add    BYTE PTR [rax],al
  35:	add    BYTE PTR [rax],al
	...

0000000000000038 <botlish_fn_1: fib<int>>:
  38:	push   rbp
  39:	mov    rbp,rsp
  3c:	sub    rsp,0x30
  40:	mov    QWORD PTR [rsp+0x10],rbx
  45:	mov    QWORD PTR [rsp+0x18],r12
  4a:	mov    QWORD PTR [rsp+0x20],r13
  4f:	mov    rbx,rdi
  52:	mov    QWORD PTR [rsp+0x8],0x0
  5b:	test   rsi,0x1
  62:	mov    r12,rsi
  65:	jne    91 <botlish_fn_1+0x59>
  6b:	mov    edx,0x5
  70:	mov    rsi,r12
  73:	mov    rdi,rbx
  76:	call   7b <botlish_fn_1+0x43>
			77: R_X86_64_PLT32	rt_int_cmp-0x4
  7b:	mov    r9d,0x2
  81:	test   rax,rax
  84:	cmovl  r9,QWORD PTR [rip+0xe4]        # 170 <botlish_fn_1+0x138>
  8c:	jmp    a6 <botlish_fn_1+0x6e>
  91:	mov    r9d,0x2
  97:	mov    rsi,r12
  9a:	cmp    rsi,0x5
  9e:	cmovl  r9,QWORD PTR [rip+0xca]        # 170 <botlish_fn_1+0x138>
  a6:	cmp    r9,0x6
  aa:	je     14f <botlish_fn_1+0x117>
  b0:	mov    rsi,r12
  b3:	sar    rsi,1
  b6:	mov    r12,rsi
  b9:	sub    rsi,0x1
  bd:	shl    rsi,1
  c0:	or     rsi,0x1
  c4:	mov    QWORD PTR [rsp],rsi
  c8:	mov    rdi,rbx
  cb:	call   d0 <botlish_fn_1+0x98>
			cc: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  d0:	mov    r13,rax
  d3:	mov    QWORD PTR [rsp],rax
  d7:	mov    rsi,r12
  da:	sub    rsi,0x2
  de:	mov    r12,rsi
  e1:	shl    rsi,1
  e4:	mov    r12,rsi
  e7:	or     rsi,0x1
  eb:	mov    r12,rsi
  ee:	mov    QWORD PTR [rsp+0x8],rsi
  f3:	mov    rdi,rbx
  f6:	call   fb <botlish_fn_1+0xc3>
			f7: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
  fb:	mov    QWORD PTR [rsp+0x8],rax
 100:	mov    rcx,r13
 103:	and    rcx,rax
 106:	test   rcx,0x1
 10d:	jne    121 <botlish_fn_1+0xe9>
 113:	mov    rdx,rax
 116:	mov    rsi,r13
 119:	mov    rdi,rbx
 11c:	jmp    145 <botlish_fn_1+0x10d>
 121:	lea    rcx,[rax-0x1]
 125:	mov    rdx,r13
 128:	mov    rsi,rax
 12b:	mov    rax,rdx
 12e:	add    rax,rcx
 131:	seto   cl
 134:	test   cl,cl
 136:	je     152 <botlish_fn_1+0x11a>
 13c:	mov    rdi,rbx
 13f:	mov    rdx,rsi
 142:	mov    rsi,r13
 145:	call   14a <botlish_fn_1+0x112>
			146: R_X86_64_PLT32	rt_int_add-0x4
 14a:	jmp    152 <botlish_fn_1+0x11a>
 14f:	mov    rax,r12
 152:	mov    rbx,QWORD PTR [rsp+0x10]
 157:	mov    r12,QWORD PTR [rsp+0x18]
 15c:	mov    r13,QWORD PTR [rsp+0x20]
 161:	add    rsp,0x30
 165:	mov    rsp,rbp
 168:	pop    rbp
 169:	ret
 16a:	add    BYTE PTR [rax],al
 16c:	add    BYTE PTR [rax],al
 16e:	add    BYTE PTR [rax],al
 170:	(bad)
 171:	add    BYTE PTR [rax],al
 173:	add    BYTE PTR [rax],al
 175:	add    BYTE PTR [rax],al
	...

0000000000000178 <botlish_entry_1: fib<int>>:
 178:	push   rbp
 179:	mov    rbp,rsp
 17c:	mov    rsi,QWORD PTR [rdx]
 17f:	call   184 <botlish_entry_1+0xc>
			180: R_X86_64_PLT32	botlish_fn_1-0x4 ; fib<int>
 184:	mov    rsp,rbp
 187:	pop    rbp
 188:	ret

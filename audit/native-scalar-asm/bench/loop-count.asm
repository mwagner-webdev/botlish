; source:  bench/loop-count.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 503  (per function: 84 54 365)
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

0000000000000054 <botlish_fn_1: work<int>>:
  54:	push   rbp
  55:	mov    rbp,rsp
  58:	sar    rsi,1
  5b:	imul   rsi,rsi,0x3
  5f:	add    rsi,0x7
  66:	test   rsi,rsi
  69:	jl     66 <botlish_fn_1+0x12>
  6f:	mov    eax,0xf
  74:	mov    rsp,rbp
  77:	pop    rbp
  78:	ret

0000000000000079 <botlish_entry_1: work<int>>:
  79:	push   rbp
  7a:	mov    rbp,rsp
  7d:	mov    rsi,QWORD PTR [rdx]
  80:	call   85 <botlish_entry_1+0xc>
			81: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  85:	mov    rsp,rbp
  88:	pop    rbp
  89:	ret
  8a:	add    BYTE PTR [rax],al
  8c:	add    BYTE PTR [rax],al
	...

0000000000000090 <botlish_fn_2: drive<int, int>>:
  90:	push   rbp
  91:	mov    rbp,rsp
  94:	sub    rsp,0x40
  98:	mov    QWORD PTR [rsp+0x20],rbx
  9d:	mov    QWORD PTR [rsp+0x28],r12
  a2:	mov    QWORD PTR [rsp+0x30],r13
  a7:	mov    QWORD PTR [rsp+0x38],r14
  ac:	mov    r13,rdi
  af:	mov    QWORD PTR [rsp],rsi
  b3:	mov    QWORD PTR [rsp+0x8],rdx
  b8:	mov    rbx,rsi
  bb:	mov    r14,rdx
  be:	test   rbx,0x1
  c5:	jne    f0 <botlish_fn_2+0x60>
  cb:	mov    edx,0x1
  d0:	mov    rsi,rbx
  d3:	mov    rdi,r13
  d6:	call   db <botlish_fn_2+0x4b>
			d7: R_X86_64_PLT32	rt_int_cmp-0x4
  db:	mov    ecx,0x2
  e0:	test   rax,rax
  e3:	cmovle rcx,QWORD PTR [rip+0xe5]        # 1d0 <botlish_fn_2+0x140>
  eb:	jmp    101 <botlish_fn_2+0x71>
  f0:	mov    ecx,0x2
  f5:	cmp    rbx,0x1
  f9:	cmovle rcx,QWORD PTR [rip+0xcf]        # 1d0 <botlish_fn_2+0x140>
 101:	cmp    rcx,0x6
 105:	je     1ab <botlish_fn_2+0x11b>
 10b:	mov    r12,rbx
 10e:	sar    r12,1
 111:	sub    r12,0x1
 115:	shl    r12,1
 118:	or     r12,0x1
 11c:	mov    QWORD PTR [rsp+0x10],r12
 121:	mov    rsi,rbx
 124:	mov    rdi,r13
 127:	call   12c <botlish_fn_2+0x9c>
			128: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 12c:	test   rax,rax
 12f:	jne    155 <botlish_fn_2+0xc5>
 135:	xor    rax,rax
 138:	mov    rbx,QWORD PTR [rsp+0x20]
 13d:	mov    r12,QWORD PTR [rsp+0x28]
 142:	mov    r13,QWORD PTR [rsp+0x30]
 147:	mov    r14,QWORD PTR [rsp+0x38]
 14c:	add    rsp,0x40
 150:	mov    rsp,rbp
 153:	pop    rbp
 154:	ret
 155:	mov    QWORD PTR [rsp],0xf
 15d:	mov    rsi,r14
 160:	test   rsi,0x1
 167:	je     18a <botlish_fn_2+0xfa>
 16d:	mov    rax,rsi
 170:	add    rax,0xe
 174:	mov    rcx,rax
 177:	seto   al
 17a:	test   al,al
 17c:	jne    18a <botlish_fn_2+0xfa>
 182:	mov    rax,rcx
 185:	jmp    197 <botlish_fn_2+0x107>
 18a:	mov    edx,0xf
 18f:	mov    rdi,r13
 192:	call   197 <botlish_fn_2+0x107>
			193: R_X86_64_PLT32	rt_int_add-0x4
 197:	mov    QWORD PTR [rsp],r12
 19b:	mov    QWORD PTR [rsp+0x8],rax
 1a0:	mov    rbx,r12
 1a3:	mov    r14,rax
 1a6:	jmp    be <botlish_fn_2+0x2e>
 1ab:	mov    rax,r14
 1ae:	mov    rbx,QWORD PTR [rsp+0x20]
 1b3:	mov    r12,QWORD PTR [rsp+0x28]
 1b8:	mov    r13,QWORD PTR [rsp+0x30]
 1bd:	mov    r14,QWORD PTR [rsp+0x38]
 1c2:	add    rsp,0x40
 1c6:	mov    rsp,rbp
 1c9:	pop    rbp
 1ca:	ret
 1cb:	add    BYTE PTR [rax],al
 1cd:	add    BYTE PTR [rax],al
 1cf:	add    BYTE PTR [rsi],al
 1d1:	add    BYTE PTR [rax],al
 1d3:	add    BYTE PTR [rax],al
 1d5:	add    BYTE PTR [rax],al
	...

00000000000001d8 <botlish_entry_2: drive<int, int>>:
 1d8:	push   rbp
 1d9:	mov    rbp,rsp
 1dc:	mov    rsi,QWORD PTR [rdx]
 1df:	mov    rdx,QWORD PTR [rdx+0x8]
 1e3:	call   1e8 <botlish_entry_2+0x10>
			1e4: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 1e8:	mov    rsp,rbp
 1eb:	pop    rbp
 1ec:	ret

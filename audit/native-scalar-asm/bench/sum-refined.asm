; source:  bench/sum-refined.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 452  (per function: 84 162 206)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> sum<int, int>
;   botlish_fn_2 / botlish_entry_2 -> step<generic>


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
			95: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
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

00000000000000f6 <botlish_fn_2: step<generic>>:
  f6:	push   rbp
  f7:	mov    rbp,rsp
  fa:	sub    rsp,0x20
  fe:	mov    QWORD PTR [rsp+0x10],rbx
 103:	mov    QWORD PTR [rsp],rsi
 107:	mov    QWORD PTR [rsp+0x8],rdx
 10c:	mov    r8d,0x1
 112:	test   rsi,0x1
 119:	jne    139 <botlish_fn_2+0x43>
 11f:	xor    r8d,r8d
 122:	test   rsi,0x7
 129:	jne    139 <botlish_fn_2+0x43>
 12f:	movzx  rax,BYTE PTR [rsi]
 133:	cmp    al,0x1
 135:	sete   r8b
 139:	test   r8b,r8b
 13c:	jne    166 <botlish_fn_2+0x70>
 142:	mov    rax,QWORD PTR [rdi+0x10]
 146:	mov    rcx,QWORD PTR [rax+0x10]
 14a:	xor    rbx,rbx
 14d:	mov    rdx,rbx
 150:	call   155 <botlish_fn_2+0x5f>
			151: R_X86_64_PLT32	rt_type_error-0x4
 155:	mov    rax,rbx
 158:	mov    rbx,QWORD PTR [rsp+0x10]
 15d:	add    rsp,0x20
 161:	mov    rsp,rbp
 164:	pop    rbp
 165:	ret
 166:	mov    rax,rsi
 169:	and    rax,rdx
 16c:	test   rax,0x1
 172:	je     18d <botlish_fn_2+0x97>
 178:	lea    rcx,[rdx-0x1]
 17c:	mov    rax,rsi
 17f:	add    rax,rcx
 182:	seto   cl
 185:	test   cl,cl
 187:	je     192 <botlish_fn_2+0x9c>
 18d:	call   192 <botlish_fn_2+0x9c>
			18e: R_X86_64_PLT32	rt_int_add-0x4
 192:	mov    rbx,QWORD PTR [rsp+0x10]
 197:	add    rsp,0x20
 19b:	mov    rsp,rbp
 19e:	pop    rbp
 19f:	ret

00000000000001a0 <botlish_entry_2: step<generic>>:
 1a0:	push   rbp
 1a1:	mov    rbp,rsp
 1a4:	mov    rsi,QWORD PTR [rdx]
 1a7:	mov    rdx,QWORD PTR [rdx+0x8]
 1ab:	call   1b0 <botlish_entry_2+0x10>
			1ac: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 1b0:	mov    rsp,rbp
 1b3:	pop    rbp
 1b4:	ret

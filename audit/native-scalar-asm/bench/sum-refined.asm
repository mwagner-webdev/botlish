; source:  bench/sum-refined.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 674  (per function: 200 268 206)
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
   4:	sub    rsp,0x20
   8:	mov    QWORD PTR [rsp+0x10],r13
   d:	mov    QWORD PTR [rsp+0x18],r14
  12:	mov    r13,QWORD PTR [rdi]
  15:	mov    rax,QWORD PTR [rdi+0x8]
  19:	lea    rcx,[r13+0x8]
  1d:	cmp    rcx,rax
  20:	ja     99 <botlish_fn_0+0x99>
  26:	lea    rax,[r13+0x8]
  2a:	mov    QWORD PTR [rdi],rax
  2d:	mov    r14,rdi
  30:	mov    QWORD PTR [r13+0x0],0x0
  38:	mov    esi,0x321
  3d:	mov    QWORD PTR [rsp],0x321
  45:	mov    edx,0x1
  4a:	mov    QWORD PTR [rsp+0x8],0x1
  53:	mov    rdi,r14
  56:	call   5b <botlish_fn_0+0x5b>
			57: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
  5b:	test   rax,rax
  5e:	jne    80 <botlish_fn_0+0x80>
  64:	mov    rdi,r14
  67:	mov    QWORD PTR [rdi],r13
  6a:	xor    rax,rax
  6d:	mov    r13,QWORD PTR [rsp+0x10]
  72:	mov    r14,QWORD PTR [rsp+0x18]
  77:	add    rsp,0x20
  7b:	mov    rsp,rbp
  7e:	pop    rbp
  7f:	ret
  80:	mov    rdi,r14
  83:	mov    QWORD PTR [rdi],r13
  86:	mov    r13,QWORD PTR [rsp+0x10]
  8b:	mov    r14,QWORD PTR [rsp+0x18]
  90:	add    rsp,0x20
  94:	mov    rsp,rbp
  97:	pop    rbp
  98:	ret
  99:	call   9e <botlish_fn_0+0x9e>
			9a: R_X86_64_PLT32	rt_stack_overflow-0x4
  9e:	xor    rax,rax
  a1:	mov    r13,QWORD PTR [rsp+0x10]
  a6:	mov    r14,QWORD PTR [rsp+0x18]
  ab:	add    rsp,0x20
  af:	mov    rsp,rbp
  b2:	pop    rbp
  b3:	ret

00000000000000b4 <botlish_entry_0: <program entry>>:
  b4:	push   rbp
  b5:	mov    rbp,rsp
  b8:	call   bd <botlish_entry_0+0x9>
			b9: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  bd:	mov    rsp,rbp
  c0:	pop    rbp
  c1:	ret

00000000000000c2 <botlish_fn_1: sum<int, int>>:
  c2:	push   rbp
  c3:	mov    rbp,rsp
  c6:	sub    rsp,0x30
  ca:	mov    QWORD PTR [rsp+0x10],rbx
  cf:	mov    QWORD PTR [rsp+0x18],r12
  d4:	mov    QWORD PTR [rsp+0x20],r13
  d9:	mov    r12,QWORD PTR [rdi]
  dc:	mov    rax,QWORD PTR [rdi+0x8]
  e0:	lea    rcx,[r12+0x8]
  e5:	cmp    rcx,rax
  e8:	ja     192 <botlish_fn_1+0xd0>
  ee:	lea    rax,[r12+0x8]
  f3:	mov    QWORD PTR [rdi],rax
  f6:	mov    r13,rdi
  f9:	mov    QWORD PTR [r12],0x0
 101:	mov    QWORD PTR [rsp],rdx
 105:	sar    rsi,1
 108:	mov    rax,rsi
 10b:	mov    rsi,rdx
 10e:	mov    rbx,rax
 111:	test   rbx,rbx
 114:	je     171 <botlish_fn_1+0xaf>
 11a:	mov    rdx,rbx
 11d:	shl    rdx,1
 120:	or     rdx,0x1
 124:	mov    QWORD PTR [rsp+0x8],rdx
 129:	mov    rdi,r13
 12c:	call   131 <botlish_fn_1+0x6f>
			12d: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 131:	test   rax,rax
 134:	jne    15b <botlish_fn_1+0x99>
 13a:	mov    rdi,r13
 13d:	mov    QWORD PTR [rdi],r12
 140:	xor    rax,rax
 143:	mov    rbx,QWORD PTR [rsp+0x10]
 148:	mov    r12,QWORD PTR [rsp+0x18]
 14d:	mov    r13,QWORD PTR [rsp+0x20]
 152:	add    rsp,0x30
 156:	mov    rsp,rbp
 159:	pop    rbp
 15a:	ret
 15b:	mov    rdi,r13
 15e:	mov    QWORD PTR [rsp],rax
 162:	sub    rbx,0x1
 166:	mov    rsi,rax
 169:	mov    rax,rbx
 16c:	jmp    10e <botlish_fn_1+0x4c>
 171:	mov    rax,rsi
 174:	mov    rdi,r13
 177:	mov    QWORD PTR [rdi],r12
 17a:	mov    rbx,QWORD PTR [rsp+0x10]
 17f:	mov    r12,QWORD PTR [rsp+0x18]
 184:	mov    r13,QWORD PTR [rsp+0x20]
 189:	add    rsp,0x30
 18d:	mov    rsp,rbp
 190:	pop    rbp
 191:	ret
 192:	call   197 <botlish_fn_1+0xd5>
			193: R_X86_64_PLT32	rt_stack_overflow-0x4
 197:	xor    rax,rax
 19a:	mov    rbx,QWORD PTR [rsp+0x10]
 19f:	mov    r12,QWORD PTR [rsp+0x18]
 1a4:	mov    r13,QWORD PTR [rsp+0x20]
 1a9:	add    rsp,0x30
 1ad:	mov    rsp,rbp
 1b0:	pop    rbp
 1b1:	ret

00000000000001b2 <botlish_entry_1: sum<int, int>>:
 1b2:	push   rbp
 1b3:	mov    rbp,rsp
 1b6:	mov    rsi,QWORD PTR [rdx]
 1b9:	mov    rdx,QWORD PTR [rdx+0x8]
 1bd:	call   1c2 <botlish_entry_1+0x10>
			1be: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
 1c2:	mov    rsp,rbp
 1c5:	pop    rbp
 1c6:	ret

00000000000001c7 <botlish_fn_2: step<generic>>:
 1c7:	push   rbp
 1c8:	mov    rbp,rsp
 1cb:	sub    rsp,0x20
 1cf:	mov    QWORD PTR [rsp+0x10],rbx
 1d4:	mov    QWORD PTR [rsp],rsi
 1d8:	mov    QWORD PTR [rsp+0x8],rdx
 1dd:	mov    r8d,0x1
 1e3:	test   rsi,0x1
 1ea:	jne    20a <botlish_fn_2+0x43>
 1f0:	xor    r8d,r8d
 1f3:	test   rsi,0x7
 1fa:	jne    20a <botlish_fn_2+0x43>
 200:	movzx  rax,BYTE PTR [rsi]
 204:	cmp    al,0x1
 206:	sete   r8b
 20a:	test   r8b,r8b
 20d:	jne    237 <botlish_fn_2+0x70>
 213:	mov    rax,QWORD PTR [rdi+0x10]
 217:	mov    rcx,QWORD PTR [rax+0x10]
 21b:	xor    rbx,rbx
 21e:	mov    rdx,rbx
 221:	call   226 <botlish_fn_2+0x5f>
			222: R_X86_64_PLT32	rt_type_error-0x4
 226:	mov    rax,rbx
 229:	mov    rbx,QWORD PTR [rsp+0x10]
 22e:	add    rsp,0x20
 232:	mov    rsp,rbp
 235:	pop    rbp
 236:	ret
 237:	mov    rax,rsi
 23a:	and    rax,rdx
 23d:	test   rax,0x1
 243:	je     25e <botlish_fn_2+0x97>
 249:	lea    rcx,[rdx-0x1]
 24d:	mov    rax,rsi
 250:	add    rax,rcx
 253:	seto   cl
 256:	test   cl,cl
 258:	je     263 <botlish_fn_2+0x9c>
 25e:	call   263 <botlish_fn_2+0x9c>
			25f: R_X86_64_PLT32	rt_int_add-0x4
 263:	mov    rbx,QWORD PTR [rsp+0x10]
 268:	add    rsp,0x20
 26c:	mov    rsp,rbp
 26f:	pop    rbp
 270:	ret

0000000000000271 <botlish_entry_2: step<generic>>:
 271:	push   rbp
 272:	mov    rbp,rsp
 275:	mov    rsi,QWORD PTR [rdx]
 278:	mov    rdx,QWORD PTR [rdx+0x8]
 27c:	call   281 <botlish_entry_2+0x10>
			27d: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 281:	mov    rsp,rbp
 284:	pop    rbp
 285:	ret

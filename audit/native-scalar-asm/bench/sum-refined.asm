; source:  bench/sum-refined.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 743  (per function: 187 256 300)
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
   8:	mov    QWORD PTR [rsp],r13
   c:	mov    QWORD PTR [rsp+0x8],r14
  11:	mov    r13,QWORD PTR [rdi]
  14:	mov    rax,QWORD PTR [rdi+0x8]
  18:	lea    rcx,[r13+0x10]
  1c:	cmp    rcx,rax
  1f:	ja     8d <botlish_fn_0+0x8d>
  25:	lea    rax,[r13+0x10]
  29:	mov    QWORD PTR [rdi],rax
  2c:	mov    r14,rdi
  2f:	mov    esi,0x321
  34:	mov    QWORD PTR [r13+0x0],0x321
  3c:	mov    edx,0x1
  41:	mov    QWORD PTR [r13+0x8],0x1
  49:	mov    rdi,r14
  4c:	call   51 <botlish_fn_0+0x51>
			4d: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
  51:	test   rax,rax
  54:	jne    75 <botlish_fn_0+0x75>
  5a:	mov    rdi,r14
  5d:	mov    QWORD PTR [rdi],r13
  60:	xor    rax,rax
  63:	mov    r13,QWORD PTR [rsp]
  67:	mov    r14,QWORD PTR [rsp+0x8]
  6c:	add    rsp,0x10
  70:	mov    rsp,rbp
  73:	pop    rbp
  74:	ret
  75:	mov    rdi,r14
  78:	mov    QWORD PTR [rdi],r13
  7b:	mov    r13,QWORD PTR [rsp]
  7f:	mov    r14,QWORD PTR [rsp+0x8]
  84:	add    rsp,0x10
  88:	mov    rsp,rbp
  8b:	pop    rbp
  8c:	ret
  8d:	call   92 <botlish_fn_0+0x92>
			8e: R_X86_64_PLT32	rt_stack_overflow-0x4
  92:	xor    rax,rax
  95:	mov    r13,QWORD PTR [rsp]
  99:	mov    r14,QWORD PTR [rsp+0x8]
  9e:	add    rsp,0x10
  a2:	mov    rsp,rbp
  a5:	pop    rbp
  a6:	ret

00000000000000a7 <botlish_entry_0: <program entry>>:
  a7:	push   rbp
  a8:	mov    rbp,rsp
  ab:	call   b0 <botlish_entry_0+0x9>
			ac: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  b0:	mov    rsp,rbp
  b3:	pop    rbp
  b4:	ret

00000000000000b5 <botlish_fn_1: sum<int, int>>:
  b5:	push   rbp
  b6:	mov    rbp,rsp
  b9:	sub    rsp,0x20
  bd:	mov    QWORD PTR [rsp],rbx
  c1:	mov    QWORD PTR [rsp+0x8],r12
  c6:	mov    QWORD PTR [rsp+0x10],r13
  cb:	mov    r12,QWORD PTR [rdi]
  ce:	mov    rax,QWORD PTR [rdi+0x8]
  d2:	lea    rcx,[r12+0x10]
  d7:	cmp    rcx,rax
  da:	ja     17a <botlish_fn_1+0xc5>
  e0:	lea    rax,[r12+0x10]
  e5:	mov    QWORD PTR [rdi],rax
  e8:	mov    r13,rdi
  eb:	mov    QWORD PTR [r12],rdx
  ef:	sar    rsi,1
  f2:	mov    rax,rsi
  f5:	mov    rsi,rdx
  f8:	mov    rbx,rax
  fb:	test   rbx,rbx
  fe:	je     15a <botlish_fn_1+0xa5>
 104:	mov    rdx,rbx
 107:	shl    rdx,1
 10a:	or     rdx,0x1
 10e:	mov    QWORD PTR [r12+0x8],rdx
 113:	mov    rdi,r13
 116:	call   11b <botlish_fn_1+0x66>
			117: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 11b:	test   rax,rax
 11e:	jne    144 <botlish_fn_1+0x8f>
 124:	mov    rdi,r13
 127:	mov    QWORD PTR [rdi],r12
 12a:	xor    rax,rax
 12d:	mov    rbx,QWORD PTR [rsp]
 131:	mov    r12,QWORD PTR [rsp+0x8]
 136:	mov    r13,QWORD PTR [rsp+0x10]
 13b:	add    rsp,0x20
 13f:	mov    rsp,rbp
 142:	pop    rbp
 143:	ret
 144:	mov    rdi,r13
 147:	mov    QWORD PTR [r12],rax
 14b:	sub    rbx,0x1
 14f:	mov    rsi,rax
 152:	mov    rax,rbx
 155:	jmp    f8 <botlish_fn_1+0x43>
 15a:	mov    rax,rsi
 15d:	mov    rdi,r13
 160:	mov    QWORD PTR [rdi],r12
 163:	mov    rbx,QWORD PTR [rsp]
 167:	mov    r12,QWORD PTR [rsp+0x8]
 16c:	mov    r13,QWORD PTR [rsp+0x10]
 171:	add    rsp,0x20
 175:	mov    rsp,rbp
 178:	pop    rbp
 179:	ret
 17a:	call   17f <botlish_fn_1+0xca>
			17b: R_X86_64_PLT32	rt_stack_overflow-0x4
 17f:	xor    rax,rax
 182:	mov    rbx,QWORD PTR [rsp]
 186:	mov    r12,QWORD PTR [rsp+0x8]
 18b:	mov    r13,QWORD PTR [rsp+0x10]
 190:	add    rsp,0x20
 194:	mov    rsp,rbp
 197:	pop    rbp
 198:	ret

0000000000000199 <botlish_entry_1: sum<int, int>>:
 199:	push   rbp
 19a:	mov    rbp,rsp
 19d:	mov    rsi,QWORD PTR [rdx]
 1a0:	mov    rdx,QWORD PTR [rdx+0x8]
 1a4:	call   1a9 <botlish_entry_1+0x10>
			1a5: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
 1a9:	mov    rsp,rbp
 1ac:	pop    rbp
 1ad:	ret

00000000000001ae <botlish_fn_2: step<generic>>:
 1ae:	push   rbp
 1af:	mov    rbp,rsp
 1b2:	sub    rsp,0x30
 1b6:	mov    QWORD PTR [rsp+0x10],rbx
 1bb:	mov    QWORD PTR [rsp+0x18],r12
 1c0:	mov    QWORD PTR [rsp+0x20],r13
 1c5:	mov    QWORD PTR [rsp+0x28],r14
 1ca:	mov    rbx,QWORD PTR [rdi+0x20]
 1ce:	mov    r13,QWORD PTR [rdi+0x28]
 1d2:	lea    rax,[rsp]
 1d6:	mov    QWORD PTR [rdi+0x20],rax
 1da:	mov    QWORD PTR [rdi+0x28],0x2
 1e2:	mov    QWORD PTR [rsp],rsi
 1e6:	mov    QWORD PTR [rsp+0x8],rdx
 1eb:	mov    ecx,0x1
 1f0:	test   rsi,0x1
 1f7:	jne    215 <botlish_fn_2+0x67>
 1fd:	xor    ecx,ecx
 1ff:	test   rsi,0x7
 206:	jne    215 <botlish_fn_2+0x67>
 20c:	movzx  rax,BYTE PTR [rsi]
 210:	cmp    al,0x1
 212:	sete   cl
 215:	test   cl,cl
 217:	jne    25d <botlish_fn_2+0xaf>
 21d:	mov    rax,QWORD PTR [rdi+0x10]
 221:	mov    r12,rdi
 224:	mov    rcx,QWORD PTR [rax+0x10]
 228:	xor    r14,r14
 22b:	mov    rdx,r14
 22e:	call   233 <botlish_fn_2+0x85>
			22f: R_X86_64_PLT32	rt_type_error-0x4
 233:	mov    rax,r14
 236:	mov    QWORD PTR [r12+0x20],rbx
 23b:	mov    QWORD PTR [r12+0x28],r13
 240:	mov    rbx,QWORD PTR [rsp+0x10]
 245:	mov    r12,QWORD PTR [rsp+0x18]
 24a:	mov    r13,QWORD PTR [rsp+0x20]
 24f:	mov    r14,QWORD PTR [rsp+0x28]
 254:	add    rsp,0x30
 258:	mov    rsp,rbp
 25b:	pop    rbp
 25c:	ret
 25d:	mov    r12,rdi
 260:	mov    rax,rsi
 263:	and    rax,rdx
 266:	test   rax,0x1
 26c:	je     287 <botlish_fn_2+0xd9>
 272:	lea    rcx,[rdx-0x1]
 276:	mov    rax,rsi
 279:	add    rax,rcx
 27c:	seto   cl
 27f:	test   cl,cl
 281:	je     28f <botlish_fn_2+0xe1>
 287:	mov    rdi,r12
 28a:	call   28f <botlish_fn_2+0xe1>
			28b: R_X86_64_PLT32	rt_int_add-0x4
 28f:	mov    QWORD PTR [r12+0x20],rbx
 294:	mov    QWORD PTR [r12+0x28],r13
 299:	mov    rbx,QWORD PTR [rsp+0x10]
 29e:	mov    r12,QWORD PTR [rsp+0x18]
 2a3:	mov    r13,QWORD PTR [rsp+0x20]
 2a8:	mov    r14,QWORD PTR [rsp+0x28]
 2ad:	add    rsp,0x30
 2b1:	mov    rsp,rbp
 2b4:	pop    rbp
 2b5:	ret

00000000000002b6 <botlish_entry_2: step<generic>>:
 2b6:	push   rbp
 2b7:	mov    rbp,rsp
 2ba:	mov    rsi,QWORD PTR [rdx]
 2bd:	mov    rdx,QWORD PTR [rdx+0x8]
 2c1:	call   2c6 <botlish_entry_2+0x10>
			2c2: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 2c6:	mov    rsp,rbp
 2c9:	pop    rbp
 2ca:	ret

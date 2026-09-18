; source:  bench/sum-refined.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 787  (per function: 202 267 318)
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
  1f:	ja     9d <botlish_fn_0+0x9d>
  25:	lea    rax,[r13+0x10]
  29:	mov    QWORD PTR [rdi],rax
  2c:	mov    r14,rdi
  2f:	mov    QWORD PTR [r13+0x0],0x0
  37:	mov    QWORD PTR [r13+0x8],0x0
  3f:	mov    esi,0x321
  44:	mov    QWORD PTR [r13+0x0],0x321
  4c:	mov    edx,0x1
  51:	mov    QWORD PTR [r13+0x8],0x1
  59:	mov    rdi,r14
  5c:	call   61 <botlish_fn_0+0x61>
			5d: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
  61:	test   rax,rax
  64:	jne    85 <botlish_fn_0+0x85>
  6a:	mov    rdi,r14
  6d:	mov    QWORD PTR [rdi],r13
  70:	xor    rax,rax
  73:	mov    r13,QWORD PTR [rsp]
  77:	mov    r14,QWORD PTR [rsp+0x8]
  7c:	add    rsp,0x10
  80:	mov    rsp,rbp
  83:	pop    rbp
  84:	ret
  85:	mov    rdi,r14
  88:	mov    QWORD PTR [rdi],r13
  8b:	mov    r13,QWORD PTR [rsp]
  8f:	mov    r14,QWORD PTR [rsp+0x8]
  94:	add    rsp,0x10
  98:	mov    rsp,rbp
  9b:	pop    rbp
  9c:	ret
  9d:	call   a2 <botlish_fn_0+0xa2>
			9e: R_X86_64_PLT32	rt_stack_overflow-0x4
  a2:	xor    rax,rax
  a5:	mov    r13,QWORD PTR [rsp]
  a9:	mov    r14,QWORD PTR [rsp+0x8]
  ae:	add    rsp,0x10
  b2:	mov    rsp,rbp
  b5:	pop    rbp
  b6:	ret

00000000000000b7 <botlish_entry_0: <program entry>>:
  b7:	push   rbp
  b8:	mov    rbp,rsp
  bb:	call   c0 <botlish_entry_0+0x9>
			bc: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  c0:	mov    rsp,rbp
  c3:	pop    rbp
  c4:	ret

00000000000000c5 <botlish_fn_1: sum<int, int>>:
  c5:	push   rbp
  c6:	mov    rbp,rsp
  c9:	sub    rsp,0x20
  cd:	mov    QWORD PTR [rsp],rbx
  d1:	mov    QWORD PTR [rsp+0x8],r12
  d6:	mov    QWORD PTR [rsp+0x10],r13
  db:	mov    r12,QWORD PTR [rdi]
  de:	mov    rax,QWORD PTR [rdi+0x8]
  e2:	lea    rcx,[r12+0x10]
  e7:	cmp    rcx,rax
  ea:	ja     195 <botlish_fn_1+0xd0>
  f0:	lea    rax,[r12+0x10]
  f5:	mov    QWORD PTR [rdi],rax
  f8:	mov    r13,rdi
  fb:	mov    QWORD PTR [r12],0x0
 103:	mov    QWORD PTR [r12+0x8],0x0
 10c:	mov    QWORD PTR [r12],rdx
 110:	sar    rsi,1
 113:	mov    rbx,rsi
 116:	mov    rsi,rdx
 119:	test   rbx,rbx
 11c:	je     175 <botlish_fn_1+0xb0>
 122:	mov    rdx,rbx
 125:	shl    rdx,1
 128:	or     rdx,0x1
 12c:	mov    QWORD PTR [r12+0x8],rdx
 131:	mov    rdi,r13
 134:	call   139 <botlish_fn_1+0x74>
			135: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 139:	test   rax,rax
 13c:	jne    162 <botlish_fn_1+0x9d>
 142:	mov    rdi,r13
 145:	mov    QWORD PTR [rdi],r12
 148:	xor    rax,rax
 14b:	mov    rbx,QWORD PTR [rsp]
 14f:	mov    r12,QWORD PTR [rsp+0x8]
 154:	mov    r13,QWORD PTR [rsp+0x10]
 159:	add    rsp,0x20
 15d:	mov    rsp,rbp
 160:	pop    rbp
 161:	ret
 162:	mov    rdi,r13
 165:	mov    QWORD PTR [r12],rax
 169:	sub    rbx,0x1
 16d:	mov    rsi,rax
 170:	jmp    119 <botlish_fn_1+0x54>
 175:	mov    rax,rsi
 178:	mov    rdi,r13
 17b:	mov    QWORD PTR [rdi],r12
 17e:	mov    rbx,QWORD PTR [rsp]
 182:	mov    r12,QWORD PTR [rsp+0x8]
 187:	mov    r13,QWORD PTR [rsp+0x10]
 18c:	add    rsp,0x20
 190:	mov    rsp,rbp
 193:	pop    rbp
 194:	ret
 195:	call   19a <botlish_fn_1+0xd5>
			196: R_X86_64_PLT32	rt_stack_overflow-0x4
 19a:	xor    rax,rax
 19d:	mov    rbx,QWORD PTR [rsp]
 1a1:	mov    r12,QWORD PTR [rsp+0x8]
 1a6:	mov    r13,QWORD PTR [rsp+0x10]
 1ab:	add    rsp,0x20
 1af:	mov    rsp,rbp
 1b2:	pop    rbp
 1b3:	ret

00000000000001b4 <botlish_entry_1: sum<int, int>>:
 1b4:	push   rbp
 1b5:	mov    rbp,rsp
 1b8:	mov    rsi,QWORD PTR [rdx]
 1bb:	mov    rdx,QWORD PTR [rdx+0x8]
 1bf:	call   1c4 <botlish_entry_1+0x10>
			1c0: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
 1c4:	mov    rsp,rbp
 1c7:	pop    rbp
 1c8:	ret

00000000000001c9 <botlish_fn_2: step<generic>>:
 1c9:	push   rbp
 1ca:	mov    rbp,rsp
 1cd:	sub    rsp,0x10
 1d1:	mov    QWORD PTR [rsp],rbx
 1d5:	mov    QWORD PTR [rsp+0x8],r12
 1da:	mov    rbx,QWORD PTR [rdi]
 1dd:	mov    rax,QWORD PTR [rdi+0x8]
 1e1:	lea    rcx,[rbx+0x10]
 1e5:	cmp    rcx,rax
 1e8:	ja     2c0 <botlish_fn_2+0xf7>
 1ee:	lea    rax,[rbx+0x10]
 1f2:	mov    QWORD PTR [rdi],rax
 1f5:	mov    QWORD PTR [rbx],0x0
 1fc:	mov    QWORD PTR [rbx+0x8],0x0
 204:	mov    QWORD PTR [rbx],rsi
 207:	mov    QWORD PTR [rbx+0x8],rdx
 20b:	mov    ecx,0x1
 210:	test   rsi,0x1
 217:	jne    235 <botlish_fn_2+0x6c>
 21d:	xor    ecx,ecx
 21f:	test   rsi,0x7
 226:	jne    235 <botlish_fn_2+0x6c>
 22c:	movzx  rax,BYTE PTR [rsi]
 230:	cmp    al,0x1
 232:	sete   cl
 235:	test   cl,cl
 237:	jne    26b <botlish_fn_2+0xa2>
 23d:	mov    rax,QWORD PTR [rdi+0x10]
 241:	mov    r12,rdi
 244:	mov    rcx,QWORD PTR [rax+0x10]
 248:	xor    rdx,rdx
 24b:	call   250 <botlish_fn_2+0x87>
			24c: R_X86_64_PLT32	rt_type_error-0x4
 250:	mov    rdi,r12
 253:	mov    QWORD PTR [rdi],rbx
 256:	xor    rax,rax
 259:	mov    rbx,QWORD PTR [rsp]
 25d:	mov    r12,QWORD PTR [rsp+0x8]
 262:	add    rsp,0x10
 266:	mov    rsp,rbp
 269:	pop    rbp
 26a:	ret
 26b:	mov    r12,rdi
 26e:	mov    rax,rsi
 271:	and    rax,rdx
 274:	test   rax,0x1
 27a:	je     29d <botlish_fn_2+0xd4>
 280:	lea    rcx,[rdx-0x1]
 284:	mov    rax,rsi
 287:	add    rax,rcx
 28a:	seto   cl
 28d:	test   cl,cl
 28f:	jne    29d <botlish_fn_2+0xd4>
 295:	mov    rdi,r12
 298:	jmp    2a8 <botlish_fn_2+0xdf>
 29d:	mov    rdi,r12
 2a0:	call   2a5 <botlish_fn_2+0xdc>
			2a1: R_X86_64_PLT32	rt_int_add-0x4
 2a5:	mov    rdi,r12
 2a8:	mov    rdi,r12
 2ab:	mov    QWORD PTR [rdi],rbx
 2ae:	mov    rbx,QWORD PTR [rsp]
 2b2:	mov    r12,QWORD PTR [rsp+0x8]
 2b7:	add    rsp,0x10
 2bb:	mov    rsp,rbp
 2be:	pop    rbp
 2bf:	ret
 2c0:	mov    r12,rdi
 2c3:	call   2c8 <botlish_fn_2+0xff>
			2c4: R_X86_64_PLT32	rt_stack_overflow-0x4
 2c8:	xor    rax,rax
 2cb:	mov    rbx,QWORD PTR [rsp]
 2cf:	mov    r12,QWORD PTR [rsp+0x8]
 2d4:	add    rsp,0x10
 2d8:	mov    rsp,rbp
 2db:	pop    rbp
 2dc:	ret

00000000000002dd <botlish_entry_2: step<generic>>:
 2dd:	push   rbp
 2de:	mov    rbp,rsp
 2e1:	mov    rsi,QWORD PTR [rdx]
 2e4:	mov    rdx,QWORD PTR [rdx+0x8]
 2e8:	call   2ed <botlish_entry_2+0x10>
			2e9: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 2ed:	mov    rsp,rbp
 2f0:	pop    rbp
 2f1:	ret

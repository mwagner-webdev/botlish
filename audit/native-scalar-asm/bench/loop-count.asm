; source:  bench/loop-count.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 798  (per function: 202 111 485)
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
   8:	mov    QWORD PTR [rsp],r14
   c:	mov    QWORD PTR [rsp+0x8],r15
  11:	mov    r14,QWORD PTR [rdi]
  14:	mov    rax,QWORD PTR [rdi+0x8]
  18:	lea    rcx,[r14+0x10]
  1c:	cmp    rcx,rax
  1f:	ja     9b <botlish_fn_0+0x9b>
  25:	lea    rax,[r14+0x10]
  29:	mov    QWORD PTR [rdi],rax
  2c:	mov    r15,rdi
  2f:	mov    QWORD PTR [r14],0x0
  36:	mov    QWORD PTR [r14+0x8],0x0
  3e:	mov    esi,0x3e9
  43:	mov    QWORD PTR [r14],0x3e9
  4a:	mov    edx,0x1
  4f:	mov    QWORD PTR [r14+0x8],0x1
  57:	mov    rdi,r15
  5a:	call   5f <botlish_fn_0+0x5f>
			5b: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
  5f:	test   rax,rax
  62:	jne    83 <botlish_fn_0+0x83>
  68:	mov    rdi,r15
  6b:	mov    QWORD PTR [rdi],r14
  6e:	xor    rax,rax
  71:	mov    r14,QWORD PTR [rsp]
  75:	mov    r15,QWORD PTR [rsp+0x8]
  7a:	add    rsp,0x10
  7e:	mov    rsp,rbp
  81:	pop    rbp
  82:	ret
  83:	mov    rdi,r15
  86:	mov    QWORD PTR [rdi],r14
  89:	mov    r14,QWORD PTR [rsp]
  8d:	mov    r15,QWORD PTR [rsp+0x8]
  92:	add    rsp,0x10
  96:	mov    rsp,rbp
  99:	pop    rbp
  9a:	ret
  9b:	mov    rax,QWORD PTR [rip+0x0]        # a2 <botlish_fn_0+0xa2>
			9e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
  a2:	call   rax
  a4:	xor    rax,rax
  a7:	mov    r14,QWORD PTR [rsp]
  ab:	mov    r15,QWORD PTR [rsp+0x8]
  b0:	add    rsp,0x10
  b4:	mov    rsp,rbp
  b7:	pop    rbp
  b8:	ret

00000000000000b9 <botlish_entry_0: <program entry>>:
  b9:	push   rbp
  ba:	mov    rbp,rsp
  bd:	call   c2 <botlish_entry_0+0x9>
			be: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  c2:	mov    rsp,rbp
  c5:	pop    rbp
  c6:	ret

00000000000000c7 <botlish_fn_1: work<int>>:
  c7:	push   rbp
  c8:	mov    rbp,rsp
  cb:	mov    rax,QWORD PTR [rdi]
  ce:	mov    rcx,QWORD PTR [rdi+0x8]
  d2:	lea    rdx,[rax+0x8]
  d6:	cmp    rdx,rcx
  d9:	ja     111 <botlish_fn_1+0x4a>
  df:	lea    rcx,[rax+0x8]
  e3:	mov    QWORD PTR [rdi],rcx
  e6:	mov    QWORD PTR [rax],0x0
  ed:	sar    rsi,1
  f0:	imul   rcx,rsi,0x3
  f4:	add    rcx,0x7
  fb:	test   rcx,rcx
  fe:	jl     fb <botlish_fn_1+0x34>
 104:	mov    QWORD PTR [rdi],rax
 107:	mov    eax,0xf
 10c:	mov    rsp,rbp
 10f:	pop    rbp
 110:	ret
 111:	mov    rax,QWORD PTR [rip+0x0]        # 118 <botlish_fn_1+0x51>
			114: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 118:	call   rax
 11a:	xor    rax,rax
 11d:	mov    rsp,rbp
 120:	pop    rbp
 121:	ret

0000000000000122 <botlish_entry_1: work<int>>:
 122:	push   rbp
 123:	mov    rbp,rsp
 126:	mov    rsi,QWORD PTR [rdx]
 129:	call   12e <botlish_entry_1+0xc>
			12a: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 12e:	mov    rsp,rbp
 131:	pop    rbp
 132:	ret
 133:	add    BYTE PTR [rax],al
 135:	add    BYTE PTR [rax],al
	...

0000000000000138 <botlish_fn_2: drive<int, int>>:
 138:	push   rbp
 139:	mov    rbp,rsp
 13c:	sub    rsp,0x30
 140:	mov    QWORD PTR [rsp],rbx
 144:	mov    QWORD PTR [rsp+0x8],r12
 149:	mov    QWORD PTR [rsp+0x10],r13
 14e:	mov    QWORD PTR [rsp+0x18],r14
 153:	mov    QWORD PTR [rsp+0x20],r15
 158:	mov    r13,QWORD PTR [rdi]
 15b:	mov    rax,QWORD PTR [rdi+0x8]
 15f:	lea    rcx,[r13+0x18]
 163:	cmp    rcx,rax
 166:	ja     2c4 <botlish_fn_2+0x18c>
 16c:	lea    rax,[r13+0x18]
 170:	mov    QWORD PTR [rdi],rax
 173:	mov    r14,rdi
 176:	mov    QWORD PTR [r13+0x0],0x0
 17e:	mov    QWORD PTR [r13+0x8],0x0
 186:	mov    QWORD PTR [r13+0x10],0x0
 18e:	mov    QWORD PTR [r13+0x0],rsi
 192:	mov    QWORD PTR [r13+0x8],rdx
 196:	mov    r12,rsi
 199:	mov    r15,rdx
 19c:	test   r12,0x1
 1a3:	jne    1d2 <botlish_fn_2+0x9a>
 1a9:	mov    edx,0x1
 1ae:	mov    rax,QWORD PTR [rip+0x0]        # 1b5 <botlish_fn_2+0x7d>
			1b1: R_X86_64_GOTPCREL	rt_int_cmp-0x4
 1b5:	mov    rsi,r12
 1b8:	mov    rdi,r14
 1bb:	call   rax
 1bd:	mov    ecx,0x2
 1c2:	test   rax,rax
 1c5:	cmovle rcx,QWORD PTR [rip+0x12b]        # 2f8 <botlish_fn_2+0x1c0>
 1cd:	jmp    1e3 <botlish_fn_2+0xab>
 1d2:	mov    ecx,0x2
 1d7:	cmp    r12,0x1
 1db:	cmovle rcx,QWORD PTR [rip+0x115]        # 2f8 <botlish_fn_2+0x1c0>
 1e3:	cmp    rcx,0x6
 1e7:	je     29a <botlish_fn_2+0x162>
 1ed:	mov    rbx,r12
 1f0:	sar    rbx,1
 1f3:	sub    rbx,0x1
 1f7:	shl    rbx,1
 1fa:	or     rbx,0x1
 1fe:	mov    QWORD PTR [r13+0x10],rbx
 202:	mov    rsi,r12
 205:	mov    rdi,r14
 208:	call   20d <botlish_fn_2+0xd5>
			209: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 20d:	test   rax,rax
 210:	jne    240 <botlish_fn_2+0x108>
 216:	mov    rdi,r14
 219:	mov    QWORD PTR [rdi],r13
 21c:	xor    rax,rax
 21f:	mov    rbx,QWORD PTR [rsp]
 223:	mov    r12,QWORD PTR [rsp+0x8]
 228:	mov    r13,QWORD PTR [rsp+0x10]
 22d:	mov    r14,QWORD PTR [rsp+0x18]
 232:	mov    r15,QWORD PTR [rsp+0x20]
 237:	add    rsp,0x30
 23b:	mov    rsp,rbp
 23e:	pop    rbp
 23f:	ret
 240:	mov    QWORD PTR [r13+0x0],rax
 244:	mov    rsi,r15
 247:	mov    rcx,rsi
 24a:	and    rcx,rax
 24d:	test   rcx,0x1
 254:	jne    262 <botlish_fn_2+0x12a>
 25a:	mov    rdx,rax
 25d:	jmp    27a <botlish_fn_2+0x142>
 262:	lea    rcx,[rax-0x1]
 266:	mov    rdx,rax
 269:	mov    rax,rsi
 26c:	add    rax,rcx
 26f:	seto   cl
 272:	test   cl,cl
 274:	je     287 <botlish_fn_2+0x14f>
 27a:	mov    r8,QWORD PTR [rip+0x0]        # 281 <botlish_fn_2+0x149>
			27d: R_X86_64_GOTPCREL	rt_int_add-0x4
 281:	mov    rdi,r14
 284:	call   r8
 287:	mov    QWORD PTR [r13+0x0],rbx
 28b:	mov    QWORD PTR [r13+0x8],rax
 28f:	mov    r12,rbx
 292:	mov    r15,rax
 295:	jmp    19c <botlish_fn_2+0x64>
 29a:	mov    rdi,r14
 29d:	mov    QWORD PTR [rdi],r13
 2a0:	mov    rax,r15
 2a3:	mov    rbx,QWORD PTR [rsp]
 2a7:	mov    r12,QWORD PTR [rsp+0x8]
 2ac:	mov    r13,QWORD PTR [rsp+0x10]
 2b1:	mov    r14,QWORD PTR [rsp+0x18]
 2b6:	mov    r15,QWORD PTR [rsp+0x20]
 2bb:	add    rsp,0x30
 2bf:	mov    rsp,rbp
 2c2:	pop    rbp
 2c3:	ret
 2c4:	mov    r14,rdi
 2c7:	mov    r9,QWORD PTR [rip+0x0]        # 2ce <botlish_fn_2+0x196>
			2ca: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 2ce:	call   r9
 2d1:	xor    rax,rax
 2d4:	mov    rbx,QWORD PTR [rsp]
 2d8:	mov    r12,QWORD PTR [rsp+0x8]
 2dd:	mov    r13,QWORD PTR [rsp+0x10]
 2e2:	mov    r14,QWORD PTR [rsp+0x18]
 2e7:	mov    r15,QWORD PTR [rsp+0x20]
 2ec:	add    rsp,0x30
 2f0:	mov    rsp,rbp
 2f3:	pop    rbp
 2f4:	ret
 2f5:	add    BYTE PTR [rax],al
 2f7:	add    BYTE PTR [rsi],al
 2f9:	add    BYTE PTR [rax],al
 2fb:	add    BYTE PTR [rax],al
 2fd:	add    BYTE PTR [rax],al
	...

0000000000000300 <botlish_entry_2: drive<int, int>>:
 300:	push   rbp
 301:	mov    rbp,rsp
 304:	mov    rsi,QWORD PTR [rdx]
 307:	mov    rdx,QWORD PTR [rdx+0x8]
 30b:	call   310 <botlish_entry_2+0x10>
			30c: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 310:	mov    rsp,rbp
 313:	pop    rbp
 314:	ret

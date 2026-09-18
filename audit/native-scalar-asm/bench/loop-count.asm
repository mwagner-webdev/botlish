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
  3f:	mov    esi,0x3e9
  44:	mov    QWORD PTR [r13+0x0],0x3e9
  4c:	mov    edx,0x1
  51:	mov    QWORD PTR [r13+0x8],0x1
  59:	mov    rdi,r14
  5c:	call   61 <botlish_fn_0+0x61>
			5d: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
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

00000000000000c5 <botlish_fn_1: work<int>>:
  c5:	push   rbp
  c6:	mov    rbp,rsp
  c9:	mov    rax,QWORD PTR [rdi]
  cc:	mov    rcx,QWORD PTR [rdi+0x8]
  d0:	lea    rdx,[rax+0x8]
  d4:	cmp    rdx,rcx
  d7:	ja     10f <botlish_fn_1+0x4a>
  dd:	lea    rcx,[rax+0x8]
  e1:	mov    QWORD PTR [rdi],rcx
  e4:	mov    QWORD PTR [rax],0x0
  eb:	sar    rsi,1
  ee:	imul   rcx,rsi,0x3
  f2:	add    rcx,0x7
  f9:	test   rcx,rcx
  fc:	jl     f9 <botlish_fn_1+0x34>
 102:	mov    QWORD PTR [rdi],rax
 105:	mov    eax,0xf
 10a:	mov    rsp,rbp
 10d:	pop    rbp
 10e:	ret
 10f:	call   114 <botlish_fn_1+0x4f>
			110: R_X86_64_PLT32	rt_stack_overflow-0x4
 114:	xor    rax,rax
 117:	mov    rsp,rbp
 11a:	pop    rbp
 11b:	ret

000000000000011c <botlish_entry_1: work<int>>:
 11c:	push   rbp
 11d:	mov    rbp,rsp
 120:	mov    rsi,QWORD PTR [rdx]
 123:	call   128 <botlish_entry_1+0xc>
			124: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 128:	mov    rsp,rbp
 12b:	pop    rbp
 12c:	ret
 12d:	add    BYTE PTR [rax],al
	...

0000000000000130 <botlish_fn_2: drive<int, int>>:
 130:	push   rbp
 131:	mov    rbp,rsp
 134:	sub    rsp,0x30
 138:	mov    QWORD PTR [rsp],rbx
 13c:	mov    QWORD PTR [rsp+0x8],r12
 141:	mov    QWORD PTR [rsp+0x10],r13
 146:	mov    QWORD PTR [rsp+0x18],r14
 14b:	mov    QWORD PTR [rsp+0x20],r15
 150:	mov    r13,QWORD PTR [rdi]
 153:	mov    rax,QWORD PTR [rdi+0x8]
 157:	lea    rcx,[r13+0x18]
 15b:	cmp    rcx,rax
 15e:	ja     2b3 <botlish_fn_2+0x183>
 164:	lea    rax,[r13+0x18]
 168:	mov    QWORD PTR [rdi],rax
 16b:	mov    r14,rdi
 16e:	mov    QWORD PTR [r13+0x0],0x0
 176:	mov    QWORD PTR [r13+0x8],0x0
 17e:	mov    QWORD PTR [r13+0x10],0x0
 186:	mov    QWORD PTR [r13+0x0],rsi
 18a:	mov    QWORD PTR [r13+0x8],rdx
 18e:	mov    r12,rsi
 191:	mov    r15,rdx
 194:	test   r12,0x1
 19b:	jne    1c6 <botlish_fn_2+0x96>
 1a1:	mov    edx,0x1
 1a6:	mov    rsi,r12
 1a9:	mov    rdi,r14
 1ac:	call   1b1 <botlish_fn_2+0x81>
			1ad: R_X86_64_PLT32	rt_int_cmp-0x4
 1b1:	mov    ecx,0x2
 1b6:	test   rax,rax
 1b9:	cmovle rcx,QWORD PTR [rip+0x11f]        # 2e0 <botlish_fn_2+0x1b0>
 1c1:	jmp    1d7 <botlish_fn_2+0xa7>
 1c6:	mov    ecx,0x2
 1cb:	cmp    r12,0x1
 1cf:	cmovle rcx,QWORD PTR [rip+0x109]        # 2e0 <botlish_fn_2+0x1b0>
 1d7:	cmp    rcx,0x6
 1db:	je     289 <botlish_fn_2+0x159>
 1e1:	mov    rbx,r12
 1e4:	sar    rbx,1
 1e7:	sub    rbx,0x1
 1eb:	shl    rbx,1
 1ee:	or     rbx,0x1
 1f2:	mov    QWORD PTR [r13+0x10],rbx
 1f6:	mov    rsi,r12
 1f9:	mov    rdi,r14
 1fc:	call   201 <botlish_fn_2+0xd1>
			1fd: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 201:	test   rax,rax
 204:	jne    234 <botlish_fn_2+0x104>
 20a:	mov    rdi,r14
 20d:	mov    QWORD PTR [rdi],r13
 210:	xor    rax,rax
 213:	mov    rbx,QWORD PTR [rsp]
 217:	mov    r12,QWORD PTR [rsp+0x8]
 21c:	mov    r13,QWORD PTR [rsp+0x10]
 221:	mov    r14,QWORD PTR [rsp+0x18]
 226:	mov    r15,QWORD PTR [rsp+0x20]
 22b:	add    rsp,0x30
 22f:	mov    rsp,rbp
 232:	pop    rbp
 233:	ret
 234:	mov    QWORD PTR [r13+0x0],rax
 238:	mov    rsi,r15
 23b:	mov    rcx,rsi
 23e:	and    rcx,rax
 241:	test   rcx,0x1
 248:	jne    256 <botlish_fn_2+0x126>
 24e:	mov    rdx,rax
 251:	jmp    26e <botlish_fn_2+0x13e>
 256:	lea    rcx,[rax-0x1]
 25a:	mov    rdx,rax
 25d:	mov    rax,rsi
 260:	add    rax,rcx
 263:	seto   cl
 266:	test   cl,cl
 268:	je     276 <botlish_fn_2+0x146>
 26e:	mov    rdi,r14
 271:	call   276 <botlish_fn_2+0x146>
			272: R_X86_64_PLT32	rt_int_add-0x4
 276:	mov    QWORD PTR [r13+0x0],rbx
 27a:	mov    QWORD PTR [r13+0x8],rax
 27e:	mov    r12,rbx
 281:	mov    r15,rax
 284:	jmp    194 <botlish_fn_2+0x64>
 289:	mov    rdi,r14
 28c:	mov    QWORD PTR [rdi],r13
 28f:	mov    rax,r15
 292:	mov    rbx,QWORD PTR [rsp]
 296:	mov    r12,QWORD PTR [rsp+0x8]
 29b:	mov    r13,QWORD PTR [rsp+0x10]
 2a0:	mov    r14,QWORD PTR [rsp+0x18]
 2a5:	mov    r15,QWORD PTR [rsp+0x20]
 2aa:	add    rsp,0x30
 2ae:	mov    rsp,rbp
 2b1:	pop    rbp
 2b2:	ret
 2b3:	mov    r14,rdi
 2b6:	call   2bb <botlish_fn_2+0x18b>
			2b7: R_X86_64_PLT32	rt_stack_overflow-0x4
 2bb:	xor    rax,rax
 2be:	mov    rbx,QWORD PTR [rsp]
 2c2:	mov    r12,QWORD PTR [rsp+0x8]
 2c7:	mov    r13,QWORD PTR [rsp+0x10]
 2cc:	mov    r14,QWORD PTR [rsp+0x18]
 2d1:	mov    r15,QWORD PTR [rsp+0x20]
 2d6:	add    rsp,0x30
 2da:	mov    rsp,rbp
 2dd:	pop    rbp
 2de:	ret
 2df:	add    BYTE PTR [rsi],al
 2e1:	add    BYTE PTR [rax],al
 2e3:	add    BYTE PTR [rax],al
 2e5:	add    BYTE PTR [rax],al
	...

00000000000002e8 <botlish_entry_2: drive<int, int>>:
 2e8:	push   rbp
 2e9:	mov    rbp,rsp
 2ec:	mov    rsi,QWORD PTR [rdx]
 2ef:	mov    rdx,QWORD PTR [rdx+0x8]
 2f3:	call   2f8 <botlish_entry_2+0x10>
			2f4: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 2f8:	mov    rsp,rbp
 2fb:	pop    rbp
 2fc:	ret

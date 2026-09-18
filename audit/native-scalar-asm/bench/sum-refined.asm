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
  3e:	mov    esi,0x321
  43:	mov    QWORD PTR [r14],0x321
  4a:	mov    edx,0x1
  4f:	mov    QWORD PTR [r14+0x8],0x1
  57:	mov    rdi,r15
  5a:	call   5f <botlish_fn_0+0x5f>
			5b: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
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

00000000000000c7 <botlish_fn_1: sum<int, int>>:
  c7:	push   rbp
  c8:	mov    rbp,rsp
  cb:	sub    rsp,0x20
  cf:	mov    QWORD PTR [rsp],rbx
  d3:	mov    QWORD PTR [rsp+0x8],r12
  d8:	mov    QWORD PTR [rsp+0x10],r13
  dd:	mov    r12,QWORD PTR [rdi]
  e0:	mov    rax,QWORD PTR [rdi+0x8]
  e4:	lea    rcx,[r12+0x10]
  e9:	cmp    rcx,rax
  ec:	ja     197 <botlish_fn_1+0xd0>
  f2:	lea    rax,[r12+0x10]
  f7:	mov    QWORD PTR [rdi],rax
  fa:	mov    r13,rdi
  fd:	mov    QWORD PTR [r12],0x0
 105:	mov    QWORD PTR [r12+0x8],0x0
 10e:	mov    QWORD PTR [r12],rdx
 112:	sar    rsi,1
 115:	mov    rbx,rsi
 118:	mov    rsi,rdx
 11b:	test   rbx,rbx
 11e:	je     177 <botlish_fn_1+0xb0>
 124:	mov    rdx,rbx
 127:	shl    rdx,1
 12a:	or     rdx,0x1
 12e:	mov    QWORD PTR [r12+0x8],rdx
 133:	mov    rdi,r13
 136:	call   13b <botlish_fn_1+0x74>
			137: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 13b:	test   rax,rax
 13e:	jne    164 <botlish_fn_1+0x9d>
 144:	mov    rdi,r13
 147:	mov    QWORD PTR [rdi],r12
 14a:	xor    rax,rax
 14d:	mov    rbx,QWORD PTR [rsp]
 151:	mov    r12,QWORD PTR [rsp+0x8]
 156:	mov    r13,QWORD PTR [rsp+0x10]
 15b:	add    rsp,0x20
 15f:	mov    rsp,rbp
 162:	pop    rbp
 163:	ret
 164:	mov    rdi,r13
 167:	mov    QWORD PTR [r12],rax
 16b:	sub    rbx,0x1
 16f:	mov    rsi,rax
 172:	jmp    11b <botlish_fn_1+0x54>
 177:	mov    rax,rsi
 17a:	mov    rdi,r13
 17d:	mov    QWORD PTR [rdi],r12
 180:	mov    rbx,QWORD PTR [rsp]
 184:	mov    r12,QWORD PTR [rsp+0x8]
 189:	mov    r13,QWORD PTR [rsp+0x10]
 18e:	add    rsp,0x20
 192:	mov    rsp,rbp
 195:	pop    rbp
 196:	ret
 197:	mov    rax,QWORD PTR [rip+0x0]        # 19e <botlish_fn_1+0xd7>
			19a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 19e:	call   rax
 1a0:	xor    rax,rax
 1a3:	mov    rbx,QWORD PTR [rsp]
 1a7:	mov    r12,QWORD PTR [rsp+0x8]
 1ac:	mov    r13,QWORD PTR [rsp+0x10]
 1b1:	add    rsp,0x20
 1b5:	mov    rsp,rbp
 1b8:	pop    rbp
 1b9:	ret

00000000000001ba <botlish_entry_1: sum<int, int>>:
 1ba:	push   rbp
 1bb:	mov    rbp,rsp
 1be:	mov    rsi,QWORD PTR [rdx]
 1c1:	mov    rdx,QWORD PTR [rdx+0x8]
 1c5:	call   1ca <botlish_entry_1+0x10>
			1c6: R_X86_64_PLT32	botlish_fn_1-0x4 ; sum<int, int>
 1ca:	mov    rsp,rbp
 1cd:	pop    rbp
 1ce:	ret

00000000000001cf <botlish_fn_2: step<generic>>:
 1cf:	push   rbp
 1d0:	mov    rbp,rsp
 1d3:	sub    rsp,0x10
 1d7:	mov    QWORD PTR [rsp],rbx
 1db:	mov    QWORD PTR [rsp+0x8],r12
 1e0:	mov    rbx,QWORD PTR [rdi]
 1e3:	mov    rax,QWORD PTR [rdi+0x8]
 1e7:	lea    rcx,[rbx+0x10]
 1eb:	cmp    rcx,rax
 1ee:	ja     2ce <botlish_fn_2+0xff>
 1f4:	lea    rax,[rbx+0x10]
 1f8:	mov    QWORD PTR [rdi],rax
 1fb:	mov    QWORD PTR [rbx],0x0
 202:	mov    QWORD PTR [rbx+0x8],0x0
 20a:	mov    QWORD PTR [rbx],rsi
 20d:	mov    QWORD PTR [rbx+0x8],rdx
 211:	mov    ecx,0x1
 216:	test   rsi,0x1
 21d:	jne    23b <botlish_fn_2+0x6c>
 223:	xor    ecx,ecx
 225:	test   rsi,0x7
 22c:	jne    23b <botlish_fn_2+0x6c>
 232:	movzx  rax,BYTE PTR [rsi]
 236:	cmp    al,0x1
 238:	sete   cl
 23b:	test   cl,cl
 23d:	jne    275 <botlish_fn_2+0xa6>
 243:	mov    rax,QWORD PTR [rdi+0x10]
 247:	mov    r12,rdi
 24a:	mov    rcx,QWORD PTR [rax+0x10]
 24e:	xor    rdx,rdx
 251:	mov    rax,QWORD PTR [rip+0x0]        # 258 <botlish_fn_2+0x89>
			254: R_X86_64_GOTPCREL	rt_type_error-0x4
 258:	call   rax
 25a:	mov    rdi,r12
 25d:	mov    QWORD PTR [rdi],rbx
 260:	xor    rax,rax
 263:	mov    rbx,QWORD PTR [rsp]
 267:	mov    r12,QWORD PTR [rsp+0x8]
 26c:	add    rsp,0x10
 270:	mov    rsp,rbp
 273:	pop    rbp
 274:	ret
 275:	mov    r12,rdi
 278:	mov    rax,rsi
 27b:	and    rax,rdx
 27e:	test   rax,0x1
 284:	je     2a7 <botlish_fn_2+0xd8>
 28a:	lea    rcx,[rdx-0x1]
 28e:	mov    rax,rsi
 291:	add    rax,rcx
 294:	seto   cl
 297:	test   cl,cl
 299:	jne    2a7 <botlish_fn_2+0xd8>
 29f:	mov    rdi,r12
 2a2:	jmp    2b6 <botlish_fn_2+0xe7>
 2a7:	mov    rax,QWORD PTR [rip+0x0]        # 2ae <botlish_fn_2+0xdf>
			2aa: R_X86_64_GOTPCREL	rt_int_add-0x4
 2ae:	mov    rdi,r12
 2b1:	call   rax
 2b3:	mov    rdi,r12
 2b6:	mov    rdi,r12
 2b9:	mov    QWORD PTR [rdi],rbx
 2bc:	mov    rbx,QWORD PTR [rsp]
 2c0:	mov    r12,QWORD PTR [rsp+0x8]
 2c5:	add    rsp,0x10
 2c9:	mov    rsp,rbp
 2cc:	pop    rbp
 2cd:	ret
 2ce:	mov    r12,rdi
 2d1:	mov    rax,QWORD PTR [rip+0x0]        # 2d8 <botlish_fn_2+0x109>
			2d4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
 2d8:	call   rax
 2da:	xor    rax,rax
 2dd:	mov    rbx,QWORD PTR [rsp]
 2e1:	mov    r12,QWORD PTR [rsp+0x8]
 2e6:	add    rsp,0x10
 2ea:	mov    rsp,rbp
 2ed:	pop    rbp
 2ee:	ret

00000000000002ef <botlish_entry_2: step<generic>>:
 2ef:	push   rbp
 2f0:	mov    rbp,rsp
 2f3:	mov    rsi,QWORD PTR [rdx]
 2f6:	mov    rdx,QWORD PTR [rdx+0x8]
 2fa:	call   2ff <botlish_entry_2+0x10>
			2fb: R_X86_64_PLT32	botlish_fn_2-0x4 ; step<generic>
 2ff:	mov    rsp,rbp
 302:	pop    rbp
 303:	ret

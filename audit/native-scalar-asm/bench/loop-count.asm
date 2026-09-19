; source:  bench/loop-count.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 731  (per function: 200 54 477)
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
  38:	mov    esi,0x3e9
  3d:	mov    QWORD PTR [rsp],0x3e9
  45:	mov    edx,0x1
  4a:	mov    QWORD PTR [rsp+0x8],0x1
  53:	mov    rdi,r14
  56:	call   5b <botlish_fn_0+0x5b>
			57: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
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

00000000000000c2 <botlish_fn_1: work<int>>:
  c2:	push   rbp
  c3:	mov    rbp,rsp
  c6:	sar    rsi,1
  c9:	imul   rsi,rsi,0x3
  cd:	add    rsi,0x7
  d4:	test   rsi,rsi
  d7:	jl     d4 <botlish_fn_1+0x12>
  dd:	mov    eax,0xf
  e2:	mov    rsp,rbp
  e5:	pop    rbp
  e6:	ret

00000000000000e7 <botlish_entry_1: work<int>>:
  e7:	push   rbp
  e8:	mov    rbp,rsp
  eb:	mov    rsi,QWORD PTR [rdx]
  ee:	call   f3 <botlish_entry_1+0xc>
			ef: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  f3:	mov    rsp,rbp
  f6:	pop    rbp
  f7:	ret

00000000000000f8 <botlish_fn_2: drive<int, int>>:
  f8:	push   rbp
  f9:	mov    rbp,rsp
  fc:	sub    rsp,0x50
 100:	mov    QWORD PTR [rsp+0x20],rbx
 105:	mov    QWORD PTR [rsp+0x28],r12
 10a:	mov    QWORD PTR [rsp+0x30],r13
 10f:	mov    QWORD PTR [rsp+0x38],r14
 114:	mov    QWORD PTR [rsp+0x40],r15
 119:	mov    r13,QWORD PTR [rdi]
 11c:	mov    rax,QWORD PTR [rdi+0x8]
 120:	lea    rcx,[r13+0x8]
 124:	cmp    rcx,rax
 127:	ja     271 <botlish_fn_2+0x179>
 12d:	lea    rax,[r13+0x8]
 131:	mov    QWORD PTR [rdi],rax
 134:	mov    r14,rdi
 137:	mov    QWORD PTR [r13+0x0],0x0
 13f:	mov    QWORD PTR [rsp],rsi
 143:	mov    QWORD PTR [rsp+0x8],rdx
 148:	mov    r12,rsi
 14b:	mov    r15,rdx
 14e:	test   r12,0x1
 155:	jne    180 <botlish_fn_2+0x88>
 15b:	mov    edx,0x1
 160:	mov    rsi,r12
 163:	mov    rdi,r14
 166:	call   16b <botlish_fn_2+0x73>
			167: R_X86_64_PLT32	rt_int_cmp-0x4
 16b:	mov    ecx,0x2
 170:	test   rax,rax
 173:	cmovle rcx,QWORD PTR [rip+0x125]        # 2a0 <botlish_fn_2+0x1a8>
 17b:	jmp    191 <botlish_fn_2+0x99>
 180:	mov    ecx,0x2
 185:	cmp    r12,0x1
 189:	cmovle rcx,QWORD PTR [rip+0x10f]        # 2a0 <botlish_fn_2+0x1a8>
 191:	cmp    rcx,0x6
 195:	je     246 <botlish_fn_2+0x14e>
 19b:	mov    rbx,r12
 19e:	sar    rbx,1
 1a1:	sub    rbx,0x1
 1a5:	shl    rbx,1
 1a8:	or     rbx,0x1
 1ac:	mov    QWORD PTR [rsp+0x10],rbx
 1b1:	mov    rsi,r12
 1b4:	mov    rdi,r14
 1b7:	call   1bc <botlish_fn_2+0xc4>
			1b8: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 1bc:	test   rax,rax
 1bf:	jne    1f0 <botlish_fn_2+0xf8>
 1c5:	mov    rdi,r14
 1c8:	mov    QWORD PTR [rdi],r13
 1cb:	xor    rax,rax
 1ce:	mov    rbx,QWORD PTR [rsp+0x20]
 1d3:	mov    r12,QWORD PTR [rsp+0x28]
 1d8:	mov    r13,QWORD PTR [rsp+0x30]
 1dd:	mov    r14,QWORD PTR [rsp+0x38]
 1e2:	mov    r15,QWORD PTR [rsp+0x40]
 1e7:	add    rsp,0x50
 1eb:	mov    rsp,rbp
 1ee:	pop    rbp
 1ef:	ret
 1f0:	mov    QWORD PTR [rsp],rax
 1f4:	mov    rsi,r15
 1f7:	mov    rcx,rsi
 1fa:	and    rcx,rax
 1fd:	test   rcx,0x1
 204:	jne    212 <botlish_fn_2+0x11a>
 20a:	mov    rdx,rax
 20d:	jmp    22a <botlish_fn_2+0x132>
 212:	lea    rcx,[rax-0x1]
 216:	mov    rdx,rax
 219:	mov    rax,rsi
 21c:	add    rax,rcx
 21f:	seto   cl
 222:	test   cl,cl
 224:	je     232 <botlish_fn_2+0x13a>
 22a:	mov    rdi,r14
 22d:	call   232 <botlish_fn_2+0x13a>
			22e: R_X86_64_PLT32	rt_int_add-0x4
 232:	mov    QWORD PTR [rsp],rbx
 236:	mov    QWORD PTR [rsp+0x8],rax
 23b:	mov    r12,rbx
 23e:	mov    r15,rax
 241:	jmp    14e <botlish_fn_2+0x56>
 246:	mov    rdi,r14
 249:	mov    QWORD PTR [rdi],r13
 24c:	mov    rax,r15
 24f:	mov    rbx,QWORD PTR [rsp+0x20]
 254:	mov    r12,QWORD PTR [rsp+0x28]
 259:	mov    r13,QWORD PTR [rsp+0x30]
 25e:	mov    r14,QWORD PTR [rsp+0x38]
 263:	mov    r15,QWORD PTR [rsp+0x40]
 268:	add    rsp,0x50
 26c:	mov    rsp,rbp
 26f:	pop    rbp
 270:	ret
 271:	mov    r14,rdi
 274:	call   279 <botlish_fn_2+0x181>
			275: R_X86_64_PLT32	rt_stack_overflow-0x4
 279:	xor    rax,rax
 27c:	mov    rbx,QWORD PTR [rsp+0x20]
 281:	mov    r12,QWORD PTR [rsp+0x28]
 286:	mov    r13,QWORD PTR [rsp+0x30]
 28b:	mov    r14,QWORD PTR [rsp+0x38]
 290:	mov    r15,QWORD PTR [rsp+0x40]
 295:	add    rsp,0x50
 299:	mov    rsp,rbp
 29c:	pop    rbp
 29d:	ret
 29e:	add    BYTE PTR [rax],al
 2a0:	(bad)
 2a1:	add    BYTE PTR [rax],al
 2a3:	add    BYTE PTR [rax],al
 2a5:	add    BYTE PTR [rax],al
	...

00000000000002a8 <botlish_entry_2: drive<int, int>>:
 2a8:	push   rbp
 2a9:	mov    rbp,rsp
 2ac:	mov    rsi,QWORD PTR [rdx]
 2af:	mov    rdx,QWORD PTR [rdx+0x8]
 2b3:	call   2b8 <botlish_entry_2+0x10>
			2b4: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 2b8:	mov    rsp,rbp
 2bb:	pop    rbp
 2bc:	ret

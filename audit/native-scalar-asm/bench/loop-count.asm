; source:  bench/loop-count.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 702  (per function: 187 54 461)
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
  1f:	ja     8d <botlish_fn_0+0x8d>
  25:	lea    rax,[r13+0x10]
  29:	mov    QWORD PTR [rdi],rax
  2c:	mov    r14,rdi
  2f:	mov    esi,0x3e9
  34:	mov    QWORD PTR [r13+0x0],0x3e9
  3c:	mov    edx,0x1
  41:	mov    QWORD PTR [r13+0x8],0x1
  49:	mov    rdi,r14
  4c:	call   51 <botlish_fn_0+0x51>
			4d: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
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

00000000000000b5 <botlish_fn_1: work<int>>:
  b5:	push   rbp
  b6:	mov    rbp,rsp
  b9:	sar    rsi,1
  bc:	imul   rsi,rsi,0x3
  c0:	add    rsi,0x7
  c7:	test   rsi,rsi
  ca:	jl     c7 <botlish_fn_1+0x12>
  d0:	mov    eax,0xf
  d5:	mov    rsp,rbp
  d8:	pop    rbp
  d9:	ret

00000000000000da <botlish_entry_1: work<int>>:
  da:	push   rbp
  db:	mov    rbp,rsp
  de:	mov    rsi,QWORD PTR [rdx]
  e1:	call   e6 <botlish_entry_1+0xc>
			e2: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  e6:	mov    rsp,rbp
  e9:	pop    rbp
  ea:	ret
  eb:	add    BYTE PTR [rax],al
  ed:	add    BYTE PTR [rax],al
	...

00000000000000f0 <botlish_fn_2: drive<int, int>>:
  f0:	push   rbp
  f1:	mov    rbp,rsp
  f4:	sub    rsp,0x30
  f8:	mov    QWORD PTR [rsp],rbx
  fc:	mov    QWORD PTR [rsp+0x8],r12
 101:	mov    QWORD PTR [rsp+0x10],r13
 106:	mov    QWORD PTR [rsp+0x18],r14
 10b:	mov    QWORD PTR [rsp+0x20],r15
 110:	mov    r13,QWORD PTR [rdi]
 113:	mov    rax,QWORD PTR [rdi+0x8]
 117:	lea    rcx,[r13+0x18]
 11b:	cmp    rcx,rax
 11e:	ja     25b <botlish_fn_2+0x16b>
 124:	lea    rax,[r13+0x18]
 128:	mov    QWORD PTR [rdi],rax
 12b:	mov    r14,rdi
 12e:	mov    QWORD PTR [r13+0x0],rsi
 132:	mov    QWORD PTR [r13+0x8],rdx
 136:	mov    r12,rsi
 139:	mov    r15,rdx
 13c:	test   r12,0x1
 143:	jne    16e <botlish_fn_2+0x7e>
 149:	mov    edx,0x1
 14e:	mov    rsi,r12
 151:	mov    rdi,r14
 154:	call   159 <botlish_fn_2+0x69>
			155: R_X86_64_PLT32	rt_int_cmp-0x4
 159:	mov    ecx,0x2
 15e:	test   rax,rax
 161:	cmovle rcx,QWORD PTR [rip+0x11f]        # 288 <botlish_fn_2+0x198>
 169:	jmp    17f <botlish_fn_2+0x8f>
 16e:	mov    ecx,0x2
 173:	cmp    r12,0x1
 177:	cmovle rcx,QWORD PTR [rip+0x109]        # 288 <botlish_fn_2+0x198>
 17f:	cmp    rcx,0x6
 183:	je     231 <botlish_fn_2+0x141>
 189:	mov    rbx,r12
 18c:	sar    rbx,1
 18f:	sub    rbx,0x1
 193:	shl    rbx,1
 196:	or     rbx,0x1
 19a:	mov    QWORD PTR [r13+0x10],rbx
 19e:	mov    rsi,r12
 1a1:	mov    rdi,r14
 1a4:	call   1a9 <botlish_fn_2+0xb9>
			1a5: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 1a9:	test   rax,rax
 1ac:	jne    1dc <botlish_fn_2+0xec>
 1b2:	mov    rdi,r14
 1b5:	mov    QWORD PTR [rdi],r13
 1b8:	xor    rax,rax
 1bb:	mov    rbx,QWORD PTR [rsp]
 1bf:	mov    r12,QWORD PTR [rsp+0x8]
 1c4:	mov    r13,QWORD PTR [rsp+0x10]
 1c9:	mov    r14,QWORD PTR [rsp+0x18]
 1ce:	mov    r15,QWORD PTR [rsp+0x20]
 1d3:	add    rsp,0x30
 1d7:	mov    rsp,rbp
 1da:	pop    rbp
 1db:	ret
 1dc:	mov    QWORD PTR [r13+0x0],rax
 1e0:	mov    rsi,r15
 1e3:	mov    rcx,rsi
 1e6:	and    rcx,rax
 1e9:	test   rcx,0x1
 1f0:	jne    1fe <botlish_fn_2+0x10e>
 1f6:	mov    rdx,rax
 1f9:	jmp    216 <botlish_fn_2+0x126>
 1fe:	lea    rcx,[rax-0x1]
 202:	mov    rdx,rax
 205:	mov    rax,rsi
 208:	add    rax,rcx
 20b:	seto   cl
 20e:	test   cl,cl
 210:	je     21e <botlish_fn_2+0x12e>
 216:	mov    rdi,r14
 219:	call   21e <botlish_fn_2+0x12e>
			21a: R_X86_64_PLT32	rt_int_add-0x4
 21e:	mov    QWORD PTR [r13+0x0],rbx
 222:	mov    QWORD PTR [r13+0x8],rax
 226:	mov    r12,rbx
 229:	mov    r15,rax
 22c:	jmp    13c <botlish_fn_2+0x4c>
 231:	mov    rdi,r14
 234:	mov    QWORD PTR [rdi],r13
 237:	mov    rax,r15
 23a:	mov    rbx,QWORD PTR [rsp]
 23e:	mov    r12,QWORD PTR [rsp+0x8]
 243:	mov    r13,QWORD PTR [rsp+0x10]
 248:	mov    r14,QWORD PTR [rsp+0x18]
 24d:	mov    r15,QWORD PTR [rsp+0x20]
 252:	add    rsp,0x30
 256:	mov    rsp,rbp
 259:	pop    rbp
 25a:	ret
 25b:	mov    r14,rdi
 25e:	call   263 <botlish_fn_2+0x173>
			25f: R_X86_64_PLT32	rt_stack_overflow-0x4
 263:	xor    rax,rax
 266:	mov    rbx,QWORD PTR [rsp]
 26a:	mov    r12,QWORD PTR [rsp+0x8]
 26f:	mov    r13,QWORD PTR [rsp+0x10]
 274:	mov    r14,QWORD PTR [rsp+0x18]
 279:	mov    r15,QWORD PTR [rsp+0x20]
 27e:	add    rsp,0x30
 282:	mov    rsp,rbp
 285:	pop    rbp
 286:	ret
 287:	add    BYTE PTR [rsi],al
 289:	add    BYTE PTR [rax],al
 28b:	add    BYTE PTR [rax],al
 28d:	add    BYTE PTR [rax],al
	...

0000000000000290 <botlish_entry_2: drive<int, int>>:
 290:	push   rbp
 291:	mov    rbp,rsp
 294:	mov    rsi,QWORD PTR [rdx]
 297:	mov    rdx,QWORD PTR [rdx+0x8]
 29b:	call   2a0 <botlish_entry_2+0x10>
			29c: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 2a0:	mov    rsp,rbp
 2a3:	pop    rbp
 2a4:	ret

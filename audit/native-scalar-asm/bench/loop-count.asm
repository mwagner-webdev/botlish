; source:  bench/loop-count.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 395  (per function: 63 31 301)
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
  28:	add    rsp,0x10
  2c:	mov    rsp,rbp
  2f:	pop    rbp
  30:	ret

0000000000000031 <botlish_entry_0: <program entry>>:
  31:	push   rbp
  32:	mov    rbp,rsp
  35:	call   3a <botlish_entry_0+0x9>
			36: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  3a:	mov    rsp,rbp
  3d:	pop    rbp
  3e:	ret

000000000000003f <botlish_fn_1: work<int>>:
  3f:	push   rbp
  40:	mov    rbp,rsp
  43:	mov    eax,0xf
  48:	mov    rsp,rbp
  4b:	pop    rbp
  4c:	ret

000000000000004d <botlish_entry_1: work<int>>:
  4d:	push   rbp
  4e:	mov    rbp,rsp
  51:	mov    rsi,QWORD PTR [rdx]
  54:	call   59 <botlish_entry_1+0xc>
			55: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  59:	mov    rsp,rbp
  5c:	pop    rbp
  5d:	ret
	...

0000000000000060 <botlish_fn_2: drive<int, int>>:
  60:	push   rbp
  61:	mov    rbp,rsp
  64:	sub    rsp,0x40
  68:	mov    QWORD PTR [rsp+0x20],rbx
  6d:	mov    QWORD PTR [rsp+0x28],r12
  72:	mov    QWORD PTR [rsp+0x30],r13
  77:	mov    QWORD PTR [rsp+0x38],r14
  7c:	mov    r13,rdi
  7f:	mov    QWORD PTR [rsp],rdx
  83:	mov    rbx,rsi
  86:	mov    r14,rdx
  89:	test   rbx,0x1
  90:	jne    bb <botlish_fn_2+0x5b>
  96:	mov    edx,0x1
  9b:	mov    rsi,rbx
  9e:	mov    rdi,r13
  a1:	call   a6 <botlish_fn_2+0x46>
			a2: R_X86_64_PLT32	rt_int_cmp-0x4
  a6:	mov    ecx,0x2
  ab:	test   rax,rax
  ae:	cmovle rcx,QWORD PTR [rip+0xba]        # 170 <botlish_fn_2+0x110>
  b6:	jmp    cc <botlish_fn_2+0x6c>
  bb:	mov    ecx,0x2
  c0:	cmp    rbx,0x1
  c4:	cmovle rcx,QWORD PTR [rip+0xa4]        # 170 <botlish_fn_2+0x110>
  cc:	cmp    rcx,0x6
  d0:	je     149 <botlish_fn_2+0xe9>
  d6:	mov    r12,rbx
  d9:	sar    r12,1
  dc:	sub    r12,0x1
  e0:	shl    r12,1
  e3:	or     r12,0x1
  e7:	mov    QWORD PTR [rsp+0x8],r12
  ec:	mov    rsi,rbx
  ef:	mov    rdi,r13
  f2:	call   f7 <botlish_fn_2+0x97>
			f3: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  f7:	mov    QWORD PTR [rsp+0x10],0xf
 100:	mov    rsi,r14
 103:	test   rsi,0x1
 10a:	je     12d <botlish_fn_2+0xcd>
 110:	mov    rax,rsi
 113:	add    rax,0xe
 117:	mov    rcx,rax
 11a:	seto   al
 11d:	test   al,al
 11f:	jne    12d <botlish_fn_2+0xcd>
 125:	mov    rax,rcx
 128:	jmp    13a <botlish_fn_2+0xda>
 12d:	mov    edx,0xf
 132:	mov    rdi,r13
 135:	call   13a <botlish_fn_2+0xda>
			136: R_X86_64_PLT32	rt_int_add-0x4
 13a:	mov    QWORD PTR [rsp],rax
 13e:	mov    rbx,r12
 141:	mov    r14,rax
 144:	jmp    89 <botlish_fn_2+0x29>
 149:	mov    rax,r14
 14c:	mov    rbx,QWORD PTR [rsp+0x20]
 151:	mov    r12,QWORD PTR [rsp+0x28]
 156:	mov    r13,QWORD PTR [rsp+0x30]
 15b:	mov    r14,QWORD PTR [rsp+0x38]
 160:	add    rsp,0x40
 164:	mov    rsp,rbp
 167:	pop    rbp
 168:	ret
 169:	add    BYTE PTR [rax],al
 16b:	add    BYTE PTR [rax],al
 16d:	add    BYTE PTR [rax],al
 16f:	add    BYTE PTR [rsi],al
 171:	add    BYTE PTR [rax],al
 173:	add    BYTE PTR [rax],al
 175:	add    BYTE PTR [rax],al
	...

0000000000000178 <botlish_entry_2: drive<int, int>>:
 178:	push   rbp
 179:	mov    rbp,rsp
 17c:	mov    rsi,QWORD PTR [rdx]
 17f:	mov    rdx,QWORD PTR [rdx+0x8]
 183:	call   188 <botlish_entry_2+0x10>
			184: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 188:	mov    rsp,rbp
 18b:	pop    rbp
 18c:	ret

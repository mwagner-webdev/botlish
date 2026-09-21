; source:  bench/loop-count.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 418  (per function: 63 54 301)
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
  43:	sar    rsi,1
  46:	imul   rsi,rsi,0x3
  4a:	add    rsi,0x7
  51:	test   rsi,rsi
  54:	jl     51 <botlish_fn_1+0x12>
  5a:	mov    eax,0xf
  5f:	mov    rsp,rbp
  62:	pop    rbp
  63:	ret

0000000000000064 <botlish_entry_1: work<int>>:
  64:	push   rbp
  65:	mov    rbp,rsp
  68:	mov    rsi,QWORD PTR [rdx]
  6b:	call   70 <botlish_entry_1+0xc>
			6c: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
  70:	mov    rsp,rbp
  73:	pop    rbp
  74:	ret
  75:	add    BYTE PTR [rax],al
	...

0000000000000078 <botlish_fn_2: drive<int, int>>:
  78:	push   rbp
  79:	mov    rbp,rsp
  7c:	sub    rsp,0x40
  80:	mov    QWORD PTR [rsp+0x20],rbx
  85:	mov    QWORD PTR [rsp+0x28],r12
  8a:	mov    QWORD PTR [rsp+0x30],r13
  8f:	mov    QWORD PTR [rsp+0x38],r14
  94:	mov    r13,rdi
  97:	mov    QWORD PTR [rsp],rdx
  9b:	mov    rbx,rsi
  9e:	mov    r14,rdx
  a1:	test   rbx,0x1
  a8:	jne    d3 <botlish_fn_2+0x5b>
  ae:	mov    edx,0x1
  b3:	mov    rsi,rbx
  b6:	mov    rdi,r13
  b9:	call   be <botlish_fn_2+0x46>
			ba: R_X86_64_PLT32	rt_int_cmp-0x4
  be:	mov    ecx,0x2
  c3:	test   rax,rax
  c6:	cmovle rcx,QWORD PTR [rip+0xba]        # 188 <botlish_fn_2+0x110>
  ce:	jmp    e4 <botlish_fn_2+0x6c>
  d3:	mov    ecx,0x2
  d8:	cmp    rbx,0x1
  dc:	cmovle rcx,QWORD PTR [rip+0xa4]        # 188 <botlish_fn_2+0x110>
  e4:	cmp    rcx,0x6
  e8:	je     161 <botlish_fn_2+0xe9>
  ee:	mov    r12,rbx
  f1:	sar    r12,1
  f4:	sub    r12,0x1
  f8:	shl    r12,1
  fb:	or     r12,0x1
  ff:	mov    QWORD PTR [rsp+0x8],r12
 104:	mov    rsi,rbx
 107:	mov    rdi,r13
 10a:	call   10f <botlish_fn_2+0x97>
			10b: R_X86_64_PLT32	botlish_fn_1-0x4 ; work<int>
 10f:	mov    QWORD PTR [rsp+0x10],0xf
 118:	mov    rsi,r14
 11b:	test   rsi,0x1
 122:	je     145 <botlish_fn_2+0xcd>
 128:	mov    rax,rsi
 12b:	add    rax,0xe
 12f:	mov    rcx,rax
 132:	seto   al
 135:	test   al,al
 137:	jne    145 <botlish_fn_2+0xcd>
 13d:	mov    rax,rcx
 140:	jmp    152 <botlish_fn_2+0xda>
 145:	mov    edx,0xf
 14a:	mov    rdi,r13
 14d:	call   152 <botlish_fn_2+0xda>
			14e: R_X86_64_PLT32	rt_int_add-0x4
 152:	mov    QWORD PTR [rsp],rax
 156:	mov    rbx,r12
 159:	mov    r14,rax
 15c:	jmp    a1 <botlish_fn_2+0x29>
 161:	mov    rax,r14
 164:	mov    rbx,QWORD PTR [rsp+0x20]
 169:	mov    r12,QWORD PTR [rsp+0x28]
 16e:	mov    r13,QWORD PTR [rsp+0x30]
 173:	mov    r14,QWORD PTR [rsp+0x38]
 178:	add    rsp,0x40
 17c:	mov    rsp,rbp
 17f:	pop    rbp
 180:	ret
 181:	add    BYTE PTR [rax],al
 183:	add    BYTE PTR [rax],al
 185:	add    BYTE PTR [rax],al
 187:	add    BYTE PTR [rsi],al
 189:	add    BYTE PTR [rax],al
 18b:	add    BYTE PTR [rax],al
 18d:	add    BYTE PTR [rax],al
	...

0000000000000190 <botlish_entry_2: drive<int, int>>:
 190:	push   rbp
 191:	mov    rbp,rsp
 194:	mov    rsi,QWORD PTR [rdx]
 197:	mov    rdx,QWORD PTR [rdx+0x8]
 19b:	call   1a0 <botlish_entry_2+0x10>
			19c: R_X86_64_PLT32	botlish_fn_2-0x4 ; drive<int, int>
 1a0:	mov    rsp,rbp
 1a3:	pop    rbp
 1a4:	ret

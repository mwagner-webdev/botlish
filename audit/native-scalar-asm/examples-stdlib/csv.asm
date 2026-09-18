; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6228  (per function: 176 501 558 698 913 482 783 765 515 556 281)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> peek<str, int>
;   botlish_fn_3 / botlish_entry_3 -> scan_unquoted<str, int, int>
;   botlish_fn_4 / botlish_entry_4 -> scan_quoted<str, int, str>
;   botlish_fn_5 / botlish_entry_5 -> scan_field<str, int>
;   botlish_fn_6 / botlish_entry_6 -> scan_record<str, int, list<never>>
;   botlish_fn_7 / botlish_entry_7 -> scan_record<str, int, list<str>>
;   botlish_fn_8 / botlish_entry_8 -> scan_records<str, int, list<never>>
;   botlish_fn_9 / botlish_entry_9 -> scan_records<str, int, list<list<str>>>
;   botlish_fn_10 / botlish_entry_10 -> csv_parse<str>


csv.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    QWORD PTR [rsp],r14
       c:	mov    QWORD PTR [rsp+0x8],r15
      11:	mov    r14,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r14+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     81 <botlish_fn_0+0x81>
      25:	lea    rax,[r14+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    QWORD PTR [r14],0x0
      33:	mov    rax,QWORD PTR [rdi+0x10]
      37:	mov    r15,rdi
      3a:	mov    rsi,QWORD PTR [rax]
      3d:	mov    QWORD PTR [r14],rsi
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
      45:	test   rax,rax
      48:	jne    69 <botlish_fn_0+0x69>
      4e:	mov    rdi,r15
      51:	mov    QWORD PTR [rdi],r14
      54:	xor    rax,rax
      57:	mov    r14,QWORD PTR [rsp]
      5b:	mov    r15,QWORD PTR [rsp+0x8]
      60:	add    rsp,0x10
      64:	mov    rsp,rbp
      67:	pop    rbp
      68:	ret
      69:	mov    rdi,r15
      6c:	mov    QWORD PTR [rdi],r14
      6f:	mov    r14,QWORD PTR [rsp]
      73:	mov    r15,QWORD PTR [rsp+0x8]
      78:	add    rsp,0x10
      7c:	mov    rsp,rbp
      7f:	pop    rbp
      80:	ret
      81:	mov    rax,QWORD PTR [rip+0x0]        # 88 <botlish_fn_0+0x88>
			84: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      88:	call   rax
      8a:	xor    rax,rax
      8d:	mov    r14,QWORD PTR [rsp]
      91:	mov    r15,QWORD PTR [rsp+0x8]
      96:	add    rsp,0x10
      9a:	mov    rsp,rbp
      9d:	pop    rbp
      9e:	ret

000000000000009f <botlish_entry_0: <program entry>>:
      9f:	push   rbp
      a0:	mov    rbp,rsp
      a3:	call   a8 <botlish_entry_0+0x9>
			a4: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a8:	mov    rsp,rbp
      ab:	pop    rbp
      ac:	ret
      ad:	add    BYTE PTR [rax],al
	...

00000000000000b0 <botlish_fn_1: peek<str, int>>:
      b0:	push   rbp
      b1:	mov    rbp,rsp
      b4:	sub    rsp,0x20
      b8:	mov    QWORD PTR [rsp],rbx
      bc:	mov    QWORD PTR [rsp+0x8],r12
      c1:	mov    QWORD PTR [rsp+0x10],r13
      c6:	mov    QWORD PTR [rsp+0x18],r14
      cb:	mov    r12,QWORD PTR [rdi]
      ce:	mov    rax,QWORD PTR [rdi+0x8]
      d2:	lea    rcx,[r12+0x18]
      d7:	cmp    rcx,rax
      da:	ja     247 <botlish_fn_1+0x197>
      e0:	lea    rax,[r12+0x18]
      e5:	mov    QWORD PTR [rdi],rax
      e8:	mov    r13,rdi
      eb:	mov    QWORD PTR [r12],0x0
      f3:	mov    QWORD PTR [r12+0x8],0x0
      fc:	mov    QWORD PTR [r12+0x10],0x0
     105:	mov    QWORD PTR [r12],rsi
     109:	mov    r14,rsi
     10c:	mov    QWORD PTR [r12+0x8],rdx
     111:	mov    rbx,rdx
     114:	mov    rax,QWORD PTR [rip+0x0]        # 11b <botlish_fn_1+0x6b>
			117: R_X86_64_GOTPCREL	rt_str_len-0x4
     11b:	mov    rsi,r14
     11e:	mov    rdi,r13
     121:	call   rax
     123:	mov    rcx,rbx
     126:	and    rcx,rax
     129:	mov    rdx,rax
     12c:	test   rcx,0x1
     133:	jne    15d <botlish_fn_1+0xad>
     139:	mov    rax,QWORD PTR [rip+0x0]        # 140 <botlish_fn_1+0x90>
			13c: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     140:	mov    rsi,rbx
     143:	mov    rdi,r13
     146:	call   rax
     148:	mov    ecx,0x2
     14d:	test   rax,rax
     150:	cmovge rcx,QWORD PTR [rip+0x120]        # 278 <botlish_fn_1+0x1c8>
     158:	jmp    16d <botlish_fn_1+0xbd>
     15d:	mov    ecx,0x2
     162:	cmp    rbx,rdx
     165:	cmovge rcx,QWORD PTR [rip+0x10b]        # 278 <botlish_fn_1+0x1c8>
     16d:	cmp    rcx,0x6
     171:	je     21d <botlish_fn_1+0x16d>
     177:	mov    QWORD PTR [r12+0x10],0x3
     180:	test   rbx,0x1
     187:	je     19f <botlish_fn_1+0xef>
     18d:	mov    rcx,rbx
     190:	add    rcx,0x2
     194:	seto   al
     197:	test   al,al
     199:	je     1b6 <botlish_fn_1+0x106>
     19f:	mov    edx,0x3
     1a4:	mov    rax,QWORD PTR [rip+0x0]        # 1ab <botlish_fn_1+0xfb>
			1a7: R_X86_64_GOTPCREL	rt_int_add-0x4
     1ab:	mov    rsi,rbx
     1ae:	mov    rdi,r13
     1b1:	call   rax
     1b3:	mov    rcx,rax
     1b6:	mov    QWORD PTR [r12+0x10],rcx
     1bb:	mov    rax,QWORD PTR [rip+0x0]        # 1c2 <botlish_fn_1+0x112>
			1be: R_X86_64_GOTPCREL	rt_substr-0x4
     1c2:	mov    rdx,rbx
     1c5:	mov    rsi,r14
     1c8:	mov    rdi,r13
     1cb:	call   rax
     1cd:	test   rax,rax
     1d0:	jne    1fb <botlish_fn_1+0x14b>
     1d6:	mov    rdi,r13
     1d9:	mov    QWORD PTR [rdi],r12
     1dc:	xor    rax,rax
     1df:	mov    rbx,QWORD PTR [rsp]
     1e3:	mov    r12,QWORD PTR [rsp+0x8]
     1e8:	mov    r13,QWORD PTR [rsp+0x10]
     1ed:	mov    r14,QWORD PTR [rsp+0x18]
     1f2:	add    rsp,0x20
     1f6:	mov    rsp,rbp
     1f9:	pop    rbp
     1fa:	ret
     1fb:	mov    rdi,r13
     1fe:	mov    QWORD PTR [rdi],r12
     201:	mov    rbx,QWORD PTR [rsp]
     205:	mov    r12,QWORD PTR [rsp+0x8]
     20a:	mov    r13,QWORD PTR [rsp+0x10]
     20f:	mov    r14,QWORD PTR [rsp+0x18]
     214:	add    rsp,0x20
     218:	mov    rsp,rbp
     21b:	pop    rbp
     21c:	ret
     21d:	mov    rdi,r13
     220:	mov    rsi,QWORD PTR [rdi+0x10]
     224:	mov    rax,QWORD PTR [rsi+0x8]
     228:	mov    QWORD PTR [rdi],r12
     22b:	mov    rbx,QWORD PTR [rsp]
     22f:	mov    r12,QWORD PTR [rsp+0x8]
     234:	mov    r13,QWORD PTR [rsp+0x10]
     239:	mov    r14,QWORD PTR [rsp+0x18]
     23e:	add    rsp,0x20
     242:	mov    rsp,rbp
     245:	pop    rbp
     246:	ret
     247:	mov    r13,rdi
     24a:	mov    rsi,QWORD PTR [rip+0x0]        # 251 <botlish_fn_1+0x1a1>
			24d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     251:	call   rsi
     253:	xor    rax,rax
     256:	mov    rbx,QWORD PTR [rsp]
     25a:	mov    r12,QWORD PTR [rsp+0x8]
     25f:	mov    r13,QWORD PTR [rsp+0x10]
     264:	mov    r14,QWORD PTR [rsp+0x18]
     269:	add    rsp,0x20
     26d:	mov    rsp,rbp
     270:	pop    rbp
     271:	ret
     272:	add    BYTE PTR [rax],al
     274:	add    BYTE PTR [rax],al
     276:	add    BYTE PTR [rax],al
     278:	(bad)
     279:	add    BYTE PTR [rax],al
     27b:	add    BYTE PTR [rax],al
     27d:	add    BYTE PTR [rax],al
	...

0000000000000280 <botlish_entry_1: peek<str, int>>:
     280:	push   rbp
     281:	mov    rbp,rsp
     284:	mov    rsi,QWORD PTR [rdx]
     287:	mov    rdx,QWORD PTR [rdx+0x8]
     28b:	call   290 <botlish_entry_1+0x10>
			28c: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     290:	mov    rsp,rbp
     293:	pop    rbp
     294:	ret
     295:	add    BYTE PTR [rax],al
	...

0000000000000298 <botlish_fn_2: peek<str, int>>:
     298:	push   rbp
     299:	mov    rbp,rsp
     29c:	sub    rsp,0x40
     2a0:	mov    QWORD PTR [rsp+0x10],rbx
     2a5:	mov    QWORD PTR [rsp+0x18],r12
     2aa:	mov    QWORD PTR [rsp+0x20],r13
     2af:	mov    QWORD PTR [rsp+0x28],r14
     2b4:	mov    QWORD PTR [rsp+0x30],r15
     2b9:	mov    r13,rcx
     2bc:	mov    r12,QWORD PTR [rdi]
     2bf:	mov    rax,QWORD PTR [rdi+0x8]
     2c3:	lea    rcx,[r12+0x18]
     2c8:	cmp    rcx,rax
     2cb:	ja     477 <botlish_fn_2+0x1df>
     2d1:	lea    rax,[r12+0x18]
     2d6:	mov    QWORD PTR [rdi],rax
     2d9:	mov    r15,rdi
     2dc:	mov    QWORD PTR [r12],0x0
     2e4:	mov    QWORD PTR [r12+0x8],0x0
     2ed:	mov    QWORD PTR [r12+0x10],0x0
     2f6:	mov    QWORD PTR [r12],rsi
     2fa:	mov    r14,rsi
     2fd:	mov    QWORD PTR [r12+0x8],rdx
     302:	mov    rbx,rdx
     305:	mov    rax,QWORD PTR [rip+0x0]        # 30c <botlish_fn_2+0x74>
			308: R_X86_64_GOTPCREL	rt_str_len-0x4
     30c:	mov    rsi,r14
     30f:	mov    rdi,r15
     312:	call   rax
     314:	mov    rcx,rbx
     317:	and    rcx,rax
     31a:	mov    rdx,rax
     31d:	test   rcx,0x1
     324:	jne    34e <botlish_fn_2+0xb6>
     32a:	mov    rax,QWORD PTR [rip+0x0]        # 331 <botlish_fn_2+0x99>
			32d: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     331:	mov    rsi,rbx
     334:	mov    rdi,r15
     337:	call   rax
     339:	mov    ecx,0x2
     33e:	test   rax,rax
     341:	cmovge rcx,QWORD PTR [rip+0x167]        # 4b0 <botlish_fn_2+0x218>
     349:	jmp    35e <botlish_fn_2+0xc6>
     34e:	mov    ecx,0x2
     353:	cmp    rbx,rdx
     356:	cmovge rcx,QWORD PTR [rip+0x152]        # 4b0 <botlish_fn_2+0x218>
     35e:	cmp    rcx,0x6
     362:	je     435 <botlish_fn_2+0x19d>
     368:	mov    QWORD PTR [r12+0x10],0x3
     371:	test   rbx,0x1
     378:	je     399 <botlish_fn_2+0x101>
     37e:	mov    rax,rbx
     381:	add    rax,0x2
     385:	seto   cl
     388:	test   cl,cl
     38a:	jne    399 <botlish_fn_2+0x101>
     390:	mov    QWORD PTR [rsp],rax
     394:	jmp    3b1 <botlish_fn_2+0x119>
     399:	mov    edx,0x3
     39e:	mov    rax,QWORD PTR [rip+0x0]        # 3a5 <botlish_fn_2+0x10d>
			3a1: R_X86_64_GOTPCREL	rt_int_add-0x4
     3a5:	mov    rsi,rbx
     3a8:	mov    rdi,r15
     3ab:	call   rax
     3ad:	mov    QWORD PTR [rsp],rax
     3b1:	mov    r8,QWORD PTR [rip+0x0]        # 3b8 <botlish_fn_2+0x120>
			3b4: R_X86_64_GOTPCREL	rt_str_region_check-0x4
     3b8:	mov    rcx,QWORD PTR [rsp]
     3bc:	mov    rdx,rbx
     3bf:	mov    rsi,r14
     3c2:	mov    rdi,r15
     3c5:	call   r8
     3c8:	test   rax,rax
     3cb:	jne    3fc <botlish_fn_2+0x164>
     3d1:	mov    rdi,r15
     3d4:	mov    QWORD PTR [rdi],r12
     3d7:	xor    rax,rax
     3da:	mov    rbx,QWORD PTR [rsp+0x10]
     3df:	mov    r12,QWORD PTR [rsp+0x18]
     3e4:	mov    r13,QWORD PTR [rsp+0x20]
     3e9:	mov    r14,QWORD PTR [rsp+0x28]
     3ee:	mov    r15,QWORD PTR [rsp+0x30]
     3f3:	add    rsp,0x40
     3f7:	mov    rsp,rbp
     3fa:	pop    rbp
     3fb:	ret
     3fc:	mov    rdi,r15
     3ff:	mov    QWORD PTR [rdi],r12
     402:	mov    rcx,r13
     405:	mov    QWORD PTR [rcx],rbx
     408:	mov    rax,QWORD PTR [rsp]
     40c:	mov    QWORD PTR [rcx+0x8],rax
     410:	mov    rax,r14
     413:	mov    rbx,QWORD PTR [rsp+0x10]
     418:	mov    r12,QWORD PTR [rsp+0x18]
     41d:	mov    r13,QWORD PTR [rsp+0x20]
     422:	mov    r14,QWORD PTR [rsp+0x28]
     427:	mov    r15,QWORD PTR [rsp+0x30]
     42c:	add    rsp,0x40
     430:	mov    rsp,rbp
     433:	pop    rbp
     434:	ret
     435:	mov    rcx,r13
     438:	mov    rdi,r15
     43b:	mov    rsi,QWORD PTR [rdi+0x10]
     43f:	mov    rax,QWORD PTR [rsi+0x8]
     443:	mov    QWORD PTR [rdi],r12
     446:	mov    QWORD PTR [rcx],0x1
     44d:	mov    QWORD PTR [rcx+0x8],0x1
     455:	mov    rbx,QWORD PTR [rsp+0x10]
     45a:	mov    r12,QWORD PTR [rsp+0x18]
     45f:	mov    r13,QWORD PTR [rsp+0x20]
     464:	mov    r14,QWORD PTR [rsp+0x28]
     469:	mov    r15,QWORD PTR [rsp+0x30]
     46e:	add    rsp,0x40
     472:	mov    rsp,rbp
     475:	pop    rbp
     476:	ret
     477:	mov    r15,rdi
     47a:	mov    r10,QWORD PTR [rip+0x0]        # 481 <botlish_fn_2+0x1e9>
			47d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     481:	call   r10
     484:	xor    rax,rax
     487:	mov    rbx,QWORD PTR [rsp+0x10]
     48c:	mov    r12,QWORD PTR [rsp+0x18]
     491:	mov    r13,QWORD PTR [rsp+0x20]
     496:	mov    r14,QWORD PTR [rsp+0x28]
     49b:	mov    r15,QWORD PTR [rsp+0x30]
     4a0:	add    rsp,0x40
     4a4:	mov    rsp,rbp
     4a7:	pop    rbp
     4a8:	ret
     4a9:	add    BYTE PTR [rax],al
     4ab:	add    BYTE PTR [rax],al
     4ad:	add    BYTE PTR [rax],al
     4af:	add    BYTE PTR [rsi],al
     4b1:	add    BYTE PTR [rax],al
     4b3:	add    BYTE PTR [rax],al
     4b5:	add    BYTE PTR [rax],al
	...

00000000000004b8 <botlish_entry_2: peek<str, int>>:
     4b8:	push   rbp
     4b9:	mov    rbp,rsp
     4bc:	ud2

00000000000004be <botlish_fn_3: scan_unquoted<str, int, int>>:
     4be:	push   rbp
     4bf:	mov    rbp,rsp
     4c2:	sub    rsp,0x60
     4c6:	mov    QWORD PTR [rsp+0x30],rbx
     4cb:	mov    QWORD PTR [rsp+0x38],r12
     4d0:	mov    QWORD PTR [rsp+0x40],r13
     4d5:	mov    QWORD PTR [rsp+0x48],r14
     4da:	mov    QWORD PTR [rsp+0x50],r15
     4df:	mov    r14,QWORD PTR [rdi]
     4e2:	mov    rax,QWORD PTR [rdi+0x8]
     4e6:	lea    r8,[r14+0x20]
     4ea:	cmp    r8,rax
     4ed:	ja     72c <botlish_fn_3+0x26e>
     4f3:	lea    rax,[r14+0x20]
     4f7:	mov    QWORD PTR [rdi],rax
     4fa:	mov    r15,rdi
     4fd:	mov    QWORD PTR [r14],0x0
     504:	mov    QWORD PTR [r14+0x8],0x0
     50c:	mov    QWORD PTR [r14+0x10],0x0
     514:	mov    QWORD PTR [r14+0x18],0x0
     51c:	mov    QWORD PTR [r14],rsi
     51f:	mov    QWORD PTR [rsp+0x10],rsi
     524:	mov    QWORD PTR [r14+0x8],rdx
     528:	mov    QWORD PTR [rsp+0x18],rdx
     52d:	mov    QWORD PTR [r14+0x10],rcx
     531:	lea    rbx,[rsp]
     535:	mov    QWORD PTR [rsp+0x20],rcx
     53a:	mov    rcx,rbx
     53d:	mov    rdx,QWORD PTR [rsp+0x20]
     542:	mov    rsi,QWORD PTR [rsp+0x10]
     547:	mov    rdi,r15
     54a:	call   54f <botlish_fn_3+0x91>
			54b: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     54f:	mov    rcx,rax
     552:	mov    QWORD PTR [rsp+0x28],rax
     557:	test   rax,rcx
     55a:	jne    568 <botlish_fn_3+0xaa>
     560:	mov    rdi,r15
     563:	jmp    6d1 <botlish_fn_3+0x213>
     568:	mov    r12,QWORD PTR [rsp]
     56c:	mov    r13,QWORD PTR [rsp+0x8]
     571:	mov    rdi,r15
     574:	mov    rcx,QWORD PTR [rdi+0x10]
     578:	mov    r8,QWORD PTR [rcx+0x8]
     57c:	mov    r9,QWORD PTR [rip+0x0]        # 583 <botlish_fn_3+0xc5>
			57f: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     583:	mov    rcx,r13
     586:	mov    rdx,r12
     589:	mov    rsi,QWORD PTR [rsp+0x28]
     58e:	call   r9
     591:	cmp    rax,0x6
     595:	je     5d9 <botlish_fn_3+0x11b>
     59b:	mov    rdi,r15
     59e:	mov    rdx,QWORD PTR [rdi+0x10]
     5a2:	mov    r8,QWORD PTR [rdx+0x10]
     5a6:	mov    r9,QWORD PTR [rip+0x0]        # 5ad <botlish_fn_3+0xef>
			5a9: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     5ad:	mov    rcx,r13
     5b0:	mov    rdx,r12
     5b3:	mov    rsi,QWORD PTR [rsp+0x28]
     5b8:	call   r9
     5bb:	cmp    rax,0x6
     5bf:	je     5cf <botlish_fn_3+0x111>
     5c5:	mov    eax,0x2
     5ca:	jmp    5de <botlish_fn_3+0x120>
     5cf:	mov    eax,0x6
     5d4:	jmp    5de <botlish_fn_3+0x120>
     5d9:	mov    eax,0x6
     5de:	cmp    rax,0x6
     5e2:	je     626 <botlish_fn_3+0x168>
     5e8:	mov    rdi,r15
     5eb:	mov    r10,QWORD PTR [rdi+0x10]
     5ef:	mov    r8,QWORD PTR [r10+0x18]
     5f3:	mov    r10,QWORD PTR [rip+0x0]        # 5fa <botlish_fn_3+0x13c>
			5f6: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     5fa:	mov    rcx,r13
     5fd:	mov    rdx,r12
     600:	mov    rsi,QWORD PTR [rsp+0x28]
     605:	call   r10
     608:	cmp    rax,0x6
     60c:	je     61c <botlish_fn_3+0x15e>
     612:	mov    eax,0x2
     617:	jmp    62b <botlish_fn_3+0x16d>
     61c:	mov    eax,0x6
     621:	jmp    62b <botlish_fn_3+0x16d>
     626:	mov    eax,0x6
     62b:	cmp    rax,0x6
     62f:	je     6aa <botlish_fn_3+0x1ec>
     635:	mov    QWORD PTR [r14+0x18],0x3
     63d:	mov    rsi,QWORD PTR [rsp+0x20]
     642:	test   rsi,0x1
     649:	je     670 <botlish_fn_3+0x1b2>
     64f:	mov    rsi,QWORD PTR [rsp+0x20]
     654:	mov    rax,rsi
     657:	add    rax,0x2
     65b:	seto   cl
     65e:	test   cl,cl
     660:	jne    670 <botlish_fn_3+0x1b2>
     666:	mov    rsi,QWORD PTR [rsp+0x10]
     66b:	jmp    68b <botlish_fn_3+0x1cd>
     670:	mov    edx,0x3
     675:	mov    rax,QWORD PTR [rip+0x0]        # 67c <botlish_fn_3+0x1be>
			678: R_X86_64_GOTPCREL	rt_int_add-0x4
     67c:	mov    rsi,QWORD PTR [rsp+0x20]
     681:	mov    rdi,r15
     684:	call   rax
     686:	mov    rsi,QWORD PTR [rsp+0x10]
     68b:	mov    QWORD PTR [r14],rsi
     68e:	mov    rdx,QWORD PTR [rsp+0x18]
     693:	mov    QWORD PTR [r14+0x8],rdx
     697:	mov    QWORD PTR [r14+0x10],rax
     69b:	mov    QWORD PTR [rsp+0x10],rsi
     6a0:	mov    QWORD PTR [rsp+0x20],rax
     6a5:	jmp    53a <botlish_fn_3+0x7c>
     6aa:	mov    rdx,QWORD PTR [rsp+0x18]
     6af:	mov    rsi,QWORD PTR [rsp+0x10]
     6b4:	mov    rax,QWORD PTR [rip+0x0]        # 6bb <botlish_fn_3+0x1fd>
			6b7: R_X86_64_GOTPCREL	rt_substr-0x4
     6bb:	mov    rcx,QWORD PTR [rsp+0x20]
     6c0:	mov    rdi,r15
     6c3:	call   rax
     6c5:	test   rax,rax
     6c8:	jne    6ff <botlish_fn_3+0x241>
     6ce:	mov    rdi,r15
     6d1:	mov    rdi,r15
     6d4:	mov    QWORD PTR [rdi],r14
     6d7:	xor    rdx,rdx
     6da:	mov    rax,rdx
     6dd:	mov    rbx,QWORD PTR [rsp+0x30]
     6e2:	mov    r12,QWORD PTR [rsp+0x38]
     6e7:	mov    r13,QWORD PTR [rsp+0x40]
     6ec:	mov    r14,QWORD PTR [rsp+0x48]
     6f1:	mov    r15,QWORD PTR [rsp+0x50]
     6f6:	add    rsp,0x60
     6fa:	mov    rsp,rbp
     6fd:	pop    rbp
     6fe:	ret
     6ff:	mov    rdi,r15
     702:	mov    QWORD PTR [rdi],r14
     705:	mov    rdx,QWORD PTR [rsp+0x20]
     70a:	mov    rbx,QWORD PTR [rsp+0x30]
     70f:	mov    r12,QWORD PTR [rsp+0x38]
     714:	mov    r13,QWORD PTR [rsp+0x40]
     719:	mov    r14,QWORD PTR [rsp+0x48]
     71e:	mov    r15,QWORD PTR [rsp+0x50]
     723:	add    rsp,0x60
     727:	mov    rsp,rbp
     72a:	pop    rbp
     72b:	ret
     72c:	mov    r15,rdi
     72f:	mov    rax,QWORD PTR [rip+0x0]        # 736 <botlish_fn_3+0x278>
			732: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     736:	call   rax
     738:	xor    rdx,rdx
     73b:	mov    rax,rdx
     73e:	mov    rbx,QWORD PTR [rsp+0x30]
     743:	mov    r12,QWORD PTR [rsp+0x38]
     748:	mov    r13,QWORD PTR [rsp+0x40]
     74d:	mov    r14,QWORD PTR [rsp+0x48]
     752:	mov    r15,QWORD PTR [rsp+0x50]
     757:	add    rsp,0x60
     75b:	mov    rsp,rbp
     75e:	pop    rbp
     75f:	ret

0000000000000760 <botlish_entry_3: scan_unquoted<str, int, int>>:
     760:	push   rbp
     761:	mov    rbp,rsp
     764:	ud2

0000000000000766 <botlish_fn_4: scan_quoted<str, int, str>>:
     766:	push   rbp
     767:	mov    rbp,rsp
     76a:	sub    rsp,0x50
     76e:	mov    QWORD PTR [rsp+0x20],rbx
     773:	mov    QWORD PTR [rsp+0x28],r12
     778:	mov    QWORD PTR [rsp+0x30],r13
     77d:	mov    QWORD PTR [rsp+0x38],r14
     782:	mov    QWORD PTR [rsp+0x40],r15
     787:	mov    r13,QWORD PTR [rdi]
     78a:	mov    rax,QWORD PTR [rdi+0x8]
     78e:	lea    r8,[r13+0x28]
     792:	cmp    r8,rax
     795:	ja     aa2 <botlish_fn_4+0x33c>
     79b:	lea    rax,[r13+0x28]
     79f:	mov    QWORD PTR [rdi],rax
     7a2:	mov    r14,rdi
     7a5:	mov    QWORD PTR [r13+0x0],0x0
     7ad:	mov    QWORD PTR [r13+0x8],0x0
     7b5:	mov    QWORD PTR [r13+0x10],0x0
     7bd:	mov    QWORD PTR [r13+0x18],0x0
     7c5:	mov    QWORD PTR [r13+0x20],0x0
     7cd:	mov    QWORD PTR [r13+0x0],rsi
     7d1:	mov    QWORD PTR [r13+0x8],rdx
     7d5:	mov    QWORD PTR [r13+0x10],rcx
     7d9:	lea    r12,[rsp]
     7dd:	mov    rbx,rsi
     7e0:	mov    r15,rdx
     7e3:	mov    QWORD PTR [rsp+0x10],rcx
     7e8:	mov    rdx,r15
     7eb:	mov    rsi,rbx
     7ee:	mov    rdi,r14
     7f1:	call   7f6 <botlish_fn_4+0x90>
			7f2: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     7f6:	test   rax,rax
     7f9:	jne    807 <botlish_fn_4+0xa1>
     7ff:	mov    rdi,r14
     802:	jmp    a5b <botlish_fn_4+0x2f5>
     807:	mov    QWORD PTR [r13+0x18],rax
     80b:	mov    rdi,r14
     80e:	mov    QWORD PTR [rsp+0x18],rax
     813:	mov    rcx,QWORD PTR [rdi+0x10]
     817:	mov    rsi,QWORD PTR [rcx+0x20]
     81b:	mov    edx,0x1
     820:	mov    ecx,0x3
     825:	mov    r9,QWORD PTR [rip+0x0]        # 82c <botlish_fn_4+0xc6>
			828: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     82c:	mov    r8,QWORD PTR [rsp+0x18]
     831:	call   r9
     834:	cmp    rax,0x6
     838:	je     8cb <botlish_fn_4+0x165>
     83e:	mov    QWORD PTR [r13+0x20],0x3
     846:	mov    rsi,r15
     849:	test   rsi,0x1
     850:	je     870 <botlish_fn_4+0x10a>
     856:	mov    rax,rsi
     859:	add    rax,0x2
     85d:	seto   cl
     860:	test   cl,cl
     862:	jne    870 <botlish_fn_4+0x10a>
     868:	mov    rsi,rax
     86b:	jmp    884 <botlish_fn_4+0x11e>
     870:	mov    edx,0x3
     875:	mov    rax,QWORD PTR [rip+0x0]        # 87c <botlish_fn_4+0x116>
			878: R_X86_64_GOTPCREL	rt_int_add-0x4
     87c:	mov    rdi,r14
     87f:	call   rax
     881:	mov    rsi,rax
     884:	mov    QWORD PTR [r13+0x8],rsi
     888:	mov    r15,rsi
     88b:	mov    rax,QWORD PTR [rip+0x0]        # 892 <botlish_fn_4+0x12c>
			88e: R_X86_64_GOTPCREL	rt_str_cat-0x4
     892:	mov    rdx,QWORD PTR [rsp+0x18]
     897:	mov    rsi,QWORD PTR [rsp+0x10]
     89c:	mov    rdi,r14
     89f:	call   rax
     8a1:	test   rax,rax
     8a4:	jne    8b2 <botlish_fn_4+0x14c>
     8aa:	mov    rdi,r14
     8ad:	jmp    a5b <botlish_fn_4+0x2f5>
     8b2:	mov    QWORD PTR [r13+0x0],rbx
     8b6:	mov    rsi,r15
     8b9:	mov    QWORD PTR [r13+0x8],rsi
     8bd:	mov    QWORD PTR [r13+0x10],rax
     8c1:	mov    QWORD PTR [rsp+0x10],rax
     8c6:	jmp    7e8 <botlish_fn_4+0x82>
     8cb:	mov    QWORD PTR [r13+0x18],0x3
     8d3:	mov    rsi,r15
     8d6:	test   rsi,0x1
     8dd:	je     8f8 <botlish_fn_4+0x192>
     8e3:	mov    rsi,r15
     8e6:	mov    rdx,rsi
     8e9:	add    rdx,0x2
     8ed:	seto   al
     8f0:	test   al,al
     8f2:	je     90f <botlish_fn_4+0x1a9>
     8f8:	mov    edx,0x3
     8fd:	mov    rax,QWORD PTR [rip+0x0]        # 904 <botlish_fn_4+0x19e>
			900: R_X86_64_GOTPCREL	rt_int_add-0x4
     904:	mov    rsi,r15
     907:	mov    rdi,r14
     90a:	call   rax
     90c:	mov    rdx,rax
     90f:	mov    QWORD PTR [r13+0x18],rdx
     913:	mov    rcx,r12
     916:	mov    rsi,rbx
     919:	mov    rdi,r14
     91c:	call   921 <botlish_fn_4+0x1bb>
			91d: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     921:	test   rax,rax
     924:	mov    rsi,rax
     927:	jne    935 <botlish_fn_4+0x1cf>
     92d:	mov    rdi,r14
     930:	jmp    a5b <botlish_fn_4+0x2f5>
     935:	mov    rdx,QWORD PTR [rsp]
     939:	mov    rcx,QWORD PTR [rsp+0x8]
     93e:	mov    rdi,r14
     941:	mov    rax,QWORD PTR [rdi+0x10]
     945:	mov    r8,QWORD PTR [rax+0x20]
     949:	mov    rax,QWORD PTR [rip+0x0]        # 950 <botlish_fn_4+0x1ea>
			94c: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     950:	call   rax
     952:	cmp    rax,0x6
     956:	je     9d8 <botlish_fn_4+0x272>
     95c:	mov    QWORD PTR [r13+0x0],0x3
     964:	mov    rsi,r15
     967:	test   rsi,0x1
     96e:	je     991 <botlish_fn_4+0x22b>
     974:	mov    rsi,r15
     977:	mov    rdx,rsi
     97a:	add    rdx,0x2
     97e:	seto   al
     981:	test   al,al
     983:	jne    991 <botlish_fn_4+0x22b>
     989:	mov    rdi,r14
     98c:	jmp    9ab <botlish_fn_4+0x245>
     991:	mov    edx,0x3
     996:	mov    rax,QWORD PTR [rip+0x0]        # 99d <botlish_fn_4+0x237>
			999: R_X86_64_GOTPCREL	rt_int_add-0x4
     99d:	mov    rsi,r15
     9a0:	mov    rdi,r14
     9a3:	call   rax
     9a5:	mov    rdx,rax
     9a8:	mov    rdi,r14
     9ab:	mov    rdi,r14
     9ae:	mov    QWORD PTR [rdi],r13
     9b1:	mov    rax,QWORD PTR [rsp+0x10]
     9b6:	mov    rbx,QWORD PTR [rsp+0x20]
     9bb:	mov    r12,QWORD PTR [rsp+0x28]
     9c0:	mov    r13,QWORD PTR [rsp+0x30]
     9c5:	mov    r14,QWORD PTR [rsp+0x38]
     9ca:	mov    r15,QWORD PTR [rsp+0x40]
     9cf:	add    rsp,0x50
     9d3:	mov    rsp,rbp
     9d6:	pop    rbp
     9d7:	ret
     9d8:	mov    QWORD PTR [r13+0x18],0x5
     9e0:	mov    rsi,r15
     9e3:	test   rsi,0x1
     9ea:	je     a12 <botlish_fn_4+0x2ac>
     9f0:	mov    rsi,r15
     9f3:	mov    rcx,rsi
     9f6:	add    rcx,0x4
     9fa:	seto   sil
     9fe:	test   sil,sil
     a01:	jne    a12 <botlish_fn_4+0x2ac>
     a07:	mov    rsi,rcx
     a0a:	mov    r15,rcx
     a0d:	jmp    a2d <botlish_fn_4+0x2c7>
     a12:	mov    edx,0x5
     a17:	mov    r8,QWORD PTR [rip+0x0]        # a1e <botlish_fn_4+0x2b8>
			a1a: R_X86_64_GOTPCREL	rt_int_add-0x4
     a1e:	mov    rsi,r15
     a21:	mov    rdi,r14
     a24:	call   r8
     a27:	mov    rsi,rax
     a2a:	mov    r15,rax
     a2d:	mov    QWORD PTR [r13+0x8],rsi
     a31:	mov    rdi,r14
     a34:	mov    r8,QWORD PTR [rdi+0x10]
     a38:	mov    rdx,QWORD PTR [r8+0x20]
     a3c:	mov    QWORD PTR [r13+0x18],rdx
     a40:	mov    r9,QWORD PTR [rip+0x0]        # a47 <botlish_fn_4+0x2e1>
			a43: R_X86_64_GOTPCREL	rt_str_cat-0x4
     a47:	mov    rsi,QWORD PTR [rsp+0x10]
     a4c:	call   r9
     a4f:	test   rax,rax
     a52:	jne    a89 <botlish_fn_4+0x323>
     a58:	mov    rdi,r14
     a5b:	mov    rdi,r14
     a5e:	mov    QWORD PTR [rdi],r13
     a61:	xor    rdx,rdx
     a64:	mov    rax,rdx
     a67:	mov    rbx,QWORD PTR [rsp+0x20]
     a6c:	mov    r12,QWORD PTR [rsp+0x28]
     a71:	mov    r13,QWORD PTR [rsp+0x30]
     a76:	mov    r14,QWORD PTR [rsp+0x38]
     a7b:	mov    r15,QWORD PTR [rsp+0x40]
     a80:	add    rsp,0x50
     a84:	mov    rsp,rbp
     a87:	pop    rbp
     a88:	ret
     a89:	mov    QWORD PTR [r13+0x0],rbx
     a8d:	mov    rsi,r15
     a90:	mov    QWORD PTR [r13+0x8],rsi
     a94:	mov    QWORD PTR [r13+0x10],rax
     a98:	mov    QWORD PTR [rsp+0x10],rax
     a9d:	jmp    7e8 <botlish_fn_4+0x82>
     aa2:	mov    r14,rdi
     aa5:	mov    rax,QWORD PTR [rip+0x0]        # aac <botlish_fn_4+0x346>
			aa8: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     aac:	call   rax
     aae:	xor    rdx,rdx
     ab1:	mov    rax,rdx
     ab4:	mov    rbx,QWORD PTR [rsp+0x20]
     ab9:	mov    r12,QWORD PTR [rsp+0x28]
     abe:	mov    r13,QWORD PTR [rsp+0x30]
     ac3:	mov    r14,QWORD PTR [rsp+0x38]
     ac8:	mov    r15,QWORD PTR [rsp+0x40]
     acd:	add    rsp,0x50
     ad1:	mov    rsp,rbp
     ad4:	pop    rbp
     ad5:	ret

0000000000000ad6 <botlish_entry_4: scan_quoted<str, int, str>>:
     ad6:	push   rbp
     ad7:	mov    rbp,rsp
     ada:	ud2

0000000000000adc <botlish_fn_5: scan_field<str, int>>:
     adc:	push   rbp
     add:	mov    rbp,rsp
     ae0:	sub    rsp,0x30
     ae4:	mov    QWORD PTR [rsp+0x10],rbx
     ae9:	mov    QWORD PTR [rsp+0x18],r12
     aee:	mov    QWORD PTR [rsp+0x20],r13
     af3:	mov    QWORD PTR [rsp+0x28],r14
     af8:	mov    rbx,QWORD PTR [rdi]
     afb:	mov    rax,QWORD PTR [rdi+0x8]
     aff:	lea    rcx,[rbx+0x18]
     b03:	cmp    rcx,rax
     b06:	ja     c80 <botlish_fn_5+0x1a4>
     b0c:	lea    rax,[rbx+0x18]
     b10:	mov    QWORD PTR [rdi],rax
     b13:	mov    r12,rdi
     b16:	mov    QWORD PTR [rbx],0x0
     b1d:	mov    QWORD PTR [rbx+0x8],0x0
     b25:	mov    QWORD PTR [rbx+0x10],0x0
     b2d:	mov    QWORD PTR [rbx],rsi
     b30:	mov    r13,rsi
     b33:	mov    QWORD PTR [rbx+0x8],rdx
     b37:	mov    r14,rdx
     b3a:	lea    rcx,[rsp]
     b3e:	mov    rdx,r14
     b41:	mov    rsi,r13
     b44:	mov    rdi,r12
     b47:	call   b4c <botlish_fn_5+0x70>
			b48: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     b4c:	test   rax,rax
     b4f:	mov    rsi,rax
     b52:	jne    b60 <botlish_fn_5+0x84>
     b58:	mov    rdi,r12
     b5b:	jmp    c34 <botlish_fn_5+0x158>
     b60:	mov    rdx,QWORD PTR [rsp]
     b64:	mov    rcx,QWORD PTR [rsp+0x8]
     b69:	mov    rdi,r12
     b6c:	mov    rax,QWORD PTR [rdi+0x10]
     b70:	mov    r8,QWORD PTR [rax+0x20]
     b74:	mov    rax,QWORD PTR [rip+0x0]        # b7b <botlish_fn_5+0x9f>
			b77: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     b7b:	call   rax
     b7d:	cmp    rax,0x6
     b81:	je     bcc <botlish_fn_5+0xf0>
     b87:	mov    rcx,r14
     b8a:	mov    rsi,r13
     b8d:	mov    rdi,r12
     b90:	mov    rdx,rcx
     b93:	call   b98 <botlish_fn_5+0xbc>
			b94: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     b98:	test   rax,rax
     b9b:	jne    ba9 <botlish_fn_5+0xcd>
     ba1:	mov    rdi,r12
     ba4:	jmp    c34 <botlish_fn_5+0x158>
     ba9:	mov    rdi,r12
     bac:	mov    QWORD PTR [rdi],rbx
     baf:	mov    rbx,QWORD PTR [rsp+0x10]
     bb4:	mov    r12,QWORD PTR [rsp+0x18]
     bb9:	mov    r13,QWORD PTR [rsp+0x20]
     bbe:	mov    r14,QWORD PTR [rsp+0x28]
     bc3:	add    rsp,0x30
     bc7:	mov    rsp,rbp
     bca:	pop    rbp
     bcb:	ret
     bcc:	mov    QWORD PTR [rbx+0x10],0x3
     bd4:	mov    rdx,r14
     bd7:	test   rdx,0x1
     bde:	je     bf6 <botlish_fn_5+0x11a>
     be4:	mov    rdx,r14
     be7:	add    rdx,0x2
     beb:	seto   al
     bee:	test   al,al
     bf0:	je     c0d <botlish_fn_5+0x131>
     bf6:	mov    edx,0x3
     bfb:	mov    rax,QWORD PTR [rip+0x0]        # c02 <botlish_fn_5+0x126>
			bfe: R_X86_64_GOTPCREL	rt_int_add-0x4
     c02:	mov    rsi,r14
     c05:	mov    rdi,r12
     c08:	call   rax
     c0a:	mov    rdx,rax
     c0d:	mov    QWORD PTR [rbx+0x8],rdx
     c11:	mov    rdi,r12
     c14:	mov    rax,QWORD PTR [rdi+0x10]
     c18:	mov    rcx,QWORD PTR [rax+0x8]
     c1c:	mov    QWORD PTR [rbx+0x10],rcx
     c20:	mov    rsi,r13
     c23:	call   c28 <botlish_fn_5+0x14c>
			c24: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     c28:	test   rax,rax
     c2b:	jne    c5d <botlish_fn_5+0x181>
     c31:	mov    rdi,r12
     c34:	mov    rdi,r12
     c37:	mov    QWORD PTR [rdi],rbx
     c3a:	xor    rdx,rdx
     c3d:	mov    rax,rdx
     c40:	mov    rbx,QWORD PTR [rsp+0x10]
     c45:	mov    r12,QWORD PTR [rsp+0x18]
     c4a:	mov    r13,QWORD PTR [rsp+0x20]
     c4f:	mov    r14,QWORD PTR [rsp+0x28]
     c54:	add    rsp,0x30
     c58:	mov    rsp,rbp
     c5b:	pop    rbp
     c5c:	ret
     c5d:	mov    rdi,r12
     c60:	mov    QWORD PTR [rdi],rbx
     c63:	mov    rbx,QWORD PTR [rsp+0x10]
     c68:	mov    r12,QWORD PTR [rsp+0x18]
     c6d:	mov    r13,QWORD PTR [rsp+0x20]
     c72:	mov    r14,QWORD PTR [rsp+0x28]
     c77:	add    rsp,0x30
     c7b:	mov    rsp,rbp
     c7e:	pop    rbp
     c7f:	ret
     c80:	mov    r12,rdi
     c83:	mov    rsi,QWORD PTR [rip+0x0]        # c8a <botlish_fn_5+0x1ae>
			c86: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     c8a:	call   rsi
     c8c:	xor    rdx,rdx
     c8f:	mov    rax,rdx
     c92:	mov    rbx,QWORD PTR [rsp+0x10]
     c97:	mov    r12,QWORD PTR [rsp+0x18]
     c9c:	mov    r13,QWORD PTR [rsp+0x20]
     ca1:	mov    r14,QWORD PTR [rsp+0x28]
     ca6:	add    rsp,0x30
     caa:	mov    rsp,rbp
     cad:	pop    rbp
     cae:	ret

0000000000000caf <botlish_entry_5: scan_field<str, int>>:
     caf:	push   rbp
     cb0:	mov    rbp,rsp
     cb3:	ud2

0000000000000cb5 <botlish_fn_6: scan_record<str, int, list<never>>>:
     cb5:	push   rbp
     cb6:	mov    rbp,rsp
     cb9:	sub    rsp,0x60
     cbd:	mov    QWORD PTR [rsp+0x30],rbx
     cc2:	mov    QWORD PTR [rsp+0x38],r12
     cc7:	mov    QWORD PTR [rsp+0x40],r13
     ccc:	mov    QWORD PTR [rsp+0x48],r14
     cd1:	mov    QWORD PTR [rsp+0x50],r15
     cd6:	mov    r13,QWORD PTR [rdi]
     cd9:	mov    rax,QWORD PTR [rdi+0x8]
     cdd:	lea    r8,[r13+0x20]
     ce1:	cmp    r8,rax
     ce4:	ja     f78 <botlish_fn_6+0x2c3>
     cea:	lea    rax,[r13+0x20]
     cee:	mov    QWORD PTR [rdi],rax
     cf1:	mov    r14,rdi
     cf4:	mov    QWORD PTR [r13+0x0],0x0
     cfc:	mov    QWORD PTR [r13+0x8],0x0
     d04:	mov    QWORD PTR [r13+0x10],0x0
     d0c:	mov    QWORD PTR [r13+0x18],0x0
     d14:	mov    QWORD PTR [r13+0x0],rsi
     d18:	mov    QWORD PTR [rsp+0x10],rsi
     d1d:	mov    QWORD PTR [r13+0x8],rdx
     d21:	mov    QWORD PTR [r13+0x10],rcx
     d25:	mov    r12,rcx
     d28:	mov    rsi,QWORD PTR [rsp+0x10]
     d2d:	mov    rdi,r14
     d30:	call   d35 <botlish_fn_6+0x80>
			d31: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     d35:	test   rax,rax
     d38:	jne    d46 <botlish_fn_6+0x91>
     d3e:	mov    rdi,r14
     d41:	jmp    f22 <botlish_fn_6+0x26d>
     d46:	mov    QWORD PTR [r13+0x8],rax
     d4a:	mov    rcx,rax
     d4d:	mov    QWORD PTR [r13+0x18],rdx
     d51:	mov    QWORD PTR [rsp+0x20],rdx
     d56:	mov    rax,QWORD PTR [rip+0x0]        # d5d <botlish_fn_6+0xa8>
			d59: R_X86_64_GOTPCREL	rt_list_append-0x4
     d5d:	mov    rdx,rcx
     d60:	mov    rsi,r12
     d63:	mov    rdi,r14
     d66:	call   rax
     d68:	mov    rcx,rax
     d6b:	mov    r15,rax
     d6e:	test   rax,rcx
     d71:	jne    d7f <botlish_fn_6+0xca>
     d77:	mov    rdi,r14
     d7a:	jmp    f22 <botlish_fn_6+0x26d>
     d7f:	mov    rax,r15
     d82:	mov    QWORD PTR [r13+0x8],rax
     d86:	lea    rcx,[rsp]
     d8a:	mov    rdx,QWORD PTR [rsp+0x20]
     d8f:	mov    rsi,QWORD PTR [rsp+0x10]
     d94:	mov    rdi,r14
     d97:	call   d9c <botlish_fn_6+0xe7>
			d98: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     d9c:	test   rax,rax
     d9f:	mov    QWORD PTR [rsp+0x18],rax
     da4:	jne    db2 <botlish_fn_6+0xfd>
     daa:	mov    rdi,r14
     dad:	jmp    f22 <botlish_fn_6+0x26d>
     db2:	mov    rbx,QWORD PTR [rsp]
     db6:	mov    r12,QWORD PTR [rsp+0x8]
     dbb:	mov    rdi,r14
     dbe:	mov    rsi,QWORD PTR [rdi+0x10]
     dc2:	mov    r8,QWORD PTR [rsi+0x10]
     dc6:	mov    r9,QWORD PTR [rip+0x0]        # dcd <botlish_fn_6+0x118>
			dc9: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     dcd:	mov    rcx,r12
     dd0:	mov    rdx,rbx
     dd3:	mov    rsi,QWORD PTR [rsp+0x18]
     dd8:	call   r9
     ddb:	cmp    rax,0x6
     ddf:	je     ebc <botlish_fn_6+0x207>
     de5:	mov    rdi,r14
     de8:	mov    rsi,QWORD PTR [rdi+0x10]
     dec:	mov    r8,QWORD PTR [rsi+0x18]
     df0:	mov    r9,QWORD PTR [rip+0x0]        # df7 <botlish_fn_6+0x142>
			df3: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     df7:	mov    rcx,r12
     dfa:	mov    rdx,rbx
     dfd:	mov    rsi,QWORD PTR [rsp+0x18]
     e02:	call   r9
     e05:	cmp    rax,0x6
     e09:	je     e3f <botlish_fn_6+0x18a>
     e0f:	mov    rdi,r14
     e12:	mov    QWORD PTR [rdi],r13
     e15:	mov    rax,r15
     e18:	mov    rdx,QWORD PTR [rsp+0x20]
     e1d:	mov    rbx,QWORD PTR [rsp+0x30]
     e22:	mov    r12,QWORD PTR [rsp+0x38]
     e27:	mov    r13,QWORD PTR [rsp+0x40]
     e2c:	mov    r14,QWORD PTR [rsp+0x48]
     e31:	mov    r15,QWORD PTR [rsp+0x50]
     e36:	add    rsp,0x60
     e3a:	mov    rsp,rbp
     e3d:	pop    rbp
     e3e:	ret
     e3f:	mov    QWORD PTR [r13+0x0],0x3
     e47:	mov    rdx,QWORD PTR [rsp+0x20]
     e4c:	test   rdx,0x1
     e53:	je     e75 <botlish_fn_6+0x1c0>
     e59:	mov    rdx,QWORD PTR [rsp+0x20]
     e5e:	add    rdx,0x2
     e62:	seto   al
     e65:	test   al,al
     e67:	jne    e75 <botlish_fn_6+0x1c0>
     e6d:	mov    rdi,r14
     e70:	jmp    e91 <botlish_fn_6+0x1dc>
     e75:	mov    edx,0x3
     e7a:	mov    rax,QWORD PTR [rip+0x0]        # e81 <botlish_fn_6+0x1cc>
			e7d: R_X86_64_GOTPCREL	rt_int_add-0x4
     e81:	mov    rsi,QWORD PTR [rsp+0x20]
     e86:	mov    rdi,r14
     e89:	call   rax
     e8b:	mov    rdx,rax
     e8e:	mov    rdi,r14
     e91:	mov    rdi,r14
     e94:	mov    QWORD PTR [rdi],r13
     e97:	mov    rax,r15
     e9a:	mov    rbx,QWORD PTR [rsp+0x30]
     e9f:	mov    r12,QWORD PTR [rsp+0x38]
     ea4:	mov    r13,QWORD PTR [rsp+0x40]
     ea9:	mov    r14,QWORD PTR [rsp+0x48]
     eae:	mov    r15,QWORD PTR [rsp+0x50]
     eb3:	add    rsp,0x60
     eb7:	mov    rsp,rbp
     eba:	pop    rbp
     ebb:	ret
     ebc:	mov    rsi,QWORD PTR [rsp+0x20]
     ec1:	mov    edx,0x3
     ec6:	mov    rcx,rdx
     ec9:	mov    QWORD PTR [r13+0x10],0x3
     ed1:	test   rsi,0x1
     ed8:	je     ef0 <botlish_fn_6+0x23b>
     ede:	mov    rdx,rsi
     ee1:	add    rdx,0x2
     ee5:	seto   al
     ee8:	test   al,al
     eea:	je     f02 <botlish_fn_6+0x24d>
     ef0:	mov    rax,QWORD PTR [rip+0x0]        # ef7 <botlish_fn_6+0x242>
			ef3: R_X86_64_GOTPCREL	rt_int_add-0x4
     ef7:	mov    rdx,rcx
     efa:	mov    rdi,r14
     efd:	call   rax
     eff:	mov    rdx,rax
     f02:	mov    QWORD PTR [r13+0x10],rdx
     f06:	mov    rcx,r15
     f09:	mov    rsi,QWORD PTR [rsp+0x10]
     f0e:	mov    rdi,r14
     f11:	call   f16 <botlish_fn_6+0x261>
			f12: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, list<str>>
     f16:	test   rax,rax
     f19:	jne    f50 <botlish_fn_6+0x29b>
     f1f:	mov    rdi,r14
     f22:	mov    rdi,r14
     f25:	mov    QWORD PTR [rdi],r13
     f28:	xor    rdx,rdx
     f2b:	mov    rax,rdx
     f2e:	mov    rbx,QWORD PTR [rsp+0x30]
     f33:	mov    r12,QWORD PTR [rsp+0x38]
     f38:	mov    r13,QWORD PTR [rsp+0x40]
     f3d:	mov    r14,QWORD PTR [rsp+0x48]
     f42:	mov    r15,QWORD PTR [rsp+0x50]
     f47:	add    rsp,0x60
     f4b:	mov    rsp,rbp
     f4e:	pop    rbp
     f4f:	ret
     f50:	mov    rdi,r14
     f53:	mov    QWORD PTR [rdi],r13
     f56:	mov    rbx,QWORD PTR [rsp+0x30]
     f5b:	mov    r12,QWORD PTR [rsp+0x38]
     f60:	mov    r13,QWORD PTR [rsp+0x40]
     f65:	mov    r14,QWORD PTR [rsp+0x48]
     f6a:	mov    r15,QWORD PTR [rsp+0x50]
     f6f:	add    rsp,0x60
     f73:	mov    rsp,rbp
     f76:	pop    rbp
     f77:	ret
     f78:	mov    r14,rdi
     f7b:	mov    rax,QWORD PTR [rip+0x0]        # f82 <botlish_fn_6+0x2cd>
			f7e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     f82:	call   rax
     f84:	xor    rdx,rdx
     f87:	mov    rax,rdx
     f8a:	mov    rbx,QWORD PTR [rsp+0x30]
     f8f:	mov    r12,QWORD PTR [rsp+0x38]
     f94:	mov    r13,QWORD PTR [rsp+0x40]
     f99:	mov    r14,QWORD PTR [rsp+0x48]
     f9e:	mov    r15,QWORD PTR [rsp+0x50]
     fa3:	add    rsp,0x60
     fa7:	mov    rsp,rbp
     faa:	pop    rbp
     fab:	ret

0000000000000fac <botlish_entry_6: scan_record<str, int, list<never>>>:
     fac:	push   rbp
     fad:	mov    rbp,rsp
     fb0:	ud2

0000000000000fb2 <botlish_fn_7: scan_record<str, int, list<str>>>:
     fb2:	push   rbp
     fb3:	mov    rbp,rsp
     fb6:	sub    rsp,0x60
     fba:	mov    QWORD PTR [rsp+0x30],rbx
     fbf:	mov    QWORD PTR [rsp+0x38],r12
     fc4:	mov    QWORD PTR [rsp+0x40],r13
     fc9:	mov    QWORD PTR [rsp+0x48],r14
     fce:	mov    QWORD PTR [rsp+0x50],r15
     fd3:	mov    r15,QWORD PTR [rdi]
     fd6:	mov    rax,QWORD PTR [rdi+0x8]
     fda:	lea    r8,[r15+0x20]
     fde:	cmp    r8,rax
     fe1:	ja     1261 <botlish_fn_7+0x2af>
     fe7:	lea    rax,[r15+0x20]
     feb:	mov    QWORD PTR [rdi],rax
     fee:	mov    QWORD PTR [rsp+0x10],rdi
     ff3:	mov    QWORD PTR [r15],0x0
     ffa:	mov    QWORD PTR [r15+0x8],0x0
    1002:	mov    QWORD PTR [r15+0x10],0x0
    100a:	mov    QWORD PTR [r15+0x18],0x0
    1012:	mov    QWORD PTR [r15],rsi
    1015:	mov    QWORD PTR [r15+0x8],rdx
    1019:	mov    QWORD PTR [r15+0x10],rcx
    101d:	lea    rbx,[rsp]
    1021:	mov    r12,rsi
    1024:	mov    r13,rcx
    1027:	mov    rsi,r12
    102a:	mov    rdi,QWORD PTR [rsp+0x10]
    102f:	call   1034 <botlish_fn_7+0x82>
			1030: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
    1034:	test   rax,rax
    1037:	jne    1047 <botlish_fn_7+0x95>
    103d:	mov    rdi,QWORD PTR [rsp+0x10]
    1042:	jmp    10b4 <botlish_fn_7+0x102>
    1047:	mov    QWORD PTR [r15+0x8],rax
    104b:	mov    rcx,rax
    104e:	mov    QWORD PTR [r15+0x18],rdx
    1052:	mov    QWORD PTR [rsp+0x28],rdx
    1057:	mov    rax,QWORD PTR [rip+0x0]        # 105e <botlish_fn_7+0xac>
			105a: R_X86_64_GOTPCREL	rt_list_append-0x4
    105e:	mov    rdx,rcx
    1061:	mov    rsi,r13
    1064:	mov    rdi,QWORD PTR [rsp+0x10]
    1069:	call   rax
    106b:	test   rax,rax
    106e:	mov    QWORD PTR [rsp+0x20],rax
    1073:	jne    1083 <botlish_fn_7+0xd1>
    1079:	mov    rdi,QWORD PTR [rsp+0x10]
    107e:	jmp    10b4 <botlish_fn_7+0x102>
    1083:	mov    rax,QWORD PTR [rsp+0x20]
    1088:	mov    QWORD PTR [r15+0x8],rax
    108c:	mov    rcx,rbx
    108f:	mov    rdx,QWORD PTR [rsp+0x28]
    1094:	mov    rsi,r12
    1097:	mov    rdi,QWORD PTR [rsp+0x10]
    109c:	call   10a1 <botlish_fn_7+0xef>
			109d: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
    10a1:	test   rax,rax
    10a4:	mov    QWORD PTR [rsp+0x18],rax
    10a9:	jne    10e4 <botlish_fn_7+0x132>
    10af:	mov    rdi,QWORD PTR [rsp+0x10]
    10b4:	mov    rdi,QWORD PTR [rsp+0x10]
    10b9:	mov    QWORD PTR [rdi],r15
    10bc:	xor    rdx,rdx
    10bf:	mov    rax,rdx
    10c2:	mov    rbx,QWORD PTR [rsp+0x30]
    10c7:	mov    r12,QWORD PTR [rsp+0x38]
    10cc:	mov    r13,QWORD PTR [rsp+0x40]
    10d1:	mov    r14,QWORD PTR [rsp+0x48]
    10d6:	mov    r15,QWORD PTR [rsp+0x50]
    10db:	add    rsp,0x60
    10df:	mov    rsp,rbp
    10e2:	pop    rbp
    10e3:	ret
    10e4:	mov    r13,QWORD PTR [rsp]
    10e8:	mov    r14,QWORD PTR [rsp+0x8]
    10ed:	mov    rdi,QWORD PTR [rsp+0x10]
    10f2:	mov    rsi,QWORD PTR [rdi+0x10]
    10f6:	mov    r8,QWORD PTR [rsi+0x10]
    10fa:	mov    r9,QWORD PTR [rip+0x0]        # 1101 <botlish_fn_7+0x14f>
			10fd: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1101:	mov    rcx,r14
    1104:	mov    rdx,r13
    1107:	mov    rsi,QWORD PTR [rsp+0x18]
    110c:	call   r9
    110f:	cmp    rax,0x6
    1113:	je     11ff <botlish_fn_7+0x24d>
    1119:	mov    rdi,QWORD PTR [rsp+0x10]
    111e:	mov    r8,QWORD PTR [rdi+0x10]
    1122:	mov    r8,QWORD PTR [r8+0x18]
    1126:	mov    r9,QWORD PTR [rip+0x0]        # 112d <botlish_fn_7+0x17b>
			1129: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    112d:	mov    rcx,r14
    1130:	mov    rdx,r13
    1133:	mov    rsi,QWORD PTR [rsp+0x18]
    1138:	call   r9
    113b:	cmp    rax,0x6
    113f:	je     1179 <botlish_fn_7+0x1c7>
    1145:	mov    rdi,QWORD PTR [rsp+0x10]
    114a:	mov    QWORD PTR [rdi],r15
    114d:	mov    rax,QWORD PTR [rsp+0x20]
    1152:	mov    rdx,QWORD PTR [rsp+0x28]
    1157:	mov    rbx,QWORD PTR [rsp+0x30]
    115c:	mov    r12,QWORD PTR [rsp+0x38]
    1161:	mov    r13,QWORD PTR [rsp+0x40]
    1166:	mov    r14,QWORD PTR [rsp+0x48]
    116b:	mov    r15,QWORD PTR [rsp+0x50]
    1170:	add    rsp,0x60
    1174:	mov    rsp,rbp
    1177:	pop    rbp
    1178:	ret
    1179:	mov    QWORD PTR [r15],0x3
    1180:	mov    rdx,QWORD PTR [rsp+0x28]
    1185:	test   rdx,0x1
    118c:	je     11b0 <botlish_fn_7+0x1fe>
    1192:	mov    rdx,QWORD PTR [rsp+0x28]
    1197:	add    rdx,0x2
    119b:	seto   al
    119e:	test   al,al
    11a0:	jne    11b0 <botlish_fn_7+0x1fe>
    11a6:	mov    rdi,QWORD PTR [rsp+0x10]
    11ab:	jmp    11d0 <botlish_fn_7+0x21e>
    11b0:	mov    edx,0x3
    11b5:	mov    rax,QWORD PTR [rip+0x0]        # 11bc <botlish_fn_7+0x20a>
			11b8: R_X86_64_GOTPCREL	rt_int_add-0x4
    11bc:	mov    rsi,QWORD PTR [rsp+0x28]
    11c1:	mov    rdi,QWORD PTR [rsp+0x10]
    11c6:	call   rax
    11c8:	mov    rdx,rax
    11cb:	mov    rdi,QWORD PTR [rsp+0x10]
    11d0:	mov    rdi,QWORD PTR [rsp+0x10]
    11d5:	mov    QWORD PTR [rdi],r15
    11d8:	mov    rax,QWORD PTR [rsp+0x20]
    11dd:	mov    rbx,QWORD PTR [rsp+0x30]
    11e2:	mov    r12,QWORD PTR [rsp+0x38]
    11e7:	mov    r13,QWORD PTR [rsp+0x40]
    11ec:	mov    r14,QWORD PTR [rsp+0x48]
    11f1:	mov    r15,QWORD PTR [rsp+0x50]
    11f6:	add    rsp,0x60
    11fa:	mov    rsp,rbp
    11fd:	pop    rbp
    11fe:	ret
    11ff:	mov    rsi,QWORD PTR [rsp+0x28]
    1204:	mov    edx,0x3
    1209:	mov    rcx,rdx
    120c:	mov    QWORD PTR [r15+0x10],0x3
    1214:	test   rsi,0x1
    121b:	je     1233 <botlish_fn_7+0x281>
    1221:	mov    rdx,rsi
    1224:	add    rdx,0x2
    1228:	seto   al
    122b:	test   al,al
    122d:	je     1247 <botlish_fn_7+0x295>
    1233:	mov    rax,QWORD PTR [rip+0x0]        # 123a <botlish_fn_7+0x288>
			1236: R_X86_64_GOTPCREL	rt_int_add-0x4
    123a:	mov    rdx,rcx
    123d:	mov    rdi,QWORD PTR [rsp+0x10]
    1242:	call   rax
    1244:	mov    rdx,rax
    1247:	mov    QWORD PTR [r15],r12
    124a:	mov    QWORD PTR [r15+0x8],rdx
    124e:	mov    rax,QWORD PTR [rsp+0x20]
    1253:	mov    QWORD PTR [r15+0x10],rax
    1257:	mov    r13,QWORD PTR [rsp+0x20]
    125c:	jmp    1027 <botlish_fn_7+0x75>
    1261:	mov    QWORD PTR [rsp+0x10],rdi
    1266:	mov    rax,QWORD PTR [rip+0x0]        # 126d <botlish_fn_7+0x2bb>
			1269: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    126d:	call   rax
    126f:	xor    rdx,rdx
    1272:	mov    rax,rdx
    1275:	mov    rbx,QWORD PTR [rsp+0x30]
    127a:	mov    r12,QWORD PTR [rsp+0x38]
    127f:	mov    r13,QWORD PTR [rsp+0x40]
    1284:	mov    r14,QWORD PTR [rsp+0x48]
    1289:	mov    r15,QWORD PTR [rsp+0x50]
    128e:	add    rsp,0x60
    1292:	mov    rsp,rbp
    1295:	pop    rbp
    1296:	ret

0000000000001297 <botlish_entry_7: scan_record<str, int, list<str>>>:
    1297:	push   rbp
    1298:	mov    rbp,rsp
    129b:	ud2

000000000000129d <botlish_fn_8: scan_records<str, int, list<never>>>:
    129d:	push   rbp
    129e:	mov    rbp,rsp
    12a1:	sub    rsp,0x30
    12a5:	mov    QWORD PTR [rsp],rbx
    12a9:	mov    QWORD PTR [rsp+0x8],r12
    12ae:	mov    QWORD PTR [rsp+0x10],r13
    12b3:	mov    QWORD PTR [rsp+0x18],r14
    12b8:	mov    QWORD PTR [rsp+0x20],r15
    12bd:	mov    rbx,QWORD PTR [rdi]
    12c0:	mov    rax,QWORD PTR [rdi+0x8]
    12c4:	lea    r8,[rbx+0x20]
    12c8:	cmp    r8,rax
    12cb:	ja     1448 <botlish_fn_8+0x1ab>
    12d1:	lea    rax,[rbx+0x20]
    12d5:	mov    QWORD PTR [rdi],rax
    12d8:	mov    r12,rdi
    12db:	mov    QWORD PTR [rbx],0x0
    12e2:	mov    QWORD PTR [rbx+0x8],0x0
    12ea:	mov    QWORD PTR [rbx+0x10],0x0
    12f2:	mov    QWORD PTR [rbx+0x18],0x0
    12fa:	mov    QWORD PTR [rbx],rsi
    12fd:	mov    r13,rsi
    1300:	mov    QWORD PTR [rbx+0x8],rdx
    1304:	mov    r15,rdx
    1307:	mov    QWORD PTR [rbx+0x10],rcx
    130b:	mov    r14,rcx
    130e:	mov    rax,QWORD PTR [rip+0x0]        # 1315 <botlish_fn_8+0x78>
			1311: R_X86_64_GOTPCREL	rt_str_len-0x4
    1315:	mov    rsi,r13
    1318:	mov    rdi,r12
    131b:	call   rax
    131d:	mov    rdx,r15
    1320:	mov    rcx,rdx
    1323:	sar    rcx,1
    1326:	sar    rax,1
    1329:	cmp    rcx,rax
    132c:	jge    141e <botlish_fn_8+0x181>
    1332:	xor    rdx,rdx
    1335:	mov    rax,QWORD PTR [rip+0x0]        # 133c <botlish_fn_8+0x9f>
			1338: R_X86_64_GOTPCREL	rt_list_new-0x4
    133c:	mov    rdi,r12
    133f:	mov    rsi,rdx
    1342:	call   rax
    1344:	test   rax,rax
    1347:	jne    1355 <botlish_fn_8+0xb8>
    134d:	mov    rdi,r12
    1350:	jmp    13cd <botlish_fn_8+0x130>
    1355:	mov    QWORD PTR [rbx+0x18],rax
    1359:	mov    rcx,rax
    135c:	mov    rdx,r15
    135f:	mov    rsi,r13
    1362:	mov    rdi,r12
    1365:	call   136a <botlish_fn_8+0xcd>
			1366: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    136a:	test   rax,rax
    136d:	jne    137b <botlish_fn_8+0xde>
    1373:	mov    rdi,r12
    1376:	jmp    13cd <botlish_fn_8+0x130>
    137b:	mov    QWORD PTR [rbx+0x8],rax
    137f:	mov    rcx,rax
    1382:	mov    QWORD PTR [rbx+0x18],rdx
    1386:	mov    r15,rdx
    1389:	mov    rax,QWORD PTR [rip+0x0]        # 1390 <botlish_fn_8+0xf3>
			138c: R_X86_64_GOTPCREL	rt_list_append-0x4
    1390:	mov    rdx,rcx
    1393:	mov    rsi,r14
    1396:	mov    rdi,r12
    1399:	call   rax
    139b:	test   rax,rax
    139e:	jne    13ac <botlish_fn_8+0x10f>
    13a4:	mov    rdi,r12
    13a7:	jmp    13cd <botlish_fn_8+0x130>
    13ac:	mov    QWORD PTR [rbx+0x8],rax
    13b0:	mov    rcx,rax
    13b3:	mov    rdx,r15
    13b6:	mov    rsi,r13
    13b9:	mov    rdi,r12
    13bc:	call   13c1 <botlish_fn_8+0x124>
			13bd: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    13c1:	test   rax,rax
    13c4:	jne    13f7 <botlish_fn_8+0x15a>
    13ca:	mov    rdi,r12
    13cd:	mov    rdi,r12
    13d0:	mov    QWORD PTR [rdi],rbx
    13d3:	xor    rax,rax
    13d6:	mov    rbx,QWORD PTR [rsp]
    13da:	mov    r12,QWORD PTR [rsp+0x8]
    13df:	mov    r13,QWORD PTR [rsp+0x10]
    13e4:	mov    r14,QWORD PTR [rsp+0x18]
    13e9:	mov    r15,QWORD PTR [rsp+0x20]
    13ee:	add    rsp,0x30
    13f2:	mov    rsp,rbp
    13f5:	pop    rbp
    13f6:	ret
    13f7:	mov    rdi,r12
    13fa:	mov    QWORD PTR [rdi],rbx
    13fd:	mov    rbx,QWORD PTR [rsp]
    1401:	mov    r12,QWORD PTR [rsp+0x8]
    1406:	mov    r13,QWORD PTR [rsp+0x10]
    140b:	mov    r14,QWORD PTR [rsp+0x18]
    1410:	mov    r15,QWORD PTR [rsp+0x20]
    1415:	add    rsp,0x30
    1419:	mov    rsp,rbp
    141c:	pop    rbp
    141d:	ret
    141e:	mov    rdi,r12
    1421:	mov    QWORD PTR [rdi],rbx
    1424:	mov    rax,r14
    1427:	mov    rbx,QWORD PTR [rsp]
    142b:	mov    r12,QWORD PTR [rsp+0x8]
    1430:	mov    r13,QWORD PTR [rsp+0x10]
    1435:	mov    r14,QWORD PTR [rsp+0x18]
    143a:	mov    r15,QWORD PTR [rsp+0x20]
    143f:	add    rsp,0x30
    1443:	mov    rsp,rbp
    1446:	pop    rbp
    1447:	ret
    1448:	mov    r12,rdi
    144b:	mov    rax,QWORD PTR [rip+0x0]        # 1452 <botlish_fn_8+0x1b5>
			144e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1452:	call   rax
    1454:	xor    rax,rax
    1457:	mov    rbx,QWORD PTR [rsp]
    145b:	mov    r12,QWORD PTR [rsp+0x8]
    1460:	mov    r13,QWORD PTR [rsp+0x10]
    1465:	mov    r14,QWORD PTR [rsp+0x18]
    146a:	mov    r15,QWORD PTR [rsp+0x20]
    146f:	add    rsp,0x30
    1473:	mov    rsp,rbp
    1476:	pop    rbp
    1477:	ret

0000000000001478 <botlish_entry_8: scan_records<str, int, list<never>>>:
    1478:	push   rbp
    1479:	mov    rbp,rsp
    147c:	mov    rsi,QWORD PTR [rdx]
    147f:	mov    r8,QWORD PTR [rdx+0x8]
    1483:	mov    rcx,QWORD PTR [rdx+0x10]
    1487:	mov    rdx,r8
    148a:	call   148f <botlish_entry_8+0x17>
			148b: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    148f:	mov    rsp,rbp
    1492:	pop    rbp
    1493:	ret
    1494:	add    BYTE PTR [rax],al
	...

0000000000001498 <botlish_fn_9: scan_records<str, int, list<list<str>>>>:
    1498:	push   rbp
    1499:	mov    rbp,rsp
    149c:	sub    rsp,0x30
    14a0:	mov    QWORD PTR [rsp],rbx
    14a4:	mov    QWORD PTR [rsp+0x8],r12
    14a9:	mov    QWORD PTR [rsp+0x10],r13
    14ae:	mov    QWORD PTR [rsp+0x18],r14
    14b3:	mov    QWORD PTR [rsp+0x20],r15
    14b8:	mov    r12,QWORD PTR [rdi]
    14bb:	mov    rax,QWORD PTR [rdi+0x8]
    14bf:	lea    r8,[r12+0x20]
    14c4:	cmp    r8,rax
    14c7:	ja     165d <botlish_fn_9+0x1c5>
    14cd:	lea    rax,[r12+0x20]
    14d2:	mov    QWORD PTR [rdi],rax
    14d5:	mov    r14,rdi
    14d8:	mov    QWORD PTR [r12],0x0
    14e0:	mov    QWORD PTR [r12+0x8],0x0
    14e9:	mov    QWORD PTR [r12+0x10],0x0
    14f2:	mov    QWORD PTR [r12+0x18],0x0
    14fb:	mov    QWORD PTR [r12],rsi
    14ff:	mov    QWORD PTR [r12+0x8],rdx
    1504:	mov    r13,rdx
    1507:	mov    QWORD PTR [r12+0x10],rcx
    150c:	mov    r15,rcx
    150f:	mov    rax,QWORD PTR [rip+0x0]        # 1516 <botlish_fn_9+0x7e>
			1512: R_X86_64_GOTPCREL	rt_str_len-0x4
    1516:	mov    rbx,rsi
    1519:	mov    rdi,r14
    151c:	call   rax
    151e:	mov    rcx,r13
    1521:	and    rcx,rax
    1524:	mov    rdx,rax
    1527:	test   rcx,0x1
    152e:	jne    1558 <botlish_fn_9+0xc0>
    1534:	mov    rax,QWORD PTR [rip+0x0]        # 153b <botlish_fn_9+0xa3>
			1537: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    153b:	mov    rsi,r13
    153e:	mov    rdi,r14
    1541:	call   rax
    1543:	mov    ecx,0x2
    1548:	test   rax,rax
    154b:	cmovge rcx,QWORD PTR [rip+0x13d]        # 1690 <botlish_fn_9+0x1f8>
    1553:	jmp    156b <botlish_fn_9+0xd3>
    1558:	mov    ecx,0x2
    155d:	mov    rax,r13
    1560:	cmp    rax,rdx
    1563:	cmovge rcx,QWORD PTR [rip+0x125]        # 1690 <botlish_fn_9+0x1f8>
    156b:	cmp    rcx,0x6
    156f:	je     1633 <botlish_fn_9+0x19b>
    1575:	xor    rdx,rdx
    1578:	mov    rax,QWORD PTR [rip+0x0]        # 157f <botlish_fn_9+0xe7>
			157b: R_X86_64_GOTPCREL	rt_list_new-0x4
    157f:	mov    rdi,r14
    1582:	mov    rsi,rdx
    1585:	call   rax
    1587:	test   rax,rax
    158a:	jne    1598 <botlish_fn_9+0x100>
    1590:	mov    rdi,r14
    1593:	jmp    15ed <botlish_fn_9+0x155>
    1598:	mov    QWORD PTR [r12+0x18],rax
    159d:	mov    rcx,rax
    15a0:	mov    rdx,r13
    15a3:	mov    rsi,rbx
    15a6:	mov    rdi,r14
    15a9:	call   15ae <botlish_fn_9+0x116>
			15aa: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    15ae:	test   rax,rax
    15b1:	jne    15bf <botlish_fn_9+0x127>
    15b7:	mov    rdi,r14
    15ba:	jmp    15ed <botlish_fn_9+0x155>
    15bf:	mov    QWORD PTR [r12+0x8],rax
    15c4:	mov    rcx,rax
    15c7:	mov    QWORD PTR [r12+0x18],rdx
    15cc:	mov    r13,rdx
    15cf:	mov    rax,QWORD PTR [rip+0x0]        # 15d6 <botlish_fn_9+0x13e>
			15d2: R_X86_64_GOTPCREL	rt_list_append-0x4
    15d6:	mov    rdx,rcx
    15d9:	mov    rsi,r15
    15dc:	mov    rdi,r14
    15df:	call   rax
    15e1:	test   rax,rax
    15e4:	jne    1617 <botlish_fn_9+0x17f>
    15ea:	mov    rdi,r14
    15ed:	mov    rdi,r14
    15f0:	mov    QWORD PTR [rdi],r12
    15f3:	xor    rax,rax
    15f6:	mov    rbx,QWORD PTR [rsp]
    15fa:	mov    r12,QWORD PTR [rsp+0x8]
    15ff:	mov    r13,QWORD PTR [rsp+0x10]
    1604:	mov    r14,QWORD PTR [rsp+0x18]
    1609:	mov    r15,QWORD PTR [rsp+0x20]
    160e:	add    rsp,0x30
    1612:	mov    rsp,rbp
    1615:	pop    rbp
    1616:	ret
    1617:	mov    QWORD PTR [r12],rbx
    161b:	mov    rdx,r13
    161e:	mov    QWORD PTR [r12+0x8],rdx
    1623:	mov    QWORD PTR [r12+0x10],rax
    1628:	mov    rsi,rbx
    162b:	mov    r15,rax
    162e:	jmp    150f <botlish_fn_9+0x77>
    1633:	mov    rdi,r14
    1636:	mov    QWORD PTR [rdi],r12
    1639:	mov    rax,r15
    163c:	mov    rbx,QWORD PTR [rsp]
    1640:	mov    r12,QWORD PTR [rsp+0x8]
    1645:	mov    r13,QWORD PTR [rsp+0x10]
    164a:	mov    r14,QWORD PTR [rsp+0x18]
    164f:	mov    r15,QWORD PTR [rsp+0x20]
    1654:	add    rsp,0x30
    1658:	mov    rsp,rbp
    165b:	pop    rbp
    165c:	ret
    165d:	mov    r14,rdi
    1660:	mov    r10,QWORD PTR [rip+0x0]        # 1667 <botlish_fn_9+0x1cf>
			1663: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1667:	call   r10
    166a:	xor    rax,rax
    166d:	mov    rbx,QWORD PTR [rsp]
    1671:	mov    r12,QWORD PTR [rsp+0x8]
    1676:	mov    r13,QWORD PTR [rsp+0x10]
    167b:	mov    r14,QWORD PTR [rsp+0x18]
    1680:	mov    r15,QWORD PTR [rsp+0x20]
    1685:	add    rsp,0x30
    1689:	mov    rsp,rbp
    168c:	pop    rbp
    168d:	ret
    168e:	add    BYTE PTR [rax],al
    1690:	(bad)
    1691:	add    BYTE PTR [rax],al
    1693:	add    BYTE PTR [rax],al
    1695:	add    BYTE PTR [rax],al
	...

0000000000001698 <botlish_entry_9: scan_records<str, int, list<list<str>>>>:
    1698:	push   rbp
    1699:	mov    rbp,rsp
    169c:	mov    rsi,QWORD PTR [rdx]
    169f:	mov    r8,QWORD PTR [rdx+0x8]
    16a3:	mov    rcx,QWORD PTR [rdx+0x10]
    16a7:	mov    rdx,r8
    16aa:	call   16af <botlish_entry_9+0x17>
			16ab: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    16af:	mov    rsp,rbp
    16b2:	pop    rbp
    16b3:	ret

00000000000016b4 <botlish_fn_10: csv_parse<str>>:
    16b4:	push   rbp
    16b5:	mov    rbp,rsp
    16b8:	sub    rsp,0x20
    16bc:	mov    QWORD PTR [rsp],rbx
    16c0:	mov    QWORD PTR [rsp+0x8],r12
    16c5:	mov    QWORD PTR [rsp+0x10],r13
    16ca:	mov    rbx,QWORD PTR [rdi]
    16cd:	mov    rax,QWORD PTR [rdi+0x8]
    16d1:	lea    rcx,[rbx+0x18]
    16d5:	cmp    rcx,rax
    16d8:	ja     1790 <botlish_fn_10+0xdc>
    16de:	lea    rax,[rbx+0x18]
    16e2:	mov    QWORD PTR [rdi],rax
    16e5:	mov    r12,rdi
    16e8:	mov    QWORD PTR [rbx],0x0
    16ef:	mov    QWORD PTR [rbx+0x8],0x0
    16f7:	mov    QWORD PTR [rbx+0x10],0x0
    16ff:	mov    QWORD PTR [rbx],rsi
    1702:	mov    r13,rsi
    1705:	mov    QWORD PTR [rbx+0x8],0x1
    170d:	xor    rdx,rdx
    1710:	mov    rax,QWORD PTR [rip+0x0]        # 1717 <botlish_fn_10+0x63>
			1713: R_X86_64_GOTPCREL	rt_list_new-0x4
    1717:	mov    rdi,r12
    171a:	mov    rsi,rdx
    171d:	call   rax
    171f:	test   rax,rax
    1722:	jne    1730 <botlish_fn_10+0x7c>
    1728:	mov    rdi,r12
    172b:	jmp    1753 <botlish_fn_10+0x9f>
    1730:	mov    QWORD PTR [rbx+0x10],rax
    1734:	mov    rcx,rax
    1737:	mov    edx,0x1
    173c:	mov    rsi,r13
    173f:	mov    rdi,r12
    1742:	call   1747 <botlish_fn_10+0x93>
			1743: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    1747:	test   rax,rax
    174a:	jne    1773 <botlish_fn_10+0xbf>
    1750:	mov    rdi,r12
    1753:	mov    rdi,r12
    1756:	mov    QWORD PTR [rdi],rbx
    1759:	xor    rax,rax
    175c:	mov    rbx,QWORD PTR [rsp]
    1760:	mov    r12,QWORD PTR [rsp+0x8]
    1765:	mov    r13,QWORD PTR [rsp+0x10]
    176a:	add    rsp,0x20
    176e:	mov    rsp,rbp
    1771:	pop    rbp
    1772:	ret
    1773:	mov    rdi,r12
    1776:	mov    QWORD PTR [rdi],rbx
    1779:	mov    rbx,QWORD PTR [rsp]
    177d:	mov    r12,QWORD PTR [rsp+0x8]
    1782:	mov    r13,QWORD PTR [rsp+0x10]
    1787:	add    rsp,0x20
    178b:	mov    rsp,rbp
    178e:	pop    rbp
    178f:	ret
    1790:	mov    r12,rdi
    1793:	mov    rax,QWORD PTR [rip+0x0]        # 179a <botlish_fn_10+0xe6>
			1796: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    179a:	call   rax
    179c:	xor    rax,rax
    179f:	mov    rbx,QWORD PTR [rsp]
    17a3:	mov    r12,QWORD PTR [rsp+0x8]
    17a8:	mov    r13,QWORD PTR [rsp+0x10]
    17ad:	add    rsp,0x20
    17b1:	mov    rsp,rbp
    17b4:	pop    rbp
    17b5:	ret

00000000000017b6 <botlish_entry_10: csv_parse<str>>:
    17b6:	push   rbp
    17b7:	mov    rbp,rsp
    17ba:	mov    rsi,QWORD PTR [rdx]
    17bd:	call   17c2 <botlish_entry_10+0xc>
			17be: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    17c2:	mov    rsp,rbp
    17c5:	pop    rbp
    17c6:	ret

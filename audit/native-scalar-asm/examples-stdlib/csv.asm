; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5949  (per function: 169 453 502 677 887 470 759 742 492 532 266)
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
       8:	mov    QWORD PTR [rsp],r13
       c:	mov    QWORD PTR [rsp+0x8],r14
      11:	mov    r13,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r13+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     7b <botlish_fn_0+0x7b>
      25:	lea    rax,[r13+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    rax,QWORD PTR [rdi+0x10]
      30:	mov    r14,rdi
      33:	mov    rsi,QWORD PTR [rax]
      36:	mov    QWORD PTR [r13+0x0],rsi
      3a:	call   3f <botlish_fn_0+0x3f>
			3b: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
      3f:	test   rax,rax
      42:	jne    63 <botlish_fn_0+0x63>
      48:	mov    rdi,r14
      4b:	mov    QWORD PTR [rdi],r13
      4e:	xor    rax,rax
      51:	mov    r13,QWORD PTR [rsp]
      55:	mov    r14,QWORD PTR [rsp+0x8]
      5a:	add    rsp,0x10
      5e:	mov    rsp,rbp
      61:	pop    rbp
      62:	ret
      63:	mov    rdi,r14
      66:	mov    QWORD PTR [rdi],r13
      69:	mov    r13,QWORD PTR [rsp]
      6d:	mov    r14,QWORD PTR [rsp+0x8]
      72:	add    rsp,0x10
      76:	mov    rsp,rbp
      79:	pop    rbp
      7a:	ret
      7b:	call   80 <botlish_fn_0+0x80>
			7c: R_X86_64_PLT32	rt_stack_overflow-0x4
      80:	xor    rax,rax
      83:	mov    r13,QWORD PTR [rsp]
      87:	mov    r14,QWORD PTR [rsp+0x8]
      8c:	add    rsp,0x10
      90:	mov    rsp,rbp
      93:	pop    rbp
      94:	ret

0000000000000095 <botlish_entry_0: <program entry>>:
      95:	push   rbp
      96:	mov    rbp,rsp
      99:	call   9e <botlish_entry_0+0x9>
			9a: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      9e:	mov    rsp,rbp
      a1:	pop    rbp
      a2:	ret
      a3:	add    BYTE PTR [rax],al
      a5:	add    BYTE PTR [rax],al
	...

00000000000000a8 <botlish_fn_1: peek<str, int>>:
      a8:	push   rbp
      a9:	mov    rbp,rsp
      ac:	sub    rsp,0x50
      b0:	mov    QWORD PTR [rsp+0x20],rbx
      b5:	mov    QWORD PTR [rsp+0x28],r12
      ba:	mov    QWORD PTR [rsp+0x30],r13
      bf:	mov    QWORD PTR [rsp+0x38],r14
      c4:	mov    QWORD PTR [rsp+0x40],r15
      c9:	mov    rbx,QWORD PTR [rdi+0x20]
      cd:	mov    r14,QWORD PTR [rdi+0x28]
      d1:	lea    rax,[rsp]
      d5:	mov    QWORD PTR [rdi+0x20],rax
      d9:	mov    QWORD PTR [rdi+0x28],0x3
      e1:	mov    QWORD PTR [rsp],rsi
      e5:	mov    r15,rsi
      e8:	mov    QWORD PTR [rsp+0x8],rdx
      ed:	mov    r13,rdx
      f0:	mov    r12,rdi
      f3:	mov    rsi,r15
      f6:	call   fb <botlish_fn_1+0x53>
			f7: R_X86_64_PLT32	rt_str_len-0x4
      fb:	mov    rcx,r13
      fe:	and    rcx,rax
     101:	mov    rdx,rax
     104:	test   rcx,0x1
     10b:	jne    131 <botlish_fn_1+0x89>
     111:	mov    rsi,r13
     114:	mov    rdi,r12
     117:	call   11c <botlish_fn_1+0x74>
			118: R_X86_64_PLT32	rt_int_cmp-0x4
     11c:	mov    ecx,0x2
     121:	test   rax,rax
     124:	cmovge rcx,QWORD PTR [rip+0x10c]        # 238 <botlish_fn_1+0x190>
     12c:	jmp    141 <botlish_fn_1+0x99>
     131:	mov    ecx,0x2
     136:	cmp    r13,rdx
     139:	cmovge rcx,QWORD PTR [rip+0xf7]        # 238 <botlish_fn_1+0x190>
     141:	cmp    rcx,0x6
     145:	je     1fd <botlish_fn_1+0x155>
     14b:	mov    QWORD PTR [rsp+0x10],0x3
     154:	test   r13,0x1
     15b:	je     173 <botlish_fn_1+0xcb>
     161:	mov    rcx,r13
     164:	add    rcx,0x2
     168:	seto   al
     16b:	test   al,al
     16d:	je     186 <botlish_fn_1+0xde>
     173:	mov    edx,0x3
     178:	mov    rsi,r13
     17b:	mov    rdi,r12
     17e:	call   183 <botlish_fn_1+0xdb>
			17f: R_X86_64_PLT32	rt_int_add-0x4
     183:	mov    rcx,rax
     186:	mov    QWORD PTR [rsp+0x10],rcx
     18b:	mov    rdx,r13
     18e:	mov    rsi,r15
     191:	mov    rdi,r12
     194:	call   199 <botlish_fn_1+0xf1>
			195: R_X86_64_PLT32	rt_substr-0x4
     199:	test   rax,rax
     19c:	jne    1d1 <botlish_fn_1+0x129>
     1a2:	mov    QWORD PTR [r12+0x20],rbx
     1a7:	mov    QWORD PTR [r12+0x28],r14
     1ac:	xor    rax,rax
     1af:	mov    rbx,QWORD PTR [rsp+0x20]
     1b4:	mov    r12,QWORD PTR [rsp+0x28]
     1b9:	mov    r13,QWORD PTR [rsp+0x30]
     1be:	mov    r14,QWORD PTR [rsp+0x38]
     1c3:	mov    r15,QWORD PTR [rsp+0x40]
     1c8:	add    rsp,0x50
     1cc:	mov    rsp,rbp
     1cf:	pop    rbp
     1d0:	ret
     1d1:	mov    QWORD PTR [r12+0x20],rbx
     1d6:	mov    QWORD PTR [r12+0x28],r14
     1db:	mov    rbx,QWORD PTR [rsp+0x20]
     1e0:	mov    r12,QWORD PTR [rsp+0x28]
     1e5:	mov    r13,QWORD PTR [rsp+0x30]
     1ea:	mov    r14,QWORD PTR [rsp+0x38]
     1ef:	mov    r15,QWORD PTR [rsp+0x40]
     1f4:	add    rsp,0x50
     1f8:	mov    rsp,rbp
     1fb:	pop    rbp
     1fc:	ret
     1fd:	mov    rax,QWORD PTR [r12+0x10]
     202:	mov    rax,QWORD PTR [rax+0x8]
     206:	mov    QWORD PTR [r12+0x20],rbx
     20b:	mov    QWORD PTR [r12+0x28],r14
     210:	mov    rbx,QWORD PTR [rsp+0x20]
     215:	mov    r12,QWORD PTR [rsp+0x28]
     21a:	mov    r13,QWORD PTR [rsp+0x30]
     21f:	mov    r14,QWORD PTR [rsp+0x38]
     224:	mov    r15,QWORD PTR [rsp+0x40]
     229:	add    rsp,0x50
     22d:	mov    rsp,rbp
     230:	pop    rbp
     231:	ret
     232:	add    BYTE PTR [rax],al
     234:	add    BYTE PTR [rax],al
     236:	add    BYTE PTR [rax],al
     238:	(bad)
     239:	add    BYTE PTR [rax],al
     23b:	add    BYTE PTR [rax],al
     23d:	add    BYTE PTR [rax],al
	...

0000000000000240 <botlish_entry_1: peek<str, int>>:
     240:	push   rbp
     241:	mov    rbp,rsp
     244:	mov    rsi,QWORD PTR [rdx]
     247:	mov    rdx,QWORD PTR [rdx+0x8]
     24b:	call   250 <botlish_entry_1+0x10>
			24c: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     250:	mov    rsp,rbp
     253:	pop    rbp
     254:	ret
     255:	add    BYTE PTR [rax],al
	...

0000000000000258 <botlish_fn_2: peek<str, int>>:
     258:	push   rbp
     259:	mov    rbp,rsp
     25c:	sub    rsp,0x60
     260:	mov    QWORD PTR [rsp+0x30],rbx
     265:	mov    QWORD PTR [rsp+0x38],r12
     26a:	mov    QWORD PTR [rsp+0x40],r13
     26f:	mov    QWORD PTR [rsp+0x48],r14
     274:	mov    QWORD PTR [rsp+0x50],r15
     279:	mov    r15,rcx
     27c:	mov    rbx,QWORD PTR [rdi+0x20]
     280:	mov    r14,QWORD PTR [rdi+0x28]
     284:	lea    rax,[rsp]
     288:	mov    QWORD PTR [rdi+0x20],rax
     28c:	mov    QWORD PTR [rdi+0x28],0x3
     294:	mov    QWORD PTR [rsp],rsi
     298:	mov    QWORD PTR [rsp+0x18],rsi
     29d:	mov    QWORD PTR [rsp+0x8],rdx
     2a2:	mov    r13,rdx
     2a5:	mov    r12,rdi
     2a8:	mov    rsi,QWORD PTR [rsp+0x18]
     2ad:	call   2b2 <botlish_fn_2+0x5a>
			2ae: R_X86_64_PLT32	rt_str_len-0x4
     2b2:	mov    rcx,r13
     2b5:	and    rcx,rax
     2b8:	mov    rdx,rax
     2bb:	test   rcx,0x1
     2c2:	jne    2e8 <botlish_fn_2+0x90>
     2c8:	mov    rsi,r13
     2cb:	mov    rdi,r12
     2ce:	call   2d3 <botlish_fn_2+0x7b>
			2cf: R_X86_64_PLT32	rt_int_cmp-0x4
     2d3:	mov    ecx,0x2
     2d8:	test   rax,rax
     2db:	cmovge rcx,QWORD PTR [rip+0x13d]        # 420 <botlish_fn_2+0x1c8>
     2e3:	jmp    2f8 <botlish_fn_2+0xa0>
     2e8:	mov    ecx,0x2
     2ed:	cmp    r13,rdx
     2f0:	cmovge rcx,QWORD PTR [rip+0x128]        # 420 <botlish_fn_2+0x1c8>
     2f8:	cmp    rcx,0x6
     2fc:	je     3d6 <botlish_fn_2+0x17e>
     302:	mov    QWORD PTR [rsp+0x10],0x3
     30b:	test   r13,0x1
     312:	je     334 <botlish_fn_2+0xdc>
     318:	mov    rax,r13
     31b:	add    rax,0x2
     31f:	seto   cl
     322:	test   cl,cl
     324:	jne    334 <botlish_fn_2+0xdc>
     32a:	mov    QWORD PTR [rsp+0x20],rax
     32f:	jmp    349 <botlish_fn_2+0xf1>
     334:	mov    edx,0x3
     339:	mov    rsi,r13
     33c:	mov    rdi,r12
     33f:	call   344 <botlish_fn_2+0xec>
			340: R_X86_64_PLT32	rt_int_add-0x4
     344:	mov    QWORD PTR [rsp+0x20],rax
     349:	mov    rcx,QWORD PTR [rsp+0x20]
     34e:	mov    rdx,r13
     351:	mov    rsi,QWORD PTR [rsp+0x18]
     356:	mov    rdi,r12
     359:	call   35e <botlish_fn_2+0x106>
			35a: R_X86_64_PLT32	rt_str_region_check-0x4
     35e:	test   rax,rax
     361:	jne    396 <botlish_fn_2+0x13e>
     367:	mov    QWORD PTR [r12+0x20],rbx
     36c:	mov    QWORD PTR [r12+0x28],r14
     371:	xor    rax,rax
     374:	mov    rbx,QWORD PTR [rsp+0x30]
     379:	mov    r12,QWORD PTR [rsp+0x38]
     37e:	mov    r13,QWORD PTR [rsp+0x40]
     383:	mov    r14,QWORD PTR [rsp+0x48]
     388:	mov    r15,QWORD PTR [rsp+0x50]
     38d:	add    rsp,0x60
     391:	mov    rsp,rbp
     394:	pop    rbp
     395:	ret
     396:	mov    QWORD PTR [r12+0x20],rbx
     39b:	mov    QWORD PTR [r12+0x28],r14
     3a0:	mov    rcx,r15
     3a3:	mov    QWORD PTR [rcx],r13
     3a6:	mov    rax,QWORD PTR [rsp+0x20]
     3ab:	mov    QWORD PTR [rcx+0x8],rax
     3af:	mov    rax,QWORD PTR [rsp+0x18]
     3b4:	mov    rbx,QWORD PTR [rsp+0x30]
     3b9:	mov    r12,QWORD PTR [rsp+0x38]
     3be:	mov    r13,QWORD PTR [rsp+0x40]
     3c3:	mov    r14,QWORD PTR [rsp+0x48]
     3c8:	mov    r15,QWORD PTR [rsp+0x50]
     3cd:	add    rsp,0x60
     3d1:	mov    rsp,rbp
     3d4:	pop    rbp
     3d5:	ret
     3d6:	mov    rcx,r15
     3d9:	mov    rax,QWORD PTR [r12+0x10]
     3de:	mov    rax,QWORD PTR [rax+0x8]
     3e2:	mov    QWORD PTR [r12+0x20],rbx
     3e7:	mov    QWORD PTR [r12+0x28],r14
     3ec:	mov    QWORD PTR [rcx],0x1
     3f3:	mov    QWORD PTR [rcx+0x8],0x1
     3fb:	mov    rbx,QWORD PTR [rsp+0x30]
     400:	mov    r12,QWORD PTR [rsp+0x38]
     405:	mov    r13,QWORD PTR [rsp+0x40]
     40a:	mov    r14,QWORD PTR [rsp+0x48]
     40f:	mov    r15,QWORD PTR [rsp+0x50]
     414:	add    rsp,0x60
     418:	mov    rsp,rbp
     41b:	pop    rbp
     41c:	ret
     41d:	add    BYTE PTR [rax],al
     41f:	add    BYTE PTR [rsi],al
     421:	add    BYTE PTR [rax],al
     423:	add    BYTE PTR [rax],al
     425:	add    BYTE PTR [rax],al
	...

0000000000000428 <botlish_entry_2: peek<str, int>>:
     428:	push   rbp
     429:	mov    rbp,rsp
     42c:	ud2

000000000000042e <botlish_fn_3: scan_unquoted<str, int, int>>:
     42e:	push   rbp
     42f:	mov    rbp,rsp
     432:	sub    rsp,0x60
     436:	mov    QWORD PTR [rsp+0x30],rbx
     43b:	mov    QWORD PTR [rsp+0x38],r12
     440:	mov    QWORD PTR [rsp+0x40],r13
     445:	mov    QWORD PTR [rsp+0x48],r14
     44a:	mov    QWORD PTR [rsp+0x50],r15
     44f:	mov    r14,QWORD PTR [rdi]
     452:	mov    rax,QWORD PTR [rdi+0x8]
     456:	lea    r8,[r14+0x20]
     45a:	cmp    r8,rax
     45d:	ja     66e <botlish_fn_3+0x240>
     463:	lea    rax,[r14+0x20]
     467:	mov    QWORD PTR [rdi],rax
     46a:	mov    r15,rdi
     46d:	mov    QWORD PTR [r14+0x18],0x0
     475:	mov    QWORD PTR [r14],rsi
     478:	mov    QWORD PTR [rsp+0x10],rsi
     47d:	mov    QWORD PTR [r14+0x8],rdx
     481:	mov    QWORD PTR [rsp+0x18],rdx
     486:	mov    QWORD PTR [r14+0x10],rcx
     48a:	lea    rbx,[rsp]
     48e:	mov    QWORD PTR [rsp+0x20],rcx
     493:	mov    rcx,rbx
     496:	mov    rdx,QWORD PTR [rsp+0x20]
     49b:	mov    rsi,QWORD PTR [rsp+0x10]
     4a0:	mov    rdi,r15
     4a3:	call   4a8 <botlish_fn_3+0x7a>
			4a4: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     4a8:	mov    rcx,rax
     4ab:	mov    QWORD PTR [rsp+0x28],rax
     4b0:	test   rax,rcx
     4b3:	jne    4c1 <botlish_fn_3+0x93>
     4b9:	mov    rdi,r15
     4bc:	jmp    613 <botlish_fn_3+0x1e5>
     4c1:	mov    r12,QWORD PTR [rsp]
     4c5:	mov    r13,QWORD PTR [rsp+0x8]
     4ca:	mov    rdi,r15
     4cd:	mov    rcx,QWORD PTR [rdi+0x10]
     4d1:	mov    r8,QWORD PTR [rcx+0x8]
     4d5:	mov    rcx,r13
     4d8:	mov    rdx,r12
     4db:	mov    rsi,QWORD PTR [rsp+0x28]
     4e0:	call   4e5 <botlish_fn_3+0xb7>
			4e1: R_X86_64_PLT32	rt_str_region_eq-0x4
     4e5:	cmp    rax,0x6
     4e9:	je     528 <botlish_fn_3+0xfa>
     4ef:	mov    rdi,r15
     4f2:	mov    rax,QWORD PTR [rdi+0x10]
     4f6:	mov    r8,QWORD PTR [rax+0x10]
     4fa:	mov    rcx,r13
     4fd:	mov    rdx,r12
     500:	mov    rsi,QWORD PTR [rsp+0x28]
     505:	call   50a <botlish_fn_3+0xdc>
			506: R_X86_64_PLT32	rt_str_region_eq-0x4
     50a:	cmp    rax,0x6
     50e:	je     51e <botlish_fn_3+0xf0>
     514:	mov    eax,0x2
     519:	jmp    52d <botlish_fn_3+0xff>
     51e:	mov    eax,0x6
     523:	jmp    52d <botlish_fn_3+0xff>
     528:	mov    eax,0x6
     52d:	cmp    rax,0x6
     531:	je     570 <botlish_fn_3+0x142>
     537:	mov    rdi,r15
     53a:	mov    rcx,QWORD PTR [rdi+0x10]
     53e:	mov    r8,QWORD PTR [rcx+0x18]
     542:	mov    rcx,r13
     545:	mov    rdx,r12
     548:	mov    rsi,QWORD PTR [rsp+0x28]
     54d:	call   552 <botlish_fn_3+0x124>
			54e: R_X86_64_PLT32	rt_str_region_eq-0x4
     552:	cmp    rax,0x6
     556:	je     566 <botlish_fn_3+0x138>
     55c:	mov    eax,0x2
     561:	jmp    575 <botlish_fn_3+0x147>
     566:	mov    eax,0x6
     56b:	jmp    575 <botlish_fn_3+0x147>
     570:	mov    eax,0x6
     575:	cmp    rax,0x6
     579:	je     5f0 <botlish_fn_3+0x1c2>
     57f:	mov    QWORD PTR [r14+0x18],0x3
     587:	mov    rsi,QWORD PTR [rsp+0x20]
     58c:	test   rsi,0x1
     593:	je     5ba <botlish_fn_3+0x18c>
     599:	mov    rsi,QWORD PTR [rsp+0x20]
     59e:	mov    rax,rsi
     5a1:	add    rax,0x2
     5a5:	seto   cl
     5a8:	test   cl,cl
     5aa:	jne    5ba <botlish_fn_3+0x18c>
     5b0:	mov    rsi,QWORD PTR [rsp+0x10]
     5b5:	jmp    5d1 <botlish_fn_3+0x1a3>
     5ba:	mov    edx,0x3
     5bf:	mov    rsi,QWORD PTR [rsp+0x20]
     5c4:	mov    rdi,r15
     5c7:	call   5cc <botlish_fn_3+0x19e>
			5c8: R_X86_64_PLT32	rt_int_add-0x4
     5cc:	mov    rsi,QWORD PTR [rsp+0x10]
     5d1:	mov    QWORD PTR [r14],rsi
     5d4:	mov    rdx,QWORD PTR [rsp+0x18]
     5d9:	mov    QWORD PTR [r14+0x8],rdx
     5dd:	mov    QWORD PTR [r14+0x10],rax
     5e1:	mov    QWORD PTR [rsp+0x10],rsi
     5e6:	mov    QWORD PTR [rsp+0x20],rax
     5eb:	jmp    493 <botlish_fn_3+0x65>
     5f0:	mov    rdx,QWORD PTR [rsp+0x18]
     5f5:	mov    rsi,QWORD PTR [rsp+0x10]
     5fa:	mov    rcx,QWORD PTR [rsp+0x20]
     5ff:	mov    rdi,r15
     602:	call   607 <botlish_fn_3+0x1d9>
			603: R_X86_64_PLT32	rt_substr-0x4
     607:	test   rax,rax
     60a:	jne    641 <botlish_fn_3+0x213>
     610:	mov    rdi,r15
     613:	mov    rdi,r15
     616:	mov    QWORD PTR [rdi],r14
     619:	xor    rdx,rdx
     61c:	mov    rax,rdx
     61f:	mov    rbx,QWORD PTR [rsp+0x30]
     624:	mov    r12,QWORD PTR [rsp+0x38]
     629:	mov    r13,QWORD PTR [rsp+0x40]
     62e:	mov    r14,QWORD PTR [rsp+0x48]
     633:	mov    r15,QWORD PTR [rsp+0x50]
     638:	add    rsp,0x60
     63c:	mov    rsp,rbp
     63f:	pop    rbp
     640:	ret
     641:	mov    rdi,r15
     644:	mov    QWORD PTR [rdi],r14
     647:	mov    rdx,QWORD PTR [rsp+0x20]
     64c:	mov    rbx,QWORD PTR [rsp+0x30]
     651:	mov    r12,QWORD PTR [rsp+0x38]
     656:	mov    r13,QWORD PTR [rsp+0x40]
     65b:	mov    r14,QWORD PTR [rsp+0x48]
     660:	mov    r15,QWORD PTR [rsp+0x50]
     665:	add    rsp,0x60
     669:	mov    rsp,rbp
     66c:	pop    rbp
     66d:	ret
     66e:	mov    r15,rdi
     671:	call   676 <botlish_fn_3+0x248>
			672: R_X86_64_PLT32	rt_stack_overflow-0x4
     676:	xor    rdx,rdx
     679:	mov    rax,rdx
     67c:	mov    rbx,QWORD PTR [rsp+0x30]
     681:	mov    r12,QWORD PTR [rsp+0x38]
     686:	mov    r13,QWORD PTR [rsp+0x40]
     68b:	mov    r14,QWORD PTR [rsp+0x48]
     690:	mov    r15,QWORD PTR [rsp+0x50]
     695:	add    rsp,0x60
     699:	mov    rsp,rbp
     69c:	pop    rbp
     69d:	ret

000000000000069e <botlish_entry_3: scan_unquoted<str, int, int>>:
     69e:	push   rbp
     69f:	mov    rbp,rsp
     6a2:	ud2

00000000000006a4 <botlish_fn_4: scan_quoted<str, int, str>>:
     6a4:	push   rbp
     6a5:	mov    rbp,rsp
     6a8:	sub    rsp,0x50
     6ac:	mov    QWORD PTR [rsp+0x20],rbx
     6b1:	mov    QWORD PTR [rsp+0x28],r12
     6b6:	mov    QWORD PTR [rsp+0x30],r13
     6bb:	mov    QWORD PTR [rsp+0x38],r14
     6c0:	mov    QWORD PTR [rsp+0x40],r15
     6c5:	mov    r13,QWORD PTR [rdi]
     6c8:	mov    rax,QWORD PTR [rdi+0x8]
     6cc:	lea    r8,[r13+0x28]
     6d0:	cmp    r8,rax
     6d3:	ja     9a5 <botlish_fn_4+0x301>
     6d9:	lea    rax,[r13+0x28]
     6dd:	mov    QWORD PTR [rdi],rax
     6e0:	mov    r14,rdi
     6e3:	mov    QWORD PTR [r13+0x18],0x0
     6eb:	mov    QWORD PTR [r13+0x20],0x0
     6f3:	mov    QWORD PTR [r13+0x0],rsi
     6f7:	mov    QWORD PTR [r13+0x8],rdx
     6fb:	mov    QWORD PTR [r13+0x10],rcx
     6ff:	lea    rbx,[rsp]
     703:	mov    r12,rsi
     706:	mov    r15,rdx
     709:	mov    QWORD PTR [rsp+0x10],rcx
     70e:	mov    rdx,r15
     711:	mov    rsi,r12
     714:	mov    rdi,r14
     717:	call   71c <botlish_fn_4+0x78>
			718: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     71c:	test   rax,rax
     71f:	jne    72d <botlish_fn_4+0x89>
     725:	mov    rdi,r14
     728:	jmp    95e <botlish_fn_4+0x2ba>
     72d:	mov    QWORD PTR [r13+0x18],rax
     731:	mov    rdi,r14
     734:	mov    QWORD PTR [rsp+0x18],rax
     739:	mov    rdx,QWORD PTR [rdi+0x10]
     73d:	mov    rsi,QWORD PTR [rdx+0x20]
     741:	mov    edx,0x1
     746:	mov    ecx,0x3
     74b:	mov    r8,QWORD PTR [rsp+0x18]
     750:	call   755 <botlish_fn_4+0xb1>
			751: R_X86_64_PLT32	rt_str_region_eq-0x4
     755:	cmp    rax,0x6
     759:	je     7e6 <botlish_fn_4+0x142>
     75f:	mov    QWORD PTR [r13+0x20],0x3
     767:	mov    rsi,r15
     76a:	test   rsi,0x1
     771:	je     793 <botlish_fn_4+0xef>
     777:	mov    r8,rsi
     77a:	add    r8,0x2
     77e:	seto   r10b
     782:	test   r10b,r10b
     785:	jne    793 <botlish_fn_4+0xef>
     78b:	mov    rsi,r8
     78e:	jmp    7a3 <botlish_fn_4+0xff>
     793:	mov    edx,0x3
     798:	mov    rdi,r14
     79b:	call   7a0 <botlish_fn_4+0xfc>
			79c: R_X86_64_PLT32	rt_int_add-0x4
     7a0:	mov    rsi,rax
     7a3:	mov    QWORD PTR [r13+0x8],rsi
     7a7:	mov    r15,rsi
     7aa:	mov    rsi,QWORD PTR [rsp+0x10]
     7af:	mov    rdx,QWORD PTR [rsp+0x18]
     7b4:	mov    rdi,r14
     7b7:	call   7bc <botlish_fn_4+0x118>
			7b8: R_X86_64_PLT32	rt_str_cat-0x4
     7bc:	test   rax,rax
     7bf:	jne    7cd <botlish_fn_4+0x129>
     7c5:	mov    rdi,r14
     7c8:	jmp    95e <botlish_fn_4+0x2ba>
     7cd:	mov    QWORD PTR [r13+0x0],r12
     7d1:	mov    rsi,r15
     7d4:	mov    QWORD PTR [r13+0x8],rsi
     7d8:	mov    QWORD PTR [r13+0x10],rax
     7dc:	mov    QWORD PTR [rsp+0x10],rax
     7e1:	jmp    70e <botlish_fn_4+0x6a>
     7e6:	mov    QWORD PTR [r13+0x18],0x3
     7ee:	mov    rsi,r15
     7f1:	test   rsi,0x1
     7f8:	je     813 <botlish_fn_4+0x16f>
     7fe:	mov    rsi,r15
     801:	mov    rdx,rsi
     804:	add    rdx,0x2
     808:	seto   al
     80b:	test   al,al
     80d:	je     826 <botlish_fn_4+0x182>
     813:	mov    edx,0x3
     818:	mov    rsi,r15
     81b:	mov    rdi,r14
     81e:	call   823 <botlish_fn_4+0x17f>
			81f: R_X86_64_PLT32	rt_int_add-0x4
     823:	mov    rdx,rax
     826:	mov    QWORD PTR [r13+0x18],rdx
     82a:	mov    rcx,rbx
     82d:	mov    rsi,r12
     830:	mov    rdi,r14
     833:	call   838 <botlish_fn_4+0x194>
			834: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     838:	test   rax,rax
     83b:	mov    rsi,rax
     83e:	jne    84c <botlish_fn_4+0x1a8>
     844:	mov    rdi,r14
     847:	jmp    95e <botlish_fn_4+0x2ba>
     84c:	mov    rdx,QWORD PTR [rsp]
     850:	mov    rcx,QWORD PTR [rsp+0x8]
     855:	mov    rdi,r14
     858:	mov    rax,QWORD PTR [rdi+0x10]
     85c:	mov    r8,QWORD PTR [rax+0x20]
     860:	call   865 <botlish_fn_4+0x1c1>
			861: R_X86_64_PLT32	rt_str_region_eq-0x4
     865:	cmp    rax,0x6
     869:	je     8e7 <botlish_fn_4+0x243>
     86f:	mov    QWORD PTR [r13+0x0],0x3
     877:	mov    rsi,r15
     87a:	test   rsi,0x1
     881:	je     8a4 <botlish_fn_4+0x200>
     887:	mov    rsi,r15
     88a:	mov    rdx,rsi
     88d:	add    rdx,0x2
     891:	seto   al
     894:	test   al,al
     896:	jne    8a4 <botlish_fn_4+0x200>
     89c:	mov    rdi,r14
     89f:	jmp    8ba <botlish_fn_4+0x216>
     8a4:	mov    edx,0x3
     8a9:	mov    rsi,r15
     8ac:	mov    rdi,r14
     8af:	call   8b4 <botlish_fn_4+0x210>
			8b0: R_X86_64_PLT32	rt_int_add-0x4
     8b4:	mov    rdx,rax
     8b7:	mov    rdi,r14
     8ba:	mov    rdi,r14
     8bd:	mov    QWORD PTR [rdi],r13
     8c0:	mov    rax,QWORD PTR [rsp+0x10]
     8c5:	mov    rbx,QWORD PTR [rsp+0x20]
     8ca:	mov    r12,QWORD PTR [rsp+0x28]
     8cf:	mov    r13,QWORD PTR [rsp+0x30]
     8d4:	mov    r14,QWORD PTR [rsp+0x38]
     8d9:	mov    r15,QWORD PTR [rsp+0x40]
     8de:	add    rsp,0x50
     8e2:	mov    rsp,rbp
     8e5:	pop    rbp
     8e6:	ret
     8e7:	mov    QWORD PTR [r13+0x18],0x5
     8ef:	mov    rsi,r15
     8f2:	test   rsi,0x1
     8f9:	je     91f <botlish_fn_4+0x27b>
     8ff:	mov    rsi,r15
     902:	mov    rax,rsi
     905:	add    rax,0x4
     909:	seto   cl
     90c:	test   cl,cl
     90e:	jne    91f <botlish_fn_4+0x27b>
     914:	mov    rsi,rax
     917:	mov    r15,rax
     91a:	jmp    935 <botlish_fn_4+0x291>
     91f:	mov    edx,0x5
     924:	mov    rsi,r15
     927:	mov    rdi,r14
     92a:	call   92f <botlish_fn_4+0x28b>
			92b: R_X86_64_PLT32	rt_int_add-0x4
     92f:	mov    rsi,rax
     932:	mov    r15,rax
     935:	mov    QWORD PTR [r13+0x8],rsi
     939:	mov    rdi,r14
     93c:	mov    rax,QWORD PTR [rdi+0x10]
     940:	mov    rdx,QWORD PTR [rax+0x20]
     944:	mov    QWORD PTR [r13+0x18],rdx
     948:	mov    rsi,QWORD PTR [rsp+0x10]
     94d:	call   952 <botlish_fn_4+0x2ae>
			94e: R_X86_64_PLT32	rt_str_cat-0x4
     952:	test   rax,rax
     955:	jne    98c <botlish_fn_4+0x2e8>
     95b:	mov    rdi,r14
     95e:	mov    rdi,r14
     961:	mov    QWORD PTR [rdi],r13
     964:	xor    rdx,rdx
     967:	mov    rax,rdx
     96a:	mov    rbx,QWORD PTR [rsp+0x20]
     96f:	mov    r12,QWORD PTR [rsp+0x28]
     974:	mov    r13,QWORD PTR [rsp+0x30]
     979:	mov    r14,QWORD PTR [rsp+0x38]
     97e:	mov    r15,QWORD PTR [rsp+0x40]
     983:	add    rsp,0x50
     987:	mov    rsp,rbp
     98a:	pop    rbp
     98b:	ret
     98c:	mov    QWORD PTR [r13+0x0],r12
     990:	mov    rsi,r15
     993:	mov    QWORD PTR [r13+0x8],rsi
     997:	mov    QWORD PTR [r13+0x10],rax
     99b:	mov    QWORD PTR [rsp+0x10],rax
     9a0:	jmp    70e <botlish_fn_4+0x6a>
     9a5:	mov    r14,rdi
     9a8:	call   9ad <botlish_fn_4+0x309>
			9a9: R_X86_64_PLT32	rt_stack_overflow-0x4
     9ad:	xor    rdx,rdx
     9b0:	mov    rax,rdx
     9b3:	mov    rbx,QWORD PTR [rsp+0x20]
     9b8:	mov    r12,QWORD PTR [rsp+0x28]
     9bd:	mov    r13,QWORD PTR [rsp+0x30]
     9c2:	mov    r14,QWORD PTR [rsp+0x38]
     9c7:	mov    r15,QWORD PTR [rsp+0x40]
     9cc:	add    rsp,0x50
     9d0:	mov    rsp,rbp
     9d3:	pop    rbp
     9d4:	ret

00000000000009d5 <botlish_entry_4: scan_quoted<str, int, str>>:
     9d5:	push   rbp
     9d6:	mov    rbp,rsp
     9d9:	ud2

00000000000009db <botlish_fn_5: scan_field<str, int>>:
     9db:	push   rbp
     9dc:	mov    rbp,rsp
     9df:	sub    rsp,0x30
     9e3:	mov    QWORD PTR [rsp+0x10],rbx
     9e8:	mov    QWORD PTR [rsp+0x18],r12
     9ed:	mov    QWORD PTR [rsp+0x20],r13
     9f2:	mov    QWORD PTR [rsp+0x28],r14
     9f7:	mov    rbx,QWORD PTR [rdi]
     9fa:	mov    rax,QWORD PTR [rdi+0x8]
     9fe:	lea    rcx,[rbx+0x18]
     a02:	cmp    rcx,rax
     a05:	ja     b68 <botlish_fn_5+0x18d>
     a0b:	lea    rax,[rbx+0x18]
     a0f:	mov    QWORD PTR [rdi],rax
     a12:	mov    r12,rdi
     a15:	mov    QWORD PTR [rbx+0x10],0x0
     a1d:	mov    QWORD PTR [rbx],rsi
     a20:	mov    r13,rsi
     a23:	mov    QWORD PTR [rbx+0x8],rdx
     a27:	mov    r14,rdx
     a2a:	lea    rcx,[rsp]
     a2e:	mov    rdx,r14
     a31:	mov    rsi,r13
     a34:	mov    rdi,r12
     a37:	call   a3c <botlish_fn_5+0x61>
			a38: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a3c:	test   rax,rax
     a3f:	mov    rsi,rax
     a42:	jne    a50 <botlish_fn_5+0x75>
     a48:	mov    rdi,r12
     a4b:	jmp    b1c <botlish_fn_5+0x141>
     a50:	mov    rdx,QWORD PTR [rsp]
     a54:	mov    rcx,QWORD PTR [rsp+0x8]
     a59:	mov    rdi,r12
     a5c:	mov    rax,QWORD PTR [rdi+0x10]
     a60:	mov    r8,QWORD PTR [rax+0x20]
     a64:	call   a69 <botlish_fn_5+0x8e>
			a65: R_X86_64_PLT32	rt_str_region_eq-0x4
     a69:	cmp    rax,0x6
     a6d:	je     ab8 <botlish_fn_5+0xdd>
     a73:	mov    rcx,r14
     a76:	mov    rsi,r13
     a79:	mov    rdi,r12
     a7c:	mov    rdx,rcx
     a7f:	call   a84 <botlish_fn_5+0xa9>
			a80: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     a84:	test   rax,rax
     a87:	jne    a95 <botlish_fn_5+0xba>
     a8d:	mov    rdi,r12
     a90:	jmp    b1c <botlish_fn_5+0x141>
     a95:	mov    rdi,r12
     a98:	mov    QWORD PTR [rdi],rbx
     a9b:	mov    rbx,QWORD PTR [rsp+0x10]
     aa0:	mov    r12,QWORD PTR [rsp+0x18]
     aa5:	mov    r13,QWORD PTR [rsp+0x20]
     aaa:	mov    r14,QWORD PTR [rsp+0x28]
     aaf:	add    rsp,0x30
     ab3:	mov    rsp,rbp
     ab6:	pop    rbp
     ab7:	ret
     ab8:	mov    QWORD PTR [rbx+0x10],0x3
     ac0:	mov    rdx,r14
     ac3:	test   rdx,0x1
     aca:	je     ae2 <botlish_fn_5+0x107>
     ad0:	mov    rdx,r14
     ad3:	add    rdx,0x2
     ad7:	seto   al
     ada:	test   al,al
     adc:	je     af5 <botlish_fn_5+0x11a>
     ae2:	mov    edx,0x3
     ae7:	mov    rsi,r14
     aea:	mov    rdi,r12
     aed:	call   af2 <botlish_fn_5+0x117>
			aee: R_X86_64_PLT32	rt_int_add-0x4
     af2:	mov    rdx,rax
     af5:	mov    QWORD PTR [rbx+0x8],rdx
     af9:	mov    rdi,r12
     afc:	mov    rax,QWORD PTR [rdi+0x10]
     b00:	mov    rcx,QWORD PTR [rax+0x8]
     b04:	mov    QWORD PTR [rbx+0x10],rcx
     b08:	mov    rsi,r13
     b0b:	call   b10 <botlish_fn_5+0x135>
			b0c: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     b10:	test   rax,rax
     b13:	jne    b45 <botlish_fn_5+0x16a>
     b19:	mov    rdi,r12
     b1c:	mov    rdi,r12
     b1f:	mov    QWORD PTR [rdi],rbx
     b22:	xor    rdx,rdx
     b25:	mov    rax,rdx
     b28:	mov    rbx,QWORD PTR [rsp+0x10]
     b2d:	mov    r12,QWORD PTR [rsp+0x18]
     b32:	mov    r13,QWORD PTR [rsp+0x20]
     b37:	mov    r14,QWORD PTR [rsp+0x28]
     b3c:	add    rsp,0x30
     b40:	mov    rsp,rbp
     b43:	pop    rbp
     b44:	ret
     b45:	mov    rdi,r12
     b48:	mov    QWORD PTR [rdi],rbx
     b4b:	mov    rbx,QWORD PTR [rsp+0x10]
     b50:	mov    r12,QWORD PTR [rsp+0x18]
     b55:	mov    r13,QWORD PTR [rsp+0x20]
     b5a:	mov    r14,QWORD PTR [rsp+0x28]
     b5f:	add    rsp,0x30
     b63:	mov    rsp,rbp
     b66:	pop    rbp
     b67:	ret
     b68:	mov    r12,rdi
     b6b:	call   b70 <botlish_fn_5+0x195>
			b6c: R_X86_64_PLT32	rt_stack_overflow-0x4
     b70:	xor    rdx,rdx
     b73:	mov    rax,rdx
     b76:	mov    rbx,QWORD PTR [rsp+0x10]
     b7b:	mov    r12,QWORD PTR [rsp+0x18]
     b80:	mov    r13,QWORD PTR [rsp+0x20]
     b85:	mov    r14,QWORD PTR [rsp+0x28]
     b8a:	add    rsp,0x30
     b8e:	mov    rsp,rbp
     b91:	pop    rbp
     b92:	ret

0000000000000b93 <botlish_entry_5: scan_field<str, int>>:
     b93:	push   rbp
     b94:	mov    rbp,rsp
     b97:	ud2

0000000000000b99 <botlish_fn_6: scan_record<str, int, list<never>>>:
     b99:	push   rbp
     b9a:	mov    rbp,rsp
     b9d:	sub    rsp,0x60
     ba1:	mov    QWORD PTR [rsp+0x30],rbx
     ba6:	mov    QWORD PTR [rsp+0x38],r12
     bab:	mov    QWORD PTR [rsp+0x40],r13
     bb0:	mov    QWORD PTR [rsp+0x48],r14
     bb5:	mov    QWORD PTR [rsp+0x50],r15
     bba:	mov    r13,QWORD PTR [rdi]
     bbd:	mov    rax,QWORD PTR [rdi+0x8]
     bc1:	lea    r8,[r13+0x20]
     bc5:	cmp    r8,rax
     bc8:	ja     e35 <botlish_fn_6+0x29c>
     bce:	lea    rax,[r13+0x20]
     bd2:	mov    QWORD PTR [rdi],rax
     bd5:	mov    r14,rdi
     bd8:	mov    QWORD PTR [r13+0x18],0x0
     be0:	mov    QWORD PTR [r13+0x0],rsi
     be4:	mov    QWORD PTR [rsp+0x10],rsi
     be9:	mov    QWORD PTR [r13+0x8],rdx
     bed:	mov    QWORD PTR [r13+0x10],rcx
     bf1:	mov    r12,rcx
     bf4:	mov    rsi,QWORD PTR [rsp+0x10]
     bf9:	mov    rdi,r14
     bfc:	call   c01 <botlish_fn_6+0x68>
			bfd: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     c01:	test   rax,rax
     c04:	jne    c12 <botlish_fn_6+0x79>
     c0a:	mov    rdi,r14
     c0d:	jmp    ddf <botlish_fn_6+0x246>
     c12:	mov    QWORD PTR [r13+0x8],rax
     c16:	mov    QWORD PTR [r13+0x18],rdx
     c1a:	mov    QWORD PTR [rsp+0x20],rdx
     c1f:	mov    rsi,r12
     c22:	mov    rdx,rax
     c25:	mov    rdi,r14
     c28:	call   c2d <botlish_fn_6+0x94>
			c29: R_X86_64_PLT32	rt_list_append-0x4
     c2d:	mov    rcx,rax
     c30:	mov    r15,rax
     c33:	test   rax,rcx
     c36:	jne    c44 <botlish_fn_6+0xab>
     c3c:	mov    rdi,r14
     c3f:	jmp    ddf <botlish_fn_6+0x246>
     c44:	mov    rax,r15
     c47:	mov    QWORD PTR [r13+0x8],rax
     c4b:	lea    rcx,[rsp]
     c4f:	mov    rdx,QWORD PTR [rsp+0x20]
     c54:	mov    rsi,QWORD PTR [rsp+0x10]
     c59:	mov    rdi,r14
     c5c:	call   c61 <botlish_fn_6+0xc8>
			c5d: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     c61:	test   rax,rax
     c64:	mov    QWORD PTR [rsp+0x18],rax
     c69:	jne    c77 <botlish_fn_6+0xde>
     c6f:	mov    rdi,r14
     c72:	jmp    ddf <botlish_fn_6+0x246>
     c77:	mov    rbx,QWORD PTR [rsp]
     c7b:	mov    r12,QWORD PTR [rsp+0x8]
     c80:	mov    rdi,r14
     c83:	mov    rcx,QWORD PTR [rdi+0x10]
     c87:	mov    r8,QWORD PTR [rcx+0x10]
     c8b:	mov    rcx,r12
     c8e:	mov    rdx,rbx
     c91:	mov    rsi,QWORD PTR [rsp+0x18]
     c96:	call   c9b <botlish_fn_6+0x102>
			c97: R_X86_64_PLT32	rt_str_region_eq-0x4
     c9b:	cmp    rax,0x6
     c9f:	je     d75 <botlish_fn_6+0x1dc>
     ca5:	mov    rdi,r14
     ca8:	mov    rax,QWORD PTR [rdi+0x10]
     cac:	mov    r8,QWORD PTR [rax+0x18]
     cb0:	mov    rcx,r12
     cb3:	mov    rdx,rbx
     cb6:	mov    rsi,QWORD PTR [rsp+0x18]
     cbb:	call   cc0 <botlish_fn_6+0x127>
			cbc: R_X86_64_PLT32	rt_str_region_eq-0x4
     cc0:	cmp    rax,0x6
     cc4:	je     cfa <botlish_fn_6+0x161>
     cca:	mov    rdi,r14
     ccd:	mov    QWORD PTR [rdi],r13
     cd0:	mov    rax,r15
     cd3:	mov    rdx,QWORD PTR [rsp+0x20]
     cd8:	mov    rbx,QWORD PTR [rsp+0x30]
     cdd:	mov    r12,QWORD PTR [rsp+0x38]
     ce2:	mov    r13,QWORD PTR [rsp+0x40]
     ce7:	mov    r14,QWORD PTR [rsp+0x48]
     cec:	mov    r15,QWORD PTR [rsp+0x50]
     cf1:	add    rsp,0x60
     cf5:	mov    rsp,rbp
     cf8:	pop    rbp
     cf9:	ret
     cfa:	mov    QWORD PTR [r13+0x0],0x3
     d02:	mov    rdx,QWORD PTR [rsp+0x20]
     d07:	test   rdx,0x1
     d0e:	je     d32 <botlish_fn_6+0x199>
     d14:	mov    rdx,QWORD PTR [rsp+0x20]
     d19:	add    rdx,0x2
     d1d:	seto   dil
     d21:	test   dil,dil
     d24:	jne    d32 <botlish_fn_6+0x199>
     d2a:	mov    rdi,r14
     d2d:	jmp    d4a <botlish_fn_6+0x1b1>
     d32:	mov    edx,0x3
     d37:	mov    rsi,QWORD PTR [rsp+0x20]
     d3c:	mov    rdi,r14
     d3f:	call   d44 <botlish_fn_6+0x1ab>
			d40: R_X86_64_PLT32	rt_int_add-0x4
     d44:	mov    rdx,rax
     d47:	mov    rdi,r14
     d4a:	mov    rdi,r14
     d4d:	mov    QWORD PTR [rdi],r13
     d50:	mov    rax,r15
     d53:	mov    rbx,QWORD PTR [rsp+0x30]
     d58:	mov    r12,QWORD PTR [rsp+0x38]
     d5d:	mov    r13,QWORD PTR [rsp+0x40]
     d62:	mov    r14,QWORD PTR [rsp+0x48]
     d67:	mov    r15,QWORD PTR [rsp+0x50]
     d6c:	add    rsp,0x60
     d70:	mov    rsp,rbp
     d73:	pop    rbp
     d74:	ret
     d75:	mov    rsi,QWORD PTR [rsp+0x20]
     d7a:	mov    edx,0x3
     d7f:	mov    r10,rdx
     d82:	mov    QWORD PTR [r13+0x10],0x3
     d8a:	test   rsi,0x1
     d91:	jne    d9f <botlish_fn_6+0x206>
     d97:	mov    rdx,r10
     d9a:	jmp    db4 <botlish_fn_6+0x21b>
     d9f:	mov    rdx,rsi
     da2:	add    rdx,0x2
     da6:	seto   al
     da9:	test   al,al
     dab:	je     dbf <botlish_fn_6+0x226>
     db1:	mov    rdx,r10
     db4:	mov    rdi,r14
     db7:	call   dbc <botlish_fn_6+0x223>
			db8: R_X86_64_PLT32	rt_int_add-0x4
     dbc:	mov    rdx,rax
     dbf:	mov    QWORD PTR [r13+0x10],rdx
     dc3:	mov    rcx,r15
     dc6:	mov    rsi,QWORD PTR [rsp+0x10]
     dcb:	mov    rdi,r14
     dce:	call   dd3 <botlish_fn_6+0x23a>
			dcf: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, list<str>>
     dd3:	test   rax,rax
     dd6:	jne    e0d <botlish_fn_6+0x274>
     ddc:	mov    rdi,r14
     ddf:	mov    rdi,r14
     de2:	mov    QWORD PTR [rdi],r13
     de5:	xor    rdx,rdx
     de8:	mov    rax,rdx
     deb:	mov    rbx,QWORD PTR [rsp+0x30]
     df0:	mov    r12,QWORD PTR [rsp+0x38]
     df5:	mov    r13,QWORD PTR [rsp+0x40]
     dfa:	mov    r14,QWORD PTR [rsp+0x48]
     dff:	mov    r15,QWORD PTR [rsp+0x50]
     e04:	add    rsp,0x60
     e08:	mov    rsp,rbp
     e0b:	pop    rbp
     e0c:	ret
     e0d:	mov    rdi,r14
     e10:	mov    QWORD PTR [rdi],r13
     e13:	mov    rbx,QWORD PTR [rsp+0x30]
     e18:	mov    r12,QWORD PTR [rsp+0x38]
     e1d:	mov    r13,QWORD PTR [rsp+0x40]
     e22:	mov    r14,QWORD PTR [rsp+0x48]
     e27:	mov    r15,QWORD PTR [rsp+0x50]
     e2c:	add    rsp,0x60
     e30:	mov    rsp,rbp
     e33:	pop    rbp
     e34:	ret
     e35:	mov    r14,rdi
     e38:	call   e3d <botlish_fn_6+0x2a4>
			e39: R_X86_64_PLT32	rt_stack_overflow-0x4
     e3d:	xor    rdx,rdx
     e40:	mov    rax,rdx
     e43:	mov    rbx,QWORD PTR [rsp+0x30]
     e48:	mov    r12,QWORD PTR [rsp+0x38]
     e4d:	mov    r13,QWORD PTR [rsp+0x40]
     e52:	mov    r14,QWORD PTR [rsp+0x48]
     e57:	mov    r15,QWORD PTR [rsp+0x50]
     e5c:	add    rsp,0x60
     e60:	mov    rsp,rbp
     e63:	pop    rbp
     e64:	ret

0000000000000e65 <botlish_entry_6: scan_record<str, int, list<never>>>:
     e65:	push   rbp
     e66:	mov    rbp,rsp
     e69:	ud2

0000000000000e6b <botlish_fn_7: scan_record<str, int, list<str>>>:
     e6b:	push   rbp
     e6c:	mov    rbp,rsp
     e6f:	sub    rsp,0x60
     e73:	mov    QWORD PTR [rsp+0x30],rbx
     e78:	mov    QWORD PTR [rsp+0x38],r12
     e7d:	mov    QWORD PTR [rsp+0x40],r13
     e82:	mov    QWORD PTR [rsp+0x48],r14
     e87:	mov    QWORD PTR [rsp+0x50],r15
     e8c:	mov    r15,QWORD PTR [rdi]
     e8f:	mov    rax,QWORD PTR [rdi+0x8]
     e93:	lea    r8,[r15+0x20]
     e97:	cmp    r8,rax
     e9a:	ja     10f7 <botlish_fn_7+0x28c>
     ea0:	lea    rax,[r15+0x20]
     ea4:	mov    QWORD PTR [rdi],rax
     ea7:	mov    QWORD PTR [rsp+0x10],rdi
     eac:	mov    QWORD PTR [r15+0x18],0x0
     eb4:	mov    QWORD PTR [r15],rsi
     eb7:	mov    QWORD PTR [r15+0x8],rdx
     ebb:	mov    QWORD PTR [r15+0x10],rcx
     ebf:	lea    rbx,[rsp]
     ec3:	mov    r12,rsi
     ec6:	mov    r13,rcx
     ec9:	mov    rsi,r12
     ecc:	mov    rdi,QWORD PTR [rsp+0x10]
     ed1:	call   ed6 <botlish_fn_7+0x6b>
			ed2: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     ed6:	test   rax,rax
     ed9:	jne    ee9 <botlish_fn_7+0x7e>
     edf:	mov    rdi,QWORD PTR [rsp+0x10]
     ee4:	jmp    f52 <botlish_fn_7+0xe7>
     ee9:	mov    QWORD PTR [r15+0x8],rax
     eed:	mov    r8,rax
     ef0:	mov    QWORD PTR [r15+0x18],rdx
     ef4:	mov    QWORD PTR [rsp+0x28],rdx
     ef9:	mov    rsi,r13
     efc:	mov    rdx,r8
     eff:	mov    rdi,QWORD PTR [rsp+0x10]
     f04:	call   f09 <botlish_fn_7+0x9e>
			f05: R_X86_64_PLT32	rt_list_append-0x4
     f09:	test   rax,rax
     f0c:	mov    QWORD PTR [rsp+0x20],rax
     f11:	jne    f21 <botlish_fn_7+0xb6>
     f17:	mov    rdi,QWORD PTR [rsp+0x10]
     f1c:	jmp    f52 <botlish_fn_7+0xe7>
     f21:	mov    rax,QWORD PTR [rsp+0x20]
     f26:	mov    QWORD PTR [r15+0x8],rax
     f2a:	mov    rcx,rbx
     f2d:	mov    rdx,QWORD PTR [rsp+0x28]
     f32:	mov    rsi,r12
     f35:	mov    rdi,QWORD PTR [rsp+0x10]
     f3a:	call   f3f <botlish_fn_7+0xd4>
			f3b: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     f3f:	test   rax,rax
     f42:	mov    QWORD PTR [rsp+0x18],rax
     f47:	jne    f82 <botlish_fn_7+0x117>
     f4d:	mov    rdi,QWORD PTR [rsp+0x10]
     f52:	mov    rdi,QWORD PTR [rsp+0x10]
     f57:	mov    QWORD PTR [rdi],r15
     f5a:	xor    rdx,rdx
     f5d:	mov    rax,rdx
     f60:	mov    rbx,QWORD PTR [rsp+0x30]
     f65:	mov    r12,QWORD PTR [rsp+0x38]
     f6a:	mov    r13,QWORD PTR [rsp+0x40]
     f6f:	mov    r14,QWORD PTR [rsp+0x48]
     f74:	mov    r15,QWORD PTR [rsp+0x50]
     f79:	add    rsp,0x60
     f7d:	mov    rsp,rbp
     f80:	pop    rbp
     f81:	ret
     f82:	mov    r13,QWORD PTR [rsp]
     f86:	mov    r14,QWORD PTR [rsp+0x8]
     f8b:	mov    rdi,QWORD PTR [rsp+0x10]
     f90:	mov    rcx,QWORD PTR [rdi+0x10]
     f94:	mov    r8,QWORD PTR [rcx+0x10]
     f98:	mov    rcx,r14
     f9b:	mov    rdx,r13
     f9e:	mov    rsi,QWORD PTR [rsp+0x18]
     fa3:	call   fa8 <botlish_fn_7+0x13d>
			fa4: R_X86_64_PLT32	rt_str_region_eq-0x4
     fa8:	cmp    rax,0x6
     fac:	je     1091 <botlish_fn_7+0x226>
     fb2:	mov    rdi,QWORD PTR [rsp+0x10]
     fb7:	mov    rax,QWORD PTR [rdi+0x10]
     fbb:	mov    r8,QWORD PTR [rax+0x18]
     fbf:	mov    rcx,r14
     fc2:	mov    rdx,r13
     fc5:	mov    rsi,QWORD PTR [rsp+0x18]
     fca:	call   fcf <botlish_fn_7+0x164>
			fcb: R_X86_64_PLT32	rt_str_region_eq-0x4
     fcf:	cmp    rax,0x6
     fd3:	je     100d <botlish_fn_7+0x1a2>
     fd9:	mov    rdi,QWORD PTR [rsp+0x10]
     fde:	mov    QWORD PTR [rdi],r15
     fe1:	mov    rax,QWORD PTR [rsp+0x20]
     fe6:	mov    rdx,QWORD PTR [rsp+0x28]
     feb:	mov    rbx,QWORD PTR [rsp+0x30]
     ff0:	mov    r12,QWORD PTR [rsp+0x38]
     ff5:	mov    r13,QWORD PTR [rsp+0x40]
     ffa:	mov    r14,QWORD PTR [rsp+0x48]
     fff:	mov    r15,QWORD PTR [rsp+0x50]
    1004:	add    rsp,0x60
    1008:	mov    rsp,rbp
    100b:	pop    rbp
    100c:	ret
    100d:	mov    QWORD PTR [r15],0x3
    1014:	mov    rdx,QWORD PTR [rsp+0x28]
    1019:	test   rdx,0x1
    1020:	je     1046 <botlish_fn_7+0x1db>
    1026:	mov    rdx,QWORD PTR [rsp+0x28]
    102b:	add    rdx,0x2
    102f:	seto   r9b
    1033:	test   r9b,r9b
    1036:	jne    1046 <botlish_fn_7+0x1db>
    103c:	mov    rdi,QWORD PTR [rsp+0x10]
    1041:	jmp    1062 <botlish_fn_7+0x1f7>
    1046:	mov    edx,0x3
    104b:	mov    rsi,QWORD PTR [rsp+0x28]
    1050:	mov    rdi,QWORD PTR [rsp+0x10]
    1055:	call   105a <botlish_fn_7+0x1ef>
			1056: R_X86_64_PLT32	rt_int_add-0x4
    105a:	mov    rdx,rax
    105d:	mov    rdi,QWORD PTR [rsp+0x10]
    1062:	mov    rdi,QWORD PTR [rsp+0x10]
    1067:	mov    QWORD PTR [rdi],r15
    106a:	mov    rax,QWORD PTR [rsp+0x20]
    106f:	mov    rbx,QWORD PTR [rsp+0x30]
    1074:	mov    r12,QWORD PTR [rsp+0x38]
    1079:	mov    r13,QWORD PTR [rsp+0x40]
    107e:	mov    r14,QWORD PTR [rsp+0x48]
    1083:	mov    r15,QWORD PTR [rsp+0x50]
    1088:	add    rsp,0x60
    108c:	mov    rsp,rbp
    108f:	pop    rbp
    1090:	ret
    1091:	mov    rsi,QWORD PTR [rsp+0x28]
    1096:	mov    edx,0x3
    109b:	mov    rdi,rdx
    109e:	mov    QWORD PTR [r15+0x10],0x3
    10a6:	test   rsi,0x1
    10ad:	jne    10bb <botlish_fn_7+0x250>
    10b3:	mov    rdx,rdi
    10b6:	jmp    10d0 <botlish_fn_7+0x265>
    10bb:	mov    rdx,rsi
    10be:	add    rdx,0x2
    10c2:	seto   al
    10c5:	test   al,al
    10c7:	je     10dd <botlish_fn_7+0x272>
    10cd:	mov    rdx,rdi
    10d0:	mov    rdi,QWORD PTR [rsp+0x10]
    10d5:	call   10da <botlish_fn_7+0x26f>
			10d6: R_X86_64_PLT32	rt_int_add-0x4
    10da:	mov    rdx,rax
    10dd:	mov    QWORD PTR [r15],r12
    10e0:	mov    QWORD PTR [r15+0x8],rdx
    10e4:	mov    rax,QWORD PTR [rsp+0x20]
    10e9:	mov    QWORD PTR [r15+0x10],rax
    10ed:	mov    r13,QWORD PTR [rsp+0x20]
    10f2:	jmp    ec9 <botlish_fn_7+0x5e>
    10f7:	mov    QWORD PTR [rsp+0x10],rdi
    10fc:	call   1101 <botlish_fn_7+0x296>
			10fd: R_X86_64_PLT32	rt_stack_overflow-0x4
    1101:	xor    rdx,rdx
    1104:	mov    rax,rdx
    1107:	mov    rbx,QWORD PTR [rsp+0x30]
    110c:	mov    r12,QWORD PTR [rsp+0x38]
    1111:	mov    r13,QWORD PTR [rsp+0x40]
    1116:	mov    r14,QWORD PTR [rsp+0x48]
    111b:	mov    r15,QWORD PTR [rsp+0x50]
    1120:	add    rsp,0x60
    1124:	mov    rsp,rbp
    1127:	pop    rbp
    1128:	ret

0000000000001129 <botlish_entry_7: scan_record<str, int, list<str>>>:
    1129:	push   rbp
    112a:	mov    rbp,rsp
    112d:	ud2

000000000000112f <botlish_fn_8: scan_records<str, int, list<never>>>:
    112f:	push   rbp
    1130:	mov    rbp,rsp
    1133:	sub    rsp,0x30
    1137:	mov    QWORD PTR [rsp],rbx
    113b:	mov    QWORD PTR [rsp+0x8],r12
    1140:	mov    QWORD PTR [rsp+0x10],r13
    1145:	mov    QWORD PTR [rsp+0x18],r14
    114a:	mov    QWORD PTR [rsp+0x20],r15
    114f:	mov    rbx,QWORD PTR [rdi]
    1152:	mov    rax,QWORD PTR [rdi+0x8]
    1156:	lea    r8,[rbx+0x20]
    115a:	cmp    r8,rax
    115d:	ja     12b4 <botlish_fn_8+0x185>
    1163:	lea    rax,[rbx+0x20]
    1167:	mov    QWORD PTR [rdi],rax
    116a:	mov    r12,rdi
    116d:	mov    QWORD PTR [rbx+0x18],0x0
    1175:	mov    QWORD PTR [rbx],rsi
    1178:	mov    r13,rsi
    117b:	mov    QWORD PTR [rbx+0x8],rdx
    117f:	mov    r15,rdx
    1182:	mov    QWORD PTR [rbx+0x10],rcx
    1186:	mov    r14,rcx
    1189:	mov    rsi,r13
    118c:	mov    rdi,r12
    118f:	call   1194 <botlish_fn_8+0x65>
			1190: R_X86_64_PLT32	rt_str_len-0x4
    1194:	mov    rdx,r15
    1197:	mov    rcx,rdx
    119a:	sar    rcx,1
    119d:	sar    rax,1
    11a0:	cmp    rcx,rax
    11a3:	jge    128a <botlish_fn_8+0x15b>
    11a9:	xor    rdx,rdx
    11ac:	mov    rdi,r12
    11af:	mov    rsi,rdx
    11b2:	call   11b7 <botlish_fn_8+0x88>
			11b3: R_X86_64_PLT32	rt_list_new-0x4
    11b7:	test   rax,rax
    11ba:	jne    11c8 <botlish_fn_8+0x99>
    11c0:	mov    rdi,r12
    11c3:	jmp    1239 <botlish_fn_8+0x10a>
    11c8:	mov    QWORD PTR [rbx+0x18],rax
    11cc:	mov    rcx,rax
    11cf:	mov    rdx,r15
    11d2:	mov    rsi,r13
    11d5:	mov    rdi,r12
    11d8:	call   11dd <botlish_fn_8+0xae>
			11d9: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    11dd:	test   rax,rax
    11e0:	jne    11ee <botlish_fn_8+0xbf>
    11e6:	mov    rdi,r12
    11e9:	jmp    1239 <botlish_fn_8+0x10a>
    11ee:	mov    QWORD PTR [rbx+0x8],rax
    11f2:	mov    QWORD PTR [rbx+0x18],rdx
    11f6:	mov    rsi,r14
    11f9:	mov    r14,rdx
    11fc:	mov    rdx,rax
    11ff:	mov    rdi,r12
    1202:	call   1207 <botlish_fn_8+0xd8>
			1203: R_X86_64_PLT32	rt_list_append-0x4
    1207:	test   rax,rax
    120a:	jne    1218 <botlish_fn_8+0xe9>
    1210:	mov    rdi,r12
    1213:	jmp    1239 <botlish_fn_8+0x10a>
    1218:	mov    QWORD PTR [rbx+0x8],rax
    121c:	mov    rcx,rax
    121f:	mov    rdx,r14
    1222:	mov    rsi,r13
    1225:	mov    rdi,r12
    1228:	call   122d <botlish_fn_8+0xfe>
			1229: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    122d:	test   rax,rax
    1230:	jne    1263 <botlish_fn_8+0x134>
    1236:	mov    rdi,r12
    1239:	mov    rdi,r12
    123c:	mov    QWORD PTR [rdi],rbx
    123f:	xor    rax,rax
    1242:	mov    rbx,QWORD PTR [rsp]
    1246:	mov    r12,QWORD PTR [rsp+0x8]
    124b:	mov    r13,QWORD PTR [rsp+0x10]
    1250:	mov    r14,QWORD PTR [rsp+0x18]
    1255:	mov    r15,QWORD PTR [rsp+0x20]
    125a:	add    rsp,0x30
    125e:	mov    rsp,rbp
    1261:	pop    rbp
    1262:	ret
    1263:	mov    rdi,r12
    1266:	mov    QWORD PTR [rdi],rbx
    1269:	mov    rbx,QWORD PTR [rsp]
    126d:	mov    r12,QWORD PTR [rsp+0x8]
    1272:	mov    r13,QWORD PTR [rsp+0x10]
    1277:	mov    r14,QWORD PTR [rsp+0x18]
    127c:	mov    r15,QWORD PTR [rsp+0x20]
    1281:	add    rsp,0x30
    1285:	mov    rsp,rbp
    1288:	pop    rbp
    1289:	ret
    128a:	mov    rdi,r12
    128d:	mov    QWORD PTR [rdi],rbx
    1290:	mov    rax,r14
    1293:	mov    rbx,QWORD PTR [rsp]
    1297:	mov    r12,QWORD PTR [rsp+0x8]
    129c:	mov    r13,QWORD PTR [rsp+0x10]
    12a1:	mov    r14,QWORD PTR [rsp+0x18]
    12a6:	mov    r15,QWORD PTR [rsp+0x20]
    12ab:	add    rsp,0x30
    12af:	mov    rsp,rbp
    12b2:	pop    rbp
    12b3:	ret
    12b4:	mov    r12,rdi
    12b7:	call   12bc <botlish_fn_8+0x18d>
			12b8: R_X86_64_PLT32	rt_stack_overflow-0x4
    12bc:	xor    rax,rax
    12bf:	mov    rbx,QWORD PTR [rsp]
    12c3:	mov    r12,QWORD PTR [rsp+0x8]
    12c8:	mov    r13,QWORD PTR [rsp+0x10]
    12cd:	mov    r14,QWORD PTR [rsp+0x18]
    12d2:	mov    r15,QWORD PTR [rsp+0x20]
    12d7:	add    rsp,0x30
    12db:	mov    rsp,rbp
    12de:	pop    rbp
    12df:	ret

00000000000012e0 <botlish_entry_8: scan_records<str, int, list<never>>>:
    12e0:	push   rbp
    12e1:	mov    rbp,rsp
    12e4:	mov    rsi,QWORD PTR [rdx]
    12e7:	mov    r8,QWORD PTR [rdx+0x8]
    12eb:	mov    rcx,QWORD PTR [rdx+0x10]
    12ef:	mov    rdx,r8
    12f2:	call   12f7 <botlish_entry_8+0x17>
			12f3: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    12f7:	mov    rsp,rbp
    12fa:	pop    rbp
    12fb:	ret
    12fc:	add    BYTE PTR [rax],al
	...

0000000000001300 <botlish_fn_9: scan_records<str, int, list<list<str>>>>:
    1300:	push   rbp
    1301:	mov    rbp,rsp
    1304:	sub    rsp,0x30
    1308:	mov    QWORD PTR [rsp],rbx
    130c:	mov    QWORD PTR [rsp+0x8],r12
    1311:	mov    QWORD PTR [rsp+0x10],r13
    1316:	mov    QWORD PTR [rsp+0x18],r14
    131b:	mov    QWORD PTR [rsp+0x20],r15
    1320:	mov    r12,QWORD PTR [rdi]
    1323:	mov    rax,QWORD PTR [rdi+0x8]
    1327:	lea    r8,[r12+0x20]
    132c:	cmp    r8,rax
    132f:	ja     1498 <botlish_fn_9+0x198>
    1335:	lea    rax,[r12+0x20]
    133a:	mov    QWORD PTR [rdi],rax
    133d:	mov    r14,rdi
    1340:	mov    QWORD PTR [r12+0x18],0x0
    1349:	mov    QWORD PTR [r12],rsi
    134d:	mov    QWORD PTR [r12+0x8],rdx
    1352:	mov    r13,rdx
    1355:	mov    QWORD PTR [r12+0x10],rcx
    135a:	mov    rbx,rsi
    135d:	mov    r15,rcx
    1360:	mov    rsi,rbx
    1363:	mov    rdi,r14
    1366:	call   136b <botlish_fn_9+0x6b>
			1367: R_X86_64_PLT32	rt_str_len-0x4
    136b:	mov    rcx,r13
    136e:	and    rcx,rax
    1371:	mov    rdx,rax
    1374:	test   rcx,0x1
    137b:	jne    13a1 <botlish_fn_9+0xa1>
    1381:	mov    rsi,r13
    1384:	mov    rdi,r14
    1387:	call   138c <botlish_fn_9+0x8c>
			1388: R_X86_64_PLT32	rt_int_cmp-0x4
    138c:	mov    ecx,0x2
    1391:	test   rax,rax
    1394:	cmovge rcx,QWORD PTR [rip+0x12c]        # 14c8 <botlish_fn_9+0x1c8>
    139c:	jmp    13b4 <botlish_fn_9+0xb4>
    13a1:	mov    ecx,0x2
    13a6:	mov    rsi,r13
    13a9:	cmp    rsi,rdx
    13ac:	cmovge rcx,QWORD PTR [rip+0x114]        # 14c8 <botlish_fn_9+0x1c8>
    13b4:	cmp    rcx,0x6
    13b8:	je     146e <botlish_fn_9+0x16e>
    13be:	xor    rdx,rdx
    13c1:	mov    rdi,r14
    13c4:	mov    rsi,rdx
    13c7:	call   13cc <botlish_fn_9+0xcc>
			13c8: R_X86_64_PLT32	rt_list_new-0x4
    13cc:	test   rax,rax
    13cf:	jne    13dd <botlish_fn_9+0xdd>
    13d5:	mov    rdi,r14
    13d8:	jmp    142b <botlish_fn_9+0x12b>
    13dd:	mov    QWORD PTR [r12+0x18],rax
    13e2:	mov    rcx,rax
    13e5:	mov    rdx,r13
    13e8:	mov    rsi,rbx
    13eb:	mov    rdi,r14
    13ee:	call   13f3 <botlish_fn_9+0xf3>
			13ef: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    13f3:	test   rax,rax
    13f6:	jne    1404 <botlish_fn_9+0x104>
    13fc:	mov    rdi,r14
    13ff:	jmp    142b <botlish_fn_9+0x12b>
    1404:	mov    QWORD PTR [r12+0x8],rax
    1409:	mov    QWORD PTR [r12+0x18],rdx
    140e:	mov    r13,rdx
    1411:	mov    rsi,r15
    1414:	mov    rdx,rax
    1417:	mov    rdi,r14
    141a:	call   141f <botlish_fn_9+0x11f>
			141b: R_X86_64_PLT32	rt_list_append-0x4
    141f:	test   rax,rax
    1422:	jne    1455 <botlish_fn_9+0x155>
    1428:	mov    rdi,r14
    142b:	mov    rdi,r14
    142e:	mov    QWORD PTR [rdi],r12
    1431:	xor    rax,rax
    1434:	mov    rbx,QWORD PTR [rsp]
    1438:	mov    r12,QWORD PTR [rsp+0x8]
    143d:	mov    r13,QWORD PTR [rsp+0x10]
    1442:	mov    r14,QWORD PTR [rsp+0x18]
    1447:	mov    r15,QWORD PTR [rsp+0x20]
    144c:	add    rsp,0x30
    1450:	mov    rsp,rbp
    1453:	pop    rbp
    1454:	ret
    1455:	mov    QWORD PTR [r12],rbx
    1459:	mov    rdx,r13
    145c:	mov    QWORD PTR [r12+0x8],rdx
    1461:	mov    QWORD PTR [r12+0x10],rax
    1466:	mov    r15,rax
    1469:	jmp    1360 <botlish_fn_9+0x60>
    146e:	mov    rdi,r14
    1471:	mov    QWORD PTR [rdi],r12
    1474:	mov    rax,r15
    1477:	mov    rbx,QWORD PTR [rsp]
    147b:	mov    r12,QWORD PTR [rsp+0x8]
    1480:	mov    r13,QWORD PTR [rsp+0x10]
    1485:	mov    r14,QWORD PTR [rsp+0x18]
    148a:	mov    r15,QWORD PTR [rsp+0x20]
    148f:	add    rsp,0x30
    1493:	mov    rsp,rbp
    1496:	pop    rbp
    1497:	ret
    1498:	mov    r14,rdi
    149b:	call   14a0 <botlish_fn_9+0x1a0>
			149c: R_X86_64_PLT32	rt_stack_overflow-0x4
    14a0:	xor    rax,rax
    14a3:	mov    rbx,QWORD PTR [rsp]
    14a7:	mov    r12,QWORD PTR [rsp+0x8]
    14ac:	mov    r13,QWORD PTR [rsp+0x10]
    14b1:	mov    r14,QWORD PTR [rsp+0x18]
    14b6:	mov    r15,QWORD PTR [rsp+0x20]
    14bb:	add    rsp,0x30
    14bf:	mov    rsp,rbp
    14c2:	pop    rbp
    14c3:	ret
    14c4:	add    BYTE PTR [rax],al
    14c6:	add    BYTE PTR [rax],al
    14c8:	(bad)
    14c9:	add    BYTE PTR [rax],al
    14cb:	add    BYTE PTR [rax],al
    14cd:	add    BYTE PTR [rax],al
	...

00000000000014d0 <botlish_entry_9: scan_records<str, int, list<list<str>>>>:
    14d0:	push   rbp
    14d1:	mov    rbp,rsp
    14d4:	mov    rsi,QWORD PTR [rdx]
    14d7:	mov    r8,QWORD PTR [rdx+0x8]
    14db:	mov    rcx,QWORD PTR [rdx+0x10]
    14df:	mov    rdx,r8
    14e2:	call   14e7 <botlish_entry_9+0x17>
			14e3: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    14e7:	mov    rsp,rbp
    14ea:	pop    rbp
    14eb:	ret

00000000000014ec <botlish_fn_10: csv_parse<str>>:
    14ec:	push   rbp
    14ed:	mov    rbp,rsp
    14f0:	sub    rsp,0x20
    14f4:	mov    QWORD PTR [rsp],rbx
    14f8:	mov    QWORD PTR [rsp+0x8],r12
    14fd:	mov    QWORD PTR [rsp+0x10],r13
    1502:	mov    rbx,QWORD PTR [rdi]
    1505:	mov    rax,QWORD PTR [rdi+0x8]
    1509:	lea    rcx,[rbx+0x18]
    150d:	cmp    rcx,rax
    1510:	ja     15b5 <botlish_fn_10+0xc9>
    1516:	lea    rax,[rbx+0x18]
    151a:	mov    QWORD PTR [rdi],rax
    151d:	mov    r12,rdi
    1520:	mov    QWORD PTR [rbx+0x10],0x0
    1528:	mov    QWORD PTR [rbx],rsi
    152b:	mov    r13,rsi
    152e:	mov    QWORD PTR [rbx+0x8],0x1
    1536:	xor    rdx,rdx
    1539:	mov    rdi,r12
    153c:	mov    rsi,rdx
    153f:	call   1544 <botlish_fn_10+0x58>
			1540: R_X86_64_PLT32	rt_list_new-0x4
    1544:	test   rax,rax
    1547:	jne    1555 <botlish_fn_10+0x69>
    154d:	mov    rdi,r12
    1550:	jmp    1578 <botlish_fn_10+0x8c>
    1555:	mov    QWORD PTR [rbx+0x10],rax
    1559:	mov    rcx,rax
    155c:	mov    edx,0x1
    1561:	mov    rsi,r13
    1564:	mov    rdi,r12
    1567:	call   156c <botlish_fn_10+0x80>
			1568: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    156c:	test   rax,rax
    156f:	jne    1598 <botlish_fn_10+0xac>
    1575:	mov    rdi,r12
    1578:	mov    rdi,r12
    157b:	mov    QWORD PTR [rdi],rbx
    157e:	xor    rax,rax
    1581:	mov    rbx,QWORD PTR [rsp]
    1585:	mov    r12,QWORD PTR [rsp+0x8]
    158a:	mov    r13,QWORD PTR [rsp+0x10]
    158f:	add    rsp,0x20
    1593:	mov    rsp,rbp
    1596:	pop    rbp
    1597:	ret
    1598:	mov    rdi,r12
    159b:	mov    QWORD PTR [rdi],rbx
    159e:	mov    rbx,QWORD PTR [rsp]
    15a2:	mov    r12,QWORD PTR [rsp+0x8]
    15a7:	mov    r13,QWORD PTR [rsp+0x10]
    15ac:	add    rsp,0x20
    15b0:	mov    rsp,rbp
    15b3:	pop    rbp
    15b4:	ret
    15b5:	mov    r12,rdi
    15b8:	call   15bd <botlish_fn_10+0xd1>
			15b9: R_X86_64_PLT32	rt_stack_overflow-0x4
    15bd:	xor    rax,rax
    15c0:	mov    rbx,QWORD PTR [rsp]
    15c4:	mov    r12,QWORD PTR [rsp+0x8]
    15c9:	mov    r13,QWORD PTR [rsp+0x10]
    15ce:	add    rsp,0x20
    15d2:	mov    rsp,rbp
    15d5:	pop    rbp
    15d6:	ret

00000000000015d7 <botlish_entry_10: csv_parse<str>>:
    15d7:	push   rbp
    15d8:	mov    rbp,rsp
    15db:	mov    rsi,QWORD PTR [rdx]
    15de:	call   15e3 <botlish_entry_10+0xc>
			15df: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    15e3:	mov    rsp,rbp
    15e6:	pop    rbp
    15e7:	ret

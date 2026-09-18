; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 13435  (per function: 176 85 318 750 750 750 750 840 776 747 747 501 558 698 913 482 938 975 648 724 309)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunk_size<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_new<generic>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<list[list<never>, mutarray, int], str>
;   botlish_fn_4 / botlish_entry_4 -> chunked_append<list[list<mutarray>, mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> chunked_append<list[list<never>, mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> chunked_append<list[list<mutarray>, mutarray, int], list>
;   botlish_fn_7 / botlish_entry_7 -> chunked_copy_chunks<list<never>, int, mutarray, int>
;   botlish_fn_8 / botlish_entry_8 -> chunked_copy_chunks<list<mutarray>, int, mutarray, int>
;   botlish_fn_9 / botlish_entry_9 -> chunked_finish<list[list<never>, mutarray, int]>
;   botlish_fn_10 / botlish_entry_10 -> chunked_finish<list[list<mutarray>, mutarray, int]>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_unquoted<str, int, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_quoted<str, int, str>
;   botlish_fn_15 / botlish_entry_15 -> scan_field<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_record<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_17 / botlish_entry_17 -> scan_record<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_19 / botlish_entry_19 -> scan_records<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_20 / botlish_entry_20 -> csv_parse<str>


csv_chunked.asm.o:     file format elf64-x86-64


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
      1f:	ja     83 <botlish_fn_0+0x83>
      25:	lea    rax,[r13+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    QWORD PTR [r13+0x0],0x0
      34:	mov    rax,QWORD PTR [rdi+0x10]
      38:	mov    r14,rdi
      3b:	mov    rsi,QWORD PTR [rax]
      3e:	mov    QWORD PTR [r13+0x0],rsi
      42:	call   47 <botlish_fn_0+0x47>
			43: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
      47:	test   rax,rax
      4a:	jne    6b <botlish_fn_0+0x6b>
      50:	mov    rdi,r14
      53:	mov    QWORD PTR [rdi],r13
      56:	xor    rax,rax
      59:	mov    r13,QWORD PTR [rsp]
      5d:	mov    r14,QWORD PTR [rsp+0x8]
      62:	add    rsp,0x10
      66:	mov    rsp,rbp
      69:	pop    rbp
      6a:	ret
      6b:	mov    rdi,r14
      6e:	mov    QWORD PTR [rdi],r13
      71:	mov    r13,QWORD PTR [rsp]
      75:	mov    r14,QWORD PTR [rsp+0x8]
      7a:	add    rsp,0x10
      7e:	mov    rsp,rbp
      81:	pop    rbp
      82:	ret
      83:	call   88 <botlish_fn_0+0x88>
			84: R_X86_64_PLT32	rt_stack_overflow-0x4
      88:	xor    rax,rax
      8b:	mov    r13,QWORD PTR [rsp]
      8f:	mov    r14,QWORD PTR [rsp+0x8]
      94:	add    rsp,0x10
      98:	mov    rsp,rbp
      9b:	pop    rbp
      9c:	ret

000000000000009d <botlish_entry_0: <program entry>>:
      9d:	push   rbp
      9e:	mov    rbp,rsp
      a1:	call   a6 <botlish_entry_0+0x9>
			a2: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a6:	mov    rsp,rbp
      a9:	pop    rbp
      aa:	ret

00000000000000ab <botlish_fn_1: chunk_size<generic>>:
      ab:	push   rbp
      ac:	mov    rbp,rsp
      af:	mov    r9,QWORD PTR [rdi]
      b2:	mov    r10,QWORD PTR [rdi+0x8]
      b6:	lea    r11,[r9+0x8]
      ba:	cmp    r11,r10
      bd:	ja     de <botlish_fn_1+0x33>
      c3:	lea    r11,[r9+0x8]
      c7:	mov    QWORD PTR [rdi],r11
      ca:	mov    QWORD PTR [r9],0x0
      d1:	mov    QWORD PTR [rdi],r9
      d4:	mov    eax,0x81
      d9:	mov    rsp,rbp
      dc:	pop    rbp
      dd:	ret
      de:	call   e3 <botlish_fn_1+0x38>
			df: R_X86_64_PLT32	rt_stack_overflow-0x4
      e3:	xor    rax,rax
      e6:	mov    rsp,rbp
      e9:	pop    rbp
      ea:	ret

00000000000000eb <botlish_entry_1: chunk_size<generic>>:
      eb:	push   rbp
      ec:	mov    rbp,rsp
      ef:	call   f4 <botlish_entry_1+0x9>
			f0: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      f4:	mov    rsp,rbp
      f7:	pop    rbp
      f8:	ret

00000000000000f9 <botlish_fn_2: chunked_new<generic>>:
      f9:	push   rbp
      fa:	mov    rbp,rsp
      fd:	sub    rsp,0x20
     101:	mov    QWORD PTR [rsp],rbx
     105:	mov    QWORD PTR [rsp+0x8],r12
     10a:	mov    QWORD PTR [rsp+0x10],r13
     10f:	mov    QWORD PTR [rsp+0x18],r14
     114:	mov    r13,rsi
     117:	mov    rbx,QWORD PTR [rdi]
     11a:	mov    rax,QWORD PTR [rdi+0x8]
     11e:	lea    rcx,[rbx+0x10]
     122:	cmp    rcx,rax
     125:	ja     1f5 <botlish_fn_2+0xfc>
     12b:	lea    rax,[rbx+0x10]
     12f:	mov    QWORD PTR [rdi],rax
     132:	mov    r12,rdi
     135:	mov    QWORD PTR [rbx],0x0
     13c:	mov    QWORD PTR [rbx+0x8],0x0
     144:	xor    rdx,rdx
     147:	mov    rdi,r12
     14a:	mov    rsi,rdx
     14d:	call   152 <botlish_fn_2+0x59>
			14e: R_X86_64_PLT32	rt_list_new-0x4
     152:	test   rax,rax
     155:	jne    163 <botlish_fn_2+0x6a>
     15b:	mov    rdi,r12
     15e:	jmp    19d <botlish_fn_2+0xa4>
     163:	mov    QWORD PTR [rbx],rax
     166:	mov    r14,rax
     169:	mov    rdi,r12
     16c:	call   171 <botlish_fn_2+0x78>
			16d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     171:	test   rax,rax
     174:	jne    182 <botlish_fn_2+0x89>
     17a:	mov    rdi,r12
     17d:	jmp    19d <botlish_fn_2+0xa4>
     182:	mov    QWORD PTR [rbx+0x8],rax
     186:	mov    rsi,rax
     189:	mov    rdi,r12
     18c:	call   191 <botlish_fn_2+0x98>
			18d: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     191:	test   rax,rax
     194:	jne    1c2 <botlish_fn_2+0xc9>
     19a:	mov    rdi,r12
     19d:	mov    rdi,r12
     1a0:	mov    QWORD PTR [rdi],rbx
     1a3:	xor    rax,rax
     1a6:	mov    rbx,QWORD PTR [rsp]
     1aa:	mov    r12,QWORD PTR [rsp+0x8]
     1af:	mov    r13,QWORD PTR [rsp+0x10]
     1b4:	mov    r14,QWORD PTR [rsp+0x18]
     1b9:	add    rsp,0x20
     1bd:	mov    rsp,rbp
     1c0:	pop    rbp
     1c1:	ret
     1c2:	mov    rdi,r12
     1c5:	mov    QWORD PTR [rdi],rbx
     1c8:	mov    rsi,r13
     1cb:	mov    QWORD PTR [rsi],rax
     1ce:	mov    QWORD PTR [rsi+0x8],0x1
     1d6:	mov    rax,r14
     1d9:	mov    rbx,QWORD PTR [rsp]
     1dd:	mov    r12,QWORD PTR [rsp+0x8]
     1e2:	mov    r13,QWORD PTR [rsp+0x10]
     1e7:	mov    r14,QWORD PTR [rsp+0x18]
     1ec:	add    rsp,0x20
     1f0:	mov    rsp,rbp
     1f3:	pop    rbp
     1f4:	ret
     1f5:	mov    r12,rdi
     1f8:	call   1fd <botlish_fn_2+0x104>
			1f9: R_X86_64_PLT32	rt_stack_overflow-0x4
     1fd:	xor    rax,rax
     200:	mov    rbx,QWORD PTR [rsp]
     204:	mov    r12,QWORD PTR [rsp+0x8]
     209:	mov    r13,QWORD PTR [rsp+0x10]
     20e:	mov    r14,QWORD PTR [rsp+0x18]
     213:	add    rsp,0x20
     217:	mov    rsp,rbp
     21a:	pop    rbp
     21b:	ret

000000000000021c <botlish_entry_2: chunked_new<generic>>:
     21c:	push   rbp
     21d:	mov    rbp,rsp
     220:	ud2
     222:	add    BYTE PTR [rax],al
     224:	add    BYTE PTR [rax],al
	...

0000000000000228 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     228:	push   rbp
     229:	mov    rbp,rsp
     22c:	sub    rsp,0x40
     230:	mov    QWORD PTR [rsp+0x10],rbx
     235:	mov    QWORD PTR [rsp+0x18],r12
     23a:	mov    QWORD PTR [rsp+0x20],r13
     23f:	mov    QWORD PTR [rsp+0x28],r14
     244:	mov    QWORD PTR [rsp+0x30],r15
     249:	mov    rbx,r9
     24c:	mov    r13,QWORD PTR [rdi]
     24f:	mov    rax,QWORD PTR [rdi+0x8]
     253:	lea    r9,[r13+0x20]
     257:	cmp    r9,rax
     25a:	ja     499 <botlish_fn_3+0x271>
     260:	lea    rax,[r13+0x20]
     264:	mov    QWORD PTR [rdi],rax
     267:	mov    r14,rdi
     26a:	mov    QWORD PTR [r13+0x0],0x0
     272:	mov    QWORD PTR [r13+0x8],0x0
     27a:	mov    QWORD PTR [r13+0x10],0x0
     282:	mov    QWORD PTR [r13+0x18],0x0
     28a:	mov    QWORD PTR [r13+0x0],rsi
     28e:	mov    r15,rsi
     291:	mov    QWORD PTR [r13+0x8],rdx
     295:	mov    QWORD PTR [rsp],rdx
     299:	mov    QWORD PTR [r13+0x10],rcx
     29d:	mov    r12,rcx
     2a0:	mov    QWORD PTR [r13+0x18],r8
     2a4:	mov    QWORD PTR [rsp+0x8],r8
     2a9:	mov    rdi,r14
     2ac:	call   2b1 <botlish_fn_3+0x89>
			2ad: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     2b1:	test   rax,rax
     2b4:	jne    2c2 <botlish_fn_3+0x9a>
     2ba:	mov    rdi,r14
     2bd:	jmp    435 <botlish_fn_3+0x20d>
     2c2:	mov    rcx,r12
     2c5:	and    rcx,rax
     2c8:	mov    rdx,rax
     2cb:	test   rcx,0x1
     2d2:	jne    2f8 <botlish_fn_3+0xd0>
     2d8:	mov    rsi,r12
     2db:	mov    rdi,r14
     2de:	call   2e3 <botlish_fn_3+0xbb>
			2df: R_X86_64_PLT32	rt_int_cmp-0x4
     2e3:	mov    ecx,0x2
     2e8:	test   rax,rax
     2eb:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 4c8 <botlish_fn_3+0x2a0>
     2f3:	jmp    308 <botlish_fn_3+0xe0>
     2f8:	mov    ecx,0x2
     2fd:	cmp    r12,rdx
     300:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 4c8 <botlish_fn_3+0x2a0>
     308:	cmp    rcx,0x6
     30c:	je     3b1 <botlish_fn_3+0x189>
     312:	mov    rcx,QWORD PTR [rsp+0x8]
     317:	mov    rdx,r12
     31a:	mov    rsi,QWORD PTR [rsp]
     31e:	mov    rdi,r14
     321:	call   326 <botlish_fn_3+0xfe>
			322: R_X86_64_PLT32	rt_mutarray_set-0x4
     326:	test   rax,rax
     329:	jne    337 <botlish_fn_3+0x10f>
     32f:	mov    rdi,r14
     332:	jmp    435 <botlish_fn_3+0x20d>
     337:	mov    QWORD PTR [r13+0x18],0x3
     33f:	test   r12,0x1
     346:	je     368 <botlish_fn_3+0x140>
     34c:	mov    rax,r12
     34f:	add    rax,0x2
     353:	seto   sil
     357:	test   sil,sil
     35a:	jne    368 <botlish_fn_3+0x140>
     360:	mov    rdi,r14
     363:	jmp    37b <botlish_fn_3+0x153>
     368:	mov    edx,0x3
     36d:	mov    rsi,r12
     370:	mov    rdi,r14
     373:	call   378 <botlish_fn_3+0x150>
			374: R_X86_64_PLT32	rt_int_add-0x4
     378:	mov    rdi,r14
     37b:	mov    rdi,r14
     37e:	mov    QWORD PTR [rdi],r13
     381:	mov    rdx,QWORD PTR [rsp]
     385:	mov    QWORD PTR [rbx],rdx
     388:	mov    QWORD PTR [rbx+0x8],rax
     38c:	mov    rax,r15
     38f:	mov    rbx,QWORD PTR [rsp+0x10]
     394:	mov    r12,QWORD PTR [rsp+0x18]
     399:	mov    r13,QWORD PTR [rsp+0x20]
     39e:	mov    r14,QWORD PTR [rsp+0x28]
     3a3:	mov    r15,QWORD PTR [rsp+0x30]
     3a8:	add    rsp,0x40
     3ac:	mov    rsp,rbp
     3af:	pop    rbp
     3b0:	ret
     3b1:	mov    rdx,QWORD PTR [rsp]
     3b5:	mov    rsi,r15
     3b8:	mov    rdi,r14
     3bb:	call   3c0 <botlish_fn_3+0x198>
			3bc: R_X86_64_PLT32	rt_list_append-0x4
     3c0:	test   rax,rax
     3c3:	jne    3d1 <botlish_fn_3+0x1a9>
     3c9:	mov    rdi,r14
     3cc:	jmp    435 <botlish_fn_3+0x20d>
     3d1:	mov    QWORD PTR [r13+0x0],rax
     3d5:	mov    r12,rax
     3d8:	mov    rdi,r14
     3db:	call   3e0 <botlish_fn_3+0x1b8>
			3dc: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     3e0:	test   rax,rax
     3e3:	jne    3f1 <botlish_fn_3+0x1c9>
     3e9:	mov    rdi,r14
     3ec:	jmp    435 <botlish_fn_3+0x20d>
     3f1:	mov    QWORD PTR [r13+0x8],rax
     3f5:	mov    rsi,rax
     3f8:	mov    rdi,r14
     3fb:	call   400 <botlish_fn_3+0x1d8>
			3fc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     400:	test   rax,rax
     403:	mov    r15,rax
     406:	jne    414 <botlish_fn_3+0x1ec>
     40c:	mov    rdi,r14
     40f:	jmp    435 <botlish_fn_3+0x20d>
     414:	mov    edx,0x1
     419:	mov    rcx,QWORD PTR [rsp+0x8]
     41e:	mov    rsi,r15
     421:	mov    rdi,r14
     424:	call   429 <botlish_fn_3+0x201>
			425: R_X86_64_PLT32	rt_mutarray_set-0x4
     429:	test   rax,rax
     42c:	jne    460 <botlish_fn_3+0x238>
     432:	mov    rdi,r14
     435:	mov    rdi,r14
     438:	mov    QWORD PTR [rdi],r13
     43b:	xor    rax,rax
     43e:	mov    rbx,QWORD PTR [rsp+0x10]
     443:	mov    r12,QWORD PTR [rsp+0x18]
     448:	mov    r13,QWORD PTR [rsp+0x20]
     44d:	mov    r14,QWORD PTR [rsp+0x28]
     452:	mov    r15,QWORD PTR [rsp+0x30]
     457:	add    rsp,0x40
     45b:	mov    rsp,rbp
     45e:	pop    rbp
     45f:	ret
     460:	mov    rdi,r14
     463:	mov    QWORD PTR [rdi],r13
     466:	mov    rax,r15
     469:	mov    QWORD PTR [rbx],rax
     46c:	mov    QWORD PTR [rbx+0x8],0x3
     474:	mov    rax,r12
     477:	mov    rbx,QWORD PTR [rsp+0x10]
     47c:	mov    r12,QWORD PTR [rsp+0x18]
     481:	mov    r13,QWORD PTR [rsp+0x20]
     486:	mov    r14,QWORD PTR [rsp+0x28]
     48b:	mov    r15,QWORD PTR [rsp+0x30]
     490:	add    rsp,0x40
     494:	mov    rsp,rbp
     497:	pop    rbp
     498:	ret
     499:	mov    r14,rdi
     49c:	call   4a1 <botlish_fn_3+0x279>
			49d: R_X86_64_PLT32	rt_stack_overflow-0x4
     4a1:	xor    rax,rax
     4a4:	mov    rbx,QWORD PTR [rsp+0x10]
     4a9:	mov    r12,QWORD PTR [rsp+0x18]
     4ae:	mov    r13,QWORD PTR [rsp+0x20]
     4b3:	mov    r14,QWORD PTR [rsp+0x28]
     4b8:	mov    r15,QWORD PTR [rsp+0x30]
     4bd:	add    rsp,0x40
     4c1:	mov    rsp,rbp
     4c4:	pop    rbp
     4c5:	ret
     4c6:	add    BYTE PTR [rax],al
     4c8:	(bad)
     4c9:	add    BYTE PTR [rax],al
     4cb:	add    BYTE PTR [rax],al
     4cd:	add    BYTE PTR [rax],al
	...

00000000000004d0 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     4d0:	push   rbp
     4d1:	mov    rbp,rsp
     4d4:	ud2
	...

00000000000004d8 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     4d8:	push   rbp
     4d9:	mov    rbp,rsp
     4dc:	sub    rsp,0x40
     4e0:	mov    QWORD PTR [rsp+0x10],rbx
     4e5:	mov    QWORD PTR [rsp+0x18],r12
     4ea:	mov    QWORD PTR [rsp+0x20],r13
     4ef:	mov    QWORD PTR [rsp+0x28],r14
     4f4:	mov    QWORD PTR [rsp+0x30],r15
     4f9:	mov    rbx,r9
     4fc:	mov    r13,QWORD PTR [rdi]
     4ff:	mov    rax,QWORD PTR [rdi+0x8]
     503:	lea    r9,[r13+0x20]
     507:	cmp    r9,rax
     50a:	ja     749 <botlish_fn_4+0x271>
     510:	lea    rax,[r13+0x20]
     514:	mov    QWORD PTR [rdi],rax
     517:	mov    r14,rdi
     51a:	mov    QWORD PTR [r13+0x0],0x0
     522:	mov    QWORD PTR [r13+0x8],0x0
     52a:	mov    QWORD PTR [r13+0x10],0x0
     532:	mov    QWORD PTR [r13+0x18],0x0
     53a:	mov    QWORD PTR [r13+0x0],rsi
     53e:	mov    r15,rsi
     541:	mov    QWORD PTR [r13+0x8],rdx
     545:	mov    QWORD PTR [rsp],rdx
     549:	mov    QWORD PTR [r13+0x10],rcx
     54d:	mov    r12,rcx
     550:	mov    QWORD PTR [r13+0x18],r8
     554:	mov    QWORD PTR [rsp+0x8],r8
     559:	mov    rdi,r14
     55c:	call   561 <botlish_fn_4+0x89>
			55d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     561:	test   rax,rax
     564:	jne    572 <botlish_fn_4+0x9a>
     56a:	mov    rdi,r14
     56d:	jmp    6e5 <botlish_fn_4+0x20d>
     572:	mov    rcx,r12
     575:	and    rcx,rax
     578:	mov    rdx,rax
     57b:	test   rcx,0x1
     582:	jne    5a8 <botlish_fn_4+0xd0>
     588:	mov    rsi,r12
     58b:	mov    rdi,r14
     58e:	call   593 <botlish_fn_4+0xbb>
			58f: R_X86_64_PLT32	rt_int_cmp-0x4
     593:	mov    ecx,0x2
     598:	test   rax,rax
     59b:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 778 <botlish_fn_4+0x2a0>
     5a3:	jmp    5b8 <botlish_fn_4+0xe0>
     5a8:	mov    ecx,0x2
     5ad:	cmp    r12,rdx
     5b0:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 778 <botlish_fn_4+0x2a0>
     5b8:	cmp    rcx,0x6
     5bc:	je     661 <botlish_fn_4+0x189>
     5c2:	mov    rcx,QWORD PTR [rsp+0x8]
     5c7:	mov    rdx,r12
     5ca:	mov    rsi,QWORD PTR [rsp]
     5ce:	mov    rdi,r14
     5d1:	call   5d6 <botlish_fn_4+0xfe>
			5d2: R_X86_64_PLT32	rt_mutarray_set-0x4
     5d6:	test   rax,rax
     5d9:	jne    5e7 <botlish_fn_4+0x10f>
     5df:	mov    rdi,r14
     5e2:	jmp    6e5 <botlish_fn_4+0x20d>
     5e7:	mov    QWORD PTR [r13+0x18],0x3
     5ef:	test   r12,0x1
     5f6:	je     618 <botlish_fn_4+0x140>
     5fc:	mov    rax,r12
     5ff:	add    rax,0x2
     603:	seto   sil
     607:	test   sil,sil
     60a:	jne    618 <botlish_fn_4+0x140>
     610:	mov    rdi,r14
     613:	jmp    62b <botlish_fn_4+0x153>
     618:	mov    edx,0x3
     61d:	mov    rsi,r12
     620:	mov    rdi,r14
     623:	call   628 <botlish_fn_4+0x150>
			624: R_X86_64_PLT32	rt_int_add-0x4
     628:	mov    rdi,r14
     62b:	mov    rdi,r14
     62e:	mov    QWORD PTR [rdi],r13
     631:	mov    rdx,QWORD PTR [rsp]
     635:	mov    QWORD PTR [rbx],rdx
     638:	mov    QWORD PTR [rbx+0x8],rax
     63c:	mov    rax,r15
     63f:	mov    rbx,QWORD PTR [rsp+0x10]
     644:	mov    r12,QWORD PTR [rsp+0x18]
     649:	mov    r13,QWORD PTR [rsp+0x20]
     64e:	mov    r14,QWORD PTR [rsp+0x28]
     653:	mov    r15,QWORD PTR [rsp+0x30]
     658:	add    rsp,0x40
     65c:	mov    rsp,rbp
     65f:	pop    rbp
     660:	ret
     661:	mov    rdx,QWORD PTR [rsp]
     665:	mov    rsi,r15
     668:	mov    rdi,r14
     66b:	call   670 <botlish_fn_4+0x198>
			66c: R_X86_64_PLT32	rt_list_append-0x4
     670:	test   rax,rax
     673:	jne    681 <botlish_fn_4+0x1a9>
     679:	mov    rdi,r14
     67c:	jmp    6e5 <botlish_fn_4+0x20d>
     681:	mov    QWORD PTR [r13+0x0],rax
     685:	mov    r12,rax
     688:	mov    rdi,r14
     68b:	call   690 <botlish_fn_4+0x1b8>
			68c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     690:	test   rax,rax
     693:	jne    6a1 <botlish_fn_4+0x1c9>
     699:	mov    rdi,r14
     69c:	jmp    6e5 <botlish_fn_4+0x20d>
     6a1:	mov    QWORD PTR [r13+0x8],rax
     6a5:	mov    rsi,rax
     6a8:	mov    rdi,r14
     6ab:	call   6b0 <botlish_fn_4+0x1d8>
			6ac: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     6b0:	test   rax,rax
     6b3:	mov    r15,rax
     6b6:	jne    6c4 <botlish_fn_4+0x1ec>
     6bc:	mov    rdi,r14
     6bf:	jmp    6e5 <botlish_fn_4+0x20d>
     6c4:	mov    edx,0x1
     6c9:	mov    rcx,QWORD PTR [rsp+0x8]
     6ce:	mov    rsi,r15
     6d1:	mov    rdi,r14
     6d4:	call   6d9 <botlish_fn_4+0x201>
			6d5: R_X86_64_PLT32	rt_mutarray_set-0x4
     6d9:	test   rax,rax
     6dc:	jne    710 <botlish_fn_4+0x238>
     6e2:	mov    rdi,r14
     6e5:	mov    rdi,r14
     6e8:	mov    QWORD PTR [rdi],r13
     6eb:	xor    rax,rax
     6ee:	mov    rbx,QWORD PTR [rsp+0x10]
     6f3:	mov    r12,QWORD PTR [rsp+0x18]
     6f8:	mov    r13,QWORD PTR [rsp+0x20]
     6fd:	mov    r14,QWORD PTR [rsp+0x28]
     702:	mov    r15,QWORD PTR [rsp+0x30]
     707:	add    rsp,0x40
     70b:	mov    rsp,rbp
     70e:	pop    rbp
     70f:	ret
     710:	mov    rdi,r14
     713:	mov    QWORD PTR [rdi],r13
     716:	mov    rax,r15
     719:	mov    QWORD PTR [rbx],rax
     71c:	mov    QWORD PTR [rbx+0x8],0x3
     724:	mov    rax,r12
     727:	mov    rbx,QWORD PTR [rsp+0x10]
     72c:	mov    r12,QWORD PTR [rsp+0x18]
     731:	mov    r13,QWORD PTR [rsp+0x20]
     736:	mov    r14,QWORD PTR [rsp+0x28]
     73b:	mov    r15,QWORD PTR [rsp+0x30]
     740:	add    rsp,0x40
     744:	mov    rsp,rbp
     747:	pop    rbp
     748:	ret
     749:	mov    r14,rdi
     74c:	call   751 <botlish_fn_4+0x279>
			74d: R_X86_64_PLT32	rt_stack_overflow-0x4
     751:	xor    rax,rax
     754:	mov    rbx,QWORD PTR [rsp+0x10]
     759:	mov    r12,QWORD PTR [rsp+0x18]
     75e:	mov    r13,QWORD PTR [rsp+0x20]
     763:	mov    r14,QWORD PTR [rsp+0x28]
     768:	mov    r15,QWORD PTR [rsp+0x30]
     76d:	add    rsp,0x40
     771:	mov    rsp,rbp
     774:	pop    rbp
     775:	ret
     776:	add    BYTE PTR [rax],al
     778:	(bad)
     779:	add    BYTE PTR [rax],al
     77b:	add    BYTE PTR [rax],al
     77d:	add    BYTE PTR [rax],al
	...

0000000000000780 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     780:	push   rbp
     781:	mov    rbp,rsp
     784:	ud2
	...

0000000000000788 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     788:	push   rbp
     789:	mov    rbp,rsp
     78c:	sub    rsp,0x40
     790:	mov    QWORD PTR [rsp+0x10],rbx
     795:	mov    QWORD PTR [rsp+0x18],r12
     79a:	mov    QWORD PTR [rsp+0x20],r13
     79f:	mov    QWORD PTR [rsp+0x28],r14
     7a4:	mov    QWORD PTR [rsp+0x30],r15
     7a9:	mov    rbx,r9
     7ac:	mov    r13,QWORD PTR [rdi]
     7af:	mov    rax,QWORD PTR [rdi+0x8]
     7b3:	lea    r9,[r13+0x20]
     7b7:	cmp    r9,rax
     7ba:	ja     9f9 <botlish_fn_5+0x271>
     7c0:	lea    rax,[r13+0x20]
     7c4:	mov    QWORD PTR [rdi],rax
     7c7:	mov    r14,rdi
     7ca:	mov    QWORD PTR [r13+0x0],0x0
     7d2:	mov    QWORD PTR [r13+0x8],0x0
     7da:	mov    QWORD PTR [r13+0x10],0x0
     7e2:	mov    QWORD PTR [r13+0x18],0x0
     7ea:	mov    QWORD PTR [r13+0x0],rsi
     7ee:	mov    r15,rsi
     7f1:	mov    QWORD PTR [r13+0x8],rdx
     7f5:	mov    QWORD PTR [rsp],rdx
     7f9:	mov    QWORD PTR [r13+0x10],rcx
     7fd:	mov    r12,rcx
     800:	mov    QWORD PTR [r13+0x18],r8
     804:	mov    QWORD PTR [rsp+0x8],r8
     809:	mov    rdi,r14
     80c:	call   811 <botlish_fn_5+0x89>
			80d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     811:	test   rax,rax
     814:	jne    822 <botlish_fn_5+0x9a>
     81a:	mov    rdi,r14
     81d:	jmp    995 <botlish_fn_5+0x20d>
     822:	mov    rcx,r12
     825:	and    rcx,rax
     828:	mov    rdx,rax
     82b:	test   rcx,0x1
     832:	jne    858 <botlish_fn_5+0xd0>
     838:	mov    rsi,r12
     83b:	mov    rdi,r14
     83e:	call   843 <botlish_fn_5+0xbb>
			83f: R_X86_64_PLT32	rt_int_cmp-0x4
     843:	mov    ecx,0x2
     848:	test   rax,rax
     84b:	cmove  rcx,QWORD PTR [rip+0x1d5]        # a28 <botlish_fn_5+0x2a0>
     853:	jmp    868 <botlish_fn_5+0xe0>
     858:	mov    ecx,0x2
     85d:	cmp    r12,rdx
     860:	cmove  rcx,QWORD PTR [rip+0x1c0]        # a28 <botlish_fn_5+0x2a0>
     868:	cmp    rcx,0x6
     86c:	je     911 <botlish_fn_5+0x189>
     872:	mov    rcx,QWORD PTR [rsp+0x8]
     877:	mov    rdx,r12
     87a:	mov    rsi,QWORD PTR [rsp]
     87e:	mov    rdi,r14
     881:	call   886 <botlish_fn_5+0xfe>
			882: R_X86_64_PLT32	rt_mutarray_set-0x4
     886:	test   rax,rax
     889:	jne    897 <botlish_fn_5+0x10f>
     88f:	mov    rdi,r14
     892:	jmp    995 <botlish_fn_5+0x20d>
     897:	mov    QWORD PTR [r13+0x18],0x3
     89f:	test   r12,0x1
     8a6:	je     8c8 <botlish_fn_5+0x140>
     8ac:	mov    rax,r12
     8af:	add    rax,0x2
     8b3:	seto   sil
     8b7:	test   sil,sil
     8ba:	jne    8c8 <botlish_fn_5+0x140>
     8c0:	mov    rdi,r14
     8c3:	jmp    8db <botlish_fn_5+0x153>
     8c8:	mov    edx,0x3
     8cd:	mov    rsi,r12
     8d0:	mov    rdi,r14
     8d3:	call   8d8 <botlish_fn_5+0x150>
			8d4: R_X86_64_PLT32	rt_int_add-0x4
     8d8:	mov    rdi,r14
     8db:	mov    rdi,r14
     8de:	mov    QWORD PTR [rdi],r13
     8e1:	mov    rdx,QWORD PTR [rsp]
     8e5:	mov    QWORD PTR [rbx],rdx
     8e8:	mov    QWORD PTR [rbx+0x8],rax
     8ec:	mov    rax,r15
     8ef:	mov    rbx,QWORD PTR [rsp+0x10]
     8f4:	mov    r12,QWORD PTR [rsp+0x18]
     8f9:	mov    r13,QWORD PTR [rsp+0x20]
     8fe:	mov    r14,QWORD PTR [rsp+0x28]
     903:	mov    r15,QWORD PTR [rsp+0x30]
     908:	add    rsp,0x40
     90c:	mov    rsp,rbp
     90f:	pop    rbp
     910:	ret
     911:	mov    rdx,QWORD PTR [rsp]
     915:	mov    rsi,r15
     918:	mov    rdi,r14
     91b:	call   920 <botlish_fn_5+0x198>
			91c: R_X86_64_PLT32	rt_list_append-0x4
     920:	test   rax,rax
     923:	jne    931 <botlish_fn_5+0x1a9>
     929:	mov    rdi,r14
     92c:	jmp    995 <botlish_fn_5+0x20d>
     931:	mov    QWORD PTR [r13+0x0],rax
     935:	mov    r12,rax
     938:	mov    rdi,r14
     93b:	call   940 <botlish_fn_5+0x1b8>
			93c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     940:	test   rax,rax
     943:	jne    951 <botlish_fn_5+0x1c9>
     949:	mov    rdi,r14
     94c:	jmp    995 <botlish_fn_5+0x20d>
     951:	mov    QWORD PTR [r13+0x8],rax
     955:	mov    rsi,rax
     958:	mov    rdi,r14
     95b:	call   960 <botlish_fn_5+0x1d8>
			95c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     960:	test   rax,rax
     963:	mov    r15,rax
     966:	jne    974 <botlish_fn_5+0x1ec>
     96c:	mov    rdi,r14
     96f:	jmp    995 <botlish_fn_5+0x20d>
     974:	mov    edx,0x1
     979:	mov    rcx,QWORD PTR [rsp+0x8]
     97e:	mov    rsi,r15
     981:	mov    rdi,r14
     984:	call   989 <botlish_fn_5+0x201>
			985: R_X86_64_PLT32	rt_mutarray_set-0x4
     989:	test   rax,rax
     98c:	jne    9c0 <botlish_fn_5+0x238>
     992:	mov    rdi,r14
     995:	mov    rdi,r14
     998:	mov    QWORD PTR [rdi],r13
     99b:	xor    rax,rax
     99e:	mov    rbx,QWORD PTR [rsp+0x10]
     9a3:	mov    r12,QWORD PTR [rsp+0x18]
     9a8:	mov    r13,QWORD PTR [rsp+0x20]
     9ad:	mov    r14,QWORD PTR [rsp+0x28]
     9b2:	mov    r15,QWORD PTR [rsp+0x30]
     9b7:	add    rsp,0x40
     9bb:	mov    rsp,rbp
     9be:	pop    rbp
     9bf:	ret
     9c0:	mov    rdi,r14
     9c3:	mov    QWORD PTR [rdi],r13
     9c6:	mov    rax,r15
     9c9:	mov    QWORD PTR [rbx],rax
     9cc:	mov    QWORD PTR [rbx+0x8],0x3
     9d4:	mov    rax,r12
     9d7:	mov    rbx,QWORD PTR [rsp+0x10]
     9dc:	mov    r12,QWORD PTR [rsp+0x18]
     9e1:	mov    r13,QWORD PTR [rsp+0x20]
     9e6:	mov    r14,QWORD PTR [rsp+0x28]
     9eb:	mov    r15,QWORD PTR [rsp+0x30]
     9f0:	add    rsp,0x40
     9f4:	mov    rsp,rbp
     9f7:	pop    rbp
     9f8:	ret
     9f9:	mov    r14,rdi
     9fc:	call   a01 <botlish_fn_5+0x279>
			9fd: R_X86_64_PLT32	rt_stack_overflow-0x4
     a01:	xor    rax,rax
     a04:	mov    rbx,QWORD PTR [rsp+0x10]
     a09:	mov    r12,QWORD PTR [rsp+0x18]
     a0e:	mov    r13,QWORD PTR [rsp+0x20]
     a13:	mov    r14,QWORD PTR [rsp+0x28]
     a18:	mov    r15,QWORD PTR [rsp+0x30]
     a1d:	add    rsp,0x40
     a21:	mov    rsp,rbp
     a24:	pop    rbp
     a25:	ret
     a26:	add    BYTE PTR [rax],al
     a28:	(bad)
     a29:	add    BYTE PTR [rax],al
     a2b:	add    BYTE PTR [rax],al
     a2d:	add    BYTE PTR [rax],al
	...

0000000000000a30 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     a30:	push   rbp
     a31:	mov    rbp,rsp
     a34:	ud2
	...

0000000000000a38 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     a38:	push   rbp
     a39:	mov    rbp,rsp
     a3c:	sub    rsp,0x40
     a40:	mov    QWORD PTR [rsp+0x10],rbx
     a45:	mov    QWORD PTR [rsp+0x18],r12
     a4a:	mov    QWORD PTR [rsp+0x20],r13
     a4f:	mov    QWORD PTR [rsp+0x28],r14
     a54:	mov    QWORD PTR [rsp+0x30],r15
     a59:	mov    rbx,r9
     a5c:	mov    r13,QWORD PTR [rdi]
     a5f:	mov    rax,QWORD PTR [rdi+0x8]
     a63:	lea    r9,[r13+0x20]
     a67:	cmp    r9,rax
     a6a:	ja     ca9 <botlish_fn_6+0x271>
     a70:	lea    rax,[r13+0x20]
     a74:	mov    QWORD PTR [rdi],rax
     a77:	mov    r14,rdi
     a7a:	mov    QWORD PTR [r13+0x0],0x0
     a82:	mov    QWORD PTR [r13+0x8],0x0
     a8a:	mov    QWORD PTR [r13+0x10],0x0
     a92:	mov    QWORD PTR [r13+0x18],0x0
     a9a:	mov    QWORD PTR [r13+0x0],rsi
     a9e:	mov    r15,rsi
     aa1:	mov    QWORD PTR [r13+0x8],rdx
     aa5:	mov    QWORD PTR [rsp],rdx
     aa9:	mov    QWORD PTR [r13+0x10],rcx
     aad:	mov    r12,rcx
     ab0:	mov    QWORD PTR [r13+0x18],r8
     ab4:	mov    QWORD PTR [rsp+0x8],r8
     ab9:	mov    rdi,r14
     abc:	call   ac1 <botlish_fn_6+0x89>
			abd: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     ac1:	test   rax,rax
     ac4:	jne    ad2 <botlish_fn_6+0x9a>
     aca:	mov    rdi,r14
     acd:	jmp    c45 <botlish_fn_6+0x20d>
     ad2:	mov    rcx,r12
     ad5:	and    rcx,rax
     ad8:	mov    rdx,rax
     adb:	test   rcx,0x1
     ae2:	jne    b08 <botlish_fn_6+0xd0>
     ae8:	mov    rsi,r12
     aeb:	mov    rdi,r14
     aee:	call   af3 <botlish_fn_6+0xbb>
			aef: R_X86_64_PLT32	rt_int_cmp-0x4
     af3:	mov    ecx,0x2
     af8:	test   rax,rax
     afb:	cmove  rcx,QWORD PTR [rip+0x1d5]        # cd8 <botlish_fn_6+0x2a0>
     b03:	jmp    b18 <botlish_fn_6+0xe0>
     b08:	mov    ecx,0x2
     b0d:	cmp    r12,rdx
     b10:	cmove  rcx,QWORD PTR [rip+0x1c0]        # cd8 <botlish_fn_6+0x2a0>
     b18:	cmp    rcx,0x6
     b1c:	je     bc1 <botlish_fn_6+0x189>
     b22:	mov    rcx,QWORD PTR [rsp+0x8]
     b27:	mov    rdx,r12
     b2a:	mov    rsi,QWORD PTR [rsp]
     b2e:	mov    rdi,r14
     b31:	call   b36 <botlish_fn_6+0xfe>
			b32: R_X86_64_PLT32	rt_mutarray_set-0x4
     b36:	test   rax,rax
     b39:	jne    b47 <botlish_fn_6+0x10f>
     b3f:	mov    rdi,r14
     b42:	jmp    c45 <botlish_fn_6+0x20d>
     b47:	mov    QWORD PTR [r13+0x18],0x3
     b4f:	test   r12,0x1
     b56:	je     b78 <botlish_fn_6+0x140>
     b5c:	mov    rax,r12
     b5f:	add    rax,0x2
     b63:	seto   sil
     b67:	test   sil,sil
     b6a:	jne    b78 <botlish_fn_6+0x140>
     b70:	mov    rdi,r14
     b73:	jmp    b8b <botlish_fn_6+0x153>
     b78:	mov    edx,0x3
     b7d:	mov    rsi,r12
     b80:	mov    rdi,r14
     b83:	call   b88 <botlish_fn_6+0x150>
			b84: R_X86_64_PLT32	rt_int_add-0x4
     b88:	mov    rdi,r14
     b8b:	mov    rdi,r14
     b8e:	mov    QWORD PTR [rdi],r13
     b91:	mov    rdx,QWORD PTR [rsp]
     b95:	mov    QWORD PTR [rbx],rdx
     b98:	mov    QWORD PTR [rbx+0x8],rax
     b9c:	mov    rax,r15
     b9f:	mov    rbx,QWORD PTR [rsp+0x10]
     ba4:	mov    r12,QWORD PTR [rsp+0x18]
     ba9:	mov    r13,QWORD PTR [rsp+0x20]
     bae:	mov    r14,QWORD PTR [rsp+0x28]
     bb3:	mov    r15,QWORD PTR [rsp+0x30]
     bb8:	add    rsp,0x40
     bbc:	mov    rsp,rbp
     bbf:	pop    rbp
     bc0:	ret
     bc1:	mov    rdx,QWORD PTR [rsp]
     bc5:	mov    rsi,r15
     bc8:	mov    rdi,r14
     bcb:	call   bd0 <botlish_fn_6+0x198>
			bcc: R_X86_64_PLT32	rt_list_append-0x4
     bd0:	test   rax,rax
     bd3:	jne    be1 <botlish_fn_6+0x1a9>
     bd9:	mov    rdi,r14
     bdc:	jmp    c45 <botlish_fn_6+0x20d>
     be1:	mov    QWORD PTR [r13+0x0],rax
     be5:	mov    r12,rax
     be8:	mov    rdi,r14
     beb:	call   bf0 <botlish_fn_6+0x1b8>
			bec: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     bf0:	test   rax,rax
     bf3:	jne    c01 <botlish_fn_6+0x1c9>
     bf9:	mov    rdi,r14
     bfc:	jmp    c45 <botlish_fn_6+0x20d>
     c01:	mov    QWORD PTR [r13+0x8],rax
     c05:	mov    rsi,rax
     c08:	mov    rdi,r14
     c0b:	call   c10 <botlish_fn_6+0x1d8>
			c0c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     c10:	test   rax,rax
     c13:	mov    r15,rax
     c16:	jne    c24 <botlish_fn_6+0x1ec>
     c1c:	mov    rdi,r14
     c1f:	jmp    c45 <botlish_fn_6+0x20d>
     c24:	mov    edx,0x1
     c29:	mov    rcx,QWORD PTR [rsp+0x8]
     c2e:	mov    rsi,r15
     c31:	mov    rdi,r14
     c34:	call   c39 <botlish_fn_6+0x201>
			c35: R_X86_64_PLT32	rt_mutarray_set-0x4
     c39:	test   rax,rax
     c3c:	jne    c70 <botlish_fn_6+0x238>
     c42:	mov    rdi,r14
     c45:	mov    rdi,r14
     c48:	mov    QWORD PTR [rdi],r13
     c4b:	xor    rax,rax
     c4e:	mov    rbx,QWORD PTR [rsp+0x10]
     c53:	mov    r12,QWORD PTR [rsp+0x18]
     c58:	mov    r13,QWORD PTR [rsp+0x20]
     c5d:	mov    r14,QWORD PTR [rsp+0x28]
     c62:	mov    r15,QWORD PTR [rsp+0x30]
     c67:	add    rsp,0x40
     c6b:	mov    rsp,rbp
     c6e:	pop    rbp
     c6f:	ret
     c70:	mov    rdi,r14
     c73:	mov    QWORD PTR [rdi],r13
     c76:	mov    rax,r15
     c79:	mov    QWORD PTR [rbx],rax
     c7c:	mov    QWORD PTR [rbx+0x8],0x3
     c84:	mov    rax,r12
     c87:	mov    rbx,QWORD PTR [rsp+0x10]
     c8c:	mov    r12,QWORD PTR [rsp+0x18]
     c91:	mov    r13,QWORD PTR [rsp+0x20]
     c96:	mov    r14,QWORD PTR [rsp+0x28]
     c9b:	mov    r15,QWORD PTR [rsp+0x30]
     ca0:	add    rsp,0x40
     ca4:	mov    rsp,rbp
     ca7:	pop    rbp
     ca8:	ret
     ca9:	mov    r14,rdi
     cac:	call   cb1 <botlish_fn_6+0x279>
			cad: R_X86_64_PLT32	rt_stack_overflow-0x4
     cb1:	xor    rax,rax
     cb4:	mov    rbx,QWORD PTR [rsp+0x10]
     cb9:	mov    r12,QWORD PTR [rsp+0x18]
     cbe:	mov    r13,QWORD PTR [rsp+0x20]
     cc3:	mov    r14,QWORD PTR [rsp+0x28]
     cc8:	mov    r15,QWORD PTR [rsp+0x30]
     ccd:	add    rsp,0x40
     cd1:	mov    rsp,rbp
     cd4:	pop    rbp
     cd5:	ret
     cd6:	add    BYTE PTR [rax],al
     cd8:	(bad)
     cd9:	add    BYTE PTR [rax],al
     cdb:	add    BYTE PTR [rax],al
     cdd:	add    BYTE PTR [rax],al
	...

0000000000000ce0 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     ce0:	push   rbp
     ce1:	mov    rbp,rsp
     ce4:	ud2
	...

0000000000000ce8 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     ce8:	push   rbp
     ce9:	mov    rbp,rsp
     cec:	sub    rsp,0x40
     cf0:	mov    QWORD PTR [rsp+0x10],rbx
     cf5:	mov    QWORD PTR [rsp+0x18],r12
     cfa:	mov    QWORD PTR [rsp+0x20],r13
     cff:	mov    QWORD PTR [rsp+0x28],r14
     d04:	mov    QWORD PTR [rsp+0x30],r15
     d09:	mov    rbx,QWORD PTR [rdi]
     d0c:	mov    rax,QWORD PTR [rdi+0x8]
     d10:	lea    r9,[rbx+0x30]
     d14:	cmp    r9,rax
     d17:	ja     fa7 <botlish_fn_7+0x2bf>
     d1d:	lea    rax,[rbx+0x30]
     d21:	mov    QWORD PTR [rdi],rax
     d24:	mov    r14,rdi
     d27:	mov    QWORD PTR [rbx],0x0
     d2e:	mov    QWORD PTR [rbx+0x8],0x0
     d36:	mov    QWORD PTR [rbx+0x10],0x0
     d3e:	mov    QWORD PTR [rbx+0x18],0x0
     d46:	mov    QWORD PTR [rbx+0x20],0x0
     d4e:	mov    QWORD PTR [rbx+0x28],0x0
     d56:	mov    QWORD PTR [rbx],rsi
     d59:	mov    QWORD PTR [rbx+0x8],rdx
     d5d:	mov    r12,rdx
     d60:	mov    QWORD PTR [rbx+0x10],rcx
     d64:	mov    r13,rcx
     d67:	mov    QWORD PTR [rbx+0x18],r8
     d6b:	mov    r15,rsi
     d6e:	mov    QWORD PTR [rsp],r8
     d72:	mov    rsi,r15
     d75:	mov    rdi,r14
     d78:	call   d7d <botlish_fn_7+0x95>
			d79: R_X86_64_PLT32	rt_list_len-0x4
     d7d:	mov    rsi,r12
     d80:	and    rsi,rax
     d83:	mov    rdx,rax
     d86:	test   rsi,0x1
     d8d:	jne    db3 <botlish_fn_7+0xcb>
     d93:	mov    rsi,r12
     d96:	mov    rdi,r14
     d99:	call   d9e <botlish_fn_7+0xb6>
			d9a: R_X86_64_PLT32	rt_int_cmp-0x4
     d9e:	mov    ecx,0x2
     da3:	test   rax,rax
     da6:	cmovge rcx,QWORD PTR [rip+0x22a]        # fd8 <botlish_fn_7+0x2f0>
     dae:	jmp    dc3 <botlish_fn_7+0xdb>
     db3:	mov    ecx,0x2
     db8:	cmp    r12,rdx
     dbb:	cmovge rcx,QWORD PTR [rip+0x215]        # fd8 <botlish_fn_7+0x2f0>
     dc3:	cmp    rcx,0x6
     dc7:	je     f7b <botlish_fn_7+0x293>
     dcd:	test   r12,0x1
     dd4:	je     ded <botlish_fn_7+0x105>
     dda:	mov    rcx,QWORD PTR [r15+0x8]
     dde:	mov    rax,r12
     de1:	sar    rax,1
     de4:	cmp    rax,rcx
     de7:	jb     e14 <botlish_fn_7+0x12c>
     ded:	mov    rdx,r12
     df0:	mov    rsi,r15
     df3:	mov    rdi,r14
     df6:	call   dfb <botlish_fn_7+0x113>
			df7: R_X86_64_PLT32	rt_list_get-0x4
     dfb:	test   rax,rax
     dfe:	jne    e0c <botlish_fn_7+0x124>
     e04:	mov    rdi,r14
     e07:	jmp    ee9 <botlish_fn_7+0x201>
     e0c:	mov    rsi,rax
     e0f:	jmp    e1f <botlish_fn_7+0x137>
     e14:	mov    rcx,QWORD PTR [r15+0x10]
     e18:	mov    rax,QWORD PTR [rcx+rax*8]
     e1c:	mov    rsi,rax
     e1f:	mov    QWORD PTR [rbx+0x20],rsi
     e23:	mov    QWORD PTR [rsp+0x8],rsi
     e28:	mov    QWORD PTR [rbx+0x28],0x1
     e30:	mov    rdi,r14
     e33:	call   e38 <botlish_fn_7+0x150>
			e34: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     e38:	test   rax,rax
     e3b:	mov    r9,rax
     e3e:	jne    e4c <botlish_fn_7+0x164>
     e44:	mov    rdi,r14
     e47:	jmp    ee9 <botlish_fn_7+0x201>
     e4c:	xor    edi,edi
     e4e:	mov    rsi,QWORD PTR [rsp+0x8]
     e53:	test   rsi,0x7
     e5a:	jne    e6a <botlish_fn_7+0x182>
     e60:	movzx  rax,BYTE PTR [rsi]
     e64:	cmp    al,0x8
     e66:	sete   dil
     e6a:	test   dil,dil
     e6d:	jne    e90 <botlish_fn_7+0x1a8>
     e73:	mov    rdi,r14
     e76:	mov    rax,QWORD PTR [rdi+0x10]
     e7a:	mov    rcx,QWORD PTR [rax+0x8]
     e7e:	mov    edx,0x8
     e83:	call   e88 <botlish_fn_7+0x1a0>
			e84: R_X86_64_PLT32	rt_type_error-0x4
     e88:	mov    rdi,r14
     e8b:	jmp    ee9 <botlish_fn_7+0x201>
     e90:	mov    QWORD PTR [rsp+0x8],rsi
     e95:	mov    r8d,0x1
     e9b:	mov    rcx,QWORD PTR [rsp+0x8]
     ea0:	mov    rdx,QWORD PTR [rsp]
     ea4:	mov    rsi,r13
     ea7:	mov    rdi,r14
     eaa:	call   eaf <botlish_fn_7+0x1c7>
			eab: R_X86_64_PLT32	rt_mutarray_copy-0x4
     eaf:	test   rax,rax
     eb2:	jne    ec0 <botlish_fn_7+0x1d8>
     eb8:	mov    rdi,r14
     ebb:	jmp    ee9 <botlish_fn_7+0x201>
     ec0:	sar    r12,1
     ec3:	add    r12,0x1
     eca:	shl    r12,1
     ecd:	or     r12,0x1
     ed1:	mov    QWORD PTR [rbx+0x8],r12
     ed5:	mov    rdi,r14
     ed8:	call   edd <botlish_fn_7+0x1f5>
			ed9: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     edd:	test   rax,rax
     ee0:	jne    f14 <botlish_fn_7+0x22c>
     ee6:	mov    rdi,r14
     ee9:	mov    rdi,r14
     eec:	mov    QWORD PTR [rdi],rbx
     eef:	xor    rax,rax
     ef2:	mov    rbx,QWORD PTR [rsp+0x10]
     ef7:	mov    r12,QWORD PTR [rsp+0x18]
     efc:	mov    r13,QWORD PTR [rsp+0x20]
     f01:	mov    r14,QWORD PTR [rsp+0x28]
     f06:	mov    r15,QWORD PTR [rsp+0x30]
     f0b:	add    rsp,0x40
     f0f:	mov    rsp,rbp
     f12:	pop    rbp
     f13:	ret
     f14:	mov    QWORD PTR [rbx+0x20],rax
     f18:	mov    rsi,QWORD PTR [rsp]
     f1c:	mov    rcx,rsi
     f1f:	and    rcx,rax
     f22:	test   rcx,0x1
     f29:	jne    f3b <botlish_fn_7+0x253>
     f2f:	mov    rdx,rax
     f32:	mov    rsi,QWORD PTR [rsp]
     f36:	jmp    f5b <botlish_fn_7+0x273>
     f3b:	lea    rcx,[rax-0x1]
     f3f:	mov    rdx,rax
     f42:	mov    rsi,QWORD PTR [rsp]
     f46:	mov    rax,rsi
     f49:	add    rax,rcx
     f4c:	seto   cl
     f4f:	test   cl,cl
     f51:	je     f63 <botlish_fn_7+0x27b>
     f57:	mov    rsi,QWORD PTR [rsp]
     f5b:	mov    rdi,r14
     f5e:	call   f63 <botlish_fn_7+0x27b>
			f5f: R_X86_64_PLT32	rt_int_add-0x4
     f63:	mov    QWORD PTR [rbx],r15
     f66:	mov    QWORD PTR [rbx+0x8],r12
     f6a:	mov    QWORD PTR [rbx+0x10],r13
     f6e:	mov    QWORD PTR [rbx+0x18],rax
     f72:	mov    QWORD PTR [rsp],rax
     f76:	jmp    d72 <botlish_fn_7+0x8a>
     f7b:	mov    rdi,r14
     f7e:	mov    QWORD PTR [rdi],rbx
     f81:	mov    rax,QWORD PTR [rsp]
     f85:	mov    rbx,QWORD PTR [rsp+0x10]
     f8a:	mov    r12,QWORD PTR [rsp+0x18]
     f8f:	mov    r13,QWORD PTR [rsp+0x20]
     f94:	mov    r14,QWORD PTR [rsp+0x28]
     f99:	mov    r15,QWORD PTR [rsp+0x30]
     f9e:	add    rsp,0x40
     fa2:	mov    rsp,rbp
     fa5:	pop    rbp
     fa6:	ret
     fa7:	mov    r14,rdi
     faa:	call   faf <botlish_fn_7+0x2c7>
			fab: R_X86_64_PLT32	rt_stack_overflow-0x4
     faf:	xor    rax,rax
     fb2:	mov    rbx,QWORD PTR [rsp+0x10]
     fb7:	mov    r12,QWORD PTR [rsp+0x18]
     fbc:	mov    r13,QWORD PTR [rsp+0x20]
     fc1:	mov    r14,QWORD PTR [rsp+0x28]
     fc6:	mov    r15,QWORD PTR [rsp+0x30]
     fcb:	add    rsp,0x40
     fcf:	mov    rsp,rbp
     fd2:	pop    rbp
     fd3:	ret
     fd4:	add    BYTE PTR [rax],al
     fd6:	add    BYTE PTR [rax],al
     fd8:	(bad)
     fd9:	add    BYTE PTR [rax],al
     fdb:	add    BYTE PTR [rax],al
     fdd:	add    BYTE PTR [rax],al
	...

0000000000000fe0 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     fe0:	push   rbp
     fe1:	mov    rbp,rsp
     fe4:	mov    rsi,QWORD PTR [rdx]
     fe7:	mov    r9,QWORD PTR [rdx+0x8]
     feb:	mov    rcx,QWORD PTR [rdx+0x10]
     fef:	mov    r8,QWORD PTR [rdx+0x18]
     ff3:	mov    rdx,r9
     ff6:	call   ffb <botlish_entry_7+0x1b>
			ff7: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     ffb:	mov    rsp,rbp
     ffe:	pop    rbp
     fff:	ret

0000000000001000 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    1000:	push   rbp
    1001:	mov    rbp,rsp
    1004:	sub    rsp,0x40
    1008:	mov    QWORD PTR [rsp+0x10],rbx
    100d:	mov    QWORD PTR [rsp+0x18],r12
    1012:	mov    QWORD PTR [rsp+0x20],r13
    1017:	mov    QWORD PTR [rsp+0x28],r14
    101c:	mov    QWORD PTR [rsp+0x30],r15
    1021:	mov    r14,QWORD PTR [rdi]
    1024:	mov    rax,QWORD PTR [rdi+0x8]
    1028:	lea    r9,[r14+0x30]
    102c:	cmp    r9,rax
    102f:	ja     1275 <botlish_fn_8+0x275>
    1035:	lea    rax,[r14+0x30]
    1039:	mov    QWORD PTR [rdi],rax
    103c:	mov    r15,rdi
    103f:	mov    QWORD PTR [r14],0x0
    1046:	mov    QWORD PTR [r14+0x8],0x0
    104e:	mov    QWORD PTR [r14+0x10],0x0
    1056:	mov    QWORD PTR [r14+0x18],0x0
    105e:	mov    QWORD PTR [r14+0x20],0x0
    1066:	mov    QWORD PTR [r14+0x28],0x0
    106e:	mov    QWORD PTR [r14],rsi
    1071:	mov    QWORD PTR [r14+0x8],rdx
    1075:	mov    rbx,rdx
    1078:	mov    QWORD PTR [r14+0x10],rcx
    107c:	mov    r13,rcx
    107f:	mov    QWORD PTR [r14+0x18],r8
    1083:	mov    r12,rsi
    1086:	mov    QWORD PTR [rsp],r8
    108a:	mov    rsi,r12
    108d:	mov    rdi,r15
    1090:	call   1095 <botlish_fn_8+0x95>
			1091: R_X86_64_PLT32	rt_list_len-0x4
    1095:	mov    rcx,rbx
    1098:	and    rcx,rax
    109b:	mov    rdx,rax
    109e:	test   rcx,0x1
    10a5:	jne    10cb <botlish_fn_8+0xcb>
    10ab:	mov    rsi,rbx
    10ae:	mov    rdi,r15
    10b1:	call   10b6 <botlish_fn_8+0xb6>
			10b2: R_X86_64_PLT32	rt_int_cmp-0x4
    10b6:	mov    ecx,0x2
    10bb:	test   rax,rax
    10be:	cmovge rcx,QWORD PTR [rip+0x1e2]        # 12a8 <botlish_fn_8+0x2a8>
    10c6:	jmp    10db <botlish_fn_8+0xdb>
    10cb:	mov    ecx,0x2
    10d0:	cmp    rbx,rdx
    10d3:	cmovge rcx,QWORD PTR [rip+0x1cd]        # 12a8 <botlish_fn_8+0x2a8>
    10db:	cmp    rcx,0x6
    10df:	je     1249 <botlish_fn_8+0x249>
    10e5:	test   rbx,0x1
    10ec:	je     1106 <botlish_fn_8+0x106>
    10f2:	mov    r8,QWORD PTR [r12+0x8]
    10f7:	mov    rdi,rbx
    10fa:	sar    rdi,1
    10fd:	cmp    rdi,r8
    1100:	jb     112d <botlish_fn_8+0x12d>
    1106:	mov    rdx,rbx
    1109:	mov    rsi,r12
    110c:	mov    rdi,r15
    110f:	call   1114 <botlish_fn_8+0x114>
			1110: R_X86_64_PLT32	rt_list_get-0x4
    1114:	test   rax,rax
    1117:	jne    1125 <botlish_fn_8+0x125>
    111d:	mov    rdi,r15
    1120:	jmp    11b7 <botlish_fn_8+0x1b7>
    1125:	mov    rcx,rax
    1128:	jmp    1136 <botlish_fn_8+0x136>
    112d:	mov    rax,QWORD PTR [r12+0x10]
    1132:	mov    rcx,QWORD PTR [rax+rdi*8]
    1136:	mov    QWORD PTR [r14+0x20],rcx
    113a:	mov    QWORD PTR [rsp+0x8],rcx
    113f:	mov    QWORD PTR [r14+0x28],0x1
    1147:	mov    rdi,r15
    114a:	call   114f <botlish_fn_8+0x14f>
			114b: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    114f:	test   rax,rax
    1152:	mov    r9,rax
    1155:	jne    1163 <botlish_fn_8+0x163>
    115b:	mov    rdi,r15
    115e:	jmp    11b7 <botlish_fn_8+0x1b7>
    1163:	mov    r8d,0x1
    1169:	mov    rcx,QWORD PTR [rsp+0x8]
    116e:	mov    rdx,QWORD PTR [rsp]
    1172:	mov    rsi,r13
    1175:	mov    rdi,r15
    1178:	call   117d <botlish_fn_8+0x17d>
			1179: R_X86_64_PLT32	rt_mutarray_copy-0x4
    117d:	test   rax,rax
    1180:	jne    118e <botlish_fn_8+0x18e>
    1186:	mov    rdi,r15
    1189:	jmp    11b7 <botlish_fn_8+0x1b7>
    118e:	sar    rbx,1
    1191:	add    rbx,0x1
    1198:	shl    rbx,1
    119b:	or     rbx,0x1
    119f:	mov    QWORD PTR [r14+0x8],rbx
    11a3:	mov    rdi,r15
    11a6:	call   11ab <botlish_fn_8+0x1ab>
			11a7: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    11ab:	test   rax,rax
    11ae:	jne    11e2 <botlish_fn_8+0x1e2>
    11b4:	mov    rdi,r15
    11b7:	mov    rdi,r15
    11ba:	mov    QWORD PTR [rdi],r14
    11bd:	xor    rax,rax
    11c0:	mov    rbx,QWORD PTR [rsp+0x10]
    11c5:	mov    r12,QWORD PTR [rsp+0x18]
    11ca:	mov    r13,QWORD PTR [rsp+0x20]
    11cf:	mov    r14,QWORD PTR [rsp+0x28]
    11d4:	mov    r15,QWORD PTR [rsp+0x30]
    11d9:	add    rsp,0x40
    11dd:	mov    rsp,rbp
    11e0:	pop    rbp
    11e1:	ret
    11e2:	mov    QWORD PTR [r14+0x20],rax
    11e6:	mov    rsi,QWORD PTR [rsp]
    11ea:	mov    rcx,rsi
    11ed:	and    rcx,rax
    11f0:	test   rcx,0x1
    11f7:	jne    1209 <botlish_fn_8+0x209>
    11fd:	mov    rdx,rax
    1200:	mov    rsi,QWORD PTR [rsp]
    1204:	jmp    1229 <botlish_fn_8+0x229>
    1209:	lea    rcx,[rax-0x1]
    120d:	mov    rdx,rax
    1210:	mov    rsi,QWORD PTR [rsp]
    1214:	mov    rax,rsi
    1217:	add    rax,rcx
    121a:	seto   cl
    121d:	test   cl,cl
    121f:	je     1231 <botlish_fn_8+0x231>
    1225:	mov    rsi,QWORD PTR [rsp]
    1229:	mov    rdi,r15
    122c:	call   1231 <botlish_fn_8+0x231>
			122d: R_X86_64_PLT32	rt_int_add-0x4
    1231:	mov    QWORD PTR [r14],r12
    1234:	mov    QWORD PTR [r14+0x8],rbx
    1238:	mov    QWORD PTR [r14+0x10],r13
    123c:	mov    QWORD PTR [r14+0x18],rax
    1240:	mov    QWORD PTR [rsp],rax
    1244:	jmp    108a <botlish_fn_8+0x8a>
    1249:	mov    rdi,r15
    124c:	mov    QWORD PTR [rdi],r14
    124f:	mov    rax,QWORD PTR [rsp]
    1253:	mov    rbx,QWORD PTR [rsp+0x10]
    1258:	mov    r12,QWORD PTR [rsp+0x18]
    125d:	mov    r13,QWORD PTR [rsp+0x20]
    1262:	mov    r14,QWORD PTR [rsp+0x28]
    1267:	mov    r15,QWORD PTR [rsp+0x30]
    126c:	add    rsp,0x40
    1270:	mov    rsp,rbp
    1273:	pop    rbp
    1274:	ret
    1275:	mov    r15,rdi
    1278:	call   127d <botlish_fn_8+0x27d>
			1279: R_X86_64_PLT32	rt_stack_overflow-0x4
    127d:	xor    rax,rax
    1280:	mov    rbx,QWORD PTR [rsp+0x10]
    1285:	mov    r12,QWORD PTR [rsp+0x18]
    128a:	mov    r13,QWORD PTR [rsp+0x20]
    128f:	mov    r14,QWORD PTR [rsp+0x28]
    1294:	mov    r15,QWORD PTR [rsp+0x30]
    1299:	add    rsp,0x40
    129d:	mov    rsp,rbp
    12a0:	pop    rbp
    12a1:	ret
    12a2:	add    BYTE PTR [rax],al
    12a4:	add    BYTE PTR [rax],al
    12a6:	add    BYTE PTR [rax],al
    12a8:	(bad)
    12a9:	add    BYTE PTR [rax],al
    12ab:	add    BYTE PTR [rax],al
    12ad:	add    BYTE PTR [rax],al
	...

00000000000012b0 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    12b0:	push   rbp
    12b1:	mov    rbp,rsp
    12b4:	mov    rsi,QWORD PTR [rdx]
    12b7:	mov    r9,QWORD PTR [rdx+0x8]
    12bb:	mov    rcx,QWORD PTR [rdx+0x10]
    12bf:	mov    r8,QWORD PTR [rdx+0x18]
    12c3:	mov    rdx,r9
    12c6:	call   12cb <botlish_entry_8+0x1b>
			12c7: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    12cb:	mov    rsp,rbp
    12ce:	pop    rbp
    12cf:	ret

00000000000012d0 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
    12d0:	push   rbp
    12d1:	mov    rbp,rsp
    12d4:	sub    rsp,0x40
    12d8:	mov    QWORD PTR [rsp+0x10],rbx
    12dd:	mov    QWORD PTR [rsp+0x18],r12
    12e2:	mov    QWORD PTR [rsp+0x20],r13
    12e7:	mov    QWORD PTR [rsp+0x28],r14
    12ec:	mov    QWORD PTR [rsp+0x30],r15
    12f1:	mov    r12,QWORD PTR [rdi]
    12f4:	mov    rax,QWORD PTR [rdi+0x8]
    12f8:	lea    r8,[r12+0x38]
    12fd:	cmp    r8,rax
    1300:	ja     1545 <botlish_fn_9+0x275>
    1306:	lea    rax,[r12+0x38]
    130b:	mov    QWORD PTR [rdi],rax
    130e:	mov    r14,rdi
    1311:	mov    QWORD PTR [r12],0x0
    1319:	mov    QWORD PTR [r12+0x8],0x0
    1322:	mov    QWORD PTR [r12+0x10],0x0
    132b:	mov    QWORD PTR [r12+0x18],0x0
    1334:	mov    QWORD PTR [r12+0x20],0x0
    133d:	mov    QWORD PTR [r12+0x28],0x0
    1346:	mov    QWORD PTR [r12+0x30],0x0
    134f:	mov    QWORD PTR [r12],rsi
    1353:	mov    QWORD PTR [rsp],rsi
    1357:	mov    QWORD PTR [r12+0x8],rdx
    135c:	mov    r15,rdx
    135f:	mov    QWORD PTR [r12+0x10],rcx
    1364:	mov    rbx,rcx
    1367:	mov    rsi,QWORD PTR [rsp]
    136b:	mov    rdi,r14
    136e:	call   1373 <botlish_fn_9+0xa3>
			136f: R_X86_64_PLT32	rt_list_len-0x4
    1373:	mov    QWORD PTR [r12+0x18],rax
    1378:	mov    r13,rax
    137b:	mov    rdi,r14
    137e:	call   1383 <botlish_fn_9+0xb3>
			137f: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1383:	test   rax,rax
    1386:	jne    1394 <botlish_fn_9+0xc4>
    138c:	mov    rdi,r14
    138f:	jmp    14f2 <botlish_fn_9+0x222>
    1394:	mov    QWORD PTR [r12+0x20],rax
    1399:	mov    rcx,r13
    139c:	mov    rdx,rcx
    139f:	and    rdx,rax
    13a2:	mov    rsi,rax
    13a5:	test   rdx,0x1
    13ac:	jne    13bd <botlish_fn_9+0xed>
    13b2:	mov    rdx,rsi
    13b5:	mov    rsi,rcx
    13b8:	jmp    13f2 <botlish_fn_9+0x122>
    13bd:	mov    rax,rcx
    13c0:	sar    rax,1
    13c3:	mov    r13,rcx
    13c6:	mov    rcx,rsi
    13c9:	lea    rdx,[rcx-0x1]
    13cd:	imul   rdx
    13d0:	seto   cl
    13d3:	or     rax,0x1
    13d7:	test   cl,cl
    13d9:	je     13ea <botlish_fn_9+0x11a>
    13df:	mov    rdx,rsi
    13e2:	mov    rsi,r13
    13e5:	jmp    13f2 <botlish_fn_9+0x122>
    13ea:	mov    rsi,rax
    13ed:	jmp    13fd <botlish_fn_9+0x12d>
    13f2:	mov    rdi,r14
    13f5:	call   13fa <botlish_fn_9+0x12a>
			13f6: R_X86_64_PLT32	rt_int_mul-0x4
    13fa:	mov    rsi,rax
    13fd:	mov    QWORD PTR [r12+0x18],rsi
    1402:	mov    rax,rsi
    1405:	and    rax,rbx
    1408:	test   rax,0x1
    140e:	je     142b <botlish_fn_9+0x15b>
    1414:	lea    rdi,[rbx-0x1]
    1418:	mov    r13,rsi
    141b:	add    r13,rdi
    141e:	seto   dil
    1422:	test   dil,dil
    1425:	je     1439 <botlish_fn_9+0x169>
    142b:	mov    rdx,rbx
    142e:	mov    rdi,r14
    1431:	call   1436 <botlish_fn_9+0x166>
			1432: R_X86_64_PLT32	rt_int_add-0x4
    1436:	mov    r13,rax
    1439:	mov    QWORD PTR [r12+0x18],r13
    143e:	mov    rsi,r13
    1441:	mov    rdi,r14
    1444:	call   1449 <botlish_fn_9+0x179>
			1445: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1449:	mov    rcx,rax
    144c:	mov    QWORD PTR [rsp+0x8],rax
    1451:	test   rax,rcx
    1454:	jne    1462 <botlish_fn_9+0x192>
    145a:	mov    rdi,r14
    145d:	jmp    14f2 <botlish_fn_9+0x222>
    1462:	mov    rax,QWORD PTR [rsp+0x8]
    1467:	mov    QWORD PTR [r12+0x20],rax
    146c:	mov    r8d,0x1
    1472:	mov    QWORD PTR [r12+0x28],0x1
    147b:	mov    QWORD PTR [r12+0x30],0x1
    1484:	mov    rsi,QWORD PTR [rsp]
    1488:	mov    rcx,QWORD PTR [rsp+0x8]
    148d:	mov    rdi,r14
    1490:	mov    rdx,r8
    1493:	call   1498 <botlish_fn_9+0x1c8>
			1494: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    1498:	test   rax,rax
    149b:	mov    rdx,rax
    149e:	jne    14ac <botlish_fn_9+0x1dc>
    14a4:	mov    rdi,r14
    14a7:	jmp    14f2 <botlish_fn_9+0x222>
    14ac:	mov    r8d,0x1
    14b2:	mov    rcx,r15
    14b5:	mov    r9,rbx
    14b8:	mov    rsi,QWORD PTR [rsp+0x8]
    14bd:	mov    rdi,r14
    14c0:	call   14c5 <botlish_fn_9+0x1f5>
			14c1: R_X86_64_PLT32	rt_mutarray_copy-0x4
    14c5:	test   rax,rax
    14c8:	jne    14d6 <botlish_fn_9+0x206>
    14ce:	mov    rdi,r14
    14d1:	jmp    14f2 <botlish_fn_9+0x222>
    14d6:	mov    rdx,r13
    14d9:	mov    rsi,QWORD PTR [rsp+0x8]
    14de:	mov    rdi,r14
    14e1:	call   14e6 <botlish_fn_9+0x216>
			14e2: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    14e6:	test   rax,rax
    14e9:	jne    151d <botlish_fn_9+0x24d>
    14ef:	mov    rdi,r14
    14f2:	mov    rdi,r14
    14f5:	mov    QWORD PTR [rdi],r12
    14f8:	xor    rax,rax
    14fb:	mov    rbx,QWORD PTR [rsp+0x10]
    1500:	mov    r12,QWORD PTR [rsp+0x18]
    1505:	mov    r13,QWORD PTR [rsp+0x20]
    150a:	mov    r14,QWORD PTR [rsp+0x28]
    150f:	mov    r15,QWORD PTR [rsp+0x30]
    1514:	add    rsp,0x40
    1518:	mov    rsp,rbp
    151b:	pop    rbp
    151c:	ret
    151d:	mov    rdi,r14
    1520:	mov    QWORD PTR [rdi],r12
    1523:	mov    rbx,QWORD PTR [rsp+0x10]
    1528:	mov    r12,QWORD PTR [rsp+0x18]
    152d:	mov    r13,QWORD PTR [rsp+0x20]
    1532:	mov    r14,QWORD PTR [rsp+0x28]
    1537:	mov    r15,QWORD PTR [rsp+0x30]
    153c:	add    rsp,0x40
    1540:	mov    rsp,rbp
    1543:	pop    rbp
    1544:	ret
    1545:	mov    r14,rdi
    1548:	call   154d <botlish_fn_9+0x27d>
			1549: R_X86_64_PLT32	rt_stack_overflow-0x4
    154d:	xor    rax,rax
    1550:	mov    rbx,QWORD PTR [rsp+0x10]
    1555:	mov    r12,QWORD PTR [rsp+0x18]
    155a:	mov    r13,QWORD PTR [rsp+0x20]
    155f:	mov    r14,QWORD PTR [rsp+0x28]
    1564:	mov    r15,QWORD PTR [rsp+0x30]
    1569:	add    rsp,0x40
    156d:	mov    rsp,rbp
    1570:	pop    rbp
    1571:	ret

0000000000001572 <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1572:	push   rbp
    1573:	mov    rbp,rsp
    1576:	mov    rsi,QWORD PTR [rdx]
    1579:	mov    r8,QWORD PTR [rdx+0x8]
    157d:	mov    rcx,QWORD PTR [rdx+0x10]
    1581:	mov    rdx,r8
    1584:	call   1589 <botlish_entry_9+0x17>
			1585: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    1589:	mov    rsp,rbp
    158c:	pop    rbp
    158d:	ret

000000000000158e <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    158e:	push   rbp
    158f:	mov    rbp,rsp
    1592:	sub    rsp,0x40
    1596:	mov    QWORD PTR [rsp+0x10],rbx
    159b:	mov    QWORD PTR [rsp+0x18],r12
    15a0:	mov    QWORD PTR [rsp+0x20],r13
    15a5:	mov    QWORD PTR [rsp+0x28],r14
    15aa:	mov    QWORD PTR [rsp+0x30],r15
    15af:	mov    r12,QWORD PTR [rdi]
    15b2:	mov    rax,QWORD PTR [rdi+0x8]
    15b6:	lea    r8,[r12+0x38]
    15bb:	cmp    r8,rax
    15be:	ja     1803 <botlish_fn_10+0x275>
    15c4:	lea    rax,[r12+0x38]
    15c9:	mov    QWORD PTR [rdi],rax
    15cc:	mov    r14,rdi
    15cf:	mov    QWORD PTR [r12],0x0
    15d7:	mov    QWORD PTR [r12+0x8],0x0
    15e0:	mov    QWORD PTR [r12+0x10],0x0
    15e9:	mov    QWORD PTR [r12+0x18],0x0
    15f2:	mov    QWORD PTR [r12+0x20],0x0
    15fb:	mov    QWORD PTR [r12+0x28],0x0
    1604:	mov    QWORD PTR [r12+0x30],0x0
    160d:	mov    QWORD PTR [r12],rsi
    1611:	mov    QWORD PTR [rsp],rsi
    1615:	mov    QWORD PTR [r12+0x8],rdx
    161a:	mov    r15,rdx
    161d:	mov    QWORD PTR [r12+0x10],rcx
    1622:	mov    rbx,rcx
    1625:	mov    rsi,QWORD PTR [rsp]
    1629:	mov    rdi,r14
    162c:	call   1631 <botlish_fn_10+0xa3>
			162d: R_X86_64_PLT32	rt_list_len-0x4
    1631:	mov    QWORD PTR [r12+0x18],rax
    1636:	mov    r13,rax
    1639:	mov    rdi,r14
    163c:	call   1641 <botlish_fn_10+0xb3>
			163d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1641:	test   rax,rax
    1644:	jne    1652 <botlish_fn_10+0xc4>
    164a:	mov    rdi,r14
    164d:	jmp    17b0 <botlish_fn_10+0x222>
    1652:	mov    QWORD PTR [r12+0x20],rax
    1657:	mov    rcx,r13
    165a:	mov    rdx,rcx
    165d:	and    rdx,rax
    1660:	mov    rsi,rax
    1663:	test   rdx,0x1
    166a:	jne    167b <botlish_fn_10+0xed>
    1670:	mov    rdx,rsi
    1673:	mov    rsi,rcx
    1676:	jmp    16b0 <botlish_fn_10+0x122>
    167b:	mov    rax,rcx
    167e:	sar    rax,1
    1681:	mov    r13,rcx
    1684:	mov    rcx,rsi
    1687:	lea    rdx,[rcx-0x1]
    168b:	imul   rdx
    168e:	seto   cl
    1691:	or     rax,0x1
    1695:	test   cl,cl
    1697:	je     16a8 <botlish_fn_10+0x11a>
    169d:	mov    rdx,rsi
    16a0:	mov    rsi,r13
    16a3:	jmp    16b0 <botlish_fn_10+0x122>
    16a8:	mov    rsi,rax
    16ab:	jmp    16bb <botlish_fn_10+0x12d>
    16b0:	mov    rdi,r14
    16b3:	call   16b8 <botlish_fn_10+0x12a>
			16b4: R_X86_64_PLT32	rt_int_mul-0x4
    16b8:	mov    rsi,rax
    16bb:	mov    QWORD PTR [r12+0x18],rsi
    16c0:	mov    rax,rsi
    16c3:	and    rax,rbx
    16c6:	test   rax,0x1
    16cc:	je     16e9 <botlish_fn_10+0x15b>
    16d2:	lea    rdi,[rbx-0x1]
    16d6:	mov    r13,rsi
    16d9:	add    r13,rdi
    16dc:	seto   dil
    16e0:	test   dil,dil
    16e3:	je     16f7 <botlish_fn_10+0x169>
    16e9:	mov    rdx,rbx
    16ec:	mov    rdi,r14
    16ef:	call   16f4 <botlish_fn_10+0x166>
			16f0: R_X86_64_PLT32	rt_int_add-0x4
    16f4:	mov    r13,rax
    16f7:	mov    QWORD PTR [r12+0x18],r13
    16fc:	mov    rsi,r13
    16ff:	mov    rdi,r14
    1702:	call   1707 <botlish_fn_10+0x179>
			1703: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1707:	mov    rcx,rax
    170a:	mov    QWORD PTR [rsp+0x8],rax
    170f:	test   rax,rcx
    1712:	jne    1720 <botlish_fn_10+0x192>
    1718:	mov    rdi,r14
    171b:	jmp    17b0 <botlish_fn_10+0x222>
    1720:	mov    rax,QWORD PTR [rsp+0x8]
    1725:	mov    QWORD PTR [r12+0x20],rax
    172a:	mov    r8d,0x1
    1730:	mov    QWORD PTR [r12+0x28],0x1
    1739:	mov    QWORD PTR [r12+0x30],0x1
    1742:	mov    rsi,QWORD PTR [rsp]
    1746:	mov    rcx,QWORD PTR [rsp+0x8]
    174b:	mov    rdi,r14
    174e:	mov    rdx,r8
    1751:	call   1756 <botlish_fn_10+0x1c8>
			1752: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    1756:	test   rax,rax
    1759:	mov    rdx,rax
    175c:	jne    176a <botlish_fn_10+0x1dc>
    1762:	mov    rdi,r14
    1765:	jmp    17b0 <botlish_fn_10+0x222>
    176a:	mov    r8d,0x1
    1770:	mov    rcx,r15
    1773:	mov    r9,rbx
    1776:	mov    rsi,QWORD PTR [rsp+0x8]
    177b:	mov    rdi,r14
    177e:	call   1783 <botlish_fn_10+0x1f5>
			177f: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1783:	test   rax,rax
    1786:	jne    1794 <botlish_fn_10+0x206>
    178c:	mov    rdi,r14
    178f:	jmp    17b0 <botlish_fn_10+0x222>
    1794:	mov    rdx,r13
    1797:	mov    rsi,QWORD PTR [rsp+0x8]
    179c:	mov    rdi,r14
    179f:	call   17a4 <botlish_fn_10+0x216>
			17a0: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    17a4:	test   rax,rax
    17a7:	jne    17db <botlish_fn_10+0x24d>
    17ad:	mov    rdi,r14
    17b0:	mov    rdi,r14
    17b3:	mov    QWORD PTR [rdi],r12
    17b6:	xor    rax,rax
    17b9:	mov    rbx,QWORD PTR [rsp+0x10]
    17be:	mov    r12,QWORD PTR [rsp+0x18]
    17c3:	mov    r13,QWORD PTR [rsp+0x20]
    17c8:	mov    r14,QWORD PTR [rsp+0x28]
    17cd:	mov    r15,QWORD PTR [rsp+0x30]
    17d2:	add    rsp,0x40
    17d6:	mov    rsp,rbp
    17d9:	pop    rbp
    17da:	ret
    17db:	mov    rdi,r14
    17de:	mov    QWORD PTR [rdi],r12
    17e1:	mov    rbx,QWORD PTR [rsp+0x10]
    17e6:	mov    r12,QWORD PTR [rsp+0x18]
    17eb:	mov    r13,QWORD PTR [rsp+0x20]
    17f0:	mov    r14,QWORD PTR [rsp+0x28]
    17f5:	mov    r15,QWORD PTR [rsp+0x30]
    17fa:	add    rsp,0x40
    17fe:	mov    rsp,rbp
    1801:	pop    rbp
    1802:	ret
    1803:	mov    r14,rdi
    1806:	call   180b <botlish_fn_10+0x27d>
			1807: R_X86_64_PLT32	rt_stack_overflow-0x4
    180b:	xor    rax,rax
    180e:	mov    rbx,QWORD PTR [rsp+0x10]
    1813:	mov    r12,QWORD PTR [rsp+0x18]
    1818:	mov    r13,QWORD PTR [rsp+0x20]
    181d:	mov    r14,QWORD PTR [rsp+0x28]
    1822:	mov    r15,QWORD PTR [rsp+0x30]
    1827:	add    rsp,0x40
    182b:	mov    rsp,rbp
    182e:	pop    rbp
    182f:	ret

0000000000001830 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1830:	push   rbp
    1831:	mov    rbp,rsp
    1834:	mov    rsi,QWORD PTR [rdx]
    1837:	mov    r8,QWORD PTR [rdx+0x8]
    183b:	mov    rcx,QWORD PTR [rdx+0x10]
    183f:	mov    rdx,r8
    1842:	call   1847 <botlish_entry_10+0x17>
			1843: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1847:	mov    rsp,rbp
    184a:	pop    rbp
    184b:	ret
    184c:	add    BYTE PTR [rax],al
	...

0000000000001850 <botlish_fn_11: peek<str, int>>:
    1850:	push   rbp
    1851:	mov    rbp,rsp
    1854:	sub    rsp,0x20
    1858:	mov    QWORD PTR [rsp],rbx
    185c:	mov    QWORD PTR [rsp+0x8],r12
    1861:	mov    QWORD PTR [rsp+0x10],r13
    1866:	mov    QWORD PTR [rsp+0x18],r14
    186b:	mov    r12,QWORD PTR [rdi]
    186e:	mov    rax,QWORD PTR [rdi+0x8]
    1872:	lea    rcx,[r12+0x18]
    1877:	cmp    rcx,rax
    187a:	ja     19d7 <botlish_fn_11+0x187>
    1880:	lea    rax,[r12+0x18]
    1885:	mov    QWORD PTR [rdi],rax
    1888:	mov    r13,rdi
    188b:	mov    QWORD PTR [r12],0x0
    1893:	mov    QWORD PTR [r12+0x8],0x0
    189c:	mov    QWORD PTR [r12+0x10],0x0
    18a5:	mov    QWORD PTR [r12],rsi
    18a9:	mov    r14,rsi
    18ac:	mov    QWORD PTR [r12+0x8],rdx
    18b1:	mov    rbx,rdx
    18b4:	mov    rsi,r14
    18b7:	mov    rdi,r13
    18ba:	call   18bf <botlish_fn_11+0x6f>
			18bb: R_X86_64_PLT32	rt_str_len-0x4
    18bf:	mov    rcx,rbx
    18c2:	and    rcx,rax
    18c5:	mov    rdx,rax
    18c8:	test   rcx,0x1
    18cf:	jne    18f5 <botlish_fn_11+0xa5>
    18d5:	mov    rsi,rbx
    18d8:	mov    rdi,r13
    18db:	call   18e0 <botlish_fn_11+0x90>
			18dc: R_X86_64_PLT32	rt_int_cmp-0x4
    18e0:	mov    ecx,0x2
    18e5:	test   rax,rax
    18e8:	cmovge rcx,QWORD PTR [rip+0x110]        # 1a00 <botlish_fn_11+0x1b0>
    18f0:	jmp    1905 <botlish_fn_11+0xb5>
    18f5:	mov    ecx,0x2
    18fa:	cmp    rbx,rdx
    18fd:	cmovge rcx,QWORD PTR [rip+0xfb]        # 1a00 <botlish_fn_11+0x1b0>
    1905:	cmp    rcx,0x6
    1909:	je     19ad <botlish_fn_11+0x15d>
    190f:	mov    QWORD PTR [r12+0x10],0x3
    1918:	test   rbx,0x1
    191f:	je     1937 <botlish_fn_11+0xe7>
    1925:	mov    rcx,rbx
    1928:	add    rcx,0x2
    192c:	seto   al
    192f:	test   al,al
    1931:	je     194a <botlish_fn_11+0xfa>
    1937:	mov    edx,0x3
    193c:	mov    rsi,rbx
    193f:	mov    rdi,r13
    1942:	call   1947 <botlish_fn_11+0xf7>
			1943: R_X86_64_PLT32	rt_int_add-0x4
    1947:	mov    rcx,rax
    194a:	mov    QWORD PTR [r12+0x10],rcx
    194f:	mov    rdx,rbx
    1952:	mov    rsi,r14
    1955:	mov    rdi,r13
    1958:	call   195d <botlish_fn_11+0x10d>
			1959: R_X86_64_PLT32	rt_substr-0x4
    195d:	test   rax,rax
    1960:	jne    198b <botlish_fn_11+0x13b>
    1966:	mov    rdi,r13
    1969:	mov    QWORD PTR [rdi],r12
    196c:	xor    rax,rax
    196f:	mov    rbx,QWORD PTR [rsp]
    1973:	mov    r12,QWORD PTR [rsp+0x8]
    1978:	mov    r13,QWORD PTR [rsp+0x10]
    197d:	mov    r14,QWORD PTR [rsp+0x18]
    1982:	add    rsp,0x20
    1986:	mov    rsp,rbp
    1989:	pop    rbp
    198a:	ret
    198b:	mov    rdi,r13
    198e:	mov    QWORD PTR [rdi],r12
    1991:	mov    rbx,QWORD PTR [rsp]
    1995:	mov    r12,QWORD PTR [rsp+0x8]
    199a:	mov    r13,QWORD PTR [rsp+0x10]
    199f:	mov    r14,QWORD PTR [rsp+0x18]
    19a4:	add    rsp,0x20
    19a8:	mov    rsp,rbp
    19ab:	pop    rbp
    19ac:	ret
    19ad:	mov    rdi,r13
    19b0:	mov    rax,QWORD PTR [rdi+0x10]
    19b4:	mov    rax,QWORD PTR [rax+0x10]
    19b8:	mov    QWORD PTR [rdi],r12
    19bb:	mov    rbx,QWORD PTR [rsp]
    19bf:	mov    r12,QWORD PTR [rsp+0x8]
    19c4:	mov    r13,QWORD PTR [rsp+0x10]
    19c9:	mov    r14,QWORD PTR [rsp+0x18]
    19ce:	add    rsp,0x20
    19d2:	mov    rsp,rbp
    19d5:	pop    rbp
    19d6:	ret
    19d7:	mov    r13,rdi
    19da:	call   19df <botlish_fn_11+0x18f>
			19db: R_X86_64_PLT32	rt_stack_overflow-0x4
    19df:	xor    rax,rax
    19e2:	mov    rbx,QWORD PTR [rsp]
    19e6:	mov    r12,QWORD PTR [rsp+0x8]
    19eb:	mov    r13,QWORD PTR [rsp+0x10]
    19f0:	mov    r14,QWORD PTR [rsp+0x18]
    19f5:	add    rsp,0x20
    19f9:	mov    rsp,rbp
    19fc:	pop    rbp
    19fd:	ret
    19fe:	add    BYTE PTR [rax],al
    1a00:	(bad)
    1a01:	add    BYTE PTR [rax],al
    1a03:	add    BYTE PTR [rax],al
    1a05:	add    BYTE PTR [rax],al
	...

0000000000001a08 <botlish_entry_11: peek<str, int>>:
    1a08:	push   rbp
    1a09:	mov    rbp,rsp
    1a0c:	mov    rsi,QWORD PTR [rdx]
    1a0f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a13:	call   1a18 <botlish_entry_11+0x10>
			1a14: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1a18:	mov    rsp,rbp
    1a1b:	pop    rbp
    1a1c:	ret
    1a1d:	add    BYTE PTR [rax],al
	...

0000000000001a20 <botlish_fn_12: peek<str, int>>:
    1a20:	push   rbp
    1a21:	mov    rbp,rsp
    1a24:	sub    rsp,0x40
    1a28:	mov    QWORD PTR [rsp+0x10],rbx
    1a2d:	mov    QWORD PTR [rsp+0x18],r12
    1a32:	mov    QWORD PTR [rsp+0x20],r13
    1a37:	mov    QWORD PTR [rsp+0x28],r14
    1a3c:	mov    QWORD PTR [rsp+0x30],r15
    1a41:	mov    r13,rcx
    1a44:	mov    r12,QWORD PTR [rdi]
    1a47:	mov    rax,QWORD PTR [rdi+0x8]
    1a4b:	lea    rcx,[r12+0x18]
    1a50:	cmp    rcx,rax
    1a53:	ja     1bee <botlish_fn_12+0x1ce>
    1a59:	lea    rax,[r12+0x18]
    1a5e:	mov    QWORD PTR [rdi],rax
    1a61:	mov    r15,rdi
    1a64:	mov    QWORD PTR [r12],0x0
    1a6c:	mov    QWORD PTR [r12+0x8],0x0
    1a75:	mov    QWORD PTR [r12+0x10],0x0
    1a7e:	mov    QWORD PTR [r12],rsi
    1a82:	mov    r14,rsi
    1a85:	mov    QWORD PTR [r12+0x8],rdx
    1a8a:	mov    rbx,rdx
    1a8d:	mov    rsi,r14
    1a90:	mov    rdi,r15
    1a93:	call   1a98 <botlish_fn_12+0x78>
			1a94: R_X86_64_PLT32	rt_str_len-0x4
    1a98:	mov    rcx,rbx
    1a9b:	and    rcx,rax
    1a9e:	mov    rdx,rax
    1aa1:	test   rcx,0x1
    1aa8:	jne    1ace <botlish_fn_12+0xae>
    1aae:	mov    rsi,rbx
    1ab1:	mov    rdi,r15
    1ab4:	call   1ab9 <botlish_fn_12+0x99>
			1ab5: R_X86_64_PLT32	rt_int_cmp-0x4
    1ab9:	mov    ecx,0x2
    1abe:	test   rax,rax
    1ac1:	cmovge rcx,QWORD PTR [rip+0x157]        # 1c20 <botlish_fn_12+0x200>
    1ac9:	jmp    1ade <botlish_fn_12+0xbe>
    1ace:	mov    ecx,0x2
    1ad3:	cmp    rbx,rdx
    1ad6:	cmovge rcx,QWORD PTR [rip+0x142]        # 1c20 <botlish_fn_12+0x200>
    1ade:	cmp    rcx,0x6
    1ae2:	je     1bac <botlish_fn_12+0x18c>
    1ae8:	mov    QWORD PTR [r12+0x10],0x3
    1af1:	test   rbx,0x1
    1af8:	je     1b19 <botlish_fn_12+0xf9>
    1afe:	mov    rax,rbx
    1b01:	add    rax,0x2
    1b05:	seto   cl
    1b08:	test   cl,cl
    1b0a:	jne    1b19 <botlish_fn_12+0xf9>
    1b10:	mov    QWORD PTR [rsp],rax
    1b14:	jmp    1b2d <botlish_fn_12+0x10d>
    1b19:	mov    edx,0x3
    1b1e:	mov    rsi,rbx
    1b21:	mov    rdi,r15
    1b24:	call   1b29 <botlish_fn_12+0x109>
			1b25: R_X86_64_PLT32	rt_int_add-0x4
    1b29:	mov    QWORD PTR [rsp],rax
    1b2d:	mov    rcx,QWORD PTR [rsp]
    1b31:	mov    rdx,rbx
    1b34:	mov    rsi,r14
    1b37:	mov    rdi,r15
    1b3a:	call   1b3f <botlish_fn_12+0x11f>
			1b3b: R_X86_64_PLT32	rt_str_region_check-0x4
    1b3f:	test   rax,rax
    1b42:	jne    1b73 <botlish_fn_12+0x153>
    1b48:	mov    rdi,r15
    1b4b:	mov    QWORD PTR [rdi],r12
    1b4e:	xor    rax,rax
    1b51:	mov    rbx,QWORD PTR [rsp+0x10]
    1b56:	mov    r12,QWORD PTR [rsp+0x18]
    1b5b:	mov    r13,QWORD PTR [rsp+0x20]
    1b60:	mov    r14,QWORD PTR [rsp+0x28]
    1b65:	mov    r15,QWORD PTR [rsp+0x30]
    1b6a:	add    rsp,0x40
    1b6e:	mov    rsp,rbp
    1b71:	pop    rbp
    1b72:	ret
    1b73:	mov    rdi,r15
    1b76:	mov    QWORD PTR [rdi],r12
    1b79:	mov    rcx,r13
    1b7c:	mov    QWORD PTR [rcx],rbx
    1b7f:	mov    rax,QWORD PTR [rsp]
    1b83:	mov    QWORD PTR [rcx+0x8],rax
    1b87:	mov    rax,r14
    1b8a:	mov    rbx,QWORD PTR [rsp+0x10]
    1b8f:	mov    r12,QWORD PTR [rsp+0x18]
    1b94:	mov    r13,QWORD PTR [rsp+0x20]
    1b99:	mov    r14,QWORD PTR [rsp+0x28]
    1b9e:	mov    r15,QWORD PTR [rsp+0x30]
    1ba3:	add    rsp,0x40
    1ba7:	mov    rsp,rbp
    1baa:	pop    rbp
    1bab:	ret
    1bac:	mov    rcx,r13
    1baf:	mov    rdi,r15
    1bb2:	mov    rdx,QWORD PTR [rdi+0x10]
    1bb6:	mov    rax,QWORD PTR [rdx+0x10]
    1bba:	mov    QWORD PTR [rdi],r12
    1bbd:	mov    QWORD PTR [rcx],0x1
    1bc4:	mov    QWORD PTR [rcx+0x8],0x1
    1bcc:	mov    rbx,QWORD PTR [rsp+0x10]
    1bd1:	mov    r12,QWORD PTR [rsp+0x18]
    1bd6:	mov    r13,QWORD PTR [rsp+0x20]
    1bdb:	mov    r14,QWORD PTR [rsp+0x28]
    1be0:	mov    r15,QWORD PTR [rsp+0x30]
    1be5:	add    rsp,0x40
    1be9:	mov    rsp,rbp
    1bec:	pop    rbp
    1bed:	ret
    1bee:	mov    r15,rdi
    1bf1:	call   1bf6 <botlish_fn_12+0x1d6>
			1bf2: R_X86_64_PLT32	rt_stack_overflow-0x4
    1bf6:	xor    rax,rax
    1bf9:	mov    rbx,QWORD PTR [rsp+0x10]
    1bfe:	mov    r12,QWORD PTR [rsp+0x18]
    1c03:	mov    r13,QWORD PTR [rsp+0x20]
    1c08:	mov    r14,QWORD PTR [rsp+0x28]
    1c0d:	mov    r15,QWORD PTR [rsp+0x30]
    1c12:	add    rsp,0x40
    1c16:	mov    rsp,rbp
    1c19:	pop    rbp
    1c1a:	ret
    1c1b:	add    BYTE PTR [rax],al
    1c1d:	add    BYTE PTR [rax],al
    1c1f:	add    BYTE PTR [rsi],al
    1c21:	add    BYTE PTR [rax],al
    1c23:	add    BYTE PTR [rax],al
    1c25:	add    BYTE PTR [rax],al
	...

0000000000001c28 <botlish_entry_12: peek<str, int>>:
    1c28:	push   rbp
    1c29:	mov    rbp,rsp
    1c2c:	ud2

0000000000001c2e <botlish_fn_13: scan_unquoted<str, int, int>>:
    1c2e:	push   rbp
    1c2f:	mov    rbp,rsp
    1c32:	sub    rsp,0x60
    1c36:	mov    QWORD PTR [rsp+0x30],rbx
    1c3b:	mov    QWORD PTR [rsp+0x38],r12
    1c40:	mov    QWORD PTR [rsp+0x40],r13
    1c45:	mov    QWORD PTR [rsp+0x48],r14
    1c4a:	mov    QWORD PTR [rsp+0x50],r15
    1c4f:	mov    r14,QWORD PTR [rdi]
    1c52:	mov    rax,QWORD PTR [rdi+0x8]
    1c56:	lea    r8,[r14+0x20]
    1c5a:	cmp    r8,rax
    1c5d:	ja     1e85 <botlish_fn_13+0x257>
    1c63:	lea    rax,[r14+0x20]
    1c67:	mov    QWORD PTR [rdi],rax
    1c6a:	mov    r15,rdi
    1c6d:	mov    QWORD PTR [r14],0x0
    1c74:	mov    QWORD PTR [r14+0x8],0x0
    1c7c:	mov    QWORD PTR [r14+0x10],0x0
    1c84:	mov    QWORD PTR [r14+0x18],0x0
    1c8c:	mov    QWORD PTR [r14],rsi
    1c8f:	mov    QWORD PTR [rsp+0x10],rsi
    1c94:	mov    QWORD PTR [r14+0x8],rdx
    1c98:	mov    QWORD PTR [rsp+0x18],rdx
    1c9d:	mov    QWORD PTR [r14+0x10],rcx
    1ca1:	lea    rbx,[rsp]
    1ca5:	mov    QWORD PTR [rsp+0x20],rcx
    1caa:	mov    rcx,rbx
    1cad:	mov    rdx,QWORD PTR [rsp+0x20]
    1cb2:	mov    rsi,QWORD PTR [rsp+0x10]
    1cb7:	mov    rdi,r15
    1cba:	call   1cbf <botlish_fn_13+0x91>
			1cbb: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1cbf:	mov    rcx,rax
    1cc2:	mov    QWORD PTR [rsp+0x28],rax
    1cc7:	test   rax,rcx
    1cca:	jne    1cd8 <botlish_fn_13+0xaa>
    1cd0:	mov    rdi,r15
    1cd3:	jmp    1e2a <botlish_fn_13+0x1fc>
    1cd8:	mov    r12,QWORD PTR [rsp]
    1cdc:	mov    r13,QWORD PTR [rsp+0x8]
    1ce1:	mov    rdi,r15
    1ce4:	mov    rcx,QWORD PTR [rdi+0x10]
    1ce8:	mov    r8,QWORD PTR [rcx+0x10]
    1cec:	mov    rcx,r13
    1cef:	mov    rdx,r12
    1cf2:	mov    rsi,QWORD PTR [rsp+0x28]
    1cf7:	call   1cfc <botlish_fn_13+0xce>
			1cf8: R_X86_64_PLT32	rt_str_region_eq-0x4
    1cfc:	cmp    rax,0x6
    1d00:	je     1d3f <botlish_fn_13+0x111>
    1d06:	mov    rdi,r15
    1d09:	mov    rax,QWORD PTR [rdi+0x10]
    1d0d:	mov    r8,QWORD PTR [rax+0x18]
    1d11:	mov    rcx,r13
    1d14:	mov    rdx,r12
    1d17:	mov    rsi,QWORD PTR [rsp+0x28]
    1d1c:	call   1d21 <botlish_fn_13+0xf3>
			1d1d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1d21:	cmp    rax,0x6
    1d25:	je     1d35 <botlish_fn_13+0x107>
    1d2b:	mov    eax,0x2
    1d30:	jmp    1d44 <botlish_fn_13+0x116>
    1d35:	mov    eax,0x6
    1d3a:	jmp    1d44 <botlish_fn_13+0x116>
    1d3f:	mov    eax,0x6
    1d44:	cmp    rax,0x6
    1d48:	je     1d87 <botlish_fn_13+0x159>
    1d4e:	mov    rdi,r15
    1d51:	mov    rsi,QWORD PTR [rdi+0x10]
    1d55:	mov    r8,QWORD PTR [rsi+0x20]
    1d59:	mov    rcx,r13
    1d5c:	mov    rdx,r12
    1d5f:	mov    rsi,QWORD PTR [rsp+0x28]
    1d64:	call   1d69 <botlish_fn_13+0x13b>
			1d65: R_X86_64_PLT32	rt_str_region_eq-0x4
    1d69:	cmp    rax,0x6
    1d6d:	je     1d7d <botlish_fn_13+0x14f>
    1d73:	mov    eax,0x2
    1d78:	jmp    1d8c <botlish_fn_13+0x15e>
    1d7d:	mov    eax,0x6
    1d82:	jmp    1d8c <botlish_fn_13+0x15e>
    1d87:	mov    eax,0x6
    1d8c:	cmp    rax,0x6
    1d90:	je     1e07 <botlish_fn_13+0x1d9>
    1d96:	mov    QWORD PTR [r14+0x18],0x3
    1d9e:	mov    rsi,QWORD PTR [rsp+0x20]
    1da3:	test   rsi,0x1
    1daa:	je     1dd1 <botlish_fn_13+0x1a3>
    1db0:	mov    rsi,QWORD PTR [rsp+0x20]
    1db5:	mov    rax,rsi
    1db8:	add    rax,0x2
    1dbc:	seto   cl
    1dbf:	test   cl,cl
    1dc1:	jne    1dd1 <botlish_fn_13+0x1a3>
    1dc7:	mov    rsi,QWORD PTR [rsp+0x10]
    1dcc:	jmp    1de8 <botlish_fn_13+0x1ba>
    1dd1:	mov    edx,0x3
    1dd6:	mov    rsi,QWORD PTR [rsp+0x20]
    1ddb:	mov    rdi,r15
    1dde:	call   1de3 <botlish_fn_13+0x1b5>
			1ddf: R_X86_64_PLT32	rt_int_add-0x4
    1de3:	mov    rsi,QWORD PTR [rsp+0x10]
    1de8:	mov    QWORD PTR [r14],rsi
    1deb:	mov    rdx,QWORD PTR [rsp+0x18]
    1df0:	mov    QWORD PTR [r14+0x8],rdx
    1df4:	mov    QWORD PTR [r14+0x10],rax
    1df8:	mov    QWORD PTR [rsp+0x10],rsi
    1dfd:	mov    QWORD PTR [rsp+0x20],rax
    1e02:	jmp    1caa <botlish_fn_13+0x7c>
    1e07:	mov    rdx,QWORD PTR [rsp+0x18]
    1e0c:	mov    rsi,QWORD PTR [rsp+0x10]
    1e11:	mov    rcx,QWORD PTR [rsp+0x20]
    1e16:	mov    rdi,r15
    1e19:	call   1e1e <botlish_fn_13+0x1f0>
			1e1a: R_X86_64_PLT32	rt_substr-0x4
    1e1e:	test   rax,rax
    1e21:	jne    1e58 <botlish_fn_13+0x22a>
    1e27:	mov    rdi,r15
    1e2a:	mov    rdi,r15
    1e2d:	mov    QWORD PTR [rdi],r14
    1e30:	xor    rdx,rdx
    1e33:	mov    rax,rdx
    1e36:	mov    rbx,QWORD PTR [rsp+0x30]
    1e3b:	mov    r12,QWORD PTR [rsp+0x38]
    1e40:	mov    r13,QWORD PTR [rsp+0x40]
    1e45:	mov    r14,QWORD PTR [rsp+0x48]
    1e4a:	mov    r15,QWORD PTR [rsp+0x50]
    1e4f:	add    rsp,0x60
    1e53:	mov    rsp,rbp
    1e56:	pop    rbp
    1e57:	ret
    1e58:	mov    rdi,r15
    1e5b:	mov    QWORD PTR [rdi],r14
    1e5e:	mov    rdx,QWORD PTR [rsp+0x20]
    1e63:	mov    rbx,QWORD PTR [rsp+0x30]
    1e68:	mov    r12,QWORD PTR [rsp+0x38]
    1e6d:	mov    r13,QWORD PTR [rsp+0x40]
    1e72:	mov    r14,QWORD PTR [rsp+0x48]
    1e77:	mov    r15,QWORD PTR [rsp+0x50]
    1e7c:	add    rsp,0x60
    1e80:	mov    rsp,rbp
    1e83:	pop    rbp
    1e84:	ret
    1e85:	mov    r15,rdi
    1e88:	call   1e8d <botlish_fn_13+0x25f>
			1e89: R_X86_64_PLT32	rt_stack_overflow-0x4
    1e8d:	xor    rdx,rdx
    1e90:	mov    rax,rdx
    1e93:	mov    rbx,QWORD PTR [rsp+0x30]
    1e98:	mov    r12,QWORD PTR [rsp+0x38]
    1e9d:	mov    r13,QWORD PTR [rsp+0x40]
    1ea2:	mov    r14,QWORD PTR [rsp+0x48]
    1ea7:	mov    r15,QWORD PTR [rsp+0x50]
    1eac:	add    rsp,0x60
    1eb0:	mov    rsp,rbp
    1eb3:	pop    rbp
    1eb4:	ret

0000000000001eb5 <botlish_entry_13: scan_unquoted<str, int, int>>:
    1eb5:	push   rbp
    1eb6:	mov    rbp,rsp
    1eb9:	ud2

0000000000001ebb <botlish_fn_14: scan_quoted<str, int, str>>:
    1ebb:	push   rbp
    1ebc:	mov    rbp,rsp
    1ebf:	sub    rsp,0x50
    1ec3:	mov    QWORD PTR [rsp+0x20],rbx
    1ec8:	mov    QWORD PTR [rsp+0x28],r12
    1ecd:	mov    QWORD PTR [rsp+0x30],r13
    1ed2:	mov    QWORD PTR [rsp+0x38],r14
    1ed7:	mov    QWORD PTR [rsp+0x40],r15
    1edc:	mov    r13,QWORD PTR [rdi]
    1edf:	mov    rax,QWORD PTR [rdi+0x8]
    1ee3:	lea    r8,[r13+0x28]
    1ee7:	cmp    r8,rax
    1eea:	ja     21d2 <botlish_fn_14+0x317>
    1ef0:	lea    rax,[r13+0x28]
    1ef4:	mov    QWORD PTR [rdi],rax
    1ef7:	mov    r14,rdi
    1efa:	mov    QWORD PTR [r13+0x0],0x0
    1f02:	mov    QWORD PTR [r13+0x8],0x0
    1f0a:	mov    QWORD PTR [r13+0x10],0x0
    1f12:	mov    QWORD PTR [r13+0x18],0x0
    1f1a:	mov    QWORD PTR [r13+0x20],0x0
    1f22:	mov    QWORD PTR [r13+0x0],rsi
    1f26:	mov    QWORD PTR [r13+0x8],rdx
    1f2a:	mov    QWORD PTR [r13+0x10],rcx
    1f2e:	lea    rbx,[rsp]
    1f32:	mov    r12,rsi
    1f35:	mov    r15,rdx
    1f38:	mov    QWORD PTR [rsp+0x10],rcx
    1f3d:	mov    rdx,r15
    1f40:	mov    rsi,r12
    1f43:	mov    rdi,r14
    1f46:	call   1f4b <botlish_fn_14+0x90>
			1f47: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1f4b:	test   rax,rax
    1f4e:	jne    1f5c <botlish_fn_14+0xa1>
    1f54:	mov    rdi,r14
    1f57:	jmp    218b <botlish_fn_14+0x2d0>
    1f5c:	mov    QWORD PTR [r13+0x18],rax
    1f60:	mov    rdi,r14
    1f63:	mov    QWORD PTR [rsp+0x18],rax
    1f68:	mov    rsi,QWORD PTR [rdi+0x10]
    1f6c:	mov    rsi,QWORD PTR [rsi+0x28]
    1f70:	mov    edx,0x1
    1f75:	mov    ecx,0x3
    1f7a:	mov    r8,QWORD PTR [rsp+0x18]
    1f7f:	call   1f84 <botlish_fn_14+0xc9>
			1f80: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f84:	cmp    rax,0x6
    1f88:	je     2013 <botlish_fn_14+0x158>
    1f8e:	mov    QWORD PTR [r13+0x20],0x3
    1f96:	mov    rsi,r15
    1f99:	test   rsi,0x1
    1fa0:	je     1fc0 <botlish_fn_14+0x105>
    1fa6:	mov    r11,rsi
    1fa9:	add    r11,0x2
    1fad:	seto   al
    1fb0:	test   al,al
    1fb2:	jne    1fc0 <botlish_fn_14+0x105>
    1fb8:	mov    rsi,r11
    1fbb:	jmp    1fd0 <botlish_fn_14+0x115>
    1fc0:	mov    edx,0x3
    1fc5:	mov    rdi,r14
    1fc8:	call   1fcd <botlish_fn_14+0x112>
			1fc9: R_X86_64_PLT32	rt_int_add-0x4
    1fcd:	mov    rsi,rax
    1fd0:	mov    QWORD PTR [r13+0x8],rsi
    1fd4:	mov    r15,rsi
    1fd7:	mov    rsi,QWORD PTR [rsp+0x10]
    1fdc:	mov    rdx,QWORD PTR [rsp+0x18]
    1fe1:	mov    rdi,r14
    1fe4:	call   1fe9 <botlish_fn_14+0x12e>
			1fe5: R_X86_64_PLT32	rt_str_cat-0x4
    1fe9:	test   rax,rax
    1fec:	jne    1ffa <botlish_fn_14+0x13f>
    1ff2:	mov    rdi,r14
    1ff5:	jmp    218b <botlish_fn_14+0x2d0>
    1ffa:	mov    QWORD PTR [r13+0x0],r12
    1ffe:	mov    rsi,r15
    2001:	mov    QWORD PTR [r13+0x8],rsi
    2005:	mov    QWORD PTR [r13+0x10],rax
    2009:	mov    QWORD PTR [rsp+0x10],rax
    200e:	jmp    1f3d <botlish_fn_14+0x82>
    2013:	mov    QWORD PTR [r13+0x18],0x3
    201b:	mov    rsi,r15
    201e:	test   rsi,0x1
    2025:	je     2040 <botlish_fn_14+0x185>
    202b:	mov    rsi,r15
    202e:	mov    rdx,rsi
    2031:	add    rdx,0x2
    2035:	seto   al
    2038:	test   al,al
    203a:	je     2053 <botlish_fn_14+0x198>
    2040:	mov    edx,0x3
    2045:	mov    rsi,r15
    2048:	mov    rdi,r14
    204b:	call   2050 <botlish_fn_14+0x195>
			204c: R_X86_64_PLT32	rt_int_add-0x4
    2050:	mov    rdx,rax
    2053:	mov    QWORD PTR [r13+0x18],rdx
    2057:	mov    rcx,rbx
    205a:	mov    rsi,r12
    205d:	mov    rdi,r14
    2060:	call   2065 <botlish_fn_14+0x1aa>
			2061: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2065:	test   rax,rax
    2068:	mov    rsi,rax
    206b:	jne    2079 <botlish_fn_14+0x1be>
    2071:	mov    rdi,r14
    2074:	jmp    218b <botlish_fn_14+0x2d0>
    2079:	mov    rdx,QWORD PTR [rsp]
    207d:	mov    rcx,QWORD PTR [rsp+0x8]
    2082:	mov    rdi,r14
    2085:	mov    rax,QWORD PTR [rdi+0x10]
    2089:	mov    r8,QWORD PTR [rax+0x28]
    208d:	call   2092 <botlish_fn_14+0x1d7>
			208e: R_X86_64_PLT32	rt_str_region_eq-0x4
    2092:	cmp    rax,0x6
    2096:	je     2114 <botlish_fn_14+0x259>
    209c:	mov    QWORD PTR [r13+0x0],0x3
    20a4:	mov    rsi,r15
    20a7:	test   rsi,0x1
    20ae:	je     20d1 <botlish_fn_14+0x216>
    20b4:	mov    rsi,r15
    20b7:	mov    rdx,rsi
    20ba:	add    rdx,0x2
    20be:	seto   al
    20c1:	test   al,al
    20c3:	jne    20d1 <botlish_fn_14+0x216>
    20c9:	mov    rdi,r14
    20cc:	jmp    20e7 <botlish_fn_14+0x22c>
    20d1:	mov    edx,0x3
    20d6:	mov    rsi,r15
    20d9:	mov    rdi,r14
    20dc:	call   20e1 <botlish_fn_14+0x226>
			20dd: R_X86_64_PLT32	rt_int_add-0x4
    20e1:	mov    rdx,rax
    20e4:	mov    rdi,r14
    20e7:	mov    rdi,r14
    20ea:	mov    QWORD PTR [rdi],r13
    20ed:	mov    rax,QWORD PTR [rsp+0x10]
    20f2:	mov    rbx,QWORD PTR [rsp+0x20]
    20f7:	mov    r12,QWORD PTR [rsp+0x28]
    20fc:	mov    r13,QWORD PTR [rsp+0x30]
    2101:	mov    r14,QWORD PTR [rsp+0x38]
    2106:	mov    r15,QWORD PTR [rsp+0x40]
    210b:	add    rsp,0x50
    210f:	mov    rsp,rbp
    2112:	pop    rbp
    2113:	ret
    2114:	mov    QWORD PTR [r13+0x18],0x5
    211c:	mov    rsi,r15
    211f:	test   rsi,0x1
    2126:	je     214c <botlish_fn_14+0x291>
    212c:	mov    rsi,r15
    212f:	mov    rax,rsi
    2132:	add    rax,0x4
    2136:	seto   cl
    2139:	test   cl,cl
    213b:	jne    214c <botlish_fn_14+0x291>
    2141:	mov    rsi,rax
    2144:	mov    r15,rax
    2147:	jmp    2162 <botlish_fn_14+0x2a7>
    214c:	mov    edx,0x5
    2151:	mov    rsi,r15
    2154:	mov    rdi,r14
    2157:	call   215c <botlish_fn_14+0x2a1>
			2158: R_X86_64_PLT32	rt_int_add-0x4
    215c:	mov    rsi,rax
    215f:	mov    r15,rax
    2162:	mov    QWORD PTR [r13+0x8],rsi
    2166:	mov    rdi,r14
    2169:	mov    rax,QWORD PTR [rdi+0x10]
    216d:	mov    rdx,QWORD PTR [rax+0x28]
    2171:	mov    QWORD PTR [r13+0x18],rdx
    2175:	mov    rsi,QWORD PTR [rsp+0x10]
    217a:	call   217f <botlish_fn_14+0x2c4>
			217b: R_X86_64_PLT32	rt_str_cat-0x4
    217f:	test   rax,rax
    2182:	jne    21b9 <botlish_fn_14+0x2fe>
    2188:	mov    rdi,r14
    218b:	mov    rdi,r14
    218e:	mov    QWORD PTR [rdi],r13
    2191:	xor    rdx,rdx
    2194:	mov    rax,rdx
    2197:	mov    rbx,QWORD PTR [rsp+0x20]
    219c:	mov    r12,QWORD PTR [rsp+0x28]
    21a1:	mov    r13,QWORD PTR [rsp+0x30]
    21a6:	mov    r14,QWORD PTR [rsp+0x38]
    21ab:	mov    r15,QWORD PTR [rsp+0x40]
    21b0:	add    rsp,0x50
    21b4:	mov    rsp,rbp
    21b7:	pop    rbp
    21b8:	ret
    21b9:	mov    QWORD PTR [r13+0x0],r12
    21bd:	mov    rsi,r15
    21c0:	mov    QWORD PTR [r13+0x8],rsi
    21c4:	mov    QWORD PTR [r13+0x10],rax
    21c8:	mov    QWORD PTR [rsp+0x10],rax
    21cd:	jmp    1f3d <botlish_fn_14+0x82>
    21d2:	mov    r14,rdi
    21d5:	call   21da <botlish_fn_14+0x31f>
			21d6: R_X86_64_PLT32	rt_stack_overflow-0x4
    21da:	xor    rdx,rdx
    21dd:	mov    rax,rdx
    21e0:	mov    rbx,QWORD PTR [rsp+0x20]
    21e5:	mov    r12,QWORD PTR [rsp+0x28]
    21ea:	mov    r13,QWORD PTR [rsp+0x30]
    21ef:	mov    r14,QWORD PTR [rsp+0x38]
    21f4:	mov    r15,QWORD PTR [rsp+0x40]
    21f9:	add    rsp,0x50
    21fd:	mov    rsp,rbp
    2200:	pop    rbp
    2201:	ret

0000000000002202 <botlish_entry_14: scan_quoted<str, int, str>>:
    2202:	push   rbp
    2203:	mov    rbp,rsp
    2206:	ud2

0000000000002208 <botlish_fn_15: scan_field<str, int>>:
    2208:	push   rbp
    2209:	mov    rbp,rsp
    220c:	sub    rsp,0x30
    2210:	mov    QWORD PTR [rsp+0x10],rbx
    2215:	mov    QWORD PTR [rsp+0x18],r12
    221a:	mov    QWORD PTR [rsp+0x20],r13
    221f:	mov    QWORD PTR [rsp+0x28],r14
    2224:	mov    rbx,QWORD PTR [rdi]
    2227:	mov    rax,QWORD PTR [rdi+0x8]
    222b:	lea    rcx,[rbx+0x18]
    222f:	cmp    rcx,rax
    2232:	ja     23a4 <botlish_fn_15+0x19c>
    2238:	lea    rax,[rbx+0x18]
    223c:	mov    QWORD PTR [rdi],rax
    223f:	mov    r12,rdi
    2242:	mov    QWORD PTR [rbx],0x0
    2249:	mov    QWORD PTR [rbx+0x8],0x0
    2251:	mov    QWORD PTR [rbx+0x10],0x0
    2259:	mov    QWORD PTR [rbx],rsi
    225c:	mov    r13,rsi
    225f:	mov    QWORD PTR [rbx+0x8],rdx
    2263:	mov    r14,rdx
    2266:	lea    rcx,[rsp]
    226a:	mov    rdx,r14
    226d:	mov    rsi,r13
    2270:	mov    rdi,r12
    2273:	call   2278 <botlish_fn_15+0x70>
			2274: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2278:	test   rax,rax
    227b:	mov    rsi,rax
    227e:	jne    228c <botlish_fn_15+0x84>
    2284:	mov    rdi,r12
    2287:	jmp    2358 <botlish_fn_15+0x150>
    228c:	mov    rdx,QWORD PTR [rsp]
    2290:	mov    rcx,QWORD PTR [rsp+0x8]
    2295:	mov    rdi,r12
    2298:	mov    rax,QWORD PTR [rdi+0x10]
    229c:	mov    r8,QWORD PTR [rax+0x28]
    22a0:	call   22a5 <botlish_fn_15+0x9d>
			22a1: R_X86_64_PLT32	rt_str_region_eq-0x4
    22a5:	cmp    rax,0x6
    22a9:	je     22f4 <botlish_fn_15+0xec>
    22af:	mov    rcx,r14
    22b2:	mov    rsi,r13
    22b5:	mov    rdi,r12
    22b8:	mov    rdx,rcx
    22bb:	call   22c0 <botlish_fn_15+0xb8>
			22bc: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    22c0:	test   rax,rax
    22c3:	jne    22d1 <botlish_fn_15+0xc9>
    22c9:	mov    rdi,r12
    22cc:	jmp    2358 <botlish_fn_15+0x150>
    22d1:	mov    rdi,r12
    22d4:	mov    QWORD PTR [rdi],rbx
    22d7:	mov    rbx,QWORD PTR [rsp+0x10]
    22dc:	mov    r12,QWORD PTR [rsp+0x18]
    22e1:	mov    r13,QWORD PTR [rsp+0x20]
    22e6:	mov    r14,QWORD PTR [rsp+0x28]
    22eb:	add    rsp,0x30
    22ef:	mov    rsp,rbp
    22f2:	pop    rbp
    22f3:	ret
    22f4:	mov    QWORD PTR [rbx+0x10],0x3
    22fc:	mov    rdx,r14
    22ff:	test   rdx,0x1
    2306:	je     231e <botlish_fn_15+0x116>
    230c:	mov    rdx,r14
    230f:	add    rdx,0x2
    2313:	seto   al
    2316:	test   al,al
    2318:	je     2331 <botlish_fn_15+0x129>
    231e:	mov    edx,0x3
    2323:	mov    rsi,r14
    2326:	mov    rdi,r12
    2329:	call   232e <botlish_fn_15+0x126>
			232a: R_X86_64_PLT32	rt_int_add-0x4
    232e:	mov    rdx,rax
    2331:	mov    QWORD PTR [rbx+0x8],rdx
    2335:	mov    rdi,r12
    2338:	mov    rax,QWORD PTR [rdi+0x10]
    233c:	mov    rcx,QWORD PTR [rax+0x10]
    2340:	mov    QWORD PTR [rbx+0x10],rcx
    2344:	mov    rsi,r13
    2347:	call   234c <botlish_fn_15+0x144>
			2348: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    234c:	test   rax,rax
    234f:	jne    2381 <botlish_fn_15+0x179>
    2355:	mov    rdi,r12
    2358:	mov    rdi,r12
    235b:	mov    QWORD PTR [rdi],rbx
    235e:	xor    rdx,rdx
    2361:	mov    rax,rdx
    2364:	mov    rbx,QWORD PTR [rsp+0x10]
    2369:	mov    r12,QWORD PTR [rsp+0x18]
    236e:	mov    r13,QWORD PTR [rsp+0x20]
    2373:	mov    r14,QWORD PTR [rsp+0x28]
    2378:	add    rsp,0x30
    237c:	mov    rsp,rbp
    237f:	pop    rbp
    2380:	ret
    2381:	mov    rdi,r12
    2384:	mov    QWORD PTR [rdi],rbx
    2387:	mov    rbx,QWORD PTR [rsp+0x10]
    238c:	mov    r12,QWORD PTR [rsp+0x18]
    2391:	mov    r13,QWORD PTR [rsp+0x20]
    2396:	mov    r14,QWORD PTR [rsp+0x28]
    239b:	add    rsp,0x30
    239f:	mov    rsp,rbp
    23a2:	pop    rbp
    23a3:	ret
    23a4:	mov    r12,rdi
    23a7:	call   23ac <botlish_fn_15+0x1a4>
			23a8: R_X86_64_PLT32	rt_stack_overflow-0x4
    23ac:	xor    rdx,rdx
    23af:	mov    rax,rdx
    23b2:	mov    rbx,QWORD PTR [rsp+0x10]
    23b7:	mov    r12,QWORD PTR [rsp+0x18]
    23bc:	mov    r13,QWORD PTR [rsp+0x20]
    23c1:	mov    r14,QWORD PTR [rsp+0x28]
    23c6:	add    rsp,0x30
    23ca:	mov    rsp,rbp
    23cd:	pop    rbp
    23ce:	ret

00000000000023cf <botlish_entry_15: scan_field<str, int>>:
    23cf:	push   rbp
    23d0:	mov    rbp,rsp
    23d3:	ud2

00000000000023d5 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    23d5:	push   rbp
    23d6:	mov    rbp,rsp
    23d9:	sub    rsp,0x80
    23e0:	mov    QWORD PTR [rsp+0x50],rbx
    23e5:	mov    QWORD PTR [rsp+0x58],r12
    23ea:	mov    QWORD PTR [rsp+0x60],r13
    23ef:	mov    QWORD PTR [rsp+0x68],r14
    23f4:	mov    QWORD PTR [rsp+0x70],r15
    23f9:	mov    rbx,QWORD PTR [rdi]
    23fc:	mov    rax,QWORD PTR [rdi+0x8]
    2400:	lea    r10,[rbx+0x30]
    2404:	cmp    r10,rax
    2407:	ja     272a <botlish_fn_16+0x355>
    240d:	lea    rax,[rbx+0x30]
    2411:	mov    QWORD PTR [rdi],rax
    2414:	mov    r14,rdi
    2417:	mov    QWORD PTR [rbx],0x0
    241e:	mov    QWORD PTR [rbx+0x8],0x0
    2426:	mov    QWORD PTR [rbx+0x10],0x0
    242e:	mov    QWORD PTR [rbx+0x18],0x0
    2436:	mov    QWORD PTR [rbx+0x20],0x0
    243e:	mov    QWORD PTR [rbx+0x28],0x0
    2446:	mov    QWORD PTR [rbx],rsi
    2449:	mov    QWORD PTR [rsp+0x20],rsi
    244e:	mov    QWORD PTR [rbx+0x8],rdx
    2452:	mov    QWORD PTR [rbx+0x10],rcx
    2456:	mov    QWORD PTR [rsp+0x28],rcx
    245b:	mov    QWORD PTR [rbx+0x18],r8
    245f:	mov    r13,r8
    2462:	mov    QWORD PTR [rbx+0x20],r9
    2466:	mov    r12,r9
    2469:	mov    rsi,QWORD PTR [rsp+0x20]
    246e:	mov    rdi,r14
    2471:	call   2476 <botlish_fn_16+0xa1>
			2472: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    2476:	test   rax,rax
    2479:	jne    2487 <botlish_fn_16+0xb2>
    247f:	mov    rdi,r14
    2482:	jmp    26ce <botlish_fn_16+0x2f9>
    2487:	mov    QWORD PTR [rbx+0x8],rax
    248b:	mov    r8,rax
    248e:	mov    QWORD PTR [rbx+0x28],rdx
    2492:	mov    r15,rdx
    2495:	lea    r9,[rsp]
    2499:	mov    rcx,r12
    249c:	mov    rdx,r13
    249f:	mov    rsi,QWORD PTR [rsp+0x28]
    24a4:	mov    rdi,r14
    24a7:	call   24ac <botlish_fn_16+0xd7>
			24a8: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    24ac:	test   rax,rax
    24af:	jne    24bd <botlish_fn_16+0xe8>
    24b5:	mov    rdi,r14
    24b8:	jmp    26ce <botlish_fn_16+0x2f9>
    24bd:	mov    QWORD PTR [rbx+0x8],rax
    24c1:	mov    QWORD PTR [rsp+0x40],rax
    24c6:	mov    rdx,QWORD PTR [rsp]
    24ca:	mov    QWORD PTR [rbx+0x10],rdx
    24ce:	mov    QWORD PTR [rsp+0x38],rdx
    24d3:	mov    rcx,QWORD PTR [rsp+0x8]
    24d8:	mov    QWORD PTR [rbx+0x18],rcx
    24dc:	mov    QWORD PTR [rsp+0x30],rcx
    24e1:	lea    rcx,[rsp+0x10]
    24e6:	mov    rdx,r15
    24e9:	mov    rsi,QWORD PTR [rsp+0x20]
    24ee:	mov    rdi,r14
    24f1:	call   24f6 <botlish_fn_16+0x121>
			24f2: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    24f6:	test   rax,rax
    24f9:	mov    QWORD PTR [rsp+0x28],rax
    24fe:	jne    250c <botlish_fn_16+0x137>
    2504:	mov    rdi,r14
    2507:	jmp    26ce <botlish_fn_16+0x2f9>
    250c:	mov    r13,QWORD PTR [rsp+0x10]
    2511:	mov    r12,QWORD PTR [rsp+0x18]
    2516:	mov    rdi,r14
    2519:	mov    r10,QWORD PTR [rdi+0x10]
    251d:	mov    r8,QWORD PTR [r10+0x18]
    2521:	mov    rcx,r12
    2524:	mov    rdx,r13
    2527:	mov    rsi,QWORD PTR [rsp+0x28]
    252c:	call   2531 <botlish_fn_16+0x15c>
			252d: R_X86_64_PLT32	rt_str_region_eq-0x4
    2531:	cmp    rax,0x6
    2535:	je     265a <botlish_fn_16+0x285>
    253b:	mov    rdi,r14
    253e:	mov    rax,QWORD PTR [rdi+0x10]
    2542:	mov    r8,QWORD PTR [rax+0x20]
    2546:	mov    rcx,r12
    2549:	mov    rdx,r13
    254c:	mov    rsi,QWORD PTR [rsp+0x28]
    2551:	call   2556 <botlish_fn_16+0x181>
			2552: R_X86_64_PLT32	rt_str_region_eq-0x4
    2556:	cmp    rax,0x6
    255a:	je     25b6 <botlish_fn_16+0x1e1>
    2560:	mov    rcx,QWORD PTR [rsp+0x30]
    2565:	mov    rdx,QWORD PTR [rsp+0x38]
    256a:	mov    rsi,QWORD PTR [rsp+0x40]
    256f:	mov    rdi,r14
    2572:	call   2577 <botlish_fn_16+0x1a2>
			2573: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2577:	test   rax,rax
    257a:	jne    2588 <botlish_fn_16+0x1b3>
    2580:	mov    rdi,r14
    2583:	jmp    26ce <botlish_fn_16+0x2f9>
    2588:	mov    rdi,r14
    258b:	mov    QWORD PTR [rdi],rbx
    258e:	mov    rdx,r15
    2591:	mov    rbx,QWORD PTR [rsp+0x50]
    2596:	mov    r12,QWORD PTR [rsp+0x58]
    259b:	mov    r13,QWORD PTR [rsp+0x60]
    25a0:	mov    r14,QWORD PTR [rsp+0x68]
    25a5:	mov    r15,QWORD PTR [rsp+0x70]
    25aa:	add    rsp,0x80
    25b1:	mov    rsp,rbp
    25b4:	pop    rbp
    25b5:	ret
    25b6:	mov    rcx,QWORD PTR [rsp+0x30]
    25bb:	mov    rdx,QWORD PTR [rsp+0x38]
    25c0:	mov    rsi,QWORD PTR [rsp+0x40]
    25c5:	mov    rdi,r14
    25c8:	call   25cd <botlish_fn_16+0x1f8>
			25c9: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    25cd:	test   rax,rax
    25d0:	jne    25de <botlish_fn_16+0x209>
    25d6:	mov    rdi,r14
    25d9:	jmp    26ce <botlish_fn_16+0x2f9>
    25de:	mov    QWORD PTR [rbx],rax
    25e1:	mov    r12,rax
    25e4:	mov    QWORD PTR [rbx+0x8],0x3
    25ec:	mov    rdx,r15
    25ef:	test   rdx,0x1
    25f6:	je     2616 <botlish_fn_16+0x241>
    25fc:	mov    rdx,r15
    25ff:	add    rdx,0x2
    2603:	seto   al
    2606:	test   al,al
    2608:	jne    2616 <botlish_fn_16+0x241>
    260e:	mov    rdi,r14
    2611:	jmp    262c <botlish_fn_16+0x257>
    2616:	mov    edx,0x3
    261b:	mov    rsi,r15
    261e:	mov    rdi,r14
    2621:	call   2626 <botlish_fn_16+0x251>
			2622: R_X86_64_PLT32	rt_int_add-0x4
    2626:	mov    rdx,rax
    2629:	mov    rdi,r14
    262c:	mov    rdi,r14
    262f:	mov    QWORD PTR [rdi],rbx
    2632:	mov    rax,r12
    2635:	mov    rbx,QWORD PTR [rsp+0x50]
    263a:	mov    r12,QWORD PTR [rsp+0x58]
    263f:	mov    r13,QWORD PTR [rsp+0x60]
    2644:	mov    r14,QWORD PTR [rsp+0x68]
    2649:	mov    r15,QWORD PTR [rsp+0x70]
    264e:	add    rsp,0x80
    2655:	mov    rsp,rbp
    2658:	pop    rbp
    2659:	ret
    265a:	mov    rsi,r15
    265d:	mov    edx,0x3
    2662:	mov    rcx,rdx
    2665:	mov    QWORD PTR [rbx+0x20],0x3
    266d:	test   rsi,0x1
    2674:	jne    2682 <botlish_fn_16+0x2ad>
    267a:	mov    rdx,rcx
    267d:	jmp    2697 <botlish_fn_16+0x2c2>
    2682:	mov    rdx,rsi
    2685:	add    rdx,0x2
    2689:	seto   al
    268c:	test   al,al
    268e:	je     26a2 <botlish_fn_16+0x2cd>
    2694:	mov    rdx,rcx
    2697:	mov    rdi,r14
    269a:	call   269f <botlish_fn_16+0x2ca>
			269b: R_X86_64_PLT32	rt_int_add-0x4
    269f:	mov    rdx,rax
    26a2:	mov    QWORD PTR [rbx+0x20],rdx
    26a6:	mov    rcx,QWORD PTR [rsp+0x40]
    26ab:	mov    rsi,QWORD PTR [rsp+0x20]
    26b0:	mov    r8,QWORD PTR [rsp+0x38]
    26b5:	mov    r9,QWORD PTR [rsp+0x30]
    26ba:	mov    rdi,r14
    26bd:	call   26c2 <botlish_fn_16+0x2ed>
			26be: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    26c2:	test   rax,rax
    26c5:	jne    26ff <botlish_fn_16+0x32a>
    26cb:	mov    rdi,r14
    26ce:	mov    rdi,r14
    26d1:	mov    QWORD PTR [rdi],rbx
    26d4:	xor    rdx,rdx
    26d7:	mov    rax,rdx
    26da:	mov    rbx,QWORD PTR [rsp+0x50]
    26df:	mov    r12,QWORD PTR [rsp+0x58]
    26e4:	mov    r13,QWORD PTR [rsp+0x60]
    26e9:	mov    r14,QWORD PTR [rsp+0x68]
    26ee:	mov    r15,QWORD PTR [rsp+0x70]
    26f3:	add    rsp,0x80
    26fa:	mov    rsp,rbp
    26fd:	pop    rbp
    26fe:	ret
    26ff:	mov    rdi,r14
    2702:	mov    QWORD PTR [rdi],rbx
    2705:	mov    rbx,QWORD PTR [rsp+0x50]
    270a:	mov    r12,QWORD PTR [rsp+0x58]
    270f:	mov    r13,QWORD PTR [rsp+0x60]
    2714:	mov    r14,QWORD PTR [rsp+0x68]
    2719:	mov    r15,QWORD PTR [rsp+0x70]
    271e:	add    rsp,0x80
    2725:	mov    rsp,rbp
    2728:	pop    rbp
    2729:	ret
    272a:	mov    r14,rdi
    272d:	call   2732 <botlish_fn_16+0x35d>
			272e: R_X86_64_PLT32	rt_stack_overflow-0x4
    2732:	xor    rdx,rdx
    2735:	mov    rax,rdx
    2738:	mov    rbx,QWORD PTR [rsp+0x50]
    273d:	mov    r12,QWORD PTR [rsp+0x58]
    2742:	mov    r13,QWORD PTR [rsp+0x60]
    2747:	mov    r14,QWORD PTR [rsp+0x68]
    274c:	mov    r15,QWORD PTR [rsp+0x70]
    2751:	add    rsp,0x80
    2758:	mov    rsp,rbp
    275b:	pop    rbp
    275c:	ret

000000000000275d <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    275d:	push   rbp
    275e:	mov    rbp,rsp
    2761:	ud2

0000000000002763 <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2763:	push   rbp
    2764:	mov    rbp,rsp
    2767:	sub    rsp,0x90
    276e:	mov    QWORD PTR [rsp+0x60],rbx
    2773:	mov    QWORD PTR [rsp+0x68],r12
    2778:	mov    QWORD PTR [rsp+0x70],r13
    277d:	mov    QWORD PTR [rsp+0x78],r14
    2782:	mov    QWORD PTR [rsp+0x80],r15
    278a:	mov    r13,QWORD PTR [rdi]
    278d:	mov    rax,QWORD PTR [rdi+0x8]
    2791:	lea    r10,[r13+0x30]
    2795:	cmp    r10,rax
    2798:	ja     2adc <botlish_fn_17+0x379>
    279e:	lea    rax,[r13+0x30]
    27a2:	mov    QWORD PTR [rdi],rax
    27a5:	mov    QWORD PTR [rsp+0x20],rdi
    27aa:	mov    QWORD PTR [r13+0x0],0x0
    27b2:	mov    QWORD PTR [r13+0x8],0x0
    27ba:	mov    QWORD PTR [r13+0x10],0x0
    27c2:	mov    QWORD PTR [r13+0x18],0x0
    27ca:	mov    QWORD PTR [r13+0x20],0x0
    27d2:	mov    QWORD PTR [r13+0x28],0x0
    27da:	mov    QWORD PTR [r13+0x0],rsi
    27de:	mov    QWORD PTR [r13+0x8],rdx
    27e2:	mov    QWORD PTR [r13+0x10],rcx
    27e6:	mov    QWORD PTR [r13+0x18],r8
    27ea:	mov    QWORD PTR [r13+0x20],r9
    27ee:	lea    r12,[rsp]
    27f2:	mov    QWORD PTR [rsp+0x50],r12
    27f7:	lea    r12,[rsp+0x10]
    27fc:	mov    rbx,rcx
    27ff:	mov    r15,rsi
    2802:	mov    QWORD PTR [rsp+0x28],r8
    2807:	mov    QWORD PTR [rsp+0x30],r9
    280c:	mov    rsi,r15
    280f:	mov    rdi,QWORD PTR [rsp+0x20]
    2814:	call   2819 <botlish_fn_17+0xb6>
			2815: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    2819:	mov    QWORD PTR [rsp+0x48],rdx
    281e:	test   rax,rax
    2821:	jne    2831 <botlish_fn_17+0xce>
    2827:	mov    rdi,QWORD PTR [rsp+0x20]
    282c:	jmp    29a1 <botlish_fn_17+0x23e>
    2831:	mov    QWORD PTR [r13+0x8],rax
    2835:	mov    rdx,QWORD PTR [rsp+0x48]
    283a:	mov    r8,rax
    283d:	mov    QWORD PTR [r13+0x28],rdx
    2841:	mov    rcx,QWORD PTR [rsp+0x30]
    2846:	mov    rdx,QWORD PTR [rsp+0x28]
    284b:	mov    rsi,rbx
    284e:	mov    rdi,QWORD PTR [rsp+0x20]
    2853:	mov    r9,QWORD PTR [rsp+0x50]
    2858:	call   285d <botlish_fn_17+0xfa>
			2859: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    285d:	test   rax,rax
    2860:	jne    2870 <botlish_fn_17+0x10d>
    2866:	mov    rdi,QWORD PTR [rsp+0x20]
    286b:	jmp    29a1 <botlish_fn_17+0x23e>
    2870:	mov    QWORD PTR [r13+0x8],rax
    2874:	mov    QWORD PTR [rsp+0x40],rax
    2879:	mov    rdx,QWORD PTR [rsp]
    287d:	mov    QWORD PTR [rsp+0x28],rdx
    2882:	mov    QWORD PTR [r13+0x10],rdx
    2886:	mov    rcx,QWORD PTR [rsp+0x8]
    288b:	mov    QWORD PTR [r13+0x18],rcx
    288f:	mov    QWORD PTR [rsp+0x30],rcx
    2894:	mov    rcx,r12
    2897:	mov    rdx,QWORD PTR [rsp+0x48]
    289c:	mov    rsi,r15
    289f:	mov    rdi,QWORD PTR [rsp+0x20]
    28a4:	call   28a9 <botlish_fn_17+0x146>
			28a5: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    28a9:	test   rax,rax
    28ac:	mov    QWORD PTR [rsp+0x38],rax
    28b1:	jne    28c1 <botlish_fn_17+0x15e>
    28b7:	mov    rdi,QWORD PTR [rsp+0x20]
    28bc:	jmp    29a1 <botlish_fn_17+0x23e>
    28c1:	mov    rbx,QWORD PTR [rsp+0x10]
    28c6:	mov    r14,QWORD PTR [rsp+0x18]
    28cb:	mov    rdi,QWORD PTR [rsp+0x20]
    28d0:	mov    rcx,QWORD PTR [rdi+0x10]
    28d4:	mov    r8,QWORD PTR [rcx+0x18]
    28d8:	mov    rcx,r14
    28db:	mov    rdx,rbx
    28de:	mov    rsi,QWORD PTR [rsp+0x38]
    28e3:	call   28e8 <botlish_fn_17+0x185>
			28e4: R_X86_64_PLT32	rt_str_region_eq-0x4
    28e8:	cmp    rax,0x6
    28ec:	je     2a65 <botlish_fn_17+0x302>
    28f2:	mov    rdi,QWORD PTR [rsp+0x20]
    28f7:	mov    rax,QWORD PTR [rdi+0x10]
    28fb:	mov    r8,QWORD PTR [rax+0x20]
    28ff:	mov    rcx,r14
    2902:	mov    rdx,rbx
    2905:	mov    rsi,QWORD PTR [rsp+0x38]
    290a:	call   290f <botlish_fn_17+0x1ac>
			290b: R_X86_64_PLT32	rt_str_region_eq-0x4
    290f:	cmp    rax,0x6
    2913:	je     297a <botlish_fn_17+0x217>
    2919:	mov    rcx,QWORD PTR [rsp+0x30]
    291e:	mov    rdx,QWORD PTR [rsp+0x28]
    2923:	mov    rsi,QWORD PTR [rsp+0x40]
    2928:	mov    rdi,QWORD PTR [rsp+0x20]
    292d:	call   2932 <botlish_fn_17+0x1cf>
			292e: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2932:	test   rax,rax
    2935:	jne    2945 <botlish_fn_17+0x1e2>
    293b:	mov    rdi,QWORD PTR [rsp+0x20]
    2940:	jmp    29a1 <botlish_fn_17+0x23e>
    2945:	mov    rdi,QWORD PTR [rsp+0x20]
    294a:	mov    QWORD PTR [rdi],r13
    294d:	mov    rdx,QWORD PTR [rsp+0x48]
    2952:	mov    rbx,QWORD PTR [rsp+0x60]
    2957:	mov    r12,QWORD PTR [rsp+0x68]
    295c:	mov    r13,QWORD PTR [rsp+0x70]
    2961:	mov    r14,QWORD PTR [rsp+0x78]
    2966:	mov    r15,QWORD PTR [rsp+0x80]
    296e:	add    rsp,0x90
    2975:	mov    rsp,rbp
    2978:	pop    rbp
    2979:	ret
    297a:	mov    rcx,QWORD PTR [rsp+0x30]
    297f:	mov    rdx,QWORD PTR [rsp+0x28]
    2984:	mov    rsi,QWORD PTR [rsp+0x40]
    2989:	mov    rdi,QWORD PTR [rsp+0x20]
    298e:	call   2993 <botlish_fn_17+0x230>
			298f: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2993:	test   rax,rax
    2996:	jne    29d7 <botlish_fn_17+0x274>
    299c:	mov    rdi,QWORD PTR [rsp+0x20]
    29a1:	mov    rdi,QWORD PTR [rsp+0x20]
    29a6:	mov    QWORD PTR [rdi],r13
    29a9:	xor    rdx,rdx
    29ac:	mov    rax,rdx
    29af:	mov    rbx,QWORD PTR [rsp+0x60]
    29b4:	mov    r12,QWORD PTR [rsp+0x68]
    29b9:	mov    r13,QWORD PTR [rsp+0x70]
    29be:	mov    r14,QWORD PTR [rsp+0x78]
    29c3:	mov    r15,QWORD PTR [rsp+0x80]
    29cb:	add    rsp,0x90
    29d2:	mov    rsp,rbp
    29d5:	pop    rbp
    29d6:	ret
    29d7:	mov    QWORD PTR [r13+0x0],rax
    29db:	mov    rbx,rax
    29de:	mov    QWORD PTR [r13+0x8],0x3
    29e6:	mov    rdx,QWORD PTR [rsp+0x48]
    29eb:	test   rdx,0x1
    29f2:	je     2a16 <botlish_fn_17+0x2b3>
    29f8:	mov    rdx,QWORD PTR [rsp+0x48]
    29fd:	add    rdx,0x2
    2a01:	seto   al
    2a04:	test   al,al
    2a06:	jne    2a16 <botlish_fn_17+0x2b3>
    2a0c:	mov    rdi,QWORD PTR [rsp+0x20]
    2a11:	jmp    2a32 <botlish_fn_17+0x2cf>
    2a16:	mov    edx,0x3
    2a1b:	mov    rsi,QWORD PTR [rsp+0x48]
    2a20:	mov    rdi,QWORD PTR [rsp+0x20]
    2a25:	call   2a2a <botlish_fn_17+0x2c7>
			2a26: R_X86_64_PLT32	rt_int_add-0x4
    2a2a:	mov    rdx,rax
    2a2d:	mov    rdi,QWORD PTR [rsp+0x20]
    2a32:	mov    rdi,QWORD PTR [rsp+0x20]
    2a37:	mov    QWORD PTR [rdi],r13
    2a3a:	mov    rax,rbx
    2a3d:	mov    rbx,QWORD PTR [rsp+0x60]
    2a42:	mov    r12,QWORD PTR [rsp+0x68]
    2a47:	mov    r13,QWORD PTR [rsp+0x70]
    2a4c:	mov    r14,QWORD PTR [rsp+0x78]
    2a51:	mov    r15,QWORD PTR [rsp+0x80]
    2a59:	add    rsp,0x90
    2a60:	mov    rsp,rbp
    2a63:	pop    rbp
    2a64:	ret
    2a65:	mov    rsi,QWORD PTR [rsp+0x48]
    2a6a:	mov    edx,0x3
    2a6f:	mov    rcx,rdx
    2a72:	mov    QWORD PTR [r13+0x20],0x3
    2a7a:	test   rsi,0x1
    2a81:	jne    2a8f <botlish_fn_17+0x32c>
    2a87:	mov    rdx,rcx
    2a8a:	jmp    2aa4 <botlish_fn_17+0x341>
    2a8f:	mov    rdx,rsi
    2a92:	add    rdx,0x2
    2a96:	seto   al
    2a99:	test   al,al
    2a9b:	je     2ab1 <botlish_fn_17+0x34e>
    2aa1:	mov    rdx,rcx
    2aa4:	mov    rdi,QWORD PTR [rsp+0x20]
    2aa9:	call   2aae <botlish_fn_17+0x34b>
			2aaa: R_X86_64_PLT32	rt_int_add-0x4
    2aae:	mov    rdx,rax
    2ab1:	mov    QWORD PTR [r13+0x0],r15
    2ab5:	mov    QWORD PTR [r13+0x8],rdx
    2ab9:	mov    rsi,QWORD PTR [rsp+0x40]
    2abe:	mov    QWORD PTR [r13+0x10],rsi
    2ac2:	mov    rax,QWORD PTR [rsp+0x28]
    2ac7:	mov    QWORD PTR [r13+0x18],rax
    2acb:	mov    rcx,QWORD PTR [rsp+0x30]
    2ad0:	mov    QWORD PTR [r13+0x20],rcx
    2ad4:	mov    rbx,rsi
    2ad7:	jmp    280c <botlish_fn_17+0xa9>
    2adc:	mov    QWORD PTR [rsp+0x20],rdi
    2ae1:	call   2ae6 <botlish_fn_17+0x383>
			2ae2: R_X86_64_PLT32	rt_stack_overflow-0x4
    2ae6:	xor    rdx,rdx
    2ae9:	mov    rax,rdx
    2aec:	mov    rbx,QWORD PTR [rsp+0x60]
    2af1:	mov    r12,QWORD PTR [rsp+0x68]
    2af6:	mov    r13,QWORD PTR [rsp+0x70]
    2afb:	mov    r14,QWORD PTR [rsp+0x78]
    2b00:	mov    r15,QWORD PTR [rsp+0x80]
    2b08:	add    rsp,0x90
    2b0f:	mov    rsp,rbp
    2b12:	pop    rbp
    2b13:	ret

0000000000002b14 <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2b14:	push   rbp
    2b15:	mov    rbp,rsp
    2b18:	ud2

0000000000002b1a <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2b1a:	push   rbp
    2b1b:	mov    rbp,rsp
    2b1e:	sub    rsp,0x60
    2b22:	mov    QWORD PTR [rsp+0x30],rbx
    2b27:	mov    QWORD PTR [rsp+0x38],r12
    2b2c:	mov    QWORD PTR [rsp+0x40],r13
    2b31:	mov    QWORD PTR [rsp+0x48],r14
    2b36:	mov    QWORD PTR [rsp+0x50],r15
    2b3b:	mov    rbx,QWORD PTR [rdi]
    2b3e:	mov    rax,QWORD PTR [rdi+0x8]
    2b42:	lea    r10,[rbx+0x40]
    2b46:	cmp    r10,rax
    2b49:	ja     2d43 <botlish_fn_18+0x229>
    2b4f:	lea    rax,[rbx+0x40]
    2b53:	mov    QWORD PTR [rdi],rax
    2b56:	mov    r12,rdi
    2b59:	mov    QWORD PTR [rbx],0x0
    2b60:	mov    QWORD PTR [rbx+0x8],0x0
    2b68:	mov    QWORD PTR [rbx+0x10],0x0
    2b70:	mov    QWORD PTR [rbx+0x18],0x0
    2b78:	mov    QWORD PTR [rbx+0x20],0x0
    2b80:	mov    QWORD PTR [rbx+0x28],0x0
    2b88:	mov    QWORD PTR [rbx+0x30],0x0
    2b90:	mov    QWORD PTR [rbx+0x38],0x0
    2b98:	mov    QWORD PTR [rbx],rsi
    2b9b:	mov    r13,rsi
    2b9e:	mov    QWORD PTR [rbx+0x8],rdx
    2ba2:	mov    QWORD PTR [rsp+0x20],rdx
    2ba7:	mov    QWORD PTR [rbx+0x10],rcx
    2bab:	mov    QWORD PTR [rsp+0x28],rcx
    2bb0:	mov    QWORD PTR [rbx+0x18],r8
    2bb4:	mov    r15,r8
    2bb7:	mov    QWORD PTR [rbx+0x20],r9
    2bbb:	mov    r14,r9
    2bbe:	mov    rsi,r13
    2bc1:	mov    rdi,r12
    2bc4:	call   2bc9 <botlish_fn_18+0xaf>
			2bc5: R_X86_64_PLT32	rt_str_len-0x4
    2bc9:	mov    rdx,QWORD PTR [rsp+0x20]
    2bce:	mov    rcx,rdx
    2bd1:	sar    rcx,1
    2bd4:	sar    rax,1
    2bd7:	cmp    rcx,rax
    2bda:	jge    2cd1 <botlish_fn_18+0x1b7>
    2be0:	lea    rsi,[rsp]
    2be4:	mov    rdi,r12
    2be7:	call   2bec <botlish_fn_18+0xd2>
			2be8: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2bec:	test   rax,rax
    2bef:	jne    2bfd <botlish_fn_18+0xe3>
    2bf5:	mov    rdi,r12
    2bf8:	jmp    2cf0 <botlish_fn_18+0x1d6>
    2bfd:	mov    QWORD PTR [rbx+0x28],rax
    2c01:	mov    rcx,rax
    2c04:	mov    r8,QWORD PTR [rsp]
    2c08:	mov    QWORD PTR [rbx+0x30],r8
    2c0c:	mov    r9,QWORD PTR [rsp+0x8]
    2c11:	mov    QWORD PTR [rbx+0x38],r9
    2c15:	mov    rdx,QWORD PTR [rsp+0x20]
    2c1a:	mov    rsi,r13
    2c1d:	mov    rdi,r12
    2c20:	call   2c25 <botlish_fn_18+0x10b>
			2c21: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2c25:	test   rax,rax
    2c28:	jne    2c36 <botlish_fn_18+0x11c>
    2c2e:	mov    rdi,r12
    2c31:	jmp    2cf0 <botlish_fn_18+0x1d6>
    2c36:	mov    QWORD PTR [rbx+0x8],rax
    2c3a:	mov    r8,rax
    2c3d:	mov    QWORD PTR [rbx+0x28],rdx
    2c41:	mov    QWORD PTR [rsp+0x20],rdx
    2c46:	lea    r9,[rsp+0x10]
    2c4b:	mov    rcx,r14
    2c4e:	mov    rdx,r15
    2c51:	mov    rsi,QWORD PTR [rsp+0x28]
    2c56:	mov    rdi,r12
    2c59:	call   2c5e <botlish_fn_18+0x144>
			2c5a: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    2c5e:	test   rax,rax
    2c61:	jne    2c6f <botlish_fn_18+0x155>
    2c67:	mov    rdi,r12
    2c6a:	jmp    2cf0 <botlish_fn_18+0x1d6>
    2c6f:	mov    QWORD PTR [rbx+0x8],rax
    2c73:	mov    rcx,rax
    2c76:	mov    r8,QWORD PTR [rsp+0x10]
    2c7b:	mov    QWORD PTR [rbx+0x10],r8
    2c7f:	mov    r9,QWORD PTR [rsp+0x18]
    2c84:	mov    QWORD PTR [rbx+0x18],r9
    2c88:	mov    rdx,QWORD PTR [rsp+0x20]
    2c8d:	mov    rsi,r13
    2c90:	mov    rdi,r12
    2c93:	call   2c98 <botlish_fn_18+0x17e>
			2c94: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2c98:	test   rax,rax
    2c9b:	jne    2ca9 <botlish_fn_18+0x18f>
    2ca1:	mov    rdi,r12
    2ca4:	jmp    2cf0 <botlish_fn_18+0x1d6>
    2ca9:	mov    rdi,r12
    2cac:	mov    QWORD PTR [rdi],rbx
    2caf:	mov    rbx,QWORD PTR [rsp+0x30]
    2cb4:	mov    r12,QWORD PTR [rsp+0x38]
    2cb9:	mov    r13,QWORD PTR [rsp+0x40]
    2cbe:	mov    r14,QWORD PTR [rsp+0x48]
    2cc3:	mov    r15,QWORD PTR [rsp+0x50]
    2cc8:	add    rsp,0x60
    2ccc:	mov    rsp,rbp
    2ccf:	pop    rbp
    2cd0:	ret
    2cd1:	mov    rcx,r14
    2cd4:	mov    rdx,r15
    2cd7:	mov    rsi,QWORD PTR [rsp+0x28]
    2cdc:	mov    rdi,r12
    2cdf:	call   2ce4 <botlish_fn_18+0x1ca>
			2ce0: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    2ce4:	test   rax,rax
    2ce7:	jne    2d1b <botlish_fn_18+0x201>
    2ced:	mov    rdi,r12
    2cf0:	mov    rdi,r12
    2cf3:	mov    QWORD PTR [rdi],rbx
    2cf6:	xor    rax,rax
    2cf9:	mov    rbx,QWORD PTR [rsp+0x30]
    2cfe:	mov    r12,QWORD PTR [rsp+0x38]
    2d03:	mov    r13,QWORD PTR [rsp+0x40]
    2d08:	mov    r14,QWORD PTR [rsp+0x48]
    2d0d:	mov    r15,QWORD PTR [rsp+0x50]
    2d12:	add    rsp,0x60
    2d16:	mov    rsp,rbp
    2d19:	pop    rbp
    2d1a:	ret
    2d1b:	mov    rdi,r12
    2d1e:	mov    QWORD PTR [rdi],rbx
    2d21:	mov    rbx,QWORD PTR [rsp+0x30]
    2d26:	mov    r12,QWORD PTR [rsp+0x38]
    2d2b:	mov    r13,QWORD PTR [rsp+0x40]
    2d30:	mov    r14,QWORD PTR [rsp+0x48]
    2d35:	mov    r15,QWORD PTR [rsp+0x50]
    2d3a:	add    rsp,0x60
    2d3e:	mov    rsp,rbp
    2d41:	pop    rbp
    2d42:	ret
    2d43:	mov    r12,rdi
    2d46:	call   2d4b <botlish_fn_18+0x231>
			2d47: R_X86_64_PLT32	rt_stack_overflow-0x4
    2d4b:	xor    rax,rax
    2d4e:	mov    rbx,QWORD PTR [rsp+0x30]
    2d53:	mov    r12,QWORD PTR [rsp+0x38]
    2d58:	mov    r13,QWORD PTR [rsp+0x40]
    2d5d:	mov    r14,QWORD PTR [rsp+0x48]
    2d62:	mov    r15,QWORD PTR [rsp+0x50]
    2d67:	add    rsp,0x60
    2d6b:	mov    rsp,rbp
    2d6e:	pop    rbp
    2d6f:	ret

0000000000002d70 <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2d70:	push   rbp
    2d71:	mov    rbp,rsp
    2d74:	mov    rsi,QWORD PTR [rdx]
    2d77:	mov    r10,QWORD PTR [rdx+0x8]
    2d7b:	mov    rcx,QWORD PTR [rdx+0x10]
    2d7f:	mov    r8,QWORD PTR [rdx+0x18]
    2d83:	mov    r9,QWORD PTR [rdx+0x20]
    2d87:	mov    rdx,r10
    2d8a:	call   2d8f <botlish_entry_18+0x1f>
			2d8b: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2d8f:	mov    rsp,rbp
    2d92:	pop    rbp
    2d93:	ret
    2d94:	add    BYTE PTR [rax],al
	...

0000000000002d98 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2d98:	push   rbp
    2d99:	mov    rbp,rsp
    2d9c:	sub    rsp,0x70
    2da0:	mov    QWORD PTR [rsp+0x40],rbx
    2da5:	mov    QWORD PTR [rsp+0x48],r12
    2daa:	mov    QWORD PTR [rsp+0x50],r13
    2daf:	mov    QWORD PTR [rsp+0x58],r14
    2db4:	mov    QWORD PTR [rsp+0x60],r15
    2db9:	mov    r14,QWORD PTR [rdi]
    2dbc:	mov    rax,QWORD PTR [rdi+0x8]
    2dc0:	lea    r10,[r14+0x40]
    2dc4:	cmp    r10,rax
    2dc7:	ja     2ff5 <botlish_fn_19+0x25d>
    2dcd:	lea    rax,[r14+0x40]
    2dd1:	mov    QWORD PTR [rdi],rax
    2dd4:	mov    QWORD PTR [rsp+0x20],rdi
    2dd9:	mov    QWORD PTR [r14],0x0
    2de0:	mov    QWORD PTR [r14+0x8],0x0
    2de8:	mov    QWORD PTR [r14+0x10],0x0
    2df0:	mov    QWORD PTR [r14+0x18],0x0
    2df8:	mov    QWORD PTR [r14+0x20],0x0
    2e00:	mov    QWORD PTR [r14+0x28],0x0
    2e08:	mov    QWORD PTR [r14+0x30],0x0
    2e10:	mov    QWORD PTR [r14+0x38],0x0
    2e18:	mov    QWORD PTR [r14],rsi
    2e1b:	mov    QWORD PTR [r14+0x8],rdx
    2e1f:	mov    r15,rdx
    2e22:	mov    QWORD PTR [r14+0x10],rcx
    2e26:	mov    QWORD PTR [r14+0x18],r8
    2e2a:	mov    QWORD PTR [r14+0x20],r9
    2e2e:	lea    rbx,[rsp]
    2e32:	lea    r12,[rsp+0x10]
    2e37:	mov    r13,rsi
    2e3a:	mov    QWORD PTR [rsp+0x28],rcx
    2e3f:	mov    QWORD PTR [rsp+0x30],r8
    2e44:	mov    QWORD PTR [rsp+0x38],r9
    2e49:	mov    rsi,r13
    2e4c:	mov    rdi,QWORD PTR [rsp+0x20]
    2e51:	call   2e56 <botlish_fn_19+0xbe>
			2e52: R_X86_64_PLT32	rt_str_len-0x4
    2e56:	mov    rcx,r15
    2e59:	and    rcx,rax
    2e5c:	mov    rdx,rax
    2e5f:	test   rcx,0x1
    2e66:	jne    2e8e <botlish_fn_19+0xf6>
    2e6c:	mov    rsi,r15
    2e6f:	mov    rdi,QWORD PTR [rsp+0x20]
    2e74:	call   2e79 <botlish_fn_19+0xe1>
			2e75: R_X86_64_PLT32	rt_int_cmp-0x4
    2e79:	mov    ecx,0x2
    2e7e:	test   rax,rax
    2e81:	cmovge rcx,QWORD PTR [rip+0x19f]        # 3028 <botlish_fn_19+0x290>
    2e89:	jmp    2ea1 <botlish_fn_19+0x109>
    2e8e:	mov    ecx,0x2
    2e93:	mov    rax,r15
    2e96:	cmp    rax,rdx
    2e99:	cmovge rcx,QWORD PTR [rip+0x187]        # 3028 <botlish_fn_19+0x290>
    2ea1:	cmp    rcx,0x6
    2ea5:	je     2f77 <botlish_fn_19+0x1df>
    2eab:	mov    rsi,rbx
    2eae:	mov    rdi,QWORD PTR [rsp+0x20]
    2eb3:	call   2eb8 <botlish_fn_19+0x120>
			2eb4: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2eb8:	test   rax,rax
    2ebb:	jne    2ecb <botlish_fn_19+0x133>
    2ec1:	mov    rdi,QWORD PTR [rsp+0x20]
    2ec6:	jmp    2f9e <botlish_fn_19+0x206>
    2ecb:	mov    QWORD PTR [r14+0x28],rax
    2ecf:	mov    rcx,rax
    2ed2:	mov    r8,QWORD PTR [rsp]
    2ed6:	mov    QWORD PTR [r14+0x30],r8
    2eda:	mov    r9,QWORD PTR [rsp+0x8]
    2edf:	mov    QWORD PTR [r14+0x38],r9
    2ee3:	mov    rdx,r15
    2ee6:	mov    rsi,r13
    2ee9:	mov    rdi,QWORD PTR [rsp+0x20]
    2eee:	call   2ef3 <botlish_fn_19+0x15b>
			2eef: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2ef3:	test   rax,rax
    2ef6:	jne    2f06 <botlish_fn_19+0x16e>
    2efc:	mov    rdi,QWORD PTR [rsp+0x20]
    2f01:	jmp    2f9e <botlish_fn_19+0x206>
    2f06:	mov    QWORD PTR [r14+0x8],rax
    2f0a:	mov    r8,rax
    2f0d:	mov    QWORD PTR [r14+0x28],rdx
    2f11:	mov    r15,rdx
    2f14:	mov    rsi,QWORD PTR [rsp+0x28]
    2f19:	mov    rdx,QWORD PTR [rsp+0x30]
    2f1e:	mov    rcx,QWORD PTR [rsp+0x38]
    2f23:	mov    rdi,QWORD PTR [rsp+0x20]
    2f28:	mov    r9,r12
    2f2b:	call   2f30 <botlish_fn_19+0x198>
			2f2c: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    2f30:	test   rax,rax
    2f33:	jne    2f43 <botlish_fn_19+0x1ab>
    2f39:	mov    rdi,QWORD PTR [rsp+0x20]
    2f3e:	jmp    2f9e <botlish_fn_19+0x206>
    2f43:	mov    rdx,QWORD PTR [rsp+0x10]
    2f48:	mov    rcx,QWORD PTR [rsp+0x18]
    2f4d:	mov    QWORD PTR [r14],r13
    2f50:	mov    rsi,r15
    2f53:	mov    QWORD PTR [r14+0x8],rsi
    2f57:	mov    QWORD PTR [r14+0x10],rax
    2f5b:	mov    QWORD PTR [r14+0x18],rdx
    2f5f:	mov    QWORD PTR [r14+0x20],rcx
    2f63:	mov    QWORD PTR [rsp+0x28],rax
    2f68:	mov    QWORD PTR [rsp+0x30],rdx
    2f6d:	mov    QWORD PTR [rsp+0x38],rcx
    2f72:	jmp    2e49 <botlish_fn_19+0xb1>
    2f77:	mov    rcx,QWORD PTR [rsp+0x38]
    2f7c:	mov    rdx,QWORD PTR [rsp+0x30]
    2f81:	mov    rsi,QWORD PTR [rsp+0x28]
    2f86:	mov    rdi,QWORD PTR [rsp+0x20]
    2f8b:	call   2f90 <botlish_fn_19+0x1f8>
			2f8c: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2f90:	test   rax,rax
    2f93:	jne    2fcb <botlish_fn_19+0x233>
    2f99:	mov    rdi,QWORD PTR [rsp+0x20]
    2f9e:	mov    rdi,QWORD PTR [rsp+0x20]
    2fa3:	mov    QWORD PTR [rdi],r14
    2fa6:	xor    rax,rax
    2fa9:	mov    rbx,QWORD PTR [rsp+0x40]
    2fae:	mov    r12,QWORD PTR [rsp+0x48]
    2fb3:	mov    r13,QWORD PTR [rsp+0x50]
    2fb8:	mov    r14,QWORD PTR [rsp+0x58]
    2fbd:	mov    r15,QWORD PTR [rsp+0x60]
    2fc2:	add    rsp,0x70
    2fc6:	mov    rsp,rbp
    2fc9:	pop    rbp
    2fca:	ret
    2fcb:	mov    rdi,QWORD PTR [rsp+0x20]
    2fd0:	mov    QWORD PTR [rdi],r14
    2fd3:	mov    rbx,QWORD PTR [rsp+0x40]
    2fd8:	mov    r12,QWORD PTR [rsp+0x48]
    2fdd:	mov    r13,QWORD PTR [rsp+0x50]
    2fe2:	mov    r14,QWORD PTR [rsp+0x58]
    2fe7:	mov    r15,QWORD PTR [rsp+0x60]
    2fec:	add    rsp,0x70
    2ff0:	mov    rsp,rbp
    2ff3:	pop    rbp
    2ff4:	ret
    2ff5:	mov    QWORD PTR [rsp+0x20],rdi
    2ffa:	call   2fff <botlish_fn_19+0x267>
			2ffb: R_X86_64_PLT32	rt_stack_overflow-0x4
    2fff:	xor    rax,rax
    3002:	mov    rbx,QWORD PTR [rsp+0x40]
    3007:	mov    r12,QWORD PTR [rsp+0x48]
    300c:	mov    r13,QWORD PTR [rsp+0x50]
    3011:	mov    r14,QWORD PTR [rsp+0x58]
    3016:	mov    r15,QWORD PTR [rsp+0x60]
    301b:	add    rsp,0x70
    301f:	mov    rsp,rbp
    3022:	pop    rbp
    3023:	ret
    3024:	add    BYTE PTR [rax],al
    3026:	add    BYTE PTR [rax],al
    3028:	(bad)
    3029:	add    BYTE PTR [rax],al
    302b:	add    BYTE PTR [rax],al
    302d:	add    BYTE PTR [rax],al
	...

0000000000003030 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    3030:	push   rbp
    3031:	mov    rbp,rsp
    3034:	mov    rsi,QWORD PTR [rdx]
    3037:	mov    r10,QWORD PTR [rdx+0x8]
    303b:	mov    rcx,QWORD PTR [rdx+0x10]
    303f:	mov    r8,QWORD PTR [rdx+0x18]
    3043:	mov    r9,QWORD PTR [rdx+0x20]
    3047:	mov    rdx,r10
    304a:	call   304f <botlish_entry_19+0x1f>
			304b: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    304f:	mov    rsp,rbp
    3052:	pop    rbp
    3053:	ret

0000000000003054 <botlish_fn_20: csv_parse<str>>:
    3054:	push   rbp
    3055:	mov    rbp,rsp
    3058:	sub    rsp,0x30
    305c:	mov    QWORD PTR [rsp+0x10],rbx
    3061:	mov    QWORD PTR [rsp+0x18],r12
    3066:	mov    QWORD PTR [rsp+0x20],r13
    306b:	mov    rbx,QWORD PTR [rdi]
    306e:	mov    rax,QWORD PTR [rdi+0x8]
    3072:	lea    rcx,[rbx+0x28]
    3076:	cmp    rcx,rax
    3079:	ja     314e <botlish_fn_20+0xfa>
    307f:	lea    rax,[rbx+0x28]
    3083:	mov    QWORD PTR [rdi],rax
    3086:	mov    r12,rdi
    3089:	mov    QWORD PTR [rbx],0x0
    3090:	mov    QWORD PTR [rbx+0x8],0x0
    3098:	mov    QWORD PTR [rbx+0x10],0x0
    30a0:	mov    QWORD PTR [rbx+0x18],0x0
    30a8:	mov    QWORD PTR [rbx+0x20],0x0
    30b0:	mov    QWORD PTR [rbx],rsi
    30b3:	mov    r13,rsi
    30b6:	mov    QWORD PTR [rbx+0x8],0x1
    30be:	lea    rsi,[rsp]
    30c2:	mov    rdi,r12
    30c5:	call   30ca <botlish_fn_20+0x76>
			30c6: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    30ca:	test   rax,rax
    30cd:	jne    30db <botlish_fn_20+0x87>
    30d3:	mov    rdi,r12
    30d6:	jmp    310f <botlish_fn_20+0xbb>
    30db:	mov    QWORD PTR [rbx+0x10],rax
    30df:	mov    rcx,rax
    30e2:	mov    r8,QWORD PTR [rsp]
    30e6:	mov    QWORD PTR [rbx+0x18],r8
    30ea:	mov    r9,QWORD PTR [rsp+0x8]
    30ef:	mov    QWORD PTR [rbx+0x20],r9
    30f3:	mov    edx,0x1
    30f8:	mov    rsi,r13
    30fb:	mov    rdi,r12
    30fe:	call   3103 <botlish_fn_20+0xaf>
			30ff: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    3103:	test   rax,rax
    3106:	jne    3130 <botlish_fn_20+0xdc>
    310c:	mov    rdi,r12
    310f:	mov    rdi,r12
    3112:	mov    QWORD PTR [rdi],rbx
    3115:	xor    rax,rax
    3118:	mov    rbx,QWORD PTR [rsp+0x10]
    311d:	mov    r12,QWORD PTR [rsp+0x18]
    3122:	mov    r13,QWORD PTR [rsp+0x20]
    3127:	add    rsp,0x30
    312b:	mov    rsp,rbp
    312e:	pop    rbp
    312f:	ret
    3130:	mov    rdi,r12
    3133:	mov    QWORD PTR [rdi],rbx
    3136:	mov    rbx,QWORD PTR [rsp+0x10]
    313b:	mov    r12,QWORD PTR [rsp+0x18]
    3140:	mov    r13,QWORD PTR [rsp+0x20]
    3145:	add    rsp,0x30
    3149:	mov    rsp,rbp
    314c:	pop    rbp
    314d:	ret
    314e:	mov    r12,rdi
    3151:	call   3156 <botlish_fn_20+0x102>
			3152: R_X86_64_PLT32	rt_stack_overflow-0x4
    3156:	xor    rax,rax
    3159:	mov    rbx,QWORD PTR [rsp+0x10]
    315e:	mov    r12,QWORD PTR [rsp+0x18]
    3163:	mov    r13,QWORD PTR [rsp+0x20]
    3168:	add    rsp,0x30
    316c:	mov    rsp,rbp
    316f:	pop    rbp
    3170:	ret

0000000000003171 <botlish_entry_20: csv_parse<str>>:
    3171:	push   rbp
    3172:	mov    rbp,rsp
    3175:	mov    rsi,QWORD PTR [rdx]
    3178:	call   317d <botlish_entry_20+0xc>
			3179: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    317d:	mov    rsp,rbp
    3180:	pop    rbp
    3181:	ret

; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10347  (per function: 68 28 203 566 566 566 566 632 544 564 564 365 430 585 770 352 799 833 537 612 197)
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
       8:	mov    r8,QWORD PTR [rdi+0x10]
       c:	mov    rsi,QWORD PTR [r8]
       f:	mov    QWORD PTR [rsp],rsi
      13:	call   18 <botlish_fn_0+0x18>
			14: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
      18:	test   rax,rax
      1b:	jne    2d <botlish_fn_0+0x2d>
      21:	xor    rax,rax
      24:	add    rsp,0x10
      28:	mov    rsp,rbp
      2b:	pop    rbp
      2c:	ret
      2d:	add    rsp,0x10
      31:	mov    rsp,rbp
      34:	pop    rbp
      35:	ret

0000000000000036 <botlish_entry_0: <program entry>>:
      36:	push   rbp
      37:	mov    rbp,rsp
      3a:	call   3f <botlish_entry_0+0x9>
			3b: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      3f:	mov    rsp,rbp
      42:	pop    rbp
      43:	ret

0000000000000044 <botlish_fn_1: chunk_size<generic>>:
      44:	push   rbp
      45:	mov    rbp,rsp
      48:	mov    eax,0x81
      4d:	mov    rsp,rbp
      50:	pop    rbp
      51:	ret

0000000000000052 <botlish_entry_1: chunk_size<generic>>:
      52:	push   rbp
      53:	mov    rbp,rsp
      56:	call   5b <botlish_entry_1+0x9>
			57: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      5b:	mov    rsp,rbp
      5e:	pop    rbp
      5f:	ret

0000000000000060 <botlish_fn_2: chunked_new<generic>>:
      60:	push   rbp
      61:	mov    rbp,rsp
      64:	sub    rsp,0x30
      68:	mov    QWORD PTR [rsp+0x10],rbx
      6d:	mov    QWORD PTR [rsp+0x18],r12
      72:	mov    QWORD PTR [rsp+0x20],r13
      77:	mov    r12,rsi
      7a:	mov    r13,rdi
      7d:	mov    QWORD PTR [rsp],0x0
      85:	mov    QWORD PTR [rsp+0x8],0x0
      8e:	xor    rdx,rdx
      91:	mov    rdi,r13
      94:	mov    rsi,rdx
      97:	call   9c <botlish_fn_2+0x3c>
			98: R_X86_64_PLT32	rt_list_new-0x4
      9c:	test   rax,rax
      9f:	je     d3 <botlish_fn_2+0x73>
      a5:	mov    QWORD PTR [rsp],rax
      a9:	mov    rbx,rax
      ac:	mov    rdi,r13
      af:	call   b4 <botlish_fn_2+0x54>
			b0: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      b4:	mov    esi,0x81
      b9:	mov    QWORD PTR [rsp+0x8],0x81
      c2:	mov    rdi,r13
      c5:	call   ca <botlish_fn_2+0x6a>
			c6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      ca:	test   rax,rax
      cd:	jne    ee <botlish_fn_2+0x8e>
      d3:	xor    rax,rax
      d6:	mov    rbx,QWORD PTR [rsp+0x10]
      db:	mov    r12,QWORD PTR [rsp+0x18]
      e0:	mov    r13,QWORD PTR [rsp+0x20]
      e5:	add    rsp,0x30
      e9:	mov    rsp,rbp
      ec:	pop    rbp
      ed:	ret
      ee:	mov    rsi,r12
      f1:	mov    QWORD PTR [rsi],rax
      f4:	mov    QWORD PTR [rsi+0x8],0x1
      fc:	mov    rax,rbx
      ff:	mov    rbx,QWORD PTR [rsp+0x10]
     104:	mov    r12,QWORD PTR [rsp+0x18]
     109:	mov    r13,QWORD PTR [rsp+0x20]
     10e:	add    rsp,0x30
     112:	mov    rsp,rbp
     115:	pop    rbp
     116:	ret

0000000000000117 <botlish_entry_2: chunked_new<generic>>:
     117:	push   rbp
     118:	mov    rbp,rsp
     11b:	ud2
     11d:	add    BYTE PTR [rax],al
	...

0000000000000120 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     120:	push   rbp
     121:	mov    rbp,rsp
     124:	sub    rsp,0x60
     128:	mov    QWORD PTR [rsp+0x30],rbx
     12d:	mov    QWORD PTR [rsp+0x38],r12
     132:	mov    QWORD PTR [rsp+0x40],r13
     137:	mov    QWORD PTR [rsp+0x48],r14
     13c:	mov    QWORD PTR [rsp+0x50],r15
     141:	mov    rbx,rcx
     144:	mov    r12,r9
     147:	mov    r13,rdi
     14a:	mov    QWORD PTR [rsp+0x18],0x0
     153:	mov    QWORD PTR [rsp],rsi
     157:	mov    r14,rsi
     15a:	mov    QWORD PTR [rsp+0x8],rdx
     15f:	mov    r15,rdx
     162:	mov    QWORD PTR [rsp+0x10],r8
     167:	mov    QWORD PTR [rsp+0x20],r8
     16c:	mov    rdi,r13
     16f:	call   174 <botlish_fn_3+0x54>
			170: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     174:	test   rbx,0x1
     17b:	jne    1a6 <botlish_fn_3+0x86>
     181:	mov    edx,0x81
     186:	mov    rsi,rbx
     189:	mov    rdi,r13
     18c:	call   191 <botlish_fn_3+0x71>
			18d: R_X86_64_PLT32	rt_int_cmp-0x4
     191:	mov    ecx,0x2
     196:	test   rax,rax
     199:	cmove  rcx,QWORD PTR [rip+0x177]        # 318 <botlish_fn_3+0x1f8>
     1a1:	jmp    1ba <botlish_fn_3+0x9a>
     1a6:	mov    ecx,0x2
     1ab:	cmp    rbx,0x81
     1b2:	cmove  rcx,QWORD PTR [rip+0x15e]        # 318 <botlish_fn_3+0x1f8>
     1ba:	cmp    rcx,0x6
     1be:	je     251 <botlish_fn_3+0x131>
     1c4:	mov    rcx,QWORD PTR [rsp+0x20]
     1c9:	mov    rdx,rbx
     1cc:	mov    rsi,r15
     1cf:	mov    rdi,r13
     1d2:	call   1d7 <botlish_fn_3+0xb7>
			1d3: R_X86_64_PLT32	rt_mutarray_set-0x4
     1d7:	test   rax,rax
     1da:	je     2b7 <botlish_fn_3+0x197>
     1e0:	mov    QWORD PTR [rsp+0x18],0x3
     1e9:	test   rbx,0x1
     1f0:	je     210 <botlish_fn_3+0xf0>
     1f6:	mov    rax,rbx
     1f9:	add    rax,0x2
     1fd:	seto   cl
     200:	test   cl,cl
     202:	jne    210 <botlish_fn_3+0xf0>
     208:	mov    rdx,r15
     20b:	jmp    223 <botlish_fn_3+0x103>
     210:	mov    edx,0x3
     215:	mov    rsi,rbx
     218:	mov    rdi,r13
     21b:	call   220 <botlish_fn_3+0x100>
			21c: R_X86_64_PLT32	rt_int_add-0x4
     220:	mov    rdx,r15
     223:	mov    QWORD PTR [r12],rdx
     227:	mov    QWORD PTR [r12+0x8],rax
     22c:	mov    rax,r14
     22f:	mov    rbx,QWORD PTR [rsp+0x30]
     234:	mov    r12,QWORD PTR [rsp+0x38]
     239:	mov    r13,QWORD PTR [rsp+0x40]
     23e:	mov    r14,QWORD PTR [rsp+0x48]
     243:	mov    r15,QWORD PTR [rsp+0x50]
     248:	add    rsp,0x60
     24c:	mov    rsp,rbp
     24f:	pop    rbp
     250:	ret
     251:	mov    rdx,r15
     254:	mov    rsi,r14
     257:	mov    rdi,r13
     25a:	call   25f <botlish_fn_3+0x13f>
			25b: R_X86_64_PLT32	rt_list_append-0x4
     25f:	test   rax,rax
     262:	je     2b7 <botlish_fn_3+0x197>
     268:	mov    QWORD PTR [rsp],rax
     26c:	mov    rbx,rax
     26f:	mov    rdi,r13
     272:	call   277 <botlish_fn_3+0x157>
			273: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     277:	mov    esi,0x81
     27c:	mov    QWORD PTR [rsp+0x8],0x81
     285:	mov    rdi,r13
     288:	call   28d <botlish_fn_3+0x16d>
			289: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     28d:	test   rax,rax
     290:	mov    r14,rax
     293:	je     2b7 <botlish_fn_3+0x197>
     299:	mov    edx,0x1
     29e:	mov    rcx,QWORD PTR [rsp+0x20]
     2a3:	mov    rdi,r13
     2a6:	mov    rsi,r14
     2a9:	call   2ae <botlish_fn_3+0x18e>
			2aa: R_X86_64_PLT32	rt_mutarray_set-0x4
     2ae:	test   rax,rax
     2b1:	jne    2dc <botlish_fn_3+0x1bc>
     2b7:	xor    rax,rax
     2ba:	mov    rbx,QWORD PTR [rsp+0x30]
     2bf:	mov    r12,QWORD PTR [rsp+0x38]
     2c4:	mov    r13,QWORD PTR [rsp+0x40]
     2c9:	mov    r14,QWORD PTR [rsp+0x48]
     2ce:	mov    r15,QWORD PTR [rsp+0x50]
     2d3:	add    rsp,0x60
     2d7:	mov    rsp,rbp
     2da:	pop    rbp
     2db:	ret
     2dc:	mov    rax,r14
     2df:	mov    QWORD PTR [r12],rax
     2e3:	mov    QWORD PTR [r12+0x8],0x3
     2ec:	mov    rax,rbx
     2ef:	mov    rbx,QWORD PTR [rsp+0x30]
     2f4:	mov    r12,QWORD PTR [rsp+0x38]
     2f9:	mov    r13,QWORD PTR [rsp+0x40]
     2fe:	mov    r14,QWORD PTR [rsp+0x48]
     303:	mov    r15,QWORD PTR [rsp+0x50]
     308:	add    rsp,0x60
     30c:	mov    rsp,rbp
     30f:	pop    rbp
     310:	ret
     311:	add    BYTE PTR [rax],al
     313:	add    BYTE PTR [rax],al
     315:	add    BYTE PTR [rax],al
     317:	add    BYTE PTR [rsi],al
     319:	add    BYTE PTR [rax],al
     31b:	add    BYTE PTR [rax],al
     31d:	add    BYTE PTR [rax],al
	...

0000000000000320 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     320:	push   rbp
     321:	mov    rbp,rsp
     324:	ud2
	...

0000000000000328 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     328:	push   rbp
     329:	mov    rbp,rsp
     32c:	sub    rsp,0x60
     330:	mov    QWORD PTR [rsp+0x30],rbx
     335:	mov    QWORD PTR [rsp+0x38],r12
     33a:	mov    QWORD PTR [rsp+0x40],r13
     33f:	mov    QWORD PTR [rsp+0x48],r14
     344:	mov    QWORD PTR [rsp+0x50],r15
     349:	mov    rbx,rcx
     34c:	mov    r12,r9
     34f:	mov    r13,rdi
     352:	mov    QWORD PTR [rsp+0x18],0x0
     35b:	mov    QWORD PTR [rsp],rsi
     35f:	mov    r14,rsi
     362:	mov    QWORD PTR [rsp+0x8],rdx
     367:	mov    r15,rdx
     36a:	mov    QWORD PTR [rsp+0x10],r8
     36f:	mov    QWORD PTR [rsp+0x20],r8
     374:	mov    rdi,r13
     377:	call   37c <botlish_fn_4+0x54>
			378: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     37c:	test   rbx,0x1
     383:	jne    3ae <botlish_fn_4+0x86>
     389:	mov    edx,0x81
     38e:	mov    rsi,rbx
     391:	mov    rdi,r13
     394:	call   399 <botlish_fn_4+0x71>
			395: R_X86_64_PLT32	rt_int_cmp-0x4
     399:	mov    ecx,0x2
     39e:	test   rax,rax
     3a1:	cmove  rcx,QWORD PTR [rip+0x177]        # 520 <botlish_fn_4+0x1f8>
     3a9:	jmp    3c2 <botlish_fn_4+0x9a>
     3ae:	mov    ecx,0x2
     3b3:	cmp    rbx,0x81
     3ba:	cmove  rcx,QWORD PTR [rip+0x15e]        # 520 <botlish_fn_4+0x1f8>
     3c2:	cmp    rcx,0x6
     3c6:	je     459 <botlish_fn_4+0x131>
     3cc:	mov    rcx,QWORD PTR [rsp+0x20]
     3d1:	mov    rdx,rbx
     3d4:	mov    rsi,r15
     3d7:	mov    rdi,r13
     3da:	call   3df <botlish_fn_4+0xb7>
			3db: R_X86_64_PLT32	rt_mutarray_set-0x4
     3df:	test   rax,rax
     3e2:	je     4bf <botlish_fn_4+0x197>
     3e8:	mov    QWORD PTR [rsp+0x18],0x3
     3f1:	test   rbx,0x1
     3f8:	je     418 <botlish_fn_4+0xf0>
     3fe:	mov    rax,rbx
     401:	add    rax,0x2
     405:	seto   cl
     408:	test   cl,cl
     40a:	jne    418 <botlish_fn_4+0xf0>
     410:	mov    rdx,r15
     413:	jmp    42b <botlish_fn_4+0x103>
     418:	mov    edx,0x3
     41d:	mov    rsi,rbx
     420:	mov    rdi,r13
     423:	call   428 <botlish_fn_4+0x100>
			424: R_X86_64_PLT32	rt_int_add-0x4
     428:	mov    rdx,r15
     42b:	mov    QWORD PTR [r12],rdx
     42f:	mov    QWORD PTR [r12+0x8],rax
     434:	mov    rax,r14
     437:	mov    rbx,QWORD PTR [rsp+0x30]
     43c:	mov    r12,QWORD PTR [rsp+0x38]
     441:	mov    r13,QWORD PTR [rsp+0x40]
     446:	mov    r14,QWORD PTR [rsp+0x48]
     44b:	mov    r15,QWORD PTR [rsp+0x50]
     450:	add    rsp,0x60
     454:	mov    rsp,rbp
     457:	pop    rbp
     458:	ret
     459:	mov    rdx,r15
     45c:	mov    rsi,r14
     45f:	mov    rdi,r13
     462:	call   467 <botlish_fn_4+0x13f>
			463: R_X86_64_PLT32	rt_list_append-0x4
     467:	test   rax,rax
     46a:	je     4bf <botlish_fn_4+0x197>
     470:	mov    QWORD PTR [rsp],rax
     474:	mov    rbx,rax
     477:	mov    rdi,r13
     47a:	call   47f <botlish_fn_4+0x157>
			47b: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     47f:	mov    esi,0x81
     484:	mov    QWORD PTR [rsp+0x8],0x81
     48d:	mov    rdi,r13
     490:	call   495 <botlish_fn_4+0x16d>
			491: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     495:	test   rax,rax
     498:	mov    r14,rax
     49b:	je     4bf <botlish_fn_4+0x197>
     4a1:	mov    edx,0x1
     4a6:	mov    rcx,QWORD PTR [rsp+0x20]
     4ab:	mov    rdi,r13
     4ae:	mov    rsi,r14
     4b1:	call   4b6 <botlish_fn_4+0x18e>
			4b2: R_X86_64_PLT32	rt_mutarray_set-0x4
     4b6:	test   rax,rax
     4b9:	jne    4e4 <botlish_fn_4+0x1bc>
     4bf:	xor    rax,rax
     4c2:	mov    rbx,QWORD PTR [rsp+0x30]
     4c7:	mov    r12,QWORD PTR [rsp+0x38]
     4cc:	mov    r13,QWORD PTR [rsp+0x40]
     4d1:	mov    r14,QWORD PTR [rsp+0x48]
     4d6:	mov    r15,QWORD PTR [rsp+0x50]
     4db:	add    rsp,0x60
     4df:	mov    rsp,rbp
     4e2:	pop    rbp
     4e3:	ret
     4e4:	mov    rax,r14
     4e7:	mov    QWORD PTR [r12],rax
     4eb:	mov    QWORD PTR [r12+0x8],0x3
     4f4:	mov    rax,rbx
     4f7:	mov    rbx,QWORD PTR [rsp+0x30]
     4fc:	mov    r12,QWORD PTR [rsp+0x38]
     501:	mov    r13,QWORD PTR [rsp+0x40]
     506:	mov    r14,QWORD PTR [rsp+0x48]
     50b:	mov    r15,QWORD PTR [rsp+0x50]
     510:	add    rsp,0x60
     514:	mov    rsp,rbp
     517:	pop    rbp
     518:	ret
     519:	add    BYTE PTR [rax],al
     51b:	add    BYTE PTR [rax],al
     51d:	add    BYTE PTR [rax],al
     51f:	add    BYTE PTR [rsi],al
     521:	add    BYTE PTR [rax],al
     523:	add    BYTE PTR [rax],al
     525:	add    BYTE PTR [rax],al
	...

0000000000000528 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     528:	push   rbp
     529:	mov    rbp,rsp
     52c:	ud2
	...

0000000000000530 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     530:	push   rbp
     531:	mov    rbp,rsp
     534:	sub    rsp,0x60
     538:	mov    QWORD PTR [rsp+0x30],rbx
     53d:	mov    QWORD PTR [rsp+0x38],r12
     542:	mov    QWORD PTR [rsp+0x40],r13
     547:	mov    QWORD PTR [rsp+0x48],r14
     54c:	mov    QWORD PTR [rsp+0x50],r15
     551:	mov    rbx,rcx
     554:	mov    r12,r9
     557:	mov    r13,rdi
     55a:	mov    QWORD PTR [rsp+0x18],0x0
     563:	mov    QWORD PTR [rsp],rsi
     567:	mov    r14,rsi
     56a:	mov    QWORD PTR [rsp+0x8],rdx
     56f:	mov    r15,rdx
     572:	mov    QWORD PTR [rsp+0x10],r8
     577:	mov    QWORD PTR [rsp+0x20],r8
     57c:	mov    rdi,r13
     57f:	call   584 <botlish_fn_5+0x54>
			580: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     584:	test   rbx,0x1
     58b:	jne    5b6 <botlish_fn_5+0x86>
     591:	mov    edx,0x81
     596:	mov    rsi,rbx
     599:	mov    rdi,r13
     59c:	call   5a1 <botlish_fn_5+0x71>
			59d: R_X86_64_PLT32	rt_int_cmp-0x4
     5a1:	mov    ecx,0x2
     5a6:	test   rax,rax
     5a9:	cmove  rcx,QWORD PTR [rip+0x177]        # 728 <botlish_fn_5+0x1f8>
     5b1:	jmp    5ca <botlish_fn_5+0x9a>
     5b6:	mov    ecx,0x2
     5bb:	cmp    rbx,0x81
     5c2:	cmove  rcx,QWORD PTR [rip+0x15e]        # 728 <botlish_fn_5+0x1f8>
     5ca:	cmp    rcx,0x6
     5ce:	je     661 <botlish_fn_5+0x131>
     5d4:	mov    rcx,QWORD PTR [rsp+0x20]
     5d9:	mov    rdx,rbx
     5dc:	mov    rsi,r15
     5df:	mov    rdi,r13
     5e2:	call   5e7 <botlish_fn_5+0xb7>
			5e3: R_X86_64_PLT32	rt_mutarray_set-0x4
     5e7:	test   rax,rax
     5ea:	je     6c7 <botlish_fn_5+0x197>
     5f0:	mov    QWORD PTR [rsp+0x18],0x3
     5f9:	test   rbx,0x1
     600:	je     620 <botlish_fn_5+0xf0>
     606:	mov    rax,rbx
     609:	add    rax,0x2
     60d:	seto   cl
     610:	test   cl,cl
     612:	jne    620 <botlish_fn_5+0xf0>
     618:	mov    rdx,r15
     61b:	jmp    633 <botlish_fn_5+0x103>
     620:	mov    edx,0x3
     625:	mov    rsi,rbx
     628:	mov    rdi,r13
     62b:	call   630 <botlish_fn_5+0x100>
			62c: R_X86_64_PLT32	rt_int_add-0x4
     630:	mov    rdx,r15
     633:	mov    QWORD PTR [r12],rdx
     637:	mov    QWORD PTR [r12+0x8],rax
     63c:	mov    rax,r14
     63f:	mov    rbx,QWORD PTR [rsp+0x30]
     644:	mov    r12,QWORD PTR [rsp+0x38]
     649:	mov    r13,QWORD PTR [rsp+0x40]
     64e:	mov    r14,QWORD PTR [rsp+0x48]
     653:	mov    r15,QWORD PTR [rsp+0x50]
     658:	add    rsp,0x60
     65c:	mov    rsp,rbp
     65f:	pop    rbp
     660:	ret
     661:	mov    rdx,r15
     664:	mov    rsi,r14
     667:	mov    rdi,r13
     66a:	call   66f <botlish_fn_5+0x13f>
			66b: R_X86_64_PLT32	rt_list_append-0x4
     66f:	test   rax,rax
     672:	je     6c7 <botlish_fn_5+0x197>
     678:	mov    QWORD PTR [rsp],rax
     67c:	mov    rbx,rax
     67f:	mov    rdi,r13
     682:	call   687 <botlish_fn_5+0x157>
			683: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     687:	mov    esi,0x81
     68c:	mov    QWORD PTR [rsp+0x8],0x81
     695:	mov    rdi,r13
     698:	call   69d <botlish_fn_5+0x16d>
			699: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     69d:	test   rax,rax
     6a0:	mov    r14,rax
     6a3:	je     6c7 <botlish_fn_5+0x197>
     6a9:	mov    edx,0x1
     6ae:	mov    rcx,QWORD PTR [rsp+0x20]
     6b3:	mov    rdi,r13
     6b6:	mov    rsi,r14
     6b9:	call   6be <botlish_fn_5+0x18e>
			6ba: R_X86_64_PLT32	rt_mutarray_set-0x4
     6be:	test   rax,rax
     6c1:	jne    6ec <botlish_fn_5+0x1bc>
     6c7:	xor    rax,rax
     6ca:	mov    rbx,QWORD PTR [rsp+0x30]
     6cf:	mov    r12,QWORD PTR [rsp+0x38]
     6d4:	mov    r13,QWORD PTR [rsp+0x40]
     6d9:	mov    r14,QWORD PTR [rsp+0x48]
     6de:	mov    r15,QWORD PTR [rsp+0x50]
     6e3:	add    rsp,0x60
     6e7:	mov    rsp,rbp
     6ea:	pop    rbp
     6eb:	ret
     6ec:	mov    rax,r14
     6ef:	mov    QWORD PTR [r12],rax
     6f3:	mov    QWORD PTR [r12+0x8],0x3
     6fc:	mov    rax,rbx
     6ff:	mov    rbx,QWORD PTR [rsp+0x30]
     704:	mov    r12,QWORD PTR [rsp+0x38]
     709:	mov    r13,QWORD PTR [rsp+0x40]
     70e:	mov    r14,QWORD PTR [rsp+0x48]
     713:	mov    r15,QWORD PTR [rsp+0x50]
     718:	add    rsp,0x60
     71c:	mov    rsp,rbp
     71f:	pop    rbp
     720:	ret
     721:	add    BYTE PTR [rax],al
     723:	add    BYTE PTR [rax],al
     725:	add    BYTE PTR [rax],al
     727:	add    BYTE PTR [rsi],al
     729:	add    BYTE PTR [rax],al
     72b:	add    BYTE PTR [rax],al
     72d:	add    BYTE PTR [rax],al
	...

0000000000000730 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     730:	push   rbp
     731:	mov    rbp,rsp
     734:	ud2
	...

0000000000000738 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     738:	push   rbp
     739:	mov    rbp,rsp
     73c:	sub    rsp,0x60
     740:	mov    QWORD PTR [rsp+0x30],rbx
     745:	mov    QWORD PTR [rsp+0x38],r12
     74a:	mov    QWORD PTR [rsp+0x40],r13
     74f:	mov    QWORD PTR [rsp+0x48],r14
     754:	mov    QWORD PTR [rsp+0x50],r15
     759:	mov    rbx,rcx
     75c:	mov    r12,r9
     75f:	mov    r13,rdi
     762:	mov    QWORD PTR [rsp+0x18],0x0
     76b:	mov    QWORD PTR [rsp],rsi
     76f:	mov    r14,rsi
     772:	mov    QWORD PTR [rsp+0x8],rdx
     777:	mov    r15,rdx
     77a:	mov    QWORD PTR [rsp+0x10],r8
     77f:	mov    QWORD PTR [rsp+0x20],r8
     784:	mov    rdi,r13
     787:	call   78c <botlish_fn_6+0x54>
			788: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     78c:	test   rbx,0x1
     793:	jne    7be <botlish_fn_6+0x86>
     799:	mov    edx,0x81
     79e:	mov    rsi,rbx
     7a1:	mov    rdi,r13
     7a4:	call   7a9 <botlish_fn_6+0x71>
			7a5: R_X86_64_PLT32	rt_int_cmp-0x4
     7a9:	mov    ecx,0x2
     7ae:	test   rax,rax
     7b1:	cmove  rcx,QWORD PTR [rip+0x177]        # 930 <botlish_fn_6+0x1f8>
     7b9:	jmp    7d2 <botlish_fn_6+0x9a>
     7be:	mov    ecx,0x2
     7c3:	cmp    rbx,0x81
     7ca:	cmove  rcx,QWORD PTR [rip+0x15e]        # 930 <botlish_fn_6+0x1f8>
     7d2:	cmp    rcx,0x6
     7d6:	je     869 <botlish_fn_6+0x131>
     7dc:	mov    rcx,QWORD PTR [rsp+0x20]
     7e1:	mov    rdx,rbx
     7e4:	mov    rsi,r15
     7e7:	mov    rdi,r13
     7ea:	call   7ef <botlish_fn_6+0xb7>
			7eb: R_X86_64_PLT32	rt_mutarray_set-0x4
     7ef:	test   rax,rax
     7f2:	je     8cf <botlish_fn_6+0x197>
     7f8:	mov    QWORD PTR [rsp+0x18],0x3
     801:	test   rbx,0x1
     808:	je     828 <botlish_fn_6+0xf0>
     80e:	mov    rax,rbx
     811:	add    rax,0x2
     815:	seto   cl
     818:	test   cl,cl
     81a:	jne    828 <botlish_fn_6+0xf0>
     820:	mov    rdx,r15
     823:	jmp    83b <botlish_fn_6+0x103>
     828:	mov    edx,0x3
     82d:	mov    rsi,rbx
     830:	mov    rdi,r13
     833:	call   838 <botlish_fn_6+0x100>
			834: R_X86_64_PLT32	rt_int_add-0x4
     838:	mov    rdx,r15
     83b:	mov    QWORD PTR [r12],rdx
     83f:	mov    QWORD PTR [r12+0x8],rax
     844:	mov    rax,r14
     847:	mov    rbx,QWORD PTR [rsp+0x30]
     84c:	mov    r12,QWORD PTR [rsp+0x38]
     851:	mov    r13,QWORD PTR [rsp+0x40]
     856:	mov    r14,QWORD PTR [rsp+0x48]
     85b:	mov    r15,QWORD PTR [rsp+0x50]
     860:	add    rsp,0x60
     864:	mov    rsp,rbp
     867:	pop    rbp
     868:	ret
     869:	mov    rdx,r15
     86c:	mov    rsi,r14
     86f:	mov    rdi,r13
     872:	call   877 <botlish_fn_6+0x13f>
			873: R_X86_64_PLT32	rt_list_append-0x4
     877:	test   rax,rax
     87a:	je     8cf <botlish_fn_6+0x197>
     880:	mov    QWORD PTR [rsp],rax
     884:	mov    rbx,rax
     887:	mov    rdi,r13
     88a:	call   88f <botlish_fn_6+0x157>
			88b: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     88f:	mov    esi,0x81
     894:	mov    QWORD PTR [rsp+0x8],0x81
     89d:	mov    rdi,r13
     8a0:	call   8a5 <botlish_fn_6+0x16d>
			8a1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     8a5:	test   rax,rax
     8a8:	mov    r14,rax
     8ab:	je     8cf <botlish_fn_6+0x197>
     8b1:	mov    edx,0x1
     8b6:	mov    rcx,QWORD PTR [rsp+0x20]
     8bb:	mov    rdi,r13
     8be:	mov    rsi,r14
     8c1:	call   8c6 <botlish_fn_6+0x18e>
			8c2: R_X86_64_PLT32	rt_mutarray_set-0x4
     8c6:	test   rax,rax
     8c9:	jne    8f4 <botlish_fn_6+0x1bc>
     8cf:	xor    rax,rax
     8d2:	mov    rbx,QWORD PTR [rsp+0x30]
     8d7:	mov    r12,QWORD PTR [rsp+0x38]
     8dc:	mov    r13,QWORD PTR [rsp+0x40]
     8e1:	mov    r14,QWORD PTR [rsp+0x48]
     8e6:	mov    r15,QWORD PTR [rsp+0x50]
     8eb:	add    rsp,0x60
     8ef:	mov    rsp,rbp
     8f2:	pop    rbp
     8f3:	ret
     8f4:	mov    rax,r14
     8f7:	mov    QWORD PTR [r12],rax
     8fb:	mov    QWORD PTR [r12+0x8],0x3
     904:	mov    rax,rbx
     907:	mov    rbx,QWORD PTR [rsp+0x30]
     90c:	mov    r12,QWORD PTR [rsp+0x38]
     911:	mov    r13,QWORD PTR [rsp+0x40]
     916:	mov    r14,QWORD PTR [rsp+0x48]
     91b:	mov    r15,QWORD PTR [rsp+0x50]
     920:	add    rsp,0x60
     924:	mov    rsp,rbp
     927:	pop    rbp
     928:	ret
     929:	add    BYTE PTR [rax],al
     92b:	add    BYTE PTR [rax],al
     92d:	add    BYTE PTR [rax],al
     92f:	add    BYTE PTR [rsi],al
     931:	add    BYTE PTR [rax],al
     933:	add    BYTE PTR [rax],al
     935:	add    BYTE PTR [rax],al
	...

0000000000000938 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     938:	push   rbp
     939:	mov    rbp,rsp
     93c:	ud2
	...

0000000000000940 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     940:	push   rbp
     941:	mov    rbp,rsp
     944:	sub    rsp,0x60
     948:	mov    QWORD PTR [rsp+0x30],rbx
     94d:	mov    QWORD PTR [rsp+0x38],r12
     952:	mov    QWORD PTR [rsp+0x40],r13
     957:	mov    QWORD PTR [rsp+0x48],r14
     95c:	mov    QWORD PTR [rsp+0x50],r15
     961:	mov    rbx,rdx
     964:	mov    r14,rdi
     967:	mov    QWORD PTR [rsp],rsi
     96b:	mov    QWORD PTR [rsp+0x8],rcx
     970:	mov    r15,rcx
     973:	mov    QWORD PTR [rsp+0x10],r8
     978:	mov    r13,rsi
     97b:	mov    QWORD PTR [rsp+0x28],r8
     980:	mov    rsi,r13
     983:	mov    rdi,r14
     986:	call   98b <botlish_fn_7+0x4b>
			987: R_X86_64_PLT32	rt_list_len-0x4
     98b:	mov    rcx,rbx
     98e:	and    rcx,rax
     991:	mov    rdx,rax
     994:	test   rcx,0x1
     99b:	jne    9c1 <botlish_fn_7+0x81>
     9a1:	mov    rsi,rbx
     9a4:	mov    rdi,r14
     9a7:	call   9ac <botlish_fn_7+0x6c>
			9a8: R_X86_64_PLT32	rt_int_cmp-0x4
     9ac:	mov    ecx,0x2
     9b1:	test   rax,rax
     9b4:	cmovge rcx,QWORD PTR [rip+0x1ac]        # b68 <botlish_fn_7+0x228>
     9bc:	jmp    9d1 <botlish_fn_7+0x91>
     9c1:	mov    ecx,0x2
     9c6:	cmp    rbx,rdx
     9c9:	cmovge rcx,QWORD PTR [rip+0x197]        # b68 <botlish_fn_7+0x228>
     9d1:	cmp    rcx,0x6
     9d5:	je     b3c <botlish_fn_7+0x1fc>
     9db:	test   rbx,0x1
     9e2:	je     9fb <botlish_fn_7+0xbb>
     9e8:	mov    rcx,QWORD PTR [r13+0x8]
     9ec:	mov    rax,rbx
     9ef:	sar    rax,1
     9f2:	cmp    rax,rcx
     9f5:	jb     a1a <botlish_fn_7+0xda>
     9fb:	mov    rdx,rbx
     9fe:	mov    rsi,r13
     a01:	mov    rdi,r14
     a04:	call   a09 <botlish_fn_7+0xc9>
			a05: R_X86_64_PLT32	rt_list_get-0x4
     a09:	test   rax,rax
     a0c:	je     a98 <botlish_fn_7+0x158>
     a12:	mov    r12,rax
     a15:	jmp    a25 <botlish_fn_7+0xe5>
     a1a:	mov    rsi,QWORD PTR [r13+0x10]
     a1e:	mov    rsi,QWORD PTR [rsi+rax*8]
     a22:	mov    r12,rsi
     a25:	mov    rdi,r14
     a28:	call   a2d <botlish_fn_7+0xed>
			a29: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     a2d:	xor    eax,eax
     a2f:	test   r12,0x7
     a36:	jne    a48 <botlish_fn_7+0x108>
     a3c:	movzx  r10,BYTE PTR [r12]
     a41:	cmp    r10b,0x8
     a45:	sete   al
     a48:	test   al,al
     a4a:	jne    a6d <botlish_fn_7+0x12d>
     a50:	mov    rdi,r14
     a53:	mov    rax,QWORD PTR [rdi+0x10]
     a57:	mov    rcx,QWORD PTR [rax+0x8]
     a5b:	mov    edx,0x8
     a60:	mov    rsi,r12
     a63:	call   a68 <botlish_fn_7+0x128>
			a64: R_X86_64_PLT32	rt_type_error-0x4
     a68:	jmp    a98 <botlish_fn_7+0x158>
     a6d:	mov    rcx,r12
     a70:	mov    r8d,0x1
     a76:	mov    r9d,0x81
     a7c:	mov    r12,r15
     a7f:	mov    rdx,QWORD PTR [rsp+0x28]
     a84:	mov    rsi,r12
     a87:	mov    rdi,r14
     a8a:	call   a8f <botlish_fn_7+0x14f>
			a8b: R_X86_64_PLT32	rt_mutarray_copy-0x4
     a8f:	test   rax,rax
     a92:	jne    abd <botlish_fn_7+0x17d>
     a98:	xor    rax,rax
     a9b:	mov    rbx,QWORD PTR [rsp+0x30]
     aa0:	mov    r12,QWORD PTR [rsp+0x38]
     aa5:	mov    r13,QWORD PTR [rsp+0x40]
     aaa:	mov    r14,QWORD PTR [rsp+0x48]
     aaf:	mov    r15,QWORD PTR [rsp+0x50]
     ab4:	add    rsp,0x60
     ab8:	mov    rsp,rbp
     abb:	pop    rbp
     abc:	ret
     abd:	sar    rbx,1
     ac0:	add    rbx,0x1
     ac7:	shl    rbx,1
     aca:	or     rbx,0x1
     ace:	mov    QWORD PTR [rsp+0x18],rbx
     ad3:	mov    rdi,r14
     ad6:	call   adb <botlish_fn_7+0x19b>
			ad7: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     adb:	mov    QWORD PTR [rsp+0x20],0x81
     ae4:	mov    rsi,QWORD PTR [rsp+0x28]
     ae9:	test   rsi,0x1
     af0:	je     b0f <botlish_fn_7+0x1cf>
     af6:	mov    rsi,QWORD PTR [rsp+0x28]
     afb:	mov    rax,rsi
     afe:	add    rax,0x80
     b04:	seto   cl
     b07:	test   cl,cl
     b09:	je     b21 <botlish_fn_7+0x1e1>
     b0f:	mov    edx,0x81
     b14:	mov    rsi,QWORD PTR [rsp+0x28]
     b19:	mov    rdi,r14
     b1c:	call   b21 <botlish_fn_7+0x1e1>
			b1d: R_X86_64_PLT32	rt_int_add-0x4
     b21:	mov    QWORD PTR [rsp],r13
     b25:	mov    QWORD PTR [rsp+0x8],r12
     b2a:	mov    QWORD PTR [rsp+0x10],rax
     b2f:	mov    r15,r12
     b32:	mov    QWORD PTR [rsp+0x28],rax
     b37:	jmp    980 <botlish_fn_7+0x40>
     b3c:	mov    rax,QWORD PTR [rsp+0x28]
     b41:	mov    rbx,QWORD PTR [rsp+0x30]
     b46:	mov    r12,QWORD PTR [rsp+0x38]
     b4b:	mov    r13,QWORD PTR [rsp+0x40]
     b50:	mov    r14,QWORD PTR [rsp+0x48]
     b55:	mov    r15,QWORD PTR [rsp+0x50]
     b5a:	add    rsp,0x60
     b5e:	mov    rsp,rbp
     b61:	pop    rbp
     b62:	ret
     b63:	add    BYTE PTR [rax],al
     b65:	add    BYTE PTR [rax],al
     b67:	add    BYTE PTR [rsi],al
     b69:	add    BYTE PTR [rax],al
     b6b:	add    BYTE PTR [rax],al
     b6d:	add    BYTE PTR [rax],al
	...

0000000000000b70 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     b70:	push   rbp
     b71:	mov    rbp,rsp
     b74:	mov    rsi,QWORD PTR [rdx]
     b77:	mov    r9,QWORD PTR [rdx+0x8]
     b7b:	mov    rcx,QWORD PTR [rdx+0x10]
     b7f:	mov    r8,QWORD PTR [rdx+0x18]
     b83:	mov    rdx,r9
     b86:	call   b8b <botlish_entry_7+0x1b>
			b87: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     b8b:	mov    rsp,rbp
     b8e:	pop    rbp
     b8f:	ret

0000000000000b90 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     b90:	push   rbp
     b91:	mov    rbp,rsp
     b94:	sub    rsp,0x60
     b98:	mov    QWORD PTR [rsp+0x30],rbx
     b9d:	mov    QWORD PTR [rsp+0x38],r12
     ba2:	mov    QWORD PTR [rsp+0x40],r13
     ba7:	mov    QWORD PTR [rsp+0x48],r14
     bac:	mov    QWORD PTR [rsp+0x50],r15
     bb1:	mov    rbx,rdx
     bb4:	mov    r14,rdi
     bb7:	mov    QWORD PTR [rsp],rsi
     bbb:	mov    QWORD PTR [rsp+0x8],rcx
     bc0:	mov    r13,rcx
     bc3:	mov    QWORD PTR [rsp+0x10],r8
     bc8:	mov    r12,rsi
     bcb:	mov    r15,r8
     bce:	mov    rsi,r12
     bd1:	mov    rdi,r14
     bd4:	call   bd9 <botlish_fn_8+0x49>
			bd5: R_X86_64_PLT32	rt_list_len-0x4
     bd9:	mov    rcx,rbx
     bdc:	and    rcx,rax
     bdf:	mov    rdx,rax
     be2:	test   rcx,0x1
     be9:	jne    c0f <botlish_fn_8+0x7f>
     bef:	mov    rsi,rbx
     bf2:	mov    rdi,r14
     bf5:	call   bfa <botlish_fn_8+0x6a>
			bf6: R_X86_64_PLT32	rt_int_cmp-0x4
     bfa:	mov    ecx,0x2
     bff:	test   rax,rax
     c02:	cmovge rcx,QWORD PTR [rip+0x15e]        # d68 <botlish_fn_8+0x1d8>
     c0a:	jmp    c1f <botlish_fn_8+0x8f>
     c0f:	mov    ecx,0x2
     c14:	cmp    rbx,rdx
     c17:	cmovge rcx,QWORD PTR [rip+0x149]        # d68 <botlish_fn_8+0x1d8>
     c1f:	cmp    rcx,0x6
     c23:	je     d3e <botlish_fn_8+0x1ae>
     c29:	test   rbx,0x1
     c30:	je     c4a <botlish_fn_8+0xba>
     c36:	mov    rax,QWORD PTR [r12+0x8]
     c3b:	mov    rcx,rbx
     c3e:	sar    rcx,1
     c41:	cmp    rcx,rax
     c44:	jb     c6b <botlish_fn_8+0xdb>
     c4a:	mov    rdx,rbx
     c4d:	mov    rsi,r12
     c50:	mov    rdi,r14
     c53:	call   c58 <botlish_fn_8+0xc8>
			c54: R_X86_64_PLT32	rt_list_get-0x4
     c58:	test   rax,rax
     c5b:	je     ca9 <botlish_fn_8+0x119>
     c61:	mov    QWORD PTR [rsp+0x28],rax
     c66:	jmp    c79 <botlish_fn_8+0xe9>
     c6b:	mov    rax,QWORD PTR [r12+0x10]
     c70:	mov    rcx,QWORD PTR [rax+rcx*8]
     c74:	mov    QWORD PTR [rsp+0x28],rcx
     c79:	mov    rdi,r14
     c7c:	call   c81 <botlish_fn_8+0xf1>
			c7d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     c81:	mov    r8d,0x1
     c87:	mov    r9d,0x81
     c8d:	mov    rcx,QWORD PTR [rsp+0x28]
     c92:	mov    rdx,r15
     c95:	mov    rsi,r13
     c98:	mov    rdi,r14
     c9b:	call   ca0 <botlish_fn_8+0x110>
			c9c: R_X86_64_PLT32	rt_mutarray_copy-0x4
     ca0:	test   rax,rax
     ca3:	jne    cce <botlish_fn_8+0x13e>
     ca9:	xor    rax,rax
     cac:	mov    rbx,QWORD PTR [rsp+0x30]
     cb1:	mov    r12,QWORD PTR [rsp+0x38]
     cb6:	mov    r13,QWORD PTR [rsp+0x40]
     cbb:	mov    r14,QWORD PTR [rsp+0x48]
     cc0:	mov    r15,QWORD PTR [rsp+0x50]
     cc5:	add    rsp,0x60
     cc9:	mov    rsp,rbp
     ccc:	pop    rbp
     ccd:	ret
     cce:	sar    rbx,1
     cd1:	add    rbx,0x1
     cd8:	shl    rbx,1
     cdb:	or     rbx,0x1
     cdf:	mov    QWORD PTR [rsp+0x18],rbx
     ce4:	mov    rdi,r14
     ce7:	call   cec <botlish_fn_8+0x15c>
			ce8: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     cec:	mov    QWORD PTR [rsp+0x20],0x81
     cf5:	mov    rsi,r15
     cf8:	test   rsi,0x1
     cff:	je     d1b <botlish_fn_8+0x18b>
     d05:	mov    rax,rsi
     d08:	add    rax,0x80
     d0e:	seto   r9b
     d12:	test   r9b,r9b
     d15:	je     d28 <botlish_fn_8+0x198>
     d1b:	mov    edx,0x81
     d20:	mov    rdi,r14
     d23:	call   d28 <botlish_fn_8+0x198>
			d24: R_X86_64_PLT32	rt_int_add-0x4
     d28:	mov    QWORD PTR [rsp],r12
     d2c:	mov    QWORD PTR [rsp+0x8],r13
     d31:	mov    QWORD PTR [rsp+0x10],rax
     d36:	mov    r15,rax
     d39:	jmp    bce <botlish_fn_8+0x3e>
     d3e:	mov    rax,r15
     d41:	mov    rbx,QWORD PTR [rsp+0x30]
     d46:	mov    r12,QWORD PTR [rsp+0x38]
     d4b:	mov    r13,QWORD PTR [rsp+0x40]
     d50:	mov    r14,QWORD PTR [rsp+0x48]
     d55:	mov    r15,QWORD PTR [rsp+0x50]
     d5a:	add    rsp,0x60
     d5e:	mov    rsp,rbp
     d61:	pop    rbp
     d62:	ret
     d63:	add    BYTE PTR [rax],al
     d65:	add    BYTE PTR [rax],al
     d67:	add    BYTE PTR [rsi],al
     d69:	add    BYTE PTR [rax],al
     d6b:	add    BYTE PTR [rax],al
     d6d:	add    BYTE PTR [rax],al
	...

0000000000000d70 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     d70:	push   rbp
     d71:	mov    rbp,rsp
     d74:	mov    rsi,QWORD PTR [rdx]
     d77:	mov    r9,QWORD PTR [rdx+0x8]
     d7b:	mov    rcx,QWORD PTR [rdx+0x10]
     d7f:	mov    r8,QWORD PTR [rdx+0x18]
     d83:	mov    rdx,r9
     d86:	call   d8b <botlish_entry_8+0x1b>
			d87: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
     d8b:	mov    rsp,rbp
     d8e:	pop    rbp
     d8f:	ret

0000000000000d90 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
     d90:	push   rbp
     d91:	mov    rbp,rsp
     d94:	sub    rsp,0x70
     d98:	mov    QWORD PTR [rsp+0x40],rbx
     d9d:	mov    QWORD PTR [rsp+0x48],r12
     da2:	mov    QWORD PTR [rsp+0x50],r13
     da7:	mov    QWORD PTR [rsp+0x58],r14
     dac:	mov    QWORD PTR [rsp+0x60],r15
     db1:	mov    r13,rdi
     db4:	mov    QWORD PTR [rsp+0x28],0x0
     dbd:	mov    QWORD PTR [rsp+0x30],0x0
     dc6:	mov    QWORD PTR [rsp],rsi
     dca:	mov    r15,rsi
     dcd:	mov    QWORD PTR [rsp+0x8],rdx
     dd2:	mov    r14,rdx
     dd5:	mov    QWORD PTR [rsp+0x10],rcx
     dda:	mov    r12,rcx
     ddd:	mov    rsi,r15
     de0:	mov    rdi,r13
     de3:	call   de8 <botlish_fn_9+0x58>
			de4: R_X86_64_PLT32	rt_list_len-0x4
     de8:	mov    QWORD PTR [rsp+0x18],rax
     ded:	mov    rbx,rax
     df0:	mov    rdi,r13
     df3:	call   df8 <botlish_fn_9+0x68>
			df4: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     df8:	mov    QWORD PTR [rsp+0x20],0x81
     e01:	mov    rcx,rbx
     e04:	test   rcx,0x1
     e0b:	jne    e19 <botlish_fn_9+0x89>
     e11:	mov    rbx,rcx
     e14:	jmp    e40 <botlish_fn_9+0xb0>
     e19:	mov    rax,rcx
     e1c:	sar    rax,1
     e1f:	mov    rbx,rcx
     e22:	imul   QWORD PTR [rip+0x14f]        # f78 <botlish_fn_9+0x1e8>
     e29:	seto   cl
     e2c:	or     rax,0x1
     e30:	test   cl,cl
     e32:	jne    e40 <botlish_fn_9+0xb0>
     e38:	mov    rsi,rax
     e3b:	jmp    e53 <botlish_fn_9+0xc3>
     e40:	mov    edx,0x81
     e45:	mov    rsi,rbx
     e48:	mov    rdi,r13
     e4b:	call   e50 <botlish_fn_9+0xc0>
			e4c: R_X86_64_PLT32	rt_int_mul-0x4
     e50:	mov    rsi,rax
     e53:	mov    QWORD PTR [rsp+0x18],rsi
     e58:	mov    rax,rsi
     e5b:	and    rax,r12
     e5e:	test   rax,0x1
     e64:	je     e80 <botlish_fn_9+0xf0>
     e6a:	lea    rcx,[r12-0x1]
     e6f:	mov    rbx,rsi
     e72:	add    rbx,rcx
     e75:	seto   al
     e78:	test   al,al
     e7a:	je     e8e <botlish_fn_9+0xfe>
     e80:	mov    rdx,r12
     e83:	mov    rdi,r13
     e86:	call   e8b <botlish_fn_9+0xfb>
			e87: R_X86_64_PLT32	rt_int_add-0x4
     e8b:	mov    rbx,rax
     e8e:	mov    QWORD PTR [rsp+0x18],rbx
     e93:	mov    rsi,rbx
     e96:	mov    rdi,r13
     e99:	call   e9e <botlish_fn_9+0x10e>
			e9a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     e9e:	mov    rcx,rax
     ea1:	mov    QWORD PTR [rsp+0x38],rax
     ea6:	test   rax,rcx
     ea9:	je     f2b <botlish_fn_9+0x19b>
     eaf:	mov    rax,QWORD PTR [rsp+0x38]
     eb4:	mov    QWORD PTR [rsp+0x20],rax
     eb9:	mov    r8d,0x1
     ebf:	mov    QWORD PTR [rsp+0x28],0x1
     ec8:	mov    QWORD PTR [rsp+0x30],0x1
     ed1:	mov    rsi,r15
     ed4:	mov    rcx,QWORD PTR [rsp+0x38]
     ed9:	mov    rdi,r13
     edc:	mov    rdx,r8
     edf:	call   ee4 <botlish_fn_9+0x154>
			ee0: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     ee4:	test   rax,rax
     ee7:	mov    rdx,rax
     eea:	je     f2b <botlish_fn_9+0x19b>
     ef0:	mov    r8d,0x1
     ef6:	mov    rcx,r14
     ef9:	mov    r9,r12
     efc:	mov    rsi,QWORD PTR [rsp+0x38]
     f01:	mov    rdi,r13
     f04:	call   f09 <botlish_fn_9+0x179>
			f05: R_X86_64_PLT32	rt_mutarray_copy-0x4
     f09:	test   rax,rax
     f0c:	je     f2b <botlish_fn_9+0x19b>
     f12:	mov    rdx,rbx
     f15:	mov    rsi,QWORD PTR [rsp+0x38]
     f1a:	mov    rdi,r13
     f1d:	call   f22 <botlish_fn_9+0x192>
			f1e: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     f22:	test   rax,rax
     f25:	jne    f50 <botlish_fn_9+0x1c0>
     f2b:	xor    rax,rax
     f2e:	mov    rbx,QWORD PTR [rsp+0x40]
     f33:	mov    r12,QWORD PTR [rsp+0x48]
     f38:	mov    r13,QWORD PTR [rsp+0x50]
     f3d:	mov    r14,QWORD PTR [rsp+0x58]
     f42:	mov    r15,QWORD PTR [rsp+0x60]
     f47:	add    rsp,0x70
     f4b:	mov    rsp,rbp
     f4e:	pop    rbp
     f4f:	ret
     f50:	mov    rbx,QWORD PTR [rsp+0x40]
     f55:	mov    r12,QWORD PTR [rsp+0x48]
     f5a:	mov    r13,QWORD PTR [rsp+0x50]
     f5f:	mov    r14,QWORD PTR [rsp+0x58]
     f64:	mov    r15,QWORD PTR [rsp+0x60]
     f69:	add    rsp,0x70
     f6d:	mov    rsp,rbp
     f70:	pop    rbp
     f71:	ret
     f72:	add    BYTE PTR [rax],al
     f74:	add    BYTE PTR [rax],al
     f76:	add    BYTE PTR [rax],al
     f78:	add    BYTE PTR [rax],0x0
     f7b:	add    BYTE PTR [rax],al
     f7d:	add    BYTE PTR [rax],al
	...

0000000000000f80 <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
     f80:	push   rbp
     f81:	mov    rbp,rsp
     f84:	mov    rsi,QWORD PTR [rdx]
     f87:	mov    r8,QWORD PTR [rdx+0x8]
     f8b:	mov    rcx,QWORD PTR [rdx+0x10]
     f8f:	mov    rdx,r8
     f92:	call   f97 <botlish_entry_9+0x17>
			f93: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
     f97:	mov    rsp,rbp
     f9a:	pop    rbp
     f9b:	ret
     f9c:	add    BYTE PTR [rax],al
	...

0000000000000fa0 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
     fa0:	push   rbp
     fa1:	mov    rbp,rsp
     fa4:	sub    rsp,0x70
     fa8:	mov    QWORD PTR [rsp+0x40],rbx
     fad:	mov    QWORD PTR [rsp+0x48],r12
     fb2:	mov    QWORD PTR [rsp+0x50],r13
     fb7:	mov    QWORD PTR [rsp+0x58],r14
     fbc:	mov    QWORD PTR [rsp+0x60],r15
     fc1:	mov    r13,rdi
     fc4:	mov    QWORD PTR [rsp+0x28],0x0
     fcd:	mov    QWORD PTR [rsp+0x30],0x0
     fd6:	mov    QWORD PTR [rsp],rsi
     fda:	mov    r15,rsi
     fdd:	mov    QWORD PTR [rsp+0x8],rdx
     fe2:	mov    r14,rdx
     fe5:	mov    QWORD PTR [rsp+0x10],rcx
     fea:	mov    r12,rcx
     fed:	mov    rsi,r15
     ff0:	mov    rdi,r13
     ff3:	call   ff8 <botlish_fn_10+0x58>
			ff4: R_X86_64_PLT32	rt_list_len-0x4
     ff8:	mov    QWORD PTR [rsp+0x18],rax
     ffd:	mov    rbx,rax
    1000:	mov    rdi,r13
    1003:	call   1008 <botlish_fn_10+0x68>
			1004: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1008:	mov    QWORD PTR [rsp+0x20],0x81
    1011:	mov    rcx,rbx
    1014:	test   rcx,0x1
    101b:	jne    1029 <botlish_fn_10+0x89>
    1021:	mov    rbx,rcx
    1024:	jmp    1050 <botlish_fn_10+0xb0>
    1029:	mov    rax,rcx
    102c:	sar    rax,1
    102f:	mov    rbx,rcx
    1032:	imul   QWORD PTR [rip+0x14f]        # 1188 <botlish_fn_10+0x1e8>
    1039:	seto   cl
    103c:	or     rax,0x1
    1040:	test   cl,cl
    1042:	jne    1050 <botlish_fn_10+0xb0>
    1048:	mov    rsi,rax
    104b:	jmp    1063 <botlish_fn_10+0xc3>
    1050:	mov    edx,0x81
    1055:	mov    rsi,rbx
    1058:	mov    rdi,r13
    105b:	call   1060 <botlish_fn_10+0xc0>
			105c: R_X86_64_PLT32	rt_int_mul-0x4
    1060:	mov    rsi,rax
    1063:	mov    QWORD PTR [rsp+0x18],rsi
    1068:	mov    rax,rsi
    106b:	and    rax,r12
    106e:	test   rax,0x1
    1074:	je     1090 <botlish_fn_10+0xf0>
    107a:	lea    rcx,[r12-0x1]
    107f:	mov    rbx,rsi
    1082:	add    rbx,rcx
    1085:	seto   al
    1088:	test   al,al
    108a:	je     109e <botlish_fn_10+0xfe>
    1090:	mov    rdx,r12
    1093:	mov    rdi,r13
    1096:	call   109b <botlish_fn_10+0xfb>
			1097: R_X86_64_PLT32	rt_int_add-0x4
    109b:	mov    rbx,rax
    109e:	mov    QWORD PTR [rsp+0x18],rbx
    10a3:	mov    rsi,rbx
    10a6:	mov    rdi,r13
    10a9:	call   10ae <botlish_fn_10+0x10e>
			10aa: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    10ae:	mov    rcx,rax
    10b1:	mov    QWORD PTR [rsp+0x38],rax
    10b6:	test   rax,rcx
    10b9:	je     113b <botlish_fn_10+0x19b>
    10bf:	mov    rax,QWORD PTR [rsp+0x38]
    10c4:	mov    QWORD PTR [rsp+0x20],rax
    10c9:	mov    r8d,0x1
    10cf:	mov    QWORD PTR [rsp+0x28],0x1
    10d8:	mov    QWORD PTR [rsp+0x30],0x1
    10e1:	mov    rsi,r15
    10e4:	mov    rcx,QWORD PTR [rsp+0x38]
    10e9:	mov    rdi,r13
    10ec:	mov    rdx,r8
    10ef:	call   10f4 <botlish_fn_10+0x154>
			10f0: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    10f4:	test   rax,rax
    10f7:	mov    rdx,rax
    10fa:	je     113b <botlish_fn_10+0x19b>
    1100:	mov    r8d,0x1
    1106:	mov    rcx,r14
    1109:	mov    r9,r12
    110c:	mov    rsi,QWORD PTR [rsp+0x38]
    1111:	mov    rdi,r13
    1114:	call   1119 <botlish_fn_10+0x179>
			1115: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1119:	test   rax,rax
    111c:	je     113b <botlish_fn_10+0x19b>
    1122:	mov    rdx,rbx
    1125:	mov    rsi,QWORD PTR [rsp+0x38]
    112a:	mov    rdi,r13
    112d:	call   1132 <botlish_fn_10+0x192>
			112e: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    1132:	test   rax,rax
    1135:	jne    1160 <botlish_fn_10+0x1c0>
    113b:	xor    rax,rax
    113e:	mov    rbx,QWORD PTR [rsp+0x40]
    1143:	mov    r12,QWORD PTR [rsp+0x48]
    1148:	mov    r13,QWORD PTR [rsp+0x50]
    114d:	mov    r14,QWORD PTR [rsp+0x58]
    1152:	mov    r15,QWORD PTR [rsp+0x60]
    1157:	add    rsp,0x70
    115b:	mov    rsp,rbp
    115e:	pop    rbp
    115f:	ret
    1160:	mov    rbx,QWORD PTR [rsp+0x40]
    1165:	mov    r12,QWORD PTR [rsp+0x48]
    116a:	mov    r13,QWORD PTR [rsp+0x50]
    116f:	mov    r14,QWORD PTR [rsp+0x58]
    1174:	mov    r15,QWORD PTR [rsp+0x60]
    1179:	add    rsp,0x70
    117d:	mov    rsp,rbp
    1180:	pop    rbp
    1181:	ret
    1182:	add    BYTE PTR [rax],al
    1184:	add    BYTE PTR [rax],al
    1186:	add    BYTE PTR [rax],al
    1188:	add    BYTE PTR [rax],0x0
    118b:	add    BYTE PTR [rax],al
    118d:	add    BYTE PTR [rax],al
	...

0000000000001190 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1190:	push   rbp
    1191:	mov    rbp,rsp
    1194:	mov    rsi,QWORD PTR [rdx]
    1197:	mov    r8,QWORD PTR [rdx+0x8]
    119b:	mov    rcx,QWORD PTR [rdx+0x10]
    119f:	mov    rdx,r8
    11a2:	call   11a7 <botlish_entry_10+0x17>
			11a3: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    11a7:	mov    rsp,rbp
    11aa:	pop    rbp
    11ab:	ret
    11ac:	add    BYTE PTR [rax],al
	...

00000000000011b0 <botlish_fn_11: peek<str, int>>:
    11b0:	push   rbp
    11b1:	mov    rbp,rsp
    11b4:	sub    rsp,0x40
    11b8:	mov    QWORD PTR [rsp+0x20],rbx
    11bd:	mov    QWORD PTR [rsp+0x28],r12
    11c2:	mov    QWORD PTR [rsp+0x30],r13
    11c7:	mov    r13,rdi
    11ca:	mov    QWORD PTR [rsp],rsi
    11ce:	mov    r12,rsi
    11d1:	mov    QWORD PTR [rsp+0x8],rdx
    11d6:	mov    rbx,rdx
    11d9:	mov    rsi,r12
    11dc:	mov    rdi,r13
    11df:	call   11e4 <botlish_fn_11+0x34>
			11e0: R_X86_64_PLT32	rt_str_len-0x4
    11e4:	mov    rcx,rbx
    11e7:	and    rcx,rax
    11ea:	mov    rdx,rax
    11ed:	test   rcx,0x1
    11f4:	jne    121a <botlish_fn_11+0x6a>
    11fa:	mov    rsi,rbx
    11fd:	mov    rdi,r13
    1200:	call   1205 <botlish_fn_11+0x55>
			1201: R_X86_64_PLT32	rt_int_cmp-0x4
    1205:	mov    ecx,0x2
    120a:	test   rax,rax
    120d:	cmovge rcx,QWORD PTR [rip+0xd3]        # 12e8 <botlish_fn_11+0x138>
    1215:	jmp    122a <botlish_fn_11+0x7a>
    121a:	mov    ecx,0x2
    121f:	cmp    rbx,rdx
    1222:	cmovge rcx,QWORD PTR [rip+0xbe]        # 12e8 <botlish_fn_11+0x138>
    122a:	cmp    rcx,0x6
    122e:	je     12be <botlish_fn_11+0x10e>
    1234:	mov    QWORD PTR [rsp+0x10],0x3
    123d:	test   rbx,0x1
    1244:	je     125c <botlish_fn_11+0xac>
    124a:	mov    rcx,rbx
    124d:	add    rcx,0x2
    1251:	seto   al
    1254:	test   al,al
    1256:	je     126f <botlish_fn_11+0xbf>
    125c:	mov    edx,0x3
    1261:	mov    rsi,rbx
    1264:	mov    rdi,r13
    1267:	call   126c <botlish_fn_11+0xbc>
			1268: R_X86_64_PLT32	rt_int_add-0x4
    126c:	mov    rcx,rax
    126f:	mov    QWORD PTR [rsp+0x10],rcx
    1274:	mov    rdx,rbx
    1277:	mov    rsi,r12
    127a:	mov    rdi,r13
    127d:	call   1282 <botlish_fn_11+0xd2>
			127e: R_X86_64_PLT32	rt_substr-0x4
    1282:	test   rax,rax
    1285:	jne    12a6 <botlish_fn_11+0xf6>
    128b:	xor    rax,rax
    128e:	mov    rbx,QWORD PTR [rsp+0x20]
    1293:	mov    r12,QWORD PTR [rsp+0x28]
    1298:	mov    r13,QWORD PTR [rsp+0x30]
    129d:	add    rsp,0x40
    12a1:	mov    rsp,rbp
    12a4:	pop    rbp
    12a5:	ret
    12a6:	mov    rbx,QWORD PTR [rsp+0x20]
    12ab:	mov    r12,QWORD PTR [rsp+0x28]
    12b0:	mov    r13,QWORD PTR [rsp+0x30]
    12b5:	add    rsp,0x40
    12b9:	mov    rsp,rbp
    12bc:	pop    rbp
    12bd:	ret
    12be:	mov    rdi,r13
    12c1:	mov    rax,QWORD PTR [rdi+0x10]
    12c5:	mov    rax,QWORD PTR [rax+0x10]
    12c9:	mov    rbx,QWORD PTR [rsp+0x20]
    12ce:	mov    r12,QWORD PTR [rsp+0x28]
    12d3:	mov    r13,QWORD PTR [rsp+0x30]
    12d8:	add    rsp,0x40
    12dc:	mov    rsp,rbp
    12df:	pop    rbp
    12e0:	ret
    12e1:	add    BYTE PTR [rax],al
    12e3:	add    BYTE PTR [rax],al
    12e5:	add    BYTE PTR [rax],al
    12e7:	add    BYTE PTR [rsi],al
    12e9:	add    BYTE PTR [rax],al
    12eb:	add    BYTE PTR [rax],al
    12ed:	add    BYTE PTR [rax],al
	...

00000000000012f0 <botlish_entry_11: peek<str, int>>:
    12f0:	push   rbp
    12f1:	mov    rbp,rsp
    12f4:	mov    rsi,QWORD PTR [rdx]
    12f7:	mov    rdx,QWORD PTR [rdx+0x8]
    12fb:	call   1300 <botlish_entry_11+0x10>
			12fc: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1300:	mov    rsp,rbp
    1303:	pop    rbp
    1304:	ret
    1305:	add    BYTE PTR [rax],al
	...

0000000000001308 <botlish_fn_12: peek<str, int>>:
    1308:	push   rbp
    1309:	mov    rbp,rsp
    130c:	sub    rsp,0x50
    1310:	mov    QWORD PTR [rsp+0x20],rbx
    1315:	mov    QWORD PTR [rsp+0x28],r12
    131a:	mov    QWORD PTR [rsp+0x30],r13
    131f:	mov    QWORD PTR [rsp+0x38],r14
    1324:	mov    QWORD PTR [rsp+0x40],r15
    1329:	mov    r12,rcx
    132c:	mov    r14,rdi
    132f:	mov    QWORD PTR [rsp],rsi
    1333:	mov    r13,rsi
    1336:	mov    QWORD PTR [rsp+0x8],rdx
    133b:	mov    rbx,rdx
    133e:	mov    rsi,r13
    1341:	mov    rdi,r14
    1344:	call   1349 <botlish_fn_12+0x41>
			1345: R_X86_64_PLT32	rt_str_len-0x4
    1349:	mov    rcx,rbx
    134c:	and    rcx,rax
    134f:	mov    rdx,rax
    1352:	test   rcx,0x1
    1359:	jne    137f <botlish_fn_12+0x77>
    135f:	mov    rsi,rbx
    1362:	mov    rdi,r14
    1365:	call   136a <botlish_fn_12+0x62>
			1366: R_X86_64_PLT32	rt_int_cmp-0x4
    136a:	mov    ecx,0x2
    136f:	test   rax,rax
    1372:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1498 <botlish_fn_12+0x190>
    137a:	jmp    138f <botlish_fn_12+0x87>
    137f:	mov    ecx,0x2
    1384:	cmp    rbx,rdx
    1387:	cmovge rcx,QWORD PTR [rip+0x109]        # 1498 <botlish_fn_12+0x190>
    138f:	cmp    rcx,0x6
    1393:	je     1453 <botlish_fn_12+0x14b>
    1399:	mov    QWORD PTR [rsp+0x10],0x3
    13a2:	test   rbx,0x1
    13a9:	je     13cc <botlish_fn_12+0xc4>
    13af:	mov    rax,rbx
    13b2:	add    rax,0x2
    13b6:	seto   cl
    13b9:	test   cl,cl
    13bb:	jne    13cc <botlish_fn_12+0xc4>
    13c1:	mov    rdi,r14
    13c4:	mov    r15,rax
    13c7:	jmp    13e2 <botlish_fn_12+0xda>
    13cc:	mov    edx,0x3
    13d1:	mov    rsi,rbx
    13d4:	mov    rdi,r14
    13d7:	call   13dc <botlish_fn_12+0xd4>
			13d8: R_X86_64_PLT32	rt_int_add-0x4
    13dc:	mov    r15,rax
    13df:	mov    rdi,r14
    13e2:	mov    rdi,r14
    13e5:	mov    rcx,r15
    13e8:	mov    rdx,rbx
    13eb:	mov    rsi,r13
    13ee:	call   13f3 <botlish_fn_12+0xeb>
			13ef: R_X86_64_PLT32	rt_str_region_check-0x4
    13f3:	test   rax,rax
    13f6:	jne    1421 <botlish_fn_12+0x119>
    13fc:	xor    rax,rax
    13ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1404:	mov    r12,QWORD PTR [rsp+0x28]
    1409:	mov    r13,QWORD PTR [rsp+0x30]
    140e:	mov    r14,QWORD PTR [rsp+0x38]
    1413:	mov    r15,QWORD PTR [rsp+0x40]
    1418:	add    rsp,0x50
    141c:	mov    rsp,rbp
    141f:	pop    rbp
    1420:	ret
    1421:	mov    rcx,r12
    1424:	mov    QWORD PTR [rcx],rbx
    1427:	mov    rax,r15
    142a:	mov    QWORD PTR [rcx+0x8],rax
    142e:	mov    rax,r13
    1431:	mov    rbx,QWORD PTR [rsp+0x20]
    1436:	mov    r12,QWORD PTR [rsp+0x28]
    143b:	mov    r13,QWORD PTR [rsp+0x30]
    1440:	mov    r14,QWORD PTR [rsp+0x38]
    1445:	mov    r15,QWORD PTR [rsp+0x40]
    144a:	add    rsp,0x50
    144e:	mov    rsp,rbp
    1451:	pop    rbp
    1452:	ret
    1453:	mov    rcx,r12
    1456:	mov    rdi,r14
    1459:	mov    rax,QWORD PTR [rdi+0x10]
    145d:	mov    rax,QWORD PTR [rax+0x10]
    1461:	mov    QWORD PTR [rcx],0x1
    1468:	mov    QWORD PTR [rcx+0x8],0x1
    1470:	mov    rbx,QWORD PTR [rsp+0x20]
    1475:	mov    r12,QWORD PTR [rsp+0x28]
    147a:	mov    r13,QWORD PTR [rsp+0x30]
    147f:	mov    r14,QWORD PTR [rsp+0x38]
    1484:	mov    r15,QWORD PTR [rsp+0x40]
    1489:	add    rsp,0x50
    148d:	mov    rsp,rbp
    1490:	pop    rbp
    1491:	ret
    1492:	add    BYTE PTR [rax],al
    1494:	add    BYTE PTR [rax],al
    1496:	add    BYTE PTR [rax],al
    1498:	(bad)
    1499:	add    BYTE PTR [rax],al
    149b:	add    BYTE PTR [rax],al
    149d:	add    BYTE PTR [rax],al
	...

00000000000014a0 <botlish_entry_12: peek<str, int>>:
    14a0:	push   rbp
    14a1:	mov    rbp,rsp
    14a4:	ud2

00000000000014a6 <botlish_fn_13: scan_unquoted<str, int, int>>:
    14a6:	push   rbp
    14a7:	mov    rbp,rsp
    14aa:	sub    rsp,0x80
    14b1:	mov    QWORD PTR [rsp+0x50],rbx
    14b6:	mov    QWORD PTR [rsp+0x58],r12
    14bb:	mov    QWORD PTR [rsp+0x60],r13
    14c0:	mov    QWORD PTR [rsp+0x68],r14
    14c5:	mov    QWORD PTR [rsp+0x70],r15
    14ca:	mov    QWORD PTR [rsp+0x30],rdi
    14cf:	mov    QWORD PTR [rsp+0x18],0x0
    14d8:	mov    QWORD PTR [rsp],rsi
    14dc:	mov    r15,rsi
    14df:	mov    QWORD PTR [rsp+0x8],rdx
    14e4:	mov    r14,rdx
    14e7:	mov    QWORD PTR [rsp+0x10],rcx
    14ec:	lea    r13,[rsp+0x20]
    14f1:	mov    QWORD PTR [rsp+0x38],rcx
    14f6:	mov    rcx,r13
    14f9:	mov    rdx,QWORD PTR [rsp+0x38]
    14fe:	mov    rsi,r15
    1501:	mov    rdi,QWORD PTR [rsp+0x30]
    1506:	call   150b <botlish_fn_13+0x65>
			1507: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    150b:	mov    rsi,rax
    150e:	mov    QWORD PTR [rsp+0x40],rax
    1513:	test   rax,rsi
    1516:	je     1670 <botlish_fn_13+0x1ca>
    151c:	mov    rbx,QWORD PTR [rsp+0x20]
    1521:	mov    r12,QWORD PTR [rsp+0x28]
    1526:	mov    rdi,QWORD PTR [rsp+0x30]
    152b:	mov    rcx,QWORD PTR [rdi+0x10]
    152f:	mov    r8,QWORD PTR [rcx+0x10]
    1533:	mov    rcx,r12
    1536:	mov    rdx,rbx
    1539:	mov    rsi,QWORD PTR [rsp+0x40]
    153e:	call   1543 <botlish_fn_13+0x9d>
			153f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1543:	cmp    rax,0x6
    1547:	je     1588 <botlish_fn_13+0xe2>
    154d:	mov    rdi,QWORD PTR [rsp+0x30]
    1552:	mov    rax,QWORD PTR [rdi+0x10]
    1556:	mov    r8,QWORD PTR [rax+0x18]
    155a:	mov    rcx,r12
    155d:	mov    rdx,rbx
    1560:	mov    rsi,QWORD PTR [rsp+0x40]
    1565:	call   156a <botlish_fn_13+0xc4>
			1566: R_X86_64_PLT32	rt_str_region_eq-0x4
    156a:	cmp    rax,0x6
    156e:	je     157e <botlish_fn_13+0xd8>
    1574:	mov    eax,0x2
    1579:	jmp    158d <botlish_fn_13+0xe7>
    157e:	mov    eax,0x6
    1583:	jmp    158d <botlish_fn_13+0xe7>
    1588:	mov    eax,0x6
    158d:	cmp    rax,0x6
    1591:	je     15d2 <botlish_fn_13+0x12c>
    1597:	mov    rdi,QWORD PTR [rsp+0x30]
    159c:	mov    rax,QWORD PTR [rdi+0x10]
    15a0:	mov    r8,QWORD PTR [rax+0x20]
    15a4:	mov    rcx,r12
    15a7:	mov    rdx,rbx
    15aa:	mov    rsi,QWORD PTR [rsp+0x40]
    15af:	call   15b4 <botlish_fn_13+0x10e>
			15b0: R_X86_64_PLT32	rt_str_region_eq-0x4
    15b4:	cmp    rax,0x6
    15b8:	je     15c8 <botlish_fn_13+0x122>
    15be:	mov    eax,0x2
    15c3:	jmp    15d7 <botlish_fn_13+0x131>
    15c8:	mov    eax,0x6
    15cd:	jmp    15d7 <botlish_fn_13+0x131>
    15d2:	mov    eax,0x6
    15d7:	cmp    rax,0x6
    15db:	je     1652 <botlish_fn_13+0x1ac>
    15e1:	mov    QWORD PTR [rsp+0x18],0x3
    15ea:	mov    rsi,QWORD PTR [rsp+0x38]
    15ef:	test   rsi,0x1
    15f6:	je     161d <botlish_fn_13+0x177>
    15fc:	mov    rsi,QWORD PTR [rsp+0x38]
    1601:	mov    rax,rsi
    1604:	add    rax,0x2
    1608:	seto   sil
    160c:	test   sil,sil
    160f:	jne    161d <botlish_fn_13+0x177>
    1615:	mov    rsi,r15
    1618:	jmp    1634 <botlish_fn_13+0x18e>
    161d:	mov    edx,0x3
    1622:	mov    rsi,QWORD PTR [rsp+0x38]
    1627:	mov    rdi,QWORD PTR [rsp+0x30]
    162c:	call   1631 <botlish_fn_13+0x18b>
			162d: R_X86_64_PLT32	rt_int_add-0x4
    1631:	mov    rsi,r15
    1634:	mov    QWORD PTR [rsp],rsi
    1638:	mov    rdx,r14
    163b:	mov    QWORD PTR [rsp+0x8],rdx
    1640:	mov    QWORD PTR [rsp+0x10],rax
    1645:	mov    r15,rsi
    1648:	mov    QWORD PTR [rsp+0x38],rax
    164d:	jmp    14f6 <botlish_fn_13+0x50>
    1652:	mov    rdx,r14
    1655:	mov    rsi,r15
    1658:	mov    rdi,QWORD PTR [rsp+0x30]
    165d:	mov    rcx,QWORD PTR [rsp+0x38]
    1662:	call   1667 <botlish_fn_13+0x1c1>
			1663: R_X86_64_PLT32	rt_substr-0x4
    1667:	test   rax,rax
    166a:	jne    169b <botlish_fn_13+0x1f5>
    1670:	xor    rdx,rdx
    1673:	mov    rax,rdx
    1676:	mov    rbx,QWORD PTR [rsp+0x50]
    167b:	mov    r12,QWORD PTR [rsp+0x58]
    1680:	mov    r13,QWORD PTR [rsp+0x60]
    1685:	mov    r14,QWORD PTR [rsp+0x68]
    168a:	mov    r15,QWORD PTR [rsp+0x70]
    168f:	add    rsp,0x80
    1696:	mov    rsp,rbp
    1699:	pop    rbp
    169a:	ret
    169b:	mov    rdx,QWORD PTR [rsp+0x38]
    16a0:	mov    rbx,QWORD PTR [rsp+0x50]
    16a5:	mov    r12,QWORD PTR [rsp+0x58]
    16aa:	mov    r13,QWORD PTR [rsp+0x60]
    16af:	mov    r14,QWORD PTR [rsp+0x68]
    16b4:	mov    r15,QWORD PTR [rsp+0x70]
    16b9:	add    rsp,0x80
    16c0:	mov    rsp,rbp
    16c3:	pop    rbp
    16c4:	ret

00000000000016c5 <botlish_entry_13: scan_unquoted<str, int, int>>:
    16c5:	push   rbp
    16c6:	mov    rbp,rsp
    16c9:	ud2

00000000000016cb <botlish_fn_14: scan_quoted<str, int, str>>:
    16cb:	push   rbp
    16cc:	mov    rbp,rsp
    16cf:	sub    rsp,0x70
    16d3:	mov    QWORD PTR [rsp+0x40],rbx
    16d8:	mov    QWORD PTR [rsp+0x48],r12
    16dd:	mov    QWORD PTR [rsp+0x50],r13
    16e2:	mov    QWORD PTR [rsp+0x58],r14
    16e7:	mov    QWORD PTR [rsp+0x60],r15
    16ec:	mov    r13,rdi
    16ef:	mov    QWORD PTR [rsp+0x18],0x0
    16f8:	mov    QWORD PTR [rsp+0x20],0x0
    1701:	mov    QWORD PTR [rsp],rsi
    1705:	mov    QWORD PTR [rsp+0x8],rdx
    170a:	mov    QWORD PTR [rsp+0x10],rcx
    170f:	lea    r12,[rsp+0x28]
    1714:	mov    rbx,rsi
    1717:	mov    r14,rdx
    171a:	mov    r15,rcx
    171d:	mov    rdx,r14
    1720:	mov    rsi,rbx
    1723:	mov    rdi,r13
    1726:	call   172b <botlish_fn_14+0x60>
			1727: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    172b:	test   rax,rax
    172e:	je     194a <botlish_fn_14+0x27f>
    1734:	mov    QWORD PTR [rsp+0x18],rax
    1739:	mov    rdi,r13
    173c:	mov    QWORD PTR [rsp+0x38],rax
    1741:	mov    rcx,QWORD PTR [rdi+0x10]
    1745:	mov    rsi,QWORD PTR [rcx+0x28]
    1749:	mov    edx,0x1
    174e:	mov    ecx,0x3
    1753:	mov    r8,QWORD PTR [rsp+0x38]
    1758:	call   175d <botlish_fn_14+0x92>
			1759: R_X86_64_PLT32	rt_str_region_eq-0x4
    175d:	cmp    rax,0x6
    1761:	je     17e4 <botlish_fn_14+0x119>
    1767:	mov    QWORD PTR [rsp+0x20],0x3
    1770:	mov    rsi,r14
    1773:	test   rsi,0x1
    177a:	je     179a <botlish_fn_14+0xcf>
    1780:	mov    rax,rsi
    1783:	add    rax,0x2
    1787:	seto   cl
    178a:	test   cl,cl
    178c:	jne    179a <botlish_fn_14+0xcf>
    1792:	mov    rsi,rax
    1795:	jmp    17aa <botlish_fn_14+0xdf>
    179a:	mov    edx,0x3
    179f:	mov    rdi,r13
    17a2:	call   17a7 <botlish_fn_14+0xdc>
			17a3: R_X86_64_PLT32	rt_int_add-0x4
    17a7:	mov    rsi,rax
    17aa:	mov    QWORD PTR [rsp+0x8],rsi
    17af:	mov    r14,rsi
    17b2:	mov    rsi,r15
    17b5:	mov    rdx,QWORD PTR [rsp+0x38]
    17ba:	mov    rdi,r13
    17bd:	call   17c2 <botlish_fn_14+0xf7>
			17be: R_X86_64_PLT32	rt_str_cat-0x4
    17c2:	test   rax,rax
    17c5:	je     194a <botlish_fn_14+0x27f>
    17cb:	mov    QWORD PTR [rsp],rbx
    17cf:	mov    rsi,r14
    17d2:	mov    QWORD PTR [rsp+0x8],rsi
    17d7:	mov    QWORD PTR [rsp+0x10],rax
    17dc:	mov    r15,rax
    17df:	jmp    171d <botlish_fn_14+0x52>
    17e4:	mov    QWORD PTR [rsp+0x18],0x3
    17ed:	mov    rsi,r14
    17f0:	test   rsi,0x1
    17f7:	je     1812 <botlish_fn_14+0x147>
    17fd:	mov    rsi,r14
    1800:	mov    rdx,rsi
    1803:	add    rdx,0x2
    1807:	seto   al
    180a:	test   al,al
    180c:	je     1825 <botlish_fn_14+0x15a>
    1812:	mov    edx,0x3
    1817:	mov    rsi,r14
    181a:	mov    rdi,r13
    181d:	call   1822 <botlish_fn_14+0x157>
			181e: R_X86_64_PLT32	rt_int_add-0x4
    1822:	mov    rdx,rax
    1825:	mov    QWORD PTR [rsp+0x18],rdx
    182a:	mov    rcx,r12
    182d:	mov    rsi,rbx
    1830:	mov    rdi,r13
    1833:	call   1838 <botlish_fn_14+0x16d>
			1834: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1838:	test   rax,rax
    183b:	mov    rsi,rax
    183e:	je     194a <botlish_fn_14+0x27f>
    1844:	mov    rdx,QWORD PTR [rsp+0x28]
    1849:	mov    rcx,QWORD PTR [rsp+0x30]
    184e:	mov    rdi,r13
    1851:	mov    rax,QWORD PTR [rdi+0x10]
    1855:	mov    r8,QWORD PTR [rax+0x28]
    1859:	call   185e <botlish_fn_14+0x193>
			185a: R_X86_64_PLT32	rt_str_region_eq-0x4
    185e:	cmp    rax,0x6
    1862:	je     18d5 <botlish_fn_14+0x20a>
    1868:	mov    QWORD PTR [rsp],0x3
    1870:	mov    rsi,r14
    1873:	test   rsi,0x1
    187a:	je     189d <botlish_fn_14+0x1d2>
    1880:	mov    rsi,r14
    1883:	mov    rdx,rsi
    1886:	add    rdx,0x2
    188a:	seto   al
    188d:	test   al,al
    188f:	jne    189d <botlish_fn_14+0x1d2>
    1895:	mov    rax,r15
    1898:	jmp    18b3 <botlish_fn_14+0x1e8>
    189d:	mov    edx,0x3
    18a2:	mov    rsi,r14
    18a5:	mov    rdi,r13
    18a8:	call   18ad <botlish_fn_14+0x1e2>
			18a9: R_X86_64_PLT32	rt_int_add-0x4
    18ad:	mov    rdx,rax
    18b0:	mov    rax,r15
    18b3:	mov    rbx,QWORD PTR [rsp+0x40]
    18b8:	mov    r12,QWORD PTR [rsp+0x48]
    18bd:	mov    r13,QWORD PTR [rsp+0x50]
    18c2:	mov    r14,QWORD PTR [rsp+0x58]
    18c7:	mov    r15,QWORD PTR [rsp+0x60]
    18cc:	add    rsp,0x70
    18d0:	mov    rsp,rbp
    18d3:	pop    rbp
    18d4:	ret
    18d5:	mov    QWORD PTR [rsp+0x18],0x5
    18de:	mov    rsi,r14
    18e1:	test   rsi,0x1
    18e8:	je     190e <botlish_fn_14+0x243>
    18ee:	mov    rsi,r14
    18f1:	mov    rax,rsi
    18f4:	add    rax,0x4
    18f8:	seto   cl
    18fb:	test   cl,cl
    18fd:	jne    190e <botlish_fn_14+0x243>
    1903:	mov    rsi,rax
    1906:	mov    r14,rax
    1909:	jmp    1924 <botlish_fn_14+0x259>
    190e:	mov    edx,0x5
    1913:	mov    rsi,r14
    1916:	mov    rdi,r13
    1919:	call   191e <botlish_fn_14+0x253>
			191a: R_X86_64_PLT32	rt_int_add-0x4
    191e:	mov    rsi,rax
    1921:	mov    r14,rax
    1924:	mov    QWORD PTR [rsp+0x8],rsi
    1929:	mov    rdi,r13
    192c:	mov    rax,QWORD PTR [rdi+0x10]
    1930:	mov    rdx,QWORD PTR [rax+0x28]
    1934:	mov    QWORD PTR [rsp+0x18],rdx
    1939:	mov    rsi,r15
    193c:	call   1941 <botlish_fn_14+0x276>
			193d: R_X86_64_PLT32	rt_str_cat-0x4
    1941:	test   rax,rax
    1944:	jne    1972 <botlish_fn_14+0x2a7>
    194a:	xor    rdx,rdx
    194d:	mov    rax,rdx
    1950:	mov    rbx,QWORD PTR [rsp+0x40]
    1955:	mov    r12,QWORD PTR [rsp+0x48]
    195a:	mov    r13,QWORD PTR [rsp+0x50]
    195f:	mov    r14,QWORD PTR [rsp+0x58]
    1964:	mov    r15,QWORD PTR [rsp+0x60]
    1969:	add    rsp,0x70
    196d:	mov    rsp,rbp
    1970:	pop    rbp
    1971:	ret
    1972:	mov    QWORD PTR [rsp],rbx
    1976:	mov    rsi,r14
    1979:	mov    QWORD PTR [rsp+0x8],rsi
    197e:	mov    QWORD PTR [rsp+0x10],rax
    1983:	mov    r15,rax
    1986:	jmp    171d <botlish_fn_14+0x52>

000000000000198b <botlish_entry_14: scan_quoted<str, int, str>>:
    198b:	push   rbp
    198c:	mov    rbp,rsp
    198f:	ud2

0000000000001991 <botlish_fn_15: scan_field<str, int>>:
    1991:	push   rbp
    1992:	mov    rbp,rsp
    1995:	sub    rsp,0x50
    1999:	mov    QWORD PTR [rsp+0x30],rbx
    199e:	mov    QWORD PTR [rsp+0x38],r12
    19a3:	mov    QWORD PTR [rsp+0x40],r13
    19a8:	mov    r12,rdi
    19ab:	mov    r13,rdx
    19ae:	mov    QWORD PTR [rsp+0x10],0x0
    19b7:	mov    QWORD PTR [rsp],rsi
    19bb:	mov    rbx,rsi
    19be:	mov    QWORD PTR [rsp+0x8],rdx
    19c3:	lea    rcx,[rsp+0x18]
    19c8:	mov    rdx,r13
    19cb:	mov    rsi,rbx
    19ce:	mov    rdi,r12
    19d1:	call   19d6 <botlish_fn_15+0x45>
			19d2: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    19d6:	test   rax,rax
    19d9:	mov    rsi,rax
    19dc:	je     1aa7 <botlish_fn_15+0x116>
    19e2:	mov    rdx,QWORD PTR [rsp+0x18]
    19e7:	mov    rcx,QWORD PTR [rsp+0x20]
    19ec:	mov    rdi,r12
    19ef:	mov    rax,QWORD PTR [rdi+0x10]
    19f3:	mov    r8,QWORD PTR [rax+0x28]
    19f7:	call   19fc <botlish_fn_15+0x6b>
			19f8: R_X86_64_PLT32	rt_str_region_eq-0x4
    19fc:	cmp    rax,0x6
    1a00:	je     1a38 <botlish_fn_15+0xa7>
    1a06:	mov    rcx,r13
    1a09:	mov    rsi,rbx
    1a0c:	mov    rdi,r12
    1a0f:	mov    rdx,rcx
    1a12:	call   1a17 <botlish_fn_15+0x86>
			1a13: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    1a17:	test   rax,rax
    1a1a:	je     1aa7 <botlish_fn_15+0x116>
    1a20:	mov    rbx,QWORD PTR [rsp+0x30]
    1a25:	mov    r12,QWORD PTR [rsp+0x38]
    1a2a:	mov    r13,QWORD PTR [rsp+0x40]
    1a2f:	add    rsp,0x50
    1a33:	mov    rsp,rbp
    1a36:	pop    rbp
    1a37:	ret
    1a38:	mov    rcx,r13
    1a3b:	mov    QWORD PTR [rsp+0x10],0x3
    1a44:	test   rcx,0x1
    1a4b:	jne    1a59 <botlish_fn_15+0xc8>
    1a51:	mov    r13,rcx
    1a54:	jmp    1a6e <botlish_fn_15+0xdd>
    1a59:	mov    rdx,rcx
    1a5c:	add    rdx,0x2
    1a60:	mov    r13,rcx
    1a63:	seto   al
    1a66:	test   al,al
    1a68:	je     1a81 <botlish_fn_15+0xf0>
    1a6e:	mov    edx,0x3
    1a73:	mov    rsi,r13
    1a76:	mov    rdi,r12
    1a79:	call   1a7e <botlish_fn_15+0xed>
			1a7a: R_X86_64_PLT32	rt_int_add-0x4
    1a7e:	mov    rdx,rax
    1a81:	mov    QWORD PTR [rsp+0x8],rdx
    1a86:	mov    rdi,r12
    1a89:	mov    rax,QWORD PTR [rdi+0x10]
    1a8d:	mov    rcx,QWORD PTR [rax+0x10]
    1a91:	mov    QWORD PTR [rsp+0x10],rcx
    1a96:	mov    rsi,rbx
    1a99:	call   1a9e <botlish_fn_15+0x10d>
			1a9a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1a9e:	test   rax,rax
    1aa1:	jne    1ac5 <botlish_fn_15+0x134>
    1aa7:	xor    rdx,rdx
    1aaa:	mov    rax,rdx
    1aad:	mov    rbx,QWORD PTR [rsp+0x30]
    1ab2:	mov    r12,QWORD PTR [rsp+0x38]
    1ab7:	mov    r13,QWORD PTR [rsp+0x40]
    1abc:	add    rsp,0x50
    1ac0:	mov    rsp,rbp
    1ac3:	pop    rbp
    1ac4:	ret
    1ac5:	mov    rbx,QWORD PTR [rsp+0x30]
    1aca:	mov    r12,QWORD PTR [rsp+0x38]
    1acf:	mov    r13,QWORD PTR [rsp+0x40]
    1ad4:	add    rsp,0x50
    1ad8:	mov    rsp,rbp
    1adb:	pop    rbp
    1adc:	ret

0000000000001add <botlish_entry_15: scan_field<str, int>>:
    1add:	push   rbp
    1ade:	mov    rbp,rsp
    1ae1:	ud2

0000000000001ae3 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1ae3:	push   rbp
    1ae4:	mov    rbp,rsp
    1ae7:	sub    rsp,0xa0
    1aee:	mov    QWORD PTR [rsp+0x70],rbx
    1af3:	mov    QWORD PTR [rsp+0x78],r12
    1af8:	mov    QWORD PTR [rsp+0x80],r13
    1b00:	mov    QWORD PTR [rsp+0x88],r14
    1b08:	mov    QWORD PTR [rsp+0x90],r15
    1b10:	mov    r13,rdi
    1b13:	mov    QWORD PTR [rsp+0x28],0x0
    1b1c:	mov    QWORD PTR [rsp],rsi
    1b20:	mov    r15,rsi
    1b23:	mov    QWORD PTR [rsp+0x8],rdx
    1b28:	mov    QWORD PTR [rsp+0x10],rcx
    1b2d:	mov    QWORD PTR [rsp+0x50],rcx
    1b32:	mov    QWORD PTR [rsp+0x18],r8
    1b37:	mov    r12,r8
    1b3a:	mov    QWORD PTR [rsp+0x20],r9
    1b3f:	mov    rbx,r9
    1b42:	mov    rsi,r15
    1b45:	mov    rdi,r13
    1b48:	call   1b4d <botlish_fn_16+0x6a>
			1b49: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1b4d:	test   rax,rax
    1b50:	je     1d84 <botlish_fn_16+0x2a1>
    1b56:	mov    QWORD PTR [rsp+0x8],rax
    1b5b:	mov    r8,rax
    1b5e:	mov    QWORD PTR [rsp+0x28],rdx
    1b63:	mov    r14,rdx
    1b66:	lea    r9,[rsp+0x30]
    1b6b:	mov    rcx,rbx
    1b6e:	mov    rdx,r12
    1b71:	mov    rsi,QWORD PTR [rsp+0x50]
    1b76:	mov    rdi,r13
    1b79:	call   1b7e <botlish_fn_16+0x9b>
			1b7a: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    1b7e:	test   rax,rax
    1b81:	je     1d84 <botlish_fn_16+0x2a1>
    1b87:	mov    QWORD PTR [rsp+0x8],rax
    1b8c:	mov    QWORD PTR [rsp+0x68],rax
    1b91:	mov    rdx,QWORD PTR [rsp+0x30]
    1b96:	mov    QWORD PTR [rsp+0x10],rdx
    1b9b:	mov    QWORD PTR [rsp+0x60],rdx
    1ba0:	mov    rcx,QWORD PTR [rsp+0x38]
    1ba5:	mov    QWORD PTR [rsp+0x18],rcx
    1baa:	mov    QWORD PTR [rsp+0x58],rcx
    1baf:	lea    rcx,[rsp+0x40]
    1bb4:	mov    rdx,r14
    1bb7:	mov    rsi,r15
    1bba:	mov    rdi,r13
    1bbd:	call   1bc2 <botlish_fn_16+0xdf>
			1bbe: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1bc2:	test   rax,rax
    1bc5:	mov    QWORD PTR [rsp+0x50],rax
    1bca:	je     1d84 <botlish_fn_16+0x2a1>
    1bd0:	mov    r12,QWORD PTR [rsp+0x40]
    1bd5:	mov    rbx,QWORD PTR [rsp+0x48]
    1bda:	mov    rdi,r13
    1bdd:	mov    rcx,QWORD PTR [rdi+0x10]
    1be1:	mov    r8,QWORD PTR [rcx+0x18]
    1be5:	mov    rcx,rbx
    1be8:	mov    rdx,r12
    1beb:	mov    rsi,QWORD PTR [rsp+0x50]
    1bf0:	call   1bf5 <botlish_fn_16+0x112>
			1bf1: R_X86_64_PLT32	rt_str_region_eq-0x4
    1bf5:	cmp    rax,0x6
    1bf9:	je     1d13 <botlish_fn_16+0x230>
    1bff:	mov    rdi,r13
    1c02:	mov    rax,QWORD PTR [rdi+0x10]
    1c06:	mov    r8,QWORD PTR [rax+0x20]
    1c0a:	mov    rcx,rbx
    1c0d:	mov    rdx,r12
    1c10:	mov    rsi,QWORD PTR [rsp+0x50]
    1c15:	call   1c1a <botlish_fn_16+0x137>
			1c16: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c1a:	cmp    rax,0x6
    1c1e:	je     1c75 <botlish_fn_16+0x192>
    1c24:	mov    rcx,QWORD PTR [rsp+0x58]
    1c29:	mov    rdx,QWORD PTR [rsp+0x60]
    1c2e:	mov    rsi,QWORD PTR [rsp+0x68]
    1c33:	mov    rdi,r13
    1c36:	call   1c3b <botlish_fn_16+0x158>
			1c37: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1c3b:	test   rax,rax
    1c3e:	je     1d84 <botlish_fn_16+0x2a1>
    1c44:	mov    rdx,r14
    1c47:	mov    rbx,QWORD PTR [rsp+0x70]
    1c4c:	mov    r12,QWORD PTR [rsp+0x78]
    1c51:	mov    r13,QWORD PTR [rsp+0x80]
    1c59:	mov    r14,QWORD PTR [rsp+0x88]
    1c61:	mov    r15,QWORD PTR [rsp+0x90]
    1c69:	add    rsp,0xa0
    1c70:	mov    rsp,rbp
    1c73:	pop    rbp
    1c74:	ret
    1c75:	mov    rcx,QWORD PTR [rsp+0x58]
    1c7a:	mov    rdx,QWORD PTR [rsp+0x60]
    1c7f:	mov    rsi,QWORD PTR [rsp+0x68]
    1c84:	mov    rdi,r13
    1c87:	call   1c8c <botlish_fn_16+0x1a9>
			1c88: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1c8c:	test   rax,rax
    1c8f:	je     1d84 <botlish_fn_16+0x2a1>
    1c95:	mov    QWORD PTR [rsp],rax
    1c99:	mov    rbx,rax
    1c9c:	mov    QWORD PTR [rsp+0x8],0x3
    1ca5:	mov    rdx,r14
    1ca8:	test   rdx,0x1
    1caf:	je     1ccf <botlish_fn_16+0x1ec>
    1cb5:	mov    rdx,r14
    1cb8:	add    rdx,0x2
    1cbc:	seto   al
    1cbf:	test   al,al
    1cc1:	jne    1ccf <botlish_fn_16+0x1ec>
    1cc7:	mov    rax,rbx
    1cca:	jmp    1ce5 <botlish_fn_16+0x202>
    1ccf:	mov    edx,0x3
    1cd4:	mov    rsi,r14
    1cd7:	mov    rdi,r13
    1cda:	call   1cdf <botlish_fn_16+0x1fc>
			1cdb: R_X86_64_PLT32	rt_int_add-0x4
    1cdf:	mov    rdx,rax
    1ce2:	mov    rax,rbx
    1ce5:	mov    rbx,QWORD PTR [rsp+0x70]
    1cea:	mov    r12,QWORD PTR [rsp+0x78]
    1cef:	mov    r13,QWORD PTR [rsp+0x80]
    1cf7:	mov    r14,QWORD PTR [rsp+0x88]
    1cff:	mov    r15,QWORD PTR [rsp+0x90]
    1d07:	add    rsp,0xa0
    1d0e:	mov    rsp,rbp
    1d11:	pop    rbp
    1d12:	ret
    1d13:	mov    rsi,r14
    1d16:	mov    edx,0x3
    1d1b:	mov    rcx,rdx
    1d1e:	mov    QWORD PTR [rsp+0x20],0x3
    1d27:	test   rsi,0x1
    1d2e:	jne    1d3c <botlish_fn_16+0x259>
    1d34:	mov    rdx,rcx
    1d37:	jmp    1d51 <botlish_fn_16+0x26e>
    1d3c:	mov    rdx,rsi
    1d3f:	add    rdx,0x2
    1d43:	seto   al
    1d46:	test   al,al
    1d48:	je     1d5c <botlish_fn_16+0x279>
    1d4e:	mov    rdx,rcx
    1d51:	mov    rdi,r13
    1d54:	call   1d59 <botlish_fn_16+0x276>
			1d55: R_X86_64_PLT32	rt_int_add-0x4
    1d59:	mov    rdx,rax
    1d5c:	mov    QWORD PTR [rsp+0x20],rdx
    1d61:	mov    rcx,QWORD PTR [rsp+0x68]
    1d66:	mov    rsi,r15
    1d69:	mov    rdi,r13
    1d6c:	mov    r8,QWORD PTR [rsp+0x60]
    1d71:	mov    r9,QWORD PTR [rsp+0x58]
    1d76:	call   1d7b <botlish_fn_16+0x298>
			1d77: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    1d7b:	test   rax,rax
    1d7e:	jne    1db8 <botlish_fn_16+0x2d5>
    1d84:	xor    rdx,rdx
    1d87:	mov    rax,rdx
    1d8a:	mov    rbx,QWORD PTR [rsp+0x70]
    1d8f:	mov    r12,QWORD PTR [rsp+0x78]
    1d94:	mov    r13,QWORD PTR [rsp+0x80]
    1d9c:	mov    r14,QWORD PTR [rsp+0x88]
    1da4:	mov    r15,QWORD PTR [rsp+0x90]
    1dac:	add    rsp,0xa0
    1db3:	mov    rsp,rbp
    1db6:	pop    rbp
    1db7:	ret
    1db8:	mov    rbx,QWORD PTR [rsp+0x70]
    1dbd:	mov    r12,QWORD PTR [rsp+0x78]
    1dc2:	mov    r13,QWORD PTR [rsp+0x80]
    1dca:	mov    r14,QWORD PTR [rsp+0x88]
    1dd2:	mov    r15,QWORD PTR [rsp+0x90]
    1dda:	add    rsp,0xa0
    1de1:	mov    rsp,rbp
    1de4:	pop    rbp
    1de5:	ret

0000000000001de6 <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1de6:	push   rbp
    1de7:	mov    rbp,rsp
    1dea:	ud2

0000000000001dec <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    1dec:	push   rbp
    1ded:	mov    rbp,rsp
    1df0:	sub    rsp,0xb0
    1df7:	mov    QWORD PTR [rsp+0x80],rbx
    1dff:	mov    QWORD PTR [rsp+0x88],r12
    1e07:	mov    QWORD PTR [rsp+0x90],r13
    1e0f:	mov    QWORD PTR [rsp+0x98],r14
    1e17:	mov    QWORD PTR [rsp+0xa0],r15
    1e1f:	mov    QWORD PTR [rsp+0x50],rdi
    1e24:	mov    QWORD PTR [rsp+0x28],0x0
    1e2d:	mov    QWORD PTR [rsp],rsi
    1e31:	mov    QWORD PTR [rsp+0x8],rdx
    1e36:	mov    QWORD PTR [rsp+0x10],rcx
    1e3b:	mov    QWORD PTR [rsp+0x18],r8
    1e40:	mov    QWORD PTR [rsp+0x20],r9
    1e45:	lea    r15,[rsp+0x30]
    1e4a:	lea    rbx,[rsp+0x40]
    1e4f:	mov    r12,rsi
    1e52:	mov    r13,rcx
    1e55:	mov    QWORD PTR [rsp+0x58],r8
    1e5a:	mov    QWORD PTR [rsp+0x60],r9
    1e5f:	mov    rsi,r12
    1e62:	mov    rdi,QWORD PTR [rsp+0x50]
    1e67:	call   1e6c <botlish_fn_17+0x80>
			1e68: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1e6c:	mov    QWORD PTR [rsp+0x78],rdx
    1e71:	test   rax,rax
    1e74:	je     1fcf <botlish_fn_17+0x1e3>
    1e7a:	mov    QWORD PTR [rsp+0x8],rax
    1e7f:	mov    rdx,QWORD PTR [rsp+0x78]
    1e84:	mov    r8,rax
    1e87:	mov    QWORD PTR [rsp+0x28],rdx
    1e8c:	mov    rcx,QWORD PTR [rsp+0x60]
    1e91:	mov    rdx,QWORD PTR [rsp+0x58]
    1e96:	mov    rsi,r13
    1e99:	mov    rdi,QWORD PTR [rsp+0x50]
    1e9e:	mov    r9,r15
    1ea1:	call   1ea6 <botlish_fn_17+0xba>
			1ea2: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    1ea6:	test   rax,rax
    1ea9:	je     1fcf <botlish_fn_17+0x1e3>
    1eaf:	mov    QWORD PTR [rsp+0x8],rax
    1eb4:	mov    QWORD PTR [rsp+0x70],rax
    1eb9:	mov    rdx,QWORD PTR [rsp+0x30]
    1ebe:	mov    QWORD PTR [rsp+0x58],rdx
    1ec3:	mov    QWORD PTR [rsp+0x10],rdx
    1ec8:	mov    rcx,QWORD PTR [rsp+0x38]
    1ecd:	mov    QWORD PTR [rsp+0x18],rcx
    1ed2:	mov    QWORD PTR [rsp+0x60],rcx
    1ed7:	mov    rcx,rbx
    1eda:	mov    rdx,QWORD PTR [rsp+0x78]
    1edf:	mov    rsi,r12
    1ee2:	mov    rdi,QWORD PTR [rsp+0x50]
    1ee7:	call   1eec <botlish_fn_17+0x100>
			1ee8: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1eec:	test   rax,rax
    1eef:	mov    QWORD PTR [rsp+0x68],rax
    1ef4:	je     1fcf <botlish_fn_17+0x1e3>
    1efa:	mov    r13,QWORD PTR [rsp+0x40]
    1eff:	mov    r14,QWORD PTR [rsp+0x48]
    1f04:	mov    rdi,QWORD PTR [rsp+0x50]
    1f09:	mov    rcx,QWORD PTR [rdi+0x10]
    1f0d:	mov    r8,QWORD PTR [rcx+0x18]
    1f11:	mov    rcx,r14
    1f14:	mov    rdx,r13
    1f17:	mov    rsi,QWORD PTR [rsp+0x68]
    1f1c:	call   1f21 <botlish_fn_17+0x135>
			1f1d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f21:	cmp    rax,0x6
    1f25:	je     2095 <botlish_fn_17+0x2a9>
    1f2b:	mov    rdi,QWORD PTR [rsp+0x50]
    1f30:	mov    rax,QWORD PTR [rdi+0x10]
    1f34:	mov    r8,QWORD PTR [rax+0x20]
    1f38:	mov    rcx,r14
    1f3b:	mov    rdx,r13
    1f3e:	mov    rsi,QWORD PTR [rsp+0x68]
    1f43:	call   1f48 <botlish_fn_17+0x15c>
			1f44: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f48:	cmp    rax,0x6
    1f4c:	je     1fad <botlish_fn_17+0x1c1>
    1f52:	mov    rcx,QWORD PTR [rsp+0x60]
    1f57:	mov    rdx,QWORD PTR [rsp+0x58]
    1f5c:	mov    rsi,QWORD PTR [rsp+0x70]
    1f61:	mov    rdi,QWORD PTR [rsp+0x50]
    1f66:	call   1f6b <botlish_fn_17+0x17f>
			1f67: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1f6b:	test   rax,rax
    1f6e:	je     1fcf <botlish_fn_17+0x1e3>
    1f74:	mov    rdx,QWORD PTR [rsp+0x78]
    1f79:	mov    rbx,QWORD PTR [rsp+0x80]
    1f81:	mov    r12,QWORD PTR [rsp+0x88]
    1f89:	mov    r13,QWORD PTR [rsp+0x90]
    1f91:	mov    r14,QWORD PTR [rsp+0x98]
    1f99:	mov    r15,QWORD PTR [rsp+0xa0]
    1fa1:	add    rsp,0xb0
    1fa8:	mov    rsp,rbp
    1fab:	pop    rbp
    1fac:	ret
    1fad:	mov    rcx,QWORD PTR [rsp+0x60]
    1fb2:	mov    rdx,QWORD PTR [rsp+0x58]
    1fb7:	mov    rsi,QWORD PTR [rsp+0x70]
    1fbc:	mov    rdi,QWORD PTR [rsp+0x50]
    1fc1:	call   1fc6 <botlish_fn_17+0x1da>
			1fc2: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1fc6:	test   rax,rax
    1fc9:	jne    2009 <botlish_fn_17+0x21d>
    1fcf:	xor    rdx,rdx
    1fd2:	mov    rax,rdx
    1fd5:	mov    rbx,QWORD PTR [rsp+0x80]
    1fdd:	mov    r12,QWORD PTR [rsp+0x88]
    1fe5:	mov    r13,QWORD PTR [rsp+0x90]
    1fed:	mov    r14,QWORD PTR [rsp+0x98]
    1ff5:	mov    r15,QWORD PTR [rsp+0xa0]
    1ffd:	add    rsp,0xb0
    2004:	mov    rsp,rbp
    2007:	pop    rbp
    2008:	ret
    2009:	mov    QWORD PTR [rsp],rax
    200d:	mov    rbx,rax
    2010:	mov    QWORD PTR [rsp+0x8],0x3
    2019:	mov    rdx,QWORD PTR [rsp+0x78]
    201e:	test   rdx,0x1
    2025:	je     2047 <botlish_fn_17+0x25b>
    202b:	mov    rdx,QWORD PTR [rsp+0x78]
    2030:	add    rdx,0x2
    2034:	seto   al
    2037:	test   al,al
    2039:	jne    2047 <botlish_fn_17+0x25b>
    203f:	mov    rax,rbx
    2042:	jmp    2061 <botlish_fn_17+0x275>
    2047:	mov    edx,0x3
    204c:	mov    rsi,QWORD PTR [rsp+0x78]
    2051:	mov    rdi,QWORD PTR [rsp+0x50]
    2056:	call   205b <botlish_fn_17+0x26f>
			2057: R_X86_64_PLT32	rt_int_add-0x4
    205b:	mov    rdx,rax
    205e:	mov    rax,rbx
    2061:	mov    rbx,QWORD PTR [rsp+0x80]
    2069:	mov    r12,QWORD PTR [rsp+0x88]
    2071:	mov    r13,QWORD PTR [rsp+0x90]
    2079:	mov    r14,QWORD PTR [rsp+0x98]
    2081:	mov    r15,QWORD PTR [rsp+0xa0]
    2089:	add    rsp,0xb0
    2090:	mov    rsp,rbp
    2093:	pop    rbp
    2094:	ret
    2095:	mov    rsi,QWORD PTR [rsp+0x78]
    209a:	mov    edx,0x3
    209f:	mov    r10,rdx
    20a2:	mov    QWORD PTR [rsp+0x20],0x3
    20ab:	test   rsi,0x1
    20b2:	jne    20c0 <botlish_fn_17+0x2d4>
    20b8:	mov    rdx,r10
    20bb:	jmp    20d5 <botlish_fn_17+0x2e9>
    20c0:	mov    rdx,rsi
    20c3:	add    rdx,0x2
    20c7:	seto   al
    20ca:	test   al,al
    20cc:	je     20e2 <botlish_fn_17+0x2f6>
    20d2:	mov    rdx,r10
    20d5:	mov    rdi,QWORD PTR [rsp+0x50]
    20da:	call   20df <botlish_fn_17+0x2f3>
			20db: R_X86_64_PLT32	rt_int_add-0x4
    20df:	mov    rdx,rax
    20e2:	mov    QWORD PTR [rsp],r12
    20e6:	mov    QWORD PTR [rsp+0x8],rdx
    20eb:	mov    rsi,QWORD PTR [rsp+0x70]
    20f0:	mov    QWORD PTR [rsp+0x10],rsi
    20f5:	mov    rax,QWORD PTR [rsp+0x58]
    20fa:	mov    QWORD PTR [rsp+0x18],rax
    20ff:	mov    rcx,QWORD PTR [rsp+0x60]
    2104:	mov    QWORD PTR [rsp+0x20],rcx
    2109:	mov    r13,rsi
    210c:	jmp    1e5f <botlish_fn_17+0x73>

0000000000002111 <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2111:	push   rbp
    2112:	mov    rbp,rsp
    2115:	ud2

0000000000002117 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2117:	push   rbp
    2118:	mov    rbp,rsp
    211b:	sub    rsp,0xa0
    2122:	mov    QWORD PTR [rsp+0x70],rbx
    2127:	mov    QWORD PTR [rsp+0x78],r12
    212c:	mov    QWORD PTR [rsp+0x80],r13
    2134:	mov    QWORD PTR [rsp+0x88],r14
    213c:	mov    QWORD PTR [rsp+0x90],r15
    2144:	mov    r12,rdi
    2147:	mov    QWORD PTR [rsp+0x28],0x0
    2150:	mov    QWORD PTR [rsp+0x30],0x0
    2159:	mov    QWORD PTR [rsp+0x38],0x0
    2162:	mov    QWORD PTR [rsp],rsi
    2166:	mov    rbx,rsi
    2169:	mov    QWORD PTR [rsp+0x8],rdx
    216e:	mov    QWORD PTR [rsp+0x60],rdx
    2173:	mov    QWORD PTR [rsp+0x10],rcx
    2178:	mov    r15,rcx
    217b:	mov    QWORD PTR [rsp+0x18],r8
    2180:	mov    r14,r8
    2183:	mov    QWORD PTR [rsp+0x20],r9
    2188:	mov    r13,r9
    218b:	mov    rsi,rbx
    218e:	mov    rdi,r12
    2191:	call   2196 <botlish_fn_18+0x7f>
			2192: R_X86_64_PLT32	rt_str_len-0x4
    2196:	mov    rdx,QWORD PTR [rsp+0x60]
    219b:	mov    rcx,rdx
    219e:	sar    rcx,1
    21a1:	sar    rax,1
    21a4:	cmp    rcx,rax
    21a7:	jge    228c <botlish_fn_18+0x175>
    21ad:	lea    rsi,[rsp+0x40]
    21b2:	mov    rdi,r12
    21b5:	call   21ba <botlish_fn_18+0xa3>
			21b6: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    21ba:	test   rax,rax
    21bd:	je     22a6 <botlish_fn_18+0x18f>
    21c3:	mov    QWORD PTR [rsp+0x28],rax
    21c8:	mov    rcx,rax
    21cb:	mov    r8,QWORD PTR [rsp+0x40]
    21d0:	mov    QWORD PTR [rsp+0x30],r8
    21d5:	mov    r9,QWORD PTR [rsp+0x48]
    21da:	mov    QWORD PTR [rsp+0x38],r9
    21df:	mov    rdx,QWORD PTR [rsp+0x60]
    21e4:	mov    rsi,rbx
    21e7:	mov    rdi,r12
    21ea:	call   21ef <botlish_fn_18+0xd8>
			21eb: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    21ef:	test   rax,rax
    21f2:	je     22a6 <botlish_fn_18+0x18f>
    21f8:	mov    QWORD PTR [rsp+0x8],rax
    21fd:	mov    r8,rax
    2200:	mov    QWORD PTR [rsp+0x28],rdx
    2205:	mov    QWORD PTR [rsp+0x60],rdx
    220a:	lea    r9,[rsp+0x50]
    220f:	mov    rcx,r13
    2212:	mov    rdx,r14
    2215:	mov    rsi,r15
    2218:	mov    rdi,r12
    221b:	call   2220 <botlish_fn_18+0x109>
			221c: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    2220:	test   rax,rax
    2223:	je     22a6 <botlish_fn_18+0x18f>
    2229:	mov    QWORD PTR [rsp+0x8],rax
    222e:	mov    rcx,rax
    2231:	mov    r8,QWORD PTR [rsp+0x50]
    2236:	mov    QWORD PTR [rsp+0x10],r8
    223b:	mov    r9,QWORD PTR [rsp+0x58]
    2240:	mov    QWORD PTR [rsp+0x18],r9
    2245:	mov    rdx,QWORD PTR [rsp+0x60]
    224a:	mov    rsi,rbx
    224d:	mov    rdi,r12
    2250:	call   2255 <botlish_fn_18+0x13e>
			2251: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2255:	test   rax,rax
    2258:	je     22a6 <botlish_fn_18+0x18f>
    225e:	mov    rbx,QWORD PTR [rsp+0x70]
    2263:	mov    r12,QWORD PTR [rsp+0x78]
    2268:	mov    r13,QWORD PTR [rsp+0x80]
    2270:	mov    r14,QWORD PTR [rsp+0x88]
    2278:	mov    r15,QWORD PTR [rsp+0x90]
    2280:	add    rsp,0xa0
    2287:	mov    rsp,rbp
    228a:	pop    rbp
    228b:	ret
    228c:	mov    rcx,r13
    228f:	mov    rdx,r14
    2292:	mov    rsi,r15
    2295:	mov    rdi,r12
    2298:	call   229d <botlish_fn_18+0x186>
			2299: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    229d:	test   rax,rax
    22a0:	jne    22d7 <botlish_fn_18+0x1c0>
    22a6:	xor    rax,rax
    22a9:	mov    rbx,QWORD PTR [rsp+0x70]
    22ae:	mov    r12,QWORD PTR [rsp+0x78]
    22b3:	mov    r13,QWORD PTR [rsp+0x80]
    22bb:	mov    r14,QWORD PTR [rsp+0x88]
    22c3:	mov    r15,QWORD PTR [rsp+0x90]
    22cb:	add    rsp,0xa0
    22d2:	mov    rsp,rbp
    22d5:	pop    rbp
    22d6:	ret
    22d7:	mov    rbx,QWORD PTR [rsp+0x70]
    22dc:	mov    r12,QWORD PTR [rsp+0x78]
    22e1:	mov    r13,QWORD PTR [rsp+0x80]
    22e9:	mov    r14,QWORD PTR [rsp+0x88]
    22f1:	mov    r15,QWORD PTR [rsp+0x90]
    22f9:	add    rsp,0xa0
    2300:	mov    rsp,rbp
    2303:	pop    rbp
    2304:	ret

0000000000002305 <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2305:	push   rbp
    2306:	mov    rbp,rsp
    2309:	mov    rsi,QWORD PTR [rdx]
    230c:	mov    r10,QWORD PTR [rdx+0x8]
    2310:	mov    rcx,QWORD PTR [rdx+0x10]
    2314:	mov    r8,QWORD PTR [rdx+0x18]
    2318:	mov    r9,QWORD PTR [rdx+0x20]
    231c:	mov    rdx,r10
    231f:	call   2324 <botlish_entry_18+0x1f>
			2320: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2324:	mov    rsp,rbp
    2327:	pop    rbp
    2328:	ret
    2329:	add    BYTE PTR [rax],al
    232b:	add    BYTE PTR [rax],al
    232d:	add    BYTE PTR [rax],al
	...

0000000000002330 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2330:	push   rbp
    2331:	mov    rbp,rsp
    2334:	sub    rsp,0xb0
    233b:	mov    QWORD PTR [rsp+0x80],rbx
    2343:	mov    QWORD PTR [rsp+0x88],r12
    234b:	mov    QWORD PTR [rsp+0x90],r13
    2353:	mov    QWORD PTR [rsp+0x98],r14
    235b:	mov    QWORD PTR [rsp+0xa0],r15
    2363:	mov    r15,rdi
    2366:	mov    QWORD PTR [rsp+0x28],0x0
    236f:	mov    QWORD PTR [rsp+0x30],0x0
    2378:	mov    QWORD PTR [rsp+0x38],0x0
    2381:	mov    QWORD PTR [rsp],rsi
    2385:	mov    QWORD PTR [rsp+0x8],rdx
    238a:	mov    r14,rdx
    238d:	mov    QWORD PTR [rsp+0x10],rcx
    2392:	mov    QWORD PTR [rsp+0x18],r8
    2397:	mov    QWORD PTR [rsp+0x20],r9
    239c:	lea    r13,[rsp+0x40]
    23a1:	lea    rbx,[rsp+0x50]
    23a6:	mov    r12,rsi
    23a9:	mov    QWORD PTR [rsp+0x60],rcx
    23ae:	mov    QWORD PTR [rsp+0x68],r8
    23b3:	mov    QWORD PTR [rsp+0x70],r9
    23b8:	mov    rsi,r12
    23bb:	mov    rdi,r15
    23be:	call   23c3 <botlish_fn_19+0x93>
			23bf: R_X86_64_PLT32	rt_str_len-0x4
    23c3:	mov    rcx,r14
    23c6:	and    rcx,rax
    23c9:	mov    rdx,rax
    23cc:	test   rcx,0x1
    23d3:	jne    23f9 <botlish_fn_19+0xc9>
    23d9:	mov    rsi,r14
    23dc:	mov    rdi,r15
    23df:	call   23e4 <botlish_fn_19+0xb4>
			23e0: R_X86_64_PLT32	rt_int_cmp-0x4
    23e4:	mov    ecx,0x2
    23e9:	test   rax,rax
    23ec:	cmovge rcx,QWORD PTR [rip+0x164]        # 2558 <botlish_fn_19+0x228>
    23f4:	jmp    240c <botlish_fn_19+0xdc>
    23f9:	mov    ecx,0x2
    23fe:	mov    rdi,r14
    2401:	cmp    rdi,rdx
    2404:	cmovge rcx,QWORD PTR [rip+0x14c]        # 2558 <botlish_fn_19+0x228>
    240c:	cmp    rcx,0x6
    2410:	je     24c9 <botlish_fn_19+0x199>
    2416:	mov    rsi,r13
    2419:	mov    rdi,r15
    241c:	call   2421 <botlish_fn_19+0xf1>
			241d: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2421:	test   rax,rax
    2424:	je     24e9 <botlish_fn_19+0x1b9>
    242a:	mov    QWORD PTR [rsp+0x28],rax
    242f:	mov    rcx,rax
    2432:	mov    r8,QWORD PTR [rsp+0x40]
    2437:	mov    QWORD PTR [rsp+0x30],r8
    243c:	mov    r9,QWORD PTR [rsp+0x48]
    2441:	mov    QWORD PTR [rsp+0x38],r9
    2446:	mov    rdx,r14
    2449:	mov    rsi,r12
    244c:	mov    rdi,r15
    244f:	call   2454 <botlish_fn_19+0x124>
			2450: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2454:	test   rax,rax
    2457:	je     24e9 <botlish_fn_19+0x1b9>
    245d:	mov    QWORD PTR [rsp+0x8],rax
    2462:	mov    r8,rax
    2465:	mov    QWORD PTR [rsp+0x28],rdx
    246a:	mov    r14,rdx
    246d:	mov    rsi,QWORD PTR [rsp+0x60]
    2472:	mov    rdx,QWORD PTR [rsp+0x68]
    2477:	mov    rcx,QWORD PTR [rsp+0x70]
    247c:	mov    rdi,r15
    247f:	mov    r9,rbx
    2482:	call   2487 <botlish_fn_19+0x157>
			2483: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    2487:	test   rax,rax
    248a:	je     24e9 <botlish_fn_19+0x1b9>
    2490:	mov    rdx,QWORD PTR [rsp+0x50]
    2495:	mov    rcx,QWORD PTR [rsp+0x58]
    249a:	mov    QWORD PTR [rsp],r12
    249e:	mov    rsi,r14
    24a1:	mov    QWORD PTR [rsp+0x8],rsi
    24a6:	mov    QWORD PTR [rsp+0x10],rax
    24ab:	mov    QWORD PTR [rsp+0x18],rdx
    24b0:	mov    QWORD PTR [rsp+0x20],rcx
    24b5:	mov    QWORD PTR [rsp+0x60],rax
    24ba:	mov    QWORD PTR [rsp+0x68],rdx
    24bf:	mov    QWORD PTR [rsp+0x70],rcx
    24c4:	jmp    23b8 <botlish_fn_19+0x88>
    24c9:	mov    rcx,QWORD PTR [rsp+0x70]
    24ce:	mov    rdx,QWORD PTR [rsp+0x68]
    24d3:	mov    rsi,QWORD PTR [rsp+0x60]
    24d8:	mov    rdi,r15
    24db:	call   24e0 <botlish_fn_19+0x1b0>
			24dc: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    24e0:	test   rax,rax
    24e3:	jne    2520 <botlish_fn_19+0x1f0>
    24e9:	xor    rax,rax
    24ec:	mov    rbx,QWORD PTR [rsp+0x80]
    24f4:	mov    r12,QWORD PTR [rsp+0x88]
    24fc:	mov    r13,QWORD PTR [rsp+0x90]
    2504:	mov    r14,QWORD PTR [rsp+0x98]
    250c:	mov    r15,QWORD PTR [rsp+0xa0]
    2514:	add    rsp,0xb0
    251b:	mov    rsp,rbp
    251e:	pop    rbp
    251f:	ret
    2520:	mov    rbx,QWORD PTR [rsp+0x80]
    2528:	mov    r12,QWORD PTR [rsp+0x88]
    2530:	mov    r13,QWORD PTR [rsp+0x90]
    2538:	mov    r14,QWORD PTR [rsp+0x98]
    2540:	mov    r15,QWORD PTR [rsp+0xa0]
    2548:	add    rsp,0xb0
    254f:	mov    rsp,rbp
    2552:	pop    rbp
    2553:	ret
    2554:	add    BYTE PTR [rax],al
    2556:	add    BYTE PTR [rax],al
    2558:	(bad)
    2559:	add    BYTE PTR [rax],al
    255b:	add    BYTE PTR [rax],al
    255d:	add    BYTE PTR [rax],al
	...

0000000000002560 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2560:	push   rbp
    2561:	mov    rbp,rsp
    2564:	mov    rsi,QWORD PTR [rdx]
    2567:	mov    r10,QWORD PTR [rdx+0x8]
    256b:	mov    rcx,QWORD PTR [rdx+0x10]
    256f:	mov    r8,QWORD PTR [rdx+0x18]
    2573:	mov    r9,QWORD PTR [rdx+0x20]
    2577:	mov    rdx,r10
    257a:	call   257f <botlish_entry_19+0x1f>
			257b: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    257f:	mov    rsp,rbp
    2582:	pop    rbp
    2583:	ret

0000000000002584 <botlish_fn_20: csv_parse<str>>:
    2584:	push   rbp
    2585:	mov    rbp,rsp
    2588:	sub    rsp,0x50
    258c:	mov    QWORD PTR [rsp+0x40],r12
    2591:	mov    QWORD PTR [rsp+0x48],r13
    2596:	mov    r13,rdi
    2599:	mov    QWORD PTR [rsp+0x10],0x0
    25a2:	mov    QWORD PTR [rsp+0x18],0x0
    25ab:	mov    QWORD PTR [rsp+0x20],0x0
    25b4:	mov    QWORD PTR [rsp],rsi
    25b8:	mov    r12,rsi
    25bb:	mov    QWORD PTR [rsp+0x8],0x1
    25c4:	lea    rsi,[rsp+0x28]
    25c9:	mov    rdi,r13
    25cc:	call   25d1 <botlish_fn_20+0x4d>
			25cd: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    25d1:	test   rax,rax
    25d4:	je     260f <botlish_fn_20+0x8b>
    25da:	mov    QWORD PTR [rsp+0x10],rax
    25df:	mov    rcx,rax
    25e2:	mov    r8,QWORD PTR [rsp+0x28]
    25e7:	mov    QWORD PTR [rsp+0x18],r8
    25ec:	mov    r9,QWORD PTR [rsp+0x30]
    25f1:	mov    QWORD PTR [rsp+0x20],r9
    25f6:	mov    edx,0x1
    25fb:	mov    rsi,r12
    25fe:	mov    rdi,r13
    2601:	call   2606 <botlish_fn_20+0x82>
			2602: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2606:	test   rax,rax
    2609:	jne    2625 <botlish_fn_20+0xa1>
    260f:	xor    rax,rax
    2612:	mov    r12,QWORD PTR [rsp+0x40]
    2617:	mov    r13,QWORD PTR [rsp+0x48]
    261c:	add    rsp,0x50
    2620:	mov    rsp,rbp
    2623:	pop    rbp
    2624:	ret
    2625:	mov    r12,QWORD PTR [rsp+0x40]
    262a:	mov    r13,QWORD PTR [rsp+0x48]
    262f:	add    rsp,0x50
    2633:	mov    rsp,rbp
    2636:	pop    rbp
    2637:	ret

0000000000002638 <botlish_entry_20: csv_parse<str>>:
    2638:	push   rbp
    2639:	mov    rbp,rsp
    263c:	mov    rsi,QWORD PTR [rdx]
    263f:	call   2644 <botlish_entry_20+0xc>
			2640: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    2644:	mov    rsp,rbp
    2647:	pop    rbp
    2648:	ret

; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6706  (per function: 181 78 357 533 402 402 81 365 430 703 925 482 890 592 285)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> geo_new_capacity<int, int>
;   botlish_fn_3 / botlish_entry_3 -> geo_grow<mutarray, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_append<list[mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> geo_append<list[mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> geo_finish<list[mutarray, int]>
;   botlish_fn_7 / botlish_entry_7 -> peek<str, int>
;   botlish_fn_8 / botlish_entry_8 -> peek<str, int>
;   botlish_fn_9 / botlish_entry_9 -> scan_unquoted<str, int, int>
;   botlish_fn_10 / botlish_entry_10 -> scan_quoted<str, int, str>
;   botlish_fn_11 / botlish_entry_11 -> scan_field<str, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_record<str, int, list[mutarray, int]>
;   botlish_fn_13 / botlish_entry_13 -> scan_records<str, int, list[mutarray, int]>
;   botlish_fn_14 / botlish_entry_14 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


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
      20:	ja     86 <botlish_fn_0+0x86>
      26:	lea    rax,[r13+0x8]
      2a:	mov    QWORD PTR [rdi],rax
      2d:	mov    QWORD PTR [r13+0x0],0x0
      35:	mov    rax,QWORD PTR [rdi+0x10]
      39:	mov    r14,rdi
      3c:	mov    rsi,QWORD PTR [rax]
      3f:	mov    QWORD PTR [rsp],rsi
      43:	call   48 <botlish_fn_0+0x48>
			44: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
      48:	test   rax,rax
      4b:	jne    6d <botlish_fn_0+0x6d>
      51:	mov    rdi,r14
      54:	mov    QWORD PTR [rdi],r13
      57:	xor    rax,rax
      5a:	mov    r13,QWORD PTR [rsp+0x10]
      5f:	mov    r14,QWORD PTR [rsp+0x18]
      64:	add    rsp,0x20
      68:	mov    rsp,rbp
      6b:	pop    rbp
      6c:	ret
      6d:	mov    rdi,r14
      70:	mov    QWORD PTR [rdi],r13
      73:	mov    r13,QWORD PTR [rsp+0x10]
      78:	mov    r14,QWORD PTR [rsp+0x18]
      7d:	add    rsp,0x20
      81:	mov    rsp,rbp
      84:	pop    rbp
      85:	ret
      86:	call   8b <botlish_fn_0+0x8b>
			87: R_X86_64_PLT32	rt_stack_overflow-0x4
      8b:	xor    rax,rax
      8e:	mov    r13,QWORD PTR [rsp+0x10]
      93:	mov    r14,QWORD PTR [rsp+0x18]
      98:	add    rsp,0x20
      9c:	mov    rsp,rbp
      9f:	pop    rbp
      a0:	ret

00000000000000a1 <botlish_entry_0: <program entry>>:
      a1:	push   rbp
      a2:	mov    rbp,rsp
      a5:	call   aa <botlish_entry_0+0x9>
			a6: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      aa:	mov    rsp,rbp
      ad:	pop    rbp
      ae:	ret

00000000000000af <botlish_fn_1: geo_new<generic>>:
      af:	push   rbp
      b0:	mov    rbp,rsp
      b3:	sub    rsp,0x10
      b7:	mov    esi,0x1
      bc:	mov    QWORD PTR [rsp],0x1
      c4:	call   c9 <botlish_fn_1+0x1a>
			c5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      c9:	test   rax,rax
      cc:	jne    e1 <botlish_fn_1+0x32>
      d2:	xor    rdx,rdx
      d5:	mov    rax,rdx
      d8:	add    rsp,0x10
      dc:	mov    rsp,rbp
      df:	pop    rbp
      e0:	ret
      e1:	mov    edx,0x1
      e6:	add    rsp,0x10
      ea:	mov    rsp,rbp
      ed:	pop    rbp
      ee:	ret

00000000000000ef <botlish_entry_1: geo_new<generic>>:
      ef:	push   rbp
      f0:	mov    rbp,rsp
      f3:	ud2
      f5:	add    BYTE PTR [rax],al
	...

00000000000000f8 <botlish_fn_2: geo_new_capacity<int, int>>:
      f8:	push   rbp
      f9:	mov    rbp,rsp
      fc:	sub    rsp,0x40
     100:	mov    QWORD PTR [rsp+0x20],rbx
     105:	mov    QWORD PTR [rsp+0x28],r12
     10a:	mov    QWORD PTR [rsp+0x30],r13
     10f:	mov    r12,rdi
     112:	mov    QWORD PTR [rsp],rsi
     116:	mov    QWORD PTR [rsp+0x8],rdx
     11b:	mov    rbx,rdx
     11e:	mov    QWORD PTR [rsp+0x10],0x5
     127:	test   rsi,0x1
     12e:	je     150 <botlish_fn_2+0x58>
     134:	mov    rax,rsi
     137:	sar    rax,1
     13a:	imul   QWORD PTR [rip+0xdf]        # 220 <botlish_fn_2+0x128>
     141:	seto   cl
     144:	or     rax,0x1
     148:	test   cl,cl
     14a:	je     15d <botlish_fn_2+0x65>
     150:	mov    edx,0x5
     155:	mov    rdi,r12
     158:	call   15d <botlish_fn_2+0x65>
			159: R_X86_64_PLT32	rt_int_mul-0x4
     15d:	mov    rcx,rax
     160:	and    rcx,rbx
     163:	mov    r13,rax
     166:	test   rcx,0x1
     16d:	jne    199 <botlish_fn_2+0xa1>
     173:	mov    rdx,rbx
     176:	mov    rsi,r13
     179:	mov    rdi,r12
     17c:	call   181 <botlish_fn_2+0x89>
			17d: R_X86_64_PLT32	rt_int_cmp-0x4
     181:	mov    ecx,0x2
     186:	test   rax,rax
     189:	cmovle rcx,QWORD PTR [rip+0x97]        # 228 <botlish_fn_2+0x130>
     191:	mov    rax,r13
     194:	jmp    1ac <botlish_fn_2+0xb4>
     199:	mov    ecx,0x2
     19e:	mov    rax,r13
     1a1:	cmp    rax,rbx
     1a4:	cmovle rcx,QWORD PTR [rip+0x7c]        # 228 <botlish_fn_2+0x130>
     1ac:	cmp    rcx,0x6
     1b0:	je     1ce <botlish_fn_2+0xd6>
     1b6:	mov    rbx,QWORD PTR [rsp+0x20]
     1bb:	mov    r12,QWORD PTR [rsp+0x28]
     1c0:	mov    r13,QWORD PTR [rsp+0x30]
     1c5:	add    rsp,0x40
     1c9:	mov    rsp,rbp
     1cc:	pop    rbp
     1cd:	ret
     1ce:	mov    QWORD PTR [rsp],0x3
     1d6:	test   rbx,0x1
     1dd:	je     1f5 <botlish_fn_2+0xfd>
     1e3:	mov    rax,rbx
     1e6:	add    rax,0x2
     1ea:	seto   cl
     1ed:	test   cl,cl
     1ef:	je     205 <botlish_fn_2+0x10d>
     1f5:	mov    edx,0x3
     1fa:	mov    rsi,rbx
     1fd:	mov    rdi,r12
     200:	call   205 <botlish_fn_2+0x10d>
			201: R_X86_64_PLT32	rt_int_add-0x4
     205:	mov    rbx,QWORD PTR [rsp+0x20]
     20a:	mov    r12,QWORD PTR [rsp+0x28]
     20f:	mov    r13,QWORD PTR [rsp+0x30]
     214:	add    rsp,0x40
     218:	mov    rsp,rbp
     21b:	pop    rbp
     21c:	ret
     21d:	add    BYTE PTR [rax],al
     21f:	add    BYTE PTR [rax+rax*1],al
     222:	add    BYTE PTR [rax],al
     224:	add    BYTE PTR [rax],al
     226:	add    BYTE PTR [rax],al
     228:	(bad)
     229:	add    BYTE PTR [rax],al
     22b:	add    BYTE PTR [rax],al
     22d:	add    BYTE PTR [rax],al
	...

0000000000000230 <botlish_entry_2: geo_new_capacity<int, int>>:
     230:	push   rbp
     231:	mov    rbp,rsp
     234:	mov    rsi,QWORD PTR [rdx]
     237:	mov    rdx,QWORD PTR [rdx+0x8]
     23b:	call   240 <botlish_entry_2+0x10>
			23c: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     240:	mov    rsp,rbp
     243:	pop    rbp
     244:	ret
     245:	add    BYTE PTR [rax],al
	...

0000000000000248 <botlish_fn_3: geo_grow<mutarray, int>>:
     248:	push   rbp
     249:	mov    rbp,rsp
     24c:	sub    rsp,0x50
     250:	mov    QWORD PTR [rsp+0x20],rbx
     255:	mov    QWORD PTR [rsp+0x28],r12
     25a:	mov    QWORD PTR [rsp+0x30],r13
     25f:	mov    QWORD PTR [rsp+0x38],r14
     264:	mov    QWORD PTR [rsp+0x40],r15
     269:	mov    rbx,QWORD PTR [rdi]
     26c:	mov    rax,QWORD PTR [rdi+0x8]
     270:	lea    rcx,[rbx+0x8]
     274:	cmp    rcx,rax
     277:	ja     3f0 <botlish_fn_3+0x1a8>
     27d:	lea    rax,[rbx+0x8]
     281:	mov    QWORD PTR [rdi],rax
     284:	mov    r13,rdi
     287:	mov    QWORD PTR [rbx],0x0
     28e:	mov    QWORD PTR [rsp],rsi
     292:	mov    r14,rsi
     295:	mov    QWORD PTR [rsp+0x8],rdx
     29a:	mov    r12,rdx
     29d:	mov    rsi,r14
     2a0:	mov    rdi,r13
     2a3:	call   2a8 <botlish_fn_3+0x60>
			2a4: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     2a8:	mov    r15,rax
     2ab:	mov    QWORD PTR [rsp+0x10],rax
     2b0:	mov    rcx,r12
     2b3:	and    rcx,rax
     2b6:	test   rcx,0x1
     2bd:	jne    2e9 <botlish_fn_3+0xa1>
     2c3:	mov    rdx,r15
     2c6:	mov    rsi,r12
     2c9:	mov    rdi,r13
     2cc:	call   2d1 <botlish_fn_3+0x89>
			2cd: R_X86_64_PLT32	rt_int_cmp-0x4
     2d1:	mov    ecx,0x2
     2d6:	test   rax,rax
     2d9:	cmovl  rcx,QWORD PTR [rip+0x13f]        # 420 <botlish_fn_3+0x1d8>
     2e1:	mov    rax,r15
     2e4:	jmp    2fc <botlish_fn_3+0xb4>
     2e9:	mov    ecx,0x2
     2ee:	mov    rax,r15
     2f1:	cmp    r12,rax
     2f4:	cmovl  rcx,QWORD PTR [rip+0x124]        # 420 <botlish_fn_3+0x1d8>
     2fc:	cmp    rcx,0x6
     300:	je     3c5 <botlish_fn_3+0x17d>
     306:	mov    rsi,rax
     309:	mov    rdx,r12
     30c:	mov    rdi,r13
     30f:	call   314 <botlish_fn_3+0xcc>
			310: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     314:	test   rax,rax
     317:	jne    325 <botlish_fn_3+0xdd>
     31d:	mov    rdi,r13
     320:	jmp    36f <botlish_fn_3+0x127>
     325:	mov    QWORD PTR [rsp+0x10],rax
     32a:	mov    rsi,rax
     32d:	mov    rdi,r13
     330:	call   335 <botlish_fn_3+0xed>
			331: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     335:	test   rax,rax
     338:	mov    r15,rax
     33b:	jne    349 <botlish_fn_3+0x101>
     341:	mov    rdi,r13
     344:	jmp    36f <botlish_fn_3+0x127>
     349:	mov    r8d,0x1
     34f:	mov    rcx,r14
     352:	mov    r9,r12
     355:	mov    rsi,r15
     358:	mov    rdi,r13
     35b:	mov    rdx,r8
     35e:	call   363 <botlish_fn_3+0x11b>
			35f: R_X86_64_PLT32	rt_mutarray_copy-0x4
     363:	test   rax,rax
     366:	jne    39a <botlish_fn_3+0x152>
     36c:	mov    rdi,r13
     36f:	mov    rdi,r13
     372:	mov    QWORD PTR [rdi],rbx
     375:	xor    rax,rax
     378:	mov    rbx,QWORD PTR [rsp+0x20]
     37d:	mov    r12,QWORD PTR [rsp+0x28]
     382:	mov    r13,QWORD PTR [rsp+0x30]
     387:	mov    r14,QWORD PTR [rsp+0x38]
     38c:	mov    r15,QWORD PTR [rsp+0x40]
     391:	add    rsp,0x50
     395:	mov    rsp,rbp
     398:	pop    rbp
     399:	ret
     39a:	mov    rdi,r13
     39d:	mov    QWORD PTR [rdi],rbx
     3a0:	mov    rax,r15
     3a3:	mov    rbx,QWORD PTR [rsp+0x20]
     3a8:	mov    r12,QWORD PTR [rsp+0x28]
     3ad:	mov    r13,QWORD PTR [rsp+0x30]
     3b2:	mov    r14,QWORD PTR [rsp+0x38]
     3b7:	mov    r15,QWORD PTR [rsp+0x40]
     3bc:	add    rsp,0x50
     3c0:	mov    rsp,rbp
     3c3:	pop    rbp
     3c4:	ret
     3c5:	mov    rdi,r13
     3c8:	mov    QWORD PTR [rdi],rbx
     3cb:	mov    rax,r14
     3ce:	mov    rbx,QWORD PTR [rsp+0x20]
     3d3:	mov    r12,QWORD PTR [rsp+0x28]
     3d8:	mov    r13,QWORD PTR [rsp+0x30]
     3dd:	mov    r14,QWORD PTR [rsp+0x38]
     3e2:	mov    r15,QWORD PTR [rsp+0x40]
     3e7:	add    rsp,0x50
     3eb:	mov    rsp,rbp
     3ee:	pop    rbp
     3ef:	ret
     3f0:	mov    r13,rdi
     3f3:	call   3f8 <botlish_fn_3+0x1b0>
			3f4: R_X86_64_PLT32	rt_stack_overflow-0x4
     3f8:	xor    rax,rax
     3fb:	mov    rbx,QWORD PTR [rsp+0x20]
     400:	mov    r12,QWORD PTR [rsp+0x28]
     405:	mov    r13,QWORD PTR [rsp+0x30]
     40a:	mov    r14,QWORD PTR [rsp+0x38]
     40f:	mov    r15,QWORD PTR [rsp+0x40]
     414:	add    rsp,0x50
     418:	mov    rsp,rbp
     41b:	pop    rbp
     41c:	ret
     41d:	add    BYTE PTR [rax],al
     41f:	add    BYTE PTR [rsi],al
     421:	add    BYTE PTR [rax],al
     423:	add    BYTE PTR [rax],al
     425:	add    BYTE PTR [rax],al
	...

0000000000000428 <botlish_entry_3: geo_grow<mutarray, int>>:
     428:	push   rbp
     429:	mov    rbp,rsp
     42c:	mov    rsi,QWORD PTR [rdx]
     42f:	mov    rdx,QWORD PTR [rdx+0x8]
     433:	call   438 <botlish_entry_3+0x10>
			434: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     438:	mov    rsp,rbp
     43b:	pop    rbp
     43c:	ret

000000000000043d <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     43d:	push   rbp
     43e:	mov    rbp,rsp
     441:	sub    rsp,0x40
     445:	mov    QWORD PTR [rsp+0x20],rbx
     44a:	mov    QWORD PTR [rsp+0x28],r12
     44f:	mov    QWORD PTR [rsp+0x30],r13
     454:	mov    QWORD PTR [rsp+0x38],r14
     459:	mov    rbx,QWORD PTR [rdi]
     45c:	mov    rax,QWORD PTR [rdi+0x8]
     460:	lea    r8,[rbx+0x8]
     464:	cmp    r8,rax
     467:	ja     575 <botlish_fn_4+0x138>
     46d:	lea    rax,[rbx+0x8]
     471:	mov    QWORD PTR [rdi],rax
     474:	mov    r13,rdi
     477:	mov    QWORD PTR [rbx],0x0
     47e:	mov    QWORD PTR [rsp],rsi
     482:	mov    QWORD PTR [rsp+0x8],rdx
     487:	mov    rdi,rdx
     48a:	mov    QWORD PTR [rsp+0x10],rcx
     48f:	mov    r14,rcx
     492:	mov    r12,rdi
     495:	mov    rdx,r12
     498:	mov    rdi,r13
     49b:	call   4a0 <botlish_fn_4+0x63>
			49c: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     4a0:	test   rax,rax
     4a3:	jne    4b1 <botlish_fn_4+0x74>
     4a9:	mov    rdi,r13
     4ac:	jmp    4d5 <botlish_fn_4+0x98>
     4b1:	mov    QWORD PTR [rsp],rax
     4b5:	mov    rcx,r14
     4b8:	mov    r14,rax
     4bb:	mov    rdx,r12
     4be:	mov    rsi,r14
     4c1:	mov    rdi,r13
     4c4:	call   4c9 <botlish_fn_4+0x8c>
			4c5: R_X86_64_PLT32	rt_mutarray_set-0x4
     4c9:	test   rax,rax
     4cc:	jne    4fe <botlish_fn_4+0xc1>
     4d2:	mov    rdi,r13
     4d5:	mov    rdi,r13
     4d8:	mov    QWORD PTR [rdi],rbx
     4db:	xor    rdx,rdx
     4de:	mov    rax,rdx
     4e1:	mov    rbx,QWORD PTR [rsp+0x20]
     4e6:	mov    r12,QWORD PTR [rsp+0x28]
     4eb:	mov    r13,QWORD PTR [rsp+0x30]
     4f0:	mov    r14,QWORD PTR [rsp+0x38]
     4f5:	add    rsp,0x40
     4f9:	mov    rsp,rbp
     4fc:	pop    rbp
     4fd:	ret
     4fe:	mov    QWORD PTR [rsp+0x10],0x3
     507:	test   r12,0x1
     50e:	jne    51c <botlish_fn_4+0xdf>
     514:	mov    rdi,r12
     517:	jmp    539 <botlish_fn_4+0xfc>
     51c:	mov    rdx,r12
     51f:	add    rdx,0x2
     523:	mov    rdi,r12
     526:	seto   al
     529:	test   al,al
     52b:	jne    539 <botlish_fn_4+0xfc>
     531:	mov    rdi,r13
     534:	jmp    54f <botlish_fn_4+0x112>
     539:	mov    edx,0x3
     53e:	mov    rsi,rdi
     541:	mov    rdi,r13
     544:	call   549 <botlish_fn_4+0x10c>
			545: R_X86_64_PLT32	rt_int_add-0x4
     549:	mov    rdx,rax
     54c:	mov    rdi,r13
     54f:	mov    rdi,r13
     552:	mov    QWORD PTR [rdi],rbx
     555:	mov    rax,r14
     558:	mov    rbx,QWORD PTR [rsp+0x20]
     55d:	mov    r12,QWORD PTR [rsp+0x28]
     562:	mov    r13,QWORD PTR [rsp+0x30]
     567:	mov    r14,QWORD PTR [rsp+0x38]
     56c:	add    rsp,0x40
     570:	mov    rsp,rbp
     573:	pop    rbp
     574:	ret
     575:	mov    r13,rdi
     578:	call   57d <botlish_fn_4+0x140>
			579: R_X86_64_PLT32	rt_stack_overflow-0x4
     57d:	xor    rdx,rdx
     580:	mov    rax,rdx
     583:	mov    rbx,QWORD PTR [rsp+0x20]
     588:	mov    r12,QWORD PTR [rsp+0x28]
     58d:	mov    r13,QWORD PTR [rsp+0x30]
     592:	mov    r14,QWORD PTR [rsp+0x38]
     597:	add    rsp,0x40
     59b:	mov    rsp,rbp
     59e:	pop    rbp
     59f:	ret

00000000000005a0 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     5a0:	push   rbp
     5a1:	mov    rbp,rsp
     5a4:	ud2

00000000000005a6 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     5a6:	push   rbp
     5a7:	mov    rbp,rsp
     5aa:	sub    rsp,0x40
     5ae:	mov    QWORD PTR [rsp+0x20],rbx
     5b3:	mov    QWORD PTR [rsp+0x28],r12
     5b8:	mov    QWORD PTR [rsp+0x30],r13
     5bd:	mov    QWORD PTR [rsp+0x38],r14
     5c2:	mov    rbx,QWORD PTR [rdi]
     5c5:	mov    rax,QWORD PTR [rdi+0x8]
     5c9:	lea    r8,[rbx+0x8]
     5cd:	cmp    r8,rax
     5d0:	ja     6de <botlish_fn_5+0x138>
     5d6:	lea    rax,[rbx+0x8]
     5da:	mov    QWORD PTR [rdi],rax
     5dd:	mov    r13,rdi
     5e0:	mov    QWORD PTR [rbx],0x0
     5e7:	mov    QWORD PTR [rsp],rsi
     5eb:	mov    QWORD PTR [rsp+0x8],rdx
     5f0:	mov    rdi,rdx
     5f3:	mov    QWORD PTR [rsp+0x10],rcx
     5f8:	mov    r14,rcx
     5fb:	mov    r12,rdi
     5fe:	mov    rdx,r12
     601:	mov    rdi,r13
     604:	call   609 <botlish_fn_5+0x63>
			605: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     609:	test   rax,rax
     60c:	jne    61a <botlish_fn_5+0x74>
     612:	mov    rdi,r13
     615:	jmp    63e <botlish_fn_5+0x98>
     61a:	mov    QWORD PTR [rsp],rax
     61e:	mov    rcx,r14
     621:	mov    r14,rax
     624:	mov    rdx,r12
     627:	mov    rsi,r14
     62a:	mov    rdi,r13
     62d:	call   632 <botlish_fn_5+0x8c>
			62e: R_X86_64_PLT32	rt_mutarray_set-0x4
     632:	test   rax,rax
     635:	jne    667 <botlish_fn_5+0xc1>
     63b:	mov    rdi,r13
     63e:	mov    rdi,r13
     641:	mov    QWORD PTR [rdi],rbx
     644:	xor    rdx,rdx
     647:	mov    rax,rdx
     64a:	mov    rbx,QWORD PTR [rsp+0x20]
     64f:	mov    r12,QWORD PTR [rsp+0x28]
     654:	mov    r13,QWORD PTR [rsp+0x30]
     659:	mov    r14,QWORD PTR [rsp+0x38]
     65e:	add    rsp,0x40
     662:	mov    rsp,rbp
     665:	pop    rbp
     666:	ret
     667:	mov    QWORD PTR [rsp+0x10],0x3
     670:	test   r12,0x1
     677:	jne    685 <botlish_fn_5+0xdf>
     67d:	mov    rdi,r12
     680:	jmp    6a2 <botlish_fn_5+0xfc>
     685:	mov    rdx,r12
     688:	add    rdx,0x2
     68c:	mov    rdi,r12
     68f:	seto   al
     692:	test   al,al
     694:	jne    6a2 <botlish_fn_5+0xfc>
     69a:	mov    rdi,r13
     69d:	jmp    6b8 <botlish_fn_5+0x112>
     6a2:	mov    edx,0x3
     6a7:	mov    rsi,rdi
     6aa:	mov    rdi,r13
     6ad:	call   6b2 <botlish_fn_5+0x10c>
			6ae: R_X86_64_PLT32	rt_int_add-0x4
     6b2:	mov    rdx,rax
     6b5:	mov    rdi,r13
     6b8:	mov    rdi,r13
     6bb:	mov    QWORD PTR [rdi],rbx
     6be:	mov    rax,r14
     6c1:	mov    rbx,QWORD PTR [rsp+0x20]
     6c6:	mov    r12,QWORD PTR [rsp+0x28]
     6cb:	mov    r13,QWORD PTR [rsp+0x30]
     6d0:	mov    r14,QWORD PTR [rsp+0x38]
     6d5:	add    rsp,0x40
     6d9:	mov    rsp,rbp
     6dc:	pop    rbp
     6dd:	ret
     6de:	mov    r13,rdi
     6e1:	call   6e6 <botlish_fn_5+0x140>
			6e2: R_X86_64_PLT32	rt_stack_overflow-0x4
     6e6:	xor    rdx,rdx
     6e9:	mov    rax,rdx
     6ec:	mov    rbx,QWORD PTR [rsp+0x20]
     6f1:	mov    r12,QWORD PTR [rsp+0x28]
     6f6:	mov    r13,QWORD PTR [rsp+0x30]
     6fb:	mov    r14,QWORD PTR [rsp+0x38]
     700:	add    rsp,0x40
     704:	mov    rsp,rbp
     707:	pop    rbp
     708:	ret

0000000000000709 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     709:	push   rbp
     70a:	mov    rbp,rsp
     70d:	ud2

000000000000070f <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     70f:	push   rbp
     710:	mov    rbp,rsp
     713:	sub    rsp,0x10
     717:	mov    QWORD PTR [rsp],rsi
     71b:	mov    QWORD PTR [rsp+0x8],rdx
     720:	call   725 <botlish_fn_6+0x16>
			721: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     725:	test   rax,rax
     728:	jne    73a <botlish_fn_6+0x2b>
     72e:	xor    rax,rax
     731:	add    rsp,0x10
     735:	mov    rsp,rbp
     738:	pop    rbp
     739:	ret
     73a:	add    rsp,0x10
     73e:	mov    rsp,rbp
     741:	pop    rbp
     742:	ret

0000000000000743 <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     743:	push   rbp
     744:	mov    rbp,rsp
     747:	mov    rsi,QWORD PTR [rdx]
     74a:	mov    rdx,QWORD PTR [rdx+0x8]
     74e:	call   753 <botlish_entry_6+0x10>
			74f: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     753:	mov    rsp,rbp
     756:	pop    rbp
     757:	ret

0000000000000758 <botlish_fn_7: peek<str, int>>:
     758:	push   rbp
     759:	mov    rbp,rsp
     75c:	sub    rsp,0x40
     760:	mov    QWORD PTR [rsp+0x20],rbx
     765:	mov    QWORD PTR [rsp+0x28],r12
     76a:	mov    QWORD PTR [rsp+0x30],r13
     76f:	mov    r13,rdi
     772:	mov    QWORD PTR [rsp],rsi
     776:	mov    r12,rsi
     779:	mov    QWORD PTR [rsp+0x8],rdx
     77e:	mov    rbx,rdx
     781:	mov    rsi,r12
     784:	mov    rdi,r13
     787:	call   78c <botlish_fn_7+0x34>
			788: R_X86_64_PLT32	rt_str_len-0x4
     78c:	mov    rcx,rbx
     78f:	and    rcx,rax
     792:	mov    rdx,rax
     795:	test   rcx,0x1
     79c:	jne    7c2 <botlish_fn_7+0x6a>
     7a2:	mov    rsi,rbx
     7a5:	mov    rdi,r13
     7a8:	call   7ad <botlish_fn_7+0x55>
			7a9: R_X86_64_PLT32	rt_int_cmp-0x4
     7ad:	mov    ecx,0x2
     7b2:	test   rax,rax
     7b5:	cmovge rcx,QWORD PTR [rip+0xd3]        # 890 <botlish_fn_7+0x138>
     7bd:	jmp    7d2 <botlish_fn_7+0x7a>
     7c2:	mov    ecx,0x2
     7c7:	cmp    rbx,rdx
     7ca:	cmovge rcx,QWORD PTR [rip+0xbe]        # 890 <botlish_fn_7+0x138>
     7d2:	cmp    rcx,0x6
     7d6:	je     866 <botlish_fn_7+0x10e>
     7dc:	mov    QWORD PTR [rsp+0x10],0x3
     7e5:	test   rbx,0x1
     7ec:	je     804 <botlish_fn_7+0xac>
     7f2:	mov    rcx,rbx
     7f5:	add    rcx,0x2
     7f9:	seto   al
     7fc:	test   al,al
     7fe:	je     817 <botlish_fn_7+0xbf>
     804:	mov    edx,0x3
     809:	mov    rsi,rbx
     80c:	mov    rdi,r13
     80f:	call   814 <botlish_fn_7+0xbc>
			810: R_X86_64_PLT32	rt_int_add-0x4
     814:	mov    rcx,rax
     817:	mov    QWORD PTR [rsp+0x10],rcx
     81c:	mov    rdx,rbx
     81f:	mov    rsi,r12
     822:	mov    rdi,r13
     825:	call   82a <botlish_fn_7+0xd2>
			826: R_X86_64_PLT32	rt_substr-0x4
     82a:	test   rax,rax
     82d:	jne    84e <botlish_fn_7+0xf6>
     833:	xor    rax,rax
     836:	mov    rbx,QWORD PTR [rsp+0x20]
     83b:	mov    r12,QWORD PTR [rsp+0x28]
     840:	mov    r13,QWORD PTR [rsp+0x30]
     845:	add    rsp,0x40
     849:	mov    rsp,rbp
     84c:	pop    rbp
     84d:	ret
     84e:	mov    rbx,QWORD PTR [rsp+0x20]
     853:	mov    r12,QWORD PTR [rsp+0x28]
     858:	mov    r13,QWORD PTR [rsp+0x30]
     85d:	add    rsp,0x40
     861:	mov    rsp,rbp
     864:	pop    rbp
     865:	ret
     866:	mov    rdi,r13
     869:	mov    rax,QWORD PTR [rdi+0x10]
     86d:	mov    rax,QWORD PTR [rax+0x8]
     871:	mov    rbx,QWORD PTR [rsp+0x20]
     876:	mov    r12,QWORD PTR [rsp+0x28]
     87b:	mov    r13,QWORD PTR [rsp+0x30]
     880:	add    rsp,0x40
     884:	mov    rsp,rbp
     887:	pop    rbp
     888:	ret
     889:	add    BYTE PTR [rax],al
     88b:	add    BYTE PTR [rax],al
     88d:	add    BYTE PTR [rax],al
     88f:	add    BYTE PTR [rsi],al
     891:	add    BYTE PTR [rax],al
     893:	add    BYTE PTR [rax],al
     895:	add    BYTE PTR [rax],al
	...

0000000000000898 <botlish_entry_7: peek<str, int>>:
     898:	push   rbp
     899:	mov    rbp,rsp
     89c:	mov    rsi,QWORD PTR [rdx]
     89f:	mov    rdx,QWORD PTR [rdx+0x8]
     8a3:	call   8a8 <botlish_entry_7+0x10>
			8a4: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     8a8:	mov    rsp,rbp
     8ab:	pop    rbp
     8ac:	ret
     8ad:	add    BYTE PTR [rax],al
	...

00000000000008b0 <botlish_fn_8: peek<str, int>>:
     8b0:	push   rbp
     8b1:	mov    rbp,rsp
     8b4:	sub    rsp,0x50
     8b8:	mov    QWORD PTR [rsp+0x20],rbx
     8bd:	mov    QWORD PTR [rsp+0x28],r12
     8c2:	mov    QWORD PTR [rsp+0x30],r13
     8c7:	mov    QWORD PTR [rsp+0x38],r14
     8cc:	mov    QWORD PTR [rsp+0x40],r15
     8d1:	mov    r12,rcx
     8d4:	mov    r14,rdi
     8d7:	mov    QWORD PTR [rsp],rsi
     8db:	mov    r13,rsi
     8de:	mov    QWORD PTR [rsp+0x8],rdx
     8e3:	mov    rbx,rdx
     8e6:	mov    rsi,r13
     8e9:	mov    rdi,r14
     8ec:	call   8f1 <botlish_fn_8+0x41>
			8ed: R_X86_64_PLT32	rt_str_len-0x4
     8f1:	mov    rcx,rbx
     8f4:	and    rcx,rax
     8f7:	mov    rdx,rax
     8fa:	test   rcx,0x1
     901:	jne    927 <botlish_fn_8+0x77>
     907:	mov    rsi,rbx
     90a:	mov    rdi,r14
     90d:	call   912 <botlish_fn_8+0x62>
			90e: R_X86_64_PLT32	rt_int_cmp-0x4
     912:	mov    ecx,0x2
     917:	test   rax,rax
     91a:	cmovge rcx,QWORD PTR [rip+0x11e]        # a40 <botlish_fn_8+0x190>
     922:	jmp    937 <botlish_fn_8+0x87>
     927:	mov    ecx,0x2
     92c:	cmp    rbx,rdx
     92f:	cmovge rcx,QWORD PTR [rip+0x109]        # a40 <botlish_fn_8+0x190>
     937:	cmp    rcx,0x6
     93b:	je     9fb <botlish_fn_8+0x14b>
     941:	mov    QWORD PTR [rsp+0x10],0x3
     94a:	test   rbx,0x1
     951:	je     974 <botlish_fn_8+0xc4>
     957:	mov    rax,rbx
     95a:	add    rax,0x2
     95e:	seto   cl
     961:	test   cl,cl
     963:	jne    974 <botlish_fn_8+0xc4>
     969:	mov    rdi,r14
     96c:	mov    r15,rax
     96f:	jmp    98a <botlish_fn_8+0xda>
     974:	mov    edx,0x3
     979:	mov    rsi,rbx
     97c:	mov    rdi,r14
     97f:	call   984 <botlish_fn_8+0xd4>
			980: R_X86_64_PLT32	rt_int_add-0x4
     984:	mov    r15,rax
     987:	mov    rdi,r14
     98a:	mov    rdi,r14
     98d:	mov    rcx,r15
     990:	mov    rdx,rbx
     993:	mov    rsi,r13
     996:	call   99b <botlish_fn_8+0xeb>
			997: R_X86_64_PLT32	rt_str_region_check-0x4
     99b:	test   rax,rax
     99e:	jne    9c9 <botlish_fn_8+0x119>
     9a4:	xor    rax,rax
     9a7:	mov    rbx,QWORD PTR [rsp+0x20]
     9ac:	mov    r12,QWORD PTR [rsp+0x28]
     9b1:	mov    r13,QWORD PTR [rsp+0x30]
     9b6:	mov    r14,QWORD PTR [rsp+0x38]
     9bb:	mov    r15,QWORD PTR [rsp+0x40]
     9c0:	add    rsp,0x50
     9c4:	mov    rsp,rbp
     9c7:	pop    rbp
     9c8:	ret
     9c9:	mov    rcx,r12
     9cc:	mov    QWORD PTR [rcx],rbx
     9cf:	mov    rax,r15
     9d2:	mov    QWORD PTR [rcx+0x8],rax
     9d6:	mov    rax,r13
     9d9:	mov    rbx,QWORD PTR [rsp+0x20]
     9de:	mov    r12,QWORD PTR [rsp+0x28]
     9e3:	mov    r13,QWORD PTR [rsp+0x30]
     9e8:	mov    r14,QWORD PTR [rsp+0x38]
     9ed:	mov    r15,QWORD PTR [rsp+0x40]
     9f2:	add    rsp,0x50
     9f6:	mov    rsp,rbp
     9f9:	pop    rbp
     9fa:	ret
     9fb:	mov    rcx,r12
     9fe:	mov    rdi,r14
     a01:	mov    rax,QWORD PTR [rdi+0x10]
     a05:	mov    rax,QWORD PTR [rax+0x8]
     a09:	mov    QWORD PTR [rcx],0x1
     a10:	mov    QWORD PTR [rcx+0x8],0x1
     a18:	mov    rbx,QWORD PTR [rsp+0x20]
     a1d:	mov    r12,QWORD PTR [rsp+0x28]
     a22:	mov    r13,QWORD PTR [rsp+0x30]
     a27:	mov    r14,QWORD PTR [rsp+0x38]
     a2c:	mov    r15,QWORD PTR [rsp+0x40]
     a31:	add    rsp,0x50
     a35:	mov    rsp,rbp
     a38:	pop    rbp
     a39:	ret
     a3a:	add    BYTE PTR [rax],al
     a3c:	add    BYTE PTR [rax],al
     a3e:	add    BYTE PTR [rax],al
     a40:	(bad)
     a41:	add    BYTE PTR [rax],al
     a43:	add    BYTE PTR [rax],al
     a45:	add    BYTE PTR [rax],al
	...

0000000000000a48 <botlish_entry_8: peek<str, int>>:
     a48:	push   rbp
     a49:	mov    rbp,rsp
     a4c:	ud2

0000000000000a4e <botlish_fn_9: scan_unquoted<str, int, int>>:
     a4e:	push   rbp
     a4f:	mov    rbp,rsp
     a52:	sub    rsp,0x80
     a59:	mov    QWORD PTR [rsp+0x50],rbx
     a5e:	mov    QWORD PTR [rsp+0x58],r12
     a63:	mov    QWORD PTR [rsp+0x60],r13
     a68:	mov    QWORD PTR [rsp+0x68],r14
     a6d:	mov    QWORD PTR [rsp+0x70],r15
     a72:	mov    r14,QWORD PTR [rdi]
     a75:	mov    rax,QWORD PTR [rdi+0x8]
     a79:	lea    r8,[r14+0x8]
     a7d:	cmp    r8,rax
     a80:	ja     ca8 <botlish_fn_9+0x25a>
     a86:	lea    rax,[r14+0x8]
     a8a:	mov    QWORD PTR [rdi],rax
     a8d:	mov    r15,rdi
     a90:	mov    QWORD PTR [r14],0x0
     a97:	mov    QWORD PTR [rsp+0x18],0x0
     aa0:	mov    QWORD PTR [rsp],rsi
     aa4:	mov    QWORD PTR [rsp+0x30],rsi
     aa9:	mov    QWORD PTR [rsp+0x8],rdx
     aae:	mov    QWORD PTR [rsp+0x38],rdx
     ab3:	mov    QWORD PTR [rsp+0x10],rcx
     ab8:	lea    rbx,[rsp+0x20]
     abd:	mov    QWORD PTR [rsp+0x40],rcx
     ac2:	mov    rcx,rbx
     ac5:	mov    rdx,QWORD PTR [rsp+0x40]
     aca:	mov    rsi,QWORD PTR [rsp+0x30]
     acf:	mov    rdi,r15
     ad2:	call   ad7 <botlish_fn_9+0x89>
			ad3: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     ad7:	mov    rcx,rax
     ada:	mov    QWORD PTR [rsp+0x48],rax
     adf:	test   rax,rcx
     ae2:	jne    af0 <botlish_fn_9+0xa2>
     ae8:	mov    rdi,r15
     aeb:	jmp    c47 <botlish_fn_9+0x1f9>
     af0:	mov    r12,QWORD PTR [rsp+0x20]
     af5:	mov    r13,QWORD PTR [rsp+0x28]
     afa:	mov    rdi,r15
     afd:	mov    rcx,QWORD PTR [rdi+0x10]
     b01:	mov    r8,QWORD PTR [rcx+0x8]
     b05:	mov    rcx,r13
     b08:	mov    rdx,r12
     b0b:	mov    rsi,QWORD PTR [rsp+0x48]
     b10:	call   b15 <botlish_fn_9+0xc7>
			b11: R_X86_64_PLT32	rt_str_region_eq-0x4
     b15:	cmp    rax,0x6
     b19:	je     b58 <botlish_fn_9+0x10a>
     b1f:	mov    rdi,r15
     b22:	mov    rax,QWORD PTR [rdi+0x10]
     b26:	mov    r8,QWORD PTR [rax+0x10]
     b2a:	mov    rcx,r13
     b2d:	mov    rdx,r12
     b30:	mov    rsi,QWORD PTR [rsp+0x48]
     b35:	call   b3a <botlish_fn_9+0xec>
			b36: R_X86_64_PLT32	rt_str_region_eq-0x4
     b3a:	cmp    rax,0x6
     b3e:	je     b4e <botlish_fn_9+0x100>
     b44:	mov    eax,0x2
     b49:	jmp    b5d <botlish_fn_9+0x10f>
     b4e:	mov    eax,0x6
     b53:	jmp    b5d <botlish_fn_9+0x10f>
     b58:	mov    eax,0x6
     b5d:	cmp    rax,0x6
     b61:	je     ba0 <botlish_fn_9+0x152>
     b67:	mov    rdi,r15
     b6a:	mov    rdx,QWORD PTR [rdi+0x10]
     b6e:	mov    r8,QWORD PTR [rdx+0x18]
     b72:	mov    rcx,r13
     b75:	mov    rdx,r12
     b78:	mov    rsi,QWORD PTR [rsp+0x48]
     b7d:	call   b82 <botlish_fn_9+0x134>
			b7e: R_X86_64_PLT32	rt_str_region_eq-0x4
     b82:	cmp    rax,0x6
     b86:	je     b96 <botlish_fn_9+0x148>
     b8c:	mov    eax,0x2
     b91:	jmp    ba5 <botlish_fn_9+0x157>
     b96:	mov    eax,0x6
     b9b:	jmp    ba5 <botlish_fn_9+0x157>
     ba0:	mov    eax,0x6
     ba5:	cmp    rax,0x6
     ba9:	je     c24 <botlish_fn_9+0x1d6>
     baf:	mov    QWORD PTR [rsp+0x18],0x3
     bb8:	mov    rsi,QWORD PTR [rsp+0x40]
     bbd:	test   rsi,0x1
     bc4:	je     beb <botlish_fn_9+0x19d>
     bca:	mov    rsi,QWORD PTR [rsp+0x40]
     bcf:	mov    rax,rsi
     bd2:	add    rax,0x2
     bd6:	seto   cl
     bd9:	test   cl,cl
     bdb:	jne    beb <botlish_fn_9+0x19d>
     be1:	mov    rsi,QWORD PTR [rsp+0x30]
     be6:	jmp    c02 <botlish_fn_9+0x1b4>
     beb:	mov    edx,0x3
     bf0:	mov    rsi,QWORD PTR [rsp+0x40]
     bf5:	mov    rdi,r15
     bf8:	call   bfd <botlish_fn_9+0x1af>
			bf9: R_X86_64_PLT32	rt_int_add-0x4
     bfd:	mov    rsi,QWORD PTR [rsp+0x30]
     c02:	mov    QWORD PTR [rsp],rsi
     c06:	mov    rdx,QWORD PTR [rsp+0x38]
     c0b:	mov    QWORD PTR [rsp+0x8],rdx
     c10:	mov    QWORD PTR [rsp+0x10],rax
     c15:	mov    QWORD PTR [rsp+0x30],rsi
     c1a:	mov    QWORD PTR [rsp+0x40],rax
     c1f:	jmp    ac2 <botlish_fn_9+0x74>
     c24:	mov    rdx,QWORD PTR [rsp+0x38]
     c29:	mov    rsi,QWORD PTR [rsp+0x30]
     c2e:	mov    rcx,QWORD PTR [rsp+0x40]
     c33:	mov    rdi,r15
     c36:	call   c3b <botlish_fn_9+0x1ed>
			c37: R_X86_64_PLT32	rt_substr-0x4
     c3b:	test   rax,rax
     c3e:	jne    c78 <botlish_fn_9+0x22a>
     c44:	mov    rdi,r15
     c47:	mov    rdi,r15
     c4a:	mov    QWORD PTR [rdi],r14
     c4d:	xor    rdx,rdx
     c50:	mov    rax,rdx
     c53:	mov    rbx,QWORD PTR [rsp+0x50]
     c58:	mov    r12,QWORD PTR [rsp+0x58]
     c5d:	mov    r13,QWORD PTR [rsp+0x60]
     c62:	mov    r14,QWORD PTR [rsp+0x68]
     c67:	mov    r15,QWORD PTR [rsp+0x70]
     c6c:	add    rsp,0x80
     c73:	mov    rsp,rbp
     c76:	pop    rbp
     c77:	ret
     c78:	mov    rdi,r15
     c7b:	mov    QWORD PTR [rdi],r14
     c7e:	mov    rdx,QWORD PTR [rsp+0x40]
     c83:	mov    rbx,QWORD PTR [rsp+0x50]
     c88:	mov    r12,QWORD PTR [rsp+0x58]
     c8d:	mov    r13,QWORD PTR [rsp+0x60]
     c92:	mov    r14,QWORD PTR [rsp+0x68]
     c97:	mov    r15,QWORD PTR [rsp+0x70]
     c9c:	add    rsp,0x80
     ca3:	mov    rsp,rbp
     ca6:	pop    rbp
     ca7:	ret
     ca8:	mov    r15,rdi
     cab:	call   cb0 <botlish_fn_9+0x262>
			cac: R_X86_64_PLT32	rt_stack_overflow-0x4
     cb0:	xor    rdx,rdx
     cb3:	mov    rax,rdx
     cb6:	mov    rbx,QWORD PTR [rsp+0x50]
     cbb:	mov    r12,QWORD PTR [rsp+0x58]
     cc0:	mov    r13,QWORD PTR [rsp+0x60]
     cc5:	mov    r14,QWORD PTR [rsp+0x68]
     cca:	mov    r15,QWORD PTR [rsp+0x70]
     ccf:	add    rsp,0x80
     cd6:	mov    rsp,rbp
     cd9:	pop    rbp
     cda:	ret

0000000000000cdb <botlish_entry_9: scan_unquoted<str, int, int>>:
     cdb:	push   rbp
     cdc:	mov    rbp,rsp
     cdf:	ud2

0000000000000ce1 <botlish_fn_10: scan_quoted<str, int, str>>:
     ce1:	push   rbp
     ce2:	mov    rbp,rsp
     ce5:	sub    rsp,0x80
     cec:	mov    QWORD PTR [rsp+0x50],rbx
     cf1:	mov    QWORD PTR [rsp+0x58],r12
     cf6:	mov    QWORD PTR [rsp+0x60],r13
     cfb:	mov    QWORD PTR [rsp+0x68],r14
     d00:	mov    QWORD PTR [rsp+0x70],r15
     d05:	mov    r13,QWORD PTR [rdi]
     d08:	mov    rax,QWORD PTR [rdi+0x8]
     d0c:	lea    r8,[r13+0x8]
     d10:	cmp    r8,rax
     d13:	ja     1005 <botlish_fn_10+0x324>
     d19:	lea    rax,[r13+0x8]
     d1d:	mov    QWORD PTR [rdi],rax
     d20:	mov    r14,rdi
     d23:	mov    QWORD PTR [r13+0x0],0x0
     d2b:	mov    QWORD PTR [rsp+0x18],0x0
     d34:	mov    QWORD PTR [rsp+0x20],0x0
     d3d:	mov    QWORD PTR [rsp],rsi
     d41:	mov    QWORD PTR [rsp+0x8],rdx
     d46:	mov    QWORD PTR [rsp+0x10],rcx
     d4b:	lea    rbx,[rsp+0x28]
     d50:	mov    r12,rsi
     d53:	mov    r15,rdx
     d56:	mov    QWORD PTR [rsp+0x38],rcx
     d5b:	mov    rdx,r15
     d5e:	mov    rsi,r12
     d61:	mov    rdi,r14
     d64:	call   d69 <botlish_fn_10+0x88>
			d65: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     d69:	test   rax,rax
     d6c:	jne    d7a <botlish_fn_10+0x99>
     d72:	mov    rdi,r14
     d75:	jmp    fb9 <botlish_fn_10+0x2d8>
     d7a:	mov    QWORD PTR [rsp+0x18],rax
     d7f:	mov    rdi,r14
     d82:	mov    QWORD PTR [rsp+0x40],rax
     d87:	mov    rsi,QWORD PTR [rdi+0x10]
     d8b:	mov    rsi,QWORD PTR [rsi+0x20]
     d8f:	mov    edx,0x1
     d94:	mov    ecx,0x3
     d99:	mov    r8,QWORD PTR [rsp+0x40]
     d9e:	call   da3 <botlish_fn_10+0xc2>
			d9f: R_X86_64_PLT32	rt_str_region_eq-0x4
     da3:	cmp    rax,0x6
     da7:	je     e38 <botlish_fn_10+0x157>
     dad:	mov    QWORD PTR [rsp+0x20],0x3
     db6:	mov    rsi,r15
     db9:	test   rsi,0x1
     dc0:	je     de2 <botlish_fn_10+0x101>
     dc6:	mov    r9,rsi
     dc9:	add    r9,0x2
     dcd:	seto   r11b
     dd1:	test   r11b,r11b
     dd4:	jne    de2 <botlish_fn_10+0x101>
     dda:	mov    rsi,r9
     ddd:	jmp    df2 <botlish_fn_10+0x111>
     de2:	mov    edx,0x3
     de7:	mov    rdi,r14
     dea:	call   def <botlish_fn_10+0x10e>
			deb: R_X86_64_PLT32	rt_int_add-0x4
     def:	mov    rsi,rax
     df2:	mov    QWORD PTR [rsp+0x8],rsi
     df7:	mov    r15,rsi
     dfa:	mov    rsi,QWORD PTR [rsp+0x38]
     dff:	mov    rdx,QWORD PTR [rsp+0x40]
     e04:	mov    rdi,r14
     e07:	call   e0c <botlish_fn_10+0x12b>
			e08: R_X86_64_PLT32	rt_str_cat-0x4
     e0c:	test   rax,rax
     e0f:	jne    e1d <botlish_fn_10+0x13c>
     e15:	mov    rdi,r14
     e18:	jmp    fb9 <botlish_fn_10+0x2d8>
     e1d:	mov    QWORD PTR [rsp],r12
     e21:	mov    rsi,r15
     e24:	mov    QWORD PTR [rsp+0x8],rsi
     e29:	mov    QWORD PTR [rsp+0x10],rax
     e2e:	mov    QWORD PTR [rsp+0x38],rax
     e33:	jmp    d5b <botlish_fn_10+0x7a>
     e38:	mov    QWORD PTR [rsp+0x18],0x3
     e41:	mov    rsi,r15
     e44:	test   rsi,0x1
     e4b:	je     e66 <botlish_fn_10+0x185>
     e51:	mov    rsi,r15
     e54:	mov    rdx,rsi
     e57:	add    rdx,0x2
     e5b:	seto   al
     e5e:	test   al,al
     e60:	je     e79 <botlish_fn_10+0x198>
     e66:	mov    edx,0x3
     e6b:	mov    rsi,r15
     e6e:	mov    rdi,r14
     e71:	call   e76 <botlish_fn_10+0x195>
			e72: R_X86_64_PLT32	rt_int_add-0x4
     e76:	mov    rdx,rax
     e79:	mov    QWORD PTR [rsp+0x18],rdx
     e7e:	mov    rcx,rbx
     e81:	mov    rsi,r12
     e84:	mov    rdi,r14
     e87:	call   e8c <botlish_fn_10+0x1ab>
			e88: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     e8c:	test   rax,rax
     e8f:	mov    rsi,rax
     e92:	jne    ea0 <botlish_fn_10+0x1bf>
     e98:	mov    rdi,r14
     e9b:	jmp    fb9 <botlish_fn_10+0x2d8>
     ea0:	mov    rdx,QWORD PTR [rsp+0x28]
     ea5:	mov    rcx,QWORD PTR [rsp+0x30]
     eaa:	mov    rdi,r14
     ead:	mov    rax,QWORD PTR [rdi+0x10]
     eb1:	mov    r8,QWORD PTR [rax+0x20]
     eb5:	call   eba <botlish_fn_10+0x1d9>
			eb6: R_X86_64_PLT32	rt_str_region_eq-0x4
     eba:	cmp    rax,0x6
     ebe:	je     f3f <botlish_fn_10+0x25e>
     ec4:	mov    QWORD PTR [rsp],0x3
     ecc:	mov    rsi,r15
     ecf:	test   rsi,0x1
     ed6:	je     ef9 <botlish_fn_10+0x218>
     edc:	mov    rsi,r15
     edf:	mov    rdx,rsi
     ee2:	add    rdx,0x2
     ee6:	seto   al
     ee9:	test   al,al
     eeb:	jne    ef9 <botlish_fn_10+0x218>
     ef1:	mov    rdi,r14
     ef4:	jmp    f0f <botlish_fn_10+0x22e>
     ef9:	mov    edx,0x3
     efe:	mov    rsi,r15
     f01:	mov    rdi,r14
     f04:	call   f09 <botlish_fn_10+0x228>
			f05: R_X86_64_PLT32	rt_int_add-0x4
     f09:	mov    rdx,rax
     f0c:	mov    rdi,r14
     f0f:	mov    rdi,r14
     f12:	mov    QWORD PTR [rdi],r13
     f15:	mov    rax,QWORD PTR [rsp+0x38]
     f1a:	mov    rbx,QWORD PTR [rsp+0x50]
     f1f:	mov    r12,QWORD PTR [rsp+0x58]
     f24:	mov    r13,QWORD PTR [rsp+0x60]
     f29:	mov    r14,QWORD PTR [rsp+0x68]
     f2e:	mov    r15,QWORD PTR [rsp+0x70]
     f33:	add    rsp,0x80
     f3a:	mov    rsp,rbp
     f3d:	pop    rbp
     f3e:	ret
     f3f:	mov    QWORD PTR [rsp+0x18],0x5
     f48:	mov    rsi,r15
     f4b:	test   rsi,0x1
     f52:	je     f78 <botlish_fn_10+0x297>
     f58:	mov    rsi,r15
     f5b:	mov    rax,rsi
     f5e:	add    rax,0x4
     f62:	seto   cl
     f65:	test   cl,cl
     f67:	jne    f78 <botlish_fn_10+0x297>
     f6d:	mov    rsi,rax
     f70:	mov    r15,rax
     f73:	jmp    f8e <botlish_fn_10+0x2ad>
     f78:	mov    edx,0x5
     f7d:	mov    rsi,r15
     f80:	mov    rdi,r14
     f83:	call   f88 <botlish_fn_10+0x2a7>
			f84: R_X86_64_PLT32	rt_int_add-0x4
     f88:	mov    rsi,rax
     f8b:	mov    r15,rax
     f8e:	mov    QWORD PTR [rsp+0x8],rsi
     f93:	mov    rdi,r14
     f96:	mov    rax,QWORD PTR [rdi+0x10]
     f9a:	mov    rdx,QWORD PTR [rax+0x20]
     f9e:	mov    QWORD PTR [rsp+0x18],rdx
     fa3:	mov    rsi,QWORD PTR [rsp+0x38]
     fa8:	call   fad <botlish_fn_10+0x2cc>
			fa9: R_X86_64_PLT32	rt_str_cat-0x4
     fad:	test   rax,rax
     fb0:	jne    fea <botlish_fn_10+0x309>
     fb6:	mov    rdi,r14
     fb9:	mov    rdi,r14
     fbc:	mov    QWORD PTR [rdi],r13
     fbf:	xor    rdx,rdx
     fc2:	mov    rax,rdx
     fc5:	mov    rbx,QWORD PTR [rsp+0x50]
     fca:	mov    r12,QWORD PTR [rsp+0x58]
     fcf:	mov    r13,QWORD PTR [rsp+0x60]
     fd4:	mov    r14,QWORD PTR [rsp+0x68]
     fd9:	mov    r15,QWORD PTR [rsp+0x70]
     fde:	add    rsp,0x80
     fe5:	mov    rsp,rbp
     fe8:	pop    rbp
     fe9:	ret
     fea:	mov    QWORD PTR [rsp],r12
     fee:	mov    rsi,r15
     ff1:	mov    QWORD PTR [rsp+0x8],rsi
     ff6:	mov    QWORD PTR [rsp+0x10],rax
     ffb:	mov    QWORD PTR [rsp+0x38],rax
    1000:	jmp    d5b <botlish_fn_10+0x7a>
    1005:	mov    r14,rdi
    1008:	call   100d <botlish_fn_10+0x32c>
			1009: R_X86_64_PLT32	rt_stack_overflow-0x4
    100d:	xor    rdx,rdx
    1010:	mov    rax,rdx
    1013:	mov    rbx,QWORD PTR [rsp+0x50]
    1018:	mov    r12,QWORD PTR [rsp+0x58]
    101d:	mov    r13,QWORD PTR [rsp+0x60]
    1022:	mov    r14,QWORD PTR [rsp+0x68]
    1027:	mov    r15,QWORD PTR [rsp+0x70]
    102c:	add    rsp,0x80
    1033:	mov    rsp,rbp
    1036:	pop    rbp
    1037:	ret

0000000000001038 <botlish_entry_10: scan_quoted<str, int, str>>:
    1038:	push   rbp
    1039:	mov    rbp,rsp
    103c:	ud2

000000000000103e <botlish_fn_11: scan_field<str, int>>:
    103e:	push   rbp
    103f:	mov    rbp,rsp
    1042:	sub    rsp,0x50
    1046:	mov    QWORD PTR [rsp+0x30],rbx
    104b:	mov    QWORD PTR [rsp+0x38],r12
    1050:	mov    QWORD PTR [rsp+0x40],r13
    1055:	mov    QWORD PTR [rsp+0x48],r14
    105a:	mov    rbx,QWORD PTR [rdi]
    105d:	mov    rax,QWORD PTR [rdi+0x8]
    1061:	lea    rcx,[rbx+0x8]
    1065:	cmp    rcx,rax
    1068:	ja     11da <botlish_fn_11+0x19c>
    106e:	lea    rax,[rbx+0x8]
    1072:	mov    QWORD PTR [rdi],rax
    1075:	mov    r12,rdi
    1078:	mov    QWORD PTR [rbx],0x0
    107f:	mov    QWORD PTR [rsp+0x10],0x0
    1088:	mov    QWORD PTR [rsp],rsi
    108c:	mov    r13,rsi
    108f:	mov    QWORD PTR [rsp+0x8],rdx
    1094:	mov    r14,rdx
    1097:	lea    rcx,[rsp+0x18]
    109c:	mov    rdx,r14
    109f:	mov    rsi,r13
    10a2:	mov    rdi,r12
    10a5:	call   10aa <botlish_fn_11+0x6c>
			10a6: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    10aa:	test   rax,rax
    10ad:	mov    rsi,rax
    10b0:	jne    10be <botlish_fn_11+0x80>
    10b6:	mov    rdi,r12
    10b9:	jmp    118e <botlish_fn_11+0x150>
    10be:	mov    rdx,QWORD PTR [rsp+0x18]
    10c3:	mov    rcx,QWORD PTR [rsp+0x20]
    10c8:	mov    rdi,r12
    10cb:	mov    rax,QWORD PTR [rdi+0x10]
    10cf:	mov    r8,QWORD PTR [rax+0x20]
    10d3:	call   10d8 <botlish_fn_11+0x9a>
			10d4: R_X86_64_PLT32	rt_str_region_eq-0x4
    10d8:	cmp    rax,0x6
    10dc:	je     1127 <botlish_fn_11+0xe9>
    10e2:	mov    rcx,r14
    10e5:	mov    rsi,r13
    10e8:	mov    rdi,r12
    10eb:	mov    rdx,rcx
    10ee:	call   10f3 <botlish_fn_11+0xb5>
			10ef: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
    10f3:	test   rax,rax
    10f6:	jne    1104 <botlish_fn_11+0xc6>
    10fc:	mov    rdi,r12
    10ff:	jmp    118e <botlish_fn_11+0x150>
    1104:	mov    rdi,r12
    1107:	mov    QWORD PTR [rdi],rbx
    110a:	mov    rbx,QWORD PTR [rsp+0x30]
    110f:	mov    r12,QWORD PTR [rsp+0x38]
    1114:	mov    r13,QWORD PTR [rsp+0x40]
    1119:	mov    r14,QWORD PTR [rsp+0x48]
    111e:	add    rsp,0x50
    1122:	mov    rsp,rbp
    1125:	pop    rbp
    1126:	ret
    1127:	mov    QWORD PTR [rsp+0x10],0x3
    1130:	mov    rdx,r14
    1133:	test   rdx,0x1
    113a:	je     1152 <botlish_fn_11+0x114>
    1140:	mov    rdx,r14
    1143:	add    rdx,0x2
    1147:	seto   al
    114a:	test   al,al
    114c:	je     1165 <botlish_fn_11+0x127>
    1152:	mov    edx,0x3
    1157:	mov    rsi,r14
    115a:	mov    rdi,r12
    115d:	call   1162 <botlish_fn_11+0x124>
			115e: R_X86_64_PLT32	rt_int_add-0x4
    1162:	mov    rdx,rax
    1165:	mov    QWORD PTR [rsp+0x8],rdx
    116a:	mov    rdi,r12
    116d:	mov    rax,QWORD PTR [rdi+0x10]
    1171:	mov    rcx,QWORD PTR [rax+0x8]
    1175:	mov    QWORD PTR [rsp+0x10],rcx
    117a:	mov    rsi,r13
    117d:	call   1182 <botlish_fn_11+0x144>
			117e: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
    1182:	test   rax,rax
    1185:	jne    11b7 <botlish_fn_11+0x179>
    118b:	mov    rdi,r12
    118e:	mov    rdi,r12
    1191:	mov    QWORD PTR [rdi],rbx
    1194:	xor    rdx,rdx
    1197:	mov    rax,rdx
    119a:	mov    rbx,QWORD PTR [rsp+0x30]
    119f:	mov    r12,QWORD PTR [rsp+0x38]
    11a4:	mov    r13,QWORD PTR [rsp+0x40]
    11a9:	mov    r14,QWORD PTR [rsp+0x48]
    11ae:	add    rsp,0x50
    11b2:	mov    rsp,rbp
    11b5:	pop    rbp
    11b6:	ret
    11b7:	mov    rdi,r12
    11ba:	mov    QWORD PTR [rdi],rbx
    11bd:	mov    rbx,QWORD PTR [rsp+0x30]
    11c2:	mov    r12,QWORD PTR [rsp+0x38]
    11c7:	mov    r13,QWORD PTR [rsp+0x40]
    11cc:	mov    r14,QWORD PTR [rsp+0x48]
    11d1:	add    rsp,0x50
    11d5:	mov    rsp,rbp
    11d8:	pop    rbp
    11d9:	ret
    11da:	mov    r12,rdi
    11dd:	call   11e2 <botlish_fn_11+0x1a4>
			11de: R_X86_64_PLT32	rt_stack_overflow-0x4
    11e2:	xor    rdx,rdx
    11e5:	mov    rax,rdx
    11e8:	mov    rbx,QWORD PTR [rsp+0x30]
    11ed:	mov    r12,QWORD PTR [rsp+0x38]
    11f2:	mov    r13,QWORD PTR [rsp+0x40]
    11f7:	mov    r14,QWORD PTR [rsp+0x48]
    11fc:	add    rsp,0x50
    1200:	mov    rsp,rbp
    1203:	pop    rbp
    1204:	ret

0000000000001205 <botlish_entry_11: scan_field<str, int>>:
    1205:	push   rbp
    1206:	mov    rbp,rsp
    1209:	ud2

000000000000120b <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
    120b:	push   rbp
    120c:	mov    rbp,rsp
    120f:	sub    rsp,0x90
    1216:	mov    QWORD PTR [rsp+0x60],rbx
    121b:	mov    QWORD PTR [rsp+0x68],r12
    1220:	mov    QWORD PTR [rsp+0x70],r13
    1225:	mov    QWORD PTR [rsp+0x78],r14
    122a:	mov    QWORD PTR [rsp+0x80],r15
    1232:	mov    r13,QWORD PTR [rdi]
    1235:	mov    rax,QWORD PTR [rdi+0x8]
    1239:	lea    r9,[r13+0x8]
    123d:	cmp    r9,rax
    1240:	ja     152a <botlish_fn_12+0x31f>
    1246:	lea    rax,[r13+0x8]
    124a:	mov    QWORD PTR [rdi],rax
    124d:	mov    QWORD PTR [rsp+0x38],rdi
    1252:	mov    QWORD PTR [r13+0x0],0x0
    125a:	mov    QWORD PTR [rsp+0x20],0x0
    1263:	mov    QWORD PTR [rsp],rsi
    1267:	mov    QWORD PTR [rsp+0x8],rdx
    126c:	mov    QWORD PTR [rsp+0x10],rcx
    1271:	mov    QWORD PTR [rsp+0x18],r8
    1276:	lea    rbx,[rsp+0x28]
    127b:	mov    r12,rsi
    127e:	mov    r14,r8
    1281:	mov    r15,rcx
    1284:	mov    rsi,r12
    1287:	mov    rdi,QWORD PTR [rsp+0x38]
    128c:	call   1291 <botlish_fn_12+0x86>
			128d: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
    1291:	test   rax,rax
    1294:	jne    12a4 <botlish_fn_12+0x99>
    129a:	mov    rdi,QWORD PTR [rsp+0x38]
    129f:	jmp    13f0 <botlish_fn_12+0x1e5>
    12a4:	mov    QWORD PTR [rsp+0x8],rax
    12a9:	mov    rcx,rax
    12ac:	mov    QWORD PTR [rsp+0x20],rdx
    12b1:	mov    QWORD PTR [rsp+0x58],rdx
    12b6:	mov    rsi,r15
    12b9:	mov    rdx,r14
    12bc:	mov    rdi,QWORD PTR [rsp+0x38]
    12c1:	call   12c6 <botlish_fn_12+0xbb>
			12c2: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    12c6:	test   rax,rax
    12c9:	jne    12d9 <botlish_fn_12+0xce>
    12cf:	mov    rdi,QWORD PTR [rsp+0x38]
    12d4:	jmp    13f0 <botlish_fn_12+0x1e5>
    12d9:	mov    QWORD PTR [rsp+0x8],rax
    12de:	mov    QWORD PTR [rsp+0x48],rax
    12e3:	mov    QWORD PTR [rsp+0x10],rdx
    12e8:	mov    QWORD PTR [rsp+0x50],rdx
    12ed:	mov    rcx,rbx
    12f0:	mov    rdx,QWORD PTR [rsp+0x58]
    12f5:	mov    rsi,r12
    12f8:	mov    rdi,QWORD PTR [rsp+0x38]
    12fd:	call   1302 <botlish_fn_12+0xf7>
			12fe: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1302:	test   rax,rax
    1305:	mov    QWORD PTR [rsp+0x40],rax
    130a:	jne    131a <botlish_fn_12+0x10f>
    1310:	mov    rdi,QWORD PTR [rsp+0x38]
    1315:	jmp    13f0 <botlish_fn_12+0x1e5>
    131a:	mov    r15,QWORD PTR [rsp+0x28]
    131f:	mov    r14,QWORD PTR [rsp+0x30]
    1324:	mov    rdi,QWORD PTR [rsp+0x38]
    1329:	mov    rcx,QWORD PTR [rdi+0x10]
    132d:	mov    r8,QWORD PTR [rcx+0x10]
    1331:	mov    rcx,r14
    1334:	mov    rdx,r15
    1337:	mov    rsi,QWORD PTR [rsp+0x40]
    133c:	call   1341 <botlish_fn_12+0x136>
			133d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1341:	cmp    rax,0x6
    1345:	je     14b5 <botlish_fn_12+0x2aa>
    134b:	mov    rdi,QWORD PTR [rsp+0x38]
    1350:	mov    rsi,QWORD PTR [rdi+0x10]
    1354:	mov    r8,QWORD PTR [rsi+0x18]
    1358:	mov    rcx,r14
    135b:	mov    rdx,r15
    135e:	mov    rsi,QWORD PTR [rsp+0x40]
    1363:	call   1368 <botlish_fn_12+0x15d>
			1364: R_X86_64_PLT32	rt_str_region_eq-0x4
    1368:	cmp    rax,0x6
    136c:	je     13ce <botlish_fn_12+0x1c3>
    1372:	mov    rdx,QWORD PTR [rsp+0x50]
    1377:	mov    rsi,QWORD PTR [rsp+0x48]
    137c:	mov    rdi,QWORD PTR [rsp+0x38]
    1381:	call   1386 <botlish_fn_12+0x17b>
			1382: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1386:	test   rax,rax
    1389:	jne    1399 <botlish_fn_12+0x18e>
    138f:	mov    rdi,QWORD PTR [rsp+0x38]
    1394:	jmp    13f0 <botlish_fn_12+0x1e5>
    1399:	mov    rdi,QWORD PTR [rsp+0x38]
    139e:	mov    QWORD PTR [rdi],r13
    13a1:	mov    rdx,QWORD PTR [rsp+0x58]
    13a6:	mov    rbx,QWORD PTR [rsp+0x60]
    13ab:	mov    r12,QWORD PTR [rsp+0x68]
    13b0:	mov    r13,QWORD PTR [rsp+0x70]
    13b5:	mov    r14,QWORD PTR [rsp+0x78]
    13ba:	mov    r15,QWORD PTR [rsp+0x80]
    13c2:	add    rsp,0x90
    13c9:	mov    rsp,rbp
    13cc:	pop    rbp
    13cd:	ret
    13ce:	mov    rdx,QWORD PTR [rsp+0x50]
    13d3:	mov    rsi,QWORD PTR [rsp+0x48]
    13d8:	mov    rdi,QWORD PTR [rsp+0x38]
    13dd:	call   13e2 <botlish_fn_12+0x1d7>
			13de: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    13e2:	test   rax,rax
    13e5:	jne    1426 <botlish_fn_12+0x21b>
    13eb:	mov    rdi,QWORD PTR [rsp+0x38]
    13f0:	mov    rdi,QWORD PTR [rsp+0x38]
    13f5:	mov    QWORD PTR [rdi],r13
    13f8:	xor    rdx,rdx
    13fb:	mov    rax,rdx
    13fe:	mov    rbx,QWORD PTR [rsp+0x60]
    1403:	mov    r12,QWORD PTR [rsp+0x68]
    1408:	mov    r13,QWORD PTR [rsp+0x70]
    140d:	mov    r14,QWORD PTR [rsp+0x78]
    1412:	mov    r15,QWORD PTR [rsp+0x80]
    141a:	add    rsp,0x90
    1421:	mov    rsp,rbp
    1424:	pop    rbp
    1425:	ret
    1426:	mov    QWORD PTR [rsp],rax
    142a:	mov    rbx,rax
    142d:	mov    QWORD PTR [rsp+0x8],0x3
    1436:	mov    rdx,QWORD PTR [rsp+0x58]
    143b:	test   rdx,0x1
    1442:	je     1466 <botlish_fn_12+0x25b>
    1448:	mov    rdx,QWORD PTR [rsp+0x58]
    144d:	add    rdx,0x2
    1451:	seto   al
    1454:	test   al,al
    1456:	jne    1466 <botlish_fn_12+0x25b>
    145c:	mov    rdi,QWORD PTR [rsp+0x38]
    1461:	jmp    1482 <botlish_fn_12+0x277>
    1466:	mov    edx,0x3
    146b:	mov    rsi,QWORD PTR [rsp+0x58]
    1470:	mov    rdi,QWORD PTR [rsp+0x38]
    1475:	call   147a <botlish_fn_12+0x26f>
			1476: R_X86_64_PLT32	rt_int_add-0x4
    147a:	mov    rdx,rax
    147d:	mov    rdi,QWORD PTR [rsp+0x38]
    1482:	mov    rdi,QWORD PTR [rsp+0x38]
    1487:	mov    QWORD PTR [rdi],r13
    148a:	mov    rax,rbx
    148d:	mov    rbx,QWORD PTR [rsp+0x60]
    1492:	mov    r12,QWORD PTR [rsp+0x68]
    1497:	mov    r13,QWORD PTR [rsp+0x70]
    149c:	mov    r14,QWORD PTR [rsp+0x78]
    14a1:	mov    r15,QWORD PTR [rsp+0x80]
    14a9:	add    rsp,0x90
    14b0:	mov    rsp,rbp
    14b3:	pop    rbp
    14b4:	ret
    14b5:	mov    rsi,QWORD PTR [rsp+0x58]
    14ba:	mov    edx,0x3
    14bf:	mov    r9,rdx
    14c2:	mov    QWORD PTR [rsp+0x18],0x3
    14cb:	test   rsi,0x1
    14d2:	jne    14e0 <botlish_fn_12+0x2d5>
    14d8:	mov    rdx,r9
    14db:	jmp    14f5 <botlish_fn_12+0x2ea>
    14e0:	mov    rdx,rsi
    14e3:	add    rdx,0x2
    14e7:	seto   al
    14ea:	test   al,al
    14ec:	je     1502 <botlish_fn_12+0x2f7>
    14f2:	mov    rdx,r9
    14f5:	mov    rdi,QWORD PTR [rsp+0x38]
    14fa:	call   14ff <botlish_fn_12+0x2f4>
			14fb: R_X86_64_PLT32	rt_int_add-0x4
    14ff:	mov    rdx,rax
    1502:	mov    QWORD PTR [rsp],r12
    1506:	mov    QWORD PTR [rsp+0x8],rdx
    150b:	mov    rsi,QWORD PTR [rsp+0x48]
    1510:	mov    QWORD PTR [rsp+0x10],rsi
    1515:	mov    rax,QWORD PTR [rsp+0x50]
    151a:	mov    QWORD PTR [rsp+0x18],rax
    151f:	mov    r14,rax
    1522:	mov    r15,rsi
    1525:	jmp    1284 <botlish_fn_12+0x79>
    152a:	mov    QWORD PTR [rsp+0x38],rdi
    152f:	call   1534 <botlish_fn_12+0x329>
			1530: R_X86_64_PLT32	rt_stack_overflow-0x4
    1534:	xor    rdx,rdx
    1537:	mov    rax,rdx
    153a:	mov    rbx,QWORD PTR [rsp+0x60]
    153f:	mov    r12,QWORD PTR [rsp+0x68]
    1544:	mov    r13,QWORD PTR [rsp+0x70]
    1549:	mov    r14,QWORD PTR [rsp+0x78]
    154e:	mov    r15,QWORD PTR [rsp+0x80]
    1556:	add    rsp,0x90
    155d:	mov    rsp,rbp
    1560:	pop    rbp
    1561:	ret

0000000000001562 <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    1562:	push   rbp
    1563:	mov    rbp,rsp
    1566:	ud2

0000000000001568 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    1568:	push   rbp
    1569:	mov    rbp,rsp
    156c:	sub    rsp,0x70
    1570:	mov    QWORD PTR [rsp+0x40],rbx
    1575:	mov    QWORD PTR [rsp+0x48],r12
    157a:	mov    QWORD PTR [rsp+0x50],r13
    157f:	mov    QWORD PTR [rsp+0x58],r14
    1584:	mov    QWORD PTR [rsp+0x60],r15
    1589:	mov    r12,QWORD PTR [rdi]
    158c:	mov    rax,QWORD PTR [rdi+0x8]
    1590:	lea    r9,[r12+0x8]
    1595:	cmp    r9,rax
    1598:	ja     174d <botlish_fn_13+0x1e5>
    159e:	lea    rax,[r12+0x8]
    15a3:	mov    QWORD PTR [rdi],rax
    15a6:	mov    r14,rdi
    15a9:	mov    QWORD PTR [r12],0x0
    15b1:	mov    QWORD PTR [rsp+0x20],0x0
    15ba:	mov    QWORD PTR [rsp+0x28],0x0
    15c3:	mov    QWORD PTR [rsp],rsi
    15c7:	mov    QWORD PTR [rsp+0x8],rdx
    15cc:	mov    r13,rdx
    15cf:	mov    QWORD PTR [rsp+0x10],rcx
    15d4:	mov    QWORD PTR [rsp+0x18],r8
    15d9:	mov    rbx,rsi
    15dc:	mov    r15,r8
    15df:	mov    QWORD PTR [rsp+0x30],rcx
    15e4:	mov    rsi,rbx
    15e7:	mov    rdi,r14
    15ea:	call   15ef <botlish_fn_13+0x87>
			15eb: R_X86_64_PLT32	rt_str_len-0x4
    15ef:	mov    rcx,r13
    15f2:	and    rcx,rax
    15f5:	mov    rdx,rax
    15f8:	test   rcx,0x1
    15ff:	jne    1625 <botlish_fn_13+0xbd>
    1605:	mov    rsi,r13
    1608:	mov    rdi,r14
    160b:	call   1610 <botlish_fn_13+0xa8>
			160c: R_X86_64_PLT32	rt_int_cmp-0x4
    1610:	mov    ecx,0x2
    1615:	test   rax,rax
    1618:	cmovge rcx,QWORD PTR [rip+0x160]        # 1780 <botlish_fn_13+0x218>
    1620:	jmp    1638 <botlish_fn_13+0xd0>
    1625:	mov    ecx,0x2
    162a:	mov    rax,r13
    162d:	cmp    rax,rdx
    1630:	cmovge rcx,QWORD PTR [rip+0x148]        # 1780 <botlish_fn_13+0x218>
    1638:	cmp    rcx,0x6
    163c:	je     16de <botlish_fn_13+0x176>
    1642:	mov    rdi,r14
    1645:	call   164a <botlish_fn_13+0xe2>
			1646: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    164a:	test   rax,rax
    164d:	jne    165b <botlish_fn_13+0xf3>
    1653:	mov    rdi,r14
    1656:	jmp    16fa <botlish_fn_13+0x192>
    165b:	mov    QWORD PTR [rsp+0x20],rax
    1660:	mov    rcx,rax
    1663:	mov    QWORD PTR [rsp+0x28],rdx
    1668:	mov    r8,rdx
    166b:	mov    rdx,r13
    166e:	mov    rsi,rbx
    1671:	mov    rdi,r14
    1674:	call   1679 <botlish_fn_13+0x111>
			1675: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    1679:	test   rax,rax
    167c:	jne    168a <botlish_fn_13+0x122>
    1682:	mov    rdi,r14
    1685:	jmp    16fa <botlish_fn_13+0x192>
    168a:	mov    QWORD PTR [rsp+0x8],rax
    168f:	mov    rcx,rax
    1692:	mov    QWORD PTR [rsp+0x20],rdx
    1697:	mov    r13,rdx
    169a:	mov    rsi,QWORD PTR [rsp+0x30]
    169f:	mov    rdx,r15
    16a2:	mov    rdi,r14
    16a5:	call   16aa <botlish_fn_13+0x142>
			16a6: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    16aa:	test   rax,rax
    16ad:	jne    16bb <botlish_fn_13+0x153>
    16b3:	mov    rdi,r14
    16b6:	jmp    16fa <botlish_fn_13+0x192>
    16bb:	mov    QWORD PTR [rsp],rbx
    16bf:	mov    rcx,r13
    16c2:	mov    QWORD PTR [rsp+0x8],rcx
    16c7:	mov    QWORD PTR [rsp+0x10],rax
    16cc:	mov    QWORD PTR [rsp+0x18],rdx
    16d1:	mov    r15,rdx
    16d4:	mov    QWORD PTR [rsp+0x30],rax
    16d9:	jmp    15e4 <botlish_fn_13+0x7c>
    16de:	mov    rdx,r15
    16e1:	mov    rsi,QWORD PTR [rsp+0x30]
    16e6:	mov    rdi,r14
    16e9:	call   16ee <botlish_fn_13+0x186>
			16ea: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    16ee:	test   rax,rax
    16f1:	jne    1725 <botlish_fn_13+0x1bd>
    16f7:	mov    rdi,r14
    16fa:	mov    rdi,r14
    16fd:	mov    QWORD PTR [rdi],r12
    1700:	xor    rax,rax
    1703:	mov    rbx,QWORD PTR [rsp+0x40]
    1708:	mov    r12,QWORD PTR [rsp+0x48]
    170d:	mov    r13,QWORD PTR [rsp+0x50]
    1712:	mov    r14,QWORD PTR [rsp+0x58]
    1717:	mov    r15,QWORD PTR [rsp+0x60]
    171c:	add    rsp,0x70
    1720:	mov    rsp,rbp
    1723:	pop    rbp
    1724:	ret
    1725:	mov    rdi,r14
    1728:	mov    QWORD PTR [rdi],r12
    172b:	mov    rbx,QWORD PTR [rsp+0x40]
    1730:	mov    r12,QWORD PTR [rsp+0x48]
    1735:	mov    r13,QWORD PTR [rsp+0x50]
    173a:	mov    r14,QWORD PTR [rsp+0x58]
    173f:	mov    r15,QWORD PTR [rsp+0x60]
    1744:	add    rsp,0x70
    1748:	mov    rsp,rbp
    174b:	pop    rbp
    174c:	ret
    174d:	mov    r14,rdi
    1750:	call   1755 <botlish_fn_13+0x1ed>
			1751: R_X86_64_PLT32	rt_stack_overflow-0x4
    1755:	xor    rax,rax
    1758:	mov    rbx,QWORD PTR [rsp+0x40]
    175d:	mov    r12,QWORD PTR [rsp+0x48]
    1762:	mov    r13,QWORD PTR [rsp+0x50]
    1767:	mov    r14,QWORD PTR [rsp+0x58]
    176c:	mov    r15,QWORD PTR [rsp+0x60]
    1771:	add    rsp,0x70
    1775:	mov    rsp,rbp
    1778:	pop    rbp
    1779:	ret
    177a:	add    BYTE PTR [rax],al
    177c:	add    BYTE PTR [rax],al
    177e:	add    BYTE PTR [rax],al
    1780:	(bad)
    1781:	add    BYTE PTR [rax],al
    1783:	add    BYTE PTR [rax],al
    1785:	add    BYTE PTR [rax],al
	...

0000000000001788 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    1788:	push   rbp
    1789:	mov    rbp,rsp
    178c:	mov    rsi,QWORD PTR [rdx]
    178f:	mov    r9,QWORD PTR [rdx+0x8]
    1793:	mov    rcx,QWORD PTR [rdx+0x10]
    1797:	mov    r8,QWORD PTR [rdx+0x18]
    179b:	mov    rdx,r9
    179e:	call   17a3 <botlish_entry_13+0x1b>
			179f: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    17a3:	mov    rsp,rbp
    17a6:	pop    rbp
    17a7:	ret

00000000000017a8 <botlish_fn_14: csv_parse<str>>:
    17a8:	push   rbp
    17a9:	mov    rbp,rsp
    17ac:	sub    rsp,0x40
    17b0:	mov    QWORD PTR [rsp+0x20],rbx
    17b5:	mov    QWORD PTR [rsp+0x28],r12
    17ba:	mov    QWORD PTR [rsp+0x30],r15
    17bf:	mov    r15,QWORD PTR [rdi]
    17c2:	mov    rax,QWORD PTR [rdi+0x8]
    17c6:	lea    rcx,[r15+0x8]
    17ca:	cmp    rcx,rax
    17cd:	ja     188a <botlish_fn_14+0xe2>
    17d3:	lea    rax,[r15+0x8]
    17d7:	mov    QWORD PTR [rdi],rax
    17da:	mov    rbx,rdi
    17dd:	mov    QWORD PTR [r15],0x0
    17e4:	mov    QWORD PTR [rsp+0x10],0x0
    17ed:	mov    QWORD PTR [rsp+0x18],0x0
    17f6:	mov    QWORD PTR [rsp],rsi
    17fa:	mov    r12,rsi
    17fd:	mov    QWORD PTR [rsp+0x8],0x1
    1806:	mov    rdi,rbx
    1809:	call   180e <botlish_fn_14+0x66>
			180a: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    180e:	test   rax,rax
    1811:	jne    181f <botlish_fn_14+0x77>
    1817:	mov    rdi,rbx
    181a:	jmp    184b <botlish_fn_14+0xa3>
    181f:	mov    QWORD PTR [rsp+0x10],rax
    1824:	mov    rcx,rax
    1827:	mov    QWORD PTR [rsp+0x18],rdx
    182c:	mov    r8,rdx
    182f:	mov    edx,0x1
    1834:	mov    rsi,r12
    1837:	mov    rdi,rbx
    183a:	call   183f <botlish_fn_14+0x97>
			183b: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    183f:	test   rax,rax
    1842:	jne    186c <botlish_fn_14+0xc4>
    1848:	mov    rdi,rbx
    184b:	mov    rdi,rbx
    184e:	mov    QWORD PTR [rdi],r15
    1851:	xor    rax,rax
    1854:	mov    rbx,QWORD PTR [rsp+0x20]
    1859:	mov    r12,QWORD PTR [rsp+0x28]
    185e:	mov    r15,QWORD PTR [rsp+0x30]
    1863:	add    rsp,0x40
    1867:	mov    rsp,rbp
    186a:	pop    rbp
    186b:	ret
    186c:	mov    rdi,rbx
    186f:	mov    QWORD PTR [rdi],r15
    1872:	mov    rbx,QWORD PTR [rsp+0x20]
    1877:	mov    r12,QWORD PTR [rsp+0x28]
    187c:	mov    r15,QWORD PTR [rsp+0x30]
    1881:	add    rsp,0x40
    1885:	mov    rsp,rbp
    1888:	pop    rbp
    1889:	ret
    188a:	mov    rbx,rdi
    188d:	call   1892 <botlish_fn_14+0xea>
			188e: R_X86_64_PLT32	rt_stack_overflow-0x4
    1892:	xor    rax,rax
    1895:	mov    rbx,QWORD PTR [rsp+0x20]
    189a:	mov    r12,QWORD PTR [rsp+0x28]
    189f:	mov    r15,QWORD PTR [rsp+0x30]
    18a4:	add    rsp,0x40
    18a8:	mov    rsp,rbp
    18ab:	pop    rbp
    18ac:	ret

00000000000018ad <botlish_entry_14: csv_parse<str>>:
    18ad:	push   rbp
    18ae:	mov    rbp,rsp
    18b1:	mov    rsi,QWORD PTR [rdx]
    18b4:	call   18b9 <botlish_entry_14+0xc>
			18b5: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    18b9:	mov    rsp,rbp
    18bc:	pop    rbp
    18bd:	ret

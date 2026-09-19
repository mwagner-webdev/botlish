; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7032  (per function: 169 184 461 517 396 396 183 469 534 677 887 470 837 584 268)
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
			3b: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
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

00000000000000a3 <botlish_fn_1: geo_new<generic>>:
      a3:	push   rbp
      a4:	mov    rbp,rsp
      a7:	sub    rsp,0x10
      ab:	mov    QWORD PTR [rsp],r13
      af:	mov    QWORD PTR [rsp+0x8],r14
      b4:	mov    r13,QWORD PTR [rdi]
      b7:	mov    rax,QWORD PTR [rdi+0x8]
      bb:	lea    rcx,[r13+0x8]
      bf:	cmp    rcx,rax
      c2:	ja     12b <botlish_fn_1+0x88>
      c8:	lea    rax,[r13+0x8]
      cc:	mov    QWORD PTR [rdi],rax
      cf:	mov    r14,rdi
      d2:	mov    esi,0x1
      d7:	mov    QWORD PTR [r13+0x0],0x1
      df:	mov    rdi,r14
      e2:	call   e7 <botlish_fn_1+0x44>
			e3: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      e7:	test   rax,rax
      ea:	jne    10e <botlish_fn_1+0x6b>
      f0:	mov    rdi,r14
      f3:	mov    QWORD PTR [rdi],r13
      f6:	xor    rdx,rdx
      f9:	mov    rax,rdx
      fc:	mov    r13,QWORD PTR [rsp]
     100:	mov    r14,QWORD PTR [rsp+0x8]
     105:	add    rsp,0x10
     109:	mov    rsp,rbp
     10c:	pop    rbp
     10d:	ret
     10e:	mov    rdi,r14
     111:	mov    QWORD PTR [rdi],r13
     114:	mov    edx,0x1
     119:	mov    r13,QWORD PTR [rsp]
     11d:	mov    r14,QWORD PTR [rsp+0x8]
     122:	add    rsp,0x10
     126:	mov    rsp,rbp
     129:	pop    rbp
     12a:	ret
     12b:	call   130 <botlish_fn_1+0x8d>
			12c: R_X86_64_PLT32	rt_stack_overflow-0x4
     130:	xor    rdx,rdx
     133:	mov    rax,rdx
     136:	mov    r13,QWORD PTR [rsp]
     13a:	mov    r14,QWORD PTR [rsp+0x8]
     13f:	add    rsp,0x10
     143:	mov    rsp,rbp
     146:	pop    rbp
     147:	ret

0000000000000148 <botlish_entry_1: geo_new<generic>>:
     148:	push   rbp
     149:	mov    rbp,rsp
     14c:	ud2
	...

0000000000000150 <botlish_fn_2: geo_new_capacity<int, int>>:
     150:	push   rbp
     151:	mov    rbp,rsp
     154:	sub    rsp,0x20
     158:	mov    QWORD PTR [rsp],rbx
     15c:	mov    QWORD PTR [rsp+0x8],r12
     161:	mov    QWORD PTR [rsp+0x10],r13
     166:	mov    QWORD PTR [rsp+0x18],r14
     16b:	mov    rbx,QWORD PTR [rdi]
     16e:	mov    rax,QWORD PTR [rdi+0x8]
     172:	lea    rcx,[rbx+0x18]
     176:	cmp    rcx,rax
     179:	ja     2af <botlish_fn_2+0x15f>
     17f:	lea    rax,[rbx+0x18]
     183:	mov    QWORD PTR [rdi],rax
     186:	mov    r13,rdi
     189:	mov    QWORD PTR [rbx],rsi
     18c:	mov    QWORD PTR [rbx+0x8],rdx
     190:	mov    r12,rdx
     193:	mov    QWORD PTR [rbx+0x10],0x5
     19b:	test   rsi,0x1
     1a2:	je     1c4 <botlish_fn_2+0x74>
     1a8:	mov    rax,rsi
     1ab:	sar    rax,1
     1ae:	imul   QWORD PTR [rip+0x123]        # 2d8 <botlish_fn_2+0x188>
     1b5:	seto   cl
     1b8:	or     rax,0x1
     1bc:	test   cl,cl
     1be:	je     1d1 <botlish_fn_2+0x81>
     1c4:	mov    edx,0x5
     1c9:	mov    rdi,r13
     1cc:	call   1d1 <botlish_fn_2+0x81>
			1cd: R_X86_64_PLT32	rt_int_mul-0x4
     1d1:	mov    rcx,rax
     1d4:	and    rcx,r12
     1d7:	mov    r14,rax
     1da:	test   rcx,0x1
     1e1:	jne    20d <botlish_fn_2+0xbd>
     1e7:	mov    rdx,r12
     1ea:	mov    rsi,r14
     1ed:	mov    rdi,r13
     1f0:	call   1f5 <botlish_fn_2+0xa5>
			1f1: R_X86_64_PLT32	rt_int_cmp-0x4
     1f5:	mov    ecx,0x2
     1fa:	test   rax,rax
     1fd:	cmovle rcx,QWORD PTR [rip+0xdb]        # 2e0 <botlish_fn_2+0x190>
     205:	mov    rax,r14
     208:	jmp    220 <botlish_fn_2+0xd0>
     20d:	mov    ecx,0x2
     212:	mov    rax,r14
     215:	cmp    rax,r12
     218:	cmovle rcx,QWORD PTR [rip+0xc0]        # 2e0 <botlish_fn_2+0x190>
     220:	cmp    rcx,0x6
     224:	je     24c <botlish_fn_2+0xfc>
     22a:	mov    rdi,r13
     22d:	mov    QWORD PTR [rdi],rbx
     230:	mov    rbx,QWORD PTR [rsp]
     234:	mov    r12,QWORD PTR [rsp+0x8]
     239:	mov    r13,QWORD PTR [rsp+0x10]
     23e:	mov    r14,QWORD PTR [rsp+0x18]
     243:	add    rsp,0x20
     247:	mov    rsp,rbp
     24a:	pop    rbp
     24b:	ret
     24c:	mov    QWORD PTR [rbx],0x3
     253:	test   r12,0x1
     25a:	je     27a <botlish_fn_2+0x12a>
     260:	mov    rax,r12
     263:	add    rax,0x2
     267:	seto   cl
     26a:	test   cl,cl
     26c:	jne    27a <botlish_fn_2+0x12a>
     272:	mov    rdi,r13
     275:	jmp    28d <botlish_fn_2+0x13d>
     27a:	mov    edx,0x3
     27f:	mov    rsi,r12
     282:	mov    rdi,r13
     285:	call   28a <botlish_fn_2+0x13a>
			286: R_X86_64_PLT32	rt_int_add-0x4
     28a:	mov    rdi,r13
     28d:	mov    rdi,r13
     290:	mov    QWORD PTR [rdi],rbx
     293:	mov    rbx,QWORD PTR [rsp]
     297:	mov    r12,QWORD PTR [rsp+0x8]
     29c:	mov    r13,QWORD PTR [rsp+0x10]
     2a1:	mov    r14,QWORD PTR [rsp+0x18]
     2a6:	add    rsp,0x20
     2aa:	mov    rsp,rbp
     2ad:	pop    rbp
     2ae:	ret
     2af:	mov    r13,rdi
     2b2:	call   2b7 <botlish_fn_2+0x167>
			2b3: R_X86_64_PLT32	rt_stack_overflow-0x4
     2b7:	xor    rax,rax
     2ba:	mov    rbx,QWORD PTR [rsp]
     2be:	mov    r12,QWORD PTR [rsp+0x8]
     2c3:	mov    r13,QWORD PTR [rsp+0x10]
     2c8:	mov    r14,QWORD PTR [rsp+0x18]
     2cd:	add    rsp,0x20
     2d1:	mov    rsp,rbp
     2d4:	pop    rbp
     2d5:	ret
     2d6:	add    BYTE PTR [rax],al
     2d8:	add    al,0x0
     2da:	add    BYTE PTR [rax],al
     2dc:	add    BYTE PTR [rax],al
     2de:	add    BYTE PTR [rax],al
     2e0:	(bad)
     2e1:	add    BYTE PTR [rax],al
     2e3:	add    BYTE PTR [rax],al
     2e5:	add    BYTE PTR [rax],al
	...

00000000000002e8 <botlish_entry_2: geo_new_capacity<int, int>>:
     2e8:	push   rbp
     2e9:	mov    rbp,rsp
     2ec:	mov    rsi,QWORD PTR [rdx]
     2ef:	mov    rdx,QWORD PTR [rdx+0x8]
     2f3:	call   2f8 <botlish_entry_2+0x10>
			2f4: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     2f8:	mov    rsp,rbp
     2fb:	pop    rbp
     2fc:	ret
     2fd:	add    BYTE PTR [rax],al
	...

0000000000000300 <botlish_fn_3: geo_grow<mutarray, int>>:
     300:	push   rbp
     301:	mov    rbp,rsp
     304:	sub    rsp,0x30
     308:	mov    QWORD PTR [rsp],rbx
     30c:	mov    QWORD PTR [rsp+0x8],r12
     311:	mov    QWORD PTR [rsp+0x10],r13
     316:	mov    QWORD PTR [rsp+0x18],r14
     31b:	mov    QWORD PTR [rsp+0x20],r15
     320:	mov    rbx,QWORD PTR [rdi]
     323:	mov    rax,QWORD PTR [rdi+0x8]
     327:	lea    rcx,[rbx+0x18]
     32b:	cmp    rcx,rax
     32e:	ja     499 <botlish_fn_3+0x199>
     334:	lea    rax,[rbx+0x18]
     338:	mov    QWORD PTR [rdi],rax
     33b:	mov    r13,rdi
     33e:	mov    QWORD PTR [rbx],rsi
     341:	mov    r14,rsi
     344:	mov    QWORD PTR [rbx+0x8],rdx
     348:	mov    r12,rdx
     34b:	mov    rsi,r14
     34e:	mov    rdi,r13
     351:	call   356 <botlish_fn_3+0x56>
			352: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     356:	mov    r15,rax
     359:	mov    QWORD PTR [rbx+0x10],rax
     35d:	mov    rcx,r12
     360:	and    rcx,rax
     363:	test   rcx,0x1
     36a:	jne    396 <botlish_fn_3+0x96>
     370:	mov    rdx,r15
     373:	mov    rsi,r12
     376:	mov    rdi,r13
     379:	call   37e <botlish_fn_3+0x7e>
			37a: R_X86_64_PLT32	rt_int_cmp-0x4
     37e:	mov    ecx,0x2
     383:	test   rax,rax
     386:	cmovl  rcx,QWORD PTR [rip+0x13a]        # 4c8 <botlish_fn_3+0x1c8>
     38e:	mov    rax,r15
     391:	jmp    3a9 <botlish_fn_3+0xa9>
     396:	mov    ecx,0x2
     39b:	mov    rax,r15
     39e:	cmp    r12,rax
     3a1:	cmovl  rcx,QWORD PTR [rip+0x11f]        # 4c8 <botlish_fn_3+0x1c8>
     3a9:	cmp    rcx,0x6
     3ad:	je     46f <botlish_fn_3+0x16f>
     3b3:	mov    rsi,rax
     3b6:	mov    rdx,r12
     3b9:	mov    rdi,r13
     3bc:	call   3c1 <botlish_fn_3+0xc1>
			3bd: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     3c1:	test   rax,rax
     3c4:	jne    3d2 <botlish_fn_3+0xd2>
     3ca:	mov    rdi,r13
     3cd:	jmp    41b <botlish_fn_3+0x11b>
     3d2:	mov    QWORD PTR [rbx+0x10],rax
     3d6:	mov    rsi,rax
     3d9:	mov    rdi,r13
     3dc:	call   3e1 <botlish_fn_3+0xe1>
			3dd: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3e1:	test   rax,rax
     3e4:	mov    r15,rax
     3e7:	jne    3f5 <botlish_fn_3+0xf5>
     3ed:	mov    rdi,r13
     3f0:	jmp    41b <botlish_fn_3+0x11b>
     3f5:	mov    r8d,0x1
     3fb:	mov    rcx,r14
     3fe:	mov    r9,r12
     401:	mov    rsi,r15
     404:	mov    rdi,r13
     407:	mov    rdx,r8
     40a:	call   40f <botlish_fn_3+0x10f>
			40b: R_X86_64_PLT32	rt_mutarray_copy-0x4
     40f:	test   rax,rax
     412:	jne    445 <botlish_fn_3+0x145>
     418:	mov    rdi,r13
     41b:	mov    rdi,r13
     41e:	mov    QWORD PTR [rdi],rbx
     421:	xor    rax,rax
     424:	mov    rbx,QWORD PTR [rsp]
     428:	mov    r12,QWORD PTR [rsp+0x8]
     42d:	mov    r13,QWORD PTR [rsp+0x10]
     432:	mov    r14,QWORD PTR [rsp+0x18]
     437:	mov    r15,QWORD PTR [rsp+0x20]
     43c:	add    rsp,0x30
     440:	mov    rsp,rbp
     443:	pop    rbp
     444:	ret
     445:	mov    rdi,r13
     448:	mov    QWORD PTR [rdi],rbx
     44b:	mov    rax,r15
     44e:	mov    rbx,QWORD PTR [rsp]
     452:	mov    r12,QWORD PTR [rsp+0x8]
     457:	mov    r13,QWORD PTR [rsp+0x10]
     45c:	mov    r14,QWORD PTR [rsp+0x18]
     461:	mov    r15,QWORD PTR [rsp+0x20]
     466:	add    rsp,0x30
     46a:	mov    rsp,rbp
     46d:	pop    rbp
     46e:	ret
     46f:	mov    rdi,r13
     472:	mov    QWORD PTR [rdi],rbx
     475:	mov    rax,r14
     478:	mov    rbx,QWORD PTR [rsp]
     47c:	mov    r12,QWORD PTR [rsp+0x8]
     481:	mov    r13,QWORD PTR [rsp+0x10]
     486:	mov    r14,QWORD PTR [rsp+0x18]
     48b:	mov    r15,QWORD PTR [rsp+0x20]
     490:	add    rsp,0x30
     494:	mov    rsp,rbp
     497:	pop    rbp
     498:	ret
     499:	mov    r13,rdi
     49c:	call   4a1 <botlish_fn_3+0x1a1>
			49d: R_X86_64_PLT32	rt_stack_overflow-0x4
     4a1:	xor    rax,rax
     4a4:	mov    rbx,QWORD PTR [rsp]
     4a8:	mov    r12,QWORD PTR [rsp+0x8]
     4ad:	mov    r13,QWORD PTR [rsp+0x10]
     4b2:	mov    r14,QWORD PTR [rsp+0x18]
     4b7:	mov    r15,QWORD PTR [rsp+0x20]
     4bc:	add    rsp,0x30
     4c0:	mov    rsp,rbp
     4c3:	pop    rbp
     4c4:	ret
     4c5:	add    BYTE PTR [rax],al
     4c7:	add    BYTE PTR [rsi],al
     4c9:	add    BYTE PTR [rax],al
     4cb:	add    BYTE PTR [rax],al
     4cd:	add    BYTE PTR [rax],al
	...

00000000000004d0 <botlish_entry_3: geo_grow<mutarray, int>>:
     4d0:	push   rbp
     4d1:	mov    rbp,rsp
     4d4:	mov    rsi,QWORD PTR [rdx]
     4d7:	mov    rdx,QWORD PTR [rdx+0x8]
     4db:	call   4e0 <botlish_entry_3+0x10>
			4dc: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     4e0:	mov    rsp,rbp
     4e3:	pop    rbp
     4e4:	ret

00000000000004e5 <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     4e5:	push   rbp
     4e6:	mov    rbp,rsp
     4e9:	sub    rsp,0x30
     4ed:	mov    QWORD PTR [rsp],rbx
     4f1:	mov    QWORD PTR [rsp+0x8],r12
     4f6:	mov    QWORD PTR [rsp+0x10],r13
     4fb:	mov    QWORD PTR [rsp+0x18],r14
     500:	mov    QWORD PTR [rsp+0x20],r15
     505:	mov    r12,QWORD PTR [rdi]
     508:	mov    r8,QWORD PTR [rdi+0x8]
     50c:	lea    rax,[r12+0x18]
     511:	cmp    rax,r8
     514:	ja     627 <botlish_fn_4+0x142>
     51a:	lea    rax,[r12+0x18]
     51f:	mov    QWORD PTR [rdi],rax
     522:	mov    r13,rdi
     525:	mov    QWORD PTR [r12],rsi
     529:	mov    QWORD PTR [r12+0x8],rdx
     52e:	mov    rdi,rdx
     531:	mov    QWORD PTR [r12+0x10],rcx
     536:	mov    r15,rcx
     539:	mov    rbx,rdi
     53c:	mov    rdx,rbx
     53f:	mov    rdi,r13
     542:	call   547 <botlish_fn_4+0x62>
			543: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     547:	test   rax,rax
     54a:	mov    r14,rax
     54d:	jne    55b <botlish_fn_4+0x76>
     553:	mov    rdi,r13
     556:	jmp    57f <botlish_fn_4+0x9a>
     55b:	mov    rax,r14
     55e:	mov    QWORD PTR [r12],rax
     562:	mov    rcx,r15
     565:	mov    rdx,rbx
     568:	mov    rsi,r14
     56b:	mov    rdi,r13
     56e:	call   573 <botlish_fn_4+0x8e>
			56f: R_X86_64_PLT32	rt_mutarray_set-0x4
     573:	test   rax,rax
     576:	jne    5ac <botlish_fn_4+0xc7>
     57c:	mov    rdi,r13
     57f:	mov    rdi,r13
     582:	mov    QWORD PTR [rdi],r12
     585:	xor    rdx,rdx
     588:	mov    rax,rdx
     58b:	mov    rbx,QWORD PTR [rsp]
     58f:	mov    r12,QWORD PTR [rsp+0x8]
     594:	mov    r13,QWORD PTR [rsp+0x10]
     599:	mov    r14,QWORD PTR [rsp+0x18]
     59e:	mov    r15,QWORD PTR [rsp+0x20]
     5a3:	add    rsp,0x30
     5a7:	mov    rsp,rbp
     5aa:	pop    rbp
     5ab:	ret
     5ac:	mov    QWORD PTR [r12+0x10],0x3
     5b5:	test   rbx,0x1
     5bc:	jne    5ca <botlish_fn_4+0xe5>
     5c2:	mov    rdi,rbx
     5c5:	jmp    5e7 <botlish_fn_4+0x102>
     5ca:	mov    rdx,rbx
     5cd:	add    rdx,0x2
     5d1:	mov    rdi,rbx
     5d4:	seto   al
     5d7:	test   al,al
     5d9:	jne    5e7 <botlish_fn_4+0x102>
     5df:	mov    rdi,r13
     5e2:	jmp    5fd <botlish_fn_4+0x118>
     5e7:	mov    edx,0x3
     5ec:	mov    rsi,rdi
     5ef:	mov    rdi,r13
     5f2:	call   5f7 <botlish_fn_4+0x112>
			5f3: R_X86_64_PLT32	rt_int_add-0x4
     5f7:	mov    rdx,rax
     5fa:	mov    rdi,r13
     5fd:	mov    rdi,r13
     600:	mov    QWORD PTR [rdi],r12
     603:	mov    rax,r14
     606:	mov    rbx,QWORD PTR [rsp]
     60a:	mov    r12,QWORD PTR [rsp+0x8]
     60f:	mov    r13,QWORD PTR [rsp+0x10]
     614:	mov    r14,QWORD PTR [rsp+0x18]
     619:	mov    r15,QWORD PTR [rsp+0x20]
     61e:	add    rsp,0x30
     622:	mov    rsp,rbp
     625:	pop    rbp
     626:	ret
     627:	mov    r13,rdi
     62a:	call   62f <botlish_fn_4+0x14a>
			62b: R_X86_64_PLT32	rt_stack_overflow-0x4
     62f:	xor    rdx,rdx
     632:	mov    rax,rdx
     635:	mov    rbx,QWORD PTR [rsp]
     639:	mov    r12,QWORD PTR [rsp+0x8]
     63e:	mov    r13,QWORD PTR [rsp+0x10]
     643:	mov    r14,QWORD PTR [rsp+0x18]
     648:	mov    r15,QWORD PTR [rsp+0x20]
     64d:	add    rsp,0x30
     651:	mov    rsp,rbp
     654:	pop    rbp
     655:	ret

0000000000000656 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     656:	push   rbp
     657:	mov    rbp,rsp
     65a:	ud2

000000000000065c <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     65c:	push   rbp
     65d:	mov    rbp,rsp
     660:	sub    rsp,0x30
     664:	mov    QWORD PTR [rsp],rbx
     668:	mov    QWORD PTR [rsp+0x8],r12
     66d:	mov    QWORD PTR [rsp+0x10],r13
     672:	mov    QWORD PTR [rsp+0x18],r14
     677:	mov    QWORD PTR [rsp+0x20],r15
     67c:	mov    r12,QWORD PTR [rdi]
     67f:	mov    r8,QWORD PTR [rdi+0x8]
     683:	lea    rax,[r12+0x18]
     688:	cmp    rax,r8
     68b:	ja     79e <botlish_fn_5+0x142>
     691:	lea    rax,[r12+0x18]
     696:	mov    QWORD PTR [rdi],rax
     699:	mov    r13,rdi
     69c:	mov    QWORD PTR [r12],rsi
     6a0:	mov    QWORD PTR [r12+0x8],rdx
     6a5:	mov    rdi,rdx
     6a8:	mov    QWORD PTR [r12+0x10],rcx
     6ad:	mov    r15,rcx
     6b0:	mov    rbx,rdi
     6b3:	mov    rdx,rbx
     6b6:	mov    rdi,r13
     6b9:	call   6be <botlish_fn_5+0x62>
			6ba: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     6be:	test   rax,rax
     6c1:	mov    r14,rax
     6c4:	jne    6d2 <botlish_fn_5+0x76>
     6ca:	mov    rdi,r13
     6cd:	jmp    6f6 <botlish_fn_5+0x9a>
     6d2:	mov    rax,r14
     6d5:	mov    QWORD PTR [r12],rax
     6d9:	mov    rcx,r15
     6dc:	mov    rdx,rbx
     6df:	mov    rsi,r14
     6e2:	mov    rdi,r13
     6e5:	call   6ea <botlish_fn_5+0x8e>
			6e6: R_X86_64_PLT32	rt_mutarray_set-0x4
     6ea:	test   rax,rax
     6ed:	jne    723 <botlish_fn_5+0xc7>
     6f3:	mov    rdi,r13
     6f6:	mov    rdi,r13
     6f9:	mov    QWORD PTR [rdi],r12
     6fc:	xor    rdx,rdx
     6ff:	mov    rax,rdx
     702:	mov    rbx,QWORD PTR [rsp]
     706:	mov    r12,QWORD PTR [rsp+0x8]
     70b:	mov    r13,QWORD PTR [rsp+0x10]
     710:	mov    r14,QWORD PTR [rsp+0x18]
     715:	mov    r15,QWORD PTR [rsp+0x20]
     71a:	add    rsp,0x30
     71e:	mov    rsp,rbp
     721:	pop    rbp
     722:	ret
     723:	mov    QWORD PTR [r12+0x10],0x3
     72c:	test   rbx,0x1
     733:	jne    741 <botlish_fn_5+0xe5>
     739:	mov    rdi,rbx
     73c:	jmp    75e <botlish_fn_5+0x102>
     741:	mov    rdx,rbx
     744:	add    rdx,0x2
     748:	mov    rdi,rbx
     74b:	seto   al
     74e:	test   al,al
     750:	jne    75e <botlish_fn_5+0x102>
     756:	mov    rdi,r13
     759:	jmp    774 <botlish_fn_5+0x118>
     75e:	mov    edx,0x3
     763:	mov    rsi,rdi
     766:	mov    rdi,r13
     769:	call   76e <botlish_fn_5+0x112>
			76a: R_X86_64_PLT32	rt_int_add-0x4
     76e:	mov    rdx,rax
     771:	mov    rdi,r13
     774:	mov    rdi,r13
     777:	mov    QWORD PTR [rdi],r12
     77a:	mov    rax,r14
     77d:	mov    rbx,QWORD PTR [rsp]
     781:	mov    r12,QWORD PTR [rsp+0x8]
     786:	mov    r13,QWORD PTR [rsp+0x10]
     78b:	mov    r14,QWORD PTR [rsp+0x18]
     790:	mov    r15,QWORD PTR [rsp+0x20]
     795:	add    rsp,0x30
     799:	mov    rsp,rbp
     79c:	pop    rbp
     79d:	ret
     79e:	mov    r13,rdi
     7a1:	call   7a6 <botlish_fn_5+0x14a>
			7a2: R_X86_64_PLT32	rt_stack_overflow-0x4
     7a6:	xor    rdx,rdx
     7a9:	mov    rax,rdx
     7ac:	mov    rbx,QWORD PTR [rsp]
     7b0:	mov    r12,QWORD PTR [rsp+0x8]
     7b5:	mov    r13,QWORD PTR [rsp+0x10]
     7ba:	mov    r14,QWORD PTR [rsp+0x18]
     7bf:	mov    r15,QWORD PTR [rsp+0x20]
     7c4:	add    rsp,0x30
     7c8:	mov    rsp,rbp
     7cb:	pop    rbp
     7cc:	ret

00000000000007cd <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     7cd:	push   rbp
     7ce:	mov    rbp,rsp
     7d1:	ud2

00000000000007d3 <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     7d3:	push   rbp
     7d4:	mov    rbp,rsp
     7d7:	sub    rsp,0x10
     7db:	mov    QWORD PTR [rsp],r13
     7df:	mov    QWORD PTR [rsp+0x8],r14
     7e4:	mov    r13,QWORD PTR [rdi]
     7e7:	mov    rax,QWORD PTR [rdi+0x8]
     7eb:	lea    rcx,[r13+0x10]
     7ef:	cmp    rcx,rax
     7f2:	ja     84e <botlish_fn_6+0x7b>
     7f8:	lea    rax,[r13+0x10]
     7fc:	mov    QWORD PTR [rdi],rax
     7ff:	mov    r14,rdi
     802:	mov    QWORD PTR [r13+0x0],rsi
     806:	mov    QWORD PTR [r13+0x8],rdx
     80a:	mov    rdi,r14
     80d:	call   812 <botlish_fn_6+0x3f>
			80e: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     812:	test   rax,rax
     815:	jne    836 <botlish_fn_6+0x63>
     81b:	mov    rdi,r14
     81e:	mov    QWORD PTR [rdi],r13
     821:	xor    rax,rax
     824:	mov    r13,QWORD PTR [rsp]
     828:	mov    r14,QWORD PTR [rsp+0x8]
     82d:	add    rsp,0x10
     831:	mov    rsp,rbp
     834:	pop    rbp
     835:	ret
     836:	mov    rdi,r14
     839:	mov    QWORD PTR [rdi],r13
     83c:	mov    r13,QWORD PTR [rsp]
     840:	mov    r14,QWORD PTR [rsp+0x8]
     845:	add    rsp,0x10
     849:	mov    rsp,rbp
     84c:	pop    rbp
     84d:	ret
     84e:	call   853 <botlish_fn_6+0x80>
			84f: R_X86_64_PLT32	rt_stack_overflow-0x4
     853:	xor    rax,rax
     856:	mov    r13,QWORD PTR [rsp]
     85a:	mov    r14,QWORD PTR [rsp+0x8]
     85f:	add    rsp,0x10
     863:	mov    rsp,rbp
     866:	pop    rbp
     867:	ret

0000000000000868 <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     868:	push   rbp
     869:	mov    rbp,rsp
     86c:	mov    rsi,QWORD PTR [rdx]
     86f:	mov    rdx,QWORD PTR [rdx+0x8]
     873:	call   878 <botlish_entry_6+0x10>
			874: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     878:	mov    rsp,rbp
     87b:	pop    rbp
     87c:	ret
     87d:	add    BYTE PTR [rax],al
	...

0000000000000880 <botlish_fn_7: peek<str, int>>:
     880:	push   rbp
     881:	mov    rbp,rsp
     884:	sub    rsp,0x20
     888:	mov    QWORD PTR [rsp],rbx
     88c:	mov    QWORD PTR [rsp+0x8],r12
     891:	mov    QWORD PTR [rsp+0x10],r13
     896:	mov    QWORD PTR [rsp+0x18],r14
     89b:	mov    r12,QWORD PTR [rdi]
     89e:	mov    rax,QWORD PTR [rdi+0x8]
     8a2:	lea    rcx,[r12+0x18]
     8a7:	cmp    rcx,rax
     8aa:	ja     9ed <botlish_fn_7+0x16d>
     8b0:	lea    rax,[r12+0x18]
     8b5:	mov    QWORD PTR [rdi],rax
     8b8:	mov    r13,rdi
     8bb:	mov    QWORD PTR [r12],rsi
     8bf:	mov    r14,rsi
     8c2:	mov    QWORD PTR [r12+0x8],rdx
     8c7:	mov    rbx,rdx
     8ca:	mov    rsi,r14
     8cd:	mov    rdi,r13
     8d0:	call   8d5 <botlish_fn_7+0x55>
			8d1: R_X86_64_PLT32	rt_str_len-0x4
     8d5:	mov    rcx,rbx
     8d8:	and    rcx,rax
     8db:	mov    rdx,rax
     8de:	test   rcx,0x1
     8e5:	jne    90b <botlish_fn_7+0x8b>
     8eb:	mov    rsi,rbx
     8ee:	mov    rdi,r13
     8f1:	call   8f6 <botlish_fn_7+0x76>
			8f2: R_X86_64_PLT32	rt_int_cmp-0x4
     8f6:	mov    ecx,0x2
     8fb:	test   rax,rax
     8fe:	cmovge rcx,QWORD PTR [rip+0x112]        # a18 <botlish_fn_7+0x198>
     906:	jmp    91b <botlish_fn_7+0x9b>
     90b:	mov    ecx,0x2
     910:	cmp    rbx,rdx
     913:	cmovge rcx,QWORD PTR [rip+0xfd]        # a18 <botlish_fn_7+0x198>
     91b:	cmp    rcx,0x6
     91f:	je     9c3 <botlish_fn_7+0x143>
     925:	mov    QWORD PTR [r12+0x10],0x3
     92e:	test   rbx,0x1
     935:	je     94d <botlish_fn_7+0xcd>
     93b:	mov    rcx,rbx
     93e:	add    rcx,0x2
     942:	seto   al
     945:	test   al,al
     947:	je     960 <botlish_fn_7+0xe0>
     94d:	mov    edx,0x3
     952:	mov    rsi,rbx
     955:	mov    rdi,r13
     958:	call   95d <botlish_fn_7+0xdd>
			959: R_X86_64_PLT32	rt_int_add-0x4
     95d:	mov    rcx,rax
     960:	mov    QWORD PTR [r12+0x10],rcx
     965:	mov    rdx,rbx
     968:	mov    rsi,r14
     96b:	mov    rdi,r13
     96e:	call   973 <botlish_fn_7+0xf3>
			96f: R_X86_64_PLT32	rt_substr-0x4
     973:	test   rax,rax
     976:	jne    9a1 <botlish_fn_7+0x121>
     97c:	mov    rdi,r13
     97f:	mov    QWORD PTR [rdi],r12
     982:	xor    rax,rax
     985:	mov    rbx,QWORD PTR [rsp]
     989:	mov    r12,QWORD PTR [rsp+0x8]
     98e:	mov    r13,QWORD PTR [rsp+0x10]
     993:	mov    r14,QWORD PTR [rsp+0x18]
     998:	add    rsp,0x20
     99c:	mov    rsp,rbp
     99f:	pop    rbp
     9a0:	ret
     9a1:	mov    rdi,r13
     9a4:	mov    QWORD PTR [rdi],r12
     9a7:	mov    rbx,QWORD PTR [rsp]
     9ab:	mov    r12,QWORD PTR [rsp+0x8]
     9b0:	mov    r13,QWORD PTR [rsp+0x10]
     9b5:	mov    r14,QWORD PTR [rsp+0x18]
     9ba:	add    rsp,0x20
     9be:	mov    rsp,rbp
     9c1:	pop    rbp
     9c2:	ret
     9c3:	mov    rdi,r13
     9c6:	mov    rax,QWORD PTR [rdi+0x10]
     9ca:	mov    rax,QWORD PTR [rax+0x8]
     9ce:	mov    QWORD PTR [rdi],r12
     9d1:	mov    rbx,QWORD PTR [rsp]
     9d5:	mov    r12,QWORD PTR [rsp+0x8]
     9da:	mov    r13,QWORD PTR [rsp+0x10]
     9df:	mov    r14,QWORD PTR [rsp+0x18]
     9e4:	add    rsp,0x20
     9e8:	mov    rsp,rbp
     9eb:	pop    rbp
     9ec:	ret
     9ed:	mov    r13,rdi
     9f0:	call   9f5 <botlish_fn_7+0x175>
			9f1: R_X86_64_PLT32	rt_stack_overflow-0x4
     9f5:	xor    rax,rax
     9f8:	mov    rbx,QWORD PTR [rsp]
     9fc:	mov    r12,QWORD PTR [rsp+0x8]
     a01:	mov    r13,QWORD PTR [rsp+0x10]
     a06:	mov    r14,QWORD PTR [rsp+0x18]
     a0b:	add    rsp,0x20
     a0f:	mov    rsp,rbp
     a12:	pop    rbp
     a13:	ret
     a14:	add    BYTE PTR [rax],al
     a16:	add    BYTE PTR [rax],al
     a18:	(bad)
     a19:	add    BYTE PTR [rax],al
     a1b:	add    BYTE PTR [rax],al
     a1d:	add    BYTE PTR [rax],al
	...

0000000000000a20 <botlish_entry_7: peek<str, int>>:
     a20:	push   rbp
     a21:	mov    rbp,rsp
     a24:	mov    rsi,QWORD PTR [rdx]
     a27:	mov    rdx,QWORD PTR [rdx+0x8]
     a2b:	call   a30 <botlish_entry_7+0x10>
			a2c: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     a30:	mov    rsp,rbp
     a33:	pop    rbp
     a34:	ret
     a35:	add    BYTE PTR [rax],al
	...

0000000000000a38 <botlish_fn_8: peek<str, int>>:
     a38:	push   rbp
     a39:	mov    rbp,rsp
     a3c:	sub    rsp,0x40
     a40:	mov    QWORD PTR [rsp+0x10],rbx
     a45:	mov    QWORD PTR [rsp+0x18],r12
     a4a:	mov    QWORD PTR [rsp+0x20],r13
     a4f:	mov    QWORD PTR [rsp+0x28],r14
     a54:	mov    QWORD PTR [rsp+0x30],r15
     a59:	mov    r13,rcx
     a5c:	mov    r12,QWORD PTR [rdi]
     a5f:	mov    rax,QWORD PTR [rdi+0x8]
     a63:	lea    rcx,[r12+0x18]
     a68:	cmp    rcx,rax
     a6b:	ja     bec <botlish_fn_8+0x1b4>
     a71:	lea    rax,[r12+0x18]
     a76:	mov    QWORD PTR [rdi],rax
     a79:	mov    r15,rdi
     a7c:	mov    QWORD PTR [r12],rsi
     a80:	mov    r14,rsi
     a83:	mov    QWORD PTR [r12+0x8],rdx
     a88:	mov    rbx,rdx
     a8b:	mov    rsi,r14
     a8e:	mov    rdi,r15
     a91:	call   a96 <botlish_fn_8+0x5e>
			a92: R_X86_64_PLT32	rt_str_len-0x4
     a96:	mov    rcx,rbx
     a99:	and    rcx,rax
     a9c:	mov    rdx,rax
     a9f:	test   rcx,0x1
     aa6:	jne    acc <botlish_fn_8+0x94>
     aac:	mov    rsi,rbx
     aaf:	mov    rdi,r15
     ab2:	call   ab7 <botlish_fn_8+0x7f>
			ab3: R_X86_64_PLT32	rt_int_cmp-0x4
     ab7:	mov    ecx,0x2
     abc:	test   rax,rax
     abf:	cmovge rcx,QWORD PTR [rip+0x159]        # c20 <botlish_fn_8+0x1e8>
     ac7:	jmp    adc <botlish_fn_8+0xa4>
     acc:	mov    ecx,0x2
     ad1:	cmp    rbx,rdx
     ad4:	cmovge rcx,QWORD PTR [rip+0x144]        # c20 <botlish_fn_8+0x1e8>
     adc:	cmp    rcx,0x6
     ae0:	je     baa <botlish_fn_8+0x172>
     ae6:	mov    QWORD PTR [r12+0x10],0x3
     aef:	test   rbx,0x1
     af6:	je     b17 <botlish_fn_8+0xdf>
     afc:	mov    rax,rbx
     aff:	add    rax,0x2
     b03:	seto   cl
     b06:	test   cl,cl
     b08:	jne    b17 <botlish_fn_8+0xdf>
     b0e:	mov    QWORD PTR [rsp],rax
     b12:	jmp    b2b <botlish_fn_8+0xf3>
     b17:	mov    edx,0x3
     b1c:	mov    rsi,rbx
     b1f:	mov    rdi,r15
     b22:	call   b27 <botlish_fn_8+0xef>
			b23: R_X86_64_PLT32	rt_int_add-0x4
     b27:	mov    QWORD PTR [rsp],rax
     b2b:	mov    rcx,QWORD PTR [rsp]
     b2f:	mov    rdx,rbx
     b32:	mov    rsi,r14
     b35:	mov    rdi,r15
     b38:	call   b3d <botlish_fn_8+0x105>
			b39: R_X86_64_PLT32	rt_str_region_check-0x4
     b3d:	test   rax,rax
     b40:	jne    b71 <botlish_fn_8+0x139>
     b46:	mov    rdi,r15
     b49:	mov    QWORD PTR [rdi],r12
     b4c:	xor    rax,rax
     b4f:	mov    rbx,QWORD PTR [rsp+0x10]
     b54:	mov    r12,QWORD PTR [rsp+0x18]
     b59:	mov    r13,QWORD PTR [rsp+0x20]
     b5e:	mov    r14,QWORD PTR [rsp+0x28]
     b63:	mov    r15,QWORD PTR [rsp+0x30]
     b68:	add    rsp,0x40
     b6c:	mov    rsp,rbp
     b6f:	pop    rbp
     b70:	ret
     b71:	mov    rdi,r15
     b74:	mov    QWORD PTR [rdi],r12
     b77:	mov    rcx,r13
     b7a:	mov    QWORD PTR [rcx],rbx
     b7d:	mov    rax,QWORD PTR [rsp]
     b81:	mov    QWORD PTR [rcx+0x8],rax
     b85:	mov    rax,r14
     b88:	mov    rbx,QWORD PTR [rsp+0x10]
     b8d:	mov    r12,QWORD PTR [rsp+0x18]
     b92:	mov    r13,QWORD PTR [rsp+0x20]
     b97:	mov    r14,QWORD PTR [rsp+0x28]
     b9c:	mov    r15,QWORD PTR [rsp+0x30]
     ba1:	add    rsp,0x40
     ba5:	mov    rsp,rbp
     ba8:	pop    rbp
     ba9:	ret
     baa:	mov    rcx,r13
     bad:	mov    rdi,r15
     bb0:	mov    rax,QWORD PTR [rdi+0x10]
     bb4:	mov    rax,QWORD PTR [rax+0x8]
     bb8:	mov    QWORD PTR [rdi],r12
     bbb:	mov    QWORD PTR [rcx],0x1
     bc2:	mov    QWORD PTR [rcx+0x8],0x1
     bca:	mov    rbx,QWORD PTR [rsp+0x10]
     bcf:	mov    r12,QWORD PTR [rsp+0x18]
     bd4:	mov    r13,QWORD PTR [rsp+0x20]
     bd9:	mov    r14,QWORD PTR [rsp+0x28]
     bde:	mov    r15,QWORD PTR [rsp+0x30]
     be3:	add    rsp,0x40
     be7:	mov    rsp,rbp
     bea:	pop    rbp
     beb:	ret
     bec:	mov    r15,rdi
     bef:	call   bf4 <botlish_fn_8+0x1bc>
			bf0: R_X86_64_PLT32	rt_stack_overflow-0x4
     bf4:	xor    rax,rax
     bf7:	mov    rbx,QWORD PTR [rsp+0x10]
     bfc:	mov    r12,QWORD PTR [rsp+0x18]
     c01:	mov    r13,QWORD PTR [rsp+0x20]
     c06:	mov    r14,QWORD PTR [rsp+0x28]
     c0b:	mov    r15,QWORD PTR [rsp+0x30]
     c10:	add    rsp,0x40
     c14:	mov    rsp,rbp
     c17:	pop    rbp
     c18:	ret
     c19:	add    BYTE PTR [rax],al
     c1b:	add    BYTE PTR [rax],al
     c1d:	add    BYTE PTR [rax],al
     c1f:	add    BYTE PTR [rsi],al
     c21:	add    BYTE PTR [rax],al
     c23:	add    BYTE PTR [rax],al
     c25:	add    BYTE PTR [rax],al
	...

0000000000000c28 <botlish_entry_8: peek<str, int>>:
     c28:	push   rbp
     c29:	mov    rbp,rsp
     c2c:	ud2

0000000000000c2e <botlish_fn_9: scan_unquoted<str, int, int>>:
     c2e:	push   rbp
     c2f:	mov    rbp,rsp
     c32:	sub    rsp,0x60
     c36:	mov    QWORD PTR [rsp+0x30],rbx
     c3b:	mov    QWORD PTR [rsp+0x38],r12
     c40:	mov    QWORD PTR [rsp+0x40],r13
     c45:	mov    QWORD PTR [rsp+0x48],r14
     c4a:	mov    QWORD PTR [rsp+0x50],r15
     c4f:	mov    r14,QWORD PTR [rdi]
     c52:	mov    rax,QWORD PTR [rdi+0x8]
     c56:	lea    r8,[r14+0x20]
     c5a:	cmp    r8,rax
     c5d:	ja     e6e <botlish_fn_9+0x240>
     c63:	lea    rax,[r14+0x20]
     c67:	mov    QWORD PTR [rdi],rax
     c6a:	mov    r15,rdi
     c6d:	mov    QWORD PTR [r14+0x18],0x0
     c75:	mov    QWORD PTR [r14],rsi
     c78:	mov    QWORD PTR [rsp+0x10],rsi
     c7d:	mov    QWORD PTR [r14+0x8],rdx
     c81:	mov    QWORD PTR [rsp+0x18],rdx
     c86:	mov    QWORD PTR [r14+0x10],rcx
     c8a:	lea    rbx,[rsp]
     c8e:	mov    QWORD PTR [rsp+0x20],rcx
     c93:	mov    rcx,rbx
     c96:	mov    rdx,QWORD PTR [rsp+0x20]
     c9b:	mov    rsi,QWORD PTR [rsp+0x10]
     ca0:	mov    rdi,r15
     ca3:	call   ca8 <botlish_fn_9+0x7a>
			ca4: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     ca8:	mov    rcx,rax
     cab:	mov    QWORD PTR [rsp+0x28],rax
     cb0:	test   rax,rcx
     cb3:	jne    cc1 <botlish_fn_9+0x93>
     cb9:	mov    rdi,r15
     cbc:	jmp    e13 <botlish_fn_9+0x1e5>
     cc1:	mov    r12,QWORD PTR [rsp]
     cc5:	mov    r13,QWORD PTR [rsp+0x8]
     cca:	mov    rdi,r15
     ccd:	mov    rcx,QWORD PTR [rdi+0x10]
     cd1:	mov    r8,QWORD PTR [rcx+0x8]
     cd5:	mov    rcx,r13
     cd8:	mov    rdx,r12
     cdb:	mov    rsi,QWORD PTR [rsp+0x28]
     ce0:	call   ce5 <botlish_fn_9+0xb7>
			ce1: R_X86_64_PLT32	rt_str_region_eq-0x4
     ce5:	cmp    rax,0x6
     ce9:	je     d28 <botlish_fn_9+0xfa>
     cef:	mov    rdi,r15
     cf2:	mov    rax,QWORD PTR [rdi+0x10]
     cf6:	mov    r8,QWORD PTR [rax+0x10]
     cfa:	mov    rcx,r13
     cfd:	mov    rdx,r12
     d00:	mov    rsi,QWORD PTR [rsp+0x28]
     d05:	call   d0a <botlish_fn_9+0xdc>
			d06: R_X86_64_PLT32	rt_str_region_eq-0x4
     d0a:	cmp    rax,0x6
     d0e:	je     d1e <botlish_fn_9+0xf0>
     d14:	mov    eax,0x2
     d19:	jmp    d2d <botlish_fn_9+0xff>
     d1e:	mov    eax,0x6
     d23:	jmp    d2d <botlish_fn_9+0xff>
     d28:	mov    eax,0x6
     d2d:	cmp    rax,0x6
     d31:	je     d70 <botlish_fn_9+0x142>
     d37:	mov    rdi,r15
     d3a:	mov    rcx,QWORD PTR [rdi+0x10]
     d3e:	mov    r8,QWORD PTR [rcx+0x18]
     d42:	mov    rcx,r13
     d45:	mov    rdx,r12
     d48:	mov    rsi,QWORD PTR [rsp+0x28]
     d4d:	call   d52 <botlish_fn_9+0x124>
			d4e: R_X86_64_PLT32	rt_str_region_eq-0x4
     d52:	cmp    rax,0x6
     d56:	je     d66 <botlish_fn_9+0x138>
     d5c:	mov    eax,0x2
     d61:	jmp    d75 <botlish_fn_9+0x147>
     d66:	mov    eax,0x6
     d6b:	jmp    d75 <botlish_fn_9+0x147>
     d70:	mov    eax,0x6
     d75:	cmp    rax,0x6
     d79:	je     df0 <botlish_fn_9+0x1c2>
     d7f:	mov    QWORD PTR [r14+0x18],0x3
     d87:	mov    rsi,QWORD PTR [rsp+0x20]
     d8c:	test   rsi,0x1
     d93:	je     dba <botlish_fn_9+0x18c>
     d99:	mov    rsi,QWORD PTR [rsp+0x20]
     d9e:	mov    rax,rsi
     da1:	add    rax,0x2
     da5:	seto   cl
     da8:	test   cl,cl
     daa:	jne    dba <botlish_fn_9+0x18c>
     db0:	mov    rsi,QWORD PTR [rsp+0x10]
     db5:	jmp    dd1 <botlish_fn_9+0x1a3>
     dba:	mov    edx,0x3
     dbf:	mov    rsi,QWORD PTR [rsp+0x20]
     dc4:	mov    rdi,r15
     dc7:	call   dcc <botlish_fn_9+0x19e>
			dc8: R_X86_64_PLT32	rt_int_add-0x4
     dcc:	mov    rsi,QWORD PTR [rsp+0x10]
     dd1:	mov    QWORD PTR [r14],rsi
     dd4:	mov    rdx,QWORD PTR [rsp+0x18]
     dd9:	mov    QWORD PTR [r14+0x8],rdx
     ddd:	mov    QWORD PTR [r14+0x10],rax
     de1:	mov    QWORD PTR [rsp+0x10],rsi
     de6:	mov    QWORD PTR [rsp+0x20],rax
     deb:	jmp    c93 <botlish_fn_9+0x65>
     df0:	mov    rdx,QWORD PTR [rsp+0x18]
     df5:	mov    rsi,QWORD PTR [rsp+0x10]
     dfa:	mov    rcx,QWORD PTR [rsp+0x20]
     dff:	mov    rdi,r15
     e02:	call   e07 <botlish_fn_9+0x1d9>
			e03: R_X86_64_PLT32	rt_substr-0x4
     e07:	test   rax,rax
     e0a:	jne    e41 <botlish_fn_9+0x213>
     e10:	mov    rdi,r15
     e13:	mov    rdi,r15
     e16:	mov    QWORD PTR [rdi],r14
     e19:	xor    rdx,rdx
     e1c:	mov    rax,rdx
     e1f:	mov    rbx,QWORD PTR [rsp+0x30]
     e24:	mov    r12,QWORD PTR [rsp+0x38]
     e29:	mov    r13,QWORD PTR [rsp+0x40]
     e2e:	mov    r14,QWORD PTR [rsp+0x48]
     e33:	mov    r15,QWORD PTR [rsp+0x50]
     e38:	add    rsp,0x60
     e3c:	mov    rsp,rbp
     e3f:	pop    rbp
     e40:	ret
     e41:	mov    rdi,r15
     e44:	mov    QWORD PTR [rdi],r14
     e47:	mov    rdx,QWORD PTR [rsp+0x20]
     e4c:	mov    rbx,QWORD PTR [rsp+0x30]
     e51:	mov    r12,QWORD PTR [rsp+0x38]
     e56:	mov    r13,QWORD PTR [rsp+0x40]
     e5b:	mov    r14,QWORD PTR [rsp+0x48]
     e60:	mov    r15,QWORD PTR [rsp+0x50]
     e65:	add    rsp,0x60
     e69:	mov    rsp,rbp
     e6c:	pop    rbp
     e6d:	ret
     e6e:	mov    r15,rdi
     e71:	call   e76 <botlish_fn_9+0x248>
			e72: R_X86_64_PLT32	rt_stack_overflow-0x4
     e76:	xor    rdx,rdx
     e79:	mov    rax,rdx
     e7c:	mov    rbx,QWORD PTR [rsp+0x30]
     e81:	mov    r12,QWORD PTR [rsp+0x38]
     e86:	mov    r13,QWORD PTR [rsp+0x40]
     e8b:	mov    r14,QWORD PTR [rsp+0x48]
     e90:	mov    r15,QWORD PTR [rsp+0x50]
     e95:	add    rsp,0x60
     e99:	mov    rsp,rbp
     e9c:	pop    rbp
     e9d:	ret

0000000000000e9e <botlish_entry_9: scan_unquoted<str, int, int>>:
     e9e:	push   rbp
     e9f:	mov    rbp,rsp
     ea2:	ud2

0000000000000ea4 <botlish_fn_10: scan_quoted<str, int, str>>:
     ea4:	push   rbp
     ea5:	mov    rbp,rsp
     ea8:	sub    rsp,0x50
     eac:	mov    QWORD PTR [rsp+0x20],rbx
     eb1:	mov    QWORD PTR [rsp+0x28],r12
     eb6:	mov    QWORD PTR [rsp+0x30],r13
     ebb:	mov    QWORD PTR [rsp+0x38],r14
     ec0:	mov    QWORD PTR [rsp+0x40],r15
     ec5:	mov    r13,QWORD PTR [rdi]
     ec8:	mov    rax,QWORD PTR [rdi+0x8]
     ecc:	lea    r8,[r13+0x28]
     ed0:	cmp    r8,rax
     ed3:	ja     11a5 <botlish_fn_10+0x301>
     ed9:	lea    rax,[r13+0x28]
     edd:	mov    QWORD PTR [rdi],rax
     ee0:	mov    r14,rdi
     ee3:	mov    QWORD PTR [r13+0x18],0x0
     eeb:	mov    QWORD PTR [r13+0x20],0x0
     ef3:	mov    QWORD PTR [r13+0x0],rsi
     ef7:	mov    QWORD PTR [r13+0x8],rdx
     efb:	mov    QWORD PTR [r13+0x10],rcx
     eff:	lea    rbx,[rsp]
     f03:	mov    r12,rsi
     f06:	mov    r15,rdx
     f09:	mov    QWORD PTR [rsp+0x10],rcx
     f0e:	mov    rdx,r15
     f11:	mov    rsi,r12
     f14:	mov    rdi,r14
     f17:	call   f1c <botlish_fn_10+0x78>
			f18: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     f1c:	test   rax,rax
     f1f:	jne    f2d <botlish_fn_10+0x89>
     f25:	mov    rdi,r14
     f28:	jmp    115e <botlish_fn_10+0x2ba>
     f2d:	mov    QWORD PTR [r13+0x18],rax
     f31:	mov    rdi,r14
     f34:	mov    QWORD PTR [rsp+0x18],rax
     f39:	mov    rdx,QWORD PTR [rdi+0x10]
     f3d:	mov    rsi,QWORD PTR [rdx+0x20]
     f41:	mov    edx,0x1
     f46:	mov    ecx,0x3
     f4b:	mov    r8,QWORD PTR [rsp+0x18]
     f50:	call   f55 <botlish_fn_10+0xb1>
			f51: R_X86_64_PLT32	rt_str_region_eq-0x4
     f55:	cmp    rax,0x6
     f59:	je     fe6 <botlish_fn_10+0x142>
     f5f:	mov    QWORD PTR [r13+0x20],0x3
     f67:	mov    rsi,r15
     f6a:	test   rsi,0x1
     f71:	je     f93 <botlish_fn_10+0xef>
     f77:	mov    r8,rsi
     f7a:	add    r8,0x2
     f7e:	seto   r10b
     f82:	test   r10b,r10b
     f85:	jne    f93 <botlish_fn_10+0xef>
     f8b:	mov    rsi,r8
     f8e:	jmp    fa3 <botlish_fn_10+0xff>
     f93:	mov    edx,0x3
     f98:	mov    rdi,r14
     f9b:	call   fa0 <botlish_fn_10+0xfc>
			f9c: R_X86_64_PLT32	rt_int_add-0x4
     fa0:	mov    rsi,rax
     fa3:	mov    QWORD PTR [r13+0x8],rsi
     fa7:	mov    r15,rsi
     faa:	mov    rsi,QWORD PTR [rsp+0x10]
     faf:	mov    rdx,QWORD PTR [rsp+0x18]
     fb4:	mov    rdi,r14
     fb7:	call   fbc <botlish_fn_10+0x118>
			fb8: R_X86_64_PLT32	rt_str_cat-0x4
     fbc:	test   rax,rax
     fbf:	jne    fcd <botlish_fn_10+0x129>
     fc5:	mov    rdi,r14
     fc8:	jmp    115e <botlish_fn_10+0x2ba>
     fcd:	mov    QWORD PTR [r13+0x0],r12
     fd1:	mov    rsi,r15
     fd4:	mov    QWORD PTR [r13+0x8],rsi
     fd8:	mov    QWORD PTR [r13+0x10],rax
     fdc:	mov    QWORD PTR [rsp+0x10],rax
     fe1:	jmp    f0e <botlish_fn_10+0x6a>
     fe6:	mov    QWORD PTR [r13+0x18],0x3
     fee:	mov    rsi,r15
     ff1:	test   rsi,0x1
     ff8:	je     1013 <botlish_fn_10+0x16f>
     ffe:	mov    rsi,r15
    1001:	mov    rdx,rsi
    1004:	add    rdx,0x2
    1008:	seto   al
    100b:	test   al,al
    100d:	je     1026 <botlish_fn_10+0x182>
    1013:	mov    edx,0x3
    1018:	mov    rsi,r15
    101b:	mov    rdi,r14
    101e:	call   1023 <botlish_fn_10+0x17f>
			101f: R_X86_64_PLT32	rt_int_add-0x4
    1023:	mov    rdx,rax
    1026:	mov    QWORD PTR [r13+0x18],rdx
    102a:	mov    rcx,rbx
    102d:	mov    rsi,r12
    1030:	mov    rdi,r14
    1033:	call   1038 <botlish_fn_10+0x194>
			1034: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1038:	test   rax,rax
    103b:	mov    rsi,rax
    103e:	jne    104c <botlish_fn_10+0x1a8>
    1044:	mov    rdi,r14
    1047:	jmp    115e <botlish_fn_10+0x2ba>
    104c:	mov    rdx,QWORD PTR [rsp]
    1050:	mov    rcx,QWORD PTR [rsp+0x8]
    1055:	mov    rdi,r14
    1058:	mov    rax,QWORD PTR [rdi+0x10]
    105c:	mov    r8,QWORD PTR [rax+0x20]
    1060:	call   1065 <botlish_fn_10+0x1c1>
			1061: R_X86_64_PLT32	rt_str_region_eq-0x4
    1065:	cmp    rax,0x6
    1069:	je     10e7 <botlish_fn_10+0x243>
    106f:	mov    QWORD PTR [r13+0x0],0x3
    1077:	mov    rsi,r15
    107a:	test   rsi,0x1
    1081:	je     10a4 <botlish_fn_10+0x200>
    1087:	mov    rsi,r15
    108a:	mov    rdx,rsi
    108d:	add    rdx,0x2
    1091:	seto   al
    1094:	test   al,al
    1096:	jne    10a4 <botlish_fn_10+0x200>
    109c:	mov    rdi,r14
    109f:	jmp    10ba <botlish_fn_10+0x216>
    10a4:	mov    edx,0x3
    10a9:	mov    rsi,r15
    10ac:	mov    rdi,r14
    10af:	call   10b4 <botlish_fn_10+0x210>
			10b0: R_X86_64_PLT32	rt_int_add-0x4
    10b4:	mov    rdx,rax
    10b7:	mov    rdi,r14
    10ba:	mov    rdi,r14
    10bd:	mov    QWORD PTR [rdi],r13
    10c0:	mov    rax,QWORD PTR [rsp+0x10]
    10c5:	mov    rbx,QWORD PTR [rsp+0x20]
    10ca:	mov    r12,QWORD PTR [rsp+0x28]
    10cf:	mov    r13,QWORD PTR [rsp+0x30]
    10d4:	mov    r14,QWORD PTR [rsp+0x38]
    10d9:	mov    r15,QWORD PTR [rsp+0x40]
    10de:	add    rsp,0x50
    10e2:	mov    rsp,rbp
    10e5:	pop    rbp
    10e6:	ret
    10e7:	mov    QWORD PTR [r13+0x18],0x5
    10ef:	mov    rsi,r15
    10f2:	test   rsi,0x1
    10f9:	je     111f <botlish_fn_10+0x27b>
    10ff:	mov    rsi,r15
    1102:	mov    rax,rsi
    1105:	add    rax,0x4
    1109:	seto   cl
    110c:	test   cl,cl
    110e:	jne    111f <botlish_fn_10+0x27b>
    1114:	mov    rsi,rax
    1117:	mov    r15,rax
    111a:	jmp    1135 <botlish_fn_10+0x291>
    111f:	mov    edx,0x5
    1124:	mov    rsi,r15
    1127:	mov    rdi,r14
    112a:	call   112f <botlish_fn_10+0x28b>
			112b: R_X86_64_PLT32	rt_int_add-0x4
    112f:	mov    rsi,rax
    1132:	mov    r15,rax
    1135:	mov    QWORD PTR [r13+0x8],rsi
    1139:	mov    rdi,r14
    113c:	mov    rax,QWORD PTR [rdi+0x10]
    1140:	mov    rdx,QWORD PTR [rax+0x20]
    1144:	mov    QWORD PTR [r13+0x18],rdx
    1148:	mov    rsi,QWORD PTR [rsp+0x10]
    114d:	call   1152 <botlish_fn_10+0x2ae>
			114e: R_X86_64_PLT32	rt_str_cat-0x4
    1152:	test   rax,rax
    1155:	jne    118c <botlish_fn_10+0x2e8>
    115b:	mov    rdi,r14
    115e:	mov    rdi,r14
    1161:	mov    QWORD PTR [rdi],r13
    1164:	xor    rdx,rdx
    1167:	mov    rax,rdx
    116a:	mov    rbx,QWORD PTR [rsp+0x20]
    116f:	mov    r12,QWORD PTR [rsp+0x28]
    1174:	mov    r13,QWORD PTR [rsp+0x30]
    1179:	mov    r14,QWORD PTR [rsp+0x38]
    117e:	mov    r15,QWORD PTR [rsp+0x40]
    1183:	add    rsp,0x50
    1187:	mov    rsp,rbp
    118a:	pop    rbp
    118b:	ret
    118c:	mov    QWORD PTR [r13+0x0],r12
    1190:	mov    rsi,r15
    1193:	mov    QWORD PTR [r13+0x8],rsi
    1197:	mov    QWORD PTR [r13+0x10],rax
    119b:	mov    QWORD PTR [rsp+0x10],rax
    11a0:	jmp    f0e <botlish_fn_10+0x6a>
    11a5:	mov    r14,rdi
    11a8:	call   11ad <botlish_fn_10+0x309>
			11a9: R_X86_64_PLT32	rt_stack_overflow-0x4
    11ad:	xor    rdx,rdx
    11b0:	mov    rax,rdx
    11b3:	mov    rbx,QWORD PTR [rsp+0x20]
    11b8:	mov    r12,QWORD PTR [rsp+0x28]
    11bd:	mov    r13,QWORD PTR [rsp+0x30]
    11c2:	mov    r14,QWORD PTR [rsp+0x38]
    11c7:	mov    r15,QWORD PTR [rsp+0x40]
    11cc:	add    rsp,0x50
    11d0:	mov    rsp,rbp
    11d3:	pop    rbp
    11d4:	ret

00000000000011d5 <botlish_entry_10: scan_quoted<str, int, str>>:
    11d5:	push   rbp
    11d6:	mov    rbp,rsp
    11d9:	ud2

00000000000011db <botlish_fn_11: scan_field<str, int>>:
    11db:	push   rbp
    11dc:	mov    rbp,rsp
    11df:	sub    rsp,0x30
    11e3:	mov    QWORD PTR [rsp+0x10],rbx
    11e8:	mov    QWORD PTR [rsp+0x18],r12
    11ed:	mov    QWORD PTR [rsp+0x20],r13
    11f2:	mov    QWORD PTR [rsp+0x28],r14
    11f7:	mov    rbx,QWORD PTR [rdi]
    11fa:	mov    rax,QWORD PTR [rdi+0x8]
    11fe:	lea    rcx,[rbx+0x18]
    1202:	cmp    rcx,rax
    1205:	ja     1368 <botlish_fn_11+0x18d>
    120b:	lea    rax,[rbx+0x18]
    120f:	mov    QWORD PTR [rdi],rax
    1212:	mov    r12,rdi
    1215:	mov    QWORD PTR [rbx+0x10],0x0
    121d:	mov    QWORD PTR [rbx],rsi
    1220:	mov    r13,rsi
    1223:	mov    QWORD PTR [rbx+0x8],rdx
    1227:	mov    r14,rdx
    122a:	lea    rcx,[rsp]
    122e:	mov    rdx,r14
    1231:	mov    rsi,r13
    1234:	mov    rdi,r12
    1237:	call   123c <botlish_fn_11+0x61>
			1238: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    123c:	test   rax,rax
    123f:	mov    rsi,rax
    1242:	jne    1250 <botlish_fn_11+0x75>
    1248:	mov    rdi,r12
    124b:	jmp    131c <botlish_fn_11+0x141>
    1250:	mov    rdx,QWORD PTR [rsp]
    1254:	mov    rcx,QWORD PTR [rsp+0x8]
    1259:	mov    rdi,r12
    125c:	mov    rax,QWORD PTR [rdi+0x10]
    1260:	mov    r8,QWORD PTR [rax+0x20]
    1264:	call   1269 <botlish_fn_11+0x8e>
			1265: R_X86_64_PLT32	rt_str_region_eq-0x4
    1269:	cmp    rax,0x6
    126d:	je     12b8 <botlish_fn_11+0xdd>
    1273:	mov    rcx,r14
    1276:	mov    rsi,r13
    1279:	mov    rdi,r12
    127c:	mov    rdx,rcx
    127f:	call   1284 <botlish_fn_11+0xa9>
			1280: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
    1284:	test   rax,rax
    1287:	jne    1295 <botlish_fn_11+0xba>
    128d:	mov    rdi,r12
    1290:	jmp    131c <botlish_fn_11+0x141>
    1295:	mov    rdi,r12
    1298:	mov    QWORD PTR [rdi],rbx
    129b:	mov    rbx,QWORD PTR [rsp+0x10]
    12a0:	mov    r12,QWORD PTR [rsp+0x18]
    12a5:	mov    r13,QWORD PTR [rsp+0x20]
    12aa:	mov    r14,QWORD PTR [rsp+0x28]
    12af:	add    rsp,0x30
    12b3:	mov    rsp,rbp
    12b6:	pop    rbp
    12b7:	ret
    12b8:	mov    QWORD PTR [rbx+0x10],0x3
    12c0:	mov    rdx,r14
    12c3:	test   rdx,0x1
    12ca:	je     12e2 <botlish_fn_11+0x107>
    12d0:	mov    rdx,r14
    12d3:	add    rdx,0x2
    12d7:	seto   al
    12da:	test   al,al
    12dc:	je     12f5 <botlish_fn_11+0x11a>
    12e2:	mov    edx,0x3
    12e7:	mov    rsi,r14
    12ea:	mov    rdi,r12
    12ed:	call   12f2 <botlish_fn_11+0x117>
			12ee: R_X86_64_PLT32	rt_int_add-0x4
    12f2:	mov    rdx,rax
    12f5:	mov    QWORD PTR [rbx+0x8],rdx
    12f9:	mov    rdi,r12
    12fc:	mov    rax,QWORD PTR [rdi+0x10]
    1300:	mov    rcx,QWORD PTR [rax+0x8]
    1304:	mov    QWORD PTR [rbx+0x10],rcx
    1308:	mov    rsi,r13
    130b:	call   1310 <botlish_fn_11+0x135>
			130c: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
    1310:	test   rax,rax
    1313:	jne    1345 <botlish_fn_11+0x16a>
    1319:	mov    rdi,r12
    131c:	mov    rdi,r12
    131f:	mov    QWORD PTR [rdi],rbx
    1322:	xor    rdx,rdx
    1325:	mov    rax,rdx
    1328:	mov    rbx,QWORD PTR [rsp+0x10]
    132d:	mov    r12,QWORD PTR [rsp+0x18]
    1332:	mov    r13,QWORD PTR [rsp+0x20]
    1337:	mov    r14,QWORD PTR [rsp+0x28]
    133c:	add    rsp,0x30
    1340:	mov    rsp,rbp
    1343:	pop    rbp
    1344:	ret
    1345:	mov    rdi,r12
    1348:	mov    QWORD PTR [rdi],rbx
    134b:	mov    rbx,QWORD PTR [rsp+0x10]
    1350:	mov    r12,QWORD PTR [rsp+0x18]
    1355:	mov    r13,QWORD PTR [rsp+0x20]
    135a:	mov    r14,QWORD PTR [rsp+0x28]
    135f:	add    rsp,0x30
    1363:	mov    rsp,rbp
    1366:	pop    rbp
    1367:	ret
    1368:	mov    r12,rdi
    136b:	call   1370 <botlish_fn_11+0x195>
			136c: R_X86_64_PLT32	rt_stack_overflow-0x4
    1370:	xor    rdx,rdx
    1373:	mov    rax,rdx
    1376:	mov    rbx,QWORD PTR [rsp+0x10]
    137b:	mov    r12,QWORD PTR [rsp+0x18]
    1380:	mov    r13,QWORD PTR [rsp+0x20]
    1385:	mov    r14,QWORD PTR [rsp+0x28]
    138a:	add    rsp,0x30
    138e:	mov    rsp,rbp
    1391:	pop    rbp
    1392:	ret

0000000000001393 <botlish_entry_11: scan_field<str, int>>:
    1393:	push   rbp
    1394:	mov    rbp,rsp
    1397:	ud2

0000000000001399 <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
    1399:	push   rbp
    139a:	mov    rbp,rsp
    139d:	sub    rsp,0x70
    13a1:	mov    QWORD PTR [rsp+0x40],rbx
    13a6:	mov    QWORD PTR [rsp+0x48],r12
    13ab:	mov    QWORD PTR [rsp+0x50],r13
    13b0:	mov    QWORD PTR [rsp+0x58],r14
    13b5:	mov    QWORD PTR [rsp+0x60],r15
    13ba:	mov    r13,QWORD PTR [rdi]
    13bd:	mov    rax,QWORD PTR [rdi+0x8]
    13c1:	lea    r9,[r13+0x28]
    13c5:	cmp    r9,rax
    13c8:	ja     1689 <botlish_fn_12+0x2f0>
    13ce:	lea    rax,[r13+0x28]
    13d2:	mov    QWORD PTR [rdi],rax
    13d5:	mov    QWORD PTR [rsp+0x10],rdi
    13da:	mov    QWORD PTR [r13+0x20],0x0
    13e2:	mov    QWORD PTR [r13+0x0],rsi
    13e6:	mov    QWORD PTR [r13+0x8],rdx
    13ea:	mov    QWORD PTR [r13+0x10],rcx
    13ee:	mov    QWORD PTR [r13+0x18],r8
    13f2:	lea    rbx,[rsp]
    13f6:	mov    r12,rsi
    13f9:	mov    r14,r8
    13fc:	mov    r15,rcx
    13ff:	mov    rsi,r12
    1402:	mov    rdi,QWORD PTR [rsp+0x10]
    1407:	call   140c <botlish_fn_12+0x73>
			1408: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
    140c:	test   rax,rax
    140f:	jne    141f <botlish_fn_12+0x86>
    1415:	mov    rdi,QWORD PTR [rsp+0x10]
    141a:	jmp    1560 <botlish_fn_12+0x1c7>
    141f:	mov    QWORD PTR [r13+0x8],rax
    1423:	mov    rcx,rax
    1426:	mov    QWORD PTR [r13+0x20],rdx
    142a:	mov    QWORD PTR [rsp+0x30],rdx
    142f:	mov    rsi,r15
    1432:	mov    rdx,r14
    1435:	mov    rdi,QWORD PTR [rsp+0x10]
    143a:	call   143f <botlish_fn_12+0xa6>
			143b: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    143f:	test   rax,rax
    1442:	jne    1452 <botlish_fn_12+0xb9>
    1448:	mov    rdi,QWORD PTR [rsp+0x10]
    144d:	jmp    1560 <botlish_fn_12+0x1c7>
    1452:	mov    QWORD PTR [r13+0x8],rax
    1456:	mov    QWORD PTR [rsp+0x20],rax
    145b:	mov    QWORD PTR [r13+0x10],rdx
    145f:	mov    QWORD PTR [rsp+0x28],rdx
    1464:	mov    rcx,rbx
    1467:	mov    rdx,QWORD PTR [rsp+0x30]
    146c:	mov    rsi,r12
    146f:	mov    rdi,QWORD PTR [rsp+0x10]
    1474:	call   1479 <botlish_fn_12+0xe0>
			1475: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1479:	test   rax,rax
    147c:	mov    QWORD PTR [rsp+0x18],rax
    1481:	jne    1491 <botlish_fn_12+0xf8>
    1487:	mov    rdi,QWORD PTR [rsp+0x10]
    148c:	jmp    1560 <botlish_fn_12+0x1c7>
    1491:	mov    r15,QWORD PTR [rsp]
    1495:	mov    r14,QWORD PTR [rsp+0x8]
    149a:	mov    rdi,QWORD PTR [rsp+0x10]
    149f:	mov    rcx,QWORD PTR [rdi+0x10]
    14a3:	mov    r8,QWORD PTR [rcx+0x10]
    14a7:	mov    rcx,r14
    14aa:	mov    rdx,r15
    14ad:	mov    rsi,QWORD PTR [rsp+0x18]
    14b2:	call   14b7 <botlish_fn_12+0x11e>
			14b3: R_X86_64_PLT32	rt_str_region_eq-0x4
    14b7:	cmp    rax,0x6
    14bb:	je     1618 <botlish_fn_12+0x27f>
    14c1:	mov    rdi,QWORD PTR [rsp+0x10]
    14c6:	mov    rsi,QWORD PTR [rdi+0x10]
    14ca:	mov    r8,QWORD PTR [rsi+0x18]
    14ce:	mov    rcx,r14
    14d1:	mov    rdx,r15
    14d4:	mov    rsi,QWORD PTR [rsp+0x18]
    14d9:	call   14de <botlish_fn_12+0x145>
			14da: R_X86_64_PLT32	rt_str_region_eq-0x4
    14de:	cmp    rax,0x6
    14e2:	je     153e <botlish_fn_12+0x1a5>
    14e8:	mov    rdx,QWORD PTR [rsp+0x28]
    14ed:	mov    rsi,QWORD PTR [rsp+0x20]
    14f2:	mov    rdi,QWORD PTR [rsp+0x10]
    14f7:	call   14fc <botlish_fn_12+0x163>
			14f8: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    14fc:	test   rax,rax
    14ff:	jne    150f <botlish_fn_12+0x176>
    1505:	mov    rdi,QWORD PTR [rsp+0x10]
    150a:	jmp    1560 <botlish_fn_12+0x1c7>
    150f:	mov    rdi,QWORD PTR [rsp+0x10]
    1514:	mov    QWORD PTR [rdi],r13
    1517:	mov    rdx,QWORD PTR [rsp+0x30]
    151c:	mov    rbx,QWORD PTR [rsp+0x40]
    1521:	mov    r12,QWORD PTR [rsp+0x48]
    1526:	mov    r13,QWORD PTR [rsp+0x50]
    152b:	mov    r14,QWORD PTR [rsp+0x58]
    1530:	mov    r15,QWORD PTR [rsp+0x60]
    1535:	add    rsp,0x70
    1539:	mov    rsp,rbp
    153c:	pop    rbp
    153d:	ret
    153e:	mov    rdx,QWORD PTR [rsp+0x28]
    1543:	mov    rsi,QWORD PTR [rsp+0x20]
    1548:	mov    rdi,QWORD PTR [rsp+0x10]
    154d:	call   1552 <botlish_fn_12+0x1b9>
			154e: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1552:	test   rax,rax
    1555:	jne    1590 <botlish_fn_12+0x1f7>
    155b:	mov    rdi,QWORD PTR [rsp+0x10]
    1560:	mov    rdi,QWORD PTR [rsp+0x10]
    1565:	mov    QWORD PTR [rdi],r13
    1568:	xor    rdx,rdx
    156b:	mov    rax,rdx
    156e:	mov    rbx,QWORD PTR [rsp+0x40]
    1573:	mov    r12,QWORD PTR [rsp+0x48]
    1578:	mov    r13,QWORD PTR [rsp+0x50]
    157d:	mov    r14,QWORD PTR [rsp+0x58]
    1582:	mov    r15,QWORD PTR [rsp+0x60]
    1587:	add    rsp,0x70
    158b:	mov    rsp,rbp
    158e:	pop    rbp
    158f:	ret
    1590:	mov    QWORD PTR [r13+0x0],rax
    1594:	mov    rbx,rax
    1597:	mov    QWORD PTR [r13+0x8],0x3
    159f:	mov    rdx,QWORD PTR [rsp+0x30]
    15a4:	test   rdx,0x1
    15ab:	je     15cf <botlish_fn_12+0x236>
    15b1:	mov    rdx,QWORD PTR [rsp+0x30]
    15b6:	add    rdx,0x2
    15ba:	seto   al
    15bd:	test   al,al
    15bf:	jne    15cf <botlish_fn_12+0x236>
    15c5:	mov    rdi,QWORD PTR [rsp+0x10]
    15ca:	jmp    15eb <botlish_fn_12+0x252>
    15cf:	mov    edx,0x3
    15d4:	mov    rsi,QWORD PTR [rsp+0x30]
    15d9:	mov    rdi,QWORD PTR [rsp+0x10]
    15de:	call   15e3 <botlish_fn_12+0x24a>
			15df: R_X86_64_PLT32	rt_int_add-0x4
    15e3:	mov    rdx,rax
    15e6:	mov    rdi,QWORD PTR [rsp+0x10]
    15eb:	mov    rdi,QWORD PTR [rsp+0x10]
    15f0:	mov    QWORD PTR [rdi],r13
    15f3:	mov    rax,rbx
    15f6:	mov    rbx,QWORD PTR [rsp+0x40]
    15fb:	mov    r12,QWORD PTR [rsp+0x48]
    1600:	mov    r13,QWORD PTR [rsp+0x50]
    1605:	mov    r14,QWORD PTR [rsp+0x58]
    160a:	mov    r15,QWORD PTR [rsp+0x60]
    160f:	add    rsp,0x70
    1613:	mov    rsp,rbp
    1616:	pop    rbp
    1617:	ret
    1618:	mov    rsi,QWORD PTR [rsp+0x30]
    161d:	mov    edx,0x3
    1622:	mov    r9,rdx
    1625:	mov    QWORD PTR [r13+0x18],0x3
    162d:	test   rsi,0x1
    1634:	jne    1642 <botlish_fn_12+0x2a9>
    163a:	mov    rdx,r9
    163d:	jmp    1657 <botlish_fn_12+0x2be>
    1642:	mov    rdx,rsi
    1645:	add    rdx,0x2
    1649:	seto   al
    164c:	test   al,al
    164e:	je     1664 <botlish_fn_12+0x2cb>
    1654:	mov    rdx,r9
    1657:	mov    rdi,QWORD PTR [rsp+0x10]
    165c:	call   1661 <botlish_fn_12+0x2c8>
			165d: R_X86_64_PLT32	rt_int_add-0x4
    1661:	mov    rdx,rax
    1664:	mov    QWORD PTR [r13+0x0],r12
    1668:	mov    QWORD PTR [r13+0x8],rdx
    166c:	mov    rsi,QWORD PTR [rsp+0x20]
    1671:	mov    QWORD PTR [r13+0x10],rsi
    1675:	mov    rax,QWORD PTR [rsp+0x28]
    167a:	mov    QWORD PTR [r13+0x18],rax
    167e:	mov    r14,rax
    1681:	mov    r15,rsi
    1684:	jmp    13ff <botlish_fn_12+0x66>
    1689:	mov    QWORD PTR [rsp+0x10],rdi
    168e:	call   1693 <botlish_fn_12+0x2fa>
			168f: R_X86_64_PLT32	rt_stack_overflow-0x4
    1693:	xor    rdx,rdx
    1696:	mov    rax,rdx
    1699:	mov    rbx,QWORD PTR [rsp+0x40]
    169e:	mov    r12,QWORD PTR [rsp+0x48]
    16a3:	mov    r13,QWORD PTR [rsp+0x50]
    16a8:	mov    r14,QWORD PTR [rsp+0x58]
    16ad:	mov    r15,QWORD PTR [rsp+0x60]
    16b2:	add    rsp,0x70
    16b6:	mov    rsp,rbp
    16b9:	pop    rbp
    16ba:	ret

00000000000016bb <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    16bb:	push   rbp
    16bc:	mov    rbp,rsp
    16bf:	ud2
    16c1:	add    BYTE PTR [rax],al
    16c3:	add    BYTE PTR [rax],al
    16c5:	add    BYTE PTR [rax],al
	...

00000000000016c8 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    16c8:	push   rbp
    16c9:	mov    rbp,rsp
    16cc:	sub    rsp,0x40
    16d0:	mov    QWORD PTR [rsp+0x10],rbx
    16d5:	mov    QWORD PTR [rsp+0x18],r12
    16da:	mov    QWORD PTR [rsp+0x20],r13
    16df:	mov    QWORD PTR [rsp+0x28],r14
    16e4:	mov    QWORD PTR [rsp+0x30],r15
    16e9:	mov    r12,QWORD PTR [rdi]
    16ec:	mov    rax,QWORD PTR [rdi+0x8]
    16f0:	lea    r9,[r12+0x30]
    16f5:	cmp    r9,rax
    16f8:	ja     18a1 <botlish_fn_13+0x1d9>
    16fe:	lea    rax,[r12+0x30]
    1703:	mov    QWORD PTR [rdi],rax
    1706:	mov    r14,rdi
    1709:	mov    QWORD PTR [r12+0x20],0x0
    1712:	mov    QWORD PTR [r12+0x28],0x0
    171b:	mov    QWORD PTR [r12],rsi
    171f:	mov    QWORD PTR [r12+0x8],rdx
    1724:	mov    r13,rdx
    1727:	mov    QWORD PTR [r12+0x10],rcx
    172c:	mov    QWORD PTR [r12+0x18],r8
    1731:	mov    rbx,rsi
    1734:	mov    r15,r8
    1737:	mov    QWORD PTR [rsp],rcx
    173b:	mov    rsi,rbx
    173e:	mov    rdi,r14
    1741:	call   1746 <botlish_fn_13+0x7e>
			1742: R_X86_64_PLT32	rt_str_len-0x4
    1746:	mov    rcx,r13
    1749:	and    rcx,rax
    174c:	mov    rdx,rax
    174f:	test   rcx,0x1
    1756:	jne    177c <botlish_fn_13+0xb4>
    175c:	mov    rsi,r13
    175f:	mov    rdi,r14
    1762:	call   1767 <botlish_fn_13+0x9f>
			1763: R_X86_64_PLT32	rt_int_cmp-0x4
    1767:	mov    ecx,0x2
    176c:	test   rax,rax
    176f:	cmovge rcx,QWORD PTR [rip+0x159]        # 18d0 <botlish_fn_13+0x208>
    1777:	jmp    178f <botlish_fn_13+0xc7>
    177c:	mov    ecx,0x2
    1781:	mov    rax,r13
    1784:	cmp    rax,rdx
    1787:	cmovge rcx,QWORD PTR [rip+0x141]        # 18d0 <botlish_fn_13+0x208>
    178f:	cmp    rcx,0x6
    1793:	je     1833 <botlish_fn_13+0x16b>
    1799:	mov    rdi,r14
    179c:	call   17a1 <botlish_fn_13+0xd9>
			179d: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    17a1:	test   rax,rax
    17a4:	jne    17b2 <botlish_fn_13+0xea>
    17aa:	mov    rdi,r14
    17ad:	jmp    184e <botlish_fn_13+0x186>
    17b2:	mov    QWORD PTR [r12+0x20],rax
    17b7:	mov    rcx,rax
    17ba:	mov    QWORD PTR [r12+0x28],rdx
    17bf:	mov    r8,rdx
    17c2:	mov    rdx,r13
    17c5:	mov    rsi,rbx
    17c8:	mov    rdi,r14
    17cb:	call   17d0 <botlish_fn_13+0x108>
			17cc: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    17d0:	test   rax,rax
    17d3:	jne    17e1 <botlish_fn_13+0x119>
    17d9:	mov    rdi,r14
    17dc:	jmp    184e <botlish_fn_13+0x186>
    17e1:	mov    QWORD PTR [r12+0x8],rax
    17e6:	mov    rcx,rax
    17e9:	mov    QWORD PTR [r12+0x20],rdx
    17ee:	mov    r13,rdx
    17f1:	mov    rsi,QWORD PTR [rsp]
    17f5:	mov    rdx,r15
    17f8:	mov    rdi,r14
    17fb:	call   1800 <botlish_fn_13+0x138>
			17fc: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1800:	test   rax,rax
    1803:	jne    1811 <botlish_fn_13+0x149>
    1809:	mov    rdi,r14
    180c:	jmp    184e <botlish_fn_13+0x186>
    1811:	mov    QWORD PTR [r12],rbx
    1815:	mov    rcx,r13
    1818:	mov    QWORD PTR [r12+0x8],rcx
    181d:	mov    QWORD PTR [r12+0x10],rax
    1822:	mov    QWORD PTR [r12+0x18],rdx
    1827:	mov    r15,rdx
    182a:	mov    QWORD PTR [rsp],rax
    182e:	jmp    173b <botlish_fn_13+0x73>
    1833:	mov    rdx,r15
    1836:	mov    rsi,QWORD PTR [rsp]
    183a:	mov    rdi,r14
    183d:	call   1842 <botlish_fn_13+0x17a>
			183e: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1842:	test   rax,rax
    1845:	jne    1879 <botlish_fn_13+0x1b1>
    184b:	mov    rdi,r14
    184e:	mov    rdi,r14
    1851:	mov    QWORD PTR [rdi],r12
    1854:	xor    rax,rax
    1857:	mov    rbx,QWORD PTR [rsp+0x10]
    185c:	mov    r12,QWORD PTR [rsp+0x18]
    1861:	mov    r13,QWORD PTR [rsp+0x20]
    1866:	mov    r14,QWORD PTR [rsp+0x28]
    186b:	mov    r15,QWORD PTR [rsp+0x30]
    1870:	add    rsp,0x40
    1874:	mov    rsp,rbp
    1877:	pop    rbp
    1878:	ret
    1879:	mov    rdi,r14
    187c:	mov    QWORD PTR [rdi],r12
    187f:	mov    rbx,QWORD PTR [rsp+0x10]
    1884:	mov    r12,QWORD PTR [rsp+0x18]
    1889:	mov    r13,QWORD PTR [rsp+0x20]
    188e:	mov    r14,QWORD PTR [rsp+0x28]
    1893:	mov    r15,QWORD PTR [rsp+0x30]
    1898:	add    rsp,0x40
    189c:	mov    rsp,rbp
    189f:	pop    rbp
    18a0:	ret
    18a1:	mov    r14,rdi
    18a4:	call   18a9 <botlish_fn_13+0x1e1>
			18a5: R_X86_64_PLT32	rt_stack_overflow-0x4
    18a9:	xor    rax,rax
    18ac:	mov    rbx,QWORD PTR [rsp+0x10]
    18b1:	mov    r12,QWORD PTR [rsp+0x18]
    18b6:	mov    r13,QWORD PTR [rsp+0x20]
    18bb:	mov    r14,QWORD PTR [rsp+0x28]
    18c0:	mov    r15,QWORD PTR [rsp+0x30]
    18c5:	add    rsp,0x40
    18c9:	mov    rsp,rbp
    18cc:	pop    rbp
    18cd:	ret
    18ce:	add    BYTE PTR [rax],al
    18d0:	(bad)
    18d1:	add    BYTE PTR [rax],al
    18d3:	add    BYTE PTR [rax],al
    18d5:	add    BYTE PTR [rax],al
	...

00000000000018d8 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    18d8:	push   rbp
    18d9:	mov    rbp,rsp
    18dc:	mov    rsi,QWORD PTR [rdx]
    18df:	mov    r9,QWORD PTR [rdx+0x8]
    18e3:	mov    rcx,QWORD PTR [rdx+0x10]
    18e7:	mov    r8,QWORD PTR [rdx+0x18]
    18eb:	mov    rdx,r9
    18ee:	call   18f3 <botlish_entry_13+0x1b>
			18ef: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    18f3:	mov    rsp,rbp
    18f6:	pop    rbp
    18f7:	ret

00000000000018f8 <botlish_fn_14: csv_parse<str>>:
    18f8:	push   rbp
    18f9:	mov    rbp,rsp
    18fc:	sub    rsp,0x20
    1900:	mov    QWORD PTR [rsp],rbx
    1904:	mov    QWORD PTR [rsp+0x8],r12
    1909:	mov    QWORD PTR [rsp+0x10],r15
    190e:	mov    r15,QWORD PTR [rdi]
    1911:	mov    rax,QWORD PTR [rdi+0x8]
    1915:	lea    rcx,[r15+0x20]
    1919:	cmp    rcx,rax
    191c:	ja     19ca <botlish_fn_14+0xd2>
    1922:	lea    rax,[r15+0x20]
    1926:	mov    QWORD PTR [rdi],rax
    1929:	mov    rbx,rdi
    192c:	mov    QWORD PTR [r15+0x10],0x0
    1934:	mov    QWORD PTR [r15+0x18],0x0
    193c:	mov    QWORD PTR [r15],rsi
    193f:	mov    r12,rsi
    1942:	mov    QWORD PTR [r15+0x8],0x1
    194a:	mov    rdi,rbx
    194d:	call   1952 <botlish_fn_14+0x5a>
			194e: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1952:	test   rax,rax
    1955:	jne    1963 <botlish_fn_14+0x6b>
    195b:	mov    rdi,rbx
    195e:	jmp    198d <botlish_fn_14+0x95>
    1963:	mov    QWORD PTR [r15+0x10],rax
    1967:	mov    rcx,rax
    196a:	mov    QWORD PTR [r15+0x18],rdx
    196e:	mov    r8,rdx
    1971:	mov    edx,0x1
    1976:	mov    rsi,r12
    1979:	mov    rdi,rbx
    197c:	call   1981 <botlish_fn_14+0x89>
			197d: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1981:	test   rax,rax
    1984:	jne    19ad <botlish_fn_14+0xb5>
    198a:	mov    rdi,rbx
    198d:	mov    rdi,rbx
    1990:	mov    QWORD PTR [rdi],r15
    1993:	xor    rax,rax
    1996:	mov    rbx,QWORD PTR [rsp]
    199a:	mov    r12,QWORD PTR [rsp+0x8]
    199f:	mov    r15,QWORD PTR [rsp+0x10]
    19a4:	add    rsp,0x20
    19a8:	mov    rsp,rbp
    19ab:	pop    rbp
    19ac:	ret
    19ad:	mov    rdi,rbx
    19b0:	mov    QWORD PTR [rdi],r15
    19b3:	mov    rbx,QWORD PTR [rsp]
    19b7:	mov    r12,QWORD PTR [rsp+0x8]
    19bc:	mov    r15,QWORD PTR [rsp+0x10]
    19c1:	add    rsp,0x20
    19c5:	mov    rsp,rbp
    19c8:	pop    rbp
    19c9:	ret
    19ca:	mov    rbx,rdi
    19cd:	call   19d2 <botlish_fn_14+0xda>
			19ce: R_X86_64_PLT32	rt_stack_overflow-0x4
    19d2:	xor    rax,rax
    19d5:	mov    rbx,QWORD PTR [rsp]
    19d9:	mov    r12,QWORD PTR [rsp+0x8]
    19de:	mov    r15,QWORD PTR [rsp+0x10]
    19e3:	add    rsp,0x20
    19e7:	mov    rsp,rbp
    19ea:	pop    rbp
    19eb:	ret

00000000000019ec <botlish_entry_14: csv_parse<str>>:
    19ec:	push   rbp
    19ed:	mov    rbp,rsp
    19f0:	mov    rsi,QWORD PTR [rdx]
    19f3:	call   19f8 <botlish_entry_14+0xc>
			19f4: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    19f8:	mov    rsp,rbp
    19fb:	pop    rbp
    19fc:	ret

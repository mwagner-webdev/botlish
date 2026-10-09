; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6386  (per function: 312 89 89 357 420 420 202 202 81 365 309 526 932 311 758 215 480 318)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<str>
;   botlish_fn_2 / botlish_entry_2 -> geo_new<List[str]>
;   botlish_fn_3 / botlish_entry_3 -> geo_new_capacity<int, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_grow<mutarray, int, str>
;   botlish_fn_5 / botlish_entry_5 -> geo_grow<mutarray, int, List[str]>
;   botlish_fn_6 / botlish_entry_6 -> geo_append<mutarray, int, str>
;   botlish_fn_7 / botlish_entry_7 -> geo_append<mutarray, int, List[str]>
;   botlish_fn_8 / botlish_entry_8 -> geo_finish<mutarray, int>
;   botlish_fn_9 / botlish_entry_9 -> peek<str, int>
;   botlish_fn_10 / botlish_entry_10 -> quote_at?<str, int>
;   botlish_fn_11 / botlish_entry_11 -> scan_unquoted<str, int, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_quoted<str, int, str>
;   botlish_fn_13 / botlish_entry_13 -> scan_field<str, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_record_rest<str, int, mutarray, int>
;   botlish_fn_15 / botlish_entry_15 -> scan_record<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_records<str, int, mutarray, int>
;   botlish_fn_17 / botlish_entry_17 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x20
       8:	mov    QWORD PTR [rsp+0x10],rbx
       d:	mov    rax,QWORD PTR [rdi+0x10]
      11:	mov    rbx,rdi
      14:	mov    rsi,QWORD PTR [rax]
      17:	mov    QWORD PTR [rsp],rsi
      1b:	call   20 <botlish_fn_0+0x20>
			1c: R_X86_64_PLT32	botlish_fn_17-0x4 ; csv_parse<str>
      20:	test   rax,rax
      23:	jne    dd <botlish_fn_0+0xdd>
      29:	mov    rdi,rbx
      2c:	call   31 <botlish_fn_0+0x31>
			2d: R_X86_64_PLT32	rt_declared_error-0x4
      31:	cmp    rax,0x40000001
      37:	je     ad <botlish_fn_0+0xad>
      3d:	mov    rdi,rbx
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	rt_declared_error-0x4
      45:	cmp    rax,0x40000002
      4b:	je     89 <botlish_fn_0+0x89>
      51:	mov    rdi,rbx
      54:	call   59 <botlish_fn_0+0x59>
			55: R_X86_64_PLT32	rt_declared_error-0x4
      59:	cmp    rax,0x40000003
      5f:	jne    cc <botlish_fn_0+0xcc>
      65:	mov    rdi,rbx
      68:	call   6d <botlish_fn_0+0x6d>
			69: R_X86_64_PLT32	rt_clear_declared_error-0x4
      6d:	xor    rdx,rdx
      70:	mov    rdi,rbx
      73:	mov    rsi,rdx
      76:	call   7b <botlish_fn_0+0x7b>
			77: R_X86_64_PLT32	rt_list_new-0x4
      7b:	test   rax,rax
      7e:	je     cc <botlish_fn_0+0xcc>
      84:	jmp    dd <botlish_fn_0+0xdd>
      89:	mov    rdi,rbx
      8c:	call   91 <botlish_fn_0+0x91>
			8d: R_X86_64_PLT32	rt_clear_declared_error-0x4
      91:	xor    rdx,rdx
      94:	mov    rdi,rbx
      97:	mov    rsi,rdx
      9a:	call   9f <botlish_fn_0+0x9f>
			9b: R_X86_64_PLT32	rt_list_new-0x4
      9f:	test   rax,rax
      a2:	je     cc <botlish_fn_0+0xcc>
      a8:	jmp    dd <botlish_fn_0+0xdd>
      ad:	mov    rdi,rbx
      b0:	call   b5 <botlish_fn_0+0xb5>
			b1: R_X86_64_PLT32	rt_clear_declared_error-0x4
      b5:	xor    rdx,rdx
      b8:	mov    rdi,rbx
      bb:	mov    rsi,rdx
      be:	call   c3 <botlish_fn_0+0xc3>
			bf: R_X86_64_PLT32	rt_list_new-0x4
      c3:	test   rax,rax
      c6:	jne    dd <botlish_fn_0+0xdd>
      cc:	xor    rax,rax
      cf:	mov    rbx,QWORD PTR [rsp+0x10]
      d4:	add    rsp,0x20
      d8:	mov    rsp,rbp
      db:	pop    rbp
      dc:	ret
      dd:	mov    rbx,QWORD PTR [rsp+0x10]
      e2:	add    rsp,0x20
      e6:	mov    rsp,rbp
      e9:	pop    rbp
      ea:	ret

00000000000000eb <botlish_entry_0: <program entry>>:
      eb:	push   rbp
      ec:	mov    rbp,rsp
      ef:	call   f4 <botlish_entry_0+0x9>
			f0: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      f4:	mov    rsp,rbp
      f7:	pop    rbp
      f8:	ret

00000000000000f9 <botlish_fn_1: geo_new<str>>:
      f9:	push   rbp
      fa:	mov    rbp,rsp
      fd:	sub    rsp,0x10
     101:	mov    QWORD PTR [rsp],rsi
     105:	mov    rdx,rsi
     108:	mov    esi,0x3
     10d:	mov    QWORD PTR [rsp+0x8],0x3
     116:	call   11b <botlish_fn_1+0x22>
			117: R_X86_64_PLT32	rt_mutarray_create-0x4
     11b:	test   rax,rax
     11e:	jne    130 <botlish_fn_1+0x37>
     124:	xor    rax,rax
     127:	add    rsp,0x10
     12b:	mov    rsp,rbp
     12e:	pop    rbp
     12f:	ret
     130:	add    rsp,0x10
     134:	mov    rsp,rbp
     137:	pop    rbp
     138:	ret

0000000000000139 <botlish_entry_1: geo_new<str>>:
     139:	push   rbp
     13a:	mov    rbp,rsp
     13d:	mov    rsi,QWORD PTR [rdx]
     140:	call   145 <botlish_entry_1+0xc>
			141: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
     145:	mov    rsp,rbp
     148:	pop    rbp
     149:	ret

000000000000014a <botlish_fn_2: geo_new<List[str]>>:
     14a:	push   rbp
     14b:	mov    rbp,rsp
     14e:	sub    rsp,0x10
     152:	mov    QWORD PTR [rsp],rsi
     156:	mov    rdx,rsi
     159:	mov    esi,0x3
     15e:	mov    QWORD PTR [rsp+0x8],0x3
     167:	call   16c <botlish_fn_2+0x22>
			168: R_X86_64_PLT32	rt_mutarray_create-0x4
     16c:	test   rax,rax
     16f:	jne    181 <botlish_fn_2+0x37>
     175:	xor    rax,rax
     178:	add    rsp,0x10
     17c:	mov    rsp,rbp
     17f:	pop    rbp
     180:	ret
     181:	add    rsp,0x10
     185:	mov    rsp,rbp
     188:	pop    rbp
     189:	ret

000000000000018a <botlish_entry_2: geo_new<List[str]>>:
     18a:	push   rbp
     18b:	mov    rbp,rsp
     18e:	mov    rsi,QWORD PTR [rdx]
     191:	call   196 <botlish_entry_2+0xc>
			192: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
     196:	mov    rsp,rbp
     199:	pop    rbp
     19a:	ret
     19b:	add    BYTE PTR [rax],al
     19d:	add    BYTE PTR [rax],al
	...

00000000000001a0 <botlish_fn_3: geo_new_capacity<int, int>>:
     1a0:	push   rbp
     1a1:	mov    rbp,rsp
     1a4:	sub    rsp,0x40
     1a8:	mov    QWORD PTR [rsp+0x20],rbx
     1ad:	mov    QWORD PTR [rsp+0x28],r12
     1b2:	mov    QWORD PTR [rsp+0x30],r13
     1b7:	mov    r12,rdi
     1ba:	mov    QWORD PTR [rsp],rsi
     1be:	mov    QWORD PTR [rsp+0x8],rdx
     1c3:	mov    rbx,rdx
     1c6:	mov    QWORD PTR [rsp+0x10],0x5
     1cf:	test   rsi,0x1
     1d6:	je     1f8 <botlish_fn_3+0x58>
     1dc:	mov    rax,rsi
     1df:	sar    rax,1
     1e2:	imul   QWORD PTR [rip+0xdf]        # 2c8 <botlish_fn_3+0x128>
     1e9:	seto   cl
     1ec:	or     rax,0x1
     1f0:	test   cl,cl
     1f2:	je     205 <botlish_fn_3+0x65>
     1f8:	mov    edx,0x5
     1fd:	mov    rdi,r12
     200:	call   205 <botlish_fn_3+0x65>
			201: R_X86_64_PLT32	rt_int_mul-0x4
     205:	mov    rcx,rax
     208:	and    rcx,rbx
     20b:	mov    r13,rax
     20e:	test   rcx,0x1
     215:	jne    241 <botlish_fn_3+0xa1>
     21b:	mov    rdx,rbx
     21e:	mov    rsi,r13
     221:	mov    rdi,r12
     224:	call   229 <botlish_fn_3+0x89>
			225: R_X86_64_PLT32	rt_int_cmp-0x4
     229:	mov    ecx,0x2
     22e:	test   rax,rax
     231:	cmovle rcx,QWORD PTR [rip+0x97]        # 2d0 <botlish_fn_3+0x130>
     239:	mov    rax,r13
     23c:	jmp    254 <botlish_fn_3+0xb4>
     241:	mov    ecx,0x2
     246:	mov    rax,r13
     249:	cmp    rax,rbx
     24c:	cmovle rcx,QWORD PTR [rip+0x7c]        # 2d0 <botlish_fn_3+0x130>
     254:	cmp    rcx,0x6
     258:	je     276 <botlish_fn_3+0xd6>
     25e:	mov    rbx,QWORD PTR [rsp+0x20]
     263:	mov    r12,QWORD PTR [rsp+0x28]
     268:	mov    r13,QWORD PTR [rsp+0x30]
     26d:	add    rsp,0x40
     271:	mov    rsp,rbp
     274:	pop    rbp
     275:	ret
     276:	mov    QWORD PTR [rsp],0x3
     27e:	test   rbx,0x1
     285:	je     29d <botlish_fn_3+0xfd>
     28b:	mov    rax,rbx
     28e:	add    rax,0x2
     292:	seto   cl
     295:	test   cl,cl
     297:	je     2ad <botlish_fn_3+0x10d>
     29d:	mov    edx,0x3
     2a2:	mov    rsi,rbx
     2a5:	mov    rdi,r12
     2a8:	call   2ad <botlish_fn_3+0x10d>
			2a9: R_X86_64_PLT32	rt_int_add-0x4
     2ad:	mov    rbx,QWORD PTR [rsp+0x20]
     2b2:	mov    r12,QWORD PTR [rsp+0x28]
     2b7:	mov    r13,QWORD PTR [rsp+0x30]
     2bc:	add    rsp,0x40
     2c0:	mov    rsp,rbp
     2c3:	pop    rbp
     2c4:	ret
     2c5:	add    BYTE PTR [rax],al
     2c7:	add    BYTE PTR [rax+rax*1],al
     2ca:	add    BYTE PTR [rax],al
     2cc:	add    BYTE PTR [rax],al
     2ce:	add    BYTE PTR [rax],al
     2d0:	(bad)
     2d1:	add    BYTE PTR [rax],al
     2d3:	add    BYTE PTR [rax],al
     2d5:	add    BYTE PTR [rax],al
	...

00000000000002d8 <botlish_entry_3: geo_new_capacity<int, int>>:
     2d8:	push   rbp
     2d9:	mov    rbp,rsp
     2dc:	mov    rsi,QWORD PTR [rdx]
     2df:	mov    rdx,QWORD PTR [rdx+0x8]
     2e3:	call   2e8 <botlish_entry_3+0x10>
			2e4: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     2e8:	mov    rsp,rbp
     2eb:	pop    rbp
     2ec:	ret
     2ed:	add    BYTE PTR [rax],al
	...

00000000000002f0 <botlish_fn_4: geo_grow<mutarray, int, str>>:
     2f0:	push   rbp
     2f1:	mov    rbp,rsp
     2f4:	sub    rsp,0x50
     2f8:	mov    QWORD PTR [rsp+0x20],rbx
     2fd:	mov    QWORD PTR [rsp+0x28],r12
     302:	mov    QWORD PTR [rsp+0x30],r13
     307:	mov    QWORD PTR [rsp+0x38],r14
     30c:	mov    QWORD PTR [rsp+0x40],r15
     311:	mov    r13,rdi
     314:	mov    QWORD PTR [rsp],rsi
     318:	mov    r12,rsi
     31b:	mov    QWORD PTR [rsp+0x8],rdx
     320:	mov    rbx,rdx
     323:	mov    QWORD PTR [rsp+0x10],rcx
     328:	mov    r14,rcx
     32b:	mov    rsi,r12
     32e:	mov    rdi,r13
     331:	call   336 <botlish_fn_4+0x46>
			332: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     336:	mov    r15,rax
     339:	mov    QWORD PTR [rsp+0x18],rax
     33e:	mov    rcx,rbx
     341:	and    rcx,rax
     344:	test   rcx,0x1
     34b:	jne    377 <botlish_fn_4+0x87>
     351:	mov    rdx,r15
     354:	mov    rsi,rbx
     357:	mov    rdi,r13
     35a:	call   35f <botlish_fn_4+0x6f>
			35b: R_X86_64_PLT32	rt_int_cmp-0x4
     35f:	mov    ecx,0x2
     364:	test   rax,rax
     367:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 458 <botlish_fn_4+0x168>
     36f:	mov    rax,r15
     372:	jmp    38a <botlish_fn_4+0x9a>
     377:	mov    ecx,0x2
     37c:	mov    rax,r15
     37f:	cmp    rbx,rax
     382:	cmovl  rcx,QWORD PTR [rip+0xce]        # 458 <botlish_fn_4+0x168>
     38a:	cmp    rcx,0x6
     38e:	je     42e <botlish_fn_4+0x13e>
     394:	mov    rsi,rax
     397:	mov    rdx,rbx
     39a:	mov    rdi,r13
     39d:	call   3a2 <botlish_fn_4+0xb2>
			39e: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     3a2:	mov    QWORD PTR [rsp+0x18],rax
     3a7:	mov    rdx,r14
     3aa:	mov    rsi,rax
     3ad:	mov    rdi,r13
     3b0:	call   3b5 <botlish_fn_4+0xc5>
			3b1: R_X86_64_PLT32	rt_mutarray_create-0x4
     3b5:	test   rax,rax
     3b8:	mov    r14,rax
     3bb:	je     3e4 <botlish_fn_4+0xf4>
     3c1:	mov    r8d,0x1
     3c7:	mov    rcx,r12
     3ca:	mov    rdi,r13
     3cd:	mov    r9,rbx
     3d0:	mov    rsi,r14
     3d3:	mov    rdx,r8
     3d6:	call   3db <botlish_fn_4+0xeb>
			3d7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     3db:	test   rax,rax
     3de:	jne    409 <botlish_fn_4+0x119>
     3e4:	xor    rax,rax
     3e7:	mov    rbx,QWORD PTR [rsp+0x20]
     3ec:	mov    r12,QWORD PTR [rsp+0x28]
     3f1:	mov    r13,QWORD PTR [rsp+0x30]
     3f6:	mov    r14,QWORD PTR [rsp+0x38]
     3fb:	mov    r15,QWORD PTR [rsp+0x40]
     400:	add    rsp,0x50
     404:	mov    rsp,rbp
     407:	pop    rbp
     408:	ret
     409:	mov    rax,r14
     40c:	mov    rbx,QWORD PTR [rsp+0x20]
     411:	mov    r12,QWORD PTR [rsp+0x28]
     416:	mov    r13,QWORD PTR [rsp+0x30]
     41b:	mov    r14,QWORD PTR [rsp+0x38]
     420:	mov    r15,QWORD PTR [rsp+0x40]
     425:	add    rsp,0x50
     429:	mov    rsp,rbp
     42c:	pop    rbp
     42d:	ret
     42e:	mov    rax,r12
     431:	mov    rbx,QWORD PTR [rsp+0x20]
     436:	mov    r12,QWORD PTR [rsp+0x28]
     43b:	mov    r13,QWORD PTR [rsp+0x30]
     440:	mov    r14,QWORD PTR [rsp+0x38]
     445:	mov    r15,QWORD PTR [rsp+0x40]
     44a:	add    rsp,0x50
     44e:	mov    rsp,rbp
     451:	pop    rbp
     452:	ret
     453:	add    BYTE PTR [rax],al
     455:	add    BYTE PTR [rax],al
     457:	add    BYTE PTR [rsi],al
     459:	add    BYTE PTR [rax],al
     45b:	add    BYTE PTR [rax],al
     45d:	add    BYTE PTR [rax],al
	...

0000000000000460 <botlish_entry_4: geo_grow<mutarray, int, str>>:
     460:	push   rbp
     461:	mov    rbp,rsp
     464:	mov    rsi,QWORD PTR [rdx]
     467:	mov    r8,QWORD PTR [rdx+0x8]
     46b:	mov    rcx,QWORD PTR [rdx+0x10]
     46f:	mov    rdx,r8
     472:	call   477 <botlish_entry_4+0x17>
			473: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_grow<mutarray, int, str>
     477:	mov    rsp,rbp
     47a:	pop    rbp
     47b:	ret
     47c:	add    BYTE PTR [rax],al
	...

0000000000000480 <botlish_fn_5: geo_grow<mutarray, int, List[str]>>:
     480:	push   rbp
     481:	mov    rbp,rsp
     484:	sub    rsp,0x50
     488:	mov    QWORD PTR [rsp+0x20],rbx
     48d:	mov    QWORD PTR [rsp+0x28],r12
     492:	mov    QWORD PTR [rsp+0x30],r13
     497:	mov    QWORD PTR [rsp+0x38],r14
     49c:	mov    QWORD PTR [rsp+0x40],r15
     4a1:	mov    r13,rdi
     4a4:	mov    QWORD PTR [rsp],rsi
     4a8:	mov    r12,rsi
     4ab:	mov    QWORD PTR [rsp+0x8],rdx
     4b0:	mov    rbx,rdx
     4b3:	mov    QWORD PTR [rsp+0x10],rcx
     4b8:	mov    r14,rcx
     4bb:	mov    rsi,r12
     4be:	mov    rdi,r13
     4c1:	call   4c6 <botlish_fn_5+0x46>
			4c2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     4c6:	mov    r15,rax
     4c9:	mov    QWORD PTR [rsp+0x18],rax
     4ce:	mov    rcx,rbx
     4d1:	and    rcx,rax
     4d4:	test   rcx,0x1
     4db:	jne    507 <botlish_fn_5+0x87>
     4e1:	mov    rdx,r15
     4e4:	mov    rsi,rbx
     4e7:	mov    rdi,r13
     4ea:	call   4ef <botlish_fn_5+0x6f>
			4eb: R_X86_64_PLT32	rt_int_cmp-0x4
     4ef:	mov    ecx,0x2
     4f4:	test   rax,rax
     4f7:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 5e8 <botlish_fn_5+0x168>
     4ff:	mov    rax,r15
     502:	jmp    51a <botlish_fn_5+0x9a>
     507:	mov    ecx,0x2
     50c:	mov    rax,r15
     50f:	cmp    rbx,rax
     512:	cmovl  rcx,QWORD PTR [rip+0xce]        # 5e8 <botlish_fn_5+0x168>
     51a:	cmp    rcx,0x6
     51e:	je     5be <botlish_fn_5+0x13e>
     524:	mov    rsi,rax
     527:	mov    rdx,rbx
     52a:	mov    rdi,r13
     52d:	call   532 <botlish_fn_5+0xb2>
			52e: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     532:	mov    QWORD PTR [rsp+0x18],rax
     537:	mov    rdx,r14
     53a:	mov    rsi,rax
     53d:	mov    rdi,r13
     540:	call   545 <botlish_fn_5+0xc5>
			541: R_X86_64_PLT32	rt_mutarray_create-0x4
     545:	test   rax,rax
     548:	mov    r14,rax
     54b:	je     574 <botlish_fn_5+0xf4>
     551:	mov    r8d,0x1
     557:	mov    rcx,r12
     55a:	mov    rdi,r13
     55d:	mov    r9,rbx
     560:	mov    rsi,r14
     563:	mov    rdx,r8
     566:	call   56b <botlish_fn_5+0xeb>
			567: R_X86_64_PLT32	rt_mutarray_copy-0x4
     56b:	test   rax,rax
     56e:	jne    599 <botlish_fn_5+0x119>
     574:	xor    rax,rax
     577:	mov    rbx,QWORD PTR [rsp+0x20]
     57c:	mov    r12,QWORD PTR [rsp+0x28]
     581:	mov    r13,QWORD PTR [rsp+0x30]
     586:	mov    r14,QWORD PTR [rsp+0x38]
     58b:	mov    r15,QWORD PTR [rsp+0x40]
     590:	add    rsp,0x50
     594:	mov    rsp,rbp
     597:	pop    rbp
     598:	ret
     599:	mov    rax,r14
     59c:	mov    rbx,QWORD PTR [rsp+0x20]
     5a1:	mov    r12,QWORD PTR [rsp+0x28]
     5a6:	mov    r13,QWORD PTR [rsp+0x30]
     5ab:	mov    r14,QWORD PTR [rsp+0x38]
     5b0:	mov    r15,QWORD PTR [rsp+0x40]
     5b5:	add    rsp,0x50
     5b9:	mov    rsp,rbp
     5bc:	pop    rbp
     5bd:	ret
     5be:	mov    rax,r12
     5c1:	mov    rbx,QWORD PTR [rsp+0x20]
     5c6:	mov    r12,QWORD PTR [rsp+0x28]
     5cb:	mov    r13,QWORD PTR [rsp+0x30]
     5d0:	mov    r14,QWORD PTR [rsp+0x38]
     5d5:	mov    r15,QWORD PTR [rsp+0x40]
     5da:	add    rsp,0x50
     5de:	mov    rsp,rbp
     5e1:	pop    rbp
     5e2:	ret
     5e3:	add    BYTE PTR [rax],al
     5e5:	add    BYTE PTR [rax],al
     5e7:	add    BYTE PTR [rsi],al
     5e9:	add    BYTE PTR [rax],al
     5eb:	add    BYTE PTR [rax],al
     5ed:	add    BYTE PTR [rax],al
	...

00000000000005f0 <botlish_entry_5: geo_grow<mutarray, int, List[str]>>:
     5f0:	push   rbp
     5f1:	mov    rbp,rsp
     5f4:	mov    rsi,QWORD PTR [rdx]
     5f7:	mov    r8,QWORD PTR [rdx+0x8]
     5fb:	mov    rcx,QWORD PTR [rdx+0x10]
     5ff:	mov    rdx,r8
     602:	call   607 <botlish_entry_5+0x17>
			603: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, List[str]>
     607:	mov    rsp,rbp
     60a:	pop    rbp
     60b:	ret

000000000000060c <botlish_fn_6: geo_append<mutarray, int, str>>:
     60c:	push   rbp
     60d:	mov    rbp,rsp
     610:	sub    rsp,0x40
     614:	mov    QWORD PTR [rsp+0x20],rbx
     619:	mov    QWORD PTR [rsp+0x28],r12
     61e:	mov    QWORD PTR [rsp+0x30],r13
     623:	mov    QWORD PTR [rsp+0x38],r14
     628:	mov    r14,rdi
     62b:	mov    QWORD PTR [rsp],rsi
     62f:	mov    QWORD PTR [rsp+0x8],rdx
     634:	mov    r13,rdx
     637:	mov    QWORD PTR [rsp+0x10],rcx
     63c:	mov    r12,rcx
     63f:	mov    rcx,r12
     642:	mov    rdx,r13
     645:	mov    rdi,r14
     648:	call   64d <botlish_fn_6+0x41>
			649: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_grow<mutarray, int, str>
     64d:	test   rax,rax
     650:	mov    rbx,rax
     653:	je     673 <botlish_fn_6+0x67>
     659:	mov    rcx,r12
     65c:	mov    rdx,r13
     65f:	mov    rdi,r14
     662:	mov    rsi,rbx
     665:	call   66a <botlish_fn_6+0x5e>
			666: R_X86_64_PLT32	rt_mutarray_set-0x4
     66a:	test   rax,rax
     66d:	jne    693 <botlish_fn_6+0x87>
     673:	xor    rax,rax
     676:	mov    rbx,QWORD PTR [rsp+0x20]
     67b:	mov    r12,QWORD PTR [rsp+0x28]
     680:	mov    r13,QWORD PTR [rsp+0x30]
     685:	mov    r14,QWORD PTR [rsp+0x38]
     68a:	add    rsp,0x40
     68e:	mov    rsp,rbp
     691:	pop    rbp
     692:	ret
     693:	mov    rax,rbx
     696:	mov    rbx,QWORD PTR [rsp+0x20]
     69b:	mov    r12,QWORD PTR [rsp+0x28]
     6a0:	mov    r13,QWORD PTR [rsp+0x30]
     6a5:	mov    r14,QWORD PTR [rsp+0x38]
     6aa:	add    rsp,0x40
     6ae:	mov    rsp,rbp
     6b1:	pop    rbp
     6b2:	ret

00000000000006b3 <botlish_entry_6: geo_append<mutarray, int, str>>:
     6b3:	push   rbp
     6b4:	mov    rbp,rsp
     6b7:	mov    rsi,QWORD PTR [rdx]
     6ba:	mov    r8,QWORD PTR [rdx+0x8]
     6be:	mov    rcx,QWORD PTR [rdx+0x10]
     6c2:	mov    rdx,r8
     6c5:	call   6ca <botlish_entry_6+0x17>
			6c6: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<mutarray, int, str>
     6ca:	mov    rsp,rbp
     6cd:	pop    rbp
     6ce:	ret

00000000000006cf <botlish_fn_7: geo_append<mutarray, int, List[str]>>:
     6cf:	push   rbp
     6d0:	mov    rbp,rsp
     6d3:	sub    rsp,0x40
     6d7:	mov    QWORD PTR [rsp+0x20],rbx
     6dc:	mov    QWORD PTR [rsp+0x28],r12
     6e1:	mov    QWORD PTR [rsp+0x30],r13
     6e6:	mov    QWORD PTR [rsp+0x38],r14
     6eb:	mov    r14,rdi
     6ee:	mov    QWORD PTR [rsp],rsi
     6f2:	mov    QWORD PTR [rsp+0x8],rdx
     6f7:	mov    r13,rdx
     6fa:	mov    QWORD PTR [rsp+0x10],rcx
     6ff:	mov    r12,rcx
     702:	mov    rcx,r12
     705:	mov    rdx,r13
     708:	mov    rdi,r14
     70b:	call   710 <botlish_fn_7+0x41>
			70c: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, List[str]>
     710:	test   rax,rax
     713:	mov    rbx,rax
     716:	je     736 <botlish_fn_7+0x67>
     71c:	mov    rcx,r12
     71f:	mov    rdx,r13
     722:	mov    rdi,r14
     725:	mov    rsi,rbx
     728:	call   72d <botlish_fn_7+0x5e>
			729: R_X86_64_PLT32	rt_mutarray_set-0x4
     72d:	test   rax,rax
     730:	jne    756 <botlish_fn_7+0x87>
     736:	xor    rax,rax
     739:	mov    rbx,QWORD PTR [rsp+0x20]
     73e:	mov    r12,QWORD PTR [rsp+0x28]
     743:	mov    r13,QWORD PTR [rsp+0x30]
     748:	mov    r14,QWORD PTR [rsp+0x38]
     74d:	add    rsp,0x40
     751:	mov    rsp,rbp
     754:	pop    rbp
     755:	ret
     756:	mov    rax,rbx
     759:	mov    rbx,QWORD PTR [rsp+0x20]
     75e:	mov    r12,QWORD PTR [rsp+0x28]
     763:	mov    r13,QWORD PTR [rsp+0x30]
     768:	mov    r14,QWORD PTR [rsp+0x38]
     76d:	add    rsp,0x40
     771:	mov    rsp,rbp
     774:	pop    rbp
     775:	ret

0000000000000776 <botlish_entry_7: geo_append<mutarray, int, List[str]>>:
     776:	push   rbp
     777:	mov    rbp,rsp
     77a:	mov    rsi,QWORD PTR [rdx]
     77d:	mov    r8,QWORD PTR [rdx+0x8]
     781:	mov    rcx,QWORD PTR [rdx+0x10]
     785:	mov    rdx,r8
     788:	call   78d <botlish_entry_7+0x17>
			789: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_append<mutarray, int, List[str]>
     78d:	mov    rsp,rbp
     790:	pop    rbp
     791:	ret

0000000000000792 <botlish_fn_8: geo_finish<mutarray, int>>:
     792:	push   rbp
     793:	mov    rbp,rsp
     796:	sub    rsp,0x10
     79a:	mov    QWORD PTR [rsp],rsi
     79e:	mov    QWORD PTR [rsp+0x8],rdx
     7a3:	call   7a8 <botlish_fn_8+0x16>
			7a4: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     7a8:	test   rax,rax
     7ab:	jne    7bd <botlish_fn_8+0x2b>
     7b1:	xor    rax,rax
     7b4:	add    rsp,0x10
     7b8:	mov    rsp,rbp
     7bb:	pop    rbp
     7bc:	ret
     7bd:	add    rsp,0x10
     7c1:	mov    rsp,rbp
     7c4:	pop    rbp
     7c5:	ret

00000000000007c6 <botlish_entry_8: geo_finish<mutarray, int>>:
     7c6:	push   rbp
     7c7:	mov    rbp,rsp
     7ca:	mov    rsi,QWORD PTR [rdx]
     7cd:	mov    rdx,QWORD PTR [rdx+0x8]
     7d1:	call   7d6 <botlish_entry_8+0x10>
			7d2: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
     7d6:	mov    rsp,rbp
     7d9:	pop    rbp
     7da:	ret
     7db:	add    BYTE PTR [rax],al
     7dd:	add    BYTE PTR [rax],al
	...

00000000000007e0 <botlish_fn_9: peek<str, int>>:
     7e0:	push   rbp
     7e1:	mov    rbp,rsp
     7e4:	sub    rsp,0x40
     7e8:	mov    QWORD PTR [rsp+0x20],rbx
     7ed:	mov    QWORD PTR [rsp+0x28],r12
     7f2:	mov    QWORD PTR [rsp+0x30],r13
     7f7:	mov    rbx,rdx
     7fa:	mov    r13,rdi
     7fd:	mov    QWORD PTR [rsp],rsi
     801:	mov    QWORD PTR [rsp+0x8],rdx
     806:	mov    rdx,QWORD PTR [rsi+0x8]
     80a:	mov    r12,rsi
     80d:	shl    rdx,1
     810:	mov    rax,rdx
     813:	or     rax,0x1
     817:	mov    rcx,rbx
     81a:	and    rcx,rax
     81d:	test   rcx,0x1
     824:	jne    84e <botlish_fn_9+0x6e>
     82a:	or     rdx,0x1
     82e:	mov    rsi,rbx
     831:	mov    rdi,r13
     834:	call   839 <botlish_fn_9+0x59>
			835: R_X86_64_PLT32	rt_int_cmp-0x4
     839:	mov    ecx,0x2
     83e:	test   rax,rax
     841:	cmovge rcx,QWORD PTR [rip+0xd7]        # 920 <botlish_fn_9+0x140>
     849:	jmp    862 <botlish_fn_9+0x82>
     84e:	or     rdx,0x1
     852:	mov    ecx,0x2
     857:	cmp    rbx,rdx
     85a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 920 <botlish_fn_9+0x140>
     862:	cmp    rcx,0x6
     866:	je     8f6 <botlish_fn_9+0x116>
     86c:	mov    QWORD PTR [rsp+0x10],0x3
     875:	test   rbx,0x1
     87c:	je     894 <botlish_fn_9+0xb4>
     882:	mov    rcx,rbx
     885:	add    rcx,0x2
     889:	seto   al
     88c:	test   al,al
     88e:	je     8a7 <botlish_fn_9+0xc7>
     894:	mov    edx,0x3
     899:	mov    rsi,rbx
     89c:	mov    rdi,r13
     89f:	call   8a4 <botlish_fn_9+0xc4>
			8a0: R_X86_64_PLT32	rt_int_add-0x4
     8a4:	mov    rcx,rax
     8a7:	mov    QWORD PTR [rsp+0x10],rcx
     8ac:	mov    rdx,rbx
     8af:	mov    rsi,r12
     8b2:	mov    rdi,r13
     8b5:	call   8ba <botlish_fn_9+0xda>
			8b6: R_X86_64_PLT32	rt_substr-0x4
     8ba:	test   rax,rax
     8bd:	jne    8de <botlish_fn_9+0xfe>
     8c3:	xor    rax,rax
     8c6:	mov    rbx,QWORD PTR [rsp+0x20]
     8cb:	mov    r12,QWORD PTR [rsp+0x28]
     8d0:	mov    r13,QWORD PTR [rsp+0x30]
     8d5:	add    rsp,0x40
     8d9:	mov    rsp,rbp
     8dc:	pop    rbp
     8dd:	ret
     8de:	mov    rbx,QWORD PTR [rsp+0x20]
     8e3:	mov    r12,QWORD PTR [rsp+0x28]
     8e8:	mov    r13,QWORD PTR [rsp+0x30]
     8ed:	add    rsp,0x40
     8f1:	mov    rsp,rbp
     8f4:	pop    rbp
     8f5:	ret
     8f6:	mov    rdi,r13
     8f9:	mov    rax,QWORD PTR [rdi+0x10]
     8fd:	mov    rax,QWORD PTR [rax+0x8]
     901:	mov    rbx,QWORD PTR [rsp+0x20]
     906:	mov    r12,QWORD PTR [rsp+0x28]
     90b:	mov    r13,QWORD PTR [rsp+0x30]
     910:	add    rsp,0x40
     914:	mov    rsp,rbp
     917:	pop    rbp
     918:	ret
     919:	add    BYTE PTR [rax],al
     91b:	add    BYTE PTR [rax],al
     91d:	add    BYTE PTR [rax],al
     91f:	add    BYTE PTR [rsi],al
     921:	add    BYTE PTR [rax],al
     923:	add    BYTE PTR [rax],al
     925:	add    BYTE PTR [rax],al
	...

0000000000000928 <botlish_entry_9: peek<str, int>>:
     928:	push   rbp
     929:	mov    rbp,rsp
     92c:	mov    rsi,QWORD PTR [rdx]
     92f:	mov    rdx,QWORD PTR [rdx+0x8]
     933:	call   938 <botlish_entry_9+0x10>
			934: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     938:	mov    rsp,rbp
     93b:	pop    rbp
     93c:	ret
     93d:	add    BYTE PTR [rax],al
	...

0000000000000940 <botlish_fn_10: quote_at?<str, int>>:
     940:	push   rbp
     941:	mov    rbp,rsp
     944:	sub    rsp,0x20
     948:	mov    QWORD PTR [rsp],rbx
     94c:	mov    QWORD PTR [rsp+0x8],r12
     951:	mov    QWORD PTR [rsp+0x10],r13
     956:	mov    rbx,rdx
     959:	mov    r13,rdi
     95c:	mov    rdx,QWORD PTR [rsi+0x8]
     960:	mov    r12,rsi
     963:	shl    rdx,1
     966:	mov    rax,rdx
     969:	or     rax,0x1
     96d:	mov    rcx,rbx
     970:	and    rcx,rax
     973:	test   rcx,0x1
     97a:	jne    9a4 <botlish_fn_10+0x64>
     980:	or     rdx,0x1
     984:	mov    rsi,rbx
     987:	mov    rdi,r13
     98a:	call   98f <botlish_fn_10+0x4f>
			98b: R_X86_64_PLT32	rt_int_cmp-0x4
     98f:	mov    ecx,0x2
     994:	test   rax,rax
     997:	cmovl  rcx,QWORD PTR [rip+0xa1]        # a40 <botlish_fn_10+0x100>
     99f:	jmp    9bb <botlish_fn_10+0x7b>
     9a4:	or     rdx,0x1
     9a8:	mov    ecx,0x2
     9ad:	mov    rax,rbx
     9b0:	cmp    rax,rdx
     9b3:	cmovl  rcx,QWORD PTR [rip+0x85]        # a40 <botlish_fn_10+0x100>
     9bb:	mov    eax,0x6
     9c0:	cmp    rcx,0x6
     9c4:	je     9d7 <botlish_fn_10+0x97>
     9ca:	mov    eax,0x2
     9cf:	mov    r12,rax
     9d2:	jmp    a24 <botlish_fn_10+0xe4>
     9d7:	mov    rdi,r13
     9da:	mov    rsi,r12
     9dd:	mov    r12,rax
     9e0:	mov    rdx,rbx
     9e3:	call   9e8 <botlish_fn_10+0xa8>
			9e4: R_X86_64_PLT32	rt_str_char_at-0x4
     9e8:	test   rax,rax
     9eb:	jne    a0b <botlish_fn_10+0xcb>
     9f1:	xor    rax,rax
     9f4:	mov    rbx,QWORD PTR [rsp]
     9f8:	mov    r12,QWORD PTR [rsp+0x8]
     9fd:	mov    r13,QWORD PTR [rsp+0x10]
     a02:	add    rsp,0x20
     a06:	mov    rsp,rbp
     a09:	pop    rbp
     a0a:	ret
     a0b:	cmp    rax,0x114
     a11:	je     a21 <botlish_fn_10+0xe1>
     a17:	mov    eax,0x2
     a1c:	jmp    a24 <botlish_fn_10+0xe4>
     a21:	mov    rax,r12
     a24:	mov    rbx,QWORD PTR [rsp]
     a28:	mov    r12,QWORD PTR [rsp+0x8]
     a2d:	mov    r13,QWORD PTR [rsp+0x10]
     a32:	add    rsp,0x20
     a36:	mov    rsp,rbp
     a39:	pop    rbp
     a3a:	ret
     a3b:	add    BYTE PTR [rax],al
     a3d:	add    BYTE PTR [rax],al
     a3f:	add    BYTE PTR [rsi],al
     a41:	add    BYTE PTR [rax],al
     a43:	add    BYTE PTR [rax],al
     a45:	add    BYTE PTR [rax],al
	...

0000000000000a48 <botlish_entry_10: quote_at?<str, int>>:
     a48:	push   rbp
     a49:	mov    rbp,rsp
     a4c:	mov    rsi,QWORD PTR [rdx]
     a4f:	mov    rdx,QWORD PTR [rdx+0x8]
     a53:	call   a58 <botlish_entry_10+0x10>
			a54: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     a58:	mov    rsp,rbp
     a5b:	pop    rbp
     a5c:	ret
     a5d:	add    BYTE PTR [rax],al
	...

0000000000000a60 <botlish_fn_11: scan_unquoted<str, int, int>>:
     a60:	push   rbp
     a61:	mov    rbp,rsp
     a64:	sub    rsp,0x40
     a68:	mov    QWORD PTR [rsp+0x20],rbx
     a6d:	mov    QWORD PTR [rsp+0x28],r12
     a72:	mov    QWORD PTR [rsp+0x30],r13
     a77:	mov    QWORD PTR [rsp+0x38],r14
     a7c:	mov    r14,rdi
     a7f:	mov    QWORD PTR [rsp+0x18],0x0
     a88:	mov    QWORD PTR [rsp],rsi
     a8c:	mov    r13,rsi
     a8f:	mov    QWORD PTR [rsp+0x8],rdx
     a94:	mov    rbx,rdx
     a97:	mov    QWORD PTR [rsp+0x10],rcx
     a9c:	mov    r12,rcx
     a9f:	mov    rdx,QWORD PTR [rsi+0x8]
     aa3:	mov    r13,rsi
     aa6:	shl    rdx,1
     aa9:	or     rdx,0x1
     aad:	mov    rax,r12
     ab0:	and    rax,rdx
     ab3:	test   rax,0x1
     ab9:	jne    adf <botlish_fn_11+0x7f>
     abf:	mov    rsi,r12
     ac2:	mov    rdi,r14
     ac5:	call   aca <botlish_fn_11+0x6a>
			ac6: R_X86_64_PLT32	rt_int_cmp-0x4
     aca:	mov    ecx,0x2
     acf:	test   rax,rax
     ad2:	cmovl  rcx,QWORD PTR [rip+0x17e]        # c58 <botlish_fn_11+0x1f8>
     ada:	jmp    af2 <botlish_fn_11+0x92>
     adf:	mov    ecx,0x2
     ae4:	mov    rsi,r12
     ae7:	cmp    rsi,rdx
     aea:	cmovl  rcx,QWORD PTR [rip+0x166]        # c58 <botlish_fn_11+0x1f8>
     af2:	cmp    rcx,0x6
     af6:	je     b0a <botlish_fn_11+0xaa>
     afc:	mov    rdx,rbx
     aff:	mov    rsi,r13
     b02:	mov    rdi,r14
     b05:	jmp    b95 <botlish_fn_11+0x135>
     b0a:	mov    rdx,r12
     b0d:	mov    rsi,r13
     b10:	mov    rdi,r14
     b13:	call   b18 <botlish_fn_11+0xb8>
			b14: R_X86_64_PLT32	rt_str_char_at-0x4
     b18:	test   rax,rax
     b1b:	je     bac <botlish_fn_11+0x14c>
     b21:	cmp    rax,0x164
     b27:	je     b37 <botlish_fn_11+0xd7>
     b2d:	mov    ecx,0x6
     b32:	jmp    b3c <botlish_fn_11+0xdc>
     b37:	mov    ecx,0x2
     b3c:	cmp    rcx,0x6
     b40:	je     b50 <botlish_fn_11+0xf0>
     b46:	mov    eax,0x2
     b4b:	jmp    b82 <botlish_fn_11+0x122>
     b50:	cmp    rax,0x54
     b54:	je     b64 <botlish_fn_11+0x104>
     b5a:	mov    eax,0x6
     b5f:	jmp    b69 <botlish_fn_11+0x109>
     b64:	mov    eax,0x2
     b69:	cmp    rax,0x6
     b6d:	je     b7d <botlish_fn_11+0x11d>
     b73:	mov    eax,0x2
     b78:	jmp    b82 <botlish_fn_11+0x122>
     b7d:	mov    eax,0x6
     b82:	cmp    rax,0x6
     b86:	je     bef <botlish_fn_11+0x18f>
     b8c:	mov    rdx,rbx
     b8f:	mov    rsi,r13
     b92:	mov    rdi,r14
     b95:	mov    rsi,r13
     b98:	mov    rdi,r14
     b9b:	mov    rcx,r12
     b9e:	call   ba3 <botlish_fn_11+0x143>
			b9f: R_X86_64_PLT32	rt_substr-0x4
     ba3:	test   rax,rax
     ba6:	jne    bcf <botlish_fn_11+0x16f>
     bac:	xor    rdx,rdx
     baf:	mov    rax,rdx
     bb2:	mov    rbx,QWORD PTR [rsp+0x20]
     bb7:	mov    r12,QWORD PTR [rsp+0x28]
     bbc:	mov    r13,QWORD PTR [rsp+0x30]
     bc1:	mov    r14,QWORD PTR [rsp+0x38]
     bc6:	add    rsp,0x40
     bca:	mov    rsp,rbp
     bcd:	pop    rbp
     bce:	ret
     bcf:	mov    rdx,r12
     bd2:	mov    rbx,QWORD PTR [rsp+0x20]
     bd7:	mov    r12,QWORD PTR [rsp+0x28]
     bdc:	mov    r13,QWORD PTR [rsp+0x30]
     be1:	mov    r14,QWORD PTR [rsp+0x38]
     be6:	add    rsp,0x40
     bea:	mov    rsp,rbp
     bed:	pop    rbp
     bee:	ret
     bef:	mov    QWORD PTR [rsp+0x18],0x3
     bf8:	mov    rdx,r12
     bfb:	test   rdx,0x1
     c02:	je     c25 <botlish_fn_11+0x1c5>
     c08:	mov    rdx,r12
     c0b:	mov    rax,rdx
     c0e:	add    rax,0x2
     c12:	seto   cl
     c15:	test   cl,cl
     c17:	jne    c25 <botlish_fn_11+0x1c5>
     c1d:	mov    rsi,r13
     c20:	jmp    c38 <botlish_fn_11+0x1d8>
     c25:	mov    edx,0x3
     c2a:	mov    rsi,r12
     c2d:	mov    rdi,r14
     c30:	call   c35 <botlish_fn_11+0x1d5>
			c31: R_X86_64_PLT32	rt_int_add-0x4
     c35:	mov    rsi,r13
     c38:	mov    rsi,r13
     c3b:	mov    QWORD PTR [rsp],rsi
     c3f:	mov    rdx,rbx
     c42:	mov    QWORD PTR [rsp+0x8],rdx
     c47:	mov    QWORD PTR [rsp+0x10],rax
     c4c:	mov    r12,rax
     c4f:	jmp    a9f <botlish_fn_11+0x3f>
     c54:	add    BYTE PTR [rax],al
     c56:	add    BYTE PTR [rax],al
     c58:	(bad)
     c59:	add    BYTE PTR [rax],al
     c5b:	add    BYTE PTR [rax],al
     c5d:	add    BYTE PTR [rax],al
	...

0000000000000c60 <botlish_entry_11: scan_unquoted<str, int, int>>:
     c60:	push   rbp
     c61:	mov    rbp,rsp
     c64:	ud2

0000000000000c66 <botlish_fn_12: scan_quoted<str, int, str>>:
     c66:	push   rbp
     c67:	mov    rbp,rsp
     c6a:	sub    rsp,0xb0
     c71:	mov    QWORD PTR [rsp+0x80],rbx
     c79:	mov    QWORD PTR [rsp+0x88],r12
     c81:	mov    QWORD PTR [rsp+0x90],r13
     c89:	mov    QWORD PTR [rsp+0x98],r14
     c91:	mov    QWORD PTR [rsp+0xa0],r15
     c99:	mov    r15,rdi
     c9c:	mov    QWORD PTR [rsp+0x18],0x0
     ca5:	mov    QWORD PTR [rsp+0x20],0x0
     cae:	mov    QWORD PTR [rsp],rsi
     cb2:	mov    QWORD PTR [rsp+0x8],rdx
     cb7:	mov    QWORD PTR [rsp+0x10],rcx
     cbc:	mov    r13,rcx
     cbf:	lea    r12,[rsp+0x58]
     cc4:	mov    rbx,rsi
     cc7:	mov    QWORD PTR [rsp+0x78],rdx
     ccc:	mov    rdx,QWORD PTR [rsp+0x78]
     cd1:	mov    rsi,rbx
     cd4:	mov    rdi,r15
     cd7:	call   cdc <botlish_fn_12+0x76>
			cd8: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     cdc:	test   rax,rax
     cdf:	je     f7b <botlish_fn_12+0x315>
     ce5:	mov    QWORD PTR [rsp+0x18],rax
     cea:	mov    r14,rax
     ced:	mov    rdx,QWORD PTR [rsp+0x78]
     cf2:	mov    rsi,rbx
     cf5:	mov    rdi,r15
     cf8:	call   cfd <botlish_fn_12+0x97>
			cf9: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     cfd:	test   rax,rax
     d00:	je     f7b <botlish_fn_12+0x315>
     d06:	cmp    rax,0x6
     d0a:	je     dc3 <botlish_fn_12+0x15d>
     d10:	mov    QWORD PTR [rsp+0x20],0x3
     d19:	mov    rsi,QWORD PTR [rsp+0x78]
     d1e:	test   rsi,0x1
     d25:	je     d4f <botlish_fn_12+0xe9>
     d2b:	mov    rsi,QWORD PTR [rsp+0x78]
     d30:	mov    rcx,rsi
     d33:	add    rcx,0x2
     d37:	seto   dl
     d3a:	test   dl,dl
     d3c:	jne    d4f <botlish_fn_12+0xe9>
     d42:	mov    rsi,rcx
     d45:	mov    QWORD PTR [rsp+0x78],rcx
     d4a:	jmp    d69 <botlish_fn_12+0x103>
     d4f:	mov    edx,0x3
     d54:	mov    rsi,QWORD PTR [rsp+0x78]
     d59:	mov    rdi,r15
     d5c:	call   d61 <botlish_fn_12+0xfb>
			d5d: R_X86_64_PLT32	rt_int_add-0x4
     d61:	mov    rsi,rax
     d64:	mov    QWORD PTR [rsp+0x78],rax
     d69:	mov    QWORD PTR [rsp+0x8],rsi
     d6e:	mov    QWORD PTR [rsp+0x58],0x0
     d77:	mov    QWORD PTR [rsp+0x60],r13
     d7c:	mov    QWORD PTR [rsp+0x68],0x0
     d85:	mov    QWORD PTR [rsp+0x70],r14
     d8a:	mov    esi,0x2
     d8f:	mov    edx,0x4
     d94:	mov    rcx,r12
     d97:	mov    rdi,r15
     d9a:	call   d9f <botlish_fn_12+0x139>
			d9b: R_X86_64_PLT32	rt_construct-0x4
     d9f:	test   rax,rax
     da2:	je     f7b <botlish_fn_12+0x315>
     da8:	mov    QWORD PTR [rsp],rbx
     dac:	mov    rsi,QWORD PTR [rsp+0x78]
     db1:	mov    QWORD PTR [rsp+0x8],rsi
     db6:	mov    QWORD PTR [rsp+0x10],rax
     dbb:	mov    r13,rax
     dbe:	jmp    ccc <botlish_fn_12+0x66>
     dc3:	mov    QWORD PTR [rsp+0x20],0x3
     dcc:	mov    rsi,QWORD PTR [rsp+0x78]
     dd1:	test   rsi,0x1
     dd8:	je     df5 <botlish_fn_12+0x18f>
     dde:	mov    rsi,QWORD PTR [rsp+0x78]
     de3:	mov    rdx,rsi
     de6:	add    rdx,0x2
     dea:	seto   al
     ded:	test   al,al
     def:	je     e0a <botlish_fn_12+0x1a4>
     df5:	mov    edx,0x3
     dfa:	mov    rsi,QWORD PTR [rsp+0x78]
     dff:	mov    rdi,r15
     e02:	call   e07 <botlish_fn_12+0x1a1>
			e03: R_X86_64_PLT32	rt_int_add-0x4
     e07:	mov    rdx,rax
     e0a:	mov    rsi,rbx
     e0d:	mov    rdi,r15
     e10:	call   e15 <botlish_fn_12+0x1af>
			e11: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     e15:	test   rax,rax
     e18:	je     f7b <botlish_fn_12+0x315>
     e1e:	cmp    rax,0x6
     e22:	je     ee1 <botlish_fn_12+0x27b>
     e28:	xor    rsi,rsi
     e2b:	lea    rcx,[rsp+0x48]
     e30:	mov    QWORD PTR [rsp+0x48],0x0
     e39:	mov    QWORD PTR [rsp+0x50],r13
     e3e:	mov    edx,0x2
     e43:	mov    rdi,r15
     e46:	call   e4b <botlish_fn_12+0x1e5>
			e47: R_X86_64_PLT32	rt_construct-0x4
     e4b:	test   rax,rax
     e4e:	je     f7b <botlish_fn_12+0x315>
     e54:	mov    QWORD PTR [rsp],rax
     e58:	mov    r12,rax
     e5b:	mov    QWORD PTR [rsp+0x10],0x3
     e64:	mov    rsi,QWORD PTR [rsp+0x78]
     e69:	test   rsi,0x1
     e70:	je     e95 <botlish_fn_12+0x22f>
     e76:	mov    rsi,QWORD PTR [rsp+0x78]
     e7b:	mov    rdx,rsi
     e7e:	add    rdx,0x2
     e82:	seto   al
     e85:	test   al,al
     e87:	jne    e95 <botlish_fn_12+0x22f>
     e8d:	mov    rax,r12
     e90:	jmp    ead <botlish_fn_12+0x247>
     e95:	mov    edx,0x3
     e9a:	mov    rsi,QWORD PTR [rsp+0x78]
     e9f:	mov    rdi,r15
     ea2:	call   ea7 <botlish_fn_12+0x241>
			ea3: R_X86_64_PLT32	rt_int_add-0x4
     ea7:	mov    rdx,rax
     eaa:	mov    rax,r12
     ead:	mov    rbx,QWORD PTR [rsp+0x80]
     eb5:	mov    r12,QWORD PTR [rsp+0x88]
     ebd:	mov    r13,QWORD PTR [rsp+0x90]
     ec5:	mov    r14,QWORD PTR [rsp+0x98]
     ecd:	mov    r15,QWORD PTR [rsp+0xa0]
     ed5:	add    rsp,0xb0
     edc:	mov    rsp,rbp
     edf:	pop    rbp
     ee0:	ret
     ee1:	mov    QWORD PTR [rsp+0x20],0x5
     eea:	mov    rsi,QWORD PTR [rsp+0x78]
     eef:	test   rsi,0x1
     ef6:	je     f20 <botlish_fn_12+0x2ba>
     efc:	mov    rsi,QWORD PTR [rsp+0x78]
     f01:	mov    rcx,rsi
     f04:	add    rcx,0x4
     f08:	seto   al
     f0b:	test   al,al
     f0d:	jne    f20 <botlish_fn_12+0x2ba>
     f13:	mov    rsi,rcx
     f16:	mov    QWORD PTR [rsp+0x78],rcx
     f1b:	jmp    f3a <botlish_fn_12+0x2d4>
     f20:	mov    edx,0x5
     f25:	mov    rsi,QWORD PTR [rsp+0x78]
     f2a:	mov    rdi,r15
     f2d:	call   f32 <botlish_fn_12+0x2cc>
			f2e: R_X86_64_PLT32	rt_int_add-0x4
     f32:	mov    rsi,rax
     f35:	mov    QWORD PTR [rsp+0x78],rax
     f3a:	mov    QWORD PTR [rsp+0x8],rsi
     f3f:	lea    rcx,[rsp+0x28]
     f44:	mov    QWORD PTR [rsp+0x28],0x0
     f4d:	mov    QWORD PTR [rsp+0x30],r13
     f52:	mov    QWORD PTR [rsp+0x38],0x0
     f5b:	mov    QWORD PTR [rsp+0x40],r14
     f60:	mov    esi,0x2
     f65:	mov    edx,0x4
     f6a:	mov    rdi,r15
     f6d:	call   f72 <botlish_fn_12+0x30c>
			f6e: R_X86_64_PLT32	rt_construct-0x4
     f72:	test   rax,rax
     f75:	jne    fb5 <botlish_fn_12+0x34f>
     f7b:	xor    rdx,rdx
     f7e:	mov    rax,rdx
     f81:	mov    rbx,QWORD PTR [rsp+0x80]
     f89:	mov    r12,QWORD PTR [rsp+0x88]
     f91:	mov    r13,QWORD PTR [rsp+0x90]
     f99:	mov    r14,QWORD PTR [rsp+0x98]
     fa1:	mov    r15,QWORD PTR [rsp+0xa0]
     fa9:	add    rsp,0xb0
     fb0:	mov    rsp,rbp
     fb3:	pop    rbp
     fb4:	ret
     fb5:	mov    QWORD PTR [rsp],rbx
     fb9:	mov    rsi,QWORD PTR [rsp+0x78]
     fbe:	mov    QWORD PTR [rsp+0x8],rsi
     fc3:	mov    QWORD PTR [rsp+0x10],rax
     fc8:	mov    r13,rax
     fcb:	jmp    ccc <botlish_fn_12+0x66>

0000000000000fd0 <botlish_entry_12: scan_quoted<str, int, str>>:
     fd0:	push   rbp
     fd1:	mov    rbp,rsp
     fd4:	ud2

0000000000000fd6 <botlish_fn_13: scan_field<str, int>>:
     fd6:	push   rbp
     fd7:	mov    rbp,rsp
     fda:	sub    rsp,0x40
     fde:	mov    QWORD PTR [rsp+0x20],rbx
     fe3:	mov    QWORD PTR [rsp+0x28],r12
     fe8:	mov    QWORD PTR [rsp+0x30],r13
     fed:	mov    r12,rdi
     ff0:	mov    r13,rdx
     ff3:	mov    QWORD PTR [rsp+0x10],0x0
     ffc:	mov    QWORD PTR [rsp],rsi
    1000:	mov    rbx,rsi
    1003:	mov    QWORD PTR [rsp+0x8],rdx
    1008:	mov    rdx,r13
    100b:	mov    rsi,rbx
    100e:	mov    rdi,r12
    1011:	call   1016 <botlish_fn_13+0x40>
			1012: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
    1016:	test   rax,rax
    1019:	je     10ca <botlish_fn_13+0xf4>
    101f:	cmp    rax,0x6
    1023:	je     105b <botlish_fn_13+0x85>
    1029:	mov    rcx,r13
    102c:	mov    rsi,rbx
    102f:	mov    rdi,r12
    1032:	mov    rdx,rcx
    1035:	call   103a <botlish_fn_13+0x64>
			1036: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_unquoted<str, int, int>
    103a:	test   rax,rax
    103d:	je     10ca <botlish_fn_13+0xf4>
    1043:	mov    rbx,QWORD PTR [rsp+0x20]
    1048:	mov    r12,QWORD PTR [rsp+0x28]
    104d:	mov    r13,QWORD PTR [rsp+0x30]
    1052:	add    rsp,0x40
    1056:	mov    rsp,rbp
    1059:	pop    rbp
    105a:	ret
    105b:	mov    rcx,r13
    105e:	mov    QWORD PTR [rsp+0x10],0x3
    1067:	test   rcx,0x1
    106e:	jne    107c <botlish_fn_13+0xa6>
    1074:	mov    r13,rcx
    1077:	jmp    1091 <botlish_fn_13+0xbb>
    107c:	mov    rdx,rcx
    107f:	add    rdx,0x2
    1083:	mov    r13,rcx
    1086:	seto   al
    1089:	test   al,al
    108b:	je     10a4 <botlish_fn_13+0xce>
    1091:	mov    edx,0x3
    1096:	mov    rsi,r13
    1099:	mov    rdi,r12
    109c:	call   10a1 <botlish_fn_13+0xcb>
			109d: R_X86_64_PLT32	rt_int_add-0x4
    10a1:	mov    rdx,rax
    10a4:	mov    QWORD PTR [rsp+0x8],rdx
    10a9:	mov    rdi,r12
    10ac:	mov    rax,QWORD PTR [rdi+0x10]
    10b0:	mov    rcx,QWORD PTR [rax+0x8]
    10b4:	mov    QWORD PTR [rsp+0x10],rcx
    10b9:	mov    rsi,rbx
    10bc:	call   10c1 <botlish_fn_13+0xeb>
			10bd: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_quoted<str, int, str>
    10c1:	test   rax,rax
    10c4:	jne    10e8 <botlish_fn_13+0x112>
    10ca:	xor    rdx,rdx
    10cd:	mov    rax,rdx
    10d0:	mov    rbx,QWORD PTR [rsp+0x20]
    10d5:	mov    r12,QWORD PTR [rsp+0x28]
    10da:	mov    r13,QWORD PTR [rsp+0x30]
    10df:	add    rsp,0x40
    10e3:	mov    rsp,rbp
    10e6:	pop    rbp
    10e7:	ret
    10e8:	mov    rbx,QWORD PTR [rsp+0x20]
    10ed:	mov    r12,QWORD PTR [rsp+0x28]
    10f2:	mov    r13,QWORD PTR [rsp+0x30]
    10f7:	add    rsp,0x40
    10fb:	mov    rsp,rbp
    10fe:	pop    rbp
    10ff:	ret

0000000000001100 <botlish_entry_13: scan_field<str, int>>:
    1100:	push   rbp
    1101:	mov    rbp,rsp
    1104:	ud2
	...

0000000000001108 <botlish_fn_14: scan_record_rest<str, int, mutarray, int>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	sub    rsp,0x60
    1110:	mov    QWORD PTR [rsp+0x30],rbx
    1115:	mov    QWORD PTR [rsp+0x38],r12
    111a:	mov    QWORD PTR [rsp+0x40],r13
    111f:	mov    QWORD PTR [rsp+0x48],r14
    1124:	mov    QWORD PTR [rsp+0x50],r15
    1129:	mov    r13,rdi
    112c:	mov    QWORD PTR [rsp+0x20],0x0
    1135:	mov    QWORD PTR [rsp],rsi
    1139:	mov    QWORD PTR [rsp+0x8],rdx
    113e:	mov    QWORD PTR [rsp+0x10],rcx
    1143:	mov    QWORD PTR [rsp+0x18],r8
    1148:	mov    rbx,rsi
    114b:	mov    r12,rdx
    114e:	mov    r14,r8
    1151:	mov    r15,rcx
    1154:	mov    rdx,QWORD PTR [rbx+0x8]
    1158:	shl    rdx,1
    115b:	or     rdx,0x1
    115f:	mov    rax,r12
    1162:	and    rax,rdx
    1165:	test   rax,0x1
    116b:	jne    1191 <botlish_fn_14+0x89>
    1171:	mov    rsi,r12
    1174:	mov    rdi,r13
    1177:	call   117c <botlish_fn_14+0x74>
			1178: R_X86_64_PLT32	rt_int_cmp-0x4
    117c:	mov    ecx,0x2
    1181:	test   rax,rax
    1184:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 13d8 <botlish_fn_14+0x2d0>
    118c:	jmp    11a4 <botlish_fn_14+0x9c>
    1191:	mov    ecx,0x2
    1196:	mov    rax,r12
    1199:	cmp    rax,rdx
    119c:	cmovl  rcx,QWORD PTR [rip+0x234]        # 13d8 <botlish_fn_14+0x2d0>
    11a4:	cmp    rcx,0x6
    11a8:	je     11bc <botlish_fn_14+0xb4>
    11ae:	mov    rdx,r14
    11b1:	mov    rsi,r15
    11b4:	mov    rdi,r13
    11b7:	jmp    11f2 <botlish_fn_14+0xea>
    11bc:	mov    rdx,r12
    11bf:	mov    rsi,rbx
    11c2:	mov    rdi,r13
    11c5:	call   11ca <botlish_fn_14+0xc2>
			11c6: R_X86_64_PLT32	rt_str_char_at-0x4
    11ca:	test   rax,rax
    11cd:	je     1332 <botlish_fn_14+0x22a>
    11d3:	cmp    rax,0x164
    11d9:	je     12b1 <botlish_fn_14+0x1a9>
    11df:	cmp    rax,0x54
    11e3:	je     1228 <botlish_fn_14+0x120>
    11e9:	mov    rdx,r14
    11ec:	mov    rsi,r15
    11ef:	mov    rdi,r13
    11f2:	mov    rdi,r13
    11f5:	call   11fa <botlish_fn_14+0xf2>
			11f6: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    11fa:	test   rax,rax
    11fd:	je     1332 <botlish_fn_14+0x22a>
    1203:	mov    rdx,r12
    1206:	mov    rbx,QWORD PTR [rsp+0x30]
    120b:	mov    r12,QWORD PTR [rsp+0x38]
    1210:	mov    r13,QWORD PTR [rsp+0x40]
    1215:	mov    r14,QWORD PTR [rsp+0x48]
    121a:	mov    r15,QWORD PTR [rsp+0x50]
    121f:	add    rsp,0x60
    1223:	mov    rsp,rbp
    1226:	pop    rbp
    1227:	ret
    1228:	mov    rdx,r14
    122b:	mov    rsi,r15
    122e:	mov    rdi,r13
    1231:	call   1236 <botlish_fn_14+0x12e>
			1232: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    1236:	test   rax,rax
    1239:	je     1332 <botlish_fn_14+0x22a>
    123f:	mov    QWORD PTR [rsp],rax
    1243:	mov    r14,rax
    1246:	mov    QWORD PTR [rsp+0x10],0x3
    124f:	mov    rdx,r12
    1252:	test   rdx,0x1
    1259:	je     1279 <botlish_fn_14+0x171>
    125f:	mov    rdx,r12
    1262:	add    rdx,0x2
    1266:	seto   al
    1269:	test   al,al
    126b:	jne    1279 <botlish_fn_14+0x171>
    1271:	mov    rax,r14
    1274:	jmp    128f <botlish_fn_14+0x187>
    1279:	mov    edx,0x3
    127e:	mov    rsi,r12
    1281:	mov    rdi,r13
    1284:	call   1289 <botlish_fn_14+0x181>
			1285: R_X86_64_PLT32	rt_int_add-0x4
    1289:	mov    rdx,rax
    128c:	mov    rax,r14
    128f:	mov    rbx,QWORD PTR [rsp+0x30]
    1294:	mov    r12,QWORD PTR [rsp+0x38]
    1299:	mov    r13,QWORD PTR [rsp+0x40]
    129e:	mov    r14,QWORD PTR [rsp+0x48]
    12a3:	mov    r15,QWORD PTR [rsp+0x50]
    12a8:	add    rsp,0x60
    12ac:	mov    rsp,rbp
    12af:	pop    rbp
    12b0:	ret
    12b1:	mov    rsi,r12
    12b4:	mov    edx,0x3
    12b9:	mov    r12,rdx
    12bc:	mov    QWORD PTR [rsp+0x20],0x3
    12c5:	test   rsi,0x1
    12cc:	je     12e4 <botlish_fn_14+0x1dc>
    12d2:	mov    rdx,rsi
    12d5:	add    rdx,0x2
    12d9:	seto   al
    12dc:	test   al,al
    12de:	je     12f2 <botlish_fn_14+0x1ea>
    12e4:	mov    rdx,r12
    12e7:	mov    rdi,r13
    12ea:	call   12ef <botlish_fn_14+0x1e7>
			12eb: R_X86_64_PLT32	rt_int_add-0x4
    12ef:	mov    rdx,rax
    12f2:	mov    QWORD PTR [rsp+0x8],rdx
    12f7:	mov    rsi,rbx
    12fa:	mov    rdi,r13
    12fd:	call   1302 <botlish_fn_14+0x1fa>
			12fe: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    1302:	test   rax,rax
    1305:	je     1332 <botlish_fn_14+0x22a>
    130b:	mov    QWORD PTR [rsp+0x8],rax
    1310:	mov    rcx,rax
    1313:	mov    QWORD PTR [rsp+0x20],rdx
    1318:	mov    rsi,r15
    131b:	mov    r15,rdx
    131e:	mov    rdx,r14
    1321:	mov    rdi,r13
    1324:	call   1329 <botlish_fn_14+0x221>
			1325: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<mutarray, int, str>
    1329:	test   rax,rax
    132c:	jne    135a <botlish_fn_14+0x252>
    1332:	xor    rdx,rdx
    1335:	mov    rax,rdx
    1338:	mov    rbx,QWORD PTR [rsp+0x30]
    133d:	mov    r12,QWORD PTR [rsp+0x38]
    1342:	mov    r13,QWORD PTR [rsp+0x40]
    1347:	mov    r14,QWORD PTR [rsp+0x48]
    134c:	mov    r15,QWORD PTR [rsp+0x50]
    1351:	add    rsp,0x60
    1355:	mov    rsp,rbp
    1358:	pop    rbp
    1359:	ret
    135a:	mov    QWORD PTR [rsp+0x8],rax
    135f:	mov    QWORD PTR [rsp+0x28],rax
    1364:	mov    QWORD PTR [rsp+0x10],0x3
    136d:	mov    rdx,r14
    1370:	test   rdx,0x1
    1377:	jne    1388 <botlish_fn_14+0x280>
    137d:	mov    rdx,r12
    1380:	mov    rsi,r14
    1383:	jmp    13a3 <botlish_fn_14+0x29b>
    1388:	mov    rdx,r14
    138b:	mov    rax,rdx
    138e:	add    rax,0x2
    1392:	seto   cl
    1395:	test   cl,cl
    1397:	je     13ab <botlish_fn_14+0x2a3>
    139d:	mov    rdx,r12
    13a0:	mov    rsi,r14
    13a3:	mov    rdi,r13
    13a6:	call   13ab <botlish_fn_14+0x2a3>
			13a7: R_X86_64_PLT32	rt_int_add-0x4
    13ab:	mov    QWORD PTR [rsp],rbx
    13af:	mov    rdx,r15
    13b2:	mov    QWORD PTR [rsp+0x8],rdx
    13b7:	mov    rcx,QWORD PTR [rsp+0x28]
    13bc:	mov    QWORD PTR [rsp+0x10],rcx
    13c1:	mov    QWORD PTR [rsp+0x18],rax
    13c6:	mov    r12,rdx
    13c9:	mov    r14,rax
    13cc:	mov    r15,rcx
    13cf:	jmp    1154 <botlish_fn_14+0x4c>
    13d4:	add    BYTE PTR [rax],al
    13d6:	add    BYTE PTR [rax],al
    13d8:	(bad)
    13d9:	add    BYTE PTR [rax],al
    13db:	add    BYTE PTR [rax],al
    13dd:	add    BYTE PTR [rax],al
	...

00000000000013e0 <botlish_entry_14: scan_record_rest<str, int, mutarray, int>>:
    13e0:	push   rbp
    13e1:	mov    rbp,rsp
    13e4:	ud2

00000000000013e6 <botlish_fn_15: scan_record<str, int>>:
    13e6:	push   rbp
    13e7:	mov    rbp,rsp
    13ea:	sub    rsp,0x40
    13ee:	mov    QWORD PTR [rsp+0x20],rbx
    13f3:	mov    QWORD PTR [rsp+0x28],r12
    13f8:	mov    QWORD PTR [rsp+0x30],r14
    13fd:	mov    r14,rdi
    1400:	mov    QWORD PTR [rsp+0x10],0x0
    1409:	mov    QWORD PTR [rsp+0x18],0x0
    1412:	mov    QWORD PTR [rsp],rsi
    1416:	mov    r12,rsi
    1419:	mov    QWORD PTR [rsp+0x8],rdx
    141e:	mov    rsi,r12
    1421:	mov    rdi,r14
    1424:	call   1429 <botlish_fn_15+0x43>
			1425: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    1429:	test   rax,rax
    142c:	je     1481 <botlish_fn_15+0x9b>
    1432:	mov    QWORD PTR [rsp+0x8],rax
    1437:	mov    rsi,rax
    143a:	mov    QWORD PTR [rsp+0x10],rdx
    143f:	mov    rbx,rdx
    1442:	mov    rdi,r14
    1445:	call   144a <botlish_fn_15+0x64>
			1446: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    144a:	test   rax,rax
    144d:	je     1481 <botlish_fn_15+0x9b>
    1453:	mov    QWORD PTR [rsp+0x8],rax
    1458:	mov    rcx,rax
    145b:	mov    r8d,0x3
    1461:	mov    QWORD PTR [rsp+0x18],0x3
    146a:	mov    rdx,rbx
    146d:	mov    rsi,r12
    1470:	mov    rdi,r14
    1473:	call   1478 <botlish_fn_15+0x92>
			1474: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_record_rest<str, int, mutarray, int>
    1478:	test   rax,rax
    147b:	jne    149f <botlish_fn_15+0xb9>
    1481:	xor    rdx,rdx
    1484:	mov    rax,rdx
    1487:	mov    rbx,QWORD PTR [rsp+0x20]
    148c:	mov    r12,QWORD PTR [rsp+0x28]
    1491:	mov    r14,QWORD PTR [rsp+0x30]
    1496:	add    rsp,0x40
    149a:	mov    rsp,rbp
    149d:	pop    rbp
    149e:	ret
    149f:	mov    rbx,QWORD PTR [rsp+0x20]
    14a4:	mov    r12,QWORD PTR [rsp+0x28]
    14a9:	mov    r14,QWORD PTR [rsp+0x30]
    14ae:	add    rsp,0x40
    14b2:	mov    rsp,rbp
    14b5:	pop    rbp
    14b6:	ret

00000000000014b7 <botlish_entry_15: scan_record<str, int>>:
    14b7:	push   rbp
    14b8:	mov    rbp,rsp
    14bb:	ud2
    14bd:	add    BYTE PTR [rax],al
	...

00000000000014c0 <botlish_fn_16: scan_records<str, int, mutarray, int>>:
    14c0:	push   rbp
    14c1:	mov    rbp,rsp
    14c4:	sub    rsp,0x60
    14c8:	mov    QWORD PTR [rsp+0x30],rbx
    14cd:	mov    QWORD PTR [rsp+0x38],r12
    14d2:	mov    QWORD PTR [rsp+0x40],r13
    14d7:	mov    QWORD PTR [rsp+0x48],r14
    14dc:	mov    QWORD PTR [rsp+0x50],r15
    14e1:	mov    r13,rdi
    14e4:	mov    QWORD PTR [rsp+0x20],0x0
    14ed:	mov    QWORD PTR [rsp],rsi
    14f1:	mov    QWORD PTR [rsp+0x8],rdx
    14f6:	mov    rax,rdx
    14f9:	mov    QWORD PTR [rsp+0x10],rcx
    14fe:	mov    QWORD PTR [rsp+0x18],r8
    1503:	mov    rbx,rsi
    1506:	mov    r14,r8
    1509:	mov    r15,rcx
    150c:	mov    rdx,QWORD PTR [rbx+0x8]
    1510:	shl    rdx,1
    1513:	or     rdx,0x1
    1517:	mov    r12,rax
    151a:	and    rax,rdx
    151d:	test   rax,0x1
    1523:	jne    1549 <botlish_fn_16+0x89>
    1529:	mov    rsi,r12
    152c:	mov    rdi,r13
    152f:	call   1534 <botlish_fn_16+0x74>
			1530: R_X86_64_PLT32	rt_int_cmp-0x4
    1534:	mov    ecx,0x2
    1539:	test   rax,rax
    153c:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1670 <botlish_fn_16+0x1b0>
    1544:	jmp    1559 <botlish_fn_16+0x99>
    1549:	mov    ecx,0x2
    154e:	cmp    r12,rdx
    1551:	cmovge rcx,QWORD PTR [rip+0x117]        # 1670 <botlish_fn_16+0x1b0>
    1559:	cmp    rcx,0x6
    155d:	je     160b <botlish_fn_16+0x14b>
    1563:	mov    rdx,r12
    1566:	mov    rsi,rbx
    1569:	mov    rdi,r13
    156c:	call   1571 <botlish_fn_16+0xb1>
			156d: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    1571:	test   rax,rax
    1574:	je     1622 <botlish_fn_16+0x162>
    157a:	mov    QWORD PTR [rsp+0x8],rax
    157f:	mov    rcx,rax
    1582:	mov    QWORD PTR [rsp+0x20],rdx
    1587:	mov    rsi,r15
    158a:	mov    r12,rdx
    158d:	mov    rdx,r14
    1590:	mov    rdi,r13
    1593:	call   1598 <botlish_fn_16+0xd8>
			1594: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_append<mutarray, int, List[str]>
    1598:	test   rax,rax
    159b:	je     1622 <botlish_fn_16+0x162>
    15a1:	mov    QWORD PTR [rsp+0x8],rax
    15a6:	mov    r15,rax
    15a9:	mov    QWORD PTR [rsp+0x10],0x3
    15b2:	mov    rsi,r14
    15b5:	test   rsi,0x1
    15bc:	je     15d7 <botlish_fn_16+0x117>
    15c2:	mov    rsi,r14
    15c5:	mov    rax,rsi
    15c8:	add    rax,0x2
    15cc:	seto   cl
    15cf:	test   cl,cl
    15d1:	je     15e7 <botlish_fn_16+0x127>
    15d7:	mov    edx,0x3
    15dc:	mov    rsi,r14
    15df:	mov    rdi,r13
    15e2:	call   15e7 <botlish_fn_16+0x127>
			15e3: R_X86_64_PLT32	rt_int_add-0x4
    15e7:	mov    QWORD PTR [rsp],rbx
    15eb:	mov    rdx,r12
    15ee:	mov    QWORD PTR [rsp+0x8],rdx
    15f3:	mov    rcx,r15
    15f6:	mov    QWORD PTR [rsp+0x10],rcx
    15fb:	mov    QWORD PTR [rsp+0x18],rax
    1600:	mov    r14,rax
    1603:	mov    rax,rdx
    1606:	jmp    150c <botlish_fn_16+0x4c>
    160b:	mov    rdx,r14
    160e:	mov    rsi,r15
    1611:	mov    rdi,r13
    1614:	call   1619 <botlish_fn_16+0x159>
			1615: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    1619:	test   rax,rax
    161c:	jne    1647 <botlish_fn_16+0x187>
    1622:	xor    rax,rax
    1625:	mov    rbx,QWORD PTR [rsp+0x30]
    162a:	mov    r12,QWORD PTR [rsp+0x38]
    162f:	mov    r13,QWORD PTR [rsp+0x40]
    1634:	mov    r14,QWORD PTR [rsp+0x48]
    1639:	mov    r15,QWORD PTR [rsp+0x50]
    163e:	add    rsp,0x60
    1642:	mov    rsp,rbp
    1645:	pop    rbp
    1646:	ret
    1647:	mov    rbx,QWORD PTR [rsp+0x30]
    164c:	mov    r12,QWORD PTR [rsp+0x38]
    1651:	mov    r13,QWORD PTR [rsp+0x40]
    1656:	mov    r14,QWORD PTR [rsp+0x48]
    165b:	mov    r15,QWORD PTR [rsp+0x50]
    1660:	add    rsp,0x60
    1664:	mov    rsp,rbp
    1667:	pop    rbp
    1668:	ret
    1669:	add    BYTE PTR [rax],al
    166b:	add    BYTE PTR [rax],al
    166d:	add    BYTE PTR [rax],al
    166f:	add    BYTE PTR [rsi],al
    1671:	add    BYTE PTR [rax],al
    1673:	add    BYTE PTR [rax],al
    1675:	add    BYTE PTR [rax],al
	...

0000000000001678 <botlish_entry_16: scan_records<str, int, mutarray, int>>:
    1678:	push   rbp
    1679:	mov    rbp,rsp
    167c:	mov    rsi,QWORD PTR [rdx]
    167f:	mov    r9,QWORD PTR [rdx+0x8]
    1683:	mov    rcx,QWORD PTR [rdx+0x10]
    1687:	mov    r8,QWORD PTR [rdx+0x18]
    168b:	mov    rdx,r9
    168e:	call   1693 <botlish_entry_16+0x1b>
			168f: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    1693:	mov    rsp,rbp
    1696:	pop    rbp
    1697:	ret

0000000000001698 <botlish_fn_17: csv_parse<str>>:
    1698:	push   rbp
    1699:	mov    rbp,rsp
    169c:	sub    rsp,0x40
    16a0:	mov    QWORD PTR [rsp+0x20],rbx
    16a5:	mov    QWORD PTR [rsp+0x28],r12
    16aa:	mov    QWORD PTR [rsp+0x30],r13
    16af:	mov    rbx,rdi
    16b2:	mov    QWORD PTR [rsp+0x8],0x0
    16bb:	mov    QWORD PTR [rsp+0x10],0x0
    16c4:	mov    QWORD PTR [rsp+0x18],0x0
    16cd:	mov    QWORD PTR [rsp],rsi
    16d1:	mov    rax,QWORD PTR [rsi+0x8]
    16d5:	mov    r12,rsi
    16d8:	shl    rax,1
    16db:	or     rax,0x1
    16df:	sar    rax,1
    16e2:	test   rax,rax
    16e5:	je     1774 <botlish_fn_17+0xdc>
    16eb:	mov    edx,0x1
    16f0:	mov    QWORD PTR [rsp+0x8],0x1
    16f9:	mov    rsi,r12
    16fc:	mov    rdi,rbx
    16ff:	call   1704 <botlish_fn_17+0x6c>
			1700: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    1704:	test   rax,rax
    1707:	je     178b <botlish_fn_17+0xf3>
    170d:	mov    QWORD PTR [rsp+0x8],rax
    1712:	mov    rsi,rax
    1715:	mov    QWORD PTR [rsp+0x10],rdx
    171a:	mov    r13,rdx
    171d:	mov    rdi,rbx
    1720:	call   1725 <botlish_fn_17+0x8d>
			1721: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    1725:	test   rax,rax
    1728:	je     178b <botlish_fn_17+0xf3>
    172e:	mov    QWORD PTR [rsp+0x8],rax
    1733:	mov    rcx,rax
    1736:	mov    r8d,0x3
    173c:	mov    QWORD PTR [rsp+0x18],0x3
    1745:	mov    rdx,r13
    1748:	mov    rsi,r12
    174b:	mov    rdi,rbx
    174e:	call   1753 <botlish_fn_17+0xbb>
			174f: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    1753:	test   rax,rax
    1756:	je     178b <botlish_fn_17+0xf3>
    175c:	mov    rbx,QWORD PTR [rsp+0x20]
    1761:	mov    r12,QWORD PTR [rsp+0x28]
    1766:	mov    r13,QWORD PTR [rsp+0x30]
    176b:	add    rsp,0x40
    176f:	mov    rsp,rbp
    1772:	pop    rbp
    1773:	ret
    1774:	xor    rdx,rdx
    1777:	mov    rdi,rbx
    177a:	mov    rsi,rdx
    177d:	call   1782 <botlish_fn_17+0xea>
			177e: R_X86_64_PLT32	rt_list_new-0x4
    1782:	test   rax,rax
    1785:	jne    17a6 <botlish_fn_17+0x10e>
    178b:	xor    rax,rax
    178e:	mov    rbx,QWORD PTR [rsp+0x20]
    1793:	mov    r12,QWORD PTR [rsp+0x28]
    1798:	mov    r13,QWORD PTR [rsp+0x30]
    179d:	add    rsp,0x40
    17a1:	mov    rsp,rbp
    17a4:	pop    rbp
    17a5:	ret
    17a6:	mov    rbx,QWORD PTR [rsp+0x20]
    17ab:	mov    r12,QWORD PTR [rsp+0x28]
    17b0:	mov    r13,QWORD PTR [rsp+0x30]
    17b5:	add    rsp,0x40
    17b9:	mov    rsp,rbp
    17bc:	pop    rbp
    17bd:	ret

00000000000017be <botlish_entry_17: csv_parse<str>>:
    17be:	push   rbp
    17bf:	mov    rbp,rsp
    17c2:	mov    rsi,QWORD PTR [rdx]
    17c5:	call   17ca <botlish_entry_17+0xc>
			17c6: R_X86_64_PLT32	botlish_fn_17-0x4 ; csv_parse<str>
    17ca:	mov    rsp,rbp
    17cd:	pop    rbp
    17ce:	ret

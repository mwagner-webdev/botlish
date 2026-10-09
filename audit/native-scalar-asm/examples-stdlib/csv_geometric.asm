; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6849  (per function: 312 89 89 357 420 420 202 202 81 365 438 585 1141 352 783 215 480 318)
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
;   botlish_fn_10 / botlish_entry_10 -> peek<str, int>
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

0000000000000940 <botlish_fn_10: peek<str, int>>:
     940:	push   rbp
     941:	mov    rbp,rsp
     944:	sub    rsp,0x50
     948:	mov    QWORD PTR [rsp+0x20],rbx
     94d:	mov    QWORD PTR [rsp+0x28],r12
     952:	mov    QWORD PTR [rsp+0x30],r13
     957:	mov    QWORD PTR [rsp+0x38],r14
     95c:	mov    QWORD PTR [rsp+0x40],r15
     961:	mov    rbx,rdx
     964:	mov    r12,rcx
     967:	mov    r14,rdi
     96a:	mov    QWORD PTR [rsp],rsi
     96e:	mov    QWORD PTR [rsp+0x8],rdx
     973:	mov    rdx,QWORD PTR [rsi+0x8]
     977:	mov    r13,rsi
     97a:	shl    rdx,1
     97d:	mov    rax,rdx
     980:	or     rax,0x1
     984:	mov    rcx,rbx
     987:	and    rcx,rax
     98a:	test   rcx,0x1
     991:	jne    9bb <botlish_fn_10+0x7b>
     997:	or     rdx,0x1
     99b:	mov    rsi,rbx
     99e:	mov    rdi,r14
     9a1:	call   9a6 <botlish_fn_10+0x66>
			9a2: R_X86_64_PLT32	rt_int_cmp-0x4
     9a6:	mov    ecx,0x2
     9ab:	test   rax,rax
     9ae:	cmovge rcx,QWORD PTR [rip+0x122]        # ad8 <botlish_fn_10+0x198>
     9b6:	jmp    9cf <botlish_fn_10+0x8f>
     9bb:	or     rdx,0x1
     9bf:	mov    ecx,0x2
     9c4:	cmp    rbx,rdx
     9c7:	cmovge rcx,QWORD PTR [rip+0x109]        # ad8 <botlish_fn_10+0x198>
     9cf:	cmp    rcx,0x6
     9d3:	je     a93 <botlish_fn_10+0x153>
     9d9:	mov    QWORD PTR [rsp+0x10],0x3
     9e2:	test   rbx,0x1
     9e9:	je     a0c <botlish_fn_10+0xcc>
     9ef:	mov    rax,rbx
     9f2:	add    rax,0x2
     9f6:	seto   cl
     9f9:	test   cl,cl
     9fb:	jne    a0c <botlish_fn_10+0xcc>
     a01:	mov    rdi,r14
     a04:	mov    r15,rax
     a07:	jmp    a22 <botlish_fn_10+0xe2>
     a0c:	mov    edx,0x3
     a11:	mov    rsi,rbx
     a14:	mov    rdi,r14
     a17:	call   a1c <botlish_fn_10+0xdc>
			a18: R_X86_64_PLT32	rt_int_add-0x4
     a1c:	mov    r15,rax
     a1f:	mov    rdi,r14
     a22:	mov    rdi,r14
     a25:	mov    rcx,r15
     a28:	mov    rdx,rbx
     a2b:	mov    rsi,r13
     a2e:	call   a33 <botlish_fn_10+0xf3>
			a2f: R_X86_64_PLT32	rt_str_region_check-0x4
     a33:	test   rax,rax
     a36:	jne    a61 <botlish_fn_10+0x121>
     a3c:	xor    rax,rax
     a3f:	mov    rbx,QWORD PTR [rsp+0x20]
     a44:	mov    r12,QWORD PTR [rsp+0x28]
     a49:	mov    r13,QWORD PTR [rsp+0x30]
     a4e:	mov    r14,QWORD PTR [rsp+0x38]
     a53:	mov    r15,QWORD PTR [rsp+0x40]
     a58:	add    rsp,0x50
     a5c:	mov    rsp,rbp
     a5f:	pop    rbp
     a60:	ret
     a61:	mov    rcx,r12
     a64:	mov    QWORD PTR [rcx],rbx
     a67:	mov    rax,r15
     a6a:	mov    QWORD PTR [rcx+0x8],rax
     a6e:	mov    rax,r13
     a71:	mov    rbx,QWORD PTR [rsp+0x20]
     a76:	mov    r12,QWORD PTR [rsp+0x28]
     a7b:	mov    r13,QWORD PTR [rsp+0x30]
     a80:	mov    r14,QWORD PTR [rsp+0x38]
     a85:	mov    r15,QWORD PTR [rsp+0x40]
     a8a:	add    rsp,0x50
     a8e:	mov    rsp,rbp
     a91:	pop    rbp
     a92:	ret
     a93:	mov    rcx,r12
     a96:	mov    rdi,r14
     a99:	mov    rax,QWORD PTR [rdi+0x10]
     a9d:	mov    rax,QWORD PTR [rax+0x8]
     aa1:	mov    QWORD PTR [rcx],0x1
     aa8:	mov    QWORD PTR [rcx+0x8],0x1
     ab0:	mov    rbx,QWORD PTR [rsp+0x20]
     ab5:	mov    r12,QWORD PTR [rsp+0x28]
     aba:	mov    r13,QWORD PTR [rsp+0x30]
     abf:	mov    r14,QWORD PTR [rsp+0x38]
     ac4:	mov    r15,QWORD PTR [rsp+0x40]
     ac9:	add    rsp,0x50
     acd:	mov    rsp,rbp
     ad0:	pop    rbp
     ad1:	ret
     ad2:	add    BYTE PTR [rax],al
     ad4:	add    BYTE PTR [rax],al
     ad6:	add    BYTE PTR [rax],al
     ad8:	(bad)
     ad9:	add    BYTE PTR [rax],al
     adb:	add    BYTE PTR [rax],al
     add:	add    BYTE PTR [rax],al
	...

0000000000000ae0 <botlish_entry_10: peek<str, int>>:
     ae0:	push   rbp
     ae1:	mov    rbp,rsp
     ae4:	ud2

0000000000000ae6 <botlish_fn_11: scan_unquoted<str, int, int>>:
     ae6:	push   rbp
     ae7:	mov    rbp,rsp
     aea:	sub    rsp,0x80
     af1:	mov    QWORD PTR [rsp+0x50],rbx
     af6:	mov    QWORD PTR [rsp+0x58],r12
     afb:	mov    QWORD PTR [rsp+0x60],r13
     b00:	mov    QWORD PTR [rsp+0x68],r14
     b05:	mov    QWORD PTR [rsp+0x70],r15
     b0a:	mov    QWORD PTR [rsp+0x30],rdi
     b0f:	mov    QWORD PTR [rsp+0x18],0x0
     b18:	mov    QWORD PTR [rsp],rsi
     b1c:	mov    r15,rsi
     b1f:	mov    QWORD PTR [rsp+0x8],rdx
     b24:	mov    r14,rdx
     b27:	mov    QWORD PTR [rsp+0x10],rcx
     b2c:	lea    r13,[rsp+0x20]
     b31:	mov    QWORD PTR [rsp+0x38],rcx
     b36:	mov    rcx,r13
     b39:	mov    rdx,QWORD PTR [rsp+0x38]
     b3e:	mov    rsi,r15
     b41:	mov    rdi,QWORD PTR [rsp+0x30]
     b46:	call   b4b <botlish_fn_11+0x65>
			b47: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
     b4b:	mov    rsi,rax
     b4e:	mov    QWORD PTR [rsp+0x40],rax
     b53:	test   rax,rsi
     b56:	je     cb0 <botlish_fn_11+0x1ca>
     b5c:	mov    rbx,QWORD PTR [rsp+0x20]
     b61:	mov    r12,QWORD PTR [rsp+0x28]
     b66:	mov    rdi,QWORD PTR [rsp+0x30]
     b6b:	mov    rcx,QWORD PTR [rdi+0x10]
     b6f:	mov    r8,QWORD PTR [rcx+0x8]
     b73:	mov    rcx,r12
     b76:	mov    rdx,rbx
     b79:	mov    rsi,QWORD PTR [rsp+0x40]
     b7e:	call   b83 <botlish_fn_11+0x9d>
			b7f: R_X86_64_PLT32	rt_str_region_eq-0x4
     b83:	cmp    rax,0x6
     b87:	je     bc8 <botlish_fn_11+0xe2>
     b8d:	mov    rdi,QWORD PTR [rsp+0x30]
     b92:	mov    rax,QWORD PTR [rdi+0x10]
     b96:	mov    r8,QWORD PTR [rax+0x10]
     b9a:	mov    rcx,r12
     b9d:	mov    rdx,rbx
     ba0:	mov    rsi,QWORD PTR [rsp+0x40]
     ba5:	call   baa <botlish_fn_11+0xc4>
			ba6: R_X86_64_PLT32	rt_str_region_eq-0x4
     baa:	cmp    rax,0x6
     bae:	je     bbe <botlish_fn_11+0xd8>
     bb4:	mov    eax,0x2
     bb9:	jmp    bcd <botlish_fn_11+0xe7>
     bbe:	mov    eax,0x6
     bc3:	jmp    bcd <botlish_fn_11+0xe7>
     bc8:	mov    eax,0x6
     bcd:	cmp    rax,0x6
     bd1:	je     c12 <botlish_fn_11+0x12c>
     bd7:	mov    rdi,QWORD PTR [rsp+0x30]
     bdc:	mov    rax,QWORD PTR [rdi+0x10]
     be0:	mov    r8,QWORD PTR [rax+0x18]
     be4:	mov    rcx,r12
     be7:	mov    rdx,rbx
     bea:	mov    rsi,QWORD PTR [rsp+0x40]
     bef:	call   bf4 <botlish_fn_11+0x10e>
			bf0: R_X86_64_PLT32	rt_str_region_eq-0x4
     bf4:	cmp    rax,0x6
     bf8:	je     c08 <botlish_fn_11+0x122>
     bfe:	mov    eax,0x2
     c03:	jmp    c17 <botlish_fn_11+0x131>
     c08:	mov    eax,0x6
     c0d:	jmp    c17 <botlish_fn_11+0x131>
     c12:	mov    eax,0x6
     c17:	cmp    rax,0x6
     c1b:	je     c92 <botlish_fn_11+0x1ac>
     c21:	mov    QWORD PTR [rsp+0x18],0x3
     c2a:	mov    rsi,QWORD PTR [rsp+0x38]
     c2f:	test   rsi,0x1
     c36:	je     c5d <botlish_fn_11+0x177>
     c3c:	mov    rsi,QWORD PTR [rsp+0x38]
     c41:	mov    rax,rsi
     c44:	add    rax,0x2
     c48:	seto   sil
     c4c:	test   sil,sil
     c4f:	jne    c5d <botlish_fn_11+0x177>
     c55:	mov    rsi,r15
     c58:	jmp    c74 <botlish_fn_11+0x18e>
     c5d:	mov    edx,0x3
     c62:	mov    rsi,QWORD PTR [rsp+0x38]
     c67:	mov    rdi,QWORD PTR [rsp+0x30]
     c6c:	call   c71 <botlish_fn_11+0x18b>
			c6d: R_X86_64_PLT32	rt_int_add-0x4
     c71:	mov    rsi,r15
     c74:	mov    QWORD PTR [rsp],rsi
     c78:	mov    rdx,r14
     c7b:	mov    QWORD PTR [rsp+0x8],rdx
     c80:	mov    QWORD PTR [rsp+0x10],rax
     c85:	mov    r15,rsi
     c88:	mov    QWORD PTR [rsp+0x38],rax
     c8d:	jmp    b36 <botlish_fn_11+0x50>
     c92:	mov    rdx,r14
     c95:	mov    rsi,r15
     c98:	mov    rdi,QWORD PTR [rsp+0x30]
     c9d:	mov    rcx,QWORD PTR [rsp+0x38]
     ca2:	call   ca7 <botlish_fn_11+0x1c1>
			ca3: R_X86_64_PLT32	rt_substr-0x4
     ca7:	test   rax,rax
     caa:	jne    cdb <botlish_fn_11+0x1f5>
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
     cdb:	mov    rdx,QWORD PTR [rsp+0x38]
     ce0:	mov    rbx,QWORD PTR [rsp+0x50]
     ce5:	mov    r12,QWORD PTR [rsp+0x58]
     cea:	mov    r13,QWORD PTR [rsp+0x60]
     cef:	mov    r14,QWORD PTR [rsp+0x68]
     cf4:	mov    r15,QWORD PTR [rsp+0x70]
     cf9:	add    rsp,0x80
     d00:	mov    rsp,rbp
     d03:	pop    rbp
     d04:	ret

0000000000000d05 <botlish_entry_11: scan_unquoted<str, int, int>>:
     d05:	push   rbp
     d06:	mov    rbp,rsp
     d09:	ud2

0000000000000d0b <botlish_fn_12: scan_quoted<str, int, str>>:
     d0b:	push   rbp
     d0c:	mov    rbp,rsp
     d0f:	sub    rsp,0xd0
     d16:	mov    QWORD PTR [rsp+0xa0],rbx
     d1e:	mov    QWORD PTR [rsp+0xa8],r12
     d26:	mov    QWORD PTR [rsp+0xb0],r13
     d2e:	mov    QWORD PTR [rsp+0xb8],r14
     d36:	mov    QWORD PTR [rsp+0xc0],r15
     d3e:	mov    QWORD PTR [rsp+0x88],rdi
     d46:	mov    QWORD PTR [rsp+0x18],0x0
     d4f:	mov    QWORD PTR [rsp+0x20],0x0
     d58:	mov    QWORD PTR [rsp],rsi
     d5c:	mov    QWORD PTR [rsp+0x8],rdx
     d61:	mov    QWORD PTR [rsp+0x10],rcx
     d66:	mov    r13,rcx
     d69:	lea    r14,[rsp+0x68]
     d6e:	lea    rbx,[rsp+0x28]
     d73:	mov    r12,rsi
     d76:	mov    QWORD PTR [rsp+0x90],rdx
     d7e:	mov    rdx,QWORD PTR [rsp+0x90]
     d86:	mov    rsi,r12
     d89:	mov    rdi,QWORD PTR [rsp+0x88]
     d91:	call   d96 <botlish_fn_12+0x8b>
			d92: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     d96:	test   rax,rax
     d99:	je     10e2 <botlish_fn_12+0x3d7>
     d9f:	mov    QWORD PTR [rsp+0x18],rax
     da4:	mov    rsi,QWORD PTR [rax+0x8]
     da8:	mov    rcx,rax
     dab:	mov    rax,0xffffffffffffffff
     db2:	test   rsi,rsi
     db5:	jne    dc3 <botlish_fn_12+0xb8>
     dbb:	mov    r15,rcx
     dbe:	jmp    dee <botlish_fn_12+0xe3>
     dc3:	mov    r15,rcx
     dc6:	movzx  rdi,BYTE PTR [r15+0x18]
     dcb:	test   rdi,rdi
     dce:	jne    de9 <botlish_fn_12+0xde>
     dd4:	mov    rsi,r15
     dd7:	mov    rdi,QWORD PTR [rsp+0x88]
     ddf:	call   de4 <botlish_fn_12+0xd9>
			de0: R_X86_64_PLT32	rt_str_to_short-0x4
     de4:	jmp    dee <botlish_fn_12+0xe3>
     de9:	movzx  rax,BYTE PTR [r15+0x19]
     dee:	cmp    rax,0x22
     df2:	je     eb2 <botlish_fn_12+0x1a7>
     df8:	mov    QWORD PTR [rsp+0x20],0x3
     e01:	mov    rsi,QWORD PTR [rsp+0x90]
     e09:	test   rsi,0x1
     e10:	je     e30 <botlish_fn_12+0x125>
     e16:	mov    rax,rsi
     e19:	add    rax,0x2
     e1d:	seto   cl
     e20:	test   cl,cl
     e22:	jne    e30 <botlish_fn_12+0x125>
     e28:	mov    rsi,rax
     e2b:	jmp    e45 <botlish_fn_12+0x13a>
     e30:	mov    edx,0x3
     e35:	mov    rdi,QWORD PTR [rsp+0x88]
     e3d:	call   e42 <botlish_fn_12+0x137>
			e3e: R_X86_64_PLT32	rt_int_add-0x4
     e42:	mov    rsi,rax
     e45:	mov    QWORD PTR [rsp+0x8],rsi
     e4a:	mov    QWORD PTR [rsp+0x90],rsi
     e52:	mov    QWORD PTR [rsp+0x68],0x0
     e5b:	mov    QWORD PTR [rsp+0x70],r13
     e60:	mov    QWORD PTR [rsp+0x78],0x0
     e69:	mov    QWORD PTR [rsp+0x80],r15
     e71:	mov    esi,0x2
     e76:	mov    edx,0x4
     e7b:	mov    rcx,r14
     e7e:	mov    rdi,QWORD PTR [rsp+0x88]
     e86:	call   e8b <botlish_fn_12+0x180>
			e87: R_X86_64_PLT32	rt_construct-0x4
     e8b:	test   rax,rax
     e8e:	je     10e2 <botlish_fn_12+0x3d7>
     e94:	mov    QWORD PTR [rsp],r12
     e98:	mov    rsi,QWORD PTR [rsp+0x90]
     ea0:	mov    QWORD PTR [rsp+0x8],rsi
     ea5:	mov    QWORD PTR [rsp+0x10],rax
     eaa:	mov    r13,rax
     ead:	jmp    d7e <botlish_fn_12+0x73>
     eb2:	mov    QWORD PTR [rsp+0x18],0x3
     ebb:	mov    rsi,QWORD PTR [rsp+0x90]
     ec3:	test   rsi,0x1
     eca:	je     eea <botlish_fn_12+0x1df>
     ed0:	mov    rsi,QWORD PTR [rsp+0x90]
     ed8:	mov    rdx,rsi
     edb:	add    rdx,0x2
     edf:	seto   al
     ee2:	test   al,al
     ee4:	je     f07 <botlish_fn_12+0x1fc>
     eea:	mov    edx,0x3
     eef:	mov    rsi,QWORD PTR [rsp+0x90]
     ef7:	mov    rdi,QWORD PTR [rsp+0x88]
     eff:	call   f04 <botlish_fn_12+0x1f9>
			f00: R_X86_64_PLT32	rt_int_add-0x4
     f04:	mov    rdx,rax
     f07:	mov    QWORD PTR [rsp+0x18],rdx
     f0c:	mov    rcx,rbx
     f0f:	mov    rsi,r12
     f12:	mov    rdi,QWORD PTR [rsp+0x88]
     f1a:	call   f1f <botlish_fn_12+0x214>
			f1b: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
     f1f:	test   rax,rax
     f22:	mov    rsi,rax
     f25:	je     10e2 <botlish_fn_12+0x3d7>
     f2b:	mov    rdx,QWORD PTR [rsp+0x28]
     f30:	mov    rcx,QWORD PTR [rsp+0x30]
     f35:	mov    rdi,QWORD PTR [rsp+0x88]
     f3d:	mov    rax,QWORD PTR [rdi+0x10]
     f41:	mov    r8,QWORD PTR [rax+0x20]
     f45:	call   f4a <botlish_fn_12+0x23f>
			f46: R_X86_64_PLT32	rt_str_region_eq-0x4
     f4a:	cmp    rax,0x6
     f4e:	je     1020 <botlish_fn_12+0x315>
     f54:	xor    rsi,rsi
     f57:	lea    rcx,[rsp+0x58]
     f5c:	mov    QWORD PTR [rsp+0x58],0x0
     f65:	mov    QWORD PTR [rsp+0x60],r13
     f6a:	mov    edx,0x2
     f6f:	mov    rdi,QWORD PTR [rsp+0x88]
     f77:	call   f7c <botlish_fn_12+0x271>
			f78: R_X86_64_PLT32	rt_construct-0x4
     f7c:	test   rax,rax
     f7f:	je     10e2 <botlish_fn_12+0x3d7>
     f85:	mov    QWORD PTR [rsp],rax
     f89:	mov    rbx,rax
     f8c:	mov    QWORD PTR [rsp+0x10],0x3
     f95:	mov    rsi,QWORD PTR [rsp+0x90]
     f9d:	test   rsi,0x1
     fa4:	je     fcc <botlish_fn_12+0x2c1>
     faa:	mov    rsi,QWORD PTR [rsp+0x90]
     fb2:	mov    rdx,rsi
     fb5:	add    rdx,0x2
     fb9:	seto   al
     fbc:	test   al,al
     fbe:	jne    fcc <botlish_fn_12+0x2c1>
     fc4:	mov    rax,rbx
     fc7:	jmp    fec <botlish_fn_12+0x2e1>
     fcc:	mov    edx,0x3
     fd1:	mov    rsi,QWORD PTR [rsp+0x90]
     fd9:	mov    rdi,QWORD PTR [rsp+0x88]
     fe1:	call   fe6 <botlish_fn_12+0x2db>
			fe2: R_X86_64_PLT32	rt_int_add-0x4
     fe6:	mov    rdx,rax
     fe9:	mov    rax,rbx
     fec:	mov    rbx,QWORD PTR [rsp+0xa0]
     ff4:	mov    r12,QWORD PTR [rsp+0xa8]
     ffc:	mov    r13,QWORD PTR [rsp+0xb0]
    1004:	mov    r14,QWORD PTR [rsp+0xb8]
    100c:	mov    r15,QWORD PTR [rsp+0xc0]
    1014:	add    rsp,0xd0
    101b:	mov    rsp,rbp
    101e:	pop    rbp
    101f:	ret
    1020:	mov    QWORD PTR [rsp+0x18],0x5
    1029:	mov    rsi,QWORD PTR [rsp+0x90]
    1031:	test   rsi,0x1
    1038:	je     106a <botlish_fn_12+0x35f>
    103e:	mov    rsi,QWORD PTR [rsp+0x90]
    1046:	mov    rdi,rsi
    1049:	add    rdi,0x4
    104d:	seto   r9b
    1051:	test   r9b,r9b
    1054:	jne    106a <botlish_fn_12+0x35f>
    105a:	mov    rsi,rdi
    105d:	mov    QWORD PTR [rsp+0x90],rdi
    1065:	jmp    108f <botlish_fn_12+0x384>
    106a:	mov    edx,0x5
    106f:	mov    rsi,QWORD PTR [rsp+0x90]
    1077:	mov    rdi,QWORD PTR [rsp+0x88]
    107f:	call   1084 <botlish_fn_12+0x379>
			1080: R_X86_64_PLT32	rt_int_add-0x4
    1084:	mov    rsi,rax
    1087:	mov    QWORD PTR [rsp+0x90],rax
    108f:	mov    QWORD PTR [rsp+0x8],rsi
    1094:	mov    rdi,QWORD PTR [rsp+0x88]
    109c:	mov    rax,QWORD PTR [rdi+0x10]
    10a0:	mov    rax,QWORD PTR [rax+0x20]
    10a4:	mov    QWORD PTR [rsp+0x18],rax
    10a9:	lea    rcx,[rsp+0x38]
    10ae:	mov    QWORD PTR [rsp+0x38],0x0
    10b7:	mov    QWORD PTR [rsp+0x40],r13
    10bc:	mov    QWORD PTR [rsp+0x48],0x0
    10c5:	mov    QWORD PTR [rsp+0x50],rax
    10ca:	mov    esi,0x2
    10cf:	mov    edx,0x4
    10d4:	call   10d9 <botlish_fn_12+0x3ce>
			10d5: R_X86_64_PLT32	rt_construct-0x4
    10d9:	test   rax,rax
    10dc:	jne    111c <botlish_fn_12+0x411>
    10e2:	xor    rdx,rdx
    10e5:	mov    rax,rdx
    10e8:	mov    rbx,QWORD PTR [rsp+0xa0]
    10f0:	mov    r12,QWORD PTR [rsp+0xa8]
    10f8:	mov    r13,QWORD PTR [rsp+0xb0]
    1100:	mov    r14,QWORD PTR [rsp+0xb8]
    1108:	mov    r15,QWORD PTR [rsp+0xc0]
    1110:	add    rsp,0xd0
    1117:	mov    rsp,rbp
    111a:	pop    rbp
    111b:	ret
    111c:	mov    QWORD PTR [rsp],r12
    1120:	mov    rsi,QWORD PTR [rsp+0x90]
    1128:	mov    QWORD PTR [rsp+0x8],rsi
    112d:	mov    QWORD PTR [rsp+0x10],rax
    1132:	mov    r13,rax
    1135:	jmp    d7e <botlish_fn_12+0x73>

000000000000113a <botlish_entry_12: scan_quoted<str, int, str>>:
    113a:	push   rbp
    113b:	mov    rbp,rsp
    113e:	ud2

0000000000001140 <botlish_fn_13: scan_field<str, int>>:
    1140:	push   rbp
    1141:	mov    rbp,rsp
    1144:	sub    rsp,0x50
    1148:	mov    QWORD PTR [rsp+0x30],rbx
    114d:	mov    QWORD PTR [rsp+0x38],r12
    1152:	mov    QWORD PTR [rsp+0x40],r13
    1157:	mov    r12,rdi
    115a:	mov    r13,rdx
    115d:	mov    QWORD PTR [rsp+0x10],0x0
    1166:	mov    QWORD PTR [rsp],rsi
    116a:	mov    rbx,rsi
    116d:	mov    QWORD PTR [rsp+0x8],rdx
    1172:	lea    rcx,[rsp+0x18]
    1177:	mov    rdx,r13
    117a:	mov    rsi,rbx
    117d:	mov    rdi,r12
    1180:	call   1185 <botlish_fn_13+0x45>
			1181: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1185:	test   rax,rax
    1188:	mov    rsi,rax
    118b:	je     1256 <botlish_fn_13+0x116>
    1191:	mov    rdx,QWORD PTR [rsp+0x18]
    1196:	mov    rcx,QWORD PTR [rsp+0x20]
    119b:	mov    rdi,r12
    119e:	mov    rax,QWORD PTR [rdi+0x10]
    11a2:	mov    r8,QWORD PTR [rax+0x20]
    11a6:	call   11ab <botlish_fn_13+0x6b>
			11a7: R_X86_64_PLT32	rt_str_region_eq-0x4
    11ab:	cmp    rax,0x6
    11af:	je     11e7 <botlish_fn_13+0xa7>
    11b5:	mov    rcx,r13
    11b8:	mov    rsi,rbx
    11bb:	mov    rdi,r12
    11be:	mov    rdx,rcx
    11c1:	call   11c6 <botlish_fn_13+0x86>
			11c2: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_unquoted<str, int, int>
    11c6:	test   rax,rax
    11c9:	je     1256 <botlish_fn_13+0x116>
    11cf:	mov    rbx,QWORD PTR [rsp+0x30]
    11d4:	mov    r12,QWORD PTR [rsp+0x38]
    11d9:	mov    r13,QWORD PTR [rsp+0x40]
    11de:	add    rsp,0x50
    11e2:	mov    rsp,rbp
    11e5:	pop    rbp
    11e6:	ret
    11e7:	mov    rcx,r13
    11ea:	mov    QWORD PTR [rsp+0x10],0x3
    11f3:	test   rcx,0x1
    11fa:	jne    1208 <botlish_fn_13+0xc8>
    1200:	mov    r13,rcx
    1203:	jmp    121d <botlish_fn_13+0xdd>
    1208:	mov    rdx,rcx
    120b:	add    rdx,0x2
    120f:	mov    r13,rcx
    1212:	seto   al
    1215:	test   al,al
    1217:	je     1230 <botlish_fn_13+0xf0>
    121d:	mov    edx,0x3
    1222:	mov    rsi,r13
    1225:	mov    rdi,r12
    1228:	call   122d <botlish_fn_13+0xed>
			1229: R_X86_64_PLT32	rt_int_add-0x4
    122d:	mov    rdx,rax
    1230:	mov    QWORD PTR [rsp+0x8],rdx
    1235:	mov    rdi,r12
    1238:	mov    rax,QWORD PTR [rdi+0x10]
    123c:	mov    rcx,QWORD PTR [rax+0x8]
    1240:	mov    QWORD PTR [rsp+0x10],rcx
    1245:	mov    rsi,rbx
    1248:	call   124d <botlish_fn_13+0x10d>
			1249: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_quoted<str, int, str>
    124d:	test   rax,rax
    1250:	jne    1274 <botlish_fn_13+0x134>
    1256:	xor    rdx,rdx
    1259:	mov    rax,rdx
    125c:	mov    rbx,QWORD PTR [rsp+0x30]
    1261:	mov    r12,QWORD PTR [rsp+0x38]
    1266:	mov    r13,QWORD PTR [rsp+0x40]
    126b:	add    rsp,0x50
    126f:	mov    rsp,rbp
    1272:	pop    rbp
    1273:	ret
    1274:	mov    rbx,QWORD PTR [rsp+0x30]
    1279:	mov    r12,QWORD PTR [rsp+0x38]
    127e:	mov    r13,QWORD PTR [rsp+0x40]
    1283:	add    rsp,0x50
    1287:	mov    rsp,rbp
    128a:	pop    rbp
    128b:	ret

000000000000128c <botlish_entry_13: scan_field<str, int>>:
    128c:	push   rbp
    128d:	mov    rbp,rsp
    1290:	ud2

0000000000001292 <botlish_fn_14: scan_record_rest<str, int, mutarray, int>>:
    1292:	push   rbp
    1293:	mov    rbp,rsp
    1296:	sub    rsp,0x90
    129d:	mov    QWORD PTR [rsp+0x60],rbx
    12a2:	mov    QWORD PTR [rsp+0x68],r12
    12a7:	mov    QWORD PTR [rsp+0x70],r13
    12ac:	mov    QWORD PTR [rsp+0x78],r14
    12b1:	mov    QWORD PTR [rsp+0x80],r15
    12b9:	mov    r15,rdi
    12bc:	mov    QWORD PTR [rsp+0x20],0x0
    12c5:	mov    QWORD PTR [rsp],rsi
    12c9:	mov    QWORD PTR [rsp+0x8],rdx
    12ce:	mov    QWORD PTR [rsp+0x10],rcx
    12d3:	mov    QWORD PTR [rsp+0x18],r8
    12d8:	lea    r12,[rsp+0x28]
    12dd:	mov    rbx,rsi
    12e0:	mov    QWORD PTR [rsp+0x38],rdx
    12e5:	mov    QWORD PTR [rsp+0x40],rcx
    12ea:	mov    QWORD PTR [rsp+0x48],r8
    12ef:	mov    rcx,r12
    12f2:	mov    rdx,QWORD PTR [rsp+0x38]
    12f7:	mov    rsi,rbx
    12fa:	mov    rdi,r15
    12fd:	call   1302 <botlish_fn_14+0x70>
			12fe: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1302:	test   rax,rax
    1305:	mov    QWORD PTR [rsp+0x50],rax
    130a:	je     14ce <botlish_fn_14+0x23c>
    1310:	mov    r14,QWORD PTR [rsp+0x28]
    1315:	mov    r13,QWORD PTR [rsp+0x30]
    131a:	mov    rdi,r15
    131d:	mov    rcx,QWORD PTR [rdi+0x10]
    1321:	mov    r8,QWORD PTR [rcx+0x10]
    1325:	mov    rcx,r13
    1328:	mov    rdx,r14
    132b:	mov    rsi,QWORD PTR [rsp+0x50]
    1330:	call   1335 <botlish_fn_14+0xa3>
			1331: R_X86_64_PLT32	rt_str_region_eq-0x4
    1335:	cmp    rax,0x6
    1339:	je     1447 <botlish_fn_14+0x1b5>
    133f:	mov    rdi,r15
    1342:	mov    rax,QWORD PTR [rdi+0x10]
    1346:	mov    r8,QWORD PTR [rax+0x18]
    134a:	mov    rcx,r13
    134d:	mov    rdx,r14
    1350:	mov    rsi,QWORD PTR [rsp+0x50]
    1355:	call   135a <botlish_fn_14+0xc8>
			1356: R_X86_64_PLT32	rt_str_region_eq-0x4
    135a:	cmp    rax,0x6
    135e:	je     13ac <botlish_fn_14+0x11a>
    1364:	mov    rdx,QWORD PTR [rsp+0x48]
    1369:	mov    rsi,QWORD PTR [rsp+0x40]
    136e:	mov    rdi,r15
    1371:	call   1376 <botlish_fn_14+0xe4>
			1372: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    1376:	test   rax,rax
    1379:	je     14ce <botlish_fn_14+0x23c>
    137f:	mov    rdx,QWORD PTR [rsp+0x38]
    1384:	mov    rbx,QWORD PTR [rsp+0x60]
    1389:	mov    r12,QWORD PTR [rsp+0x68]
    138e:	mov    r13,QWORD PTR [rsp+0x70]
    1393:	mov    r14,QWORD PTR [rsp+0x78]
    1398:	mov    r15,QWORD PTR [rsp+0x80]
    13a0:	add    rsp,0x90
    13a7:	mov    rsp,rbp
    13aa:	pop    rbp
    13ab:	ret
    13ac:	mov    rdx,QWORD PTR [rsp+0x48]
    13b1:	mov    rsi,QWORD PTR [rsp+0x40]
    13b6:	mov    rdi,r15
    13b9:	call   13be <botlish_fn_14+0x12c>
			13ba: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    13be:	test   rax,rax
    13c1:	je     14ce <botlish_fn_14+0x23c>
    13c7:	mov    QWORD PTR [rsp],rax
    13cb:	mov    rbx,rax
    13ce:	mov    QWORD PTR [rsp+0x10],0x3
    13d7:	mov    rdx,QWORD PTR [rsp+0x38]
    13dc:	test   rdx,0x1
    13e3:	je     1407 <botlish_fn_14+0x175>
    13e9:	mov    rdx,QWORD PTR [rsp+0x38]
    13ee:	add    rdx,0x2
    13f2:	seto   sil
    13f6:	test   sil,sil
    13f9:	jne    1407 <botlish_fn_14+0x175>
    13ff:	mov    rax,rbx
    1402:	jmp    141f <botlish_fn_14+0x18d>
    1407:	mov    edx,0x3
    140c:	mov    rsi,QWORD PTR [rsp+0x38]
    1411:	mov    rdi,r15
    1414:	call   1419 <botlish_fn_14+0x187>
			1415: R_X86_64_PLT32	rt_int_add-0x4
    1419:	mov    rdx,rax
    141c:	mov    rax,rbx
    141f:	mov    rbx,QWORD PTR [rsp+0x60]
    1424:	mov    r12,QWORD PTR [rsp+0x68]
    1429:	mov    r13,QWORD PTR [rsp+0x70]
    142e:	mov    r14,QWORD PTR [rsp+0x78]
    1433:	mov    r15,QWORD PTR [rsp+0x80]
    143b:	add    rsp,0x90
    1442:	mov    rsp,rbp
    1445:	pop    rbp
    1446:	ret
    1447:	mov    rsi,QWORD PTR [rsp+0x38]
    144c:	mov    edx,0x3
    1451:	mov    r13,rdx
    1454:	mov    QWORD PTR [rsp+0x20],0x3
    145d:	test   rsi,0x1
    1464:	je     147c <botlish_fn_14+0x1ea>
    146a:	mov    rdx,rsi
    146d:	add    rdx,0x2
    1471:	seto   al
    1474:	test   al,al
    1476:	je     148a <botlish_fn_14+0x1f8>
    147c:	mov    rdx,r13
    147f:	mov    rdi,r15
    1482:	call   1487 <botlish_fn_14+0x1f5>
			1483: R_X86_64_PLT32	rt_int_add-0x4
    1487:	mov    rdx,rax
    148a:	mov    QWORD PTR [rsp+0x8],rdx
    148f:	mov    rsi,rbx
    1492:	mov    rdi,r15
    1495:	call   149a <botlish_fn_14+0x208>
			1496: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    149a:	test   rax,rax
    149d:	je     14ce <botlish_fn_14+0x23c>
    14a3:	mov    QWORD PTR [rsp+0x8],rax
    14a8:	mov    rcx,rax
    14ab:	mov    QWORD PTR [rsp+0x20],rdx
    14b0:	mov    rsi,QWORD PTR [rsp+0x40]
    14b5:	mov    r14,rdx
    14b8:	mov    rdx,QWORD PTR [rsp+0x48]
    14bd:	mov    rdi,r15
    14c0:	call   14c5 <botlish_fn_14+0x233>
			14c1: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<mutarray, int, str>
    14c5:	test   rax,rax
    14c8:	jne    14fc <botlish_fn_14+0x26a>
    14ce:	xor    rdx,rdx
    14d1:	mov    rax,rdx
    14d4:	mov    rbx,QWORD PTR [rsp+0x60]
    14d9:	mov    r12,QWORD PTR [rsp+0x68]
    14de:	mov    r13,QWORD PTR [rsp+0x70]
    14e3:	mov    r14,QWORD PTR [rsp+0x78]
    14e8:	mov    r15,QWORD PTR [rsp+0x80]
    14f0:	add    rsp,0x90
    14f7:	mov    rsp,rbp
    14fa:	pop    rbp
    14fb:	ret
    14fc:	mov    QWORD PTR [rsp+0x8],rax
    1501:	mov    QWORD PTR [rsp+0x38],rax
    1506:	mov    QWORD PTR [rsp+0x10],0x3
    150f:	mov    rdx,QWORD PTR [rsp+0x48]
    1514:	test   rdx,0x1
    151b:	jne    152e <botlish_fn_14+0x29c>
    1521:	mov    rdx,r13
    1524:	mov    rsi,QWORD PTR [rsp+0x48]
    1529:	jmp    154d <botlish_fn_14+0x2bb>
    152e:	mov    rdx,QWORD PTR [rsp+0x48]
    1533:	mov    rax,rdx
    1536:	add    rax,0x2
    153a:	seto   cl
    153d:	test   cl,cl
    153f:	je     1555 <botlish_fn_14+0x2c3>
    1545:	mov    rdx,r13
    1548:	mov    rsi,QWORD PTR [rsp+0x48]
    154d:	mov    rdi,r15
    1550:	call   1555 <botlish_fn_14+0x2c3>
			1551: R_X86_64_PLT32	rt_int_add-0x4
    1555:	mov    QWORD PTR [rsp],rbx
    1559:	mov    rdx,r14
    155c:	mov    QWORD PTR [rsp+0x8],rdx
    1561:	mov    rcx,QWORD PTR [rsp+0x38]
    1566:	mov    QWORD PTR [rsp+0x10],rcx
    156b:	mov    QWORD PTR [rsp+0x18],rax
    1570:	mov    QWORD PTR [rsp+0x38],rdx
    1575:	mov    QWORD PTR [rsp+0x40],rcx
    157a:	mov    QWORD PTR [rsp+0x48],rax
    157f:	jmp    12ef <botlish_fn_14+0x5d>

0000000000001584 <botlish_entry_14: scan_record_rest<str, int, mutarray, int>>:
    1584:	push   rbp
    1585:	mov    rbp,rsp
    1588:	ud2

000000000000158a <botlish_fn_15: scan_record<str, int>>:
    158a:	push   rbp
    158b:	mov    rbp,rsp
    158e:	sub    rsp,0x40
    1592:	mov    QWORD PTR [rsp+0x20],rbx
    1597:	mov    QWORD PTR [rsp+0x28],r12
    159c:	mov    QWORD PTR [rsp+0x30],r14
    15a1:	mov    r14,rdi
    15a4:	mov    QWORD PTR [rsp+0x10],0x0
    15ad:	mov    QWORD PTR [rsp+0x18],0x0
    15b6:	mov    QWORD PTR [rsp],rsi
    15ba:	mov    r12,rsi
    15bd:	mov    QWORD PTR [rsp+0x8],rdx
    15c2:	mov    rsi,r12
    15c5:	mov    rdi,r14
    15c8:	call   15cd <botlish_fn_15+0x43>
			15c9: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    15cd:	test   rax,rax
    15d0:	je     1625 <botlish_fn_15+0x9b>
    15d6:	mov    QWORD PTR [rsp+0x8],rax
    15db:	mov    rsi,rax
    15de:	mov    QWORD PTR [rsp+0x10],rdx
    15e3:	mov    rbx,rdx
    15e6:	mov    rdi,r14
    15e9:	call   15ee <botlish_fn_15+0x64>
			15ea: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    15ee:	test   rax,rax
    15f1:	je     1625 <botlish_fn_15+0x9b>
    15f7:	mov    QWORD PTR [rsp+0x8],rax
    15fc:	mov    rcx,rax
    15ff:	mov    r8d,0x3
    1605:	mov    QWORD PTR [rsp+0x18],0x3
    160e:	mov    rdx,rbx
    1611:	mov    rsi,r12
    1614:	mov    rdi,r14
    1617:	call   161c <botlish_fn_15+0x92>
			1618: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_record_rest<str, int, mutarray, int>
    161c:	test   rax,rax
    161f:	jne    1643 <botlish_fn_15+0xb9>
    1625:	xor    rdx,rdx
    1628:	mov    rax,rdx
    162b:	mov    rbx,QWORD PTR [rsp+0x20]
    1630:	mov    r12,QWORD PTR [rsp+0x28]
    1635:	mov    r14,QWORD PTR [rsp+0x30]
    163a:	add    rsp,0x40
    163e:	mov    rsp,rbp
    1641:	pop    rbp
    1642:	ret
    1643:	mov    rbx,QWORD PTR [rsp+0x20]
    1648:	mov    r12,QWORD PTR [rsp+0x28]
    164d:	mov    r14,QWORD PTR [rsp+0x30]
    1652:	add    rsp,0x40
    1656:	mov    rsp,rbp
    1659:	pop    rbp
    165a:	ret

000000000000165b <botlish_entry_15: scan_record<str, int>>:
    165b:	push   rbp
    165c:	mov    rbp,rsp
    165f:	ud2
    1661:	add    BYTE PTR [rax],al
    1663:	add    BYTE PTR [rax],al
    1665:	add    BYTE PTR [rax],al
	...

0000000000001668 <botlish_fn_16: scan_records<str, int, mutarray, int>>:
    1668:	push   rbp
    1669:	mov    rbp,rsp
    166c:	sub    rsp,0x60
    1670:	mov    QWORD PTR [rsp+0x30],rbx
    1675:	mov    QWORD PTR [rsp+0x38],r12
    167a:	mov    QWORD PTR [rsp+0x40],r13
    167f:	mov    QWORD PTR [rsp+0x48],r14
    1684:	mov    QWORD PTR [rsp+0x50],r15
    1689:	mov    r13,rdi
    168c:	mov    QWORD PTR [rsp+0x20],0x0
    1695:	mov    QWORD PTR [rsp],rsi
    1699:	mov    QWORD PTR [rsp+0x8],rdx
    169e:	mov    rax,rdx
    16a1:	mov    QWORD PTR [rsp+0x10],rcx
    16a6:	mov    QWORD PTR [rsp+0x18],r8
    16ab:	mov    rbx,rsi
    16ae:	mov    r14,r8
    16b1:	mov    r15,rcx
    16b4:	mov    rdx,QWORD PTR [rbx+0x8]
    16b8:	shl    rdx,1
    16bb:	or     rdx,0x1
    16bf:	mov    r12,rax
    16c2:	and    rax,rdx
    16c5:	test   rax,0x1
    16cb:	jne    16f1 <botlish_fn_16+0x89>
    16d1:	mov    rsi,r12
    16d4:	mov    rdi,r13
    16d7:	call   16dc <botlish_fn_16+0x74>
			16d8: R_X86_64_PLT32	rt_int_cmp-0x4
    16dc:	mov    ecx,0x2
    16e1:	test   rax,rax
    16e4:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1818 <botlish_fn_16+0x1b0>
    16ec:	jmp    1701 <botlish_fn_16+0x99>
    16f1:	mov    ecx,0x2
    16f6:	cmp    r12,rdx
    16f9:	cmovge rcx,QWORD PTR [rip+0x117]        # 1818 <botlish_fn_16+0x1b0>
    1701:	cmp    rcx,0x6
    1705:	je     17b3 <botlish_fn_16+0x14b>
    170b:	mov    rdx,r12
    170e:	mov    rsi,rbx
    1711:	mov    rdi,r13
    1714:	call   1719 <botlish_fn_16+0xb1>
			1715: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    1719:	test   rax,rax
    171c:	je     17ca <botlish_fn_16+0x162>
    1722:	mov    QWORD PTR [rsp+0x8],rax
    1727:	mov    rcx,rax
    172a:	mov    QWORD PTR [rsp+0x20],rdx
    172f:	mov    rsi,r15
    1732:	mov    r12,rdx
    1735:	mov    rdx,r14
    1738:	mov    rdi,r13
    173b:	call   1740 <botlish_fn_16+0xd8>
			173c: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_append<mutarray, int, List[str]>
    1740:	test   rax,rax
    1743:	je     17ca <botlish_fn_16+0x162>
    1749:	mov    QWORD PTR [rsp+0x8],rax
    174e:	mov    r15,rax
    1751:	mov    QWORD PTR [rsp+0x10],0x3
    175a:	mov    rsi,r14
    175d:	test   rsi,0x1
    1764:	je     177f <botlish_fn_16+0x117>
    176a:	mov    rsi,r14
    176d:	mov    rax,rsi
    1770:	add    rax,0x2
    1774:	seto   cl
    1777:	test   cl,cl
    1779:	je     178f <botlish_fn_16+0x127>
    177f:	mov    edx,0x3
    1784:	mov    rsi,r14
    1787:	mov    rdi,r13
    178a:	call   178f <botlish_fn_16+0x127>
			178b: R_X86_64_PLT32	rt_int_add-0x4
    178f:	mov    QWORD PTR [rsp],rbx
    1793:	mov    rdx,r12
    1796:	mov    QWORD PTR [rsp+0x8],rdx
    179b:	mov    rcx,r15
    179e:	mov    QWORD PTR [rsp+0x10],rcx
    17a3:	mov    QWORD PTR [rsp+0x18],rax
    17a8:	mov    r14,rax
    17ab:	mov    rax,rdx
    17ae:	jmp    16b4 <botlish_fn_16+0x4c>
    17b3:	mov    rdx,r14
    17b6:	mov    rsi,r15
    17b9:	mov    rdi,r13
    17bc:	call   17c1 <botlish_fn_16+0x159>
			17bd: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    17c1:	test   rax,rax
    17c4:	jne    17ef <botlish_fn_16+0x187>
    17ca:	xor    rax,rax
    17cd:	mov    rbx,QWORD PTR [rsp+0x30]
    17d2:	mov    r12,QWORD PTR [rsp+0x38]
    17d7:	mov    r13,QWORD PTR [rsp+0x40]
    17dc:	mov    r14,QWORD PTR [rsp+0x48]
    17e1:	mov    r15,QWORD PTR [rsp+0x50]
    17e6:	add    rsp,0x60
    17ea:	mov    rsp,rbp
    17ed:	pop    rbp
    17ee:	ret
    17ef:	mov    rbx,QWORD PTR [rsp+0x30]
    17f4:	mov    r12,QWORD PTR [rsp+0x38]
    17f9:	mov    r13,QWORD PTR [rsp+0x40]
    17fe:	mov    r14,QWORD PTR [rsp+0x48]
    1803:	mov    r15,QWORD PTR [rsp+0x50]
    1808:	add    rsp,0x60
    180c:	mov    rsp,rbp
    180f:	pop    rbp
    1810:	ret
    1811:	add    BYTE PTR [rax],al
    1813:	add    BYTE PTR [rax],al
    1815:	add    BYTE PTR [rax],al
    1817:	add    BYTE PTR [rsi],al
    1819:	add    BYTE PTR [rax],al
    181b:	add    BYTE PTR [rax],al
    181d:	add    BYTE PTR [rax],al
	...

0000000000001820 <botlish_entry_16: scan_records<str, int, mutarray, int>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	mov    rsi,QWORD PTR [rdx]
    1827:	mov    r9,QWORD PTR [rdx+0x8]
    182b:	mov    rcx,QWORD PTR [rdx+0x10]
    182f:	mov    r8,QWORD PTR [rdx+0x18]
    1833:	mov    rdx,r9
    1836:	call   183b <botlish_entry_16+0x1b>
			1837: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    183b:	mov    rsp,rbp
    183e:	pop    rbp
    183f:	ret

0000000000001840 <botlish_fn_17: csv_parse<str>>:
    1840:	push   rbp
    1841:	mov    rbp,rsp
    1844:	sub    rsp,0x40
    1848:	mov    QWORD PTR [rsp+0x20],rbx
    184d:	mov    QWORD PTR [rsp+0x28],r12
    1852:	mov    QWORD PTR [rsp+0x30],r13
    1857:	mov    rbx,rdi
    185a:	mov    QWORD PTR [rsp+0x8],0x0
    1863:	mov    QWORD PTR [rsp+0x10],0x0
    186c:	mov    QWORD PTR [rsp+0x18],0x0
    1875:	mov    QWORD PTR [rsp],rsi
    1879:	mov    rax,QWORD PTR [rsi+0x8]
    187d:	mov    r12,rsi
    1880:	shl    rax,1
    1883:	or     rax,0x1
    1887:	sar    rax,1
    188a:	test   rax,rax
    188d:	je     191c <botlish_fn_17+0xdc>
    1893:	mov    edx,0x1
    1898:	mov    QWORD PTR [rsp+0x8],0x1
    18a1:	mov    rsi,r12
    18a4:	mov    rdi,rbx
    18a7:	call   18ac <botlish_fn_17+0x6c>
			18a8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    18ac:	test   rax,rax
    18af:	je     1933 <botlish_fn_17+0xf3>
    18b5:	mov    QWORD PTR [rsp+0x8],rax
    18ba:	mov    rsi,rax
    18bd:	mov    QWORD PTR [rsp+0x10],rdx
    18c2:	mov    r13,rdx
    18c5:	mov    rdi,rbx
    18c8:	call   18cd <botlish_fn_17+0x8d>
			18c9: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    18cd:	test   rax,rax
    18d0:	je     1933 <botlish_fn_17+0xf3>
    18d6:	mov    QWORD PTR [rsp+0x8],rax
    18db:	mov    rcx,rax
    18de:	mov    r8d,0x3
    18e4:	mov    QWORD PTR [rsp+0x18],0x3
    18ed:	mov    rdx,r13
    18f0:	mov    rsi,r12
    18f3:	mov    rdi,rbx
    18f6:	call   18fb <botlish_fn_17+0xbb>
			18f7: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    18fb:	test   rax,rax
    18fe:	je     1933 <botlish_fn_17+0xf3>
    1904:	mov    rbx,QWORD PTR [rsp+0x20]
    1909:	mov    r12,QWORD PTR [rsp+0x28]
    190e:	mov    r13,QWORD PTR [rsp+0x30]
    1913:	add    rsp,0x40
    1917:	mov    rsp,rbp
    191a:	pop    rbp
    191b:	ret
    191c:	xor    rdx,rdx
    191f:	mov    rdi,rbx
    1922:	mov    rsi,rdx
    1925:	call   192a <botlish_fn_17+0xea>
			1926: R_X86_64_PLT32	rt_list_new-0x4
    192a:	test   rax,rax
    192d:	jne    194e <botlish_fn_17+0x10e>
    1933:	xor    rax,rax
    1936:	mov    rbx,QWORD PTR [rsp+0x20]
    193b:	mov    r12,QWORD PTR [rsp+0x28]
    1940:	mov    r13,QWORD PTR [rsp+0x30]
    1945:	add    rsp,0x40
    1949:	mov    rsp,rbp
    194c:	pop    rbp
    194d:	ret
    194e:	mov    rbx,QWORD PTR [rsp+0x20]
    1953:	mov    r12,QWORD PTR [rsp+0x28]
    1958:	mov    r13,QWORD PTR [rsp+0x30]
    195d:	add    rsp,0x40
    1961:	mov    rsp,rbp
    1964:	pop    rbp
    1965:	ret

0000000000001966 <botlish_entry_17: csv_parse<str>>:
    1966:	push   rbp
    1967:	mov    rbp,rsp
    196a:	mov    rsi,QWORD PTR [rdx]
    196d:	call   1972 <botlish_entry_17+0xc>
			196e: R_X86_64_PLT32	botlish_fn_17-0x4 ; csv_parse<str>
    1972:	mov    rsp,rbp
    1975:	pop    rbp
    1976:	ret

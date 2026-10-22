; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 21495  (per function: 45 89 89 89 357 436 436 436 272 272 272 81 365 309 470 932 310 758 215 480 318 489 446 70 493 114 103 105 44 231 243 692 1096 381 588 730 784 723 809 673 1304 780 107 433 259 629 515 78 78 1166 301)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<str>
;   botlish_fn_2 / botlish_entry_2 -> geo_new<List[str]>
;   botlish_fn_3 / botlish_entry_3 -> geo_new<HashTable>
;   botlish_fn_4 / botlish_entry_4 -> geo_new_capacity<int, int>
;   botlish_fn_5 / botlish_entry_5 -> geo_grow<mutarray, int, str>
;   botlish_fn_6 / botlish_entry_6 -> geo_grow<mutarray, int, List[str]>
;   botlish_fn_7 / botlish_entry_7 -> geo_grow<mutarray, int, HashTable>
;   botlish_fn_8 / botlish_entry_8 -> geo_append<mutarray, int, str>
;   botlish_fn_9 / botlish_entry_9 -> geo_append<mutarray, int, List[str]>
;   botlish_fn_10 / botlish_entry_10 -> geo_append<mutarray, int, HashTable>
;   botlish_fn_11 / botlish_entry_11 -> geo_finish<mutarray, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> quote_at?<str, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_unquoted<str, int, int>
;   botlish_fn_15 / botlish_entry_15 -> scan_quoted<str, int, str>
;   botlish_fn_16 / botlish_entry_16 -> scan_field<str, int>
;   botlish_fn_17 / botlish_entry_17 -> scan_record_rest<str, int, mutarray, int>
;   botlish_fn_18 / botlish_entry_18 -> scan_record<str, int>
;   botlish_fn_19 / botlish_entry_19 -> scan_records<str, int, mutarray, int>
;   botlish_fn_20 / botlish_entry_20 -> csv_parse<str>
;   botlish_fn_21 / botlish_entry_21 -> ht_alloc<int>
;   botlish_fn_22 / botlish_entry_22 -> ht_alloc<int>
;   botlish_fn_23 / botlish_entry_23 -> ht_new<generic>
;   botlish_fn_24 / botlish_entry_24 -> ht_capacity_for<int, int>
;   botlish_fn_25 / botlish_entry_25 -> ht_new_sized<int>
;   botlish_fn_26 / botlish_entry_26 -> ht_size<HashTable>
;   botlish_fn_27 / botlish_entry_27 -> ht_tombstones<HashTable>
;   botlish_fn_28 / botlish_entry_28 -> ht_capacity<HashTable>
;   botlish_fn_29 / botlish_entry_29 -> ht_probe_start<HashTable, str>
;   botlish_fn_30 / botlish_entry_30 -> ht_probe_next<HashTable, int>
;   botlish_fn_31 / botlish_entry_31 -> ht_find_get<HashTable, str, int>
;   botlish_fn_32 / botlish_entry_32 -> ht_find_insert<HashTable, str, int, int>
;   botlish_fn_33 / botlish_entry_33 -> ht_get<HashTable, str>
;   botlish_fn_34 / botlish_entry_34 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_35 / botlish_entry_35 -> ht_rehash_insert<HashTable, int, any, any>
;   botlish_fn_36 / botlish_entry_36 -> ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
;   botlish_fn_37 / botlish_entry_37 -> ht_rehash<HashTable, int>
;   botlish_fn_38 / botlish_entry_38 -> ht_should_grow<HashTable>
;   botlish_fn_39 / botlish_entry_39 -> ht_grow_or_clean<HashTable>
;   botlish_fn_40 / botlish_entry_40 -> ht_place<HashTable, int, str, str>
;   botlish_fn_41 / botlish_entry_41 -> ht_set<HashTable, str, str>
;   botlish_fn_42 / botlish_entry_42 -> row_new<bool, int>
;   botlish_fn_43 / botlish_entry_43 -> row_fill<HashTable, List[str], List[str], int, int>
;   botlish_fn_44 / botlish_entry_44 -> row_table<List[str], int, List[str], bool>
;   botlish_fn_45 / botlish_entry_45 -> build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
;   botlish_fn_46 / botlish_entry_46 -> csv_records_generic<str, bool>
;   botlish_fn_47 / botlish_entry_47 -> csv_records<str>
;   botlish_fn_48 / botlish_entry_48 -> csv_records_presized<str>
;   botlish_fn_49 / botlish_entry_49 -> sample_checks<generic>
;   botlish_fn_50 / botlish_entry_50 -> sample<generic>


csv_records.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
       9:	test   rax,rax
       c:	jne    1a <botlish_fn_0+0x1a>
      12:	xor    rax,rax
      15:	mov    rsp,rbp
      18:	pop    rbp
      19:	ret
      1a:	mov    rsp,rbp
      1d:	pop    rbp
      1e:	ret

000000000000001f <botlish_entry_0: <program entry>>:
      1f:	push   rbp
      20:	mov    rbp,rsp
      23:	call   28 <botlish_entry_0+0x9>
			24: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      28:	mov    rsp,rbp
      2b:	pop    rbp
      2c:	ret

000000000000002d <botlish_fn_1: geo_new<str>>:
      2d:	push   rbp
      2e:	mov    rbp,rsp
      31:	sub    rsp,0x10
      35:	mov    QWORD PTR [rsp],rsi
      39:	mov    rdx,rsi
      3c:	mov    esi,0x3
      41:	mov    QWORD PTR [rsp+0x8],0x3
      4a:	call   4f <botlish_fn_1+0x22>
			4b: R_X86_64_PLT32	rt_mutarray_create-0x4
      4f:	test   rax,rax
      52:	jne    64 <botlish_fn_1+0x37>
      58:	xor    rax,rax
      5b:	add    rsp,0x10
      5f:	mov    rsp,rbp
      62:	pop    rbp
      63:	ret
      64:	add    rsp,0x10
      68:	mov    rsp,rbp
      6b:	pop    rbp
      6c:	ret

000000000000006d <botlish_entry_1: geo_new<str>>:
      6d:	push   rbp
      6e:	mov    rbp,rsp
      71:	mov    rsi,QWORD PTR [rdx]
      74:	call   79 <botlish_entry_1+0xc>
			75: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
      79:	mov    rsp,rbp
      7c:	pop    rbp
      7d:	ret

000000000000007e <botlish_fn_2: geo_new<List[str]>>:
      7e:	push   rbp
      7f:	mov    rbp,rsp
      82:	sub    rsp,0x10
      86:	mov    QWORD PTR [rsp],rsi
      8a:	mov    rdx,rsi
      8d:	mov    esi,0x3
      92:	mov    QWORD PTR [rsp+0x8],0x3
      9b:	call   a0 <botlish_fn_2+0x22>
			9c: R_X86_64_PLT32	rt_mutarray_create-0x4
      a0:	test   rax,rax
      a3:	jne    b5 <botlish_fn_2+0x37>
      a9:	xor    rax,rax
      ac:	add    rsp,0x10
      b0:	mov    rsp,rbp
      b3:	pop    rbp
      b4:	ret
      b5:	add    rsp,0x10
      b9:	mov    rsp,rbp
      bc:	pop    rbp
      bd:	ret

00000000000000be <botlish_entry_2: geo_new<List[str]>>:
      be:	push   rbp
      bf:	mov    rbp,rsp
      c2:	mov    rsi,QWORD PTR [rdx]
      c5:	call   ca <botlish_entry_2+0xc>
			c6: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
      ca:	mov    rsp,rbp
      cd:	pop    rbp
      ce:	ret

00000000000000cf <botlish_fn_3: geo_new<HashTable>>:
      cf:	push   rbp
      d0:	mov    rbp,rsp
      d3:	sub    rsp,0x10
      d7:	mov    QWORD PTR [rsp],rsi
      db:	mov    rdx,rsi
      de:	mov    esi,0x3
      e3:	mov    QWORD PTR [rsp+0x8],0x3
      ec:	call   f1 <botlish_fn_3+0x22>
			ed: R_X86_64_PLT32	rt_mutarray_create-0x4
      f1:	test   rax,rax
      f4:	jne    106 <botlish_fn_3+0x37>
      fa:	xor    rax,rax
      fd:	add    rsp,0x10
     101:	mov    rsp,rbp
     104:	pop    rbp
     105:	ret
     106:	add    rsp,0x10
     10a:	mov    rsp,rbp
     10d:	pop    rbp
     10e:	ret

000000000000010f <botlish_entry_3: geo_new<HashTable>>:
     10f:	push   rbp
     110:	mov    rbp,rsp
     113:	mov    rsi,QWORD PTR [rdx]
     116:	call   11b <botlish_entry_3+0xc>
			117: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
     11b:	mov    rsp,rbp
     11e:	pop    rbp
     11f:	ret

0000000000000120 <botlish_fn_4: geo_new_capacity<int, int>>:
     120:	push   rbp
     121:	mov    rbp,rsp
     124:	sub    rsp,0x40
     128:	mov    QWORD PTR [rsp+0x20],rbx
     12d:	mov    QWORD PTR [rsp+0x28],r12
     132:	mov    QWORD PTR [rsp+0x30],r13
     137:	mov    r12,rdi
     13a:	mov    QWORD PTR [rsp],rsi
     13e:	mov    QWORD PTR [rsp+0x8],rdx
     143:	mov    rbx,rdx
     146:	mov    QWORD PTR [rsp+0x10],0x5
     14f:	test   rsi,0x1
     156:	je     178 <botlish_fn_4+0x58>
     15c:	mov    rax,rsi
     15f:	sar    rax,1
     162:	imul   QWORD PTR [rip+0xdf]        # 248 <botlish_fn_4+0x128>
     169:	seto   cl
     16c:	or     rax,0x1
     170:	test   cl,cl
     172:	je     185 <botlish_fn_4+0x65>
     178:	mov    edx,0x5
     17d:	mov    rdi,r12
     180:	call   185 <botlish_fn_4+0x65>
			181: R_X86_64_PLT32	rt_int_mul-0x4
     185:	mov    rcx,rax
     188:	and    rcx,rbx
     18b:	mov    r13,rax
     18e:	test   rcx,0x1
     195:	jne    1c1 <botlish_fn_4+0xa1>
     19b:	mov    rdx,rbx
     19e:	mov    rsi,r13
     1a1:	mov    rdi,r12
     1a4:	call   1a9 <botlish_fn_4+0x89>
			1a5: R_X86_64_PLT32	rt_int_cmp-0x4
     1a9:	mov    ecx,0x2
     1ae:	test   rax,rax
     1b1:	cmovle rcx,QWORD PTR [rip+0x97]        # 250 <botlish_fn_4+0x130>
     1b9:	mov    rax,r13
     1bc:	jmp    1d4 <botlish_fn_4+0xb4>
     1c1:	mov    ecx,0x2
     1c6:	mov    rax,r13
     1c9:	cmp    rax,rbx
     1cc:	cmovle rcx,QWORD PTR [rip+0x7c]        # 250 <botlish_fn_4+0x130>
     1d4:	cmp    rcx,0x6
     1d8:	je     1f6 <botlish_fn_4+0xd6>
     1de:	mov    rbx,QWORD PTR [rsp+0x20]
     1e3:	mov    r12,QWORD PTR [rsp+0x28]
     1e8:	mov    r13,QWORD PTR [rsp+0x30]
     1ed:	add    rsp,0x40
     1f1:	mov    rsp,rbp
     1f4:	pop    rbp
     1f5:	ret
     1f6:	mov    QWORD PTR [rsp],0x3
     1fe:	test   rbx,0x1
     205:	je     21d <botlish_fn_4+0xfd>
     20b:	mov    rax,rbx
     20e:	add    rax,0x2
     212:	seto   cl
     215:	test   cl,cl
     217:	je     22d <botlish_fn_4+0x10d>
     21d:	mov    edx,0x3
     222:	mov    rsi,rbx
     225:	mov    rdi,r12
     228:	call   22d <botlish_fn_4+0x10d>
			229: R_X86_64_PLT32	rt_int_add-0x4
     22d:	mov    rbx,QWORD PTR [rsp+0x20]
     232:	mov    r12,QWORD PTR [rsp+0x28]
     237:	mov    r13,QWORD PTR [rsp+0x30]
     23c:	add    rsp,0x40
     240:	mov    rsp,rbp
     243:	pop    rbp
     244:	ret
     245:	add    BYTE PTR [rax],al
     247:	add    BYTE PTR [rax+rax*1],al
     24a:	add    BYTE PTR [rax],al
     24c:	add    BYTE PTR [rax],al
     24e:	add    BYTE PTR [rax],al
     250:	(bad)
     251:	add    BYTE PTR [rax],al
     253:	add    BYTE PTR [rax],al
     255:	add    BYTE PTR [rax],al
	...

0000000000000258 <botlish_entry_4: geo_new_capacity<int, int>>:
     258:	push   rbp
     259:	mov    rbp,rsp
     25c:	mov    rsi,QWORD PTR [rdx]
     25f:	mov    rdx,QWORD PTR [rdx+0x8]
     263:	call   268 <botlish_entry_4+0x10>
			264: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     268:	mov    rsp,rbp
     26b:	pop    rbp
     26c:	ret
     26d:	add    BYTE PTR [rax],al
	...

0000000000000270 <botlish_fn_5: geo_grow<mutarray, int, str>>:
     270:	push   rbp
     271:	mov    rbp,rsp
     274:	sub    rsp,0x50
     278:	mov    QWORD PTR [rsp+0x20],rbx
     27d:	mov    QWORD PTR [rsp+0x28],r12
     282:	mov    QWORD PTR [rsp+0x30],r13
     287:	mov    QWORD PTR [rsp+0x38],r14
     28c:	mov    QWORD PTR [rsp+0x40],r15
     291:	mov    rbx,rdx
     294:	mov    r13,rdi
     297:	mov    QWORD PTR [rsp],rsi
     29b:	mov    r12,rsi
     29e:	mov    QWORD PTR [rsp+0x8],rdx
     2a3:	mov    QWORD PTR [rsp+0x10],rcx
     2a8:	mov    r14,rcx
     2ab:	mov    rax,r12
     2ae:	mov    rsi,QWORD PTR [rax+0x8]
     2b2:	shl    rsi,1
     2b5:	mov    rax,rsi
     2b8:	or     rax,0x1
     2bc:	mov    QWORD PTR [rsp+0x18],rax
     2c1:	mov    rdx,rbx
     2c4:	mov    rcx,rdx
     2c7:	and    rcx,rax
     2ca:	test   rcx,0x1
     2d1:	jne    304 <botlish_fn_5+0x94>
     2d7:	mov    rdx,rsi
     2da:	or     rdx,0x1
     2de:	mov    r15,rsi
     2e1:	mov    rsi,rbx
     2e4:	mov    rdi,r13
     2e7:	call   2ec <botlish_fn_5+0x7c>
			2e8: R_X86_64_PLT32	rt_int_cmp-0x4
     2ec:	mov    ecx,0x2
     2f1:	test   rax,rax
     2f4:	cmovl  rcx,QWORD PTR [rip+0xec]        # 3e8 <botlish_fn_5+0x178>
     2fc:	mov    rsi,r15
     2ff:	jmp    31b <botlish_fn_5+0xab>
     304:	mov    rdx,rsi
     307:	or     rdx,0x1
     30b:	mov    ecx,0x2
     310:	cmp    rbx,rdx
     313:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 3e8 <botlish_fn_5+0x178>
     31b:	cmp    rcx,0x6
     31f:	je     3c0 <botlish_fn_5+0x150>
     325:	or     rsi,0x1
     329:	mov    rdx,rbx
     32c:	mov    rdi,r13
     32f:	call   334 <botlish_fn_5+0xc4>
			330: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     334:	mov    QWORD PTR [rsp+0x18],rax
     339:	mov    rdx,r14
     33c:	mov    rsi,rax
     33f:	mov    rdi,r13
     342:	call   347 <botlish_fn_5+0xd7>
			343: R_X86_64_PLT32	rt_mutarray_create-0x4
     347:	test   rax,rax
     34a:	mov    r14,rax
     34d:	je     376 <botlish_fn_5+0x106>
     353:	mov    r8d,0x1
     359:	mov    rcx,r12
     35c:	mov    rdi,r13
     35f:	mov    r9,rbx
     362:	mov    rsi,r14
     365:	mov    rdx,r8
     368:	call   36d <botlish_fn_5+0xfd>
			369: R_X86_64_PLT32	rt_mutarray_copy-0x4
     36d:	test   rax,rax
     370:	jne    39b <botlish_fn_5+0x12b>
     376:	xor    rax,rax
     379:	mov    rbx,QWORD PTR [rsp+0x20]
     37e:	mov    r12,QWORD PTR [rsp+0x28]
     383:	mov    r13,QWORD PTR [rsp+0x30]
     388:	mov    r14,QWORD PTR [rsp+0x38]
     38d:	mov    r15,QWORD PTR [rsp+0x40]
     392:	add    rsp,0x50
     396:	mov    rsp,rbp
     399:	pop    rbp
     39a:	ret
     39b:	mov    rax,r14
     39e:	mov    rbx,QWORD PTR [rsp+0x20]
     3a3:	mov    r12,QWORD PTR [rsp+0x28]
     3a8:	mov    r13,QWORD PTR [rsp+0x30]
     3ad:	mov    r14,QWORD PTR [rsp+0x38]
     3b2:	mov    r15,QWORD PTR [rsp+0x40]
     3b7:	add    rsp,0x50
     3bb:	mov    rsp,rbp
     3be:	pop    rbp
     3bf:	ret
     3c0:	mov    rax,r12
     3c3:	mov    rbx,QWORD PTR [rsp+0x20]
     3c8:	mov    r12,QWORD PTR [rsp+0x28]
     3cd:	mov    r13,QWORD PTR [rsp+0x30]
     3d2:	mov    r14,QWORD PTR [rsp+0x38]
     3d7:	mov    r15,QWORD PTR [rsp+0x40]
     3dc:	add    rsp,0x50
     3e0:	mov    rsp,rbp
     3e3:	pop    rbp
     3e4:	ret
     3e5:	add    BYTE PTR [rax],al
     3e7:	add    BYTE PTR [rsi],al
     3e9:	add    BYTE PTR [rax],al
     3eb:	add    BYTE PTR [rax],al
     3ed:	add    BYTE PTR [rax],al
	...

00000000000003f0 <botlish_entry_5: geo_grow<mutarray, int, str>>:
     3f0:	push   rbp
     3f1:	mov    rbp,rsp
     3f4:	mov    rsi,QWORD PTR [rdx]
     3f7:	mov    r8,QWORD PTR [rdx+0x8]
     3fb:	mov    rcx,QWORD PTR [rdx+0x10]
     3ff:	mov    rdx,r8
     402:	call   407 <botlish_entry_5+0x17>
			403: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     407:	mov    rsp,rbp
     40a:	pop    rbp
     40b:	ret
     40c:	add    BYTE PTR [rax],al
	...

0000000000000410 <botlish_fn_6: geo_grow<mutarray, int, List[str]>>:
     410:	push   rbp
     411:	mov    rbp,rsp
     414:	sub    rsp,0x50
     418:	mov    QWORD PTR [rsp+0x20],rbx
     41d:	mov    QWORD PTR [rsp+0x28],r12
     422:	mov    QWORD PTR [rsp+0x30],r13
     427:	mov    QWORD PTR [rsp+0x38],r14
     42c:	mov    QWORD PTR [rsp+0x40],r15
     431:	mov    rbx,rdx
     434:	mov    r13,rdi
     437:	mov    QWORD PTR [rsp],rsi
     43b:	mov    r12,rsi
     43e:	mov    QWORD PTR [rsp+0x8],rdx
     443:	mov    QWORD PTR [rsp+0x10],rcx
     448:	mov    r14,rcx
     44b:	mov    rax,r12
     44e:	mov    rsi,QWORD PTR [rax+0x8]
     452:	shl    rsi,1
     455:	mov    rax,rsi
     458:	or     rax,0x1
     45c:	mov    QWORD PTR [rsp+0x18],rax
     461:	mov    rdx,rbx
     464:	mov    rcx,rdx
     467:	and    rcx,rax
     46a:	test   rcx,0x1
     471:	jne    4a4 <botlish_fn_6+0x94>
     477:	mov    rdx,rsi
     47a:	or     rdx,0x1
     47e:	mov    r15,rsi
     481:	mov    rsi,rbx
     484:	mov    rdi,r13
     487:	call   48c <botlish_fn_6+0x7c>
			488: R_X86_64_PLT32	rt_int_cmp-0x4
     48c:	mov    ecx,0x2
     491:	test   rax,rax
     494:	cmovl  rcx,QWORD PTR [rip+0xec]        # 588 <botlish_fn_6+0x178>
     49c:	mov    rsi,r15
     49f:	jmp    4bb <botlish_fn_6+0xab>
     4a4:	mov    rdx,rsi
     4a7:	or     rdx,0x1
     4ab:	mov    ecx,0x2
     4b0:	cmp    rbx,rdx
     4b3:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 588 <botlish_fn_6+0x178>
     4bb:	cmp    rcx,0x6
     4bf:	je     560 <botlish_fn_6+0x150>
     4c5:	or     rsi,0x1
     4c9:	mov    rdx,rbx
     4cc:	mov    rdi,r13
     4cf:	call   4d4 <botlish_fn_6+0xc4>
			4d0: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     4d4:	mov    QWORD PTR [rsp+0x18],rax
     4d9:	mov    rdx,r14
     4dc:	mov    rsi,rax
     4df:	mov    rdi,r13
     4e2:	call   4e7 <botlish_fn_6+0xd7>
			4e3: R_X86_64_PLT32	rt_mutarray_create-0x4
     4e7:	test   rax,rax
     4ea:	mov    r14,rax
     4ed:	je     516 <botlish_fn_6+0x106>
     4f3:	mov    r8d,0x1
     4f9:	mov    rcx,r12
     4fc:	mov    rdi,r13
     4ff:	mov    r9,rbx
     502:	mov    rsi,r14
     505:	mov    rdx,r8
     508:	call   50d <botlish_fn_6+0xfd>
			509: R_X86_64_PLT32	rt_mutarray_copy-0x4
     50d:	test   rax,rax
     510:	jne    53b <botlish_fn_6+0x12b>
     516:	xor    rax,rax
     519:	mov    rbx,QWORD PTR [rsp+0x20]
     51e:	mov    r12,QWORD PTR [rsp+0x28]
     523:	mov    r13,QWORD PTR [rsp+0x30]
     528:	mov    r14,QWORD PTR [rsp+0x38]
     52d:	mov    r15,QWORD PTR [rsp+0x40]
     532:	add    rsp,0x50
     536:	mov    rsp,rbp
     539:	pop    rbp
     53a:	ret
     53b:	mov    rax,r14
     53e:	mov    rbx,QWORD PTR [rsp+0x20]
     543:	mov    r12,QWORD PTR [rsp+0x28]
     548:	mov    r13,QWORD PTR [rsp+0x30]
     54d:	mov    r14,QWORD PTR [rsp+0x38]
     552:	mov    r15,QWORD PTR [rsp+0x40]
     557:	add    rsp,0x50
     55b:	mov    rsp,rbp
     55e:	pop    rbp
     55f:	ret
     560:	mov    rax,r12
     563:	mov    rbx,QWORD PTR [rsp+0x20]
     568:	mov    r12,QWORD PTR [rsp+0x28]
     56d:	mov    r13,QWORD PTR [rsp+0x30]
     572:	mov    r14,QWORD PTR [rsp+0x38]
     577:	mov    r15,QWORD PTR [rsp+0x40]
     57c:	add    rsp,0x50
     580:	mov    rsp,rbp
     583:	pop    rbp
     584:	ret
     585:	add    BYTE PTR [rax],al
     587:	add    BYTE PTR [rsi],al
     589:	add    BYTE PTR [rax],al
     58b:	add    BYTE PTR [rax],al
     58d:	add    BYTE PTR [rax],al
	...

0000000000000590 <botlish_entry_6: geo_grow<mutarray, int, List[str]>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	mov    rsi,QWORD PTR [rdx]
     597:	mov    r8,QWORD PTR [rdx+0x8]
     59b:	mov    rcx,QWORD PTR [rdx+0x10]
     59f:	mov    rdx,r8
     5a2:	call   5a7 <botlish_entry_6+0x17>
			5a3: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     5a7:	mov    rsp,rbp
     5aa:	pop    rbp
     5ab:	ret
     5ac:	add    BYTE PTR [rax],al
	...

00000000000005b0 <botlish_fn_7: geo_grow<mutarray, int, HashTable>>:
     5b0:	push   rbp
     5b1:	mov    rbp,rsp
     5b4:	sub    rsp,0x50
     5b8:	mov    QWORD PTR [rsp+0x20],rbx
     5bd:	mov    QWORD PTR [rsp+0x28],r12
     5c2:	mov    QWORD PTR [rsp+0x30],r13
     5c7:	mov    QWORD PTR [rsp+0x38],r14
     5cc:	mov    QWORD PTR [rsp+0x40],r15
     5d1:	mov    rbx,rdx
     5d4:	mov    r13,rdi
     5d7:	mov    QWORD PTR [rsp],rsi
     5db:	mov    r12,rsi
     5de:	mov    QWORD PTR [rsp+0x8],rdx
     5e3:	mov    QWORD PTR [rsp+0x10],rcx
     5e8:	mov    r14,rcx
     5eb:	mov    rax,r12
     5ee:	mov    rsi,QWORD PTR [rax+0x8]
     5f2:	shl    rsi,1
     5f5:	mov    rax,rsi
     5f8:	or     rax,0x1
     5fc:	mov    QWORD PTR [rsp+0x18],rax
     601:	mov    rdx,rbx
     604:	mov    rcx,rdx
     607:	and    rcx,rax
     60a:	test   rcx,0x1
     611:	jne    644 <botlish_fn_7+0x94>
     617:	mov    rdx,rsi
     61a:	or     rdx,0x1
     61e:	mov    r15,rsi
     621:	mov    rsi,rbx
     624:	mov    rdi,r13
     627:	call   62c <botlish_fn_7+0x7c>
			628: R_X86_64_PLT32	rt_int_cmp-0x4
     62c:	mov    ecx,0x2
     631:	test   rax,rax
     634:	cmovl  rcx,QWORD PTR [rip+0xec]        # 728 <botlish_fn_7+0x178>
     63c:	mov    rsi,r15
     63f:	jmp    65b <botlish_fn_7+0xab>
     644:	mov    rdx,rsi
     647:	or     rdx,0x1
     64b:	mov    ecx,0x2
     650:	cmp    rbx,rdx
     653:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 728 <botlish_fn_7+0x178>
     65b:	cmp    rcx,0x6
     65f:	je     700 <botlish_fn_7+0x150>
     665:	or     rsi,0x1
     669:	mov    rdx,rbx
     66c:	mov    rdi,r13
     66f:	call   674 <botlish_fn_7+0xc4>
			670: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     674:	mov    QWORD PTR [rsp+0x18],rax
     679:	mov    rdx,r14
     67c:	mov    rsi,rax
     67f:	mov    rdi,r13
     682:	call   687 <botlish_fn_7+0xd7>
			683: R_X86_64_PLT32	rt_mutarray_create-0x4
     687:	test   rax,rax
     68a:	mov    r14,rax
     68d:	je     6b6 <botlish_fn_7+0x106>
     693:	mov    r8d,0x1
     699:	mov    rcx,r12
     69c:	mov    rdi,r13
     69f:	mov    r9,rbx
     6a2:	mov    rsi,r14
     6a5:	mov    rdx,r8
     6a8:	call   6ad <botlish_fn_7+0xfd>
			6a9: R_X86_64_PLT32	rt_mutarray_copy-0x4
     6ad:	test   rax,rax
     6b0:	jne    6db <botlish_fn_7+0x12b>
     6b6:	xor    rax,rax
     6b9:	mov    rbx,QWORD PTR [rsp+0x20]
     6be:	mov    r12,QWORD PTR [rsp+0x28]
     6c3:	mov    r13,QWORD PTR [rsp+0x30]
     6c8:	mov    r14,QWORD PTR [rsp+0x38]
     6cd:	mov    r15,QWORD PTR [rsp+0x40]
     6d2:	add    rsp,0x50
     6d6:	mov    rsp,rbp
     6d9:	pop    rbp
     6da:	ret
     6db:	mov    rax,r14
     6de:	mov    rbx,QWORD PTR [rsp+0x20]
     6e3:	mov    r12,QWORD PTR [rsp+0x28]
     6e8:	mov    r13,QWORD PTR [rsp+0x30]
     6ed:	mov    r14,QWORD PTR [rsp+0x38]
     6f2:	mov    r15,QWORD PTR [rsp+0x40]
     6f7:	add    rsp,0x50
     6fb:	mov    rsp,rbp
     6fe:	pop    rbp
     6ff:	ret
     700:	mov    rax,r12
     703:	mov    rbx,QWORD PTR [rsp+0x20]
     708:	mov    r12,QWORD PTR [rsp+0x28]
     70d:	mov    r13,QWORD PTR [rsp+0x30]
     712:	mov    r14,QWORD PTR [rsp+0x38]
     717:	mov    r15,QWORD PTR [rsp+0x40]
     71c:	add    rsp,0x50
     720:	mov    rsp,rbp
     723:	pop    rbp
     724:	ret
     725:	add    BYTE PTR [rax],al
     727:	add    BYTE PTR [rsi],al
     729:	add    BYTE PTR [rax],al
     72b:	add    BYTE PTR [rax],al
     72d:	add    BYTE PTR [rax],al
	...

0000000000000730 <botlish_entry_7: geo_grow<mutarray, int, HashTable>>:
     730:	push   rbp
     731:	mov    rbp,rsp
     734:	mov    rsi,QWORD PTR [rdx]
     737:	mov    r8,QWORD PTR [rdx+0x8]
     73b:	mov    rcx,QWORD PTR [rdx+0x10]
     73f:	mov    rdx,r8
     742:	call   747 <botlish_entry_7+0x17>
			743: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     747:	mov    rsp,rbp
     74a:	pop    rbp
     74b:	ret

000000000000074c <botlish_fn_8: geo_append<mutarray, int, str>>:
     74c:	push   rbp
     74d:	mov    rbp,rsp
     750:	sub    rsp,0x40
     754:	mov    QWORD PTR [rsp+0x20],rbx
     759:	mov    QWORD PTR [rsp+0x28],r12
     75e:	mov    QWORD PTR [rsp+0x30],r13
     763:	mov    QWORD PTR [rsp+0x38],r15
     768:	mov    rbx,rdi
     76b:	mov    QWORD PTR [rsp],rsi
     76f:	mov    QWORD PTR [rsp+0x8],rdx
     774:	mov    r15,rdx
     777:	mov    QWORD PTR [rsp+0x10],rcx
     77c:	mov    r13,rcx
     77f:	mov    rcx,r13
     782:	mov    rdx,r15
     785:	mov    rdi,rbx
     788:	call   78d <botlish_fn_8+0x41>
			789: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     78d:	test   rax,rax
     790:	je     7ce <botlish_fn_8+0x82>
     796:	mov    rdx,r15
     799:	test   rdx,0x1
     7a0:	je     821 <botlish_fn_8+0xd5>
     7a6:	mov    rsi,QWORD PTR [rax+0x8]
     7aa:	mov    rdi,rdx
     7ad:	sar    rdi,1
     7b0:	cmp    rdi,rsi
     7b3:	jae    82f <botlish_fn_8+0xe3>
     7b9:	mov    rcx,QWORD PTR [rax+0x18]
     7bd:	mov    r12,rax
     7c0:	test   rcx,rcx
     7c3:	jne    7f6 <botlish_fn_8+0xaa>
     7c9:	jmp    83d <botlish_fn_8+0xf1>
     7ce:	xor    rax,rax
     7d1:	mov    rbx,QWORD PTR [rsp+0x20]
     7d6:	mov    r12,QWORD PTR [rsp+0x28]
     7db:	mov    r13,QWORD PTR [rsp+0x30]
     7e0:	mov    r15,QWORD PTR [rsp+0x38]
     7e5:	add    rsp,0x40
     7e9:	mov    rsp,rbp
     7ec:	pop    rbp
     7ed:	ret
     7ee:	mov    rax,r12
     7f1:	jmp    804 <botlish_fn_8+0xb8>
     7f6:	mov    rax,r12
     7f9:	mov    rcx,r13
     7fc:	mov    rdx,QWORD PTR [rax+0x10]
     800:	mov    QWORD PTR [rdx+rdi*8],rcx
     804:	mov    rbx,QWORD PTR [rsp+0x20]
     809:	mov    r12,QWORD PTR [rsp+0x28]
     80e:	mov    r13,QWORD PTR [rsp+0x30]
     813:	mov    r15,QWORD PTR [rsp+0x38]
     818:	add    rsp,0x40
     81c:	mov    rsp,rbp
     81f:	pop    rbp
     820:	ret
     821:	mov    rcx,r13
     824:	mov    rdi,rbx
     827:	mov    r12,rax
     82a:	jmp    843 <botlish_fn_8+0xf7>
     82f:	mov    rcx,r13
     832:	mov    rdi,rbx
     835:	mov    r12,rax
     838:	jmp    843 <botlish_fn_8+0xf7>
     83d:	mov    rcx,r13
     840:	mov    rdi,rbx
     843:	mov    rsi,r12
     846:	call   84b <botlish_fn_8+0xff>
			847: R_X86_64_PLT32	rt_mutarray_set-0x4
     84b:	test   rax,rax
     84e:	jne    7ee <botlish_fn_8+0xa2>
     854:	jmp    7ce <botlish_fn_8+0x82>

0000000000000859 <botlish_entry_8: geo_append<mutarray, int, str>>:
     859:	push   rbp
     85a:	mov    rbp,rsp
     85d:	mov    rsi,QWORD PTR [rdx]
     860:	mov    r8,QWORD PTR [rdx+0x8]
     864:	mov    rcx,QWORD PTR [rdx+0x10]
     868:	mov    rdx,r8
     86b:	call   870 <botlish_entry_8+0x17>
			86c: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     870:	mov    rsp,rbp
     873:	pop    rbp
     874:	ret

0000000000000875 <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     875:	push   rbp
     876:	mov    rbp,rsp
     879:	sub    rsp,0x40
     87d:	mov    QWORD PTR [rsp+0x20],rbx
     882:	mov    QWORD PTR [rsp+0x28],r12
     887:	mov    QWORD PTR [rsp+0x30],r13
     88c:	mov    QWORD PTR [rsp+0x38],r15
     891:	mov    rbx,rdi
     894:	mov    QWORD PTR [rsp],rsi
     898:	mov    QWORD PTR [rsp+0x8],rdx
     89d:	mov    r15,rdx
     8a0:	mov    QWORD PTR [rsp+0x10],rcx
     8a5:	mov    r13,rcx
     8a8:	mov    rcx,r13
     8ab:	mov    rdx,r15
     8ae:	mov    rdi,rbx
     8b1:	call   8b6 <botlish_fn_9+0x41>
			8b2: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     8b6:	test   rax,rax
     8b9:	je     8f7 <botlish_fn_9+0x82>
     8bf:	mov    rdx,r15
     8c2:	test   rdx,0x1
     8c9:	je     94a <botlish_fn_9+0xd5>
     8cf:	mov    rsi,QWORD PTR [rax+0x8]
     8d3:	mov    rdi,rdx
     8d6:	sar    rdi,1
     8d9:	cmp    rdi,rsi
     8dc:	jae    958 <botlish_fn_9+0xe3>
     8e2:	mov    rcx,QWORD PTR [rax+0x18]
     8e6:	mov    r12,rax
     8e9:	test   rcx,rcx
     8ec:	jne    91f <botlish_fn_9+0xaa>
     8f2:	jmp    966 <botlish_fn_9+0xf1>
     8f7:	xor    rax,rax
     8fa:	mov    rbx,QWORD PTR [rsp+0x20]
     8ff:	mov    r12,QWORD PTR [rsp+0x28]
     904:	mov    r13,QWORD PTR [rsp+0x30]
     909:	mov    r15,QWORD PTR [rsp+0x38]
     90e:	add    rsp,0x40
     912:	mov    rsp,rbp
     915:	pop    rbp
     916:	ret
     917:	mov    rax,r12
     91a:	jmp    92d <botlish_fn_9+0xb8>
     91f:	mov    rax,r12
     922:	mov    rcx,r13
     925:	mov    rdx,QWORD PTR [rax+0x10]
     929:	mov    QWORD PTR [rdx+rdi*8],rcx
     92d:	mov    rbx,QWORD PTR [rsp+0x20]
     932:	mov    r12,QWORD PTR [rsp+0x28]
     937:	mov    r13,QWORD PTR [rsp+0x30]
     93c:	mov    r15,QWORD PTR [rsp+0x38]
     941:	add    rsp,0x40
     945:	mov    rsp,rbp
     948:	pop    rbp
     949:	ret
     94a:	mov    rcx,r13
     94d:	mov    rdi,rbx
     950:	mov    r12,rax
     953:	jmp    96c <botlish_fn_9+0xf7>
     958:	mov    rcx,r13
     95b:	mov    rdi,rbx
     95e:	mov    r12,rax
     961:	jmp    96c <botlish_fn_9+0xf7>
     966:	mov    rcx,r13
     969:	mov    rdi,rbx
     96c:	mov    rsi,r12
     96f:	call   974 <botlish_fn_9+0xff>
			970: R_X86_64_PLT32	rt_mutarray_set-0x4
     974:	test   rax,rax
     977:	jne    917 <botlish_fn_9+0xa2>
     97d:	jmp    8f7 <botlish_fn_9+0x82>

0000000000000982 <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     982:	push   rbp
     983:	mov    rbp,rsp
     986:	mov    rsi,QWORD PTR [rdx]
     989:	mov    r8,QWORD PTR [rdx+0x8]
     98d:	mov    rcx,QWORD PTR [rdx+0x10]
     991:	mov    rdx,r8
     994:	call   999 <botlish_entry_9+0x17>
			995: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     999:	mov    rsp,rbp
     99c:	pop    rbp
     99d:	ret

000000000000099e <botlish_fn_10: geo_append<mutarray, int, HashTable>>:
     99e:	push   rbp
     99f:	mov    rbp,rsp
     9a2:	sub    rsp,0x40
     9a6:	mov    QWORD PTR [rsp+0x20],rbx
     9ab:	mov    QWORD PTR [rsp+0x28],r12
     9b0:	mov    QWORD PTR [rsp+0x30],r13
     9b5:	mov    QWORD PTR [rsp+0x38],r15
     9ba:	mov    rbx,rdi
     9bd:	mov    QWORD PTR [rsp],rsi
     9c1:	mov    QWORD PTR [rsp+0x8],rdx
     9c6:	mov    r15,rdx
     9c9:	mov    QWORD PTR [rsp+0x10],rcx
     9ce:	mov    r13,rcx
     9d1:	mov    rcx,r13
     9d4:	mov    rdx,r15
     9d7:	mov    rdi,rbx
     9da:	call   9df <botlish_fn_10+0x41>
			9db: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     9df:	test   rax,rax
     9e2:	je     a20 <botlish_fn_10+0x82>
     9e8:	mov    rdx,r15
     9eb:	test   rdx,0x1
     9f2:	je     a73 <botlish_fn_10+0xd5>
     9f8:	mov    rsi,QWORD PTR [rax+0x8]
     9fc:	mov    rdi,rdx
     9ff:	sar    rdi,1
     a02:	cmp    rdi,rsi
     a05:	jae    a81 <botlish_fn_10+0xe3>
     a0b:	mov    rcx,QWORD PTR [rax+0x18]
     a0f:	mov    r12,rax
     a12:	test   rcx,rcx
     a15:	jne    a48 <botlish_fn_10+0xaa>
     a1b:	jmp    a8f <botlish_fn_10+0xf1>
     a20:	xor    rax,rax
     a23:	mov    rbx,QWORD PTR [rsp+0x20]
     a28:	mov    r12,QWORD PTR [rsp+0x28]
     a2d:	mov    r13,QWORD PTR [rsp+0x30]
     a32:	mov    r15,QWORD PTR [rsp+0x38]
     a37:	add    rsp,0x40
     a3b:	mov    rsp,rbp
     a3e:	pop    rbp
     a3f:	ret
     a40:	mov    rax,r12
     a43:	jmp    a56 <botlish_fn_10+0xb8>
     a48:	mov    rax,r12
     a4b:	mov    rcx,r13
     a4e:	mov    rdx,QWORD PTR [rax+0x10]
     a52:	mov    QWORD PTR [rdx+rdi*8],rcx
     a56:	mov    rbx,QWORD PTR [rsp+0x20]
     a5b:	mov    r12,QWORD PTR [rsp+0x28]
     a60:	mov    r13,QWORD PTR [rsp+0x30]
     a65:	mov    r15,QWORD PTR [rsp+0x38]
     a6a:	add    rsp,0x40
     a6e:	mov    rsp,rbp
     a71:	pop    rbp
     a72:	ret
     a73:	mov    rcx,r13
     a76:	mov    rdi,rbx
     a79:	mov    r12,rax
     a7c:	jmp    a95 <botlish_fn_10+0xf7>
     a81:	mov    rcx,r13
     a84:	mov    rdi,rbx
     a87:	mov    r12,rax
     a8a:	jmp    a95 <botlish_fn_10+0xf7>
     a8f:	mov    rcx,r13
     a92:	mov    rdi,rbx
     a95:	mov    rsi,r12
     a98:	call   a9d <botlish_fn_10+0xff>
			a99: R_X86_64_PLT32	rt_mutarray_set-0x4
     a9d:	test   rax,rax
     aa0:	jne    a40 <botlish_fn_10+0xa2>
     aa6:	jmp    a20 <botlish_fn_10+0x82>

0000000000000aab <botlish_entry_10: geo_append<mutarray, int, HashTable>>:
     aab:	push   rbp
     aac:	mov    rbp,rsp
     aaf:	mov    rsi,QWORD PTR [rdx]
     ab2:	mov    r8,QWORD PTR [rdx+0x8]
     ab6:	mov    rcx,QWORD PTR [rdx+0x10]
     aba:	mov    rdx,r8
     abd:	call   ac2 <botlish_entry_10+0x17>
			abe: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
     ac2:	mov    rsp,rbp
     ac5:	pop    rbp
     ac6:	ret

0000000000000ac7 <botlish_fn_11: geo_finish<mutarray, int>>:
     ac7:	push   rbp
     ac8:	mov    rbp,rsp
     acb:	sub    rsp,0x10
     acf:	mov    QWORD PTR [rsp],rsi
     ad3:	mov    QWORD PTR [rsp+0x8],rdx
     ad8:	call   add <botlish_fn_11+0x16>
			ad9: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     add:	test   rax,rax
     ae0:	jne    af2 <botlish_fn_11+0x2b>
     ae6:	xor    rax,rax
     ae9:	add    rsp,0x10
     aed:	mov    rsp,rbp
     af0:	pop    rbp
     af1:	ret
     af2:	add    rsp,0x10
     af6:	mov    rsp,rbp
     af9:	pop    rbp
     afa:	ret

0000000000000afb <botlish_entry_11: geo_finish<mutarray, int>>:
     afb:	push   rbp
     afc:	mov    rbp,rsp
     aff:	mov    rsi,QWORD PTR [rdx]
     b02:	mov    rdx,QWORD PTR [rdx+0x8]
     b06:	call   b0b <botlish_entry_11+0x10>
			b07: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
     b0b:	mov    rsp,rbp
     b0e:	pop    rbp
     b0f:	ret

0000000000000b10 <botlish_fn_12: peek<str, int>>:
     b10:	push   rbp
     b11:	mov    rbp,rsp
     b14:	sub    rsp,0x40
     b18:	mov    QWORD PTR [rsp+0x20],rbx
     b1d:	mov    QWORD PTR [rsp+0x28],r12
     b22:	mov    QWORD PTR [rsp+0x30],r13
     b27:	mov    rbx,rdx
     b2a:	mov    r13,rdi
     b2d:	mov    QWORD PTR [rsp],rsi
     b31:	mov    QWORD PTR [rsp+0x8],rdx
     b36:	mov    rdx,QWORD PTR [rsi+0x8]
     b3a:	mov    r12,rsi
     b3d:	shl    rdx,1
     b40:	mov    rax,rdx
     b43:	or     rax,0x1
     b47:	mov    rcx,rbx
     b4a:	and    rcx,rax
     b4d:	test   rcx,0x1
     b54:	jne    b7e <botlish_fn_12+0x6e>
     b5a:	or     rdx,0x1
     b5e:	mov    rsi,rbx
     b61:	mov    rdi,r13
     b64:	call   b69 <botlish_fn_12+0x59>
			b65: R_X86_64_PLT32	rt_int_cmp-0x4
     b69:	mov    ecx,0x2
     b6e:	test   rax,rax
     b71:	cmovge rcx,QWORD PTR [rip+0xcf]        # c48 <botlish_fn_12+0x138>
     b79:	jmp    b92 <botlish_fn_12+0x82>
     b7e:	or     rdx,0x1
     b82:	mov    ecx,0x2
     b87:	cmp    rbx,rdx
     b8a:	cmovge rcx,QWORD PTR [rip+0xb6]        # c48 <botlish_fn_12+0x138>
     b92:	cmp    rcx,0x6
     b96:	je     c26 <botlish_fn_12+0x116>
     b9c:	mov    QWORD PTR [rsp+0x10],0x3
     ba5:	test   rbx,0x1
     bac:	je     bc4 <botlish_fn_12+0xb4>
     bb2:	mov    rcx,rbx
     bb5:	add    rcx,0x2
     bb9:	seto   al
     bbc:	test   al,al
     bbe:	je     bd7 <botlish_fn_12+0xc7>
     bc4:	mov    edx,0x3
     bc9:	mov    rsi,rbx
     bcc:	mov    rdi,r13
     bcf:	call   bd4 <botlish_fn_12+0xc4>
			bd0: R_X86_64_PLT32	rt_int_add-0x4
     bd4:	mov    rcx,rax
     bd7:	mov    QWORD PTR [rsp+0x10],rcx
     bdc:	mov    rdx,rbx
     bdf:	mov    rsi,r12
     be2:	mov    rdi,r13
     be5:	call   bea <botlish_fn_12+0xda>
			be6: R_X86_64_PLT32	rt_substr-0x4
     bea:	test   rax,rax
     bed:	jne    c0e <botlish_fn_12+0xfe>
     bf3:	xor    rax,rax
     bf6:	mov    rbx,QWORD PTR [rsp+0x20]
     bfb:	mov    r12,QWORD PTR [rsp+0x28]
     c00:	mov    r13,QWORD PTR [rsp+0x30]
     c05:	add    rsp,0x40
     c09:	mov    rsp,rbp
     c0c:	pop    rbp
     c0d:	ret
     c0e:	mov    rbx,QWORD PTR [rsp+0x20]
     c13:	mov    r12,QWORD PTR [rsp+0x28]
     c18:	mov    r13,QWORD PTR [rsp+0x30]
     c1d:	add    rsp,0x40
     c21:	mov    rsp,rbp
     c24:	pop    rbp
     c25:	ret
     c26:	mov    rdi,r13
     c29:	mov    rax,QWORD PTR [rdi+0x10]
     c2d:	mov    rax,QWORD PTR [rax]
     c30:	mov    rbx,QWORD PTR [rsp+0x20]
     c35:	mov    r12,QWORD PTR [rsp+0x28]
     c3a:	mov    r13,QWORD PTR [rsp+0x30]
     c3f:	add    rsp,0x40
     c43:	mov    rsp,rbp
     c46:	pop    rbp
     c47:	ret
     c48:	(bad)
     c49:	add    BYTE PTR [rax],al
     c4b:	add    BYTE PTR [rax],al
     c4d:	add    BYTE PTR [rax],al
	...

0000000000000c50 <botlish_entry_12: peek<str, int>>:
     c50:	push   rbp
     c51:	mov    rbp,rsp
     c54:	mov    rsi,QWORD PTR [rdx]
     c57:	mov    rdx,QWORD PTR [rdx+0x8]
     c5b:	call   c60 <botlish_entry_12+0x10>
			c5c: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     c60:	mov    rsp,rbp
     c63:	pop    rbp
     c64:	ret
     c65:	add    BYTE PTR [rax],al
	...

0000000000000c68 <botlish_fn_13: quote_at?<str, int>>:
     c68:	push   rbp
     c69:	mov    rbp,rsp
     c6c:	sub    rsp,0x20
     c70:	mov    QWORD PTR [rsp],rbx
     c74:	mov    QWORD PTR [rsp+0x8],r12
     c79:	mov    QWORD PTR [rsp+0x10],r13
     c7e:	mov    rbx,rdx
     c81:	mov    r13,rdi
     c84:	mov    rdx,QWORD PTR [rsi+0x8]
     c88:	mov    r12,rsi
     c8b:	shl    rdx,1
     c8e:	mov    rax,rdx
     c91:	or     rax,0x1
     c95:	mov    rcx,rbx
     c98:	and    rcx,rax
     c9b:	test   rcx,0x1
     ca2:	jne    ccc <botlish_fn_13+0x64>
     ca8:	or     rdx,0x1
     cac:	mov    rsi,rbx
     caf:	mov    rdi,r13
     cb2:	call   cb7 <botlish_fn_13+0x4f>
			cb3: R_X86_64_PLT32	rt_int_cmp-0x4
     cb7:	mov    ecx,0x2
     cbc:	test   rax,rax
     cbf:	cmovl  rcx,QWORD PTR [rip+0xa1]        # d68 <botlish_fn_13+0x100>
     cc7:	jmp    ce3 <botlish_fn_13+0x7b>
     ccc:	or     rdx,0x1
     cd0:	mov    ecx,0x2
     cd5:	mov    rax,rbx
     cd8:	cmp    rax,rdx
     cdb:	cmovl  rcx,QWORD PTR [rip+0x85]        # d68 <botlish_fn_13+0x100>
     ce3:	mov    eax,0x6
     ce8:	cmp    rcx,0x6
     cec:	je     cff <botlish_fn_13+0x97>
     cf2:	mov    eax,0x2
     cf7:	mov    r12,rax
     cfa:	jmp    d4c <botlish_fn_13+0xe4>
     cff:	mov    rdi,r13
     d02:	mov    rsi,r12
     d05:	mov    r12,rax
     d08:	mov    rdx,rbx
     d0b:	call   d10 <botlish_fn_13+0xa8>
			d0c: R_X86_64_PLT32	rt_str_char_at-0x4
     d10:	test   rax,rax
     d13:	jne    d33 <botlish_fn_13+0xcb>
     d19:	xor    rax,rax
     d1c:	mov    rbx,QWORD PTR [rsp]
     d20:	mov    r12,QWORD PTR [rsp+0x8]
     d25:	mov    r13,QWORD PTR [rsp+0x10]
     d2a:	add    rsp,0x20
     d2e:	mov    rsp,rbp
     d31:	pop    rbp
     d32:	ret
     d33:	cmp    rax,0x114
     d39:	je     d49 <botlish_fn_13+0xe1>
     d3f:	mov    eax,0x2
     d44:	jmp    d4c <botlish_fn_13+0xe4>
     d49:	mov    rax,r12
     d4c:	mov    rbx,QWORD PTR [rsp]
     d50:	mov    r12,QWORD PTR [rsp+0x8]
     d55:	mov    r13,QWORD PTR [rsp+0x10]
     d5a:	add    rsp,0x20
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

0000000000000d70 <botlish_entry_13: quote_at?<str, int>>:
     d70:	push   rbp
     d71:	mov    rbp,rsp
     d74:	mov    rsi,QWORD PTR [rdx]
     d77:	mov    rdx,QWORD PTR [rdx+0x8]
     d7b:	call   d80 <botlish_entry_13+0x10>
			d7c: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     d80:	mov    rsp,rbp
     d83:	pop    rbp
     d84:	ret
     d85:	add    BYTE PTR [rax],al
	...

0000000000000d88 <botlish_fn_14: scan_unquoted<str, int, int>>:
     d88:	push   rbp
     d89:	mov    rbp,rsp
     d8c:	sub    rsp,0x40
     d90:	mov    QWORD PTR [rsp+0x20],rbx
     d95:	mov    QWORD PTR [rsp+0x28],r12
     d9a:	mov    QWORD PTR [rsp+0x30],r13
     d9f:	mov    QWORD PTR [rsp+0x38],r14
     da4:	mov    r13,rdi
     da7:	mov    QWORD PTR [rsp+0x18],0x0
     db0:	mov    QWORD PTR [rsp],rsi
     db4:	mov    r12,rsi
     db7:	mov    QWORD PTR [rsp+0x8],rdx
     dbc:	mov    rbx,rdx
     dbf:	mov    QWORD PTR [rsp+0x10],rcx
     dc4:	mov    rax,r12
     dc7:	mov    rsi,rcx
     dca:	mov    rdx,QWORD PTR [rax+0x8]
     dce:	mov    r12,rax
     dd1:	shl    rdx,1
     dd4:	or     rdx,0x1
     dd8:	mov    rax,rsi
     ddb:	and    rax,rdx
     dde:	mov    r14,rsi
     de1:	test   rax,0x1
     de7:	jne    e0d <botlish_fn_14+0x85>
     ded:	mov    rsi,r14
     df0:	mov    rdi,r13
     df3:	call   df8 <botlish_fn_14+0x70>
			df4: R_X86_64_PLT32	rt_int_cmp-0x4
     df8:	mov    ecx,0x2
     dfd:	test   rax,rax
     e00:	cmovl  rcx,QWORD PTR [rip+0x138]        # f40 <botlish_fn_14+0x1b8>
     e08:	jmp    e20 <botlish_fn_14+0x98>
     e0d:	mov    ecx,0x2
     e12:	mov    rsi,r14
     e15:	cmp    rsi,rdx
     e18:	cmovl  rcx,QWORD PTR [rip+0x120]        # f40 <botlish_fn_14+0x1b8>
     e20:	cmp    rcx,0x6
     e24:	je     e38 <botlish_fn_14+0xb0>
     e2a:	mov    rdx,rbx
     e2d:	mov    rsi,r12
     e30:	mov    rdi,r13
     e33:	jmp    ee3 <botlish_fn_14+0x15b>
     e38:	mov    rdx,r14
     e3b:	mov    rsi,r12
     e3e:	mov    rdi,r13
     e41:	call   e46 <botlish_fn_14+0xbe>
			e42: R_X86_64_PLT32	rt_str_char_at-0x4
     e46:	test   rax,rax
     e49:	je     efa <botlish_fn_14+0x172>
     e4f:	cmp    rax,0x164
     e55:	jne    e63 <botlish_fn_14+0xdb>
     e5b:	mov    rdx,rbx
     e5e:	jmp    edd <botlish_fn_14+0x155>
     e63:	cmp    rax,0x54
     e67:	jne    e75 <botlish_fn_14+0xed>
     e6d:	mov    rdx,rbx
     e70:	jmp    edd <botlish_fn_14+0x155>
     e75:	mov    QWORD PTR [rsp+0x18],0x3
     e7e:	mov    rsi,r14
     e81:	test   rsi,0x1
     e88:	je     eab <botlish_fn_14+0x123>
     e8e:	mov    rsi,r14
     e91:	mov    rax,rsi
     e94:	add    rax,0x2
     e98:	seto   cl
     e9b:	test   cl,cl
     e9d:	jne    eab <botlish_fn_14+0x123>
     ea3:	mov    rsi,r12
     ea6:	jmp    ebe <botlish_fn_14+0x136>
     eab:	mov    edx,0x3
     eb0:	mov    rsi,r14
     eb3:	mov    rdi,r13
     eb6:	call   ebb <botlish_fn_14+0x133>
			eb7: R_X86_64_PLT32	rt_int_add-0x4
     ebb:	mov    rsi,r12
     ebe:	mov    rsi,r12
     ec1:	mov    QWORD PTR [rsp],rsi
     ec5:	mov    rdx,rbx
     ec8:	mov    QWORD PTR [rsp+0x8],rdx
     ecd:	mov    QWORD PTR [rsp+0x10],rax
     ed2:	mov    rsi,rax
     ed5:	mov    rax,r12
     ed8:	jmp    dca <botlish_fn_14+0x42>
     edd:	mov    rsi,r12
     ee0:	mov    rdi,r13
     ee3:	mov    rsi,r12
     ee6:	mov    rdi,r13
     ee9:	mov    rcx,r14
     eec:	call   ef1 <botlish_fn_14+0x169>
			eed: R_X86_64_PLT32	rt_substr-0x4
     ef1:	test   rax,rax
     ef4:	jne    f1d <botlish_fn_14+0x195>
     efa:	xor    rdx,rdx
     efd:	mov    rax,rdx
     f00:	mov    rbx,QWORD PTR [rsp+0x20]
     f05:	mov    r12,QWORD PTR [rsp+0x28]
     f0a:	mov    r13,QWORD PTR [rsp+0x30]
     f0f:	mov    r14,QWORD PTR [rsp+0x38]
     f14:	add    rsp,0x40
     f18:	mov    rsp,rbp
     f1b:	pop    rbp
     f1c:	ret
     f1d:	mov    rdx,r14
     f20:	mov    rbx,QWORD PTR [rsp+0x20]
     f25:	mov    r12,QWORD PTR [rsp+0x28]
     f2a:	mov    r13,QWORD PTR [rsp+0x30]
     f2f:	mov    r14,QWORD PTR [rsp+0x38]
     f34:	add    rsp,0x40
     f38:	mov    rsp,rbp
     f3b:	pop    rbp
     f3c:	ret
     f3d:	add    BYTE PTR [rax],al
     f3f:	add    BYTE PTR [rsi],al
     f41:	add    BYTE PTR [rax],al
     f43:	add    BYTE PTR [rax],al
     f45:	add    BYTE PTR [rax],al
	...

0000000000000f48 <botlish_entry_14: scan_unquoted<str, int, int>>:
     f48:	push   rbp
     f49:	mov    rbp,rsp
     f4c:	ud2

0000000000000f4e <botlish_fn_15: scan_quoted<str, int, str>>:
     f4e:	push   rbp
     f4f:	mov    rbp,rsp
     f52:	sub    rsp,0xb0
     f59:	mov    QWORD PTR [rsp+0x80],rbx
     f61:	mov    QWORD PTR [rsp+0x88],r12
     f69:	mov    QWORD PTR [rsp+0x90],r13
     f71:	mov    QWORD PTR [rsp+0x98],r14
     f79:	mov    QWORD PTR [rsp+0xa0],r15
     f81:	mov    r15,rdi
     f84:	mov    QWORD PTR [rsp+0x18],0x0
     f8d:	mov    QWORD PTR [rsp+0x20],0x0
     f96:	mov    QWORD PTR [rsp],rsi
     f9a:	mov    QWORD PTR [rsp+0x8],rdx
     f9f:	mov    QWORD PTR [rsp+0x10],rcx
     fa4:	mov    r13,rcx
     fa7:	lea    r12,[rsp+0x58]
     fac:	mov    rbx,rsi
     faf:	mov    QWORD PTR [rsp+0x78],rdx
     fb4:	mov    rdx,QWORD PTR [rsp+0x78]
     fb9:	mov    rsi,rbx
     fbc:	mov    rdi,r15
     fbf:	call   fc4 <botlish_fn_15+0x76>
			fc0: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     fc4:	test   rax,rax
     fc7:	je     1263 <botlish_fn_15+0x315>
     fcd:	mov    QWORD PTR [rsp+0x18],rax
     fd2:	mov    r14,rax
     fd5:	mov    rdx,QWORD PTR [rsp+0x78]
     fda:	mov    rsi,rbx
     fdd:	mov    rdi,r15
     fe0:	call   fe5 <botlish_fn_15+0x97>
			fe1: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     fe5:	test   rax,rax
     fe8:	je     1263 <botlish_fn_15+0x315>
     fee:	cmp    rax,0x6
     ff2:	je     10ab <botlish_fn_15+0x15d>
     ff8:	mov    QWORD PTR [rsp+0x20],0x3
    1001:	mov    rsi,QWORD PTR [rsp+0x78]
    1006:	test   rsi,0x1
    100d:	je     1037 <botlish_fn_15+0xe9>
    1013:	mov    rsi,QWORD PTR [rsp+0x78]
    1018:	mov    rcx,rsi
    101b:	add    rcx,0x2
    101f:	seto   dl
    1022:	test   dl,dl
    1024:	jne    1037 <botlish_fn_15+0xe9>
    102a:	mov    rsi,rcx
    102d:	mov    QWORD PTR [rsp+0x78],rcx
    1032:	jmp    1051 <botlish_fn_15+0x103>
    1037:	mov    edx,0x3
    103c:	mov    rsi,QWORD PTR [rsp+0x78]
    1041:	mov    rdi,r15
    1044:	call   1049 <botlish_fn_15+0xfb>
			1045: R_X86_64_PLT32	rt_int_add-0x4
    1049:	mov    rsi,rax
    104c:	mov    QWORD PTR [rsp+0x78],rax
    1051:	mov    QWORD PTR [rsp+0x8],rsi
    1056:	mov    QWORD PTR [rsp+0x58],0x0
    105f:	mov    QWORD PTR [rsp+0x60],r13
    1064:	mov    QWORD PTR [rsp+0x68],0x0
    106d:	mov    QWORD PTR [rsp+0x70],r14
    1072:	mov    esi,0x2
    1077:	mov    edx,0x4
    107c:	mov    rcx,r12
    107f:	mov    rdi,r15
    1082:	call   1087 <botlish_fn_15+0x139>
			1083: R_X86_64_PLT32	rt_construct-0x4
    1087:	test   rax,rax
    108a:	je     1263 <botlish_fn_15+0x315>
    1090:	mov    QWORD PTR [rsp],rbx
    1094:	mov    rsi,QWORD PTR [rsp+0x78]
    1099:	mov    QWORD PTR [rsp+0x8],rsi
    109e:	mov    QWORD PTR [rsp+0x10],rax
    10a3:	mov    r13,rax
    10a6:	jmp    fb4 <botlish_fn_15+0x66>
    10ab:	mov    QWORD PTR [rsp+0x20],0x3
    10b4:	mov    rsi,QWORD PTR [rsp+0x78]
    10b9:	test   rsi,0x1
    10c0:	je     10dd <botlish_fn_15+0x18f>
    10c6:	mov    rsi,QWORD PTR [rsp+0x78]
    10cb:	mov    rdx,rsi
    10ce:	add    rdx,0x2
    10d2:	seto   al
    10d5:	test   al,al
    10d7:	je     10f2 <botlish_fn_15+0x1a4>
    10dd:	mov    edx,0x3
    10e2:	mov    rsi,QWORD PTR [rsp+0x78]
    10e7:	mov    rdi,r15
    10ea:	call   10ef <botlish_fn_15+0x1a1>
			10eb: R_X86_64_PLT32	rt_int_add-0x4
    10ef:	mov    rdx,rax
    10f2:	mov    rsi,rbx
    10f5:	mov    rdi,r15
    10f8:	call   10fd <botlish_fn_15+0x1af>
			10f9: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
    10fd:	test   rax,rax
    1100:	je     1263 <botlish_fn_15+0x315>
    1106:	cmp    rax,0x6
    110a:	je     11c9 <botlish_fn_15+0x27b>
    1110:	xor    rsi,rsi
    1113:	lea    rcx,[rsp+0x48]
    1118:	mov    QWORD PTR [rsp+0x48],0x0
    1121:	mov    QWORD PTR [rsp+0x50],r13
    1126:	mov    edx,0x2
    112b:	mov    rdi,r15
    112e:	call   1133 <botlish_fn_15+0x1e5>
			112f: R_X86_64_PLT32	rt_construct-0x4
    1133:	test   rax,rax
    1136:	je     1263 <botlish_fn_15+0x315>
    113c:	mov    QWORD PTR [rsp],rax
    1140:	mov    r12,rax
    1143:	mov    QWORD PTR [rsp+0x10],0x3
    114c:	mov    rsi,QWORD PTR [rsp+0x78]
    1151:	test   rsi,0x1
    1158:	je     117d <botlish_fn_15+0x22f>
    115e:	mov    rsi,QWORD PTR [rsp+0x78]
    1163:	mov    rdx,rsi
    1166:	add    rdx,0x2
    116a:	seto   al
    116d:	test   al,al
    116f:	jne    117d <botlish_fn_15+0x22f>
    1175:	mov    rax,r12
    1178:	jmp    1195 <botlish_fn_15+0x247>
    117d:	mov    edx,0x3
    1182:	mov    rsi,QWORD PTR [rsp+0x78]
    1187:	mov    rdi,r15
    118a:	call   118f <botlish_fn_15+0x241>
			118b: R_X86_64_PLT32	rt_int_add-0x4
    118f:	mov    rdx,rax
    1192:	mov    rax,r12
    1195:	mov    rbx,QWORD PTR [rsp+0x80]
    119d:	mov    r12,QWORD PTR [rsp+0x88]
    11a5:	mov    r13,QWORD PTR [rsp+0x90]
    11ad:	mov    r14,QWORD PTR [rsp+0x98]
    11b5:	mov    r15,QWORD PTR [rsp+0xa0]
    11bd:	add    rsp,0xb0
    11c4:	mov    rsp,rbp
    11c7:	pop    rbp
    11c8:	ret
    11c9:	mov    QWORD PTR [rsp+0x20],0x5
    11d2:	mov    rsi,QWORD PTR [rsp+0x78]
    11d7:	test   rsi,0x1
    11de:	je     1208 <botlish_fn_15+0x2ba>
    11e4:	mov    rsi,QWORD PTR [rsp+0x78]
    11e9:	mov    rcx,rsi
    11ec:	add    rcx,0x4
    11f0:	seto   al
    11f3:	test   al,al
    11f5:	jne    1208 <botlish_fn_15+0x2ba>
    11fb:	mov    rsi,rcx
    11fe:	mov    QWORD PTR [rsp+0x78],rcx
    1203:	jmp    1222 <botlish_fn_15+0x2d4>
    1208:	mov    edx,0x5
    120d:	mov    rsi,QWORD PTR [rsp+0x78]
    1212:	mov    rdi,r15
    1215:	call   121a <botlish_fn_15+0x2cc>
			1216: R_X86_64_PLT32	rt_int_add-0x4
    121a:	mov    rsi,rax
    121d:	mov    QWORD PTR [rsp+0x78],rax
    1222:	mov    QWORD PTR [rsp+0x8],rsi
    1227:	lea    rcx,[rsp+0x28]
    122c:	mov    QWORD PTR [rsp+0x28],0x0
    1235:	mov    QWORD PTR [rsp+0x30],r13
    123a:	mov    QWORD PTR [rsp+0x38],0x0
    1243:	mov    QWORD PTR [rsp+0x40],r14
    1248:	mov    esi,0x2
    124d:	mov    edx,0x4
    1252:	mov    rdi,r15
    1255:	call   125a <botlish_fn_15+0x30c>
			1256: R_X86_64_PLT32	rt_construct-0x4
    125a:	test   rax,rax
    125d:	jne    129d <botlish_fn_15+0x34f>
    1263:	xor    rdx,rdx
    1266:	mov    rax,rdx
    1269:	mov    rbx,QWORD PTR [rsp+0x80]
    1271:	mov    r12,QWORD PTR [rsp+0x88]
    1279:	mov    r13,QWORD PTR [rsp+0x90]
    1281:	mov    r14,QWORD PTR [rsp+0x98]
    1289:	mov    r15,QWORD PTR [rsp+0xa0]
    1291:	add    rsp,0xb0
    1298:	mov    rsp,rbp
    129b:	pop    rbp
    129c:	ret
    129d:	mov    QWORD PTR [rsp],rbx
    12a1:	mov    rsi,QWORD PTR [rsp+0x78]
    12a6:	mov    QWORD PTR [rsp+0x8],rsi
    12ab:	mov    QWORD PTR [rsp+0x10],rax
    12b0:	mov    r13,rax
    12b3:	jmp    fb4 <botlish_fn_15+0x66>

00000000000012b8 <botlish_entry_15: scan_quoted<str, int, str>>:
    12b8:	push   rbp
    12b9:	mov    rbp,rsp
    12bc:	ud2

00000000000012be <botlish_fn_16: scan_field<str, int>>:
    12be:	push   rbp
    12bf:	mov    rbp,rsp
    12c2:	sub    rsp,0x40
    12c6:	mov    QWORD PTR [rsp+0x20],rbx
    12cb:	mov    QWORD PTR [rsp+0x28],r12
    12d0:	mov    QWORD PTR [rsp+0x30],r13
    12d5:	mov    r12,rdi
    12d8:	mov    r13,rdx
    12db:	mov    QWORD PTR [rsp+0x10],0x0
    12e4:	mov    QWORD PTR [rsp],rsi
    12e8:	mov    rbx,rsi
    12eb:	mov    QWORD PTR [rsp+0x8],rdx
    12f0:	mov    rdx,r13
    12f3:	mov    rsi,rbx
    12f6:	mov    rdi,r12
    12f9:	call   12fe <botlish_fn_16+0x40>
			12fa: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
    12fe:	test   rax,rax
    1301:	je     13b1 <botlish_fn_16+0xf3>
    1307:	cmp    rax,0x6
    130b:	je     1343 <botlish_fn_16+0x85>
    1311:	mov    rcx,r13
    1314:	mov    rsi,rbx
    1317:	mov    rdi,r12
    131a:	mov    rdx,rcx
    131d:	call   1322 <botlish_fn_16+0x64>
			131e: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_unquoted<str, int, int>
    1322:	test   rax,rax
    1325:	je     13b1 <botlish_fn_16+0xf3>
    132b:	mov    rbx,QWORD PTR [rsp+0x20]
    1330:	mov    r12,QWORD PTR [rsp+0x28]
    1335:	mov    r13,QWORD PTR [rsp+0x30]
    133a:	add    rsp,0x40
    133e:	mov    rsp,rbp
    1341:	pop    rbp
    1342:	ret
    1343:	mov    rcx,r13
    1346:	mov    QWORD PTR [rsp+0x10],0x3
    134f:	test   rcx,0x1
    1356:	jne    1364 <botlish_fn_16+0xa6>
    135c:	mov    r13,rcx
    135f:	jmp    1379 <botlish_fn_16+0xbb>
    1364:	mov    rdx,rcx
    1367:	add    rdx,0x2
    136b:	mov    r13,rcx
    136e:	seto   al
    1371:	test   al,al
    1373:	je     138c <botlish_fn_16+0xce>
    1379:	mov    edx,0x3
    137e:	mov    rsi,r13
    1381:	mov    rdi,r12
    1384:	call   1389 <botlish_fn_16+0xcb>
			1385: R_X86_64_PLT32	rt_int_add-0x4
    1389:	mov    rdx,rax
    138c:	mov    QWORD PTR [rsp+0x8],rdx
    1391:	mov    rdi,r12
    1394:	mov    rax,QWORD PTR [rdi+0x10]
    1398:	mov    rcx,QWORD PTR [rax]
    139b:	mov    QWORD PTR [rsp+0x10],rcx
    13a0:	mov    rsi,rbx
    13a3:	call   13a8 <botlish_fn_16+0xea>
			13a4: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_quoted<str, int, str>
    13a8:	test   rax,rax
    13ab:	jne    13cf <botlish_fn_16+0x111>
    13b1:	xor    rdx,rdx
    13b4:	mov    rax,rdx
    13b7:	mov    rbx,QWORD PTR [rsp+0x20]
    13bc:	mov    r12,QWORD PTR [rsp+0x28]
    13c1:	mov    r13,QWORD PTR [rsp+0x30]
    13c6:	add    rsp,0x40
    13ca:	mov    rsp,rbp
    13cd:	pop    rbp
    13ce:	ret
    13cf:	mov    rbx,QWORD PTR [rsp+0x20]
    13d4:	mov    r12,QWORD PTR [rsp+0x28]
    13d9:	mov    r13,QWORD PTR [rsp+0x30]
    13de:	add    rsp,0x40
    13e2:	mov    rsp,rbp
    13e5:	pop    rbp
    13e6:	ret

00000000000013e7 <botlish_entry_16: scan_field<str, int>>:
    13e7:	push   rbp
    13e8:	mov    rbp,rsp
    13eb:	ud2
    13ed:	add    BYTE PTR [rax],al
	...

00000000000013f0 <botlish_fn_17: scan_record_rest<str, int, mutarray, int>>:
    13f0:	push   rbp
    13f1:	mov    rbp,rsp
    13f4:	sub    rsp,0x60
    13f8:	mov    QWORD PTR [rsp+0x30],rbx
    13fd:	mov    QWORD PTR [rsp+0x38],r12
    1402:	mov    QWORD PTR [rsp+0x40],r13
    1407:	mov    QWORD PTR [rsp+0x48],r14
    140c:	mov    QWORD PTR [rsp+0x50],r15
    1411:	mov    r13,rdi
    1414:	mov    QWORD PTR [rsp+0x20],0x0
    141d:	mov    QWORD PTR [rsp],rsi
    1421:	mov    QWORD PTR [rsp+0x8],rdx
    1426:	mov    QWORD PTR [rsp+0x10],rcx
    142b:	mov    QWORD PTR [rsp+0x18],r8
    1430:	mov    rbx,rsi
    1433:	mov    r12,rdx
    1436:	mov    r14,r8
    1439:	mov    r15,rcx
    143c:	mov    rdx,QWORD PTR [rbx+0x8]
    1440:	shl    rdx,1
    1443:	or     rdx,0x1
    1447:	mov    rax,r12
    144a:	and    rax,rdx
    144d:	test   rax,0x1
    1453:	jne    1479 <botlish_fn_17+0x89>
    1459:	mov    rsi,r12
    145c:	mov    rdi,r13
    145f:	call   1464 <botlish_fn_17+0x74>
			1460: R_X86_64_PLT32	rt_int_cmp-0x4
    1464:	mov    ecx,0x2
    1469:	test   rax,rax
    146c:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 16c0 <botlish_fn_17+0x2d0>
    1474:	jmp    148c <botlish_fn_17+0x9c>
    1479:	mov    ecx,0x2
    147e:	mov    rax,r12
    1481:	cmp    rax,rdx
    1484:	cmovl  rcx,QWORD PTR [rip+0x234]        # 16c0 <botlish_fn_17+0x2d0>
    148c:	cmp    rcx,0x6
    1490:	je     14a4 <botlish_fn_17+0xb4>
    1496:	mov    rdx,r14
    1499:	mov    rsi,r15
    149c:	mov    rdi,r13
    149f:	jmp    14da <botlish_fn_17+0xea>
    14a4:	mov    rdx,r12
    14a7:	mov    rsi,rbx
    14aa:	mov    rdi,r13
    14ad:	call   14b2 <botlish_fn_17+0xc2>
			14ae: R_X86_64_PLT32	rt_str_char_at-0x4
    14b2:	test   rax,rax
    14b5:	je     161a <botlish_fn_17+0x22a>
    14bb:	cmp    rax,0x164
    14c1:	je     1599 <botlish_fn_17+0x1a9>
    14c7:	cmp    rax,0x54
    14cb:	je     1510 <botlish_fn_17+0x120>
    14d1:	mov    rdx,r14
    14d4:	mov    rsi,r15
    14d7:	mov    rdi,r13
    14da:	mov    rdi,r13
    14dd:	call   14e2 <botlish_fn_17+0xf2>
			14de: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    14e2:	test   rax,rax
    14e5:	je     161a <botlish_fn_17+0x22a>
    14eb:	mov    rdx,r12
    14ee:	mov    rbx,QWORD PTR [rsp+0x30]
    14f3:	mov    r12,QWORD PTR [rsp+0x38]
    14f8:	mov    r13,QWORD PTR [rsp+0x40]
    14fd:	mov    r14,QWORD PTR [rsp+0x48]
    1502:	mov    r15,QWORD PTR [rsp+0x50]
    1507:	add    rsp,0x60
    150b:	mov    rsp,rbp
    150e:	pop    rbp
    150f:	ret
    1510:	mov    rdx,r14
    1513:	mov    rsi,r15
    1516:	mov    rdi,r13
    1519:	call   151e <botlish_fn_17+0x12e>
			151a: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    151e:	test   rax,rax
    1521:	je     161a <botlish_fn_17+0x22a>
    1527:	mov    QWORD PTR [rsp],rax
    152b:	mov    r14,rax
    152e:	mov    QWORD PTR [rsp+0x10],0x3
    1537:	mov    rdx,r12
    153a:	test   rdx,0x1
    1541:	je     1561 <botlish_fn_17+0x171>
    1547:	mov    rdx,r12
    154a:	add    rdx,0x2
    154e:	seto   al
    1551:	test   al,al
    1553:	jne    1561 <botlish_fn_17+0x171>
    1559:	mov    rax,r14
    155c:	jmp    1577 <botlish_fn_17+0x187>
    1561:	mov    edx,0x3
    1566:	mov    rsi,r12
    1569:	mov    rdi,r13
    156c:	call   1571 <botlish_fn_17+0x181>
			156d: R_X86_64_PLT32	rt_int_add-0x4
    1571:	mov    rdx,rax
    1574:	mov    rax,r14
    1577:	mov    rbx,QWORD PTR [rsp+0x30]
    157c:	mov    r12,QWORD PTR [rsp+0x38]
    1581:	mov    r13,QWORD PTR [rsp+0x40]
    1586:	mov    r14,QWORD PTR [rsp+0x48]
    158b:	mov    r15,QWORD PTR [rsp+0x50]
    1590:	add    rsp,0x60
    1594:	mov    rsp,rbp
    1597:	pop    rbp
    1598:	ret
    1599:	mov    rsi,r12
    159c:	mov    edx,0x3
    15a1:	mov    r12,rdx
    15a4:	mov    QWORD PTR [rsp+0x20],0x3
    15ad:	test   rsi,0x1
    15b4:	je     15cc <botlish_fn_17+0x1dc>
    15ba:	mov    rdx,rsi
    15bd:	add    rdx,0x2
    15c1:	seto   al
    15c4:	test   al,al
    15c6:	je     15da <botlish_fn_17+0x1ea>
    15cc:	mov    rdx,r12
    15cf:	mov    rdi,r13
    15d2:	call   15d7 <botlish_fn_17+0x1e7>
			15d3: R_X86_64_PLT32	rt_int_add-0x4
    15d7:	mov    rdx,rax
    15da:	mov    QWORD PTR [rsp+0x8],rdx
    15df:	mov    rsi,rbx
    15e2:	mov    rdi,r13
    15e5:	call   15ea <botlish_fn_17+0x1fa>
			15e6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    15ea:	test   rax,rax
    15ed:	je     161a <botlish_fn_17+0x22a>
    15f3:	mov    QWORD PTR [rsp+0x8],rax
    15f8:	mov    rcx,rax
    15fb:	mov    QWORD PTR [rsp+0x20],rdx
    1600:	mov    rsi,r15
    1603:	mov    r15,rdx
    1606:	mov    rdx,r14
    1609:	mov    rdi,r13
    160c:	call   1611 <botlish_fn_17+0x221>
			160d: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    1611:	test   rax,rax
    1614:	jne    1642 <botlish_fn_17+0x252>
    161a:	xor    rdx,rdx
    161d:	mov    rax,rdx
    1620:	mov    rbx,QWORD PTR [rsp+0x30]
    1625:	mov    r12,QWORD PTR [rsp+0x38]
    162a:	mov    r13,QWORD PTR [rsp+0x40]
    162f:	mov    r14,QWORD PTR [rsp+0x48]
    1634:	mov    r15,QWORD PTR [rsp+0x50]
    1639:	add    rsp,0x60
    163d:	mov    rsp,rbp
    1640:	pop    rbp
    1641:	ret
    1642:	mov    QWORD PTR [rsp+0x8],rax
    1647:	mov    QWORD PTR [rsp+0x28],rax
    164c:	mov    QWORD PTR [rsp+0x10],0x3
    1655:	mov    rdx,r14
    1658:	test   rdx,0x1
    165f:	jne    1670 <botlish_fn_17+0x280>
    1665:	mov    rdx,r12
    1668:	mov    rsi,r14
    166b:	jmp    168b <botlish_fn_17+0x29b>
    1670:	mov    rdx,r14
    1673:	mov    rax,rdx
    1676:	add    rax,0x2
    167a:	seto   cl
    167d:	test   cl,cl
    167f:	je     1693 <botlish_fn_17+0x2a3>
    1685:	mov    rdx,r12
    1688:	mov    rsi,r14
    168b:	mov    rdi,r13
    168e:	call   1693 <botlish_fn_17+0x2a3>
			168f: R_X86_64_PLT32	rt_int_add-0x4
    1693:	mov    QWORD PTR [rsp],rbx
    1697:	mov    rdx,r15
    169a:	mov    QWORD PTR [rsp+0x8],rdx
    169f:	mov    rcx,QWORD PTR [rsp+0x28]
    16a4:	mov    QWORD PTR [rsp+0x10],rcx
    16a9:	mov    QWORD PTR [rsp+0x18],rax
    16ae:	mov    r12,rdx
    16b1:	mov    r14,rax
    16b4:	mov    r15,rcx
    16b7:	jmp    143c <botlish_fn_17+0x4c>
    16bc:	add    BYTE PTR [rax],al
    16be:	add    BYTE PTR [rax],al
    16c0:	(bad)
    16c1:	add    BYTE PTR [rax],al
    16c3:	add    BYTE PTR [rax],al
    16c5:	add    BYTE PTR [rax],al
	...

00000000000016c8 <botlish_entry_17: scan_record_rest<str, int, mutarray, int>>:
    16c8:	push   rbp
    16c9:	mov    rbp,rsp
    16cc:	ud2

00000000000016ce <botlish_fn_18: scan_record<str, int>>:
    16ce:	push   rbp
    16cf:	mov    rbp,rsp
    16d2:	sub    rsp,0x40
    16d6:	mov    QWORD PTR [rsp+0x20],rbx
    16db:	mov    QWORD PTR [rsp+0x28],r12
    16e0:	mov    QWORD PTR [rsp+0x30],r14
    16e5:	mov    r14,rdi
    16e8:	mov    QWORD PTR [rsp+0x10],0x0
    16f1:	mov    QWORD PTR [rsp+0x18],0x0
    16fa:	mov    QWORD PTR [rsp],rsi
    16fe:	mov    r12,rsi
    1701:	mov    QWORD PTR [rsp+0x8],rdx
    1706:	mov    rsi,r12
    1709:	mov    rdi,r14
    170c:	call   1711 <botlish_fn_18+0x43>
			170d: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    1711:	test   rax,rax
    1714:	je     1769 <botlish_fn_18+0x9b>
    171a:	mov    QWORD PTR [rsp+0x8],rax
    171f:	mov    rsi,rax
    1722:	mov    QWORD PTR [rsp+0x10],rdx
    1727:	mov    rbx,rdx
    172a:	mov    rdi,r14
    172d:	call   1732 <botlish_fn_18+0x64>
			172e: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    1732:	test   rax,rax
    1735:	je     1769 <botlish_fn_18+0x9b>
    173b:	mov    QWORD PTR [rsp+0x8],rax
    1740:	mov    rcx,rax
    1743:	mov    r8d,0x3
    1749:	mov    QWORD PTR [rsp+0x18],0x3
    1752:	mov    rdx,rbx
    1755:	mov    rsi,r12
    1758:	mov    rdi,r14
    175b:	call   1760 <botlish_fn_18+0x92>
			175c: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record_rest<str, int, mutarray, int>
    1760:	test   rax,rax
    1763:	jne    1787 <botlish_fn_18+0xb9>
    1769:	xor    rdx,rdx
    176c:	mov    rax,rdx
    176f:	mov    rbx,QWORD PTR [rsp+0x20]
    1774:	mov    r12,QWORD PTR [rsp+0x28]
    1779:	mov    r14,QWORD PTR [rsp+0x30]
    177e:	add    rsp,0x40
    1782:	mov    rsp,rbp
    1785:	pop    rbp
    1786:	ret
    1787:	mov    rbx,QWORD PTR [rsp+0x20]
    178c:	mov    r12,QWORD PTR [rsp+0x28]
    1791:	mov    r14,QWORD PTR [rsp+0x30]
    1796:	add    rsp,0x40
    179a:	mov    rsp,rbp
    179d:	pop    rbp
    179e:	ret

000000000000179f <botlish_entry_18: scan_record<str, int>>:
    179f:	push   rbp
    17a0:	mov    rbp,rsp
    17a3:	ud2
    17a5:	add    BYTE PTR [rax],al
	...

00000000000017a8 <botlish_fn_19: scan_records<str, int, mutarray, int>>:
    17a8:	push   rbp
    17a9:	mov    rbp,rsp
    17ac:	sub    rsp,0x60
    17b0:	mov    QWORD PTR [rsp+0x30],rbx
    17b5:	mov    QWORD PTR [rsp+0x38],r12
    17ba:	mov    QWORD PTR [rsp+0x40],r13
    17bf:	mov    QWORD PTR [rsp+0x48],r14
    17c4:	mov    QWORD PTR [rsp+0x50],r15
    17c9:	mov    r13,rdi
    17cc:	mov    QWORD PTR [rsp+0x20],0x0
    17d5:	mov    QWORD PTR [rsp],rsi
    17d9:	mov    QWORD PTR [rsp+0x8],rdx
    17de:	mov    rax,rdx
    17e1:	mov    QWORD PTR [rsp+0x10],rcx
    17e6:	mov    QWORD PTR [rsp+0x18],r8
    17eb:	mov    rbx,rsi
    17ee:	mov    r14,r8
    17f1:	mov    r15,rcx
    17f4:	mov    rdx,QWORD PTR [rbx+0x8]
    17f8:	shl    rdx,1
    17fb:	or     rdx,0x1
    17ff:	mov    r12,rax
    1802:	and    rax,rdx
    1805:	test   rax,0x1
    180b:	jne    1831 <botlish_fn_19+0x89>
    1811:	mov    rsi,r12
    1814:	mov    rdi,r13
    1817:	call   181c <botlish_fn_19+0x74>
			1818: R_X86_64_PLT32	rt_int_cmp-0x4
    181c:	mov    ecx,0x2
    1821:	test   rax,rax
    1824:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1958 <botlish_fn_19+0x1b0>
    182c:	jmp    1841 <botlish_fn_19+0x99>
    1831:	mov    ecx,0x2
    1836:	cmp    r12,rdx
    1839:	cmovge rcx,QWORD PTR [rip+0x117]        # 1958 <botlish_fn_19+0x1b0>
    1841:	cmp    rcx,0x6
    1845:	je     18f3 <botlish_fn_19+0x14b>
    184b:	mov    rdx,r12
    184e:	mov    rsi,rbx
    1851:	mov    rdi,r13
    1854:	call   1859 <botlish_fn_19+0xb1>
			1855: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    1859:	test   rax,rax
    185c:	je     190a <botlish_fn_19+0x162>
    1862:	mov    QWORD PTR [rsp+0x8],rax
    1867:	mov    rcx,rax
    186a:	mov    QWORD PTR [rsp+0x20],rdx
    186f:	mov    rsi,r15
    1872:	mov    r12,rdx
    1875:	mov    rdx,r14
    1878:	mov    rdi,r13
    187b:	call   1880 <botlish_fn_19+0xd8>
			187c: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1880:	test   rax,rax
    1883:	je     190a <botlish_fn_19+0x162>
    1889:	mov    QWORD PTR [rsp+0x8],rax
    188e:	mov    r15,rax
    1891:	mov    QWORD PTR [rsp+0x10],0x3
    189a:	mov    rsi,r14
    189d:	test   rsi,0x1
    18a4:	je     18bf <botlish_fn_19+0x117>
    18aa:	mov    rsi,r14
    18ad:	mov    rax,rsi
    18b0:	add    rax,0x2
    18b4:	seto   cl
    18b7:	test   cl,cl
    18b9:	je     18cf <botlish_fn_19+0x127>
    18bf:	mov    edx,0x3
    18c4:	mov    rsi,r14
    18c7:	mov    rdi,r13
    18ca:	call   18cf <botlish_fn_19+0x127>
			18cb: R_X86_64_PLT32	rt_int_add-0x4
    18cf:	mov    QWORD PTR [rsp],rbx
    18d3:	mov    rdx,r12
    18d6:	mov    QWORD PTR [rsp+0x8],rdx
    18db:	mov    rcx,r15
    18de:	mov    QWORD PTR [rsp+0x10],rcx
    18e3:	mov    QWORD PTR [rsp+0x18],rax
    18e8:	mov    r14,rax
    18eb:	mov    rax,rdx
    18ee:	jmp    17f4 <botlish_fn_19+0x4c>
    18f3:	mov    rdx,r14
    18f6:	mov    rsi,r15
    18f9:	mov    rdi,r13
    18fc:	call   1901 <botlish_fn_19+0x159>
			18fd: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    1901:	test   rax,rax
    1904:	jne    192f <botlish_fn_19+0x187>
    190a:	xor    rax,rax
    190d:	mov    rbx,QWORD PTR [rsp+0x30]
    1912:	mov    r12,QWORD PTR [rsp+0x38]
    1917:	mov    r13,QWORD PTR [rsp+0x40]
    191c:	mov    r14,QWORD PTR [rsp+0x48]
    1921:	mov    r15,QWORD PTR [rsp+0x50]
    1926:	add    rsp,0x60
    192a:	mov    rsp,rbp
    192d:	pop    rbp
    192e:	ret
    192f:	mov    rbx,QWORD PTR [rsp+0x30]
    1934:	mov    r12,QWORD PTR [rsp+0x38]
    1939:	mov    r13,QWORD PTR [rsp+0x40]
    193e:	mov    r14,QWORD PTR [rsp+0x48]
    1943:	mov    r15,QWORD PTR [rsp+0x50]
    1948:	add    rsp,0x60
    194c:	mov    rsp,rbp
    194f:	pop    rbp
    1950:	ret
    1951:	add    BYTE PTR [rax],al
    1953:	add    BYTE PTR [rax],al
    1955:	add    BYTE PTR [rax],al
    1957:	add    BYTE PTR [rsi],al
    1959:	add    BYTE PTR [rax],al
    195b:	add    BYTE PTR [rax],al
    195d:	add    BYTE PTR [rax],al
	...

0000000000001960 <botlish_entry_19: scan_records<str, int, mutarray, int>>:
    1960:	push   rbp
    1961:	mov    rbp,rsp
    1964:	mov    rsi,QWORD PTR [rdx]
    1967:	mov    r9,QWORD PTR [rdx+0x8]
    196b:	mov    rcx,QWORD PTR [rdx+0x10]
    196f:	mov    r8,QWORD PTR [rdx+0x18]
    1973:	mov    rdx,r9
    1976:	call   197b <botlish_entry_19+0x1b>
			1977: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    197b:	mov    rsp,rbp
    197e:	pop    rbp
    197f:	ret

0000000000001980 <botlish_fn_20: csv_parse<str>>:
    1980:	push   rbp
    1981:	mov    rbp,rsp
    1984:	sub    rsp,0x40
    1988:	mov    QWORD PTR [rsp+0x20],rbx
    198d:	mov    QWORD PTR [rsp+0x28],r12
    1992:	mov    QWORD PTR [rsp+0x30],r13
    1997:	mov    rbx,rdi
    199a:	mov    QWORD PTR [rsp+0x8],0x0
    19a3:	mov    QWORD PTR [rsp+0x10],0x0
    19ac:	mov    QWORD PTR [rsp+0x18],0x0
    19b5:	mov    QWORD PTR [rsp],rsi
    19b9:	mov    rax,QWORD PTR [rsi+0x8]
    19bd:	mov    r12,rsi
    19c0:	shl    rax,1
    19c3:	or     rax,0x1
    19c7:	sar    rax,1
    19ca:	test   rax,rax
    19cd:	je     1a5c <botlish_fn_20+0xdc>
    19d3:	mov    edx,0x1
    19d8:	mov    QWORD PTR [rsp+0x8],0x1
    19e1:	mov    rsi,r12
    19e4:	mov    rdi,rbx
    19e7:	call   19ec <botlish_fn_20+0x6c>
			19e8: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    19ec:	test   rax,rax
    19ef:	je     1a73 <botlish_fn_20+0xf3>
    19f5:	mov    QWORD PTR [rsp+0x8],rax
    19fa:	mov    rsi,rax
    19fd:	mov    QWORD PTR [rsp+0x10],rdx
    1a02:	mov    r13,rdx
    1a05:	mov    rdi,rbx
    1a08:	call   1a0d <botlish_fn_20+0x8d>
			1a09: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    1a0d:	test   rax,rax
    1a10:	je     1a73 <botlish_fn_20+0xf3>
    1a16:	mov    QWORD PTR [rsp+0x8],rax
    1a1b:	mov    rcx,rax
    1a1e:	mov    r8d,0x3
    1a24:	mov    QWORD PTR [rsp+0x18],0x3
    1a2d:	mov    rdx,r13
    1a30:	mov    rsi,r12
    1a33:	mov    rdi,rbx
    1a36:	call   1a3b <botlish_fn_20+0xbb>
			1a37: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    1a3b:	test   rax,rax
    1a3e:	je     1a73 <botlish_fn_20+0xf3>
    1a44:	mov    rbx,QWORD PTR [rsp+0x20]
    1a49:	mov    r12,QWORD PTR [rsp+0x28]
    1a4e:	mov    r13,QWORD PTR [rsp+0x30]
    1a53:	add    rsp,0x40
    1a57:	mov    rsp,rbp
    1a5a:	pop    rbp
    1a5b:	ret
    1a5c:	xor    rdx,rdx
    1a5f:	mov    rdi,rbx
    1a62:	mov    rsi,rdx
    1a65:	call   1a6a <botlish_fn_20+0xea>
			1a66: R_X86_64_PLT32	rt_list_new-0x4
    1a6a:	test   rax,rax
    1a6d:	jne    1a8e <botlish_fn_20+0x10e>
    1a73:	xor    rax,rax
    1a76:	mov    rbx,QWORD PTR [rsp+0x20]
    1a7b:	mov    r12,QWORD PTR [rsp+0x28]
    1a80:	mov    r13,QWORD PTR [rsp+0x30]
    1a85:	add    rsp,0x40
    1a89:	mov    rsp,rbp
    1a8c:	pop    rbp
    1a8d:	ret
    1a8e:	mov    rbx,QWORD PTR [rsp+0x20]
    1a93:	mov    r12,QWORD PTR [rsp+0x28]
    1a98:	mov    r13,QWORD PTR [rsp+0x30]
    1a9d:	add    rsp,0x40
    1aa1:	mov    rsp,rbp
    1aa4:	pop    rbp
    1aa5:	ret

0000000000001aa6 <botlish_entry_20: csv_parse<str>>:
    1aa6:	push   rbp
    1aa7:	mov    rbp,rsp
    1aaa:	mov    rsi,QWORD PTR [rdx]
    1aad:	call   1ab2 <botlish_entry_20+0xc>
			1aae: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    1ab2:	mov    rsp,rbp
    1ab5:	pop    rbp
    1ab6:	ret

0000000000001ab7 <botlish_fn_21: ht_alloc<int>>:
    1ab7:	push   rbp
    1ab8:	mov    rbp,rsp
    1abb:	sub    rsp,0x70
    1abf:	mov    QWORD PTR [rsp+0x40],rbx
    1ac4:	mov    QWORD PTR [rsp+0x48],r12
    1ac9:	mov    QWORD PTR [rsp+0x50],r13
    1ace:	mov    QWORD PTR [rsp+0x58],r14
    1ad3:	mov    QWORD PTR [rsp+0x60],r15
    1ad8:	mov    r12,rdi
    1adb:	mov    QWORD PTR [rsp+0x10],0x0
    1ae4:	mov    QWORD PTR [rsp+0x18],0x0
    1aed:	mov    QWORD PTR [rsp],rsi
    1af1:	mov    r13,rsi
    1af4:	mov    esi,0x5
    1af9:	mov    QWORD PTR [rsp+0x8],0x5
    1b02:	mov    rdi,r12
    1b05:	call   1b0a <botlish_fn_21+0x53>
			1b06: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b0a:	mov    rcx,rax
    1b0d:	mov    rbx,rax
    1b10:	test   rax,rcx
    1b13:	je     1bac <botlish_fn_21+0xf5>
    1b19:	mov    rax,rbx
    1b1c:	mov    QWORD PTR [rsp+0x8],rax
    1b21:	mov    rcx,QWORD PTR [rax+0x18]
    1b25:	test   rcx,rcx
    1b28:	je     1c29 <botlish_fn_21+0x172>
    1b2e:	mov    rcx,QWORD PTR [rbx+0x10]
    1b32:	mov    QWORD PTR [rcx],0x1
    1b39:	mov    rcx,QWORD PTR [rbx+0x18]
    1b3d:	test   rcx,rcx
    1b40:	je     1c41 <botlish_fn_21+0x18a>
    1b46:	mov    rax,QWORD PTR [rbx+0x10]
    1b4a:	mov    QWORD PTR [rax+0x8],0x1
    1b52:	mov    edx,0x1
    1b57:	mov    QWORD PTR [rsp+0x10],0x1
    1b60:	mov    rsi,r13
    1b63:	mov    rdi,r12
    1b66:	call   1b6b <botlish_fn_21+0xb4>
			1b67: R_X86_64_PLT32	rt_mutarray_create-0x4
    1b6b:	test   rax,rax
    1b6e:	je     1bac <botlish_fn_21+0xf5>
    1b74:	mov    QWORD PTR [rsp+0x10],rax
    1b79:	mov    r14,rax
    1b7c:	mov    rsi,r13
    1b7f:	mov    rdi,r12
    1b82:	call   1b87 <botlish_fn_21+0xd0>
			1b83: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b87:	test   rax,rax
    1b8a:	je     1bac <botlish_fn_21+0xf5>
    1b90:	mov    QWORD PTR [rsp+0x18],rax
    1b95:	mov    rsi,r13
    1b98:	mov    r15,rax
    1b9b:	mov    rdi,r12
    1b9e:	call   1ba3 <botlish_fn_21+0xec>
			1b9f: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1ba3:	test   rax,rax
    1ba6:	jne    1bd1 <botlish_fn_21+0x11a>
    1bac:	xor    rax,rax
    1baf:	mov    rbx,QWORD PTR [rsp+0x40]
    1bb4:	mov    r12,QWORD PTR [rsp+0x48]
    1bb9:	mov    r13,QWORD PTR [rsp+0x50]
    1bbe:	mov    r14,QWORD PTR [rsp+0x58]
    1bc3:	mov    r15,QWORD PTR [rsp+0x60]
    1bc8:	add    rsp,0x70
    1bcc:	mov    rsp,rbp
    1bcf:	pop    rbp
    1bd0:	ret
    1bd1:	mov    QWORD PTR [rsp],rax
    1bd5:	lea    rcx,[rsp+0x20]
    1bda:	mov    rdx,r14
    1bdd:	mov    QWORD PTR [rsp+0x20],rdx
    1be2:	mov    rdx,r15
    1be5:	mov    QWORD PTR [rsp+0x28],rdx
    1bea:	mov    QWORD PTR [rsp+0x30],rax
    1bef:	mov    rax,rbx
    1bf2:	mov    QWORD PTR [rsp+0x38],rax
    1bf7:	xor    rsi,rsi
    1bfa:	mov    edx,0x4
    1bff:	mov    rdi,r12
    1c02:	call   1c07 <botlish_fn_21+0x150>
			1c03: R_X86_64_PLT32	rt_struct_new-0x4
    1c07:	mov    rbx,QWORD PTR [rsp+0x40]
    1c0c:	mov    r12,QWORD PTR [rsp+0x48]
    1c11:	mov    r13,QWORD PTR [rsp+0x50]
    1c16:	mov    r14,QWORD PTR [rsp+0x58]
    1c1b:	mov    r15,QWORD PTR [rsp+0x60]
    1c20:	add    rsp,0x70
    1c24:	mov    rsp,rbp
    1c27:	pop    rbp
    1c28:	ret
    1c29:	mov    ecx,0x1
    1c2e:	mov    rsi,rbx
    1c31:	mov    rdi,r12
    1c34:	mov    rdx,rcx
    1c37:	call   1c3c <botlish_fn_21+0x185>
			1c38: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1c3c:	jmp    1b39 <botlish_fn_21+0x82>
    1c41:	mov    edx,0x3
    1c46:	mov    ecx,0x1
    1c4b:	mov    rsi,rbx
    1c4e:	mov    rdi,r12
    1c51:	call   1c56 <botlish_fn_21+0x19f>
			1c52: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1c56:	jmp    1b52 <botlish_fn_21+0x9b>

0000000000001c5b <botlish_entry_21: ht_alloc<int>>:
    1c5b:	push   rbp
    1c5c:	mov    rbp,rsp
    1c5f:	mov    rsi,QWORD PTR [rdx]
    1c62:	call   1c67 <botlish_entry_21+0xc>
			1c63: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1c67:	mov    rsp,rbp
    1c6a:	pop    rbp
    1c6b:	ret

0000000000001c6c <botlish_fn_22: ht_alloc<int>>:
    1c6c:	push   rbp
    1c6d:	mov    rbp,rsp
    1c70:	sub    rsp,0x60
    1c74:	mov    QWORD PTR [rsp+0x30],rbx
    1c79:	mov    QWORD PTR [rsp+0x38],r12
    1c7e:	mov    QWORD PTR [rsp+0x40],r13
    1c83:	mov    QWORD PTR [rsp+0x48],r14
    1c88:	mov    QWORD PTR [rsp+0x50],r15
    1c8d:	mov    r12,rdx
    1c90:	mov    r14,rdi
    1c93:	mov    QWORD PTR [rsp+0x10],0x0
    1c9c:	mov    QWORD PTR [rsp+0x18],0x0
    1ca5:	mov    QWORD PTR [rsp],rsi
    1ca9:	mov    r13,rsi
    1cac:	mov    esi,0x5
    1cb1:	mov    QWORD PTR [rsp+0x8],0x5
    1cba:	mov    rdi,r14
    1cbd:	call   1cc2 <botlish_fn_22+0x56>
			1cbe: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1cc2:	mov    rcx,rax
    1cc5:	mov    rbx,rax
    1cc8:	test   rax,rcx
    1ccb:	je     1d66 <botlish_fn_22+0xfa>
    1cd1:	mov    rax,rbx
    1cd4:	mov    QWORD PTR [rsp+0x8],rax
    1cd9:	mov    rcx,QWORD PTR [rax+0x18]
    1cdd:	test   rcx,rcx
    1ce0:	je     1dc6 <botlish_fn_22+0x15a>
    1ce6:	mov    rcx,QWORD PTR [rbx+0x10]
    1cea:	mov    QWORD PTR [rcx],0x1
    1cf1:	mov    rcx,QWORD PTR [rbx+0x18]
    1cf5:	test   rcx,rcx
    1cf8:	je     1dde <botlish_fn_22+0x172>
    1cfe:	mov    rax,QWORD PTR [rbx+0x10]
    1d02:	mov    QWORD PTR [rax+0x8],0x1
    1d0a:	mov    edx,0x1
    1d0f:	mov    QWORD PTR [rsp+0x10],0x1
    1d18:	mov    rsi,r13
    1d1b:	mov    rdi,r14
    1d1e:	call   1d23 <botlish_fn_22+0xb7>
			1d1f: R_X86_64_PLT32	rt_mutarray_create-0x4
    1d23:	test   rax,rax
    1d26:	je     1d66 <botlish_fn_22+0xfa>
    1d2c:	mov    QWORD PTR [rsp+0x10],rax
    1d31:	mov    r15,rax
    1d34:	mov    rsi,r13
    1d37:	mov    rdi,r14
    1d3a:	call   1d3f <botlish_fn_22+0xd3>
			1d3b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d3f:	test   rax,rax
    1d42:	je     1d66 <botlish_fn_22+0xfa>
    1d48:	mov    QWORD PTR [rsp+0x18],rax
    1d4d:	mov    rsi,r13
    1d50:	mov    rdi,r14
    1d53:	mov    QWORD PTR [rsp+0x20],rax
    1d58:	call   1d5d <botlish_fn_22+0xf1>
			1d59: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d5d:	test   rax,rax
    1d60:	jne    1d8b <botlish_fn_22+0x11f>
    1d66:	xor    rax,rax
    1d69:	mov    rbx,QWORD PTR [rsp+0x30]
    1d6e:	mov    r12,QWORD PTR [rsp+0x38]
    1d73:	mov    r13,QWORD PTR [rsp+0x40]
    1d78:	mov    r14,QWORD PTR [rsp+0x48]
    1d7d:	mov    r15,QWORD PTR [rsp+0x50]
    1d82:	add    rsp,0x60
    1d86:	mov    rsp,rbp
    1d89:	pop    rbp
    1d8a:	ret
    1d8b:	mov    rcx,QWORD PTR [rsp+0x20]
    1d90:	mov    rdx,r12
    1d93:	mov    QWORD PTR [rdx],rcx
    1d96:	mov    QWORD PTR [rdx+0x8],rax
    1d9a:	mov    rax,rbx
    1d9d:	mov    QWORD PTR [rdx+0x10],rax
    1da1:	mov    rax,r15
    1da4:	mov    rbx,QWORD PTR [rsp+0x30]
    1da9:	mov    r12,QWORD PTR [rsp+0x38]
    1dae:	mov    r13,QWORD PTR [rsp+0x40]
    1db3:	mov    r14,QWORD PTR [rsp+0x48]
    1db8:	mov    r15,QWORD PTR [rsp+0x50]
    1dbd:	add    rsp,0x60
    1dc1:	mov    rsp,rbp
    1dc4:	pop    rbp
    1dc5:	ret
    1dc6:	mov    ecx,0x1
    1dcb:	mov    rsi,rbx
    1dce:	mov    rdi,r14
    1dd1:	mov    rdx,rcx
    1dd4:	call   1dd9 <botlish_fn_22+0x16d>
			1dd5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1dd9:	jmp    1cf1 <botlish_fn_22+0x85>
    1dde:	mov    edx,0x3
    1de3:	mov    ecx,0x1
    1de8:	mov    rsi,rbx
    1deb:	mov    rdi,r14
    1dee:	call   1df3 <botlish_fn_22+0x187>
			1def: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1df3:	jmp    1d0a <botlish_fn_22+0x9e>

0000000000001df8 <botlish_entry_22: ht_alloc<int>>:
    1df8:	push   rbp
    1df9:	mov    rbp,rsp
    1dfc:	ud2

0000000000001dfe <botlish_fn_23: ht_new<generic>>:
    1dfe:	push   rbp
    1dff:	mov    rbp,rsp
    1e02:	sub    rsp,0x10
    1e06:	mov    esi,0x11
    1e0b:	mov    QWORD PTR [rsp],0x11
    1e13:	call   1e18 <botlish_fn_23+0x1a>
			1e14: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1e18:	test   rax,rax
    1e1b:	jne    1e2d <botlish_fn_23+0x2f>
    1e21:	xor    rax,rax
    1e24:	add    rsp,0x10
    1e28:	mov    rsp,rbp
    1e2b:	pop    rbp
    1e2c:	ret
    1e2d:	add    rsp,0x10
    1e31:	mov    rsp,rbp
    1e34:	pop    rbp
    1e35:	ret

0000000000001e36 <botlish_entry_23: ht_new<generic>>:
    1e36:	push   rbp
    1e37:	mov    rbp,rsp
    1e3a:	call   1e3f <botlish_entry_23+0x9>
			1e3b: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    1e3f:	mov    rsp,rbp
    1e42:	pop    rbp
    1e43:	ret
    1e44:	add    BYTE PTR [rax],al
	...

0000000000001e48 <botlish_fn_24: ht_capacity_for<int, int>>:
    1e48:	push   rbp
    1e49:	mov    rbp,rsp
    1e4c:	sub    rsp,0x50
    1e50:	mov    QWORD PTR [rsp+0x20],rbx
    1e55:	mov    QWORD PTR [rsp+0x28],r12
    1e5a:	mov    QWORD PTR [rsp+0x30],r13
    1e5f:	mov    QWORD PTR [rsp+0x38],r14
    1e64:	mov    QWORD PTR [rsp+0x40],r15
    1e69:	mov    r13,rdi
    1e6c:	mov    QWORD PTR [rsp],rdx
    1e70:	mov    rbx,rsi
    1e73:	or     rbx,0x1
    1e77:	sar    rbx,1
    1e7a:	mov    r12,rsi
    1e7d:	mov    r14,rdx
    1e80:	mov    rax,r12
    1e83:	or     rax,0x1
    1e87:	mov    QWORD PTR [rsp+0x8],rax
    1e8c:	mov    QWORD PTR [rsp+0x10],0x7
    1e95:	mov    rax,rbx
    1e98:	imul   QWORD PTR [rip+0x159]        # 1ff8 <botlish_fn_24+0x1b0>
    1e9f:	seto   cl
    1ea2:	or     rax,0x1
    1ea6:	test   cl,cl
    1ea8:	jne    1eb6 <botlish_fn_24+0x6e>
    1eae:	mov    rsi,rax
    1eb1:	jmp    1ecd <botlish_fn_24+0x85>
    1eb6:	mov    rsi,r12
    1eb9:	or     rsi,0x1
    1ebd:	mov    edx,0x7
    1ec2:	mov    rdi,r13
    1ec5:	call   1eca <botlish_fn_24+0x82>
			1ec6: R_X86_64_PLT32	rt_int_mul-0x4
    1eca:	mov    rsi,rax
    1ecd:	mov    QWORD PTR [rsp+0x8],rsi
    1ed2:	mov    r15,rsi
    1ed5:	mov    QWORD PTR [rsp+0x10],0x5
    1ede:	mov    rsi,r14
    1ee1:	test   rsi,0x1
    1ee8:	je     1f18 <botlish_fn_24+0xd0>
    1eee:	mov    rsi,r14
    1ef1:	mov    rax,rsi
    1ef4:	sar    rax,1
    1ef7:	imul   QWORD PTR [rip+0x102]        # 2000 <botlish_fn_24+0x1b8>
    1efe:	seto   cl
    1f01:	or     rax,0x1
    1f05:	test   cl,cl
    1f07:	jne    1f18 <botlish_fn_24+0xd0>
    1f0d:	mov    rdx,rax
    1f10:	mov    rsi,r15
    1f13:	jmp    1f2e <botlish_fn_24+0xe6>
    1f18:	mov    edx,0x5
    1f1d:	mov    rsi,r14
    1f20:	mov    rdi,r13
    1f23:	call   1f28 <botlish_fn_24+0xe0>
			1f24: R_X86_64_PLT32	rt_int_mul-0x4
    1f28:	mov    rdx,rax
    1f2b:	mov    rsi,r15
    1f2e:	mov    rax,rsi
    1f31:	and    rax,rdx
    1f34:	test   rax,0x1
    1f3a:	jne    1f5d <botlish_fn_24+0x115>
    1f40:	mov    rdi,r13
    1f43:	call   1f48 <botlish_fn_24+0x100>
			1f44: R_X86_64_PLT32	rt_int_cmp-0x4
    1f48:	mov    ecx,0x2
    1f4d:	test   rax,rax
    1f50:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1ff8 <botlish_fn_24+0x1b0>
    1f58:	jmp    1f6d <botlish_fn_24+0x125>
    1f5d:	mov    ecx,0x2
    1f62:	cmp    rsi,rdx
    1f65:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1ff8 <botlish_fn_24+0x1b0>
    1f6d:	cmp    rcx,0x6
    1f71:	je     1fcd <botlish_fn_24+0x185>
    1f77:	mov    QWORD PTR [rsp+0x8],0x5
    1f80:	mov    rsi,r14
    1f83:	test   rsi,0x1
    1f8a:	je     1fb1 <botlish_fn_24+0x169>
    1f90:	mov    rsi,r14
    1f93:	mov    rax,rsi
    1f96:	sar    rax,1
    1f99:	imul   QWORD PTR [rip+0x60]        # 2000 <botlish_fn_24+0x1b8>
    1fa0:	seto   sil
    1fa4:	or     rax,0x1
    1fa8:	test   sil,sil
    1fab:	je     1fc1 <botlish_fn_24+0x179>
    1fb1:	mov    edx,0x5
    1fb6:	mov    rsi,r14
    1fb9:	mov    rdi,r13
    1fbc:	call   1fc1 <botlish_fn_24+0x179>
			1fbd: R_X86_64_PLT32	rt_int_mul-0x4
    1fc1:	mov    QWORD PTR [rsp],rax
    1fc5:	mov    r14,rax
    1fc8:	jmp    1e80 <botlish_fn_24+0x38>
    1fcd:	mov    rax,r14
    1fd0:	mov    rbx,QWORD PTR [rsp+0x20]
    1fd5:	mov    r12,QWORD PTR [rsp+0x28]
    1fda:	mov    r13,QWORD PTR [rsp+0x30]
    1fdf:	mov    r14,QWORD PTR [rsp+0x38]
    1fe4:	mov    r15,QWORD PTR [rsp+0x40]
    1fe9:	add    rsp,0x50
    1fed:	mov    rsp,rbp
    1ff0:	pop    rbp
    1ff1:	ret
    1ff2:	add    BYTE PTR [rax],al
    1ff4:	add    BYTE PTR [rax],al
    1ff6:	add    BYTE PTR [rax],al
    1ff8:	(bad)
    1ff9:	add    BYTE PTR [rax],al
    1ffb:	add    BYTE PTR [rax],al
    1ffd:	add    BYTE PTR [rax],al
    1fff:	add    BYTE PTR [rax+rax*1],al
    2002:	add    BYTE PTR [rax],al
    2004:	add    BYTE PTR [rax],al
	...

0000000000002008 <botlish_entry_24: ht_capacity_for<int, int>>:
    2008:	push   rbp
    2009:	mov    rbp,rsp
    200c:	mov    rsi,QWORD PTR [rdx]
    200f:	mov    rdx,QWORD PTR [rdx+0x8]
    2013:	call   2018 <botlish_entry_24+0x10>
			2014: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    2018:	mov    rsp,rbp
    201b:	pop    rbp
    201c:	ret

000000000000201d <botlish_fn_25: ht_new_sized<int>>:
    201d:	push   rbp
    201e:	mov    rbp,rsp
    2021:	sub    rsp,0x20
    2025:	mov    QWORD PTR [rsp+0x10],r12
    202a:	mov    r12,rdi
    202d:	mov    QWORD PTR [rsp],rsi
    2031:	mov    edx,0x11
    2036:	mov    QWORD PTR [rsp+0x8],0x11
    203f:	mov    rdi,r12
    2042:	call   2047 <botlish_fn_25+0x2a>
			2043: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    2047:	mov    QWORD PTR [rsp],rax
    204b:	mov    rsi,rax
    204e:	mov    rdi,r12
    2051:	call   2056 <botlish_fn_25+0x39>
			2052: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2056:	test   rax,rax
    2059:	jne    2070 <botlish_fn_25+0x53>
    205f:	xor    rax,rax
    2062:	mov    r12,QWORD PTR [rsp+0x10]
    2067:	add    rsp,0x20
    206b:	mov    rsp,rbp
    206e:	pop    rbp
    206f:	ret
    2070:	mov    r12,QWORD PTR [rsp+0x10]
    2075:	add    rsp,0x20
    2079:	mov    rsp,rbp
    207c:	pop    rbp
    207d:	ret

000000000000207e <botlish_entry_25: ht_new_sized<int>>:
    207e:	push   rbp
    207f:	mov    rbp,rsp
    2082:	mov    rsi,QWORD PTR [rdx]
    2085:	call   208a <botlish_entry_25+0xc>
			2086: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    208a:	mov    rsp,rbp
    208d:	pop    rbp
    208e:	ret

000000000000208f <botlish_fn_26: ht_size<HashTable>>:
    208f:	push   rbp
    2090:	mov    rbp,rsp
    2093:	mov    rax,QWORD PTR [rsi+0x18]
    2097:	mov    rsi,QWORD PTR [rax+0x18]
    209b:	mov    rax,QWORD PTR [rsi+0x8]
    209f:	test   rax,rax
    20a2:	jne    20ba <botlish_fn_26+0x2b>
    20a8:	jmp    20c6 <botlish_fn_26+0x37>
    20ad:	xor    rax,rax
    20b0:	mov    rsp,rbp
    20b3:	pop    rbp
    20b4:	ret
    20b5:	jmp    20c1 <botlish_fn_26+0x32>
    20ba:	mov    rax,QWORD PTR [rsi+0x10]
    20be:	mov    rax,QWORD PTR [rax]
    20c1:	mov    rsp,rbp
    20c4:	pop    rbp
    20c5:	ret
    20c6:	mov    edx,0x1
    20cb:	call   20d0 <botlish_fn_26+0x41>
			20cc: R_X86_64_PLT32	rt_mutarray_get-0x4
    20d0:	test   rax,rax
    20d3:	jne    20c1 <botlish_fn_26+0x32>
    20d9:	jmp    20ad <botlish_fn_26+0x1e>

00000000000020de <botlish_entry_26: ht_size<HashTable>>:
    20de:	push   rbp
    20df:	mov    rbp,rsp
    20e2:	mov    rsi,QWORD PTR [rdx]
    20e5:	call   20ea <botlish_entry_26+0xc>
			20e6: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    20ea:	mov    rsp,rbp
    20ed:	pop    rbp
    20ee:	ret

00000000000020ef <botlish_fn_27: ht_tombstones<HashTable>>:
    20ef:	push   rbp
    20f0:	mov    rbp,rsp
    20f3:	mov    rax,QWORD PTR [rsi+0x18]
    20f7:	mov    rsi,QWORD PTR [rax+0x18]
    20fb:	mov    rax,QWORD PTR [rsi+0x8]
    20ff:	cmp    rax,0x1
    2103:	ja     211b <botlish_fn_27+0x2c>
    2109:	jmp    2128 <botlish_fn_27+0x39>
    210e:	xor    rax,rax
    2111:	mov    rsp,rbp
    2114:	pop    rbp
    2115:	ret
    2116:	jmp    2123 <botlish_fn_27+0x34>
    211b:	mov    rax,QWORD PTR [rsi+0x10]
    211f:	mov    rax,QWORD PTR [rax+0x8]
    2123:	mov    rsp,rbp
    2126:	pop    rbp
    2127:	ret
    2128:	mov    edx,0x3
    212d:	call   2132 <botlish_fn_27+0x43>
			212e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2132:	test   rax,rax
    2135:	jne    2123 <botlish_fn_27+0x34>
    213b:	jmp    210e <botlish_fn_27+0x1f>

0000000000002140 <botlish_entry_27: ht_tombstones<HashTable>>:
    2140:	push   rbp
    2141:	mov    rbp,rsp
    2144:	mov    rsi,QWORD PTR [rdx]
    2147:	call   214c <botlish_entry_27+0xc>
			2148: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    214c:	mov    rsp,rbp
    214f:	pop    rbp
    2150:	ret

0000000000002151 <botlish_fn_28: ht_capacity<HashTable>>:
    2151:	push   rbp
    2152:	mov    rbp,rsp
    2155:	mov    rdi,QWORD PTR [rsi+0x18]
    2159:	mov    rdi,QWORD PTR [rdi]
    215c:	mov    rax,QWORD PTR [rdi+0x8]
    2160:	shl    rax,1
    2163:	or     rax,0x1
    2167:	mov    rsp,rbp
    216a:	pop    rbp
    216b:	ret

000000000000216c <botlish_entry_28: ht_capacity<HashTable>>:
    216c:	push   rbp
    216d:	mov    rbp,rsp
    2170:	mov    rsi,QWORD PTR [rdx]
    2173:	call   2178 <botlish_entry_28+0xc>
			2174: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2178:	mov    rsp,rbp
    217b:	pop    rbp
    217c:	ret

000000000000217d <botlish_fn_29: ht_probe_start<HashTable, str>>:
    217d:	push   rbp
    217e:	mov    rbp,rsp
    2181:	sub    rsp,0x10
    2185:	mov    QWORD PTR [rsp],rbx
    2189:	mov    QWORD PTR [rsp+0x8],r12
    218e:	mov    rbx,rdi
    2191:	mov    r12,rsi
    2194:	mov    rsi,rdx
    2197:	mov    rdi,rbx
    219a:	call   219f <botlish_fn_29+0x22>
			219b: R_X86_64_PLT32	rt_hash-0x4
    219f:	mov    rsi,r12
    21a2:	mov    r12,rax
    21a5:	mov    rdi,rbx
    21a8:	call   21ad <botlish_fn_29+0x30>
			21a9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    21ad:	sar    rax,1
    21b0:	test   rax,rax
    21b3:	mov    rcx,rax
    21b6:	jne    21d6 <botlish_fn_29+0x59>
    21bc:	jmp    2225 <botlish_fn_29+0xa8>
    21c1:	xor    rax,rax
    21c4:	mov    rbx,QWORD PTR [rsp]
    21c8:	mov    r12,QWORD PTR [rsp+0x8]
    21cd:	add    rsp,0x10
    21d1:	mov    rsp,rbp
    21d4:	pop    rbp
    21d5:	ret
    21d6:	mov    rax,r12
    21d9:	sar    rax,1
    21dc:	cqo
    21de:	cmp    rcx,0xffffffffffffffff
    21e2:	jne    21f2 <botlish_fn_29+0x75>
    21e8:	mov    edx,0x0
    21ed:	jmp    21f5 <botlish_fn_29+0x78>
    21f2:	idiv   rcx
    21f5:	mov    rax,rcx
    21f8:	neg    rax
    21fb:	cmovs  rax,rcx
    21ff:	add    rax,rdx
    2202:	test   rdx,rdx
    2205:	cmovl  rdx,rax
    2209:	shl    rdx,1
    220c:	mov    rax,rdx
    220f:	or     rax,0x1
    2213:	mov    rbx,QWORD PTR [rsp]
    2217:	mov    r12,QWORD PTR [rsp+0x8]
    221c:	add    rsp,0x10
    2220:	mov    rsp,rbp
    2223:	pop    rbp
    2224:	ret
    2225:	mov    edx,0x1
    222a:	mov    rax,r12
    222d:	mov    rsi,rax
    2230:	or     rsi,0x1
    2234:	mov    rdi,rbx
    2237:	call   223c <botlish_fn_29+0xbf>
			2238: R_X86_64_PLT32	rt_int_mod-0x4
    223c:	jmp    21c1 <botlish_fn_29+0x44>

0000000000002241 <botlish_entry_29: ht_probe_start<HashTable, str>>:
    2241:	push   rbp
    2242:	mov    rbp,rsp
    2245:	mov    rsi,QWORD PTR [rdx]
    2248:	mov    rdx,QWORD PTR [rdx+0x8]
    224c:	call   2251 <botlish_entry_29+0x10>
			224d: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    2251:	mov    rsp,rbp
    2254:	pop    rbp
    2255:	ret

0000000000002256 <botlish_fn_30: ht_probe_next<HashTable, int>>:
    2256:	push   rbp
    2257:	mov    rbp,rsp
    225a:	sub    rsp,0x10
    225e:	mov    QWORD PTR [rsp],rbx
    2262:	mov    QWORD PTR [rsp+0x8],r12
    2267:	mov    rbx,rdi
    226a:	mov    r12,rdx
    226d:	mov    rdi,rbx
    2270:	call   2275 <botlish_fn_30+0x1f>
			2271: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2275:	sar    rax,1
    2278:	test   rax,rax
    227b:	mov    rsi,rax
    227e:	jne    22a1 <botlish_fn_30+0x4b>
    2284:	jmp    22f6 <botlish_fn_30+0xa0>
    2289:	xor    rdx,rdx
    228c:	mov    rax,rdx
    228f:	mov    rbx,QWORD PTR [rsp]
    2293:	mov    r12,QWORD PTR [rsp+0x8]
    2298:	add    rsp,0x10
    229c:	mov    rsp,rbp
    229f:	pop    rbp
    22a0:	ret
    22a1:	mov    rax,r12
    22a4:	mov    ecx,0x1
    22a9:	add    rax,0x1
    22b0:	cqo
    22b2:	cmp    rsi,0xffffffffffffffff
    22b6:	jne    22c6 <botlish_fn_30+0x70>
    22bc:	mov    edx,0x0
    22c1:	jmp    22c9 <botlish_fn_30+0x73>
    22c6:	idiv   rsi
    22c9:	mov    rax,rsi
    22cc:	neg    rax
    22cf:	cmovs  rax,rsi
    22d3:	lea    rsi,[rdx+rax*1]
    22d7:	test   rdx,rdx
    22da:	mov    rax,rdx
    22dd:	cmovl  rax,rsi
    22e1:	mov    rdx,rcx
    22e4:	mov    rbx,QWORD PTR [rsp]
    22e8:	mov    r12,QWORD PTR [rsp+0x8]
    22ed:	add    rsp,0x10
    22f1:	mov    rsp,rbp
    22f4:	pop    rbp
    22f5:	ret
    22f6:	mov    edx,0x1
    22fb:	mov    rax,r12
    22fe:	lea    rsi,[rax+0x1]
    2302:	shl    rsi,1
    2305:	or     rsi,0x1
    2309:	mov    rdi,rbx
    230c:	call   2311 <botlish_fn_30+0xbb>
			230d: R_X86_64_PLT32	rt_int_mod-0x4
    2311:	jmp    2289 <botlish_fn_30+0x33>

0000000000002316 <botlish_entry_30: ht_probe_next<HashTable, int>>:
    2316:	push   rbp
    2317:	mov    rbp,rsp
    231a:	mov    rsi,QWORD PTR [rdx]
    231d:	mov    rdx,QWORD PTR [rdx+0x8]
    2321:	sar    rdx,1
    2324:	call   2329 <botlish_entry_30+0x13>
			2325: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2329:	shl    rax,1
    232c:	or     rax,0x1
    2330:	mov    rcx,rax
    2333:	xor    rax,rax
    2336:	test   rdx,rdx
    2339:	cmovne rax,rcx
    233d:	mov    rsp,rbp
    2340:	pop    rbp
    2341:	ret
    2342:	add    BYTE PTR [rax],al
    2344:	add    BYTE PTR [rax],al
	...

0000000000002348 <botlish_fn_31: ht_find_get<HashTable, str, int>>:
    2348:	push   rbp
    2349:	mov    rbp,rsp
    234c:	sub    rsp,0x30
    2350:	mov    QWORD PTR [rsp],rbx
    2354:	mov    QWORD PTR [rsp+0x8],r12
    2359:	mov    QWORD PTR [rsp+0x10],r13
    235e:	mov    QWORD PTR [rsp+0x18],r14
    2363:	mov    QWORD PTR [rsp+0x20],r15
    2368:	mov    rbx,rdx
    236b:	mov    r13,rdi
    236e:	sar    rcx,1
    2371:	mov    rdi,rcx
    2374:	mov    r12,rsi
    2377:	mov    rax,QWORD PTR [r12+0x18]
    237c:	mov    rsi,QWORD PTR [rax]
    237f:	mov    rcx,QWORD PTR [rsi+0x8]
    2383:	mov    rax,rdi
    2386:	shl    rax,1
    2389:	or     rax,0x1
    238d:	sar    rax,1
    2390:	cmp    rax,rcx
    2393:	jb     23a6 <botlish_fn_31+0x5e>
    2399:	jmp    256d <botlish_fn_31+0x225>
    239e:	mov    rsi,rax
    23a1:	jmp    23b1 <botlish_fn_31+0x69>
    23a6:	mov    r14,rdi
    23a9:	mov    rcx,QWORD PTR [rsi+0x10]
    23ad:	mov    rsi,QWORD PTR [rcx+rax*8]
    23b1:	test   rsi,0x1
    23b8:	mov    r15,rsi
    23bb:	jne    23e9 <botlish_fn_31+0xa1>
    23c1:	mov    edx,0x1
    23c6:	mov    rsi,r15
    23c9:	mov    rdi,r13
    23cc:	call   23d1 <botlish_fn_31+0x89>
			23cd: R_X86_64_PLT32	rt_int_cmp-0x4
    23d1:	mov    ecx,0x2
    23d6:	test   rax,rax
    23d9:	cmove  rcx,QWORD PTR [rip+0x1d7]        # 25b8 <botlish_fn_31+0x270>
    23e1:	mov    rsi,r15
    23e4:	jmp    23fd <botlish_fn_31+0xb5>
    23e9:	mov    ecx,0x2
    23ee:	mov    rsi,r15
    23f1:	cmp    rsi,0x1
    23f5:	cmove  rcx,QWORD PTR [rip+0x1bb]        # 25b8 <botlish_fn_31+0x270>
    23fd:	cmp    rcx,0x6
    2401:	je     2545 <botlish_fn_31+0x1fd>
    2407:	test   rsi,0x1
    240e:	jne    2436 <botlish_fn_31+0xee>
    2414:	mov    edx,0x3
    2419:	mov    rdi,r13
    241c:	call   2421 <botlish_fn_31+0xd9>
			241d: R_X86_64_PLT32	rt_int_cmp-0x4
    2421:	mov    ecx,0x2
    2426:	test   rax,rax
    2429:	cmove  rcx,QWORD PTR [rip+0x187]        # 25b8 <botlish_fn_31+0x270>
    2431:	jmp    2447 <botlish_fn_31+0xff>
    2436:	mov    ecx,0x2
    243b:	cmp    rsi,0x3
    243f:	cmove  rcx,QWORD PTR [rip+0x171]        # 25b8 <botlish_fn_31+0x270>
    2447:	cmp    rcx,0x6
    244b:	jne    24d4 <botlish_fn_31+0x18c>
    2451:	mov    rax,QWORD PTR [r12+0x18]
    2456:	mov    rsi,QWORD PTR [rax+0x8]
    245a:	mov    rcx,QWORD PTR [rsi+0x8]
    245e:	mov    rdi,r14
    2461:	mov    rax,rdi
    2464:	shl    rax,1
    2467:	or     rax,0x1
    246b:	sar    rax,1
    246e:	cmp    rax,rcx
    2471:	jb     2484 <botlish_fn_31+0x13c>
    2477:	jmp    2590 <botlish_fn_31+0x248>
    247c:	mov    rsi,rax
    247f:	jmp    248f <botlish_fn_31+0x147>
    2484:	mov    r14,rdi
    2487:	mov    rcx,QWORD PTR [rsi+0x10]
    248b:	mov    rsi,QWORD PTR [rcx+rax*8]
    248f:	mov    rax,rsi
    2492:	and    rax,rbx
    2495:	test   rax,0x1
    249b:	jne    24ba <botlish_fn_31+0x172>
    24a1:	mov    rdx,rbx
    24a4:	mov    rdi,r13
    24a7:	call   24ac <botlish_fn_31+0x164>
			24a8: R_X86_64_PLT32	rt_value_eq-0x4
    24ac:	test   rax,rax
    24af:	je     24eb <botlish_fn_31+0x1a3>
    24b5:	jmp    24ca <botlish_fn_31+0x182>
    24ba:	mov    eax,0x2
    24bf:	cmp    rsi,rbx
    24c2:	cmove  rax,QWORD PTR [rip+0xee]        # 25b8 <botlish_fn_31+0x270>
    24ca:	cmp    rax,0x6
    24ce:	je     2517 <botlish_fn_31+0x1cf>
    24d4:	mov    rdx,r14
    24d7:	mov    rsi,r12
    24da:	mov    rdi,r13
    24dd:	call   24e2 <botlish_fn_31+0x19a>
			24de: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    24e2:	test   rdx,rdx
    24e5:	jne    250f <botlish_fn_31+0x1c7>
    24eb:	xor    rax,rax
    24ee:	mov    rbx,QWORD PTR [rsp]
    24f2:	mov    r12,QWORD PTR [rsp+0x8]
    24f7:	mov    r13,QWORD PTR [rsp+0x10]
    24fc:	mov    r14,QWORD PTR [rsp+0x18]
    2501:	mov    r15,QWORD PTR [rsp+0x20]
    2506:	add    rsp,0x30
    250a:	mov    rsp,rbp
    250d:	pop    rbp
    250e:	ret
    250f:	mov    rdi,rax
    2512:	jmp    2377 <botlish_fn_31+0x2f>
    2517:	mov    rdx,r14
    251a:	shl    rdx,1
    251d:	mov    rax,rdx
    2520:	or     rax,0x1
    2524:	mov    rbx,QWORD PTR [rsp]
    2528:	mov    r12,QWORD PTR [rsp+0x8]
    252d:	mov    r13,QWORD PTR [rsp+0x10]
    2532:	mov    r14,QWORD PTR [rsp+0x18]
    2537:	mov    r15,QWORD PTR [rsp+0x20]
    253c:	add    rsp,0x30
    2540:	mov    rsp,rbp
    2543:	pop    rbp
    2544:	ret
    2545:	mov    rax,0xffffffffffffffff
    254c:	mov    rbx,QWORD PTR [rsp]
    2550:	mov    r12,QWORD PTR [rsp+0x8]
    2555:	mov    r13,QWORD PTR [rsp+0x10]
    255a:	mov    r14,QWORD PTR [rsp+0x18]
    255f:	mov    r15,QWORD PTR [rsp+0x20]
    2564:	add    rsp,0x30
    2568:	mov    rsp,rbp
    256b:	pop    rbp
    256c:	ret
    256d:	mov    rdx,rdi
    2570:	shl    rdx,1
    2573:	mov    r14,rdi
    2576:	or     rdx,0x1
    257a:	mov    rdi,r13
    257d:	call   2582 <botlish_fn_31+0x23a>
			257e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2582:	test   rax,rax
    2585:	jne    239e <botlish_fn_31+0x56>
    258b:	jmp    24eb <botlish_fn_31+0x1a3>
    2590:	mov    rdx,rdi
    2593:	shl    rdx,1
    2596:	mov    r14,rdi
    2599:	or     rdx,0x1
    259d:	mov    rdi,r13
    25a0:	call   25a5 <botlish_fn_31+0x25d>
			25a1: R_X86_64_PLT32	rt_mutarray_get-0x4
    25a5:	test   rax,rax
    25a8:	jne    247c <botlish_fn_31+0x134>
    25ae:	jmp    24eb <botlish_fn_31+0x1a3>
    25b3:	add    BYTE PTR [rax],al
    25b5:	add    BYTE PTR [rax],al
    25b7:	add    BYTE PTR [rsi],al
    25b9:	add    BYTE PTR [rax],al
    25bb:	add    BYTE PTR [rax],al
    25bd:	add    BYTE PTR [rax],al
	...

00000000000025c0 <botlish_entry_31: ht_find_get<HashTable, str, int>>:
    25c0:	push   rbp
    25c1:	mov    rbp,rsp
    25c4:	mov    rsi,QWORD PTR [rdx]
    25c7:	mov    r8,QWORD PTR [rdx+0x8]
    25cb:	mov    rcx,QWORD PTR [rdx+0x10]
    25cf:	mov    rdx,r8
    25d2:	call   25d7 <botlish_entry_31+0x17>
			25d3: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    25d7:	mov    rsp,rbp
    25da:	pop    rbp
    25db:	ret
    25dc:	add    BYTE PTR [rax],al
	...

00000000000025e0 <botlish_fn_32: ht_find_insert<HashTable, str, int, int>>:
    25e0:	push   rbp
    25e1:	mov    rbp,rsp
    25e4:	sub    rsp,0x40
    25e8:	mov    QWORD PTR [rsp+0x10],rbx
    25ed:	mov    QWORD PTR [rsp+0x18],r12
    25f2:	mov    QWORD PTR [rsp+0x20],r13
    25f7:	mov    QWORD PTR [rsp+0x28],r14
    25fc:	mov    QWORD PTR [rsp+0x30],r15
    2601:	mov    r14,rdi
    2604:	mov    r15,rdx
    2607:	sar    rcx,1
    260a:	mov    rbx,rsi
    260d:	mov    r12,rcx
    2610:	mov    r13,r8
    2613:	mov    rax,QWORD PTR [rbx+0x18]
    2617:	mov    rsi,QWORD PTR [rax]
    261a:	mov    rdx,QWORD PTR [rsi+0x8]
    261e:	mov    rcx,r12
    2621:	shl    rcx,1
    2624:	or     rcx,0x1
    2628:	sar    rcx,1
    262b:	cmp    rcx,rdx
    262e:	jb     2641 <botlish_fn_32+0x61>
    2634:	jmp    2981 <botlish_fn_32+0x3a1>
    2639:	mov    rsi,rax
    263c:	jmp    2649 <botlish_fn_32+0x69>
    2641:	mov    rax,QWORD PTR [rsi+0x10]
    2645:	mov    rsi,QWORD PTR [rax+rcx*8]
    2649:	test   rsi,0x1
    2650:	mov    QWORD PTR [rsp],rsi
    2654:	jne    2680 <botlish_fn_32+0xa0>
    265a:	mov    edx,0x1
    265f:	mov    rsi,QWORD PTR [rsp]
    2663:	mov    rdi,r14
    2666:	call   266b <botlish_fn_32+0x8b>
			2667: R_X86_64_PLT32	rt_int_cmp-0x4
    266b:	mov    ecx,0x2
    2670:	test   rax,rax
    2673:	cmove  rcx,QWORD PTR [rip+0x34d]        # 29c8 <botlish_fn_32+0x3e8>
    267b:	jmp    2695 <botlish_fn_32+0xb5>
    2680:	mov    ecx,0x2
    2685:	mov    rsi,QWORD PTR [rsp]
    2689:	cmp    rsi,0x1
    268d:	cmove  rcx,QWORD PTR [rip+0x333]        # 29c8 <botlish_fn_32+0x3e8>
    2695:	cmp    rcx,0x6
    2699:	je     28d5 <botlish_fn_32+0x2f5>
    269f:	mov    rsi,QWORD PTR [rsp]
    26a3:	test   rsi,0x1
    26aa:	jne    26d6 <botlish_fn_32+0xf6>
    26b0:	mov    edx,0x3
    26b5:	mov    rsi,QWORD PTR [rsp]
    26b9:	mov    rdi,r14
    26bc:	call   26c1 <botlish_fn_32+0xe1>
			26bd: R_X86_64_PLT32	rt_int_cmp-0x4
    26c1:	mov    ecx,0x2
    26c6:	test   rax,rax
    26c9:	cmove  rcx,QWORD PTR [rip+0x2f7]        # 29c8 <botlish_fn_32+0x3e8>
    26d1:	jmp    26eb <botlish_fn_32+0x10b>
    26d6:	mov    ecx,0x2
    26db:	mov    rsi,QWORD PTR [rsp]
    26df:	cmp    rsi,0x3
    26e3:	cmove  rcx,QWORD PTR [rip+0x2dd]        # 29c8 <botlish_fn_32+0x3e8>
    26eb:	cmp    rcx,0x6
    26ef:	je     2706 <botlish_fn_32+0x126>
    26f5:	mov    QWORD PTR [rsp+0x8],r12
    26fa:	mov    r12,r15
    26fd:	mov    rsi,QWORD PTR [rsp]
    2701:	jmp    2791 <botlish_fn_32+0x1b1>
    2706:	mov    rax,QWORD PTR [rbx+0x18]
    270a:	mov    rsi,QWORD PTR [rax+0x8]
    270e:	mov    rax,QWORD PTR [rsi+0x8]
    2712:	mov    rcx,r12
    2715:	shl    rcx,1
    2718:	or     rcx,0x1
    271c:	sar    rcx,1
    271f:	cmp    rcx,rax
    2722:	jb     2738 <botlish_fn_32+0x158>
    2728:	jmp    29a1 <botlish_fn_32+0x3c1>
    272d:	mov    rsi,rax
    2730:	mov    r12,r15
    2733:	jmp    2748 <botlish_fn_32+0x168>
    2738:	mov    QWORD PTR [rsp+0x8],r12
    273d:	mov    rax,QWORD PTR [rsi+0x10]
    2741:	mov    rsi,QWORD PTR [rax+rcx*8]
    2745:	mov    r12,r15
    2748:	mov    rax,rsi
    274b:	and    rax,r12
    274e:	test   rax,0x1
    2754:	jne    2773 <botlish_fn_32+0x193>
    275a:	mov    rdx,r12
    275d:	mov    rdi,r14
    2760:	call   2765 <botlish_fn_32+0x185>
			2761: R_X86_64_PLT32	rt_value_eq-0x4
    2765:	test   rax,rax
    2768:	je     2880 <botlish_fn_32+0x2a0>
    276e:	jmp    2783 <botlish_fn_32+0x1a3>
    2773:	mov    eax,0x2
    2778:	cmp    rsi,r12
    277b:	cmove  rax,QWORD PTR [rip+0x245]        # 29c8 <botlish_fn_32+0x3e8>
    2783:	cmp    rax,0x6
    2787:	je     28cb <botlish_fn_32+0x2eb>
    278d:	mov    rsi,QWORD PTR [rsp]
    2791:	test   rsi,0x1
    2798:	jne    27c4 <botlish_fn_32+0x1e4>
    279e:	mov    edx,0x5
    27a3:	mov    rsi,QWORD PTR [rsp]
    27a7:	mov    rdi,r14
    27aa:	call   27af <botlish_fn_32+0x1cf>
			27ab: R_X86_64_PLT32	rt_int_cmp-0x4
    27af:	mov    ecx,0x2
    27b4:	test   rax,rax
    27b7:	cmove  rcx,QWORD PTR [rip+0x209]        # 29c8 <botlish_fn_32+0x3e8>
    27bf:	jmp    27d9 <botlish_fn_32+0x1f9>
    27c4:	mov    ecx,0x2
    27c9:	mov    rsi,QWORD PTR [rsp]
    27cd:	cmp    rsi,0x5
    27d1:	cmove  rcx,QWORD PTR [rip+0x1ef]        # 29c8 <botlish_fn_32+0x3e8>
    27d9:	cmp    rcx,0x6
    27dd:	je     27ed <botlish_fn_32+0x20d>
    27e3:	mov    rdx,QWORD PTR [rsp+0x8]
    27e8:	jmp    283e <botlish_fn_32+0x25e>
    27ed:	test   r13,0x1
    27f4:	jne    281f <botlish_fn_32+0x23f>
    27fa:	mov    edx,0x1
    27ff:	mov    rsi,r13
    2802:	mov    rdi,r14
    2805:	call   280a <botlish_fn_32+0x22a>
			2806: R_X86_64_PLT32	rt_int_cmp-0x4
    280a:	mov    ecx,0x2
    280f:	test   rax,rax
    2812:	cmovl  rcx,QWORD PTR [rip+0x1ae]        # 29c8 <botlish_fn_32+0x3e8>
    281a:	jmp    282f <botlish_fn_32+0x24f>
    281f:	mov    ecx,0x2
    2824:	test   r13,r13
    2827:	cmovle rcx,QWORD PTR [rip+0x199]        # 29c8 <botlish_fn_32+0x3e8>
    282f:	cmp    rcx,0x6
    2833:	je     2864 <botlish_fn_32+0x284>
    2839:	mov    rdx,QWORD PTR [rsp+0x8]
    283e:	mov    rsi,rbx
    2841:	mov    rdi,r14
    2844:	call   2849 <botlish_fn_32+0x269>
			2845: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2849:	mov    QWORD PTR [rsp+0x8],rax
    284e:	test   rdx,rdx
    2851:	je     2880 <botlish_fn_32+0x2a0>
    2857:	mov    r15,r12
    285a:	mov    r12,QWORD PTR [rsp+0x8]
    285f:	jmp    2613 <botlish_fn_32+0x33>
    2864:	mov    rdx,QWORD PTR [rsp+0x8]
    2869:	mov    rsi,rbx
    286c:	mov    rdi,r14
    286f:	call   2874 <botlish_fn_32+0x294>
			2870: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2874:	mov    rcx,rax
    2877:	test   rdx,rdx
    287a:	jne    28a5 <botlish_fn_32+0x2c5>
    2880:	xor    rax,rax
    2883:	mov    rbx,QWORD PTR [rsp+0x10]
    2888:	mov    r12,QWORD PTR [rsp+0x18]
    288d:	mov    r13,QWORD PTR [rsp+0x20]
    2892:	mov    r14,QWORD PTR [rsp+0x28]
    2897:	mov    r15,QWORD PTR [rsp+0x30]
    289c:	add    rsp,0x40
    28a0:	mov    rsp,rbp
    28a3:	pop    rbp
    28a4:	ret
    28a5:	mov    rax,QWORD PTR [rsp+0x8]
    28aa:	shl    rax,1
    28ad:	mov    QWORD PTR [rsp+0x8],rax
    28b2:	or     rax,0x1
    28b6:	mov    QWORD PTR [rsp+0x8],rax
    28bb:	mov    r15,r12
    28be:	mov    r13,QWORD PTR [rsp+0x8]
    28c3:	mov    r12,rcx
    28c6:	jmp    2613 <botlish_fn_32+0x33>
    28cb:	mov    rax,QWORD PTR [rsp+0x8]
    28d0:	jmp    2933 <botlish_fn_32+0x353>
    28d5:	mov    rax,r13
    28d8:	mov    QWORD PTR [rsp+0x8],r12
    28dd:	test   rax,0x1
    28e3:	jne    290e <botlish_fn_32+0x32e>
    28e9:	mov    edx,0x1
    28ee:	mov    rdi,r14
    28f1:	mov    rsi,r13
    28f4:	call   28f9 <botlish_fn_32+0x319>
			28f5: R_X86_64_PLT32	rt_int_cmp-0x4
    28f9:	mov    ecx,0x2
    28fe:	test   rax,rax
    2901:	cmovge rcx,QWORD PTR [rip+0xbf]        # 29c8 <botlish_fn_32+0x3e8>
    2909:	jmp    2924 <botlish_fn_32+0x344>
    290e:	mov    ecx,0x2
    2913:	mov    rax,r13
    2916:	mov    rdx,r13
    2919:	test   rax,rdx
    291c:	cmovg  rcx,QWORD PTR [rip+0xa4]        # 29c8 <botlish_fn_32+0x3e8>
    2924:	cmp    rcx,0x6
    2928:	je     295c <botlish_fn_32+0x37c>
    292e:	mov    rax,QWORD PTR [rsp+0x8]
    2933:	shl    rax,1
    2936:	or     rax,0x1
    293a:	mov    rbx,QWORD PTR [rsp+0x10]
    293f:	mov    r12,QWORD PTR [rsp+0x18]
    2944:	mov    r13,QWORD PTR [rsp+0x20]
    2949:	mov    r14,QWORD PTR [rsp+0x28]
    294e:	mov    r15,QWORD PTR [rsp+0x30]
    2953:	add    rsp,0x40
    2957:	mov    rsp,rbp
    295a:	pop    rbp
    295b:	ret
    295c:	mov    rax,r13
    295f:	mov    rbx,QWORD PTR [rsp+0x10]
    2964:	mov    r12,QWORD PTR [rsp+0x18]
    2969:	mov    r13,QWORD PTR [rsp+0x20]
    296e:	mov    r14,QWORD PTR [rsp+0x28]
    2973:	mov    r15,QWORD PTR [rsp+0x30]
    2978:	add    rsp,0x40
    297c:	mov    rsp,rbp
    297f:	pop    rbp
    2980:	ret
    2981:	mov    rdx,r12
    2984:	shl    rdx,1
    2987:	or     rdx,0x1
    298b:	mov    rdi,r14
    298e:	call   2993 <botlish_fn_32+0x3b3>
			298f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2993:	test   rax,rax
    2996:	jne    2639 <botlish_fn_32+0x59>
    299c:	jmp    2880 <botlish_fn_32+0x2a0>
    29a1:	mov    rdx,r12
    29a4:	shl    rdx,1
    29a7:	mov    QWORD PTR [rsp+0x8],r12
    29ac:	or     rdx,0x1
    29b0:	mov    rdi,r14
    29b3:	call   29b8 <botlish_fn_32+0x3d8>
			29b4: R_X86_64_PLT32	rt_mutarray_get-0x4
    29b8:	test   rax,rax
    29bb:	jne    272d <botlish_fn_32+0x14d>
    29c1:	jmp    2880 <botlish_fn_32+0x2a0>
    29c6:	add    BYTE PTR [rax],al
    29c8:	(bad)
    29c9:	add    BYTE PTR [rax],al
    29cb:	add    BYTE PTR [rax],al
    29cd:	add    BYTE PTR [rax],al
	...

00000000000029d0 <botlish_entry_32: ht_find_insert<HashTable, str, int, int>>:
    29d0:	push   rbp
    29d1:	mov    rbp,rsp
    29d4:	mov    rsi,QWORD PTR [rdx]
    29d7:	mov    r9,QWORD PTR [rdx+0x8]
    29db:	mov    rcx,QWORD PTR [rdx+0x10]
    29df:	mov    r8,QWORD PTR [rdx+0x18]
    29e3:	mov    rdx,r9
    29e6:	call   29eb <botlish_entry_32+0x1b>
			29e7: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    29eb:	mov    rsp,rbp
    29ee:	pop    rbp
    29ef:	ret

00000000000029f0 <botlish_fn_33: ht_get<HashTable, str>>:
    29f0:	push   rbp
    29f1:	mov    rbp,rsp
    29f4:	sub    rsp,0x20
    29f8:	mov    QWORD PTR [rsp],rbx
    29fc:	mov    QWORD PTR [rsp+0x8],r12
    2a01:	mov    QWORD PTR [rsp+0x10],r13
    2a06:	mov    r12,rdi
    2a09:	mov    r13,rdx
    2a0c:	mov    rbx,rsi
    2a0f:	mov    rdx,r13
    2a12:	mov    rdi,r12
    2a15:	call   2a1a <botlish_fn_33+0x2a>
			2a16: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    2a1a:	test   rax,rax
    2a1d:	mov    rcx,rax
    2a20:	je     2ac6 <botlish_fn_33+0xd6>
    2a26:	mov    rdx,r13
    2a29:	mov    rsi,rbx
    2a2c:	mov    rdi,r12
    2a2f:	call   2a34 <botlish_fn_33+0x44>
			2a30: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    2a34:	mov    rcx,rax
    2a37:	mov    r13,rax
    2a3a:	test   rax,rcx
    2a3d:	je     2ac6 <botlish_fn_33+0xd6>
    2a43:	mov    rax,r13
    2a46:	test   rax,0x1
    2a4c:	jne    2a7a <botlish_fn_33+0x8a>
    2a52:	mov    edx,0x1
    2a57:	mov    rsi,r13
    2a5a:	mov    rdi,r12
    2a5d:	call   2a62 <botlish_fn_33+0x72>
			2a5e: R_X86_64_PLT32	rt_int_cmp-0x4
    2a62:	mov    ecx,0x2
    2a67:	test   rax,rax
    2a6a:	cmovl  rcx,QWORD PTR [rip+0xd6]        # 2b48 <botlish_fn_33+0x158>
    2a72:	mov    rax,r13
    2a75:	jmp    2a8d <botlish_fn_33+0x9d>
    2a7a:	mov    ecx,0x2
    2a7f:	mov    rax,r13
    2a82:	test   rax,rax
    2a85:	cmovle rcx,QWORD PTR [rip+0xbb]        # 2b48 <botlish_fn_33+0x158>
    2a8d:	cmp    rcx,0x6
    2a91:	je     2b04 <botlish_fn_33+0x114>
    2a97:	mov    rcx,QWORD PTR [rbx+0x18]
    2a9b:	mov    rsi,QWORD PTR [rcx+0x10]
    2a9f:	test   rax,0x1
    2aa5:	je     2b20 <botlish_fn_33+0x130>
    2aab:	mov    rdx,QWORD PTR [rsi+0x8]
    2aaf:	mov    rcx,rax
    2ab2:	sar    rcx,1
    2ab5:	mov    r13,rax
    2ab8:	cmp    rcx,rdx
    2abb:	jb     2ae5 <botlish_fn_33+0xf5>
    2ac1:	jmp    2b2b <botlish_fn_33+0x13b>
    2ac6:	xor    rax,rax
    2ac9:	mov    rbx,QWORD PTR [rsp]
    2acd:	mov    r12,QWORD PTR [rsp+0x8]
    2ad2:	mov    r13,QWORD PTR [rsp+0x10]
    2ad7:	add    rsp,0x20
    2adb:	mov    rsp,rbp
    2ade:	pop    rbp
    2adf:	ret
    2ae0:	jmp    2aed <botlish_fn_33+0xfd>
    2ae5:	mov    rax,QWORD PTR [rsi+0x10]
    2ae9:	mov    rax,QWORD PTR [rax+rcx*8]
    2aed:	mov    rbx,QWORD PTR [rsp]
    2af1:	mov    r12,QWORD PTR [rsp+0x8]
    2af6:	mov    r13,QWORD PTR [rsp+0x10]
    2afb:	add    rsp,0x20
    2aff:	mov    rsp,rbp
    2b02:	pop    rbp
    2b03:	ret
    2b04:	mov    eax,0xa
    2b09:	mov    rbx,QWORD PTR [rsp]
    2b0d:	mov    r12,QWORD PTR [rsp+0x8]
    2b12:	mov    r13,QWORD PTR [rsp+0x10]
    2b17:	add    rsp,0x20
    2b1b:	mov    rsp,rbp
    2b1e:	pop    rbp
    2b1f:	ret
    2b20:	mov    rdx,rax
    2b23:	mov    rdi,r12
    2b26:	jmp    2b31 <botlish_fn_33+0x141>
    2b2b:	mov    rdx,r13
    2b2e:	mov    rdi,r12
    2b31:	mov    rdi,r12
    2b34:	call   2b39 <botlish_fn_33+0x149>
			2b35: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b39:	test   rax,rax
    2b3c:	jne    2aed <botlish_fn_33+0xfd>
    2b42:	jmp    2ac6 <botlish_fn_33+0xd6>
    2b47:	add    BYTE PTR [rsi],al
    2b49:	add    BYTE PTR [rax],al
    2b4b:	add    BYTE PTR [rax],al
    2b4d:	add    BYTE PTR [rax],al
	...

0000000000002b50 <botlish_entry_33: ht_get<HashTable, str>>:
    2b50:	push   rbp
    2b51:	mov    rbp,rsp
    2b54:	mov    rsi,QWORD PTR [rdx]
    2b57:	mov    rdx,QWORD PTR [rdx+0x8]
    2b5b:	call   2b60 <botlish_entry_33+0x10>
			2b5c: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    2b60:	mov    rsp,rbp
    2b63:	pop    rbp
    2b64:	ret
    2b65:	add    BYTE PTR [rax],al
	...

0000000000002b68 <botlish_fn_34: ht_rehash_probe<mutarray, int, int>>:
    2b68:	push   rbp
    2b69:	mov    rbp,rsp
    2b6c:	sub    rsp,0x60
    2b70:	mov    QWORD PTR [rsp+0x30],rbx
    2b75:	mov    QWORD PTR [rsp+0x38],r12
    2b7a:	mov    QWORD PTR [rsp+0x40],r13
    2b7f:	mov    QWORD PTR [rsp+0x48],r14
    2b84:	mov    QWORD PTR [rsp+0x50],r15
    2b89:	mov    r15,rdi
    2b8c:	mov    QWORD PTR [rsp],rsi
    2b90:	mov    rax,rsi
    2b93:	mov    QWORD PTR [rsp+0x8],rdx
    2b98:	mov    QWORD PTR [rsp+0x10],rcx
    2b9d:	mov    r14,rcx
    2ba0:	sar    r14,1
    2ba3:	mov    r13,rcx
    2ba6:	mov    rbx,r14
    2ba9:	neg    rbx
    2bac:	cmovs  rbx,r14
    2bb0:	mov    rsi,rdx
    2bb3:	test   rsi,0x1
    2bba:	je     2d4f <botlish_fn_34+0x1e7>
    2bc0:	mov    r12,rax
    2bc3:	mov    rcx,QWORD PTR [r12+0x8]
    2bc8:	mov    rax,rsi
    2bcb:	sar    rax,1
    2bce:	mov    QWORD PTR [rsp+0x20],rsi
    2bd3:	cmp    rax,rcx
    2bd6:	jb     2be9 <botlish_fn_34+0x81>
    2bdc:	jmp    2d57 <botlish_fn_34+0x1ef>
    2be1:	mov    rsi,rax
    2be4:	jmp    2bf2 <botlish_fn_34+0x8a>
    2be9:	mov    rcx,QWORD PTR [r12+0x10]
    2bee:	mov    rsi,QWORD PTR [rcx+rax*8]
    2bf2:	test   rsi,0x1
    2bf9:	jne    2c1a <botlish_fn_34+0xb2>
    2bff:	mov    edx,0x1
    2c04:	mov    rdi,r15
    2c07:	call   2c0c <botlish_fn_34+0xa4>
			2c08: R_X86_64_PLT32	rt_value_eq-0x4
    2c0c:	test   rax,rax
    2c0f:	je     2cea <botlish_fn_34+0x182>
    2c15:	jmp    2c2b <botlish_fn_34+0xc3>
    2c1a:	mov    eax,0x2
    2c1f:	cmp    rsi,0x1
    2c23:	cmove  rax,QWORD PTR [rip+0x14d]        # 2d78 <botlish_fn_34+0x210>
    2c2b:	cmp    rax,0x6
    2c2f:	je     2d28 <botlish_fn_34+0x1c0>
    2c35:	mov    QWORD PTR [rsp+0x18],0x3
    2c3e:	mov    rsi,QWORD PTR [rsp+0x20]
    2c43:	test   rsi,0x1
    2c4a:	je     2c66 <botlish_fn_34+0xfe>
    2c50:	mov    rsi,QWORD PTR [rsp+0x20]
    2c55:	add    rsi,0x2
    2c59:	seto   dil
    2c5d:	test   dil,dil
    2c60:	je     2c7b <botlish_fn_34+0x113>
    2c66:	mov    edx,0x3
    2c6b:	mov    rsi,QWORD PTR [rsp+0x20]
    2c70:	mov    rdi,r15
    2c73:	call   2c78 <botlish_fn_34+0x110>
			2c74: R_X86_64_PLT32	rt_int_add-0x4
    2c78:	mov    rsi,rax
    2c7b:	mov    QWORD PTR [rsp+0x8],rsi
    2c80:	mov    r10,rsi
    2c83:	and    r10,r13
    2c86:	test   r10,0x1
    2c8d:	je     2cd6 <botlish_fn_34+0x16e>
    2c93:	cmp    r13,0x1
    2c97:	je     2cd6 <botlish_fn_34+0x16e>
    2c9d:	mov    rax,rsi
    2ca0:	sar    rax,1
    2ca3:	cqo
    2ca5:	cmp    r14,0xffffffffffffffff
    2ca9:	jne    2cb9 <botlish_fn_34+0x151>
    2caf:	mov    edx,0x0
    2cb4:	jmp    2cbc <botlish_fn_34+0x154>
    2cb9:	idiv   r14
    2cbc:	lea    rax,[rdx+rbx*1]
    2cc0:	test   rdx,rdx
    2cc3:	cmovl  rdx,rax
    2cc7:	shl    rdx,1
    2cca:	or     rdx,0x1
    2cce:	mov    rax,rdx
    2cd1:	jmp    2d0f <botlish_fn_34+0x1a7>
    2cd6:	mov    rdx,r13
    2cd9:	mov    rdi,r15
    2cdc:	call   2ce1 <botlish_fn_34+0x179>
			2cdd: R_X86_64_PLT32	rt_int_mod-0x4
    2ce1:	test   rax,rax
    2ce4:	jne    2d0f <botlish_fn_34+0x1a7>
    2cea:	xor    rax,rax
    2ced:	mov    rbx,QWORD PTR [rsp+0x30]
    2cf2:	mov    r12,QWORD PTR [rsp+0x38]
    2cf7:	mov    r13,QWORD PTR [rsp+0x40]
    2cfc:	mov    r14,QWORD PTR [rsp+0x48]
    2d01:	mov    r15,QWORD PTR [rsp+0x50]
    2d06:	add    rsp,0x60
    2d0a:	mov    rsp,rbp
    2d0d:	pop    rbp
    2d0e:	ret
    2d0f:	mov    QWORD PTR [rsp],r12
    2d13:	mov    QWORD PTR [rsp+0x8],rax
    2d18:	mov    QWORD PTR [rsp+0x10],r13
    2d1d:	mov    rsi,rax
    2d20:	mov    rax,r12
    2d23:	jmp    2bb3 <botlish_fn_34+0x4b>
    2d28:	mov    rax,QWORD PTR [rsp+0x20]
    2d2d:	mov    rbx,QWORD PTR [rsp+0x30]
    2d32:	mov    r12,QWORD PTR [rsp+0x38]
    2d37:	mov    r13,QWORD PTR [rsp+0x40]
    2d3c:	mov    r14,QWORD PTR [rsp+0x48]
    2d41:	mov    r15,QWORD PTR [rsp+0x50]
    2d46:	add    rsp,0x60
    2d4a:	mov    rsp,rbp
    2d4d:	pop    rbp
    2d4e:	ret
    2d4f:	mov    r12,rax
    2d52:	mov    QWORD PTR [rsp+0x20],rsi
    2d57:	mov    rdx,QWORD PTR [rsp+0x20]
    2d5c:	mov    rsi,r12
    2d5f:	mov    rdi,r15
    2d62:	call   2d67 <botlish_fn_34+0x1ff>
			2d63: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d67:	test   rax,rax
    2d6a:	jne    2be1 <botlish_fn_34+0x79>
    2d70:	jmp    2cea <botlish_fn_34+0x182>
    2d75:	add    BYTE PTR [rax],al
    2d77:	add    BYTE PTR [rsi],al
    2d79:	add    BYTE PTR [rax],al
    2d7b:	add    BYTE PTR [rax],al
    2d7d:	add    BYTE PTR [rax],al
	...

0000000000002d80 <botlish_entry_34: ht_rehash_probe<mutarray, int, int>>:
    2d80:	push   rbp
    2d81:	mov    rbp,rsp
    2d84:	mov    rsi,QWORD PTR [rdx]
    2d87:	mov    r8,QWORD PTR [rdx+0x8]
    2d8b:	mov    rcx,QWORD PTR [rdx+0x10]
    2d8f:	mov    rdx,r8
    2d92:	call   2d97 <botlish_entry_34+0x17>
			2d93: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2d97:	mov    rsp,rbp
    2d9a:	pop    rbp
    2d9b:	ret

0000000000002d9c <botlish_fn_35: ht_rehash_insert<HashTable, int, any, any>>:
    2d9c:	push   rbp
    2d9d:	mov    rbp,rsp
    2da0:	sub    rsp,0x70
    2da4:	mov    QWORD PTR [rsp+0x40],rbx
    2da9:	mov    QWORD PTR [rsp+0x48],r12
    2dae:	mov    QWORD PTR [rsp+0x50],r13
    2db3:	mov    QWORD PTR [rsp+0x58],r14
    2db8:	mov    QWORD PTR [rsp+0x60],r15
    2dbd:	mov    r15,rdi
    2dc0:	mov    QWORD PTR [rsp],rsi
    2dc4:	mov    QWORD PTR [rsp+0x8],rdx
    2dc9:	mov    r12,rdx
    2dcc:	mov    QWORD PTR [rsp+0x10],rcx
    2dd1:	mov    QWORD PTR [rsp+0x30],rcx
    2dd6:	mov    QWORD PTR [rsp+0x18],r8
    2ddb:	mov    r14,r8
    2dde:	mov    rax,QWORD PTR [rsi+0x18]
    2de2:	mov    rbx,rsi
    2de5:	mov    rsi,QWORD PTR [rax]
    2de8:	mov    QWORD PTR [rsp+0x20],rsi
    2ded:	mov    QWORD PTR [rsp+0x38],rsi
    2df2:	mov    rsi,QWORD PTR [rsp+0x30]
    2df7:	mov    rdi,r15
    2dfa:	call   2dff <botlish_fn_35+0x63>
			2dfb: R_X86_64_PLT32	rt_hash-0x4
    2dff:	test   rax,rax
    2e02:	je     2f81 <botlish_fn_35+0x1e5>
    2e08:	mov    QWORD PTR [rsp+0x28],rax
    2e0d:	mov    r13,r12
    2e10:	mov    rcx,rax
    2e13:	and    rcx,r13
    2e16:	test   rcx,0x1
    2e1d:	jne    2e2b <botlish_fn_35+0x8f>
    2e23:	mov    rsi,rax
    2e26:	jmp    2e82 <botlish_fn_35+0xe6>
    2e2b:	cmp    r13,0x1
    2e2f:	jne    2e3d <botlish_fn_35+0xa1>
    2e35:	mov    rsi,rax
    2e38:	jmp    2e82 <botlish_fn_35+0xe6>
    2e3d:	sar    rax,1
    2e40:	mov    rcx,r13
    2e43:	sar    rcx,1
    2e46:	cqo
    2e48:	cmp    rcx,0xffffffffffffffff
    2e4c:	jne    2e5c <botlish_fn_35+0xc0>
    2e52:	mov    edx,0x0
    2e57:	jmp    2e5f <botlish_fn_35+0xc3>
    2e5c:	idiv   rcx
    2e5f:	mov    rax,rcx
    2e62:	neg    rax
    2e65:	cmovs  rax,rcx
    2e69:	add    rax,rdx
    2e6c:	test   rdx,rdx
    2e6f:	cmovl  rdx,rax
    2e73:	shl    rdx,1
    2e76:	or     rdx,0x1
    2e7a:	mov    r12,r13
    2e7d:	jmp    2e9c <botlish_fn_35+0x100>
    2e82:	mov    rdx,r13
    2e85:	mov    rdi,r15
    2e88:	call   2e8d <botlish_fn_35+0xf1>
			2e89: R_X86_64_PLT32	rt_int_mod-0x4
    2e8d:	mov    r12,r13
    2e90:	test   rax,rax
    2e93:	je     2f81 <botlish_fn_35+0x1e5>
    2e99:	mov    rdx,rax
    2e9c:	mov    QWORD PTR [rsp+0x28],rdx
    2ea1:	mov    rcx,r12
    2ea4:	mov    rsi,QWORD PTR [rsp+0x38]
    2ea9:	mov    rdi,r15
    2eac:	call   2eb1 <botlish_fn_35+0x115>
			2ead: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2eb1:	mov    rcx,rax
    2eb4:	mov    r12,rax
    2eb7:	test   rax,rcx
    2eba:	je     2f81 <botlish_fn_35+0x1e5>
    2ec0:	mov    r9,QWORD PTR [rbx+0x18]
    2ec4:	mov    rsi,QWORD PTR [r9]
    2ec7:	mov    rax,r12
    2eca:	test   rax,0x1
    2ed0:	je     2fde <botlish_fn_35+0x242>
    2ed6:	mov    rdx,QWORD PTR [rsi+0x8]
    2eda:	mov    rax,r12
    2edd:	mov    rcx,rax
    2ee0:	sar    rcx,1
    2ee3:	cmp    rcx,rdx
    2ee6:	jae    2fde <botlish_fn_35+0x242>
    2eec:	mov    rdx,QWORD PTR [rsi+0x18]
    2ef0:	test   rdx,rdx
    2ef3:	je     2fde <botlish_fn_35+0x242>
    2ef9:	mov    rax,QWORD PTR [rsi+0x10]
    2efd:	mov    QWORD PTR [rax+rcx*8],0x3
    2f05:	mov    rax,QWORD PTR [rbx+0x18]
    2f09:	mov    rsi,QWORD PTR [rax+0x8]
    2f0d:	test   r12,0x1
    2f14:	je     2ffc <botlish_fn_35+0x260>
    2f1a:	mov    rdx,QWORD PTR [rsi+0x8]
    2f1e:	mov    rdi,r12
    2f21:	sar    rdi,1
    2f24:	cmp    rdi,rdx
    2f27:	jae    3006 <botlish_fn_35+0x26a>
    2f2d:	mov    rcx,QWORD PTR [rsi+0x18]
    2f31:	test   rcx,rcx
    2f34:	je     3010 <botlish_fn_35+0x274>
    2f3a:	mov    rcx,QWORD PTR [rsp+0x30]
    2f3f:	mov    rax,QWORD PTR [rsi+0x10]
    2f43:	mov    QWORD PTR [rax+rdi*8],rcx
    2f47:	mov    rax,QWORD PTR [rbx+0x18]
    2f4b:	mov    rsi,QWORD PTR [rax+0x10]
    2f4f:	test   r12,0x1
    2f56:	je     302e <botlish_fn_35+0x292>
    2f5c:	mov    rdx,QWORD PTR [rsi+0x8]
    2f60:	mov    rdi,r12
    2f63:	sar    rdi,1
    2f66:	cmp    rdi,rdx
    2f69:	jae    303c <botlish_fn_35+0x2a0>
    2f6f:	mov    rax,QWORD PTR [rsi+0x18]
    2f73:	test   rax,rax
    2f76:	jne    2fae <botlish_fn_35+0x212>
    2f7c:	jmp    304a <botlish_fn_35+0x2ae>
    2f81:	xor    rax,rax
    2f84:	mov    rbx,QWORD PTR [rsp+0x40]
    2f89:	mov    r12,QWORD PTR [rsp+0x48]
    2f8e:	mov    r13,QWORD PTR [rsp+0x50]
    2f93:	mov    r14,QWORD PTR [rsp+0x58]
    2f98:	mov    r15,QWORD PTR [rsp+0x60]
    2f9d:	add    rsp,0x70
    2fa1:	mov    rsp,rbp
    2fa4:	pop    rbp
    2fa5:	ret
    2fa6:	mov    rax,rbx
    2fa9:	jmp    2fbc <botlish_fn_35+0x220>
    2fae:	mov    rcx,r14
    2fb1:	mov    rax,QWORD PTR [rsi+0x10]
    2fb5:	mov    QWORD PTR [rax+rdi*8],rcx
    2fb9:	mov    rax,rbx
    2fbc:	mov    rbx,QWORD PTR [rsp+0x40]
    2fc1:	mov    r12,QWORD PTR [rsp+0x48]
    2fc6:	mov    r13,QWORD PTR [rsp+0x50]
    2fcb:	mov    r14,QWORD PTR [rsp+0x58]
    2fd0:	mov    r15,QWORD PTR [rsp+0x60]
    2fd5:	add    rsp,0x70
    2fd9:	mov    rsp,rbp
    2fdc:	pop    rbp
    2fdd:	ret
    2fde:	mov    ecx,0x3
    2fe3:	mov    rdx,r12
    2fe6:	mov    rdi,r15
    2fe9:	call   2fee <botlish_fn_35+0x252>
			2fea: R_X86_64_PLT32	rt_mutarray_set-0x4
    2fee:	test   rax,rax
    2ff1:	jne    2f05 <botlish_fn_35+0x169>
    2ff7:	jmp    2f81 <botlish_fn_35+0x1e5>
    2ffc:	mov    rcx,QWORD PTR [rsp+0x30]
    3001:	jmp    3015 <botlish_fn_35+0x279>
    3006:	mov    rcx,QWORD PTR [rsp+0x30]
    300b:	jmp    3015 <botlish_fn_35+0x279>
    3010:	mov    rcx,QWORD PTR [rsp+0x30]
    3015:	mov    rdx,r12
    3018:	mov    rdi,r15
    301b:	call   3020 <botlish_fn_35+0x284>
			301c: R_X86_64_PLT32	rt_mutarray_set-0x4
    3020:	test   rax,rax
    3023:	jne    2f47 <botlish_fn_35+0x1ab>
    3029:	jmp    2f81 <botlish_fn_35+0x1e5>
    302e:	mov    rcx,r14
    3031:	mov    rdx,r12
    3034:	mov    rdi,r15
    3037:	jmp    3053 <botlish_fn_35+0x2b7>
    303c:	mov    rcx,r14
    303f:	mov    rdx,r12
    3042:	mov    rdi,r15
    3045:	jmp    3053 <botlish_fn_35+0x2b7>
    304a:	mov    rcx,r14
    304d:	mov    rdx,r12
    3050:	mov    rdi,r15
    3053:	mov    rdi,r15
    3056:	call   305b <botlish_fn_35+0x2bf>
			3057: R_X86_64_PLT32	rt_mutarray_set-0x4
    305b:	test   rax,rax
    305e:	jne    2fa6 <botlish_fn_35+0x20a>
    3064:	jmp    2f81 <botlish_fn_35+0x1e5>

0000000000003069 <botlish_entry_35: ht_rehash_insert<HashTable, int, any, any>>:
    3069:	push   rbp
    306a:	mov    rbp,rsp
    306d:	mov    rsi,QWORD PTR [rdx]
    3070:	mov    r9,QWORD PTR [rdx+0x8]
    3074:	mov    rcx,QWORD PTR [rdx+0x10]
    3078:	mov    r8,QWORD PTR [rdx+0x18]
    307c:	mov    rdx,r9
    307f:	call   3084 <botlish_entry_35+0x1b>
			3080: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    3084:	mov    rsp,rbp
    3087:	pop    rbp
    3088:	ret
    3089:	add    BYTE PTR [rax],al
    308b:	add    BYTE PTR [rax],al
    308d:	add    BYTE PTR [rax],al
	...

0000000000003090 <botlish_fn_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    3090:	push   rbp
    3091:	mov    rbp,rsp
    3094:	sub    rsp,0x90
    309b:	mov    QWORD PTR [rsp+0x60],rbx
    30a0:	mov    QWORD PTR [rsp+0x68],r12
    30a5:	mov    QWORD PTR [rsp+0x70],r13
    30aa:	mov    QWORD PTR [rsp+0x78],r14
    30af:	mov    QWORD PTR [rsp+0x80],r15
    30b7:	mov    QWORD PTR [rsp+0x38],rdi
    30bc:	mov    QWORD PTR [rsp+0x40],r9
    30c1:	mov    rax,QWORD PTR [rbp+0x10]
    30c5:	mov    r12,QWORD PTR [rbp+0x18]
    30c9:	mov    QWORD PTR [rsp],rsi
    30cd:	mov    QWORD PTR [rsp+0x8],rdx
    30d2:	mov    r15,rdx
    30d5:	mov    QWORD PTR [rsp+0x10],rcx
    30da:	mov    rbx,rcx
    30dd:	mov    QWORD PTR [rsp+0x18],rax
    30e2:	mov    QWORD PTR [rsp+0x48],rax
    30e7:	mov    QWORD PTR [rsp+0x20],r12
    30ec:	sar    r8,1
    30ef:	mov    rdx,QWORD PTR [rsp+0x40]
    30f4:	mov    r13,r8
    30f7:	cmp    r13,rdx
    30fa:	mov    QWORD PTR [rsp+0x40],rdx
    30ff:	jge    329b <botlish_fn_36+0x20b>
    3105:	mov    r14,rsi
    3108:	mov    rdx,QWORD PTR [r14+0x8]
    310c:	mov    rax,r13
    310f:	shl    rax,1
    3112:	or     rax,0x1
    3116:	sar    rax,1
    3119:	cmp    rax,rdx
    311c:	jb     312f <botlish_fn_36+0x9f>
    3122:	jmp    32c8 <botlish_fn_36+0x238>
    3127:	mov    rsi,rax
    312a:	jmp    3137 <botlish_fn_36+0xa7>
    312f:	mov    r8,QWORD PTR [r14+0x10]
    3133:	mov    rsi,QWORD PTR [r8+rax*8]
    3137:	test   rsi,0x1
    313e:	jne    3161 <botlish_fn_36+0xd1>
    3144:	mov    edx,0x3
    3149:	mov    rdi,QWORD PTR [rsp+0x38]
    314e:	call   3153 <botlish_fn_36+0xc3>
			314f: R_X86_64_PLT32	rt_value_eq-0x4
    3153:	test   rax,rax
    3156:	je     323f <botlish_fn_36+0x1af>
    315c:	jmp    3172 <botlish_fn_36+0xe2>
    3161:	mov    eax,0x2
    3166:	cmp    rsi,0x3
    316a:	cmove  rax,QWORD PTR [rip+0x1c6]        # 3338 <botlish_fn_36+0x2a8>
    3172:	cmp    rax,0x6
    3176:	je     31ad <botlish_fn_36+0x11d>
    317c:	mov    QWORD PTR [rsp],r14
    3180:	mov    QWORD PTR [rsp+0x8],r15
    3185:	mov    QWORD PTR [rsp+0x10],rbx
    318a:	mov    rax,QWORD PTR [rsp+0x48]
    318f:	mov    QWORD PTR [rsp+0x18],rax
    3194:	mov    QWORD PTR [rsp+0x20],r12
    3199:	add    r13,0x1
    31a0:	mov    rdx,QWORD PTR [rsp+0x40]
    31a5:	mov    rsi,r14
    31a8:	jmp    30f7 <botlish_fn_36+0x67>
    31ad:	mov    rdx,QWORD PTR [r15+0x8]
    31b1:	mov    rcx,r13
    31b4:	shl    rcx,1
    31b7:	or     rcx,0x1
    31bb:	sar    rcx,1
    31be:	cmp    rcx,rdx
    31c1:	jb     31d4 <botlish_fn_36+0x144>
    31c7:	jmp    32ed <botlish_fn_36+0x25d>
    31cc:	mov    rcx,rax
    31cf:	jmp    31dc <botlish_fn_36+0x14c>
    31d4:	mov    rax,QWORD PTR [r15+0x10]
    31d8:	mov    rcx,QWORD PTR [rax+rcx*8]
    31dc:	mov    QWORD PTR [rsp+0x28],rcx
    31e1:	mov    QWORD PTR [rsp+0x50],rcx
    31e6:	mov    rax,QWORD PTR [rbx+0x8]
    31ea:	mov    rcx,r13
    31ed:	shl    rcx,1
    31f0:	or     rcx,0x1
    31f4:	sar    rcx,1
    31f7:	cmp    rcx,rax
    31fa:	jb     3212 <botlish_fn_36+0x182>
    3200:	jmp    3312 <botlish_fn_36+0x282>
    3205:	mov    rsi,QWORD PTR [rsp+0x48]
    320a:	mov    r8,rax
    320d:	jmp    321f <botlish_fn_36+0x18f>
    3212:	mov    rax,QWORD PTR [rbx+0x10]
    3216:	mov    r8,QWORD PTR [rax+rcx*8]
    321a:	mov    rsi,QWORD PTR [rsp+0x48]
    321f:	mov    QWORD PTR [rsp+0x30],r8
    3224:	mov    rcx,QWORD PTR [rsp+0x50]
    3229:	mov    rdx,r12
    322c:	mov    rdi,QWORD PTR [rsp+0x38]
    3231:	call   3236 <botlish_fn_36+0x1a6>
			3232: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    3236:	test   rax,rax
    3239:	jne    326a <botlish_fn_36+0x1da>
    323f:	xor    rax,rax
    3242:	mov    rbx,QWORD PTR [rsp+0x60]
    3247:	mov    r12,QWORD PTR [rsp+0x68]
    324c:	mov    r13,QWORD PTR [rsp+0x70]
    3251:	mov    r14,QWORD PTR [rsp+0x78]
    3256:	mov    r15,QWORD PTR [rsp+0x80]
    325e:	add    rsp,0x90
    3265:	mov    rsp,rbp
    3268:	pop    rbp
    3269:	ret
    326a:	mov    QWORD PTR [rsp],r14
    326e:	mov    QWORD PTR [rsp+0x8],r15
    3273:	mov    QWORD PTR [rsp+0x10],rbx
    3278:	mov    QWORD PTR [rsp+0x18],rax
    327d:	mov    QWORD PTR [rsp+0x20],r12
    3282:	add    r13,0x1
    3289:	mov    rdx,QWORD PTR [rsp+0x40]
    328e:	mov    rsi,r14
    3291:	mov    QWORD PTR [rsp+0x48],rax
    3296:	jmp    30f7 <botlish_fn_36+0x67>
    329b:	mov    rax,QWORD PTR [rsp+0x48]
    32a0:	mov    rbx,QWORD PTR [rsp+0x60]
    32a5:	mov    r12,QWORD PTR [rsp+0x68]
    32aa:	mov    r13,QWORD PTR [rsp+0x70]
    32af:	mov    r14,QWORD PTR [rsp+0x78]
    32b4:	mov    r15,QWORD PTR [rsp+0x80]
    32bc:	add    rsp,0x90
    32c3:	mov    rsp,rbp
    32c6:	pop    rbp
    32c7:	ret
    32c8:	mov    rdx,r13
    32cb:	shl    rdx,1
    32ce:	or     rdx,0x1
    32d2:	mov    rsi,r14
    32d5:	mov    rdi,QWORD PTR [rsp+0x38]
    32da:	call   32df <botlish_fn_36+0x24f>
			32db: R_X86_64_PLT32	rt_mutarray_get-0x4
    32df:	test   rax,rax
    32e2:	jne    3127 <botlish_fn_36+0x97>
    32e8:	jmp    323f <botlish_fn_36+0x1af>
    32ed:	mov    rdx,r13
    32f0:	shl    rdx,1
    32f3:	or     rdx,0x1
    32f7:	mov    rsi,r15
    32fa:	mov    rdi,QWORD PTR [rsp+0x38]
    32ff:	call   3304 <botlish_fn_36+0x274>
			3300: R_X86_64_PLT32	rt_mutarray_get-0x4
    3304:	test   rax,rax
    3307:	jne    31cc <botlish_fn_36+0x13c>
    330d:	jmp    323f <botlish_fn_36+0x1af>
    3312:	mov    rdx,r13
    3315:	shl    rdx,1
    3318:	or     rdx,0x1
    331c:	mov    rsi,rbx
    331f:	mov    rdi,QWORD PTR [rsp+0x38]
    3324:	call   3329 <botlish_fn_36+0x299>
			3325: R_X86_64_PLT32	rt_mutarray_get-0x4
    3329:	test   rax,rax
    332c:	jne    3205 <botlish_fn_36+0x175>
    3332:	jmp    323f <botlish_fn_36+0x1af>
    3337:	add    BYTE PTR [rsi],al
    3339:	add    BYTE PTR [rax],al
    333b:	add    BYTE PTR [rax],al
    333d:	add    BYTE PTR [rax],al
	...

0000000000003340 <botlish_entry_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    3340:	push   rbp
    3341:	mov    rbp,rsp
    3344:	sub    rsp,0x10
    3348:	mov    rsi,QWORD PTR [rdx]
    334b:	mov    r11,QWORD PTR [rdx+0x8]
    334f:	mov    rcx,QWORD PTR [rdx+0x10]
    3353:	mov    r8,QWORD PTR [rdx+0x18]
    3357:	mov    r9,QWORD PTR [rdx+0x20]
    335b:	mov    rax,QWORD PTR [rdx+0x28]
    335f:	mov    rdx,QWORD PTR [rdx+0x30]
    3363:	sar    r9,1
    3366:	mov    QWORD PTR [rsp],rax
    336a:	mov    QWORD PTR [rsp+0x8],rdx
    336f:	mov    rdx,r11
    3372:	call   3377 <botlish_entry_36+0x37>
			3373: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    3377:	add    rsp,0x10
    337b:	mov    rsp,rbp
    337e:	pop    rbp
    337f:	ret

0000000000003380 <botlish_fn_37: ht_rehash<HashTable, int>>:
    3380:	push   rbp
    3381:	mov    rbp,rsp
    3384:	sub    rsp,0x100
    338b:	mov    QWORD PTR [rsp+0xd0],rbx
    3393:	mov    QWORD PTR [rsp+0xd8],r12
    339b:	mov    QWORD PTR [rsp+0xe0],r13
    33a3:	mov    QWORD PTR [rsp+0xe8],r14
    33ab:	mov    QWORD PTR [rsp+0xf0],r15
    33b3:	mov    QWORD PTR [rsp+0x98],rdi
    33bb:	mov    QWORD PTR [rsp+0x20],0x0
    33c4:	mov    QWORD PTR [rsp+0x28],0x0
    33cd:	mov    QWORD PTR [rsp+0x30],0x0
    33d6:	mov    QWORD PTR [rsp+0x38],0x0
    33df:	mov    QWORD PTR [rsp+0x40],0x0
    33e8:	mov    QWORD PTR [rsp+0x48],0x0
    33f1:	mov    QWORD PTR [rsp+0x50],0x0
    33fa:	mov    QWORD PTR [rsp+0x58],0x0
    3403:	mov    QWORD PTR [rsp+0x10],rsi
    3408:	mov    rbx,rsi
    340b:	mov    QWORD PTR [rsp+0x18],rdx
    3410:	mov    QWORD PTR [rsp+0xa0],rdx
    3418:	lea    rdx,[rsp+0x60]
    341d:	mov    rsi,QWORD PTR [rsp+0xa0]
    3425:	mov    rdi,QWORD PTR [rsp+0x98]
    342d:	call   3432 <botlish_fn_37+0xb2>
			342e: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    3432:	test   rax,rax
    3435:	je     35a2 <botlish_fn_37+0x222>
    343b:	mov    QWORD PTR [rsp+0x20],rax
    3440:	mov    QWORD PTR [rsp+0xc0],rax
    3448:	mov    rcx,QWORD PTR [rsp+0x60]
    344d:	mov    QWORD PTR [rsp+0x28],rcx
    3452:	mov    QWORD PTR [rsp+0xb8],rcx
    345a:	mov    rcx,QWORD PTR [rsp+0x68]
    345f:	mov    QWORD PTR [rsp+0x30],rcx
    3464:	mov    QWORD PTR [rsp+0xb0],rcx
    346c:	mov    r13,QWORD PTR [rsp+0x70]
    3471:	mov    QWORD PTR [rsp+0x38],r13
    3476:	mov    rsi,rbx
    3479:	mov    rdi,QWORD PTR [rsp+0x98]
    3481:	call   3486 <botlish_fn_37+0x106>
			3482: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3486:	test   rax,rax
    3489:	mov    rcx,rax
    348c:	je     35a2 <botlish_fn_37+0x222>
    3492:	mov    rax,QWORD PTR [r13+0x8]
    3496:	test   rax,rax
    3499:	je     360d <botlish_fn_37+0x28d>
    349f:	mov    rax,QWORD PTR [r13+0x18]
    34a3:	test   rax,rax
    34a6:	jne    34b9 <botlish_fn_37+0x139>
    34ac:	jmp    360d <botlish_fn_37+0x28d>
    34b1:	mov    rsi,rbx
    34b4:	jmp    34c3 <botlish_fn_37+0x143>
    34b9:	mov    rax,QWORD PTR [r13+0x10]
    34bd:	mov    QWORD PTR [rax],rcx
    34c0:	mov    rsi,rbx
    34c3:	mov    rdx,QWORD PTR [rsi+0x18]
    34c7:	mov    r14,QWORD PTR [rdx]
    34ca:	mov    QWORD PTR [rsp+0x40],r14
    34cf:	mov    rdi,QWORD PTR [rsi+0x18]
    34d3:	mov    r15,QWORD PTR [rdi+0x8]
    34d7:	mov    QWORD PTR [rsp+0x48],r15
    34dc:	mov    rdi,QWORD PTR [rsi+0x18]
    34e0:	mov    rbx,QWORD PTR [rdi+0x10]
    34e4:	mov    QWORD PTR [rsp+0x50],rbx
    34e9:	mov    r12d,0x1
    34ef:	mov    QWORD PTR [rsp+0x58],0x1
    34f8:	mov    rdi,QWORD PTR [rsp+0x98]
    3500:	call   3505 <botlish_fn_37+0x185>
			3501: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3505:	mov    QWORD PTR [rsp+0xa8],rax
    350d:	lea    rcx,[rsp+0x78]
    3512:	mov    rax,QWORD PTR [rsp+0xc0]
    351a:	mov    QWORD PTR [rsp+0x78],rax
    351f:	mov    rax,QWORD PTR [rsp+0xb8]
    3527:	mov    QWORD PTR [rsp+0x80],rax
    352f:	mov    rax,QWORD PTR [rsp+0xb0]
    3537:	mov    QWORD PTR [rsp+0x88],rax
    353f:	mov    QWORD PTR [rsp+0x90],r13
    3547:	xor    rsi,rsi
    354a:	mov    edx,0x4
    354f:	mov    rdi,QWORD PTR [rsp+0x98]
    3557:	call   355c <botlish_fn_37+0x1dc>
			3558: R_X86_64_PLT32	rt_struct_new-0x4
    355c:	mov    QWORD PTR [rsp+0x10],rax
    3561:	mov    rcx,QWORD PTR [rsp+0xa8]
    3569:	mov    r9,rcx
    356c:	sar    r9,1
    356f:	mov    QWORD PTR [rsp],rax
    3573:	mov    rdx,QWORD PTR [rsp+0xa0]
    357b:	mov    QWORD PTR [rsp+0x8],rdx
    3580:	mov    rcx,rbx
    3583:	mov    rdx,r15
    3586:	mov    rsi,r14
    3589:	mov    rdi,QWORD PTR [rsp+0x98]
    3591:	mov    r8,r12
    3594:	call   3599 <botlish_fn_37+0x219>
			3595: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    3599:	test   rax,rax
    359c:	jne    35d9 <botlish_fn_37+0x259>
    35a2:	xor    rax,rax
    35a5:	mov    rbx,QWORD PTR [rsp+0xd0]
    35ad:	mov    r12,QWORD PTR [rsp+0xd8]
    35b5:	mov    r13,QWORD PTR [rsp+0xe0]
    35bd:	mov    r14,QWORD PTR [rsp+0xe8]
    35c5:	mov    r15,QWORD PTR [rsp+0xf0]
    35cd:	add    rsp,0x100
    35d4:	mov    rsp,rbp
    35d7:	pop    rbp
    35d8:	ret
    35d9:	mov    rbx,QWORD PTR [rsp+0xd0]
    35e1:	mov    r12,QWORD PTR [rsp+0xd8]
    35e9:	mov    r13,QWORD PTR [rsp+0xe0]
    35f1:	mov    r14,QWORD PTR [rsp+0xe8]
    35f9:	mov    r15,QWORD PTR [rsp+0xf0]
    3601:	add    rsp,0x100
    3608:	mov    rsp,rbp
    360b:	pop    rbp
    360c:	ret
    360d:	mov    edx,0x1
    3612:	mov    rsi,r13
    3615:	mov    rdi,QWORD PTR [rsp+0x98]
    361d:	call   3622 <botlish_fn_37+0x2a2>
			361e: R_X86_64_PLT32	rt_mutarray_set-0x4
    3622:	test   rax,rax
    3625:	jne    34b1 <botlish_fn_37+0x131>
    362b:	jmp    35a2 <botlish_fn_37+0x222>

0000000000003630 <botlish_entry_37: ht_rehash<HashTable, int>>:
    3630:	push   rbp
    3631:	mov    rbp,rsp
    3634:	mov    rsi,QWORD PTR [rdx]
    3637:	mov    rdx,QWORD PTR [rdx+0x8]
    363b:	call   3640 <botlish_entry_37+0x10>
			363c: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3640:	mov    rsp,rbp
    3643:	pop    rbp
    3644:	ret
    3645:	add    BYTE PTR [rax],al
	...

0000000000003648 <botlish_fn_38: ht_should_grow<HashTable>>:
    3648:	push   rbp
    3649:	mov    rbp,rsp
    364c:	sub    rsp,0x40
    3650:	mov    QWORD PTR [rsp+0x20],rbx
    3655:	mov    QWORD PTR [rsp+0x28],r12
    365a:	mov    QWORD PTR [rsp+0x30],r13
    365f:	mov    rbx,rdi
    3662:	mov    QWORD PTR [rsp],rsi
    3666:	mov    r12,rsi
    3669:	mov    rsi,r12
    366c:	mov    rdi,rbx
    366f:	call   3674 <botlish_fn_38+0x2c>
			3670: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3674:	mov    rcx,rax
    3677:	mov    r13,rax
    367a:	test   rax,rcx
    367d:	je     3756 <botlish_fn_38+0x10e>
    3683:	mov    rax,r13
    3686:	mov    QWORD PTR [rsp+0x8],rax
    368b:	mov    rsi,r12
    368e:	mov    rdi,rbx
    3691:	call   3696 <botlish_fn_38+0x4e>
			3692: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3696:	mov    rcx,rax
    3699:	test   rcx,rcx
    369c:	je     3756 <botlish_fn_38+0x10e>
    36a2:	mov    QWORD PTR [rsp+0x10],rcx
    36a7:	mov    edx,0x1
    36ac:	mov    rax,r13
    36af:	test   rax,0x1
    36b5:	jne    36d8 <botlish_fn_38+0x90>
    36bb:	xor    edx,edx
    36bd:	mov    rax,r13
    36c0:	test   rax,0x7
    36c6:	jne    36d8 <botlish_fn_38+0x90>
    36cc:	mov    rax,r13
    36cf:	movzx  rax,BYTE PTR [rax]
    36d3:	cmp    al,0x1
    36d5:	sete   dl
    36d8:	test   dl,dl
    36da:	jne    36fb <botlish_fn_38+0xb3>
    36e0:	mov    rdi,rbx
    36e3:	mov    rax,QWORD PTR [rdi+0x10]
    36e7:	mov    rcx,QWORD PTR [rax+0x8]
    36eb:	xor    rdx,rdx
    36ee:	mov    rsi,r13
    36f1:	call   36f6 <botlish_fn_38+0xae>
			36f2: R_X86_64_PLT32	rt_type_error-0x4
    36f6:	jmp    3756 <botlish_fn_38+0x10e>
    36fb:	mov    eax,0x1
    3700:	test   rcx,0x1
    3707:	je     3715 <botlish_fn_38+0xcd>
    370d:	mov    r8,rcx
    3710:	jmp    3738 <botlish_fn_38+0xf0>
    3715:	xor    eax,eax
    3717:	test   rcx,0x7
    371e:	je     372c <botlish_fn_38+0xe4>
    3724:	mov    r8,rcx
    3727:	jmp    3738 <botlish_fn_38+0xf0>
    372c:	movzx  rax,BYTE PTR [rcx]
    3730:	mov    r8,rcx
    3733:	cmp    al,0x1
    3735:	sete   al
    3738:	test   al,al
    373a:	jne    3771 <botlish_fn_38+0x129>
    3740:	mov    rdi,rbx
    3743:	mov    rax,QWORD PTR [rdi+0x10]
    3747:	mov    rcx,QWORD PTR [rax+0x8]
    374b:	xor    rdx,rdx
    374e:	mov    rsi,r8
    3751:	call   3756 <botlish_fn_38+0x10e>
			3752: R_X86_64_PLT32	rt_type_error-0x4
    3756:	xor    rax,rax
    3759:	mov    rbx,QWORD PTR [rsp+0x20]
    375e:	mov    r12,QWORD PTR [rsp+0x28]
    3763:	mov    r13,QWORD PTR [rsp+0x30]
    3768:	add    rsp,0x40
    376c:	mov    rsp,rbp
    376f:	pop    rbp
    3770:	ret
    3771:	mov    rcx,r8
    3774:	mov    rsi,r13
    3777:	mov    rax,rsi
    377a:	and    rax,rcx
    377d:	test   rax,0x1
    3783:	jne    3794 <botlish_fn_38+0x14c>
    3789:	mov    rdx,r8
    378c:	mov    rsi,r13
    378f:	jmp    37b2 <botlish_fn_38+0x16a>
    3794:	mov    rcx,r8
    3797:	lea    rax,[rcx-0x1]
    379b:	mov    rsi,r13
    379e:	add    rsi,rax
    37a1:	seto   al
    37a4:	test   al,al
    37a6:	je     37bd <botlish_fn_38+0x175>
    37ac:	mov    rdx,r8
    37af:	mov    rsi,r13
    37b2:	mov    rdi,rbx
    37b5:	call   37ba <botlish_fn_38+0x172>
			37b6: R_X86_64_PLT32	rt_int_add-0x4
    37ba:	mov    rsi,rax
    37bd:	mov    QWORD PTR [rsp+0x8],rsi
    37c2:	mov    QWORD PTR [rsp+0x10],0x3
    37cb:	test   rsi,0x1
    37d2:	je     37f5 <botlish_fn_38+0x1ad>
    37d8:	mov    rax,rsi
    37db:	add    rax,0x2
    37df:	mov    rcx,rax
    37e2:	seto   al
    37e5:	test   al,al
    37e7:	jne    37f5 <botlish_fn_38+0x1ad>
    37ed:	mov    rsi,rcx
    37f0:	jmp    3805 <botlish_fn_38+0x1bd>
    37f5:	mov    edx,0x3
    37fa:	mov    rdi,rbx
    37fd:	call   3802 <botlish_fn_38+0x1ba>
			37fe: R_X86_64_PLT32	rt_int_add-0x4
    3802:	mov    rsi,rax
    3805:	mov    QWORD PTR [rsp+0x8],rsi
    380a:	mov    edx,0x7
    380f:	mov    rdi,rdx
    3812:	mov    QWORD PTR [rsp+0x10],0x7
    381b:	test   rsi,0x1
    3822:	jne    3830 <botlish_fn_38+0x1e8>
    3828:	mov    rdx,rdi
    382b:	jmp    385c <botlish_fn_38+0x214>
    3830:	mov    rax,rsi
    3833:	sar    rax,1
    3836:	imul   QWORD PTR [rip+0xf3]        # 3930 <botlish_fn_38+0x2e8>
    383d:	seto   cl
    3840:	or     rax,0x1
    3844:	test   cl,cl
    3846:	je     3854 <botlish_fn_38+0x20c>
    384c:	mov    rdx,rdi
    384f:	jmp    385c <botlish_fn_38+0x214>
    3854:	mov    rsi,rax
    3857:	jmp    3867 <botlish_fn_38+0x21f>
    385c:	mov    rdi,rbx
    385f:	call   3864 <botlish_fn_38+0x21c>
			3860: R_X86_64_PLT32	rt_int_mul-0x4
    3864:	mov    rsi,rax
    3867:	mov    QWORD PTR [rsp+0x8],rsi
    386c:	mov    r13,rsi
    386f:	mov    rsi,r12
    3872:	mov    rdi,rbx
    3875:	call   387a <botlish_fn_38+0x232>
			3876: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    387a:	mov    QWORD PTR [rsp],rax
    387e:	mov    QWORD PTR [rsp+0x10],0x5
    3887:	test   rax,0x1
    388d:	mov    rcx,rax
    3890:	je     38bf <botlish_fn_38+0x277>
    3896:	mov    rax,rcx
    3899:	sar    rax,1
    389c:	imul   QWORD PTR [rip+0x95]        # 3938 <botlish_fn_38+0x2f0>
    38a3:	seto   sil
    38a7:	or     rax,0x1
    38ab:	test   sil,sil
    38ae:	jne    38bf <botlish_fn_38+0x277>
    38b4:	mov    rdx,rax
    38b7:	mov    rsi,r13
    38ba:	jmp    38d5 <botlish_fn_38+0x28d>
    38bf:	mov    edx,0x5
    38c4:	mov    rsi,rcx
    38c7:	mov    rdi,rbx
    38ca:	call   38cf <botlish_fn_38+0x287>
			38cb: R_X86_64_PLT32	rt_int_mul-0x4
    38cf:	mov    rdx,rax
    38d2:	mov    rsi,r13
    38d5:	mov    rdi,rsi
    38d8:	and    rdi,rdx
    38db:	test   rdi,0x1
    38e2:	jne    3908 <botlish_fn_38+0x2c0>
    38e8:	mov    rdi,rbx
    38eb:	call   38f0 <botlish_fn_38+0x2a8>
			38ec: R_X86_64_PLT32	rt_int_cmp-0x4
    38f0:	mov    esi,0x2
    38f5:	test   rax,rax
    38f8:	mov    rax,rsi
    38fb:	cmovg  rax,QWORD PTR [rip+0x2d]        # 3930 <botlish_fn_38+0x2e8>
    3903:	jmp    3918 <botlish_fn_38+0x2d0>
    3908:	mov    eax,0x2
    390d:	cmp    rsi,rdx
    3910:	cmovg  rax,QWORD PTR [rip+0x18]        # 3930 <botlish_fn_38+0x2e8>
    3918:	mov    rbx,QWORD PTR [rsp+0x20]
    391d:	mov    r12,QWORD PTR [rsp+0x28]
    3922:	mov    r13,QWORD PTR [rsp+0x30]
    3927:	add    rsp,0x40
    392b:	mov    rsp,rbp
    392e:	pop    rbp
    392f:	ret
    3930:	(bad)
    3931:	add    BYTE PTR [rax],al
    3933:	add    BYTE PTR [rax],al
    3935:	add    BYTE PTR [rax],al
    3937:	add    BYTE PTR [rax+rax*1],al
    393a:	add    BYTE PTR [rax],al
    393c:	add    BYTE PTR [rax],al
	...

0000000000003940 <botlish_entry_38: ht_should_grow<HashTable>>:
    3940:	push   rbp
    3941:	mov    rbp,rsp
    3944:	mov    rsi,QWORD PTR [rdx]
    3947:	call   394c <botlish_entry_38+0xc>
			3948: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    394c:	mov    rsp,rbp
    394f:	pop    rbp
    3950:	ret
    3951:	add    BYTE PTR [rax],al
    3953:	add    BYTE PTR [rax],al
    3955:	add    BYTE PTR [rax],al
	...

0000000000003958 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    3958:	push   rbp
    3959:	mov    rbp,rsp
    395c:	sub    rsp,0x40
    3960:	mov    QWORD PTR [rsp+0x20],rbx
    3965:	mov    QWORD PTR [rsp+0x28],r12
    396a:	mov    QWORD PTR [rsp+0x30],r13
    396f:	mov    rbx,rdi
    3972:	mov    QWORD PTR [rsp+0x10],0x0
    397b:	mov    QWORD PTR [rsp],rsi
    397f:	mov    r12,rsi
    3982:	mov    rsi,r12
    3985:	mov    rdi,rbx
    3988:	call   398d <botlish_fn_39+0x35>
			3989: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    398d:	test   rax,rax
    3990:	mov    r13,rax
    3993:	je     3b81 <botlish_fn_39+0x229>
    3999:	mov    rsi,r12
    399c:	mov    rdi,rbx
    399f:	call   39a4 <botlish_fn_39+0x4c>
			39a0: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    39a4:	mov    r11,rax
    39a7:	test   r11,r11
    39aa:	je     3b81 <botlish_fn_39+0x229>
    39b0:	mov    ecx,0x1
    39b5:	mov    rax,r13
    39b8:	test   rax,0x1
    39be:	je     39cc <botlish_fn_39+0x74>
    39c4:	mov    r13,rax
    39c7:	jmp    39f0 <botlish_fn_39+0x98>
    39cc:	xor    ecx,ecx
    39ce:	test   rax,0x7
    39d4:	je     39e2 <botlish_fn_39+0x8a>
    39da:	mov    r13,rax
    39dd:	jmp    39f0 <botlish_fn_39+0x98>
    39e2:	movzx  rcx,BYTE PTR [rax]
    39e6:	mov    r13,rax
    39e9:	rex cmp cl,0x1
    39ed:	sete   cl
    39f0:	test   cl,cl
    39f2:	jne    3a13 <botlish_fn_39+0xbb>
    39f8:	mov    rdi,rbx
    39fb:	mov    rsi,QWORD PTR [rdi+0x10]
    39ff:	mov    rcx,QWORD PTR [rsi+0x10]
    3a03:	xor    rdx,rdx
    3a06:	mov    rsi,r13
    3a09:	call   3a0e <botlish_fn_39+0xb6>
			3a0a: R_X86_64_PLT32	rt_type_error-0x4
    3a0e:	jmp    3b81 <botlish_fn_39+0x229>
    3a13:	mov    rsi,r13
    3a16:	mov    eax,0x1
    3a1b:	test   r11,0x1
    3a22:	je     3a30 <botlish_fn_39+0xd8>
    3a28:	mov    r8,r11
    3a2b:	jmp    3a55 <botlish_fn_39+0xfd>
    3a30:	xor    eax,eax
    3a32:	test   r11,0x7
    3a39:	je     3a47 <botlish_fn_39+0xef>
    3a3f:	mov    r8,r11
    3a42:	jmp    3a55 <botlish_fn_39+0xfd>
    3a47:	movzx  r10,BYTE PTR [r11]
    3a4b:	mov    r8,r11
    3a4e:	cmp    r10b,0x1
    3a52:	sete   al
    3a55:	test   al,al
    3a57:	jne    3a78 <botlish_fn_39+0x120>
    3a5d:	mov    rdi,rbx
    3a60:	mov    rax,QWORD PTR [rdi+0x10]
    3a64:	mov    rcx,QWORD PTR [rax+0x10]
    3a68:	xor    rdx,rdx
    3a6b:	mov    rsi,r8
    3a6e:	call   3a73 <botlish_fn_39+0x11b>
			3a6f: R_X86_64_PLT32	rt_type_error-0x4
    3a73:	jmp    3b81 <botlish_fn_39+0x229>
    3a78:	mov    r11,r8
    3a7b:	mov    rax,rsi
    3a7e:	and    rax,r11
    3a81:	test   rax,0x1
    3a87:	jne    3aad <botlish_fn_39+0x155>
    3a8d:	mov    rdx,r8
    3a90:	mov    rdi,rbx
    3a93:	call   3a98 <botlish_fn_39+0x140>
			3a94: R_X86_64_PLT32	rt_int_cmp-0x4
    3a98:	mov    ecx,0x2
    3a9d:	test   rax,rax
    3aa0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3bb8 <botlish_fn_39+0x260>
    3aa8:	jmp    3ac0 <botlish_fn_39+0x168>
    3aad:	mov    ecx,0x2
    3ab2:	mov    r11,r8
    3ab5:	cmp    rsi,r11
    3ab8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3bb8 <botlish_fn_39+0x260>
    3ac0:	cmp    rcx,0x6
    3ac4:	je     3b5a <botlish_fn_39+0x202>
    3aca:	mov    rsi,r12
    3acd:	mov    rdi,rbx
    3ad0:	call   3ad5 <botlish_fn_39+0x17d>
			3ad1: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3ad5:	mov    QWORD PTR [rsp+0x8],rax
    3ada:	mov    QWORD PTR [rsp+0x10],0x5
    3ae3:	test   rax,0x1
    3ae9:	mov    rsi,rax
    3aec:	je     3b19 <botlish_fn_39+0x1c1>
    3af2:	mov    rcx,rsi
    3af5:	mov    rax,rcx
    3af8:	sar    rax,1
    3afb:	imul   QWORD PTR [rip+0xbe]        # 3bc0 <botlish_fn_39+0x268>
    3b02:	seto   cl
    3b05:	or     rax,0x1
    3b09:	test   cl,cl
    3b0b:	jne    3b19 <botlish_fn_39+0x1c1>
    3b11:	mov    rdx,rax
    3b14:	jmp    3b29 <botlish_fn_39+0x1d1>
    3b19:	mov    edx,0x5
    3b1e:	mov    rdi,rbx
    3b21:	call   3b26 <botlish_fn_39+0x1ce>
			3b22: R_X86_64_PLT32	rt_int_mul-0x4
    3b26:	mov    rdx,rax
    3b29:	mov    QWORD PTR [rsp+0x8],rdx
    3b2e:	mov    rsi,r12
    3b31:	mov    rdi,rbx
    3b34:	call   3b39 <botlish_fn_39+0x1e1>
			3b35: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3b39:	test   rax,rax
    3b3c:	je     3b81 <botlish_fn_39+0x229>
    3b42:	mov    rbx,QWORD PTR [rsp+0x20]
    3b47:	mov    r12,QWORD PTR [rsp+0x28]
    3b4c:	mov    r13,QWORD PTR [rsp+0x30]
    3b51:	add    rsp,0x40
    3b55:	mov    rsp,rbp
    3b58:	pop    rbp
    3b59:	ret
    3b5a:	mov    rsi,r12
    3b5d:	mov    rdi,rbx
    3b60:	call   3b65 <botlish_fn_39+0x20d>
			3b61: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3b65:	mov    QWORD PTR [rsp+0x8],rax
    3b6a:	mov    rdx,rax
    3b6d:	mov    rsi,r12
    3b70:	mov    rdi,rbx
    3b73:	call   3b78 <botlish_fn_39+0x220>
			3b74: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3b78:	test   rax,rax
    3b7b:	jne    3b9c <botlish_fn_39+0x244>
    3b81:	xor    rax,rax
    3b84:	mov    rbx,QWORD PTR [rsp+0x20]
    3b89:	mov    r12,QWORD PTR [rsp+0x28]
    3b8e:	mov    r13,QWORD PTR [rsp+0x30]
    3b93:	add    rsp,0x40
    3b97:	mov    rsp,rbp
    3b9a:	pop    rbp
    3b9b:	ret
    3b9c:	mov    rbx,QWORD PTR [rsp+0x20]
    3ba1:	mov    r12,QWORD PTR [rsp+0x28]
    3ba6:	mov    r13,QWORD PTR [rsp+0x30]
    3bab:	add    rsp,0x40
    3baf:	mov    rsp,rbp
    3bb2:	pop    rbp
    3bb3:	ret
    3bb4:	add    BYTE PTR [rax],al
    3bb6:	add    BYTE PTR [rax],al
    3bb8:	(bad)
    3bb9:	add    BYTE PTR [rax],al
    3bbb:	add    BYTE PTR [rax],al
    3bbd:	add    BYTE PTR [rax],al
    3bbf:	add    BYTE PTR [rax+rax*1],al
    3bc2:	add    BYTE PTR [rax],al
    3bc4:	add    BYTE PTR [rax],al
	...

0000000000003bc8 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    3bc8:	push   rbp
    3bc9:	mov    rbp,rsp
    3bcc:	mov    rsi,QWORD PTR [rdx]
    3bcf:	call   3bd4 <botlish_entry_39+0xc>
			3bd0: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3bd4:	mov    rsp,rbp
    3bd7:	pop    rbp
    3bd8:	ret
    3bd9:	add    BYTE PTR [rax],al
    3bdb:	add    BYTE PTR [rax],al
    3bdd:	add    BYTE PTR [rax],al
	...

0000000000003be0 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    3be0:	push   rbp
    3be1:	mov    rbp,rsp
    3be4:	sub    rsp,0x70
    3be8:	mov    QWORD PTR [rsp+0x40],rbx
    3bed:	mov    QWORD PTR [rsp+0x48],r12
    3bf2:	mov    QWORD PTR [rsp+0x50],r13
    3bf7:	mov    QWORD PTR [rsp+0x58],r14
    3bfc:	mov    QWORD PTR [rsp+0x60],r15
    3c01:	mov    r12,rdi
    3c04:	mov    r14,r8
    3c07:	mov    QWORD PTR [rsp+0x30],rcx
    3c0c:	mov    QWORD PTR [rsp],rsi
    3c10:	mov    rax,QWORD PTR [rsi+0x18]
    3c14:	mov    rbx,rsi
    3c17:	mov    rsi,QWORD PTR [rax]
    3c1a:	test   rdx,0x1
    3c21:	je     3fc7 <botlish_fn_40+0x3e7>
    3c27:	mov    rcx,QWORD PTR [rsi+0x8]
    3c2b:	mov    rax,rdx
    3c2e:	sar    rax,1
    3c31:	mov    r15,rdx
    3c34:	cmp    rax,rcx
    3c37:	jb     3c4a <botlish_fn_40+0x6a>
    3c3d:	jmp    3fca <botlish_fn_40+0x3ea>
    3c42:	mov    rsi,rax
    3c45:	jmp    3c52 <botlish_fn_40+0x72>
    3c4a:	mov    rcx,QWORD PTR [rsi+0x10]
    3c4e:	mov    rsi,QWORD PTR [rcx+rax*8]
    3c52:	mov    QWORD PTR [rsp+0x8],rsi
    3c57:	mov    r13,rsi
    3c5a:	mov    rax,QWORD PTR [rbx+0x18]
    3c5e:	mov    rsi,QWORD PTR [rax]
    3c61:	mov    rdx,r15
    3c64:	test   rdx,0x1
    3c6b:	je     3fe3 <botlish_fn_40+0x403>
    3c71:	mov    rcx,QWORD PTR [rsi+0x8]
    3c75:	mov    rdx,r15
    3c78:	mov    rax,rdx
    3c7b:	sar    rax,1
    3c7e:	cmp    rax,rcx
    3c81:	jae    3fe3 <botlish_fn_40+0x403>
    3c87:	mov    rcx,QWORD PTR [rsi+0x18]
    3c8b:	test   rcx,rcx
    3c8e:	je     3fe3 <botlish_fn_40+0x403>
    3c94:	mov    rcx,QWORD PTR [rsi+0x10]
    3c98:	mov    QWORD PTR [rcx+rax*8],0x3
    3ca0:	mov    rax,QWORD PTR [rbx+0x18]
    3ca4:	mov    rsi,QWORD PTR [rax+0x8]
    3ca8:	mov    rdx,r15
    3cab:	test   rdx,0x1
    3cb2:	je     4001 <botlish_fn_40+0x421>
    3cb8:	mov    rcx,QWORD PTR [rsi+0x8]
    3cbc:	mov    rdx,r15
    3cbf:	mov    rax,rdx
    3cc2:	sar    rax,1
    3cc5:	cmp    rax,rcx
    3cc8:	jae    400b <botlish_fn_40+0x42b>
    3cce:	mov    rcx,QWORD PTR [rsi+0x18]
    3cd2:	test   rcx,rcx
    3cd5:	je     4015 <botlish_fn_40+0x435>
    3cdb:	mov    rcx,QWORD PTR [rsp+0x30]
    3ce0:	mov    r8,QWORD PTR [rsi+0x10]
    3ce4:	mov    QWORD PTR [r8+rax*8],rcx
    3ce8:	mov    r10,QWORD PTR [rbx+0x18]
    3cec:	mov    rsi,QWORD PTR [r10+0x10]
    3cf0:	mov    rdx,r15
    3cf3:	test   rdx,0x1
    3cfa:	je     4033 <botlish_fn_40+0x453>
    3d00:	mov    rcx,QWORD PTR [rsi+0x8]
    3d04:	mov    rdx,r15
    3d07:	mov    rax,rdx
    3d0a:	sar    rax,1
    3d0d:	cmp    rax,rcx
    3d10:	jae    403e <botlish_fn_40+0x45e>
    3d16:	mov    rcx,QWORD PTR [rsi+0x18]
    3d1a:	test   rcx,rcx
    3d1d:	je     4049 <botlish_fn_40+0x469>
    3d23:	mov    rcx,r14
    3d26:	mov    rdx,QWORD PTR [rsi+0x10]
    3d2a:	mov    QWORD PTR [rdx+rax*8],rcx
    3d2e:	mov    rax,QWORD PTR [rbx+0x18]
    3d32:	mov    rsi,QWORD PTR [rax+0x18]
    3d36:	mov    QWORD PTR [rsp+0x10],rsi
    3d3b:	mov    r15,rsi
    3d3e:	mov    QWORD PTR [rsp+0x18],0x1
    3d47:	mov    rsi,rbx
    3d4a:	mov    rdi,r12
    3d4d:	call   3d52 <botlish_fn_40+0x172>
			3d4e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3d52:	test   rax,rax
    3d55:	je     3f70 <botlish_fn_40+0x390>
    3d5b:	mov    QWORD PTR [rsp+0x20],rax
    3d60:	mov    edx,0x3
    3d65:	mov    r14,rdx
    3d68:	mov    QWORD PTR [rsp+0x28],0x3
    3d71:	mov    ecx,0x1
    3d76:	test   rax,0x1
    3d7c:	je     3d8a <botlish_fn_40+0x1aa>
    3d82:	mov    rsi,rax
    3d85:	jmp    3dae <botlish_fn_40+0x1ce>
    3d8a:	xor    ecx,ecx
    3d8c:	test   rax,0x7
    3d92:	je     3da0 <botlish_fn_40+0x1c0>
    3d98:	mov    rsi,rax
    3d9b:	jmp    3dae <botlish_fn_40+0x1ce>
    3da0:	movzx  rcx,BYTE PTR [rax]
    3da4:	mov    rsi,rax
    3da7:	rex cmp cl,0x1
    3dab:	sete   cl
    3dae:	test   cl,cl
    3db0:	jne    3dce <botlish_fn_40+0x1ee>
    3db6:	mov    rdi,r12
    3db9:	mov    rax,QWORD PTR [rdi+0x10]
    3dbd:	mov    rcx,QWORD PTR [rax+0x8]
    3dc1:	xor    rdx,rdx
    3dc4:	call   3dc9 <botlish_fn_40+0x1e9>
			3dc5: R_X86_64_PLT32	rt_type_error-0x4
    3dc9:	jmp    3f70 <botlish_fn_40+0x390>
    3dce:	test   rsi,0x1
    3dd5:	je     3ded <botlish_fn_40+0x20d>
    3ddb:	mov    rcx,rsi
    3dde:	add    rcx,0x2
    3de2:	seto   al
    3de5:	test   al,al
    3de7:	je     3dfb <botlish_fn_40+0x21b>
    3ded:	mov    rdx,r14
    3df0:	mov    rdi,r12
    3df3:	call   3df8 <botlish_fn_40+0x218>
			3df4: R_X86_64_PLT32	rt_int_add-0x4
    3df8:	mov    rcx,rax
    3dfb:	mov    rsi,r15
    3dfe:	mov    rax,QWORD PTR [rsi+0x8]
    3e02:	test   rax,rax
    3e05:	je     4068 <botlish_fn_40+0x488>
    3e0b:	mov    rax,QWORD PTR [rsi+0x18]
    3e0f:	test   rax,rax
    3e12:	jne    3e25 <botlish_fn_40+0x245>
    3e18:	jmp    4068 <botlish_fn_40+0x488>
    3e1d:	mov    rsi,r13
    3e20:	jmp    3e2f <botlish_fn_40+0x24f>
    3e25:	mov    rax,QWORD PTR [rsi+0x10]
    3e29:	mov    QWORD PTR [rax],rcx
    3e2c:	mov    rsi,r13
    3e2f:	test   rsi,0x1
    3e36:	jne    3e5e <botlish_fn_40+0x27e>
    3e3c:	mov    edx,0x5
    3e41:	mov    rdi,r12
    3e44:	call   3e49 <botlish_fn_40+0x269>
			3e45: R_X86_64_PLT32	rt_int_cmp-0x4
    3e49:	mov    ecx,0x2
    3e4e:	test   rax,rax
    3e51:	cmove  rcx,QWORD PTR [rip+0x257]        # 40b0 <botlish_fn_40+0x4d0>
    3e59:	jmp    3e6f <botlish_fn_40+0x28f>
    3e5e:	mov    ecx,0x2
    3e63:	cmp    rsi,0x5
    3e67:	cmove  rcx,QWORD PTR [rip+0x241]        # 40b0 <botlish_fn_40+0x4d0>
    3e6f:	cmp    rcx,0x6
    3e73:	je     3e81 <botlish_fn_40+0x2a1>
    3e79:	mov    rax,rbx
    3e7c:	jmp    3fa5 <botlish_fn_40+0x3c5>
    3e81:	mov    r10,QWORD PTR [rbx+0x18]
    3e85:	mov    rsi,QWORD PTR [r10+0x18]
    3e89:	mov    QWORD PTR [rsp+0x8],rsi
    3e8e:	mov    r13,rsi
    3e91:	mov    QWORD PTR [rsp+0x10],0x3
    3e9a:	mov    rsi,rbx
    3e9d:	mov    rdi,r12
    3ea0:	call   3ea5 <botlish_fn_40+0x2c5>
			3ea1: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3ea5:	test   rax,rax
    3ea8:	je     3f70 <botlish_fn_40+0x390>
    3eae:	mov    QWORD PTR [rsp+0x18],rax
    3eb3:	mov    QWORD PTR [rsp+0x20],0x3
    3ebc:	mov    ecx,0x1
    3ec1:	test   rax,0x1
    3ec7:	je     3ed5 <botlish_fn_40+0x2f5>
    3ecd:	mov    rsi,rax
    3ed0:	jmp    3ef9 <botlish_fn_40+0x319>
    3ed5:	xor    ecx,ecx
    3ed7:	test   rax,0x7
    3edd:	je     3eeb <botlish_fn_40+0x30b>
    3ee3:	mov    rsi,rax
    3ee6:	jmp    3ef9 <botlish_fn_40+0x319>
    3eeb:	movzx  rcx,BYTE PTR [rax]
    3eef:	mov    rsi,rax
    3ef2:	rex cmp cl,0x1
    3ef6:	sete   cl
    3ef9:	test   cl,cl
    3efb:	jne    3f19 <botlish_fn_40+0x339>
    3f01:	mov    rdi,r12
    3f04:	mov    rax,QWORD PTR [rdi+0x10]
    3f08:	mov    rcx,QWORD PTR [rax+0x18]
    3f0c:	xor    rdx,rdx
    3f0f:	call   3f14 <botlish_fn_40+0x334>
			3f10: R_X86_64_PLT32	rt_type_error-0x4
    3f14:	jmp    3f70 <botlish_fn_40+0x390>
    3f19:	test   rsi,0x1
    3f20:	je     3f3f <botlish_fn_40+0x35f>
    3f26:	mov    rcx,rsi
    3f29:	sub    rcx,0x3
    3f2d:	seto   al
    3f30:	add    rcx,0x1
    3f37:	test   al,al
    3f39:	je     3f4d <botlish_fn_40+0x36d>
    3f3f:	mov    rdx,r14
    3f42:	mov    rdi,r12
    3f45:	call   3f4a <botlish_fn_40+0x36a>
			3f46: R_X86_64_PLT32	rt_int_sub-0x4
    3f4a:	mov    rcx,rax
    3f4d:	mov    rsi,r13
    3f50:	mov    rax,QWORD PTR [rsi+0x8]
    3f54:	cmp    rax,0x1
    3f58:	jbe    4083 <botlish_fn_40+0x4a3>
    3f5e:	mov    rax,QWORD PTR [rsi+0x18]
    3f62:	test   rax,rax
    3f65:	jne    3f9a <botlish_fn_40+0x3ba>
    3f6b:	jmp    408e <botlish_fn_40+0x4ae>
    3f70:	xor    rax,rax
    3f73:	mov    rbx,QWORD PTR [rsp+0x40]
    3f78:	mov    r12,QWORD PTR [rsp+0x48]
    3f7d:	mov    r13,QWORD PTR [rsp+0x50]
    3f82:	mov    r14,QWORD PTR [rsp+0x58]
    3f87:	mov    r15,QWORD PTR [rsp+0x60]
    3f8c:	add    rsp,0x70
    3f90:	mov    rsp,rbp
    3f93:	pop    rbp
    3f94:	ret
    3f95:	jmp    3fa2 <botlish_fn_40+0x3c2>
    3f9a:	mov    rax,QWORD PTR [rsi+0x10]
    3f9e:	mov    QWORD PTR [rax+0x8],rcx
    3fa2:	mov    rax,rbx
    3fa5:	mov    rbx,QWORD PTR [rsp+0x40]
    3faa:	mov    r12,QWORD PTR [rsp+0x48]
    3faf:	mov    r13,QWORD PTR [rsp+0x50]
    3fb4:	mov    r14,QWORD PTR [rsp+0x58]
    3fb9:	mov    r15,QWORD PTR [rsp+0x60]
    3fbe:	add    rsp,0x70
    3fc2:	mov    rsp,rbp
    3fc5:	pop    rbp
    3fc6:	ret
    3fc7:	mov    r15,rdx
    3fca:	mov    rdx,r15
    3fcd:	mov    rdi,r12
    3fd0:	call   3fd5 <botlish_fn_40+0x3f5>
			3fd1: R_X86_64_PLT32	rt_mutarray_get-0x4
    3fd5:	test   rax,rax
    3fd8:	jne    3c42 <botlish_fn_40+0x62>
    3fde:	jmp    3f70 <botlish_fn_40+0x390>
    3fe3:	mov    ecx,0x3
    3fe8:	mov    rdx,r15
    3feb:	mov    rdi,r12
    3fee:	call   3ff3 <botlish_fn_40+0x413>
			3fef: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ff3:	test   rax,rax
    3ff6:	jne    3ca0 <botlish_fn_40+0xc0>
    3ffc:	jmp    3f70 <botlish_fn_40+0x390>
    4001:	mov    rcx,QWORD PTR [rsp+0x30]
    4006:	jmp    401a <botlish_fn_40+0x43a>
    400b:	mov    rcx,QWORD PTR [rsp+0x30]
    4010:	jmp    401a <botlish_fn_40+0x43a>
    4015:	mov    rcx,QWORD PTR [rsp+0x30]
    401a:	mov    rdx,r15
    401d:	mov    rdi,r12
    4020:	call   4025 <botlish_fn_40+0x445>
			4021: R_X86_64_PLT32	rt_mutarray_set-0x4
    4025:	test   rax,rax
    4028:	jne    3ce8 <botlish_fn_40+0x108>
    402e:	jmp    3f70 <botlish_fn_40+0x390>
    4033:	mov    rcx,r14
    4036:	mov    rdx,r15
    4039:	jmp    404f <botlish_fn_40+0x46f>
    403e:	mov    rcx,r14
    4041:	mov    rdx,r15
    4044:	jmp    404f <botlish_fn_40+0x46f>
    4049:	mov    rcx,r14
    404c:	mov    rdx,r15
    404f:	mov    rdx,r15
    4052:	mov    rdi,r12
    4055:	call   405a <botlish_fn_40+0x47a>
			4056: R_X86_64_PLT32	rt_mutarray_set-0x4
    405a:	test   rax,rax
    405d:	jne    3d2e <botlish_fn_40+0x14e>
    4063:	jmp    3f70 <botlish_fn_40+0x390>
    4068:	mov    edx,0x1
    406d:	mov    rdi,r12
    4070:	call   4075 <botlish_fn_40+0x495>
			4071: R_X86_64_PLT32	rt_mutarray_set-0x4
    4075:	test   rax,rax
    4078:	jne    3e1d <botlish_fn_40+0x23d>
    407e:	jmp    3f70 <botlish_fn_40+0x390>
    4083:	mov    rdx,r14
    4086:	mov    rdi,r12
    4089:	jmp    4094 <botlish_fn_40+0x4b4>
    408e:	mov    rdx,r14
    4091:	mov    rdi,r12
    4094:	mov    rdx,r14
    4097:	mov    rdi,r12
    409a:	call   409f <botlish_fn_40+0x4bf>
			409b: R_X86_64_PLT32	rt_mutarray_set-0x4
    409f:	test   rax,rax
    40a2:	jne    3fa2 <botlish_fn_40+0x3c2>
    40a8:	jmp    3f70 <botlish_fn_40+0x390>
    40ad:	add    BYTE PTR [rax],al
    40af:	add    BYTE PTR [rsi],al
    40b1:	add    BYTE PTR [rax],al
    40b3:	add    BYTE PTR [rax],al
    40b5:	add    BYTE PTR [rax],al
	...

00000000000040b8 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    40b8:	push   rbp
    40b9:	mov    rbp,rsp
    40bc:	mov    rsi,QWORD PTR [rdx]
    40bf:	mov    r9,QWORD PTR [rdx+0x8]
    40c3:	mov    rcx,QWORD PTR [rdx+0x10]
    40c7:	mov    r8,QWORD PTR [rdx+0x18]
    40cb:	mov    rdx,r9
    40ce:	call   40d3 <botlish_entry_40+0x1b>
			40cf: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    40d3:	mov    rsp,rbp
    40d6:	pop    rbp
    40d7:	ret

00000000000040d8 <botlish_fn_41: ht_set<HashTable, str, str>>:
    40d8:	push   rbp
    40d9:	mov    rbp,rsp
    40dc:	sub    rsp,0x60
    40e0:	mov    QWORD PTR [rsp+0x30],rbx
    40e5:	mov    QWORD PTR [rsp+0x38],r12
    40ea:	mov    QWORD PTR [rsp+0x40],r13
    40ef:	mov    QWORD PTR [rsp+0x48],r14
    40f4:	mov    QWORD PTR [rsp+0x50],r15
    40f9:	mov    r12,rdi
    40fc:	mov    r14,rdx
    40ff:	mov    QWORD PTR [rsp],rsi
    4103:	mov    r13,rsi
    4106:	mov    QWORD PTR [rsp+0x8],rdx
    410b:	mov    QWORD PTR [rsp+0x10],rcx
    4110:	mov    rbx,rcx
    4113:	mov    rdx,r14
    4116:	mov    rsi,r13
    4119:	mov    rdi,r12
    411c:	call   4121 <botlish_fn_41+0x49>
			411d: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    4121:	test   rax,rax
    4124:	mov    rcx,rax
    4127:	je     4318 <botlish_fn_41+0x240>
    412d:	mov    r8,0xffffffffffffffff
    4134:	mov    QWORD PTR [rsp+0x20],r8
    4139:	mov    rdx,r14
    413c:	mov    rsi,r13
    413f:	mov    rdi,r12
    4142:	call   4147 <botlish_fn_41+0x6f>
			4143: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    4147:	test   rax,rax
    414a:	je     4318 <botlish_fn_41+0x240>
    4150:	mov    QWORD PTR [rsp+0x18],rax
    4155:	mov    rsi,r13
    4158:	mov    rcx,QWORD PTR [rsi+0x18]
    415c:	mov    rsi,QWORD PTR [rcx]
    415f:	test   rax,0x1
    4165:	je     4375 <botlish_fn_41+0x29d>
    416b:	mov    rdx,QWORD PTR [rsi+0x8]
    416f:	mov    rcx,rax
    4172:	sar    rcx,1
    4175:	mov    r15,rax
    4178:	cmp    rcx,rdx
    417b:	jb     418e <botlish_fn_41+0xb6>
    4181:	jmp    4378 <botlish_fn_41+0x2a0>
    4186:	mov    rsi,rax
    4189:	jmp    4196 <botlish_fn_41+0xbe>
    418e:	mov    rax,QWORD PTR [rsi+0x10]
    4192:	mov    rsi,QWORD PTR [rax+rcx*8]
    4196:	test   rsi,0x1
    419d:	jne    41c5 <botlish_fn_41+0xed>
    41a3:	mov    edx,0x3
    41a8:	mov    rdi,r12
    41ab:	call   41b0 <botlish_fn_41+0xd8>
			41ac: R_X86_64_PLT32	rt_int_cmp-0x4
    41b0:	mov    ecx,0x2
    41b5:	test   rax,rax
    41b8:	cmove  rcx,QWORD PTR [rip+0x208]        # 43c8 <botlish_fn_41+0x2f0>
    41c0:	jmp    41d6 <botlish_fn_41+0xfe>
    41c5:	mov    ecx,0x2
    41ca:	cmp    rsi,0x3
    41ce:	cmove  rcx,QWORD PTR [rip+0x1f2]        # 43c8 <botlish_fn_41+0x2f0>
    41d6:	cmp    rcx,0x6
    41da:	je     42d8 <botlish_fn_41+0x200>
    41e0:	mov    rsi,r13
    41e3:	mov    rdi,r12
    41e6:	call   41eb <botlish_fn_41+0x113>
			41e7: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    41eb:	test   rax,rax
    41ee:	je     4318 <botlish_fn_41+0x240>
    41f4:	cmp    rax,0x6
    41f8:	je     423d <botlish_fn_41+0x165>
    41fe:	mov    rcx,r14
    4201:	mov    rdx,r15
    4204:	mov    rsi,r13
    4207:	mov    rdi,r12
    420a:	mov    r8,rbx
    420d:	call   4212 <botlish_fn_41+0x13a>
			420e: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    4212:	test   rax,rax
    4215:	je     4318 <botlish_fn_41+0x240>
    421b:	mov    rbx,QWORD PTR [rsp+0x30]
    4220:	mov    r12,QWORD PTR [rsp+0x38]
    4225:	mov    r13,QWORD PTR [rsp+0x40]
    422a:	mov    r14,QWORD PTR [rsp+0x48]
    422f:	mov    r15,QWORD PTR [rsp+0x50]
    4234:	add    rsp,0x60
    4238:	mov    rsp,rbp
    423b:	pop    rbp
    423c:	ret
    423d:	mov    rsi,r13
    4240:	mov    rdi,r12
    4243:	call   4248 <botlish_fn_41+0x170>
			4244: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    4248:	mov    r11,rax
    424b:	mov    r13,rax
    424e:	test   rax,r11
    4251:	je     4318 <botlish_fn_41+0x240>
    4257:	mov    rax,r13
    425a:	mov    QWORD PTR [rsp],rax
    425e:	mov    rdx,r14
    4261:	mov    rsi,r13
    4264:	mov    rdi,r12
    4267:	call   426c <botlish_fn_41+0x194>
			4268: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    426c:	test   rax,rax
    426f:	mov    rcx,rax
    4272:	je     4318 <botlish_fn_41+0x240>
    4278:	mov    r8,QWORD PTR [rsp+0x20]
    427d:	mov    rdx,r14
    4280:	mov    rsi,r13
    4283:	mov    rdi,r12
    4286:	call   428b <botlish_fn_41+0x1b3>
			4287: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    428b:	test   rax,rax
    428e:	je     4318 <botlish_fn_41+0x240>
    4294:	mov    QWORD PTR [rsp+0x18],rax
    4299:	mov    rcx,r14
    429c:	mov    rdx,rax
    429f:	mov    rsi,r13
    42a2:	mov    rdi,r12
    42a5:	mov    r8,rbx
    42a8:	call   42ad <botlish_fn_41+0x1d5>
			42a9: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    42ad:	test   rax,rax
    42b0:	je     4318 <botlish_fn_41+0x240>
    42b6:	mov    rbx,QWORD PTR [rsp+0x30]
    42bb:	mov    r12,QWORD PTR [rsp+0x38]
    42c0:	mov    r13,QWORD PTR [rsp+0x40]
    42c5:	mov    r14,QWORD PTR [rsp+0x48]
    42ca:	mov    r15,QWORD PTR [rsp+0x50]
    42cf:	add    rsp,0x60
    42d3:	mov    rsp,rbp
    42d6:	pop    rbp
    42d7:	ret
    42d8:	mov    rdx,r15
    42db:	mov    rsi,r13
    42de:	mov    rax,QWORD PTR [rsi+0x18]
    42e2:	mov    rsi,QWORD PTR [rax+0x10]
    42e6:	test   rdx,0x1
    42ed:	je     4391 <botlish_fn_41+0x2b9>
    42f3:	mov    rcx,QWORD PTR [rsi+0x8]
    42f7:	mov    rax,rdx
    42fa:	sar    rax,1
    42fd:	cmp    rax,rcx
    4300:	jae    439c <botlish_fn_41+0x2c4>
    4306:	mov    rcx,QWORD PTR [rsi+0x18]
    430a:	test   rcx,rcx
    430d:	jne    4345 <botlish_fn_41+0x26d>
    4313:	jmp    43a7 <botlish_fn_41+0x2cf>
    4318:	xor    rax,rax
    431b:	mov    rbx,QWORD PTR [rsp+0x30]
    4320:	mov    r12,QWORD PTR [rsp+0x38]
    4325:	mov    r13,QWORD PTR [rsp+0x40]
    432a:	mov    r14,QWORD PTR [rsp+0x48]
    432f:	mov    r15,QWORD PTR [rsp+0x50]
    4334:	add    rsp,0x60
    4338:	mov    rsp,rbp
    433b:	pop    rbp
    433c:	ret
    433d:	mov    rax,r13
    4340:	jmp    4353 <botlish_fn_41+0x27b>
    4345:	mov    rcx,rbx
    4348:	mov    rdx,QWORD PTR [rsi+0x10]
    434c:	mov    QWORD PTR [rdx+rax*8],rcx
    4350:	mov    rax,r13
    4353:	mov    rbx,QWORD PTR [rsp+0x30]
    4358:	mov    r12,QWORD PTR [rsp+0x38]
    435d:	mov    r13,QWORD PTR [rsp+0x40]
    4362:	mov    r14,QWORD PTR [rsp+0x48]
    4367:	mov    r15,QWORD PTR [rsp+0x50]
    436c:	add    rsp,0x60
    4370:	mov    rsp,rbp
    4373:	pop    rbp
    4374:	ret
    4375:	mov    r15,rax
    4378:	mov    rdx,r15
    437b:	mov    rdi,r12
    437e:	call   4383 <botlish_fn_41+0x2ab>
			437f: R_X86_64_PLT32	rt_mutarray_get-0x4
    4383:	test   rax,rax
    4386:	jne    4186 <botlish_fn_41+0xae>
    438c:	jmp    4318 <botlish_fn_41+0x240>
    4391:	mov    rcx,rbx
    4394:	mov    rdi,r12
    4397:	jmp    43ad <botlish_fn_41+0x2d5>
    439c:	mov    rcx,rbx
    439f:	mov    rdi,r12
    43a2:	jmp    43ad <botlish_fn_41+0x2d5>
    43a7:	mov    rcx,rbx
    43aa:	mov    rdi,r12
    43ad:	mov    rdi,r12
    43b0:	call   43b5 <botlish_fn_41+0x2dd>
			43b1: R_X86_64_PLT32	rt_mutarray_set-0x4
    43b5:	test   rax,rax
    43b8:	jne    433d <botlish_fn_41+0x265>
    43be:	jmp    4318 <botlish_fn_41+0x240>
    43c3:	add    BYTE PTR [rax],al
    43c5:	add    BYTE PTR [rax],al
    43c7:	add    BYTE PTR [rsi],al
    43c9:	add    BYTE PTR [rax],al
    43cb:	add    BYTE PTR [rax],al
    43cd:	add    BYTE PTR [rax],al
	...

00000000000043d0 <botlish_entry_41: ht_set<HashTable, str, str>>:
    43d0:	push   rbp
    43d1:	mov    rbp,rsp
    43d4:	mov    rsi,QWORD PTR [rdx]
    43d7:	mov    r8,QWORD PTR [rdx+0x8]
    43db:	mov    rcx,QWORD PTR [rdx+0x10]
    43df:	mov    rdx,r8
    43e2:	call   43e7 <botlish_entry_41+0x17>
			43e3: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    43e7:	mov    rsp,rbp
    43ea:	pop    rbp
    43eb:	ret

00000000000043ec <botlish_fn_42: row_new<bool, int>>:
    43ec:	push   rbp
    43ed:	mov    rbp,rsp
    43f0:	sub    rsp,0x10
    43f4:	mov    QWORD PTR [rsp],rdx
    43f8:	mov    r8,rdx
    43fb:	cmp    rsi,0x6
    43ff:	je     441c <botlish_fn_42+0x30>
    4405:	call   440a <botlish_fn_42+0x1e>
			4406: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    440a:	test   rax,rax
    440d:	je     442d <botlish_fn_42+0x41>
    4413:	add    rsp,0x10
    4417:	mov    rsp,rbp
    441a:	pop    rbp
    441b:	ret
    441c:	mov    rsi,r8
    441f:	call   4424 <botlish_fn_42+0x38>
			4420: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    4424:	test   rax,rax
    4427:	jne    4439 <botlish_fn_42+0x4d>
    442d:	xor    rax,rax
    4430:	add    rsp,0x10
    4434:	mov    rsp,rbp
    4437:	pop    rbp
    4438:	ret
    4439:	add    rsp,0x10
    443d:	mov    rsp,rbp
    4440:	pop    rbp
    4441:	ret

0000000000004442 <botlish_entry_42: row_new<bool, int>>:
    4442:	push   rbp
    4443:	mov    rbp,rsp
    4446:	mov    rsi,QWORD PTR [rdx]
    4449:	mov    rdx,QWORD PTR [rdx+0x8]
    444d:	call   4452 <botlish_entry_42+0x10>
			444e: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    4452:	mov    rsp,rbp
    4455:	pop    rbp
    4456:	ret

0000000000004457 <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    4457:	push   rbp
    4458:	mov    rbp,rsp
    445b:	sub    rsp,0x70
    445f:	mov    QWORD PTR [rsp+0x40],rbx
    4464:	mov    QWORD PTR [rsp+0x48],r12
    4469:	mov    QWORD PTR [rsp+0x50],r13
    446e:	mov    QWORD PTR [rsp+0x58],r14
    4473:	mov    QWORD PTR [rsp+0x60],r15
    4478:	mov    r15,rdi
    447b:	mov    QWORD PTR [rsp],rsi
    447f:	mov    QWORD PTR [rsp+0x8],rdx
    4484:	mov    QWORD PTR [rsp+0x10],rcx
    4489:	mov    r14,rcx
    448c:	sar    r8,1
    448f:	mov    rbx,r8
    4492:	mov    r12,r9
    4495:	mov    QWORD PTR [rsp+0x28],rsi
    449a:	cmp    rbx,r12
    449d:	jge    45ac <botlish_fn_43+0x155>
    44a3:	mov    r13,rdx
    44a6:	mov    rdx,QWORD PTR [r13+0x8]
    44aa:	mov    rcx,rbx
    44ad:	shl    rcx,1
    44b0:	or     rcx,0x1
    44b4:	sar    rcx,1
    44b7:	cmp    rcx,rdx
    44ba:	jb     44e6 <botlish_fn_43+0x8f>
    44c0:	mov    rdx,rbx
    44c3:	shl    rdx,1
    44c6:	or     rdx,0x1
    44ca:	mov    rsi,r13
    44cd:	mov    rdi,r15
    44d0:	call   44d5 <botlish_fn_43+0x7e>
			44d1: R_X86_64_PLT32	rt_list_get-0x4
    44d5:	test   rax,rax
    44d8:	je     4565 <botlish_fn_43+0x10e>
    44de:	mov    rdx,rax
    44e1:	jmp    44ee <botlish_fn_43+0x97>
    44e6:	mov    rax,QWORD PTR [r13+0x10]
    44ea:	mov    rdx,QWORD PTR [rax+rcx*8]
    44ee:	mov    QWORD PTR [rsp+0x18],rdx
    44f3:	mov    QWORD PTR [rsp+0x30],rdx
    44f8:	mov    rax,QWORD PTR [r14+0x8]
    44fc:	mov    rcx,rbx
    44ff:	shl    rcx,1
    4502:	or     rcx,0x1
    4506:	sar    rcx,1
    4509:	cmp    rcx,rax
    450c:	jb     453d <botlish_fn_43+0xe6>
    4512:	mov    rdx,rbx
    4515:	shl    rdx,1
    4518:	or     rdx,0x1
    451c:	mov    rsi,r14
    451f:	mov    rdi,r15
    4522:	call   4527 <botlish_fn_43+0xd0>
			4523: R_X86_64_PLT32	rt_list_get-0x4
    4527:	test   rax,rax
    452a:	je     4565 <botlish_fn_43+0x10e>
    4530:	mov    rcx,rax
    4533:	mov    rsi,QWORD PTR [rsp+0x28]
    4538:	jmp    454a <botlish_fn_43+0xf3>
    453d:	mov    rax,QWORD PTR [r14+0x10]
    4541:	mov    rcx,QWORD PTR [rax+rcx*8]
    4545:	mov    rsi,QWORD PTR [rsp+0x28]
    454a:	mov    QWORD PTR [rsp+0x20],rcx
    454f:	mov    rdx,QWORD PTR [rsp+0x30]
    4554:	mov    rdi,r15
    4557:	call   455c <botlish_fn_43+0x105>
			4558: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    455c:	test   rax,rax
    455f:	jne    458a <botlish_fn_43+0x133>
    4565:	xor    rax,rax
    4568:	mov    rbx,QWORD PTR [rsp+0x40]
    456d:	mov    r12,QWORD PTR [rsp+0x48]
    4572:	mov    r13,QWORD PTR [rsp+0x50]
    4577:	mov    r14,QWORD PTR [rsp+0x58]
    457c:	mov    r15,QWORD PTR [rsp+0x60]
    4581:	add    rsp,0x70
    4585:	mov    rsp,rbp
    4588:	pop    rbp
    4589:	ret
    458a:	mov    QWORD PTR [rsp],rax
    458e:	mov    QWORD PTR [rsp+0x8],r13
    4593:	mov    QWORD PTR [rsp+0x10],r14
    4598:	add    rbx,0x1
    459f:	mov    rdx,r13
    45a2:	mov    QWORD PTR [rsp+0x28],rax
    45a7:	jmp    449a <botlish_fn_43+0x43>
    45ac:	mov    rax,QWORD PTR [rsp+0x28]
    45b1:	mov    rbx,QWORD PTR [rsp+0x40]
    45b6:	mov    r12,QWORD PTR [rsp+0x48]
    45bb:	mov    r13,QWORD PTR [rsp+0x50]
    45c0:	mov    r14,QWORD PTR [rsp+0x58]
    45c5:	mov    r15,QWORD PTR [rsp+0x60]
    45ca:	add    rsp,0x70
    45ce:	mov    rsp,rbp
    45d1:	pop    rbp
    45d2:	ret

00000000000045d3 <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    45d3:	push   rbp
    45d4:	mov    rbp,rsp
    45d7:	mov    rsi,QWORD PTR [rdx]
    45da:	mov    r10,QWORD PTR [rdx+0x8]
    45de:	mov    rcx,QWORD PTR [rdx+0x10]
    45e2:	mov    r8,QWORD PTR [rdx+0x18]
    45e6:	mov    r9,QWORD PTR [rdx+0x20]
    45ea:	sar    r9,1
    45ed:	mov    rdx,r10
    45f0:	call   45f5 <botlish_entry_43+0x22>
			45f1: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    45f5:	mov    rsp,rbp
    45f8:	pop    rbp
    45f9:	ret

00000000000045fa <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    45fa:	push   rbp
    45fb:	mov    rbp,rsp
    45fe:	sub    rsp,0x50
    4602:	mov    QWORD PTR [rsp+0x20],rbx
    4607:	mov    QWORD PTR [rsp+0x28],r12
    460c:	mov    QWORD PTR [rsp+0x30],r13
    4611:	mov    QWORD PTR [rsp+0x38],r14
    4616:	mov    QWORD PTR [rsp+0x40],r15
    461b:	mov    r12,rdi
    461e:	mov    QWORD PTR [rsp],rsi
    4622:	mov    r15,rsi
    4625:	mov    QWORD PTR [rsp+0x8],rdx
    462a:	mov    QWORD PTR [rsp+0x10],rcx
    462f:	mov    r13,rcx
    4632:	mov    QWORD PTR [rsp+0x18],r8
    4637:	mov    rsi,r8
    463a:	mov    rdi,r12
    463d:	call   4642 <botlish_fn_44+0x48>
			463e: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    4642:	test   rax,rax
    4645:	je     468f <botlish_fn_44+0x95>
    464b:	mov    QWORD PTR [rsp+0x8],rax
    4650:	mov    r14,rax
    4653:	mov    ebx,0x1
    4658:	mov    QWORD PTR [rsp+0x18],0x1
    4661:	mov    rsi,r13
    4664:	mov    rdi,r12
    4667:	call   466c <botlish_fn_44+0x72>
			4668: R_X86_64_PLT32	rt_list_len-0x4
    466c:	mov    r9,rax
    466f:	sar    r9,1
    4672:	mov    rcx,r13
    4675:	mov    rdx,r15
    4678:	mov    rsi,r14
    467b:	mov    rdi,r12
    467e:	mov    r8,rbx
    4681:	call   4686 <botlish_fn_44+0x8c>
			4682: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    4686:	test   rax,rax
    4689:	jne    46b4 <botlish_fn_44+0xba>
    468f:	xor    rax,rax
    4692:	mov    rbx,QWORD PTR [rsp+0x20]
    4697:	mov    r12,QWORD PTR [rsp+0x28]
    469c:	mov    r13,QWORD PTR [rsp+0x30]
    46a1:	mov    r14,QWORD PTR [rsp+0x38]
    46a6:	mov    r15,QWORD PTR [rsp+0x40]
    46ab:	add    rsp,0x50
    46af:	mov    rsp,rbp
    46b2:	pop    rbp
    46b3:	ret
    46b4:	mov    rbx,QWORD PTR [rsp+0x20]
    46b9:	mov    r12,QWORD PTR [rsp+0x28]
    46be:	mov    r13,QWORD PTR [rsp+0x30]
    46c3:	mov    r14,QWORD PTR [rsp+0x38]
    46c8:	mov    r15,QWORD PTR [rsp+0x40]
    46cd:	add    rsp,0x50
    46d1:	mov    rsp,rbp
    46d4:	pop    rbp
    46d5:	ret

00000000000046d6 <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    46d6:	push   rbp
    46d7:	mov    rbp,rsp
    46da:	mov    rsi,QWORD PTR [rdx]
    46dd:	mov    r9,QWORD PTR [rdx+0x8]
    46e1:	mov    rcx,QWORD PTR [rdx+0x10]
    46e5:	mov    r8,QWORD PTR [rdx+0x18]
    46e9:	mov    rdx,r9
    46ec:	call   46f1 <botlish_entry_44+0x1b>
			46ed: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    46f1:	mov    rsp,rbp
    46f4:	pop    rbp
    46f5:	ret

00000000000046f6 <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    46f6:	push   rbp
    46f7:	mov    rbp,rsp
    46fa:	sub    rsp,0x90
    4701:	mov    QWORD PTR [rsp+0x60],rbx
    4706:	mov    QWORD PTR [rsp+0x68],r12
    470b:	mov    QWORD PTR [rsp+0x70],r13
    4710:	mov    QWORD PTR [rsp+0x78],r14
    4715:	mov    QWORD PTR [rsp+0x80],r15
    471d:	mov    r13,r8
    4720:	mov    QWORD PTR [rsp+0x38],rdi
    4725:	mov    rdi,QWORD PTR [rbp+0x10]
    4729:	mov    r15,QWORD PTR [rbp+0x18]
    472d:	mov    QWORD PTR [rsp+0x28],0x0
    4736:	mov    QWORD PTR [rsp+0x30],0x0
    473f:	mov    QWORD PTR [rsp],rsi
    4743:	mov    QWORD PTR [rsp+0x8],rcx
    4748:	mov    r14,rcx
    474b:	mov    QWORD PTR [rsp+0x10],r9
    4750:	mov    QWORD PTR [rsp+0x18],rdi
    4755:	mov    QWORD PTR [rsp+0x20],r15
    475a:	sar    rdx,1
    475d:	mov    r12,rdx
    4760:	mov    rbx,rsi
    4763:	mov    QWORD PTR [rsp+0x40],r9
    4768:	mov    QWORD PTR [rsp+0x48],rdi
    476d:	mov    rsi,rbx
    4770:	mov    rdi,QWORD PTR [rsp+0x38]
    4775:	call   477a <botlish_fn_45+0x84>
			4776: R_X86_64_PLT32	rt_list_len-0x4
    477a:	sar    rax,1
    477d:	cmp    r12,rax
    4780:	jge    48ab <botlish_fn_45+0x1b5>
    4786:	mov    rax,r13
    4789:	or     rax,0x1
    478d:	mov    QWORD PTR [rsp+0x28],rax
    4792:	mov    rcx,QWORD PTR [rbx+0x8]
    4796:	mov    rax,r12
    4799:	shl    rax,1
    479c:	or     rax,0x1
    47a0:	sar    rax,1
    47a3:	cmp    rax,rcx
    47a6:	jb     47d4 <botlish_fn_45+0xde>
    47ac:	mov    rdx,r12
    47af:	shl    rdx,1
    47b2:	or     rdx,0x1
    47b6:	mov    rsi,rbx
    47b9:	mov    rdi,QWORD PTR [rsp+0x38]
    47be:	call   47c3 <botlish_fn_45+0xcd>
			47bf: R_X86_64_PLT32	rt_list_get-0x4
    47c3:	test   rax,rax
    47c6:	je     48c8 <botlish_fn_45+0x1d2>
    47cc:	mov    rcx,rax
    47cf:	jmp    47dc <botlish_fn_45+0xe6>
    47d4:	mov    rcx,QWORD PTR [rbx+0x10]
    47d8:	mov    rcx,QWORD PTR [rcx+rax*8]
    47dc:	mov    QWORD PTR [rsp+0x30],rcx
    47e1:	mov    rdx,r13
    47e4:	or     rdx,0x1
    47e8:	mov    rsi,r14
    47eb:	mov    rdi,QWORD PTR [rsp+0x38]
    47f0:	mov    r8,r15
    47f3:	call   47f8 <botlish_fn_45+0x102>
			47f4: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    47f8:	test   rax,rax
    47fb:	je     48c8 <botlish_fn_45+0x1d2>
    4801:	mov    QWORD PTR [rsp+0x28],rax
    4806:	mov    rcx,rax
    4809:	mov    rsi,QWORD PTR [rsp+0x40]
    480e:	mov    rdx,QWORD PTR [rsp+0x48]
    4813:	mov    rdi,QWORD PTR [rsp+0x38]
    4818:	call   481d <botlish_fn_45+0x127>
			4819: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    481d:	test   rax,rax
    4820:	je     48c8 <botlish_fn_45+0x1d2>
    4826:	mov    QWORD PTR [rsp+0x10],rax
    482b:	mov    QWORD PTR [rsp+0x50],rax
    4830:	mov    QWORD PTR [rsp+0x28],0x3
    4839:	mov    rsi,QWORD PTR [rsp+0x48]
    483e:	test   rsi,0x1
    4845:	je     4864 <botlish_fn_45+0x16e>
    484b:	mov    rsi,QWORD PTR [rsp+0x48]
    4850:	mov    rax,rsi
    4853:	add    rax,0x2
    4857:	seto   r10b
    485b:	test   r10b,r10b
    485e:	je     4878 <botlish_fn_45+0x182>
    4864:	mov    edx,0x3
    4869:	mov    rsi,QWORD PTR [rsp+0x48]
    486e:	mov    rdi,QWORD PTR [rsp+0x38]
    4873:	call   4878 <botlish_fn_45+0x182>
			4874: R_X86_64_PLT32	rt_int_add-0x4
    4878:	mov    QWORD PTR [rsp],rbx
    487c:	mov    QWORD PTR [rsp+0x8],r14
    4881:	mov    rcx,QWORD PTR [rsp+0x50]
    4886:	mov    QWORD PTR [rsp+0x10],rcx
    488b:	mov    QWORD PTR [rsp+0x18],rax
    4890:	mov    QWORD PTR [rsp+0x20],r15
    4895:	add    r12,0x1
    489c:	mov    QWORD PTR [rsp+0x40],rcx
    48a1:	mov    QWORD PTR [rsp+0x48],rax
    48a6:	jmp    476d <botlish_fn_45+0x77>
    48ab:	mov    rdx,QWORD PTR [rsp+0x48]
    48b0:	mov    rsi,QWORD PTR [rsp+0x40]
    48b5:	mov    rdi,QWORD PTR [rsp+0x38]
    48ba:	call   48bf <botlish_fn_45+0x1c9>
			48bb: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    48bf:	test   rax,rax
    48c2:	jne    48f3 <botlish_fn_45+0x1fd>
    48c8:	xor    rax,rax
    48cb:	mov    rbx,QWORD PTR [rsp+0x60]
    48d0:	mov    r12,QWORD PTR [rsp+0x68]
    48d5:	mov    r13,QWORD PTR [rsp+0x70]
    48da:	mov    r14,QWORD PTR [rsp+0x78]
    48df:	mov    r15,QWORD PTR [rsp+0x80]
    48e7:	add    rsp,0x90
    48ee:	mov    rsp,rbp
    48f1:	pop    rbp
    48f2:	ret
    48f3:	mov    rbx,QWORD PTR [rsp+0x60]
    48f8:	mov    r12,QWORD PTR [rsp+0x68]
    48fd:	mov    r13,QWORD PTR [rsp+0x70]
    4902:	mov    r14,QWORD PTR [rsp+0x78]
    4907:	mov    r15,QWORD PTR [rsp+0x80]
    490f:	add    rsp,0x90
    4916:	mov    rsp,rbp
    4919:	pop    rbp
    491a:	ret

000000000000491b <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    491b:	push   rbp
    491c:	mov    rbp,rsp
    491f:	sub    rsp,0x10
    4923:	mov    rsi,QWORD PTR [rdx]
    4926:	mov    r10,QWORD PTR [rdx+0x8]
    492a:	mov    rcx,QWORD PTR [rdx+0x10]
    492e:	mov    r8,QWORD PTR [rdx+0x18]
    4932:	mov    r9,QWORD PTR [rdx+0x20]
    4936:	mov    r11,QWORD PTR [rdx+0x28]
    493a:	mov    rax,QWORD PTR [rdx+0x30]
    493e:	mov    QWORD PTR [rsp],r11
    4942:	mov    QWORD PTR [rsp+0x8],rax
    4947:	mov    rdx,r10
    494a:	call   494f <botlish_entry_45+0x34>
			494b: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    494f:	add    rsp,0x10
    4953:	mov    rsp,rbp
    4956:	pop    rbp
    4957:	ret

0000000000004958 <botlish_fn_46: csv_records_generic<str, bool>>:
    4958:	push   rbp
    4959:	mov    rbp,rsp
    495c:	sub    rsp,0x80
    4963:	mov    QWORD PTR [rsp+0x50],rbx
    4968:	mov    QWORD PTR [rsp+0x58],r12
    496d:	mov    QWORD PTR [rsp+0x60],r13
    4972:	mov    QWORD PTR [rsp+0x68],r14
    4977:	mov    QWORD PTR [rsp+0x70],r15
    497c:	mov    r12,rdi
    497f:	mov    QWORD PTR [rsp+0x20],0x0
    4988:	mov    QWORD PTR [rsp+0x28],0x0
    4991:	mov    QWORD PTR [rsp+0x30],0x0
    499a:	mov    QWORD PTR [rsp+0x38],0x0
    49a3:	mov    QWORD PTR [rsp+0x40],0x0
    49ac:	mov    QWORD PTR [rsp+0x10],rsi
    49b1:	mov    QWORD PTR [rsp+0x18],rdx
    49b6:	mov    r13,rdx
    49b9:	mov    rdi,r12
    49bc:	call   49c1 <botlish_fn_46+0x69>
			49bd: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    49c1:	mov    rcx,rax
    49c4:	mov    r14,rax
    49c7:	test   rax,rcx
    49ca:	je     4ae4 <botlish_fn_46+0x18c>
    49d0:	mov    rax,r14
    49d3:	mov    QWORD PTR [rsp+0x10],rax
    49d8:	mov    rsi,r14
    49db:	mov    rdi,r12
    49de:	call   49e3 <botlish_fn_46+0x8b>
			49df: R_X86_64_PLT32	rt_list_len-0x4
    49e3:	sar    rax,1
    49e6:	cmp    rax,0x1
    49ea:	jle    4acd <botlish_fn_46+0x175>
    49f0:	mov    rax,r14
    49f3:	mov    rax,QWORD PTR [rax+0x10]
    49f7:	mov    rbx,QWORD PTR [rax]
    49fa:	mov    QWORD PTR [rsp+0x20],rbx
    49ff:	mov    rsi,rbx
    4a02:	mov    rdi,r12
    4a05:	call   4a0a <botlish_fn_46+0xb2>
			4a06: R_X86_64_PLT32	rt_list_len-0x4
    4a0a:	mov    r15,rbx
    4a0d:	mov    QWORD PTR [rsp+0x28],rax
    4a12:	mov    QWORD PTR [rsp+0x48],rax
    4a17:	mov    rax,r14
    4a1a:	mov    rcx,QWORD PTR [rax+0x10]
    4a1e:	mov    rcx,QWORD PTR [rcx+0x8]
    4a22:	mov    QWORD PTR [rsp+0x30],rcx
    4a27:	mov    rbx,r13
    4a2a:	mov    rdx,QWORD PTR [rsp+0x48]
    4a2f:	mov    rsi,r15
    4a32:	mov    rdi,r12
    4a35:	mov    r8,rbx
    4a38:	call   4a3d <botlish_fn_46+0xe5>
			4a39: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    4a3d:	test   rax,rax
    4a40:	je     4ae4 <botlish_fn_46+0x18c>
    4a46:	mov    QWORD PTR [rsp+0x30],rax
    4a4b:	mov    rsi,rax
    4a4e:	mov    QWORD PTR [rsp+0x38],0x5
    4a57:	mov    rdi,r12
    4a5a:	call   4a5f <botlish_fn_46+0x107>
			4a5b: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    4a5f:	test   rax,rax
    4a62:	je     4ae4 <botlish_fn_46+0x18c>
    4a68:	mov    QWORD PTR [rsp+0x30],rax
    4a6d:	mov    r9,rax
    4a70:	mov    eax,0x3
    4a75:	mov    QWORD PTR [rsp+0x40],0x3
    4a7e:	mov    edx,0x5
    4a83:	mov    QWORD PTR [rsp],rax
    4a87:	mov    QWORD PTR [rsp+0x8],rbx
    4a8c:	mov    rcx,r15
    4a8f:	mov    rsi,r14
    4a92:	mov    rdi,r12
    4a95:	mov    r8,QWORD PTR [rsp+0x48]
    4a9a:	call   4a9f <botlish_fn_46+0x147>
			4a9b: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4a9f:	test   rax,rax
    4aa2:	je     4ae4 <botlish_fn_46+0x18c>
    4aa8:	mov    rbx,QWORD PTR [rsp+0x50]
    4aad:	mov    r12,QWORD PTR [rsp+0x58]
    4ab2:	mov    r13,QWORD PTR [rsp+0x60]
    4ab7:	mov    r14,QWORD PTR [rsp+0x68]
    4abc:	mov    r15,QWORD PTR [rsp+0x70]
    4ac1:	add    rsp,0x80
    4ac8:	mov    rsp,rbp
    4acb:	pop    rbp
    4acc:	ret
    4acd:	xor    rdx,rdx
    4ad0:	mov    rdi,r12
    4ad3:	mov    rsi,rdx
    4ad6:	call   4adb <botlish_fn_46+0x183>
			4ad7: R_X86_64_PLT32	rt_list_new-0x4
    4adb:	test   rax,rax
    4ade:	jne    4b0c <botlish_fn_46+0x1b4>
    4ae4:	xor    rax,rax
    4ae7:	mov    rbx,QWORD PTR [rsp+0x50]
    4aec:	mov    r12,QWORD PTR [rsp+0x58]
    4af1:	mov    r13,QWORD PTR [rsp+0x60]
    4af6:	mov    r14,QWORD PTR [rsp+0x68]
    4afb:	mov    r15,QWORD PTR [rsp+0x70]
    4b00:	add    rsp,0x80
    4b07:	mov    rsp,rbp
    4b0a:	pop    rbp
    4b0b:	ret
    4b0c:	mov    rbx,QWORD PTR [rsp+0x50]
    4b11:	mov    r12,QWORD PTR [rsp+0x58]
    4b16:	mov    r13,QWORD PTR [rsp+0x60]
    4b1b:	mov    r14,QWORD PTR [rsp+0x68]
    4b20:	mov    r15,QWORD PTR [rsp+0x70]
    4b25:	add    rsp,0x80
    4b2c:	mov    rsp,rbp
    4b2f:	pop    rbp
    4b30:	ret

0000000000004b31 <botlish_entry_46: csv_records_generic<str, bool>>:
    4b31:	push   rbp
    4b32:	mov    rbp,rsp
    4b35:	mov    rsi,QWORD PTR [rdx]
    4b38:	mov    rdx,QWORD PTR [rdx+0x8]
    4b3c:	call   4b41 <botlish_entry_46+0x10>
			4b3d: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4b41:	mov    rsp,rbp
    4b44:	pop    rbp
    4b45:	ret

0000000000004b46 <botlish_fn_47: csv_records<str>>:
    4b46:	push   rbp
    4b47:	mov    rbp,rsp
    4b4a:	sub    rsp,0x10
    4b4e:	mov    QWORD PTR [rsp],rsi
    4b52:	mov    edx,0x2
    4b57:	mov    QWORD PTR [rsp+0x8],0x2
    4b60:	call   4b65 <botlish_fn_47+0x1f>
			4b61: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4b65:	test   rax,rax
    4b68:	jne    4b7a <botlish_fn_47+0x34>
    4b6e:	xor    rax,rax
    4b71:	add    rsp,0x10
    4b75:	mov    rsp,rbp
    4b78:	pop    rbp
    4b79:	ret
    4b7a:	add    rsp,0x10
    4b7e:	mov    rsp,rbp
    4b81:	pop    rbp
    4b82:	ret

0000000000004b83 <botlish_entry_47: csv_records<str>>:
    4b83:	push   rbp
    4b84:	mov    rbp,rsp
    4b87:	mov    rsi,QWORD PTR [rdx]
    4b8a:	call   4b8f <botlish_entry_47+0xc>
			4b8b: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4b8f:	mov    rsp,rbp
    4b92:	pop    rbp
    4b93:	ret

0000000000004b94 <botlish_fn_48: csv_records_presized<str>>:
    4b94:	push   rbp
    4b95:	mov    rbp,rsp
    4b98:	sub    rsp,0x10
    4b9c:	mov    QWORD PTR [rsp],rsi
    4ba0:	mov    edx,0x6
    4ba5:	mov    QWORD PTR [rsp+0x8],0x6
    4bae:	call   4bb3 <botlish_fn_48+0x1f>
			4baf: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4bb3:	test   rax,rax
    4bb6:	jne    4bc8 <botlish_fn_48+0x34>
    4bbc:	xor    rax,rax
    4bbf:	add    rsp,0x10
    4bc3:	mov    rsp,rbp
    4bc6:	pop    rbp
    4bc7:	ret
    4bc8:	add    rsp,0x10
    4bcc:	mov    rsp,rbp
    4bcf:	pop    rbp
    4bd0:	ret

0000000000004bd1 <botlish_entry_48: csv_records_presized<str>>:
    4bd1:	push   rbp
    4bd2:	mov    rbp,rsp
    4bd5:	mov    rsi,QWORD PTR [rdx]
    4bd8:	call   4bdd <botlish_entry_48+0xc>
			4bd9: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4bdd:	mov    rsp,rbp
    4be0:	pop    rbp
    4be1:	ret
    4be2:	add    BYTE PTR [rax],al
    4be4:	add    BYTE PTR [rax],al
	...

0000000000004be8 <botlish_fn_49: sample_checks<generic>>:
    4be8:	push   rbp
    4be9:	mov    rbp,rsp
    4bec:	sub    rsp,0xc0
    4bf3:	mov    QWORD PTR [rsp+0x90],rbx
    4bfb:	mov    QWORD PTR [rsp+0x98],r12
    4c03:	mov    QWORD PTR [rsp+0xa0],r13
    4c0b:	mov    QWORD PTR [rsp+0xa8],r14
    4c13:	mov    QWORD PTR [rsp+0xb0],r15
    4c1b:	mov    QWORD PTR [rsp+0x8],0x0
    4c24:	mov    QWORD PTR [rsp+0x10],0x0
    4c2d:	mov    QWORD PTR [rsp+0x18],0x0
    4c36:	mov    QWORD PTR [rsp+0x20],0x0
    4c3f:	mov    QWORD PTR [rsp+0x28],0x0
    4c48:	mov    QWORD PTR [rsp+0x30],0x0
    4c51:	mov    rax,QWORD PTR [rdi+0x10]
    4c55:	mov    r13,rdi
    4c58:	mov    rsi,QWORD PTR [rax+0x20]
    4c5c:	mov    QWORD PTR [rsp],rsi
    4c60:	call   4c65 <botlish_fn_49+0x7d>
			4c61: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4c65:	mov    rsi,rax
    4c68:	mov    r12,rax
    4c6b:	test   rax,rsi
    4c6e:	je     4fb9 <botlish_fn_49+0x3d1>
    4c74:	mov    rax,r12
    4c77:	mov    QWORD PTR [rsp],rax
    4c7b:	mov    rdi,r13
    4c7e:	mov    rax,QWORD PTR [rdi+0x10]
    4c82:	mov    rsi,QWORD PTR [rax+0x20]
    4c86:	mov    QWORD PTR [rsp+0x8],rsi
    4c8b:	call   4c90 <botlish_fn_49+0xa8>
			4c8c: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4c90:	mov    rbx,rax
    4c93:	test   rbx,rbx
    4c96:	je     4fb9 <botlish_fn_49+0x3d1>
    4c9c:	mov    rax,r12
    4c9f:	mov    rax,QWORD PTR [rax+0x8]
    4ca3:	test   rax,rax
    4ca6:	jne    4ccd <botlish_fn_49+0xe5>
    4cac:	mov    edx,0x1
    4cb1:	mov    rsi,r12
    4cb4:	mov    rdi,r13
    4cb7:	call   4cbc <botlish_fn_49+0xd4>
			4cb8: R_X86_64_PLT32	rt_list_get-0x4
    4cbc:	test   rax,rax
    4cbf:	je     4fb9 <botlish_fn_49+0x3d1>
    4cc5:	mov    r14,rax
    4cc8:	jmp    4cd8 <botlish_fn_49+0xf0>
    4ccd:	mov    rax,QWORD PTR [r12+0x10]
    4cd2:	mov    rsi,QWORD PTR [rax]
    4cd5:	mov    r14,rsi
    4cd8:	mov    rax,QWORD PTR [r12+0x8]
    4cdd:	cmp    rax,0x1
    4ce1:	ja     4d08 <botlish_fn_49+0x120>
    4ce7:	mov    edx,0x3
    4cec:	mov    rsi,r12
    4cef:	mov    rdi,r13
    4cf2:	call   4cf7 <botlish_fn_49+0x10f>
			4cf3: R_X86_64_PLT32	rt_list_get-0x4
    4cf7:	test   rax,rax
    4cfa:	je     4fb9 <botlish_fn_49+0x3d1>
    4d00:	mov    r15,rax
    4d03:	jmp    4d14 <botlish_fn_49+0x12c>
    4d08:	mov    rax,QWORD PTR [r12+0x10]
    4d0d:	mov    rsi,QWORD PTR [rax+0x8]
    4d11:	mov    r15,rsi
    4d14:	mov    rax,QWORD PTR [rbx+0x8]
    4d18:	mov    rsi,rbx
    4d1b:	test   rax,rax
    4d1e:	jne    4d47 <botlish_fn_49+0x15f>
    4d24:	mov    edx,0x1
    4d29:	mov    rdi,r13
    4d2c:	call   4d31 <botlish_fn_49+0x149>
			4d2d: R_X86_64_PLT32	rt_list_get-0x4
    4d31:	test   rax,rax
    4d34:	je     4fb9 <botlish_fn_49+0x3d1>
    4d3a:	mov    rdi,r13
    4d3d:	mov    QWORD PTR [rsp+0x70],rax
    4d42:	jmp    4d56 <botlish_fn_49+0x16e>
    4d47:	mov    rax,QWORD PTR [rsi+0x10]
    4d4b:	mov    rsi,QWORD PTR [rax]
    4d4e:	mov    QWORD PTR [rsp+0x70],rsi
    4d53:	mov    rdi,r13
    4d56:	mov    rdi,r13
    4d59:	mov    rax,QWORD PTR [rdi+0x10]
    4d5d:	mov    rdx,QWORD PTR [rax+0x28]
    4d61:	mov    rsi,r14
    4d64:	call   4d69 <botlish_fn_49+0x181>
			4d65: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4d69:	test   rax,rax
    4d6c:	mov    rbx,rax
    4d6f:	je     4fb9 <botlish_fn_49+0x3d1>
    4d75:	mov    rdi,r13
    4d78:	mov    rax,QWORD PTR [rdi+0x10]
    4d7c:	mov    rdx,QWORD PTR [rax+0x28]
    4d80:	mov    rsi,QWORD PTR [rsp+0x70]
    4d85:	call   4d8a <botlish_fn_49+0x1a2>
			4d86: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4d8a:	test   rax,rax
    4d8d:	je     4fb9 <botlish_fn_49+0x3d1>
    4d93:	mov    rsi,rbx
    4d96:	mov    rcx,rsi
    4d99:	and    rcx,rax
    4d9c:	mov    rdx,rax
    4d9f:	test   rcx,0x1
    4da6:	jne    4dc5 <botlish_fn_49+0x1dd>
    4dac:	mov    rsi,rbx
    4daf:	mov    rdi,r13
    4db2:	call   4db7 <botlish_fn_49+0x1cf>
			4db3: R_X86_64_PLT32	rt_value_eq-0x4
    4db7:	test   rax,rax
    4dba:	je     4fb9 <botlish_fn_49+0x3d1>
    4dc0:	jmp    4dd8 <botlish_fn_49+0x1f0>
    4dc5:	mov    rsi,rbx
    4dc8:	mov    eax,0x2
    4dcd:	cmp    rsi,rdx
    4dd0:	cmove  rax,QWORD PTR [rip+0x250]        # 5028 <botlish_fn_49+0x440>
    4dd8:	mov    ebx,0x6
    4ddd:	cmp    rax,0x6
    4de1:	je     4dfd <botlish_fn_49+0x215>
    4de7:	mov    ebx,0x2
    4dec:	mov    QWORD PTR [rsp+0x8],0x2
    4df5:	mov    rsi,r12
    4df8:	jmp    4e9a <botlish_fn_49+0x2b2>
    4dfd:	mov    rsi,r14
    4e00:	mov    rdi,r13
    4e03:	call   4e08 <botlish_fn_49+0x220>
			4e04: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4e08:	test   rax,rax
    4e0b:	mov    QWORD PTR [rsp+0x80],rax
    4e13:	je     4fb9 <botlish_fn_49+0x3d1>
    4e19:	mov    rsi,QWORD PTR [rsp+0x70]
    4e1e:	mov    rdi,r13
    4e21:	call   4e26 <botlish_fn_49+0x23e>
			4e22: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4e26:	test   rax,rax
    4e29:	je     4fb9 <botlish_fn_49+0x3d1>
    4e2f:	mov    rcx,QWORD PTR [rsp+0x80]
    4e37:	mov    r8,rcx
    4e3a:	and    r8,rax
    4e3d:	mov    rdx,rax
    4e40:	test   r8,0x1
    4e47:	jne    4e6b <botlish_fn_49+0x283>
    4e4d:	mov    rsi,QWORD PTR [rsp+0x80]
    4e55:	mov    rdi,r13
    4e58:	call   4e5d <botlish_fn_49+0x275>
			4e59: R_X86_64_PLT32	rt_value_eq-0x4
    4e5d:	test   rax,rax
    4e60:	je     4fb9 <botlish_fn_49+0x3d1>
    4e66:	jmp    4e83 <botlish_fn_49+0x29b>
    4e6b:	mov    rsi,QWORD PTR [rsp+0x80]
    4e73:	mov    eax,0x2
    4e78:	cmp    rsi,rdx
    4e7b:	cmove  rax,QWORD PTR [rip+0x1a5]        # 5028 <botlish_fn_49+0x440>
    4e83:	cmp    rax,0x6
    4e87:	je     4e92 <botlish_fn_49+0x2aa>
    4e8d:	mov    ebx,0x2
    4e92:	mov    QWORD PTR [rsp+0x8],rbx
    4e97:	mov    rsi,r12
    4e9a:	mov    rdi,r13
    4e9d:	call   4ea2 <botlish_fn_49+0x2ba>
			4e9e: R_X86_64_PLT32	rt_list_len-0x4
    4ea2:	mov    QWORD PTR [rsp],rax
    4ea6:	mov    rdi,r13
    4ea9:	mov    r12,rax
    4eac:	mov    rax,QWORD PTR [rdi+0x10]
    4eb0:	mov    rdx,QWORD PTR [rax+0x28]
    4eb4:	mov    rsi,r14
    4eb7:	call   4ebc <botlish_fn_49+0x2d4>
			4eb8: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4ebc:	test   rax,rax
    4ebf:	je     4fb9 <botlish_fn_49+0x3d1>
    4ec5:	mov    QWORD PTR [rsp+0x10],rax
    4eca:	mov    rdi,r13
    4ecd:	mov    QWORD PTR [rsp+0x80],rax
    4ed5:	mov    rax,QWORD PTR [rdi+0x10]
    4ed9:	mov    rdx,QWORD PTR [rax+0x30]
    4edd:	mov    rsi,r14
    4ee0:	call   4ee5 <botlish_fn_49+0x2fd>
			4ee1: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4ee5:	test   rax,rax
    4ee8:	je     4fb9 <botlish_fn_49+0x3d1>
    4eee:	mov    QWORD PTR [rsp+0x18],rax
    4ef3:	mov    rdi,r13
    4ef6:	mov    QWORD PTR [rsp+0x78],rax
    4efb:	mov    rax,QWORD PTR [rdi+0x10]
    4eff:	mov    rdx,QWORD PTR [rax+0x38]
    4f03:	mov    rsi,r14
    4f06:	call   4f0b <botlish_fn_49+0x323>
			4f07: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4f0b:	test   rax,rax
    4f0e:	je     4fb9 <botlish_fn_49+0x3d1>
    4f14:	mov    QWORD PTR [rsp+0x20],rax
    4f19:	mov    rdi,r13
    4f1c:	mov    r14,rax
    4f1f:	mov    rax,QWORD PTR [rdi+0x10]
    4f23:	mov    rdx,QWORD PTR [rax+0x28]
    4f27:	mov    rsi,r15
    4f2a:	call   4f2f <botlish_fn_49+0x347>
			4f2b: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4f2f:	test   rax,rax
    4f32:	je     4fb9 <botlish_fn_49+0x3d1>
    4f38:	mov    QWORD PTR [rsp+0x28],rax
    4f3d:	mov    rdi,r13
    4f40:	mov    QWORD PTR [rsp+0x70],rax
    4f45:	mov    rax,QWORD PTR [rdi+0x10]
    4f49:	mov    rdx,QWORD PTR [rax+0x38]
    4f4d:	mov    rsi,r15
    4f50:	call   4f55 <botlish_fn_49+0x36d>
			4f51: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4f55:	test   rax,rax
    4f58:	je     4fb9 <botlish_fn_49+0x3d1>
    4f5e:	mov    QWORD PTR [rsp+0x30],rax
    4f63:	lea    rdx,[rsp+0x38]
    4f68:	mov    rcx,r12
    4f6b:	mov    QWORD PTR [rsp+0x38],rcx
    4f70:	mov    rsi,QWORD PTR [rsp+0x80]
    4f78:	mov    QWORD PTR [rsp+0x40],rsi
    4f7d:	mov    rdi,QWORD PTR [rsp+0x78]
    4f82:	mov    QWORD PTR [rsp+0x48],rdi
    4f87:	mov    r10,r14
    4f8a:	mov    QWORD PTR [rsp+0x50],r10
    4f8f:	mov    rcx,QWORD PTR [rsp+0x70]
    4f94:	mov    QWORD PTR [rsp+0x58],rcx
    4f99:	mov    QWORD PTR [rsp+0x60],rax
    4f9e:	mov    QWORD PTR [rsp+0x68],rbx
    4fa3:	mov    esi,0x7
    4fa8:	mov    rdi,r13
    4fab:	call   4fb0 <botlish_fn_49+0x3c8>
			4fac: R_X86_64_PLT32	rt_list_new-0x4
    4fb0:	test   rax,rax
    4fb3:	jne    4ff0 <botlish_fn_49+0x408>
    4fb9:	xor    rax,rax
    4fbc:	mov    rbx,QWORD PTR [rsp+0x90]
    4fc4:	mov    r12,QWORD PTR [rsp+0x98]
    4fcc:	mov    r13,QWORD PTR [rsp+0xa0]
    4fd4:	mov    r14,QWORD PTR [rsp+0xa8]
    4fdc:	mov    r15,QWORD PTR [rsp+0xb0]
    4fe4:	add    rsp,0xc0
    4feb:	mov    rsp,rbp
    4fee:	pop    rbp
    4fef:	ret
    4ff0:	mov    rbx,QWORD PTR [rsp+0x90]
    4ff8:	mov    r12,QWORD PTR [rsp+0x98]
    5000:	mov    r13,QWORD PTR [rsp+0xa0]
    5008:	mov    r14,QWORD PTR [rsp+0xa8]
    5010:	mov    r15,QWORD PTR [rsp+0xb0]
    5018:	add    rsp,0xc0
    501f:	mov    rsp,rbp
    5022:	pop    rbp
    5023:	ret
    5024:	add    BYTE PTR [rax],al
    5026:	add    BYTE PTR [rax],al
    5028:	(bad)
    5029:	add    BYTE PTR [rax],al
    502b:	add    BYTE PTR [rax],al
    502d:	add    BYTE PTR [rax],al
	...

0000000000005030 <botlish_entry_49: sample_checks<generic>>:
    5030:	push   rbp
    5031:	mov    rbp,rsp
    5034:	call   5039 <botlish_entry_49+0x9>
			5035: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    5039:	mov    rsp,rbp
    503c:	pop    rbp
    503d:	ret

000000000000503e <botlish_fn_50: sample<generic>>:
    503e:	push   rbp
    503f:	mov    rbp,rsp
    5042:	sub    rsp,0x10
    5046:	mov    QWORD PTR [rsp],rbx
    504a:	mov    rbx,rdi
    504d:	mov    rdi,rbx
    5050:	call   5055 <botlish_fn_50+0x17>
			5051: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    5055:	test   rax,rax
    5058:	jne    5111 <botlish_fn_50+0xd3>
    505e:	mov    rdi,rbx
    5061:	call   5066 <botlish_fn_50+0x28>
			5062: R_X86_64_PLT32	rt_declared_error-0x4
    5066:	cmp    rax,0x40000001
    506c:	je     50e2 <botlish_fn_50+0xa4>
    5072:	mov    rdi,rbx
    5075:	call   507a <botlish_fn_50+0x3c>
			5076: R_X86_64_PLT32	rt_declared_error-0x4
    507a:	cmp    rax,0x40000002
    5080:	je     50be <botlish_fn_50+0x80>
    5086:	mov    rdi,rbx
    5089:	call   508e <botlish_fn_50+0x50>
			508a: R_X86_64_PLT32	rt_declared_error-0x4
    508e:	cmp    rax,0x40000003
    5094:	jne    5101 <botlish_fn_50+0xc3>
    509a:	mov    rdi,rbx
    509d:	call   50a2 <botlish_fn_50+0x64>
			509e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    50a2:	xor    rdx,rdx
    50a5:	mov    rdi,rbx
    50a8:	mov    rsi,rdx
    50ab:	call   50b0 <botlish_fn_50+0x72>
			50ac: R_X86_64_PLT32	rt_list_new-0x4
    50b0:	test   rax,rax
    50b3:	je     5101 <botlish_fn_50+0xc3>
    50b9:	jmp    5111 <botlish_fn_50+0xd3>
    50be:	mov    rdi,rbx
    50c1:	call   50c6 <botlish_fn_50+0x88>
			50c2: R_X86_64_PLT32	rt_clear_declared_error-0x4
    50c6:	xor    rdx,rdx
    50c9:	mov    rdi,rbx
    50cc:	mov    rsi,rdx
    50cf:	call   50d4 <botlish_fn_50+0x96>
			50d0: R_X86_64_PLT32	rt_list_new-0x4
    50d4:	test   rax,rax
    50d7:	je     5101 <botlish_fn_50+0xc3>
    50dd:	jmp    5111 <botlish_fn_50+0xd3>
    50e2:	mov    rdi,rbx
    50e5:	call   50ea <botlish_fn_50+0xac>
			50e6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    50ea:	xor    rdx,rdx
    50ed:	mov    rdi,rbx
    50f0:	mov    rsi,rdx
    50f3:	call   50f8 <botlish_fn_50+0xba>
			50f4: R_X86_64_PLT32	rt_list_new-0x4
    50f8:	test   rax,rax
    50fb:	jne    5111 <botlish_fn_50+0xd3>
    5101:	xor    rax,rax
    5104:	mov    rbx,QWORD PTR [rsp]
    5108:	add    rsp,0x10
    510c:	mov    rsp,rbp
    510f:	pop    rbp
    5110:	ret
    5111:	mov    rbx,QWORD PTR [rsp]
    5115:	add    rsp,0x10
    5119:	mov    rsp,rbp
    511c:	pop    rbp
    511d:	ret

000000000000511e <botlish_entry_50: sample<generic>>:
    511e:	push   rbp
    511f:	mov    rbp,rsp
    5122:	call   5127 <botlish_entry_50+0x9>
			5123: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    5127:	mov    rsp,rbp
    512a:	pop    rbp
    512b:	ret

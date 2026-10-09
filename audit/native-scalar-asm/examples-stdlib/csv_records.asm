; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 19685  (per function: 45 89 89 89 357 420 420 420 202 202 202 81 365 309 526 932 310 758 215 480 318 427 385 70 493 114 69 69 46 170 236 636 1040 333 380 402 616 654 809 673 928 684 107 433 259 629 515 78 78 1222 301)
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
     291:	mov    r13,rdi
     294:	mov    QWORD PTR [rsp],rsi
     298:	mov    r12,rsi
     29b:	mov    QWORD PTR [rsp+0x8],rdx
     2a0:	mov    rbx,rdx
     2a3:	mov    QWORD PTR [rsp+0x10],rcx
     2a8:	mov    r14,rcx
     2ab:	mov    rsi,r12
     2ae:	mov    rdi,r13
     2b1:	call   2b6 <botlish_fn_5+0x46>
			2b2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     2b6:	mov    r15,rax
     2b9:	mov    QWORD PTR [rsp+0x18],rax
     2be:	mov    rcx,rbx
     2c1:	and    rcx,rax
     2c4:	test   rcx,0x1
     2cb:	jne    2f7 <botlish_fn_5+0x87>
     2d1:	mov    rdx,r15
     2d4:	mov    rsi,rbx
     2d7:	mov    rdi,r13
     2da:	call   2df <botlish_fn_5+0x6f>
			2db: R_X86_64_PLT32	rt_int_cmp-0x4
     2df:	mov    ecx,0x2
     2e4:	test   rax,rax
     2e7:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 3d8 <botlish_fn_5+0x168>
     2ef:	mov    rax,r15
     2f2:	jmp    30a <botlish_fn_5+0x9a>
     2f7:	mov    ecx,0x2
     2fc:	mov    rax,r15
     2ff:	cmp    rbx,rax
     302:	cmovl  rcx,QWORD PTR [rip+0xce]        # 3d8 <botlish_fn_5+0x168>
     30a:	cmp    rcx,0x6
     30e:	je     3ae <botlish_fn_5+0x13e>
     314:	mov    rsi,rax
     317:	mov    rdx,rbx
     31a:	mov    rdi,r13
     31d:	call   322 <botlish_fn_5+0xb2>
			31e: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     322:	mov    QWORD PTR [rsp+0x18],rax
     327:	mov    rdx,r14
     32a:	mov    rsi,rax
     32d:	mov    rdi,r13
     330:	call   335 <botlish_fn_5+0xc5>
			331: R_X86_64_PLT32	rt_mutarray_create-0x4
     335:	test   rax,rax
     338:	mov    r14,rax
     33b:	je     364 <botlish_fn_5+0xf4>
     341:	mov    r8d,0x1
     347:	mov    rcx,r12
     34a:	mov    rdi,r13
     34d:	mov    r9,rbx
     350:	mov    rsi,r14
     353:	mov    rdx,r8
     356:	call   35b <botlish_fn_5+0xeb>
			357: R_X86_64_PLT32	rt_mutarray_copy-0x4
     35b:	test   rax,rax
     35e:	jne    389 <botlish_fn_5+0x119>
     364:	xor    rax,rax
     367:	mov    rbx,QWORD PTR [rsp+0x20]
     36c:	mov    r12,QWORD PTR [rsp+0x28]
     371:	mov    r13,QWORD PTR [rsp+0x30]
     376:	mov    r14,QWORD PTR [rsp+0x38]
     37b:	mov    r15,QWORD PTR [rsp+0x40]
     380:	add    rsp,0x50
     384:	mov    rsp,rbp
     387:	pop    rbp
     388:	ret
     389:	mov    rax,r14
     38c:	mov    rbx,QWORD PTR [rsp+0x20]
     391:	mov    r12,QWORD PTR [rsp+0x28]
     396:	mov    r13,QWORD PTR [rsp+0x30]
     39b:	mov    r14,QWORD PTR [rsp+0x38]
     3a0:	mov    r15,QWORD PTR [rsp+0x40]
     3a5:	add    rsp,0x50
     3a9:	mov    rsp,rbp
     3ac:	pop    rbp
     3ad:	ret
     3ae:	mov    rax,r12
     3b1:	mov    rbx,QWORD PTR [rsp+0x20]
     3b6:	mov    r12,QWORD PTR [rsp+0x28]
     3bb:	mov    r13,QWORD PTR [rsp+0x30]
     3c0:	mov    r14,QWORD PTR [rsp+0x38]
     3c5:	mov    r15,QWORD PTR [rsp+0x40]
     3ca:	add    rsp,0x50
     3ce:	mov    rsp,rbp
     3d1:	pop    rbp
     3d2:	ret
     3d3:	add    BYTE PTR [rax],al
     3d5:	add    BYTE PTR [rax],al
     3d7:	add    BYTE PTR [rsi],al
     3d9:	add    BYTE PTR [rax],al
     3db:	add    BYTE PTR [rax],al
     3dd:	add    BYTE PTR [rax],al
	...

00000000000003e0 <botlish_entry_5: geo_grow<mutarray, int, str>>:
     3e0:	push   rbp
     3e1:	mov    rbp,rsp
     3e4:	mov    rsi,QWORD PTR [rdx]
     3e7:	mov    r8,QWORD PTR [rdx+0x8]
     3eb:	mov    rcx,QWORD PTR [rdx+0x10]
     3ef:	mov    rdx,r8
     3f2:	call   3f7 <botlish_entry_5+0x17>
			3f3: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     3f7:	mov    rsp,rbp
     3fa:	pop    rbp
     3fb:	ret
     3fc:	add    BYTE PTR [rax],al
	...

0000000000000400 <botlish_fn_6: geo_grow<mutarray, int, List[str]>>:
     400:	push   rbp
     401:	mov    rbp,rsp
     404:	sub    rsp,0x50
     408:	mov    QWORD PTR [rsp+0x20],rbx
     40d:	mov    QWORD PTR [rsp+0x28],r12
     412:	mov    QWORD PTR [rsp+0x30],r13
     417:	mov    QWORD PTR [rsp+0x38],r14
     41c:	mov    QWORD PTR [rsp+0x40],r15
     421:	mov    r13,rdi
     424:	mov    QWORD PTR [rsp],rsi
     428:	mov    r12,rsi
     42b:	mov    QWORD PTR [rsp+0x8],rdx
     430:	mov    rbx,rdx
     433:	mov    QWORD PTR [rsp+0x10],rcx
     438:	mov    r14,rcx
     43b:	mov    rsi,r12
     43e:	mov    rdi,r13
     441:	call   446 <botlish_fn_6+0x46>
			442: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     446:	mov    r15,rax
     449:	mov    QWORD PTR [rsp+0x18],rax
     44e:	mov    rcx,rbx
     451:	and    rcx,rax
     454:	test   rcx,0x1
     45b:	jne    487 <botlish_fn_6+0x87>
     461:	mov    rdx,r15
     464:	mov    rsi,rbx
     467:	mov    rdi,r13
     46a:	call   46f <botlish_fn_6+0x6f>
			46b: R_X86_64_PLT32	rt_int_cmp-0x4
     46f:	mov    ecx,0x2
     474:	test   rax,rax
     477:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 568 <botlish_fn_6+0x168>
     47f:	mov    rax,r15
     482:	jmp    49a <botlish_fn_6+0x9a>
     487:	mov    ecx,0x2
     48c:	mov    rax,r15
     48f:	cmp    rbx,rax
     492:	cmovl  rcx,QWORD PTR [rip+0xce]        # 568 <botlish_fn_6+0x168>
     49a:	cmp    rcx,0x6
     49e:	je     53e <botlish_fn_6+0x13e>
     4a4:	mov    rsi,rax
     4a7:	mov    rdx,rbx
     4aa:	mov    rdi,r13
     4ad:	call   4b2 <botlish_fn_6+0xb2>
			4ae: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     4b2:	mov    QWORD PTR [rsp+0x18],rax
     4b7:	mov    rdx,r14
     4ba:	mov    rsi,rax
     4bd:	mov    rdi,r13
     4c0:	call   4c5 <botlish_fn_6+0xc5>
			4c1: R_X86_64_PLT32	rt_mutarray_create-0x4
     4c5:	test   rax,rax
     4c8:	mov    r14,rax
     4cb:	je     4f4 <botlish_fn_6+0xf4>
     4d1:	mov    r8d,0x1
     4d7:	mov    rcx,r12
     4da:	mov    rdi,r13
     4dd:	mov    r9,rbx
     4e0:	mov    rsi,r14
     4e3:	mov    rdx,r8
     4e6:	call   4eb <botlish_fn_6+0xeb>
			4e7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     4eb:	test   rax,rax
     4ee:	jne    519 <botlish_fn_6+0x119>
     4f4:	xor    rax,rax
     4f7:	mov    rbx,QWORD PTR [rsp+0x20]
     4fc:	mov    r12,QWORD PTR [rsp+0x28]
     501:	mov    r13,QWORD PTR [rsp+0x30]
     506:	mov    r14,QWORD PTR [rsp+0x38]
     50b:	mov    r15,QWORD PTR [rsp+0x40]
     510:	add    rsp,0x50
     514:	mov    rsp,rbp
     517:	pop    rbp
     518:	ret
     519:	mov    rax,r14
     51c:	mov    rbx,QWORD PTR [rsp+0x20]
     521:	mov    r12,QWORD PTR [rsp+0x28]
     526:	mov    r13,QWORD PTR [rsp+0x30]
     52b:	mov    r14,QWORD PTR [rsp+0x38]
     530:	mov    r15,QWORD PTR [rsp+0x40]
     535:	add    rsp,0x50
     539:	mov    rsp,rbp
     53c:	pop    rbp
     53d:	ret
     53e:	mov    rax,r12
     541:	mov    rbx,QWORD PTR [rsp+0x20]
     546:	mov    r12,QWORD PTR [rsp+0x28]
     54b:	mov    r13,QWORD PTR [rsp+0x30]
     550:	mov    r14,QWORD PTR [rsp+0x38]
     555:	mov    r15,QWORD PTR [rsp+0x40]
     55a:	add    rsp,0x50
     55e:	mov    rsp,rbp
     561:	pop    rbp
     562:	ret
     563:	add    BYTE PTR [rax],al
     565:	add    BYTE PTR [rax],al
     567:	add    BYTE PTR [rsi],al
     569:	add    BYTE PTR [rax],al
     56b:	add    BYTE PTR [rax],al
     56d:	add    BYTE PTR [rax],al
	...

0000000000000570 <botlish_entry_6: geo_grow<mutarray, int, List[str]>>:
     570:	push   rbp
     571:	mov    rbp,rsp
     574:	mov    rsi,QWORD PTR [rdx]
     577:	mov    r8,QWORD PTR [rdx+0x8]
     57b:	mov    rcx,QWORD PTR [rdx+0x10]
     57f:	mov    rdx,r8
     582:	call   587 <botlish_entry_6+0x17>
			583: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     587:	mov    rsp,rbp
     58a:	pop    rbp
     58b:	ret
     58c:	add    BYTE PTR [rax],al
	...

0000000000000590 <botlish_fn_7: geo_grow<mutarray, int, HashTable>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	sub    rsp,0x50
     598:	mov    QWORD PTR [rsp+0x20],rbx
     59d:	mov    QWORD PTR [rsp+0x28],r12
     5a2:	mov    QWORD PTR [rsp+0x30],r13
     5a7:	mov    QWORD PTR [rsp+0x38],r14
     5ac:	mov    QWORD PTR [rsp+0x40],r15
     5b1:	mov    r13,rdi
     5b4:	mov    QWORD PTR [rsp],rsi
     5b8:	mov    r12,rsi
     5bb:	mov    QWORD PTR [rsp+0x8],rdx
     5c0:	mov    rbx,rdx
     5c3:	mov    QWORD PTR [rsp+0x10],rcx
     5c8:	mov    r14,rcx
     5cb:	mov    rsi,r12
     5ce:	mov    rdi,r13
     5d1:	call   5d6 <botlish_fn_7+0x46>
			5d2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     5d6:	mov    r15,rax
     5d9:	mov    QWORD PTR [rsp+0x18],rax
     5de:	mov    rcx,rbx
     5e1:	and    rcx,rax
     5e4:	test   rcx,0x1
     5eb:	jne    617 <botlish_fn_7+0x87>
     5f1:	mov    rdx,r15
     5f4:	mov    rsi,rbx
     5f7:	mov    rdi,r13
     5fa:	call   5ff <botlish_fn_7+0x6f>
			5fb: R_X86_64_PLT32	rt_int_cmp-0x4
     5ff:	mov    ecx,0x2
     604:	test   rax,rax
     607:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 6f8 <botlish_fn_7+0x168>
     60f:	mov    rax,r15
     612:	jmp    62a <botlish_fn_7+0x9a>
     617:	mov    ecx,0x2
     61c:	mov    rax,r15
     61f:	cmp    rbx,rax
     622:	cmovl  rcx,QWORD PTR [rip+0xce]        # 6f8 <botlish_fn_7+0x168>
     62a:	cmp    rcx,0x6
     62e:	je     6ce <botlish_fn_7+0x13e>
     634:	mov    rsi,rax
     637:	mov    rdx,rbx
     63a:	mov    rdi,r13
     63d:	call   642 <botlish_fn_7+0xb2>
			63e: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     642:	mov    QWORD PTR [rsp+0x18],rax
     647:	mov    rdx,r14
     64a:	mov    rsi,rax
     64d:	mov    rdi,r13
     650:	call   655 <botlish_fn_7+0xc5>
			651: R_X86_64_PLT32	rt_mutarray_create-0x4
     655:	test   rax,rax
     658:	mov    r14,rax
     65b:	je     684 <botlish_fn_7+0xf4>
     661:	mov    r8d,0x1
     667:	mov    rcx,r12
     66a:	mov    rdi,r13
     66d:	mov    r9,rbx
     670:	mov    rsi,r14
     673:	mov    rdx,r8
     676:	call   67b <botlish_fn_7+0xeb>
			677: R_X86_64_PLT32	rt_mutarray_copy-0x4
     67b:	test   rax,rax
     67e:	jne    6a9 <botlish_fn_7+0x119>
     684:	xor    rax,rax
     687:	mov    rbx,QWORD PTR [rsp+0x20]
     68c:	mov    r12,QWORD PTR [rsp+0x28]
     691:	mov    r13,QWORD PTR [rsp+0x30]
     696:	mov    r14,QWORD PTR [rsp+0x38]
     69b:	mov    r15,QWORD PTR [rsp+0x40]
     6a0:	add    rsp,0x50
     6a4:	mov    rsp,rbp
     6a7:	pop    rbp
     6a8:	ret
     6a9:	mov    rax,r14
     6ac:	mov    rbx,QWORD PTR [rsp+0x20]
     6b1:	mov    r12,QWORD PTR [rsp+0x28]
     6b6:	mov    r13,QWORD PTR [rsp+0x30]
     6bb:	mov    r14,QWORD PTR [rsp+0x38]
     6c0:	mov    r15,QWORD PTR [rsp+0x40]
     6c5:	add    rsp,0x50
     6c9:	mov    rsp,rbp
     6cc:	pop    rbp
     6cd:	ret
     6ce:	mov    rax,r12
     6d1:	mov    rbx,QWORD PTR [rsp+0x20]
     6d6:	mov    r12,QWORD PTR [rsp+0x28]
     6db:	mov    r13,QWORD PTR [rsp+0x30]
     6e0:	mov    r14,QWORD PTR [rsp+0x38]
     6e5:	mov    r15,QWORD PTR [rsp+0x40]
     6ea:	add    rsp,0x50
     6ee:	mov    rsp,rbp
     6f1:	pop    rbp
     6f2:	ret
     6f3:	add    BYTE PTR [rax],al
     6f5:	add    BYTE PTR [rax],al
     6f7:	add    BYTE PTR [rsi],al
     6f9:	add    BYTE PTR [rax],al
     6fb:	add    BYTE PTR [rax],al
     6fd:	add    BYTE PTR [rax],al
	...

0000000000000700 <botlish_entry_7: geo_grow<mutarray, int, HashTable>>:
     700:	push   rbp
     701:	mov    rbp,rsp
     704:	mov    rsi,QWORD PTR [rdx]
     707:	mov    r8,QWORD PTR [rdx+0x8]
     70b:	mov    rcx,QWORD PTR [rdx+0x10]
     70f:	mov    rdx,r8
     712:	call   717 <botlish_entry_7+0x17>
			713: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     717:	mov    rsp,rbp
     71a:	pop    rbp
     71b:	ret

000000000000071c <botlish_fn_8: geo_append<mutarray, int, str>>:
     71c:	push   rbp
     71d:	mov    rbp,rsp
     720:	sub    rsp,0x40
     724:	mov    QWORD PTR [rsp+0x20],rbx
     729:	mov    QWORD PTR [rsp+0x28],r12
     72e:	mov    QWORD PTR [rsp+0x30],r13
     733:	mov    QWORD PTR [rsp+0x38],r14
     738:	mov    r14,rdi
     73b:	mov    QWORD PTR [rsp],rsi
     73f:	mov    QWORD PTR [rsp+0x8],rdx
     744:	mov    r13,rdx
     747:	mov    QWORD PTR [rsp+0x10],rcx
     74c:	mov    r12,rcx
     74f:	mov    rcx,r12
     752:	mov    rdx,r13
     755:	mov    rdi,r14
     758:	call   75d <botlish_fn_8+0x41>
			759: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     75d:	test   rax,rax
     760:	mov    rbx,rax
     763:	je     783 <botlish_fn_8+0x67>
     769:	mov    rcx,r12
     76c:	mov    rdx,r13
     76f:	mov    rdi,r14
     772:	mov    rsi,rbx
     775:	call   77a <botlish_fn_8+0x5e>
			776: R_X86_64_PLT32	rt_mutarray_set-0x4
     77a:	test   rax,rax
     77d:	jne    7a3 <botlish_fn_8+0x87>
     783:	xor    rax,rax
     786:	mov    rbx,QWORD PTR [rsp+0x20]
     78b:	mov    r12,QWORD PTR [rsp+0x28]
     790:	mov    r13,QWORD PTR [rsp+0x30]
     795:	mov    r14,QWORD PTR [rsp+0x38]
     79a:	add    rsp,0x40
     79e:	mov    rsp,rbp
     7a1:	pop    rbp
     7a2:	ret
     7a3:	mov    rax,rbx
     7a6:	mov    rbx,QWORD PTR [rsp+0x20]
     7ab:	mov    r12,QWORD PTR [rsp+0x28]
     7b0:	mov    r13,QWORD PTR [rsp+0x30]
     7b5:	mov    r14,QWORD PTR [rsp+0x38]
     7ba:	add    rsp,0x40
     7be:	mov    rsp,rbp
     7c1:	pop    rbp
     7c2:	ret

00000000000007c3 <botlish_entry_8: geo_append<mutarray, int, str>>:
     7c3:	push   rbp
     7c4:	mov    rbp,rsp
     7c7:	mov    rsi,QWORD PTR [rdx]
     7ca:	mov    r8,QWORD PTR [rdx+0x8]
     7ce:	mov    rcx,QWORD PTR [rdx+0x10]
     7d2:	mov    rdx,r8
     7d5:	call   7da <botlish_entry_8+0x17>
			7d6: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     7da:	mov    rsp,rbp
     7dd:	pop    rbp
     7de:	ret

00000000000007df <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     7df:	push   rbp
     7e0:	mov    rbp,rsp
     7e3:	sub    rsp,0x40
     7e7:	mov    QWORD PTR [rsp+0x20],rbx
     7ec:	mov    QWORD PTR [rsp+0x28],r12
     7f1:	mov    QWORD PTR [rsp+0x30],r13
     7f6:	mov    QWORD PTR [rsp+0x38],r14
     7fb:	mov    r14,rdi
     7fe:	mov    QWORD PTR [rsp],rsi
     802:	mov    QWORD PTR [rsp+0x8],rdx
     807:	mov    r13,rdx
     80a:	mov    QWORD PTR [rsp+0x10],rcx
     80f:	mov    r12,rcx
     812:	mov    rcx,r12
     815:	mov    rdx,r13
     818:	mov    rdi,r14
     81b:	call   820 <botlish_fn_9+0x41>
			81c: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     820:	test   rax,rax
     823:	mov    rbx,rax
     826:	je     846 <botlish_fn_9+0x67>
     82c:	mov    rcx,r12
     82f:	mov    rdx,r13
     832:	mov    rdi,r14
     835:	mov    rsi,rbx
     838:	call   83d <botlish_fn_9+0x5e>
			839: R_X86_64_PLT32	rt_mutarray_set-0x4
     83d:	test   rax,rax
     840:	jne    866 <botlish_fn_9+0x87>
     846:	xor    rax,rax
     849:	mov    rbx,QWORD PTR [rsp+0x20]
     84e:	mov    r12,QWORD PTR [rsp+0x28]
     853:	mov    r13,QWORD PTR [rsp+0x30]
     858:	mov    r14,QWORD PTR [rsp+0x38]
     85d:	add    rsp,0x40
     861:	mov    rsp,rbp
     864:	pop    rbp
     865:	ret
     866:	mov    rax,rbx
     869:	mov    rbx,QWORD PTR [rsp+0x20]
     86e:	mov    r12,QWORD PTR [rsp+0x28]
     873:	mov    r13,QWORD PTR [rsp+0x30]
     878:	mov    r14,QWORD PTR [rsp+0x38]
     87d:	add    rsp,0x40
     881:	mov    rsp,rbp
     884:	pop    rbp
     885:	ret

0000000000000886 <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     886:	push   rbp
     887:	mov    rbp,rsp
     88a:	mov    rsi,QWORD PTR [rdx]
     88d:	mov    r8,QWORD PTR [rdx+0x8]
     891:	mov    rcx,QWORD PTR [rdx+0x10]
     895:	mov    rdx,r8
     898:	call   89d <botlish_entry_9+0x17>
			899: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     89d:	mov    rsp,rbp
     8a0:	pop    rbp
     8a1:	ret

00000000000008a2 <botlish_fn_10: geo_append<mutarray, int, HashTable>>:
     8a2:	push   rbp
     8a3:	mov    rbp,rsp
     8a6:	sub    rsp,0x40
     8aa:	mov    QWORD PTR [rsp+0x20],rbx
     8af:	mov    QWORD PTR [rsp+0x28],r12
     8b4:	mov    QWORD PTR [rsp+0x30],r13
     8b9:	mov    QWORD PTR [rsp+0x38],r14
     8be:	mov    r14,rdi
     8c1:	mov    QWORD PTR [rsp],rsi
     8c5:	mov    QWORD PTR [rsp+0x8],rdx
     8ca:	mov    r13,rdx
     8cd:	mov    QWORD PTR [rsp+0x10],rcx
     8d2:	mov    r12,rcx
     8d5:	mov    rcx,r12
     8d8:	mov    rdx,r13
     8db:	mov    rdi,r14
     8de:	call   8e3 <botlish_fn_10+0x41>
			8df: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     8e3:	test   rax,rax
     8e6:	mov    rbx,rax
     8e9:	je     909 <botlish_fn_10+0x67>
     8ef:	mov    rcx,r12
     8f2:	mov    rdx,r13
     8f5:	mov    rdi,r14
     8f8:	mov    rsi,rbx
     8fb:	call   900 <botlish_fn_10+0x5e>
			8fc: R_X86_64_PLT32	rt_mutarray_set-0x4
     900:	test   rax,rax
     903:	jne    929 <botlish_fn_10+0x87>
     909:	xor    rax,rax
     90c:	mov    rbx,QWORD PTR [rsp+0x20]
     911:	mov    r12,QWORD PTR [rsp+0x28]
     916:	mov    r13,QWORD PTR [rsp+0x30]
     91b:	mov    r14,QWORD PTR [rsp+0x38]
     920:	add    rsp,0x40
     924:	mov    rsp,rbp
     927:	pop    rbp
     928:	ret
     929:	mov    rax,rbx
     92c:	mov    rbx,QWORD PTR [rsp+0x20]
     931:	mov    r12,QWORD PTR [rsp+0x28]
     936:	mov    r13,QWORD PTR [rsp+0x30]
     93b:	mov    r14,QWORD PTR [rsp+0x38]
     940:	add    rsp,0x40
     944:	mov    rsp,rbp
     947:	pop    rbp
     948:	ret

0000000000000949 <botlish_entry_10: geo_append<mutarray, int, HashTable>>:
     949:	push   rbp
     94a:	mov    rbp,rsp
     94d:	mov    rsi,QWORD PTR [rdx]
     950:	mov    r8,QWORD PTR [rdx+0x8]
     954:	mov    rcx,QWORD PTR [rdx+0x10]
     958:	mov    rdx,r8
     95b:	call   960 <botlish_entry_10+0x17>
			95c: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
     960:	mov    rsp,rbp
     963:	pop    rbp
     964:	ret

0000000000000965 <botlish_fn_11: geo_finish<mutarray, int>>:
     965:	push   rbp
     966:	mov    rbp,rsp
     969:	sub    rsp,0x10
     96d:	mov    QWORD PTR [rsp],rsi
     971:	mov    QWORD PTR [rsp+0x8],rdx
     976:	call   97b <botlish_fn_11+0x16>
			977: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     97b:	test   rax,rax
     97e:	jne    990 <botlish_fn_11+0x2b>
     984:	xor    rax,rax
     987:	add    rsp,0x10
     98b:	mov    rsp,rbp
     98e:	pop    rbp
     98f:	ret
     990:	add    rsp,0x10
     994:	mov    rsp,rbp
     997:	pop    rbp
     998:	ret

0000000000000999 <botlish_entry_11: geo_finish<mutarray, int>>:
     999:	push   rbp
     99a:	mov    rbp,rsp
     99d:	mov    rsi,QWORD PTR [rdx]
     9a0:	mov    rdx,QWORD PTR [rdx+0x8]
     9a4:	call   9a9 <botlish_entry_11+0x10>
			9a5: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
     9a9:	mov    rsp,rbp
     9ac:	pop    rbp
     9ad:	ret
	...

00000000000009b0 <botlish_fn_12: peek<str, int>>:
     9b0:	push   rbp
     9b1:	mov    rbp,rsp
     9b4:	sub    rsp,0x40
     9b8:	mov    QWORD PTR [rsp+0x20],rbx
     9bd:	mov    QWORD PTR [rsp+0x28],r12
     9c2:	mov    QWORD PTR [rsp+0x30],r13
     9c7:	mov    rbx,rdx
     9ca:	mov    r13,rdi
     9cd:	mov    QWORD PTR [rsp],rsi
     9d1:	mov    QWORD PTR [rsp+0x8],rdx
     9d6:	mov    rdx,QWORD PTR [rsi+0x8]
     9da:	mov    r12,rsi
     9dd:	shl    rdx,1
     9e0:	mov    rax,rdx
     9e3:	or     rax,0x1
     9e7:	mov    rcx,rbx
     9ea:	and    rcx,rax
     9ed:	test   rcx,0x1
     9f4:	jne    a1e <botlish_fn_12+0x6e>
     9fa:	or     rdx,0x1
     9fe:	mov    rsi,rbx
     a01:	mov    rdi,r13
     a04:	call   a09 <botlish_fn_12+0x59>
			a05: R_X86_64_PLT32	rt_int_cmp-0x4
     a09:	mov    ecx,0x2
     a0e:	test   rax,rax
     a11:	cmovge rcx,QWORD PTR [rip+0xcf]        # ae8 <botlish_fn_12+0x138>
     a19:	jmp    a32 <botlish_fn_12+0x82>
     a1e:	or     rdx,0x1
     a22:	mov    ecx,0x2
     a27:	cmp    rbx,rdx
     a2a:	cmovge rcx,QWORD PTR [rip+0xb6]        # ae8 <botlish_fn_12+0x138>
     a32:	cmp    rcx,0x6
     a36:	je     ac6 <botlish_fn_12+0x116>
     a3c:	mov    QWORD PTR [rsp+0x10],0x3
     a45:	test   rbx,0x1
     a4c:	je     a64 <botlish_fn_12+0xb4>
     a52:	mov    rcx,rbx
     a55:	add    rcx,0x2
     a59:	seto   al
     a5c:	test   al,al
     a5e:	je     a77 <botlish_fn_12+0xc7>
     a64:	mov    edx,0x3
     a69:	mov    rsi,rbx
     a6c:	mov    rdi,r13
     a6f:	call   a74 <botlish_fn_12+0xc4>
			a70: R_X86_64_PLT32	rt_int_add-0x4
     a74:	mov    rcx,rax
     a77:	mov    QWORD PTR [rsp+0x10],rcx
     a7c:	mov    rdx,rbx
     a7f:	mov    rsi,r12
     a82:	mov    rdi,r13
     a85:	call   a8a <botlish_fn_12+0xda>
			a86: R_X86_64_PLT32	rt_substr-0x4
     a8a:	test   rax,rax
     a8d:	jne    aae <botlish_fn_12+0xfe>
     a93:	xor    rax,rax
     a96:	mov    rbx,QWORD PTR [rsp+0x20]
     a9b:	mov    r12,QWORD PTR [rsp+0x28]
     aa0:	mov    r13,QWORD PTR [rsp+0x30]
     aa5:	add    rsp,0x40
     aa9:	mov    rsp,rbp
     aac:	pop    rbp
     aad:	ret
     aae:	mov    rbx,QWORD PTR [rsp+0x20]
     ab3:	mov    r12,QWORD PTR [rsp+0x28]
     ab8:	mov    r13,QWORD PTR [rsp+0x30]
     abd:	add    rsp,0x40
     ac1:	mov    rsp,rbp
     ac4:	pop    rbp
     ac5:	ret
     ac6:	mov    rdi,r13
     ac9:	mov    rax,QWORD PTR [rdi+0x10]
     acd:	mov    rax,QWORD PTR [rax]
     ad0:	mov    rbx,QWORD PTR [rsp+0x20]
     ad5:	mov    r12,QWORD PTR [rsp+0x28]
     ada:	mov    r13,QWORD PTR [rsp+0x30]
     adf:	add    rsp,0x40
     ae3:	mov    rsp,rbp
     ae6:	pop    rbp
     ae7:	ret
     ae8:	(bad)
     ae9:	add    BYTE PTR [rax],al
     aeb:	add    BYTE PTR [rax],al
     aed:	add    BYTE PTR [rax],al
	...

0000000000000af0 <botlish_entry_12: peek<str, int>>:
     af0:	push   rbp
     af1:	mov    rbp,rsp
     af4:	mov    rsi,QWORD PTR [rdx]
     af7:	mov    rdx,QWORD PTR [rdx+0x8]
     afb:	call   b00 <botlish_entry_12+0x10>
			afc: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     b00:	mov    rsp,rbp
     b03:	pop    rbp
     b04:	ret
     b05:	add    BYTE PTR [rax],al
	...

0000000000000b08 <botlish_fn_13: quote_at?<str, int>>:
     b08:	push   rbp
     b09:	mov    rbp,rsp
     b0c:	sub    rsp,0x20
     b10:	mov    QWORD PTR [rsp],rbx
     b14:	mov    QWORD PTR [rsp+0x8],r12
     b19:	mov    QWORD PTR [rsp+0x10],r13
     b1e:	mov    rbx,rdx
     b21:	mov    r13,rdi
     b24:	mov    rdx,QWORD PTR [rsi+0x8]
     b28:	mov    r12,rsi
     b2b:	shl    rdx,1
     b2e:	mov    rax,rdx
     b31:	or     rax,0x1
     b35:	mov    rcx,rbx
     b38:	and    rcx,rax
     b3b:	test   rcx,0x1
     b42:	jne    b6c <botlish_fn_13+0x64>
     b48:	or     rdx,0x1
     b4c:	mov    rsi,rbx
     b4f:	mov    rdi,r13
     b52:	call   b57 <botlish_fn_13+0x4f>
			b53: R_X86_64_PLT32	rt_int_cmp-0x4
     b57:	mov    ecx,0x2
     b5c:	test   rax,rax
     b5f:	cmovl  rcx,QWORD PTR [rip+0xa1]        # c08 <botlish_fn_13+0x100>
     b67:	jmp    b83 <botlish_fn_13+0x7b>
     b6c:	or     rdx,0x1
     b70:	mov    ecx,0x2
     b75:	mov    rax,rbx
     b78:	cmp    rax,rdx
     b7b:	cmovl  rcx,QWORD PTR [rip+0x85]        # c08 <botlish_fn_13+0x100>
     b83:	mov    eax,0x6
     b88:	cmp    rcx,0x6
     b8c:	je     b9f <botlish_fn_13+0x97>
     b92:	mov    eax,0x2
     b97:	mov    r12,rax
     b9a:	jmp    bec <botlish_fn_13+0xe4>
     b9f:	mov    rdi,r13
     ba2:	mov    rsi,r12
     ba5:	mov    r12,rax
     ba8:	mov    rdx,rbx
     bab:	call   bb0 <botlish_fn_13+0xa8>
			bac: R_X86_64_PLT32	rt_str_char_at-0x4
     bb0:	test   rax,rax
     bb3:	jne    bd3 <botlish_fn_13+0xcb>
     bb9:	xor    rax,rax
     bbc:	mov    rbx,QWORD PTR [rsp]
     bc0:	mov    r12,QWORD PTR [rsp+0x8]
     bc5:	mov    r13,QWORD PTR [rsp+0x10]
     bca:	add    rsp,0x20
     bce:	mov    rsp,rbp
     bd1:	pop    rbp
     bd2:	ret
     bd3:	cmp    rax,0x114
     bd9:	je     be9 <botlish_fn_13+0xe1>
     bdf:	mov    eax,0x2
     be4:	jmp    bec <botlish_fn_13+0xe4>
     be9:	mov    rax,r12
     bec:	mov    rbx,QWORD PTR [rsp]
     bf0:	mov    r12,QWORD PTR [rsp+0x8]
     bf5:	mov    r13,QWORD PTR [rsp+0x10]
     bfa:	add    rsp,0x20
     bfe:	mov    rsp,rbp
     c01:	pop    rbp
     c02:	ret
     c03:	add    BYTE PTR [rax],al
     c05:	add    BYTE PTR [rax],al
     c07:	add    BYTE PTR [rsi],al
     c09:	add    BYTE PTR [rax],al
     c0b:	add    BYTE PTR [rax],al
     c0d:	add    BYTE PTR [rax],al
	...

0000000000000c10 <botlish_entry_13: quote_at?<str, int>>:
     c10:	push   rbp
     c11:	mov    rbp,rsp
     c14:	mov    rsi,QWORD PTR [rdx]
     c17:	mov    rdx,QWORD PTR [rdx+0x8]
     c1b:	call   c20 <botlish_entry_13+0x10>
			c1c: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     c20:	mov    rsp,rbp
     c23:	pop    rbp
     c24:	ret
     c25:	add    BYTE PTR [rax],al
	...

0000000000000c28 <botlish_fn_14: scan_unquoted<str, int, int>>:
     c28:	push   rbp
     c29:	mov    rbp,rsp
     c2c:	sub    rsp,0x40
     c30:	mov    QWORD PTR [rsp+0x20],rbx
     c35:	mov    QWORD PTR [rsp+0x28],r12
     c3a:	mov    QWORD PTR [rsp+0x30],r13
     c3f:	mov    QWORD PTR [rsp+0x38],r14
     c44:	mov    r14,rdi
     c47:	mov    QWORD PTR [rsp+0x18],0x0
     c50:	mov    QWORD PTR [rsp],rsi
     c54:	mov    r13,rsi
     c57:	mov    QWORD PTR [rsp+0x8],rdx
     c5c:	mov    rbx,rdx
     c5f:	mov    QWORD PTR [rsp+0x10],rcx
     c64:	mov    r12,rcx
     c67:	mov    rdx,QWORD PTR [rsi+0x8]
     c6b:	mov    r13,rsi
     c6e:	shl    rdx,1
     c71:	or     rdx,0x1
     c75:	mov    rax,r12
     c78:	and    rax,rdx
     c7b:	test   rax,0x1
     c81:	jne    ca7 <botlish_fn_14+0x7f>
     c87:	mov    rsi,r12
     c8a:	mov    rdi,r14
     c8d:	call   c92 <botlish_fn_14+0x6a>
			c8e: R_X86_64_PLT32	rt_int_cmp-0x4
     c92:	mov    ecx,0x2
     c97:	test   rax,rax
     c9a:	cmovl  rcx,QWORD PTR [rip+0x17e]        # e20 <botlish_fn_14+0x1f8>
     ca2:	jmp    cba <botlish_fn_14+0x92>
     ca7:	mov    ecx,0x2
     cac:	mov    rsi,r12
     caf:	cmp    rsi,rdx
     cb2:	cmovl  rcx,QWORD PTR [rip+0x166]        # e20 <botlish_fn_14+0x1f8>
     cba:	cmp    rcx,0x6
     cbe:	je     cd2 <botlish_fn_14+0xaa>
     cc4:	mov    rdx,rbx
     cc7:	mov    rsi,r13
     cca:	mov    rdi,r14
     ccd:	jmp    d5d <botlish_fn_14+0x135>
     cd2:	mov    rdx,r12
     cd5:	mov    rsi,r13
     cd8:	mov    rdi,r14
     cdb:	call   ce0 <botlish_fn_14+0xb8>
			cdc: R_X86_64_PLT32	rt_str_char_at-0x4
     ce0:	test   rax,rax
     ce3:	je     d74 <botlish_fn_14+0x14c>
     ce9:	cmp    rax,0x164
     cef:	je     cff <botlish_fn_14+0xd7>
     cf5:	mov    ecx,0x6
     cfa:	jmp    d04 <botlish_fn_14+0xdc>
     cff:	mov    ecx,0x2
     d04:	cmp    rcx,0x6
     d08:	je     d18 <botlish_fn_14+0xf0>
     d0e:	mov    eax,0x2
     d13:	jmp    d4a <botlish_fn_14+0x122>
     d18:	cmp    rax,0x54
     d1c:	je     d2c <botlish_fn_14+0x104>
     d22:	mov    eax,0x6
     d27:	jmp    d31 <botlish_fn_14+0x109>
     d2c:	mov    eax,0x2
     d31:	cmp    rax,0x6
     d35:	je     d45 <botlish_fn_14+0x11d>
     d3b:	mov    eax,0x2
     d40:	jmp    d4a <botlish_fn_14+0x122>
     d45:	mov    eax,0x6
     d4a:	cmp    rax,0x6
     d4e:	je     db7 <botlish_fn_14+0x18f>
     d54:	mov    rdx,rbx
     d57:	mov    rsi,r13
     d5a:	mov    rdi,r14
     d5d:	mov    rsi,r13
     d60:	mov    rdi,r14
     d63:	mov    rcx,r12
     d66:	call   d6b <botlish_fn_14+0x143>
			d67: R_X86_64_PLT32	rt_substr-0x4
     d6b:	test   rax,rax
     d6e:	jne    d97 <botlish_fn_14+0x16f>
     d74:	xor    rdx,rdx
     d77:	mov    rax,rdx
     d7a:	mov    rbx,QWORD PTR [rsp+0x20]
     d7f:	mov    r12,QWORD PTR [rsp+0x28]
     d84:	mov    r13,QWORD PTR [rsp+0x30]
     d89:	mov    r14,QWORD PTR [rsp+0x38]
     d8e:	add    rsp,0x40
     d92:	mov    rsp,rbp
     d95:	pop    rbp
     d96:	ret
     d97:	mov    rdx,r12
     d9a:	mov    rbx,QWORD PTR [rsp+0x20]
     d9f:	mov    r12,QWORD PTR [rsp+0x28]
     da4:	mov    r13,QWORD PTR [rsp+0x30]
     da9:	mov    r14,QWORD PTR [rsp+0x38]
     dae:	add    rsp,0x40
     db2:	mov    rsp,rbp
     db5:	pop    rbp
     db6:	ret
     db7:	mov    QWORD PTR [rsp+0x18],0x3
     dc0:	mov    rdx,r12
     dc3:	test   rdx,0x1
     dca:	je     ded <botlish_fn_14+0x1c5>
     dd0:	mov    rdx,r12
     dd3:	mov    rax,rdx
     dd6:	add    rax,0x2
     dda:	seto   cl
     ddd:	test   cl,cl
     ddf:	jne    ded <botlish_fn_14+0x1c5>
     de5:	mov    rsi,r13
     de8:	jmp    e00 <botlish_fn_14+0x1d8>
     ded:	mov    edx,0x3
     df2:	mov    rsi,r12
     df5:	mov    rdi,r14
     df8:	call   dfd <botlish_fn_14+0x1d5>
			df9: R_X86_64_PLT32	rt_int_add-0x4
     dfd:	mov    rsi,r13
     e00:	mov    rsi,r13
     e03:	mov    QWORD PTR [rsp],rsi
     e07:	mov    rdx,rbx
     e0a:	mov    QWORD PTR [rsp+0x8],rdx
     e0f:	mov    QWORD PTR [rsp+0x10],rax
     e14:	mov    r12,rax
     e17:	jmp    c67 <botlish_fn_14+0x3f>
     e1c:	add    BYTE PTR [rax],al
     e1e:	add    BYTE PTR [rax],al
     e20:	(bad)
     e21:	add    BYTE PTR [rax],al
     e23:	add    BYTE PTR [rax],al
     e25:	add    BYTE PTR [rax],al
	...

0000000000000e28 <botlish_entry_14: scan_unquoted<str, int, int>>:
     e28:	push   rbp
     e29:	mov    rbp,rsp
     e2c:	ud2

0000000000000e2e <botlish_fn_15: scan_quoted<str, int, str>>:
     e2e:	push   rbp
     e2f:	mov    rbp,rsp
     e32:	sub    rsp,0xb0
     e39:	mov    QWORD PTR [rsp+0x80],rbx
     e41:	mov    QWORD PTR [rsp+0x88],r12
     e49:	mov    QWORD PTR [rsp+0x90],r13
     e51:	mov    QWORD PTR [rsp+0x98],r14
     e59:	mov    QWORD PTR [rsp+0xa0],r15
     e61:	mov    r15,rdi
     e64:	mov    QWORD PTR [rsp+0x18],0x0
     e6d:	mov    QWORD PTR [rsp+0x20],0x0
     e76:	mov    QWORD PTR [rsp],rsi
     e7a:	mov    QWORD PTR [rsp+0x8],rdx
     e7f:	mov    QWORD PTR [rsp+0x10],rcx
     e84:	mov    r13,rcx
     e87:	lea    r12,[rsp+0x58]
     e8c:	mov    rbx,rsi
     e8f:	mov    QWORD PTR [rsp+0x78],rdx
     e94:	mov    rdx,QWORD PTR [rsp+0x78]
     e99:	mov    rsi,rbx
     e9c:	mov    rdi,r15
     e9f:	call   ea4 <botlish_fn_15+0x76>
			ea0: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     ea4:	test   rax,rax
     ea7:	je     1143 <botlish_fn_15+0x315>
     ead:	mov    QWORD PTR [rsp+0x18],rax
     eb2:	mov    r14,rax
     eb5:	mov    rdx,QWORD PTR [rsp+0x78]
     eba:	mov    rsi,rbx
     ebd:	mov    rdi,r15
     ec0:	call   ec5 <botlish_fn_15+0x97>
			ec1: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     ec5:	test   rax,rax
     ec8:	je     1143 <botlish_fn_15+0x315>
     ece:	cmp    rax,0x6
     ed2:	je     f8b <botlish_fn_15+0x15d>
     ed8:	mov    QWORD PTR [rsp+0x20],0x3
     ee1:	mov    rsi,QWORD PTR [rsp+0x78]
     ee6:	test   rsi,0x1
     eed:	je     f17 <botlish_fn_15+0xe9>
     ef3:	mov    rsi,QWORD PTR [rsp+0x78]
     ef8:	mov    rcx,rsi
     efb:	add    rcx,0x2
     eff:	seto   dl
     f02:	test   dl,dl
     f04:	jne    f17 <botlish_fn_15+0xe9>
     f0a:	mov    rsi,rcx
     f0d:	mov    QWORD PTR [rsp+0x78],rcx
     f12:	jmp    f31 <botlish_fn_15+0x103>
     f17:	mov    edx,0x3
     f1c:	mov    rsi,QWORD PTR [rsp+0x78]
     f21:	mov    rdi,r15
     f24:	call   f29 <botlish_fn_15+0xfb>
			f25: R_X86_64_PLT32	rt_int_add-0x4
     f29:	mov    rsi,rax
     f2c:	mov    QWORD PTR [rsp+0x78],rax
     f31:	mov    QWORD PTR [rsp+0x8],rsi
     f36:	mov    QWORD PTR [rsp+0x58],0x0
     f3f:	mov    QWORD PTR [rsp+0x60],r13
     f44:	mov    QWORD PTR [rsp+0x68],0x0
     f4d:	mov    QWORD PTR [rsp+0x70],r14
     f52:	mov    esi,0x2
     f57:	mov    edx,0x4
     f5c:	mov    rcx,r12
     f5f:	mov    rdi,r15
     f62:	call   f67 <botlish_fn_15+0x139>
			f63: R_X86_64_PLT32	rt_construct-0x4
     f67:	test   rax,rax
     f6a:	je     1143 <botlish_fn_15+0x315>
     f70:	mov    QWORD PTR [rsp],rbx
     f74:	mov    rsi,QWORD PTR [rsp+0x78]
     f79:	mov    QWORD PTR [rsp+0x8],rsi
     f7e:	mov    QWORD PTR [rsp+0x10],rax
     f83:	mov    r13,rax
     f86:	jmp    e94 <botlish_fn_15+0x66>
     f8b:	mov    QWORD PTR [rsp+0x20],0x3
     f94:	mov    rsi,QWORD PTR [rsp+0x78]
     f99:	test   rsi,0x1
     fa0:	je     fbd <botlish_fn_15+0x18f>
     fa6:	mov    rsi,QWORD PTR [rsp+0x78]
     fab:	mov    rdx,rsi
     fae:	add    rdx,0x2
     fb2:	seto   al
     fb5:	test   al,al
     fb7:	je     fd2 <botlish_fn_15+0x1a4>
     fbd:	mov    edx,0x3
     fc2:	mov    rsi,QWORD PTR [rsp+0x78]
     fc7:	mov    rdi,r15
     fca:	call   fcf <botlish_fn_15+0x1a1>
			fcb: R_X86_64_PLT32	rt_int_add-0x4
     fcf:	mov    rdx,rax
     fd2:	mov    rsi,rbx
     fd5:	mov    rdi,r15
     fd8:	call   fdd <botlish_fn_15+0x1af>
			fd9: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     fdd:	test   rax,rax
     fe0:	je     1143 <botlish_fn_15+0x315>
     fe6:	cmp    rax,0x6
     fea:	je     10a9 <botlish_fn_15+0x27b>
     ff0:	xor    rsi,rsi
     ff3:	lea    rcx,[rsp+0x48]
     ff8:	mov    QWORD PTR [rsp+0x48],0x0
    1001:	mov    QWORD PTR [rsp+0x50],r13
    1006:	mov    edx,0x2
    100b:	mov    rdi,r15
    100e:	call   1013 <botlish_fn_15+0x1e5>
			100f: R_X86_64_PLT32	rt_construct-0x4
    1013:	test   rax,rax
    1016:	je     1143 <botlish_fn_15+0x315>
    101c:	mov    QWORD PTR [rsp],rax
    1020:	mov    r12,rax
    1023:	mov    QWORD PTR [rsp+0x10],0x3
    102c:	mov    rsi,QWORD PTR [rsp+0x78]
    1031:	test   rsi,0x1
    1038:	je     105d <botlish_fn_15+0x22f>
    103e:	mov    rsi,QWORD PTR [rsp+0x78]
    1043:	mov    rdx,rsi
    1046:	add    rdx,0x2
    104a:	seto   al
    104d:	test   al,al
    104f:	jne    105d <botlish_fn_15+0x22f>
    1055:	mov    rax,r12
    1058:	jmp    1075 <botlish_fn_15+0x247>
    105d:	mov    edx,0x3
    1062:	mov    rsi,QWORD PTR [rsp+0x78]
    1067:	mov    rdi,r15
    106a:	call   106f <botlish_fn_15+0x241>
			106b: R_X86_64_PLT32	rt_int_add-0x4
    106f:	mov    rdx,rax
    1072:	mov    rax,r12
    1075:	mov    rbx,QWORD PTR [rsp+0x80]
    107d:	mov    r12,QWORD PTR [rsp+0x88]
    1085:	mov    r13,QWORD PTR [rsp+0x90]
    108d:	mov    r14,QWORD PTR [rsp+0x98]
    1095:	mov    r15,QWORD PTR [rsp+0xa0]
    109d:	add    rsp,0xb0
    10a4:	mov    rsp,rbp
    10a7:	pop    rbp
    10a8:	ret
    10a9:	mov    QWORD PTR [rsp+0x20],0x5
    10b2:	mov    rsi,QWORD PTR [rsp+0x78]
    10b7:	test   rsi,0x1
    10be:	je     10e8 <botlish_fn_15+0x2ba>
    10c4:	mov    rsi,QWORD PTR [rsp+0x78]
    10c9:	mov    rcx,rsi
    10cc:	add    rcx,0x4
    10d0:	seto   al
    10d3:	test   al,al
    10d5:	jne    10e8 <botlish_fn_15+0x2ba>
    10db:	mov    rsi,rcx
    10de:	mov    QWORD PTR [rsp+0x78],rcx
    10e3:	jmp    1102 <botlish_fn_15+0x2d4>
    10e8:	mov    edx,0x5
    10ed:	mov    rsi,QWORD PTR [rsp+0x78]
    10f2:	mov    rdi,r15
    10f5:	call   10fa <botlish_fn_15+0x2cc>
			10f6: R_X86_64_PLT32	rt_int_add-0x4
    10fa:	mov    rsi,rax
    10fd:	mov    QWORD PTR [rsp+0x78],rax
    1102:	mov    QWORD PTR [rsp+0x8],rsi
    1107:	lea    rcx,[rsp+0x28]
    110c:	mov    QWORD PTR [rsp+0x28],0x0
    1115:	mov    QWORD PTR [rsp+0x30],r13
    111a:	mov    QWORD PTR [rsp+0x38],0x0
    1123:	mov    QWORD PTR [rsp+0x40],r14
    1128:	mov    esi,0x2
    112d:	mov    edx,0x4
    1132:	mov    rdi,r15
    1135:	call   113a <botlish_fn_15+0x30c>
			1136: R_X86_64_PLT32	rt_construct-0x4
    113a:	test   rax,rax
    113d:	jne    117d <botlish_fn_15+0x34f>
    1143:	xor    rdx,rdx
    1146:	mov    rax,rdx
    1149:	mov    rbx,QWORD PTR [rsp+0x80]
    1151:	mov    r12,QWORD PTR [rsp+0x88]
    1159:	mov    r13,QWORD PTR [rsp+0x90]
    1161:	mov    r14,QWORD PTR [rsp+0x98]
    1169:	mov    r15,QWORD PTR [rsp+0xa0]
    1171:	add    rsp,0xb0
    1178:	mov    rsp,rbp
    117b:	pop    rbp
    117c:	ret
    117d:	mov    QWORD PTR [rsp],rbx
    1181:	mov    rsi,QWORD PTR [rsp+0x78]
    1186:	mov    QWORD PTR [rsp+0x8],rsi
    118b:	mov    QWORD PTR [rsp+0x10],rax
    1190:	mov    r13,rax
    1193:	jmp    e94 <botlish_fn_15+0x66>

0000000000001198 <botlish_entry_15: scan_quoted<str, int, str>>:
    1198:	push   rbp
    1199:	mov    rbp,rsp
    119c:	ud2

000000000000119e <botlish_fn_16: scan_field<str, int>>:
    119e:	push   rbp
    119f:	mov    rbp,rsp
    11a2:	sub    rsp,0x40
    11a6:	mov    QWORD PTR [rsp+0x20],rbx
    11ab:	mov    QWORD PTR [rsp+0x28],r12
    11b0:	mov    QWORD PTR [rsp+0x30],r13
    11b5:	mov    r12,rdi
    11b8:	mov    r13,rdx
    11bb:	mov    QWORD PTR [rsp+0x10],0x0
    11c4:	mov    QWORD PTR [rsp],rsi
    11c8:	mov    rbx,rsi
    11cb:	mov    QWORD PTR [rsp+0x8],rdx
    11d0:	mov    rdx,r13
    11d3:	mov    rsi,rbx
    11d6:	mov    rdi,r12
    11d9:	call   11de <botlish_fn_16+0x40>
			11da: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
    11de:	test   rax,rax
    11e1:	je     1291 <botlish_fn_16+0xf3>
    11e7:	cmp    rax,0x6
    11eb:	je     1223 <botlish_fn_16+0x85>
    11f1:	mov    rcx,r13
    11f4:	mov    rsi,rbx
    11f7:	mov    rdi,r12
    11fa:	mov    rdx,rcx
    11fd:	call   1202 <botlish_fn_16+0x64>
			11fe: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_unquoted<str, int, int>
    1202:	test   rax,rax
    1205:	je     1291 <botlish_fn_16+0xf3>
    120b:	mov    rbx,QWORD PTR [rsp+0x20]
    1210:	mov    r12,QWORD PTR [rsp+0x28]
    1215:	mov    r13,QWORD PTR [rsp+0x30]
    121a:	add    rsp,0x40
    121e:	mov    rsp,rbp
    1221:	pop    rbp
    1222:	ret
    1223:	mov    rcx,r13
    1226:	mov    QWORD PTR [rsp+0x10],0x3
    122f:	test   rcx,0x1
    1236:	jne    1244 <botlish_fn_16+0xa6>
    123c:	mov    r13,rcx
    123f:	jmp    1259 <botlish_fn_16+0xbb>
    1244:	mov    rdx,rcx
    1247:	add    rdx,0x2
    124b:	mov    r13,rcx
    124e:	seto   al
    1251:	test   al,al
    1253:	je     126c <botlish_fn_16+0xce>
    1259:	mov    edx,0x3
    125e:	mov    rsi,r13
    1261:	mov    rdi,r12
    1264:	call   1269 <botlish_fn_16+0xcb>
			1265: R_X86_64_PLT32	rt_int_add-0x4
    1269:	mov    rdx,rax
    126c:	mov    QWORD PTR [rsp+0x8],rdx
    1271:	mov    rdi,r12
    1274:	mov    rax,QWORD PTR [rdi+0x10]
    1278:	mov    rcx,QWORD PTR [rax]
    127b:	mov    QWORD PTR [rsp+0x10],rcx
    1280:	mov    rsi,rbx
    1283:	call   1288 <botlish_fn_16+0xea>
			1284: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_quoted<str, int, str>
    1288:	test   rax,rax
    128b:	jne    12af <botlish_fn_16+0x111>
    1291:	xor    rdx,rdx
    1294:	mov    rax,rdx
    1297:	mov    rbx,QWORD PTR [rsp+0x20]
    129c:	mov    r12,QWORD PTR [rsp+0x28]
    12a1:	mov    r13,QWORD PTR [rsp+0x30]
    12a6:	add    rsp,0x40
    12aa:	mov    rsp,rbp
    12ad:	pop    rbp
    12ae:	ret
    12af:	mov    rbx,QWORD PTR [rsp+0x20]
    12b4:	mov    r12,QWORD PTR [rsp+0x28]
    12b9:	mov    r13,QWORD PTR [rsp+0x30]
    12be:	add    rsp,0x40
    12c2:	mov    rsp,rbp
    12c5:	pop    rbp
    12c6:	ret

00000000000012c7 <botlish_entry_16: scan_field<str, int>>:
    12c7:	push   rbp
    12c8:	mov    rbp,rsp
    12cb:	ud2
    12cd:	add    BYTE PTR [rax],al
	...

00000000000012d0 <botlish_fn_17: scan_record_rest<str, int, mutarray, int>>:
    12d0:	push   rbp
    12d1:	mov    rbp,rsp
    12d4:	sub    rsp,0x60
    12d8:	mov    QWORD PTR [rsp+0x30],rbx
    12dd:	mov    QWORD PTR [rsp+0x38],r12
    12e2:	mov    QWORD PTR [rsp+0x40],r13
    12e7:	mov    QWORD PTR [rsp+0x48],r14
    12ec:	mov    QWORD PTR [rsp+0x50],r15
    12f1:	mov    r13,rdi
    12f4:	mov    QWORD PTR [rsp+0x20],0x0
    12fd:	mov    QWORD PTR [rsp],rsi
    1301:	mov    QWORD PTR [rsp+0x8],rdx
    1306:	mov    QWORD PTR [rsp+0x10],rcx
    130b:	mov    QWORD PTR [rsp+0x18],r8
    1310:	mov    rbx,rsi
    1313:	mov    r12,rdx
    1316:	mov    r14,r8
    1319:	mov    r15,rcx
    131c:	mov    rdx,QWORD PTR [rbx+0x8]
    1320:	shl    rdx,1
    1323:	or     rdx,0x1
    1327:	mov    rax,r12
    132a:	and    rax,rdx
    132d:	test   rax,0x1
    1333:	jne    1359 <botlish_fn_17+0x89>
    1339:	mov    rsi,r12
    133c:	mov    rdi,r13
    133f:	call   1344 <botlish_fn_17+0x74>
			1340: R_X86_64_PLT32	rt_int_cmp-0x4
    1344:	mov    ecx,0x2
    1349:	test   rax,rax
    134c:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 15a0 <botlish_fn_17+0x2d0>
    1354:	jmp    136c <botlish_fn_17+0x9c>
    1359:	mov    ecx,0x2
    135e:	mov    rax,r12
    1361:	cmp    rax,rdx
    1364:	cmovl  rcx,QWORD PTR [rip+0x234]        # 15a0 <botlish_fn_17+0x2d0>
    136c:	cmp    rcx,0x6
    1370:	je     1384 <botlish_fn_17+0xb4>
    1376:	mov    rdx,r14
    1379:	mov    rsi,r15
    137c:	mov    rdi,r13
    137f:	jmp    13ba <botlish_fn_17+0xea>
    1384:	mov    rdx,r12
    1387:	mov    rsi,rbx
    138a:	mov    rdi,r13
    138d:	call   1392 <botlish_fn_17+0xc2>
			138e: R_X86_64_PLT32	rt_str_char_at-0x4
    1392:	test   rax,rax
    1395:	je     14fa <botlish_fn_17+0x22a>
    139b:	cmp    rax,0x164
    13a1:	je     1479 <botlish_fn_17+0x1a9>
    13a7:	cmp    rax,0x54
    13ab:	je     13f0 <botlish_fn_17+0x120>
    13b1:	mov    rdx,r14
    13b4:	mov    rsi,r15
    13b7:	mov    rdi,r13
    13ba:	mov    rdi,r13
    13bd:	call   13c2 <botlish_fn_17+0xf2>
			13be: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    13c2:	test   rax,rax
    13c5:	je     14fa <botlish_fn_17+0x22a>
    13cb:	mov    rdx,r12
    13ce:	mov    rbx,QWORD PTR [rsp+0x30]
    13d3:	mov    r12,QWORD PTR [rsp+0x38]
    13d8:	mov    r13,QWORD PTR [rsp+0x40]
    13dd:	mov    r14,QWORD PTR [rsp+0x48]
    13e2:	mov    r15,QWORD PTR [rsp+0x50]
    13e7:	add    rsp,0x60
    13eb:	mov    rsp,rbp
    13ee:	pop    rbp
    13ef:	ret
    13f0:	mov    rdx,r14
    13f3:	mov    rsi,r15
    13f6:	mov    rdi,r13
    13f9:	call   13fe <botlish_fn_17+0x12e>
			13fa: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    13fe:	test   rax,rax
    1401:	je     14fa <botlish_fn_17+0x22a>
    1407:	mov    QWORD PTR [rsp],rax
    140b:	mov    r14,rax
    140e:	mov    QWORD PTR [rsp+0x10],0x3
    1417:	mov    rdx,r12
    141a:	test   rdx,0x1
    1421:	je     1441 <botlish_fn_17+0x171>
    1427:	mov    rdx,r12
    142a:	add    rdx,0x2
    142e:	seto   al
    1431:	test   al,al
    1433:	jne    1441 <botlish_fn_17+0x171>
    1439:	mov    rax,r14
    143c:	jmp    1457 <botlish_fn_17+0x187>
    1441:	mov    edx,0x3
    1446:	mov    rsi,r12
    1449:	mov    rdi,r13
    144c:	call   1451 <botlish_fn_17+0x181>
			144d: R_X86_64_PLT32	rt_int_add-0x4
    1451:	mov    rdx,rax
    1454:	mov    rax,r14
    1457:	mov    rbx,QWORD PTR [rsp+0x30]
    145c:	mov    r12,QWORD PTR [rsp+0x38]
    1461:	mov    r13,QWORD PTR [rsp+0x40]
    1466:	mov    r14,QWORD PTR [rsp+0x48]
    146b:	mov    r15,QWORD PTR [rsp+0x50]
    1470:	add    rsp,0x60
    1474:	mov    rsp,rbp
    1477:	pop    rbp
    1478:	ret
    1479:	mov    rsi,r12
    147c:	mov    edx,0x3
    1481:	mov    r12,rdx
    1484:	mov    QWORD PTR [rsp+0x20],0x3
    148d:	test   rsi,0x1
    1494:	je     14ac <botlish_fn_17+0x1dc>
    149a:	mov    rdx,rsi
    149d:	add    rdx,0x2
    14a1:	seto   al
    14a4:	test   al,al
    14a6:	je     14ba <botlish_fn_17+0x1ea>
    14ac:	mov    rdx,r12
    14af:	mov    rdi,r13
    14b2:	call   14b7 <botlish_fn_17+0x1e7>
			14b3: R_X86_64_PLT32	rt_int_add-0x4
    14b7:	mov    rdx,rax
    14ba:	mov    QWORD PTR [rsp+0x8],rdx
    14bf:	mov    rsi,rbx
    14c2:	mov    rdi,r13
    14c5:	call   14ca <botlish_fn_17+0x1fa>
			14c6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    14ca:	test   rax,rax
    14cd:	je     14fa <botlish_fn_17+0x22a>
    14d3:	mov    QWORD PTR [rsp+0x8],rax
    14d8:	mov    rcx,rax
    14db:	mov    QWORD PTR [rsp+0x20],rdx
    14e0:	mov    rsi,r15
    14e3:	mov    r15,rdx
    14e6:	mov    rdx,r14
    14e9:	mov    rdi,r13
    14ec:	call   14f1 <botlish_fn_17+0x221>
			14ed: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    14f1:	test   rax,rax
    14f4:	jne    1522 <botlish_fn_17+0x252>
    14fa:	xor    rdx,rdx
    14fd:	mov    rax,rdx
    1500:	mov    rbx,QWORD PTR [rsp+0x30]
    1505:	mov    r12,QWORD PTR [rsp+0x38]
    150a:	mov    r13,QWORD PTR [rsp+0x40]
    150f:	mov    r14,QWORD PTR [rsp+0x48]
    1514:	mov    r15,QWORD PTR [rsp+0x50]
    1519:	add    rsp,0x60
    151d:	mov    rsp,rbp
    1520:	pop    rbp
    1521:	ret
    1522:	mov    QWORD PTR [rsp+0x8],rax
    1527:	mov    QWORD PTR [rsp+0x28],rax
    152c:	mov    QWORD PTR [rsp+0x10],0x3
    1535:	mov    rdx,r14
    1538:	test   rdx,0x1
    153f:	jne    1550 <botlish_fn_17+0x280>
    1545:	mov    rdx,r12
    1548:	mov    rsi,r14
    154b:	jmp    156b <botlish_fn_17+0x29b>
    1550:	mov    rdx,r14
    1553:	mov    rax,rdx
    1556:	add    rax,0x2
    155a:	seto   cl
    155d:	test   cl,cl
    155f:	je     1573 <botlish_fn_17+0x2a3>
    1565:	mov    rdx,r12
    1568:	mov    rsi,r14
    156b:	mov    rdi,r13
    156e:	call   1573 <botlish_fn_17+0x2a3>
			156f: R_X86_64_PLT32	rt_int_add-0x4
    1573:	mov    QWORD PTR [rsp],rbx
    1577:	mov    rdx,r15
    157a:	mov    QWORD PTR [rsp+0x8],rdx
    157f:	mov    rcx,QWORD PTR [rsp+0x28]
    1584:	mov    QWORD PTR [rsp+0x10],rcx
    1589:	mov    QWORD PTR [rsp+0x18],rax
    158e:	mov    r12,rdx
    1591:	mov    r14,rax
    1594:	mov    r15,rcx
    1597:	jmp    131c <botlish_fn_17+0x4c>
    159c:	add    BYTE PTR [rax],al
    159e:	add    BYTE PTR [rax],al
    15a0:	(bad)
    15a1:	add    BYTE PTR [rax],al
    15a3:	add    BYTE PTR [rax],al
    15a5:	add    BYTE PTR [rax],al
	...

00000000000015a8 <botlish_entry_17: scan_record_rest<str, int, mutarray, int>>:
    15a8:	push   rbp
    15a9:	mov    rbp,rsp
    15ac:	ud2

00000000000015ae <botlish_fn_18: scan_record<str, int>>:
    15ae:	push   rbp
    15af:	mov    rbp,rsp
    15b2:	sub    rsp,0x40
    15b6:	mov    QWORD PTR [rsp+0x20],rbx
    15bb:	mov    QWORD PTR [rsp+0x28],r12
    15c0:	mov    QWORD PTR [rsp+0x30],r14
    15c5:	mov    r14,rdi
    15c8:	mov    QWORD PTR [rsp+0x10],0x0
    15d1:	mov    QWORD PTR [rsp+0x18],0x0
    15da:	mov    QWORD PTR [rsp],rsi
    15de:	mov    r12,rsi
    15e1:	mov    QWORD PTR [rsp+0x8],rdx
    15e6:	mov    rsi,r12
    15e9:	mov    rdi,r14
    15ec:	call   15f1 <botlish_fn_18+0x43>
			15ed: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    15f1:	test   rax,rax
    15f4:	je     1649 <botlish_fn_18+0x9b>
    15fa:	mov    QWORD PTR [rsp+0x8],rax
    15ff:	mov    rsi,rax
    1602:	mov    QWORD PTR [rsp+0x10],rdx
    1607:	mov    rbx,rdx
    160a:	mov    rdi,r14
    160d:	call   1612 <botlish_fn_18+0x64>
			160e: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    1612:	test   rax,rax
    1615:	je     1649 <botlish_fn_18+0x9b>
    161b:	mov    QWORD PTR [rsp+0x8],rax
    1620:	mov    rcx,rax
    1623:	mov    r8d,0x3
    1629:	mov    QWORD PTR [rsp+0x18],0x3
    1632:	mov    rdx,rbx
    1635:	mov    rsi,r12
    1638:	mov    rdi,r14
    163b:	call   1640 <botlish_fn_18+0x92>
			163c: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record_rest<str, int, mutarray, int>
    1640:	test   rax,rax
    1643:	jne    1667 <botlish_fn_18+0xb9>
    1649:	xor    rdx,rdx
    164c:	mov    rax,rdx
    164f:	mov    rbx,QWORD PTR [rsp+0x20]
    1654:	mov    r12,QWORD PTR [rsp+0x28]
    1659:	mov    r14,QWORD PTR [rsp+0x30]
    165e:	add    rsp,0x40
    1662:	mov    rsp,rbp
    1665:	pop    rbp
    1666:	ret
    1667:	mov    rbx,QWORD PTR [rsp+0x20]
    166c:	mov    r12,QWORD PTR [rsp+0x28]
    1671:	mov    r14,QWORD PTR [rsp+0x30]
    1676:	add    rsp,0x40
    167a:	mov    rsp,rbp
    167d:	pop    rbp
    167e:	ret

000000000000167f <botlish_entry_18: scan_record<str, int>>:
    167f:	push   rbp
    1680:	mov    rbp,rsp
    1683:	ud2
    1685:	add    BYTE PTR [rax],al
	...

0000000000001688 <botlish_fn_19: scan_records<str, int, mutarray, int>>:
    1688:	push   rbp
    1689:	mov    rbp,rsp
    168c:	sub    rsp,0x60
    1690:	mov    QWORD PTR [rsp+0x30],rbx
    1695:	mov    QWORD PTR [rsp+0x38],r12
    169a:	mov    QWORD PTR [rsp+0x40],r13
    169f:	mov    QWORD PTR [rsp+0x48],r14
    16a4:	mov    QWORD PTR [rsp+0x50],r15
    16a9:	mov    r13,rdi
    16ac:	mov    QWORD PTR [rsp+0x20],0x0
    16b5:	mov    QWORD PTR [rsp],rsi
    16b9:	mov    QWORD PTR [rsp+0x8],rdx
    16be:	mov    rax,rdx
    16c1:	mov    QWORD PTR [rsp+0x10],rcx
    16c6:	mov    QWORD PTR [rsp+0x18],r8
    16cb:	mov    rbx,rsi
    16ce:	mov    r14,r8
    16d1:	mov    r15,rcx
    16d4:	mov    rdx,QWORD PTR [rbx+0x8]
    16d8:	shl    rdx,1
    16db:	or     rdx,0x1
    16df:	mov    r12,rax
    16e2:	and    rax,rdx
    16e5:	test   rax,0x1
    16eb:	jne    1711 <botlish_fn_19+0x89>
    16f1:	mov    rsi,r12
    16f4:	mov    rdi,r13
    16f7:	call   16fc <botlish_fn_19+0x74>
			16f8: R_X86_64_PLT32	rt_int_cmp-0x4
    16fc:	mov    ecx,0x2
    1701:	test   rax,rax
    1704:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1838 <botlish_fn_19+0x1b0>
    170c:	jmp    1721 <botlish_fn_19+0x99>
    1711:	mov    ecx,0x2
    1716:	cmp    r12,rdx
    1719:	cmovge rcx,QWORD PTR [rip+0x117]        # 1838 <botlish_fn_19+0x1b0>
    1721:	cmp    rcx,0x6
    1725:	je     17d3 <botlish_fn_19+0x14b>
    172b:	mov    rdx,r12
    172e:	mov    rsi,rbx
    1731:	mov    rdi,r13
    1734:	call   1739 <botlish_fn_19+0xb1>
			1735: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    1739:	test   rax,rax
    173c:	je     17ea <botlish_fn_19+0x162>
    1742:	mov    QWORD PTR [rsp+0x8],rax
    1747:	mov    rcx,rax
    174a:	mov    QWORD PTR [rsp+0x20],rdx
    174f:	mov    rsi,r15
    1752:	mov    r12,rdx
    1755:	mov    rdx,r14
    1758:	mov    rdi,r13
    175b:	call   1760 <botlish_fn_19+0xd8>
			175c: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1760:	test   rax,rax
    1763:	je     17ea <botlish_fn_19+0x162>
    1769:	mov    QWORD PTR [rsp+0x8],rax
    176e:	mov    r15,rax
    1771:	mov    QWORD PTR [rsp+0x10],0x3
    177a:	mov    rsi,r14
    177d:	test   rsi,0x1
    1784:	je     179f <botlish_fn_19+0x117>
    178a:	mov    rsi,r14
    178d:	mov    rax,rsi
    1790:	add    rax,0x2
    1794:	seto   cl
    1797:	test   cl,cl
    1799:	je     17af <botlish_fn_19+0x127>
    179f:	mov    edx,0x3
    17a4:	mov    rsi,r14
    17a7:	mov    rdi,r13
    17aa:	call   17af <botlish_fn_19+0x127>
			17ab: R_X86_64_PLT32	rt_int_add-0x4
    17af:	mov    QWORD PTR [rsp],rbx
    17b3:	mov    rdx,r12
    17b6:	mov    QWORD PTR [rsp+0x8],rdx
    17bb:	mov    rcx,r15
    17be:	mov    QWORD PTR [rsp+0x10],rcx
    17c3:	mov    QWORD PTR [rsp+0x18],rax
    17c8:	mov    r14,rax
    17cb:	mov    rax,rdx
    17ce:	jmp    16d4 <botlish_fn_19+0x4c>
    17d3:	mov    rdx,r14
    17d6:	mov    rsi,r15
    17d9:	mov    rdi,r13
    17dc:	call   17e1 <botlish_fn_19+0x159>
			17dd: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    17e1:	test   rax,rax
    17e4:	jne    180f <botlish_fn_19+0x187>
    17ea:	xor    rax,rax
    17ed:	mov    rbx,QWORD PTR [rsp+0x30]
    17f2:	mov    r12,QWORD PTR [rsp+0x38]
    17f7:	mov    r13,QWORD PTR [rsp+0x40]
    17fc:	mov    r14,QWORD PTR [rsp+0x48]
    1801:	mov    r15,QWORD PTR [rsp+0x50]
    1806:	add    rsp,0x60
    180a:	mov    rsp,rbp
    180d:	pop    rbp
    180e:	ret
    180f:	mov    rbx,QWORD PTR [rsp+0x30]
    1814:	mov    r12,QWORD PTR [rsp+0x38]
    1819:	mov    r13,QWORD PTR [rsp+0x40]
    181e:	mov    r14,QWORD PTR [rsp+0x48]
    1823:	mov    r15,QWORD PTR [rsp+0x50]
    1828:	add    rsp,0x60
    182c:	mov    rsp,rbp
    182f:	pop    rbp
    1830:	ret
    1831:	add    BYTE PTR [rax],al
    1833:	add    BYTE PTR [rax],al
    1835:	add    BYTE PTR [rax],al
    1837:	add    BYTE PTR [rsi],al
    1839:	add    BYTE PTR [rax],al
    183b:	add    BYTE PTR [rax],al
    183d:	add    BYTE PTR [rax],al
	...

0000000000001840 <botlish_entry_19: scan_records<str, int, mutarray, int>>:
    1840:	push   rbp
    1841:	mov    rbp,rsp
    1844:	mov    rsi,QWORD PTR [rdx]
    1847:	mov    r9,QWORD PTR [rdx+0x8]
    184b:	mov    rcx,QWORD PTR [rdx+0x10]
    184f:	mov    r8,QWORD PTR [rdx+0x18]
    1853:	mov    rdx,r9
    1856:	call   185b <botlish_entry_19+0x1b>
			1857: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    185b:	mov    rsp,rbp
    185e:	pop    rbp
    185f:	ret

0000000000001860 <botlish_fn_20: csv_parse<str>>:
    1860:	push   rbp
    1861:	mov    rbp,rsp
    1864:	sub    rsp,0x40
    1868:	mov    QWORD PTR [rsp+0x20],rbx
    186d:	mov    QWORD PTR [rsp+0x28],r12
    1872:	mov    QWORD PTR [rsp+0x30],r13
    1877:	mov    rbx,rdi
    187a:	mov    QWORD PTR [rsp+0x8],0x0
    1883:	mov    QWORD PTR [rsp+0x10],0x0
    188c:	mov    QWORD PTR [rsp+0x18],0x0
    1895:	mov    QWORD PTR [rsp],rsi
    1899:	mov    rax,QWORD PTR [rsi+0x8]
    189d:	mov    r12,rsi
    18a0:	shl    rax,1
    18a3:	or     rax,0x1
    18a7:	sar    rax,1
    18aa:	test   rax,rax
    18ad:	je     193c <botlish_fn_20+0xdc>
    18b3:	mov    edx,0x1
    18b8:	mov    QWORD PTR [rsp+0x8],0x1
    18c1:	mov    rsi,r12
    18c4:	mov    rdi,rbx
    18c7:	call   18cc <botlish_fn_20+0x6c>
			18c8: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    18cc:	test   rax,rax
    18cf:	je     1953 <botlish_fn_20+0xf3>
    18d5:	mov    QWORD PTR [rsp+0x8],rax
    18da:	mov    rsi,rax
    18dd:	mov    QWORD PTR [rsp+0x10],rdx
    18e2:	mov    r13,rdx
    18e5:	mov    rdi,rbx
    18e8:	call   18ed <botlish_fn_20+0x8d>
			18e9: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    18ed:	test   rax,rax
    18f0:	je     1953 <botlish_fn_20+0xf3>
    18f6:	mov    QWORD PTR [rsp+0x8],rax
    18fb:	mov    rcx,rax
    18fe:	mov    r8d,0x3
    1904:	mov    QWORD PTR [rsp+0x18],0x3
    190d:	mov    rdx,r13
    1910:	mov    rsi,r12
    1913:	mov    rdi,rbx
    1916:	call   191b <botlish_fn_20+0xbb>
			1917: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    191b:	test   rax,rax
    191e:	je     1953 <botlish_fn_20+0xf3>
    1924:	mov    rbx,QWORD PTR [rsp+0x20]
    1929:	mov    r12,QWORD PTR [rsp+0x28]
    192e:	mov    r13,QWORD PTR [rsp+0x30]
    1933:	add    rsp,0x40
    1937:	mov    rsp,rbp
    193a:	pop    rbp
    193b:	ret
    193c:	xor    rdx,rdx
    193f:	mov    rdi,rbx
    1942:	mov    rsi,rdx
    1945:	call   194a <botlish_fn_20+0xea>
			1946: R_X86_64_PLT32	rt_list_new-0x4
    194a:	test   rax,rax
    194d:	jne    196e <botlish_fn_20+0x10e>
    1953:	xor    rax,rax
    1956:	mov    rbx,QWORD PTR [rsp+0x20]
    195b:	mov    r12,QWORD PTR [rsp+0x28]
    1960:	mov    r13,QWORD PTR [rsp+0x30]
    1965:	add    rsp,0x40
    1969:	mov    rsp,rbp
    196c:	pop    rbp
    196d:	ret
    196e:	mov    rbx,QWORD PTR [rsp+0x20]
    1973:	mov    r12,QWORD PTR [rsp+0x28]
    1978:	mov    r13,QWORD PTR [rsp+0x30]
    197d:	add    rsp,0x40
    1981:	mov    rsp,rbp
    1984:	pop    rbp
    1985:	ret

0000000000001986 <botlish_entry_20: csv_parse<str>>:
    1986:	push   rbp
    1987:	mov    rbp,rsp
    198a:	mov    rsi,QWORD PTR [rdx]
    198d:	call   1992 <botlish_entry_20+0xc>
			198e: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    1992:	mov    rsp,rbp
    1995:	pop    rbp
    1996:	ret

0000000000001997 <botlish_fn_21: ht_alloc<int>>:
    1997:	push   rbp
    1998:	mov    rbp,rsp
    199b:	sub    rsp,0x70
    199f:	mov    QWORD PTR [rsp+0x40],rbx
    19a4:	mov    QWORD PTR [rsp+0x48],r12
    19a9:	mov    QWORD PTR [rsp+0x50],r13
    19ae:	mov    QWORD PTR [rsp+0x58],r14
    19b3:	mov    QWORD PTR [rsp+0x60],r15
    19b8:	mov    r12,rdi
    19bb:	mov    QWORD PTR [rsp+0x10],0x0
    19c4:	mov    QWORD PTR [rsp+0x18],0x0
    19cd:	mov    QWORD PTR [rsp],rsi
    19d1:	mov    r13,rsi
    19d4:	mov    esi,0x5
    19d9:	mov    QWORD PTR [rsp+0x8],0x5
    19e2:	mov    rdi,r12
    19e5:	call   19ea <botlish_fn_21+0x53>
			19e6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    19ea:	mov    rcx,rax
    19ed:	mov    r14,rax
    19f0:	test   rax,rcx
    19f3:	je     1a82 <botlish_fn_21+0xeb>
    19f9:	mov    rax,r14
    19fc:	mov    QWORD PTR [rsp+0x8],rax
    1a01:	mov    ebx,0x1
    1a06:	mov    rcx,rbx
    1a09:	mov    rdx,rbx
    1a0c:	mov    rsi,r14
    1a0f:	mov    rdi,r12
    1a12:	call   1a17 <botlish_fn_21+0x80>
			1a13: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1a17:	mov    edx,0x3
    1a1c:	mov    rcx,rbx
    1a1f:	mov    rsi,r14
    1a22:	mov    rdi,r12
    1a25:	call   1a2a <botlish_fn_21+0x93>
			1a26: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1a2a:	mov    QWORD PTR [rsp+0x10],0x1
    1a33:	mov    rdx,rbx
    1a36:	mov    rsi,r13
    1a39:	mov    rdi,r12
    1a3c:	call   1a41 <botlish_fn_21+0xaa>
			1a3d: R_X86_64_PLT32	rt_mutarray_create-0x4
    1a41:	test   rax,rax
    1a44:	je     1a82 <botlish_fn_21+0xeb>
    1a4a:	mov    QWORD PTR [rsp+0x10],rax
    1a4f:	mov    rbx,rax
    1a52:	mov    rsi,r13
    1a55:	mov    rdi,r12
    1a58:	call   1a5d <botlish_fn_21+0xc6>
			1a59: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a5d:	test   rax,rax
    1a60:	je     1a82 <botlish_fn_21+0xeb>
    1a66:	mov    QWORD PTR [rsp+0x18],rax
    1a6b:	mov    rsi,r13
    1a6e:	mov    r15,rax
    1a71:	mov    rdi,r12
    1a74:	call   1a79 <botlish_fn_21+0xe2>
			1a75: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a79:	test   rax,rax
    1a7c:	jne    1aa7 <botlish_fn_21+0x110>
    1a82:	xor    rax,rax
    1a85:	mov    rbx,QWORD PTR [rsp+0x40]
    1a8a:	mov    r12,QWORD PTR [rsp+0x48]
    1a8f:	mov    r13,QWORD PTR [rsp+0x50]
    1a94:	mov    r14,QWORD PTR [rsp+0x58]
    1a99:	mov    r15,QWORD PTR [rsp+0x60]
    1a9e:	add    rsp,0x70
    1aa2:	mov    rsp,rbp
    1aa5:	pop    rbp
    1aa6:	ret
    1aa7:	mov    QWORD PTR [rsp],rax
    1aab:	lea    rcx,[rsp+0x20]
    1ab0:	mov    rdx,rbx
    1ab3:	mov    QWORD PTR [rsp+0x20],rdx
    1ab8:	mov    rsi,r15
    1abb:	mov    QWORD PTR [rsp+0x28],rsi
    1ac0:	mov    QWORD PTR [rsp+0x30],rax
    1ac5:	mov    rax,r14
    1ac8:	mov    QWORD PTR [rsp+0x38],rax
    1acd:	xor    rsi,rsi
    1ad0:	mov    edx,0x4
    1ad5:	mov    rdi,r12
    1ad8:	call   1add <botlish_fn_21+0x146>
			1ad9: R_X86_64_PLT32	rt_struct_new-0x4
    1add:	mov    rbx,QWORD PTR [rsp+0x40]
    1ae2:	mov    r12,QWORD PTR [rsp+0x48]
    1ae7:	mov    r13,QWORD PTR [rsp+0x50]
    1aec:	mov    r14,QWORD PTR [rsp+0x58]
    1af1:	mov    r15,QWORD PTR [rsp+0x60]
    1af6:	add    rsp,0x70
    1afa:	mov    rsp,rbp
    1afd:	pop    rbp
    1afe:	ret

0000000000001aff <botlish_entry_21: ht_alloc<int>>:
    1aff:	push   rbp
    1b00:	mov    rbp,rsp
    1b03:	mov    rsi,QWORD PTR [rdx]
    1b06:	call   1b0b <botlish_entry_21+0xc>
			1b07: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1b0b:	mov    rsp,rbp
    1b0e:	pop    rbp
    1b0f:	ret

0000000000001b10 <botlish_fn_22: ht_alloc<int>>:
    1b10:	push   rbp
    1b11:	mov    rbp,rsp
    1b14:	sub    rsp,0x60
    1b18:	mov    QWORD PTR [rsp+0x30],rbx
    1b1d:	mov    QWORD PTR [rsp+0x38],r12
    1b22:	mov    QWORD PTR [rsp+0x40],r13
    1b27:	mov    QWORD PTR [rsp+0x48],r14
    1b2c:	mov    QWORD PTR [rsp+0x50],r15
    1b31:	mov    r13,rdi
    1b34:	mov    r15,rdx
    1b37:	mov    QWORD PTR [rsp+0x10],0x0
    1b40:	mov    QWORD PTR [rsp+0x18],0x0
    1b49:	mov    QWORD PTR [rsp],rsi
    1b4d:	mov    r12,rsi
    1b50:	mov    esi,0x5
    1b55:	mov    QWORD PTR [rsp+0x8],0x5
    1b5e:	mov    rdi,r13
    1b61:	call   1b66 <botlish_fn_22+0x56>
			1b62: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b66:	mov    rcx,rax
    1b69:	mov    r14,rax
    1b6c:	test   rax,rcx
    1b6f:	je     1c00 <botlish_fn_22+0xf0>
    1b75:	mov    rax,r14
    1b78:	mov    QWORD PTR [rsp+0x8],rax
    1b7d:	mov    ebx,0x1
    1b82:	mov    rcx,rbx
    1b85:	mov    rdx,rbx
    1b88:	mov    rsi,r14
    1b8b:	mov    rdi,r13
    1b8e:	call   1b93 <botlish_fn_22+0x83>
			1b8f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1b93:	mov    edx,0x3
    1b98:	mov    rcx,rbx
    1b9b:	mov    rsi,r14
    1b9e:	mov    rdi,r13
    1ba1:	call   1ba6 <botlish_fn_22+0x96>
			1ba2: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1ba6:	mov    QWORD PTR [rsp+0x10],0x1
    1baf:	mov    rdx,rbx
    1bb2:	mov    rsi,r12
    1bb5:	mov    rdi,r13
    1bb8:	call   1bbd <botlish_fn_22+0xad>
			1bb9: R_X86_64_PLT32	rt_mutarray_create-0x4
    1bbd:	test   rax,rax
    1bc0:	je     1c00 <botlish_fn_22+0xf0>
    1bc6:	mov    QWORD PTR [rsp+0x10],rax
    1bcb:	mov    rbx,rax
    1bce:	mov    rsi,r12
    1bd1:	mov    rdi,r13
    1bd4:	call   1bd9 <botlish_fn_22+0xc9>
			1bd5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1bd9:	test   rax,rax
    1bdc:	je     1c00 <botlish_fn_22+0xf0>
    1be2:	mov    QWORD PTR [rsp+0x18],rax
    1be7:	mov    rsi,r12
    1bea:	mov    rdi,r13
    1bed:	mov    QWORD PTR [rsp+0x20],rax
    1bf2:	call   1bf7 <botlish_fn_22+0xe7>
			1bf3: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1bf7:	test   rax,rax
    1bfa:	jne    1c25 <botlish_fn_22+0x115>
    1c00:	xor    rax,rax
    1c03:	mov    rbx,QWORD PTR [rsp+0x30]
    1c08:	mov    r12,QWORD PTR [rsp+0x38]
    1c0d:	mov    r13,QWORD PTR [rsp+0x40]
    1c12:	mov    r14,QWORD PTR [rsp+0x48]
    1c17:	mov    r15,QWORD PTR [rsp+0x50]
    1c1c:	add    rsp,0x60
    1c20:	mov    rsp,rbp
    1c23:	pop    rbp
    1c24:	ret
    1c25:	mov    rcx,QWORD PTR [rsp+0x20]
    1c2a:	mov    rdx,r15
    1c2d:	mov    QWORD PTR [rdx],rcx
    1c30:	mov    QWORD PTR [rdx+0x8],rax
    1c34:	mov    rax,r14
    1c37:	mov    QWORD PTR [rdx+0x10],rax
    1c3b:	mov    rax,rbx
    1c3e:	mov    rbx,QWORD PTR [rsp+0x30]
    1c43:	mov    r12,QWORD PTR [rsp+0x38]
    1c48:	mov    r13,QWORD PTR [rsp+0x40]
    1c4d:	mov    r14,QWORD PTR [rsp+0x48]
    1c52:	mov    r15,QWORD PTR [rsp+0x50]
    1c57:	add    rsp,0x60
    1c5b:	mov    rsp,rbp
    1c5e:	pop    rbp
    1c5f:	ret

0000000000001c60 <botlish_entry_22: ht_alloc<int>>:
    1c60:	push   rbp
    1c61:	mov    rbp,rsp
    1c64:	ud2

0000000000001c66 <botlish_fn_23: ht_new<generic>>:
    1c66:	push   rbp
    1c67:	mov    rbp,rsp
    1c6a:	sub    rsp,0x10
    1c6e:	mov    esi,0x11
    1c73:	mov    QWORD PTR [rsp],0x11
    1c7b:	call   1c80 <botlish_fn_23+0x1a>
			1c7c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1c80:	test   rax,rax
    1c83:	jne    1c95 <botlish_fn_23+0x2f>
    1c89:	xor    rax,rax
    1c8c:	add    rsp,0x10
    1c90:	mov    rsp,rbp
    1c93:	pop    rbp
    1c94:	ret
    1c95:	add    rsp,0x10
    1c99:	mov    rsp,rbp
    1c9c:	pop    rbp
    1c9d:	ret

0000000000001c9e <botlish_entry_23: ht_new<generic>>:
    1c9e:	push   rbp
    1c9f:	mov    rbp,rsp
    1ca2:	call   1ca7 <botlish_entry_23+0x9>
			1ca3: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    1ca7:	mov    rsp,rbp
    1caa:	pop    rbp
    1cab:	ret
    1cac:	add    BYTE PTR [rax],al
	...

0000000000001cb0 <botlish_fn_24: ht_capacity_for<int, int>>:
    1cb0:	push   rbp
    1cb1:	mov    rbp,rsp
    1cb4:	sub    rsp,0x50
    1cb8:	mov    QWORD PTR [rsp+0x20],rbx
    1cbd:	mov    QWORD PTR [rsp+0x28],r12
    1cc2:	mov    QWORD PTR [rsp+0x30],r13
    1cc7:	mov    QWORD PTR [rsp+0x38],r14
    1ccc:	mov    QWORD PTR [rsp+0x40],r15
    1cd1:	mov    r13,rdi
    1cd4:	mov    QWORD PTR [rsp],rdx
    1cd8:	mov    rbx,rsi
    1cdb:	or     rbx,0x1
    1cdf:	sar    rbx,1
    1ce2:	mov    r12,rsi
    1ce5:	mov    r14,rdx
    1ce8:	mov    rax,r12
    1ceb:	or     rax,0x1
    1cef:	mov    QWORD PTR [rsp+0x8],rax
    1cf4:	mov    QWORD PTR [rsp+0x10],0x7
    1cfd:	mov    rax,rbx
    1d00:	imul   QWORD PTR [rip+0x159]        # 1e60 <botlish_fn_24+0x1b0>
    1d07:	seto   cl
    1d0a:	or     rax,0x1
    1d0e:	test   cl,cl
    1d10:	jne    1d1e <botlish_fn_24+0x6e>
    1d16:	mov    rsi,rax
    1d19:	jmp    1d35 <botlish_fn_24+0x85>
    1d1e:	mov    rsi,r12
    1d21:	or     rsi,0x1
    1d25:	mov    edx,0x7
    1d2a:	mov    rdi,r13
    1d2d:	call   1d32 <botlish_fn_24+0x82>
			1d2e: R_X86_64_PLT32	rt_int_mul-0x4
    1d32:	mov    rsi,rax
    1d35:	mov    QWORD PTR [rsp+0x8],rsi
    1d3a:	mov    r15,rsi
    1d3d:	mov    QWORD PTR [rsp+0x10],0x5
    1d46:	mov    rsi,r14
    1d49:	test   rsi,0x1
    1d50:	je     1d80 <botlish_fn_24+0xd0>
    1d56:	mov    rsi,r14
    1d59:	mov    rax,rsi
    1d5c:	sar    rax,1
    1d5f:	imul   QWORD PTR [rip+0x102]        # 1e68 <botlish_fn_24+0x1b8>
    1d66:	seto   cl
    1d69:	or     rax,0x1
    1d6d:	test   cl,cl
    1d6f:	jne    1d80 <botlish_fn_24+0xd0>
    1d75:	mov    rdx,rax
    1d78:	mov    rsi,r15
    1d7b:	jmp    1d96 <botlish_fn_24+0xe6>
    1d80:	mov    edx,0x5
    1d85:	mov    rsi,r14
    1d88:	mov    rdi,r13
    1d8b:	call   1d90 <botlish_fn_24+0xe0>
			1d8c: R_X86_64_PLT32	rt_int_mul-0x4
    1d90:	mov    rdx,rax
    1d93:	mov    rsi,r15
    1d96:	mov    rax,rsi
    1d99:	and    rax,rdx
    1d9c:	test   rax,0x1
    1da2:	jne    1dc5 <botlish_fn_24+0x115>
    1da8:	mov    rdi,r13
    1dab:	call   1db0 <botlish_fn_24+0x100>
			1dac: R_X86_64_PLT32	rt_int_cmp-0x4
    1db0:	mov    ecx,0x2
    1db5:	test   rax,rax
    1db8:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1e60 <botlish_fn_24+0x1b0>
    1dc0:	jmp    1dd5 <botlish_fn_24+0x125>
    1dc5:	mov    ecx,0x2
    1dca:	cmp    rsi,rdx
    1dcd:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1e60 <botlish_fn_24+0x1b0>
    1dd5:	cmp    rcx,0x6
    1dd9:	je     1e35 <botlish_fn_24+0x185>
    1ddf:	mov    QWORD PTR [rsp+0x8],0x5
    1de8:	mov    rsi,r14
    1deb:	test   rsi,0x1
    1df2:	je     1e19 <botlish_fn_24+0x169>
    1df8:	mov    rsi,r14
    1dfb:	mov    rax,rsi
    1dfe:	sar    rax,1
    1e01:	imul   QWORD PTR [rip+0x60]        # 1e68 <botlish_fn_24+0x1b8>
    1e08:	seto   sil
    1e0c:	or     rax,0x1
    1e10:	test   sil,sil
    1e13:	je     1e29 <botlish_fn_24+0x179>
    1e19:	mov    edx,0x5
    1e1e:	mov    rsi,r14
    1e21:	mov    rdi,r13
    1e24:	call   1e29 <botlish_fn_24+0x179>
			1e25: R_X86_64_PLT32	rt_int_mul-0x4
    1e29:	mov    QWORD PTR [rsp],rax
    1e2d:	mov    r14,rax
    1e30:	jmp    1ce8 <botlish_fn_24+0x38>
    1e35:	mov    rax,r14
    1e38:	mov    rbx,QWORD PTR [rsp+0x20]
    1e3d:	mov    r12,QWORD PTR [rsp+0x28]
    1e42:	mov    r13,QWORD PTR [rsp+0x30]
    1e47:	mov    r14,QWORD PTR [rsp+0x38]
    1e4c:	mov    r15,QWORD PTR [rsp+0x40]
    1e51:	add    rsp,0x50
    1e55:	mov    rsp,rbp
    1e58:	pop    rbp
    1e59:	ret
    1e5a:	add    BYTE PTR [rax],al
    1e5c:	add    BYTE PTR [rax],al
    1e5e:	add    BYTE PTR [rax],al
    1e60:	(bad)
    1e61:	add    BYTE PTR [rax],al
    1e63:	add    BYTE PTR [rax],al
    1e65:	add    BYTE PTR [rax],al
    1e67:	add    BYTE PTR [rax+rax*1],al
    1e6a:	add    BYTE PTR [rax],al
    1e6c:	add    BYTE PTR [rax],al
	...

0000000000001e70 <botlish_entry_24: ht_capacity_for<int, int>>:
    1e70:	push   rbp
    1e71:	mov    rbp,rsp
    1e74:	mov    rsi,QWORD PTR [rdx]
    1e77:	mov    rdx,QWORD PTR [rdx+0x8]
    1e7b:	call   1e80 <botlish_entry_24+0x10>
			1e7c: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    1e80:	mov    rsp,rbp
    1e83:	pop    rbp
    1e84:	ret

0000000000001e85 <botlish_fn_25: ht_new_sized<int>>:
    1e85:	push   rbp
    1e86:	mov    rbp,rsp
    1e89:	sub    rsp,0x20
    1e8d:	mov    QWORD PTR [rsp+0x10],r12
    1e92:	mov    r12,rdi
    1e95:	mov    QWORD PTR [rsp],rsi
    1e99:	mov    edx,0x11
    1e9e:	mov    QWORD PTR [rsp+0x8],0x11
    1ea7:	mov    rdi,r12
    1eaa:	call   1eaf <botlish_fn_25+0x2a>
			1eab: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    1eaf:	mov    QWORD PTR [rsp],rax
    1eb3:	mov    rsi,rax
    1eb6:	mov    rdi,r12
    1eb9:	call   1ebe <botlish_fn_25+0x39>
			1eba: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1ebe:	test   rax,rax
    1ec1:	jne    1ed8 <botlish_fn_25+0x53>
    1ec7:	xor    rax,rax
    1eca:	mov    r12,QWORD PTR [rsp+0x10]
    1ecf:	add    rsp,0x20
    1ed3:	mov    rsp,rbp
    1ed6:	pop    rbp
    1ed7:	ret
    1ed8:	mov    r12,QWORD PTR [rsp+0x10]
    1edd:	add    rsp,0x20
    1ee1:	mov    rsp,rbp
    1ee4:	pop    rbp
    1ee5:	ret

0000000000001ee6 <botlish_entry_25: ht_new_sized<int>>:
    1ee6:	push   rbp
    1ee7:	mov    rbp,rsp
    1eea:	mov    rsi,QWORD PTR [rdx]
    1eed:	call   1ef2 <botlish_entry_25+0xc>
			1eee: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    1ef2:	mov    rsp,rbp
    1ef5:	pop    rbp
    1ef6:	ret

0000000000001ef7 <botlish_fn_26: ht_size<HashTable>>:
    1ef7:	push   rbp
    1ef8:	mov    rbp,rsp
    1efb:	mov    r9,QWORD PTR [rsi+0x18]
    1eff:	mov    rsi,QWORD PTR [r9+0x18]
    1f03:	mov    edx,0x1
    1f08:	call   1f0d <botlish_fn_26+0x16>
			1f09: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f0d:	test   rax,rax
    1f10:	jne    1f1e <botlish_fn_26+0x27>
    1f16:	xor    rax,rax
    1f19:	mov    rsp,rbp
    1f1c:	pop    rbp
    1f1d:	ret
    1f1e:	mov    rsp,rbp
    1f21:	pop    rbp
    1f22:	ret

0000000000001f23 <botlish_entry_26: ht_size<HashTable>>:
    1f23:	push   rbp
    1f24:	mov    rbp,rsp
    1f27:	mov    rsi,QWORD PTR [rdx]
    1f2a:	call   1f2f <botlish_entry_26+0xc>
			1f2b: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    1f2f:	mov    rsp,rbp
    1f32:	pop    rbp
    1f33:	ret

0000000000001f34 <botlish_fn_27: ht_tombstones<HashTable>>:
    1f34:	push   rbp
    1f35:	mov    rbp,rsp
    1f38:	mov    r9,QWORD PTR [rsi+0x18]
    1f3c:	mov    rsi,QWORD PTR [r9+0x18]
    1f40:	mov    edx,0x3
    1f45:	call   1f4a <botlish_fn_27+0x16>
			1f46: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f4a:	test   rax,rax
    1f4d:	jne    1f5b <botlish_fn_27+0x27>
    1f53:	xor    rax,rax
    1f56:	mov    rsp,rbp
    1f59:	pop    rbp
    1f5a:	ret
    1f5b:	mov    rsp,rbp
    1f5e:	pop    rbp
    1f5f:	ret

0000000000001f60 <botlish_entry_27: ht_tombstones<HashTable>>:
    1f60:	push   rbp
    1f61:	mov    rbp,rsp
    1f64:	mov    rsi,QWORD PTR [rdx]
    1f67:	call   1f6c <botlish_entry_27+0xc>
			1f68: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    1f6c:	mov    rsp,rbp
    1f6f:	pop    rbp
    1f70:	ret

0000000000001f71 <botlish_fn_28: ht_capacity<HashTable>>:
    1f71:	push   rbp
    1f72:	mov    rbp,rsp
    1f75:	mov    rsi,QWORD PTR [rsi+0x18]
    1f79:	mov    rsi,QWORD PTR [rsi]
    1f7c:	call   1f81 <botlish_fn_28+0x10>
			1f7d: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1f81:	mov    rsp,rbp
    1f84:	pop    rbp
    1f85:	ret

0000000000001f86 <botlish_entry_28: ht_capacity<HashTable>>:
    1f86:	push   rbp
    1f87:	mov    rbp,rsp
    1f8a:	mov    rsi,QWORD PTR [rdx]
    1f8d:	call   1f92 <botlish_entry_28+0xc>
			1f8e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    1f92:	mov    rsp,rbp
    1f95:	pop    rbp
    1f96:	ret

0000000000001f97 <botlish_fn_29: ht_probe_start<HashTable, str>>:
    1f97:	push   rbp
    1f98:	mov    rbp,rsp
    1f9b:	sub    rsp,0x20
    1f9f:	mov    QWORD PTR [rsp],r12
    1fa3:	mov    QWORD PTR [rsp+0x8],r13
    1fa8:	mov    QWORD PTR [rsp+0x10],r14
    1fad:	mov    r12,rdi
    1fb0:	mov    r13,rsi
    1fb3:	mov    rsi,rdx
    1fb6:	mov    rdi,r12
    1fb9:	call   1fbe <botlish_fn_29+0x27>
			1fba: R_X86_64_PLT32	rt_hash-0x4
    1fbe:	test   rax,rax
    1fc1:	mov    r14,rax
    1fc4:	je     1fec <botlish_fn_29+0x55>
    1fca:	mov    rsi,r13
    1fcd:	mov    rdi,r12
    1fd0:	call   1fd5 <botlish_fn_29+0x3e>
			1fd1: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    1fd5:	mov    rdx,rax
    1fd8:	mov    rsi,r14
    1fdb:	mov    rdi,r12
    1fde:	call   1fe3 <botlish_fn_29+0x4c>
			1fdf: R_X86_64_PLT32	rt_int_mod-0x4
    1fe3:	test   rax,rax
    1fe6:	jne    2006 <botlish_fn_29+0x6f>
    1fec:	xor    rax,rax
    1fef:	mov    r12,QWORD PTR [rsp]
    1ff3:	mov    r13,QWORD PTR [rsp+0x8]
    1ff8:	mov    r14,QWORD PTR [rsp+0x10]
    1ffd:	add    rsp,0x20
    2001:	mov    rsp,rbp
    2004:	pop    rbp
    2005:	ret
    2006:	mov    r12,QWORD PTR [rsp]
    200a:	mov    r13,QWORD PTR [rsp+0x8]
    200f:	mov    r14,QWORD PTR [rsp+0x10]
    2014:	add    rsp,0x20
    2018:	mov    rsp,rbp
    201b:	pop    rbp
    201c:	ret

000000000000201d <botlish_entry_29: ht_probe_start<HashTable, str>>:
    201d:	push   rbp
    201e:	mov    rbp,rsp
    2021:	mov    rsi,QWORD PTR [rdx]
    2024:	mov    rdx,QWORD PTR [rdx+0x8]
    2028:	call   202d <botlish_entry_29+0x10>
			2029: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    202d:	mov    rsp,rbp
    2030:	pop    rbp
    2031:	ret

0000000000002032 <botlish_fn_30: ht_probe_next<HashTable, int>>:
    2032:	push   rbp
    2033:	mov    rbp,rsp
    2036:	sub    rsp,0x40
    203a:	mov    QWORD PTR [rsp+0x20],rbx
    203f:	mov    QWORD PTR [rsp+0x28],r12
    2044:	mov    QWORD PTR [rsp+0x30],r14
    2049:	mov    r14,rdi
    204c:	mov    QWORD PTR [rsp],rsi
    2050:	mov    rbx,rsi
    2053:	mov    QWORD PTR [rsp+0x8],rdx
    2058:	mov    QWORD PTR [rsp+0x10],0x3
    2061:	test   rdx,0x1
    2068:	jne    2076 <botlish_fn_30+0x44>
    206e:	mov    rsi,rdx
    2071:	jmp    2096 <botlish_fn_30+0x64>
    2076:	mov    rsi,rdx
    2079:	add    rsi,0x2
    207d:	mov    r12,rsi
    2080:	mov    rsi,rdx
    2083:	seto   al
    2086:	test   al,al
    2088:	jne    2096 <botlish_fn_30+0x64>
    208e:	mov    rsi,rbx
    2091:	jmp    20a9 <botlish_fn_30+0x77>
    2096:	mov    edx,0x3
    209b:	mov    rdi,r14
    209e:	call   20a3 <botlish_fn_30+0x71>
			209f: R_X86_64_PLT32	rt_int_add-0x4
    20a3:	mov    rsi,rbx
    20a6:	mov    r12,rax
    20a9:	mov    rdi,r14
    20ac:	call   20b1 <botlish_fn_30+0x7f>
			20ad: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    20b1:	mov    rdx,rax
    20b4:	mov    rsi,r12
    20b7:	mov    rdi,r14
    20ba:	call   20bf <botlish_fn_30+0x8d>
			20bb: R_X86_64_PLT32	rt_int_mod-0x4
    20bf:	test   rax,rax
    20c2:	jne    20e3 <botlish_fn_30+0xb1>
    20c8:	xor    rax,rax
    20cb:	mov    rbx,QWORD PTR [rsp+0x20]
    20d0:	mov    r12,QWORD PTR [rsp+0x28]
    20d5:	mov    r14,QWORD PTR [rsp+0x30]
    20da:	add    rsp,0x40
    20de:	mov    rsp,rbp
    20e1:	pop    rbp
    20e2:	ret
    20e3:	mov    rbx,QWORD PTR [rsp+0x20]
    20e8:	mov    r12,QWORD PTR [rsp+0x28]
    20ed:	mov    r14,QWORD PTR [rsp+0x30]
    20f2:	add    rsp,0x40
    20f6:	mov    rsp,rbp
    20f9:	pop    rbp
    20fa:	ret

00000000000020fb <botlish_entry_30: ht_probe_next<HashTable, int>>:
    20fb:	push   rbp
    20fc:	mov    rbp,rsp
    20ff:	mov    rsi,QWORD PTR [rdx]
    2102:	mov    rdx,QWORD PTR [rdx+0x8]
    2106:	call   210b <botlish_entry_30+0x10>
			2107: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    210b:	mov    rsp,rbp
    210e:	pop    rbp
    210f:	ret

0000000000002110 <botlish_fn_31: ht_find_get<HashTable, str, int>>:
    2110:	push   rbp
    2111:	mov    rbp,rsp
    2114:	sub    rsp,0x50
    2118:	mov    QWORD PTR [rsp+0x20],rbx
    211d:	mov    QWORD PTR [rsp+0x28],r12
    2122:	mov    QWORD PTR [rsp+0x30],r13
    2127:	mov    QWORD PTR [rsp+0x38],r14
    212c:	mov    QWORD PTR [rsp+0x40],r15
    2131:	mov    r13,rdi
    2134:	mov    QWORD PTR [rsp],rsi
    2138:	mov    QWORD PTR [rsp+0x8],rdx
    213d:	mov    rbx,rdx
    2140:	mov    QWORD PTR [rsp+0x10],rcx
    2145:	mov    r12,rsi
    2148:	mov    r14,rcx
    214b:	mov    rax,QWORD PTR [r12+0x18]
    2150:	mov    rsi,QWORD PTR [rax]
    2153:	mov    rdx,r14
    2156:	mov    rdi,r13
    2159:	call   215e <botlish_fn_31+0x4e>
			215a: R_X86_64_PLT32	rt_mutarray_get-0x4
    215e:	mov    rcx,rax
    2161:	mov    r15,rax
    2164:	test   rax,rcx
    2167:	je     22b7 <botlish_fn_31+0x1a7>
    216d:	mov    rax,r15
    2170:	test   rax,0x1
    2176:	jne    21a4 <botlish_fn_31+0x94>
    217c:	mov    edx,0x1
    2181:	mov    rsi,r15
    2184:	mov    rdi,r13
    2187:	call   218c <botlish_fn_31+0x7c>
			2188: R_X86_64_PLT32	rt_int_cmp-0x4
    218c:	mov    ecx,0x2
    2191:	test   rax,rax
    2194:	cmove  rcx,QWORD PTR [rip+0x1a4]        # 2340 <botlish_fn_31+0x230>
    219c:	mov    rax,r15
    219f:	jmp    21b8 <botlish_fn_31+0xa8>
    21a4:	mov    ecx,0x2
    21a9:	mov    rax,r15
    21ac:	cmp    rax,0x1
    21b0:	cmove  rcx,QWORD PTR [rip+0x188]        # 2340 <botlish_fn_31+0x230>
    21b8:	cmp    rcx,0x6
    21bc:	je     2317 <botlish_fn_31+0x207>
    21c2:	test   rax,0x1
    21c8:	mov    r15,rax
    21cb:	jne    21f6 <botlish_fn_31+0xe6>
    21d1:	mov    edx,0x3
    21d6:	mov    rsi,r15
    21d9:	mov    rdi,r13
    21dc:	call   21e1 <botlish_fn_31+0xd1>
			21dd: R_X86_64_PLT32	rt_int_cmp-0x4
    21e1:	mov    ecx,0x2
    21e6:	test   rax,rax
    21e9:	cmove  rcx,QWORD PTR [rip+0x14f]        # 2340 <botlish_fn_31+0x230>
    21f1:	jmp    220a <botlish_fn_31+0xfa>
    21f6:	mov    rsi,r15
    21f9:	mov    ecx,0x2
    21fe:	cmp    rsi,0x3
    2202:	cmove  rcx,QWORD PTR [rip+0x136]        # 2340 <botlish_fn_31+0x230>
    220a:	cmp    rcx,0x6
    220e:	je     221e <botlish_fn_31+0x10e>
    2214:	mov    eax,0x2
    2219:	jmp    2296 <botlish_fn_31+0x186>
    221e:	mov    rcx,QWORD PTR [r12+0x18]
    2223:	mov    rsi,QWORD PTR [rcx+0x8]
    2227:	mov    rdx,r14
    222a:	mov    rdi,r13
    222d:	call   2232 <botlish_fn_31+0x122>
			222e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2232:	test   rax,rax
    2235:	je     22b7 <botlish_fn_31+0x1a7>
    223b:	mov    rsi,rax
    223e:	and    rsi,rbx
    2241:	test   rsi,0x1
    2248:	jne    226a <botlish_fn_31+0x15a>
    224e:	mov    rsi,rax
    2251:	mov    rdx,rbx
    2254:	mov    rdi,r13
    2257:	call   225c <botlish_fn_31+0x14c>
			2258: R_X86_64_PLT32	rt_value_eq-0x4
    225c:	test   rax,rax
    225f:	je     22b7 <botlish_fn_31+0x1a7>
    2265:	jmp    227d <botlish_fn_31+0x16d>
    226a:	mov    rsi,rax
    226d:	mov    eax,0x2
    2272:	cmp    rsi,rbx
    2275:	cmove  rax,QWORD PTR [rip+0xc3]        # 2340 <botlish_fn_31+0x230>
    227d:	cmp    rax,0x6
    2281:	je     2291 <botlish_fn_31+0x181>
    2287:	mov    eax,0x2
    228c:	jmp    2296 <botlish_fn_31+0x186>
    2291:	mov    eax,0x6
    2296:	cmp    rax,0x6
    229a:	je     22f2 <botlish_fn_31+0x1e2>
    22a0:	mov    rdx,r14
    22a3:	mov    rsi,r12
    22a6:	mov    rdi,r13
    22a9:	call   22ae <botlish_fn_31+0x19e>
			22aa: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    22ae:	test   rax,rax
    22b1:	jne    22dc <botlish_fn_31+0x1cc>
    22b7:	xor    rax,rax
    22ba:	mov    rbx,QWORD PTR [rsp+0x20]
    22bf:	mov    r12,QWORD PTR [rsp+0x28]
    22c4:	mov    r13,QWORD PTR [rsp+0x30]
    22c9:	mov    r14,QWORD PTR [rsp+0x38]
    22ce:	mov    r15,QWORD PTR [rsp+0x40]
    22d3:	add    rsp,0x50
    22d7:	mov    rsp,rbp
    22da:	pop    rbp
    22db:	ret
    22dc:	mov    QWORD PTR [rsp],r12
    22e0:	mov    QWORD PTR [rsp+0x8],rbx
    22e5:	mov    QWORD PTR [rsp+0x10],rax
    22ea:	mov    r14,rax
    22ed:	jmp    214b <botlish_fn_31+0x3b>
    22f2:	mov    rax,r14
    22f5:	mov    rbx,QWORD PTR [rsp+0x20]
    22fa:	mov    r12,QWORD PTR [rsp+0x28]
    22ff:	mov    r13,QWORD PTR [rsp+0x30]
    2304:	mov    r14,QWORD PTR [rsp+0x38]
    2309:	mov    r15,QWORD PTR [rsp+0x40]
    230e:	add    rsp,0x50
    2312:	mov    rsp,rbp
    2315:	pop    rbp
    2316:	ret
    2317:	mov    rax,0xffffffffffffffff
    231e:	mov    rbx,QWORD PTR [rsp+0x20]
    2323:	mov    r12,QWORD PTR [rsp+0x28]
    2328:	mov    r13,QWORD PTR [rsp+0x30]
    232d:	mov    r14,QWORD PTR [rsp+0x38]
    2332:	mov    r15,QWORD PTR [rsp+0x40]
    2337:	add    rsp,0x50
    233b:	mov    rsp,rbp
    233e:	pop    rbp
    233f:	ret
    2340:	(bad)
    2341:	add    BYTE PTR [rax],al
    2343:	add    BYTE PTR [rax],al
    2345:	add    BYTE PTR [rax],al
	...

0000000000002348 <botlish_entry_31: ht_find_get<HashTable, str, int>>:
    2348:	push   rbp
    2349:	mov    rbp,rsp
    234c:	mov    rsi,QWORD PTR [rdx]
    234f:	mov    r8,QWORD PTR [rdx+0x8]
    2353:	mov    rcx,QWORD PTR [rdx+0x10]
    2357:	mov    rdx,r8
    235a:	call   235f <botlish_entry_31+0x17>
			235b: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    235f:	mov    rsp,rbp
    2362:	pop    rbp
    2363:	ret
    2364:	add    BYTE PTR [rax],al
	...

0000000000002368 <botlish_fn_32: ht_find_insert<HashTable, str, int, int>>:
    2368:	push   rbp
    2369:	mov    rbp,rsp
    236c:	sub    rsp,0x60
    2370:	mov    QWORD PTR [rsp+0x30],rbx
    2375:	mov    QWORD PTR [rsp+0x38],r12
    237a:	mov    QWORD PTR [rsp+0x40],r13
    237f:	mov    QWORD PTR [rsp+0x48],r14
    2384:	mov    QWORD PTR [rsp+0x50],r15
    2389:	mov    r15,rdi
    238c:	mov    QWORD PTR [rsp],rsi
    2390:	mov    QWORD PTR [rsp+0x8],rdx
    2395:	mov    r12,rdx
    2398:	mov    QWORD PTR [rsp+0x10],rcx
    239d:	mov    QWORD PTR [rsp+0x18],r8
    23a2:	mov    rbx,rsi
    23a5:	mov    r14,rcx
    23a8:	mov    QWORD PTR [rsp+0x20],r8
    23ad:	mov    r10,QWORD PTR [rbx+0x18]
    23b1:	mov    rsi,QWORD PTR [r10]
    23b4:	mov    rdx,r14
    23b7:	mov    rdi,r15
    23ba:	call   23bf <botlish_fn_32+0x57>
			23bb: R_X86_64_PLT32	rt_mutarray_get-0x4
    23bf:	mov    rcx,rax
    23c2:	mov    r13,rax
    23c5:	test   rax,rcx
    23c8:	je     2618 <botlish_fn_32+0x2b0>
    23ce:	mov    rax,r13
    23d1:	test   rax,0x1
    23d7:	jne    2402 <botlish_fn_32+0x9a>
    23dd:	mov    edx,0x1
    23e2:	mov    rsi,r13
    23e5:	mov    rdi,r15
    23e8:	call   23ed <botlish_fn_32+0x85>
			23e9: R_X86_64_PLT32	rt_int_cmp-0x4
    23ed:	mov    ecx,0x2
    23f2:	test   rax,rax
    23f5:	cmove  rcx,QWORD PTR [rip+0x313]        # 2710 <botlish_fn_32+0x3a8>
    23fd:	jmp    2416 <botlish_fn_32+0xae>
    2402:	mov    ecx,0x2
    2407:	mov    rax,r13
    240a:	cmp    rax,0x1
    240e:	cmove  rcx,QWORD PTR [rip+0x2fa]        # 2710 <botlish_fn_32+0x3a8>
    2416:	cmp    rcx,0x6
    241a:	je     2668 <botlish_fn_32+0x300>
    2420:	mov    rax,r13
    2423:	test   rax,0x1
    2429:	jne    2454 <botlish_fn_32+0xec>
    242f:	mov    edx,0x3
    2434:	mov    rsi,r13
    2437:	mov    rdi,r15
    243a:	call   243f <botlish_fn_32+0xd7>
			243b: R_X86_64_PLT32	rt_int_cmp-0x4
    243f:	mov    ecx,0x2
    2444:	test   rax,rax
    2447:	cmove  rcx,QWORD PTR [rip+0x2c1]        # 2710 <botlish_fn_32+0x3a8>
    244f:	jmp    2468 <botlish_fn_32+0x100>
    2454:	mov    ecx,0x2
    2459:	mov    rax,r13
    245c:	cmp    rax,0x3
    2460:	cmove  rcx,QWORD PTR [rip+0x2a8]        # 2710 <botlish_fn_32+0x3a8>
    2468:	cmp    rcx,0x6
    246c:	je     247c <botlish_fn_32+0x114>
    2472:	mov    eax,0x2
    2477:	jmp    24f0 <botlish_fn_32+0x188>
    247c:	mov    rax,QWORD PTR [rbx+0x18]
    2480:	mov    rsi,QWORD PTR [rax+0x8]
    2484:	mov    rdx,r14
    2487:	mov    rdi,r15
    248a:	call   248f <botlish_fn_32+0x127>
			248b: R_X86_64_PLT32	rt_mutarray_get-0x4
    248f:	test   rax,rax
    2492:	je     2618 <botlish_fn_32+0x2b0>
    2498:	mov    rcx,rax
    249b:	and    rcx,r12
    249e:	mov    rsi,rax
    24a1:	test   rcx,0x1
    24a8:	jne    24c7 <botlish_fn_32+0x15f>
    24ae:	mov    rdx,r12
    24b1:	mov    rdi,r15
    24b4:	call   24b9 <botlish_fn_32+0x151>
			24b5: R_X86_64_PLT32	rt_value_eq-0x4
    24b9:	test   rax,rax
    24bc:	je     2618 <botlish_fn_32+0x2b0>
    24c2:	jmp    24d7 <botlish_fn_32+0x16f>
    24c7:	mov    eax,0x2
    24cc:	cmp    rsi,r12
    24cf:	cmove  rax,QWORD PTR [rip+0x239]        # 2710 <botlish_fn_32+0x3a8>
    24d7:	cmp    rax,0x6
    24db:	je     24eb <botlish_fn_32+0x183>
    24e1:	mov    eax,0x2
    24e6:	jmp    24f0 <botlish_fn_32+0x188>
    24eb:	mov    eax,0x6
    24f0:	cmp    rax,0x6
    24f4:	je     2660 <botlish_fn_32+0x2f8>
    24fa:	mov    rax,r13
    24fd:	test   rax,0x1
    2503:	jne    252e <botlish_fn_32+0x1c6>
    2509:	mov    edx,0x5
    250e:	mov    rsi,r13
    2511:	mov    rdi,r15
    2514:	call   2519 <botlish_fn_32+0x1b1>
			2515: R_X86_64_PLT32	rt_int_cmp-0x4
    2519:	mov    ecx,0x2
    251e:	test   rax,rax
    2521:	cmove  rcx,QWORD PTR [rip+0x1e7]        # 2710 <botlish_fn_32+0x3a8>
    2529:	jmp    2542 <botlish_fn_32+0x1da>
    252e:	mov    rsi,r13
    2531:	mov    ecx,0x2
    2536:	cmp    rsi,0x5
    253a:	cmove  rcx,QWORD PTR [rip+0x1ce]        # 2710 <botlish_fn_32+0x3a8>
    2542:	cmp    rcx,0x6
    2546:	je     2556 <botlish_fn_32+0x1ee>
    254c:	mov    eax,0x2
    2551:	jmp    25c0 <botlish_fn_32+0x258>
    2556:	mov    r13,QWORD PTR [rsp+0x20]
    255b:	test   r13,0x1
    2562:	jne    2592 <botlish_fn_32+0x22a>
    2568:	mov    edx,0x1
    256d:	mov    rsi,r13
    2570:	mov    rdi,r15
    2573:	call   2578 <botlish_fn_32+0x210>
			2574: R_X86_64_PLT32	rt_int_cmp-0x4
    2578:	mov    ecx,0x2
    257d:	test   rax,rax
    2580:	cmovl  rcx,QWORD PTR [rip+0x188]        # 2710 <botlish_fn_32+0x3a8>
    2588:	mov    QWORD PTR [rsp+0x20],r13
    258d:	jmp    25a7 <botlish_fn_32+0x23f>
    2592:	mov    ecx,0x2
    2597:	test   r13,r13
    259a:	mov    QWORD PTR [rsp+0x20],r13
    259f:	cmovle rcx,QWORD PTR [rip+0x169]        # 2710 <botlish_fn_32+0x3a8>
    25a7:	cmp    rcx,0x6
    25ab:	je     25bb <botlish_fn_32+0x253>
    25b1:	mov    eax,0x2
    25b6:	jmp    25c0 <botlish_fn_32+0x258>
    25bb:	mov    eax,0x6
    25c0:	cmp    rax,0x6
    25c4:	je     2601 <botlish_fn_32+0x299>
    25ca:	mov    rdx,r14
    25cd:	mov    rsi,rbx
    25d0:	mov    rdi,r15
    25d3:	call   25d8 <botlish_fn_32+0x270>
			25d4: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    25d8:	test   rax,rax
    25db:	je     2618 <botlish_fn_32+0x2b0>
    25e1:	mov    QWORD PTR [rsp],rbx
    25e5:	mov    QWORD PTR [rsp+0x8],r12
    25ea:	mov    QWORD PTR [rsp+0x10],rax
    25ef:	mov    r10,QWORD PTR [rsp+0x20]
    25f4:	mov    QWORD PTR [rsp+0x18],r10
    25f9:	mov    r14,rax
    25fc:	jmp    23ad <botlish_fn_32+0x45>
    2601:	mov    rdx,r14
    2604:	mov    rsi,rbx
    2607:	mov    rdi,r15
    260a:	call   260f <botlish_fn_32+0x2a7>
			260b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    260f:	test   rax,rax
    2612:	jne    263d <botlish_fn_32+0x2d5>
    2618:	xor    rax,rax
    261b:	mov    rbx,QWORD PTR [rsp+0x30]
    2620:	mov    r12,QWORD PTR [rsp+0x38]
    2625:	mov    r13,QWORD PTR [rsp+0x40]
    262a:	mov    r14,QWORD PTR [rsp+0x48]
    262f:	mov    r15,QWORD PTR [rsp+0x50]
    2634:	add    rsp,0x60
    2638:	mov    rsp,rbp
    263b:	pop    rbp
    263c:	ret
    263d:	mov    QWORD PTR [rsp],rbx
    2641:	mov    QWORD PTR [rsp+0x8],r12
    2646:	mov    QWORD PTR [rsp+0x10],rax
    264b:	mov    rdx,r14
    264e:	mov    QWORD PTR [rsp+0x18],rdx
    2653:	mov    QWORD PTR [rsp+0x20],r14
    2658:	mov    r14,rax
    265b:	jmp    23ad <botlish_fn_32+0x45>
    2660:	mov    rax,r14
    2663:	jmp    26c7 <botlish_fn_32+0x35f>
    2668:	mov    rax,QWORD PTR [rsp+0x20]
    266d:	test   rax,0x1
    2673:	jne    26a0 <botlish_fn_32+0x338>
    2679:	mov    edx,0x1
    267e:	mov    rdi,r15
    2681:	mov    rsi,QWORD PTR [rsp+0x20]
    2686:	call   268b <botlish_fn_32+0x323>
			2687: R_X86_64_PLT32	rt_int_cmp-0x4
    268b:	mov    ecx,0x2
    2690:	test   rax,rax
    2693:	cmovge rcx,QWORD PTR [rip+0x75]        # 2710 <botlish_fn_32+0x3a8>
    269b:	jmp    26ba <botlish_fn_32+0x352>
    26a0:	mov    ecx,0x2
    26a5:	mov    rax,QWORD PTR [rsp+0x20]
    26aa:	mov    rdx,QWORD PTR [rsp+0x20]
    26af:	test   rax,rdx
    26b2:	cmovg  rcx,QWORD PTR [rip+0x56]        # 2710 <botlish_fn_32+0x3a8>
    26ba:	cmp    rcx,0x6
    26be:	je     26e9 <botlish_fn_32+0x381>
    26c4:	mov    rax,r14
    26c7:	mov    rbx,QWORD PTR [rsp+0x30]
    26cc:	mov    r12,QWORD PTR [rsp+0x38]
    26d1:	mov    r13,QWORD PTR [rsp+0x40]
    26d6:	mov    r14,QWORD PTR [rsp+0x48]
    26db:	mov    r15,QWORD PTR [rsp+0x50]
    26e0:	add    rsp,0x60
    26e4:	mov    rsp,rbp
    26e7:	pop    rbp
    26e8:	ret
    26e9:	mov    rax,QWORD PTR [rsp+0x20]
    26ee:	mov    rbx,QWORD PTR [rsp+0x30]
    26f3:	mov    r12,QWORD PTR [rsp+0x38]
    26f8:	mov    r13,QWORD PTR [rsp+0x40]
    26fd:	mov    r14,QWORD PTR [rsp+0x48]
    2702:	mov    r15,QWORD PTR [rsp+0x50]
    2707:	add    rsp,0x60
    270b:	mov    rsp,rbp
    270e:	pop    rbp
    270f:	ret
    2710:	(bad)
    2711:	add    BYTE PTR [rax],al
    2713:	add    BYTE PTR [rax],al
    2715:	add    BYTE PTR [rax],al
	...

0000000000002718 <botlish_entry_32: ht_find_insert<HashTable, str, int, int>>:
    2718:	push   rbp
    2719:	mov    rbp,rsp
    271c:	mov    rsi,QWORD PTR [rdx]
    271f:	mov    r9,QWORD PTR [rdx+0x8]
    2723:	mov    rcx,QWORD PTR [rdx+0x10]
    2727:	mov    r8,QWORD PTR [rdx+0x18]
    272b:	mov    rdx,r9
    272e:	call   2733 <botlish_entry_32+0x1b>
			272f: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    2733:	mov    rsp,rbp
    2736:	pop    rbp
    2737:	ret

0000000000002738 <botlish_fn_33: ht_get<HashTable, str>>:
    2738:	push   rbp
    2739:	mov    rbp,rsp
    273c:	sub    rsp,0x40
    2740:	mov    QWORD PTR [rsp+0x20],rbx
    2745:	mov    QWORD PTR [rsp+0x28],r12
    274a:	mov    QWORD PTR [rsp+0x30],r13
    274f:	mov    r12,rdi
    2752:	mov    QWORD PTR [rsp],rsi
    2756:	mov    QWORD PTR [rsp+0x8],rdx
    275b:	mov    r13,rdx
    275e:	mov    rbx,rsi
    2761:	mov    rdx,r13
    2764:	mov    rdi,r12
    2767:	call   276c <botlish_fn_33+0x34>
			2768: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    276c:	test   rax,rax
    276f:	je     2807 <botlish_fn_33+0xcf>
    2775:	mov    QWORD PTR [rsp+0x10],rax
    277a:	mov    rcx,rax
    277d:	mov    rdx,r13
    2780:	mov    rsi,rbx
    2783:	mov    rdi,r12
    2786:	call   278b <botlish_fn_33+0x53>
			2787: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    278b:	mov    rcx,rax
    278e:	mov    r13,rax
    2791:	test   rax,rcx
    2794:	je     2807 <botlish_fn_33+0xcf>
    279a:	mov    rax,r13
    279d:	test   rax,0x1
    27a3:	jne    27ce <botlish_fn_33+0x96>
    27a9:	mov    edx,0x1
    27ae:	mov    rsi,r13
    27b1:	mov    rdi,r12
    27b4:	call   27b9 <botlish_fn_33+0x81>
			27b5: R_X86_64_PLT32	rt_int_cmp-0x4
    27b9:	mov    ecx,0x2
    27be:	test   rax,rax
    27c1:	cmovl  rcx,QWORD PTR [rip+0x8f]        # 2858 <botlish_fn_33+0x120>
    27c9:	jmp    27e1 <botlish_fn_33+0xa9>
    27ce:	mov    ecx,0x2
    27d3:	mov    rax,r13
    27d6:	test   rax,rax
    27d9:	cmovle rcx,QWORD PTR [rip+0x77]        # 2858 <botlish_fn_33+0x120>
    27e1:	cmp    rcx,0x6
    27e5:	je     283a <botlish_fn_33+0x102>
    27eb:	mov    rax,QWORD PTR [rbx+0x18]
    27ef:	mov    rsi,QWORD PTR [rax+0x10]
    27f3:	mov    rdx,r13
    27f6:	mov    rdi,r12
    27f9:	call   27fe <botlish_fn_33+0xc6>
			27fa: R_X86_64_PLT32	rt_mutarray_get-0x4
    27fe:	test   rax,rax
    2801:	jne    2822 <botlish_fn_33+0xea>
    2807:	xor    rax,rax
    280a:	mov    rbx,QWORD PTR [rsp+0x20]
    280f:	mov    r12,QWORD PTR [rsp+0x28]
    2814:	mov    r13,QWORD PTR [rsp+0x30]
    2819:	add    rsp,0x40
    281d:	mov    rsp,rbp
    2820:	pop    rbp
    2821:	ret
    2822:	mov    rbx,QWORD PTR [rsp+0x20]
    2827:	mov    r12,QWORD PTR [rsp+0x28]
    282c:	mov    r13,QWORD PTR [rsp+0x30]
    2831:	add    rsp,0x40
    2835:	mov    rsp,rbp
    2838:	pop    rbp
    2839:	ret
    283a:	mov    eax,0xa
    283f:	mov    rbx,QWORD PTR [rsp+0x20]
    2844:	mov    r12,QWORD PTR [rsp+0x28]
    2849:	mov    r13,QWORD PTR [rsp+0x30]
    284e:	add    rsp,0x40
    2852:	mov    rsp,rbp
    2855:	pop    rbp
    2856:	ret
    2857:	add    BYTE PTR [rsi],al
    2859:	add    BYTE PTR [rax],al
    285b:	add    BYTE PTR [rax],al
    285d:	add    BYTE PTR [rax],al
	...

0000000000002860 <botlish_entry_33: ht_get<HashTable, str>>:
    2860:	push   rbp
    2861:	mov    rbp,rsp
    2864:	mov    rsi,QWORD PTR [rdx]
    2867:	mov    rdx,QWORD PTR [rdx+0x8]
    286b:	call   2870 <botlish_entry_33+0x10>
			286c: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    2870:	mov    rsp,rbp
    2873:	pop    rbp
    2874:	ret
    2875:	add    BYTE PTR [rax],al
	...

0000000000002878 <botlish_fn_34: ht_rehash_probe<mutarray, int, int>>:
    2878:	push   rbp
    2879:	mov    rbp,rsp
    287c:	sub    rsp,0x40
    2880:	mov    QWORD PTR [rsp+0x20],rbx
    2885:	mov    QWORD PTR [rsp+0x28],r12
    288a:	mov    QWORD PTR [rsp+0x30],r13
    288f:	mov    QWORD PTR [rsp+0x38],r14
    2894:	mov    r13,rdi
    2897:	mov    QWORD PTR [rsp],rsi
    289b:	mov    QWORD PTR [rsp+0x8],rdx
    28a0:	mov    QWORD PTR [rsp+0x10],rcx
    28a5:	mov    r12,rcx
    28a8:	mov    rbx,rsi
    28ab:	mov    r14,rdx
    28ae:	mov    rdx,r14
    28b1:	mov    rsi,rbx
    28b4:	mov    rdi,r13
    28b7:	call   28bc <botlish_fn_34+0x44>
			28b8: R_X86_64_PLT32	rt_mutarray_get-0x4
    28bc:	test   rax,rax
    28bf:	je     295c <botlish_fn_34+0xe4>
    28c5:	test   rax,0x1
    28cb:	mov    rsi,rax
    28ce:	jne    28ef <botlish_fn_34+0x77>
    28d4:	mov    edx,0x1
    28d9:	mov    rdi,r13
    28dc:	call   28e1 <botlish_fn_34+0x69>
			28dd: R_X86_64_PLT32	rt_value_eq-0x4
    28e1:	test   rax,rax
    28e4:	je     295c <botlish_fn_34+0xe4>
    28ea:	jmp    2900 <botlish_fn_34+0x88>
    28ef:	mov    eax,0x2
    28f4:	cmp    rsi,0x1
    28f8:	cmove  rax,QWORD PTR [rip+0xb8]        # 29b8 <botlish_fn_34+0x140>
    2900:	cmp    rax,0x6
    2904:	je     2992 <botlish_fn_34+0x11a>
    290a:	mov    QWORD PTR [rsp+0x18],0x3
    2913:	mov    rsi,r14
    2916:	test   rsi,0x1
    291d:	je     2935 <botlish_fn_34+0xbd>
    2923:	mov    rsi,r14
    2926:	add    rsi,0x2
    292a:	seto   al
    292d:	test   al,al
    292f:	je     2948 <botlish_fn_34+0xd0>
    2935:	mov    edx,0x3
    293a:	mov    rsi,r14
    293d:	mov    rdi,r13
    2940:	call   2945 <botlish_fn_34+0xcd>
			2941: R_X86_64_PLT32	rt_int_add-0x4
    2945:	mov    rsi,rax
    2948:	mov    rdx,r12
    294b:	mov    rdi,r13
    294e:	call   2953 <botlish_fn_34+0xdb>
			294f: R_X86_64_PLT32	rt_int_mod-0x4
    2953:	test   rax,rax
    2956:	jne    297c <botlish_fn_34+0x104>
    295c:	xor    rax,rax
    295f:	mov    rbx,QWORD PTR [rsp+0x20]
    2964:	mov    r12,QWORD PTR [rsp+0x28]
    2969:	mov    r13,QWORD PTR [rsp+0x30]
    296e:	mov    r14,QWORD PTR [rsp+0x38]
    2973:	add    rsp,0x40
    2977:	mov    rsp,rbp
    297a:	pop    rbp
    297b:	ret
    297c:	mov    QWORD PTR [rsp],rbx
    2980:	mov    QWORD PTR [rsp+0x8],rax
    2985:	mov    QWORD PTR [rsp+0x10],r12
    298a:	mov    r14,rax
    298d:	jmp    28ae <botlish_fn_34+0x36>
    2992:	mov    rax,r14
    2995:	mov    rbx,QWORD PTR [rsp+0x20]
    299a:	mov    r12,QWORD PTR [rsp+0x28]
    299f:	mov    r13,QWORD PTR [rsp+0x30]
    29a4:	mov    r14,QWORD PTR [rsp+0x38]
    29a9:	add    rsp,0x40
    29ad:	mov    rsp,rbp
    29b0:	pop    rbp
    29b1:	ret
    29b2:	add    BYTE PTR [rax],al
    29b4:	add    BYTE PTR [rax],al
    29b6:	add    BYTE PTR [rax],al
    29b8:	(bad)
    29b9:	add    BYTE PTR [rax],al
    29bb:	add    BYTE PTR [rax],al
    29bd:	add    BYTE PTR [rax],al
	...

00000000000029c0 <botlish_entry_34: ht_rehash_probe<mutarray, int, int>>:
    29c0:	push   rbp
    29c1:	mov    rbp,rsp
    29c4:	mov    rsi,QWORD PTR [rdx]
    29c7:	mov    r8,QWORD PTR [rdx+0x8]
    29cb:	mov    rcx,QWORD PTR [rdx+0x10]
    29cf:	mov    rdx,r8
    29d2:	call   29d7 <botlish_entry_34+0x17>
			29d3: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    29d7:	mov    rsp,rbp
    29da:	pop    rbp
    29db:	ret

00000000000029dc <botlish_fn_35: ht_rehash_insert<HashTable, int, any, any>>:
    29dc:	push   rbp
    29dd:	mov    rbp,rsp
    29e0:	sub    rsp,0x70
    29e4:	mov    QWORD PTR [rsp+0x40],rbx
    29e9:	mov    QWORD PTR [rsp+0x48],r12
    29ee:	mov    QWORD PTR [rsp+0x50],r13
    29f3:	mov    QWORD PTR [rsp+0x58],r14
    29f8:	mov    QWORD PTR [rsp+0x60],r15
    29fd:	mov    r13,rdi
    2a00:	mov    QWORD PTR [rsp],rsi
    2a04:	mov    QWORD PTR [rsp+0x8],rdx
    2a09:	mov    r15,rdx
    2a0c:	mov    QWORD PTR [rsp+0x10],rcx
    2a11:	mov    r14,rcx
    2a14:	mov    QWORD PTR [rsp+0x18],r8
    2a19:	mov    r12,r8
    2a1c:	mov    rax,QWORD PTR [rsi+0x18]
    2a20:	mov    rbx,rsi
    2a23:	mov    rsi,QWORD PTR [rax]
    2a26:	mov    QWORD PTR [rsp+0x20],rsi
    2a2b:	mov    QWORD PTR [rsp+0x30],rsi
    2a30:	mov    rsi,r14
    2a33:	mov    rdi,r13
    2a36:	call   2a3b <botlish_fn_35+0x5f>
			2a37: R_X86_64_PLT32	rt_hash-0x4
    2a3b:	test   rax,rax
    2a3e:	mov    rsi,rax
    2a41:	je     2ae0 <botlish_fn_35+0x104>
    2a47:	mov    rdx,r15
    2a4a:	mov    rdi,r13
    2a4d:	call   2a52 <botlish_fn_35+0x76>
			2a4e: R_X86_64_PLT32	rt_int_mod-0x4
    2a52:	test   rax,rax
    2a55:	je     2ae0 <botlish_fn_35+0x104>
    2a5b:	mov    QWORD PTR [rsp+0x28],rax
    2a60:	mov    rcx,r15
    2a63:	mov    rdx,rax
    2a66:	mov    rsi,QWORD PTR [rsp+0x30]
    2a6b:	mov    rdi,r13
    2a6e:	call   2a73 <botlish_fn_35+0x97>
			2a6f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2a73:	mov    rdx,rax
    2a76:	mov    r15,rax
    2a79:	test   rax,rdx
    2a7c:	je     2ae0 <botlish_fn_35+0x104>
    2a82:	mov    rcx,QWORD PTR [rbx+0x18]
    2a86:	mov    rsi,QWORD PTR [rcx]
    2a89:	mov    ecx,0x3
    2a8e:	mov    rdx,r15
    2a91:	mov    rdi,r13
    2a94:	call   2a99 <botlish_fn_35+0xbd>
			2a95: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a99:	test   rax,rax
    2a9c:	je     2ae0 <botlish_fn_35+0x104>
    2aa2:	mov    rax,QWORD PTR [rbx+0x18]
    2aa6:	mov    rsi,QWORD PTR [rax+0x8]
    2aaa:	mov    rcx,r14
    2aad:	mov    rdx,r15
    2ab0:	mov    rdi,r13
    2ab3:	call   2ab8 <botlish_fn_35+0xdc>
			2ab4: R_X86_64_PLT32	rt_mutarray_set-0x4
    2ab8:	test   rax,rax
    2abb:	je     2ae0 <botlish_fn_35+0x104>
    2ac1:	mov    rax,QWORD PTR [rbx+0x18]
    2ac5:	mov    rsi,QWORD PTR [rax+0x10]
    2ac9:	mov    rcx,r12
    2acc:	mov    rdx,r15
    2acf:	mov    rdi,r13
    2ad2:	call   2ad7 <botlish_fn_35+0xfb>
			2ad3: R_X86_64_PLT32	rt_mutarray_set-0x4
    2ad7:	test   rax,rax
    2ada:	jne    2b05 <botlish_fn_35+0x129>
    2ae0:	xor    rax,rax
    2ae3:	mov    rbx,QWORD PTR [rsp+0x40]
    2ae8:	mov    r12,QWORD PTR [rsp+0x48]
    2aed:	mov    r13,QWORD PTR [rsp+0x50]
    2af2:	mov    r14,QWORD PTR [rsp+0x58]
    2af7:	mov    r15,QWORD PTR [rsp+0x60]
    2afc:	add    rsp,0x70
    2b00:	mov    rsp,rbp
    2b03:	pop    rbp
    2b04:	ret
    2b05:	mov    rax,rbx
    2b08:	mov    rbx,QWORD PTR [rsp+0x40]
    2b0d:	mov    r12,QWORD PTR [rsp+0x48]
    2b12:	mov    r13,QWORD PTR [rsp+0x50]
    2b17:	mov    r14,QWORD PTR [rsp+0x58]
    2b1c:	mov    r15,QWORD PTR [rsp+0x60]
    2b21:	add    rsp,0x70
    2b25:	mov    rsp,rbp
    2b28:	pop    rbp
    2b29:	ret

0000000000002b2a <botlish_entry_35: ht_rehash_insert<HashTable, int, any, any>>:
    2b2a:	push   rbp
    2b2b:	mov    rbp,rsp
    2b2e:	mov    rsi,QWORD PTR [rdx]
    2b31:	mov    r9,QWORD PTR [rdx+0x8]
    2b35:	mov    rcx,QWORD PTR [rdx+0x10]
    2b39:	mov    r8,QWORD PTR [rdx+0x18]
    2b3d:	mov    rdx,r9
    2b40:	call   2b45 <botlish_entry_35+0x1b>
			2b41: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2b45:	mov    rsp,rbp
    2b48:	pop    rbp
    2b49:	ret
    2b4a:	add    BYTE PTR [rax],al
    2b4c:	add    BYTE PTR [rax],al
	...

0000000000002b50 <botlish_fn_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2b50:	push   rbp
    2b51:	mov    rbp,rsp
    2b54:	sub    rsp,0x90
    2b5b:	mov    QWORD PTR [rsp+0x60],rbx
    2b60:	mov    QWORD PTR [rsp+0x68],r12
    2b65:	mov    QWORD PTR [rsp+0x70],r13
    2b6a:	mov    QWORD PTR [rsp+0x78],r14
    2b6f:	mov    QWORD PTR [rsp+0x80],r15
    2b77:	mov    QWORD PTR [rsp+0x38],rdi
    2b7c:	mov    QWORD PTR [rsp+0x40],r9
    2b81:	mov    rdi,QWORD PTR [rbp+0x10]
    2b85:	mov    rbx,QWORD PTR [rbp+0x18]
    2b89:	mov    QWORD PTR [rsp],rsi
    2b8d:	mov    QWORD PTR [rsp+0x8],rdx
    2b92:	mov    r14,rdx
    2b95:	mov    QWORD PTR [rsp+0x10],rcx
    2b9a:	mov    r15,rcx
    2b9d:	mov    QWORD PTR [rsp+0x18],rdi
    2ba2:	mov    QWORD PTR [rsp+0x20],rbx
    2ba7:	sar    r8,1
    2baa:	mov    rcx,QWORD PTR [rsp+0x40]
    2baf:	mov    r12,r8
    2bb2:	mov    QWORD PTR [rsp+0x48],rdi
    2bb7:	cmp    r12,rcx
    2bba:	mov    QWORD PTR [rsp+0x40],rcx
    2bbf:	jge    2d26 <botlish_fn_36+0x1d6>
    2bc5:	mov    rdx,r12
    2bc8:	shl    rdx,1
    2bcb:	or     rdx,0x1
    2bcf:	mov    r13,rsi
    2bd2:	mov    QWORD PTR [rsp+0x58],rdx
    2bd7:	mov    rdi,QWORD PTR [rsp+0x38]
    2bdc:	call   2be1 <botlish_fn_36+0x91>
			2bdd: R_X86_64_PLT32	rt_mutarray_get-0x4
    2be1:	test   rax,rax
    2be4:	je     2cca <botlish_fn_36+0x17a>
    2bea:	test   rax,0x1
    2bf0:	mov    rsi,rax
    2bf3:	jne    2c16 <botlish_fn_36+0xc6>
    2bf9:	mov    edx,0x3
    2bfe:	mov    rdi,QWORD PTR [rsp+0x38]
    2c03:	call   2c08 <botlish_fn_36+0xb8>
			2c04: R_X86_64_PLT32	rt_value_eq-0x4
    2c08:	test   rax,rax
    2c0b:	je     2cca <botlish_fn_36+0x17a>
    2c11:	jmp    2c27 <botlish_fn_36+0xd7>
    2c16:	mov    eax,0x2
    2c1b:	cmp    rsi,0x3
    2c1f:	cmove  rax,QWORD PTR [rip+0x131]        # 2d58 <botlish_fn_36+0x208>
    2c27:	cmp    rax,0x6
    2c2b:	je     2c62 <botlish_fn_36+0x112>
    2c31:	mov    QWORD PTR [rsp],r13
    2c35:	mov    QWORD PTR [rsp+0x8],r14
    2c3a:	mov    QWORD PTR [rsp+0x10],r15
    2c3f:	mov    rsi,QWORD PTR [rsp+0x48]
    2c44:	mov    QWORD PTR [rsp+0x18],rsi
    2c49:	mov    QWORD PTR [rsp+0x20],rbx
    2c4e:	add    r12,0x1
    2c55:	mov    rcx,QWORD PTR [rsp+0x40]
    2c5a:	mov    rsi,r13
    2c5d:	jmp    2bb7 <botlish_fn_36+0x67>
    2c62:	mov    rdx,QWORD PTR [rsp+0x58]
    2c67:	mov    rsi,r14
    2c6a:	mov    rdi,QWORD PTR [rsp+0x38]
    2c6f:	call   2c74 <botlish_fn_36+0x124>
			2c70: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c74:	test   rax,rax
    2c77:	je     2cca <botlish_fn_36+0x17a>
    2c7d:	mov    QWORD PTR [rsp+0x28],rax
    2c82:	mov    rdx,QWORD PTR [rsp+0x58]
    2c87:	mov    QWORD PTR [rsp+0x50],rax
    2c8c:	mov    rsi,r15
    2c8f:	mov    rdi,QWORD PTR [rsp+0x38]
    2c94:	call   2c99 <botlish_fn_36+0x149>
			2c95: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c99:	test   rax,rax
    2c9c:	je     2cca <botlish_fn_36+0x17a>
    2ca2:	mov    QWORD PTR [rsp+0x30],rax
    2ca7:	mov    rcx,QWORD PTR [rsp+0x50]
    2cac:	mov    rsi,QWORD PTR [rsp+0x48]
    2cb1:	mov    r8,rax
    2cb4:	mov    rdx,rbx
    2cb7:	mov    rdi,QWORD PTR [rsp+0x38]
    2cbc:	call   2cc1 <botlish_fn_36+0x171>
			2cbd: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2cc1:	test   rax,rax
    2cc4:	jne    2cf5 <botlish_fn_36+0x1a5>
    2cca:	xor    rax,rax
    2ccd:	mov    rbx,QWORD PTR [rsp+0x60]
    2cd2:	mov    r12,QWORD PTR [rsp+0x68]
    2cd7:	mov    r13,QWORD PTR [rsp+0x70]
    2cdc:	mov    r14,QWORD PTR [rsp+0x78]
    2ce1:	mov    r15,QWORD PTR [rsp+0x80]
    2ce9:	add    rsp,0x90
    2cf0:	mov    rsp,rbp
    2cf3:	pop    rbp
    2cf4:	ret
    2cf5:	mov    QWORD PTR [rsp],r13
    2cf9:	mov    QWORD PTR [rsp+0x8],r14
    2cfe:	mov    QWORD PTR [rsp+0x10],r15
    2d03:	mov    QWORD PTR [rsp+0x18],rax
    2d08:	mov    QWORD PTR [rsp+0x20],rbx
    2d0d:	add    r12,0x1
    2d14:	mov    rcx,QWORD PTR [rsp+0x40]
    2d19:	mov    rsi,r13
    2d1c:	mov    QWORD PTR [rsp+0x48],rax
    2d21:	jmp    2bb7 <botlish_fn_36+0x67>
    2d26:	mov    rax,QWORD PTR [rsp+0x48]
    2d2b:	mov    rbx,QWORD PTR [rsp+0x60]
    2d30:	mov    r12,QWORD PTR [rsp+0x68]
    2d35:	mov    r13,QWORD PTR [rsp+0x70]
    2d3a:	mov    r14,QWORD PTR [rsp+0x78]
    2d3f:	mov    r15,QWORD PTR [rsp+0x80]
    2d47:	add    rsp,0x90
    2d4e:	mov    rsp,rbp
    2d51:	pop    rbp
    2d52:	ret
    2d53:	add    BYTE PTR [rax],al
    2d55:	add    BYTE PTR [rax],al
    2d57:	add    BYTE PTR [rsi],al
    2d59:	add    BYTE PTR [rax],al
    2d5b:	add    BYTE PTR [rax],al
    2d5d:	add    BYTE PTR [rax],al
	...

0000000000002d60 <botlish_entry_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2d60:	push   rbp
    2d61:	mov    rbp,rsp
    2d64:	sub    rsp,0x10
    2d68:	mov    rsi,QWORD PTR [rdx]
    2d6b:	mov    r11,QWORD PTR [rdx+0x8]
    2d6f:	mov    rcx,QWORD PTR [rdx+0x10]
    2d73:	mov    r8,QWORD PTR [rdx+0x18]
    2d77:	mov    r9,QWORD PTR [rdx+0x20]
    2d7b:	mov    rax,QWORD PTR [rdx+0x28]
    2d7f:	mov    rdx,QWORD PTR [rdx+0x30]
    2d83:	sar    r9,1
    2d86:	mov    QWORD PTR [rsp],rax
    2d8a:	mov    QWORD PTR [rsp+0x8],rdx
    2d8f:	mov    rdx,r11
    2d92:	call   2d97 <botlish_entry_36+0x37>
			2d93: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2d97:	add    rsp,0x10
    2d9b:	mov    rsp,rbp
    2d9e:	pop    rbp
    2d9f:	ret

0000000000002da0 <botlish_fn_37: ht_rehash<HashTable, int>>:
    2da0:	push   rbp
    2da1:	mov    rbp,rsp
    2da4:	sub    rsp,0xf0
    2dab:	mov    QWORD PTR [rsp+0xc0],rbx
    2db3:	mov    QWORD PTR [rsp+0xc8],r12
    2dbb:	mov    QWORD PTR [rsp+0xd0],r13
    2dc3:	mov    QWORD PTR [rsp+0xd8],r14
    2dcb:	mov    QWORD PTR [rsp+0xe0],r15
    2dd3:	mov    QWORD PTR [rsp+0x90],rdi
    2ddb:	mov    QWORD PTR [rsp+0x20],0x0
    2de4:	mov    QWORD PTR [rsp+0x28],0x0
    2ded:	mov    QWORD PTR [rsp+0x30],0x0
    2df6:	mov    QWORD PTR [rsp+0x38],0x0
    2dff:	mov    QWORD PTR [rsp+0x40],0x0
    2e08:	mov    QWORD PTR [rsp+0x48],0x0
    2e11:	mov    QWORD PTR [rsp+0x50],0x0
    2e1a:	mov    QWORD PTR [rsp+0x10],rsi
    2e1f:	mov    r14,rsi
    2e22:	mov    QWORD PTR [rsp+0x18],rdx
    2e27:	mov    QWORD PTR [rsp+0x98],rdx
    2e2f:	lea    rdx,[rsp+0x58]
    2e34:	mov    rsi,QWORD PTR [rsp+0x98]
    2e3c:	mov    rdi,QWORD PTR [rsp+0x90]
    2e44:	call   2e49 <botlish_fn_37+0xa9>
			2e45: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    2e49:	test   rax,rax
    2e4c:	je     2fa0 <botlish_fn_37+0x200>
    2e52:	mov    QWORD PTR [rsp+0x10],rax
    2e57:	mov    QWORD PTR [rsp+0xb8],rax
    2e5f:	mov    rbx,QWORD PTR [rsp+0x58]
    2e64:	mov    QWORD PTR [rsp+0x20],rbx
    2e69:	mov    r12,QWORD PTR [rsp+0x60]
    2e6e:	mov    QWORD PTR [rsp+0x28],r12
    2e73:	mov    r13,QWORD PTR [rsp+0x68]
    2e78:	mov    QWORD PTR [rsp+0x30],r13
    2e7d:	mov    rsi,r14
    2e80:	mov    rdi,QWORD PTR [rsp+0x90]
    2e88:	call   2e8d <botlish_fn_37+0xed>
			2e89: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2e8d:	test   rax,rax
    2e90:	mov    rcx,rax
    2e93:	je     2fa0 <botlish_fn_37+0x200>
    2e99:	mov    edx,0x1
    2e9e:	mov    rsi,r13
    2ea1:	mov    rdi,QWORD PTR [rsp+0x90]
    2ea9:	call   2eae <botlish_fn_37+0x10e>
			2eaa: R_X86_64_PLT32	rt_mutarray_set-0x4
    2eae:	test   rax,rax
    2eb1:	je     2fa0 <botlish_fn_37+0x200>
    2eb7:	mov    rsi,r14
    2eba:	mov    rax,QWORD PTR [rsi+0x18]
    2ebe:	mov    rcx,QWORD PTR [rax]
    2ec1:	mov    QWORD PTR [rsp+0x38],rcx
    2ec6:	mov    QWORD PTR [rsp+0xb0],rcx
    2ece:	mov    rax,QWORD PTR [rsi+0x18]
    2ed2:	mov    r15,QWORD PTR [rax+0x8]
    2ed6:	mov    QWORD PTR [rsp+0x40],r15
    2edb:	mov    rax,QWORD PTR [rsi+0x18]
    2edf:	mov    r14,QWORD PTR [rax+0x10]
    2ee3:	mov    QWORD PTR [rsp+0x48],r14
    2ee8:	mov    r8d,0x1
    2eee:	mov    QWORD PTR [rsp+0xa8],r8
    2ef6:	mov    QWORD PTR [rsp+0x50],0x1
    2eff:	mov    rdi,QWORD PTR [rsp+0x90]
    2f07:	call   2f0c <botlish_fn_37+0x16c>
			2f08: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2f0c:	mov    QWORD PTR [rsp+0xa0],rax
    2f14:	lea    rcx,[rsp+0x70]
    2f19:	mov    rax,QWORD PTR [rsp+0xb8]
    2f21:	mov    QWORD PTR [rsp+0x70],rax
    2f26:	mov    QWORD PTR [rsp+0x78],rbx
    2f2b:	mov    QWORD PTR [rsp+0x80],r12
    2f33:	mov    QWORD PTR [rsp+0x88],r13
    2f3b:	xor    rsi,rsi
    2f3e:	mov    edx,0x4
    2f43:	mov    rdi,QWORD PTR [rsp+0x90]
    2f4b:	call   2f50 <botlish_fn_37+0x1b0>
			2f4c: R_X86_64_PLT32	rt_struct_new-0x4
    2f50:	mov    QWORD PTR [rsp+0x10],rax
    2f55:	mov    rcx,QWORD PTR [rsp+0xa0]
    2f5d:	mov    r9,rcx
    2f60:	sar    r9,1
    2f63:	mov    QWORD PTR [rsp],rax
    2f67:	mov    rdx,QWORD PTR [rsp+0x98]
    2f6f:	mov    QWORD PTR [rsp+0x8],rdx
    2f74:	mov    rcx,r14
    2f77:	mov    rdx,r15
    2f7a:	mov    rsi,QWORD PTR [rsp+0xb0]
    2f82:	mov    rdi,QWORD PTR [rsp+0x90]
    2f8a:	mov    r8,QWORD PTR [rsp+0xa8]
    2f92:	call   2f97 <botlish_fn_37+0x1f7>
			2f93: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2f97:	test   rax,rax
    2f9a:	jne    2fd7 <botlish_fn_37+0x237>
    2fa0:	xor    rax,rax
    2fa3:	mov    rbx,QWORD PTR [rsp+0xc0]
    2fab:	mov    r12,QWORD PTR [rsp+0xc8]
    2fb3:	mov    r13,QWORD PTR [rsp+0xd0]
    2fbb:	mov    r14,QWORD PTR [rsp+0xd8]
    2fc3:	mov    r15,QWORD PTR [rsp+0xe0]
    2fcb:	add    rsp,0xf0
    2fd2:	mov    rsp,rbp
    2fd5:	pop    rbp
    2fd6:	ret
    2fd7:	mov    rbx,QWORD PTR [rsp+0xc0]
    2fdf:	mov    r12,QWORD PTR [rsp+0xc8]
    2fe7:	mov    r13,QWORD PTR [rsp+0xd0]
    2fef:	mov    r14,QWORD PTR [rsp+0xd8]
    2ff7:	mov    r15,QWORD PTR [rsp+0xe0]
    2fff:	add    rsp,0xf0
    3006:	mov    rsp,rbp
    3009:	pop    rbp
    300a:	ret

000000000000300b <botlish_entry_37: ht_rehash<HashTable, int>>:
    300b:	push   rbp
    300c:	mov    rbp,rsp
    300f:	mov    rsi,QWORD PTR [rdx]
    3012:	mov    rdx,QWORD PTR [rdx+0x8]
    3016:	call   301b <botlish_entry_37+0x10>
			3017: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    301b:	mov    rsp,rbp
    301e:	pop    rbp
    301f:	ret

0000000000003020 <botlish_fn_38: ht_should_grow<HashTable>>:
    3020:	push   rbp
    3021:	mov    rbp,rsp
    3024:	sub    rsp,0x40
    3028:	mov    QWORD PTR [rsp+0x20],rbx
    302d:	mov    QWORD PTR [rsp+0x28],r12
    3032:	mov    QWORD PTR [rsp+0x30],r13
    3037:	mov    rbx,rdi
    303a:	mov    QWORD PTR [rsp],rsi
    303e:	mov    r12,rsi
    3041:	mov    rsi,r12
    3044:	mov    rdi,rbx
    3047:	call   304c <botlish_fn_38+0x2c>
			3048: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    304c:	mov    rcx,rax
    304f:	mov    r13,rax
    3052:	test   rax,rcx
    3055:	je     312e <botlish_fn_38+0x10e>
    305b:	mov    rax,r13
    305e:	mov    QWORD PTR [rsp+0x8],rax
    3063:	mov    rsi,r12
    3066:	mov    rdi,rbx
    3069:	call   306e <botlish_fn_38+0x4e>
			306a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    306e:	mov    rcx,rax
    3071:	test   rcx,rcx
    3074:	je     312e <botlish_fn_38+0x10e>
    307a:	mov    QWORD PTR [rsp+0x10],rcx
    307f:	mov    edx,0x1
    3084:	mov    rax,r13
    3087:	test   rax,0x1
    308d:	jne    30b0 <botlish_fn_38+0x90>
    3093:	xor    edx,edx
    3095:	mov    rax,r13
    3098:	test   rax,0x7
    309e:	jne    30b0 <botlish_fn_38+0x90>
    30a4:	mov    rax,r13
    30a7:	movzx  rax,BYTE PTR [rax]
    30ab:	cmp    al,0x1
    30ad:	sete   dl
    30b0:	test   dl,dl
    30b2:	jne    30d3 <botlish_fn_38+0xb3>
    30b8:	mov    rdi,rbx
    30bb:	mov    rax,QWORD PTR [rdi+0x10]
    30bf:	mov    rcx,QWORD PTR [rax+0x8]
    30c3:	xor    rdx,rdx
    30c6:	mov    rsi,r13
    30c9:	call   30ce <botlish_fn_38+0xae>
			30ca: R_X86_64_PLT32	rt_type_error-0x4
    30ce:	jmp    312e <botlish_fn_38+0x10e>
    30d3:	mov    eax,0x1
    30d8:	test   rcx,0x1
    30df:	je     30ed <botlish_fn_38+0xcd>
    30e5:	mov    r8,rcx
    30e8:	jmp    3110 <botlish_fn_38+0xf0>
    30ed:	xor    eax,eax
    30ef:	test   rcx,0x7
    30f6:	je     3104 <botlish_fn_38+0xe4>
    30fc:	mov    r8,rcx
    30ff:	jmp    3110 <botlish_fn_38+0xf0>
    3104:	movzx  rax,BYTE PTR [rcx]
    3108:	mov    r8,rcx
    310b:	cmp    al,0x1
    310d:	sete   al
    3110:	test   al,al
    3112:	jne    3149 <botlish_fn_38+0x129>
    3118:	mov    rdi,rbx
    311b:	mov    rax,QWORD PTR [rdi+0x10]
    311f:	mov    rcx,QWORD PTR [rax+0x8]
    3123:	xor    rdx,rdx
    3126:	mov    rsi,r8
    3129:	call   312e <botlish_fn_38+0x10e>
			312a: R_X86_64_PLT32	rt_type_error-0x4
    312e:	xor    rax,rax
    3131:	mov    rbx,QWORD PTR [rsp+0x20]
    3136:	mov    r12,QWORD PTR [rsp+0x28]
    313b:	mov    r13,QWORD PTR [rsp+0x30]
    3140:	add    rsp,0x40
    3144:	mov    rsp,rbp
    3147:	pop    rbp
    3148:	ret
    3149:	mov    rcx,r8
    314c:	mov    rsi,r13
    314f:	mov    rax,rsi
    3152:	and    rax,rcx
    3155:	test   rax,0x1
    315b:	jne    316c <botlish_fn_38+0x14c>
    3161:	mov    rdx,r8
    3164:	mov    rsi,r13
    3167:	jmp    318a <botlish_fn_38+0x16a>
    316c:	mov    rcx,r8
    316f:	lea    rax,[rcx-0x1]
    3173:	mov    rsi,r13
    3176:	add    rsi,rax
    3179:	seto   al
    317c:	test   al,al
    317e:	je     3195 <botlish_fn_38+0x175>
    3184:	mov    rdx,r8
    3187:	mov    rsi,r13
    318a:	mov    rdi,rbx
    318d:	call   3192 <botlish_fn_38+0x172>
			318e: R_X86_64_PLT32	rt_int_add-0x4
    3192:	mov    rsi,rax
    3195:	mov    QWORD PTR [rsp+0x8],rsi
    319a:	mov    QWORD PTR [rsp+0x10],0x3
    31a3:	test   rsi,0x1
    31aa:	je     31cd <botlish_fn_38+0x1ad>
    31b0:	mov    rax,rsi
    31b3:	add    rax,0x2
    31b7:	mov    rcx,rax
    31ba:	seto   al
    31bd:	test   al,al
    31bf:	jne    31cd <botlish_fn_38+0x1ad>
    31c5:	mov    rsi,rcx
    31c8:	jmp    31dd <botlish_fn_38+0x1bd>
    31cd:	mov    edx,0x3
    31d2:	mov    rdi,rbx
    31d5:	call   31da <botlish_fn_38+0x1ba>
			31d6: R_X86_64_PLT32	rt_int_add-0x4
    31da:	mov    rsi,rax
    31dd:	mov    QWORD PTR [rsp+0x8],rsi
    31e2:	mov    edx,0x7
    31e7:	mov    rdi,rdx
    31ea:	mov    QWORD PTR [rsp+0x10],0x7
    31f3:	test   rsi,0x1
    31fa:	jne    3208 <botlish_fn_38+0x1e8>
    3200:	mov    rdx,rdi
    3203:	jmp    3234 <botlish_fn_38+0x214>
    3208:	mov    rax,rsi
    320b:	sar    rax,1
    320e:	imul   QWORD PTR [rip+0xf3]        # 3308 <botlish_fn_38+0x2e8>
    3215:	seto   cl
    3218:	or     rax,0x1
    321c:	test   cl,cl
    321e:	je     322c <botlish_fn_38+0x20c>
    3224:	mov    rdx,rdi
    3227:	jmp    3234 <botlish_fn_38+0x214>
    322c:	mov    rsi,rax
    322f:	jmp    323f <botlish_fn_38+0x21f>
    3234:	mov    rdi,rbx
    3237:	call   323c <botlish_fn_38+0x21c>
			3238: R_X86_64_PLT32	rt_int_mul-0x4
    323c:	mov    rsi,rax
    323f:	mov    QWORD PTR [rsp],rsi
    3243:	mov    r13,rsi
    3246:	mov    rsi,r12
    3249:	mov    rdi,rbx
    324c:	call   3251 <botlish_fn_38+0x231>
			324d: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3251:	mov    QWORD PTR [rsp+0x8],rax
    3256:	mov    QWORD PTR [rsp+0x10],0x5
    325f:	test   rax,0x1
    3265:	mov    rcx,rax
    3268:	je     3297 <botlish_fn_38+0x277>
    326e:	mov    rax,rcx
    3271:	sar    rax,1
    3274:	imul   QWORD PTR [rip+0x95]        # 3310 <botlish_fn_38+0x2f0>
    327b:	seto   sil
    327f:	or     rax,0x1
    3283:	test   sil,sil
    3286:	jne    3297 <botlish_fn_38+0x277>
    328c:	mov    rdx,rax
    328f:	mov    rsi,r13
    3292:	jmp    32ad <botlish_fn_38+0x28d>
    3297:	mov    edx,0x5
    329c:	mov    rsi,rcx
    329f:	mov    rdi,rbx
    32a2:	call   32a7 <botlish_fn_38+0x287>
			32a3: R_X86_64_PLT32	rt_int_mul-0x4
    32a7:	mov    rdx,rax
    32aa:	mov    rsi,r13
    32ad:	mov    rdi,rsi
    32b0:	and    rdi,rdx
    32b3:	test   rdi,0x1
    32ba:	jne    32e0 <botlish_fn_38+0x2c0>
    32c0:	mov    rdi,rbx
    32c3:	call   32c8 <botlish_fn_38+0x2a8>
			32c4: R_X86_64_PLT32	rt_int_cmp-0x4
    32c8:	mov    esi,0x2
    32cd:	test   rax,rax
    32d0:	mov    rax,rsi
    32d3:	cmovg  rax,QWORD PTR [rip+0x2d]        # 3308 <botlish_fn_38+0x2e8>
    32db:	jmp    32f0 <botlish_fn_38+0x2d0>
    32e0:	mov    eax,0x2
    32e5:	cmp    rsi,rdx
    32e8:	cmovg  rax,QWORD PTR [rip+0x18]        # 3308 <botlish_fn_38+0x2e8>
    32f0:	mov    rbx,QWORD PTR [rsp+0x20]
    32f5:	mov    r12,QWORD PTR [rsp+0x28]
    32fa:	mov    r13,QWORD PTR [rsp+0x30]
    32ff:	add    rsp,0x40
    3303:	mov    rsp,rbp
    3306:	pop    rbp
    3307:	ret
    3308:	(bad)
    3309:	add    BYTE PTR [rax],al
    330b:	add    BYTE PTR [rax],al
    330d:	add    BYTE PTR [rax],al
    330f:	add    BYTE PTR [rax+rax*1],al
    3312:	add    BYTE PTR [rax],al
    3314:	add    BYTE PTR [rax],al
	...

0000000000003318 <botlish_entry_38: ht_should_grow<HashTable>>:
    3318:	push   rbp
    3319:	mov    rbp,rsp
    331c:	mov    rsi,QWORD PTR [rdx]
    331f:	call   3324 <botlish_entry_38+0xc>
			3320: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    3324:	mov    rsp,rbp
    3327:	pop    rbp
    3328:	ret
    3329:	add    BYTE PTR [rax],al
    332b:	add    BYTE PTR [rax],al
    332d:	add    BYTE PTR [rax],al
	...

0000000000003330 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    3330:	push   rbp
    3331:	mov    rbp,rsp
    3334:	sub    rsp,0x40
    3338:	mov    QWORD PTR [rsp+0x20],rbx
    333d:	mov    QWORD PTR [rsp+0x28],r12
    3342:	mov    QWORD PTR [rsp+0x30],r13
    3347:	mov    rbx,rdi
    334a:	mov    QWORD PTR [rsp+0x10],0x0
    3353:	mov    QWORD PTR [rsp],rsi
    3357:	mov    r12,rsi
    335a:	mov    rsi,r12
    335d:	mov    rdi,rbx
    3360:	call   3365 <botlish_fn_39+0x35>
			3361: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3365:	test   rax,rax
    3368:	mov    r13,rax
    336b:	je     3559 <botlish_fn_39+0x229>
    3371:	mov    rsi,r12
    3374:	mov    rdi,rbx
    3377:	call   337c <botlish_fn_39+0x4c>
			3378: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    337c:	mov    r11,rax
    337f:	test   r11,r11
    3382:	je     3559 <botlish_fn_39+0x229>
    3388:	mov    ecx,0x1
    338d:	mov    rax,r13
    3390:	test   rax,0x1
    3396:	je     33a4 <botlish_fn_39+0x74>
    339c:	mov    r13,rax
    339f:	jmp    33c8 <botlish_fn_39+0x98>
    33a4:	xor    ecx,ecx
    33a6:	test   rax,0x7
    33ac:	je     33ba <botlish_fn_39+0x8a>
    33b2:	mov    r13,rax
    33b5:	jmp    33c8 <botlish_fn_39+0x98>
    33ba:	movzx  rcx,BYTE PTR [rax]
    33be:	mov    r13,rax
    33c1:	rex cmp cl,0x1
    33c5:	sete   cl
    33c8:	test   cl,cl
    33ca:	jne    33eb <botlish_fn_39+0xbb>
    33d0:	mov    rdi,rbx
    33d3:	mov    rsi,QWORD PTR [rdi+0x10]
    33d7:	mov    rcx,QWORD PTR [rsi+0x10]
    33db:	xor    rdx,rdx
    33de:	mov    rsi,r13
    33e1:	call   33e6 <botlish_fn_39+0xb6>
			33e2: R_X86_64_PLT32	rt_type_error-0x4
    33e6:	jmp    3559 <botlish_fn_39+0x229>
    33eb:	mov    rsi,r13
    33ee:	mov    eax,0x1
    33f3:	test   r11,0x1
    33fa:	je     3408 <botlish_fn_39+0xd8>
    3400:	mov    r8,r11
    3403:	jmp    342d <botlish_fn_39+0xfd>
    3408:	xor    eax,eax
    340a:	test   r11,0x7
    3411:	je     341f <botlish_fn_39+0xef>
    3417:	mov    r8,r11
    341a:	jmp    342d <botlish_fn_39+0xfd>
    341f:	movzx  r10,BYTE PTR [r11]
    3423:	mov    r8,r11
    3426:	cmp    r10b,0x1
    342a:	sete   al
    342d:	test   al,al
    342f:	jne    3450 <botlish_fn_39+0x120>
    3435:	mov    rdi,rbx
    3438:	mov    rax,QWORD PTR [rdi+0x10]
    343c:	mov    rcx,QWORD PTR [rax+0x10]
    3440:	xor    rdx,rdx
    3443:	mov    rsi,r8
    3446:	call   344b <botlish_fn_39+0x11b>
			3447: R_X86_64_PLT32	rt_type_error-0x4
    344b:	jmp    3559 <botlish_fn_39+0x229>
    3450:	mov    r11,r8
    3453:	mov    rax,rsi
    3456:	and    rax,r11
    3459:	test   rax,0x1
    345f:	jne    3485 <botlish_fn_39+0x155>
    3465:	mov    rdx,r8
    3468:	mov    rdi,rbx
    346b:	call   3470 <botlish_fn_39+0x140>
			346c: R_X86_64_PLT32	rt_int_cmp-0x4
    3470:	mov    ecx,0x2
    3475:	test   rax,rax
    3478:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3590 <botlish_fn_39+0x260>
    3480:	jmp    3498 <botlish_fn_39+0x168>
    3485:	mov    ecx,0x2
    348a:	mov    r11,r8
    348d:	cmp    rsi,r11
    3490:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3590 <botlish_fn_39+0x260>
    3498:	cmp    rcx,0x6
    349c:	je     3532 <botlish_fn_39+0x202>
    34a2:	mov    rsi,r12
    34a5:	mov    rdi,rbx
    34a8:	call   34ad <botlish_fn_39+0x17d>
			34a9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    34ad:	mov    QWORD PTR [rsp+0x8],rax
    34b2:	mov    QWORD PTR [rsp+0x10],0x5
    34bb:	test   rax,0x1
    34c1:	mov    rsi,rax
    34c4:	je     34f1 <botlish_fn_39+0x1c1>
    34ca:	mov    rcx,rsi
    34cd:	mov    rax,rcx
    34d0:	sar    rax,1
    34d3:	imul   QWORD PTR [rip+0xbe]        # 3598 <botlish_fn_39+0x268>
    34da:	seto   cl
    34dd:	or     rax,0x1
    34e1:	test   cl,cl
    34e3:	jne    34f1 <botlish_fn_39+0x1c1>
    34e9:	mov    rdx,rax
    34ec:	jmp    3501 <botlish_fn_39+0x1d1>
    34f1:	mov    edx,0x5
    34f6:	mov    rdi,rbx
    34f9:	call   34fe <botlish_fn_39+0x1ce>
			34fa: R_X86_64_PLT32	rt_int_mul-0x4
    34fe:	mov    rdx,rax
    3501:	mov    QWORD PTR [rsp+0x8],rdx
    3506:	mov    rsi,r12
    3509:	mov    rdi,rbx
    350c:	call   3511 <botlish_fn_39+0x1e1>
			350d: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3511:	test   rax,rax
    3514:	je     3559 <botlish_fn_39+0x229>
    351a:	mov    rbx,QWORD PTR [rsp+0x20]
    351f:	mov    r12,QWORD PTR [rsp+0x28]
    3524:	mov    r13,QWORD PTR [rsp+0x30]
    3529:	add    rsp,0x40
    352d:	mov    rsp,rbp
    3530:	pop    rbp
    3531:	ret
    3532:	mov    rsi,r12
    3535:	mov    rdi,rbx
    3538:	call   353d <botlish_fn_39+0x20d>
			3539: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    353d:	mov    QWORD PTR [rsp+0x8],rax
    3542:	mov    rdx,rax
    3545:	mov    rsi,r12
    3548:	mov    rdi,rbx
    354b:	call   3550 <botlish_fn_39+0x220>
			354c: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3550:	test   rax,rax
    3553:	jne    3574 <botlish_fn_39+0x244>
    3559:	xor    rax,rax
    355c:	mov    rbx,QWORD PTR [rsp+0x20]
    3561:	mov    r12,QWORD PTR [rsp+0x28]
    3566:	mov    r13,QWORD PTR [rsp+0x30]
    356b:	add    rsp,0x40
    356f:	mov    rsp,rbp
    3572:	pop    rbp
    3573:	ret
    3574:	mov    rbx,QWORD PTR [rsp+0x20]
    3579:	mov    r12,QWORD PTR [rsp+0x28]
    357e:	mov    r13,QWORD PTR [rsp+0x30]
    3583:	add    rsp,0x40
    3587:	mov    rsp,rbp
    358a:	pop    rbp
    358b:	ret
    358c:	add    BYTE PTR [rax],al
    358e:	add    BYTE PTR [rax],al
    3590:	(bad)
    3591:	add    BYTE PTR [rax],al
    3593:	add    BYTE PTR [rax],al
    3595:	add    BYTE PTR [rax],al
    3597:	add    BYTE PTR [rax+rax*1],al
    359a:	add    BYTE PTR [rax],al
    359c:	add    BYTE PTR [rax],al
	...

00000000000035a0 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    35a0:	push   rbp
    35a1:	mov    rbp,rsp
    35a4:	mov    rsi,QWORD PTR [rdx]
    35a7:	call   35ac <botlish_entry_39+0xc>
			35a8: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    35ac:	mov    rsp,rbp
    35af:	pop    rbp
    35b0:	ret
    35b1:	add    BYTE PTR [rax],al
    35b3:	add    BYTE PTR [rax],al
    35b5:	add    BYTE PTR [rax],al
	...

00000000000035b8 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    35b8:	push   rbp
    35b9:	mov    rbp,rsp
    35bc:	sub    rsp,0x70
    35c0:	mov    QWORD PTR [rsp+0x40],rbx
    35c5:	mov    QWORD PTR [rsp+0x48],r12
    35ca:	mov    QWORD PTR [rsp+0x50],r13
    35cf:	mov    QWORD PTR [rsp+0x58],r14
    35d4:	mov    QWORD PTR [rsp+0x60],r15
    35d9:	mov    r12,rdi
    35dc:	mov    r14,r8
    35df:	mov    r15,rdx
    35e2:	mov    QWORD PTR [rsp+0x30],rcx
    35e7:	mov    QWORD PTR [rsp],rsi
    35eb:	mov    r9,QWORD PTR [rsi+0x18]
    35ef:	mov    r13,rsi
    35f2:	mov    rsi,QWORD PTR [r9]
    35f5:	mov    rdx,r15
    35f8:	mov    rdi,r12
    35fb:	call   3600 <botlish_fn_40+0x48>
			35fc: R_X86_64_PLT32	rt_mutarray_get-0x4
    3600:	test   rax,rax
    3603:	je     3898 <botlish_fn_40+0x2e0>
    3609:	mov    QWORD PTR [rsp+0x8],rax
    360e:	mov    rbx,r13
    3611:	mov    r13,rax
    3614:	mov    rax,QWORD PTR [rbx+0x18]
    3618:	mov    rsi,QWORD PTR [rax]
    361b:	mov    ecx,0x3
    3620:	mov    rdx,r15
    3623:	mov    rdi,r12
    3626:	call   362b <botlish_fn_40+0x73>
			3627: R_X86_64_PLT32	rt_mutarray_set-0x4
    362b:	test   rax,rax
    362e:	je     3898 <botlish_fn_40+0x2e0>
    3634:	mov    rax,QWORD PTR [rbx+0x18]
    3638:	mov    rsi,QWORD PTR [rax+0x8]
    363c:	mov    rcx,QWORD PTR [rsp+0x30]
    3641:	mov    rdx,r15
    3644:	mov    rdi,r12
    3647:	call   364c <botlish_fn_40+0x94>
			3648: R_X86_64_PLT32	rt_mutarray_set-0x4
    364c:	test   rax,rax
    364f:	je     3898 <botlish_fn_40+0x2e0>
    3655:	mov    rax,QWORD PTR [rbx+0x18]
    3659:	mov    rsi,QWORD PTR [rax+0x10]
    365d:	mov    rcx,r14
    3660:	mov    rdx,r15
    3663:	mov    rdi,r12
    3666:	call   366b <botlish_fn_40+0xb3>
			3667: R_X86_64_PLT32	rt_mutarray_set-0x4
    366b:	test   rax,rax
    366e:	je     3898 <botlish_fn_40+0x2e0>
    3674:	mov    rax,QWORD PTR [rbx+0x18]
    3678:	mov    rsi,QWORD PTR [rax+0x18]
    367c:	mov    QWORD PTR [rsp+0x10],rsi
    3681:	mov    r14,rsi
    3684:	mov    QWORD PTR [rsp+0x18],0x1
    368d:	mov    rsi,rbx
    3690:	mov    rdi,r12
    3693:	call   3698 <botlish_fn_40+0xe0>
			3694: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3698:	test   rax,rax
    369b:	je     3898 <botlish_fn_40+0x2e0>
    36a1:	mov    QWORD PTR [rsp+0x20],rax
    36a6:	mov    QWORD PTR [rsp+0x28],0x3
    36af:	mov    ecx,0x1
    36b4:	test   rax,0x1
    36ba:	je     36c8 <botlish_fn_40+0x110>
    36c0:	mov    rsi,rax
    36c3:	jmp    36ec <botlish_fn_40+0x134>
    36c8:	xor    ecx,ecx
    36ca:	test   rax,0x7
    36d0:	je     36de <botlish_fn_40+0x126>
    36d6:	mov    rsi,rax
    36d9:	jmp    36ec <botlish_fn_40+0x134>
    36de:	movzx  rcx,BYTE PTR [rax]
    36e2:	mov    rsi,rax
    36e5:	rex cmp cl,0x1
    36e9:	sete   cl
    36ec:	test   cl,cl
    36ee:	jne    370c <botlish_fn_40+0x154>
    36f4:	mov    rdi,r12
    36f7:	mov    rax,QWORD PTR [rdi+0x10]
    36fb:	mov    rcx,QWORD PTR [rax+0x8]
    36ff:	xor    rdx,rdx
    3702:	call   3707 <botlish_fn_40+0x14f>
			3703: R_X86_64_PLT32	rt_type_error-0x4
    3707:	jmp    3898 <botlish_fn_40+0x2e0>
    370c:	test   rsi,0x1
    3713:	je     372b <botlish_fn_40+0x173>
    3719:	mov    rcx,rsi
    371c:	add    rcx,0x2
    3720:	seto   al
    3723:	test   al,al
    3725:	je     373b <botlish_fn_40+0x183>
    372b:	mov    edx,0x3
    3730:	mov    rdi,r12
    3733:	call   3738 <botlish_fn_40+0x180>
			3734: R_X86_64_PLT32	rt_int_add-0x4
    3738:	mov    rcx,rax
    373b:	mov    edx,0x1
    3740:	mov    rsi,r14
    3743:	mov    rdi,r12
    3746:	call   374b <botlish_fn_40+0x193>
			3747: R_X86_64_PLT32	rt_mutarray_set-0x4
    374b:	test   rax,rax
    374e:	je     3898 <botlish_fn_40+0x2e0>
    3754:	mov    rax,r13
    3757:	test   rax,0x1
    375d:	jne    3788 <botlish_fn_40+0x1d0>
    3763:	mov    edx,0x5
    3768:	mov    rsi,r13
    376b:	mov    rdi,r12
    376e:	call   3773 <botlish_fn_40+0x1bb>
			376f: R_X86_64_PLT32	rt_int_cmp-0x4
    3773:	mov    ecx,0x2
    3778:	test   rax,rax
    377b:	cmove  rcx,QWORD PTR [rip+0x165]        # 38e8 <botlish_fn_40+0x330>
    3783:	jmp    379c <botlish_fn_40+0x1e4>
    3788:	mov    rsi,r13
    378b:	mov    ecx,0x2
    3790:	cmp    rsi,0x5
    3794:	cmove  rcx,QWORD PTR [rip+0x14c]        # 38e8 <botlish_fn_40+0x330>
    379c:	cmp    rcx,0x6
    37a0:	je     37ae <botlish_fn_40+0x1f6>
    37a6:	mov    rax,rbx
    37a9:	jmp    38c0 <botlish_fn_40+0x308>
    37ae:	mov    rax,QWORD PTR [rbx+0x18]
    37b2:	mov    rsi,QWORD PTR [rax+0x18]
    37b6:	mov    QWORD PTR [rsp+0x8],rsi
    37bb:	mov    r14,rsi
    37be:	mov    QWORD PTR [rsp+0x10],0x3
    37c7:	mov    rsi,rbx
    37ca:	mov    rdi,r12
    37cd:	call   37d2 <botlish_fn_40+0x21a>
			37ce: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    37d2:	mov    r13,rbx
    37d5:	test   rax,rax
    37d8:	je     3898 <botlish_fn_40+0x2e0>
    37de:	mov    QWORD PTR [rsp+0x18],rax
    37e3:	mov    QWORD PTR [rsp+0x20],0x3
    37ec:	mov    ecx,0x1
    37f1:	test   rax,0x1
    37f7:	je     3805 <botlish_fn_40+0x24d>
    37fd:	mov    rsi,rax
    3800:	jmp    3829 <botlish_fn_40+0x271>
    3805:	xor    ecx,ecx
    3807:	test   rax,0x7
    380d:	je     381b <botlish_fn_40+0x263>
    3813:	mov    rsi,rax
    3816:	jmp    3829 <botlish_fn_40+0x271>
    381b:	movzx  r10,BYTE PTR [rax]
    381f:	mov    rsi,rax
    3822:	cmp    r10b,0x1
    3826:	sete   cl
    3829:	test   cl,cl
    382b:	jne    3849 <botlish_fn_40+0x291>
    3831:	mov    rdi,r12
    3834:	mov    rax,QWORD PTR [rdi+0x10]
    3838:	mov    rcx,QWORD PTR [rax+0x18]
    383c:	xor    rdx,rdx
    383f:	call   3844 <botlish_fn_40+0x28c>
			3840: R_X86_64_PLT32	rt_type_error-0x4
    3844:	jmp    3898 <botlish_fn_40+0x2e0>
    3849:	test   rsi,0x1
    3850:	je     386f <botlish_fn_40+0x2b7>
    3856:	mov    rcx,rsi
    3859:	sub    rcx,0x3
    385d:	seto   al
    3860:	add    rcx,0x1
    3867:	test   al,al
    3869:	je     387f <botlish_fn_40+0x2c7>
    386f:	mov    edx,0x3
    3874:	mov    rdi,r12
    3877:	call   387c <botlish_fn_40+0x2c4>
			3878: R_X86_64_PLT32	rt_int_sub-0x4
    387c:	mov    rcx,rax
    387f:	mov    edx,0x3
    3884:	mov    rsi,r14
    3887:	mov    rdi,r12
    388a:	call   388f <botlish_fn_40+0x2d7>
			388b: R_X86_64_PLT32	rt_mutarray_set-0x4
    388f:	test   rax,rax
    3892:	jne    38bd <botlish_fn_40+0x305>
    3898:	xor    rax,rax
    389b:	mov    rbx,QWORD PTR [rsp+0x40]
    38a0:	mov    r12,QWORD PTR [rsp+0x48]
    38a5:	mov    r13,QWORD PTR [rsp+0x50]
    38aa:	mov    r14,QWORD PTR [rsp+0x58]
    38af:	mov    r15,QWORD PTR [rsp+0x60]
    38b4:	add    rsp,0x70
    38b8:	mov    rsp,rbp
    38bb:	pop    rbp
    38bc:	ret
    38bd:	mov    rax,r13
    38c0:	mov    rbx,QWORD PTR [rsp+0x40]
    38c5:	mov    r12,QWORD PTR [rsp+0x48]
    38ca:	mov    r13,QWORD PTR [rsp+0x50]
    38cf:	mov    r14,QWORD PTR [rsp+0x58]
    38d4:	mov    r15,QWORD PTR [rsp+0x60]
    38d9:	add    rsp,0x70
    38dd:	mov    rsp,rbp
    38e0:	pop    rbp
    38e1:	ret
    38e2:	add    BYTE PTR [rax],al
    38e4:	add    BYTE PTR [rax],al
    38e6:	add    BYTE PTR [rax],al
    38e8:	(bad)
    38e9:	add    BYTE PTR [rax],al
    38eb:	add    BYTE PTR [rax],al
    38ed:	add    BYTE PTR [rax],al
	...

00000000000038f0 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    38f0:	push   rbp
    38f1:	mov    rbp,rsp
    38f4:	mov    rsi,QWORD PTR [rdx]
    38f7:	mov    r9,QWORD PTR [rdx+0x8]
    38fb:	mov    rcx,QWORD PTR [rdx+0x10]
    38ff:	mov    r8,QWORD PTR [rdx+0x18]
    3903:	mov    rdx,r9
    3906:	call   390b <botlish_entry_40+0x1b>
			3907: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    390b:	mov    rsp,rbp
    390e:	pop    rbp
    390f:	ret

0000000000003910 <botlish_fn_41: ht_set<HashTable, str, str>>:
    3910:	push   rbp
    3911:	mov    rbp,rsp
    3914:	sub    rsp,0x60
    3918:	mov    QWORD PTR [rsp+0x30],rbx
    391d:	mov    QWORD PTR [rsp+0x38],r12
    3922:	mov    QWORD PTR [rsp+0x40],r13
    3927:	mov    QWORD PTR [rsp+0x48],r14
    392c:	mov    QWORD PTR [rsp+0x50],r15
    3931:	mov    r12,rdi
    3934:	mov    r13,rdx
    3937:	mov    QWORD PTR [rsp],rsi
    393b:	mov    r14,rsi
    393e:	mov    QWORD PTR [rsp+0x8],rdx
    3943:	mov    QWORD PTR [rsp+0x10],rcx
    3948:	mov    rbx,rcx
    394b:	mov    rdx,r13
    394e:	mov    rsi,r14
    3951:	mov    rdi,r12
    3954:	call   3959 <botlish_fn_41+0x49>
			3955: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3959:	test   rax,rax
    395c:	je     3b34 <botlish_fn_41+0x224>
    3962:	mov    QWORD PTR [rsp+0x18],rax
    3967:	mov    rcx,rax
    396a:	mov    r8,0xffffffffffffffff
    3971:	mov    r15,r8
    3974:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    397d:	mov    rdx,r13
    3980:	mov    rsi,r14
    3983:	mov    rdi,r12
    3986:	call   398b <botlish_fn_41+0x7b>
			3987: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    398b:	test   rax,rax
    398e:	je     3b34 <botlish_fn_41+0x224>
    3994:	mov    QWORD PTR [rsp+0x18],rax
    3999:	mov    rsi,r14
    399c:	mov    QWORD PTR [rsp+0x28],rax
    39a1:	mov    rax,QWORD PTR [rsi+0x18]
    39a5:	mov    rsi,QWORD PTR [rax]
    39a8:	mov    rdx,QWORD PTR [rsp+0x28]
    39ad:	mov    rdi,r12
    39b0:	call   39b5 <botlish_fn_41+0xa5>
			39b1: R_X86_64_PLT32	rt_mutarray_get-0x4
    39b5:	test   rax,rax
    39b8:	je     3b34 <botlish_fn_41+0x224>
    39be:	test   rax,0x1
    39c4:	mov    rsi,rax
    39c7:	jne    39ef <botlish_fn_41+0xdf>
    39cd:	mov    edx,0x3
    39d2:	mov    rdi,r12
    39d5:	call   39da <botlish_fn_41+0xca>
			39d6: R_X86_64_PLT32	rt_int_cmp-0x4
    39da:	mov    ecx,0x2
    39df:	test   rax,rax
    39e2:	cmove  rcx,QWORD PTR [rip+0x196]        # 3b80 <botlish_fn_41+0x270>
    39ea:	jmp    3a00 <botlish_fn_41+0xf0>
    39ef:	mov    ecx,0x2
    39f4:	cmp    rsi,0x3
    39f8:	cmove  rcx,QWORD PTR [rip+0x180]        # 3b80 <botlish_fn_41+0x270>
    3a00:	cmp    rcx,0x6
    3a04:	je     3b10 <botlish_fn_41+0x200>
    3a0a:	mov    rsi,r14
    3a0d:	mov    rdi,r12
    3a10:	call   3a15 <botlish_fn_41+0x105>
			3a11: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    3a15:	test   rax,rax
    3a18:	je     3b34 <botlish_fn_41+0x224>
    3a1e:	cmp    rax,0x6
    3a22:	je     3a69 <botlish_fn_41+0x159>
    3a28:	mov    rcx,r13
    3a2b:	mov    rdx,QWORD PTR [rsp+0x28]
    3a30:	mov    rsi,r14
    3a33:	mov    rdi,r12
    3a36:	mov    r8,rbx
    3a39:	call   3a3e <botlish_fn_41+0x12e>
			3a3a: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3a3e:	test   rax,rax
    3a41:	je     3b34 <botlish_fn_41+0x224>
    3a47:	mov    rbx,QWORD PTR [rsp+0x30]
    3a4c:	mov    r12,QWORD PTR [rsp+0x38]
    3a51:	mov    r13,QWORD PTR [rsp+0x40]
    3a56:	mov    r14,QWORD PTR [rsp+0x48]
    3a5b:	mov    r15,QWORD PTR [rsp+0x50]
    3a60:	add    rsp,0x60
    3a64:	mov    rsp,rbp
    3a67:	pop    rbp
    3a68:	ret
    3a69:	mov    rsi,r14
    3a6c:	mov    rdi,r12
    3a6f:	call   3a74 <botlish_fn_41+0x164>
			3a70: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3a74:	mov    rcx,rax
    3a77:	mov    r14,rax
    3a7a:	test   rax,rcx
    3a7d:	je     3b34 <botlish_fn_41+0x224>
    3a83:	mov    rax,r14
    3a86:	mov    QWORD PTR [rsp],rax
    3a8a:	mov    rdx,r13
    3a8d:	mov    rsi,r14
    3a90:	mov    rdi,r12
    3a93:	call   3a98 <botlish_fn_41+0x188>
			3a94: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3a98:	test   rax,rax
    3a9b:	je     3b34 <botlish_fn_41+0x224>
    3aa1:	mov    QWORD PTR [rsp+0x18],rax
    3aa6:	mov    rcx,rax
    3aa9:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3ab2:	mov    r8,r15
    3ab5:	mov    rdx,r13
    3ab8:	mov    rsi,r14
    3abb:	mov    rdi,r12
    3abe:	call   3ac3 <botlish_fn_41+0x1b3>
			3abf: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3ac3:	test   rax,rax
    3ac6:	je     3b34 <botlish_fn_41+0x224>
    3acc:	mov    QWORD PTR [rsp+0x18],rax
    3ad1:	mov    rcx,r13
    3ad4:	mov    rdx,rax
    3ad7:	mov    rsi,r14
    3ada:	mov    rdi,r12
    3add:	mov    r8,rbx
    3ae0:	call   3ae5 <botlish_fn_41+0x1d5>
			3ae1: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3ae5:	test   rax,rax
    3ae8:	je     3b34 <botlish_fn_41+0x224>
    3aee:	mov    rbx,QWORD PTR [rsp+0x30]
    3af3:	mov    r12,QWORD PTR [rsp+0x38]
    3af8:	mov    r13,QWORD PTR [rsp+0x40]
    3afd:	mov    r14,QWORD PTR [rsp+0x48]
    3b02:	mov    r15,QWORD PTR [rsp+0x50]
    3b07:	add    rsp,0x60
    3b0b:	mov    rsp,rbp
    3b0e:	pop    rbp
    3b0f:	ret
    3b10:	mov    rdx,QWORD PTR [rsp+0x28]
    3b15:	mov    rsi,r14
    3b18:	mov    rax,QWORD PTR [rsi+0x18]
    3b1c:	mov    rsi,QWORD PTR [rax+0x10]
    3b20:	mov    rcx,rbx
    3b23:	mov    rdi,r12
    3b26:	call   3b2b <botlish_fn_41+0x21b>
			3b27: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b2b:	test   rax,rax
    3b2e:	jne    3b59 <botlish_fn_41+0x249>
    3b34:	xor    rax,rax
    3b37:	mov    rbx,QWORD PTR [rsp+0x30]
    3b3c:	mov    r12,QWORD PTR [rsp+0x38]
    3b41:	mov    r13,QWORD PTR [rsp+0x40]
    3b46:	mov    r14,QWORD PTR [rsp+0x48]
    3b4b:	mov    r15,QWORD PTR [rsp+0x50]
    3b50:	add    rsp,0x60
    3b54:	mov    rsp,rbp
    3b57:	pop    rbp
    3b58:	ret
    3b59:	mov    rax,r14
    3b5c:	mov    rbx,QWORD PTR [rsp+0x30]
    3b61:	mov    r12,QWORD PTR [rsp+0x38]
    3b66:	mov    r13,QWORD PTR [rsp+0x40]
    3b6b:	mov    r14,QWORD PTR [rsp+0x48]
    3b70:	mov    r15,QWORD PTR [rsp+0x50]
    3b75:	add    rsp,0x60
    3b79:	mov    rsp,rbp
    3b7c:	pop    rbp
    3b7d:	ret
    3b7e:	add    BYTE PTR [rax],al
    3b80:	(bad)
    3b81:	add    BYTE PTR [rax],al
    3b83:	add    BYTE PTR [rax],al
    3b85:	add    BYTE PTR [rax],al
	...

0000000000003b88 <botlish_entry_41: ht_set<HashTable, str, str>>:
    3b88:	push   rbp
    3b89:	mov    rbp,rsp
    3b8c:	mov    rsi,QWORD PTR [rdx]
    3b8f:	mov    r8,QWORD PTR [rdx+0x8]
    3b93:	mov    rcx,QWORD PTR [rdx+0x10]
    3b97:	mov    rdx,r8
    3b9a:	call   3b9f <botlish_entry_41+0x17>
			3b9b: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3b9f:	mov    rsp,rbp
    3ba2:	pop    rbp
    3ba3:	ret

0000000000003ba4 <botlish_fn_42: row_new<bool, int>>:
    3ba4:	push   rbp
    3ba5:	mov    rbp,rsp
    3ba8:	sub    rsp,0x10
    3bac:	mov    QWORD PTR [rsp],rdx
    3bb0:	mov    r8,rdx
    3bb3:	cmp    rsi,0x6
    3bb7:	je     3bd4 <botlish_fn_42+0x30>
    3bbd:	call   3bc2 <botlish_fn_42+0x1e>
			3bbe: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    3bc2:	test   rax,rax
    3bc5:	je     3be5 <botlish_fn_42+0x41>
    3bcb:	add    rsp,0x10
    3bcf:	mov    rsp,rbp
    3bd2:	pop    rbp
    3bd3:	ret
    3bd4:	mov    rsi,r8
    3bd7:	call   3bdc <botlish_fn_42+0x38>
			3bd8: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    3bdc:	test   rax,rax
    3bdf:	jne    3bf1 <botlish_fn_42+0x4d>
    3be5:	xor    rax,rax
    3be8:	add    rsp,0x10
    3bec:	mov    rsp,rbp
    3bef:	pop    rbp
    3bf0:	ret
    3bf1:	add    rsp,0x10
    3bf5:	mov    rsp,rbp
    3bf8:	pop    rbp
    3bf9:	ret

0000000000003bfa <botlish_entry_42: row_new<bool, int>>:
    3bfa:	push   rbp
    3bfb:	mov    rbp,rsp
    3bfe:	mov    rsi,QWORD PTR [rdx]
    3c01:	mov    rdx,QWORD PTR [rdx+0x8]
    3c05:	call   3c0a <botlish_entry_42+0x10>
			3c06: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3c0a:	mov    rsp,rbp
    3c0d:	pop    rbp
    3c0e:	ret

0000000000003c0f <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3c0f:	push   rbp
    3c10:	mov    rbp,rsp
    3c13:	sub    rsp,0x70
    3c17:	mov    QWORD PTR [rsp+0x40],rbx
    3c1c:	mov    QWORD PTR [rsp+0x48],r12
    3c21:	mov    QWORD PTR [rsp+0x50],r13
    3c26:	mov    QWORD PTR [rsp+0x58],r14
    3c2b:	mov    QWORD PTR [rsp+0x60],r15
    3c30:	mov    r15,rdi
    3c33:	mov    QWORD PTR [rsp],rsi
    3c37:	mov    QWORD PTR [rsp+0x8],rdx
    3c3c:	mov    QWORD PTR [rsp+0x10],rcx
    3c41:	mov    r14,rcx
    3c44:	sar    r8,1
    3c47:	mov    rbx,r8
    3c4a:	mov    r12,r9
    3c4d:	mov    QWORD PTR [rsp+0x28],rsi
    3c52:	cmp    rbx,r12
    3c55:	jge    3d64 <botlish_fn_43+0x155>
    3c5b:	mov    r13,rdx
    3c5e:	mov    rdx,QWORD PTR [r13+0x8]
    3c62:	mov    rcx,rbx
    3c65:	shl    rcx,1
    3c68:	or     rcx,0x1
    3c6c:	sar    rcx,1
    3c6f:	cmp    rcx,rdx
    3c72:	jb     3c9e <botlish_fn_43+0x8f>
    3c78:	mov    rdx,rbx
    3c7b:	shl    rdx,1
    3c7e:	or     rdx,0x1
    3c82:	mov    rsi,r13
    3c85:	mov    rdi,r15
    3c88:	call   3c8d <botlish_fn_43+0x7e>
			3c89: R_X86_64_PLT32	rt_list_get-0x4
    3c8d:	test   rax,rax
    3c90:	je     3d1d <botlish_fn_43+0x10e>
    3c96:	mov    rdx,rax
    3c99:	jmp    3ca6 <botlish_fn_43+0x97>
    3c9e:	mov    rax,QWORD PTR [r13+0x10]
    3ca2:	mov    rdx,QWORD PTR [rax+rcx*8]
    3ca6:	mov    QWORD PTR [rsp+0x18],rdx
    3cab:	mov    QWORD PTR [rsp+0x30],rdx
    3cb0:	mov    rax,QWORD PTR [r14+0x8]
    3cb4:	mov    rcx,rbx
    3cb7:	shl    rcx,1
    3cba:	or     rcx,0x1
    3cbe:	sar    rcx,1
    3cc1:	cmp    rcx,rax
    3cc4:	jb     3cf5 <botlish_fn_43+0xe6>
    3cca:	mov    rdx,rbx
    3ccd:	shl    rdx,1
    3cd0:	or     rdx,0x1
    3cd4:	mov    rsi,r14
    3cd7:	mov    rdi,r15
    3cda:	call   3cdf <botlish_fn_43+0xd0>
			3cdb: R_X86_64_PLT32	rt_list_get-0x4
    3cdf:	test   rax,rax
    3ce2:	je     3d1d <botlish_fn_43+0x10e>
    3ce8:	mov    rcx,rax
    3ceb:	mov    rsi,QWORD PTR [rsp+0x28]
    3cf0:	jmp    3d02 <botlish_fn_43+0xf3>
    3cf5:	mov    rax,QWORD PTR [r14+0x10]
    3cf9:	mov    rcx,QWORD PTR [rax+rcx*8]
    3cfd:	mov    rsi,QWORD PTR [rsp+0x28]
    3d02:	mov    QWORD PTR [rsp+0x20],rcx
    3d07:	mov    rdx,QWORD PTR [rsp+0x30]
    3d0c:	mov    rdi,r15
    3d0f:	call   3d14 <botlish_fn_43+0x105>
			3d10: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3d14:	test   rax,rax
    3d17:	jne    3d42 <botlish_fn_43+0x133>
    3d1d:	xor    rax,rax
    3d20:	mov    rbx,QWORD PTR [rsp+0x40]
    3d25:	mov    r12,QWORD PTR [rsp+0x48]
    3d2a:	mov    r13,QWORD PTR [rsp+0x50]
    3d2f:	mov    r14,QWORD PTR [rsp+0x58]
    3d34:	mov    r15,QWORD PTR [rsp+0x60]
    3d39:	add    rsp,0x70
    3d3d:	mov    rsp,rbp
    3d40:	pop    rbp
    3d41:	ret
    3d42:	mov    QWORD PTR [rsp],rax
    3d46:	mov    QWORD PTR [rsp+0x8],r13
    3d4b:	mov    QWORD PTR [rsp+0x10],r14
    3d50:	add    rbx,0x1
    3d57:	mov    rdx,r13
    3d5a:	mov    QWORD PTR [rsp+0x28],rax
    3d5f:	jmp    3c52 <botlish_fn_43+0x43>
    3d64:	mov    rax,QWORD PTR [rsp+0x28]
    3d69:	mov    rbx,QWORD PTR [rsp+0x40]
    3d6e:	mov    r12,QWORD PTR [rsp+0x48]
    3d73:	mov    r13,QWORD PTR [rsp+0x50]
    3d78:	mov    r14,QWORD PTR [rsp+0x58]
    3d7d:	mov    r15,QWORD PTR [rsp+0x60]
    3d82:	add    rsp,0x70
    3d86:	mov    rsp,rbp
    3d89:	pop    rbp
    3d8a:	ret

0000000000003d8b <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3d8b:	push   rbp
    3d8c:	mov    rbp,rsp
    3d8f:	mov    rsi,QWORD PTR [rdx]
    3d92:	mov    r10,QWORD PTR [rdx+0x8]
    3d96:	mov    rcx,QWORD PTR [rdx+0x10]
    3d9a:	mov    r8,QWORD PTR [rdx+0x18]
    3d9e:	mov    r9,QWORD PTR [rdx+0x20]
    3da2:	sar    r9,1
    3da5:	mov    rdx,r10
    3da8:	call   3dad <botlish_entry_43+0x22>
			3da9: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3dad:	mov    rsp,rbp
    3db0:	pop    rbp
    3db1:	ret

0000000000003db2 <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    3db2:	push   rbp
    3db3:	mov    rbp,rsp
    3db6:	sub    rsp,0x50
    3dba:	mov    QWORD PTR [rsp+0x20],rbx
    3dbf:	mov    QWORD PTR [rsp+0x28],r12
    3dc4:	mov    QWORD PTR [rsp+0x30],r13
    3dc9:	mov    QWORD PTR [rsp+0x38],r14
    3dce:	mov    QWORD PTR [rsp+0x40],r15
    3dd3:	mov    r12,rdi
    3dd6:	mov    QWORD PTR [rsp],rsi
    3dda:	mov    r15,rsi
    3ddd:	mov    QWORD PTR [rsp+0x8],rdx
    3de2:	mov    QWORD PTR [rsp+0x10],rcx
    3de7:	mov    r13,rcx
    3dea:	mov    QWORD PTR [rsp+0x18],r8
    3def:	mov    rsi,r8
    3df2:	mov    rdi,r12
    3df5:	call   3dfa <botlish_fn_44+0x48>
			3df6: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3dfa:	test   rax,rax
    3dfd:	je     3e47 <botlish_fn_44+0x95>
    3e03:	mov    QWORD PTR [rsp+0x8],rax
    3e08:	mov    r14,rax
    3e0b:	mov    ebx,0x1
    3e10:	mov    QWORD PTR [rsp+0x18],0x1
    3e19:	mov    rsi,r13
    3e1c:	mov    rdi,r12
    3e1f:	call   3e24 <botlish_fn_44+0x72>
			3e20: R_X86_64_PLT32	rt_list_len-0x4
    3e24:	mov    r9,rax
    3e27:	sar    r9,1
    3e2a:	mov    rcx,r13
    3e2d:	mov    rdx,r15
    3e30:	mov    rsi,r14
    3e33:	mov    rdi,r12
    3e36:	mov    r8,rbx
    3e39:	call   3e3e <botlish_fn_44+0x8c>
			3e3a: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3e3e:	test   rax,rax
    3e41:	jne    3e6c <botlish_fn_44+0xba>
    3e47:	xor    rax,rax
    3e4a:	mov    rbx,QWORD PTR [rsp+0x20]
    3e4f:	mov    r12,QWORD PTR [rsp+0x28]
    3e54:	mov    r13,QWORD PTR [rsp+0x30]
    3e59:	mov    r14,QWORD PTR [rsp+0x38]
    3e5e:	mov    r15,QWORD PTR [rsp+0x40]
    3e63:	add    rsp,0x50
    3e67:	mov    rsp,rbp
    3e6a:	pop    rbp
    3e6b:	ret
    3e6c:	mov    rbx,QWORD PTR [rsp+0x20]
    3e71:	mov    r12,QWORD PTR [rsp+0x28]
    3e76:	mov    r13,QWORD PTR [rsp+0x30]
    3e7b:	mov    r14,QWORD PTR [rsp+0x38]
    3e80:	mov    r15,QWORD PTR [rsp+0x40]
    3e85:	add    rsp,0x50
    3e89:	mov    rsp,rbp
    3e8c:	pop    rbp
    3e8d:	ret

0000000000003e8e <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    3e8e:	push   rbp
    3e8f:	mov    rbp,rsp
    3e92:	mov    rsi,QWORD PTR [rdx]
    3e95:	mov    r9,QWORD PTR [rdx+0x8]
    3e99:	mov    rcx,QWORD PTR [rdx+0x10]
    3e9d:	mov    r8,QWORD PTR [rdx+0x18]
    3ea1:	mov    rdx,r9
    3ea4:	call   3ea9 <botlish_entry_44+0x1b>
			3ea5: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3ea9:	mov    rsp,rbp
    3eac:	pop    rbp
    3ead:	ret

0000000000003eae <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    3eae:	push   rbp
    3eaf:	mov    rbp,rsp
    3eb2:	sub    rsp,0x90
    3eb9:	mov    QWORD PTR [rsp+0x60],rbx
    3ebe:	mov    QWORD PTR [rsp+0x68],r12
    3ec3:	mov    QWORD PTR [rsp+0x70],r13
    3ec8:	mov    QWORD PTR [rsp+0x78],r14
    3ecd:	mov    QWORD PTR [rsp+0x80],r15
    3ed5:	mov    r13,r8
    3ed8:	mov    QWORD PTR [rsp+0x38],rdi
    3edd:	mov    rdi,QWORD PTR [rbp+0x10]
    3ee1:	mov    r15,QWORD PTR [rbp+0x18]
    3ee5:	mov    QWORD PTR [rsp+0x28],0x0
    3eee:	mov    QWORD PTR [rsp+0x30],0x0
    3ef7:	mov    QWORD PTR [rsp],rsi
    3efb:	mov    QWORD PTR [rsp+0x8],rcx
    3f00:	mov    r14,rcx
    3f03:	mov    QWORD PTR [rsp+0x10],r9
    3f08:	mov    QWORD PTR [rsp+0x18],rdi
    3f0d:	mov    QWORD PTR [rsp+0x20],r15
    3f12:	sar    rdx,1
    3f15:	mov    r12,rdx
    3f18:	mov    rbx,rsi
    3f1b:	mov    QWORD PTR [rsp+0x40],r9
    3f20:	mov    QWORD PTR [rsp+0x48],rdi
    3f25:	mov    rsi,rbx
    3f28:	mov    rdi,QWORD PTR [rsp+0x38]
    3f2d:	call   3f32 <botlish_fn_45+0x84>
			3f2e: R_X86_64_PLT32	rt_list_len-0x4
    3f32:	sar    rax,1
    3f35:	cmp    r12,rax
    3f38:	jge    4063 <botlish_fn_45+0x1b5>
    3f3e:	mov    rax,r13
    3f41:	or     rax,0x1
    3f45:	mov    QWORD PTR [rsp+0x28],rax
    3f4a:	mov    rcx,QWORD PTR [rbx+0x8]
    3f4e:	mov    rax,r12
    3f51:	shl    rax,1
    3f54:	or     rax,0x1
    3f58:	sar    rax,1
    3f5b:	cmp    rax,rcx
    3f5e:	jb     3f8c <botlish_fn_45+0xde>
    3f64:	mov    rdx,r12
    3f67:	shl    rdx,1
    3f6a:	or     rdx,0x1
    3f6e:	mov    rsi,rbx
    3f71:	mov    rdi,QWORD PTR [rsp+0x38]
    3f76:	call   3f7b <botlish_fn_45+0xcd>
			3f77: R_X86_64_PLT32	rt_list_get-0x4
    3f7b:	test   rax,rax
    3f7e:	je     4080 <botlish_fn_45+0x1d2>
    3f84:	mov    rcx,rax
    3f87:	jmp    3f94 <botlish_fn_45+0xe6>
    3f8c:	mov    rcx,QWORD PTR [rbx+0x10]
    3f90:	mov    rcx,QWORD PTR [rcx+rax*8]
    3f94:	mov    QWORD PTR [rsp+0x30],rcx
    3f99:	mov    rdx,r13
    3f9c:	or     rdx,0x1
    3fa0:	mov    rsi,r14
    3fa3:	mov    rdi,QWORD PTR [rsp+0x38]
    3fa8:	mov    r8,r15
    3fab:	call   3fb0 <botlish_fn_45+0x102>
			3fac: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3fb0:	test   rax,rax
    3fb3:	je     4080 <botlish_fn_45+0x1d2>
    3fb9:	mov    QWORD PTR [rsp+0x28],rax
    3fbe:	mov    rcx,rax
    3fc1:	mov    rsi,QWORD PTR [rsp+0x40]
    3fc6:	mov    rdx,QWORD PTR [rsp+0x48]
    3fcb:	mov    rdi,QWORD PTR [rsp+0x38]
    3fd0:	call   3fd5 <botlish_fn_45+0x127>
			3fd1: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    3fd5:	test   rax,rax
    3fd8:	je     4080 <botlish_fn_45+0x1d2>
    3fde:	mov    QWORD PTR [rsp+0x10],rax
    3fe3:	mov    QWORD PTR [rsp+0x50],rax
    3fe8:	mov    QWORD PTR [rsp+0x28],0x3
    3ff1:	mov    rsi,QWORD PTR [rsp+0x48]
    3ff6:	test   rsi,0x1
    3ffd:	je     401c <botlish_fn_45+0x16e>
    4003:	mov    rsi,QWORD PTR [rsp+0x48]
    4008:	mov    rax,rsi
    400b:	add    rax,0x2
    400f:	seto   r10b
    4013:	test   r10b,r10b
    4016:	je     4030 <botlish_fn_45+0x182>
    401c:	mov    edx,0x3
    4021:	mov    rsi,QWORD PTR [rsp+0x48]
    4026:	mov    rdi,QWORD PTR [rsp+0x38]
    402b:	call   4030 <botlish_fn_45+0x182>
			402c: R_X86_64_PLT32	rt_int_add-0x4
    4030:	mov    QWORD PTR [rsp],rbx
    4034:	mov    QWORD PTR [rsp+0x8],r14
    4039:	mov    rcx,QWORD PTR [rsp+0x50]
    403e:	mov    QWORD PTR [rsp+0x10],rcx
    4043:	mov    QWORD PTR [rsp+0x18],rax
    4048:	mov    QWORD PTR [rsp+0x20],r15
    404d:	add    r12,0x1
    4054:	mov    QWORD PTR [rsp+0x40],rcx
    4059:	mov    QWORD PTR [rsp+0x48],rax
    405e:	jmp    3f25 <botlish_fn_45+0x77>
    4063:	mov    rdx,QWORD PTR [rsp+0x48]
    4068:	mov    rsi,QWORD PTR [rsp+0x40]
    406d:	mov    rdi,QWORD PTR [rsp+0x38]
    4072:	call   4077 <botlish_fn_45+0x1c9>
			4073: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    4077:	test   rax,rax
    407a:	jne    40ab <botlish_fn_45+0x1fd>
    4080:	xor    rax,rax
    4083:	mov    rbx,QWORD PTR [rsp+0x60]
    4088:	mov    r12,QWORD PTR [rsp+0x68]
    408d:	mov    r13,QWORD PTR [rsp+0x70]
    4092:	mov    r14,QWORD PTR [rsp+0x78]
    4097:	mov    r15,QWORD PTR [rsp+0x80]
    409f:	add    rsp,0x90
    40a6:	mov    rsp,rbp
    40a9:	pop    rbp
    40aa:	ret
    40ab:	mov    rbx,QWORD PTR [rsp+0x60]
    40b0:	mov    r12,QWORD PTR [rsp+0x68]
    40b5:	mov    r13,QWORD PTR [rsp+0x70]
    40ba:	mov    r14,QWORD PTR [rsp+0x78]
    40bf:	mov    r15,QWORD PTR [rsp+0x80]
    40c7:	add    rsp,0x90
    40ce:	mov    rsp,rbp
    40d1:	pop    rbp
    40d2:	ret

00000000000040d3 <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    40d3:	push   rbp
    40d4:	mov    rbp,rsp
    40d7:	sub    rsp,0x10
    40db:	mov    rsi,QWORD PTR [rdx]
    40de:	mov    r10,QWORD PTR [rdx+0x8]
    40e2:	mov    rcx,QWORD PTR [rdx+0x10]
    40e6:	mov    r8,QWORD PTR [rdx+0x18]
    40ea:	mov    r9,QWORD PTR [rdx+0x20]
    40ee:	mov    r11,QWORD PTR [rdx+0x28]
    40f2:	mov    rax,QWORD PTR [rdx+0x30]
    40f6:	mov    QWORD PTR [rsp],r11
    40fa:	mov    QWORD PTR [rsp+0x8],rax
    40ff:	mov    rdx,r10
    4102:	call   4107 <botlish_entry_45+0x34>
			4103: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4107:	add    rsp,0x10
    410b:	mov    rsp,rbp
    410e:	pop    rbp
    410f:	ret

0000000000004110 <botlish_fn_46: csv_records_generic<str, bool>>:
    4110:	push   rbp
    4111:	mov    rbp,rsp
    4114:	sub    rsp,0x80
    411b:	mov    QWORD PTR [rsp+0x50],rbx
    4120:	mov    QWORD PTR [rsp+0x58],r12
    4125:	mov    QWORD PTR [rsp+0x60],r13
    412a:	mov    QWORD PTR [rsp+0x68],r14
    412f:	mov    QWORD PTR [rsp+0x70],r15
    4134:	mov    r12,rdi
    4137:	mov    QWORD PTR [rsp+0x20],0x0
    4140:	mov    QWORD PTR [rsp+0x28],0x0
    4149:	mov    QWORD PTR [rsp+0x30],0x0
    4152:	mov    QWORD PTR [rsp+0x38],0x0
    415b:	mov    QWORD PTR [rsp+0x40],0x0
    4164:	mov    QWORD PTR [rsp+0x10],rsi
    4169:	mov    QWORD PTR [rsp+0x18],rdx
    416e:	mov    r13,rdx
    4171:	mov    rdi,r12
    4174:	call   4179 <botlish_fn_46+0x69>
			4175: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    4179:	mov    rcx,rax
    417c:	mov    r14,rax
    417f:	test   rax,rcx
    4182:	je     429c <botlish_fn_46+0x18c>
    4188:	mov    rax,r14
    418b:	mov    QWORD PTR [rsp+0x10],rax
    4190:	mov    rsi,r14
    4193:	mov    rdi,r12
    4196:	call   419b <botlish_fn_46+0x8b>
			4197: R_X86_64_PLT32	rt_list_len-0x4
    419b:	sar    rax,1
    419e:	cmp    rax,0x1
    41a2:	jle    4285 <botlish_fn_46+0x175>
    41a8:	mov    rax,r14
    41ab:	mov    rax,QWORD PTR [rax+0x10]
    41af:	mov    rbx,QWORD PTR [rax]
    41b2:	mov    QWORD PTR [rsp+0x20],rbx
    41b7:	mov    rsi,rbx
    41ba:	mov    rdi,r12
    41bd:	call   41c2 <botlish_fn_46+0xb2>
			41be: R_X86_64_PLT32	rt_list_len-0x4
    41c2:	mov    r15,rbx
    41c5:	mov    QWORD PTR [rsp+0x28],rax
    41ca:	mov    QWORD PTR [rsp+0x48],rax
    41cf:	mov    rax,r14
    41d2:	mov    rcx,QWORD PTR [rax+0x10]
    41d6:	mov    rcx,QWORD PTR [rcx+0x8]
    41da:	mov    QWORD PTR [rsp+0x30],rcx
    41df:	mov    rbx,r13
    41e2:	mov    rdx,QWORD PTR [rsp+0x48]
    41e7:	mov    rsi,r15
    41ea:	mov    rdi,r12
    41ed:	mov    r8,rbx
    41f0:	call   41f5 <botlish_fn_46+0xe5>
			41f1: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    41f5:	test   rax,rax
    41f8:	je     429c <botlish_fn_46+0x18c>
    41fe:	mov    QWORD PTR [rsp+0x30],rax
    4203:	mov    rsi,rax
    4206:	mov    QWORD PTR [rsp+0x38],0x5
    420f:	mov    rdi,r12
    4212:	call   4217 <botlish_fn_46+0x107>
			4213: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    4217:	test   rax,rax
    421a:	je     429c <botlish_fn_46+0x18c>
    4220:	mov    QWORD PTR [rsp+0x30],rax
    4225:	mov    r9,rax
    4228:	mov    eax,0x3
    422d:	mov    QWORD PTR [rsp+0x40],0x3
    4236:	mov    edx,0x5
    423b:	mov    QWORD PTR [rsp],rax
    423f:	mov    QWORD PTR [rsp+0x8],rbx
    4244:	mov    rcx,r15
    4247:	mov    rsi,r14
    424a:	mov    rdi,r12
    424d:	mov    r8,QWORD PTR [rsp+0x48]
    4252:	call   4257 <botlish_fn_46+0x147>
			4253: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4257:	test   rax,rax
    425a:	je     429c <botlish_fn_46+0x18c>
    4260:	mov    rbx,QWORD PTR [rsp+0x50]
    4265:	mov    r12,QWORD PTR [rsp+0x58]
    426a:	mov    r13,QWORD PTR [rsp+0x60]
    426f:	mov    r14,QWORD PTR [rsp+0x68]
    4274:	mov    r15,QWORD PTR [rsp+0x70]
    4279:	add    rsp,0x80
    4280:	mov    rsp,rbp
    4283:	pop    rbp
    4284:	ret
    4285:	xor    rdx,rdx
    4288:	mov    rdi,r12
    428b:	mov    rsi,rdx
    428e:	call   4293 <botlish_fn_46+0x183>
			428f: R_X86_64_PLT32	rt_list_new-0x4
    4293:	test   rax,rax
    4296:	jne    42c4 <botlish_fn_46+0x1b4>
    429c:	xor    rax,rax
    429f:	mov    rbx,QWORD PTR [rsp+0x50]
    42a4:	mov    r12,QWORD PTR [rsp+0x58]
    42a9:	mov    r13,QWORD PTR [rsp+0x60]
    42ae:	mov    r14,QWORD PTR [rsp+0x68]
    42b3:	mov    r15,QWORD PTR [rsp+0x70]
    42b8:	add    rsp,0x80
    42bf:	mov    rsp,rbp
    42c2:	pop    rbp
    42c3:	ret
    42c4:	mov    rbx,QWORD PTR [rsp+0x50]
    42c9:	mov    r12,QWORD PTR [rsp+0x58]
    42ce:	mov    r13,QWORD PTR [rsp+0x60]
    42d3:	mov    r14,QWORD PTR [rsp+0x68]
    42d8:	mov    r15,QWORD PTR [rsp+0x70]
    42dd:	add    rsp,0x80
    42e4:	mov    rsp,rbp
    42e7:	pop    rbp
    42e8:	ret

00000000000042e9 <botlish_entry_46: csv_records_generic<str, bool>>:
    42e9:	push   rbp
    42ea:	mov    rbp,rsp
    42ed:	mov    rsi,QWORD PTR [rdx]
    42f0:	mov    rdx,QWORD PTR [rdx+0x8]
    42f4:	call   42f9 <botlish_entry_46+0x10>
			42f5: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    42f9:	mov    rsp,rbp
    42fc:	pop    rbp
    42fd:	ret

00000000000042fe <botlish_fn_47: csv_records<str>>:
    42fe:	push   rbp
    42ff:	mov    rbp,rsp
    4302:	sub    rsp,0x10
    4306:	mov    QWORD PTR [rsp],rsi
    430a:	mov    edx,0x2
    430f:	mov    QWORD PTR [rsp+0x8],0x2
    4318:	call   431d <botlish_fn_47+0x1f>
			4319: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    431d:	test   rax,rax
    4320:	jne    4332 <botlish_fn_47+0x34>
    4326:	xor    rax,rax
    4329:	add    rsp,0x10
    432d:	mov    rsp,rbp
    4330:	pop    rbp
    4331:	ret
    4332:	add    rsp,0x10
    4336:	mov    rsp,rbp
    4339:	pop    rbp
    433a:	ret

000000000000433b <botlish_entry_47: csv_records<str>>:
    433b:	push   rbp
    433c:	mov    rbp,rsp
    433f:	mov    rsi,QWORD PTR [rdx]
    4342:	call   4347 <botlish_entry_47+0xc>
			4343: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4347:	mov    rsp,rbp
    434a:	pop    rbp
    434b:	ret

000000000000434c <botlish_fn_48: csv_records_presized<str>>:
    434c:	push   rbp
    434d:	mov    rbp,rsp
    4350:	sub    rsp,0x10
    4354:	mov    QWORD PTR [rsp],rsi
    4358:	mov    edx,0x6
    435d:	mov    QWORD PTR [rsp+0x8],0x6
    4366:	call   436b <botlish_fn_48+0x1f>
			4367: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    436b:	test   rax,rax
    436e:	jne    4380 <botlish_fn_48+0x34>
    4374:	xor    rax,rax
    4377:	add    rsp,0x10
    437b:	mov    rsp,rbp
    437e:	pop    rbp
    437f:	ret
    4380:	add    rsp,0x10
    4384:	mov    rsp,rbp
    4387:	pop    rbp
    4388:	ret

0000000000004389 <botlish_entry_48: csv_records_presized<str>>:
    4389:	push   rbp
    438a:	mov    rbp,rsp
    438d:	mov    rsi,QWORD PTR [rdx]
    4390:	call   4395 <botlish_entry_48+0xc>
			4391: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4395:	mov    rsp,rbp
    4398:	pop    rbp
    4399:	ret
    439a:	add    BYTE PTR [rax],al
    439c:	add    BYTE PTR [rax],al
	...

00000000000043a0 <botlish_fn_49: sample_checks<generic>>:
    43a0:	push   rbp
    43a1:	mov    rbp,rsp
    43a4:	sub    rsp,0xc0
    43ab:	mov    QWORD PTR [rsp+0x90],rbx
    43b3:	mov    QWORD PTR [rsp+0x98],r12
    43bb:	mov    QWORD PTR [rsp+0xa0],r13
    43c3:	mov    QWORD PTR [rsp+0xa8],r14
    43cb:	mov    QWORD PTR [rsp+0xb0],r15
    43d3:	mov    QWORD PTR [rsp+0x8],0x0
    43dc:	mov    QWORD PTR [rsp+0x10],0x0
    43e5:	mov    QWORD PTR [rsp+0x18],0x0
    43ee:	mov    QWORD PTR [rsp+0x20],0x0
    43f7:	mov    QWORD PTR [rsp+0x28],0x0
    4400:	mov    QWORD PTR [rsp+0x30],0x0
    4409:	mov    QWORD PTR [rsp+0x38],0x0
    4412:	mov    rax,QWORD PTR [rdi+0x10]
    4416:	mov    r13,rdi
    4419:	mov    rsi,QWORD PTR [rax+0x20]
    441d:	mov    QWORD PTR [rsp],rsi
    4421:	call   4426 <botlish_fn_49+0x86>
			4422: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4426:	mov    rsi,rax
    4429:	mov    r12,rax
    442c:	test   rax,rsi
    442f:	je     47b4 <botlish_fn_49+0x414>
    4435:	mov    rax,r12
    4438:	mov    QWORD PTR [rsp],rax
    443c:	mov    rdi,r13
    443f:	mov    rax,QWORD PTR [rdi+0x10]
    4443:	mov    rsi,QWORD PTR [rax+0x20]
    4447:	mov    QWORD PTR [rsp+0x8],rsi
    444c:	call   4451 <botlish_fn_49+0xb1>
			444d: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4451:	mov    rbx,rax
    4454:	test   rbx,rbx
    4457:	je     47b4 <botlish_fn_49+0x414>
    445d:	mov    rax,r12
    4460:	mov    rax,QWORD PTR [rax+0x8]
    4464:	test   rax,rax
    4467:	jne    448e <botlish_fn_49+0xee>
    446d:	mov    edx,0x1
    4472:	mov    rsi,r12
    4475:	mov    rdi,r13
    4478:	call   447d <botlish_fn_49+0xdd>
			4479: R_X86_64_PLT32	rt_list_get-0x4
    447d:	test   rax,rax
    4480:	je     47b4 <botlish_fn_49+0x414>
    4486:	mov    rsi,rax
    4489:	jmp    4496 <botlish_fn_49+0xf6>
    448e:	mov    rax,QWORD PTR [r12+0x10]
    4493:	mov    rsi,QWORD PTR [rax]
    4496:	mov    QWORD PTR [rsp+0x8],rsi
    449b:	mov    r15,rsi
    449e:	mov    rax,QWORD PTR [r12+0x8]
    44a3:	cmp    rax,0x1
    44a7:	ja     44ce <botlish_fn_49+0x12e>
    44ad:	mov    edx,0x3
    44b2:	mov    rsi,r12
    44b5:	mov    rdi,r13
    44b8:	call   44bd <botlish_fn_49+0x11d>
			44b9: R_X86_64_PLT32	rt_list_get-0x4
    44bd:	test   rax,rax
    44c0:	je     47b4 <botlish_fn_49+0x414>
    44c6:	mov    rsi,rax
    44c9:	jmp    44d7 <botlish_fn_49+0x137>
    44ce:	mov    rax,QWORD PTR [r12+0x10]
    44d3:	mov    rsi,QWORD PTR [rax+0x8]
    44d7:	mov    QWORD PTR [rsp+0x10],rsi
    44dc:	mov    r14,rsi
    44df:	mov    rax,QWORD PTR [rbx+0x8]
    44e3:	mov    rsi,rbx
    44e6:	test   rax,rax
    44e9:	jne    450d <botlish_fn_49+0x16d>
    44ef:	mov    edx,0x1
    44f4:	mov    rdi,r13
    44f7:	call   44fc <botlish_fn_49+0x15c>
			44f8: R_X86_64_PLT32	rt_list_get-0x4
    44fc:	test   rax,rax
    44ff:	je     47b4 <botlish_fn_49+0x414>
    4505:	mov    rsi,rax
    4508:	jmp    4514 <botlish_fn_49+0x174>
    450d:	mov    rax,QWORD PTR [rsi+0x10]
    4511:	mov    rsi,QWORD PTR [rax]
    4514:	mov    QWORD PTR [rsp+0x18],rsi
    4519:	mov    rdi,r13
    451c:	mov    QWORD PTR [rsp+0x78],rsi
    4521:	mov    rax,QWORD PTR [rdi+0x10]
    4525:	mov    rdx,QWORD PTR [rax+0x28]
    4529:	mov    QWORD PTR [rsp+0x20],rdx
    452e:	mov    rsi,r15
    4531:	call   4536 <botlish_fn_49+0x196>
			4532: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4536:	test   rax,rax
    4539:	je     47b4 <botlish_fn_49+0x414>
    453f:	mov    QWORD PTR [rsp+0x20],rax
    4544:	mov    rbx,rax
    4547:	mov    rdi,r13
    454a:	mov    rax,QWORD PTR [rdi+0x10]
    454e:	mov    rdx,QWORD PTR [rax+0x28]
    4552:	mov    QWORD PTR [rsp+0x28],rdx
    4557:	mov    rsi,QWORD PTR [rsp+0x78]
    455c:	call   4561 <botlish_fn_49+0x1c1>
			455d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4561:	test   rax,rax
    4564:	je     47b4 <botlish_fn_49+0x414>
    456a:	mov    rcx,rbx
    456d:	mov    rdx,rcx
    4570:	and    rdx,rax
    4573:	test   rdx,0x1
    457a:	jne    459c <botlish_fn_49+0x1fc>
    4580:	mov    rdx,rax
    4583:	mov    rsi,rbx
    4586:	mov    rdi,r13
    4589:	call   458e <botlish_fn_49+0x1ee>
			458a: R_X86_64_PLT32	rt_value_eq-0x4
    458e:	test   rax,rax
    4591:	je     47b4 <botlish_fn_49+0x414>
    4597:	jmp    45b2 <botlish_fn_49+0x212>
    459c:	mov    rdx,rax
    459f:	mov    rsi,rbx
    45a2:	mov    eax,0x2
    45a7:	cmp    rsi,rdx
    45aa:	cmove  rax,QWORD PTR [rip+0x26e]        # 4820 <botlish_fn_49+0x480>
    45b2:	mov    ebx,0x6
    45b7:	cmp    rax,0x6
    45bb:	je     45d6 <botlish_fn_49+0x236>
    45c1:	mov    ebx,0x2
    45c6:	mov    QWORD PTR [rsp],0x2
    45ce:	mov    rsi,r12
    45d1:	jmp    4675 <botlish_fn_49+0x2d5>
    45d6:	mov    rsi,r15
    45d9:	mov    rdi,r13
    45dc:	call   45e1 <botlish_fn_49+0x241>
			45dd: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    45e1:	test   rax,rax
    45e4:	mov    QWORD PTR [rsp+0x88],rax
    45ec:	je     47b4 <botlish_fn_49+0x414>
    45f2:	mov    rsi,QWORD PTR [rsp+0x78]
    45f7:	mov    rdi,r13
    45fa:	call   45ff <botlish_fn_49+0x25f>
			45fb: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    45ff:	test   rax,rax
    4602:	je     47b4 <botlish_fn_49+0x414>
    4608:	mov    rcx,QWORD PTR [rsp+0x88]
    4610:	mov    rdx,rcx
    4613:	and    rdx,rax
    4616:	test   rdx,0x1
    461d:	jne    4644 <botlish_fn_49+0x2a4>
    4623:	mov    rdx,rax
    4626:	mov    rsi,QWORD PTR [rsp+0x88]
    462e:	mov    rdi,r13
    4631:	call   4636 <botlish_fn_49+0x296>
			4632: R_X86_64_PLT32	rt_value_eq-0x4
    4636:	test   rax,rax
    4639:	je     47b4 <botlish_fn_49+0x414>
    463f:	jmp    465f <botlish_fn_49+0x2bf>
    4644:	mov    rdx,rax
    4647:	mov    rsi,QWORD PTR [rsp+0x88]
    464f:	mov    eax,0x2
    4654:	cmp    rsi,rdx
    4657:	cmove  rax,QWORD PTR [rip+0x1c1]        # 4820 <botlish_fn_49+0x480>
    465f:	cmp    rax,0x6
    4663:	je     466e <botlish_fn_49+0x2ce>
    4669:	mov    ebx,0x2
    466e:	mov    QWORD PTR [rsp],rbx
    4672:	mov    rsi,r12
    4675:	mov    rdi,r13
    4678:	call   467d <botlish_fn_49+0x2dd>
			4679: R_X86_64_PLT32	rt_list_len-0x4
    467d:	mov    QWORD PTR [rsp+0x18],rax
    4682:	mov    rdi,r13
    4685:	mov    r12,rax
    4688:	mov    rax,QWORD PTR [rdi+0x10]
    468c:	mov    rdx,QWORD PTR [rax+0x28]
    4690:	mov    QWORD PTR [rsp+0x20],rdx
    4695:	mov    rsi,r15
    4698:	call   469d <botlish_fn_49+0x2fd>
			4699: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    469d:	test   rax,rax
    46a0:	je     47b4 <botlish_fn_49+0x414>
    46a6:	mov    QWORD PTR [rsp+0x20],rax
    46ab:	mov    rdi,r13
    46ae:	mov    QWORD PTR [rsp+0x88],rax
    46b6:	mov    rax,QWORD PTR [rdi+0x10]
    46ba:	mov    rdx,QWORD PTR [rax+0x30]
    46be:	mov    QWORD PTR [rsp+0x28],rdx
    46c3:	mov    rsi,r15
    46c6:	call   46cb <botlish_fn_49+0x32b>
			46c7: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46cb:	test   rax,rax
    46ce:	je     47b4 <botlish_fn_49+0x414>
    46d4:	mov    QWORD PTR [rsp+0x28],rax
    46d9:	mov    rdi,r13
    46dc:	mov    QWORD PTR [rsp+0x80],rax
    46e4:	mov    rax,QWORD PTR [rdi+0x10]
    46e8:	mov    rdx,QWORD PTR [rax+0x38]
    46ec:	mov    QWORD PTR [rsp+0x30],rdx
    46f1:	mov    rsi,r15
    46f4:	call   46f9 <botlish_fn_49+0x359>
			46f5: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46f9:	test   rax,rax
    46fc:	je     47b4 <botlish_fn_49+0x414>
    4702:	mov    QWORD PTR [rsp+0x8],rax
    4707:	mov    rdi,r13
    470a:	mov    r15,rax
    470d:	mov    rax,QWORD PTR [rdi+0x10]
    4711:	mov    rdx,QWORD PTR [rax+0x28]
    4715:	mov    QWORD PTR [rsp+0x30],rdx
    471a:	mov    rsi,r14
    471d:	call   4722 <botlish_fn_49+0x382>
			471e: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4722:	test   rax,rax
    4725:	je     47b4 <botlish_fn_49+0x414>
    472b:	mov    QWORD PTR [rsp+0x30],rax
    4730:	mov    rdi,r13
    4733:	mov    QWORD PTR [rsp+0x78],rax
    4738:	mov    rax,QWORD PTR [rdi+0x10]
    473c:	mov    rdx,QWORD PTR [rax+0x38]
    4740:	mov    QWORD PTR [rsp+0x38],rdx
    4745:	mov    rsi,r14
    4748:	call   474d <botlish_fn_49+0x3ad>
			4749: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    474d:	test   rax,rax
    4750:	je     47b4 <botlish_fn_49+0x414>
    4756:	mov    QWORD PTR [rsp+0x10],rax
    475b:	lea    rdx,[rsp+0x40]
    4760:	mov    r9,r12
    4763:	mov    QWORD PTR [rsp+0x40],r9
    4768:	mov    rcx,QWORD PTR [rsp+0x88]
    4770:	mov    QWORD PTR [rsp+0x48],rcx
    4775:	mov    rcx,QWORD PTR [rsp+0x80]
    477d:	mov    QWORD PTR [rsp+0x50],rcx
    4782:	mov    rcx,r15
    4785:	mov    QWORD PTR [rsp+0x58],rcx
    478a:	mov    rcx,QWORD PTR [rsp+0x78]
    478f:	mov    QWORD PTR [rsp+0x60],rcx
    4794:	mov    QWORD PTR [rsp+0x68],rax
    4799:	mov    QWORD PTR [rsp+0x70],rbx
    479e:	mov    esi,0x7
    47a3:	mov    rdi,r13
    47a6:	call   47ab <botlish_fn_49+0x40b>
			47a7: R_X86_64_PLT32	rt_list_new-0x4
    47ab:	test   rax,rax
    47ae:	jne    47eb <botlish_fn_49+0x44b>
    47b4:	xor    rax,rax
    47b7:	mov    rbx,QWORD PTR [rsp+0x90]
    47bf:	mov    r12,QWORD PTR [rsp+0x98]
    47c7:	mov    r13,QWORD PTR [rsp+0xa0]
    47cf:	mov    r14,QWORD PTR [rsp+0xa8]
    47d7:	mov    r15,QWORD PTR [rsp+0xb0]
    47df:	add    rsp,0xc0
    47e6:	mov    rsp,rbp
    47e9:	pop    rbp
    47ea:	ret
    47eb:	mov    rbx,QWORD PTR [rsp+0x90]
    47f3:	mov    r12,QWORD PTR [rsp+0x98]
    47fb:	mov    r13,QWORD PTR [rsp+0xa0]
    4803:	mov    r14,QWORD PTR [rsp+0xa8]
    480b:	mov    r15,QWORD PTR [rsp+0xb0]
    4813:	add    rsp,0xc0
    481a:	mov    rsp,rbp
    481d:	pop    rbp
    481e:	ret
    481f:	add    BYTE PTR [rsi],al
    4821:	add    BYTE PTR [rax],al
    4823:	add    BYTE PTR [rax],al
    4825:	add    BYTE PTR [rax],al
	...

0000000000004828 <botlish_entry_49: sample_checks<generic>>:
    4828:	push   rbp
    4829:	mov    rbp,rsp
    482c:	call   4831 <botlish_entry_49+0x9>
			482d: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    4831:	mov    rsp,rbp
    4834:	pop    rbp
    4835:	ret

0000000000004836 <botlish_fn_50: sample<generic>>:
    4836:	push   rbp
    4837:	mov    rbp,rsp
    483a:	sub    rsp,0x10
    483e:	mov    QWORD PTR [rsp],rbx
    4842:	mov    rbx,rdi
    4845:	mov    rdi,rbx
    4848:	call   484d <botlish_fn_50+0x17>
			4849: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    484d:	test   rax,rax
    4850:	jne    4909 <botlish_fn_50+0xd3>
    4856:	mov    rdi,rbx
    4859:	call   485e <botlish_fn_50+0x28>
			485a: R_X86_64_PLT32	rt_declared_error-0x4
    485e:	cmp    rax,0x40000001
    4864:	je     48da <botlish_fn_50+0xa4>
    486a:	mov    rdi,rbx
    486d:	call   4872 <botlish_fn_50+0x3c>
			486e: R_X86_64_PLT32	rt_declared_error-0x4
    4872:	cmp    rax,0x40000002
    4878:	je     48b6 <botlish_fn_50+0x80>
    487e:	mov    rdi,rbx
    4881:	call   4886 <botlish_fn_50+0x50>
			4882: R_X86_64_PLT32	rt_declared_error-0x4
    4886:	cmp    rax,0x40000003
    488c:	jne    48f9 <botlish_fn_50+0xc3>
    4892:	mov    rdi,rbx
    4895:	call   489a <botlish_fn_50+0x64>
			4896: R_X86_64_PLT32	rt_clear_declared_error-0x4
    489a:	xor    rdx,rdx
    489d:	mov    rdi,rbx
    48a0:	mov    rsi,rdx
    48a3:	call   48a8 <botlish_fn_50+0x72>
			48a4: R_X86_64_PLT32	rt_list_new-0x4
    48a8:	test   rax,rax
    48ab:	je     48f9 <botlish_fn_50+0xc3>
    48b1:	jmp    4909 <botlish_fn_50+0xd3>
    48b6:	mov    rdi,rbx
    48b9:	call   48be <botlish_fn_50+0x88>
			48ba: R_X86_64_PLT32	rt_clear_declared_error-0x4
    48be:	xor    rdx,rdx
    48c1:	mov    rdi,rbx
    48c4:	mov    rsi,rdx
    48c7:	call   48cc <botlish_fn_50+0x96>
			48c8: R_X86_64_PLT32	rt_list_new-0x4
    48cc:	test   rax,rax
    48cf:	je     48f9 <botlish_fn_50+0xc3>
    48d5:	jmp    4909 <botlish_fn_50+0xd3>
    48da:	mov    rdi,rbx
    48dd:	call   48e2 <botlish_fn_50+0xac>
			48de: R_X86_64_PLT32	rt_clear_declared_error-0x4
    48e2:	xor    rdx,rdx
    48e5:	mov    rdi,rbx
    48e8:	mov    rsi,rdx
    48eb:	call   48f0 <botlish_fn_50+0xba>
			48ec: R_X86_64_PLT32	rt_list_new-0x4
    48f0:	test   rax,rax
    48f3:	jne    4909 <botlish_fn_50+0xd3>
    48f9:	xor    rax,rax
    48fc:	mov    rbx,QWORD PTR [rsp]
    4900:	add    rsp,0x10
    4904:	mov    rsp,rbp
    4907:	pop    rbp
    4908:	ret
    4909:	mov    rbx,QWORD PTR [rsp]
    490d:	add    rsp,0x10
    4911:	mov    rsp,rbp
    4914:	pop    rbp
    4915:	ret

0000000000004916 <botlish_entry_50: sample<generic>>:
    4916:	push   rbp
    4917:	mov    rbp,rsp
    491a:	call   491f <botlish_entry_50+0x9>
			491b: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    491f:	mov    rsp,rbp
    4922:	pop    rbp
    4923:	ret

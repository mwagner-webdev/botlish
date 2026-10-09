; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 20163  (per function: 45 89 89 89 357 420 420 420 202 202 202 81 365 430 584 1141 351 783 215 480 318 427 385 70 493 114 69 69 46 170 236 636 1064 333 380 402 616 654 809 673 928 684 107 433 259 629 515 78 78 1222 301)
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
;   botlish_fn_13 / botlish_entry_13 -> peek<str, int>
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

0000000000000b08 <botlish_fn_13: peek<str, int>>:
     b08:	push   rbp
     b09:	mov    rbp,rsp
     b0c:	sub    rsp,0x50
     b10:	mov    QWORD PTR [rsp+0x20],rbx
     b15:	mov    QWORD PTR [rsp+0x28],r12
     b1a:	mov    QWORD PTR [rsp+0x30],r13
     b1f:	mov    QWORD PTR [rsp+0x38],r14
     b24:	mov    QWORD PTR [rsp+0x40],r15
     b29:	mov    rbx,rdx
     b2c:	mov    r12,rcx
     b2f:	mov    r14,rdi
     b32:	mov    QWORD PTR [rsp],rsi
     b36:	mov    QWORD PTR [rsp+0x8],rdx
     b3b:	mov    rdx,QWORD PTR [rsi+0x8]
     b3f:	mov    r13,rsi
     b42:	shl    rdx,1
     b45:	mov    rax,rdx
     b48:	or     rax,0x1
     b4c:	mov    rcx,rbx
     b4f:	and    rcx,rax
     b52:	test   rcx,0x1
     b59:	jne    b83 <botlish_fn_13+0x7b>
     b5f:	or     rdx,0x1
     b63:	mov    rsi,rbx
     b66:	mov    rdi,r14
     b69:	call   b6e <botlish_fn_13+0x66>
			b6a: R_X86_64_PLT32	rt_int_cmp-0x4
     b6e:	mov    ecx,0x2
     b73:	test   rax,rax
     b76:	cmovge rcx,QWORD PTR [rip+0x122]        # ca0 <botlish_fn_13+0x198>
     b7e:	jmp    b97 <botlish_fn_13+0x8f>
     b83:	or     rdx,0x1
     b87:	mov    ecx,0x2
     b8c:	cmp    rbx,rdx
     b8f:	cmovge rcx,QWORD PTR [rip+0x109]        # ca0 <botlish_fn_13+0x198>
     b97:	cmp    rcx,0x6
     b9b:	je     c5b <botlish_fn_13+0x153>
     ba1:	mov    QWORD PTR [rsp+0x10],0x3
     baa:	test   rbx,0x1
     bb1:	je     bd4 <botlish_fn_13+0xcc>
     bb7:	mov    rax,rbx
     bba:	add    rax,0x2
     bbe:	seto   cl
     bc1:	test   cl,cl
     bc3:	jne    bd4 <botlish_fn_13+0xcc>
     bc9:	mov    rdi,r14
     bcc:	mov    r15,rax
     bcf:	jmp    bea <botlish_fn_13+0xe2>
     bd4:	mov    edx,0x3
     bd9:	mov    rsi,rbx
     bdc:	mov    rdi,r14
     bdf:	call   be4 <botlish_fn_13+0xdc>
			be0: R_X86_64_PLT32	rt_int_add-0x4
     be4:	mov    r15,rax
     be7:	mov    rdi,r14
     bea:	mov    rdi,r14
     bed:	mov    rcx,r15
     bf0:	mov    rdx,rbx
     bf3:	mov    rsi,r13
     bf6:	call   bfb <botlish_fn_13+0xf3>
			bf7: R_X86_64_PLT32	rt_str_region_check-0x4
     bfb:	test   rax,rax
     bfe:	jne    c29 <botlish_fn_13+0x121>
     c04:	xor    rax,rax
     c07:	mov    rbx,QWORD PTR [rsp+0x20]
     c0c:	mov    r12,QWORD PTR [rsp+0x28]
     c11:	mov    r13,QWORD PTR [rsp+0x30]
     c16:	mov    r14,QWORD PTR [rsp+0x38]
     c1b:	mov    r15,QWORD PTR [rsp+0x40]
     c20:	add    rsp,0x50
     c24:	mov    rsp,rbp
     c27:	pop    rbp
     c28:	ret
     c29:	mov    rcx,r12
     c2c:	mov    QWORD PTR [rcx],rbx
     c2f:	mov    rax,r15
     c32:	mov    QWORD PTR [rcx+0x8],rax
     c36:	mov    rax,r13
     c39:	mov    rbx,QWORD PTR [rsp+0x20]
     c3e:	mov    r12,QWORD PTR [rsp+0x28]
     c43:	mov    r13,QWORD PTR [rsp+0x30]
     c48:	mov    r14,QWORD PTR [rsp+0x38]
     c4d:	mov    r15,QWORD PTR [rsp+0x40]
     c52:	add    rsp,0x50
     c56:	mov    rsp,rbp
     c59:	pop    rbp
     c5a:	ret
     c5b:	mov    rcx,r12
     c5e:	mov    rdi,r14
     c61:	mov    rax,QWORD PTR [rdi+0x10]
     c65:	mov    rax,QWORD PTR [rax]
     c68:	mov    QWORD PTR [rcx],0x1
     c6f:	mov    QWORD PTR [rcx+0x8],0x1
     c77:	mov    rbx,QWORD PTR [rsp+0x20]
     c7c:	mov    r12,QWORD PTR [rsp+0x28]
     c81:	mov    r13,QWORD PTR [rsp+0x30]
     c86:	mov    r14,QWORD PTR [rsp+0x38]
     c8b:	mov    r15,QWORD PTR [rsp+0x40]
     c90:	add    rsp,0x50
     c94:	mov    rsp,rbp
     c97:	pop    rbp
     c98:	ret
     c99:	add    BYTE PTR [rax],al
     c9b:	add    BYTE PTR [rax],al
     c9d:	add    BYTE PTR [rax],al
     c9f:	add    BYTE PTR [rsi],al
     ca1:	add    BYTE PTR [rax],al
     ca3:	add    BYTE PTR [rax],al
     ca5:	add    BYTE PTR [rax],al
	...

0000000000000ca8 <botlish_entry_13: peek<str, int>>:
     ca8:	push   rbp
     ca9:	mov    rbp,rsp
     cac:	ud2

0000000000000cae <botlish_fn_14: scan_unquoted<str, int, int>>:
     cae:	push   rbp
     caf:	mov    rbp,rsp
     cb2:	sub    rsp,0x80
     cb9:	mov    QWORD PTR [rsp+0x50],rbx
     cbe:	mov    QWORD PTR [rsp+0x58],r12
     cc3:	mov    QWORD PTR [rsp+0x60],r13
     cc8:	mov    QWORD PTR [rsp+0x68],r14
     ccd:	mov    QWORD PTR [rsp+0x70],r15
     cd2:	mov    QWORD PTR [rsp+0x30],rdi
     cd7:	mov    QWORD PTR [rsp+0x18],0x0
     ce0:	mov    QWORD PTR [rsp],rsi
     ce4:	mov    r15,rsi
     ce7:	mov    QWORD PTR [rsp+0x8],rdx
     cec:	mov    r14,rdx
     cef:	mov    QWORD PTR [rsp+0x10],rcx
     cf4:	lea    r13,[rsp+0x20]
     cf9:	mov    QWORD PTR [rsp+0x38],rcx
     cfe:	mov    rcx,r13
     d01:	mov    rdx,QWORD PTR [rsp+0x38]
     d06:	mov    rsi,r15
     d09:	mov    rdi,QWORD PTR [rsp+0x30]
     d0e:	call   d13 <botlish_fn_14+0x65>
			d0f: R_X86_64_PLT32	botlish_fn_13-0x4 ; peek<str, int>
     d13:	mov    rsi,rax
     d16:	mov    QWORD PTR [rsp+0x40],rax
     d1b:	test   rax,rsi
     d1e:	je     e77 <botlish_fn_14+0x1c9>
     d24:	mov    rbx,QWORD PTR [rsp+0x20]
     d29:	mov    r12,QWORD PTR [rsp+0x28]
     d2e:	mov    rdi,QWORD PTR [rsp+0x30]
     d33:	mov    rcx,QWORD PTR [rdi+0x10]
     d37:	mov    r8,QWORD PTR [rcx]
     d3a:	mov    rcx,r12
     d3d:	mov    rdx,rbx
     d40:	mov    rsi,QWORD PTR [rsp+0x40]
     d45:	call   d4a <botlish_fn_14+0x9c>
			d46: R_X86_64_PLT32	rt_str_region_eq-0x4
     d4a:	cmp    rax,0x6
     d4e:	je     d8f <botlish_fn_14+0xe1>
     d54:	mov    rdi,QWORD PTR [rsp+0x30]
     d59:	mov    rax,QWORD PTR [rdi+0x10]
     d5d:	mov    r8,QWORD PTR [rax+0x8]
     d61:	mov    rcx,r12
     d64:	mov    rdx,rbx
     d67:	mov    rsi,QWORD PTR [rsp+0x40]
     d6c:	call   d71 <botlish_fn_14+0xc3>
			d6d: R_X86_64_PLT32	rt_str_region_eq-0x4
     d71:	cmp    rax,0x6
     d75:	je     d85 <botlish_fn_14+0xd7>
     d7b:	mov    eax,0x2
     d80:	jmp    d94 <botlish_fn_14+0xe6>
     d85:	mov    eax,0x6
     d8a:	jmp    d94 <botlish_fn_14+0xe6>
     d8f:	mov    eax,0x6
     d94:	cmp    rax,0x6
     d98:	je     dd9 <botlish_fn_14+0x12b>
     d9e:	mov    rdi,QWORD PTR [rsp+0x30]
     da3:	mov    rax,QWORD PTR [rdi+0x10]
     da7:	mov    r8,QWORD PTR [rax+0x10]
     dab:	mov    rcx,r12
     dae:	mov    rdx,rbx
     db1:	mov    rsi,QWORD PTR [rsp+0x40]
     db6:	call   dbb <botlish_fn_14+0x10d>
			db7: R_X86_64_PLT32	rt_str_region_eq-0x4
     dbb:	cmp    rax,0x6
     dbf:	je     dcf <botlish_fn_14+0x121>
     dc5:	mov    eax,0x2
     dca:	jmp    dde <botlish_fn_14+0x130>
     dcf:	mov    eax,0x6
     dd4:	jmp    dde <botlish_fn_14+0x130>
     dd9:	mov    eax,0x6
     dde:	cmp    rax,0x6
     de2:	je     e59 <botlish_fn_14+0x1ab>
     de8:	mov    QWORD PTR [rsp+0x18],0x3
     df1:	mov    rsi,QWORD PTR [rsp+0x38]
     df6:	test   rsi,0x1
     dfd:	je     e24 <botlish_fn_14+0x176>
     e03:	mov    rsi,QWORD PTR [rsp+0x38]
     e08:	mov    rax,rsi
     e0b:	add    rax,0x2
     e0f:	seto   sil
     e13:	test   sil,sil
     e16:	jne    e24 <botlish_fn_14+0x176>
     e1c:	mov    rsi,r15
     e1f:	jmp    e3b <botlish_fn_14+0x18d>
     e24:	mov    edx,0x3
     e29:	mov    rsi,QWORD PTR [rsp+0x38]
     e2e:	mov    rdi,QWORD PTR [rsp+0x30]
     e33:	call   e38 <botlish_fn_14+0x18a>
			e34: R_X86_64_PLT32	rt_int_add-0x4
     e38:	mov    rsi,r15
     e3b:	mov    QWORD PTR [rsp],rsi
     e3f:	mov    rdx,r14
     e42:	mov    QWORD PTR [rsp+0x8],rdx
     e47:	mov    QWORD PTR [rsp+0x10],rax
     e4c:	mov    r15,rsi
     e4f:	mov    QWORD PTR [rsp+0x38],rax
     e54:	jmp    cfe <botlish_fn_14+0x50>
     e59:	mov    rdx,r14
     e5c:	mov    rsi,r15
     e5f:	mov    rdi,QWORD PTR [rsp+0x30]
     e64:	mov    rcx,QWORD PTR [rsp+0x38]
     e69:	call   e6e <botlish_fn_14+0x1c0>
			e6a: R_X86_64_PLT32	rt_substr-0x4
     e6e:	test   rax,rax
     e71:	jne    ea2 <botlish_fn_14+0x1f4>
     e77:	xor    rdx,rdx
     e7a:	mov    rax,rdx
     e7d:	mov    rbx,QWORD PTR [rsp+0x50]
     e82:	mov    r12,QWORD PTR [rsp+0x58]
     e87:	mov    r13,QWORD PTR [rsp+0x60]
     e8c:	mov    r14,QWORD PTR [rsp+0x68]
     e91:	mov    r15,QWORD PTR [rsp+0x70]
     e96:	add    rsp,0x80
     e9d:	mov    rsp,rbp
     ea0:	pop    rbp
     ea1:	ret
     ea2:	mov    rdx,QWORD PTR [rsp+0x38]
     ea7:	mov    rbx,QWORD PTR [rsp+0x50]
     eac:	mov    r12,QWORD PTR [rsp+0x58]
     eb1:	mov    r13,QWORD PTR [rsp+0x60]
     eb6:	mov    r14,QWORD PTR [rsp+0x68]
     ebb:	mov    r15,QWORD PTR [rsp+0x70]
     ec0:	add    rsp,0x80
     ec7:	mov    rsp,rbp
     eca:	pop    rbp
     ecb:	ret

0000000000000ecc <botlish_entry_14: scan_unquoted<str, int, int>>:
     ecc:	push   rbp
     ecd:	mov    rbp,rsp
     ed0:	ud2

0000000000000ed2 <botlish_fn_15: scan_quoted<str, int, str>>:
     ed2:	push   rbp
     ed3:	mov    rbp,rsp
     ed6:	sub    rsp,0xd0
     edd:	mov    QWORD PTR [rsp+0xa0],rbx
     ee5:	mov    QWORD PTR [rsp+0xa8],r12
     eed:	mov    QWORD PTR [rsp+0xb0],r13
     ef5:	mov    QWORD PTR [rsp+0xb8],r14
     efd:	mov    QWORD PTR [rsp+0xc0],r15
     f05:	mov    QWORD PTR [rsp+0x88],rdi
     f0d:	mov    QWORD PTR [rsp+0x18],0x0
     f16:	mov    QWORD PTR [rsp+0x20],0x0
     f1f:	mov    QWORD PTR [rsp],rsi
     f23:	mov    QWORD PTR [rsp+0x8],rdx
     f28:	mov    QWORD PTR [rsp+0x10],rcx
     f2d:	mov    r13,rcx
     f30:	lea    r14,[rsp+0x68]
     f35:	lea    rbx,[rsp+0x28]
     f3a:	mov    r12,rsi
     f3d:	mov    QWORD PTR [rsp+0x90],rdx
     f45:	mov    rdx,QWORD PTR [rsp+0x90]
     f4d:	mov    rsi,r12
     f50:	mov    rdi,QWORD PTR [rsp+0x88]
     f58:	call   f5d <botlish_fn_15+0x8b>
			f59: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     f5d:	test   rax,rax
     f60:	je     12a9 <botlish_fn_15+0x3d7>
     f66:	mov    QWORD PTR [rsp+0x18],rax
     f6b:	mov    rsi,QWORD PTR [rax+0x8]
     f6f:	mov    rcx,rax
     f72:	mov    rax,0xffffffffffffffff
     f79:	test   rsi,rsi
     f7c:	jne    f8a <botlish_fn_15+0xb8>
     f82:	mov    r15,rcx
     f85:	jmp    fb5 <botlish_fn_15+0xe3>
     f8a:	mov    r15,rcx
     f8d:	movzx  rdi,BYTE PTR [r15+0x18]
     f92:	test   rdi,rdi
     f95:	jne    fb0 <botlish_fn_15+0xde>
     f9b:	mov    rsi,r15
     f9e:	mov    rdi,QWORD PTR [rsp+0x88]
     fa6:	call   fab <botlish_fn_15+0xd9>
			fa7: R_X86_64_PLT32	rt_str_to_short-0x4
     fab:	jmp    fb5 <botlish_fn_15+0xe3>
     fb0:	movzx  rax,BYTE PTR [r15+0x19]
     fb5:	cmp    rax,0x22
     fb9:	je     1079 <botlish_fn_15+0x1a7>
     fbf:	mov    QWORD PTR [rsp+0x20],0x3
     fc8:	mov    rsi,QWORD PTR [rsp+0x90]
     fd0:	test   rsi,0x1
     fd7:	je     ff7 <botlish_fn_15+0x125>
     fdd:	mov    rax,rsi
     fe0:	add    rax,0x2
     fe4:	seto   cl
     fe7:	test   cl,cl
     fe9:	jne    ff7 <botlish_fn_15+0x125>
     fef:	mov    rsi,rax
     ff2:	jmp    100c <botlish_fn_15+0x13a>
     ff7:	mov    edx,0x3
     ffc:	mov    rdi,QWORD PTR [rsp+0x88]
    1004:	call   1009 <botlish_fn_15+0x137>
			1005: R_X86_64_PLT32	rt_int_add-0x4
    1009:	mov    rsi,rax
    100c:	mov    QWORD PTR [rsp+0x8],rsi
    1011:	mov    QWORD PTR [rsp+0x90],rsi
    1019:	mov    QWORD PTR [rsp+0x68],0x0
    1022:	mov    QWORD PTR [rsp+0x70],r13
    1027:	mov    QWORD PTR [rsp+0x78],0x0
    1030:	mov    QWORD PTR [rsp+0x80],r15
    1038:	mov    esi,0x2
    103d:	mov    edx,0x4
    1042:	mov    rcx,r14
    1045:	mov    rdi,QWORD PTR [rsp+0x88]
    104d:	call   1052 <botlish_fn_15+0x180>
			104e: R_X86_64_PLT32	rt_construct-0x4
    1052:	test   rax,rax
    1055:	je     12a9 <botlish_fn_15+0x3d7>
    105b:	mov    QWORD PTR [rsp],r12
    105f:	mov    rsi,QWORD PTR [rsp+0x90]
    1067:	mov    QWORD PTR [rsp+0x8],rsi
    106c:	mov    QWORD PTR [rsp+0x10],rax
    1071:	mov    r13,rax
    1074:	jmp    f45 <botlish_fn_15+0x73>
    1079:	mov    QWORD PTR [rsp+0x18],0x3
    1082:	mov    rsi,QWORD PTR [rsp+0x90]
    108a:	test   rsi,0x1
    1091:	je     10b1 <botlish_fn_15+0x1df>
    1097:	mov    rsi,QWORD PTR [rsp+0x90]
    109f:	mov    rdx,rsi
    10a2:	add    rdx,0x2
    10a6:	seto   al
    10a9:	test   al,al
    10ab:	je     10ce <botlish_fn_15+0x1fc>
    10b1:	mov    edx,0x3
    10b6:	mov    rsi,QWORD PTR [rsp+0x90]
    10be:	mov    rdi,QWORD PTR [rsp+0x88]
    10c6:	call   10cb <botlish_fn_15+0x1f9>
			10c7: R_X86_64_PLT32	rt_int_add-0x4
    10cb:	mov    rdx,rax
    10ce:	mov    QWORD PTR [rsp+0x18],rdx
    10d3:	mov    rcx,rbx
    10d6:	mov    rsi,r12
    10d9:	mov    rdi,QWORD PTR [rsp+0x88]
    10e1:	call   10e6 <botlish_fn_15+0x214>
			10e2: R_X86_64_PLT32	botlish_fn_13-0x4 ; peek<str, int>
    10e6:	test   rax,rax
    10e9:	mov    rsi,rax
    10ec:	je     12a9 <botlish_fn_15+0x3d7>
    10f2:	mov    rdx,QWORD PTR [rsp+0x28]
    10f7:	mov    rcx,QWORD PTR [rsp+0x30]
    10fc:	mov    rdi,QWORD PTR [rsp+0x88]
    1104:	mov    rax,QWORD PTR [rdi+0x10]
    1108:	mov    r8,QWORD PTR [rax+0x18]
    110c:	call   1111 <botlish_fn_15+0x23f>
			110d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1111:	cmp    rax,0x6
    1115:	je     11e7 <botlish_fn_15+0x315>
    111b:	xor    rsi,rsi
    111e:	lea    rcx,[rsp+0x58]
    1123:	mov    QWORD PTR [rsp+0x58],0x0
    112c:	mov    QWORD PTR [rsp+0x60],r13
    1131:	mov    edx,0x2
    1136:	mov    rdi,QWORD PTR [rsp+0x88]
    113e:	call   1143 <botlish_fn_15+0x271>
			113f: R_X86_64_PLT32	rt_construct-0x4
    1143:	test   rax,rax
    1146:	je     12a9 <botlish_fn_15+0x3d7>
    114c:	mov    QWORD PTR [rsp],rax
    1150:	mov    rbx,rax
    1153:	mov    QWORD PTR [rsp+0x10],0x3
    115c:	mov    rsi,QWORD PTR [rsp+0x90]
    1164:	test   rsi,0x1
    116b:	je     1193 <botlish_fn_15+0x2c1>
    1171:	mov    rsi,QWORD PTR [rsp+0x90]
    1179:	mov    rdx,rsi
    117c:	add    rdx,0x2
    1180:	seto   al
    1183:	test   al,al
    1185:	jne    1193 <botlish_fn_15+0x2c1>
    118b:	mov    rax,rbx
    118e:	jmp    11b3 <botlish_fn_15+0x2e1>
    1193:	mov    edx,0x3
    1198:	mov    rsi,QWORD PTR [rsp+0x90]
    11a0:	mov    rdi,QWORD PTR [rsp+0x88]
    11a8:	call   11ad <botlish_fn_15+0x2db>
			11a9: R_X86_64_PLT32	rt_int_add-0x4
    11ad:	mov    rdx,rax
    11b0:	mov    rax,rbx
    11b3:	mov    rbx,QWORD PTR [rsp+0xa0]
    11bb:	mov    r12,QWORD PTR [rsp+0xa8]
    11c3:	mov    r13,QWORD PTR [rsp+0xb0]
    11cb:	mov    r14,QWORD PTR [rsp+0xb8]
    11d3:	mov    r15,QWORD PTR [rsp+0xc0]
    11db:	add    rsp,0xd0
    11e2:	mov    rsp,rbp
    11e5:	pop    rbp
    11e6:	ret
    11e7:	mov    QWORD PTR [rsp+0x18],0x5
    11f0:	mov    rsi,QWORD PTR [rsp+0x90]
    11f8:	test   rsi,0x1
    11ff:	je     1231 <botlish_fn_15+0x35f>
    1205:	mov    rsi,QWORD PTR [rsp+0x90]
    120d:	mov    rdi,rsi
    1210:	add    rdi,0x4
    1214:	seto   r9b
    1218:	test   r9b,r9b
    121b:	jne    1231 <botlish_fn_15+0x35f>
    1221:	mov    rsi,rdi
    1224:	mov    QWORD PTR [rsp+0x90],rdi
    122c:	jmp    1256 <botlish_fn_15+0x384>
    1231:	mov    edx,0x5
    1236:	mov    rsi,QWORD PTR [rsp+0x90]
    123e:	mov    rdi,QWORD PTR [rsp+0x88]
    1246:	call   124b <botlish_fn_15+0x379>
			1247: R_X86_64_PLT32	rt_int_add-0x4
    124b:	mov    rsi,rax
    124e:	mov    QWORD PTR [rsp+0x90],rax
    1256:	mov    QWORD PTR [rsp+0x8],rsi
    125b:	mov    rdi,QWORD PTR [rsp+0x88]
    1263:	mov    rax,QWORD PTR [rdi+0x10]
    1267:	mov    rax,QWORD PTR [rax+0x18]
    126b:	mov    QWORD PTR [rsp+0x18],rax
    1270:	lea    rcx,[rsp+0x38]
    1275:	mov    QWORD PTR [rsp+0x38],0x0
    127e:	mov    QWORD PTR [rsp+0x40],r13
    1283:	mov    QWORD PTR [rsp+0x48],0x0
    128c:	mov    QWORD PTR [rsp+0x50],rax
    1291:	mov    esi,0x2
    1296:	mov    edx,0x4
    129b:	call   12a0 <botlish_fn_15+0x3ce>
			129c: R_X86_64_PLT32	rt_construct-0x4
    12a0:	test   rax,rax
    12a3:	jne    12e3 <botlish_fn_15+0x411>
    12a9:	xor    rdx,rdx
    12ac:	mov    rax,rdx
    12af:	mov    rbx,QWORD PTR [rsp+0xa0]
    12b7:	mov    r12,QWORD PTR [rsp+0xa8]
    12bf:	mov    r13,QWORD PTR [rsp+0xb0]
    12c7:	mov    r14,QWORD PTR [rsp+0xb8]
    12cf:	mov    r15,QWORD PTR [rsp+0xc0]
    12d7:	add    rsp,0xd0
    12de:	mov    rsp,rbp
    12e1:	pop    rbp
    12e2:	ret
    12e3:	mov    QWORD PTR [rsp],r12
    12e7:	mov    rsi,QWORD PTR [rsp+0x90]
    12ef:	mov    QWORD PTR [rsp+0x8],rsi
    12f4:	mov    QWORD PTR [rsp+0x10],rax
    12f9:	mov    r13,rax
    12fc:	jmp    f45 <botlish_fn_15+0x73>

0000000000001301 <botlish_entry_15: scan_quoted<str, int, str>>:
    1301:	push   rbp
    1302:	mov    rbp,rsp
    1305:	ud2

0000000000001307 <botlish_fn_16: scan_field<str, int>>:
    1307:	push   rbp
    1308:	mov    rbp,rsp
    130b:	sub    rsp,0x50
    130f:	mov    QWORD PTR [rsp+0x30],rbx
    1314:	mov    QWORD PTR [rsp+0x38],r12
    1319:	mov    QWORD PTR [rsp+0x40],r13
    131e:	mov    r12,rdi
    1321:	mov    r13,rdx
    1324:	mov    QWORD PTR [rsp+0x10],0x0
    132d:	mov    QWORD PTR [rsp],rsi
    1331:	mov    rbx,rsi
    1334:	mov    QWORD PTR [rsp+0x8],rdx
    1339:	lea    rcx,[rsp+0x18]
    133e:	mov    rdx,r13
    1341:	mov    rsi,rbx
    1344:	mov    rdi,r12
    1347:	call   134c <botlish_fn_16+0x45>
			1348: R_X86_64_PLT32	botlish_fn_13-0x4 ; peek<str, int>
    134c:	test   rax,rax
    134f:	mov    rsi,rax
    1352:	je     141c <botlish_fn_16+0x115>
    1358:	mov    rdx,QWORD PTR [rsp+0x18]
    135d:	mov    rcx,QWORD PTR [rsp+0x20]
    1362:	mov    rdi,r12
    1365:	mov    rax,QWORD PTR [rdi+0x10]
    1369:	mov    r8,QWORD PTR [rax+0x18]
    136d:	call   1372 <botlish_fn_16+0x6b>
			136e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1372:	cmp    rax,0x6
    1376:	je     13ae <botlish_fn_16+0xa7>
    137c:	mov    rcx,r13
    137f:	mov    rsi,rbx
    1382:	mov    rdi,r12
    1385:	mov    rdx,rcx
    1388:	call   138d <botlish_fn_16+0x86>
			1389: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_unquoted<str, int, int>
    138d:	test   rax,rax
    1390:	je     141c <botlish_fn_16+0x115>
    1396:	mov    rbx,QWORD PTR [rsp+0x30]
    139b:	mov    r12,QWORD PTR [rsp+0x38]
    13a0:	mov    r13,QWORD PTR [rsp+0x40]
    13a5:	add    rsp,0x50
    13a9:	mov    rsp,rbp
    13ac:	pop    rbp
    13ad:	ret
    13ae:	mov    rcx,r13
    13b1:	mov    QWORD PTR [rsp+0x10],0x3
    13ba:	test   rcx,0x1
    13c1:	jne    13cf <botlish_fn_16+0xc8>
    13c7:	mov    r13,rcx
    13ca:	jmp    13e4 <botlish_fn_16+0xdd>
    13cf:	mov    rdx,rcx
    13d2:	add    rdx,0x2
    13d6:	mov    r13,rcx
    13d9:	seto   al
    13dc:	test   al,al
    13de:	je     13f7 <botlish_fn_16+0xf0>
    13e4:	mov    edx,0x3
    13e9:	mov    rsi,r13
    13ec:	mov    rdi,r12
    13ef:	call   13f4 <botlish_fn_16+0xed>
			13f0: R_X86_64_PLT32	rt_int_add-0x4
    13f4:	mov    rdx,rax
    13f7:	mov    QWORD PTR [rsp+0x8],rdx
    13fc:	mov    rdi,r12
    13ff:	mov    rax,QWORD PTR [rdi+0x10]
    1403:	mov    rcx,QWORD PTR [rax]
    1406:	mov    QWORD PTR [rsp+0x10],rcx
    140b:	mov    rsi,rbx
    140e:	call   1413 <botlish_fn_16+0x10c>
			140f: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_quoted<str, int, str>
    1413:	test   rax,rax
    1416:	jne    143a <botlish_fn_16+0x133>
    141c:	xor    rdx,rdx
    141f:	mov    rax,rdx
    1422:	mov    rbx,QWORD PTR [rsp+0x30]
    1427:	mov    r12,QWORD PTR [rsp+0x38]
    142c:	mov    r13,QWORD PTR [rsp+0x40]
    1431:	add    rsp,0x50
    1435:	mov    rsp,rbp
    1438:	pop    rbp
    1439:	ret
    143a:	mov    rbx,QWORD PTR [rsp+0x30]
    143f:	mov    r12,QWORD PTR [rsp+0x38]
    1444:	mov    r13,QWORD PTR [rsp+0x40]
    1449:	add    rsp,0x50
    144d:	mov    rsp,rbp
    1450:	pop    rbp
    1451:	ret

0000000000001452 <botlish_entry_16: scan_field<str, int>>:
    1452:	push   rbp
    1453:	mov    rbp,rsp
    1456:	ud2

0000000000001458 <botlish_fn_17: scan_record_rest<str, int, mutarray, int>>:
    1458:	push   rbp
    1459:	mov    rbp,rsp
    145c:	sub    rsp,0x90
    1463:	mov    QWORD PTR [rsp+0x60],rbx
    1468:	mov    QWORD PTR [rsp+0x68],r12
    146d:	mov    QWORD PTR [rsp+0x70],r13
    1472:	mov    QWORD PTR [rsp+0x78],r14
    1477:	mov    QWORD PTR [rsp+0x80],r15
    147f:	mov    r15,rdi
    1482:	mov    QWORD PTR [rsp+0x20],0x0
    148b:	mov    QWORD PTR [rsp],rsi
    148f:	mov    QWORD PTR [rsp+0x8],rdx
    1494:	mov    QWORD PTR [rsp+0x10],rcx
    1499:	mov    QWORD PTR [rsp+0x18],r8
    149e:	lea    r12,[rsp+0x28]
    14a3:	mov    rbx,rsi
    14a6:	mov    QWORD PTR [rsp+0x38],rdx
    14ab:	mov    QWORD PTR [rsp+0x40],rcx
    14b0:	mov    QWORD PTR [rsp+0x48],r8
    14b5:	mov    rcx,r12
    14b8:	mov    rdx,QWORD PTR [rsp+0x38]
    14bd:	mov    rsi,rbx
    14c0:	mov    rdi,r15
    14c3:	call   14c8 <botlish_fn_17+0x70>
			14c4: R_X86_64_PLT32	botlish_fn_13-0x4 ; peek<str, int>
    14c8:	test   rax,rax
    14cb:	mov    QWORD PTR [rsp+0x50],rax
    14d0:	je     1694 <botlish_fn_17+0x23c>
    14d6:	mov    r14,QWORD PTR [rsp+0x28]
    14db:	mov    r13,QWORD PTR [rsp+0x30]
    14e0:	mov    rdi,r15
    14e3:	mov    rcx,QWORD PTR [rdi+0x10]
    14e7:	mov    r8,QWORD PTR [rcx+0x8]
    14eb:	mov    rcx,r13
    14ee:	mov    rdx,r14
    14f1:	mov    rsi,QWORD PTR [rsp+0x50]
    14f6:	call   14fb <botlish_fn_17+0xa3>
			14f7: R_X86_64_PLT32	rt_str_region_eq-0x4
    14fb:	cmp    rax,0x6
    14ff:	je     160d <botlish_fn_17+0x1b5>
    1505:	mov    rdi,r15
    1508:	mov    rax,QWORD PTR [rdi+0x10]
    150c:	mov    r8,QWORD PTR [rax+0x10]
    1510:	mov    rcx,r13
    1513:	mov    rdx,r14
    1516:	mov    rsi,QWORD PTR [rsp+0x50]
    151b:	call   1520 <botlish_fn_17+0xc8>
			151c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1520:	cmp    rax,0x6
    1524:	je     1572 <botlish_fn_17+0x11a>
    152a:	mov    rdx,QWORD PTR [rsp+0x48]
    152f:	mov    rsi,QWORD PTR [rsp+0x40]
    1534:	mov    rdi,r15
    1537:	call   153c <botlish_fn_17+0xe4>
			1538: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    153c:	test   rax,rax
    153f:	je     1694 <botlish_fn_17+0x23c>
    1545:	mov    rdx,QWORD PTR [rsp+0x38]
    154a:	mov    rbx,QWORD PTR [rsp+0x60]
    154f:	mov    r12,QWORD PTR [rsp+0x68]
    1554:	mov    r13,QWORD PTR [rsp+0x70]
    1559:	mov    r14,QWORD PTR [rsp+0x78]
    155e:	mov    r15,QWORD PTR [rsp+0x80]
    1566:	add    rsp,0x90
    156d:	mov    rsp,rbp
    1570:	pop    rbp
    1571:	ret
    1572:	mov    rdx,QWORD PTR [rsp+0x48]
    1577:	mov    rsi,QWORD PTR [rsp+0x40]
    157c:	mov    rdi,r15
    157f:	call   1584 <botlish_fn_17+0x12c>
			1580: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    1584:	test   rax,rax
    1587:	je     1694 <botlish_fn_17+0x23c>
    158d:	mov    QWORD PTR [rsp],rax
    1591:	mov    rbx,rax
    1594:	mov    QWORD PTR [rsp+0x10],0x3
    159d:	mov    rdx,QWORD PTR [rsp+0x38]
    15a2:	test   rdx,0x1
    15a9:	je     15cd <botlish_fn_17+0x175>
    15af:	mov    rdx,QWORD PTR [rsp+0x38]
    15b4:	add    rdx,0x2
    15b8:	seto   sil
    15bc:	test   sil,sil
    15bf:	jne    15cd <botlish_fn_17+0x175>
    15c5:	mov    rax,rbx
    15c8:	jmp    15e5 <botlish_fn_17+0x18d>
    15cd:	mov    edx,0x3
    15d2:	mov    rsi,QWORD PTR [rsp+0x38]
    15d7:	mov    rdi,r15
    15da:	call   15df <botlish_fn_17+0x187>
			15db: R_X86_64_PLT32	rt_int_add-0x4
    15df:	mov    rdx,rax
    15e2:	mov    rax,rbx
    15e5:	mov    rbx,QWORD PTR [rsp+0x60]
    15ea:	mov    r12,QWORD PTR [rsp+0x68]
    15ef:	mov    r13,QWORD PTR [rsp+0x70]
    15f4:	mov    r14,QWORD PTR [rsp+0x78]
    15f9:	mov    r15,QWORD PTR [rsp+0x80]
    1601:	add    rsp,0x90
    1608:	mov    rsp,rbp
    160b:	pop    rbp
    160c:	ret
    160d:	mov    rsi,QWORD PTR [rsp+0x38]
    1612:	mov    edx,0x3
    1617:	mov    r13,rdx
    161a:	mov    QWORD PTR [rsp+0x20],0x3
    1623:	test   rsi,0x1
    162a:	je     1642 <botlish_fn_17+0x1ea>
    1630:	mov    rdx,rsi
    1633:	add    rdx,0x2
    1637:	seto   al
    163a:	test   al,al
    163c:	je     1650 <botlish_fn_17+0x1f8>
    1642:	mov    rdx,r13
    1645:	mov    rdi,r15
    1648:	call   164d <botlish_fn_17+0x1f5>
			1649: R_X86_64_PLT32	rt_int_add-0x4
    164d:	mov    rdx,rax
    1650:	mov    QWORD PTR [rsp+0x8],rdx
    1655:	mov    rsi,rbx
    1658:	mov    rdi,r15
    165b:	call   1660 <botlish_fn_17+0x208>
			165c: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    1660:	test   rax,rax
    1663:	je     1694 <botlish_fn_17+0x23c>
    1669:	mov    QWORD PTR [rsp+0x8],rax
    166e:	mov    rcx,rax
    1671:	mov    QWORD PTR [rsp+0x20],rdx
    1676:	mov    rsi,QWORD PTR [rsp+0x40]
    167b:	mov    r14,rdx
    167e:	mov    rdx,QWORD PTR [rsp+0x48]
    1683:	mov    rdi,r15
    1686:	call   168b <botlish_fn_17+0x233>
			1687: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    168b:	test   rax,rax
    168e:	jne    16c2 <botlish_fn_17+0x26a>
    1694:	xor    rdx,rdx
    1697:	mov    rax,rdx
    169a:	mov    rbx,QWORD PTR [rsp+0x60]
    169f:	mov    r12,QWORD PTR [rsp+0x68]
    16a4:	mov    r13,QWORD PTR [rsp+0x70]
    16a9:	mov    r14,QWORD PTR [rsp+0x78]
    16ae:	mov    r15,QWORD PTR [rsp+0x80]
    16b6:	add    rsp,0x90
    16bd:	mov    rsp,rbp
    16c0:	pop    rbp
    16c1:	ret
    16c2:	mov    QWORD PTR [rsp+0x8],rax
    16c7:	mov    QWORD PTR [rsp+0x38],rax
    16cc:	mov    QWORD PTR [rsp+0x10],0x3
    16d5:	mov    rdx,QWORD PTR [rsp+0x48]
    16da:	test   rdx,0x1
    16e1:	jne    16f4 <botlish_fn_17+0x29c>
    16e7:	mov    rdx,r13
    16ea:	mov    rsi,QWORD PTR [rsp+0x48]
    16ef:	jmp    1713 <botlish_fn_17+0x2bb>
    16f4:	mov    rdx,QWORD PTR [rsp+0x48]
    16f9:	mov    rax,rdx
    16fc:	add    rax,0x2
    1700:	seto   cl
    1703:	test   cl,cl
    1705:	je     171b <botlish_fn_17+0x2c3>
    170b:	mov    rdx,r13
    170e:	mov    rsi,QWORD PTR [rsp+0x48]
    1713:	mov    rdi,r15
    1716:	call   171b <botlish_fn_17+0x2c3>
			1717: R_X86_64_PLT32	rt_int_add-0x4
    171b:	mov    QWORD PTR [rsp],rbx
    171f:	mov    rdx,r14
    1722:	mov    QWORD PTR [rsp+0x8],rdx
    1727:	mov    rcx,QWORD PTR [rsp+0x38]
    172c:	mov    QWORD PTR [rsp+0x10],rcx
    1731:	mov    QWORD PTR [rsp+0x18],rax
    1736:	mov    QWORD PTR [rsp+0x38],rdx
    173b:	mov    QWORD PTR [rsp+0x40],rcx
    1740:	mov    QWORD PTR [rsp+0x48],rax
    1745:	jmp    14b5 <botlish_fn_17+0x5d>

000000000000174a <botlish_entry_17: scan_record_rest<str, int, mutarray, int>>:
    174a:	push   rbp
    174b:	mov    rbp,rsp
    174e:	ud2

0000000000001750 <botlish_fn_18: scan_record<str, int>>:
    1750:	push   rbp
    1751:	mov    rbp,rsp
    1754:	sub    rsp,0x40
    1758:	mov    QWORD PTR [rsp+0x20],rbx
    175d:	mov    QWORD PTR [rsp+0x28],r12
    1762:	mov    QWORD PTR [rsp+0x30],r14
    1767:	mov    r14,rdi
    176a:	mov    QWORD PTR [rsp+0x10],0x0
    1773:	mov    QWORD PTR [rsp+0x18],0x0
    177c:	mov    QWORD PTR [rsp],rsi
    1780:	mov    r12,rsi
    1783:	mov    QWORD PTR [rsp+0x8],rdx
    1788:	mov    rsi,r12
    178b:	mov    rdi,r14
    178e:	call   1793 <botlish_fn_18+0x43>
			178f: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    1793:	test   rax,rax
    1796:	je     17eb <botlish_fn_18+0x9b>
    179c:	mov    QWORD PTR [rsp+0x8],rax
    17a1:	mov    rsi,rax
    17a4:	mov    QWORD PTR [rsp+0x10],rdx
    17a9:	mov    rbx,rdx
    17ac:	mov    rdi,r14
    17af:	call   17b4 <botlish_fn_18+0x64>
			17b0: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    17b4:	test   rax,rax
    17b7:	je     17eb <botlish_fn_18+0x9b>
    17bd:	mov    QWORD PTR [rsp+0x8],rax
    17c2:	mov    rcx,rax
    17c5:	mov    r8d,0x3
    17cb:	mov    QWORD PTR [rsp+0x18],0x3
    17d4:	mov    rdx,rbx
    17d7:	mov    rsi,r12
    17da:	mov    rdi,r14
    17dd:	call   17e2 <botlish_fn_18+0x92>
			17de: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record_rest<str, int, mutarray, int>
    17e2:	test   rax,rax
    17e5:	jne    1809 <botlish_fn_18+0xb9>
    17eb:	xor    rdx,rdx
    17ee:	mov    rax,rdx
    17f1:	mov    rbx,QWORD PTR [rsp+0x20]
    17f6:	mov    r12,QWORD PTR [rsp+0x28]
    17fb:	mov    r14,QWORD PTR [rsp+0x30]
    1800:	add    rsp,0x40
    1804:	mov    rsp,rbp
    1807:	pop    rbp
    1808:	ret
    1809:	mov    rbx,QWORD PTR [rsp+0x20]
    180e:	mov    r12,QWORD PTR [rsp+0x28]
    1813:	mov    r14,QWORD PTR [rsp+0x30]
    1818:	add    rsp,0x40
    181c:	mov    rsp,rbp
    181f:	pop    rbp
    1820:	ret

0000000000001821 <botlish_entry_18: scan_record<str, int>>:
    1821:	push   rbp
    1822:	mov    rbp,rsp
    1825:	ud2
	...

0000000000001828 <botlish_fn_19: scan_records<str, int, mutarray, int>>:
    1828:	push   rbp
    1829:	mov    rbp,rsp
    182c:	sub    rsp,0x60
    1830:	mov    QWORD PTR [rsp+0x30],rbx
    1835:	mov    QWORD PTR [rsp+0x38],r12
    183a:	mov    QWORD PTR [rsp+0x40],r13
    183f:	mov    QWORD PTR [rsp+0x48],r14
    1844:	mov    QWORD PTR [rsp+0x50],r15
    1849:	mov    r13,rdi
    184c:	mov    QWORD PTR [rsp+0x20],0x0
    1855:	mov    QWORD PTR [rsp],rsi
    1859:	mov    QWORD PTR [rsp+0x8],rdx
    185e:	mov    rax,rdx
    1861:	mov    QWORD PTR [rsp+0x10],rcx
    1866:	mov    QWORD PTR [rsp+0x18],r8
    186b:	mov    rbx,rsi
    186e:	mov    r14,r8
    1871:	mov    r15,rcx
    1874:	mov    rdx,QWORD PTR [rbx+0x8]
    1878:	shl    rdx,1
    187b:	or     rdx,0x1
    187f:	mov    r12,rax
    1882:	and    rax,rdx
    1885:	test   rax,0x1
    188b:	jne    18b1 <botlish_fn_19+0x89>
    1891:	mov    rsi,r12
    1894:	mov    rdi,r13
    1897:	call   189c <botlish_fn_19+0x74>
			1898: R_X86_64_PLT32	rt_int_cmp-0x4
    189c:	mov    ecx,0x2
    18a1:	test   rax,rax
    18a4:	cmovge rcx,QWORD PTR [rip+0x12c]        # 19d8 <botlish_fn_19+0x1b0>
    18ac:	jmp    18c1 <botlish_fn_19+0x99>
    18b1:	mov    ecx,0x2
    18b6:	cmp    r12,rdx
    18b9:	cmovge rcx,QWORD PTR [rip+0x117]        # 19d8 <botlish_fn_19+0x1b0>
    18c1:	cmp    rcx,0x6
    18c5:	je     1973 <botlish_fn_19+0x14b>
    18cb:	mov    rdx,r12
    18ce:	mov    rsi,rbx
    18d1:	mov    rdi,r13
    18d4:	call   18d9 <botlish_fn_19+0xb1>
			18d5: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    18d9:	test   rax,rax
    18dc:	je     198a <botlish_fn_19+0x162>
    18e2:	mov    QWORD PTR [rsp+0x8],rax
    18e7:	mov    rcx,rax
    18ea:	mov    QWORD PTR [rsp+0x20],rdx
    18ef:	mov    rsi,r15
    18f2:	mov    r12,rdx
    18f5:	mov    rdx,r14
    18f8:	mov    rdi,r13
    18fb:	call   1900 <botlish_fn_19+0xd8>
			18fc: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1900:	test   rax,rax
    1903:	je     198a <botlish_fn_19+0x162>
    1909:	mov    QWORD PTR [rsp+0x8],rax
    190e:	mov    r15,rax
    1911:	mov    QWORD PTR [rsp+0x10],0x3
    191a:	mov    rsi,r14
    191d:	test   rsi,0x1
    1924:	je     193f <botlish_fn_19+0x117>
    192a:	mov    rsi,r14
    192d:	mov    rax,rsi
    1930:	add    rax,0x2
    1934:	seto   cl
    1937:	test   cl,cl
    1939:	je     194f <botlish_fn_19+0x127>
    193f:	mov    edx,0x3
    1944:	mov    rsi,r14
    1947:	mov    rdi,r13
    194a:	call   194f <botlish_fn_19+0x127>
			194b: R_X86_64_PLT32	rt_int_add-0x4
    194f:	mov    QWORD PTR [rsp],rbx
    1953:	mov    rdx,r12
    1956:	mov    QWORD PTR [rsp+0x8],rdx
    195b:	mov    rcx,r15
    195e:	mov    QWORD PTR [rsp+0x10],rcx
    1963:	mov    QWORD PTR [rsp+0x18],rax
    1968:	mov    r14,rax
    196b:	mov    rax,rdx
    196e:	jmp    1874 <botlish_fn_19+0x4c>
    1973:	mov    rdx,r14
    1976:	mov    rsi,r15
    1979:	mov    rdi,r13
    197c:	call   1981 <botlish_fn_19+0x159>
			197d: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    1981:	test   rax,rax
    1984:	jne    19af <botlish_fn_19+0x187>
    198a:	xor    rax,rax
    198d:	mov    rbx,QWORD PTR [rsp+0x30]
    1992:	mov    r12,QWORD PTR [rsp+0x38]
    1997:	mov    r13,QWORD PTR [rsp+0x40]
    199c:	mov    r14,QWORD PTR [rsp+0x48]
    19a1:	mov    r15,QWORD PTR [rsp+0x50]
    19a6:	add    rsp,0x60
    19aa:	mov    rsp,rbp
    19ad:	pop    rbp
    19ae:	ret
    19af:	mov    rbx,QWORD PTR [rsp+0x30]
    19b4:	mov    r12,QWORD PTR [rsp+0x38]
    19b9:	mov    r13,QWORD PTR [rsp+0x40]
    19be:	mov    r14,QWORD PTR [rsp+0x48]
    19c3:	mov    r15,QWORD PTR [rsp+0x50]
    19c8:	add    rsp,0x60
    19cc:	mov    rsp,rbp
    19cf:	pop    rbp
    19d0:	ret
    19d1:	add    BYTE PTR [rax],al
    19d3:	add    BYTE PTR [rax],al
    19d5:	add    BYTE PTR [rax],al
    19d7:	add    BYTE PTR [rsi],al
    19d9:	add    BYTE PTR [rax],al
    19db:	add    BYTE PTR [rax],al
    19dd:	add    BYTE PTR [rax],al
	...

00000000000019e0 <botlish_entry_19: scan_records<str, int, mutarray, int>>:
    19e0:	push   rbp
    19e1:	mov    rbp,rsp
    19e4:	mov    rsi,QWORD PTR [rdx]
    19e7:	mov    r9,QWORD PTR [rdx+0x8]
    19eb:	mov    rcx,QWORD PTR [rdx+0x10]
    19ef:	mov    r8,QWORD PTR [rdx+0x18]
    19f3:	mov    rdx,r9
    19f6:	call   19fb <botlish_entry_19+0x1b>
			19f7: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    19fb:	mov    rsp,rbp
    19fe:	pop    rbp
    19ff:	ret

0000000000001a00 <botlish_fn_20: csv_parse<str>>:
    1a00:	push   rbp
    1a01:	mov    rbp,rsp
    1a04:	sub    rsp,0x40
    1a08:	mov    QWORD PTR [rsp+0x20],rbx
    1a0d:	mov    QWORD PTR [rsp+0x28],r12
    1a12:	mov    QWORD PTR [rsp+0x30],r13
    1a17:	mov    rbx,rdi
    1a1a:	mov    QWORD PTR [rsp+0x8],0x0
    1a23:	mov    QWORD PTR [rsp+0x10],0x0
    1a2c:	mov    QWORD PTR [rsp+0x18],0x0
    1a35:	mov    QWORD PTR [rsp],rsi
    1a39:	mov    rax,QWORD PTR [rsi+0x8]
    1a3d:	mov    r12,rsi
    1a40:	shl    rax,1
    1a43:	or     rax,0x1
    1a47:	sar    rax,1
    1a4a:	test   rax,rax
    1a4d:	je     1adc <botlish_fn_20+0xdc>
    1a53:	mov    edx,0x1
    1a58:	mov    QWORD PTR [rsp+0x8],0x1
    1a61:	mov    rsi,r12
    1a64:	mov    rdi,rbx
    1a67:	call   1a6c <botlish_fn_20+0x6c>
			1a68: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    1a6c:	test   rax,rax
    1a6f:	je     1af3 <botlish_fn_20+0xf3>
    1a75:	mov    QWORD PTR [rsp+0x8],rax
    1a7a:	mov    rsi,rax
    1a7d:	mov    QWORD PTR [rsp+0x10],rdx
    1a82:	mov    r13,rdx
    1a85:	mov    rdi,rbx
    1a88:	call   1a8d <botlish_fn_20+0x8d>
			1a89: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    1a8d:	test   rax,rax
    1a90:	je     1af3 <botlish_fn_20+0xf3>
    1a96:	mov    QWORD PTR [rsp+0x8],rax
    1a9b:	mov    rcx,rax
    1a9e:	mov    r8d,0x3
    1aa4:	mov    QWORD PTR [rsp+0x18],0x3
    1aad:	mov    rdx,r13
    1ab0:	mov    rsi,r12
    1ab3:	mov    rdi,rbx
    1ab6:	call   1abb <botlish_fn_20+0xbb>
			1ab7: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    1abb:	test   rax,rax
    1abe:	je     1af3 <botlish_fn_20+0xf3>
    1ac4:	mov    rbx,QWORD PTR [rsp+0x20]
    1ac9:	mov    r12,QWORD PTR [rsp+0x28]
    1ace:	mov    r13,QWORD PTR [rsp+0x30]
    1ad3:	add    rsp,0x40
    1ad7:	mov    rsp,rbp
    1ada:	pop    rbp
    1adb:	ret
    1adc:	xor    rdx,rdx
    1adf:	mov    rdi,rbx
    1ae2:	mov    rsi,rdx
    1ae5:	call   1aea <botlish_fn_20+0xea>
			1ae6: R_X86_64_PLT32	rt_list_new-0x4
    1aea:	test   rax,rax
    1aed:	jne    1b0e <botlish_fn_20+0x10e>
    1af3:	xor    rax,rax
    1af6:	mov    rbx,QWORD PTR [rsp+0x20]
    1afb:	mov    r12,QWORD PTR [rsp+0x28]
    1b00:	mov    r13,QWORD PTR [rsp+0x30]
    1b05:	add    rsp,0x40
    1b09:	mov    rsp,rbp
    1b0c:	pop    rbp
    1b0d:	ret
    1b0e:	mov    rbx,QWORD PTR [rsp+0x20]
    1b13:	mov    r12,QWORD PTR [rsp+0x28]
    1b18:	mov    r13,QWORD PTR [rsp+0x30]
    1b1d:	add    rsp,0x40
    1b21:	mov    rsp,rbp
    1b24:	pop    rbp
    1b25:	ret

0000000000001b26 <botlish_entry_20: csv_parse<str>>:
    1b26:	push   rbp
    1b27:	mov    rbp,rsp
    1b2a:	mov    rsi,QWORD PTR [rdx]
    1b2d:	call   1b32 <botlish_entry_20+0xc>
			1b2e: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    1b32:	mov    rsp,rbp
    1b35:	pop    rbp
    1b36:	ret

0000000000001b37 <botlish_fn_21: ht_alloc<int>>:
    1b37:	push   rbp
    1b38:	mov    rbp,rsp
    1b3b:	sub    rsp,0x70
    1b3f:	mov    QWORD PTR [rsp+0x40],rbx
    1b44:	mov    QWORD PTR [rsp+0x48],r12
    1b49:	mov    QWORD PTR [rsp+0x50],r13
    1b4e:	mov    QWORD PTR [rsp+0x58],r14
    1b53:	mov    QWORD PTR [rsp+0x60],r15
    1b58:	mov    r12,rdi
    1b5b:	mov    QWORD PTR [rsp+0x10],0x0
    1b64:	mov    QWORD PTR [rsp+0x18],0x0
    1b6d:	mov    QWORD PTR [rsp],rsi
    1b71:	mov    r13,rsi
    1b74:	mov    esi,0x5
    1b79:	mov    QWORD PTR [rsp+0x8],0x5
    1b82:	mov    rdi,r12
    1b85:	call   1b8a <botlish_fn_21+0x53>
			1b86: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b8a:	mov    rcx,rax
    1b8d:	mov    r14,rax
    1b90:	test   rax,rcx
    1b93:	je     1c22 <botlish_fn_21+0xeb>
    1b99:	mov    rax,r14
    1b9c:	mov    QWORD PTR [rsp+0x8],rax
    1ba1:	mov    ebx,0x1
    1ba6:	mov    rcx,rbx
    1ba9:	mov    rdx,rbx
    1bac:	mov    rsi,r14
    1baf:	mov    rdi,r12
    1bb2:	call   1bb7 <botlish_fn_21+0x80>
			1bb3: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1bb7:	mov    edx,0x3
    1bbc:	mov    rcx,rbx
    1bbf:	mov    rsi,r14
    1bc2:	mov    rdi,r12
    1bc5:	call   1bca <botlish_fn_21+0x93>
			1bc6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1bca:	mov    QWORD PTR [rsp+0x10],0x1
    1bd3:	mov    rdx,rbx
    1bd6:	mov    rsi,r13
    1bd9:	mov    rdi,r12
    1bdc:	call   1be1 <botlish_fn_21+0xaa>
			1bdd: R_X86_64_PLT32	rt_mutarray_create-0x4
    1be1:	test   rax,rax
    1be4:	je     1c22 <botlish_fn_21+0xeb>
    1bea:	mov    QWORD PTR [rsp+0x10],rax
    1bef:	mov    rbx,rax
    1bf2:	mov    rsi,r13
    1bf5:	mov    rdi,r12
    1bf8:	call   1bfd <botlish_fn_21+0xc6>
			1bf9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1bfd:	test   rax,rax
    1c00:	je     1c22 <botlish_fn_21+0xeb>
    1c06:	mov    QWORD PTR [rsp+0x18],rax
    1c0b:	mov    rsi,r13
    1c0e:	mov    r15,rax
    1c11:	mov    rdi,r12
    1c14:	call   1c19 <botlish_fn_21+0xe2>
			1c15: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1c19:	test   rax,rax
    1c1c:	jne    1c47 <botlish_fn_21+0x110>
    1c22:	xor    rax,rax
    1c25:	mov    rbx,QWORD PTR [rsp+0x40]
    1c2a:	mov    r12,QWORD PTR [rsp+0x48]
    1c2f:	mov    r13,QWORD PTR [rsp+0x50]
    1c34:	mov    r14,QWORD PTR [rsp+0x58]
    1c39:	mov    r15,QWORD PTR [rsp+0x60]
    1c3e:	add    rsp,0x70
    1c42:	mov    rsp,rbp
    1c45:	pop    rbp
    1c46:	ret
    1c47:	mov    QWORD PTR [rsp],rax
    1c4b:	lea    rcx,[rsp+0x20]
    1c50:	mov    rdx,rbx
    1c53:	mov    QWORD PTR [rsp+0x20],rdx
    1c58:	mov    rsi,r15
    1c5b:	mov    QWORD PTR [rsp+0x28],rsi
    1c60:	mov    QWORD PTR [rsp+0x30],rax
    1c65:	mov    rax,r14
    1c68:	mov    QWORD PTR [rsp+0x38],rax
    1c6d:	xor    rsi,rsi
    1c70:	mov    edx,0x4
    1c75:	mov    rdi,r12
    1c78:	call   1c7d <botlish_fn_21+0x146>
			1c79: R_X86_64_PLT32	rt_struct_new-0x4
    1c7d:	mov    rbx,QWORD PTR [rsp+0x40]
    1c82:	mov    r12,QWORD PTR [rsp+0x48]
    1c87:	mov    r13,QWORD PTR [rsp+0x50]
    1c8c:	mov    r14,QWORD PTR [rsp+0x58]
    1c91:	mov    r15,QWORD PTR [rsp+0x60]
    1c96:	add    rsp,0x70
    1c9a:	mov    rsp,rbp
    1c9d:	pop    rbp
    1c9e:	ret

0000000000001c9f <botlish_entry_21: ht_alloc<int>>:
    1c9f:	push   rbp
    1ca0:	mov    rbp,rsp
    1ca3:	mov    rsi,QWORD PTR [rdx]
    1ca6:	call   1cab <botlish_entry_21+0xc>
			1ca7: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1cab:	mov    rsp,rbp
    1cae:	pop    rbp
    1caf:	ret

0000000000001cb0 <botlish_fn_22: ht_alloc<int>>:
    1cb0:	push   rbp
    1cb1:	mov    rbp,rsp
    1cb4:	sub    rsp,0x60
    1cb8:	mov    QWORD PTR [rsp+0x30],rbx
    1cbd:	mov    QWORD PTR [rsp+0x38],r12
    1cc2:	mov    QWORD PTR [rsp+0x40],r13
    1cc7:	mov    QWORD PTR [rsp+0x48],r14
    1ccc:	mov    QWORD PTR [rsp+0x50],r15
    1cd1:	mov    r13,rdi
    1cd4:	mov    r15,rdx
    1cd7:	mov    QWORD PTR [rsp+0x10],0x0
    1ce0:	mov    QWORD PTR [rsp+0x18],0x0
    1ce9:	mov    QWORD PTR [rsp],rsi
    1ced:	mov    r12,rsi
    1cf0:	mov    esi,0x5
    1cf5:	mov    QWORD PTR [rsp+0x8],0x5
    1cfe:	mov    rdi,r13
    1d01:	call   1d06 <botlish_fn_22+0x56>
			1d02: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d06:	mov    rcx,rax
    1d09:	mov    r14,rax
    1d0c:	test   rax,rcx
    1d0f:	je     1da0 <botlish_fn_22+0xf0>
    1d15:	mov    rax,r14
    1d18:	mov    QWORD PTR [rsp+0x8],rax
    1d1d:	mov    ebx,0x1
    1d22:	mov    rcx,rbx
    1d25:	mov    rdx,rbx
    1d28:	mov    rsi,r14
    1d2b:	mov    rdi,r13
    1d2e:	call   1d33 <botlish_fn_22+0x83>
			1d2f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1d33:	mov    edx,0x3
    1d38:	mov    rcx,rbx
    1d3b:	mov    rsi,r14
    1d3e:	mov    rdi,r13
    1d41:	call   1d46 <botlish_fn_22+0x96>
			1d42: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1d46:	mov    QWORD PTR [rsp+0x10],0x1
    1d4f:	mov    rdx,rbx
    1d52:	mov    rsi,r12
    1d55:	mov    rdi,r13
    1d58:	call   1d5d <botlish_fn_22+0xad>
			1d59: R_X86_64_PLT32	rt_mutarray_create-0x4
    1d5d:	test   rax,rax
    1d60:	je     1da0 <botlish_fn_22+0xf0>
    1d66:	mov    QWORD PTR [rsp+0x10],rax
    1d6b:	mov    rbx,rax
    1d6e:	mov    rsi,r12
    1d71:	mov    rdi,r13
    1d74:	call   1d79 <botlish_fn_22+0xc9>
			1d75: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d79:	test   rax,rax
    1d7c:	je     1da0 <botlish_fn_22+0xf0>
    1d82:	mov    QWORD PTR [rsp+0x18],rax
    1d87:	mov    rsi,r12
    1d8a:	mov    rdi,r13
    1d8d:	mov    QWORD PTR [rsp+0x20],rax
    1d92:	call   1d97 <botlish_fn_22+0xe7>
			1d93: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d97:	test   rax,rax
    1d9a:	jne    1dc5 <botlish_fn_22+0x115>
    1da0:	xor    rax,rax
    1da3:	mov    rbx,QWORD PTR [rsp+0x30]
    1da8:	mov    r12,QWORD PTR [rsp+0x38]
    1dad:	mov    r13,QWORD PTR [rsp+0x40]
    1db2:	mov    r14,QWORD PTR [rsp+0x48]
    1db7:	mov    r15,QWORD PTR [rsp+0x50]
    1dbc:	add    rsp,0x60
    1dc0:	mov    rsp,rbp
    1dc3:	pop    rbp
    1dc4:	ret
    1dc5:	mov    rcx,QWORD PTR [rsp+0x20]
    1dca:	mov    rdx,r15
    1dcd:	mov    QWORD PTR [rdx],rcx
    1dd0:	mov    QWORD PTR [rdx+0x8],rax
    1dd4:	mov    rax,r14
    1dd7:	mov    QWORD PTR [rdx+0x10],rax
    1ddb:	mov    rax,rbx
    1dde:	mov    rbx,QWORD PTR [rsp+0x30]
    1de3:	mov    r12,QWORD PTR [rsp+0x38]
    1de8:	mov    r13,QWORD PTR [rsp+0x40]
    1ded:	mov    r14,QWORD PTR [rsp+0x48]
    1df2:	mov    r15,QWORD PTR [rsp+0x50]
    1df7:	add    rsp,0x60
    1dfb:	mov    rsp,rbp
    1dfe:	pop    rbp
    1dff:	ret

0000000000001e00 <botlish_entry_22: ht_alloc<int>>:
    1e00:	push   rbp
    1e01:	mov    rbp,rsp
    1e04:	ud2

0000000000001e06 <botlish_fn_23: ht_new<generic>>:
    1e06:	push   rbp
    1e07:	mov    rbp,rsp
    1e0a:	sub    rsp,0x10
    1e0e:	mov    esi,0x11
    1e13:	mov    QWORD PTR [rsp],0x11
    1e1b:	call   1e20 <botlish_fn_23+0x1a>
			1e1c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1e20:	test   rax,rax
    1e23:	jne    1e35 <botlish_fn_23+0x2f>
    1e29:	xor    rax,rax
    1e2c:	add    rsp,0x10
    1e30:	mov    rsp,rbp
    1e33:	pop    rbp
    1e34:	ret
    1e35:	add    rsp,0x10
    1e39:	mov    rsp,rbp
    1e3c:	pop    rbp
    1e3d:	ret

0000000000001e3e <botlish_entry_23: ht_new<generic>>:
    1e3e:	push   rbp
    1e3f:	mov    rbp,rsp
    1e42:	call   1e47 <botlish_entry_23+0x9>
			1e43: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    1e47:	mov    rsp,rbp
    1e4a:	pop    rbp
    1e4b:	ret
    1e4c:	add    BYTE PTR [rax],al
	...

0000000000001e50 <botlish_fn_24: ht_capacity_for<int, int>>:
    1e50:	push   rbp
    1e51:	mov    rbp,rsp
    1e54:	sub    rsp,0x50
    1e58:	mov    QWORD PTR [rsp+0x20],rbx
    1e5d:	mov    QWORD PTR [rsp+0x28],r12
    1e62:	mov    QWORD PTR [rsp+0x30],r13
    1e67:	mov    QWORD PTR [rsp+0x38],r14
    1e6c:	mov    QWORD PTR [rsp+0x40],r15
    1e71:	mov    r13,rdi
    1e74:	mov    QWORD PTR [rsp],rdx
    1e78:	mov    rbx,rsi
    1e7b:	or     rbx,0x1
    1e7f:	sar    rbx,1
    1e82:	mov    r12,rsi
    1e85:	mov    r14,rdx
    1e88:	mov    rax,r12
    1e8b:	or     rax,0x1
    1e8f:	mov    QWORD PTR [rsp+0x8],rax
    1e94:	mov    QWORD PTR [rsp+0x10],0x7
    1e9d:	mov    rax,rbx
    1ea0:	imul   QWORD PTR [rip+0x159]        # 2000 <botlish_fn_24+0x1b0>
    1ea7:	seto   cl
    1eaa:	or     rax,0x1
    1eae:	test   cl,cl
    1eb0:	jne    1ebe <botlish_fn_24+0x6e>
    1eb6:	mov    rsi,rax
    1eb9:	jmp    1ed5 <botlish_fn_24+0x85>
    1ebe:	mov    rsi,r12
    1ec1:	or     rsi,0x1
    1ec5:	mov    edx,0x7
    1eca:	mov    rdi,r13
    1ecd:	call   1ed2 <botlish_fn_24+0x82>
			1ece: R_X86_64_PLT32	rt_int_mul-0x4
    1ed2:	mov    rsi,rax
    1ed5:	mov    QWORD PTR [rsp+0x8],rsi
    1eda:	mov    r15,rsi
    1edd:	mov    QWORD PTR [rsp+0x10],0x5
    1ee6:	mov    rsi,r14
    1ee9:	test   rsi,0x1
    1ef0:	je     1f20 <botlish_fn_24+0xd0>
    1ef6:	mov    rsi,r14
    1ef9:	mov    rax,rsi
    1efc:	sar    rax,1
    1eff:	imul   QWORD PTR [rip+0x102]        # 2008 <botlish_fn_24+0x1b8>
    1f06:	seto   cl
    1f09:	or     rax,0x1
    1f0d:	test   cl,cl
    1f0f:	jne    1f20 <botlish_fn_24+0xd0>
    1f15:	mov    rdx,rax
    1f18:	mov    rsi,r15
    1f1b:	jmp    1f36 <botlish_fn_24+0xe6>
    1f20:	mov    edx,0x5
    1f25:	mov    rsi,r14
    1f28:	mov    rdi,r13
    1f2b:	call   1f30 <botlish_fn_24+0xe0>
			1f2c: R_X86_64_PLT32	rt_int_mul-0x4
    1f30:	mov    rdx,rax
    1f33:	mov    rsi,r15
    1f36:	mov    rax,rsi
    1f39:	and    rax,rdx
    1f3c:	test   rax,0x1
    1f42:	jne    1f65 <botlish_fn_24+0x115>
    1f48:	mov    rdi,r13
    1f4b:	call   1f50 <botlish_fn_24+0x100>
			1f4c: R_X86_64_PLT32	rt_int_cmp-0x4
    1f50:	mov    ecx,0x2
    1f55:	test   rax,rax
    1f58:	cmovle rcx,QWORD PTR [rip+0xa0]        # 2000 <botlish_fn_24+0x1b0>
    1f60:	jmp    1f75 <botlish_fn_24+0x125>
    1f65:	mov    ecx,0x2
    1f6a:	cmp    rsi,rdx
    1f6d:	cmovle rcx,QWORD PTR [rip+0x8b]        # 2000 <botlish_fn_24+0x1b0>
    1f75:	cmp    rcx,0x6
    1f79:	je     1fd5 <botlish_fn_24+0x185>
    1f7f:	mov    QWORD PTR [rsp+0x8],0x5
    1f88:	mov    rsi,r14
    1f8b:	test   rsi,0x1
    1f92:	je     1fb9 <botlish_fn_24+0x169>
    1f98:	mov    rsi,r14
    1f9b:	mov    rax,rsi
    1f9e:	sar    rax,1
    1fa1:	imul   QWORD PTR [rip+0x60]        # 2008 <botlish_fn_24+0x1b8>
    1fa8:	seto   sil
    1fac:	or     rax,0x1
    1fb0:	test   sil,sil
    1fb3:	je     1fc9 <botlish_fn_24+0x179>
    1fb9:	mov    edx,0x5
    1fbe:	mov    rsi,r14
    1fc1:	mov    rdi,r13
    1fc4:	call   1fc9 <botlish_fn_24+0x179>
			1fc5: R_X86_64_PLT32	rt_int_mul-0x4
    1fc9:	mov    QWORD PTR [rsp],rax
    1fcd:	mov    r14,rax
    1fd0:	jmp    1e88 <botlish_fn_24+0x38>
    1fd5:	mov    rax,r14
    1fd8:	mov    rbx,QWORD PTR [rsp+0x20]
    1fdd:	mov    r12,QWORD PTR [rsp+0x28]
    1fe2:	mov    r13,QWORD PTR [rsp+0x30]
    1fe7:	mov    r14,QWORD PTR [rsp+0x38]
    1fec:	mov    r15,QWORD PTR [rsp+0x40]
    1ff1:	add    rsp,0x50
    1ff5:	mov    rsp,rbp
    1ff8:	pop    rbp
    1ff9:	ret
    1ffa:	add    BYTE PTR [rax],al
    1ffc:	add    BYTE PTR [rax],al
    1ffe:	add    BYTE PTR [rax],al
    2000:	(bad)
    2001:	add    BYTE PTR [rax],al
    2003:	add    BYTE PTR [rax],al
    2005:	add    BYTE PTR [rax],al
    2007:	add    BYTE PTR [rax+rax*1],al
    200a:	add    BYTE PTR [rax],al
    200c:	add    BYTE PTR [rax],al
	...

0000000000002010 <botlish_entry_24: ht_capacity_for<int, int>>:
    2010:	push   rbp
    2011:	mov    rbp,rsp
    2014:	mov    rsi,QWORD PTR [rdx]
    2017:	mov    rdx,QWORD PTR [rdx+0x8]
    201b:	call   2020 <botlish_entry_24+0x10>
			201c: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    2020:	mov    rsp,rbp
    2023:	pop    rbp
    2024:	ret

0000000000002025 <botlish_fn_25: ht_new_sized<int>>:
    2025:	push   rbp
    2026:	mov    rbp,rsp
    2029:	sub    rsp,0x20
    202d:	mov    QWORD PTR [rsp+0x10],r12
    2032:	mov    r12,rdi
    2035:	mov    QWORD PTR [rsp],rsi
    2039:	mov    edx,0x11
    203e:	mov    QWORD PTR [rsp+0x8],0x11
    2047:	mov    rdi,r12
    204a:	call   204f <botlish_fn_25+0x2a>
			204b: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    204f:	mov    QWORD PTR [rsp],rax
    2053:	mov    rsi,rax
    2056:	mov    rdi,r12
    2059:	call   205e <botlish_fn_25+0x39>
			205a: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    205e:	test   rax,rax
    2061:	jne    2078 <botlish_fn_25+0x53>
    2067:	xor    rax,rax
    206a:	mov    r12,QWORD PTR [rsp+0x10]
    206f:	add    rsp,0x20
    2073:	mov    rsp,rbp
    2076:	pop    rbp
    2077:	ret
    2078:	mov    r12,QWORD PTR [rsp+0x10]
    207d:	add    rsp,0x20
    2081:	mov    rsp,rbp
    2084:	pop    rbp
    2085:	ret

0000000000002086 <botlish_entry_25: ht_new_sized<int>>:
    2086:	push   rbp
    2087:	mov    rbp,rsp
    208a:	mov    rsi,QWORD PTR [rdx]
    208d:	call   2092 <botlish_entry_25+0xc>
			208e: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    2092:	mov    rsp,rbp
    2095:	pop    rbp
    2096:	ret

0000000000002097 <botlish_fn_26: ht_size<HashTable>>:
    2097:	push   rbp
    2098:	mov    rbp,rsp
    209b:	mov    r9,QWORD PTR [rsi+0x18]
    209f:	mov    rsi,QWORD PTR [r9+0x18]
    20a3:	mov    edx,0x1
    20a8:	call   20ad <botlish_fn_26+0x16>
			20a9: R_X86_64_PLT32	rt_mutarray_get-0x4
    20ad:	test   rax,rax
    20b0:	jne    20be <botlish_fn_26+0x27>
    20b6:	xor    rax,rax
    20b9:	mov    rsp,rbp
    20bc:	pop    rbp
    20bd:	ret
    20be:	mov    rsp,rbp
    20c1:	pop    rbp
    20c2:	ret

00000000000020c3 <botlish_entry_26: ht_size<HashTable>>:
    20c3:	push   rbp
    20c4:	mov    rbp,rsp
    20c7:	mov    rsi,QWORD PTR [rdx]
    20ca:	call   20cf <botlish_entry_26+0xc>
			20cb: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    20cf:	mov    rsp,rbp
    20d2:	pop    rbp
    20d3:	ret

00000000000020d4 <botlish_fn_27: ht_tombstones<HashTable>>:
    20d4:	push   rbp
    20d5:	mov    rbp,rsp
    20d8:	mov    r9,QWORD PTR [rsi+0x18]
    20dc:	mov    rsi,QWORD PTR [r9+0x18]
    20e0:	mov    edx,0x3
    20e5:	call   20ea <botlish_fn_27+0x16>
			20e6: R_X86_64_PLT32	rt_mutarray_get-0x4
    20ea:	test   rax,rax
    20ed:	jne    20fb <botlish_fn_27+0x27>
    20f3:	xor    rax,rax
    20f6:	mov    rsp,rbp
    20f9:	pop    rbp
    20fa:	ret
    20fb:	mov    rsp,rbp
    20fe:	pop    rbp
    20ff:	ret

0000000000002100 <botlish_entry_27: ht_tombstones<HashTable>>:
    2100:	push   rbp
    2101:	mov    rbp,rsp
    2104:	mov    rsi,QWORD PTR [rdx]
    2107:	call   210c <botlish_entry_27+0xc>
			2108: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    210c:	mov    rsp,rbp
    210f:	pop    rbp
    2110:	ret

0000000000002111 <botlish_fn_28: ht_capacity<HashTable>>:
    2111:	push   rbp
    2112:	mov    rbp,rsp
    2115:	mov    rsi,QWORD PTR [rsi+0x18]
    2119:	mov    rsi,QWORD PTR [rsi]
    211c:	call   2121 <botlish_fn_28+0x10>
			211d: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2121:	mov    rsp,rbp
    2124:	pop    rbp
    2125:	ret

0000000000002126 <botlish_entry_28: ht_capacity<HashTable>>:
    2126:	push   rbp
    2127:	mov    rbp,rsp
    212a:	mov    rsi,QWORD PTR [rdx]
    212d:	call   2132 <botlish_entry_28+0xc>
			212e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2132:	mov    rsp,rbp
    2135:	pop    rbp
    2136:	ret

0000000000002137 <botlish_fn_29: ht_probe_start<HashTable, str>>:
    2137:	push   rbp
    2138:	mov    rbp,rsp
    213b:	sub    rsp,0x20
    213f:	mov    QWORD PTR [rsp],r12
    2143:	mov    QWORD PTR [rsp+0x8],r13
    2148:	mov    QWORD PTR [rsp+0x10],r14
    214d:	mov    r12,rdi
    2150:	mov    r13,rsi
    2153:	mov    rsi,rdx
    2156:	mov    rdi,r12
    2159:	call   215e <botlish_fn_29+0x27>
			215a: R_X86_64_PLT32	rt_hash-0x4
    215e:	test   rax,rax
    2161:	mov    r14,rax
    2164:	je     218c <botlish_fn_29+0x55>
    216a:	mov    rsi,r13
    216d:	mov    rdi,r12
    2170:	call   2175 <botlish_fn_29+0x3e>
			2171: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2175:	mov    rdx,rax
    2178:	mov    rsi,r14
    217b:	mov    rdi,r12
    217e:	call   2183 <botlish_fn_29+0x4c>
			217f: R_X86_64_PLT32	rt_int_mod-0x4
    2183:	test   rax,rax
    2186:	jne    21a6 <botlish_fn_29+0x6f>
    218c:	xor    rax,rax
    218f:	mov    r12,QWORD PTR [rsp]
    2193:	mov    r13,QWORD PTR [rsp+0x8]
    2198:	mov    r14,QWORD PTR [rsp+0x10]
    219d:	add    rsp,0x20
    21a1:	mov    rsp,rbp
    21a4:	pop    rbp
    21a5:	ret
    21a6:	mov    r12,QWORD PTR [rsp]
    21aa:	mov    r13,QWORD PTR [rsp+0x8]
    21af:	mov    r14,QWORD PTR [rsp+0x10]
    21b4:	add    rsp,0x20
    21b8:	mov    rsp,rbp
    21bb:	pop    rbp
    21bc:	ret

00000000000021bd <botlish_entry_29: ht_probe_start<HashTable, str>>:
    21bd:	push   rbp
    21be:	mov    rbp,rsp
    21c1:	mov    rsi,QWORD PTR [rdx]
    21c4:	mov    rdx,QWORD PTR [rdx+0x8]
    21c8:	call   21cd <botlish_entry_29+0x10>
			21c9: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    21cd:	mov    rsp,rbp
    21d0:	pop    rbp
    21d1:	ret

00000000000021d2 <botlish_fn_30: ht_probe_next<HashTable, int>>:
    21d2:	push   rbp
    21d3:	mov    rbp,rsp
    21d6:	sub    rsp,0x40
    21da:	mov    QWORD PTR [rsp+0x20],rbx
    21df:	mov    QWORD PTR [rsp+0x28],r12
    21e4:	mov    QWORD PTR [rsp+0x30],r14
    21e9:	mov    r14,rdi
    21ec:	mov    QWORD PTR [rsp],rsi
    21f0:	mov    rbx,rsi
    21f3:	mov    QWORD PTR [rsp+0x8],rdx
    21f8:	mov    QWORD PTR [rsp+0x10],0x3
    2201:	test   rdx,0x1
    2208:	jne    2216 <botlish_fn_30+0x44>
    220e:	mov    rsi,rdx
    2211:	jmp    2236 <botlish_fn_30+0x64>
    2216:	mov    rsi,rdx
    2219:	add    rsi,0x2
    221d:	mov    r12,rsi
    2220:	mov    rsi,rdx
    2223:	seto   al
    2226:	test   al,al
    2228:	jne    2236 <botlish_fn_30+0x64>
    222e:	mov    rsi,rbx
    2231:	jmp    2249 <botlish_fn_30+0x77>
    2236:	mov    edx,0x3
    223b:	mov    rdi,r14
    223e:	call   2243 <botlish_fn_30+0x71>
			223f: R_X86_64_PLT32	rt_int_add-0x4
    2243:	mov    rsi,rbx
    2246:	mov    r12,rax
    2249:	mov    rdi,r14
    224c:	call   2251 <botlish_fn_30+0x7f>
			224d: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2251:	mov    rdx,rax
    2254:	mov    rsi,r12
    2257:	mov    rdi,r14
    225a:	call   225f <botlish_fn_30+0x8d>
			225b: R_X86_64_PLT32	rt_int_mod-0x4
    225f:	test   rax,rax
    2262:	jne    2283 <botlish_fn_30+0xb1>
    2268:	xor    rax,rax
    226b:	mov    rbx,QWORD PTR [rsp+0x20]
    2270:	mov    r12,QWORD PTR [rsp+0x28]
    2275:	mov    r14,QWORD PTR [rsp+0x30]
    227a:	add    rsp,0x40
    227e:	mov    rsp,rbp
    2281:	pop    rbp
    2282:	ret
    2283:	mov    rbx,QWORD PTR [rsp+0x20]
    2288:	mov    r12,QWORD PTR [rsp+0x28]
    228d:	mov    r14,QWORD PTR [rsp+0x30]
    2292:	add    rsp,0x40
    2296:	mov    rsp,rbp
    2299:	pop    rbp
    229a:	ret

000000000000229b <botlish_entry_30: ht_probe_next<HashTable, int>>:
    229b:	push   rbp
    229c:	mov    rbp,rsp
    229f:	mov    rsi,QWORD PTR [rdx]
    22a2:	mov    rdx,QWORD PTR [rdx+0x8]
    22a6:	call   22ab <botlish_entry_30+0x10>
			22a7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    22ab:	mov    rsp,rbp
    22ae:	pop    rbp
    22af:	ret

00000000000022b0 <botlish_fn_31: ht_find_get<HashTable, str, int>>:
    22b0:	push   rbp
    22b1:	mov    rbp,rsp
    22b4:	sub    rsp,0x50
    22b8:	mov    QWORD PTR [rsp+0x20],rbx
    22bd:	mov    QWORD PTR [rsp+0x28],r12
    22c2:	mov    QWORD PTR [rsp+0x30],r13
    22c7:	mov    QWORD PTR [rsp+0x38],r14
    22cc:	mov    QWORD PTR [rsp+0x40],r15
    22d1:	mov    r13,rdi
    22d4:	mov    QWORD PTR [rsp],rsi
    22d8:	mov    QWORD PTR [rsp+0x8],rdx
    22dd:	mov    rbx,rdx
    22e0:	mov    QWORD PTR [rsp+0x10],rcx
    22e5:	mov    r12,rsi
    22e8:	mov    r14,rcx
    22eb:	mov    rax,QWORD PTR [r12+0x18]
    22f0:	mov    rsi,QWORD PTR [rax]
    22f3:	mov    rdx,r14
    22f6:	mov    rdi,r13
    22f9:	call   22fe <botlish_fn_31+0x4e>
			22fa: R_X86_64_PLT32	rt_mutarray_get-0x4
    22fe:	mov    rcx,rax
    2301:	mov    r15,rax
    2304:	test   rax,rcx
    2307:	je     2457 <botlish_fn_31+0x1a7>
    230d:	mov    rax,r15
    2310:	test   rax,0x1
    2316:	jne    2344 <botlish_fn_31+0x94>
    231c:	mov    edx,0x1
    2321:	mov    rsi,r15
    2324:	mov    rdi,r13
    2327:	call   232c <botlish_fn_31+0x7c>
			2328: R_X86_64_PLT32	rt_int_cmp-0x4
    232c:	mov    ecx,0x2
    2331:	test   rax,rax
    2334:	cmove  rcx,QWORD PTR [rip+0x1a4]        # 24e0 <botlish_fn_31+0x230>
    233c:	mov    rax,r15
    233f:	jmp    2358 <botlish_fn_31+0xa8>
    2344:	mov    ecx,0x2
    2349:	mov    rax,r15
    234c:	cmp    rax,0x1
    2350:	cmove  rcx,QWORD PTR [rip+0x188]        # 24e0 <botlish_fn_31+0x230>
    2358:	cmp    rcx,0x6
    235c:	je     24b7 <botlish_fn_31+0x207>
    2362:	test   rax,0x1
    2368:	mov    r15,rax
    236b:	jne    2396 <botlish_fn_31+0xe6>
    2371:	mov    edx,0x3
    2376:	mov    rsi,r15
    2379:	mov    rdi,r13
    237c:	call   2381 <botlish_fn_31+0xd1>
			237d: R_X86_64_PLT32	rt_int_cmp-0x4
    2381:	mov    ecx,0x2
    2386:	test   rax,rax
    2389:	cmove  rcx,QWORD PTR [rip+0x14f]        # 24e0 <botlish_fn_31+0x230>
    2391:	jmp    23aa <botlish_fn_31+0xfa>
    2396:	mov    rsi,r15
    2399:	mov    ecx,0x2
    239e:	cmp    rsi,0x3
    23a2:	cmove  rcx,QWORD PTR [rip+0x136]        # 24e0 <botlish_fn_31+0x230>
    23aa:	cmp    rcx,0x6
    23ae:	je     23be <botlish_fn_31+0x10e>
    23b4:	mov    eax,0x2
    23b9:	jmp    2436 <botlish_fn_31+0x186>
    23be:	mov    rcx,QWORD PTR [r12+0x18]
    23c3:	mov    rsi,QWORD PTR [rcx+0x8]
    23c7:	mov    rdx,r14
    23ca:	mov    rdi,r13
    23cd:	call   23d2 <botlish_fn_31+0x122>
			23ce: R_X86_64_PLT32	rt_mutarray_get-0x4
    23d2:	test   rax,rax
    23d5:	je     2457 <botlish_fn_31+0x1a7>
    23db:	mov    rsi,rax
    23de:	and    rsi,rbx
    23e1:	test   rsi,0x1
    23e8:	jne    240a <botlish_fn_31+0x15a>
    23ee:	mov    rsi,rax
    23f1:	mov    rdx,rbx
    23f4:	mov    rdi,r13
    23f7:	call   23fc <botlish_fn_31+0x14c>
			23f8: R_X86_64_PLT32	rt_value_eq-0x4
    23fc:	test   rax,rax
    23ff:	je     2457 <botlish_fn_31+0x1a7>
    2405:	jmp    241d <botlish_fn_31+0x16d>
    240a:	mov    rsi,rax
    240d:	mov    eax,0x2
    2412:	cmp    rsi,rbx
    2415:	cmove  rax,QWORD PTR [rip+0xc3]        # 24e0 <botlish_fn_31+0x230>
    241d:	cmp    rax,0x6
    2421:	je     2431 <botlish_fn_31+0x181>
    2427:	mov    eax,0x2
    242c:	jmp    2436 <botlish_fn_31+0x186>
    2431:	mov    eax,0x6
    2436:	cmp    rax,0x6
    243a:	je     2492 <botlish_fn_31+0x1e2>
    2440:	mov    rdx,r14
    2443:	mov    rsi,r12
    2446:	mov    rdi,r13
    2449:	call   244e <botlish_fn_31+0x19e>
			244a: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    244e:	test   rax,rax
    2451:	jne    247c <botlish_fn_31+0x1cc>
    2457:	xor    rax,rax
    245a:	mov    rbx,QWORD PTR [rsp+0x20]
    245f:	mov    r12,QWORD PTR [rsp+0x28]
    2464:	mov    r13,QWORD PTR [rsp+0x30]
    2469:	mov    r14,QWORD PTR [rsp+0x38]
    246e:	mov    r15,QWORD PTR [rsp+0x40]
    2473:	add    rsp,0x50
    2477:	mov    rsp,rbp
    247a:	pop    rbp
    247b:	ret
    247c:	mov    QWORD PTR [rsp],r12
    2480:	mov    QWORD PTR [rsp+0x8],rbx
    2485:	mov    QWORD PTR [rsp+0x10],rax
    248a:	mov    r14,rax
    248d:	jmp    22eb <botlish_fn_31+0x3b>
    2492:	mov    rax,r14
    2495:	mov    rbx,QWORD PTR [rsp+0x20]
    249a:	mov    r12,QWORD PTR [rsp+0x28]
    249f:	mov    r13,QWORD PTR [rsp+0x30]
    24a4:	mov    r14,QWORD PTR [rsp+0x38]
    24a9:	mov    r15,QWORD PTR [rsp+0x40]
    24ae:	add    rsp,0x50
    24b2:	mov    rsp,rbp
    24b5:	pop    rbp
    24b6:	ret
    24b7:	mov    rax,0xffffffffffffffff
    24be:	mov    rbx,QWORD PTR [rsp+0x20]
    24c3:	mov    r12,QWORD PTR [rsp+0x28]
    24c8:	mov    r13,QWORD PTR [rsp+0x30]
    24cd:	mov    r14,QWORD PTR [rsp+0x38]
    24d2:	mov    r15,QWORD PTR [rsp+0x40]
    24d7:	add    rsp,0x50
    24db:	mov    rsp,rbp
    24de:	pop    rbp
    24df:	ret
    24e0:	(bad)
    24e1:	add    BYTE PTR [rax],al
    24e3:	add    BYTE PTR [rax],al
    24e5:	add    BYTE PTR [rax],al
	...

00000000000024e8 <botlish_entry_31: ht_find_get<HashTable, str, int>>:
    24e8:	push   rbp
    24e9:	mov    rbp,rsp
    24ec:	mov    rsi,QWORD PTR [rdx]
    24ef:	mov    r8,QWORD PTR [rdx+0x8]
    24f3:	mov    rcx,QWORD PTR [rdx+0x10]
    24f7:	mov    rdx,r8
    24fa:	call   24ff <botlish_entry_31+0x17>
			24fb: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    24ff:	mov    rsp,rbp
    2502:	pop    rbp
    2503:	ret
    2504:	add    BYTE PTR [rax],al
	...

0000000000002508 <botlish_fn_32: ht_find_insert<HashTable, str, int, int>>:
    2508:	push   rbp
    2509:	mov    rbp,rsp
    250c:	sub    rsp,0x60
    2510:	mov    QWORD PTR [rsp+0x30],rbx
    2515:	mov    QWORD PTR [rsp+0x38],r12
    251a:	mov    QWORD PTR [rsp+0x40],r13
    251f:	mov    QWORD PTR [rsp+0x48],r14
    2524:	mov    QWORD PTR [rsp+0x50],r15
    2529:	mov    r14,rdi
    252c:	mov    QWORD PTR [rsp],rsi
    2530:	mov    QWORD PTR [rsp+0x8],rdx
    2535:	mov    r12,rdx
    2538:	mov    QWORD PTR [rsp+0x10],rcx
    253d:	mov    QWORD PTR [rsp+0x18],r8
    2542:	mov    rbx,rsi
    2545:	mov    r15,rcx
    2548:	mov    QWORD PTR [rsp+0x20],r8
    254d:	mov    r9,QWORD PTR [rbx+0x18]
    2551:	mov    rsi,QWORD PTR [r9]
    2554:	mov    rdx,r15
    2557:	mov    rdi,r14
    255a:	call   255f <botlish_fn_32+0x57>
			255b: R_X86_64_PLT32	rt_mutarray_get-0x4
    255f:	mov    rcx,rax
    2562:	mov    r13,rax
    2565:	test   rax,rcx
    2568:	je     27b8 <botlish_fn_32+0x2b0>
    256e:	mov    rax,r13
    2571:	test   rax,0x1
    2577:	jne    25a2 <botlish_fn_32+0x9a>
    257d:	mov    edx,0x1
    2582:	mov    rsi,r13
    2585:	mov    rdi,r14
    2588:	call   258d <botlish_fn_32+0x85>
			2589: R_X86_64_PLT32	rt_int_cmp-0x4
    258d:	mov    ecx,0x2
    2592:	test   rax,rax
    2595:	cmove  rcx,QWORD PTR [rip+0x333]        # 28d0 <botlish_fn_32+0x3c8>
    259d:	jmp    25b6 <botlish_fn_32+0xae>
    25a2:	mov    ecx,0x2
    25a7:	mov    rax,r13
    25aa:	cmp    rax,0x1
    25ae:	cmove  rcx,QWORD PTR [rip+0x31a]        # 28d0 <botlish_fn_32+0x3c8>
    25b6:	cmp    rcx,0x6
    25ba:	je     2825 <botlish_fn_32+0x31d>
    25c0:	mov    rax,r13
    25c3:	test   rax,0x1
    25c9:	jne    25f4 <botlish_fn_32+0xec>
    25cf:	mov    edx,0x3
    25d4:	mov    rsi,r13
    25d7:	mov    rdi,r14
    25da:	call   25df <botlish_fn_32+0xd7>
			25db: R_X86_64_PLT32	rt_int_cmp-0x4
    25df:	mov    ecx,0x2
    25e4:	test   rax,rax
    25e7:	cmove  rcx,QWORD PTR [rip+0x2e1]        # 28d0 <botlish_fn_32+0x3c8>
    25ef:	jmp    2608 <botlish_fn_32+0x100>
    25f4:	mov    ecx,0x2
    25f9:	mov    rax,r13
    25fc:	cmp    rax,0x3
    2600:	cmove  rcx,QWORD PTR [rip+0x2c8]        # 28d0 <botlish_fn_32+0x3c8>
    2608:	cmp    rcx,0x6
    260c:	je     261c <botlish_fn_32+0x114>
    2612:	mov    eax,0x2
    2617:	jmp    2690 <botlish_fn_32+0x188>
    261c:	mov    rax,QWORD PTR [rbx+0x18]
    2620:	mov    rsi,QWORD PTR [rax+0x8]
    2624:	mov    rdx,r15
    2627:	mov    rdi,r14
    262a:	call   262f <botlish_fn_32+0x127>
			262b: R_X86_64_PLT32	rt_mutarray_get-0x4
    262f:	test   rax,rax
    2632:	je     27b8 <botlish_fn_32+0x2b0>
    2638:	mov    rcx,rax
    263b:	and    rcx,r12
    263e:	mov    rsi,rax
    2641:	test   rcx,0x1
    2648:	jne    2667 <botlish_fn_32+0x15f>
    264e:	mov    rdx,r12
    2651:	mov    rdi,r14
    2654:	call   2659 <botlish_fn_32+0x151>
			2655: R_X86_64_PLT32	rt_value_eq-0x4
    2659:	test   rax,rax
    265c:	je     27b8 <botlish_fn_32+0x2b0>
    2662:	jmp    2677 <botlish_fn_32+0x16f>
    2667:	mov    eax,0x2
    266c:	cmp    rsi,r12
    266f:	cmove  rax,QWORD PTR [rip+0x259]        # 28d0 <botlish_fn_32+0x3c8>
    2677:	cmp    rax,0x6
    267b:	je     268b <botlish_fn_32+0x183>
    2681:	mov    eax,0x2
    2686:	jmp    2690 <botlish_fn_32+0x188>
    268b:	mov    eax,0x6
    2690:	cmp    rax,0x6
    2694:	je     2800 <botlish_fn_32+0x2f8>
    269a:	mov    rax,r13
    269d:	test   rax,0x1
    26a3:	jne    26ce <botlish_fn_32+0x1c6>
    26a9:	mov    edx,0x5
    26ae:	mov    rsi,r13
    26b1:	mov    rdi,r14
    26b4:	call   26b9 <botlish_fn_32+0x1b1>
			26b5: R_X86_64_PLT32	rt_int_cmp-0x4
    26b9:	mov    ecx,0x2
    26be:	test   rax,rax
    26c1:	cmove  rcx,QWORD PTR [rip+0x207]        # 28d0 <botlish_fn_32+0x3c8>
    26c9:	jmp    26e2 <botlish_fn_32+0x1da>
    26ce:	mov    rsi,r13
    26d1:	mov    ecx,0x2
    26d6:	cmp    rsi,0x5
    26da:	cmove  rcx,QWORD PTR [rip+0x1ee]        # 28d0 <botlish_fn_32+0x3c8>
    26e2:	cmp    rcx,0x6
    26e6:	je     26f6 <botlish_fn_32+0x1ee>
    26ec:	mov    eax,0x2
    26f1:	jmp    2760 <botlish_fn_32+0x258>
    26f6:	mov    r13,QWORD PTR [rsp+0x20]
    26fb:	test   r13,0x1
    2702:	jne    2732 <botlish_fn_32+0x22a>
    2708:	mov    edx,0x1
    270d:	mov    rsi,r13
    2710:	mov    rdi,r14
    2713:	call   2718 <botlish_fn_32+0x210>
			2714: R_X86_64_PLT32	rt_int_cmp-0x4
    2718:	mov    ecx,0x2
    271d:	test   rax,rax
    2720:	cmovl  rcx,QWORD PTR [rip+0x1a8]        # 28d0 <botlish_fn_32+0x3c8>
    2728:	mov    QWORD PTR [rsp+0x20],r13
    272d:	jmp    2747 <botlish_fn_32+0x23f>
    2732:	mov    ecx,0x2
    2737:	test   r13,r13
    273a:	mov    QWORD PTR [rsp+0x20],r13
    273f:	cmovle rcx,QWORD PTR [rip+0x189]        # 28d0 <botlish_fn_32+0x3c8>
    2747:	cmp    rcx,0x6
    274b:	je     275b <botlish_fn_32+0x253>
    2751:	mov    eax,0x2
    2756:	jmp    2760 <botlish_fn_32+0x258>
    275b:	mov    eax,0x6
    2760:	cmp    rax,0x6
    2764:	je     27a1 <botlish_fn_32+0x299>
    276a:	mov    rdx,r15
    276d:	mov    rsi,rbx
    2770:	mov    rdi,r14
    2773:	call   2778 <botlish_fn_32+0x270>
			2774: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2778:	test   rax,rax
    277b:	je     27b8 <botlish_fn_32+0x2b0>
    2781:	mov    QWORD PTR [rsp],rbx
    2785:	mov    QWORD PTR [rsp+0x8],r12
    278a:	mov    QWORD PTR [rsp+0x10],rax
    278f:	mov    rcx,QWORD PTR [rsp+0x20]
    2794:	mov    QWORD PTR [rsp+0x18],rcx
    2799:	mov    r15,rax
    279c:	jmp    254d <botlish_fn_32+0x45>
    27a1:	mov    rdx,r15
    27a4:	mov    rsi,rbx
    27a7:	mov    rdi,r14
    27aa:	call   27af <botlish_fn_32+0x2a7>
			27ab: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    27af:	test   rax,rax
    27b2:	jne    27dd <botlish_fn_32+0x2d5>
    27b8:	xor    rax,rax
    27bb:	mov    rbx,QWORD PTR [rsp+0x30]
    27c0:	mov    r12,QWORD PTR [rsp+0x38]
    27c5:	mov    r13,QWORD PTR [rsp+0x40]
    27ca:	mov    r14,QWORD PTR [rsp+0x48]
    27cf:	mov    r15,QWORD PTR [rsp+0x50]
    27d4:	add    rsp,0x60
    27d8:	mov    rsp,rbp
    27db:	pop    rbp
    27dc:	ret
    27dd:	mov    QWORD PTR [rsp],rbx
    27e1:	mov    QWORD PTR [rsp+0x8],r12
    27e6:	mov    QWORD PTR [rsp+0x10],rax
    27eb:	mov    rdx,r15
    27ee:	mov    QWORD PTR [rsp+0x18],rdx
    27f3:	mov    QWORD PTR [rsp+0x20],r15
    27f8:	mov    r15,rax
    27fb:	jmp    254d <botlish_fn_32+0x45>
    2800:	mov    rax,r15
    2803:	mov    rbx,QWORD PTR [rsp+0x30]
    2808:	mov    r12,QWORD PTR [rsp+0x38]
    280d:	mov    r13,QWORD PTR [rsp+0x40]
    2812:	mov    r14,QWORD PTR [rsp+0x48]
    2817:	mov    r15,QWORD PTR [rsp+0x50]
    281c:	add    rsp,0x60
    2820:	mov    rsp,rbp
    2823:	pop    rbp
    2824:	ret
    2825:	mov    rax,QWORD PTR [rsp+0x20]
    282a:	test   rax,0x1
    2830:	jne    285d <botlish_fn_32+0x355>
    2836:	mov    edx,0x1
    283b:	mov    rdi,r14
    283e:	mov    rsi,QWORD PTR [rsp+0x20]
    2843:	call   2848 <botlish_fn_32+0x340>
			2844: R_X86_64_PLT32	rt_int_cmp-0x4
    2848:	mov    ecx,0x2
    284d:	test   rax,rax
    2850:	cmovge rcx,QWORD PTR [rip+0x78]        # 28d0 <botlish_fn_32+0x3c8>
    2858:	jmp    2877 <botlish_fn_32+0x36f>
    285d:	mov    ecx,0x2
    2862:	mov    rax,QWORD PTR [rsp+0x20]
    2867:	mov    rdx,QWORD PTR [rsp+0x20]
    286c:	test   rax,rdx
    286f:	cmovg  rcx,QWORD PTR [rip+0x59]        # 28d0 <botlish_fn_32+0x3c8>
    2877:	cmp    rcx,0x6
    287b:	je     28a6 <botlish_fn_32+0x39e>
    2881:	mov    rax,r15
    2884:	mov    rbx,QWORD PTR [rsp+0x30]
    2889:	mov    r12,QWORD PTR [rsp+0x38]
    288e:	mov    r13,QWORD PTR [rsp+0x40]
    2893:	mov    r14,QWORD PTR [rsp+0x48]
    2898:	mov    r15,QWORD PTR [rsp+0x50]
    289d:	add    rsp,0x60
    28a1:	mov    rsp,rbp
    28a4:	pop    rbp
    28a5:	ret
    28a6:	mov    rax,QWORD PTR [rsp+0x20]
    28ab:	mov    rbx,QWORD PTR [rsp+0x30]
    28b0:	mov    r12,QWORD PTR [rsp+0x38]
    28b5:	mov    r13,QWORD PTR [rsp+0x40]
    28ba:	mov    r14,QWORD PTR [rsp+0x48]
    28bf:	mov    r15,QWORD PTR [rsp+0x50]
    28c4:	add    rsp,0x60
    28c8:	mov    rsp,rbp
    28cb:	pop    rbp
    28cc:	ret
    28cd:	add    BYTE PTR [rax],al
    28cf:	add    BYTE PTR [rsi],al
    28d1:	add    BYTE PTR [rax],al
    28d3:	add    BYTE PTR [rax],al
    28d5:	add    BYTE PTR [rax],al
	...

00000000000028d8 <botlish_entry_32: ht_find_insert<HashTable, str, int, int>>:
    28d8:	push   rbp
    28d9:	mov    rbp,rsp
    28dc:	mov    rsi,QWORD PTR [rdx]
    28df:	mov    r9,QWORD PTR [rdx+0x8]
    28e3:	mov    rcx,QWORD PTR [rdx+0x10]
    28e7:	mov    r8,QWORD PTR [rdx+0x18]
    28eb:	mov    rdx,r9
    28ee:	call   28f3 <botlish_entry_32+0x1b>
			28ef: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    28f3:	mov    rsp,rbp
    28f6:	pop    rbp
    28f7:	ret

00000000000028f8 <botlish_fn_33: ht_get<HashTable, str>>:
    28f8:	push   rbp
    28f9:	mov    rbp,rsp
    28fc:	sub    rsp,0x40
    2900:	mov    QWORD PTR [rsp+0x20],rbx
    2905:	mov    QWORD PTR [rsp+0x28],r12
    290a:	mov    QWORD PTR [rsp+0x30],r13
    290f:	mov    r12,rdi
    2912:	mov    QWORD PTR [rsp],rsi
    2916:	mov    QWORD PTR [rsp+0x8],rdx
    291b:	mov    r13,rdx
    291e:	mov    rbx,rsi
    2921:	mov    rdx,r13
    2924:	mov    rdi,r12
    2927:	call   292c <botlish_fn_33+0x34>
			2928: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    292c:	test   rax,rax
    292f:	je     29c7 <botlish_fn_33+0xcf>
    2935:	mov    QWORD PTR [rsp+0x10],rax
    293a:	mov    rcx,rax
    293d:	mov    rdx,r13
    2940:	mov    rsi,rbx
    2943:	mov    rdi,r12
    2946:	call   294b <botlish_fn_33+0x53>
			2947: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    294b:	mov    rcx,rax
    294e:	mov    r13,rax
    2951:	test   rax,rcx
    2954:	je     29c7 <botlish_fn_33+0xcf>
    295a:	mov    rax,r13
    295d:	test   rax,0x1
    2963:	jne    298e <botlish_fn_33+0x96>
    2969:	mov    edx,0x1
    296e:	mov    rsi,r13
    2971:	mov    rdi,r12
    2974:	call   2979 <botlish_fn_33+0x81>
			2975: R_X86_64_PLT32	rt_int_cmp-0x4
    2979:	mov    ecx,0x2
    297e:	test   rax,rax
    2981:	cmovl  rcx,QWORD PTR [rip+0x8f]        # 2a18 <botlish_fn_33+0x120>
    2989:	jmp    29a1 <botlish_fn_33+0xa9>
    298e:	mov    ecx,0x2
    2993:	mov    rax,r13
    2996:	test   rax,rax
    2999:	cmovle rcx,QWORD PTR [rip+0x77]        # 2a18 <botlish_fn_33+0x120>
    29a1:	cmp    rcx,0x6
    29a5:	je     29fa <botlish_fn_33+0x102>
    29ab:	mov    rax,QWORD PTR [rbx+0x18]
    29af:	mov    rsi,QWORD PTR [rax+0x10]
    29b3:	mov    rdx,r13
    29b6:	mov    rdi,r12
    29b9:	call   29be <botlish_fn_33+0xc6>
			29ba: R_X86_64_PLT32	rt_mutarray_get-0x4
    29be:	test   rax,rax
    29c1:	jne    29e2 <botlish_fn_33+0xea>
    29c7:	xor    rax,rax
    29ca:	mov    rbx,QWORD PTR [rsp+0x20]
    29cf:	mov    r12,QWORD PTR [rsp+0x28]
    29d4:	mov    r13,QWORD PTR [rsp+0x30]
    29d9:	add    rsp,0x40
    29dd:	mov    rsp,rbp
    29e0:	pop    rbp
    29e1:	ret
    29e2:	mov    rbx,QWORD PTR [rsp+0x20]
    29e7:	mov    r12,QWORD PTR [rsp+0x28]
    29ec:	mov    r13,QWORD PTR [rsp+0x30]
    29f1:	add    rsp,0x40
    29f5:	mov    rsp,rbp
    29f8:	pop    rbp
    29f9:	ret
    29fa:	mov    eax,0xa
    29ff:	mov    rbx,QWORD PTR [rsp+0x20]
    2a04:	mov    r12,QWORD PTR [rsp+0x28]
    2a09:	mov    r13,QWORD PTR [rsp+0x30]
    2a0e:	add    rsp,0x40
    2a12:	mov    rsp,rbp
    2a15:	pop    rbp
    2a16:	ret
    2a17:	add    BYTE PTR [rsi],al
    2a19:	add    BYTE PTR [rax],al
    2a1b:	add    BYTE PTR [rax],al
    2a1d:	add    BYTE PTR [rax],al
	...

0000000000002a20 <botlish_entry_33: ht_get<HashTable, str>>:
    2a20:	push   rbp
    2a21:	mov    rbp,rsp
    2a24:	mov    rsi,QWORD PTR [rdx]
    2a27:	mov    rdx,QWORD PTR [rdx+0x8]
    2a2b:	call   2a30 <botlish_entry_33+0x10>
			2a2c: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    2a30:	mov    rsp,rbp
    2a33:	pop    rbp
    2a34:	ret
    2a35:	add    BYTE PTR [rax],al
	...

0000000000002a38 <botlish_fn_34: ht_rehash_probe<mutarray, int, int>>:
    2a38:	push   rbp
    2a39:	mov    rbp,rsp
    2a3c:	sub    rsp,0x40
    2a40:	mov    QWORD PTR [rsp+0x20],rbx
    2a45:	mov    QWORD PTR [rsp+0x28],r12
    2a4a:	mov    QWORD PTR [rsp+0x30],r13
    2a4f:	mov    QWORD PTR [rsp+0x38],r14
    2a54:	mov    r13,rdi
    2a57:	mov    QWORD PTR [rsp],rsi
    2a5b:	mov    QWORD PTR [rsp+0x8],rdx
    2a60:	mov    QWORD PTR [rsp+0x10],rcx
    2a65:	mov    r12,rcx
    2a68:	mov    rbx,rsi
    2a6b:	mov    r14,rdx
    2a6e:	mov    rdx,r14
    2a71:	mov    rsi,rbx
    2a74:	mov    rdi,r13
    2a77:	call   2a7c <botlish_fn_34+0x44>
			2a78: R_X86_64_PLT32	rt_mutarray_get-0x4
    2a7c:	test   rax,rax
    2a7f:	je     2b1c <botlish_fn_34+0xe4>
    2a85:	test   rax,0x1
    2a8b:	mov    rsi,rax
    2a8e:	jne    2aaf <botlish_fn_34+0x77>
    2a94:	mov    edx,0x1
    2a99:	mov    rdi,r13
    2a9c:	call   2aa1 <botlish_fn_34+0x69>
			2a9d: R_X86_64_PLT32	rt_value_eq-0x4
    2aa1:	test   rax,rax
    2aa4:	je     2b1c <botlish_fn_34+0xe4>
    2aaa:	jmp    2ac0 <botlish_fn_34+0x88>
    2aaf:	mov    eax,0x2
    2ab4:	cmp    rsi,0x1
    2ab8:	cmove  rax,QWORD PTR [rip+0xb8]        # 2b78 <botlish_fn_34+0x140>
    2ac0:	cmp    rax,0x6
    2ac4:	je     2b52 <botlish_fn_34+0x11a>
    2aca:	mov    QWORD PTR [rsp+0x18],0x3
    2ad3:	mov    rsi,r14
    2ad6:	test   rsi,0x1
    2add:	je     2af5 <botlish_fn_34+0xbd>
    2ae3:	mov    rsi,r14
    2ae6:	add    rsi,0x2
    2aea:	seto   al
    2aed:	test   al,al
    2aef:	je     2b08 <botlish_fn_34+0xd0>
    2af5:	mov    edx,0x3
    2afa:	mov    rsi,r14
    2afd:	mov    rdi,r13
    2b00:	call   2b05 <botlish_fn_34+0xcd>
			2b01: R_X86_64_PLT32	rt_int_add-0x4
    2b05:	mov    rsi,rax
    2b08:	mov    rdx,r12
    2b0b:	mov    rdi,r13
    2b0e:	call   2b13 <botlish_fn_34+0xdb>
			2b0f: R_X86_64_PLT32	rt_int_mod-0x4
    2b13:	test   rax,rax
    2b16:	jne    2b3c <botlish_fn_34+0x104>
    2b1c:	xor    rax,rax
    2b1f:	mov    rbx,QWORD PTR [rsp+0x20]
    2b24:	mov    r12,QWORD PTR [rsp+0x28]
    2b29:	mov    r13,QWORD PTR [rsp+0x30]
    2b2e:	mov    r14,QWORD PTR [rsp+0x38]
    2b33:	add    rsp,0x40
    2b37:	mov    rsp,rbp
    2b3a:	pop    rbp
    2b3b:	ret
    2b3c:	mov    QWORD PTR [rsp],rbx
    2b40:	mov    QWORD PTR [rsp+0x8],rax
    2b45:	mov    QWORD PTR [rsp+0x10],r12
    2b4a:	mov    r14,rax
    2b4d:	jmp    2a6e <botlish_fn_34+0x36>
    2b52:	mov    rax,r14
    2b55:	mov    rbx,QWORD PTR [rsp+0x20]
    2b5a:	mov    r12,QWORD PTR [rsp+0x28]
    2b5f:	mov    r13,QWORD PTR [rsp+0x30]
    2b64:	mov    r14,QWORD PTR [rsp+0x38]
    2b69:	add    rsp,0x40
    2b6d:	mov    rsp,rbp
    2b70:	pop    rbp
    2b71:	ret
    2b72:	add    BYTE PTR [rax],al
    2b74:	add    BYTE PTR [rax],al
    2b76:	add    BYTE PTR [rax],al
    2b78:	(bad)
    2b79:	add    BYTE PTR [rax],al
    2b7b:	add    BYTE PTR [rax],al
    2b7d:	add    BYTE PTR [rax],al
	...

0000000000002b80 <botlish_entry_34: ht_rehash_probe<mutarray, int, int>>:
    2b80:	push   rbp
    2b81:	mov    rbp,rsp
    2b84:	mov    rsi,QWORD PTR [rdx]
    2b87:	mov    r8,QWORD PTR [rdx+0x8]
    2b8b:	mov    rcx,QWORD PTR [rdx+0x10]
    2b8f:	mov    rdx,r8
    2b92:	call   2b97 <botlish_entry_34+0x17>
			2b93: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2b97:	mov    rsp,rbp
    2b9a:	pop    rbp
    2b9b:	ret

0000000000002b9c <botlish_fn_35: ht_rehash_insert<HashTable, int, any, any>>:
    2b9c:	push   rbp
    2b9d:	mov    rbp,rsp
    2ba0:	sub    rsp,0x70
    2ba4:	mov    QWORD PTR [rsp+0x40],rbx
    2ba9:	mov    QWORD PTR [rsp+0x48],r12
    2bae:	mov    QWORD PTR [rsp+0x50],r13
    2bb3:	mov    QWORD PTR [rsp+0x58],r14
    2bb8:	mov    QWORD PTR [rsp+0x60],r15
    2bbd:	mov    r13,rdi
    2bc0:	mov    QWORD PTR [rsp],rsi
    2bc4:	mov    QWORD PTR [rsp+0x8],rdx
    2bc9:	mov    r15,rdx
    2bcc:	mov    QWORD PTR [rsp+0x10],rcx
    2bd1:	mov    r14,rcx
    2bd4:	mov    QWORD PTR [rsp+0x18],r8
    2bd9:	mov    r12,r8
    2bdc:	mov    rax,QWORD PTR [rsi+0x18]
    2be0:	mov    rbx,rsi
    2be3:	mov    rsi,QWORD PTR [rax]
    2be6:	mov    QWORD PTR [rsp+0x20],rsi
    2beb:	mov    QWORD PTR [rsp+0x30],rsi
    2bf0:	mov    rsi,r14
    2bf3:	mov    rdi,r13
    2bf6:	call   2bfb <botlish_fn_35+0x5f>
			2bf7: R_X86_64_PLT32	rt_hash-0x4
    2bfb:	test   rax,rax
    2bfe:	mov    rsi,rax
    2c01:	je     2ca0 <botlish_fn_35+0x104>
    2c07:	mov    rdx,r15
    2c0a:	mov    rdi,r13
    2c0d:	call   2c12 <botlish_fn_35+0x76>
			2c0e: R_X86_64_PLT32	rt_int_mod-0x4
    2c12:	test   rax,rax
    2c15:	je     2ca0 <botlish_fn_35+0x104>
    2c1b:	mov    QWORD PTR [rsp+0x28],rax
    2c20:	mov    rcx,r15
    2c23:	mov    rdx,rax
    2c26:	mov    rsi,QWORD PTR [rsp+0x30]
    2c2b:	mov    rdi,r13
    2c2e:	call   2c33 <botlish_fn_35+0x97>
			2c2f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2c33:	mov    rdx,rax
    2c36:	mov    r15,rax
    2c39:	test   rax,rdx
    2c3c:	je     2ca0 <botlish_fn_35+0x104>
    2c42:	mov    rcx,QWORD PTR [rbx+0x18]
    2c46:	mov    rsi,QWORD PTR [rcx]
    2c49:	mov    ecx,0x3
    2c4e:	mov    rdx,r15
    2c51:	mov    rdi,r13
    2c54:	call   2c59 <botlish_fn_35+0xbd>
			2c55: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c59:	test   rax,rax
    2c5c:	je     2ca0 <botlish_fn_35+0x104>
    2c62:	mov    rax,QWORD PTR [rbx+0x18]
    2c66:	mov    rsi,QWORD PTR [rax+0x8]
    2c6a:	mov    rcx,r14
    2c6d:	mov    rdx,r15
    2c70:	mov    rdi,r13
    2c73:	call   2c78 <botlish_fn_35+0xdc>
			2c74: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c78:	test   rax,rax
    2c7b:	je     2ca0 <botlish_fn_35+0x104>
    2c81:	mov    rax,QWORD PTR [rbx+0x18]
    2c85:	mov    rsi,QWORD PTR [rax+0x10]
    2c89:	mov    rcx,r12
    2c8c:	mov    rdx,r15
    2c8f:	mov    rdi,r13
    2c92:	call   2c97 <botlish_fn_35+0xfb>
			2c93: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c97:	test   rax,rax
    2c9a:	jne    2cc5 <botlish_fn_35+0x129>
    2ca0:	xor    rax,rax
    2ca3:	mov    rbx,QWORD PTR [rsp+0x40]
    2ca8:	mov    r12,QWORD PTR [rsp+0x48]
    2cad:	mov    r13,QWORD PTR [rsp+0x50]
    2cb2:	mov    r14,QWORD PTR [rsp+0x58]
    2cb7:	mov    r15,QWORD PTR [rsp+0x60]
    2cbc:	add    rsp,0x70
    2cc0:	mov    rsp,rbp
    2cc3:	pop    rbp
    2cc4:	ret
    2cc5:	mov    rax,rbx
    2cc8:	mov    rbx,QWORD PTR [rsp+0x40]
    2ccd:	mov    r12,QWORD PTR [rsp+0x48]
    2cd2:	mov    r13,QWORD PTR [rsp+0x50]
    2cd7:	mov    r14,QWORD PTR [rsp+0x58]
    2cdc:	mov    r15,QWORD PTR [rsp+0x60]
    2ce1:	add    rsp,0x70
    2ce5:	mov    rsp,rbp
    2ce8:	pop    rbp
    2ce9:	ret

0000000000002cea <botlish_entry_35: ht_rehash_insert<HashTable, int, any, any>>:
    2cea:	push   rbp
    2ceb:	mov    rbp,rsp
    2cee:	mov    rsi,QWORD PTR [rdx]
    2cf1:	mov    r9,QWORD PTR [rdx+0x8]
    2cf5:	mov    rcx,QWORD PTR [rdx+0x10]
    2cf9:	mov    r8,QWORD PTR [rdx+0x18]
    2cfd:	mov    rdx,r9
    2d00:	call   2d05 <botlish_entry_35+0x1b>
			2d01: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2d05:	mov    rsp,rbp
    2d08:	pop    rbp
    2d09:	ret
    2d0a:	add    BYTE PTR [rax],al
    2d0c:	add    BYTE PTR [rax],al
	...

0000000000002d10 <botlish_fn_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2d10:	push   rbp
    2d11:	mov    rbp,rsp
    2d14:	sub    rsp,0x90
    2d1b:	mov    QWORD PTR [rsp+0x60],rbx
    2d20:	mov    QWORD PTR [rsp+0x68],r12
    2d25:	mov    QWORD PTR [rsp+0x70],r13
    2d2a:	mov    QWORD PTR [rsp+0x78],r14
    2d2f:	mov    QWORD PTR [rsp+0x80],r15
    2d37:	mov    QWORD PTR [rsp+0x38],rdi
    2d3c:	mov    QWORD PTR [rsp+0x40],r9
    2d41:	mov    rdi,QWORD PTR [rbp+0x10]
    2d45:	mov    rbx,QWORD PTR [rbp+0x18]
    2d49:	mov    QWORD PTR [rsp],rsi
    2d4d:	mov    QWORD PTR [rsp+0x8],rdx
    2d52:	mov    r14,rdx
    2d55:	mov    QWORD PTR [rsp+0x10],rcx
    2d5a:	mov    r15,rcx
    2d5d:	mov    QWORD PTR [rsp+0x18],rdi
    2d62:	mov    QWORD PTR [rsp+0x20],rbx
    2d67:	sar    r8,1
    2d6a:	mov    rcx,QWORD PTR [rsp+0x40]
    2d6f:	mov    r12,r8
    2d72:	mov    QWORD PTR [rsp+0x48],rdi
    2d77:	cmp    r12,rcx
    2d7a:	mov    QWORD PTR [rsp+0x40],rcx
    2d7f:	jge    2ee6 <botlish_fn_36+0x1d6>
    2d85:	mov    rdx,r12
    2d88:	shl    rdx,1
    2d8b:	or     rdx,0x1
    2d8f:	mov    r13,rsi
    2d92:	mov    QWORD PTR [rsp+0x58],rdx
    2d97:	mov    rdi,QWORD PTR [rsp+0x38]
    2d9c:	call   2da1 <botlish_fn_36+0x91>
			2d9d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2da1:	test   rax,rax
    2da4:	je     2e8a <botlish_fn_36+0x17a>
    2daa:	test   rax,0x1
    2db0:	mov    rsi,rax
    2db3:	jne    2dd6 <botlish_fn_36+0xc6>
    2db9:	mov    edx,0x3
    2dbe:	mov    rdi,QWORD PTR [rsp+0x38]
    2dc3:	call   2dc8 <botlish_fn_36+0xb8>
			2dc4: R_X86_64_PLT32	rt_value_eq-0x4
    2dc8:	test   rax,rax
    2dcb:	je     2e8a <botlish_fn_36+0x17a>
    2dd1:	jmp    2de7 <botlish_fn_36+0xd7>
    2dd6:	mov    eax,0x2
    2ddb:	cmp    rsi,0x3
    2ddf:	cmove  rax,QWORD PTR [rip+0x131]        # 2f18 <botlish_fn_36+0x208>
    2de7:	cmp    rax,0x6
    2deb:	je     2e22 <botlish_fn_36+0x112>
    2df1:	mov    QWORD PTR [rsp],r13
    2df5:	mov    QWORD PTR [rsp+0x8],r14
    2dfa:	mov    QWORD PTR [rsp+0x10],r15
    2dff:	mov    rsi,QWORD PTR [rsp+0x48]
    2e04:	mov    QWORD PTR [rsp+0x18],rsi
    2e09:	mov    QWORD PTR [rsp+0x20],rbx
    2e0e:	add    r12,0x1
    2e15:	mov    rcx,QWORD PTR [rsp+0x40]
    2e1a:	mov    rsi,r13
    2e1d:	jmp    2d77 <botlish_fn_36+0x67>
    2e22:	mov    rdx,QWORD PTR [rsp+0x58]
    2e27:	mov    rsi,r14
    2e2a:	mov    rdi,QWORD PTR [rsp+0x38]
    2e2f:	call   2e34 <botlish_fn_36+0x124>
			2e30: R_X86_64_PLT32	rt_mutarray_get-0x4
    2e34:	test   rax,rax
    2e37:	je     2e8a <botlish_fn_36+0x17a>
    2e3d:	mov    QWORD PTR [rsp+0x28],rax
    2e42:	mov    rdx,QWORD PTR [rsp+0x58]
    2e47:	mov    QWORD PTR [rsp+0x50],rax
    2e4c:	mov    rsi,r15
    2e4f:	mov    rdi,QWORD PTR [rsp+0x38]
    2e54:	call   2e59 <botlish_fn_36+0x149>
			2e55: R_X86_64_PLT32	rt_mutarray_get-0x4
    2e59:	test   rax,rax
    2e5c:	je     2e8a <botlish_fn_36+0x17a>
    2e62:	mov    QWORD PTR [rsp+0x30],rax
    2e67:	mov    rcx,QWORD PTR [rsp+0x50]
    2e6c:	mov    rsi,QWORD PTR [rsp+0x48]
    2e71:	mov    r8,rax
    2e74:	mov    rdx,rbx
    2e77:	mov    rdi,QWORD PTR [rsp+0x38]
    2e7c:	call   2e81 <botlish_fn_36+0x171>
			2e7d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2e81:	test   rax,rax
    2e84:	jne    2eb5 <botlish_fn_36+0x1a5>
    2e8a:	xor    rax,rax
    2e8d:	mov    rbx,QWORD PTR [rsp+0x60]
    2e92:	mov    r12,QWORD PTR [rsp+0x68]
    2e97:	mov    r13,QWORD PTR [rsp+0x70]
    2e9c:	mov    r14,QWORD PTR [rsp+0x78]
    2ea1:	mov    r15,QWORD PTR [rsp+0x80]
    2ea9:	add    rsp,0x90
    2eb0:	mov    rsp,rbp
    2eb3:	pop    rbp
    2eb4:	ret
    2eb5:	mov    QWORD PTR [rsp],r13
    2eb9:	mov    QWORD PTR [rsp+0x8],r14
    2ebe:	mov    QWORD PTR [rsp+0x10],r15
    2ec3:	mov    QWORD PTR [rsp+0x18],rax
    2ec8:	mov    QWORD PTR [rsp+0x20],rbx
    2ecd:	add    r12,0x1
    2ed4:	mov    rcx,QWORD PTR [rsp+0x40]
    2ed9:	mov    rsi,r13
    2edc:	mov    QWORD PTR [rsp+0x48],rax
    2ee1:	jmp    2d77 <botlish_fn_36+0x67>
    2ee6:	mov    rax,QWORD PTR [rsp+0x48]
    2eeb:	mov    rbx,QWORD PTR [rsp+0x60]
    2ef0:	mov    r12,QWORD PTR [rsp+0x68]
    2ef5:	mov    r13,QWORD PTR [rsp+0x70]
    2efa:	mov    r14,QWORD PTR [rsp+0x78]
    2eff:	mov    r15,QWORD PTR [rsp+0x80]
    2f07:	add    rsp,0x90
    2f0e:	mov    rsp,rbp
    2f11:	pop    rbp
    2f12:	ret
    2f13:	add    BYTE PTR [rax],al
    2f15:	add    BYTE PTR [rax],al
    2f17:	add    BYTE PTR [rsi],al
    2f19:	add    BYTE PTR [rax],al
    2f1b:	add    BYTE PTR [rax],al
    2f1d:	add    BYTE PTR [rax],al
	...

0000000000002f20 <botlish_entry_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2f20:	push   rbp
    2f21:	mov    rbp,rsp
    2f24:	sub    rsp,0x10
    2f28:	mov    rsi,QWORD PTR [rdx]
    2f2b:	mov    r11,QWORD PTR [rdx+0x8]
    2f2f:	mov    rcx,QWORD PTR [rdx+0x10]
    2f33:	mov    r8,QWORD PTR [rdx+0x18]
    2f37:	mov    r9,QWORD PTR [rdx+0x20]
    2f3b:	mov    rax,QWORD PTR [rdx+0x28]
    2f3f:	mov    rdx,QWORD PTR [rdx+0x30]
    2f43:	sar    r9,1
    2f46:	mov    QWORD PTR [rsp],rax
    2f4a:	mov    QWORD PTR [rsp+0x8],rdx
    2f4f:	mov    rdx,r11
    2f52:	call   2f57 <botlish_entry_36+0x37>
			2f53: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2f57:	add    rsp,0x10
    2f5b:	mov    rsp,rbp
    2f5e:	pop    rbp
    2f5f:	ret

0000000000002f60 <botlish_fn_37: ht_rehash<HashTable, int>>:
    2f60:	push   rbp
    2f61:	mov    rbp,rsp
    2f64:	sub    rsp,0xf0
    2f6b:	mov    QWORD PTR [rsp+0xc0],rbx
    2f73:	mov    QWORD PTR [rsp+0xc8],r12
    2f7b:	mov    QWORD PTR [rsp+0xd0],r13
    2f83:	mov    QWORD PTR [rsp+0xd8],r14
    2f8b:	mov    QWORD PTR [rsp+0xe0],r15
    2f93:	mov    QWORD PTR [rsp+0x90],rdi
    2f9b:	mov    QWORD PTR [rsp+0x20],0x0
    2fa4:	mov    QWORD PTR [rsp+0x28],0x0
    2fad:	mov    QWORD PTR [rsp+0x30],0x0
    2fb6:	mov    QWORD PTR [rsp+0x38],0x0
    2fbf:	mov    QWORD PTR [rsp+0x40],0x0
    2fc8:	mov    QWORD PTR [rsp+0x48],0x0
    2fd1:	mov    QWORD PTR [rsp+0x50],0x0
    2fda:	mov    QWORD PTR [rsp+0x10],rsi
    2fdf:	mov    r14,rsi
    2fe2:	mov    QWORD PTR [rsp+0x18],rdx
    2fe7:	mov    QWORD PTR [rsp+0x98],rdx
    2fef:	lea    rdx,[rsp+0x58]
    2ff4:	mov    rsi,QWORD PTR [rsp+0x98]
    2ffc:	mov    rdi,QWORD PTR [rsp+0x90]
    3004:	call   3009 <botlish_fn_37+0xa9>
			3005: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    3009:	test   rax,rax
    300c:	je     3160 <botlish_fn_37+0x200>
    3012:	mov    QWORD PTR [rsp+0x10],rax
    3017:	mov    QWORD PTR [rsp+0xb8],rax
    301f:	mov    rbx,QWORD PTR [rsp+0x58]
    3024:	mov    QWORD PTR [rsp+0x20],rbx
    3029:	mov    r12,QWORD PTR [rsp+0x60]
    302e:	mov    QWORD PTR [rsp+0x28],r12
    3033:	mov    r13,QWORD PTR [rsp+0x68]
    3038:	mov    QWORD PTR [rsp+0x30],r13
    303d:	mov    rsi,r14
    3040:	mov    rdi,QWORD PTR [rsp+0x90]
    3048:	call   304d <botlish_fn_37+0xed>
			3049: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    304d:	test   rax,rax
    3050:	mov    rcx,rax
    3053:	je     3160 <botlish_fn_37+0x200>
    3059:	mov    edx,0x1
    305e:	mov    rsi,r13
    3061:	mov    rdi,QWORD PTR [rsp+0x90]
    3069:	call   306e <botlish_fn_37+0x10e>
			306a: R_X86_64_PLT32	rt_mutarray_set-0x4
    306e:	test   rax,rax
    3071:	je     3160 <botlish_fn_37+0x200>
    3077:	mov    rsi,r14
    307a:	mov    rax,QWORD PTR [rsi+0x18]
    307e:	mov    rcx,QWORD PTR [rax]
    3081:	mov    QWORD PTR [rsp+0x38],rcx
    3086:	mov    QWORD PTR [rsp+0xb0],rcx
    308e:	mov    rax,QWORD PTR [rsi+0x18]
    3092:	mov    r15,QWORD PTR [rax+0x8]
    3096:	mov    QWORD PTR [rsp+0x40],r15
    309b:	mov    rax,QWORD PTR [rsi+0x18]
    309f:	mov    r14,QWORD PTR [rax+0x10]
    30a3:	mov    QWORD PTR [rsp+0x48],r14
    30a8:	mov    r8d,0x1
    30ae:	mov    QWORD PTR [rsp+0xa8],r8
    30b6:	mov    QWORD PTR [rsp+0x50],0x1
    30bf:	mov    rdi,QWORD PTR [rsp+0x90]
    30c7:	call   30cc <botlish_fn_37+0x16c>
			30c8: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    30cc:	mov    QWORD PTR [rsp+0xa0],rax
    30d4:	lea    rcx,[rsp+0x70]
    30d9:	mov    rax,QWORD PTR [rsp+0xb8]
    30e1:	mov    QWORD PTR [rsp+0x70],rax
    30e6:	mov    QWORD PTR [rsp+0x78],rbx
    30eb:	mov    QWORD PTR [rsp+0x80],r12
    30f3:	mov    QWORD PTR [rsp+0x88],r13
    30fb:	xor    rsi,rsi
    30fe:	mov    edx,0x4
    3103:	mov    rdi,QWORD PTR [rsp+0x90]
    310b:	call   3110 <botlish_fn_37+0x1b0>
			310c: R_X86_64_PLT32	rt_struct_new-0x4
    3110:	mov    QWORD PTR [rsp+0x10],rax
    3115:	mov    rcx,QWORD PTR [rsp+0xa0]
    311d:	mov    r9,rcx
    3120:	sar    r9,1
    3123:	mov    QWORD PTR [rsp],rax
    3127:	mov    rdx,QWORD PTR [rsp+0x98]
    312f:	mov    QWORD PTR [rsp+0x8],rdx
    3134:	mov    rcx,r14
    3137:	mov    rdx,r15
    313a:	mov    rsi,QWORD PTR [rsp+0xb0]
    3142:	mov    rdi,QWORD PTR [rsp+0x90]
    314a:	mov    r8,QWORD PTR [rsp+0xa8]
    3152:	call   3157 <botlish_fn_37+0x1f7>
			3153: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    3157:	test   rax,rax
    315a:	jne    3197 <botlish_fn_37+0x237>
    3160:	xor    rax,rax
    3163:	mov    rbx,QWORD PTR [rsp+0xc0]
    316b:	mov    r12,QWORD PTR [rsp+0xc8]
    3173:	mov    r13,QWORD PTR [rsp+0xd0]
    317b:	mov    r14,QWORD PTR [rsp+0xd8]
    3183:	mov    r15,QWORD PTR [rsp+0xe0]
    318b:	add    rsp,0xf0
    3192:	mov    rsp,rbp
    3195:	pop    rbp
    3196:	ret
    3197:	mov    rbx,QWORD PTR [rsp+0xc0]
    319f:	mov    r12,QWORD PTR [rsp+0xc8]
    31a7:	mov    r13,QWORD PTR [rsp+0xd0]
    31af:	mov    r14,QWORD PTR [rsp+0xd8]
    31b7:	mov    r15,QWORD PTR [rsp+0xe0]
    31bf:	add    rsp,0xf0
    31c6:	mov    rsp,rbp
    31c9:	pop    rbp
    31ca:	ret

00000000000031cb <botlish_entry_37: ht_rehash<HashTable, int>>:
    31cb:	push   rbp
    31cc:	mov    rbp,rsp
    31cf:	mov    rsi,QWORD PTR [rdx]
    31d2:	mov    rdx,QWORD PTR [rdx+0x8]
    31d6:	call   31db <botlish_entry_37+0x10>
			31d7: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    31db:	mov    rsp,rbp
    31de:	pop    rbp
    31df:	ret

00000000000031e0 <botlish_fn_38: ht_should_grow<HashTable>>:
    31e0:	push   rbp
    31e1:	mov    rbp,rsp
    31e4:	sub    rsp,0x40
    31e8:	mov    QWORD PTR [rsp+0x20],rbx
    31ed:	mov    QWORD PTR [rsp+0x28],r12
    31f2:	mov    QWORD PTR [rsp+0x30],r13
    31f7:	mov    rbx,rdi
    31fa:	mov    QWORD PTR [rsp],rsi
    31fe:	mov    r12,rsi
    3201:	mov    rsi,r12
    3204:	mov    rdi,rbx
    3207:	call   320c <botlish_fn_38+0x2c>
			3208: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    320c:	mov    rcx,rax
    320f:	mov    r13,rax
    3212:	test   rax,rcx
    3215:	je     32ee <botlish_fn_38+0x10e>
    321b:	mov    rax,r13
    321e:	mov    QWORD PTR [rsp+0x8],rax
    3223:	mov    rsi,r12
    3226:	mov    rdi,rbx
    3229:	call   322e <botlish_fn_38+0x4e>
			322a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    322e:	mov    rcx,rax
    3231:	test   rcx,rcx
    3234:	je     32ee <botlish_fn_38+0x10e>
    323a:	mov    QWORD PTR [rsp+0x10],rcx
    323f:	mov    edx,0x1
    3244:	mov    rax,r13
    3247:	test   rax,0x1
    324d:	jne    3270 <botlish_fn_38+0x90>
    3253:	xor    edx,edx
    3255:	mov    rax,r13
    3258:	test   rax,0x7
    325e:	jne    3270 <botlish_fn_38+0x90>
    3264:	mov    rax,r13
    3267:	movzx  rax,BYTE PTR [rax]
    326b:	cmp    al,0x1
    326d:	sete   dl
    3270:	test   dl,dl
    3272:	jne    3293 <botlish_fn_38+0xb3>
    3278:	mov    rdi,rbx
    327b:	mov    rax,QWORD PTR [rdi+0x10]
    327f:	mov    rcx,QWORD PTR [rax+0x20]
    3283:	xor    rdx,rdx
    3286:	mov    rsi,r13
    3289:	call   328e <botlish_fn_38+0xae>
			328a: R_X86_64_PLT32	rt_type_error-0x4
    328e:	jmp    32ee <botlish_fn_38+0x10e>
    3293:	mov    eax,0x1
    3298:	test   rcx,0x1
    329f:	je     32ad <botlish_fn_38+0xcd>
    32a5:	mov    r8,rcx
    32a8:	jmp    32d0 <botlish_fn_38+0xf0>
    32ad:	xor    eax,eax
    32af:	test   rcx,0x7
    32b6:	je     32c4 <botlish_fn_38+0xe4>
    32bc:	mov    r8,rcx
    32bf:	jmp    32d0 <botlish_fn_38+0xf0>
    32c4:	movzx  rax,BYTE PTR [rcx]
    32c8:	mov    r8,rcx
    32cb:	cmp    al,0x1
    32cd:	sete   al
    32d0:	test   al,al
    32d2:	jne    3309 <botlish_fn_38+0x129>
    32d8:	mov    rdi,rbx
    32db:	mov    rax,QWORD PTR [rdi+0x10]
    32df:	mov    rcx,QWORD PTR [rax+0x20]
    32e3:	xor    rdx,rdx
    32e6:	mov    rsi,r8
    32e9:	call   32ee <botlish_fn_38+0x10e>
			32ea: R_X86_64_PLT32	rt_type_error-0x4
    32ee:	xor    rax,rax
    32f1:	mov    rbx,QWORD PTR [rsp+0x20]
    32f6:	mov    r12,QWORD PTR [rsp+0x28]
    32fb:	mov    r13,QWORD PTR [rsp+0x30]
    3300:	add    rsp,0x40
    3304:	mov    rsp,rbp
    3307:	pop    rbp
    3308:	ret
    3309:	mov    rcx,r8
    330c:	mov    rsi,r13
    330f:	mov    rax,rsi
    3312:	and    rax,rcx
    3315:	test   rax,0x1
    331b:	jne    332c <botlish_fn_38+0x14c>
    3321:	mov    rdx,r8
    3324:	mov    rsi,r13
    3327:	jmp    334a <botlish_fn_38+0x16a>
    332c:	mov    rcx,r8
    332f:	lea    rax,[rcx-0x1]
    3333:	mov    rsi,r13
    3336:	add    rsi,rax
    3339:	seto   al
    333c:	test   al,al
    333e:	je     3355 <botlish_fn_38+0x175>
    3344:	mov    rdx,r8
    3347:	mov    rsi,r13
    334a:	mov    rdi,rbx
    334d:	call   3352 <botlish_fn_38+0x172>
			334e: R_X86_64_PLT32	rt_int_add-0x4
    3352:	mov    rsi,rax
    3355:	mov    QWORD PTR [rsp+0x8],rsi
    335a:	mov    QWORD PTR [rsp+0x10],0x3
    3363:	test   rsi,0x1
    336a:	je     338d <botlish_fn_38+0x1ad>
    3370:	mov    rax,rsi
    3373:	add    rax,0x2
    3377:	mov    rcx,rax
    337a:	seto   al
    337d:	test   al,al
    337f:	jne    338d <botlish_fn_38+0x1ad>
    3385:	mov    rsi,rcx
    3388:	jmp    339d <botlish_fn_38+0x1bd>
    338d:	mov    edx,0x3
    3392:	mov    rdi,rbx
    3395:	call   339a <botlish_fn_38+0x1ba>
			3396: R_X86_64_PLT32	rt_int_add-0x4
    339a:	mov    rsi,rax
    339d:	mov    QWORD PTR [rsp+0x8],rsi
    33a2:	mov    edx,0x7
    33a7:	mov    rdi,rdx
    33aa:	mov    QWORD PTR [rsp+0x10],0x7
    33b3:	test   rsi,0x1
    33ba:	jne    33c8 <botlish_fn_38+0x1e8>
    33c0:	mov    rdx,rdi
    33c3:	jmp    33f4 <botlish_fn_38+0x214>
    33c8:	mov    rax,rsi
    33cb:	sar    rax,1
    33ce:	imul   QWORD PTR [rip+0xf3]        # 34c8 <botlish_fn_38+0x2e8>
    33d5:	seto   cl
    33d8:	or     rax,0x1
    33dc:	test   cl,cl
    33de:	je     33ec <botlish_fn_38+0x20c>
    33e4:	mov    rdx,rdi
    33e7:	jmp    33f4 <botlish_fn_38+0x214>
    33ec:	mov    rsi,rax
    33ef:	jmp    33ff <botlish_fn_38+0x21f>
    33f4:	mov    rdi,rbx
    33f7:	call   33fc <botlish_fn_38+0x21c>
			33f8: R_X86_64_PLT32	rt_int_mul-0x4
    33fc:	mov    rsi,rax
    33ff:	mov    QWORD PTR [rsp],rsi
    3403:	mov    r13,rsi
    3406:	mov    rsi,r12
    3409:	mov    rdi,rbx
    340c:	call   3411 <botlish_fn_38+0x231>
			340d: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3411:	mov    QWORD PTR [rsp+0x8],rax
    3416:	mov    QWORD PTR [rsp+0x10],0x5
    341f:	test   rax,0x1
    3425:	mov    rcx,rax
    3428:	je     3457 <botlish_fn_38+0x277>
    342e:	mov    rax,rcx
    3431:	sar    rax,1
    3434:	imul   QWORD PTR [rip+0x95]        # 34d0 <botlish_fn_38+0x2f0>
    343b:	seto   sil
    343f:	or     rax,0x1
    3443:	test   sil,sil
    3446:	jne    3457 <botlish_fn_38+0x277>
    344c:	mov    rdx,rax
    344f:	mov    rsi,r13
    3452:	jmp    346d <botlish_fn_38+0x28d>
    3457:	mov    edx,0x5
    345c:	mov    rsi,rcx
    345f:	mov    rdi,rbx
    3462:	call   3467 <botlish_fn_38+0x287>
			3463: R_X86_64_PLT32	rt_int_mul-0x4
    3467:	mov    rdx,rax
    346a:	mov    rsi,r13
    346d:	mov    rdi,rsi
    3470:	and    rdi,rdx
    3473:	test   rdi,0x1
    347a:	jne    34a0 <botlish_fn_38+0x2c0>
    3480:	mov    rdi,rbx
    3483:	call   3488 <botlish_fn_38+0x2a8>
			3484: R_X86_64_PLT32	rt_int_cmp-0x4
    3488:	mov    esi,0x2
    348d:	test   rax,rax
    3490:	mov    rax,rsi
    3493:	cmovg  rax,QWORD PTR [rip+0x2d]        # 34c8 <botlish_fn_38+0x2e8>
    349b:	jmp    34b0 <botlish_fn_38+0x2d0>
    34a0:	mov    eax,0x2
    34a5:	cmp    rsi,rdx
    34a8:	cmovg  rax,QWORD PTR [rip+0x18]        # 34c8 <botlish_fn_38+0x2e8>
    34b0:	mov    rbx,QWORD PTR [rsp+0x20]
    34b5:	mov    r12,QWORD PTR [rsp+0x28]
    34ba:	mov    r13,QWORD PTR [rsp+0x30]
    34bf:	add    rsp,0x40
    34c3:	mov    rsp,rbp
    34c6:	pop    rbp
    34c7:	ret
    34c8:	(bad)
    34c9:	add    BYTE PTR [rax],al
    34cb:	add    BYTE PTR [rax],al
    34cd:	add    BYTE PTR [rax],al
    34cf:	add    BYTE PTR [rax+rax*1],al
    34d2:	add    BYTE PTR [rax],al
    34d4:	add    BYTE PTR [rax],al
	...

00000000000034d8 <botlish_entry_38: ht_should_grow<HashTable>>:
    34d8:	push   rbp
    34d9:	mov    rbp,rsp
    34dc:	mov    rsi,QWORD PTR [rdx]
    34df:	call   34e4 <botlish_entry_38+0xc>
			34e0: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    34e4:	mov    rsp,rbp
    34e7:	pop    rbp
    34e8:	ret
    34e9:	add    BYTE PTR [rax],al
    34eb:	add    BYTE PTR [rax],al
    34ed:	add    BYTE PTR [rax],al
	...

00000000000034f0 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    34f0:	push   rbp
    34f1:	mov    rbp,rsp
    34f4:	sub    rsp,0x40
    34f8:	mov    QWORD PTR [rsp+0x20],rbx
    34fd:	mov    QWORD PTR [rsp+0x28],r12
    3502:	mov    QWORD PTR [rsp+0x30],r13
    3507:	mov    rbx,rdi
    350a:	mov    QWORD PTR [rsp+0x10],0x0
    3513:	mov    QWORD PTR [rsp],rsi
    3517:	mov    r12,rsi
    351a:	mov    rsi,r12
    351d:	mov    rdi,rbx
    3520:	call   3525 <botlish_fn_39+0x35>
			3521: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3525:	test   rax,rax
    3528:	mov    r13,rax
    352b:	je     3719 <botlish_fn_39+0x229>
    3531:	mov    rsi,r12
    3534:	mov    rdi,rbx
    3537:	call   353c <botlish_fn_39+0x4c>
			3538: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    353c:	mov    r11,rax
    353f:	test   r11,r11
    3542:	je     3719 <botlish_fn_39+0x229>
    3548:	mov    ecx,0x1
    354d:	mov    rax,r13
    3550:	test   rax,0x1
    3556:	je     3564 <botlish_fn_39+0x74>
    355c:	mov    r13,rax
    355f:	jmp    3588 <botlish_fn_39+0x98>
    3564:	xor    ecx,ecx
    3566:	test   rax,0x7
    356c:	je     357a <botlish_fn_39+0x8a>
    3572:	mov    r13,rax
    3575:	jmp    3588 <botlish_fn_39+0x98>
    357a:	movzx  rcx,BYTE PTR [rax]
    357e:	mov    r13,rax
    3581:	rex cmp cl,0x1
    3585:	sete   cl
    3588:	test   cl,cl
    358a:	jne    35ab <botlish_fn_39+0xbb>
    3590:	mov    rdi,rbx
    3593:	mov    rsi,QWORD PTR [rdi+0x10]
    3597:	mov    rcx,QWORD PTR [rsi+0x28]
    359b:	xor    rdx,rdx
    359e:	mov    rsi,r13
    35a1:	call   35a6 <botlish_fn_39+0xb6>
			35a2: R_X86_64_PLT32	rt_type_error-0x4
    35a6:	jmp    3719 <botlish_fn_39+0x229>
    35ab:	mov    rsi,r13
    35ae:	mov    eax,0x1
    35b3:	test   r11,0x1
    35ba:	je     35c8 <botlish_fn_39+0xd8>
    35c0:	mov    r8,r11
    35c3:	jmp    35ed <botlish_fn_39+0xfd>
    35c8:	xor    eax,eax
    35ca:	test   r11,0x7
    35d1:	je     35df <botlish_fn_39+0xef>
    35d7:	mov    r8,r11
    35da:	jmp    35ed <botlish_fn_39+0xfd>
    35df:	movzx  r10,BYTE PTR [r11]
    35e3:	mov    r8,r11
    35e6:	cmp    r10b,0x1
    35ea:	sete   al
    35ed:	test   al,al
    35ef:	jne    3610 <botlish_fn_39+0x120>
    35f5:	mov    rdi,rbx
    35f8:	mov    rax,QWORD PTR [rdi+0x10]
    35fc:	mov    rcx,QWORD PTR [rax+0x28]
    3600:	xor    rdx,rdx
    3603:	mov    rsi,r8
    3606:	call   360b <botlish_fn_39+0x11b>
			3607: R_X86_64_PLT32	rt_type_error-0x4
    360b:	jmp    3719 <botlish_fn_39+0x229>
    3610:	mov    r11,r8
    3613:	mov    rax,rsi
    3616:	and    rax,r11
    3619:	test   rax,0x1
    361f:	jne    3645 <botlish_fn_39+0x155>
    3625:	mov    rdx,r8
    3628:	mov    rdi,rbx
    362b:	call   3630 <botlish_fn_39+0x140>
			362c: R_X86_64_PLT32	rt_int_cmp-0x4
    3630:	mov    ecx,0x2
    3635:	test   rax,rax
    3638:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3750 <botlish_fn_39+0x260>
    3640:	jmp    3658 <botlish_fn_39+0x168>
    3645:	mov    ecx,0x2
    364a:	mov    r11,r8
    364d:	cmp    rsi,r11
    3650:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3750 <botlish_fn_39+0x260>
    3658:	cmp    rcx,0x6
    365c:	je     36f2 <botlish_fn_39+0x202>
    3662:	mov    rsi,r12
    3665:	mov    rdi,rbx
    3668:	call   366d <botlish_fn_39+0x17d>
			3669: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    366d:	mov    QWORD PTR [rsp+0x8],rax
    3672:	mov    QWORD PTR [rsp+0x10],0x5
    367b:	test   rax,0x1
    3681:	mov    rsi,rax
    3684:	je     36b1 <botlish_fn_39+0x1c1>
    368a:	mov    rcx,rsi
    368d:	mov    rax,rcx
    3690:	sar    rax,1
    3693:	imul   QWORD PTR [rip+0xbe]        # 3758 <botlish_fn_39+0x268>
    369a:	seto   cl
    369d:	or     rax,0x1
    36a1:	test   cl,cl
    36a3:	jne    36b1 <botlish_fn_39+0x1c1>
    36a9:	mov    rdx,rax
    36ac:	jmp    36c1 <botlish_fn_39+0x1d1>
    36b1:	mov    edx,0x5
    36b6:	mov    rdi,rbx
    36b9:	call   36be <botlish_fn_39+0x1ce>
			36ba: R_X86_64_PLT32	rt_int_mul-0x4
    36be:	mov    rdx,rax
    36c1:	mov    QWORD PTR [rsp+0x8],rdx
    36c6:	mov    rsi,r12
    36c9:	mov    rdi,rbx
    36cc:	call   36d1 <botlish_fn_39+0x1e1>
			36cd: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    36d1:	test   rax,rax
    36d4:	je     3719 <botlish_fn_39+0x229>
    36da:	mov    rbx,QWORD PTR [rsp+0x20]
    36df:	mov    r12,QWORD PTR [rsp+0x28]
    36e4:	mov    r13,QWORD PTR [rsp+0x30]
    36e9:	add    rsp,0x40
    36ed:	mov    rsp,rbp
    36f0:	pop    rbp
    36f1:	ret
    36f2:	mov    rsi,r12
    36f5:	mov    rdi,rbx
    36f8:	call   36fd <botlish_fn_39+0x20d>
			36f9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    36fd:	mov    QWORD PTR [rsp+0x8],rax
    3702:	mov    rdx,rax
    3705:	mov    rsi,r12
    3708:	mov    rdi,rbx
    370b:	call   3710 <botlish_fn_39+0x220>
			370c: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3710:	test   rax,rax
    3713:	jne    3734 <botlish_fn_39+0x244>
    3719:	xor    rax,rax
    371c:	mov    rbx,QWORD PTR [rsp+0x20]
    3721:	mov    r12,QWORD PTR [rsp+0x28]
    3726:	mov    r13,QWORD PTR [rsp+0x30]
    372b:	add    rsp,0x40
    372f:	mov    rsp,rbp
    3732:	pop    rbp
    3733:	ret
    3734:	mov    rbx,QWORD PTR [rsp+0x20]
    3739:	mov    r12,QWORD PTR [rsp+0x28]
    373e:	mov    r13,QWORD PTR [rsp+0x30]
    3743:	add    rsp,0x40
    3747:	mov    rsp,rbp
    374a:	pop    rbp
    374b:	ret
    374c:	add    BYTE PTR [rax],al
    374e:	add    BYTE PTR [rax],al
    3750:	(bad)
    3751:	add    BYTE PTR [rax],al
    3753:	add    BYTE PTR [rax],al
    3755:	add    BYTE PTR [rax],al
    3757:	add    BYTE PTR [rax+rax*1],al
    375a:	add    BYTE PTR [rax],al
    375c:	add    BYTE PTR [rax],al
	...

0000000000003760 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    3760:	push   rbp
    3761:	mov    rbp,rsp
    3764:	mov    rsi,QWORD PTR [rdx]
    3767:	call   376c <botlish_entry_39+0xc>
			3768: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    376c:	mov    rsp,rbp
    376f:	pop    rbp
    3770:	ret
    3771:	add    BYTE PTR [rax],al
    3773:	add    BYTE PTR [rax],al
    3775:	add    BYTE PTR [rax],al
	...

0000000000003778 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    3778:	push   rbp
    3779:	mov    rbp,rsp
    377c:	sub    rsp,0x70
    3780:	mov    QWORD PTR [rsp+0x40],rbx
    3785:	mov    QWORD PTR [rsp+0x48],r12
    378a:	mov    QWORD PTR [rsp+0x50],r13
    378f:	mov    QWORD PTR [rsp+0x58],r14
    3794:	mov    QWORD PTR [rsp+0x60],r15
    3799:	mov    r12,rdi
    379c:	mov    r14,r8
    379f:	mov    r15,rdx
    37a2:	mov    QWORD PTR [rsp+0x30],rcx
    37a7:	mov    QWORD PTR [rsp],rsi
    37ab:	mov    r9,QWORD PTR [rsi+0x18]
    37af:	mov    r13,rsi
    37b2:	mov    rsi,QWORD PTR [r9]
    37b5:	mov    rdx,r15
    37b8:	mov    rdi,r12
    37bb:	call   37c0 <botlish_fn_40+0x48>
			37bc: R_X86_64_PLT32	rt_mutarray_get-0x4
    37c0:	test   rax,rax
    37c3:	je     3a58 <botlish_fn_40+0x2e0>
    37c9:	mov    QWORD PTR [rsp+0x8],rax
    37ce:	mov    rbx,r13
    37d1:	mov    r13,rax
    37d4:	mov    rax,QWORD PTR [rbx+0x18]
    37d8:	mov    rsi,QWORD PTR [rax]
    37db:	mov    ecx,0x3
    37e0:	mov    rdx,r15
    37e3:	mov    rdi,r12
    37e6:	call   37eb <botlish_fn_40+0x73>
			37e7: R_X86_64_PLT32	rt_mutarray_set-0x4
    37eb:	test   rax,rax
    37ee:	je     3a58 <botlish_fn_40+0x2e0>
    37f4:	mov    rax,QWORD PTR [rbx+0x18]
    37f8:	mov    rsi,QWORD PTR [rax+0x8]
    37fc:	mov    rcx,QWORD PTR [rsp+0x30]
    3801:	mov    rdx,r15
    3804:	mov    rdi,r12
    3807:	call   380c <botlish_fn_40+0x94>
			3808: R_X86_64_PLT32	rt_mutarray_set-0x4
    380c:	test   rax,rax
    380f:	je     3a58 <botlish_fn_40+0x2e0>
    3815:	mov    rax,QWORD PTR [rbx+0x18]
    3819:	mov    rsi,QWORD PTR [rax+0x10]
    381d:	mov    rcx,r14
    3820:	mov    rdx,r15
    3823:	mov    rdi,r12
    3826:	call   382b <botlish_fn_40+0xb3>
			3827: R_X86_64_PLT32	rt_mutarray_set-0x4
    382b:	test   rax,rax
    382e:	je     3a58 <botlish_fn_40+0x2e0>
    3834:	mov    rax,QWORD PTR [rbx+0x18]
    3838:	mov    rsi,QWORD PTR [rax+0x18]
    383c:	mov    QWORD PTR [rsp+0x10],rsi
    3841:	mov    r14,rsi
    3844:	mov    QWORD PTR [rsp+0x18],0x1
    384d:	mov    rsi,rbx
    3850:	mov    rdi,r12
    3853:	call   3858 <botlish_fn_40+0xe0>
			3854: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3858:	test   rax,rax
    385b:	je     3a58 <botlish_fn_40+0x2e0>
    3861:	mov    QWORD PTR [rsp+0x20],rax
    3866:	mov    QWORD PTR [rsp+0x28],0x3
    386f:	mov    ecx,0x1
    3874:	test   rax,0x1
    387a:	je     3888 <botlish_fn_40+0x110>
    3880:	mov    rsi,rax
    3883:	jmp    38ac <botlish_fn_40+0x134>
    3888:	xor    ecx,ecx
    388a:	test   rax,0x7
    3890:	je     389e <botlish_fn_40+0x126>
    3896:	mov    rsi,rax
    3899:	jmp    38ac <botlish_fn_40+0x134>
    389e:	movzx  rcx,BYTE PTR [rax]
    38a2:	mov    rsi,rax
    38a5:	rex cmp cl,0x1
    38a9:	sete   cl
    38ac:	test   cl,cl
    38ae:	jne    38cc <botlish_fn_40+0x154>
    38b4:	mov    rdi,r12
    38b7:	mov    rax,QWORD PTR [rdi+0x10]
    38bb:	mov    rcx,QWORD PTR [rax+0x20]
    38bf:	xor    rdx,rdx
    38c2:	call   38c7 <botlish_fn_40+0x14f>
			38c3: R_X86_64_PLT32	rt_type_error-0x4
    38c7:	jmp    3a58 <botlish_fn_40+0x2e0>
    38cc:	test   rsi,0x1
    38d3:	je     38eb <botlish_fn_40+0x173>
    38d9:	mov    rcx,rsi
    38dc:	add    rcx,0x2
    38e0:	seto   al
    38e3:	test   al,al
    38e5:	je     38fb <botlish_fn_40+0x183>
    38eb:	mov    edx,0x3
    38f0:	mov    rdi,r12
    38f3:	call   38f8 <botlish_fn_40+0x180>
			38f4: R_X86_64_PLT32	rt_int_add-0x4
    38f8:	mov    rcx,rax
    38fb:	mov    edx,0x1
    3900:	mov    rsi,r14
    3903:	mov    rdi,r12
    3906:	call   390b <botlish_fn_40+0x193>
			3907: R_X86_64_PLT32	rt_mutarray_set-0x4
    390b:	test   rax,rax
    390e:	je     3a58 <botlish_fn_40+0x2e0>
    3914:	mov    rax,r13
    3917:	test   rax,0x1
    391d:	jne    3948 <botlish_fn_40+0x1d0>
    3923:	mov    edx,0x5
    3928:	mov    rsi,r13
    392b:	mov    rdi,r12
    392e:	call   3933 <botlish_fn_40+0x1bb>
			392f: R_X86_64_PLT32	rt_int_cmp-0x4
    3933:	mov    ecx,0x2
    3938:	test   rax,rax
    393b:	cmove  rcx,QWORD PTR [rip+0x165]        # 3aa8 <botlish_fn_40+0x330>
    3943:	jmp    395c <botlish_fn_40+0x1e4>
    3948:	mov    rsi,r13
    394b:	mov    ecx,0x2
    3950:	cmp    rsi,0x5
    3954:	cmove  rcx,QWORD PTR [rip+0x14c]        # 3aa8 <botlish_fn_40+0x330>
    395c:	cmp    rcx,0x6
    3960:	je     396e <botlish_fn_40+0x1f6>
    3966:	mov    rax,rbx
    3969:	jmp    3a80 <botlish_fn_40+0x308>
    396e:	mov    rax,QWORD PTR [rbx+0x18]
    3972:	mov    rsi,QWORD PTR [rax+0x18]
    3976:	mov    QWORD PTR [rsp+0x8],rsi
    397b:	mov    r14,rsi
    397e:	mov    QWORD PTR [rsp+0x10],0x3
    3987:	mov    rsi,rbx
    398a:	mov    rdi,r12
    398d:	call   3992 <botlish_fn_40+0x21a>
			398e: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3992:	mov    r13,rbx
    3995:	test   rax,rax
    3998:	je     3a58 <botlish_fn_40+0x2e0>
    399e:	mov    QWORD PTR [rsp+0x18],rax
    39a3:	mov    QWORD PTR [rsp+0x20],0x3
    39ac:	mov    ecx,0x1
    39b1:	test   rax,0x1
    39b7:	je     39c5 <botlish_fn_40+0x24d>
    39bd:	mov    rsi,rax
    39c0:	jmp    39e9 <botlish_fn_40+0x271>
    39c5:	xor    ecx,ecx
    39c7:	test   rax,0x7
    39cd:	je     39db <botlish_fn_40+0x263>
    39d3:	mov    rsi,rax
    39d6:	jmp    39e9 <botlish_fn_40+0x271>
    39db:	movzx  r10,BYTE PTR [rax]
    39df:	mov    rsi,rax
    39e2:	cmp    r10b,0x1
    39e6:	sete   cl
    39e9:	test   cl,cl
    39eb:	jne    3a09 <botlish_fn_40+0x291>
    39f1:	mov    rdi,r12
    39f4:	mov    rax,QWORD PTR [rdi+0x10]
    39f8:	mov    rcx,QWORD PTR [rax+0x30]
    39fc:	xor    rdx,rdx
    39ff:	call   3a04 <botlish_fn_40+0x28c>
			3a00: R_X86_64_PLT32	rt_type_error-0x4
    3a04:	jmp    3a58 <botlish_fn_40+0x2e0>
    3a09:	test   rsi,0x1
    3a10:	je     3a2f <botlish_fn_40+0x2b7>
    3a16:	mov    rcx,rsi
    3a19:	sub    rcx,0x3
    3a1d:	seto   al
    3a20:	add    rcx,0x1
    3a27:	test   al,al
    3a29:	je     3a3f <botlish_fn_40+0x2c7>
    3a2f:	mov    edx,0x3
    3a34:	mov    rdi,r12
    3a37:	call   3a3c <botlish_fn_40+0x2c4>
			3a38: R_X86_64_PLT32	rt_int_sub-0x4
    3a3c:	mov    rcx,rax
    3a3f:	mov    edx,0x3
    3a44:	mov    rsi,r14
    3a47:	mov    rdi,r12
    3a4a:	call   3a4f <botlish_fn_40+0x2d7>
			3a4b: R_X86_64_PLT32	rt_mutarray_set-0x4
    3a4f:	test   rax,rax
    3a52:	jne    3a7d <botlish_fn_40+0x305>
    3a58:	xor    rax,rax
    3a5b:	mov    rbx,QWORD PTR [rsp+0x40]
    3a60:	mov    r12,QWORD PTR [rsp+0x48]
    3a65:	mov    r13,QWORD PTR [rsp+0x50]
    3a6a:	mov    r14,QWORD PTR [rsp+0x58]
    3a6f:	mov    r15,QWORD PTR [rsp+0x60]
    3a74:	add    rsp,0x70
    3a78:	mov    rsp,rbp
    3a7b:	pop    rbp
    3a7c:	ret
    3a7d:	mov    rax,r13
    3a80:	mov    rbx,QWORD PTR [rsp+0x40]
    3a85:	mov    r12,QWORD PTR [rsp+0x48]
    3a8a:	mov    r13,QWORD PTR [rsp+0x50]
    3a8f:	mov    r14,QWORD PTR [rsp+0x58]
    3a94:	mov    r15,QWORD PTR [rsp+0x60]
    3a99:	add    rsp,0x70
    3a9d:	mov    rsp,rbp
    3aa0:	pop    rbp
    3aa1:	ret
    3aa2:	add    BYTE PTR [rax],al
    3aa4:	add    BYTE PTR [rax],al
    3aa6:	add    BYTE PTR [rax],al
    3aa8:	(bad)
    3aa9:	add    BYTE PTR [rax],al
    3aab:	add    BYTE PTR [rax],al
    3aad:	add    BYTE PTR [rax],al
	...

0000000000003ab0 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    3ab0:	push   rbp
    3ab1:	mov    rbp,rsp
    3ab4:	mov    rsi,QWORD PTR [rdx]
    3ab7:	mov    r9,QWORD PTR [rdx+0x8]
    3abb:	mov    rcx,QWORD PTR [rdx+0x10]
    3abf:	mov    r8,QWORD PTR [rdx+0x18]
    3ac3:	mov    rdx,r9
    3ac6:	call   3acb <botlish_entry_40+0x1b>
			3ac7: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3acb:	mov    rsp,rbp
    3ace:	pop    rbp
    3acf:	ret

0000000000003ad0 <botlish_fn_41: ht_set<HashTable, str, str>>:
    3ad0:	push   rbp
    3ad1:	mov    rbp,rsp
    3ad4:	sub    rsp,0x60
    3ad8:	mov    QWORD PTR [rsp+0x30],rbx
    3add:	mov    QWORD PTR [rsp+0x38],r12
    3ae2:	mov    QWORD PTR [rsp+0x40],r13
    3ae7:	mov    QWORD PTR [rsp+0x48],r14
    3aec:	mov    QWORD PTR [rsp+0x50],r15
    3af1:	mov    r12,rdi
    3af4:	mov    r13,rdx
    3af7:	mov    QWORD PTR [rsp],rsi
    3afb:	mov    r14,rsi
    3afe:	mov    QWORD PTR [rsp+0x8],rdx
    3b03:	mov    QWORD PTR [rsp+0x10],rcx
    3b08:	mov    rbx,rcx
    3b0b:	mov    rdx,r13
    3b0e:	mov    rsi,r14
    3b11:	mov    rdi,r12
    3b14:	call   3b19 <botlish_fn_41+0x49>
			3b15: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3b19:	test   rax,rax
    3b1c:	je     3cf4 <botlish_fn_41+0x224>
    3b22:	mov    QWORD PTR [rsp+0x18],rax
    3b27:	mov    rcx,rax
    3b2a:	mov    r8,0xffffffffffffffff
    3b31:	mov    r15,r8
    3b34:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3b3d:	mov    rdx,r13
    3b40:	mov    rsi,r14
    3b43:	mov    rdi,r12
    3b46:	call   3b4b <botlish_fn_41+0x7b>
			3b47: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3b4b:	test   rax,rax
    3b4e:	je     3cf4 <botlish_fn_41+0x224>
    3b54:	mov    QWORD PTR [rsp+0x18],rax
    3b59:	mov    rsi,r14
    3b5c:	mov    QWORD PTR [rsp+0x28],rax
    3b61:	mov    rax,QWORD PTR [rsi+0x18]
    3b65:	mov    rsi,QWORD PTR [rax]
    3b68:	mov    rdx,QWORD PTR [rsp+0x28]
    3b6d:	mov    rdi,r12
    3b70:	call   3b75 <botlish_fn_41+0xa5>
			3b71: R_X86_64_PLT32	rt_mutarray_get-0x4
    3b75:	test   rax,rax
    3b78:	je     3cf4 <botlish_fn_41+0x224>
    3b7e:	test   rax,0x1
    3b84:	mov    rsi,rax
    3b87:	jne    3baf <botlish_fn_41+0xdf>
    3b8d:	mov    edx,0x3
    3b92:	mov    rdi,r12
    3b95:	call   3b9a <botlish_fn_41+0xca>
			3b96: R_X86_64_PLT32	rt_int_cmp-0x4
    3b9a:	mov    ecx,0x2
    3b9f:	test   rax,rax
    3ba2:	cmove  rcx,QWORD PTR [rip+0x196]        # 3d40 <botlish_fn_41+0x270>
    3baa:	jmp    3bc0 <botlish_fn_41+0xf0>
    3baf:	mov    ecx,0x2
    3bb4:	cmp    rsi,0x3
    3bb8:	cmove  rcx,QWORD PTR [rip+0x180]        # 3d40 <botlish_fn_41+0x270>
    3bc0:	cmp    rcx,0x6
    3bc4:	je     3cd0 <botlish_fn_41+0x200>
    3bca:	mov    rsi,r14
    3bcd:	mov    rdi,r12
    3bd0:	call   3bd5 <botlish_fn_41+0x105>
			3bd1: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    3bd5:	test   rax,rax
    3bd8:	je     3cf4 <botlish_fn_41+0x224>
    3bde:	cmp    rax,0x6
    3be2:	je     3c29 <botlish_fn_41+0x159>
    3be8:	mov    rcx,r13
    3beb:	mov    rdx,QWORD PTR [rsp+0x28]
    3bf0:	mov    rsi,r14
    3bf3:	mov    rdi,r12
    3bf6:	mov    r8,rbx
    3bf9:	call   3bfe <botlish_fn_41+0x12e>
			3bfa: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3bfe:	test   rax,rax
    3c01:	je     3cf4 <botlish_fn_41+0x224>
    3c07:	mov    rbx,QWORD PTR [rsp+0x30]
    3c0c:	mov    r12,QWORD PTR [rsp+0x38]
    3c11:	mov    r13,QWORD PTR [rsp+0x40]
    3c16:	mov    r14,QWORD PTR [rsp+0x48]
    3c1b:	mov    r15,QWORD PTR [rsp+0x50]
    3c20:	add    rsp,0x60
    3c24:	mov    rsp,rbp
    3c27:	pop    rbp
    3c28:	ret
    3c29:	mov    rsi,r14
    3c2c:	mov    rdi,r12
    3c2f:	call   3c34 <botlish_fn_41+0x164>
			3c30: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3c34:	mov    rcx,rax
    3c37:	mov    r14,rax
    3c3a:	test   rax,rcx
    3c3d:	je     3cf4 <botlish_fn_41+0x224>
    3c43:	mov    rax,r14
    3c46:	mov    QWORD PTR [rsp],rax
    3c4a:	mov    rdx,r13
    3c4d:	mov    rsi,r14
    3c50:	mov    rdi,r12
    3c53:	call   3c58 <botlish_fn_41+0x188>
			3c54: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3c58:	test   rax,rax
    3c5b:	je     3cf4 <botlish_fn_41+0x224>
    3c61:	mov    QWORD PTR [rsp+0x18],rax
    3c66:	mov    rcx,rax
    3c69:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3c72:	mov    r8,r15
    3c75:	mov    rdx,r13
    3c78:	mov    rsi,r14
    3c7b:	mov    rdi,r12
    3c7e:	call   3c83 <botlish_fn_41+0x1b3>
			3c7f: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3c83:	test   rax,rax
    3c86:	je     3cf4 <botlish_fn_41+0x224>
    3c8c:	mov    QWORD PTR [rsp+0x18],rax
    3c91:	mov    rcx,r13
    3c94:	mov    rdx,rax
    3c97:	mov    rsi,r14
    3c9a:	mov    rdi,r12
    3c9d:	mov    r8,rbx
    3ca0:	call   3ca5 <botlish_fn_41+0x1d5>
			3ca1: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3ca5:	test   rax,rax
    3ca8:	je     3cf4 <botlish_fn_41+0x224>
    3cae:	mov    rbx,QWORD PTR [rsp+0x30]
    3cb3:	mov    r12,QWORD PTR [rsp+0x38]
    3cb8:	mov    r13,QWORD PTR [rsp+0x40]
    3cbd:	mov    r14,QWORD PTR [rsp+0x48]
    3cc2:	mov    r15,QWORD PTR [rsp+0x50]
    3cc7:	add    rsp,0x60
    3ccb:	mov    rsp,rbp
    3cce:	pop    rbp
    3ccf:	ret
    3cd0:	mov    rdx,QWORD PTR [rsp+0x28]
    3cd5:	mov    rsi,r14
    3cd8:	mov    rax,QWORD PTR [rsi+0x18]
    3cdc:	mov    rsi,QWORD PTR [rax+0x10]
    3ce0:	mov    rcx,rbx
    3ce3:	mov    rdi,r12
    3ce6:	call   3ceb <botlish_fn_41+0x21b>
			3ce7: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ceb:	test   rax,rax
    3cee:	jne    3d19 <botlish_fn_41+0x249>
    3cf4:	xor    rax,rax
    3cf7:	mov    rbx,QWORD PTR [rsp+0x30]
    3cfc:	mov    r12,QWORD PTR [rsp+0x38]
    3d01:	mov    r13,QWORD PTR [rsp+0x40]
    3d06:	mov    r14,QWORD PTR [rsp+0x48]
    3d0b:	mov    r15,QWORD PTR [rsp+0x50]
    3d10:	add    rsp,0x60
    3d14:	mov    rsp,rbp
    3d17:	pop    rbp
    3d18:	ret
    3d19:	mov    rax,r14
    3d1c:	mov    rbx,QWORD PTR [rsp+0x30]
    3d21:	mov    r12,QWORD PTR [rsp+0x38]
    3d26:	mov    r13,QWORD PTR [rsp+0x40]
    3d2b:	mov    r14,QWORD PTR [rsp+0x48]
    3d30:	mov    r15,QWORD PTR [rsp+0x50]
    3d35:	add    rsp,0x60
    3d39:	mov    rsp,rbp
    3d3c:	pop    rbp
    3d3d:	ret
    3d3e:	add    BYTE PTR [rax],al
    3d40:	(bad)
    3d41:	add    BYTE PTR [rax],al
    3d43:	add    BYTE PTR [rax],al
    3d45:	add    BYTE PTR [rax],al
	...

0000000000003d48 <botlish_entry_41: ht_set<HashTable, str, str>>:
    3d48:	push   rbp
    3d49:	mov    rbp,rsp
    3d4c:	mov    rsi,QWORD PTR [rdx]
    3d4f:	mov    r8,QWORD PTR [rdx+0x8]
    3d53:	mov    rcx,QWORD PTR [rdx+0x10]
    3d57:	mov    rdx,r8
    3d5a:	call   3d5f <botlish_entry_41+0x17>
			3d5b: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3d5f:	mov    rsp,rbp
    3d62:	pop    rbp
    3d63:	ret

0000000000003d64 <botlish_fn_42: row_new<bool, int>>:
    3d64:	push   rbp
    3d65:	mov    rbp,rsp
    3d68:	sub    rsp,0x10
    3d6c:	mov    QWORD PTR [rsp],rdx
    3d70:	mov    r8,rdx
    3d73:	cmp    rsi,0x6
    3d77:	je     3d94 <botlish_fn_42+0x30>
    3d7d:	call   3d82 <botlish_fn_42+0x1e>
			3d7e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    3d82:	test   rax,rax
    3d85:	je     3da5 <botlish_fn_42+0x41>
    3d8b:	add    rsp,0x10
    3d8f:	mov    rsp,rbp
    3d92:	pop    rbp
    3d93:	ret
    3d94:	mov    rsi,r8
    3d97:	call   3d9c <botlish_fn_42+0x38>
			3d98: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    3d9c:	test   rax,rax
    3d9f:	jne    3db1 <botlish_fn_42+0x4d>
    3da5:	xor    rax,rax
    3da8:	add    rsp,0x10
    3dac:	mov    rsp,rbp
    3daf:	pop    rbp
    3db0:	ret
    3db1:	add    rsp,0x10
    3db5:	mov    rsp,rbp
    3db8:	pop    rbp
    3db9:	ret

0000000000003dba <botlish_entry_42: row_new<bool, int>>:
    3dba:	push   rbp
    3dbb:	mov    rbp,rsp
    3dbe:	mov    rsi,QWORD PTR [rdx]
    3dc1:	mov    rdx,QWORD PTR [rdx+0x8]
    3dc5:	call   3dca <botlish_entry_42+0x10>
			3dc6: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3dca:	mov    rsp,rbp
    3dcd:	pop    rbp
    3dce:	ret

0000000000003dcf <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3dcf:	push   rbp
    3dd0:	mov    rbp,rsp
    3dd3:	sub    rsp,0x70
    3dd7:	mov    QWORD PTR [rsp+0x40],rbx
    3ddc:	mov    QWORD PTR [rsp+0x48],r12
    3de1:	mov    QWORD PTR [rsp+0x50],r13
    3de6:	mov    QWORD PTR [rsp+0x58],r14
    3deb:	mov    QWORD PTR [rsp+0x60],r15
    3df0:	mov    r15,rdi
    3df3:	mov    QWORD PTR [rsp],rsi
    3df7:	mov    QWORD PTR [rsp+0x8],rdx
    3dfc:	mov    QWORD PTR [rsp+0x10],rcx
    3e01:	mov    r14,rcx
    3e04:	sar    r8,1
    3e07:	mov    rbx,r8
    3e0a:	mov    r12,r9
    3e0d:	mov    QWORD PTR [rsp+0x28],rsi
    3e12:	cmp    rbx,r12
    3e15:	jge    3f24 <botlish_fn_43+0x155>
    3e1b:	mov    r13,rdx
    3e1e:	mov    rdx,QWORD PTR [r13+0x8]
    3e22:	mov    rcx,rbx
    3e25:	shl    rcx,1
    3e28:	or     rcx,0x1
    3e2c:	sar    rcx,1
    3e2f:	cmp    rcx,rdx
    3e32:	jb     3e5e <botlish_fn_43+0x8f>
    3e38:	mov    rdx,rbx
    3e3b:	shl    rdx,1
    3e3e:	or     rdx,0x1
    3e42:	mov    rsi,r13
    3e45:	mov    rdi,r15
    3e48:	call   3e4d <botlish_fn_43+0x7e>
			3e49: R_X86_64_PLT32	rt_list_get-0x4
    3e4d:	test   rax,rax
    3e50:	je     3edd <botlish_fn_43+0x10e>
    3e56:	mov    rdx,rax
    3e59:	jmp    3e66 <botlish_fn_43+0x97>
    3e5e:	mov    rax,QWORD PTR [r13+0x10]
    3e62:	mov    rdx,QWORD PTR [rax+rcx*8]
    3e66:	mov    QWORD PTR [rsp+0x18],rdx
    3e6b:	mov    QWORD PTR [rsp+0x30],rdx
    3e70:	mov    rax,QWORD PTR [r14+0x8]
    3e74:	mov    rcx,rbx
    3e77:	shl    rcx,1
    3e7a:	or     rcx,0x1
    3e7e:	sar    rcx,1
    3e81:	cmp    rcx,rax
    3e84:	jb     3eb5 <botlish_fn_43+0xe6>
    3e8a:	mov    rdx,rbx
    3e8d:	shl    rdx,1
    3e90:	or     rdx,0x1
    3e94:	mov    rsi,r14
    3e97:	mov    rdi,r15
    3e9a:	call   3e9f <botlish_fn_43+0xd0>
			3e9b: R_X86_64_PLT32	rt_list_get-0x4
    3e9f:	test   rax,rax
    3ea2:	je     3edd <botlish_fn_43+0x10e>
    3ea8:	mov    rcx,rax
    3eab:	mov    rsi,QWORD PTR [rsp+0x28]
    3eb0:	jmp    3ec2 <botlish_fn_43+0xf3>
    3eb5:	mov    rax,QWORD PTR [r14+0x10]
    3eb9:	mov    rcx,QWORD PTR [rax+rcx*8]
    3ebd:	mov    rsi,QWORD PTR [rsp+0x28]
    3ec2:	mov    QWORD PTR [rsp+0x20],rcx
    3ec7:	mov    rdx,QWORD PTR [rsp+0x30]
    3ecc:	mov    rdi,r15
    3ecf:	call   3ed4 <botlish_fn_43+0x105>
			3ed0: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3ed4:	test   rax,rax
    3ed7:	jne    3f02 <botlish_fn_43+0x133>
    3edd:	xor    rax,rax
    3ee0:	mov    rbx,QWORD PTR [rsp+0x40]
    3ee5:	mov    r12,QWORD PTR [rsp+0x48]
    3eea:	mov    r13,QWORD PTR [rsp+0x50]
    3eef:	mov    r14,QWORD PTR [rsp+0x58]
    3ef4:	mov    r15,QWORD PTR [rsp+0x60]
    3ef9:	add    rsp,0x70
    3efd:	mov    rsp,rbp
    3f00:	pop    rbp
    3f01:	ret
    3f02:	mov    QWORD PTR [rsp],rax
    3f06:	mov    QWORD PTR [rsp+0x8],r13
    3f0b:	mov    QWORD PTR [rsp+0x10],r14
    3f10:	add    rbx,0x1
    3f17:	mov    rdx,r13
    3f1a:	mov    QWORD PTR [rsp+0x28],rax
    3f1f:	jmp    3e12 <botlish_fn_43+0x43>
    3f24:	mov    rax,QWORD PTR [rsp+0x28]
    3f29:	mov    rbx,QWORD PTR [rsp+0x40]
    3f2e:	mov    r12,QWORD PTR [rsp+0x48]
    3f33:	mov    r13,QWORD PTR [rsp+0x50]
    3f38:	mov    r14,QWORD PTR [rsp+0x58]
    3f3d:	mov    r15,QWORD PTR [rsp+0x60]
    3f42:	add    rsp,0x70
    3f46:	mov    rsp,rbp
    3f49:	pop    rbp
    3f4a:	ret

0000000000003f4b <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3f4b:	push   rbp
    3f4c:	mov    rbp,rsp
    3f4f:	mov    rsi,QWORD PTR [rdx]
    3f52:	mov    r10,QWORD PTR [rdx+0x8]
    3f56:	mov    rcx,QWORD PTR [rdx+0x10]
    3f5a:	mov    r8,QWORD PTR [rdx+0x18]
    3f5e:	mov    r9,QWORD PTR [rdx+0x20]
    3f62:	sar    r9,1
    3f65:	mov    rdx,r10
    3f68:	call   3f6d <botlish_entry_43+0x22>
			3f69: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3f6d:	mov    rsp,rbp
    3f70:	pop    rbp
    3f71:	ret

0000000000003f72 <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    3f72:	push   rbp
    3f73:	mov    rbp,rsp
    3f76:	sub    rsp,0x50
    3f7a:	mov    QWORD PTR [rsp+0x20],rbx
    3f7f:	mov    QWORD PTR [rsp+0x28],r12
    3f84:	mov    QWORD PTR [rsp+0x30],r13
    3f89:	mov    QWORD PTR [rsp+0x38],r14
    3f8e:	mov    QWORD PTR [rsp+0x40],r15
    3f93:	mov    r12,rdi
    3f96:	mov    QWORD PTR [rsp],rsi
    3f9a:	mov    r15,rsi
    3f9d:	mov    QWORD PTR [rsp+0x8],rdx
    3fa2:	mov    QWORD PTR [rsp+0x10],rcx
    3fa7:	mov    r13,rcx
    3faa:	mov    QWORD PTR [rsp+0x18],r8
    3faf:	mov    rsi,r8
    3fb2:	mov    rdi,r12
    3fb5:	call   3fba <botlish_fn_44+0x48>
			3fb6: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3fba:	test   rax,rax
    3fbd:	je     4007 <botlish_fn_44+0x95>
    3fc3:	mov    QWORD PTR [rsp+0x8],rax
    3fc8:	mov    r14,rax
    3fcb:	mov    ebx,0x1
    3fd0:	mov    QWORD PTR [rsp+0x18],0x1
    3fd9:	mov    rsi,r13
    3fdc:	mov    rdi,r12
    3fdf:	call   3fe4 <botlish_fn_44+0x72>
			3fe0: R_X86_64_PLT32	rt_list_len-0x4
    3fe4:	mov    r9,rax
    3fe7:	sar    r9,1
    3fea:	mov    rcx,r13
    3fed:	mov    rdx,r15
    3ff0:	mov    rsi,r14
    3ff3:	mov    rdi,r12
    3ff6:	mov    r8,rbx
    3ff9:	call   3ffe <botlish_fn_44+0x8c>
			3ffa: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3ffe:	test   rax,rax
    4001:	jne    402c <botlish_fn_44+0xba>
    4007:	xor    rax,rax
    400a:	mov    rbx,QWORD PTR [rsp+0x20]
    400f:	mov    r12,QWORD PTR [rsp+0x28]
    4014:	mov    r13,QWORD PTR [rsp+0x30]
    4019:	mov    r14,QWORD PTR [rsp+0x38]
    401e:	mov    r15,QWORD PTR [rsp+0x40]
    4023:	add    rsp,0x50
    4027:	mov    rsp,rbp
    402a:	pop    rbp
    402b:	ret
    402c:	mov    rbx,QWORD PTR [rsp+0x20]
    4031:	mov    r12,QWORD PTR [rsp+0x28]
    4036:	mov    r13,QWORD PTR [rsp+0x30]
    403b:	mov    r14,QWORD PTR [rsp+0x38]
    4040:	mov    r15,QWORD PTR [rsp+0x40]
    4045:	add    rsp,0x50
    4049:	mov    rsp,rbp
    404c:	pop    rbp
    404d:	ret

000000000000404e <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    404e:	push   rbp
    404f:	mov    rbp,rsp
    4052:	mov    rsi,QWORD PTR [rdx]
    4055:	mov    r9,QWORD PTR [rdx+0x8]
    4059:	mov    rcx,QWORD PTR [rdx+0x10]
    405d:	mov    r8,QWORD PTR [rdx+0x18]
    4061:	mov    rdx,r9
    4064:	call   4069 <botlish_entry_44+0x1b>
			4065: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    4069:	mov    rsp,rbp
    406c:	pop    rbp
    406d:	ret

000000000000406e <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    406e:	push   rbp
    406f:	mov    rbp,rsp
    4072:	sub    rsp,0x90
    4079:	mov    QWORD PTR [rsp+0x60],rbx
    407e:	mov    QWORD PTR [rsp+0x68],r12
    4083:	mov    QWORD PTR [rsp+0x70],r13
    4088:	mov    QWORD PTR [rsp+0x78],r14
    408d:	mov    QWORD PTR [rsp+0x80],r15
    4095:	mov    r13,r8
    4098:	mov    QWORD PTR [rsp+0x38],rdi
    409d:	mov    rdi,QWORD PTR [rbp+0x10]
    40a1:	mov    r15,QWORD PTR [rbp+0x18]
    40a5:	mov    QWORD PTR [rsp+0x28],0x0
    40ae:	mov    QWORD PTR [rsp+0x30],0x0
    40b7:	mov    QWORD PTR [rsp],rsi
    40bb:	mov    QWORD PTR [rsp+0x8],rcx
    40c0:	mov    r14,rcx
    40c3:	mov    QWORD PTR [rsp+0x10],r9
    40c8:	mov    QWORD PTR [rsp+0x18],rdi
    40cd:	mov    QWORD PTR [rsp+0x20],r15
    40d2:	sar    rdx,1
    40d5:	mov    r12,rdx
    40d8:	mov    rbx,rsi
    40db:	mov    QWORD PTR [rsp+0x40],r9
    40e0:	mov    QWORD PTR [rsp+0x48],rdi
    40e5:	mov    rsi,rbx
    40e8:	mov    rdi,QWORD PTR [rsp+0x38]
    40ed:	call   40f2 <botlish_fn_45+0x84>
			40ee: R_X86_64_PLT32	rt_list_len-0x4
    40f2:	sar    rax,1
    40f5:	cmp    r12,rax
    40f8:	jge    4223 <botlish_fn_45+0x1b5>
    40fe:	mov    rax,r13
    4101:	or     rax,0x1
    4105:	mov    QWORD PTR [rsp+0x28],rax
    410a:	mov    rcx,QWORD PTR [rbx+0x8]
    410e:	mov    rax,r12
    4111:	shl    rax,1
    4114:	or     rax,0x1
    4118:	sar    rax,1
    411b:	cmp    rax,rcx
    411e:	jb     414c <botlish_fn_45+0xde>
    4124:	mov    rdx,r12
    4127:	shl    rdx,1
    412a:	or     rdx,0x1
    412e:	mov    rsi,rbx
    4131:	mov    rdi,QWORD PTR [rsp+0x38]
    4136:	call   413b <botlish_fn_45+0xcd>
			4137: R_X86_64_PLT32	rt_list_get-0x4
    413b:	test   rax,rax
    413e:	je     4240 <botlish_fn_45+0x1d2>
    4144:	mov    rcx,rax
    4147:	jmp    4154 <botlish_fn_45+0xe6>
    414c:	mov    rcx,QWORD PTR [rbx+0x10]
    4150:	mov    rcx,QWORD PTR [rcx+rax*8]
    4154:	mov    QWORD PTR [rsp+0x30],rcx
    4159:	mov    rdx,r13
    415c:	or     rdx,0x1
    4160:	mov    rsi,r14
    4163:	mov    rdi,QWORD PTR [rsp+0x38]
    4168:	mov    r8,r15
    416b:	call   4170 <botlish_fn_45+0x102>
			416c: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    4170:	test   rax,rax
    4173:	je     4240 <botlish_fn_45+0x1d2>
    4179:	mov    QWORD PTR [rsp+0x28],rax
    417e:	mov    rcx,rax
    4181:	mov    rsi,QWORD PTR [rsp+0x40]
    4186:	mov    rdx,QWORD PTR [rsp+0x48]
    418b:	mov    rdi,QWORD PTR [rsp+0x38]
    4190:	call   4195 <botlish_fn_45+0x127>
			4191: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    4195:	test   rax,rax
    4198:	je     4240 <botlish_fn_45+0x1d2>
    419e:	mov    QWORD PTR [rsp+0x10],rax
    41a3:	mov    QWORD PTR [rsp+0x50],rax
    41a8:	mov    QWORD PTR [rsp+0x28],0x3
    41b1:	mov    rsi,QWORD PTR [rsp+0x48]
    41b6:	test   rsi,0x1
    41bd:	je     41dc <botlish_fn_45+0x16e>
    41c3:	mov    rsi,QWORD PTR [rsp+0x48]
    41c8:	mov    rax,rsi
    41cb:	add    rax,0x2
    41cf:	seto   r10b
    41d3:	test   r10b,r10b
    41d6:	je     41f0 <botlish_fn_45+0x182>
    41dc:	mov    edx,0x3
    41e1:	mov    rsi,QWORD PTR [rsp+0x48]
    41e6:	mov    rdi,QWORD PTR [rsp+0x38]
    41eb:	call   41f0 <botlish_fn_45+0x182>
			41ec: R_X86_64_PLT32	rt_int_add-0x4
    41f0:	mov    QWORD PTR [rsp],rbx
    41f4:	mov    QWORD PTR [rsp+0x8],r14
    41f9:	mov    rcx,QWORD PTR [rsp+0x50]
    41fe:	mov    QWORD PTR [rsp+0x10],rcx
    4203:	mov    QWORD PTR [rsp+0x18],rax
    4208:	mov    QWORD PTR [rsp+0x20],r15
    420d:	add    r12,0x1
    4214:	mov    QWORD PTR [rsp+0x40],rcx
    4219:	mov    QWORD PTR [rsp+0x48],rax
    421e:	jmp    40e5 <botlish_fn_45+0x77>
    4223:	mov    rdx,QWORD PTR [rsp+0x48]
    4228:	mov    rsi,QWORD PTR [rsp+0x40]
    422d:	mov    rdi,QWORD PTR [rsp+0x38]
    4232:	call   4237 <botlish_fn_45+0x1c9>
			4233: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    4237:	test   rax,rax
    423a:	jne    426b <botlish_fn_45+0x1fd>
    4240:	xor    rax,rax
    4243:	mov    rbx,QWORD PTR [rsp+0x60]
    4248:	mov    r12,QWORD PTR [rsp+0x68]
    424d:	mov    r13,QWORD PTR [rsp+0x70]
    4252:	mov    r14,QWORD PTR [rsp+0x78]
    4257:	mov    r15,QWORD PTR [rsp+0x80]
    425f:	add    rsp,0x90
    4266:	mov    rsp,rbp
    4269:	pop    rbp
    426a:	ret
    426b:	mov    rbx,QWORD PTR [rsp+0x60]
    4270:	mov    r12,QWORD PTR [rsp+0x68]
    4275:	mov    r13,QWORD PTR [rsp+0x70]
    427a:	mov    r14,QWORD PTR [rsp+0x78]
    427f:	mov    r15,QWORD PTR [rsp+0x80]
    4287:	add    rsp,0x90
    428e:	mov    rsp,rbp
    4291:	pop    rbp
    4292:	ret

0000000000004293 <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4293:	push   rbp
    4294:	mov    rbp,rsp
    4297:	sub    rsp,0x10
    429b:	mov    rsi,QWORD PTR [rdx]
    429e:	mov    r10,QWORD PTR [rdx+0x8]
    42a2:	mov    rcx,QWORD PTR [rdx+0x10]
    42a6:	mov    r8,QWORD PTR [rdx+0x18]
    42aa:	mov    r9,QWORD PTR [rdx+0x20]
    42ae:	mov    r11,QWORD PTR [rdx+0x28]
    42b2:	mov    rax,QWORD PTR [rdx+0x30]
    42b6:	mov    QWORD PTR [rsp],r11
    42ba:	mov    QWORD PTR [rsp+0x8],rax
    42bf:	mov    rdx,r10
    42c2:	call   42c7 <botlish_entry_45+0x34>
			42c3: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    42c7:	add    rsp,0x10
    42cb:	mov    rsp,rbp
    42ce:	pop    rbp
    42cf:	ret

00000000000042d0 <botlish_fn_46: csv_records_generic<str, bool>>:
    42d0:	push   rbp
    42d1:	mov    rbp,rsp
    42d4:	sub    rsp,0x80
    42db:	mov    QWORD PTR [rsp+0x50],rbx
    42e0:	mov    QWORD PTR [rsp+0x58],r12
    42e5:	mov    QWORD PTR [rsp+0x60],r13
    42ea:	mov    QWORD PTR [rsp+0x68],r14
    42ef:	mov    QWORD PTR [rsp+0x70],r15
    42f4:	mov    r12,rdi
    42f7:	mov    QWORD PTR [rsp+0x20],0x0
    4300:	mov    QWORD PTR [rsp+0x28],0x0
    4309:	mov    QWORD PTR [rsp+0x30],0x0
    4312:	mov    QWORD PTR [rsp+0x38],0x0
    431b:	mov    QWORD PTR [rsp+0x40],0x0
    4324:	mov    QWORD PTR [rsp+0x10],rsi
    4329:	mov    QWORD PTR [rsp+0x18],rdx
    432e:	mov    r13,rdx
    4331:	mov    rdi,r12
    4334:	call   4339 <botlish_fn_46+0x69>
			4335: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    4339:	mov    rcx,rax
    433c:	mov    r14,rax
    433f:	test   rax,rcx
    4342:	je     445c <botlish_fn_46+0x18c>
    4348:	mov    rax,r14
    434b:	mov    QWORD PTR [rsp+0x10],rax
    4350:	mov    rsi,r14
    4353:	mov    rdi,r12
    4356:	call   435b <botlish_fn_46+0x8b>
			4357: R_X86_64_PLT32	rt_list_len-0x4
    435b:	sar    rax,1
    435e:	cmp    rax,0x1
    4362:	jle    4445 <botlish_fn_46+0x175>
    4368:	mov    rax,r14
    436b:	mov    rax,QWORD PTR [rax+0x10]
    436f:	mov    rbx,QWORD PTR [rax]
    4372:	mov    QWORD PTR [rsp+0x20],rbx
    4377:	mov    rsi,rbx
    437a:	mov    rdi,r12
    437d:	call   4382 <botlish_fn_46+0xb2>
			437e: R_X86_64_PLT32	rt_list_len-0x4
    4382:	mov    r15,rbx
    4385:	mov    QWORD PTR [rsp+0x28],rax
    438a:	mov    QWORD PTR [rsp+0x48],rax
    438f:	mov    rax,r14
    4392:	mov    rcx,QWORD PTR [rax+0x10]
    4396:	mov    rcx,QWORD PTR [rcx+0x8]
    439a:	mov    QWORD PTR [rsp+0x30],rcx
    439f:	mov    rbx,r13
    43a2:	mov    rdx,QWORD PTR [rsp+0x48]
    43a7:	mov    rsi,r15
    43aa:	mov    rdi,r12
    43ad:	mov    r8,rbx
    43b0:	call   43b5 <botlish_fn_46+0xe5>
			43b1: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    43b5:	test   rax,rax
    43b8:	je     445c <botlish_fn_46+0x18c>
    43be:	mov    QWORD PTR [rsp+0x30],rax
    43c3:	mov    rsi,rax
    43c6:	mov    QWORD PTR [rsp+0x38],0x5
    43cf:	mov    rdi,r12
    43d2:	call   43d7 <botlish_fn_46+0x107>
			43d3: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    43d7:	test   rax,rax
    43da:	je     445c <botlish_fn_46+0x18c>
    43e0:	mov    QWORD PTR [rsp+0x30],rax
    43e5:	mov    r9,rax
    43e8:	mov    eax,0x3
    43ed:	mov    QWORD PTR [rsp+0x40],0x3
    43f6:	mov    edx,0x5
    43fb:	mov    QWORD PTR [rsp],rax
    43ff:	mov    QWORD PTR [rsp+0x8],rbx
    4404:	mov    rcx,r15
    4407:	mov    rsi,r14
    440a:	mov    rdi,r12
    440d:	mov    r8,QWORD PTR [rsp+0x48]
    4412:	call   4417 <botlish_fn_46+0x147>
			4413: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4417:	test   rax,rax
    441a:	je     445c <botlish_fn_46+0x18c>
    4420:	mov    rbx,QWORD PTR [rsp+0x50]
    4425:	mov    r12,QWORD PTR [rsp+0x58]
    442a:	mov    r13,QWORD PTR [rsp+0x60]
    442f:	mov    r14,QWORD PTR [rsp+0x68]
    4434:	mov    r15,QWORD PTR [rsp+0x70]
    4439:	add    rsp,0x80
    4440:	mov    rsp,rbp
    4443:	pop    rbp
    4444:	ret
    4445:	xor    rdx,rdx
    4448:	mov    rdi,r12
    444b:	mov    rsi,rdx
    444e:	call   4453 <botlish_fn_46+0x183>
			444f: R_X86_64_PLT32	rt_list_new-0x4
    4453:	test   rax,rax
    4456:	jne    4484 <botlish_fn_46+0x1b4>
    445c:	xor    rax,rax
    445f:	mov    rbx,QWORD PTR [rsp+0x50]
    4464:	mov    r12,QWORD PTR [rsp+0x58]
    4469:	mov    r13,QWORD PTR [rsp+0x60]
    446e:	mov    r14,QWORD PTR [rsp+0x68]
    4473:	mov    r15,QWORD PTR [rsp+0x70]
    4478:	add    rsp,0x80
    447f:	mov    rsp,rbp
    4482:	pop    rbp
    4483:	ret
    4484:	mov    rbx,QWORD PTR [rsp+0x50]
    4489:	mov    r12,QWORD PTR [rsp+0x58]
    448e:	mov    r13,QWORD PTR [rsp+0x60]
    4493:	mov    r14,QWORD PTR [rsp+0x68]
    4498:	mov    r15,QWORD PTR [rsp+0x70]
    449d:	add    rsp,0x80
    44a4:	mov    rsp,rbp
    44a7:	pop    rbp
    44a8:	ret

00000000000044a9 <botlish_entry_46: csv_records_generic<str, bool>>:
    44a9:	push   rbp
    44aa:	mov    rbp,rsp
    44ad:	mov    rsi,QWORD PTR [rdx]
    44b0:	mov    rdx,QWORD PTR [rdx+0x8]
    44b4:	call   44b9 <botlish_entry_46+0x10>
			44b5: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    44b9:	mov    rsp,rbp
    44bc:	pop    rbp
    44bd:	ret

00000000000044be <botlish_fn_47: csv_records<str>>:
    44be:	push   rbp
    44bf:	mov    rbp,rsp
    44c2:	sub    rsp,0x10
    44c6:	mov    QWORD PTR [rsp],rsi
    44ca:	mov    edx,0x2
    44cf:	mov    QWORD PTR [rsp+0x8],0x2
    44d8:	call   44dd <botlish_fn_47+0x1f>
			44d9: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    44dd:	test   rax,rax
    44e0:	jne    44f2 <botlish_fn_47+0x34>
    44e6:	xor    rax,rax
    44e9:	add    rsp,0x10
    44ed:	mov    rsp,rbp
    44f0:	pop    rbp
    44f1:	ret
    44f2:	add    rsp,0x10
    44f6:	mov    rsp,rbp
    44f9:	pop    rbp
    44fa:	ret

00000000000044fb <botlish_entry_47: csv_records<str>>:
    44fb:	push   rbp
    44fc:	mov    rbp,rsp
    44ff:	mov    rsi,QWORD PTR [rdx]
    4502:	call   4507 <botlish_entry_47+0xc>
			4503: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4507:	mov    rsp,rbp
    450a:	pop    rbp
    450b:	ret

000000000000450c <botlish_fn_48: csv_records_presized<str>>:
    450c:	push   rbp
    450d:	mov    rbp,rsp
    4510:	sub    rsp,0x10
    4514:	mov    QWORD PTR [rsp],rsi
    4518:	mov    edx,0x6
    451d:	mov    QWORD PTR [rsp+0x8],0x6
    4526:	call   452b <botlish_fn_48+0x1f>
			4527: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    452b:	test   rax,rax
    452e:	jne    4540 <botlish_fn_48+0x34>
    4534:	xor    rax,rax
    4537:	add    rsp,0x10
    453b:	mov    rsp,rbp
    453e:	pop    rbp
    453f:	ret
    4540:	add    rsp,0x10
    4544:	mov    rsp,rbp
    4547:	pop    rbp
    4548:	ret

0000000000004549 <botlish_entry_48: csv_records_presized<str>>:
    4549:	push   rbp
    454a:	mov    rbp,rsp
    454d:	mov    rsi,QWORD PTR [rdx]
    4550:	call   4555 <botlish_entry_48+0xc>
			4551: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4555:	mov    rsp,rbp
    4558:	pop    rbp
    4559:	ret
    455a:	add    BYTE PTR [rax],al
    455c:	add    BYTE PTR [rax],al
	...

0000000000004560 <botlish_fn_49: sample_checks<generic>>:
    4560:	push   rbp
    4561:	mov    rbp,rsp
    4564:	sub    rsp,0xc0
    456b:	mov    QWORD PTR [rsp+0x90],rbx
    4573:	mov    QWORD PTR [rsp+0x98],r12
    457b:	mov    QWORD PTR [rsp+0xa0],r13
    4583:	mov    QWORD PTR [rsp+0xa8],r14
    458b:	mov    QWORD PTR [rsp+0xb0],r15
    4593:	mov    QWORD PTR [rsp+0x8],0x0
    459c:	mov    QWORD PTR [rsp+0x10],0x0
    45a5:	mov    QWORD PTR [rsp+0x18],0x0
    45ae:	mov    QWORD PTR [rsp+0x20],0x0
    45b7:	mov    QWORD PTR [rsp+0x28],0x0
    45c0:	mov    QWORD PTR [rsp+0x30],0x0
    45c9:	mov    QWORD PTR [rsp+0x38],0x0
    45d2:	mov    rax,QWORD PTR [rdi+0x10]
    45d6:	mov    r13,rdi
    45d9:	mov    rsi,QWORD PTR [rax+0x38]
    45dd:	mov    QWORD PTR [rsp],rsi
    45e1:	call   45e6 <botlish_fn_49+0x86>
			45e2: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    45e6:	mov    rsi,rax
    45e9:	mov    r12,rax
    45ec:	test   rax,rsi
    45ef:	je     4974 <botlish_fn_49+0x414>
    45f5:	mov    rax,r12
    45f8:	mov    QWORD PTR [rsp],rax
    45fc:	mov    rdi,r13
    45ff:	mov    rax,QWORD PTR [rdi+0x10]
    4603:	mov    rsi,QWORD PTR [rax+0x38]
    4607:	mov    QWORD PTR [rsp+0x8],rsi
    460c:	call   4611 <botlish_fn_49+0xb1>
			460d: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4611:	mov    rbx,rax
    4614:	test   rbx,rbx
    4617:	je     4974 <botlish_fn_49+0x414>
    461d:	mov    rax,r12
    4620:	mov    rax,QWORD PTR [rax+0x8]
    4624:	test   rax,rax
    4627:	jne    464e <botlish_fn_49+0xee>
    462d:	mov    edx,0x1
    4632:	mov    rsi,r12
    4635:	mov    rdi,r13
    4638:	call   463d <botlish_fn_49+0xdd>
			4639: R_X86_64_PLT32	rt_list_get-0x4
    463d:	test   rax,rax
    4640:	je     4974 <botlish_fn_49+0x414>
    4646:	mov    rsi,rax
    4649:	jmp    4656 <botlish_fn_49+0xf6>
    464e:	mov    rax,QWORD PTR [r12+0x10]
    4653:	mov    rsi,QWORD PTR [rax]
    4656:	mov    QWORD PTR [rsp+0x8],rsi
    465b:	mov    r15,rsi
    465e:	mov    rax,QWORD PTR [r12+0x8]
    4663:	cmp    rax,0x1
    4667:	ja     468e <botlish_fn_49+0x12e>
    466d:	mov    edx,0x3
    4672:	mov    rsi,r12
    4675:	mov    rdi,r13
    4678:	call   467d <botlish_fn_49+0x11d>
			4679: R_X86_64_PLT32	rt_list_get-0x4
    467d:	test   rax,rax
    4680:	je     4974 <botlish_fn_49+0x414>
    4686:	mov    rsi,rax
    4689:	jmp    4697 <botlish_fn_49+0x137>
    468e:	mov    rax,QWORD PTR [r12+0x10]
    4693:	mov    rsi,QWORD PTR [rax+0x8]
    4697:	mov    QWORD PTR [rsp+0x10],rsi
    469c:	mov    r14,rsi
    469f:	mov    rax,QWORD PTR [rbx+0x8]
    46a3:	mov    rsi,rbx
    46a6:	test   rax,rax
    46a9:	jne    46cd <botlish_fn_49+0x16d>
    46af:	mov    edx,0x1
    46b4:	mov    rdi,r13
    46b7:	call   46bc <botlish_fn_49+0x15c>
			46b8: R_X86_64_PLT32	rt_list_get-0x4
    46bc:	test   rax,rax
    46bf:	je     4974 <botlish_fn_49+0x414>
    46c5:	mov    rsi,rax
    46c8:	jmp    46d4 <botlish_fn_49+0x174>
    46cd:	mov    rax,QWORD PTR [rsi+0x10]
    46d1:	mov    rsi,QWORD PTR [rax]
    46d4:	mov    QWORD PTR [rsp+0x18],rsi
    46d9:	mov    rdi,r13
    46dc:	mov    QWORD PTR [rsp+0x78],rsi
    46e1:	mov    rax,QWORD PTR [rdi+0x10]
    46e5:	mov    rdx,QWORD PTR [rax+0x40]
    46e9:	mov    QWORD PTR [rsp+0x20],rdx
    46ee:	mov    rsi,r15
    46f1:	call   46f6 <botlish_fn_49+0x196>
			46f2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46f6:	test   rax,rax
    46f9:	je     4974 <botlish_fn_49+0x414>
    46ff:	mov    QWORD PTR [rsp+0x20],rax
    4704:	mov    rbx,rax
    4707:	mov    rdi,r13
    470a:	mov    rax,QWORD PTR [rdi+0x10]
    470e:	mov    rdx,QWORD PTR [rax+0x40]
    4712:	mov    QWORD PTR [rsp+0x28],rdx
    4717:	mov    rsi,QWORD PTR [rsp+0x78]
    471c:	call   4721 <botlish_fn_49+0x1c1>
			471d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4721:	test   rax,rax
    4724:	je     4974 <botlish_fn_49+0x414>
    472a:	mov    rcx,rbx
    472d:	mov    rdx,rcx
    4730:	and    rdx,rax
    4733:	test   rdx,0x1
    473a:	jne    475c <botlish_fn_49+0x1fc>
    4740:	mov    rdx,rax
    4743:	mov    rsi,rbx
    4746:	mov    rdi,r13
    4749:	call   474e <botlish_fn_49+0x1ee>
			474a: R_X86_64_PLT32	rt_value_eq-0x4
    474e:	test   rax,rax
    4751:	je     4974 <botlish_fn_49+0x414>
    4757:	jmp    4772 <botlish_fn_49+0x212>
    475c:	mov    rdx,rax
    475f:	mov    rsi,rbx
    4762:	mov    eax,0x2
    4767:	cmp    rsi,rdx
    476a:	cmove  rax,QWORD PTR [rip+0x26e]        # 49e0 <botlish_fn_49+0x480>
    4772:	mov    ebx,0x6
    4777:	cmp    rax,0x6
    477b:	je     4796 <botlish_fn_49+0x236>
    4781:	mov    ebx,0x2
    4786:	mov    QWORD PTR [rsp],0x2
    478e:	mov    rsi,r12
    4791:	jmp    4835 <botlish_fn_49+0x2d5>
    4796:	mov    rsi,r15
    4799:	mov    rdi,r13
    479c:	call   47a1 <botlish_fn_49+0x241>
			479d: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    47a1:	test   rax,rax
    47a4:	mov    QWORD PTR [rsp+0x88],rax
    47ac:	je     4974 <botlish_fn_49+0x414>
    47b2:	mov    rsi,QWORD PTR [rsp+0x78]
    47b7:	mov    rdi,r13
    47ba:	call   47bf <botlish_fn_49+0x25f>
			47bb: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    47bf:	test   rax,rax
    47c2:	je     4974 <botlish_fn_49+0x414>
    47c8:	mov    rcx,QWORD PTR [rsp+0x88]
    47d0:	mov    rdx,rcx
    47d3:	and    rdx,rax
    47d6:	test   rdx,0x1
    47dd:	jne    4804 <botlish_fn_49+0x2a4>
    47e3:	mov    rdx,rax
    47e6:	mov    rsi,QWORD PTR [rsp+0x88]
    47ee:	mov    rdi,r13
    47f1:	call   47f6 <botlish_fn_49+0x296>
			47f2: R_X86_64_PLT32	rt_value_eq-0x4
    47f6:	test   rax,rax
    47f9:	je     4974 <botlish_fn_49+0x414>
    47ff:	jmp    481f <botlish_fn_49+0x2bf>
    4804:	mov    rdx,rax
    4807:	mov    rsi,QWORD PTR [rsp+0x88]
    480f:	mov    eax,0x2
    4814:	cmp    rsi,rdx
    4817:	cmove  rax,QWORD PTR [rip+0x1c1]        # 49e0 <botlish_fn_49+0x480>
    481f:	cmp    rax,0x6
    4823:	je     482e <botlish_fn_49+0x2ce>
    4829:	mov    ebx,0x2
    482e:	mov    QWORD PTR [rsp],rbx
    4832:	mov    rsi,r12
    4835:	mov    rdi,r13
    4838:	call   483d <botlish_fn_49+0x2dd>
			4839: R_X86_64_PLT32	rt_list_len-0x4
    483d:	mov    QWORD PTR [rsp+0x18],rax
    4842:	mov    rdi,r13
    4845:	mov    r12,rax
    4848:	mov    rax,QWORD PTR [rdi+0x10]
    484c:	mov    rdx,QWORD PTR [rax+0x40]
    4850:	mov    QWORD PTR [rsp+0x20],rdx
    4855:	mov    rsi,r15
    4858:	call   485d <botlish_fn_49+0x2fd>
			4859: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    485d:	test   rax,rax
    4860:	je     4974 <botlish_fn_49+0x414>
    4866:	mov    QWORD PTR [rsp+0x20],rax
    486b:	mov    rdi,r13
    486e:	mov    QWORD PTR [rsp+0x88],rax
    4876:	mov    rax,QWORD PTR [rdi+0x10]
    487a:	mov    rdx,QWORD PTR [rax+0x48]
    487e:	mov    QWORD PTR [rsp+0x28],rdx
    4883:	mov    rsi,r15
    4886:	call   488b <botlish_fn_49+0x32b>
			4887: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    488b:	test   rax,rax
    488e:	je     4974 <botlish_fn_49+0x414>
    4894:	mov    QWORD PTR [rsp+0x28],rax
    4899:	mov    rdi,r13
    489c:	mov    QWORD PTR [rsp+0x80],rax
    48a4:	mov    rax,QWORD PTR [rdi+0x10]
    48a8:	mov    rdx,QWORD PTR [rax+0x50]
    48ac:	mov    QWORD PTR [rsp+0x30],rdx
    48b1:	mov    rsi,r15
    48b4:	call   48b9 <botlish_fn_49+0x359>
			48b5: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    48b9:	test   rax,rax
    48bc:	je     4974 <botlish_fn_49+0x414>
    48c2:	mov    QWORD PTR [rsp+0x8],rax
    48c7:	mov    rdi,r13
    48ca:	mov    r15,rax
    48cd:	mov    rax,QWORD PTR [rdi+0x10]
    48d1:	mov    rdx,QWORD PTR [rax+0x40]
    48d5:	mov    QWORD PTR [rsp+0x30],rdx
    48da:	mov    rsi,r14
    48dd:	call   48e2 <botlish_fn_49+0x382>
			48de: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    48e2:	test   rax,rax
    48e5:	je     4974 <botlish_fn_49+0x414>
    48eb:	mov    QWORD PTR [rsp+0x30],rax
    48f0:	mov    rdi,r13
    48f3:	mov    QWORD PTR [rsp+0x78],rax
    48f8:	mov    rax,QWORD PTR [rdi+0x10]
    48fc:	mov    rdx,QWORD PTR [rax+0x50]
    4900:	mov    QWORD PTR [rsp+0x38],rdx
    4905:	mov    rsi,r14
    4908:	call   490d <botlish_fn_49+0x3ad>
			4909: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    490d:	test   rax,rax
    4910:	je     4974 <botlish_fn_49+0x414>
    4916:	mov    QWORD PTR [rsp+0x10],rax
    491b:	lea    rdx,[rsp+0x40]
    4920:	mov    r9,r12
    4923:	mov    QWORD PTR [rsp+0x40],r9
    4928:	mov    rcx,QWORD PTR [rsp+0x88]
    4930:	mov    QWORD PTR [rsp+0x48],rcx
    4935:	mov    rcx,QWORD PTR [rsp+0x80]
    493d:	mov    QWORD PTR [rsp+0x50],rcx
    4942:	mov    rcx,r15
    4945:	mov    QWORD PTR [rsp+0x58],rcx
    494a:	mov    rcx,QWORD PTR [rsp+0x78]
    494f:	mov    QWORD PTR [rsp+0x60],rcx
    4954:	mov    QWORD PTR [rsp+0x68],rax
    4959:	mov    QWORD PTR [rsp+0x70],rbx
    495e:	mov    esi,0x7
    4963:	mov    rdi,r13
    4966:	call   496b <botlish_fn_49+0x40b>
			4967: R_X86_64_PLT32	rt_list_new-0x4
    496b:	test   rax,rax
    496e:	jne    49ab <botlish_fn_49+0x44b>
    4974:	xor    rax,rax
    4977:	mov    rbx,QWORD PTR [rsp+0x90]
    497f:	mov    r12,QWORD PTR [rsp+0x98]
    4987:	mov    r13,QWORD PTR [rsp+0xa0]
    498f:	mov    r14,QWORD PTR [rsp+0xa8]
    4997:	mov    r15,QWORD PTR [rsp+0xb0]
    499f:	add    rsp,0xc0
    49a6:	mov    rsp,rbp
    49a9:	pop    rbp
    49aa:	ret
    49ab:	mov    rbx,QWORD PTR [rsp+0x90]
    49b3:	mov    r12,QWORD PTR [rsp+0x98]
    49bb:	mov    r13,QWORD PTR [rsp+0xa0]
    49c3:	mov    r14,QWORD PTR [rsp+0xa8]
    49cb:	mov    r15,QWORD PTR [rsp+0xb0]
    49d3:	add    rsp,0xc0
    49da:	mov    rsp,rbp
    49dd:	pop    rbp
    49de:	ret
    49df:	add    BYTE PTR [rsi],al
    49e1:	add    BYTE PTR [rax],al
    49e3:	add    BYTE PTR [rax],al
    49e5:	add    BYTE PTR [rax],al
	...

00000000000049e8 <botlish_entry_49: sample_checks<generic>>:
    49e8:	push   rbp
    49e9:	mov    rbp,rsp
    49ec:	call   49f1 <botlish_entry_49+0x9>
			49ed: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    49f1:	mov    rsp,rbp
    49f4:	pop    rbp
    49f5:	ret

00000000000049f6 <botlish_fn_50: sample<generic>>:
    49f6:	push   rbp
    49f7:	mov    rbp,rsp
    49fa:	sub    rsp,0x10
    49fe:	mov    QWORD PTR [rsp],rbx
    4a02:	mov    rbx,rdi
    4a05:	mov    rdi,rbx
    4a08:	call   4a0d <botlish_fn_50+0x17>
			4a09: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    4a0d:	test   rax,rax
    4a10:	jne    4ac9 <botlish_fn_50+0xd3>
    4a16:	mov    rdi,rbx
    4a19:	call   4a1e <botlish_fn_50+0x28>
			4a1a: R_X86_64_PLT32	rt_declared_error-0x4
    4a1e:	cmp    rax,0x40000001
    4a24:	je     4a9a <botlish_fn_50+0xa4>
    4a2a:	mov    rdi,rbx
    4a2d:	call   4a32 <botlish_fn_50+0x3c>
			4a2e: R_X86_64_PLT32	rt_declared_error-0x4
    4a32:	cmp    rax,0x40000002
    4a38:	je     4a76 <botlish_fn_50+0x80>
    4a3e:	mov    rdi,rbx
    4a41:	call   4a46 <botlish_fn_50+0x50>
			4a42: R_X86_64_PLT32	rt_declared_error-0x4
    4a46:	cmp    rax,0x40000003
    4a4c:	jne    4ab9 <botlish_fn_50+0xc3>
    4a52:	mov    rdi,rbx
    4a55:	call   4a5a <botlish_fn_50+0x64>
			4a56: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4a5a:	xor    rdx,rdx
    4a5d:	mov    rdi,rbx
    4a60:	mov    rsi,rdx
    4a63:	call   4a68 <botlish_fn_50+0x72>
			4a64: R_X86_64_PLT32	rt_list_new-0x4
    4a68:	test   rax,rax
    4a6b:	je     4ab9 <botlish_fn_50+0xc3>
    4a71:	jmp    4ac9 <botlish_fn_50+0xd3>
    4a76:	mov    rdi,rbx
    4a79:	call   4a7e <botlish_fn_50+0x88>
			4a7a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4a7e:	xor    rdx,rdx
    4a81:	mov    rdi,rbx
    4a84:	mov    rsi,rdx
    4a87:	call   4a8c <botlish_fn_50+0x96>
			4a88: R_X86_64_PLT32	rt_list_new-0x4
    4a8c:	test   rax,rax
    4a8f:	je     4ab9 <botlish_fn_50+0xc3>
    4a95:	jmp    4ac9 <botlish_fn_50+0xd3>
    4a9a:	mov    rdi,rbx
    4a9d:	call   4aa2 <botlish_fn_50+0xac>
			4a9e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4aa2:	xor    rdx,rdx
    4aa5:	mov    rdi,rbx
    4aa8:	mov    rsi,rdx
    4aab:	call   4ab0 <botlish_fn_50+0xba>
			4aac: R_X86_64_PLT32	rt_list_new-0x4
    4ab0:	test   rax,rax
    4ab3:	jne    4ac9 <botlish_fn_50+0xd3>
    4ab9:	xor    rax,rax
    4abc:	mov    rbx,QWORD PTR [rsp]
    4ac0:	add    rsp,0x10
    4ac4:	mov    rsp,rbp
    4ac7:	pop    rbp
    4ac8:	ret
    4ac9:	mov    rbx,QWORD PTR [rsp]
    4acd:	add    rsp,0x10
    4ad1:	mov    rsp,rbp
    4ad4:	pop    rbp
    4ad5:	ret

0000000000004ad6 <botlish_entry_50: sample<generic>>:
    4ad6:	push   rbp
    4ad7:	mov    rbp,rsp
    4ada:	call   4adf <botlish_entry_50+0x9>
			4adb: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    4adf:	mov    rsp,rbp
    4ae2:	pop    rbp
    4ae3:	ret

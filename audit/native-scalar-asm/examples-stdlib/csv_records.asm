; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 21919  (per function: 45 78 357 381 272 272 272 81 365 430 584 770 351 695 456 171 28 28 28 28 396 524 99 493 143 61 125 61 125 61 125 61 125 61 168 168 179 179 245 245 820 1264 429 412 444 1129 766 817 665 1176 860 107 756 335 645 580 78 78 1222)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> geo_new_capacity<int, int>
;   botlish_fn_3 / botlish_entry_3 -> geo_grow<mutarray, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_append<list[mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> geo_append<list[mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> geo_append<list[mutarray, int], mutarray>
;   botlish_fn_7 / botlish_entry_7 -> geo_finish<list[mutarray, int]>
;   botlish_fn_8 / botlish_entry_8 -> peek<str, int>
;   botlish_fn_9 / botlish_entry_9 -> peek<str, int>
;   botlish_fn_10 / botlish_entry_10 -> scan_unquoted<str, int, int>
;   botlish_fn_11 / botlish_entry_11 -> scan_quoted<str, int, str>
;   botlish_fn_12 / botlish_entry_12 -> scan_field<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_record<str, int, list[mutarray, int]>
;   botlish_fn_14 / botlish_entry_14 -> scan_records<str, int, list[mutarray, int]>
;   botlish_fn_15 / botlish_entry_15 -> csv_parse<str>
;   botlish_fn_16 / botlish_entry_16 -> ht_min_capacity<generic>
;   botlish_fn_17 / botlish_entry_17 -> ht_empty_state<generic>
;   botlish_fn_18 / botlish_entry_18 -> ht_occupied_state<generic>
;   botlish_fn_19 / botlish_entry_19 -> ht_tombstone_state<generic>
;   botlish_fn_20 / botlish_entry_20 -> ht_fill_empty<mutarray, int, int>
;   botlish_fn_21 / botlish_entry_21 -> ht_alloc<int>
;   botlish_fn_22 / botlish_entry_22 -> ht_new<generic>
;   botlish_fn_23 / botlish_entry_23 -> ht_capacity_for<int, int>
;   botlish_fn_24 / botlish_entry_24 -> ht_new_sized<int>
;   botlish_fn_25 / botlish_entry_25 -> ht_controls<mutarray>
;   botlish_fn_26 / botlish_entry_26 -> ht_controls<generic>
;   botlish_fn_27 / botlish_entry_27 -> ht_keys<mutarray>
;   botlish_fn_28 / botlish_entry_28 -> ht_keys<generic>
;   botlish_fn_29 / botlish_entry_29 -> ht_values<mutarray>
;   botlish_fn_30 / botlish_entry_30 -> ht_values<generic>
;   botlish_fn_31 / botlish_entry_31 -> ht_size<mutarray>
;   botlish_fn_32 / botlish_entry_32 -> ht_size<generic>
;   botlish_fn_33 / botlish_entry_33 -> ht_tombstones<mutarray>
;   botlish_fn_34 / botlish_entry_34 -> ht_capacity<mutarray>
;   botlish_fn_35 / botlish_entry_35 -> ht_capacity<generic>
;   botlish_fn_36 / botlish_entry_36 -> ht_probe_start<mutarray, any>
;   botlish_fn_37 / botlish_entry_37 -> ht_probe_start<any, str>
;   botlish_fn_38 / botlish_entry_38 -> ht_probe_next<mutarray, int>
;   botlish_fn_39 / botlish_entry_39 -> ht_probe_next<any, int>
;   botlish_fn_40 / botlish_entry_40 -> ht_find_get<any, str, int>
;   botlish_fn_41 / botlish_entry_41 -> ht_find_insert<mutarray, any, int, int>
;   botlish_fn_42 / botlish_entry_42 -> ht_get<any, str>
;   botlish_fn_43 / botlish_entry_43 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_44 / botlish_entry_44 -> ht_rehash_insert<list<mutarray>, int, any, any>
;   botlish_fn_45 / botlish_entry_45 -> ht_rehash_scan<list, int, int, list<mutarray>, int>
;   botlish_fn_46 / botlish_entry_46 -> ht_rehash<mutarray, int>
;   botlish_fn_47 / botlish_entry_47 -> ht_should_grow<mutarray>
;   botlish_fn_48 / botlish_entry_48 -> ht_grow_or_clean<mutarray>
;   botlish_fn_49 / botlish_entry_49 -> ht_place<mutarray, int, any, any>
;   botlish_fn_50 / botlish_entry_50 -> ht_set<mutarray, any, any>
;   botlish_fn_51 / botlish_entry_51 -> row_new<bool, int>
;   botlish_fn_52 / botlish_entry_52 -> row_fill<mutarray, any, any, int, int>
;   botlish_fn_53 / botlish_entry_53 -> row_table<any, int, any, bool>
;   botlish_fn_54 / botlish_entry_54 -> build_rows<list, int, any, int, list[mutarray, int], bool>
;   botlish_fn_55 / botlish_entry_55 -> csv_records_generic<str, bool>
;   botlish_fn_56 / botlish_entry_56 -> csv_records<str>
;   botlish_fn_57 / botlish_entry_57 -> csv_records_presized<str>
;   botlish_fn_58 / botlish_entry_58 -> sample<generic>


csv_records.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
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

000000000000002d <botlish_fn_1: geo_new<generic>>:
      2d:	push   rbp
      2e:	mov    rbp,rsp
      31:	sub    rsp,0x10
      35:	mov    esi,0x1
      3a:	mov    QWORD PTR [rsp],0x1
      42:	call   47 <botlish_fn_1+0x1a>
			43: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      47:	test   rax,rax
      4a:	jne    5f <botlish_fn_1+0x32>
      50:	xor    rdx,rdx
      53:	mov    rax,rdx
      56:	add    rsp,0x10
      5a:	mov    rsp,rbp
      5d:	pop    rbp
      5e:	ret
      5f:	mov    edx,0x1
      64:	add    rsp,0x10
      68:	mov    rsp,rbp
      6b:	pop    rbp
      6c:	ret

000000000000006d <botlish_entry_1: geo_new<generic>>:
      6d:	push   rbp
      6e:	mov    rbp,rsp
      71:	ud2
      73:	add    BYTE PTR [rax],al
      75:	add    BYTE PTR [rax],al
	...

0000000000000078 <botlish_fn_2: geo_new_capacity<int, int>>:
      78:	push   rbp
      79:	mov    rbp,rsp
      7c:	sub    rsp,0x40
      80:	mov    QWORD PTR [rsp+0x20],rbx
      85:	mov    QWORD PTR [rsp+0x28],r12
      8a:	mov    QWORD PTR [rsp+0x30],r13
      8f:	mov    r12,rdi
      92:	mov    QWORD PTR [rsp],rsi
      96:	mov    QWORD PTR [rsp+0x8],rdx
      9b:	mov    rbx,rdx
      9e:	mov    QWORD PTR [rsp+0x10],0x5
      a7:	test   rsi,0x1
      ae:	je     d0 <botlish_fn_2+0x58>
      b4:	mov    rax,rsi
      b7:	sar    rax,1
      ba:	imul   QWORD PTR [rip+0xdf]        # 1a0 <botlish_fn_2+0x128>
      c1:	seto   cl
      c4:	or     rax,0x1
      c8:	test   cl,cl
      ca:	je     dd <botlish_fn_2+0x65>
      d0:	mov    edx,0x5
      d5:	mov    rdi,r12
      d8:	call   dd <botlish_fn_2+0x65>
			d9: R_X86_64_PLT32	rt_int_mul-0x4
      dd:	mov    rcx,rax
      e0:	and    rcx,rbx
      e3:	mov    r13,rax
      e6:	test   rcx,0x1
      ed:	jne    119 <botlish_fn_2+0xa1>
      f3:	mov    rdx,rbx
      f6:	mov    rsi,r13
      f9:	mov    rdi,r12
      fc:	call   101 <botlish_fn_2+0x89>
			fd: R_X86_64_PLT32	rt_int_cmp-0x4
     101:	mov    ecx,0x2
     106:	test   rax,rax
     109:	cmovle rcx,QWORD PTR [rip+0x97]        # 1a8 <botlish_fn_2+0x130>
     111:	mov    rax,r13
     114:	jmp    12c <botlish_fn_2+0xb4>
     119:	mov    ecx,0x2
     11e:	mov    rax,r13
     121:	cmp    rax,rbx
     124:	cmovle rcx,QWORD PTR [rip+0x7c]        # 1a8 <botlish_fn_2+0x130>
     12c:	cmp    rcx,0x6
     130:	je     14e <botlish_fn_2+0xd6>
     136:	mov    rbx,QWORD PTR [rsp+0x20]
     13b:	mov    r12,QWORD PTR [rsp+0x28]
     140:	mov    r13,QWORD PTR [rsp+0x30]
     145:	add    rsp,0x40
     149:	mov    rsp,rbp
     14c:	pop    rbp
     14d:	ret
     14e:	mov    QWORD PTR [rsp],0x3
     156:	test   rbx,0x1
     15d:	je     175 <botlish_fn_2+0xfd>
     163:	mov    rax,rbx
     166:	add    rax,0x2
     16a:	seto   cl
     16d:	test   cl,cl
     16f:	je     185 <botlish_fn_2+0x10d>
     175:	mov    edx,0x3
     17a:	mov    rsi,rbx
     17d:	mov    rdi,r12
     180:	call   185 <botlish_fn_2+0x10d>
			181: R_X86_64_PLT32	rt_int_add-0x4
     185:	mov    rbx,QWORD PTR [rsp+0x20]
     18a:	mov    r12,QWORD PTR [rsp+0x28]
     18f:	mov    r13,QWORD PTR [rsp+0x30]
     194:	add    rsp,0x40
     198:	mov    rsp,rbp
     19b:	pop    rbp
     19c:	ret
     19d:	add    BYTE PTR [rax],al
     19f:	add    BYTE PTR [rax+rax*1],al
     1a2:	add    BYTE PTR [rax],al
     1a4:	add    BYTE PTR [rax],al
     1a6:	add    BYTE PTR [rax],al
     1a8:	(bad)
     1a9:	add    BYTE PTR [rax],al
     1ab:	add    BYTE PTR [rax],al
     1ad:	add    BYTE PTR [rax],al
	...

00000000000001b0 <botlish_entry_2: geo_new_capacity<int, int>>:
     1b0:	push   rbp
     1b1:	mov    rbp,rsp
     1b4:	mov    rsi,QWORD PTR [rdx]
     1b7:	mov    rdx,QWORD PTR [rdx+0x8]
     1bb:	call   1c0 <botlish_entry_2+0x10>
			1bc: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     1c0:	mov    rsp,rbp
     1c3:	pop    rbp
     1c4:	ret
     1c5:	add    BYTE PTR [rax],al
	...

00000000000001c8 <botlish_fn_3: geo_grow<mutarray, int>>:
     1c8:	push   rbp
     1c9:	mov    rbp,rsp
     1cc:	sub    rsp,0x40
     1d0:	mov    QWORD PTR [rsp+0x20],rbx
     1d5:	mov    QWORD PTR [rsp+0x28],r12
     1da:	mov    QWORD PTR [rsp+0x30],r13
     1df:	mov    QWORD PTR [rsp+0x38],r14
     1e4:	mov    r13,rdi
     1e7:	mov    QWORD PTR [rsp],rsi
     1eb:	mov    r12,rsi
     1ee:	mov    QWORD PTR [rsp+0x8],rdx
     1f3:	mov    rbx,rdx
     1f6:	mov    rsi,r12
     1f9:	mov    rdi,r13
     1fc:	call   201 <botlish_fn_3+0x39>
			1fd: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     201:	mov    r14,rax
     204:	mov    QWORD PTR [rsp+0x10],rax
     209:	mov    rcx,rbx
     20c:	and    rcx,rax
     20f:	test   rcx,0x1
     216:	jne    242 <botlish_fn_3+0x7a>
     21c:	mov    rdx,r14
     21f:	mov    rsi,rbx
     222:	mov    rdi,r13
     225:	call   22a <botlish_fn_3+0x62>
			226: R_X86_64_PLT32	rt_int_cmp-0x4
     22a:	mov    ecx,0x2
     22f:	test   rax,rax
     232:	cmovl  rcx,QWORD PTR [rip+0xd6]        # 310 <botlish_fn_3+0x148>
     23a:	mov    rax,r14
     23d:	jmp    255 <botlish_fn_3+0x8d>
     242:	mov    ecx,0x2
     247:	mov    rax,r14
     24a:	cmp    rbx,rax
     24d:	cmovl  rcx,QWORD PTR [rip+0xbb]        # 310 <botlish_fn_3+0x148>
     255:	cmp    rcx,0x6
     259:	je     2ec <botlish_fn_3+0x124>
     25f:	mov    rsi,rax
     262:	mov    rdx,rbx
     265:	mov    rdi,r13
     268:	call   26d <botlish_fn_3+0xa5>
			269: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     26d:	mov    QWORD PTR [rsp+0x10],rax
     272:	mov    rsi,rax
     275:	mov    rdi,r13
     278:	call   27d <botlish_fn_3+0xb5>
			279: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     27d:	test   rax,rax
     280:	mov    r14,rax
     283:	je     2ac <botlish_fn_3+0xe4>
     289:	mov    r8d,0x1
     28f:	mov    rcx,r12
     292:	mov    rdi,r13
     295:	mov    r9,rbx
     298:	mov    rsi,r14
     29b:	mov    rdx,r8
     29e:	call   2a3 <botlish_fn_3+0xdb>
			29f: R_X86_64_PLT32	rt_mutarray_copy-0x4
     2a3:	test   rax,rax
     2a6:	jne    2cc <botlish_fn_3+0x104>
     2ac:	xor    rax,rax
     2af:	mov    rbx,QWORD PTR [rsp+0x20]
     2b4:	mov    r12,QWORD PTR [rsp+0x28]
     2b9:	mov    r13,QWORD PTR [rsp+0x30]
     2be:	mov    r14,QWORD PTR [rsp+0x38]
     2c3:	add    rsp,0x40
     2c7:	mov    rsp,rbp
     2ca:	pop    rbp
     2cb:	ret
     2cc:	mov    rax,r14
     2cf:	mov    rbx,QWORD PTR [rsp+0x20]
     2d4:	mov    r12,QWORD PTR [rsp+0x28]
     2d9:	mov    r13,QWORD PTR [rsp+0x30]
     2de:	mov    r14,QWORD PTR [rsp+0x38]
     2e3:	add    rsp,0x40
     2e7:	mov    rsp,rbp
     2ea:	pop    rbp
     2eb:	ret
     2ec:	mov    rax,r12
     2ef:	mov    rbx,QWORD PTR [rsp+0x20]
     2f4:	mov    r12,QWORD PTR [rsp+0x28]
     2f9:	mov    r13,QWORD PTR [rsp+0x30]
     2fe:	mov    r14,QWORD PTR [rsp+0x38]
     303:	add    rsp,0x40
     307:	mov    rsp,rbp
     30a:	pop    rbp
     30b:	ret
     30c:	add    BYTE PTR [rax],al
     30e:	add    BYTE PTR [rax],al
     310:	(bad)
     311:	add    BYTE PTR [rax],al
     313:	add    BYTE PTR [rax],al
     315:	add    BYTE PTR [rax],al
	...

0000000000000318 <botlish_entry_3: geo_grow<mutarray, int>>:
     318:	push   rbp
     319:	mov    rbp,rsp
     31c:	mov    rsi,QWORD PTR [rdx]
     31f:	mov    rdx,QWORD PTR [rdx+0x8]
     323:	call   328 <botlish_entry_3+0x10>
			324: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     328:	mov    rsp,rbp
     32b:	pop    rbp
     32c:	ret

000000000000032d <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     32d:	push   rbp
     32e:	mov    rbp,rsp
     331:	sub    rsp,0x40
     335:	mov    QWORD PTR [rsp+0x20],rbx
     33a:	mov    QWORD PTR [rsp+0x28],r12
     33f:	mov    QWORD PTR [rsp+0x30],r13
     344:	mov    r12,rdi
     347:	mov    QWORD PTR [rsp],rsi
     34b:	mov    QWORD PTR [rsp+0x8],rdx
     350:	mov    rdi,rdx
     353:	mov    QWORD PTR [rsp+0x10],rcx
     358:	mov    r13,rcx
     35b:	mov    rbx,rdi
     35e:	mov    rdx,rbx
     361:	mov    rdi,r12
     364:	call   369 <botlish_fn_4+0x3c>
			365: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     369:	test   rax,rax
     36c:	je     393 <botlish_fn_4+0x66>
     372:	mov    QWORD PTR [rsp],rax
     376:	mov    rcx,r13
     379:	mov    r13,rax
     37c:	mov    rdx,rbx
     37f:	mov    rsi,r13
     382:	mov    rdi,r12
     385:	call   38a <botlish_fn_4+0x5d>
			386: R_X86_64_PLT32	rt_mutarray_set-0x4
     38a:	test   rax,rax
     38d:	jne    3b1 <botlish_fn_4+0x84>
     393:	xor    rdx,rdx
     396:	mov    rax,rdx
     399:	mov    rbx,QWORD PTR [rsp+0x20]
     39e:	mov    r12,QWORD PTR [rsp+0x28]
     3a3:	mov    r13,QWORD PTR [rsp+0x30]
     3a8:	add    rsp,0x40
     3ac:	mov    rsp,rbp
     3af:	pop    rbp
     3b0:	ret
     3b1:	mov    QWORD PTR [rsp+0x10],0x3
     3ba:	test   rbx,0x1
     3c1:	jne    3cf <botlish_fn_4+0xa2>
     3c7:	mov    rdi,rbx
     3ca:	jmp    3ec <botlish_fn_4+0xbf>
     3cf:	mov    rdx,rbx
     3d2:	add    rdx,0x2
     3d6:	mov    rdi,rbx
     3d9:	seto   al
     3dc:	test   al,al
     3de:	jne    3ec <botlish_fn_4+0xbf>
     3e4:	mov    rax,r13
     3e7:	jmp    402 <botlish_fn_4+0xd5>
     3ec:	mov    edx,0x3
     3f1:	mov    rsi,rdi
     3f4:	mov    rdi,r12
     3f7:	call   3fc <botlish_fn_4+0xcf>
			3f8: R_X86_64_PLT32	rt_int_add-0x4
     3fc:	mov    rdx,rax
     3ff:	mov    rax,r13
     402:	mov    rbx,QWORD PTR [rsp+0x20]
     407:	mov    r12,QWORD PTR [rsp+0x28]
     40c:	mov    r13,QWORD PTR [rsp+0x30]
     411:	add    rsp,0x40
     415:	mov    rsp,rbp
     418:	pop    rbp
     419:	ret

000000000000041a <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     41a:	push   rbp
     41b:	mov    rbp,rsp
     41e:	ud2

0000000000000420 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     420:	push   rbp
     421:	mov    rbp,rsp
     424:	sub    rsp,0x40
     428:	mov    QWORD PTR [rsp+0x20],rbx
     42d:	mov    QWORD PTR [rsp+0x28],r12
     432:	mov    QWORD PTR [rsp+0x30],r13
     437:	mov    r12,rdi
     43a:	mov    QWORD PTR [rsp],rsi
     43e:	mov    QWORD PTR [rsp+0x8],rdx
     443:	mov    rdi,rdx
     446:	mov    QWORD PTR [rsp+0x10],rcx
     44b:	mov    r13,rcx
     44e:	mov    rbx,rdi
     451:	mov    rdx,rbx
     454:	mov    rdi,r12
     457:	call   45c <botlish_fn_5+0x3c>
			458: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     45c:	test   rax,rax
     45f:	je     486 <botlish_fn_5+0x66>
     465:	mov    QWORD PTR [rsp],rax
     469:	mov    rcx,r13
     46c:	mov    r13,rax
     46f:	mov    rdx,rbx
     472:	mov    rsi,r13
     475:	mov    rdi,r12
     478:	call   47d <botlish_fn_5+0x5d>
			479: R_X86_64_PLT32	rt_mutarray_set-0x4
     47d:	test   rax,rax
     480:	jne    4a4 <botlish_fn_5+0x84>
     486:	xor    rdx,rdx
     489:	mov    rax,rdx
     48c:	mov    rbx,QWORD PTR [rsp+0x20]
     491:	mov    r12,QWORD PTR [rsp+0x28]
     496:	mov    r13,QWORD PTR [rsp+0x30]
     49b:	add    rsp,0x40
     49f:	mov    rsp,rbp
     4a2:	pop    rbp
     4a3:	ret
     4a4:	mov    QWORD PTR [rsp+0x10],0x3
     4ad:	test   rbx,0x1
     4b4:	jne    4c2 <botlish_fn_5+0xa2>
     4ba:	mov    rdi,rbx
     4bd:	jmp    4df <botlish_fn_5+0xbf>
     4c2:	mov    rdx,rbx
     4c5:	add    rdx,0x2
     4c9:	mov    rdi,rbx
     4cc:	seto   al
     4cf:	test   al,al
     4d1:	jne    4df <botlish_fn_5+0xbf>
     4d7:	mov    rax,r13
     4da:	jmp    4f5 <botlish_fn_5+0xd5>
     4df:	mov    edx,0x3
     4e4:	mov    rsi,rdi
     4e7:	mov    rdi,r12
     4ea:	call   4ef <botlish_fn_5+0xcf>
			4eb: R_X86_64_PLT32	rt_int_add-0x4
     4ef:	mov    rdx,rax
     4f2:	mov    rax,r13
     4f5:	mov    rbx,QWORD PTR [rsp+0x20]
     4fa:	mov    r12,QWORD PTR [rsp+0x28]
     4ff:	mov    r13,QWORD PTR [rsp+0x30]
     504:	add    rsp,0x40
     508:	mov    rsp,rbp
     50b:	pop    rbp
     50c:	ret

000000000000050d <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     50d:	push   rbp
     50e:	mov    rbp,rsp
     511:	ud2

0000000000000513 <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     513:	push   rbp
     514:	mov    rbp,rsp
     517:	sub    rsp,0x40
     51b:	mov    QWORD PTR [rsp+0x20],rbx
     520:	mov    QWORD PTR [rsp+0x28],r12
     525:	mov    QWORD PTR [rsp+0x30],r13
     52a:	mov    r12,rdi
     52d:	mov    QWORD PTR [rsp],rsi
     531:	mov    QWORD PTR [rsp+0x8],rdx
     536:	mov    rdi,rdx
     539:	mov    QWORD PTR [rsp+0x10],rcx
     53e:	mov    r13,rcx
     541:	mov    rbx,rdi
     544:	mov    rdx,rbx
     547:	mov    rdi,r12
     54a:	call   54f <botlish_fn_6+0x3c>
			54b: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     54f:	test   rax,rax
     552:	je     579 <botlish_fn_6+0x66>
     558:	mov    QWORD PTR [rsp],rax
     55c:	mov    rcx,r13
     55f:	mov    r13,rax
     562:	mov    rdx,rbx
     565:	mov    rsi,r13
     568:	mov    rdi,r12
     56b:	call   570 <botlish_fn_6+0x5d>
			56c: R_X86_64_PLT32	rt_mutarray_set-0x4
     570:	test   rax,rax
     573:	jne    597 <botlish_fn_6+0x84>
     579:	xor    rdx,rdx
     57c:	mov    rax,rdx
     57f:	mov    rbx,QWORD PTR [rsp+0x20]
     584:	mov    r12,QWORD PTR [rsp+0x28]
     589:	mov    r13,QWORD PTR [rsp+0x30]
     58e:	add    rsp,0x40
     592:	mov    rsp,rbp
     595:	pop    rbp
     596:	ret
     597:	mov    QWORD PTR [rsp+0x10],0x3
     5a0:	test   rbx,0x1
     5a7:	jne    5b5 <botlish_fn_6+0xa2>
     5ad:	mov    rdi,rbx
     5b0:	jmp    5d2 <botlish_fn_6+0xbf>
     5b5:	mov    rdx,rbx
     5b8:	add    rdx,0x2
     5bc:	mov    rdi,rbx
     5bf:	seto   al
     5c2:	test   al,al
     5c4:	jne    5d2 <botlish_fn_6+0xbf>
     5ca:	mov    rax,r13
     5cd:	jmp    5e8 <botlish_fn_6+0xd5>
     5d2:	mov    edx,0x3
     5d7:	mov    rsi,rdi
     5da:	mov    rdi,r12
     5dd:	call   5e2 <botlish_fn_6+0xcf>
			5de: R_X86_64_PLT32	rt_int_add-0x4
     5e2:	mov    rdx,rax
     5e5:	mov    rax,r13
     5e8:	mov    rbx,QWORD PTR [rsp+0x20]
     5ed:	mov    r12,QWORD PTR [rsp+0x28]
     5f2:	mov    r13,QWORD PTR [rsp+0x30]
     5f7:	add    rsp,0x40
     5fb:	mov    rsp,rbp
     5fe:	pop    rbp
     5ff:	ret

0000000000000600 <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     600:	push   rbp
     601:	mov    rbp,rsp
     604:	ud2

0000000000000606 <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     606:	push   rbp
     607:	mov    rbp,rsp
     60a:	sub    rsp,0x10
     60e:	mov    QWORD PTR [rsp],rsi
     612:	mov    QWORD PTR [rsp+0x8],rdx
     617:	call   61c <botlish_fn_7+0x16>
			618: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     61c:	test   rax,rax
     61f:	jne    631 <botlish_fn_7+0x2b>
     625:	xor    rax,rax
     628:	add    rsp,0x10
     62c:	mov    rsp,rbp
     62f:	pop    rbp
     630:	ret
     631:	add    rsp,0x10
     635:	mov    rsp,rbp
     638:	pop    rbp
     639:	ret

000000000000063a <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     63a:	push   rbp
     63b:	mov    rbp,rsp
     63e:	mov    rsi,QWORD PTR [rdx]
     641:	mov    rdx,QWORD PTR [rdx+0x8]
     645:	call   64a <botlish_entry_7+0x10>
			646: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     64a:	mov    rsp,rbp
     64d:	pop    rbp
     64e:	ret
	...

0000000000000650 <botlish_fn_8: peek<str, int>>:
     650:	push   rbp
     651:	mov    rbp,rsp
     654:	sub    rsp,0x40
     658:	mov    QWORD PTR [rsp+0x20],rbx
     65d:	mov    QWORD PTR [rsp+0x28],r12
     662:	mov    QWORD PTR [rsp+0x30],r13
     667:	mov    r13,rdi
     66a:	mov    QWORD PTR [rsp],rsi
     66e:	mov    r12,rsi
     671:	mov    QWORD PTR [rsp+0x8],rdx
     676:	mov    rbx,rdx
     679:	mov    rsi,r12
     67c:	mov    rdi,r13
     67f:	call   684 <botlish_fn_8+0x34>
			680: R_X86_64_PLT32	rt_str_len-0x4
     684:	mov    rcx,rbx
     687:	and    rcx,rax
     68a:	mov    rdx,rax
     68d:	test   rcx,0x1
     694:	jne    6ba <botlish_fn_8+0x6a>
     69a:	mov    rsi,rbx
     69d:	mov    rdi,r13
     6a0:	call   6a5 <botlish_fn_8+0x55>
			6a1: R_X86_64_PLT32	rt_int_cmp-0x4
     6a5:	mov    ecx,0x2
     6aa:	test   rax,rax
     6ad:	cmovge rcx,QWORD PTR [rip+0xcb]        # 780 <botlish_fn_8+0x130>
     6b5:	jmp    6ca <botlish_fn_8+0x7a>
     6ba:	mov    ecx,0x2
     6bf:	cmp    rbx,rdx
     6c2:	cmovge rcx,QWORD PTR [rip+0xb6]        # 780 <botlish_fn_8+0x130>
     6ca:	cmp    rcx,0x6
     6ce:	je     75e <botlish_fn_8+0x10e>
     6d4:	mov    QWORD PTR [rsp+0x10],0x3
     6dd:	test   rbx,0x1
     6e4:	je     6fc <botlish_fn_8+0xac>
     6ea:	mov    rcx,rbx
     6ed:	add    rcx,0x2
     6f1:	seto   al
     6f4:	test   al,al
     6f6:	je     70f <botlish_fn_8+0xbf>
     6fc:	mov    edx,0x3
     701:	mov    rsi,rbx
     704:	mov    rdi,r13
     707:	call   70c <botlish_fn_8+0xbc>
			708: R_X86_64_PLT32	rt_int_add-0x4
     70c:	mov    rcx,rax
     70f:	mov    QWORD PTR [rsp+0x10],rcx
     714:	mov    rdx,rbx
     717:	mov    rsi,r12
     71a:	mov    rdi,r13
     71d:	call   722 <botlish_fn_8+0xd2>
			71e: R_X86_64_PLT32	rt_substr-0x4
     722:	test   rax,rax
     725:	jne    746 <botlish_fn_8+0xf6>
     72b:	xor    rax,rax
     72e:	mov    rbx,QWORD PTR [rsp+0x20]
     733:	mov    r12,QWORD PTR [rsp+0x28]
     738:	mov    r13,QWORD PTR [rsp+0x30]
     73d:	add    rsp,0x40
     741:	mov    rsp,rbp
     744:	pop    rbp
     745:	ret
     746:	mov    rbx,QWORD PTR [rsp+0x20]
     74b:	mov    r12,QWORD PTR [rsp+0x28]
     750:	mov    r13,QWORD PTR [rsp+0x30]
     755:	add    rsp,0x40
     759:	mov    rsp,rbp
     75c:	pop    rbp
     75d:	ret
     75e:	mov    rdi,r13
     761:	mov    rax,QWORD PTR [rdi+0x10]
     765:	mov    rax,QWORD PTR [rax]
     768:	mov    rbx,QWORD PTR [rsp+0x20]
     76d:	mov    r12,QWORD PTR [rsp+0x28]
     772:	mov    r13,QWORD PTR [rsp+0x30]
     777:	add    rsp,0x40
     77b:	mov    rsp,rbp
     77e:	pop    rbp
     77f:	ret
     780:	(bad)
     781:	add    BYTE PTR [rax],al
     783:	add    BYTE PTR [rax],al
     785:	add    BYTE PTR [rax],al
	...

0000000000000788 <botlish_entry_8: peek<str, int>>:
     788:	push   rbp
     789:	mov    rbp,rsp
     78c:	mov    rsi,QWORD PTR [rdx]
     78f:	mov    rdx,QWORD PTR [rdx+0x8]
     793:	call   798 <botlish_entry_8+0x10>
			794: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     798:	mov    rsp,rbp
     79b:	pop    rbp
     79c:	ret
     79d:	add    BYTE PTR [rax],al
	...

00000000000007a0 <botlish_fn_9: peek<str, int>>:
     7a0:	push   rbp
     7a1:	mov    rbp,rsp
     7a4:	sub    rsp,0x50
     7a8:	mov    QWORD PTR [rsp+0x20],rbx
     7ad:	mov    QWORD PTR [rsp+0x28],r12
     7b2:	mov    QWORD PTR [rsp+0x30],r13
     7b7:	mov    QWORD PTR [rsp+0x38],r14
     7bc:	mov    QWORD PTR [rsp+0x40],r15
     7c1:	mov    r12,rcx
     7c4:	mov    r14,rdi
     7c7:	mov    QWORD PTR [rsp],rsi
     7cb:	mov    r13,rsi
     7ce:	mov    QWORD PTR [rsp+0x8],rdx
     7d3:	mov    rbx,rdx
     7d6:	mov    rsi,r13
     7d9:	mov    rdi,r14
     7dc:	call   7e1 <botlish_fn_9+0x41>
			7dd: R_X86_64_PLT32	rt_str_len-0x4
     7e1:	mov    rcx,rbx
     7e4:	and    rcx,rax
     7e7:	mov    rdx,rax
     7ea:	test   rcx,0x1
     7f1:	jne    817 <botlish_fn_9+0x77>
     7f7:	mov    rsi,rbx
     7fa:	mov    rdi,r14
     7fd:	call   802 <botlish_fn_9+0x62>
			7fe: R_X86_64_PLT32	rt_int_cmp-0x4
     802:	mov    ecx,0x2
     807:	test   rax,rax
     80a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 930 <botlish_fn_9+0x190>
     812:	jmp    827 <botlish_fn_9+0x87>
     817:	mov    ecx,0x2
     81c:	cmp    rbx,rdx
     81f:	cmovge rcx,QWORD PTR [rip+0x109]        # 930 <botlish_fn_9+0x190>
     827:	cmp    rcx,0x6
     82b:	je     8eb <botlish_fn_9+0x14b>
     831:	mov    QWORD PTR [rsp+0x10],0x3
     83a:	test   rbx,0x1
     841:	je     864 <botlish_fn_9+0xc4>
     847:	mov    rax,rbx
     84a:	add    rax,0x2
     84e:	seto   cl
     851:	test   cl,cl
     853:	jne    864 <botlish_fn_9+0xc4>
     859:	mov    rdi,r14
     85c:	mov    r15,rax
     85f:	jmp    87a <botlish_fn_9+0xda>
     864:	mov    edx,0x3
     869:	mov    rsi,rbx
     86c:	mov    rdi,r14
     86f:	call   874 <botlish_fn_9+0xd4>
			870: R_X86_64_PLT32	rt_int_add-0x4
     874:	mov    r15,rax
     877:	mov    rdi,r14
     87a:	mov    rdi,r14
     87d:	mov    rcx,r15
     880:	mov    rdx,rbx
     883:	mov    rsi,r13
     886:	call   88b <botlish_fn_9+0xeb>
			887: R_X86_64_PLT32	rt_str_region_check-0x4
     88b:	test   rax,rax
     88e:	jne    8b9 <botlish_fn_9+0x119>
     894:	xor    rax,rax
     897:	mov    rbx,QWORD PTR [rsp+0x20]
     89c:	mov    r12,QWORD PTR [rsp+0x28]
     8a1:	mov    r13,QWORD PTR [rsp+0x30]
     8a6:	mov    r14,QWORD PTR [rsp+0x38]
     8ab:	mov    r15,QWORD PTR [rsp+0x40]
     8b0:	add    rsp,0x50
     8b4:	mov    rsp,rbp
     8b7:	pop    rbp
     8b8:	ret
     8b9:	mov    rcx,r12
     8bc:	mov    QWORD PTR [rcx],rbx
     8bf:	mov    rax,r15
     8c2:	mov    QWORD PTR [rcx+0x8],rax
     8c6:	mov    rax,r13
     8c9:	mov    rbx,QWORD PTR [rsp+0x20]
     8ce:	mov    r12,QWORD PTR [rsp+0x28]
     8d3:	mov    r13,QWORD PTR [rsp+0x30]
     8d8:	mov    r14,QWORD PTR [rsp+0x38]
     8dd:	mov    r15,QWORD PTR [rsp+0x40]
     8e2:	add    rsp,0x50
     8e6:	mov    rsp,rbp
     8e9:	pop    rbp
     8ea:	ret
     8eb:	mov    rcx,r12
     8ee:	mov    rdi,r14
     8f1:	mov    rax,QWORD PTR [rdi+0x10]
     8f5:	mov    rax,QWORD PTR [rax]
     8f8:	mov    QWORD PTR [rcx],0x1
     8ff:	mov    QWORD PTR [rcx+0x8],0x1
     907:	mov    rbx,QWORD PTR [rsp+0x20]
     90c:	mov    r12,QWORD PTR [rsp+0x28]
     911:	mov    r13,QWORD PTR [rsp+0x30]
     916:	mov    r14,QWORD PTR [rsp+0x38]
     91b:	mov    r15,QWORD PTR [rsp+0x40]
     920:	add    rsp,0x50
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

0000000000000938 <botlish_entry_9: peek<str, int>>:
     938:	push   rbp
     939:	mov    rbp,rsp
     93c:	ud2

000000000000093e <botlish_fn_10: scan_unquoted<str, int, int>>:
     93e:	push   rbp
     93f:	mov    rbp,rsp
     942:	sub    rsp,0x80
     949:	mov    QWORD PTR [rsp+0x50],rbx
     94e:	mov    QWORD PTR [rsp+0x58],r12
     953:	mov    QWORD PTR [rsp+0x60],r13
     958:	mov    QWORD PTR [rsp+0x68],r14
     95d:	mov    QWORD PTR [rsp+0x70],r15
     962:	mov    QWORD PTR [rsp+0x30],rdi
     967:	mov    QWORD PTR [rsp+0x18],0x0
     970:	mov    QWORD PTR [rsp],rsi
     974:	mov    r15,rsi
     977:	mov    QWORD PTR [rsp+0x8],rdx
     97c:	mov    r14,rdx
     97f:	mov    QWORD PTR [rsp+0x10],rcx
     984:	lea    r13,[rsp+0x20]
     989:	mov    QWORD PTR [rsp+0x38],rcx
     98e:	mov    rcx,r13
     991:	mov    rdx,QWORD PTR [rsp+0x38]
     996:	mov    rsi,r15
     999:	mov    rdi,QWORD PTR [rsp+0x30]
     99e:	call   9a3 <botlish_fn_10+0x65>
			99f: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     9a3:	mov    rsi,rax
     9a6:	mov    QWORD PTR [rsp+0x40],rax
     9ab:	test   rax,rsi
     9ae:	je     b07 <botlish_fn_10+0x1c9>
     9b4:	mov    rbx,QWORD PTR [rsp+0x20]
     9b9:	mov    r12,QWORD PTR [rsp+0x28]
     9be:	mov    rdi,QWORD PTR [rsp+0x30]
     9c3:	mov    rcx,QWORD PTR [rdi+0x10]
     9c7:	mov    r8,QWORD PTR [rcx]
     9ca:	mov    rcx,r12
     9cd:	mov    rdx,rbx
     9d0:	mov    rsi,QWORD PTR [rsp+0x40]
     9d5:	call   9da <botlish_fn_10+0x9c>
			9d6: R_X86_64_PLT32	rt_str_region_eq-0x4
     9da:	cmp    rax,0x6
     9de:	je     a1f <botlish_fn_10+0xe1>
     9e4:	mov    rdi,QWORD PTR [rsp+0x30]
     9e9:	mov    rax,QWORD PTR [rdi+0x10]
     9ed:	mov    r8,QWORD PTR [rax+0x8]
     9f1:	mov    rcx,r12
     9f4:	mov    rdx,rbx
     9f7:	mov    rsi,QWORD PTR [rsp+0x40]
     9fc:	call   a01 <botlish_fn_10+0xc3>
			9fd: R_X86_64_PLT32	rt_str_region_eq-0x4
     a01:	cmp    rax,0x6
     a05:	je     a15 <botlish_fn_10+0xd7>
     a0b:	mov    eax,0x2
     a10:	jmp    a24 <botlish_fn_10+0xe6>
     a15:	mov    eax,0x6
     a1a:	jmp    a24 <botlish_fn_10+0xe6>
     a1f:	mov    eax,0x6
     a24:	cmp    rax,0x6
     a28:	je     a69 <botlish_fn_10+0x12b>
     a2e:	mov    rdi,QWORD PTR [rsp+0x30]
     a33:	mov    rax,QWORD PTR [rdi+0x10]
     a37:	mov    r8,QWORD PTR [rax+0x10]
     a3b:	mov    rcx,r12
     a3e:	mov    rdx,rbx
     a41:	mov    rsi,QWORD PTR [rsp+0x40]
     a46:	call   a4b <botlish_fn_10+0x10d>
			a47: R_X86_64_PLT32	rt_str_region_eq-0x4
     a4b:	cmp    rax,0x6
     a4f:	je     a5f <botlish_fn_10+0x121>
     a55:	mov    eax,0x2
     a5a:	jmp    a6e <botlish_fn_10+0x130>
     a5f:	mov    eax,0x6
     a64:	jmp    a6e <botlish_fn_10+0x130>
     a69:	mov    eax,0x6
     a6e:	cmp    rax,0x6
     a72:	je     ae9 <botlish_fn_10+0x1ab>
     a78:	mov    QWORD PTR [rsp+0x18],0x3
     a81:	mov    rsi,QWORD PTR [rsp+0x38]
     a86:	test   rsi,0x1
     a8d:	je     ab4 <botlish_fn_10+0x176>
     a93:	mov    rsi,QWORD PTR [rsp+0x38]
     a98:	mov    rax,rsi
     a9b:	add    rax,0x2
     a9f:	seto   sil
     aa3:	test   sil,sil
     aa6:	jne    ab4 <botlish_fn_10+0x176>
     aac:	mov    rsi,r15
     aaf:	jmp    acb <botlish_fn_10+0x18d>
     ab4:	mov    edx,0x3
     ab9:	mov    rsi,QWORD PTR [rsp+0x38]
     abe:	mov    rdi,QWORD PTR [rsp+0x30]
     ac3:	call   ac8 <botlish_fn_10+0x18a>
			ac4: R_X86_64_PLT32	rt_int_add-0x4
     ac8:	mov    rsi,r15
     acb:	mov    QWORD PTR [rsp],rsi
     acf:	mov    rdx,r14
     ad2:	mov    QWORD PTR [rsp+0x8],rdx
     ad7:	mov    QWORD PTR [rsp+0x10],rax
     adc:	mov    r15,rsi
     adf:	mov    QWORD PTR [rsp+0x38],rax
     ae4:	jmp    98e <botlish_fn_10+0x50>
     ae9:	mov    rdx,r14
     aec:	mov    rsi,r15
     aef:	mov    rdi,QWORD PTR [rsp+0x30]
     af4:	mov    rcx,QWORD PTR [rsp+0x38]
     af9:	call   afe <botlish_fn_10+0x1c0>
			afa: R_X86_64_PLT32	rt_substr-0x4
     afe:	test   rax,rax
     b01:	jne    b32 <botlish_fn_10+0x1f4>
     b07:	xor    rdx,rdx
     b0a:	mov    rax,rdx
     b0d:	mov    rbx,QWORD PTR [rsp+0x50]
     b12:	mov    r12,QWORD PTR [rsp+0x58]
     b17:	mov    r13,QWORD PTR [rsp+0x60]
     b1c:	mov    r14,QWORD PTR [rsp+0x68]
     b21:	mov    r15,QWORD PTR [rsp+0x70]
     b26:	add    rsp,0x80
     b2d:	mov    rsp,rbp
     b30:	pop    rbp
     b31:	ret
     b32:	mov    rdx,QWORD PTR [rsp+0x38]
     b37:	mov    rbx,QWORD PTR [rsp+0x50]
     b3c:	mov    r12,QWORD PTR [rsp+0x58]
     b41:	mov    r13,QWORD PTR [rsp+0x60]
     b46:	mov    r14,QWORD PTR [rsp+0x68]
     b4b:	mov    r15,QWORD PTR [rsp+0x70]
     b50:	add    rsp,0x80
     b57:	mov    rsp,rbp
     b5a:	pop    rbp
     b5b:	ret

0000000000000b5c <botlish_entry_10: scan_unquoted<str, int, int>>:
     b5c:	push   rbp
     b5d:	mov    rbp,rsp
     b60:	ud2

0000000000000b62 <botlish_fn_11: scan_quoted<str, int, str>>:
     b62:	push   rbp
     b63:	mov    rbp,rsp
     b66:	sub    rsp,0x70
     b6a:	mov    QWORD PTR [rsp+0x40],rbx
     b6f:	mov    QWORD PTR [rsp+0x48],r12
     b74:	mov    QWORD PTR [rsp+0x50],r13
     b79:	mov    QWORD PTR [rsp+0x58],r14
     b7e:	mov    QWORD PTR [rsp+0x60],r15
     b83:	mov    r13,rdi
     b86:	mov    QWORD PTR [rsp+0x18],0x0
     b8f:	mov    QWORD PTR [rsp+0x20],0x0
     b98:	mov    QWORD PTR [rsp],rsi
     b9c:	mov    QWORD PTR [rsp+0x8],rdx
     ba1:	mov    QWORD PTR [rsp+0x10],rcx
     ba6:	lea    r12,[rsp+0x28]
     bab:	mov    rbx,rsi
     bae:	mov    r14,rdx
     bb1:	mov    r15,rcx
     bb4:	mov    rdx,r14
     bb7:	mov    rsi,rbx
     bba:	mov    rdi,r13
     bbd:	call   bc2 <botlish_fn_11+0x60>
			bbe: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     bc2:	test   rax,rax
     bc5:	je     de1 <botlish_fn_11+0x27f>
     bcb:	mov    QWORD PTR [rsp+0x18],rax
     bd0:	mov    rdi,r13
     bd3:	mov    QWORD PTR [rsp+0x38],rax
     bd8:	mov    rcx,QWORD PTR [rdi+0x10]
     bdc:	mov    rsi,QWORD PTR [rcx+0x18]
     be0:	mov    edx,0x1
     be5:	mov    ecx,0x3
     bea:	mov    r8,QWORD PTR [rsp+0x38]
     bef:	call   bf4 <botlish_fn_11+0x92>
			bf0: R_X86_64_PLT32	rt_str_region_eq-0x4
     bf4:	cmp    rax,0x6
     bf8:	je     c7b <botlish_fn_11+0x119>
     bfe:	mov    QWORD PTR [rsp+0x20],0x3
     c07:	mov    rsi,r14
     c0a:	test   rsi,0x1
     c11:	je     c31 <botlish_fn_11+0xcf>
     c17:	mov    rax,rsi
     c1a:	add    rax,0x2
     c1e:	seto   cl
     c21:	test   cl,cl
     c23:	jne    c31 <botlish_fn_11+0xcf>
     c29:	mov    rsi,rax
     c2c:	jmp    c41 <botlish_fn_11+0xdf>
     c31:	mov    edx,0x3
     c36:	mov    rdi,r13
     c39:	call   c3e <botlish_fn_11+0xdc>
			c3a: R_X86_64_PLT32	rt_int_add-0x4
     c3e:	mov    rsi,rax
     c41:	mov    QWORD PTR [rsp+0x8],rsi
     c46:	mov    r14,rsi
     c49:	mov    rsi,r15
     c4c:	mov    rdx,QWORD PTR [rsp+0x38]
     c51:	mov    rdi,r13
     c54:	call   c59 <botlish_fn_11+0xf7>
			c55: R_X86_64_PLT32	rt_str_cat-0x4
     c59:	test   rax,rax
     c5c:	je     de1 <botlish_fn_11+0x27f>
     c62:	mov    QWORD PTR [rsp],rbx
     c66:	mov    rsi,r14
     c69:	mov    QWORD PTR [rsp+0x8],rsi
     c6e:	mov    QWORD PTR [rsp+0x10],rax
     c73:	mov    r15,rax
     c76:	jmp    bb4 <botlish_fn_11+0x52>
     c7b:	mov    QWORD PTR [rsp+0x18],0x3
     c84:	mov    rsi,r14
     c87:	test   rsi,0x1
     c8e:	je     ca9 <botlish_fn_11+0x147>
     c94:	mov    rsi,r14
     c97:	mov    rdx,rsi
     c9a:	add    rdx,0x2
     c9e:	seto   al
     ca1:	test   al,al
     ca3:	je     cbc <botlish_fn_11+0x15a>
     ca9:	mov    edx,0x3
     cae:	mov    rsi,r14
     cb1:	mov    rdi,r13
     cb4:	call   cb9 <botlish_fn_11+0x157>
			cb5: R_X86_64_PLT32	rt_int_add-0x4
     cb9:	mov    rdx,rax
     cbc:	mov    QWORD PTR [rsp+0x18],rdx
     cc1:	mov    rcx,r12
     cc4:	mov    rsi,rbx
     cc7:	mov    rdi,r13
     cca:	call   ccf <botlish_fn_11+0x16d>
			ccb: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     ccf:	test   rax,rax
     cd2:	mov    rsi,rax
     cd5:	je     de1 <botlish_fn_11+0x27f>
     cdb:	mov    rdx,QWORD PTR [rsp+0x28]
     ce0:	mov    rcx,QWORD PTR [rsp+0x30]
     ce5:	mov    rdi,r13
     ce8:	mov    rax,QWORD PTR [rdi+0x10]
     cec:	mov    r8,QWORD PTR [rax+0x18]
     cf0:	call   cf5 <botlish_fn_11+0x193>
			cf1: R_X86_64_PLT32	rt_str_region_eq-0x4
     cf5:	cmp    rax,0x6
     cf9:	je     d6c <botlish_fn_11+0x20a>
     cff:	mov    QWORD PTR [rsp],0x3
     d07:	mov    rsi,r14
     d0a:	test   rsi,0x1
     d11:	je     d34 <botlish_fn_11+0x1d2>
     d17:	mov    rsi,r14
     d1a:	mov    rdx,rsi
     d1d:	add    rdx,0x2
     d21:	seto   al
     d24:	test   al,al
     d26:	jne    d34 <botlish_fn_11+0x1d2>
     d2c:	mov    rax,r15
     d2f:	jmp    d4a <botlish_fn_11+0x1e8>
     d34:	mov    edx,0x3
     d39:	mov    rsi,r14
     d3c:	mov    rdi,r13
     d3f:	call   d44 <botlish_fn_11+0x1e2>
			d40: R_X86_64_PLT32	rt_int_add-0x4
     d44:	mov    rdx,rax
     d47:	mov    rax,r15
     d4a:	mov    rbx,QWORD PTR [rsp+0x40]
     d4f:	mov    r12,QWORD PTR [rsp+0x48]
     d54:	mov    r13,QWORD PTR [rsp+0x50]
     d59:	mov    r14,QWORD PTR [rsp+0x58]
     d5e:	mov    r15,QWORD PTR [rsp+0x60]
     d63:	add    rsp,0x70
     d67:	mov    rsp,rbp
     d6a:	pop    rbp
     d6b:	ret
     d6c:	mov    QWORD PTR [rsp+0x18],0x5
     d75:	mov    rsi,r14
     d78:	test   rsi,0x1
     d7f:	je     da5 <botlish_fn_11+0x243>
     d85:	mov    rsi,r14
     d88:	mov    rax,rsi
     d8b:	add    rax,0x4
     d8f:	seto   cl
     d92:	test   cl,cl
     d94:	jne    da5 <botlish_fn_11+0x243>
     d9a:	mov    rsi,rax
     d9d:	mov    r14,rax
     da0:	jmp    dbb <botlish_fn_11+0x259>
     da5:	mov    edx,0x5
     daa:	mov    rsi,r14
     dad:	mov    rdi,r13
     db0:	call   db5 <botlish_fn_11+0x253>
			db1: R_X86_64_PLT32	rt_int_add-0x4
     db5:	mov    rsi,rax
     db8:	mov    r14,rax
     dbb:	mov    QWORD PTR [rsp+0x8],rsi
     dc0:	mov    rdi,r13
     dc3:	mov    rax,QWORD PTR [rdi+0x10]
     dc7:	mov    rdx,QWORD PTR [rax+0x18]
     dcb:	mov    QWORD PTR [rsp+0x18],rdx
     dd0:	mov    rsi,r15
     dd3:	call   dd8 <botlish_fn_11+0x276>
			dd4: R_X86_64_PLT32	rt_str_cat-0x4
     dd8:	test   rax,rax
     ddb:	jne    e09 <botlish_fn_11+0x2a7>
     de1:	xor    rdx,rdx
     de4:	mov    rax,rdx
     de7:	mov    rbx,QWORD PTR [rsp+0x40]
     dec:	mov    r12,QWORD PTR [rsp+0x48]
     df1:	mov    r13,QWORD PTR [rsp+0x50]
     df6:	mov    r14,QWORD PTR [rsp+0x58]
     dfb:	mov    r15,QWORD PTR [rsp+0x60]
     e00:	add    rsp,0x70
     e04:	mov    rsp,rbp
     e07:	pop    rbp
     e08:	ret
     e09:	mov    QWORD PTR [rsp],rbx
     e0d:	mov    rsi,r14
     e10:	mov    QWORD PTR [rsp+0x8],rsi
     e15:	mov    QWORD PTR [rsp+0x10],rax
     e1a:	mov    r15,rax
     e1d:	jmp    bb4 <botlish_fn_11+0x52>

0000000000000e22 <botlish_entry_11: scan_quoted<str, int, str>>:
     e22:	push   rbp
     e23:	mov    rbp,rsp
     e26:	ud2

0000000000000e28 <botlish_fn_12: scan_field<str, int>>:
     e28:	push   rbp
     e29:	mov    rbp,rsp
     e2c:	sub    rsp,0x50
     e30:	mov    QWORD PTR [rsp+0x30],rbx
     e35:	mov    QWORD PTR [rsp+0x38],r12
     e3a:	mov    QWORD PTR [rsp+0x40],r13
     e3f:	mov    r12,rdi
     e42:	mov    r13,rdx
     e45:	mov    QWORD PTR [rsp+0x10],0x0
     e4e:	mov    QWORD PTR [rsp],rsi
     e52:	mov    rbx,rsi
     e55:	mov    QWORD PTR [rsp+0x8],rdx
     e5a:	lea    rcx,[rsp+0x18]
     e5f:	mov    rdx,r13
     e62:	mov    rsi,rbx
     e65:	mov    rdi,r12
     e68:	call   e6d <botlish_fn_12+0x45>
			e69: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     e6d:	test   rax,rax
     e70:	mov    rsi,rax
     e73:	je     f3d <botlish_fn_12+0x115>
     e79:	mov    rdx,QWORD PTR [rsp+0x18]
     e7e:	mov    rcx,QWORD PTR [rsp+0x20]
     e83:	mov    rdi,r12
     e86:	mov    rax,QWORD PTR [rdi+0x10]
     e8a:	mov    r8,QWORD PTR [rax+0x18]
     e8e:	call   e93 <botlish_fn_12+0x6b>
			e8f: R_X86_64_PLT32	rt_str_region_eq-0x4
     e93:	cmp    rax,0x6
     e97:	je     ecf <botlish_fn_12+0xa7>
     e9d:	mov    rcx,r13
     ea0:	mov    rsi,rbx
     ea3:	mov    rdi,r12
     ea6:	mov    rdx,rcx
     ea9:	call   eae <botlish_fn_12+0x86>
			eaa: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
     eae:	test   rax,rax
     eb1:	je     f3d <botlish_fn_12+0x115>
     eb7:	mov    rbx,QWORD PTR [rsp+0x30]
     ebc:	mov    r12,QWORD PTR [rsp+0x38]
     ec1:	mov    r13,QWORD PTR [rsp+0x40]
     ec6:	add    rsp,0x50
     eca:	mov    rsp,rbp
     ecd:	pop    rbp
     ece:	ret
     ecf:	mov    rcx,r13
     ed2:	mov    QWORD PTR [rsp+0x10],0x3
     edb:	test   rcx,0x1
     ee2:	jne    ef0 <botlish_fn_12+0xc8>
     ee8:	mov    r13,rcx
     eeb:	jmp    f05 <botlish_fn_12+0xdd>
     ef0:	mov    rdx,rcx
     ef3:	add    rdx,0x2
     ef7:	mov    r13,rcx
     efa:	seto   al
     efd:	test   al,al
     eff:	je     f18 <botlish_fn_12+0xf0>
     f05:	mov    edx,0x3
     f0a:	mov    rsi,r13
     f0d:	mov    rdi,r12
     f10:	call   f15 <botlish_fn_12+0xed>
			f11: R_X86_64_PLT32	rt_int_add-0x4
     f15:	mov    rdx,rax
     f18:	mov    QWORD PTR [rsp+0x8],rdx
     f1d:	mov    rdi,r12
     f20:	mov    rax,QWORD PTR [rdi+0x10]
     f24:	mov    rcx,QWORD PTR [rax]
     f27:	mov    QWORD PTR [rsp+0x10],rcx
     f2c:	mov    rsi,rbx
     f2f:	call   f34 <botlish_fn_12+0x10c>
			f30: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
     f34:	test   rax,rax
     f37:	jne    f5b <botlish_fn_12+0x133>
     f3d:	xor    rdx,rdx
     f40:	mov    rax,rdx
     f43:	mov    rbx,QWORD PTR [rsp+0x30]
     f48:	mov    r12,QWORD PTR [rsp+0x38]
     f4d:	mov    r13,QWORD PTR [rsp+0x40]
     f52:	add    rsp,0x50
     f56:	mov    rsp,rbp
     f59:	pop    rbp
     f5a:	ret
     f5b:	mov    rbx,QWORD PTR [rsp+0x30]
     f60:	mov    r12,QWORD PTR [rsp+0x38]
     f65:	mov    r13,QWORD PTR [rsp+0x40]
     f6a:	add    rsp,0x50
     f6e:	mov    rsp,rbp
     f71:	pop    rbp
     f72:	ret

0000000000000f73 <botlish_entry_12: scan_field<str, int>>:
     f73:	push   rbp
     f74:	mov    rbp,rsp
     f77:	ud2

0000000000000f79 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
     f79:	push   rbp
     f7a:	mov    rbp,rsp
     f7d:	sub    rsp,0x90
     f84:	mov    QWORD PTR [rsp+0x60],rbx
     f89:	mov    QWORD PTR [rsp+0x68],r12
     f8e:	mov    QWORD PTR [rsp+0x70],r13
     f93:	mov    QWORD PTR [rsp+0x78],r14
     f98:	mov    QWORD PTR [rsp+0x80],r15
     fa0:	mov    r15,rdi
     fa3:	mov    QWORD PTR [rsp+0x20],0x0
     fac:	mov    QWORD PTR [rsp],rsi
     fb0:	mov    QWORD PTR [rsp+0x8],rdx
     fb5:	mov    QWORD PTR [rsp+0x10],rcx
     fba:	mov    QWORD PTR [rsp+0x18],r8
     fbf:	lea    r14,[rsp+0x28]
     fc4:	mov    rbx,rsi
     fc7:	mov    r12,r8
     fca:	mov    r13,rcx
     fcd:	mov    rsi,rbx
     fd0:	mov    rdi,r15
     fd3:	call   fd8 <botlish_fn_13+0x5f>
			fd4: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
     fd8:	test   rax,rax
     fdb:	je     10f6 <botlish_fn_13+0x17d>
     fe1:	mov    QWORD PTR [rsp+0x8],rax
     fe6:	mov    rcx,rax
     fe9:	mov    QWORD PTR [rsp+0x20],rdx
     fee:	mov    QWORD PTR [rsp+0x50],rdx
     ff3:	mov    rsi,r13
     ff6:	mov    rdx,r12
     ff9:	mov    rdi,r15
     ffc:	call   1001 <botlish_fn_13+0x88>
			ffd: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    1001:	test   rax,rax
    1004:	je     10f6 <botlish_fn_13+0x17d>
    100a:	mov    QWORD PTR [rsp+0x8],rax
    100f:	mov    QWORD PTR [rsp+0x40],rax
    1014:	mov    QWORD PTR [rsp+0x10],rdx
    1019:	mov    QWORD PTR [rsp+0x48],rdx
    101e:	mov    rcx,r14
    1021:	mov    rdx,QWORD PTR [rsp+0x50]
    1026:	mov    rsi,rbx
    1029:	mov    rdi,r15
    102c:	call   1031 <botlish_fn_13+0xb8>
			102d: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1031:	test   rax,rax
    1034:	mov    QWORD PTR [rsp+0x38],rax
    1039:	je     10f6 <botlish_fn_13+0x17d>
    103f:	mov    r12,QWORD PTR [rsp+0x28]
    1044:	mov    r13,QWORD PTR [rsp+0x30]
    1049:	mov    rdi,r15
    104c:	mov    rcx,QWORD PTR [rdi+0x10]
    1050:	mov    r8,QWORD PTR [rcx+0x8]
    1054:	mov    rcx,r13
    1057:	mov    rdx,r12
    105a:	mov    rsi,QWORD PTR [rsp+0x38]
    105f:	call   1064 <botlish_fn_13+0xeb>
			1060: R_X86_64_PLT32	rt_str_region_eq-0x4
    1064:	cmp    rax,0x6
    1068:	je     11a4 <botlish_fn_13+0x22b>
    106e:	mov    rdi,r15
    1071:	mov    rax,QWORD PTR [rdi+0x10]
    1075:	mov    r8,QWORD PTR [rax+0x10]
    1079:	mov    rcx,r13
    107c:	mov    rdx,r12
    107f:	mov    rsi,QWORD PTR [rsp+0x38]
    1084:	call   1089 <botlish_fn_13+0x110>
			1085: R_X86_64_PLT32	rt_str_region_eq-0x4
    1089:	cmp    rax,0x6
    108d:	je     10db <botlish_fn_13+0x162>
    1093:	mov    rdx,QWORD PTR [rsp+0x48]
    1098:	mov    rsi,QWORD PTR [rsp+0x40]
    109d:	mov    rdi,r15
    10a0:	call   10a5 <botlish_fn_13+0x12c>
			10a1: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    10a5:	test   rax,rax
    10a8:	je     10f6 <botlish_fn_13+0x17d>
    10ae:	mov    rdx,QWORD PTR [rsp+0x50]
    10b3:	mov    rbx,QWORD PTR [rsp+0x60]
    10b8:	mov    r12,QWORD PTR [rsp+0x68]
    10bd:	mov    r13,QWORD PTR [rsp+0x70]
    10c2:	mov    r14,QWORD PTR [rsp+0x78]
    10c7:	mov    r15,QWORD PTR [rsp+0x80]
    10cf:	add    rsp,0x90
    10d6:	mov    rsp,rbp
    10d9:	pop    rbp
    10da:	ret
    10db:	mov    rdx,QWORD PTR [rsp+0x48]
    10e0:	mov    rsi,QWORD PTR [rsp+0x40]
    10e5:	mov    rdi,r15
    10e8:	call   10ed <botlish_fn_13+0x174>
			10e9: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    10ed:	test   rax,rax
    10f0:	jne    1124 <botlish_fn_13+0x1ab>
    10f6:	xor    rdx,rdx
    10f9:	mov    rax,rdx
    10fc:	mov    rbx,QWORD PTR [rsp+0x60]
    1101:	mov    r12,QWORD PTR [rsp+0x68]
    1106:	mov    r13,QWORD PTR [rsp+0x70]
    110b:	mov    r14,QWORD PTR [rsp+0x78]
    1110:	mov    r15,QWORD PTR [rsp+0x80]
    1118:	add    rsp,0x90
    111f:	mov    rsp,rbp
    1122:	pop    rbp
    1123:	ret
    1124:	mov    QWORD PTR [rsp],rax
    1128:	mov    r12,rax
    112b:	mov    QWORD PTR [rsp+0x8],0x3
    1134:	mov    rdx,QWORD PTR [rsp+0x50]
    1139:	test   rdx,0x1
    1140:	je     1164 <botlish_fn_13+0x1eb>
    1146:	mov    rdx,QWORD PTR [rsp+0x50]
    114b:	add    rdx,0x2
    114f:	seto   r10b
    1153:	test   r10b,r10b
    1156:	jne    1164 <botlish_fn_13+0x1eb>
    115c:	mov    rax,r12
    115f:	jmp    117c <botlish_fn_13+0x203>
    1164:	mov    edx,0x3
    1169:	mov    rsi,QWORD PTR [rsp+0x50]
    116e:	mov    rdi,r15
    1171:	call   1176 <botlish_fn_13+0x1fd>
			1172: R_X86_64_PLT32	rt_int_add-0x4
    1176:	mov    rdx,rax
    1179:	mov    rax,r12
    117c:	mov    rbx,QWORD PTR [rsp+0x60]
    1181:	mov    r12,QWORD PTR [rsp+0x68]
    1186:	mov    r13,QWORD PTR [rsp+0x70]
    118b:	mov    r14,QWORD PTR [rsp+0x78]
    1190:	mov    r15,QWORD PTR [rsp+0x80]
    1198:	add    rsp,0x90
    119f:	mov    rsp,rbp
    11a2:	pop    rbp
    11a3:	ret
    11a4:	mov    rsi,QWORD PTR [rsp+0x50]
    11a9:	mov    edx,0x3
    11ae:	mov    rcx,rdx
    11b1:	mov    QWORD PTR [rsp+0x18],0x3
    11ba:	test   rsi,0x1
    11c1:	jne    11cf <botlish_fn_13+0x256>
    11c7:	mov    rdx,rcx
    11ca:	jmp    11e4 <botlish_fn_13+0x26b>
    11cf:	mov    rdx,rsi
    11d2:	add    rdx,0x2
    11d6:	seto   al
    11d9:	test   al,al
    11db:	je     11ef <botlish_fn_13+0x276>
    11e1:	mov    rdx,rcx
    11e4:	mov    rdi,r15
    11e7:	call   11ec <botlish_fn_13+0x273>
			11e8: R_X86_64_PLT32	rt_int_add-0x4
    11ec:	mov    rdx,rax
    11ef:	mov    QWORD PTR [rsp],rbx
    11f3:	mov    QWORD PTR [rsp+0x8],rdx
    11f8:	mov    rsi,QWORD PTR [rsp+0x40]
    11fd:	mov    QWORD PTR [rsp+0x10],rsi
    1202:	mov    r11,QWORD PTR [rsp+0x48]
    1207:	mov    QWORD PTR [rsp+0x18],r11
    120c:	mov    r12,r11
    120f:	mov    r13,rsi
    1212:	jmp    fcd <botlish_fn_13+0x54>

0000000000001217 <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    1217:	push   rbp
    1218:	mov    rbp,rsp
    121b:	ud2
    121d:	add    BYTE PTR [rax],al
	...

0000000000001220 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    1220:	push   rbp
    1221:	mov    rbp,rsp
    1224:	sub    rsp,0x60
    1228:	mov    QWORD PTR [rsp+0x30],rbx
    122d:	mov    QWORD PTR [rsp+0x38],r12
    1232:	mov    QWORD PTR [rsp+0x40],r13
    1237:	mov    QWORD PTR [rsp+0x48],r14
    123c:	mov    QWORD PTR [rsp+0x50],r15
    1241:	mov    r13,rdi
    1244:	mov    QWORD PTR [rsp+0x20],0x0
    124d:	mov    QWORD PTR [rsp+0x28],0x0
    1256:	mov    QWORD PTR [rsp],rsi
    125a:	mov    QWORD PTR [rsp+0x8],rdx
    125f:	mov    r12,rdx
    1262:	mov    QWORD PTR [rsp+0x10],rcx
    1267:	mov    QWORD PTR [rsp+0x18],r8
    126c:	mov    rbx,rsi
    126f:	mov    r14,r8
    1272:	mov    r15,rcx
    1275:	mov    rsi,rbx
    1278:	mov    rdi,r13
    127b:	call   1280 <botlish_fn_14+0x60>
			127c: R_X86_64_PLT32	rt_str_len-0x4
    1280:	mov    rcx,r12
    1283:	and    rcx,rax
    1286:	mov    rdx,rax
    1289:	test   rcx,0x1
    1290:	jne    12b6 <botlish_fn_14+0x96>
    1296:	mov    rsi,r12
    1299:	mov    rdi,r13
    129c:	call   12a1 <botlish_fn_14+0x81>
			129d: R_X86_64_PLT32	rt_int_cmp-0x4
    12a1:	mov    ecx,0x2
    12a6:	test   rax,rax
    12a9:	cmovge rcx,QWORD PTR [rip+0x107]        # 13b8 <botlish_fn_14+0x198>
    12b1:	jmp    12c9 <botlish_fn_14+0xa9>
    12b6:	mov    ecx,0x2
    12bb:	mov    rax,r12
    12be:	cmp    rax,rdx
    12c1:	cmovge rcx,QWORD PTR [rip+0xef]        # 13b8 <botlish_fn_14+0x198>
    12c9:	cmp    rcx,0x6
    12cd:	je     1353 <botlish_fn_14+0x133>
    12d3:	mov    rdi,r13
    12d6:	call   12db <botlish_fn_14+0xbb>
			12d7: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    12db:	test   rax,rax
    12de:	je     136a <botlish_fn_14+0x14a>
    12e4:	mov    QWORD PTR [rsp+0x20],rax
    12e9:	mov    rcx,rax
    12ec:	mov    QWORD PTR [rsp+0x28],rdx
    12f1:	mov    r8,rdx
    12f4:	mov    rdx,r12
    12f7:	mov    rsi,rbx
    12fa:	mov    rdi,r13
    12fd:	call   1302 <botlish_fn_14+0xe2>
			12fe: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    1302:	test   rax,rax
    1305:	je     136a <botlish_fn_14+0x14a>
    130b:	mov    QWORD PTR [rsp+0x8],rax
    1310:	mov    rcx,rax
    1313:	mov    QWORD PTR [rsp+0x20],rdx
    1318:	mov    r12,rdx
    131b:	mov    rsi,r15
    131e:	mov    rdx,r14
    1321:	mov    rdi,r13
    1324:	call   1329 <botlish_fn_14+0x109>
			1325: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1329:	test   rax,rax
    132c:	je     136a <botlish_fn_14+0x14a>
    1332:	mov    QWORD PTR [rsp],rbx
    1336:	mov    rcx,r12
    1339:	mov    QWORD PTR [rsp+0x8],rcx
    133e:	mov    QWORD PTR [rsp+0x10],rax
    1343:	mov    QWORD PTR [rsp+0x18],rdx
    1348:	mov    r14,rdx
    134b:	mov    r15,rax
    134e:	jmp    1275 <botlish_fn_14+0x55>
    1353:	mov    rdx,r14
    1356:	mov    rsi,r15
    1359:	mov    rdi,r13
    135c:	call   1361 <botlish_fn_14+0x141>
			135d: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1361:	test   rax,rax
    1364:	jne    138f <botlish_fn_14+0x16f>
    136a:	xor    rax,rax
    136d:	mov    rbx,QWORD PTR [rsp+0x30]
    1372:	mov    r12,QWORD PTR [rsp+0x38]
    1377:	mov    r13,QWORD PTR [rsp+0x40]
    137c:	mov    r14,QWORD PTR [rsp+0x48]
    1381:	mov    r15,QWORD PTR [rsp+0x50]
    1386:	add    rsp,0x60
    138a:	mov    rsp,rbp
    138d:	pop    rbp
    138e:	ret
    138f:	mov    rbx,QWORD PTR [rsp+0x30]
    1394:	mov    r12,QWORD PTR [rsp+0x38]
    1399:	mov    r13,QWORD PTR [rsp+0x40]
    139e:	mov    r14,QWORD PTR [rsp+0x48]
    13a3:	mov    r15,QWORD PTR [rsp+0x50]
    13a8:	add    rsp,0x60
    13ac:	mov    rsp,rbp
    13af:	pop    rbp
    13b0:	ret
    13b1:	add    BYTE PTR [rax],al
    13b3:	add    BYTE PTR [rax],al
    13b5:	add    BYTE PTR [rax],al
    13b7:	add    BYTE PTR [rsi],al
    13b9:	add    BYTE PTR [rax],al
    13bb:	add    BYTE PTR [rax],al
    13bd:	add    BYTE PTR [rax],al
	...

00000000000013c0 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    13c0:	push   rbp
    13c1:	mov    rbp,rsp
    13c4:	mov    rsi,QWORD PTR [rdx]
    13c7:	mov    r9,QWORD PTR [rdx+0x8]
    13cb:	mov    rcx,QWORD PTR [rdx+0x10]
    13cf:	mov    r8,QWORD PTR [rdx+0x18]
    13d3:	mov    rdx,r9
    13d6:	call   13db <botlish_entry_14+0x1b>
			13d7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    13db:	mov    rsp,rbp
    13de:	pop    rbp
    13df:	ret

00000000000013e0 <botlish_fn_15: csv_parse<str>>:
    13e0:	push   rbp
    13e1:	mov    rbp,rsp
    13e4:	sub    rsp,0x30
    13e8:	mov    QWORD PTR [rsp+0x20],r12
    13ed:	mov    QWORD PTR [rsp+0x28],r13
    13f2:	mov    r13,rdi
    13f5:	mov    QWORD PTR [rsp+0x10],0x0
    13fe:	mov    QWORD PTR [rsp+0x18],0x0
    1407:	mov    QWORD PTR [rsp],rsi
    140b:	mov    r12,rsi
    140e:	mov    QWORD PTR [rsp+0x8],0x1
    1417:	mov    rdi,r13
    141a:	call   141f <botlish_fn_15+0x3f>
			141b: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    141f:	test   rax,rax
    1422:	je     1451 <botlish_fn_15+0x71>
    1428:	mov    QWORD PTR [rsp+0x10],rax
    142d:	mov    rcx,rax
    1430:	mov    QWORD PTR [rsp+0x18],rdx
    1435:	mov    r8,rdx
    1438:	mov    edx,0x1
    143d:	mov    rsi,r12
    1440:	mov    rdi,r13
    1443:	call   1448 <botlish_fn_15+0x68>
			1444: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1448:	test   rax,rax
    144b:	jne    1467 <botlish_fn_15+0x87>
    1451:	xor    rax,rax
    1454:	mov    r12,QWORD PTR [rsp+0x20]
    1459:	mov    r13,QWORD PTR [rsp+0x28]
    145e:	add    rsp,0x30
    1462:	mov    rsp,rbp
    1465:	pop    rbp
    1466:	ret
    1467:	mov    r12,QWORD PTR [rsp+0x20]
    146c:	mov    r13,QWORD PTR [rsp+0x28]
    1471:	add    rsp,0x30
    1475:	mov    rsp,rbp
    1478:	pop    rbp
    1479:	ret

000000000000147a <botlish_entry_15: csv_parse<str>>:
    147a:	push   rbp
    147b:	mov    rbp,rsp
    147e:	mov    rsi,QWORD PTR [rdx]
    1481:	call   1486 <botlish_entry_15+0xc>
			1482: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    1486:	mov    rsp,rbp
    1489:	pop    rbp
    148a:	ret

000000000000148b <botlish_fn_16: ht_min_capacity<generic>>:
    148b:	push   rbp
    148c:	mov    rbp,rsp
    148f:	mov    eax,0x11
    1494:	mov    rsp,rbp
    1497:	pop    rbp
    1498:	ret

0000000000001499 <botlish_entry_16: ht_min_capacity<generic>>:
    1499:	push   rbp
    149a:	mov    rbp,rsp
    149d:	call   14a2 <botlish_entry_16+0x9>
			149e: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    14a2:	mov    rsp,rbp
    14a5:	pop    rbp
    14a6:	ret

00000000000014a7 <botlish_fn_17: ht_empty_state<generic>>:
    14a7:	push   rbp
    14a8:	mov    rbp,rsp
    14ab:	mov    eax,0x1
    14b0:	mov    rsp,rbp
    14b3:	pop    rbp
    14b4:	ret

00000000000014b5 <botlish_entry_17: ht_empty_state<generic>>:
    14b5:	push   rbp
    14b6:	mov    rbp,rsp
    14b9:	call   14be <botlish_entry_17+0x9>
			14ba: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    14be:	mov    rsp,rbp
    14c1:	pop    rbp
    14c2:	ret

00000000000014c3 <botlish_fn_18: ht_occupied_state<generic>>:
    14c3:	push   rbp
    14c4:	mov    rbp,rsp
    14c7:	mov    eax,0x3
    14cc:	mov    rsp,rbp
    14cf:	pop    rbp
    14d0:	ret

00000000000014d1 <botlish_entry_18: ht_occupied_state<generic>>:
    14d1:	push   rbp
    14d2:	mov    rbp,rsp
    14d5:	call   14da <botlish_entry_18+0x9>
			14d6: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    14da:	mov    rsp,rbp
    14dd:	pop    rbp
    14de:	ret

00000000000014df <botlish_fn_19: ht_tombstone_state<generic>>:
    14df:	push   rbp
    14e0:	mov    rbp,rsp
    14e3:	mov    eax,0x5
    14e8:	mov    rsp,rbp
    14eb:	pop    rbp
    14ec:	ret

00000000000014ed <botlish_entry_19: ht_tombstone_state<generic>>:
    14ed:	push   rbp
    14ee:	mov    rbp,rsp
    14f1:	call   14f6 <botlish_entry_19+0x9>
			14f2: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    14f6:	mov    rsp,rbp
    14f9:	pop    rbp
    14fa:	ret
    14fb:	add    BYTE PTR [rax],al
    14fd:	add    BYTE PTR [rax],al
	...

0000000000001500 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    1500:	push   rbp
    1501:	mov    rbp,rsp
    1504:	sub    rsp,0x40
    1508:	mov    QWORD PTR [rsp+0x20],rbx
    150d:	mov    QWORD PTR [rsp+0x28],r12
    1512:	mov    QWORD PTR [rsp+0x30],r13
    1517:	mov    QWORD PTR [rsp+0x38],r14
    151c:	mov    r13,rdi
    151f:	mov    QWORD PTR [rsp],rsi
    1523:	mov    rbx,rsi
    1526:	mov    QWORD PTR [rsp+0x8],rdx
    152b:	mov    QWORD PTR [rsp+0x10],rcx
    1530:	mov    r12,rcx
    1533:	mov    rsi,rdx
    1536:	mov    rax,rsi
    1539:	and    rax,r12
    153c:	mov    r14,rsi
    153f:	test   rax,0x1
    1545:	jne    156e <botlish_fn_20+0x6e>
    154b:	mov    rdx,r12
    154e:	mov    rsi,r14
    1551:	mov    rdi,r13
    1554:	call   1559 <botlish_fn_20+0x59>
			1555: R_X86_64_PLT32	rt_int_cmp-0x4
    1559:	mov    ecx,0x2
    155e:	test   rax,rax
    1561:	cmovge rcx,QWORD PTR [rip+0xe7]        # 1650 <botlish_fn_20+0x150>
    1569:	jmp    1581 <botlish_fn_20+0x81>
    156e:	mov    ecx,0x2
    1573:	mov    rsi,r14
    1576:	cmp    rsi,r12
    1579:	cmovge rcx,QWORD PTR [rip+0xcf]        # 1650 <botlish_fn_20+0x150>
    1581:	cmp    rcx,0x6
    1585:	je     162e <botlish_fn_20+0x12e>
    158b:	mov    rdi,r13
    158e:	call   1593 <botlish_fn_20+0x93>
			158f: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1593:	mov    ecx,0x1
    1598:	mov    rdx,r14
    159b:	mov    rsi,rbx
    159e:	mov    rdi,r13
    15a1:	call   15a6 <botlish_fn_20+0xa6>
			15a2: R_X86_64_PLT32	rt_mutarray_set-0x4
    15a6:	test   rax,rax
    15a9:	jne    15cf <botlish_fn_20+0xcf>
    15af:	xor    rax,rax
    15b2:	mov    rbx,QWORD PTR [rsp+0x20]
    15b7:	mov    r12,QWORD PTR [rsp+0x28]
    15bc:	mov    r13,QWORD PTR [rsp+0x30]
    15c1:	mov    r14,QWORD PTR [rsp+0x38]
    15c6:	add    rsp,0x40
    15ca:	mov    rsp,rbp
    15cd:	pop    rbp
    15ce:	ret
    15cf:	mov    QWORD PTR [rsp+0x18],0x3
    15d8:	mov    rsi,r14
    15db:	test   rsi,0x1
    15e2:	je     1605 <botlish_fn_20+0x105>
    15e8:	mov    rsi,r14
    15eb:	mov    rcx,rsi
    15ee:	add    rcx,0x2
    15f2:	seto   al
    15f5:	test   al,al
    15f7:	jne    1605 <botlish_fn_20+0x105>
    15fd:	mov    r14,rcx
    1600:	jmp    1618 <botlish_fn_20+0x118>
    1605:	mov    edx,0x3
    160a:	mov    rsi,r14
    160d:	mov    rdi,r13
    1610:	call   1615 <botlish_fn_20+0x115>
			1611: R_X86_64_PLT32	rt_int_add-0x4
    1615:	mov    r14,rax
    1618:	mov    QWORD PTR [rsp],rbx
    161c:	mov    rsi,r14
    161f:	mov    QWORD PTR [rsp+0x8],rsi
    1624:	mov    QWORD PTR [rsp+0x10],r12
    1629:	jmp    1536 <botlish_fn_20+0x36>
    162e:	mov    eax,0xa
    1633:	mov    rbx,QWORD PTR [rsp+0x20]
    1638:	mov    r12,QWORD PTR [rsp+0x28]
    163d:	mov    r13,QWORD PTR [rsp+0x30]
    1642:	mov    r14,QWORD PTR [rsp+0x38]
    1647:	add    rsp,0x40
    164b:	mov    rsp,rbp
    164e:	pop    rbp
    164f:	ret
    1650:	(bad)
    1651:	add    BYTE PTR [rax],al
    1653:	add    BYTE PTR [rax],al
    1655:	add    BYTE PTR [rax],al
	...

0000000000001658 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    1658:	push   rbp
    1659:	mov    rbp,rsp
    165c:	mov    rsi,QWORD PTR [rdx]
    165f:	mov    r8,QWORD PTR [rdx+0x8]
    1663:	mov    rcx,QWORD PTR [rdx+0x10]
    1667:	mov    rdx,r8
    166a:	call   166f <botlish_entry_20+0x17>
			166b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    166f:	mov    rsp,rbp
    1672:	pop    rbp
    1673:	ret

0000000000001674 <botlish_fn_21: ht_alloc<int>>:
    1674:	push   rbp
    1675:	mov    rbp,rsp
    1678:	sub    rsp,0x50
    167c:	mov    QWORD PTR [rsp+0x20],rbx
    1681:	mov    QWORD PTR [rsp+0x28],r12
    1686:	mov    QWORD PTR [rsp+0x30],r13
    168b:	mov    QWORD PTR [rsp+0x38],r14
    1690:	mov    QWORD PTR [rsp+0x40],r15
    1695:	mov    rbx,rdi
    1698:	mov    QWORD PTR [rsp+0x8],0x0
    16a1:	mov    QWORD PTR [rsp+0x10],0x0
    16aa:	mov    QWORD PTR [rsp+0x18],0x0
    16b3:	mov    QWORD PTR [rsp],rsi
    16b7:	mov    r13,rsi
    16ba:	mov    rsi,r13
    16bd:	mov    rdi,rbx
    16c0:	call   16c5 <botlish_fn_21+0x51>
			16c1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    16c5:	test   rax,rax
    16c8:	je     17e4 <botlish_fn_21+0x170>
    16ce:	mov    QWORD PTR [rsp+0x8],rax
    16d3:	mov    r12,rax
    16d6:	mov    edx,0x1
    16db:	mov    QWORD PTR [rsp+0x10],0x1
    16e4:	mov    rcx,r13
    16e7:	mov    rsi,r12
    16ea:	mov    rdi,rbx
    16ed:	call   16f2 <botlish_fn_21+0x7e>
			16ee: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    16f2:	test   rax,rax
    16f5:	je     17e4 <botlish_fn_21+0x170>
    16fb:	mov    rsi,r13
    16fe:	mov    rdi,rbx
    1701:	call   1706 <botlish_fn_21+0x92>
			1702: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1706:	test   rax,rax
    1709:	je     17e4 <botlish_fn_21+0x170>
    170f:	mov    QWORD PTR [rsp+0x10],rax
    1714:	mov    rsi,r13
    1717:	mov    r14,rax
    171a:	mov    rdi,rbx
    171d:	call   1722 <botlish_fn_21+0xae>
			171e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1722:	test   rax,rax
    1725:	je     17e4 <botlish_fn_21+0x170>
    172b:	mov    QWORD PTR [rsp],rax
    172f:	mov    r13,rax
    1732:	mov    esi,0xb
    1737:	mov    QWORD PTR [rsp+0x18],0xb
    1740:	mov    rdi,rbx
    1743:	call   1748 <botlish_fn_21+0xd4>
			1744: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1748:	test   rax,rax
    174b:	mov    r15,rax
    174e:	je     17e4 <botlish_fn_21+0x170>
    1754:	mov    edx,0x1
    1759:	mov    rcx,r12
    175c:	mov    rsi,r15
    175f:	mov    rdi,rbx
    1762:	call   1767 <botlish_fn_21+0xf3>
			1763: R_X86_64_PLT32	rt_mutarray_set-0x4
    1767:	test   rax,rax
    176a:	je     17e4 <botlish_fn_21+0x170>
    1770:	mov    edx,0x3
    1775:	mov    rcx,r14
    1778:	mov    rsi,r15
    177b:	mov    rdi,rbx
    177e:	call   1783 <botlish_fn_21+0x10f>
			177f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1783:	test   rax,rax
    1786:	je     17e4 <botlish_fn_21+0x170>
    178c:	mov    edx,0x5
    1791:	mov    rcx,r13
    1794:	mov    rsi,r15
    1797:	mov    rdi,rbx
    179a:	call   179f <botlish_fn_21+0x12b>
			179b: R_X86_64_PLT32	rt_mutarray_set-0x4
    179f:	test   rax,rax
    17a2:	je     17e4 <botlish_fn_21+0x170>
    17a8:	mov    edx,0x7
    17ad:	mov    ecx,0x1
    17b2:	mov    rsi,r15
    17b5:	mov    rdi,rbx
    17b8:	call   17bd <botlish_fn_21+0x149>
			17b9: R_X86_64_PLT32	rt_mutarray_set-0x4
    17bd:	test   rax,rax
    17c0:	je     17e4 <botlish_fn_21+0x170>
    17c6:	mov    edx,0x9
    17cb:	mov    ecx,0x1
    17d0:	mov    rdi,rbx
    17d3:	mov    rsi,r15
    17d6:	call   17db <botlish_fn_21+0x167>
			17d7: R_X86_64_PLT32	rt_mutarray_set-0x4
    17db:	test   rax,rax
    17de:	jne    1809 <botlish_fn_21+0x195>
    17e4:	xor    rax,rax
    17e7:	mov    rbx,QWORD PTR [rsp+0x20]
    17ec:	mov    r12,QWORD PTR [rsp+0x28]
    17f1:	mov    r13,QWORD PTR [rsp+0x30]
    17f6:	mov    r14,QWORD PTR [rsp+0x38]
    17fb:	mov    r15,QWORD PTR [rsp+0x40]
    1800:	add    rsp,0x50
    1804:	mov    rsp,rbp
    1807:	pop    rbp
    1808:	ret
    1809:	mov    rax,r15
    180c:	mov    rbx,QWORD PTR [rsp+0x20]
    1811:	mov    r12,QWORD PTR [rsp+0x28]
    1816:	mov    r13,QWORD PTR [rsp+0x30]
    181b:	mov    r14,QWORD PTR [rsp+0x38]
    1820:	mov    r15,QWORD PTR [rsp+0x40]
    1825:	add    rsp,0x50
    1829:	mov    rsp,rbp
    182c:	pop    rbp
    182d:	ret

000000000000182e <botlish_entry_21: ht_alloc<int>>:
    182e:	push   rbp
    182f:	mov    rbp,rsp
    1832:	mov    rsi,QWORD PTR [rdx]
    1835:	call   183a <botlish_entry_21+0xc>
			1836: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    183a:	mov    rsp,rbp
    183d:	pop    rbp
    183e:	ret

000000000000183f <botlish_fn_22: ht_new<generic>>:
    183f:	push   rbp
    1840:	mov    rbp,rsp
    1843:	sub    rsp,0x20
    1847:	mov    QWORD PTR [rsp+0x10],r12
    184c:	mov    r12,rdi
    184f:	mov    rdi,r12
    1852:	call   1857 <botlish_fn_22+0x18>
			1853: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1857:	mov    esi,0x11
    185c:	mov    QWORD PTR [rsp],0x11
    1864:	mov    rdi,r12
    1867:	call   186c <botlish_fn_22+0x2d>
			1868: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    186c:	test   rax,rax
    186f:	jne    1886 <botlish_fn_22+0x47>
    1875:	xor    rax,rax
    1878:	mov    r12,QWORD PTR [rsp+0x10]
    187d:	add    rsp,0x20
    1881:	mov    rsp,rbp
    1884:	pop    rbp
    1885:	ret
    1886:	mov    r12,QWORD PTR [rsp+0x10]
    188b:	add    rsp,0x20
    188f:	mov    rsp,rbp
    1892:	pop    rbp
    1893:	ret

0000000000001894 <botlish_entry_22: ht_new<generic>>:
    1894:	push   rbp
    1895:	mov    rbp,rsp
    1898:	call   189d <botlish_entry_22+0x9>
			1899: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    189d:	mov    rsp,rbp
    18a0:	pop    rbp
    18a1:	ret
    18a2:	add    BYTE PTR [rax],al
    18a4:	add    BYTE PTR [rax],al
	...

00000000000018a8 <botlish_fn_23: ht_capacity_for<int, int>>:
    18a8:	push   rbp
    18a9:	mov    rbp,rsp
    18ac:	sub    rsp,0x50
    18b0:	mov    QWORD PTR [rsp+0x20],rbx
    18b5:	mov    QWORD PTR [rsp+0x28],r12
    18ba:	mov    QWORD PTR [rsp+0x30],r13
    18bf:	mov    QWORD PTR [rsp+0x38],r14
    18c4:	mov    QWORD PTR [rsp+0x40],r15
    18c9:	mov    r13,rdi
    18cc:	mov    QWORD PTR [rsp],rdx
    18d0:	mov    rbx,rsi
    18d3:	or     rbx,0x1
    18d7:	sar    rbx,1
    18da:	mov    r12,rsi
    18dd:	mov    r14,rdx
    18e0:	mov    rax,r12
    18e3:	or     rax,0x1
    18e7:	mov    QWORD PTR [rsp+0x8],rax
    18ec:	mov    QWORD PTR [rsp+0x10],0x7
    18f5:	mov    rax,rbx
    18f8:	imul   QWORD PTR [rip+0x159]        # 1a58 <botlish_fn_23+0x1b0>
    18ff:	seto   cl
    1902:	or     rax,0x1
    1906:	test   cl,cl
    1908:	jne    1916 <botlish_fn_23+0x6e>
    190e:	mov    rsi,rax
    1911:	jmp    192d <botlish_fn_23+0x85>
    1916:	mov    rsi,r12
    1919:	or     rsi,0x1
    191d:	mov    edx,0x7
    1922:	mov    rdi,r13
    1925:	call   192a <botlish_fn_23+0x82>
			1926: R_X86_64_PLT32	rt_int_mul-0x4
    192a:	mov    rsi,rax
    192d:	mov    QWORD PTR [rsp+0x8],rsi
    1932:	mov    r15,rsi
    1935:	mov    QWORD PTR [rsp+0x10],0x5
    193e:	mov    rsi,r14
    1941:	test   rsi,0x1
    1948:	je     1978 <botlish_fn_23+0xd0>
    194e:	mov    rsi,r14
    1951:	mov    rax,rsi
    1954:	sar    rax,1
    1957:	imul   QWORD PTR [rip+0x102]        # 1a60 <botlish_fn_23+0x1b8>
    195e:	seto   cl
    1961:	or     rax,0x1
    1965:	test   cl,cl
    1967:	jne    1978 <botlish_fn_23+0xd0>
    196d:	mov    rdx,rax
    1970:	mov    rsi,r15
    1973:	jmp    198e <botlish_fn_23+0xe6>
    1978:	mov    edx,0x5
    197d:	mov    rsi,r14
    1980:	mov    rdi,r13
    1983:	call   1988 <botlish_fn_23+0xe0>
			1984: R_X86_64_PLT32	rt_int_mul-0x4
    1988:	mov    rdx,rax
    198b:	mov    rsi,r15
    198e:	mov    rax,rsi
    1991:	and    rax,rdx
    1994:	test   rax,0x1
    199a:	jne    19bd <botlish_fn_23+0x115>
    19a0:	mov    rdi,r13
    19a3:	call   19a8 <botlish_fn_23+0x100>
			19a4: R_X86_64_PLT32	rt_int_cmp-0x4
    19a8:	mov    ecx,0x2
    19ad:	test   rax,rax
    19b0:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1a58 <botlish_fn_23+0x1b0>
    19b8:	jmp    19cd <botlish_fn_23+0x125>
    19bd:	mov    ecx,0x2
    19c2:	cmp    rsi,rdx
    19c5:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1a58 <botlish_fn_23+0x1b0>
    19cd:	cmp    rcx,0x6
    19d1:	je     1a2d <botlish_fn_23+0x185>
    19d7:	mov    QWORD PTR [rsp+0x8],0x5
    19e0:	mov    rsi,r14
    19e3:	test   rsi,0x1
    19ea:	je     1a11 <botlish_fn_23+0x169>
    19f0:	mov    rsi,r14
    19f3:	mov    rax,rsi
    19f6:	sar    rax,1
    19f9:	imul   QWORD PTR [rip+0x60]        # 1a60 <botlish_fn_23+0x1b8>
    1a00:	seto   sil
    1a04:	or     rax,0x1
    1a08:	test   sil,sil
    1a0b:	je     1a21 <botlish_fn_23+0x179>
    1a11:	mov    edx,0x5
    1a16:	mov    rsi,r14
    1a19:	mov    rdi,r13
    1a1c:	call   1a21 <botlish_fn_23+0x179>
			1a1d: R_X86_64_PLT32	rt_int_mul-0x4
    1a21:	mov    QWORD PTR [rsp],rax
    1a25:	mov    r14,rax
    1a28:	jmp    18e0 <botlish_fn_23+0x38>
    1a2d:	mov    rax,r14
    1a30:	mov    rbx,QWORD PTR [rsp+0x20]
    1a35:	mov    r12,QWORD PTR [rsp+0x28]
    1a3a:	mov    r13,QWORD PTR [rsp+0x30]
    1a3f:	mov    r14,QWORD PTR [rsp+0x38]
    1a44:	mov    r15,QWORD PTR [rsp+0x40]
    1a49:	add    rsp,0x50
    1a4d:	mov    rsp,rbp
    1a50:	pop    rbp
    1a51:	ret
    1a52:	add    BYTE PTR [rax],al
    1a54:	add    BYTE PTR [rax],al
    1a56:	add    BYTE PTR [rax],al
    1a58:	(bad)
    1a59:	add    BYTE PTR [rax],al
    1a5b:	add    BYTE PTR [rax],al
    1a5d:	add    BYTE PTR [rax],al
    1a5f:	add    BYTE PTR [rax+rax*1],al
    1a62:	add    BYTE PTR [rax],al
    1a64:	add    BYTE PTR [rax],al
	...

0000000000001a68 <botlish_entry_23: ht_capacity_for<int, int>>:
    1a68:	push   rbp
    1a69:	mov    rbp,rsp
    1a6c:	mov    rsi,QWORD PTR [rdx]
    1a6f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a73:	call   1a78 <botlish_entry_23+0x10>
			1a74: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    1a78:	mov    rsp,rbp
    1a7b:	pop    rbp
    1a7c:	ret

0000000000001a7d <botlish_fn_24: ht_new_sized<int>>:
    1a7d:	push   rbp
    1a7e:	mov    rbp,rsp
    1a81:	sub    rsp,0x20
    1a85:	mov    QWORD PTR [rsp+0x10],r12
    1a8a:	mov    QWORD PTR [rsp+0x18],r13
    1a8f:	mov    r12,rdi
    1a92:	mov    QWORD PTR [rsp],rsi
    1a96:	mov    r13,rsi
    1a99:	mov    rdi,r12
    1a9c:	call   1aa1 <botlish_fn_24+0x24>
			1a9d: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1aa1:	mov    edx,0x11
    1aa6:	mov    QWORD PTR [rsp+0x8],0x11
    1aaf:	mov    rsi,r13
    1ab2:	mov    rdi,r12
    1ab5:	call   1aba <botlish_fn_24+0x3d>
			1ab6: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    1aba:	mov    QWORD PTR [rsp],rax
    1abe:	mov    rsi,rax
    1ac1:	mov    rdi,r12
    1ac4:	call   1ac9 <botlish_fn_24+0x4c>
			1ac5: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1ac9:	test   rax,rax
    1acc:	jne    1ae8 <botlish_fn_24+0x6b>
    1ad2:	xor    rax,rax
    1ad5:	mov    r12,QWORD PTR [rsp+0x10]
    1ada:	mov    r13,QWORD PTR [rsp+0x18]
    1adf:	add    rsp,0x20
    1ae3:	mov    rsp,rbp
    1ae6:	pop    rbp
    1ae7:	ret
    1ae8:	mov    r12,QWORD PTR [rsp+0x10]
    1aed:	mov    r13,QWORD PTR [rsp+0x18]
    1af2:	add    rsp,0x20
    1af6:	mov    rsp,rbp
    1af9:	pop    rbp
    1afa:	ret

0000000000001afb <botlish_entry_24: ht_new_sized<int>>:
    1afb:	push   rbp
    1afc:	mov    rbp,rsp
    1aff:	mov    rsi,QWORD PTR [rdx]
    1b02:	call   1b07 <botlish_entry_24+0xc>
			1b03: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    1b07:	mov    rsp,rbp
    1b0a:	pop    rbp
    1b0b:	ret

0000000000001b0c <botlish_fn_25: ht_controls<mutarray>>:
    1b0c:	push   rbp
    1b0d:	mov    rbp,rsp
    1b10:	mov    edx,0x1
    1b15:	call   1b1a <botlish_fn_25+0xe>
			1b16: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b1a:	test   rax,rax
    1b1d:	jne    1b2b <botlish_fn_25+0x1f>
    1b23:	xor    rax,rax
    1b26:	mov    rsp,rbp
    1b29:	pop    rbp
    1b2a:	ret
    1b2b:	mov    rsp,rbp
    1b2e:	pop    rbp
    1b2f:	ret

0000000000001b30 <botlish_entry_25: ht_controls<mutarray>>:
    1b30:	push   rbp
    1b31:	mov    rbp,rsp
    1b34:	mov    rsi,QWORD PTR [rdx]
    1b37:	call   1b3c <botlish_entry_25+0xc>
			1b38: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    1b3c:	mov    rsp,rbp
    1b3f:	pop    rbp
    1b40:	ret

0000000000001b41 <botlish_fn_26: ht_controls<generic>>:
    1b41:	push   rbp
    1b42:	mov    rbp,rsp
    1b45:	xor    r8d,r8d
    1b48:	test   rsi,0x7
    1b4f:	jne    1b5f <botlish_fn_26+0x1e>
    1b55:	movzx  rax,BYTE PTR [rsi]
    1b59:	cmp    al,0x8
    1b5b:	sete   r8b
    1b5f:	test   r8b,r8b
    1b62:	jne    1b7f <botlish_fn_26+0x3e>
    1b68:	mov    rax,QWORD PTR [rdi+0x10]
    1b6c:	mov    rcx,QWORD PTR [rax+0x20]
    1b70:	mov    edx,0x8
    1b75:	call   1b7a <botlish_fn_26+0x39>
			1b76: R_X86_64_PLT32	rt_type_error-0x4
    1b7a:	jmp    1b92 <botlish_fn_26+0x51>
    1b7f:	mov    edx,0x1
    1b84:	call   1b89 <botlish_fn_26+0x48>
			1b85: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b89:	test   rax,rax
    1b8c:	jne    1b9a <botlish_fn_26+0x59>
    1b92:	xor    rax,rax
    1b95:	mov    rsp,rbp
    1b98:	pop    rbp
    1b99:	ret
    1b9a:	mov    rsp,rbp
    1b9d:	pop    rbp
    1b9e:	ret

0000000000001b9f <botlish_entry_26: ht_controls<generic>>:
    1b9f:	push   rbp
    1ba0:	mov    rbp,rsp
    1ba3:	mov    rsi,QWORD PTR [rdx]
    1ba6:	call   1bab <botlish_entry_26+0xc>
			1ba7: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    1bab:	mov    rsp,rbp
    1bae:	pop    rbp
    1baf:	ret

0000000000001bb0 <botlish_fn_27: ht_keys<mutarray>>:
    1bb0:	push   rbp
    1bb1:	mov    rbp,rsp
    1bb4:	mov    edx,0x3
    1bb9:	call   1bbe <botlish_fn_27+0xe>
			1bba: R_X86_64_PLT32	rt_mutarray_get-0x4
    1bbe:	test   rax,rax
    1bc1:	jne    1bcf <botlish_fn_27+0x1f>
    1bc7:	xor    rax,rax
    1bca:	mov    rsp,rbp
    1bcd:	pop    rbp
    1bce:	ret
    1bcf:	mov    rsp,rbp
    1bd2:	pop    rbp
    1bd3:	ret

0000000000001bd4 <botlish_entry_27: ht_keys<mutarray>>:
    1bd4:	push   rbp
    1bd5:	mov    rbp,rsp
    1bd8:	mov    rsi,QWORD PTR [rdx]
    1bdb:	call   1be0 <botlish_entry_27+0xc>
			1bdc: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    1be0:	mov    rsp,rbp
    1be3:	pop    rbp
    1be4:	ret

0000000000001be5 <botlish_fn_28: ht_keys<generic>>:
    1be5:	push   rbp
    1be6:	mov    rbp,rsp
    1be9:	xor    r8d,r8d
    1bec:	test   rsi,0x7
    1bf3:	jne    1c03 <botlish_fn_28+0x1e>
    1bf9:	movzx  rax,BYTE PTR [rsi]
    1bfd:	cmp    al,0x8
    1bff:	sete   r8b
    1c03:	test   r8b,r8b
    1c06:	jne    1c23 <botlish_fn_28+0x3e>
    1c0c:	mov    rax,QWORD PTR [rdi+0x10]
    1c10:	mov    rcx,QWORD PTR [rax+0x20]
    1c14:	mov    edx,0x8
    1c19:	call   1c1e <botlish_fn_28+0x39>
			1c1a: R_X86_64_PLT32	rt_type_error-0x4
    1c1e:	jmp    1c36 <botlish_fn_28+0x51>
    1c23:	mov    edx,0x3
    1c28:	call   1c2d <botlish_fn_28+0x48>
			1c29: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c2d:	test   rax,rax
    1c30:	jne    1c3e <botlish_fn_28+0x59>
    1c36:	xor    rax,rax
    1c39:	mov    rsp,rbp
    1c3c:	pop    rbp
    1c3d:	ret
    1c3e:	mov    rsp,rbp
    1c41:	pop    rbp
    1c42:	ret

0000000000001c43 <botlish_entry_28: ht_keys<generic>>:
    1c43:	push   rbp
    1c44:	mov    rbp,rsp
    1c47:	mov    rsi,QWORD PTR [rdx]
    1c4a:	call   1c4f <botlish_entry_28+0xc>
			1c4b: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    1c4f:	mov    rsp,rbp
    1c52:	pop    rbp
    1c53:	ret

0000000000001c54 <botlish_fn_29: ht_values<mutarray>>:
    1c54:	push   rbp
    1c55:	mov    rbp,rsp
    1c58:	mov    edx,0x5
    1c5d:	call   1c62 <botlish_fn_29+0xe>
			1c5e: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c62:	test   rax,rax
    1c65:	jne    1c73 <botlish_fn_29+0x1f>
    1c6b:	xor    rax,rax
    1c6e:	mov    rsp,rbp
    1c71:	pop    rbp
    1c72:	ret
    1c73:	mov    rsp,rbp
    1c76:	pop    rbp
    1c77:	ret

0000000000001c78 <botlish_entry_29: ht_values<mutarray>>:
    1c78:	push   rbp
    1c79:	mov    rbp,rsp
    1c7c:	mov    rsi,QWORD PTR [rdx]
    1c7f:	call   1c84 <botlish_entry_29+0xc>
			1c80: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    1c84:	mov    rsp,rbp
    1c87:	pop    rbp
    1c88:	ret

0000000000001c89 <botlish_fn_30: ht_values<generic>>:
    1c89:	push   rbp
    1c8a:	mov    rbp,rsp
    1c8d:	xor    r8d,r8d
    1c90:	test   rsi,0x7
    1c97:	jne    1ca7 <botlish_fn_30+0x1e>
    1c9d:	movzx  rax,BYTE PTR [rsi]
    1ca1:	cmp    al,0x8
    1ca3:	sete   r8b
    1ca7:	test   r8b,r8b
    1caa:	jne    1cc7 <botlish_fn_30+0x3e>
    1cb0:	mov    rax,QWORD PTR [rdi+0x10]
    1cb4:	mov    rcx,QWORD PTR [rax+0x20]
    1cb8:	mov    edx,0x8
    1cbd:	call   1cc2 <botlish_fn_30+0x39>
			1cbe: R_X86_64_PLT32	rt_type_error-0x4
    1cc2:	jmp    1cda <botlish_fn_30+0x51>
    1cc7:	mov    edx,0x5
    1ccc:	call   1cd1 <botlish_fn_30+0x48>
			1ccd: R_X86_64_PLT32	rt_mutarray_get-0x4
    1cd1:	test   rax,rax
    1cd4:	jne    1ce2 <botlish_fn_30+0x59>
    1cda:	xor    rax,rax
    1cdd:	mov    rsp,rbp
    1ce0:	pop    rbp
    1ce1:	ret
    1ce2:	mov    rsp,rbp
    1ce5:	pop    rbp
    1ce6:	ret

0000000000001ce7 <botlish_entry_30: ht_values<generic>>:
    1ce7:	push   rbp
    1ce8:	mov    rbp,rsp
    1ceb:	mov    rsi,QWORD PTR [rdx]
    1cee:	call   1cf3 <botlish_entry_30+0xc>
			1cef: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    1cf3:	mov    rsp,rbp
    1cf6:	pop    rbp
    1cf7:	ret

0000000000001cf8 <botlish_fn_31: ht_size<mutarray>>:
    1cf8:	push   rbp
    1cf9:	mov    rbp,rsp
    1cfc:	mov    edx,0x7
    1d01:	call   1d06 <botlish_fn_31+0xe>
			1d02: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d06:	test   rax,rax
    1d09:	jne    1d17 <botlish_fn_31+0x1f>
    1d0f:	xor    rax,rax
    1d12:	mov    rsp,rbp
    1d15:	pop    rbp
    1d16:	ret
    1d17:	mov    rsp,rbp
    1d1a:	pop    rbp
    1d1b:	ret

0000000000001d1c <botlish_entry_31: ht_size<mutarray>>:
    1d1c:	push   rbp
    1d1d:	mov    rbp,rsp
    1d20:	mov    rsi,QWORD PTR [rdx]
    1d23:	call   1d28 <botlish_entry_31+0xc>
			1d24: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    1d28:	mov    rsp,rbp
    1d2b:	pop    rbp
    1d2c:	ret

0000000000001d2d <botlish_fn_32: ht_size<generic>>:
    1d2d:	push   rbp
    1d2e:	mov    rbp,rsp
    1d31:	xor    r8d,r8d
    1d34:	test   rsi,0x7
    1d3b:	jne    1d4b <botlish_fn_32+0x1e>
    1d41:	movzx  rax,BYTE PTR [rsi]
    1d45:	cmp    al,0x8
    1d47:	sete   r8b
    1d4b:	test   r8b,r8b
    1d4e:	jne    1d6b <botlish_fn_32+0x3e>
    1d54:	mov    rax,QWORD PTR [rdi+0x10]
    1d58:	mov    rcx,QWORD PTR [rax+0x20]
    1d5c:	mov    edx,0x8
    1d61:	call   1d66 <botlish_fn_32+0x39>
			1d62: R_X86_64_PLT32	rt_type_error-0x4
    1d66:	jmp    1d7e <botlish_fn_32+0x51>
    1d6b:	mov    edx,0x7
    1d70:	call   1d75 <botlish_fn_32+0x48>
			1d71: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d75:	test   rax,rax
    1d78:	jne    1d86 <botlish_fn_32+0x59>
    1d7e:	xor    rax,rax
    1d81:	mov    rsp,rbp
    1d84:	pop    rbp
    1d85:	ret
    1d86:	mov    rsp,rbp
    1d89:	pop    rbp
    1d8a:	ret

0000000000001d8b <botlish_entry_32: ht_size<generic>>:
    1d8b:	push   rbp
    1d8c:	mov    rbp,rsp
    1d8f:	mov    rsi,QWORD PTR [rdx]
    1d92:	call   1d97 <botlish_entry_32+0xc>
			1d93: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    1d97:	mov    rsp,rbp
    1d9a:	pop    rbp
    1d9b:	ret

0000000000001d9c <botlish_fn_33: ht_tombstones<mutarray>>:
    1d9c:	push   rbp
    1d9d:	mov    rbp,rsp
    1da0:	mov    edx,0x9
    1da5:	call   1daa <botlish_fn_33+0xe>
			1da6: R_X86_64_PLT32	rt_mutarray_get-0x4
    1daa:	test   rax,rax
    1dad:	jne    1dbb <botlish_fn_33+0x1f>
    1db3:	xor    rax,rax
    1db6:	mov    rsp,rbp
    1db9:	pop    rbp
    1dba:	ret
    1dbb:	mov    rsp,rbp
    1dbe:	pop    rbp
    1dbf:	ret

0000000000001dc0 <botlish_entry_33: ht_tombstones<mutarray>>:
    1dc0:	push   rbp
    1dc1:	mov    rbp,rsp
    1dc4:	mov    rsi,QWORD PTR [rdx]
    1dc7:	call   1dcc <botlish_entry_33+0xc>
			1dc8: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    1dcc:	mov    rsp,rbp
    1dcf:	pop    rbp
    1dd0:	ret

0000000000001dd1 <botlish_fn_34: ht_capacity<mutarray>>:
    1dd1:	push   rbp
    1dd2:	mov    rbp,rsp
    1dd5:	sub    rsp,0x10
    1dd9:	mov    QWORD PTR [rsp],rbx
    1ddd:	mov    rbx,rdi
    1de0:	mov    rdi,rbx
    1de3:	call   1de8 <botlish_fn_34+0x17>
			1de4: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    1de8:	test   rax,rax
    1deb:	je     1e35 <botlish_fn_34+0x64>
    1df1:	xor    r8d,r8d
    1df4:	test   rax,0x7
    1dfa:	je     1e08 <botlish_fn_34+0x37>
    1e00:	mov    rsi,rax
    1e03:	jmp    1e17 <botlish_fn_34+0x46>
    1e08:	movzx  rcx,BYTE PTR [rax]
    1e0c:	mov    rsi,rax
    1e0f:	rex cmp cl,0x8
    1e13:	sete   r8b
    1e17:	test   r8b,r8b
    1e1a:	jne    1e45 <botlish_fn_34+0x74>
    1e20:	mov    rdi,rbx
    1e23:	mov    rax,QWORD PTR [rdi+0x10]
    1e27:	mov    rcx,QWORD PTR [rax+0x28]
    1e2b:	mov    edx,0x8
    1e30:	call   1e35 <botlish_fn_34+0x64>
			1e31: R_X86_64_PLT32	rt_type_error-0x4
    1e35:	xor    rax,rax
    1e38:	mov    rbx,QWORD PTR [rsp]
    1e3c:	add    rsp,0x10
    1e40:	mov    rsp,rbp
    1e43:	pop    rbp
    1e44:	ret
    1e45:	mov    rdi,rbx
    1e48:	call   1e4d <botlish_fn_34+0x7c>
			1e49: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1e4d:	mov    rbx,QWORD PTR [rsp]
    1e51:	add    rsp,0x10
    1e55:	mov    rsp,rbp
    1e58:	pop    rbp
    1e59:	ret

0000000000001e5a <botlish_entry_34: ht_capacity<mutarray>>:
    1e5a:	push   rbp
    1e5b:	mov    rbp,rsp
    1e5e:	mov    rsi,QWORD PTR [rdx]
    1e61:	call   1e66 <botlish_entry_34+0xc>
			1e62: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    1e66:	mov    rsp,rbp
    1e69:	pop    rbp
    1e6a:	ret

0000000000001e6b <botlish_fn_35: ht_capacity<generic>>:
    1e6b:	push   rbp
    1e6c:	mov    rbp,rsp
    1e6f:	sub    rsp,0x10
    1e73:	mov    QWORD PTR [rsp],rbx
    1e77:	mov    rbx,rdi
    1e7a:	mov    rdi,rbx
    1e7d:	call   1e82 <botlish_fn_35+0x17>
			1e7e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    1e82:	test   rax,rax
    1e85:	je     1ecf <botlish_fn_35+0x64>
    1e8b:	xor    r8d,r8d
    1e8e:	test   rax,0x7
    1e94:	je     1ea2 <botlish_fn_35+0x37>
    1e9a:	mov    rsi,rax
    1e9d:	jmp    1eb1 <botlish_fn_35+0x46>
    1ea2:	movzx  rcx,BYTE PTR [rax]
    1ea6:	mov    rsi,rax
    1ea9:	rex cmp cl,0x8
    1ead:	sete   r8b
    1eb1:	test   r8b,r8b
    1eb4:	jne    1edf <botlish_fn_35+0x74>
    1eba:	mov    rdi,rbx
    1ebd:	mov    rax,QWORD PTR [rdi+0x10]
    1ec1:	mov    rcx,QWORD PTR [rax+0x28]
    1ec5:	mov    edx,0x8
    1eca:	call   1ecf <botlish_fn_35+0x64>
			1ecb: R_X86_64_PLT32	rt_type_error-0x4
    1ecf:	xor    rax,rax
    1ed2:	mov    rbx,QWORD PTR [rsp]
    1ed6:	add    rsp,0x10
    1eda:	mov    rsp,rbp
    1edd:	pop    rbp
    1ede:	ret
    1edf:	mov    rdi,rbx
    1ee2:	call   1ee7 <botlish_fn_35+0x7c>
			1ee3: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1ee7:	mov    rbx,QWORD PTR [rsp]
    1eeb:	add    rsp,0x10
    1eef:	mov    rsp,rbp
    1ef2:	pop    rbp
    1ef3:	ret

0000000000001ef4 <botlish_entry_35: ht_capacity<generic>>:
    1ef4:	push   rbp
    1ef5:	mov    rbp,rsp
    1ef8:	mov    rsi,QWORD PTR [rdx]
    1efb:	call   1f00 <botlish_entry_35+0xc>
			1efc: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    1f00:	mov    rsp,rbp
    1f03:	pop    rbp
    1f04:	ret

0000000000001f05 <botlish_fn_36: ht_probe_start<mutarray, any>>:
    1f05:	push   rbp
    1f06:	mov    rbp,rsp
    1f09:	sub    rsp,0x20
    1f0d:	mov    QWORD PTR [rsp],r12
    1f11:	mov    QWORD PTR [rsp+0x8],r13
    1f16:	mov    QWORD PTR [rsp+0x10],r14
    1f1b:	mov    r12,rdi
    1f1e:	mov    r14,rsi
    1f21:	mov    rsi,rdx
    1f24:	mov    rdi,r12
    1f27:	call   1f2c <botlish_fn_36+0x27>
			1f28: R_X86_64_PLT32	rt_hash-0x4
    1f2c:	test   rax,rax
    1f2f:	mov    r13,rax
    1f32:	je     1f63 <botlish_fn_36+0x5e>
    1f38:	mov    rsi,r14
    1f3b:	mov    rdi,r12
    1f3e:	call   1f43 <botlish_fn_36+0x3e>
			1f3f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    1f43:	test   rax,rax
    1f46:	mov    rdx,rax
    1f49:	je     1f63 <botlish_fn_36+0x5e>
    1f4f:	mov    rsi,r13
    1f52:	mov    rdi,r12
    1f55:	call   1f5a <botlish_fn_36+0x55>
			1f56: R_X86_64_PLT32	rt_int_mod-0x4
    1f5a:	test   rax,rax
    1f5d:	jne    1f7d <botlish_fn_36+0x78>
    1f63:	xor    rax,rax
    1f66:	mov    r12,QWORD PTR [rsp]
    1f6a:	mov    r13,QWORD PTR [rsp+0x8]
    1f6f:	mov    r14,QWORD PTR [rsp+0x10]
    1f74:	add    rsp,0x20
    1f78:	mov    rsp,rbp
    1f7b:	pop    rbp
    1f7c:	ret
    1f7d:	mov    r12,QWORD PTR [rsp]
    1f81:	mov    r13,QWORD PTR [rsp+0x8]
    1f86:	mov    r14,QWORD PTR [rsp+0x10]
    1f8b:	add    rsp,0x20
    1f8f:	mov    rsp,rbp
    1f92:	pop    rbp
    1f93:	ret

0000000000001f94 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    1f94:	push   rbp
    1f95:	mov    rbp,rsp
    1f98:	mov    rsi,QWORD PTR [rdx]
    1f9b:	mov    rdx,QWORD PTR [rdx+0x8]
    1f9f:	call   1fa4 <botlish_entry_36+0x10>
			1fa0: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    1fa4:	mov    rsp,rbp
    1fa7:	pop    rbp
    1fa8:	ret

0000000000001fa9 <botlish_fn_37: ht_probe_start<any, str>>:
    1fa9:	push   rbp
    1faa:	mov    rbp,rsp
    1fad:	sub    rsp,0x20
    1fb1:	mov    QWORD PTR [rsp],r12
    1fb5:	mov    QWORD PTR [rsp+0x8],r13
    1fba:	mov    QWORD PTR [rsp+0x10],r14
    1fbf:	mov    r12,rdi
    1fc2:	mov    r14,rsi
    1fc5:	mov    rsi,rdx
    1fc8:	mov    rdi,r12
    1fcb:	call   1fd0 <botlish_fn_37+0x27>
			1fcc: R_X86_64_PLT32	rt_hash-0x4
    1fd0:	test   rax,rax
    1fd3:	mov    r13,rax
    1fd6:	je     2007 <botlish_fn_37+0x5e>
    1fdc:	mov    rsi,r14
    1fdf:	mov    rdi,r12
    1fe2:	call   1fe7 <botlish_fn_37+0x3e>
			1fe3: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    1fe7:	test   rax,rax
    1fea:	mov    rdx,rax
    1fed:	je     2007 <botlish_fn_37+0x5e>
    1ff3:	mov    rsi,r13
    1ff6:	mov    rdi,r12
    1ff9:	call   1ffe <botlish_fn_37+0x55>
			1ffa: R_X86_64_PLT32	rt_int_mod-0x4
    1ffe:	test   rax,rax
    2001:	jne    2021 <botlish_fn_37+0x78>
    2007:	xor    rax,rax
    200a:	mov    r12,QWORD PTR [rsp]
    200e:	mov    r13,QWORD PTR [rsp+0x8]
    2013:	mov    r14,QWORD PTR [rsp+0x10]
    2018:	add    rsp,0x20
    201c:	mov    rsp,rbp
    201f:	pop    rbp
    2020:	ret
    2021:	mov    r12,QWORD PTR [rsp]
    2025:	mov    r13,QWORD PTR [rsp+0x8]
    202a:	mov    r14,QWORD PTR [rsp+0x10]
    202f:	add    rsp,0x20
    2033:	mov    rsp,rbp
    2036:	pop    rbp
    2037:	ret

0000000000002038 <botlish_entry_37: ht_probe_start<any, str>>:
    2038:	push   rbp
    2039:	mov    rbp,rsp
    203c:	mov    rsi,QWORD PTR [rdx]
    203f:	mov    rdx,QWORD PTR [rdx+0x8]
    2043:	call   2048 <botlish_entry_37+0x10>
			2044: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    2048:	mov    rsp,rbp
    204b:	pop    rbp
    204c:	ret

000000000000204d <botlish_fn_38: ht_probe_next<mutarray, int>>:
    204d:	push   rbp
    204e:	mov    rbp,rsp
    2051:	sub    rsp,0x40
    2055:	mov    QWORD PTR [rsp+0x20],rbx
    205a:	mov    QWORD PTR [rsp+0x28],r12
    205f:	mov    QWORD PTR [rsp+0x30],r13
    2064:	mov    r13,rdi
    2067:	mov    QWORD PTR [rsp],rsi
    206b:	mov    rbx,rsi
    206e:	mov    QWORD PTR [rsp+0x8],rdx
    2073:	mov    QWORD PTR [rsp+0x10],0x3
    207c:	test   rdx,0x1
    2083:	jne    2091 <botlish_fn_38+0x44>
    2089:	mov    rsi,rdx
    208c:	jmp    20b1 <botlish_fn_38+0x64>
    2091:	mov    rsi,rdx
    2094:	add    rsi,0x2
    2098:	mov    r12,rsi
    209b:	mov    rsi,rdx
    209e:	seto   al
    20a1:	test   al,al
    20a3:	jne    20b1 <botlish_fn_38+0x64>
    20a9:	mov    rsi,rbx
    20ac:	jmp    20c4 <botlish_fn_38+0x77>
    20b1:	mov    edx,0x3
    20b6:	mov    rdi,r13
    20b9:	call   20be <botlish_fn_38+0x71>
			20ba: R_X86_64_PLT32	rt_int_add-0x4
    20be:	mov    rsi,rbx
    20c1:	mov    r12,rax
    20c4:	mov    rdi,r13
    20c7:	call   20cc <botlish_fn_38+0x7f>
			20c8: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    20cc:	test   rax,rax
    20cf:	mov    rdx,rax
    20d2:	je     20ec <botlish_fn_38+0x9f>
    20d8:	mov    rsi,r12
    20db:	mov    rdi,r13
    20de:	call   20e3 <botlish_fn_38+0x96>
			20df: R_X86_64_PLT32	rt_int_mod-0x4
    20e3:	test   rax,rax
    20e6:	jne    2107 <botlish_fn_38+0xba>
    20ec:	xor    rax,rax
    20ef:	mov    rbx,QWORD PTR [rsp+0x20]
    20f4:	mov    r12,QWORD PTR [rsp+0x28]
    20f9:	mov    r13,QWORD PTR [rsp+0x30]
    20fe:	add    rsp,0x40
    2102:	mov    rsp,rbp
    2105:	pop    rbp
    2106:	ret
    2107:	mov    rbx,QWORD PTR [rsp+0x20]
    210c:	mov    r12,QWORD PTR [rsp+0x28]
    2111:	mov    r13,QWORD PTR [rsp+0x30]
    2116:	add    rsp,0x40
    211a:	mov    rsp,rbp
    211d:	pop    rbp
    211e:	ret

000000000000211f <botlish_entry_38: ht_probe_next<mutarray, int>>:
    211f:	push   rbp
    2120:	mov    rbp,rsp
    2123:	mov    rsi,QWORD PTR [rdx]
    2126:	mov    rdx,QWORD PTR [rdx+0x8]
    212a:	call   212f <botlish_entry_38+0x10>
			212b: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    212f:	mov    rsp,rbp
    2132:	pop    rbp
    2133:	ret

0000000000002134 <botlish_fn_39: ht_probe_next<any, int>>:
    2134:	push   rbp
    2135:	mov    rbp,rsp
    2138:	sub    rsp,0x40
    213c:	mov    QWORD PTR [rsp+0x20],rbx
    2141:	mov    QWORD PTR [rsp+0x28],r12
    2146:	mov    QWORD PTR [rsp+0x30],r13
    214b:	mov    r13,rdi
    214e:	mov    QWORD PTR [rsp],rsi
    2152:	mov    rbx,rsi
    2155:	mov    QWORD PTR [rsp+0x8],rdx
    215a:	mov    QWORD PTR [rsp+0x10],0x3
    2163:	test   rdx,0x1
    216a:	jne    2178 <botlish_fn_39+0x44>
    2170:	mov    rsi,rdx
    2173:	jmp    2198 <botlish_fn_39+0x64>
    2178:	mov    rsi,rdx
    217b:	add    rsi,0x2
    217f:	mov    r12,rsi
    2182:	mov    rsi,rdx
    2185:	seto   al
    2188:	test   al,al
    218a:	jne    2198 <botlish_fn_39+0x64>
    2190:	mov    rsi,rbx
    2193:	jmp    21ab <botlish_fn_39+0x77>
    2198:	mov    edx,0x3
    219d:	mov    rdi,r13
    21a0:	call   21a5 <botlish_fn_39+0x71>
			21a1: R_X86_64_PLT32	rt_int_add-0x4
    21a5:	mov    rsi,rbx
    21a8:	mov    r12,rax
    21ab:	mov    rdi,r13
    21ae:	call   21b3 <botlish_fn_39+0x7f>
			21af: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    21b3:	test   rax,rax
    21b6:	mov    rdx,rax
    21b9:	je     21d3 <botlish_fn_39+0x9f>
    21bf:	mov    rsi,r12
    21c2:	mov    rdi,r13
    21c5:	call   21ca <botlish_fn_39+0x96>
			21c6: R_X86_64_PLT32	rt_int_mod-0x4
    21ca:	test   rax,rax
    21cd:	jne    21ee <botlish_fn_39+0xba>
    21d3:	xor    rax,rax
    21d6:	mov    rbx,QWORD PTR [rsp+0x20]
    21db:	mov    r12,QWORD PTR [rsp+0x28]
    21e0:	mov    r13,QWORD PTR [rsp+0x30]
    21e5:	add    rsp,0x40
    21e9:	mov    rsp,rbp
    21ec:	pop    rbp
    21ed:	ret
    21ee:	mov    rbx,QWORD PTR [rsp+0x20]
    21f3:	mov    r12,QWORD PTR [rsp+0x28]
    21f8:	mov    r13,QWORD PTR [rsp+0x30]
    21fd:	add    rsp,0x40
    2201:	mov    rsp,rbp
    2204:	pop    rbp
    2205:	ret

0000000000002206 <botlish_entry_39: ht_probe_next<any, int>>:
    2206:	push   rbp
    2207:	mov    rbp,rsp
    220a:	mov    rsi,QWORD PTR [rdx]
    220d:	mov    rdx,QWORD PTR [rdx+0x8]
    2211:	call   2216 <botlish_entry_39+0x10>
			2212: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    2216:	mov    rsp,rbp
    2219:	pop    rbp
    221a:	ret
    221b:	add    BYTE PTR [rax],al
    221d:	add    BYTE PTR [rax],al
	...

0000000000002220 <botlish_fn_40: ht_find_get<any, str, int>>:
    2220:	push   rbp
    2221:	mov    rbp,rsp
    2224:	sub    rsp,0x50
    2228:	mov    QWORD PTR [rsp+0x20],rbx
    222d:	mov    QWORD PTR [rsp+0x28],r12
    2232:	mov    QWORD PTR [rsp+0x30],r13
    2237:	mov    QWORD PTR [rsp+0x38],r14
    223c:	mov    QWORD PTR [rsp+0x40],r15
    2241:	mov    r14,rdi
    2244:	mov    QWORD PTR [rsp],rsi
    2248:	mov    QWORD PTR [rsp+0x8],rdx
    224d:	mov    r15,rdx
    2250:	mov    QWORD PTR [rsp+0x10],rcx
    2255:	mov    r13,rsi
    2258:	mov    QWORD PTR [rsp+0x18],rcx
    225d:	mov    rsi,r13
    2260:	mov    rdi,r14
    2263:	call   2268 <botlish_fn_40+0x48>
			2264: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2268:	test   rax,rax
    226b:	je     2470 <botlish_fn_40+0x250>
    2271:	xor    ecx,ecx
    2273:	test   rax,0x7
    2279:	je     2287 <botlish_fn_40+0x67>
    227f:	mov    r8,rax
    2282:	jmp    2295 <botlish_fn_40+0x75>
    2287:	movzx  rcx,BYTE PTR [rax]
    228b:	mov    r8,rax
    228e:	rex cmp cl,0x8
    2292:	sete   cl
    2295:	test   cl,cl
    2297:	jne    22ba <botlish_fn_40+0x9a>
    229d:	mov    rdi,r14
    22a0:	mov    rsi,QWORD PTR [rdi+0x10]
    22a4:	mov    rcx,QWORD PTR [rsi+0x20]
    22a8:	mov    edx,0x8
    22ad:	mov    rsi,r8
    22b0:	call   22b5 <botlish_fn_40+0x95>
			22b1: R_X86_64_PLT32	rt_type_error-0x4
    22b5:	jmp    2470 <botlish_fn_40+0x250>
    22ba:	mov    rsi,r8
    22bd:	mov    rdx,QWORD PTR [rsp+0x18]
    22c2:	mov    rdi,r14
    22c5:	call   22ca <botlish_fn_40+0xaa>
			22c6: R_X86_64_PLT32	rt_mutarray_get-0x4
    22ca:	mov    rcx,rax
    22cd:	mov    r12,rax
    22d0:	test   rax,rcx
    22d3:	je     2470 <botlish_fn_40+0x250>
    22d9:	mov    rdi,r14
    22dc:	call   22e1 <botlish_fn_40+0xc1>
			22dd: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    22e1:	mov    rax,r12
    22e4:	test   rax,0x1
    22ea:	jne    230e <botlish_fn_40+0xee>
    22f0:	mov    edx,0x1
    22f5:	mov    rsi,r12
    22f8:	mov    rdi,r14
    22fb:	call   2300 <botlish_fn_40+0xe0>
			22fc: R_X86_64_PLT32	rt_value_eq-0x4
    2300:	test   rax,rax
    2303:	je     2470 <botlish_fn_40+0x250>
    2309:	jmp    231f <botlish_fn_40+0xff>
    230e:	mov    eax,0x2
    2313:	cmp    r12,0x1
    2317:	cmove  rax,QWORD PTR [rip+0x1e1]        # 2500 <botlish_fn_40+0x2e0>
    231f:	mov    ebx,0x6
    2324:	cmp    rax,0x6
    2328:	je     24d7 <botlish_fn_40+0x2b7>
    232e:	mov    rdi,r14
    2331:	call   2336 <botlish_fn_40+0x116>
			2332: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2336:	test   r12,0x1
    233d:	jne    2361 <botlish_fn_40+0x141>
    2343:	mov    edx,0x3
    2348:	mov    rsi,r12
    234b:	mov    rdi,r14
    234e:	call   2353 <botlish_fn_40+0x133>
			234f: R_X86_64_PLT32	rt_value_eq-0x4
    2353:	test   rax,rax
    2356:	je     2470 <botlish_fn_40+0x250>
    235c:	jmp    2375 <botlish_fn_40+0x155>
    2361:	mov    rsi,r12
    2364:	mov    eax,0x2
    2369:	cmp    rsi,0x3
    236d:	cmove  rax,QWORD PTR [rip+0x18b]        # 2500 <botlish_fn_40+0x2e0>
    2375:	cmp    rax,0x6
    2379:	je     238c <botlish_fn_40+0x16c>
    237f:	mov    ebx,0x2
    2384:	mov    r12,r15
    2387:	jmp    244d <botlish_fn_40+0x22d>
    238c:	mov    rsi,r13
    238f:	mov    rdi,r14
    2392:	call   2397 <botlish_fn_40+0x177>
			2393: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2397:	test   rax,rax
    239a:	je     2470 <botlish_fn_40+0x250>
    23a0:	xor    ecx,ecx
    23a2:	test   rax,0x7
    23a8:	je     23b6 <botlish_fn_40+0x196>
    23ae:	mov    rsi,rax
    23b1:	jmp    23c4 <botlish_fn_40+0x1a4>
    23b6:	movzx  rcx,BYTE PTR [rax]
    23ba:	mov    rsi,rax
    23bd:	rex cmp cl,0x8
    23c1:	sete   cl
    23c4:	test   cl,cl
    23c6:	jne    23e6 <botlish_fn_40+0x1c6>
    23cc:	mov    rdi,r14
    23cf:	mov    rax,QWORD PTR [rdi+0x10]
    23d3:	mov    rcx,QWORD PTR [rax+0x20]
    23d7:	mov    edx,0x8
    23dc:	call   23e1 <botlish_fn_40+0x1c1>
			23dd: R_X86_64_PLT32	rt_type_error-0x4
    23e1:	jmp    2470 <botlish_fn_40+0x250>
    23e6:	mov    rdx,QWORD PTR [rsp+0x18]
    23eb:	mov    rdi,r14
    23ee:	call   23f3 <botlish_fn_40+0x1d3>
			23ef: R_X86_64_PLT32	rt_mutarray_get-0x4
    23f3:	test   rax,rax
    23f6:	je     2470 <botlish_fn_40+0x250>
    23fc:	mov    r12,r15
    23ff:	mov    rcx,rax
    2402:	and    rcx,r12
    2405:	mov    rsi,rax
    2408:	test   rcx,0x1
    240f:	jne    242e <botlish_fn_40+0x20e>
    2415:	mov    rdx,r12
    2418:	mov    rdi,r14
    241b:	call   2420 <botlish_fn_40+0x200>
			241c: R_X86_64_PLT32	rt_value_eq-0x4
    2420:	test   rax,rax
    2423:	je     2470 <botlish_fn_40+0x250>
    2429:	jmp    243e <botlish_fn_40+0x21e>
    242e:	mov    eax,0x2
    2433:	cmp    rsi,r12
    2436:	cmove  rax,QWORD PTR [rip+0xc2]        # 2500 <botlish_fn_40+0x2e0>
    243e:	cmp    rax,0x6
    2442:	je     244d <botlish_fn_40+0x22d>
    2448:	mov    ebx,0x2
    244d:	cmp    rbx,0x6
    2451:	je     24b0 <botlish_fn_40+0x290>
    2457:	mov    rdx,QWORD PTR [rsp+0x18]
    245c:	mov    rsi,r13
    245f:	mov    rdi,r14
    2462:	call   2467 <botlish_fn_40+0x247>
			2463: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    2467:	test   rax,rax
    246a:	jne    2495 <botlish_fn_40+0x275>
    2470:	xor    rax,rax
    2473:	mov    rbx,QWORD PTR [rsp+0x20]
    2478:	mov    r12,QWORD PTR [rsp+0x28]
    247d:	mov    r13,QWORD PTR [rsp+0x30]
    2482:	mov    r14,QWORD PTR [rsp+0x38]
    2487:	mov    r15,QWORD PTR [rsp+0x40]
    248c:	add    rsp,0x50
    2490:	mov    rsp,rbp
    2493:	pop    rbp
    2494:	ret
    2495:	mov    QWORD PTR [rsp],r13
    2499:	mov    QWORD PTR [rsp+0x8],r12
    249e:	mov    QWORD PTR [rsp+0x10],rax
    24a3:	mov    r15,r12
    24a6:	mov    QWORD PTR [rsp+0x18],rax
    24ab:	jmp    225d <botlish_fn_40+0x3d>
    24b0:	mov    rax,QWORD PTR [rsp+0x18]
    24b5:	mov    rbx,QWORD PTR [rsp+0x20]
    24ba:	mov    r12,QWORD PTR [rsp+0x28]
    24bf:	mov    r13,QWORD PTR [rsp+0x30]
    24c4:	mov    r14,QWORD PTR [rsp+0x38]
    24c9:	mov    r15,QWORD PTR [rsp+0x40]
    24ce:	add    rsp,0x50
    24d2:	mov    rsp,rbp
    24d5:	pop    rbp
    24d6:	ret
    24d7:	mov    rax,0xffffffffffffffff
    24de:	mov    rbx,QWORD PTR [rsp+0x20]
    24e3:	mov    r12,QWORD PTR [rsp+0x28]
    24e8:	mov    r13,QWORD PTR [rsp+0x30]
    24ed:	mov    r14,QWORD PTR [rsp+0x38]
    24f2:	mov    r15,QWORD PTR [rsp+0x40]
    24f7:	add    rsp,0x50
    24fb:	mov    rsp,rbp
    24fe:	pop    rbp
    24ff:	ret
    2500:	(bad)
    2501:	add    BYTE PTR [rax],al
    2503:	add    BYTE PTR [rax],al
    2505:	add    BYTE PTR [rax],al
	...

0000000000002508 <botlish_entry_40: ht_find_get<any, str, int>>:
    2508:	push   rbp
    2509:	mov    rbp,rsp
    250c:	mov    rsi,QWORD PTR [rdx]
    250f:	mov    r8,QWORD PTR [rdx+0x8]
    2513:	mov    rcx,QWORD PTR [rdx+0x10]
    2517:	mov    rdx,r8
    251a:	call   251f <botlish_entry_40+0x17>
			251b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    251f:	mov    rsp,rbp
    2522:	pop    rbp
    2523:	ret
    2524:	add    BYTE PTR [rax],al
	...

0000000000002528 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    2528:	push   rbp
    2529:	mov    rbp,rsp
    252c:	sub    rsp,0x60
    2530:	mov    QWORD PTR [rsp+0x30],rbx
    2535:	mov    QWORD PTR [rsp+0x38],r12
    253a:	mov    QWORD PTR [rsp+0x40],r13
    253f:	mov    QWORD PTR [rsp+0x48],r14
    2544:	mov    QWORD PTR [rsp+0x50],r15
    2549:	mov    r15,rdi
    254c:	mov    QWORD PTR [rsp],rsi
    2550:	mov    QWORD PTR [rsp+0x8],rdx
    2555:	mov    r13,rdx
    2558:	mov    QWORD PTR [rsp+0x10],rcx
    255d:	mov    QWORD PTR [rsp+0x18],r8
    2562:	mov    rbx,rsi
    2565:	mov    QWORD PTR [rsp+0x20],rcx
    256a:	mov    QWORD PTR [rsp+0x28],r8
    256f:	mov    rsi,rbx
    2572:	mov    rdi,r15
    2575:	call   257a <botlish_fn_41+0x52>
			2576: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    257a:	test   rax,rax
    257d:	je     2883 <botlish_fn_41+0x35b>
    2583:	xor    ecx,ecx
    2585:	test   rax,0x7
    258b:	je     2599 <botlish_fn_41+0x71>
    2591:	mov    rsi,rax
    2594:	jmp    25a7 <botlish_fn_41+0x7f>
    2599:	movzx  rcx,BYTE PTR [rax]
    259d:	mov    rsi,rax
    25a0:	rex cmp cl,0x8
    25a4:	sete   cl
    25a7:	test   cl,cl
    25a9:	jne    25c9 <botlish_fn_41+0xa1>
    25af:	mov    rdi,r15
    25b2:	mov    rax,QWORD PTR [rdi+0x10]
    25b6:	mov    rcx,QWORD PTR [rax+0x20]
    25ba:	mov    edx,0x8
    25bf:	call   25c4 <botlish_fn_41+0x9c>
			25c0: R_X86_64_PLT32	rt_type_error-0x4
    25c4:	jmp    2883 <botlish_fn_41+0x35b>
    25c9:	mov    rdx,QWORD PTR [rsp+0x20]
    25ce:	mov    rdi,r15
    25d1:	call   25d6 <botlish_fn_41+0xae>
			25d2: R_X86_64_PLT32	rt_mutarray_get-0x4
    25d6:	mov    r9,rax
    25d9:	mov    r14,rax
    25dc:	test   rax,r9
    25df:	je     2883 <botlish_fn_41+0x35b>
    25e5:	mov    rdi,r15
    25e8:	call   25ed <botlish_fn_41+0xc5>
			25e9: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    25ed:	mov    rax,r14
    25f0:	test   rax,0x1
    25f6:	jne    261a <botlish_fn_41+0xf2>
    25fc:	mov    edx,0x1
    2601:	mov    rsi,r14
    2604:	mov    rdi,r15
    2607:	call   260c <botlish_fn_41+0xe4>
			2608: R_X86_64_PLT32	rt_value_eq-0x4
    260c:	test   rax,rax
    260f:	je     2883 <botlish_fn_41+0x35b>
    2615:	jmp    262e <botlish_fn_41+0x106>
    261a:	mov    eax,0x2
    261f:	mov    rcx,r14
    2622:	cmp    rcx,0x1
    2626:	cmove  rax,QWORD PTR [rip+0x37a]        # 29a8 <botlish_fn_41+0x480>
    262e:	mov    r12d,0x6
    2634:	cmp    rax,0x6
    2638:	je     28fb <botlish_fn_41+0x3d3>
    263e:	mov    rdi,r15
    2641:	call   2646 <botlish_fn_41+0x11e>
			2642: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2646:	mov    rax,r14
    2649:	test   rax,0x1
    264f:	jne    2673 <botlish_fn_41+0x14b>
    2655:	mov    edx,0x3
    265a:	mov    rsi,r14
    265d:	mov    rdi,r15
    2660:	call   2665 <botlish_fn_41+0x13d>
			2661: R_X86_64_PLT32	rt_value_eq-0x4
    2665:	test   rax,rax
    2668:	je     2883 <botlish_fn_41+0x35b>
    266e:	jmp    2687 <botlish_fn_41+0x15f>
    2673:	mov    eax,0x2
    2678:	mov    rcx,r14
    267b:	cmp    rcx,0x3
    267f:	cmove  rax,QWORD PTR [rip+0x321]        # 29a8 <botlish_fn_41+0x480>
    2687:	cmp    rax,0x6
    268b:	je     269b <botlish_fn_41+0x173>
    2691:	mov    eax,0x2
    2696:	jmp    275c <botlish_fn_41+0x234>
    269b:	mov    rsi,rbx
    269e:	mov    rdi,r15
    26a1:	call   26a6 <botlish_fn_41+0x17e>
			26a2: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    26a6:	test   rax,rax
    26a9:	je     2883 <botlish_fn_41+0x35b>
    26af:	xor    ecx,ecx
    26b1:	test   rax,0x7
    26b7:	jne    26c8 <botlish_fn_41+0x1a0>
    26bd:	movzx  rcx,BYTE PTR [rax]
    26c1:	rex cmp cl,0x8
    26c5:	sete   cl
    26c8:	test   cl,cl
    26ca:	jne    26ed <botlish_fn_41+0x1c5>
    26d0:	mov    rdi,r15
    26d3:	mov    rsi,QWORD PTR [rdi+0x10]
    26d7:	mov    rcx,QWORD PTR [rsi+0x20]
    26db:	mov    edx,0x8
    26e0:	mov    rsi,rax
    26e3:	call   26e8 <botlish_fn_41+0x1c0>
			26e4: R_X86_64_PLT32	rt_type_error-0x4
    26e8:	jmp    2883 <botlish_fn_41+0x35b>
    26ed:	mov    rsi,rax
    26f0:	mov    rdx,QWORD PTR [rsp+0x20]
    26f5:	mov    rdi,r15
    26f8:	call   26fd <botlish_fn_41+0x1d5>
			26f9: R_X86_64_PLT32	rt_mutarray_get-0x4
    26fd:	test   rax,rax
    2700:	je     2883 <botlish_fn_41+0x35b>
    2706:	mov    r8,rax
    2709:	and    r8,r13
    270c:	mov    rsi,rax
    270f:	test   r8,0x1
    2716:	jne    2735 <botlish_fn_41+0x20d>
    271c:	mov    rdx,r13
    271f:	mov    rdi,r15
    2722:	call   2727 <botlish_fn_41+0x1ff>
			2723: R_X86_64_PLT32	rt_value_eq-0x4
    2727:	test   rax,rax
    272a:	je     2883 <botlish_fn_41+0x35b>
    2730:	jmp    2745 <botlish_fn_41+0x21d>
    2735:	mov    eax,0x2
    273a:	cmp    rsi,r13
    273d:	cmove  rax,QWORD PTR [rip+0x263]        # 29a8 <botlish_fn_41+0x480>
    2745:	cmp    rax,0x6
    2749:	je     2759 <botlish_fn_41+0x231>
    274f:	mov    eax,0x2
    2754:	jmp    275c <botlish_fn_41+0x234>
    2759:	mov    rax,r12
    275c:	cmp    rax,0x6
    2760:	je     28d4 <botlish_fn_41+0x3ac>
    2766:	mov    rdi,r15
    2769:	call   276e <botlish_fn_41+0x246>
			276a: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    276e:	mov    rax,r14
    2771:	test   rax,0x1
    2777:	jne    279b <botlish_fn_41+0x273>
    277d:	mov    edx,0x5
    2782:	mov    rsi,r14
    2785:	mov    rdi,r15
    2788:	call   278d <botlish_fn_41+0x265>
			2789: R_X86_64_PLT32	rt_value_eq-0x4
    278d:	test   rax,rax
    2790:	je     2883 <botlish_fn_41+0x35b>
    2796:	jmp    27af <botlish_fn_41+0x287>
    279b:	mov    rsi,r14
    279e:	mov    eax,0x2
    27a3:	cmp    rsi,0x5
    27a7:	cmove  rax,QWORD PTR [rip+0x1f9]        # 29a8 <botlish_fn_41+0x480>
    27af:	cmp    rax,0x6
    27b3:	je     27c4 <botlish_fn_41+0x29c>
    27b9:	mov    r12d,0x2
    27bf:	jmp    2825 <botlish_fn_41+0x2fd>
    27c4:	mov    r14,QWORD PTR [rsp+0x28]
    27c9:	test   r14,0x1
    27d0:	jne    2800 <botlish_fn_41+0x2d8>
    27d6:	mov    edx,0x1
    27db:	mov    rsi,r14
    27de:	mov    rdi,r15
    27e1:	call   27e6 <botlish_fn_41+0x2be>
			27e2: R_X86_64_PLT32	rt_int_cmp-0x4
    27e6:	mov    ecx,0x2
    27eb:	test   rax,rax
    27ee:	cmovl  rcx,QWORD PTR [rip+0x1b2]        # 29a8 <botlish_fn_41+0x480>
    27f6:	mov    QWORD PTR [rsp+0x28],r14
    27fb:	jmp    2815 <botlish_fn_41+0x2ed>
    2800:	mov    ecx,0x2
    2805:	test   r14,r14
    2808:	mov    QWORD PTR [rsp+0x28],r14
    280d:	cmovle rcx,QWORD PTR [rip+0x193]        # 29a8 <botlish_fn_41+0x480>
    2815:	cmp    rcx,0x6
    2819:	je     2825 <botlish_fn_41+0x2fd>
    281f:	mov    r12d,0x2
    2825:	cmp    r12,0x6
    2829:	je     286a <botlish_fn_41+0x342>
    282f:	mov    rdx,QWORD PTR [rsp+0x20]
    2834:	mov    rsi,rbx
    2837:	mov    rdi,r15
    283a:	call   283f <botlish_fn_41+0x317>
			283b: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    283f:	test   rax,rax
    2842:	je     2883 <botlish_fn_41+0x35b>
    2848:	mov    QWORD PTR [rsp],rbx
    284c:	mov    QWORD PTR [rsp+0x8],r13
    2851:	mov    QWORD PTR [rsp+0x10],rax
    2856:	mov    rcx,QWORD PTR [rsp+0x28]
    285b:	mov    QWORD PTR [rsp+0x18],rcx
    2860:	mov    QWORD PTR [rsp+0x20],rax
    2865:	jmp    256f <botlish_fn_41+0x47>
    286a:	mov    rdx,QWORD PTR [rsp+0x20]
    286f:	mov    rsi,rbx
    2872:	mov    rdi,r15
    2875:	call   287a <botlish_fn_41+0x352>
			2876: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    287a:	test   rax,rax
    287d:	jne    28a8 <botlish_fn_41+0x380>
    2883:	xor    rax,rax
    2886:	mov    rbx,QWORD PTR [rsp+0x30]
    288b:	mov    r12,QWORD PTR [rsp+0x38]
    2890:	mov    r13,QWORD PTR [rsp+0x40]
    2895:	mov    r14,QWORD PTR [rsp+0x48]
    289a:	mov    r15,QWORD PTR [rsp+0x50]
    289f:	add    rsp,0x60
    28a3:	mov    rsp,rbp
    28a6:	pop    rbp
    28a7:	ret
    28a8:	mov    QWORD PTR [rsp],rbx
    28ac:	mov    QWORD PTR [rsp+0x8],r13
    28b1:	mov    QWORD PTR [rsp+0x10],rax
    28b6:	mov    rdx,QWORD PTR [rsp+0x20]
    28bb:	mov    QWORD PTR [rsp+0x18],rdx
    28c0:	mov    rcx,QWORD PTR [rsp+0x20]
    28c5:	mov    QWORD PTR [rsp+0x28],rcx
    28ca:	mov    QWORD PTR [rsp+0x20],rax
    28cf:	jmp    256f <botlish_fn_41+0x47>
    28d4:	mov    rax,QWORD PTR [rsp+0x20]
    28d9:	mov    rbx,QWORD PTR [rsp+0x30]
    28de:	mov    r12,QWORD PTR [rsp+0x38]
    28e3:	mov    r13,QWORD PTR [rsp+0x40]
    28e8:	mov    r14,QWORD PTR [rsp+0x48]
    28ed:	mov    r15,QWORD PTR [rsp+0x50]
    28f2:	add    rsp,0x60
    28f6:	mov    rsp,rbp
    28f9:	pop    rbp
    28fa:	ret
    28fb:	mov    rax,QWORD PTR [rsp+0x28]
    2900:	test   rax,0x1
    2906:	jne    2933 <botlish_fn_41+0x40b>
    290c:	mov    edx,0x1
    2911:	mov    rdi,r15
    2914:	mov    rsi,QWORD PTR [rsp+0x28]
    2919:	call   291e <botlish_fn_41+0x3f6>
			291a: R_X86_64_PLT32	rt_int_cmp-0x4
    291e:	mov    ecx,0x2
    2923:	test   rax,rax
    2926:	cmovge rcx,QWORD PTR [rip+0x7a]        # 29a8 <botlish_fn_41+0x480>
    292e:	jmp    294d <botlish_fn_41+0x425>
    2933:	mov    ecx,0x2
    2938:	mov    rax,QWORD PTR [rsp+0x28]
    293d:	mov    rdx,QWORD PTR [rsp+0x28]
    2942:	test   rax,rdx
    2945:	cmovg  rcx,QWORD PTR [rip+0x5b]        # 29a8 <botlish_fn_41+0x480>
    294d:	cmp    rcx,0x6
    2951:	je     297e <botlish_fn_41+0x456>
    2957:	mov    rax,QWORD PTR [rsp+0x20]
    295c:	mov    rbx,QWORD PTR [rsp+0x30]
    2961:	mov    r12,QWORD PTR [rsp+0x38]
    2966:	mov    r13,QWORD PTR [rsp+0x40]
    296b:	mov    r14,QWORD PTR [rsp+0x48]
    2970:	mov    r15,QWORD PTR [rsp+0x50]
    2975:	add    rsp,0x60
    2979:	mov    rsp,rbp
    297c:	pop    rbp
    297d:	ret
    297e:	mov    rax,QWORD PTR [rsp+0x28]
    2983:	mov    rbx,QWORD PTR [rsp+0x30]
    2988:	mov    r12,QWORD PTR [rsp+0x38]
    298d:	mov    r13,QWORD PTR [rsp+0x40]
    2992:	mov    r14,QWORD PTR [rsp+0x48]
    2997:	mov    r15,QWORD PTR [rsp+0x50]
    299c:	add    rsp,0x60
    29a0:	mov    rsp,rbp
    29a3:	pop    rbp
    29a4:	ret
    29a5:	add    BYTE PTR [rax],al
    29a7:	add    BYTE PTR [rsi],al
    29a9:	add    BYTE PTR [rax],al
    29ab:	add    BYTE PTR [rax],al
    29ad:	add    BYTE PTR [rax],al
	...

00000000000029b0 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    29b0:	push   rbp
    29b1:	mov    rbp,rsp
    29b4:	mov    rsi,QWORD PTR [rdx]
    29b7:	mov    r9,QWORD PTR [rdx+0x8]
    29bb:	mov    rcx,QWORD PTR [rdx+0x10]
    29bf:	mov    r8,QWORD PTR [rdx+0x18]
    29c3:	mov    rdx,r9
    29c6:	call   29cb <botlish_entry_41+0x1b>
			29c7: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    29cb:	mov    rsp,rbp
    29ce:	pop    rbp
    29cf:	ret

00000000000029d0 <botlish_fn_42: ht_get<any, str>>:
    29d0:	push   rbp
    29d1:	mov    rbp,rsp
    29d4:	sub    rsp,0x40
    29d8:	mov    QWORD PTR [rsp+0x20],rbx
    29dd:	mov    QWORD PTR [rsp+0x28],r12
    29e2:	mov    QWORD PTR [rsp+0x30],r13
    29e7:	mov    rbx,rdi
    29ea:	mov    QWORD PTR [rsp],rsi
    29ee:	mov    r13,rsi
    29f1:	mov    QWORD PTR [rsp+0x8],rdx
    29f6:	mov    r12,rdx
    29f9:	mov    rdx,r12
    29fc:	mov    rsi,r13
    29ff:	mov    rdi,rbx
    2a02:	call   2a07 <botlish_fn_42+0x37>
			2a03: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    2a07:	test   rax,rax
    2a0a:	je     2af4 <botlish_fn_42+0x124>
    2a10:	mov    QWORD PTR [rsp+0x10],rax
    2a15:	mov    rcx,rax
    2a18:	mov    rdx,r12
    2a1b:	mov    rsi,r13
    2a1e:	mov    rdi,rbx
    2a21:	call   2a26 <botlish_fn_42+0x56>
			2a22: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    2a26:	mov    rcx,rax
    2a29:	mov    r12,rax
    2a2c:	test   rax,rcx
    2a2f:	je     2af4 <botlish_fn_42+0x124>
    2a35:	mov    rax,r12
    2a38:	test   rax,0x1
    2a3e:	jne    2a69 <botlish_fn_42+0x99>
    2a44:	mov    edx,0x1
    2a49:	mov    rsi,r12
    2a4c:	mov    rdi,rbx
    2a4f:	call   2a54 <botlish_fn_42+0x84>
			2a50: R_X86_64_PLT32	rt_int_cmp-0x4
    2a54:	mov    ecx,0x2
    2a59:	test   rax,rax
    2a5c:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 2b48 <botlish_fn_42+0x178>
    2a64:	jmp    2a7c <botlish_fn_42+0xac>
    2a69:	mov    ecx,0x2
    2a6e:	mov    rax,r12
    2a71:	test   rax,rax
    2a74:	cmovle rcx,QWORD PTR [rip+0xcc]        # 2b48 <botlish_fn_42+0x178>
    2a7c:	cmp    rcx,0x6
    2a80:	je     2b27 <botlish_fn_42+0x157>
    2a86:	mov    rsi,r13
    2a89:	mov    rdi,rbx
    2a8c:	call   2a91 <botlish_fn_42+0xc1>
			2a8d: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    2a91:	test   rax,rax
    2a94:	je     2af4 <botlish_fn_42+0x124>
    2a9a:	xor    ecx,ecx
    2a9c:	test   rax,0x7
    2aa2:	je     2ab0 <botlish_fn_42+0xe0>
    2aa8:	mov    rsi,rax
    2aab:	jmp    2abe <botlish_fn_42+0xee>
    2ab0:	movzx  rcx,BYTE PTR [rax]
    2ab4:	mov    rsi,rax
    2ab7:	rex cmp cl,0x8
    2abb:	sete   cl
    2abe:	test   cl,cl
    2ac0:	jne    2ae0 <botlish_fn_42+0x110>
    2ac6:	mov    rdi,rbx
    2ac9:	mov    rax,QWORD PTR [rdi+0x10]
    2acd:	mov    rcx,QWORD PTR [rax+0x20]
    2ad1:	mov    edx,0x8
    2ad6:	call   2adb <botlish_fn_42+0x10b>
			2ad7: R_X86_64_PLT32	rt_type_error-0x4
    2adb:	jmp    2af4 <botlish_fn_42+0x124>
    2ae0:	mov    rdx,r12
    2ae3:	mov    rdi,rbx
    2ae6:	call   2aeb <botlish_fn_42+0x11b>
			2ae7: R_X86_64_PLT32	rt_mutarray_get-0x4
    2aeb:	test   rax,rax
    2aee:	jne    2b0f <botlish_fn_42+0x13f>
    2af4:	xor    rax,rax
    2af7:	mov    rbx,QWORD PTR [rsp+0x20]
    2afc:	mov    r12,QWORD PTR [rsp+0x28]
    2b01:	mov    r13,QWORD PTR [rsp+0x30]
    2b06:	add    rsp,0x40
    2b0a:	mov    rsp,rbp
    2b0d:	pop    rbp
    2b0e:	ret
    2b0f:	mov    rbx,QWORD PTR [rsp+0x20]
    2b14:	mov    r12,QWORD PTR [rsp+0x28]
    2b19:	mov    r13,QWORD PTR [rsp+0x30]
    2b1e:	add    rsp,0x40
    2b22:	mov    rsp,rbp
    2b25:	pop    rbp
    2b26:	ret
    2b27:	mov    eax,0xa
    2b2c:	mov    rbx,QWORD PTR [rsp+0x20]
    2b31:	mov    r12,QWORD PTR [rsp+0x28]
    2b36:	mov    r13,QWORD PTR [rsp+0x30]
    2b3b:	add    rsp,0x40
    2b3f:	mov    rsp,rbp
    2b42:	pop    rbp
    2b43:	ret
    2b44:	add    BYTE PTR [rax],al
    2b46:	add    BYTE PTR [rax],al
    2b48:	(bad)
    2b49:	add    BYTE PTR [rax],al
    2b4b:	add    BYTE PTR [rax],al
    2b4d:	add    BYTE PTR [rax],al
	...

0000000000002b50 <botlish_entry_42: ht_get<any, str>>:
    2b50:	push   rbp
    2b51:	mov    rbp,rsp
    2b54:	mov    rsi,QWORD PTR [rdx]
    2b57:	mov    rdx,QWORD PTR [rdx+0x8]
    2b5b:	call   2b60 <botlish_entry_42+0x10>
			2b5c: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    2b60:	mov    rsp,rbp
    2b63:	pop    rbp
    2b64:	ret
    2b65:	add    BYTE PTR [rax],al
	...

0000000000002b68 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    2b68:	push   rbp
    2b69:	mov    rbp,rsp
    2b6c:	sub    rsp,0x50
    2b70:	mov    QWORD PTR [rsp+0x20],rbx
    2b75:	mov    QWORD PTR [rsp+0x28],r12
    2b7a:	mov    QWORD PTR [rsp+0x30],r13
    2b7f:	mov    QWORD PTR [rsp+0x38],r14
    2b84:	mov    QWORD PTR [rsp+0x40],r15
    2b89:	mov    r13,rdi
    2b8c:	mov    QWORD PTR [rsp],rsi
    2b90:	mov    QWORD PTR [rsp+0x8],rdx
    2b95:	mov    QWORD PTR [rsp+0x10],rcx
    2b9a:	mov    r12,rcx
    2b9d:	mov    rbx,rsi
    2ba0:	mov    r14,rdx
    2ba3:	mov    rdx,r14
    2ba6:	mov    rsi,rbx
    2ba9:	mov    rdi,r13
    2bac:	call   2bb1 <botlish_fn_43+0x49>
			2bad: R_X86_64_PLT32	rt_mutarray_get-0x4
    2bb1:	test   rax,rax
    2bb4:	mov    r15,rax
    2bb7:	je     2c62 <botlish_fn_43+0xfa>
    2bbd:	mov    rdi,r13
    2bc0:	call   2bc5 <botlish_fn_43+0x5d>
			2bc1: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    2bc5:	mov    rax,r15
    2bc8:	test   rax,0x1
    2bce:	jne    2bf2 <botlish_fn_43+0x8a>
    2bd4:	mov    edx,0x1
    2bd9:	mov    rsi,r15
    2bdc:	mov    rdi,r13
    2bdf:	call   2be4 <botlish_fn_43+0x7c>
			2be0: R_X86_64_PLT32	rt_value_eq-0x4
    2be4:	test   rax,rax
    2be7:	je     2c62 <botlish_fn_43+0xfa>
    2bed:	jmp    2c06 <botlish_fn_43+0x9e>
    2bf2:	mov    rsi,r15
    2bf5:	mov    eax,0x2
    2bfa:	cmp    rsi,0x1
    2bfe:	cmove  rax,QWORD PTR [rip+0xc2]        # 2cc8 <botlish_fn_43+0x160>
    2c06:	cmp    rax,0x6
    2c0a:	je     2c9d <botlish_fn_43+0x135>
    2c10:	mov    QWORD PTR [rsp+0x18],0x3
    2c19:	mov    rsi,r14
    2c1c:	test   rsi,0x1
    2c23:	je     2c3b <botlish_fn_43+0xd3>
    2c29:	mov    rsi,r14
    2c2c:	add    rsi,0x2
    2c30:	seto   al
    2c33:	test   al,al
    2c35:	je     2c4e <botlish_fn_43+0xe6>
    2c3b:	mov    edx,0x3
    2c40:	mov    rsi,r14
    2c43:	mov    rdi,r13
    2c46:	call   2c4b <botlish_fn_43+0xe3>
			2c47: R_X86_64_PLT32	rt_int_add-0x4
    2c4b:	mov    rsi,rax
    2c4e:	mov    rdx,r12
    2c51:	mov    rdi,r13
    2c54:	call   2c59 <botlish_fn_43+0xf1>
			2c55: R_X86_64_PLT32	rt_int_mod-0x4
    2c59:	test   rax,rax
    2c5c:	jne    2c87 <botlish_fn_43+0x11f>
    2c62:	xor    rax,rax
    2c65:	mov    rbx,QWORD PTR [rsp+0x20]
    2c6a:	mov    r12,QWORD PTR [rsp+0x28]
    2c6f:	mov    r13,QWORD PTR [rsp+0x30]
    2c74:	mov    r14,QWORD PTR [rsp+0x38]
    2c79:	mov    r15,QWORD PTR [rsp+0x40]
    2c7e:	add    rsp,0x50
    2c82:	mov    rsp,rbp
    2c85:	pop    rbp
    2c86:	ret
    2c87:	mov    QWORD PTR [rsp],rbx
    2c8b:	mov    QWORD PTR [rsp+0x8],rax
    2c90:	mov    QWORD PTR [rsp+0x10],r12
    2c95:	mov    r14,rax
    2c98:	jmp    2ba3 <botlish_fn_43+0x3b>
    2c9d:	mov    rax,r14
    2ca0:	mov    rbx,QWORD PTR [rsp+0x20]
    2ca5:	mov    r12,QWORD PTR [rsp+0x28]
    2caa:	mov    r13,QWORD PTR [rsp+0x30]
    2caf:	mov    r14,QWORD PTR [rsp+0x38]
    2cb4:	mov    r15,QWORD PTR [rsp+0x40]
    2cb9:	add    rsp,0x50
    2cbd:	mov    rsp,rbp
    2cc0:	pop    rbp
    2cc1:	ret
    2cc2:	add    BYTE PTR [rax],al
    2cc4:	add    BYTE PTR [rax],al
    2cc6:	add    BYTE PTR [rax],al
    2cc8:	(bad)
    2cc9:	add    BYTE PTR [rax],al
    2ccb:	add    BYTE PTR [rax],al
    2ccd:	add    BYTE PTR [rax],al
	...

0000000000002cd0 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    2cd0:	push   rbp
    2cd1:	mov    rbp,rsp
    2cd4:	mov    rsi,QWORD PTR [rdx]
    2cd7:	mov    r8,QWORD PTR [rdx+0x8]
    2cdb:	mov    rcx,QWORD PTR [rdx+0x10]
    2cdf:	mov    rdx,r8
    2ce2:	call   2ce7 <botlish_entry_43+0x17>
			2ce3: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    2ce7:	mov    rsp,rbp
    2cea:	pop    rbp
    2ceb:	ret

0000000000002cec <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    2cec:	push   rbp
    2ced:	mov    rbp,rsp
    2cf0:	sub    rsp,0x80
    2cf7:	mov    QWORD PTR [rsp+0x50],rbx
    2cfc:	mov    QWORD PTR [rsp+0x58],r12
    2d01:	mov    QWORD PTR [rsp+0x60],r13
    2d06:	mov    QWORD PTR [rsp+0x68],r14
    2d0b:	mov    QWORD PTR [rsp+0x70],r15
    2d10:	mov    r12,rdi
    2d13:	mov    rdi,QWORD PTR [rbp+0x10]
    2d17:	mov    QWORD PTR [rsp],rsi
    2d1b:	mov    QWORD PTR [rsp+0x38],rsi
    2d20:	mov    QWORD PTR [rsp+0x8],rdx
    2d25:	mov    r15,rdx
    2d28:	mov    QWORD PTR [rsp+0x10],rcx
    2d2d:	mov    rbx,rcx
    2d30:	mov    QWORD PTR [rsp+0x18],r8
    2d35:	mov    QWORD PTR [rsp+0x40],r8
    2d3a:	mov    QWORD PTR [rsp+0x20],r9
    2d3f:	mov    r14,r9
    2d42:	mov    QWORD PTR [rsp+0x28],rdi
    2d47:	mov    r13,rdi
    2d4a:	mov    rsi,r14
    2d4d:	mov    rdi,r12
    2d50:	call   2d55 <botlish_fn_44+0x69>
			2d51: R_X86_64_PLT32	rt_hash-0x4
    2d55:	test   rax,rax
    2d58:	mov    rsi,rax
    2d5b:	je     2dff <botlish_fn_44+0x113>
    2d61:	mov    rdx,QWORD PTR [rsp+0x40]
    2d66:	mov    rdi,r12
    2d69:	call   2d6e <botlish_fn_44+0x82>
			2d6a: R_X86_64_PLT32	rt_int_mod-0x4
    2d6e:	test   rax,rax
    2d71:	je     2dff <botlish_fn_44+0x113>
    2d77:	mov    QWORD PTR [rsp+0x30],rax
    2d7c:	mov    rcx,QWORD PTR [rsp+0x40]
    2d81:	mov    rdx,rax
    2d84:	mov    rsi,QWORD PTR [rsp+0x38]
    2d89:	mov    rdi,r12
    2d8c:	call   2d91 <botlish_fn_44+0xa5>
			2d8d: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    2d91:	test   rax,rax
    2d94:	mov    QWORD PTR [rsp+0x40],rax
    2d99:	je     2dff <botlish_fn_44+0x113>
    2d9f:	mov    rdi,r12
    2da2:	call   2da7 <botlish_fn_44+0xbb>
			2da3: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2da7:	mov    ecx,0x3
    2dac:	mov    rsi,QWORD PTR [rsp+0x38]
    2db1:	mov    rdx,QWORD PTR [rsp+0x40]
    2db6:	mov    rdi,r12
    2db9:	call   2dbe <botlish_fn_44+0xd2>
			2dba: R_X86_64_PLT32	rt_mutarray_set-0x4
    2dbe:	test   rax,rax
    2dc1:	je     2dff <botlish_fn_44+0x113>
    2dc7:	mov    rcx,r14
    2dca:	mov    rsi,r15
    2dcd:	mov    rdx,QWORD PTR [rsp+0x40]
    2dd2:	mov    rdi,r12
    2dd5:	call   2dda <botlish_fn_44+0xee>
			2dd6: R_X86_64_PLT32	rt_mutarray_set-0x4
    2dda:	test   rax,rax
    2ddd:	je     2dff <botlish_fn_44+0x113>
    2de3:	mov    rcx,r13
    2de6:	mov    rdx,QWORD PTR [rsp+0x40]
    2deb:	mov    rsi,rbx
    2dee:	mov    rdi,r12
    2df1:	call   2df6 <botlish_fn_44+0x10a>
			2df2: R_X86_64_PLT32	rt_mutarray_set-0x4
    2df6:	test   rax,rax
    2df9:	jne    2e27 <botlish_fn_44+0x13b>
    2dff:	xor    rax,rax
    2e02:	mov    rbx,QWORD PTR [rsp+0x50]
    2e07:	mov    r12,QWORD PTR [rsp+0x58]
    2e0c:	mov    r13,QWORD PTR [rsp+0x60]
    2e11:	mov    r14,QWORD PTR [rsp+0x68]
    2e16:	mov    r15,QWORD PTR [rsp+0x70]
    2e1b:	add    rsp,0x80
    2e22:	mov    rsp,rbp
    2e25:	pop    rbp
    2e26:	ret
    2e27:	mov    eax,0xa
    2e2c:	mov    rbx,QWORD PTR [rsp+0x50]
    2e31:	mov    r12,QWORD PTR [rsp+0x58]
    2e36:	mov    r13,QWORD PTR [rsp+0x60]
    2e3b:	mov    r14,QWORD PTR [rsp+0x68]
    2e40:	mov    r15,QWORD PTR [rsp+0x70]
    2e45:	add    rsp,0x80
    2e4c:	mov    rsp,rbp
    2e4f:	pop    rbp
    2e50:	ret

0000000000002e51 <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    2e51:	push   rbp
    2e52:	mov    rbp,rsp
    2e55:	sub    rsp,0x10
    2e59:	mov    rsi,QWORD PTR [rdx]
    2e5c:	mov    r10,QWORD PTR [rdx+0x8]
    2e60:	mov    rcx,QWORD PTR [rdx+0x10]
    2e64:	mov    r8,QWORD PTR [rdx+0x18]
    2e68:	mov    r9,QWORD PTR [rdx+0x20]
    2e6c:	mov    r11,QWORD PTR [rdx+0x28]
    2e70:	mov    QWORD PTR [rsp],r11
    2e74:	mov    rdx,r10
    2e77:	call   2e7c <botlish_entry_44+0x2b>
			2e78: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    2e7c:	add    rsp,0x10
    2e80:	mov    rsp,rbp
    2e83:	pop    rbp
    2e84:	ret
    2e85:	add    BYTE PTR [rax],al
	...

0000000000002e88 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2e88:	push   rbp
    2e89:	mov    rbp,rsp
    2e8c:	sub    rsp,0xc0
    2e93:	mov    QWORD PTR [rsp+0x90],rbx
    2e9b:	mov    QWORD PTR [rsp+0x98],r12
    2ea3:	mov    QWORD PTR [rsp+0xa0],r13
    2eab:	mov    QWORD PTR [rsp+0xa8],r14
    2eb3:	mov    QWORD PTR [rsp+0xb0],r15
    2ebb:	mov    QWORD PTR [rsp+0x60],rdi
    2ec0:	mov    QWORD PTR [rsp+0x80],r9
    2ec8:	mov    r12,QWORD PTR [rbp+0x10]
    2ecc:	mov    r13,QWORD PTR [rbp+0x18]
    2ed0:	mov    r14,QWORD PTR [rbp+0x20]
    2ed4:	mov    rdi,QWORD PTR [rbp+0x28]
    2ed8:	mov    QWORD PTR [rsp+0x10],rsi
    2edd:	mov    QWORD PTR [rsp+0x68],rsi
    2ee2:	mov    QWORD PTR [rsp+0x18],rdx
    2ee7:	mov    QWORD PTR [rsp+0x70],rdx
    2eec:	mov    QWORD PTR [rsp+0x20],rcx
    2ef1:	mov    QWORD PTR [rsp+0x78],rcx
    2ef6:	mov    QWORD PTR [rsp+0x28],r8
    2efb:	mov    rax,r12
    2efe:	mov    QWORD PTR [rsp+0x30],rax
    2f03:	mov    QWORD PTR [rsp+0x38],r13
    2f08:	mov    QWORD PTR [rsp+0x40],r14
    2f0d:	mov    QWORD PTR [rsp+0x48],rdi
    2f12:	mov    QWORD PTR [rsp+0x88],rdi
    2f1a:	mov    rsi,QWORD PTR [rsp+0x80]
    2f22:	mov    rax,rsi
    2f25:	or     rax,0x1
    2f29:	mov    r15,r8
    2f2c:	mov    rcx,r15
    2f2f:	and    rcx,rax
    2f32:	test   rcx,0x1
    2f39:	jne    2f70 <botlish_fn_45+0xe8>
    2f3f:	mov    rdx,rsi
    2f42:	or     rdx,0x1
    2f46:	mov    QWORD PTR [rsp+0x80],rsi
    2f4e:	mov    rsi,r15
    2f51:	mov    rdi,QWORD PTR [rsp+0x60]
    2f56:	call   2f5b <botlish_fn_45+0xd3>
			2f57: R_X86_64_PLT32	rt_int_cmp-0x4
    2f5b:	mov    ecx,0x2
    2f60:	test   rax,rax
    2f63:	cmovge rcx,QWORD PTR [rip+0x2ed]        # 3258 <botlish_fn_45+0x3d0>
    2f6b:	jmp    2f92 <botlish_fn_45+0x10a>
    2f70:	mov    rdi,rsi
    2f73:	mov    QWORD PTR [rsp+0x80],rsi
    2f7b:	mov    rax,rdi
    2f7e:	or     rax,0x1
    2f82:	mov    ecx,0x2
    2f87:	cmp    r15,rax
    2f8a:	cmovge rcx,QWORD PTR [rip+0x2c6]        # 3258 <botlish_fn_45+0x3d0>
    2f92:	cmp    rcx,0x6
    2f96:	je     321b <botlish_fn_45+0x393>
    2f9c:	xor    eax,eax
    2f9e:	mov    rsi,QWORD PTR [rsp+0x68]
    2fa3:	test   rsi,0x7
    2faa:	jne    2fb9 <botlish_fn_45+0x131>
    2fb0:	movzx  rax,BYTE PTR [rsi]
    2fb4:	cmp    al,0x8
    2fb6:	sete   al
    2fb9:	test   al,al
    2fbb:	jne    2fdd <botlish_fn_45+0x155>
    2fc1:	mov    rdi,QWORD PTR [rsp+0x60]
    2fc6:	mov    rax,QWORD PTR [rdi+0x10]
    2fca:	mov    rcx,QWORD PTR [rax+0x20]
    2fce:	mov    edx,0x8
    2fd3:	call   2fd8 <botlish_fn_45+0x150>
			2fd4: R_X86_64_PLT32	rt_type_error-0x4
    2fd8:	jmp    317f <botlish_fn_45+0x2f7>
    2fdd:	mov    QWORD PTR [rsp+0x68],rsi
    2fe2:	mov    rdx,r15
    2fe5:	mov    rdi,QWORD PTR [rsp+0x60]
    2fea:	call   2fef <botlish_fn_45+0x167>
			2feb: R_X86_64_PLT32	rt_mutarray_get-0x4
    2fef:	test   rax,rax
    2ff2:	mov    rbx,rax
    2ff5:	je     317f <botlish_fn_45+0x2f7>
    2ffb:	mov    rdi,QWORD PTR [rsp+0x60]
    3000:	call   3005 <botlish_fn_45+0x17d>
			3001: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3005:	mov    rax,rbx
    3008:	test   rax,0x1
    300e:	jne    3034 <botlish_fn_45+0x1ac>
    3014:	mov    edx,0x3
    3019:	mov    rsi,rbx
    301c:	mov    rdi,QWORD PTR [rsp+0x60]
    3021:	call   3026 <botlish_fn_45+0x19e>
			3022: R_X86_64_PLT32	rt_value_eq-0x4
    3026:	test   rax,rax
    3029:	je     317f <botlish_fn_45+0x2f7>
    302f:	jmp    3048 <botlish_fn_45+0x1c0>
    3034:	mov    rsi,rbx
    3037:	mov    eax,0x2
    303c:	cmp    rsi,0x3
    3040:	cmove  rax,QWORD PTR [rip+0x210]        # 3258 <botlish_fn_45+0x3d0>
    3048:	cmp    rax,0x6
    304c:	je     3064 <botlish_fn_45+0x1dc>
    3052:	mov    rbx,QWORD PTR [rsp+0x88]
    305a:	mov    rsi,QWORD PTR [rsp+0x68]
    305f:	jmp    31bb <botlish_fn_45+0x333>
    3064:	xor    eax,eax
    3066:	mov    rdx,QWORD PTR [rsp+0x70]
    306b:	test   rdx,0x7
    3072:	je     3082 <botlish_fn_45+0x1fa>
    3078:	mov    QWORD PTR [rsp+0x70],rdx
    307d:	jmp    3090 <botlish_fn_45+0x208>
    3082:	movzx  rax,BYTE PTR [rdx]
    3086:	mov    QWORD PTR [rsp+0x70],rdx
    308b:	cmp    al,0x8
    308d:	sete   al
    3090:	test   al,al
    3092:	jne    30b9 <botlish_fn_45+0x231>
    3098:	mov    rdi,QWORD PTR [rsp+0x60]
    309d:	mov    rax,QWORD PTR [rdi+0x10]
    30a1:	mov    rcx,QWORD PTR [rax+0x20]
    30a5:	mov    edx,0x8
    30aa:	mov    rsi,QWORD PTR [rsp+0x70]
    30af:	call   30b4 <botlish_fn_45+0x22c>
			30b0: R_X86_64_PLT32	rt_type_error-0x4
    30b4:	jmp    317f <botlish_fn_45+0x2f7>
    30b9:	mov    rdx,r15
    30bc:	mov    rsi,QWORD PTR [rsp+0x70]
    30c1:	mov    rdi,QWORD PTR [rsp+0x60]
    30c6:	call   30cb <botlish_fn_45+0x243>
			30c7: R_X86_64_PLT32	rt_mutarray_get-0x4
    30cb:	test   rax,rax
    30ce:	je     317f <botlish_fn_45+0x2f7>
    30d4:	mov    QWORD PTR [rsp+0x50],rax
    30d9:	mov    rbx,rax
    30dc:	xor    eax,eax
    30de:	mov    rcx,QWORD PTR [rsp+0x78]
    30e3:	test   rcx,0x7
    30ea:	je     30fa <botlish_fn_45+0x272>
    30f0:	mov    QWORD PTR [rsp+0x78],rcx
    30f5:	jmp    3108 <botlish_fn_45+0x280>
    30fa:	movzx  rax,BYTE PTR [rcx]
    30fe:	mov    QWORD PTR [rsp+0x78],rcx
    3103:	cmp    al,0x8
    3105:	sete   al
    3108:	test   al,al
    310a:	jne    3131 <botlish_fn_45+0x2a9>
    3110:	mov    rdi,QWORD PTR [rsp+0x60]
    3115:	mov    rdx,QWORD PTR [rdi+0x10]
    3119:	mov    rcx,QWORD PTR [rdx+0x20]
    311d:	mov    edx,0x8
    3122:	mov    rsi,QWORD PTR [rsp+0x78]
    3127:	call   312c <botlish_fn_45+0x2a4>
			3128: R_X86_64_PLT32	rt_type_error-0x4
    312c:	jmp    317f <botlish_fn_45+0x2f7>
    3131:	mov    rdx,r15
    3134:	mov    rsi,QWORD PTR [rsp+0x78]
    3139:	mov    rdi,QWORD PTR [rsp+0x60]
    313e:	call   3143 <botlish_fn_45+0x2bb>
			313f: R_X86_64_PLT32	rt_mutarray_get-0x4
    3143:	test   rax,rax
    3146:	je     317f <botlish_fn_45+0x2f7>
    314c:	mov    QWORD PTR [rsp+0x58],rax
    3151:	mov    QWORD PTR [rsp],rax
    3155:	mov    r9,rbx
    3158:	mov    rbx,QWORD PTR [rsp+0x88]
    3160:	mov    rcx,r14
    3163:	mov    rdx,r13
    3166:	mov    rsi,r12
    3169:	mov    rdi,QWORD PTR [rsp+0x60]
    316e:	mov    r8,rbx
    3171:	call   3176 <botlish_fn_45+0x2ee>
			3172: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    3176:	test   rax,rax
    3179:	jne    31b6 <botlish_fn_45+0x32e>
    317f:	xor    rax,rax
    3182:	mov    rbx,QWORD PTR [rsp+0x90]
    318a:	mov    r12,QWORD PTR [rsp+0x98]
    3192:	mov    r13,QWORD PTR [rsp+0xa0]
    319a:	mov    r14,QWORD PTR [rsp+0xa8]
    31a2:	mov    r15,QWORD PTR [rsp+0xb0]
    31aa:	add    rsp,0xc0
    31b1:	mov    rsp,rbp
    31b4:	pop    rbp
    31b5:	ret
    31b6:	mov    rsi,QWORD PTR [rsp+0x68]
    31bb:	mov    rsi,QWORD PTR [rsp+0x68]
    31c0:	mov    QWORD PTR [rsp+0x10],rsi
    31c5:	mov    rsi,QWORD PTR [rsp+0x70]
    31ca:	mov    QWORD PTR [rsp+0x18],rsi
    31cf:	mov    rsi,QWORD PTR [rsp+0x78]
    31d4:	mov    QWORD PTR [rsp+0x20],rsi
    31d9:	sar    r15,1
    31dc:	add    r15,0x1
    31e3:	shl    r15,1
    31e6:	or     r15,0x1
    31ea:	mov    QWORD PTR [rsp+0x28],r15
    31ef:	mov    QWORD PTR [rsp+0x30],r12
    31f4:	mov    QWORD PTR [rsp+0x38],r13
    31f9:	mov    QWORD PTR [rsp+0x40],r14
    31fe:	mov    QWORD PTR [rsp+0x48],rbx
    3203:	mov    rsi,QWORD PTR [rsp+0x80]
    320b:	mov    r8,r15
    320e:	mov    QWORD PTR [rsp+0x88],rbx
    3216:	jmp    2f22 <botlish_fn_45+0x9a>
    321b:	mov    eax,0xa
    3220:	mov    rbx,QWORD PTR [rsp+0x90]
    3228:	mov    r12,QWORD PTR [rsp+0x98]
    3230:	mov    r13,QWORD PTR [rsp+0xa0]
    3238:	mov    r14,QWORD PTR [rsp+0xa8]
    3240:	mov    r15,QWORD PTR [rsp+0xb0]
    3248:	add    rsp,0xc0
    324f:	mov    rsp,rbp
    3252:	pop    rbp
    3253:	ret
    3254:	add    BYTE PTR [rax],al
    3256:	add    BYTE PTR [rax],al
    3258:	(bad)
    3259:	add    BYTE PTR [rax],al
    325b:	add    BYTE PTR [rax],al
    325d:	add    BYTE PTR [rax],al
	...

0000000000003260 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    3260:	push   rbp
    3261:	mov    rbp,rsp
    3264:	sub    rsp,0x30
    3268:	mov    QWORD PTR [rsp+0x20],r12
    326d:	mov    rsi,QWORD PTR [rdx]
    3270:	mov    rax,QWORD PTR [rdx+0x8]
    3274:	mov    rcx,QWORD PTR [rdx+0x10]
    3278:	mov    r8,QWORD PTR [rdx+0x18]
    327c:	mov    r9,QWORD PTR [rdx+0x20]
    3280:	mov    r10,QWORD PTR [rdx+0x28]
    3284:	mov    r11,QWORD PTR [rdx+0x30]
    3288:	mov    r12,QWORD PTR [rdx+0x38]
    328c:	mov    rdx,QWORD PTR [rdx+0x40]
    3290:	mov    QWORD PTR [rsp],r10
    3294:	mov    QWORD PTR [rsp+0x8],r11
    3299:	mov    QWORD PTR [rsp+0x10],r12
    329e:	mov    QWORD PTR [rsp+0x18],rdx
    32a3:	mov    rdx,rax
    32a6:	call   32ab <botlish_entry_45+0x4b>
			32a7: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    32ab:	mov    r12,QWORD PTR [rsp+0x20]
    32b0:	add    rsp,0x30
    32b4:	mov    rsp,rbp
    32b7:	pop    rbp
    32b8:	ret

00000000000032b9 <botlish_fn_46: ht_rehash<mutarray, int>>:
    32b9:	push   rbp
    32ba:	mov    rbp,rsp
    32bd:	sub    rsp,0xd0
    32c4:	mov    QWORD PTR [rsp+0xa0],rbx
    32cc:	mov    QWORD PTR [rsp+0xa8],r12
    32d4:	mov    QWORD PTR [rsp+0xb0],r13
    32dc:	mov    QWORD PTR [rsp+0xb8],r14
    32e4:	mov    QWORD PTR [rsp+0xc0],r15
    32ec:	mov    r13,rdi
    32ef:	mov    QWORD PTR [rsp+0x50],0x0
    32f8:	mov    QWORD PTR [rsp+0x58],0x0
    3301:	mov    QWORD PTR [rsp+0x60],0x0
    330a:	mov    QWORD PTR [rsp+0x68],0x0
    3313:	mov    QWORD PTR [rsp+0x20],rsi
    3318:	mov    r12,rsi
    331b:	mov    QWORD PTR [rsp+0x28],rdx
    3320:	mov    rbx,rdx
    3323:	mov    rsi,r12
    3326:	mov    rdi,r13
    3329:	call   332e <botlish_fn_46+0x75>
			332a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    332e:	test   rax,rax
    3331:	je     3500 <botlish_fn_46+0x247>
    3337:	mov    QWORD PTR [rsp+0x30],rax
    333c:	mov    r14,rax
    333f:	mov    rsi,r12
    3342:	mov    rdi,r13
    3345:	call   334a <botlish_fn_46+0x91>
			3346: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    334a:	test   rax,rax
    334d:	je     3500 <botlish_fn_46+0x247>
    3353:	mov    QWORD PTR [rsp+0x38],rax
    3358:	mov    r15,rax
    335b:	mov    rsi,r12
    335e:	mov    rdi,r13
    3361:	call   3366 <botlish_fn_46+0xad>
			3362: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    3366:	test   rax,rax
    3369:	je     3500 <botlish_fn_46+0x247>
    336f:	mov    QWORD PTR [rsp+0x40],rax
    3374:	mov    QWORD PTR [rsp+0x90],rax
    337c:	mov    rsi,r12
    337f:	mov    rdi,r13
    3382:	call   3387 <botlish_fn_46+0xce>
			3383: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3387:	test   rax,rax
    338a:	je     3500 <botlish_fn_46+0x247>
    3390:	mov    QWORD PTR [rsp+0x48],rax
    3395:	mov    QWORD PTR [rsp+0x88],rax
    339d:	mov    rsi,rbx
    33a0:	mov    rdi,r13
    33a3:	call   33a8 <botlish_fn_46+0xef>
			33a4: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    33a8:	mov    rcx,rax
    33ab:	mov    QWORD PTR [rsp+0x80],rax
    33b3:	test   rax,rcx
    33b6:	je     3500 <botlish_fn_46+0x247>
    33bc:	mov    rax,QWORD PTR [rsp+0x80]
    33c4:	mov    QWORD PTR [rsp+0x50],rax
    33c9:	mov    edx,0x1
    33ce:	mov    QWORD PTR [rsp+0x58],0x1
    33d7:	mov    rcx,rbx
    33da:	mov    rsi,QWORD PTR [rsp+0x80]
    33e2:	mov    rdi,r13
    33e5:	call   33ea <botlish_fn_46+0x131>
			33e6: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    33ea:	test   rax,rax
    33ed:	je     3500 <botlish_fn_46+0x247>
    33f3:	mov    rsi,rbx
    33f6:	mov    rdi,r13
    33f9:	call   33fe <botlish_fn_46+0x145>
			33fa: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    33fe:	test   rax,rax
    3401:	je     3500 <botlish_fn_46+0x247>
    3407:	mov    QWORD PTR [rsp+0x58],rax
    340c:	mov    QWORD PTR [rsp+0x78],rax
    3411:	mov    rsi,rbx
    3414:	mov    rdi,r13
    3417:	call   341c <botlish_fn_46+0x163>
			3418: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    341c:	test   rax,rax
    341f:	je     3500 <botlish_fn_46+0x247>
    3425:	mov    QWORD PTR [rsp+0x60],rax
    342a:	mov    r8d,0x1
    3430:	mov    QWORD PTR [rsp+0x68],0x1
    3439:	mov    rcx,QWORD PTR [rsp+0x80]
    3441:	mov    QWORD PTR [rsp],rcx
    3445:	mov    rcx,QWORD PTR [rsp+0x78]
    344a:	mov    QWORD PTR [rsp+0x8],rcx
    344f:	mov    QWORD PTR [rsp+0x10],rax
    3454:	mov    QWORD PTR [rsp+0x70],rax
    3459:	mov    QWORD PTR [rsp+0x18],rbx
    345e:	mov    rcx,QWORD PTR [rsp+0x90]
    3466:	mov    rdx,r15
    3469:	mov    rsi,r14
    346c:	mov    r9,QWORD PTR [rsp+0x88]
    3474:	mov    rdi,r13
    3477:	call   347c <botlish_fn_46+0x1c3>
			3478: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    347c:	test   rax,rax
    347f:	je     3500 <botlish_fn_46+0x247>
    3485:	mov    edx,0x1
    348a:	mov    rcx,QWORD PTR [rsp+0x80]
    3492:	mov    rsi,r12
    3495:	mov    rdi,r13
    3498:	call   349d <botlish_fn_46+0x1e4>
			3499: R_X86_64_PLT32	rt_mutarray_set-0x4
    349d:	test   rax,rax
    34a0:	je     3500 <botlish_fn_46+0x247>
    34a6:	mov    edx,0x3
    34ab:	mov    rcx,QWORD PTR [rsp+0x78]
    34b0:	mov    rsi,r12
    34b3:	mov    rdi,r13
    34b6:	call   34bb <botlish_fn_46+0x202>
			34b7: R_X86_64_PLT32	rt_mutarray_set-0x4
    34bb:	test   rax,rax
    34be:	je     3500 <botlish_fn_46+0x247>
    34c4:	mov    edx,0x5
    34c9:	mov    rcx,QWORD PTR [rsp+0x70]
    34ce:	mov    rsi,r12
    34d1:	mov    rdi,r13
    34d4:	call   34d9 <botlish_fn_46+0x220>
			34d5: R_X86_64_PLT32	rt_mutarray_set-0x4
    34d9:	test   rax,rax
    34dc:	je     3500 <botlish_fn_46+0x247>
    34e2:	mov    edx,0x9
    34e7:	mov    ecx,0x1
    34ec:	mov    rsi,r12
    34ef:	mov    rdi,r13
    34f2:	call   34f7 <botlish_fn_46+0x23e>
			34f3: R_X86_64_PLT32	rt_mutarray_set-0x4
    34f7:	test   rax,rax
    34fa:	jne    3537 <botlish_fn_46+0x27e>
    3500:	xor    rax,rax
    3503:	mov    rbx,QWORD PTR [rsp+0xa0]
    350b:	mov    r12,QWORD PTR [rsp+0xa8]
    3513:	mov    r13,QWORD PTR [rsp+0xb0]
    351b:	mov    r14,QWORD PTR [rsp+0xb8]
    3523:	mov    r15,QWORD PTR [rsp+0xc0]
    352b:	add    rsp,0xd0
    3532:	mov    rsp,rbp
    3535:	pop    rbp
    3536:	ret
    3537:	mov    eax,0xa
    353c:	mov    rbx,QWORD PTR [rsp+0xa0]
    3544:	mov    r12,QWORD PTR [rsp+0xa8]
    354c:	mov    r13,QWORD PTR [rsp+0xb0]
    3554:	mov    r14,QWORD PTR [rsp+0xb8]
    355c:	mov    r15,QWORD PTR [rsp+0xc0]
    3564:	add    rsp,0xd0
    356b:	mov    rsp,rbp
    356e:	pop    rbp
    356f:	ret

0000000000003570 <botlish_entry_46: ht_rehash<mutarray, int>>:
    3570:	push   rbp
    3571:	mov    rbp,rsp
    3574:	mov    rsi,QWORD PTR [rdx]
    3577:	mov    rdx,QWORD PTR [rdx+0x8]
    357b:	call   3580 <botlish_entry_46+0x10>
			357c: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    3580:	mov    rsp,rbp
    3583:	pop    rbp
    3584:	ret
    3585:	add    BYTE PTR [rax],al
	...

0000000000003588 <botlish_fn_47: ht_should_grow<mutarray>>:
    3588:	push   rbp
    3589:	mov    rbp,rsp
    358c:	sub    rsp,0x40
    3590:	mov    QWORD PTR [rsp+0x20],rbx
    3595:	mov    QWORD PTR [rsp+0x28],r12
    359a:	mov    QWORD PTR [rsp+0x30],r13
    359f:	mov    rbx,rdi
    35a2:	mov    QWORD PTR [rsp],rsi
    35a6:	mov    r12,rsi
    35a9:	mov    rsi,r12
    35ac:	mov    rdi,rbx
    35af:	call   35b4 <botlish_fn_47+0x2c>
			35b0: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    35b4:	mov    rcx,rax
    35b7:	mov    r13,rax
    35ba:	test   rax,rcx
    35bd:	je     37ac <botlish_fn_47+0x224>
    35c3:	mov    rax,r13
    35c6:	mov    QWORD PTR [rsp+0x8],rax
    35cb:	mov    rsi,r12
    35ce:	mov    rdi,rbx
    35d1:	call   35d6 <botlish_fn_47+0x4e>
			35d2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    35d6:	mov    rcx,rax
    35d9:	test   rcx,rcx
    35dc:	je     37ac <botlish_fn_47+0x224>
    35e2:	mov    QWORD PTR [rsp+0x10],rcx
    35e7:	mov    edx,0x1
    35ec:	mov    rax,r13
    35ef:	test   rax,0x1
    35f5:	jne    3618 <botlish_fn_47+0x90>
    35fb:	xor    edx,edx
    35fd:	mov    rax,r13
    3600:	test   rax,0x7
    3606:	jne    3618 <botlish_fn_47+0x90>
    360c:	mov    rax,r13
    360f:	movzx  rax,BYTE PTR [rax]
    3613:	cmp    al,0x1
    3615:	sete   dl
    3618:	test   dl,dl
    361a:	jne    363b <botlish_fn_47+0xb3>
    3620:	mov    rdi,rbx
    3623:	mov    rax,QWORD PTR [rdi+0x10]
    3627:	mov    rcx,QWORD PTR [rax+0x30]
    362b:	xor    rdx,rdx
    362e:	mov    rsi,r13
    3631:	call   3636 <botlish_fn_47+0xae>
			3632: R_X86_64_PLT32	rt_type_error-0x4
    3636:	jmp    37ac <botlish_fn_47+0x224>
    363b:	mov    eax,0x1
    3640:	test   rcx,0x1
    3647:	je     3655 <botlish_fn_47+0xcd>
    364d:	mov    r8,rcx
    3650:	jmp    3678 <botlish_fn_47+0xf0>
    3655:	xor    eax,eax
    3657:	test   rcx,0x7
    365e:	je     366c <botlish_fn_47+0xe4>
    3664:	mov    r8,rcx
    3667:	jmp    3678 <botlish_fn_47+0xf0>
    366c:	movzx  rax,BYTE PTR [rcx]
    3670:	mov    r8,rcx
    3673:	cmp    al,0x1
    3675:	sete   al
    3678:	test   al,al
    367a:	jne    369b <botlish_fn_47+0x113>
    3680:	mov    rdi,rbx
    3683:	mov    rax,QWORD PTR [rdi+0x10]
    3687:	mov    rcx,QWORD PTR [rax+0x30]
    368b:	xor    rdx,rdx
    368e:	mov    rsi,r8
    3691:	call   3696 <botlish_fn_47+0x10e>
			3692: R_X86_64_PLT32	rt_type_error-0x4
    3696:	jmp    37ac <botlish_fn_47+0x224>
    369b:	mov    rcx,r8
    369e:	mov    rsi,r13
    36a1:	mov    rax,rsi
    36a4:	and    rax,rcx
    36a7:	test   rax,0x1
    36ad:	jne    36be <botlish_fn_47+0x136>
    36b3:	mov    rdx,r8
    36b6:	mov    rsi,r13
    36b9:	jmp    36dc <botlish_fn_47+0x154>
    36be:	mov    rcx,r8
    36c1:	lea    rax,[rcx-0x1]
    36c5:	mov    rsi,r13
    36c8:	add    rsi,rax
    36cb:	seto   al
    36ce:	test   al,al
    36d0:	je     36e7 <botlish_fn_47+0x15f>
    36d6:	mov    rdx,r8
    36d9:	mov    rsi,r13
    36dc:	mov    rdi,rbx
    36df:	call   36e4 <botlish_fn_47+0x15c>
			36e0: R_X86_64_PLT32	rt_int_add-0x4
    36e4:	mov    rsi,rax
    36e7:	mov    QWORD PTR [rsp+0x8],rsi
    36ec:	mov    QWORD PTR [rsp+0x10],0x3
    36f5:	test   rsi,0x1
    36fc:	je     371f <botlish_fn_47+0x197>
    3702:	mov    rax,rsi
    3705:	add    rax,0x2
    3709:	mov    rcx,rax
    370c:	seto   al
    370f:	test   al,al
    3711:	jne    371f <botlish_fn_47+0x197>
    3717:	mov    rsi,rcx
    371a:	jmp    372f <botlish_fn_47+0x1a7>
    371f:	mov    edx,0x3
    3724:	mov    rdi,rbx
    3727:	call   372c <botlish_fn_47+0x1a4>
			3728: R_X86_64_PLT32	rt_int_add-0x4
    372c:	mov    rsi,rax
    372f:	mov    QWORD PTR [rsp+0x8],rsi
    3734:	mov    edx,0x7
    3739:	mov    rdi,rdx
    373c:	mov    QWORD PTR [rsp+0x10],0x7
    3745:	test   rsi,0x1
    374c:	jne    375a <botlish_fn_47+0x1d2>
    3752:	mov    rdx,rdi
    3755:	jmp    3786 <botlish_fn_47+0x1fe>
    375a:	mov    rax,rsi
    375d:	sar    rax,1
    3760:	imul   QWORD PTR [rip+0x119]        # 3880 <botlish_fn_47+0x2f8>
    3767:	seto   cl
    376a:	or     rax,0x1
    376e:	test   cl,cl
    3770:	je     377e <botlish_fn_47+0x1f6>
    3776:	mov    rdx,rdi
    3779:	jmp    3786 <botlish_fn_47+0x1fe>
    377e:	mov    rsi,rax
    3781:	jmp    3791 <botlish_fn_47+0x209>
    3786:	mov    rdi,rbx
    3789:	call   378e <botlish_fn_47+0x206>
			378a: R_X86_64_PLT32	rt_int_mul-0x4
    378e:	mov    rsi,rax
    3791:	mov    QWORD PTR [rsp],rsi
    3795:	mov    r13,rsi
    3798:	mov    rsi,r12
    379b:	mov    rdi,rbx
    379e:	call   37a3 <botlish_fn_47+0x21b>
			379f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    37a3:	test   rax,rax
    37a6:	jne    37c7 <botlish_fn_47+0x23f>
    37ac:	xor    rax,rax
    37af:	mov    rbx,QWORD PTR [rsp+0x20]
    37b4:	mov    r12,QWORD PTR [rsp+0x28]
    37b9:	mov    r13,QWORD PTR [rsp+0x30]
    37be:	add    rsp,0x40
    37c2:	mov    rsp,rbp
    37c5:	pop    rbp
    37c6:	ret
    37c7:	mov    QWORD PTR [rsp+0x8],rax
    37cc:	mov    QWORD PTR [rsp+0x10],0x5
    37d5:	test   rax,0x1
    37db:	mov    rsi,rax
    37de:	je     3810 <botlish_fn_47+0x288>
    37e4:	mov    rcx,rsi
    37e7:	mov    rax,rcx
    37ea:	sar    rax,1
    37ed:	imul   QWORD PTR [rip+0x94]        # 3888 <botlish_fn_47+0x300>
    37f4:	seto   dil
    37f8:	or     rax,0x1
    37fc:	test   dil,dil
    37ff:	jne    3810 <botlish_fn_47+0x288>
    3805:	mov    rdx,rax
    3808:	mov    rsi,r13
    380b:	jmp    3823 <botlish_fn_47+0x29b>
    3810:	mov    edx,0x5
    3815:	mov    rdi,rbx
    3818:	call   381d <botlish_fn_47+0x295>
			3819: R_X86_64_PLT32	rt_int_mul-0x4
    381d:	mov    rdx,rax
    3820:	mov    rsi,r13
    3823:	mov    r10,rsi
    3826:	and    r10,rdx
    3829:	test   r10,0x1
    3830:	jne    3857 <botlish_fn_47+0x2cf>
    3836:	mov    rdi,rbx
    3839:	call   383e <botlish_fn_47+0x2b6>
			383a: R_X86_64_PLT32	rt_int_cmp-0x4
    383e:	mov    r8d,0x2
    3844:	test   rax,rax
    3847:	mov    rax,r8
    384a:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3880 <botlish_fn_47+0x2f8>
    3852:	jmp    3867 <botlish_fn_47+0x2df>
    3857:	mov    eax,0x2
    385c:	cmp    rsi,rdx
    385f:	cmovg  rax,QWORD PTR [rip+0x19]        # 3880 <botlish_fn_47+0x2f8>
    3867:	mov    rbx,QWORD PTR [rsp+0x20]
    386c:	mov    r12,QWORD PTR [rsp+0x28]
    3871:	mov    r13,QWORD PTR [rsp+0x30]
    3876:	add    rsp,0x40
    387a:	mov    rsp,rbp
    387d:	pop    rbp
    387e:	ret
    387f:	add    BYTE PTR [rsi],al
    3881:	add    BYTE PTR [rax],al
    3883:	add    BYTE PTR [rax],al
    3885:	add    BYTE PTR [rax],al
    3887:	add    BYTE PTR [rax+rax*1],al
    388a:	add    BYTE PTR [rax],al
    388c:	add    BYTE PTR [rax],al
	...

0000000000003890 <botlish_entry_47: ht_should_grow<mutarray>>:
    3890:	push   rbp
    3891:	mov    rbp,rsp
    3894:	mov    rsi,QWORD PTR [rdx]
    3897:	call   389c <botlish_entry_47+0xc>
			3898: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    389c:	mov    rsp,rbp
    389f:	pop    rbp
    38a0:	ret
    38a1:	add    BYTE PTR [rax],al
    38a3:	add    BYTE PTR [rax],al
    38a5:	add    BYTE PTR [rax],al
	...

00000000000038a8 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    38a8:	push   rbp
    38a9:	mov    rbp,rsp
    38ac:	sub    rsp,0x40
    38b0:	mov    QWORD PTR [rsp+0x20],rbx
    38b5:	mov    QWORD PTR [rsp+0x28],r12
    38ba:	mov    QWORD PTR [rsp+0x30],r13
    38bf:	mov    rbx,rdi
    38c2:	mov    QWORD PTR [rsp+0x10],0x0
    38cb:	mov    QWORD PTR [rsp],rsi
    38cf:	mov    r12,rsi
    38d2:	mov    rsi,r12
    38d5:	mov    rdi,rbx
    38d8:	call   38dd <botlish_fn_48+0x35>
			38d9: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    38dd:	test   rax,rax
    38e0:	mov    r13,rax
    38e3:	je     3ad0 <botlish_fn_48+0x228>
    38e9:	mov    rsi,r12
    38ec:	mov    rdi,rbx
    38ef:	call   38f4 <botlish_fn_48+0x4c>
			38f0: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    38f4:	mov    rcx,rax
    38f7:	test   rcx,rcx
    38fa:	je     3ad0 <botlish_fn_48+0x228>
    3900:	mov    edx,0x1
    3905:	mov    rax,r13
    3908:	test   rax,0x1
    390e:	je     391c <botlish_fn_48+0x74>
    3914:	mov    r13,rax
    3917:	jmp    3940 <botlish_fn_48+0x98>
    391c:	xor    edx,edx
    391e:	test   rax,0x7
    3924:	je     3932 <botlish_fn_48+0x8a>
    392a:	mov    r13,rax
    392d:	jmp    3940 <botlish_fn_48+0x98>
    3932:	movzx  rdx,BYTE PTR [rax]
    3936:	mov    r13,rax
    3939:	rex cmp dl,0x1
    393d:	sete   dl
    3940:	test   dl,dl
    3942:	jne    3963 <botlish_fn_48+0xbb>
    3948:	mov    rdi,rbx
    394b:	mov    rsi,QWORD PTR [rdi+0x10]
    394f:	mov    rcx,QWORD PTR [rsi+0x38]
    3953:	xor    rdx,rdx
    3956:	mov    rsi,r13
    3959:	call   395e <botlish_fn_48+0xb6>
			395a: R_X86_64_PLT32	rt_type_error-0x4
    395e:	jmp    3ad0 <botlish_fn_48+0x228>
    3963:	mov    rsi,r13
    3966:	mov    eax,0x1
    396b:	test   rcx,0x1
    3972:	je     3980 <botlish_fn_48+0xd8>
    3978:	mov    r8,rcx
    397b:	jmp    39a5 <botlish_fn_48+0xfd>
    3980:	xor    eax,eax
    3982:	test   rcx,0x7
    3989:	je     3997 <botlish_fn_48+0xef>
    398f:	mov    r8,rcx
    3992:	jmp    39a5 <botlish_fn_48+0xfd>
    3997:	movzx  r11,BYTE PTR [rcx]
    399b:	mov    r8,rcx
    399e:	cmp    r11b,0x1
    39a2:	sete   al
    39a5:	test   al,al
    39a7:	jne    39c8 <botlish_fn_48+0x120>
    39ad:	mov    rdi,rbx
    39b0:	mov    rax,QWORD PTR [rdi+0x10]
    39b4:	mov    rcx,QWORD PTR [rax+0x38]
    39b8:	xor    rdx,rdx
    39bb:	mov    rsi,r8
    39be:	call   39c3 <botlish_fn_48+0x11b>
			39bf: R_X86_64_PLT32	rt_type_error-0x4
    39c3:	jmp    3ad0 <botlish_fn_48+0x228>
    39c8:	mov    rcx,r8
    39cb:	mov    rax,rsi
    39ce:	and    rax,rcx
    39d1:	test   rax,0x1
    39d7:	jne    39fd <botlish_fn_48+0x155>
    39dd:	mov    rdx,r8
    39e0:	mov    rdi,rbx
    39e3:	call   39e8 <botlish_fn_48+0x140>
			39e4: R_X86_64_PLT32	rt_int_cmp-0x4
    39e8:	mov    ecx,0x2
    39ed:	test   rax,rax
    39f0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3b08 <botlish_fn_48+0x260>
    39f8:	jmp    3a10 <botlish_fn_48+0x168>
    39fd:	mov    ecx,0x2
    3a02:	mov    r9,r8
    3a05:	cmp    rsi,r9
    3a08:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3b08 <botlish_fn_48+0x260>
    3a10:	cmp    rcx,0x6
    3a14:	je     3aa0 <botlish_fn_48+0x1f8>
    3a1a:	mov    rsi,r12
    3a1d:	mov    rdi,rbx
    3a20:	call   3a25 <botlish_fn_48+0x17d>
			3a21: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3a25:	test   rax,rax
    3a28:	je     3ad0 <botlish_fn_48+0x228>
    3a2e:	mov    QWORD PTR [rsp+0x8],rax
    3a33:	mov    QWORD PTR [rsp+0x10],0x5
    3a3c:	test   rax,0x1
    3a42:	mov    rsi,rax
    3a45:	je     3a72 <botlish_fn_48+0x1ca>
    3a4b:	mov    rcx,rsi
    3a4e:	mov    rax,rcx
    3a51:	sar    rax,1
    3a54:	imul   QWORD PTR [rip+0xb5]        # 3b10 <botlish_fn_48+0x268>
    3a5b:	seto   cl
    3a5e:	or     rax,0x1
    3a62:	test   cl,cl
    3a64:	jne    3a72 <botlish_fn_48+0x1ca>
    3a6a:	mov    rdx,rax
    3a6d:	jmp    3a82 <botlish_fn_48+0x1da>
    3a72:	mov    edx,0x5
    3a77:	mov    rdi,rbx
    3a7a:	call   3a7f <botlish_fn_48+0x1d7>
			3a7b: R_X86_64_PLT32	rt_int_mul-0x4
    3a7f:	mov    rdx,rax
    3a82:	mov    QWORD PTR [rsp+0x8],rdx
    3a87:	mov    rsi,r12
    3a8a:	mov    rdi,rbx
    3a8d:	call   3a92 <botlish_fn_48+0x1ea>
			3a8e: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    3a92:	test   rax,rax
    3a95:	je     3ad0 <botlish_fn_48+0x228>
    3a9b:	jmp    3aeb <botlish_fn_48+0x243>
    3aa0:	mov    rsi,r12
    3aa3:	mov    rdi,rbx
    3aa6:	call   3aab <botlish_fn_48+0x203>
			3aa7: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3aab:	test   rax,rax
    3aae:	je     3ad0 <botlish_fn_48+0x228>
    3ab4:	mov    QWORD PTR [rsp+0x8],rax
    3ab9:	mov    rdx,rax
    3abc:	mov    rsi,r12
    3abf:	mov    rdi,rbx
    3ac2:	call   3ac7 <botlish_fn_48+0x21f>
			3ac3: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    3ac7:	test   rax,rax
    3aca:	jne    3aeb <botlish_fn_48+0x243>
    3ad0:	xor    rax,rax
    3ad3:	mov    rbx,QWORD PTR [rsp+0x20]
    3ad8:	mov    r12,QWORD PTR [rsp+0x28]
    3add:	mov    r13,QWORD PTR [rsp+0x30]
    3ae2:	add    rsp,0x40
    3ae6:	mov    rsp,rbp
    3ae9:	pop    rbp
    3aea:	ret
    3aeb:	mov    rbx,QWORD PTR [rsp+0x20]
    3af0:	mov    r12,QWORD PTR [rsp+0x28]
    3af5:	mov    r13,QWORD PTR [rsp+0x30]
    3afa:	add    rsp,0x40
    3afe:	mov    rsp,rbp
    3b01:	pop    rbp
    3b02:	ret
    3b03:	add    BYTE PTR [rax],al
    3b05:	add    BYTE PTR [rax],al
    3b07:	add    BYTE PTR [rsi],al
    3b09:	add    BYTE PTR [rax],al
    3b0b:	add    BYTE PTR [rax],al
    3b0d:	add    BYTE PTR [rax],al
    3b0f:	add    BYTE PTR [rax+rax*1],al
    3b12:	add    BYTE PTR [rax],al
    3b14:	add    BYTE PTR [rax],al
	...

0000000000003b18 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    3b18:	push   rbp
    3b19:	mov    rbp,rsp
    3b1c:	mov    rsi,QWORD PTR [rdx]
    3b1f:	call   3b24 <botlish_entry_48+0xc>
			3b20: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    3b24:	mov    rsp,rbp
    3b27:	pop    rbp
    3b28:	ret
    3b29:	add    BYTE PTR [rax],al
    3b2b:	add    BYTE PTR [rax],al
    3b2d:	add    BYTE PTR [rax],al
	...

0000000000003b30 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    3b30:	push   rbp
    3b31:	mov    rbp,rsp
    3b34:	sub    rsp,0x70
    3b38:	mov    QWORD PTR [rsp+0x40],rbx
    3b3d:	mov    QWORD PTR [rsp+0x48],r12
    3b42:	mov    QWORD PTR [rsp+0x50],r13
    3b47:	mov    QWORD PTR [rsp+0x58],r14
    3b4c:	mov    QWORD PTR [rsp+0x60],r15
    3b51:	mov    rbx,rdi
    3b54:	mov    r14,r8
    3b57:	mov    r15,rdx
    3b5a:	mov    QWORD PTR [rsp+0x28],rcx
    3b5f:	mov    QWORD PTR [rsp],rsi
    3b63:	mov    r12,rsi
    3b66:	mov    rsi,r12
    3b69:	mov    rdi,rbx
    3b6c:	call   3b71 <botlish_fn_49+0x41>
			3b6d: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    3b71:	test   rax,rax
    3b74:	je     3ee0 <botlish_fn_49+0x3b0>
    3b7a:	xor    ecx,ecx
    3b7c:	test   rax,0x7
    3b82:	je     3b92 <botlish_fn_49+0x62>
    3b88:	mov    QWORD PTR [rsp+0x30],rax
    3b8d:	jmp    3ba2 <botlish_fn_49+0x72>
    3b92:	movzx  rcx,BYTE PTR [rax]
    3b96:	mov    QWORD PTR [rsp+0x30],rax
    3b9b:	rex cmp cl,0x8
    3b9f:	sete   cl
    3ba2:	test   cl,cl
    3ba4:	jne    3bc9 <botlish_fn_49+0x99>
    3baa:	mov    rdi,rbx
    3bad:	mov    rax,QWORD PTR [rdi+0x10]
    3bb1:	mov    rcx,QWORD PTR [rax+0x20]
    3bb5:	mov    edx,0x8
    3bba:	mov    rsi,QWORD PTR [rsp+0x30]
    3bbf:	call   3bc4 <botlish_fn_49+0x94>
			3bc0: R_X86_64_PLT32	rt_type_error-0x4
    3bc4:	jmp    3ee0 <botlish_fn_49+0x3b0>
    3bc9:	mov    rdx,r15
    3bcc:	mov    rsi,QWORD PTR [rsp+0x30]
    3bd1:	mov    rdi,rbx
    3bd4:	call   3bd9 <botlish_fn_49+0xa9>
			3bd5: R_X86_64_PLT32	rt_mutarray_get-0x4
    3bd9:	test   rax,rax
    3bdc:	je     3ee0 <botlish_fn_49+0x3b0>
    3be2:	mov    QWORD PTR [rsp+0x8],rax
    3be7:	mov    r13,rax
    3bea:	mov    rdi,rbx
    3bed:	call   3bf2 <botlish_fn_49+0xc2>
			3bee: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3bf2:	mov    ecx,0x3
    3bf7:	mov    rsi,QWORD PTR [rsp+0x30]
    3bfc:	mov    rdx,r15
    3bff:	mov    rdi,rbx
    3c02:	call   3c07 <botlish_fn_49+0xd7>
			3c03: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c07:	test   rax,rax
    3c0a:	je     3ee0 <botlish_fn_49+0x3b0>
    3c10:	mov    rsi,r12
    3c13:	mov    rdi,rbx
    3c16:	call   3c1b <botlish_fn_49+0xeb>
			3c17: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    3c1b:	test   rax,rax
    3c1e:	je     3ee0 <botlish_fn_49+0x3b0>
    3c24:	xor    ecx,ecx
    3c26:	test   rax,0x7
    3c2c:	je     3c3a <botlish_fn_49+0x10a>
    3c32:	mov    rsi,rax
    3c35:	jmp    3c48 <botlish_fn_49+0x118>
    3c3a:	movzx  rcx,BYTE PTR [rax]
    3c3e:	mov    rsi,rax
    3c41:	rex cmp cl,0x8
    3c45:	sete   cl
    3c48:	test   cl,cl
    3c4a:	jne    3c6a <botlish_fn_49+0x13a>
    3c50:	mov    rdi,rbx
    3c53:	mov    rax,QWORD PTR [rdi+0x10]
    3c57:	mov    rcx,QWORD PTR [rax+0x40]
    3c5b:	mov    edx,0x8
    3c60:	call   3c65 <botlish_fn_49+0x135>
			3c61: R_X86_64_PLT32	rt_type_error-0x4
    3c65:	jmp    3ee0 <botlish_fn_49+0x3b0>
    3c6a:	mov    rcx,QWORD PTR [rsp+0x28]
    3c6f:	mov    rdx,r15
    3c72:	mov    rdi,rbx
    3c75:	call   3c7a <botlish_fn_49+0x14a>
			3c76: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c7a:	test   rax,rax
    3c7d:	je     3ee0 <botlish_fn_49+0x3b0>
    3c83:	mov    rsi,r12
    3c86:	mov    rdi,rbx
    3c89:	call   3c8e <botlish_fn_49+0x15e>
			3c8a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    3c8e:	test   rax,rax
    3c91:	je     3ee0 <botlish_fn_49+0x3b0>
    3c97:	xor    esi,esi
    3c99:	test   rax,0x7
    3c9f:	jne    3cb1 <botlish_fn_49+0x181>
    3ca5:	movzx  rsi,BYTE PTR [rax]
    3ca9:	cmp    sil,0x8
    3cad:	sete   sil
    3cb1:	test   sil,sil
    3cb4:	jne    3cda <botlish_fn_49+0x1aa>
    3cba:	mov    rdi,rbx
    3cbd:	mov    rdi,QWORD PTR [rdi+0x10]
    3cc1:	mov    rcx,QWORD PTR [rdi+0x40]
    3cc5:	mov    edx,0x8
    3cca:	mov    rsi,rax
    3ccd:	mov    rdi,rbx
    3cd0:	call   3cd5 <botlish_fn_49+0x1a5>
			3cd1: R_X86_64_PLT32	rt_type_error-0x4
    3cd5:	jmp    3ee0 <botlish_fn_49+0x3b0>
    3cda:	mov    rcx,r14
    3cdd:	mov    rdx,r15
    3ce0:	mov    rsi,rax
    3ce3:	mov    rdi,rbx
    3ce6:	call   3ceb <botlish_fn_49+0x1bb>
			3ce7: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ceb:	test   rax,rax
    3cee:	je     3ee0 <botlish_fn_49+0x3b0>
    3cf4:	mov    QWORD PTR [rsp+0x10],0x7
    3cfd:	mov    rsi,r12
    3d00:	mov    rdi,rbx
    3d03:	call   3d08 <botlish_fn_49+0x1d8>
			3d04: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    3d08:	test   rax,rax
    3d0b:	je     3ee0 <botlish_fn_49+0x3b0>
    3d11:	mov    QWORD PTR [rsp+0x18],rax
    3d16:	mov    QWORD PTR [rsp+0x20],0x3
    3d1f:	mov    ecx,0x1
    3d24:	test   rax,0x1
    3d2a:	je     3d38 <botlish_fn_49+0x208>
    3d30:	mov    rsi,rax
    3d33:	jmp    3d5c <botlish_fn_49+0x22c>
    3d38:	xor    ecx,ecx
    3d3a:	test   rax,0x7
    3d40:	je     3d4e <botlish_fn_49+0x21e>
    3d46:	mov    rsi,rax
    3d49:	jmp    3d5c <botlish_fn_49+0x22c>
    3d4e:	movzx  rcx,BYTE PTR [rax]
    3d52:	mov    rsi,rax
    3d55:	rex cmp cl,0x1
    3d59:	sete   cl
    3d5c:	test   cl,cl
    3d5e:	jne    3d7c <botlish_fn_49+0x24c>
    3d64:	mov    rdi,rbx
    3d67:	mov    rax,QWORD PTR [rdi+0x10]
    3d6b:	mov    rcx,QWORD PTR [rax+0x30]
    3d6f:	xor    rdx,rdx
    3d72:	call   3d77 <botlish_fn_49+0x247>
			3d73: R_X86_64_PLT32	rt_type_error-0x4
    3d77:	jmp    3ee0 <botlish_fn_49+0x3b0>
    3d7c:	test   rsi,0x1
    3d83:	je     3d9b <botlish_fn_49+0x26b>
    3d89:	mov    rcx,rsi
    3d8c:	add    rcx,0x2
    3d90:	seto   al
    3d93:	test   al,al
    3d95:	je     3dab <botlish_fn_49+0x27b>
    3d9b:	mov    edx,0x3
    3da0:	mov    rdi,rbx
    3da3:	call   3da8 <botlish_fn_49+0x278>
			3da4: R_X86_64_PLT32	rt_int_add-0x4
    3da8:	mov    rcx,rax
    3dab:	mov    edx,0x7
    3db0:	mov    rsi,r12
    3db3:	mov    rdi,rbx
    3db6:	call   3dbb <botlish_fn_49+0x28b>
			3db7: R_X86_64_PLT32	rt_mutarray_set-0x4
    3dbb:	test   rax,rax
    3dbe:	je     3ee0 <botlish_fn_49+0x3b0>
    3dc4:	mov    rdi,rbx
    3dc7:	call   3dcc <botlish_fn_49+0x29c>
			3dc8: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3dcc:	mov    rax,r13
    3dcf:	test   rax,0x1
    3dd5:	jne    3df9 <botlish_fn_49+0x2c9>
    3ddb:	mov    edx,0x5
    3de0:	mov    rsi,r13
    3de3:	mov    rdi,rbx
    3de6:	call   3deb <botlish_fn_49+0x2bb>
			3de7: R_X86_64_PLT32	rt_value_eq-0x4
    3deb:	test   rax,rax
    3dee:	je     3ee0 <botlish_fn_49+0x3b0>
    3df4:	jmp    3e0d <botlish_fn_49+0x2dd>
    3df9:	mov    rsi,r13
    3dfc:	mov    eax,0x2
    3e01:	cmp    rsi,0x5
    3e05:	cmove  rax,QWORD PTR [rip+0x123]        # 3f30 <botlish_fn_49+0x400>
    3e0d:	cmp    rax,0x6
    3e11:	jne    3f05 <botlish_fn_49+0x3d5>
    3e17:	mov    QWORD PTR [rsp+0x8],0x9
    3e20:	mov    rsi,r12
    3e23:	mov    rdi,rbx
    3e26:	call   3e2b <botlish_fn_49+0x2fb>
			3e27: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3e2b:	test   rax,rax
    3e2e:	je     3ee0 <botlish_fn_49+0x3b0>
    3e34:	mov    QWORD PTR [rsp+0x10],rax
    3e39:	mov    QWORD PTR [rsp+0x18],0x3
    3e42:	mov    ecx,0x1
    3e47:	test   rax,0x1
    3e4d:	jne    3e6c <botlish_fn_49+0x33c>
    3e53:	xor    ecx,ecx
    3e55:	test   rax,0x7
    3e5b:	jne    3e6c <botlish_fn_49+0x33c>
    3e61:	movzx  rcx,BYTE PTR [rax]
    3e65:	rex cmp cl,0x1
    3e69:	sete   cl
    3e6c:	test   cl,cl
    3e6e:	jne    3e8f <botlish_fn_49+0x35f>
    3e74:	mov    rdi,rbx
    3e77:	mov    rsi,QWORD PTR [rdi+0x10]
    3e7b:	mov    rcx,QWORD PTR [rsi+0x48]
    3e7f:	xor    rdx,rdx
    3e82:	mov    rsi,rax
    3e85:	call   3e8a <botlish_fn_49+0x35a>
			3e86: R_X86_64_PLT32	rt_type_error-0x4
    3e8a:	jmp    3ee0 <botlish_fn_49+0x3b0>
    3e8f:	mov    rsi,rax
    3e92:	test   rsi,0x1
    3e99:	je     3eb7 <botlish_fn_49+0x387>
    3e9f:	mov    rdi,rsi
    3ea2:	sub    rdi,0x3
    3ea6:	seto   r8b
    3eaa:	lea    rcx,[rdi+0x1]
    3eae:	test   r8b,r8b
    3eb1:	je     3ec7 <botlish_fn_49+0x397>
    3eb7:	mov    edx,0x3
    3ebc:	mov    rdi,rbx
    3ebf:	call   3ec4 <botlish_fn_49+0x394>
			3ec0: R_X86_64_PLT32	rt_int_sub-0x4
    3ec4:	mov    rcx,rax
    3ec7:	mov    edx,0x9
    3ecc:	mov    rsi,r12
    3ecf:	mov    rdi,rbx
    3ed2:	call   3ed7 <botlish_fn_49+0x3a7>
			3ed3: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ed7:	test   rax,rax
    3eda:	jne    3f05 <botlish_fn_49+0x3d5>
    3ee0:	xor    rax,rax
    3ee3:	mov    rbx,QWORD PTR [rsp+0x40]
    3ee8:	mov    r12,QWORD PTR [rsp+0x48]
    3eed:	mov    r13,QWORD PTR [rsp+0x50]
    3ef2:	mov    r14,QWORD PTR [rsp+0x58]
    3ef7:	mov    r15,QWORD PTR [rsp+0x60]
    3efc:	add    rsp,0x70
    3f00:	mov    rsp,rbp
    3f03:	pop    rbp
    3f04:	ret
    3f05:	mov    eax,0xa
    3f0a:	mov    rbx,QWORD PTR [rsp+0x40]
    3f0f:	mov    r12,QWORD PTR [rsp+0x48]
    3f14:	mov    r13,QWORD PTR [rsp+0x50]
    3f19:	mov    r14,QWORD PTR [rsp+0x58]
    3f1e:	mov    r15,QWORD PTR [rsp+0x60]
    3f23:	add    rsp,0x70
    3f27:	mov    rsp,rbp
    3f2a:	pop    rbp
    3f2b:	ret
    3f2c:	add    BYTE PTR [rax],al
    3f2e:	add    BYTE PTR [rax],al
    3f30:	(bad)
    3f31:	add    BYTE PTR [rax],al
    3f33:	add    BYTE PTR [rax],al
    3f35:	add    BYTE PTR [rax],al
	...

0000000000003f38 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    3f38:	push   rbp
    3f39:	mov    rbp,rsp
    3f3c:	mov    rsi,QWORD PTR [rdx]
    3f3f:	mov    r9,QWORD PTR [rdx+0x8]
    3f43:	mov    rcx,QWORD PTR [rdx+0x10]
    3f47:	mov    r8,QWORD PTR [rdx+0x18]
    3f4b:	mov    rdx,r9
    3f4e:	call   3f53 <botlish_entry_49+0x1b>
			3f4f: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    3f53:	mov    rsp,rbp
    3f56:	pop    rbp
    3f57:	ret

0000000000003f58 <botlish_fn_50: ht_set<mutarray, any, any>>:
    3f58:	push   rbp
    3f59:	mov    rbp,rsp
    3f5c:	sub    rsp,0x70
    3f60:	mov    QWORD PTR [rsp+0x40],rbx
    3f65:	mov    QWORD PTR [rsp+0x48],r12
    3f6a:	mov    QWORD PTR [rsp+0x50],r13
    3f6f:	mov    QWORD PTR [rsp+0x58],r14
    3f74:	mov    QWORD PTR [rsp+0x60],r15
    3f79:	mov    rbx,rdi
    3f7c:	mov    r13,rdx
    3f7f:	mov    QWORD PTR [rsp],rsi
    3f83:	mov    r14,rsi
    3f86:	mov    QWORD PTR [rsp+0x8],rdx
    3f8b:	mov    QWORD PTR [rsp+0x10],rcx
    3f90:	mov    r12,rcx
    3f93:	mov    rdx,r13
    3f96:	mov    rsi,r14
    3f99:	mov    rdi,rbx
    3f9c:	call   3fa1 <botlish_fn_50+0x49>
			3f9d: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    3fa1:	test   rax,rax
    3fa4:	je     4228 <botlish_fn_50+0x2d0>
    3faa:	mov    QWORD PTR [rsp+0x18],rax
    3faf:	mov    rcx,rax
    3fb2:	mov    r8,0xffffffffffffffff
    3fb9:	mov    QWORD PTR [rsp+0x30],r8
    3fbe:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3fc7:	mov    rdx,r13
    3fca:	mov    rsi,r14
    3fcd:	mov    rdi,rbx
    3fd0:	call   3fd5 <botlish_fn_50+0x7d>
			3fd1: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    3fd5:	mov    rcx,rax
    3fd8:	mov    r15,rax
    3fdb:	test   rax,rcx
    3fde:	je     4228 <botlish_fn_50+0x2d0>
    3fe4:	mov    rax,r15
    3fe7:	mov    QWORD PTR [rsp+0x18],rax
    3fec:	mov    rsi,r14
    3fef:	mov    rdi,rbx
    3ff2:	call   3ff7 <botlish_fn_50+0x9f>
			3ff3: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    3ff7:	test   rax,rax
    3ffa:	je     4228 <botlish_fn_50+0x2d0>
    4000:	xor    ecx,ecx
    4002:	test   rax,0x7
    4008:	je     4016 <botlish_fn_50+0xbe>
    400e:	mov    r8,rax
    4011:	jmp    4024 <botlish_fn_50+0xcc>
    4016:	movzx  rcx,BYTE PTR [rax]
    401a:	mov    r8,rax
    401d:	rex cmp cl,0x8
    4021:	sete   cl
    4024:	test   cl,cl
    4026:	jne    4049 <botlish_fn_50+0xf1>
    402c:	mov    rdi,rbx
    402f:	mov    rsi,QWORD PTR [rdi+0x10]
    4033:	mov    rcx,QWORD PTR [rsi+0x20]
    4037:	mov    edx,0x8
    403c:	mov    rsi,r8
    403f:	call   4044 <botlish_fn_50+0xec>
			4040: R_X86_64_PLT32	rt_type_error-0x4
    4044:	jmp    4228 <botlish_fn_50+0x2d0>
    4049:	mov    rsi,r8
    404c:	mov    rdx,r15
    404f:	mov    rdi,rbx
    4052:	call   4057 <botlish_fn_50+0xff>
			4053: R_X86_64_PLT32	rt_mutarray_get-0x4
    4057:	test   rax,rax
    405a:	mov    QWORD PTR [rsp+0x28],rax
    405f:	je     4228 <botlish_fn_50+0x2d0>
    4065:	mov    rdi,rbx
    4068:	call   406d <botlish_fn_50+0x115>
			4069: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    406d:	mov    rax,QWORD PTR [rsp+0x28]
    4072:	test   rax,0x1
    4078:	jne    409e <botlish_fn_50+0x146>
    407e:	mov    edx,0x3
    4083:	mov    rsi,QWORD PTR [rsp+0x28]
    4088:	mov    rdi,rbx
    408b:	call   4090 <botlish_fn_50+0x138>
			408c: R_X86_64_PLT32	rt_value_eq-0x4
    4090:	test   rax,rax
    4093:	je     4228 <botlish_fn_50+0x2d0>
    4099:	jmp    40b4 <botlish_fn_50+0x15c>
    409e:	mov    rsi,QWORD PTR [rsp+0x28]
    40a3:	mov    eax,0x2
    40a8:	cmp    rsi,0x3
    40ac:	cmove  rax,QWORD PTR [rip+0x1c4]        # 4278 <botlish_fn_50+0x320>
    40b4:	cmp    rax,0x6
    40b8:	je     41b7 <botlish_fn_50+0x25f>
    40be:	mov    rsi,r14
    40c1:	mov    rdi,rbx
    40c4:	call   40c9 <botlish_fn_50+0x171>
			40c5: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    40c9:	test   rax,rax
    40cc:	je     4228 <botlish_fn_50+0x2d0>
    40d2:	cmp    rax,0x6
    40d6:	je     411b <botlish_fn_50+0x1c3>
    40dc:	mov    rcx,r13
    40df:	mov    rdx,r15
    40e2:	mov    rsi,r14
    40e5:	mov    rdi,rbx
    40e8:	mov    r8,r12
    40eb:	call   40f0 <botlish_fn_50+0x198>
			40ec: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    40f0:	test   rax,rax
    40f3:	je     4228 <botlish_fn_50+0x2d0>
    40f9:	mov    rbx,QWORD PTR [rsp+0x40]
    40fe:	mov    r12,QWORD PTR [rsp+0x48]
    4103:	mov    r13,QWORD PTR [rsp+0x50]
    4108:	mov    r14,QWORD PTR [rsp+0x58]
    410d:	mov    r15,QWORD PTR [rsp+0x60]
    4112:	add    rsp,0x70
    4116:	mov    rsp,rbp
    4119:	pop    rbp
    411a:	ret
    411b:	mov    rsi,r14
    411e:	mov    rdi,rbx
    4121:	call   4126 <botlish_fn_50+0x1ce>
			4122: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    4126:	test   rax,rax
    4129:	je     4228 <botlish_fn_50+0x2d0>
    412f:	mov    rdx,r13
    4132:	mov    rsi,r14
    4135:	mov    rdi,rbx
    4138:	call   413d <botlish_fn_50+0x1e5>
			4139: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    413d:	test   rax,rax
    4140:	je     4228 <botlish_fn_50+0x2d0>
    4146:	mov    QWORD PTR [rsp+0x18],rax
    414b:	mov    rcx,rax
    414e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4157:	mov    r8,QWORD PTR [rsp+0x30]
    415c:	mov    rdx,r13
    415f:	mov    rsi,r14
    4162:	mov    rdi,rbx
    4165:	call   416a <botlish_fn_50+0x212>
			4166: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    416a:	test   rax,rax
    416d:	je     4228 <botlish_fn_50+0x2d0>
    4173:	mov    QWORD PTR [rsp+0x18],rax
    4178:	mov    rcx,r13
    417b:	mov    rdx,rax
    417e:	mov    rsi,r14
    4181:	mov    rdi,rbx
    4184:	mov    r8,r12
    4187:	call   418c <botlish_fn_50+0x234>
			4188: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    418c:	test   rax,rax
    418f:	je     4228 <botlish_fn_50+0x2d0>
    4195:	mov    rbx,QWORD PTR [rsp+0x40]
    419a:	mov    r12,QWORD PTR [rsp+0x48]
    419f:	mov    r13,QWORD PTR [rsp+0x50]
    41a4:	mov    r14,QWORD PTR [rsp+0x58]
    41a9:	mov    r15,QWORD PTR [rsp+0x60]
    41ae:	add    rsp,0x70
    41b2:	mov    rsp,rbp
    41b5:	pop    rbp
    41b6:	ret
    41b7:	mov    rsi,r14
    41ba:	mov    rdi,rbx
    41bd:	call   41c2 <botlish_fn_50+0x26a>
			41be: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    41c2:	test   rax,rax
    41c5:	je     4228 <botlish_fn_50+0x2d0>
    41cb:	xor    ecx,ecx
    41cd:	test   rax,0x7
    41d3:	je     41e1 <botlish_fn_50+0x289>
    41d9:	mov    rsi,rax
    41dc:	jmp    41ef <botlish_fn_50+0x297>
    41e1:	movzx  rcx,BYTE PTR [rax]
    41e5:	mov    rsi,rax
    41e8:	rex cmp cl,0x8
    41ec:	sete   cl
    41ef:	test   cl,cl
    41f1:	jne    4211 <botlish_fn_50+0x2b9>
    41f7:	mov    rdi,rbx
    41fa:	mov    rax,QWORD PTR [rdi+0x10]
    41fe:	mov    rcx,QWORD PTR [rax+0x40]
    4202:	mov    edx,0x8
    4207:	call   420c <botlish_fn_50+0x2b4>
			4208: R_X86_64_PLT32	rt_type_error-0x4
    420c:	jmp    4228 <botlish_fn_50+0x2d0>
    4211:	mov    rcx,r12
    4214:	mov    rdx,r15
    4217:	mov    rdi,rbx
    421a:	call   421f <botlish_fn_50+0x2c7>
			421b: R_X86_64_PLT32	rt_mutarray_set-0x4
    421f:	test   rax,rax
    4222:	jne    424d <botlish_fn_50+0x2f5>
    4228:	xor    rax,rax
    422b:	mov    rbx,QWORD PTR [rsp+0x40]
    4230:	mov    r12,QWORD PTR [rsp+0x48]
    4235:	mov    r13,QWORD PTR [rsp+0x50]
    423a:	mov    r14,QWORD PTR [rsp+0x58]
    423f:	mov    r15,QWORD PTR [rsp+0x60]
    4244:	add    rsp,0x70
    4248:	mov    rsp,rbp
    424b:	pop    rbp
    424c:	ret
    424d:	mov    eax,0xa
    4252:	mov    rbx,QWORD PTR [rsp+0x40]
    4257:	mov    r12,QWORD PTR [rsp+0x48]
    425c:	mov    r13,QWORD PTR [rsp+0x50]
    4261:	mov    r14,QWORD PTR [rsp+0x58]
    4266:	mov    r15,QWORD PTR [rsp+0x60]
    426b:	add    rsp,0x70
    426f:	mov    rsp,rbp
    4272:	pop    rbp
    4273:	ret
    4274:	add    BYTE PTR [rax],al
    4276:	add    BYTE PTR [rax],al
    4278:	(bad)
    4279:	add    BYTE PTR [rax],al
    427b:	add    BYTE PTR [rax],al
    427d:	add    BYTE PTR [rax],al
	...

0000000000004280 <botlish_entry_50: ht_set<mutarray, any, any>>:
    4280:	push   rbp
    4281:	mov    rbp,rsp
    4284:	mov    rsi,QWORD PTR [rdx]
    4287:	mov    r8,QWORD PTR [rdx+0x8]
    428b:	mov    rcx,QWORD PTR [rdx+0x10]
    428f:	mov    rdx,r8
    4292:	call   4297 <botlish_entry_50+0x17>
			4293: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    4297:	mov    rsp,rbp
    429a:	pop    rbp
    429b:	ret

000000000000429c <botlish_fn_51: row_new<bool, int>>:
    429c:	push   rbp
    429d:	mov    rbp,rsp
    42a0:	sub    rsp,0x10
    42a4:	mov    QWORD PTR [rsp],rdx
    42a8:	mov    r8,rdx
    42ab:	cmp    rsi,0x6
    42af:	je     42cc <botlish_fn_51+0x30>
    42b5:	call   42ba <botlish_fn_51+0x1e>
			42b6: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    42ba:	test   rax,rax
    42bd:	je     42dd <botlish_fn_51+0x41>
    42c3:	add    rsp,0x10
    42c7:	mov    rsp,rbp
    42ca:	pop    rbp
    42cb:	ret
    42cc:	mov    rsi,r8
    42cf:	call   42d4 <botlish_fn_51+0x38>
			42d0: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    42d4:	test   rax,rax
    42d7:	jne    42e9 <botlish_fn_51+0x4d>
    42dd:	xor    rax,rax
    42e0:	add    rsp,0x10
    42e4:	mov    rsp,rbp
    42e7:	pop    rbp
    42e8:	ret
    42e9:	add    rsp,0x10
    42ed:	mov    rsp,rbp
    42f0:	pop    rbp
    42f1:	ret

00000000000042f2 <botlish_entry_51: row_new<bool, int>>:
    42f2:	push   rbp
    42f3:	mov    rbp,rsp
    42f6:	mov    rsi,QWORD PTR [rdx]
    42f9:	mov    rdx,QWORD PTR [rdx+0x8]
    42fd:	call   4302 <botlish_entry_51+0x10>
			42fe: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    4302:	mov    rsp,rbp
    4305:	pop    rbp
    4306:	ret
	...

0000000000004308 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    4308:	push   rbp
    4309:	mov    rbp,rsp
    430c:	sub    rsp,0x70
    4310:	mov    QWORD PTR [rsp+0x40],rbx
    4315:	mov    QWORD PTR [rsp+0x48],r12
    431a:	mov    QWORD PTR [rsp+0x50],r13
    431f:	mov    QWORD PTR [rsp+0x58],r14
    4324:	mov    QWORD PTR [rsp+0x60],r15
    4329:	mov    rbx,rdx
    432c:	mov    r15,rdi
    432f:	mov    QWORD PTR [rsp],rsi
    4333:	mov    r13,rsi
    4336:	mov    QWORD PTR [rsp+0x8],rdx
    433b:	mov    QWORD PTR [rsp+0x10],rcx
    4340:	mov    QWORD PTR [rsp+0x30],rcx
    4345:	mov    QWORD PTR [rsp+0x18],r8
    434a:	mov    r14,r9
    434d:	mov    rax,r14
    4350:	or     rax,0x1
    4354:	mov    r12,r8
    4357:	mov    rcx,r12
    435a:	and    rcx,rax
    435d:	test   rcx,0x1
    4364:	jne    4391 <botlish_fn_52+0x89>
    436a:	mov    rdx,r14
    436d:	or     rdx,0x1
    4371:	mov    rsi,r12
    4374:	mov    rdi,r15
    4377:	call   437c <botlish_fn_52+0x74>
			4378: R_X86_64_PLT32	rt_int_cmp-0x4
    437c:	mov    ecx,0x2
    4381:	test   rax,rax
    4384:	cmovge rcx,QWORD PTR [rip+0x20c]        # 4598 <botlish_fn_52+0x290>
    438c:	jmp    43a8 <botlish_fn_52+0xa0>
    4391:	mov    rdx,r14
    4394:	or     rdx,0x1
    4398:	mov    ecx,0x2
    439d:	cmp    r12,rdx
    43a0:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 4598 <botlish_fn_52+0x290>
    43a8:	cmp    rcx,0x6
    43ac:	je     4572 <botlish_fn_52+0x26a>
    43b2:	xor    ecx,ecx
    43b4:	mov    rdx,rbx
    43b7:	test   rdx,0x7
    43be:	jne    43d2 <botlish_fn_52+0xca>
    43c4:	mov    rdx,rbx
    43c7:	movzx  r9,BYTE PTR [rdx]
    43cb:	cmp    r9b,0x3
    43cf:	sete   cl
    43d2:	test   cl,cl
    43d4:	jne    43f7 <botlish_fn_52+0xef>
    43da:	mov    rdi,r15
    43dd:	mov    rax,QWORD PTR [rdi+0x10]
    43e1:	mov    rcx,QWORD PTR [rax+0x50]
    43e5:	mov    edx,0x4
    43ea:	mov    rsi,rbx
    43ed:	call   43f2 <botlish_fn_52+0xea>
			43ee: R_X86_64_PLT32	rt_type_error-0x4
    43f2:	jmp    451c <botlish_fn_52+0x214>
    43f7:	mov    rsi,rbx
    43fa:	test   r12,0x1
    4401:	jne    440f <botlish_fn_52+0x107>
    4407:	mov    rbx,rsi
    440a:	jmp    4425 <botlish_fn_52+0x11d>
    440f:	mov    rax,QWORD PTR [rsi+0x8]
    4413:	mov    rbx,rsi
    4416:	mov    rcx,r12
    4419:	sar    rcx,1
    441c:	cmp    rcx,rax
    441f:	jb     4444 <botlish_fn_52+0x13c>
    4425:	mov    rdx,r12
    4428:	mov    rsi,rbx
    442b:	mov    rdi,r15
    442e:	call   4433 <botlish_fn_52+0x12b>
			442f: R_X86_64_PLT32	rt_list_get-0x4
    4433:	test   rax,rax
    4436:	je     451c <botlish_fn_52+0x214>
    443c:	mov    rdx,rax
    443f:	jmp    444c <botlish_fn_52+0x144>
    4444:	mov    rax,QWORD PTR [rbx+0x10]
    4448:	mov    rdx,QWORD PTR [rax+rcx*8]
    444c:	mov    QWORD PTR [rsp+0x20],rdx
    4451:	mov    QWORD PTR [rsp+0x38],rdx
    4456:	xor    esi,esi
    4458:	mov    rcx,QWORD PTR [rsp+0x30]
    445d:	test   rcx,0x7
    4464:	je     4474 <botlish_fn_52+0x16c>
    446a:	mov    QWORD PTR [rsp+0x30],rcx
    446f:	jmp    4483 <botlish_fn_52+0x17b>
    4474:	movzx  rax,BYTE PTR [rcx]
    4478:	mov    QWORD PTR [rsp+0x30],rcx
    447d:	cmp    al,0x3
    447f:	sete   sil
    4483:	test   sil,sil
    4486:	jne    44ab <botlish_fn_52+0x1a3>
    448c:	mov    rdi,r15
    448f:	mov    rax,QWORD PTR [rdi+0x10]
    4493:	mov    rcx,QWORD PTR [rax+0x50]
    4497:	mov    edx,0x4
    449c:	mov    rsi,QWORD PTR [rsp+0x30]
    44a1:	call   44a6 <botlish_fn_52+0x19e>
			44a2: R_X86_64_PLT32	rt_type_error-0x4
    44a6:	jmp    451c <botlish_fn_52+0x214>
    44ab:	test   r12,0x1
    44b2:	je     44d0 <botlish_fn_52+0x1c8>
    44b8:	mov    rsi,QWORD PTR [rsp+0x30]
    44bd:	mov    rcx,QWORD PTR [rsi+0x8]
    44c1:	mov    rax,r12
    44c4:	sar    rax,1
    44c7:	cmp    rax,rcx
    44ca:	jb     44f1 <botlish_fn_52+0x1e9>
    44d0:	mov    rdx,r12
    44d3:	mov    rsi,QWORD PTR [rsp+0x30]
    44d8:	mov    rdi,r15
    44db:	call   44e0 <botlish_fn_52+0x1d8>
			44dc: R_X86_64_PLT32	rt_list_get-0x4
    44e0:	test   rax,rax
    44e3:	je     451c <botlish_fn_52+0x214>
    44e9:	mov    rcx,rax
    44ec:	jmp    44fe <botlish_fn_52+0x1f6>
    44f1:	mov    rsi,QWORD PTR [rsp+0x30]
    44f6:	mov    rcx,QWORD PTR [rsi+0x10]
    44fa:	mov    rcx,QWORD PTR [rcx+rax*8]
    44fe:	mov    QWORD PTR [rsp+0x28],rcx
    4503:	mov    rdx,QWORD PTR [rsp+0x38]
    4508:	mov    rsi,r13
    450b:	mov    rdi,r15
    450e:	call   4513 <botlish_fn_52+0x20b>
			450f: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    4513:	test   rax,rax
    4516:	jne    4541 <botlish_fn_52+0x239>
    451c:	xor    rax,rax
    451f:	mov    rbx,QWORD PTR [rsp+0x40]
    4524:	mov    r12,QWORD PTR [rsp+0x48]
    4529:	mov    r13,QWORD PTR [rsp+0x50]
    452e:	mov    r14,QWORD PTR [rsp+0x58]
    4533:	mov    r15,QWORD PTR [rsp+0x60]
    4538:	add    rsp,0x70
    453c:	mov    rsp,rbp
    453f:	pop    rbp
    4540:	ret
    4541:	mov    QWORD PTR [rsp],r13
    4545:	mov    QWORD PTR [rsp+0x8],rbx
    454a:	mov    rsi,QWORD PTR [rsp+0x30]
    454f:	mov    QWORD PTR [rsp+0x10],rsi
    4554:	sar    r12,1
    4557:	add    r12,0x1
    455e:	shl    r12,1
    4561:	or     r12,0x1
    4565:	mov    QWORD PTR [rsp+0x18],r12
    456a:	mov    r8,r12
    456d:	jmp    434d <botlish_fn_52+0x45>
    4572:	mov    rax,r13
    4575:	mov    rbx,QWORD PTR [rsp+0x40]
    457a:	mov    r12,QWORD PTR [rsp+0x48]
    457f:	mov    r13,QWORD PTR [rsp+0x50]
    4584:	mov    r14,QWORD PTR [rsp+0x58]
    4589:	mov    r15,QWORD PTR [rsp+0x60]
    458e:	add    rsp,0x70
    4592:	mov    rsp,rbp
    4595:	pop    rbp
    4596:	ret
    4597:	add    BYTE PTR [rsi],al
    4599:	add    BYTE PTR [rax],al
    459b:	add    BYTE PTR [rax],al
    459d:	add    BYTE PTR [rax],al
	...

00000000000045a0 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    45a0:	push   rbp
    45a1:	mov    rbp,rsp
    45a4:	mov    rsi,QWORD PTR [rdx]
    45a7:	mov    r10,QWORD PTR [rdx+0x8]
    45ab:	mov    rcx,QWORD PTR [rdx+0x10]
    45af:	mov    r8,QWORD PTR [rdx+0x18]
    45b3:	mov    r9,QWORD PTR [rdx+0x20]
    45b7:	mov    rdx,r10
    45ba:	call   45bf <botlish_entry_52+0x1f>
			45bb: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    45bf:	mov    rsp,rbp
    45c2:	pop    rbp
    45c3:	ret

00000000000045c4 <botlish_fn_53: row_table<any, int, any, bool>>:
    45c4:	push   rbp
    45c5:	mov    rbp,rsp
    45c8:	sub    rsp,0x50
    45cc:	mov    QWORD PTR [rsp+0x30],rbx
    45d1:	mov    QWORD PTR [rsp+0x38],r12
    45d6:	mov    QWORD PTR [rsp+0x40],r13
    45db:	mov    QWORD PTR [rsp+0x48],r14
    45e0:	mov    r12,rdi
    45e3:	mov    QWORD PTR [rsp+0x20],0x0
    45ec:	mov    QWORD PTR [rsp],rsi
    45f0:	mov    r13,rsi
    45f3:	mov    QWORD PTR [rsp+0x8],rdx
    45f8:	mov    QWORD PTR [rsp+0x10],rcx
    45fd:	mov    rbx,rcx
    4600:	mov    QWORD PTR [rsp+0x18],r8
    4605:	mov    rsi,r8
    4608:	mov    rdi,r12
    460b:	call   4610 <botlish_fn_53+0x4c>
			460c: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    4610:	test   rax,rax
    4613:	je     46a8 <botlish_fn_53+0xe4>
    4619:	mov    QWORD PTR [rsp+0x8],rax
    461e:	mov    r14,rax
    4621:	mov    QWORD PTR [rsp+0x18],0x1
    462a:	xor    eax,eax
    462c:	mov    rcx,rbx
    462f:	test   rcx,0x7
    4636:	je     4644 <botlish_fn_53+0x80>
    463c:	mov    rbx,rcx
    463f:	jmp    4650 <botlish_fn_53+0x8c>
    4644:	movzx  rax,BYTE PTR [rcx]
    4648:	mov    rbx,rcx
    464b:	cmp    al,0x3
    464d:	sete   al
    4650:	test   al,al
    4652:	jne    4675 <botlish_fn_53+0xb1>
    4658:	mov    rdi,r12
    465b:	mov    rax,QWORD PTR [rdi+0x10]
    465f:	mov    rcx,QWORD PTR [rax+0x58]
    4663:	mov    edx,0x4
    4668:	mov    rsi,rbx
    466b:	call   4670 <botlish_fn_53+0xac>
			466c: R_X86_64_PLT32	rt_type_error-0x4
    4670:	jmp    46a8 <botlish_fn_53+0xe4>
    4675:	mov    rsi,rbx
    4678:	mov    rdi,r12
    467b:	call   4680 <botlish_fn_53+0xbc>
			467c: R_X86_64_PLT32	rt_list_len-0x4
    4680:	mov    QWORD PTR [rsp+0x20],rax
    4685:	mov    r8d,0x1
    468b:	mov    rcx,rbx
    468e:	mov    rdx,r13
    4691:	mov    rsi,r14
    4694:	mov    rdi,r12
    4697:	mov    r9,rax
    469a:	call   469f <botlish_fn_53+0xdb>
			469b: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    469f:	test   rax,rax
    46a2:	jne    46c8 <botlish_fn_53+0x104>
    46a8:	xor    rax,rax
    46ab:	mov    rbx,QWORD PTR [rsp+0x30]
    46b0:	mov    r12,QWORD PTR [rsp+0x38]
    46b5:	mov    r13,QWORD PTR [rsp+0x40]
    46ba:	mov    r14,QWORD PTR [rsp+0x48]
    46bf:	add    rsp,0x50
    46c3:	mov    rsp,rbp
    46c6:	pop    rbp
    46c7:	ret
    46c8:	mov    rbx,QWORD PTR [rsp+0x30]
    46cd:	mov    r12,QWORD PTR [rsp+0x38]
    46d2:	mov    r13,QWORD PTR [rsp+0x40]
    46d7:	mov    r14,QWORD PTR [rsp+0x48]
    46dc:	add    rsp,0x50
    46e0:	mov    rsp,rbp
    46e3:	pop    rbp
    46e4:	ret

00000000000046e5 <botlish_entry_53: row_table<any, int, any, bool>>:
    46e5:	push   rbp
    46e6:	mov    rbp,rsp
    46e9:	mov    rsi,QWORD PTR [rdx]
    46ec:	mov    r9,QWORD PTR [rdx+0x8]
    46f0:	mov    rcx,QWORD PTR [rdx+0x10]
    46f4:	mov    r8,QWORD PTR [rdx+0x18]
    46f8:	mov    rdx,r9
    46fb:	call   4700 <botlish_entry_53+0x1b>
			46fc: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    4700:	mov    rsp,rbp
    4703:	pop    rbp
    4704:	ret
    4705:	add    BYTE PTR [rax],al
	...

0000000000004708 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4708:	push   rbp
    4709:	mov    rbp,rsp
    470c:	sub    rsp,0x90
    4713:	mov    QWORD PTR [rsp+0x60],rbx
    4718:	mov    QWORD PTR [rsp+0x68],r12
    471d:	mov    QWORD PTR [rsp+0x70],r13
    4722:	mov    QWORD PTR [rsp+0x78],r14
    4727:	mov    QWORD PTR [rsp+0x80],r15
    472f:	mov    r13,r8
    4732:	mov    QWORD PTR [rsp+0x40],rdi
    4737:	mov    r11,QWORD PTR [rbp+0x10]
    473b:	mov    r15,QWORD PTR [rbp+0x18]
    473f:	mov    QWORD PTR [rsp+0x30],0x0
    4748:	mov    QWORD PTR [rsp+0x38],0x0
    4751:	mov    QWORD PTR [rsp],rsi
    4755:	mov    QWORD PTR [rsp+0x8],rdx
    475a:	mov    r12,rdx
    475d:	mov    QWORD PTR [rsp+0x10],rcx
    4762:	mov    r14,rcx
    4765:	mov    QWORD PTR [rsp+0x18],r9
    476a:	mov    QWORD PTR [rsp+0x20],r11
    476f:	mov    QWORD PTR [rsp+0x50],r11
    4774:	mov    QWORD PTR [rsp+0x28],r15
    4779:	mov    rbx,rsi
    477c:	mov    QWORD PTR [rsp+0x48],r9
    4781:	mov    rsi,rbx
    4784:	mov    rdi,QWORD PTR [rsp+0x40]
    4789:	call   478e <botlish_fn_54+0x86>
			478a: R_X86_64_PLT32	rt_list_len-0x4
    478e:	mov    rcx,r12
    4791:	and    rcx,rax
    4794:	mov    rdx,rax
    4797:	test   rcx,0x1
    479e:	jne    47c6 <botlish_fn_54+0xbe>
    47a4:	mov    rsi,r12
    47a7:	mov    rdi,QWORD PTR [rsp+0x40]
    47ac:	call   47b1 <botlish_fn_54+0xa9>
			47ad: R_X86_64_PLT32	rt_int_cmp-0x4
    47b1:	mov    ecx,0x2
    47b6:	test   rax,rax
    47b9:	cmovge rcx,QWORD PTR [rip+0x177]        # 4938 <botlish_fn_54+0x230>
    47c1:	jmp    47d6 <botlish_fn_54+0xce>
    47c6:	mov    ecx,0x2
    47cb:	cmp    r12,rdx
    47ce:	cmovge rcx,QWORD PTR [rip+0x162]        # 4938 <botlish_fn_54+0x230>
    47d6:	cmp    rcx,0x6
    47da:	je     48c1 <botlish_fn_54+0x1b9>
    47e0:	mov    rax,r13
    47e3:	or     rax,0x1
    47e7:	mov    QWORD PTR [rsp+0x30],rax
    47ec:	test   r12,0x1
    47f3:	je     480c <botlish_fn_54+0x104>
    47f9:	mov    rcx,QWORD PTR [rbx+0x8]
    47fd:	mov    rax,r12
    4800:	sar    rax,1
    4803:	cmp    rax,rcx
    4806:	jb     482d <botlish_fn_54+0x125>
    480c:	mov    rdx,r12
    480f:	mov    rsi,rbx
    4812:	mov    rdi,QWORD PTR [rsp+0x40]
    4817:	call   481c <botlish_fn_54+0x114>
			4818: R_X86_64_PLT32	rt_list_get-0x4
    481c:	test   rax,rax
    481f:	je     48de <botlish_fn_54+0x1d6>
    4825:	mov    rcx,rax
    4828:	jmp    4835 <botlish_fn_54+0x12d>
    482d:	mov    rsi,QWORD PTR [rbx+0x10]
    4831:	mov    rcx,QWORD PTR [rsi+rax*8]
    4835:	mov    QWORD PTR [rsp+0x38],rcx
    483a:	mov    rdx,r13
    483d:	or     rdx,0x1
    4841:	mov    rsi,r14
    4844:	mov    rdi,QWORD PTR [rsp+0x40]
    4849:	mov    r8,r15
    484c:	call   4851 <botlish_fn_54+0x149>
			484d: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    4851:	test   rax,rax
    4854:	je     48de <botlish_fn_54+0x1d6>
    485a:	mov    QWORD PTR [rsp+0x8],rax
    485f:	mov    rcx,rax
    4862:	sar    r12,1
    4865:	add    r12,0x1
    486c:	shl    r12,1
    486f:	or     r12,0x1
    4873:	mov    QWORD PTR [rsp+0x30],r12
    4878:	mov    rdx,QWORD PTR [rsp+0x50]
    487d:	mov    rsi,QWORD PTR [rsp+0x48]
    4882:	mov    rdi,QWORD PTR [rsp+0x40]
    4887:	call   488c <botlish_fn_54+0x184>
			4888: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    488c:	test   rax,rax
    488f:	je     48de <botlish_fn_54+0x1d6>
    4895:	mov    QWORD PTR [rsp],rbx
    4899:	mov    QWORD PTR [rsp+0x8],r12
    489e:	mov    QWORD PTR [rsp+0x10],r14
    48a3:	mov    QWORD PTR [rsp+0x18],rax
    48a8:	mov    QWORD PTR [rsp+0x20],rdx
    48ad:	mov    QWORD PTR [rsp+0x28],r15
    48b2:	mov    QWORD PTR [rsp+0x48],rax
    48b7:	mov    QWORD PTR [rsp+0x50],rdx
    48bc:	jmp    4781 <botlish_fn_54+0x79>
    48c1:	mov    rdx,QWORD PTR [rsp+0x50]
    48c6:	mov    rsi,QWORD PTR [rsp+0x48]
    48cb:	mov    rdi,QWORD PTR [rsp+0x40]
    48d0:	call   48d5 <botlish_fn_54+0x1cd>
			48d1: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    48d5:	test   rax,rax
    48d8:	jne    4909 <botlish_fn_54+0x201>
    48de:	xor    rax,rax
    48e1:	mov    rbx,QWORD PTR [rsp+0x60]
    48e6:	mov    r12,QWORD PTR [rsp+0x68]
    48eb:	mov    r13,QWORD PTR [rsp+0x70]
    48f0:	mov    r14,QWORD PTR [rsp+0x78]
    48f5:	mov    r15,QWORD PTR [rsp+0x80]
    48fd:	add    rsp,0x90
    4904:	mov    rsp,rbp
    4907:	pop    rbp
    4908:	ret
    4909:	mov    rbx,QWORD PTR [rsp+0x60]
    490e:	mov    r12,QWORD PTR [rsp+0x68]
    4913:	mov    r13,QWORD PTR [rsp+0x70]
    4918:	mov    r14,QWORD PTR [rsp+0x78]
    491d:	mov    r15,QWORD PTR [rsp+0x80]
    4925:	add    rsp,0x90
    492c:	mov    rsp,rbp
    492f:	pop    rbp
    4930:	ret
    4931:	add    BYTE PTR [rax],al
    4933:	add    BYTE PTR [rax],al
    4935:	add    BYTE PTR [rax],al
    4937:	add    BYTE PTR [rsi],al
    4939:	add    BYTE PTR [rax],al
    493b:	add    BYTE PTR [rax],al
    493d:	add    BYTE PTR [rax],al
	...

0000000000004940 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4940:	push   rbp
    4941:	mov    rbp,rsp
    4944:	sub    rsp,0x10
    4948:	mov    rsi,QWORD PTR [rdx]
    494b:	mov    r10,QWORD PTR [rdx+0x8]
    494f:	mov    rcx,QWORD PTR [rdx+0x10]
    4953:	mov    r8,QWORD PTR [rdx+0x18]
    4957:	mov    r9,QWORD PTR [rdx+0x20]
    495b:	mov    r11,QWORD PTR [rdx+0x28]
    495f:	mov    rax,QWORD PTR [rdx+0x30]
    4963:	mov    QWORD PTR [rsp],r11
    4967:	mov    QWORD PTR [rsp+0x8],rax
    496c:	mov    rdx,r10
    496f:	call   4974 <botlish_entry_54+0x34>
			4970: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4974:	add    rsp,0x10
    4978:	mov    rsp,rbp
    497b:	pop    rbp
    497c:	ret

000000000000497d <botlish_fn_55: csv_records_generic<str, bool>>:
    497d:	push   rbp
    497e:	mov    rbp,rsp
    4981:	sub    rsp,0x80
    4988:	mov    QWORD PTR [rsp+0x50],rbx
    498d:	mov    QWORD PTR [rsp+0x58],r12
    4992:	mov    QWORD PTR [rsp+0x60],r13
    4997:	mov    QWORD PTR [rsp+0x68],r14
    499c:	mov    QWORD PTR [rsp+0x70],r15
    49a1:	mov    rbx,rdi
    49a4:	mov    QWORD PTR [rsp+0x20],0x0
    49ad:	mov    QWORD PTR [rsp+0x28],0x0
    49b6:	mov    QWORD PTR [rsp+0x30],0x0
    49bf:	mov    QWORD PTR [rsp+0x38],0x0
    49c8:	mov    QWORD PTR [rsp+0x40],0x0
    49d1:	mov    QWORD PTR [rsp+0x10],rsi
    49d6:	mov    QWORD PTR [rsp+0x18],rdx
    49db:	mov    r12,rdx
    49de:	mov    rdi,rbx
    49e1:	call   49e6 <botlish_fn_55+0x69>
			49e2: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    49e6:	mov    rcx,rax
    49e9:	mov    r13,rax
    49ec:	test   rax,rcx
    49ef:	je     4b35 <botlish_fn_55+0x1b8>
    49f5:	mov    rax,r13
    49f8:	mov    QWORD PTR [rsp+0x10],rax
    49fd:	mov    rsi,r13
    4a00:	mov    rdi,rbx
    4a03:	call   4a08 <botlish_fn_55+0x8b>
			4a04: R_X86_64_PLT32	rt_list_len-0x4
    4a08:	sar    rax,1
    4a0b:	test   rax,rax
    4a0e:	je     4b1e <botlish_fn_55+0x1a1>
    4a14:	mov    rax,r13
    4a17:	mov    rax,QWORD PTR [rax+0x8]
    4a1b:	test   rax,rax
    4a1e:	jne    4a45 <botlish_fn_55+0xc8>
    4a24:	mov    edx,0x1
    4a29:	mov    rsi,r13
    4a2c:	mov    rdi,rbx
    4a2f:	call   4a34 <botlish_fn_55+0xb7>
			4a30: R_X86_64_PLT32	rt_list_get-0x4
    4a34:	test   rax,rax
    4a37:	je     4b35 <botlish_fn_55+0x1b8>
    4a3d:	mov    rsi,rax
    4a40:	jmp    4a52 <botlish_fn_55+0xd5>
    4a45:	mov    rax,r13
    4a48:	mov    rcx,QWORD PTR [rax+0x10]
    4a4c:	mov    rax,QWORD PTR [rcx]
    4a4f:	mov    rsi,rax
    4a52:	mov    QWORD PTR [rsp+0x20],rsi
    4a57:	mov    QWORD PTR [rsp+0x28],0x3
    4a60:	xor    eax,eax
    4a62:	test   rsi,0x7
    4a69:	jne    4a78 <botlish_fn_55+0xfb>
    4a6f:	movzx  rax,BYTE PTR [rsi]
    4a73:	cmp    al,0x3
    4a75:	sete   al
    4a78:	test   al,al
    4a7a:	jne    4a9a <botlish_fn_55+0x11d>
    4a80:	mov    rdi,rbx
    4a83:	mov    rax,QWORD PTR [rdi+0x10]
    4a87:	mov    rcx,QWORD PTR [rax+0x58]
    4a8b:	mov    edx,0x4
    4a90:	call   4a95 <botlish_fn_55+0x118>
			4a91: R_X86_64_PLT32	rt_type_error-0x4
    4a95:	jmp    4b35 <botlish_fn_55+0x1b8>
    4a9a:	mov    r14,rsi
    4a9d:	mov    rdi,rbx
    4aa0:	call   4aa5 <botlish_fn_55+0x128>
			4aa1: R_X86_64_PLT32	rt_list_len-0x4
    4aa5:	mov    QWORD PTR [rsp+0x30],rax
    4aaa:	mov    r15,rax
    4aad:	mov    rdi,rbx
    4ab0:	call   4ab5 <botlish_fn_55+0x138>
			4ab1: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    4ab5:	test   rax,rax
    4ab8:	je     4b35 <botlish_fn_55+0x1b8>
    4abe:	mov    QWORD PTR [rsp+0x38],rax
    4ac3:	mov    r9,rax
    4ac6:	mov    QWORD PTR [rsp+0x40],rdx
    4acb:	mov    rax,rdx
    4ace:	mov    edx,0x3
    4ad3:	mov    QWORD PTR [rsp],rax
    4ad7:	mov    rax,r12
    4ada:	mov    QWORD PTR [rsp+0x8],rax
    4adf:	mov    rcx,r14
    4ae2:	mov    rsi,r13
    4ae5:	mov    rdi,rbx
    4ae8:	mov    r8,r15
    4aeb:	call   4af0 <botlish_fn_55+0x173>
			4aec: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4af0:	test   rax,rax
    4af3:	je     4b35 <botlish_fn_55+0x1b8>
    4af9:	mov    rbx,QWORD PTR [rsp+0x50]
    4afe:	mov    r12,QWORD PTR [rsp+0x58]
    4b03:	mov    r13,QWORD PTR [rsp+0x60]
    4b08:	mov    r14,QWORD PTR [rsp+0x68]
    4b0d:	mov    r15,QWORD PTR [rsp+0x70]
    4b12:	add    rsp,0x80
    4b19:	mov    rsp,rbp
    4b1c:	pop    rbp
    4b1d:	ret
    4b1e:	xor    rdx,rdx
    4b21:	mov    rdi,rbx
    4b24:	mov    rsi,rdx
    4b27:	call   4b2c <botlish_fn_55+0x1af>
			4b28: R_X86_64_PLT32	rt_list_new-0x4
    4b2c:	test   rax,rax
    4b2f:	jne    4b5d <botlish_fn_55+0x1e0>
    4b35:	xor    rax,rax
    4b38:	mov    rbx,QWORD PTR [rsp+0x50]
    4b3d:	mov    r12,QWORD PTR [rsp+0x58]
    4b42:	mov    r13,QWORD PTR [rsp+0x60]
    4b47:	mov    r14,QWORD PTR [rsp+0x68]
    4b4c:	mov    r15,QWORD PTR [rsp+0x70]
    4b51:	add    rsp,0x80
    4b58:	mov    rsp,rbp
    4b5b:	pop    rbp
    4b5c:	ret
    4b5d:	mov    rbx,QWORD PTR [rsp+0x50]
    4b62:	mov    r12,QWORD PTR [rsp+0x58]
    4b67:	mov    r13,QWORD PTR [rsp+0x60]
    4b6c:	mov    r14,QWORD PTR [rsp+0x68]
    4b71:	mov    r15,QWORD PTR [rsp+0x70]
    4b76:	add    rsp,0x80
    4b7d:	mov    rsp,rbp
    4b80:	pop    rbp
    4b81:	ret

0000000000004b82 <botlish_entry_55: csv_records_generic<str, bool>>:
    4b82:	push   rbp
    4b83:	mov    rbp,rsp
    4b86:	mov    rsi,QWORD PTR [rdx]
    4b89:	mov    rdx,QWORD PTR [rdx+0x8]
    4b8d:	call   4b92 <botlish_entry_55+0x10>
			4b8e: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4b92:	mov    rsp,rbp
    4b95:	pop    rbp
    4b96:	ret

0000000000004b97 <botlish_fn_56: csv_records<str>>:
    4b97:	push   rbp
    4b98:	mov    rbp,rsp
    4b9b:	sub    rsp,0x10
    4b9f:	mov    QWORD PTR [rsp],rsi
    4ba3:	mov    edx,0x2
    4ba8:	mov    QWORD PTR [rsp+0x8],0x2
    4bb1:	call   4bb6 <botlish_fn_56+0x1f>
			4bb2: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4bb6:	test   rax,rax
    4bb9:	jne    4bcb <botlish_fn_56+0x34>
    4bbf:	xor    rax,rax
    4bc2:	add    rsp,0x10
    4bc6:	mov    rsp,rbp
    4bc9:	pop    rbp
    4bca:	ret
    4bcb:	add    rsp,0x10
    4bcf:	mov    rsp,rbp
    4bd2:	pop    rbp
    4bd3:	ret

0000000000004bd4 <botlish_entry_56: csv_records<str>>:
    4bd4:	push   rbp
    4bd5:	mov    rbp,rsp
    4bd8:	mov    rsi,QWORD PTR [rdx]
    4bdb:	call   4be0 <botlish_entry_56+0xc>
			4bdc: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    4be0:	mov    rsp,rbp
    4be3:	pop    rbp
    4be4:	ret

0000000000004be5 <botlish_fn_57: csv_records_presized<str>>:
    4be5:	push   rbp
    4be6:	mov    rbp,rsp
    4be9:	sub    rsp,0x10
    4bed:	mov    QWORD PTR [rsp],rsi
    4bf1:	mov    edx,0x6
    4bf6:	mov    QWORD PTR [rsp+0x8],0x6
    4bff:	call   4c04 <botlish_fn_57+0x1f>
			4c00: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4c04:	test   rax,rax
    4c07:	jne    4c19 <botlish_fn_57+0x34>
    4c0d:	xor    rax,rax
    4c10:	add    rsp,0x10
    4c14:	mov    rsp,rbp
    4c17:	pop    rbp
    4c18:	ret
    4c19:	add    rsp,0x10
    4c1d:	mov    rsp,rbp
    4c20:	pop    rbp
    4c21:	ret

0000000000004c22 <botlish_entry_57: csv_records_presized<str>>:
    4c22:	push   rbp
    4c23:	mov    rbp,rsp
    4c26:	mov    rsi,QWORD PTR [rdx]
    4c29:	call   4c2e <botlish_entry_57+0xc>
			4c2a: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    4c2e:	mov    rsp,rbp
    4c31:	pop    rbp
    4c32:	ret
    4c33:	add    BYTE PTR [rax],al
    4c35:	add    BYTE PTR [rax],al
	...

0000000000004c38 <botlish_fn_58: sample<generic>>:
    4c38:	push   rbp
    4c39:	mov    rbp,rsp
    4c3c:	sub    rsp,0xc0
    4c43:	mov    QWORD PTR [rsp+0x90],rbx
    4c4b:	mov    QWORD PTR [rsp+0x98],r12
    4c53:	mov    QWORD PTR [rsp+0xa0],r13
    4c5b:	mov    QWORD PTR [rsp+0xa8],r14
    4c63:	mov    QWORD PTR [rsp+0xb0],r15
    4c6b:	mov    QWORD PTR [rsp+0x8],0x0
    4c74:	mov    QWORD PTR [rsp+0x10],0x0
    4c7d:	mov    QWORD PTR [rsp+0x18],0x0
    4c86:	mov    QWORD PTR [rsp+0x20],0x0
    4c8f:	mov    QWORD PTR [rsp+0x28],0x0
    4c98:	mov    QWORD PTR [rsp+0x30],0x0
    4ca1:	mov    QWORD PTR [rsp+0x38],0x0
    4caa:	mov    rax,QWORD PTR [rdi+0x10]
    4cae:	mov    r13,rdi
    4cb1:	mov    rsi,QWORD PTR [rax+0x60]
    4cb5:	mov    QWORD PTR [rsp],rsi
    4cb9:	call   4cbe <botlish_fn_58+0x86>
			4cba: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    4cbe:	mov    rsi,rax
    4cc1:	mov    r12,rax
    4cc4:	test   rax,rsi
    4cc7:	je     504c <botlish_fn_58+0x414>
    4ccd:	mov    rax,r12
    4cd0:	mov    QWORD PTR [rsp],rax
    4cd4:	mov    rdi,r13
    4cd7:	mov    rax,QWORD PTR [rdi+0x10]
    4cdb:	mov    rsi,QWORD PTR [rax+0x60]
    4cdf:	mov    QWORD PTR [rsp+0x8],rsi
    4ce4:	call   4ce9 <botlish_fn_58+0xb1>
			4ce5: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    4ce9:	mov    rbx,rax
    4cec:	test   rbx,rbx
    4cef:	je     504c <botlish_fn_58+0x414>
    4cf5:	mov    rax,r12
    4cf8:	mov    rax,QWORD PTR [rax+0x8]
    4cfc:	test   rax,rax
    4cff:	jne    4d26 <botlish_fn_58+0xee>
    4d05:	mov    edx,0x1
    4d0a:	mov    rsi,r12
    4d0d:	mov    rdi,r13
    4d10:	call   4d15 <botlish_fn_58+0xdd>
			4d11: R_X86_64_PLT32	rt_list_get-0x4
    4d15:	test   rax,rax
    4d18:	je     504c <botlish_fn_58+0x414>
    4d1e:	mov    rsi,rax
    4d21:	jmp    4d2e <botlish_fn_58+0xf6>
    4d26:	mov    rax,QWORD PTR [r12+0x10]
    4d2b:	mov    rsi,QWORD PTR [rax]
    4d2e:	mov    QWORD PTR [rsp+0x8],rsi
    4d33:	mov    r15,rsi
    4d36:	mov    rax,QWORD PTR [r12+0x8]
    4d3b:	cmp    rax,0x1
    4d3f:	ja     4d66 <botlish_fn_58+0x12e>
    4d45:	mov    edx,0x3
    4d4a:	mov    rsi,r12
    4d4d:	mov    rdi,r13
    4d50:	call   4d55 <botlish_fn_58+0x11d>
			4d51: R_X86_64_PLT32	rt_list_get-0x4
    4d55:	test   rax,rax
    4d58:	je     504c <botlish_fn_58+0x414>
    4d5e:	mov    rsi,rax
    4d61:	jmp    4d6f <botlish_fn_58+0x137>
    4d66:	mov    rax,QWORD PTR [r12+0x10]
    4d6b:	mov    rsi,QWORD PTR [rax+0x8]
    4d6f:	mov    QWORD PTR [rsp+0x10],rsi
    4d74:	mov    r14,rsi
    4d77:	mov    rax,QWORD PTR [rbx+0x8]
    4d7b:	mov    rsi,rbx
    4d7e:	test   rax,rax
    4d81:	jne    4da5 <botlish_fn_58+0x16d>
    4d87:	mov    edx,0x1
    4d8c:	mov    rdi,r13
    4d8f:	call   4d94 <botlish_fn_58+0x15c>
			4d90: R_X86_64_PLT32	rt_list_get-0x4
    4d94:	test   rax,rax
    4d97:	je     504c <botlish_fn_58+0x414>
    4d9d:	mov    rsi,rax
    4da0:	jmp    4dac <botlish_fn_58+0x174>
    4da5:	mov    rax,QWORD PTR [rsi+0x10]
    4da9:	mov    rsi,QWORD PTR [rax]
    4dac:	mov    QWORD PTR [rsp+0x18],rsi
    4db1:	mov    rdi,r13
    4db4:	mov    QWORD PTR [rsp+0x78],rsi
    4db9:	mov    rax,QWORD PTR [rdi+0x10]
    4dbd:	mov    rdx,QWORD PTR [rax+0x68]
    4dc1:	mov    QWORD PTR [rsp+0x20],rdx
    4dc6:	mov    rsi,r15
    4dc9:	call   4dce <botlish_fn_58+0x196>
			4dca: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4dce:	test   rax,rax
    4dd1:	je     504c <botlish_fn_58+0x414>
    4dd7:	mov    QWORD PTR [rsp+0x20],rax
    4ddc:	mov    rbx,rax
    4ddf:	mov    rdi,r13
    4de2:	mov    rax,QWORD PTR [rdi+0x10]
    4de6:	mov    rdx,QWORD PTR [rax+0x68]
    4dea:	mov    QWORD PTR [rsp+0x28],rdx
    4def:	mov    rsi,QWORD PTR [rsp+0x78]
    4df4:	call   4df9 <botlish_fn_58+0x1c1>
			4df5: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4df9:	test   rax,rax
    4dfc:	je     504c <botlish_fn_58+0x414>
    4e02:	mov    rcx,rbx
    4e05:	mov    rdx,rcx
    4e08:	and    rdx,rax
    4e0b:	test   rdx,0x1
    4e12:	jne    4e34 <botlish_fn_58+0x1fc>
    4e18:	mov    rdx,rax
    4e1b:	mov    rsi,rbx
    4e1e:	mov    rdi,r13
    4e21:	call   4e26 <botlish_fn_58+0x1ee>
			4e22: R_X86_64_PLT32	rt_value_eq-0x4
    4e26:	test   rax,rax
    4e29:	je     504c <botlish_fn_58+0x414>
    4e2f:	jmp    4e4a <botlish_fn_58+0x212>
    4e34:	mov    rdx,rax
    4e37:	mov    rsi,rbx
    4e3a:	mov    eax,0x2
    4e3f:	cmp    rsi,rdx
    4e42:	cmove  rax,QWORD PTR [rip+0x26e]        # 50b8 <botlish_fn_58+0x480>
    4e4a:	mov    ebx,0x6
    4e4f:	cmp    rax,0x6
    4e53:	je     4e6e <botlish_fn_58+0x236>
    4e59:	mov    ebx,0x2
    4e5e:	mov    QWORD PTR [rsp],0x2
    4e66:	mov    rsi,r12
    4e69:	jmp    4f0d <botlish_fn_58+0x2d5>
    4e6e:	mov    rsi,r15
    4e71:	mov    rdi,r13
    4e74:	call   4e79 <botlish_fn_58+0x241>
			4e75: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    4e79:	test   rax,rax
    4e7c:	mov    QWORD PTR [rsp+0x88],rax
    4e84:	je     504c <botlish_fn_58+0x414>
    4e8a:	mov    rsi,QWORD PTR [rsp+0x78]
    4e8f:	mov    rdi,r13
    4e92:	call   4e97 <botlish_fn_58+0x25f>
			4e93: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    4e97:	test   rax,rax
    4e9a:	je     504c <botlish_fn_58+0x414>
    4ea0:	mov    rcx,QWORD PTR [rsp+0x88]
    4ea8:	mov    rdx,rcx
    4eab:	and    rdx,rax
    4eae:	test   rdx,0x1
    4eb5:	jne    4edc <botlish_fn_58+0x2a4>
    4ebb:	mov    rdx,rax
    4ebe:	mov    rsi,QWORD PTR [rsp+0x88]
    4ec6:	mov    rdi,r13
    4ec9:	call   4ece <botlish_fn_58+0x296>
			4eca: R_X86_64_PLT32	rt_value_eq-0x4
    4ece:	test   rax,rax
    4ed1:	je     504c <botlish_fn_58+0x414>
    4ed7:	jmp    4ef7 <botlish_fn_58+0x2bf>
    4edc:	mov    rdx,rax
    4edf:	mov    rsi,QWORD PTR [rsp+0x88]
    4ee7:	mov    eax,0x2
    4eec:	cmp    rsi,rdx
    4eef:	cmove  rax,QWORD PTR [rip+0x1c1]        # 50b8 <botlish_fn_58+0x480>
    4ef7:	cmp    rax,0x6
    4efb:	je     4f06 <botlish_fn_58+0x2ce>
    4f01:	mov    ebx,0x2
    4f06:	mov    QWORD PTR [rsp],rbx
    4f0a:	mov    rsi,r12
    4f0d:	mov    rdi,r13
    4f10:	call   4f15 <botlish_fn_58+0x2dd>
			4f11: R_X86_64_PLT32	rt_list_len-0x4
    4f15:	mov    QWORD PTR [rsp+0x18],rax
    4f1a:	mov    rdi,r13
    4f1d:	mov    r12,rax
    4f20:	mov    rax,QWORD PTR [rdi+0x10]
    4f24:	mov    rdx,QWORD PTR [rax+0x68]
    4f28:	mov    QWORD PTR [rsp+0x20],rdx
    4f2d:	mov    rsi,r15
    4f30:	call   4f35 <botlish_fn_58+0x2fd>
			4f31: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4f35:	test   rax,rax
    4f38:	je     504c <botlish_fn_58+0x414>
    4f3e:	mov    QWORD PTR [rsp+0x20],rax
    4f43:	mov    rdi,r13
    4f46:	mov    QWORD PTR [rsp+0x88],rax
    4f4e:	mov    rax,QWORD PTR [rdi+0x10]
    4f52:	mov    rdx,QWORD PTR [rax+0x70]
    4f56:	mov    QWORD PTR [rsp+0x28],rdx
    4f5b:	mov    rsi,r15
    4f5e:	call   4f63 <botlish_fn_58+0x32b>
			4f5f: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4f63:	test   rax,rax
    4f66:	je     504c <botlish_fn_58+0x414>
    4f6c:	mov    QWORD PTR [rsp+0x28],rax
    4f71:	mov    rdi,r13
    4f74:	mov    QWORD PTR [rsp+0x80],rax
    4f7c:	mov    rax,QWORD PTR [rdi+0x10]
    4f80:	mov    rdx,QWORD PTR [rax+0x78]
    4f84:	mov    QWORD PTR [rsp+0x30],rdx
    4f89:	mov    rsi,r15
    4f8c:	call   4f91 <botlish_fn_58+0x359>
			4f8d: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4f91:	test   rax,rax
    4f94:	je     504c <botlish_fn_58+0x414>
    4f9a:	mov    QWORD PTR [rsp+0x8],rax
    4f9f:	mov    rdi,r13
    4fa2:	mov    r15,rax
    4fa5:	mov    rax,QWORD PTR [rdi+0x10]
    4fa9:	mov    rdx,QWORD PTR [rax+0x68]
    4fad:	mov    QWORD PTR [rsp+0x30],rdx
    4fb2:	mov    rsi,r14
    4fb5:	call   4fba <botlish_fn_58+0x382>
			4fb6: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4fba:	test   rax,rax
    4fbd:	je     504c <botlish_fn_58+0x414>
    4fc3:	mov    QWORD PTR [rsp+0x30],rax
    4fc8:	mov    rdi,r13
    4fcb:	mov    QWORD PTR [rsp+0x78],rax
    4fd0:	mov    rax,QWORD PTR [rdi+0x10]
    4fd4:	mov    rdx,QWORD PTR [rax+0x78]
    4fd8:	mov    QWORD PTR [rsp+0x38],rdx
    4fdd:	mov    rsi,r14
    4fe0:	call   4fe5 <botlish_fn_58+0x3ad>
			4fe1: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4fe5:	test   rax,rax
    4fe8:	je     504c <botlish_fn_58+0x414>
    4fee:	mov    QWORD PTR [rsp+0x10],rax
    4ff3:	lea    rdx,[rsp+0x40]
    4ff8:	mov    r9,r12
    4ffb:	mov    QWORD PTR [rsp+0x40],r9
    5000:	mov    rcx,QWORD PTR [rsp+0x88]
    5008:	mov    QWORD PTR [rsp+0x48],rcx
    500d:	mov    rcx,QWORD PTR [rsp+0x80]
    5015:	mov    QWORD PTR [rsp+0x50],rcx
    501a:	mov    rcx,r15
    501d:	mov    QWORD PTR [rsp+0x58],rcx
    5022:	mov    rcx,QWORD PTR [rsp+0x78]
    5027:	mov    QWORD PTR [rsp+0x60],rcx
    502c:	mov    QWORD PTR [rsp+0x68],rax
    5031:	mov    QWORD PTR [rsp+0x70],rbx
    5036:	mov    esi,0x7
    503b:	mov    rdi,r13
    503e:	call   5043 <botlish_fn_58+0x40b>
			503f: R_X86_64_PLT32	rt_list_new-0x4
    5043:	test   rax,rax
    5046:	jne    5083 <botlish_fn_58+0x44b>
    504c:	xor    rax,rax
    504f:	mov    rbx,QWORD PTR [rsp+0x90]
    5057:	mov    r12,QWORD PTR [rsp+0x98]
    505f:	mov    r13,QWORD PTR [rsp+0xa0]
    5067:	mov    r14,QWORD PTR [rsp+0xa8]
    506f:	mov    r15,QWORD PTR [rsp+0xb0]
    5077:	add    rsp,0xc0
    507e:	mov    rsp,rbp
    5081:	pop    rbp
    5082:	ret
    5083:	mov    rbx,QWORD PTR [rsp+0x90]
    508b:	mov    r12,QWORD PTR [rsp+0x98]
    5093:	mov    r13,QWORD PTR [rsp+0xa0]
    509b:	mov    r14,QWORD PTR [rsp+0xa8]
    50a3:	mov    r15,QWORD PTR [rsp+0xb0]
    50ab:	add    rsp,0xc0
    50b2:	mov    rsp,rbp
    50b5:	pop    rbp
    50b6:	ret
    50b7:	add    BYTE PTR [rsi],al
    50b9:	add    BYTE PTR [rax],al
    50bb:	add    BYTE PTR [rax],al
    50bd:	add    BYTE PTR [rax],al
	...

00000000000050c0 <botlish_entry_58: sample<generic>>:
    50c0:	push   rbp
    50c1:	mov    rbp,rsp
    50c4:	call   50c9 <botlish_entry_58+0x9>
			50c5: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    50c9:	mov    rsp,rbp
    50cc:	pop    rbp
    50cd:	ret

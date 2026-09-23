; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 21624  (per function: 45 78 357 381 272 272 272 81 365 430 584 770 351 695 456 171 388 524 70 493 114 61 125 61 125 61 125 61 125 61 168 168 179 179 245 245 804 1248 429 380 439 1113 766 817 665 1168 836 107 756 335 645 580 78 78 1222)
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
;   botlish_fn_16 / botlish_entry_16 -> ht_fill_empty<mutarray, int, int>
;   botlish_fn_17 / botlish_entry_17 -> ht_alloc<int>
;   botlish_fn_18 / botlish_entry_18 -> ht_new<generic>
;   botlish_fn_19 / botlish_entry_19 -> ht_capacity_for<int, int>
;   botlish_fn_20 / botlish_entry_20 -> ht_new_sized<int>
;   botlish_fn_21 / botlish_entry_21 -> ht_controls<mutarray>
;   botlish_fn_22 / botlish_entry_22 -> ht_controls<generic>
;   botlish_fn_23 / botlish_entry_23 -> ht_keys<mutarray>
;   botlish_fn_24 / botlish_entry_24 -> ht_keys<generic>
;   botlish_fn_25 / botlish_entry_25 -> ht_values<mutarray>
;   botlish_fn_26 / botlish_entry_26 -> ht_values<generic>
;   botlish_fn_27 / botlish_entry_27 -> ht_size<mutarray>
;   botlish_fn_28 / botlish_entry_28 -> ht_size<generic>
;   botlish_fn_29 / botlish_entry_29 -> ht_tombstones<mutarray>
;   botlish_fn_30 / botlish_entry_30 -> ht_capacity<mutarray>
;   botlish_fn_31 / botlish_entry_31 -> ht_capacity<generic>
;   botlish_fn_32 / botlish_entry_32 -> ht_probe_start<mutarray, any>
;   botlish_fn_33 / botlish_entry_33 -> ht_probe_start<any, str>
;   botlish_fn_34 / botlish_entry_34 -> ht_probe_next<mutarray, int>
;   botlish_fn_35 / botlish_entry_35 -> ht_probe_next<any, int>
;   botlish_fn_36 / botlish_entry_36 -> ht_find_get<any, str, int>
;   botlish_fn_37 / botlish_entry_37 -> ht_find_insert<mutarray, any, int, int>
;   botlish_fn_38 / botlish_entry_38 -> ht_get<any, str>
;   botlish_fn_39 / botlish_entry_39 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_40 / botlish_entry_40 -> ht_rehash_insert<list<mutarray>, int, any, any>
;   botlish_fn_41 / botlish_entry_41 -> ht_rehash_scan<list, int, int, list<mutarray>, int>
;   botlish_fn_42 / botlish_entry_42 -> ht_rehash<mutarray, int>
;   botlish_fn_43 / botlish_entry_43 -> ht_should_grow<mutarray>
;   botlish_fn_44 / botlish_entry_44 -> ht_grow_or_clean<mutarray>
;   botlish_fn_45 / botlish_entry_45 -> ht_place<mutarray, int, any, any>
;   botlish_fn_46 / botlish_entry_46 -> ht_set<mutarray, any, any>
;   botlish_fn_47 / botlish_entry_47 -> row_new<bool, int>
;   botlish_fn_48 / botlish_entry_48 -> row_fill<mutarray, any, any, int, int>
;   botlish_fn_49 / botlish_entry_49 -> row_table<any, int, any, bool>
;   botlish_fn_50 / botlish_entry_50 -> build_rows<list, int, any, int, list[mutarray, int], bool>
;   botlish_fn_51 / botlish_entry_51 -> csv_records_generic<str, bool>
;   botlish_fn_52 / botlish_entry_52 -> csv_records<str>
;   botlish_fn_53 / botlish_entry_53 -> csv_records_presized<str>
;   botlish_fn_54 / botlish_entry_54 -> sample<generic>


csv_records.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_54-0x4 ; sample<generic>
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
    148b:	add    BYTE PTR [rax],al
    148d:	add    BYTE PTR [rax],al
	...

0000000000001490 <botlish_fn_16: ht_fill_empty<mutarray, int, int>>:
    1490:	push   rbp
    1491:	mov    rbp,rsp
    1494:	sub    rsp,0x40
    1498:	mov    QWORD PTR [rsp+0x20],rbx
    149d:	mov    QWORD PTR [rsp+0x28],r12
    14a2:	mov    QWORD PTR [rsp+0x30],r13
    14a7:	mov    QWORD PTR [rsp+0x38],r14
    14ac:	mov    r13,rdi
    14af:	mov    QWORD PTR [rsp],rsi
    14b3:	mov    rbx,rsi
    14b6:	mov    QWORD PTR [rsp+0x8],rdx
    14bb:	mov    QWORD PTR [rsp+0x10],rcx
    14c0:	mov    r12,rcx
    14c3:	mov    rsi,rdx
    14c6:	mov    rax,rsi
    14c9:	and    rax,r12
    14cc:	mov    r14,rsi
    14cf:	test   rax,0x1
    14d5:	jne    14fe <botlish_fn_16+0x6e>
    14db:	mov    rdx,r12
    14de:	mov    rsi,r14
    14e1:	mov    rdi,r13
    14e4:	call   14e9 <botlish_fn_16+0x59>
			14e5: R_X86_64_PLT32	rt_int_cmp-0x4
    14e9:	mov    ecx,0x2
    14ee:	test   rax,rax
    14f1:	cmovge rcx,QWORD PTR [rip+0xdf]        # 15d8 <botlish_fn_16+0x148>
    14f9:	jmp    1511 <botlish_fn_16+0x81>
    14fe:	mov    ecx,0x2
    1503:	mov    rsi,r14
    1506:	cmp    rsi,r12
    1509:	cmovge rcx,QWORD PTR [rip+0xc7]        # 15d8 <botlish_fn_16+0x148>
    1511:	cmp    rcx,0x6
    1515:	je     15b6 <botlish_fn_16+0x126>
    151b:	mov    ecx,0x1
    1520:	mov    rdx,r14
    1523:	mov    rsi,rbx
    1526:	mov    rdi,r13
    1529:	call   152e <botlish_fn_16+0x9e>
			152a: R_X86_64_PLT32	rt_mutarray_set-0x4
    152e:	test   rax,rax
    1531:	jne    1557 <botlish_fn_16+0xc7>
    1537:	xor    rax,rax
    153a:	mov    rbx,QWORD PTR [rsp+0x20]
    153f:	mov    r12,QWORD PTR [rsp+0x28]
    1544:	mov    r13,QWORD PTR [rsp+0x30]
    1549:	mov    r14,QWORD PTR [rsp+0x38]
    154e:	add    rsp,0x40
    1552:	mov    rsp,rbp
    1555:	pop    rbp
    1556:	ret
    1557:	mov    QWORD PTR [rsp+0x18],0x3
    1560:	mov    rsi,r14
    1563:	test   rsi,0x1
    156a:	je     158d <botlish_fn_16+0xfd>
    1570:	mov    rsi,r14
    1573:	mov    rcx,rsi
    1576:	add    rcx,0x2
    157a:	seto   al
    157d:	test   al,al
    157f:	jne    158d <botlish_fn_16+0xfd>
    1585:	mov    r14,rcx
    1588:	jmp    15a0 <botlish_fn_16+0x110>
    158d:	mov    edx,0x3
    1592:	mov    rsi,r14
    1595:	mov    rdi,r13
    1598:	call   159d <botlish_fn_16+0x10d>
			1599: R_X86_64_PLT32	rt_int_add-0x4
    159d:	mov    r14,rax
    15a0:	mov    QWORD PTR [rsp],rbx
    15a4:	mov    rsi,r14
    15a7:	mov    QWORD PTR [rsp+0x8],rsi
    15ac:	mov    QWORD PTR [rsp+0x10],r12
    15b1:	jmp    14c6 <botlish_fn_16+0x36>
    15b6:	mov    eax,0xa
    15bb:	mov    rbx,QWORD PTR [rsp+0x20]
    15c0:	mov    r12,QWORD PTR [rsp+0x28]
    15c5:	mov    r13,QWORD PTR [rsp+0x30]
    15ca:	mov    r14,QWORD PTR [rsp+0x38]
    15cf:	add    rsp,0x40
    15d3:	mov    rsp,rbp
    15d6:	pop    rbp
    15d7:	ret
    15d8:	(bad)
    15d9:	add    BYTE PTR [rax],al
    15db:	add    BYTE PTR [rax],al
    15dd:	add    BYTE PTR [rax],al
	...

00000000000015e0 <botlish_entry_16: ht_fill_empty<mutarray, int, int>>:
    15e0:	push   rbp
    15e1:	mov    rbp,rsp
    15e4:	mov    rsi,QWORD PTR [rdx]
    15e7:	mov    r8,QWORD PTR [rdx+0x8]
    15eb:	mov    rcx,QWORD PTR [rdx+0x10]
    15ef:	mov    rdx,r8
    15f2:	call   15f7 <botlish_entry_16+0x17>
			15f3: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_fill_empty<mutarray, int, int>
    15f7:	mov    rsp,rbp
    15fa:	pop    rbp
    15fb:	ret

00000000000015fc <botlish_fn_17: ht_alloc<int>>:
    15fc:	push   rbp
    15fd:	mov    rbp,rsp
    1600:	sub    rsp,0x50
    1604:	mov    QWORD PTR [rsp+0x20],rbx
    1609:	mov    QWORD PTR [rsp+0x28],r12
    160e:	mov    QWORD PTR [rsp+0x30],r13
    1613:	mov    QWORD PTR [rsp+0x38],r14
    1618:	mov    QWORD PTR [rsp+0x40],r15
    161d:	mov    rbx,rdi
    1620:	mov    QWORD PTR [rsp+0x8],0x0
    1629:	mov    QWORD PTR [rsp+0x10],0x0
    1632:	mov    QWORD PTR [rsp+0x18],0x0
    163b:	mov    QWORD PTR [rsp],rsi
    163f:	mov    r13,rsi
    1642:	mov    rsi,r13
    1645:	mov    rdi,rbx
    1648:	call   164d <botlish_fn_17+0x51>
			1649: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    164d:	test   rax,rax
    1650:	je     176c <botlish_fn_17+0x170>
    1656:	mov    QWORD PTR [rsp+0x8],rax
    165b:	mov    r12,rax
    165e:	mov    edx,0x1
    1663:	mov    QWORD PTR [rsp+0x10],0x1
    166c:	mov    rcx,r13
    166f:	mov    rsi,r12
    1672:	mov    rdi,rbx
    1675:	call   167a <botlish_fn_17+0x7e>
			1676: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_fill_empty<mutarray, int, int>
    167a:	test   rax,rax
    167d:	je     176c <botlish_fn_17+0x170>
    1683:	mov    rsi,r13
    1686:	mov    rdi,rbx
    1689:	call   168e <botlish_fn_17+0x92>
			168a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    168e:	test   rax,rax
    1691:	je     176c <botlish_fn_17+0x170>
    1697:	mov    QWORD PTR [rsp+0x10],rax
    169c:	mov    rsi,r13
    169f:	mov    r14,rax
    16a2:	mov    rdi,rbx
    16a5:	call   16aa <botlish_fn_17+0xae>
			16a6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    16aa:	test   rax,rax
    16ad:	je     176c <botlish_fn_17+0x170>
    16b3:	mov    QWORD PTR [rsp],rax
    16b7:	mov    r13,rax
    16ba:	mov    esi,0xb
    16bf:	mov    QWORD PTR [rsp+0x18],0xb
    16c8:	mov    rdi,rbx
    16cb:	call   16d0 <botlish_fn_17+0xd4>
			16cc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    16d0:	test   rax,rax
    16d3:	mov    r15,rax
    16d6:	je     176c <botlish_fn_17+0x170>
    16dc:	mov    edx,0x1
    16e1:	mov    rcx,r12
    16e4:	mov    rsi,r15
    16e7:	mov    rdi,rbx
    16ea:	call   16ef <botlish_fn_17+0xf3>
			16eb: R_X86_64_PLT32	rt_mutarray_set-0x4
    16ef:	test   rax,rax
    16f2:	je     176c <botlish_fn_17+0x170>
    16f8:	mov    edx,0x3
    16fd:	mov    rcx,r14
    1700:	mov    rsi,r15
    1703:	mov    rdi,rbx
    1706:	call   170b <botlish_fn_17+0x10f>
			1707: R_X86_64_PLT32	rt_mutarray_set-0x4
    170b:	test   rax,rax
    170e:	je     176c <botlish_fn_17+0x170>
    1714:	mov    edx,0x5
    1719:	mov    rcx,r13
    171c:	mov    rsi,r15
    171f:	mov    rdi,rbx
    1722:	call   1727 <botlish_fn_17+0x12b>
			1723: R_X86_64_PLT32	rt_mutarray_set-0x4
    1727:	test   rax,rax
    172a:	je     176c <botlish_fn_17+0x170>
    1730:	mov    edx,0x7
    1735:	mov    ecx,0x1
    173a:	mov    rsi,r15
    173d:	mov    rdi,rbx
    1740:	call   1745 <botlish_fn_17+0x149>
			1741: R_X86_64_PLT32	rt_mutarray_set-0x4
    1745:	test   rax,rax
    1748:	je     176c <botlish_fn_17+0x170>
    174e:	mov    edx,0x9
    1753:	mov    ecx,0x1
    1758:	mov    rdi,rbx
    175b:	mov    rsi,r15
    175e:	call   1763 <botlish_fn_17+0x167>
			175f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1763:	test   rax,rax
    1766:	jne    1791 <botlish_fn_17+0x195>
    176c:	xor    rax,rax
    176f:	mov    rbx,QWORD PTR [rsp+0x20]
    1774:	mov    r12,QWORD PTR [rsp+0x28]
    1779:	mov    r13,QWORD PTR [rsp+0x30]
    177e:	mov    r14,QWORD PTR [rsp+0x38]
    1783:	mov    r15,QWORD PTR [rsp+0x40]
    1788:	add    rsp,0x50
    178c:	mov    rsp,rbp
    178f:	pop    rbp
    1790:	ret
    1791:	mov    rax,r15
    1794:	mov    rbx,QWORD PTR [rsp+0x20]
    1799:	mov    r12,QWORD PTR [rsp+0x28]
    179e:	mov    r13,QWORD PTR [rsp+0x30]
    17a3:	mov    r14,QWORD PTR [rsp+0x38]
    17a8:	mov    r15,QWORD PTR [rsp+0x40]
    17ad:	add    rsp,0x50
    17b1:	mov    rsp,rbp
    17b4:	pop    rbp
    17b5:	ret

00000000000017b6 <botlish_entry_17: ht_alloc<int>>:
    17b6:	push   rbp
    17b7:	mov    rbp,rsp
    17ba:	mov    rsi,QWORD PTR [rdx]
    17bd:	call   17c2 <botlish_entry_17+0xc>
			17be: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_alloc<int>
    17c2:	mov    rsp,rbp
    17c5:	pop    rbp
    17c6:	ret

00000000000017c7 <botlish_fn_18: ht_new<generic>>:
    17c7:	push   rbp
    17c8:	mov    rbp,rsp
    17cb:	sub    rsp,0x10
    17cf:	mov    esi,0x11
    17d4:	mov    QWORD PTR [rsp],0x11
    17dc:	call   17e1 <botlish_fn_18+0x1a>
			17dd: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_alloc<int>
    17e1:	test   rax,rax
    17e4:	jne    17f6 <botlish_fn_18+0x2f>
    17ea:	xor    rax,rax
    17ed:	add    rsp,0x10
    17f1:	mov    rsp,rbp
    17f4:	pop    rbp
    17f5:	ret
    17f6:	add    rsp,0x10
    17fa:	mov    rsp,rbp
    17fd:	pop    rbp
    17fe:	ret

00000000000017ff <botlish_entry_18: ht_new<generic>>:
    17ff:	push   rbp
    1800:	mov    rbp,rsp
    1803:	call   1808 <botlish_entry_18+0x9>
			1804: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_new<generic>
    1808:	mov    rsp,rbp
    180b:	pop    rbp
    180c:	ret
    180d:	add    BYTE PTR [rax],al
	...

0000000000001810 <botlish_fn_19: ht_capacity_for<int, int>>:
    1810:	push   rbp
    1811:	mov    rbp,rsp
    1814:	sub    rsp,0x50
    1818:	mov    QWORD PTR [rsp+0x20],rbx
    181d:	mov    QWORD PTR [rsp+0x28],r12
    1822:	mov    QWORD PTR [rsp+0x30],r13
    1827:	mov    QWORD PTR [rsp+0x38],r14
    182c:	mov    QWORD PTR [rsp+0x40],r15
    1831:	mov    r13,rdi
    1834:	mov    QWORD PTR [rsp],rdx
    1838:	mov    rbx,rsi
    183b:	or     rbx,0x1
    183f:	sar    rbx,1
    1842:	mov    r12,rsi
    1845:	mov    r14,rdx
    1848:	mov    rax,r12
    184b:	or     rax,0x1
    184f:	mov    QWORD PTR [rsp+0x8],rax
    1854:	mov    QWORD PTR [rsp+0x10],0x7
    185d:	mov    rax,rbx
    1860:	imul   QWORD PTR [rip+0x159]        # 19c0 <botlish_fn_19+0x1b0>
    1867:	seto   cl
    186a:	or     rax,0x1
    186e:	test   cl,cl
    1870:	jne    187e <botlish_fn_19+0x6e>
    1876:	mov    rsi,rax
    1879:	jmp    1895 <botlish_fn_19+0x85>
    187e:	mov    rsi,r12
    1881:	or     rsi,0x1
    1885:	mov    edx,0x7
    188a:	mov    rdi,r13
    188d:	call   1892 <botlish_fn_19+0x82>
			188e: R_X86_64_PLT32	rt_int_mul-0x4
    1892:	mov    rsi,rax
    1895:	mov    QWORD PTR [rsp+0x8],rsi
    189a:	mov    r15,rsi
    189d:	mov    QWORD PTR [rsp+0x10],0x5
    18a6:	mov    rsi,r14
    18a9:	test   rsi,0x1
    18b0:	je     18e0 <botlish_fn_19+0xd0>
    18b6:	mov    rsi,r14
    18b9:	mov    rax,rsi
    18bc:	sar    rax,1
    18bf:	imul   QWORD PTR [rip+0x102]        # 19c8 <botlish_fn_19+0x1b8>
    18c6:	seto   cl
    18c9:	or     rax,0x1
    18cd:	test   cl,cl
    18cf:	jne    18e0 <botlish_fn_19+0xd0>
    18d5:	mov    rdx,rax
    18d8:	mov    rsi,r15
    18db:	jmp    18f6 <botlish_fn_19+0xe6>
    18e0:	mov    edx,0x5
    18e5:	mov    rsi,r14
    18e8:	mov    rdi,r13
    18eb:	call   18f0 <botlish_fn_19+0xe0>
			18ec: R_X86_64_PLT32	rt_int_mul-0x4
    18f0:	mov    rdx,rax
    18f3:	mov    rsi,r15
    18f6:	mov    rax,rsi
    18f9:	and    rax,rdx
    18fc:	test   rax,0x1
    1902:	jne    1925 <botlish_fn_19+0x115>
    1908:	mov    rdi,r13
    190b:	call   1910 <botlish_fn_19+0x100>
			190c: R_X86_64_PLT32	rt_int_cmp-0x4
    1910:	mov    ecx,0x2
    1915:	test   rax,rax
    1918:	cmovle rcx,QWORD PTR [rip+0xa0]        # 19c0 <botlish_fn_19+0x1b0>
    1920:	jmp    1935 <botlish_fn_19+0x125>
    1925:	mov    ecx,0x2
    192a:	cmp    rsi,rdx
    192d:	cmovle rcx,QWORD PTR [rip+0x8b]        # 19c0 <botlish_fn_19+0x1b0>
    1935:	cmp    rcx,0x6
    1939:	je     1995 <botlish_fn_19+0x185>
    193f:	mov    QWORD PTR [rsp+0x8],0x5
    1948:	mov    rsi,r14
    194b:	test   rsi,0x1
    1952:	je     1979 <botlish_fn_19+0x169>
    1958:	mov    rsi,r14
    195b:	mov    rax,rsi
    195e:	sar    rax,1
    1961:	imul   QWORD PTR [rip+0x60]        # 19c8 <botlish_fn_19+0x1b8>
    1968:	seto   sil
    196c:	or     rax,0x1
    1970:	test   sil,sil
    1973:	je     1989 <botlish_fn_19+0x179>
    1979:	mov    edx,0x5
    197e:	mov    rsi,r14
    1981:	mov    rdi,r13
    1984:	call   1989 <botlish_fn_19+0x179>
			1985: R_X86_64_PLT32	rt_int_mul-0x4
    1989:	mov    QWORD PTR [rsp],rax
    198d:	mov    r14,rax
    1990:	jmp    1848 <botlish_fn_19+0x38>
    1995:	mov    rax,r14
    1998:	mov    rbx,QWORD PTR [rsp+0x20]
    199d:	mov    r12,QWORD PTR [rsp+0x28]
    19a2:	mov    r13,QWORD PTR [rsp+0x30]
    19a7:	mov    r14,QWORD PTR [rsp+0x38]
    19ac:	mov    r15,QWORD PTR [rsp+0x40]
    19b1:	add    rsp,0x50
    19b5:	mov    rsp,rbp
    19b8:	pop    rbp
    19b9:	ret
    19ba:	add    BYTE PTR [rax],al
    19bc:	add    BYTE PTR [rax],al
    19be:	add    BYTE PTR [rax],al
    19c0:	(bad)
    19c1:	add    BYTE PTR [rax],al
    19c3:	add    BYTE PTR [rax],al
    19c5:	add    BYTE PTR [rax],al
    19c7:	add    BYTE PTR [rax+rax*1],al
    19ca:	add    BYTE PTR [rax],al
    19cc:	add    BYTE PTR [rax],al
	...

00000000000019d0 <botlish_entry_19: ht_capacity_for<int, int>>:
    19d0:	push   rbp
    19d1:	mov    rbp,rsp
    19d4:	mov    rsi,QWORD PTR [rdx]
    19d7:	mov    rdx,QWORD PTR [rdx+0x8]
    19db:	call   19e0 <botlish_entry_19+0x10>
			19dc: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_capacity_for<int, int>
    19e0:	mov    rsp,rbp
    19e3:	pop    rbp
    19e4:	ret

00000000000019e5 <botlish_fn_20: ht_new_sized<int>>:
    19e5:	push   rbp
    19e6:	mov    rbp,rsp
    19e9:	sub    rsp,0x20
    19ed:	mov    QWORD PTR [rsp+0x10],r12
    19f2:	mov    r12,rdi
    19f5:	mov    QWORD PTR [rsp],rsi
    19f9:	mov    edx,0x11
    19fe:	mov    QWORD PTR [rsp+0x8],0x11
    1a07:	mov    rdi,r12
    1a0a:	call   1a0f <botlish_fn_20+0x2a>
			1a0b: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_capacity_for<int, int>
    1a0f:	mov    QWORD PTR [rsp],rax
    1a13:	mov    rsi,rax
    1a16:	mov    rdi,r12
    1a19:	call   1a1e <botlish_fn_20+0x39>
			1a1a: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_alloc<int>
    1a1e:	test   rax,rax
    1a21:	jne    1a38 <botlish_fn_20+0x53>
    1a27:	xor    rax,rax
    1a2a:	mov    r12,QWORD PTR [rsp+0x10]
    1a2f:	add    rsp,0x20
    1a33:	mov    rsp,rbp
    1a36:	pop    rbp
    1a37:	ret
    1a38:	mov    r12,QWORD PTR [rsp+0x10]
    1a3d:	add    rsp,0x20
    1a41:	mov    rsp,rbp
    1a44:	pop    rbp
    1a45:	ret

0000000000001a46 <botlish_entry_20: ht_new_sized<int>>:
    1a46:	push   rbp
    1a47:	mov    rbp,rsp
    1a4a:	mov    rsi,QWORD PTR [rdx]
    1a4d:	call   1a52 <botlish_entry_20+0xc>
			1a4e: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_new_sized<int>
    1a52:	mov    rsp,rbp
    1a55:	pop    rbp
    1a56:	ret

0000000000001a57 <botlish_fn_21: ht_controls<mutarray>>:
    1a57:	push   rbp
    1a58:	mov    rbp,rsp
    1a5b:	mov    edx,0x1
    1a60:	call   1a65 <botlish_fn_21+0xe>
			1a61: R_X86_64_PLT32	rt_mutarray_get-0x4
    1a65:	test   rax,rax
    1a68:	jne    1a76 <botlish_fn_21+0x1f>
    1a6e:	xor    rax,rax
    1a71:	mov    rsp,rbp
    1a74:	pop    rbp
    1a75:	ret
    1a76:	mov    rsp,rbp
    1a79:	pop    rbp
    1a7a:	ret

0000000000001a7b <botlish_entry_21: ht_controls<mutarray>>:
    1a7b:	push   rbp
    1a7c:	mov    rbp,rsp
    1a7f:	mov    rsi,QWORD PTR [rdx]
    1a82:	call   1a87 <botlish_entry_21+0xc>
			1a83: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    1a87:	mov    rsp,rbp
    1a8a:	pop    rbp
    1a8b:	ret

0000000000001a8c <botlish_fn_22: ht_controls<generic>>:
    1a8c:	push   rbp
    1a8d:	mov    rbp,rsp
    1a90:	xor    r8d,r8d
    1a93:	test   rsi,0x7
    1a9a:	jne    1aaa <botlish_fn_22+0x1e>
    1aa0:	movzx  rax,BYTE PTR [rsi]
    1aa4:	cmp    al,0x8
    1aa6:	sete   r8b
    1aaa:	test   r8b,r8b
    1aad:	jne    1aca <botlish_fn_22+0x3e>
    1ab3:	mov    rax,QWORD PTR [rdi+0x10]
    1ab7:	mov    rcx,QWORD PTR [rax+0x20]
    1abb:	mov    edx,0x8
    1ac0:	call   1ac5 <botlish_fn_22+0x39>
			1ac1: R_X86_64_PLT32	rt_type_error-0x4
    1ac5:	jmp    1add <botlish_fn_22+0x51>
    1aca:	mov    edx,0x1
    1acf:	call   1ad4 <botlish_fn_22+0x48>
			1ad0: R_X86_64_PLT32	rt_mutarray_get-0x4
    1ad4:	test   rax,rax
    1ad7:	jne    1ae5 <botlish_fn_22+0x59>
    1add:	xor    rax,rax
    1ae0:	mov    rsp,rbp
    1ae3:	pop    rbp
    1ae4:	ret
    1ae5:	mov    rsp,rbp
    1ae8:	pop    rbp
    1ae9:	ret

0000000000001aea <botlish_entry_22: ht_controls<generic>>:
    1aea:	push   rbp
    1aeb:	mov    rbp,rsp
    1aee:	mov    rsi,QWORD PTR [rdx]
    1af1:	call   1af6 <botlish_entry_22+0xc>
			1af2: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_controls<generic>
    1af6:	mov    rsp,rbp
    1af9:	pop    rbp
    1afa:	ret

0000000000001afb <botlish_fn_23: ht_keys<mutarray>>:
    1afb:	push   rbp
    1afc:	mov    rbp,rsp
    1aff:	mov    edx,0x3
    1b04:	call   1b09 <botlish_fn_23+0xe>
			1b05: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b09:	test   rax,rax
    1b0c:	jne    1b1a <botlish_fn_23+0x1f>
    1b12:	xor    rax,rax
    1b15:	mov    rsp,rbp
    1b18:	pop    rbp
    1b19:	ret
    1b1a:	mov    rsp,rbp
    1b1d:	pop    rbp
    1b1e:	ret

0000000000001b1f <botlish_entry_23: ht_keys<mutarray>>:
    1b1f:	push   rbp
    1b20:	mov    rbp,rsp
    1b23:	mov    rsi,QWORD PTR [rdx]
    1b26:	call   1b2b <botlish_entry_23+0xc>
			1b27: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    1b2b:	mov    rsp,rbp
    1b2e:	pop    rbp
    1b2f:	ret

0000000000001b30 <botlish_fn_24: ht_keys<generic>>:
    1b30:	push   rbp
    1b31:	mov    rbp,rsp
    1b34:	xor    r8d,r8d
    1b37:	test   rsi,0x7
    1b3e:	jne    1b4e <botlish_fn_24+0x1e>
    1b44:	movzx  rax,BYTE PTR [rsi]
    1b48:	cmp    al,0x8
    1b4a:	sete   r8b
    1b4e:	test   r8b,r8b
    1b51:	jne    1b6e <botlish_fn_24+0x3e>
    1b57:	mov    rax,QWORD PTR [rdi+0x10]
    1b5b:	mov    rcx,QWORD PTR [rax+0x20]
    1b5f:	mov    edx,0x8
    1b64:	call   1b69 <botlish_fn_24+0x39>
			1b65: R_X86_64_PLT32	rt_type_error-0x4
    1b69:	jmp    1b81 <botlish_fn_24+0x51>
    1b6e:	mov    edx,0x3
    1b73:	call   1b78 <botlish_fn_24+0x48>
			1b74: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b78:	test   rax,rax
    1b7b:	jne    1b89 <botlish_fn_24+0x59>
    1b81:	xor    rax,rax
    1b84:	mov    rsp,rbp
    1b87:	pop    rbp
    1b88:	ret
    1b89:	mov    rsp,rbp
    1b8c:	pop    rbp
    1b8d:	ret

0000000000001b8e <botlish_entry_24: ht_keys<generic>>:
    1b8e:	push   rbp
    1b8f:	mov    rbp,rsp
    1b92:	mov    rsi,QWORD PTR [rdx]
    1b95:	call   1b9a <botlish_entry_24+0xc>
			1b96: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_keys<generic>
    1b9a:	mov    rsp,rbp
    1b9d:	pop    rbp
    1b9e:	ret

0000000000001b9f <botlish_fn_25: ht_values<mutarray>>:
    1b9f:	push   rbp
    1ba0:	mov    rbp,rsp
    1ba3:	mov    edx,0x5
    1ba8:	call   1bad <botlish_fn_25+0xe>
			1ba9: R_X86_64_PLT32	rt_mutarray_get-0x4
    1bad:	test   rax,rax
    1bb0:	jne    1bbe <botlish_fn_25+0x1f>
    1bb6:	xor    rax,rax
    1bb9:	mov    rsp,rbp
    1bbc:	pop    rbp
    1bbd:	ret
    1bbe:	mov    rsp,rbp
    1bc1:	pop    rbp
    1bc2:	ret

0000000000001bc3 <botlish_entry_25: ht_values<mutarray>>:
    1bc3:	push   rbp
    1bc4:	mov    rbp,rsp
    1bc7:	mov    rsi,QWORD PTR [rdx]
    1bca:	call   1bcf <botlish_entry_25+0xc>
			1bcb: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    1bcf:	mov    rsp,rbp
    1bd2:	pop    rbp
    1bd3:	ret

0000000000001bd4 <botlish_fn_26: ht_values<generic>>:
    1bd4:	push   rbp
    1bd5:	mov    rbp,rsp
    1bd8:	xor    r8d,r8d
    1bdb:	test   rsi,0x7
    1be2:	jne    1bf2 <botlish_fn_26+0x1e>
    1be8:	movzx  rax,BYTE PTR [rsi]
    1bec:	cmp    al,0x8
    1bee:	sete   r8b
    1bf2:	test   r8b,r8b
    1bf5:	jne    1c12 <botlish_fn_26+0x3e>
    1bfb:	mov    rax,QWORD PTR [rdi+0x10]
    1bff:	mov    rcx,QWORD PTR [rax+0x20]
    1c03:	mov    edx,0x8
    1c08:	call   1c0d <botlish_fn_26+0x39>
			1c09: R_X86_64_PLT32	rt_type_error-0x4
    1c0d:	jmp    1c25 <botlish_fn_26+0x51>
    1c12:	mov    edx,0x5
    1c17:	call   1c1c <botlish_fn_26+0x48>
			1c18: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c1c:	test   rax,rax
    1c1f:	jne    1c2d <botlish_fn_26+0x59>
    1c25:	xor    rax,rax
    1c28:	mov    rsp,rbp
    1c2b:	pop    rbp
    1c2c:	ret
    1c2d:	mov    rsp,rbp
    1c30:	pop    rbp
    1c31:	ret

0000000000001c32 <botlish_entry_26: ht_values<generic>>:
    1c32:	push   rbp
    1c33:	mov    rbp,rsp
    1c36:	mov    rsi,QWORD PTR [rdx]
    1c39:	call   1c3e <botlish_entry_26+0xc>
			1c3a: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_values<generic>
    1c3e:	mov    rsp,rbp
    1c41:	pop    rbp
    1c42:	ret

0000000000001c43 <botlish_fn_27: ht_size<mutarray>>:
    1c43:	push   rbp
    1c44:	mov    rbp,rsp
    1c47:	mov    edx,0x7
    1c4c:	call   1c51 <botlish_fn_27+0xe>
			1c4d: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c51:	test   rax,rax
    1c54:	jne    1c62 <botlish_fn_27+0x1f>
    1c5a:	xor    rax,rax
    1c5d:	mov    rsp,rbp
    1c60:	pop    rbp
    1c61:	ret
    1c62:	mov    rsp,rbp
    1c65:	pop    rbp
    1c66:	ret

0000000000001c67 <botlish_entry_27: ht_size<mutarray>>:
    1c67:	push   rbp
    1c68:	mov    rbp,rsp
    1c6b:	mov    rsi,QWORD PTR [rdx]
    1c6e:	call   1c73 <botlish_entry_27+0xc>
			1c6f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    1c73:	mov    rsp,rbp
    1c76:	pop    rbp
    1c77:	ret

0000000000001c78 <botlish_fn_28: ht_size<generic>>:
    1c78:	push   rbp
    1c79:	mov    rbp,rsp
    1c7c:	xor    r8d,r8d
    1c7f:	test   rsi,0x7
    1c86:	jne    1c96 <botlish_fn_28+0x1e>
    1c8c:	movzx  rax,BYTE PTR [rsi]
    1c90:	cmp    al,0x8
    1c92:	sete   r8b
    1c96:	test   r8b,r8b
    1c99:	jne    1cb6 <botlish_fn_28+0x3e>
    1c9f:	mov    rax,QWORD PTR [rdi+0x10]
    1ca3:	mov    rcx,QWORD PTR [rax+0x20]
    1ca7:	mov    edx,0x8
    1cac:	call   1cb1 <botlish_fn_28+0x39>
			1cad: R_X86_64_PLT32	rt_type_error-0x4
    1cb1:	jmp    1cc9 <botlish_fn_28+0x51>
    1cb6:	mov    edx,0x7
    1cbb:	call   1cc0 <botlish_fn_28+0x48>
			1cbc: R_X86_64_PLT32	rt_mutarray_get-0x4
    1cc0:	test   rax,rax
    1cc3:	jne    1cd1 <botlish_fn_28+0x59>
    1cc9:	xor    rax,rax
    1ccc:	mov    rsp,rbp
    1ccf:	pop    rbp
    1cd0:	ret
    1cd1:	mov    rsp,rbp
    1cd4:	pop    rbp
    1cd5:	ret

0000000000001cd6 <botlish_entry_28: ht_size<generic>>:
    1cd6:	push   rbp
    1cd7:	mov    rbp,rsp
    1cda:	mov    rsi,QWORD PTR [rdx]
    1cdd:	call   1ce2 <botlish_entry_28+0xc>
			1cde: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    1ce2:	mov    rsp,rbp
    1ce5:	pop    rbp
    1ce6:	ret

0000000000001ce7 <botlish_fn_29: ht_tombstones<mutarray>>:
    1ce7:	push   rbp
    1ce8:	mov    rbp,rsp
    1ceb:	mov    edx,0x9
    1cf0:	call   1cf5 <botlish_fn_29+0xe>
			1cf1: R_X86_64_PLT32	rt_mutarray_get-0x4
    1cf5:	test   rax,rax
    1cf8:	jne    1d06 <botlish_fn_29+0x1f>
    1cfe:	xor    rax,rax
    1d01:	mov    rsp,rbp
    1d04:	pop    rbp
    1d05:	ret
    1d06:	mov    rsp,rbp
    1d09:	pop    rbp
    1d0a:	ret

0000000000001d0b <botlish_entry_29: ht_tombstones<mutarray>>:
    1d0b:	push   rbp
    1d0c:	mov    rbp,rsp
    1d0f:	mov    rsi,QWORD PTR [rdx]
    1d12:	call   1d17 <botlish_entry_29+0xc>
			1d13: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    1d17:	mov    rsp,rbp
    1d1a:	pop    rbp
    1d1b:	ret

0000000000001d1c <botlish_fn_30: ht_capacity<mutarray>>:
    1d1c:	push   rbp
    1d1d:	mov    rbp,rsp
    1d20:	sub    rsp,0x10
    1d24:	mov    QWORD PTR [rsp],rbx
    1d28:	mov    rbx,rdi
    1d2b:	mov    rdi,rbx
    1d2e:	call   1d33 <botlish_fn_30+0x17>
			1d2f: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    1d33:	test   rax,rax
    1d36:	je     1d80 <botlish_fn_30+0x64>
    1d3c:	xor    r8d,r8d
    1d3f:	test   rax,0x7
    1d45:	je     1d53 <botlish_fn_30+0x37>
    1d4b:	mov    rsi,rax
    1d4e:	jmp    1d62 <botlish_fn_30+0x46>
    1d53:	movzx  rcx,BYTE PTR [rax]
    1d57:	mov    rsi,rax
    1d5a:	rex cmp cl,0x8
    1d5e:	sete   r8b
    1d62:	test   r8b,r8b
    1d65:	jne    1d90 <botlish_fn_30+0x74>
    1d6b:	mov    rdi,rbx
    1d6e:	mov    rax,QWORD PTR [rdi+0x10]
    1d72:	mov    rcx,QWORD PTR [rax+0x28]
    1d76:	mov    edx,0x8
    1d7b:	call   1d80 <botlish_fn_30+0x64>
			1d7c: R_X86_64_PLT32	rt_type_error-0x4
    1d80:	xor    rax,rax
    1d83:	mov    rbx,QWORD PTR [rsp]
    1d87:	add    rsp,0x10
    1d8b:	mov    rsp,rbp
    1d8e:	pop    rbp
    1d8f:	ret
    1d90:	mov    rdi,rbx
    1d93:	call   1d98 <botlish_fn_30+0x7c>
			1d94: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1d98:	mov    rbx,QWORD PTR [rsp]
    1d9c:	add    rsp,0x10
    1da0:	mov    rsp,rbp
    1da3:	pop    rbp
    1da4:	ret

0000000000001da5 <botlish_entry_30: ht_capacity<mutarray>>:
    1da5:	push   rbp
    1da6:	mov    rbp,rsp
    1da9:	mov    rsi,QWORD PTR [rdx]
    1dac:	call   1db1 <botlish_entry_30+0xc>
			1dad: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    1db1:	mov    rsp,rbp
    1db4:	pop    rbp
    1db5:	ret

0000000000001db6 <botlish_fn_31: ht_capacity<generic>>:
    1db6:	push   rbp
    1db7:	mov    rbp,rsp
    1dba:	sub    rsp,0x10
    1dbe:	mov    QWORD PTR [rsp],rbx
    1dc2:	mov    rbx,rdi
    1dc5:	mov    rdi,rbx
    1dc8:	call   1dcd <botlish_fn_31+0x17>
			1dc9: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_controls<generic>
    1dcd:	test   rax,rax
    1dd0:	je     1e1a <botlish_fn_31+0x64>
    1dd6:	xor    r8d,r8d
    1dd9:	test   rax,0x7
    1ddf:	je     1ded <botlish_fn_31+0x37>
    1de5:	mov    rsi,rax
    1de8:	jmp    1dfc <botlish_fn_31+0x46>
    1ded:	movzx  rcx,BYTE PTR [rax]
    1df1:	mov    rsi,rax
    1df4:	rex cmp cl,0x8
    1df8:	sete   r8b
    1dfc:	test   r8b,r8b
    1dff:	jne    1e2a <botlish_fn_31+0x74>
    1e05:	mov    rdi,rbx
    1e08:	mov    rax,QWORD PTR [rdi+0x10]
    1e0c:	mov    rcx,QWORD PTR [rax+0x28]
    1e10:	mov    edx,0x8
    1e15:	call   1e1a <botlish_fn_31+0x64>
			1e16: R_X86_64_PLT32	rt_type_error-0x4
    1e1a:	xor    rax,rax
    1e1d:	mov    rbx,QWORD PTR [rsp]
    1e21:	add    rsp,0x10
    1e25:	mov    rsp,rbp
    1e28:	pop    rbp
    1e29:	ret
    1e2a:	mov    rdi,rbx
    1e2d:	call   1e32 <botlish_fn_31+0x7c>
			1e2e: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1e32:	mov    rbx,QWORD PTR [rsp]
    1e36:	add    rsp,0x10
    1e3a:	mov    rsp,rbp
    1e3d:	pop    rbp
    1e3e:	ret

0000000000001e3f <botlish_entry_31: ht_capacity<generic>>:
    1e3f:	push   rbp
    1e40:	mov    rbp,rsp
    1e43:	mov    rsi,QWORD PTR [rdx]
    1e46:	call   1e4b <botlish_entry_31+0xc>
			1e47: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_capacity<generic>
    1e4b:	mov    rsp,rbp
    1e4e:	pop    rbp
    1e4f:	ret

0000000000001e50 <botlish_fn_32: ht_probe_start<mutarray, any>>:
    1e50:	push   rbp
    1e51:	mov    rbp,rsp
    1e54:	sub    rsp,0x20
    1e58:	mov    QWORD PTR [rsp],r12
    1e5c:	mov    QWORD PTR [rsp+0x8],r13
    1e61:	mov    QWORD PTR [rsp+0x10],r14
    1e66:	mov    r12,rdi
    1e69:	mov    r14,rsi
    1e6c:	mov    rsi,rdx
    1e6f:	mov    rdi,r12
    1e72:	call   1e77 <botlish_fn_32+0x27>
			1e73: R_X86_64_PLT32	rt_hash-0x4
    1e77:	test   rax,rax
    1e7a:	mov    r13,rax
    1e7d:	je     1eae <botlish_fn_32+0x5e>
    1e83:	mov    rsi,r14
    1e86:	mov    rdi,r12
    1e89:	call   1e8e <botlish_fn_32+0x3e>
			1e8a: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    1e8e:	test   rax,rax
    1e91:	mov    rdx,rax
    1e94:	je     1eae <botlish_fn_32+0x5e>
    1e9a:	mov    rsi,r13
    1e9d:	mov    rdi,r12
    1ea0:	call   1ea5 <botlish_fn_32+0x55>
			1ea1: R_X86_64_PLT32	rt_int_mod-0x4
    1ea5:	test   rax,rax
    1ea8:	jne    1ec8 <botlish_fn_32+0x78>
    1eae:	xor    rax,rax
    1eb1:	mov    r12,QWORD PTR [rsp]
    1eb5:	mov    r13,QWORD PTR [rsp+0x8]
    1eba:	mov    r14,QWORD PTR [rsp+0x10]
    1ebf:	add    rsp,0x20
    1ec3:	mov    rsp,rbp
    1ec6:	pop    rbp
    1ec7:	ret
    1ec8:	mov    r12,QWORD PTR [rsp]
    1ecc:	mov    r13,QWORD PTR [rsp+0x8]
    1ed1:	mov    r14,QWORD PTR [rsp+0x10]
    1ed6:	add    rsp,0x20
    1eda:	mov    rsp,rbp
    1edd:	pop    rbp
    1ede:	ret

0000000000001edf <botlish_entry_32: ht_probe_start<mutarray, any>>:
    1edf:	push   rbp
    1ee0:	mov    rbp,rsp
    1ee3:	mov    rsi,QWORD PTR [rdx]
    1ee6:	mov    rdx,QWORD PTR [rdx+0x8]
    1eea:	call   1eef <botlish_entry_32+0x10>
			1eeb: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    1eef:	mov    rsp,rbp
    1ef2:	pop    rbp
    1ef3:	ret

0000000000001ef4 <botlish_fn_33: ht_probe_start<any, str>>:
    1ef4:	push   rbp
    1ef5:	mov    rbp,rsp
    1ef8:	sub    rsp,0x20
    1efc:	mov    QWORD PTR [rsp],r12
    1f00:	mov    QWORD PTR [rsp+0x8],r13
    1f05:	mov    QWORD PTR [rsp+0x10],r14
    1f0a:	mov    r12,rdi
    1f0d:	mov    r14,rsi
    1f10:	mov    rsi,rdx
    1f13:	mov    rdi,r12
    1f16:	call   1f1b <botlish_fn_33+0x27>
			1f17: R_X86_64_PLT32	rt_hash-0x4
    1f1b:	test   rax,rax
    1f1e:	mov    r13,rax
    1f21:	je     1f52 <botlish_fn_33+0x5e>
    1f27:	mov    rsi,r14
    1f2a:	mov    rdi,r12
    1f2d:	call   1f32 <botlish_fn_33+0x3e>
			1f2e: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_capacity<generic>
    1f32:	test   rax,rax
    1f35:	mov    rdx,rax
    1f38:	je     1f52 <botlish_fn_33+0x5e>
    1f3e:	mov    rsi,r13
    1f41:	mov    rdi,r12
    1f44:	call   1f49 <botlish_fn_33+0x55>
			1f45: R_X86_64_PLT32	rt_int_mod-0x4
    1f49:	test   rax,rax
    1f4c:	jne    1f6c <botlish_fn_33+0x78>
    1f52:	xor    rax,rax
    1f55:	mov    r12,QWORD PTR [rsp]
    1f59:	mov    r13,QWORD PTR [rsp+0x8]
    1f5e:	mov    r14,QWORD PTR [rsp+0x10]
    1f63:	add    rsp,0x20
    1f67:	mov    rsp,rbp
    1f6a:	pop    rbp
    1f6b:	ret
    1f6c:	mov    r12,QWORD PTR [rsp]
    1f70:	mov    r13,QWORD PTR [rsp+0x8]
    1f75:	mov    r14,QWORD PTR [rsp+0x10]
    1f7a:	add    rsp,0x20
    1f7e:	mov    rsp,rbp
    1f81:	pop    rbp
    1f82:	ret

0000000000001f83 <botlish_entry_33: ht_probe_start<any, str>>:
    1f83:	push   rbp
    1f84:	mov    rbp,rsp
    1f87:	mov    rsi,QWORD PTR [rdx]
    1f8a:	mov    rdx,QWORD PTR [rdx+0x8]
    1f8e:	call   1f93 <botlish_entry_33+0x10>
			1f8f: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_probe_start<any, str>
    1f93:	mov    rsp,rbp
    1f96:	pop    rbp
    1f97:	ret

0000000000001f98 <botlish_fn_34: ht_probe_next<mutarray, int>>:
    1f98:	push   rbp
    1f99:	mov    rbp,rsp
    1f9c:	sub    rsp,0x40
    1fa0:	mov    QWORD PTR [rsp+0x20],rbx
    1fa5:	mov    QWORD PTR [rsp+0x28],r12
    1faa:	mov    QWORD PTR [rsp+0x30],r13
    1faf:	mov    r13,rdi
    1fb2:	mov    QWORD PTR [rsp],rsi
    1fb6:	mov    rbx,rsi
    1fb9:	mov    QWORD PTR [rsp+0x8],rdx
    1fbe:	mov    QWORD PTR [rsp+0x10],0x3
    1fc7:	test   rdx,0x1
    1fce:	jne    1fdc <botlish_fn_34+0x44>
    1fd4:	mov    rsi,rdx
    1fd7:	jmp    1ffc <botlish_fn_34+0x64>
    1fdc:	mov    rsi,rdx
    1fdf:	add    rsi,0x2
    1fe3:	mov    r12,rsi
    1fe6:	mov    rsi,rdx
    1fe9:	seto   al
    1fec:	test   al,al
    1fee:	jne    1ffc <botlish_fn_34+0x64>
    1ff4:	mov    rsi,rbx
    1ff7:	jmp    200f <botlish_fn_34+0x77>
    1ffc:	mov    edx,0x3
    2001:	mov    rdi,r13
    2004:	call   2009 <botlish_fn_34+0x71>
			2005: R_X86_64_PLT32	rt_int_add-0x4
    2009:	mov    rsi,rbx
    200c:	mov    r12,rax
    200f:	mov    rdi,r13
    2012:	call   2017 <botlish_fn_34+0x7f>
			2013: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    2017:	test   rax,rax
    201a:	mov    rdx,rax
    201d:	je     2037 <botlish_fn_34+0x9f>
    2023:	mov    rsi,r12
    2026:	mov    rdi,r13
    2029:	call   202e <botlish_fn_34+0x96>
			202a: R_X86_64_PLT32	rt_int_mod-0x4
    202e:	test   rax,rax
    2031:	jne    2052 <botlish_fn_34+0xba>
    2037:	xor    rax,rax
    203a:	mov    rbx,QWORD PTR [rsp+0x20]
    203f:	mov    r12,QWORD PTR [rsp+0x28]
    2044:	mov    r13,QWORD PTR [rsp+0x30]
    2049:	add    rsp,0x40
    204d:	mov    rsp,rbp
    2050:	pop    rbp
    2051:	ret
    2052:	mov    rbx,QWORD PTR [rsp+0x20]
    2057:	mov    r12,QWORD PTR [rsp+0x28]
    205c:	mov    r13,QWORD PTR [rsp+0x30]
    2061:	add    rsp,0x40
    2065:	mov    rsp,rbp
    2068:	pop    rbp
    2069:	ret

000000000000206a <botlish_entry_34: ht_probe_next<mutarray, int>>:
    206a:	push   rbp
    206b:	mov    rbp,rsp
    206e:	mov    rsi,QWORD PTR [rdx]
    2071:	mov    rdx,QWORD PTR [rdx+0x8]
    2075:	call   207a <botlish_entry_34+0x10>
			2076: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_probe_next<mutarray, int>
    207a:	mov    rsp,rbp
    207d:	pop    rbp
    207e:	ret

000000000000207f <botlish_fn_35: ht_probe_next<any, int>>:
    207f:	push   rbp
    2080:	mov    rbp,rsp
    2083:	sub    rsp,0x40
    2087:	mov    QWORD PTR [rsp+0x20],rbx
    208c:	mov    QWORD PTR [rsp+0x28],r12
    2091:	mov    QWORD PTR [rsp+0x30],r13
    2096:	mov    r13,rdi
    2099:	mov    QWORD PTR [rsp],rsi
    209d:	mov    rbx,rsi
    20a0:	mov    QWORD PTR [rsp+0x8],rdx
    20a5:	mov    QWORD PTR [rsp+0x10],0x3
    20ae:	test   rdx,0x1
    20b5:	jne    20c3 <botlish_fn_35+0x44>
    20bb:	mov    rsi,rdx
    20be:	jmp    20e3 <botlish_fn_35+0x64>
    20c3:	mov    rsi,rdx
    20c6:	add    rsi,0x2
    20ca:	mov    r12,rsi
    20cd:	mov    rsi,rdx
    20d0:	seto   al
    20d3:	test   al,al
    20d5:	jne    20e3 <botlish_fn_35+0x64>
    20db:	mov    rsi,rbx
    20de:	jmp    20f6 <botlish_fn_35+0x77>
    20e3:	mov    edx,0x3
    20e8:	mov    rdi,r13
    20eb:	call   20f0 <botlish_fn_35+0x71>
			20ec: R_X86_64_PLT32	rt_int_add-0x4
    20f0:	mov    rsi,rbx
    20f3:	mov    r12,rax
    20f6:	mov    rdi,r13
    20f9:	call   20fe <botlish_fn_35+0x7f>
			20fa: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_capacity<generic>
    20fe:	test   rax,rax
    2101:	mov    rdx,rax
    2104:	je     211e <botlish_fn_35+0x9f>
    210a:	mov    rsi,r12
    210d:	mov    rdi,r13
    2110:	call   2115 <botlish_fn_35+0x96>
			2111: R_X86_64_PLT32	rt_int_mod-0x4
    2115:	test   rax,rax
    2118:	jne    2139 <botlish_fn_35+0xba>
    211e:	xor    rax,rax
    2121:	mov    rbx,QWORD PTR [rsp+0x20]
    2126:	mov    r12,QWORD PTR [rsp+0x28]
    212b:	mov    r13,QWORD PTR [rsp+0x30]
    2130:	add    rsp,0x40
    2134:	mov    rsp,rbp
    2137:	pop    rbp
    2138:	ret
    2139:	mov    rbx,QWORD PTR [rsp+0x20]
    213e:	mov    r12,QWORD PTR [rsp+0x28]
    2143:	mov    r13,QWORD PTR [rsp+0x30]
    2148:	add    rsp,0x40
    214c:	mov    rsp,rbp
    214f:	pop    rbp
    2150:	ret

0000000000002151 <botlish_entry_35: ht_probe_next<any, int>>:
    2151:	push   rbp
    2152:	mov    rbp,rsp
    2155:	mov    rsi,QWORD PTR [rdx]
    2158:	mov    rdx,QWORD PTR [rdx+0x8]
    215c:	call   2161 <botlish_entry_35+0x10>
			215d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_next<any, int>
    2161:	mov    rsp,rbp
    2164:	pop    rbp
    2165:	ret
	...

0000000000002168 <botlish_fn_36: ht_find_get<any, str, int>>:
    2168:	push   rbp
    2169:	mov    rbp,rsp
    216c:	sub    rsp,0x50
    2170:	mov    QWORD PTR [rsp+0x20],rbx
    2175:	mov    QWORD PTR [rsp+0x28],r12
    217a:	mov    QWORD PTR [rsp+0x30],r13
    217f:	mov    QWORD PTR [rsp+0x38],r14
    2184:	mov    QWORD PTR [rsp+0x40],r15
    2189:	mov    r14,rdi
    218c:	mov    QWORD PTR [rsp],rsi
    2190:	mov    QWORD PTR [rsp+0x8],rdx
    2195:	mov    r13,rdx
    2198:	mov    QWORD PTR [rsp+0x10],rcx
    219d:	mov    r12,rsi
    21a0:	mov    r15,rcx
    21a3:	mov    rsi,r12
    21a6:	mov    rdi,r14
    21a9:	call   21ae <botlish_fn_36+0x46>
			21aa: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_controls<generic>
    21ae:	test   rax,rax
    21b1:	je     23b0 <botlish_fn_36+0x248>
    21b7:	xor    ecx,ecx
    21b9:	test   rax,0x7
    21bf:	je     21cd <botlish_fn_36+0x65>
    21c5:	mov    rsi,rax
    21c8:	jmp    21db <botlish_fn_36+0x73>
    21cd:	movzx  rcx,BYTE PTR [rax]
    21d1:	mov    rsi,rax
    21d4:	rex cmp cl,0x8
    21d8:	sete   cl
    21db:	test   cl,cl
    21dd:	jne    21fd <botlish_fn_36+0x95>
    21e3:	mov    rdi,r14
    21e6:	mov    rdx,QWORD PTR [rdi+0x10]
    21ea:	mov    rcx,QWORD PTR [rdx+0x20]
    21ee:	mov    edx,0x8
    21f3:	call   21f8 <botlish_fn_36+0x90>
			21f4: R_X86_64_PLT32	rt_type_error-0x4
    21f8:	jmp    23b0 <botlish_fn_36+0x248>
    21fd:	mov    rdx,r15
    2200:	mov    rdi,r14
    2203:	call   2208 <botlish_fn_36+0xa0>
			2204: R_X86_64_PLT32	rt_mutarray_get-0x4
    2208:	mov    rcx,rax
    220b:	mov    QWORD PTR [rsp+0x18],rax
    2210:	test   rax,rcx
    2213:	je     23b0 <botlish_fn_36+0x248>
    2219:	mov    rax,QWORD PTR [rsp+0x18]
    221e:	test   rax,0x1
    2224:	jne    224f <botlish_fn_36+0xe7>
    222a:	mov    edx,0x1
    222f:	mov    rsi,QWORD PTR [rsp+0x18]
    2234:	mov    rdi,r14
    2237:	call   223c <botlish_fn_36+0xd4>
			2238: R_X86_64_PLT32	rt_value_eq-0x4
    223c:	test   rax,rax
    223f:	je     23b0 <botlish_fn_36+0x248>
    2245:	mov    rcx,QWORD PTR [rsp+0x18]
    224a:	jmp    2265 <botlish_fn_36+0xfd>
    224f:	mov    eax,0x2
    2254:	mov    rcx,QWORD PTR [rsp+0x18]
    2259:	cmp    rcx,0x1
    225d:	cmove  rax,QWORD PTR [rip+0x1db]        # 2440 <botlish_fn_36+0x2d8>
    2265:	mov    ebx,0x6
    226a:	cmp    rax,0x6
    226e:	je     2410 <botlish_fn_36+0x2a8>
    2274:	test   rcx,0x1
    227b:	mov    QWORD PTR [rsp+0x18],rcx
    2280:	jne    22a6 <botlish_fn_36+0x13e>
    2286:	mov    edx,0x3
    228b:	mov    rsi,QWORD PTR [rsp+0x18]
    2290:	mov    rdi,r14
    2293:	call   2298 <botlish_fn_36+0x130>
			2294: R_X86_64_PLT32	rt_value_eq-0x4
    2298:	test   rax,rax
    229b:	je     23b0 <botlish_fn_36+0x248>
    22a1:	jmp    22bc <botlish_fn_36+0x154>
    22a6:	mov    rsi,QWORD PTR [rsp+0x18]
    22ab:	mov    eax,0x2
    22b0:	cmp    rsi,0x3
    22b4:	cmove  rax,QWORD PTR [rip+0x184]        # 2440 <botlish_fn_36+0x2d8>
    22bc:	cmp    rax,0x6
    22c0:	je     22d0 <botlish_fn_36+0x168>
    22c6:	mov    ebx,0x2
    22cb:	jmp    238f <botlish_fn_36+0x227>
    22d0:	mov    rsi,r12
    22d3:	mov    rdi,r14
    22d6:	call   22db <botlish_fn_36+0x173>
			22d7: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_keys<generic>
    22db:	test   rax,rax
    22de:	je     23b0 <botlish_fn_36+0x248>
    22e4:	xor    r10d,r10d
    22e7:	test   rax,0x7
    22ed:	je     22fb <botlish_fn_36+0x193>
    22f3:	mov    rsi,rax
    22f6:	jmp    230a <botlish_fn_36+0x1a2>
    22fb:	movzx  rcx,BYTE PTR [rax]
    22ff:	mov    rsi,rax
    2302:	rex cmp cl,0x8
    2306:	sete   r10b
    230a:	test   r10b,r10b
    230d:	jne    232d <botlish_fn_36+0x1c5>
    2313:	mov    rdi,r14
    2316:	mov    rax,QWORD PTR [rdi+0x10]
    231a:	mov    rcx,QWORD PTR [rax+0x20]
    231e:	mov    edx,0x8
    2323:	call   2328 <botlish_fn_36+0x1c0>
			2324: R_X86_64_PLT32	rt_type_error-0x4
    2328:	jmp    23b0 <botlish_fn_36+0x248>
    232d:	mov    rdx,r15
    2330:	mov    rdi,r14
    2333:	call   2338 <botlish_fn_36+0x1d0>
			2334: R_X86_64_PLT32	rt_mutarray_get-0x4
    2338:	test   rax,rax
    233b:	je     23b0 <botlish_fn_36+0x248>
    2341:	mov    rcx,rax
    2344:	and    rcx,r13
    2347:	mov    rsi,rax
    234a:	test   rcx,0x1
    2351:	jne    2370 <botlish_fn_36+0x208>
    2357:	mov    rdx,r13
    235a:	mov    rdi,r14
    235d:	call   2362 <botlish_fn_36+0x1fa>
			235e: R_X86_64_PLT32	rt_value_eq-0x4
    2362:	test   rax,rax
    2365:	je     23b0 <botlish_fn_36+0x248>
    236b:	jmp    2380 <botlish_fn_36+0x218>
    2370:	mov    eax,0x2
    2375:	cmp    rsi,r13
    2378:	cmove  rax,QWORD PTR [rip+0xc0]        # 2440 <botlish_fn_36+0x2d8>
    2380:	cmp    rax,0x6
    2384:	je     238f <botlish_fn_36+0x227>
    238a:	mov    ebx,0x2
    238f:	cmp    rbx,0x6
    2393:	je     23eb <botlish_fn_36+0x283>
    2399:	mov    rdx,r15
    239c:	mov    rsi,r12
    239f:	mov    rdi,r14
    23a2:	call   23a7 <botlish_fn_36+0x23f>
			23a3: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_next<any, int>
    23a7:	test   rax,rax
    23aa:	jne    23d5 <botlish_fn_36+0x26d>
    23b0:	xor    rax,rax
    23b3:	mov    rbx,QWORD PTR [rsp+0x20]
    23b8:	mov    r12,QWORD PTR [rsp+0x28]
    23bd:	mov    r13,QWORD PTR [rsp+0x30]
    23c2:	mov    r14,QWORD PTR [rsp+0x38]
    23c7:	mov    r15,QWORD PTR [rsp+0x40]
    23cc:	add    rsp,0x50
    23d0:	mov    rsp,rbp
    23d3:	pop    rbp
    23d4:	ret
    23d5:	mov    QWORD PTR [rsp],r12
    23d9:	mov    QWORD PTR [rsp+0x8],r13
    23de:	mov    QWORD PTR [rsp+0x10],rax
    23e3:	mov    r15,rax
    23e6:	jmp    21a3 <botlish_fn_36+0x3b>
    23eb:	mov    rax,r15
    23ee:	mov    rbx,QWORD PTR [rsp+0x20]
    23f3:	mov    r12,QWORD PTR [rsp+0x28]
    23f8:	mov    r13,QWORD PTR [rsp+0x30]
    23fd:	mov    r14,QWORD PTR [rsp+0x38]
    2402:	mov    r15,QWORD PTR [rsp+0x40]
    2407:	add    rsp,0x50
    240b:	mov    rsp,rbp
    240e:	pop    rbp
    240f:	ret
    2410:	mov    rax,0xffffffffffffffff
    2417:	mov    rbx,QWORD PTR [rsp+0x20]
    241c:	mov    r12,QWORD PTR [rsp+0x28]
    2421:	mov    r13,QWORD PTR [rsp+0x30]
    2426:	mov    r14,QWORD PTR [rsp+0x38]
    242b:	mov    r15,QWORD PTR [rsp+0x40]
    2430:	add    rsp,0x50
    2434:	mov    rsp,rbp
    2437:	pop    rbp
    2438:	ret
    2439:	add    BYTE PTR [rax],al
    243b:	add    BYTE PTR [rax],al
    243d:	add    BYTE PTR [rax],al
    243f:	add    BYTE PTR [rsi],al
    2441:	add    BYTE PTR [rax],al
    2443:	add    BYTE PTR [rax],al
    2445:	add    BYTE PTR [rax],al
	...

0000000000002448 <botlish_entry_36: ht_find_get<any, str, int>>:
    2448:	push   rbp
    2449:	mov    rbp,rsp
    244c:	mov    rsi,QWORD PTR [rdx]
    244f:	mov    r8,QWORD PTR [rdx+0x8]
    2453:	mov    rcx,QWORD PTR [rdx+0x10]
    2457:	mov    rdx,r8
    245a:	call   245f <botlish_entry_36+0x17>
			245b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_find_get<any, str, int>
    245f:	mov    rsp,rbp
    2462:	pop    rbp
    2463:	ret
    2464:	add    BYTE PTR [rax],al
	...

0000000000002468 <botlish_fn_37: ht_find_insert<mutarray, any, int, int>>:
    2468:	push   rbp
    2469:	mov    rbp,rsp
    246c:	sub    rsp,0x60
    2470:	mov    QWORD PTR [rsp+0x30],rbx
    2475:	mov    QWORD PTR [rsp+0x38],r12
    247a:	mov    QWORD PTR [rsp+0x40],r13
    247f:	mov    QWORD PTR [rsp+0x48],r14
    2484:	mov    QWORD PTR [rsp+0x50],r15
    2489:	mov    r15,rdi
    248c:	mov    QWORD PTR [rsp],rsi
    2490:	mov    QWORD PTR [rsp+0x8],rdx
    2495:	mov    r13,rdx
    2498:	mov    QWORD PTR [rsp+0x10],rcx
    249d:	mov    QWORD PTR [rsp+0x18],r8
    24a2:	mov    rbx,rsi
    24a5:	mov    QWORD PTR [rsp+0x20],rcx
    24aa:	mov    QWORD PTR [rsp+0x28],r8
    24af:	mov    rsi,rbx
    24b2:	mov    rdi,r15
    24b5:	call   24ba <botlish_fn_37+0x52>
			24b6: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    24ba:	test   rax,rax
    24bd:	je     27b5 <botlish_fn_37+0x34d>
    24c3:	xor    ecx,ecx
    24c5:	test   rax,0x7
    24cb:	je     24d9 <botlish_fn_37+0x71>
    24d1:	mov    rsi,rax
    24d4:	jmp    24e7 <botlish_fn_37+0x7f>
    24d9:	movzx  rcx,BYTE PTR [rax]
    24dd:	mov    rsi,rax
    24e0:	rex cmp cl,0x8
    24e4:	sete   cl
    24e7:	test   cl,cl
    24e9:	jne    2509 <botlish_fn_37+0xa1>
    24ef:	mov    rdi,r15
    24f2:	mov    rax,QWORD PTR [rdi+0x10]
    24f6:	mov    rcx,QWORD PTR [rax+0x20]
    24fa:	mov    edx,0x8
    24ff:	call   2504 <botlish_fn_37+0x9c>
			2500: R_X86_64_PLT32	rt_type_error-0x4
    2504:	jmp    27b5 <botlish_fn_37+0x34d>
    2509:	mov    rdx,QWORD PTR [rsp+0x20]
    250e:	mov    rdi,r15
    2511:	call   2516 <botlish_fn_37+0xae>
			2512: R_X86_64_PLT32	rt_mutarray_get-0x4
    2516:	mov    rsi,rax
    2519:	mov    r14,rax
    251c:	test   rax,rsi
    251f:	je     27b5 <botlish_fn_37+0x34d>
    2525:	mov    rax,r14
    2528:	test   rax,0x1
    252e:	jne    2552 <botlish_fn_37+0xea>
    2534:	mov    edx,0x1
    2539:	mov    rsi,r14
    253c:	mov    rdi,r15
    253f:	call   2544 <botlish_fn_37+0xdc>
			2540: R_X86_64_PLT32	rt_value_eq-0x4
    2544:	test   rax,rax
    2547:	je     27b5 <botlish_fn_37+0x34d>
    254d:	jmp    2566 <botlish_fn_37+0xfe>
    2552:	mov    eax,0x2
    2557:	mov    rcx,r14
    255a:	cmp    rcx,0x1
    255e:	cmove  rax,QWORD PTR [rip+0x372]        # 28d8 <botlish_fn_37+0x470>
    2566:	mov    r12d,0x6
    256c:	cmp    rax,0x6
    2570:	je     282d <botlish_fn_37+0x3c5>
    2576:	mov    rax,r14
    2579:	test   rax,0x1
    257f:	jne    25a3 <botlish_fn_37+0x13b>
    2585:	mov    edx,0x3
    258a:	mov    rsi,r14
    258d:	mov    rdi,r15
    2590:	call   2595 <botlish_fn_37+0x12d>
			2591: R_X86_64_PLT32	rt_value_eq-0x4
    2595:	test   rax,rax
    2598:	je     27b5 <botlish_fn_37+0x34d>
    259e:	jmp    25b7 <botlish_fn_37+0x14f>
    25a3:	mov    eax,0x2
    25a8:	mov    rcx,r14
    25ab:	cmp    rcx,0x3
    25af:	cmove  rax,QWORD PTR [rip+0x321]        # 28d8 <botlish_fn_37+0x470>
    25b7:	cmp    rax,0x6
    25bb:	je     25cc <botlish_fn_37+0x164>
    25c1:	mov    r11d,0x2
    25c7:	jmp    2696 <botlish_fn_37+0x22e>
    25cc:	mov    rsi,rbx
    25cf:	mov    rdi,r15
    25d2:	call   25d7 <botlish_fn_37+0x16f>
			25d3: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    25d7:	test   rax,rax
    25da:	je     27b5 <botlish_fn_37+0x34d>
    25e0:	xor    ecx,ecx
    25e2:	test   rax,0x7
    25e8:	je     25f6 <botlish_fn_37+0x18e>
    25ee:	mov    rsi,rax
    25f1:	jmp    2604 <botlish_fn_37+0x19c>
    25f6:	movzx  rcx,BYTE PTR [rax]
    25fa:	mov    rsi,rax
    25fd:	rex cmp cl,0x8
    2601:	sete   cl
    2604:	test   cl,cl
    2606:	jne    2626 <botlish_fn_37+0x1be>
    260c:	mov    rdi,r15
    260f:	mov    rcx,QWORD PTR [rdi+0x10]
    2613:	mov    rcx,QWORD PTR [rcx+0x20]
    2617:	mov    edx,0x8
    261c:	call   2621 <botlish_fn_37+0x1b9>
			261d: R_X86_64_PLT32	rt_type_error-0x4
    2621:	jmp    27b5 <botlish_fn_37+0x34d>
    2626:	mov    rdx,QWORD PTR [rsp+0x20]
    262b:	mov    rdi,r15
    262e:	call   2633 <botlish_fn_37+0x1cb>
			262f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2633:	test   rax,rax
    2636:	je     27b5 <botlish_fn_37+0x34d>
    263c:	mov    rsi,rax
    263f:	and    rsi,r13
    2642:	test   rsi,0x1
    2649:	jne    266b <botlish_fn_37+0x203>
    264f:	mov    rsi,rax
    2652:	mov    rdx,r13
    2655:	mov    rdi,r15
    2658:	call   265d <botlish_fn_37+0x1f5>
			2659: R_X86_64_PLT32	rt_value_eq-0x4
    265d:	test   rax,rax
    2660:	je     27b5 <botlish_fn_37+0x34d>
    2666:	jmp    267e <botlish_fn_37+0x216>
    266b:	mov    rsi,rax
    266e:	mov    eax,0x2
    2673:	cmp    rsi,r13
    2676:	cmove  rax,QWORD PTR [rip+0x25a]        # 28d8 <botlish_fn_37+0x470>
    267e:	cmp    rax,0x6
    2682:	je     2693 <botlish_fn_37+0x22b>
    2688:	mov    r11d,0x2
    268e:	jmp    2696 <botlish_fn_37+0x22e>
    2693:	mov    r11,r12
    2696:	cmp    r11,0x6
    269a:	je     2806 <botlish_fn_37+0x39e>
    26a0:	mov    rax,r14
    26a3:	test   rax,0x1
    26a9:	jne    26cd <botlish_fn_37+0x265>
    26af:	mov    edx,0x5
    26b4:	mov    rsi,r14
    26b7:	mov    rdi,r15
    26ba:	call   26bf <botlish_fn_37+0x257>
			26bb: R_X86_64_PLT32	rt_value_eq-0x4
    26bf:	test   rax,rax
    26c2:	je     27b5 <botlish_fn_37+0x34d>
    26c8:	jmp    26e1 <botlish_fn_37+0x279>
    26cd:	mov    rsi,r14
    26d0:	mov    eax,0x2
    26d5:	cmp    rsi,0x5
    26d9:	cmove  rax,QWORD PTR [rip+0x1f7]        # 28d8 <botlish_fn_37+0x470>
    26e1:	cmp    rax,0x6
    26e5:	je     26f6 <botlish_fn_37+0x28e>
    26eb:	mov    r12d,0x2
    26f1:	jmp    2757 <botlish_fn_37+0x2ef>
    26f6:	mov    r14,QWORD PTR [rsp+0x28]
    26fb:	test   r14,0x1
    2702:	jne    2732 <botlish_fn_37+0x2ca>
    2708:	mov    edx,0x1
    270d:	mov    rsi,r14
    2710:	mov    rdi,r15
    2713:	call   2718 <botlish_fn_37+0x2b0>
			2714: R_X86_64_PLT32	rt_int_cmp-0x4
    2718:	mov    ecx,0x2
    271d:	test   rax,rax
    2720:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 28d8 <botlish_fn_37+0x470>
    2728:	mov    QWORD PTR [rsp+0x28],r14
    272d:	jmp    2747 <botlish_fn_37+0x2df>
    2732:	mov    ecx,0x2
    2737:	test   r14,r14
    273a:	mov    QWORD PTR [rsp+0x28],r14
    273f:	cmovle rcx,QWORD PTR [rip+0x191]        # 28d8 <botlish_fn_37+0x470>
    2747:	cmp    rcx,0x6
    274b:	je     2757 <botlish_fn_37+0x2ef>
    2751:	mov    r12d,0x2
    2757:	cmp    r12,0x6
    275b:	je     279c <botlish_fn_37+0x334>
    2761:	mov    rdx,QWORD PTR [rsp+0x20]
    2766:	mov    rsi,rbx
    2769:	mov    rdi,r15
    276c:	call   2771 <botlish_fn_37+0x309>
			276d: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_probe_next<mutarray, int>
    2771:	test   rax,rax
    2774:	je     27b5 <botlish_fn_37+0x34d>
    277a:	mov    QWORD PTR [rsp],rbx
    277e:	mov    QWORD PTR [rsp+0x8],r13
    2783:	mov    QWORD PTR [rsp+0x10],rax
    2788:	mov    r11,QWORD PTR [rsp+0x28]
    278d:	mov    QWORD PTR [rsp+0x18],r11
    2792:	mov    QWORD PTR [rsp+0x20],rax
    2797:	jmp    24af <botlish_fn_37+0x47>
    279c:	mov    rdx,QWORD PTR [rsp+0x20]
    27a1:	mov    rsi,rbx
    27a4:	mov    rdi,r15
    27a7:	call   27ac <botlish_fn_37+0x344>
			27a8: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_probe_next<mutarray, int>
    27ac:	test   rax,rax
    27af:	jne    27da <botlish_fn_37+0x372>
    27b5:	xor    rax,rax
    27b8:	mov    rbx,QWORD PTR [rsp+0x30]
    27bd:	mov    r12,QWORD PTR [rsp+0x38]
    27c2:	mov    r13,QWORD PTR [rsp+0x40]
    27c7:	mov    r14,QWORD PTR [rsp+0x48]
    27cc:	mov    r15,QWORD PTR [rsp+0x50]
    27d1:	add    rsp,0x60
    27d5:	mov    rsp,rbp
    27d8:	pop    rbp
    27d9:	ret
    27da:	mov    QWORD PTR [rsp],rbx
    27de:	mov    QWORD PTR [rsp+0x8],r13
    27e3:	mov    QWORD PTR [rsp+0x10],rax
    27e8:	mov    rdx,QWORD PTR [rsp+0x20]
    27ed:	mov    QWORD PTR [rsp+0x18],rdx
    27f2:	mov    rcx,QWORD PTR [rsp+0x20]
    27f7:	mov    QWORD PTR [rsp+0x28],rcx
    27fc:	mov    QWORD PTR [rsp+0x20],rax
    2801:	jmp    24af <botlish_fn_37+0x47>
    2806:	mov    rax,QWORD PTR [rsp+0x20]
    280b:	mov    rbx,QWORD PTR [rsp+0x30]
    2810:	mov    r12,QWORD PTR [rsp+0x38]
    2815:	mov    r13,QWORD PTR [rsp+0x40]
    281a:	mov    r14,QWORD PTR [rsp+0x48]
    281f:	mov    r15,QWORD PTR [rsp+0x50]
    2824:	add    rsp,0x60
    2828:	mov    rsp,rbp
    282b:	pop    rbp
    282c:	ret
    282d:	mov    rax,QWORD PTR [rsp+0x28]
    2832:	test   rax,0x1
    2838:	jne    2865 <botlish_fn_37+0x3fd>
    283e:	mov    edx,0x1
    2843:	mov    rdi,r15
    2846:	mov    rsi,QWORD PTR [rsp+0x28]
    284b:	call   2850 <botlish_fn_37+0x3e8>
			284c: R_X86_64_PLT32	rt_int_cmp-0x4
    2850:	mov    ecx,0x2
    2855:	test   rax,rax
    2858:	cmovge rcx,QWORD PTR [rip+0x78]        # 28d8 <botlish_fn_37+0x470>
    2860:	jmp    287f <botlish_fn_37+0x417>
    2865:	mov    ecx,0x2
    286a:	mov    rax,QWORD PTR [rsp+0x28]
    286f:	mov    rdx,QWORD PTR [rsp+0x28]
    2874:	test   rax,rdx
    2877:	cmovg  rcx,QWORD PTR [rip+0x59]        # 28d8 <botlish_fn_37+0x470>
    287f:	cmp    rcx,0x6
    2883:	je     28b0 <botlish_fn_37+0x448>
    2889:	mov    rax,QWORD PTR [rsp+0x20]
    288e:	mov    rbx,QWORD PTR [rsp+0x30]
    2893:	mov    r12,QWORD PTR [rsp+0x38]
    2898:	mov    r13,QWORD PTR [rsp+0x40]
    289d:	mov    r14,QWORD PTR [rsp+0x48]
    28a2:	mov    r15,QWORD PTR [rsp+0x50]
    28a7:	add    rsp,0x60
    28ab:	mov    rsp,rbp
    28ae:	pop    rbp
    28af:	ret
    28b0:	mov    rax,QWORD PTR [rsp+0x28]
    28b5:	mov    rbx,QWORD PTR [rsp+0x30]
    28ba:	mov    r12,QWORD PTR [rsp+0x38]
    28bf:	mov    r13,QWORD PTR [rsp+0x40]
    28c4:	mov    r14,QWORD PTR [rsp+0x48]
    28c9:	mov    r15,QWORD PTR [rsp+0x50]
    28ce:	add    rsp,0x60
    28d2:	mov    rsp,rbp
    28d5:	pop    rbp
    28d6:	ret
    28d7:	add    BYTE PTR [rsi],al
    28d9:	add    BYTE PTR [rax],al
    28db:	add    BYTE PTR [rax],al
    28dd:	add    BYTE PTR [rax],al
	...

00000000000028e0 <botlish_entry_37: ht_find_insert<mutarray, any, int, int>>:
    28e0:	push   rbp
    28e1:	mov    rbp,rsp
    28e4:	mov    rsi,QWORD PTR [rdx]
    28e7:	mov    r9,QWORD PTR [rdx+0x8]
    28eb:	mov    rcx,QWORD PTR [rdx+0x10]
    28ef:	mov    r8,QWORD PTR [rdx+0x18]
    28f3:	mov    rdx,r9
    28f6:	call   28fb <botlish_entry_37+0x1b>
			28f7: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    28fb:	mov    rsp,rbp
    28fe:	pop    rbp
    28ff:	ret

0000000000002900 <botlish_fn_38: ht_get<any, str>>:
    2900:	push   rbp
    2901:	mov    rbp,rsp
    2904:	sub    rsp,0x40
    2908:	mov    QWORD PTR [rsp+0x20],rbx
    290d:	mov    QWORD PTR [rsp+0x28],r12
    2912:	mov    QWORD PTR [rsp+0x30],r13
    2917:	mov    rbx,rdi
    291a:	mov    QWORD PTR [rsp],rsi
    291e:	mov    r13,rsi
    2921:	mov    QWORD PTR [rsp+0x8],rdx
    2926:	mov    r12,rdx
    2929:	mov    rdx,r12
    292c:	mov    rsi,r13
    292f:	mov    rdi,rbx
    2932:	call   2937 <botlish_fn_38+0x37>
			2933: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_probe_start<any, str>
    2937:	test   rax,rax
    293a:	je     2a24 <botlish_fn_38+0x124>
    2940:	mov    QWORD PTR [rsp+0x10],rax
    2945:	mov    rcx,rax
    2948:	mov    rdx,r12
    294b:	mov    rsi,r13
    294e:	mov    rdi,rbx
    2951:	call   2956 <botlish_fn_38+0x56>
			2952: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_find_get<any, str, int>
    2956:	mov    rcx,rax
    2959:	mov    r12,rax
    295c:	test   rax,rcx
    295f:	je     2a24 <botlish_fn_38+0x124>
    2965:	mov    rax,r12
    2968:	test   rax,0x1
    296e:	jne    2999 <botlish_fn_38+0x99>
    2974:	mov    edx,0x1
    2979:	mov    rsi,r12
    297c:	mov    rdi,rbx
    297f:	call   2984 <botlish_fn_38+0x84>
			2980: R_X86_64_PLT32	rt_int_cmp-0x4
    2984:	mov    ecx,0x2
    2989:	test   rax,rax
    298c:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 2a78 <botlish_fn_38+0x178>
    2994:	jmp    29ac <botlish_fn_38+0xac>
    2999:	mov    ecx,0x2
    299e:	mov    rax,r12
    29a1:	test   rax,rax
    29a4:	cmovle rcx,QWORD PTR [rip+0xcc]        # 2a78 <botlish_fn_38+0x178>
    29ac:	cmp    rcx,0x6
    29b0:	je     2a57 <botlish_fn_38+0x157>
    29b6:	mov    rsi,r13
    29b9:	mov    rdi,rbx
    29bc:	call   29c1 <botlish_fn_38+0xc1>
			29bd: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_values<generic>
    29c1:	test   rax,rax
    29c4:	je     2a24 <botlish_fn_38+0x124>
    29ca:	xor    ecx,ecx
    29cc:	test   rax,0x7
    29d2:	je     29e0 <botlish_fn_38+0xe0>
    29d8:	mov    rsi,rax
    29db:	jmp    29ee <botlish_fn_38+0xee>
    29e0:	movzx  rcx,BYTE PTR [rax]
    29e4:	mov    rsi,rax
    29e7:	rex cmp cl,0x8
    29eb:	sete   cl
    29ee:	test   cl,cl
    29f0:	jne    2a10 <botlish_fn_38+0x110>
    29f6:	mov    rdi,rbx
    29f9:	mov    rax,QWORD PTR [rdi+0x10]
    29fd:	mov    rcx,QWORD PTR [rax+0x20]
    2a01:	mov    edx,0x8
    2a06:	call   2a0b <botlish_fn_38+0x10b>
			2a07: R_X86_64_PLT32	rt_type_error-0x4
    2a0b:	jmp    2a24 <botlish_fn_38+0x124>
    2a10:	mov    rdx,r12
    2a13:	mov    rdi,rbx
    2a16:	call   2a1b <botlish_fn_38+0x11b>
			2a17: R_X86_64_PLT32	rt_mutarray_get-0x4
    2a1b:	test   rax,rax
    2a1e:	jne    2a3f <botlish_fn_38+0x13f>
    2a24:	xor    rax,rax
    2a27:	mov    rbx,QWORD PTR [rsp+0x20]
    2a2c:	mov    r12,QWORD PTR [rsp+0x28]
    2a31:	mov    r13,QWORD PTR [rsp+0x30]
    2a36:	add    rsp,0x40
    2a3a:	mov    rsp,rbp
    2a3d:	pop    rbp
    2a3e:	ret
    2a3f:	mov    rbx,QWORD PTR [rsp+0x20]
    2a44:	mov    r12,QWORD PTR [rsp+0x28]
    2a49:	mov    r13,QWORD PTR [rsp+0x30]
    2a4e:	add    rsp,0x40
    2a52:	mov    rsp,rbp
    2a55:	pop    rbp
    2a56:	ret
    2a57:	mov    eax,0xa
    2a5c:	mov    rbx,QWORD PTR [rsp+0x20]
    2a61:	mov    r12,QWORD PTR [rsp+0x28]
    2a66:	mov    r13,QWORD PTR [rsp+0x30]
    2a6b:	add    rsp,0x40
    2a6f:	mov    rsp,rbp
    2a72:	pop    rbp
    2a73:	ret
    2a74:	add    BYTE PTR [rax],al
    2a76:	add    BYTE PTR [rax],al
    2a78:	(bad)
    2a79:	add    BYTE PTR [rax],al
    2a7b:	add    BYTE PTR [rax],al
    2a7d:	add    BYTE PTR [rax],al
	...

0000000000002a80 <botlish_entry_38: ht_get<any, str>>:
    2a80:	push   rbp
    2a81:	mov    rbp,rsp
    2a84:	mov    rsi,QWORD PTR [rdx]
    2a87:	mov    rdx,QWORD PTR [rdx+0x8]
    2a8b:	call   2a90 <botlish_entry_38+0x10>
			2a8c: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    2a90:	mov    rsp,rbp
    2a93:	pop    rbp
    2a94:	ret
    2a95:	add    BYTE PTR [rax],al
	...

0000000000002a98 <botlish_fn_39: ht_rehash_probe<mutarray, int, int>>:
    2a98:	push   rbp
    2a99:	mov    rbp,rsp
    2a9c:	sub    rsp,0x40
    2aa0:	mov    QWORD PTR [rsp+0x20],rbx
    2aa5:	mov    QWORD PTR [rsp+0x28],r12
    2aaa:	mov    QWORD PTR [rsp+0x30],r13
    2aaf:	mov    QWORD PTR [rsp+0x38],r14
    2ab4:	mov    r13,rdi
    2ab7:	mov    QWORD PTR [rsp],rsi
    2abb:	mov    QWORD PTR [rsp+0x8],rdx
    2ac0:	mov    QWORD PTR [rsp+0x10],rcx
    2ac5:	mov    r12,rcx
    2ac8:	mov    rbx,rsi
    2acb:	mov    r14,rdx
    2ace:	mov    rdx,r14
    2ad1:	mov    rsi,rbx
    2ad4:	mov    rdi,r13
    2ad7:	call   2adc <botlish_fn_39+0x44>
			2ad8: R_X86_64_PLT32	rt_mutarray_get-0x4
    2adc:	test   rax,rax
    2adf:	je     2b7c <botlish_fn_39+0xe4>
    2ae5:	test   rax,0x1
    2aeb:	mov    rsi,rax
    2aee:	jne    2b0f <botlish_fn_39+0x77>
    2af4:	mov    edx,0x1
    2af9:	mov    rdi,r13
    2afc:	call   2b01 <botlish_fn_39+0x69>
			2afd: R_X86_64_PLT32	rt_value_eq-0x4
    2b01:	test   rax,rax
    2b04:	je     2b7c <botlish_fn_39+0xe4>
    2b0a:	jmp    2b20 <botlish_fn_39+0x88>
    2b0f:	mov    eax,0x2
    2b14:	cmp    rsi,0x1
    2b18:	cmove  rax,QWORD PTR [rip+0xb8]        # 2bd8 <botlish_fn_39+0x140>
    2b20:	cmp    rax,0x6
    2b24:	je     2bb2 <botlish_fn_39+0x11a>
    2b2a:	mov    QWORD PTR [rsp+0x18],0x3
    2b33:	mov    rsi,r14
    2b36:	test   rsi,0x1
    2b3d:	je     2b55 <botlish_fn_39+0xbd>
    2b43:	mov    rsi,r14
    2b46:	add    rsi,0x2
    2b4a:	seto   al
    2b4d:	test   al,al
    2b4f:	je     2b68 <botlish_fn_39+0xd0>
    2b55:	mov    edx,0x3
    2b5a:	mov    rsi,r14
    2b5d:	mov    rdi,r13
    2b60:	call   2b65 <botlish_fn_39+0xcd>
			2b61: R_X86_64_PLT32	rt_int_add-0x4
    2b65:	mov    rsi,rax
    2b68:	mov    rdx,r12
    2b6b:	mov    rdi,r13
    2b6e:	call   2b73 <botlish_fn_39+0xdb>
			2b6f: R_X86_64_PLT32	rt_int_mod-0x4
    2b73:	test   rax,rax
    2b76:	jne    2b9c <botlish_fn_39+0x104>
    2b7c:	xor    rax,rax
    2b7f:	mov    rbx,QWORD PTR [rsp+0x20]
    2b84:	mov    r12,QWORD PTR [rsp+0x28]
    2b89:	mov    r13,QWORD PTR [rsp+0x30]
    2b8e:	mov    r14,QWORD PTR [rsp+0x38]
    2b93:	add    rsp,0x40
    2b97:	mov    rsp,rbp
    2b9a:	pop    rbp
    2b9b:	ret
    2b9c:	mov    QWORD PTR [rsp],rbx
    2ba0:	mov    QWORD PTR [rsp+0x8],rax
    2ba5:	mov    QWORD PTR [rsp+0x10],r12
    2baa:	mov    r14,rax
    2bad:	jmp    2ace <botlish_fn_39+0x36>
    2bb2:	mov    rax,r14
    2bb5:	mov    rbx,QWORD PTR [rsp+0x20]
    2bba:	mov    r12,QWORD PTR [rsp+0x28]
    2bbf:	mov    r13,QWORD PTR [rsp+0x30]
    2bc4:	mov    r14,QWORD PTR [rsp+0x38]
    2bc9:	add    rsp,0x40
    2bcd:	mov    rsp,rbp
    2bd0:	pop    rbp
    2bd1:	ret
    2bd2:	add    BYTE PTR [rax],al
    2bd4:	add    BYTE PTR [rax],al
    2bd6:	add    BYTE PTR [rax],al
    2bd8:	(bad)
    2bd9:	add    BYTE PTR [rax],al
    2bdb:	add    BYTE PTR [rax],al
    2bdd:	add    BYTE PTR [rax],al
	...

0000000000002be0 <botlish_entry_39: ht_rehash_probe<mutarray, int, int>>:
    2be0:	push   rbp
    2be1:	mov    rbp,rsp
    2be4:	mov    rsi,QWORD PTR [rdx]
    2be7:	mov    r8,QWORD PTR [rdx+0x8]
    2beb:	mov    rcx,QWORD PTR [rdx+0x10]
    2bef:	mov    rdx,r8
    2bf2:	call   2bf7 <botlish_entry_39+0x17>
			2bf3: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_rehash_probe<mutarray, int, int>
    2bf7:	mov    rsp,rbp
    2bfa:	pop    rbp
    2bfb:	ret

0000000000002bfc <botlish_fn_40: ht_rehash_insert<list<mutarray>, int, any, any>>:
    2bfc:	push   rbp
    2bfd:	mov    rbp,rsp
    2c00:	sub    rsp,0x80
    2c07:	mov    QWORD PTR [rsp+0x50],rbx
    2c0c:	mov    QWORD PTR [rsp+0x58],r12
    2c11:	mov    QWORD PTR [rsp+0x60],r13
    2c16:	mov    QWORD PTR [rsp+0x68],r14
    2c1b:	mov    QWORD PTR [rsp+0x70],r15
    2c20:	mov    r12,rdi
    2c23:	mov    rdi,QWORD PTR [rbp+0x10]
    2c27:	mov    QWORD PTR [rsp],rsi
    2c2b:	mov    QWORD PTR [rsp+0x38],rsi
    2c30:	mov    QWORD PTR [rsp+0x8],rdx
    2c35:	mov    r15,rdx
    2c38:	mov    QWORD PTR [rsp+0x10],rcx
    2c3d:	mov    rbx,rcx
    2c40:	mov    QWORD PTR [rsp+0x18],r8
    2c45:	mov    QWORD PTR [rsp+0x40],r8
    2c4a:	mov    QWORD PTR [rsp+0x20],r9
    2c4f:	mov    r14,r9
    2c52:	mov    QWORD PTR [rsp+0x28],rdi
    2c57:	mov    r13,rdi
    2c5a:	mov    rsi,r14
    2c5d:	mov    rdi,r12
    2c60:	call   2c65 <botlish_fn_40+0x69>
			2c61: R_X86_64_PLT32	rt_hash-0x4
    2c65:	test   rax,rax
    2c68:	mov    rsi,rax
    2c6b:	je     2d0a <botlish_fn_40+0x10e>
    2c71:	mov    rdx,QWORD PTR [rsp+0x40]
    2c76:	mov    rdi,r12
    2c79:	call   2c7e <botlish_fn_40+0x82>
			2c7a: R_X86_64_PLT32	rt_int_mod-0x4
    2c7e:	test   rax,rax
    2c81:	je     2d0a <botlish_fn_40+0x10e>
    2c87:	mov    QWORD PTR [rsp+0x30],rax
    2c8c:	mov    rcx,QWORD PTR [rsp+0x40]
    2c91:	mov    rdx,rax
    2c94:	mov    rsi,QWORD PTR [rsp+0x38]
    2c99:	mov    rdi,r12
    2c9c:	call   2ca1 <botlish_fn_40+0xa5>
			2c9d: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_rehash_probe<mutarray, int, int>
    2ca1:	mov    rcx,rax
    2ca4:	mov    QWORD PTR [rsp+0x40],rax
    2ca9:	test   rax,rcx
    2cac:	je     2d0a <botlish_fn_40+0x10e>
    2cb2:	mov    ecx,0x3
    2cb7:	mov    rsi,QWORD PTR [rsp+0x38]
    2cbc:	mov    rdx,QWORD PTR [rsp+0x40]
    2cc1:	mov    rdi,r12
    2cc4:	call   2cc9 <botlish_fn_40+0xcd>
			2cc5: R_X86_64_PLT32	rt_mutarray_set-0x4
    2cc9:	test   rax,rax
    2ccc:	je     2d0a <botlish_fn_40+0x10e>
    2cd2:	mov    rcx,r14
    2cd5:	mov    rsi,r15
    2cd8:	mov    rdx,QWORD PTR [rsp+0x40]
    2cdd:	mov    rdi,r12
    2ce0:	call   2ce5 <botlish_fn_40+0xe9>
			2ce1: R_X86_64_PLT32	rt_mutarray_set-0x4
    2ce5:	test   rax,rax
    2ce8:	je     2d0a <botlish_fn_40+0x10e>
    2cee:	mov    rcx,r13
    2cf1:	mov    rdx,QWORD PTR [rsp+0x40]
    2cf6:	mov    rsi,rbx
    2cf9:	mov    rdi,r12
    2cfc:	call   2d01 <botlish_fn_40+0x105>
			2cfd: R_X86_64_PLT32	rt_mutarray_set-0x4
    2d01:	test   rax,rax
    2d04:	jne    2d32 <botlish_fn_40+0x136>
    2d0a:	xor    rax,rax
    2d0d:	mov    rbx,QWORD PTR [rsp+0x50]
    2d12:	mov    r12,QWORD PTR [rsp+0x58]
    2d17:	mov    r13,QWORD PTR [rsp+0x60]
    2d1c:	mov    r14,QWORD PTR [rsp+0x68]
    2d21:	mov    r15,QWORD PTR [rsp+0x70]
    2d26:	add    rsp,0x80
    2d2d:	mov    rsp,rbp
    2d30:	pop    rbp
    2d31:	ret
    2d32:	mov    eax,0xa
    2d37:	mov    rbx,QWORD PTR [rsp+0x50]
    2d3c:	mov    r12,QWORD PTR [rsp+0x58]
    2d41:	mov    r13,QWORD PTR [rsp+0x60]
    2d46:	mov    r14,QWORD PTR [rsp+0x68]
    2d4b:	mov    r15,QWORD PTR [rsp+0x70]
    2d50:	add    rsp,0x80
    2d57:	mov    rsp,rbp
    2d5a:	pop    rbp
    2d5b:	ret

0000000000002d5c <botlish_entry_40: ht_rehash_insert<list<mutarray>, int, any, any>>:
    2d5c:	push   rbp
    2d5d:	mov    rbp,rsp
    2d60:	sub    rsp,0x10
    2d64:	mov    rsi,QWORD PTR [rdx]
    2d67:	mov    r10,QWORD PTR [rdx+0x8]
    2d6b:	mov    rcx,QWORD PTR [rdx+0x10]
    2d6f:	mov    r8,QWORD PTR [rdx+0x18]
    2d73:	mov    r9,QWORD PTR [rdx+0x20]
    2d77:	mov    r11,QWORD PTR [rdx+0x28]
    2d7b:	mov    QWORD PTR [rsp],r11
    2d7f:	mov    rdx,r10
    2d82:	call   2d87 <botlish_entry_40+0x2b>
			2d83: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    2d87:	add    rsp,0x10
    2d8b:	mov    rsp,rbp
    2d8e:	pop    rbp
    2d8f:	ret

0000000000002d90 <botlish_fn_41: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2d90:	push   rbp
    2d91:	mov    rbp,rsp
    2d94:	sub    rsp,0xc0
    2d9b:	mov    QWORD PTR [rsp+0x90],rbx
    2da3:	mov    QWORD PTR [rsp+0x98],r12
    2dab:	mov    QWORD PTR [rsp+0xa0],r13
    2db3:	mov    QWORD PTR [rsp+0xa8],r14
    2dbb:	mov    QWORD PTR [rsp+0xb0],r15
    2dc3:	mov    QWORD PTR [rsp+0x60],rdi
    2dc8:	mov    QWORD PTR [rsp+0x80],r9
    2dd0:	mov    r12,QWORD PTR [rbp+0x10]
    2dd4:	mov    r13,QWORD PTR [rbp+0x18]
    2dd8:	mov    r14,QWORD PTR [rbp+0x20]
    2ddc:	mov    rdi,QWORD PTR [rbp+0x28]
    2de0:	mov    QWORD PTR [rsp+0x10],rsi
    2de5:	mov    QWORD PTR [rsp+0x68],rsi
    2dea:	mov    QWORD PTR [rsp+0x18],rdx
    2def:	mov    QWORD PTR [rsp+0x70],rdx
    2df4:	mov    QWORD PTR [rsp+0x20],rcx
    2df9:	mov    QWORD PTR [rsp+0x78],rcx
    2dfe:	mov    QWORD PTR [rsp+0x28],r8
    2e03:	mov    rax,r12
    2e06:	mov    QWORD PTR [rsp+0x30],rax
    2e0b:	mov    QWORD PTR [rsp+0x38],r13
    2e10:	mov    QWORD PTR [rsp+0x40],r14
    2e15:	mov    QWORD PTR [rsp+0x48],rdi
    2e1a:	mov    QWORD PTR [rsp+0x88],rdi
    2e22:	mov    rsi,QWORD PTR [rsp+0x80]
    2e2a:	mov    rax,rsi
    2e2d:	or     rax,0x1
    2e31:	mov    r15,r8
    2e34:	mov    rcx,r15
    2e37:	and    rcx,rax
    2e3a:	test   rcx,0x1
    2e41:	jne    2e78 <botlish_fn_41+0xe8>
    2e47:	mov    rdx,rsi
    2e4a:	or     rdx,0x1
    2e4e:	mov    QWORD PTR [rsp+0x80],rsi
    2e56:	mov    rsi,r15
    2e59:	mov    rdi,QWORD PTR [rsp+0x60]
    2e5e:	call   2e63 <botlish_fn_41+0xd3>
			2e5f: R_X86_64_PLT32	rt_int_cmp-0x4
    2e63:	mov    ecx,0x2
    2e68:	test   rax,rax
    2e6b:	cmovge rcx,QWORD PTR [rip+0x2dd]        # 3150 <botlish_fn_41+0x3c0>
    2e73:	jmp    2e9a <botlish_fn_41+0x10a>
    2e78:	mov    rdi,rsi
    2e7b:	mov    QWORD PTR [rsp+0x80],rsi
    2e83:	mov    rax,rdi
    2e86:	or     rax,0x1
    2e8a:	mov    ecx,0x2
    2e8f:	cmp    r15,rax
    2e92:	cmovge rcx,QWORD PTR [rip+0x2b6]        # 3150 <botlish_fn_41+0x3c0>
    2e9a:	cmp    rcx,0x6
    2e9e:	je     3110 <botlish_fn_41+0x380>
    2ea4:	xor    eax,eax
    2ea6:	mov    rsi,QWORD PTR [rsp+0x68]
    2eab:	test   rsi,0x7
    2eb2:	jne    2ec1 <botlish_fn_41+0x131>
    2eb8:	movzx  rax,BYTE PTR [rsi]
    2ebc:	cmp    al,0x8
    2ebe:	sete   al
    2ec1:	test   al,al
    2ec3:	jne    2ee5 <botlish_fn_41+0x155>
    2ec9:	mov    rdi,QWORD PTR [rsp+0x60]
    2ece:	mov    rax,QWORD PTR [rdi+0x10]
    2ed2:	mov    rcx,QWORD PTR [rax+0x20]
    2ed6:	mov    edx,0x8
    2edb:	call   2ee0 <botlish_fn_41+0x150>
			2edc: R_X86_64_PLT32	rt_type_error-0x4
    2ee0:	jmp    3074 <botlish_fn_41+0x2e4>
    2ee5:	mov    QWORD PTR [rsp+0x68],rsi
    2eea:	mov    rdx,r15
    2eed:	mov    rdi,QWORD PTR [rsp+0x60]
    2ef2:	call   2ef7 <botlish_fn_41+0x167>
			2ef3: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ef7:	test   rax,rax
    2efa:	je     3074 <botlish_fn_41+0x2e4>
    2f00:	test   rax,0x1
    2f06:	mov    rsi,rax
    2f09:	jne    2f2c <botlish_fn_41+0x19c>
    2f0f:	mov    edx,0x3
    2f14:	mov    rdi,QWORD PTR [rsp+0x60]
    2f19:	call   2f1e <botlish_fn_41+0x18e>
			2f1a: R_X86_64_PLT32	rt_value_eq-0x4
    2f1e:	test   rax,rax
    2f21:	je     3074 <botlish_fn_41+0x2e4>
    2f27:	jmp    2f3d <botlish_fn_41+0x1ad>
    2f2c:	mov    eax,0x2
    2f31:	cmp    rsi,0x3
    2f35:	cmove  rax,QWORD PTR [rip+0x213]        # 3150 <botlish_fn_41+0x3c0>
    2f3d:	cmp    rax,0x6
    2f41:	je     2f59 <botlish_fn_41+0x1c9>
    2f47:	mov    rbx,QWORD PTR [rsp+0x88]
    2f4f:	mov    rsi,QWORD PTR [rsp+0x68]
    2f54:	jmp    30b0 <botlish_fn_41+0x320>
    2f59:	xor    eax,eax
    2f5b:	mov    rdx,QWORD PTR [rsp+0x70]
    2f60:	test   rdx,0x7
    2f67:	je     2f77 <botlish_fn_41+0x1e7>
    2f6d:	mov    QWORD PTR [rsp+0x70],rdx
    2f72:	jmp    2f85 <botlish_fn_41+0x1f5>
    2f77:	movzx  rax,BYTE PTR [rdx]
    2f7b:	mov    QWORD PTR [rsp+0x70],rdx
    2f80:	cmp    al,0x8
    2f82:	sete   al
    2f85:	test   al,al
    2f87:	jne    2fae <botlish_fn_41+0x21e>
    2f8d:	mov    rdi,QWORD PTR [rsp+0x60]
    2f92:	mov    rax,QWORD PTR [rdi+0x10]
    2f96:	mov    rcx,QWORD PTR [rax+0x20]
    2f9a:	mov    edx,0x8
    2f9f:	mov    rsi,QWORD PTR [rsp+0x70]
    2fa4:	call   2fa9 <botlish_fn_41+0x219>
			2fa5: R_X86_64_PLT32	rt_type_error-0x4
    2fa9:	jmp    3074 <botlish_fn_41+0x2e4>
    2fae:	mov    rdx,r15
    2fb1:	mov    rsi,QWORD PTR [rsp+0x70]
    2fb6:	mov    rdi,QWORD PTR [rsp+0x60]
    2fbb:	call   2fc0 <botlish_fn_41+0x230>
			2fbc: R_X86_64_PLT32	rt_mutarray_get-0x4
    2fc0:	test   rax,rax
    2fc3:	je     3074 <botlish_fn_41+0x2e4>
    2fc9:	mov    QWORD PTR [rsp+0x50],rax
    2fce:	mov    rbx,rax
    2fd1:	xor    eax,eax
    2fd3:	mov    rcx,QWORD PTR [rsp+0x78]
    2fd8:	test   rcx,0x7
    2fdf:	je     2fef <botlish_fn_41+0x25f>
    2fe5:	mov    QWORD PTR [rsp+0x78],rcx
    2fea:	jmp    2ffd <botlish_fn_41+0x26d>
    2fef:	movzx  rax,BYTE PTR [rcx]
    2ff3:	mov    QWORD PTR [rsp+0x78],rcx
    2ff8:	cmp    al,0x8
    2ffa:	sete   al
    2ffd:	test   al,al
    2fff:	jne    3026 <botlish_fn_41+0x296>
    3005:	mov    rdi,QWORD PTR [rsp+0x60]
    300a:	mov    rcx,QWORD PTR [rdi+0x10]
    300e:	mov    rcx,QWORD PTR [rcx+0x20]
    3012:	mov    edx,0x8
    3017:	mov    rsi,QWORD PTR [rsp+0x78]
    301c:	call   3021 <botlish_fn_41+0x291>
			301d: R_X86_64_PLT32	rt_type_error-0x4
    3021:	jmp    3074 <botlish_fn_41+0x2e4>
    3026:	mov    rdx,r15
    3029:	mov    rsi,QWORD PTR [rsp+0x78]
    302e:	mov    rdi,QWORD PTR [rsp+0x60]
    3033:	call   3038 <botlish_fn_41+0x2a8>
			3034: R_X86_64_PLT32	rt_mutarray_get-0x4
    3038:	test   rax,rax
    303b:	je     3074 <botlish_fn_41+0x2e4>
    3041:	mov    QWORD PTR [rsp+0x58],rax
    3046:	mov    QWORD PTR [rsp],rax
    304a:	mov    r9,rbx
    304d:	mov    rbx,QWORD PTR [rsp+0x88]
    3055:	mov    rcx,r14
    3058:	mov    rdx,r13
    305b:	mov    rsi,r12
    305e:	mov    rdi,QWORD PTR [rsp+0x60]
    3063:	mov    r8,rbx
    3066:	call   306b <botlish_fn_41+0x2db>
			3067: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    306b:	test   rax,rax
    306e:	jne    30ab <botlish_fn_41+0x31b>
    3074:	xor    rax,rax
    3077:	mov    rbx,QWORD PTR [rsp+0x90]
    307f:	mov    r12,QWORD PTR [rsp+0x98]
    3087:	mov    r13,QWORD PTR [rsp+0xa0]
    308f:	mov    r14,QWORD PTR [rsp+0xa8]
    3097:	mov    r15,QWORD PTR [rsp+0xb0]
    309f:	add    rsp,0xc0
    30a6:	mov    rsp,rbp
    30a9:	pop    rbp
    30aa:	ret
    30ab:	mov    rsi,QWORD PTR [rsp+0x68]
    30b0:	mov    rsi,QWORD PTR [rsp+0x68]
    30b5:	mov    QWORD PTR [rsp+0x10],rsi
    30ba:	mov    rsi,QWORD PTR [rsp+0x70]
    30bf:	mov    QWORD PTR [rsp+0x18],rsi
    30c4:	mov    rsi,QWORD PTR [rsp+0x78]
    30c9:	mov    QWORD PTR [rsp+0x20],rsi
    30ce:	sar    r15,1
    30d1:	add    r15,0x1
    30d8:	shl    r15,1
    30db:	or     r15,0x1
    30df:	mov    QWORD PTR [rsp+0x28],r15
    30e4:	mov    QWORD PTR [rsp+0x30],r12
    30e9:	mov    QWORD PTR [rsp+0x38],r13
    30ee:	mov    QWORD PTR [rsp+0x40],r14
    30f3:	mov    QWORD PTR [rsp+0x48],rbx
    30f8:	mov    rsi,QWORD PTR [rsp+0x80]
    3100:	mov    r8,r15
    3103:	mov    QWORD PTR [rsp+0x88],rbx
    310b:	jmp    2e2a <botlish_fn_41+0x9a>
    3110:	mov    eax,0xa
    3115:	mov    rbx,QWORD PTR [rsp+0x90]
    311d:	mov    r12,QWORD PTR [rsp+0x98]
    3125:	mov    r13,QWORD PTR [rsp+0xa0]
    312d:	mov    r14,QWORD PTR [rsp+0xa8]
    3135:	mov    r15,QWORD PTR [rsp+0xb0]
    313d:	add    rsp,0xc0
    3144:	mov    rsp,rbp
    3147:	pop    rbp
    3148:	ret
    3149:	add    BYTE PTR [rax],al
    314b:	add    BYTE PTR [rax],al
    314d:	add    BYTE PTR [rax],al
    314f:	add    BYTE PTR [rsi],al
    3151:	add    BYTE PTR [rax],al
    3153:	add    BYTE PTR [rax],al
    3155:	add    BYTE PTR [rax],al
	...

0000000000003158 <botlish_entry_41: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    3158:	push   rbp
    3159:	mov    rbp,rsp
    315c:	sub    rsp,0x30
    3160:	mov    QWORD PTR [rsp+0x20],r12
    3165:	mov    rsi,QWORD PTR [rdx]
    3168:	mov    rax,QWORD PTR [rdx+0x8]
    316c:	mov    rcx,QWORD PTR [rdx+0x10]
    3170:	mov    r8,QWORD PTR [rdx+0x18]
    3174:	mov    r9,QWORD PTR [rdx+0x20]
    3178:	mov    r10,QWORD PTR [rdx+0x28]
    317c:	mov    r11,QWORD PTR [rdx+0x30]
    3180:	mov    r12,QWORD PTR [rdx+0x38]
    3184:	mov    rdx,QWORD PTR [rdx+0x40]
    3188:	mov    QWORD PTR [rsp],r10
    318c:	mov    QWORD PTR [rsp+0x8],r11
    3191:	mov    QWORD PTR [rsp+0x10],r12
    3196:	mov    QWORD PTR [rsp+0x18],rdx
    319b:	mov    rdx,rax
    319e:	call   31a3 <botlish_entry_41+0x4b>
			319f: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    31a3:	mov    r12,QWORD PTR [rsp+0x20]
    31a8:	add    rsp,0x30
    31ac:	mov    rsp,rbp
    31af:	pop    rbp
    31b0:	ret

00000000000031b1 <botlish_fn_42: ht_rehash<mutarray, int>>:
    31b1:	push   rbp
    31b2:	mov    rbp,rsp
    31b5:	sub    rsp,0xd0
    31bc:	mov    QWORD PTR [rsp+0xa0],rbx
    31c4:	mov    QWORD PTR [rsp+0xa8],r12
    31cc:	mov    QWORD PTR [rsp+0xb0],r13
    31d4:	mov    QWORD PTR [rsp+0xb8],r14
    31dc:	mov    QWORD PTR [rsp+0xc0],r15
    31e4:	mov    r13,rdi
    31e7:	mov    QWORD PTR [rsp+0x50],0x0
    31f0:	mov    QWORD PTR [rsp+0x58],0x0
    31f9:	mov    QWORD PTR [rsp+0x60],0x0
    3202:	mov    QWORD PTR [rsp+0x68],0x0
    320b:	mov    QWORD PTR [rsp+0x20],rsi
    3210:	mov    r12,rsi
    3213:	mov    QWORD PTR [rsp+0x28],rdx
    3218:	mov    rbx,rdx
    321b:	mov    rsi,r12
    321e:	mov    rdi,r13
    3221:	call   3226 <botlish_fn_42+0x75>
			3222: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    3226:	test   rax,rax
    3229:	je     33f8 <botlish_fn_42+0x247>
    322f:	mov    QWORD PTR [rsp+0x30],rax
    3234:	mov    r14,rax
    3237:	mov    rsi,r12
    323a:	mov    rdi,r13
    323d:	call   3242 <botlish_fn_42+0x91>
			323e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    3242:	test   rax,rax
    3245:	je     33f8 <botlish_fn_42+0x247>
    324b:	mov    QWORD PTR [rsp+0x38],rax
    3250:	mov    r15,rax
    3253:	mov    rsi,r12
    3256:	mov    rdi,r13
    3259:	call   325e <botlish_fn_42+0xad>
			325a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    325e:	test   rax,rax
    3261:	je     33f8 <botlish_fn_42+0x247>
    3267:	mov    QWORD PTR [rsp+0x40],rax
    326c:	mov    QWORD PTR [rsp+0x90],rax
    3274:	mov    rsi,r12
    3277:	mov    rdi,r13
    327a:	call   327f <botlish_fn_42+0xce>
			327b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    327f:	test   rax,rax
    3282:	je     33f8 <botlish_fn_42+0x247>
    3288:	mov    QWORD PTR [rsp+0x48],rax
    328d:	mov    QWORD PTR [rsp+0x88],rax
    3295:	mov    rsi,rbx
    3298:	mov    rdi,r13
    329b:	call   32a0 <botlish_fn_42+0xef>
			329c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    32a0:	mov    rcx,rax
    32a3:	mov    QWORD PTR [rsp+0x80],rax
    32ab:	test   rax,rcx
    32ae:	je     33f8 <botlish_fn_42+0x247>
    32b4:	mov    rax,QWORD PTR [rsp+0x80]
    32bc:	mov    QWORD PTR [rsp+0x50],rax
    32c1:	mov    edx,0x1
    32c6:	mov    QWORD PTR [rsp+0x58],0x1
    32cf:	mov    rcx,rbx
    32d2:	mov    rsi,QWORD PTR [rsp+0x80]
    32da:	mov    rdi,r13
    32dd:	call   32e2 <botlish_fn_42+0x131>
			32de: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_fill_empty<mutarray, int, int>
    32e2:	test   rax,rax
    32e5:	je     33f8 <botlish_fn_42+0x247>
    32eb:	mov    rsi,rbx
    32ee:	mov    rdi,r13
    32f1:	call   32f6 <botlish_fn_42+0x145>
			32f2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    32f6:	test   rax,rax
    32f9:	je     33f8 <botlish_fn_42+0x247>
    32ff:	mov    QWORD PTR [rsp+0x58],rax
    3304:	mov    QWORD PTR [rsp+0x78],rax
    3309:	mov    rsi,rbx
    330c:	mov    rdi,r13
    330f:	call   3314 <botlish_fn_42+0x163>
			3310: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3314:	test   rax,rax
    3317:	je     33f8 <botlish_fn_42+0x247>
    331d:	mov    QWORD PTR [rsp+0x60],rax
    3322:	mov    r8d,0x1
    3328:	mov    QWORD PTR [rsp+0x68],0x1
    3331:	mov    rcx,QWORD PTR [rsp+0x80]
    3339:	mov    QWORD PTR [rsp],rcx
    333d:	mov    rcx,QWORD PTR [rsp+0x78]
    3342:	mov    QWORD PTR [rsp+0x8],rcx
    3347:	mov    QWORD PTR [rsp+0x10],rax
    334c:	mov    QWORD PTR [rsp+0x70],rax
    3351:	mov    QWORD PTR [rsp+0x18],rbx
    3356:	mov    rcx,QWORD PTR [rsp+0x90]
    335e:	mov    rdx,r15
    3361:	mov    rsi,r14
    3364:	mov    r9,QWORD PTR [rsp+0x88]
    336c:	mov    rdi,r13
    336f:	call   3374 <botlish_fn_42+0x1c3>
			3370: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    3374:	test   rax,rax
    3377:	je     33f8 <botlish_fn_42+0x247>
    337d:	mov    edx,0x1
    3382:	mov    rcx,QWORD PTR [rsp+0x80]
    338a:	mov    rsi,r12
    338d:	mov    rdi,r13
    3390:	call   3395 <botlish_fn_42+0x1e4>
			3391: R_X86_64_PLT32	rt_mutarray_set-0x4
    3395:	test   rax,rax
    3398:	je     33f8 <botlish_fn_42+0x247>
    339e:	mov    edx,0x3
    33a3:	mov    rcx,QWORD PTR [rsp+0x78]
    33a8:	mov    rsi,r12
    33ab:	mov    rdi,r13
    33ae:	call   33b3 <botlish_fn_42+0x202>
			33af: R_X86_64_PLT32	rt_mutarray_set-0x4
    33b3:	test   rax,rax
    33b6:	je     33f8 <botlish_fn_42+0x247>
    33bc:	mov    edx,0x5
    33c1:	mov    rcx,QWORD PTR [rsp+0x70]
    33c6:	mov    rsi,r12
    33c9:	mov    rdi,r13
    33cc:	call   33d1 <botlish_fn_42+0x220>
			33cd: R_X86_64_PLT32	rt_mutarray_set-0x4
    33d1:	test   rax,rax
    33d4:	je     33f8 <botlish_fn_42+0x247>
    33da:	mov    edx,0x9
    33df:	mov    ecx,0x1
    33e4:	mov    rsi,r12
    33e7:	mov    rdi,r13
    33ea:	call   33ef <botlish_fn_42+0x23e>
			33eb: R_X86_64_PLT32	rt_mutarray_set-0x4
    33ef:	test   rax,rax
    33f2:	jne    342f <botlish_fn_42+0x27e>
    33f8:	xor    rax,rax
    33fb:	mov    rbx,QWORD PTR [rsp+0xa0]
    3403:	mov    r12,QWORD PTR [rsp+0xa8]
    340b:	mov    r13,QWORD PTR [rsp+0xb0]
    3413:	mov    r14,QWORD PTR [rsp+0xb8]
    341b:	mov    r15,QWORD PTR [rsp+0xc0]
    3423:	add    rsp,0xd0
    342a:	mov    rsp,rbp
    342d:	pop    rbp
    342e:	ret
    342f:	mov    eax,0xa
    3434:	mov    rbx,QWORD PTR [rsp+0xa0]
    343c:	mov    r12,QWORD PTR [rsp+0xa8]
    3444:	mov    r13,QWORD PTR [rsp+0xb0]
    344c:	mov    r14,QWORD PTR [rsp+0xb8]
    3454:	mov    r15,QWORD PTR [rsp+0xc0]
    345c:	add    rsp,0xd0
    3463:	mov    rsp,rbp
    3466:	pop    rbp
    3467:	ret

0000000000003468 <botlish_entry_42: ht_rehash<mutarray, int>>:
    3468:	push   rbp
    3469:	mov    rbp,rsp
    346c:	mov    rsi,QWORD PTR [rdx]
    346f:	mov    rdx,QWORD PTR [rdx+0x8]
    3473:	call   3478 <botlish_entry_42+0x10>
			3474: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    3478:	mov    rsp,rbp
    347b:	pop    rbp
    347c:	ret
    347d:	add    BYTE PTR [rax],al
	...

0000000000003480 <botlish_fn_43: ht_should_grow<mutarray>>:
    3480:	push   rbp
    3481:	mov    rbp,rsp
    3484:	sub    rsp,0x40
    3488:	mov    QWORD PTR [rsp+0x20],rbx
    348d:	mov    QWORD PTR [rsp+0x28],r12
    3492:	mov    QWORD PTR [rsp+0x30],r13
    3497:	mov    rbx,rdi
    349a:	mov    QWORD PTR [rsp],rsi
    349e:	mov    r12,rsi
    34a1:	mov    rsi,r12
    34a4:	mov    rdi,rbx
    34a7:	call   34ac <botlish_fn_43+0x2c>
			34a8: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    34ac:	mov    rcx,rax
    34af:	mov    r13,rax
    34b2:	test   rax,rcx
    34b5:	je     36a4 <botlish_fn_43+0x224>
    34bb:	mov    rax,r13
    34be:	mov    QWORD PTR [rsp+0x8],rax
    34c3:	mov    rsi,r12
    34c6:	mov    rdi,rbx
    34c9:	call   34ce <botlish_fn_43+0x4e>
			34ca: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    34ce:	mov    rcx,rax
    34d1:	test   rcx,rcx
    34d4:	je     36a4 <botlish_fn_43+0x224>
    34da:	mov    QWORD PTR [rsp+0x10],rcx
    34df:	mov    edx,0x1
    34e4:	mov    rax,r13
    34e7:	test   rax,0x1
    34ed:	jne    3510 <botlish_fn_43+0x90>
    34f3:	xor    edx,edx
    34f5:	mov    rax,r13
    34f8:	test   rax,0x7
    34fe:	jne    3510 <botlish_fn_43+0x90>
    3504:	mov    rax,r13
    3507:	movzx  rax,BYTE PTR [rax]
    350b:	cmp    al,0x1
    350d:	sete   dl
    3510:	test   dl,dl
    3512:	jne    3533 <botlish_fn_43+0xb3>
    3518:	mov    rdi,rbx
    351b:	mov    rax,QWORD PTR [rdi+0x10]
    351f:	mov    rcx,QWORD PTR [rax+0x30]
    3523:	xor    rdx,rdx
    3526:	mov    rsi,r13
    3529:	call   352e <botlish_fn_43+0xae>
			352a: R_X86_64_PLT32	rt_type_error-0x4
    352e:	jmp    36a4 <botlish_fn_43+0x224>
    3533:	mov    eax,0x1
    3538:	test   rcx,0x1
    353f:	je     354d <botlish_fn_43+0xcd>
    3545:	mov    r8,rcx
    3548:	jmp    3570 <botlish_fn_43+0xf0>
    354d:	xor    eax,eax
    354f:	test   rcx,0x7
    3556:	je     3564 <botlish_fn_43+0xe4>
    355c:	mov    r8,rcx
    355f:	jmp    3570 <botlish_fn_43+0xf0>
    3564:	movzx  rax,BYTE PTR [rcx]
    3568:	mov    r8,rcx
    356b:	cmp    al,0x1
    356d:	sete   al
    3570:	test   al,al
    3572:	jne    3593 <botlish_fn_43+0x113>
    3578:	mov    rdi,rbx
    357b:	mov    rax,QWORD PTR [rdi+0x10]
    357f:	mov    rcx,QWORD PTR [rax+0x30]
    3583:	xor    rdx,rdx
    3586:	mov    rsi,r8
    3589:	call   358e <botlish_fn_43+0x10e>
			358a: R_X86_64_PLT32	rt_type_error-0x4
    358e:	jmp    36a4 <botlish_fn_43+0x224>
    3593:	mov    rcx,r8
    3596:	mov    rsi,r13
    3599:	mov    rax,rsi
    359c:	and    rax,rcx
    359f:	test   rax,0x1
    35a5:	jne    35b6 <botlish_fn_43+0x136>
    35ab:	mov    rdx,r8
    35ae:	mov    rsi,r13
    35b1:	jmp    35d4 <botlish_fn_43+0x154>
    35b6:	mov    rcx,r8
    35b9:	lea    rax,[rcx-0x1]
    35bd:	mov    rsi,r13
    35c0:	add    rsi,rax
    35c3:	seto   al
    35c6:	test   al,al
    35c8:	je     35df <botlish_fn_43+0x15f>
    35ce:	mov    rdx,r8
    35d1:	mov    rsi,r13
    35d4:	mov    rdi,rbx
    35d7:	call   35dc <botlish_fn_43+0x15c>
			35d8: R_X86_64_PLT32	rt_int_add-0x4
    35dc:	mov    rsi,rax
    35df:	mov    QWORD PTR [rsp+0x8],rsi
    35e4:	mov    QWORD PTR [rsp+0x10],0x3
    35ed:	test   rsi,0x1
    35f4:	je     3617 <botlish_fn_43+0x197>
    35fa:	mov    rax,rsi
    35fd:	add    rax,0x2
    3601:	mov    rcx,rax
    3604:	seto   al
    3607:	test   al,al
    3609:	jne    3617 <botlish_fn_43+0x197>
    360f:	mov    rsi,rcx
    3612:	jmp    3627 <botlish_fn_43+0x1a7>
    3617:	mov    edx,0x3
    361c:	mov    rdi,rbx
    361f:	call   3624 <botlish_fn_43+0x1a4>
			3620: R_X86_64_PLT32	rt_int_add-0x4
    3624:	mov    rsi,rax
    3627:	mov    QWORD PTR [rsp+0x8],rsi
    362c:	mov    edx,0x7
    3631:	mov    rdi,rdx
    3634:	mov    QWORD PTR [rsp+0x10],0x7
    363d:	test   rsi,0x1
    3644:	jne    3652 <botlish_fn_43+0x1d2>
    364a:	mov    rdx,rdi
    364d:	jmp    367e <botlish_fn_43+0x1fe>
    3652:	mov    rax,rsi
    3655:	sar    rax,1
    3658:	imul   QWORD PTR [rip+0x119]        # 3778 <botlish_fn_43+0x2f8>
    365f:	seto   cl
    3662:	or     rax,0x1
    3666:	test   cl,cl
    3668:	je     3676 <botlish_fn_43+0x1f6>
    366e:	mov    rdx,rdi
    3671:	jmp    367e <botlish_fn_43+0x1fe>
    3676:	mov    rsi,rax
    3679:	jmp    3689 <botlish_fn_43+0x209>
    367e:	mov    rdi,rbx
    3681:	call   3686 <botlish_fn_43+0x206>
			3682: R_X86_64_PLT32	rt_int_mul-0x4
    3686:	mov    rsi,rax
    3689:	mov    QWORD PTR [rsp],rsi
    368d:	mov    r13,rsi
    3690:	mov    rsi,r12
    3693:	mov    rdi,rbx
    3696:	call   369b <botlish_fn_43+0x21b>
			3697: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    369b:	test   rax,rax
    369e:	jne    36bf <botlish_fn_43+0x23f>
    36a4:	xor    rax,rax
    36a7:	mov    rbx,QWORD PTR [rsp+0x20]
    36ac:	mov    r12,QWORD PTR [rsp+0x28]
    36b1:	mov    r13,QWORD PTR [rsp+0x30]
    36b6:	add    rsp,0x40
    36ba:	mov    rsp,rbp
    36bd:	pop    rbp
    36be:	ret
    36bf:	mov    QWORD PTR [rsp+0x8],rax
    36c4:	mov    QWORD PTR [rsp+0x10],0x5
    36cd:	test   rax,0x1
    36d3:	mov    rsi,rax
    36d6:	je     3708 <botlish_fn_43+0x288>
    36dc:	mov    rcx,rsi
    36df:	mov    rax,rcx
    36e2:	sar    rax,1
    36e5:	imul   QWORD PTR [rip+0x94]        # 3780 <botlish_fn_43+0x300>
    36ec:	seto   dil
    36f0:	or     rax,0x1
    36f4:	test   dil,dil
    36f7:	jne    3708 <botlish_fn_43+0x288>
    36fd:	mov    rdx,rax
    3700:	mov    rsi,r13
    3703:	jmp    371b <botlish_fn_43+0x29b>
    3708:	mov    edx,0x5
    370d:	mov    rdi,rbx
    3710:	call   3715 <botlish_fn_43+0x295>
			3711: R_X86_64_PLT32	rt_int_mul-0x4
    3715:	mov    rdx,rax
    3718:	mov    rsi,r13
    371b:	mov    r10,rsi
    371e:	and    r10,rdx
    3721:	test   r10,0x1
    3728:	jne    374f <botlish_fn_43+0x2cf>
    372e:	mov    rdi,rbx
    3731:	call   3736 <botlish_fn_43+0x2b6>
			3732: R_X86_64_PLT32	rt_int_cmp-0x4
    3736:	mov    r8d,0x2
    373c:	test   rax,rax
    373f:	mov    rax,r8
    3742:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3778 <botlish_fn_43+0x2f8>
    374a:	jmp    375f <botlish_fn_43+0x2df>
    374f:	mov    eax,0x2
    3754:	cmp    rsi,rdx
    3757:	cmovg  rax,QWORD PTR [rip+0x19]        # 3778 <botlish_fn_43+0x2f8>
    375f:	mov    rbx,QWORD PTR [rsp+0x20]
    3764:	mov    r12,QWORD PTR [rsp+0x28]
    3769:	mov    r13,QWORD PTR [rsp+0x30]
    376e:	add    rsp,0x40
    3772:	mov    rsp,rbp
    3775:	pop    rbp
    3776:	ret
    3777:	add    BYTE PTR [rsi],al
    3779:	add    BYTE PTR [rax],al
    377b:	add    BYTE PTR [rax],al
    377d:	add    BYTE PTR [rax],al
    377f:	add    BYTE PTR [rax+rax*1],al
    3782:	add    BYTE PTR [rax],al
    3784:	add    BYTE PTR [rax],al
	...

0000000000003788 <botlish_entry_43: ht_should_grow<mutarray>>:
    3788:	push   rbp
    3789:	mov    rbp,rsp
    378c:	mov    rsi,QWORD PTR [rdx]
    378f:	call   3794 <botlish_entry_43+0xc>
			3790: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_should_grow<mutarray>
    3794:	mov    rsp,rbp
    3797:	pop    rbp
    3798:	ret
    3799:	add    BYTE PTR [rax],al
    379b:	add    BYTE PTR [rax],al
    379d:	add    BYTE PTR [rax],al
	...

00000000000037a0 <botlish_fn_44: ht_grow_or_clean<mutarray>>:
    37a0:	push   rbp
    37a1:	mov    rbp,rsp
    37a4:	sub    rsp,0x40
    37a8:	mov    QWORD PTR [rsp+0x20],rbx
    37ad:	mov    QWORD PTR [rsp+0x28],r12
    37b2:	mov    QWORD PTR [rsp+0x30],r13
    37b7:	mov    rbx,rdi
    37ba:	mov    QWORD PTR [rsp+0x10],0x0
    37c3:	mov    QWORD PTR [rsp],rsi
    37c7:	mov    r12,rsi
    37ca:	mov    rsi,r12
    37cd:	mov    rdi,rbx
    37d0:	call   37d5 <botlish_fn_44+0x35>
			37d1: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    37d5:	test   rax,rax
    37d8:	mov    r13,rax
    37db:	je     39c8 <botlish_fn_44+0x228>
    37e1:	mov    rsi,r12
    37e4:	mov    rdi,rbx
    37e7:	call   37ec <botlish_fn_44+0x4c>
			37e8: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    37ec:	mov    rcx,rax
    37ef:	test   rcx,rcx
    37f2:	je     39c8 <botlish_fn_44+0x228>
    37f8:	mov    edx,0x1
    37fd:	mov    rax,r13
    3800:	test   rax,0x1
    3806:	je     3814 <botlish_fn_44+0x74>
    380c:	mov    r13,rax
    380f:	jmp    3838 <botlish_fn_44+0x98>
    3814:	xor    edx,edx
    3816:	test   rax,0x7
    381c:	je     382a <botlish_fn_44+0x8a>
    3822:	mov    r13,rax
    3825:	jmp    3838 <botlish_fn_44+0x98>
    382a:	movzx  rdx,BYTE PTR [rax]
    382e:	mov    r13,rax
    3831:	rex cmp dl,0x1
    3835:	sete   dl
    3838:	test   dl,dl
    383a:	jne    385b <botlish_fn_44+0xbb>
    3840:	mov    rdi,rbx
    3843:	mov    rsi,QWORD PTR [rdi+0x10]
    3847:	mov    rcx,QWORD PTR [rsi+0x38]
    384b:	xor    rdx,rdx
    384e:	mov    rsi,r13
    3851:	call   3856 <botlish_fn_44+0xb6>
			3852: R_X86_64_PLT32	rt_type_error-0x4
    3856:	jmp    39c8 <botlish_fn_44+0x228>
    385b:	mov    rsi,r13
    385e:	mov    eax,0x1
    3863:	test   rcx,0x1
    386a:	je     3878 <botlish_fn_44+0xd8>
    3870:	mov    r8,rcx
    3873:	jmp    389d <botlish_fn_44+0xfd>
    3878:	xor    eax,eax
    387a:	test   rcx,0x7
    3881:	je     388f <botlish_fn_44+0xef>
    3887:	mov    r8,rcx
    388a:	jmp    389d <botlish_fn_44+0xfd>
    388f:	movzx  r11,BYTE PTR [rcx]
    3893:	mov    r8,rcx
    3896:	cmp    r11b,0x1
    389a:	sete   al
    389d:	test   al,al
    389f:	jne    38c0 <botlish_fn_44+0x120>
    38a5:	mov    rdi,rbx
    38a8:	mov    rax,QWORD PTR [rdi+0x10]
    38ac:	mov    rcx,QWORD PTR [rax+0x38]
    38b0:	xor    rdx,rdx
    38b3:	mov    rsi,r8
    38b6:	call   38bb <botlish_fn_44+0x11b>
			38b7: R_X86_64_PLT32	rt_type_error-0x4
    38bb:	jmp    39c8 <botlish_fn_44+0x228>
    38c0:	mov    rcx,r8
    38c3:	mov    rax,rsi
    38c6:	and    rax,rcx
    38c9:	test   rax,0x1
    38cf:	jne    38f5 <botlish_fn_44+0x155>
    38d5:	mov    rdx,r8
    38d8:	mov    rdi,rbx
    38db:	call   38e0 <botlish_fn_44+0x140>
			38dc: R_X86_64_PLT32	rt_int_cmp-0x4
    38e0:	mov    ecx,0x2
    38e5:	test   rax,rax
    38e8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3a00 <botlish_fn_44+0x260>
    38f0:	jmp    3908 <botlish_fn_44+0x168>
    38f5:	mov    ecx,0x2
    38fa:	mov    r9,r8
    38fd:	cmp    rsi,r9
    3900:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3a00 <botlish_fn_44+0x260>
    3908:	cmp    rcx,0x6
    390c:	je     3998 <botlish_fn_44+0x1f8>
    3912:	mov    rsi,r12
    3915:	mov    rdi,rbx
    3918:	call   391d <botlish_fn_44+0x17d>
			3919: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    391d:	test   rax,rax
    3920:	je     39c8 <botlish_fn_44+0x228>
    3926:	mov    QWORD PTR [rsp+0x8],rax
    392b:	mov    QWORD PTR [rsp+0x10],0x5
    3934:	test   rax,0x1
    393a:	mov    rsi,rax
    393d:	je     396a <botlish_fn_44+0x1ca>
    3943:	mov    rcx,rsi
    3946:	mov    rax,rcx
    3949:	sar    rax,1
    394c:	imul   QWORD PTR [rip+0xb5]        # 3a08 <botlish_fn_44+0x268>
    3953:	seto   cl
    3956:	or     rax,0x1
    395a:	test   cl,cl
    395c:	jne    396a <botlish_fn_44+0x1ca>
    3962:	mov    rdx,rax
    3965:	jmp    397a <botlish_fn_44+0x1da>
    396a:	mov    edx,0x5
    396f:	mov    rdi,rbx
    3972:	call   3977 <botlish_fn_44+0x1d7>
			3973: R_X86_64_PLT32	rt_int_mul-0x4
    3977:	mov    rdx,rax
    397a:	mov    QWORD PTR [rsp+0x8],rdx
    397f:	mov    rsi,r12
    3982:	mov    rdi,rbx
    3985:	call   398a <botlish_fn_44+0x1ea>
			3986: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    398a:	test   rax,rax
    398d:	je     39c8 <botlish_fn_44+0x228>
    3993:	jmp    39e3 <botlish_fn_44+0x243>
    3998:	mov    rsi,r12
    399b:	mov    rdi,rbx
    399e:	call   39a3 <botlish_fn_44+0x203>
			399f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    39a3:	test   rax,rax
    39a6:	je     39c8 <botlish_fn_44+0x228>
    39ac:	mov    QWORD PTR [rsp+0x8],rax
    39b1:	mov    rdx,rax
    39b4:	mov    rsi,r12
    39b7:	mov    rdi,rbx
    39ba:	call   39bf <botlish_fn_44+0x21f>
			39bb: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    39bf:	test   rax,rax
    39c2:	jne    39e3 <botlish_fn_44+0x243>
    39c8:	xor    rax,rax
    39cb:	mov    rbx,QWORD PTR [rsp+0x20]
    39d0:	mov    r12,QWORD PTR [rsp+0x28]
    39d5:	mov    r13,QWORD PTR [rsp+0x30]
    39da:	add    rsp,0x40
    39de:	mov    rsp,rbp
    39e1:	pop    rbp
    39e2:	ret
    39e3:	mov    rbx,QWORD PTR [rsp+0x20]
    39e8:	mov    r12,QWORD PTR [rsp+0x28]
    39ed:	mov    r13,QWORD PTR [rsp+0x30]
    39f2:	add    rsp,0x40
    39f6:	mov    rsp,rbp
    39f9:	pop    rbp
    39fa:	ret
    39fb:	add    BYTE PTR [rax],al
    39fd:	add    BYTE PTR [rax],al
    39ff:	add    BYTE PTR [rsi],al
    3a01:	add    BYTE PTR [rax],al
    3a03:	add    BYTE PTR [rax],al
    3a05:	add    BYTE PTR [rax],al
    3a07:	add    BYTE PTR [rax+rax*1],al
    3a0a:	add    BYTE PTR [rax],al
    3a0c:	add    BYTE PTR [rax],al
	...

0000000000003a10 <botlish_entry_44: ht_grow_or_clean<mutarray>>:
    3a10:	push   rbp
    3a11:	mov    rbp,rsp
    3a14:	mov    rsi,QWORD PTR [rdx]
    3a17:	call   3a1c <botlish_entry_44+0xc>
			3a18: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_grow_or_clean<mutarray>
    3a1c:	mov    rsp,rbp
    3a1f:	pop    rbp
    3a20:	ret
    3a21:	add    BYTE PTR [rax],al
    3a23:	add    BYTE PTR [rax],al
    3a25:	add    BYTE PTR [rax],al
	...

0000000000003a28 <botlish_fn_45: ht_place<mutarray, int, any, any>>:
    3a28:	push   rbp
    3a29:	mov    rbp,rsp
    3a2c:	sub    rsp,0x70
    3a30:	mov    QWORD PTR [rsp+0x40],rbx
    3a35:	mov    QWORD PTR [rsp+0x48],r12
    3a3a:	mov    QWORD PTR [rsp+0x50],r13
    3a3f:	mov    QWORD PTR [rsp+0x58],r14
    3a44:	mov    QWORD PTR [rsp+0x60],r15
    3a49:	mov    rbx,rdi
    3a4c:	mov    r14,r8
    3a4f:	mov    r15,rdx
    3a52:	mov    QWORD PTR [rsp+0x28],rcx
    3a57:	mov    QWORD PTR [rsp],rsi
    3a5b:	mov    r12,rsi
    3a5e:	mov    rsi,r12
    3a61:	mov    rdi,rbx
    3a64:	call   3a69 <botlish_fn_45+0x41>
			3a65: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    3a69:	test   rax,rax
    3a6c:	je     3dd2 <botlish_fn_45+0x3aa>
    3a72:	xor    ecx,ecx
    3a74:	test   rax,0x7
    3a7a:	je     3a8a <botlish_fn_45+0x62>
    3a80:	mov    QWORD PTR [rsp+0x30],rax
    3a85:	jmp    3a9a <botlish_fn_45+0x72>
    3a8a:	movzx  rcx,BYTE PTR [rax]
    3a8e:	mov    QWORD PTR [rsp+0x30],rax
    3a93:	rex cmp cl,0x8
    3a97:	sete   cl
    3a9a:	test   cl,cl
    3a9c:	jne    3ac1 <botlish_fn_45+0x99>
    3aa2:	mov    rdi,rbx
    3aa5:	mov    rax,QWORD PTR [rdi+0x10]
    3aa9:	mov    rcx,QWORD PTR [rax+0x20]
    3aad:	mov    edx,0x8
    3ab2:	mov    rsi,QWORD PTR [rsp+0x30]
    3ab7:	call   3abc <botlish_fn_45+0x94>
			3ab8: R_X86_64_PLT32	rt_type_error-0x4
    3abc:	jmp    3dd2 <botlish_fn_45+0x3aa>
    3ac1:	mov    rdx,r15
    3ac4:	mov    rsi,QWORD PTR [rsp+0x30]
    3ac9:	mov    rdi,rbx
    3acc:	call   3ad1 <botlish_fn_45+0xa9>
			3acd: R_X86_64_PLT32	rt_mutarray_get-0x4
    3ad1:	test   rax,rax
    3ad4:	je     3dd2 <botlish_fn_45+0x3aa>
    3ada:	mov    QWORD PTR [rsp+0x8],rax
    3adf:	mov    r13,rax
    3ae2:	mov    ecx,0x3
    3ae7:	mov    rsi,QWORD PTR [rsp+0x30]
    3aec:	mov    rdx,r15
    3aef:	mov    rdi,rbx
    3af2:	call   3af7 <botlish_fn_45+0xcf>
			3af3: R_X86_64_PLT32	rt_mutarray_set-0x4
    3af7:	test   rax,rax
    3afa:	je     3dd2 <botlish_fn_45+0x3aa>
    3b00:	mov    rsi,r12
    3b03:	mov    rdi,rbx
    3b06:	call   3b0b <botlish_fn_45+0xe3>
			3b07: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    3b0b:	test   rax,rax
    3b0e:	je     3dd2 <botlish_fn_45+0x3aa>
    3b14:	xor    ecx,ecx
    3b16:	test   rax,0x7
    3b1c:	je     3b2a <botlish_fn_45+0x102>
    3b22:	mov    rsi,rax
    3b25:	jmp    3b38 <botlish_fn_45+0x110>
    3b2a:	movzx  rcx,BYTE PTR [rax]
    3b2e:	mov    rsi,rax
    3b31:	rex cmp cl,0x8
    3b35:	sete   cl
    3b38:	test   cl,cl
    3b3a:	jne    3b5a <botlish_fn_45+0x132>
    3b40:	mov    rdi,rbx
    3b43:	mov    rax,QWORD PTR [rdi+0x10]
    3b47:	mov    rcx,QWORD PTR [rax+0x40]
    3b4b:	mov    edx,0x8
    3b50:	call   3b55 <botlish_fn_45+0x12d>
			3b51: R_X86_64_PLT32	rt_type_error-0x4
    3b55:	jmp    3dd2 <botlish_fn_45+0x3aa>
    3b5a:	mov    rcx,QWORD PTR [rsp+0x28]
    3b5f:	mov    rdx,r15
    3b62:	mov    rdi,rbx
    3b65:	call   3b6a <botlish_fn_45+0x142>
			3b66: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b6a:	test   rax,rax
    3b6d:	je     3dd2 <botlish_fn_45+0x3aa>
    3b73:	mov    rsi,r12
    3b76:	mov    rdi,rbx
    3b79:	call   3b7e <botlish_fn_45+0x156>
			3b7a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    3b7e:	test   rax,rax
    3b81:	je     3dd2 <botlish_fn_45+0x3aa>
    3b87:	xor    esi,esi
    3b89:	test   rax,0x7
    3b8f:	jne    3ba1 <botlish_fn_45+0x179>
    3b95:	movzx  rcx,BYTE PTR [rax]
    3b99:	rex cmp cl,0x8
    3b9d:	sete   sil
    3ba1:	test   sil,sil
    3ba4:	jne    3bc7 <botlish_fn_45+0x19f>
    3baa:	mov    rdi,rbx
    3bad:	mov    rsi,QWORD PTR [rdi+0x10]
    3bb1:	mov    rcx,QWORD PTR [rsi+0x40]
    3bb5:	mov    edx,0x8
    3bba:	mov    rsi,rax
    3bbd:	call   3bc2 <botlish_fn_45+0x19a>
			3bbe: R_X86_64_PLT32	rt_type_error-0x4
    3bc2:	jmp    3dd2 <botlish_fn_45+0x3aa>
    3bc7:	mov    rcx,r14
    3bca:	mov    rdx,r15
    3bcd:	mov    rsi,rax
    3bd0:	mov    rdi,rbx
    3bd3:	call   3bd8 <botlish_fn_45+0x1b0>
			3bd4: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bd8:	test   rax,rax
    3bdb:	je     3dd2 <botlish_fn_45+0x3aa>
    3be1:	mov    QWORD PTR [rsp+0x10],0x7
    3bea:	mov    rsi,r12
    3bed:	mov    rdi,rbx
    3bf0:	call   3bf5 <botlish_fn_45+0x1cd>
			3bf1: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    3bf5:	test   rax,rax
    3bf8:	je     3dd2 <botlish_fn_45+0x3aa>
    3bfe:	mov    QWORD PTR [rsp+0x18],rax
    3c03:	mov    QWORD PTR [rsp+0x20],0x3
    3c0c:	mov    ecx,0x1
    3c11:	test   rax,0x1
    3c17:	je     3c25 <botlish_fn_45+0x1fd>
    3c1d:	mov    rsi,rax
    3c20:	jmp    3c49 <botlish_fn_45+0x221>
    3c25:	xor    ecx,ecx
    3c27:	test   rax,0x7
    3c2d:	je     3c3b <botlish_fn_45+0x213>
    3c33:	mov    rsi,rax
    3c36:	jmp    3c49 <botlish_fn_45+0x221>
    3c3b:	movzx  rcx,BYTE PTR [rax]
    3c3f:	mov    rsi,rax
    3c42:	rex cmp cl,0x1
    3c46:	sete   cl
    3c49:	test   cl,cl
    3c4b:	jne    3c69 <botlish_fn_45+0x241>
    3c51:	mov    rdi,rbx
    3c54:	mov    rax,QWORD PTR [rdi+0x10]
    3c58:	mov    rcx,QWORD PTR [rax+0x30]
    3c5c:	xor    rdx,rdx
    3c5f:	call   3c64 <botlish_fn_45+0x23c>
			3c60: R_X86_64_PLT32	rt_type_error-0x4
    3c64:	jmp    3dd2 <botlish_fn_45+0x3aa>
    3c69:	test   rsi,0x1
    3c70:	je     3c88 <botlish_fn_45+0x260>
    3c76:	mov    rcx,rsi
    3c79:	add    rcx,0x2
    3c7d:	seto   al
    3c80:	test   al,al
    3c82:	je     3c98 <botlish_fn_45+0x270>
    3c88:	mov    edx,0x3
    3c8d:	mov    rdi,rbx
    3c90:	call   3c95 <botlish_fn_45+0x26d>
			3c91: R_X86_64_PLT32	rt_int_add-0x4
    3c95:	mov    rcx,rax
    3c98:	mov    edx,0x7
    3c9d:	mov    rsi,r12
    3ca0:	mov    rdi,rbx
    3ca3:	call   3ca8 <botlish_fn_45+0x280>
			3ca4: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ca8:	test   rax,rax
    3cab:	je     3dd2 <botlish_fn_45+0x3aa>
    3cb1:	mov    rax,r13
    3cb4:	test   rax,0x1
    3cba:	jne    3cde <botlish_fn_45+0x2b6>
    3cc0:	mov    edx,0x5
    3cc5:	mov    rsi,r13
    3cc8:	mov    rdi,rbx
    3ccb:	call   3cd0 <botlish_fn_45+0x2a8>
			3ccc: R_X86_64_PLT32	rt_value_eq-0x4
    3cd0:	test   rax,rax
    3cd3:	je     3dd2 <botlish_fn_45+0x3aa>
    3cd9:	jmp    3cf2 <botlish_fn_45+0x2ca>
    3cde:	mov    rsi,r13
    3ce1:	mov    eax,0x2
    3ce6:	cmp    rsi,0x5
    3cea:	cmove  rax,QWORD PTR [rip+0x12e]        # 3e20 <botlish_fn_45+0x3f8>
    3cf2:	cmp    rax,0x6
    3cf6:	jne    3df7 <botlish_fn_45+0x3cf>
    3cfc:	mov    QWORD PTR [rsp+0x8],0x9
    3d05:	mov    rsi,r12
    3d08:	mov    rdi,rbx
    3d0b:	call   3d10 <botlish_fn_45+0x2e8>
			3d0c: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    3d10:	test   rax,rax
    3d13:	je     3dd2 <botlish_fn_45+0x3aa>
    3d19:	mov    QWORD PTR [rsp+0x10],rax
    3d1e:	mov    QWORD PTR [rsp+0x18],0x3
    3d27:	mov    ecx,0x1
    3d2c:	test   rax,0x1
    3d32:	je     3d40 <botlish_fn_45+0x318>
    3d38:	mov    rsi,rax
    3d3b:	jmp    3d64 <botlish_fn_45+0x33c>
    3d40:	xor    ecx,ecx
    3d42:	test   rax,0x7
    3d48:	je     3d56 <botlish_fn_45+0x32e>
    3d4e:	mov    rsi,rax
    3d51:	jmp    3d64 <botlish_fn_45+0x33c>
    3d56:	movzx  rcx,BYTE PTR [rax]
    3d5a:	mov    rsi,rax
    3d5d:	rex cmp cl,0x1
    3d61:	sete   cl
    3d64:	test   cl,cl
    3d66:	jne    3d84 <botlish_fn_45+0x35c>
    3d6c:	mov    rdi,rbx
    3d6f:	mov    rcx,QWORD PTR [rdi+0x10]
    3d73:	mov    rcx,QWORD PTR [rcx+0x48]
    3d77:	xor    rdx,rdx
    3d7a:	call   3d7f <botlish_fn_45+0x357>
			3d7b: R_X86_64_PLT32	rt_type_error-0x4
    3d7f:	jmp    3dd2 <botlish_fn_45+0x3aa>
    3d84:	test   rsi,0x1
    3d8b:	je     3da9 <botlish_fn_45+0x381>
    3d91:	mov    r8,rsi
    3d94:	sub    r8,0x3
    3d98:	seto   dil
    3d9c:	lea    rcx,[r8+0x1]
    3da0:	test   dil,dil
    3da3:	je     3db9 <botlish_fn_45+0x391>
    3da9:	mov    edx,0x3
    3dae:	mov    rdi,rbx
    3db1:	call   3db6 <botlish_fn_45+0x38e>
			3db2: R_X86_64_PLT32	rt_int_sub-0x4
    3db6:	mov    rcx,rax
    3db9:	mov    edx,0x9
    3dbe:	mov    rsi,r12
    3dc1:	mov    rdi,rbx
    3dc4:	call   3dc9 <botlish_fn_45+0x3a1>
			3dc5: R_X86_64_PLT32	rt_mutarray_set-0x4
    3dc9:	test   rax,rax
    3dcc:	jne    3df7 <botlish_fn_45+0x3cf>
    3dd2:	xor    rax,rax
    3dd5:	mov    rbx,QWORD PTR [rsp+0x40]
    3dda:	mov    r12,QWORD PTR [rsp+0x48]
    3ddf:	mov    r13,QWORD PTR [rsp+0x50]
    3de4:	mov    r14,QWORD PTR [rsp+0x58]
    3de9:	mov    r15,QWORD PTR [rsp+0x60]
    3dee:	add    rsp,0x70
    3df2:	mov    rsp,rbp
    3df5:	pop    rbp
    3df6:	ret
    3df7:	mov    eax,0xa
    3dfc:	mov    rbx,QWORD PTR [rsp+0x40]
    3e01:	mov    r12,QWORD PTR [rsp+0x48]
    3e06:	mov    r13,QWORD PTR [rsp+0x50]
    3e0b:	mov    r14,QWORD PTR [rsp+0x58]
    3e10:	mov    r15,QWORD PTR [rsp+0x60]
    3e15:	add    rsp,0x70
    3e19:	mov    rsp,rbp
    3e1c:	pop    rbp
    3e1d:	ret
    3e1e:	add    BYTE PTR [rax],al
    3e20:	(bad)
    3e21:	add    BYTE PTR [rax],al
    3e23:	add    BYTE PTR [rax],al
    3e25:	add    BYTE PTR [rax],al
	...

0000000000003e28 <botlish_entry_45: ht_place<mutarray, int, any, any>>:
    3e28:	push   rbp
    3e29:	mov    rbp,rsp
    3e2c:	mov    rsi,QWORD PTR [rdx]
    3e2f:	mov    r9,QWORD PTR [rdx+0x8]
    3e33:	mov    rcx,QWORD PTR [rdx+0x10]
    3e37:	mov    r8,QWORD PTR [rdx+0x18]
    3e3b:	mov    rdx,r9
    3e3e:	call   3e43 <botlish_entry_45+0x1b>
			3e3f: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    3e43:	mov    rsp,rbp
    3e46:	pop    rbp
    3e47:	ret

0000000000003e48 <botlish_fn_46: ht_set<mutarray, any, any>>:
    3e48:	push   rbp
    3e49:	mov    rbp,rsp
    3e4c:	sub    rsp,0x60
    3e50:	mov    QWORD PTR [rsp+0x30],rbx
    3e55:	mov    QWORD PTR [rsp+0x38],r12
    3e5a:	mov    QWORD PTR [rsp+0x40],r13
    3e5f:	mov    QWORD PTR [rsp+0x48],r14
    3e64:	mov    QWORD PTR [rsp+0x50],r15
    3e69:	mov    rbx,rdi
    3e6c:	mov    r13,rdx
    3e6f:	mov    QWORD PTR [rsp],rsi
    3e73:	mov    r14,rsi
    3e76:	mov    QWORD PTR [rsp+0x8],rdx
    3e7b:	mov    QWORD PTR [rsp+0x10],rcx
    3e80:	mov    r12,rcx
    3e83:	mov    rdx,r13
    3e86:	mov    rsi,r14
    3e89:	mov    rdi,rbx
    3e8c:	call   3e91 <botlish_fn_46+0x49>
			3e8d: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    3e91:	test   rax,rax
    3e94:	je     40ff <botlish_fn_46+0x2b7>
    3e9a:	mov    QWORD PTR [rsp+0x18],rax
    3e9f:	mov    rcx,rax
    3ea2:	mov    r8,0xffffffffffffffff
    3ea9:	mov    QWORD PTR [rsp+0x28],r8
    3eae:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3eb7:	mov    rdx,r13
    3eba:	mov    rsi,r14
    3ebd:	mov    rdi,rbx
    3ec0:	call   3ec5 <botlish_fn_46+0x7d>
			3ec1: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    3ec5:	mov    rcx,rax
    3ec8:	mov    r15,rax
    3ecb:	test   rax,rcx
    3ece:	je     40ff <botlish_fn_46+0x2b7>
    3ed4:	mov    rax,r15
    3ed7:	mov    QWORD PTR [rsp+0x18],rax
    3edc:	mov    rsi,r14
    3edf:	mov    rdi,rbx
    3ee2:	call   3ee7 <botlish_fn_46+0x9f>
			3ee3: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    3ee7:	test   rax,rax
    3eea:	je     40ff <botlish_fn_46+0x2b7>
    3ef0:	xor    ecx,ecx
    3ef2:	test   rax,0x7
    3ef8:	je     3f06 <botlish_fn_46+0xbe>
    3efe:	mov    r8,rax
    3f01:	jmp    3f14 <botlish_fn_46+0xcc>
    3f06:	movzx  rcx,BYTE PTR [rax]
    3f0a:	mov    r8,rax
    3f0d:	rex cmp cl,0x8
    3f11:	sete   cl
    3f14:	test   cl,cl
    3f16:	jne    3f39 <botlish_fn_46+0xf1>
    3f1c:	mov    rdi,rbx
    3f1f:	mov    rsi,QWORD PTR [rdi+0x10]
    3f23:	mov    rcx,QWORD PTR [rsi+0x20]
    3f27:	mov    edx,0x8
    3f2c:	mov    rsi,r8
    3f2f:	call   3f34 <botlish_fn_46+0xec>
			3f30: R_X86_64_PLT32	rt_type_error-0x4
    3f34:	jmp    40ff <botlish_fn_46+0x2b7>
    3f39:	mov    rsi,r8
    3f3c:	mov    rdx,r15
    3f3f:	mov    rdi,rbx
    3f42:	call   3f47 <botlish_fn_46+0xff>
			3f43: R_X86_64_PLT32	rt_mutarray_get-0x4
    3f47:	test   rax,rax
    3f4a:	je     40ff <botlish_fn_46+0x2b7>
    3f50:	test   rax,0x1
    3f56:	mov    rsi,rax
    3f59:	jne    3f7a <botlish_fn_46+0x132>
    3f5f:	mov    edx,0x3
    3f64:	mov    rdi,rbx
    3f67:	call   3f6c <botlish_fn_46+0x124>
			3f68: R_X86_64_PLT32	rt_value_eq-0x4
    3f6c:	test   rax,rax
    3f6f:	je     40ff <botlish_fn_46+0x2b7>
    3f75:	jmp    3f8b <botlish_fn_46+0x143>
    3f7a:	mov    eax,0x2
    3f7f:	cmp    rsi,0x3
    3f83:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4150 <botlish_fn_46+0x308>
    3f8b:	cmp    rax,0x6
    3f8f:	je     408e <botlish_fn_46+0x246>
    3f95:	mov    rsi,r14
    3f98:	mov    rdi,rbx
    3f9b:	call   3fa0 <botlish_fn_46+0x158>
			3f9c: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_should_grow<mutarray>
    3fa0:	test   rax,rax
    3fa3:	je     40ff <botlish_fn_46+0x2b7>
    3fa9:	cmp    rax,0x6
    3fad:	je     3ff2 <botlish_fn_46+0x1aa>
    3fb3:	mov    rcx,r13
    3fb6:	mov    rdx,r15
    3fb9:	mov    rsi,r14
    3fbc:	mov    rdi,rbx
    3fbf:	mov    r8,r12
    3fc2:	call   3fc7 <botlish_fn_46+0x17f>
			3fc3: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    3fc7:	test   rax,rax
    3fca:	je     40ff <botlish_fn_46+0x2b7>
    3fd0:	mov    rbx,QWORD PTR [rsp+0x30]
    3fd5:	mov    r12,QWORD PTR [rsp+0x38]
    3fda:	mov    r13,QWORD PTR [rsp+0x40]
    3fdf:	mov    r14,QWORD PTR [rsp+0x48]
    3fe4:	mov    r15,QWORD PTR [rsp+0x50]
    3fe9:	add    rsp,0x60
    3fed:	mov    rsp,rbp
    3ff0:	pop    rbp
    3ff1:	ret
    3ff2:	mov    rsi,r14
    3ff5:	mov    rdi,rbx
    3ff8:	call   3ffd <botlish_fn_46+0x1b5>
			3ff9: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_grow_or_clean<mutarray>
    3ffd:	test   rax,rax
    4000:	je     40ff <botlish_fn_46+0x2b7>
    4006:	mov    rdx,r13
    4009:	mov    rsi,r14
    400c:	mov    rdi,rbx
    400f:	call   4014 <botlish_fn_46+0x1cc>
			4010: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    4014:	test   rax,rax
    4017:	je     40ff <botlish_fn_46+0x2b7>
    401d:	mov    QWORD PTR [rsp+0x18],rax
    4022:	mov    rcx,rax
    4025:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    402e:	mov    r8,QWORD PTR [rsp+0x28]
    4033:	mov    rdx,r13
    4036:	mov    rsi,r14
    4039:	mov    rdi,rbx
    403c:	call   4041 <botlish_fn_46+0x1f9>
			403d: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    4041:	test   rax,rax
    4044:	je     40ff <botlish_fn_46+0x2b7>
    404a:	mov    QWORD PTR [rsp+0x18],rax
    404f:	mov    rcx,r13
    4052:	mov    rdx,rax
    4055:	mov    rsi,r14
    4058:	mov    rdi,rbx
    405b:	mov    r8,r12
    405e:	call   4063 <botlish_fn_46+0x21b>
			405f: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    4063:	test   rax,rax
    4066:	je     40ff <botlish_fn_46+0x2b7>
    406c:	mov    rbx,QWORD PTR [rsp+0x30]
    4071:	mov    r12,QWORD PTR [rsp+0x38]
    4076:	mov    r13,QWORD PTR [rsp+0x40]
    407b:	mov    r14,QWORD PTR [rsp+0x48]
    4080:	mov    r15,QWORD PTR [rsp+0x50]
    4085:	add    rsp,0x60
    4089:	mov    rsp,rbp
    408c:	pop    rbp
    408d:	ret
    408e:	mov    rsi,r14
    4091:	mov    rdi,rbx
    4094:	call   4099 <botlish_fn_46+0x251>
			4095: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    4099:	test   rax,rax
    409c:	je     40ff <botlish_fn_46+0x2b7>
    40a2:	xor    ecx,ecx
    40a4:	test   rax,0x7
    40aa:	je     40b8 <botlish_fn_46+0x270>
    40b0:	mov    rsi,rax
    40b3:	jmp    40c6 <botlish_fn_46+0x27e>
    40b8:	movzx  rcx,BYTE PTR [rax]
    40bc:	mov    rsi,rax
    40bf:	rex cmp cl,0x8
    40c3:	sete   cl
    40c6:	test   cl,cl
    40c8:	jne    40e8 <botlish_fn_46+0x2a0>
    40ce:	mov    rdi,rbx
    40d1:	mov    rax,QWORD PTR [rdi+0x10]
    40d5:	mov    rcx,QWORD PTR [rax+0x40]
    40d9:	mov    edx,0x8
    40de:	call   40e3 <botlish_fn_46+0x29b>
			40df: R_X86_64_PLT32	rt_type_error-0x4
    40e3:	jmp    40ff <botlish_fn_46+0x2b7>
    40e8:	mov    rcx,r12
    40eb:	mov    rdx,r15
    40ee:	mov    rdi,rbx
    40f1:	call   40f6 <botlish_fn_46+0x2ae>
			40f2: R_X86_64_PLT32	rt_mutarray_set-0x4
    40f6:	test   rax,rax
    40f9:	jne    4124 <botlish_fn_46+0x2dc>
    40ff:	xor    rax,rax
    4102:	mov    rbx,QWORD PTR [rsp+0x30]
    4107:	mov    r12,QWORD PTR [rsp+0x38]
    410c:	mov    r13,QWORD PTR [rsp+0x40]
    4111:	mov    r14,QWORD PTR [rsp+0x48]
    4116:	mov    r15,QWORD PTR [rsp+0x50]
    411b:	add    rsp,0x60
    411f:	mov    rsp,rbp
    4122:	pop    rbp
    4123:	ret
    4124:	mov    eax,0xa
    4129:	mov    rbx,QWORD PTR [rsp+0x30]
    412e:	mov    r12,QWORD PTR [rsp+0x38]
    4133:	mov    r13,QWORD PTR [rsp+0x40]
    4138:	mov    r14,QWORD PTR [rsp+0x48]
    413d:	mov    r15,QWORD PTR [rsp+0x50]
    4142:	add    rsp,0x60
    4146:	mov    rsp,rbp
    4149:	pop    rbp
    414a:	ret
    414b:	add    BYTE PTR [rax],al
    414d:	add    BYTE PTR [rax],al
    414f:	add    BYTE PTR [rsi],al
    4151:	add    BYTE PTR [rax],al
    4153:	add    BYTE PTR [rax],al
    4155:	add    BYTE PTR [rax],al
	...

0000000000004158 <botlish_entry_46: ht_set<mutarray, any, any>>:
    4158:	push   rbp
    4159:	mov    rbp,rsp
    415c:	mov    rsi,QWORD PTR [rdx]
    415f:	mov    r8,QWORD PTR [rdx+0x8]
    4163:	mov    rcx,QWORD PTR [rdx+0x10]
    4167:	mov    rdx,r8
    416a:	call   416f <botlish_entry_46+0x17>
			416b: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_set<mutarray, any, any>
    416f:	mov    rsp,rbp
    4172:	pop    rbp
    4173:	ret

0000000000004174 <botlish_fn_47: row_new<bool, int>>:
    4174:	push   rbp
    4175:	mov    rbp,rsp
    4178:	sub    rsp,0x10
    417c:	mov    QWORD PTR [rsp],rdx
    4180:	mov    r8,rdx
    4183:	cmp    rsi,0x6
    4187:	je     41a4 <botlish_fn_47+0x30>
    418d:	call   4192 <botlish_fn_47+0x1e>
			418e: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_new<generic>
    4192:	test   rax,rax
    4195:	je     41b5 <botlish_fn_47+0x41>
    419b:	add    rsp,0x10
    419f:	mov    rsp,rbp
    41a2:	pop    rbp
    41a3:	ret
    41a4:	mov    rsi,r8
    41a7:	call   41ac <botlish_fn_47+0x38>
			41a8: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_new_sized<int>
    41ac:	test   rax,rax
    41af:	jne    41c1 <botlish_fn_47+0x4d>
    41b5:	xor    rax,rax
    41b8:	add    rsp,0x10
    41bc:	mov    rsp,rbp
    41bf:	pop    rbp
    41c0:	ret
    41c1:	add    rsp,0x10
    41c5:	mov    rsp,rbp
    41c8:	pop    rbp
    41c9:	ret

00000000000041ca <botlish_entry_47: row_new<bool, int>>:
    41ca:	push   rbp
    41cb:	mov    rbp,rsp
    41ce:	mov    rsi,QWORD PTR [rdx]
    41d1:	mov    rdx,QWORD PTR [rdx+0x8]
    41d5:	call   41da <botlish_entry_47+0x10>
			41d6: R_X86_64_PLT32	botlish_fn_47-0x4 ; row_new<bool, int>
    41da:	mov    rsp,rbp
    41dd:	pop    rbp
    41de:	ret
	...

00000000000041e0 <botlish_fn_48: row_fill<mutarray, any, any, int, int>>:
    41e0:	push   rbp
    41e1:	mov    rbp,rsp
    41e4:	sub    rsp,0x70
    41e8:	mov    QWORD PTR [rsp+0x40],rbx
    41ed:	mov    QWORD PTR [rsp+0x48],r12
    41f2:	mov    QWORD PTR [rsp+0x50],r13
    41f7:	mov    QWORD PTR [rsp+0x58],r14
    41fc:	mov    QWORD PTR [rsp+0x60],r15
    4201:	mov    rbx,rdx
    4204:	mov    r15,rdi
    4207:	mov    QWORD PTR [rsp],rsi
    420b:	mov    r13,rsi
    420e:	mov    QWORD PTR [rsp+0x8],rdx
    4213:	mov    QWORD PTR [rsp+0x10],rcx
    4218:	mov    QWORD PTR [rsp+0x30],rcx
    421d:	mov    QWORD PTR [rsp+0x18],r8
    4222:	mov    r14,r9
    4225:	mov    rax,r14
    4228:	or     rax,0x1
    422c:	mov    r12,r8
    422f:	mov    rcx,r12
    4232:	and    rcx,rax
    4235:	test   rcx,0x1
    423c:	jne    4269 <botlish_fn_48+0x89>
    4242:	mov    rdx,r14
    4245:	or     rdx,0x1
    4249:	mov    rsi,r12
    424c:	mov    rdi,r15
    424f:	call   4254 <botlish_fn_48+0x74>
			4250: R_X86_64_PLT32	rt_int_cmp-0x4
    4254:	mov    ecx,0x2
    4259:	test   rax,rax
    425c:	cmovge rcx,QWORD PTR [rip+0x20c]        # 4470 <botlish_fn_48+0x290>
    4264:	jmp    4280 <botlish_fn_48+0xa0>
    4269:	mov    rdx,r14
    426c:	or     rdx,0x1
    4270:	mov    ecx,0x2
    4275:	cmp    r12,rdx
    4278:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 4470 <botlish_fn_48+0x290>
    4280:	cmp    rcx,0x6
    4284:	je     444a <botlish_fn_48+0x26a>
    428a:	xor    ecx,ecx
    428c:	mov    rdx,rbx
    428f:	test   rdx,0x7
    4296:	jne    42aa <botlish_fn_48+0xca>
    429c:	mov    rdx,rbx
    429f:	movzx  r9,BYTE PTR [rdx]
    42a3:	cmp    r9b,0x3
    42a7:	sete   cl
    42aa:	test   cl,cl
    42ac:	jne    42cf <botlish_fn_48+0xef>
    42b2:	mov    rdi,r15
    42b5:	mov    rax,QWORD PTR [rdi+0x10]
    42b9:	mov    rcx,QWORD PTR [rax+0x50]
    42bd:	mov    edx,0x4
    42c2:	mov    rsi,rbx
    42c5:	call   42ca <botlish_fn_48+0xea>
			42c6: R_X86_64_PLT32	rt_type_error-0x4
    42ca:	jmp    43f4 <botlish_fn_48+0x214>
    42cf:	mov    rsi,rbx
    42d2:	test   r12,0x1
    42d9:	jne    42e7 <botlish_fn_48+0x107>
    42df:	mov    rbx,rsi
    42e2:	jmp    42fd <botlish_fn_48+0x11d>
    42e7:	mov    rax,QWORD PTR [rsi+0x8]
    42eb:	mov    rbx,rsi
    42ee:	mov    rcx,r12
    42f1:	sar    rcx,1
    42f4:	cmp    rcx,rax
    42f7:	jb     431c <botlish_fn_48+0x13c>
    42fd:	mov    rdx,r12
    4300:	mov    rsi,rbx
    4303:	mov    rdi,r15
    4306:	call   430b <botlish_fn_48+0x12b>
			4307: R_X86_64_PLT32	rt_list_get-0x4
    430b:	test   rax,rax
    430e:	je     43f4 <botlish_fn_48+0x214>
    4314:	mov    rdx,rax
    4317:	jmp    4324 <botlish_fn_48+0x144>
    431c:	mov    rax,QWORD PTR [rbx+0x10]
    4320:	mov    rdx,QWORD PTR [rax+rcx*8]
    4324:	mov    QWORD PTR [rsp+0x20],rdx
    4329:	mov    QWORD PTR [rsp+0x38],rdx
    432e:	xor    esi,esi
    4330:	mov    rcx,QWORD PTR [rsp+0x30]
    4335:	test   rcx,0x7
    433c:	je     434c <botlish_fn_48+0x16c>
    4342:	mov    QWORD PTR [rsp+0x30],rcx
    4347:	jmp    435b <botlish_fn_48+0x17b>
    434c:	movzx  rax,BYTE PTR [rcx]
    4350:	mov    QWORD PTR [rsp+0x30],rcx
    4355:	cmp    al,0x3
    4357:	sete   sil
    435b:	test   sil,sil
    435e:	jne    4383 <botlish_fn_48+0x1a3>
    4364:	mov    rdi,r15
    4367:	mov    rax,QWORD PTR [rdi+0x10]
    436b:	mov    rcx,QWORD PTR [rax+0x50]
    436f:	mov    edx,0x4
    4374:	mov    rsi,QWORD PTR [rsp+0x30]
    4379:	call   437e <botlish_fn_48+0x19e>
			437a: R_X86_64_PLT32	rt_type_error-0x4
    437e:	jmp    43f4 <botlish_fn_48+0x214>
    4383:	test   r12,0x1
    438a:	je     43a8 <botlish_fn_48+0x1c8>
    4390:	mov    rsi,QWORD PTR [rsp+0x30]
    4395:	mov    rcx,QWORD PTR [rsi+0x8]
    4399:	mov    rax,r12
    439c:	sar    rax,1
    439f:	cmp    rax,rcx
    43a2:	jb     43c9 <botlish_fn_48+0x1e9>
    43a8:	mov    rdx,r12
    43ab:	mov    rsi,QWORD PTR [rsp+0x30]
    43b0:	mov    rdi,r15
    43b3:	call   43b8 <botlish_fn_48+0x1d8>
			43b4: R_X86_64_PLT32	rt_list_get-0x4
    43b8:	test   rax,rax
    43bb:	je     43f4 <botlish_fn_48+0x214>
    43c1:	mov    rcx,rax
    43c4:	jmp    43d6 <botlish_fn_48+0x1f6>
    43c9:	mov    rsi,QWORD PTR [rsp+0x30]
    43ce:	mov    rcx,QWORD PTR [rsi+0x10]
    43d2:	mov    rcx,QWORD PTR [rcx+rax*8]
    43d6:	mov    QWORD PTR [rsp+0x28],rcx
    43db:	mov    rdx,QWORD PTR [rsp+0x38]
    43e0:	mov    rsi,r13
    43e3:	mov    rdi,r15
    43e6:	call   43eb <botlish_fn_48+0x20b>
			43e7: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_set<mutarray, any, any>
    43eb:	test   rax,rax
    43ee:	jne    4419 <botlish_fn_48+0x239>
    43f4:	xor    rax,rax
    43f7:	mov    rbx,QWORD PTR [rsp+0x40]
    43fc:	mov    r12,QWORD PTR [rsp+0x48]
    4401:	mov    r13,QWORD PTR [rsp+0x50]
    4406:	mov    r14,QWORD PTR [rsp+0x58]
    440b:	mov    r15,QWORD PTR [rsp+0x60]
    4410:	add    rsp,0x70
    4414:	mov    rsp,rbp
    4417:	pop    rbp
    4418:	ret
    4419:	mov    QWORD PTR [rsp],r13
    441d:	mov    QWORD PTR [rsp+0x8],rbx
    4422:	mov    rsi,QWORD PTR [rsp+0x30]
    4427:	mov    QWORD PTR [rsp+0x10],rsi
    442c:	sar    r12,1
    442f:	add    r12,0x1
    4436:	shl    r12,1
    4439:	or     r12,0x1
    443d:	mov    QWORD PTR [rsp+0x18],r12
    4442:	mov    r8,r12
    4445:	jmp    4225 <botlish_fn_48+0x45>
    444a:	mov    rax,r13
    444d:	mov    rbx,QWORD PTR [rsp+0x40]
    4452:	mov    r12,QWORD PTR [rsp+0x48]
    4457:	mov    r13,QWORD PTR [rsp+0x50]
    445c:	mov    r14,QWORD PTR [rsp+0x58]
    4461:	mov    r15,QWORD PTR [rsp+0x60]
    4466:	add    rsp,0x70
    446a:	mov    rsp,rbp
    446d:	pop    rbp
    446e:	ret
    446f:	add    BYTE PTR [rsi],al
    4471:	add    BYTE PTR [rax],al
    4473:	add    BYTE PTR [rax],al
    4475:	add    BYTE PTR [rax],al
	...

0000000000004478 <botlish_entry_48: row_fill<mutarray, any, any, int, int>>:
    4478:	push   rbp
    4479:	mov    rbp,rsp
    447c:	mov    rsi,QWORD PTR [rdx]
    447f:	mov    r10,QWORD PTR [rdx+0x8]
    4483:	mov    rcx,QWORD PTR [rdx+0x10]
    4487:	mov    r8,QWORD PTR [rdx+0x18]
    448b:	mov    r9,QWORD PTR [rdx+0x20]
    448f:	mov    rdx,r10
    4492:	call   4497 <botlish_entry_48+0x1f>
			4493: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_fill<mutarray, any, any, int, int>
    4497:	mov    rsp,rbp
    449a:	pop    rbp
    449b:	ret

000000000000449c <botlish_fn_49: row_table<any, int, any, bool>>:
    449c:	push   rbp
    449d:	mov    rbp,rsp
    44a0:	sub    rsp,0x50
    44a4:	mov    QWORD PTR [rsp+0x30],rbx
    44a9:	mov    QWORD PTR [rsp+0x38],r12
    44ae:	mov    QWORD PTR [rsp+0x40],r13
    44b3:	mov    QWORD PTR [rsp+0x48],r14
    44b8:	mov    r12,rdi
    44bb:	mov    QWORD PTR [rsp+0x20],0x0
    44c4:	mov    QWORD PTR [rsp],rsi
    44c8:	mov    r13,rsi
    44cb:	mov    QWORD PTR [rsp+0x8],rdx
    44d0:	mov    QWORD PTR [rsp+0x10],rcx
    44d5:	mov    rbx,rcx
    44d8:	mov    QWORD PTR [rsp+0x18],r8
    44dd:	mov    rsi,r8
    44e0:	mov    rdi,r12
    44e3:	call   44e8 <botlish_fn_49+0x4c>
			44e4: R_X86_64_PLT32	botlish_fn_47-0x4 ; row_new<bool, int>
    44e8:	test   rax,rax
    44eb:	je     4580 <botlish_fn_49+0xe4>
    44f1:	mov    QWORD PTR [rsp+0x8],rax
    44f6:	mov    r14,rax
    44f9:	mov    QWORD PTR [rsp+0x18],0x1
    4502:	xor    eax,eax
    4504:	mov    rcx,rbx
    4507:	test   rcx,0x7
    450e:	je     451c <botlish_fn_49+0x80>
    4514:	mov    rbx,rcx
    4517:	jmp    4528 <botlish_fn_49+0x8c>
    451c:	movzx  rax,BYTE PTR [rcx]
    4520:	mov    rbx,rcx
    4523:	cmp    al,0x3
    4525:	sete   al
    4528:	test   al,al
    452a:	jne    454d <botlish_fn_49+0xb1>
    4530:	mov    rdi,r12
    4533:	mov    rax,QWORD PTR [rdi+0x10]
    4537:	mov    rcx,QWORD PTR [rax+0x58]
    453b:	mov    edx,0x4
    4540:	mov    rsi,rbx
    4543:	call   4548 <botlish_fn_49+0xac>
			4544: R_X86_64_PLT32	rt_type_error-0x4
    4548:	jmp    4580 <botlish_fn_49+0xe4>
    454d:	mov    rsi,rbx
    4550:	mov    rdi,r12
    4553:	call   4558 <botlish_fn_49+0xbc>
			4554: R_X86_64_PLT32	rt_list_len-0x4
    4558:	mov    QWORD PTR [rsp+0x20],rax
    455d:	mov    r8d,0x1
    4563:	mov    rcx,rbx
    4566:	mov    rdx,r13
    4569:	mov    rsi,r14
    456c:	mov    rdi,r12
    456f:	mov    r9,rax
    4572:	call   4577 <botlish_fn_49+0xdb>
			4573: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_fill<mutarray, any, any, int, int>
    4577:	test   rax,rax
    457a:	jne    45a0 <botlish_fn_49+0x104>
    4580:	xor    rax,rax
    4583:	mov    rbx,QWORD PTR [rsp+0x30]
    4588:	mov    r12,QWORD PTR [rsp+0x38]
    458d:	mov    r13,QWORD PTR [rsp+0x40]
    4592:	mov    r14,QWORD PTR [rsp+0x48]
    4597:	add    rsp,0x50
    459b:	mov    rsp,rbp
    459e:	pop    rbp
    459f:	ret
    45a0:	mov    rbx,QWORD PTR [rsp+0x30]
    45a5:	mov    r12,QWORD PTR [rsp+0x38]
    45aa:	mov    r13,QWORD PTR [rsp+0x40]
    45af:	mov    r14,QWORD PTR [rsp+0x48]
    45b4:	add    rsp,0x50
    45b8:	mov    rsp,rbp
    45bb:	pop    rbp
    45bc:	ret

00000000000045bd <botlish_entry_49: row_table<any, int, any, bool>>:
    45bd:	push   rbp
    45be:	mov    rbp,rsp
    45c1:	mov    rsi,QWORD PTR [rdx]
    45c4:	mov    r9,QWORD PTR [rdx+0x8]
    45c8:	mov    rcx,QWORD PTR [rdx+0x10]
    45cc:	mov    r8,QWORD PTR [rdx+0x18]
    45d0:	mov    rdx,r9
    45d3:	call   45d8 <botlish_entry_49+0x1b>
			45d4: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_table<any, int, any, bool>
    45d8:	mov    rsp,rbp
    45db:	pop    rbp
    45dc:	ret
    45dd:	add    BYTE PTR [rax],al
	...

00000000000045e0 <botlish_fn_50: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    45e0:	push   rbp
    45e1:	mov    rbp,rsp
    45e4:	sub    rsp,0x90
    45eb:	mov    QWORD PTR [rsp+0x60],rbx
    45f0:	mov    QWORD PTR [rsp+0x68],r12
    45f5:	mov    QWORD PTR [rsp+0x70],r13
    45fa:	mov    QWORD PTR [rsp+0x78],r14
    45ff:	mov    QWORD PTR [rsp+0x80],r15
    4607:	mov    r13,r8
    460a:	mov    QWORD PTR [rsp+0x40],rdi
    460f:	mov    r11,QWORD PTR [rbp+0x10]
    4613:	mov    r15,QWORD PTR [rbp+0x18]
    4617:	mov    QWORD PTR [rsp+0x30],0x0
    4620:	mov    QWORD PTR [rsp+0x38],0x0
    4629:	mov    QWORD PTR [rsp],rsi
    462d:	mov    QWORD PTR [rsp+0x8],rdx
    4632:	mov    r12,rdx
    4635:	mov    QWORD PTR [rsp+0x10],rcx
    463a:	mov    r14,rcx
    463d:	mov    QWORD PTR [rsp+0x18],r9
    4642:	mov    QWORD PTR [rsp+0x20],r11
    4647:	mov    QWORD PTR [rsp+0x50],r11
    464c:	mov    QWORD PTR [rsp+0x28],r15
    4651:	mov    rbx,rsi
    4654:	mov    QWORD PTR [rsp+0x48],r9
    4659:	mov    rsi,rbx
    465c:	mov    rdi,QWORD PTR [rsp+0x40]
    4661:	call   4666 <botlish_fn_50+0x86>
			4662: R_X86_64_PLT32	rt_list_len-0x4
    4666:	mov    rcx,r12
    4669:	and    rcx,rax
    466c:	mov    rdx,rax
    466f:	test   rcx,0x1
    4676:	jne    469e <botlish_fn_50+0xbe>
    467c:	mov    rsi,r12
    467f:	mov    rdi,QWORD PTR [rsp+0x40]
    4684:	call   4689 <botlish_fn_50+0xa9>
			4685: R_X86_64_PLT32	rt_int_cmp-0x4
    4689:	mov    ecx,0x2
    468e:	test   rax,rax
    4691:	cmovge rcx,QWORD PTR [rip+0x177]        # 4810 <botlish_fn_50+0x230>
    4699:	jmp    46ae <botlish_fn_50+0xce>
    469e:	mov    ecx,0x2
    46a3:	cmp    r12,rdx
    46a6:	cmovge rcx,QWORD PTR [rip+0x162]        # 4810 <botlish_fn_50+0x230>
    46ae:	cmp    rcx,0x6
    46b2:	je     4799 <botlish_fn_50+0x1b9>
    46b8:	mov    rax,r13
    46bb:	or     rax,0x1
    46bf:	mov    QWORD PTR [rsp+0x30],rax
    46c4:	test   r12,0x1
    46cb:	je     46e4 <botlish_fn_50+0x104>
    46d1:	mov    rcx,QWORD PTR [rbx+0x8]
    46d5:	mov    rax,r12
    46d8:	sar    rax,1
    46db:	cmp    rax,rcx
    46de:	jb     4705 <botlish_fn_50+0x125>
    46e4:	mov    rdx,r12
    46e7:	mov    rsi,rbx
    46ea:	mov    rdi,QWORD PTR [rsp+0x40]
    46ef:	call   46f4 <botlish_fn_50+0x114>
			46f0: R_X86_64_PLT32	rt_list_get-0x4
    46f4:	test   rax,rax
    46f7:	je     47b6 <botlish_fn_50+0x1d6>
    46fd:	mov    rcx,rax
    4700:	jmp    470d <botlish_fn_50+0x12d>
    4705:	mov    rsi,QWORD PTR [rbx+0x10]
    4709:	mov    rcx,QWORD PTR [rsi+rax*8]
    470d:	mov    QWORD PTR [rsp+0x38],rcx
    4712:	mov    rdx,r13
    4715:	or     rdx,0x1
    4719:	mov    rsi,r14
    471c:	mov    rdi,QWORD PTR [rsp+0x40]
    4721:	mov    r8,r15
    4724:	call   4729 <botlish_fn_50+0x149>
			4725: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_table<any, int, any, bool>
    4729:	test   rax,rax
    472c:	je     47b6 <botlish_fn_50+0x1d6>
    4732:	mov    QWORD PTR [rsp+0x8],rax
    4737:	mov    rcx,rax
    473a:	sar    r12,1
    473d:	add    r12,0x1
    4744:	shl    r12,1
    4747:	or     r12,0x1
    474b:	mov    QWORD PTR [rsp+0x30],r12
    4750:	mov    rdx,QWORD PTR [rsp+0x50]
    4755:	mov    rsi,QWORD PTR [rsp+0x48]
    475a:	mov    rdi,QWORD PTR [rsp+0x40]
    475f:	call   4764 <botlish_fn_50+0x184>
			4760: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    4764:	test   rax,rax
    4767:	je     47b6 <botlish_fn_50+0x1d6>
    476d:	mov    QWORD PTR [rsp],rbx
    4771:	mov    QWORD PTR [rsp+0x8],r12
    4776:	mov    QWORD PTR [rsp+0x10],r14
    477b:	mov    QWORD PTR [rsp+0x18],rax
    4780:	mov    QWORD PTR [rsp+0x20],rdx
    4785:	mov    QWORD PTR [rsp+0x28],r15
    478a:	mov    QWORD PTR [rsp+0x48],rax
    478f:	mov    QWORD PTR [rsp+0x50],rdx
    4794:	jmp    4659 <botlish_fn_50+0x79>
    4799:	mov    rdx,QWORD PTR [rsp+0x50]
    479e:	mov    rsi,QWORD PTR [rsp+0x48]
    47a3:	mov    rdi,QWORD PTR [rsp+0x40]
    47a8:	call   47ad <botlish_fn_50+0x1cd>
			47a9: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    47ad:	test   rax,rax
    47b0:	jne    47e1 <botlish_fn_50+0x201>
    47b6:	xor    rax,rax
    47b9:	mov    rbx,QWORD PTR [rsp+0x60]
    47be:	mov    r12,QWORD PTR [rsp+0x68]
    47c3:	mov    r13,QWORD PTR [rsp+0x70]
    47c8:	mov    r14,QWORD PTR [rsp+0x78]
    47cd:	mov    r15,QWORD PTR [rsp+0x80]
    47d5:	add    rsp,0x90
    47dc:	mov    rsp,rbp
    47df:	pop    rbp
    47e0:	ret
    47e1:	mov    rbx,QWORD PTR [rsp+0x60]
    47e6:	mov    r12,QWORD PTR [rsp+0x68]
    47eb:	mov    r13,QWORD PTR [rsp+0x70]
    47f0:	mov    r14,QWORD PTR [rsp+0x78]
    47f5:	mov    r15,QWORD PTR [rsp+0x80]
    47fd:	add    rsp,0x90
    4804:	mov    rsp,rbp
    4807:	pop    rbp
    4808:	ret
    4809:	add    BYTE PTR [rax],al
    480b:	add    BYTE PTR [rax],al
    480d:	add    BYTE PTR [rax],al
    480f:	add    BYTE PTR [rsi],al
    4811:	add    BYTE PTR [rax],al
    4813:	add    BYTE PTR [rax],al
    4815:	add    BYTE PTR [rax],al
	...

0000000000004818 <botlish_entry_50: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4818:	push   rbp
    4819:	mov    rbp,rsp
    481c:	sub    rsp,0x10
    4820:	mov    rsi,QWORD PTR [rdx]
    4823:	mov    r10,QWORD PTR [rdx+0x8]
    4827:	mov    rcx,QWORD PTR [rdx+0x10]
    482b:	mov    r8,QWORD PTR [rdx+0x18]
    482f:	mov    r9,QWORD PTR [rdx+0x20]
    4833:	mov    r11,QWORD PTR [rdx+0x28]
    4837:	mov    rax,QWORD PTR [rdx+0x30]
    483b:	mov    QWORD PTR [rsp],r11
    483f:	mov    QWORD PTR [rsp+0x8],rax
    4844:	mov    rdx,r10
    4847:	call   484c <botlish_entry_50+0x34>
			4848: R_X86_64_PLT32	botlish_fn_50-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    484c:	add    rsp,0x10
    4850:	mov    rsp,rbp
    4853:	pop    rbp
    4854:	ret

0000000000004855 <botlish_fn_51: csv_records_generic<str, bool>>:
    4855:	push   rbp
    4856:	mov    rbp,rsp
    4859:	sub    rsp,0x80
    4860:	mov    QWORD PTR [rsp+0x50],rbx
    4865:	mov    QWORD PTR [rsp+0x58],r12
    486a:	mov    QWORD PTR [rsp+0x60],r13
    486f:	mov    QWORD PTR [rsp+0x68],r14
    4874:	mov    QWORD PTR [rsp+0x70],r15
    4879:	mov    rbx,rdi
    487c:	mov    QWORD PTR [rsp+0x20],0x0
    4885:	mov    QWORD PTR [rsp+0x28],0x0
    488e:	mov    QWORD PTR [rsp+0x30],0x0
    4897:	mov    QWORD PTR [rsp+0x38],0x0
    48a0:	mov    QWORD PTR [rsp+0x40],0x0
    48a9:	mov    QWORD PTR [rsp+0x10],rsi
    48ae:	mov    QWORD PTR [rsp+0x18],rdx
    48b3:	mov    r12,rdx
    48b6:	mov    rdi,rbx
    48b9:	call   48be <botlish_fn_51+0x69>
			48ba: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    48be:	mov    rcx,rax
    48c1:	mov    r13,rax
    48c4:	test   rax,rcx
    48c7:	je     4a0d <botlish_fn_51+0x1b8>
    48cd:	mov    rax,r13
    48d0:	mov    QWORD PTR [rsp+0x10],rax
    48d5:	mov    rsi,r13
    48d8:	mov    rdi,rbx
    48db:	call   48e0 <botlish_fn_51+0x8b>
			48dc: R_X86_64_PLT32	rt_list_len-0x4
    48e0:	sar    rax,1
    48e3:	test   rax,rax
    48e6:	je     49f6 <botlish_fn_51+0x1a1>
    48ec:	mov    rax,r13
    48ef:	mov    rax,QWORD PTR [rax+0x8]
    48f3:	test   rax,rax
    48f6:	jne    491d <botlish_fn_51+0xc8>
    48fc:	mov    edx,0x1
    4901:	mov    rsi,r13
    4904:	mov    rdi,rbx
    4907:	call   490c <botlish_fn_51+0xb7>
			4908: R_X86_64_PLT32	rt_list_get-0x4
    490c:	test   rax,rax
    490f:	je     4a0d <botlish_fn_51+0x1b8>
    4915:	mov    rsi,rax
    4918:	jmp    492a <botlish_fn_51+0xd5>
    491d:	mov    rax,r13
    4920:	mov    rcx,QWORD PTR [rax+0x10]
    4924:	mov    rax,QWORD PTR [rcx]
    4927:	mov    rsi,rax
    492a:	mov    QWORD PTR [rsp+0x20],rsi
    492f:	mov    QWORD PTR [rsp+0x28],0x3
    4938:	xor    eax,eax
    493a:	test   rsi,0x7
    4941:	jne    4950 <botlish_fn_51+0xfb>
    4947:	movzx  rax,BYTE PTR [rsi]
    494b:	cmp    al,0x3
    494d:	sete   al
    4950:	test   al,al
    4952:	jne    4972 <botlish_fn_51+0x11d>
    4958:	mov    rdi,rbx
    495b:	mov    rax,QWORD PTR [rdi+0x10]
    495f:	mov    rcx,QWORD PTR [rax+0x58]
    4963:	mov    edx,0x4
    4968:	call   496d <botlish_fn_51+0x118>
			4969: R_X86_64_PLT32	rt_type_error-0x4
    496d:	jmp    4a0d <botlish_fn_51+0x1b8>
    4972:	mov    r14,rsi
    4975:	mov    rdi,rbx
    4978:	call   497d <botlish_fn_51+0x128>
			4979: R_X86_64_PLT32	rt_list_len-0x4
    497d:	mov    QWORD PTR [rsp+0x30],rax
    4982:	mov    r15,rax
    4985:	mov    rdi,rbx
    4988:	call   498d <botlish_fn_51+0x138>
			4989: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    498d:	test   rax,rax
    4990:	je     4a0d <botlish_fn_51+0x1b8>
    4996:	mov    QWORD PTR [rsp+0x38],rax
    499b:	mov    r9,rax
    499e:	mov    QWORD PTR [rsp+0x40],rdx
    49a3:	mov    rax,rdx
    49a6:	mov    edx,0x3
    49ab:	mov    QWORD PTR [rsp],rax
    49af:	mov    rax,r12
    49b2:	mov    QWORD PTR [rsp+0x8],rax
    49b7:	mov    rcx,r14
    49ba:	mov    rsi,r13
    49bd:	mov    rdi,rbx
    49c0:	mov    r8,r15
    49c3:	call   49c8 <botlish_fn_51+0x173>
			49c4: R_X86_64_PLT32	botlish_fn_50-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    49c8:	test   rax,rax
    49cb:	je     4a0d <botlish_fn_51+0x1b8>
    49d1:	mov    rbx,QWORD PTR [rsp+0x50]
    49d6:	mov    r12,QWORD PTR [rsp+0x58]
    49db:	mov    r13,QWORD PTR [rsp+0x60]
    49e0:	mov    r14,QWORD PTR [rsp+0x68]
    49e5:	mov    r15,QWORD PTR [rsp+0x70]
    49ea:	add    rsp,0x80
    49f1:	mov    rsp,rbp
    49f4:	pop    rbp
    49f5:	ret
    49f6:	xor    rdx,rdx
    49f9:	mov    rdi,rbx
    49fc:	mov    rsi,rdx
    49ff:	call   4a04 <botlish_fn_51+0x1af>
			4a00: R_X86_64_PLT32	rt_list_new-0x4
    4a04:	test   rax,rax
    4a07:	jne    4a35 <botlish_fn_51+0x1e0>
    4a0d:	xor    rax,rax
    4a10:	mov    rbx,QWORD PTR [rsp+0x50]
    4a15:	mov    r12,QWORD PTR [rsp+0x58]
    4a1a:	mov    r13,QWORD PTR [rsp+0x60]
    4a1f:	mov    r14,QWORD PTR [rsp+0x68]
    4a24:	mov    r15,QWORD PTR [rsp+0x70]
    4a29:	add    rsp,0x80
    4a30:	mov    rsp,rbp
    4a33:	pop    rbp
    4a34:	ret
    4a35:	mov    rbx,QWORD PTR [rsp+0x50]
    4a3a:	mov    r12,QWORD PTR [rsp+0x58]
    4a3f:	mov    r13,QWORD PTR [rsp+0x60]
    4a44:	mov    r14,QWORD PTR [rsp+0x68]
    4a49:	mov    r15,QWORD PTR [rsp+0x70]
    4a4e:	add    rsp,0x80
    4a55:	mov    rsp,rbp
    4a58:	pop    rbp
    4a59:	ret

0000000000004a5a <botlish_entry_51: csv_records_generic<str, bool>>:
    4a5a:	push   rbp
    4a5b:	mov    rbp,rsp
    4a5e:	mov    rsi,QWORD PTR [rdx]
    4a61:	mov    rdx,QWORD PTR [rdx+0x8]
    4a65:	call   4a6a <botlish_entry_51+0x10>
			4a66: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4a6a:	mov    rsp,rbp
    4a6d:	pop    rbp
    4a6e:	ret

0000000000004a6f <botlish_fn_52: csv_records<str>>:
    4a6f:	push   rbp
    4a70:	mov    rbp,rsp
    4a73:	sub    rsp,0x10
    4a77:	mov    QWORD PTR [rsp],rsi
    4a7b:	mov    edx,0x2
    4a80:	mov    QWORD PTR [rsp+0x8],0x2
    4a89:	call   4a8e <botlish_fn_52+0x1f>
			4a8a: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4a8e:	test   rax,rax
    4a91:	jne    4aa3 <botlish_fn_52+0x34>
    4a97:	xor    rax,rax
    4a9a:	add    rsp,0x10
    4a9e:	mov    rsp,rbp
    4aa1:	pop    rbp
    4aa2:	ret
    4aa3:	add    rsp,0x10
    4aa7:	mov    rsp,rbp
    4aaa:	pop    rbp
    4aab:	ret

0000000000004aac <botlish_entry_52: csv_records<str>>:
    4aac:	push   rbp
    4aad:	mov    rbp,rsp
    4ab0:	mov    rsi,QWORD PTR [rdx]
    4ab3:	call   4ab8 <botlish_entry_52+0xc>
			4ab4: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records<str>
    4ab8:	mov    rsp,rbp
    4abb:	pop    rbp
    4abc:	ret

0000000000004abd <botlish_fn_53: csv_records_presized<str>>:
    4abd:	push   rbp
    4abe:	mov    rbp,rsp
    4ac1:	sub    rsp,0x10
    4ac5:	mov    QWORD PTR [rsp],rsi
    4ac9:	mov    edx,0x6
    4ace:	mov    QWORD PTR [rsp+0x8],0x6
    4ad7:	call   4adc <botlish_fn_53+0x1f>
			4ad8: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4adc:	test   rax,rax
    4adf:	jne    4af1 <botlish_fn_53+0x34>
    4ae5:	xor    rax,rax
    4ae8:	add    rsp,0x10
    4aec:	mov    rsp,rbp
    4aef:	pop    rbp
    4af0:	ret
    4af1:	add    rsp,0x10
    4af5:	mov    rsp,rbp
    4af8:	pop    rbp
    4af9:	ret

0000000000004afa <botlish_entry_53: csv_records_presized<str>>:
    4afa:	push   rbp
    4afb:	mov    rbp,rsp
    4afe:	mov    rsi,QWORD PTR [rdx]
    4b01:	call   4b06 <botlish_entry_53+0xc>
			4b02: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_presized<str>
    4b06:	mov    rsp,rbp
    4b09:	pop    rbp
    4b0a:	ret
    4b0b:	add    BYTE PTR [rax],al
    4b0d:	add    BYTE PTR [rax],al
	...

0000000000004b10 <botlish_fn_54: sample<generic>>:
    4b10:	push   rbp
    4b11:	mov    rbp,rsp
    4b14:	sub    rsp,0xc0
    4b1b:	mov    QWORD PTR [rsp+0x90],rbx
    4b23:	mov    QWORD PTR [rsp+0x98],r12
    4b2b:	mov    QWORD PTR [rsp+0xa0],r13
    4b33:	mov    QWORD PTR [rsp+0xa8],r14
    4b3b:	mov    QWORD PTR [rsp+0xb0],r15
    4b43:	mov    QWORD PTR [rsp+0x8],0x0
    4b4c:	mov    QWORD PTR [rsp+0x10],0x0
    4b55:	mov    QWORD PTR [rsp+0x18],0x0
    4b5e:	mov    QWORD PTR [rsp+0x20],0x0
    4b67:	mov    QWORD PTR [rsp+0x28],0x0
    4b70:	mov    QWORD PTR [rsp+0x30],0x0
    4b79:	mov    QWORD PTR [rsp+0x38],0x0
    4b82:	mov    rax,QWORD PTR [rdi+0x10]
    4b86:	mov    r13,rdi
    4b89:	mov    rsi,QWORD PTR [rax+0x60]
    4b8d:	mov    QWORD PTR [rsp],rsi
    4b91:	call   4b96 <botlish_fn_54+0x86>
			4b92: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records<str>
    4b96:	mov    rsi,rax
    4b99:	mov    r12,rax
    4b9c:	test   rax,rsi
    4b9f:	je     4f24 <botlish_fn_54+0x414>
    4ba5:	mov    rax,r12
    4ba8:	mov    QWORD PTR [rsp],rax
    4bac:	mov    rdi,r13
    4baf:	mov    rax,QWORD PTR [rdi+0x10]
    4bb3:	mov    rsi,QWORD PTR [rax+0x60]
    4bb7:	mov    QWORD PTR [rsp+0x8],rsi
    4bbc:	call   4bc1 <botlish_fn_54+0xb1>
			4bbd: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_presized<str>
    4bc1:	mov    rbx,rax
    4bc4:	test   rbx,rbx
    4bc7:	je     4f24 <botlish_fn_54+0x414>
    4bcd:	mov    rax,r12
    4bd0:	mov    rax,QWORD PTR [rax+0x8]
    4bd4:	test   rax,rax
    4bd7:	jne    4bfe <botlish_fn_54+0xee>
    4bdd:	mov    edx,0x1
    4be2:	mov    rsi,r12
    4be5:	mov    rdi,r13
    4be8:	call   4bed <botlish_fn_54+0xdd>
			4be9: R_X86_64_PLT32	rt_list_get-0x4
    4bed:	test   rax,rax
    4bf0:	je     4f24 <botlish_fn_54+0x414>
    4bf6:	mov    rsi,rax
    4bf9:	jmp    4c06 <botlish_fn_54+0xf6>
    4bfe:	mov    rax,QWORD PTR [r12+0x10]
    4c03:	mov    rsi,QWORD PTR [rax]
    4c06:	mov    QWORD PTR [rsp+0x8],rsi
    4c0b:	mov    r15,rsi
    4c0e:	mov    rax,QWORD PTR [r12+0x8]
    4c13:	cmp    rax,0x1
    4c17:	ja     4c3e <botlish_fn_54+0x12e>
    4c1d:	mov    edx,0x3
    4c22:	mov    rsi,r12
    4c25:	mov    rdi,r13
    4c28:	call   4c2d <botlish_fn_54+0x11d>
			4c29: R_X86_64_PLT32	rt_list_get-0x4
    4c2d:	test   rax,rax
    4c30:	je     4f24 <botlish_fn_54+0x414>
    4c36:	mov    rsi,rax
    4c39:	jmp    4c47 <botlish_fn_54+0x137>
    4c3e:	mov    rax,QWORD PTR [r12+0x10]
    4c43:	mov    rsi,QWORD PTR [rax+0x8]
    4c47:	mov    QWORD PTR [rsp+0x10],rsi
    4c4c:	mov    r14,rsi
    4c4f:	mov    rax,QWORD PTR [rbx+0x8]
    4c53:	mov    rsi,rbx
    4c56:	test   rax,rax
    4c59:	jne    4c7d <botlish_fn_54+0x16d>
    4c5f:	mov    edx,0x1
    4c64:	mov    rdi,r13
    4c67:	call   4c6c <botlish_fn_54+0x15c>
			4c68: R_X86_64_PLT32	rt_list_get-0x4
    4c6c:	test   rax,rax
    4c6f:	je     4f24 <botlish_fn_54+0x414>
    4c75:	mov    rsi,rax
    4c78:	jmp    4c84 <botlish_fn_54+0x174>
    4c7d:	mov    rax,QWORD PTR [rsi+0x10]
    4c81:	mov    rsi,QWORD PTR [rax]
    4c84:	mov    QWORD PTR [rsp+0x18],rsi
    4c89:	mov    rdi,r13
    4c8c:	mov    QWORD PTR [rsp+0x78],rsi
    4c91:	mov    rax,QWORD PTR [rdi+0x10]
    4c95:	mov    rdx,QWORD PTR [rax+0x68]
    4c99:	mov    QWORD PTR [rsp+0x20],rdx
    4c9e:	mov    rsi,r15
    4ca1:	call   4ca6 <botlish_fn_54+0x196>
			4ca2: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4ca6:	test   rax,rax
    4ca9:	je     4f24 <botlish_fn_54+0x414>
    4caf:	mov    QWORD PTR [rsp+0x20],rax
    4cb4:	mov    rbx,rax
    4cb7:	mov    rdi,r13
    4cba:	mov    rax,QWORD PTR [rdi+0x10]
    4cbe:	mov    rdx,QWORD PTR [rax+0x68]
    4cc2:	mov    QWORD PTR [rsp+0x28],rdx
    4cc7:	mov    rsi,QWORD PTR [rsp+0x78]
    4ccc:	call   4cd1 <botlish_fn_54+0x1c1>
			4ccd: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4cd1:	test   rax,rax
    4cd4:	je     4f24 <botlish_fn_54+0x414>
    4cda:	mov    rcx,rbx
    4cdd:	mov    rdx,rcx
    4ce0:	and    rdx,rax
    4ce3:	test   rdx,0x1
    4cea:	jne    4d0c <botlish_fn_54+0x1fc>
    4cf0:	mov    rdx,rax
    4cf3:	mov    rsi,rbx
    4cf6:	mov    rdi,r13
    4cf9:	call   4cfe <botlish_fn_54+0x1ee>
			4cfa: R_X86_64_PLT32	rt_value_eq-0x4
    4cfe:	test   rax,rax
    4d01:	je     4f24 <botlish_fn_54+0x414>
    4d07:	jmp    4d22 <botlish_fn_54+0x212>
    4d0c:	mov    rdx,rax
    4d0f:	mov    rsi,rbx
    4d12:	mov    eax,0x2
    4d17:	cmp    rsi,rdx
    4d1a:	cmove  rax,QWORD PTR [rip+0x26e]        # 4f90 <botlish_fn_54+0x480>
    4d22:	mov    ebx,0x6
    4d27:	cmp    rax,0x6
    4d2b:	je     4d46 <botlish_fn_54+0x236>
    4d31:	mov    ebx,0x2
    4d36:	mov    QWORD PTR [rsp],0x2
    4d3e:	mov    rsi,r12
    4d41:	jmp    4de5 <botlish_fn_54+0x2d5>
    4d46:	mov    rsi,r15
    4d49:	mov    rdi,r13
    4d4c:	call   4d51 <botlish_fn_54+0x241>
			4d4d: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    4d51:	test   rax,rax
    4d54:	mov    QWORD PTR [rsp+0x88],rax
    4d5c:	je     4f24 <botlish_fn_54+0x414>
    4d62:	mov    rsi,QWORD PTR [rsp+0x78]
    4d67:	mov    rdi,r13
    4d6a:	call   4d6f <botlish_fn_54+0x25f>
			4d6b: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    4d6f:	test   rax,rax
    4d72:	je     4f24 <botlish_fn_54+0x414>
    4d78:	mov    rcx,QWORD PTR [rsp+0x88]
    4d80:	mov    rdx,rcx
    4d83:	and    rdx,rax
    4d86:	test   rdx,0x1
    4d8d:	jne    4db4 <botlish_fn_54+0x2a4>
    4d93:	mov    rdx,rax
    4d96:	mov    rsi,QWORD PTR [rsp+0x88]
    4d9e:	mov    rdi,r13
    4da1:	call   4da6 <botlish_fn_54+0x296>
			4da2: R_X86_64_PLT32	rt_value_eq-0x4
    4da6:	test   rax,rax
    4da9:	je     4f24 <botlish_fn_54+0x414>
    4daf:	jmp    4dcf <botlish_fn_54+0x2bf>
    4db4:	mov    rdx,rax
    4db7:	mov    rsi,QWORD PTR [rsp+0x88]
    4dbf:	mov    eax,0x2
    4dc4:	cmp    rsi,rdx
    4dc7:	cmove  rax,QWORD PTR [rip+0x1c1]        # 4f90 <botlish_fn_54+0x480>
    4dcf:	cmp    rax,0x6
    4dd3:	je     4dde <botlish_fn_54+0x2ce>
    4dd9:	mov    ebx,0x2
    4dde:	mov    QWORD PTR [rsp],rbx
    4de2:	mov    rsi,r12
    4de5:	mov    rdi,r13
    4de8:	call   4ded <botlish_fn_54+0x2dd>
			4de9: R_X86_64_PLT32	rt_list_len-0x4
    4ded:	mov    QWORD PTR [rsp+0x18],rax
    4df2:	mov    rdi,r13
    4df5:	mov    r12,rax
    4df8:	mov    rax,QWORD PTR [rdi+0x10]
    4dfc:	mov    rdx,QWORD PTR [rax+0x68]
    4e00:	mov    QWORD PTR [rsp+0x20],rdx
    4e05:	mov    rsi,r15
    4e08:	call   4e0d <botlish_fn_54+0x2fd>
			4e09: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4e0d:	test   rax,rax
    4e10:	je     4f24 <botlish_fn_54+0x414>
    4e16:	mov    QWORD PTR [rsp+0x20],rax
    4e1b:	mov    rdi,r13
    4e1e:	mov    QWORD PTR [rsp+0x88],rax
    4e26:	mov    rax,QWORD PTR [rdi+0x10]
    4e2a:	mov    rdx,QWORD PTR [rax+0x70]
    4e2e:	mov    QWORD PTR [rsp+0x28],rdx
    4e33:	mov    rsi,r15
    4e36:	call   4e3b <botlish_fn_54+0x32b>
			4e37: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4e3b:	test   rax,rax
    4e3e:	je     4f24 <botlish_fn_54+0x414>
    4e44:	mov    QWORD PTR [rsp+0x28],rax
    4e49:	mov    rdi,r13
    4e4c:	mov    QWORD PTR [rsp+0x80],rax
    4e54:	mov    rax,QWORD PTR [rdi+0x10]
    4e58:	mov    rdx,QWORD PTR [rax+0x78]
    4e5c:	mov    QWORD PTR [rsp+0x30],rdx
    4e61:	mov    rsi,r15
    4e64:	call   4e69 <botlish_fn_54+0x359>
			4e65: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4e69:	test   rax,rax
    4e6c:	je     4f24 <botlish_fn_54+0x414>
    4e72:	mov    QWORD PTR [rsp+0x8],rax
    4e77:	mov    rdi,r13
    4e7a:	mov    r15,rax
    4e7d:	mov    rax,QWORD PTR [rdi+0x10]
    4e81:	mov    rdx,QWORD PTR [rax+0x68]
    4e85:	mov    QWORD PTR [rsp+0x30],rdx
    4e8a:	mov    rsi,r14
    4e8d:	call   4e92 <botlish_fn_54+0x382>
			4e8e: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4e92:	test   rax,rax
    4e95:	je     4f24 <botlish_fn_54+0x414>
    4e9b:	mov    QWORD PTR [rsp+0x30],rax
    4ea0:	mov    rdi,r13
    4ea3:	mov    QWORD PTR [rsp+0x78],rax
    4ea8:	mov    rax,QWORD PTR [rdi+0x10]
    4eac:	mov    rdx,QWORD PTR [rax+0x78]
    4eb0:	mov    QWORD PTR [rsp+0x38],rdx
    4eb5:	mov    rsi,r14
    4eb8:	call   4ebd <botlish_fn_54+0x3ad>
			4eb9: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4ebd:	test   rax,rax
    4ec0:	je     4f24 <botlish_fn_54+0x414>
    4ec6:	mov    QWORD PTR [rsp+0x10],rax
    4ecb:	lea    rdx,[rsp+0x40]
    4ed0:	mov    r9,r12
    4ed3:	mov    QWORD PTR [rsp+0x40],r9
    4ed8:	mov    rcx,QWORD PTR [rsp+0x88]
    4ee0:	mov    QWORD PTR [rsp+0x48],rcx
    4ee5:	mov    rcx,QWORD PTR [rsp+0x80]
    4eed:	mov    QWORD PTR [rsp+0x50],rcx
    4ef2:	mov    rcx,r15
    4ef5:	mov    QWORD PTR [rsp+0x58],rcx
    4efa:	mov    rcx,QWORD PTR [rsp+0x78]
    4eff:	mov    QWORD PTR [rsp+0x60],rcx
    4f04:	mov    QWORD PTR [rsp+0x68],rax
    4f09:	mov    QWORD PTR [rsp+0x70],rbx
    4f0e:	mov    esi,0x7
    4f13:	mov    rdi,r13
    4f16:	call   4f1b <botlish_fn_54+0x40b>
			4f17: R_X86_64_PLT32	rt_list_new-0x4
    4f1b:	test   rax,rax
    4f1e:	jne    4f5b <botlish_fn_54+0x44b>
    4f24:	xor    rax,rax
    4f27:	mov    rbx,QWORD PTR [rsp+0x90]
    4f2f:	mov    r12,QWORD PTR [rsp+0x98]
    4f37:	mov    r13,QWORD PTR [rsp+0xa0]
    4f3f:	mov    r14,QWORD PTR [rsp+0xa8]
    4f47:	mov    r15,QWORD PTR [rsp+0xb0]
    4f4f:	add    rsp,0xc0
    4f56:	mov    rsp,rbp
    4f59:	pop    rbp
    4f5a:	ret
    4f5b:	mov    rbx,QWORD PTR [rsp+0x90]
    4f63:	mov    r12,QWORD PTR [rsp+0x98]
    4f6b:	mov    r13,QWORD PTR [rsp+0xa0]
    4f73:	mov    r14,QWORD PTR [rsp+0xa8]
    4f7b:	mov    r15,QWORD PTR [rsp+0xb0]
    4f83:	add    rsp,0xc0
    4f8a:	mov    rsp,rbp
    4f8d:	pop    rbp
    4f8e:	ret
    4f8f:	add    BYTE PTR [rsi],al
    4f91:	add    BYTE PTR [rax],al
    4f93:	add    BYTE PTR [rax],al
    4f95:	add    BYTE PTR [rax],al
	...

0000000000004f98 <botlish_entry_54: sample<generic>>:
    4f98:	push   rbp
    4f99:	mov    rbp,rsp
    4f9c:	call   4fa1 <botlish_entry_54+0x9>
			4f9d: R_X86_64_PLT32	botlish_fn_54-0x4 ; sample<generic>
    4fa1:	mov    rsp,rbp
    4fa4:	pop    rbp
    4fa5:	ret

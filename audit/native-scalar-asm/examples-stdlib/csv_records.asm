; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 21917  (per function: 45 78 357 381 272 272 272 81 365 430 584 1063 351 695 456 171 388 524 70 493 114 61 125 61 125 61 125 61 125 61 168 168 179 179 245 245 804 1248 429 380 439 1113 766 817 665 1168 836 107 756 335 645 580 78 78 1222)
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
;   botlish_fn_40 / botlish_entry_40 -> ht_rehash_insert<List[mutarray], int, any, any>
;   botlish_fn_41 / botlish_entry_41 -> ht_rehash_scan<list, int, int, List[mutarray], int>
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
     b66:	sub    rsp,0xd0
     b6d:	mov    QWORD PTR [rsp+0xa0],rbx
     b75:	mov    QWORD PTR [rsp+0xa8],r12
     b7d:	mov    QWORD PTR [rsp+0xb0],r13
     b85:	mov    QWORD PTR [rsp+0xb8],r14
     b8d:	mov    QWORD PTR [rsp+0xc0],r15
     b95:	mov    r15,rdi
     b98:	mov    QWORD PTR [rsp+0x18],0x0
     ba1:	mov    QWORD PTR [rsp+0x20],0x0
     baa:	mov    QWORD PTR [rsp],rsi
     bae:	mov    QWORD PTR [rsp+0x8],rdx
     bb3:	mov    QWORD PTR [rsp+0x10],rcx
     bb8:	mov    r13,rcx
     bbb:	lea    r14,[rsp+0x68]
     bc0:	lea    rbx,[rsp+0x28]
     bc5:	mov    r12,rsi
     bc8:	mov    QWORD PTR [rsp+0x88],rdx
     bd0:	mov    rdx,QWORD PTR [rsp+0x88]
     bd8:	mov    rsi,r12
     bdb:	mov    rdi,r15
     bde:	call   be3 <botlish_fn_11+0x81>
			bdf: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     be3:	test   rax,rax
     be6:	je     eea <botlish_fn_11+0x388>
     bec:	mov    QWORD PTR [rsp+0x18],rax
     bf1:	mov    rdi,r15
     bf4:	mov    QWORD PTR [rsp+0x90],rax
     bfc:	mov    rsi,QWORD PTR [rdi+0x10]
     c00:	mov    rsi,QWORD PTR [rsi+0x18]
     c04:	mov    edx,0x1
     c09:	mov    ecx,0x3
     c0e:	mov    r8,QWORD PTR [rsp+0x90]
     c16:	call   c1b <botlish_fn_11+0xb9>
			c17: R_X86_64_PLT32	rt_str_region_eq-0x4
     c1b:	cmp    rax,0x6
     c1f:	je     cdf <botlish_fn_11+0x17d>
     c25:	mov    QWORD PTR [rsp+0x20],0x3
     c2e:	mov    rsi,QWORD PTR [rsp+0x88]
     c36:	test   rsi,0x1
     c3d:	je     c5f <botlish_fn_11+0xfd>
     c43:	mov    r9,rsi
     c46:	add    r9,0x2
     c4a:	seto   r11b
     c4e:	test   r11b,r11b
     c51:	jne    c5f <botlish_fn_11+0xfd>
     c57:	mov    rsi,r9
     c5a:	jmp    c6f <botlish_fn_11+0x10d>
     c5f:	mov    edx,0x3
     c64:	mov    rdi,r15
     c67:	call   c6c <botlish_fn_11+0x10a>
			c68: R_X86_64_PLT32	rt_int_add-0x4
     c6c:	mov    rsi,rax
     c6f:	mov    QWORD PTR [rsp+0x8],rsi
     c74:	mov    QWORD PTR [rsp+0x88],rsi
     c7c:	mov    QWORD PTR [rsp+0x68],0x0
     c85:	mov    QWORD PTR [rsp+0x70],r13
     c8a:	mov    QWORD PTR [rsp+0x78],0x0
     c93:	mov    rax,QWORD PTR [rsp+0x90]
     c9b:	mov    QWORD PTR [rsp+0x80],rax
     ca3:	mov    esi,0x2
     ca8:	mov    edx,0x4
     cad:	mov    rcx,r14
     cb0:	mov    rdi,r15
     cb3:	call   cb8 <botlish_fn_11+0x156>
			cb4: R_X86_64_PLT32	rt_construct-0x4
     cb8:	test   rax,rax
     cbb:	je     eea <botlish_fn_11+0x388>
     cc1:	mov    QWORD PTR [rsp],r12
     cc5:	mov    rsi,QWORD PTR [rsp+0x88]
     ccd:	mov    QWORD PTR [rsp+0x8],rsi
     cd2:	mov    QWORD PTR [rsp+0x10],rax
     cd7:	mov    r13,rax
     cda:	jmp    bd0 <botlish_fn_11+0x6e>
     cdf:	mov    QWORD PTR [rsp+0x18],0x3
     ce8:	mov    rsi,QWORD PTR [rsp+0x88]
     cf0:	test   rsi,0x1
     cf7:	je     d17 <botlish_fn_11+0x1b5>
     cfd:	mov    rsi,QWORD PTR [rsp+0x88]
     d05:	mov    rdx,rsi
     d08:	add    rdx,0x2
     d0c:	seto   al
     d0f:	test   al,al
     d11:	je     d2f <botlish_fn_11+0x1cd>
     d17:	mov    edx,0x3
     d1c:	mov    rsi,QWORD PTR [rsp+0x88]
     d24:	mov    rdi,r15
     d27:	call   d2c <botlish_fn_11+0x1ca>
			d28: R_X86_64_PLT32	rt_int_add-0x4
     d2c:	mov    rdx,rax
     d2f:	mov    QWORD PTR [rsp+0x18],rdx
     d34:	mov    rcx,rbx
     d37:	mov    rsi,r12
     d3a:	mov    rdi,r15
     d3d:	call   d42 <botlish_fn_11+0x1e0>
			d3e: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     d42:	test   rax,rax
     d45:	mov    rsi,rax
     d48:	je     eea <botlish_fn_11+0x388>
     d4e:	mov    rdx,QWORD PTR [rsp+0x28]
     d53:	mov    rcx,QWORD PTR [rsp+0x30]
     d58:	mov    rdi,r15
     d5b:	mov    rax,QWORD PTR [rdi+0x10]
     d5f:	mov    r8,QWORD PTR [rax+0x18]
     d63:	call   d68 <botlish_fn_11+0x206>
			d64: R_X86_64_PLT32	rt_str_region_eq-0x4
     d68:	cmp    rax,0x6
     d6c:	je     e34 <botlish_fn_11+0x2d2>
     d72:	xor    rsi,rsi
     d75:	lea    rcx,[rsp+0x58]
     d7a:	mov    QWORD PTR [rsp+0x58],0x0
     d83:	mov    QWORD PTR [rsp+0x60],r13
     d88:	mov    edx,0x2
     d8d:	mov    rdi,r15
     d90:	call   d95 <botlish_fn_11+0x233>
			d91: R_X86_64_PLT32	rt_construct-0x4
     d95:	test   rax,rax
     d98:	je     eea <botlish_fn_11+0x388>
     d9e:	mov    QWORD PTR [rsp],rax
     da2:	mov    rbx,rax
     da5:	mov    QWORD PTR [rsp+0x10],0x3
     dae:	mov    rsi,QWORD PTR [rsp+0x88]
     db6:	test   rsi,0x1
     dbd:	je     de5 <botlish_fn_11+0x283>
     dc3:	mov    rsi,QWORD PTR [rsp+0x88]
     dcb:	mov    rdx,rsi
     dce:	add    rdx,0x2
     dd2:	seto   al
     dd5:	test   al,al
     dd7:	jne    de5 <botlish_fn_11+0x283>
     ddd:	mov    rax,rbx
     de0:	jmp    e00 <botlish_fn_11+0x29e>
     de5:	mov    edx,0x3
     dea:	mov    rsi,QWORD PTR [rsp+0x88]
     df2:	mov    rdi,r15
     df5:	call   dfa <botlish_fn_11+0x298>
			df6: R_X86_64_PLT32	rt_int_add-0x4
     dfa:	mov    rdx,rax
     dfd:	mov    rax,rbx
     e00:	mov    rbx,QWORD PTR [rsp+0xa0]
     e08:	mov    r12,QWORD PTR [rsp+0xa8]
     e10:	mov    r13,QWORD PTR [rsp+0xb0]
     e18:	mov    r14,QWORD PTR [rsp+0xb8]
     e20:	mov    r15,QWORD PTR [rsp+0xc0]
     e28:	add    rsp,0xd0
     e2f:	mov    rsp,rbp
     e32:	pop    rbp
     e33:	ret
     e34:	mov    QWORD PTR [rsp+0x18],0x5
     e3d:	mov    rsi,QWORD PTR [rsp+0x88]
     e45:	test   rsi,0x1
     e4c:	je     e7c <botlish_fn_11+0x31a>
     e52:	mov    rsi,QWORD PTR [rsp+0x88]
     e5a:	mov    rax,rsi
     e5d:	add    rax,0x4
     e61:	seto   cl
     e64:	test   cl,cl
     e66:	jne    e7c <botlish_fn_11+0x31a>
     e6c:	mov    rsi,rax
     e6f:	mov    QWORD PTR [rsp+0x88],rax
     e77:	jmp    e9c <botlish_fn_11+0x33a>
     e7c:	mov    edx,0x5
     e81:	mov    rsi,QWORD PTR [rsp+0x88]
     e89:	mov    rdi,r15
     e8c:	call   e91 <botlish_fn_11+0x32f>
			e8d: R_X86_64_PLT32	rt_int_add-0x4
     e91:	mov    rsi,rax
     e94:	mov    QWORD PTR [rsp+0x88],rax
     e9c:	mov    QWORD PTR [rsp+0x8],rsi
     ea1:	mov    rdi,r15
     ea4:	mov    rsi,QWORD PTR [rdi+0x10]
     ea8:	mov    rsi,QWORD PTR [rsi+0x18]
     eac:	mov    QWORD PTR [rsp+0x18],rsi
     eb1:	lea    rcx,[rsp+0x38]
     eb6:	mov    QWORD PTR [rsp+0x38],0x0
     ebf:	mov    QWORD PTR [rsp+0x40],r13
     ec4:	mov    QWORD PTR [rsp+0x48],0x0
     ecd:	mov    QWORD PTR [rsp+0x50],rsi
     ed2:	mov    esi,0x2
     ed7:	mov    edx,0x4
     edc:	call   ee1 <botlish_fn_11+0x37f>
			edd: R_X86_64_PLT32	rt_construct-0x4
     ee1:	test   rax,rax
     ee4:	jne    f24 <botlish_fn_11+0x3c2>
     eea:	xor    rdx,rdx
     eed:	mov    rax,rdx
     ef0:	mov    rbx,QWORD PTR [rsp+0xa0]
     ef8:	mov    r12,QWORD PTR [rsp+0xa8]
     f00:	mov    r13,QWORD PTR [rsp+0xb0]
     f08:	mov    r14,QWORD PTR [rsp+0xb8]
     f10:	mov    r15,QWORD PTR [rsp+0xc0]
     f18:	add    rsp,0xd0
     f1f:	mov    rsp,rbp
     f22:	pop    rbp
     f23:	ret
     f24:	mov    QWORD PTR [rsp],r12
     f28:	mov    rsi,QWORD PTR [rsp+0x88]
     f30:	mov    QWORD PTR [rsp+0x8],rsi
     f35:	mov    QWORD PTR [rsp+0x10],rax
     f3a:	mov    r13,rax
     f3d:	jmp    bd0 <botlish_fn_11+0x6e>

0000000000000f42 <botlish_entry_11: scan_quoted<str, int, str>>:
     f42:	push   rbp
     f43:	mov    rbp,rsp
     f46:	ud2

0000000000000f48 <botlish_fn_12: scan_field<str, int>>:
     f48:	push   rbp
     f49:	mov    rbp,rsp
     f4c:	sub    rsp,0x50
     f50:	mov    QWORD PTR [rsp+0x30],rbx
     f55:	mov    QWORD PTR [rsp+0x38],r12
     f5a:	mov    QWORD PTR [rsp+0x40],r13
     f5f:	mov    r12,rdi
     f62:	mov    r13,rdx
     f65:	mov    QWORD PTR [rsp+0x10],0x0
     f6e:	mov    QWORD PTR [rsp],rsi
     f72:	mov    rbx,rsi
     f75:	mov    QWORD PTR [rsp+0x8],rdx
     f7a:	lea    rcx,[rsp+0x18]
     f7f:	mov    rdx,r13
     f82:	mov    rsi,rbx
     f85:	mov    rdi,r12
     f88:	call   f8d <botlish_fn_12+0x45>
			f89: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     f8d:	test   rax,rax
     f90:	mov    rsi,rax
     f93:	je     105d <botlish_fn_12+0x115>
     f99:	mov    rdx,QWORD PTR [rsp+0x18]
     f9e:	mov    rcx,QWORD PTR [rsp+0x20]
     fa3:	mov    rdi,r12
     fa6:	mov    rax,QWORD PTR [rdi+0x10]
     faa:	mov    r8,QWORD PTR [rax+0x18]
     fae:	call   fb3 <botlish_fn_12+0x6b>
			faf: R_X86_64_PLT32	rt_str_region_eq-0x4
     fb3:	cmp    rax,0x6
     fb7:	je     fef <botlish_fn_12+0xa7>
     fbd:	mov    rcx,r13
     fc0:	mov    rsi,rbx
     fc3:	mov    rdi,r12
     fc6:	mov    rdx,rcx
     fc9:	call   fce <botlish_fn_12+0x86>
			fca: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
     fce:	test   rax,rax
     fd1:	je     105d <botlish_fn_12+0x115>
     fd7:	mov    rbx,QWORD PTR [rsp+0x30]
     fdc:	mov    r12,QWORD PTR [rsp+0x38]
     fe1:	mov    r13,QWORD PTR [rsp+0x40]
     fe6:	add    rsp,0x50
     fea:	mov    rsp,rbp
     fed:	pop    rbp
     fee:	ret
     fef:	mov    rcx,r13
     ff2:	mov    QWORD PTR [rsp+0x10],0x3
     ffb:	test   rcx,0x1
    1002:	jne    1010 <botlish_fn_12+0xc8>
    1008:	mov    r13,rcx
    100b:	jmp    1025 <botlish_fn_12+0xdd>
    1010:	mov    rdx,rcx
    1013:	add    rdx,0x2
    1017:	mov    r13,rcx
    101a:	seto   al
    101d:	test   al,al
    101f:	je     1038 <botlish_fn_12+0xf0>
    1025:	mov    edx,0x3
    102a:	mov    rsi,r13
    102d:	mov    rdi,r12
    1030:	call   1035 <botlish_fn_12+0xed>
			1031: R_X86_64_PLT32	rt_int_add-0x4
    1035:	mov    rdx,rax
    1038:	mov    QWORD PTR [rsp+0x8],rdx
    103d:	mov    rdi,r12
    1040:	mov    rax,QWORD PTR [rdi+0x10]
    1044:	mov    rcx,QWORD PTR [rax]
    1047:	mov    QWORD PTR [rsp+0x10],rcx
    104c:	mov    rsi,rbx
    104f:	call   1054 <botlish_fn_12+0x10c>
			1050: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
    1054:	test   rax,rax
    1057:	jne    107b <botlish_fn_12+0x133>
    105d:	xor    rdx,rdx
    1060:	mov    rax,rdx
    1063:	mov    rbx,QWORD PTR [rsp+0x30]
    1068:	mov    r12,QWORD PTR [rsp+0x38]
    106d:	mov    r13,QWORD PTR [rsp+0x40]
    1072:	add    rsp,0x50
    1076:	mov    rsp,rbp
    1079:	pop    rbp
    107a:	ret
    107b:	mov    rbx,QWORD PTR [rsp+0x30]
    1080:	mov    r12,QWORD PTR [rsp+0x38]
    1085:	mov    r13,QWORD PTR [rsp+0x40]
    108a:	add    rsp,0x50
    108e:	mov    rsp,rbp
    1091:	pop    rbp
    1092:	ret

0000000000001093 <botlish_entry_12: scan_field<str, int>>:
    1093:	push   rbp
    1094:	mov    rbp,rsp
    1097:	ud2

0000000000001099 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
    1099:	push   rbp
    109a:	mov    rbp,rsp
    109d:	sub    rsp,0x90
    10a4:	mov    QWORD PTR [rsp+0x60],rbx
    10a9:	mov    QWORD PTR [rsp+0x68],r12
    10ae:	mov    QWORD PTR [rsp+0x70],r13
    10b3:	mov    QWORD PTR [rsp+0x78],r14
    10b8:	mov    QWORD PTR [rsp+0x80],r15
    10c0:	mov    r15,rdi
    10c3:	mov    QWORD PTR [rsp+0x20],0x0
    10cc:	mov    QWORD PTR [rsp],rsi
    10d0:	mov    QWORD PTR [rsp+0x8],rdx
    10d5:	mov    QWORD PTR [rsp+0x10],rcx
    10da:	mov    QWORD PTR [rsp+0x18],r8
    10df:	lea    r14,[rsp+0x28]
    10e4:	mov    rbx,rsi
    10e7:	mov    r12,r8
    10ea:	mov    r13,rcx
    10ed:	mov    rsi,rbx
    10f0:	mov    rdi,r15
    10f3:	call   10f8 <botlish_fn_13+0x5f>
			10f4: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
    10f8:	test   rax,rax
    10fb:	je     1216 <botlish_fn_13+0x17d>
    1101:	mov    QWORD PTR [rsp+0x8],rax
    1106:	mov    rcx,rax
    1109:	mov    QWORD PTR [rsp+0x20],rdx
    110e:	mov    QWORD PTR [rsp+0x50],rdx
    1113:	mov    rsi,r13
    1116:	mov    rdx,r12
    1119:	mov    rdi,r15
    111c:	call   1121 <botlish_fn_13+0x88>
			111d: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    1121:	test   rax,rax
    1124:	je     1216 <botlish_fn_13+0x17d>
    112a:	mov    QWORD PTR [rsp+0x8],rax
    112f:	mov    QWORD PTR [rsp+0x40],rax
    1134:	mov    QWORD PTR [rsp+0x10],rdx
    1139:	mov    QWORD PTR [rsp+0x48],rdx
    113e:	mov    rcx,r14
    1141:	mov    rdx,QWORD PTR [rsp+0x50]
    1146:	mov    rsi,rbx
    1149:	mov    rdi,r15
    114c:	call   1151 <botlish_fn_13+0xb8>
			114d: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1151:	test   rax,rax
    1154:	mov    QWORD PTR [rsp+0x38],rax
    1159:	je     1216 <botlish_fn_13+0x17d>
    115f:	mov    r12,QWORD PTR [rsp+0x28]
    1164:	mov    r13,QWORD PTR [rsp+0x30]
    1169:	mov    rdi,r15
    116c:	mov    rcx,QWORD PTR [rdi+0x10]
    1170:	mov    r8,QWORD PTR [rcx+0x8]
    1174:	mov    rcx,r13
    1177:	mov    rdx,r12
    117a:	mov    rsi,QWORD PTR [rsp+0x38]
    117f:	call   1184 <botlish_fn_13+0xeb>
			1180: R_X86_64_PLT32	rt_str_region_eq-0x4
    1184:	cmp    rax,0x6
    1188:	je     12c4 <botlish_fn_13+0x22b>
    118e:	mov    rdi,r15
    1191:	mov    rax,QWORD PTR [rdi+0x10]
    1195:	mov    r8,QWORD PTR [rax+0x10]
    1199:	mov    rcx,r13
    119c:	mov    rdx,r12
    119f:	mov    rsi,QWORD PTR [rsp+0x38]
    11a4:	call   11a9 <botlish_fn_13+0x110>
			11a5: R_X86_64_PLT32	rt_str_region_eq-0x4
    11a9:	cmp    rax,0x6
    11ad:	je     11fb <botlish_fn_13+0x162>
    11b3:	mov    rdx,QWORD PTR [rsp+0x48]
    11b8:	mov    rsi,QWORD PTR [rsp+0x40]
    11bd:	mov    rdi,r15
    11c0:	call   11c5 <botlish_fn_13+0x12c>
			11c1: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    11c5:	test   rax,rax
    11c8:	je     1216 <botlish_fn_13+0x17d>
    11ce:	mov    rdx,QWORD PTR [rsp+0x50]
    11d3:	mov    rbx,QWORD PTR [rsp+0x60]
    11d8:	mov    r12,QWORD PTR [rsp+0x68]
    11dd:	mov    r13,QWORD PTR [rsp+0x70]
    11e2:	mov    r14,QWORD PTR [rsp+0x78]
    11e7:	mov    r15,QWORD PTR [rsp+0x80]
    11ef:	add    rsp,0x90
    11f6:	mov    rsp,rbp
    11f9:	pop    rbp
    11fa:	ret
    11fb:	mov    rdx,QWORD PTR [rsp+0x48]
    1200:	mov    rsi,QWORD PTR [rsp+0x40]
    1205:	mov    rdi,r15
    1208:	call   120d <botlish_fn_13+0x174>
			1209: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    120d:	test   rax,rax
    1210:	jne    1244 <botlish_fn_13+0x1ab>
    1216:	xor    rdx,rdx
    1219:	mov    rax,rdx
    121c:	mov    rbx,QWORD PTR [rsp+0x60]
    1221:	mov    r12,QWORD PTR [rsp+0x68]
    1226:	mov    r13,QWORD PTR [rsp+0x70]
    122b:	mov    r14,QWORD PTR [rsp+0x78]
    1230:	mov    r15,QWORD PTR [rsp+0x80]
    1238:	add    rsp,0x90
    123f:	mov    rsp,rbp
    1242:	pop    rbp
    1243:	ret
    1244:	mov    QWORD PTR [rsp],rax
    1248:	mov    r12,rax
    124b:	mov    QWORD PTR [rsp+0x8],0x3
    1254:	mov    rdx,QWORD PTR [rsp+0x50]
    1259:	test   rdx,0x1
    1260:	je     1284 <botlish_fn_13+0x1eb>
    1266:	mov    rdx,QWORD PTR [rsp+0x50]
    126b:	add    rdx,0x2
    126f:	seto   r10b
    1273:	test   r10b,r10b
    1276:	jne    1284 <botlish_fn_13+0x1eb>
    127c:	mov    rax,r12
    127f:	jmp    129c <botlish_fn_13+0x203>
    1284:	mov    edx,0x3
    1289:	mov    rsi,QWORD PTR [rsp+0x50]
    128e:	mov    rdi,r15
    1291:	call   1296 <botlish_fn_13+0x1fd>
			1292: R_X86_64_PLT32	rt_int_add-0x4
    1296:	mov    rdx,rax
    1299:	mov    rax,r12
    129c:	mov    rbx,QWORD PTR [rsp+0x60]
    12a1:	mov    r12,QWORD PTR [rsp+0x68]
    12a6:	mov    r13,QWORD PTR [rsp+0x70]
    12ab:	mov    r14,QWORD PTR [rsp+0x78]
    12b0:	mov    r15,QWORD PTR [rsp+0x80]
    12b8:	add    rsp,0x90
    12bf:	mov    rsp,rbp
    12c2:	pop    rbp
    12c3:	ret
    12c4:	mov    rsi,QWORD PTR [rsp+0x50]
    12c9:	mov    edx,0x3
    12ce:	mov    rcx,rdx
    12d1:	mov    QWORD PTR [rsp+0x18],0x3
    12da:	test   rsi,0x1
    12e1:	jne    12ef <botlish_fn_13+0x256>
    12e7:	mov    rdx,rcx
    12ea:	jmp    1304 <botlish_fn_13+0x26b>
    12ef:	mov    rdx,rsi
    12f2:	add    rdx,0x2
    12f6:	seto   al
    12f9:	test   al,al
    12fb:	je     130f <botlish_fn_13+0x276>
    1301:	mov    rdx,rcx
    1304:	mov    rdi,r15
    1307:	call   130c <botlish_fn_13+0x273>
			1308: R_X86_64_PLT32	rt_int_add-0x4
    130c:	mov    rdx,rax
    130f:	mov    QWORD PTR [rsp],rbx
    1313:	mov    QWORD PTR [rsp+0x8],rdx
    1318:	mov    rsi,QWORD PTR [rsp+0x40]
    131d:	mov    QWORD PTR [rsp+0x10],rsi
    1322:	mov    r11,QWORD PTR [rsp+0x48]
    1327:	mov    QWORD PTR [rsp+0x18],r11
    132c:	mov    r12,r11
    132f:	mov    r13,rsi
    1332:	jmp    10ed <botlish_fn_13+0x54>

0000000000001337 <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    1337:	push   rbp
    1338:	mov    rbp,rsp
    133b:	ud2
    133d:	add    BYTE PTR [rax],al
	...

0000000000001340 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    1340:	push   rbp
    1341:	mov    rbp,rsp
    1344:	sub    rsp,0x60
    1348:	mov    QWORD PTR [rsp+0x30],rbx
    134d:	mov    QWORD PTR [rsp+0x38],r12
    1352:	mov    QWORD PTR [rsp+0x40],r13
    1357:	mov    QWORD PTR [rsp+0x48],r14
    135c:	mov    QWORD PTR [rsp+0x50],r15
    1361:	mov    r13,rdi
    1364:	mov    QWORD PTR [rsp+0x20],0x0
    136d:	mov    QWORD PTR [rsp+0x28],0x0
    1376:	mov    QWORD PTR [rsp],rsi
    137a:	mov    QWORD PTR [rsp+0x8],rdx
    137f:	mov    r12,rdx
    1382:	mov    QWORD PTR [rsp+0x10],rcx
    1387:	mov    QWORD PTR [rsp+0x18],r8
    138c:	mov    rbx,rsi
    138f:	mov    r14,r8
    1392:	mov    r15,rcx
    1395:	mov    rsi,rbx
    1398:	mov    rdi,r13
    139b:	call   13a0 <botlish_fn_14+0x60>
			139c: R_X86_64_PLT32	rt_str_len-0x4
    13a0:	mov    rcx,r12
    13a3:	and    rcx,rax
    13a6:	mov    rdx,rax
    13a9:	test   rcx,0x1
    13b0:	jne    13d6 <botlish_fn_14+0x96>
    13b6:	mov    rsi,r12
    13b9:	mov    rdi,r13
    13bc:	call   13c1 <botlish_fn_14+0x81>
			13bd: R_X86_64_PLT32	rt_int_cmp-0x4
    13c1:	mov    ecx,0x2
    13c6:	test   rax,rax
    13c9:	cmovge rcx,QWORD PTR [rip+0x107]        # 14d8 <botlish_fn_14+0x198>
    13d1:	jmp    13e9 <botlish_fn_14+0xa9>
    13d6:	mov    ecx,0x2
    13db:	mov    rax,r12
    13de:	cmp    rax,rdx
    13e1:	cmovge rcx,QWORD PTR [rip+0xef]        # 14d8 <botlish_fn_14+0x198>
    13e9:	cmp    rcx,0x6
    13ed:	je     1473 <botlish_fn_14+0x133>
    13f3:	mov    rdi,r13
    13f6:	call   13fb <botlish_fn_14+0xbb>
			13f7: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    13fb:	test   rax,rax
    13fe:	je     148a <botlish_fn_14+0x14a>
    1404:	mov    QWORD PTR [rsp+0x20],rax
    1409:	mov    rcx,rax
    140c:	mov    QWORD PTR [rsp+0x28],rdx
    1411:	mov    r8,rdx
    1414:	mov    rdx,r12
    1417:	mov    rsi,rbx
    141a:	mov    rdi,r13
    141d:	call   1422 <botlish_fn_14+0xe2>
			141e: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    1422:	test   rax,rax
    1425:	je     148a <botlish_fn_14+0x14a>
    142b:	mov    QWORD PTR [rsp+0x8],rax
    1430:	mov    rcx,rax
    1433:	mov    QWORD PTR [rsp+0x20],rdx
    1438:	mov    r12,rdx
    143b:	mov    rsi,r15
    143e:	mov    rdx,r14
    1441:	mov    rdi,r13
    1444:	call   1449 <botlish_fn_14+0x109>
			1445: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1449:	test   rax,rax
    144c:	je     148a <botlish_fn_14+0x14a>
    1452:	mov    QWORD PTR [rsp],rbx
    1456:	mov    rcx,r12
    1459:	mov    QWORD PTR [rsp+0x8],rcx
    145e:	mov    QWORD PTR [rsp+0x10],rax
    1463:	mov    QWORD PTR [rsp+0x18],rdx
    1468:	mov    r14,rdx
    146b:	mov    r15,rax
    146e:	jmp    1395 <botlish_fn_14+0x55>
    1473:	mov    rdx,r14
    1476:	mov    rsi,r15
    1479:	mov    rdi,r13
    147c:	call   1481 <botlish_fn_14+0x141>
			147d: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1481:	test   rax,rax
    1484:	jne    14af <botlish_fn_14+0x16f>
    148a:	xor    rax,rax
    148d:	mov    rbx,QWORD PTR [rsp+0x30]
    1492:	mov    r12,QWORD PTR [rsp+0x38]
    1497:	mov    r13,QWORD PTR [rsp+0x40]
    149c:	mov    r14,QWORD PTR [rsp+0x48]
    14a1:	mov    r15,QWORD PTR [rsp+0x50]
    14a6:	add    rsp,0x60
    14aa:	mov    rsp,rbp
    14ad:	pop    rbp
    14ae:	ret
    14af:	mov    rbx,QWORD PTR [rsp+0x30]
    14b4:	mov    r12,QWORD PTR [rsp+0x38]
    14b9:	mov    r13,QWORD PTR [rsp+0x40]
    14be:	mov    r14,QWORD PTR [rsp+0x48]
    14c3:	mov    r15,QWORD PTR [rsp+0x50]
    14c8:	add    rsp,0x60
    14cc:	mov    rsp,rbp
    14cf:	pop    rbp
    14d0:	ret
    14d1:	add    BYTE PTR [rax],al
    14d3:	add    BYTE PTR [rax],al
    14d5:	add    BYTE PTR [rax],al
    14d7:	add    BYTE PTR [rsi],al
    14d9:	add    BYTE PTR [rax],al
    14db:	add    BYTE PTR [rax],al
    14dd:	add    BYTE PTR [rax],al
	...

00000000000014e0 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    14e0:	push   rbp
    14e1:	mov    rbp,rsp
    14e4:	mov    rsi,QWORD PTR [rdx]
    14e7:	mov    r9,QWORD PTR [rdx+0x8]
    14eb:	mov    rcx,QWORD PTR [rdx+0x10]
    14ef:	mov    r8,QWORD PTR [rdx+0x18]
    14f3:	mov    rdx,r9
    14f6:	call   14fb <botlish_entry_14+0x1b>
			14f7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    14fb:	mov    rsp,rbp
    14fe:	pop    rbp
    14ff:	ret

0000000000001500 <botlish_fn_15: csv_parse<str>>:
    1500:	push   rbp
    1501:	mov    rbp,rsp
    1504:	sub    rsp,0x30
    1508:	mov    QWORD PTR [rsp+0x20],r12
    150d:	mov    QWORD PTR [rsp+0x28],r13
    1512:	mov    r13,rdi
    1515:	mov    QWORD PTR [rsp+0x10],0x0
    151e:	mov    QWORD PTR [rsp+0x18],0x0
    1527:	mov    QWORD PTR [rsp],rsi
    152b:	mov    r12,rsi
    152e:	mov    QWORD PTR [rsp+0x8],0x1
    1537:	mov    rdi,r13
    153a:	call   153f <botlish_fn_15+0x3f>
			153b: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    153f:	test   rax,rax
    1542:	je     1571 <botlish_fn_15+0x71>
    1548:	mov    QWORD PTR [rsp+0x10],rax
    154d:	mov    rcx,rax
    1550:	mov    QWORD PTR [rsp+0x18],rdx
    1555:	mov    r8,rdx
    1558:	mov    edx,0x1
    155d:	mov    rsi,r12
    1560:	mov    rdi,r13
    1563:	call   1568 <botlish_fn_15+0x68>
			1564: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1568:	test   rax,rax
    156b:	jne    1587 <botlish_fn_15+0x87>
    1571:	xor    rax,rax
    1574:	mov    r12,QWORD PTR [rsp+0x20]
    1579:	mov    r13,QWORD PTR [rsp+0x28]
    157e:	add    rsp,0x30
    1582:	mov    rsp,rbp
    1585:	pop    rbp
    1586:	ret
    1587:	mov    r12,QWORD PTR [rsp+0x20]
    158c:	mov    r13,QWORD PTR [rsp+0x28]
    1591:	add    rsp,0x30
    1595:	mov    rsp,rbp
    1598:	pop    rbp
    1599:	ret

000000000000159a <botlish_entry_15: csv_parse<str>>:
    159a:	push   rbp
    159b:	mov    rbp,rsp
    159e:	mov    rsi,QWORD PTR [rdx]
    15a1:	call   15a6 <botlish_entry_15+0xc>
			15a2: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    15a6:	mov    rsp,rbp
    15a9:	pop    rbp
    15aa:	ret
    15ab:	add    BYTE PTR [rax],al
    15ad:	add    BYTE PTR [rax],al
	...

00000000000015b0 <botlish_fn_16: ht_fill_empty<mutarray, int, int>>:
    15b0:	push   rbp
    15b1:	mov    rbp,rsp
    15b4:	sub    rsp,0x40
    15b8:	mov    QWORD PTR [rsp+0x20],rbx
    15bd:	mov    QWORD PTR [rsp+0x28],r12
    15c2:	mov    QWORD PTR [rsp+0x30],r13
    15c7:	mov    QWORD PTR [rsp+0x38],r14
    15cc:	mov    r13,rdi
    15cf:	mov    QWORD PTR [rsp],rsi
    15d3:	mov    rbx,rsi
    15d6:	mov    QWORD PTR [rsp+0x8],rdx
    15db:	mov    QWORD PTR [rsp+0x10],rcx
    15e0:	mov    r12,rcx
    15e3:	mov    rsi,rdx
    15e6:	mov    rax,rsi
    15e9:	and    rax,r12
    15ec:	mov    r14,rsi
    15ef:	test   rax,0x1
    15f5:	jne    161e <botlish_fn_16+0x6e>
    15fb:	mov    rdx,r12
    15fe:	mov    rsi,r14
    1601:	mov    rdi,r13
    1604:	call   1609 <botlish_fn_16+0x59>
			1605: R_X86_64_PLT32	rt_int_cmp-0x4
    1609:	mov    ecx,0x2
    160e:	test   rax,rax
    1611:	cmovge rcx,QWORD PTR [rip+0xdf]        # 16f8 <botlish_fn_16+0x148>
    1619:	jmp    1631 <botlish_fn_16+0x81>
    161e:	mov    ecx,0x2
    1623:	mov    rsi,r14
    1626:	cmp    rsi,r12
    1629:	cmovge rcx,QWORD PTR [rip+0xc7]        # 16f8 <botlish_fn_16+0x148>
    1631:	cmp    rcx,0x6
    1635:	je     16d6 <botlish_fn_16+0x126>
    163b:	mov    ecx,0x1
    1640:	mov    rdx,r14
    1643:	mov    rsi,rbx
    1646:	mov    rdi,r13
    1649:	call   164e <botlish_fn_16+0x9e>
			164a: R_X86_64_PLT32	rt_mutarray_set-0x4
    164e:	test   rax,rax
    1651:	jne    1677 <botlish_fn_16+0xc7>
    1657:	xor    rax,rax
    165a:	mov    rbx,QWORD PTR [rsp+0x20]
    165f:	mov    r12,QWORD PTR [rsp+0x28]
    1664:	mov    r13,QWORD PTR [rsp+0x30]
    1669:	mov    r14,QWORD PTR [rsp+0x38]
    166e:	add    rsp,0x40
    1672:	mov    rsp,rbp
    1675:	pop    rbp
    1676:	ret
    1677:	mov    QWORD PTR [rsp+0x18],0x3
    1680:	mov    rsi,r14
    1683:	test   rsi,0x1
    168a:	je     16ad <botlish_fn_16+0xfd>
    1690:	mov    rsi,r14
    1693:	mov    rcx,rsi
    1696:	add    rcx,0x2
    169a:	seto   al
    169d:	test   al,al
    169f:	jne    16ad <botlish_fn_16+0xfd>
    16a5:	mov    r14,rcx
    16a8:	jmp    16c0 <botlish_fn_16+0x110>
    16ad:	mov    edx,0x3
    16b2:	mov    rsi,r14
    16b5:	mov    rdi,r13
    16b8:	call   16bd <botlish_fn_16+0x10d>
			16b9: R_X86_64_PLT32	rt_int_add-0x4
    16bd:	mov    r14,rax
    16c0:	mov    QWORD PTR [rsp],rbx
    16c4:	mov    rsi,r14
    16c7:	mov    QWORD PTR [rsp+0x8],rsi
    16cc:	mov    QWORD PTR [rsp+0x10],r12
    16d1:	jmp    15e6 <botlish_fn_16+0x36>
    16d6:	mov    eax,0xa
    16db:	mov    rbx,QWORD PTR [rsp+0x20]
    16e0:	mov    r12,QWORD PTR [rsp+0x28]
    16e5:	mov    r13,QWORD PTR [rsp+0x30]
    16ea:	mov    r14,QWORD PTR [rsp+0x38]
    16ef:	add    rsp,0x40
    16f3:	mov    rsp,rbp
    16f6:	pop    rbp
    16f7:	ret
    16f8:	(bad)
    16f9:	add    BYTE PTR [rax],al
    16fb:	add    BYTE PTR [rax],al
    16fd:	add    BYTE PTR [rax],al
	...

0000000000001700 <botlish_entry_16: ht_fill_empty<mutarray, int, int>>:
    1700:	push   rbp
    1701:	mov    rbp,rsp
    1704:	mov    rsi,QWORD PTR [rdx]
    1707:	mov    r8,QWORD PTR [rdx+0x8]
    170b:	mov    rcx,QWORD PTR [rdx+0x10]
    170f:	mov    rdx,r8
    1712:	call   1717 <botlish_entry_16+0x17>
			1713: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_fill_empty<mutarray, int, int>
    1717:	mov    rsp,rbp
    171a:	pop    rbp
    171b:	ret

000000000000171c <botlish_fn_17: ht_alloc<int>>:
    171c:	push   rbp
    171d:	mov    rbp,rsp
    1720:	sub    rsp,0x50
    1724:	mov    QWORD PTR [rsp+0x20],rbx
    1729:	mov    QWORD PTR [rsp+0x28],r12
    172e:	mov    QWORD PTR [rsp+0x30],r13
    1733:	mov    QWORD PTR [rsp+0x38],r14
    1738:	mov    QWORD PTR [rsp+0x40],r15
    173d:	mov    rbx,rdi
    1740:	mov    QWORD PTR [rsp+0x8],0x0
    1749:	mov    QWORD PTR [rsp+0x10],0x0
    1752:	mov    QWORD PTR [rsp+0x18],0x0
    175b:	mov    QWORD PTR [rsp],rsi
    175f:	mov    r13,rsi
    1762:	mov    rsi,r13
    1765:	mov    rdi,rbx
    1768:	call   176d <botlish_fn_17+0x51>
			1769: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    176d:	test   rax,rax
    1770:	je     188c <botlish_fn_17+0x170>
    1776:	mov    QWORD PTR [rsp+0x8],rax
    177b:	mov    r12,rax
    177e:	mov    edx,0x1
    1783:	mov    QWORD PTR [rsp+0x10],0x1
    178c:	mov    rcx,r13
    178f:	mov    rsi,r12
    1792:	mov    rdi,rbx
    1795:	call   179a <botlish_fn_17+0x7e>
			1796: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_fill_empty<mutarray, int, int>
    179a:	test   rax,rax
    179d:	je     188c <botlish_fn_17+0x170>
    17a3:	mov    rsi,r13
    17a6:	mov    rdi,rbx
    17a9:	call   17ae <botlish_fn_17+0x92>
			17aa: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    17ae:	test   rax,rax
    17b1:	je     188c <botlish_fn_17+0x170>
    17b7:	mov    QWORD PTR [rsp+0x10],rax
    17bc:	mov    rsi,r13
    17bf:	mov    r14,rax
    17c2:	mov    rdi,rbx
    17c5:	call   17ca <botlish_fn_17+0xae>
			17c6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    17ca:	test   rax,rax
    17cd:	je     188c <botlish_fn_17+0x170>
    17d3:	mov    QWORD PTR [rsp],rax
    17d7:	mov    r13,rax
    17da:	mov    esi,0xb
    17df:	mov    QWORD PTR [rsp+0x18],0xb
    17e8:	mov    rdi,rbx
    17eb:	call   17f0 <botlish_fn_17+0xd4>
			17ec: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    17f0:	test   rax,rax
    17f3:	mov    r15,rax
    17f6:	je     188c <botlish_fn_17+0x170>
    17fc:	mov    edx,0x1
    1801:	mov    rcx,r12
    1804:	mov    rsi,r15
    1807:	mov    rdi,rbx
    180a:	call   180f <botlish_fn_17+0xf3>
			180b: R_X86_64_PLT32	rt_mutarray_set-0x4
    180f:	test   rax,rax
    1812:	je     188c <botlish_fn_17+0x170>
    1818:	mov    edx,0x3
    181d:	mov    rcx,r14
    1820:	mov    rsi,r15
    1823:	mov    rdi,rbx
    1826:	call   182b <botlish_fn_17+0x10f>
			1827: R_X86_64_PLT32	rt_mutarray_set-0x4
    182b:	test   rax,rax
    182e:	je     188c <botlish_fn_17+0x170>
    1834:	mov    edx,0x5
    1839:	mov    rcx,r13
    183c:	mov    rsi,r15
    183f:	mov    rdi,rbx
    1842:	call   1847 <botlish_fn_17+0x12b>
			1843: R_X86_64_PLT32	rt_mutarray_set-0x4
    1847:	test   rax,rax
    184a:	je     188c <botlish_fn_17+0x170>
    1850:	mov    edx,0x7
    1855:	mov    ecx,0x1
    185a:	mov    rsi,r15
    185d:	mov    rdi,rbx
    1860:	call   1865 <botlish_fn_17+0x149>
			1861: R_X86_64_PLT32	rt_mutarray_set-0x4
    1865:	test   rax,rax
    1868:	je     188c <botlish_fn_17+0x170>
    186e:	mov    edx,0x9
    1873:	mov    ecx,0x1
    1878:	mov    rdi,rbx
    187b:	mov    rsi,r15
    187e:	call   1883 <botlish_fn_17+0x167>
			187f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1883:	test   rax,rax
    1886:	jne    18b1 <botlish_fn_17+0x195>
    188c:	xor    rax,rax
    188f:	mov    rbx,QWORD PTR [rsp+0x20]
    1894:	mov    r12,QWORD PTR [rsp+0x28]
    1899:	mov    r13,QWORD PTR [rsp+0x30]
    189e:	mov    r14,QWORD PTR [rsp+0x38]
    18a3:	mov    r15,QWORD PTR [rsp+0x40]
    18a8:	add    rsp,0x50
    18ac:	mov    rsp,rbp
    18af:	pop    rbp
    18b0:	ret
    18b1:	mov    rax,r15
    18b4:	mov    rbx,QWORD PTR [rsp+0x20]
    18b9:	mov    r12,QWORD PTR [rsp+0x28]
    18be:	mov    r13,QWORD PTR [rsp+0x30]
    18c3:	mov    r14,QWORD PTR [rsp+0x38]
    18c8:	mov    r15,QWORD PTR [rsp+0x40]
    18cd:	add    rsp,0x50
    18d1:	mov    rsp,rbp
    18d4:	pop    rbp
    18d5:	ret

00000000000018d6 <botlish_entry_17: ht_alloc<int>>:
    18d6:	push   rbp
    18d7:	mov    rbp,rsp
    18da:	mov    rsi,QWORD PTR [rdx]
    18dd:	call   18e2 <botlish_entry_17+0xc>
			18de: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_alloc<int>
    18e2:	mov    rsp,rbp
    18e5:	pop    rbp
    18e6:	ret

00000000000018e7 <botlish_fn_18: ht_new<generic>>:
    18e7:	push   rbp
    18e8:	mov    rbp,rsp
    18eb:	sub    rsp,0x10
    18ef:	mov    esi,0x11
    18f4:	mov    QWORD PTR [rsp],0x11
    18fc:	call   1901 <botlish_fn_18+0x1a>
			18fd: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_alloc<int>
    1901:	test   rax,rax
    1904:	jne    1916 <botlish_fn_18+0x2f>
    190a:	xor    rax,rax
    190d:	add    rsp,0x10
    1911:	mov    rsp,rbp
    1914:	pop    rbp
    1915:	ret
    1916:	add    rsp,0x10
    191a:	mov    rsp,rbp
    191d:	pop    rbp
    191e:	ret

000000000000191f <botlish_entry_18: ht_new<generic>>:
    191f:	push   rbp
    1920:	mov    rbp,rsp
    1923:	call   1928 <botlish_entry_18+0x9>
			1924: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_new<generic>
    1928:	mov    rsp,rbp
    192b:	pop    rbp
    192c:	ret
    192d:	add    BYTE PTR [rax],al
	...

0000000000001930 <botlish_fn_19: ht_capacity_for<int, int>>:
    1930:	push   rbp
    1931:	mov    rbp,rsp
    1934:	sub    rsp,0x50
    1938:	mov    QWORD PTR [rsp+0x20],rbx
    193d:	mov    QWORD PTR [rsp+0x28],r12
    1942:	mov    QWORD PTR [rsp+0x30],r13
    1947:	mov    QWORD PTR [rsp+0x38],r14
    194c:	mov    QWORD PTR [rsp+0x40],r15
    1951:	mov    r13,rdi
    1954:	mov    QWORD PTR [rsp],rdx
    1958:	mov    rbx,rsi
    195b:	or     rbx,0x1
    195f:	sar    rbx,1
    1962:	mov    r12,rsi
    1965:	mov    r14,rdx
    1968:	mov    rax,r12
    196b:	or     rax,0x1
    196f:	mov    QWORD PTR [rsp+0x8],rax
    1974:	mov    QWORD PTR [rsp+0x10],0x7
    197d:	mov    rax,rbx
    1980:	imul   QWORD PTR [rip+0x159]        # 1ae0 <botlish_fn_19+0x1b0>
    1987:	seto   cl
    198a:	or     rax,0x1
    198e:	test   cl,cl
    1990:	jne    199e <botlish_fn_19+0x6e>
    1996:	mov    rsi,rax
    1999:	jmp    19b5 <botlish_fn_19+0x85>
    199e:	mov    rsi,r12
    19a1:	or     rsi,0x1
    19a5:	mov    edx,0x7
    19aa:	mov    rdi,r13
    19ad:	call   19b2 <botlish_fn_19+0x82>
			19ae: R_X86_64_PLT32	rt_int_mul-0x4
    19b2:	mov    rsi,rax
    19b5:	mov    QWORD PTR [rsp+0x8],rsi
    19ba:	mov    r15,rsi
    19bd:	mov    QWORD PTR [rsp+0x10],0x5
    19c6:	mov    rsi,r14
    19c9:	test   rsi,0x1
    19d0:	je     1a00 <botlish_fn_19+0xd0>
    19d6:	mov    rsi,r14
    19d9:	mov    rax,rsi
    19dc:	sar    rax,1
    19df:	imul   QWORD PTR [rip+0x102]        # 1ae8 <botlish_fn_19+0x1b8>
    19e6:	seto   cl
    19e9:	or     rax,0x1
    19ed:	test   cl,cl
    19ef:	jne    1a00 <botlish_fn_19+0xd0>
    19f5:	mov    rdx,rax
    19f8:	mov    rsi,r15
    19fb:	jmp    1a16 <botlish_fn_19+0xe6>
    1a00:	mov    edx,0x5
    1a05:	mov    rsi,r14
    1a08:	mov    rdi,r13
    1a0b:	call   1a10 <botlish_fn_19+0xe0>
			1a0c: R_X86_64_PLT32	rt_int_mul-0x4
    1a10:	mov    rdx,rax
    1a13:	mov    rsi,r15
    1a16:	mov    rax,rsi
    1a19:	and    rax,rdx
    1a1c:	test   rax,0x1
    1a22:	jne    1a45 <botlish_fn_19+0x115>
    1a28:	mov    rdi,r13
    1a2b:	call   1a30 <botlish_fn_19+0x100>
			1a2c: R_X86_64_PLT32	rt_int_cmp-0x4
    1a30:	mov    ecx,0x2
    1a35:	test   rax,rax
    1a38:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1ae0 <botlish_fn_19+0x1b0>
    1a40:	jmp    1a55 <botlish_fn_19+0x125>
    1a45:	mov    ecx,0x2
    1a4a:	cmp    rsi,rdx
    1a4d:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1ae0 <botlish_fn_19+0x1b0>
    1a55:	cmp    rcx,0x6
    1a59:	je     1ab5 <botlish_fn_19+0x185>
    1a5f:	mov    QWORD PTR [rsp+0x8],0x5
    1a68:	mov    rsi,r14
    1a6b:	test   rsi,0x1
    1a72:	je     1a99 <botlish_fn_19+0x169>
    1a78:	mov    rsi,r14
    1a7b:	mov    rax,rsi
    1a7e:	sar    rax,1
    1a81:	imul   QWORD PTR [rip+0x60]        # 1ae8 <botlish_fn_19+0x1b8>
    1a88:	seto   sil
    1a8c:	or     rax,0x1
    1a90:	test   sil,sil
    1a93:	je     1aa9 <botlish_fn_19+0x179>
    1a99:	mov    edx,0x5
    1a9e:	mov    rsi,r14
    1aa1:	mov    rdi,r13
    1aa4:	call   1aa9 <botlish_fn_19+0x179>
			1aa5: R_X86_64_PLT32	rt_int_mul-0x4
    1aa9:	mov    QWORD PTR [rsp],rax
    1aad:	mov    r14,rax
    1ab0:	jmp    1968 <botlish_fn_19+0x38>
    1ab5:	mov    rax,r14
    1ab8:	mov    rbx,QWORD PTR [rsp+0x20]
    1abd:	mov    r12,QWORD PTR [rsp+0x28]
    1ac2:	mov    r13,QWORD PTR [rsp+0x30]
    1ac7:	mov    r14,QWORD PTR [rsp+0x38]
    1acc:	mov    r15,QWORD PTR [rsp+0x40]
    1ad1:	add    rsp,0x50
    1ad5:	mov    rsp,rbp
    1ad8:	pop    rbp
    1ad9:	ret
    1ada:	add    BYTE PTR [rax],al
    1adc:	add    BYTE PTR [rax],al
    1ade:	add    BYTE PTR [rax],al
    1ae0:	(bad)
    1ae1:	add    BYTE PTR [rax],al
    1ae3:	add    BYTE PTR [rax],al
    1ae5:	add    BYTE PTR [rax],al
    1ae7:	add    BYTE PTR [rax+rax*1],al
    1aea:	add    BYTE PTR [rax],al
    1aec:	add    BYTE PTR [rax],al
	...

0000000000001af0 <botlish_entry_19: ht_capacity_for<int, int>>:
    1af0:	push   rbp
    1af1:	mov    rbp,rsp
    1af4:	mov    rsi,QWORD PTR [rdx]
    1af7:	mov    rdx,QWORD PTR [rdx+0x8]
    1afb:	call   1b00 <botlish_entry_19+0x10>
			1afc: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_capacity_for<int, int>
    1b00:	mov    rsp,rbp
    1b03:	pop    rbp
    1b04:	ret

0000000000001b05 <botlish_fn_20: ht_new_sized<int>>:
    1b05:	push   rbp
    1b06:	mov    rbp,rsp
    1b09:	sub    rsp,0x20
    1b0d:	mov    QWORD PTR [rsp+0x10],r12
    1b12:	mov    r12,rdi
    1b15:	mov    QWORD PTR [rsp],rsi
    1b19:	mov    edx,0x11
    1b1e:	mov    QWORD PTR [rsp+0x8],0x11
    1b27:	mov    rdi,r12
    1b2a:	call   1b2f <botlish_fn_20+0x2a>
			1b2b: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_capacity_for<int, int>
    1b2f:	mov    QWORD PTR [rsp],rax
    1b33:	mov    rsi,rax
    1b36:	mov    rdi,r12
    1b39:	call   1b3e <botlish_fn_20+0x39>
			1b3a: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_alloc<int>
    1b3e:	test   rax,rax
    1b41:	jne    1b58 <botlish_fn_20+0x53>
    1b47:	xor    rax,rax
    1b4a:	mov    r12,QWORD PTR [rsp+0x10]
    1b4f:	add    rsp,0x20
    1b53:	mov    rsp,rbp
    1b56:	pop    rbp
    1b57:	ret
    1b58:	mov    r12,QWORD PTR [rsp+0x10]
    1b5d:	add    rsp,0x20
    1b61:	mov    rsp,rbp
    1b64:	pop    rbp
    1b65:	ret

0000000000001b66 <botlish_entry_20: ht_new_sized<int>>:
    1b66:	push   rbp
    1b67:	mov    rbp,rsp
    1b6a:	mov    rsi,QWORD PTR [rdx]
    1b6d:	call   1b72 <botlish_entry_20+0xc>
			1b6e: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_new_sized<int>
    1b72:	mov    rsp,rbp
    1b75:	pop    rbp
    1b76:	ret

0000000000001b77 <botlish_fn_21: ht_controls<mutarray>>:
    1b77:	push   rbp
    1b78:	mov    rbp,rsp
    1b7b:	mov    edx,0x1
    1b80:	call   1b85 <botlish_fn_21+0xe>
			1b81: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b85:	test   rax,rax
    1b88:	jne    1b96 <botlish_fn_21+0x1f>
    1b8e:	xor    rax,rax
    1b91:	mov    rsp,rbp
    1b94:	pop    rbp
    1b95:	ret
    1b96:	mov    rsp,rbp
    1b99:	pop    rbp
    1b9a:	ret

0000000000001b9b <botlish_entry_21: ht_controls<mutarray>>:
    1b9b:	push   rbp
    1b9c:	mov    rbp,rsp
    1b9f:	mov    rsi,QWORD PTR [rdx]
    1ba2:	call   1ba7 <botlish_entry_21+0xc>
			1ba3: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    1ba7:	mov    rsp,rbp
    1baa:	pop    rbp
    1bab:	ret

0000000000001bac <botlish_fn_22: ht_controls<generic>>:
    1bac:	push   rbp
    1bad:	mov    rbp,rsp
    1bb0:	xor    r8d,r8d
    1bb3:	test   rsi,0x7
    1bba:	jne    1bca <botlish_fn_22+0x1e>
    1bc0:	movzx  rax,BYTE PTR [rsi]
    1bc4:	cmp    al,0x8
    1bc6:	sete   r8b
    1bca:	test   r8b,r8b
    1bcd:	jne    1bea <botlish_fn_22+0x3e>
    1bd3:	mov    rax,QWORD PTR [rdi+0x10]
    1bd7:	mov    rcx,QWORD PTR [rax+0x20]
    1bdb:	mov    edx,0x8
    1be0:	call   1be5 <botlish_fn_22+0x39>
			1be1: R_X86_64_PLT32	rt_type_error-0x4
    1be5:	jmp    1bfd <botlish_fn_22+0x51>
    1bea:	mov    edx,0x1
    1bef:	call   1bf4 <botlish_fn_22+0x48>
			1bf0: R_X86_64_PLT32	rt_mutarray_get-0x4
    1bf4:	test   rax,rax
    1bf7:	jne    1c05 <botlish_fn_22+0x59>
    1bfd:	xor    rax,rax
    1c00:	mov    rsp,rbp
    1c03:	pop    rbp
    1c04:	ret
    1c05:	mov    rsp,rbp
    1c08:	pop    rbp
    1c09:	ret

0000000000001c0a <botlish_entry_22: ht_controls<generic>>:
    1c0a:	push   rbp
    1c0b:	mov    rbp,rsp
    1c0e:	mov    rsi,QWORD PTR [rdx]
    1c11:	call   1c16 <botlish_entry_22+0xc>
			1c12: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_controls<generic>
    1c16:	mov    rsp,rbp
    1c19:	pop    rbp
    1c1a:	ret

0000000000001c1b <botlish_fn_23: ht_keys<mutarray>>:
    1c1b:	push   rbp
    1c1c:	mov    rbp,rsp
    1c1f:	mov    edx,0x3
    1c24:	call   1c29 <botlish_fn_23+0xe>
			1c25: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c29:	test   rax,rax
    1c2c:	jne    1c3a <botlish_fn_23+0x1f>
    1c32:	xor    rax,rax
    1c35:	mov    rsp,rbp
    1c38:	pop    rbp
    1c39:	ret
    1c3a:	mov    rsp,rbp
    1c3d:	pop    rbp
    1c3e:	ret

0000000000001c3f <botlish_entry_23: ht_keys<mutarray>>:
    1c3f:	push   rbp
    1c40:	mov    rbp,rsp
    1c43:	mov    rsi,QWORD PTR [rdx]
    1c46:	call   1c4b <botlish_entry_23+0xc>
			1c47: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    1c4b:	mov    rsp,rbp
    1c4e:	pop    rbp
    1c4f:	ret

0000000000001c50 <botlish_fn_24: ht_keys<generic>>:
    1c50:	push   rbp
    1c51:	mov    rbp,rsp
    1c54:	xor    r8d,r8d
    1c57:	test   rsi,0x7
    1c5e:	jne    1c6e <botlish_fn_24+0x1e>
    1c64:	movzx  rax,BYTE PTR [rsi]
    1c68:	cmp    al,0x8
    1c6a:	sete   r8b
    1c6e:	test   r8b,r8b
    1c71:	jne    1c8e <botlish_fn_24+0x3e>
    1c77:	mov    rax,QWORD PTR [rdi+0x10]
    1c7b:	mov    rcx,QWORD PTR [rax+0x20]
    1c7f:	mov    edx,0x8
    1c84:	call   1c89 <botlish_fn_24+0x39>
			1c85: R_X86_64_PLT32	rt_type_error-0x4
    1c89:	jmp    1ca1 <botlish_fn_24+0x51>
    1c8e:	mov    edx,0x3
    1c93:	call   1c98 <botlish_fn_24+0x48>
			1c94: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c98:	test   rax,rax
    1c9b:	jne    1ca9 <botlish_fn_24+0x59>
    1ca1:	xor    rax,rax
    1ca4:	mov    rsp,rbp
    1ca7:	pop    rbp
    1ca8:	ret
    1ca9:	mov    rsp,rbp
    1cac:	pop    rbp
    1cad:	ret

0000000000001cae <botlish_entry_24: ht_keys<generic>>:
    1cae:	push   rbp
    1caf:	mov    rbp,rsp
    1cb2:	mov    rsi,QWORD PTR [rdx]
    1cb5:	call   1cba <botlish_entry_24+0xc>
			1cb6: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_keys<generic>
    1cba:	mov    rsp,rbp
    1cbd:	pop    rbp
    1cbe:	ret

0000000000001cbf <botlish_fn_25: ht_values<mutarray>>:
    1cbf:	push   rbp
    1cc0:	mov    rbp,rsp
    1cc3:	mov    edx,0x5
    1cc8:	call   1ccd <botlish_fn_25+0xe>
			1cc9: R_X86_64_PLT32	rt_mutarray_get-0x4
    1ccd:	test   rax,rax
    1cd0:	jne    1cde <botlish_fn_25+0x1f>
    1cd6:	xor    rax,rax
    1cd9:	mov    rsp,rbp
    1cdc:	pop    rbp
    1cdd:	ret
    1cde:	mov    rsp,rbp
    1ce1:	pop    rbp
    1ce2:	ret

0000000000001ce3 <botlish_entry_25: ht_values<mutarray>>:
    1ce3:	push   rbp
    1ce4:	mov    rbp,rsp
    1ce7:	mov    rsi,QWORD PTR [rdx]
    1cea:	call   1cef <botlish_entry_25+0xc>
			1ceb: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    1cef:	mov    rsp,rbp
    1cf2:	pop    rbp
    1cf3:	ret

0000000000001cf4 <botlish_fn_26: ht_values<generic>>:
    1cf4:	push   rbp
    1cf5:	mov    rbp,rsp
    1cf8:	xor    r8d,r8d
    1cfb:	test   rsi,0x7
    1d02:	jne    1d12 <botlish_fn_26+0x1e>
    1d08:	movzx  rax,BYTE PTR [rsi]
    1d0c:	cmp    al,0x8
    1d0e:	sete   r8b
    1d12:	test   r8b,r8b
    1d15:	jne    1d32 <botlish_fn_26+0x3e>
    1d1b:	mov    rax,QWORD PTR [rdi+0x10]
    1d1f:	mov    rcx,QWORD PTR [rax+0x20]
    1d23:	mov    edx,0x8
    1d28:	call   1d2d <botlish_fn_26+0x39>
			1d29: R_X86_64_PLT32	rt_type_error-0x4
    1d2d:	jmp    1d45 <botlish_fn_26+0x51>
    1d32:	mov    edx,0x5
    1d37:	call   1d3c <botlish_fn_26+0x48>
			1d38: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d3c:	test   rax,rax
    1d3f:	jne    1d4d <botlish_fn_26+0x59>
    1d45:	xor    rax,rax
    1d48:	mov    rsp,rbp
    1d4b:	pop    rbp
    1d4c:	ret
    1d4d:	mov    rsp,rbp
    1d50:	pop    rbp
    1d51:	ret

0000000000001d52 <botlish_entry_26: ht_values<generic>>:
    1d52:	push   rbp
    1d53:	mov    rbp,rsp
    1d56:	mov    rsi,QWORD PTR [rdx]
    1d59:	call   1d5e <botlish_entry_26+0xc>
			1d5a: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_values<generic>
    1d5e:	mov    rsp,rbp
    1d61:	pop    rbp
    1d62:	ret

0000000000001d63 <botlish_fn_27: ht_size<mutarray>>:
    1d63:	push   rbp
    1d64:	mov    rbp,rsp
    1d67:	mov    edx,0x7
    1d6c:	call   1d71 <botlish_fn_27+0xe>
			1d6d: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d71:	test   rax,rax
    1d74:	jne    1d82 <botlish_fn_27+0x1f>
    1d7a:	xor    rax,rax
    1d7d:	mov    rsp,rbp
    1d80:	pop    rbp
    1d81:	ret
    1d82:	mov    rsp,rbp
    1d85:	pop    rbp
    1d86:	ret

0000000000001d87 <botlish_entry_27: ht_size<mutarray>>:
    1d87:	push   rbp
    1d88:	mov    rbp,rsp
    1d8b:	mov    rsi,QWORD PTR [rdx]
    1d8e:	call   1d93 <botlish_entry_27+0xc>
			1d8f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    1d93:	mov    rsp,rbp
    1d96:	pop    rbp
    1d97:	ret

0000000000001d98 <botlish_fn_28: ht_size<generic>>:
    1d98:	push   rbp
    1d99:	mov    rbp,rsp
    1d9c:	xor    r8d,r8d
    1d9f:	test   rsi,0x7
    1da6:	jne    1db6 <botlish_fn_28+0x1e>
    1dac:	movzx  rax,BYTE PTR [rsi]
    1db0:	cmp    al,0x8
    1db2:	sete   r8b
    1db6:	test   r8b,r8b
    1db9:	jne    1dd6 <botlish_fn_28+0x3e>
    1dbf:	mov    rax,QWORD PTR [rdi+0x10]
    1dc3:	mov    rcx,QWORD PTR [rax+0x20]
    1dc7:	mov    edx,0x8
    1dcc:	call   1dd1 <botlish_fn_28+0x39>
			1dcd: R_X86_64_PLT32	rt_type_error-0x4
    1dd1:	jmp    1de9 <botlish_fn_28+0x51>
    1dd6:	mov    edx,0x7
    1ddb:	call   1de0 <botlish_fn_28+0x48>
			1ddc: R_X86_64_PLT32	rt_mutarray_get-0x4
    1de0:	test   rax,rax
    1de3:	jne    1df1 <botlish_fn_28+0x59>
    1de9:	xor    rax,rax
    1dec:	mov    rsp,rbp
    1def:	pop    rbp
    1df0:	ret
    1df1:	mov    rsp,rbp
    1df4:	pop    rbp
    1df5:	ret

0000000000001df6 <botlish_entry_28: ht_size<generic>>:
    1df6:	push   rbp
    1df7:	mov    rbp,rsp
    1dfa:	mov    rsi,QWORD PTR [rdx]
    1dfd:	call   1e02 <botlish_entry_28+0xc>
			1dfe: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    1e02:	mov    rsp,rbp
    1e05:	pop    rbp
    1e06:	ret

0000000000001e07 <botlish_fn_29: ht_tombstones<mutarray>>:
    1e07:	push   rbp
    1e08:	mov    rbp,rsp
    1e0b:	mov    edx,0x9
    1e10:	call   1e15 <botlish_fn_29+0xe>
			1e11: R_X86_64_PLT32	rt_mutarray_get-0x4
    1e15:	test   rax,rax
    1e18:	jne    1e26 <botlish_fn_29+0x1f>
    1e1e:	xor    rax,rax
    1e21:	mov    rsp,rbp
    1e24:	pop    rbp
    1e25:	ret
    1e26:	mov    rsp,rbp
    1e29:	pop    rbp
    1e2a:	ret

0000000000001e2b <botlish_entry_29: ht_tombstones<mutarray>>:
    1e2b:	push   rbp
    1e2c:	mov    rbp,rsp
    1e2f:	mov    rsi,QWORD PTR [rdx]
    1e32:	call   1e37 <botlish_entry_29+0xc>
			1e33: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    1e37:	mov    rsp,rbp
    1e3a:	pop    rbp
    1e3b:	ret

0000000000001e3c <botlish_fn_30: ht_capacity<mutarray>>:
    1e3c:	push   rbp
    1e3d:	mov    rbp,rsp
    1e40:	sub    rsp,0x10
    1e44:	mov    QWORD PTR [rsp],rbx
    1e48:	mov    rbx,rdi
    1e4b:	mov    rdi,rbx
    1e4e:	call   1e53 <botlish_fn_30+0x17>
			1e4f: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    1e53:	test   rax,rax
    1e56:	je     1ea0 <botlish_fn_30+0x64>
    1e5c:	xor    r8d,r8d
    1e5f:	test   rax,0x7
    1e65:	je     1e73 <botlish_fn_30+0x37>
    1e6b:	mov    rsi,rax
    1e6e:	jmp    1e82 <botlish_fn_30+0x46>
    1e73:	movzx  rcx,BYTE PTR [rax]
    1e77:	mov    rsi,rax
    1e7a:	rex cmp cl,0x8
    1e7e:	sete   r8b
    1e82:	test   r8b,r8b
    1e85:	jne    1eb0 <botlish_fn_30+0x74>
    1e8b:	mov    rdi,rbx
    1e8e:	mov    rax,QWORD PTR [rdi+0x10]
    1e92:	mov    rcx,QWORD PTR [rax+0x28]
    1e96:	mov    edx,0x8
    1e9b:	call   1ea0 <botlish_fn_30+0x64>
			1e9c: R_X86_64_PLT32	rt_type_error-0x4
    1ea0:	xor    rax,rax
    1ea3:	mov    rbx,QWORD PTR [rsp]
    1ea7:	add    rsp,0x10
    1eab:	mov    rsp,rbp
    1eae:	pop    rbp
    1eaf:	ret
    1eb0:	mov    rdi,rbx
    1eb3:	call   1eb8 <botlish_fn_30+0x7c>
			1eb4: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1eb8:	mov    rbx,QWORD PTR [rsp]
    1ebc:	add    rsp,0x10
    1ec0:	mov    rsp,rbp
    1ec3:	pop    rbp
    1ec4:	ret

0000000000001ec5 <botlish_entry_30: ht_capacity<mutarray>>:
    1ec5:	push   rbp
    1ec6:	mov    rbp,rsp
    1ec9:	mov    rsi,QWORD PTR [rdx]
    1ecc:	call   1ed1 <botlish_entry_30+0xc>
			1ecd: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    1ed1:	mov    rsp,rbp
    1ed4:	pop    rbp
    1ed5:	ret

0000000000001ed6 <botlish_fn_31: ht_capacity<generic>>:
    1ed6:	push   rbp
    1ed7:	mov    rbp,rsp
    1eda:	sub    rsp,0x10
    1ede:	mov    QWORD PTR [rsp],rbx
    1ee2:	mov    rbx,rdi
    1ee5:	mov    rdi,rbx
    1ee8:	call   1eed <botlish_fn_31+0x17>
			1ee9: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_controls<generic>
    1eed:	test   rax,rax
    1ef0:	je     1f3a <botlish_fn_31+0x64>
    1ef6:	xor    r8d,r8d
    1ef9:	test   rax,0x7
    1eff:	je     1f0d <botlish_fn_31+0x37>
    1f05:	mov    rsi,rax
    1f08:	jmp    1f1c <botlish_fn_31+0x46>
    1f0d:	movzx  rcx,BYTE PTR [rax]
    1f11:	mov    rsi,rax
    1f14:	rex cmp cl,0x8
    1f18:	sete   r8b
    1f1c:	test   r8b,r8b
    1f1f:	jne    1f4a <botlish_fn_31+0x74>
    1f25:	mov    rdi,rbx
    1f28:	mov    rax,QWORD PTR [rdi+0x10]
    1f2c:	mov    rcx,QWORD PTR [rax+0x28]
    1f30:	mov    edx,0x8
    1f35:	call   1f3a <botlish_fn_31+0x64>
			1f36: R_X86_64_PLT32	rt_type_error-0x4
    1f3a:	xor    rax,rax
    1f3d:	mov    rbx,QWORD PTR [rsp]
    1f41:	add    rsp,0x10
    1f45:	mov    rsp,rbp
    1f48:	pop    rbp
    1f49:	ret
    1f4a:	mov    rdi,rbx
    1f4d:	call   1f52 <botlish_fn_31+0x7c>
			1f4e: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1f52:	mov    rbx,QWORD PTR [rsp]
    1f56:	add    rsp,0x10
    1f5a:	mov    rsp,rbp
    1f5d:	pop    rbp
    1f5e:	ret

0000000000001f5f <botlish_entry_31: ht_capacity<generic>>:
    1f5f:	push   rbp
    1f60:	mov    rbp,rsp
    1f63:	mov    rsi,QWORD PTR [rdx]
    1f66:	call   1f6b <botlish_entry_31+0xc>
			1f67: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_capacity<generic>
    1f6b:	mov    rsp,rbp
    1f6e:	pop    rbp
    1f6f:	ret

0000000000001f70 <botlish_fn_32: ht_probe_start<mutarray, any>>:
    1f70:	push   rbp
    1f71:	mov    rbp,rsp
    1f74:	sub    rsp,0x20
    1f78:	mov    QWORD PTR [rsp],r12
    1f7c:	mov    QWORD PTR [rsp+0x8],r13
    1f81:	mov    QWORD PTR [rsp+0x10],r14
    1f86:	mov    r12,rdi
    1f89:	mov    r14,rsi
    1f8c:	mov    rsi,rdx
    1f8f:	mov    rdi,r12
    1f92:	call   1f97 <botlish_fn_32+0x27>
			1f93: R_X86_64_PLT32	rt_hash-0x4
    1f97:	test   rax,rax
    1f9a:	mov    r13,rax
    1f9d:	je     1fce <botlish_fn_32+0x5e>
    1fa3:	mov    rsi,r14
    1fa6:	mov    rdi,r12
    1fa9:	call   1fae <botlish_fn_32+0x3e>
			1faa: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    1fae:	test   rax,rax
    1fb1:	mov    rdx,rax
    1fb4:	je     1fce <botlish_fn_32+0x5e>
    1fba:	mov    rsi,r13
    1fbd:	mov    rdi,r12
    1fc0:	call   1fc5 <botlish_fn_32+0x55>
			1fc1: R_X86_64_PLT32	rt_int_mod-0x4
    1fc5:	test   rax,rax
    1fc8:	jne    1fe8 <botlish_fn_32+0x78>
    1fce:	xor    rax,rax
    1fd1:	mov    r12,QWORD PTR [rsp]
    1fd5:	mov    r13,QWORD PTR [rsp+0x8]
    1fda:	mov    r14,QWORD PTR [rsp+0x10]
    1fdf:	add    rsp,0x20
    1fe3:	mov    rsp,rbp
    1fe6:	pop    rbp
    1fe7:	ret
    1fe8:	mov    r12,QWORD PTR [rsp]
    1fec:	mov    r13,QWORD PTR [rsp+0x8]
    1ff1:	mov    r14,QWORD PTR [rsp+0x10]
    1ff6:	add    rsp,0x20
    1ffa:	mov    rsp,rbp
    1ffd:	pop    rbp
    1ffe:	ret

0000000000001fff <botlish_entry_32: ht_probe_start<mutarray, any>>:
    1fff:	push   rbp
    2000:	mov    rbp,rsp
    2003:	mov    rsi,QWORD PTR [rdx]
    2006:	mov    rdx,QWORD PTR [rdx+0x8]
    200a:	call   200f <botlish_entry_32+0x10>
			200b: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    200f:	mov    rsp,rbp
    2012:	pop    rbp
    2013:	ret

0000000000002014 <botlish_fn_33: ht_probe_start<any, str>>:
    2014:	push   rbp
    2015:	mov    rbp,rsp
    2018:	sub    rsp,0x20
    201c:	mov    QWORD PTR [rsp],r12
    2020:	mov    QWORD PTR [rsp+0x8],r13
    2025:	mov    QWORD PTR [rsp+0x10],r14
    202a:	mov    r12,rdi
    202d:	mov    r14,rsi
    2030:	mov    rsi,rdx
    2033:	mov    rdi,r12
    2036:	call   203b <botlish_fn_33+0x27>
			2037: R_X86_64_PLT32	rt_hash-0x4
    203b:	test   rax,rax
    203e:	mov    r13,rax
    2041:	je     2072 <botlish_fn_33+0x5e>
    2047:	mov    rsi,r14
    204a:	mov    rdi,r12
    204d:	call   2052 <botlish_fn_33+0x3e>
			204e: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_capacity<generic>
    2052:	test   rax,rax
    2055:	mov    rdx,rax
    2058:	je     2072 <botlish_fn_33+0x5e>
    205e:	mov    rsi,r13
    2061:	mov    rdi,r12
    2064:	call   2069 <botlish_fn_33+0x55>
			2065: R_X86_64_PLT32	rt_int_mod-0x4
    2069:	test   rax,rax
    206c:	jne    208c <botlish_fn_33+0x78>
    2072:	xor    rax,rax
    2075:	mov    r12,QWORD PTR [rsp]
    2079:	mov    r13,QWORD PTR [rsp+0x8]
    207e:	mov    r14,QWORD PTR [rsp+0x10]
    2083:	add    rsp,0x20
    2087:	mov    rsp,rbp
    208a:	pop    rbp
    208b:	ret
    208c:	mov    r12,QWORD PTR [rsp]
    2090:	mov    r13,QWORD PTR [rsp+0x8]
    2095:	mov    r14,QWORD PTR [rsp+0x10]
    209a:	add    rsp,0x20
    209e:	mov    rsp,rbp
    20a1:	pop    rbp
    20a2:	ret

00000000000020a3 <botlish_entry_33: ht_probe_start<any, str>>:
    20a3:	push   rbp
    20a4:	mov    rbp,rsp
    20a7:	mov    rsi,QWORD PTR [rdx]
    20aa:	mov    rdx,QWORD PTR [rdx+0x8]
    20ae:	call   20b3 <botlish_entry_33+0x10>
			20af: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_probe_start<any, str>
    20b3:	mov    rsp,rbp
    20b6:	pop    rbp
    20b7:	ret

00000000000020b8 <botlish_fn_34: ht_probe_next<mutarray, int>>:
    20b8:	push   rbp
    20b9:	mov    rbp,rsp
    20bc:	sub    rsp,0x40
    20c0:	mov    QWORD PTR [rsp+0x20],rbx
    20c5:	mov    QWORD PTR [rsp+0x28],r12
    20ca:	mov    QWORD PTR [rsp+0x30],r13
    20cf:	mov    r13,rdi
    20d2:	mov    QWORD PTR [rsp],rsi
    20d6:	mov    rbx,rsi
    20d9:	mov    QWORD PTR [rsp+0x8],rdx
    20de:	mov    QWORD PTR [rsp+0x10],0x3
    20e7:	test   rdx,0x1
    20ee:	jne    20fc <botlish_fn_34+0x44>
    20f4:	mov    rsi,rdx
    20f7:	jmp    211c <botlish_fn_34+0x64>
    20fc:	mov    rsi,rdx
    20ff:	add    rsi,0x2
    2103:	mov    r12,rsi
    2106:	mov    rsi,rdx
    2109:	seto   al
    210c:	test   al,al
    210e:	jne    211c <botlish_fn_34+0x64>
    2114:	mov    rsi,rbx
    2117:	jmp    212f <botlish_fn_34+0x77>
    211c:	mov    edx,0x3
    2121:	mov    rdi,r13
    2124:	call   2129 <botlish_fn_34+0x71>
			2125: R_X86_64_PLT32	rt_int_add-0x4
    2129:	mov    rsi,rbx
    212c:	mov    r12,rax
    212f:	mov    rdi,r13
    2132:	call   2137 <botlish_fn_34+0x7f>
			2133: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    2137:	test   rax,rax
    213a:	mov    rdx,rax
    213d:	je     2157 <botlish_fn_34+0x9f>
    2143:	mov    rsi,r12
    2146:	mov    rdi,r13
    2149:	call   214e <botlish_fn_34+0x96>
			214a: R_X86_64_PLT32	rt_int_mod-0x4
    214e:	test   rax,rax
    2151:	jne    2172 <botlish_fn_34+0xba>
    2157:	xor    rax,rax
    215a:	mov    rbx,QWORD PTR [rsp+0x20]
    215f:	mov    r12,QWORD PTR [rsp+0x28]
    2164:	mov    r13,QWORD PTR [rsp+0x30]
    2169:	add    rsp,0x40
    216d:	mov    rsp,rbp
    2170:	pop    rbp
    2171:	ret
    2172:	mov    rbx,QWORD PTR [rsp+0x20]
    2177:	mov    r12,QWORD PTR [rsp+0x28]
    217c:	mov    r13,QWORD PTR [rsp+0x30]
    2181:	add    rsp,0x40
    2185:	mov    rsp,rbp
    2188:	pop    rbp
    2189:	ret

000000000000218a <botlish_entry_34: ht_probe_next<mutarray, int>>:
    218a:	push   rbp
    218b:	mov    rbp,rsp
    218e:	mov    rsi,QWORD PTR [rdx]
    2191:	mov    rdx,QWORD PTR [rdx+0x8]
    2195:	call   219a <botlish_entry_34+0x10>
			2196: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_probe_next<mutarray, int>
    219a:	mov    rsp,rbp
    219d:	pop    rbp
    219e:	ret

000000000000219f <botlish_fn_35: ht_probe_next<any, int>>:
    219f:	push   rbp
    21a0:	mov    rbp,rsp
    21a3:	sub    rsp,0x40
    21a7:	mov    QWORD PTR [rsp+0x20],rbx
    21ac:	mov    QWORD PTR [rsp+0x28],r12
    21b1:	mov    QWORD PTR [rsp+0x30],r13
    21b6:	mov    r13,rdi
    21b9:	mov    QWORD PTR [rsp],rsi
    21bd:	mov    rbx,rsi
    21c0:	mov    QWORD PTR [rsp+0x8],rdx
    21c5:	mov    QWORD PTR [rsp+0x10],0x3
    21ce:	test   rdx,0x1
    21d5:	jne    21e3 <botlish_fn_35+0x44>
    21db:	mov    rsi,rdx
    21de:	jmp    2203 <botlish_fn_35+0x64>
    21e3:	mov    rsi,rdx
    21e6:	add    rsi,0x2
    21ea:	mov    r12,rsi
    21ed:	mov    rsi,rdx
    21f0:	seto   al
    21f3:	test   al,al
    21f5:	jne    2203 <botlish_fn_35+0x64>
    21fb:	mov    rsi,rbx
    21fe:	jmp    2216 <botlish_fn_35+0x77>
    2203:	mov    edx,0x3
    2208:	mov    rdi,r13
    220b:	call   2210 <botlish_fn_35+0x71>
			220c: R_X86_64_PLT32	rt_int_add-0x4
    2210:	mov    rsi,rbx
    2213:	mov    r12,rax
    2216:	mov    rdi,r13
    2219:	call   221e <botlish_fn_35+0x7f>
			221a: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_capacity<generic>
    221e:	test   rax,rax
    2221:	mov    rdx,rax
    2224:	je     223e <botlish_fn_35+0x9f>
    222a:	mov    rsi,r12
    222d:	mov    rdi,r13
    2230:	call   2235 <botlish_fn_35+0x96>
			2231: R_X86_64_PLT32	rt_int_mod-0x4
    2235:	test   rax,rax
    2238:	jne    2259 <botlish_fn_35+0xba>
    223e:	xor    rax,rax
    2241:	mov    rbx,QWORD PTR [rsp+0x20]
    2246:	mov    r12,QWORD PTR [rsp+0x28]
    224b:	mov    r13,QWORD PTR [rsp+0x30]
    2250:	add    rsp,0x40
    2254:	mov    rsp,rbp
    2257:	pop    rbp
    2258:	ret
    2259:	mov    rbx,QWORD PTR [rsp+0x20]
    225e:	mov    r12,QWORD PTR [rsp+0x28]
    2263:	mov    r13,QWORD PTR [rsp+0x30]
    2268:	add    rsp,0x40
    226c:	mov    rsp,rbp
    226f:	pop    rbp
    2270:	ret

0000000000002271 <botlish_entry_35: ht_probe_next<any, int>>:
    2271:	push   rbp
    2272:	mov    rbp,rsp
    2275:	mov    rsi,QWORD PTR [rdx]
    2278:	mov    rdx,QWORD PTR [rdx+0x8]
    227c:	call   2281 <botlish_entry_35+0x10>
			227d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_next<any, int>
    2281:	mov    rsp,rbp
    2284:	pop    rbp
    2285:	ret
	...

0000000000002288 <botlish_fn_36: ht_find_get<any, str, int>>:
    2288:	push   rbp
    2289:	mov    rbp,rsp
    228c:	sub    rsp,0x50
    2290:	mov    QWORD PTR [rsp+0x20],rbx
    2295:	mov    QWORD PTR [rsp+0x28],r12
    229a:	mov    QWORD PTR [rsp+0x30],r13
    229f:	mov    QWORD PTR [rsp+0x38],r14
    22a4:	mov    QWORD PTR [rsp+0x40],r15
    22a9:	mov    r14,rdi
    22ac:	mov    QWORD PTR [rsp],rsi
    22b0:	mov    QWORD PTR [rsp+0x8],rdx
    22b5:	mov    r13,rdx
    22b8:	mov    QWORD PTR [rsp+0x10],rcx
    22bd:	mov    r12,rsi
    22c0:	mov    r15,rcx
    22c3:	mov    rsi,r12
    22c6:	mov    rdi,r14
    22c9:	call   22ce <botlish_fn_36+0x46>
			22ca: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_controls<generic>
    22ce:	test   rax,rax
    22d1:	je     24d0 <botlish_fn_36+0x248>
    22d7:	xor    ecx,ecx
    22d9:	test   rax,0x7
    22df:	je     22ed <botlish_fn_36+0x65>
    22e5:	mov    rsi,rax
    22e8:	jmp    22fb <botlish_fn_36+0x73>
    22ed:	movzx  rcx,BYTE PTR [rax]
    22f1:	mov    rsi,rax
    22f4:	rex cmp cl,0x8
    22f8:	sete   cl
    22fb:	test   cl,cl
    22fd:	jne    231d <botlish_fn_36+0x95>
    2303:	mov    rdi,r14
    2306:	mov    rdx,QWORD PTR [rdi+0x10]
    230a:	mov    rcx,QWORD PTR [rdx+0x20]
    230e:	mov    edx,0x8
    2313:	call   2318 <botlish_fn_36+0x90>
			2314: R_X86_64_PLT32	rt_type_error-0x4
    2318:	jmp    24d0 <botlish_fn_36+0x248>
    231d:	mov    rdx,r15
    2320:	mov    rdi,r14
    2323:	call   2328 <botlish_fn_36+0xa0>
			2324: R_X86_64_PLT32	rt_mutarray_get-0x4
    2328:	mov    rcx,rax
    232b:	mov    QWORD PTR [rsp+0x18],rax
    2330:	test   rax,rcx
    2333:	je     24d0 <botlish_fn_36+0x248>
    2339:	mov    rax,QWORD PTR [rsp+0x18]
    233e:	test   rax,0x1
    2344:	jne    236f <botlish_fn_36+0xe7>
    234a:	mov    edx,0x1
    234f:	mov    rsi,QWORD PTR [rsp+0x18]
    2354:	mov    rdi,r14
    2357:	call   235c <botlish_fn_36+0xd4>
			2358: R_X86_64_PLT32	rt_value_eq-0x4
    235c:	test   rax,rax
    235f:	je     24d0 <botlish_fn_36+0x248>
    2365:	mov    rcx,QWORD PTR [rsp+0x18]
    236a:	jmp    2385 <botlish_fn_36+0xfd>
    236f:	mov    eax,0x2
    2374:	mov    rcx,QWORD PTR [rsp+0x18]
    2379:	cmp    rcx,0x1
    237d:	cmove  rax,QWORD PTR [rip+0x1db]        # 2560 <botlish_fn_36+0x2d8>
    2385:	mov    ebx,0x6
    238a:	cmp    rax,0x6
    238e:	je     2530 <botlish_fn_36+0x2a8>
    2394:	test   rcx,0x1
    239b:	mov    QWORD PTR [rsp+0x18],rcx
    23a0:	jne    23c6 <botlish_fn_36+0x13e>
    23a6:	mov    edx,0x3
    23ab:	mov    rsi,QWORD PTR [rsp+0x18]
    23b0:	mov    rdi,r14
    23b3:	call   23b8 <botlish_fn_36+0x130>
			23b4: R_X86_64_PLT32	rt_value_eq-0x4
    23b8:	test   rax,rax
    23bb:	je     24d0 <botlish_fn_36+0x248>
    23c1:	jmp    23dc <botlish_fn_36+0x154>
    23c6:	mov    rsi,QWORD PTR [rsp+0x18]
    23cb:	mov    eax,0x2
    23d0:	cmp    rsi,0x3
    23d4:	cmove  rax,QWORD PTR [rip+0x184]        # 2560 <botlish_fn_36+0x2d8>
    23dc:	cmp    rax,0x6
    23e0:	je     23f0 <botlish_fn_36+0x168>
    23e6:	mov    ebx,0x2
    23eb:	jmp    24af <botlish_fn_36+0x227>
    23f0:	mov    rsi,r12
    23f3:	mov    rdi,r14
    23f6:	call   23fb <botlish_fn_36+0x173>
			23f7: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_keys<generic>
    23fb:	test   rax,rax
    23fe:	je     24d0 <botlish_fn_36+0x248>
    2404:	xor    r10d,r10d
    2407:	test   rax,0x7
    240d:	je     241b <botlish_fn_36+0x193>
    2413:	mov    rsi,rax
    2416:	jmp    242a <botlish_fn_36+0x1a2>
    241b:	movzx  rcx,BYTE PTR [rax]
    241f:	mov    rsi,rax
    2422:	rex cmp cl,0x8
    2426:	sete   r10b
    242a:	test   r10b,r10b
    242d:	jne    244d <botlish_fn_36+0x1c5>
    2433:	mov    rdi,r14
    2436:	mov    rax,QWORD PTR [rdi+0x10]
    243a:	mov    rcx,QWORD PTR [rax+0x20]
    243e:	mov    edx,0x8
    2443:	call   2448 <botlish_fn_36+0x1c0>
			2444: R_X86_64_PLT32	rt_type_error-0x4
    2448:	jmp    24d0 <botlish_fn_36+0x248>
    244d:	mov    rdx,r15
    2450:	mov    rdi,r14
    2453:	call   2458 <botlish_fn_36+0x1d0>
			2454: R_X86_64_PLT32	rt_mutarray_get-0x4
    2458:	test   rax,rax
    245b:	je     24d0 <botlish_fn_36+0x248>
    2461:	mov    rcx,rax
    2464:	and    rcx,r13
    2467:	mov    rsi,rax
    246a:	test   rcx,0x1
    2471:	jne    2490 <botlish_fn_36+0x208>
    2477:	mov    rdx,r13
    247a:	mov    rdi,r14
    247d:	call   2482 <botlish_fn_36+0x1fa>
			247e: R_X86_64_PLT32	rt_value_eq-0x4
    2482:	test   rax,rax
    2485:	je     24d0 <botlish_fn_36+0x248>
    248b:	jmp    24a0 <botlish_fn_36+0x218>
    2490:	mov    eax,0x2
    2495:	cmp    rsi,r13
    2498:	cmove  rax,QWORD PTR [rip+0xc0]        # 2560 <botlish_fn_36+0x2d8>
    24a0:	cmp    rax,0x6
    24a4:	je     24af <botlish_fn_36+0x227>
    24aa:	mov    ebx,0x2
    24af:	cmp    rbx,0x6
    24b3:	je     250b <botlish_fn_36+0x283>
    24b9:	mov    rdx,r15
    24bc:	mov    rsi,r12
    24bf:	mov    rdi,r14
    24c2:	call   24c7 <botlish_fn_36+0x23f>
			24c3: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_next<any, int>
    24c7:	test   rax,rax
    24ca:	jne    24f5 <botlish_fn_36+0x26d>
    24d0:	xor    rax,rax
    24d3:	mov    rbx,QWORD PTR [rsp+0x20]
    24d8:	mov    r12,QWORD PTR [rsp+0x28]
    24dd:	mov    r13,QWORD PTR [rsp+0x30]
    24e2:	mov    r14,QWORD PTR [rsp+0x38]
    24e7:	mov    r15,QWORD PTR [rsp+0x40]
    24ec:	add    rsp,0x50
    24f0:	mov    rsp,rbp
    24f3:	pop    rbp
    24f4:	ret
    24f5:	mov    QWORD PTR [rsp],r12
    24f9:	mov    QWORD PTR [rsp+0x8],r13
    24fe:	mov    QWORD PTR [rsp+0x10],rax
    2503:	mov    r15,rax
    2506:	jmp    22c3 <botlish_fn_36+0x3b>
    250b:	mov    rax,r15
    250e:	mov    rbx,QWORD PTR [rsp+0x20]
    2513:	mov    r12,QWORD PTR [rsp+0x28]
    2518:	mov    r13,QWORD PTR [rsp+0x30]
    251d:	mov    r14,QWORD PTR [rsp+0x38]
    2522:	mov    r15,QWORD PTR [rsp+0x40]
    2527:	add    rsp,0x50
    252b:	mov    rsp,rbp
    252e:	pop    rbp
    252f:	ret
    2530:	mov    rax,0xffffffffffffffff
    2537:	mov    rbx,QWORD PTR [rsp+0x20]
    253c:	mov    r12,QWORD PTR [rsp+0x28]
    2541:	mov    r13,QWORD PTR [rsp+0x30]
    2546:	mov    r14,QWORD PTR [rsp+0x38]
    254b:	mov    r15,QWORD PTR [rsp+0x40]
    2550:	add    rsp,0x50
    2554:	mov    rsp,rbp
    2557:	pop    rbp
    2558:	ret
    2559:	add    BYTE PTR [rax],al
    255b:	add    BYTE PTR [rax],al
    255d:	add    BYTE PTR [rax],al
    255f:	add    BYTE PTR [rsi],al
    2561:	add    BYTE PTR [rax],al
    2563:	add    BYTE PTR [rax],al
    2565:	add    BYTE PTR [rax],al
	...

0000000000002568 <botlish_entry_36: ht_find_get<any, str, int>>:
    2568:	push   rbp
    2569:	mov    rbp,rsp
    256c:	mov    rsi,QWORD PTR [rdx]
    256f:	mov    r8,QWORD PTR [rdx+0x8]
    2573:	mov    rcx,QWORD PTR [rdx+0x10]
    2577:	mov    rdx,r8
    257a:	call   257f <botlish_entry_36+0x17>
			257b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_find_get<any, str, int>
    257f:	mov    rsp,rbp
    2582:	pop    rbp
    2583:	ret
    2584:	add    BYTE PTR [rax],al
	...

0000000000002588 <botlish_fn_37: ht_find_insert<mutarray, any, int, int>>:
    2588:	push   rbp
    2589:	mov    rbp,rsp
    258c:	sub    rsp,0x60
    2590:	mov    QWORD PTR [rsp+0x30],rbx
    2595:	mov    QWORD PTR [rsp+0x38],r12
    259a:	mov    QWORD PTR [rsp+0x40],r13
    259f:	mov    QWORD PTR [rsp+0x48],r14
    25a4:	mov    QWORD PTR [rsp+0x50],r15
    25a9:	mov    r15,rdi
    25ac:	mov    QWORD PTR [rsp],rsi
    25b0:	mov    QWORD PTR [rsp+0x8],rdx
    25b5:	mov    r13,rdx
    25b8:	mov    QWORD PTR [rsp+0x10],rcx
    25bd:	mov    QWORD PTR [rsp+0x18],r8
    25c2:	mov    rbx,rsi
    25c5:	mov    QWORD PTR [rsp+0x20],rcx
    25ca:	mov    QWORD PTR [rsp+0x28],r8
    25cf:	mov    rsi,rbx
    25d2:	mov    rdi,r15
    25d5:	call   25da <botlish_fn_37+0x52>
			25d6: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    25da:	test   rax,rax
    25dd:	je     28d5 <botlish_fn_37+0x34d>
    25e3:	xor    ecx,ecx
    25e5:	test   rax,0x7
    25eb:	je     25f9 <botlish_fn_37+0x71>
    25f1:	mov    rsi,rax
    25f4:	jmp    2607 <botlish_fn_37+0x7f>
    25f9:	movzx  rcx,BYTE PTR [rax]
    25fd:	mov    rsi,rax
    2600:	rex cmp cl,0x8
    2604:	sete   cl
    2607:	test   cl,cl
    2609:	jne    2629 <botlish_fn_37+0xa1>
    260f:	mov    rdi,r15
    2612:	mov    rax,QWORD PTR [rdi+0x10]
    2616:	mov    rcx,QWORD PTR [rax+0x20]
    261a:	mov    edx,0x8
    261f:	call   2624 <botlish_fn_37+0x9c>
			2620: R_X86_64_PLT32	rt_type_error-0x4
    2624:	jmp    28d5 <botlish_fn_37+0x34d>
    2629:	mov    rdx,QWORD PTR [rsp+0x20]
    262e:	mov    rdi,r15
    2631:	call   2636 <botlish_fn_37+0xae>
			2632: R_X86_64_PLT32	rt_mutarray_get-0x4
    2636:	mov    rsi,rax
    2639:	mov    r14,rax
    263c:	test   rax,rsi
    263f:	je     28d5 <botlish_fn_37+0x34d>
    2645:	mov    rax,r14
    2648:	test   rax,0x1
    264e:	jne    2672 <botlish_fn_37+0xea>
    2654:	mov    edx,0x1
    2659:	mov    rsi,r14
    265c:	mov    rdi,r15
    265f:	call   2664 <botlish_fn_37+0xdc>
			2660: R_X86_64_PLT32	rt_value_eq-0x4
    2664:	test   rax,rax
    2667:	je     28d5 <botlish_fn_37+0x34d>
    266d:	jmp    2686 <botlish_fn_37+0xfe>
    2672:	mov    eax,0x2
    2677:	mov    rcx,r14
    267a:	cmp    rcx,0x1
    267e:	cmove  rax,QWORD PTR [rip+0x372]        # 29f8 <botlish_fn_37+0x470>
    2686:	mov    r12d,0x6
    268c:	cmp    rax,0x6
    2690:	je     294d <botlish_fn_37+0x3c5>
    2696:	mov    rax,r14
    2699:	test   rax,0x1
    269f:	jne    26c3 <botlish_fn_37+0x13b>
    26a5:	mov    edx,0x3
    26aa:	mov    rsi,r14
    26ad:	mov    rdi,r15
    26b0:	call   26b5 <botlish_fn_37+0x12d>
			26b1: R_X86_64_PLT32	rt_value_eq-0x4
    26b5:	test   rax,rax
    26b8:	je     28d5 <botlish_fn_37+0x34d>
    26be:	jmp    26d7 <botlish_fn_37+0x14f>
    26c3:	mov    eax,0x2
    26c8:	mov    rcx,r14
    26cb:	cmp    rcx,0x3
    26cf:	cmove  rax,QWORD PTR [rip+0x321]        # 29f8 <botlish_fn_37+0x470>
    26d7:	cmp    rax,0x6
    26db:	je     26ec <botlish_fn_37+0x164>
    26e1:	mov    r11d,0x2
    26e7:	jmp    27b6 <botlish_fn_37+0x22e>
    26ec:	mov    rsi,rbx
    26ef:	mov    rdi,r15
    26f2:	call   26f7 <botlish_fn_37+0x16f>
			26f3: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    26f7:	test   rax,rax
    26fa:	je     28d5 <botlish_fn_37+0x34d>
    2700:	xor    ecx,ecx
    2702:	test   rax,0x7
    2708:	je     2716 <botlish_fn_37+0x18e>
    270e:	mov    rsi,rax
    2711:	jmp    2724 <botlish_fn_37+0x19c>
    2716:	movzx  rcx,BYTE PTR [rax]
    271a:	mov    rsi,rax
    271d:	rex cmp cl,0x8
    2721:	sete   cl
    2724:	test   cl,cl
    2726:	jne    2746 <botlish_fn_37+0x1be>
    272c:	mov    rdi,r15
    272f:	mov    rcx,QWORD PTR [rdi+0x10]
    2733:	mov    rcx,QWORD PTR [rcx+0x20]
    2737:	mov    edx,0x8
    273c:	call   2741 <botlish_fn_37+0x1b9>
			273d: R_X86_64_PLT32	rt_type_error-0x4
    2741:	jmp    28d5 <botlish_fn_37+0x34d>
    2746:	mov    rdx,QWORD PTR [rsp+0x20]
    274b:	mov    rdi,r15
    274e:	call   2753 <botlish_fn_37+0x1cb>
			274f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2753:	test   rax,rax
    2756:	je     28d5 <botlish_fn_37+0x34d>
    275c:	mov    rsi,rax
    275f:	and    rsi,r13
    2762:	test   rsi,0x1
    2769:	jne    278b <botlish_fn_37+0x203>
    276f:	mov    rsi,rax
    2772:	mov    rdx,r13
    2775:	mov    rdi,r15
    2778:	call   277d <botlish_fn_37+0x1f5>
			2779: R_X86_64_PLT32	rt_value_eq-0x4
    277d:	test   rax,rax
    2780:	je     28d5 <botlish_fn_37+0x34d>
    2786:	jmp    279e <botlish_fn_37+0x216>
    278b:	mov    rsi,rax
    278e:	mov    eax,0x2
    2793:	cmp    rsi,r13
    2796:	cmove  rax,QWORD PTR [rip+0x25a]        # 29f8 <botlish_fn_37+0x470>
    279e:	cmp    rax,0x6
    27a2:	je     27b3 <botlish_fn_37+0x22b>
    27a8:	mov    r11d,0x2
    27ae:	jmp    27b6 <botlish_fn_37+0x22e>
    27b3:	mov    r11,r12
    27b6:	cmp    r11,0x6
    27ba:	je     2926 <botlish_fn_37+0x39e>
    27c0:	mov    rax,r14
    27c3:	test   rax,0x1
    27c9:	jne    27ed <botlish_fn_37+0x265>
    27cf:	mov    edx,0x5
    27d4:	mov    rsi,r14
    27d7:	mov    rdi,r15
    27da:	call   27df <botlish_fn_37+0x257>
			27db: R_X86_64_PLT32	rt_value_eq-0x4
    27df:	test   rax,rax
    27e2:	je     28d5 <botlish_fn_37+0x34d>
    27e8:	jmp    2801 <botlish_fn_37+0x279>
    27ed:	mov    rsi,r14
    27f0:	mov    eax,0x2
    27f5:	cmp    rsi,0x5
    27f9:	cmove  rax,QWORD PTR [rip+0x1f7]        # 29f8 <botlish_fn_37+0x470>
    2801:	cmp    rax,0x6
    2805:	je     2816 <botlish_fn_37+0x28e>
    280b:	mov    r12d,0x2
    2811:	jmp    2877 <botlish_fn_37+0x2ef>
    2816:	mov    r14,QWORD PTR [rsp+0x28]
    281b:	test   r14,0x1
    2822:	jne    2852 <botlish_fn_37+0x2ca>
    2828:	mov    edx,0x1
    282d:	mov    rsi,r14
    2830:	mov    rdi,r15
    2833:	call   2838 <botlish_fn_37+0x2b0>
			2834: R_X86_64_PLT32	rt_int_cmp-0x4
    2838:	mov    ecx,0x2
    283d:	test   rax,rax
    2840:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 29f8 <botlish_fn_37+0x470>
    2848:	mov    QWORD PTR [rsp+0x28],r14
    284d:	jmp    2867 <botlish_fn_37+0x2df>
    2852:	mov    ecx,0x2
    2857:	test   r14,r14
    285a:	mov    QWORD PTR [rsp+0x28],r14
    285f:	cmovle rcx,QWORD PTR [rip+0x191]        # 29f8 <botlish_fn_37+0x470>
    2867:	cmp    rcx,0x6
    286b:	je     2877 <botlish_fn_37+0x2ef>
    2871:	mov    r12d,0x2
    2877:	cmp    r12,0x6
    287b:	je     28bc <botlish_fn_37+0x334>
    2881:	mov    rdx,QWORD PTR [rsp+0x20]
    2886:	mov    rsi,rbx
    2889:	mov    rdi,r15
    288c:	call   2891 <botlish_fn_37+0x309>
			288d: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_probe_next<mutarray, int>
    2891:	test   rax,rax
    2894:	je     28d5 <botlish_fn_37+0x34d>
    289a:	mov    QWORD PTR [rsp],rbx
    289e:	mov    QWORD PTR [rsp+0x8],r13
    28a3:	mov    QWORD PTR [rsp+0x10],rax
    28a8:	mov    r11,QWORD PTR [rsp+0x28]
    28ad:	mov    QWORD PTR [rsp+0x18],r11
    28b2:	mov    QWORD PTR [rsp+0x20],rax
    28b7:	jmp    25cf <botlish_fn_37+0x47>
    28bc:	mov    rdx,QWORD PTR [rsp+0x20]
    28c1:	mov    rsi,rbx
    28c4:	mov    rdi,r15
    28c7:	call   28cc <botlish_fn_37+0x344>
			28c8: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_probe_next<mutarray, int>
    28cc:	test   rax,rax
    28cf:	jne    28fa <botlish_fn_37+0x372>
    28d5:	xor    rax,rax
    28d8:	mov    rbx,QWORD PTR [rsp+0x30]
    28dd:	mov    r12,QWORD PTR [rsp+0x38]
    28e2:	mov    r13,QWORD PTR [rsp+0x40]
    28e7:	mov    r14,QWORD PTR [rsp+0x48]
    28ec:	mov    r15,QWORD PTR [rsp+0x50]
    28f1:	add    rsp,0x60
    28f5:	mov    rsp,rbp
    28f8:	pop    rbp
    28f9:	ret
    28fa:	mov    QWORD PTR [rsp],rbx
    28fe:	mov    QWORD PTR [rsp+0x8],r13
    2903:	mov    QWORD PTR [rsp+0x10],rax
    2908:	mov    rdx,QWORD PTR [rsp+0x20]
    290d:	mov    QWORD PTR [rsp+0x18],rdx
    2912:	mov    rcx,QWORD PTR [rsp+0x20]
    2917:	mov    QWORD PTR [rsp+0x28],rcx
    291c:	mov    QWORD PTR [rsp+0x20],rax
    2921:	jmp    25cf <botlish_fn_37+0x47>
    2926:	mov    rax,QWORD PTR [rsp+0x20]
    292b:	mov    rbx,QWORD PTR [rsp+0x30]
    2930:	mov    r12,QWORD PTR [rsp+0x38]
    2935:	mov    r13,QWORD PTR [rsp+0x40]
    293a:	mov    r14,QWORD PTR [rsp+0x48]
    293f:	mov    r15,QWORD PTR [rsp+0x50]
    2944:	add    rsp,0x60
    2948:	mov    rsp,rbp
    294b:	pop    rbp
    294c:	ret
    294d:	mov    rax,QWORD PTR [rsp+0x28]
    2952:	test   rax,0x1
    2958:	jne    2985 <botlish_fn_37+0x3fd>
    295e:	mov    edx,0x1
    2963:	mov    rdi,r15
    2966:	mov    rsi,QWORD PTR [rsp+0x28]
    296b:	call   2970 <botlish_fn_37+0x3e8>
			296c: R_X86_64_PLT32	rt_int_cmp-0x4
    2970:	mov    ecx,0x2
    2975:	test   rax,rax
    2978:	cmovge rcx,QWORD PTR [rip+0x78]        # 29f8 <botlish_fn_37+0x470>
    2980:	jmp    299f <botlish_fn_37+0x417>
    2985:	mov    ecx,0x2
    298a:	mov    rax,QWORD PTR [rsp+0x28]
    298f:	mov    rdx,QWORD PTR [rsp+0x28]
    2994:	test   rax,rdx
    2997:	cmovg  rcx,QWORD PTR [rip+0x59]        # 29f8 <botlish_fn_37+0x470>
    299f:	cmp    rcx,0x6
    29a3:	je     29d0 <botlish_fn_37+0x448>
    29a9:	mov    rax,QWORD PTR [rsp+0x20]
    29ae:	mov    rbx,QWORD PTR [rsp+0x30]
    29b3:	mov    r12,QWORD PTR [rsp+0x38]
    29b8:	mov    r13,QWORD PTR [rsp+0x40]
    29bd:	mov    r14,QWORD PTR [rsp+0x48]
    29c2:	mov    r15,QWORD PTR [rsp+0x50]
    29c7:	add    rsp,0x60
    29cb:	mov    rsp,rbp
    29ce:	pop    rbp
    29cf:	ret
    29d0:	mov    rax,QWORD PTR [rsp+0x28]
    29d5:	mov    rbx,QWORD PTR [rsp+0x30]
    29da:	mov    r12,QWORD PTR [rsp+0x38]
    29df:	mov    r13,QWORD PTR [rsp+0x40]
    29e4:	mov    r14,QWORD PTR [rsp+0x48]
    29e9:	mov    r15,QWORD PTR [rsp+0x50]
    29ee:	add    rsp,0x60
    29f2:	mov    rsp,rbp
    29f5:	pop    rbp
    29f6:	ret
    29f7:	add    BYTE PTR [rsi],al
    29f9:	add    BYTE PTR [rax],al
    29fb:	add    BYTE PTR [rax],al
    29fd:	add    BYTE PTR [rax],al
	...

0000000000002a00 <botlish_entry_37: ht_find_insert<mutarray, any, int, int>>:
    2a00:	push   rbp
    2a01:	mov    rbp,rsp
    2a04:	mov    rsi,QWORD PTR [rdx]
    2a07:	mov    r9,QWORD PTR [rdx+0x8]
    2a0b:	mov    rcx,QWORD PTR [rdx+0x10]
    2a0f:	mov    r8,QWORD PTR [rdx+0x18]
    2a13:	mov    rdx,r9
    2a16:	call   2a1b <botlish_entry_37+0x1b>
			2a17: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    2a1b:	mov    rsp,rbp
    2a1e:	pop    rbp
    2a1f:	ret

0000000000002a20 <botlish_fn_38: ht_get<any, str>>:
    2a20:	push   rbp
    2a21:	mov    rbp,rsp
    2a24:	sub    rsp,0x40
    2a28:	mov    QWORD PTR [rsp+0x20],rbx
    2a2d:	mov    QWORD PTR [rsp+0x28],r12
    2a32:	mov    QWORD PTR [rsp+0x30],r13
    2a37:	mov    rbx,rdi
    2a3a:	mov    QWORD PTR [rsp],rsi
    2a3e:	mov    r13,rsi
    2a41:	mov    QWORD PTR [rsp+0x8],rdx
    2a46:	mov    r12,rdx
    2a49:	mov    rdx,r12
    2a4c:	mov    rsi,r13
    2a4f:	mov    rdi,rbx
    2a52:	call   2a57 <botlish_fn_38+0x37>
			2a53: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_probe_start<any, str>
    2a57:	test   rax,rax
    2a5a:	je     2b44 <botlish_fn_38+0x124>
    2a60:	mov    QWORD PTR [rsp+0x10],rax
    2a65:	mov    rcx,rax
    2a68:	mov    rdx,r12
    2a6b:	mov    rsi,r13
    2a6e:	mov    rdi,rbx
    2a71:	call   2a76 <botlish_fn_38+0x56>
			2a72: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_find_get<any, str, int>
    2a76:	mov    rcx,rax
    2a79:	mov    r12,rax
    2a7c:	test   rax,rcx
    2a7f:	je     2b44 <botlish_fn_38+0x124>
    2a85:	mov    rax,r12
    2a88:	test   rax,0x1
    2a8e:	jne    2ab9 <botlish_fn_38+0x99>
    2a94:	mov    edx,0x1
    2a99:	mov    rsi,r12
    2a9c:	mov    rdi,rbx
    2a9f:	call   2aa4 <botlish_fn_38+0x84>
			2aa0: R_X86_64_PLT32	rt_int_cmp-0x4
    2aa4:	mov    ecx,0x2
    2aa9:	test   rax,rax
    2aac:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 2b98 <botlish_fn_38+0x178>
    2ab4:	jmp    2acc <botlish_fn_38+0xac>
    2ab9:	mov    ecx,0x2
    2abe:	mov    rax,r12
    2ac1:	test   rax,rax
    2ac4:	cmovle rcx,QWORD PTR [rip+0xcc]        # 2b98 <botlish_fn_38+0x178>
    2acc:	cmp    rcx,0x6
    2ad0:	je     2b77 <botlish_fn_38+0x157>
    2ad6:	mov    rsi,r13
    2ad9:	mov    rdi,rbx
    2adc:	call   2ae1 <botlish_fn_38+0xc1>
			2add: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_values<generic>
    2ae1:	test   rax,rax
    2ae4:	je     2b44 <botlish_fn_38+0x124>
    2aea:	xor    ecx,ecx
    2aec:	test   rax,0x7
    2af2:	je     2b00 <botlish_fn_38+0xe0>
    2af8:	mov    rsi,rax
    2afb:	jmp    2b0e <botlish_fn_38+0xee>
    2b00:	movzx  rcx,BYTE PTR [rax]
    2b04:	mov    rsi,rax
    2b07:	rex cmp cl,0x8
    2b0b:	sete   cl
    2b0e:	test   cl,cl
    2b10:	jne    2b30 <botlish_fn_38+0x110>
    2b16:	mov    rdi,rbx
    2b19:	mov    rax,QWORD PTR [rdi+0x10]
    2b1d:	mov    rcx,QWORD PTR [rax+0x20]
    2b21:	mov    edx,0x8
    2b26:	call   2b2b <botlish_fn_38+0x10b>
			2b27: R_X86_64_PLT32	rt_type_error-0x4
    2b2b:	jmp    2b44 <botlish_fn_38+0x124>
    2b30:	mov    rdx,r12
    2b33:	mov    rdi,rbx
    2b36:	call   2b3b <botlish_fn_38+0x11b>
			2b37: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b3b:	test   rax,rax
    2b3e:	jne    2b5f <botlish_fn_38+0x13f>
    2b44:	xor    rax,rax
    2b47:	mov    rbx,QWORD PTR [rsp+0x20]
    2b4c:	mov    r12,QWORD PTR [rsp+0x28]
    2b51:	mov    r13,QWORD PTR [rsp+0x30]
    2b56:	add    rsp,0x40
    2b5a:	mov    rsp,rbp
    2b5d:	pop    rbp
    2b5e:	ret
    2b5f:	mov    rbx,QWORD PTR [rsp+0x20]
    2b64:	mov    r12,QWORD PTR [rsp+0x28]
    2b69:	mov    r13,QWORD PTR [rsp+0x30]
    2b6e:	add    rsp,0x40
    2b72:	mov    rsp,rbp
    2b75:	pop    rbp
    2b76:	ret
    2b77:	mov    eax,0xa
    2b7c:	mov    rbx,QWORD PTR [rsp+0x20]
    2b81:	mov    r12,QWORD PTR [rsp+0x28]
    2b86:	mov    r13,QWORD PTR [rsp+0x30]
    2b8b:	add    rsp,0x40
    2b8f:	mov    rsp,rbp
    2b92:	pop    rbp
    2b93:	ret
    2b94:	add    BYTE PTR [rax],al
    2b96:	add    BYTE PTR [rax],al
    2b98:	(bad)
    2b99:	add    BYTE PTR [rax],al
    2b9b:	add    BYTE PTR [rax],al
    2b9d:	add    BYTE PTR [rax],al
	...

0000000000002ba0 <botlish_entry_38: ht_get<any, str>>:
    2ba0:	push   rbp
    2ba1:	mov    rbp,rsp
    2ba4:	mov    rsi,QWORD PTR [rdx]
    2ba7:	mov    rdx,QWORD PTR [rdx+0x8]
    2bab:	call   2bb0 <botlish_entry_38+0x10>
			2bac: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    2bb0:	mov    rsp,rbp
    2bb3:	pop    rbp
    2bb4:	ret
    2bb5:	add    BYTE PTR [rax],al
	...

0000000000002bb8 <botlish_fn_39: ht_rehash_probe<mutarray, int, int>>:
    2bb8:	push   rbp
    2bb9:	mov    rbp,rsp
    2bbc:	sub    rsp,0x40
    2bc0:	mov    QWORD PTR [rsp+0x20],rbx
    2bc5:	mov    QWORD PTR [rsp+0x28],r12
    2bca:	mov    QWORD PTR [rsp+0x30],r13
    2bcf:	mov    QWORD PTR [rsp+0x38],r14
    2bd4:	mov    r13,rdi
    2bd7:	mov    QWORD PTR [rsp],rsi
    2bdb:	mov    QWORD PTR [rsp+0x8],rdx
    2be0:	mov    QWORD PTR [rsp+0x10],rcx
    2be5:	mov    r12,rcx
    2be8:	mov    rbx,rsi
    2beb:	mov    r14,rdx
    2bee:	mov    rdx,r14
    2bf1:	mov    rsi,rbx
    2bf4:	mov    rdi,r13
    2bf7:	call   2bfc <botlish_fn_39+0x44>
			2bf8: R_X86_64_PLT32	rt_mutarray_get-0x4
    2bfc:	test   rax,rax
    2bff:	je     2c9c <botlish_fn_39+0xe4>
    2c05:	test   rax,0x1
    2c0b:	mov    rsi,rax
    2c0e:	jne    2c2f <botlish_fn_39+0x77>
    2c14:	mov    edx,0x1
    2c19:	mov    rdi,r13
    2c1c:	call   2c21 <botlish_fn_39+0x69>
			2c1d: R_X86_64_PLT32	rt_value_eq-0x4
    2c21:	test   rax,rax
    2c24:	je     2c9c <botlish_fn_39+0xe4>
    2c2a:	jmp    2c40 <botlish_fn_39+0x88>
    2c2f:	mov    eax,0x2
    2c34:	cmp    rsi,0x1
    2c38:	cmove  rax,QWORD PTR [rip+0xb8]        # 2cf8 <botlish_fn_39+0x140>
    2c40:	cmp    rax,0x6
    2c44:	je     2cd2 <botlish_fn_39+0x11a>
    2c4a:	mov    QWORD PTR [rsp+0x18],0x3
    2c53:	mov    rsi,r14
    2c56:	test   rsi,0x1
    2c5d:	je     2c75 <botlish_fn_39+0xbd>
    2c63:	mov    rsi,r14
    2c66:	add    rsi,0x2
    2c6a:	seto   al
    2c6d:	test   al,al
    2c6f:	je     2c88 <botlish_fn_39+0xd0>
    2c75:	mov    edx,0x3
    2c7a:	mov    rsi,r14
    2c7d:	mov    rdi,r13
    2c80:	call   2c85 <botlish_fn_39+0xcd>
			2c81: R_X86_64_PLT32	rt_int_add-0x4
    2c85:	mov    rsi,rax
    2c88:	mov    rdx,r12
    2c8b:	mov    rdi,r13
    2c8e:	call   2c93 <botlish_fn_39+0xdb>
			2c8f: R_X86_64_PLT32	rt_int_mod-0x4
    2c93:	test   rax,rax
    2c96:	jne    2cbc <botlish_fn_39+0x104>
    2c9c:	xor    rax,rax
    2c9f:	mov    rbx,QWORD PTR [rsp+0x20]
    2ca4:	mov    r12,QWORD PTR [rsp+0x28]
    2ca9:	mov    r13,QWORD PTR [rsp+0x30]
    2cae:	mov    r14,QWORD PTR [rsp+0x38]
    2cb3:	add    rsp,0x40
    2cb7:	mov    rsp,rbp
    2cba:	pop    rbp
    2cbb:	ret
    2cbc:	mov    QWORD PTR [rsp],rbx
    2cc0:	mov    QWORD PTR [rsp+0x8],rax
    2cc5:	mov    QWORD PTR [rsp+0x10],r12
    2cca:	mov    r14,rax
    2ccd:	jmp    2bee <botlish_fn_39+0x36>
    2cd2:	mov    rax,r14
    2cd5:	mov    rbx,QWORD PTR [rsp+0x20]
    2cda:	mov    r12,QWORD PTR [rsp+0x28]
    2cdf:	mov    r13,QWORD PTR [rsp+0x30]
    2ce4:	mov    r14,QWORD PTR [rsp+0x38]
    2ce9:	add    rsp,0x40
    2ced:	mov    rsp,rbp
    2cf0:	pop    rbp
    2cf1:	ret
    2cf2:	add    BYTE PTR [rax],al
    2cf4:	add    BYTE PTR [rax],al
    2cf6:	add    BYTE PTR [rax],al
    2cf8:	(bad)
    2cf9:	add    BYTE PTR [rax],al
    2cfb:	add    BYTE PTR [rax],al
    2cfd:	add    BYTE PTR [rax],al
	...

0000000000002d00 <botlish_entry_39: ht_rehash_probe<mutarray, int, int>>:
    2d00:	push   rbp
    2d01:	mov    rbp,rsp
    2d04:	mov    rsi,QWORD PTR [rdx]
    2d07:	mov    r8,QWORD PTR [rdx+0x8]
    2d0b:	mov    rcx,QWORD PTR [rdx+0x10]
    2d0f:	mov    rdx,r8
    2d12:	call   2d17 <botlish_entry_39+0x17>
			2d13: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_rehash_probe<mutarray, int, int>
    2d17:	mov    rsp,rbp
    2d1a:	pop    rbp
    2d1b:	ret

0000000000002d1c <botlish_fn_40: ht_rehash_insert<List[mutarray], int, any, any>>:
    2d1c:	push   rbp
    2d1d:	mov    rbp,rsp
    2d20:	sub    rsp,0x80
    2d27:	mov    QWORD PTR [rsp+0x50],rbx
    2d2c:	mov    QWORD PTR [rsp+0x58],r12
    2d31:	mov    QWORD PTR [rsp+0x60],r13
    2d36:	mov    QWORD PTR [rsp+0x68],r14
    2d3b:	mov    QWORD PTR [rsp+0x70],r15
    2d40:	mov    r12,rdi
    2d43:	mov    rdi,QWORD PTR [rbp+0x10]
    2d47:	mov    QWORD PTR [rsp],rsi
    2d4b:	mov    QWORD PTR [rsp+0x38],rsi
    2d50:	mov    QWORD PTR [rsp+0x8],rdx
    2d55:	mov    r15,rdx
    2d58:	mov    QWORD PTR [rsp+0x10],rcx
    2d5d:	mov    rbx,rcx
    2d60:	mov    QWORD PTR [rsp+0x18],r8
    2d65:	mov    QWORD PTR [rsp+0x40],r8
    2d6a:	mov    QWORD PTR [rsp+0x20],r9
    2d6f:	mov    r14,r9
    2d72:	mov    QWORD PTR [rsp+0x28],rdi
    2d77:	mov    r13,rdi
    2d7a:	mov    rsi,r14
    2d7d:	mov    rdi,r12
    2d80:	call   2d85 <botlish_fn_40+0x69>
			2d81: R_X86_64_PLT32	rt_hash-0x4
    2d85:	test   rax,rax
    2d88:	mov    rsi,rax
    2d8b:	je     2e2a <botlish_fn_40+0x10e>
    2d91:	mov    rdx,QWORD PTR [rsp+0x40]
    2d96:	mov    rdi,r12
    2d99:	call   2d9e <botlish_fn_40+0x82>
			2d9a: R_X86_64_PLT32	rt_int_mod-0x4
    2d9e:	test   rax,rax
    2da1:	je     2e2a <botlish_fn_40+0x10e>
    2da7:	mov    QWORD PTR [rsp+0x30],rax
    2dac:	mov    rcx,QWORD PTR [rsp+0x40]
    2db1:	mov    rdx,rax
    2db4:	mov    rsi,QWORD PTR [rsp+0x38]
    2db9:	mov    rdi,r12
    2dbc:	call   2dc1 <botlish_fn_40+0xa5>
			2dbd: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_rehash_probe<mutarray, int, int>
    2dc1:	mov    rcx,rax
    2dc4:	mov    QWORD PTR [rsp+0x40],rax
    2dc9:	test   rax,rcx
    2dcc:	je     2e2a <botlish_fn_40+0x10e>
    2dd2:	mov    ecx,0x3
    2dd7:	mov    rsi,QWORD PTR [rsp+0x38]
    2ddc:	mov    rdx,QWORD PTR [rsp+0x40]
    2de1:	mov    rdi,r12
    2de4:	call   2de9 <botlish_fn_40+0xcd>
			2de5: R_X86_64_PLT32	rt_mutarray_set-0x4
    2de9:	test   rax,rax
    2dec:	je     2e2a <botlish_fn_40+0x10e>
    2df2:	mov    rcx,r14
    2df5:	mov    rsi,r15
    2df8:	mov    rdx,QWORD PTR [rsp+0x40]
    2dfd:	mov    rdi,r12
    2e00:	call   2e05 <botlish_fn_40+0xe9>
			2e01: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e05:	test   rax,rax
    2e08:	je     2e2a <botlish_fn_40+0x10e>
    2e0e:	mov    rcx,r13
    2e11:	mov    rdx,QWORD PTR [rsp+0x40]
    2e16:	mov    rsi,rbx
    2e19:	mov    rdi,r12
    2e1c:	call   2e21 <botlish_fn_40+0x105>
			2e1d: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e21:	test   rax,rax
    2e24:	jne    2e52 <botlish_fn_40+0x136>
    2e2a:	xor    rax,rax
    2e2d:	mov    rbx,QWORD PTR [rsp+0x50]
    2e32:	mov    r12,QWORD PTR [rsp+0x58]
    2e37:	mov    r13,QWORD PTR [rsp+0x60]
    2e3c:	mov    r14,QWORD PTR [rsp+0x68]
    2e41:	mov    r15,QWORD PTR [rsp+0x70]
    2e46:	add    rsp,0x80
    2e4d:	mov    rsp,rbp
    2e50:	pop    rbp
    2e51:	ret
    2e52:	mov    eax,0xa
    2e57:	mov    rbx,QWORD PTR [rsp+0x50]
    2e5c:	mov    r12,QWORD PTR [rsp+0x58]
    2e61:	mov    r13,QWORD PTR [rsp+0x60]
    2e66:	mov    r14,QWORD PTR [rsp+0x68]
    2e6b:	mov    r15,QWORD PTR [rsp+0x70]
    2e70:	add    rsp,0x80
    2e77:	mov    rsp,rbp
    2e7a:	pop    rbp
    2e7b:	ret

0000000000002e7c <botlish_entry_40: ht_rehash_insert<List[mutarray], int, any, any>>:
    2e7c:	push   rbp
    2e7d:	mov    rbp,rsp
    2e80:	sub    rsp,0x10
    2e84:	mov    rsi,QWORD PTR [rdx]
    2e87:	mov    r10,QWORD PTR [rdx+0x8]
    2e8b:	mov    rcx,QWORD PTR [rdx+0x10]
    2e8f:	mov    r8,QWORD PTR [rdx+0x18]
    2e93:	mov    r9,QWORD PTR [rdx+0x20]
    2e97:	mov    r11,QWORD PTR [rdx+0x28]
    2e9b:	mov    QWORD PTR [rsp],r11
    2e9f:	mov    rdx,r10
    2ea2:	call   2ea7 <botlish_entry_40+0x2b>
			2ea3: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_insert<List[mutarray], int, any, any>
    2ea7:	add    rsp,0x10
    2eab:	mov    rsp,rbp
    2eae:	pop    rbp
    2eaf:	ret

0000000000002eb0 <botlish_fn_41: ht_rehash_scan<list, int, int, List[mutarray], int>>:
    2eb0:	push   rbp
    2eb1:	mov    rbp,rsp
    2eb4:	sub    rsp,0xc0
    2ebb:	mov    QWORD PTR [rsp+0x90],rbx
    2ec3:	mov    QWORD PTR [rsp+0x98],r12
    2ecb:	mov    QWORD PTR [rsp+0xa0],r13
    2ed3:	mov    QWORD PTR [rsp+0xa8],r14
    2edb:	mov    QWORD PTR [rsp+0xb0],r15
    2ee3:	mov    QWORD PTR [rsp+0x60],rdi
    2ee8:	mov    QWORD PTR [rsp+0x80],r9
    2ef0:	mov    r12,QWORD PTR [rbp+0x10]
    2ef4:	mov    r13,QWORD PTR [rbp+0x18]
    2ef8:	mov    r14,QWORD PTR [rbp+0x20]
    2efc:	mov    rdi,QWORD PTR [rbp+0x28]
    2f00:	mov    QWORD PTR [rsp+0x10],rsi
    2f05:	mov    QWORD PTR [rsp+0x68],rsi
    2f0a:	mov    QWORD PTR [rsp+0x18],rdx
    2f0f:	mov    QWORD PTR [rsp+0x70],rdx
    2f14:	mov    QWORD PTR [rsp+0x20],rcx
    2f19:	mov    QWORD PTR [rsp+0x78],rcx
    2f1e:	mov    QWORD PTR [rsp+0x28],r8
    2f23:	mov    rax,r12
    2f26:	mov    QWORD PTR [rsp+0x30],rax
    2f2b:	mov    QWORD PTR [rsp+0x38],r13
    2f30:	mov    QWORD PTR [rsp+0x40],r14
    2f35:	mov    QWORD PTR [rsp+0x48],rdi
    2f3a:	mov    QWORD PTR [rsp+0x88],rdi
    2f42:	mov    rsi,QWORD PTR [rsp+0x80]
    2f4a:	mov    rax,rsi
    2f4d:	or     rax,0x1
    2f51:	mov    r15,r8
    2f54:	mov    rcx,r15
    2f57:	and    rcx,rax
    2f5a:	test   rcx,0x1
    2f61:	jne    2f98 <botlish_fn_41+0xe8>
    2f67:	mov    rdx,rsi
    2f6a:	or     rdx,0x1
    2f6e:	mov    QWORD PTR [rsp+0x80],rsi
    2f76:	mov    rsi,r15
    2f79:	mov    rdi,QWORD PTR [rsp+0x60]
    2f7e:	call   2f83 <botlish_fn_41+0xd3>
			2f7f: R_X86_64_PLT32	rt_int_cmp-0x4
    2f83:	mov    ecx,0x2
    2f88:	test   rax,rax
    2f8b:	cmovge rcx,QWORD PTR [rip+0x2dd]        # 3270 <botlish_fn_41+0x3c0>
    2f93:	jmp    2fba <botlish_fn_41+0x10a>
    2f98:	mov    rdi,rsi
    2f9b:	mov    QWORD PTR [rsp+0x80],rsi
    2fa3:	mov    rax,rdi
    2fa6:	or     rax,0x1
    2faa:	mov    ecx,0x2
    2faf:	cmp    r15,rax
    2fb2:	cmovge rcx,QWORD PTR [rip+0x2b6]        # 3270 <botlish_fn_41+0x3c0>
    2fba:	cmp    rcx,0x6
    2fbe:	je     3230 <botlish_fn_41+0x380>
    2fc4:	xor    eax,eax
    2fc6:	mov    rsi,QWORD PTR [rsp+0x68]
    2fcb:	test   rsi,0x7
    2fd2:	jne    2fe1 <botlish_fn_41+0x131>
    2fd8:	movzx  rax,BYTE PTR [rsi]
    2fdc:	cmp    al,0x8
    2fde:	sete   al
    2fe1:	test   al,al
    2fe3:	jne    3005 <botlish_fn_41+0x155>
    2fe9:	mov    rdi,QWORD PTR [rsp+0x60]
    2fee:	mov    rax,QWORD PTR [rdi+0x10]
    2ff2:	mov    rcx,QWORD PTR [rax+0x20]
    2ff6:	mov    edx,0x8
    2ffb:	call   3000 <botlish_fn_41+0x150>
			2ffc: R_X86_64_PLT32	rt_type_error-0x4
    3000:	jmp    3194 <botlish_fn_41+0x2e4>
    3005:	mov    QWORD PTR [rsp+0x68],rsi
    300a:	mov    rdx,r15
    300d:	mov    rdi,QWORD PTR [rsp+0x60]
    3012:	call   3017 <botlish_fn_41+0x167>
			3013: R_X86_64_PLT32	rt_mutarray_get-0x4
    3017:	test   rax,rax
    301a:	je     3194 <botlish_fn_41+0x2e4>
    3020:	test   rax,0x1
    3026:	mov    rsi,rax
    3029:	jne    304c <botlish_fn_41+0x19c>
    302f:	mov    edx,0x3
    3034:	mov    rdi,QWORD PTR [rsp+0x60]
    3039:	call   303e <botlish_fn_41+0x18e>
			303a: R_X86_64_PLT32	rt_value_eq-0x4
    303e:	test   rax,rax
    3041:	je     3194 <botlish_fn_41+0x2e4>
    3047:	jmp    305d <botlish_fn_41+0x1ad>
    304c:	mov    eax,0x2
    3051:	cmp    rsi,0x3
    3055:	cmove  rax,QWORD PTR [rip+0x213]        # 3270 <botlish_fn_41+0x3c0>
    305d:	cmp    rax,0x6
    3061:	je     3079 <botlish_fn_41+0x1c9>
    3067:	mov    rbx,QWORD PTR [rsp+0x88]
    306f:	mov    rsi,QWORD PTR [rsp+0x68]
    3074:	jmp    31d0 <botlish_fn_41+0x320>
    3079:	xor    eax,eax
    307b:	mov    rdx,QWORD PTR [rsp+0x70]
    3080:	test   rdx,0x7
    3087:	je     3097 <botlish_fn_41+0x1e7>
    308d:	mov    QWORD PTR [rsp+0x70],rdx
    3092:	jmp    30a5 <botlish_fn_41+0x1f5>
    3097:	movzx  rax,BYTE PTR [rdx]
    309b:	mov    QWORD PTR [rsp+0x70],rdx
    30a0:	cmp    al,0x8
    30a2:	sete   al
    30a5:	test   al,al
    30a7:	jne    30ce <botlish_fn_41+0x21e>
    30ad:	mov    rdi,QWORD PTR [rsp+0x60]
    30b2:	mov    rax,QWORD PTR [rdi+0x10]
    30b6:	mov    rcx,QWORD PTR [rax+0x20]
    30ba:	mov    edx,0x8
    30bf:	mov    rsi,QWORD PTR [rsp+0x70]
    30c4:	call   30c9 <botlish_fn_41+0x219>
			30c5: R_X86_64_PLT32	rt_type_error-0x4
    30c9:	jmp    3194 <botlish_fn_41+0x2e4>
    30ce:	mov    rdx,r15
    30d1:	mov    rsi,QWORD PTR [rsp+0x70]
    30d6:	mov    rdi,QWORD PTR [rsp+0x60]
    30db:	call   30e0 <botlish_fn_41+0x230>
			30dc: R_X86_64_PLT32	rt_mutarray_get-0x4
    30e0:	test   rax,rax
    30e3:	je     3194 <botlish_fn_41+0x2e4>
    30e9:	mov    QWORD PTR [rsp+0x50],rax
    30ee:	mov    rbx,rax
    30f1:	xor    eax,eax
    30f3:	mov    rcx,QWORD PTR [rsp+0x78]
    30f8:	test   rcx,0x7
    30ff:	je     310f <botlish_fn_41+0x25f>
    3105:	mov    QWORD PTR [rsp+0x78],rcx
    310a:	jmp    311d <botlish_fn_41+0x26d>
    310f:	movzx  rax,BYTE PTR [rcx]
    3113:	mov    QWORD PTR [rsp+0x78],rcx
    3118:	cmp    al,0x8
    311a:	sete   al
    311d:	test   al,al
    311f:	jne    3146 <botlish_fn_41+0x296>
    3125:	mov    rdi,QWORD PTR [rsp+0x60]
    312a:	mov    rcx,QWORD PTR [rdi+0x10]
    312e:	mov    rcx,QWORD PTR [rcx+0x20]
    3132:	mov    edx,0x8
    3137:	mov    rsi,QWORD PTR [rsp+0x78]
    313c:	call   3141 <botlish_fn_41+0x291>
			313d: R_X86_64_PLT32	rt_type_error-0x4
    3141:	jmp    3194 <botlish_fn_41+0x2e4>
    3146:	mov    rdx,r15
    3149:	mov    rsi,QWORD PTR [rsp+0x78]
    314e:	mov    rdi,QWORD PTR [rsp+0x60]
    3153:	call   3158 <botlish_fn_41+0x2a8>
			3154: R_X86_64_PLT32	rt_mutarray_get-0x4
    3158:	test   rax,rax
    315b:	je     3194 <botlish_fn_41+0x2e4>
    3161:	mov    QWORD PTR [rsp+0x58],rax
    3166:	mov    QWORD PTR [rsp],rax
    316a:	mov    r9,rbx
    316d:	mov    rbx,QWORD PTR [rsp+0x88]
    3175:	mov    rcx,r14
    3178:	mov    rdx,r13
    317b:	mov    rsi,r12
    317e:	mov    rdi,QWORD PTR [rsp+0x60]
    3183:	mov    r8,rbx
    3186:	call   318b <botlish_fn_41+0x2db>
			3187: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_insert<List[mutarray], int, any, any>
    318b:	test   rax,rax
    318e:	jne    31cb <botlish_fn_41+0x31b>
    3194:	xor    rax,rax
    3197:	mov    rbx,QWORD PTR [rsp+0x90]
    319f:	mov    r12,QWORD PTR [rsp+0x98]
    31a7:	mov    r13,QWORD PTR [rsp+0xa0]
    31af:	mov    r14,QWORD PTR [rsp+0xa8]
    31b7:	mov    r15,QWORD PTR [rsp+0xb0]
    31bf:	add    rsp,0xc0
    31c6:	mov    rsp,rbp
    31c9:	pop    rbp
    31ca:	ret
    31cb:	mov    rsi,QWORD PTR [rsp+0x68]
    31d0:	mov    rsi,QWORD PTR [rsp+0x68]
    31d5:	mov    QWORD PTR [rsp+0x10],rsi
    31da:	mov    rsi,QWORD PTR [rsp+0x70]
    31df:	mov    QWORD PTR [rsp+0x18],rsi
    31e4:	mov    rsi,QWORD PTR [rsp+0x78]
    31e9:	mov    QWORD PTR [rsp+0x20],rsi
    31ee:	sar    r15,1
    31f1:	add    r15,0x1
    31f8:	shl    r15,1
    31fb:	or     r15,0x1
    31ff:	mov    QWORD PTR [rsp+0x28],r15
    3204:	mov    QWORD PTR [rsp+0x30],r12
    3209:	mov    QWORD PTR [rsp+0x38],r13
    320e:	mov    QWORD PTR [rsp+0x40],r14
    3213:	mov    QWORD PTR [rsp+0x48],rbx
    3218:	mov    rsi,QWORD PTR [rsp+0x80]
    3220:	mov    r8,r15
    3223:	mov    QWORD PTR [rsp+0x88],rbx
    322b:	jmp    2f4a <botlish_fn_41+0x9a>
    3230:	mov    eax,0xa
    3235:	mov    rbx,QWORD PTR [rsp+0x90]
    323d:	mov    r12,QWORD PTR [rsp+0x98]
    3245:	mov    r13,QWORD PTR [rsp+0xa0]
    324d:	mov    r14,QWORD PTR [rsp+0xa8]
    3255:	mov    r15,QWORD PTR [rsp+0xb0]
    325d:	add    rsp,0xc0
    3264:	mov    rsp,rbp
    3267:	pop    rbp
    3268:	ret
    3269:	add    BYTE PTR [rax],al
    326b:	add    BYTE PTR [rax],al
    326d:	add    BYTE PTR [rax],al
    326f:	add    BYTE PTR [rsi],al
    3271:	add    BYTE PTR [rax],al
    3273:	add    BYTE PTR [rax],al
    3275:	add    BYTE PTR [rax],al
	...

0000000000003278 <botlish_entry_41: ht_rehash_scan<list, int, int, List[mutarray], int>>:
    3278:	push   rbp
    3279:	mov    rbp,rsp
    327c:	sub    rsp,0x30
    3280:	mov    QWORD PTR [rsp+0x20],r12
    3285:	mov    rsi,QWORD PTR [rdx]
    3288:	mov    rax,QWORD PTR [rdx+0x8]
    328c:	mov    rcx,QWORD PTR [rdx+0x10]
    3290:	mov    r8,QWORD PTR [rdx+0x18]
    3294:	mov    r9,QWORD PTR [rdx+0x20]
    3298:	mov    r10,QWORD PTR [rdx+0x28]
    329c:	mov    r11,QWORD PTR [rdx+0x30]
    32a0:	mov    r12,QWORD PTR [rdx+0x38]
    32a4:	mov    rdx,QWORD PTR [rdx+0x40]
    32a8:	mov    QWORD PTR [rsp],r10
    32ac:	mov    QWORD PTR [rsp+0x8],r11
    32b1:	mov    QWORD PTR [rsp+0x10],r12
    32b6:	mov    QWORD PTR [rsp+0x18],rdx
    32bb:	mov    rdx,rax
    32be:	call   32c3 <botlish_entry_41+0x4b>
			32bf: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    32c3:	mov    r12,QWORD PTR [rsp+0x20]
    32c8:	add    rsp,0x30
    32cc:	mov    rsp,rbp
    32cf:	pop    rbp
    32d0:	ret

00000000000032d1 <botlish_fn_42: ht_rehash<mutarray, int>>:
    32d1:	push   rbp
    32d2:	mov    rbp,rsp
    32d5:	sub    rsp,0xd0
    32dc:	mov    QWORD PTR [rsp+0xa0],rbx
    32e4:	mov    QWORD PTR [rsp+0xa8],r12
    32ec:	mov    QWORD PTR [rsp+0xb0],r13
    32f4:	mov    QWORD PTR [rsp+0xb8],r14
    32fc:	mov    QWORD PTR [rsp+0xc0],r15
    3304:	mov    r13,rdi
    3307:	mov    QWORD PTR [rsp+0x50],0x0
    3310:	mov    QWORD PTR [rsp+0x58],0x0
    3319:	mov    QWORD PTR [rsp+0x60],0x0
    3322:	mov    QWORD PTR [rsp+0x68],0x0
    332b:	mov    QWORD PTR [rsp+0x20],rsi
    3330:	mov    r12,rsi
    3333:	mov    QWORD PTR [rsp+0x28],rdx
    3338:	mov    rbx,rdx
    333b:	mov    rsi,r12
    333e:	mov    rdi,r13
    3341:	call   3346 <botlish_fn_42+0x75>
			3342: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    3346:	test   rax,rax
    3349:	je     3518 <botlish_fn_42+0x247>
    334f:	mov    QWORD PTR [rsp+0x30],rax
    3354:	mov    r14,rax
    3357:	mov    rsi,r12
    335a:	mov    rdi,r13
    335d:	call   3362 <botlish_fn_42+0x91>
			335e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    3362:	test   rax,rax
    3365:	je     3518 <botlish_fn_42+0x247>
    336b:	mov    QWORD PTR [rsp+0x38],rax
    3370:	mov    r15,rax
    3373:	mov    rsi,r12
    3376:	mov    rdi,r13
    3379:	call   337e <botlish_fn_42+0xad>
			337a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    337e:	test   rax,rax
    3381:	je     3518 <botlish_fn_42+0x247>
    3387:	mov    QWORD PTR [rsp+0x40],rax
    338c:	mov    QWORD PTR [rsp+0x90],rax
    3394:	mov    rsi,r12
    3397:	mov    rdi,r13
    339a:	call   339f <botlish_fn_42+0xce>
			339b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    339f:	test   rax,rax
    33a2:	je     3518 <botlish_fn_42+0x247>
    33a8:	mov    QWORD PTR [rsp+0x48],rax
    33ad:	mov    QWORD PTR [rsp+0x88],rax
    33b5:	mov    rsi,rbx
    33b8:	mov    rdi,r13
    33bb:	call   33c0 <botlish_fn_42+0xef>
			33bc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    33c0:	mov    rcx,rax
    33c3:	mov    QWORD PTR [rsp+0x80],rax
    33cb:	test   rax,rcx
    33ce:	je     3518 <botlish_fn_42+0x247>
    33d4:	mov    rax,QWORD PTR [rsp+0x80]
    33dc:	mov    QWORD PTR [rsp+0x50],rax
    33e1:	mov    edx,0x1
    33e6:	mov    QWORD PTR [rsp+0x58],0x1
    33ef:	mov    rcx,rbx
    33f2:	mov    rsi,QWORD PTR [rsp+0x80]
    33fa:	mov    rdi,r13
    33fd:	call   3402 <botlish_fn_42+0x131>
			33fe: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_fill_empty<mutarray, int, int>
    3402:	test   rax,rax
    3405:	je     3518 <botlish_fn_42+0x247>
    340b:	mov    rsi,rbx
    340e:	mov    rdi,r13
    3411:	call   3416 <botlish_fn_42+0x145>
			3412: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3416:	test   rax,rax
    3419:	je     3518 <botlish_fn_42+0x247>
    341f:	mov    QWORD PTR [rsp+0x58],rax
    3424:	mov    QWORD PTR [rsp+0x78],rax
    3429:	mov    rsi,rbx
    342c:	mov    rdi,r13
    342f:	call   3434 <botlish_fn_42+0x163>
			3430: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3434:	test   rax,rax
    3437:	je     3518 <botlish_fn_42+0x247>
    343d:	mov    QWORD PTR [rsp+0x60],rax
    3442:	mov    r8d,0x1
    3448:	mov    QWORD PTR [rsp+0x68],0x1
    3451:	mov    rcx,QWORD PTR [rsp+0x80]
    3459:	mov    QWORD PTR [rsp],rcx
    345d:	mov    rcx,QWORD PTR [rsp+0x78]
    3462:	mov    QWORD PTR [rsp+0x8],rcx
    3467:	mov    QWORD PTR [rsp+0x10],rax
    346c:	mov    QWORD PTR [rsp+0x70],rax
    3471:	mov    QWORD PTR [rsp+0x18],rbx
    3476:	mov    rcx,QWORD PTR [rsp+0x90]
    347e:	mov    rdx,r15
    3481:	mov    rsi,r14
    3484:	mov    r9,QWORD PTR [rsp+0x88]
    348c:	mov    rdi,r13
    348f:	call   3494 <botlish_fn_42+0x1c3>
			3490: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    3494:	test   rax,rax
    3497:	je     3518 <botlish_fn_42+0x247>
    349d:	mov    edx,0x1
    34a2:	mov    rcx,QWORD PTR [rsp+0x80]
    34aa:	mov    rsi,r12
    34ad:	mov    rdi,r13
    34b0:	call   34b5 <botlish_fn_42+0x1e4>
			34b1: R_X86_64_PLT32	rt_mutarray_set-0x4
    34b5:	test   rax,rax
    34b8:	je     3518 <botlish_fn_42+0x247>
    34be:	mov    edx,0x3
    34c3:	mov    rcx,QWORD PTR [rsp+0x78]
    34c8:	mov    rsi,r12
    34cb:	mov    rdi,r13
    34ce:	call   34d3 <botlish_fn_42+0x202>
			34cf: R_X86_64_PLT32	rt_mutarray_set-0x4
    34d3:	test   rax,rax
    34d6:	je     3518 <botlish_fn_42+0x247>
    34dc:	mov    edx,0x5
    34e1:	mov    rcx,QWORD PTR [rsp+0x70]
    34e6:	mov    rsi,r12
    34e9:	mov    rdi,r13
    34ec:	call   34f1 <botlish_fn_42+0x220>
			34ed: R_X86_64_PLT32	rt_mutarray_set-0x4
    34f1:	test   rax,rax
    34f4:	je     3518 <botlish_fn_42+0x247>
    34fa:	mov    edx,0x9
    34ff:	mov    ecx,0x1
    3504:	mov    rsi,r12
    3507:	mov    rdi,r13
    350a:	call   350f <botlish_fn_42+0x23e>
			350b: R_X86_64_PLT32	rt_mutarray_set-0x4
    350f:	test   rax,rax
    3512:	jne    354f <botlish_fn_42+0x27e>
    3518:	xor    rax,rax
    351b:	mov    rbx,QWORD PTR [rsp+0xa0]
    3523:	mov    r12,QWORD PTR [rsp+0xa8]
    352b:	mov    r13,QWORD PTR [rsp+0xb0]
    3533:	mov    r14,QWORD PTR [rsp+0xb8]
    353b:	mov    r15,QWORD PTR [rsp+0xc0]
    3543:	add    rsp,0xd0
    354a:	mov    rsp,rbp
    354d:	pop    rbp
    354e:	ret
    354f:	mov    eax,0xa
    3554:	mov    rbx,QWORD PTR [rsp+0xa0]
    355c:	mov    r12,QWORD PTR [rsp+0xa8]
    3564:	mov    r13,QWORD PTR [rsp+0xb0]
    356c:	mov    r14,QWORD PTR [rsp+0xb8]
    3574:	mov    r15,QWORD PTR [rsp+0xc0]
    357c:	add    rsp,0xd0
    3583:	mov    rsp,rbp
    3586:	pop    rbp
    3587:	ret

0000000000003588 <botlish_entry_42: ht_rehash<mutarray, int>>:
    3588:	push   rbp
    3589:	mov    rbp,rsp
    358c:	mov    rsi,QWORD PTR [rdx]
    358f:	mov    rdx,QWORD PTR [rdx+0x8]
    3593:	call   3598 <botlish_entry_42+0x10>
			3594: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    3598:	mov    rsp,rbp
    359b:	pop    rbp
    359c:	ret
    359d:	add    BYTE PTR [rax],al
	...

00000000000035a0 <botlish_fn_43: ht_should_grow<mutarray>>:
    35a0:	push   rbp
    35a1:	mov    rbp,rsp
    35a4:	sub    rsp,0x40
    35a8:	mov    QWORD PTR [rsp+0x20],rbx
    35ad:	mov    QWORD PTR [rsp+0x28],r12
    35b2:	mov    QWORD PTR [rsp+0x30],r13
    35b7:	mov    rbx,rdi
    35ba:	mov    QWORD PTR [rsp],rsi
    35be:	mov    r12,rsi
    35c1:	mov    rsi,r12
    35c4:	mov    rdi,rbx
    35c7:	call   35cc <botlish_fn_43+0x2c>
			35c8: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    35cc:	mov    rcx,rax
    35cf:	mov    r13,rax
    35d2:	test   rax,rcx
    35d5:	je     37c4 <botlish_fn_43+0x224>
    35db:	mov    rax,r13
    35de:	mov    QWORD PTR [rsp+0x8],rax
    35e3:	mov    rsi,r12
    35e6:	mov    rdi,rbx
    35e9:	call   35ee <botlish_fn_43+0x4e>
			35ea: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    35ee:	mov    rcx,rax
    35f1:	test   rcx,rcx
    35f4:	je     37c4 <botlish_fn_43+0x224>
    35fa:	mov    QWORD PTR [rsp+0x10],rcx
    35ff:	mov    edx,0x1
    3604:	mov    rax,r13
    3607:	test   rax,0x1
    360d:	jne    3630 <botlish_fn_43+0x90>
    3613:	xor    edx,edx
    3615:	mov    rax,r13
    3618:	test   rax,0x7
    361e:	jne    3630 <botlish_fn_43+0x90>
    3624:	mov    rax,r13
    3627:	movzx  rax,BYTE PTR [rax]
    362b:	cmp    al,0x1
    362d:	sete   dl
    3630:	test   dl,dl
    3632:	jne    3653 <botlish_fn_43+0xb3>
    3638:	mov    rdi,rbx
    363b:	mov    rax,QWORD PTR [rdi+0x10]
    363f:	mov    rcx,QWORD PTR [rax+0x30]
    3643:	xor    rdx,rdx
    3646:	mov    rsi,r13
    3649:	call   364e <botlish_fn_43+0xae>
			364a: R_X86_64_PLT32	rt_type_error-0x4
    364e:	jmp    37c4 <botlish_fn_43+0x224>
    3653:	mov    eax,0x1
    3658:	test   rcx,0x1
    365f:	je     366d <botlish_fn_43+0xcd>
    3665:	mov    r8,rcx
    3668:	jmp    3690 <botlish_fn_43+0xf0>
    366d:	xor    eax,eax
    366f:	test   rcx,0x7
    3676:	je     3684 <botlish_fn_43+0xe4>
    367c:	mov    r8,rcx
    367f:	jmp    3690 <botlish_fn_43+0xf0>
    3684:	movzx  rax,BYTE PTR [rcx]
    3688:	mov    r8,rcx
    368b:	cmp    al,0x1
    368d:	sete   al
    3690:	test   al,al
    3692:	jne    36b3 <botlish_fn_43+0x113>
    3698:	mov    rdi,rbx
    369b:	mov    rax,QWORD PTR [rdi+0x10]
    369f:	mov    rcx,QWORD PTR [rax+0x30]
    36a3:	xor    rdx,rdx
    36a6:	mov    rsi,r8
    36a9:	call   36ae <botlish_fn_43+0x10e>
			36aa: R_X86_64_PLT32	rt_type_error-0x4
    36ae:	jmp    37c4 <botlish_fn_43+0x224>
    36b3:	mov    rcx,r8
    36b6:	mov    rsi,r13
    36b9:	mov    rax,rsi
    36bc:	and    rax,rcx
    36bf:	test   rax,0x1
    36c5:	jne    36d6 <botlish_fn_43+0x136>
    36cb:	mov    rdx,r8
    36ce:	mov    rsi,r13
    36d1:	jmp    36f4 <botlish_fn_43+0x154>
    36d6:	mov    rcx,r8
    36d9:	lea    rax,[rcx-0x1]
    36dd:	mov    rsi,r13
    36e0:	add    rsi,rax
    36e3:	seto   al
    36e6:	test   al,al
    36e8:	je     36ff <botlish_fn_43+0x15f>
    36ee:	mov    rdx,r8
    36f1:	mov    rsi,r13
    36f4:	mov    rdi,rbx
    36f7:	call   36fc <botlish_fn_43+0x15c>
			36f8: R_X86_64_PLT32	rt_int_add-0x4
    36fc:	mov    rsi,rax
    36ff:	mov    QWORD PTR [rsp+0x8],rsi
    3704:	mov    QWORD PTR [rsp+0x10],0x3
    370d:	test   rsi,0x1
    3714:	je     3737 <botlish_fn_43+0x197>
    371a:	mov    rax,rsi
    371d:	add    rax,0x2
    3721:	mov    rcx,rax
    3724:	seto   al
    3727:	test   al,al
    3729:	jne    3737 <botlish_fn_43+0x197>
    372f:	mov    rsi,rcx
    3732:	jmp    3747 <botlish_fn_43+0x1a7>
    3737:	mov    edx,0x3
    373c:	mov    rdi,rbx
    373f:	call   3744 <botlish_fn_43+0x1a4>
			3740: R_X86_64_PLT32	rt_int_add-0x4
    3744:	mov    rsi,rax
    3747:	mov    QWORD PTR [rsp+0x8],rsi
    374c:	mov    edx,0x7
    3751:	mov    rdi,rdx
    3754:	mov    QWORD PTR [rsp+0x10],0x7
    375d:	test   rsi,0x1
    3764:	jne    3772 <botlish_fn_43+0x1d2>
    376a:	mov    rdx,rdi
    376d:	jmp    379e <botlish_fn_43+0x1fe>
    3772:	mov    rax,rsi
    3775:	sar    rax,1
    3778:	imul   QWORD PTR [rip+0x119]        # 3898 <botlish_fn_43+0x2f8>
    377f:	seto   cl
    3782:	or     rax,0x1
    3786:	test   cl,cl
    3788:	je     3796 <botlish_fn_43+0x1f6>
    378e:	mov    rdx,rdi
    3791:	jmp    379e <botlish_fn_43+0x1fe>
    3796:	mov    rsi,rax
    3799:	jmp    37a9 <botlish_fn_43+0x209>
    379e:	mov    rdi,rbx
    37a1:	call   37a6 <botlish_fn_43+0x206>
			37a2: R_X86_64_PLT32	rt_int_mul-0x4
    37a6:	mov    rsi,rax
    37a9:	mov    QWORD PTR [rsp],rsi
    37ad:	mov    r13,rsi
    37b0:	mov    rsi,r12
    37b3:	mov    rdi,rbx
    37b6:	call   37bb <botlish_fn_43+0x21b>
			37b7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    37bb:	test   rax,rax
    37be:	jne    37df <botlish_fn_43+0x23f>
    37c4:	xor    rax,rax
    37c7:	mov    rbx,QWORD PTR [rsp+0x20]
    37cc:	mov    r12,QWORD PTR [rsp+0x28]
    37d1:	mov    r13,QWORD PTR [rsp+0x30]
    37d6:	add    rsp,0x40
    37da:	mov    rsp,rbp
    37dd:	pop    rbp
    37de:	ret
    37df:	mov    QWORD PTR [rsp+0x8],rax
    37e4:	mov    QWORD PTR [rsp+0x10],0x5
    37ed:	test   rax,0x1
    37f3:	mov    rsi,rax
    37f6:	je     3828 <botlish_fn_43+0x288>
    37fc:	mov    rcx,rsi
    37ff:	mov    rax,rcx
    3802:	sar    rax,1
    3805:	imul   QWORD PTR [rip+0x94]        # 38a0 <botlish_fn_43+0x300>
    380c:	seto   dil
    3810:	or     rax,0x1
    3814:	test   dil,dil
    3817:	jne    3828 <botlish_fn_43+0x288>
    381d:	mov    rdx,rax
    3820:	mov    rsi,r13
    3823:	jmp    383b <botlish_fn_43+0x29b>
    3828:	mov    edx,0x5
    382d:	mov    rdi,rbx
    3830:	call   3835 <botlish_fn_43+0x295>
			3831: R_X86_64_PLT32	rt_int_mul-0x4
    3835:	mov    rdx,rax
    3838:	mov    rsi,r13
    383b:	mov    r10,rsi
    383e:	and    r10,rdx
    3841:	test   r10,0x1
    3848:	jne    386f <botlish_fn_43+0x2cf>
    384e:	mov    rdi,rbx
    3851:	call   3856 <botlish_fn_43+0x2b6>
			3852: R_X86_64_PLT32	rt_int_cmp-0x4
    3856:	mov    r8d,0x2
    385c:	test   rax,rax
    385f:	mov    rax,r8
    3862:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3898 <botlish_fn_43+0x2f8>
    386a:	jmp    387f <botlish_fn_43+0x2df>
    386f:	mov    eax,0x2
    3874:	cmp    rsi,rdx
    3877:	cmovg  rax,QWORD PTR [rip+0x19]        # 3898 <botlish_fn_43+0x2f8>
    387f:	mov    rbx,QWORD PTR [rsp+0x20]
    3884:	mov    r12,QWORD PTR [rsp+0x28]
    3889:	mov    r13,QWORD PTR [rsp+0x30]
    388e:	add    rsp,0x40
    3892:	mov    rsp,rbp
    3895:	pop    rbp
    3896:	ret
    3897:	add    BYTE PTR [rsi],al
    3899:	add    BYTE PTR [rax],al
    389b:	add    BYTE PTR [rax],al
    389d:	add    BYTE PTR [rax],al
    389f:	add    BYTE PTR [rax+rax*1],al
    38a2:	add    BYTE PTR [rax],al
    38a4:	add    BYTE PTR [rax],al
	...

00000000000038a8 <botlish_entry_43: ht_should_grow<mutarray>>:
    38a8:	push   rbp
    38a9:	mov    rbp,rsp
    38ac:	mov    rsi,QWORD PTR [rdx]
    38af:	call   38b4 <botlish_entry_43+0xc>
			38b0: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_should_grow<mutarray>
    38b4:	mov    rsp,rbp
    38b7:	pop    rbp
    38b8:	ret
    38b9:	add    BYTE PTR [rax],al
    38bb:	add    BYTE PTR [rax],al
    38bd:	add    BYTE PTR [rax],al
	...

00000000000038c0 <botlish_fn_44: ht_grow_or_clean<mutarray>>:
    38c0:	push   rbp
    38c1:	mov    rbp,rsp
    38c4:	sub    rsp,0x40
    38c8:	mov    QWORD PTR [rsp+0x20],rbx
    38cd:	mov    QWORD PTR [rsp+0x28],r12
    38d2:	mov    QWORD PTR [rsp+0x30],r13
    38d7:	mov    rbx,rdi
    38da:	mov    QWORD PTR [rsp+0x10],0x0
    38e3:	mov    QWORD PTR [rsp],rsi
    38e7:	mov    r12,rsi
    38ea:	mov    rsi,r12
    38ed:	mov    rdi,rbx
    38f0:	call   38f5 <botlish_fn_44+0x35>
			38f1: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    38f5:	test   rax,rax
    38f8:	mov    r13,rax
    38fb:	je     3ae8 <botlish_fn_44+0x228>
    3901:	mov    rsi,r12
    3904:	mov    rdi,rbx
    3907:	call   390c <botlish_fn_44+0x4c>
			3908: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    390c:	mov    rcx,rax
    390f:	test   rcx,rcx
    3912:	je     3ae8 <botlish_fn_44+0x228>
    3918:	mov    edx,0x1
    391d:	mov    rax,r13
    3920:	test   rax,0x1
    3926:	je     3934 <botlish_fn_44+0x74>
    392c:	mov    r13,rax
    392f:	jmp    3958 <botlish_fn_44+0x98>
    3934:	xor    edx,edx
    3936:	test   rax,0x7
    393c:	je     394a <botlish_fn_44+0x8a>
    3942:	mov    r13,rax
    3945:	jmp    3958 <botlish_fn_44+0x98>
    394a:	movzx  rdx,BYTE PTR [rax]
    394e:	mov    r13,rax
    3951:	rex cmp dl,0x1
    3955:	sete   dl
    3958:	test   dl,dl
    395a:	jne    397b <botlish_fn_44+0xbb>
    3960:	mov    rdi,rbx
    3963:	mov    rsi,QWORD PTR [rdi+0x10]
    3967:	mov    rcx,QWORD PTR [rsi+0x38]
    396b:	xor    rdx,rdx
    396e:	mov    rsi,r13
    3971:	call   3976 <botlish_fn_44+0xb6>
			3972: R_X86_64_PLT32	rt_type_error-0x4
    3976:	jmp    3ae8 <botlish_fn_44+0x228>
    397b:	mov    rsi,r13
    397e:	mov    eax,0x1
    3983:	test   rcx,0x1
    398a:	je     3998 <botlish_fn_44+0xd8>
    3990:	mov    r8,rcx
    3993:	jmp    39bd <botlish_fn_44+0xfd>
    3998:	xor    eax,eax
    399a:	test   rcx,0x7
    39a1:	je     39af <botlish_fn_44+0xef>
    39a7:	mov    r8,rcx
    39aa:	jmp    39bd <botlish_fn_44+0xfd>
    39af:	movzx  r11,BYTE PTR [rcx]
    39b3:	mov    r8,rcx
    39b6:	cmp    r11b,0x1
    39ba:	sete   al
    39bd:	test   al,al
    39bf:	jne    39e0 <botlish_fn_44+0x120>
    39c5:	mov    rdi,rbx
    39c8:	mov    rax,QWORD PTR [rdi+0x10]
    39cc:	mov    rcx,QWORD PTR [rax+0x38]
    39d0:	xor    rdx,rdx
    39d3:	mov    rsi,r8
    39d6:	call   39db <botlish_fn_44+0x11b>
			39d7: R_X86_64_PLT32	rt_type_error-0x4
    39db:	jmp    3ae8 <botlish_fn_44+0x228>
    39e0:	mov    rcx,r8
    39e3:	mov    rax,rsi
    39e6:	and    rax,rcx
    39e9:	test   rax,0x1
    39ef:	jne    3a15 <botlish_fn_44+0x155>
    39f5:	mov    rdx,r8
    39f8:	mov    rdi,rbx
    39fb:	call   3a00 <botlish_fn_44+0x140>
			39fc: R_X86_64_PLT32	rt_int_cmp-0x4
    3a00:	mov    ecx,0x2
    3a05:	test   rax,rax
    3a08:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3b20 <botlish_fn_44+0x260>
    3a10:	jmp    3a28 <botlish_fn_44+0x168>
    3a15:	mov    ecx,0x2
    3a1a:	mov    r9,r8
    3a1d:	cmp    rsi,r9
    3a20:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3b20 <botlish_fn_44+0x260>
    3a28:	cmp    rcx,0x6
    3a2c:	je     3ab8 <botlish_fn_44+0x1f8>
    3a32:	mov    rsi,r12
    3a35:	mov    rdi,rbx
    3a38:	call   3a3d <botlish_fn_44+0x17d>
			3a39: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    3a3d:	test   rax,rax
    3a40:	je     3ae8 <botlish_fn_44+0x228>
    3a46:	mov    QWORD PTR [rsp+0x8],rax
    3a4b:	mov    QWORD PTR [rsp+0x10],0x5
    3a54:	test   rax,0x1
    3a5a:	mov    rsi,rax
    3a5d:	je     3a8a <botlish_fn_44+0x1ca>
    3a63:	mov    rcx,rsi
    3a66:	mov    rax,rcx
    3a69:	sar    rax,1
    3a6c:	imul   QWORD PTR [rip+0xb5]        # 3b28 <botlish_fn_44+0x268>
    3a73:	seto   cl
    3a76:	or     rax,0x1
    3a7a:	test   cl,cl
    3a7c:	jne    3a8a <botlish_fn_44+0x1ca>
    3a82:	mov    rdx,rax
    3a85:	jmp    3a9a <botlish_fn_44+0x1da>
    3a8a:	mov    edx,0x5
    3a8f:	mov    rdi,rbx
    3a92:	call   3a97 <botlish_fn_44+0x1d7>
			3a93: R_X86_64_PLT32	rt_int_mul-0x4
    3a97:	mov    rdx,rax
    3a9a:	mov    QWORD PTR [rsp+0x8],rdx
    3a9f:	mov    rsi,r12
    3aa2:	mov    rdi,rbx
    3aa5:	call   3aaa <botlish_fn_44+0x1ea>
			3aa6: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    3aaa:	test   rax,rax
    3aad:	je     3ae8 <botlish_fn_44+0x228>
    3ab3:	jmp    3b03 <botlish_fn_44+0x243>
    3ab8:	mov    rsi,r12
    3abb:	mov    rdi,rbx
    3abe:	call   3ac3 <botlish_fn_44+0x203>
			3abf: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    3ac3:	test   rax,rax
    3ac6:	je     3ae8 <botlish_fn_44+0x228>
    3acc:	mov    QWORD PTR [rsp+0x8],rax
    3ad1:	mov    rdx,rax
    3ad4:	mov    rsi,r12
    3ad7:	mov    rdi,rbx
    3ada:	call   3adf <botlish_fn_44+0x21f>
			3adb: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    3adf:	test   rax,rax
    3ae2:	jne    3b03 <botlish_fn_44+0x243>
    3ae8:	xor    rax,rax
    3aeb:	mov    rbx,QWORD PTR [rsp+0x20]
    3af0:	mov    r12,QWORD PTR [rsp+0x28]
    3af5:	mov    r13,QWORD PTR [rsp+0x30]
    3afa:	add    rsp,0x40
    3afe:	mov    rsp,rbp
    3b01:	pop    rbp
    3b02:	ret
    3b03:	mov    rbx,QWORD PTR [rsp+0x20]
    3b08:	mov    r12,QWORD PTR [rsp+0x28]
    3b0d:	mov    r13,QWORD PTR [rsp+0x30]
    3b12:	add    rsp,0x40
    3b16:	mov    rsp,rbp
    3b19:	pop    rbp
    3b1a:	ret
    3b1b:	add    BYTE PTR [rax],al
    3b1d:	add    BYTE PTR [rax],al
    3b1f:	add    BYTE PTR [rsi],al
    3b21:	add    BYTE PTR [rax],al
    3b23:	add    BYTE PTR [rax],al
    3b25:	add    BYTE PTR [rax],al
    3b27:	add    BYTE PTR [rax+rax*1],al
    3b2a:	add    BYTE PTR [rax],al
    3b2c:	add    BYTE PTR [rax],al
	...

0000000000003b30 <botlish_entry_44: ht_grow_or_clean<mutarray>>:
    3b30:	push   rbp
    3b31:	mov    rbp,rsp
    3b34:	mov    rsi,QWORD PTR [rdx]
    3b37:	call   3b3c <botlish_entry_44+0xc>
			3b38: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_grow_or_clean<mutarray>
    3b3c:	mov    rsp,rbp
    3b3f:	pop    rbp
    3b40:	ret
    3b41:	add    BYTE PTR [rax],al
    3b43:	add    BYTE PTR [rax],al
    3b45:	add    BYTE PTR [rax],al
	...

0000000000003b48 <botlish_fn_45: ht_place<mutarray, int, any, any>>:
    3b48:	push   rbp
    3b49:	mov    rbp,rsp
    3b4c:	sub    rsp,0x70
    3b50:	mov    QWORD PTR [rsp+0x40],rbx
    3b55:	mov    QWORD PTR [rsp+0x48],r12
    3b5a:	mov    QWORD PTR [rsp+0x50],r13
    3b5f:	mov    QWORD PTR [rsp+0x58],r14
    3b64:	mov    QWORD PTR [rsp+0x60],r15
    3b69:	mov    rbx,rdi
    3b6c:	mov    r14,r8
    3b6f:	mov    r15,rdx
    3b72:	mov    QWORD PTR [rsp+0x28],rcx
    3b77:	mov    QWORD PTR [rsp],rsi
    3b7b:	mov    r12,rsi
    3b7e:	mov    rsi,r12
    3b81:	mov    rdi,rbx
    3b84:	call   3b89 <botlish_fn_45+0x41>
			3b85: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    3b89:	test   rax,rax
    3b8c:	je     3ef2 <botlish_fn_45+0x3aa>
    3b92:	xor    ecx,ecx
    3b94:	test   rax,0x7
    3b9a:	je     3baa <botlish_fn_45+0x62>
    3ba0:	mov    QWORD PTR [rsp+0x30],rax
    3ba5:	jmp    3bba <botlish_fn_45+0x72>
    3baa:	movzx  rcx,BYTE PTR [rax]
    3bae:	mov    QWORD PTR [rsp+0x30],rax
    3bb3:	rex cmp cl,0x8
    3bb7:	sete   cl
    3bba:	test   cl,cl
    3bbc:	jne    3be1 <botlish_fn_45+0x99>
    3bc2:	mov    rdi,rbx
    3bc5:	mov    rax,QWORD PTR [rdi+0x10]
    3bc9:	mov    rcx,QWORD PTR [rax+0x20]
    3bcd:	mov    edx,0x8
    3bd2:	mov    rsi,QWORD PTR [rsp+0x30]
    3bd7:	call   3bdc <botlish_fn_45+0x94>
			3bd8: R_X86_64_PLT32	rt_type_error-0x4
    3bdc:	jmp    3ef2 <botlish_fn_45+0x3aa>
    3be1:	mov    rdx,r15
    3be4:	mov    rsi,QWORD PTR [rsp+0x30]
    3be9:	mov    rdi,rbx
    3bec:	call   3bf1 <botlish_fn_45+0xa9>
			3bed: R_X86_64_PLT32	rt_mutarray_get-0x4
    3bf1:	test   rax,rax
    3bf4:	je     3ef2 <botlish_fn_45+0x3aa>
    3bfa:	mov    QWORD PTR [rsp+0x8],rax
    3bff:	mov    r13,rax
    3c02:	mov    ecx,0x3
    3c07:	mov    rsi,QWORD PTR [rsp+0x30]
    3c0c:	mov    rdx,r15
    3c0f:	mov    rdi,rbx
    3c12:	call   3c17 <botlish_fn_45+0xcf>
			3c13: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c17:	test   rax,rax
    3c1a:	je     3ef2 <botlish_fn_45+0x3aa>
    3c20:	mov    rsi,r12
    3c23:	mov    rdi,rbx
    3c26:	call   3c2b <botlish_fn_45+0xe3>
			3c27: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    3c2b:	test   rax,rax
    3c2e:	je     3ef2 <botlish_fn_45+0x3aa>
    3c34:	xor    ecx,ecx
    3c36:	test   rax,0x7
    3c3c:	je     3c4a <botlish_fn_45+0x102>
    3c42:	mov    rsi,rax
    3c45:	jmp    3c58 <botlish_fn_45+0x110>
    3c4a:	movzx  rcx,BYTE PTR [rax]
    3c4e:	mov    rsi,rax
    3c51:	rex cmp cl,0x8
    3c55:	sete   cl
    3c58:	test   cl,cl
    3c5a:	jne    3c7a <botlish_fn_45+0x132>
    3c60:	mov    rdi,rbx
    3c63:	mov    rax,QWORD PTR [rdi+0x10]
    3c67:	mov    rcx,QWORD PTR [rax+0x40]
    3c6b:	mov    edx,0x8
    3c70:	call   3c75 <botlish_fn_45+0x12d>
			3c71: R_X86_64_PLT32	rt_type_error-0x4
    3c75:	jmp    3ef2 <botlish_fn_45+0x3aa>
    3c7a:	mov    rcx,QWORD PTR [rsp+0x28]
    3c7f:	mov    rdx,r15
    3c82:	mov    rdi,rbx
    3c85:	call   3c8a <botlish_fn_45+0x142>
			3c86: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c8a:	test   rax,rax
    3c8d:	je     3ef2 <botlish_fn_45+0x3aa>
    3c93:	mov    rsi,r12
    3c96:	mov    rdi,rbx
    3c99:	call   3c9e <botlish_fn_45+0x156>
			3c9a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    3c9e:	test   rax,rax
    3ca1:	je     3ef2 <botlish_fn_45+0x3aa>
    3ca7:	xor    esi,esi
    3ca9:	test   rax,0x7
    3caf:	jne    3cc1 <botlish_fn_45+0x179>
    3cb5:	movzx  rcx,BYTE PTR [rax]
    3cb9:	rex cmp cl,0x8
    3cbd:	sete   sil
    3cc1:	test   sil,sil
    3cc4:	jne    3ce7 <botlish_fn_45+0x19f>
    3cca:	mov    rdi,rbx
    3ccd:	mov    rsi,QWORD PTR [rdi+0x10]
    3cd1:	mov    rcx,QWORD PTR [rsi+0x40]
    3cd5:	mov    edx,0x8
    3cda:	mov    rsi,rax
    3cdd:	call   3ce2 <botlish_fn_45+0x19a>
			3cde: R_X86_64_PLT32	rt_type_error-0x4
    3ce2:	jmp    3ef2 <botlish_fn_45+0x3aa>
    3ce7:	mov    rcx,r14
    3cea:	mov    rdx,r15
    3ced:	mov    rsi,rax
    3cf0:	mov    rdi,rbx
    3cf3:	call   3cf8 <botlish_fn_45+0x1b0>
			3cf4: R_X86_64_PLT32	rt_mutarray_set-0x4
    3cf8:	test   rax,rax
    3cfb:	je     3ef2 <botlish_fn_45+0x3aa>
    3d01:	mov    QWORD PTR [rsp+0x10],0x7
    3d0a:	mov    rsi,r12
    3d0d:	mov    rdi,rbx
    3d10:	call   3d15 <botlish_fn_45+0x1cd>
			3d11: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    3d15:	test   rax,rax
    3d18:	je     3ef2 <botlish_fn_45+0x3aa>
    3d1e:	mov    QWORD PTR [rsp+0x18],rax
    3d23:	mov    QWORD PTR [rsp+0x20],0x3
    3d2c:	mov    ecx,0x1
    3d31:	test   rax,0x1
    3d37:	je     3d45 <botlish_fn_45+0x1fd>
    3d3d:	mov    rsi,rax
    3d40:	jmp    3d69 <botlish_fn_45+0x221>
    3d45:	xor    ecx,ecx
    3d47:	test   rax,0x7
    3d4d:	je     3d5b <botlish_fn_45+0x213>
    3d53:	mov    rsi,rax
    3d56:	jmp    3d69 <botlish_fn_45+0x221>
    3d5b:	movzx  rcx,BYTE PTR [rax]
    3d5f:	mov    rsi,rax
    3d62:	rex cmp cl,0x1
    3d66:	sete   cl
    3d69:	test   cl,cl
    3d6b:	jne    3d89 <botlish_fn_45+0x241>
    3d71:	mov    rdi,rbx
    3d74:	mov    rax,QWORD PTR [rdi+0x10]
    3d78:	mov    rcx,QWORD PTR [rax+0x30]
    3d7c:	xor    rdx,rdx
    3d7f:	call   3d84 <botlish_fn_45+0x23c>
			3d80: R_X86_64_PLT32	rt_type_error-0x4
    3d84:	jmp    3ef2 <botlish_fn_45+0x3aa>
    3d89:	test   rsi,0x1
    3d90:	je     3da8 <botlish_fn_45+0x260>
    3d96:	mov    rcx,rsi
    3d99:	add    rcx,0x2
    3d9d:	seto   al
    3da0:	test   al,al
    3da2:	je     3db8 <botlish_fn_45+0x270>
    3da8:	mov    edx,0x3
    3dad:	mov    rdi,rbx
    3db0:	call   3db5 <botlish_fn_45+0x26d>
			3db1: R_X86_64_PLT32	rt_int_add-0x4
    3db5:	mov    rcx,rax
    3db8:	mov    edx,0x7
    3dbd:	mov    rsi,r12
    3dc0:	mov    rdi,rbx
    3dc3:	call   3dc8 <botlish_fn_45+0x280>
			3dc4: R_X86_64_PLT32	rt_mutarray_set-0x4
    3dc8:	test   rax,rax
    3dcb:	je     3ef2 <botlish_fn_45+0x3aa>
    3dd1:	mov    rax,r13
    3dd4:	test   rax,0x1
    3dda:	jne    3dfe <botlish_fn_45+0x2b6>
    3de0:	mov    edx,0x5
    3de5:	mov    rsi,r13
    3de8:	mov    rdi,rbx
    3deb:	call   3df0 <botlish_fn_45+0x2a8>
			3dec: R_X86_64_PLT32	rt_value_eq-0x4
    3df0:	test   rax,rax
    3df3:	je     3ef2 <botlish_fn_45+0x3aa>
    3df9:	jmp    3e12 <botlish_fn_45+0x2ca>
    3dfe:	mov    rsi,r13
    3e01:	mov    eax,0x2
    3e06:	cmp    rsi,0x5
    3e0a:	cmove  rax,QWORD PTR [rip+0x12e]        # 3f40 <botlish_fn_45+0x3f8>
    3e12:	cmp    rax,0x6
    3e16:	jne    3f17 <botlish_fn_45+0x3cf>
    3e1c:	mov    QWORD PTR [rsp+0x8],0x9
    3e25:	mov    rsi,r12
    3e28:	mov    rdi,rbx
    3e2b:	call   3e30 <botlish_fn_45+0x2e8>
			3e2c: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    3e30:	test   rax,rax
    3e33:	je     3ef2 <botlish_fn_45+0x3aa>
    3e39:	mov    QWORD PTR [rsp+0x10],rax
    3e3e:	mov    QWORD PTR [rsp+0x18],0x3
    3e47:	mov    ecx,0x1
    3e4c:	test   rax,0x1
    3e52:	je     3e60 <botlish_fn_45+0x318>
    3e58:	mov    rsi,rax
    3e5b:	jmp    3e84 <botlish_fn_45+0x33c>
    3e60:	xor    ecx,ecx
    3e62:	test   rax,0x7
    3e68:	je     3e76 <botlish_fn_45+0x32e>
    3e6e:	mov    rsi,rax
    3e71:	jmp    3e84 <botlish_fn_45+0x33c>
    3e76:	movzx  rcx,BYTE PTR [rax]
    3e7a:	mov    rsi,rax
    3e7d:	rex cmp cl,0x1
    3e81:	sete   cl
    3e84:	test   cl,cl
    3e86:	jne    3ea4 <botlish_fn_45+0x35c>
    3e8c:	mov    rdi,rbx
    3e8f:	mov    rcx,QWORD PTR [rdi+0x10]
    3e93:	mov    rcx,QWORD PTR [rcx+0x48]
    3e97:	xor    rdx,rdx
    3e9a:	call   3e9f <botlish_fn_45+0x357>
			3e9b: R_X86_64_PLT32	rt_type_error-0x4
    3e9f:	jmp    3ef2 <botlish_fn_45+0x3aa>
    3ea4:	test   rsi,0x1
    3eab:	je     3ec9 <botlish_fn_45+0x381>
    3eb1:	mov    r8,rsi
    3eb4:	sub    r8,0x3
    3eb8:	seto   dil
    3ebc:	lea    rcx,[r8+0x1]
    3ec0:	test   dil,dil
    3ec3:	je     3ed9 <botlish_fn_45+0x391>
    3ec9:	mov    edx,0x3
    3ece:	mov    rdi,rbx
    3ed1:	call   3ed6 <botlish_fn_45+0x38e>
			3ed2: R_X86_64_PLT32	rt_int_sub-0x4
    3ed6:	mov    rcx,rax
    3ed9:	mov    edx,0x9
    3ede:	mov    rsi,r12
    3ee1:	mov    rdi,rbx
    3ee4:	call   3ee9 <botlish_fn_45+0x3a1>
			3ee5: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ee9:	test   rax,rax
    3eec:	jne    3f17 <botlish_fn_45+0x3cf>
    3ef2:	xor    rax,rax
    3ef5:	mov    rbx,QWORD PTR [rsp+0x40]
    3efa:	mov    r12,QWORD PTR [rsp+0x48]
    3eff:	mov    r13,QWORD PTR [rsp+0x50]
    3f04:	mov    r14,QWORD PTR [rsp+0x58]
    3f09:	mov    r15,QWORD PTR [rsp+0x60]
    3f0e:	add    rsp,0x70
    3f12:	mov    rsp,rbp
    3f15:	pop    rbp
    3f16:	ret
    3f17:	mov    eax,0xa
    3f1c:	mov    rbx,QWORD PTR [rsp+0x40]
    3f21:	mov    r12,QWORD PTR [rsp+0x48]
    3f26:	mov    r13,QWORD PTR [rsp+0x50]
    3f2b:	mov    r14,QWORD PTR [rsp+0x58]
    3f30:	mov    r15,QWORD PTR [rsp+0x60]
    3f35:	add    rsp,0x70
    3f39:	mov    rsp,rbp
    3f3c:	pop    rbp
    3f3d:	ret
    3f3e:	add    BYTE PTR [rax],al
    3f40:	(bad)
    3f41:	add    BYTE PTR [rax],al
    3f43:	add    BYTE PTR [rax],al
    3f45:	add    BYTE PTR [rax],al
	...

0000000000003f48 <botlish_entry_45: ht_place<mutarray, int, any, any>>:
    3f48:	push   rbp
    3f49:	mov    rbp,rsp
    3f4c:	mov    rsi,QWORD PTR [rdx]
    3f4f:	mov    r9,QWORD PTR [rdx+0x8]
    3f53:	mov    rcx,QWORD PTR [rdx+0x10]
    3f57:	mov    r8,QWORD PTR [rdx+0x18]
    3f5b:	mov    rdx,r9
    3f5e:	call   3f63 <botlish_entry_45+0x1b>
			3f5f: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    3f63:	mov    rsp,rbp
    3f66:	pop    rbp
    3f67:	ret

0000000000003f68 <botlish_fn_46: ht_set<mutarray, any, any>>:
    3f68:	push   rbp
    3f69:	mov    rbp,rsp
    3f6c:	sub    rsp,0x60
    3f70:	mov    QWORD PTR [rsp+0x30],rbx
    3f75:	mov    QWORD PTR [rsp+0x38],r12
    3f7a:	mov    QWORD PTR [rsp+0x40],r13
    3f7f:	mov    QWORD PTR [rsp+0x48],r14
    3f84:	mov    QWORD PTR [rsp+0x50],r15
    3f89:	mov    rbx,rdi
    3f8c:	mov    r13,rdx
    3f8f:	mov    QWORD PTR [rsp],rsi
    3f93:	mov    r14,rsi
    3f96:	mov    QWORD PTR [rsp+0x8],rdx
    3f9b:	mov    QWORD PTR [rsp+0x10],rcx
    3fa0:	mov    r12,rcx
    3fa3:	mov    rdx,r13
    3fa6:	mov    rsi,r14
    3fa9:	mov    rdi,rbx
    3fac:	call   3fb1 <botlish_fn_46+0x49>
			3fad: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    3fb1:	test   rax,rax
    3fb4:	je     421f <botlish_fn_46+0x2b7>
    3fba:	mov    QWORD PTR [rsp+0x18],rax
    3fbf:	mov    rcx,rax
    3fc2:	mov    r8,0xffffffffffffffff
    3fc9:	mov    QWORD PTR [rsp+0x28],r8
    3fce:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3fd7:	mov    rdx,r13
    3fda:	mov    rsi,r14
    3fdd:	mov    rdi,rbx
    3fe0:	call   3fe5 <botlish_fn_46+0x7d>
			3fe1: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    3fe5:	mov    rcx,rax
    3fe8:	mov    r15,rax
    3feb:	test   rax,rcx
    3fee:	je     421f <botlish_fn_46+0x2b7>
    3ff4:	mov    rax,r15
    3ff7:	mov    QWORD PTR [rsp+0x18],rax
    3ffc:	mov    rsi,r14
    3fff:	mov    rdi,rbx
    4002:	call   4007 <botlish_fn_46+0x9f>
			4003: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    4007:	test   rax,rax
    400a:	je     421f <botlish_fn_46+0x2b7>
    4010:	xor    ecx,ecx
    4012:	test   rax,0x7
    4018:	je     4026 <botlish_fn_46+0xbe>
    401e:	mov    r8,rax
    4021:	jmp    4034 <botlish_fn_46+0xcc>
    4026:	movzx  rcx,BYTE PTR [rax]
    402a:	mov    r8,rax
    402d:	rex cmp cl,0x8
    4031:	sete   cl
    4034:	test   cl,cl
    4036:	jne    4059 <botlish_fn_46+0xf1>
    403c:	mov    rdi,rbx
    403f:	mov    rsi,QWORD PTR [rdi+0x10]
    4043:	mov    rcx,QWORD PTR [rsi+0x20]
    4047:	mov    edx,0x8
    404c:	mov    rsi,r8
    404f:	call   4054 <botlish_fn_46+0xec>
			4050: R_X86_64_PLT32	rt_type_error-0x4
    4054:	jmp    421f <botlish_fn_46+0x2b7>
    4059:	mov    rsi,r8
    405c:	mov    rdx,r15
    405f:	mov    rdi,rbx
    4062:	call   4067 <botlish_fn_46+0xff>
			4063: R_X86_64_PLT32	rt_mutarray_get-0x4
    4067:	test   rax,rax
    406a:	je     421f <botlish_fn_46+0x2b7>
    4070:	test   rax,0x1
    4076:	mov    rsi,rax
    4079:	jne    409a <botlish_fn_46+0x132>
    407f:	mov    edx,0x3
    4084:	mov    rdi,rbx
    4087:	call   408c <botlish_fn_46+0x124>
			4088: R_X86_64_PLT32	rt_value_eq-0x4
    408c:	test   rax,rax
    408f:	je     421f <botlish_fn_46+0x2b7>
    4095:	jmp    40ab <botlish_fn_46+0x143>
    409a:	mov    eax,0x2
    409f:	cmp    rsi,0x3
    40a3:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4270 <botlish_fn_46+0x308>
    40ab:	cmp    rax,0x6
    40af:	je     41ae <botlish_fn_46+0x246>
    40b5:	mov    rsi,r14
    40b8:	mov    rdi,rbx
    40bb:	call   40c0 <botlish_fn_46+0x158>
			40bc: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_should_grow<mutarray>
    40c0:	test   rax,rax
    40c3:	je     421f <botlish_fn_46+0x2b7>
    40c9:	cmp    rax,0x6
    40cd:	je     4112 <botlish_fn_46+0x1aa>
    40d3:	mov    rcx,r13
    40d6:	mov    rdx,r15
    40d9:	mov    rsi,r14
    40dc:	mov    rdi,rbx
    40df:	mov    r8,r12
    40e2:	call   40e7 <botlish_fn_46+0x17f>
			40e3: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    40e7:	test   rax,rax
    40ea:	je     421f <botlish_fn_46+0x2b7>
    40f0:	mov    rbx,QWORD PTR [rsp+0x30]
    40f5:	mov    r12,QWORD PTR [rsp+0x38]
    40fa:	mov    r13,QWORD PTR [rsp+0x40]
    40ff:	mov    r14,QWORD PTR [rsp+0x48]
    4104:	mov    r15,QWORD PTR [rsp+0x50]
    4109:	add    rsp,0x60
    410d:	mov    rsp,rbp
    4110:	pop    rbp
    4111:	ret
    4112:	mov    rsi,r14
    4115:	mov    rdi,rbx
    4118:	call   411d <botlish_fn_46+0x1b5>
			4119: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_grow_or_clean<mutarray>
    411d:	test   rax,rax
    4120:	je     421f <botlish_fn_46+0x2b7>
    4126:	mov    rdx,r13
    4129:	mov    rsi,r14
    412c:	mov    rdi,rbx
    412f:	call   4134 <botlish_fn_46+0x1cc>
			4130: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    4134:	test   rax,rax
    4137:	je     421f <botlish_fn_46+0x2b7>
    413d:	mov    QWORD PTR [rsp+0x18],rax
    4142:	mov    rcx,rax
    4145:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    414e:	mov    r8,QWORD PTR [rsp+0x28]
    4153:	mov    rdx,r13
    4156:	mov    rsi,r14
    4159:	mov    rdi,rbx
    415c:	call   4161 <botlish_fn_46+0x1f9>
			415d: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    4161:	test   rax,rax
    4164:	je     421f <botlish_fn_46+0x2b7>
    416a:	mov    QWORD PTR [rsp+0x18],rax
    416f:	mov    rcx,r13
    4172:	mov    rdx,rax
    4175:	mov    rsi,r14
    4178:	mov    rdi,rbx
    417b:	mov    r8,r12
    417e:	call   4183 <botlish_fn_46+0x21b>
			417f: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    4183:	test   rax,rax
    4186:	je     421f <botlish_fn_46+0x2b7>
    418c:	mov    rbx,QWORD PTR [rsp+0x30]
    4191:	mov    r12,QWORD PTR [rsp+0x38]
    4196:	mov    r13,QWORD PTR [rsp+0x40]
    419b:	mov    r14,QWORD PTR [rsp+0x48]
    41a0:	mov    r15,QWORD PTR [rsp+0x50]
    41a5:	add    rsp,0x60
    41a9:	mov    rsp,rbp
    41ac:	pop    rbp
    41ad:	ret
    41ae:	mov    rsi,r14
    41b1:	mov    rdi,rbx
    41b4:	call   41b9 <botlish_fn_46+0x251>
			41b5: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    41b9:	test   rax,rax
    41bc:	je     421f <botlish_fn_46+0x2b7>
    41c2:	xor    ecx,ecx
    41c4:	test   rax,0x7
    41ca:	je     41d8 <botlish_fn_46+0x270>
    41d0:	mov    rsi,rax
    41d3:	jmp    41e6 <botlish_fn_46+0x27e>
    41d8:	movzx  rcx,BYTE PTR [rax]
    41dc:	mov    rsi,rax
    41df:	rex cmp cl,0x8
    41e3:	sete   cl
    41e6:	test   cl,cl
    41e8:	jne    4208 <botlish_fn_46+0x2a0>
    41ee:	mov    rdi,rbx
    41f1:	mov    rax,QWORD PTR [rdi+0x10]
    41f5:	mov    rcx,QWORD PTR [rax+0x40]
    41f9:	mov    edx,0x8
    41fe:	call   4203 <botlish_fn_46+0x29b>
			41ff: R_X86_64_PLT32	rt_type_error-0x4
    4203:	jmp    421f <botlish_fn_46+0x2b7>
    4208:	mov    rcx,r12
    420b:	mov    rdx,r15
    420e:	mov    rdi,rbx
    4211:	call   4216 <botlish_fn_46+0x2ae>
			4212: R_X86_64_PLT32	rt_mutarray_set-0x4
    4216:	test   rax,rax
    4219:	jne    4244 <botlish_fn_46+0x2dc>
    421f:	xor    rax,rax
    4222:	mov    rbx,QWORD PTR [rsp+0x30]
    4227:	mov    r12,QWORD PTR [rsp+0x38]
    422c:	mov    r13,QWORD PTR [rsp+0x40]
    4231:	mov    r14,QWORD PTR [rsp+0x48]
    4236:	mov    r15,QWORD PTR [rsp+0x50]
    423b:	add    rsp,0x60
    423f:	mov    rsp,rbp
    4242:	pop    rbp
    4243:	ret
    4244:	mov    eax,0xa
    4249:	mov    rbx,QWORD PTR [rsp+0x30]
    424e:	mov    r12,QWORD PTR [rsp+0x38]
    4253:	mov    r13,QWORD PTR [rsp+0x40]
    4258:	mov    r14,QWORD PTR [rsp+0x48]
    425d:	mov    r15,QWORD PTR [rsp+0x50]
    4262:	add    rsp,0x60
    4266:	mov    rsp,rbp
    4269:	pop    rbp
    426a:	ret
    426b:	add    BYTE PTR [rax],al
    426d:	add    BYTE PTR [rax],al
    426f:	add    BYTE PTR [rsi],al
    4271:	add    BYTE PTR [rax],al
    4273:	add    BYTE PTR [rax],al
    4275:	add    BYTE PTR [rax],al
	...

0000000000004278 <botlish_entry_46: ht_set<mutarray, any, any>>:
    4278:	push   rbp
    4279:	mov    rbp,rsp
    427c:	mov    rsi,QWORD PTR [rdx]
    427f:	mov    r8,QWORD PTR [rdx+0x8]
    4283:	mov    rcx,QWORD PTR [rdx+0x10]
    4287:	mov    rdx,r8
    428a:	call   428f <botlish_entry_46+0x17>
			428b: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_set<mutarray, any, any>
    428f:	mov    rsp,rbp
    4292:	pop    rbp
    4293:	ret

0000000000004294 <botlish_fn_47: row_new<bool, int>>:
    4294:	push   rbp
    4295:	mov    rbp,rsp
    4298:	sub    rsp,0x10
    429c:	mov    QWORD PTR [rsp],rdx
    42a0:	mov    r8,rdx
    42a3:	cmp    rsi,0x6
    42a7:	je     42c4 <botlish_fn_47+0x30>
    42ad:	call   42b2 <botlish_fn_47+0x1e>
			42ae: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_new<generic>
    42b2:	test   rax,rax
    42b5:	je     42d5 <botlish_fn_47+0x41>
    42bb:	add    rsp,0x10
    42bf:	mov    rsp,rbp
    42c2:	pop    rbp
    42c3:	ret
    42c4:	mov    rsi,r8
    42c7:	call   42cc <botlish_fn_47+0x38>
			42c8: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_new_sized<int>
    42cc:	test   rax,rax
    42cf:	jne    42e1 <botlish_fn_47+0x4d>
    42d5:	xor    rax,rax
    42d8:	add    rsp,0x10
    42dc:	mov    rsp,rbp
    42df:	pop    rbp
    42e0:	ret
    42e1:	add    rsp,0x10
    42e5:	mov    rsp,rbp
    42e8:	pop    rbp
    42e9:	ret

00000000000042ea <botlish_entry_47: row_new<bool, int>>:
    42ea:	push   rbp
    42eb:	mov    rbp,rsp
    42ee:	mov    rsi,QWORD PTR [rdx]
    42f1:	mov    rdx,QWORD PTR [rdx+0x8]
    42f5:	call   42fa <botlish_entry_47+0x10>
			42f6: R_X86_64_PLT32	botlish_fn_47-0x4 ; row_new<bool, int>
    42fa:	mov    rsp,rbp
    42fd:	pop    rbp
    42fe:	ret
	...

0000000000004300 <botlish_fn_48: row_fill<mutarray, any, any, int, int>>:
    4300:	push   rbp
    4301:	mov    rbp,rsp
    4304:	sub    rsp,0x70
    4308:	mov    QWORD PTR [rsp+0x40],rbx
    430d:	mov    QWORD PTR [rsp+0x48],r12
    4312:	mov    QWORD PTR [rsp+0x50],r13
    4317:	mov    QWORD PTR [rsp+0x58],r14
    431c:	mov    QWORD PTR [rsp+0x60],r15
    4321:	mov    rbx,rdx
    4324:	mov    r15,rdi
    4327:	mov    QWORD PTR [rsp],rsi
    432b:	mov    r13,rsi
    432e:	mov    QWORD PTR [rsp+0x8],rdx
    4333:	mov    QWORD PTR [rsp+0x10],rcx
    4338:	mov    QWORD PTR [rsp+0x30],rcx
    433d:	mov    QWORD PTR [rsp+0x18],r8
    4342:	mov    r14,r9
    4345:	mov    rax,r14
    4348:	or     rax,0x1
    434c:	mov    r12,r8
    434f:	mov    rcx,r12
    4352:	and    rcx,rax
    4355:	test   rcx,0x1
    435c:	jne    4389 <botlish_fn_48+0x89>
    4362:	mov    rdx,r14
    4365:	or     rdx,0x1
    4369:	mov    rsi,r12
    436c:	mov    rdi,r15
    436f:	call   4374 <botlish_fn_48+0x74>
			4370: R_X86_64_PLT32	rt_int_cmp-0x4
    4374:	mov    ecx,0x2
    4379:	test   rax,rax
    437c:	cmovge rcx,QWORD PTR [rip+0x20c]        # 4590 <botlish_fn_48+0x290>
    4384:	jmp    43a0 <botlish_fn_48+0xa0>
    4389:	mov    rdx,r14
    438c:	or     rdx,0x1
    4390:	mov    ecx,0x2
    4395:	cmp    r12,rdx
    4398:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 4590 <botlish_fn_48+0x290>
    43a0:	cmp    rcx,0x6
    43a4:	je     456a <botlish_fn_48+0x26a>
    43aa:	xor    ecx,ecx
    43ac:	mov    rdx,rbx
    43af:	test   rdx,0x7
    43b6:	jne    43ca <botlish_fn_48+0xca>
    43bc:	mov    rdx,rbx
    43bf:	movzx  r9,BYTE PTR [rdx]
    43c3:	cmp    r9b,0x3
    43c7:	sete   cl
    43ca:	test   cl,cl
    43cc:	jne    43ef <botlish_fn_48+0xef>
    43d2:	mov    rdi,r15
    43d5:	mov    rax,QWORD PTR [rdi+0x10]
    43d9:	mov    rcx,QWORD PTR [rax+0x50]
    43dd:	mov    edx,0x4
    43e2:	mov    rsi,rbx
    43e5:	call   43ea <botlish_fn_48+0xea>
			43e6: R_X86_64_PLT32	rt_type_error-0x4
    43ea:	jmp    4514 <botlish_fn_48+0x214>
    43ef:	mov    rsi,rbx
    43f2:	test   r12,0x1
    43f9:	jne    4407 <botlish_fn_48+0x107>
    43ff:	mov    rbx,rsi
    4402:	jmp    441d <botlish_fn_48+0x11d>
    4407:	mov    rax,QWORD PTR [rsi+0x8]
    440b:	mov    rbx,rsi
    440e:	mov    rcx,r12
    4411:	sar    rcx,1
    4414:	cmp    rcx,rax
    4417:	jb     443c <botlish_fn_48+0x13c>
    441d:	mov    rdx,r12
    4420:	mov    rsi,rbx
    4423:	mov    rdi,r15
    4426:	call   442b <botlish_fn_48+0x12b>
			4427: R_X86_64_PLT32	rt_list_get-0x4
    442b:	test   rax,rax
    442e:	je     4514 <botlish_fn_48+0x214>
    4434:	mov    rdx,rax
    4437:	jmp    4444 <botlish_fn_48+0x144>
    443c:	mov    rax,QWORD PTR [rbx+0x10]
    4440:	mov    rdx,QWORD PTR [rax+rcx*8]
    4444:	mov    QWORD PTR [rsp+0x20],rdx
    4449:	mov    QWORD PTR [rsp+0x38],rdx
    444e:	xor    esi,esi
    4450:	mov    rcx,QWORD PTR [rsp+0x30]
    4455:	test   rcx,0x7
    445c:	je     446c <botlish_fn_48+0x16c>
    4462:	mov    QWORD PTR [rsp+0x30],rcx
    4467:	jmp    447b <botlish_fn_48+0x17b>
    446c:	movzx  rax,BYTE PTR [rcx]
    4470:	mov    QWORD PTR [rsp+0x30],rcx
    4475:	cmp    al,0x3
    4477:	sete   sil
    447b:	test   sil,sil
    447e:	jne    44a3 <botlish_fn_48+0x1a3>
    4484:	mov    rdi,r15
    4487:	mov    rax,QWORD PTR [rdi+0x10]
    448b:	mov    rcx,QWORD PTR [rax+0x50]
    448f:	mov    edx,0x4
    4494:	mov    rsi,QWORD PTR [rsp+0x30]
    4499:	call   449e <botlish_fn_48+0x19e>
			449a: R_X86_64_PLT32	rt_type_error-0x4
    449e:	jmp    4514 <botlish_fn_48+0x214>
    44a3:	test   r12,0x1
    44aa:	je     44c8 <botlish_fn_48+0x1c8>
    44b0:	mov    rsi,QWORD PTR [rsp+0x30]
    44b5:	mov    rcx,QWORD PTR [rsi+0x8]
    44b9:	mov    rax,r12
    44bc:	sar    rax,1
    44bf:	cmp    rax,rcx
    44c2:	jb     44e9 <botlish_fn_48+0x1e9>
    44c8:	mov    rdx,r12
    44cb:	mov    rsi,QWORD PTR [rsp+0x30]
    44d0:	mov    rdi,r15
    44d3:	call   44d8 <botlish_fn_48+0x1d8>
			44d4: R_X86_64_PLT32	rt_list_get-0x4
    44d8:	test   rax,rax
    44db:	je     4514 <botlish_fn_48+0x214>
    44e1:	mov    rcx,rax
    44e4:	jmp    44f6 <botlish_fn_48+0x1f6>
    44e9:	mov    rsi,QWORD PTR [rsp+0x30]
    44ee:	mov    rcx,QWORD PTR [rsi+0x10]
    44f2:	mov    rcx,QWORD PTR [rcx+rax*8]
    44f6:	mov    QWORD PTR [rsp+0x28],rcx
    44fb:	mov    rdx,QWORD PTR [rsp+0x38]
    4500:	mov    rsi,r13
    4503:	mov    rdi,r15
    4506:	call   450b <botlish_fn_48+0x20b>
			4507: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_set<mutarray, any, any>
    450b:	test   rax,rax
    450e:	jne    4539 <botlish_fn_48+0x239>
    4514:	xor    rax,rax
    4517:	mov    rbx,QWORD PTR [rsp+0x40]
    451c:	mov    r12,QWORD PTR [rsp+0x48]
    4521:	mov    r13,QWORD PTR [rsp+0x50]
    4526:	mov    r14,QWORD PTR [rsp+0x58]
    452b:	mov    r15,QWORD PTR [rsp+0x60]
    4530:	add    rsp,0x70
    4534:	mov    rsp,rbp
    4537:	pop    rbp
    4538:	ret
    4539:	mov    QWORD PTR [rsp],r13
    453d:	mov    QWORD PTR [rsp+0x8],rbx
    4542:	mov    rsi,QWORD PTR [rsp+0x30]
    4547:	mov    QWORD PTR [rsp+0x10],rsi
    454c:	sar    r12,1
    454f:	add    r12,0x1
    4556:	shl    r12,1
    4559:	or     r12,0x1
    455d:	mov    QWORD PTR [rsp+0x18],r12
    4562:	mov    r8,r12
    4565:	jmp    4345 <botlish_fn_48+0x45>
    456a:	mov    rax,r13
    456d:	mov    rbx,QWORD PTR [rsp+0x40]
    4572:	mov    r12,QWORD PTR [rsp+0x48]
    4577:	mov    r13,QWORD PTR [rsp+0x50]
    457c:	mov    r14,QWORD PTR [rsp+0x58]
    4581:	mov    r15,QWORD PTR [rsp+0x60]
    4586:	add    rsp,0x70
    458a:	mov    rsp,rbp
    458d:	pop    rbp
    458e:	ret
    458f:	add    BYTE PTR [rsi],al
    4591:	add    BYTE PTR [rax],al
    4593:	add    BYTE PTR [rax],al
    4595:	add    BYTE PTR [rax],al
	...

0000000000004598 <botlish_entry_48: row_fill<mutarray, any, any, int, int>>:
    4598:	push   rbp
    4599:	mov    rbp,rsp
    459c:	mov    rsi,QWORD PTR [rdx]
    459f:	mov    r10,QWORD PTR [rdx+0x8]
    45a3:	mov    rcx,QWORD PTR [rdx+0x10]
    45a7:	mov    r8,QWORD PTR [rdx+0x18]
    45ab:	mov    r9,QWORD PTR [rdx+0x20]
    45af:	mov    rdx,r10
    45b2:	call   45b7 <botlish_entry_48+0x1f>
			45b3: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_fill<mutarray, any, any, int, int>
    45b7:	mov    rsp,rbp
    45ba:	pop    rbp
    45bb:	ret

00000000000045bc <botlish_fn_49: row_table<any, int, any, bool>>:
    45bc:	push   rbp
    45bd:	mov    rbp,rsp
    45c0:	sub    rsp,0x50
    45c4:	mov    QWORD PTR [rsp+0x30],rbx
    45c9:	mov    QWORD PTR [rsp+0x38],r12
    45ce:	mov    QWORD PTR [rsp+0x40],r13
    45d3:	mov    QWORD PTR [rsp+0x48],r14
    45d8:	mov    r12,rdi
    45db:	mov    QWORD PTR [rsp+0x20],0x0
    45e4:	mov    QWORD PTR [rsp],rsi
    45e8:	mov    r13,rsi
    45eb:	mov    QWORD PTR [rsp+0x8],rdx
    45f0:	mov    QWORD PTR [rsp+0x10],rcx
    45f5:	mov    rbx,rcx
    45f8:	mov    QWORD PTR [rsp+0x18],r8
    45fd:	mov    rsi,r8
    4600:	mov    rdi,r12
    4603:	call   4608 <botlish_fn_49+0x4c>
			4604: R_X86_64_PLT32	botlish_fn_47-0x4 ; row_new<bool, int>
    4608:	test   rax,rax
    460b:	je     46a0 <botlish_fn_49+0xe4>
    4611:	mov    QWORD PTR [rsp+0x8],rax
    4616:	mov    r14,rax
    4619:	mov    QWORD PTR [rsp+0x18],0x1
    4622:	xor    eax,eax
    4624:	mov    rcx,rbx
    4627:	test   rcx,0x7
    462e:	je     463c <botlish_fn_49+0x80>
    4634:	mov    rbx,rcx
    4637:	jmp    4648 <botlish_fn_49+0x8c>
    463c:	movzx  rax,BYTE PTR [rcx]
    4640:	mov    rbx,rcx
    4643:	cmp    al,0x3
    4645:	sete   al
    4648:	test   al,al
    464a:	jne    466d <botlish_fn_49+0xb1>
    4650:	mov    rdi,r12
    4653:	mov    rax,QWORD PTR [rdi+0x10]
    4657:	mov    rcx,QWORD PTR [rax+0x58]
    465b:	mov    edx,0x4
    4660:	mov    rsi,rbx
    4663:	call   4668 <botlish_fn_49+0xac>
			4664: R_X86_64_PLT32	rt_type_error-0x4
    4668:	jmp    46a0 <botlish_fn_49+0xe4>
    466d:	mov    rsi,rbx
    4670:	mov    rdi,r12
    4673:	call   4678 <botlish_fn_49+0xbc>
			4674: R_X86_64_PLT32	rt_list_len-0x4
    4678:	mov    QWORD PTR [rsp+0x20],rax
    467d:	mov    r8d,0x1
    4683:	mov    rcx,rbx
    4686:	mov    rdx,r13
    4689:	mov    rsi,r14
    468c:	mov    rdi,r12
    468f:	mov    r9,rax
    4692:	call   4697 <botlish_fn_49+0xdb>
			4693: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_fill<mutarray, any, any, int, int>
    4697:	test   rax,rax
    469a:	jne    46c0 <botlish_fn_49+0x104>
    46a0:	xor    rax,rax
    46a3:	mov    rbx,QWORD PTR [rsp+0x30]
    46a8:	mov    r12,QWORD PTR [rsp+0x38]
    46ad:	mov    r13,QWORD PTR [rsp+0x40]
    46b2:	mov    r14,QWORD PTR [rsp+0x48]
    46b7:	add    rsp,0x50
    46bb:	mov    rsp,rbp
    46be:	pop    rbp
    46bf:	ret
    46c0:	mov    rbx,QWORD PTR [rsp+0x30]
    46c5:	mov    r12,QWORD PTR [rsp+0x38]
    46ca:	mov    r13,QWORD PTR [rsp+0x40]
    46cf:	mov    r14,QWORD PTR [rsp+0x48]
    46d4:	add    rsp,0x50
    46d8:	mov    rsp,rbp
    46db:	pop    rbp
    46dc:	ret

00000000000046dd <botlish_entry_49: row_table<any, int, any, bool>>:
    46dd:	push   rbp
    46de:	mov    rbp,rsp
    46e1:	mov    rsi,QWORD PTR [rdx]
    46e4:	mov    r9,QWORD PTR [rdx+0x8]
    46e8:	mov    rcx,QWORD PTR [rdx+0x10]
    46ec:	mov    r8,QWORD PTR [rdx+0x18]
    46f0:	mov    rdx,r9
    46f3:	call   46f8 <botlish_entry_49+0x1b>
			46f4: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_table<any, int, any, bool>
    46f8:	mov    rsp,rbp
    46fb:	pop    rbp
    46fc:	ret
    46fd:	add    BYTE PTR [rax],al
	...

0000000000004700 <botlish_fn_50: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4700:	push   rbp
    4701:	mov    rbp,rsp
    4704:	sub    rsp,0x90
    470b:	mov    QWORD PTR [rsp+0x60],rbx
    4710:	mov    QWORD PTR [rsp+0x68],r12
    4715:	mov    QWORD PTR [rsp+0x70],r13
    471a:	mov    QWORD PTR [rsp+0x78],r14
    471f:	mov    QWORD PTR [rsp+0x80],r15
    4727:	mov    r13,r8
    472a:	mov    QWORD PTR [rsp+0x40],rdi
    472f:	mov    r11,QWORD PTR [rbp+0x10]
    4733:	mov    r15,QWORD PTR [rbp+0x18]
    4737:	mov    QWORD PTR [rsp+0x30],0x0
    4740:	mov    QWORD PTR [rsp+0x38],0x0
    4749:	mov    QWORD PTR [rsp],rsi
    474d:	mov    QWORD PTR [rsp+0x8],rdx
    4752:	mov    r12,rdx
    4755:	mov    QWORD PTR [rsp+0x10],rcx
    475a:	mov    r14,rcx
    475d:	mov    QWORD PTR [rsp+0x18],r9
    4762:	mov    QWORD PTR [rsp+0x20],r11
    4767:	mov    QWORD PTR [rsp+0x50],r11
    476c:	mov    QWORD PTR [rsp+0x28],r15
    4771:	mov    rbx,rsi
    4774:	mov    QWORD PTR [rsp+0x48],r9
    4779:	mov    rsi,rbx
    477c:	mov    rdi,QWORD PTR [rsp+0x40]
    4781:	call   4786 <botlish_fn_50+0x86>
			4782: R_X86_64_PLT32	rt_list_len-0x4
    4786:	mov    rcx,r12
    4789:	and    rcx,rax
    478c:	mov    rdx,rax
    478f:	test   rcx,0x1
    4796:	jne    47be <botlish_fn_50+0xbe>
    479c:	mov    rsi,r12
    479f:	mov    rdi,QWORD PTR [rsp+0x40]
    47a4:	call   47a9 <botlish_fn_50+0xa9>
			47a5: R_X86_64_PLT32	rt_int_cmp-0x4
    47a9:	mov    ecx,0x2
    47ae:	test   rax,rax
    47b1:	cmovge rcx,QWORD PTR [rip+0x177]        # 4930 <botlish_fn_50+0x230>
    47b9:	jmp    47ce <botlish_fn_50+0xce>
    47be:	mov    ecx,0x2
    47c3:	cmp    r12,rdx
    47c6:	cmovge rcx,QWORD PTR [rip+0x162]        # 4930 <botlish_fn_50+0x230>
    47ce:	cmp    rcx,0x6
    47d2:	je     48b9 <botlish_fn_50+0x1b9>
    47d8:	mov    rax,r13
    47db:	or     rax,0x1
    47df:	mov    QWORD PTR [rsp+0x30],rax
    47e4:	test   r12,0x1
    47eb:	je     4804 <botlish_fn_50+0x104>
    47f1:	mov    rcx,QWORD PTR [rbx+0x8]
    47f5:	mov    rax,r12
    47f8:	sar    rax,1
    47fb:	cmp    rax,rcx
    47fe:	jb     4825 <botlish_fn_50+0x125>
    4804:	mov    rdx,r12
    4807:	mov    rsi,rbx
    480a:	mov    rdi,QWORD PTR [rsp+0x40]
    480f:	call   4814 <botlish_fn_50+0x114>
			4810: R_X86_64_PLT32	rt_list_get-0x4
    4814:	test   rax,rax
    4817:	je     48d6 <botlish_fn_50+0x1d6>
    481d:	mov    rcx,rax
    4820:	jmp    482d <botlish_fn_50+0x12d>
    4825:	mov    rsi,QWORD PTR [rbx+0x10]
    4829:	mov    rcx,QWORD PTR [rsi+rax*8]
    482d:	mov    QWORD PTR [rsp+0x38],rcx
    4832:	mov    rdx,r13
    4835:	or     rdx,0x1
    4839:	mov    rsi,r14
    483c:	mov    rdi,QWORD PTR [rsp+0x40]
    4841:	mov    r8,r15
    4844:	call   4849 <botlish_fn_50+0x149>
			4845: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_table<any, int, any, bool>
    4849:	test   rax,rax
    484c:	je     48d6 <botlish_fn_50+0x1d6>
    4852:	mov    QWORD PTR [rsp+0x8],rax
    4857:	mov    rcx,rax
    485a:	sar    r12,1
    485d:	add    r12,0x1
    4864:	shl    r12,1
    4867:	or     r12,0x1
    486b:	mov    QWORD PTR [rsp+0x30],r12
    4870:	mov    rdx,QWORD PTR [rsp+0x50]
    4875:	mov    rsi,QWORD PTR [rsp+0x48]
    487a:	mov    rdi,QWORD PTR [rsp+0x40]
    487f:	call   4884 <botlish_fn_50+0x184>
			4880: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    4884:	test   rax,rax
    4887:	je     48d6 <botlish_fn_50+0x1d6>
    488d:	mov    QWORD PTR [rsp],rbx
    4891:	mov    QWORD PTR [rsp+0x8],r12
    4896:	mov    QWORD PTR [rsp+0x10],r14
    489b:	mov    QWORD PTR [rsp+0x18],rax
    48a0:	mov    QWORD PTR [rsp+0x20],rdx
    48a5:	mov    QWORD PTR [rsp+0x28],r15
    48aa:	mov    QWORD PTR [rsp+0x48],rax
    48af:	mov    QWORD PTR [rsp+0x50],rdx
    48b4:	jmp    4779 <botlish_fn_50+0x79>
    48b9:	mov    rdx,QWORD PTR [rsp+0x50]
    48be:	mov    rsi,QWORD PTR [rsp+0x48]
    48c3:	mov    rdi,QWORD PTR [rsp+0x40]
    48c8:	call   48cd <botlish_fn_50+0x1cd>
			48c9: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    48cd:	test   rax,rax
    48d0:	jne    4901 <botlish_fn_50+0x201>
    48d6:	xor    rax,rax
    48d9:	mov    rbx,QWORD PTR [rsp+0x60]
    48de:	mov    r12,QWORD PTR [rsp+0x68]
    48e3:	mov    r13,QWORD PTR [rsp+0x70]
    48e8:	mov    r14,QWORD PTR [rsp+0x78]
    48ed:	mov    r15,QWORD PTR [rsp+0x80]
    48f5:	add    rsp,0x90
    48fc:	mov    rsp,rbp
    48ff:	pop    rbp
    4900:	ret
    4901:	mov    rbx,QWORD PTR [rsp+0x60]
    4906:	mov    r12,QWORD PTR [rsp+0x68]
    490b:	mov    r13,QWORD PTR [rsp+0x70]
    4910:	mov    r14,QWORD PTR [rsp+0x78]
    4915:	mov    r15,QWORD PTR [rsp+0x80]
    491d:	add    rsp,0x90
    4924:	mov    rsp,rbp
    4927:	pop    rbp
    4928:	ret
    4929:	add    BYTE PTR [rax],al
    492b:	add    BYTE PTR [rax],al
    492d:	add    BYTE PTR [rax],al
    492f:	add    BYTE PTR [rsi],al
    4931:	add    BYTE PTR [rax],al
    4933:	add    BYTE PTR [rax],al
    4935:	add    BYTE PTR [rax],al
	...

0000000000004938 <botlish_entry_50: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4938:	push   rbp
    4939:	mov    rbp,rsp
    493c:	sub    rsp,0x10
    4940:	mov    rsi,QWORD PTR [rdx]
    4943:	mov    r10,QWORD PTR [rdx+0x8]
    4947:	mov    rcx,QWORD PTR [rdx+0x10]
    494b:	mov    r8,QWORD PTR [rdx+0x18]
    494f:	mov    r9,QWORD PTR [rdx+0x20]
    4953:	mov    r11,QWORD PTR [rdx+0x28]
    4957:	mov    rax,QWORD PTR [rdx+0x30]
    495b:	mov    QWORD PTR [rsp],r11
    495f:	mov    QWORD PTR [rsp+0x8],rax
    4964:	mov    rdx,r10
    4967:	call   496c <botlish_entry_50+0x34>
			4968: R_X86_64_PLT32	botlish_fn_50-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    496c:	add    rsp,0x10
    4970:	mov    rsp,rbp
    4973:	pop    rbp
    4974:	ret

0000000000004975 <botlish_fn_51: csv_records_generic<str, bool>>:
    4975:	push   rbp
    4976:	mov    rbp,rsp
    4979:	sub    rsp,0x80
    4980:	mov    QWORD PTR [rsp+0x50],rbx
    4985:	mov    QWORD PTR [rsp+0x58],r12
    498a:	mov    QWORD PTR [rsp+0x60],r13
    498f:	mov    QWORD PTR [rsp+0x68],r14
    4994:	mov    QWORD PTR [rsp+0x70],r15
    4999:	mov    rbx,rdi
    499c:	mov    QWORD PTR [rsp+0x20],0x0
    49a5:	mov    QWORD PTR [rsp+0x28],0x0
    49ae:	mov    QWORD PTR [rsp+0x30],0x0
    49b7:	mov    QWORD PTR [rsp+0x38],0x0
    49c0:	mov    QWORD PTR [rsp+0x40],0x0
    49c9:	mov    QWORD PTR [rsp+0x10],rsi
    49ce:	mov    QWORD PTR [rsp+0x18],rdx
    49d3:	mov    r12,rdx
    49d6:	mov    rdi,rbx
    49d9:	call   49de <botlish_fn_51+0x69>
			49da: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    49de:	mov    rcx,rax
    49e1:	mov    r13,rax
    49e4:	test   rax,rcx
    49e7:	je     4b2d <botlish_fn_51+0x1b8>
    49ed:	mov    rax,r13
    49f0:	mov    QWORD PTR [rsp+0x10],rax
    49f5:	mov    rsi,r13
    49f8:	mov    rdi,rbx
    49fb:	call   4a00 <botlish_fn_51+0x8b>
			49fc: R_X86_64_PLT32	rt_list_len-0x4
    4a00:	sar    rax,1
    4a03:	test   rax,rax
    4a06:	je     4b16 <botlish_fn_51+0x1a1>
    4a0c:	mov    rax,r13
    4a0f:	mov    rax,QWORD PTR [rax+0x8]
    4a13:	test   rax,rax
    4a16:	jne    4a3d <botlish_fn_51+0xc8>
    4a1c:	mov    edx,0x1
    4a21:	mov    rsi,r13
    4a24:	mov    rdi,rbx
    4a27:	call   4a2c <botlish_fn_51+0xb7>
			4a28: R_X86_64_PLT32	rt_list_get-0x4
    4a2c:	test   rax,rax
    4a2f:	je     4b2d <botlish_fn_51+0x1b8>
    4a35:	mov    rsi,rax
    4a38:	jmp    4a4a <botlish_fn_51+0xd5>
    4a3d:	mov    rax,r13
    4a40:	mov    rcx,QWORD PTR [rax+0x10]
    4a44:	mov    rax,QWORD PTR [rcx]
    4a47:	mov    rsi,rax
    4a4a:	mov    QWORD PTR [rsp+0x20],rsi
    4a4f:	mov    QWORD PTR [rsp+0x28],0x3
    4a58:	xor    eax,eax
    4a5a:	test   rsi,0x7
    4a61:	jne    4a70 <botlish_fn_51+0xfb>
    4a67:	movzx  rax,BYTE PTR [rsi]
    4a6b:	cmp    al,0x3
    4a6d:	sete   al
    4a70:	test   al,al
    4a72:	jne    4a92 <botlish_fn_51+0x11d>
    4a78:	mov    rdi,rbx
    4a7b:	mov    rax,QWORD PTR [rdi+0x10]
    4a7f:	mov    rcx,QWORD PTR [rax+0x58]
    4a83:	mov    edx,0x4
    4a88:	call   4a8d <botlish_fn_51+0x118>
			4a89: R_X86_64_PLT32	rt_type_error-0x4
    4a8d:	jmp    4b2d <botlish_fn_51+0x1b8>
    4a92:	mov    r14,rsi
    4a95:	mov    rdi,rbx
    4a98:	call   4a9d <botlish_fn_51+0x128>
			4a99: R_X86_64_PLT32	rt_list_len-0x4
    4a9d:	mov    QWORD PTR [rsp+0x30],rax
    4aa2:	mov    r15,rax
    4aa5:	mov    rdi,rbx
    4aa8:	call   4aad <botlish_fn_51+0x138>
			4aa9: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    4aad:	test   rax,rax
    4ab0:	je     4b2d <botlish_fn_51+0x1b8>
    4ab6:	mov    QWORD PTR [rsp+0x38],rax
    4abb:	mov    r9,rax
    4abe:	mov    QWORD PTR [rsp+0x40],rdx
    4ac3:	mov    rax,rdx
    4ac6:	mov    edx,0x3
    4acb:	mov    QWORD PTR [rsp],rax
    4acf:	mov    rax,r12
    4ad2:	mov    QWORD PTR [rsp+0x8],rax
    4ad7:	mov    rcx,r14
    4ada:	mov    rsi,r13
    4add:	mov    rdi,rbx
    4ae0:	mov    r8,r15
    4ae3:	call   4ae8 <botlish_fn_51+0x173>
			4ae4: R_X86_64_PLT32	botlish_fn_50-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4ae8:	test   rax,rax
    4aeb:	je     4b2d <botlish_fn_51+0x1b8>
    4af1:	mov    rbx,QWORD PTR [rsp+0x50]
    4af6:	mov    r12,QWORD PTR [rsp+0x58]
    4afb:	mov    r13,QWORD PTR [rsp+0x60]
    4b00:	mov    r14,QWORD PTR [rsp+0x68]
    4b05:	mov    r15,QWORD PTR [rsp+0x70]
    4b0a:	add    rsp,0x80
    4b11:	mov    rsp,rbp
    4b14:	pop    rbp
    4b15:	ret
    4b16:	xor    rdx,rdx
    4b19:	mov    rdi,rbx
    4b1c:	mov    rsi,rdx
    4b1f:	call   4b24 <botlish_fn_51+0x1af>
			4b20: R_X86_64_PLT32	rt_list_new-0x4
    4b24:	test   rax,rax
    4b27:	jne    4b55 <botlish_fn_51+0x1e0>
    4b2d:	xor    rax,rax
    4b30:	mov    rbx,QWORD PTR [rsp+0x50]
    4b35:	mov    r12,QWORD PTR [rsp+0x58]
    4b3a:	mov    r13,QWORD PTR [rsp+0x60]
    4b3f:	mov    r14,QWORD PTR [rsp+0x68]
    4b44:	mov    r15,QWORD PTR [rsp+0x70]
    4b49:	add    rsp,0x80
    4b50:	mov    rsp,rbp
    4b53:	pop    rbp
    4b54:	ret
    4b55:	mov    rbx,QWORD PTR [rsp+0x50]
    4b5a:	mov    r12,QWORD PTR [rsp+0x58]
    4b5f:	mov    r13,QWORD PTR [rsp+0x60]
    4b64:	mov    r14,QWORD PTR [rsp+0x68]
    4b69:	mov    r15,QWORD PTR [rsp+0x70]
    4b6e:	add    rsp,0x80
    4b75:	mov    rsp,rbp
    4b78:	pop    rbp
    4b79:	ret

0000000000004b7a <botlish_entry_51: csv_records_generic<str, bool>>:
    4b7a:	push   rbp
    4b7b:	mov    rbp,rsp
    4b7e:	mov    rsi,QWORD PTR [rdx]
    4b81:	mov    rdx,QWORD PTR [rdx+0x8]
    4b85:	call   4b8a <botlish_entry_51+0x10>
			4b86: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4b8a:	mov    rsp,rbp
    4b8d:	pop    rbp
    4b8e:	ret

0000000000004b8f <botlish_fn_52: csv_records<str>>:
    4b8f:	push   rbp
    4b90:	mov    rbp,rsp
    4b93:	sub    rsp,0x10
    4b97:	mov    QWORD PTR [rsp],rsi
    4b9b:	mov    edx,0x2
    4ba0:	mov    QWORD PTR [rsp+0x8],0x2
    4ba9:	call   4bae <botlish_fn_52+0x1f>
			4baa: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4bae:	test   rax,rax
    4bb1:	jne    4bc3 <botlish_fn_52+0x34>
    4bb7:	xor    rax,rax
    4bba:	add    rsp,0x10
    4bbe:	mov    rsp,rbp
    4bc1:	pop    rbp
    4bc2:	ret
    4bc3:	add    rsp,0x10
    4bc7:	mov    rsp,rbp
    4bca:	pop    rbp
    4bcb:	ret

0000000000004bcc <botlish_entry_52: csv_records<str>>:
    4bcc:	push   rbp
    4bcd:	mov    rbp,rsp
    4bd0:	mov    rsi,QWORD PTR [rdx]
    4bd3:	call   4bd8 <botlish_entry_52+0xc>
			4bd4: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records<str>
    4bd8:	mov    rsp,rbp
    4bdb:	pop    rbp
    4bdc:	ret

0000000000004bdd <botlish_fn_53: csv_records_presized<str>>:
    4bdd:	push   rbp
    4bde:	mov    rbp,rsp
    4be1:	sub    rsp,0x10
    4be5:	mov    QWORD PTR [rsp],rsi
    4be9:	mov    edx,0x6
    4bee:	mov    QWORD PTR [rsp+0x8],0x6
    4bf7:	call   4bfc <botlish_fn_53+0x1f>
			4bf8: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4bfc:	test   rax,rax
    4bff:	jne    4c11 <botlish_fn_53+0x34>
    4c05:	xor    rax,rax
    4c08:	add    rsp,0x10
    4c0c:	mov    rsp,rbp
    4c0f:	pop    rbp
    4c10:	ret
    4c11:	add    rsp,0x10
    4c15:	mov    rsp,rbp
    4c18:	pop    rbp
    4c19:	ret

0000000000004c1a <botlish_entry_53: csv_records_presized<str>>:
    4c1a:	push   rbp
    4c1b:	mov    rbp,rsp
    4c1e:	mov    rsi,QWORD PTR [rdx]
    4c21:	call   4c26 <botlish_entry_53+0xc>
			4c22: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_presized<str>
    4c26:	mov    rsp,rbp
    4c29:	pop    rbp
    4c2a:	ret
    4c2b:	add    BYTE PTR [rax],al
    4c2d:	add    BYTE PTR [rax],al
	...

0000000000004c30 <botlish_fn_54: sample<generic>>:
    4c30:	push   rbp
    4c31:	mov    rbp,rsp
    4c34:	sub    rsp,0xc0
    4c3b:	mov    QWORD PTR [rsp+0x90],rbx
    4c43:	mov    QWORD PTR [rsp+0x98],r12
    4c4b:	mov    QWORD PTR [rsp+0xa0],r13
    4c53:	mov    QWORD PTR [rsp+0xa8],r14
    4c5b:	mov    QWORD PTR [rsp+0xb0],r15
    4c63:	mov    QWORD PTR [rsp+0x8],0x0
    4c6c:	mov    QWORD PTR [rsp+0x10],0x0
    4c75:	mov    QWORD PTR [rsp+0x18],0x0
    4c7e:	mov    QWORD PTR [rsp+0x20],0x0
    4c87:	mov    QWORD PTR [rsp+0x28],0x0
    4c90:	mov    QWORD PTR [rsp+0x30],0x0
    4c99:	mov    QWORD PTR [rsp+0x38],0x0
    4ca2:	mov    rax,QWORD PTR [rdi+0x10]
    4ca6:	mov    r13,rdi
    4ca9:	mov    rsi,QWORD PTR [rax+0x60]
    4cad:	mov    QWORD PTR [rsp],rsi
    4cb1:	call   4cb6 <botlish_fn_54+0x86>
			4cb2: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records<str>
    4cb6:	mov    rsi,rax
    4cb9:	mov    r12,rax
    4cbc:	test   rax,rsi
    4cbf:	je     5044 <botlish_fn_54+0x414>
    4cc5:	mov    rax,r12
    4cc8:	mov    QWORD PTR [rsp],rax
    4ccc:	mov    rdi,r13
    4ccf:	mov    rax,QWORD PTR [rdi+0x10]
    4cd3:	mov    rsi,QWORD PTR [rax+0x60]
    4cd7:	mov    QWORD PTR [rsp+0x8],rsi
    4cdc:	call   4ce1 <botlish_fn_54+0xb1>
			4cdd: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_presized<str>
    4ce1:	mov    rbx,rax
    4ce4:	test   rbx,rbx
    4ce7:	je     5044 <botlish_fn_54+0x414>
    4ced:	mov    rax,r12
    4cf0:	mov    rax,QWORD PTR [rax+0x8]
    4cf4:	test   rax,rax
    4cf7:	jne    4d1e <botlish_fn_54+0xee>
    4cfd:	mov    edx,0x1
    4d02:	mov    rsi,r12
    4d05:	mov    rdi,r13
    4d08:	call   4d0d <botlish_fn_54+0xdd>
			4d09: R_X86_64_PLT32	rt_list_get-0x4
    4d0d:	test   rax,rax
    4d10:	je     5044 <botlish_fn_54+0x414>
    4d16:	mov    rsi,rax
    4d19:	jmp    4d26 <botlish_fn_54+0xf6>
    4d1e:	mov    rax,QWORD PTR [r12+0x10]
    4d23:	mov    rsi,QWORD PTR [rax]
    4d26:	mov    QWORD PTR [rsp+0x8],rsi
    4d2b:	mov    r15,rsi
    4d2e:	mov    rax,QWORD PTR [r12+0x8]
    4d33:	cmp    rax,0x1
    4d37:	ja     4d5e <botlish_fn_54+0x12e>
    4d3d:	mov    edx,0x3
    4d42:	mov    rsi,r12
    4d45:	mov    rdi,r13
    4d48:	call   4d4d <botlish_fn_54+0x11d>
			4d49: R_X86_64_PLT32	rt_list_get-0x4
    4d4d:	test   rax,rax
    4d50:	je     5044 <botlish_fn_54+0x414>
    4d56:	mov    rsi,rax
    4d59:	jmp    4d67 <botlish_fn_54+0x137>
    4d5e:	mov    rax,QWORD PTR [r12+0x10]
    4d63:	mov    rsi,QWORD PTR [rax+0x8]
    4d67:	mov    QWORD PTR [rsp+0x10],rsi
    4d6c:	mov    r14,rsi
    4d6f:	mov    rax,QWORD PTR [rbx+0x8]
    4d73:	mov    rsi,rbx
    4d76:	test   rax,rax
    4d79:	jne    4d9d <botlish_fn_54+0x16d>
    4d7f:	mov    edx,0x1
    4d84:	mov    rdi,r13
    4d87:	call   4d8c <botlish_fn_54+0x15c>
			4d88: R_X86_64_PLT32	rt_list_get-0x4
    4d8c:	test   rax,rax
    4d8f:	je     5044 <botlish_fn_54+0x414>
    4d95:	mov    rsi,rax
    4d98:	jmp    4da4 <botlish_fn_54+0x174>
    4d9d:	mov    rax,QWORD PTR [rsi+0x10]
    4da1:	mov    rsi,QWORD PTR [rax]
    4da4:	mov    QWORD PTR [rsp+0x18],rsi
    4da9:	mov    rdi,r13
    4dac:	mov    QWORD PTR [rsp+0x78],rsi
    4db1:	mov    rax,QWORD PTR [rdi+0x10]
    4db5:	mov    rdx,QWORD PTR [rax+0x68]
    4db9:	mov    QWORD PTR [rsp+0x20],rdx
    4dbe:	mov    rsi,r15
    4dc1:	call   4dc6 <botlish_fn_54+0x196>
			4dc2: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4dc6:	test   rax,rax
    4dc9:	je     5044 <botlish_fn_54+0x414>
    4dcf:	mov    QWORD PTR [rsp+0x20],rax
    4dd4:	mov    rbx,rax
    4dd7:	mov    rdi,r13
    4dda:	mov    rax,QWORD PTR [rdi+0x10]
    4dde:	mov    rdx,QWORD PTR [rax+0x68]
    4de2:	mov    QWORD PTR [rsp+0x28],rdx
    4de7:	mov    rsi,QWORD PTR [rsp+0x78]
    4dec:	call   4df1 <botlish_fn_54+0x1c1>
			4ded: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4df1:	test   rax,rax
    4df4:	je     5044 <botlish_fn_54+0x414>
    4dfa:	mov    rcx,rbx
    4dfd:	mov    rdx,rcx
    4e00:	and    rdx,rax
    4e03:	test   rdx,0x1
    4e0a:	jne    4e2c <botlish_fn_54+0x1fc>
    4e10:	mov    rdx,rax
    4e13:	mov    rsi,rbx
    4e16:	mov    rdi,r13
    4e19:	call   4e1e <botlish_fn_54+0x1ee>
			4e1a: R_X86_64_PLT32	rt_value_eq-0x4
    4e1e:	test   rax,rax
    4e21:	je     5044 <botlish_fn_54+0x414>
    4e27:	jmp    4e42 <botlish_fn_54+0x212>
    4e2c:	mov    rdx,rax
    4e2f:	mov    rsi,rbx
    4e32:	mov    eax,0x2
    4e37:	cmp    rsi,rdx
    4e3a:	cmove  rax,QWORD PTR [rip+0x26e]        # 50b0 <botlish_fn_54+0x480>
    4e42:	mov    ebx,0x6
    4e47:	cmp    rax,0x6
    4e4b:	je     4e66 <botlish_fn_54+0x236>
    4e51:	mov    ebx,0x2
    4e56:	mov    QWORD PTR [rsp],0x2
    4e5e:	mov    rsi,r12
    4e61:	jmp    4f05 <botlish_fn_54+0x2d5>
    4e66:	mov    rsi,r15
    4e69:	mov    rdi,r13
    4e6c:	call   4e71 <botlish_fn_54+0x241>
			4e6d: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    4e71:	test   rax,rax
    4e74:	mov    QWORD PTR [rsp+0x88],rax
    4e7c:	je     5044 <botlish_fn_54+0x414>
    4e82:	mov    rsi,QWORD PTR [rsp+0x78]
    4e87:	mov    rdi,r13
    4e8a:	call   4e8f <botlish_fn_54+0x25f>
			4e8b: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    4e8f:	test   rax,rax
    4e92:	je     5044 <botlish_fn_54+0x414>
    4e98:	mov    rcx,QWORD PTR [rsp+0x88]
    4ea0:	mov    rdx,rcx
    4ea3:	and    rdx,rax
    4ea6:	test   rdx,0x1
    4ead:	jne    4ed4 <botlish_fn_54+0x2a4>
    4eb3:	mov    rdx,rax
    4eb6:	mov    rsi,QWORD PTR [rsp+0x88]
    4ebe:	mov    rdi,r13
    4ec1:	call   4ec6 <botlish_fn_54+0x296>
			4ec2: R_X86_64_PLT32	rt_value_eq-0x4
    4ec6:	test   rax,rax
    4ec9:	je     5044 <botlish_fn_54+0x414>
    4ecf:	jmp    4eef <botlish_fn_54+0x2bf>
    4ed4:	mov    rdx,rax
    4ed7:	mov    rsi,QWORD PTR [rsp+0x88]
    4edf:	mov    eax,0x2
    4ee4:	cmp    rsi,rdx
    4ee7:	cmove  rax,QWORD PTR [rip+0x1c1]        # 50b0 <botlish_fn_54+0x480>
    4eef:	cmp    rax,0x6
    4ef3:	je     4efe <botlish_fn_54+0x2ce>
    4ef9:	mov    ebx,0x2
    4efe:	mov    QWORD PTR [rsp],rbx
    4f02:	mov    rsi,r12
    4f05:	mov    rdi,r13
    4f08:	call   4f0d <botlish_fn_54+0x2dd>
			4f09: R_X86_64_PLT32	rt_list_len-0x4
    4f0d:	mov    QWORD PTR [rsp+0x18],rax
    4f12:	mov    rdi,r13
    4f15:	mov    r12,rax
    4f18:	mov    rax,QWORD PTR [rdi+0x10]
    4f1c:	mov    rdx,QWORD PTR [rax+0x68]
    4f20:	mov    QWORD PTR [rsp+0x20],rdx
    4f25:	mov    rsi,r15
    4f28:	call   4f2d <botlish_fn_54+0x2fd>
			4f29: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4f2d:	test   rax,rax
    4f30:	je     5044 <botlish_fn_54+0x414>
    4f36:	mov    QWORD PTR [rsp+0x20],rax
    4f3b:	mov    rdi,r13
    4f3e:	mov    QWORD PTR [rsp+0x88],rax
    4f46:	mov    rax,QWORD PTR [rdi+0x10]
    4f4a:	mov    rdx,QWORD PTR [rax+0x70]
    4f4e:	mov    QWORD PTR [rsp+0x28],rdx
    4f53:	mov    rsi,r15
    4f56:	call   4f5b <botlish_fn_54+0x32b>
			4f57: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4f5b:	test   rax,rax
    4f5e:	je     5044 <botlish_fn_54+0x414>
    4f64:	mov    QWORD PTR [rsp+0x28],rax
    4f69:	mov    rdi,r13
    4f6c:	mov    QWORD PTR [rsp+0x80],rax
    4f74:	mov    rax,QWORD PTR [rdi+0x10]
    4f78:	mov    rdx,QWORD PTR [rax+0x78]
    4f7c:	mov    QWORD PTR [rsp+0x30],rdx
    4f81:	mov    rsi,r15
    4f84:	call   4f89 <botlish_fn_54+0x359>
			4f85: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4f89:	test   rax,rax
    4f8c:	je     5044 <botlish_fn_54+0x414>
    4f92:	mov    QWORD PTR [rsp+0x8],rax
    4f97:	mov    rdi,r13
    4f9a:	mov    r15,rax
    4f9d:	mov    rax,QWORD PTR [rdi+0x10]
    4fa1:	mov    rdx,QWORD PTR [rax+0x68]
    4fa5:	mov    QWORD PTR [rsp+0x30],rdx
    4faa:	mov    rsi,r14
    4fad:	call   4fb2 <botlish_fn_54+0x382>
			4fae: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4fb2:	test   rax,rax
    4fb5:	je     5044 <botlish_fn_54+0x414>
    4fbb:	mov    QWORD PTR [rsp+0x30],rax
    4fc0:	mov    rdi,r13
    4fc3:	mov    QWORD PTR [rsp+0x78],rax
    4fc8:	mov    rax,QWORD PTR [rdi+0x10]
    4fcc:	mov    rdx,QWORD PTR [rax+0x78]
    4fd0:	mov    QWORD PTR [rsp+0x38],rdx
    4fd5:	mov    rsi,r14
    4fd8:	call   4fdd <botlish_fn_54+0x3ad>
			4fd9: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4fdd:	test   rax,rax
    4fe0:	je     5044 <botlish_fn_54+0x414>
    4fe6:	mov    QWORD PTR [rsp+0x10],rax
    4feb:	lea    rdx,[rsp+0x40]
    4ff0:	mov    r9,r12
    4ff3:	mov    QWORD PTR [rsp+0x40],r9
    4ff8:	mov    rcx,QWORD PTR [rsp+0x88]
    5000:	mov    QWORD PTR [rsp+0x48],rcx
    5005:	mov    rcx,QWORD PTR [rsp+0x80]
    500d:	mov    QWORD PTR [rsp+0x50],rcx
    5012:	mov    rcx,r15
    5015:	mov    QWORD PTR [rsp+0x58],rcx
    501a:	mov    rcx,QWORD PTR [rsp+0x78]
    501f:	mov    QWORD PTR [rsp+0x60],rcx
    5024:	mov    QWORD PTR [rsp+0x68],rax
    5029:	mov    QWORD PTR [rsp+0x70],rbx
    502e:	mov    esi,0x7
    5033:	mov    rdi,r13
    5036:	call   503b <botlish_fn_54+0x40b>
			5037: R_X86_64_PLT32	rt_list_new-0x4
    503b:	test   rax,rax
    503e:	jne    507b <botlish_fn_54+0x44b>
    5044:	xor    rax,rax
    5047:	mov    rbx,QWORD PTR [rsp+0x90]
    504f:	mov    r12,QWORD PTR [rsp+0x98]
    5057:	mov    r13,QWORD PTR [rsp+0xa0]
    505f:	mov    r14,QWORD PTR [rsp+0xa8]
    5067:	mov    r15,QWORD PTR [rsp+0xb0]
    506f:	add    rsp,0xc0
    5076:	mov    rsp,rbp
    5079:	pop    rbp
    507a:	ret
    507b:	mov    rbx,QWORD PTR [rsp+0x90]
    5083:	mov    r12,QWORD PTR [rsp+0x98]
    508b:	mov    r13,QWORD PTR [rsp+0xa0]
    5093:	mov    r14,QWORD PTR [rsp+0xa8]
    509b:	mov    r15,QWORD PTR [rsp+0xb0]
    50a3:	add    rsp,0xc0
    50aa:	mov    rsp,rbp
    50ad:	pop    rbp
    50ae:	ret
    50af:	add    BYTE PTR [rsi],al
    50b1:	add    BYTE PTR [rax],al
    50b3:	add    BYTE PTR [rax],al
    50b5:	add    BYTE PTR [rax],al
	...

00000000000050b8 <botlish_entry_54: sample<generic>>:
    50b8:	push   rbp
    50b9:	mov    rbp,rsp
    50bc:	call   50c1 <botlish_entry_54+0x9>
			50bd: R_X86_64_PLT32	botlish_fn_54-0x4 ; sample<generic>
    50c1:	mov    rsp,rbp
    50c4:	pop    rbp
    50c5:	ret

; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 21526  (per function: 45 78 357 381 272 272 272 81 365 430 584 1063 351 695 456 171 388 524 70 493 114 61 125 61 125 61 125 61 125 61 168 168 179 179 245 245 804 1248 429 380 439 977 766 817 665 1168 836 107 618 335 528 580 78 78 1222)
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
    2ee3:	mov    QWORD PTR [rsp+0x58],rdi
    2ee8:	mov    r15,QWORD PTR [rbp+0x10]
    2eec:	mov    r12,QWORD PTR [rbp+0x18]
    2ef0:	mov    r13,QWORD PTR [rbp+0x20]
    2ef4:	mov    r14,QWORD PTR [rbp+0x28]
    2ef8:	mov    QWORD PTR [rsp+0x10],rsi
    2efd:	mov    QWORD PTR [rsp+0x60],rsi
    2f02:	mov    QWORD PTR [rsp+0x18],rdx
    2f07:	mov    QWORD PTR [rsp+0x68],rdx
    2f0c:	mov    QWORD PTR [rsp+0x20],rcx
    2f11:	mov    QWORD PTR [rsp+0x70],rcx
    2f16:	mov    QWORD PTR [rsp+0x28],r15
    2f1b:	mov    QWORD PTR [rsp+0x30],r12
    2f20:	mov    QWORD PTR [rsp+0x38],r13
    2f25:	mov    QWORD PTR [rsp+0x40],r14
    2f2a:	sar    r8,1
    2f2d:	sar    r9,1
    2f30:	mov    QWORD PTR [rsp+0x88],r9
    2f38:	mov    rcx,QWORD PTR [rsp+0x88]
    2f40:	mov    rbx,r8
    2f43:	cmp    rbx,rcx
    2f46:	mov    QWORD PTR [rsp+0x88],rcx
    2f4e:	jge    31b7 <botlish_fn_41+0x307>
    2f54:	xor    eax,eax
    2f56:	mov    rsi,QWORD PTR [rsp+0x60]
    2f5b:	test   rsi,0x7
    2f62:	jne    2f73 <botlish_fn_41+0xc3>
    2f68:	movzx  r10,BYTE PTR [rsi]
    2f6c:	cmp    r10b,0x8
    2f70:	sete   al
    2f73:	test   al,al
    2f75:	jne    2f97 <botlish_fn_41+0xe7>
    2f7b:	mov    rdi,QWORD PTR [rsp+0x58]
    2f80:	mov    rax,QWORD PTR [rdi+0x10]
    2f84:	mov    rcx,QWORD PTR [rax+0x20]
    2f88:	mov    edx,0x8
    2f8d:	call   2f92 <botlish_fn_41+0xe2>
			2f8e: R_X86_64_PLT32	rt_type_error-0x4
    2f92:	jmp    3135 <botlish_fn_41+0x285>
    2f97:	mov    QWORD PTR [rsp+0x60],rsi
    2f9c:	mov    rdx,rbx
    2f9f:	shl    rdx,1
    2fa2:	or     rdx,0x1
    2fa6:	mov    QWORD PTR [rsp+0x80],rdx
    2fae:	mov    rdi,QWORD PTR [rsp+0x58]
    2fb3:	call   2fb8 <botlish_fn_41+0x108>
			2fb4: R_X86_64_PLT32	rt_mutarray_get-0x4
    2fb8:	test   rax,rax
    2fbb:	je     3135 <botlish_fn_41+0x285>
    2fc1:	test   rax,0x1
    2fc7:	mov    rsi,rax
    2fca:	jne    2fed <botlish_fn_41+0x13d>
    2fd0:	mov    edx,0x3
    2fd5:	mov    rdi,QWORD PTR [rsp+0x58]
    2fda:	call   2fdf <botlish_fn_41+0x12f>
			2fdb: R_X86_64_PLT32	rt_value_eq-0x4
    2fdf:	test   rax,rax
    2fe2:	je     3135 <botlish_fn_41+0x285>
    2fe8:	jmp    2ffe <botlish_fn_41+0x14e>
    2fed:	mov    eax,0x2
    2ff2:	cmp    rsi,0x3
    2ff6:	cmove  rax,QWORD PTR [rip+0x1f2]        # 31f0 <botlish_fn_41+0x340>
    2ffe:	cmp    rax,0x6
    3002:	je     3012 <botlish_fn_41+0x162>
    3008:	mov    rsi,QWORD PTR [rsp+0x60]
    300d:	jmp    3171 <botlish_fn_41+0x2c1>
    3012:	xor    esi,esi
    3014:	mov    rdx,QWORD PTR [rsp+0x68]
    3019:	test   rdx,0x7
    3020:	je     3030 <botlish_fn_41+0x180>
    3026:	mov    QWORD PTR [rsp+0x68],rdx
    302b:	jmp    303f <botlish_fn_41+0x18f>
    3030:	movzx  rax,BYTE PTR [rdx]
    3034:	mov    QWORD PTR [rsp+0x68],rdx
    3039:	cmp    al,0x8
    303b:	sete   sil
    303f:	test   sil,sil
    3042:	jne    3069 <botlish_fn_41+0x1b9>
    3048:	mov    rdi,QWORD PTR [rsp+0x58]
    304d:	mov    rax,QWORD PTR [rdi+0x10]
    3051:	mov    rcx,QWORD PTR [rax+0x20]
    3055:	mov    edx,0x8
    305a:	mov    rsi,QWORD PTR [rsp+0x68]
    305f:	call   3064 <botlish_fn_41+0x1b4>
			3060: R_X86_64_PLT32	rt_type_error-0x4
    3064:	jmp    3135 <botlish_fn_41+0x285>
    3069:	mov    rdx,QWORD PTR [rsp+0x80]
    3071:	mov    rsi,QWORD PTR [rsp+0x68]
    3076:	mov    rdi,QWORD PTR [rsp+0x58]
    307b:	call   3080 <botlish_fn_41+0x1d0>
			307c: R_X86_64_PLT32	rt_mutarray_get-0x4
    3080:	test   rax,rax
    3083:	je     3135 <botlish_fn_41+0x285>
    3089:	mov    QWORD PTR [rsp+0x48],rax
    308e:	mov    QWORD PTR [rsp+0x78],rax
    3093:	xor    eax,eax
    3095:	mov    rcx,QWORD PTR [rsp+0x70]
    309a:	test   rcx,0x7
    30a1:	je     30b1 <botlish_fn_41+0x201>
    30a7:	mov    QWORD PTR [rsp+0x70],rcx
    30ac:	jmp    30bf <botlish_fn_41+0x20f>
    30b1:	movzx  rax,BYTE PTR [rcx]
    30b5:	mov    QWORD PTR [rsp+0x70],rcx
    30ba:	cmp    al,0x8
    30bc:	sete   al
    30bf:	test   al,al
    30c1:	jne    30e8 <botlish_fn_41+0x238>
    30c7:	mov    rdi,QWORD PTR [rsp+0x58]
    30cc:	mov    rax,QWORD PTR [rdi+0x10]
    30d0:	mov    rcx,QWORD PTR [rax+0x20]
    30d4:	mov    edx,0x8
    30d9:	mov    rsi,QWORD PTR [rsp+0x70]
    30de:	call   30e3 <botlish_fn_41+0x233>
			30df: R_X86_64_PLT32	rt_type_error-0x4
    30e3:	jmp    3135 <botlish_fn_41+0x285>
    30e8:	mov    rdx,QWORD PTR [rsp+0x80]
    30f0:	mov    rsi,QWORD PTR [rsp+0x70]
    30f5:	mov    rdi,QWORD PTR [rsp+0x58]
    30fa:	call   30ff <botlish_fn_41+0x24f>
			30fb: R_X86_64_PLT32	rt_mutarray_get-0x4
    30ff:	test   rax,rax
    3102:	je     3135 <botlish_fn_41+0x285>
    3108:	mov    QWORD PTR [rsp+0x50],rax
    310d:	mov    QWORD PTR [rsp],rax
    3111:	mov    r9,QWORD PTR [rsp+0x78]
    3116:	mov    rcx,r13
    3119:	mov    rdx,r12
    311c:	mov    rsi,r15
    311f:	mov    rdi,QWORD PTR [rsp+0x58]
    3124:	mov    r8,r14
    3127:	call   312c <botlish_fn_41+0x27c>
			3128: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_insert<List[mutarray], int, any, any>
    312c:	test   rax,rax
    312f:	jne    316c <botlish_fn_41+0x2bc>
    3135:	xor    rax,rax
    3138:	mov    rbx,QWORD PTR [rsp+0x90]
    3140:	mov    r12,QWORD PTR [rsp+0x98]
    3148:	mov    r13,QWORD PTR [rsp+0xa0]
    3150:	mov    r14,QWORD PTR [rsp+0xa8]
    3158:	mov    r15,QWORD PTR [rsp+0xb0]
    3160:	add    rsp,0xc0
    3167:	mov    rsp,rbp
    316a:	pop    rbp
    316b:	ret
    316c:	mov    rsi,QWORD PTR [rsp+0x60]
    3171:	mov    rsi,QWORD PTR [rsp+0x60]
    3176:	mov    QWORD PTR [rsp+0x10],rsi
    317b:	mov    rsi,QWORD PTR [rsp+0x68]
    3180:	mov    QWORD PTR [rsp+0x18],rsi
    3185:	mov    rsi,QWORD PTR [rsp+0x70]
    318a:	mov    QWORD PTR [rsp+0x20],rsi
    318f:	mov    QWORD PTR [rsp+0x28],r15
    3194:	mov    QWORD PTR [rsp+0x30],r12
    3199:	mov    QWORD PTR [rsp+0x38],r13
    319e:	mov    QWORD PTR [rsp+0x40],r14
    31a3:	add    rbx,0x1
    31aa:	mov    rcx,QWORD PTR [rsp+0x88]
    31b2:	jmp    2f43 <botlish_fn_41+0x93>
    31b7:	mov    eax,0xa
    31bc:	mov    rbx,QWORD PTR [rsp+0x90]
    31c4:	mov    r12,QWORD PTR [rsp+0x98]
    31cc:	mov    r13,QWORD PTR [rsp+0xa0]
    31d4:	mov    r14,QWORD PTR [rsp+0xa8]
    31dc:	mov    r15,QWORD PTR [rsp+0xb0]
    31e4:	add    rsp,0xc0
    31eb:	mov    rsp,rbp
    31ee:	pop    rbp
    31ef:	ret
    31f0:	(bad)
    31f1:	add    BYTE PTR [rax],al
    31f3:	add    BYTE PTR [rax],al
    31f5:	add    BYTE PTR [rax],al
	...

00000000000031f8 <botlish_entry_41: ht_rehash_scan<list, int, int, List[mutarray], int>>:
    31f8:	push   rbp
    31f9:	mov    rbp,rsp
    31fc:	sub    rsp,0x30
    3200:	mov    QWORD PTR [rsp+0x20],r12
    3205:	mov    rsi,QWORD PTR [rdx]
    3208:	mov    rax,QWORD PTR [rdx+0x8]
    320c:	mov    rcx,QWORD PTR [rdx+0x10]
    3210:	mov    r8,QWORD PTR [rdx+0x18]
    3214:	mov    r9,QWORD PTR [rdx+0x20]
    3218:	mov    r10,QWORD PTR [rdx+0x28]
    321c:	mov    r11,QWORD PTR [rdx+0x30]
    3220:	mov    r12,QWORD PTR [rdx+0x38]
    3224:	mov    rdx,QWORD PTR [rdx+0x40]
    3228:	mov    QWORD PTR [rsp],r10
    322c:	mov    QWORD PTR [rsp+0x8],r11
    3231:	mov    QWORD PTR [rsp+0x10],r12
    3236:	mov    QWORD PTR [rsp+0x18],rdx
    323b:	mov    rdx,rax
    323e:	call   3243 <botlish_entry_41+0x4b>
			323f: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    3243:	mov    r12,QWORD PTR [rsp+0x20]
    3248:	add    rsp,0x30
    324c:	mov    rsp,rbp
    324f:	pop    rbp
    3250:	ret

0000000000003251 <botlish_fn_42: ht_rehash<mutarray, int>>:
    3251:	push   rbp
    3252:	mov    rbp,rsp
    3255:	sub    rsp,0xd0
    325c:	mov    QWORD PTR [rsp+0xa0],rbx
    3264:	mov    QWORD PTR [rsp+0xa8],r12
    326c:	mov    QWORD PTR [rsp+0xb0],r13
    3274:	mov    QWORD PTR [rsp+0xb8],r14
    327c:	mov    QWORD PTR [rsp+0xc0],r15
    3284:	mov    r13,rdi
    3287:	mov    QWORD PTR [rsp+0x50],0x0
    3290:	mov    QWORD PTR [rsp+0x58],0x0
    3299:	mov    QWORD PTR [rsp+0x60],0x0
    32a2:	mov    QWORD PTR [rsp+0x68],0x0
    32ab:	mov    QWORD PTR [rsp+0x20],rsi
    32b0:	mov    r12,rsi
    32b3:	mov    QWORD PTR [rsp+0x28],rdx
    32b8:	mov    rbx,rdx
    32bb:	mov    rsi,r12
    32be:	mov    rdi,r13
    32c1:	call   32c6 <botlish_fn_42+0x75>
			32c2: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    32c6:	test   rax,rax
    32c9:	je     3498 <botlish_fn_42+0x247>
    32cf:	mov    QWORD PTR [rsp+0x30],rax
    32d4:	mov    r14,rax
    32d7:	mov    rsi,r12
    32da:	mov    rdi,r13
    32dd:	call   32e2 <botlish_fn_42+0x91>
			32de: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    32e2:	test   rax,rax
    32e5:	je     3498 <botlish_fn_42+0x247>
    32eb:	mov    QWORD PTR [rsp+0x38],rax
    32f0:	mov    r15,rax
    32f3:	mov    rsi,r12
    32f6:	mov    rdi,r13
    32f9:	call   32fe <botlish_fn_42+0xad>
			32fa: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    32fe:	test   rax,rax
    3301:	je     3498 <botlish_fn_42+0x247>
    3307:	mov    QWORD PTR [rsp+0x40],rax
    330c:	mov    QWORD PTR [rsp+0x90],rax
    3314:	mov    rsi,r12
    3317:	mov    rdi,r13
    331a:	call   331f <botlish_fn_42+0xce>
			331b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    331f:	test   rax,rax
    3322:	je     3498 <botlish_fn_42+0x247>
    3328:	mov    QWORD PTR [rsp+0x48],rax
    332d:	mov    QWORD PTR [rsp+0x88],rax
    3335:	mov    rsi,rbx
    3338:	mov    rdi,r13
    333b:	call   3340 <botlish_fn_42+0xef>
			333c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3340:	mov    rcx,rax
    3343:	mov    QWORD PTR [rsp+0x80],rax
    334b:	test   rax,rcx
    334e:	je     3498 <botlish_fn_42+0x247>
    3354:	mov    rax,QWORD PTR [rsp+0x80]
    335c:	mov    QWORD PTR [rsp+0x50],rax
    3361:	mov    edx,0x1
    3366:	mov    QWORD PTR [rsp+0x58],0x1
    336f:	mov    rcx,rbx
    3372:	mov    rsi,QWORD PTR [rsp+0x80]
    337a:	mov    rdi,r13
    337d:	call   3382 <botlish_fn_42+0x131>
			337e: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_fill_empty<mutarray, int, int>
    3382:	test   rax,rax
    3385:	je     3498 <botlish_fn_42+0x247>
    338b:	mov    rsi,rbx
    338e:	mov    rdi,r13
    3391:	call   3396 <botlish_fn_42+0x145>
			3392: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3396:	test   rax,rax
    3399:	je     3498 <botlish_fn_42+0x247>
    339f:	mov    QWORD PTR [rsp+0x58],rax
    33a4:	mov    QWORD PTR [rsp+0x78],rax
    33a9:	mov    rsi,rbx
    33ac:	mov    rdi,r13
    33af:	call   33b4 <botlish_fn_42+0x163>
			33b0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    33b4:	test   rax,rax
    33b7:	je     3498 <botlish_fn_42+0x247>
    33bd:	mov    QWORD PTR [rsp+0x60],rax
    33c2:	mov    r8d,0x1
    33c8:	mov    QWORD PTR [rsp+0x68],0x1
    33d1:	mov    rcx,QWORD PTR [rsp+0x80]
    33d9:	mov    QWORD PTR [rsp],rcx
    33dd:	mov    rcx,QWORD PTR [rsp+0x78]
    33e2:	mov    QWORD PTR [rsp+0x8],rcx
    33e7:	mov    QWORD PTR [rsp+0x10],rax
    33ec:	mov    QWORD PTR [rsp+0x70],rax
    33f1:	mov    QWORD PTR [rsp+0x18],rbx
    33f6:	mov    rcx,QWORD PTR [rsp+0x90]
    33fe:	mov    rdx,r15
    3401:	mov    rsi,r14
    3404:	mov    r9,QWORD PTR [rsp+0x88]
    340c:	mov    rdi,r13
    340f:	call   3414 <botlish_fn_42+0x1c3>
			3410: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    3414:	test   rax,rax
    3417:	je     3498 <botlish_fn_42+0x247>
    341d:	mov    edx,0x1
    3422:	mov    rcx,QWORD PTR [rsp+0x80]
    342a:	mov    rsi,r12
    342d:	mov    rdi,r13
    3430:	call   3435 <botlish_fn_42+0x1e4>
			3431: R_X86_64_PLT32	rt_mutarray_set-0x4
    3435:	test   rax,rax
    3438:	je     3498 <botlish_fn_42+0x247>
    343e:	mov    edx,0x3
    3443:	mov    rcx,QWORD PTR [rsp+0x78]
    3448:	mov    rsi,r12
    344b:	mov    rdi,r13
    344e:	call   3453 <botlish_fn_42+0x202>
			344f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3453:	test   rax,rax
    3456:	je     3498 <botlish_fn_42+0x247>
    345c:	mov    edx,0x5
    3461:	mov    rcx,QWORD PTR [rsp+0x70]
    3466:	mov    rsi,r12
    3469:	mov    rdi,r13
    346c:	call   3471 <botlish_fn_42+0x220>
			346d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3471:	test   rax,rax
    3474:	je     3498 <botlish_fn_42+0x247>
    347a:	mov    edx,0x9
    347f:	mov    ecx,0x1
    3484:	mov    rsi,r12
    3487:	mov    rdi,r13
    348a:	call   348f <botlish_fn_42+0x23e>
			348b: R_X86_64_PLT32	rt_mutarray_set-0x4
    348f:	test   rax,rax
    3492:	jne    34cf <botlish_fn_42+0x27e>
    3498:	xor    rax,rax
    349b:	mov    rbx,QWORD PTR [rsp+0xa0]
    34a3:	mov    r12,QWORD PTR [rsp+0xa8]
    34ab:	mov    r13,QWORD PTR [rsp+0xb0]
    34b3:	mov    r14,QWORD PTR [rsp+0xb8]
    34bb:	mov    r15,QWORD PTR [rsp+0xc0]
    34c3:	add    rsp,0xd0
    34ca:	mov    rsp,rbp
    34cd:	pop    rbp
    34ce:	ret
    34cf:	mov    eax,0xa
    34d4:	mov    rbx,QWORD PTR [rsp+0xa0]
    34dc:	mov    r12,QWORD PTR [rsp+0xa8]
    34e4:	mov    r13,QWORD PTR [rsp+0xb0]
    34ec:	mov    r14,QWORD PTR [rsp+0xb8]
    34f4:	mov    r15,QWORD PTR [rsp+0xc0]
    34fc:	add    rsp,0xd0
    3503:	mov    rsp,rbp
    3506:	pop    rbp
    3507:	ret

0000000000003508 <botlish_entry_42: ht_rehash<mutarray, int>>:
    3508:	push   rbp
    3509:	mov    rbp,rsp
    350c:	mov    rsi,QWORD PTR [rdx]
    350f:	mov    rdx,QWORD PTR [rdx+0x8]
    3513:	call   3518 <botlish_entry_42+0x10>
			3514: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    3518:	mov    rsp,rbp
    351b:	pop    rbp
    351c:	ret
    351d:	add    BYTE PTR [rax],al
	...

0000000000003520 <botlish_fn_43: ht_should_grow<mutarray>>:
    3520:	push   rbp
    3521:	mov    rbp,rsp
    3524:	sub    rsp,0x40
    3528:	mov    QWORD PTR [rsp+0x20],rbx
    352d:	mov    QWORD PTR [rsp+0x28],r12
    3532:	mov    QWORD PTR [rsp+0x30],r13
    3537:	mov    rbx,rdi
    353a:	mov    QWORD PTR [rsp],rsi
    353e:	mov    r12,rsi
    3541:	mov    rsi,r12
    3544:	mov    rdi,rbx
    3547:	call   354c <botlish_fn_43+0x2c>
			3548: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    354c:	mov    rcx,rax
    354f:	mov    r13,rax
    3552:	test   rax,rcx
    3555:	je     3744 <botlish_fn_43+0x224>
    355b:	mov    rax,r13
    355e:	mov    QWORD PTR [rsp+0x8],rax
    3563:	mov    rsi,r12
    3566:	mov    rdi,rbx
    3569:	call   356e <botlish_fn_43+0x4e>
			356a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    356e:	mov    rcx,rax
    3571:	test   rcx,rcx
    3574:	je     3744 <botlish_fn_43+0x224>
    357a:	mov    QWORD PTR [rsp+0x10],rcx
    357f:	mov    edx,0x1
    3584:	mov    rax,r13
    3587:	test   rax,0x1
    358d:	jne    35b0 <botlish_fn_43+0x90>
    3593:	xor    edx,edx
    3595:	mov    rax,r13
    3598:	test   rax,0x7
    359e:	jne    35b0 <botlish_fn_43+0x90>
    35a4:	mov    rax,r13
    35a7:	movzx  rax,BYTE PTR [rax]
    35ab:	cmp    al,0x1
    35ad:	sete   dl
    35b0:	test   dl,dl
    35b2:	jne    35d3 <botlish_fn_43+0xb3>
    35b8:	mov    rdi,rbx
    35bb:	mov    rax,QWORD PTR [rdi+0x10]
    35bf:	mov    rcx,QWORD PTR [rax+0x30]
    35c3:	xor    rdx,rdx
    35c6:	mov    rsi,r13
    35c9:	call   35ce <botlish_fn_43+0xae>
			35ca: R_X86_64_PLT32	rt_type_error-0x4
    35ce:	jmp    3744 <botlish_fn_43+0x224>
    35d3:	mov    eax,0x1
    35d8:	test   rcx,0x1
    35df:	je     35ed <botlish_fn_43+0xcd>
    35e5:	mov    r8,rcx
    35e8:	jmp    3610 <botlish_fn_43+0xf0>
    35ed:	xor    eax,eax
    35ef:	test   rcx,0x7
    35f6:	je     3604 <botlish_fn_43+0xe4>
    35fc:	mov    r8,rcx
    35ff:	jmp    3610 <botlish_fn_43+0xf0>
    3604:	movzx  rax,BYTE PTR [rcx]
    3608:	mov    r8,rcx
    360b:	cmp    al,0x1
    360d:	sete   al
    3610:	test   al,al
    3612:	jne    3633 <botlish_fn_43+0x113>
    3618:	mov    rdi,rbx
    361b:	mov    rax,QWORD PTR [rdi+0x10]
    361f:	mov    rcx,QWORD PTR [rax+0x30]
    3623:	xor    rdx,rdx
    3626:	mov    rsi,r8
    3629:	call   362e <botlish_fn_43+0x10e>
			362a: R_X86_64_PLT32	rt_type_error-0x4
    362e:	jmp    3744 <botlish_fn_43+0x224>
    3633:	mov    rcx,r8
    3636:	mov    rsi,r13
    3639:	mov    rax,rsi
    363c:	and    rax,rcx
    363f:	test   rax,0x1
    3645:	jne    3656 <botlish_fn_43+0x136>
    364b:	mov    rdx,r8
    364e:	mov    rsi,r13
    3651:	jmp    3674 <botlish_fn_43+0x154>
    3656:	mov    rcx,r8
    3659:	lea    rax,[rcx-0x1]
    365d:	mov    rsi,r13
    3660:	add    rsi,rax
    3663:	seto   al
    3666:	test   al,al
    3668:	je     367f <botlish_fn_43+0x15f>
    366e:	mov    rdx,r8
    3671:	mov    rsi,r13
    3674:	mov    rdi,rbx
    3677:	call   367c <botlish_fn_43+0x15c>
			3678: R_X86_64_PLT32	rt_int_add-0x4
    367c:	mov    rsi,rax
    367f:	mov    QWORD PTR [rsp+0x8],rsi
    3684:	mov    QWORD PTR [rsp+0x10],0x3
    368d:	test   rsi,0x1
    3694:	je     36b7 <botlish_fn_43+0x197>
    369a:	mov    rax,rsi
    369d:	add    rax,0x2
    36a1:	mov    rcx,rax
    36a4:	seto   al
    36a7:	test   al,al
    36a9:	jne    36b7 <botlish_fn_43+0x197>
    36af:	mov    rsi,rcx
    36b2:	jmp    36c7 <botlish_fn_43+0x1a7>
    36b7:	mov    edx,0x3
    36bc:	mov    rdi,rbx
    36bf:	call   36c4 <botlish_fn_43+0x1a4>
			36c0: R_X86_64_PLT32	rt_int_add-0x4
    36c4:	mov    rsi,rax
    36c7:	mov    QWORD PTR [rsp+0x8],rsi
    36cc:	mov    edx,0x7
    36d1:	mov    rdi,rdx
    36d4:	mov    QWORD PTR [rsp+0x10],0x7
    36dd:	test   rsi,0x1
    36e4:	jne    36f2 <botlish_fn_43+0x1d2>
    36ea:	mov    rdx,rdi
    36ed:	jmp    371e <botlish_fn_43+0x1fe>
    36f2:	mov    rax,rsi
    36f5:	sar    rax,1
    36f8:	imul   QWORD PTR [rip+0x119]        # 3818 <botlish_fn_43+0x2f8>
    36ff:	seto   cl
    3702:	or     rax,0x1
    3706:	test   cl,cl
    3708:	je     3716 <botlish_fn_43+0x1f6>
    370e:	mov    rdx,rdi
    3711:	jmp    371e <botlish_fn_43+0x1fe>
    3716:	mov    rsi,rax
    3719:	jmp    3729 <botlish_fn_43+0x209>
    371e:	mov    rdi,rbx
    3721:	call   3726 <botlish_fn_43+0x206>
			3722: R_X86_64_PLT32	rt_int_mul-0x4
    3726:	mov    rsi,rax
    3729:	mov    QWORD PTR [rsp],rsi
    372d:	mov    r13,rsi
    3730:	mov    rsi,r12
    3733:	mov    rdi,rbx
    3736:	call   373b <botlish_fn_43+0x21b>
			3737: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    373b:	test   rax,rax
    373e:	jne    375f <botlish_fn_43+0x23f>
    3744:	xor    rax,rax
    3747:	mov    rbx,QWORD PTR [rsp+0x20]
    374c:	mov    r12,QWORD PTR [rsp+0x28]
    3751:	mov    r13,QWORD PTR [rsp+0x30]
    3756:	add    rsp,0x40
    375a:	mov    rsp,rbp
    375d:	pop    rbp
    375e:	ret
    375f:	mov    QWORD PTR [rsp+0x8],rax
    3764:	mov    QWORD PTR [rsp+0x10],0x5
    376d:	test   rax,0x1
    3773:	mov    rsi,rax
    3776:	je     37a8 <botlish_fn_43+0x288>
    377c:	mov    rcx,rsi
    377f:	mov    rax,rcx
    3782:	sar    rax,1
    3785:	imul   QWORD PTR [rip+0x94]        # 3820 <botlish_fn_43+0x300>
    378c:	seto   dil
    3790:	or     rax,0x1
    3794:	test   dil,dil
    3797:	jne    37a8 <botlish_fn_43+0x288>
    379d:	mov    rdx,rax
    37a0:	mov    rsi,r13
    37a3:	jmp    37bb <botlish_fn_43+0x29b>
    37a8:	mov    edx,0x5
    37ad:	mov    rdi,rbx
    37b0:	call   37b5 <botlish_fn_43+0x295>
			37b1: R_X86_64_PLT32	rt_int_mul-0x4
    37b5:	mov    rdx,rax
    37b8:	mov    rsi,r13
    37bb:	mov    r10,rsi
    37be:	and    r10,rdx
    37c1:	test   r10,0x1
    37c8:	jne    37ef <botlish_fn_43+0x2cf>
    37ce:	mov    rdi,rbx
    37d1:	call   37d6 <botlish_fn_43+0x2b6>
			37d2: R_X86_64_PLT32	rt_int_cmp-0x4
    37d6:	mov    r8d,0x2
    37dc:	test   rax,rax
    37df:	mov    rax,r8
    37e2:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3818 <botlish_fn_43+0x2f8>
    37ea:	jmp    37ff <botlish_fn_43+0x2df>
    37ef:	mov    eax,0x2
    37f4:	cmp    rsi,rdx
    37f7:	cmovg  rax,QWORD PTR [rip+0x19]        # 3818 <botlish_fn_43+0x2f8>
    37ff:	mov    rbx,QWORD PTR [rsp+0x20]
    3804:	mov    r12,QWORD PTR [rsp+0x28]
    3809:	mov    r13,QWORD PTR [rsp+0x30]
    380e:	add    rsp,0x40
    3812:	mov    rsp,rbp
    3815:	pop    rbp
    3816:	ret
    3817:	add    BYTE PTR [rsi],al
    3819:	add    BYTE PTR [rax],al
    381b:	add    BYTE PTR [rax],al
    381d:	add    BYTE PTR [rax],al
    381f:	add    BYTE PTR [rax+rax*1],al
    3822:	add    BYTE PTR [rax],al
    3824:	add    BYTE PTR [rax],al
	...

0000000000003828 <botlish_entry_43: ht_should_grow<mutarray>>:
    3828:	push   rbp
    3829:	mov    rbp,rsp
    382c:	mov    rsi,QWORD PTR [rdx]
    382f:	call   3834 <botlish_entry_43+0xc>
			3830: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_should_grow<mutarray>
    3834:	mov    rsp,rbp
    3837:	pop    rbp
    3838:	ret
    3839:	add    BYTE PTR [rax],al
    383b:	add    BYTE PTR [rax],al
    383d:	add    BYTE PTR [rax],al
	...

0000000000003840 <botlish_fn_44: ht_grow_or_clean<mutarray>>:
    3840:	push   rbp
    3841:	mov    rbp,rsp
    3844:	sub    rsp,0x40
    3848:	mov    QWORD PTR [rsp+0x20],rbx
    384d:	mov    QWORD PTR [rsp+0x28],r12
    3852:	mov    QWORD PTR [rsp+0x30],r13
    3857:	mov    rbx,rdi
    385a:	mov    QWORD PTR [rsp+0x10],0x0
    3863:	mov    QWORD PTR [rsp],rsi
    3867:	mov    r12,rsi
    386a:	mov    rsi,r12
    386d:	mov    rdi,rbx
    3870:	call   3875 <botlish_fn_44+0x35>
			3871: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    3875:	test   rax,rax
    3878:	mov    r13,rax
    387b:	je     3a68 <botlish_fn_44+0x228>
    3881:	mov    rsi,r12
    3884:	mov    rdi,rbx
    3887:	call   388c <botlish_fn_44+0x4c>
			3888: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    388c:	mov    rcx,rax
    388f:	test   rcx,rcx
    3892:	je     3a68 <botlish_fn_44+0x228>
    3898:	mov    edx,0x1
    389d:	mov    rax,r13
    38a0:	test   rax,0x1
    38a6:	je     38b4 <botlish_fn_44+0x74>
    38ac:	mov    r13,rax
    38af:	jmp    38d8 <botlish_fn_44+0x98>
    38b4:	xor    edx,edx
    38b6:	test   rax,0x7
    38bc:	je     38ca <botlish_fn_44+0x8a>
    38c2:	mov    r13,rax
    38c5:	jmp    38d8 <botlish_fn_44+0x98>
    38ca:	movzx  rdx,BYTE PTR [rax]
    38ce:	mov    r13,rax
    38d1:	rex cmp dl,0x1
    38d5:	sete   dl
    38d8:	test   dl,dl
    38da:	jne    38fb <botlish_fn_44+0xbb>
    38e0:	mov    rdi,rbx
    38e3:	mov    rsi,QWORD PTR [rdi+0x10]
    38e7:	mov    rcx,QWORD PTR [rsi+0x38]
    38eb:	xor    rdx,rdx
    38ee:	mov    rsi,r13
    38f1:	call   38f6 <botlish_fn_44+0xb6>
			38f2: R_X86_64_PLT32	rt_type_error-0x4
    38f6:	jmp    3a68 <botlish_fn_44+0x228>
    38fb:	mov    rsi,r13
    38fe:	mov    eax,0x1
    3903:	test   rcx,0x1
    390a:	je     3918 <botlish_fn_44+0xd8>
    3910:	mov    r8,rcx
    3913:	jmp    393d <botlish_fn_44+0xfd>
    3918:	xor    eax,eax
    391a:	test   rcx,0x7
    3921:	je     392f <botlish_fn_44+0xef>
    3927:	mov    r8,rcx
    392a:	jmp    393d <botlish_fn_44+0xfd>
    392f:	movzx  r11,BYTE PTR [rcx]
    3933:	mov    r8,rcx
    3936:	cmp    r11b,0x1
    393a:	sete   al
    393d:	test   al,al
    393f:	jne    3960 <botlish_fn_44+0x120>
    3945:	mov    rdi,rbx
    3948:	mov    rax,QWORD PTR [rdi+0x10]
    394c:	mov    rcx,QWORD PTR [rax+0x38]
    3950:	xor    rdx,rdx
    3953:	mov    rsi,r8
    3956:	call   395b <botlish_fn_44+0x11b>
			3957: R_X86_64_PLT32	rt_type_error-0x4
    395b:	jmp    3a68 <botlish_fn_44+0x228>
    3960:	mov    rcx,r8
    3963:	mov    rax,rsi
    3966:	and    rax,rcx
    3969:	test   rax,0x1
    396f:	jne    3995 <botlish_fn_44+0x155>
    3975:	mov    rdx,r8
    3978:	mov    rdi,rbx
    397b:	call   3980 <botlish_fn_44+0x140>
			397c: R_X86_64_PLT32	rt_int_cmp-0x4
    3980:	mov    ecx,0x2
    3985:	test   rax,rax
    3988:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3aa0 <botlish_fn_44+0x260>
    3990:	jmp    39a8 <botlish_fn_44+0x168>
    3995:	mov    ecx,0x2
    399a:	mov    r9,r8
    399d:	cmp    rsi,r9
    39a0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3aa0 <botlish_fn_44+0x260>
    39a8:	cmp    rcx,0x6
    39ac:	je     3a38 <botlish_fn_44+0x1f8>
    39b2:	mov    rsi,r12
    39b5:	mov    rdi,rbx
    39b8:	call   39bd <botlish_fn_44+0x17d>
			39b9: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    39bd:	test   rax,rax
    39c0:	je     3a68 <botlish_fn_44+0x228>
    39c6:	mov    QWORD PTR [rsp+0x8],rax
    39cb:	mov    QWORD PTR [rsp+0x10],0x5
    39d4:	test   rax,0x1
    39da:	mov    rsi,rax
    39dd:	je     3a0a <botlish_fn_44+0x1ca>
    39e3:	mov    rcx,rsi
    39e6:	mov    rax,rcx
    39e9:	sar    rax,1
    39ec:	imul   QWORD PTR [rip+0xb5]        # 3aa8 <botlish_fn_44+0x268>
    39f3:	seto   cl
    39f6:	or     rax,0x1
    39fa:	test   cl,cl
    39fc:	jne    3a0a <botlish_fn_44+0x1ca>
    3a02:	mov    rdx,rax
    3a05:	jmp    3a1a <botlish_fn_44+0x1da>
    3a0a:	mov    edx,0x5
    3a0f:	mov    rdi,rbx
    3a12:	call   3a17 <botlish_fn_44+0x1d7>
			3a13: R_X86_64_PLT32	rt_int_mul-0x4
    3a17:	mov    rdx,rax
    3a1a:	mov    QWORD PTR [rsp+0x8],rdx
    3a1f:	mov    rsi,r12
    3a22:	mov    rdi,rbx
    3a25:	call   3a2a <botlish_fn_44+0x1ea>
			3a26: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    3a2a:	test   rax,rax
    3a2d:	je     3a68 <botlish_fn_44+0x228>
    3a33:	jmp    3a83 <botlish_fn_44+0x243>
    3a38:	mov    rsi,r12
    3a3b:	mov    rdi,rbx
    3a3e:	call   3a43 <botlish_fn_44+0x203>
			3a3f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_capacity<mutarray>
    3a43:	test   rax,rax
    3a46:	je     3a68 <botlish_fn_44+0x228>
    3a4c:	mov    QWORD PTR [rsp+0x8],rax
    3a51:	mov    rdx,rax
    3a54:	mov    rsi,r12
    3a57:	mov    rdi,rbx
    3a5a:	call   3a5f <botlish_fn_44+0x21f>
			3a5b: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash<mutarray, int>
    3a5f:	test   rax,rax
    3a62:	jne    3a83 <botlish_fn_44+0x243>
    3a68:	xor    rax,rax
    3a6b:	mov    rbx,QWORD PTR [rsp+0x20]
    3a70:	mov    r12,QWORD PTR [rsp+0x28]
    3a75:	mov    r13,QWORD PTR [rsp+0x30]
    3a7a:	add    rsp,0x40
    3a7e:	mov    rsp,rbp
    3a81:	pop    rbp
    3a82:	ret
    3a83:	mov    rbx,QWORD PTR [rsp+0x20]
    3a88:	mov    r12,QWORD PTR [rsp+0x28]
    3a8d:	mov    r13,QWORD PTR [rsp+0x30]
    3a92:	add    rsp,0x40
    3a96:	mov    rsp,rbp
    3a99:	pop    rbp
    3a9a:	ret
    3a9b:	add    BYTE PTR [rax],al
    3a9d:	add    BYTE PTR [rax],al
    3a9f:	add    BYTE PTR [rsi],al
    3aa1:	add    BYTE PTR [rax],al
    3aa3:	add    BYTE PTR [rax],al
    3aa5:	add    BYTE PTR [rax],al
    3aa7:	add    BYTE PTR [rax+rax*1],al
    3aaa:	add    BYTE PTR [rax],al
    3aac:	add    BYTE PTR [rax],al
	...

0000000000003ab0 <botlish_entry_44: ht_grow_or_clean<mutarray>>:
    3ab0:	push   rbp
    3ab1:	mov    rbp,rsp
    3ab4:	mov    rsi,QWORD PTR [rdx]
    3ab7:	call   3abc <botlish_entry_44+0xc>
			3ab8: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_grow_or_clean<mutarray>
    3abc:	mov    rsp,rbp
    3abf:	pop    rbp
    3ac0:	ret
    3ac1:	add    BYTE PTR [rax],al
    3ac3:	add    BYTE PTR [rax],al
    3ac5:	add    BYTE PTR [rax],al
	...

0000000000003ac8 <botlish_fn_45: ht_place<mutarray, int, any, any>>:
    3ac8:	push   rbp
    3ac9:	mov    rbp,rsp
    3acc:	sub    rsp,0x70
    3ad0:	mov    QWORD PTR [rsp+0x40],rbx
    3ad5:	mov    QWORD PTR [rsp+0x48],r12
    3ada:	mov    QWORD PTR [rsp+0x50],r13
    3adf:	mov    QWORD PTR [rsp+0x58],r14
    3ae4:	mov    QWORD PTR [rsp+0x60],r15
    3ae9:	mov    rbx,rdi
    3aec:	mov    r14,r8
    3aef:	mov    r15,rdx
    3af2:	mov    QWORD PTR [rsp+0x28],rcx
    3af7:	mov    QWORD PTR [rsp],rsi
    3afb:	mov    r12,rsi
    3afe:	mov    rsi,r12
    3b01:	mov    rdi,rbx
    3b04:	call   3b09 <botlish_fn_45+0x41>
			3b05: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    3b09:	test   rax,rax
    3b0c:	je     3e72 <botlish_fn_45+0x3aa>
    3b12:	xor    ecx,ecx
    3b14:	test   rax,0x7
    3b1a:	je     3b2a <botlish_fn_45+0x62>
    3b20:	mov    QWORD PTR [rsp+0x30],rax
    3b25:	jmp    3b3a <botlish_fn_45+0x72>
    3b2a:	movzx  rcx,BYTE PTR [rax]
    3b2e:	mov    QWORD PTR [rsp+0x30],rax
    3b33:	rex cmp cl,0x8
    3b37:	sete   cl
    3b3a:	test   cl,cl
    3b3c:	jne    3b61 <botlish_fn_45+0x99>
    3b42:	mov    rdi,rbx
    3b45:	mov    rax,QWORD PTR [rdi+0x10]
    3b49:	mov    rcx,QWORD PTR [rax+0x20]
    3b4d:	mov    edx,0x8
    3b52:	mov    rsi,QWORD PTR [rsp+0x30]
    3b57:	call   3b5c <botlish_fn_45+0x94>
			3b58: R_X86_64_PLT32	rt_type_error-0x4
    3b5c:	jmp    3e72 <botlish_fn_45+0x3aa>
    3b61:	mov    rdx,r15
    3b64:	mov    rsi,QWORD PTR [rsp+0x30]
    3b69:	mov    rdi,rbx
    3b6c:	call   3b71 <botlish_fn_45+0xa9>
			3b6d: R_X86_64_PLT32	rt_mutarray_get-0x4
    3b71:	test   rax,rax
    3b74:	je     3e72 <botlish_fn_45+0x3aa>
    3b7a:	mov    QWORD PTR [rsp+0x8],rax
    3b7f:	mov    r13,rax
    3b82:	mov    ecx,0x3
    3b87:	mov    rsi,QWORD PTR [rsp+0x30]
    3b8c:	mov    rdx,r15
    3b8f:	mov    rdi,rbx
    3b92:	call   3b97 <botlish_fn_45+0xcf>
			3b93: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b97:	test   rax,rax
    3b9a:	je     3e72 <botlish_fn_45+0x3aa>
    3ba0:	mov    rsi,r12
    3ba3:	mov    rdi,rbx
    3ba6:	call   3bab <botlish_fn_45+0xe3>
			3ba7: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_keys<mutarray>
    3bab:	test   rax,rax
    3bae:	je     3e72 <botlish_fn_45+0x3aa>
    3bb4:	xor    ecx,ecx
    3bb6:	test   rax,0x7
    3bbc:	je     3bca <botlish_fn_45+0x102>
    3bc2:	mov    rsi,rax
    3bc5:	jmp    3bd8 <botlish_fn_45+0x110>
    3bca:	movzx  rcx,BYTE PTR [rax]
    3bce:	mov    rsi,rax
    3bd1:	rex cmp cl,0x8
    3bd5:	sete   cl
    3bd8:	test   cl,cl
    3bda:	jne    3bfa <botlish_fn_45+0x132>
    3be0:	mov    rdi,rbx
    3be3:	mov    rax,QWORD PTR [rdi+0x10]
    3be7:	mov    rcx,QWORD PTR [rax+0x40]
    3beb:	mov    edx,0x8
    3bf0:	call   3bf5 <botlish_fn_45+0x12d>
			3bf1: R_X86_64_PLT32	rt_type_error-0x4
    3bf5:	jmp    3e72 <botlish_fn_45+0x3aa>
    3bfa:	mov    rcx,QWORD PTR [rsp+0x28]
    3bff:	mov    rdx,r15
    3c02:	mov    rdi,rbx
    3c05:	call   3c0a <botlish_fn_45+0x142>
			3c06: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c0a:	test   rax,rax
    3c0d:	je     3e72 <botlish_fn_45+0x3aa>
    3c13:	mov    rsi,r12
    3c16:	mov    rdi,rbx
    3c19:	call   3c1e <botlish_fn_45+0x156>
			3c1a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    3c1e:	test   rax,rax
    3c21:	je     3e72 <botlish_fn_45+0x3aa>
    3c27:	xor    esi,esi
    3c29:	test   rax,0x7
    3c2f:	jne    3c41 <botlish_fn_45+0x179>
    3c35:	movzx  rcx,BYTE PTR [rax]
    3c39:	rex cmp cl,0x8
    3c3d:	sete   sil
    3c41:	test   sil,sil
    3c44:	jne    3c67 <botlish_fn_45+0x19f>
    3c4a:	mov    rdi,rbx
    3c4d:	mov    rsi,QWORD PTR [rdi+0x10]
    3c51:	mov    rcx,QWORD PTR [rsi+0x40]
    3c55:	mov    edx,0x8
    3c5a:	mov    rsi,rax
    3c5d:	call   3c62 <botlish_fn_45+0x19a>
			3c5e: R_X86_64_PLT32	rt_type_error-0x4
    3c62:	jmp    3e72 <botlish_fn_45+0x3aa>
    3c67:	mov    rcx,r14
    3c6a:	mov    rdx,r15
    3c6d:	mov    rsi,rax
    3c70:	mov    rdi,rbx
    3c73:	call   3c78 <botlish_fn_45+0x1b0>
			3c74: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c78:	test   rax,rax
    3c7b:	je     3e72 <botlish_fn_45+0x3aa>
    3c81:	mov    QWORD PTR [rsp+0x10],0x7
    3c8a:	mov    rsi,r12
    3c8d:	mov    rdi,rbx
    3c90:	call   3c95 <botlish_fn_45+0x1cd>
			3c91: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_size<mutarray>
    3c95:	test   rax,rax
    3c98:	je     3e72 <botlish_fn_45+0x3aa>
    3c9e:	mov    QWORD PTR [rsp+0x18],rax
    3ca3:	mov    QWORD PTR [rsp+0x20],0x3
    3cac:	mov    ecx,0x1
    3cb1:	test   rax,0x1
    3cb7:	je     3cc5 <botlish_fn_45+0x1fd>
    3cbd:	mov    rsi,rax
    3cc0:	jmp    3ce9 <botlish_fn_45+0x221>
    3cc5:	xor    ecx,ecx
    3cc7:	test   rax,0x7
    3ccd:	je     3cdb <botlish_fn_45+0x213>
    3cd3:	mov    rsi,rax
    3cd6:	jmp    3ce9 <botlish_fn_45+0x221>
    3cdb:	movzx  rcx,BYTE PTR [rax]
    3cdf:	mov    rsi,rax
    3ce2:	rex cmp cl,0x1
    3ce6:	sete   cl
    3ce9:	test   cl,cl
    3ceb:	jne    3d09 <botlish_fn_45+0x241>
    3cf1:	mov    rdi,rbx
    3cf4:	mov    rax,QWORD PTR [rdi+0x10]
    3cf8:	mov    rcx,QWORD PTR [rax+0x30]
    3cfc:	xor    rdx,rdx
    3cff:	call   3d04 <botlish_fn_45+0x23c>
			3d00: R_X86_64_PLT32	rt_type_error-0x4
    3d04:	jmp    3e72 <botlish_fn_45+0x3aa>
    3d09:	test   rsi,0x1
    3d10:	je     3d28 <botlish_fn_45+0x260>
    3d16:	mov    rcx,rsi
    3d19:	add    rcx,0x2
    3d1d:	seto   al
    3d20:	test   al,al
    3d22:	je     3d38 <botlish_fn_45+0x270>
    3d28:	mov    edx,0x3
    3d2d:	mov    rdi,rbx
    3d30:	call   3d35 <botlish_fn_45+0x26d>
			3d31: R_X86_64_PLT32	rt_int_add-0x4
    3d35:	mov    rcx,rax
    3d38:	mov    edx,0x7
    3d3d:	mov    rsi,r12
    3d40:	mov    rdi,rbx
    3d43:	call   3d48 <botlish_fn_45+0x280>
			3d44: R_X86_64_PLT32	rt_mutarray_set-0x4
    3d48:	test   rax,rax
    3d4b:	je     3e72 <botlish_fn_45+0x3aa>
    3d51:	mov    rax,r13
    3d54:	test   rax,0x1
    3d5a:	jne    3d7e <botlish_fn_45+0x2b6>
    3d60:	mov    edx,0x5
    3d65:	mov    rsi,r13
    3d68:	mov    rdi,rbx
    3d6b:	call   3d70 <botlish_fn_45+0x2a8>
			3d6c: R_X86_64_PLT32	rt_value_eq-0x4
    3d70:	test   rax,rax
    3d73:	je     3e72 <botlish_fn_45+0x3aa>
    3d79:	jmp    3d92 <botlish_fn_45+0x2ca>
    3d7e:	mov    rsi,r13
    3d81:	mov    eax,0x2
    3d86:	cmp    rsi,0x5
    3d8a:	cmove  rax,QWORD PTR [rip+0x12e]        # 3ec0 <botlish_fn_45+0x3f8>
    3d92:	cmp    rax,0x6
    3d96:	jne    3e97 <botlish_fn_45+0x3cf>
    3d9c:	mov    QWORD PTR [rsp+0x8],0x9
    3da5:	mov    rsi,r12
    3da8:	mov    rdi,rbx
    3dab:	call   3db0 <botlish_fn_45+0x2e8>
			3dac: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_tombstones<mutarray>
    3db0:	test   rax,rax
    3db3:	je     3e72 <botlish_fn_45+0x3aa>
    3db9:	mov    QWORD PTR [rsp+0x10],rax
    3dbe:	mov    QWORD PTR [rsp+0x18],0x3
    3dc7:	mov    ecx,0x1
    3dcc:	test   rax,0x1
    3dd2:	je     3de0 <botlish_fn_45+0x318>
    3dd8:	mov    rsi,rax
    3ddb:	jmp    3e04 <botlish_fn_45+0x33c>
    3de0:	xor    ecx,ecx
    3de2:	test   rax,0x7
    3de8:	je     3df6 <botlish_fn_45+0x32e>
    3dee:	mov    rsi,rax
    3df1:	jmp    3e04 <botlish_fn_45+0x33c>
    3df6:	movzx  rcx,BYTE PTR [rax]
    3dfa:	mov    rsi,rax
    3dfd:	rex cmp cl,0x1
    3e01:	sete   cl
    3e04:	test   cl,cl
    3e06:	jne    3e24 <botlish_fn_45+0x35c>
    3e0c:	mov    rdi,rbx
    3e0f:	mov    rcx,QWORD PTR [rdi+0x10]
    3e13:	mov    rcx,QWORD PTR [rcx+0x48]
    3e17:	xor    rdx,rdx
    3e1a:	call   3e1f <botlish_fn_45+0x357>
			3e1b: R_X86_64_PLT32	rt_type_error-0x4
    3e1f:	jmp    3e72 <botlish_fn_45+0x3aa>
    3e24:	test   rsi,0x1
    3e2b:	je     3e49 <botlish_fn_45+0x381>
    3e31:	mov    r8,rsi
    3e34:	sub    r8,0x3
    3e38:	seto   dil
    3e3c:	lea    rcx,[r8+0x1]
    3e40:	test   dil,dil
    3e43:	je     3e59 <botlish_fn_45+0x391>
    3e49:	mov    edx,0x3
    3e4e:	mov    rdi,rbx
    3e51:	call   3e56 <botlish_fn_45+0x38e>
			3e52: R_X86_64_PLT32	rt_int_sub-0x4
    3e56:	mov    rcx,rax
    3e59:	mov    edx,0x9
    3e5e:	mov    rsi,r12
    3e61:	mov    rdi,rbx
    3e64:	call   3e69 <botlish_fn_45+0x3a1>
			3e65: R_X86_64_PLT32	rt_mutarray_set-0x4
    3e69:	test   rax,rax
    3e6c:	jne    3e97 <botlish_fn_45+0x3cf>
    3e72:	xor    rax,rax
    3e75:	mov    rbx,QWORD PTR [rsp+0x40]
    3e7a:	mov    r12,QWORD PTR [rsp+0x48]
    3e7f:	mov    r13,QWORD PTR [rsp+0x50]
    3e84:	mov    r14,QWORD PTR [rsp+0x58]
    3e89:	mov    r15,QWORD PTR [rsp+0x60]
    3e8e:	add    rsp,0x70
    3e92:	mov    rsp,rbp
    3e95:	pop    rbp
    3e96:	ret
    3e97:	mov    eax,0xa
    3e9c:	mov    rbx,QWORD PTR [rsp+0x40]
    3ea1:	mov    r12,QWORD PTR [rsp+0x48]
    3ea6:	mov    r13,QWORD PTR [rsp+0x50]
    3eab:	mov    r14,QWORD PTR [rsp+0x58]
    3eb0:	mov    r15,QWORD PTR [rsp+0x60]
    3eb5:	add    rsp,0x70
    3eb9:	mov    rsp,rbp
    3ebc:	pop    rbp
    3ebd:	ret
    3ebe:	add    BYTE PTR [rax],al
    3ec0:	(bad)
    3ec1:	add    BYTE PTR [rax],al
    3ec3:	add    BYTE PTR [rax],al
    3ec5:	add    BYTE PTR [rax],al
	...

0000000000003ec8 <botlish_entry_45: ht_place<mutarray, int, any, any>>:
    3ec8:	push   rbp
    3ec9:	mov    rbp,rsp
    3ecc:	mov    rsi,QWORD PTR [rdx]
    3ecf:	mov    r9,QWORD PTR [rdx+0x8]
    3ed3:	mov    rcx,QWORD PTR [rdx+0x10]
    3ed7:	mov    r8,QWORD PTR [rdx+0x18]
    3edb:	mov    rdx,r9
    3ede:	call   3ee3 <botlish_entry_45+0x1b>
			3edf: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    3ee3:	mov    rsp,rbp
    3ee6:	pop    rbp
    3ee7:	ret

0000000000003ee8 <botlish_fn_46: ht_set<mutarray, any, any>>:
    3ee8:	push   rbp
    3ee9:	mov    rbp,rsp
    3eec:	sub    rsp,0x60
    3ef0:	mov    QWORD PTR [rsp+0x30],rbx
    3ef5:	mov    QWORD PTR [rsp+0x38],r12
    3efa:	mov    QWORD PTR [rsp+0x40],r13
    3eff:	mov    QWORD PTR [rsp+0x48],r14
    3f04:	mov    QWORD PTR [rsp+0x50],r15
    3f09:	mov    rbx,rdi
    3f0c:	mov    r13,rdx
    3f0f:	mov    QWORD PTR [rsp],rsi
    3f13:	mov    r14,rsi
    3f16:	mov    QWORD PTR [rsp+0x8],rdx
    3f1b:	mov    QWORD PTR [rsp+0x10],rcx
    3f20:	mov    r12,rcx
    3f23:	mov    rdx,r13
    3f26:	mov    rsi,r14
    3f29:	mov    rdi,rbx
    3f2c:	call   3f31 <botlish_fn_46+0x49>
			3f2d: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    3f31:	test   rax,rax
    3f34:	je     419f <botlish_fn_46+0x2b7>
    3f3a:	mov    QWORD PTR [rsp+0x18],rax
    3f3f:	mov    rcx,rax
    3f42:	mov    r8,0xffffffffffffffff
    3f49:	mov    QWORD PTR [rsp+0x28],r8
    3f4e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3f57:	mov    rdx,r13
    3f5a:	mov    rsi,r14
    3f5d:	mov    rdi,rbx
    3f60:	call   3f65 <botlish_fn_46+0x7d>
			3f61: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    3f65:	mov    rcx,rax
    3f68:	mov    r15,rax
    3f6b:	test   rax,rcx
    3f6e:	je     419f <botlish_fn_46+0x2b7>
    3f74:	mov    rax,r15
    3f77:	mov    QWORD PTR [rsp+0x18],rax
    3f7c:	mov    rsi,r14
    3f7f:	mov    rdi,rbx
    3f82:	call   3f87 <botlish_fn_46+0x9f>
			3f83: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_controls<mutarray>
    3f87:	test   rax,rax
    3f8a:	je     419f <botlish_fn_46+0x2b7>
    3f90:	xor    ecx,ecx
    3f92:	test   rax,0x7
    3f98:	je     3fa6 <botlish_fn_46+0xbe>
    3f9e:	mov    r8,rax
    3fa1:	jmp    3fb4 <botlish_fn_46+0xcc>
    3fa6:	movzx  rcx,BYTE PTR [rax]
    3faa:	mov    r8,rax
    3fad:	rex cmp cl,0x8
    3fb1:	sete   cl
    3fb4:	test   cl,cl
    3fb6:	jne    3fd9 <botlish_fn_46+0xf1>
    3fbc:	mov    rdi,rbx
    3fbf:	mov    rsi,QWORD PTR [rdi+0x10]
    3fc3:	mov    rcx,QWORD PTR [rsi+0x20]
    3fc7:	mov    edx,0x8
    3fcc:	mov    rsi,r8
    3fcf:	call   3fd4 <botlish_fn_46+0xec>
			3fd0: R_X86_64_PLT32	rt_type_error-0x4
    3fd4:	jmp    419f <botlish_fn_46+0x2b7>
    3fd9:	mov    rsi,r8
    3fdc:	mov    rdx,r15
    3fdf:	mov    rdi,rbx
    3fe2:	call   3fe7 <botlish_fn_46+0xff>
			3fe3: R_X86_64_PLT32	rt_mutarray_get-0x4
    3fe7:	test   rax,rax
    3fea:	je     419f <botlish_fn_46+0x2b7>
    3ff0:	test   rax,0x1
    3ff6:	mov    rsi,rax
    3ff9:	jne    401a <botlish_fn_46+0x132>
    3fff:	mov    edx,0x3
    4004:	mov    rdi,rbx
    4007:	call   400c <botlish_fn_46+0x124>
			4008: R_X86_64_PLT32	rt_value_eq-0x4
    400c:	test   rax,rax
    400f:	je     419f <botlish_fn_46+0x2b7>
    4015:	jmp    402b <botlish_fn_46+0x143>
    401a:	mov    eax,0x2
    401f:	cmp    rsi,0x3
    4023:	cmove  rax,QWORD PTR [rip+0x1c5]        # 41f0 <botlish_fn_46+0x308>
    402b:	cmp    rax,0x6
    402f:	je     412e <botlish_fn_46+0x246>
    4035:	mov    rsi,r14
    4038:	mov    rdi,rbx
    403b:	call   4040 <botlish_fn_46+0x158>
			403c: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_should_grow<mutarray>
    4040:	test   rax,rax
    4043:	je     419f <botlish_fn_46+0x2b7>
    4049:	cmp    rax,0x6
    404d:	je     4092 <botlish_fn_46+0x1aa>
    4053:	mov    rcx,r13
    4056:	mov    rdx,r15
    4059:	mov    rsi,r14
    405c:	mov    rdi,rbx
    405f:	mov    r8,r12
    4062:	call   4067 <botlish_fn_46+0x17f>
			4063: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    4067:	test   rax,rax
    406a:	je     419f <botlish_fn_46+0x2b7>
    4070:	mov    rbx,QWORD PTR [rsp+0x30]
    4075:	mov    r12,QWORD PTR [rsp+0x38]
    407a:	mov    r13,QWORD PTR [rsp+0x40]
    407f:	mov    r14,QWORD PTR [rsp+0x48]
    4084:	mov    r15,QWORD PTR [rsp+0x50]
    4089:	add    rsp,0x60
    408d:	mov    rsp,rbp
    4090:	pop    rbp
    4091:	ret
    4092:	mov    rsi,r14
    4095:	mov    rdi,rbx
    4098:	call   409d <botlish_fn_46+0x1b5>
			4099: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_grow_or_clean<mutarray>
    409d:	test   rax,rax
    40a0:	je     419f <botlish_fn_46+0x2b7>
    40a6:	mov    rdx,r13
    40a9:	mov    rsi,r14
    40ac:	mov    rdi,rbx
    40af:	call   40b4 <botlish_fn_46+0x1cc>
			40b0: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_probe_start<mutarray, any>
    40b4:	test   rax,rax
    40b7:	je     419f <botlish_fn_46+0x2b7>
    40bd:	mov    QWORD PTR [rsp+0x18],rax
    40c2:	mov    rcx,rax
    40c5:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    40ce:	mov    r8,QWORD PTR [rsp+0x28]
    40d3:	mov    rdx,r13
    40d6:	mov    rsi,r14
    40d9:	mov    rdi,rbx
    40dc:	call   40e1 <botlish_fn_46+0x1f9>
			40dd: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_insert<mutarray, any, int, int>
    40e1:	test   rax,rax
    40e4:	je     419f <botlish_fn_46+0x2b7>
    40ea:	mov    QWORD PTR [rsp+0x18],rax
    40ef:	mov    rcx,r13
    40f2:	mov    rdx,rax
    40f5:	mov    rsi,r14
    40f8:	mov    rdi,rbx
    40fb:	mov    r8,r12
    40fe:	call   4103 <botlish_fn_46+0x21b>
			40ff: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_place<mutarray, int, any, any>
    4103:	test   rax,rax
    4106:	je     419f <botlish_fn_46+0x2b7>
    410c:	mov    rbx,QWORD PTR [rsp+0x30]
    4111:	mov    r12,QWORD PTR [rsp+0x38]
    4116:	mov    r13,QWORD PTR [rsp+0x40]
    411b:	mov    r14,QWORD PTR [rsp+0x48]
    4120:	mov    r15,QWORD PTR [rsp+0x50]
    4125:	add    rsp,0x60
    4129:	mov    rsp,rbp
    412c:	pop    rbp
    412d:	ret
    412e:	mov    rsi,r14
    4131:	mov    rdi,rbx
    4134:	call   4139 <botlish_fn_46+0x251>
			4135: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_values<mutarray>
    4139:	test   rax,rax
    413c:	je     419f <botlish_fn_46+0x2b7>
    4142:	xor    ecx,ecx
    4144:	test   rax,0x7
    414a:	je     4158 <botlish_fn_46+0x270>
    4150:	mov    rsi,rax
    4153:	jmp    4166 <botlish_fn_46+0x27e>
    4158:	movzx  rcx,BYTE PTR [rax]
    415c:	mov    rsi,rax
    415f:	rex cmp cl,0x8
    4163:	sete   cl
    4166:	test   cl,cl
    4168:	jne    4188 <botlish_fn_46+0x2a0>
    416e:	mov    rdi,rbx
    4171:	mov    rax,QWORD PTR [rdi+0x10]
    4175:	mov    rcx,QWORD PTR [rax+0x40]
    4179:	mov    edx,0x8
    417e:	call   4183 <botlish_fn_46+0x29b>
			417f: R_X86_64_PLT32	rt_type_error-0x4
    4183:	jmp    419f <botlish_fn_46+0x2b7>
    4188:	mov    rcx,r12
    418b:	mov    rdx,r15
    418e:	mov    rdi,rbx
    4191:	call   4196 <botlish_fn_46+0x2ae>
			4192: R_X86_64_PLT32	rt_mutarray_set-0x4
    4196:	test   rax,rax
    4199:	jne    41c4 <botlish_fn_46+0x2dc>
    419f:	xor    rax,rax
    41a2:	mov    rbx,QWORD PTR [rsp+0x30]
    41a7:	mov    r12,QWORD PTR [rsp+0x38]
    41ac:	mov    r13,QWORD PTR [rsp+0x40]
    41b1:	mov    r14,QWORD PTR [rsp+0x48]
    41b6:	mov    r15,QWORD PTR [rsp+0x50]
    41bb:	add    rsp,0x60
    41bf:	mov    rsp,rbp
    41c2:	pop    rbp
    41c3:	ret
    41c4:	mov    eax,0xa
    41c9:	mov    rbx,QWORD PTR [rsp+0x30]
    41ce:	mov    r12,QWORD PTR [rsp+0x38]
    41d3:	mov    r13,QWORD PTR [rsp+0x40]
    41d8:	mov    r14,QWORD PTR [rsp+0x48]
    41dd:	mov    r15,QWORD PTR [rsp+0x50]
    41e2:	add    rsp,0x60
    41e6:	mov    rsp,rbp
    41e9:	pop    rbp
    41ea:	ret
    41eb:	add    BYTE PTR [rax],al
    41ed:	add    BYTE PTR [rax],al
    41ef:	add    BYTE PTR [rsi],al
    41f1:	add    BYTE PTR [rax],al
    41f3:	add    BYTE PTR [rax],al
    41f5:	add    BYTE PTR [rax],al
	...

00000000000041f8 <botlish_entry_46: ht_set<mutarray, any, any>>:
    41f8:	push   rbp
    41f9:	mov    rbp,rsp
    41fc:	mov    rsi,QWORD PTR [rdx]
    41ff:	mov    r8,QWORD PTR [rdx+0x8]
    4203:	mov    rcx,QWORD PTR [rdx+0x10]
    4207:	mov    rdx,r8
    420a:	call   420f <botlish_entry_46+0x17>
			420b: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_set<mutarray, any, any>
    420f:	mov    rsp,rbp
    4212:	pop    rbp
    4213:	ret

0000000000004214 <botlish_fn_47: row_new<bool, int>>:
    4214:	push   rbp
    4215:	mov    rbp,rsp
    4218:	sub    rsp,0x10
    421c:	mov    QWORD PTR [rsp],rdx
    4220:	mov    r8,rdx
    4223:	cmp    rsi,0x6
    4227:	je     4244 <botlish_fn_47+0x30>
    422d:	call   4232 <botlish_fn_47+0x1e>
			422e: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_new<generic>
    4232:	test   rax,rax
    4235:	je     4255 <botlish_fn_47+0x41>
    423b:	add    rsp,0x10
    423f:	mov    rsp,rbp
    4242:	pop    rbp
    4243:	ret
    4244:	mov    rsi,r8
    4247:	call   424c <botlish_fn_47+0x38>
			4248: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_new_sized<int>
    424c:	test   rax,rax
    424f:	jne    4261 <botlish_fn_47+0x4d>
    4255:	xor    rax,rax
    4258:	add    rsp,0x10
    425c:	mov    rsp,rbp
    425f:	pop    rbp
    4260:	ret
    4261:	add    rsp,0x10
    4265:	mov    rsp,rbp
    4268:	pop    rbp
    4269:	ret

000000000000426a <botlish_entry_47: row_new<bool, int>>:
    426a:	push   rbp
    426b:	mov    rbp,rsp
    426e:	mov    rsi,QWORD PTR [rdx]
    4271:	mov    rdx,QWORD PTR [rdx+0x8]
    4275:	call   427a <botlish_entry_47+0x10>
			4276: R_X86_64_PLT32	botlish_fn_47-0x4 ; row_new<bool, int>
    427a:	mov    rsp,rbp
    427d:	pop    rbp
    427e:	ret

000000000000427f <botlish_fn_48: row_fill<mutarray, any, any, int, int>>:
    427f:	push   rbp
    4280:	mov    rbp,rsp
    4283:	sub    rsp,0x70
    4287:	mov    QWORD PTR [rsp+0x40],rbx
    428c:	mov    QWORD PTR [rsp+0x48],r12
    4291:	mov    QWORD PTR [rsp+0x50],r13
    4296:	mov    QWORD PTR [rsp+0x58],r14
    429b:	mov    QWORD PTR [rsp+0x60],r15
    42a0:	mov    r15,rdi
    42a3:	mov    QWORD PTR [rsp],rsi
    42a7:	mov    r13,rsi
    42aa:	mov    QWORD PTR [rsp+0x8],rdx
    42af:	mov    QWORD PTR [rsp+0x10],rcx
    42b4:	mov    QWORD PTR [rsp+0x28],rcx
    42b9:	sar    r8,1
    42bc:	mov    r14,r8
    42bf:	sar    r9,1
    42c2:	mov    rbx,r9
    42c5:	cmp    r14,rbx
    42c8:	jge    4481 <botlish_fn_48+0x202>
    42ce:	xor    ecx,ecx
    42d0:	test   rdx,0x7
    42d7:	je     42e5 <botlish_fn_48+0x66>
    42dd:	mov    r8,rdx
    42e0:	jmp    42f1 <botlish_fn_48+0x72>
    42e5:	movzx  rax,BYTE PTR [rdx]
    42e9:	mov    r8,rdx
    42ec:	cmp    al,0x3
    42ee:	sete   cl
    42f1:	test   cl,cl
    42f3:	jne    4316 <botlish_fn_48+0x97>
    42f9:	mov    rdi,r15
    42fc:	mov    rsi,QWORD PTR [rdi+0x10]
    4300:	mov    rcx,QWORD PTR [rsi+0x50]
    4304:	mov    edx,0x4
    4309:	mov    rsi,r8
    430c:	call   4311 <botlish_fn_48+0x92>
			430d: R_X86_64_PLT32	rt_type_error-0x4
    4311:	jmp    443a <botlish_fn_48+0x1bb>
    4316:	mov    rsi,r8
    4319:	mov    rdi,QWORD PTR [rsi+0x8]
    431d:	mov    r8,rsi
    4320:	mov    rsi,r14
    4323:	shl    rsi,1
    4326:	or     rsi,0x1
    432a:	sar    rsi,1
    432d:	cmp    rsi,rdi
    4330:	jb     435f <botlish_fn_48+0xe0>
    4336:	mov    rdx,r14
    4339:	shl    rdx,1
    433c:	or     rdx,0x1
    4340:	mov    r12,r8
    4343:	mov    rsi,r12
    4346:	mov    rdi,r15
    4349:	call   434e <botlish_fn_48+0xcf>
			434a: R_X86_64_PLT32	rt_list_get-0x4
    434e:	test   rax,rax
    4351:	je     443a <botlish_fn_48+0x1bb>
    4357:	mov    rdx,rax
    435a:	jmp    436b <botlish_fn_48+0xec>
    435f:	mov    r12,r8
    4362:	mov    r11,QWORD PTR [r12+0x10]
    4367:	mov    rdx,QWORD PTR [r11+rsi*8]
    436b:	mov    QWORD PTR [rsp+0x18],rdx
    4370:	mov    QWORD PTR [rsp+0x30],rdx
    4375:	xor    ecx,ecx
    4377:	mov    rdx,QWORD PTR [rsp+0x28]
    437c:	test   rdx,0x7
    4383:	je     4393 <botlish_fn_48+0x114>
    4389:	mov    QWORD PTR [rsp+0x28],rdx
    438e:	jmp    43a1 <botlish_fn_48+0x122>
    4393:	movzx  rax,BYTE PTR [rdx]
    4397:	mov    QWORD PTR [rsp+0x28],rdx
    439c:	cmp    al,0x3
    439e:	sete   cl
    43a1:	test   cl,cl
    43a3:	jne    43c8 <botlish_fn_48+0x149>
    43a9:	mov    rdi,r15
    43ac:	mov    rax,QWORD PTR [rdi+0x10]
    43b0:	mov    rcx,QWORD PTR [rax+0x50]
    43b4:	mov    edx,0x4
    43b9:	mov    rsi,QWORD PTR [rsp+0x28]
    43be:	call   43c3 <botlish_fn_48+0x144>
			43bf: R_X86_64_PLT32	rt_type_error-0x4
    43c3:	jmp    443a <botlish_fn_48+0x1bb>
    43c8:	mov    rsi,QWORD PTR [rsp+0x28]
    43cd:	mov    rax,QWORD PTR [rsi+0x8]
    43d1:	mov    rcx,r14
    43d4:	shl    rcx,1
    43d7:	or     rcx,0x1
    43db:	sar    rcx,1
    43de:	cmp    rcx,rax
    43e1:	jb     440f <botlish_fn_48+0x190>
    43e7:	mov    rdx,r14
    43ea:	shl    rdx,1
    43ed:	or     rdx,0x1
    43f1:	mov    rsi,QWORD PTR [rsp+0x28]
    43f6:	mov    rdi,r15
    43f9:	call   43fe <botlish_fn_48+0x17f>
			43fa: R_X86_64_PLT32	rt_list_get-0x4
    43fe:	test   rax,rax
    4401:	je     443a <botlish_fn_48+0x1bb>
    4407:	mov    rcx,rax
    440a:	jmp    441c <botlish_fn_48+0x19d>
    440f:	mov    rsi,QWORD PTR [rsp+0x28]
    4414:	mov    rax,QWORD PTR [rsi+0x10]
    4418:	mov    rcx,QWORD PTR [rax+rcx*8]
    441c:	mov    QWORD PTR [rsp+0x20],rcx
    4421:	mov    rdx,QWORD PTR [rsp+0x30]
    4426:	mov    rsi,r13
    4429:	mov    rdi,r15
    442c:	call   4431 <botlish_fn_48+0x1b2>
			442d: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_set<mutarray, any, any>
    4431:	test   rax,rax
    4434:	jne    445f <botlish_fn_48+0x1e0>
    443a:	xor    rax,rax
    443d:	mov    rbx,QWORD PTR [rsp+0x40]
    4442:	mov    r12,QWORD PTR [rsp+0x48]
    4447:	mov    r13,QWORD PTR [rsp+0x50]
    444c:	mov    r14,QWORD PTR [rsp+0x58]
    4451:	mov    r15,QWORD PTR [rsp+0x60]
    4456:	add    rsp,0x70
    445a:	mov    rsp,rbp
    445d:	pop    rbp
    445e:	ret
    445f:	mov    QWORD PTR [rsp],r13
    4463:	mov    QWORD PTR [rsp+0x8],r12
    4468:	mov    rsi,QWORD PTR [rsp+0x28]
    446d:	mov    QWORD PTR [rsp+0x10],rsi
    4472:	add    r14,0x1
    4479:	mov    rdx,r12
    447c:	jmp    42c5 <botlish_fn_48+0x46>
    4481:	mov    rax,r13
    4484:	mov    rbx,QWORD PTR [rsp+0x40]
    4489:	mov    r12,QWORD PTR [rsp+0x48]
    448e:	mov    r13,QWORD PTR [rsp+0x50]
    4493:	mov    r14,QWORD PTR [rsp+0x58]
    4498:	mov    r15,QWORD PTR [rsp+0x60]
    449d:	add    rsp,0x70
    44a1:	mov    rsp,rbp
    44a4:	pop    rbp
    44a5:	ret

00000000000044a6 <botlish_entry_48: row_fill<mutarray, any, any, int, int>>:
    44a6:	push   rbp
    44a7:	mov    rbp,rsp
    44aa:	mov    rsi,QWORD PTR [rdx]
    44ad:	mov    r10,QWORD PTR [rdx+0x8]
    44b1:	mov    rcx,QWORD PTR [rdx+0x10]
    44b5:	mov    r8,QWORD PTR [rdx+0x18]
    44b9:	mov    r9,QWORD PTR [rdx+0x20]
    44bd:	mov    rdx,r10
    44c0:	call   44c5 <botlish_entry_48+0x1f>
			44c1: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_fill<mutarray, any, any, int, int>
    44c5:	mov    rsp,rbp
    44c8:	pop    rbp
    44c9:	ret

00000000000044ca <botlish_fn_49: row_table<any, int, any, bool>>:
    44ca:	push   rbp
    44cb:	mov    rbp,rsp
    44ce:	sub    rsp,0x50
    44d2:	mov    QWORD PTR [rsp+0x30],rbx
    44d7:	mov    QWORD PTR [rsp+0x38],r12
    44dc:	mov    QWORD PTR [rsp+0x40],r13
    44e1:	mov    QWORD PTR [rsp+0x48],r14
    44e6:	mov    r12,rdi
    44e9:	mov    QWORD PTR [rsp+0x20],0x0
    44f2:	mov    QWORD PTR [rsp],rsi
    44f6:	mov    r13,rsi
    44f9:	mov    QWORD PTR [rsp+0x8],rdx
    44fe:	mov    QWORD PTR [rsp+0x10],rcx
    4503:	mov    rbx,rcx
    4506:	mov    QWORD PTR [rsp+0x18],r8
    450b:	mov    rsi,r8
    450e:	mov    rdi,r12
    4511:	call   4516 <botlish_fn_49+0x4c>
			4512: R_X86_64_PLT32	botlish_fn_47-0x4 ; row_new<bool, int>
    4516:	test   rax,rax
    4519:	je     45ae <botlish_fn_49+0xe4>
    451f:	mov    QWORD PTR [rsp+0x8],rax
    4524:	mov    r14,rax
    4527:	mov    QWORD PTR [rsp+0x18],0x1
    4530:	xor    eax,eax
    4532:	mov    rcx,rbx
    4535:	test   rcx,0x7
    453c:	je     454a <botlish_fn_49+0x80>
    4542:	mov    rbx,rcx
    4545:	jmp    4556 <botlish_fn_49+0x8c>
    454a:	movzx  rax,BYTE PTR [rcx]
    454e:	mov    rbx,rcx
    4551:	cmp    al,0x3
    4553:	sete   al
    4556:	test   al,al
    4558:	jne    457b <botlish_fn_49+0xb1>
    455e:	mov    rdi,r12
    4561:	mov    rax,QWORD PTR [rdi+0x10]
    4565:	mov    rcx,QWORD PTR [rax+0x58]
    4569:	mov    edx,0x4
    456e:	mov    rsi,rbx
    4571:	call   4576 <botlish_fn_49+0xac>
			4572: R_X86_64_PLT32	rt_type_error-0x4
    4576:	jmp    45ae <botlish_fn_49+0xe4>
    457b:	mov    rsi,rbx
    457e:	mov    rdi,r12
    4581:	call   4586 <botlish_fn_49+0xbc>
			4582: R_X86_64_PLT32	rt_list_len-0x4
    4586:	mov    QWORD PTR [rsp+0x20],rax
    458b:	mov    r8d,0x1
    4591:	mov    rcx,rbx
    4594:	mov    rdx,r13
    4597:	mov    rsi,r14
    459a:	mov    rdi,r12
    459d:	mov    r9,rax
    45a0:	call   45a5 <botlish_fn_49+0xdb>
			45a1: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_fill<mutarray, any, any, int, int>
    45a5:	test   rax,rax
    45a8:	jne    45ce <botlish_fn_49+0x104>
    45ae:	xor    rax,rax
    45b1:	mov    rbx,QWORD PTR [rsp+0x30]
    45b6:	mov    r12,QWORD PTR [rsp+0x38]
    45bb:	mov    r13,QWORD PTR [rsp+0x40]
    45c0:	mov    r14,QWORD PTR [rsp+0x48]
    45c5:	add    rsp,0x50
    45c9:	mov    rsp,rbp
    45cc:	pop    rbp
    45cd:	ret
    45ce:	mov    rbx,QWORD PTR [rsp+0x30]
    45d3:	mov    r12,QWORD PTR [rsp+0x38]
    45d8:	mov    r13,QWORD PTR [rsp+0x40]
    45dd:	mov    r14,QWORD PTR [rsp+0x48]
    45e2:	add    rsp,0x50
    45e6:	mov    rsp,rbp
    45e9:	pop    rbp
    45ea:	ret

00000000000045eb <botlish_entry_49: row_table<any, int, any, bool>>:
    45eb:	push   rbp
    45ec:	mov    rbp,rsp
    45ef:	mov    rsi,QWORD PTR [rdx]
    45f2:	mov    r9,QWORD PTR [rdx+0x8]
    45f6:	mov    rcx,QWORD PTR [rdx+0x10]
    45fa:	mov    r8,QWORD PTR [rdx+0x18]
    45fe:	mov    rdx,r9
    4601:	call   4606 <botlish_entry_49+0x1b>
			4602: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_table<any, int, any, bool>
    4606:	mov    rsp,rbp
    4609:	pop    rbp
    460a:	ret

000000000000460b <botlish_fn_50: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    460b:	push   rbp
    460c:	mov    rbp,rsp
    460f:	sub    rsp,0x80
    4616:	mov    QWORD PTR [rsp+0x50],rbx
    461b:	mov    QWORD PTR [rsp+0x58],r12
    4620:	mov    QWORD PTR [rsp+0x60],r13
    4625:	mov    QWORD PTR [rsp+0x68],r14
    462a:	mov    QWORD PTR [rsp+0x70],r15
    462f:	mov    r13,r8
    4632:	mov    QWORD PTR [rsp+0x38],rdi
    4637:	mov    r11,QWORD PTR [rbp+0x10]
    463b:	mov    r15,QWORD PTR [rbp+0x18]
    463f:	mov    QWORD PTR [rsp+0x28],0x0
    4648:	mov    QWORD PTR [rsp+0x30],0x0
    4651:	mov    QWORD PTR [rsp],rsi
    4655:	mov    QWORD PTR [rsp+0x8],rcx
    465a:	mov    r14,rcx
    465d:	mov    QWORD PTR [rsp+0x10],r9
    4662:	mov    QWORD PTR [rsp+0x18],r11
    4667:	mov    QWORD PTR [rsp+0x48],r11
    466c:	mov    QWORD PTR [rsp+0x20],r15
    4671:	sar    rdx,1
    4674:	mov    r12,rdx
    4677:	mov    rbx,rsi
    467a:	mov    QWORD PTR [rsp+0x40],r9
    467f:	mov    rsi,rbx
    4682:	mov    rdi,QWORD PTR [rsp+0x38]
    4687:	call   468c <botlish_fn_50+0x81>
			4688: R_X86_64_PLT32	rt_list_len-0x4
    468c:	sar    rax,1
    468f:	cmp    r12,rax
    4692:	jge    4766 <botlish_fn_50+0x15b>
    4698:	mov    rax,r13
    469b:	or     rax,0x1
    469f:	mov    QWORD PTR [rsp+0x28],rax
    46a4:	mov    rcx,QWORD PTR [rbx+0x8]
    46a8:	mov    rax,r12
    46ab:	shl    rax,1
    46ae:	or     rax,0x1
    46b2:	sar    rax,1
    46b5:	cmp    rax,rcx
    46b8:	jb     46e6 <botlish_fn_50+0xdb>
    46be:	mov    rdx,r12
    46c1:	shl    rdx,1
    46c4:	or     rdx,0x1
    46c8:	mov    rsi,rbx
    46cb:	mov    rdi,QWORD PTR [rsp+0x38]
    46d0:	call   46d5 <botlish_fn_50+0xca>
			46d1: R_X86_64_PLT32	rt_list_get-0x4
    46d5:	test   rax,rax
    46d8:	je     4783 <botlish_fn_50+0x178>
    46de:	mov    rcx,rax
    46e1:	jmp    46ee <botlish_fn_50+0xe3>
    46e6:	mov    rcx,QWORD PTR [rbx+0x10]
    46ea:	mov    rcx,QWORD PTR [rcx+rax*8]
    46ee:	mov    QWORD PTR [rsp+0x30],rcx
    46f3:	mov    rdx,r13
    46f6:	or     rdx,0x1
    46fa:	mov    rsi,r14
    46fd:	mov    rdi,QWORD PTR [rsp+0x38]
    4702:	mov    r8,r15
    4705:	call   470a <botlish_fn_50+0xff>
			4706: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_table<any, int, any, bool>
    470a:	test   rax,rax
    470d:	je     4783 <botlish_fn_50+0x178>
    4713:	mov    QWORD PTR [rsp+0x28],rax
    4718:	mov    rcx,rax
    471b:	mov    rdx,QWORD PTR [rsp+0x48]
    4720:	mov    rsi,QWORD PTR [rsp+0x40]
    4725:	mov    rdi,QWORD PTR [rsp+0x38]
    472a:	call   472f <botlish_fn_50+0x124>
			472b: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    472f:	test   rax,rax
    4732:	je     4783 <botlish_fn_50+0x178>
    4738:	mov    QWORD PTR [rsp],rbx
    473c:	mov    QWORD PTR [rsp+0x8],r14
    4741:	mov    QWORD PTR [rsp+0x10],rax
    4746:	mov    QWORD PTR [rsp+0x18],rdx
    474b:	mov    QWORD PTR [rsp+0x20],r15
    4750:	add    r12,0x1
    4757:	mov    QWORD PTR [rsp+0x40],rax
    475c:	mov    QWORD PTR [rsp+0x48],rdx
    4761:	jmp    467f <botlish_fn_50+0x74>
    4766:	mov    rdx,QWORD PTR [rsp+0x48]
    476b:	mov    rsi,QWORD PTR [rsp+0x40]
    4770:	mov    rdi,QWORD PTR [rsp+0x38]
    4775:	call   477a <botlish_fn_50+0x16f>
			4776: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    477a:	test   rax,rax
    477d:	jne    47ab <botlish_fn_50+0x1a0>
    4783:	xor    rax,rax
    4786:	mov    rbx,QWORD PTR [rsp+0x50]
    478b:	mov    r12,QWORD PTR [rsp+0x58]
    4790:	mov    r13,QWORD PTR [rsp+0x60]
    4795:	mov    r14,QWORD PTR [rsp+0x68]
    479a:	mov    r15,QWORD PTR [rsp+0x70]
    479f:	add    rsp,0x80
    47a6:	mov    rsp,rbp
    47a9:	pop    rbp
    47aa:	ret
    47ab:	mov    rbx,QWORD PTR [rsp+0x50]
    47b0:	mov    r12,QWORD PTR [rsp+0x58]
    47b5:	mov    r13,QWORD PTR [rsp+0x60]
    47ba:	mov    r14,QWORD PTR [rsp+0x68]
    47bf:	mov    r15,QWORD PTR [rsp+0x70]
    47c4:	add    rsp,0x80
    47cb:	mov    rsp,rbp
    47ce:	pop    rbp
    47cf:	ret

00000000000047d0 <botlish_entry_50: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    47d0:	push   rbp
    47d1:	mov    rbp,rsp
    47d4:	sub    rsp,0x10
    47d8:	mov    rsi,QWORD PTR [rdx]
    47db:	mov    r10,QWORD PTR [rdx+0x8]
    47df:	mov    rcx,QWORD PTR [rdx+0x10]
    47e3:	mov    r8,QWORD PTR [rdx+0x18]
    47e7:	mov    r9,QWORD PTR [rdx+0x20]
    47eb:	mov    r11,QWORD PTR [rdx+0x28]
    47ef:	mov    rax,QWORD PTR [rdx+0x30]
    47f3:	mov    QWORD PTR [rsp],r11
    47f7:	mov    QWORD PTR [rsp+0x8],rax
    47fc:	mov    rdx,r10
    47ff:	call   4804 <botlish_entry_50+0x34>
			4800: R_X86_64_PLT32	botlish_fn_50-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4804:	add    rsp,0x10
    4808:	mov    rsp,rbp
    480b:	pop    rbp
    480c:	ret

000000000000480d <botlish_fn_51: csv_records_generic<str, bool>>:
    480d:	push   rbp
    480e:	mov    rbp,rsp
    4811:	sub    rsp,0x80
    4818:	mov    QWORD PTR [rsp+0x50],rbx
    481d:	mov    QWORD PTR [rsp+0x58],r12
    4822:	mov    QWORD PTR [rsp+0x60],r13
    4827:	mov    QWORD PTR [rsp+0x68],r14
    482c:	mov    QWORD PTR [rsp+0x70],r15
    4831:	mov    rbx,rdi
    4834:	mov    QWORD PTR [rsp+0x20],0x0
    483d:	mov    QWORD PTR [rsp+0x28],0x0
    4846:	mov    QWORD PTR [rsp+0x30],0x0
    484f:	mov    QWORD PTR [rsp+0x38],0x0
    4858:	mov    QWORD PTR [rsp+0x40],0x0
    4861:	mov    QWORD PTR [rsp+0x10],rsi
    4866:	mov    QWORD PTR [rsp+0x18],rdx
    486b:	mov    r12,rdx
    486e:	mov    rdi,rbx
    4871:	call   4876 <botlish_fn_51+0x69>
			4872: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    4876:	mov    rcx,rax
    4879:	mov    r13,rax
    487c:	test   rax,rcx
    487f:	je     49c5 <botlish_fn_51+0x1b8>
    4885:	mov    rax,r13
    4888:	mov    QWORD PTR [rsp+0x10],rax
    488d:	mov    rsi,r13
    4890:	mov    rdi,rbx
    4893:	call   4898 <botlish_fn_51+0x8b>
			4894: R_X86_64_PLT32	rt_list_len-0x4
    4898:	sar    rax,1
    489b:	test   rax,rax
    489e:	je     49ae <botlish_fn_51+0x1a1>
    48a4:	mov    rax,r13
    48a7:	mov    rax,QWORD PTR [rax+0x8]
    48ab:	test   rax,rax
    48ae:	jne    48d5 <botlish_fn_51+0xc8>
    48b4:	mov    edx,0x1
    48b9:	mov    rsi,r13
    48bc:	mov    rdi,rbx
    48bf:	call   48c4 <botlish_fn_51+0xb7>
			48c0: R_X86_64_PLT32	rt_list_get-0x4
    48c4:	test   rax,rax
    48c7:	je     49c5 <botlish_fn_51+0x1b8>
    48cd:	mov    rsi,rax
    48d0:	jmp    48e2 <botlish_fn_51+0xd5>
    48d5:	mov    rax,r13
    48d8:	mov    rcx,QWORD PTR [rax+0x10]
    48dc:	mov    rax,QWORD PTR [rcx]
    48df:	mov    rsi,rax
    48e2:	mov    QWORD PTR [rsp+0x20],rsi
    48e7:	mov    QWORD PTR [rsp+0x28],0x3
    48f0:	xor    eax,eax
    48f2:	test   rsi,0x7
    48f9:	jne    4908 <botlish_fn_51+0xfb>
    48ff:	movzx  rax,BYTE PTR [rsi]
    4903:	cmp    al,0x3
    4905:	sete   al
    4908:	test   al,al
    490a:	jne    492a <botlish_fn_51+0x11d>
    4910:	mov    rdi,rbx
    4913:	mov    rax,QWORD PTR [rdi+0x10]
    4917:	mov    rcx,QWORD PTR [rax+0x58]
    491b:	mov    edx,0x4
    4920:	call   4925 <botlish_fn_51+0x118>
			4921: R_X86_64_PLT32	rt_type_error-0x4
    4925:	jmp    49c5 <botlish_fn_51+0x1b8>
    492a:	mov    r14,rsi
    492d:	mov    rdi,rbx
    4930:	call   4935 <botlish_fn_51+0x128>
			4931: R_X86_64_PLT32	rt_list_len-0x4
    4935:	mov    QWORD PTR [rsp+0x30],rax
    493a:	mov    r15,rax
    493d:	mov    rdi,rbx
    4940:	call   4945 <botlish_fn_51+0x138>
			4941: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    4945:	test   rax,rax
    4948:	je     49c5 <botlish_fn_51+0x1b8>
    494e:	mov    QWORD PTR [rsp+0x38],rax
    4953:	mov    r9,rax
    4956:	mov    QWORD PTR [rsp+0x40],rdx
    495b:	mov    rax,rdx
    495e:	mov    edx,0x3
    4963:	mov    QWORD PTR [rsp],rax
    4967:	mov    rax,r12
    496a:	mov    QWORD PTR [rsp+0x8],rax
    496f:	mov    rcx,r14
    4972:	mov    rsi,r13
    4975:	mov    rdi,rbx
    4978:	mov    r8,r15
    497b:	call   4980 <botlish_fn_51+0x173>
			497c: R_X86_64_PLT32	botlish_fn_50-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4980:	test   rax,rax
    4983:	je     49c5 <botlish_fn_51+0x1b8>
    4989:	mov    rbx,QWORD PTR [rsp+0x50]
    498e:	mov    r12,QWORD PTR [rsp+0x58]
    4993:	mov    r13,QWORD PTR [rsp+0x60]
    4998:	mov    r14,QWORD PTR [rsp+0x68]
    499d:	mov    r15,QWORD PTR [rsp+0x70]
    49a2:	add    rsp,0x80
    49a9:	mov    rsp,rbp
    49ac:	pop    rbp
    49ad:	ret
    49ae:	xor    rdx,rdx
    49b1:	mov    rdi,rbx
    49b4:	mov    rsi,rdx
    49b7:	call   49bc <botlish_fn_51+0x1af>
			49b8: R_X86_64_PLT32	rt_list_new-0x4
    49bc:	test   rax,rax
    49bf:	jne    49ed <botlish_fn_51+0x1e0>
    49c5:	xor    rax,rax
    49c8:	mov    rbx,QWORD PTR [rsp+0x50]
    49cd:	mov    r12,QWORD PTR [rsp+0x58]
    49d2:	mov    r13,QWORD PTR [rsp+0x60]
    49d7:	mov    r14,QWORD PTR [rsp+0x68]
    49dc:	mov    r15,QWORD PTR [rsp+0x70]
    49e1:	add    rsp,0x80
    49e8:	mov    rsp,rbp
    49eb:	pop    rbp
    49ec:	ret
    49ed:	mov    rbx,QWORD PTR [rsp+0x50]
    49f2:	mov    r12,QWORD PTR [rsp+0x58]
    49f7:	mov    r13,QWORD PTR [rsp+0x60]
    49fc:	mov    r14,QWORD PTR [rsp+0x68]
    4a01:	mov    r15,QWORD PTR [rsp+0x70]
    4a06:	add    rsp,0x80
    4a0d:	mov    rsp,rbp
    4a10:	pop    rbp
    4a11:	ret

0000000000004a12 <botlish_entry_51: csv_records_generic<str, bool>>:
    4a12:	push   rbp
    4a13:	mov    rbp,rsp
    4a16:	mov    rsi,QWORD PTR [rdx]
    4a19:	mov    rdx,QWORD PTR [rdx+0x8]
    4a1d:	call   4a22 <botlish_entry_51+0x10>
			4a1e: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4a22:	mov    rsp,rbp
    4a25:	pop    rbp
    4a26:	ret

0000000000004a27 <botlish_fn_52: csv_records<str>>:
    4a27:	push   rbp
    4a28:	mov    rbp,rsp
    4a2b:	sub    rsp,0x10
    4a2f:	mov    QWORD PTR [rsp],rsi
    4a33:	mov    edx,0x2
    4a38:	mov    QWORD PTR [rsp+0x8],0x2
    4a41:	call   4a46 <botlish_fn_52+0x1f>
			4a42: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4a46:	test   rax,rax
    4a49:	jne    4a5b <botlish_fn_52+0x34>
    4a4f:	xor    rax,rax
    4a52:	add    rsp,0x10
    4a56:	mov    rsp,rbp
    4a59:	pop    rbp
    4a5a:	ret
    4a5b:	add    rsp,0x10
    4a5f:	mov    rsp,rbp
    4a62:	pop    rbp
    4a63:	ret

0000000000004a64 <botlish_entry_52: csv_records<str>>:
    4a64:	push   rbp
    4a65:	mov    rbp,rsp
    4a68:	mov    rsi,QWORD PTR [rdx]
    4a6b:	call   4a70 <botlish_entry_52+0xc>
			4a6c: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records<str>
    4a70:	mov    rsp,rbp
    4a73:	pop    rbp
    4a74:	ret

0000000000004a75 <botlish_fn_53: csv_records_presized<str>>:
    4a75:	push   rbp
    4a76:	mov    rbp,rsp
    4a79:	sub    rsp,0x10
    4a7d:	mov    QWORD PTR [rsp],rsi
    4a81:	mov    edx,0x6
    4a86:	mov    QWORD PTR [rsp+0x8],0x6
    4a8f:	call   4a94 <botlish_fn_53+0x1f>
			4a90: R_X86_64_PLT32	botlish_fn_51-0x4 ; csv_records_generic<str, bool>
    4a94:	test   rax,rax
    4a97:	jne    4aa9 <botlish_fn_53+0x34>
    4a9d:	xor    rax,rax
    4aa0:	add    rsp,0x10
    4aa4:	mov    rsp,rbp
    4aa7:	pop    rbp
    4aa8:	ret
    4aa9:	add    rsp,0x10
    4aad:	mov    rsp,rbp
    4ab0:	pop    rbp
    4ab1:	ret

0000000000004ab2 <botlish_entry_53: csv_records_presized<str>>:
    4ab2:	push   rbp
    4ab3:	mov    rbp,rsp
    4ab6:	mov    rsi,QWORD PTR [rdx]
    4ab9:	call   4abe <botlish_entry_53+0xc>
			4aba: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_presized<str>
    4abe:	mov    rsp,rbp
    4ac1:	pop    rbp
    4ac2:	ret
    4ac3:	add    BYTE PTR [rax],al
    4ac5:	add    BYTE PTR [rax],al
	...

0000000000004ac8 <botlish_fn_54: sample<generic>>:
    4ac8:	push   rbp
    4ac9:	mov    rbp,rsp
    4acc:	sub    rsp,0xc0
    4ad3:	mov    QWORD PTR [rsp+0x90],rbx
    4adb:	mov    QWORD PTR [rsp+0x98],r12
    4ae3:	mov    QWORD PTR [rsp+0xa0],r13
    4aeb:	mov    QWORD PTR [rsp+0xa8],r14
    4af3:	mov    QWORD PTR [rsp+0xb0],r15
    4afb:	mov    QWORD PTR [rsp+0x8],0x0
    4b04:	mov    QWORD PTR [rsp+0x10],0x0
    4b0d:	mov    QWORD PTR [rsp+0x18],0x0
    4b16:	mov    QWORD PTR [rsp+0x20],0x0
    4b1f:	mov    QWORD PTR [rsp+0x28],0x0
    4b28:	mov    QWORD PTR [rsp+0x30],0x0
    4b31:	mov    QWORD PTR [rsp+0x38],0x0
    4b3a:	mov    rax,QWORD PTR [rdi+0x10]
    4b3e:	mov    r13,rdi
    4b41:	mov    rsi,QWORD PTR [rax+0x60]
    4b45:	mov    QWORD PTR [rsp],rsi
    4b49:	call   4b4e <botlish_fn_54+0x86>
			4b4a: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records<str>
    4b4e:	mov    rsi,rax
    4b51:	mov    r12,rax
    4b54:	test   rax,rsi
    4b57:	je     4edc <botlish_fn_54+0x414>
    4b5d:	mov    rax,r12
    4b60:	mov    QWORD PTR [rsp],rax
    4b64:	mov    rdi,r13
    4b67:	mov    rax,QWORD PTR [rdi+0x10]
    4b6b:	mov    rsi,QWORD PTR [rax+0x60]
    4b6f:	mov    QWORD PTR [rsp+0x8],rsi
    4b74:	call   4b79 <botlish_fn_54+0xb1>
			4b75: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_presized<str>
    4b79:	mov    rbx,rax
    4b7c:	test   rbx,rbx
    4b7f:	je     4edc <botlish_fn_54+0x414>
    4b85:	mov    rax,r12
    4b88:	mov    rax,QWORD PTR [rax+0x8]
    4b8c:	test   rax,rax
    4b8f:	jne    4bb6 <botlish_fn_54+0xee>
    4b95:	mov    edx,0x1
    4b9a:	mov    rsi,r12
    4b9d:	mov    rdi,r13
    4ba0:	call   4ba5 <botlish_fn_54+0xdd>
			4ba1: R_X86_64_PLT32	rt_list_get-0x4
    4ba5:	test   rax,rax
    4ba8:	je     4edc <botlish_fn_54+0x414>
    4bae:	mov    rsi,rax
    4bb1:	jmp    4bbe <botlish_fn_54+0xf6>
    4bb6:	mov    rax,QWORD PTR [r12+0x10]
    4bbb:	mov    rsi,QWORD PTR [rax]
    4bbe:	mov    QWORD PTR [rsp+0x8],rsi
    4bc3:	mov    r15,rsi
    4bc6:	mov    rax,QWORD PTR [r12+0x8]
    4bcb:	cmp    rax,0x1
    4bcf:	ja     4bf6 <botlish_fn_54+0x12e>
    4bd5:	mov    edx,0x3
    4bda:	mov    rsi,r12
    4bdd:	mov    rdi,r13
    4be0:	call   4be5 <botlish_fn_54+0x11d>
			4be1: R_X86_64_PLT32	rt_list_get-0x4
    4be5:	test   rax,rax
    4be8:	je     4edc <botlish_fn_54+0x414>
    4bee:	mov    rsi,rax
    4bf1:	jmp    4bff <botlish_fn_54+0x137>
    4bf6:	mov    rax,QWORD PTR [r12+0x10]
    4bfb:	mov    rsi,QWORD PTR [rax+0x8]
    4bff:	mov    QWORD PTR [rsp+0x10],rsi
    4c04:	mov    r14,rsi
    4c07:	mov    rax,QWORD PTR [rbx+0x8]
    4c0b:	mov    rsi,rbx
    4c0e:	test   rax,rax
    4c11:	jne    4c35 <botlish_fn_54+0x16d>
    4c17:	mov    edx,0x1
    4c1c:	mov    rdi,r13
    4c1f:	call   4c24 <botlish_fn_54+0x15c>
			4c20: R_X86_64_PLT32	rt_list_get-0x4
    4c24:	test   rax,rax
    4c27:	je     4edc <botlish_fn_54+0x414>
    4c2d:	mov    rsi,rax
    4c30:	jmp    4c3c <botlish_fn_54+0x174>
    4c35:	mov    rax,QWORD PTR [rsi+0x10]
    4c39:	mov    rsi,QWORD PTR [rax]
    4c3c:	mov    QWORD PTR [rsp+0x18],rsi
    4c41:	mov    rdi,r13
    4c44:	mov    QWORD PTR [rsp+0x78],rsi
    4c49:	mov    rax,QWORD PTR [rdi+0x10]
    4c4d:	mov    rdx,QWORD PTR [rax+0x68]
    4c51:	mov    QWORD PTR [rsp+0x20],rdx
    4c56:	mov    rsi,r15
    4c59:	call   4c5e <botlish_fn_54+0x196>
			4c5a: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4c5e:	test   rax,rax
    4c61:	je     4edc <botlish_fn_54+0x414>
    4c67:	mov    QWORD PTR [rsp+0x20],rax
    4c6c:	mov    rbx,rax
    4c6f:	mov    rdi,r13
    4c72:	mov    rax,QWORD PTR [rdi+0x10]
    4c76:	mov    rdx,QWORD PTR [rax+0x68]
    4c7a:	mov    QWORD PTR [rsp+0x28],rdx
    4c7f:	mov    rsi,QWORD PTR [rsp+0x78]
    4c84:	call   4c89 <botlish_fn_54+0x1c1>
			4c85: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4c89:	test   rax,rax
    4c8c:	je     4edc <botlish_fn_54+0x414>
    4c92:	mov    rcx,rbx
    4c95:	mov    rdx,rcx
    4c98:	and    rdx,rax
    4c9b:	test   rdx,0x1
    4ca2:	jne    4cc4 <botlish_fn_54+0x1fc>
    4ca8:	mov    rdx,rax
    4cab:	mov    rsi,rbx
    4cae:	mov    rdi,r13
    4cb1:	call   4cb6 <botlish_fn_54+0x1ee>
			4cb2: R_X86_64_PLT32	rt_value_eq-0x4
    4cb6:	test   rax,rax
    4cb9:	je     4edc <botlish_fn_54+0x414>
    4cbf:	jmp    4cda <botlish_fn_54+0x212>
    4cc4:	mov    rdx,rax
    4cc7:	mov    rsi,rbx
    4cca:	mov    eax,0x2
    4ccf:	cmp    rsi,rdx
    4cd2:	cmove  rax,QWORD PTR [rip+0x26e]        # 4f48 <botlish_fn_54+0x480>
    4cda:	mov    ebx,0x6
    4cdf:	cmp    rax,0x6
    4ce3:	je     4cfe <botlish_fn_54+0x236>
    4ce9:	mov    ebx,0x2
    4cee:	mov    QWORD PTR [rsp],0x2
    4cf6:	mov    rsi,r12
    4cf9:	jmp    4d9d <botlish_fn_54+0x2d5>
    4cfe:	mov    rsi,r15
    4d01:	mov    rdi,r13
    4d04:	call   4d09 <botlish_fn_54+0x241>
			4d05: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    4d09:	test   rax,rax
    4d0c:	mov    QWORD PTR [rsp+0x88],rax
    4d14:	je     4edc <botlish_fn_54+0x414>
    4d1a:	mov    rsi,QWORD PTR [rsp+0x78]
    4d1f:	mov    rdi,r13
    4d22:	call   4d27 <botlish_fn_54+0x25f>
			4d23: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_size<generic>
    4d27:	test   rax,rax
    4d2a:	je     4edc <botlish_fn_54+0x414>
    4d30:	mov    rcx,QWORD PTR [rsp+0x88]
    4d38:	mov    rdx,rcx
    4d3b:	and    rdx,rax
    4d3e:	test   rdx,0x1
    4d45:	jne    4d6c <botlish_fn_54+0x2a4>
    4d4b:	mov    rdx,rax
    4d4e:	mov    rsi,QWORD PTR [rsp+0x88]
    4d56:	mov    rdi,r13
    4d59:	call   4d5e <botlish_fn_54+0x296>
			4d5a: R_X86_64_PLT32	rt_value_eq-0x4
    4d5e:	test   rax,rax
    4d61:	je     4edc <botlish_fn_54+0x414>
    4d67:	jmp    4d87 <botlish_fn_54+0x2bf>
    4d6c:	mov    rdx,rax
    4d6f:	mov    rsi,QWORD PTR [rsp+0x88]
    4d77:	mov    eax,0x2
    4d7c:	cmp    rsi,rdx
    4d7f:	cmove  rax,QWORD PTR [rip+0x1c1]        # 4f48 <botlish_fn_54+0x480>
    4d87:	cmp    rax,0x6
    4d8b:	je     4d96 <botlish_fn_54+0x2ce>
    4d91:	mov    ebx,0x2
    4d96:	mov    QWORD PTR [rsp],rbx
    4d9a:	mov    rsi,r12
    4d9d:	mov    rdi,r13
    4da0:	call   4da5 <botlish_fn_54+0x2dd>
			4da1: R_X86_64_PLT32	rt_list_len-0x4
    4da5:	mov    QWORD PTR [rsp+0x18],rax
    4daa:	mov    rdi,r13
    4dad:	mov    r12,rax
    4db0:	mov    rax,QWORD PTR [rdi+0x10]
    4db4:	mov    rdx,QWORD PTR [rax+0x68]
    4db8:	mov    QWORD PTR [rsp+0x20],rdx
    4dbd:	mov    rsi,r15
    4dc0:	call   4dc5 <botlish_fn_54+0x2fd>
			4dc1: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4dc5:	test   rax,rax
    4dc8:	je     4edc <botlish_fn_54+0x414>
    4dce:	mov    QWORD PTR [rsp+0x20],rax
    4dd3:	mov    rdi,r13
    4dd6:	mov    QWORD PTR [rsp+0x88],rax
    4dde:	mov    rax,QWORD PTR [rdi+0x10]
    4de2:	mov    rdx,QWORD PTR [rax+0x70]
    4de6:	mov    QWORD PTR [rsp+0x28],rdx
    4deb:	mov    rsi,r15
    4dee:	call   4df3 <botlish_fn_54+0x32b>
			4def: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4df3:	test   rax,rax
    4df6:	je     4edc <botlish_fn_54+0x414>
    4dfc:	mov    QWORD PTR [rsp+0x28],rax
    4e01:	mov    rdi,r13
    4e04:	mov    QWORD PTR [rsp+0x80],rax
    4e0c:	mov    rax,QWORD PTR [rdi+0x10]
    4e10:	mov    rdx,QWORD PTR [rax+0x78]
    4e14:	mov    QWORD PTR [rsp+0x30],rdx
    4e19:	mov    rsi,r15
    4e1c:	call   4e21 <botlish_fn_54+0x359>
			4e1d: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4e21:	test   rax,rax
    4e24:	je     4edc <botlish_fn_54+0x414>
    4e2a:	mov    QWORD PTR [rsp+0x8],rax
    4e2f:	mov    rdi,r13
    4e32:	mov    r15,rax
    4e35:	mov    rax,QWORD PTR [rdi+0x10]
    4e39:	mov    rdx,QWORD PTR [rax+0x68]
    4e3d:	mov    QWORD PTR [rsp+0x30],rdx
    4e42:	mov    rsi,r14
    4e45:	call   4e4a <botlish_fn_54+0x382>
			4e46: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4e4a:	test   rax,rax
    4e4d:	je     4edc <botlish_fn_54+0x414>
    4e53:	mov    QWORD PTR [rsp+0x30],rax
    4e58:	mov    rdi,r13
    4e5b:	mov    QWORD PTR [rsp+0x78],rax
    4e60:	mov    rax,QWORD PTR [rdi+0x10]
    4e64:	mov    rdx,QWORD PTR [rax+0x78]
    4e68:	mov    QWORD PTR [rsp+0x38],rdx
    4e6d:	mov    rsi,r14
    4e70:	call   4e75 <botlish_fn_54+0x3ad>
			4e71: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_get<any, str>
    4e75:	test   rax,rax
    4e78:	je     4edc <botlish_fn_54+0x414>
    4e7e:	mov    QWORD PTR [rsp+0x10],rax
    4e83:	lea    rdx,[rsp+0x40]
    4e88:	mov    r9,r12
    4e8b:	mov    QWORD PTR [rsp+0x40],r9
    4e90:	mov    rcx,QWORD PTR [rsp+0x88]
    4e98:	mov    QWORD PTR [rsp+0x48],rcx
    4e9d:	mov    rcx,QWORD PTR [rsp+0x80]
    4ea5:	mov    QWORD PTR [rsp+0x50],rcx
    4eaa:	mov    rcx,r15
    4ead:	mov    QWORD PTR [rsp+0x58],rcx
    4eb2:	mov    rcx,QWORD PTR [rsp+0x78]
    4eb7:	mov    QWORD PTR [rsp+0x60],rcx
    4ebc:	mov    QWORD PTR [rsp+0x68],rax
    4ec1:	mov    QWORD PTR [rsp+0x70],rbx
    4ec6:	mov    esi,0x7
    4ecb:	mov    rdi,r13
    4ece:	call   4ed3 <botlish_fn_54+0x40b>
			4ecf: R_X86_64_PLT32	rt_list_new-0x4
    4ed3:	test   rax,rax
    4ed6:	jne    4f13 <botlish_fn_54+0x44b>
    4edc:	xor    rax,rax
    4edf:	mov    rbx,QWORD PTR [rsp+0x90]
    4ee7:	mov    r12,QWORD PTR [rsp+0x98]
    4eef:	mov    r13,QWORD PTR [rsp+0xa0]
    4ef7:	mov    r14,QWORD PTR [rsp+0xa8]
    4eff:	mov    r15,QWORD PTR [rsp+0xb0]
    4f07:	add    rsp,0xc0
    4f0e:	mov    rsp,rbp
    4f11:	pop    rbp
    4f12:	ret
    4f13:	mov    rbx,QWORD PTR [rsp+0x90]
    4f1b:	mov    r12,QWORD PTR [rsp+0x98]
    4f23:	mov    r13,QWORD PTR [rsp+0xa0]
    4f2b:	mov    r14,QWORD PTR [rsp+0xa8]
    4f33:	mov    r15,QWORD PTR [rsp+0xb0]
    4f3b:	add    rsp,0xc0
    4f42:	mov    rsp,rbp
    4f45:	pop    rbp
    4f46:	ret
    4f47:	add    BYTE PTR [rsi],al
    4f49:	add    BYTE PTR [rax],al
    4f4b:	add    BYTE PTR [rax],al
    4f4d:	add    BYTE PTR [rax],al
	...

0000000000004f50 <botlish_entry_54: sample<generic>>:
    4f50:	push   rbp
    4f51:	mov    rbp,rsp
    4f54:	call   4f59 <botlish_entry_54+0x9>
			4f55: R_X86_64_PLT32	botlish_fn_54-0x4 ; sample<generic>
    4f59:	mov    rsp,rbp
    4f5c:	pop    rbp
    4f5d:	ret

; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 28701  (per function: 172 78 357 533 402 402 402 81 365 430 702 925 481 890 592 285 28 28 28 28 540 712 220 493 286 61 125 61 125 61 125 61 125 61 281 281 297 297 347 347 1036 1592 589 572 612 1585 1030 977 841 1496 1132 256 908 462 893 723 194 194 1494)
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
       4:	sub    rsp,0x10
       8:	mov    QWORD PTR [rsp],r12
       c:	mov    QWORD PTR [rsp+0x8],r13
      11:	mov    r12,QWORD PTR [rdi]
      14:	mov    r11,QWORD PTR [rdi+0x8]
      18:	lea    rax,[r12+0x8]
      1d:	cmp    rax,r11
      20:	ja     7d <botlish_fn_0+0x7d>
      26:	lea    rax,[r12+0x8]
      2b:	mov    QWORD PTR [rdi],rax
      2e:	mov    r13,rdi
      31:	mov    QWORD PTR [r12],0x0
      39:	mov    rdi,r13
      3c:	call   41 <botlish_fn_0+0x41>
			3d: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
      41:	test   rax,rax
      44:	jne    65 <botlish_fn_0+0x65>
      4a:	mov    rdi,r13
      4d:	mov    QWORD PTR [rdi],r12
      50:	xor    rax,rax
      53:	mov    r12,QWORD PTR [rsp]
      57:	mov    r13,QWORD PTR [rsp+0x8]
      5c:	add    rsp,0x10
      60:	mov    rsp,rbp
      63:	pop    rbp
      64:	ret
      65:	mov    rdi,r13
      68:	mov    QWORD PTR [rdi],r12
      6b:	mov    r12,QWORD PTR [rsp]
      6f:	mov    r13,QWORD PTR [rsp+0x8]
      74:	add    rsp,0x10
      78:	mov    rsp,rbp
      7b:	pop    rbp
      7c:	ret
      7d:	call   82 <botlish_fn_0+0x82>
			7e: R_X86_64_PLT32	rt_stack_overflow-0x4
      82:	xor    rax,rax
      85:	mov    r12,QWORD PTR [rsp]
      89:	mov    r13,QWORD PTR [rsp+0x8]
      8e:	add    rsp,0x10
      92:	mov    rsp,rbp
      95:	pop    rbp
      96:	ret

0000000000000097 <botlish_entry_0: <program entry>>:
      97:	push   rbp
      98:	mov    rbp,rsp
      9b:	call   a0 <botlish_entry_0+0x9>
			9c: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a0:	mov    rsp,rbp
      a3:	pop    rbp
      a4:	ret

00000000000000a5 <botlish_fn_1: geo_new<generic>>:
      a5:	push   rbp
      a6:	mov    rbp,rsp
      a9:	sub    rsp,0x10
      ad:	mov    esi,0x1
      b2:	mov    QWORD PTR [rsp],0x1
      ba:	call   bf <botlish_fn_1+0x1a>
			bb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      bf:	test   rax,rax
      c2:	jne    d7 <botlish_fn_1+0x32>
      c8:	xor    rdx,rdx
      cb:	mov    rax,rdx
      ce:	add    rsp,0x10
      d2:	mov    rsp,rbp
      d5:	pop    rbp
      d6:	ret
      d7:	mov    edx,0x1
      dc:	add    rsp,0x10
      e0:	mov    rsp,rbp
      e3:	pop    rbp
      e4:	ret

00000000000000e5 <botlish_entry_1: geo_new<generic>>:
      e5:	push   rbp
      e6:	mov    rbp,rsp
      e9:	ud2
      eb:	add    BYTE PTR [rax],al
      ed:	add    BYTE PTR [rax],al
	...

00000000000000f0 <botlish_fn_2: geo_new_capacity<int, int>>:
      f0:	push   rbp
      f1:	mov    rbp,rsp
      f4:	sub    rsp,0x40
      f8:	mov    QWORD PTR [rsp+0x20],rbx
      fd:	mov    QWORD PTR [rsp+0x28],r12
     102:	mov    QWORD PTR [rsp+0x30],r13
     107:	mov    r12,rdi
     10a:	mov    QWORD PTR [rsp],rsi
     10e:	mov    QWORD PTR [rsp+0x8],rdx
     113:	mov    rbx,rdx
     116:	mov    QWORD PTR [rsp+0x10],0x5
     11f:	test   rsi,0x1
     126:	je     148 <botlish_fn_2+0x58>
     12c:	mov    rax,rsi
     12f:	sar    rax,1
     132:	imul   QWORD PTR [rip+0xdf]        # 218 <botlish_fn_2+0x128>
     139:	seto   cl
     13c:	or     rax,0x1
     140:	test   cl,cl
     142:	je     155 <botlish_fn_2+0x65>
     148:	mov    edx,0x5
     14d:	mov    rdi,r12
     150:	call   155 <botlish_fn_2+0x65>
			151: R_X86_64_PLT32	rt_int_mul-0x4
     155:	mov    rcx,rax
     158:	and    rcx,rbx
     15b:	mov    r13,rax
     15e:	test   rcx,0x1
     165:	jne    191 <botlish_fn_2+0xa1>
     16b:	mov    rdx,rbx
     16e:	mov    rsi,r13
     171:	mov    rdi,r12
     174:	call   179 <botlish_fn_2+0x89>
			175: R_X86_64_PLT32	rt_int_cmp-0x4
     179:	mov    ecx,0x2
     17e:	test   rax,rax
     181:	cmovle rcx,QWORD PTR [rip+0x97]        # 220 <botlish_fn_2+0x130>
     189:	mov    rax,r13
     18c:	jmp    1a4 <botlish_fn_2+0xb4>
     191:	mov    ecx,0x2
     196:	mov    rax,r13
     199:	cmp    rax,rbx
     19c:	cmovle rcx,QWORD PTR [rip+0x7c]        # 220 <botlish_fn_2+0x130>
     1a4:	cmp    rcx,0x6
     1a8:	je     1c6 <botlish_fn_2+0xd6>
     1ae:	mov    rbx,QWORD PTR [rsp+0x20]
     1b3:	mov    r12,QWORD PTR [rsp+0x28]
     1b8:	mov    r13,QWORD PTR [rsp+0x30]
     1bd:	add    rsp,0x40
     1c1:	mov    rsp,rbp
     1c4:	pop    rbp
     1c5:	ret
     1c6:	mov    QWORD PTR [rsp],0x3
     1ce:	test   rbx,0x1
     1d5:	je     1ed <botlish_fn_2+0xfd>
     1db:	mov    rax,rbx
     1de:	add    rax,0x2
     1e2:	seto   cl
     1e5:	test   cl,cl
     1e7:	je     1fd <botlish_fn_2+0x10d>
     1ed:	mov    edx,0x3
     1f2:	mov    rsi,rbx
     1f5:	mov    rdi,r12
     1f8:	call   1fd <botlish_fn_2+0x10d>
			1f9: R_X86_64_PLT32	rt_int_add-0x4
     1fd:	mov    rbx,QWORD PTR [rsp+0x20]
     202:	mov    r12,QWORD PTR [rsp+0x28]
     207:	mov    r13,QWORD PTR [rsp+0x30]
     20c:	add    rsp,0x40
     210:	mov    rsp,rbp
     213:	pop    rbp
     214:	ret
     215:	add    BYTE PTR [rax],al
     217:	add    BYTE PTR [rax+rax*1],al
     21a:	add    BYTE PTR [rax],al
     21c:	add    BYTE PTR [rax],al
     21e:	add    BYTE PTR [rax],al
     220:	(bad)
     221:	add    BYTE PTR [rax],al
     223:	add    BYTE PTR [rax],al
     225:	add    BYTE PTR [rax],al
	...

0000000000000228 <botlish_entry_2: geo_new_capacity<int, int>>:
     228:	push   rbp
     229:	mov    rbp,rsp
     22c:	mov    rsi,QWORD PTR [rdx]
     22f:	mov    rdx,QWORD PTR [rdx+0x8]
     233:	call   238 <botlish_entry_2+0x10>
			234: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     238:	mov    rsp,rbp
     23b:	pop    rbp
     23c:	ret
     23d:	add    BYTE PTR [rax],al
	...

0000000000000240 <botlish_fn_3: geo_grow<mutarray, int>>:
     240:	push   rbp
     241:	mov    rbp,rsp
     244:	sub    rsp,0x50
     248:	mov    QWORD PTR [rsp+0x20],rbx
     24d:	mov    QWORD PTR [rsp+0x28],r12
     252:	mov    QWORD PTR [rsp+0x30],r13
     257:	mov    QWORD PTR [rsp+0x38],r14
     25c:	mov    QWORD PTR [rsp+0x40],r15
     261:	mov    rbx,QWORD PTR [rdi]
     264:	mov    rax,QWORD PTR [rdi+0x8]
     268:	lea    rcx,[rbx+0x8]
     26c:	cmp    rcx,rax
     26f:	ja     3e8 <botlish_fn_3+0x1a8>
     275:	lea    rax,[rbx+0x8]
     279:	mov    QWORD PTR [rdi],rax
     27c:	mov    r13,rdi
     27f:	mov    QWORD PTR [rbx],0x0
     286:	mov    QWORD PTR [rsp],rsi
     28a:	mov    r14,rsi
     28d:	mov    QWORD PTR [rsp+0x8],rdx
     292:	mov    r12,rdx
     295:	mov    rsi,r14
     298:	mov    rdi,r13
     29b:	call   2a0 <botlish_fn_3+0x60>
			29c: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     2a0:	mov    r15,rax
     2a3:	mov    QWORD PTR [rsp+0x10],rax
     2a8:	mov    rcx,r12
     2ab:	and    rcx,rax
     2ae:	test   rcx,0x1
     2b5:	jne    2e1 <botlish_fn_3+0xa1>
     2bb:	mov    rdx,r15
     2be:	mov    rsi,r12
     2c1:	mov    rdi,r13
     2c4:	call   2c9 <botlish_fn_3+0x89>
			2c5: R_X86_64_PLT32	rt_int_cmp-0x4
     2c9:	mov    ecx,0x2
     2ce:	test   rax,rax
     2d1:	cmovl  rcx,QWORD PTR [rip+0x13f]        # 418 <botlish_fn_3+0x1d8>
     2d9:	mov    rax,r15
     2dc:	jmp    2f4 <botlish_fn_3+0xb4>
     2e1:	mov    ecx,0x2
     2e6:	mov    rax,r15
     2e9:	cmp    r12,rax
     2ec:	cmovl  rcx,QWORD PTR [rip+0x124]        # 418 <botlish_fn_3+0x1d8>
     2f4:	cmp    rcx,0x6
     2f8:	je     3bd <botlish_fn_3+0x17d>
     2fe:	mov    rsi,rax
     301:	mov    rdx,r12
     304:	mov    rdi,r13
     307:	call   30c <botlish_fn_3+0xcc>
			308: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     30c:	test   rax,rax
     30f:	jne    31d <botlish_fn_3+0xdd>
     315:	mov    rdi,r13
     318:	jmp    367 <botlish_fn_3+0x127>
     31d:	mov    QWORD PTR [rsp+0x10],rax
     322:	mov    rsi,rax
     325:	mov    rdi,r13
     328:	call   32d <botlish_fn_3+0xed>
			329: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     32d:	test   rax,rax
     330:	mov    r15,rax
     333:	jne    341 <botlish_fn_3+0x101>
     339:	mov    rdi,r13
     33c:	jmp    367 <botlish_fn_3+0x127>
     341:	mov    r8d,0x1
     347:	mov    rcx,r14
     34a:	mov    r9,r12
     34d:	mov    rsi,r15
     350:	mov    rdi,r13
     353:	mov    rdx,r8
     356:	call   35b <botlish_fn_3+0x11b>
			357: R_X86_64_PLT32	rt_mutarray_copy-0x4
     35b:	test   rax,rax
     35e:	jne    392 <botlish_fn_3+0x152>
     364:	mov    rdi,r13
     367:	mov    rdi,r13
     36a:	mov    QWORD PTR [rdi],rbx
     36d:	xor    rax,rax
     370:	mov    rbx,QWORD PTR [rsp+0x20]
     375:	mov    r12,QWORD PTR [rsp+0x28]
     37a:	mov    r13,QWORD PTR [rsp+0x30]
     37f:	mov    r14,QWORD PTR [rsp+0x38]
     384:	mov    r15,QWORD PTR [rsp+0x40]
     389:	add    rsp,0x50
     38d:	mov    rsp,rbp
     390:	pop    rbp
     391:	ret
     392:	mov    rdi,r13
     395:	mov    QWORD PTR [rdi],rbx
     398:	mov    rax,r15
     39b:	mov    rbx,QWORD PTR [rsp+0x20]
     3a0:	mov    r12,QWORD PTR [rsp+0x28]
     3a5:	mov    r13,QWORD PTR [rsp+0x30]
     3aa:	mov    r14,QWORD PTR [rsp+0x38]
     3af:	mov    r15,QWORD PTR [rsp+0x40]
     3b4:	add    rsp,0x50
     3b8:	mov    rsp,rbp
     3bb:	pop    rbp
     3bc:	ret
     3bd:	mov    rdi,r13
     3c0:	mov    QWORD PTR [rdi],rbx
     3c3:	mov    rax,r14
     3c6:	mov    rbx,QWORD PTR [rsp+0x20]
     3cb:	mov    r12,QWORD PTR [rsp+0x28]
     3d0:	mov    r13,QWORD PTR [rsp+0x30]
     3d5:	mov    r14,QWORD PTR [rsp+0x38]
     3da:	mov    r15,QWORD PTR [rsp+0x40]
     3df:	add    rsp,0x50
     3e3:	mov    rsp,rbp
     3e6:	pop    rbp
     3e7:	ret
     3e8:	mov    r13,rdi
     3eb:	call   3f0 <botlish_fn_3+0x1b0>
			3ec: R_X86_64_PLT32	rt_stack_overflow-0x4
     3f0:	xor    rax,rax
     3f3:	mov    rbx,QWORD PTR [rsp+0x20]
     3f8:	mov    r12,QWORD PTR [rsp+0x28]
     3fd:	mov    r13,QWORD PTR [rsp+0x30]
     402:	mov    r14,QWORD PTR [rsp+0x38]
     407:	mov    r15,QWORD PTR [rsp+0x40]
     40c:	add    rsp,0x50
     410:	mov    rsp,rbp
     413:	pop    rbp
     414:	ret
     415:	add    BYTE PTR [rax],al
     417:	add    BYTE PTR [rsi],al
     419:	add    BYTE PTR [rax],al
     41b:	add    BYTE PTR [rax],al
     41d:	add    BYTE PTR [rax],al
	...

0000000000000420 <botlish_entry_3: geo_grow<mutarray, int>>:
     420:	push   rbp
     421:	mov    rbp,rsp
     424:	mov    rsi,QWORD PTR [rdx]
     427:	mov    rdx,QWORD PTR [rdx+0x8]
     42b:	call   430 <botlish_entry_3+0x10>
			42c: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     430:	mov    rsp,rbp
     433:	pop    rbp
     434:	ret

0000000000000435 <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     435:	push   rbp
     436:	mov    rbp,rsp
     439:	sub    rsp,0x40
     43d:	mov    QWORD PTR [rsp+0x20],rbx
     442:	mov    QWORD PTR [rsp+0x28],r12
     447:	mov    QWORD PTR [rsp+0x30],r13
     44c:	mov    QWORD PTR [rsp+0x38],r14
     451:	mov    rbx,QWORD PTR [rdi]
     454:	mov    rax,QWORD PTR [rdi+0x8]
     458:	lea    r8,[rbx+0x8]
     45c:	cmp    r8,rax
     45f:	ja     56d <botlish_fn_4+0x138>
     465:	lea    rax,[rbx+0x8]
     469:	mov    QWORD PTR [rdi],rax
     46c:	mov    r13,rdi
     46f:	mov    QWORD PTR [rbx],0x0
     476:	mov    QWORD PTR [rsp],rsi
     47a:	mov    QWORD PTR [rsp+0x8],rdx
     47f:	mov    rdi,rdx
     482:	mov    QWORD PTR [rsp+0x10],rcx
     487:	mov    r14,rcx
     48a:	mov    r12,rdi
     48d:	mov    rdx,r12
     490:	mov    rdi,r13
     493:	call   498 <botlish_fn_4+0x63>
			494: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     498:	test   rax,rax
     49b:	jne    4a9 <botlish_fn_4+0x74>
     4a1:	mov    rdi,r13
     4a4:	jmp    4cd <botlish_fn_4+0x98>
     4a9:	mov    QWORD PTR [rsp],rax
     4ad:	mov    rcx,r14
     4b0:	mov    r14,rax
     4b3:	mov    rdx,r12
     4b6:	mov    rsi,r14
     4b9:	mov    rdi,r13
     4bc:	call   4c1 <botlish_fn_4+0x8c>
			4bd: R_X86_64_PLT32	rt_mutarray_set-0x4
     4c1:	test   rax,rax
     4c4:	jne    4f6 <botlish_fn_4+0xc1>
     4ca:	mov    rdi,r13
     4cd:	mov    rdi,r13
     4d0:	mov    QWORD PTR [rdi],rbx
     4d3:	xor    rdx,rdx
     4d6:	mov    rax,rdx
     4d9:	mov    rbx,QWORD PTR [rsp+0x20]
     4de:	mov    r12,QWORD PTR [rsp+0x28]
     4e3:	mov    r13,QWORD PTR [rsp+0x30]
     4e8:	mov    r14,QWORD PTR [rsp+0x38]
     4ed:	add    rsp,0x40
     4f1:	mov    rsp,rbp
     4f4:	pop    rbp
     4f5:	ret
     4f6:	mov    QWORD PTR [rsp+0x10],0x3
     4ff:	test   r12,0x1
     506:	jne    514 <botlish_fn_4+0xdf>
     50c:	mov    rdi,r12
     50f:	jmp    531 <botlish_fn_4+0xfc>
     514:	mov    rdx,r12
     517:	add    rdx,0x2
     51b:	mov    rdi,r12
     51e:	seto   al
     521:	test   al,al
     523:	jne    531 <botlish_fn_4+0xfc>
     529:	mov    rdi,r13
     52c:	jmp    547 <botlish_fn_4+0x112>
     531:	mov    edx,0x3
     536:	mov    rsi,rdi
     539:	mov    rdi,r13
     53c:	call   541 <botlish_fn_4+0x10c>
			53d: R_X86_64_PLT32	rt_int_add-0x4
     541:	mov    rdx,rax
     544:	mov    rdi,r13
     547:	mov    rdi,r13
     54a:	mov    QWORD PTR [rdi],rbx
     54d:	mov    rax,r14
     550:	mov    rbx,QWORD PTR [rsp+0x20]
     555:	mov    r12,QWORD PTR [rsp+0x28]
     55a:	mov    r13,QWORD PTR [rsp+0x30]
     55f:	mov    r14,QWORD PTR [rsp+0x38]
     564:	add    rsp,0x40
     568:	mov    rsp,rbp
     56b:	pop    rbp
     56c:	ret
     56d:	mov    r13,rdi
     570:	call   575 <botlish_fn_4+0x140>
			571: R_X86_64_PLT32	rt_stack_overflow-0x4
     575:	xor    rdx,rdx
     578:	mov    rax,rdx
     57b:	mov    rbx,QWORD PTR [rsp+0x20]
     580:	mov    r12,QWORD PTR [rsp+0x28]
     585:	mov    r13,QWORD PTR [rsp+0x30]
     58a:	mov    r14,QWORD PTR [rsp+0x38]
     58f:	add    rsp,0x40
     593:	mov    rsp,rbp
     596:	pop    rbp
     597:	ret

0000000000000598 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     598:	push   rbp
     599:	mov    rbp,rsp
     59c:	ud2

000000000000059e <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     59e:	push   rbp
     59f:	mov    rbp,rsp
     5a2:	sub    rsp,0x40
     5a6:	mov    QWORD PTR [rsp+0x20],rbx
     5ab:	mov    QWORD PTR [rsp+0x28],r12
     5b0:	mov    QWORD PTR [rsp+0x30],r13
     5b5:	mov    QWORD PTR [rsp+0x38],r14
     5ba:	mov    rbx,QWORD PTR [rdi]
     5bd:	mov    rax,QWORD PTR [rdi+0x8]
     5c1:	lea    r8,[rbx+0x8]
     5c5:	cmp    r8,rax
     5c8:	ja     6d6 <botlish_fn_5+0x138>
     5ce:	lea    rax,[rbx+0x8]
     5d2:	mov    QWORD PTR [rdi],rax
     5d5:	mov    r13,rdi
     5d8:	mov    QWORD PTR [rbx],0x0
     5df:	mov    QWORD PTR [rsp],rsi
     5e3:	mov    QWORD PTR [rsp+0x8],rdx
     5e8:	mov    rdi,rdx
     5eb:	mov    QWORD PTR [rsp+0x10],rcx
     5f0:	mov    r14,rcx
     5f3:	mov    r12,rdi
     5f6:	mov    rdx,r12
     5f9:	mov    rdi,r13
     5fc:	call   601 <botlish_fn_5+0x63>
			5fd: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     601:	test   rax,rax
     604:	jne    612 <botlish_fn_5+0x74>
     60a:	mov    rdi,r13
     60d:	jmp    636 <botlish_fn_5+0x98>
     612:	mov    QWORD PTR [rsp],rax
     616:	mov    rcx,r14
     619:	mov    r14,rax
     61c:	mov    rdx,r12
     61f:	mov    rsi,r14
     622:	mov    rdi,r13
     625:	call   62a <botlish_fn_5+0x8c>
			626: R_X86_64_PLT32	rt_mutarray_set-0x4
     62a:	test   rax,rax
     62d:	jne    65f <botlish_fn_5+0xc1>
     633:	mov    rdi,r13
     636:	mov    rdi,r13
     639:	mov    QWORD PTR [rdi],rbx
     63c:	xor    rdx,rdx
     63f:	mov    rax,rdx
     642:	mov    rbx,QWORD PTR [rsp+0x20]
     647:	mov    r12,QWORD PTR [rsp+0x28]
     64c:	mov    r13,QWORD PTR [rsp+0x30]
     651:	mov    r14,QWORD PTR [rsp+0x38]
     656:	add    rsp,0x40
     65a:	mov    rsp,rbp
     65d:	pop    rbp
     65e:	ret
     65f:	mov    QWORD PTR [rsp+0x10],0x3
     668:	test   r12,0x1
     66f:	jne    67d <botlish_fn_5+0xdf>
     675:	mov    rdi,r12
     678:	jmp    69a <botlish_fn_5+0xfc>
     67d:	mov    rdx,r12
     680:	add    rdx,0x2
     684:	mov    rdi,r12
     687:	seto   al
     68a:	test   al,al
     68c:	jne    69a <botlish_fn_5+0xfc>
     692:	mov    rdi,r13
     695:	jmp    6b0 <botlish_fn_5+0x112>
     69a:	mov    edx,0x3
     69f:	mov    rsi,rdi
     6a2:	mov    rdi,r13
     6a5:	call   6aa <botlish_fn_5+0x10c>
			6a6: R_X86_64_PLT32	rt_int_add-0x4
     6aa:	mov    rdx,rax
     6ad:	mov    rdi,r13
     6b0:	mov    rdi,r13
     6b3:	mov    QWORD PTR [rdi],rbx
     6b6:	mov    rax,r14
     6b9:	mov    rbx,QWORD PTR [rsp+0x20]
     6be:	mov    r12,QWORD PTR [rsp+0x28]
     6c3:	mov    r13,QWORD PTR [rsp+0x30]
     6c8:	mov    r14,QWORD PTR [rsp+0x38]
     6cd:	add    rsp,0x40
     6d1:	mov    rsp,rbp
     6d4:	pop    rbp
     6d5:	ret
     6d6:	mov    r13,rdi
     6d9:	call   6de <botlish_fn_5+0x140>
			6da: R_X86_64_PLT32	rt_stack_overflow-0x4
     6de:	xor    rdx,rdx
     6e1:	mov    rax,rdx
     6e4:	mov    rbx,QWORD PTR [rsp+0x20]
     6e9:	mov    r12,QWORD PTR [rsp+0x28]
     6ee:	mov    r13,QWORD PTR [rsp+0x30]
     6f3:	mov    r14,QWORD PTR [rsp+0x38]
     6f8:	add    rsp,0x40
     6fc:	mov    rsp,rbp
     6ff:	pop    rbp
     700:	ret

0000000000000701 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     701:	push   rbp
     702:	mov    rbp,rsp
     705:	ud2

0000000000000707 <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     707:	push   rbp
     708:	mov    rbp,rsp
     70b:	sub    rsp,0x40
     70f:	mov    QWORD PTR [rsp+0x20],rbx
     714:	mov    QWORD PTR [rsp+0x28],r12
     719:	mov    QWORD PTR [rsp+0x30],r13
     71e:	mov    QWORD PTR [rsp+0x38],r14
     723:	mov    rbx,QWORD PTR [rdi]
     726:	mov    rax,QWORD PTR [rdi+0x8]
     72a:	lea    r8,[rbx+0x8]
     72e:	cmp    r8,rax
     731:	ja     83f <botlish_fn_6+0x138>
     737:	lea    rax,[rbx+0x8]
     73b:	mov    QWORD PTR [rdi],rax
     73e:	mov    r13,rdi
     741:	mov    QWORD PTR [rbx],0x0
     748:	mov    QWORD PTR [rsp],rsi
     74c:	mov    QWORD PTR [rsp+0x8],rdx
     751:	mov    rdi,rdx
     754:	mov    QWORD PTR [rsp+0x10],rcx
     759:	mov    r14,rcx
     75c:	mov    r12,rdi
     75f:	mov    rdx,r12
     762:	mov    rdi,r13
     765:	call   76a <botlish_fn_6+0x63>
			766: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     76a:	test   rax,rax
     76d:	jne    77b <botlish_fn_6+0x74>
     773:	mov    rdi,r13
     776:	jmp    79f <botlish_fn_6+0x98>
     77b:	mov    QWORD PTR [rsp],rax
     77f:	mov    rcx,r14
     782:	mov    r14,rax
     785:	mov    rdx,r12
     788:	mov    rsi,r14
     78b:	mov    rdi,r13
     78e:	call   793 <botlish_fn_6+0x8c>
			78f: R_X86_64_PLT32	rt_mutarray_set-0x4
     793:	test   rax,rax
     796:	jne    7c8 <botlish_fn_6+0xc1>
     79c:	mov    rdi,r13
     79f:	mov    rdi,r13
     7a2:	mov    QWORD PTR [rdi],rbx
     7a5:	xor    rdx,rdx
     7a8:	mov    rax,rdx
     7ab:	mov    rbx,QWORD PTR [rsp+0x20]
     7b0:	mov    r12,QWORD PTR [rsp+0x28]
     7b5:	mov    r13,QWORD PTR [rsp+0x30]
     7ba:	mov    r14,QWORD PTR [rsp+0x38]
     7bf:	add    rsp,0x40
     7c3:	mov    rsp,rbp
     7c6:	pop    rbp
     7c7:	ret
     7c8:	mov    QWORD PTR [rsp+0x10],0x3
     7d1:	test   r12,0x1
     7d8:	jne    7e6 <botlish_fn_6+0xdf>
     7de:	mov    rdi,r12
     7e1:	jmp    803 <botlish_fn_6+0xfc>
     7e6:	mov    rdx,r12
     7e9:	add    rdx,0x2
     7ed:	mov    rdi,r12
     7f0:	seto   al
     7f3:	test   al,al
     7f5:	jne    803 <botlish_fn_6+0xfc>
     7fb:	mov    rdi,r13
     7fe:	jmp    819 <botlish_fn_6+0x112>
     803:	mov    edx,0x3
     808:	mov    rsi,rdi
     80b:	mov    rdi,r13
     80e:	call   813 <botlish_fn_6+0x10c>
			80f: R_X86_64_PLT32	rt_int_add-0x4
     813:	mov    rdx,rax
     816:	mov    rdi,r13
     819:	mov    rdi,r13
     81c:	mov    QWORD PTR [rdi],rbx
     81f:	mov    rax,r14
     822:	mov    rbx,QWORD PTR [rsp+0x20]
     827:	mov    r12,QWORD PTR [rsp+0x28]
     82c:	mov    r13,QWORD PTR [rsp+0x30]
     831:	mov    r14,QWORD PTR [rsp+0x38]
     836:	add    rsp,0x40
     83a:	mov    rsp,rbp
     83d:	pop    rbp
     83e:	ret
     83f:	mov    r13,rdi
     842:	call   847 <botlish_fn_6+0x140>
			843: R_X86_64_PLT32	rt_stack_overflow-0x4
     847:	xor    rdx,rdx
     84a:	mov    rax,rdx
     84d:	mov    rbx,QWORD PTR [rsp+0x20]
     852:	mov    r12,QWORD PTR [rsp+0x28]
     857:	mov    r13,QWORD PTR [rsp+0x30]
     85c:	mov    r14,QWORD PTR [rsp+0x38]
     861:	add    rsp,0x40
     865:	mov    rsp,rbp
     868:	pop    rbp
     869:	ret

000000000000086a <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     86a:	push   rbp
     86b:	mov    rbp,rsp
     86e:	ud2

0000000000000870 <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     870:	push   rbp
     871:	mov    rbp,rsp
     874:	sub    rsp,0x10
     878:	mov    QWORD PTR [rsp],rsi
     87c:	mov    QWORD PTR [rsp+0x8],rdx
     881:	call   886 <botlish_fn_7+0x16>
			882: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     886:	test   rax,rax
     889:	jne    89b <botlish_fn_7+0x2b>
     88f:	xor    rax,rax
     892:	add    rsp,0x10
     896:	mov    rsp,rbp
     899:	pop    rbp
     89a:	ret
     89b:	add    rsp,0x10
     89f:	mov    rsp,rbp
     8a2:	pop    rbp
     8a3:	ret

00000000000008a4 <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     8a4:	push   rbp
     8a5:	mov    rbp,rsp
     8a8:	mov    rsi,QWORD PTR [rdx]
     8ab:	mov    rdx,QWORD PTR [rdx+0x8]
     8af:	call   8b4 <botlish_entry_7+0x10>
			8b0: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     8b4:	mov    rsp,rbp
     8b7:	pop    rbp
     8b8:	ret
     8b9:	add    BYTE PTR [rax],al
     8bb:	add    BYTE PTR [rax],al
     8bd:	add    BYTE PTR [rax],al
	...

00000000000008c0 <botlish_fn_8: peek<str, int>>:
     8c0:	push   rbp
     8c1:	mov    rbp,rsp
     8c4:	sub    rsp,0x40
     8c8:	mov    QWORD PTR [rsp+0x20],rbx
     8cd:	mov    QWORD PTR [rsp+0x28],r12
     8d2:	mov    QWORD PTR [rsp+0x30],r13
     8d7:	mov    r13,rdi
     8da:	mov    QWORD PTR [rsp],rsi
     8de:	mov    r12,rsi
     8e1:	mov    QWORD PTR [rsp+0x8],rdx
     8e6:	mov    rbx,rdx
     8e9:	mov    rsi,r12
     8ec:	mov    rdi,r13
     8ef:	call   8f4 <botlish_fn_8+0x34>
			8f0: R_X86_64_PLT32	rt_str_len-0x4
     8f4:	mov    rcx,rbx
     8f7:	and    rcx,rax
     8fa:	mov    rdx,rax
     8fd:	test   rcx,0x1
     904:	jne    92a <botlish_fn_8+0x6a>
     90a:	mov    rsi,rbx
     90d:	mov    rdi,r13
     910:	call   915 <botlish_fn_8+0x55>
			911: R_X86_64_PLT32	rt_int_cmp-0x4
     915:	mov    ecx,0x2
     91a:	test   rax,rax
     91d:	cmovge rcx,QWORD PTR [rip+0xcb]        # 9f0 <botlish_fn_8+0x130>
     925:	jmp    93a <botlish_fn_8+0x7a>
     92a:	mov    ecx,0x2
     92f:	cmp    rbx,rdx
     932:	cmovge rcx,QWORD PTR [rip+0xb6]        # 9f0 <botlish_fn_8+0x130>
     93a:	cmp    rcx,0x6
     93e:	je     9ce <botlish_fn_8+0x10e>
     944:	mov    QWORD PTR [rsp+0x10],0x3
     94d:	test   rbx,0x1
     954:	je     96c <botlish_fn_8+0xac>
     95a:	mov    rcx,rbx
     95d:	add    rcx,0x2
     961:	seto   al
     964:	test   al,al
     966:	je     97f <botlish_fn_8+0xbf>
     96c:	mov    edx,0x3
     971:	mov    rsi,rbx
     974:	mov    rdi,r13
     977:	call   97c <botlish_fn_8+0xbc>
			978: R_X86_64_PLT32	rt_int_add-0x4
     97c:	mov    rcx,rax
     97f:	mov    QWORD PTR [rsp+0x10],rcx
     984:	mov    rdx,rbx
     987:	mov    rsi,r12
     98a:	mov    rdi,r13
     98d:	call   992 <botlish_fn_8+0xd2>
			98e: R_X86_64_PLT32	rt_substr-0x4
     992:	test   rax,rax
     995:	jne    9b6 <botlish_fn_8+0xf6>
     99b:	xor    rax,rax
     99e:	mov    rbx,QWORD PTR [rsp+0x20]
     9a3:	mov    r12,QWORD PTR [rsp+0x28]
     9a8:	mov    r13,QWORD PTR [rsp+0x30]
     9ad:	add    rsp,0x40
     9b1:	mov    rsp,rbp
     9b4:	pop    rbp
     9b5:	ret
     9b6:	mov    rbx,QWORD PTR [rsp+0x20]
     9bb:	mov    r12,QWORD PTR [rsp+0x28]
     9c0:	mov    r13,QWORD PTR [rsp+0x30]
     9c5:	add    rsp,0x40
     9c9:	mov    rsp,rbp
     9cc:	pop    rbp
     9cd:	ret
     9ce:	mov    rdi,r13
     9d1:	mov    rax,QWORD PTR [rdi+0x10]
     9d5:	mov    rax,QWORD PTR [rax]
     9d8:	mov    rbx,QWORD PTR [rsp+0x20]
     9dd:	mov    r12,QWORD PTR [rsp+0x28]
     9e2:	mov    r13,QWORD PTR [rsp+0x30]
     9e7:	add    rsp,0x40
     9eb:	mov    rsp,rbp
     9ee:	pop    rbp
     9ef:	ret
     9f0:	(bad)
     9f1:	add    BYTE PTR [rax],al
     9f3:	add    BYTE PTR [rax],al
     9f5:	add    BYTE PTR [rax],al
	...

00000000000009f8 <botlish_entry_8: peek<str, int>>:
     9f8:	push   rbp
     9f9:	mov    rbp,rsp
     9fc:	mov    rsi,QWORD PTR [rdx]
     9ff:	mov    rdx,QWORD PTR [rdx+0x8]
     a03:	call   a08 <botlish_entry_8+0x10>
			a04: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     a08:	mov    rsp,rbp
     a0b:	pop    rbp
     a0c:	ret
     a0d:	add    BYTE PTR [rax],al
	...

0000000000000a10 <botlish_fn_9: peek<str, int>>:
     a10:	push   rbp
     a11:	mov    rbp,rsp
     a14:	sub    rsp,0x50
     a18:	mov    QWORD PTR [rsp+0x20],rbx
     a1d:	mov    QWORD PTR [rsp+0x28],r12
     a22:	mov    QWORD PTR [rsp+0x30],r13
     a27:	mov    QWORD PTR [rsp+0x38],r14
     a2c:	mov    QWORD PTR [rsp+0x40],r15
     a31:	mov    r12,rcx
     a34:	mov    r14,rdi
     a37:	mov    QWORD PTR [rsp],rsi
     a3b:	mov    r13,rsi
     a3e:	mov    QWORD PTR [rsp+0x8],rdx
     a43:	mov    rbx,rdx
     a46:	mov    rsi,r13
     a49:	mov    rdi,r14
     a4c:	call   a51 <botlish_fn_9+0x41>
			a4d: R_X86_64_PLT32	rt_str_len-0x4
     a51:	mov    rcx,rbx
     a54:	and    rcx,rax
     a57:	mov    rdx,rax
     a5a:	test   rcx,0x1
     a61:	jne    a87 <botlish_fn_9+0x77>
     a67:	mov    rsi,rbx
     a6a:	mov    rdi,r14
     a6d:	call   a72 <botlish_fn_9+0x62>
			a6e: R_X86_64_PLT32	rt_int_cmp-0x4
     a72:	mov    ecx,0x2
     a77:	test   rax,rax
     a7a:	cmovge rcx,QWORD PTR [rip+0x11e]        # ba0 <botlish_fn_9+0x190>
     a82:	jmp    a97 <botlish_fn_9+0x87>
     a87:	mov    ecx,0x2
     a8c:	cmp    rbx,rdx
     a8f:	cmovge rcx,QWORD PTR [rip+0x109]        # ba0 <botlish_fn_9+0x190>
     a97:	cmp    rcx,0x6
     a9b:	je     b5b <botlish_fn_9+0x14b>
     aa1:	mov    QWORD PTR [rsp+0x10],0x3
     aaa:	test   rbx,0x1
     ab1:	je     ad4 <botlish_fn_9+0xc4>
     ab7:	mov    rax,rbx
     aba:	add    rax,0x2
     abe:	seto   cl
     ac1:	test   cl,cl
     ac3:	jne    ad4 <botlish_fn_9+0xc4>
     ac9:	mov    rdi,r14
     acc:	mov    r15,rax
     acf:	jmp    aea <botlish_fn_9+0xda>
     ad4:	mov    edx,0x3
     ad9:	mov    rsi,rbx
     adc:	mov    rdi,r14
     adf:	call   ae4 <botlish_fn_9+0xd4>
			ae0: R_X86_64_PLT32	rt_int_add-0x4
     ae4:	mov    r15,rax
     ae7:	mov    rdi,r14
     aea:	mov    rdi,r14
     aed:	mov    rcx,r15
     af0:	mov    rdx,rbx
     af3:	mov    rsi,r13
     af6:	call   afb <botlish_fn_9+0xeb>
			af7: R_X86_64_PLT32	rt_str_region_check-0x4
     afb:	test   rax,rax
     afe:	jne    b29 <botlish_fn_9+0x119>
     b04:	xor    rax,rax
     b07:	mov    rbx,QWORD PTR [rsp+0x20]
     b0c:	mov    r12,QWORD PTR [rsp+0x28]
     b11:	mov    r13,QWORD PTR [rsp+0x30]
     b16:	mov    r14,QWORD PTR [rsp+0x38]
     b1b:	mov    r15,QWORD PTR [rsp+0x40]
     b20:	add    rsp,0x50
     b24:	mov    rsp,rbp
     b27:	pop    rbp
     b28:	ret
     b29:	mov    rcx,r12
     b2c:	mov    QWORD PTR [rcx],rbx
     b2f:	mov    rax,r15
     b32:	mov    QWORD PTR [rcx+0x8],rax
     b36:	mov    rax,r13
     b39:	mov    rbx,QWORD PTR [rsp+0x20]
     b3e:	mov    r12,QWORD PTR [rsp+0x28]
     b43:	mov    r13,QWORD PTR [rsp+0x30]
     b48:	mov    r14,QWORD PTR [rsp+0x38]
     b4d:	mov    r15,QWORD PTR [rsp+0x40]
     b52:	add    rsp,0x50
     b56:	mov    rsp,rbp
     b59:	pop    rbp
     b5a:	ret
     b5b:	mov    rcx,r12
     b5e:	mov    rdi,r14
     b61:	mov    rax,QWORD PTR [rdi+0x10]
     b65:	mov    rax,QWORD PTR [rax]
     b68:	mov    QWORD PTR [rcx],0x1
     b6f:	mov    QWORD PTR [rcx+0x8],0x1
     b77:	mov    rbx,QWORD PTR [rsp+0x20]
     b7c:	mov    r12,QWORD PTR [rsp+0x28]
     b81:	mov    r13,QWORD PTR [rsp+0x30]
     b86:	mov    r14,QWORD PTR [rsp+0x38]
     b8b:	mov    r15,QWORD PTR [rsp+0x40]
     b90:	add    rsp,0x50
     b94:	mov    rsp,rbp
     b97:	pop    rbp
     b98:	ret
     b99:	add    BYTE PTR [rax],al
     b9b:	add    BYTE PTR [rax],al
     b9d:	add    BYTE PTR [rax],al
     b9f:	add    BYTE PTR [rsi],al
     ba1:	add    BYTE PTR [rax],al
     ba3:	add    BYTE PTR [rax],al
     ba5:	add    BYTE PTR [rax],al
	...

0000000000000ba8 <botlish_entry_9: peek<str, int>>:
     ba8:	push   rbp
     ba9:	mov    rbp,rsp
     bac:	ud2

0000000000000bae <botlish_fn_10: scan_unquoted<str, int, int>>:
     bae:	push   rbp
     baf:	mov    rbp,rsp
     bb2:	sub    rsp,0x80
     bb9:	mov    QWORD PTR [rsp+0x50],rbx
     bbe:	mov    QWORD PTR [rsp+0x58],r12
     bc3:	mov    QWORD PTR [rsp+0x60],r13
     bc8:	mov    QWORD PTR [rsp+0x68],r14
     bcd:	mov    QWORD PTR [rsp+0x70],r15
     bd2:	mov    r14,QWORD PTR [rdi]
     bd5:	mov    rax,QWORD PTR [rdi+0x8]
     bd9:	lea    r8,[r14+0x8]
     bdd:	cmp    r8,rax
     be0:	ja     e07 <botlish_fn_10+0x259>
     be6:	lea    rax,[r14+0x8]
     bea:	mov    QWORD PTR [rdi],rax
     bed:	mov    r15,rdi
     bf0:	mov    QWORD PTR [r14],0x0
     bf7:	mov    QWORD PTR [rsp+0x18],0x0
     c00:	mov    QWORD PTR [rsp],rsi
     c04:	mov    QWORD PTR [rsp+0x30],rsi
     c09:	mov    QWORD PTR [rsp+0x8],rdx
     c0e:	mov    QWORD PTR [rsp+0x38],rdx
     c13:	mov    QWORD PTR [rsp+0x10],rcx
     c18:	lea    rbx,[rsp+0x20]
     c1d:	mov    QWORD PTR [rsp+0x40],rcx
     c22:	mov    rcx,rbx
     c25:	mov    rdx,QWORD PTR [rsp+0x40]
     c2a:	mov    rsi,QWORD PTR [rsp+0x30]
     c2f:	mov    rdi,r15
     c32:	call   c37 <botlish_fn_10+0x89>
			c33: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     c37:	mov    rcx,rax
     c3a:	mov    QWORD PTR [rsp+0x48],rax
     c3f:	test   rax,rcx
     c42:	jne    c50 <botlish_fn_10+0xa2>
     c48:	mov    rdi,r15
     c4b:	jmp    da6 <botlish_fn_10+0x1f8>
     c50:	mov    r12,QWORD PTR [rsp+0x20]
     c55:	mov    r13,QWORD PTR [rsp+0x28]
     c5a:	mov    rdi,r15
     c5d:	mov    rcx,QWORD PTR [rdi+0x10]
     c61:	mov    r8,QWORD PTR [rcx]
     c64:	mov    rcx,r13
     c67:	mov    rdx,r12
     c6a:	mov    rsi,QWORD PTR [rsp+0x48]
     c6f:	call   c74 <botlish_fn_10+0xc6>
			c70: R_X86_64_PLT32	rt_str_region_eq-0x4
     c74:	cmp    rax,0x6
     c78:	je     cb7 <botlish_fn_10+0x109>
     c7e:	mov    rdi,r15
     c81:	mov    rax,QWORD PTR [rdi+0x10]
     c85:	mov    r8,QWORD PTR [rax+0x8]
     c89:	mov    rcx,r13
     c8c:	mov    rdx,r12
     c8f:	mov    rsi,QWORD PTR [rsp+0x48]
     c94:	call   c99 <botlish_fn_10+0xeb>
			c95: R_X86_64_PLT32	rt_str_region_eq-0x4
     c99:	cmp    rax,0x6
     c9d:	je     cad <botlish_fn_10+0xff>
     ca3:	mov    eax,0x2
     ca8:	jmp    cbc <botlish_fn_10+0x10e>
     cad:	mov    eax,0x6
     cb2:	jmp    cbc <botlish_fn_10+0x10e>
     cb7:	mov    eax,0x6
     cbc:	cmp    rax,0x6
     cc0:	je     cff <botlish_fn_10+0x151>
     cc6:	mov    rdi,r15
     cc9:	mov    rdx,QWORD PTR [rdi+0x10]
     ccd:	mov    r8,QWORD PTR [rdx+0x10]
     cd1:	mov    rcx,r13
     cd4:	mov    rdx,r12
     cd7:	mov    rsi,QWORD PTR [rsp+0x48]
     cdc:	call   ce1 <botlish_fn_10+0x133>
			cdd: R_X86_64_PLT32	rt_str_region_eq-0x4
     ce1:	cmp    rax,0x6
     ce5:	je     cf5 <botlish_fn_10+0x147>
     ceb:	mov    eax,0x2
     cf0:	jmp    d04 <botlish_fn_10+0x156>
     cf5:	mov    eax,0x6
     cfa:	jmp    d04 <botlish_fn_10+0x156>
     cff:	mov    eax,0x6
     d04:	cmp    rax,0x6
     d08:	je     d83 <botlish_fn_10+0x1d5>
     d0e:	mov    QWORD PTR [rsp+0x18],0x3
     d17:	mov    rsi,QWORD PTR [rsp+0x40]
     d1c:	test   rsi,0x1
     d23:	je     d4a <botlish_fn_10+0x19c>
     d29:	mov    rsi,QWORD PTR [rsp+0x40]
     d2e:	mov    rax,rsi
     d31:	add    rax,0x2
     d35:	seto   cl
     d38:	test   cl,cl
     d3a:	jne    d4a <botlish_fn_10+0x19c>
     d40:	mov    rsi,QWORD PTR [rsp+0x30]
     d45:	jmp    d61 <botlish_fn_10+0x1b3>
     d4a:	mov    edx,0x3
     d4f:	mov    rsi,QWORD PTR [rsp+0x40]
     d54:	mov    rdi,r15
     d57:	call   d5c <botlish_fn_10+0x1ae>
			d58: R_X86_64_PLT32	rt_int_add-0x4
     d5c:	mov    rsi,QWORD PTR [rsp+0x30]
     d61:	mov    QWORD PTR [rsp],rsi
     d65:	mov    rdx,QWORD PTR [rsp+0x38]
     d6a:	mov    QWORD PTR [rsp+0x8],rdx
     d6f:	mov    QWORD PTR [rsp+0x10],rax
     d74:	mov    QWORD PTR [rsp+0x30],rsi
     d79:	mov    QWORD PTR [rsp+0x40],rax
     d7e:	jmp    c22 <botlish_fn_10+0x74>
     d83:	mov    rdx,QWORD PTR [rsp+0x38]
     d88:	mov    rsi,QWORD PTR [rsp+0x30]
     d8d:	mov    rcx,QWORD PTR [rsp+0x40]
     d92:	mov    rdi,r15
     d95:	call   d9a <botlish_fn_10+0x1ec>
			d96: R_X86_64_PLT32	rt_substr-0x4
     d9a:	test   rax,rax
     d9d:	jne    dd7 <botlish_fn_10+0x229>
     da3:	mov    rdi,r15
     da6:	mov    rdi,r15
     da9:	mov    QWORD PTR [rdi],r14
     dac:	xor    rdx,rdx
     daf:	mov    rax,rdx
     db2:	mov    rbx,QWORD PTR [rsp+0x50]
     db7:	mov    r12,QWORD PTR [rsp+0x58]
     dbc:	mov    r13,QWORD PTR [rsp+0x60]
     dc1:	mov    r14,QWORD PTR [rsp+0x68]
     dc6:	mov    r15,QWORD PTR [rsp+0x70]
     dcb:	add    rsp,0x80
     dd2:	mov    rsp,rbp
     dd5:	pop    rbp
     dd6:	ret
     dd7:	mov    rdi,r15
     dda:	mov    QWORD PTR [rdi],r14
     ddd:	mov    rdx,QWORD PTR [rsp+0x40]
     de2:	mov    rbx,QWORD PTR [rsp+0x50]
     de7:	mov    r12,QWORD PTR [rsp+0x58]
     dec:	mov    r13,QWORD PTR [rsp+0x60]
     df1:	mov    r14,QWORD PTR [rsp+0x68]
     df6:	mov    r15,QWORD PTR [rsp+0x70]
     dfb:	add    rsp,0x80
     e02:	mov    rsp,rbp
     e05:	pop    rbp
     e06:	ret
     e07:	mov    r15,rdi
     e0a:	call   e0f <botlish_fn_10+0x261>
			e0b: R_X86_64_PLT32	rt_stack_overflow-0x4
     e0f:	xor    rdx,rdx
     e12:	mov    rax,rdx
     e15:	mov    rbx,QWORD PTR [rsp+0x50]
     e1a:	mov    r12,QWORD PTR [rsp+0x58]
     e1f:	mov    r13,QWORD PTR [rsp+0x60]
     e24:	mov    r14,QWORD PTR [rsp+0x68]
     e29:	mov    r15,QWORD PTR [rsp+0x70]
     e2e:	add    rsp,0x80
     e35:	mov    rsp,rbp
     e38:	pop    rbp
     e39:	ret

0000000000000e3a <botlish_entry_10: scan_unquoted<str, int, int>>:
     e3a:	push   rbp
     e3b:	mov    rbp,rsp
     e3e:	ud2

0000000000000e40 <botlish_fn_11: scan_quoted<str, int, str>>:
     e40:	push   rbp
     e41:	mov    rbp,rsp
     e44:	sub    rsp,0x80
     e4b:	mov    QWORD PTR [rsp+0x50],rbx
     e50:	mov    QWORD PTR [rsp+0x58],r12
     e55:	mov    QWORD PTR [rsp+0x60],r13
     e5a:	mov    QWORD PTR [rsp+0x68],r14
     e5f:	mov    QWORD PTR [rsp+0x70],r15
     e64:	mov    r13,QWORD PTR [rdi]
     e67:	mov    rax,QWORD PTR [rdi+0x8]
     e6b:	lea    r8,[r13+0x8]
     e6f:	cmp    r8,rax
     e72:	ja     1164 <botlish_fn_11+0x324>
     e78:	lea    rax,[r13+0x8]
     e7c:	mov    QWORD PTR [rdi],rax
     e7f:	mov    r14,rdi
     e82:	mov    QWORD PTR [r13+0x0],0x0
     e8a:	mov    QWORD PTR [rsp+0x18],0x0
     e93:	mov    QWORD PTR [rsp+0x20],0x0
     e9c:	mov    QWORD PTR [rsp],rsi
     ea0:	mov    QWORD PTR [rsp+0x8],rdx
     ea5:	mov    QWORD PTR [rsp+0x10],rcx
     eaa:	lea    rbx,[rsp+0x28]
     eaf:	mov    r12,rsi
     eb2:	mov    r15,rdx
     eb5:	mov    QWORD PTR [rsp+0x38],rcx
     eba:	mov    rdx,r15
     ebd:	mov    rsi,r12
     ec0:	mov    rdi,r14
     ec3:	call   ec8 <botlish_fn_11+0x88>
			ec4: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     ec8:	test   rax,rax
     ecb:	jne    ed9 <botlish_fn_11+0x99>
     ed1:	mov    rdi,r14
     ed4:	jmp    1118 <botlish_fn_11+0x2d8>
     ed9:	mov    QWORD PTR [rsp+0x18],rax
     ede:	mov    rdi,r14
     ee1:	mov    QWORD PTR [rsp+0x40],rax
     ee6:	mov    rsi,QWORD PTR [rdi+0x10]
     eea:	mov    rsi,QWORD PTR [rsi+0x18]
     eee:	mov    edx,0x1
     ef3:	mov    ecx,0x3
     ef8:	mov    r8,QWORD PTR [rsp+0x40]
     efd:	call   f02 <botlish_fn_11+0xc2>
			efe: R_X86_64_PLT32	rt_str_region_eq-0x4
     f02:	cmp    rax,0x6
     f06:	je     f97 <botlish_fn_11+0x157>
     f0c:	mov    QWORD PTR [rsp+0x20],0x3
     f15:	mov    rsi,r15
     f18:	test   rsi,0x1
     f1f:	je     f41 <botlish_fn_11+0x101>
     f25:	mov    r9,rsi
     f28:	add    r9,0x2
     f2c:	seto   r11b
     f30:	test   r11b,r11b
     f33:	jne    f41 <botlish_fn_11+0x101>
     f39:	mov    rsi,r9
     f3c:	jmp    f51 <botlish_fn_11+0x111>
     f41:	mov    edx,0x3
     f46:	mov    rdi,r14
     f49:	call   f4e <botlish_fn_11+0x10e>
			f4a: R_X86_64_PLT32	rt_int_add-0x4
     f4e:	mov    rsi,rax
     f51:	mov    QWORD PTR [rsp+0x8],rsi
     f56:	mov    r15,rsi
     f59:	mov    rsi,QWORD PTR [rsp+0x38]
     f5e:	mov    rdx,QWORD PTR [rsp+0x40]
     f63:	mov    rdi,r14
     f66:	call   f6b <botlish_fn_11+0x12b>
			f67: R_X86_64_PLT32	rt_str_cat-0x4
     f6b:	test   rax,rax
     f6e:	jne    f7c <botlish_fn_11+0x13c>
     f74:	mov    rdi,r14
     f77:	jmp    1118 <botlish_fn_11+0x2d8>
     f7c:	mov    QWORD PTR [rsp],r12
     f80:	mov    rsi,r15
     f83:	mov    QWORD PTR [rsp+0x8],rsi
     f88:	mov    QWORD PTR [rsp+0x10],rax
     f8d:	mov    QWORD PTR [rsp+0x38],rax
     f92:	jmp    eba <botlish_fn_11+0x7a>
     f97:	mov    QWORD PTR [rsp+0x18],0x3
     fa0:	mov    rsi,r15
     fa3:	test   rsi,0x1
     faa:	je     fc5 <botlish_fn_11+0x185>
     fb0:	mov    rsi,r15
     fb3:	mov    rdx,rsi
     fb6:	add    rdx,0x2
     fba:	seto   al
     fbd:	test   al,al
     fbf:	je     fd8 <botlish_fn_11+0x198>
     fc5:	mov    edx,0x3
     fca:	mov    rsi,r15
     fcd:	mov    rdi,r14
     fd0:	call   fd5 <botlish_fn_11+0x195>
			fd1: R_X86_64_PLT32	rt_int_add-0x4
     fd5:	mov    rdx,rax
     fd8:	mov    QWORD PTR [rsp+0x18],rdx
     fdd:	mov    rcx,rbx
     fe0:	mov    rsi,r12
     fe3:	mov    rdi,r14
     fe6:	call   feb <botlish_fn_11+0x1ab>
			fe7: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     feb:	test   rax,rax
     fee:	mov    rsi,rax
     ff1:	jne    fff <botlish_fn_11+0x1bf>
     ff7:	mov    rdi,r14
     ffa:	jmp    1118 <botlish_fn_11+0x2d8>
     fff:	mov    rdx,QWORD PTR [rsp+0x28]
    1004:	mov    rcx,QWORD PTR [rsp+0x30]
    1009:	mov    rdi,r14
    100c:	mov    rax,QWORD PTR [rdi+0x10]
    1010:	mov    r8,QWORD PTR [rax+0x18]
    1014:	call   1019 <botlish_fn_11+0x1d9>
			1015: R_X86_64_PLT32	rt_str_region_eq-0x4
    1019:	cmp    rax,0x6
    101d:	je     109e <botlish_fn_11+0x25e>
    1023:	mov    QWORD PTR [rsp],0x3
    102b:	mov    rsi,r15
    102e:	test   rsi,0x1
    1035:	je     1058 <botlish_fn_11+0x218>
    103b:	mov    rsi,r15
    103e:	mov    rdx,rsi
    1041:	add    rdx,0x2
    1045:	seto   al
    1048:	test   al,al
    104a:	jne    1058 <botlish_fn_11+0x218>
    1050:	mov    rdi,r14
    1053:	jmp    106e <botlish_fn_11+0x22e>
    1058:	mov    edx,0x3
    105d:	mov    rsi,r15
    1060:	mov    rdi,r14
    1063:	call   1068 <botlish_fn_11+0x228>
			1064: R_X86_64_PLT32	rt_int_add-0x4
    1068:	mov    rdx,rax
    106b:	mov    rdi,r14
    106e:	mov    rdi,r14
    1071:	mov    QWORD PTR [rdi],r13
    1074:	mov    rax,QWORD PTR [rsp+0x38]
    1079:	mov    rbx,QWORD PTR [rsp+0x50]
    107e:	mov    r12,QWORD PTR [rsp+0x58]
    1083:	mov    r13,QWORD PTR [rsp+0x60]
    1088:	mov    r14,QWORD PTR [rsp+0x68]
    108d:	mov    r15,QWORD PTR [rsp+0x70]
    1092:	add    rsp,0x80
    1099:	mov    rsp,rbp
    109c:	pop    rbp
    109d:	ret
    109e:	mov    QWORD PTR [rsp+0x18],0x5
    10a7:	mov    rsi,r15
    10aa:	test   rsi,0x1
    10b1:	je     10d7 <botlish_fn_11+0x297>
    10b7:	mov    rsi,r15
    10ba:	mov    rax,rsi
    10bd:	add    rax,0x4
    10c1:	seto   cl
    10c4:	test   cl,cl
    10c6:	jne    10d7 <botlish_fn_11+0x297>
    10cc:	mov    rsi,rax
    10cf:	mov    r15,rax
    10d2:	jmp    10ed <botlish_fn_11+0x2ad>
    10d7:	mov    edx,0x5
    10dc:	mov    rsi,r15
    10df:	mov    rdi,r14
    10e2:	call   10e7 <botlish_fn_11+0x2a7>
			10e3: R_X86_64_PLT32	rt_int_add-0x4
    10e7:	mov    rsi,rax
    10ea:	mov    r15,rax
    10ed:	mov    QWORD PTR [rsp+0x8],rsi
    10f2:	mov    rdi,r14
    10f5:	mov    rax,QWORD PTR [rdi+0x10]
    10f9:	mov    rdx,QWORD PTR [rax+0x18]
    10fd:	mov    QWORD PTR [rsp+0x18],rdx
    1102:	mov    rsi,QWORD PTR [rsp+0x38]
    1107:	call   110c <botlish_fn_11+0x2cc>
			1108: R_X86_64_PLT32	rt_str_cat-0x4
    110c:	test   rax,rax
    110f:	jne    1149 <botlish_fn_11+0x309>
    1115:	mov    rdi,r14
    1118:	mov    rdi,r14
    111b:	mov    QWORD PTR [rdi],r13
    111e:	xor    rdx,rdx
    1121:	mov    rax,rdx
    1124:	mov    rbx,QWORD PTR [rsp+0x50]
    1129:	mov    r12,QWORD PTR [rsp+0x58]
    112e:	mov    r13,QWORD PTR [rsp+0x60]
    1133:	mov    r14,QWORD PTR [rsp+0x68]
    1138:	mov    r15,QWORD PTR [rsp+0x70]
    113d:	add    rsp,0x80
    1144:	mov    rsp,rbp
    1147:	pop    rbp
    1148:	ret
    1149:	mov    QWORD PTR [rsp],r12
    114d:	mov    rsi,r15
    1150:	mov    QWORD PTR [rsp+0x8],rsi
    1155:	mov    QWORD PTR [rsp+0x10],rax
    115a:	mov    QWORD PTR [rsp+0x38],rax
    115f:	jmp    eba <botlish_fn_11+0x7a>
    1164:	mov    r14,rdi
    1167:	call   116c <botlish_fn_11+0x32c>
			1168: R_X86_64_PLT32	rt_stack_overflow-0x4
    116c:	xor    rdx,rdx
    116f:	mov    rax,rdx
    1172:	mov    rbx,QWORD PTR [rsp+0x50]
    1177:	mov    r12,QWORD PTR [rsp+0x58]
    117c:	mov    r13,QWORD PTR [rsp+0x60]
    1181:	mov    r14,QWORD PTR [rsp+0x68]
    1186:	mov    r15,QWORD PTR [rsp+0x70]
    118b:	add    rsp,0x80
    1192:	mov    rsp,rbp
    1195:	pop    rbp
    1196:	ret

0000000000001197 <botlish_entry_11: scan_quoted<str, int, str>>:
    1197:	push   rbp
    1198:	mov    rbp,rsp
    119b:	ud2

000000000000119d <botlish_fn_12: scan_field<str, int>>:
    119d:	push   rbp
    119e:	mov    rbp,rsp
    11a1:	sub    rsp,0x50
    11a5:	mov    QWORD PTR [rsp+0x30],rbx
    11aa:	mov    QWORD PTR [rsp+0x38],r12
    11af:	mov    QWORD PTR [rsp+0x40],r13
    11b4:	mov    QWORD PTR [rsp+0x48],r14
    11b9:	mov    rbx,QWORD PTR [rdi]
    11bc:	mov    rax,QWORD PTR [rdi+0x8]
    11c0:	lea    rcx,[rbx+0x8]
    11c4:	cmp    rcx,rax
    11c7:	ja     1338 <botlish_fn_12+0x19b>
    11cd:	lea    rax,[rbx+0x8]
    11d1:	mov    QWORD PTR [rdi],rax
    11d4:	mov    r12,rdi
    11d7:	mov    QWORD PTR [rbx],0x0
    11de:	mov    QWORD PTR [rsp+0x10],0x0
    11e7:	mov    QWORD PTR [rsp],rsi
    11eb:	mov    r13,rsi
    11ee:	mov    QWORD PTR [rsp+0x8],rdx
    11f3:	mov    r14,rdx
    11f6:	lea    rcx,[rsp+0x18]
    11fb:	mov    rdx,r14
    11fe:	mov    rsi,r13
    1201:	mov    rdi,r12
    1204:	call   1209 <botlish_fn_12+0x6c>
			1205: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1209:	test   rax,rax
    120c:	mov    rsi,rax
    120f:	jne    121d <botlish_fn_12+0x80>
    1215:	mov    rdi,r12
    1218:	jmp    12ec <botlish_fn_12+0x14f>
    121d:	mov    rdx,QWORD PTR [rsp+0x18]
    1222:	mov    rcx,QWORD PTR [rsp+0x20]
    1227:	mov    rdi,r12
    122a:	mov    rax,QWORD PTR [rdi+0x10]
    122e:	mov    r8,QWORD PTR [rax+0x18]
    1232:	call   1237 <botlish_fn_12+0x9a>
			1233: R_X86_64_PLT32	rt_str_region_eq-0x4
    1237:	cmp    rax,0x6
    123b:	je     1286 <botlish_fn_12+0xe9>
    1241:	mov    rcx,r14
    1244:	mov    rsi,r13
    1247:	mov    rdi,r12
    124a:	mov    rdx,rcx
    124d:	call   1252 <botlish_fn_12+0xb5>
			124e: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
    1252:	test   rax,rax
    1255:	jne    1263 <botlish_fn_12+0xc6>
    125b:	mov    rdi,r12
    125e:	jmp    12ec <botlish_fn_12+0x14f>
    1263:	mov    rdi,r12
    1266:	mov    QWORD PTR [rdi],rbx
    1269:	mov    rbx,QWORD PTR [rsp+0x30]
    126e:	mov    r12,QWORD PTR [rsp+0x38]
    1273:	mov    r13,QWORD PTR [rsp+0x40]
    1278:	mov    r14,QWORD PTR [rsp+0x48]
    127d:	add    rsp,0x50
    1281:	mov    rsp,rbp
    1284:	pop    rbp
    1285:	ret
    1286:	mov    QWORD PTR [rsp+0x10],0x3
    128f:	mov    rdx,r14
    1292:	test   rdx,0x1
    1299:	je     12b1 <botlish_fn_12+0x114>
    129f:	mov    rdx,r14
    12a2:	add    rdx,0x2
    12a6:	seto   al
    12a9:	test   al,al
    12ab:	je     12c4 <botlish_fn_12+0x127>
    12b1:	mov    edx,0x3
    12b6:	mov    rsi,r14
    12b9:	mov    rdi,r12
    12bc:	call   12c1 <botlish_fn_12+0x124>
			12bd: R_X86_64_PLT32	rt_int_add-0x4
    12c1:	mov    rdx,rax
    12c4:	mov    QWORD PTR [rsp+0x8],rdx
    12c9:	mov    rdi,r12
    12cc:	mov    rax,QWORD PTR [rdi+0x10]
    12d0:	mov    rcx,QWORD PTR [rax]
    12d3:	mov    QWORD PTR [rsp+0x10],rcx
    12d8:	mov    rsi,r13
    12db:	call   12e0 <botlish_fn_12+0x143>
			12dc: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
    12e0:	test   rax,rax
    12e3:	jne    1315 <botlish_fn_12+0x178>
    12e9:	mov    rdi,r12
    12ec:	mov    rdi,r12
    12ef:	mov    QWORD PTR [rdi],rbx
    12f2:	xor    rdx,rdx
    12f5:	mov    rax,rdx
    12f8:	mov    rbx,QWORD PTR [rsp+0x30]
    12fd:	mov    r12,QWORD PTR [rsp+0x38]
    1302:	mov    r13,QWORD PTR [rsp+0x40]
    1307:	mov    r14,QWORD PTR [rsp+0x48]
    130c:	add    rsp,0x50
    1310:	mov    rsp,rbp
    1313:	pop    rbp
    1314:	ret
    1315:	mov    rdi,r12
    1318:	mov    QWORD PTR [rdi],rbx
    131b:	mov    rbx,QWORD PTR [rsp+0x30]
    1320:	mov    r12,QWORD PTR [rsp+0x38]
    1325:	mov    r13,QWORD PTR [rsp+0x40]
    132a:	mov    r14,QWORD PTR [rsp+0x48]
    132f:	add    rsp,0x50
    1333:	mov    rsp,rbp
    1336:	pop    rbp
    1337:	ret
    1338:	mov    r12,rdi
    133b:	call   1340 <botlish_fn_12+0x1a3>
			133c: R_X86_64_PLT32	rt_stack_overflow-0x4
    1340:	xor    rdx,rdx
    1343:	mov    rax,rdx
    1346:	mov    rbx,QWORD PTR [rsp+0x30]
    134b:	mov    r12,QWORD PTR [rsp+0x38]
    1350:	mov    r13,QWORD PTR [rsp+0x40]
    1355:	mov    r14,QWORD PTR [rsp+0x48]
    135a:	add    rsp,0x50
    135e:	mov    rsp,rbp
    1361:	pop    rbp
    1362:	ret

0000000000001363 <botlish_entry_12: scan_field<str, int>>:
    1363:	push   rbp
    1364:	mov    rbp,rsp
    1367:	ud2

0000000000001369 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
    1369:	push   rbp
    136a:	mov    rbp,rsp
    136d:	sub    rsp,0x90
    1374:	mov    QWORD PTR [rsp+0x60],rbx
    1379:	mov    QWORD PTR [rsp+0x68],r12
    137e:	mov    QWORD PTR [rsp+0x70],r13
    1383:	mov    QWORD PTR [rsp+0x78],r14
    1388:	mov    QWORD PTR [rsp+0x80],r15
    1390:	mov    r13,QWORD PTR [rdi]
    1393:	mov    rax,QWORD PTR [rdi+0x8]
    1397:	lea    r9,[r13+0x8]
    139b:	cmp    r9,rax
    139e:	ja     1688 <botlish_fn_13+0x31f>
    13a4:	lea    rax,[r13+0x8]
    13a8:	mov    QWORD PTR [rdi],rax
    13ab:	mov    QWORD PTR [rsp+0x38],rdi
    13b0:	mov    QWORD PTR [r13+0x0],0x0
    13b8:	mov    QWORD PTR [rsp+0x20],0x0
    13c1:	mov    QWORD PTR [rsp],rsi
    13c5:	mov    QWORD PTR [rsp+0x8],rdx
    13ca:	mov    QWORD PTR [rsp+0x10],rcx
    13cf:	mov    QWORD PTR [rsp+0x18],r8
    13d4:	lea    rbx,[rsp+0x28]
    13d9:	mov    r12,rsi
    13dc:	mov    r14,r8
    13df:	mov    r15,rcx
    13e2:	mov    rsi,r12
    13e5:	mov    rdi,QWORD PTR [rsp+0x38]
    13ea:	call   13ef <botlish_fn_13+0x86>
			13eb: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
    13ef:	test   rax,rax
    13f2:	jne    1402 <botlish_fn_13+0x99>
    13f8:	mov    rdi,QWORD PTR [rsp+0x38]
    13fd:	jmp    154e <botlish_fn_13+0x1e5>
    1402:	mov    QWORD PTR [rsp+0x8],rax
    1407:	mov    rcx,rax
    140a:	mov    QWORD PTR [rsp+0x20],rdx
    140f:	mov    QWORD PTR [rsp+0x58],rdx
    1414:	mov    rsi,r15
    1417:	mov    rdx,r14
    141a:	mov    rdi,QWORD PTR [rsp+0x38]
    141f:	call   1424 <botlish_fn_13+0xbb>
			1420: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    1424:	test   rax,rax
    1427:	jne    1437 <botlish_fn_13+0xce>
    142d:	mov    rdi,QWORD PTR [rsp+0x38]
    1432:	jmp    154e <botlish_fn_13+0x1e5>
    1437:	mov    QWORD PTR [rsp+0x8],rax
    143c:	mov    QWORD PTR [rsp+0x48],rax
    1441:	mov    QWORD PTR [rsp+0x10],rdx
    1446:	mov    QWORD PTR [rsp+0x50],rdx
    144b:	mov    rcx,rbx
    144e:	mov    rdx,QWORD PTR [rsp+0x58]
    1453:	mov    rsi,r12
    1456:	mov    rdi,QWORD PTR [rsp+0x38]
    145b:	call   1460 <botlish_fn_13+0xf7>
			145c: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1460:	test   rax,rax
    1463:	mov    QWORD PTR [rsp+0x40],rax
    1468:	jne    1478 <botlish_fn_13+0x10f>
    146e:	mov    rdi,QWORD PTR [rsp+0x38]
    1473:	jmp    154e <botlish_fn_13+0x1e5>
    1478:	mov    r15,QWORD PTR [rsp+0x28]
    147d:	mov    r14,QWORD PTR [rsp+0x30]
    1482:	mov    rdi,QWORD PTR [rsp+0x38]
    1487:	mov    rcx,QWORD PTR [rdi+0x10]
    148b:	mov    r8,QWORD PTR [rcx+0x8]
    148f:	mov    rcx,r14
    1492:	mov    rdx,r15
    1495:	mov    rsi,QWORD PTR [rsp+0x40]
    149a:	call   149f <botlish_fn_13+0x136>
			149b: R_X86_64_PLT32	rt_str_region_eq-0x4
    149f:	cmp    rax,0x6
    14a3:	je     1613 <botlish_fn_13+0x2aa>
    14a9:	mov    rdi,QWORD PTR [rsp+0x38]
    14ae:	mov    rsi,QWORD PTR [rdi+0x10]
    14b2:	mov    r8,QWORD PTR [rsi+0x10]
    14b6:	mov    rcx,r14
    14b9:	mov    rdx,r15
    14bc:	mov    rsi,QWORD PTR [rsp+0x40]
    14c1:	call   14c6 <botlish_fn_13+0x15d>
			14c2: R_X86_64_PLT32	rt_str_region_eq-0x4
    14c6:	cmp    rax,0x6
    14ca:	je     152c <botlish_fn_13+0x1c3>
    14d0:	mov    rdx,QWORD PTR [rsp+0x50]
    14d5:	mov    rsi,QWORD PTR [rsp+0x48]
    14da:	mov    rdi,QWORD PTR [rsp+0x38]
    14df:	call   14e4 <botlish_fn_13+0x17b>
			14e0: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    14e4:	test   rax,rax
    14e7:	jne    14f7 <botlish_fn_13+0x18e>
    14ed:	mov    rdi,QWORD PTR [rsp+0x38]
    14f2:	jmp    154e <botlish_fn_13+0x1e5>
    14f7:	mov    rdi,QWORD PTR [rsp+0x38]
    14fc:	mov    QWORD PTR [rdi],r13
    14ff:	mov    rdx,QWORD PTR [rsp+0x58]
    1504:	mov    rbx,QWORD PTR [rsp+0x60]
    1509:	mov    r12,QWORD PTR [rsp+0x68]
    150e:	mov    r13,QWORD PTR [rsp+0x70]
    1513:	mov    r14,QWORD PTR [rsp+0x78]
    1518:	mov    r15,QWORD PTR [rsp+0x80]
    1520:	add    rsp,0x90
    1527:	mov    rsp,rbp
    152a:	pop    rbp
    152b:	ret
    152c:	mov    rdx,QWORD PTR [rsp+0x50]
    1531:	mov    rsi,QWORD PTR [rsp+0x48]
    1536:	mov    rdi,QWORD PTR [rsp+0x38]
    153b:	call   1540 <botlish_fn_13+0x1d7>
			153c: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1540:	test   rax,rax
    1543:	jne    1584 <botlish_fn_13+0x21b>
    1549:	mov    rdi,QWORD PTR [rsp+0x38]
    154e:	mov    rdi,QWORD PTR [rsp+0x38]
    1553:	mov    QWORD PTR [rdi],r13
    1556:	xor    rdx,rdx
    1559:	mov    rax,rdx
    155c:	mov    rbx,QWORD PTR [rsp+0x60]
    1561:	mov    r12,QWORD PTR [rsp+0x68]
    1566:	mov    r13,QWORD PTR [rsp+0x70]
    156b:	mov    r14,QWORD PTR [rsp+0x78]
    1570:	mov    r15,QWORD PTR [rsp+0x80]
    1578:	add    rsp,0x90
    157f:	mov    rsp,rbp
    1582:	pop    rbp
    1583:	ret
    1584:	mov    QWORD PTR [rsp],rax
    1588:	mov    rbx,rax
    158b:	mov    QWORD PTR [rsp+0x8],0x3
    1594:	mov    rdx,QWORD PTR [rsp+0x58]
    1599:	test   rdx,0x1
    15a0:	je     15c4 <botlish_fn_13+0x25b>
    15a6:	mov    rdx,QWORD PTR [rsp+0x58]
    15ab:	add    rdx,0x2
    15af:	seto   al
    15b2:	test   al,al
    15b4:	jne    15c4 <botlish_fn_13+0x25b>
    15ba:	mov    rdi,QWORD PTR [rsp+0x38]
    15bf:	jmp    15e0 <botlish_fn_13+0x277>
    15c4:	mov    edx,0x3
    15c9:	mov    rsi,QWORD PTR [rsp+0x58]
    15ce:	mov    rdi,QWORD PTR [rsp+0x38]
    15d3:	call   15d8 <botlish_fn_13+0x26f>
			15d4: R_X86_64_PLT32	rt_int_add-0x4
    15d8:	mov    rdx,rax
    15db:	mov    rdi,QWORD PTR [rsp+0x38]
    15e0:	mov    rdi,QWORD PTR [rsp+0x38]
    15e5:	mov    QWORD PTR [rdi],r13
    15e8:	mov    rax,rbx
    15eb:	mov    rbx,QWORD PTR [rsp+0x60]
    15f0:	mov    r12,QWORD PTR [rsp+0x68]
    15f5:	mov    r13,QWORD PTR [rsp+0x70]
    15fa:	mov    r14,QWORD PTR [rsp+0x78]
    15ff:	mov    r15,QWORD PTR [rsp+0x80]
    1607:	add    rsp,0x90
    160e:	mov    rsp,rbp
    1611:	pop    rbp
    1612:	ret
    1613:	mov    rsi,QWORD PTR [rsp+0x58]
    1618:	mov    edx,0x3
    161d:	mov    r9,rdx
    1620:	mov    QWORD PTR [rsp+0x18],0x3
    1629:	test   rsi,0x1
    1630:	jne    163e <botlish_fn_13+0x2d5>
    1636:	mov    rdx,r9
    1639:	jmp    1653 <botlish_fn_13+0x2ea>
    163e:	mov    rdx,rsi
    1641:	add    rdx,0x2
    1645:	seto   al
    1648:	test   al,al
    164a:	je     1660 <botlish_fn_13+0x2f7>
    1650:	mov    rdx,r9
    1653:	mov    rdi,QWORD PTR [rsp+0x38]
    1658:	call   165d <botlish_fn_13+0x2f4>
			1659: R_X86_64_PLT32	rt_int_add-0x4
    165d:	mov    rdx,rax
    1660:	mov    QWORD PTR [rsp],r12
    1664:	mov    QWORD PTR [rsp+0x8],rdx
    1669:	mov    rsi,QWORD PTR [rsp+0x48]
    166e:	mov    QWORD PTR [rsp+0x10],rsi
    1673:	mov    rax,QWORD PTR [rsp+0x50]
    1678:	mov    QWORD PTR [rsp+0x18],rax
    167d:	mov    r14,rax
    1680:	mov    r15,rsi
    1683:	jmp    13e2 <botlish_fn_13+0x79>
    1688:	mov    QWORD PTR [rsp+0x38],rdi
    168d:	call   1692 <botlish_fn_13+0x329>
			168e: R_X86_64_PLT32	rt_stack_overflow-0x4
    1692:	xor    rdx,rdx
    1695:	mov    rax,rdx
    1698:	mov    rbx,QWORD PTR [rsp+0x60]
    169d:	mov    r12,QWORD PTR [rsp+0x68]
    16a2:	mov    r13,QWORD PTR [rsp+0x70]
    16a7:	mov    r14,QWORD PTR [rsp+0x78]
    16ac:	mov    r15,QWORD PTR [rsp+0x80]
    16b4:	add    rsp,0x90
    16bb:	mov    rsp,rbp
    16be:	pop    rbp
    16bf:	ret

00000000000016c0 <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    16c0:	push   rbp
    16c1:	mov    rbp,rsp
    16c4:	ud2
	...

00000000000016c8 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    16c8:	push   rbp
    16c9:	mov    rbp,rsp
    16cc:	sub    rsp,0x70
    16d0:	mov    QWORD PTR [rsp+0x40],rbx
    16d5:	mov    QWORD PTR [rsp+0x48],r12
    16da:	mov    QWORD PTR [rsp+0x50],r13
    16df:	mov    QWORD PTR [rsp+0x58],r14
    16e4:	mov    QWORD PTR [rsp+0x60],r15
    16e9:	mov    r12,QWORD PTR [rdi]
    16ec:	mov    rax,QWORD PTR [rdi+0x8]
    16f0:	lea    r9,[r12+0x8]
    16f5:	cmp    r9,rax
    16f8:	ja     18ad <botlish_fn_14+0x1e5>
    16fe:	lea    rax,[r12+0x8]
    1703:	mov    QWORD PTR [rdi],rax
    1706:	mov    r14,rdi
    1709:	mov    QWORD PTR [r12],0x0
    1711:	mov    QWORD PTR [rsp+0x20],0x0
    171a:	mov    QWORD PTR [rsp+0x28],0x0
    1723:	mov    QWORD PTR [rsp],rsi
    1727:	mov    QWORD PTR [rsp+0x8],rdx
    172c:	mov    r13,rdx
    172f:	mov    QWORD PTR [rsp+0x10],rcx
    1734:	mov    QWORD PTR [rsp+0x18],r8
    1739:	mov    rbx,rsi
    173c:	mov    r15,r8
    173f:	mov    QWORD PTR [rsp+0x30],rcx
    1744:	mov    rsi,rbx
    1747:	mov    rdi,r14
    174a:	call   174f <botlish_fn_14+0x87>
			174b: R_X86_64_PLT32	rt_str_len-0x4
    174f:	mov    rcx,r13
    1752:	and    rcx,rax
    1755:	mov    rdx,rax
    1758:	test   rcx,0x1
    175f:	jne    1785 <botlish_fn_14+0xbd>
    1765:	mov    rsi,r13
    1768:	mov    rdi,r14
    176b:	call   1770 <botlish_fn_14+0xa8>
			176c: R_X86_64_PLT32	rt_int_cmp-0x4
    1770:	mov    ecx,0x2
    1775:	test   rax,rax
    1778:	cmovge rcx,QWORD PTR [rip+0x160]        # 18e0 <botlish_fn_14+0x218>
    1780:	jmp    1798 <botlish_fn_14+0xd0>
    1785:	mov    ecx,0x2
    178a:	mov    rax,r13
    178d:	cmp    rax,rdx
    1790:	cmovge rcx,QWORD PTR [rip+0x148]        # 18e0 <botlish_fn_14+0x218>
    1798:	cmp    rcx,0x6
    179c:	je     183e <botlish_fn_14+0x176>
    17a2:	mov    rdi,r14
    17a5:	call   17aa <botlish_fn_14+0xe2>
			17a6: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    17aa:	test   rax,rax
    17ad:	jne    17bb <botlish_fn_14+0xf3>
    17b3:	mov    rdi,r14
    17b6:	jmp    185a <botlish_fn_14+0x192>
    17bb:	mov    QWORD PTR [rsp+0x20],rax
    17c0:	mov    rcx,rax
    17c3:	mov    QWORD PTR [rsp+0x28],rdx
    17c8:	mov    r8,rdx
    17cb:	mov    rdx,r13
    17ce:	mov    rsi,rbx
    17d1:	mov    rdi,r14
    17d4:	call   17d9 <botlish_fn_14+0x111>
			17d5: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    17d9:	test   rax,rax
    17dc:	jne    17ea <botlish_fn_14+0x122>
    17e2:	mov    rdi,r14
    17e5:	jmp    185a <botlish_fn_14+0x192>
    17ea:	mov    QWORD PTR [rsp+0x8],rax
    17ef:	mov    rcx,rax
    17f2:	mov    QWORD PTR [rsp+0x20],rdx
    17f7:	mov    r13,rdx
    17fa:	mov    rsi,QWORD PTR [rsp+0x30]
    17ff:	mov    rdx,r15
    1802:	mov    rdi,r14
    1805:	call   180a <botlish_fn_14+0x142>
			1806: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    180a:	test   rax,rax
    180d:	jne    181b <botlish_fn_14+0x153>
    1813:	mov    rdi,r14
    1816:	jmp    185a <botlish_fn_14+0x192>
    181b:	mov    QWORD PTR [rsp],rbx
    181f:	mov    rcx,r13
    1822:	mov    QWORD PTR [rsp+0x8],rcx
    1827:	mov    QWORD PTR [rsp+0x10],rax
    182c:	mov    QWORD PTR [rsp+0x18],rdx
    1831:	mov    r15,rdx
    1834:	mov    QWORD PTR [rsp+0x30],rax
    1839:	jmp    1744 <botlish_fn_14+0x7c>
    183e:	mov    rdx,r15
    1841:	mov    rsi,QWORD PTR [rsp+0x30]
    1846:	mov    rdi,r14
    1849:	call   184e <botlish_fn_14+0x186>
			184a: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    184e:	test   rax,rax
    1851:	jne    1885 <botlish_fn_14+0x1bd>
    1857:	mov    rdi,r14
    185a:	mov    rdi,r14
    185d:	mov    QWORD PTR [rdi],r12
    1860:	xor    rax,rax
    1863:	mov    rbx,QWORD PTR [rsp+0x40]
    1868:	mov    r12,QWORD PTR [rsp+0x48]
    186d:	mov    r13,QWORD PTR [rsp+0x50]
    1872:	mov    r14,QWORD PTR [rsp+0x58]
    1877:	mov    r15,QWORD PTR [rsp+0x60]
    187c:	add    rsp,0x70
    1880:	mov    rsp,rbp
    1883:	pop    rbp
    1884:	ret
    1885:	mov    rdi,r14
    1888:	mov    QWORD PTR [rdi],r12
    188b:	mov    rbx,QWORD PTR [rsp+0x40]
    1890:	mov    r12,QWORD PTR [rsp+0x48]
    1895:	mov    r13,QWORD PTR [rsp+0x50]
    189a:	mov    r14,QWORD PTR [rsp+0x58]
    189f:	mov    r15,QWORD PTR [rsp+0x60]
    18a4:	add    rsp,0x70
    18a8:	mov    rsp,rbp
    18ab:	pop    rbp
    18ac:	ret
    18ad:	mov    r14,rdi
    18b0:	call   18b5 <botlish_fn_14+0x1ed>
			18b1: R_X86_64_PLT32	rt_stack_overflow-0x4
    18b5:	xor    rax,rax
    18b8:	mov    rbx,QWORD PTR [rsp+0x40]
    18bd:	mov    r12,QWORD PTR [rsp+0x48]
    18c2:	mov    r13,QWORD PTR [rsp+0x50]
    18c7:	mov    r14,QWORD PTR [rsp+0x58]
    18cc:	mov    r15,QWORD PTR [rsp+0x60]
    18d1:	add    rsp,0x70
    18d5:	mov    rsp,rbp
    18d8:	pop    rbp
    18d9:	ret
    18da:	add    BYTE PTR [rax],al
    18dc:	add    BYTE PTR [rax],al
    18de:	add    BYTE PTR [rax],al
    18e0:	(bad)
    18e1:	add    BYTE PTR [rax],al
    18e3:	add    BYTE PTR [rax],al
    18e5:	add    BYTE PTR [rax],al
	...

00000000000018e8 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    18e8:	push   rbp
    18e9:	mov    rbp,rsp
    18ec:	mov    rsi,QWORD PTR [rdx]
    18ef:	mov    r9,QWORD PTR [rdx+0x8]
    18f3:	mov    rcx,QWORD PTR [rdx+0x10]
    18f7:	mov    r8,QWORD PTR [rdx+0x18]
    18fb:	mov    rdx,r9
    18fe:	call   1903 <botlish_entry_14+0x1b>
			18ff: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1903:	mov    rsp,rbp
    1906:	pop    rbp
    1907:	ret

0000000000001908 <botlish_fn_15: csv_parse<str>>:
    1908:	push   rbp
    1909:	mov    rbp,rsp
    190c:	sub    rsp,0x40
    1910:	mov    QWORD PTR [rsp+0x20],rbx
    1915:	mov    QWORD PTR [rsp+0x28],r12
    191a:	mov    QWORD PTR [rsp+0x30],r15
    191f:	mov    r15,QWORD PTR [rdi]
    1922:	mov    rax,QWORD PTR [rdi+0x8]
    1926:	lea    rcx,[r15+0x8]
    192a:	cmp    rcx,rax
    192d:	ja     19ea <botlish_fn_15+0xe2>
    1933:	lea    rax,[r15+0x8]
    1937:	mov    QWORD PTR [rdi],rax
    193a:	mov    rbx,rdi
    193d:	mov    QWORD PTR [r15],0x0
    1944:	mov    QWORD PTR [rsp+0x10],0x0
    194d:	mov    QWORD PTR [rsp+0x18],0x0
    1956:	mov    QWORD PTR [rsp],rsi
    195a:	mov    r12,rsi
    195d:	mov    QWORD PTR [rsp+0x8],0x1
    1966:	mov    rdi,rbx
    1969:	call   196e <botlish_fn_15+0x66>
			196a: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    196e:	test   rax,rax
    1971:	jne    197f <botlish_fn_15+0x77>
    1977:	mov    rdi,rbx
    197a:	jmp    19ab <botlish_fn_15+0xa3>
    197f:	mov    QWORD PTR [rsp+0x10],rax
    1984:	mov    rcx,rax
    1987:	mov    QWORD PTR [rsp+0x18],rdx
    198c:	mov    r8,rdx
    198f:	mov    edx,0x1
    1994:	mov    rsi,r12
    1997:	mov    rdi,rbx
    199a:	call   199f <botlish_fn_15+0x97>
			199b: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    199f:	test   rax,rax
    19a2:	jne    19cc <botlish_fn_15+0xc4>
    19a8:	mov    rdi,rbx
    19ab:	mov    rdi,rbx
    19ae:	mov    QWORD PTR [rdi],r15
    19b1:	xor    rax,rax
    19b4:	mov    rbx,QWORD PTR [rsp+0x20]
    19b9:	mov    r12,QWORD PTR [rsp+0x28]
    19be:	mov    r15,QWORD PTR [rsp+0x30]
    19c3:	add    rsp,0x40
    19c7:	mov    rsp,rbp
    19ca:	pop    rbp
    19cb:	ret
    19cc:	mov    rdi,rbx
    19cf:	mov    QWORD PTR [rdi],r15
    19d2:	mov    rbx,QWORD PTR [rsp+0x20]
    19d7:	mov    r12,QWORD PTR [rsp+0x28]
    19dc:	mov    r15,QWORD PTR [rsp+0x30]
    19e1:	add    rsp,0x40
    19e5:	mov    rsp,rbp
    19e8:	pop    rbp
    19e9:	ret
    19ea:	mov    rbx,rdi
    19ed:	call   19f2 <botlish_fn_15+0xea>
			19ee: R_X86_64_PLT32	rt_stack_overflow-0x4
    19f2:	xor    rax,rax
    19f5:	mov    rbx,QWORD PTR [rsp+0x20]
    19fa:	mov    r12,QWORD PTR [rsp+0x28]
    19ff:	mov    r15,QWORD PTR [rsp+0x30]
    1a04:	add    rsp,0x40
    1a08:	mov    rsp,rbp
    1a0b:	pop    rbp
    1a0c:	ret

0000000000001a0d <botlish_entry_15: csv_parse<str>>:
    1a0d:	push   rbp
    1a0e:	mov    rbp,rsp
    1a11:	mov    rsi,QWORD PTR [rdx]
    1a14:	call   1a19 <botlish_entry_15+0xc>
			1a15: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    1a19:	mov    rsp,rbp
    1a1c:	pop    rbp
    1a1d:	ret

0000000000001a1e <botlish_fn_16: ht_min_capacity<generic>>:
    1a1e:	push   rbp
    1a1f:	mov    rbp,rsp
    1a22:	mov    eax,0x11
    1a27:	mov    rsp,rbp
    1a2a:	pop    rbp
    1a2b:	ret

0000000000001a2c <botlish_entry_16: ht_min_capacity<generic>>:
    1a2c:	push   rbp
    1a2d:	mov    rbp,rsp
    1a30:	call   1a35 <botlish_entry_16+0x9>
			1a31: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1a35:	mov    rsp,rbp
    1a38:	pop    rbp
    1a39:	ret

0000000000001a3a <botlish_fn_17: ht_empty_state<generic>>:
    1a3a:	push   rbp
    1a3b:	mov    rbp,rsp
    1a3e:	mov    eax,0x1
    1a43:	mov    rsp,rbp
    1a46:	pop    rbp
    1a47:	ret

0000000000001a48 <botlish_entry_17: ht_empty_state<generic>>:
    1a48:	push   rbp
    1a49:	mov    rbp,rsp
    1a4c:	call   1a51 <botlish_entry_17+0x9>
			1a4d: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1a51:	mov    rsp,rbp
    1a54:	pop    rbp
    1a55:	ret

0000000000001a56 <botlish_fn_18: ht_occupied_state<generic>>:
    1a56:	push   rbp
    1a57:	mov    rbp,rsp
    1a5a:	mov    eax,0x3
    1a5f:	mov    rsp,rbp
    1a62:	pop    rbp
    1a63:	ret

0000000000001a64 <botlish_entry_18: ht_occupied_state<generic>>:
    1a64:	push   rbp
    1a65:	mov    rbp,rsp
    1a68:	call   1a6d <botlish_entry_18+0x9>
			1a69: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    1a6d:	mov    rsp,rbp
    1a70:	pop    rbp
    1a71:	ret

0000000000001a72 <botlish_fn_19: ht_tombstone_state<generic>>:
    1a72:	push   rbp
    1a73:	mov    rbp,rsp
    1a76:	mov    eax,0x5
    1a7b:	mov    rsp,rbp
    1a7e:	pop    rbp
    1a7f:	ret

0000000000001a80 <botlish_entry_19: ht_tombstone_state<generic>>:
    1a80:	push   rbp
    1a81:	mov    rbp,rsp
    1a84:	call   1a89 <botlish_entry_19+0x9>
			1a85: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    1a89:	mov    rsp,rbp
    1a8c:	pop    rbp
    1a8d:	ret
	...

0000000000001a90 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    1a90:	push   rbp
    1a91:	mov    rbp,rsp
    1a94:	sub    rsp,0x50
    1a98:	mov    QWORD PTR [rsp+0x20],rbx
    1a9d:	mov    QWORD PTR [rsp+0x28],r12
    1aa2:	mov    QWORD PTR [rsp+0x30],r13
    1aa7:	mov    QWORD PTR [rsp+0x38],r14
    1aac:	mov    QWORD PTR [rsp+0x40],r15
    1ab1:	mov    r13,QWORD PTR [rdi]
    1ab4:	mov    r8,QWORD PTR [rdi+0x8]
    1ab8:	lea    rax,[r13+0x8]
    1abc:	cmp    rax,r8
    1abf:	ja     1c39 <botlish_fn_20+0x1a9>
    1ac5:	lea    rax,[r13+0x8]
    1ac9:	mov    QWORD PTR [rdi],rax
    1acc:	mov    r14,rdi
    1acf:	mov    QWORD PTR [r13+0x0],0x0
    1ad7:	mov    QWORD PTR [rsp+0x18],0x0
    1ae0:	mov    QWORD PTR [rsp],rsi
    1ae4:	mov    r12,rsi
    1ae7:	mov    QWORD PTR [rsp+0x8],rdx
    1aec:	mov    QWORD PTR [rsp+0x10],rcx
    1af1:	mov    rbx,rcx
    1af4:	mov    rsi,rdx
    1af7:	mov    rax,rsi
    1afa:	and    rax,rbx
    1afd:	mov    r15,rsi
    1b00:	test   rax,0x1
    1b06:	jne    1b2f <botlish_fn_20+0x9f>
    1b0c:	mov    rdx,rbx
    1b0f:	mov    rsi,r15
    1b12:	mov    rdi,r14
    1b15:	call   1b1a <botlish_fn_20+0x8a>
			1b16: R_X86_64_PLT32	rt_int_cmp-0x4
    1b1a:	mov    ecx,0x2
    1b1f:	test   rax,rax
    1b22:	cmovge rcx,QWORD PTR [rip+0x13e]        # 1c68 <botlish_fn_20+0x1d8>
    1b2a:	jmp    1b42 <botlish_fn_20+0xb2>
    1b2f:	mov    ecx,0x2
    1b34:	mov    rsi,r15
    1b37:	cmp    rsi,rbx
    1b3a:	cmovge rcx,QWORD PTR [rip+0x126]        # 1c68 <botlish_fn_20+0x1d8>
    1b42:	cmp    rcx,0x6
    1b46:	je     1c0c <botlish_fn_20+0x17c>
    1b4c:	mov    rdi,r14
    1b4f:	call   1b54 <botlish_fn_20+0xc4>
			1b50: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1b54:	test   rax,rax
    1b57:	mov    rcx,rax
    1b5a:	jne    1b68 <botlish_fn_20+0xd8>
    1b60:	mov    rdi,r14
    1b63:	jmp    1b82 <botlish_fn_20+0xf2>
    1b68:	mov    rdx,r15
    1b6b:	mov    rsi,r12
    1b6e:	mov    rdi,r14
    1b71:	call   1b76 <botlish_fn_20+0xe6>
			1b72: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b76:	test   rax,rax
    1b79:	jne    1bad <botlish_fn_20+0x11d>
    1b7f:	mov    rdi,r14
    1b82:	mov    rdi,r14
    1b85:	mov    QWORD PTR [rdi],r13
    1b88:	xor    rax,rax
    1b8b:	mov    rbx,QWORD PTR [rsp+0x20]
    1b90:	mov    r12,QWORD PTR [rsp+0x28]
    1b95:	mov    r13,QWORD PTR [rsp+0x30]
    1b9a:	mov    r14,QWORD PTR [rsp+0x38]
    1b9f:	mov    r15,QWORD PTR [rsp+0x40]
    1ba4:	add    rsp,0x50
    1ba8:	mov    rsp,rbp
    1bab:	pop    rbp
    1bac:	ret
    1bad:	mov    QWORD PTR [rsp+0x18],0x3
    1bb6:	mov    rsi,r15
    1bb9:	test   rsi,0x1
    1bc0:	je     1be3 <botlish_fn_20+0x153>
    1bc6:	mov    rsi,r15
    1bc9:	mov    rcx,rsi
    1bcc:	add    rcx,0x2
    1bd0:	seto   al
    1bd3:	test   al,al
    1bd5:	jne    1be3 <botlish_fn_20+0x153>
    1bdb:	mov    r15,rcx
    1bde:	jmp    1bf6 <botlish_fn_20+0x166>
    1be3:	mov    edx,0x3
    1be8:	mov    rsi,r15
    1beb:	mov    rdi,r14
    1bee:	call   1bf3 <botlish_fn_20+0x163>
			1bef: R_X86_64_PLT32	rt_int_add-0x4
    1bf3:	mov    r15,rax
    1bf6:	mov    QWORD PTR [rsp],r12
    1bfa:	mov    rsi,r15
    1bfd:	mov    QWORD PTR [rsp+0x8],rsi
    1c02:	mov    QWORD PTR [rsp+0x10],rbx
    1c07:	jmp    1af7 <botlish_fn_20+0x67>
    1c0c:	mov    rdi,r14
    1c0f:	mov    QWORD PTR [rdi],r13
    1c12:	mov    eax,0xa
    1c17:	mov    rbx,QWORD PTR [rsp+0x20]
    1c1c:	mov    r12,QWORD PTR [rsp+0x28]
    1c21:	mov    r13,QWORD PTR [rsp+0x30]
    1c26:	mov    r14,QWORD PTR [rsp+0x38]
    1c2b:	mov    r15,QWORD PTR [rsp+0x40]
    1c30:	add    rsp,0x50
    1c34:	mov    rsp,rbp
    1c37:	pop    rbp
    1c38:	ret
    1c39:	mov    r14,rdi
    1c3c:	call   1c41 <botlish_fn_20+0x1b1>
			1c3d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1c41:	xor    rax,rax
    1c44:	mov    rbx,QWORD PTR [rsp+0x20]
    1c49:	mov    r12,QWORD PTR [rsp+0x28]
    1c4e:	mov    r13,QWORD PTR [rsp+0x30]
    1c53:	mov    r14,QWORD PTR [rsp+0x38]
    1c58:	mov    r15,QWORD PTR [rsp+0x40]
    1c5d:	add    rsp,0x50
    1c61:	mov    rsp,rbp
    1c64:	pop    rbp
    1c65:	ret
    1c66:	add    BYTE PTR [rax],al
    1c68:	(bad)
    1c69:	add    BYTE PTR [rax],al
    1c6b:	add    BYTE PTR [rax],al
    1c6d:	add    BYTE PTR [rax],al
	...

0000000000001c70 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    1c70:	push   rbp
    1c71:	mov    rbp,rsp
    1c74:	mov    rsi,QWORD PTR [rdx]
    1c77:	mov    r8,QWORD PTR [rdx+0x8]
    1c7b:	mov    rcx,QWORD PTR [rdx+0x10]
    1c7f:	mov    rdx,r8
    1c82:	call   1c87 <botlish_entry_20+0x17>
			1c83: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1c87:	mov    rsp,rbp
    1c8a:	pop    rbp
    1c8b:	ret

0000000000001c8c <botlish_fn_21: ht_alloc<int>>:
    1c8c:	push   rbp
    1c8d:	mov    rbp,rsp
    1c90:	sub    rsp,0x60
    1c94:	mov    QWORD PTR [rsp+0x30],rbx
    1c99:	mov    QWORD PTR [rsp+0x38],r12
    1c9e:	mov    QWORD PTR [rsp+0x40],r13
    1ca3:	mov    QWORD PTR [rsp+0x48],r14
    1ca8:	mov    QWORD PTR [rsp+0x50],r15
    1cad:	mov    rbx,QWORD PTR [rdi]
    1cb0:	mov    rax,QWORD PTR [rdi+0x8]
    1cb4:	lea    rcx,[rbx+0x8]
    1cb8:	cmp    rcx,rax
    1cbb:	ja     1ecd <botlish_fn_21+0x241>
    1cc1:	lea    rax,[rbx+0x8]
    1cc5:	mov    QWORD PTR [rdi],rax
    1cc8:	mov    r12,rdi
    1ccb:	mov    QWORD PTR [rbx],0x0
    1cd2:	mov    QWORD PTR [rsp+0x8],0x0
    1cdb:	mov    QWORD PTR [rsp+0x10],0x0
    1ce4:	mov    QWORD PTR [rsp+0x18],0x0
    1ced:	mov    QWORD PTR [rsp],rsi
    1cf1:	mov    r13,rsi
    1cf4:	mov    rsi,r13
    1cf7:	mov    rdi,r12
    1cfa:	call   1cff <botlish_fn_21+0x73>
			1cfb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1cff:	test   rax,rax
    1d02:	jne    1d10 <botlish_fn_21+0x84>
    1d08:	mov    rdi,r12
    1d0b:	jmp    1e75 <botlish_fn_21+0x1e9>
    1d10:	mov    QWORD PTR [rsp+0x8],rax
    1d15:	mov    r14,rax
    1d18:	mov    edx,0x1
    1d1d:	mov    QWORD PTR [rsp+0x10],0x1
    1d26:	mov    rcx,r13
    1d29:	mov    rsi,r14
    1d2c:	mov    rdi,r12
    1d2f:	call   1d34 <botlish_fn_21+0xa8>
			1d30: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1d34:	test   rax,rax
    1d37:	jne    1d45 <botlish_fn_21+0xb9>
    1d3d:	mov    rdi,r12
    1d40:	jmp    1e75 <botlish_fn_21+0x1e9>
    1d45:	mov    rsi,r13
    1d48:	mov    rdi,r12
    1d4b:	call   1d50 <botlish_fn_21+0xc4>
			1d4c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d50:	test   rax,rax
    1d53:	jne    1d61 <botlish_fn_21+0xd5>
    1d59:	mov    rdi,r12
    1d5c:	jmp    1e75 <botlish_fn_21+0x1e9>
    1d61:	mov    QWORD PTR [rsp+0x10],rax
    1d66:	mov    rsi,r13
    1d69:	mov    r15,rax
    1d6c:	mov    rdi,r12
    1d6f:	call   1d74 <botlish_fn_21+0xe8>
			1d70: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d74:	test   rax,rax
    1d77:	jne    1d85 <botlish_fn_21+0xf9>
    1d7d:	mov    rdi,r12
    1d80:	jmp    1e75 <botlish_fn_21+0x1e9>
    1d85:	mov    QWORD PTR [rsp],rax
    1d89:	mov    r13,rax
    1d8c:	mov    esi,0xb
    1d91:	mov    QWORD PTR [rsp+0x18],0xb
    1d9a:	mov    rdi,r12
    1d9d:	call   1da2 <botlish_fn_21+0x116>
			1d9e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1da2:	test   rax,rax
    1da5:	mov    QWORD PTR [rsp+0x20],rax
    1daa:	jne    1db8 <botlish_fn_21+0x12c>
    1db0:	mov    rdi,r12
    1db3:	jmp    1e75 <botlish_fn_21+0x1e9>
    1db8:	mov    edx,0x1
    1dbd:	mov    rcx,r14
    1dc0:	mov    rsi,QWORD PTR [rsp+0x20]
    1dc5:	mov    rdi,r12
    1dc8:	call   1dcd <botlish_fn_21+0x141>
			1dc9: R_X86_64_PLT32	rt_mutarray_set-0x4
    1dcd:	test   rax,rax
    1dd0:	jne    1dde <botlish_fn_21+0x152>
    1dd6:	mov    rdi,r12
    1dd9:	jmp    1e75 <botlish_fn_21+0x1e9>
    1dde:	mov    edx,0x3
    1de3:	mov    rcx,r15
    1de6:	mov    rsi,QWORD PTR [rsp+0x20]
    1deb:	mov    rdi,r12
    1dee:	call   1df3 <botlish_fn_21+0x167>
			1def: R_X86_64_PLT32	rt_mutarray_set-0x4
    1df3:	test   rax,rax
    1df6:	jne    1e04 <botlish_fn_21+0x178>
    1dfc:	mov    rdi,r12
    1dff:	jmp    1e75 <botlish_fn_21+0x1e9>
    1e04:	mov    edx,0x5
    1e09:	mov    rcx,r13
    1e0c:	mov    rsi,QWORD PTR [rsp+0x20]
    1e11:	mov    rdi,r12
    1e14:	call   1e19 <botlish_fn_21+0x18d>
			1e15: R_X86_64_PLT32	rt_mutarray_set-0x4
    1e19:	test   rax,rax
    1e1c:	jne    1e2a <botlish_fn_21+0x19e>
    1e22:	mov    rdi,r12
    1e25:	jmp    1e75 <botlish_fn_21+0x1e9>
    1e2a:	mov    edx,0x7
    1e2f:	mov    ecx,0x1
    1e34:	mov    rsi,QWORD PTR [rsp+0x20]
    1e39:	mov    rdi,r12
    1e3c:	call   1e41 <botlish_fn_21+0x1b5>
			1e3d: R_X86_64_PLT32	rt_mutarray_set-0x4
    1e41:	test   rax,rax
    1e44:	jne    1e52 <botlish_fn_21+0x1c6>
    1e4a:	mov    rdi,r12
    1e4d:	jmp    1e75 <botlish_fn_21+0x1e9>
    1e52:	mov    edx,0x9
    1e57:	mov    ecx,0x1
    1e5c:	mov    rsi,QWORD PTR [rsp+0x20]
    1e61:	mov    rdi,r12
    1e64:	call   1e69 <botlish_fn_21+0x1dd>
			1e65: R_X86_64_PLT32	rt_mutarray_set-0x4
    1e69:	test   rax,rax
    1e6c:	jne    1ea0 <botlish_fn_21+0x214>
    1e72:	mov    rdi,r12
    1e75:	mov    rdi,r12
    1e78:	mov    QWORD PTR [rdi],rbx
    1e7b:	xor    rax,rax
    1e7e:	mov    rbx,QWORD PTR [rsp+0x30]
    1e83:	mov    r12,QWORD PTR [rsp+0x38]
    1e88:	mov    r13,QWORD PTR [rsp+0x40]
    1e8d:	mov    r14,QWORD PTR [rsp+0x48]
    1e92:	mov    r15,QWORD PTR [rsp+0x50]
    1e97:	add    rsp,0x60
    1e9b:	mov    rsp,rbp
    1e9e:	pop    rbp
    1e9f:	ret
    1ea0:	mov    rdi,r12
    1ea3:	mov    QWORD PTR [rdi],rbx
    1ea6:	mov    rax,QWORD PTR [rsp+0x20]
    1eab:	mov    rbx,QWORD PTR [rsp+0x30]
    1eb0:	mov    r12,QWORD PTR [rsp+0x38]
    1eb5:	mov    r13,QWORD PTR [rsp+0x40]
    1eba:	mov    r14,QWORD PTR [rsp+0x48]
    1ebf:	mov    r15,QWORD PTR [rsp+0x50]
    1ec4:	add    rsp,0x60
    1ec8:	mov    rsp,rbp
    1ecb:	pop    rbp
    1ecc:	ret
    1ecd:	mov    r12,rdi
    1ed0:	call   1ed5 <botlish_fn_21+0x249>
			1ed1: R_X86_64_PLT32	rt_stack_overflow-0x4
    1ed5:	xor    rax,rax
    1ed8:	mov    rbx,QWORD PTR [rsp+0x30]
    1edd:	mov    r12,QWORD PTR [rsp+0x38]
    1ee2:	mov    r13,QWORD PTR [rsp+0x40]
    1ee7:	mov    r14,QWORD PTR [rsp+0x48]
    1eec:	mov    r15,QWORD PTR [rsp+0x50]
    1ef1:	add    rsp,0x60
    1ef5:	mov    rsp,rbp
    1ef8:	pop    rbp
    1ef9:	ret

0000000000001efa <botlish_entry_21: ht_alloc<int>>:
    1efa:	push   rbp
    1efb:	mov    rbp,rsp
    1efe:	mov    rsi,QWORD PTR [rdx]
    1f01:	call   1f06 <botlish_entry_21+0xc>
			1f02: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1f06:	mov    rsp,rbp
    1f09:	pop    rbp
    1f0a:	ret

0000000000001f0b <botlish_fn_22: ht_new<generic>>:
    1f0b:	push   rbp
    1f0c:	mov    rbp,rsp
    1f0f:	sub    rsp,0x20
    1f13:	mov    QWORD PTR [rsp+0x10],r12
    1f18:	mov    QWORD PTR [rsp+0x18],r13
    1f1d:	mov    r12,QWORD PTR [rdi]
    1f20:	mov    rax,QWORD PTR [rdi+0x8]
    1f24:	lea    rcx,[r12+0x8]
    1f29:	cmp    rcx,rax
    1f2c:	ja     1fb6 <botlish_fn_22+0xab>
    1f32:	lea    rax,[r12+0x8]
    1f37:	mov    QWORD PTR [rdi],rax
    1f3a:	mov    r13,rdi
    1f3d:	mov    QWORD PTR [r12],0x0
    1f45:	mov    QWORD PTR [rsp],0x0
    1f4d:	mov    rdi,r13
    1f50:	call   1f55 <botlish_fn_22+0x4a>
			1f51: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1f55:	test   rax,rax
    1f58:	jne    1f66 <botlish_fn_22+0x5b>
    1f5e:	mov    rdi,r13
    1f61:	jmp    1f81 <botlish_fn_22+0x76>
    1f66:	mov    QWORD PTR [rsp],rax
    1f6a:	mov    rsi,rax
    1f6d:	mov    rdi,r13
    1f70:	call   1f75 <botlish_fn_22+0x6a>
			1f71: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1f75:	test   rax,rax
    1f78:	jne    1f9d <botlish_fn_22+0x92>
    1f7e:	mov    rdi,r13
    1f81:	mov    rdi,r13
    1f84:	mov    QWORD PTR [rdi],r12
    1f87:	xor    rax,rax
    1f8a:	mov    r12,QWORD PTR [rsp+0x10]
    1f8f:	mov    r13,QWORD PTR [rsp+0x18]
    1f94:	add    rsp,0x20
    1f98:	mov    rsp,rbp
    1f9b:	pop    rbp
    1f9c:	ret
    1f9d:	mov    rdi,r13
    1fa0:	mov    QWORD PTR [rdi],r12
    1fa3:	mov    r12,QWORD PTR [rsp+0x10]
    1fa8:	mov    r13,QWORD PTR [rsp+0x18]
    1fad:	add    rsp,0x20
    1fb1:	mov    rsp,rbp
    1fb4:	pop    rbp
    1fb5:	ret
    1fb6:	mov    r13,rdi
    1fb9:	call   1fbe <botlish_fn_22+0xb3>
			1fba: R_X86_64_PLT32	rt_stack_overflow-0x4
    1fbe:	xor    rax,rax
    1fc1:	mov    r12,QWORD PTR [rsp+0x10]
    1fc6:	mov    r13,QWORD PTR [rsp+0x18]
    1fcb:	add    rsp,0x20
    1fcf:	mov    rsp,rbp
    1fd2:	pop    rbp
    1fd3:	ret

0000000000001fd4 <botlish_entry_22: ht_new<generic>>:
    1fd4:	push   rbp
    1fd5:	mov    rbp,rsp
    1fd8:	call   1fdd <botlish_entry_22+0x9>
			1fd9: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    1fdd:	mov    rsp,rbp
    1fe0:	pop    rbp
    1fe1:	ret
    1fe2:	add    BYTE PTR [rax],al
    1fe4:	add    BYTE PTR [rax],al
	...

0000000000001fe8 <botlish_fn_23: ht_capacity_for<int, int>>:
    1fe8:	push   rbp
    1fe9:	mov    rbp,rsp
    1fec:	sub    rsp,0x50
    1ff0:	mov    QWORD PTR [rsp+0x20],rbx
    1ff5:	mov    QWORD PTR [rsp+0x28],r12
    1ffa:	mov    QWORD PTR [rsp+0x30],r13
    1fff:	mov    QWORD PTR [rsp+0x38],r14
    2004:	mov    QWORD PTR [rsp+0x40],r15
    2009:	mov    r13,rdi
    200c:	mov    QWORD PTR [rsp],rdx
    2010:	mov    rbx,rsi
    2013:	or     rbx,0x1
    2017:	sar    rbx,1
    201a:	mov    r12,rsi
    201d:	mov    r14,rdx
    2020:	mov    rax,r12
    2023:	or     rax,0x1
    2027:	mov    QWORD PTR [rsp+0x8],rax
    202c:	mov    QWORD PTR [rsp+0x10],0x7
    2035:	mov    rax,rbx
    2038:	imul   QWORD PTR [rip+0x159]        # 2198 <botlish_fn_23+0x1b0>
    203f:	seto   cl
    2042:	or     rax,0x1
    2046:	test   cl,cl
    2048:	jne    2056 <botlish_fn_23+0x6e>
    204e:	mov    rsi,rax
    2051:	jmp    206d <botlish_fn_23+0x85>
    2056:	mov    rsi,r12
    2059:	or     rsi,0x1
    205d:	mov    edx,0x7
    2062:	mov    rdi,r13
    2065:	call   206a <botlish_fn_23+0x82>
			2066: R_X86_64_PLT32	rt_int_mul-0x4
    206a:	mov    rsi,rax
    206d:	mov    QWORD PTR [rsp+0x8],rsi
    2072:	mov    r15,rsi
    2075:	mov    QWORD PTR [rsp+0x10],0x5
    207e:	mov    rsi,r14
    2081:	test   rsi,0x1
    2088:	je     20b8 <botlish_fn_23+0xd0>
    208e:	mov    rsi,r14
    2091:	mov    rax,rsi
    2094:	sar    rax,1
    2097:	imul   QWORD PTR [rip+0x102]        # 21a0 <botlish_fn_23+0x1b8>
    209e:	seto   cl
    20a1:	or     rax,0x1
    20a5:	test   cl,cl
    20a7:	jne    20b8 <botlish_fn_23+0xd0>
    20ad:	mov    rdx,rax
    20b0:	mov    rsi,r15
    20b3:	jmp    20ce <botlish_fn_23+0xe6>
    20b8:	mov    edx,0x5
    20bd:	mov    rsi,r14
    20c0:	mov    rdi,r13
    20c3:	call   20c8 <botlish_fn_23+0xe0>
			20c4: R_X86_64_PLT32	rt_int_mul-0x4
    20c8:	mov    rdx,rax
    20cb:	mov    rsi,r15
    20ce:	mov    rax,rsi
    20d1:	and    rax,rdx
    20d4:	test   rax,0x1
    20da:	jne    20fd <botlish_fn_23+0x115>
    20e0:	mov    rdi,r13
    20e3:	call   20e8 <botlish_fn_23+0x100>
			20e4: R_X86_64_PLT32	rt_int_cmp-0x4
    20e8:	mov    ecx,0x2
    20ed:	test   rax,rax
    20f0:	cmovle rcx,QWORD PTR [rip+0xa0]        # 2198 <botlish_fn_23+0x1b0>
    20f8:	jmp    210d <botlish_fn_23+0x125>
    20fd:	mov    ecx,0x2
    2102:	cmp    rsi,rdx
    2105:	cmovle rcx,QWORD PTR [rip+0x8b]        # 2198 <botlish_fn_23+0x1b0>
    210d:	cmp    rcx,0x6
    2111:	je     216d <botlish_fn_23+0x185>
    2117:	mov    QWORD PTR [rsp+0x8],0x5
    2120:	mov    rsi,r14
    2123:	test   rsi,0x1
    212a:	je     2151 <botlish_fn_23+0x169>
    2130:	mov    rsi,r14
    2133:	mov    rax,rsi
    2136:	sar    rax,1
    2139:	imul   QWORD PTR [rip+0x60]        # 21a0 <botlish_fn_23+0x1b8>
    2140:	seto   sil
    2144:	or     rax,0x1
    2148:	test   sil,sil
    214b:	je     2161 <botlish_fn_23+0x179>
    2151:	mov    edx,0x5
    2156:	mov    rsi,r14
    2159:	mov    rdi,r13
    215c:	call   2161 <botlish_fn_23+0x179>
			215d: R_X86_64_PLT32	rt_int_mul-0x4
    2161:	mov    QWORD PTR [rsp],rax
    2165:	mov    r14,rax
    2168:	jmp    2020 <botlish_fn_23+0x38>
    216d:	mov    rax,r14
    2170:	mov    rbx,QWORD PTR [rsp+0x20]
    2175:	mov    r12,QWORD PTR [rsp+0x28]
    217a:	mov    r13,QWORD PTR [rsp+0x30]
    217f:	mov    r14,QWORD PTR [rsp+0x38]
    2184:	mov    r15,QWORD PTR [rsp+0x40]
    2189:	add    rsp,0x50
    218d:	mov    rsp,rbp
    2190:	pop    rbp
    2191:	ret
    2192:	add    BYTE PTR [rax],al
    2194:	add    BYTE PTR [rax],al
    2196:	add    BYTE PTR [rax],al
    2198:	(bad)
    2199:	add    BYTE PTR [rax],al
    219b:	add    BYTE PTR [rax],al
    219d:	add    BYTE PTR [rax],al
    219f:	add    BYTE PTR [rax+rax*1],al
    21a2:	add    BYTE PTR [rax],al
    21a4:	add    BYTE PTR [rax],al
	...

00000000000021a8 <botlish_entry_23: ht_capacity_for<int, int>>:
    21a8:	push   rbp
    21a9:	mov    rbp,rsp
    21ac:	mov    rsi,QWORD PTR [rdx]
    21af:	mov    rdx,QWORD PTR [rdx+0x8]
    21b3:	call   21b8 <botlish_entry_23+0x10>
			21b4: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    21b8:	mov    rsp,rbp
    21bb:	pop    rbp
    21bc:	ret

00000000000021bd <botlish_fn_24: ht_new_sized<int>>:
    21bd:	push   rbp
    21be:	mov    rbp,rsp
    21c1:	sub    rsp,0x30
    21c5:	mov    QWORD PTR [rsp+0x10],rbx
    21ca:	mov    QWORD PTR [rsp+0x18],r14
    21cf:	mov    QWORD PTR [rsp+0x20],r15
    21d4:	mov    r14,QWORD PTR [rdi]
    21d7:	mov    rax,QWORD PTR [rdi+0x8]
    21db:	lea    rcx,[r14+0x8]
    21df:	cmp    rcx,rax
    21e2:	ja     22a0 <botlish_fn_24+0xe3>
    21e8:	lea    rax,[r14+0x8]
    21ec:	mov    QWORD PTR [rdi],rax
    21ef:	mov    r15,rdi
    21f2:	mov    QWORD PTR [r14],0x0
    21f9:	mov    QWORD PTR [rsp+0x8],0x0
    2202:	mov    QWORD PTR [rsp],rsi
    2206:	mov    rbx,rsi
    2209:	mov    rdi,r15
    220c:	call   2211 <botlish_fn_24+0x54>
			220d: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    2211:	test   rax,rax
    2214:	jne    2222 <botlish_fn_24+0x65>
    221a:	mov    rdi,r15
    221d:	jmp    2261 <botlish_fn_24+0xa4>
    2222:	mov    QWORD PTR [rsp+0x8],rax
    2227:	mov    rdx,rax
    222a:	mov    rsi,rbx
    222d:	mov    rdi,r15
    2230:	call   2235 <botlish_fn_24+0x78>
			2231: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    2235:	test   rax,rax
    2238:	jne    2246 <botlish_fn_24+0x89>
    223e:	mov    rdi,r15
    2241:	jmp    2261 <botlish_fn_24+0xa4>
    2246:	mov    QWORD PTR [rsp],rax
    224a:	mov    rsi,rax
    224d:	mov    rdi,r15
    2250:	call   2255 <botlish_fn_24+0x98>
			2251: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2255:	test   rax,rax
    2258:	jne    2282 <botlish_fn_24+0xc5>
    225e:	mov    rdi,r15
    2261:	mov    rdi,r15
    2264:	mov    QWORD PTR [rdi],r14
    2267:	xor    rax,rax
    226a:	mov    rbx,QWORD PTR [rsp+0x10]
    226f:	mov    r14,QWORD PTR [rsp+0x18]
    2274:	mov    r15,QWORD PTR [rsp+0x20]
    2279:	add    rsp,0x30
    227d:	mov    rsp,rbp
    2280:	pop    rbp
    2281:	ret
    2282:	mov    rdi,r15
    2285:	mov    QWORD PTR [rdi],r14
    2288:	mov    rbx,QWORD PTR [rsp+0x10]
    228d:	mov    r14,QWORD PTR [rsp+0x18]
    2292:	mov    r15,QWORD PTR [rsp+0x20]
    2297:	add    rsp,0x30
    229b:	mov    rsp,rbp
    229e:	pop    rbp
    229f:	ret
    22a0:	mov    r15,rdi
    22a3:	call   22a8 <botlish_fn_24+0xeb>
			22a4: R_X86_64_PLT32	rt_stack_overflow-0x4
    22a8:	xor    rax,rax
    22ab:	mov    rbx,QWORD PTR [rsp+0x10]
    22b0:	mov    r14,QWORD PTR [rsp+0x18]
    22b5:	mov    r15,QWORD PTR [rsp+0x20]
    22ba:	add    rsp,0x30
    22be:	mov    rsp,rbp
    22c1:	pop    rbp
    22c2:	ret

00000000000022c3 <botlish_entry_24: ht_new_sized<int>>:
    22c3:	push   rbp
    22c4:	mov    rbp,rsp
    22c7:	mov    rsi,QWORD PTR [rdx]
    22ca:	call   22cf <botlish_entry_24+0xc>
			22cb: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    22cf:	mov    rsp,rbp
    22d2:	pop    rbp
    22d3:	ret

00000000000022d4 <botlish_fn_25: ht_controls<mutarray>>:
    22d4:	push   rbp
    22d5:	mov    rbp,rsp
    22d8:	mov    edx,0x1
    22dd:	call   22e2 <botlish_fn_25+0xe>
			22de: R_X86_64_PLT32	rt_mutarray_get-0x4
    22e2:	test   rax,rax
    22e5:	jne    22f3 <botlish_fn_25+0x1f>
    22eb:	xor    rax,rax
    22ee:	mov    rsp,rbp
    22f1:	pop    rbp
    22f2:	ret
    22f3:	mov    rsp,rbp
    22f6:	pop    rbp
    22f7:	ret

00000000000022f8 <botlish_entry_25: ht_controls<mutarray>>:
    22f8:	push   rbp
    22f9:	mov    rbp,rsp
    22fc:	mov    rsi,QWORD PTR [rdx]
    22ff:	call   2304 <botlish_entry_25+0xc>
			2300: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    2304:	mov    rsp,rbp
    2307:	pop    rbp
    2308:	ret

0000000000002309 <botlish_fn_26: ht_controls<generic>>:
    2309:	push   rbp
    230a:	mov    rbp,rsp
    230d:	xor    r8d,r8d
    2310:	test   rsi,0x7
    2317:	jne    2327 <botlish_fn_26+0x1e>
    231d:	movzx  rax,BYTE PTR [rsi]
    2321:	cmp    al,0x8
    2323:	sete   r8b
    2327:	test   r8b,r8b
    232a:	jne    2347 <botlish_fn_26+0x3e>
    2330:	mov    rax,QWORD PTR [rdi+0x10]
    2334:	mov    rcx,QWORD PTR [rax+0x20]
    2338:	mov    edx,0x8
    233d:	call   2342 <botlish_fn_26+0x39>
			233e: R_X86_64_PLT32	rt_type_error-0x4
    2342:	jmp    235a <botlish_fn_26+0x51>
    2347:	mov    edx,0x1
    234c:	call   2351 <botlish_fn_26+0x48>
			234d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2351:	test   rax,rax
    2354:	jne    2362 <botlish_fn_26+0x59>
    235a:	xor    rax,rax
    235d:	mov    rsp,rbp
    2360:	pop    rbp
    2361:	ret
    2362:	mov    rsp,rbp
    2365:	pop    rbp
    2366:	ret

0000000000002367 <botlish_entry_26: ht_controls<generic>>:
    2367:	push   rbp
    2368:	mov    rbp,rsp
    236b:	mov    rsi,QWORD PTR [rdx]
    236e:	call   2373 <botlish_entry_26+0xc>
			236f: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2373:	mov    rsp,rbp
    2376:	pop    rbp
    2377:	ret

0000000000002378 <botlish_fn_27: ht_keys<mutarray>>:
    2378:	push   rbp
    2379:	mov    rbp,rsp
    237c:	mov    edx,0x3
    2381:	call   2386 <botlish_fn_27+0xe>
			2382: R_X86_64_PLT32	rt_mutarray_get-0x4
    2386:	test   rax,rax
    2389:	jne    2397 <botlish_fn_27+0x1f>
    238f:	xor    rax,rax
    2392:	mov    rsp,rbp
    2395:	pop    rbp
    2396:	ret
    2397:	mov    rsp,rbp
    239a:	pop    rbp
    239b:	ret

000000000000239c <botlish_entry_27: ht_keys<mutarray>>:
    239c:	push   rbp
    239d:	mov    rbp,rsp
    23a0:	mov    rsi,QWORD PTR [rdx]
    23a3:	call   23a8 <botlish_entry_27+0xc>
			23a4: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    23a8:	mov    rsp,rbp
    23ab:	pop    rbp
    23ac:	ret

00000000000023ad <botlish_fn_28: ht_keys<generic>>:
    23ad:	push   rbp
    23ae:	mov    rbp,rsp
    23b1:	xor    r8d,r8d
    23b4:	test   rsi,0x7
    23bb:	jne    23cb <botlish_fn_28+0x1e>
    23c1:	movzx  rax,BYTE PTR [rsi]
    23c5:	cmp    al,0x8
    23c7:	sete   r8b
    23cb:	test   r8b,r8b
    23ce:	jne    23eb <botlish_fn_28+0x3e>
    23d4:	mov    rax,QWORD PTR [rdi+0x10]
    23d8:	mov    rcx,QWORD PTR [rax+0x20]
    23dc:	mov    edx,0x8
    23e1:	call   23e6 <botlish_fn_28+0x39>
			23e2: R_X86_64_PLT32	rt_type_error-0x4
    23e6:	jmp    23fe <botlish_fn_28+0x51>
    23eb:	mov    edx,0x3
    23f0:	call   23f5 <botlish_fn_28+0x48>
			23f1: R_X86_64_PLT32	rt_mutarray_get-0x4
    23f5:	test   rax,rax
    23f8:	jne    2406 <botlish_fn_28+0x59>
    23fe:	xor    rax,rax
    2401:	mov    rsp,rbp
    2404:	pop    rbp
    2405:	ret
    2406:	mov    rsp,rbp
    2409:	pop    rbp
    240a:	ret

000000000000240b <botlish_entry_28: ht_keys<generic>>:
    240b:	push   rbp
    240c:	mov    rbp,rsp
    240f:	mov    rsi,QWORD PTR [rdx]
    2412:	call   2417 <botlish_entry_28+0xc>
			2413: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2417:	mov    rsp,rbp
    241a:	pop    rbp
    241b:	ret

000000000000241c <botlish_fn_29: ht_values<mutarray>>:
    241c:	push   rbp
    241d:	mov    rbp,rsp
    2420:	mov    edx,0x5
    2425:	call   242a <botlish_fn_29+0xe>
			2426: R_X86_64_PLT32	rt_mutarray_get-0x4
    242a:	test   rax,rax
    242d:	jne    243b <botlish_fn_29+0x1f>
    2433:	xor    rax,rax
    2436:	mov    rsp,rbp
    2439:	pop    rbp
    243a:	ret
    243b:	mov    rsp,rbp
    243e:	pop    rbp
    243f:	ret

0000000000002440 <botlish_entry_29: ht_values<mutarray>>:
    2440:	push   rbp
    2441:	mov    rbp,rsp
    2444:	mov    rsi,QWORD PTR [rdx]
    2447:	call   244c <botlish_entry_29+0xc>
			2448: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    244c:	mov    rsp,rbp
    244f:	pop    rbp
    2450:	ret

0000000000002451 <botlish_fn_30: ht_values<generic>>:
    2451:	push   rbp
    2452:	mov    rbp,rsp
    2455:	xor    r8d,r8d
    2458:	test   rsi,0x7
    245f:	jne    246f <botlish_fn_30+0x1e>
    2465:	movzx  rax,BYTE PTR [rsi]
    2469:	cmp    al,0x8
    246b:	sete   r8b
    246f:	test   r8b,r8b
    2472:	jne    248f <botlish_fn_30+0x3e>
    2478:	mov    rax,QWORD PTR [rdi+0x10]
    247c:	mov    rcx,QWORD PTR [rax+0x20]
    2480:	mov    edx,0x8
    2485:	call   248a <botlish_fn_30+0x39>
			2486: R_X86_64_PLT32	rt_type_error-0x4
    248a:	jmp    24a2 <botlish_fn_30+0x51>
    248f:	mov    edx,0x5
    2494:	call   2499 <botlish_fn_30+0x48>
			2495: R_X86_64_PLT32	rt_mutarray_get-0x4
    2499:	test   rax,rax
    249c:	jne    24aa <botlish_fn_30+0x59>
    24a2:	xor    rax,rax
    24a5:	mov    rsp,rbp
    24a8:	pop    rbp
    24a9:	ret
    24aa:	mov    rsp,rbp
    24ad:	pop    rbp
    24ae:	ret

00000000000024af <botlish_entry_30: ht_values<generic>>:
    24af:	push   rbp
    24b0:	mov    rbp,rsp
    24b3:	mov    rsi,QWORD PTR [rdx]
    24b6:	call   24bb <botlish_entry_30+0xc>
			24b7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    24bb:	mov    rsp,rbp
    24be:	pop    rbp
    24bf:	ret

00000000000024c0 <botlish_fn_31: ht_size<mutarray>>:
    24c0:	push   rbp
    24c1:	mov    rbp,rsp
    24c4:	mov    edx,0x7
    24c9:	call   24ce <botlish_fn_31+0xe>
			24ca: R_X86_64_PLT32	rt_mutarray_get-0x4
    24ce:	test   rax,rax
    24d1:	jne    24df <botlish_fn_31+0x1f>
    24d7:	xor    rax,rax
    24da:	mov    rsp,rbp
    24dd:	pop    rbp
    24de:	ret
    24df:	mov    rsp,rbp
    24e2:	pop    rbp
    24e3:	ret

00000000000024e4 <botlish_entry_31: ht_size<mutarray>>:
    24e4:	push   rbp
    24e5:	mov    rbp,rsp
    24e8:	mov    rsi,QWORD PTR [rdx]
    24eb:	call   24f0 <botlish_entry_31+0xc>
			24ec: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    24f0:	mov    rsp,rbp
    24f3:	pop    rbp
    24f4:	ret

00000000000024f5 <botlish_fn_32: ht_size<generic>>:
    24f5:	push   rbp
    24f6:	mov    rbp,rsp
    24f9:	xor    r8d,r8d
    24fc:	test   rsi,0x7
    2503:	jne    2513 <botlish_fn_32+0x1e>
    2509:	movzx  rax,BYTE PTR [rsi]
    250d:	cmp    al,0x8
    250f:	sete   r8b
    2513:	test   r8b,r8b
    2516:	jne    2533 <botlish_fn_32+0x3e>
    251c:	mov    rax,QWORD PTR [rdi+0x10]
    2520:	mov    rcx,QWORD PTR [rax+0x20]
    2524:	mov    edx,0x8
    2529:	call   252e <botlish_fn_32+0x39>
			252a: R_X86_64_PLT32	rt_type_error-0x4
    252e:	jmp    2546 <botlish_fn_32+0x51>
    2533:	mov    edx,0x7
    2538:	call   253d <botlish_fn_32+0x48>
			2539: R_X86_64_PLT32	rt_mutarray_get-0x4
    253d:	test   rax,rax
    2540:	jne    254e <botlish_fn_32+0x59>
    2546:	xor    rax,rax
    2549:	mov    rsp,rbp
    254c:	pop    rbp
    254d:	ret
    254e:	mov    rsp,rbp
    2551:	pop    rbp
    2552:	ret

0000000000002553 <botlish_entry_32: ht_size<generic>>:
    2553:	push   rbp
    2554:	mov    rbp,rsp
    2557:	mov    rsi,QWORD PTR [rdx]
    255a:	call   255f <botlish_entry_32+0xc>
			255b: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    255f:	mov    rsp,rbp
    2562:	pop    rbp
    2563:	ret

0000000000002564 <botlish_fn_33: ht_tombstones<mutarray>>:
    2564:	push   rbp
    2565:	mov    rbp,rsp
    2568:	mov    edx,0x9
    256d:	call   2572 <botlish_fn_33+0xe>
			256e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2572:	test   rax,rax
    2575:	jne    2583 <botlish_fn_33+0x1f>
    257b:	xor    rax,rax
    257e:	mov    rsp,rbp
    2581:	pop    rbp
    2582:	ret
    2583:	mov    rsp,rbp
    2586:	pop    rbp
    2587:	ret

0000000000002588 <botlish_entry_33: ht_tombstones<mutarray>>:
    2588:	push   rbp
    2589:	mov    rbp,rsp
    258c:	mov    rsi,QWORD PTR [rdx]
    258f:	call   2594 <botlish_entry_33+0xc>
			2590: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    2594:	mov    rsp,rbp
    2597:	pop    rbp
    2598:	ret

0000000000002599 <botlish_fn_34: ht_capacity<mutarray>>:
    2599:	push   rbp
    259a:	mov    rbp,rsp
    259d:	sub    rsp,0x20
    25a1:	mov    QWORD PTR [rsp+0x10],rbx
    25a6:	mov    QWORD PTR [rsp+0x18],r12
    25ab:	mov    rbx,QWORD PTR [rdi]
    25ae:	mov    rax,QWORD PTR [rdi+0x8]
    25b2:	lea    rcx,[rbx+0x8]
    25b6:	cmp    rcx,rax
    25b9:	ja     266e <botlish_fn_34+0xd5>
    25bf:	lea    rax,[rbx+0x8]
    25c3:	mov    QWORD PTR [rdi],rax
    25c6:	mov    r12,rdi
    25c9:	mov    QWORD PTR [rbx],0x0
    25d0:	mov    QWORD PTR [rsp],rsi
    25d4:	mov    rdi,r12
    25d7:	call   25dc <botlish_fn_34+0x43>
			25d8: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    25dc:	test   rax,rax
    25df:	jne    25ed <botlish_fn_34+0x54>
    25e5:	mov    rdi,r12
    25e8:	jmp    2631 <botlish_fn_34+0x98>
    25ed:	xor    ecx,ecx
    25ef:	test   rax,0x7
    25f5:	je     2603 <botlish_fn_34+0x6a>
    25fb:	mov    rsi,rax
    25fe:	jmp    2611 <botlish_fn_34+0x78>
    2603:	movzx  rcx,BYTE PTR [rax]
    2607:	mov    rsi,rax
    260a:	rex cmp cl,0x8
    260e:	sete   cl
    2611:	test   cl,cl
    2613:	jne    264d <botlish_fn_34+0xb4>
    2619:	mov    rdi,r12
    261c:	mov    rax,QWORD PTR [rdi+0x10]
    2620:	mov    rcx,QWORD PTR [rax+0x28]
    2624:	mov    edx,0x8
    2629:	call   262e <botlish_fn_34+0x95>
			262a: R_X86_64_PLT32	rt_type_error-0x4
    262e:	mov    rdi,r12
    2631:	mov    rdi,r12
    2634:	mov    QWORD PTR [rdi],rbx
    2637:	xor    rax,rax
    263a:	mov    rbx,QWORD PTR [rsp+0x10]
    263f:	mov    r12,QWORD PTR [rsp+0x18]
    2644:	add    rsp,0x20
    2648:	mov    rsp,rbp
    264b:	pop    rbp
    264c:	ret
    264d:	mov    rdi,r12
    2650:	call   2655 <botlish_fn_34+0xbc>
			2651: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2655:	mov    rdi,r12
    2658:	mov    QWORD PTR [rdi],rbx
    265b:	mov    rbx,QWORD PTR [rsp+0x10]
    2660:	mov    r12,QWORD PTR [rsp+0x18]
    2665:	add    rsp,0x20
    2669:	mov    rsp,rbp
    266c:	pop    rbp
    266d:	ret
    266e:	mov    r12,rdi
    2671:	call   2676 <botlish_fn_34+0xdd>
			2672: R_X86_64_PLT32	rt_stack_overflow-0x4
    2676:	xor    rax,rax
    2679:	mov    rbx,QWORD PTR [rsp+0x10]
    267e:	mov    r12,QWORD PTR [rsp+0x18]
    2683:	add    rsp,0x20
    2687:	mov    rsp,rbp
    268a:	pop    rbp
    268b:	ret

000000000000268c <botlish_entry_34: ht_capacity<mutarray>>:
    268c:	push   rbp
    268d:	mov    rbp,rsp
    2690:	mov    rsi,QWORD PTR [rdx]
    2693:	call   2698 <botlish_entry_34+0xc>
			2694: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2698:	mov    rsp,rbp
    269b:	pop    rbp
    269c:	ret

000000000000269d <botlish_fn_35: ht_capacity<generic>>:
    269d:	push   rbp
    269e:	mov    rbp,rsp
    26a1:	sub    rsp,0x20
    26a5:	mov    QWORD PTR [rsp+0x10],rbx
    26aa:	mov    QWORD PTR [rsp+0x18],r12
    26af:	mov    rbx,QWORD PTR [rdi]
    26b2:	mov    rax,QWORD PTR [rdi+0x8]
    26b6:	lea    rcx,[rbx+0x8]
    26ba:	cmp    rcx,rax
    26bd:	ja     2772 <botlish_fn_35+0xd5>
    26c3:	lea    rax,[rbx+0x8]
    26c7:	mov    QWORD PTR [rdi],rax
    26ca:	mov    r12,rdi
    26cd:	mov    QWORD PTR [rbx],0x0
    26d4:	mov    QWORD PTR [rsp],rsi
    26d8:	mov    rdi,r12
    26db:	call   26e0 <botlish_fn_35+0x43>
			26dc: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    26e0:	test   rax,rax
    26e3:	jne    26f1 <botlish_fn_35+0x54>
    26e9:	mov    rdi,r12
    26ec:	jmp    2735 <botlish_fn_35+0x98>
    26f1:	xor    ecx,ecx
    26f3:	test   rax,0x7
    26f9:	je     2707 <botlish_fn_35+0x6a>
    26ff:	mov    rsi,rax
    2702:	jmp    2715 <botlish_fn_35+0x78>
    2707:	movzx  rcx,BYTE PTR [rax]
    270b:	mov    rsi,rax
    270e:	rex cmp cl,0x8
    2712:	sete   cl
    2715:	test   cl,cl
    2717:	jne    2751 <botlish_fn_35+0xb4>
    271d:	mov    rdi,r12
    2720:	mov    rax,QWORD PTR [rdi+0x10]
    2724:	mov    rcx,QWORD PTR [rax+0x28]
    2728:	mov    edx,0x8
    272d:	call   2732 <botlish_fn_35+0x95>
			272e: R_X86_64_PLT32	rt_type_error-0x4
    2732:	mov    rdi,r12
    2735:	mov    rdi,r12
    2738:	mov    QWORD PTR [rdi],rbx
    273b:	xor    rax,rax
    273e:	mov    rbx,QWORD PTR [rsp+0x10]
    2743:	mov    r12,QWORD PTR [rsp+0x18]
    2748:	add    rsp,0x20
    274c:	mov    rsp,rbp
    274f:	pop    rbp
    2750:	ret
    2751:	mov    rdi,r12
    2754:	call   2759 <botlish_fn_35+0xbc>
			2755: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2759:	mov    rdi,r12
    275c:	mov    QWORD PTR [rdi],rbx
    275f:	mov    rbx,QWORD PTR [rsp+0x10]
    2764:	mov    r12,QWORD PTR [rsp+0x18]
    2769:	add    rsp,0x20
    276d:	mov    rsp,rbp
    2770:	pop    rbp
    2771:	ret
    2772:	mov    r12,rdi
    2775:	call   277a <botlish_fn_35+0xdd>
			2776: R_X86_64_PLT32	rt_stack_overflow-0x4
    277a:	xor    rax,rax
    277d:	mov    rbx,QWORD PTR [rsp+0x10]
    2782:	mov    r12,QWORD PTR [rsp+0x18]
    2787:	add    rsp,0x20
    278b:	mov    rsp,rbp
    278e:	pop    rbp
    278f:	ret

0000000000002790 <botlish_entry_35: ht_capacity<generic>>:
    2790:	push   rbp
    2791:	mov    rbp,rsp
    2794:	mov    rsi,QWORD PTR [rdx]
    2797:	call   279c <botlish_entry_35+0xc>
			2798: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    279c:	mov    rsp,rbp
    279f:	pop    rbp
    27a0:	ret

00000000000027a1 <botlish_fn_36: ht_probe_start<mutarray, any>>:
    27a1:	push   rbp
    27a2:	mov    rbp,rsp
    27a5:	sub    rsp,0x30
    27a9:	mov    QWORD PTR [rsp+0x10],rbx
    27ae:	mov    QWORD PTR [rsp+0x18],r12
    27b3:	mov    QWORD PTR [rsp+0x20],r15
    27b8:	mov    r15,QWORD PTR [rdi]
    27bb:	mov    rax,QWORD PTR [rdi+0x8]
    27bf:	lea    rcx,[r15+0x8]
    27c3:	cmp    rcx,rax
    27c6:	ja     287d <botlish_fn_36+0xdc>
    27cc:	lea    rax,[r15+0x8]
    27d0:	mov    QWORD PTR [rdi],rax
    27d3:	mov    rbx,rdi
    27d6:	mov    QWORD PTR [r15],0x0
    27dd:	mov    QWORD PTR [rsp],rsi
    27e1:	mov    r12,rsi
    27e4:	mov    rsi,rdx
    27e7:	mov    rdi,rbx
    27ea:	call   27ef <botlish_fn_36+0x4e>
			27eb: R_X86_64_PLT32	rt_hash-0x4
    27ef:	test   rax,rax
    27f2:	jne    2800 <botlish_fn_36+0x5f>
    27f8:	mov    rdi,rbx
    27fb:	jmp    283e <botlish_fn_36+0x9d>
    2800:	mov    QWORD PTR [rsp+0x8],rax
    2805:	mov    rsi,r12
    2808:	mov    r12,rax
    280b:	mov    rdi,rbx
    280e:	call   2813 <botlish_fn_36+0x72>
			280f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2813:	test   rax,rax
    2816:	mov    rdx,rax
    2819:	jne    2827 <botlish_fn_36+0x86>
    281f:	mov    rdi,rbx
    2822:	jmp    283e <botlish_fn_36+0x9d>
    2827:	mov    rsi,r12
    282a:	mov    rdi,rbx
    282d:	call   2832 <botlish_fn_36+0x91>
			282e: R_X86_64_PLT32	rt_int_mod-0x4
    2832:	test   rax,rax
    2835:	jne    285f <botlish_fn_36+0xbe>
    283b:	mov    rdi,rbx
    283e:	mov    rdi,rbx
    2841:	mov    QWORD PTR [rdi],r15
    2844:	xor    rax,rax
    2847:	mov    rbx,QWORD PTR [rsp+0x10]
    284c:	mov    r12,QWORD PTR [rsp+0x18]
    2851:	mov    r15,QWORD PTR [rsp+0x20]
    2856:	add    rsp,0x30
    285a:	mov    rsp,rbp
    285d:	pop    rbp
    285e:	ret
    285f:	mov    rdi,rbx
    2862:	mov    QWORD PTR [rdi],r15
    2865:	mov    rbx,QWORD PTR [rsp+0x10]
    286a:	mov    r12,QWORD PTR [rsp+0x18]
    286f:	mov    r15,QWORD PTR [rsp+0x20]
    2874:	add    rsp,0x30
    2878:	mov    rsp,rbp
    287b:	pop    rbp
    287c:	ret
    287d:	mov    rbx,rdi
    2880:	call   2885 <botlish_fn_36+0xe4>
			2881: R_X86_64_PLT32	rt_stack_overflow-0x4
    2885:	xor    rax,rax
    2888:	mov    rbx,QWORD PTR [rsp+0x10]
    288d:	mov    r12,QWORD PTR [rsp+0x18]
    2892:	mov    r15,QWORD PTR [rsp+0x20]
    2897:	add    rsp,0x30
    289b:	mov    rsp,rbp
    289e:	pop    rbp
    289f:	ret

00000000000028a0 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    28a0:	push   rbp
    28a1:	mov    rbp,rsp
    28a4:	mov    rsi,QWORD PTR [rdx]
    28a7:	mov    rdx,QWORD PTR [rdx+0x8]
    28ab:	call   28b0 <botlish_entry_36+0x10>
			28ac: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    28b0:	mov    rsp,rbp
    28b3:	pop    rbp
    28b4:	ret

00000000000028b5 <botlish_fn_37: ht_probe_start<any, str>>:
    28b5:	push   rbp
    28b6:	mov    rbp,rsp
    28b9:	sub    rsp,0x30
    28bd:	mov    QWORD PTR [rsp+0x10],rbx
    28c2:	mov    QWORD PTR [rsp+0x18],r12
    28c7:	mov    QWORD PTR [rsp+0x20],r15
    28cc:	mov    r15,QWORD PTR [rdi]
    28cf:	mov    rax,QWORD PTR [rdi+0x8]
    28d3:	lea    rcx,[r15+0x8]
    28d7:	cmp    rcx,rax
    28da:	ja     2991 <botlish_fn_37+0xdc>
    28e0:	lea    rax,[r15+0x8]
    28e4:	mov    QWORD PTR [rdi],rax
    28e7:	mov    rbx,rdi
    28ea:	mov    QWORD PTR [r15],0x0
    28f1:	mov    QWORD PTR [rsp],rsi
    28f5:	mov    r12,rsi
    28f8:	mov    rsi,rdx
    28fb:	mov    rdi,rbx
    28fe:	call   2903 <botlish_fn_37+0x4e>
			28ff: R_X86_64_PLT32	rt_hash-0x4
    2903:	test   rax,rax
    2906:	jne    2914 <botlish_fn_37+0x5f>
    290c:	mov    rdi,rbx
    290f:	jmp    2952 <botlish_fn_37+0x9d>
    2914:	mov    QWORD PTR [rsp+0x8],rax
    2919:	mov    rsi,r12
    291c:	mov    r12,rax
    291f:	mov    rdi,rbx
    2922:	call   2927 <botlish_fn_37+0x72>
			2923: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2927:	test   rax,rax
    292a:	mov    rdx,rax
    292d:	jne    293b <botlish_fn_37+0x86>
    2933:	mov    rdi,rbx
    2936:	jmp    2952 <botlish_fn_37+0x9d>
    293b:	mov    rsi,r12
    293e:	mov    rdi,rbx
    2941:	call   2946 <botlish_fn_37+0x91>
			2942: R_X86_64_PLT32	rt_int_mod-0x4
    2946:	test   rax,rax
    2949:	jne    2973 <botlish_fn_37+0xbe>
    294f:	mov    rdi,rbx
    2952:	mov    rdi,rbx
    2955:	mov    QWORD PTR [rdi],r15
    2958:	xor    rax,rax
    295b:	mov    rbx,QWORD PTR [rsp+0x10]
    2960:	mov    r12,QWORD PTR [rsp+0x18]
    2965:	mov    r15,QWORD PTR [rsp+0x20]
    296a:	add    rsp,0x30
    296e:	mov    rsp,rbp
    2971:	pop    rbp
    2972:	ret
    2973:	mov    rdi,rbx
    2976:	mov    QWORD PTR [rdi],r15
    2979:	mov    rbx,QWORD PTR [rsp+0x10]
    297e:	mov    r12,QWORD PTR [rsp+0x18]
    2983:	mov    r15,QWORD PTR [rsp+0x20]
    2988:	add    rsp,0x30
    298c:	mov    rsp,rbp
    298f:	pop    rbp
    2990:	ret
    2991:	mov    rbx,rdi
    2994:	call   2999 <botlish_fn_37+0xe4>
			2995: R_X86_64_PLT32	rt_stack_overflow-0x4
    2999:	xor    rax,rax
    299c:	mov    rbx,QWORD PTR [rsp+0x10]
    29a1:	mov    r12,QWORD PTR [rsp+0x18]
    29a6:	mov    r15,QWORD PTR [rsp+0x20]
    29ab:	add    rsp,0x30
    29af:	mov    rsp,rbp
    29b2:	pop    rbp
    29b3:	ret

00000000000029b4 <botlish_entry_37: ht_probe_start<any, str>>:
    29b4:	push   rbp
    29b5:	mov    rbp,rsp
    29b8:	mov    rsi,QWORD PTR [rdx]
    29bb:	mov    rdx,QWORD PTR [rdx+0x8]
    29bf:	call   29c4 <botlish_entry_37+0x10>
			29c0: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    29c4:	mov    rsp,rbp
    29c7:	pop    rbp
    29c8:	ret

00000000000029c9 <botlish_fn_38: ht_probe_next<mutarray, int>>:
    29c9:	push   rbp
    29ca:	mov    rbp,rsp
    29cd:	sub    rsp,0x40
    29d1:	mov    QWORD PTR [rsp+0x20],rbx
    29d6:	mov    QWORD PTR [rsp+0x28],r12
    29db:	mov    QWORD PTR [rsp+0x30],r13
    29e0:	mov    rbx,QWORD PTR [rdi]
    29e3:	mov    rax,QWORD PTR [rdi+0x8]
    29e7:	lea    rcx,[rbx+0x8]
    29eb:	cmp    rcx,rax
    29ee:	ja     2ad7 <botlish_fn_38+0x10e>
    29f4:	lea    rax,[rbx+0x8]
    29f8:	mov    QWORD PTR [rdi],rax
    29fb:	mov    r12,rdi
    29fe:	mov    QWORD PTR [rbx],0x0
    2a05:	mov    QWORD PTR [rsp],rsi
    2a09:	mov    r13,rsi
    2a0c:	mov    QWORD PTR [rsp+0x8],rdx
    2a11:	mov    QWORD PTR [rsp+0x10],0x3
    2a1a:	test   rdx,0x1
    2a21:	jne    2a2f <botlish_fn_38+0x66>
    2a27:	mov    rcx,rdx
    2a2a:	jmp    2a44 <botlish_fn_38+0x7b>
    2a2f:	mov    rsi,rdx
    2a32:	add    rsi,0x2
    2a36:	mov    rcx,rdx
    2a39:	seto   al
    2a3c:	test   al,al
    2a3e:	je     2a57 <botlish_fn_38+0x8e>
    2a44:	mov    edx,0x3
    2a49:	mov    rsi,rcx
    2a4c:	mov    rdi,r12
    2a4f:	call   2a54 <botlish_fn_38+0x8b>
			2a50: R_X86_64_PLT32	rt_int_add-0x4
    2a54:	mov    rsi,rax
    2a57:	mov    QWORD PTR [rsp+0x8],rsi
    2a5c:	mov    rax,rsi
    2a5f:	mov    rsi,r13
    2a62:	mov    r13,rax
    2a65:	mov    rdi,r12
    2a68:	call   2a6d <botlish_fn_38+0xa4>
			2a69: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2a6d:	test   rax,rax
    2a70:	mov    rdx,rax
    2a73:	jne    2a81 <botlish_fn_38+0xb8>
    2a79:	mov    rdi,r12
    2a7c:	jmp    2a98 <botlish_fn_38+0xcf>
    2a81:	mov    rsi,r13
    2a84:	mov    rdi,r12
    2a87:	call   2a8c <botlish_fn_38+0xc3>
			2a88: R_X86_64_PLT32	rt_int_mod-0x4
    2a8c:	test   rax,rax
    2a8f:	jne    2ab9 <botlish_fn_38+0xf0>
    2a95:	mov    rdi,r12
    2a98:	mov    rdi,r12
    2a9b:	mov    QWORD PTR [rdi],rbx
    2a9e:	xor    rax,rax
    2aa1:	mov    rbx,QWORD PTR [rsp+0x20]
    2aa6:	mov    r12,QWORD PTR [rsp+0x28]
    2aab:	mov    r13,QWORD PTR [rsp+0x30]
    2ab0:	add    rsp,0x40
    2ab4:	mov    rsp,rbp
    2ab7:	pop    rbp
    2ab8:	ret
    2ab9:	mov    rdi,r12
    2abc:	mov    QWORD PTR [rdi],rbx
    2abf:	mov    rbx,QWORD PTR [rsp+0x20]
    2ac4:	mov    r12,QWORD PTR [rsp+0x28]
    2ac9:	mov    r13,QWORD PTR [rsp+0x30]
    2ace:	add    rsp,0x40
    2ad2:	mov    rsp,rbp
    2ad5:	pop    rbp
    2ad6:	ret
    2ad7:	mov    r12,rdi
    2ada:	call   2adf <botlish_fn_38+0x116>
			2adb: R_X86_64_PLT32	rt_stack_overflow-0x4
    2adf:	xor    rax,rax
    2ae2:	mov    rbx,QWORD PTR [rsp+0x20]
    2ae7:	mov    r12,QWORD PTR [rsp+0x28]
    2aec:	mov    r13,QWORD PTR [rsp+0x30]
    2af1:	add    rsp,0x40
    2af5:	mov    rsp,rbp
    2af8:	pop    rbp
    2af9:	ret

0000000000002afa <botlish_entry_38: ht_probe_next<mutarray, int>>:
    2afa:	push   rbp
    2afb:	mov    rbp,rsp
    2afe:	mov    rsi,QWORD PTR [rdx]
    2b01:	mov    rdx,QWORD PTR [rdx+0x8]
    2b05:	call   2b0a <botlish_entry_38+0x10>
			2b06: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    2b0a:	mov    rsp,rbp
    2b0d:	pop    rbp
    2b0e:	ret

0000000000002b0f <botlish_fn_39: ht_probe_next<any, int>>:
    2b0f:	push   rbp
    2b10:	mov    rbp,rsp
    2b13:	sub    rsp,0x40
    2b17:	mov    QWORD PTR [rsp+0x20],rbx
    2b1c:	mov    QWORD PTR [rsp+0x28],r12
    2b21:	mov    QWORD PTR [rsp+0x30],r13
    2b26:	mov    rbx,QWORD PTR [rdi]
    2b29:	mov    rax,QWORD PTR [rdi+0x8]
    2b2d:	lea    rcx,[rbx+0x8]
    2b31:	cmp    rcx,rax
    2b34:	ja     2c1d <botlish_fn_39+0x10e>
    2b3a:	lea    rax,[rbx+0x8]
    2b3e:	mov    QWORD PTR [rdi],rax
    2b41:	mov    r12,rdi
    2b44:	mov    QWORD PTR [rbx],0x0
    2b4b:	mov    QWORD PTR [rsp],rsi
    2b4f:	mov    r13,rsi
    2b52:	mov    QWORD PTR [rsp+0x8],rdx
    2b57:	mov    QWORD PTR [rsp+0x10],0x3
    2b60:	test   rdx,0x1
    2b67:	jne    2b75 <botlish_fn_39+0x66>
    2b6d:	mov    rcx,rdx
    2b70:	jmp    2b8a <botlish_fn_39+0x7b>
    2b75:	mov    rsi,rdx
    2b78:	add    rsi,0x2
    2b7c:	mov    rcx,rdx
    2b7f:	seto   al
    2b82:	test   al,al
    2b84:	je     2b9d <botlish_fn_39+0x8e>
    2b8a:	mov    edx,0x3
    2b8f:	mov    rsi,rcx
    2b92:	mov    rdi,r12
    2b95:	call   2b9a <botlish_fn_39+0x8b>
			2b96: R_X86_64_PLT32	rt_int_add-0x4
    2b9a:	mov    rsi,rax
    2b9d:	mov    QWORD PTR [rsp+0x8],rsi
    2ba2:	mov    rax,rsi
    2ba5:	mov    rsi,r13
    2ba8:	mov    r13,rax
    2bab:	mov    rdi,r12
    2bae:	call   2bb3 <botlish_fn_39+0xa4>
			2baf: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2bb3:	test   rax,rax
    2bb6:	mov    rdx,rax
    2bb9:	jne    2bc7 <botlish_fn_39+0xb8>
    2bbf:	mov    rdi,r12
    2bc2:	jmp    2bde <botlish_fn_39+0xcf>
    2bc7:	mov    rsi,r13
    2bca:	mov    rdi,r12
    2bcd:	call   2bd2 <botlish_fn_39+0xc3>
			2bce: R_X86_64_PLT32	rt_int_mod-0x4
    2bd2:	test   rax,rax
    2bd5:	jne    2bff <botlish_fn_39+0xf0>
    2bdb:	mov    rdi,r12
    2bde:	mov    rdi,r12
    2be1:	mov    QWORD PTR [rdi],rbx
    2be4:	xor    rax,rax
    2be7:	mov    rbx,QWORD PTR [rsp+0x20]
    2bec:	mov    r12,QWORD PTR [rsp+0x28]
    2bf1:	mov    r13,QWORD PTR [rsp+0x30]
    2bf6:	add    rsp,0x40
    2bfa:	mov    rsp,rbp
    2bfd:	pop    rbp
    2bfe:	ret
    2bff:	mov    rdi,r12
    2c02:	mov    QWORD PTR [rdi],rbx
    2c05:	mov    rbx,QWORD PTR [rsp+0x20]
    2c0a:	mov    r12,QWORD PTR [rsp+0x28]
    2c0f:	mov    r13,QWORD PTR [rsp+0x30]
    2c14:	add    rsp,0x40
    2c18:	mov    rsp,rbp
    2c1b:	pop    rbp
    2c1c:	ret
    2c1d:	mov    r12,rdi
    2c20:	call   2c25 <botlish_fn_39+0x116>
			2c21: R_X86_64_PLT32	rt_stack_overflow-0x4
    2c25:	xor    rax,rax
    2c28:	mov    rbx,QWORD PTR [rsp+0x20]
    2c2d:	mov    r12,QWORD PTR [rsp+0x28]
    2c32:	mov    r13,QWORD PTR [rsp+0x30]
    2c37:	add    rsp,0x40
    2c3b:	mov    rsp,rbp
    2c3e:	pop    rbp
    2c3f:	ret

0000000000002c40 <botlish_entry_39: ht_probe_next<any, int>>:
    2c40:	push   rbp
    2c41:	mov    rbp,rsp
    2c44:	mov    rsi,QWORD PTR [rdx]
    2c47:	mov    rdx,QWORD PTR [rdx+0x8]
    2c4b:	call   2c50 <botlish_entry_39+0x10>
			2c4c: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    2c50:	mov    rsp,rbp
    2c53:	pop    rbp
    2c54:	ret
    2c55:	add    BYTE PTR [rax],al
	...

0000000000002c58 <botlish_fn_40: ht_find_get<any, str, int>>:
    2c58:	push   rbp
    2c59:	mov    rbp,rsp
    2c5c:	sub    rsp,0x60
    2c60:	mov    QWORD PTR [rsp+0x30],rbx
    2c65:	mov    QWORD PTR [rsp+0x38],r12
    2c6a:	mov    QWORD PTR [rsp+0x40],r13
    2c6f:	mov    QWORD PTR [rsp+0x48],r14
    2c74:	mov    QWORD PTR [rsp+0x50],r15
    2c79:	mov    r14,QWORD PTR [rdi]
    2c7c:	mov    rax,QWORD PTR [rdi+0x8]
    2c80:	lea    r8,[r14+0x8]
    2c84:	cmp    r8,rax
    2c87:	ja     2fdd <botlish_fn_40+0x385>
    2c8d:	lea    rax,[r14+0x8]
    2c91:	mov    QWORD PTR [rdi],rax
    2c94:	mov    r15,rdi
    2c97:	mov    QWORD PTR [r14],0x0
    2c9e:	mov    QWORD PTR [rsp+0x18],0x0
    2ca7:	mov    QWORD PTR [rsp],rsi
    2cab:	mov    QWORD PTR [rsp+0x8],rdx
    2cb0:	mov    QWORD PTR [rsp+0x20],rdx
    2cb5:	mov    QWORD PTR [rsp+0x10],rcx
    2cba:	mov    rbx,rsi
    2cbd:	mov    QWORD PTR [rsp+0x28],rcx
    2cc2:	mov    rsi,rbx
    2cc5:	mov    rdi,r15
    2cc8:	call   2ccd <botlish_fn_40+0x75>
			2cc9: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2ccd:	test   rax,rax
    2cd0:	jne    2cde <botlish_fn_40+0x86>
    2cd6:	mov    rdi,r15
    2cd9:	jmp    2f39 <botlish_fn_40+0x2e1>
    2cde:	xor    ecx,ecx
    2ce0:	test   rax,0x7
    2ce6:	je     2cf4 <botlish_fn_40+0x9c>
    2cec:	mov    rsi,rax
    2cef:	jmp    2d02 <botlish_fn_40+0xaa>
    2cf4:	movzx  rcx,BYTE PTR [rax]
    2cf8:	mov    rsi,rax
    2cfb:	rex cmp cl,0x8
    2cff:	sete   cl
    2d02:	test   cl,cl
    2d04:	jne    2d27 <botlish_fn_40+0xcf>
    2d0a:	mov    rdi,r15
    2d0d:	mov    rax,QWORD PTR [rdi+0x10]
    2d11:	mov    rcx,QWORD PTR [rax+0x20]
    2d15:	mov    edx,0x8
    2d1a:	call   2d1f <botlish_fn_40+0xc7>
			2d1b: R_X86_64_PLT32	rt_type_error-0x4
    2d1f:	mov    rdi,r15
    2d22:	jmp    2f39 <botlish_fn_40+0x2e1>
    2d27:	mov    rdx,QWORD PTR [rsp+0x28]
    2d2c:	mov    rdi,r15
    2d2f:	call   2d34 <botlish_fn_40+0xdc>
			2d30: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d34:	mov    rcx,rax
    2d37:	mov    r13,rax
    2d3a:	test   rax,rcx
    2d3d:	jne    2d4b <botlish_fn_40+0xf3>
    2d43:	mov    rdi,r15
    2d46:	jmp    2f39 <botlish_fn_40+0x2e1>
    2d4b:	mov    rax,r13
    2d4e:	mov    QWORD PTR [rsp+0x18],rax
    2d53:	mov    rdi,r15
    2d56:	call   2d5b <botlish_fn_40+0x103>
			2d57: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    2d5b:	test   rax,rax
    2d5e:	jne    2d6c <botlish_fn_40+0x114>
    2d64:	mov    rdi,r15
    2d67:	jmp    2f39 <botlish_fn_40+0x2e1>
    2d6c:	mov    rsi,r13
    2d6f:	mov    rcx,rsi
    2d72:	and    rcx,rax
    2d75:	mov    rdx,rax
    2d78:	test   rcx,0x1
    2d7f:	jne    2da1 <botlish_fn_40+0x149>
    2d85:	mov    rsi,r13
    2d88:	mov    rdi,r15
    2d8b:	call   2d90 <botlish_fn_40+0x138>
			2d8c: R_X86_64_PLT32	rt_value_eq-0x4
    2d90:	test   rax,rax
    2d93:	jne    2db1 <botlish_fn_40+0x159>
    2d99:	mov    rdi,r15
    2d9c:	jmp    2f39 <botlish_fn_40+0x2e1>
    2da1:	mov    eax,0x2
    2da6:	cmp    r13,rdx
    2da9:	cmove  rax,QWORD PTR [rip+0x25f]        # 3010 <botlish_fn_40+0x3b8>
    2db1:	mov    r12d,0x6
    2db7:	cmp    rax,0x6
    2dbb:	je     2fae <botlish_fn_40+0x356>
    2dc1:	mov    rdi,r15
    2dc4:	call   2dc9 <botlish_fn_40+0x171>
			2dc5: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2dc9:	test   rax,rax
    2dcc:	jne    2dda <botlish_fn_40+0x182>
    2dd2:	mov    rdi,r15
    2dd5:	jmp    2f39 <botlish_fn_40+0x2e1>
    2dda:	mov    rcx,r13
    2ddd:	and    rcx,rax
    2de0:	mov    rdx,rax
    2de3:	test   rcx,0x1
    2dea:	jne    2e0c <botlish_fn_40+0x1b4>
    2df0:	mov    rsi,r13
    2df3:	mov    rdi,r15
    2df6:	call   2dfb <botlish_fn_40+0x1a3>
			2df7: R_X86_64_PLT32	rt_value_eq-0x4
    2dfb:	test   rax,rax
    2dfe:	jne    2e1f <botlish_fn_40+0x1c7>
    2e04:	mov    rdi,r15
    2e07:	jmp    2f39 <botlish_fn_40+0x2e1>
    2e0c:	mov    rsi,r13
    2e0f:	mov    eax,0x2
    2e14:	cmp    rsi,rdx
    2e17:	cmove  rax,QWORD PTR [rip+0x1f1]        # 3010 <botlish_fn_40+0x3b8>
    2e1f:	cmp    rax,0x6
    2e23:	je     2e39 <botlish_fn_40+0x1e1>
    2e29:	mov    r12d,0x2
    2e2f:	mov    r13,QWORD PTR [rsp+0x20]
    2e34:	jmp    2f13 <botlish_fn_40+0x2bb>
    2e39:	mov    rsi,rbx
    2e3c:	mov    rdi,r15
    2e3f:	call   2e44 <botlish_fn_40+0x1ec>
			2e40: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2e44:	test   rax,rax
    2e47:	jne    2e55 <botlish_fn_40+0x1fd>
    2e4d:	mov    rdi,r15
    2e50:	jmp    2f39 <botlish_fn_40+0x2e1>
    2e55:	xor    ecx,ecx
    2e57:	test   rax,0x7
    2e5d:	je     2e6b <botlish_fn_40+0x213>
    2e63:	mov    rsi,rax
    2e66:	jmp    2e79 <botlish_fn_40+0x221>
    2e6b:	movzx  rcx,BYTE PTR [rax]
    2e6f:	mov    rsi,rax
    2e72:	rex cmp cl,0x8
    2e76:	sete   cl
    2e79:	test   cl,cl
    2e7b:	jne    2e9e <botlish_fn_40+0x246>
    2e81:	mov    rdi,r15
    2e84:	mov    rax,QWORD PTR [rdi+0x10]
    2e88:	mov    rcx,QWORD PTR [rax+0x20]
    2e8c:	mov    edx,0x8
    2e91:	call   2e96 <botlish_fn_40+0x23e>
			2e92: R_X86_64_PLT32	rt_type_error-0x4
    2e96:	mov    rdi,r15
    2e99:	jmp    2f39 <botlish_fn_40+0x2e1>
    2e9e:	mov    rdx,QWORD PTR [rsp+0x28]
    2ea3:	mov    rdi,r15
    2ea6:	call   2eab <botlish_fn_40+0x253>
			2ea7: R_X86_64_PLT32	rt_mutarray_get-0x4
    2eab:	test   rax,rax
    2eae:	jne    2ebc <botlish_fn_40+0x264>
    2eb4:	mov    rdi,r15
    2eb7:	jmp    2f39 <botlish_fn_40+0x2e1>
    2ebc:	mov    r13,QWORD PTR [rsp+0x20]
    2ec1:	mov    rcx,rax
    2ec4:	and    rcx,r13
    2ec7:	mov    rsi,rax
    2eca:	test   rcx,0x1
    2ed1:	jne    2ef3 <botlish_fn_40+0x29b>
    2ed7:	mov    rdx,r13
    2eda:	mov    rdi,r15
    2edd:	call   2ee2 <botlish_fn_40+0x28a>
			2ede: R_X86_64_PLT32	rt_value_eq-0x4
    2ee2:	test   rax,rax
    2ee5:	jne    2f03 <botlish_fn_40+0x2ab>
    2eeb:	mov    rdi,r15
    2eee:	jmp    2f39 <botlish_fn_40+0x2e1>
    2ef3:	mov    eax,0x2
    2ef8:	cmp    rsi,r13
    2efb:	cmove  rax,QWORD PTR [rip+0x10d]        # 3010 <botlish_fn_40+0x3b8>
    2f03:	cmp    rax,0x6
    2f07:	je     2f13 <botlish_fn_40+0x2bb>
    2f0d:	mov    r12d,0x2
    2f13:	cmp    r12,0x6
    2f17:	je     2f81 <botlish_fn_40+0x329>
    2f1d:	mov    rdx,QWORD PTR [rsp+0x28]
    2f22:	mov    rsi,rbx
    2f25:	mov    rdi,r15
    2f28:	call   2f2d <botlish_fn_40+0x2d5>
			2f29: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    2f2d:	test   rax,rax
    2f30:	jne    2f64 <botlish_fn_40+0x30c>
    2f36:	mov    rdi,r15
    2f39:	mov    rdi,r15
    2f3c:	mov    QWORD PTR [rdi],r14
    2f3f:	xor    rax,rax
    2f42:	mov    rbx,QWORD PTR [rsp+0x30]
    2f47:	mov    r12,QWORD PTR [rsp+0x38]
    2f4c:	mov    r13,QWORD PTR [rsp+0x40]
    2f51:	mov    r14,QWORD PTR [rsp+0x48]
    2f56:	mov    r15,QWORD PTR [rsp+0x50]
    2f5b:	add    rsp,0x60
    2f5f:	mov    rsp,rbp
    2f62:	pop    rbp
    2f63:	ret
    2f64:	mov    QWORD PTR [rsp],rbx
    2f68:	mov    QWORD PTR [rsp+0x8],r13
    2f6d:	mov    QWORD PTR [rsp+0x10],rax
    2f72:	mov    QWORD PTR [rsp+0x20],r13
    2f77:	mov    QWORD PTR [rsp+0x28],rax
    2f7c:	jmp    2cc2 <botlish_fn_40+0x6a>
    2f81:	mov    rdi,r15
    2f84:	mov    QWORD PTR [rdi],r14
    2f87:	mov    rax,QWORD PTR [rsp+0x28]
    2f8c:	mov    rbx,QWORD PTR [rsp+0x30]
    2f91:	mov    r12,QWORD PTR [rsp+0x38]
    2f96:	mov    r13,QWORD PTR [rsp+0x40]
    2f9b:	mov    r14,QWORD PTR [rsp+0x48]
    2fa0:	mov    r15,QWORD PTR [rsp+0x50]
    2fa5:	add    rsp,0x60
    2fa9:	mov    rsp,rbp
    2fac:	pop    rbp
    2fad:	ret
    2fae:	mov    rdi,r15
    2fb1:	mov    QWORD PTR [rdi],r14
    2fb4:	mov    rax,0xffffffffffffffff
    2fbb:	mov    rbx,QWORD PTR [rsp+0x30]
    2fc0:	mov    r12,QWORD PTR [rsp+0x38]
    2fc5:	mov    r13,QWORD PTR [rsp+0x40]
    2fca:	mov    r14,QWORD PTR [rsp+0x48]
    2fcf:	mov    r15,QWORD PTR [rsp+0x50]
    2fd4:	add    rsp,0x60
    2fd8:	mov    rsp,rbp
    2fdb:	pop    rbp
    2fdc:	ret
    2fdd:	mov    r15,rdi
    2fe0:	call   2fe5 <botlish_fn_40+0x38d>
			2fe1: R_X86_64_PLT32	rt_stack_overflow-0x4
    2fe5:	xor    rax,rax
    2fe8:	mov    rbx,QWORD PTR [rsp+0x30]
    2fed:	mov    r12,QWORD PTR [rsp+0x38]
    2ff2:	mov    r13,QWORD PTR [rsp+0x40]
    2ff7:	mov    r14,QWORD PTR [rsp+0x48]
    2ffc:	mov    r15,QWORD PTR [rsp+0x50]
    3001:	add    rsp,0x60
    3005:	mov    rsp,rbp
    3008:	pop    rbp
    3009:	ret
    300a:	add    BYTE PTR [rax],al
    300c:	add    BYTE PTR [rax],al
    300e:	add    BYTE PTR [rax],al
    3010:	(bad)
    3011:	add    BYTE PTR [rax],al
    3013:	add    BYTE PTR [rax],al
    3015:	add    BYTE PTR [rax],al
	...

0000000000003018 <botlish_entry_40: ht_find_get<any, str, int>>:
    3018:	push   rbp
    3019:	mov    rbp,rsp
    301c:	mov    rsi,QWORD PTR [rdx]
    301f:	mov    r8,QWORD PTR [rdx+0x8]
    3023:	mov    rcx,QWORD PTR [rdx+0x10]
    3027:	mov    rdx,r8
    302a:	call   302f <botlish_entry_40+0x17>
			302b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    302f:	mov    rsp,rbp
    3032:	pop    rbp
    3033:	ret
    3034:	add    BYTE PTR [rax],al
	...

0000000000003038 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    3038:	push   rbp
    3039:	mov    rbp,rsp
    303c:	sub    rsp,0x70
    3040:	mov    QWORD PTR [rsp+0x40],rbx
    3045:	mov    QWORD PTR [rsp+0x48],r12
    304a:	mov    QWORD PTR [rsp+0x50],r13
    304f:	mov    QWORD PTR [rsp+0x58],r14
    3054:	mov    QWORD PTR [rsp+0x60],r15
    3059:	mov    rbx,QWORD PTR [rdi]
    305c:	mov    rax,QWORD PTR [rdi+0x8]
    3060:	lea    r9,[rbx+0x8]
    3064:	cmp    r9,rax
    3067:	ja     35d4 <botlish_fn_41+0x59c>
    306d:	lea    rax,[rbx+0x8]
    3071:	mov    QWORD PTR [rdi],rax
    3074:	mov    QWORD PTR [rsp+0x28],rdi
    3079:	mov    QWORD PTR [rbx],0x0
    3080:	mov    QWORD PTR [rsp+0x20],0x0
    3089:	mov    QWORD PTR [rsp],rsi
    308d:	mov    QWORD PTR [rsp+0x8],rdx
    3092:	mov    r14,rdx
    3095:	mov    QWORD PTR [rsp+0x10],rcx
    309a:	mov    QWORD PTR [rsp+0x18],r8
    309f:	mov    r12,rsi
    30a2:	mov    QWORD PTR [rsp+0x30],rcx
    30a7:	mov    QWORD PTR [rsp+0x38],r8
    30ac:	mov    rsi,r12
    30af:	mov    rdi,QWORD PTR [rsp+0x28]
    30b4:	call   30b9 <botlish_fn_41+0x81>
			30b5: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    30b9:	test   rax,rax
    30bc:	jne    30cc <botlish_fn_41+0x94>
    30c2:	mov    rdi,QWORD PTR [rsp+0x28]
    30c7:	jmp    3490 <botlish_fn_41+0x458>
    30cc:	xor    ecx,ecx
    30ce:	test   rax,0x7
    30d4:	je     30e2 <botlish_fn_41+0xaa>
    30da:	mov    rsi,rax
    30dd:	jmp    30f0 <botlish_fn_41+0xb8>
    30e2:	movzx  rcx,BYTE PTR [rax]
    30e6:	mov    rsi,rax
    30e9:	rex cmp cl,0x8
    30ed:	sete   cl
    30f0:	test   cl,cl
    30f2:	jne    3119 <botlish_fn_41+0xe1>
    30f8:	mov    rdi,QWORD PTR [rsp+0x28]
    30fd:	mov    rax,QWORD PTR [rdi+0x10]
    3101:	mov    rcx,QWORD PTR [rax+0x20]
    3105:	mov    edx,0x8
    310a:	call   310f <botlish_fn_41+0xd7>
			310b: R_X86_64_PLT32	rt_type_error-0x4
    310f:	mov    rdi,QWORD PTR [rsp+0x28]
    3114:	jmp    3490 <botlish_fn_41+0x458>
    3119:	mov    rdx,QWORD PTR [rsp+0x30]
    311e:	mov    rdi,QWORD PTR [rsp+0x28]
    3123:	call   3128 <botlish_fn_41+0xf0>
			3124: R_X86_64_PLT32	rt_mutarray_get-0x4
    3128:	mov    rcx,rax
    312b:	mov    r15,rax
    312e:	test   rax,rcx
    3131:	jne    3141 <botlish_fn_41+0x109>
    3137:	mov    rdi,QWORD PTR [rsp+0x28]
    313c:	jmp    3490 <botlish_fn_41+0x458>
    3141:	mov    rax,r15
    3144:	mov    QWORD PTR [rsp+0x20],rax
    3149:	mov    rdi,QWORD PTR [rsp+0x28]
    314e:	call   3153 <botlish_fn_41+0x11b>
			314f: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    3153:	test   rax,rax
    3156:	jne    3166 <botlish_fn_41+0x12e>
    315c:	mov    rdi,QWORD PTR [rsp+0x28]
    3161:	jmp    3490 <botlish_fn_41+0x458>
    3166:	mov    rcx,r15
    3169:	and    rcx,rax
    316c:	mov    rdx,rax
    316f:	test   rcx,0x1
    3176:	jne    319c <botlish_fn_41+0x164>
    317c:	mov    rsi,r15
    317f:	mov    rdi,QWORD PTR [rsp+0x28]
    3184:	call   3189 <botlish_fn_41+0x151>
			3185: R_X86_64_PLT32	rt_value_eq-0x4
    3189:	test   rax,rax
    318c:	jne    31af <botlish_fn_41+0x177>
    3192:	mov    rdi,QWORD PTR [rsp+0x28]
    3197:	jmp    3490 <botlish_fn_41+0x458>
    319c:	mov    eax,0x2
    31a1:	mov    rcx,r15
    31a4:	cmp    rcx,rdx
    31a7:	cmove  rax,QWORD PTR [rip+0x459]        # 3608 <botlish_fn_41+0x5d0>
    31af:	mov    r13d,0x6
    31b5:	cmp    rax,0x6
    31b9:	je     3518 <botlish_fn_41+0x4e0>
    31bf:	mov    rdi,QWORD PTR [rsp+0x28]
    31c4:	call   31c9 <botlish_fn_41+0x191>
			31c5: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    31c9:	test   rax,rax
    31cc:	jne    31dc <botlish_fn_41+0x1a4>
    31d2:	mov    rdi,QWORD PTR [rsp+0x28]
    31d7:	jmp    3490 <botlish_fn_41+0x458>
    31dc:	mov    rcx,r15
    31df:	mov    rdx,rcx
    31e2:	and    rdx,rax
    31e5:	mov    rdi,rax
    31e8:	test   rdx,0x1
    31ef:	jne    3218 <botlish_fn_41+0x1e0>
    31f5:	mov    rdx,rdi
    31f8:	mov    rsi,r15
    31fb:	mov    rdi,QWORD PTR [rsp+0x28]
    3200:	call   3205 <botlish_fn_41+0x1cd>
			3201: R_X86_64_PLT32	rt_value_eq-0x4
    3205:	test   rax,rax
    3208:	jne    322e <botlish_fn_41+0x1f6>
    320e:	mov    rdi,QWORD PTR [rsp+0x28]
    3213:	jmp    3490 <botlish_fn_41+0x458>
    3218:	mov    rdx,rdi
    321b:	mov    eax,0x2
    3220:	mov    rdi,r15
    3223:	cmp    rdi,rdx
    3226:	cmove  rax,QWORD PTR [rip+0x3da]        # 3608 <botlish_fn_41+0x5d0>
    322e:	cmp    rax,0x6
    3232:	je     3242 <botlish_fn_41+0x20a>
    3238:	mov    eax,0x2
    323d:	jmp    332e <botlish_fn_41+0x2f6>
    3242:	mov    rsi,r12
    3245:	mov    rdi,QWORD PTR [rsp+0x28]
    324a:	call   324f <botlish_fn_41+0x217>
			324b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    324f:	test   rax,rax
    3252:	jne    3262 <botlish_fn_41+0x22a>
    3258:	mov    rdi,QWORD PTR [rsp+0x28]
    325d:	jmp    3490 <botlish_fn_41+0x458>
    3262:	xor    ecx,ecx
    3264:	test   rax,0x7
    326a:	je     3278 <botlish_fn_41+0x240>
    3270:	mov    rsi,rax
    3273:	jmp    3286 <botlish_fn_41+0x24e>
    3278:	movzx  rcx,BYTE PTR [rax]
    327c:	mov    rsi,rax
    327f:	rex cmp cl,0x8
    3283:	sete   cl
    3286:	test   cl,cl
    3288:	jne    32af <botlish_fn_41+0x277>
    328e:	mov    rdi,QWORD PTR [rsp+0x28]
    3293:	mov    rax,QWORD PTR [rdi+0x10]
    3297:	mov    rcx,QWORD PTR [rax+0x20]
    329b:	mov    edx,0x8
    32a0:	call   32a5 <botlish_fn_41+0x26d>
			32a1: R_X86_64_PLT32	rt_type_error-0x4
    32a5:	mov    rdi,QWORD PTR [rsp+0x28]
    32aa:	jmp    3490 <botlish_fn_41+0x458>
    32af:	mov    rdx,QWORD PTR [rsp+0x30]
    32b4:	mov    rdi,QWORD PTR [rsp+0x28]
    32b9:	call   32be <botlish_fn_41+0x286>
			32ba: R_X86_64_PLT32	rt_mutarray_get-0x4
    32be:	test   rax,rax
    32c1:	jne    32d1 <botlish_fn_41+0x299>
    32c7:	mov    rdi,QWORD PTR [rsp+0x28]
    32cc:	jmp    3490 <botlish_fn_41+0x458>
    32d1:	mov    rcx,rax
    32d4:	and    rcx,r14
    32d7:	mov    rsi,rax
    32da:	test   rcx,0x1
    32e1:	jne    3307 <botlish_fn_41+0x2cf>
    32e7:	mov    rdx,r14
    32ea:	mov    rdi,QWORD PTR [rsp+0x28]
    32ef:	call   32f4 <botlish_fn_41+0x2bc>
			32f0: R_X86_64_PLT32	rt_value_eq-0x4
    32f4:	test   rax,rax
    32f7:	jne    3317 <botlish_fn_41+0x2df>
    32fd:	mov    rdi,QWORD PTR [rsp+0x28]
    3302:	jmp    3490 <botlish_fn_41+0x458>
    3307:	mov    eax,0x2
    330c:	cmp    rsi,r14
    330f:	cmove  rax,QWORD PTR [rip+0x2f1]        # 3608 <botlish_fn_41+0x5d0>
    3317:	cmp    rax,0x6
    331b:	je     332b <botlish_fn_41+0x2f3>
    3321:	mov    eax,0x2
    3326:	jmp    332e <botlish_fn_41+0x2f6>
    332b:	mov    rax,r13
    332e:	cmp    rax,0x6
    3332:	je     34e9 <botlish_fn_41+0x4b1>
    3338:	mov    rdi,QWORD PTR [rsp+0x28]
    333d:	call   3342 <botlish_fn_41+0x30a>
			333e: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3342:	test   rax,rax
    3345:	jne    3355 <botlish_fn_41+0x31d>
    334b:	mov    rdi,QWORD PTR [rsp+0x28]
    3350:	jmp    3490 <botlish_fn_41+0x458>
    3355:	mov    rcx,r15
    3358:	mov    rdx,rcx
    335b:	and    rdx,rax
    335e:	mov    r11,rax
    3361:	test   rdx,0x1
    3368:	jne    3391 <botlish_fn_41+0x359>
    336e:	mov    rdx,r11
    3371:	mov    rsi,r15
    3374:	mov    rdi,QWORD PTR [rsp+0x28]
    3379:	call   337e <botlish_fn_41+0x346>
			337a: R_X86_64_PLT32	rt_value_eq-0x4
    337e:	test   rax,rax
    3381:	jne    33a7 <botlish_fn_41+0x36f>
    3387:	mov    rdi,QWORD PTR [rsp+0x28]
    338c:	jmp    3490 <botlish_fn_41+0x458>
    3391:	mov    rdx,r11
    3394:	mov    rsi,r15
    3397:	mov    eax,0x2
    339c:	cmp    rsi,rdx
    339f:	cmove  rax,QWORD PTR [rip+0x261]        # 3608 <botlish_fn_41+0x5d0>
    33a7:	cmp    rax,0x6
    33ab:	je     33bc <botlish_fn_41+0x384>
    33b1:	mov    r13d,0x2
    33b7:	jmp    341f <botlish_fn_41+0x3e7>
    33bc:	mov    r15,QWORD PTR [rsp+0x38]
    33c1:	test   r15,0x1
    33c8:	jne    33fa <botlish_fn_41+0x3c2>
    33ce:	mov    edx,0x1
    33d3:	mov    rsi,r15
    33d6:	mov    rdi,QWORD PTR [rsp+0x28]
    33db:	call   33e0 <botlish_fn_41+0x3a8>
			33dc: R_X86_64_PLT32	rt_int_cmp-0x4
    33e0:	mov    ecx,0x2
    33e5:	test   rax,rax
    33e8:	cmovl  rcx,QWORD PTR [rip+0x218]        # 3608 <botlish_fn_41+0x5d0>
    33f0:	mov    QWORD PTR [rsp+0x38],r15
    33f5:	jmp    340f <botlish_fn_41+0x3d7>
    33fa:	mov    ecx,0x2
    33ff:	test   r15,r15
    3402:	mov    QWORD PTR [rsp+0x38],r15
    3407:	cmovle rcx,QWORD PTR [rip+0x1f9]        # 3608 <botlish_fn_41+0x5d0>
    340f:	cmp    rcx,0x6
    3413:	je     341f <botlish_fn_41+0x3e7>
    3419:	mov    r13d,0x2
    341f:	cmp    r13,0x6
    3423:	je     3470 <botlish_fn_41+0x438>
    3429:	mov    rdx,QWORD PTR [rsp+0x30]
    342e:	mov    rsi,r12
    3431:	mov    rdi,QWORD PTR [rsp+0x28]
    3436:	call   343b <botlish_fn_41+0x403>
			3437: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    343b:	test   rax,rax
    343e:	jne    344e <botlish_fn_41+0x416>
    3444:	mov    rdi,QWORD PTR [rsp+0x28]
    3449:	jmp    3490 <botlish_fn_41+0x458>
    344e:	mov    QWORD PTR [rsp],r12
    3452:	mov    QWORD PTR [rsp+0x8],r14
    3457:	mov    QWORD PTR [rsp+0x10],rax
    345c:	mov    rcx,QWORD PTR [rsp+0x38]
    3461:	mov    QWORD PTR [rsp+0x18],rcx
    3466:	mov    QWORD PTR [rsp+0x30],rax
    346b:	jmp    30ac <botlish_fn_41+0x74>
    3470:	mov    rdx,QWORD PTR [rsp+0x30]
    3475:	mov    rsi,r12
    3478:	mov    rdi,QWORD PTR [rsp+0x28]
    347d:	call   3482 <botlish_fn_41+0x44a>
			347e: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    3482:	test   rax,rax
    3485:	jne    34bd <botlish_fn_41+0x485>
    348b:	mov    rdi,QWORD PTR [rsp+0x28]
    3490:	mov    rdi,QWORD PTR [rsp+0x28]
    3495:	mov    QWORD PTR [rdi],rbx
    3498:	xor    rax,rax
    349b:	mov    rbx,QWORD PTR [rsp+0x40]
    34a0:	mov    r12,QWORD PTR [rsp+0x48]
    34a5:	mov    r13,QWORD PTR [rsp+0x50]
    34aa:	mov    r14,QWORD PTR [rsp+0x58]
    34af:	mov    r15,QWORD PTR [rsp+0x60]
    34b4:	add    rsp,0x70
    34b8:	mov    rsp,rbp
    34bb:	pop    rbp
    34bc:	ret
    34bd:	mov    QWORD PTR [rsp],r12
    34c1:	mov    QWORD PTR [rsp+0x8],r14
    34c6:	mov    QWORD PTR [rsp+0x10],rax
    34cb:	mov    rdx,QWORD PTR [rsp+0x30]
    34d0:	mov    QWORD PTR [rsp+0x18],rdx
    34d5:	mov    rcx,QWORD PTR [rsp+0x30]
    34da:	mov    QWORD PTR [rsp+0x38],rcx
    34df:	mov    QWORD PTR [rsp+0x30],rax
    34e4:	jmp    30ac <botlish_fn_41+0x74>
    34e9:	mov    rdi,QWORD PTR [rsp+0x28]
    34ee:	mov    QWORD PTR [rdi],rbx
    34f1:	mov    rax,QWORD PTR [rsp+0x30]
    34f6:	mov    rbx,QWORD PTR [rsp+0x40]
    34fb:	mov    r12,QWORD PTR [rsp+0x48]
    3500:	mov    r13,QWORD PTR [rsp+0x50]
    3505:	mov    r14,QWORD PTR [rsp+0x58]
    350a:	mov    r15,QWORD PTR [rsp+0x60]
    350f:	add    rsp,0x70
    3513:	mov    rsp,rbp
    3516:	pop    rbp
    3517:	ret
    3518:	mov    rax,QWORD PTR [rsp+0x38]
    351d:	test   rax,0x1
    3523:	jne    3552 <botlish_fn_41+0x51a>
    3529:	mov    edx,0x1
    352e:	mov    rsi,QWORD PTR [rsp+0x38]
    3533:	mov    rdi,QWORD PTR [rsp+0x28]
    3538:	call   353d <botlish_fn_41+0x505>
			3539: R_X86_64_PLT32	rt_int_cmp-0x4
    353d:	mov    ecx,0x2
    3542:	test   rax,rax
    3545:	cmovge rcx,QWORD PTR [rip+0xbb]        # 3608 <botlish_fn_41+0x5d0>
    354d:	jmp    356c <botlish_fn_41+0x534>
    3552:	mov    ecx,0x2
    3557:	mov    rax,QWORD PTR [rsp+0x38]
    355c:	mov    r11,QWORD PTR [rsp+0x38]
    3561:	test   rax,r11
    3564:	cmovg  rcx,QWORD PTR [rip+0x9c]        # 3608 <botlish_fn_41+0x5d0>
    356c:	cmp    rcx,0x6
    3570:	je     35a5 <botlish_fn_41+0x56d>
    3576:	mov    rdi,QWORD PTR [rsp+0x28]
    357b:	mov    QWORD PTR [rdi],rbx
    357e:	mov    rax,QWORD PTR [rsp+0x30]
    3583:	mov    rbx,QWORD PTR [rsp+0x40]
    3588:	mov    r12,QWORD PTR [rsp+0x48]
    358d:	mov    r13,QWORD PTR [rsp+0x50]
    3592:	mov    r14,QWORD PTR [rsp+0x58]
    3597:	mov    r15,QWORD PTR [rsp+0x60]
    359c:	add    rsp,0x70
    35a0:	mov    rsp,rbp
    35a3:	pop    rbp
    35a4:	ret
    35a5:	mov    rdi,QWORD PTR [rsp+0x28]
    35aa:	mov    QWORD PTR [rdi],rbx
    35ad:	mov    rax,QWORD PTR [rsp+0x38]
    35b2:	mov    rbx,QWORD PTR [rsp+0x40]
    35b7:	mov    r12,QWORD PTR [rsp+0x48]
    35bc:	mov    r13,QWORD PTR [rsp+0x50]
    35c1:	mov    r14,QWORD PTR [rsp+0x58]
    35c6:	mov    r15,QWORD PTR [rsp+0x60]
    35cb:	add    rsp,0x70
    35cf:	mov    rsp,rbp
    35d2:	pop    rbp
    35d3:	ret
    35d4:	mov    QWORD PTR [rsp+0x28],rdi
    35d9:	call   35de <botlish_fn_41+0x5a6>
			35da: R_X86_64_PLT32	rt_stack_overflow-0x4
    35de:	xor    rax,rax
    35e1:	mov    rbx,QWORD PTR [rsp+0x40]
    35e6:	mov    r12,QWORD PTR [rsp+0x48]
    35eb:	mov    r13,QWORD PTR [rsp+0x50]
    35f0:	mov    r14,QWORD PTR [rsp+0x58]
    35f5:	mov    r15,QWORD PTR [rsp+0x60]
    35fa:	add    rsp,0x70
    35fe:	mov    rsp,rbp
    3601:	pop    rbp
    3602:	ret
    3603:	add    BYTE PTR [rax],al
    3605:	add    BYTE PTR [rax],al
    3607:	add    BYTE PTR [rsi],al
    3609:	add    BYTE PTR [rax],al
    360b:	add    BYTE PTR [rax],al
    360d:	add    BYTE PTR [rax],al
	...

0000000000003610 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    3610:	push   rbp
    3611:	mov    rbp,rsp
    3614:	mov    rsi,QWORD PTR [rdx]
    3617:	mov    r9,QWORD PTR [rdx+0x8]
    361b:	mov    rcx,QWORD PTR [rdx+0x10]
    361f:	mov    r8,QWORD PTR [rdx+0x18]
    3623:	mov    rdx,r9
    3626:	call   362b <botlish_entry_41+0x1b>
			3627: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    362b:	mov    rsp,rbp
    362e:	pop    rbp
    362f:	ret

0000000000003630 <botlish_fn_42: ht_get<any, str>>:
    3630:	push   rbp
    3631:	mov    rbp,rsp
    3634:	sub    rsp,0x40
    3638:	mov    QWORD PTR [rsp+0x20],rbx
    363d:	mov    QWORD PTR [rsp+0x28],r12
    3642:	mov    QWORD PTR [rsp+0x30],r13
    3647:	mov    QWORD PTR [rsp+0x38],r14
    364c:	mov    rbx,QWORD PTR [rdi]
    364f:	mov    rax,QWORD PTR [rdi+0x8]
    3653:	lea    rcx,[rbx+0x8]
    3657:	cmp    rcx,rax
    365a:	ja     3813 <botlish_fn_42+0x1e3>
    3660:	lea    rax,[rbx+0x8]
    3664:	mov    QWORD PTR [rdi],rax
    3667:	mov    r12,rdi
    366a:	mov    QWORD PTR [rbx],0x0
    3671:	mov    QWORD PTR [rsp+0x10],0x0
    367a:	mov    QWORD PTR [rsp],rsi
    367e:	mov    r13,rsi
    3681:	mov    QWORD PTR [rsp+0x8],rdx
    3686:	mov    r14,rdx
    3689:	mov    rdx,r14
    368c:	mov    rsi,r13
    368f:	mov    rdi,r12
    3692:	call   3697 <botlish_fn_42+0x67>
			3693: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    3697:	test   rax,rax
    369a:	jne    36a8 <botlish_fn_42+0x78>
    36a0:	mov    rdi,r12
    36a3:	jmp    37a2 <botlish_fn_42+0x172>
    36a8:	mov    QWORD PTR [rsp+0x10],rax
    36ad:	mov    rcx,rax
    36b0:	mov    rdx,r14
    36b3:	mov    rsi,r13
    36b6:	mov    rdi,r12
    36b9:	call   36be <botlish_fn_42+0x8e>
			36ba: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    36be:	mov    r11,rax
    36c1:	mov    r14,rax
    36c4:	test   rax,r11
    36c7:	jne    36d5 <botlish_fn_42+0xa5>
    36cd:	mov    rdi,r12
    36d0:	jmp    37a2 <botlish_fn_42+0x172>
    36d5:	mov    rax,r14
    36d8:	mov    QWORD PTR [rsp+0x8],rax
    36dd:	test   rax,0x1
    36e3:	jne    370e <botlish_fn_42+0xde>
    36e9:	mov    edx,0x1
    36ee:	mov    rsi,r14
    36f1:	mov    rdi,r12
    36f4:	call   36f9 <botlish_fn_42+0xc9>
			36f5: R_X86_64_PLT32	rt_int_cmp-0x4
    36f9:	mov    ecx,0x2
    36fe:	test   rax,rax
    3701:	cmovl  rcx,QWORD PTR [rip+0x137]        # 3840 <botlish_fn_42+0x210>
    3709:	jmp    3721 <botlish_fn_42+0xf1>
    370e:	mov    ecx,0x2
    3713:	mov    rax,r14
    3716:	test   rax,rax
    3719:	cmovle rcx,QWORD PTR [rip+0x11f]        # 3840 <botlish_fn_42+0x210>
    3721:	cmp    rcx,0x6
    3725:	je     37eb <botlish_fn_42+0x1bb>
    372b:	mov    rsi,r13
    372e:	mov    rdi,r12
    3731:	call   3736 <botlish_fn_42+0x106>
			3732: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    3736:	test   rax,rax
    3739:	jne    3747 <botlish_fn_42+0x117>
    373f:	mov    rdi,r12
    3742:	jmp    37a2 <botlish_fn_42+0x172>
    3747:	xor    ecx,ecx
    3749:	test   rax,0x7
    374f:	jne    3760 <botlish_fn_42+0x130>
    3755:	movzx  rcx,BYTE PTR [rax]
    3759:	rex cmp cl,0x8
    375d:	sete   cl
    3760:	test   cl,cl
    3762:	jne    3788 <botlish_fn_42+0x158>
    3768:	mov    rdi,r12
    376b:	mov    rsi,QWORD PTR [rdi+0x10]
    376f:	mov    rcx,QWORD PTR [rsi+0x20]
    3773:	mov    edx,0x8
    3778:	mov    rsi,rax
    377b:	call   3780 <botlish_fn_42+0x150>
			377c: R_X86_64_PLT32	rt_type_error-0x4
    3780:	mov    rdi,r12
    3783:	jmp    37a2 <botlish_fn_42+0x172>
    3788:	mov    rdx,r14
    378b:	mov    rsi,rax
    378e:	mov    rdi,r12
    3791:	call   3796 <botlish_fn_42+0x166>
			3792: R_X86_64_PLT32	rt_mutarray_get-0x4
    3796:	test   rax,rax
    3799:	jne    37c8 <botlish_fn_42+0x198>
    379f:	mov    rdi,r12
    37a2:	mov    rdi,r12
    37a5:	mov    QWORD PTR [rdi],rbx
    37a8:	xor    rax,rax
    37ab:	mov    rbx,QWORD PTR [rsp+0x20]
    37b0:	mov    r12,QWORD PTR [rsp+0x28]
    37b5:	mov    r13,QWORD PTR [rsp+0x30]
    37ba:	mov    r14,QWORD PTR [rsp+0x38]
    37bf:	add    rsp,0x40
    37c3:	mov    rsp,rbp
    37c6:	pop    rbp
    37c7:	ret
    37c8:	mov    rdi,r12
    37cb:	mov    QWORD PTR [rdi],rbx
    37ce:	mov    rbx,QWORD PTR [rsp+0x20]
    37d3:	mov    r12,QWORD PTR [rsp+0x28]
    37d8:	mov    r13,QWORD PTR [rsp+0x30]
    37dd:	mov    r14,QWORD PTR [rsp+0x38]
    37e2:	add    rsp,0x40
    37e6:	mov    rsp,rbp
    37e9:	pop    rbp
    37ea:	ret
    37eb:	mov    rdi,r12
    37ee:	mov    QWORD PTR [rdi],rbx
    37f1:	mov    eax,0xa
    37f6:	mov    rbx,QWORD PTR [rsp+0x20]
    37fb:	mov    r12,QWORD PTR [rsp+0x28]
    3800:	mov    r13,QWORD PTR [rsp+0x30]
    3805:	mov    r14,QWORD PTR [rsp+0x38]
    380a:	add    rsp,0x40
    380e:	mov    rsp,rbp
    3811:	pop    rbp
    3812:	ret
    3813:	mov    r12,rdi
    3816:	call   381b <botlish_fn_42+0x1eb>
			3817: R_X86_64_PLT32	rt_stack_overflow-0x4
    381b:	xor    rax,rax
    381e:	mov    rbx,QWORD PTR [rsp+0x20]
    3823:	mov    r12,QWORD PTR [rsp+0x28]
    3828:	mov    r13,QWORD PTR [rsp+0x30]
    382d:	mov    r14,QWORD PTR [rsp+0x38]
    3832:	add    rsp,0x40
    3836:	mov    rsp,rbp
    3839:	pop    rbp
    383a:	ret
    383b:	add    BYTE PTR [rax],al
    383d:	add    BYTE PTR [rax],al
    383f:	add    BYTE PTR [rsi],al
    3841:	add    BYTE PTR [rax],al
    3843:	add    BYTE PTR [rax],al
    3845:	add    BYTE PTR [rax],al
	...

0000000000003848 <botlish_entry_42: ht_get<any, str>>:
    3848:	push   rbp
    3849:	mov    rbp,rsp
    384c:	mov    rsi,QWORD PTR [rdx]
    384f:	mov    rdx,QWORD PTR [rdx+0x8]
    3853:	call   3858 <botlish_entry_42+0x10>
			3854: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    3858:	mov    rsp,rbp
    385b:	pop    rbp
    385c:	ret
    385d:	add    BYTE PTR [rax],al
	...

0000000000003860 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    3860:	push   rbp
    3861:	mov    rbp,rsp
    3864:	sub    rsp,0x60
    3868:	mov    QWORD PTR [rsp+0x30],rbx
    386d:	mov    QWORD PTR [rsp+0x38],r12
    3872:	mov    QWORD PTR [rsp+0x40],r13
    3877:	mov    QWORD PTR [rsp+0x48],r14
    387c:	mov    QWORD PTR [rsp+0x50],r15
    3881:	mov    r12,QWORD PTR [rdi]
    3884:	mov    rax,QWORD PTR [rdi+0x8]
    3888:	lea    r8,[r12+0x8]
    388d:	cmp    r8,rax
    3890:	ja     3a1b <botlish_fn_43+0x1bb>
    3896:	lea    rax,[r12+0x8]
    389b:	mov    QWORD PTR [rdi],rax
    389e:	mov    r14,rdi
    38a1:	mov    QWORD PTR [r12],0x0
    38a9:	mov    QWORD PTR [rsp],rsi
    38ad:	mov    QWORD PTR [rsp+0x8],rdx
    38b2:	mov    QWORD PTR [rsp+0x10],rcx
    38b7:	mov    r13,rcx
    38ba:	mov    rbx,rsi
    38bd:	mov    r15,rdx
    38c0:	mov    rdx,r15
    38c3:	mov    rsi,rbx
    38c6:	mov    rdi,r14
    38c9:	call   38ce <botlish_fn_43+0x6e>
			38ca: R_X86_64_PLT32	rt_mutarray_get-0x4
    38ce:	test   rax,rax
    38d1:	jne    38df <botlish_fn_43+0x7f>
    38d7:	mov    rdi,r14
    38da:	jmp    39af <botlish_fn_43+0x14f>
    38df:	mov    QWORD PTR [rsp+0x18],rax
    38e4:	mov    QWORD PTR [rsp+0x20],rax
    38e9:	mov    rdi,r14
    38ec:	call   38f1 <botlish_fn_43+0x91>
			38ed: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    38f1:	test   rax,rax
    38f4:	jne    3902 <botlish_fn_43+0xa2>
    38fa:	mov    rdi,r14
    38fd:	jmp    39af <botlish_fn_43+0x14f>
    3902:	mov    rsi,QWORD PTR [rsp+0x20]
    3907:	mov    rcx,rsi
    390a:	and    rcx,rax
    390d:	mov    rdx,rax
    3910:	test   rcx,0x1
    3917:	jne    393b <botlish_fn_43+0xdb>
    391d:	mov    rsi,QWORD PTR [rsp+0x20]
    3922:	mov    rdi,r14
    3925:	call   392a <botlish_fn_43+0xca>
			3926: R_X86_64_PLT32	rt_value_eq-0x4
    392a:	test   rax,rax
    392d:	jne    3950 <botlish_fn_43+0xf0>
    3933:	mov    rdi,r14
    3936:	jmp    39af <botlish_fn_43+0x14f>
    393b:	mov    rsi,QWORD PTR [rsp+0x20]
    3940:	mov    eax,0x2
    3945:	cmp    rsi,rdx
    3948:	cmove  rax,QWORD PTR [rip+0xf8]        # 3a48 <botlish_fn_43+0x1e8>
    3950:	cmp    rax,0x6
    3954:	je     39f0 <botlish_fn_43+0x190>
    395a:	mov    QWORD PTR [rsp+0x18],0x3
    3963:	mov    rsi,r15
    3966:	test   rsi,0x1
    396d:	je     3985 <botlish_fn_43+0x125>
    3973:	mov    rsi,r15
    3976:	add    rsi,0x2
    397a:	seto   al
    397d:	test   al,al
    397f:	je     3998 <botlish_fn_43+0x138>
    3985:	mov    edx,0x3
    398a:	mov    rsi,r15
    398d:	mov    rdi,r14
    3990:	call   3995 <botlish_fn_43+0x135>
			3991: R_X86_64_PLT32	rt_int_add-0x4
    3995:	mov    rsi,rax
    3998:	mov    rdx,r13
    399b:	mov    rdi,r14
    399e:	call   39a3 <botlish_fn_43+0x143>
			399f: R_X86_64_PLT32	rt_int_mod-0x4
    39a3:	test   rax,rax
    39a6:	jne    39da <botlish_fn_43+0x17a>
    39ac:	mov    rdi,r14
    39af:	mov    rdi,r14
    39b2:	mov    QWORD PTR [rdi],r12
    39b5:	xor    rax,rax
    39b8:	mov    rbx,QWORD PTR [rsp+0x30]
    39bd:	mov    r12,QWORD PTR [rsp+0x38]
    39c2:	mov    r13,QWORD PTR [rsp+0x40]
    39c7:	mov    r14,QWORD PTR [rsp+0x48]
    39cc:	mov    r15,QWORD PTR [rsp+0x50]
    39d1:	add    rsp,0x60
    39d5:	mov    rsp,rbp
    39d8:	pop    rbp
    39d9:	ret
    39da:	mov    QWORD PTR [rsp],rbx
    39de:	mov    QWORD PTR [rsp+0x8],rax
    39e3:	mov    QWORD PTR [rsp+0x10],r13
    39e8:	mov    r15,rax
    39eb:	jmp    38c0 <botlish_fn_43+0x60>
    39f0:	mov    rdi,r14
    39f3:	mov    QWORD PTR [rdi],r12
    39f6:	mov    rax,r15
    39f9:	mov    rbx,QWORD PTR [rsp+0x30]
    39fe:	mov    r12,QWORD PTR [rsp+0x38]
    3a03:	mov    r13,QWORD PTR [rsp+0x40]
    3a08:	mov    r14,QWORD PTR [rsp+0x48]
    3a0d:	mov    r15,QWORD PTR [rsp+0x50]
    3a12:	add    rsp,0x60
    3a16:	mov    rsp,rbp
    3a19:	pop    rbp
    3a1a:	ret
    3a1b:	mov    r14,rdi
    3a1e:	call   3a23 <botlish_fn_43+0x1c3>
			3a1f: R_X86_64_PLT32	rt_stack_overflow-0x4
    3a23:	xor    rax,rax
    3a26:	mov    rbx,QWORD PTR [rsp+0x30]
    3a2b:	mov    r12,QWORD PTR [rsp+0x38]
    3a30:	mov    r13,QWORD PTR [rsp+0x40]
    3a35:	mov    r14,QWORD PTR [rsp+0x48]
    3a3a:	mov    r15,QWORD PTR [rsp+0x50]
    3a3f:	add    rsp,0x60
    3a43:	mov    rsp,rbp
    3a46:	pop    rbp
    3a47:	ret
    3a48:	(bad)
    3a49:	add    BYTE PTR [rax],al
    3a4b:	add    BYTE PTR [rax],al
    3a4d:	add    BYTE PTR [rax],al
	...

0000000000003a50 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    3a50:	push   rbp
    3a51:	mov    rbp,rsp
    3a54:	mov    rsi,QWORD PTR [rdx]
    3a57:	mov    r8,QWORD PTR [rdx+0x8]
    3a5b:	mov    rcx,QWORD PTR [rdx+0x10]
    3a5f:	mov    rdx,r8
    3a62:	call   3a67 <botlish_entry_43+0x17>
			3a63: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    3a67:	mov    rsp,rbp
    3a6a:	pop    rbp
    3a6b:	ret

0000000000003a6c <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    3a6c:	push   rbp
    3a6d:	mov    rbp,rsp
    3a70:	sub    rsp,0x80
    3a77:	mov    QWORD PTR [rsp+0x50],rbx
    3a7c:	mov    QWORD PTR [rsp+0x58],r12
    3a81:	mov    QWORD PTR [rsp+0x60],r13
    3a86:	mov    QWORD PTR [rsp+0x68],r14
    3a8b:	mov    QWORD PTR [rsp+0x70],r15
    3a90:	mov    r10,QWORD PTR [rbp+0x10]
    3a94:	mov    rbx,QWORD PTR [rdi]
    3a97:	mov    rax,QWORD PTR [rdi+0x8]
    3a9b:	lea    r11,[rbx+0x8]
    3a9f:	cmp    r11,rax
    3aa2:	ja     3c42 <botlish_fn_44+0x1d6>
    3aa8:	lea    rax,[rbx+0x8]
    3aac:	mov    QWORD PTR [rdi],rax
    3aaf:	mov    r12,rdi
    3ab2:	mov    QWORD PTR [rbx],0x0
    3ab9:	mov    QWORD PTR [rsp],rsi
    3abd:	mov    QWORD PTR [rsp+0x38],rsi
    3ac2:	mov    QWORD PTR [rsp+0x8],rdx
    3ac7:	mov    QWORD PTR [rsp+0x40],rdx
    3acc:	mov    QWORD PTR [rsp+0x10],rcx
    3ad1:	mov    r13,rcx
    3ad4:	mov    QWORD PTR [rsp+0x18],r8
    3ad9:	mov    QWORD PTR [rsp+0x48],r8
    3ade:	mov    QWORD PTR [rsp+0x20],r9
    3ae3:	mov    r15,r9
    3ae6:	mov    QWORD PTR [rsp+0x28],r10
    3aeb:	mov    r14,r10
    3aee:	mov    rsi,r15
    3af1:	mov    rdi,r12
    3af4:	call   3af9 <botlish_fn_44+0x8d>
			3af5: R_X86_64_PLT32	rt_hash-0x4
    3af9:	test   rax,rax
    3afc:	mov    rsi,rax
    3aff:	jne    3b0d <botlish_fn_44+0xa1>
    3b05:	mov    rdi,r12
    3b08:	jmp    3be4 <botlish_fn_44+0x178>
    3b0d:	mov    rdx,QWORD PTR [rsp+0x48]
    3b12:	mov    rdi,r12
    3b15:	call   3b1a <botlish_fn_44+0xae>
			3b16: R_X86_64_PLT32	rt_int_mod-0x4
    3b1a:	test   rax,rax
    3b1d:	jne    3b2b <botlish_fn_44+0xbf>
    3b23:	mov    rdi,r12
    3b26:	jmp    3be4 <botlish_fn_44+0x178>
    3b2b:	mov    QWORD PTR [rsp+0x30],rax
    3b30:	mov    rcx,QWORD PTR [rsp+0x48]
    3b35:	mov    rdx,rax
    3b38:	mov    rsi,QWORD PTR [rsp+0x38]
    3b3d:	mov    rdi,r12
    3b40:	call   3b45 <botlish_fn_44+0xd9>
			3b41: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    3b45:	test   rax,rax
    3b48:	jne    3b56 <botlish_fn_44+0xea>
    3b4e:	mov    rdi,r12
    3b51:	jmp    3be4 <botlish_fn_44+0x178>
    3b56:	mov    QWORD PTR [rsp+0x18],rax
    3b5b:	mov    QWORD PTR [rsp+0x48],rax
    3b60:	mov    rdi,r12
    3b63:	call   3b68 <botlish_fn_44+0xfc>
			3b64: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3b68:	test   rax,rax
    3b6b:	mov    rcx,rax
    3b6e:	jne    3b7c <botlish_fn_44+0x110>
    3b74:	mov    rdi,r12
    3b77:	jmp    3be4 <botlish_fn_44+0x178>
    3b7c:	mov    rsi,QWORD PTR [rsp+0x38]
    3b81:	mov    rdx,QWORD PTR [rsp+0x48]
    3b86:	mov    rdi,r12
    3b89:	call   3b8e <botlish_fn_44+0x122>
			3b8a: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b8e:	test   rax,rax
    3b91:	jne    3b9f <botlish_fn_44+0x133>
    3b97:	mov    rdi,r12
    3b9a:	jmp    3be4 <botlish_fn_44+0x178>
    3b9f:	mov    rcx,r15
    3ba2:	mov    rsi,QWORD PTR [rsp+0x40]
    3ba7:	mov    rdx,QWORD PTR [rsp+0x48]
    3bac:	mov    rdi,r12
    3baf:	call   3bb4 <botlish_fn_44+0x148>
			3bb0: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bb4:	test   rax,rax
    3bb7:	jne    3bc5 <botlish_fn_44+0x159>
    3bbd:	mov    rdi,r12
    3bc0:	jmp    3be4 <botlish_fn_44+0x178>
    3bc5:	mov    rcx,r14
    3bc8:	mov    rdx,QWORD PTR [rsp+0x48]
    3bcd:	mov    rsi,r13
    3bd0:	mov    rdi,r12
    3bd3:	call   3bd8 <botlish_fn_44+0x16c>
			3bd4: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bd8:	test   rax,rax
    3bdb:	jne    3c12 <botlish_fn_44+0x1a6>
    3be1:	mov    rdi,r12
    3be4:	mov    rdi,r12
    3be7:	mov    QWORD PTR [rdi],rbx
    3bea:	xor    rax,rax
    3bed:	mov    rbx,QWORD PTR [rsp+0x50]
    3bf2:	mov    r12,QWORD PTR [rsp+0x58]
    3bf7:	mov    r13,QWORD PTR [rsp+0x60]
    3bfc:	mov    r14,QWORD PTR [rsp+0x68]
    3c01:	mov    r15,QWORD PTR [rsp+0x70]
    3c06:	add    rsp,0x80
    3c0d:	mov    rsp,rbp
    3c10:	pop    rbp
    3c11:	ret
    3c12:	mov    rdi,r12
    3c15:	mov    QWORD PTR [rdi],rbx
    3c18:	mov    eax,0xa
    3c1d:	mov    rbx,QWORD PTR [rsp+0x50]
    3c22:	mov    r12,QWORD PTR [rsp+0x58]
    3c27:	mov    r13,QWORD PTR [rsp+0x60]
    3c2c:	mov    r14,QWORD PTR [rsp+0x68]
    3c31:	mov    r15,QWORD PTR [rsp+0x70]
    3c36:	add    rsp,0x80
    3c3d:	mov    rsp,rbp
    3c40:	pop    rbp
    3c41:	ret
    3c42:	mov    r12,rdi
    3c45:	call   3c4a <botlish_fn_44+0x1de>
			3c46: R_X86_64_PLT32	rt_stack_overflow-0x4
    3c4a:	xor    rax,rax
    3c4d:	mov    rbx,QWORD PTR [rsp+0x50]
    3c52:	mov    r12,QWORD PTR [rsp+0x58]
    3c57:	mov    r13,QWORD PTR [rsp+0x60]
    3c5c:	mov    r14,QWORD PTR [rsp+0x68]
    3c61:	mov    r15,QWORD PTR [rsp+0x70]
    3c66:	add    rsp,0x80
    3c6d:	mov    rsp,rbp
    3c70:	pop    rbp
    3c71:	ret

0000000000003c72 <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    3c72:	push   rbp
    3c73:	mov    rbp,rsp
    3c76:	sub    rsp,0x10
    3c7a:	mov    rsi,QWORD PTR [rdx]
    3c7d:	mov    r10,QWORD PTR [rdx+0x8]
    3c81:	mov    rcx,QWORD PTR [rdx+0x10]
    3c85:	mov    r8,QWORD PTR [rdx+0x18]
    3c89:	mov    r9,QWORD PTR [rdx+0x20]
    3c8d:	mov    r11,QWORD PTR [rdx+0x28]
    3c91:	mov    QWORD PTR [rsp],r11
    3c95:	mov    rdx,r10
    3c98:	call   3c9d <botlish_entry_44+0x2b>
			3c99: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    3c9d:	add    rsp,0x10
    3ca1:	mov    rsp,rbp
    3ca4:	pop    rbp
    3ca5:	ret
	...

0000000000003ca8 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    3ca8:	push   rbp
    3ca9:	mov    rbp,rsp
    3cac:	sub    rsp,0xd0
    3cb3:	mov    QWORD PTR [rsp+0xa0],rbx
    3cbb:	mov    QWORD PTR [rsp+0xa8],r12
    3cc3:	mov    QWORD PTR [rsp+0xb0],r13
    3ccb:	mov    QWORD PTR [rsp+0xb8],r14
    3cd3:	mov    QWORD PTR [rsp+0xc0],r15
    3cdb:	mov    r13,QWORD PTR [rbp+0x10]
    3cdf:	mov    r14,QWORD PTR [rbp+0x18]
    3ce3:	mov    r15,QWORD PTR [rbp+0x20]
    3ce7:	mov    r12,QWORD PTR [rbp+0x28]
    3ceb:	mov    r10,QWORD PTR [rdi]
    3cee:	mov    r11,QWORD PTR [rdi+0x8]
    3cf2:	lea    rax,[r10+0x8]
    3cf6:	cmp    rax,r11
    3cf9:	ja     41e9 <botlish_fn_45+0x541>
    3cff:	lea    rax,[r10+0x8]
    3d03:	mov    QWORD PTR [rdi],rax
    3d06:	mov    QWORD PTR [rsp+0x68],rdi
    3d0b:	mov    QWORD PTR [r10],0x0
    3d12:	mov    QWORD PTR [rsp+0x98],r10
    3d1a:	mov    QWORD PTR [rsp+0x60],0x0
    3d23:	mov    QWORD PTR [rsp+0x10],rsi
    3d28:	mov    QWORD PTR [rsp+0x70],rsi
    3d2d:	mov    QWORD PTR [rsp+0x18],rdx
    3d32:	mov    QWORD PTR [rsp+0x78],rdx
    3d37:	mov    QWORD PTR [rsp+0x20],rcx
    3d3c:	mov    QWORD PTR [rsp+0x80],rcx
    3d44:	mov    QWORD PTR [rsp+0x28],r8
    3d49:	mov    QWORD PTR [rsp+0x30],r9
    3d4e:	mov    QWORD PTR [rsp+0x88],r9
    3d56:	mov    QWORD PTR [rsp+0x38],r13
    3d5b:	mov    QWORD PTR [rsp+0x40],r14
    3d60:	mov    QWORD PTR [rsp+0x48],r15
    3d65:	mov    QWORD PTR [rsp+0x50],r12
    3d6a:	mov    rbx,QWORD PTR [rsp+0x88]
    3d72:	mov    rsi,r8
    3d75:	mov    rax,rsi
    3d78:	and    rax,rbx
    3d7b:	mov    QWORD PTR [rsp+0x90],rsi
    3d83:	test   rax,0x1
    3d89:	jne    3dc1 <botlish_fn_45+0x119>
    3d8f:	mov    rdx,rbx
    3d92:	mov    rsi,QWORD PTR [rsp+0x90]
    3d9a:	mov    rdi,QWORD PTR [rsp+0x68]
    3d9f:	call   3da4 <botlish_fn_45+0xfc>
			3da0: R_X86_64_PLT32	rt_int_cmp-0x4
    3da4:	mov    QWORD PTR [rsp+0x88],rbx
    3dac:	mov    ecx,0x2
    3db1:	test   rax,rax
    3db4:	cmovge rcx,QWORD PTR [rip+0x474]        # 4230 <botlish_fn_45+0x588>
    3dbc:	jmp    3de9 <botlish_fn_45+0x141>
    3dc1:	mov    QWORD PTR [rsp+0x88],rbx
    3dc9:	mov    ecx,0x2
    3dce:	mov    rsi,QWORD PTR [rsp+0x90]
    3dd6:	mov    r9,QWORD PTR [rsp+0x88]
    3dde:	cmp    rsi,r9
    3de1:	cmovge rcx,QWORD PTR [rip+0x447]        # 4230 <botlish_fn_45+0x588>
    3de9:	cmp    rcx,0x6
    3ded:	je     41a0 <botlish_fn_45+0x4f8>
    3df3:	xor    eax,eax
    3df5:	mov    rsi,QWORD PTR [rsp+0x70]
    3dfa:	test   rsi,0x7
    3e01:	jne    3e10 <botlish_fn_45+0x168>
    3e07:	movzx  rax,BYTE PTR [rsi]
    3e0b:	cmp    al,0x8
    3e0d:	sete   al
    3e10:	test   al,al
    3e12:	jne    3e41 <botlish_fn_45+0x199>
    3e18:	mov    rdi,QWORD PTR [rsp+0x68]
    3e1d:	mov    rax,QWORD PTR [rdi+0x10]
    3e21:	mov    rcx,QWORD PTR [rax+0x20]
    3e25:	mov    edx,0x8
    3e2a:	call   3e2f <botlish_fn_45+0x187>
			3e2b: R_X86_64_PLT32	rt_type_error-0x4
    3e2f:	mov    rbx,QWORD PTR [rsp+0x98]
    3e37:	mov    rdi,QWORD PTR [rsp+0x68]
    3e3c:	jmp    4087 <botlish_fn_45+0x3df>
    3e41:	mov    QWORD PTR [rsp+0x70],rsi
    3e46:	mov    rdx,QWORD PTR [rsp+0x90]
    3e4e:	mov    rdi,QWORD PTR [rsp+0x68]
    3e53:	call   3e58 <botlish_fn_45+0x1b0>
			3e54: R_X86_64_PLT32	rt_mutarray_get-0x4
    3e58:	test   rax,rax
    3e5b:	jne    3e73 <botlish_fn_45+0x1cb>
    3e61:	mov    rbx,QWORD PTR [rsp+0x98]
    3e69:	mov    rdi,QWORD PTR [rsp+0x68]
    3e6e:	jmp    4087 <botlish_fn_45+0x3df>
    3e73:	mov    QWORD PTR [rsp+0x58],rax
    3e78:	mov    rbx,rax
    3e7b:	mov    rdi,QWORD PTR [rsp+0x68]
    3e80:	call   3e85 <botlish_fn_45+0x1dd>
			3e81: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3e85:	test   rax,rax
    3e88:	jne    3ea0 <botlish_fn_45+0x1f8>
    3e8e:	mov    rbx,QWORD PTR [rsp+0x98]
    3e96:	mov    rdi,QWORD PTR [rsp+0x68]
    3e9b:	jmp    4087 <botlish_fn_45+0x3df>
    3ea0:	mov    rcx,rbx
    3ea3:	mov    rdx,rcx
    3ea6:	and    rdx,rax
    3ea9:	test   rdx,0x1
    3eb0:	jne    3ee1 <botlish_fn_45+0x239>
    3eb6:	mov    rdx,rax
    3eb9:	mov    rsi,rbx
    3ebc:	mov    rdi,QWORD PTR [rsp+0x68]
    3ec1:	call   3ec6 <botlish_fn_45+0x21e>
			3ec2: R_X86_64_PLT32	rt_value_eq-0x4
    3ec6:	test   rax,rax
    3ec9:	jne    3ef7 <botlish_fn_45+0x24f>
    3ecf:	mov    rbx,QWORD PTR [rsp+0x98]
    3ed7:	mov    rdi,QWORD PTR [rsp+0x68]
    3edc:	jmp    4087 <botlish_fn_45+0x3df>
    3ee1:	mov    rdx,rax
    3ee4:	mov    rsi,rbx
    3ee7:	mov    eax,0x2
    3eec:	cmp    rsi,rdx
    3eef:	cmove  rax,QWORD PTR [rip+0x339]        # 4230 <botlish_fn_45+0x588>
    3ef7:	cmp    rax,0x6
    3efb:	je     3f0e <botlish_fn_45+0x266>
    3f01:	mov    rbx,QWORD PTR [rsp+0x98]
    3f09:	jmp    40ce <botlish_fn_45+0x426>
    3f0e:	xor    eax,eax
    3f10:	mov    rdx,QWORD PTR [rsp+0x78]
    3f15:	test   rdx,0x7
    3f1c:	je     3f2c <botlish_fn_45+0x284>
    3f22:	mov    QWORD PTR [rsp+0x78],rdx
    3f27:	jmp    3f3c <botlish_fn_45+0x294>
    3f2c:	movzx  rcx,BYTE PTR [rdx]
    3f30:	mov    QWORD PTR [rsp+0x78],rdx
    3f35:	rex cmp cl,0x8
    3f39:	sete   al
    3f3c:	test   al,al
    3f3e:	jne    3f72 <botlish_fn_45+0x2ca>
    3f44:	mov    rdi,QWORD PTR [rsp+0x68]
    3f49:	mov    rsi,QWORD PTR [rdi+0x10]
    3f4d:	mov    rcx,QWORD PTR [rsi+0x20]
    3f51:	mov    edx,0x8
    3f56:	mov    rsi,QWORD PTR [rsp+0x78]
    3f5b:	call   3f60 <botlish_fn_45+0x2b8>
			3f5c: R_X86_64_PLT32	rt_type_error-0x4
    3f60:	mov    rbx,QWORD PTR [rsp+0x98]
    3f68:	mov    rdi,QWORD PTR [rsp+0x68]
    3f6d:	jmp    4087 <botlish_fn_45+0x3df>
    3f72:	mov    rdx,QWORD PTR [rsp+0x90]
    3f7a:	mov    rsi,QWORD PTR [rsp+0x78]
    3f7f:	mov    rdi,QWORD PTR [rsp+0x68]
    3f84:	call   3f89 <botlish_fn_45+0x2e1>
			3f85: R_X86_64_PLT32	rt_mutarray_get-0x4
    3f89:	test   rax,rax
    3f8c:	jne    3fa4 <botlish_fn_45+0x2fc>
    3f92:	mov    rbx,QWORD PTR [rsp+0x98]
    3f9a:	mov    rdi,QWORD PTR [rsp+0x68]
    3f9f:	jmp    4087 <botlish_fn_45+0x3df>
    3fa4:	mov    QWORD PTR [rsp+0x58],rax
    3fa9:	mov    rbx,rax
    3fac:	xor    eax,eax
    3fae:	mov    rcx,QWORD PTR [rsp+0x80]
    3fb6:	test   rcx,0x7
    3fbd:	je     3fd0 <botlish_fn_45+0x328>
    3fc3:	mov    QWORD PTR [rsp+0x80],rcx
    3fcb:	jmp    3fe1 <botlish_fn_45+0x339>
    3fd0:	movzx  rax,BYTE PTR [rcx]
    3fd4:	mov    QWORD PTR [rsp+0x80],rcx
    3fdc:	cmp    al,0x8
    3fde:	sete   al
    3fe1:	test   al,al
    3fe3:	jne    401a <botlish_fn_45+0x372>
    3fe9:	mov    rdi,QWORD PTR [rsp+0x68]
    3fee:	mov    rax,QWORD PTR [rdi+0x10]
    3ff2:	mov    rcx,QWORD PTR [rax+0x20]
    3ff6:	mov    edx,0x8
    3ffb:	mov    rsi,QWORD PTR [rsp+0x80]
    4003:	call   4008 <botlish_fn_45+0x360>
			4004: R_X86_64_PLT32	rt_type_error-0x4
    4008:	mov    rbx,QWORD PTR [rsp+0x98]
    4010:	mov    rdi,QWORD PTR [rsp+0x68]
    4015:	jmp    4087 <botlish_fn_45+0x3df>
    401a:	mov    rdx,QWORD PTR [rsp+0x90]
    4022:	mov    rsi,QWORD PTR [rsp+0x80]
    402a:	mov    rdi,QWORD PTR [rsp+0x68]
    402f:	call   4034 <botlish_fn_45+0x38c>
			4030: R_X86_64_PLT32	rt_mutarray_get-0x4
    4034:	test   rax,rax
    4037:	jne    404f <botlish_fn_45+0x3a7>
    403d:	mov    rbx,QWORD PTR [rsp+0x98]
    4045:	mov    rdi,QWORD PTR [rsp+0x68]
    404a:	jmp    4087 <botlish_fn_45+0x3df>
    404f:	mov    QWORD PTR [rsp+0x60],rax
    4054:	mov    QWORD PTR [rsp],rax
    4058:	mov    r9,rbx
    405b:	mov    rcx,r15
    405e:	mov    rdx,r14
    4061:	mov    rsi,r13
    4064:	mov    rdi,QWORD PTR [rsp+0x68]
    4069:	mov    r8,r12
    406c:	call   4071 <botlish_fn_45+0x3c9>
			406d: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    4071:	test   rax,rax
    4074:	jne    40c6 <botlish_fn_45+0x41e>
    407a:	mov    rbx,QWORD PTR [rsp+0x98]
    4082:	mov    rdi,QWORD PTR [rsp+0x68]
    4087:	mov    rdi,QWORD PTR [rsp+0x68]
    408c:	mov    QWORD PTR [rdi],rbx
    408f:	xor    rax,rax
    4092:	mov    rbx,QWORD PTR [rsp+0xa0]
    409a:	mov    r12,QWORD PTR [rsp+0xa8]
    40a2:	mov    r13,QWORD PTR [rsp+0xb0]
    40aa:	mov    r14,QWORD PTR [rsp+0xb8]
    40b2:	mov    r15,QWORD PTR [rsp+0xc0]
    40ba:	add    rsp,0xd0
    40c1:	mov    rsp,rbp
    40c4:	pop    rbp
    40c5:	ret
    40c6:	mov    rbx,QWORD PTR [rsp+0x98]
    40ce:	mov    QWORD PTR [rsp+0x58],0x3
    40d7:	mov    rsi,QWORD PTR [rsp+0x90]
    40df:	test   rsi,0x1
    40e6:	je     4118 <botlish_fn_45+0x470>
    40ec:	mov    rsi,QWORD PTR [rsp+0x90]
    40f4:	mov    rcx,rsi
    40f7:	add    rcx,0x2
    40fb:	seto   al
    40fe:	test   al,al
    4100:	jne    4118 <botlish_fn_45+0x470>
    4106:	mov    rsi,QWORD PTR [rsp+0x70]
    410b:	mov    QWORD PTR [rsp+0x90],rcx
    4113:	jmp    413c <botlish_fn_45+0x494>
    4118:	mov    edx,0x3
    411d:	mov    rsi,QWORD PTR [rsp+0x90]
    4125:	mov    rdi,QWORD PTR [rsp+0x68]
    412a:	call   412f <botlish_fn_45+0x487>
			412b: R_X86_64_PLT32	rt_int_add-0x4
    412f:	mov    rsi,QWORD PTR [rsp+0x70]
    4134:	mov    QWORD PTR [rsp+0x90],rax
    413c:	mov    rsi,QWORD PTR [rsp+0x70]
    4141:	mov    QWORD PTR [rsp+0x10],rsi
    4146:	mov    rsi,QWORD PTR [rsp+0x78]
    414b:	mov    QWORD PTR [rsp+0x18],rsi
    4150:	mov    rsi,QWORD PTR [rsp+0x80]
    4158:	mov    QWORD PTR [rsp+0x20],rsi
    415d:	mov    rsi,QWORD PTR [rsp+0x90]
    4165:	mov    QWORD PTR [rsp+0x28],rsi
    416a:	mov    r9,QWORD PTR [rsp+0x88]
    4172:	mov    QWORD PTR [rsp+0x30],r9
    4177:	mov    QWORD PTR [rsp+0x38],r13
    417c:	mov    QWORD PTR [rsp+0x40],r14
    4181:	mov    QWORD PTR [rsp+0x48],r15
    4186:	mov    QWORD PTR [rsp+0x50],r12
    418b:	mov    QWORD PTR [rsp+0x98],rbx
    4193:	mov    rbx,QWORD PTR [rsp+0x88]
    419b:	jmp    3d75 <botlish_fn_45+0xcd>
    41a0:	mov    rbx,QWORD PTR [rsp+0x98]
    41a8:	mov    rdi,QWORD PTR [rsp+0x68]
    41ad:	mov    QWORD PTR [rdi],rbx
    41b0:	mov    eax,0xa
    41b5:	mov    rbx,QWORD PTR [rsp+0xa0]
    41bd:	mov    r12,QWORD PTR [rsp+0xa8]
    41c5:	mov    r13,QWORD PTR [rsp+0xb0]
    41cd:	mov    r14,QWORD PTR [rsp+0xb8]
    41d5:	mov    r15,QWORD PTR [rsp+0xc0]
    41dd:	add    rsp,0xd0
    41e4:	mov    rsp,rbp
    41e7:	pop    rbp
    41e8:	ret
    41e9:	mov    QWORD PTR [rsp+0x68],rdi
    41ee:	call   41f3 <botlish_fn_45+0x54b>
			41ef: R_X86_64_PLT32	rt_stack_overflow-0x4
    41f3:	xor    rax,rax
    41f6:	mov    rbx,QWORD PTR [rsp+0xa0]
    41fe:	mov    r12,QWORD PTR [rsp+0xa8]
    4206:	mov    r13,QWORD PTR [rsp+0xb0]
    420e:	mov    r14,QWORD PTR [rsp+0xb8]
    4216:	mov    r15,QWORD PTR [rsp+0xc0]
    421e:	add    rsp,0xd0
    4225:	mov    rsp,rbp
    4228:	pop    rbp
    4229:	ret
    422a:	add    BYTE PTR [rax],al
    422c:	add    BYTE PTR [rax],al
    422e:	add    BYTE PTR [rax],al
    4230:	(bad)
    4231:	add    BYTE PTR [rax],al
    4233:	add    BYTE PTR [rax],al
    4235:	add    BYTE PTR [rax],al
	...

0000000000004238 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4238:	push   rbp
    4239:	mov    rbp,rsp
    423c:	sub    rsp,0x30
    4240:	mov    QWORD PTR [rsp+0x20],r12
    4245:	mov    rsi,QWORD PTR [rdx]
    4248:	mov    rax,QWORD PTR [rdx+0x8]
    424c:	mov    rcx,QWORD PTR [rdx+0x10]
    4250:	mov    r8,QWORD PTR [rdx+0x18]
    4254:	mov    r9,QWORD PTR [rdx+0x20]
    4258:	mov    r10,QWORD PTR [rdx+0x28]
    425c:	mov    r11,QWORD PTR [rdx+0x30]
    4260:	mov    r12,QWORD PTR [rdx+0x38]
    4264:	mov    rdx,QWORD PTR [rdx+0x40]
    4268:	mov    QWORD PTR [rsp],r10
    426c:	mov    QWORD PTR [rsp+0x8],r11
    4271:	mov    QWORD PTR [rsp+0x10],r12
    4276:	mov    QWORD PTR [rsp+0x18],rdx
    427b:	mov    rdx,rax
    427e:	call   4283 <botlish_entry_45+0x4b>
			427f: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    4283:	mov    r12,QWORD PTR [rsp+0x20]
    4288:	add    rsp,0x30
    428c:	mov    rsp,rbp
    428f:	pop    rbp
    4290:	ret

0000000000004291 <botlish_fn_46: ht_rehash<mutarray, int>>:
    4291:	push   rbp
    4292:	mov    rbp,rsp
    4295:	sub    rsp,0xd0
    429c:	mov    QWORD PTR [rsp+0xa0],rbx
    42a4:	mov    QWORD PTR [rsp+0xa8],r12
    42ac:	mov    QWORD PTR [rsp+0xb0],r13
    42b4:	mov    QWORD PTR [rsp+0xb8],r14
    42bc:	mov    QWORD PTR [rsp+0xc0],r15
    42c4:	mov    r12,QWORD PTR [rdi]
    42c7:	mov    rax,QWORD PTR [rdi+0x8]
    42cb:	lea    rcx,[r12+0x8]
    42d0:	cmp    rcx,rax
    42d3:	ja     460a <botlish_fn_46+0x379>
    42d9:	lea    rax,[r12+0x8]
    42de:	mov    QWORD PTR [rdi],rax
    42e1:	mov    r13,rdi
    42e4:	mov    QWORD PTR [r12],0x0
    42ec:	mov    QWORD PTR [rsp+0x30],0x0
    42f5:	mov    QWORD PTR [rsp+0x38],0x0
    42fe:	mov    QWORD PTR [rsp+0x40],0x0
    4307:	mov    QWORD PTR [rsp+0x48],0x0
    4310:	mov    QWORD PTR [rsp+0x50],0x0
    4319:	mov    QWORD PTR [rsp+0x58],0x0
    4322:	mov    QWORD PTR [rsp+0x60],0x0
    432b:	mov    QWORD PTR [rsp+0x68],0x0
    4334:	mov    QWORD PTR [rsp+0x20],rsi
    4339:	mov    r14,rsi
    433c:	mov    QWORD PTR [rsp+0x28],rdx
    4341:	mov    rbx,rdx
    4344:	mov    rsi,r14
    4347:	mov    rdi,r13
    434a:	call   434f <botlish_fn_46+0xbe>
			434b: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    434f:	test   rax,rax
    4352:	jne    4360 <botlish_fn_46+0xcf>
    4358:	mov    rdi,r13
    435b:	jmp    458e <botlish_fn_46+0x2fd>
    4360:	mov    QWORD PTR [rsp+0x30],rax
    4365:	mov    r15,rax
    4368:	mov    rsi,r14
    436b:	mov    rdi,r13
    436e:	call   4373 <botlish_fn_46+0xe2>
			436f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4373:	test   rax,rax
    4376:	jne    4384 <botlish_fn_46+0xf3>
    437c:	mov    rdi,r13
    437f:	jmp    458e <botlish_fn_46+0x2fd>
    4384:	mov    QWORD PTR [rsp+0x38],rax
    4389:	mov    QWORD PTR [rsp+0x98],rax
    4391:	mov    rsi,r14
    4394:	mov    rdi,r13
    4397:	call   439c <botlish_fn_46+0x10b>
			4398: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    439c:	test   rax,rax
    439f:	jne    43ad <botlish_fn_46+0x11c>
    43a5:	mov    rdi,r13
    43a8:	jmp    458e <botlish_fn_46+0x2fd>
    43ad:	mov    QWORD PTR [rsp+0x40],rax
    43b2:	mov    QWORD PTR [rsp+0x90],rax
    43ba:	mov    rsi,r14
    43bd:	mov    rdi,r13
    43c0:	call   43c5 <botlish_fn_46+0x134>
			43c1: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    43c5:	test   rax,rax
    43c8:	jne    43d6 <botlish_fn_46+0x145>
    43ce:	mov    rdi,r13
    43d1:	jmp    458e <botlish_fn_46+0x2fd>
    43d6:	mov    QWORD PTR [rsp+0x48],rax
    43db:	mov    QWORD PTR [rsp+0x88],rax
    43e3:	mov    rsi,rbx
    43e6:	mov    rdi,r13
    43e9:	call   43ee <botlish_fn_46+0x15d>
			43ea: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    43ee:	mov    rcx,rax
    43f1:	mov    QWORD PTR [rsp+0x80],rax
    43f9:	test   rax,rcx
    43fc:	jne    440a <botlish_fn_46+0x179>
    4402:	mov    rdi,r13
    4405:	jmp    458e <botlish_fn_46+0x2fd>
    440a:	mov    rax,QWORD PTR [rsp+0x80]
    4412:	mov    QWORD PTR [rsp+0x50],rax
    4417:	mov    edx,0x1
    441c:	mov    QWORD PTR [rsp+0x58],0x1
    4425:	mov    rcx,rbx
    4428:	mov    rsi,QWORD PTR [rsp+0x80]
    4430:	mov    rdi,r13
    4433:	call   4438 <botlish_fn_46+0x1a7>
			4434: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    4438:	test   rax,rax
    443b:	jne    4449 <botlish_fn_46+0x1b8>
    4441:	mov    rdi,r13
    4444:	jmp    458e <botlish_fn_46+0x2fd>
    4449:	mov    rsi,rbx
    444c:	mov    rdi,r13
    444f:	call   4454 <botlish_fn_46+0x1c3>
			4450: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4454:	test   rax,rax
    4457:	jne    4465 <botlish_fn_46+0x1d4>
    445d:	mov    rdi,r13
    4460:	jmp    458e <botlish_fn_46+0x2fd>
    4465:	mov    QWORD PTR [rsp+0x58],rax
    446a:	mov    QWORD PTR [rsp+0x78],rax
    446f:	mov    rsi,rbx
    4472:	mov    rdi,r13
    4475:	call   447a <botlish_fn_46+0x1e9>
			4476: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    447a:	test   rax,rax
    447d:	jne    448b <botlish_fn_46+0x1fa>
    4483:	mov    rdi,r13
    4486:	jmp    458e <botlish_fn_46+0x2fd>
    448b:	mov    QWORD PTR [rsp+0x60],rax
    4490:	mov    r8d,0x1
    4496:	mov    QWORD PTR [rsp+0x68],0x1
    449f:	mov    rcx,QWORD PTR [rsp+0x80]
    44a7:	mov    QWORD PTR [rsp],rcx
    44ab:	mov    rcx,QWORD PTR [rsp+0x78]
    44b0:	mov    QWORD PTR [rsp+0x8],rcx
    44b5:	mov    QWORD PTR [rsp+0x10],rax
    44ba:	mov    QWORD PTR [rsp+0x70],rax
    44bf:	mov    QWORD PTR [rsp+0x18],rbx
    44c4:	mov    rcx,QWORD PTR [rsp+0x90]
    44cc:	mov    rdx,QWORD PTR [rsp+0x98]
    44d4:	mov    rsi,r15
    44d7:	mov    r9,QWORD PTR [rsp+0x88]
    44df:	mov    rdi,r13
    44e2:	call   44e7 <botlish_fn_46+0x256>
			44e3: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    44e7:	test   rax,rax
    44ea:	jne    44f8 <botlish_fn_46+0x267>
    44f0:	mov    rdi,r13
    44f3:	jmp    458e <botlish_fn_46+0x2fd>
    44f8:	mov    edx,0x1
    44fd:	mov    rcx,QWORD PTR [rsp+0x80]
    4505:	mov    rsi,r14
    4508:	mov    rdi,r13
    450b:	call   4510 <botlish_fn_46+0x27f>
			450c: R_X86_64_PLT32	rt_mutarray_set-0x4
    4510:	test   rax,rax
    4513:	jne    4521 <botlish_fn_46+0x290>
    4519:	mov    rdi,r13
    451c:	jmp    458e <botlish_fn_46+0x2fd>
    4521:	mov    edx,0x3
    4526:	mov    rcx,QWORD PTR [rsp+0x78]
    452b:	mov    rsi,r14
    452e:	mov    rdi,r13
    4531:	call   4536 <botlish_fn_46+0x2a5>
			4532: R_X86_64_PLT32	rt_mutarray_set-0x4
    4536:	test   rax,rax
    4539:	jne    4547 <botlish_fn_46+0x2b6>
    453f:	mov    rdi,r13
    4542:	jmp    458e <botlish_fn_46+0x2fd>
    4547:	mov    edx,0x5
    454c:	mov    rcx,QWORD PTR [rsp+0x70]
    4551:	mov    rsi,r14
    4554:	mov    rdi,r13
    4557:	call   455c <botlish_fn_46+0x2cb>
			4558: R_X86_64_PLT32	rt_mutarray_set-0x4
    455c:	test   rax,rax
    455f:	jne    456d <botlish_fn_46+0x2dc>
    4565:	mov    rdi,r13
    4568:	jmp    458e <botlish_fn_46+0x2fd>
    456d:	mov    edx,0x9
    4572:	mov    ecx,0x1
    4577:	mov    rsi,r14
    457a:	mov    rdi,r13
    457d:	call   4582 <botlish_fn_46+0x2f1>
			457e: R_X86_64_PLT32	rt_mutarray_set-0x4
    4582:	test   rax,rax
    4585:	jne    45cb <botlish_fn_46+0x33a>
    458b:	mov    rdi,r13
    458e:	mov    rdi,r13
    4591:	mov    QWORD PTR [rdi],r12
    4594:	xor    rax,rax
    4597:	mov    rbx,QWORD PTR [rsp+0xa0]
    459f:	mov    r12,QWORD PTR [rsp+0xa8]
    45a7:	mov    r13,QWORD PTR [rsp+0xb0]
    45af:	mov    r14,QWORD PTR [rsp+0xb8]
    45b7:	mov    r15,QWORD PTR [rsp+0xc0]
    45bf:	add    rsp,0xd0
    45c6:	mov    rsp,rbp
    45c9:	pop    rbp
    45ca:	ret
    45cb:	mov    rdi,r13
    45ce:	mov    QWORD PTR [rdi],r12
    45d1:	mov    eax,0xa
    45d6:	mov    rbx,QWORD PTR [rsp+0xa0]
    45de:	mov    r12,QWORD PTR [rsp+0xa8]
    45e6:	mov    r13,QWORD PTR [rsp+0xb0]
    45ee:	mov    r14,QWORD PTR [rsp+0xb8]
    45f6:	mov    r15,QWORD PTR [rsp+0xc0]
    45fe:	add    rsp,0xd0
    4605:	mov    rsp,rbp
    4608:	pop    rbp
    4609:	ret
    460a:	mov    r13,rdi
    460d:	call   4612 <botlish_fn_46+0x381>
			460e: R_X86_64_PLT32	rt_stack_overflow-0x4
    4612:	xor    rax,rax
    4615:	mov    rbx,QWORD PTR [rsp+0xa0]
    461d:	mov    r12,QWORD PTR [rsp+0xa8]
    4625:	mov    r13,QWORD PTR [rsp+0xb0]
    462d:	mov    r14,QWORD PTR [rsp+0xb8]
    4635:	mov    r15,QWORD PTR [rsp+0xc0]
    463d:	add    rsp,0xd0
    4644:	mov    rsp,rbp
    4647:	pop    rbp
    4648:	ret

0000000000004649 <botlish_entry_46: ht_rehash<mutarray, int>>:
    4649:	push   rbp
    464a:	mov    rbp,rsp
    464d:	mov    rsi,QWORD PTR [rdx]
    4650:	mov    rdx,QWORD PTR [rdx+0x8]
    4654:	call   4659 <botlish_entry_46+0x10>
			4655: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    4659:	mov    rsp,rbp
    465c:	pop    rbp
    465d:	ret
	...

0000000000004660 <botlish_fn_47: ht_should_grow<mutarray>>:
    4660:	push   rbp
    4661:	mov    rbp,rsp
    4664:	sub    rsp,0x40
    4668:	mov    QWORD PTR [rsp+0x20],rbx
    466d:	mov    QWORD PTR [rsp+0x28],r12
    4672:	mov    QWORD PTR [rsp+0x30],r13
    4677:	mov    QWORD PTR [rsp+0x38],r14
    467c:	mov    r12,QWORD PTR [rdi]
    467f:	mov    r8,QWORD PTR [rdi+0x8]
    4683:	lea    r9,[r12+0x8]
    4688:	cmp    r9,r8
    468b:	ja     49c6 <botlish_fn_47+0x366>
    4691:	lea    r9,[r12+0x8]
    4696:	mov    QWORD PTR [rdi],r9
    4699:	mov    r13,rdi
    469c:	mov    QWORD PTR [r12],0x0
    46a4:	mov    QWORD PTR [rsp+0x8],0x0
    46ad:	mov    QWORD PTR [rsp+0x10],0x0
    46b6:	mov    QWORD PTR [rsp],rsi
    46ba:	mov    rbx,rsi
    46bd:	mov    rsi,rbx
    46c0:	mov    rdi,r13
    46c3:	call   46c8 <botlish_fn_47+0x68>
			46c4: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    46c8:	mov    rcx,rax
    46cb:	mov    r14,rax
    46ce:	test   rax,rcx
    46d1:	jne    46df <botlish_fn_47+0x7f>
    46d7:	mov    rdi,r13
    46da:	jmp    48dc <botlish_fn_47+0x27c>
    46df:	mov    rax,r14
    46e2:	mov    QWORD PTR [rsp+0x8],rax
    46e7:	mov    rsi,rbx
    46ea:	mov    rdi,r13
    46ed:	call   46f2 <botlish_fn_47+0x92>
			46ee: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    46f2:	mov    rcx,rax
    46f5:	test   rcx,rcx
    46f8:	jne    4706 <botlish_fn_47+0xa6>
    46fe:	mov    rdi,r13
    4701:	jmp    48dc <botlish_fn_47+0x27c>
    4706:	mov    QWORD PTR [rsp+0x10],rcx
    470b:	mov    edx,0x1
    4710:	mov    rax,r14
    4713:	test   rax,0x1
    4719:	jne    473c <botlish_fn_47+0xdc>
    471f:	xor    edx,edx
    4721:	mov    rax,r14
    4724:	test   rax,0x7
    472a:	jne    473c <botlish_fn_47+0xdc>
    4730:	mov    rax,r14
    4733:	movzx  rax,BYTE PTR [rax]
    4737:	cmp    al,0x1
    4739:	sete   dl
    473c:	test   dl,dl
    473e:	jne    4762 <botlish_fn_47+0x102>
    4744:	mov    rdi,r13
    4747:	mov    rax,QWORD PTR [rdi+0x10]
    474b:	mov    rcx,QWORD PTR [rax+0x30]
    474f:	xor    rdx,rdx
    4752:	mov    rsi,r14
    4755:	call   475a <botlish_fn_47+0xfa>
			4756: R_X86_64_PLT32	rt_type_error-0x4
    475a:	mov    rdi,r13
    475d:	jmp    48dc <botlish_fn_47+0x27c>
    4762:	mov    eax,0x1
    4767:	test   rcx,0x1
    476e:	je     477c <botlish_fn_47+0x11c>
    4774:	mov    r8,rcx
    4777:	jmp    479f <botlish_fn_47+0x13f>
    477c:	xor    eax,eax
    477e:	test   rcx,0x7
    4785:	je     4793 <botlish_fn_47+0x133>
    478b:	mov    r8,rcx
    478e:	jmp    479f <botlish_fn_47+0x13f>
    4793:	movzx  rax,BYTE PTR [rcx]
    4797:	mov    r8,rcx
    479a:	cmp    al,0x1
    479c:	sete   al
    479f:	test   al,al
    47a1:	jne    47c5 <botlish_fn_47+0x165>
    47a7:	mov    rdi,r13
    47aa:	mov    rax,QWORD PTR [rdi+0x10]
    47ae:	mov    rcx,QWORD PTR [rax+0x30]
    47b2:	xor    rdx,rdx
    47b5:	mov    rsi,r8
    47b8:	call   47bd <botlish_fn_47+0x15d>
			47b9: R_X86_64_PLT32	rt_type_error-0x4
    47bd:	mov    rdi,r13
    47c0:	jmp    48dc <botlish_fn_47+0x27c>
    47c5:	mov    rcx,r8
    47c8:	mov    rsi,r14
    47cb:	mov    rax,rsi
    47ce:	and    rax,rcx
    47d1:	test   rax,0x1
    47d7:	jne    47e8 <botlish_fn_47+0x188>
    47dd:	mov    rdx,r8
    47e0:	mov    rsi,r14
    47e3:	jmp    4806 <botlish_fn_47+0x1a6>
    47e8:	mov    rcx,r8
    47eb:	lea    rax,[rcx-0x1]
    47ef:	mov    rsi,r14
    47f2:	add    rsi,rax
    47f5:	seto   al
    47f8:	test   al,al
    47fa:	je     4811 <botlish_fn_47+0x1b1>
    4800:	mov    rdx,r8
    4803:	mov    rsi,r14
    4806:	mov    rdi,r13
    4809:	call   480e <botlish_fn_47+0x1ae>
			480a: R_X86_64_PLT32	rt_int_add-0x4
    480e:	mov    rsi,rax
    4811:	mov    QWORD PTR [rsp+0x8],rsi
    4816:	mov    QWORD PTR [rsp+0x10],0x3
    481f:	test   rsi,0x1
    4826:	je     4849 <botlish_fn_47+0x1e9>
    482c:	mov    rax,rsi
    482f:	add    rax,0x2
    4833:	mov    rcx,rax
    4836:	seto   al
    4839:	test   al,al
    483b:	jne    4849 <botlish_fn_47+0x1e9>
    4841:	mov    rsi,rcx
    4844:	jmp    4859 <botlish_fn_47+0x1f9>
    4849:	mov    edx,0x3
    484e:	mov    rdi,r13
    4851:	call   4856 <botlish_fn_47+0x1f6>
			4852: R_X86_64_PLT32	rt_int_add-0x4
    4856:	mov    rsi,rax
    4859:	mov    QWORD PTR [rsp+0x8],rsi
    485e:	mov    edx,0x7
    4863:	mov    rcx,rdx
    4866:	mov    QWORD PTR [rsp+0x10],0x7
    486f:	test   rsi,0x1
    4876:	jne    4884 <botlish_fn_47+0x224>
    487c:	mov    rdx,rcx
    487f:	jmp    48b2 <botlish_fn_47+0x252>
    4884:	mov    rax,rsi
    4887:	sar    rax,1
    488a:	imul   QWORD PTR [rip+0x15f]        # 49f0 <botlish_fn_47+0x390>
    4891:	seto   dil
    4895:	or     rax,0x1
    4899:	test   dil,dil
    489c:	je     48aa <botlish_fn_47+0x24a>
    48a2:	mov    rdx,rcx
    48a5:	jmp    48b2 <botlish_fn_47+0x252>
    48aa:	mov    rsi,rax
    48ad:	jmp    48bd <botlish_fn_47+0x25d>
    48b2:	mov    rdi,r13
    48b5:	call   48ba <botlish_fn_47+0x25a>
			48b6: R_X86_64_PLT32	rt_int_mul-0x4
    48ba:	mov    rsi,rax
    48bd:	mov    QWORD PTR [rsp+0x8],rsi
    48c2:	mov    r14,rsi
    48c5:	mov    rsi,rbx
    48c8:	mov    rdi,r13
    48cb:	call   48d0 <botlish_fn_47+0x270>
			48cc: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    48d0:	test   rax,rax
    48d3:	jne    4902 <botlish_fn_47+0x2a2>
    48d9:	mov    rdi,r13
    48dc:	mov    rdi,r13
    48df:	mov    QWORD PTR [rdi],r12
    48e2:	xor    rax,rax
    48e5:	mov    rbx,QWORD PTR [rsp+0x20]
    48ea:	mov    r12,QWORD PTR [rsp+0x28]
    48ef:	mov    r13,QWORD PTR [rsp+0x30]
    48f4:	mov    r14,QWORD PTR [rsp+0x38]
    48f9:	add    rsp,0x40
    48fd:	mov    rsp,rbp
    4900:	pop    rbp
    4901:	ret
    4902:	mov    QWORD PTR [rsp],rax
    4906:	mov    QWORD PTR [rsp+0x10],0x5
    490f:	test   rax,0x1
    4915:	mov    rsi,rax
    4918:	je     4948 <botlish_fn_47+0x2e8>
    491e:	mov    rcx,rsi
    4921:	mov    rax,rcx
    4924:	sar    rax,1
    4927:	imul   QWORD PTR [rip+0xca]        # 49f8 <botlish_fn_47+0x398>
    492e:	seto   cl
    4931:	or     rax,0x1
    4935:	test   cl,cl
    4937:	jne    4948 <botlish_fn_47+0x2e8>
    493d:	mov    rdx,rax
    4940:	mov    rsi,r14
    4943:	jmp    495b <botlish_fn_47+0x2fb>
    4948:	mov    edx,0x5
    494d:	mov    rdi,r13
    4950:	call   4955 <botlish_fn_47+0x2f5>
			4951: R_X86_64_PLT32	rt_int_mul-0x4
    4955:	mov    rdx,rax
    4958:	mov    rsi,r14
    495b:	mov    rax,rsi
    495e:	and    rax,rdx
    4961:	test   rax,0x1
    4967:	jne    4990 <botlish_fn_47+0x330>
    496d:	mov    rdi,r13
    4970:	call   4975 <botlish_fn_47+0x315>
			4971: R_X86_64_PLT32	rt_int_cmp-0x4
    4975:	mov    ecx,0x2
    497a:	test   rax,rax
    497d:	mov    rax,rcx
    4980:	cmovg  rax,QWORD PTR [rip+0x68]        # 49f0 <botlish_fn_47+0x390>
    4988:	mov    rdi,r13
    498b:	jmp    49a3 <botlish_fn_47+0x343>
    4990:	mov    eax,0x2
    4995:	cmp    rsi,rdx
    4998:	cmovg  rax,QWORD PTR [rip+0x50]        # 49f0 <botlish_fn_47+0x390>
    49a0:	mov    rdi,r13
    49a3:	mov    rdi,r13
    49a6:	mov    QWORD PTR [rdi],r12
    49a9:	mov    rbx,QWORD PTR [rsp+0x20]
    49ae:	mov    r12,QWORD PTR [rsp+0x28]
    49b3:	mov    r13,QWORD PTR [rsp+0x30]
    49b8:	mov    r14,QWORD PTR [rsp+0x38]
    49bd:	add    rsp,0x40
    49c1:	mov    rsp,rbp
    49c4:	pop    rbp
    49c5:	ret
    49c6:	mov    r13,rdi
    49c9:	call   49ce <botlish_fn_47+0x36e>
			49ca: R_X86_64_PLT32	rt_stack_overflow-0x4
    49ce:	xor    rax,rax
    49d1:	mov    rbx,QWORD PTR [rsp+0x20]
    49d6:	mov    r12,QWORD PTR [rsp+0x28]
    49db:	mov    r13,QWORD PTR [rsp+0x30]
    49e0:	mov    r14,QWORD PTR [rsp+0x38]
    49e5:	add    rsp,0x40
    49e9:	mov    rsp,rbp
    49ec:	pop    rbp
    49ed:	ret
    49ee:	add    BYTE PTR [rax],al
    49f0:	(bad)
    49f1:	add    BYTE PTR [rax],al
    49f3:	add    BYTE PTR [rax],al
    49f5:	add    BYTE PTR [rax],al
    49f7:	add    BYTE PTR [rax+rax*1],al
    49fa:	add    BYTE PTR [rax],al
    49fc:	add    BYTE PTR [rax],al
	...

0000000000004a00 <botlish_entry_47: ht_should_grow<mutarray>>:
    4a00:	push   rbp
    4a01:	mov    rbp,rsp
    4a04:	mov    rsi,QWORD PTR [rdx]
    4a07:	call   4a0c <botlish_entry_47+0xc>
			4a08: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    4a0c:	mov    rsp,rbp
    4a0f:	pop    rbp
    4a10:	ret
    4a11:	add    BYTE PTR [rax],al
    4a13:	add    BYTE PTR [rax],al
    4a15:	add    BYTE PTR [rax],al
	...

0000000000004a18 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    4a18:	push   rbp
    4a19:	mov    rbp,rsp
    4a1c:	sub    rsp,0x40
    4a20:	mov    QWORD PTR [rsp+0x20],rbx
    4a25:	mov    QWORD PTR [rsp+0x28],r12
    4a2a:	mov    QWORD PTR [rsp+0x30],r13
    4a2f:	mov    QWORD PTR [rsp+0x38],r14
    4a34:	mov    rbx,QWORD PTR [rdi]
    4a37:	mov    rax,QWORD PTR [rdi+0x8]
    4a3b:	lea    rcx,[rbx+0x8]
    4a3f:	cmp    rcx,rax
    4a42:	ja     4cf5 <botlish_fn_48+0x2dd>
    4a48:	lea    rax,[rbx+0x8]
    4a4c:	mov    QWORD PTR [rdi],rax
    4a4f:	mov    r12,rdi
    4a52:	mov    QWORD PTR [rbx],0x0
    4a59:	mov    QWORD PTR [rsp+0x8],0x0
    4a62:	mov    QWORD PTR [rsp+0x10],0x0
    4a6b:	mov    QWORD PTR [rsp],rsi
    4a6f:	mov    r13,rsi
    4a72:	mov    rsi,r13
    4a75:	mov    rdi,r12
    4a78:	call   4a7d <botlish_fn_48+0x65>
			4a79: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4a7d:	test   rax,rax
    4a80:	jne    4a8e <botlish_fn_48+0x76>
    4a86:	mov    rdi,r12
    4a89:	jmp    4ca9 <botlish_fn_48+0x291>
    4a8e:	mov    QWORD PTR [rsp+0x8],rax
    4a93:	mov    r14,rax
    4a96:	mov    rsi,r13
    4a99:	mov    rdi,r12
    4a9c:	call   4aa1 <botlish_fn_48+0x89>
			4a9d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    4aa1:	mov    rcx,rax
    4aa4:	test   rcx,rcx
    4aa7:	jne    4ab5 <botlish_fn_48+0x9d>
    4aad:	mov    rdi,r12
    4ab0:	jmp    4ca9 <botlish_fn_48+0x291>
    4ab5:	mov    edx,0x1
    4aba:	mov    rax,r14
    4abd:	test   rax,0x1
    4ac3:	je     4ad1 <botlish_fn_48+0xb9>
    4ac9:	mov    r14,rax
    4acc:	jmp    4af5 <botlish_fn_48+0xdd>
    4ad1:	xor    edx,edx
    4ad3:	test   rax,0x7
    4ad9:	je     4ae7 <botlish_fn_48+0xcf>
    4adf:	mov    r14,rax
    4ae2:	jmp    4af5 <botlish_fn_48+0xdd>
    4ae7:	movzx  rdx,BYTE PTR [rax]
    4aeb:	mov    r14,rax
    4aee:	rex cmp dl,0x1
    4af2:	sete   dl
    4af5:	test   dl,dl
    4af7:	jne    4b1b <botlish_fn_48+0x103>
    4afd:	mov    rdi,r12
    4b00:	mov    rax,QWORD PTR [rdi+0x10]
    4b04:	mov    rcx,QWORD PTR [rax+0x38]
    4b08:	xor    rdx,rdx
    4b0b:	mov    rsi,r14
    4b0e:	call   4b13 <botlish_fn_48+0xfb>
			4b0f: R_X86_64_PLT32	rt_type_error-0x4
    4b13:	mov    rdi,r12
    4b16:	jmp    4ca9 <botlish_fn_48+0x291>
    4b1b:	mov    rsi,r14
    4b1e:	mov    eax,0x1
    4b23:	test   rcx,0x1
    4b2a:	je     4b38 <botlish_fn_48+0x120>
    4b30:	mov    r8,rcx
    4b33:	jmp    4b5b <botlish_fn_48+0x143>
    4b38:	xor    eax,eax
    4b3a:	test   rcx,0x7
    4b41:	je     4b4f <botlish_fn_48+0x137>
    4b47:	mov    r8,rcx
    4b4a:	jmp    4b5b <botlish_fn_48+0x143>
    4b4f:	movzx  rax,BYTE PTR [rcx]
    4b53:	mov    r8,rcx
    4b56:	cmp    al,0x1
    4b58:	sete   al
    4b5b:	test   al,al
    4b5d:	jne    4b81 <botlish_fn_48+0x169>
    4b63:	mov    rdi,r12
    4b66:	mov    rax,QWORD PTR [rdi+0x10]
    4b6a:	mov    rcx,QWORD PTR [rax+0x38]
    4b6e:	xor    rdx,rdx
    4b71:	mov    rsi,r8
    4b74:	call   4b79 <botlish_fn_48+0x161>
			4b75: R_X86_64_PLT32	rt_type_error-0x4
    4b79:	mov    rdi,r12
    4b7c:	jmp    4ca9 <botlish_fn_48+0x291>
    4b81:	mov    rcx,r8
    4b84:	mov    rax,rsi
    4b87:	and    rax,rcx
    4b8a:	test   rax,0x1
    4b90:	jne    4bb7 <botlish_fn_48+0x19f>
    4b96:	mov    rdx,r8
    4b99:	mov    rdi,r12
    4b9c:	call   4ba1 <botlish_fn_48+0x189>
			4b9d: R_X86_64_PLT32	rt_int_cmp-0x4
    4ba1:	mov    r9d,0x2
    4ba7:	test   rax,rax
    4baa:	cmovg  r9,QWORD PTR [rip+0x16e]        # 4d20 <botlish_fn_48+0x308>
    4bb2:	jmp    4bcb <botlish_fn_48+0x1b3>
    4bb7:	mov    r9d,0x2
    4bbd:	mov    rcx,r8
    4bc0:	cmp    rsi,rcx
    4bc3:	cmovg  r9,QWORD PTR [rip+0x155]        # 4d20 <botlish_fn_48+0x308>
    4bcb:	cmp    r9,0x6
    4bcf:	je     4c6e <botlish_fn_48+0x256>
    4bd5:	mov    rsi,r13
    4bd8:	mov    rdi,r12
    4bdb:	call   4be0 <botlish_fn_48+0x1c8>
			4bdc: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4be0:	test   rax,rax
    4be3:	jne    4bf1 <botlish_fn_48+0x1d9>
    4be9:	mov    rdi,r12
    4bec:	jmp    4ca9 <botlish_fn_48+0x291>
    4bf1:	mov    QWORD PTR [rsp+0x8],rax
    4bf6:	mov    QWORD PTR [rsp+0x10],0x5
    4bff:	test   rax,0x1
    4c05:	mov    rsi,rax
    4c08:	je     4c35 <botlish_fn_48+0x21d>
    4c0e:	mov    rcx,rsi
    4c11:	mov    rax,rcx
    4c14:	sar    rax,1
    4c17:	imul   QWORD PTR [rip+0x10a]        # 4d28 <botlish_fn_48+0x310>
    4c1e:	seto   cl
    4c21:	or     rax,0x1
    4c25:	test   cl,cl
    4c27:	jne    4c35 <botlish_fn_48+0x21d>
    4c2d:	mov    rdx,rax
    4c30:	jmp    4c45 <botlish_fn_48+0x22d>
    4c35:	mov    edx,0x5
    4c3a:	mov    rdi,r12
    4c3d:	call   4c42 <botlish_fn_48+0x22a>
			4c3e: R_X86_64_PLT32	rt_int_mul-0x4
    4c42:	mov    rdx,rax
    4c45:	mov    QWORD PTR [rsp+0x8],rdx
    4c4a:	mov    rsi,r13
    4c4d:	mov    rdi,r12
    4c50:	call   4c55 <botlish_fn_48+0x23d>
			4c51: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    4c55:	test   rax,rax
    4c58:	jne    4c66 <botlish_fn_48+0x24e>
    4c5e:	mov    rdi,r12
    4c61:	jmp    4ca9 <botlish_fn_48+0x291>
    4c66:	mov    rdi,r12
    4c69:	jmp    4cd2 <botlish_fn_48+0x2ba>
    4c6e:	mov    rsi,r13
    4c71:	mov    rdi,r12
    4c74:	call   4c79 <botlish_fn_48+0x261>
			4c75: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4c79:	test   rax,rax
    4c7c:	jne    4c8a <botlish_fn_48+0x272>
    4c82:	mov    rdi,r12
    4c85:	jmp    4ca9 <botlish_fn_48+0x291>
    4c8a:	mov    QWORD PTR [rsp+0x8],rax
    4c8f:	mov    rdx,rax
    4c92:	mov    rsi,r13
    4c95:	mov    rdi,r12
    4c98:	call   4c9d <botlish_fn_48+0x285>
			4c99: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    4c9d:	test   rax,rax
    4ca0:	jne    4ccf <botlish_fn_48+0x2b7>
    4ca6:	mov    rdi,r12
    4ca9:	mov    rdi,r12
    4cac:	mov    QWORD PTR [rdi],rbx
    4caf:	xor    rax,rax
    4cb2:	mov    rbx,QWORD PTR [rsp+0x20]
    4cb7:	mov    r12,QWORD PTR [rsp+0x28]
    4cbc:	mov    r13,QWORD PTR [rsp+0x30]
    4cc1:	mov    r14,QWORD PTR [rsp+0x38]
    4cc6:	add    rsp,0x40
    4cca:	mov    rsp,rbp
    4ccd:	pop    rbp
    4cce:	ret
    4ccf:	mov    rdi,r12
    4cd2:	mov    rdi,r12
    4cd5:	mov    QWORD PTR [rdi],rbx
    4cd8:	mov    rbx,QWORD PTR [rsp+0x20]
    4cdd:	mov    r12,QWORD PTR [rsp+0x28]
    4ce2:	mov    r13,QWORD PTR [rsp+0x30]
    4ce7:	mov    r14,QWORD PTR [rsp+0x38]
    4cec:	add    rsp,0x40
    4cf0:	mov    rsp,rbp
    4cf3:	pop    rbp
    4cf4:	ret
    4cf5:	mov    r12,rdi
    4cf8:	call   4cfd <botlish_fn_48+0x2e5>
			4cf9: R_X86_64_PLT32	rt_stack_overflow-0x4
    4cfd:	xor    rax,rax
    4d00:	mov    rbx,QWORD PTR [rsp+0x20]
    4d05:	mov    r12,QWORD PTR [rsp+0x28]
    4d0a:	mov    r13,QWORD PTR [rsp+0x30]
    4d0f:	mov    r14,QWORD PTR [rsp+0x38]
    4d14:	add    rsp,0x40
    4d18:	mov    rsp,rbp
    4d1b:	pop    rbp
    4d1c:	ret
    4d1d:	add    BYTE PTR [rax],al
    4d1f:	add    BYTE PTR [rsi],al
    4d21:	add    BYTE PTR [rax],al
    4d23:	add    BYTE PTR [rax],al
    4d25:	add    BYTE PTR [rax],al
    4d27:	add    BYTE PTR [rax+rax*1],al
    4d2a:	add    BYTE PTR [rax],al
    4d2c:	add    BYTE PTR [rax],al
	...

0000000000004d30 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    4d30:	push   rbp
    4d31:	mov    rbp,rsp
    4d34:	mov    rsi,QWORD PTR [rdx]
    4d37:	call   4d3c <botlish_entry_48+0xc>
			4d38: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    4d3c:	mov    rsp,rbp
    4d3f:	pop    rbp
    4d40:	ret
    4d41:	add    BYTE PTR [rax],al
    4d43:	add    BYTE PTR [rax],al
    4d45:	add    BYTE PTR [rax],al
	...

0000000000004d48 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    4d48:	push   rbp
    4d49:	mov    rbp,rsp
    4d4c:	sub    rsp,0x80
    4d53:	mov    QWORD PTR [rsp+0x50],rbx
    4d58:	mov    QWORD PTR [rsp+0x58],r12
    4d5d:	mov    QWORD PTR [rsp+0x60],r13
    4d62:	mov    QWORD PTR [rsp+0x68],r14
    4d67:	mov    QWORD PTR [rsp+0x70],r15
    4d6c:	mov    rbx,QWORD PTR [rdi]
    4d6f:	mov    rax,QWORD PTR [rdi+0x8]
    4d73:	lea    r9,[rbx+0x8]
    4d77:	cmp    r9,rax
    4d7a:	ja     5253 <botlish_fn_49+0x50b>
    4d80:	lea    rax,[rbx+0x8]
    4d84:	mov    QWORD PTR [rdi],rax
    4d87:	mov    r12,rdi
    4d8a:	mov    QWORD PTR [rbx],0x0
    4d91:	mov    QWORD PTR [rsp+0x20],0x0
    4d9a:	mov    QWORD PTR [rsp+0x28],0x0
    4da3:	mov    QWORD PTR [rsp],rsi
    4da7:	mov    r13,rsi
    4daa:	mov    QWORD PTR [rsp+0x8],rdx
    4daf:	mov    QWORD PTR [rsp+0x30],rdx
    4db4:	mov    QWORD PTR [rsp+0x10],rcx
    4db9:	mov    QWORD PTR [rsp+0x38],rcx
    4dbe:	mov    QWORD PTR [rsp+0x18],r8
    4dc3:	mov    r15,r8
    4dc6:	mov    rsi,r13
    4dc9:	mov    rdi,r12
    4dcc:	call   4dd1 <botlish_fn_49+0x89>
			4dcd: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    4dd1:	test   rax,rax
    4dd4:	jne    4de2 <botlish_fn_49+0x9a>
    4dda:	mov    rdi,r12
    4ddd:	jmp    51f2 <botlish_fn_49+0x4aa>
    4de2:	mov    QWORD PTR [rsp+0x20],rax
    4de7:	xor    ecx,ecx
    4de9:	test   rax,0x7
    4def:	je     4dff <botlish_fn_49+0xb7>
    4df5:	mov    QWORD PTR [rsp+0x40],rax
    4dfa:	jmp    4e0f <botlish_fn_49+0xc7>
    4dff:	movzx  rcx,BYTE PTR [rax]
    4e03:	mov    QWORD PTR [rsp+0x40],rax
    4e08:	rex cmp cl,0x8
    4e0c:	sete   cl
    4e0f:	test   cl,cl
    4e11:	jne    4e39 <botlish_fn_49+0xf1>
    4e17:	mov    rdi,r12
    4e1a:	mov    rax,QWORD PTR [rdi+0x10]
    4e1e:	mov    rcx,QWORD PTR [rax+0x20]
    4e22:	mov    edx,0x8
    4e27:	mov    rsi,QWORD PTR [rsp+0x40]
    4e2c:	call   4e31 <botlish_fn_49+0xe9>
			4e2d: R_X86_64_PLT32	rt_type_error-0x4
    4e31:	mov    rdi,r12
    4e34:	jmp    51f2 <botlish_fn_49+0x4aa>
    4e39:	mov    rdx,QWORD PTR [rsp+0x30]
    4e3e:	mov    rsi,QWORD PTR [rsp+0x40]
    4e43:	mov    rdi,r12
    4e46:	call   4e4b <botlish_fn_49+0x103>
			4e47: R_X86_64_PLT32	rt_mutarray_get-0x4
    4e4b:	test   rax,rax
    4e4e:	jne    4e5c <botlish_fn_49+0x114>
    4e54:	mov    rdi,r12
    4e57:	jmp    51f2 <botlish_fn_49+0x4aa>
    4e5c:	mov    QWORD PTR [rsp+0x28],rax
    4e61:	mov    r14,rax
    4e64:	mov    rdi,r12
    4e67:	call   4e6c <botlish_fn_49+0x124>
			4e68: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    4e6c:	test   rax,rax
    4e6f:	mov    rcx,rax
    4e72:	jne    4e80 <botlish_fn_49+0x138>
    4e78:	mov    rdi,r12
    4e7b:	jmp    51f2 <botlish_fn_49+0x4aa>
    4e80:	mov    rsi,QWORD PTR [rsp+0x40]
    4e85:	mov    rdx,QWORD PTR [rsp+0x30]
    4e8a:	mov    rdi,r12
    4e8d:	call   4e92 <botlish_fn_49+0x14a>
			4e8e: R_X86_64_PLT32	rt_mutarray_set-0x4
    4e92:	test   rax,rax
    4e95:	jne    4ea3 <botlish_fn_49+0x15b>
    4e9b:	mov    rdi,r12
    4e9e:	jmp    51f2 <botlish_fn_49+0x4aa>
    4ea3:	mov    rsi,r13
    4ea6:	mov    rdi,r12
    4ea9:	call   4eae <botlish_fn_49+0x166>
			4eaa: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4eae:	test   rax,rax
    4eb1:	jne    4ebf <botlish_fn_49+0x177>
    4eb7:	mov    rdi,r12
    4eba:	jmp    51f2 <botlish_fn_49+0x4aa>
    4ebf:	xor    ecx,ecx
    4ec1:	test   rax,0x7
    4ec7:	je     4ed5 <botlish_fn_49+0x18d>
    4ecd:	mov    rsi,rax
    4ed0:	jmp    4ee3 <botlish_fn_49+0x19b>
    4ed5:	movzx  r8,BYTE PTR [rax]
    4ed9:	mov    rsi,rax
    4edc:	cmp    r8b,0x8
    4ee0:	sete   cl
    4ee3:	test   cl,cl
    4ee5:	jne    4f08 <botlish_fn_49+0x1c0>
    4eeb:	mov    rdi,r12
    4eee:	mov    rax,QWORD PTR [rdi+0x10]
    4ef2:	mov    rcx,QWORD PTR [rax+0x40]
    4ef6:	mov    edx,0x8
    4efb:	call   4f00 <botlish_fn_49+0x1b8>
			4efc: R_X86_64_PLT32	rt_type_error-0x4
    4f00:	mov    rdi,r12
    4f03:	jmp    51f2 <botlish_fn_49+0x4aa>
    4f08:	mov    rcx,QWORD PTR [rsp+0x38]
    4f0d:	mov    rdx,QWORD PTR [rsp+0x30]
    4f12:	mov    rdi,r12
    4f15:	call   4f1a <botlish_fn_49+0x1d2>
			4f16: R_X86_64_PLT32	rt_mutarray_set-0x4
    4f1a:	test   rax,rax
    4f1d:	jne    4f2b <botlish_fn_49+0x1e3>
    4f23:	mov    rdi,r12
    4f26:	jmp    51f2 <botlish_fn_49+0x4aa>
    4f2b:	mov    rsi,r13
    4f2e:	mov    rdi,r12
    4f31:	call   4f36 <botlish_fn_49+0x1ee>
			4f32: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4f36:	test   rax,rax
    4f39:	jne    4f47 <botlish_fn_49+0x1ff>
    4f3f:	mov    rdi,r12
    4f42:	jmp    51f2 <botlish_fn_49+0x4aa>
    4f47:	xor    ecx,ecx
    4f49:	test   rax,0x7
    4f4f:	je     4f5d <botlish_fn_49+0x215>
    4f55:	mov    rsi,rax
    4f58:	jmp    4f6b <botlish_fn_49+0x223>
    4f5d:	movzx  rcx,BYTE PTR [rax]
    4f61:	mov    rsi,rax
    4f64:	rex cmp cl,0x8
    4f68:	sete   cl
    4f6b:	test   cl,cl
    4f6d:	jne    4f90 <botlish_fn_49+0x248>
    4f73:	mov    rdi,r12
    4f76:	mov    rax,QWORD PTR [rdi+0x10]
    4f7a:	mov    rcx,QWORD PTR [rax+0x40]
    4f7e:	mov    edx,0x8
    4f83:	call   4f88 <botlish_fn_49+0x240>
			4f84: R_X86_64_PLT32	rt_type_error-0x4
    4f88:	mov    rdi,r12
    4f8b:	jmp    51f2 <botlish_fn_49+0x4aa>
    4f90:	mov    rcx,r15
    4f93:	mov    rdx,QWORD PTR [rsp+0x30]
    4f98:	mov    rdi,r12
    4f9b:	call   4fa0 <botlish_fn_49+0x258>
			4f9c: R_X86_64_PLT32	rt_mutarray_set-0x4
    4fa0:	test   rax,rax
    4fa3:	jne    4fb1 <botlish_fn_49+0x269>
    4fa9:	mov    rdi,r12
    4fac:	jmp    51f2 <botlish_fn_49+0x4aa>
    4fb1:	mov    QWORD PTR [rsp+0x8],0x7
    4fba:	mov    rsi,r13
    4fbd:	mov    rdi,r12
    4fc0:	call   4fc5 <botlish_fn_49+0x27d>
			4fc1: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    4fc5:	test   rax,rax
    4fc8:	jne    4fd6 <botlish_fn_49+0x28e>
    4fce:	mov    rdi,r12
    4fd1:	jmp    51f2 <botlish_fn_49+0x4aa>
    4fd6:	mov    QWORD PTR [rsp+0x10],rax
    4fdb:	mov    QWORD PTR [rsp+0x18],0x3
    4fe4:	mov    ecx,0x1
    4fe9:	test   rax,0x1
    4fef:	je     4ffd <botlish_fn_49+0x2b5>
    4ff5:	mov    rsi,rax
    4ff8:	jmp    5021 <botlish_fn_49+0x2d9>
    4ffd:	xor    ecx,ecx
    4fff:	test   rax,0x7
    5005:	je     5013 <botlish_fn_49+0x2cb>
    500b:	mov    rsi,rax
    500e:	jmp    5021 <botlish_fn_49+0x2d9>
    5013:	movzx  rcx,BYTE PTR [rax]
    5017:	mov    rsi,rax
    501a:	rex cmp cl,0x1
    501e:	sete   cl
    5021:	test   cl,cl
    5023:	jne    5044 <botlish_fn_49+0x2fc>
    5029:	mov    rdi,r12
    502c:	mov    rax,QWORD PTR [rdi+0x10]
    5030:	mov    rcx,QWORD PTR [rax+0x30]
    5034:	xor    rdx,rdx
    5037:	call   503c <botlish_fn_49+0x2f4>
			5038: R_X86_64_PLT32	rt_type_error-0x4
    503c:	mov    rdi,r12
    503f:	jmp    51f2 <botlish_fn_49+0x4aa>
    5044:	test   rsi,0x1
    504b:	je     5063 <botlish_fn_49+0x31b>
    5051:	mov    rcx,rsi
    5054:	add    rcx,0x2
    5058:	seto   al
    505b:	test   al,al
    505d:	je     5073 <botlish_fn_49+0x32b>
    5063:	mov    edx,0x3
    5068:	mov    rdi,r12
    506b:	call   5070 <botlish_fn_49+0x328>
			506c: R_X86_64_PLT32	rt_int_add-0x4
    5070:	mov    rcx,rax
    5073:	mov    edx,0x7
    5078:	mov    rsi,r13
    507b:	mov    rdi,r12
    507e:	call   5083 <botlish_fn_49+0x33b>
			507f: R_X86_64_PLT32	rt_mutarray_set-0x4
    5083:	test   rax,rax
    5086:	jne    5094 <botlish_fn_49+0x34c>
    508c:	mov    rdi,r12
    508f:	jmp    51f2 <botlish_fn_49+0x4aa>
    5094:	mov    rdi,r12
    5097:	call   509c <botlish_fn_49+0x354>
			5098: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    509c:	test   rax,rax
    509f:	jne    50ad <botlish_fn_49+0x365>
    50a5:	mov    rdi,r12
    50a8:	jmp    51f2 <botlish_fn_49+0x4aa>
    50ad:	mov    rcx,r14
    50b0:	mov    rdx,rcx
    50b3:	and    rdx,rax
    50b6:	mov    r8,rax
    50b9:	test   rdx,0x1
    50c0:	jne    50e5 <botlish_fn_49+0x39d>
    50c6:	mov    rdx,r8
    50c9:	mov    rsi,r14
    50cc:	mov    rdi,r12
    50cf:	call   50d4 <botlish_fn_49+0x38c>
			50d0: R_X86_64_PLT32	rt_value_eq-0x4
    50d4:	test   rax,rax
    50d7:	jne    50fb <botlish_fn_49+0x3b3>
    50dd:	mov    rdi,r12
    50e0:	jmp    51f2 <botlish_fn_49+0x4aa>
    50e5:	mov    rdx,r8
    50e8:	mov    rsi,r14
    50eb:	mov    eax,0x2
    50f0:	cmp    rsi,rdx
    50f3:	cmove  rax,QWORD PTR [rip+0x18d]        # 5288 <botlish_fn_49+0x540>
    50fb:	cmp    rax,0x6
    50ff:	je     510d <botlish_fn_49+0x3c5>
    5105:	mov    rdi,r12
    5108:	jmp    5223 <botlish_fn_49+0x4db>
    510d:	mov    QWORD PTR [rsp+0x8],0x9
    5116:	mov    rsi,r13
    5119:	mov    rdi,r12
    511c:	call   5121 <botlish_fn_49+0x3d9>
			511d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    5121:	test   rax,rax
    5124:	jne    5132 <botlish_fn_49+0x3ea>
    512a:	mov    rdi,r12
    512d:	jmp    51f2 <botlish_fn_49+0x4aa>
    5132:	mov    QWORD PTR [rsp+0x10],rax
    5137:	mov    QWORD PTR [rsp+0x18],0x3
    5140:	mov    ecx,0x1
    5145:	test   rax,0x1
    514b:	je     5159 <botlish_fn_49+0x411>
    5151:	mov    rsi,rax
    5154:	jmp    517d <botlish_fn_49+0x435>
    5159:	xor    ecx,ecx
    515b:	test   rax,0x7
    5161:	je     516f <botlish_fn_49+0x427>
    5167:	mov    rsi,rax
    516a:	jmp    517d <botlish_fn_49+0x435>
    516f:	movzx  rcx,BYTE PTR [rax]
    5173:	mov    rsi,rax
    5176:	rex cmp cl,0x1
    517a:	sete   cl
    517d:	test   cl,cl
    517f:	jne    51a0 <botlish_fn_49+0x458>
    5185:	mov    rdi,r12
    5188:	mov    rax,QWORD PTR [rdi+0x10]
    518c:	mov    rcx,QWORD PTR [rax+0x48]
    5190:	xor    rdx,rdx
    5193:	call   5198 <botlish_fn_49+0x450>
			5194: R_X86_64_PLT32	rt_type_error-0x4
    5198:	mov    rdi,r12
    519b:	jmp    51f2 <botlish_fn_49+0x4aa>
    51a0:	test   rsi,0x1
    51a7:	je     51c6 <botlish_fn_49+0x47e>
    51ad:	mov    rcx,rsi
    51b0:	sub    rcx,0x3
    51b4:	seto   al
    51b7:	add    rcx,0x1
    51be:	test   al,al
    51c0:	je     51d6 <botlish_fn_49+0x48e>
    51c6:	mov    edx,0x3
    51cb:	mov    rdi,r12
    51ce:	call   51d3 <botlish_fn_49+0x48b>
			51cf: R_X86_64_PLT32	rt_int_sub-0x4
    51d3:	mov    rcx,rax
    51d6:	mov    edx,0x9
    51db:	mov    rsi,r13
    51de:	mov    rdi,r12
    51e1:	call   51e6 <botlish_fn_49+0x49e>
			51e2: R_X86_64_PLT32	rt_mutarray_set-0x4
    51e6:	test   rax,rax
    51e9:	jne    5220 <botlish_fn_49+0x4d8>
    51ef:	mov    rdi,r12
    51f2:	mov    rdi,r12
    51f5:	mov    QWORD PTR [rdi],rbx
    51f8:	xor    rax,rax
    51fb:	mov    rbx,QWORD PTR [rsp+0x50]
    5200:	mov    r12,QWORD PTR [rsp+0x58]
    5205:	mov    r13,QWORD PTR [rsp+0x60]
    520a:	mov    r14,QWORD PTR [rsp+0x68]
    520f:	mov    r15,QWORD PTR [rsp+0x70]
    5214:	add    rsp,0x80
    521b:	mov    rsp,rbp
    521e:	pop    rbp
    521f:	ret
    5220:	mov    rdi,r12
    5223:	mov    rdi,r12
    5226:	mov    QWORD PTR [rdi],rbx
    5229:	mov    eax,0xa
    522e:	mov    rbx,QWORD PTR [rsp+0x50]
    5233:	mov    r12,QWORD PTR [rsp+0x58]
    5238:	mov    r13,QWORD PTR [rsp+0x60]
    523d:	mov    r14,QWORD PTR [rsp+0x68]
    5242:	mov    r15,QWORD PTR [rsp+0x70]
    5247:	add    rsp,0x80
    524e:	mov    rsp,rbp
    5251:	pop    rbp
    5252:	ret
    5253:	mov    r12,rdi
    5256:	call   525b <botlish_fn_49+0x513>
			5257: R_X86_64_PLT32	rt_stack_overflow-0x4
    525b:	xor    rax,rax
    525e:	mov    rbx,QWORD PTR [rsp+0x50]
    5263:	mov    r12,QWORD PTR [rsp+0x58]
    5268:	mov    r13,QWORD PTR [rsp+0x60]
    526d:	mov    r14,QWORD PTR [rsp+0x68]
    5272:	mov    r15,QWORD PTR [rsp+0x70]
    5277:	add    rsp,0x80
    527e:	mov    rsp,rbp
    5281:	pop    rbp
    5282:	ret
    5283:	add    BYTE PTR [rax],al
    5285:	add    BYTE PTR [rax],al
    5287:	add    BYTE PTR [rsi],al
    5289:	add    BYTE PTR [rax],al
    528b:	add    BYTE PTR [rax],al
    528d:	add    BYTE PTR [rax],al
	...

0000000000005290 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    5290:	push   rbp
    5291:	mov    rbp,rsp
    5294:	mov    rsi,QWORD PTR [rdx]
    5297:	mov    r9,QWORD PTR [rdx+0x8]
    529b:	mov    rcx,QWORD PTR [rdx+0x10]
    529f:	mov    r8,QWORD PTR [rdx+0x18]
    52a3:	mov    rdx,r9
    52a6:	call   52ab <botlish_entry_49+0x1b>
			52a7: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    52ab:	mov    rsp,rbp
    52ae:	pop    rbp
    52af:	ret

00000000000052b0 <botlish_fn_50: ht_set<mutarray, any, any>>:
    52b0:	push   rbp
    52b1:	mov    rbp,rsp
    52b4:	sub    rsp,0x70
    52b8:	mov    QWORD PTR [rsp+0x40],rbx
    52bd:	mov    QWORD PTR [rsp+0x48],r12
    52c2:	mov    QWORD PTR [rsp+0x50],r13
    52c7:	mov    QWORD PTR [rsp+0x58],r14
    52cc:	mov    QWORD PTR [rsp+0x60],r15
    52d1:	mov    rbx,QWORD PTR [rdi]
    52d4:	mov    rax,QWORD PTR [rdi+0x8]
    52d8:	lea    r8,[rbx+0x8]
    52dc:	cmp    r8,rax
    52df:	ja     569d <botlish_fn_50+0x3ed>
    52e5:	lea    rax,[rbx+0x8]
    52e9:	mov    QWORD PTR [rdi],rax
    52ec:	mov    r12,rdi
    52ef:	mov    QWORD PTR [rbx],0x0
    52f6:	mov    QWORD PTR [rsp+0x18],0x0
    52ff:	mov    QWORD PTR [rsp+0x20],0x0
    5308:	mov    QWORD PTR [rsp],rsi
    530c:	mov    r15,rsi
    530f:	mov    QWORD PTR [rsp+0x8],rdx
    5314:	mov    r14,rdx
    5317:	mov    QWORD PTR [rsp+0x10],rcx
    531c:	mov    r13,rcx
    531f:	mov    rdx,r14
    5322:	mov    rsi,r15
    5325:	mov    rdi,r12
    5328:	call   532d <botlish_fn_50+0x7d>
			5329: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    532d:	test   rax,rax
    5330:	jne    533e <botlish_fn_50+0x8e>
    5336:	mov    rdi,r12
    5339:	jmp    5645 <botlish_fn_50+0x395>
    533e:	mov    QWORD PTR [rsp+0x18],rax
    5343:	mov    rcx,rax
    5346:	mov    r8,0xffffffffffffffff
    534d:	mov    QWORD PTR [rsp+0x38],r8
    5352:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    535b:	mov    rdx,r14
    535e:	mov    rsi,r15
    5361:	mov    rdi,r12
    5364:	call   5369 <botlish_fn_50+0xb9>
			5365: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    5369:	mov    rcx,rax
    536c:	mov    QWORD PTR [rsp+0x30],rax
    5371:	test   rax,rcx
    5374:	jne    5382 <botlish_fn_50+0xd2>
    537a:	mov    rdi,r12
    537d:	jmp    5645 <botlish_fn_50+0x395>
    5382:	mov    rax,QWORD PTR [rsp+0x30]
    5387:	mov    QWORD PTR [rsp+0x18],rax
    538c:	mov    rsi,r15
    538f:	mov    rdi,r12
    5392:	call   5397 <botlish_fn_50+0xe7>
			5393: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    5397:	test   rax,rax
    539a:	jne    53a8 <botlish_fn_50+0xf8>
    53a0:	mov    rdi,r12
    53a3:	jmp    5645 <botlish_fn_50+0x395>
    53a8:	xor    ecx,ecx
    53aa:	test   rax,0x7
    53b0:	je     53be <botlish_fn_50+0x10e>
    53b6:	mov    rsi,rax
    53b9:	jmp    53cc <botlish_fn_50+0x11c>
    53be:	movzx  rcx,BYTE PTR [rax]
    53c2:	mov    rsi,rax
    53c5:	rex cmp cl,0x8
    53c9:	sete   cl
    53cc:	test   cl,cl
    53ce:	jne    53f1 <botlish_fn_50+0x141>
    53d4:	mov    rdi,r12
    53d7:	mov    rax,QWORD PTR [rdi+0x10]
    53db:	mov    rcx,QWORD PTR [rax+0x20]
    53df:	mov    edx,0x8
    53e4:	call   53e9 <botlish_fn_50+0x139>
			53e5: R_X86_64_PLT32	rt_type_error-0x4
    53e9:	mov    rdi,r12
    53ec:	jmp    5645 <botlish_fn_50+0x395>
    53f1:	mov    rdx,QWORD PTR [rsp+0x30]
    53f6:	mov    rdi,r12
    53f9:	call   53fe <botlish_fn_50+0x14e>
			53fa: R_X86_64_PLT32	rt_mutarray_get-0x4
    53fe:	test   rax,rax
    5401:	jne    540f <botlish_fn_50+0x15f>
    5407:	mov    rdi,r12
    540a:	jmp    5645 <botlish_fn_50+0x395>
    540f:	mov    QWORD PTR [rsp+0x20],rax
    5414:	mov    QWORD PTR [rsp+0x28],rax
    5419:	mov    rdi,r12
    541c:	call   5421 <botlish_fn_50+0x171>
			541d: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    5421:	test   rax,rax
    5424:	jne    5432 <botlish_fn_50+0x182>
    542a:	mov    rdi,r12
    542d:	jmp    5645 <botlish_fn_50+0x395>
    5432:	mov    rcx,QWORD PTR [rsp+0x28]
    5437:	mov    rdx,rcx
    543a:	and    rdx,rax
    543d:	test   rdx,0x1
    5444:	jne    546b <botlish_fn_50+0x1bb>
    544a:	mov    rdx,rax
    544d:	mov    rsi,QWORD PTR [rsp+0x28]
    5452:	mov    rdi,r12
    5455:	call   545a <botlish_fn_50+0x1aa>
			5456: R_X86_64_PLT32	rt_value_eq-0x4
    545a:	test   rax,rax
    545d:	jne    5483 <botlish_fn_50+0x1d3>
    5463:	mov    rdi,r12
    5466:	jmp    5645 <botlish_fn_50+0x395>
    546b:	mov    rdx,rax
    546e:	mov    rsi,QWORD PTR [rsp+0x28]
    5473:	mov    eax,0x2
    5478:	cmp    rsi,rdx
    547b:	cmove  rax,QWORD PTR [rip+0x24d]        # 56d0 <botlish_fn_50+0x420>
    5483:	cmp    rax,0x6
    5487:	je     55c4 <botlish_fn_50+0x314>
    548d:	mov    rsi,r15
    5490:	mov    rdi,r12
    5493:	call   5498 <botlish_fn_50+0x1e8>
			5494: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    5498:	test   rax,rax
    549b:	jne    54a9 <botlish_fn_50+0x1f9>
    54a1:	mov    rdi,r12
    54a4:	jmp    5645 <botlish_fn_50+0x395>
    54a9:	cmp    rax,0x6
    54ad:	je     5502 <botlish_fn_50+0x252>
    54b3:	mov    rcx,r14
    54b6:	mov    rdx,QWORD PTR [rsp+0x30]
    54bb:	mov    rsi,r15
    54be:	mov    r8,r13
    54c1:	mov    rdi,r12
    54c4:	call   54c9 <botlish_fn_50+0x219>
			54c5: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    54c9:	test   rax,rax
    54cc:	jne    54da <botlish_fn_50+0x22a>
    54d2:	mov    rdi,r12
    54d5:	jmp    5645 <botlish_fn_50+0x395>
    54da:	mov    rdi,r12
    54dd:	mov    QWORD PTR [rdi],rbx
    54e0:	mov    rbx,QWORD PTR [rsp+0x40]
    54e5:	mov    r12,QWORD PTR [rsp+0x48]
    54ea:	mov    r13,QWORD PTR [rsp+0x50]
    54ef:	mov    r14,QWORD PTR [rsp+0x58]
    54f4:	mov    r15,QWORD PTR [rsp+0x60]
    54f9:	add    rsp,0x70
    54fd:	mov    rsp,rbp
    5500:	pop    rbp
    5501:	ret
    5502:	mov    rsi,r15
    5505:	mov    rdi,r12
    5508:	call   550d <botlish_fn_50+0x25d>
			5509: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    550d:	test   rax,rax
    5510:	jne    551e <botlish_fn_50+0x26e>
    5516:	mov    rdi,r12
    5519:	jmp    5645 <botlish_fn_50+0x395>
    551e:	mov    rdx,r14
    5521:	mov    rsi,r15
    5524:	mov    rdi,r12
    5527:	call   552c <botlish_fn_50+0x27c>
			5528: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    552c:	test   rax,rax
    552f:	jne    553d <botlish_fn_50+0x28d>
    5535:	mov    rdi,r12
    5538:	jmp    5645 <botlish_fn_50+0x395>
    553d:	mov    QWORD PTR [rsp+0x18],rax
    5542:	mov    rcx,rax
    5545:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    554e:	mov    r8,QWORD PTR [rsp+0x38]
    5553:	mov    rdx,r14
    5556:	mov    rsi,r15
    5559:	mov    rdi,r12
    555c:	call   5561 <botlish_fn_50+0x2b1>
			555d: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    5561:	test   rax,rax
    5564:	jne    5572 <botlish_fn_50+0x2c2>
    556a:	mov    rdi,r12
    556d:	jmp    5645 <botlish_fn_50+0x395>
    5572:	mov    QWORD PTR [rsp+0x18],rax
    5577:	mov    rcx,r14
    557a:	mov    rdx,rax
    557d:	mov    rsi,r15
    5580:	mov    r8,r13
    5583:	mov    rdi,r12
    5586:	call   558b <botlish_fn_50+0x2db>
			5587: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    558b:	test   rax,rax
    558e:	jne    559c <botlish_fn_50+0x2ec>
    5594:	mov    rdi,r12
    5597:	jmp    5645 <botlish_fn_50+0x395>
    559c:	mov    rdi,r12
    559f:	mov    QWORD PTR [rdi],rbx
    55a2:	mov    rbx,QWORD PTR [rsp+0x40]
    55a7:	mov    r12,QWORD PTR [rsp+0x48]
    55ac:	mov    r13,QWORD PTR [rsp+0x50]
    55b1:	mov    r14,QWORD PTR [rsp+0x58]
    55b6:	mov    r15,QWORD PTR [rsp+0x60]
    55bb:	add    rsp,0x70
    55bf:	mov    rsp,rbp
    55c2:	pop    rbp
    55c3:	ret
    55c4:	mov    rsi,r15
    55c7:	mov    rdi,r12
    55ca:	call   55cf <botlish_fn_50+0x31f>
			55cb: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    55cf:	test   rax,rax
    55d2:	jne    55e0 <botlish_fn_50+0x330>
    55d8:	mov    rdi,r12
    55db:	jmp    5645 <botlish_fn_50+0x395>
    55e0:	xor    ecx,ecx
    55e2:	test   rax,0x7
    55e8:	je     55f6 <botlish_fn_50+0x346>
    55ee:	mov    rsi,rax
    55f1:	jmp    5604 <botlish_fn_50+0x354>
    55f6:	movzx  rdi,BYTE PTR [rax]
    55fa:	mov    rsi,rax
    55fd:	cmp    dil,0x8
    5601:	sete   cl
    5604:	test   cl,cl
    5606:	jne    5629 <botlish_fn_50+0x379>
    560c:	mov    rdi,r12
    560f:	mov    r11,QWORD PTR [rdi+0x10]
    5613:	mov    rcx,QWORD PTR [r11+0x40]
    5617:	mov    edx,0x8
    561c:	call   5621 <botlish_fn_50+0x371>
			561d: R_X86_64_PLT32	rt_type_error-0x4
    5621:	mov    rdi,r12
    5624:	jmp    5645 <botlish_fn_50+0x395>
    5629:	mov    rcx,r13
    562c:	mov    rdx,QWORD PTR [rsp+0x30]
    5631:	mov    rdi,r12
    5634:	call   5639 <botlish_fn_50+0x389>
			5635: R_X86_64_PLT32	rt_mutarray_set-0x4
    5639:	test   rax,rax
    563c:	jne    5670 <botlish_fn_50+0x3c0>
    5642:	mov    rdi,r12
    5645:	mov    rdi,r12
    5648:	mov    QWORD PTR [rdi],rbx
    564b:	xor    rax,rax
    564e:	mov    rbx,QWORD PTR [rsp+0x40]
    5653:	mov    r12,QWORD PTR [rsp+0x48]
    5658:	mov    r13,QWORD PTR [rsp+0x50]
    565d:	mov    r14,QWORD PTR [rsp+0x58]
    5662:	mov    r15,QWORD PTR [rsp+0x60]
    5667:	add    rsp,0x70
    566b:	mov    rsp,rbp
    566e:	pop    rbp
    566f:	ret
    5670:	mov    rdi,r12
    5673:	mov    QWORD PTR [rdi],rbx
    5676:	mov    eax,0xa
    567b:	mov    rbx,QWORD PTR [rsp+0x40]
    5680:	mov    r12,QWORD PTR [rsp+0x48]
    5685:	mov    r13,QWORD PTR [rsp+0x50]
    568a:	mov    r14,QWORD PTR [rsp+0x58]
    568f:	mov    r15,QWORD PTR [rsp+0x60]
    5694:	add    rsp,0x70
    5698:	mov    rsp,rbp
    569b:	pop    rbp
    569c:	ret
    569d:	mov    r12,rdi
    56a0:	call   56a5 <botlish_fn_50+0x3f5>
			56a1: R_X86_64_PLT32	rt_stack_overflow-0x4
    56a5:	xor    rax,rax
    56a8:	mov    rbx,QWORD PTR [rsp+0x40]
    56ad:	mov    r12,QWORD PTR [rsp+0x48]
    56b2:	mov    r13,QWORD PTR [rsp+0x50]
    56b7:	mov    r14,QWORD PTR [rsp+0x58]
    56bc:	mov    r15,QWORD PTR [rsp+0x60]
    56c1:	add    rsp,0x70
    56c5:	mov    rsp,rbp
    56c8:	pop    rbp
    56c9:	ret
    56ca:	add    BYTE PTR [rax],al
    56cc:	add    BYTE PTR [rax],al
    56ce:	add    BYTE PTR [rax],al
    56d0:	(bad)
    56d1:	add    BYTE PTR [rax],al
    56d3:	add    BYTE PTR [rax],al
    56d5:	add    BYTE PTR [rax],al
	...

00000000000056d8 <botlish_entry_50: ht_set<mutarray, any, any>>:
    56d8:	push   rbp
    56d9:	mov    rbp,rsp
    56dc:	mov    rsi,QWORD PTR [rdx]
    56df:	mov    r8,QWORD PTR [rdx+0x8]
    56e3:	mov    rcx,QWORD PTR [rdx+0x10]
    56e7:	mov    rdx,r8
    56ea:	call   56ef <botlish_entry_50+0x17>
			56eb: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    56ef:	mov    rsp,rbp
    56f2:	pop    rbp
    56f3:	ret

00000000000056f4 <botlish_fn_51: row_new<bool, int>>:
    56f4:	push   rbp
    56f5:	mov    rbp,rsp
    56f8:	sub    rsp,0x20
    56fc:	mov    QWORD PTR [rsp+0x10],r14
    5701:	mov    QWORD PTR [rsp+0x18],r15
    5706:	mov    r14,QWORD PTR [rdi]
    5709:	mov    rax,QWORD PTR [rdi+0x8]
    570d:	lea    rcx,[r14+0x8]
    5711:	cmp    rcx,rax
    5714:	ja     57ba <botlish_fn_51+0xc6>
    571a:	lea    rax,[r14+0x8]
    571e:	mov    QWORD PTR [rdi],rax
    5721:	mov    r15,rdi
    5724:	mov    QWORD PTR [r14],0x0
    572b:	mov    QWORD PTR [rsp],rdx
    572f:	mov    rax,rdx
    5732:	cmp    rsi,0x6
    5736:	je     576e <botlish_fn_51+0x7a>
    573c:	mov    rdi,r15
    573f:	call   5744 <botlish_fn_51+0x50>
			5740: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    5744:	test   rax,rax
    5747:	jne    5755 <botlish_fn_51+0x61>
    574d:	mov    rdi,r15
    5750:	jmp    5785 <botlish_fn_51+0x91>
    5755:	mov    rdi,r15
    5758:	mov    QWORD PTR [rdi],r14
    575b:	mov    r14,QWORD PTR [rsp+0x10]
    5760:	mov    r15,QWORD PTR [rsp+0x18]
    5765:	add    rsp,0x20
    5769:	mov    rsp,rbp
    576c:	pop    rbp
    576d:	ret
    576e:	mov    rsi,rax
    5771:	mov    rdi,r15
    5774:	call   5779 <botlish_fn_51+0x85>
			5775: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    5779:	test   rax,rax
    577c:	jne    57a1 <botlish_fn_51+0xad>
    5782:	mov    rdi,r15
    5785:	mov    rdi,r15
    5788:	mov    QWORD PTR [rdi],r14
    578b:	xor    rax,rax
    578e:	mov    r14,QWORD PTR [rsp+0x10]
    5793:	mov    r15,QWORD PTR [rsp+0x18]
    5798:	add    rsp,0x20
    579c:	mov    rsp,rbp
    579f:	pop    rbp
    57a0:	ret
    57a1:	mov    rdi,r15
    57a4:	mov    QWORD PTR [rdi],r14
    57a7:	mov    r14,QWORD PTR [rsp+0x10]
    57ac:	mov    r15,QWORD PTR [rsp+0x18]
    57b1:	add    rsp,0x20
    57b5:	mov    rsp,rbp
    57b8:	pop    rbp
    57b9:	ret
    57ba:	mov    r15,rdi
    57bd:	call   57c2 <botlish_fn_51+0xce>
			57be: R_X86_64_PLT32	rt_stack_overflow-0x4
    57c2:	xor    rax,rax
    57c5:	mov    r14,QWORD PTR [rsp+0x10]
    57ca:	mov    r15,QWORD PTR [rsp+0x18]
    57cf:	add    rsp,0x20
    57d3:	mov    rsp,rbp
    57d6:	pop    rbp
    57d7:	ret

00000000000057d8 <botlish_entry_51: row_new<bool, int>>:
    57d8:	push   rbp
    57d9:	mov    rbp,rsp
    57dc:	mov    rsi,QWORD PTR [rdx]
    57df:	mov    rdx,QWORD PTR [rdx+0x8]
    57e3:	call   57e8 <botlish_entry_51+0x10>
			57e4: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    57e8:	mov    rsp,rbp
    57eb:	pop    rbp
    57ec:	ret
    57ed:	add    BYTE PTR [rax],al
	...

00000000000057f0 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    57f0:	push   rbp
    57f1:	mov    rbp,rsp
    57f4:	sub    rsp,0x80
    57fb:	mov    QWORD PTR [rsp+0x50],rbx
    5800:	mov    QWORD PTR [rsp+0x58],r12
    5805:	mov    QWORD PTR [rsp+0x60],r13
    580a:	mov    QWORD PTR [rsp+0x68],r14
    580f:	mov    QWORD PTR [rsp+0x70],r15
    5814:	mov    r10,r9
    5817:	mov    r13,rdx
    581a:	mov    r15,QWORD PTR [rdi]
    581d:	mov    rax,QWORD PTR [rdi+0x8]
    5821:	lea    rdx,[r15+0x8]
    5825:	cmp    rdx,rax
    5828:	ja     5aed <botlish_fn_52+0x2fd>
    582e:	lea    rdx,[r15+0x8]
    5832:	mov    QWORD PTR [rdi],rdx
    5835:	mov    QWORD PTR [rsp+0x30],rdi
    583a:	mov    QWORD PTR [r15],0x0
    5841:	mov    QWORD PTR [rsp],rsi
    5845:	mov    rdx,r13
    5848:	mov    r14,rsi
    584b:	mov    QWORD PTR [rsp+0x8],rdx
    5850:	mov    QWORD PTR [rsp+0x10],rcx
    5855:	mov    QWORD PTR [rsp+0x38],rcx
    585a:	mov    QWORD PTR [rsp+0x18],r8
    585f:	mov    r9,r8
    5862:	mov    rbx,r10
    5865:	mov    r8,rbx
    5868:	or     r8,0x1
    586c:	mov    r12,r9
    586f:	and    r9,r8
    5872:	test   r9,0x1
    5879:	jne    58a8 <botlish_fn_52+0xb8>
    587f:	mov    rdx,rbx
    5882:	or     rdx,0x1
    5886:	mov    rsi,r12
    5889:	mov    rdi,QWORD PTR [rsp+0x30]
    588e:	call   5893 <botlish_fn_52+0xa3>
			588f: R_X86_64_PLT32	rt_int_cmp-0x4
    5893:	mov    ecx,0x2
    5898:	test   rax,rax
    589b:	cmovge rcx,QWORD PTR [rip+0x27d]        # 5b20 <botlish_fn_52+0x330>
    58a3:	jmp    58bf <botlish_fn_52+0xcf>
    58a8:	mov    rax,rbx
    58ab:	or     rax,0x1
    58af:	mov    ecx,0x2
    58b4:	cmp    r12,rax
    58b7:	cmovge rcx,QWORD PTR [rip+0x261]        # 5b20 <botlish_fn_52+0x330>
    58bf:	cmp    rcx,0x6
    58c3:	je     5abd <botlish_fn_52+0x2cd>
    58c9:	xor    ecx,ecx
    58cb:	mov    rdx,r13
    58ce:	test   rdx,0x7
    58d5:	jne    58e7 <botlish_fn_52+0xf7>
    58db:	mov    rdx,r13
    58de:	movzx  rax,BYTE PTR [rdx]
    58e2:	cmp    al,0x3
    58e4:	sete   cl
    58e7:	test   cl,cl
    58e9:	jne    5913 <botlish_fn_52+0x123>
    58ef:	mov    rdi,QWORD PTR [rsp+0x30]
    58f4:	mov    rax,QWORD PTR [rdi+0x10]
    58f8:	mov    rcx,QWORD PTR [rax+0x50]
    58fc:	mov    edx,0x4
    5901:	mov    rsi,r13
    5904:	call   5909 <botlish_fn_52+0x119>
			5905: R_X86_64_PLT32	rt_type_error-0x4
    5909:	mov    rdi,QWORD PTR [rsp+0x30]
    590e:	jmp    5a5c <botlish_fn_52+0x26c>
    5913:	mov    rsi,r13
    5916:	test   r12,0x1
    591d:	jne    592b <botlish_fn_52+0x13b>
    5923:	mov    r13,rsi
    5926:	jmp    5941 <botlish_fn_52+0x151>
    592b:	mov    rax,QWORD PTR [rsi+0x8]
    592f:	mov    r13,rsi
    5932:	mov    rcx,r12
    5935:	sar    rcx,1
    5938:	cmp    rcx,rax
    593b:	jb     596c <botlish_fn_52+0x17c>
    5941:	mov    rdx,r12
    5944:	mov    rsi,r13
    5947:	mov    rdi,QWORD PTR [rsp+0x30]
    594c:	call   5951 <botlish_fn_52+0x161>
			594d: R_X86_64_PLT32	rt_list_get-0x4
    5951:	test   rax,rax
    5954:	jne    5964 <botlish_fn_52+0x174>
    595a:	mov    rdi,QWORD PTR [rsp+0x30]
    595f:	jmp    5a5c <botlish_fn_52+0x26c>
    5964:	mov    rdx,rax
    5967:	jmp    5974 <botlish_fn_52+0x184>
    596c:	mov    rax,QWORD PTR [r13+0x10]
    5970:	mov    rdx,QWORD PTR [rax+rcx*8]
    5974:	mov    QWORD PTR [rsp+0x20],rdx
    5979:	mov    QWORD PTR [rsp+0x40],rdx
    597e:	xor    ecx,ecx
    5980:	mov    rdx,QWORD PTR [rsp+0x38]
    5985:	test   rdx,0x7
    598c:	je     599c <botlish_fn_52+0x1ac>
    5992:	mov    QWORD PTR [rsp+0x38],rdx
    5997:	jmp    59aa <botlish_fn_52+0x1ba>
    599c:	movzx  rax,BYTE PTR [rdx]
    59a0:	mov    QWORD PTR [rsp+0x38],rdx
    59a5:	cmp    al,0x3
    59a7:	sete   cl
    59aa:	test   cl,cl
    59ac:	jne    59d8 <botlish_fn_52+0x1e8>
    59b2:	mov    rdi,QWORD PTR [rsp+0x30]
    59b7:	mov    rax,QWORD PTR [rdi+0x10]
    59bb:	mov    rcx,QWORD PTR [rax+0x50]
    59bf:	mov    edx,0x4
    59c4:	mov    rsi,QWORD PTR [rsp+0x38]
    59c9:	call   59ce <botlish_fn_52+0x1de>
			59ca: R_X86_64_PLT32	rt_type_error-0x4
    59ce:	mov    rdi,QWORD PTR [rsp+0x30]
    59d3:	jmp    5a5c <botlish_fn_52+0x26c>
    59d8:	test   r12,0x1
    59df:	je     59fd <botlish_fn_52+0x20d>
    59e5:	mov    rsi,QWORD PTR [rsp+0x38]
    59ea:	mov    rcx,QWORD PTR [rsi+0x8]
    59ee:	mov    rax,r12
    59f1:	sar    rax,1
    59f4:	cmp    rax,rcx
    59f7:	jb     5a2a <botlish_fn_52+0x23a>
    59fd:	mov    rdx,r12
    5a00:	mov    rsi,QWORD PTR [rsp+0x38]
    5a05:	mov    rdi,QWORD PTR [rsp+0x30]
    5a0a:	call   5a0f <botlish_fn_52+0x21f>
			5a0b: R_X86_64_PLT32	rt_list_get-0x4
    5a0f:	test   rax,rax
    5a12:	jne    5a22 <botlish_fn_52+0x232>
    5a18:	mov    rdi,QWORD PTR [rsp+0x30]
    5a1d:	jmp    5a5c <botlish_fn_52+0x26c>
    5a22:	mov    rcx,rax
    5a25:	jmp    5a37 <botlish_fn_52+0x247>
    5a2a:	mov    rsi,QWORD PTR [rsp+0x38]
    5a2f:	mov    rcx,QWORD PTR [rsi+0x10]
    5a33:	mov    rcx,QWORD PTR [rcx+rax*8]
    5a37:	mov    QWORD PTR [rsp+0x28],rcx
    5a3c:	mov    rdx,QWORD PTR [rsp+0x40]
    5a41:	mov    rsi,r14
    5a44:	mov    rdi,QWORD PTR [rsp+0x30]
    5a49:	call   5a4e <botlish_fn_52+0x25e>
			5a4a: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    5a4e:	test   rax,rax
    5a51:	jne    5a8c <botlish_fn_52+0x29c>
    5a57:	mov    rdi,QWORD PTR [rsp+0x30]
    5a5c:	mov    rdi,QWORD PTR [rsp+0x30]
    5a61:	mov    QWORD PTR [rdi],r15
    5a64:	xor    rax,rax
    5a67:	mov    rbx,QWORD PTR [rsp+0x50]
    5a6c:	mov    r12,QWORD PTR [rsp+0x58]
    5a71:	mov    r13,QWORD PTR [rsp+0x60]
    5a76:	mov    r14,QWORD PTR [rsp+0x68]
    5a7b:	mov    r15,QWORD PTR [rsp+0x70]
    5a80:	add    rsp,0x80
    5a87:	mov    rsp,rbp
    5a8a:	pop    rbp
    5a8b:	ret
    5a8c:	mov    QWORD PTR [rsp],r14
    5a90:	mov    QWORD PTR [rsp+0x8],r13
    5a95:	mov    rsi,QWORD PTR [rsp+0x38]
    5a9a:	mov    QWORD PTR [rsp+0x10],rsi
    5a9f:	sar    r12,1
    5aa2:	add    r12,0x1
    5aa9:	shl    r12,1
    5aac:	or     r12,0x1
    5ab0:	mov    QWORD PTR [rsp+0x18],r12
    5ab5:	mov    r9,r12
    5ab8:	jmp    5865 <botlish_fn_52+0x75>
    5abd:	mov    rdi,QWORD PTR [rsp+0x30]
    5ac2:	mov    QWORD PTR [rdi],r15
    5ac5:	mov    rax,r14
    5ac8:	mov    rbx,QWORD PTR [rsp+0x50]
    5acd:	mov    r12,QWORD PTR [rsp+0x58]
    5ad2:	mov    r13,QWORD PTR [rsp+0x60]
    5ad7:	mov    r14,QWORD PTR [rsp+0x68]
    5adc:	mov    r15,QWORD PTR [rsp+0x70]
    5ae1:	add    rsp,0x80
    5ae8:	mov    rsp,rbp
    5aeb:	pop    rbp
    5aec:	ret
    5aed:	mov    QWORD PTR [rsp+0x30],rdi
    5af2:	call   5af7 <botlish_fn_52+0x307>
			5af3: R_X86_64_PLT32	rt_stack_overflow-0x4
    5af7:	xor    rax,rax
    5afa:	mov    rbx,QWORD PTR [rsp+0x50]
    5aff:	mov    r12,QWORD PTR [rsp+0x58]
    5b04:	mov    r13,QWORD PTR [rsp+0x60]
    5b09:	mov    r14,QWORD PTR [rsp+0x68]
    5b0e:	mov    r15,QWORD PTR [rsp+0x70]
    5b13:	add    rsp,0x80
    5b1a:	mov    rsp,rbp
    5b1d:	pop    rbp
    5b1e:	ret
    5b1f:	add    BYTE PTR [rsi],al
    5b21:	add    BYTE PTR [rax],al
    5b23:	add    BYTE PTR [rax],al
    5b25:	add    BYTE PTR [rax],al
	...

0000000000005b28 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    5b28:	push   rbp
    5b29:	mov    rbp,rsp
    5b2c:	mov    rsi,QWORD PTR [rdx]
    5b2f:	mov    r10,QWORD PTR [rdx+0x8]
    5b33:	mov    rcx,QWORD PTR [rdx+0x10]
    5b37:	mov    r8,QWORD PTR [rdx+0x18]
    5b3b:	mov    r9,QWORD PTR [rdx+0x20]
    5b3f:	mov    rdx,r10
    5b42:	call   5b47 <botlish_entry_52+0x1f>
			5b43: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    5b47:	mov    rsp,rbp
    5b4a:	pop    rbp
    5b4b:	ret

0000000000005b4c <botlish_fn_53: row_table<any, int, any, bool>>:
    5b4c:	push   rbp
    5b4d:	mov    rbp,rsp
    5b50:	sub    rsp,0x60
    5b54:	mov    QWORD PTR [rsp+0x30],rbx
    5b59:	mov    QWORD PTR [rsp+0x38],r12
    5b5e:	mov    QWORD PTR [rsp+0x40],r13
    5b63:	mov    QWORD PTR [rsp+0x48],r14
    5b68:	mov    QWORD PTR [rsp+0x50],r15
    5b6d:	mov    rbx,QWORD PTR [rdi]
    5b70:	mov    rax,QWORD PTR [rdi+0x8]
    5b74:	lea    r9,[rbx+0x8]
    5b78:	cmp    r9,rax
    5b7b:	ja     5cb8 <botlish_fn_53+0x16c>
    5b81:	lea    rax,[rbx+0x8]
    5b85:	mov    QWORD PTR [rdi],rax
    5b88:	mov    r12,rdi
    5b8b:	mov    QWORD PTR [rbx],0x0
    5b92:	mov    QWORD PTR [rsp+0x20],0x0
    5b9b:	mov    QWORD PTR [rsp],rsi
    5b9f:	mov    r14,rsi
    5ba2:	mov    QWORD PTR [rsp+0x8],rdx
    5ba7:	mov    QWORD PTR [rsp+0x10],rcx
    5bac:	mov    r13,rcx
    5baf:	mov    QWORD PTR [rsp+0x18],r8
    5bb4:	mov    rsi,r8
    5bb7:	mov    rdi,r12
    5bba:	call   5bbf <botlish_fn_53+0x73>
			5bbb: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    5bbf:	test   rax,rax
    5bc2:	jne    5bd0 <botlish_fn_53+0x84>
    5bc8:	mov    rdi,r12
    5bcb:	jmp    5c65 <botlish_fn_53+0x119>
    5bd0:	mov    QWORD PTR [rsp+0x8],rax
    5bd5:	mov    r15,rax
    5bd8:	mov    QWORD PTR [rsp+0x18],0x1
    5be1:	xor    ecx,ecx
    5be3:	mov    rdx,r13
    5be6:	test   rdx,0x7
    5bed:	je     5bfb <botlish_fn_53+0xaf>
    5bf3:	mov    r13,rdx
    5bf6:	jmp    5c07 <botlish_fn_53+0xbb>
    5bfb:	movzx  rax,BYTE PTR [rdx]
    5bff:	mov    r13,rdx
    5c02:	cmp    al,0x3
    5c04:	sete   cl
    5c07:	test   cl,cl
    5c09:	jne    5c2f <botlish_fn_53+0xe3>
    5c0f:	mov    rdi,r12
    5c12:	mov    rax,QWORD PTR [rdi+0x10]
    5c16:	mov    rcx,QWORD PTR [rax+0x58]
    5c1a:	mov    edx,0x4
    5c1f:	mov    rsi,r13
    5c22:	call   5c27 <botlish_fn_53+0xdb>
			5c23: R_X86_64_PLT32	rt_type_error-0x4
    5c27:	mov    rdi,r12
    5c2a:	jmp    5c65 <botlish_fn_53+0x119>
    5c2f:	mov    rsi,r13
    5c32:	mov    rdi,r12
    5c35:	call   5c3a <botlish_fn_53+0xee>
			5c36: R_X86_64_PLT32	rt_list_len-0x4
    5c3a:	mov    QWORD PTR [rsp+0x20],rax
    5c3f:	mov    r8d,0x1
    5c45:	mov    rcx,r13
    5c48:	mov    rdx,r14
    5c4b:	mov    rsi,r15
    5c4e:	mov    r9,rax
    5c51:	mov    rdi,r12
    5c54:	call   5c59 <botlish_fn_53+0x10d>
			5c55: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    5c59:	test   rax,rax
    5c5c:	jne    5c90 <botlish_fn_53+0x144>
    5c62:	mov    rdi,r12
    5c65:	mov    rdi,r12
    5c68:	mov    QWORD PTR [rdi],rbx
    5c6b:	xor    rax,rax
    5c6e:	mov    rbx,QWORD PTR [rsp+0x30]
    5c73:	mov    r12,QWORD PTR [rsp+0x38]
    5c78:	mov    r13,QWORD PTR [rsp+0x40]
    5c7d:	mov    r14,QWORD PTR [rsp+0x48]
    5c82:	mov    r15,QWORD PTR [rsp+0x50]
    5c87:	add    rsp,0x60
    5c8b:	mov    rsp,rbp
    5c8e:	pop    rbp
    5c8f:	ret
    5c90:	mov    rdi,r12
    5c93:	mov    QWORD PTR [rdi],rbx
    5c96:	mov    rbx,QWORD PTR [rsp+0x30]
    5c9b:	mov    r12,QWORD PTR [rsp+0x38]
    5ca0:	mov    r13,QWORD PTR [rsp+0x40]
    5ca5:	mov    r14,QWORD PTR [rsp+0x48]
    5caa:	mov    r15,QWORD PTR [rsp+0x50]
    5caf:	add    rsp,0x60
    5cb3:	mov    rsp,rbp
    5cb6:	pop    rbp
    5cb7:	ret
    5cb8:	mov    r12,rdi
    5cbb:	call   5cc0 <botlish_fn_53+0x174>
			5cbc: R_X86_64_PLT32	rt_stack_overflow-0x4
    5cc0:	xor    rax,rax
    5cc3:	mov    rbx,QWORD PTR [rsp+0x30]
    5cc8:	mov    r12,QWORD PTR [rsp+0x38]
    5ccd:	mov    r13,QWORD PTR [rsp+0x40]
    5cd2:	mov    r14,QWORD PTR [rsp+0x48]
    5cd7:	mov    r15,QWORD PTR [rsp+0x50]
    5cdc:	add    rsp,0x60
    5ce0:	mov    rsp,rbp
    5ce3:	pop    rbp
    5ce4:	ret

0000000000005ce5 <botlish_entry_53: row_table<any, int, any, bool>>:
    5ce5:	push   rbp
    5ce6:	mov    rbp,rsp
    5ce9:	mov    rsi,QWORD PTR [rdx]
    5cec:	mov    r9,QWORD PTR [rdx+0x8]
    5cf0:	mov    rcx,QWORD PTR [rdx+0x10]
    5cf4:	mov    r8,QWORD PTR [rdx+0x18]
    5cf8:	mov    rdx,r9
    5cfb:	call   5d00 <botlish_entry_53+0x1b>
			5cfc: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    5d00:	mov    rsp,rbp
    5d03:	pop    rbp
    5d04:	ret
    5d05:	add    BYTE PTR [rax],al
	...

0000000000005d08 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    5d08:	push   rbp
    5d09:	mov    rbp,rsp
    5d0c:	sub    rsp,0xa0
    5d13:	mov    QWORD PTR [rsp+0x70],rbx
    5d18:	mov    QWORD PTR [rsp+0x78],r12
    5d1d:	mov    QWORD PTR [rsp+0x80],r13
    5d25:	mov    QWORD PTR [rsp+0x88],r14
    5d2d:	mov    QWORD PTR [rsp+0x90],r15
    5d35:	mov    r15,r8
    5d38:	mov    r11,QWORD PTR [rbp+0x10]
    5d3c:	mov    r12,QWORD PTR [rbp+0x18]
    5d40:	mov    rax,QWORD PTR [rdi]
    5d43:	mov    QWORD PTR [rsp+0x60],rax
    5d48:	mov    rax,QWORD PTR [rdi+0x8]
    5d4c:	mov    r8,QWORD PTR [rsp+0x60]
    5d51:	lea    r10,[r8+0x8]
    5d55:	cmp    r10,rax
    5d58:	ja     5fe2 <botlish_fn_54+0x2da>
    5d5e:	mov    r10,QWORD PTR [rsp+0x60]
    5d63:	lea    rax,[r10+0x8]
    5d67:	mov    QWORD PTR [rdi],rax
    5d6a:	mov    rax,QWORD PTR [rsp+0x60]
    5d6f:	mov    QWORD PTR [rsp+0x40],rdi
    5d74:	mov    QWORD PTR [rax],0x0
    5d7b:	mov    QWORD PTR [rsp+0x30],0x0
    5d84:	mov    QWORD PTR [rsp+0x38],0x0
    5d8d:	mov    QWORD PTR [rsp],rsi
    5d91:	mov    QWORD PTR [rsp+0x8],rdx
    5d96:	mov    rbx,rdx
    5d99:	mov    QWORD PTR [rsp+0x10],rcx
    5d9e:	mov    QWORD PTR [rsp+0x48],rcx
    5da3:	mov    QWORD PTR [rsp+0x18],r9
    5da8:	mov    QWORD PTR [rsp+0x20],r11
    5dad:	mov    QWORD PTR [rsp+0x58],r11
    5db2:	mov    QWORD PTR [rsp+0x28],r12
    5db7:	mov    r13,rsi
    5dba:	mov    QWORD PTR [rsp+0x50],r9
    5dbf:	mov    rsi,r13
    5dc2:	mov    rdi,QWORD PTR [rsp+0x40]
    5dc7:	call   5dcc <botlish_fn_54+0xc4>
			5dc8: R_X86_64_PLT32	rt_list_len-0x4
    5dcc:	mov    r14,rbx
    5dcf:	mov    rcx,r14
    5dd2:	and    rcx,rax
    5dd5:	mov    rdx,rax
    5dd8:	test   rcx,0x1
    5ddf:	jne    5e07 <botlish_fn_54+0xff>
    5de5:	mov    rsi,r14
    5de8:	mov    rdi,QWORD PTR [rsp+0x40]
    5ded:	call   5df2 <botlish_fn_54+0xea>
			5dee: R_X86_64_PLT32	rt_int_cmp-0x4
    5df2:	mov    ecx,0x2
    5df7:	test   rax,rax
    5dfa:	cmovge rcx,QWORD PTR [rip+0x21e]        # 6020 <botlish_fn_54+0x318>
    5e02:	jmp    5e17 <botlish_fn_54+0x10f>
    5e07:	mov    ecx,0x2
    5e0c:	cmp    r14,rdx
    5e0f:	cmovge rcx,QWORD PTR [rip+0x209]        # 6020 <botlish_fn_54+0x318>
    5e17:	cmp    rcx,0x6
    5e1b:	je     5f42 <botlish_fn_54+0x23a>
    5e21:	mov    rbx,r15
    5e24:	mov    rsi,rbx
    5e27:	or     rsi,0x1
    5e2b:	mov    QWORD PTR [rsp+0x30],rsi
    5e30:	test   r14,0x1
    5e37:	je     5e50 <botlish_fn_54+0x148>
    5e3d:	mov    r10,QWORD PTR [r13+0x8]
    5e41:	mov    r9,r14
    5e44:	sar    r9,1
    5e47:	cmp    r9,r10
    5e4a:	jb     5e80 <botlish_fn_54+0x178>
    5e50:	mov    rdx,r14
    5e53:	mov    rsi,r13
    5e56:	mov    rdi,QWORD PTR [rsp+0x40]
    5e5b:	call   5e60 <botlish_fn_54+0x158>
			5e5c: R_X86_64_PLT32	rt_list_get-0x4
    5e60:	test   rax,rax
    5e63:	jne    5e78 <botlish_fn_54+0x170>
    5e69:	mov    rdi,QWORD PTR [rsp+0x40]
    5e6e:	mov    r12,QWORD PTR [rsp+0x60]
    5e73:	jmp    5f69 <botlish_fn_54+0x261>
    5e78:	mov    rcx,rax
    5e7b:	jmp    5e88 <botlish_fn_54+0x180>
    5e80:	mov    rax,QWORD PTR [r13+0x10]
    5e84:	mov    rcx,QWORD PTR [rax+r9*8]
    5e88:	mov    QWORD PTR [rsp+0x38],rcx
    5e8d:	mov    rdx,rbx
    5e90:	or     rdx,0x1
    5e94:	mov    r15,QWORD PTR [rsp+0x48]
    5e99:	mov    rsi,r15
    5e9c:	mov    rdi,QWORD PTR [rsp+0x40]
    5ea1:	mov    r8,r12
    5ea4:	call   5ea9 <botlish_fn_54+0x1a1>
			5ea5: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    5ea9:	test   rax,rax
    5eac:	jne    5ec1 <botlish_fn_54+0x1b9>
    5eb2:	mov    rdi,QWORD PTR [rsp+0x40]
    5eb7:	mov    r12,QWORD PTR [rsp+0x60]
    5ebc:	jmp    5f69 <botlish_fn_54+0x261>
    5ec1:	mov    QWORD PTR [rsp+0x8],rax
    5ec6:	mov    rcx,rax
    5ec9:	sar    r14,1
    5ecc:	add    r14,0x1
    5ed3:	shl    r14,1
    5ed6:	or     r14,0x1
    5eda:	mov    QWORD PTR [rsp+0x30],r14
    5edf:	mov    rdx,QWORD PTR [rsp+0x58]
    5ee4:	mov    rsi,QWORD PTR [rsp+0x50]
    5ee9:	mov    rdi,QWORD PTR [rsp+0x40]
    5eee:	call   5ef3 <botlish_fn_54+0x1eb>
			5eef: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    5ef3:	test   rax,rax
    5ef6:	jne    5f0b <botlish_fn_54+0x203>
    5efc:	mov    rdi,QWORD PTR [rsp+0x40]
    5f01:	mov    r12,QWORD PTR [rsp+0x60]
    5f06:	jmp    5f69 <botlish_fn_54+0x261>
    5f0b:	mov    QWORD PTR [rsp],r13
    5f0f:	mov    QWORD PTR [rsp+0x8],r14
    5f14:	mov    QWORD PTR [rsp+0x10],r15
    5f19:	mov    QWORD PTR [rsp+0x18],rax
    5f1e:	mov    QWORD PTR [rsp+0x20],rdx
    5f23:	mov    QWORD PTR [rsp+0x28],r12
    5f28:	mov    QWORD PTR [rsp+0x58],rdx
    5f2d:	mov    QWORD PTR [rsp+0x50],rax
    5f32:	mov    QWORD PTR [rsp+0x48],r15
    5f37:	mov    r15,rbx
    5f3a:	mov    rbx,r14
    5f3d:	jmp    5dbf <botlish_fn_54+0xb7>
    5f42:	mov    rdx,QWORD PTR [rsp+0x58]
    5f47:	mov    rsi,QWORD PTR [rsp+0x50]
    5f4c:	mov    rdi,QWORD PTR [rsp+0x40]
    5f51:	call   5f56 <botlish_fn_54+0x24e>
			5f52: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    5f56:	test   rax,rax
    5f59:	jne    5fa7 <botlish_fn_54+0x29f>
    5f5f:	mov    rdi,QWORD PTR [rsp+0x40]
    5f64:	mov    r12,QWORD PTR [rsp+0x60]
    5f69:	mov    rdi,QWORD PTR [rsp+0x40]
    5f6e:	mov    r12,QWORD PTR [rsp+0x60]
    5f73:	mov    QWORD PTR [rdi],r12
    5f76:	xor    rax,rax
    5f79:	mov    rbx,QWORD PTR [rsp+0x70]
    5f7e:	mov    r12,QWORD PTR [rsp+0x78]
    5f83:	mov    r13,QWORD PTR [rsp+0x80]
    5f8b:	mov    r14,QWORD PTR [rsp+0x88]
    5f93:	mov    r15,QWORD PTR [rsp+0x90]
    5f9b:	add    rsp,0xa0
    5fa2:	mov    rsp,rbp
    5fa5:	pop    rbp
    5fa6:	ret
    5fa7:	mov    rdi,QWORD PTR [rsp+0x40]
    5fac:	mov    r12,QWORD PTR [rsp+0x60]
    5fb1:	mov    QWORD PTR [rdi],r12
    5fb4:	mov    rbx,QWORD PTR [rsp+0x70]
    5fb9:	mov    r12,QWORD PTR [rsp+0x78]
    5fbe:	mov    r13,QWORD PTR [rsp+0x80]
    5fc6:	mov    r14,QWORD PTR [rsp+0x88]
    5fce:	mov    r15,QWORD PTR [rsp+0x90]
    5fd6:	add    rsp,0xa0
    5fdd:	mov    rsp,rbp
    5fe0:	pop    rbp
    5fe1:	ret
    5fe2:	mov    QWORD PTR [rsp+0x40],rdi
    5fe7:	call   5fec <botlish_fn_54+0x2e4>
			5fe8: R_X86_64_PLT32	rt_stack_overflow-0x4
    5fec:	xor    rax,rax
    5fef:	mov    rbx,QWORD PTR [rsp+0x70]
    5ff4:	mov    r12,QWORD PTR [rsp+0x78]
    5ff9:	mov    r13,QWORD PTR [rsp+0x80]
    6001:	mov    r14,QWORD PTR [rsp+0x88]
    6009:	mov    r15,QWORD PTR [rsp+0x90]
    6011:	add    rsp,0xa0
    6018:	mov    rsp,rbp
    601b:	pop    rbp
    601c:	ret
    601d:	add    BYTE PTR [rax],al
    601f:	add    BYTE PTR [rsi],al
    6021:	add    BYTE PTR [rax],al
    6023:	add    BYTE PTR [rax],al
    6025:	add    BYTE PTR [rax],al
	...

0000000000006028 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    6028:	push   rbp
    6029:	mov    rbp,rsp
    602c:	sub    rsp,0x10
    6030:	mov    rsi,QWORD PTR [rdx]
    6033:	mov    r10,QWORD PTR [rdx+0x8]
    6037:	mov    rcx,QWORD PTR [rdx+0x10]
    603b:	mov    r8,QWORD PTR [rdx+0x18]
    603f:	mov    r9,QWORD PTR [rdx+0x20]
    6043:	mov    r11,QWORD PTR [rdx+0x28]
    6047:	mov    rax,QWORD PTR [rdx+0x30]
    604b:	mov    QWORD PTR [rsp],r11
    604f:	mov    QWORD PTR [rsp+0x8],rax
    6054:	mov    rdx,r10
    6057:	call   605c <botlish_entry_54+0x34>
			6058: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    605c:	add    rsp,0x10
    6060:	mov    rsp,rbp
    6063:	pop    rbp
    6064:	ret

0000000000006065 <botlish_fn_55: csv_records_generic<str, bool>>:
    6065:	push   rbp
    6066:	mov    rbp,rsp
    6069:	sub    rsp,0x80
    6070:	mov    QWORD PTR [rsp+0x50],rbx
    6075:	mov    QWORD PTR [rsp+0x58],r12
    607a:	mov    QWORD PTR [rsp+0x60],r13
    607f:	mov    QWORD PTR [rsp+0x68],r14
    6084:	mov    QWORD PTR [rsp+0x70],r15
    6089:	mov    rbx,QWORD PTR [rdi]
    608c:	mov    rax,QWORD PTR [rdi+0x8]
    6090:	lea    rcx,[rbx+0x8]
    6094:	cmp    rcx,rax
    6097:	ja     62ca <botlish_fn_55+0x265>
    609d:	lea    rax,[rbx+0x8]
    60a1:	mov    QWORD PTR [rdi],rax
    60a4:	mov    r12,rdi
    60a7:	mov    QWORD PTR [rbx],0x0
    60ae:	mov    QWORD PTR [rsp+0x20],0x0
    60b7:	mov    QWORD PTR [rsp+0x28],0x0
    60c0:	mov    QWORD PTR [rsp+0x30],0x0
    60c9:	mov    QWORD PTR [rsp+0x38],0x0
    60d2:	mov    QWORD PTR [rsp+0x40],0x0
    60db:	mov    QWORD PTR [rsp+0x10],rsi
    60e0:	mov    QWORD PTR [rsp+0x18],rdx
    60e5:	mov    r13,rdx
    60e8:	mov    rdi,r12
    60eb:	call   60f0 <botlish_fn_55+0x8b>
			60ec: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    60f0:	mov    rcx,rax
    60f3:	mov    r14,rax
    60f6:	test   rax,rcx
    60f9:	jne    6107 <botlish_fn_55+0xa2>
    60ff:	mov    rdi,r12
    6102:	jmp    6271 <botlish_fn_55+0x20c>
    6107:	mov    rax,r14
    610a:	mov    QWORD PTR [rsp+0x10],rax
    610f:	mov    rsi,r14
    6112:	mov    rdi,r12
    6115:	call   611a <botlish_fn_55+0xb5>
			6116: R_X86_64_PLT32	rt_list_len-0x4
    611a:	sar    rax,1
    611d:	test   rax,rax
    6120:	je     6257 <botlish_fn_55+0x1f2>
    6126:	mov    rax,r14
    6129:	mov    rax,QWORD PTR [rax+0x8]
    612d:	test   rax,rax
    6130:	jne    615f <botlish_fn_55+0xfa>
    6136:	mov    edx,0x1
    613b:	mov    rsi,r14
    613e:	mov    rdi,r12
    6141:	call   6146 <botlish_fn_55+0xe1>
			6142: R_X86_64_PLT32	rt_list_get-0x4
    6146:	test   rax,rax
    6149:	jne    6157 <botlish_fn_55+0xf2>
    614f:	mov    rdi,r12
    6152:	jmp    6271 <botlish_fn_55+0x20c>
    6157:	mov    rsi,rax
    615a:	jmp    616c <botlish_fn_55+0x107>
    615f:	mov    rax,r14
    6162:	mov    rcx,QWORD PTR [rax+0x10]
    6166:	mov    rcx,QWORD PTR [rcx]
    6169:	mov    rsi,rcx
    616c:	mov    QWORD PTR [rsp+0x20],rsi
    6171:	mov    QWORD PTR [rsp+0x28],0x3
    617a:	xor    eax,eax
    617c:	test   rsi,0x7
    6183:	jne    6194 <botlish_fn_55+0x12f>
    6189:	movzx  rdi,BYTE PTR [rsi]
    618d:	cmp    dil,0x3
    6191:	sete   al
    6194:	test   al,al
    6196:	jne    61b9 <botlish_fn_55+0x154>
    619c:	mov    rdi,r12
    619f:	mov    r11,QWORD PTR [rdi+0x10]
    61a3:	mov    rcx,QWORD PTR [r11+0x58]
    61a7:	mov    edx,0x4
    61ac:	call   61b1 <botlish_fn_55+0x14c>
			61ad: R_X86_64_PLT32	rt_type_error-0x4
    61b1:	mov    rdi,r12
    61b4:	jmp    6271 <botlish_fn_55+0x20c>
    61b9:	mov    r15,rsi
    61bc:	mov    rdi,r12
    61bf:	call   61c4 <botlish_fn_55+0x15f>
			61c0: R_X86_64_PLT32	rt_list_len-0x4
    61c4:	mov    QWORD PTR [rsp+0x30],rax
    61c9:	mov    QWORD PTR [rsp+0x48],rax
    61ce:	mov    rdi,r12
    61d1:	call   61d6 <botlish_fn_55+0x171>
			61d2: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    61d6:	test   rax,rax
    61d9:	jne    61e7 <botlish_fn_55+0x182>
    61df:	mov    rdi,r12
    61e2:	jmp    6271 <botlish_fn_55+0x20c>
    61e7:	mov    QWORD PTR [rsp+0x38],rax
    61ec:	mov    r9,rax
    61ef:	mov    QWORD PTR [rsp+0x40],rdx
    61f4:	mov    rsi,rdx
    61f7:	mov    edx,0x3
    61fc:	mov    QWORD PTR [rsp],rsi
    6200:	mov    rax,r13
    6203:	mov    QWORD PTR [rsp+0x8],rax
    6208:	mov    rcx,r15
    620b:	mov    rsi,r14
    620e:	mov    r8,QWORD PTR [rsp+0x48]
    6213:	mov    rdi,r12
    6216:	call   621b <botlish_fn_55+0x1b6>
			6217: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    621b:	test   rax,rax
    621e:	jne    622c <botlish_fn_55+0x1c7>
    6224:	mov    rdi,r12
    6227:	jmp    6271 <botlish_fn_55+0x20c>
    622c:	mov    rdi,r12
    622f:	mov    QWORD PTR [rdi],rbx
    6232:	mov    rbx,QWORD PTR [rsp+0x50]
    6237:	mov    r12,QWORD PTR [rsp+0x58]
    623c:	mov    r13,QWORD PTR [rsp+0x60]
    6241:	mov    r14,QWORD PTR [rsp+0x68]
    6246:	mov    r15,QWORD PTR [rsp+0x70]
    624b:	add    rsp,0x80
    6252:	mov    rsp,rbp
    6255:	pop    rbp
    6256:	ret
    6257:	xor    rdx,rdx
    625a:	mov    rdi,r12
    625d:	mov    rsi,rdx
    6260:	call   6265 <botlish_fn_55+0x200>
			6261: R_X86_64_PLT32	rt_list_new-0x4
    6265:	test   rax,rax
    6268:	jne    629f <botlish_fn_55+0x23a>
    626e:	mov    rdi,r12
    6271:	mov    rdi,r12
    6274:	mov    QWORD PTR [rdi],rbx
    6277:	xor    rax,rax
    627a:	mov    rbx,QWORD PTR [rsp+0x50]
    627f:	mov    r12,QWORD PTR [rsp+0x58]
    6284:	mov    r13,QWORD PTR [rsp+0x60]
    6289:	mov    r14,QWORD PTR [rsp+0x68]
    628e:	mov    r15,QWORD PTR [rsp+0x70]
    6293:	add    rsp,0x80
    629a:	mov    rsp,rbp
    629d:	pop    rbp
    629e:	ret
    629f:	mov    rdi,r12
    62a2:	mov    QWORD PTR [rdi],rbx
    62a5:	mov    rbx,QWORD PTR [rsp+0x50]
    62aa:	mov    r12,QWORD PTR [rsp+0x58]
    62af:	mov    r13,QWORD PTR [rsp+0x60]
    62b4:	mov    r14,QWORD PTR [rsp+0x68]
    62b9:	mov    r15,QWORD PTR [rsp+0x70]
    62be:	add    rsp,0x80
    62c5:	mov    rsp,rbp
    62c8:	pop    rbp
    62c9:	ret
    62ca:	mov    r12,rdi
    62cd:	call   62d2 <botlish_fn_55+0x26d>
			62ce: R_X86_64_PLT32	rt_stack_overflow-0x4
    62d2:	xor    rax,rax
    62d5:	mov    rbx,QWORD PTR [rsp+0x50]
    62da:	mov    r12,QWORD PTR [rsp+0x58]
    62df:	mov    r13,QWORD PTR [rsp+0x60]
    62e4:	mov    r14,QWORD PTR [rsp+0x68]
    62e9:	mov    r15,QWORD PTR [rsp+0x70]
    62ee:	add    rsp,0x80
    62f5:	mov    rsp,rbp
    62f8:	pop    rbp
    62f9:	ret

00000000000062fa <botlish_entry_55: csv_records_generic<str, bool>>:
    62fa:	push   rbp
    62fb:	mov    rbp,rsp
    62fe:	mov    rsi,QWORD PTR [rdx]
    6301:	mov    rdx,QWORD PTR [rdx+0x8]
    6305:	call   630a <botlish_entry_55+0x10>
			6306: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    630a:	mov    rsp,rbp
    630d:	pop    rbp
    630e:	ret

000000000000630f <botlish_fn_56: csv_records<str>>:
    630f:	push   rbp
    6310:	mov    rbp,rsp
    6313:	sub    rsp,0x20
    6317:	mov    QWORD PTR [rsp+0x10],r13
    631c:	mov    QWORD PTR [rsp+0x18],r14
    6321:	mov    r13,QWORD PTR [rdi]
    6324:	mov    rax,QWORD PTR [rdi+0x8]
    6328:	lea    rcx,[r13+0x8]
    632c:	cmp    rcx,rax
    632f:	ja     639f <botlish_fn_56+0x90>
    6335:	lea    rax,[r13+0x8]
    6339:	mov    QWORD PTR [rdi],rax
    633c:	mov    r14,rdi
    633f:	mov    QWORD PTR [r13+0x0],0x0
    6347:	mov    QWORD PTR [rsp],rsi
    634b:	mov    edx,0x2
    6350:	mov    QWORD PTR [rsp+0x8],0x2
    6359:	mov    rdi,r14
    635c:	call   6361 <botlish_fn_56+0x52>
			635d: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6361:	test   rax,rax
    6364:	jne    6386 <botlish_fn_56+0x77>
    636a:	mov    rdi,r14
    636d:	mov    QWORD PTR [rdi],r13
    6370:	xor    rax,rax
    6373:	mov    r13,QWORD PTR [rsp+0x10]
    6378:	mov    r14,QWORD PTR [rsp+0x18]
    637d:	add    rsp,0x20
    6381:	mov    rsp,rbp
    6384:	pop    rbp
    6385:	ret
    6386:	mov    rdi,r14
    6389:	mov    QWORD PTR [rdi],r13
    638c:	mov    r13,QWORD PTR [rsp+0x10]
    6391:	mov    r14,QWORD PTR [rsp+0x18]
    6396:	add    rsp,0x20
    639a:	mov    rsp,rbp
    639d:	pop    rbp
    639e:	ret
    639f:	call   63a4 <botlish_fn_56+0x95>
			63a0: R_X86_64_PLT32	rt_stack_overflow-0x4
    63a4:	xor    rax,rax
    63a7:	mov    r13,QWORD PTR [rsp+0x10]
    63ac:	mov    r14,QWORD PTR [rsp+0x18]
    63b1:	add    rsp,0x20
    63b5:	mov    rsp,rbp
    63b8:	pop    rbp
    63b9:	ret

00000000000063ba <botlish_entry_56: csv_records<str>>:
    63ba:	push   rbp
    63bb:	mov    rbp,rsp
    63be:	mov    rsi,QWORD PTR [rdx]
    63c1:	call   63c6 <botlish_entry_56+0xc>
			63c2: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    63c6:	mov    rsp,rbp
    63c9:	pop    rbp
    63ca:	ret

00000000000063cb <botlish_fn_57: csv_records_presized<str>>:
    63cb:	push   rbp
    63cc:	mov    rbp,rsp
    63cf:	sub    rsp,0x20
    63d3:	mov    QWORD PTR [rsp+0x10],r13
    63d8:	mov    QWORD PTR [rsp+0x18],r14
    63dd:	mov    r13,QWORD PTR [rdi]
    63e0:	mov    rax,QWORD PTR [rdi+0x8]
    63e4:	lea    rcx,[r13+0x8]
    63e8:	cmp    rcx,rax
    63eb:	ja     645b <botlish_fn_57+0x90>
    63f1:	lea    rax,[r13+0x8]
    63f5:	mov    QWORD PTR [rdi],rax
    63f8:	mov    r14,rdi
    63fb:	mov    QWORD PTR [r13+0x0],0x0
    6403:	mov    QWORD PTR [rsp],rsi
    6407:	mov    edx,0x6
    640c:	mov    QWORD PTR [rsp+0x8],0x6
    6415:	mov    rdi,r14
    6418:	call   641d <botlish_fn_57+0x52>
			6419: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    641d:	test   rax,rax
    6420:	jne    6442 <botlish_fn_57+0x77>
    6426:	mov    rdi,r14
    6429:	mov    QWORD PTR [rdi],r13
    642c:	xor    rax,rax
    642f:	mov    r13,QWORD PTR [rsp+0x10]
    6434:	mov    r14,QWORD PTR [rsp+0x18]
    6439:	add    rsp,0x20
    643d:	mov    rsp,rbp
    6440:	pop    rbp
    6441:	ret
    6442:	mov    rdi,r14
    6445:	mov    QWORD PTR [rdi],r13
    6448:	mov    r13,QWORD PTR [rsp+0x10]
    644d:	mov    r14,QWORD PTR [rsp+0x18]
    6452:	add    rsp,0x20
    6456:	mov    rsp,rbp
    6459:	pop    rbp
    645a:	ret
    645b:	call   6460 <botlish_fn_57+0x95>
			645c: R_X86_64_PLT32	rt_stack_overflow-0x4
    6460:	xor    rax,rax
    6463:	mov    r13,QWORD PTR [rsp+0x10]
    6468:	mov    r14,QWORD PTR [rsp+0x18]
    646d:	add    rsp,0x20
    6471:	mov    rsp,rbp
    6474:	pop    rbp
    6475:	ret

0000000000006476 <botlish_entry_57: csv_records_presized<str>>:
    6476:	push   rbp
    6477:	mov    rbp,rsp
    647a:	mov    rsi,QWORD PTR [rdx]
    647d:	call   6482 <botlish_entry_57+0xc>
			647e: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    6482:	mov    rsp,rbp
    6485:	pop    rbp
    6486:	ret
	...

0000000000006488 <botlish_fn_58: sample<generic>>:
    6488:	push   rbp
    6489:	mov    rbp,rsp
    648c:	sub    rsp,0xd0
    6493:	mov    QWORD PTR [rsp+0xa0],rbx
    649b:	mov    QWORD PTR [rsp+0xa8],r12
    64a3:	mov    QWORD PTR [rsp+0xb0],r13
    64ab:	mov    QWORD PTR [rsp+0xb8],r14
    64b3:	mov    QWORD PTR [rsp+0xc0],r15
    64bb:	mov    r14,QWORD PTR [rdi]
    64be:	mov    rax,QWORD PTR [rdi+0x8]
    64c2:	lea    rcx,[r14+0x8]
    64c6:	cmp    rcx,rax
    64c9:	ja     69ca <botlish_fn_58+0x542>
    64cf:	lea    rax,[r14+0x8]
    64d3:	mov    QWORD PTR [rdi],rax
    64d6:	mov    QWORD PTR [r14],0x0
    64dd:	mov    QWORD PTR [rsp+0x8],0x0
    64e6:	mov    QWORD PTR [rsp+0x10],0x0
    64ef:	mov    QWORD PTR [rsp+0x18],0x0
    64f8:	mov    QWORD PTR [rsp+0x20],0x0
    6501:	mov    QWORD PTR [rsp+0x28],0x0
    650a:	mov    QWORD PTR [rsp+0x30],0x0
    6513:	mov    QWORD PTR [rsp+0x38],0x0
    651c:	mov    rax,QWORD PTR [rdi+0x10]
    6520:	mov    r15,rdi
    6523:	mov    rsi,QWORD PTR [rax+0x60]
    6527:	mov    QWORD PTR [rsp],rsi
    652b:	call   6530 <botlish_fn_58+0xa8>
			652c: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6530:	mov    rcx,rax
    6533:	mov    r13,rax
    6536:	test   rax,rcx
    6539:	jne    6547 <botlish_fn_58+0xbf>
    653f:	mov    rdi,r15
    6542:	jmp    6953 <botlish_fn_58+0x4cb>
    6547:	mov    rax,r13
    654a:	mov    QWORD PTR [rsp],rax
    654e:	mov    rdi,r15
    6551:	mov    rax,QWORD PTR [rdi+0x10]
    6555:	mov    rsi,QWORD PTR [rax+0x60]
    6559:	mov    QWORD PTR [rsp+0x8],rsi
    655e:	call   6563 <botlish_fn_58+0xdb>
			655f: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    6563:	mov    r12,rax
    6566:	test   r12,r12
    6569:	jne    6577 <botlish_fn_58+0xef>
    656f:	mov    rdi,r15
    6572:	jmp    6953 <botlish_fn_58+0x4cb>
    6577:	mov    rax,r13
    657a:	mov    rax,QWORD PTR [rax+0x8]
    657e:	test   rax,rax
    6581:	jne    65b3 <botlish_fn_58+0x12b>
    6587:	mov    edx,0x1
    658c:	mov    rsi,r13
    658f:	mov    rdi,r15
    6592:	call   6597 <botlish_fn_58+0x10f>
			6593: R_X86_64_PLT32	rt_list_get-0x4
    6597:	test   rax,rax
    659a:	jne    65a8 <botlish_fn_58+0x120>
    65a0:	mov    rdi,r15
    65a3:	jmp    6953 <botlish_fn_58+0x4cb>
    65a8:	mov    rbx,r13
    65ab:	mov    rsi,rax
    65ae:	jmp    65bd <botlish_fn_58+0x135>
    65b3:	mov    rbx,r13
    65b6:	mov    rax,QWORD PTR [rbx+0x10]
    65ba:	mov    rsi,QWORD PTR [rax]
    65bd:	mov    QWORD PTR [rsp+0x8],rsi
    65c2:	mov    QWORD PTR [rsp+0x80],rsi
    65ca:	mov    rax,QWORD PTR [rbx+0x8]
    65ce:	cmp    rax,0x1
    65d2:	ja     6604 <botlish_fn_58+0x17c>
    65d8:	mov    edx,0x3
    65dd:	mov    rsi,rbx
    65e0:	mov    rdi,r15
    65e3:	call   65e8 <botlish_fn_58+0x160>
			65e4: R_X86_64_PLT32	rt_list_get-0x4
    65e8:	test   rax,rax
    65eb:	jne    65f9 <botlish_fn_58+0x171>
    65f1:	mov    rdi,r15
    65f4:	jmp    6953 <botlish_fn_58+0x4cb>
    65f9:	mov    rsi,rax
    65fc:	mov    r13,rbx
    65ff:	jmp    660f <botlish_fn_58+0x187>
    6604:	mov    rax,QWORD PTR [rbx+0x10]
    6608:	mov    r13,rbx
    660b:	mov    rsi,QWORD PTR [rax+0x8]
    660f:	mov    QWORD PTR [rsp+0x10],rsi
    6614:	mov    QWORD PTR [rsp+0x78],rsi
    6619:	mov    rax,QWORD PTR [r12+0x8]
    661e:	mov    rsi,r12
    6621:	test   rax,rax
    6624:	jne    6650 <botlish_fn_58+0x1c8>
    662a:	mov    edx,0x1
    662f:	mov    rdi,r15
    6632:	call   6637 <botlish_fn_58+0x1af>
			6633: R_X86_64_PLT32	rt_list_get-0x4
    6637:	test   rax,rax
    663a:	jne    6648 <botlish_fn_58+0x1c0>
    6640:	mov    rdi,r15
    6643:	jmp    6953 <botlish_fn_58+0x4cb>
    6648:	mov    rsi,rax
    664b:	jmp    6657 <botlish_fn_58+0x1cf>
    6650:	mov    rax,QWORD PTR [rsi+0x10]
    6654:	mov    rsi,QWORD PTR [rax]
    6657:	mov    QWORD PTR [rsp+0x18],rsi
    665c:	mov    rdi,r15
    665f:	mov    r12,rsi
    6662:	mov    rax,QWORD PTR [rdi+0x10]
    6666:	mov    rdx,QWORD PTR [rax+0x68]
    666a:	mov    QWORD PTR [rsp+0x20],rdx
    666f:	mov    rsi,QWORD PTR [rsp+0x80]
    6677:	call   667c <botlish_fn_58+0x1f4>
			6678: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    667c:	test   rax,rax
    667f:	jne    668d <botlish_fn_58+0x205>
    6685:	mov    rdi,r15
    6688:	jmp    6953 <botlish_fn_58+0x4cb>
    668d:	mov    QWORD PTR [rsp+0x20],rax
    6692:	mov    rbx,rax
    6695:	mov    rdi,r15
    6698:	mov    rsi,QWORD PTR [rdi+0x10]
    669c:	mov    rdx,QWORD PTR [rsi+0x68]
    66a0:	mov    QWORD PTR [rsp+0x28],rdx
    66a5:	mov    rsi,r12
    66a8:	call   66ad <botlish_fn_58+0x225>
			66a9: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    66ad:	test   rax,rax
    66b0:	jne    66be <botlish_fn_58+0x236>
    66b6:	mov    rdi,r15
    66b9:	jmp    6953 <botlish_fn_58+0x4cb>
    66be:	mov    rcx,rbx
    66c1:	mov    r8,rcx
    66c4:	and    r8,rax
    66c7:	mov    rdx,rax
    66ca:	test   r8,0x1
    66d1:	jne    66f3 <botlish_fn_58+0x26b>
    66d7:	mov    rsi,rbx
    66da:	mov    rdi,r15
    66dd:	call   66e2 <botlish_fn_58+0x25a>
			66de: R_X86_64_PLT32	rt_value_eq-0x4
    66e2:	test   rax,rax
    66e5:	jne    6706 <botlish_fn_58+0x27e>
    66eb:	mov    rdi,r15
    66ee:	jmp    6953 <botlish_fn_58+0x4cb>
    66f3:	mov    rsi,rbx
    66f6:	mov    eax,0x2
    66fb:	cmp    rsi,rdx
    66fe:	cmove  rax,QWORD PTR [rip+0x30a]        # 6a10 <botlish_fn_58+0x588>
    6706:	mov    ebx,0x6
    670b:	cmp    rax,0x6
    670f:	je     672a <botlish_fn_58+0x2a2>
    6715:	mov    ebx,0x2
    671a:	mov    QWORD PTR [rsp],0x2
    6722:	mov    rsi,r13
    6725:	jmp    67d0 <botlish_fn_58+0x348>
    672a:	mov    rsi,QWORD PTR [rsp+0x80]
    6732:	mov    rdi,r15
    6735:	call   673a <botlish_fn_58+0x2b2>
			6736: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    673a:	test   rax,rax
    673d:	jne    674b <botlish_fn_58+0x2c3>
    6743:	mov    rdi,r15
    6746:	jmp    6953 <botlish_fn_58+0x4cb>
    674b:	mov    QWORD PTR [rsp+0x20],rax
    6750:	mov    rsi,r12
    6753:	mov    r12,rax
    6756:	mov    rdi,r15
    6759:	call   675e <botlish_fn_58+0x2d6>
			675a: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    675e:	test   rax,rax
    6761:	jne    676f <botlish_fn_58+0x2e7>
    6767:	mov    rdi,r15
    676a:	jmp    6953 <botlish_fn_58+0x4cb>
    676f:	mov    rcx,r12
    6772:	mov    rdx,rcx
    6775:	and    rdx,rax
    6778:	test   rdx,0x1
    677f:	jne    67a4 <botlish_fn_58+0x31c>
    6785:	mov    rdx,rax
    6788:	mov    rsi,r12
    678b:	mov    rdi,r15
    678e:	call   6793 <botlish_fn_58+0x30b>
			678f: R_X86_64_PLT32	rt_value_eq-0x4
    6793:	test   rax,rax
    6796:	jne    67ba <botlish_fn_58+0x332>
    679c:	mov    rdi,r15
    679f:	jmp    6953 <botlish_fn_58+0x4cb>
    67a4:	mov    rdx,rax
    67a7:	mov    rsi,r12
    67aa:	mov    eax,0x2
    67af:	cmp    rsi,rdx
    67b2:	cmove  rax,QWORD PTR [rip+0x256]        # 6a10 <botlish_fn_58+0x588>
    67ba:	cmp    rax,0x6
    67be:	je     67c9 <botlish_fn_58+0x341>
    67c4:	mov    ebx,0x2
    67c9:	mov    QWORD PTR [rsp],rbx
    67cd:	mov    rsi,r13
    67d0:	mov    rdi,r15
    67d3:	call   67d8 <botlish_fn_58+0x350>
			67d4: R_X86_64_PLT32	rt_list_len-0x4
    67d8:	mov    QWORD PTR [rsp+0x18],rax
    67dd:	mov    rdi,r15
    67e0:	mov    r12,rax
    67e3:	mov    rax,QWORD PTR [rdi+0x10]
    67e7:	mov    rdx,QWORD PTR [rax+0x68]
    67eb:	mov    QWORD PTR [rsp+0x20],rdx
    67f0:	mov    rsi,QWORD PTR [rsp+0x80]
    67f8:	call   67fd <botlish_fn_58+0x375>
			67f9: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    67fd:	test   rax,rax
    6800:	jne    680e <botlish_fn_58+0x386>
    6806:	mov    rdi,r15
    6809:	jmp    6953 <botlish_fn_58+0x4cb>
    680e:	mov    QWORD PTR [rsp+0x20],rax
    6813:	mov    rdi,r15
    6816:	mov    r13,rax
    6819:	mov    rax,QWORD PTR [rdi+0x10]
    681d:	mov    rdx,QWORD PTR [rax+0x70]
    6821:	mov    QWORD PTR [rsp+0x28],rdx
    6826:	mov    rsi,QWORD PTR [rsp+0x80]
    682e:	call   6833 <botlish_fn_58+0x3ab>
			682f: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6833:	test   rax,rax
    6836:	jne    6844 <botlish_fn_58+0x3bc>
    683c:	mov    rdi,r15
    683f:	jmp    6953 <botlish_fn_58+0x4cb>
    6844:	mov    QWORD PTR [rsp+0x28],rax
    6849:	mov    rdi,r15
    684c:	mov    QWORD PTR [rsp+0x90],rax
    6854:	mov    rax,QWORD PTR [rdi+0x10]
    6858:	mov    rdx,QWORD PTR [rax+0x78]
    685c:	mov    QWORD PTR [rsp+0x30],rdx
    6861:	mov    rsi,QWORD PTR [rsp+0x80]
    6869:	call   686e <botlish_fn_58+0x3e6>
			686a: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    686e:	test   rax,rax
    6871:	jne    687f <botlish_fn_58+0x3f7>
    6877:	mov    rdi,r15
    687a:	jmp    6953 <botlish_fn_58+0x4cb>
    687f:	mov    QWORD PTR [rsp+0x8],rax
    6884:	mov    rdi,r15
    6887:	mov    QWORD PTR [rsp+0x88],rax
    688f:	mov    rax,QWORD PTR [rdi+0x10]
    6893:	mov    rdx,QWORD PTR [rax+0x68]
    6897:	mov    QWORD PTR [rsp+0x30],rdx
    689c:	mov    rsi,QWORD PTR [rsp+0x78]
    68a1:	call   68a6 <botlish_fn_58+0x41e>
			68a2: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    68a6:	test   rax,rax
    68a9:	jne    68b7 <botlish_fn_58+0x42f>
    68af:	mov    rdi,r15
    68b2:	jmp    6953 <botlish_fn_58+0x4cb>
    68b7:	mov    QWORD PTR [rsp+0x30],rax
    68bc:	mov    rdi,r15
    68bf:	mov    QWORD PTR [rsp+0x80],rax
    68c7:	mov    rax,QWORD PTR [rdi+0x10]
    68cb:	mov    rdx,QWORD PTR [rax+0x78]
    68cf:	mov    QWORD PTR [rsp+0x38],rdx
    68d4:	mov    rsi,QWORD PTR [rsp+0x78]
    68d9:	call   68de <botlish_fn_58+0x456>
			68da: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    68de:	test   rax,rax
    68e1:	jne    68ef <botlish_fn_58+0x467>
    68e7:	mov    rdi,r15
    68ea:	jmp    6953 <botlish_fn_58+0x4cb>
    68ef:	mov    QWORD PTR [rsp+0x10],rax
    68f4:	lea    rdx,[rsp+0x40]
    68f9:	mov    rcx,r12
    68fc:	mov    QWORD PTR [rsp+0x40],rcx
    6901:	mov    rcx,r13
    6904:	mov    QWORD PTR [rsp+0x48],rcx
    6909:	mov    rcx,QWORD PTR [rsp+0x90]
    6911:	mov    QWORD PTR [rsp+0x50],rcx
    6916:	mov    rcx,QWORD PTR [rsp+0x88]
    691e:	mov    QWORD PTR [rsp+0x58],rcx
    6923:	mov    rcx,QWORD PTR [rsp+0x80]
    692b:	mov    QWORD PTR [rsp+0x60],rcx
    6930:	mov    QWORD PTR [rsp+0x68],rax
    6935:	mov    QWORD PTR [rsp+0x70],rbx
    693a:	mov    esi,0x7
    693f:	mov    rdi,r15
    6942:	call   6947 <botlish_fn_58+0x4bf>
			6943: R_X86_64_PLT32	rt_list_new-0x4
    6947:	test   rax,rax
    694a:	jne    6990 <botlish_fn_58+0x508>
    6950:	mov    rdi,r15
    6953:	mov    rdi,r15
    6956:	mov    QWORD PTR [rdi],r14
    6959:	xor    rax,rax
    695c:	mov    rbx,QWORD PTR [rsp+0xa0]
    6964:	mov    r12,QWORD PTR [rsp+0xa8]
    696c:	mov    r13,QWORD PTR [rsp+0xb0]
    6974:	mov    r14,QWORD PTR [rsp+0xb8]
    697c:	mov    r15,QWORD PTR [rsp+0xc0]
    6984:	add    rsp,0xd0
    698b:	mov    rsp,rbp
    698e:	pop    rbp
    698f:	ret
    6990:	mov    rdi,r15
    6993:	mov    QWORD PTR [rdi],r14
    6996:	mov    rbx,QWORD PTR [rsp+0xa0]
    699e:	mov    r12,QWORD PTR [rsp+0xa8]
    69a6:	mov    r13,QWORD PTR [rsp+0xb0]
    69ae:	mov    r14,QWORD PTR [rsp+0xb8]
    69b6:	mov    r15,QWORD PTR [rsp+0xc0]
    69be:	add    rsp,0xd0
    69c5:	mov    rsp,rbp
    69c8:	pop    rbp
    69c9:	ret
    69ca:	mov    r15,rdi
    69cd:	call   69d2 <botlish_fn_58+0x54a>
			69ce: R_X86_64_PLT32	rt_stack_overflow-0x4
    69d2:	xor    rax,rax
    69d5:	mov    rbx,QWORD PTR [rsp+0xa0]
    69dd:	mov    r12,QWORD PTR [rsp+0xa8]
    69e5:	mov    r13,QWORD PTR [rsp+0xb0]
    69ed:	mov    r14,QWORD PTR [rsp+0xb8]
    69f5:	mov    r15,QWORD PTR [rsp+0xc0]
    69fd:	add    rsp,0xd0
    6a04:	mov    rsp,rbp
    6a07:	pop    rbp
    6a08:	ret
    6a09:	add    BYTE PTR [rax],al
    6a0b:	add    BYTE PTR [rax],al
    6a0d:	add    BYTE PTR [rax],al
    6a0f:	add    BYTE PTR [rsi],al
    6a11:	add    BYTE PTR [rax],al
    6a13:	add    BYTE PTR [rax],al
    6a15:	add    BYTE PTR [rax],al
	...

0000000000006a18 <botlish_entry_58: sample<generic>>:
    6a18:	push   rbp
    6a19:	mov    rbp,rsp
    6a1c:	call   6a21 <botlish_entry_58+0x9>
			6a1d: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    6a21:	mov    rsp,rbp
    6a24:	pop    rbp
    6a25:	ret

; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 22322  (per function: 45 78 357 397 272 272 272 81 365 430 584 770 351 695 456 171 28 28 28 28 412 524 116 493 170 61 125 61 125 61 125 61 125 61 175 175 190 190 233 233 852 1312 437 428 458 1153 803 841 681 1232 892 107 756 335 645 580 78 78 1230)
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
     232:	cmovl  rcx,QWORD PTR [rip+0xde]        # 318 <botlish_fn_3+0x150>
     23a:	mov    rax,r14
     23d:	jmp    255 <botlish_fn_3+0x8d>
     242:	mov    ecx,0x2
     247:	mov    rax,r14
     24a:	cmp    rbx,rax
     24d:	cmovl  rcx,QWORD PTR [rip+0xc3]        # 318 <botlish_fn_3+0x150>
     255:	cmp    rcx,0x6
     259:	je     2f5 <botlish_fn_3+0x12d>
     25f:	mov    rsi,rax
     262:	mov    rdx,rbx
     265:	mov    rdi,r13
     268:	call   26d <botlish_fn_3+0xa5>
			269: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     26d:	test   rax,rax
     270:	je     2b5 <botlish_fn_3+0xed>
     276:	mov    QWORD PTR [rsp+0x10],rax
     27b:	mov    rsi,rax
     27e:	mov    rdi,r13
     281:	call   286 <botlish_fn_3+0xbe>
			282: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     286:	test   rax,rax
     289:	mov    r14,rax
     28c:	je     2b5 <botlish_fn_3+0xed>
     292:	mov    r8d,0x1
     298:	mov    rcx,r12
     29b:	mov    rdi,r13
     29e:	mov    r9,rbx
     2a1:	mov    rsi,r14
     2a4:	mov    rdx,r8
     2a7:	call   2ac <botlish_fn_3+0xe4>
			2a8: R_X86_64_PLT32	rt_mutarray_copy-0x4
     2ac:	test   rax,rax
     2af:	jne    2d5 <botlish_fn_3+0x10d>
     2b5:	xor    rax,rax
     2b8:	mov    rbx,QWORD PTR [rsp+0x20]
     2bd:	mov    r12,QWORD PTR [rsp+0x28]
     2c2:	mov    r13,QWORD PTR [rsp+0x30]
     2c7:	mov    r14,QWORD PTR [rsp+0x38]
     2cc:	add    rsp,0x40
     2d0:	mov    rsp,rbp
     2d3:	pop    rbp
     2d4:	ret
     2d5:	mov    rax,r14
     2d8:	mov    rbx,QWORD PTR [rsp+0x20]
     2dd:	mov    r12,QWORD PTR [rsp+0x28]
     2e2:	mov    r13,QWORD PTR [rsp+0x30]
     2e7:	mov    r14,QWORD PTR [rsp+0x38]
     2ec:	add    rsp,0x40
     2f0:	mov    rsp,rbp
     2f3:	pop    rbp
     2f4:	ret
     2f5:	mov    rax,r12
     2f8:	mov    rbx,QWORD PTR [rsp+0x20]
     2fd:	mov    r12,QWORD PTR [rsp+0x28]
     302:	mov    r13,QWORD PTR [rsp+0x30]
     307:	mov    r14,QWORD PTR [rsp+0x38]
     30c:	add    rsp,0x40
     310:	mov    rsp,rbp
     313:	pop    rbp
     314:	ret
     315:	add    BYTE PTR [rax],al
     317:	add    BYTE PTR [rsi],al
     319:	add    BYTE PTR [rax],al
     31b:	add    BYTE PTR [rax],al
     31d:	add    BYTE PTR [rax],al
	...

0000000000000320 <botlish_entry_3: geo_grow<mutarray, int>>:
     320:	push   rbp
     321:	mov    rbp,rsp
     324:	mov    rsi,QWORD PTR [rdx]
     327:	mov    rdx,QWORD PTR [rdx+0x8]
     32b:	call   330 <botlish_entry_3+0x10>
			32c: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     330:	mov    rsp,rbp
     333:	pop    rbp
     334:	ret

0000000000000335 <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     335:	push   rbp
     336:	mov    rbp,rsp
     339:	sub    rsp,0x40
     33d:	mov    QWORD PTR [rsp+0x20],rbx
     342:	mov    QWORD PTR [rsp+0x28],r12
     347:	mov    QWORD PTR [rsp+0x30],r13
     34c:	mov    r12,rdi
     34f:	mov    QWORD PTR [rsp],rsi
     353:	mov    QWORD PTR [rsp+0x8],rdx
     358:	mov    rdi,rdx
     35b:	mov    QWORD PTR [rsp+0x10],rcx
     360:	mov    r13,rcx
     363:	mov    rbx,rdi
     366:	mov    rdx,rbx
     369:	mov    rdi,r12
     36c:	call   371 <botlish_fn_4+0x3c>
			36d: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     371:	test   rax,rax
     374:	je     39b <botlish_fn_4+0x66>
     37a:	mov    QWORD PTR [rsp],rax
     37e:	mov    rcx,r13
     381:	mov    r13,rax
     384:	mov    rdx,rbx
     387:	mov    rsi,r13
     38a:	mov    rdi,r12
     38d:	call   392 <botlish_fn_4+0x5d>
			38e: R_X86_64_PLT32	rt_mutarray_set-0x4
     392:	test   rax,rax
     395:	jne    3b9 <botlish_fn_4+0x84>
     39b:	xor    rdx,rdx
     39e:	mov    rax,rdx
     3a1:	mov    rbx,QWORD PTR [rsp+0x20]
     3a6:	mov    r12,QWORD PTR [rsp+0x28]
     3ab:	mov    r13,QWORD PTR [rsp+0x30]
     3b0:	add    rsp,0x40
     3b4:	mov    rsp,rbp
     3b7:	pop    rbp
     3b8:	ret
     3b9:	mov    QWORD PTR [rsp+0x10],0x3
     3c2:	test   rbx,0x1
     3c9:	jne    3d7 <botlish_fn_4+0xa2>
     3cf:	mov    rdi,rbx
     3d2:	jmp    3f4 <botlish_fn_4+0xbf>
     3d7:	mov    rdx,rbx
     3da:	add    rdx,0x2
     3de:	mov    rdi,rbx
     3e1:	seto   al
     3e4:	test   al,al
     3e6:	jne    3f4 <botlish_fn_4+0xbf>
     3ec:	mov    rax,r13
     3ef:	jmp    40a <botlish_fn_4+0xd5>
     3f4:	mov    edx,0x3
     3f9:	mov    rsi,rdi
     3fc:	mov    rdi,r12
     3ff:	call   404 <botlish_fn_4+0xcf>
			400: R_X86_64_PLT32	rt_int_add-0x4
     404:	mov    rdx,rax
     407:	mov    rax,r13
     40a:	mov    rbx,QWORD PTR [rsp+0x20]
     40f:	mov    r12,QWORD PTR [rsp+0x28]
     414:	mov    r13,QWORD PTR [rsp+0x30]
     419:	add    rsp,0x40
     41d:	mov    rsp,rbp
     420:	pop    rbp
     421:	ret

0000000000000422 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     422:	push   rbp
     423:	mov    rbp,rsp
     426:	ud2

0000000000000428 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     428:	push   rbp
     429:	mov    rbp,rsp
     42c:	sub    rsp,0x40
     430:	mov    QWORD PTR [rsp+0x20],rbx
     435:	mov    QWORD PTR [rsp+0x28],r12
     43a:	mov    QWORD PTR [rsp+0x30],r13
     43f:	mov    r12,rdi
     442:	mov    QWORD PTR [rsp],rsi
     446:	mov    QWORD PTR [rsp+0x8],rdx
     44b:	mov    rdi,rdx
     44e:	mov    QWORD PTR [rsp+0x10],rcx
     453:	mov    r13,rcx
     456:	mov    rbx,rdi
     459:	mov    rdx,rbx
     45c:	mov    rdi,r12
     45f:	call   464 <botlish_fn_5+0x3c>
			460: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     464:	test   rax,rax
     467:	je     48e <botlish_fn_5+0x66>
     46d:	mov    QWORD PTR [rsp],rax
     471:	mov    rcx,r13
     474:	mov    r13,rax
     477:	mov    rdx,rbx
     47a:	mov    rsi,r13
     47d:	mov    rdi,r12
     480:	call   485 <botlish_fn_5+0x5d>
			481: R_X86_64_PLT32	rt_mutarray_set-0x4
     485:	test   rax,rax
     488:	jne    4ac <botlish_fn_5+0x84>
     48e:	xor    rdx,rdx
     491:	mov    rax,rdx
     494:	mov    rbx,QWORD PTR [rsp+0x20]
     499:	mov    r12,QWORD PTR [rsp+0x28]
     49e:	mov    r13,QWORD PTR [rsp+0x30]
     4a3:	add    rsp,0x40
     4a7:	mov    rsp,rbp
     4aa:	pop    rbp
     4ab:	ret
     4ac:	mov    QWORD PTR [rsp+0x10],0x3
     4b5:	test   rbx,0x1
     4bc:	jne    4ca <botlish_fn_5+0xa2>
     4c2:	mov    rdi,rbx
     4c5:	jmp    4e7 <botlish_fn_5+0xbf>
     4ca:	mov    rdx,rbx
     4cd:	add    rdx,0x2
     4d1:	mov    rdi,rbx
     4d4:	seto   al
     4d7:	test   al,al
     4d9:	jne    4e7 <botlish_fn_5+0xbf>
     4df:	mov    rax,r13
     4e2:	jmp    4fd <botlish_fn_5+0xd5>
     4e7:	mov    edx,0x3
     4ec:	mov    rsi,rdi
     4ef:	mov    rdi,r12
     4f2:	call   4f7 <botlish_fn_5+0xcf>
			4f3: R_X86_64_PLT32	rt_int_add-0x4
     4f7:	mov    rdx,rax
     4fa:	mov    rax,r13
     4fd:	mov    rbx,QWORD PTR [rsp+0x20]
     502:	mov    r12,QWORD PTR [rsp+0x28]
     507:	mov    r13,QWORD PTR [rsp+0x30]
     50c:	add    rsp,0x40
     510:	mov    rsp,rbp
     513:	pop    rbp
     514:	ret

0000000000000515 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     515:	push   rbp
     516:	mov    rbp,rsp
     519:	ud2

000000000000051b <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     51b:	push   rbp
     51c:	mov    rbp,rsp
     51f:	sub    rsp,0x40
     523:	mov    QWORD PTR [rsp+0x20],rbx
     528:	mov    QWORD PTR [rsp+0x28],r12
     52d:	mov    QWORD PTR [rsp+0x30],r13
     532:	mov    r12,rdi
     535:	mov    QWORD PTR [rsp],rsi
     539:	mov    QWORD PTR [rsp+0x8],rdx
     53e:	mov    rdi,rdx
     541:	mov    QWORD PTR [rsp+0x10],rcx
     546:	mov    r13,rcx
     549:	mov    rbx,rdi
     54c:	mov    rdx,rbx
     54f:	mov    rdi,r12
     552:	call   557 <botlish_fn_6+0x3c>
			553: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     557:	test   rax,rax
     55a:	je     581 <botlish_fn_6+0x66>
     560:	mov    QWORD PTR [rsp],rax
     564:	mov    rcx,r13
     567:	mov    r13,rax
     56a:	mov    rdx,rbx
     56d:	mov    rsi,r13
     570:	mov    rdi,r12
     573:	call   578 <botlish_fn_6+0x5d>
			574: R_X86_64_PLT32	rt_mutarray_set-0x4
     578:	test   rax,rax
     57b:	jne    59f <botlish_fn_6+0x84>
     581:	xor    rdx,rdx
     584:	mov    rax,rdx
     587:	mov    rbx,QWORD PTR [rsp+0x20]
     58c:	mov    r12,QWORD PTR [rsp+0x28]
     591:	mov    r13,QWORD PTR [rsp+0x30]
     596:	add    rsp,0x40
     59a:	mov    rsp,rbp
     59d:	pop    rbp
     59e:	ret
     59f:	mov    QWORD PTR [rsp+0x10],0x3
     5a8:	test   rbx,0x1
     5af:	jne    5bd <botlish_fn_6+0xa2>
     5b5:	mov    rdi,rbx
     5b8:	jmp    5da <botlish_fn_6+0xbf>
     5bd:	mov    rdx,rbx
     5c0:	add    rdx,0x2
     5c4:	mov    rdi,rbx
     5c7:	seto   al
     5ca:	test   al,al
     5cc:	jne    5da <botlish_fn_6+0xbf>
     5d2:	mov    rax,r13
     5d5:	jmp    5f0 <botlish_fn_6+0xd5>
     5da:	mov    edx,0x3
     5df:	mov    rsi,rdi
     5e2:	mov    rdi,r12
     5e5:	call   5ea <botlish_fn_6+0xcf>
			5e6: R_X86_64_PLT32	rt_int_add-0x4
     5ea:	mov    rdx,rax
     5ed:	mov    rax,r13
     5f0:	mov    rbx,QWORD PTR [rsp+0x20]
     5f5:	mov    r12,QWORD PTR [rsp+0x28]
     5fa:	mov    r13,QWORD PTR [rsp+0x30]
     5ff:	add    rsp,0x40
     603:	mov    rsp,rbp
     606:	pop    rbp
     607:	ret

0000000000000608 <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     608:	push   rbp
     609:	mov    rbp,rsp
     60c:	ud2

000000000000060e <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     60e:	push   rbp
     60f:	mov    rbp,rsp
     612:	sub    rsp,0x10
     616:	mov    QWORD PTR [rsp],rsi
     61a:	mov    QWORD PTR [rsp+0x8],rdx
     61f:	call   624 <botlish_fn_7+0x16>
			620: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     624:	test   rax,rax
     627:	jne    639 <botlish_fn_7+0x2b>
     62d:	xor    rax,rax
     630:	add    rsp,0x10
     634:	mov    rsp,rbp
     637:	pop    rbp
     638:	ret
     639:	add    rsp,0x10
     63d:	mov    rsp,rbp
     640:	pop    rbp
     641:	ret

0000000000000642 <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     642:	push   rbp
     643:	mov    rbp,rsp
     646:	mov    rsi,QWORD PTR [rdx]
     649:	mov    rdx,QWORD PTR [rdx+0x8]
     64d:	call   652 <botlish_entry_7+0x10>
			64e: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     652:	mov    rsp,rbp
     655:	pop    rbp
     656:	ret
	...

0000000000000658 <botlish_fn_8: peek<str, int>>:
     658:	push   rbp
     659:	mov    rbp,rsp
     65c:	sub    rsp,0x40
     660:	mov    QWORD PTR [rsp+0x20],rbx
     665:	mov    QWORD PTR [rsp+0x28],r12
     66a:	mov    QWORD PTR [rsp+0x30],r13
     66f:	mov    r13,rdi
     672:	mov    QWORD PTR [rsp],rsi
     676:	mov    r12,rsi
     679:	mov    QWORD PTR [rsp+0x8],rdx
     67e:	mov    rbx,rdx
     681:	mov    rsi,r12
     684:	mov    rdi,r13
     687:	call   68c <botlish_fn_8+0x34>
			688: R_X86_64_PLT32	rt_str_len-0x4
     68c:	mov    rcx,rbx
     68f:	and    rcx,rax
     692:	mov    rdx,rax
     695:	test   rcx,0x1
     69c:	jne    6c2 <botlish_fn_8+0x6a>
     6a2:	mov    rsi,rbx
     6a5:	mov    rdi,r13
     6a8:	call   6ad <botlish_fn_8+0x55>
			6a9: R_X86_64_PLT32	rt_int_cmp-0x4
     6ad:	mov    ecx,0x2
     6b2:	test   rax,rax
     6b5:	cmovge rcx,QWORD PTR [rip+0xcb]        # 788 <botlish_fn_8+0x130>
     6bd:	jmp    6d2 <botlish_fn_8+0x7a>
     6c2:	mov    ecx,0x2
     6c7:	cmp    rbx,rdx
     6ca:	cmovge rcx,QWORD PTR [rip+0xb6]        # 788 <botlish_fn_8+0x130>
     6d2:	cmp    rcx,0x6
     6d6:	je     766 <botlish_fn_8+0x10e>
     6dc:	mov    QWORD PTR [rsp+0x10],0x3
     6e5:	test   rbx,0x1
     6ec:	je     704 <botlish_fn_8+0xac>
     6f2:	mov    rcx,rbx
     6f5:	add    rcx,0x2
     6f9:	seto   al
     6fc:	test   al,al
     6fe:	je     717 <botlish_fn_8+0xbf>
     704:	mov    edx,0x3
     709:	mov    rsi,rbx
     70c:	mov    rdi,r13
     70f:	call   714 <botlish_fn_8+0xbc>
			710: R_X86_64_PLT32	rt_int_add-0x4
     714:	mov    rcx,rax
     717:	mov    QWORD PTR [rsp+0x10],rcx
     71c:	mov    rdx,rbx
     71f:	mov    rsi,r12
     722:	mov    rdi,r13
     725:	call   72a <botlish_fn_8+0xd2>
			726: R_X86_64_PLT32	rt_substr-0x4
     72a:	test   rax,rax
     72d:	jne    74e <botlish_fn_8+0xf6>
     733:	xor    rax,rax
     736:	mov    rbx,QWORD PTR [rsp+0x20]
     73b:	mov    r12,QWORD PTR [rsp+0x28]
     740:	mov    r13,QWORD PTR [rsp+0x30]
     745:	add    rsp,0x40
     749:	mov    rsp,rbp
     74c:	pop    rbp
     74d:	ret
     74e:	mov    rbx,QWORD PTR [rsp+0x20]
     753:	mov    r12,QWORD PTR [rsp+0x28]
     758:	mov    r13,QWORD PTR [rsp+0x30]
     75d:	add    rsp,0x40
     761:	mov    rsp,rbp
     764:	pop    rbp
     765:	ret
     766:	mov    rdi,r13
     769:	mov    rax,QWORD PTR [rdi+0x10]
     76d:	mov    rax,QWORD PTR [rax]
     770:	mov    rbx,QWORD PTR [rsp+0x20]
     775:	mov    r12,QWORD PTR [rsp+0x28]
     77a:	mov    r13,QWORD PTR [rsp+0x30]
     77f:	add    rsp,0x40
     783:	mov    rsp,rbp
     786:	pop    rbp
     787:	ret
     788:	(bad)
     789:	add    BYTE PTR [rax],al
     78b:	add    BYTE PTR [rax],al
     78d:	add    BYTE PTR [rax],al
	...

0000000000000790 <botlish_entry_8: peek<str, int>>:
     790:	push   rbp
     791:	mov    rbp,rsp
     794:	mov    rsi,QWORD PTR [rdx]
     797:	mov    rdx,QWORD PTR [rdx+0x8]
     79b:	call   7a0 <botlish_entry_8+0x10>
			79c: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     7a0:	mov    rsp,rbp
     7a3:	pop    rbp
     7a4:	ret
     7a5:	add    BYTE PTR [rax],al
	...

00000000000007a8 <botlish_fn_9: peek<str, int>>:
     7a8:	push   rbp
     7a9:	mov    rbp,rsp
     7ac:	sub    rsp,0x50
     7b0:	mov    QWORD PTR [rsp+0x20],rbx
     7b5:	mov    QWORD PTR [rsp+0x28],r12
     7ba:	mov    QWORD PTR [rsp+0x30],r13
     7bf:	mov    QWORD PTR [rsp+0x38],r14
     7c4:	mov    QWORD PTR [rsp+0x40],r15
     7c9:	mov    r12,rcx
     7cc:	mov    r14,rdi
     7cf:	mov    QWORD PTR [rsp],rsi
     7d3:	mov    r13,rsi
     7d6:	mov    QWORD PTR [rsp+0x8],rdx
     7db:	mov    rbx,rdx
     7de:	mov    rsi,r13
     7e1:	mov    rdi,r14
     7e4:	call   7e9 <botlish_fn_9+0x41>
			7e5: R_X86_64_PLT32	rt_str_len-0x4
     7e9:	mov    rcx,rbx
     7ec:	and    rcx,rax
     7ef:	mov    rdx,rax
     7f2:	test   rcx,0x1
     7f9:	jne    81f <botlish_fn_9+0x77>
     7ff:	mov    rsi,rbx
     802:	mov    rdi,r14
     805:	call   80a <botlish_fn_9+0x62>
			806: R_X86_64_PLT32	rt_int_cmp-0x4
     80a:	mov    ecx,0x2
     80f:	test   rax,rax
     812:	cmovge rcx,QWORD PTR [rip+0x11e]        # 938 <botlish_fn_9+0x190>
     81a:	jmp    82f <botlish_fn_9+0x87>
     81f:	mov    ecx,0x2
     824:	cmp    rbx,rdx
     827:	cmovge rcx,QWORD PTR [rip+0x109]        # 938 <botlish_fn_9+0x190>
     82f:	cmp    rcx,0x6
     833:	je     8f3 <botlish_fn_9+0x14b>
     839:	mov    QWORD PTR [rsp+0x10],0x3
     842:	test   rbx,0x1
     849:	je     86c <botlish_fn_9+0xc4>
     84f:	mov    rax,rbx
     852:	add    rax,0x2
     856:	seto   cl
     859:	test   cl,cl
     85b:	jne    86c <botlish_fn_9+0xc4>
     861:	mov    rdi,r14
     864:	mov    r15,rax
     867:	jmp    882 <botlish_fn_9+0xda>
     86c:	mov    edx,0x3
     871:	mov    rsi,rbx
     874:	mov    rdi,r14
     877:	call   87c <botlish_fn_9+0xd4>
			878: R_X86_64_PLT32	rt_int_add-0x4
     87c:	mov    r15,rax
     87f:	mov    rdi,r14
     882:	mov    rdi,r14
     885:	mov    rcx,r15
     888:	mov    rdx,rbx
     88b:	mov    rsi,r13
     88e:	call   893 <botlish_fn_9+0xeb>
			88f: R_X86_64_PLT32	rt_str_region_check-0x4
     893:	test   rax,rax
     896:	jne    8c1 <botlish_fn_9+0x119>
     89c:	xor    rax,rax
     89f:	mov    rbx,QWORD PTR [rsp+0x20]
     8a4:	mov    r12,QWORD PTR [rsp+0x28]
     8a9:	mov    r13,QWORD PTR [rsp+0x30]
     8ae:	mov    r14,QWORD PTR [rsp+0x38]
     8b3:	mov    r15,QWORD PTR [rsp+0x40]
     8b8:	add    rsp,0x50
     8bc:	mov    rsp,rbp
     8bf:	pop    rbp
     8c0:	ret
     8c1:	mov    rcx,r12
     8c4:	mov    QWORD PTR [rcx],rbx
     8c7:	mov    rax,r15
     8ca:	mov    QWORD PTR [rcx+0x8],rax
     8ce:	mov    rax,r13
     8d1:	mov    rbx,QWORD PTR [rsp+0x20]
     8d6:	mov    r12,QWORD PTR [rsp+0x28]
     8db:	mov    r13,QWORD PTR [rsp+0x30]
     8e0:	mov    r14,QWORD PTR [rsp+0x38]
     8e5:	mov    r15,QWORD PTR [rsp+0x40]
     8ea:	add    rsp,0x50
     8ee:	mov    rsp,rbp
     8f1:	pop    rbp
     8f2:	ret
     8f3:	mov    rcx,r12
     8f6:	mov    rdi,r14
     8f9:	mov    rax,QWORD PTR [rdi+0x10]
     8fd:	mov    rax,QWORD PTR [rax]
     900:	mov    QWORD PTR [rcx],0x1
     907:	mov    QWORD PTR [rcx+0x8],0x1
     90f:	mov    rbx,QWORD PTR [rsp+0x20]
     914:	mov    r12,QWORD PTR [rsp+0x28]
     919:	mov    r13,QWORD PTR [rsp+0x30]
     91e:	mov    r14,QWORD PTR [rsp+0x38]
     923:	mov    r15,QWORD PTR [rsp+0x40]
     928:	add    rsp,0x50
     92c:	mov    rsp,rbp
     92f:	pop    rbp
     930:	ret
     931:	add    BYTE PTR [rax],al
     933:	add    BYTE PTR [rax],al
     935:	add    BYTE PTR [rax],al
     937:	add    BYTE PTR [rsi],al
     939:	add    BYTE PTR [rax],al
     93b:	add    BYTE PTR [rax],al
     93d:	add    BYTE PTR [rax],al
	...

0000000000000940 <botlish_entry_9: peek<str, int>>:
     940:	push   rbp
     941:	mov    rbp,rsp
     944:	ud2

0000000000000946 <botlish_fn_10: scan_unquoted<str, int, int>>:
     946:	push   rbp
     947:	mov    rbp,rsp
     94a:	sub    rsp,0x80
     951:	mov    QWORD PTR [rsp+0x50],rbx
     956:	mov    QWORD PTR [rsp+0x58],r12
     95b:	mov    QWORD PTR [rsp+0x60],r13
     960:	mov    QWORD PTR [rsp+0x68],r14
     965:	mov    QWORD PTR [rsp+0x70],r15
     96a:	mov    QWORD PTR [rsp+0x30],rdi
     96f:	mov    QWORD PTR [rsp+0x18],0x0
     978:	mov    QWORD PTR [rsp],rsi
     97c:	mov    r15,rsi
     97f:	mov    QWORD PTR [rsp+0x8],rdx
     984:	mov    r14,rdx
     987:	mov    QWORD PTR [rsp+0x10],rcx
     98c:	lea    r13,[rsp+0x20]
     991:	mov    QWORD PTR [rsp+0x38],rcx
     996:	mov    rcx,r13
     999:	mov    rdx,QWORD PTR [rsp+0x38]
     99e:	mov    rsi,r15
     9a1:	mov    rdi,QWORD PTR [rsp+0x30]
     9a6:	call   9ab <botlish_fn_10+0x65>
			9a7: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     9ab:	mov    rsi,rax
     9ae:	mov    QWORD PTR [rsp+0x40],rax
     9b3:	test   rax,rsi
     9b6:	je     b0f <botlish_fn_10+0x1c9>
     9bc:	mov    rbx,QWORD PTR [rsp+0x20]
     9c1:	mov    r12,QWORD PTR [rsp+0x28]
     9c6:	mov    rdi,QWORD PTR [rsp+0x30]
     9cb:	mov    rcx,QWORD PTR [rdi+0x10]
     9cf:	mov    r8,QWORD PTR [rcx]
     9d2:	mov    rcx,r12
     9d5:	mov    rdx,rbx
     9d8:	mov    rsi,QWORD PTR [rsp+0x40]
     9dd:	call   9e2 <botlish_fn_10+0x9c>
			9de: R_X86_64_PLT32	rt_str_region_eq-0x4
     9e2:	cmp    rax,0x6
     9e6:	je     a27 <botlish_fn_10+0xe1>
     9ec:	mov    rdi,QWORD PTR [rsp+0x30]
     9f1:	mov    rax,QWORD PTR [rdi+0x10]
     9f5:	mov    r8,QWORD PTR [rax+0x8]
     9f9:	mov    rcx,r12
     9fc:	mov    rdx,rbx
     9ff:	mov    rsi,QWORD PTR [rsp+0x40]
     a04:	call   a09 <botlish_fn_10+0xc3>
			a05: R_X86_64_PLT32	rt_str_region_eq-0x4
     a09:	cmp    rax,0x6
     a0d:	je     a1d <botlish_fn_10+0xd7>
     a13:	mov    eax,0x2
     a18:	jmp    a2c <botlish_fn_10+0xe6>
     a1d:	mov    eax,0x6
     a22:	jmp    a2c <botlish_fn_10+0xe6>
     a27:	mov    eax,0x6
     a2c:	cmp    rax,0x6
     a30:	je     a71 <botlish_fn_10+0x12b>
     a36:	mov    rdi,QWORD PTR [rsp+0x30]
     a3b:	mov    rax,QWORD PTR [rdi+0x10]
     a3f:	mov    r8,QWORD PTR [rax+0x10]
     a43:	mov    rcx,r12
     a46:	mov    rdx,rbx
     a49:	mov    rsi,QWORD PTR [rsp+0x40]
     a4e:	call   a53 <botlish_fn_10+0x10d>
			a4f: R_X86_64_PLT32	rt_str_region_eq-0x4
     a53:	cmp    rax,0x6
     a57:	je     a67 <botlish_fn_10+0x121>
     a5d:	mov    eax,0x2
     a62:	jmp    a76 <botlish_fn_10+0x130>
     a67:	mov    eax,0x6
     a6c:	jmp    a76 <botlish_fn_10+0x130>
     a71:	mov    eax,0x6
     a76:	cmp    rax,0x6
     a7a:	je     af1 <botlish_fn_10+0x1ab>
     a80:	mov    QWORD PTR [rsp+0x18],0x3
     a89:	mov    rsi,QWORD PTR [rsp+0x38]
     a8e:	test   rsi,0x1
     a95:	je     abc <botlish_fn_10+0x176>
     a9b:	mov    rsi,QWORD PTR [rsp+0x38]
     aa0:	mov    rax,rsi
     aa3:	add    rax,0x2
     aa7:	seto   sil
     aab:	test   sil,sil
     aae:	jne    abc <botlish_fn_10+0x176>
     ab4:	mov    rsi,r15
     ab7:	jmp    ad3 <botlish_fn_10+0x18d>
     abc:	mov    edx,0x3
     ac1:	mov    rsi,QWORD PTR [rsp+0x38]
     ac6:	mov    rdi,QWORD PTR [rsp+0x30]
     acb:	call   ad0 <botlish_fn_10+0x18a>
			acc: R_X86_64_PLT32	rt_int_add-0x4
     ad0:	mov    rsi,r15
     ad3:	mov    QWORD PTR [rsp],rsi
     ad7:	mov    rdx,r14
     ada:	mov    QWORD PTR [rsp+0x8],rdx
     adf:	mov    QWORD PTR [rsp+0x10],rax
     ae4:	mov    r15,rsi
     ae7:	mov    QWORD PTR [rsp+0x38],rax
     aec:	jmp    996 <botlish_fn_10+0x50>
     af1:	mov    rdx,r14
     af4:	mov    rsi,r15
     af7:	mov    rdi,QWORD PTR [rsp+0x30]
     afc:	mov    rcx,QWORD PTR [rsp+0x38]
     b01:	call   b06 <botlish_fn_10+0x1c0>
			b02: R_X86_64_PLT32	rt_substr-0x4
     b06:	test   rax,rax
     b09:	jne    b3a <botlish_fn_10+0x1f4>
     b0f:	xor    rdx,rdx
     b12:	mov    rax,rdx
     b15:	mov    rbx,QWORD PTR [rsp+0x50]
     b1a:	mov    r12,QWORD PTR [rsp+0x58]
     b1f:	mov    r13,QWORD PTR [rsp+0x60]
     b24:	mov    r14,QWORD PTR [rsp+0x68]
     b29:	mov    r15,QWORD PTR [rsp+0x70]
     b2e:	add    rsp,0x80
     b35:	mov    rsp,rbp
     b38:	pop    rbp
     b39:	ret
     b3a:	mov    rdx,QWORD PTR [rsp+0x38]
     b3f:	mov    rbx,QWORD PTR [rsp+0x50]
     b44:	mov    r12,QWORD PTR [rsp+0x58]
     b49:	mov    r13,QWORD PTR [rsp+0x60]
     b4e:	mov    r14,QWORD PTR [rsp+0x68]
     b53:	mov    r15,QWORD PTR [rsp+0x70]
     b58:	add    rsp,0x80
     b5f:	mov    rsp,rbp
     b62:	pop    rbp
     b63:	ret

0000000000000b64 <botlish_entry_10: scan_unquoted<str, int, int>>:
     b64:	push   rbp
     b65:	mov    rbp,rsp
     b68:	ud2

0000000000000b6a <botlish_fn_11: scan_quoted<str, int, str>>:
     b6a:	push   rbp
     b6b:	mov    rbp,rsp
     b6e:	sub    rsp,0x70
     b72:	mov    QWORD PTR [rsp+0x40],rbx
     b77:	mov    QWORD PTR [rsp+0x48],r12
     b7c:	mov    QWORD PTR [rsp+0x50],r13
     b81:	mov    QWORD PTR [rsp+0x58],r14
     b86:	mov    QWORD PTR [rsp+0x60],r15
     b8b:	mov    r13,rdi
     b8e:	mov    QWORD PTR [rsp+0x18],0x0
     b97:	mov    QWORD PTR [rsp+0x20],0x0
     ba0:	mov    QWORD PTR [rsp],rsi
     ba4:	mov    QWORD PTR [rsp+0x8],rdx
     ba9:	mov    QWORD PTR [rsp+0x10],rcx
     bae:	lea    r12,[rsp+0x28]
     bb3:	mov    rbx,rsi
     bb6:	mov    r14,rdx
     bb9:	mov    r15,rcx
     bbc:	mov    rdx,r14
     bbf:	mov    rsi,rbx
     bc2:	mov    rdi,r13
     bc5:	call   bca <botlish_fn_11+0x60>
			bc6: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     bca:	test   rax,rax
     bcd:	je     de9 <botlish_fn_11+0x27f>
     bd3:	mov    QWORD PTR [rsp+0x18],rax
     bd8:	mov    rdi,r13
     bdb:	mov    QWORD PTR [rsp+0x38],rax
     be0:	mov    rcx,QWORD PTR [rdi+0x10]
     be4:	mov    rsi,QWORD PTR [rcx+0x18]
     be8:	mov    edx,0x1
     bed:	mov    ecx,0x3
     bf2:	mov    r8,QWORD PTR [rsp+0x38]
     bf7:	call   bfc <botlish_fn_11+0x92>
			bf8: R_X86_64_PLT32	rt_str_region_eq-0x4
     bfc:	cmp    rax,0x6
     c00:	je     c83 <botlish_fn_11+0x119>
     c06:	mov    QWORD PTR [rsp+0x20],0x3
     c0f:	mov    rsi,r14
     c12:	test   rsi,0x1
     c19:	je     c39 <botlish_fn_11+0xcf>
     c1f:	mov    rax,rsi
     c22:	add    rax,0x2
     c26:	seto   cl
     c29:	test   cl,cl
     c2b:	jne    c39 <botlish_fn_11+0xcf>
     c31:	mov    rsi,rax
     c34:	jmp    c49 <botlish_fn_11+0xdf>
     c39:	mov    edx,0x3
     c3e:	mov    rdi,r13
     c41:	call   c46 <botlish_fn_11+0xdc>
			c42: R_X86_64_PLT32	rt_int_add-0x4
     c46:	mov    rsi,rax
     c49:	mov    QWORD PTR [rsp+0x8],rsi
     c4e:	mov    r14,rsi
     c51:	mov    rsi,r15
     c54:	mov    rdx,QWORD PTR [rsp+0x38]
     c59:	mov    rdi,r13
     c5c:	call   c61 <botlish_fn_11+0xf7>
			c5d: R_X86_64_PLT32	rt_str_cat-0x4
     c61:	test   rax,rax
     c64:	je     de9 <botlish_fn_11+0x27f>
     c6a:	mov    QWORD PTR [rsp],rbx
     c6e:	mov    rsi,r14
     c71:	mov    QWORD PTR [rsp+0x8],rsi
     c76:	mov    QWORD PTR [rsp+0x10],rax
     c7b:	mov    r15,rax
     c7e:	jmp    bbc <botlish_fn_11+0x52>
     c83:	mov    QWORD PTR [rsp+0x18],0x3
     c8c:	mov    rsi,r14
     c8f:	test   rsi,0x1
     c96:	je     cb1 <botlish_fn_11+0x147>
     c9c:	mov    rsi,r14
     c9f:	mov    rdx,rsi
     ca2:	add    rdx,0x2
     ca6:	seto   al
     ca9:	test   al,al
     cab:	je     cc4 <botlish_fn_11+0x15a>
     cb1:	mov    edx,0x3
     cb6:	mov    rsi,r14
     cb9:	mov    rdi,r13
     cbc:	call   cc1 <botlish_fn_11+0x157>
			cbd: R_X86_64_PLT32	rt_int_add-0x4
     cc1:	mov    rdx,rax
     cc4:	mov    QWORD PTR [rsp+0x18],rdx
     cc9:	mov    rcx,r12
     ccc:	mov    rsi,rbx
     ccf:	mov    rdi,r13
     cd2:	call   cd7 <botlish_fn_11+0x16d>
			cd3: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     cd7:	test   rax,rax
     cda:	mov    rsi,rax
     cdd:	je     de9 <botlish_fn_11+0x27f>
     ce3:	mov    rdx,QWORD PTR [rsp+0x28]
     ce8:	mov    rcx,QWORD PTR [rsp+0x30]
     ced:	mov    rdi,r13
     cf0:	mov    rax,QWORD PTR [rdi+0x10]
     cf4:	mov    r8,QWORD PTR [rax+0x18]
     cf8:	call   cfd <botlish_fn_11+0x193>
			cf9: R_X86_64_PLT32	rt_str_region_eq-0x4
     cfd:	cmp    rax,0x6
     d01:	je     d74 <botlish_fn_11+0x20a>
     d07:	mov    QWORD PTR [rsp],0x3
     d0f:	mov    rsi,r14
     d12:	test   rsi,0x1
     d19:	je     d3c <botlish_fn_11+0x1d2>
     d1f:	mov    rsi,r14
     d22:	mov    rdx,rsi
     d25:	add    rdx,0x2
     d29:	seto   al
     d2c:	test   al,al
     d2e:	jne    d3c <botlish_fn_11+0x1d2>
     d34:	mov    rax,r15
     d37:	jmp    d52 <botlish_fn_11+0x1e8>
     d3c:	mov    edx,0x3
     d41:	mov    rsi,r14
     d44:	mov    rdi,r13
     d47:	call   d4c <botlish_fn_11+0x1e2>
			d48: R_X86_64_PLT32	rt_int_add-0x4
     d4c:	mov    rdx,rax
     d4f:	mov    rax,r15
     d52:	mov    rbx,QWORD PTR [rsp+0x40]
     d57:	mov    r12,QWORD PTR [rsp+0x48]
     d5c:	mov    r13,QWORD PTR [rsp+0x50]
     d61:	mov    r14,QWORD PTR [rsp+0x58]
     d66:	mov    r15,QWORD PTR [rsp+0x60]
     d6b:	add    rsp,0x70
     d6f:	mov    rsp,rbp
     d72:	pop    rbp
     d73:	ret
     d74:	mov    QWORD PTR [rsp+0x18],0x5
     d7d:	mov    rsi,r14
     d80:	test   rsi,0x1
     d87:	je     dad <botlish_fn_11+0x243>
     d8d:	mov    rsi,r14
     d90:	mov    rax,rsi
     d93:	add    rax,0x4
     d97:	seto   cl
     d9a:	test   cl,cl
     d9c:	jne    dad <botlish_fn_11+0x243>
     da2:	mov    rsi,rax
     da5:	mov    r14,rax
     da8:	jmp    dc3 <botlish_fn_11+0x259>
     dad:	mov    edx,0x5
     db2:	mov    rsi,r14
     db5:	mov    rdi,r13
     db8:	call   dbd <botlish_fn_11+0x253>
			db9: R_X86_64_PLT32	rt_int_add-0x4
     dbd:	mov    rsi,rax
     dc0:	mov    r14,rax
     dc3:	mov    QWORD PTR [rsp+0x8],rsi
     dc8:	mov    rdi,r13
     dcb:	mov    rax,QWORD PTR [rdi+0x10]
     dcf:	mov    rdx,QWORD PTR [rax+0x18]
     dd3:	mov    QWORD PTR [rsp+0x18],rdx
     dd8:	mov    rsi,r15
     ddb:	call   de0 <botlish_fn_11+0x276>
			ddc: R_X86_64_PLT32	rt_str_cat-0x4
     de0:	test   rax,rax
     de3:	jne    e11 <botlish_fn_11+0x2a7>
     de9:	xor    rdx,rdx
     dec:	mov    rax,rdx
     def:	mov    rbx,QWORD PTR [rsp+0x40]
     df4:	mov    r12,QWORD PTR [rsp+0x48]
     df9:	mov    r13,QWORD PTR [rsp+0x50]
     dfe:	mov    r14,QWORD PTR [rsp+0x58]
     e03:	mov    r15,QWORD PTR [rsp+0x60]
     e08:	add    rsp,0x70
     e0c:	mov    rsp,rbp
     e0f:	pop    rbp
     e10:	ret
     e11:	mov    QWORD PTR [rsp],rbx
     e15:	mov    rsi,r14
     e18:	mov    QWORD PTR [rsp+0x8],rsi
     e1d:	mov    QWORD PTR [rsp+0x10],rax
     e22:	mov    r15,rax
     e25:	jmp    bbc <botlish_fn_11+0x52>

0000000000000e2a <botlish_entry_11: scan_quoted<str, int, str>>:
     e2a:	push   rbp
     e2b:	mov    rbp,rsp
     e2e:	ud2

0000000000000e30 <botlish_fn_12: scan_field<str, int>>:
     e30:	push   rbp
     e31:	mov    rbp,rsp
     e34:	sub    rsp,0x50
     e38:	mov    QWORD PTR [rsp+0x30],rbx
     e3d:	mov    QWORD PTR [rsp+0x38],r12
     e42:	mov    QWORD PTR [rsp+0x40],r13
     e47:	mov    r12,rdi
     e4a:	mov    r13,rdx
     e4d:	mov    QWORD PTR [rsp+0x10],0x0
     e56:	mov    QWORD PTR [rsp],rsi
     e5a:	mov    rbx,rsi
     e5d:	mov    QWORD PTR [rsp+0x8],rdx
     e62:	lea    rcx,[rsp+0x18]
     e67:	mov    rdx,r13
     e6a:	mov    rsi,rbx
     e6d:	mov    rdi,r12
     e70:	call   e75 <botlish_fn_12+0x45>
			e71: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     e75:	test   rax,rax
     e78:	mov    rsi,rax
     e7b:	je     f45 <botlish_fn_12+0x115>
     e81:	mov    rdx,QWORD PTR [rsp+0x18]
     e86:	mov    rcx,QWORD PTR [rsp+0x20]
     e8b:	mov    rdi,r12
     e8e:	mov    rax,QWORD PTR [rdi+0x10]
     e92:	mov    r8,QWORD PTR [rax+0x18]
     e96:	call   e9b <botlish_fn_12+0x6b>
			e97: R_X86_64_PLT32	rt_str_region_eq-0x4
     e9b:	cmp    rax,0x6
     e9f:	je     ed7 <botlish_fn_12+0xa7>
     ea5:	mov    rcx,r13
     ea8:	mov    rsi,rbx
     eab:	mov    rdi,r12
     eae:	mov    rdx,rcx
     eb1:	call   eb6 <botlish_fn_12+0x86>
			eb2: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
     eb6:	test   rax,rax
     eb9:	je     f45 <botlish_fn_12+0x115>
     ebf:	mov    rbx,QWORD PTR [rsp+0x30]
     ec4:	mov    r12,QWORD PTR [rsp+0x38]
     ec9:	mov    r13,QWORD PTR [rsp+0x40]
     ece:	add    rsp,0x50
     ed2:	mov    rsp,rbp
     ed5:	pop    rbp
     ed6:	ret
     ed7:	mov    rcx,r13
     eda:	mov    QWORD PTR [rsp+0x10],0x3
     ee3:	test   rcx,0x1
     eea:	jne    ef8 <botlish_fn_12+0xc8>
     ef0:	mov    r13,rcx
     ef3:	jmp    f0d <botlish_fn_12+0xdd>
     ef8:	mov    rdx,rcx
     efb:	add    rdx,0x2
     eff:	mov    r13,rcx
     f02:	seto   al
     f05:	test   al,al
     f07:	je     f20 <botlish_fn_12+0xf0>
     f0d:	mov    edx,0x3
     f12:	mov    rsi,r13
     f15:	mov    rdi,r12
     f18:	call   f1d <botlish_fn_12+0xed>
			f19: R_X86_64_PLT32	rt_int_add-0x4
     f1d:	mov    rdx,rax
     f20:	mov    QWORD PTR [rsp+0x8],rdx
     f25:	mov    rdi,r12
     f28:	mov    rax,QWORD PTR [rdi+0x10]
     f2c:	mov    rcx,QWORD PTR [rax]
     f2f:	mov    QWORD PTR [rsp+0x10],rcx
     f34:	mov    rsi,rbx
     f37:	call   f3c <botlish_fn_12+0x10c>
			f38: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
     f3c:	test   rax,rax
     f3f:	jne    f63 <botlish_fn_12+0x133>
     f45:	xor    rdx,rdx
     f48:	mov    rax,rdx
     f4b:	mov    rbx,QWORD PTR [rsp+0x30]
     f50:	mov    r12,QWORD PTR [rsp+0x38]
     f55:	mov    r13,QWORD PTR [rsp+0x40]
     f5a:	add    rsp,0x50
     f5e:	mov    rsp,rbp
     f61:	pop    rbp
     f62:	ret
     f63:	mov    rbx,QWORD PTR [rsp+0x30]
     f68:	mov    r12,QWORD PTR [rsp+0x38]
     f6d:	mov    r13,QWORD PTR [rsp+0x40]
     f72:	add    rsp,0x50
     f76:	mov    rsp,rbp
     f79:	pop    rbp
     f7a:	ret

0000000000000f7b <botlish_entry_12: scan_field<str, int>>:
     f7b:	push   rbp
     f7c:	mov    rbp,rsp
     f7f:	ud2

0000000000000f81 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
     f81:	push   rbp
     f82:	mov    rbp,rsp
     f85:	sub    rsp,0x90
     f8c:	mov    QWORD PTR [rsp+0x60],rbx
     f91:	mov    QWORD PTR [rsp+0x68],r12
     f96:	mov    QWORD PTR [rsp+0x70],r13
     f9b:	mov    QWORD PTR [rsp+0x78],r14
     fa0:	mov    QWORD PTR [rsp+0x80],r15
     fa8:	mov    r15,rdi
     fab:	mov    QWORD PTR [rsp+0x20],0x0
     fb4:	mov    QWORD PTR [rsp],rsi
     fb8:	mov    QWORD PTR [rsp+0x8],rdx
     fbd:	mov    QWORD PTR [rsp+0x10],rcx
     fc2:	mov    QWORD PTR [rsp+0x18],r8
     fc7:	lea    r14,[rsp+0x28]
     fcc:	mov    rbx,rsi
     fcf:	mov    r12,r8
     fd2:	mov    r13,rcx
     fd5:	mov    rsi,rbx
     fd8:	mov    rdi,r15
     fdb:	call   fe0 <botlish_fn_13+0x5f>
			fdc: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
     fe0:	test   rax,rax
     fe3:	je     10fe <botlish_fn_13+0x17d>
     fe9:	mov    QWORD PTR [rsp+0x8],rax
     fee:	mov    rcx,rax
     ff1:	mov    QWORD PTR [rsp+0x20],rdx
     ff6:	mov    QWORD PTR [rsp+0x50],rdx
     ffb:	mov    rsi,r13
     ffe:	mov    rdx,r12
    1001:	mov    rdi,r15
    1004:	call   1009 <botlish_fn_13+0x88>
			1005: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    1009:	test   rax,rax
    100c:	je     10fe <botlish_fn_13+0x17d>
    1012:	mov    QWORD PTR [rsp+0x8],rax
    1017:	mov    QWORD PTR [rsp+0x40],rax
    101c:	mov    QWORD PTR [rsp+0x10],rdx
    1021:	mov    QWORD PTR [rsp+0x48],rdx
    1026:	mov    rcx,r14
    1029:	mov    rdx,QWORD PTR [rsp+0x50]
    102e:	mov    rsi,rbx
    1031:	mov    rdi,r15
    1034:	call   1039 <botlish_fn_13+0xb8>
			1035: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1039:	test   rax,rax
    103c:	mov    QWORD PTR [rsp+0x38],rax
    1041:	je     10fe <botlish_fn_13+0x17d>
    1047:	mov    r12,QWORD PTR [rsp+0x28]
    104c:	mov    r13,QWORD PTR [rsp+0x30]
    1051:	mov    rdi,r15
    1054:	mov    rcx,QWORD PTR [rdi+0x10]
    1058:	mov    r8,QWORD PTR [rcx+0x8]
    105c:	mov    rcx,r13
    105f:	mov    rdx,r12
    1062:	mov    rsi,QWORD PTR [rsp+0x38]
    1067:	call   106c <botlish_fn_13+0xeb>
			1068: R_X86_64_PLT32	rt_str_region_eq-0x4
    106c:	cmp    rax,0x6
    1070:	je     11ac <botlish_fn_13+0x22b>
    1076:	mov    rdi,r15
    1079:	mov    rax,QWORD PTR [rdi+0x10]
    107d:	mov    r8,QWORD PTR [rax+0x10]
    1081:	mov    rcx,r13
    1084:	mov    rdx,r12
    1087:	mov    rsi,QWORD PTR [rsp+0x38]
    108c:	call   1091 <botlish_fn_13+0x110>
			108d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1091:	cmp    rax,0x6
    1095:	je     10e3 <botlish_fn_13+0x162>
    109b:	mov    rdx,QWORD PTR [rsp+0x48]
    10a0:	mov    rsi,QWORD PTR [rsp+0x40]
    10a5:	mov    rdi,r15
    10a8:	call   10ad <botlish_fn_13+0x12c>
			10a9: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    10ad:	test   rax,rax
    10b0:	je     10fe <botlish_fn_13+0x17d>
    10b6:	mov    rdx,QWORD PTR [rsp+0x50]
    10bb:	mov    rbx,QWORD PTR [rsp+0x60]
    10c0:	mov    r12,QWORD PTR [rsp+0x68]
    10c5:	mov    r13,QWORD PTR [rsp+0x70]
    10ca:	mov    r14,QWORD PTR [rsp+0x78]
    10cf:	mov    r15,QWORD PTR [rsp+0x80]
    10d7:	add    rsp,0x90
    10de:	mov    rsp,rbp
    10e1:	pop    rbp
    10e2:	ret
    10e3:	mov    rdx,QWORD PTR [rsp+0x48]
    10e8:	mov    rsi,QWORD PTR [rsp+0x40]
    10ed:	mov    rdi,r15
    10f0:	call   10f5 <botlish_fn_13+0x174>
			10f1: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    10f5:	test   rax,rax
    10f8:	jne    112c <botlish_fn_13+0x1ab>
    10fe:	xor    rdx,rdx
    1101:	mov    rax,rdx
    1104:	mov    rbx,QWORD PTR [rsp+0x60]
    1109:	mov    r12,QWORD PTR [rsp+0x68]
    110e:	mov    r13,QWORD PTR [rsp+0x70]
    1113:	mov    r14,QWORD PTR [rsp+0x78]
    1118:	mov    r15,QWORD PTR [rsp+0x80]
    1120:	add    rsp,0x90
    1127:	mov    rsp,rbp
    112a:	pop    rbp
    112b:	ret
    112c:	mov    QWORD PTR [rsp],rax
    1130:	mov    r12,rax
    1133:	mov    QWORD PTR [rsp+0x8],0x3
    113c:	mov    rdx,QWORD PTR [rsp+0x50]
    1141:	test   rdx,0x1
    1148:	je     116c <botlish_fn_13+0x1eb>
    114e:	mov    rdx,QWORD PTR [rsp+0x50]
    1153:	add    rdx,0x2
    1157:	seto   r10b
    115b:	test   r10b,r10b
    115e:	jne    116c <botlish_fn_13+0x1eb>
    1164:	mov    rax,r12
    1167:	jmp    1184 <botlish_fn_13+0x203>
    116c:	mov    edx,0x3
    1171:	mov    rsi,QWORD PTR [rsp+0x50]
    1176:	mov    rdi,r15
    1179:	call   117e <botlish_fn_13+0x1fd>
			117a: R_X86_64_PLT32	rt_int_add-0x4
    117e:	mov    rdx,rax
    1181:	mov    rax,r12
    1184:	mov    rbx,QWORD PTR [rsp+0x60]
    1189:	mov    r12,QWORD PTR [rsp+0x68]
    118e:	mov    r13,QWORD PTR [rsp+0x70]
    1193:	mov    r14,QWORD PTR [rsp+0x78]
    1198:	mov    r15,QWORD PTR [rsp+0x80]
    11a0:	add    rsp,0x90
    11a7:	mov    rsp,rbp
    11aa:	pop    rbp
    11ab:	ret
    11ac:	mov    rsi,QWORD PTR [rsp+0x50]
    11b1:	mov    edx,0x3
    11b6:	mov    rcx,rdx
    11b9:	mov    QWORD PTR [rsp+0x18],0x3
    11c2:	test   rsi,0x1
    11c9:	jne    11d7 <botlish_fn_13+0x256>
    11cf:	mov    rdx,rcx
    11d2:	jmp    11ec <botlish_fn_13+0x26b>
    11d7:	mov    rdx,rsi
    11da:	add    rdx,0x2
    11de:	seto   al
    11e1:	test   al,al
    11e3:	je     11f7 <botlish_fn_13+0x276>
    11e9:	mov    rdx,rcx
    11ec:	mov    rdi,r15
    11ef:	call   11f4 <botlish_fn_13+0x273>
			11f0: R_X86_64_PLT32	rt_int_add-0x4
    11f4:	mov    rdx,rax
    11f7:	mov    QWORD PTR [rsp],rbx
    11fb:	mov    QWORD PTR [rsp+0x8],rdx
    1200:	mov    rsi,QWORD PTR [rsp+0x40]
    1205:	mov    QWORD PTR [rsp+0x10],rsi
    120a:	mov    r11,QWORD PTR [rsp+0x48]
    120f:	mov    QWORD PTR [rsp+0x18],r11
    1214:	mov    r12,r11
    1217:	mov    r13,rsi
    121a:	jmp    fd5 <botlish_fn_13+0x54>

000000000000121f <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    121f:	push   rbp
    1220:	mov    rbp,rsp
    1223:	ud2
    1225:	add    BYTE PTR [rax],al
	...

0000000000001228 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    1228:	push   rbp
    1229:	mov    rbp,rsp
    122c:	sub    rsp,0x60
    1230:	mov    QWORD PTR [rsp+0x30],rbx
    1235:	mov    QWORD PTR [rsp+0x38],r12
    123a:	mov    QWORD PTR [rsp+0x40],r13
    123f:	mov    QWORD PTR [rsp+0x48],r14
    1244:	mov    QWORD PTR [rsp+0x50],r15
    1249:	mov    r13,rdi
    124c:	mov    QWORD PTR [rsp+0x20],0x0
    1255:	mov    QWORD PTR [rsp+0x28],0x0
    125e:	mov    QWORD PTR [rsp],rsi
    1262:	mov    QWORD PTR [rsp+0x8],rdx
    1267:	mov    r12,rdx
    126a:	mov    QWORD PTR [rsp+0x10],rcx
    126f:	mov    QWORD PTR [rsp+0x18],r8
    1274:	mov    rbx,rsi
    1277:	mov    r14,r8
    127a:	mov    r15,rcx
    127d:	mov    rsi,rbx
    1280:	mov    rdi,r13
    1283:	call   1288 <botlish_fn_14+0x60>
			1284: R_X86_64_PLT32	rt_str_len-0x4
    1288:	mov    rcx,r12
    128b:	and    rcx,rax
    128e:	mov    rdx,rax
    1291:	test   rcx,0x1
    1298:	jne    12be <botlish_fn_14+0x96>
    129e:	mov    rsi,r12
    12a1:	mov    rdi,r13
    12a4:	call   12a9 <botlish_fn_14+0x81>
			12a5: R_X86_64_PLT32	rt_int_cmp-0x4
    12a9:	mov    ecx,0x2
    12ae:	test   rax,rax
    12b1:	cmovge rcx,QWORD PTR [rip+0x107]        # 13c0 <botlish_fn_14+0x198>
    12b9:	jmp    12d1 <botlish_fn_14+0xa9>
    12be:	mov    ecx,0x2
    12c3:	mov    rax,r12
    12c6:	cmp    rax,rdx
    12c9:	cmovge rcx,QWORD PTR [rip+0xef]        # 13c0 <botlish_fn_14+0x198>
    12d1:	cmp    rcx,0x6
    12d5:	je     135b <botlish_fn_14+0x133>
    12db:	mov    rdi,r13
    12de:	call   12e3 <botlish_fn_14+0xbb>
			12df: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    12e3:	test   rax,rax
    12e6:	je     1372 <botlish_fn_14+0x14a>
    12ec:	mov    QWORD PTR [rsp+0x20],rax
    12f1:	mov    rcx,rax
    12f4:	mov    QWORD PTR [rsp+0x28],rdx
    12f9:	mov    r8,rdx
    12fc:	mov    rdx,r12
    12ff:	mov    rsi,rbx
    1302:	mov    rdi,r13
    1305:	call   130a <botlish_fn_14+0xe2>
			1306: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    130a:	test   rax,rax
    130d:	je     1372 <botlish_fn_14+0x14a>
    1313:	mov    QWORD PTR [rsp+0x8],rax
    1318:	mov    rcx,rax
    131b:	mov    QWORD PTR [rsp+0x20],rdx
    1320:	mov    r12,rdx
    1323:	mov    rsi,r15
    1326:	mov    rdx,r14
    1329:	mov    rdi,r13
    132c:	call   1331 <botlish_fn_14+0x109>
			132d: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1331:	test   rax,rax
    1334:	je     1372 <botlish_fn_14+0x14a>
    133a:	mov    QWORD PTR [rsp],rbx
    133e:	mov    rcx,r12
    1341:	mov    QWORD PTR [rsp+0x8],rcx
    1346:	mov    QWORD PTR [rsp+0x10],rax
    134b:	mov    QWORD PTR [rsp+0x18],rdx
    1350:	mov    r14,rdx
    1353:	mov    r15,rax
    1356:	jmp    127d <botlish_fn_14+0x55>
    135b:	mov    rdx,r14
    135e:	mov    rsi,r15
    1361:	mov    rdi,r13
    1364:	call   1369 <botlish_fn_14+0x141>
			1365: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1369:	test   rax,rax
    136c:	jne    1397 <botlish_fn_14+0x16f>
    1372:	xor    rax,rax
    1375:	mov    rbx,QWORD PTR [rsp+0x30]
    137a:	mov    r12,QWORD PTR [rsp+0x38]
    137f:	mov    r13,QWORD PTR [rsp+0x40]
    1384:	mov    r14,QWORD PTR [rsp+0x48]
    1389:	mov    r15,QWORD PTR [rsp+0x50]
    138e:	add    rsp,0x60
    1392:	mov    rsp,rbp
    1395:	pop    rbp
    1396:	ret
    1397:	mov    rbx,QWORD PTR [rsp+0x30]
    139c:	mov    r12,QWORD PTR [rsp+0x38]
    13a1:	mov    r13,QWORD PTR [rsp+0x40]
    13a6:	mov    r14,QWORD PTR [rsp+0x48]
    13ab:	mov    r15,QWORD PTR [rsp+0x50]
    13b0:	add    rsp,0x60
    13b4:	mov    rsp,rbp
    13b7:	pop    rbp
    13b8:	ret
    13b9:	add    BYTE PTR [rax],al
    13bb:	add    BYTE PTR [rax],al
    13bd:	add    BYTE PTR [rax],al
    13bf:	add    BYTE PTR [rsi],al
    13c1:	add    BYTE PTR [rax],al
    13c3:	add    BYTE PTR [rax],al
    13c5:	add    BYTE PTR [rax],al
	...

00000000000013c8 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    13c8:	push   rbp
    13c9:	mov    rbp,rsp
    13cc:	mov    rsi,QWORD PTR [rdx]
    13cf:	mov    r9,QWORD PTR [rdx+0x8]
    13d3:	mov    rcx,QWORD PTR [rdx+0x10]
    13d7:	mov    r8,QWORD PTR [rdx+0x18]
    13db:	mov    rdx,r9
    13de:	call   13e3 <botlish_entry_14+0x1b>
			13df: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    13e3:	mov    rsp,rbp
    13e6:	pop    rbp
    13e7:	ret

00000000000013e8 <botlish_fn_15: csv_parse<str>>:
    13e8:	push   rbp
    13e9:	mov    rbp,rsp
    13ec:	sub    rsp,0x30
    13f0:	mov    QWORD PTR [rsp+0x20],r12
    13f5:	mov    QWORD PTR [rsp+0x28],r13
    13fa:	mov    r13,rdi
    13fd:	mov    QWORD PTR [rsp+0x10],0x0
    1406:	mov    QWORD PTR [rsp+0x18],0x0
    140f:	mov    QWORD PTR [rsp],rsi
    1413:	mov    r12,rsi
    1416:	mov    QWORD PTR [rsp+0x8],0x1
    141f:	mov    rdi,r13
    1422:	call   1427 <botlish_fn_15+0x3f>
			1423: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1427:	test   rax,rax
    142a:	je     1459 <botlish_fn_15+0x71>
    1430:	mov    QWORD PTR [rsp+0x10],rax
    1435:	mov    rcx,rax
    1438:	mov    QWORD PTR [rsp+0x18],rdx
    143d:	mov    r8,rdx
    1440:	mov    edx,0x1
    1445:	mov    rsi,r12
    1448:	mov    rdi,r13
    144b:	call   1450 <botlish_fn_15+0x68>
			144c: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1450:	test   rax,rax
    1453:	jne    146f <botlish_fn_15+0x87>
    1459:	xor    rax,rax
    145c:	mov    r12,QWORD PTR [rsp+0x20]
    1461:	mov    r13,QWORD PTR [rsp+0x28]
    1466:	add    rsp,0x30
    146a:	mov    rsp,rbp
    146d:	pop    rbp
    146e:	ret
    146f:	mov    r12,QWORD PTR [rsp+0x20]
    1474:	mov    r13,QWORD PTR [rsp+0x28]
    1479:	add    rsp,0x30
    147d:	mov    rsp,rbp
    1480:	pop    rbp
    1481:	ret

0000000000001482 <botlish_entry_15: csv_parse<str>>:
    1482:	push   rbp
    1483:	mov    rbp,rsp
    1486:	mov    rsi,QWORD PTR [rdx]
    1489:	call   148e <botlish_entry_15+0xc>
			148a: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    148e:	mov    rsp,rbp
    1491:	pop    rbp
    1492:	ret

0000000000001493 <botlish_fn_16: ht_min_capacity<generic>>:
    1493:	push   rbp
    1494:	mov    rbp,rsp
    1497:	mov    eax,0x11
    149c:	mov    rsp,rbp
    149f:	pop    rbp
    14a0:	ret

00000000000014a1 <botlish_entry_16: ht_min_capacity<generic>>:
    14a1:	push   rbp
    14a2:	mov    rbp,rsp
    14a5:	call   14aa <botlish_entry_16+0x9>
			14a6: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    14aa:	mov    rsp,rbp
    14ad:	pop    rbp
    14ae:	ret

00000000000014af <botlish_fn_17: ht_empty_state<generic>>:
    14af:	push   rbp
    14b0:	mov    rbp,rsp
    14b3:	mov    eax,0x1
    14b8:	mov    rsp,rbp
    14bb:	pop    rbp
    14bc:	ret

00000000000014bd <botlish_entry_17: ht_empty_state<generic>>:
    14bd:	push   rbp
    14be:	mov    rbp,rsp
    14c1:	call   14c6 <botlish_entry_17+0x9>
			14c2: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    14c6:	mov    rsp,rbp
    14c9:	pop    rbp
    14ca:	ret

00000000000014cb <botlish_fn_18: ht_occupied_state<generic>>:
    14cb:	push   rbp
    14cc:	mov    rbp,rsp
    14cf:	mov    eax,0x3
    14d4:	mov    rsp,rbp
    14d7:	pop    rbp
    14d8:	ret

00000000000014d9 <botlish_entry_18: ht_occupied_state<generic>>:
    14d9:	push   rbp
    14da:	mov    rbp,rsp
    14dd:	call   14e2 <botlish_entry_18+0x9>
			14de: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    14e2:	mov    rsp,rbp
    14e5:	pop    rbp
    14e6:	ret

00000000000014e7 <botlish_fn_19: ht_tombstone_state<generic>>:
    14e7:	push   rbp
    14e8:	mov    rbp,rsp
    14eb:	mov    eax,0x5
    14f0:	mov    rsp,rbp
    14f3:	pop    rbp
    14f4:	ret

00000000000014f5 <botlish_entry_19: ht_tombstone_state<generic>>:
    14f5:	push   rbp
    14f6:	mov    rbp,rsp
    14f9:	call   14fe <botlish_entry_19+0x9>
			14fa: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    14fe:	mov    rsp,rbp
    1501:	pop    rbp
    1502:	ret
    1503:	add    BYTE PTR [rax],al
    1505:	add    BYTE PTR [rax],al
	...

0000000000001508 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    1508:	push   rbp
    1509:	mov    rbp,rsp
    150c:	sub    rsp,0x40
    1510:	mov    QWORD PTR [rsp+0x20],rbx
    1515:	mov    QWORD PTR [rsp+0x28],r12
    151a:	mov    QWORD PTR [rsp+0x30],r13
    151f:	mov    QWORD PTR [rsp+0x38],r14
    1524:	mov    r13,rdi
    1527:	mov    QWORD PTR [rsp+0x18],0x0
    1530:	mov    QWORD PTR [rsp],rsi
    1534:	mov    rbx,rsi
    1537:	mov    QWORD PTR [rsp+0x8],rdx
    153c:	mov    QWORD PTR [rsp+0x10],rcx
    1541:	mov    r12,rcx
    1544:	mov    rsi,rdx
    1547:	mov    rax,rsi
    154a:	and    rax,r12
    154d:	mov    r14,rsi
    1550:	test   rax,0x1
    1556:	jne    157f <botlish_fn_20+0x77>
    155c:	mov    rdx,r12
    155f:	mov    rsi,r14
    1562:	mov    rdi,r13
    1565:	call   156a <botlish_fn_20+0x62>
			1566: R_X86_64_PLT32	rt_int_cmp-0x4
    156a:	mov    ecx,0x2
    156f:	test   rax,rax
    1572:	cmovge rcx,QWORD PTR [rip+0xf6]        # 1670 <botlish_fn_20+0x168>
    157a:	jmp    1592 <botlish_fn_20+0x8a>
    157f:	mov    ecx,0x2
    1584:	mov    rsi,r14
    1587:	cmp    rsi,r12
    158a:	cmovge rcx,QWORD PTR [rip+0xde]        # 1670 <botlish_fn_20+0x168>
    1592:	cmp    rcx,0x6
    1596:	je     1648 <botlish_fn_20+0x140>
    159c:	mov    rdi,r13
    159f:	call   15a4 <botlish_fn_20+0x9c>
			15a0: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    15a4:	test   rax,rax
    15a7:	je     15c9 <botlish_fn_20+0xc1>
    15ad:	mov    ecx,0x1
    15b2:	mov    rdx,r14
    15b5:	mov    rsi,rbx
    15b8:	mov    rdi,r13
    15bb:	call   15c0 <botlish_fn_20+0xb8>
			15bc: R_X86_64_PLT32	rt_mutarray_set-0x4
    15c0:	test   rax,rax
    15c3:	jne    15e9 <botlish_fn_20+0xe1>
    15c9:	xor    rax,rax
    15cc:	mov    rbx,QWORD PTR [rsp+0x20]
    15d1:	mov    r12,QWORD PTR [rsp+0x28]
    15d6:	mov    r13,QWORD PTR [rsp+0x30]
    15db:	mov    r14,QWORD PTR [rsp+0x38]
    15e0:	add    rsp,0x40
    15e4:	mov    rsp,rbp
    15e7:	pop    rbp
    15e8:	ret
    15e9:	mov    QWORD PTR [rsp+0x18],0x3
    15f2:	mov    rsi,r14
    15f5:	test   rsi,0x1
    15fc:	je     161f <botlish_fn_20+0x117>
    1602:	mov    rsi,r14
    1605:	mov    rcx,rsi
    1608:	add    rcx,0x2
    160c:	seto   al
    160f:	test   al,al
    1611:	jne    161f <botlish_fn_20+0x117>
    1617:	mov    r14,rcx
    161a:	jmp    1632 <botlish_fn_20+0x12a>
    161f:	mov    edx,0x3
    1624:	mov    rsi,r14
    1627:	mov    rdi,r13
    162a:	call   162f <botlish_fn_20+0x127>
			162b: R_X86_64_PLT32	rt_int_add-0x4
    162f:	mov    r14,rax
    1632:	mov    QWORD PTR [rsp],rbx
    1636:	mov    rsi,r14
    1639:	mov    QWORD PTR [rsp+0x8],rsi
    163e:	mov    QWORD PTR [rsp+0x10],r12
    1643:	jmp    1547 <botlish_fn_20+0x3f>
    1648:	mov    eax,0xa
    164d:	mov    rbx,QWORD PTR [rsp+0x20]
    1652:	mov    r12,QWORD PTR [rsp+0x28]
    1657:	mov    r13,QWORD PTR [rsp+0x30]
    165c:	mov    r14,QWORD PTR [rsp+0x38]
    1661:	add    rsp,0x40
    1665:	mov    rsp,rbp
    1668:	pop    rbp
    1669:	ret
    166a:	add    BYTE PTR [rax],al
    166c:	add    BYTE PTR [rax],al
    166e:	add    BYTE PTR [rax],al
    1670:	(bad)
    1671:	add    BYTE PTR [rax],al
    1673:	add    BYTE PTR [rax],al
    1675:	add    BYTE PTR [rax],al
	...

0000000000001678 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    1678:	push   rbp
    1679:	mov    rbp,rsp
    167c:	mov    rsi,QWORD PTR [rdx]
    167f:	mov    r8,QWORD PTR [rdx+0x8]
    1683:	mov    rcx,QWORD PTR [rdx+0x10]
    1687:	mov    rdx,r8
    168a:	call   168f <botlish_entry_20+0x17>
			168b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    168f:	mov    rsp,rbp
    1692:	pop    rbp
    1693:	ret

0000000000001694 <botlish_fn_21: ht_alloc<int>>:
    1694:	push   rbp
    1695:	mov    rbp,rsp
    1698:	sub    rsp,0x50
    169c:	mov    QWORD PTR [rsp+0x20],rbx
    16a1:	mov    QWORD PTR [rsp+0x28],r12
    16a6:	mov    QWORD PTR [rsp+0x30],r13
    16ab:	mov    QWORD PTR [rsp+0x38],r14
    16b0:	mov    QWORD PTR [rsp+0x40],r15
    16b5:	mov    rbx,rdi
    16b8:	mov    QWORD PTR [rsp+0x8],0x0
    16c1:	mov    QWORD PTR [rsp+0x10],0x0
    16ca:	mov    QWORD PTR [rsp+0x18],0x0
    16d3:	mov    QWORD PTR [rsp],rsi
    16d7:	mov    r13,rsi
    16da:	mov    rsi,r13
    16dd:	mov    rdi,rbx
    16e0:	call   16e5 <botlish_fn_21+0x51>
			16e1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    16e5:	test   rax,rax
    16e8:	je     1804 <botlish_fn_21+0x170>
    16ee:	mov    QWORD PTR [rsp+0x8],rax
    16f3:	mov    r12,rax
    16f6:	mov    edx,0x1
    16fb:	mov    QWORD PTR [rsp+0x10],0x1
    1704:	mov    rcx,r13
    1707:	mov    rsi,r12
    170a:	mov    rdi,rbx
    170d:	call   1712 <botlish_fn_21+0x7e>
			170e: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1712:	test   rax,rax
    1715:	je     1804 <botlish_fn_21+0x170>
    171b:	mov    rsi,r13
    171e:	mov    rdi,rbx
    1721:	call   1726 <botlish_fn_21+0x92>
			1722: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1726:	test   rax,rax
    1729:	je     1804 <botlish_fn_21+0x170>
    172f:	mov    QWORD PTR [rsp+0x10],rax
    1734:	mov    rsi,r13
    1737:	mov    r14,rax
    173a:	mov    rdi,rbx
    173d:	call   1742 <botlish_fn_21+0xae>
			173e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1742:	test   rax,rax
    1745:	je     1804 <botlish_fn_21+0x170>
    174b:	mov    QWORD PTR [rsp],rax
    174f:	mov    r13,rax
    1752:	mov    esi,0xb
    1757:	mov    QWORD PTR [rsp+0x18],0xb
    1760:	mov    rdi,rbx
    1763:	call   1768 <botlish_fn_21+0xd4>
			1764: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1768:	test   rax,rax
    176b:	mov    r15,rax
    176e:	je     1804 <botlish_fn_21+0x170>
    1774:	mov    edx,0x1
    1779:	mov    rcx,r12
    177c:	mov    rsi,r15
    177f:	mov    rdi,rbx
    1782:	call   1787 <botlish_fn_21+0xf3>
			1783: R_X86_64_PLT32	rt_mutarray_set-0x4
    1787:	test   rax,rax
    178a:	je     1804 <botlish_fn_21+0x170>
    1790:	mov    edx,0x3
    1795:	mov    rcx,r14
    1798:	mov    rsi,r15
    179b:	mov    rdi,rbx
    179e:	call   17a3 <botlish_fn_21+0x10f>
			179f: R_X86_64_PLT32	rt_mutarray_set-0x4
    17a3:	test   rax,rax
    17a6:	je     1804 <botlish_fn_21+0x170>
    17ac:	mov    edx,0x5
    17b1:	mov    rcx,r13
    17b4:	mov    rsi,r15
    17b7:	mov    rdi,rbx
    17ba:	call   17bf <botlish_fn_21+0x12b>
			17bb: R_X86_64_PLT32	rt_mutarray_set-0x4
    17bf:	test   rax,rax
    17c2:	je     1804 <botlish_fn_21+0x170>
    17c8:	mov    edx,0x7
    17cd:	mov    ecx,0x1
    17d2:	mov    rsi,r15
    17d5:	mov    rdi,rbx
    17d8:	call   17dd <botlish_fn_21+0x149>
			17d9: R_X86_64_PLT32	rt_mutarray_set-0x4
    17dd:	test   rax,rax
    17e0:	je     1804 <botlish_fn_21+0x170>
    17e6:	mov    edx,0x9
    17eb:	mov    ecx,0x1
    17f0:	mov    rdi,rbx
    17f3:	mov    rsi,r15
    17f6:	call   17fb <botlish_fn_21+0x167>
			17f7: R_X86_64_PLT32	rt_mutarray_set-0x4
    17fb:	test   rax,rax
    17fe:	jne    1829 <botlish_fn_21+0x195>
    1804:	xor    rax,rax
    1807:	mov    rbx,QWORD PTR [rsp+0x20]
    180c:	mov    r12,QWORD PTR [rsp+0x28]
    1811:	mov    r13,QWORD PTR [rsp+0x30]
    1816:	mov    r14,QWORD PTR [rsp+0x38]
    181b:	mov    r15,QWORD PTR [rsp+0x40]
    1820:	add    rsp,0x50
    1824:	mov    rsp,rbp
    1827:	pop    rbp
    1828:	ret
    1829:	mov    rax,r15
    182c:	mov    rbx,QWORD PTR [rsp+0x20]
    1831:	mov    r12,QWORD PTR [rsp+0x28]
    1836:	mov    r13,QWORD PTR [rsp+0x30]
    183b:	mov    r14,QWORD PTR [rsp+0x38]
    1840:	mov    r15,QWORD PTR [rsp+0x40]
    1845:	add    rsp,0x50
    1849:	mov    rsp,rbp
    184c:	pop    rbp
    184d:	ret

000000000000184e <botlish_entry_21: ht_alloc<int>>:
    184e:	push   rbp
    184f:	mov    rbp,rsp
    1852:	mov    rsi,QWORD PTR [rdx]
    1855:	call   185a <botlish_entry_21+0xc>
			1856: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    185a:	mov    rsp,rbp
    185d:	pop    rbp
    185e:	ret

000000000000185f <botlish_fn_22: ht_new<generic>>:
    185f:	push   rbp
    1860:	mov    rbp,rsp
    1863:	sub    rsp,0x20
    1867:	mov    QWORD PTR [rsp+0x10],r12
    186c:	mov    r12,rdi
    186f:	mov    QWORD PTR [rsp],0x0
    1877:	mov    rdi,r12
    187a:	call   187f <botlish_fn_22+0x20>
			187b: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    187f:	test   rax,rax
    1882:	je     18a6 <botlish_fn_22+0x47>
    1888:	mov    esi,0x11
    188d:	mov    QWORD PTR [rsp],0x11
    1895:	mov    rdi,r12
    1898:	call   189d <botlish_fn_22+0x3e>
			1899: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    189d:	test   rax,rax
    18a0:	jne    18b7 <botlish_fn_22+0x58>
    18a6:	xor    rax,rax
    18a9:	mov    r12,QWORD PTR [rsp+0x10]
    18ae:	add    rsp,0x20
    18b2:	mov    rsp,rbp
    18b5:	pop    rbp
    18b6:	ret
    18b7:	mov    r12,QWORD PTR [rsp+0x10]
    18bc:	add    rsp,0x20
    18c0:	mov    rsp,rbp
    18c3:	pop    rbp
    18c4:	ret

00000000000018c5 <botlish_entry_22: ht_new<generic>>:
    18c5:	push   rbp
    18c6:	mov    rbp,rsp
    18c9:	call   18ce <botlish_entry_22+0x9>
			18ca: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    18ce:	mov    rsp,rbp
    18d1:	pop    rbp
    18d2:	ret
    18d3:	add    BYTE PTR [rax],al
    18d5:	add    BYTE PTR [rax],al
	...

00000000000018d8 <botlish_fn_23: ht_capacity_for<int, int>>:
    18d8:	push   rbp
    18d9:	mov    rbp,rsp
    18dc:	sub    rsp,0x50
    18e0:	mov    QWORD PTR [rsp+0x20],rbx
    18e5:	mov    QWORD PTR [rsp+0x28],r12
    18ea:	mov    QWORD PTR [rsp+0x30],r13
    18ef:	mov    QWORD PTR [rsp+0x38],r14
    18f4:	mov    QWORD PTR [rsp+0x40],r15
    18f9:	mov    r13,rdi
    18fc:	mov    QWORD PTR [rsp],rdx
    1900:	mov    rbx,rsi
    1903:	or     rbx,0x1
    1907:	sar    rbx,1
    190a:	mov    r12,rsi
    190d:	mov    r14,rdx
    1910:	mov    rax,r12
    1913:	or     rax,0x1
    1917:	mov    QWORD PTR [rsp+0x8],rax
    191c:	mov    QWORD PTR [rsp+0x10],0x7
    1925:	mov    rax,rbx
    1928:	imul   QWORD PTR [rip+0x159]        # 1a88 <botlish_fn_23+0x1b0>
    192f:	seto   cl
    1932:	or     rax,0x1
    1936:	test   cl,cl
    1938:	jne    1946 <botlish_fn_23+0x6e>
    193e:	mov    rsi,rax
    1941:	jmp    195d <botlish_fn_23+0x85>
    1946:	mov    rsi,r12
    1949:	or     rsi,0x1
    194d:	mov    edx,0x7
    1952:	mov    rdi,r13
    1955:	call   195a <botlish_fn_23+0x82>
			1956: R_X86_64_PLT32	rt_int_mul-0x4
    195a:	mov    rsi,rax
    195d:	mov    QWORD PTR [rsp+0x8],rsi
    1962:	mov    r15,rsi
    1965:	mov    QWORD PTR [rsp+0x10],0x5
    196e:	mov    rsi,r14
    1971:	test   rsi,0x1
    1978:	je     19a8 <botlish_fn_23+0xd0>
    197e:	mov    rsi,r14
    1981:	mov    rax,rsi
    1984:	sar    rax,1
    1987:	imul   QWORD PTR [rip+0x102]        # 1a90 <botlish_fn_23+0x1b8>
    198e:	seto   cl
    1991:	or     rax,0x1
    1995:	test   cl,cl
    1997:	jne    19a8 <botlish_fn_23+0xd0>
    199d:	mov    rdx,rax
    19a0:	mov    rsi,r15
    19a3:	jmp    19be <botlish_fn_23+0xe6>
    19a8:	mov    edx,0x5
    19ad:	mov    rsi,r14
    19b0:	mov    rdi,r13
    19b3:	call   19b8 <botlish_fn_23+0xe0>
			19b4: R_X86_64_PLT32	rt_int_mul-0x4
    19b8:	mov    rdx,rax
    19bb:	mov    rsi,r15
    19be:	mov    rax,rsi
    19c1:	and    rax,rdx
    19c4:	test   rax,0x1
    19ca:	jne    19ed <botlish_fn_23+0x115>
    19d0:	mov    rdi,r13
    19d3:	call   19d8 <botlish_fn_23+0x100>
			19d4: R_X86_64_PLT32	rt_int_cmp-0x4
    19d8:	mov    ecx,0x2
    19dd:	test   rax,rax
    19e0:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1a88 <botlish_fn_23+0x1b0>
    19e8:	jmp    19fd <botlish_fn_23+0x125>
    19ed:	mov    ecx,0x2
    19f2:	cmp    rsi,rdx
    19f5:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1a88 <botlish_fn_23+0x1b0>
    19fd:	cmp    rcx,0x6
    1a01:	je     1a5d <botlish_fn_23+0x185>
    1a07:	mov    QWORD PTR [rsp+0x8],0x5
    1a10:	mov    rsi,r14
    1a13:	test   rsi,0x1
    1a1a:	je     1a41 <botlish_fn_23+0x169>
    1a20:	mov    rsi,r14
    1a23:	mov    rax,rsi
    1a26:	sar    rax,1
    1a29:	imul   QWORD PTR [rip+0x60]        # 1a90 <botlish_fn_23+0x1b8>
    1a30:	seto   sil
    1a34:	or     rax,0x1
    1a38:	test   sil,sil
    1a3b:	je     1a51 <botlish_fn_23+0x179>
    1a41:	mov    edx,0x5
    1a46:	mov    rsi,r14
    1a49:	mov    rdi,r13
    1a4c:	call   1a51 <botlish_fn_23+0x179>
			1a4d: R_X86_64_PLT32	rt_int_mul-0x4
    1a51:	mov    QWORD PTR [rsp],rax
    1a55:	mov    r14,rax
    1a58:	jmp    1910 <botlish_fn_23+0x38>
    1a5d:	mov    rax,r14
    1a60:	mov    rbx,QWORD PTR [rsp+0x20]
    1a65:	mov    r12,QWORD PTR [rsp+0x28]
    1a6a:	mov    r13,QWORD PTR [rsp+0x30]
    1a6f:	mov    r14,QWORD PTR [rsp+0x38]
    1a74:	mov    r15,QWORD PTR [rsp+0x40]
    1a79:	add    rsp,0x50
    1a7d:	mov    rsp,rbp
    1a80:	pop    rbp
    1a81:	ret
    1a82:	add    BYTE PTR [rax],al
    1a84:	add    BYTE PTR [rax],al
    1a86:	add    BYTE PTR [rax],al
    1a88:	(bad)
    1a89:	add    BYTE PTR [rax],al
    1a8b:	add    BYTE PTR [rax],al
    1a8d:	add    BYTE PTR [rax],al
    1a8f:	add    BYTE PTR [rax+rax*1],al
    1a92:	add    BYTE PTR [rax],al
    1a94:	add    BYTE PTR [rax],al
	...

0000000000001a98 <botlish_entry_23: ht_capacity_for<int, int>>:
    1a98:	push   rbp
    1a99:	mov    rbp,rsp
    1a9c:	mov    rsi,QWORD PTR [rdx]
    1a9f:	mov    rdx,QWORD PTR [rdx+0x8]
    1aa3:	call   1aa8 <botlish_entry_23+0x10>
			1aa4: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    1aa8:	mov    rsp,rbp
    1aab:	pop    rbp
    1aac:	ret

0000000000001aad <botlish_fn_24: ht_new_sized<int>>:
    1aad:	push   rbp
    1aae:	mov    rbp,rsp
    1ab1:	sub    rsp,0x20
    1ab5:	mov    QWORD PTR [rsp+0x10],r12
    1aba:	mov    QWORD PTR [rsp+0x18],r13
    1abf:	mov    r12,rdi
    1ac2:	mov    QWORD PTR [rsp+0x8],0x0
    1acb:	mov    QWORD PTR [rsp],rsi
    1acf:	mov    r13,rsi
    1ad2:	mov    rdi,r12
    1ad5:	call   1ada <botlish_fn_24+0x2d>
			1ad6: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1ada:	test   rax,rax
    1add:	je     1b1d <botlish_fn_24+0x70>
    1ae3:	mov    edx,0x11
    1ae8:	mov    QWORD PTR [rsp+0x8],0x11
    1af1:	mov    rsi,r13
    1af4:	mov    rdi,r12
    1af7:	call   1afc <botlish_fn_24+0x4f>
			1af8: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    1afc:	test   rax,rax
    1aff:	je     1b1d <botlish_fn_24+0x70>
    1b05:	mov    QWORD PTR [rsp],rax
    1b09:	mov    rsi,rax
    1b0c:	mov    rdi,r12
    1b0f:	call   1b14 <botlish_fn_24+0x67>
			1b10: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1b14:	test   rax,rax
    1b17:	jne    1b33 <botlish_fn_24+0x86>
    1b1d:	xor    rax,rax
    1b20:	mov    r12,QWORD PTR [rsp+0x10]
    1b25:	mov    r13,QWORD PTR [rsp+0x18]
    1b2a:	add    rsp,0x20
    1b2e:	mov    rsp,rbp
    1b31:	pop    rbp
    1b32:	ret
    1b33:	mov    r12,QWORD PTR [rsp+0x10]
    1b38:	mov    r13,QWORD PTR [rsp+0x18]
    1b3d:	add    rsp,0x20
    1b41:	mov    rsp,rbp
    1b44:	pop    rbp
    1b45:	ret

0000000000001b46 <botlish_entry_24: ht_new_sized<int>>:
    1b46:	push   rbp
    1b47:	mov    rbp,rsp
    1b4a:	mov    rsi,QWORD PTR [rdx]
    1b4d:	call   1b52 <botlish_entry_24+0xc>
			1b4e: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    1b52:	mov    rsp,rbp
    1b55:	pop    rbp
    1b56:	ret

0000000000001b57 <botlish_fn_25: ht_controls<mutarray>>:
    1b57:	push   rbp
    1b58:	mov    rbp,rsp
    1b5b:	mov    edx,0x1
    1b60:	call   1b65 <botlish_fn_25+0xe>
			1b61: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b65:	test   rax,rax
    1b68:	jne    1b76 <botlish_fn_25+0x1f>
    1b6e:	xor    rax,rax
    1b71:	mov    rsp,rbp
    1b74:	pop    rbp
    1b75:	ret
    1b76:	mov    rsp,rbp
    1b79:	pop    rbp
    1b7a:	ret

0000000000001b7b <botlish_entry_25: ht_controls<mutarray>>:
    1b7b:	push   rbp
    1b7c:	mov    rbp,rsp
    1b7f:	mov    rsi,QWORD PTR [rdx]
    1b82:	call   1b87 <botlish_entry_25+0xc>
			1b83: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    1b87:	mov    rsp,rbp
    1b8a:	pop    rbp
    1b8b:	ret

0000000000001b8c <botlish_fn_26: ht_controls<generic>>:
    1b8c:	push   rbp
    1b8d:	mov    rbp,rsp
    1b90:	xor    r8d,r8d
    1b93:	test   rsi,0x7
    1b9a:	jne    1baa <botlish_fn_26+0x1e>
    1ba0:	movzx  rax,BYTE PTR [rsi]
    1ba4:	cmp    al,0x8
    1ba6:	sete   r8b
    1baa:	test   r8b,r8b
    1bad:	jne    1bca <botlish_fn_26+0x3e>
    1bb3:	mov    rax,QWORD PTR [rdi+0x10]
    1bb7:	mov    rcx,QWORD PTR [rax+0x20]
    1bbb:	mov    edx,0x8
    1bc0:	call   1bc5 <botlish_fn_26+0x39>
			1bc1: R_X86_64_PLT32	rt_type_error-0x4
    1bc5:	jmp    1bdd <botlish_fn_26+0x51>
    1bca:	mov    edx,0x1
    1bcf:	call   1bd4 <botlish_fn_26+0x48>
			1bd0: R_X86_64_PLT32	rt_mutarray_get-0x4
    1bd4:	test   rax,rax
    1bd7:	jne    1be5 <botlish_fn_26+0x59>
    1bdd:	xor    rax,rax
    1be0:	mov    rsp,rbp
    1be3:	pop    rbp
    1be4:	ret
    1be5:	mov    rsp,rbp
    1be8:	pop    rbp
    1be9:	ret

0000000000001bea <botlish_entry_26: ht_controls<generic>>:
    1bea:	push   rbp
    1beb:	mov    rbp,rsp
    1bee:	mov    rsi,QWORD PTR [rdx]
    1bf1:	call   1bf6 <botlish_entry_26+0xc>
			1bf2: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    1bf6:	mov    rsp,rbp
    1bf9:	pop    rbp
    1bfa:	ret

0000000000001bfb <botlish_fn_27: ht_keys<mutarray>>:
    1bfb:	push   rbp
    1bfc:	mov    rbp,rsp
    1bff:	mov    edx,0x3
    1c04:	call   1c09 <botlish_fn_27+0xe>
			1c05: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c09:	test   rax,rax
    1c0c:	jne    1c1a <botlish_fn_27+0x1f>
    1c12:	xor    rax,rax
    1c15:	mov    rsp,rbp
    1c18:	pop    rbp
    1c19:	ret
    1c1a:	mov    rsp,rbp
    1c1d:	pop    rbp
    1c1e:	ret

0000000000001c1f <botlish_entry_27: ht_keys<mutarray>>:
    1c1f:	push   rbp
    1c20:	mov    rbp,rsp
    1c23:	mov    rsi,QWORD PTR [rdx]
    1c26:	call   1c2b <botlish_entry_27+0xc>
			1c27: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    1c2b:	mov    rsp,rbp
    1c2e:	pop    rbp
    1c2f:	ret

0000000000001c30 <botlish_fn_28: ht_keys<generic>>:
    1c30:	push   rbp
    1c31:	mov    rbp,rsp
    1c34:	xor    r8d,r8d
    1c37:	test   rsi,0x7
    1c3e:	jne    1c4e <botlish_fn_28+0x1e>
    1c44:	movzx  rax,BYTE PTR [rsi]
    1c48:	cmp    al,0x8
    1c4a:	sete   r8b
    1c4e:	test   r8b,r8b
    1c51:	jne    1c6e <botlish_fn_28+0x3e>
    1c57:	mov    rax,QWORD PTR [rdi+0x10]
    1c5b:	mov    rcx,QWORD PTR [rax+0x20]
    1c5f:	mov    edx,0x8
    1c64:	call   1c69 <botlish_fn_28+0x39>
			1c65: R_X86_64_PLT32	rt_type_error-0x4
    1c69:	jmp    1c81 <botlish_fn_28+0x51>
    1c6e:	mov    edx,0x3
    1c73:	call   1c78 <botlish_fn_28+0x48>
			1c74: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c78:	test   rax,rax
    1c7b:	jne    1c89 <botlish_fn_28+0x59>
    1c81:	xor    rax,rax
    1c84:	mov    rsp,rbp
    1c87:	pop    rbp
    1c88:	ret
    1c89:	mov    rsp,rbp
    1c8c:	pop    rbp
    1c8d:	ret

0000000000001c8e <botlish_entry_28: ht_keys<generic>>:
    1c8e:	push   rbp
    1c8f:	mov    rbp,rsp
    1c92:	mov    rsi,QWORD PTR [rdx]
    1c95:	call   1c9a <botlish_entry_28+0xc>
			1c96: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    1c9a:	mov    rsp,rbp
    1c9d:	pop    rbp
    1c9e:	ret

0000000000001c9f <botlish_fn_29: ht_values<mutarray>>:
    1c9f:	push   rbp
    1ca0:	mov    rbp,rsp
    1ca3:	mov    edx,0x5
    1ca8:	call   1cad <botlish_fn_29+0xe>
			1ca9: R_X86_64_PLT32	rt_mutarray_get-0x4
    1cad:	test   rax,rax
    1cb0:	jne    1cbe <botlish_fn_29+0x1f>
    1cb6:	xor    rax,rax
    1cb9:	mov    rsp,rbp
    1cbc:	pop    rbp
    1cbd:	ret
    1cbe:	mov    rsp,rbp
    1cc1:	pop    rbp
    1cc2:	ret

0000000000001cc3 <botlish_entry_29: ht_values<mutarray>>:
    1cc3:	push   rbp
    1cc4:	mov    rbp,rsp
    1cc7:	mov    rsi,QWORD PTR [rdx]
    1cca:	call   1ccf <botlish_entry_29+0xc>
			1ccb: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    1ccf:	mov    rsp,rbp
    1cd2:	pop    rbp
    1cd3:	ret

0000000000001cd4 <botlish_fn_30: ht_values<generic>>:
    1cd4:	push   rbp
    1cd5:	mov    rbp,rsp
    1cd8:	xor    r8d,r8d
    1cdb:	test   rsi,0x7
    1ce2:	jne    1cf2 <botlish_fn_30+0x1e>
    1ce8:	movzx  rax,BYTE PTR [rsi]
    1cec:	cmp    al,0x8
    1cee:	sete   r8b
    1cf2:	test   r8b,r8b
    1cf5:	jne    1d12 <botlish_fn_30+0x3e>
    1cfb:	mov    rax,QWORD PTR [rdi+0x10]
    1cff:	mov    rcx,QWORD PTR [rax+0x20]
    1d03:	mov    edx,0x8
    1d08:	call   1d0d <botlish_fn_30+0x39>
			1d09: R_X86_64_PLT32	rt_type_error-0x4
    1d0d:	jmp    1d25 <botlish_fn_30+0x51>
    1d12:	mov    edx,0x5
    1d17:	call   1d1c <botlish_fn_30+0x48>
			1d18: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d1c:	test   rax,rax
    1d1f:	jne    1d2d <botlish_fn_30+0x59>
    1d25:	xor    rax,rax
    1d28:	mov    rsp,rbp
    1d2b:	pop    rbp
    1d2c:	ret
    1d2d:	mov    rsp,rbp
    1d30:	pop    rbp
    1d31:	ret

0000000000001d32 <botlish_entry_30: ht_values<generic>>:
    1d32:	push   rbp
    1d33:	mov    rbp,rsp
    1d36:	mov    rsi,QWORD PTR [rdx]
    1d39:	call   1d3e <botlish_entry_30+0xc>
			1d3a: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    1d3e:	mov    rsp,rbp
    1d41:	pop    rbp
    1d42:	ret

0000000000001d43 <botlish_fn_31: ht_size<mutarray>>:
    1d43:	push   rbp
    1d44:	mov    rbp,rsp
    1d47:	mov    edx,0x7
    1d4c:	call   1d51 <botlish_fn_31+0xe>
			1d4d: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d51:	test   rax,rax
    1d54:	jne    1d62 <botlish_fn_31+0x1f>
    1d5a:	xor    rax,rax
    1d5d:	mov    rsp,rbp
    1d60:	pop    rbp
    1d61:	ret
    1d62:	mov    rsp,rbp
    1d65:	pop    rbp
    1d66:	ret

0000000000001d67 <botlish_entry_31: ht_size<mutarray>>:
    1d67:	push   rbp
    1d68:	mov    rbp,rsp
    1d6b:	mov    rsi,QWORD PTR [rdx]
    1d6e:	call   1d73 <botlish_entry_31+0xc>
			1d6f: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    1d73:	mov    rsp,rbp
    1d76:	pop    rbp
    1d77:	ret

0000000000001d78 <botlish_fn_32: ht_size<generic>>:
    1d78:	push   rbp
    1d79:	mov    rbp,rsp
    1d7c:	xor    r8d,r8d
    1d7f:	test   rsi,0x7
    1d86:	jne    1d96 <botlish_fn_32+0x1e>
    1d8c:	movzx  rax,BYTE PTR [rsi]
    1d90:	cmp    al,0x8
    1d92:	sete   r8b
    1d96:	test   r8b,r8b
    1d99:	jne    1db6 <botlish_fn_32+0x3e>
    1d9f:	mov    rax,QWORD PTR [rdi+0x10]
    1da3:	mov    rcx,QWORD PTR [rax+0x20]
    1da7:	mov    edx,0x8
    1dac:	call   1db1 <botlish_fn_32+0x39>
			1dad: R_X86_64_PLT32	rt_type_error-0x4
    1db1:	jmp    1dc9 <botlish_fn_32+0x51>
    1db6:	mov    edx,0x7
    1dbb:	call   1dc0 <botlish_fn_32+0x48>
			1dbc: R_X86_64_PLT32	rt_mutarray_get-0x4
    1dc0:	test   rax,rax
    1dc3:	jne    1dd1 <botlish_fn_32+0x59>
    1dc9:	xor    rax,rax
    1dcc:	mov    rsp,rbp
    1dcf:	pop    rbp
    1dd0:	ret
    1dd1:	mov    rsp,rbp
    1dd4:	pop    rbp
    1dd5:	ret

0000000000001dd6 <botlish_entry_32: ht_size<generic>>:
    1dd6:	push   rbp
    1dd7:	mov    rbp,rsp
    1dda:	mov    rsi,QWORD PTR [rdx]
    1ddd:	call   1de2 <botlish_entry_32+0xc>
			1dde: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    1de2:	mov    rsp,rbp
    1de5:	pop    rbp
    1de6:	ret

0000000000001de7 <botlish_fn_33: ht_tombstones<mutarray>>:
    1de7:	push   rbp
    1de8:	mov    rbp,rsp
    1deb:	mov    edx,0x9
    1df0:	call   1df5 <botlish_fn_33+0xe>
			1df1: R_X86_64_PLT32	rt_mutarray_get-0x4
    1df5:	test   rax,rax
    1df8:	jne    1e06 <botlish_fn_33+0x1f>
    1dfe:	xor    rax,rax
    1e01:	mov    rsp,rbp
    1e04:	pop    rbp
    1e05:	ret
    1e06:	mov    rsp,rbp
    1e09:	pop    rbp
    1e0a:	ret

0000000000001e0b <botlish_entry_33: ht_tombstones<mutarray>>:
    1e0b:	push   rbp
    1e0c:	mov    rbp,rsp
    1e0f:	mov    rsi,QWORD PTR [rdx]
    1e12:	call   1e17 <botlish_entry_33+0xc>
			1e13: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    1e17:	mov    rsp,rbp
    1e1a:	pop    rbp
    1e1b:	ret

0000000000001e1c <botlish_fn_34: ht_capacity<mutarray>>:
    1e1c:	push   rbp
    1e1d:	mov    rbp,rsp
    1e20:	sub    rsp,0x20
    1e24:	mov    QWORD PTR [rsp+0x10],rbx
    1e29:	mov    rbx,rdi
    1e2c:	mov    QWORD PTR [rsp],rsi
    1e30:	mov    rdi,rbx
    1e33:	call   1e38 <botlish_fn_34+0x1c>
			1e34: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    1e38:	test   rax,rax
    1e3b:	je     1e85 <botlish_fn_34+0x69>
    1e41:	xor    r9d,r9d
    1e44:	test   rax,0x7
    1e4a:	je     1e58 <botlish_fn_34+0x3c>
    1e50:	mov    rsi,rax
    1e53:	jmp    1e67 <botlish_fn_34+0x4b>
    1e58:	movzx  rcx,BYTE PTR [rax]
    1e5c:	mov    rsi,rax
    1e5f:	rex cmp cl,0x8
    1e63:	sete   r9b
    1e67:	test   r9b,r9b
    1e6a:	jne    1e96 <botlish_fn_34+0x7a>
    1e70:	mov    rdi,rbx
    1e73:	mov    rax,QWORD PTR [rdi+0x10]
    1e77:	mov    rcx,QWORD PTR [rax+0x28]
    1e7b:	mov    edx,0x8
    1e80:	call   1e85 <botlish_fn_34+0x69>
			1e81: R_X86_64_PLT32	rt_type_error-0x4
    1e85:	xor    rax,rax
    1e88:	mov    rbx,QWORD PTR [rsp+0x10]
    1e8d:	add    rsp,0x20
    1e91:	mov    rsp,rbp
    1e94:	pop    rbp
    1e95:	ret
    1e96:	mov    rdi,rbx
    1e99:	call   1e9e <botlish_fn_34+0x82>
			1e9a: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1e9e:	mov    rbx,QWORD PTR [rsp+0x10]
    1ea3:	add    rsp,0x20
    1ea7:	mov    rsp,rbp
    1eaa:	pop    rbp
    1eab:	ret

0000000000001eac <botlish_entry_34: ht_capacity<mutarray>>:
    1eac:	push   rbp
    1ead:	mov    rbp,rsp
    1eb0:	mov    rsi,QWORD PTR [rdx]
    1eb3:	call   1eb8 <botlish_entry_34+0xc>
			1eb4: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    1eb8:	mov    rsp,rbp
    1ebb:	pop    rbp
    1ebc:	ret

0000000000001ebd <botlish_fn_35: ht_capacity<generic>>:
    1ebd:	push   rbp
    1ebe:	mov    rbp,rsp
    1ec1:	sub    rsp,0x20
    1ec5:	mov    QWORD PTR [rsp+0x10],rbx
    1eca:	mov    rbx,rdi
    1ecd:	mov    QWORD PTR [rsp],rsi
    1ed1:	mov    rdi,rbx
    1ed4:	call   1ed9 <botlish_fn_35+0x1c>
			1ed5: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    1ed9:	test   rax,rax
    1edc:	je     1f26 <botlish_fn_35+0x69>
    1ee2:	xor    r9d,r9d
    1ee5:	test   rax,0x7
    1eeb:	je     1ef9 <botlish_fn_35+0x3c>
    1ef1:	mov    rsi,rax
    1ef4:	jmp    1f08 <botlish_fn_35+0x4b>
    1ef9:	movzx  rcx,BYTE PTR [rax]
    1efd:	mov    rsi,rax
    1f00:	rex cmp cl,0x8
    1f04:	sete   r9b
    1f08:	test   r9b,r9b
    1f0b:	jne    1f37 <botlish_fn_35+0x7a>
    1f11:	mov    rdi,rbx
    1f14:	mov    rax,QWORD PTR [rdi+0x10]
    1f18:	mov    rcx,QWORD PTR [rax+0x28]
    1f1c:	mov    edx,0x8
    1f21:	call   1f26 <botlish_fn_35+0x69>
			1f22: R_X86_64_PLT32	rt_type_error-0x4
    1f26:	xor    rax,rax
    1f29:	mov    rbx,QWORD PTR [rsp+0x10]
    1f2e:	add    rsp,0x20
    1f32:	mov    rsp,rbp
    1f35:	pop    rbp
    1f36:	ret
    1f37:	mov    rdi,rbx
    1f3a:	call   1f3f <botlish_fn_35+0x82>
			1f3b: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1f3f:	mov    rbx,QWORD PTR [rsp+0x10]
    1f44:	add    rsp,0x20
    1f48:	mov    rsp,rbp
    1f4b:	pop    rbp
    1f4c:	ret

0000000000001f4d <botlish_entry_35: ht_capacity<generic>>:
    1f4d:	push   rbp
    1f4e:	mov    rbp,rsp
    1f51:	mov    rsi,QWORD PTR [rdx]
    1f54:	call   1f59 <botlish_entry_35+0xc>
			1f55: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    1f59:	mov    rsp,rbp
    1f5c:	pop    rbp
    1f5d:	ret

0000000000001f5e <botlish_fn_36: ht_probe_start<mutarray, any>>:
    1f5e:	push   rbp
    1f5f:	mov    rbp,rsp
    1f62:	sub    rsp,0x30
    1f66:	mov    QWORD PTR [rsp+0x10],r12
    1f6b:	mov    QWORD PTR [rsp+0x18],r13
    1f70:	mov    QWORD PTR [rsp+0x20],r14
    1f75:	mov    r12,rdi
    1f78:	mov    QWORD PTR [rsp],rsi
    1f7c:	mov    r14,rsi
    1f7f:	mov    rsi,rdx
    1f82:	mov    rdi,r12
    1f85:	call   1f8a <botlish_fn_36+0x2c>
			1f86: R_X86_64_PLT32	rt_hash-0x4
    1f8a:	test   rax,rax
    1f8d:	je     1fc6 <botlish_fn_36+0x68>
    1f93:	mov    QWORD PTR [rsp+0x8],rax
    1f98:	mov    rsi,r14
    1f9b:	mov    r13,rax
    1f9e:	mov    rdi,r12
    1fa1:	call   1fa6 <botlish_fn_36+0x48>
			1fa2: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    1fa6:	test   rax,rax
    1fa9:	mov    rdx,rax
    1fac:	je     1fc6 <botlish_fn_36+0x68>
    1fb2:	mov    rsi,r13
    1fb5:	mov    rdi,r12
    1fb8:	call   1fbd <botlish_fn_36+0x5f>
			1fb9: R_X86_64_PLT32	rt_int_mod-0x4
    1fbd:	test   rax,rax
    1fc0:	jne    1fe1 <botlish_fn_36+0x83>
    1fc6:	xor    rax,rax
    1fc9:	mov    r12,QWORD PTR [rsp+0x10]
    1fce:	mov    r13,QWORD PTR [rsp+0x18]
    1fd3:	mov    r14,QWORD PTR [rsp+0x20]
    1fd8:	add    rsp,0x30
    1fdc:	mov    rsp,rbp
    1fdf:	pop    rbp
    1fe0:	ret
    1fe1:	mov    r12,QWORD PTR [rsp+0x10]
    1fe6:	mov    r13,QWORD PTR [rsp+0x18]
    1feb:	mov    r14,QWORD PTR [rsp+0x20]
    1ff0:	add    rsp,0x30
    1ff4:	mov    rsp,rbp
    1ff7:	pop    rbp
    1ff8:	ret

0000000000001ff9 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    1ff9:	push   rbp
    1ffa:	mov    rbp,rsp
    1ffd:	mov    rsi,QWORD PTR [rdx]
    2000:	mov    rdx,QWORD PTR [rdx+0x8]
    2004:	call   2009 <botlish_entry_36+0x10>
			2005: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    2009:	mov    rsp,rbp
    200c:	pop    rbp
    200d:	ret

000000000000200e <botlish_fn_37: ht_probe_start<any, str>>:
    200e:	push   rbp
    200f:	mov    rbp,rsp
    2012:	sub    rsp,0x30
    2016:	mov    QWORD PTR [rsp+0x10],r12
    201b:	mov    QWORD PTR [rsp+0x18],r13
    2020:	mov    QWORD PTR [rsp+0x20],r14
    2025:	mov    r12,rdi
    2028:	mov    QWORD PTR [rsp],rsi
    202c:	mov    r14,rsi
    202f:	mov    rsi,rdx
    2032:	mov    rdi,r12
    2035:	call   203a <botlish_fn_37+0x2c>
			2036: R_X86_64_PLT32	rt_hash-0x4
    203a:	test   rax,rax
    203d:	je     2076 <botlish_fn_37+0x68>
    2043:	mov    QWORD PTR [rsp+0x8],rax
    2048:	mov    rsi,r14
    204b:	mov    r13,rax
    204e:	mov    rdi,r12
    2051:	call   2056 <botlish_fn_37+0x48>
			2052: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2056:	test   rax,rax
    2059:	mov    rdx,rax
    205c:	je     2076 <botlish_fn_37+0x68>
    2062:	mov    rsi,r13
    2065:	mov    rdi,r12
    2068:	call   206d <botlish_fn_37+0x5f>
			2069: R_X86_64_PLT32	rt_int_mod-0x4
    206d:	test   rax,rax
    2070:	jne    2091 <botlish_fn_37+0x83>
    2076:	xor    rax,rax
    2079:	mov    r12,QWORD PTR [rsp+0x10]
    207e:	mov    r13,QWORD PTR [rsp+0x18]
    2083:	mov    r14,QWORD PTR [rsp+0x20]
    2088:	add    rsp,0x30
    208c:	mov    rsp,rbp
    208f:	pop    rbp
    2090:	ret
    2091:	mov    r12,QWORD PTR [rsp+0x10]
    2096:	mov    r13,QWORD PTR [rsp+0x18]
    209b:	mov    r14,QWORD PTR [rsp+0x20]
    20a0:	add    rsp,0x30
    20a4:	mov    rsp,rbp
    20a7:	pop    rbp
    20a8:	ret

00000000000020a9 <botlish_entry_37: ht_probe_start<any, str>>:
    20a9:	push   rbp
    20aa:	mov    rbp,rsp
    20ad:	mov    rsi,QWORD PTR [rdx]
    20b0:	mov    rdx,QWORD PTR [rdx+0x8]
    20b4:	call   20b9 <botlish_entry_37+0x10>
			20b5: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    20b9:	mov    rsp,rbp
    20bc:	pop    rbp
    20bd:	ret

00000000000020be <botlish_fn_38: ht_probe_next<mutarray, int>>:
    20be:	push   rbp
    20bf:	mov    rbp,rsp
    20c2:	sub    rsp,0x30
    20c6:	mov    QWORD PTR [rsp+0x20],rbx
    20cb:	mov    QWORD PTR [rsp+0x28],r13
    20d0:	mov    r13,rdi
    20d3:	mov    QWORD PTR [rsp],rsi
    20d7:	mov    rbx,rsi
    20da:	mov    QWORD PTR [rsp+0x8],rdx
    20df:	mov    QWORD PTR [rsp+0x10],0x3
    20e8:	test   rdx,0x1
    20ef:	jne    20fd <botlish_fn_38+0x3f>
    20f5:	mov    rcx,rdx
    20f8:	jmp    2112 <botlish_fn_38+0x54>
    20fd:	mov    rsi,rdx
    2100:	add    rsi,0x2
    2104:	mov    rcx,rdx
    2107:	seto   al
    210a:	test   al,al
    210c:	je     2125 <botlish_fn_38+0x67>
    2112:	mov    edx,0x3
    2117:	mov    rsi,rcx
    211a:	mov    rdi,r13
    211d:	call   2122 <botlish_fn_38+0x64>
			211e: R_X86_64_PLT32	rt_int_add-0x4
    2122:	mov    rsi,rax
    2125:	mov    QWORD PTR [rsp+0x8],rsi
    212a:	mov    rax,rbx
    212d:	mov    rbx,rsi
    2130:	mov    rsi,rax
    2133:	mov    rdi,r13
    2136:	call   213b <botlish_fn_38+0x7d>
			2137: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    213b:	test   rax,rax
    213e:	mov    rdx,rax
    2141:	je     215b <botlish_fn_38+0x9d>
    2147:	mov    rsi,rbx
    214a:	mov    rdi,r13
    214d:	call   2152 <botlish_fn_38+0x94>
			214e: R_X86_64_PLT32	rt_int_mod-0x4
    2152:	test   rax,rax
    2155:	jne    2171 <botlish_fn_38+0xb3>
    215b:	xor    rax,rax
    215e:	mov    rbx,QWORD PTR [rsp+0x20]
    2163:	mov    r13,QWORD PTR [rsp+0x28]
    2168:	add    rsp,0x30
    216c:	mov    rsp,rbp
    216f:	pop    rbp
    2170:	ret
    2171:	mov    rbx,QWORD PTR [rsp+0x20]
    2176:	mov    r13,QWORD PTR [rsp+0x28]
    217b:	add    rsp,0x30
    217f:	mov    rsp,rbp
    2182:	pop    rbp
    2183:	ret

0000000000002184 <botlish_entry_38: ht_probe_next<mutarray, int>>:
    2184:	push   rbp
    2185:	mov    rbp,rsp
    2188:	mov    rsi,QWORD PTR [rdx]
    218b:	mov    rdx,QWORD PTR [rdx+0x8]
    218f:	call   2194 <botlish_entry_38+0x10>
			2190: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    2194:	mov    rsp,rbp
    2197:	pop    rbp
    2198:	ret

0000000000002199 <botlish_fn_39: ht_probe_next<any, int>>:
    2199:	push   rbp
    219a:	mov    rbp,rsp
    219d:	sub    rsp,0x30
    21a1:	mov    QWORD PTR [rsp+0x20],rbx
    21a6:	mov    QWORD PTR [rsp+0x28],r13
    21ab:	mov    r13,rdi
    21ae:	mov    QWORD PTR [rsp],rsi
    21b2:	mov    rbx,rsi
    21b5:	mov    QWORD PTR [rsp+0x8],rdx
    21ba:	mov    QWORD PTR [rsp+0x10],0x3
    21c3:	test   rdx,0x1
    21ca:	jne    21d8 <botlish_fn_39+0x3f>
    21d0:	mov    rcx,rdx
    21d3:	jmp    21ed <botlish_fn_39+0x54>
    21d8:	mov    rsi,rdx
    21db:	add    rsi,0x2
    21df:	mov    rcx,rdx
    21e2:	seto   al
    21e5:	test   al,al
    21e7:	je     2200 <botlish_fn_39+0x67>
    21ed:	mov    edx,0x3
    21f2:	mov    rsi,rcx
    21f5:	mov    rdi,r13
    21f8:	call   21fd <botlish_fn_39+0x64>
			21f9: R_X86_64_PLT32	rt_int_add-0x4
    21fd:	mov    rsi,rax
    2200:	mov    QWORD PTR [rsp+0x8],rsi
    2205:	mov    rax,rbx
    2208:	mov    rbx,rsi
    220b:	mov    rsi,rax
    220e:	mov    rdi,r13
    2211:	call   2216 <botlish_fn_39+0x7d>
			2212: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2216:	test   rax,rax
    2219:	mov    rdx,rax
    221c:	je     2236 <botlish_fn_39+0x9d>
    2222:	mov    rsi,rbx
    2225:	mov    rdi,r13
    2228:	call   222d <botlish_fn_39+0x94>
			2229: R_X86_64_PLT32	rt_int_mod-0x4
    222d:	test   rax,rax
    2230:	jne    224c <botlish_fn_39+0xb3>
    2236:	xor    rax,rax
    2239:	mov    rbx,QWORD PTR [rsp+0x20]
    223e:	mov    r13,QWORD PTR [rsp+0x28]
    2243:	add    rsp,0x30
    2247:	mov    rsp,rbp
    224a:	pop    rbp
    224b:	ret
    224c:	mov    rbx,QWORD PTR [rsp+0x20]
    2251:	mov    r13,QWORD PTR [rsp+0x28]
    2256:	add    rsp,0x30
    225a:	mov    rsp,rbp
    225d:	pop    rbp
    225e:	ret

000000000000225f <botlish_entry_39: ht_probe_next<any, int>>:
    225f:	push   rbp
    2260:	mov    rbp,rsp
    2263:	mov    rsi,QWORD PTR [rdx]
    2266:	mov    rdx,QWORD PTR [rdx+0x8]
    226a:	call   226f <botlish_entry_39+0x10>
			226b: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    226f:	mov    rsp,rbp
    2272:	pop    rbp
    2273:	ret
    2274:	add    BYTE PTR [rax],al
	...

0000000000002278 <botlish_fn_40: ht_find_get<any, str, int>>:
    2278:	push   rbp
    2279:	mov    rbp,rsp
    227c:	sub    rsp,0x60
    2280:	mov    QWORD PTR [rsp+0x30],rbx
    2285:	mov    QWORD PTR [rsp+0x38],r12
    228a:	mov    QWORD PTR [rsp+0x40],r13
    228f:	mov    QWORD PTR [rsp+0x48],r14
    2294:	mov    QWORD PTR [rsp+0x50],r15
    2299:	mov    r14,rdi
    229c:	mov    QWORD PTR [rsp+0x18],0x0
    22a5:	mov    QWORD PTR [rsp],rsi
    22a9:	mov    QWORD PTR [rsp+0x8],rdx
    22ae:	mov    r15,rdx
    22b1:	mov    QWORD PTR [rsp+0x10],rcx
    22b6:	mov    r13,rsi
    22b9:	mov    QWORD PTR [rsp+0x20],rcx
    22be:	mov    rsi,r13
    22c1:	mov    rdi,r14
    22c4:	call   22c9 <botlish_fn_40+0x51>
			22c5: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    22c9:	test   rax,rax
    22cc:	je     24eb <botlish_fn_40+0x273>
    22d2:	xor    ecx,ecx
    22d4:	test   rax,0x7
    22da:	je     22e8 <botlish_fn_40+0x70>
    22e0:	mov    r8,rax
    22e3:	jmp    22f6 <botlish_fn_40+0x7e>
    22e8:	movzx  rcx,BYTE PTR [rax]
    22ec:	mov    r8,rax
    22ef:	rex cmp cl,0x8
    22f3:	sete   cl
    22f6:	test   cl,cl
    22f8:	jne    231b <botlish_fn_40+0xa3>
    22fe:	mov    rdi,r14
    2301:	mov    rsi,QWORD PTR [rdi+0x10]
    2305:	mov    rcx,QWORD PTR [rsi+0x20]
    2309:	mov    edx,0x8
    230e:	mov    rsi,r8
    2311:	call   2316 <botlish_fn_40+0x9e>
			2312: R_X86_64_PLT32	rt_type_error-0x4
    2316:	jmp    24eb <botlish_fn_40+0x273>
    231b:	mov    rsi,r8
    231e:	mov    rdx,QWORD PTR [rsp+0x20]
    2323:	mov    rdi,r14
    2326:	call   232b <botlish_fn_40+0xb3>
			2327: R_X86_64_PLT32	rt_mutarray_get-0x4
    232b:	mov    rcx,rax
    232e:	mov    r12,rax
    2331:	test   rax,rcx
    2334:	je     24eb <botlish_fn_40+0x273>
    233a:	mov    rax,r12
    233d:	mov    QWORD PTR [rsp+0x18],rax
    2342:	mov    rdi,r14
    2345:	call   234a <botlish_fn_40+0xd2>
			2346: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    234a:	test   rax,rax
    234d:	je     24eb <botlish_fn_40+0x273>
    2353:	mov    rax,r12
    2356:	test   rax,0x1
    235c:	jne    2380 <botlish_fn_40+0x108>
    2362:	mov    edx,0x1
    2367:	mov    rsi,r12
    236a:	mov    rdi,r14
    236d:	call   2372 <botlish_fn_40+0xfa>
			236e: R_X86_64_PLT32	rt_value_eq-0x4
    2372:	test   rax,rax
    2375:	je     24eb <botlish_fn_40+0x273>
    237b:	jmp    2391 <botlish_fn_40+0x119>
    2380:	mov    eax,0x2
    2385:	cmp    r12,0x1
    2389:	cmove  rax,QWORD PTR [rip+0x1ef]        # 2580 <botlish_fn_40+0x308>
    2391:	mov    ebx,0x6
    2396:	cmp    rax,0x6
    239a:	je     2552 <botlish_fn_40+0x2da>
    23a0:	mov    rdi,r14
    23a3:	call   23a8 <botlish_fn_40+0x130>
			23a4: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    23a8:	test   rax,rax
    23ab:	je     24eb <botlish_fn_40+0x273>
    23b1:	test   r12,0x1
    23b8:	jne    23dc <botlish_fn_40+0x164>
    23be:	mov    edx,0x3
    23c3:	mov    rsi,r12
    23c6:	mov    rdi,r14
    23c9:	call   23ce <botlish_fn_40+0x156>
			23ca: R_X86_64_PLT32	rt_value_eq-0x4
    23ce:	test   rax,rax
    23d1:	je     24eb <botlish_fn_40+0x273>
    23d7:	jmp    23f0 <botlish_fn_40+0x178>
    23dc:	mov    rsi,r12
    23df:	mov    eax,0x2
    23e4:	cmp    rsi,0x3
    23e8:	cmove  rax,QWORD PTR [rip+0x190]        # 2580 <botlish_fn_40+0x308>
    23f0:	cmp    rax,0x6
    23f4:	je     2407 <botlish_fn_40+0x18f>
    23fa:	mov    ebx,0x2
    23ff:	mov    r12,r15
    2402:	jmp    24c8 <botlish_fn_40+0x250>
    2407:	mov    rsi,r13
    240a:	mov    rdi,r14
    240d:	call   2412 <botlish_fn_40+0x19a>
			240e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2412:	test   rax,rax
    2415:	je     24eb <botlish_fn_40+0x273>
    241b:	xor    ecx,ecx
    241d:	test   rax,0x7
    2423:	je     2431 <botlish_fn_40+0x1b9>
    2429:	mov    rsi,rax
    242c:	jmp    243f <botlish_fn_40+0x1c7>
    2431:	movzx  rcx,BYTE PTR [rax]
    2435:	mov    rsi,rax
    2438:	rex cmp cl,0x8
    243c:	sete   cl
    243f:	test   cl,cl
    2441:	jne    2461 <botlish_fn_40+0x1e9>
    2447:	mov    rdi,r14
    244a:	mov    rax,QWORD PTR [rdi+0x10]
    244e:	mov    rcx,QWORD PTR [rax+0x20]
    2452:	mov    edx,0x8
    2457:	call   245c <botlish_fn_40+0x1e4>
			2458: R_X86_64_PLT32	rt_type_error-0x4
    245c:	jmp    24eb <botlish_fn_40+0x273>
    2461:	mov    rdx,QWORD PTR [rsp+0x20]
    2466:	mov    rdi,r14
    2469:	call   246e <botlish_fn_40+0x1f6>
			246a: R_X86_64_PLT32	rt_mutarray_get-0x4
    246e:	test   rax,rax
    2471:	je     24eb <botlish_fn_40+0x273>
    2477:	mov    r12,r15
    247a:	mov    rcx,rax
    247d:	and    rcx,r12
    2480:	mov    rsi,rax
    2483:	test   rcx,0x1
    248a:	jne    24a9 <botlish_fn_40+0x231>
    2490:	mov    rdx,r12
    2493:	mov    rdi,r14
    2496:	call   249b <botlish_fn_40+0x223>
			2497: R_X86_64_PLT32	rt_value_eq-0x4
    249b:	test   rax,rax
    249e:	je     24eb <botlish_fn_40+0x273>
    24a4:	jmp    24b9 <botlish_fn_40+0x241>
    24a9:	mov    eax,0x2
    24ae:	cmp    rsi,r12
    24b1:	cmove  rax,QWORD PTR [rip+0xc7]        # 2580 <botlish_fn_40+0x308>
    24b9:	cmp    rax,0x6
    24bd:	je     24c8 <botlish_fn_40+0x250>
    24c3:	mov    ebx,0x2
    24c8:	cmp    rbx,0x6
    24cc:	je     252b <botlish_fn_40+0x2b3>
    24d2:	mov    rdx,QWORD PTR [rsp+0x20]
    24d7:	mov    rsi,r13
    24da:	mov    rdi,r14
    24dd:	call   24e2 <botlish_fn_40+0x26a>
			24de: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    24e2:	test   rax,rax
    24e5:	jne    2510 <botlish_fn_40+0x298>
    24eb:	xor    rax,rax
    24ee:	mov    rbx,QWORD PTR [rsp+0x30]
    24f3:	mov    r12,QWORD PTR [rsp+0x38]
    24f8:	mov    r13,QWORD PTR [rsp+0x40]
    24fd:	mov    r14,QWORD PTR [rsp+0x48]
    2502:	mov    r15,QWORD PTR [rsp+0x50]
    2507:	add    rsp,0x60
    250b:	mov    rsp,rbp
    250e:	pop    rbp
    250f:	ret
    2510:	mov    QWORD PTR [rsp],r13
    2514:	mov    QWORD PTR [rsp+0x8],r12
    2519:	mov    QWORD PTR [rsp+0x10],rax
    251e:	mov    r15,r12
    2521:	mov    QWORD PTR [rsp+0x20],rax
    2526:	jmp    22be <botlish_fn_40+0x46>
    252b:	mov    rax,QWORD PTR [rsp+0x20]
    2530:	mov    rbx,QWORD PTR [rsp+0x30]
    2535:	mov    r12,QWORD PTR [rsp+0x38]
    253a:	mov    r13,QWORD PTR [rsp+0x40]
    253f:	mov    r14,QWORD PTR [rsp+0x48]
    2544:	mov    r15,QWORD PTR [rsp+0x50]
    2549:	add    rsp,0x60
    254d:	mov    rsp,rbp
    2550:	pop    rbp
    2551:	ret
    2552:	mov    rax,0xffffffffffffffff
    2559:	mov    rbx,QWORD PTR [rsp+0x30]
    255e:	mov    r12,QWORD PTR [rsp+0x38]
    2563:	mov    r13,QWORD PTR [rsp+0x40]
    2568:	mov    r14,QWORD PTR [rsp+0x48]
    256d:	mov    r15,QWORD PTR [rsp+0x50]
    2572:	add    rsp,0x60
    2576:	mov    rsp,rbp
    2579:	pop    rbp
    257a:	ret
    257b:	add    BYTE PTR [rax],al
    257d:	add    BYTE PTR [rax],al
    257f:	add    BYTE PTR [rsi],al
    2581:	add    BYTE PTR [rax],al
    2583:	add    BYTE PTR [rax],al
    2585:	add    BYTE PTR [rax],al
	...

0000000000002588 <botlish_entry_40: ht_find_get<any, str, int>>:
    2588:	push   rbp
    2589:	mov    rbp,rsp
    258c:	mov    rsi,QWORD PTR [rdx]
    258f:	mov    r8,QWORD PTR [rdx+0x8]
    2593:	mov    rcx,QWORD PTR [rdx+0x10]
    2597:	mov    rdx,r8
    259a:	call   259f <botlish_entry_40+0x17>
			259b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    259f:	mov    rsp,rbp
    25a2:	pop    rbp
    25a3:	ret
    25a4:	add    BYTE PTR [rax],al
	...

00000000000025a8 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    25a8:	push   rbp
    25a9:	mov    rbp,rsp
    25ac:	sub    rsp,0x70
    25b0:	mov    QWORD PTR [rsp+0x40],rbx
    25b5:	mov    QWORD PTR [rsp+0x48],r12
    25ba:	mov    QWORD PTR [rsp+0x50],r13
    25bf:	mov    QWORD PTR [rsp+0x58],r14
    25c4:	mov    QWORD PTR [rsp+0x60],r15
    25c9:	mov    r15,rdi
    25cc:	mov    QWORD PTR [rsp+0x20],0x0
    25d5:	mov    QWORD PTR [rsp],rsi
    25d9:	mov    QWORD PTR [rsp+0x8],rdx
    25de:	mov    r13,rdx
    25e1:	mov    QWORD PTR [rsp+0x10],rcx
    25e6:	mov    QWORD PTR [rsp+0x18],r8
    25eb:	mov    rbx,rsi
    25ee:	mov    QWORD PTR [rsp+0x28],rcx
    25f3:	mov    QWORD PTR [rsp+0x30],r8
    25f8:	mov    rsi,rbx
    25fb:	mov    rdi,r15
    25fe:	call   2603 <botlish_fn_41+0x5b>
			25ff: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    2603:	test   rax,rax
    2606:	je     2934 <botlish_fn_41+0x38c>
    260c:	xor    ecx,ecx
    260e:	test   rax,0x7
    2614:	je     2622 <botlish_fn_41+0x7a>
    261a:	mov    rsi,rax
    261d:	jmp    2630 <botlish_fn_41+0x88>
    2622:	movzx  rcx,BYTE PTR [rax]
    2626:	mov    rsi,rax
    2629:	rex cmp cl,0x8
    262d:	sete   cl
    2630:	test   cl,cl
    2632:	jne    2652 <botlish_fn_41+0xaa>
    2638:	mov    rdi,r15
    263b:	mov    rax,QWORD PTR [rdi+0x10]
    263f:	mov    rcx,QWORD PTR [rax+0x20]
    2643:	mov    edx,0x8
    2648:	call   264d <botlish_fn_41+0xa5>
			2649: R_X86_64_PLT32	rt_type_error-0x4
    264d:	jmp    2934 <botlish_fn_41+0x38c>
    2652:	mov    rdx,QWORD PTR [rsp+0x28]
    2657:	mov    rdi,r15
    265a:	call   265f <botlish_fn_41+0xb7>
			265b: R_X86_64_PLT32	rt_mutarray_get-0x4
    265f:	mov    r10,rax
    2662:	mov    r14,rax
    2665:	test   rax,r10
    2668:	je     2934 <botlish_fn_41+0x38c>
    266e:	mov    rax,r14
    2671:	mov    QWORD PTR [rsp+0x20],rax
    2676:	mov    rdi,r15
    2679:	call   267e <botlish_fn_41+0xd6>
			267a: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    267e:	test   rax,rax
    2681:	je     2934 <botlish_fn_41+0x38c>
    2687:	mov    rax,r14
    268a:	test   rax,0x1
    2690:	jne    26b4 <botlish_fn_41+0x10c>
    2696:	mov    edx,0x1
    269b:	mov    rsi,r14
    269e:	mov    rdi,r15
    26a1:	call   26a6 <botlish_fn_41+0xfe>
			26a2: R_X86_64_PLT32	rt_value_eq-0x4
    26a6:	test   rax,rax
    26a9:	je     2934 <botlish_fn_41+0x38c>
    26af:	jmp    26c8 <botlish_fn_41+0x120>
    26b4:	mov    eax,0x2
    26b9:	mov    rcx,r14
    26bc:	cmp    rcx,0x1
    26c0:	cmove  rax,QWORD PTR [rip+0x390]        # 2a58 <botlish_fn_41+0x4b0>
    26c8:	mov    r12d,0x6
    26ce:	cmp    rax,0x6
    26d2:	je     29ac <botlish_fn_41+0x404>
    26d8:	mov    rdi,r15
    26db:	call   26e0 <botlish_fn_41+0x138>
			26dc: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    26e0:	test   rax,rax
    26e3:	je     2934 <botlish_fn_41+0x38c>
    26e9:	mov    rax,r14
    26ec:	test   rax,0x1
    26f2:	jne    2716 <botlish_fn_41+0x16e>
    26f8:	mov    edx,0x3
    26fd:	mov    rsi,r14
    2700:	mov    rdi,r15
    2703:	call   2708 <botlish_fn_41+0x160>
			2704: R_X86_64_PLT32	rt_value_eq-0x4
    2708:	test   rax,rax
    270b:	je     2934 <botlish_fn_41+0x38c>
    2711:	jmp    272a <botlish_fn_41+0x182>
    2716:	mov    eax,0x2
    271b:	mov    rcx,r14
    271e:	cmp    rcx,0x3
    2722:	cmove  rax,QWORD PTR [rip+0x32e]        # 2a58 <botlish_fn_41+0x4b0>
    272a:	cmp    rax,0x6
    272e:	je     273e <botlish_fn_41+0x196>
    2734:	mov    eax,0x2
    2739:	jmp    2804 <botlish_fn_41+0x25c>
    273e:	mov    rsi,rbx
    2741:	mov    rdi,r15
    2744:	call   2749 <botlish_fn_41+0x1a1>
			2745: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    2749:	test   rax,rax
    274c:	je     2934 <botlish_fn_41+0x38c>
    2752:	xor    ecx,ecx
    2754:	test   rax,0x7
    275a:	je     2768 <botlish_fn_41+0x1c0>
    2760:	mov    rsi,rax
    2763:	jmp    2776 <botlish_fn_41+0x1ce>
    2768:	movzx  r8,BYTE PTR [rax]
    276c:	mov    rsi,rax
    276f:	cmp    r8b,0x8
    2773:	sete   cl
    2776:	test   cl,cl
    2778:	jne    2798 <botlish_fn_41+0x1f0>
    277e:	mov    rdi,r15
    2781:	mov    rax,QWORD PTR [rdi+0x10]
    2785:	mov    rcx,QWORD PTR [rax+0x20]
    2789:	mov    edx,0x8
    278e:	call   2793 <botlish_fn_41+0x1eb>
			278f: R_X86_64_PLT32	rt_type_error-0x4
    2793:	jmp    2934 <botlish_fn_41+0x38c>
    2798:	mov    rdx,QWORD PTR [rsp+0x28]
    279d:	mov    rdi,r15
    27a0:	call   27a5 <botlish_fn_41+0x1fd>
			27a1: R_X86_64_PLT32	rt_mutarray_get-0x4
    27a5:	test   rax,rax
    27a8:	je     2934 <botlish_fn_41+0x38c>
    27ae:	mov    rcx,rax
    27b1:	and    rcx,r13
    27b4:	mov    rsi,rax
    27b7:	test   rcx,0x1
    27be:	jne    27dd <botlish_fn_41+0x235>
    27c4:	mov    rdx,r13
    27c7:	mov    rdi,r15
    27ca:	call   27cf <botlish_fn_41+0x227>
			27cb: R_X86_64_PLT32	rt_value_eq-0x4
    27cf:	test   rax,rax
    27d2:	je     2934 <botlish_fn_41+0x38c>
    27d8:	jmp    27ed <botlish_fn_41+0x245>
    27dd:	mov    eax,0x2
    27e2:	cmp    rsi,r13
    27e5:	cmove  rax,QWORD PTR [rip+0x26b]        # 2a58 <botlish_fn_41+0x4b0>
    27ed:	cmp    rax,0x6
    27f1:	je     2801 <botlish_fn_41+0x259>
    27f7:	mov    eax,0x2
    27fc:	jmp    2804 <botlish_fn_41+0x25c>
    2801:	mov    rax,r12
    2804:	cmp    rax,0x6
    2808:	je     2985 <botlish_fn_41+0x3dd>
    280e:	mov    rdi,r15
    2811:	call   2816 <botlish_fn_41+0x26e>
			2812: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    2816:	test   rax,rax
    2819:	je     2934 <botlish_fn_41+0x38c>
    281f:	mov    rax,r14
    2822:	test   rax,0x1
    2828:	jne    284c <botlish_fn_41+0x2a4>
    282e:	mov    edx,0x5
    2833:	mov    rsi,r14
    2836:	mov    rdi,r15
    2839:	call   283e <botlish_fn_41+0x296>
			283a: R_X86_64_PLT32	rt_value_eq-0x4
    283e:	test   rax,rax
    2841:	je     2934 <botlish_fn_41+0x38c>
    2847:	jmp    2860 <botlish_fn_41+0x2b8>
    284c:	mov    rsi,r14
    284f:	mov    eax,0x2
    2854:	cmp    rsi,0x5
    2858:	cmove  rax,QWORD PTR [rip+0x1f8]        # 2a58 <botlish_fn_41+0x4b0>
    2860:	cmp    rax,0x6
    2864:	je     2875 <botlish_fn_41+0x2cd>
    286a:	mov    r12d,0x2
    2870:	jmp    28d6 <botlish_fn_41+0x32e>
    2875:	mov    r14,QWORD PTR [rsp+0x30]
    287a:	test   r14,0x1
    2881:	jne    28b1 <botlish_fn_41+0x309>
    2887:	mov    edx,0x1
    288c:	mov    rsi,r14
    288f:	mov    rdi,r15
    2892:	call   2897 <botlish_fn_41+0x2ef>
			2893: R_X86_64_PLT32	rt_int_cmp-0x4
    2897:	mov    ecx,0x2
    289c:	test   rax,rax
    289f:	cmovl  rcx,QWORD PTR [rip+0x1b1]        # 2a58 <botlish_fn_41+0x4b0>
    28a7:	mov    QWORD PTR [rsp+0x30],r14
    28ac:	jmp    28c6 <botlish_fn_41+0x31e>
    28b1:	mov    ecx,0x2
    28b6:	test   r14,r14
    28b9:	mov    QWORD PTR [rsp+0x30],r14
    28be:	cmovle rcx,QWORD PTR [rip+0x192]        # 2a58 <botlish_fn_41+0x4b0>
    28c6:	cmp    rcx,0x6
    28ca:	je     28d6 <botlish_fn_41+0x32e>
    28d0:	mov    r12d,0x2
    28d6:	cmp    r12,0x6
    28da:	je     291b <botlish_fn_41+0x373>
    28e0:	mov    rdx,QWORD PTR [rsp+0x28]
    28e5:	mov    rsi,rbx
    28e8:	mov    rdi,r15
    28eb:	call   28f0 <botlish_fn_41+0x348>
			28ec: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    28f0:	test   rax,rax
    28f3:	je     2934 <botlish_fn_41+0x38c>
    28f9:	mov    QWORD PTR [rsp],rbx
    28fd:	mov    QWORD PTR [rsp+0x8],r13
    2902:	mov    QWORD PTR [rsp+0x10],rax
    2907:	mov    rcx,QWORD PTR [rsp+0x30]
    290c:	mov    QWORD PTR [rsp+0x18],rcx
    2911:	mov    QWORD PTR [rsp+0x28],rax
    2916:	jmp    25f8 <botlish_fn_41+0x50>
    291b:	mov    rdx,QWORD PTR [rsp+0x28]
    2920:	mov    rsi,rbx
    2923:	mov    rdi,r15
    2926:	call   292b <botlish_fn_41+0x383>
			2927: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    292b:	test   rax,rax
    292e:	jne    2959 <botlish_fn_41+0x3b1>
    2934:	xor    rax,rax
    2937:	mov    rbx,QWORD PTR [rsp+0x40]
    293c:	mov    r12,QWORD PTR [rsp+0x48]
    2941:	mov    r13,QWORD PTR [rsp+0x50]
    2946:	mov    r14,QWORD PTR [rsp+0x58]
    294b:	mov    r15,QWORD PTR [rsp+0x60]
    2950:	add    rsp,0x70
    2954:	mov    rsp,rbp
    2957:	pop    rbp
    2958:	ret
    2959:	mov    QWORD PTR [rsp],rbx
    295d:	mov    QWORD PTR [rsp+0x8],r13
    2962:	mov    QWORD PTR [rsp+0x10],rax
    2967:	mov    rdx,QWORD PTR [rsp+0x28]
    296c:	mov    QWORD PTR [rsp+0x18],rdx
    2971:	mov    rcx,QWORD PTR [rsp+0x28]
    2976:	mov    QWORD PTR [rsp+0x30],rcx
    297b:	mov    QWORD PTR [rsp+0x28],rax
    2980:	jmp    25f8 <botlish_fn_41+0x50>
    2985:	mov    rax,QWORD PTR [rsp+0x28]
    298a:	mov    rbx,QWORD PTR [rsp+0x40]
    298f:	mov    r12,QWORD PTR [rsp+0x48]
    2994:	mov    r13,QWORD PTR [rsp+0x50]
    2999:	mov    r14,QWORD PTR [rsp+0x58]
    299e:	mov    r15,QWORD PTR [rsp+0x60]
    29a3:	add    rsp,0x70
    29a7:	mov    rsp,rbp
    29aa:	pop    rbp
    29ab:	ret
    29ac:	mov    rax,QWORD PTR [rsp+0x30]
    29b1:	test   rax,0x1
    29b7:	jne    29e4 <botlish_fn_41+0x43c>
    29bd:	mov    edx,0x1
    29c2:	mov    rdi,r15
    29c5:	mov    rsi,QWORD PTR [rsp+0x30]
    29ca:	call   29cf <botlish_fn_41+0x427>
			29cb: R_X86_64_PLT32	rt_int_cmp-0x4
    29cf:	mov    esi,0x2
    29d4:	test   rax,rax
    29d7:	cmovge rsi,QWORD PTR [rip+0x79]        # 2a58 <botlish_fn_41+0x4b0>
    29df:	jmp    29fe <botlish_fn_41+0x456>
    29e4:	mov    esi,0x2
    29e9:	mov    rax,QWORD PTR [rsp+0x30]
    29ee:	mov    rcx,QWORD PTR [rsp+0x30]
    29f3:	test   rax,rcx
    29f6:	cmovg  rsi,QWORD PTR [rip+0x5a]        # 2a58 <botlish_fn_41+0x4b0>
    29fe:	cmp    rsi,0x6
    2a02:	je     2a2f <botlish_fn_41+0x487>
    2a08:	mov    rax,QWORD PTR [rsp+0x28]
    2a0d:	mov    rbx,QWORD PTR [rsp+0x40]
    2a12:	mov    r12,QWORD PTR [rsp+0x48]
    2a17:	mov    r13,QWORD PTR [rsp+0x50]
    2a1c:	mov    r14,QWORD PTR [rsp+0x58]
    2a21:	mov    r15,QWORD PTR [rsp+0x60]
    2a26:	add    rsp,0x70
    2a2a:	mov    rsp,rbp
    2a2d:	pop    rbp
    2a2e:	ret
    2a2f:	mov    rax,QWORD PTR [rsp+0x30]
    2a34:	mov    rbx,QWORD PTR [rsp+0x40]
    2a39:	mov    r12,QWORD PTR [rsp+0x48]
    2a3e:	mov    r13,QWORD PTR [rsp+0x50]
    2a43:	mov    r14,QWORD PTR [rsp+0x58]
    2a48:	mov    r15,QWORD PTR [rsp+0x60]
    2a4d:	add    rsp,0x70
    2a51:	mov    rsp,rbp
    2a54:	pop    rbp
    2a55:	ret
    2a56:	add    BYTE PTR [rax],al
    2a58:	(bad)
    2a59:	add    BYTE PTR [rax],al
    2a5b:	add    BYTE PTR [rax],al
    2a5d:	add    BYTE PTR [rax],al
	...

0000000000002a60 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    2a60:	push   rbp
    2a61:	mov    rbp,rsp
    2a64:	mov    rsi,QWORD PTR [rdx]
    2a67:	mov    r9,QWORD PTR [rdx+0x8]
    2a6b:	mov    rcx,QWORD PTR [rdx+0x10]
    2a6f:	mov    r8,QWORD PTR [rdx+0x18]
    2a73:	mov    rdx,r9
    2a76:	call   2a7b <botlish_entry_41+0x1b>
			2a77: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    2a7b:	mov    rsp,rbp
    2a7e:	pop    rbp
    2a7f:	ret

0000000000002a80 <botlish_fn_42: ht_get<any, str>>:
    2a80:	push   rbp
    2a81:	mov    rbp,rsp
    2a84:	sub    rsp,0x40
    2a88:	mov    QWORD PTR [rsp+0x20],rbx
    2a8d:	mov    QWORD PTR [rsp+0x28],r12
    2a92:	mov    QWORD PTR [rsp+0x30],r13
    2a97:	mov    rbx,rdi
    2a9a:	mov    QWORD PTR [rsp+0x10],0x0
    2aa3:	mov    QWORD PTR [rsp],rsi
    2aa7:	mov    r13,rsi
    2aaa:	mov    QWORD PTR [rsp+0x8],rdx
    2aaf:	mov    r12,rdx
    2ab2:	mov    rdx,r12
    2ab5:	mov    rsi,r13
    2ab8:	mov    rdi,rbx
    2abb:	call   2ac0 <botlish_fn_42+0x40>
			2abc: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    2ac0:	test   rax,rax
    2ac3:	je     2bb2 <botlish_fn_42+0x132>
    2ac9:	mov    QWORD PTR [rsp+0x10],rax
    2ace:	mov    rcx,rax
    2ad1:	mov    rdx,r12
    2ad4:	mov    rsi,r13
    2ad7:	mov    rdi,rbx
    2ada:	call   2adf <botlish_fn_42+0x5f>
			2adb: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    2adf:	mov    rcx,rax
    2ae2:	mov    r12,rax
    2ae5:	test   rax,rcx
    2ae8:	je     2bb2 <botlish_fn_42+0x132>
    2aee:	mov    rax,r12
    2af1:	mov    QWORD PTR [rsp+0x8],rax
    2af6:	test   rax,0x1
    2afc:	jne    2b27 <botlish_fn_42+0xa7>
    2b02:	mov    edx,0x1
    2b07:	mov    rsi,r12
    2b0a:	mov    rdi,rbx
    2b0d:	call   2b12 <botlish_fn_42+0x92>
			2b0e: R_X86_64_PLT32	rt_int_cmp-0x4
    2b12:	mov    ecx,0x2
    2b17:	test   rax,rax
    2b1a:	cmovl  rcx,QWORD PTR [rip+0xe6]        # 2c08 <botlish_fn_42+0x188>
    2b22:	jmp    2b3a <botlish_fn_42+0xba>
    2b27:	mov    ecx,0x2
    2b2c:	mov    rax,r12
    2b2f:	test   rax,rax
    2b32:	cmovle rcx,QWORD PTR [rip+0xce]        # 2c08 <botlish_fn_42+0x188>
    2b3a:	cmp    rcx,0x6
    2b3e:	je     2be5 <botlish_fn_42+0x165>
    2b44:	mov    rsi,r13
    2b47:	mov    rdi,rbx
    2b4a:	call   2b4f <botlish_fn_42+0xcf>
			2b4b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    2b4f:	test   rax,rax
    2b52:	je     2bb2 <botlish_fn_42+0x132>
    2b58:	xor    ecx,ecx
    2b5a:	test   rax,0x7
    2b60:	je     2b6e <botlish_fn_42+0xee>
    2b66:	mov    rsi,rax
    2b69:	jmp    2b7c <botlish_fn_42+0xfc>
    2b6e:	movzx  rcx,BYTE PTR [rax]
    2b72:	mov    rsi,rax
    2b75:	rex cmp cl,0x8
    2b79:	sete   cl
    2b7c:	test   cl,cl
    2b7e:	jne    2b9e <botlish_fn_42+0x11e>
    2b84:	mov    rdi,rbx
    2b87:	mov    rax,QWORD PTR [rdi+0x10]
    2b8b:	mov    rcx,QWORD PTR [rax+0x20]
    2b8f:	mov    edx,0x8
    2b94:	call   2b99 <botlish_fn_42+0x119>
			2b95: R_X86_64_PLT32	rt_type_error-0x4
    2b99:	jmp    2bb2 <botlish_fn_42+0x132>
    2b9e:	mov    rdx,r12
    2ba1:	mov    rdi,rbx
    2ba4:	call   2ba9 <botlish_fn_42+0x129>
			2ba5: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ba9:	test   rax,rax
    2bac:	jne    2bcd <botlish_fn_42+0x14d>
    2bb2:	xor    rax,rax
    2bb5:	mov    rbx,QWORD PTR [rsp+0x20]
    2bba:	mov    r12,QWORD PTR [rsp+0x28]
    2bbf:	mov    r13,QWORD PTR [rsp+0x30]
    2bc4:	add    rsp,0x40
    2bc8:	mov    rsp,rbp
    2bcb:	pop    rbp
    2bcc:	ret
    2bcd:	mov    rbx,QWORD PTR [rsp+0x20]
    2bd2:	mov    r12,QWORD PTR [rsp+0x28]
    2bd7:	mov    r13,QWORD PTR [rsp+0x30]
    2bdc:	add    rsp,0x40
    2be0:	mov    rsp,rbp
    2be3:	pop    rbp
    2be4:	ret
    2be5:	mov    eax,0xa
    2bea:	mov    rbx,QWORD PTR [rsp+0x20]
    2bef:	mov    r12,QWORD PTR [rsp+0x28]
    2bf4:	mov    r13,QWORD PTR [rsp+0x30]
    2bf9:	add    rsp,0x40
    2bfd:	mov    rsp,rbp
    2c00:	pop    rbp
    2c01:	ret
    2c02:	add    BYTE PTR [rax],al
    2c04:	add    BYTE PTR [rax],al
    2c06:	add    BYTE PTR [rax],al
    2c08:	(bad)
    2c09:	add    BYTE PTR [rax],al
    2c0b:	add    BYTE PTR [rax],al
    2c0d:	add    BYTE PTR [rax],al
	...

0000000000002c10 <botlish_entry_42: ht_get<any, str>>:
    2c10:	push   rbp
    2c11:	mov    rbp,rsp
    2c14:	mov    rsi,QWORD PTR [rdx]
    2c17:	mov    rdx,QWORD PTR [rdx+0x8]
    2c1b:	call   2c20 <botlish_entry_42+0x10>
			2c1c: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    2c20:	mov    rsp,rbp
    2c23:	pop    rbp
    2c24:	ret
    2c25:	add    BYTE PTR [rax],al
	...

0000000000002c28 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    2c28:	push   rbp
    2c29:	mov    rbp,rsp
    2c2c:	sub    rsp,0x50
    2c30:	mov    QWORD PTR [rsp+0x20],rbx
    2c35:	mov    QWORD PTR [rsp+0x28],r12
    2c3a:	mov    QWORD PTR [rsp+0x30],r13
    2c3f:	mov    QWORD PTR [rsp+0x38],r14
    2c44:	mov    QWORD PTR [rsp+0x40],r15
    2c49:	mov    r13,rdi
    2c4c:	mov    QWORD PTR [rsp],rsi
    2c50:	mov    QWORD PTR [rsp+0x8],rdx
    2c55:	mov    QWORD PTR [rsp+0x10],rcx
    2c5a:	mov    r12,rcx
    2c5d:	mov    rbx,rsi
    2c60:	mov    r14,rdx
    2c63:	mov    rdx,r14
    2c66:	mov    rsi,rbx
    2c69:	mov    rdi,r13
    2c6c:	call   2c71 <botlish_fn_43+0x49>
			2c6d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c71:	test   rax,rax
    2c74:	je     2d30 <botlish_fn_43+0x108>
    2c7a:	mov    QWORD PTR [rsp+0x18],rax
    2c7f:	mov    r15,rax
    2c82:	mov    rdi,r13
    2c85:	call   2c8a <botlish_fn_43+0x62>
			2c86: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    2c8a:	test   rax,rax
    2c8d:	je     2d30 <botlish_fn_43+0x108>
    2c93:	mov    rax,r15
    2c96:	test   rax,0x1
    2c9c:	jne    2cc0 <botlish_fn_43+0x98>
    2ca2:	mov    edx,0x1
    2ca7:	mov    rsi,r15
    2caa:	mov    rdi,r13
    2cad:	call   2cb2 <botlish_fn_43+0x8a>
			2cae: R_X86_64_PLT32	rt_value_eq-0x4
    2cb2:	test   rax,rax
    2cb5:	je     2d30 <botlish_fn_43+0x108>
    2cbb:	jmp    2cd4 <botlish_fn_43+0xac>
    2cc0:	mov    rsi,r15
    2cc3:	mov    eax,0x2
    2cc8:	cmp    rsi,0x1
    2ccc:	cmove  rax,QWORD PTR [rip+0xbc]        # 2d90 <botlish_fn_43+0x168>
    2cd4:	cmp    rax,0x6
    2cd8:	je     2d6b <botlish_fn_43+0x143>
    2cde:	mov    QWORD PTR [rsp+0x18],0x3
    2ce7:	mov    rsi,r14
    2cea:	test   rsi,0x1
    2cf1:	je     2d09 <botlish_fn_43+0xe1>
    2cf7:	mov    rsi,r14
    2cfa:	add    rsi,0x2
    2cfe:	seto   al
    2d01:	test   al,al
    2d03:	je     2d1c <botlish_fn_43+0xf4>
    2d09:	mov    edx,0x3
    2d0e:	mov    rsi,r14
    2d11:	mov    rdi,r13
    2d14:	call   2d19 <botlish_fn_43+0xf1>
			2d15: R_X86_64_PLT32	rt_int_add-0x4
    2d19:	mov    rsi,rax
    2d1c:	mov    rdx,r12
    2d1f:	mov    rdi,r13
    2d22:	call   2d27 <botlish_fn_43+0xff>
			2d23: R_X86_64_PLT32	rt_int_mod-0x4
    2d27:	test   rax,rax
    2d2a:	jne    2d55 <botlish_fn_43+0x12d>
    2d30:	xor    rax,rax
    2d33:	mov    rbx,QWORD PTR [rsp+0x20]
    2d38:	mov    r12,QWORD PTR [rsp+0x28]
    2d3d:	mov    r13,QWORD PTR [rsp+0x30]
    2d42:	mov    r14,QWORD PTR [rsp+0x38]
    2d47:	mov    r15,QWORD PTR [rsp+0x40]
    2d4c:	add    rsp,0x50
    2d50:	mov    rsp,rbp
    2d53:	pop    rbp
    2d54:	ret
    2d55:	mov    QWORD PTR [rsp],rbx
    2d59:	mov    QWORD PTR [rsp+0x8],rax
    2d5e:	mov    QWORD PTR [rsp+0x10],r12
    2d63:	mov    r14,rax
    2d66:	jmp    2c63 <botlish_fn_43+0x3b>
    2d6b:	mov    rax,r14
    2d6e:	mov    rbx,QWORD PTR [rsp+0x20]
    2d73:	mov    r12,QWORD PTR [rsp+0x28]
    2d78:	mov    r13,QWORD PTR [rsp+0x30]
    2d7d:	mov    r14,QWORD PTR [rsp+0x38]
    2d82:	mov    r15,QWORD PTR [rsp+0x40]
    2d87:	add    rsp,0x50
    2d8b:	mov    rsp,rbp
    2d8e:	pop    rbp
    2d8f:	ret
    2d90:	(bad)
    2d91:	add    BYTE PTR [rax],al
    2d93:	add    BYTE PTR [rax],al
    2d95:	add    BYTE PTR [rax],al
	...

0000000000002d98 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    2d98:	push   rbp
    2d99:	mov    rbp,rsp
    2d9c:	mov    rsi,QWORD PTR [rdx]
    2d9f:	mov    r8,QWORD PTR [rdx+0x8]
    2da3:	mov    rcx,QWORD PTR [rdx+0x10]
    2da7:	mov    rdx,r8
    2daa:	call   2daf <botlish_entry_43+0x17>
			2dab: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    2daf:	mov    rsp,rbp
    2db2:	pop    rbp
    2db3:	ret

0000000000002db4 <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    2db4:	push   rbp
    2db5:	mov    rbp,rsp
    2db8:	sub    rsp,0x80
    2dbf:	mov    QWORD PTR [rsp+0x50],rbx
    2dc4:	mov    QWORD PTR [rsp+0x58],r12
    2dc9:	mov    QWORD PTR [rsp+0x60],r13
    2dce:	mov    QWORD PTR [rsp+0x68],r14
    2dd3:	mov    QWORD PTR [rsp+0x70],r15
    2dd8:	mov    r12,rdi
    2ddb:	mov    rdi,QWORD PTR [rbp+0x10]
    2ddf:	mov    QWORD PTR [rsp],rsi
    2de3:	mov    QWORD PTR [rsp+0x38],rsi
    2de8:	mov    QWORD PTR [rsp+0x8],rdx
    2ded:	mov    r15,rdx
    2df0:	mov    QWORD PTR [rsp+0x10],rcx
    2df5:	mov    rbx,rcx
    2df8:	mov    QWORD PTR [rsp+0x18],r8
    2dfd:	mov    QWORD PTR [rsp+0x40],r8
    2e02:	mov    QWORD PTR [rsp+0x20],r9
    2e07:	mov    r14,r9
    2e0a:	mov    QWORD PTR [rsp+0x28],rdi
    2e0f:	mov    r13,rdi
    2e12:	mov    rsi,r14
    2e15:	mov    rdi,r12
    2e18:	call   2e1d <botlish_fn_44+0x69>
			2e19: R_X86_64_PLT32	rt_hash-0x4
    2e1d:	test   rax,rax
    2e20:	mov    rsi,rax
    2e23:	je     2ed5 <botlish_fn_44+0x121>
    2e29:	mov    rdx,QWORD PTR [rsp+0x40]
    2e2e:	mov    rdi,r12
    2e31:	call   2e36 <botlish_fn_44+0x82>
			2e32: R_X86_64_PLT32	rt_int_mod-0x4
    2e36:	test   rax,rax
    2e39:	je     2ed5 <botlish_fn_44+0x121>
    2e3f:	mov    QWORD PTR [rsp+0x30],rax
    2e44:	mov    rcx,QWORD PTR [rsp+0x40]
    2e49:	mov    rdx,rax
    2e4c:	mov    rsi,QWORD PTR [rsp+0x38]
    2e51:	mov    rdi,r12
    2e54:	call   2e59 <botlish_fn_44+0xa5>
			2e55: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    2e59:	test   rax,rax
    2e5c:	je     2ed5 <botlish_fn_44+0x121>
    2e62:	mov    QWORD PTR [rsp+0x18],rax
    2e67:	mov    QWORD PTR [rsp+0x40],rax
    2e6c:	mov    rdi,r12
    2e6f:	call   2e74 <botlish_fn_44+0xc0>
			2e70: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2e74:	test   rax,rax
    2e77:	je     2ed5 <botlish_fn_44+0x121>
    2e7d:	mov    ecx,0x3
    2e82:	mov    rsi,QWORD PTR [rsp+0x38]
    2e87:	mov    rdx,QWORD PTR [rsp+0x40]
    2e8c:	mov    rdi,r12
    2e8f:	call   2e94 <botlish_fn_44+0xe0>
			2e90: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e94:	test   rax,rax
    2e97:	je     2ed5 <botlish_fn_44+0x121>
    2e9d:	mov    rcx,r14
    2ea0:	mov    rsi,r15
    2ea3:	mov    rdx,QWORD PTR [rsp+0x40]
    2ea8:	mov    rdi,r12
    2eab:	call   2eb0 <botlish_fn_44+0xfc>
			2eac: R_X86_64_PLT32	rt_mutarray_set-0x4
    2eb0:	test   rax,rax
    2eb3:	je     2ed5 <botlish_fn_44+0x121>
    2eb9:	mov    rcx,r13
    2ebc:	mov    rdx,QWORD PTR [rsp+0x40]
    2ec1:	mov    rsi,rbx
    2ec4:	mov    rdi,r12
    2ec7:	call   2ecc <botlish_fn_44+0x118>
			2ec8: R_X86_64_PLT32	rt_mutarray_set-0x4
    2ecc:	test   rax,rax
    2ecf:	jne    2efd <botlish_fn_44+0x149>
    2ed5:	xor    rax,rax
    2ed8:	mov    rbx,QWORD PTR [rsp+0x50]
    2edd:	mov    r12,QWORD PTR [rsp+0x58]
    2ee2:	mov    r13,QWORD PTR [rsp+0x60]
    2ee7:	mov    r14,QWORD PTR [rsp+0x68]
    2eec:	mov    r15,QWORD PTR [rsp+0x70]
    2ef1:	add    rsp,0x80
    2ef8:	mov    rsp,rbp
    2efb:	pop    rbp
    2efc:	ret
    2efd:	mov    eax,0xa
    2f02:	mov    rbx,QWORD PTR [rsp+0x50]
    2f07:	mov    r12,QWORD PTR [rsp+0x58]
    2f0c:	mov    r13,QWORD PTR [rsp+0x60]
    2f11:	mov    r14,QWORD PTR [rsp+0x68]
    2f16:	mov    r15,QWORD PTR [rsp+0x70]
    2f1b:	add    rsp,0x80
    2f22:	mov    rsp,rbp
    2f25:	pop    rbp
    2f26:	ret

0000000000002f27 <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    2f27:	push   rbp
    2f28:	mov    rbp,rsp
    2f2b:	sub    rsp,0x10
    2f2f:	mov    rsi,QWORD PTR [rdx]
    2f32:	mov    r10,QWORD PTR [rdx+0x8]
    2f36:	mov    rcx,QWORD PTR [rdx+0x10]
    2f3a:	mov    r8,QWORD PTR [rdx+0x18]
    2f3e:	mov    r9,QWORD PTR [rdx+0x20]
    2f42:	mov    r11,QWORD PTR [rdx+0x28]
    2f46:	mov    QWORD PTR [rsp],r11
    2f4a:	mov    rdx,r10
    2f4d:	call   2f52 <botlish_entry_44+0x2b>
			2f4e: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    2f52:	add    rsp,0x10
    2f56:	mov    rsp,rbp
    2f59:	pop    rbp
    2f5a:	ret
    2f5b:	add    BYTE PTR [rax],al
    2f5d:	add    BYTE PTR [rax],al
	...

0000000000002f60 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2f60:	push   rbp
    2f61:	mov    rbp,rsp
    2f64:	sub    rsp,0xc0
    2f6b:	mov    QWORD PTR [rsp+0x90],rbx
    2f73:	mov    QWORD PTR [rsp+0x98],r12
    2f7b:	mov    QWORD PTR [rsp+0xa0],r13
    2f83:	mov    QWORD PTR [rsp+0xa8],r14
    2f8b:	mov    QWORD PTR [rsp+0xb0],r15
    2f93:	mov    QWORD PTR [rsp+0x60],rdi
    2f98:	mov    QWORD PTR [rsp+0x80],r9
    2fa0:	mov    r12,QWORD PTR [rbp+0x10]
    2fa4:	mov    r13,QWORD PTR [rbp+0x18]
    2fa8:	mov    r14,QWORD PTR [rbp+0x20]
    2fac:	mov    rdi,QWORD PTR [rbp+0x28]
    2fb0:	mov    QWORD PTR [rsp+0x58],0x0
    2fb9:	mov    QWORD PTR [rsp+0x10],rsi
    2fbe:	mov    QWORD PTR [rsp+0x68],rsi
    2fc3:	mov    QWORD PTR [rsp+0x18],rdx
    2fc8:	mov    QWORD PTR [rsp+0x70],rdx
    2fcd:	mov    QWORD PTR [rsp+0x20],rcx
    2fd2:	mov    QWORD PTR [rsp+0x78],rcx
    2fd7:	mov    QWORD PTR [rsp+0x28],r8
    2fdc:	mov    rax,r12
    2fdf:	mov    QWORD PTR [rsp+0x30],rax
    2fe4:	mov    QWORD PTR [rsp+0x38],r13
    2fe9:	mov    QWORD PTR [rsp+0x40],r14
    2fee:	mov    QWORD PTR [rsp+0x48],rdi
    2ff3:	mov    QWORD PTR [rsp+0x88],rdi
    2ffb:	mov    rsi,QWORD PTR [rsp+0x80]
    3003:	mov    rax,rsi
    3006:	or     rax,0x1
    300a:	mov    r15,r8
    300d:	mov    rcx,r15
    3010:	and    rcx,rax
    3013:	test   rcx,0x1
    301a:	jne    3051 <botlish_fn_45+0xf1>
    3020:	mov    rdx,rsi
    3023:	or     rdx,0x1
    3027:	mov    QWORD PTR [rsp+0x80],rsi
    302f:	mov    rsi,r15
    3032:	mov    rdi,QWORD PTR [rsp+0x60]
    3037:	call   303c <botlish_fn_45+0xdc>
			3038: R_X86_64_PLT32	rt_int_cmp-0x4
    303c:	mov    ecx,0x2
    3041:	test   rax,rax
    3044:	cmovge rcx,QWORD PTR [rip+0x304]        # 3350 <botlish_fn_45+0x3f0>
    304c:	jmp    3073 <botlish_fn_45+0x113>
    3051:	mov    rdi,rsi
    3054:	mov    QWORD PTR [rsp+0x80],rsi
    305c:	mov    rax,rdi
    305f:	or     rax,0x1
    3063:	mov    ecx,0x2
    3068:	cmp    r15,rax
    306b:	cmovge rcx,QWORD PTR [rip+0x2dd]        # 3350 <botlish_fn_45+0x3f0>
    3073:	cmp    rcx,0x6
    3077:	je     3311 <botlish_fn_45+0x3b1>
    307d:	xor    eax,eax
    307f:	mov    rsi,QWORD PTR [rsp+0x68]
    3084:	test   rsi,0x7
    308b:	jne    309a <botlish_fn_45+0x13a>
    3091:	movzx  rax,BYTE PTR [rsi]
    3095:	cmp    al,0x8
    3097:	sete   al
    309a:	test   al,al
    309c:	jne    30be <botlish_fn_45+0x15e>
    30a2:	mov    rdi,QWORD PTR [rsp+0x60]
    30a7:	mov    rax,QWORD PTR [rdi+0x10]
    30ab:	mov    rcx,QWORD PTR [rax+0x20]
    30af:	mov    edx,0x8
    30b4:	call   30b9 <botlish_fn_45+0x159>
			30b5: R_X86_64_PLT32	rt_type_error-0x4
    30b9:	jmp    3275 <botlish_fn_45+0x315>
    30be:	mov    QWORD PTR [rsp+0x68],rsi
    30c3:	mov    rdx,r15
    30c6:	mov    rdi,QWORD PTR [rsp+0x60]
    30cb:	call   30d0 <botlish_fn_45+0x170>
			30cc: R_X86_64_PLT32	rt_mutarray_get-0x4
    30d0:	test   rax,rax
    30d3:	je     3275 <botlish_fn_45+0x315>
    30d9:	mov    QWORD PTR [rsp+0x50],rax
    30de:	mov    rbx,rax
    30e1:	mov    rdi,QWORD PTR [rsp+0x60]
    30e6:	call   30eb <botlish_fn_45+0x18b>
			30e7: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    30eb:	test   rax,rax
    30ee:	je     3275 <botlish_fn_45+0x315>
    30f4:	mov    rax,rbx
    30f7:	test   rax,0x1
    30fd:	jne    3123 <botlish_fn_45+0x1c3>
    3103:	mov    edx,0x3
    3108:	mov    rsi,rbx
    310b:	mov    rdi,QWORD PTR [rsp+0x60]
    3110:	call   3115 <botlish_fn_45+0x1b5>
			3111: R_X86_64_PLT32	rt_value_eq-0x4
    3115:	test   rax,rax
    3118:	je     3275 <botlish_fn_45+0x315>
    311e:	jmp    3137 <botlish_fn_45+0x1d7>
    3123:	mov    rsi,rbx
    3126:	mov    eax,0x2
    312b:	cmp    rsi,0x3
    312f:	cmove  rax,QWORD PTR [rip+0x219]        # 3350 <botlish_fn_45+0x3f0>
    3137:	cmp    rax,0x6
    313b:	je     3153 <botlish_fn_45+0x1f3>
    3141:	mov    rbx,QWORD PTR [rsp+0x88]
    3149:	mov    rsi,QWORD PTR [rsp+0x68]
    314e:	jmp    32b1 <botlish_fn_45+0x351>
    3153:	xor    eax,eax
    3155:	mov    rdx,QWORD PTR [rsp+0x70]
    315a:	test   rdx,0x7
    3161:	je     3171 <botlish_fn_45+0x211>
    3167:	mov    QWORD PTR [rsp+0x70],rdx
    316c:	jmp    317f <botlish_fn_45+0x21f>
    3171:	movzx  rax,BYTE PTR [rdx]
    3175:	mov    QWORD PTR [rsp+0x70],rdx
    317a:	cmp    al,0x8
    317c:	sete   al
    317f:	test   al,al
    3181:	jne    31a8 <botlish_fn_45+0x248>
    3187:	mov    rdi,QWORD PTR [rsp+0x60]
    318c:	mov    rax,QWORD PTR [rdi+0x10]
    3190:	mov    rcx,QWORD PTR [rax+0x20]
    3194:	mov    edx,0x8
    3199:	mov    rsi,QWORD PTR [rsp+0x70]
    319e:	call   31a3 <botlish_fn_45+0x243>
			319f: R_X86_64_PLT32	rt_type_error-0x4
    31a3:	jmp    3275 <botlish_fn_45+0x315>
    31a8:	mov    rdx,r15
    31ab:	mov    rsi,QWORD PTR [rsp+0x70]
    31b0:	mov    rdi,QWORD PTR [rsp+0x60]
    31b5:	call   31ba <botlish_fn_45+0x25a>
			31b6: R_X86_64_PLT32	rt_mutarray_get-0x4
    31ba:	test   rax,rax
    31bd:	je     3275 <botlish_fn_45+0x315>
    31c3:	mov    QWORD PTR [rsp+0x50],rax
    31c8:	mov    rbx,rax
    31cb:	xor    eax,eax
    31cd:	mov    rcx,QWORD PTR [rsp+0x78]
    31d2:	test   rcx,0x7
    31d9:	je     31e9 <botlish_fn_45+0x289>
    31df:	mov    QWORD PTR [rsp+0x78],rcx
    31e4:	jmp    31f9 <botlish_fn_45+0x299>
    31e9:	movzx  rsi,BYTE PTR [rcx]
    31ed:	mov    QWORD PTR [rsp+0x78],rcx
    31f2:	cmp    sil,0x8
    31f6:	sete   al
    31f9:	test   al,al
    31fb:	jne    3227 <botlish_fn_45+0x2c7>
    3201:	mov    rdi,QWORD PTR [rsp+0x60]
    3206:	mov    rdi,QWORD PTR [rdi+0x10]
    320a:	mov    rcx,QWORD PTR [rdi+0x20]
    320e:	mov    edx,0x8
    3213:	mov    rsi,QWORD PTR [rsp+0x78]
    3218:	mov    rdi,QWORD PTR [rsp+0x60]
    321d:	call   3222 <botlish_fn_45+0x2c2>
			321e: R_X86_64_PLT32	rt_type_error-0x4
    3222:	jmp    3275 <botlish_fn_45+0x315>
    3227:	mov    rdx,r15
    322a:	mov    rsi,QWORD PTR [rsp+0x78]
    322f:	mov    rdi,QWORD PTR [rsp+0x60]
    3234:	call   3239 <botlish_fn_45+0x2d9>
			3235: R_X86_64_PLT32	rt_mutarray_get-0x4
    3239:	test   rax,rax
    323c:	je     3275 <botlish_fn_45+0x315>
    3242:	mov    QWORD PTR [rsp+0x58],rax
    3247:	mov    QWORD PTR [rsp],rax
    324b:	mov    r9,rbx
    324e:	mov    rbx,QWORD PTR [rsp+0x88]
    3256:	mov    rcx,r14
    3259:	mov    rdx,r13
    325c:	mov    rsi,r12
    325f:	mov    rdi,QWORD PTR [rsp+0x60]
    3264:	mov    r8,rbx
    3267:	call   326c <botlish_fn_45+0x30c>
			3268: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    326c:	test   rax,rax
    326f:	jne    32ac <botlish_fn_45+0x34c>
    3275:	xor    rax,rax
    3278:	mov    rbx,QWORD PTR [rsp+0x90]
    3280:	mov    r12,QWORD PTR [rsp+0x98]
    3288:	mov    r13,QWORD PTR [rsp+0xa0]
    3290:	mov    r14,QWORD PTR [rsp+0xa8]
    3298:	mov    r15,QWORD PTR [rsp+0xb0]
    32a0:	add    rsp,0xc0
    32a7:	mov    rsp,rbp
    32aa:	pop    rbp
    32ab:	ret
    32ac:	mov    rsi,QWORD PTR [rsp+0x68]
    32b1:	mov    rsi,QWORD PTR [rsp+0x68]
    32b6:	mov    QWORD PTR [rsp+0x10],rsi
    32bb:	mov    rsi,QWORD PTR [rsp+0x70]
    32c0:	mov    QWORD PTR [rsp+0x18],rsi
    32c5:	mov    rsi,QWORD PTR [rsp+0x78]
    32ca:	mov    QWORD PTR [rsp+0x20],rsi
    32cf:	sar    r15,1
    32d2:	add    r15,0x1
    32d9:	shl    r15,1
    32dc:	or     r15,0x1
    32e0:	mov    QWORD PTR [rsp+0x28],r15
    32e5:	mov    QWORD PTR [rsp+0x30],r12
    32ea:	mov    QWORD PTR [rsp+0x38],r13
    32ef:	mov    QWORD PTR [rsp+0x40],r14
    32f4:	mov    QWORD PTR [rsp+0x48],rbx
    32f9:	mov    rsi,QWORD PTR [rsp+0x80]
    3301:	mov    r8,r15
    3304:	mov    QWORD PTR [rsp+0x88],rbx
    330c:	jmp    3003 <botlish_fn_45+0xa3>
    3311:	mov    eax,0xa
    3316:	mov    rbx,QWORD PTR [rsp+0x90]
    331e:	mov    r12,QWORD PTR [rsp+0x98]
    3326:	mov    r13,QWORD PTR [rsp+0xa0]
    332e:	mov    r14,QWORD PTR [rsp+0xa8]
    3336:	mov    r15,QWORD PTR [rsp+0xb0]
    333e:	add    rsp,0xc0
    3345:	mov    rsp,rbp
    3348:	pop    rbp
    3349:	ret
    334a:	add    BYTE PTR [rax],al
    334c:	add    BYTE PTR [rax],al
    334e:	add    BYTE PTR [rax],al
    3350:	(bad)
    3351:	add    BYTE PTR [rax],al
    3353:	add    BYTE PTR [rax],al
    3355:	add    BYTE PTR [rax],al
	...

0000000000003358 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    3358:	push   rbp
    3359:	mov    rbp,rsp
    335c:	sub    rsp,0x30
    3360:	mov    QWORD PTR [rsp+0x20],r12
    3365:	mov    rsi,QWORD PTR [rdx]
    3368:	mov    rax,QWORD PTR [rdx+0x8]
    336c:	mov    rcx,QWORD PTR [rdx+0x10]
    3370:	mov    r8,QWORD PTR [rdx+0x18]
    3374:	mov    r9,QWORD PTR [rdx+0x20]
    3378:	mov    r10,QWORD PTR [rdx+0x28]
    337c:	mov    r11,QWORD PTR [rdx+0x30]
    3380:	mov    r12,QWORD PTR [rdx+0x38]
    3384:	mov    rdx,QWORD PTR [rdx+0x40]
    3388:	mov    QWORD PTR [rsp],r10
    338c:	mov    QWORD PTR [rsp+0x8],r11
    3391:	mov    QWORD PTR [rsp+0x10],r12
    3396:	mov    QWORD PTR [rsp+0x18],rdx
    339b:	mov    rdx,rax
    339e:	call   33a3 <botlish_entry_45+0x4b>
			339f: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    33a3:	mov    r12,QWORD PTR [rsp+0x20]
    33a8:	add    rsp,0x30
    33ac:	mov    rsp,rbp
    33af:	pop    rbp
    33b0:	ret

00000000000033b1 <botlish_fn_46: ht_rehash<mutarray, int>>:
    33b1:	push   rbp
    33b2:	mov    rbp,rsp
    33b5:	sub    rsp,0xd0
    33bc:	mov    QWORD PTR [rsp+0xa0],rbx
    33c4:	mov    QWORD PTR [rsp+0xa8],r12
    33cc:	mov    QWORD PTR [rsp+0xb0],r13
    33d4:	mov    QWORD PTR [rsp+0xb8],r14
    33dc:	mov    QWORD PTR [rsp+0xc0],r15
    33e4:	mov    r13,rdi
    33e7:	mov    QWORD PTR [rsp+0x30],0x0
    33f0:	mov    QWORD PTR [rsp+0x38],0x0
    33f9:	mov    QWORD PTR [rsp+0x40],0x0
    3402:	mov    QWORD PTR [rsp+0x48],0x0
    340b:	mov    QWORD PTR [rsp+0x50],0x0
    3414:	mov    QWORD PTR [rsp+0x58],0x0
    341d:	mov    QWORD PTR [rsp+0x60],0x0
    3426:	mov    QWORD PTR [rsp+0x68],0x0
    342f:	mov    QWORD PTR [rsp+0x20],rsi
    3434:	mov    r12,rsi
    3437:	mov    QWORD PTR [rsp+0x28],rdx
    343c:	mov    rbx,rdx
    343f:	mov    rsi,r12
    3442:	mov    rdi,r13
    3445:	call   344a <botlish_fn_46+0x99>
			3446: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    344a:	test   rax,rax
    344d:	je     361c <botlish_fn_46+0x26b>
    3453:	mov    QWORD PTR [rsp+0x30],rax
    3458:	mov    r14,rax
    345b:	mov    rsi,r12
    345e:	mov    rdi,r13
    3461:	call   3466 <botlish_fn_46+0xb5>
			3462: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    3466:	test   rax,rax
    3469:	je     361c <botlish_fn_46+0x26b>
    346f:	mov    QWORD PTR [rsp+0x38],rax
    3474:	mov    r15,rax
    3477:	mov    rsi,r12
    347a:	mov    rdi,r13
    347d:	call   3482 <botlish_fn_46+0xd1>
			347e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    3482:	test   rax,rax
    3485:	je     361c <botlish_fn_46+0x26b>
    348b:	mov    QWORD PTR [rsp+0x40],rax
    3490:	mov    QWORD PTR [rsp+0x90],rax
    3498:	mov    rsi,r12
    349b:	mov    rdi,r13
    349e:	call   34a3 <botlish_fn_46+0xf2>
			349f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    34a3:	test   rax,rax
    34a6:	je     361c <botlish_fn_46+0x26b>
    34ac:	mov    QWORD PTR [rsp+0x48],rax
    34b1:	mov    QWORD PTR [rsp+0x88],rax
    34b9:	mov    rsi,rbx
    34bc:	mov    rdi,r13
    34bf:	call   34c4 <botlish_fn_46+0x113>
			34c0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    34c4:	mov    rcx,rax
    34c7:	mov    QWORD PTR [rsp+0x80],rax
    34cf:	test   rax,rcx
    34d2:	je     361c <botlish_fn_46+0x26b>
    34d8:	mov    rax,QWORD PTR [rsp+0x80]
    34e0:	mov    QWORD PTR [rsp+0x50],rax
    34e5:	mov    edx,0x1
    34ea:	mov    QWORD PTR [rsp+0x58],0x1
    34f3:	mov    rcx,rbx
    34f6:	mov    rsi,QWORD PTR [rsp+0x80]
    34fe:	mov    rdi,r13
    3501:	call   3506 <botlish_fn_46+0x155>
			3502: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    3506:	test   rax,rax
    3509:	je     361c <botlish_fn_46+0x26b>
    350f:	mov    rsi,rbx
    3512:	mov    rdi,r13
    3515:	call   351a <botlish_fn_46+0x169>
			3516: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    351a:	test   rax,rax
    351d:	je     361c <botlish_fn_46+0x26b>
    3523:	mov    QWORD PTR [rsp+0x58],rax
    3528:	mov    QWORD PTR [rsp+0x78],rax
    352d:	mov    rsi,rbx
    3530:	mov    rdi,r13
    3533:	call   3538 <botlish_fn_46+0x187>
			3534: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3538:	test   rax,rax
    353b:	je     361c <botlish_fn_46+0x26b>
    3541:	mov    QWORD PTR [rsp+0x60],rax
    3546:	mov    r8d,0x1
    354c:	mov    QWORD PTR [rsp+0x68],0x1
    3555:	mov    rcx,QWORD PTR [rsp+0x80]
    355d:	mov    QWORD PTR [rsp],rcx
    3561:	mov    rcx,QWORD PTR [rsp+0x78]
    3566:	mov    QWORD PTR [rsp+0x8],rcx
    356b:	mov    QWORD PTR [rsp+0x10],rax
    3570:	mov    QWORD PTR [rsp+0x70],rax
    3575:	mov    QWORD PTR [rsp+0x18],rbx
    357a:	mov    rcx,QWORD PTR [rsp+0x90]
    3582:	mov    rdx,r15
    3585:	mov    rsi,r14
    3588:	mov    r9,QWORD PTR [rsp+0x88]
    3590:	mov    rdi,r13
    3593:	call   3598 <botlish_fn_46+0x1e7>
			3594: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    3598:	test   rax,rax
    359b:	je     361c <botlish_fn_46+0x26b>
    35a1:	mov    edx,0x1
    35a6:	mov    rcx,QWORD PTR [rsp+0x80]
    35ae:	mov    rsi,r12
    35b1:	mov    rdi,r13
    35b4:	call   35b9 <botlish_fn_46+0x208>
			35b5: R_X86_64_PLT32	rt_mutarray_set-0x4
    35b9:	test   rax,rax
    35bc:	je     361c <botlish_fn_46+0x26b>
    35c2:	mov    edx,0x3
    35c7:	mov    rcx,QWORD PTR [rsp+0x78]
    35cc:	mov    rsi,r12
    35cf:	mov    rdi,r13
    35d2:	call   35d7 <botlish_fn_46+0x226>
			35d3: R_X86_64_PLT32	rt_mutarray_set-0x4
    35d7:	test   rax,rax
    35da:	je     361c <botlish_fn_46+0x26b>
    35e0:	mov    edx,0x5
    35e5:	mov    rcx,QWORD PTR [rsp+0x70]
    35ea:	mov    rsi,r12
    35ed:	mov    rdi,r13
    35f0:	call   35f5 <botlish_fn_46+0x244>
			35f1: R_X86_64_PLT32	rt_mutarray_set-0x4
    35f5:	test   rax,rax
    35f8:	je     361c <botlish_fn_46+0x26b>
    35fe:	mov    edx,0x9
    3603:	mov    ecx,0x1
    3608:	mov    rsi,r12
    360b:	mov    rdi,r13
    360e:	call   3613 <botlish_fn_46+0x262>
			360f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3613:	test   rax,rax
    3616:	jne    3653 <botlish_fn_46+0x2a2>
    361c:	xor    rax,rax
    361f:	mov    rbx,QWORD PTR [rsp+0xa0]
    3627:	mov    r12,QWORD PTR [rsp+0xa8]
    362f:	mov    r13,QWORD PTR [rsp+0xb0]
    3637:	mov    r14,QWORD PTR [rsp+0xb8]
    363f:	mov    r15,QWORD PTR [rsp+0xc0]
    3647:	add    rsp,0xd0
    364e:	mov    rsp,rbp
    3651:	pop    rbp
    3652:	ret
    3653:	mov    eax,0xa
    3658:	mov    rbx,QWORD PTR [rsp+0xa0]
    3660:	mov    r12,QWORD PTR [rsp+0xa8]
    3668:	mov    r13,QWORD PTR [rsp+0xb0]
    3670:	mov    r14,QWORD PTR [rsp+0xb8]
    3678:	mov    r15,QWORD PTR [rsp+0xc0]
    3680:	add    rsp,0xd0
    3687:	mov    rsp,rbp
    368a:	pop    rbp
    368b:	ret

000000000000368c <botlish_entry_46: ht_rehash<mutarray, int>>:
    368c:	push   rbp
    368d:	mov    rbp,rsp
    3690:	mov    rsi,QWORD PTR [rdx]
    3693:	mov    rdx,QWORD PTR [rdx+0x8]
    3697:	call   369c <botlish_entry_46+0x10>
			3698: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    369c:	mov    rsp,rbp
    369f:	pop    rbp
    36a0:	ret
    36a1:	add    BYTE PTR [rax],al
    36a3:	add    BYTE PTR [rax],al
    36a5:	add    BYTE PTR [rax],al
	...

00000000000036a8 <botlish_fn_47: ht_should_grow<mutarray>>:
    36a8:	push   rbp
    36a9:	mov    rbp,rsp
    36ac:	sub    rsp,0x40
    36b0:	mov    QWORD PTR [rsp+0x20],rbx
    36b5:	mov    QWORD PTR [rsp+0x28],r12
    36ba:	mov    QWORD PTR [rsp+0x30],r13
    36bf:	mov    rbx,rdi
    36c2:	mov    QWORD PTR [rsp+0x8],0x0
    36cb:	mov    QWORD PTR [rsp+0x10],0x0
    36d4:	mov    QWORD PTR [rsp],rsi
    36d8:	mov    r12,rsi
    36db:	mov    rsi,r12
    36de:	mov    rdi,rbx
    36e1:	call   36e6 <botlish_fn_47+0x3e>
			36e2: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    36e6:	mov    rcx,rax
    36e9:	mov    r13,rax
    36ec:	test   rax,rcx
    36ef:	je     38df <botlish_fn_47+0x237>
    36f5:	mov    rax,r13
    36f8:	mov    QWORD PTR [rsp+0x8],rax
    36fd:	mov    rsi,r12
    3700:	mov    rdi,rbx
    3703:	call   3708 <botlish_fn_47+0x60>
			3704: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3708:	mov    rcx,rax
    370b:	test   rcx,rcx
    370e:	je     38df <botlish_fn_47+0x237>
    3714:	mov    QWORD PTR [rsp+0x10],rcx
    3719:	mov    edx,0x1
    371e:	mov    rax,r13
    3721:	test   rax,0x1
    3727:	jne    374a <botlish_fn_47+0xa2>
    372d:	xor    edx,edx
    372f:	mov    rax,r13
    3732:	test   rax,0x7
    3738:	jne    374a <botlish_fn_47+0xa2>
    373e:	mov    rax,r13
    3741:	movzx  rax,BYTE PTR [rax]
    3745:	cmp    al,0x1
    3747:	sete   dl
    374a:	test   dl,dl
    374c:	jne    376d <botlish_fn_47+0xc5>
    3752:	mov    rdi,rbx
    3755:	mov    rax,QWORD PTR [rdi+0x10]
    3759:	mov    rcx,QWORD PTR [rax+0x30]
    375d:	xor    rdx,rdx
    3760:	mov    rsi,r13
    3763:	call   3768 <botlish_fn_47+0xc0>
			3764: R_X86_64_PLT32	rt_type_error-0x4
    3768:	jmp    38df <botlish_fn_47+0x237>
    376d:	mov    eax,0x1
    3772:	test   rcx,0x1
    3779:	je     3787 <botlish_fn_47+0xdf>
    377f:	mov    r8,rcx
    3782:	jmp    37aa <botlish_fn_47+0x102>
    3787:	xor    eax,eax
    3789:	test   rcx,0x7
    3790:	je     379e <botlish_fn_47+0xf6>
    3796:	mov    r8,rcx
    3799:	jmp    37aa <botlish_fn_47+0x102>
    379e:	movzx  rax,BYTE PTR [rcx]
    37a2:	mov    r8,rcx
    37a5:	cmp    al,0x1
    37a7:	sete   al
    37aa:	test   al,al
    37ac:	jne    37cd <botlish_fn_47+0x125>
    37b2:	mov    rdi,rbx
    37b5:	mov    rax,QWORD PTR [rdi+0x10]
    37b9:	mov    rcx,QWORD PTR [rax+0x30]
    37bd:	xor    rdx,rdx
    37c0:	mov    rsi,r8
    37c3:	call   37c8 <botlish_fn_47+0x120>
			37c4: R_X86_64_PLT32	rt_type_error-0x4
    37c8:	jmp    38df <botlish_fn_47+0x237>
    37cd:	mov    rcx,r8
    37d0:	mov    rsi,r13
    37d3:	mov    rax,rsi
    37d6:	and    rax,rcx
    37d9:	test   rax,0x1
    37df:	jne    37f0 <botlish_fn_47+0x148>
    37e5:	mov    rdx,r8
    37e8:	mov    rsi,r13
    37eb:	jmp    380e <botlish_fn_47+0x166>
    37f0:	mov    rcx,r8
    37f3:	lea    rax,[rcx-0x1]
    37f7:	mov    rsi,r13
    37fa:	add    rsi,rax
    37fd:	seto   al
    3800:	test   al,al
    3802:	je     3819 <botlish_fn_47+0x171>
    3808:	mov    rdx,r8
    380b:	mov    rsi,r13
    380e:	mov    rdi,rbx
    3811:	call   3816 <botlish_fn_47+0x16e>
			3812: R_X86_64_PLT32	rt_int_add-0x4
    3816:	mov    rsi,rax
    3819:	mov    QWORD PTR [rsp+0x8],rsi
    381e:	mov    QWORD PTR [rsp+0x10],0x3
    3827:	test   rsi,0x1
    382e:	je     3851 <botlish_fn_47+0x1a9>
    3834:	mov    rax,rsi
    3837:	add    rax,0x2
    383b:	mov    rcx,rax
    383e:	seto   al
    3841:	test   al,al
    3843:	jne    3851 <botlish_fn_47+0x1a9>
    3849:	mov    rsi,rcx
    384c:	jmp    3861 <botlish_fn_47+0x1b9>
    3851:	mov    edx,0x3
    3856:	mov    rdi,rbx
    3859:	call   385e <botlish_fn_47+0x1b6>
			385a: R_X86_64_PLT32	rt_int_add-0x4
    385e:	mov    rsi,rax
    3861:	mov    QWORD PTR [rsp+0x8],rsi
    3866:	mov    edx,0x7
    386b:	mov    rdi,rdx
    386e:	mov    QWORD PTR [rsp+0x10],0x7
    3877:	test   rsi,0x1
    387e:	jne    388c <botlish_fn_47+0x1e4>
    3884:	mov    rdx,rdi
    3887:	jmp    38b8 <botlish_fn_47+0x210>
    388c:	mov    rax,rsi
    388f:	sar    rax,1
    3892:	imul   QWORD PTR [rip+0x117]        # 39b0 <botlish_fn_47+0x308>
    3899:	seto   cl
    389c:	or     rax,0x1
    38a0:	test   cl,cl
    38a2:	je     38b0 <botlish_fn_47+0x208>
    38a8:	mov    rdx,rdi
    38ab:	jmp    38b8 <botlish_fn_47+0x210>
    38b0:	mov    rsi,rax
    38b3:	jmp    38c3 <botlish_fn_47+0x21b>
    38b8:	mov    rdi,rbx
    38bb:	call   38c0 <botlish_fn_47+0x218>
			38bc: R_X86_64_PLT32	rt_int_mul-0x4
    38c0:	mov    rsi,rax
    38c3:	mov    QWORD PTR [rsp+0x8],rsi
    38c8:	mov    r13,rsi
    38cb:	mov    rsi,r12
    38ce:	mov    rdi,rbx
    38d1:	call   38d6 <botlish_fn_47+0x22e>
			38d2: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    38d6:	test   rax,rax
    38d9:	jne    38fa <botlish_fn_47+0x252>
    38df:	xor    rax,rax
    38e2:	mov    rbx,QWORD PTR [rsp+0x20]
    38e7:	mov    r12,QWORD PTR [rsp+0x28]
    38ec:	mov    r13,QWORD PTR [rsp+0x30]
    38f1:	add    rsp,0x40
    38f5:	mov    rsp,rbp
    38f8:	pop    rbp
    38f9:	ret
    38fa:	mov    QWORD PTR [rsp],rax
    38fe:	mov    QWORD PTR [rsp+0x10],0x5
    3907:	test   rax,0x1
    390d:	mov    rsi,rax
    3910:	je     3942 <botlish_fn_47+0x29a>
    3916:	mov    rcx,rsi
    3919:	mov    rax,rcx
    391c:	sar    rax,1
    391f:	imul   QWORD PTR [rip+0x92]        # 39b8 <botlish_fn_47+0x310>
    3926:	seto   r9b
    392a:	or     rax,0x1
    392e:	test   r9b,r9b
    3931:	jne    3942 <botlish_fn_47+0x29a>
    3937:	mov    rdx,rax
    393a:	mov    rsi,r13
    393d:	jmp    3955 <botlish_fn_47+0x2ad>
    3942:	mov    edx,0x5
    3947:	mov    rdi,rbx
    394a:	call   394f <botlish_fn_47+0x2a7>
			394b: R_X86_64_PLT32	rt_int_mul-0x4
    394f:	mov    rdx,rax
    3952:	mov    rsi,r13
    3955:	mov    rax,rsi
    3958:	and    rax,rdx
    395b:	test   rax,0x1
    3961:	jne    3988 <botlish_fn_47+0x2e0>
    3967:	mov    rdi,rbx
    396a:	call   396f <botlish_fn_47+0x2c7>
			396b: R_X86_64_PLT32	rt_int_cmp-0x4
    396f:	mov    r10d,0x2
    3975:	test   rax,rax
    3978:	mov    rax,r10
    397b:	cmovg  rax,QWORD PTR [rip+0x2d]        # 39b0 <botlish_fn_47+0x308>
    3983:	jmp    3998 <botlish_fn_47+0x2f0>
    3988:	mov    eax,0x2
    398d:	cmp    rsi,rdx
    3990:	cmovg  rax,QWORD PTR [rip+0x18]        # 39b0 <botlish_fn_47+0x308>
    3998:	mov    rbx,QWORD PTR [rsp+0x20]
    399d:	mov    r12,QWORD PTR [rsp+0x28]
    39a2:	mov    r13,QWORD PTR [rsp+0x30]
    39a7:	add    rsp,0x40
    39ab:	mov    rsp,rbp
    39ae:	pop    rbp
    39af:	ret
    39b0:	(bad)
    39b1:	add    BYTE PTR [rax],al
    39b3:	add    BYTE PTR [rax],al
    39b5:	add    BYTE PTR [rax],al
    39b7:	add    BYTE PTR [rax+rax*1],al
    39ba:	add    BYTE PTR [rax],al
    39bc:	add    BYTE PTR [rax],al
	...

00000000000039c0 <botlish_entry_47: ht_should_grow<mutarray>>:
    39c0:	push   rbp
    39c1:	mov    rbp,rsp
    39c4:	mov    rsi,QWORD PTR [rdx]
    39c7:	call   39cc <botlish_entry_47+0xc>
			39c8: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    39cc:	mov    rsp,rbp
    39cf:	pop    rbp
    39d0:	ret
    39d1:	add    BYTE PTR [rax],al
    39d3:	add    BYTE PTR [rax],al
    39d5:	add    BYTE PTR [rax],al
	...

00000000000039d8 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    39d8:	push   rbp
    39d9:	mov    rbp,rsp
    39dc:	sub    rsp,0x40
    39e0:	mov    QWORD PTR [rsp+0x20],rbx
    39e5:	mov    QWORD PTR [rsp+0x28],r12
    39ea:	mov    QWORD PTR [rsp+0x30],r13
    39ef:	mov    rbx,rdi
    39f2:	mov    QWORD PTR [rsp+0x8],0x0
    39fb:	mov    QWORD PTR [rsp+0x10],0x0
    3a04:	mov    QWORD PTR [rsp],rsi
    3a08:	mov    r12,rsi
    3a0b:	mov    rsi,r12
    3a0e:	mov    rdi,rbx
    3a11:	call   3a16 <botlish_fn_48+0x3e>
			3a12: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3a16:	test   rax,rax
    3a19:	je     3c0c <botlish_fn_48+0x234>
    3a1f:	mov    QWORD PTR [rsp+0x8],rax
    3a24:	mov    r13,rax
    3a27:	mov    rsi,r12
    3a2a:	mov    rdi,rbx
    3a2d:	call   3a32 <botlish_fn_48+0x5a>
			3a2e: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    3a32:	mov    rcx,rax
    3a35:	test   rcx,rcx
    3a38:	je     3c0c <botlish_fn_48+0x234>
    3a3e:	mov    edx,0x1
    3a43:	mov    rax,r13
    3a46:	test   rax,0x1
    3a4c:	je     3a5a <botlish_fn_48+0x82>
    3a52:	mov    r13,rax
    3a55:	jmp    3a7e <botlish_fn_48+0xa6>
    3a5a:	xor    edx,edx
    3a5c:	test   rax,0x7
    3a62:	je     3a70 <botlish_fn_48+0x98>
    3a68:	mov    r13,rax
    3a6b:	jmp    3a7e <botlish_fn_48+0xa6>
    3a70:	movzx  rdx,BYTE PTR [rax]
    3a74:	mov    r13,rax
    3a77:	rex cmp dl,0x1
    3a7b:	sete   dl
    3a7e:	test   dl,dl
    3a80:	jne    3aa1 <botlish_fn_48+0xc9>
    3a86:	mov    rdi,rbx
    3a89:	mov    rsi,QWORD PTR [rdi+0x10]
    3a8d:	mov    rcx,QWORD PTR [rsi+0x38]
    3a91:	xor    rdx,rdx
    3a94:	mov    rsi,r13
    3a97:	call   3a9c <botlish_fn_48+0xc4>
			3a98: R_X86_64_PLT32	rt_type_error-0x4
    3a9c:	jmp    3c0c <botlish_fn_48+0x234>
    3aa1:	mov    rsi,r13
    3aa4:	mov    eax,0x1
    3aa9:	test   rcx,0x1
    3ab0:	je     3abe <botlish_fn_48+0xe6>
    3ab6:	mov    r8,rcx
    3ab9:	jmp    3ae1 <botlish_fn_48+0x109>
    3abe:	xor    eax,eax
    3ac0:	test   rcx,0x7
    3ac7:	je     3ad5 <botlish_fn_48+0xfd>
    3acd:	mov    r8,rcx
    3ad0:	jmp    3ae1 <botlish_fn_48+0x109>
    3ad5:	movzx  rax,BYTE PTR [rcx]
    3ad9:	mov    r8,rcx
    3adc:	cmp    al,0x1
    3ade:	sete   al
    3ae1:	test   al,al
    3ae3:	jne    3b04 <botlish_fn_48+0x12c>
    3ae9:	mov    rdi,rbx
    3aec:	mov    rax,QWORD PTR [rdi+0x10]
    3af0:	mov    rcx,QWORD PTR [rax+0x38]
    3af4:	xor    rdx,rdx
    3af7:	mov    rsi,r8
    3afa:	call   3aff <botlish_fn_48+0x127>
			3afb: R_X86_64_PLT32	rt_type_error-0x4
    3aff:	jmp    3c0c <botlish_fn_48+0x234>
    3b04:	mov    rcx,r8
    3b07:	mov    rax,rsi
    3b0a:	and    rax,rcx
    3b0d:	test   rax,0x1
    3b13:	jne    3b39 <botlish_fn_48+0x161>
    3b19:	mov    rdx,r8
    3b1c:	mov    rdi,rbx
    3b1f:	call   3b24 <botlish_fn_48+0x14c>
			3b20: R_X86_64_PLT32	rt_int_cmp-0x4
    3b24:	mov    ecx,0x2
    3b29:	test   rax,rax
    3b2c:	cmovg  rcx,QWORD PTR [rip+0x10c]        # 3c40 <botlish_fn_48+0x268>
    3b34:	jmp    3b4c <botlish_fn_48+0x174>
    3b39:	mov    ecx,0x2
    3b3e:	mov    r11,r8
    3b41:	cmp    rsi,r11
    3b44:	cmovg  rcx,QWORD PTR [rip+0xf4]        # 3c40 <botlish_fn_48+0x268>
    3b4c:	cmp    rcx,0x6
    3b50:	je     3bdc <botlish_fn_48+0x204>
    3b56:	mov    rsi,r12
    3b59:	mov    rdi,rbx
    3b5c:	call   3b61 <botlish_fn_48+0x189>
			3b5d: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3b61:	test   rax,rax
    3b64:	je     3c0c <botlish_fn_48+0x234>
    3b6a:	mov    QWORD PTR [rsp+0x8],rax
    3b6f:	mov    QWORD PTR [rsp+0x10],0x5
    3b78:	test   rax,0x1
    3b7e:	mov    rsi,rax
    3b81:	je     3bae <botlish_fn_48+0x1d6>
    3b87:	mov    rcx,rsi
    3b8a:	mov    rax,rcx
    3b8d:	sar    rax,1
    3b90:	imul   QWORD PTR [rip+0xb1]        # 3c48 <botlish_fn_48+0x270>
    3b97:	seto   cl
    3b9a:	or     rax,0x1
    3b9e:	test   cl,cl
    3ba0:	jne    3bae <botlish_fn_48+0x1d6>
    3ba6:	mov    rdx,rax
    3ba9:	jmp    3bbe <botlish_fn_48+0x1e6>
    3bae:	mov    edx,0x5
    3bb3:	mov    rdi,rbx
    3bb6:	call   3bbb <botlish_fn_48+0x1e3>
			3bb7: R_X86_64_PLT32	rt_int_mul-0x4
    3bbb:	mov    rdx,rax
    3bbe:	mov    QWORD PTR [rsp+0x8],rdx
    3bc3:	mov    rsi,r12
    3bc6:	mov    rdi,rbx
    3bc9:	call   3bce <botlish_fn_48+0x1f6>
			3bca: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    3bce:	test   rax,rax
    3bd1:	je     3c0c <botlish_fn_48+0x234>
    3bd7:	jmp    3c27 <botlish_fn_48+0x24f>
    3bdc:	mov    rsi,r12
    3bdf:	mov    rdi,rbx
    3be2:	call   3be7 <botlish_fn_48+0x20f>
			3be3: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3be7:	test   rax,rax
    3bea:	je     3c0c <botlish_fn_48+0x234>
    3bf0:	mov    QWORD PTR [rsp+0x8],rax
    3bf5:	mov    rdx,rax
    3bf8:	mov    rsi,r12
    3bfb:	mov    rdi,rbx
    3bfe:	call   3c03 <botlish_fn_48+0x22b>
			3bff: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    3c03:	test   rax,rax
    3c06:	jne    3c27 <botlish_fn_48+0x24f>
    3c0c:	xor    rax,rax
    3c0f:	mov    rbx,QWORD PTR [rsp+0x20]
    3c14:	mov    r12,QWORD PTR [rsp+0x28]
    3c19:	mov    r13,QWORD PTR [rsp+0x30]
    3c1e:	add    rsp,0x40
    3c22:	mov    rsp,rbp
    3c25:	pop    rbp
    3c26:	ret
    3c27:	mov    rbx,QWORD PTR [rsp+0x20]
    3c2c:	mov    r12,QWORD PTR [rsp+0x28]
    3c31:	mov    r13,QWORD PTR [rsp+0x30]
    3c36:	add    rsp,0x40
    3c3a:	mov    rsp,rbp
    3c3d:	pop    rbp
    3c3e:	ret
    3c3f:	add    BYTE PTR [rsi],al
    3c41:	add    BYTE PTR [rax],al
    3c43:	add    BYTE PTR [rax],al
    3c45:	add    BYTE PTR [rax],al
    3c47:	add    BYTE PTR [rax+rax*1],al
    3c4a:	add    BYTE PTR [rax],al
    3c4c:	add    BYTE PTR [rax],al
	...

0000000000003c50 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    3c50:	push   rbp
    3c51:	mov    rbp,rsp
    3c54:	mov    rsi,QWORD PTR [rdx]
    3c57:	call   3c5c <botlish_entry_48+0xc>
			3c58: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    3c5c:	mov    rsp,rbp
    3c5f:	pop    rbp
    3c60:	ret
    3c61:	add    BYTE PTR [rax],al
    3c63:	add    BYTE PTR [rax],al
    3c65:	add    BYTE PTR [rax],al
	...

0000000000003c68 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    3c68:	push   rbp
    3c69:	mov    rbp,rsp
    3c6c:	sub    rsp,0x70
    3c70:	mov    QWORD PTR [rsp+0x40],rbx
    3c75:	mov    QWORD PTR [rsp+0x48],r12
    3c7a:	mov    QWORD PTR [rsp+0x50],r13
    3c7f:	mov    QWORD PTR [rsp+0x58],r14
    3c84:	mov    QWORD PTR [rsp+0x60],r15
    3c89:	mov    rbx,rdi
    3c8c:	mov    QWORD PTR [rsp+0x20],0x0
    3c95:	mov    QWORD PTR [rsp+0x28],0x0
    3c9e:	mov    QWORD PTR [rsp],rsi
    3ca2:	mov    r12,rsi
    3ca5:	mov    QWORD PTR [rsp+0x8],rdx
    3caa:	mov    r15,rdx
    3cad:	mov    QWORD PTR [rsp+0x10],rcx
    3cb2:	mov    QWORD PTR [rsp+0x30],rcx
    3cb7:	mov    QWORD PTR [rsp+0x18],r8
    3cbc:	mov    r14,r8
    3cbf:	mov    rsi,r12
    3cc2:	mov    rdi,rbx
    3cc5:	call   3cca <botlish_fn_49+0x62>
			3cc6: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    3cca:	test   rax,rax
    3ccd:	je     405e <botlish_fn_49+0x3f6>
    3cd3:	mov    QWORD PTR [rsp+0x20],rax
    3cd8:	xor    ecx,ecx
    3cda:	test   rax,0x7
    3ce0:	je     3cf0 <botlish_fn_49+0x88>
    3ce6:	mov    QWORD PTR [rsp+0x38],rax
    3ceb:	jmp    3d00 <botlish_fn_49+0x98>
    3cf0:	movzx  rcx,BYTE PTR [rax]
    3cf4:	mov    QWORD PTR [rsp+0x38],rax
    3cf9:	rex cmp cl,0x8
    3cfd:	sete   cl
    3d00:	test   cl,cl
    3d02:	jne    3d27 <botlish_fn_49+0xbf>
    3d08:	mov    rdi,rbx
    3d0b:	mov    rax,QWORD PTR [rdi+0x10]
    3d0f:	mov    rcx,QWORD PTR [rax+0x20]
    3d13:	mov    edx,0x8
    3d18:	mov    rsi,QWORD PTR [rsp+0x38]
    3d1d:	call   3d22 <botlish_fn_49+0xba>
			3d1e: R_X86_64_PLT32	rt_type_error-0x4
    3d22:	jmp    405e <botlish_fn_49+0x3f6>
    3d27:	mov    rdx,r15
    3d2a:	mov    rsi,QWORD PTR [rsp+0x38]
    3d2f:	mov    rdi,rbx
    3d32:	call   3d37 <botlish_fn_49+0xcf>
			3d33: R_X86_64_PLT32	rt_mutarray_get-0x4
    3d37:	test   rax,rax
    3d3a:	je     405e <botlish_fn_49+0x3f6>
    3d40:	mov    QWORD PTR [rsp+0x28],rax
    3d45:	mov    r13,rax
    3d48:	mov    rdi,rbx
    3d4b:	call   3d50 <botlish_fn_49+0xe8>
			3d4c: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3d50:	test   rax,rax
    3d53:	je     405e <botlish_fn_49+0x3f6>
    3d59:	mov    ecx,0x3
    3d5e:	mov    rsi,QWORD PTR [rsp+0x38]
    3d63:	mov    rdx,r15
    3d66:	mov    rdi,rbx
    3d69:	call   3d6e <botlish_fn_49+0x106>
			3d6a: R_X86_64_PLT32	rt_mutarray_set-0x4
    3d6e:	test   rax,rax
    3d71:	je     405e <botlish_fn_49+0x3f6>
    3d77:	mov    rsi,r12
    3d7a:	mov    rdi,rbx
    3d7d:	call   3d82 <botlish_fn_49+0x11a>
			3d7e: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    3d82:	test   rax,rax
    3d85:	je     405e <botlish_fn_49+0x3f6>
    3d8b:	xor    ecx,ecx
    3d8d:	test   rax,0x7
    3d93:	je     3da1 <botlish_fn_49+0x139>
    3d99:	mov    rsi,rax
    3d9c:	jmp    3daf <botlish_fn_49+0x147>
    3da1:	movzx  rcx,BYTE PTR [rax]
    3da5:	mov    rsi,rax
    3da8:	rex cmp cl,0x8
    3dac:	sete   cl
    3daf:	test   cl,cl
    3db1:	jne    3dd1 <botlish_fn_49+0x169>
    3db7:	mov    rdi,rbx
    3dba:	mov    rdx,QWORD PTR [rdi+0x10]
    3dbe:	mov    rcx,QWORD PTR [rdx+0x40]
    3dc2:	mov    edx,0x8
    3dc7:	call   3dcc <botlish_fn_49+0x164>
			3dc8: R_X86_64_PLT32	rt_type_error-0x4
    3dcc:	jmp    405e <botlish_fn_49+0x3f6>
    3dd1:	mov    rcx,QWORD PTR [rsp+0x30]
    3dd6:	mov    rdx,r15
    3dd9:	mov    rdi,rbx
    3ddc:	call   3de1 <botlish_fn_49+0x179>
			3ddd: R_X86_64_PLT32	rt_mutarray_set-0x4
    3de1:	test   rax,rax
    3de4:	je     405e <botlish_fn_49+0x3f6>
    3dea:	mov    rsi,r12
    3ded:	mov    rdi,rbx
    3df0:	call   3df5 <botlish_fn_49+0x18d>
			3df1: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    3df5:	test   rax,rax
    3df8:	je     405e <botlish_fn_49+0x3f6>
    3dfe:	xor    ecx,ecx
    3e00:	test   rax,0x7
    3e06:	je     3e14 <botlish_fn_49+0x1ac>
    3e0c:	mov    rsi,rax
    3e0f:	jmp    3e22 <botlish_fn_49+0x1ba>
    3e14:	movzx  rcx,BYTE PTR [rax]
    3e18:	mov    rsi,rax
    3e1b:	rex cmp cl,0x8
    3e1f:	sete   cl
    3e22:	test   cl,cl
    3e24:	jne    3e44 <botlish_fn_49+0x1dc>
    3e2a:	mov    rdi,rbx
    3e2d:	mov    rax,QWORD PTR [rdi+0x10]
    3e31:	mov    rcx,QWORD PTR [rax+0x40]
    3e35:	mov    edx,0x8
    3e3a:	call   3e3f <botlish_fn_49+0x1d7>
			3e3b: R_X86_64_PLT32	rt_type_error-0x4
    3e3f:	jmp    405e <botlish_fn_49+0x3f6>
    3e44:	mov    rcx,r14
    3e47:	mov    rdx,r15
    3e4a:	mov    rdi,rbx
    3e4d:	call   3e52 <botlish_fn_49+0x1ea>
			3e4e: R_X86_64_PLT32	rt_mutarray_set-0x4
    3e52:	test   rax,rax
    3e55:	je     405e <botlish_fn_49+0x3f6>
    3e5b:	mov    QWORD PTR [rsp+0x8],0x7
    3e64:	mov    rsi,r12
    3e67:	mov    rdi,rbx
    3e6a:	call   3e6f <botlish_fn_49+0x207>
			3e6b: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    3e6f:	test   rax,rax
    3e72:	je     405e <botlish_fn_49+0x3f6>
    3e78:	mov    QWORD PTR [rsp+0x10],rax
    3e7d:	mov    QWORD PTR [rsp+0x18],0x3
    3e86:	mov    ecx,0x1
    3e8b:	test   rax,0x1
    3e91:	je     3e9f <botlish_fn_49+0x237>
    3e97:	mov    rsi,rax
    3e9a:	jmp    3ec3 <botlish_fn_49+0x25b>
    3e9f:	xor    ecx,ecx
    3ea1:	test   rax,0x7
    3ea7:	je     3eb5 <botlish_fn_49+0x24d>
    3ead:	mov    rsi,rax
    3eb0:	jmp    3ec3 <botlish_fn_49+0x25b>
    3eb5:	movzx  rcx,BYTE PTR [rax]
    3eb9:	mov    rsi,rax
    3ebc:	rex cmp cl,0x1
    3ec0:	sete   cl
    3ec3:	test   cl,cl
    3ec5:	jne    3ee3 <botlish_fn_49+0x27b>
    3ecb:	mov    rdi,rbx
    3ece:	mov    rax,QWORD PTR [rdi+0x10]
    3ed2:	mov    rcx,QWORD PTR [rax+0x30]
    3ed6:	xor    rdx,rdx
    3ed9:	call   3ede <botlish_fn_49+0x276>
			3eda: R_X86_64_PLT32	rt_type_error-0x4
    3ede:	jmp    405e <botlish_fn_49+0x3f6>
    3ee3:	test   rsi,0x1
    3eea:	je     3f02 <botlish_fn_49+0x29a>
    3ef0:	mov    rcx,rsi
    3ef3:	add    rcx,0x2
    3ef7:	seto   al
    3efa:	test   al,al
    3efc:	je     3f12 <botlish_fn_49+0x2aa>
    3f02:	mov    edx,0x3
    3f07:	mov    rdi,rbx
    3f0a:	call   3f0f <botlish_fn_49+0x2a7>
			3f0b: R_X86_64_PLT32	rt_int_add-0x4
    3f0f:	mov    rcx,rax
    3f12:	mov    edx,0x7
    3f17:	mov    rsi,r12
    3f1a:	mov    rdi,rbx
    3f1d:	call   3f22 <botlish_fn_49+0x2ba>
			3f1e: R_X86_64_PLT32	rt_mutarray_set-0x4
    3f22:	test   rax,rax
    3f25:	je     405e <botlish_fn_49+0x3f6>
    3f2b:	mov    rdi,rbx
    3f2e:	call   3f33 <botlish_fn_49+0x2cb>
			3f2f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3f33:	test   rax,rax
    3f36:	je     405e <botlish_fn_49+0x3f6>
    3f3c:	mov    rax,r13
    3f3f:	test   rax,0x1
    3f45:	jne    3f69 <botlish_fn_49+0x301>
    3f4b:	mov    edx,0x5
    3f50:	mov    rsi,r13
    3f53:	mov    rdi,rbx
    3f56:	call   3f5b <botlish_fn_49+0x2f3>
			3f57: R_X86_64_PLT32	rt_value_eq-0x4
    3f5b:	test   rax,rax
    3f5e:	je     405e <botlish_fn_49+0x3f6>
    3f64:	jmp    3f7d <botlish_fn_49+0x315>
    3f69:	mov    rsi,r13
    3f6c:	mov    eax,0x2
    3f71:	cmp    rsi,0x5
    3f75:	cmove  rax,QWORD PTR [rip+0x133]        # 40b0 <botlish_fn_49+0x448>
    3f7d:	cmp    rax,0x6
    3f81:	jne    4083 <botlish_fn_49+0x41b>
    3f87:	mov    QWORD PTR [rsp+0x8],0x9
    3f90:	mov    rsi,r12
    3f93:	mov    rdi,rbx
    3f96:	call   3f9b <botlish_fn_49+0x333>
			3f97: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3f9b:	test   rax,rax
    3f9e:	je     405e <botlish_fn_49+0x3f6>
    3fa4:	mov    QWORD PTR [rsp+0x10],rax
    3fa9:	mov    QWORD PTR [rsp+0x18],0x3
    3fb2:	mov    ecx,0x1
    3fb7:	test   rax,0x1
    3fbd:	je     3fcb <botlish_fn_49+0x363>
    3fc3:	mov    rsi,rax
    3fc6:	jmp    3fef <botlish_fn_49+0x387>
    3fcb:	xor    ecx,ecx
    3fcd:	test   rax,0x7
    3fd3:	je     3fe1 <botlish_fn_49+0x379>
    3fd9:	mov    rsi,rax
    3fdc:	jmp    3fef <botlish_fn_49+0x387>
    3fe1:	movzx  r11,BYTE PTR [rax]
    3fe5:	mov    rsi,rax
    3fe8:	cmp    r11b,0x1
    3fec:	sete   cl
    3fef:	test   cl,cl
    3ff1:	jne    400f <botlish_fn_49+0x3a7>
    3ff7:	mov    rdi,rbx
    3ffa:	mov    rax,QWORD PTR [rdi+0x10]
    3ffe:	mov    rcx,QWORD PTR [rax+0x48]
    4002:	xor    rdx,rdx
    4005:	call   400a <botlish_fn_49+0x3a2>
			4006: R_X86_64_PLT32	rt_type_error-0x4
    400a:	jmp    405e <botlish_fn_49+0x3f6>
    400f:	test   rsi,0x1
    4016:	je     4035 <botlish_fn_49+0x3cd>
    401c:	mov    rcx,rsi
    401f:	sub    rcx,0x3
    4023:	seto   al
    4026:	add    rcx,0x1
    402d:	test   al,al
    402f:	je     4045 <botlish_fn_49+0x3dd>
    4035:	mov    edx,0x3
    403a:	mov    rdi,rbx
    403d:	call   4042 <botlish_fn_49+0x3da>
			403e: R_X86_64_PLT32	rt_int_sub-0x4
    4042:	mov    rcx,rax
    4045:	mov    edx,0x9
    404a:	mov    rsi,r12
    404d:	mov    rdi,rbx
    4050:	call   4055 <botlish_fn_49+0x3ed>
			4051: R_X86_64_PLT32	rt_mutarray_set-0x4
    4055:	test   rax,rax
    4058:	jne    4083 <botlish_fn_49+0x41b>
    405e:	xor    rax,rax
    4061:	mov    rbx,QWORD PTR [rsp+0x40]
    4066:	mov    r12,QWORD PTR [rsp+0x48]
    406b:	mov    r13,QWORD PTR [rsp+0x50]
    4070:	mov    r14,QWORD PTR [rsp+0x58]
    4075:	mov    r15,QWORD PTR [rsp+0x60]
    407a:	add    rsp,0x70
    407e:	mov    rsp,rbp
    4081:	pop    rbp
    4082:	ret
    4083:	mov    eax,0xa
    4088:	mov    rbx,QWORD PTR [rsp+0x40]
    408d:	mov    r12,QWORD PTR [rsp+0x48]
    4092:	mov    r13,QWORD PTR [rsp+0x50]
    4097:	mov    r14,QWORD PTR [rsp+0x58]
    409c:	mov    r15,QWORD PTR [rsp+0x60]
    40a1:	add    rsp,0x70
    40a5:	mov    rsp,rbp
    40a8:	pop    rbp
    40a9:	ret
    40aa:	add    BYTE PTR [rax],al
    40ac:	add    BYTE PTR [rax],al
    40ae:	add    BYTE PTR [rax],al
    40b0:	(bad)
    40b1:	add    BYTE PTR [rax],al
    40b3:	add    BYTE PTR [rax],al
    40b5:	add    BYTE PTR [rax],al
	...

00000000000040b8 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    40b8:	push   rbp
    40b9:	mov    rbp,rsp
    40bc:	mov    rsi,QWORD PTR [rdx]
    40bf:	mov    r9,QWORD PTR [rdx+0x8]
    40c3:	mov    rcx,QWORD PTR [rdx+0x10]
    40c7:	mov    r8,QWORD PTR [rdx+0x18]
    40cb:	mov    rdx,r9
    40ce:	call   40d3 <botlish_entry_49+0x1b>
			40cf: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    40d3:	mov    rsp,rbp
    40d6:	pop    rbp
    40d7:	ret

00000000000040d8 <botlish_fn_50: ht_set<mutarray, any, any>>:
    40d8:	push   rbp
    40d9:	mov    rbp,rsp
    40dc:	sub    rsp,0x70
    40e0:	mov    QWORD PTR [rsp+0x40],rbx
    40e5:	mov    QWORD PTR [rsp+0x48],r12
    40ea:	mov    QWORD PTR [rsp+0x50],r13
    40ef:	mov    QWORD PTR [rsp+0x58],r14
    40f4:	mov    QWORD PTR [rsp+0x60],r15
    40f9:	mov    rbx,rdi
    40fc:	mov    QWORD PTR [rsp+0x18],0x0
    4105:	mov    QWORD PTR [rsp+0x20],0x0
    410e:	mov    QWORD PTR [rsp],rsi
    4112:	mov    r14,rsi
    4115:	mov    QWORD PTR [rsp+0x8],rdx
    411a:	mov    r13,rdx
    411d:	mov    QWORD PTR [rsp+0x10],rcx
    4122:	mov    r12,rcx
    4125:	mov    rdx,r13
    4128:	mov    rsi,r14
    412b:	mov    rdi,rbx
    412e:	call   4133 <botlish_fn_50+0x5b>
			412f: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    4133:	test   rax,rax
    4136:	je     43c8 <botlish_fn_50+0x2f0>
    413c:	mov    QWORD PTR [rsp+0x18],rax
    4141:	mov    rcx,rax
    4144:	mov    r8,0xffffffffffffffff
    414b:	mov    QWORD PTR [rsp+0x30],r8
    4150:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4159:	mov    rdx,r13
    415c:	mov    rsi,r14
    415f:	mov    rdi,rbx
    4162:	call   4167 <botlish_fn_50+0x8f>
			4163: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    4167:	mov    rcx,rax
    416a:	mov    r15,rax
    416d:	test   rax,rcx
    4170:	je     43c8 <botlish_fn_50+0x2f0>
    4176:	mov    rax,r15
    4179:	mov    QWORD PTR [rsp+0x18],rax
    417e:	mov    rsi,r14
    4181:	mov    rdi,rbx
    4184:	call   4189 <botlish_fn_50+0xb1>
			4185: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    4189:	test   rax,rax
    418c:	je     43c8 <botlish_fn_50+0x2f0>
    4192:	xor    ecx,ecx
    4194:	test   rax,0x7
    419a:	je     41a8 <botlish_fn_50+0xd0>
    41a0:	mov    r8,rax
    41a3:	jmp    41b6 <botlish_fn_50+0xde>
    41a8:	movzx  rdx,BYTE PTR [rax]
    41ac:	mov    r8,rax
    41af:	rex cmp dl,0x8
    41b3:	sete   cl
    41b6:	test   cl,cl
    41b8:	jne    41db <botlish_fn_50+0x103>
    41be:	mov    rdi,rbx
    41c1:	mov    rsi,QWORD PTR [rdi+0x10]
    41c5:	mov    rcx,QWORD PTR [rsi+0x20]
    41c9:	mov    edx,0x8
    41ce:	mov    rsi,r8
    41d1:	call   41d6 <botlish_fn_50+0xfe>
			41d2: R_X86_64_PLT32	rt_type_error-0x4
    41d6:	jmp    43c8 <botlish_fn_50+0x2f0>
    41db:	mov    rsi,r8
    41de:	mov    rdx,r15
    41e1:	mov    rdi,rbx
    41e4:	call   41e9 <botlish_fn_50+0x111>
			41e5: R_X86_64_PLT32	rt_mutarray_get-0x4
    41e9:	test   rax,rax
    41ec:	je     43c8 <botlish_fn_50+0x2f0>
    41f2:	mov    QWORD PTR [rsp+0x20],rax
    41f7:	mov    QWORD PTR [rsp+0x28],rax
    41fc:	mov    rdi,rbx
    41ff:	call   4204 <botlish_fn_50+0x12c>
			4200: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    4204:	test   rax,rax
    4207:	je     43c8 <botlish_fn_50+0x2f0>
    420d:	mov    rax,QWORD PTR [rsp+0x28]
    4212:	test   rax,0x1
    4218:	jne    423e <botlish_fn_50+0x166>
    421e:	mov    edx,0x3
    4223:	mov    rsi,QWORD PTR [rsp+0x28]
    4228:	mov    rdi,rbx
    422b:	call   4230 <botlish_fn_50+0x158>
			422c: R_X86_64_PLT32	rt_value_eq-0x4
    4230:	test   rax,rax
    4233:	je     43c8 <botlish_fn_50+0x2f0>
    4239:	jmp    4254 <botlish_fn_50+0x17c>
    423e:	mov    rsi,QWORD PTR [rsp+0x28]
    4243:	mov    eax,0x2
    4248:	cmp    rsi,0x3
    424c:	cmove  rax,QWORD PTR [rip+0x1c4]        # 4418 <botlish_fn_50+0x340>
    4254:	cmp    rax,0x6
    4258:	je     4357 <botlish_fn_50+0x27f>
    425e:	mov    rsi,r14
    4261:	mov    rdi,rbx
    4264:	call   4269 <botlish_fn_50+0x191>
			4265: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    4269:	test   rax,rax
    426c:	je     43c8 <botlish_fn_50+0x2f0>
    4272:	cmp    rax,0x6
    4276:	je     42bb <botlish_fn_50+0x1e3>
    427c:	mov    rcx,r13
    427f:	mov    rdx,r15
    4282:	mov    rsi,r14
    4285:	mov    rdi,rbx
    4288:	mov    r8,r12
    428b:	call   4290 <botlish_fn_50+0x1b8>
			428c: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    4290:	test   rax,rax
    4293:	je     43c8 <botlish_fn_50+0x2f0>
    4299:	mov    rbx,QWORD PTR [rsp+0x40]
    429e:	mov    r12,QWORD PTR [rsp+0x48]
    42a3:	mov    r13,QWORD PTR [rsp+0x50]
    42a8:	mov    r14,QWORD PTR [rsp+0x58]
    42ad:	mov    r15,QWORD PTR [rsp+0x60]
    42b2:	add    rsp,0x70
    42b6:	mov    rsp,rbp
    42b9:	pop    rbp
    42ba:	ret
    42bb:	mov    rsi,r14
    42be:	mov    rdi,rbx
    42c1:	call   42c6 <botlish_fn_50+0x1ee>
			42c2: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    42c6:	test   rax,rax
    42c9:	je     43c8 <botlish_fn_50+0x2f0>
    42cf:	mov    rdx,r13
    42d2:	mov    rsi,r14
    42d5:	mov    rdi,rbx
    42d8:	call   42dd <botlish_fn_50+0x205>
			42d9: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    42dd:	test   rax,rax
    42e0:	je     43c8 <botlish_fn_50+0x2f0>
    42e6:	mov    QWORD PTR [rsp+0x18],rax
    42eb:	mov    rcx,rax
    42ee:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    42f7:	mov    r8,QWORD PTR [rsp+0x30]
    42fc:	mov    rdx,r13
    42ff:	mov    rsi,r14
    4302:	mov    rdi,rbx
    4305:	call   430a <botlish_fn_50+0x232>
			4306: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    430a:	test   rax,rax
    430d:	je     43c8 <botlish_fn_50+0x2f0>
    4313:	mov    QWORD PTR [rsp+0x18],rax
    4318:	mov    rcx,r13
    431b:	mov    rdx,rax
    431e:	mov    rsi,r14
    4321:	mov    rdi,rbx
    4324:	mov    r8,r12
    4327:	call   432c <botlish_fn_50+0x254>
			4328: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    432c:	test   rax,rax
    432f:	je     43c8 <botlish_fn_50+0x2f0>
    4335:	mov    rbx,QWORD PTR [rsp+0x40]
    433a:	mov    r12,QWORD PTR [rsp+0x48]
    433f:	mov    r13,QWORD PTR [rsp+0x50]
    4344:	mov    r14,QWORD PTR [rsp+0x58]
    4349:	mov    r15,QWORD PTR [rsp+0x60]
    434e:	add    rsp,0x70
    4352:	mov    rsp,rbp
    4355:	pop    rbp
    4356:	ret
    4357:	mov    rsi,r14
    435a:	mov    rdi,rbx
    435d:	call   4362 <botlish_fn_50+0x28a>
			435e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4362:	test   rax,rax
    4365:	je     43c8 <botlish_fn_50+0x2f0>
    436b:	xor    ecx,ecx
    436d:	test   rax,0x7
    4373:	je     4381 <botlish_fn_50+0x2a9>
    4379:	mov    rsi,rax
    437c:	jmp    438f <botlish_fn_50+0x2b7>
    4381:	movzx  rcx,BYTE PTR [rax]
    4385:	mov    rsi,rax
    4388:	rex cmp cl,0x8
    438c:	sete   cl
    438f:	test   cl,cl
    4391:	jne    43b1 <botlish_fn_50+0x2d9>
    4397:	mov    rdi,rbx
    439a:	mov    rax,QWORD PTR [rdi+0x10]
    439e:	mov    rcx,QWORD PTR [rax+0x40]
    43a2:	mov    edx,0x8
    43a7:	call   43ac <botlish_fn_50+0x2d4>
			43a8: R_X86_64_PLT32	rt_type_error-0x4
    43ac:	jmp    43c8 <botlish_fn_50+0x2f0>
    43b1:	mov    rcx,r12
    43b4:	mov    rdx,r15
    43b7:	mov    rdi,rbx
    43ba:	call   43bf <botlish_fn_50+0x2e7>
			43bb: R_X86_64_PLT32	rt_mutarray_set-0x4
    43bf:	test   rax,rax
    43c2:	jne    43ed <botlish_fn_50+0x315>
    43c8:	xor    rax,rax
    43cb:	mov    rbx,QWORD PTR [rsp+0x40]
    43d0:	mov    r12,QWORD PTR [rsp+0x48]
    43d5:	mov    r13,QWORD PTR [rsp+0x50]
    43da:	mov    r14,QWORD PTR [rsp+0x58]
    43df:	mov    r15,QWORD PTR [rsp+0x60]
    43e4:	add    rsp,0x70
    43e8:	mov    rsp,rbp
    43eb:	pop    rbp
    43ec:	ret
    43ed:	mov    eax,0xa
    43f2:	mov    rbx,QWORD PTR [rsp+0x40]
    43f7:	mov    r12,QWORD PTR [rsp+0x48]
    43fc:	mov    r13,QWORD PTR [rsp+0x50]
    4401:	mov    r14,QWORD PTR [rsp+0x58]
    4406:	mov    r15,QWORD PTR [rsp+0x60]
    440b:	add    rsp,0x70
    440f:	mov    rsp,rbp
    4412:	pop    rbp
    4413:	ret
    4414:	add    BYTE PTR [rax],al
    4416:	add    BYTE PTR [rax],al
    4418:	(bad)
    4419:	add    BYTE PTR [rax],al
    441b:	add    BYTE PTR [rax],al
    441d:	add    BYTE PTR [rax],al
	...

0000000000004420 <botlish_entry_50: ht_set<mutarray, any, any>>:
    4420:	push   rbp
    4421:	mov    rbp,rsp
    4424:	mov    rsi,QWORD PTR [rdx]
    4427:	mov    r8,QWORD PTR [rdx+0x8]
    442b:	mov    rcx,QWORD PTR [rdx+0x10]
    442f:	mov    rdx,r8
    4432:	call   4437 <botlish_entry_50+0x17>
			4433: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    4437:	mov    rsp,rbp
    443a:	pop    rbp
    443b:	ret

000000000000443c <botlish_fn_51: row_new<bool, int>>:
    443c:	push   rbp
    443d:	mov    rbp,rsp
    4440:	sub    rsp,0x10
    4444:	mov    QWORD PTR [rsp],rdx
    4448:	mov    r8,rdx
    444b:	cmp    rsi,0x6
    444f:	je     446c <botlish_fn_51+0x30>
    4455:	call   445a <botlish_fn_51+0x1e>
			4456: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    445a:	test   rax,rax
    445d:	je     447d <botlish_fn_51+0x41>
    4463:	add    rsp,0x10
    4467:	mov    rsp,rbp
    446a:	pop    rbp
    446b:	ret
    446c:	mov    rsi,r8
    446f:	call   4474 <botlish_fn_51+0x38>
			4470: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    4474:	test   rax,rax
    4477:	jne    4489 <botlish_fn_51+0x4d>
    447d:	xor    rax,rax
    4480:	add    rsp,0x10
    4484:	mov    rsp,rbp
    4487:	pop    rbp
    4488:	ret
    4489:	add    rsp,0x10
    448d:	mov    rsp,rbp
    4490:	pop    rbp
    4491:	ret

0000000000004492 <botlish_entry_51: row_new<bool, int>>:
    4492:	push   rbp
    4493:	mov    rbp,rsp
    4496:	mov    rsi,QWORD PTR [rdx]
    4499:	mov    rdx,QWORD PTR [rdx+0x8]
    449d:	call   44a2 <botlish_entry_51+0x10>
			449e: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    44a2:	mov    rsp,rbp
    44a5:	pop    rbp
    44a6:	ret
	...

00000000000044a8 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    44a8:	push   rbp
    44a9:	mov    rbp,rsp
    44ac:	sub    rsp,0x70
    44b0:	mov    QWORD PTR [rsp+0x40],rbx
    44b5:	mov    QWORD PTR [rsp+0x48],r12
    44ba:	mov    QWORD PTR [rsp+0x50],r13
    44bf:	mov    QWORD PTR [rsp+0x58],r14
    44c4:	mov    QWORD PTR [rsp+0x60],r15
    44c9:	mov    rbx,rdx
    44cc:	mov    r15,rdi
    44cf:	mov    QWORD PTR [rsp],rsi
    44d3:	mov    r13,rsi
    44d6:	mov    QWORD PTR [rsp+0x8],rdx
    44db:	mov    QWORD PTR [rsp+0x10],rcx
    44e0:	mov    QWORD PTR [rsp+0x30],rcx
    44e5:	mov    QWORD PTR [rsp+0x18],r8
    44ea:	mov    r14,r9
    44ed:	mov    rax,r14
    44f0:	or     rax,0x1
    44f4:	mov    r12,r8
    44f7:	mov    rcx,r12
    44fa:	and    rcx,rax
    44fd:	test   rcx,0x1
    4504:	jne    4531 <botlish_fn_52+0x89>
    450a:	mov    rdx,r14
    450d:	or     rdx,0x1
    4511:	mov    rsi,r12
    4514:	mov    rdi,r15
    4517:	call   451c <botlish_fn_52+0x74>
			4518: R_X86_64_PLT32	rt_int_cmp-0x4
    451c:	mov    ecx,0x2
    4521:	test   rax,rax
    4524:	cmovge rcx,QWORD PTR [rip+0x20c]        # 4738 <botlish_fn_52+0x290>
    452c:	jmp    4548 <botlish_fn_52+0xa0>
    4531:	mov    rdx,r14
    4534:	or     rdx,0x1
    4538:	mov    ecx,0x2
    453d:	cmp    r12,rdx
    4540:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 4738 <botlish_fn_52+0x290>
    4548:	cmp    rcx,0x6
    454c:	je     4712 <botlish_fn_52+0x26a>
    4552:	xor    ecx,ecx
    4554:	mov    rdx,rbx
    4557:	test   rdx,0x7
    455e:	jne    4572 <botlish_fn_52+0xca>
    4564:	mov    rdx,rbx
    4567:	movzx  r9,BYTE PTR [rdx]
    456b:	cmp    r9b,0x3
    456f:	sete   cl
    4572:	test   cl,cl
    4574:	jne    4597 <botlish_fn_52+0xef>
    457a:	mov    rdi,r15
    457d:	mov    rax,QWORD PTR [rdi+0x10]
    4581:	mov    rcx,QWORD PTR [rax+0x50]
    4585:	mov    edx,0x4
    458a:	mov    rsi,rbx
    458d:	call   4592 <botlish_fn_52+0xea>
			458e: R_X86_64_PLT32	rt_type_error-0x4
    4592:	jmp    46bc <botlish_fn_52+0x214>
    4597:	mov    rsi,rbx
    459a:	test   r12,0x1
    45a1:	jne    45af <botlish_fn_52+0x107>
    45a7:	mov    rbx,rsi
    45aa:	jmp    45c5 <botlish_fn_52+0x11d>
    45af:	mov    rax,QWORD PTR [rsi+0x8]
    45b3:	mov    rbx,rsi
    45b6:	mov    rcx,r12
    45b9:	sar    rcx,1
    45bc:	cmp    rcx,rax
    45bf:	jb     45e4 <botlish_fn_52+0x13c>
    45c5:	mov    rdx,r12
    45c8:	mov    rsi,rbx
    45cb:	mov    rdi,r15
    45ce:	call   45d3 <botlish_fn_52+0x12b>
			45cf: R_X86_64_PLT32	rt_list_get-0x4
    45d3:	test   rax,rax
    45d6:	je     46bc <botlish_fn_52+0x214>
    45dc:	mov    rdx,rax
    45df:	jmp    45ec <botlish_fn_52+0x144>
    45e4:	mov    rax,QWORD PTR [rbx+0x10]
    45e8:	mov    rdx,QWORD PTR [rax+rcx*8]
    45ec:	mov    QWORD PTR [rsp+0x20],rdx
    45f1:	mov    QWORD PTR [rsp+0x38],rdx
    45f6:	xor    esi,esi
    45f8:	mov    rcx,QWORD PTR [rsp+0x30]
    45fd:	test   rcx,0x7
    4604:	je     4614 <botlish_fn_52+0x16c>
    460a:	mov    QWORD PTR [rsp+0x30],rcx
    460f:	jmp    4623 <botlish_fn_52+0x17b>
    4614:	movzx  rax,BYTE PTR [rcx]
    4618:	mov    QWORD PTR [rsp+0x30],rcx
    461d:	cmp    al,0x3
    461f:	sete   sil
    4623:	test   sil,sil
    4626:	jne    464b <botlish_fn_52+0x1a3>
    462c:	mov    rdi,r15
    462f:	mov    rax,QWORD PTR [rdi+0x10]
    4633:	mov    rcx,QWORD PTR [rax+0x50]
    4637:	mov    edx,0x4
    463c:	mov    rsi,QWORD PTR [rsp+0x30]
    4641:	call   4646 <botlish_fn_52+0x19e>
			4642: R_X86_64_PLT32	rt_type_error-0x4
    4646:	jmp    46bc <botlish_fn_52+0x214>
    464b:	test   r12,0x1
    4652:	je     4670 <botlish_fn_52+0x1c8>
    4658:	mov    rsi,QWORD PTR [rsp+0x30]
    465d:	mov    rcx,QWORD PTR [rsi+0x8]
    4661:	mov    rax,r12
    4664:	sar    rax,1
    4667:	cmp    rax,rcx
    466a:	jb     4691 <botlish_fn_52+0x1e9>
    4670:	mov    rdx,r12
    4673:	mov    rsi,QWORD PTR [rsp+0x30]
    4678:	mov    rdi,r15
    467b:	call   4680 <botlish_fn_52+0x1d8>
			467c: R_X86_64_PLT32	rt_list_get-0x4
    4680:	test   rax,rax
    4683:	je     46bc <botlish_fn_52+0x214>
    4689:	mov    rcx,rax
    468c:	jmp    469e <botlish_fn_52+0x1f6>
    4691:	mov    rsi,QWORD PTR [rsp+0x30]
    4696:	mov    rcx,QWORD PTR [rsi+0x10]
    469a:	mov    rcx,QWORD PTR [rcx+rax*8]
    469e:	mov    QWORD PTR [rsp+0x28],rcx
    46a3:	mov    rdx,QWORD PTR [rsp+0x38]
    46a8:	mov    rsi,r13
    46ab:	mov    rdi,r15
    46ae:	call   46b3 <botlish_fn_52+0x20b>
			46af: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    46b3:	test   rax,rax
    46b6:	jne    46e1 <botlish_fn_52+0x239>
    46bc:	xor    rax,rax
    46bf:	mov    rbx,QWORD PTR [rsp+0x40]
    46c4:	mov    r12,QWORD PTR [rsp+0x48]
    46c9:	mov    r13,QWORD PTR [rsp+0x50]
    46ce:	mov    r14,QWORD PTR [rsp+0x58]
    46d3:	mov    r15,QWORD PTR [rsp+0x60]
    46d8:	add    rsp,0x70
    46dc:	mov    rsp,rbp
    46df:	pop    rbp
    46e0:	ret
    46e1:	mov    QWORD PTR [rsp],r13
    46e5:	mov    QWORD PTR [rsp+0x8],rbx
    46ea:	mov    rsi,QWORD PTR [rsp+0x30]
    46ef:	mov    QWORD PTR [rsp+0x10],rsi
    46f4:	sar    r12,1
    46f7:	add    r12,0x1
    46fe:	shl    r12,1
    4701:	or     r12,0x1
    4705:	mov    QWORD PTR [rsp+0x18],r12
    470a:	mov    r8,r12
    470d:	jmp    44ed <botlish_fn_52+0x45>
    4712:	mov    rax,r13
    4715:	mov    rbx,QWORD PTR [rsp+0x40]
    471a:	mov    r12,QWORD PTR [rsp+0x48]
    471f:	mov    r13,QWORD PTR [rsp+0x50]
    4724:	mov    r14,QWORD PTR [rsp+0x58]
    4729:	mov    r15,QWORD PTR [rsp+0x60]
    472e:	add    rsp,0x70
    4732:	mov    rsp,rbp
    4735:	pop    rbp
    4736:	ret
    4737:	add    BYTE PTR [rsi],al
    4739:	add    BYTE PTR [rax],al
    473b:	add    BYTE PTR [rax],al
    473d:	add    BYTE PTR [rax],al
	...

0000000000004740 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    4740:	push   rbp
    4741:	mov    rbp,rsp
    4744:	mov    rsi,QWORD PTR [rdx]
    4747:	mov    r10,QWORD PTR [rdx+0x8]
    474b:	mov    rcx,QWORD PTR [rdx+0x10]
    474f:	mov    r8,QWORD PTR [rdx+0x18]
    4753:	mov    r9,QWORD PTR [rdx+0x20]
    4757:	mov    rdx,r10
    475a:	call   475f <botlish_entry_52+0x1f>
			475b: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    475f:	mov    rsp,rbp
    4762:	pop    rbp
    4763:	ret

0000000000004764 <botlish_fn_53: row_table<any, int, any, bool>>:
    4764:	push   rbp
    4765:	mov    rbp,rsp
    4768:	sub    rsp,0x50
    476c:	mov    QWORD PTR [rsp+0x30],rbx
    4771:	mov    QWORD PTR [rsp+0x38],r12
    4776:	mov    QWORD PTR [rsp+0x40],r13
    477b:	mov    QWORD PTR [rsp+0x48],r14
    4780:	mov    r12,rdi
    4783:	mov    QWORD PTR [rsp+0x20],0x0
    478c:	mov    QWORD PTR [rsp],rsi
    4790:	mov    r13,rsi
    4793:	mov    QWORD PTR [rsp+0x8],rdx
    4798:	mov    QWORD PTR [rsp+0x10],rcx
    479d:	mov    rbx,rcx
    47a0:	mov    QWORD PTR [rsp+0x18],r8
    47a5:	mov    rsi,r8
    47a8:	mov    rdi,r12
    47ab:	call   47b0 <botlish_fn_53+0x4c>
			47ac: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    47b0:	test   rax,rax
    47b3:	je     4848 <botlish_fn_53+0xe4>
    47b9:	mov    QWORD PTR [rsp+0x8],rax
    47be:	mov    r14,rax
    47c1:	mov    QWORD PTR [rsp+0x18],0x1
    47ca:	xor    eax,eax
    47cc:	mov    rcx,rbx
    47cf:	test   rcx,0x7
    47d6:	je     47e4 <botlish_fn_53+0x80>
    47dc:	mov    rbx,rcx
    47df:	jmp    47f0 <botlish_fn_53+0x8c>
    47e4:	movzx  rax,BYTE PTR [rcx]
    47e8:	mov    rbx,rcx
    47eb:	cmp    al,0x3
    47ed:	sete   al
    47f0:	test   al,al
    47f2:	jne    4815 <botlish_fn_53+0xb1>
    47f8:	mov    rdi,r12
    47fb:	mov    rax,QWORD PTR [rdi+0x10]
    47ff:	mov    rcx,QWORD PTR [rax+0x58]
    4803:	mov    edx,0x4
    4808:	mov    rsi,rbx
    480b:	call   4810 <botlish_fn_53+0xac>
			480c: R_X86_64_PLT32	rt_type_error-0x4
    4810:	jmp    4848 <botlish_fn_53+0xe4>
    4815:	mov    rsi,rbx
    4818:	mov    rdi,r12
    481b:	call   4820 <botlish_fn_53+0xbc>
			481c: R_X86_64_PLT32	rt_list_len-0x4
    4820:	mov    QWORD PTR [rsp+0x20],rax
    4825:	mov    r8d,0x1
    482b:	mov    rcx,rbx
    482e:	mov    rdx,r13
    4831:	mov    rsi,r14
    4834:	mov    rdi,r12
    4837:	mov    r9,rax
    483a:	call   483f <botlish_fn_53+0xdb>
			483b: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    483f:	test   rax,rax
    4842:	jne    4868 <botlish_fn_53+0x104>
    4848:	xor    rax,rax
    484b:	mov    rbx,QWORD PTR [rsp+0x30]
    4850:	mov    r12,QWORD PTR [rsp+0x38]
    4855:	mov    r13,QWORD PTR [rsp+0x40]
    485a:	mov    r14,QWORD PTR [rsp+0x48]
    485f:	add    rsp,0x50
    4863:	mov    rsp,rbp
    4866:	pop    rbp
    4867:	ret
    4868:	mov    rbx,QWORD PTR [rsp+0x30]
    486d:	mov    r12,QWORD PTR [rsp+0x38]
    4872:	mov    r13,QWORD PTR [rsp+0x40]
    4877:	mov    r14,QWORD PTR [rsp+0x48]
    487c:	add    rsp,0x50
    4880:	mov    rsp,rbp
    4883:	pop    rbp
    4884:	ret

0000000000004885 <botlish_entry_53: row_table<any, int, any, bool>>:
    4885:	push   rbp
    4886:	mov    rbp,rsp
    4889:	mov    rsi,QWORD PTR [rdx]
    488c:	mov    r9,QWORD PTR [rdx+0x8]
    4890:	mov    rcx,QWORD PTR [rdx+0x10]
    4894:	mov    r8,QWORD PTR [rdx+0x18]
    4898:	mov    rdx,r9
    489b:	call   48a0 <botlish_entry_53+0x1b>
			489c: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    48a0:	mov    rsp,rbp
    48a3:	pop    rbp
    48a4:	ret
    48a5:	add    BYTE PTR [rax],al
	...

00000000000048a8 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    48a8:	push   rbp
    48a9:	mov    rbp,rsp
    48ac:	sub    rsp,0x90
    48b3:	mov    QWORD PTR [rsp+0x60],rbx
    48b8:	mov    QWORD PTR [rsp+0x68],r12
    48bd:	mov    QWORD PTR [rsp+0x70],r13
    48c2:	mov    QWORD PTR [rsp+0x78],r14
    48c7:	mov    QWORD PTR [rsp+0x80],r15
    48cf:	mov    r13,r8
    48d2:	mov    QWORD PTR [rsp+0x40],rdi
    48d7:	mov    r11,QWORD PTR [rbp+0x10]
    48db:	mov    r15,QWORD PTR [rbp+0x18]
    48df:	mov    QWORD PTR [rsp+0x30],0x0
    48e8:	mov    QWORD PTR [rsp+0x38],0x0
    48f1:	mov    QWORD PTR [rsp],rsi
    48f5:	mov    QWORD PTR [rsp+0x8],rdx
    48fa:	mov    r12,rdx
    48fd:	mov    QWORD PTR [rsp+0x10],rcx
    4902:	mov    r14,rcx
    4905:	mov    QWORD PTR [rsp+0x18],r9
    490a:	mov    QWORD PTR [rsp+0x20],r11
    490f:	mov    QWORD PTR [rsp+0x50],r11
    4914:	mov    QWORD PTR [rsp+0x28],r15
    4919:	mov    rbx,rsi
    491c:	mov    QWORD PTR [rsp+0x48],r9
    4921:	mov    rsi,rbx
    4924:	mov    rdi,QWORD PTR [rsp+0x40]
    4929:	call   492e <botlish_fn_54+0x86>
			492a: R_X86_64_PLT32	rt_list_len-0x4
    492e:	mov    rcx,r12
    4931:	and    rcx,rax
    4934:	mov    rdx,rax
    4937:	test   rcx,0x1
    493e:	jne    4966 <botlish_fn_54+0xbe>
    4944:	mov    rsi,r12
    4947:	mov    rdi,QWORD PTR [rsp+0x40]
    494c:	call   4951 <botlish_fn_54+0xa9>
			494d: R_X86_64_PLT32	rt_int_cmp-0x4
    4951:	mov    ecx,0x2
    4956:	test   rax,rax
    4959:	cmovge rcx,QWORD PTR [rip+0x177]        # 4ad8 <botlish_fn_54+0x230>
    4961:	jmp    4976 <botlish_fn_54+0xce>
    4966:	mov    ecx,0x2
    496b:	cmp    r12,rdx
    496e:	cmovge rcx,QWORD PTR [rip+0x162]        # 4ad8 <botlish_fn_54+0x230>
    4976:	cmp    rcx,0x6
    497a:	je     4a61 <botlish_fn_54+0x1b9>
    4980:	mov    rax,r13
    4983:	or     rax,0x1
    4987:	mov    QWORD PTR [rsp+0x30],rax
    498c:	test   r12,0x1
    4993:	je     49ac <botlish_fn_54+0x104>
    4999:	mov    rcx,QWORD PTR [rbx+0x8]
    499d:	mov    rax,r12
    49a0:	sar    rax,1
    49a3:	cmp    rax,rcx
    49a6:	jb     49cd <botlish_fn_54+0x125>
    49ac:	mov    rdx,r12
    49af:	mov    rsi,rbx
    49b2:	mov    rdi,QWORD PTR [rsp+0x40]
    49b7:	call   49bc <botlish_fn_54+0x114>
			49b8: R_X86_64_PLT32	rt_list_get-0x4
    49bc:	test   rax,rax
    49bf:	je     4a7e <botlish_fn_54+0x1d6>
    49c5:	mov    rcx,rax
    49c8:	jmp    49d5 <botlish_fn_54+0x12d>
    49cd:	mov    rsi,QWORD PTR [rbx+0x10]
    49d1:	mov    rcx,QWORD PTR [rsi+rax*8]
    49d5:	mov    QWORD PTR [rsp+0x38],rcx
    49da:	mov    rdx,r13
    49dd:	or     rdx,0x1
    49e1:	mov    rsi,r14
    49e4:	mov    rdi,QWORD PTR [rsp+0x40]
    49e9:	mov    r8,r15
    49ec:	call   49f1 <botlish_fn_54+0x149>
			49ed: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    49f1:	test   rax,rax
    49f4:	je     4a7e <botlish_fn_54+0x1d6>
    49fa:	mov    QWORD PTR [rsp+0x8],rax
    49ff:	mov    rcx,rax
    4a02:	sar    r12,1
    4a05:	add    r12,0x1
    4a0c:	shl    r12,1
    4a0f:	or     r12,0x1
    4a13:	mov    QWORD PTR [rsp+0x30],r12
    4a18:	mov    rdx,QWORD PTR [rsp+0x50]
    4a1d:	mov    rsi,QWORD PTR [rsp+0x48]
    4a22:	mov    rdi,QWORD PTR [rsp+0x40]
    4a27:	call   4a2c <botlish_fn_54+0x184>
			4a28: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    4a2c:	test   rax,rax
    4a2f:	je     4a7e <botlish_fn_54+0x1d6>
    4a35:	mov    QWORD PTR [rsp],rbx
    4a39:	mov    QWORD PTR [rsp+0x8],r12
    4a3e:	mov    QWORD PTR [rsp+0x10],r14
    4a43:	mov    QWORD PTR [rsp+0x18],rax
    4a48:	mov    QWORD PTR [rsp+0x20],rdx
    4a4d:	mov    QWORD PTR [rsp+0x28],r15
    4a52:	mov    QWORD PTR [rsp+0x48],rax
    4a57:	mov    QWORD PTR [rsp+0x50],rdx
    4a5c:	jmp    4921 <botlish_fn_54+0x79>
    4a61:	mov    rdx,QWORD PTR [rsp+0x50]
    4a66:	mov    rsi,QWORD PTR [rsp+0x48]
    4a6b:	mov    rdi,QWORD PTR [rsp+0x40]
    4a70:	call   4a75 <botlish_fn_54+0x1cd>
			4a71: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    4a75:	test   rax,rax
    4a78:	jne    4aa9 <botlish_fn_54+0x201>
    4a7e:	xor    rax,rax
    4a81:	mov    rbx,QWORD PTR [rsp+0x60]
    4a86:	mov    r12,QWORD PTR [rsp+0x68]
    4a8b:	mov    r13,QWORD PTR [rsp+0x70]
    4a90:	mov    r14,QWORD PTR [rsp+0x78]
    4a95:	mov    r15,QWORD PTR [rsp+0x80]
    4a9d:	add    rsp,0x90
    4aa4:	mov    rsp,rbp
    4aa7:	pop    rbp
    4aa8:	ret
    4aa9:	mov    rbx,QWORD PTR [rsp+0x60]
    4aae:	mov    r12,QWORD PTR [rsp+0x68]
    4ab3:	mov    r13,QWORD PTR [rsp+0x70]
    4ab8:	mov    r14,QWORD PTR [rsp+0x78]
    4abd:	mov    r15,QWORD PTR [rsp+0x80]
    4ac5:	add    rsp,0x90
    4acc:	mov    rsp,rbp
    4acf:	pop    rbp
    4ad0:	ret
    4ad1:	add    BYTE PTR [rax],al
    4ad3:	add    BYTE PTR [rax],al
    4ad5:	add    BYTE PTR [rax],al
    4ad7:	add    BYTE PTR [rsi],al
    4ad9:	add    BYTE PTR [rax],al
    4adb:	add    BYTE PTR [rax],al
    4add:	add    BYTE PTR [rax],al
	...

0000000000004ae0 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4ae0:	push   rbp
    4ae1:	mov    rbp,rsp
    4ae4:	sub    rsp,0x10
    4ae8:	mov    rsi,QWORD PTR [rdx]
    4aeb:	mov    r10,QWORD PTR [rdx+0x8]
    4aef:	mov    rcx,QWORD PTR [rdx+0x10]
    4af3:	mov    r8,QWORD PTR [rdx+0x18]
    4af7:	mov    r9,QWORD PTR [rdx+0x20]
    4afb:	mov    r11,QWORD PTR [rdx+0x28]
    4aff:	mov    rax,QWORD PTR [rdx+0x30]
    4b03:	mov    QWORD PTR [rsp],r11
    4b07:	mov    QWORD PTR [rsp+0x8],rax
    4b0c:	mov    rdx,r10
    4b0f:	call   4b14 <botlish_entry_54+0x34>
			4b10: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4b14:	add    rsp,0x10
    4b18:	mov    rsp,rbp
    4b1b:	pop    rbp
    4b1c:	ret

0000000000004b1d <botlish_fn_55: csv_records_generic<str, bool>>:
    4b1d:	push   rbp
    4b1e:	mov    rbp,rsp
    4b21:	sub    rsp,0x80
    4b28:	mov    QWORD PTR [rsp+0x50],rbx
    4b2d:	mov    QWORD PTR [rsp+0x58],r12
    4b32:	mov    QWORD PTR [rsp+0x60],r13
    4b37:	mov    QWORD PTR [rsp+0x68],r14
    4b3c:	mov    QWORD PTR [rsp+0x70],r15
    4b41:	mov    rbx,rdi
    4b44:	mov    QWORD PTR [rsp+0x20],0x0
    4b4d:	mov    QWORD PTR [rsp+0x28],0x0
    4b56:	mov    QWORD PTR [rsp+0x30],0x0
    4b5f:	mov    QWORD PTR [rsp+0x38],0x0
    4b68:	mov    QWORD PTR [rsp+0x40],0x0
    4b71:	mov    QWORD PTR [rsp+0x10],rsi
    4b76:	mov    QWORD PTR [rsp+0x18],rdx
    4b7b:	mov    r12,rdx
    4b7e:	mov    rdi,rbx
    4b81:	call   4b86 <botlish_fn_55+0x69>
			4b82: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    4b86:	mov    rcx,rax
    4b89:	mov    r13,rax
    4b8c:	test   rax,rcx
    4b8f:	je     4cd5 <botlish_fn_55+0x1b8>
    4b95:	mov    rax,r13
    4b98:	mov    QWORD PTR [rsp+0x10],rax
    4b9d:	mov    rsi,r13
    4ba0:	mov    rdi,rbx
    4ba3:	call   4ba8 <botlish_fn_55+0x8b>
			4ba4: R_X86_64_PLT32	rt_list_len-0x4
    4ba8:	sar    rax,1
    4bab:	test   rax,rax
    4bae:	je     4cbe <botlish_fn_55+0x1a1>
    4bb4:	mov    rax,r13
    4bb7:	mov    rax,QWORD PTR [rax+0x8]
    4bbb:	test   rax,rax
    4bbe:	jne    4be5 <botlish_fn_55+0xc8>
    4bc4:	mov    edx,0x1
    4bc9:	mov    rsi,r13
    4bcc:	mov    rdi,rbx
    4bcf:	call   4bd4 <botlish_fn_55+0xb7>
			4bd0: R_X86_64_PLT32	rt_list_get-0x4
    4bd4:	test   rax,rax
    4bd7:	je     4cd5 <botlish_fn_55+0x1b8>
    4bdd:	mov    rsi,rax
    4be0:	jmp    4bf2 <botlish_fn_55+0xd5>
    4be5:	mov    rax,r13
    4be8:	mov    rcx,QWORD PTR [rax+0x10]
    4bec:	mov    rax,QWORD PTR [rcx]
    4bef:	mov    rsi,rax
    4bf2:	mov    QWORD PTR [rsp+0x20],rsi
    4bf7:	mov    QWORD PTR [rsp+0x28],0x3
    4c00:	xor    eax,eax
    4c02:	test   rsi,0x7
    4c09:	jne    4c18 <botlish_fn_55+0xfb>
    4c0f:	movzx  rax,BYTE PTR [rsi]
    4c13:	cmp    al,0x3
    4c15:	sete   al
    4c18:	test   al,al
    4c1a:	jne    4c3a <botlish_fn_55+0x11d>
    4c20:	mov    rdi,rbx
    4c23:	mov    rax,QWORD PTR [rdi+0x10]
    4c27:	mov    rcx,QWORD PTR [rax+0x58]
    4c2b:	mov    edx,0x4
    4c30:	call   4c35 <botlish_fn_55+0x118>
			4c31: R_X86_64_PLT32	rt_type_error-0x4
    4c35:	jmp    4cd5 <botlish_fn_55+0x1b8>
    4c3a:	mov    r14,rsi
    4c3d:	mov    rdi,rbx
    4c40:	call   4c45 <botlish_fn_55+0x128>
			4c41: R_X86_64_PLT32	rt_list_len-0x4
    4c45:	mov    QWORD PTR [rsp+0x30],rax
    4c4a:	mov    r15,rax
    4c4d:	mov    rdi,rbx
    4c50:	call   4c55 <botlish_fn_55+0x138>
			4c51: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    4c55:	test   rax,rax
    4c58:	je     4cd5 <botlish_fn_55+0x1b8>
    4c5e:	mov    QWORD PTR [rsp+0x38],rax
    4c63:	mov    r9,rax
    4c66:	mov    QWORD PTR [rsp+0x40],rdx
    4c6b:	mov    rax,rdx
    4c6e:	mov    edx,0x3
    4c73:	mov    QWORD PTR [rsp],rax
    4c77:	mov    rax,r12
    4c7a:	mov    QWORD PTR [rsp+0x8],rax
    4c7f:	mov    rcx,r14
    4c82:	mov    rsi,r13
    4c85:	mov    rdi,rbx
    4c88:	mov    r8,r15
    4c8b:	call   4c90 <botlish_fn_55+0x173>
			4c8c: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4c90:	test   rax,rax
    4c93:	je     4cd5 <botlish_fn_55+0x1b8>
    4c99:	mov    rbx,QWORD PTR [rsp+0x50]
    4c9e:	mov    r12,QWORD PTR [rsp+0x58]
    4ca3:	mov    r13,QWORD PTR [rsp+0x60]
    4ca8:	mov    r14,QWORD PTR [rsp+0x68]
    4cad:	mov    r15,QWORD PTR [rsp+0x70]
    4cb2:	add    rsp,0x80
    4cb9:	mov    rsp,rbp
    4cbc:	pop    rbp
    4cbd:	ret
    4cbe:	xor    rdx,rdx
    4cc1:	mov    rdi,rbx
    4cc4:	mov    rsi,rdx
    4cc7:	call   4ccc <botlish_fn_55+0x1af>
			4cc8: R_X86_64_PLT32	rt_list_new-0x4
    4ccc:	test   rax,rax
    4ccf:	jne    4cfd <botlish_fn_55+0x1e0>
    4cd5:	xor    rax,rax
    4cd8:	mov    rbx,QWORD PTR [rsp+0x50]
    4cdd:	mov    r12,QWORD PTR [rsp+0x58]
    4ce2:	mov    r13,QWORD PTR [rsp+0x60]
    4ce7:	mov    r14,QWORD PTR [rsp+0x68]
    4cec:	mov    r15,QWORD PTR [rsp+0x70]
    4cf1:	add    rsp,0x80
    4cf8:	mov    rsp,rbp
    4cfb:	pop    rbp
    4cfc:	ret
    4cfd:	mov    rbx,QWORD PTR [rsp+0x50]
    4d02:	mov    r12,QWORD PTR [rsp+0x58]
    4d07:	mov    r13,QWORD PTR [rsp+0x60]
    4d0c:	mov    r14,QWORD PTR [rsp+0x68]
    4d11:	mov    r15,QWORD PTR [rsp+0x70]
    4d16:	add    rsp,0x80
    4d1d:	mov    rsp,rbp
    4d20:	pop    rbp
    4d21:	ret

0000000000004d22 <botlish_entry_55: csv_records_generic<str, bool>>:
    4d22:	push   rbp
    4d23:	mov    rbp,rsp
    4d26:	mov    rsi,QWORD PTR [rdx]
    4d29:	mov    rdx,QWORD PTR [rdx+0x8]
    4d2d:	call   4d32 <botlish_entry_55+0x10>
			4d2e: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4d32:	mov    rsp,rbp
    4d35:	pop    rbp
    4d36:	ret

0000000000004d37 <botlish_fn_56: csv_records<str>>:
    4d37:	push   rbp
    4d38:	mov    rbp,rsp
    4d3b:	sub    rsp,0x10
    4d3f:	mov    QWORD PTR [rsp],rsi
    4d43:	mov    edx,0x2
    4d48:	mov    QWORD PTR [rsp+0x8],0x2
    4d51:	call   4d56 <botlish_fn_56+0x1f>
			4d52: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4d56:	test   rax,rax
    4d59:	jne    4d6b <botlish_fn_56+0x34>
    4d5f:	xor    rax,rax
    4d62:	add    rsp,0x10
    4d66:	mov    rsp,rbp
    4d69:	pop    rbp
    4d6a:	ret
    4d6b:	add    rsp,0x10
    4d6f:	mov    rsp,rbp
    4d72:	pop    rbp
    4d73:	ret

0000000000004d74 <botlish_entry_56: csv_records<str>>:
    4d74:	push   rbp
    4d75:	mov    rbp,rsp
    4d78:	mov    rsi,QWORD PTR [rdx]
    4d7b:	call   4d80 <botlish_entry_56+0xc>
			4d7c: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    4d80:	mov    rsp,rbp
    4d83:	pop    rbp
    4d84:	ret

0000000000004d85 <botlish_fn_57: csv_records_presized<str>>:
    4d85:	push   rbp
    4d86:	mov    rbp,rsp
    4d89:	sub    rsp,0x10
    4d8d:	mov    QWORD PTR [rsp],rsi
    4d91:	mov    edx,0x6
    4d96:	mov    QWORD PTR [rsp+0x8],0x6
    4d9f:	call   4da4 <botlish_fn_57+0x1f>
			4da0: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4da4:	test   rax,rax
    4da7:	jne    4db9 <botlish_fn_57+0x34>
    4dad:	xor    rax,rax
    4db0:	add    rsp,0x10
    4db4:	mov    rsp,rbp
    4db7:	pop    rbp
    4db8:	ret
    4db9:	add    rsp,0x10
    4dbd:	mov    rsp,rbp
    4dc0:	pop    rbp
    4dc1:	ret

0000000000004dc2 <botlish_entry_57: csv_records_presized<str>>:
    4dc2:	push   rbp
    4dc3:	mov    rbp,rsp
    4dc6:	mov    rsi,QWORD PTR [rdx]
    4dc9:	call   4dce <botlish_entry_57+0xc>
			4dca: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    4dce:	mov    rsp,rbp
    4dd1:	pop    rbp
    4dd2:	ret
    4dd3:	add    BYTE PTR [rax],al
    4dd5:	add    BYTE PTR [rax],al
	...

0000000000004dd8 <botlish_fn_58: sample<generic>>:
    4dd8:	push   rbp
    4dd9:	mov    rbp,rsp
    4ddc:	sub    rsp,0xc0
    4de3:	mov    QWORD PTR [rsp+0x90],rbx
    4deb:	mov    QWORD PTR [rsp+0x98],r12
    4df3:	mov    QWORD PTR [rsp+0xa0],r13
    4dfb:	mov    QWORD PTR [rsp+0xa8],r14
    4e03:	mov    QWORD PTR [rsp+0xb0],r15
    4e0b:	mov    QWORD PTR [rsp+0x8],0x0
    4e14:	mov    QWORD PTR [rsp+0x10],0x0
    4e1d:	mov    QWORD PTR [rsp+0x18],0x0
    4e26:	mov    QWORD PTR [rsp+0x20],0x0
    4e2f:	mov    QWORD PTR [rsp+0x28],0x0
    4e38:	mov    QWORD PTR [rsp+0x30],0x0
    4e41:	mov    QWORD PTR [rsp+0x38],0x0
    4e4a:	mov    rax,QWORD PTR [rdi+0x10]
    4e4e:	mov    r13,rdi
    4e51:	mov    rsi,QWORD PTR [rax+0x60]
    4e55:	mov    QWORD PTR [rsp],rsi
    4e59:	call   4e5e <botlish_fn_58+0x86>
			4e5a: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    4e5e:	mov    rsi,rax
    4e61:	mov    r12,rax
    4e64:	test   rax,rsi
    4e67:	je     51f1 <botlish_fn_58+0x419>
    4e6d:	mov    rax,r12
    4e70:	mov    QWORD PTR [rsp],rax
    4e74:	mov    rdi,r13
    4e77:	mov    rax,QWORD PTR [rdi+0x10]
    4e7b:	mov    rsi,QWORD PTR [rax+0x60]
    4e7f:	mov    QWORD PTR [rsp+0x8],rsi
    4e84:	call   4e89 <botlish_fn_58+0xb1>
			4e85: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    4e89:	mov    rbx,rax
    4e8c:	test   rbx,rbx
    4e8f:	je     51f1 <botlish_fn_58+0x419>
    4e95:	mov    rax,r12
    4e98:	mov    rax,QWORD PTR [rax+0x8]
    4e9c:	test   rax,rax
    4e9f:	jne    4ec6 <botlish_fn_58+0xee>
    4ea5:	mov    edx,0x1
    4eaa:	mov    rsi,r12
    4ead:	mov    rdi,r13
    4eb0:	call   4eb5 <botlish_fn_58+0xdd>
			4eb1: R_X86_64_PLT32	rt_list_get-0x4
    4eb5:	test   rax,rax
    4eb8:	je     51f1 <botlish_fn_58+0x419>
    4ebe:	mov    rsi,rax
    4ec1:	jmp    4ece <botlish_fn_58+0xf6>
    4ec6:	mov    rax,QWORD PTR [r12+0x10]
    4ecb:	mov    rsi,QWORD PTR [rax]
    4ece:	mov    QWORD PTR [rsp+0x8],rsi
    4ed3:	mov    r15,rsi
    4ed6:	mov    rax,QWORD PTR [r12+0x8]
    4edb:	cmp    rax,0x1
    4edf:	ja     4f06 <botlish_fn_58+0x12e>
    4ee5:	mov    edx,0x3
    4eea:	mov    rsi,r12
    4eed:	mov    rdi,r13
    4ef0:	call   4ef5 <botlish_fn_58+0x11d>
			4ef1: R_X86_64_PLT32	rt_list_get-0x4
    4ef5:	test   rax,rax
    4ef8:	je     51f1 <botlish_fn_58+0x419>
    4efe:	mov    rsi,rax
    4f01:	jmp    4f0f <botlish_fn_58+0x137>
    4f06:	mov    rax,QWORD PTR [r12+0x10]
    4f0b:	mov    rsi,QWORD PTR [rax+0x8]
    4f0f:	mov    QWORD PTR [rsp+0x10],rsi
    4f14:	mov    r14,rsi
    4f17:	mov    rax,QWORD PTR [rbx+0x8]
    4f1b:	mov    rsi,rbx
    4f1e:	test   rax,rax
    4f21:	jne    4f45 <botlish_fn_58+0x16d>
    4f27:	mov    edx,0x1
    4f2c:	mov    rdi,r13
    4f2f:	call   4f34 <botlish_fn_58+0x15c>
			4f30: R_X86_64_PLT32	rt_list_get-0x4
    4f34:	test   rax,rax
    4f37:	je     51f1 <botlish_fn_58+0x419>
    4f3d:	mov    rsi,rax
    4f40:	jmp    4f4c <botlish_fn_58+0x174>
    4f45:	mov    rax,QWORD PTR [rsi+0x10]
    4f49:	mov    rsi,QWORD PTR [rax]
    4f4c:	mov    QWORD PTR [rsp+0x18],rsi
    4f51:	mov    rdi,r13
    4f54:	mov    QWORD PTR [rsp+0x78],rsi
    4f59:	mov    rax,QWORD PTR [rdi+0x10]
    4f5d:	mov    rdx,QWORD PTR [rax+0x68]
    4f61:	mov    QWORD PTR [rsp+0x20],rdx
    4f66:	mov    rsi,r15
    4f69:	call   4f6e <botlish_fn_58+0x196>
			4f6a: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4f6e:	test   rax,rax
    4f71:	je     51f1 <botlish_fn_58+0x419>
    4f77:	mov    QWORD PTR [rsp+0x20],rax
    4f7c:	mov    rbx,rax
    4f7f:	mov    rdi,r13
    4f82:	mov    rax,QWORD PTR [rdi+0x10]
    4f86:	mov    rdx,QWORD PTR [rax+0x68]
    4f8a:	mov    QWORD PTR [rsp+0x28],rdx
    4f8f:	mov    rsi,QWORD PTR [rsp+0x78]
    4f94:	call   4f99 <botlish_fn_58+0x1c1>
			4f95: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4f99:	test   rax,rax
    4f9c:	je     51f1 <botlish_fn_58+0x419>
    4fa2:	mov    rcx,rbx
    4fa5:	mov    rdx,rcx
    4fa8:	and    rdx,rax
    4fab:	test   rdx,0x1
    4fb2:	jne    4fd4 <botlish_fn_58+0x1fc>
    4fb8:	mov    rdx,rax
    4fbb:	mov    rsi,rbx
    4fbe:	mov    rdi,r13
    4fc1:	call   4fc6 <botlish_fn_58+0x1ee>
			4fc2: R_X86_64_PLT32	rt_value_eq-0x4
    4fc6:	test   rax,rax
    4fc9:	je     51f1 <botlish_fn_58+0x419>
    4fcf:	jmp    4fea <botlish_fn_58+0x212>
    4fd4:	mov    rdx,rax
    4fd7:	mov    rsi,rbx
    4fda:	mov    eax,0x2
    4fdf:	cmp    rsi,rdx
    4fe2:	cmove  rax,QWORD PTR [rip+0x276]        # 5260 <botlish_fn_58+0x488>
    4fea:	mov    ebx,0x6
    4fef:	cmp    rax,0x6
    4ff3:	je     500e <botlish_fn_58+0x236>
    4ff9:	mov    ebx,0x2
    4ffe:	mov    QWORD PTR [rsp],0x2
    5006:	mov    rsi,r12
    5009:	jmp    50b2 <botlish_fn_58+0x2da>
    500e:	mov    rsi,r15
    5011:	mov    rdi,r13
    5014:	call   5019 <botlish_fn_58+0x241>
			5015: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    5019:	test   rax,rax
    501c:	je     51f1 <botlish_fn_58+0x419>
    5022:	mov    QWORD PTR [rsp+0x20],rax
    5027:	mov    rsi,QWORD PTR [rsp+0x78]
    502c:	mov    QWORD PTR [rsp+0x88],rax
    5034:	mov    rdi,r13
    5037:	call   503c <botlish_fn_58+0x264>
			5038: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    503c:	test   rax,rax
    503f:	je     51f1 <botlish_fn_58+0x419>
    5045:	mov    rcx,QWORD PTR [rsp+0x88]
    504d:	mov    rdx,rcx
    5050:	and    rdx,rax
    5053:	test   rdx,0x1
    505a:	jne    5081 <botlish_fn_58+0x2a9>
    5060:	mov    rdx,rax
    5063:	mov    rsi,QWORD PTR [rsp+0x88]
    506b:	mov    rdi,r13
    506e:	call   5073 <botlish_fn_58+0x29b>
			506f: R_X86_64_PLT32	rt_value_eq-0x4
    5073:	test   rax,rax
    5076:	je     51f1 <botlish_fn_58+0x419>
    507c:	jmp    509c <botlish_fn_58+0x2c4>
    5081:	mov    rdx,rax
    5084:	mov    rsi,QWORD PTR [rsp+0x88]
    508c:	mov    eax,0x2
    5091:	cmp    rsi,rdx
    5094:	cmove  rax,QWORD PTR [rip+0x1c4]        # 5260 <botlish_fn_58+0x488>
    509c:	cmp    rax,0x6
    50a0:	je     50ab <botlish_fn_58+0x2d3>
    50a6:	mov    ebx,0x2
    50ab:	mov    QWORD PTR [rsp],rbx
    50af:	mov    rsi,r12
    50b2:	mov    rdi,r13
    50b5:	call   50ba <botlish_fn_58+0x2e2>
			50b6: R_X86_64_PLT32	rt_list_len-0x4
    50ba:	mov    QWORD PTR [rsp+0x18],rax
    50bf:	mov    rdi,r13
    50c2:	mov    r12,rax
    50c5:	mov    rax,QWORD PTR [rdi+0x10]
    50c9:	mov    rdx,QWORD PTR [rax+0x68]
    50cd:	mov    QWORD PTR [rsp+0x20],rdx
    50d2:	mov    rsi,r15
    50d5:	call   50da <botlish_fn_58+0x302>
			50d6: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    50da:	test   rax,rax
    50dd:	je     51f1 <botlish_fn_58+0x419>
    50e3:	mov    QWORD PTR [rsp+0x20],rax
    50e8:	mov    rdi,r13
    50eb:	mov    QWORD PTR [rsp+0x88],rax
    50f3:	mov    rax,QWORD PTR [rdi+0x10]
    50f7:	mov    rdx,QWORD PTR [rax+0x70]
    50fb:	mov    QWORD PTR [rsp+0x28],rdx
    5100:	mov    rsi,r15
    5103:	call   5108 <botlish_fn_58+0x330>
			5104: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    5108:	test   rax,rax
    510b:	je     51f1 <botlish_fn_58+0x419>
    5111:	mov    QWORD PTR [rsp+0x28],rax
    5116:	mov    rdi,r13
    5119:	mov    QWORD PTR [rsp+0x80],rax
    5121:	mov    rax,QWORD PTR [rdi+0x10]
    5125:	mov    rdx,QWORD PTR [rax+0x78]
    5129:	mov    QWORD PTR [rsp+0x30],rdx
    512e:	mov    rsi,r15
    5131:	call   5136 <botlish_fn_58+0x35e>
			5132: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    5136:	test   rax,rax
    5139:	je     51f1 <botlish_fn_58+0x419>
    513f:	mov    QWORD PTR [rsp+0x8],rax
    5144:	mov    rdi,r13
    5147:	mov    r15,rax
    514a:	mov    rax,QWORD PTR [rdi+0x10]
    514e:	mov    rdx,QWORD PTR [rax+0x68]
    5152:	mov    QWORD PTR [rsp+0x30],rdx
    5157:	mov    rsi,r14
    515a:	call   515f <botlish_fn_58+0x387>
			515b: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    515f:	test   rax,rax
    5162:	je     51f1 <botlish_fn_58+0x419>
    5168:	mov    QWORD PTR [rsp+0x30],rax
    516d:	mov    rdi,r13
    5170:	mov    QWORD PTR [rsp+0x78],rax
    5175:	mov    rax,QWORD PTR [rdi+0x10]
    5179:	mov    rdx,QWORD PTR [rax+0x78]
    517d:	mov    QWORD PTR [rsp+0x38],rdx
    5182:	mov    rsi,r14
    5185:	call   518a <botlish_fn_58+0x3b2>
			5186: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    518a:	test   rax,rax
    518d:	je     51f1 <botlish_fn_58+0x419>
    5193:	mov    QWORD PTR [rsp+0x10],rax
    5198:	lea    rdx,[rsp+0x40]
    519d:	mov    r10,r12
    51a0:	mov    QWORD PTR [rsp+0x40],r10
    51a5:	mov    rcx,QWORD PTR [rsp+0x88]
    51ad:	mov    QWORD PTR [rsp+0x48],rcx
    51b2:	mov    rcx,QWORD PTR [rsp+0x80]
    51ba:	mov    QWORD PTR [rsp+0x50],rcx
    51bf:	mov    rcx,r15
    51c2:	mov    QWORD PTR [rsp+0x58],rcx
    51c7:	mov    rcx,QWORD PTR [rsp+0x78]
    51cc:	mov    QWORD PTR [rsp+0x60],rcx
    51d1:	mov    QWORD PTR [rsp+0x68],rax
    51d6:	mov    QWORD PTR [rsp+0x70],rbx
    51db:	mov    esi,0x7
    51e0:	mov    rdi,r13
    51e3:	call   51e8 <botlish_fn_58+0x410>
			51e4: R_X86_64_PLT32	rt_list_new-0x4
    51e8:	test   rax,rax
    51eb:	jne    5228 <botlish_fn_58+0x450>
    51f1:	xor    rax,rax
    51f4:	mov    rbx,QWORD PTR [rsp+0x90]
    51fc:	mov    r12,QWORD PTR [rsp+0x98]
    5204:	mov    r13,QWORD PTR [rsp+0xa0]
    520c:	mov    r14,QWORD PTR [rsp+0xa8]
    5214:	mov    r15,QWORD PTR [rsp+0xb0]
    521c:	add    rsp,0xc0
    5223:	mov    rsp,rbp
    5226:	pop    rbp
    5227:	ret
    5228:	mov    rbx,QWORD PTR [rsp+0x90]
    5230:	mov    r12,QWORD PTR [rsp+0x98]
    5238:	mov    r13,QWORD PTR [rsp+0xa0]
    5240:	mov    r14,QWORD PTR [rsp+0xa8]
    5248:	mov    r15,QWORD PTR [rsp+0xb0]
    5250:	add    rsp,0xc0
    5257:	mov    rsp,rbp
    525a:	pop    rbp
    525b:	ret
    525c:	add    BYTE PTR [rax],al
    525e:	add    BYTE PTR [rax],al
    5260:	(bad)
    5261:	add    BYTE PTR [rax],al
    5263:	add    BYTE PTR [rax],al
    5265:	add    BYTE PTR [rax],al
	...

0000000000005268 <botlish_entry_58: sample<generic>>:
    5268:	push   rbp
    5269:	mov    rbp,rsp
    526c:	call   5271 <botlish_entry_58+0x9>
			526d: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    5271:	mov    rsp,rbp
    5274:	pop    rbp
    5275:	ret

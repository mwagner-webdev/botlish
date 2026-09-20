; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 22468  (per function: 45 78 357 397 272 272 272 81 365 430 584 770 351 695 456 171 28 28 28 28 412 524 110 493 164 61 125 61 125 61 125 61 125 61 175 175 190 190 233 233 860 1328 437 436 456 1257 803 841 681 1240 908 107 756 335 645 580 78 78 1230)
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
    1572:	cmovge rcx,QWORD PTR [rip+0xee]        # 1668 <botlish_fn_20+0x160>
    157a:	jmp    1592 <botlish_fn_20+0x8a>
    157f:	mov    ecx,0x2
    1584:	mov    rsi,r14
    1587:	cmp    rsi,r12
    158a:	cmovge rcx,QWORD PTR [rip+0xd6]        # 1668 <botlish_fn_20+0x160>
    1592:	cmp    rcx,0x6
    1596:	je     1646 <botlish_fn_20+0x13e>
    159c:	mov    rdi,r13
    159f:	call   15a4 <botlish_fn_20+0x9c>
			15a0: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    15a4:	test   rax,rax
    15a7:	mov    rcx,rax
    15aa:	je     15c7 <botlish_fn_20+0xbf>
    15b0:	mov    rdx,r14
    15b3:	mov    rsi,rbx
    15b6:	mov    rdi,r13
    15b9:	call   15be <botlish_fn_20+0xb6>
			15ba: R_X86_64_PLT32	rt_mutarray_set-0x4
    15be:	test   rax,rax
    15c1:	jne    15e7 <botlish_fn_20+0xdf>
    15c7:	xor    rax,rax
    15ca:	mov    rbx,QWORD PTR [rsp+0x20]
    15cf:	mov    r12,QWORD PTR [rsp+0x28]
    15d4:	mov    r13,QWORD PTR [rsp+0x30]
    15d9:	mov    r14,QWORD PTR [rsp+0x38]
    15de:	add    rsp,0x40
    15e2:	mov    rsp,rbp
    15e5:	pop    rbp
    15e6:	ret
    15e7:	mov    QWORD PTR [rsp+0x18],0x3
    15f0:	mov    rsi,r14
    15f3:	test   rsi,0x1
    15fa:	je     161d <botlish_fn_20+0x115>
    1600:	mov    rsi,r14
    1603:	mov    rcx,rsi
    1606:	add    rcx,0x2
    160a:	seto   al
    160d:	test   al,al
    160f:	jne    161d <botlish_fn_20+0x115>
    1615:	mov    r14,rcx
    1618:	jmp    1630 <botlish_fn_20+0x128>
    161d:	mov    edx,0x3
    1622:	mov    rsi,r14
    1625:	mov    rdi,r13
    1628:	call   162d <botlish_fn_20+0x125>
			1629: R_X86_64_PLT32	rt_int_add-0x4
    162d:	mov    r14,rax
    1630:	mov    QWORD PTR [rsp],rbx
    1634:	mov    rsi,r14
    1637:	mov    QWORD PTR [rsp+0x8],rsi
    163c:	mov    QWORD PTR [rsp+0x10],r12
    1641:	jmp    1547 <botlish_fn_20+0x3f>
    1646:	mov    eax,0xa
    164b:	mov    rbx,QWORD PTR [rsp+0x20]
    1650:	mov    r12,QWORD PTR [rsp+0x28]
    1655:	mov    r13,QWORD PTR [rsp+0x30]
    165a:	mov    r14,QWORD PTR [rsp+0x38]
    165f:	add    rsp,0x40
    1663:	mov    rsp,rbp
    1666:	pop    rbp
    1667:	ret
    1668:	(bad)
    1669:	add    BYTE PTR [rax],al
    166b:	add    BYTE PTR [rax],al
    166d:	add    BYTE PTR [rax],al
	...

0000000000001670 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    1670:	push   rbp
    1671:	mov    rbp,rsp
    1674:	mov    rsi,QWORD PTR [rdx]
    1677:	mov    r8,QWORD PTR [rdx+0x8]
    167b:	mov    rcx,QWORD PTR [rdx+0x10]
    167f:	mov    rdx,r8
    1682:	call   1687 <botlish_entry_20+0x17>
			1683: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1687:	mov    rsp,rbp
    168a:	pop    rbp
    168b:	ret

000000000000168c <botlish_fn_21: ht_alloc<int>>:
    168c:	push   rbp
    168d:	mov    rbp,rsp
    1690:	sub    rsp,0x50
    1694:	mov    QWORD PTR [rsp+0x20],rbx
    1699:	mov    QWORD PTR [rsp+0x28],r12
    169e:	mov    QWORD PTR [rsp+0x30],r13
    16a3:	mov    QWORD PTR [rsp+0x38],r14
    16a8:	mov    QWORD PTR [rsp+0x40],r15
    16ad:	mov    rbx,rdi
    16b0:	mov    QWORD PTR [rsp+0x8],0x0
    16b9:	mov    QWORD PTR [rsp+0x10],0x0
    16c2:	mov    QWORD PTR [rsp+0x18],0x0
    16cb:	mov    QWORD PTR [rsp],rsi
    16cf:	mov    r13,rsi
    16d2:	mov    rsi,r13
    16d5:	mov    rdi,rbx
    16d8:	call   16dd <botlish_fn_21+0x51>
			16d9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    16dd:	test   rax,rax
    16e0:	je     17fc <botlish_fn_21+0x170>
    16e6:	mov    QWORD PTR [rsp+0x8],rax
    16eb:	mov    r12,rax
    16ee:	mov    edx,0x1
    16f3:	mov    QWORD PTR [rsp+0x10],0x1
    16fc:	mov    rcx,r13
    16ff:	mov    rsi,r12
    1702:	mov    rdi,rbx
    1705:	call   170a <botlish_fn_21+0x7e>
			1706: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    170a:	test   rax,rax
    170d:	je     17fc <botlish_fn_21+0x170>
    1713:	mov    rsi,r13
    1716:	mov    rdi,rbx
    1719:	call   171e <botlish_fn_21+0x92>
			171a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    171e:	test   rax,rax
    1721:	je     17fc <botlish_fn_21+0x170>
    1727:	mov    QWORD PTR [rsp+0x10],rax
    172c:	mov    rsi,r13
    172f:	mov    r14,rax
    1732:	mov    rdi,rbx
    1735:	call   173a <botlish_fn_21+0xae>
			1736: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    173a:	test   rax,rax
    173d:	je     17fc <botlish_fn_21+0x170>
    1743:	mov    QWORD PTR [rsp],rax
    1747:	mov    r13,rax
    174a:	mov    esi,0xb
    174f:	mov    QWORD PTR [rsp+0x18],0xb
    1758:	mov    rdi,rbx
    175b:	call   1760 <botlish_fn_21+0xd4>
			175c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1760:	test   rax,rax
    1763:	mov    r15,rax
    1766:	je     17fc <botlish_fn_21+0x170>
    176c:	mov    edx,0x1
    1771:	mov    rcx,r12
    1774:	mov    rsi,r15
    1777:	mov    rdi,rbx
    177a:	call   177f <botlish_fn_21+0xf3>
			177b: R_X86_64_PLT32	rt_mutarray_set-0x4
    177f:	test   rax,rax
    1782:	je     17fc <botlish_fn_21+0x170>
    1788:	mov    edx,0x3
    178d:	mov    rcx,r14
    1790:	mov    rsi,r15
    1793:	mov    rdi,rbx
    1796:	call   179b <botlish_fn_21+0x10f>
			1797: R_X86_64_PLT32	rt_mutarray_set-0x4
    179b:	test   rax,rax
    179e:	je     17fc <botlish_fn_21+0x170>
    17a4:	mov    edx,0x5
    17a9:	mov    rcx,r13
    17ac:	mov    rsi,r15
    17af:	mov    rdi,rbx
    17b2:	call   17b7 <botlish_fn_21+0x12b>
			17b3: R_X86_64_PLT32	rt_mutarray_set-0x4
    17b7:	test   rax,rax
    17ba:	je     17fc <botlish_fn_21+0x170>
    17c0:	mov    edx,0x7
    17c5:	mov    ecx,0x1
    17ca:	mov    rsi,r15
    17cd:	mov    rdi,rbx
    17d0:	call   17d5 <botlish_fn_21+0x149>
			17d1: R_X86_64_PLT32	rt_mutarray_set-0x4
    17d5:	test   rax,rax
    17d8:	je     17fc <botlish_fn_21+0x170>
    17de:	mov    edx,0x9
    17e3:	mov    ecx,0x1
    17e8:	mov    rdi,rbx
    17eb:	mov    rsi,r15
    17ee:	call   17f3 <botlish_fn_21+0x167>
			17ef: R_X86_64_PLT32	rt_mutarray_set-0x4
    17f3:	test   rax,rax
    17f6:	jne    1821 <botlish_fn_21+0x195>
    17fc:	xor    rax,rax
    17ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1804:	mov    r12,QWORD PTR [rsp+0x28]
    1809:	mov    r13,QWORD PTR [rsp+0x30]
    180e:	mov    r14,QWORD PTR [rsp+0x38]
    1813:	mov    r15,QWORD PTR [rsp+0x40]
    1818:	add    rsp,0x50
    181c:	mov    rsp,rbp
    181f:	pop    rbp
    1820:	ret
    1821:	mov    rax,r15
    1824:	mov    rbx,QWORD PTR [rsp+0x20]
    1829:	mov    r12,QWORD PTR [rsp+0x28]
    182e:	mov    r13,QWORD PTR [rsp+0x30]
    1833:	mov    r14,QWORD PTR [rsp+0x38]
    1838:	mov    r15,QWORD PTR [rsp+0x40]
    183d:	add    rsp,0x50
    1841:	mov    rsp,rbp
    1844:	pop    rbp
    1845:	ret

0000000000001846 <botlish_entry_21: ht_alloc<int>>:
    1846:	push   rbp
    1847:	mov    rbp,rsp
    184a:	mov    rsi,QWORD PTR [rdx]
    184d:	call   1852 <botlish_entry_21+0xc>
			184e: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1852:	mov    rsp,rbp
    1855:	pop    rbp
    1856:	ret

0000000000001857 <botlish_fn_22: ht_new<generic>>:
    1857:	push   rbp
    1858:	mov    rbp,rsp
    185b:	sub    rsp,0x20
    185f:	mov    QWORD PTR [rsp+0x10],r12
    1864:	mov    r12,rdi
    1867:	mov    QWORD PTR [rsp],0x0
    186f:	mov    rdi,r12
    1872:	call   1877 <botlish_fn_22+0x20>
			1873: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1877:	test   rax,rax
    187a:	je     1898 <botlish_fn_22+0x41>
    1880:	mov    QWORD PTR [rsp],rax
    1884:	mov    rsi,rax
    1887:	mov    rdi,r12
    188a:	call   188f <botlish_fn_22+0x38>
			188b: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    188f:	test   rax,rax
    1892:	jne    18a9 <botlish_fn_22+0x52>
    1898:	xor    rax,rax
    189b:	mov    r12,QWORD PTR [rsp+0x10]
    18a0:	add    rsp,0x20
    18a4:	mov    rsp,rbp
    18a7:	pop    rbp
    18a8:	ret
    18a9:	mov    r12,QWORD PTR [rsp+0x10]
    18ae:	add    rsp,0x20
    18b2:	mov    rsp,rbp
    18b5:	pop    rbp
    18b6:	ret

00000000000018b7 <botlish_entry_22: ht_new<generic>>:
    18b7:	push   rbp
    18b8:	mov    rbp,rsp
    18bb:	call   18c0 <botlish_entry_22+0x9>
			18bc: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    18c0:	mov    rsp,rbp
    18c3:	pop    rbp
    18c4:	ret
    18c5:	add    BYTE PTR [rax],al
	...

00000000000018c8 <botlish_fn_23: ht_capacity_for<int, int>>:
    18c8:	push   rbp
    18c9:	mov    rbp,rsp
    18cc:	sub    rsp,0x50
    18d0:	mov    QWORD PTR [rsp+0x20],rbx
    18d5:	mov    QWORD PTR [rsp+0x28],r12
    18da:	mov    QWORD PTR [rsp+0x30],r13
    18df:	mov    QWORD PTR [rsp+0x38],r14
    18e4:	mov    QWORD PTR [rsp+0x40],r15
    18e9:	mov    r13,rdi
    18ec:	mov    QWORD PTR [rsp],rdx
    18f0:	mov    rbx,rsi
    18f3:	or     rbx,0x1
    18f7:	sar    rbx,1
    18fa:	mov    r12,rsi
    18fd:	mov    r14,rdx
    1900:	mov    rax,r12
    1903:	or     rax,0x1
    1907:	mov    QWORD PTR [rsp+0x8],rax
    190c:	mov    QWORD PTR [rsp+0x10],0x7
    1915:	mov    rax,rbx
    1918:	imul   QWORD PTR [rip+0x159]        # 1a78 <botlish_fn_23+0x1b0>
    191f:	seto   cl
    1922:	or     rax,0x1
    1926:	test   cl,cl
    1928:	jne    1936 <botlish_fn_23+0x6e>
    192e:	mov    rsi,rax
    1931:	jmp    194d <botlish_fn_23+0x85>
    1936:	mov    rsi,r12
    1939:	or     rsi,0x1
    193d:	mov    edx,0x7
    1942:	mov    rdi,r13
    1945:	call   194a <botlish_fn_23+0x82>
			1946: R_X86_64_PLT32	rt_int_mul-0x4
    194a:	mov    rsi,rax
    194d:	mov    QWORD PTR [rsp+0x8],rsi
    1952:	mov    r15,rsi
    1955:	mov    QWORD PTR [rsp+0x10],0x5
    195e:	mov    rsi,r14
    1961:	test   rsi,0x1
    1968:	je     1998 <botlish_fn_23+0xd0>
    196e:	mov    rsi,r14
    1971:	mov    rax,rsi
    1974:	sar    rax,1
    1977:	imul   QWORD PTR [rip+0x102]        # 1a80 <botlish_fn_23+0x1b8>
    197e:	seto   cl
    1981:	or     rax,0x1
    1985:	test   cl,cl
    1987:	jne    1998 <botlish_fn_23+0xd0>
    198d:	mov    rdx,rax
    1990:	mov    rsi,r15
    1993:	jmp    19ae <botlish_fn_23+0xe6>
    1998:	mov    edx,0x5
    199d:	mov    rsi,r14
    19a0:	mov    rdi,r13
    19a3:	call   19a8 <botlish_fn_23+0xe0>
			19a4: R_X86_64_PLT32	rt_int_mul-0x4
    19a8:	mov    rdx,rax
    19ab:	mov    rsi,r15
    19ae:	mov    rax,rsi
    19b1:	and    rax,rdx
    19b4:	test   rax,0x1
    19ba:	jne    19dd <botlish_fn_23+0x115>
    19c0:	mov    rdi,r13
    19c3:	call   19c8 <botlish_fn_23+0x100>
			19c4: R_X86_64_PLT32	rt_int_cmp-0x4
    19c8:	mov    ecx,0x2
    19cd:	test   rax,rax
    19d0:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1a78 <botlish_fn_23+0x1b0>
    19d8:	jmp    19ed <botlish_fn_23+0x125>
    19dd:	mov    ecx,0x2
    19e2:	cmp    rsi,rdx
    19e5:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1a78 <botlish_fn_23+0x1b0>
    19ed:	cmp    rcx,0x6
    19f1:	je     1a4d <botlish_fn_23+0x185>
    19f7:	mov    QWORD PTR [rsp+0x8],0x5
    1a00:	mov    rsi,r14
    1a03:	test   rsi,0x1
    1a0a:	je     1a31 <botlish_fn_23+0x169>
    1a10:	mov    rsi,r14
    1a13:	mov    rax,rsi
    1a16:	sar    rax,1
    1a19:	imul   QWORD PTR [rip+0x60]        # 1a80 <botlish_fn_23+0x1b8>
    1a20:	seto   sil
    1a24:	or     rax,0x1
    1a28:	test   sil,sil
    1a2b:	je     1a41 <botlish_fn_23+0x179>
    1a31:	mov    edx,0x5
    1a36:	mov    rsi,r14
    1a39:	mov    rdi,r13
    1a3c:	call   1a41 <botlish_fn_23+0x179>
			1a3d: R_X86_64_PLT32	rt_int_mul-0x4
    1a41:	mov    QWORD PTR [rsp],rax
    1a45:	mov    r14,rax
    1a48:	jmp    1900 <botlish_fn_23+0x38>
    1a4d:	mov    rax,r14
    1a50:	mov    rbx,QWORD PTR [rsp+0x20]
    1a55:	mov    r12,QWORD PTR [rsp+0x28]
    1a5a:	mov    r13,QWORD PTR [rsp+0x30]
    1a5f:	mov    r14,QWORD PTR [rsp+0x38]
    1a64:	mov    r15,QWORD PTR [rsp+0x40]
    1a69:	add    rsp,0x50
    1a6d:	mov    rsp,rbp
    1a70:	pop    rbp
    1a71:	ret
    1a72:	add    BYTE PTR [rax],al
    1a74:	add    BYTE PTR [rax],al
    1a76:	add    BYTE PTR [rax],al
    1a78:	(bad)
    1a79:	add    BYTE PTR [rax],al
    1a7b:	add    BYTE PTR [rax],al
    1a7d:	add    BYTE PTR [rax],al
    1a7f:	add    BYTE PTR [rax+rax*1],al
    1a82:	add    BYTE PTR [rax],al
    1a84:	add    BYTE PTR [rax],al
	...

0000000000001a88 <botlish_entry_23: ht_capacity_for<int, int>>:
    1a88:	push   rbp
    1a89:	mov    rbp,rsp
    1a8c:	mov    rsi,QWORD PTR [rdx]
    1a8f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a93:	call   1a98 <botlish_entry_23+0x10>
			1a94: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    1a98:	mov    rsp,rbp
    1a9b:	pop    rbp
    1a9c:	ret

0000000000001a9d <botlish_fn_24: ht_new_sized<int>>:
    1a9d:	push   rbp
    1a9e:	mov    rbp,rsp
    1aa1:	sub    rsp,0x20
    1aa5:	mov    QWORD PTR [rsp+0x10],r12
    1aaa:	mov    QWORD PTR [rsp+0x18],r13
    1aaf:	mov    r12,rdi
    1ab2:	mov    QWORD PTR [rsp+0x8],0x0
    1abb:	mov    QWORD PTR [rsp],rsi
    1abf:	mov    r13,rsi
    1ac2:	mov    rdi,r12
    1ac5:	call   1aca <botlish_fn_24+0x2d>
			1ac6: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1aca:	test   rax,rax
    1acd:	je     1b07 <botlish_fn_24+0x6a>
    1ad3:	mov    QWORD PTR [rsp+0x8],rax
    1ad8:	mov    rdx,rax
    1adb:	mov    rsi,r13
    1ade:	mov    rdi,r12
    1ae1:	call   1ae6 <botlish_fn_24+0x49>
			1ae2: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    1ae6:	test   rax,rax
    1ae9:	je     1b07 <botlish_fn_24+0x6a>
    1aef:	mov    QWORD PTR [rsp],rax
    1af3:	mov    rsi,rax
    1af6:	mov    rdi,r12
    1af9:	call   1afe <botlish_fn_24+0x61>
			1afa: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1afe:	test   rax,rax
    1b01:	jne    1b1d <botlish_fn_24+0x80>
    1b07:	xor    rax,rax
    1b0a:	mov    r12,QWORD PTR [rsp+0x10]
    1b0f:	mov    r13,QWORD PTR [rsp+0x18]
    1b14:	add    rsp,0x20
    1b18:	mov    rsp,rbp
    1b1b:	pop    rbp
    1b1c:	ret
    1b1d:	mov    r12,QWORD PTR [rsp+0x10]
    1b22:	mov    r13,QWORD PTR [rsp+0x18]
    1b27:	add    rsp,0x20
    1b2b:	mov    rsp,rbp
    1b2e:	pop    rbp
    1b2f:	ret

0000000000001b30 <botlish_entry_24: ht_new_sized<int>>:
    1b30:	push   rbp
    1b31:	mov    rbp,rsp
    1b34:	mov    rsi,QWORD PTR [rdx]
    1b37:	call   1b3c <botlish_entry_24+0xc>
			1b38: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    1b3c:	mov    rsp,rbp
    1b3f:	pop    rbp
    1b40:	ret

0000000000001b41 <botlish_fn_25: ht_controls<mutarray>>:
    1b41:	push   rbp
    1b42:	mov    rbp,rsp
    1b45:	mov    edx,0x1
    1b4a:	call   1b4f <botlish_fn_25+0xe>
			1b4b: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b4f:	test   rax,rax
    1b52:	jne    1b60 <botlish_fn_25+0x1f>
    1b58:	xor    rax,rax
    1b5b:	mov    rsp,rbp
    1b5e:	pop    rbp
    1b5f:	ret
    1b60:	mov    rsp,rbp
    1b63:	pop    rbp
    1b64:	ret

0000000000001b65 <botlish_entry_25: ht_controls<mutarray>>:
    1b65:	push   rbp
    1b66:	mov    rbp,rsp
    1b69:	mov    rsi,QWORD PTR [rdx]
    1b6c:	call   1b71 <botlish_entry_25+0xc>
			1b6d: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    1b71:	mov    rsp,rbp
    1b74:	pop    rbp
    1b75:	ret

0000000000001b76 <botlish_fn_26: ht_controls<generic>>:
    1b76:	push   rbp
    1b77:	mov    rbp,rsp
    1b7a:	xor    r8d,r8d
    1b7d:	test   rsi,0x7
    1b84:	jne    1b94 <botlish_fn_26+0x1e>
    1b8a:	movzx  rax,BYTE PTR [rsi]
    1b8e:	cmp    al,0x8
    1b90:	sete   r8b
    1b94:	test   r8b,r8b
    1b97:	jne    1bb4 <botlish_fn_26+0x3e>
    1b9d:	mov    rax,QWORD PTR [rdi+0x10]
    1ba1:	mov    rcx,QWORD PTR [rax+0x20]
    1ba5:	mov    edx,0x8
    1baa:	call   1baf <botlish_fn_26+0x39>
			1bab: R_X86_64_PLT32	rt_type_error-0x4
    1baf:	jmp    1bc7 <botlish_fn_26+0x51>
    1bb4:	mov    edx,0x1
    1bb9:	call   1bbe <botlish_fn_26+0x48>
			1bba: R_X86_64_PLT32	rt_mutarray_get-0x4
    1bbe:	test   rax,rax
    1bc1:	jne    1bcf <botlish_fn_26+0x59>
    1bc7:	xor    rax,rax
    1bca:	mov    rsp,rbp
    1bcd:	pop    rbp
    1bce:	ret
    1bcf:	mov    rsp,rbp
    1bd2:	pop    rbp
    1bd3:	ret

0000000000001bd4 <botlish_entry_26: ht_controls<generic>>:
    1bd4:	push   rbp
    1bd5:	mov    rbp,rsp
    1bd8:	mov    rsi,QWORD PTR [rdx]
    1bdb:	call   1be0 <botlish_entry_26+0xc>
			1bdc: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    1be0:	mov    rsp,rbp
    1be3:	pop    rbp
    1be4:	ret

0000000000001be5 <botlish_fn_27: ht_keys<mutarray>>:
    1be5:	push   rbp
    1be6:	mov    rbp,rsp
    1be9:	mov    edx,0x3
    1bee:	call   1bf3 <botlish_fn_27+0xe>
			1bef: R_X86_64_PLT32	rt_mutarray_get-0x4
    1bf3:	test   rax,rax
    1bf6:	jne    1c04 <botlish_fn_27+0x1f>
    1bfc:	xor    rax,rax
    1bff:	mov    rsp,rbp
    1c02:	pop    rbp
    1c03:	ret
    1c04:	mov    rsp,rbp
    1c07:	pop    rbp
    1c08:	ret

0000000000001c09 <botlish_entry_27: ht_keys<mutarray>>:
    1c09:	push   rbp
    1c0a:	mov    rbp,rsp
    1c0d:	mov    rsi,QWORD PTR [rdx]
    1c10:	call   1c15 <botlish_entry_27+0xc>
			1c11: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    1c15:	mov    rsp,rbp
    1c18:	pop    rbp
    1c19:	ret

0000000000001c1a <botlish_fn_28: ht_keys<generic>>:
    1c1a:	push   rbp
    1c1b:	mov    rbp,rsp
    1c1e:	xor    r8d,r8d
    1c21:	test   rsi,0x7
    1c28:	jne    1c38 <botlish_fn_28+0x1e>
    1c2e:	movzx  rax,BYTE PTR [rsi]
    1c32:	cmp    al,0x8
    1c34:	sete   r8b
    1c38:	test   r8b,r8b
    1c3b:	jne    1c58 <botlish_fn_28+0x3e>
    1c41:	mov    rax,QWORD PTR [rdi+0x10]
    1c45:	mov    rcx,QWORD PTR [rax+0x20]
    1c49:	mov    edx,0x8
    1c4e:	call   1c53 <botlish_fn_28+0x39>
			1c4f: R_X86_64_PLT32	rt_type_error-0x4
    1c53:	jmp    1c6b <botlish_fn_28+0x51>
    1c58:	mov    edx,0x3
    1c5d:	call   1c62 <botlish_fn_28+0x48>
			1c5e: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c62:	test   rax,rax
    1c65:	jne    1c73 <botlish_fn_28+0x59>
    1c6b:	xor    rax,rax
    1c6e:	mov    rsp,rbp
    1c71:	pop    rbp
    1c72:	ret
    1c73:	mov    rsp,rbp
    1c76:	pop    rbp
    1c77:	ret

0000000000001c78 <botlish_entry_28: ht_keys<generic>>:
    1c78:	push   rbp
    1c79:	mov    rbp,rsp
    1c7c:	mov    rsi,QWORD PTR [rdx]
    1c7f:	call   1c84 <botlish_entry_28+0xc>
			1c80: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    1c84:	mov    rsp,rbp
    1c87:	pop    rbp
    1c88:	ret

0000000000001c89 <botlish_fn_29: ht_values<mutarray>>:
    1c89:	push   rbp
    1c8a:	mov    rbp,rsp
    1c8d:	mov    edx,0x5
    1c92:	call   1c97 <botlish_fn_29+0xe>
			1c93: R_X86_64_PLT32	rt_mutarray_get-0x4
    1c97:	test   rax,rax
    1c9a:	jne    1ca8 <botlish_fn_29+0x1f>
    1ca0:	xor    rax,rax
    1ca3:	mov    rsp,rbp
    1ca6:	pop    rbp
    1ca7:	ret
    1ca8:	mov    rsp,rbp
    1cab:	pop    rbp
    1cac:	ret

0000000000001cad <botlish_entry_29: ht_values<mutarray>>:
    1cad:	push   rbp
    1cae:	mov    rbp,rsp
    1cb1:	mov    rsi,QWORD PTR [rdx]
    1cb4:	call   1cb9 <botlish_entry_29+0xc>
			1cb5: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    1cb9:	mov    rsp,rbp
    1cbc:	pop    rbp
    1cbd:	ret

0000000000001cbe <botlish_fn_30: ht_values<generic>>:
    1cbe:	push   rbp
    1cbf:	mov    rbp,rsp
    1cc2:	xor    r8d,r8d
    1cc5:	test   rsi,0x7
    1ccc:	jne    1cdc <botlish_fn_30+0x1e>
    1cd2:	movzx  rax,BYTE PTR [rsi]
    1cd6:	cmp    al,0x8
    1cd8:	sete   r8b
    1cdc:	test   r8b,r8b
    1cdf:	jne    1cfc <botlish_fn_30+0x3e>
    1ce5:	mov    rax,QWORD PTR [rdi+0x10]
    1ce9:	mov    rcx,QWORD PTR [rax+0x20]
    1ced:	mov    edx,0x8
    1cf2:	call   1cf7 <botlish_fn_30+0x39>
			1cf3: R_X86_64_PLT32	rt_type_error-0x4
    1cf7:	jmp    1d0f <botlish_fn_30+0x51>
    1cfc:	mov    edx,0x5
    1d01:	call   1d06 <botlish_fn_30+0x48>
			1d02: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d06:	test   rax,rax
    1d09:	jne    1d17 <botlish_fn_30+0x59>
    1d0f:	xor    rax,rax
    1d12:	mov    rsp,rbp
    1d15:	pop    rbp
    1d16:	ret
    1d17:	mov    rsp,rbp
    1d1a:	pop    rbp
    1d1b:	ret

0000000000001d1c <botlish_entry_30: ht_values<generic>>:
    1d1c:	push   rbp
    1d1d:	mov    rbp,rsp
    1d20:	mov    rsi,QWORD PTR [rdx]
    1d23:	call   1d28 <botlish_entry_30+0xc>
			1d24: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    1d28:	mov    rsp,rbp
    1d2b:	pop    rbp
    1d2c:	ret

0000000000001d2d <botlish_fn_31: ht_size<mutarray>>:
    1d2d:	push   rbp
    1d2e:	mov    rbp,rsp
    1d31:	mov    edx,0x7
    1d36:	call   1d3b <botlish_fn_31+0xe>
			1d37: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d3b:	test   rax,rax
    1d3e:	jne    1d4c <botlish_fn_31+0x1f>
    1d44:	xor    rax,rax
    1d47:	mov    rsp,rbp
    1d4a:	pop    rbp
    1d4b:	ret
    1d4c:	mov    rsp,rbp
    1d4f:	pop    rbp
    1d50:	ret

0000000000001d51 <botlish_entry_31: ht_size<mutarray>>:
    1d51:	push   rbp
    1d52:	mov    rbp,rsp
    1d55:	mov    rsi,QWORD PTR [rdx]
    1d58:	call   1d5d <botlish_entry_31+0xc>
			1d59: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    1d5d:	mov    rsp,rbp
    1d60:	pop    rbp
    1d61:	ret

0000000000001d62 <botlish_fn_32: ht_size<generic>>:
    1d62:	push   rbp
    1d63:	mov    rbp,rsp
    1d66:	xor    r8d,r8d
    1d69:	test   rsi,0x7
    1d70:	jne    1d80 <botlish_fn_32+0x1e>
    1d76:	movzx  rax,BYTE PTR [rsi]
    1d7a:	cmp    al,0x8
    1d7c:	sete   r8b
    1d80:	test   r8b,r8b
    1d83:	jne    1da0 <botlish_fn_32+0x3e>
    1d89:	mov    rax,QWORD PTR [rdi+0x10]
    1d8d:	mov    rcx,QWORD PTR [rax+0x20]
    1d91:	mov    edx,0x8
    1d96:	call   1d9b <botlish_fn_32+0x39>
			1d97: R_X86_64_PLT32	rt_type_error-0x4
    1d9b:	jmp    1db3 <botlish_fn_32+0x51>
    1da0:	mov    edx,0x7
    1da5:	call   1daa <botlish_fn_32+0x48>
			1da6: R_X86_64_PLT32	rt_mutarray_get-0x4
    1daa:	test   rax,rax
    1dad:	jne    1dbb <botlish_fn_32+0x59>
    1db3:	xor    rax,rax
    1db6:	mov    rsp,rbp
    1db9:	pop    rbp
    1dba:	ret
    1dbb:	mov    rsp,rbp
    1dbe:	pop    rbp
    1dbf:	ret

0000000000001dc0 <botlish_entry_32: ht_size<generic>>:
    1dc0:	push   rbp
    1dc1:	mov    rbp,rsp
    1dc4:	mov    rsi,QWORD PTR [rdx]
    1dc7:	call   1dcc <botlish_entry_32+0xc>
			1dc8: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    1dcc:	mov    rsp,rbp
    1dcf:	pop    rbp
    1dd0:	ret

0000000000001dd1 <botlish_fn_33: ht_tombstones<mutarray>>:
    1dd1:	push   rbp
    1dd2:	mov    rbp,rsp
    1dd5:	mov    edx,0x9
    1dda:	call   1ddf <botlish_fn_33+0xe>
			1ddb: R_X86_64_PLT32	rt_mutarray_get-0x4
    1ddf:	test   rax,rax
    1de2:	jne    1df0 <botlish_fn_33+0x1f>
    1de8:	xor    rax,rax
    1deb:	mov    rsp,rbp
    1dee:	pop    rbp
    1def:	ret
    1df0:	mov    rsp,rbp
    1df3:	pop    rbp
    1df4:	ret

0000000000001df5 <botlish_entry_33: ht_tombstones<mutarray>>:
    1df5:	push   rbp
    1df6:	mov    rbp,rsp
    1df9:	mov    rsi,QWORD PTR [rdx]
    1dfc:	call   1e01 <botlish_entry_33+0xc>
			1dfd: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    1e01:	mov    rsp,rbp
    1e04:	pop    rbp
    1e05:	ret

0000000000001e06 <botlish_fn_34: ht_capacity<mutarray>>:
    1e06:	push   rbp
    1e07:	mov    rbp,rsp
    1e0a:	sub    rsp,0x20
    1e0e:	mov    QWORD PTR [rsp+0x10],rbx
    1e13:	mov    rbx,rdi
    1e16:	mov    QWORD PTR [rsp],rsi
    1e1a:	mov    rdi,rbx
    1e1d:	call   1e22 <botlish_fn_34+0x1c>
			1e1e: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    1e22:	test   rax,rax
    1e25:	je     1e6f <botlish_fn_34+0x69>
    1e2b:	xor    r9d,r9d
    1e2e:	test   rax,0x7
    1e34:	je     1e42 <botlish_fn_34+0x3c>
    1e3a:	mov    rsi,rax
    1e3d:	jmp    1e51 <botlish_fn_34+0x4b>
    1e42:	movzx  rcx,BYTE PTR [rax]
    1e46:	mov    rsi,rax
    1e49:	rex cmp cl,0x8
    1e4d:	sete   r9b
    1e51:	test   r9b,r9b
    1e54:	jne    1e80 <botlish_fn_34+0x7a>
    1e5a:	mov    rdi,rbx
    1e5d:	mov    rax,QWORD PTR [rdi+0x10]
    1e61:	mov    rcx,QWORD PTR [rax+0x28]
    1e65:	mov    edx,0x8
    1e6a:	call   1e6f <botlish_fn_34+0x69>
			1e6b: R_X86_64_PLT32	rt_type_error-0x4
    1e6f:	xor    rax,rax
    1e72:	mov    rbx,QWORD PTR [rsp+0x10]
    1e77:	add    rsp,0x20
    1e7b:	mov    rsp,rbp
    1e7e:	pop    rbp
    1e7f:	ret
    1e80:	mov    rdi,rbx
    1e83:	call   1e88 <botlish_fn_34+0x82>
			1e84: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1e88:	mov    rbx,QWORD PTR [rsp+0x10]
    1e8d:	add    rsp,0x20
    1e91:	mov    rsp,rbp
    1e94:	pop    rbp
    1e95:	ret

0000000000001e96 <botlish_entry_34: ht_capacity<mutarray>>:
    1e96:	push   rbp
    1e97:	mov    rbp,rsp
    1e9a:	mov    rsi,QWORD PTR [rdx]
    1e9d:	call   1ea2 <botlish_entry_34+0xc>
			1e9e: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    1ea2:	mov    rsp,rbp
    1ea5:	pop    rbp
    1ea6:	ret

0000000000001ea7 <botlish_fn_35: ht_capacity<generic>>:
    1ea7:	push   rbp
    1ea8:	mov    rbp,rsp
    1eab:	sub    rsp,0x20
    1eaf:	mov    QWORD PTR [rsp+0x10],rbx
    1eb4:	mov    rbx,rdi
    1eb7:	mov    QWORD PTR [rsp],rsi
    1ebb:	mov    rdi,rbx
    1ebe:	call   1ec3 <botlish_fn_35+0x1c>
			1ebf: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    1ec3:	test   rax,rax
    1ec6:	je     1f10 <botlish_fn_35+0x69>
    1ecc:	xor    r9d,r9d
    1ecf:	test   rax,0x7
    1ed5:	je     1ee3 <botlish_fn_35+0x3c>
    1edb:	mov    rsi,rax
    1ede:	jmp    1ef2 <botlish_fn_35+0x4b>
    1ee3:	movzx  rcx,BYTE PTR [rax]
    1ee7:	mov    rsi,rax
    1eea:	rex cmp cl,0x8
    1eee:	sete   r9b
    1ef2:	test   r9b,r9b
    1ef5:	jne    1f21 <botlish_fn_35+0x7a>
    1efb:	mov    rdi,rbx
    1efe:	mov    rax,QWORD PTR [rdi+0x10]
    1f02:	mov    rcx,QWORD PTR [rax+0x28]
    1f06:	mov    edx,0x8
    1f0b:	call   1f10 <botlish_fn_35+0x69>
			1f0c: R_X86_64_PLT32	rt_type_error-0x4
    1f10:	xor    rax,rax
    1f13:	mov    rbx,QWORD PTR [rsp+0x10]
    1f18:	add    rsp,0x20
    1f1c:	mov    rsp,rbp
    1f1f:	pop    rbp
    1f20:	ret
    1f21:	mov    rdi,rbx
    1f24:	call   1f29 <botlish_fn_35+0x82>
			1f25: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1f29:	mov    rbx,QWORD PTR [rsp+0x10]
    1f2e:	add    rsp,0x20
    1f32:	mov    rsp,rbp
    1f35:	pop    rbp
    1f36:	ret

0000000000001f37 <botlish_entry_35: ht_capacity<generic>>:
    1f37:	push   rbp
    1f38:	mov    rbp,rsp
    1f3b:	mov    rsi,QWORD PTR [rdx]
    1f3e:	call   1f43 <botlish_entry_35+0xc>
			1f3f: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    1f43:	mov    rsp,rbp
    1f46:	pop    rbp
    1f47:	ret

0000000000001f48 <botlish_fn_36: ht_probe_start<mutarray, any>>:
    1f48:	push   rbp
    1f49:	mov    rbp,rsp
    1f4c:	sub    rsp,0x30
    1f50:	mov    QWORD PTR [rsp+0x10],r12
    1f55:	mov    QWORD PTR [rsp+0x18],r13
    1f5a:	mov    QWORD PTR [rsp+0x20],r14
    1f5f:	mov    r12,rdi
    1f62:	mov    QWORD PTR [rsp],rsi
    1f66:	mov    r14,rsi
    1f69:	mov    rsi,rdx
    1f6c:	mov    rdi,r12
    1f6f:	call   1f74 <botlish_fn_36+0x2c>
			1f70: R_X86_64_PLT32	rt_hash-0x4
    1f74:	test   rax,rax
    1f77:	je     1fb0 <botlish_fn_36+0x68>
    1f7d:	mov    QWORD PTR [rsp+0x8],rax
    1f82:	mov    rsi,r14
    1f85:	mov    r13,rax
    1f88:	mov    rdi,r12
    1f8b:	call   1f90 <botlish_fn_36+0x48>
			1f8c: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    1f90:	test   rax,rax
    1f93:	mov    rdx,rax
    1f96:	je     1fb0 <botlish_fn_36+0x68>
    1f9c:	mov    rsi,r13
    1f9f:	mov    rdi,r12
    1fa2:	call   1fa7 <botlish_fn_36+0x5f>
			1fa3: R_X86_64_PLT32	rt_int_mod-0x4
    1fa7:	test   rax,rax
    1faa:	jne    1fcb <botlish_fn_36+0x83>
    1fb0:	xor    rax,rax
    1fb3:	mov    r12,QWORD PTR [rsp+0x10]
    1fb8:	mov    r13,QWORD PTR [rsp+0x18]
    1fbd:	mov    r14,QWORD PTR [rsp+0x20]
    1fc2:	add    rsp,0x30
    1fc6:	mov    rsp,rbp
    1fc9:	pop    rbp
    1fca:	ret
    1fcb:	mov    r12,QWORD PTR [rsp+0x10]
    1fd0:	mov    r13,QWORD PTR [rsp+0x18]
    1fd5:	mov    r14,QWORD PTR [rsp+0x20]
    1fda:	add    rsp,0x30
    1fde:	mov    rsp,rbp
    1fe1:	pop    rbp
    1fe2:	ret

0000000000001fe3 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    1fe3:	push   rbp
    1fe4:	mov    rbp,rsp
    1fe7:	mov    rsi,QWORD PTR [rdx]
    1fea:	mov    rdx,QWORD PTR [rdx+0x8]
    1fee:	call   1ff3 <botlish_entry_36+0x10>
			1fef: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    1ff3:	mov    rsp,rbp
    1ff6:	pop    rbp
    1ff7:	ret

0000000000001ff8 <botlish_fn_37: ht_probe_start<any, str>>:
    1ff8:	push   rbp
    1ff9:	mov    rbp,rsp
    1ffc:	sub    rsp,0x30
    2000:	mov    QWORD PTR [rsp+0x10],r12
    2005:	mov    QWORD PTR [rsp+0x18],r13
    200a:	mov    QWORD PTR [rsp+0x20],r14
    200f:	mov    r12,rdi
    2012:	mov    QWORD PTR [rsp],rsi
    2016:	mov    r14,rsi
    2019:	mov    rsi,rdx
    201c:	mov    rdi,r12
    201f:	call   2024 <botlish_fn_37+0x2c>
			2020: R_X86_64_PLT32	rt_hash-0x4
    2024:	test   rax,rax
    2027:	je     2060 <botlish_fn_37+0x68>
    202d:	mov    QWORD PTR [rsp+0x8],rax
    2032:	mov    rsi,r14
    2035:	mov    r13,rax
    2038:	mov    rdi,r12
    203b:	call   2040 <botlish_fn_37+0x48>
			203c: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2040:	test   rax,rax
    2043:	mov    rdx,rax
    2046:	je     2060 <botlish_fn_37+0x68>
    204c:	mov    rsi,r13
    204f:	mov    rdi,r12
    2052:	call   2057 <botlish_fn_37+0x5f>
			2053: R_X86_64_PLT32	rt_int_mod-0x4
    2057:	test   rax,rax
    205a:	jne    207b <botlish_fn_37+0x83>
    2060:	xor    rax,rax
    2063:	mov    r12,QWORD PTR [rsp+0x10]
    2068:	mov    r13,QWORD PTR [rsp+0x18]
    206d:	mov    r14,QWORD PTR [rsp+0x20]
    2072:	add    rsp,0x30
    2076:	mov    rsp,rbp
    2079:	pop    rbp
    207a:	ret
    207b:	mov    r12,QWORD PTR [rsp+0x10]
    2080:	mov    r13,QWORD PTR [rsp+0x18]
    2085:	mov    r14,QWORD PTR [rsp+0x20]
    208a:	add    rsp,0x30
    208e:	mov    rsp,rbp
    2091:	pop    rbp
    2092:	ret

0000000000002093 <botlish_entry_37: ht_probe_start<any, str>>:
    2093:	push   rbp
    2094:	mov    rbp,rsp
    2097:	mov    rsi,QWORD PTR [rdx]
    209a:	mov    rdx,QWORD PTR [rdx+0x8]
    209e:	call   20a3 <botlish_entry_37+0x10>
			209f: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    20a3:	mov    rsp,rbp
    20a6:	pop    rbp
    20a7:	ret

00000000000020a8 <botlish_fn_38: ht_probe_next<mutarray, int>>:
    20a8:	push   rbp
    20a9:	mov    rbp,rsp
    20ac:	sub    rsp,0x30
    20b0:	mov    QWORD PTR [rsp+0x20],rbx
    20b5:	mov    QWORD PTR [rsp+0x28],r13
    20ba:	mov    r13,rdi
    20bd:	mov    QWORD PTR [rsp],rsi
    20c1:	mov    rbx,rsi
    20c4:	mov    QWORD PTR [rsp+0x8],rdx
    20c9:	mov    QWORD PTR [rsp+0x10],0x3
    20d2:	test   rdx,0x1
    20d9:	jne    20e7 <botlish_fn_38+0x3f>
    20df:	mov    rcx,rdx
    20e2:	jmp    20fc <botlish_fn_38+0x54>
    20e7:	mov    rsi,rdx
    20ea:	add    rsi,0x2
    20ee:	mov    rcx,rdx
    20f1:	seto   al
    20f4:	test   al,al
    20f6:	je     210f <botlish_fn_38+0x67>
    20fc:	mov    edx,0x3
    2101:	mov    rsi,rcx
    2104:	mov    rdi,r13
    2107:	call   210c <botlish_fn_38+0x64>
			2108: R_X86_64_PLT32	rt_int_add-0x4
    210c:	mov    rsi,rax
    210f:	mov    QWORD PTR [rsp+0x8],rsi
    2114:	mov    rax,rbx
    2117:	mov    rbx,rsi
    211a:	mov    rsi,rax
    211d:	mov    rdi,r13
    2120:	call   2125 <botlish_fn_38+0x7d>
			2121: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2125:	test   rax,rax
    2128:	mov    rdx,rax
    212b:	je     2145 <botlish_fn_38+0x9d>
    2131:	mov    rsi,rbx
    2134:	mov    rdi,r13
    2137:	call   213c <botlish_fn_38+0x94>
			2138: R_X86_64_PLT32	rt_int_mod-0x4
    213c:	test   rax,rax
    213f:	jne    215b <botlish_fn_38+0xb3>
    2145:	xor    rax,rax
    2148:	mov    rbx,QWORD PTR [rsp+0x20]
    214d:	mov    r13,QWORD PTR [rsp+0x28]
    2152:	add    rsp,0x30
    2156:	mov    rsp,rbp
    2159:	pop    rbp
    215a:	ret
    215b:	mov    rbx,QWORD PTR [rsp+0x20]
    2160:	mov    r13,QWORD PTR [rsp+0x28]
    2165:	add    rsp,0x30
    2169:	mov    rsp,rbp
    216c:	pop    rbp
    216d:	ret

000000000000216e <botlish_entry_38: ht_probe_next<mutarray, int>>:
    216e:	push   rbp
    216f:	mov    rbp,rsp
    2172:	mov    rsi,QWORD PTR [rdx]
    2175:	mov    rdx,QWORD PTR [rdx+0x8]
    2179:	call   217e <botlish_entry_38+0x10>
			217a: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    217e:	mov    rsp,rbp
    2181:	pop    rbp
    2182:	ret

0000000000002183 <botlish_fn_39: ht_probe_next<any, int>>:
    2183:	push   rbp
    2184:	mov    rbp,rsp
    2187:	sub    rsp,0x30
    218b:	mov    QWORD PTR [rsp+0x20],rbx
    2190:	mov    QWORD PTR [rsp+0x28],r13
    2195:	mov    r13,rdi
    2198:	mov    QWORD PTR [rsp],rsi
    219c:	mov    rbx,rsi
    219f:	mov    QWORD PTR [rsp+0x8],rdx
    21a4:	mov    QWORD PTR [rsp+0x10],0x3
    21ad:	test   rdx,0x1
    21b4:	jne    21c2 <botlish_fn_39+0x3f>
    21ba:	mov    rcx,rdx
    21bd:	jmp    21d7 <botlish_fn_39+0x54>
    21c2:	mov    rsi,rdx
    21c5:	add    rsi,0x2
    21c9:	mov    rcx,rdx
    21cc:	seto   al
    21cf:	test   al,al
    21d1:	je     21ea <botlish_fn_39+0x67>
    21d7:	mov    edx,0x3
    21dc:	mov    rsi,rcx
    21df:	mov    rdi,r13
    21e2:	call   21e7 <botlish_fn_39+0x64>
			21e3: R_X86_64_PLT32	rt_int_add-0x4
    21e7:	mov    rsi,rax
    21ea:	mov    QWORD PTR [rsp+0x8],rsi
    21ef:	mov    rax,rbx
    21f2:	mov    rbx,rsi
    21f5:	mov    rsi,rax
    21f8:	mov    rdi,r13
    21fb:	call   2200 <botlish_fn_39+0x7d>
			21fc: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2200:	test   rax,rax
    2203:	mov    rdx,rax
    2206:	je     2220 <botlish_fn_39+0x9d>
    220c:	mov    rsi,rbx
    220f:	mov    rdi,r13
    2212:	call   2217 <botlish_fn_39+0x94>
			2213: R_X86_64_PLT32	rt_int_mod-0x4
    2217:	test   rax,rax
    221a:	jne    2236 <botlish_fn_39+0xb3>
    2220:	xor    rax,rax
    2223:	mov    rbx,QWORD PTR [rsp+0x20]
    2228:	mov    r13,QWORD PTR [rsp+0x28]
    222d:	add    rsp,0x30
    2231:	mov    rsp,rbp
    2234:	pop    rbp
    2235:	ret
    2236:	mov    rbx,QWORD PTR [rsp+0x20]
    223b:	mov    r13,QWORD PTR [rsp+0x28]
    2240:	add    rsp,0x30
    2244:	mov    rsp,rbp
    2247:	pop    rbp
    2248:	ret

0000000000002249 <botlish_entry_39: ht_probe_next<any, int>>:
    2249:	push   rbp
    224a:	mov    rbp,rsp
    224d:	mov    rsi,QWORD PTR [rdx]
    2250:	mov    rdx,QWORD PTR [rdx+0x8]
    2254:	call   2259 <botlish_entry_39+0x10>
			2255: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    2259:	mov    rsp,rbp
    225c:	pop    rbp
    225d:	ret
	...

0000000000002260 <botlish_fn_40: ht_find_get<any, str, int>>:
    2260:	push   rbp
    2261:	mov    rbp,rsp
    2264:	sub    rsp,0x60
    2268:	mov    QWORD PTR [rsp+0x30],rbx
    226d:	mov    QWORD PTR [rsp+0x38],r12
    2272:	mov    QWORD PTR [rsp+0x40],r13
    2277:	mov    QWORD PTR [rsp+0x48],r14
    227c:	mov    QWORD PTR [rsp+0x50],r15
    2281:	mov    r14,rdi
    2284:	mov    QWORD PTR [rsp+0x18],0x0
    228d:	mov    QWORD PTR [rsp],rsi
    2291:	mov    QWORD PTR [rsp+0x8],rdx
    2296:	mov    r15,rdx
    2299:	mov    QWORD PTR [rsp+0x10],rcx
    229e:	mov    r13,rsi
    22a1:	mov    QWORD PTR [rsp+0x20],rcx
    22a6:	mov    rsi,r13
    22a9:	mov    rdi,r14
    22ac:	call   22b1 <botlish_fn_40+0x51>
			22ad: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    22b1:	test   rax,rax
    22b4:	je     24d7 <botlish_fn_40+0x277>
    22ba:	xor    ecx,ecx
    22bc:	test   rax,0x7
    22c2:	je     22d0 <botlish_fn_40+0x70>
    22c8:	mov    r8,rax
    22cb:	jmp    22de <botlish_fn_40+0x7e>
    22d0:	movzx  rcx,BYTE PTR [rax]
    22d4:	mov    r8,rax
    22d7:	rex cmp cl,0x8
    22db:	sete   cl
    22de:	test   cl,cl
    22e0:	jne    2303 <botlish_fn_40+0xa3>
    22e6:	mov    rdi,r14
    22e9:	mov    rsi,QWORD PTR [rdi+0x10]
    22ed:	mov    rcx,QWORD PTR [rsi+0x20]
    22f1:	mov    edx,0x8
    22f6:	mov    rsi,r8
    22f9:	call   22fe <botlish_fn_40+0x9e>
			22fa: R_X86_64_PLT32	rt_type_error-0x4
    22fe:	jmp    24d7 <botlish_fn_40+0x277>
    2303:	mov    rsi,r8
    2306:	mov    rdx,QWORD PTR [rsp+0x20]
    230b:	mov    rdi,r14
    230e:	call   2313 <botlish_fn_40+0xb3>
			230f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2313:	mov    rcx,rax
    2316:	mov    r12,rax
    2319:	test   rax,rcx
    231c:	je     24d7 <botlish_fn_40+0x277>
    2322:	mov    rax,r12
    2325:	mov    QWORD PTR [rsp+0x18],rax
    232a:	mov    rdi,r14
    232d:	call   2332 <botlish_fn_40+0xd2>
			232e: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    2332:	test   rax,rax
    2335:	je     24d7 <botlish_fn_40+0x277>
    233b:	mov    rcx,r12
    233e:	and    rcx,rax
    2341:	mov    rdx,rax
    2344:	test   rcx,0x1
    234b:	jne    236a <botlish_fn_40+0x10a>
    2351:	mov    rsi,r12
    2354:	mov    rdi,r14
    2357:	call   235c <botlish_fn_40+0xfc>
			2358: R_X86_64_PLT32	rt_value_eq-0x4
    235c:	test   rax,rax
    235f:	je     24d7 <botlish_fn_40+0x277>
    2365:	jmp    237a <botlish_fn_40+0x11a>
    236a:	mov    eax,0x2
    236f:	cmp    r12,rdx
    2372:	cmove  rax,QWORD PTR [rip+0x1ee]        # 2568 <botlish_fn_40+0x308>
    237a:	mov    ebx,0x6
    237f:	cmp    rax,0x6
    2383:	je     253e <botlish_fn_40+0x2de>
    2389:	mov    rdi,r14
    238c:	call   2391 <botlish_fn_40+0x131>
			238d: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2391:	test   rax,rax
    2394:	je     24d7 <botlish_fn_40+0x277>
    239a:	mov    rcx,r12
    239d:	and    rcx,rax
    23a0:	mov    rdx,rax
    23a3:	test   rcx,0x1
    23aa:	jne    23c9 <botlish_fn_40+0x169>
    23b0:	mov    rsi,r12
    23b3:	mov    rdi,r14
    23b6:	call   23bb <botlish_fn_40+0x15b>
			23b7: R_X86_64_PLT32	rt_value_eq-0x4
    23bb:	test   rax,rax
    23be:	je     24d7 <botlish_fn_40+0x277>
    23c4:	jmp    23dc <botlish_fn_40+0x17c>
    23c9:	mov    rsi,r12
    23cc:	mov    eax,0x2
    23d1:	cmp    rsi,rdx
    23d4:	cmove  rax,QWORD PTR [rip+0x18c]        # 2568 <botlish_fn_40+0x308>
    23dc:	cmp    rax,0x6
    23e0:	je     23f3 <botlish_fn_40+0x193>
    23e6:	mov    ebx,0x2
    23eb:	mov    r12,r15
    23ee:	jmp    24b4 <botlish_fn_40+0x254>
    23f3:	mov    rsi,r13
    23f6:	mov    rdi,r14
    23f9:	call   23fe <botlish_fn_40+0x19e>
			23fa: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    23fe:	test   rax,rax
    2401:	je     24d7 <botlish_fn_40+0x277>
    2407:	xor    ecx,ecx
    2409:	test   rax,0x7
    240f:	je     241d <botlish_fn_40+0x1bd>
    2415:	mov    rsi,rax
    2418:	jmp    242b <botlish_fn_40+0x1cb>
    241d:	movzx  rcx,BYTE PTR [rax]
    2421:	mov    rsi,rax
    2424:	rex cmp cl,0x8
    2428:	sete   cl
    242b:	test   cl,cl
    242d:	jne    244d <botlish_fn_40+0x1ed>
    2433:	mov    rdi,r14
    2436:	mov    rax,QWORD PTR [rdi+0x10]
    243a:	mov    rcx,QWORD PTR [rax+0x20]
    243e:	mov    edx,0x8
    2443:	call   2448 <botlish_fn_40+0x1e8>
			2444: R_X86_64_PLT32	rt_type_error-0x4
    2448:	jmp    24d7 <botlish_fn_40+0x277>
    244d:	mov    rdx,QWORD PTR [rsp+0x20]
    2452:	mov    rdi,r14
    2455:	call   245a <botlish_fn_40+0x1fa>
			2456: R_X86_64_PLT32	rt_mutarray_get-0x4
    245a:	test   rax,rax
    245d:	je     24d7 <botlish_fn_40+0x277>
    2463:	mov    r12,r15
    2466:	mov    rcx,rax
    2469:	and    rcx,r12
    246c:	mov    rsi,rax
    246f:	test   rcx,0x1
    2476:	jne    2495 <botlish_fn_40+0x235>
    247c:	mov    rdx,r12
    247f:	mov    rdi,r14
    2482:	call   2487 <botlish_fn_40+0x227>
			2483: R_X86_64_PLT32	rt_value_eq-0x4
    2487:	test   rax,rax
    248a:	je     24d7 <botlish_fn_40+0x277>
    2490:	jmp    24a5 <botlish_fn_40+0x245>
    2495:	mov    eax,0x2
    249a:	cmp    rsi,r12
    249d:	cmove  rax,QWORD PTR [rip+0xc3]        # 2568 <botlish_fn_40+0x308>
    24a5:	cmp    rax,0x6
    24a9:	je     24b4 <botlish_fn_40+0x254>
    24af:	mov    ebx,0x2
    24b4:	cmp    rbx,0x6
    24b8:	je     2517 <botlish_fn_40+0x2b7>
    24be:	mov    rdx,QWORD PTR [rsp+0x20]
    24c3:	mov    rsi,r13
    24c6:	mov    rdi,r14
    24c9:	call   24ce <botlish_fn_40+0x26e>
			24ca: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    24ce:	test   rax,rax
    24d1:	jne    24fc <botlish_fn_40+0x29c>
    24d7:	xor    rax,rax
    24da:	mov    rbx,QWORD PTR [rsp+0x30]
    24df:	mov    r12,QWORD PTR [rsp+0x38]
    24e4:	mov    r13,QWORD PTR [rsp+0x40]
    24e9:	mov    r14,QWORD PTR [rsp+0x48]
    24ee:	mov    r15,QWORD PTR [rsp+0x50]
    24f3:	add    rsp,0x60
    24f7:	mov    rsp,rbp
    24fa:	pop    rbp
    24fb:	ret
    24fc:	mov    QWORD PTR [rsp],r13
    2500:	mov    QWORD PTR [rsp+0x8],r12
    2505:	mov    QWORD PTR [rsp+0x10],rax
    250a:	mov    r15,r12
    250d:	mov    QWORD PTR [rsp+0x20],rax
    2512:	jmp    22a6 <botlish_fn_40+0x46>
    2517:	mov    rax,QWORD PTR [rsp+0x20]
    251c:	mov    rbx,QWORD PTR [rsp+0x30]
    2521:	mov    r12,QWORD PTR [rsp+0x38]
    2526:	mov    r13,QWORD PTR [rsp+0x40]
    252b:	mov    r14,QWORD PTR [rsp+0x48]
    2530:	mov    r15,QWORD PTR [rsp+0x50]
    2535:	add    rsp,0x60
    2539:	mov    rsp,rbp
    253c:	pop    rbp
    253d:	ret
    253e:	mov    rax,0xffffffffffffffff
    2545:	mov    rbx,QWORD PTR [rsp+0x30]
    254a:	mov    r12,QWORD PTR [rsp+0x38]
    254f:	mov    r13,QWORD PTR [rsp+0x40]
    2554:	mov    r14,QWORD PTR [rsp+0x48]
    2559:	mov    r15,QWORD PTR [rsp+0x50]
    255e:	add    rsp,0x60
    2562:	mov    rsp,rbp
    2565:	pop    rbp
    2566:	ret
    2567:	add    BYTE PTR [rsi],al
    2569:	add    BYTE PTR [rax],al
    256b:	add    BYTE PTR [rax],al
    256d:	add    BYTE PTR [rax],al
	...

0000000000002570 <botlish_entry_40: ht_find_get<any, str, int>>:
    2570:	push   rbp
    2571:	mov    rbp,rsp
    2574:	mov    rsi,QWORD PTR [rdx]
    2577:	mov    r8,QWORD PTR [rdx+0x8]
    257b:	mov    rcx,QWORD PTR [rdx+0x10]
    257f:	mov    rdx,r8
    2582:	call   2587 <botlish_entry_40+0x17>
			2583: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    2587:	mov    rsp,rbp
    258a:	pop    rbp
    258b:	ret
    258c:	add    BYTE PTR [rax],al
	...

0000000000002590 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    2590:	push   rbp
    2591:	mov    rbp,rsp
    2594:	sub    rsp,0x70
    2598:	mov    QWORD PTR [rsp+0x40],rbx
    259d:	mov    QWORD PTR [rsp+0x48],r12
    25a2:	mov    QWORD PTR [rsp+0x50],r13
    25a7:	mov    QWORD PTR [rsp+0x58],r14
    25ac:	mov    QWORD PTR [rsp+0x60],r15
    25b1:	mov    r15,rdi
    25b4:	mov    QWORD PTR [rsp+0x20],0x0
    25bd:	mov    QWORD PTR [rsp],rsi
    25c1:	mov    QWORD PTR [rsp+0x8],rdx
    25c6:	mov    r13,rdx
    25c9:	mov    QWORD PTR [rsp+0x10],rcx
    25ce:	mov    QWORD PTR [rsp+0x18],r8
    25d3:	mov    rbx,rsi
    25d6:	mov    QWORD PTR [rsp+0x28],rcx
    25db:	mov    QWORD PTR [rsp+0x30],r8
    25e0:	mov    rsi,rbx
    25e3:	mov    rdi,r15
    25e6:	call   25eb <botlish_fn_41+0x5b>
			25e7: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    25eb:	test   rax,rax
    25ee:	je     2928 <botlish_fn_41+0x398>
    25f4:	xor    ecx,ecx
    25f6:	test   rax,0x7
    25fc:	je     260a <botlish_fn_41+0x7a>
    2602:	mov    rsi,rax
    2605:	jmp    2618 <botlish_fn_41+0x88>
    260a:	movzx  rcx,BYTE PTR [rax]
    260e:	mov    rsi,rax
    2611:	rex cmp cl,0x8
    2615:	sete   cl
    2618:	test   cl,cl
    261a:	jne    263a <botlish_fn_41+0xaa>
    2620:	mov    rdi,r15
    2623:	mov    rax,QWORD PTR [rdi+0x10]
    2627:	mov    rcx,QWORD PTR [rax+0x20]
    262b:	mov    edx,0x8
    2630:	call   2635 <botlish_fn_41+0xa5>
			2631: R_X86_64_PLT32	rt_type_error-0x4
    2635:	jmp    2928 <botlish_fn_41+0x398>
    263a:	mov    rdx,QWORD PTR [rsp+0x28]
    263f:	mov    rdi,r15
    2642:	call   2647 <botlish_fn_41+0xb7>
			2643: R_X86_64_PLT32	rt_mutarray_get-0x4
    2647:	mov    r10,rax
    264a:	mov    r14,rax
    264d:	test   rax,r10
    2650:	je     2928 <botlish_fn_41+0x398>
    2656:	mov    rax,r14
    2659:	mov    QWORD PTR [rsp+0x20],rax
    265e:	mov    rdi,r15
    2661:	call   2666 <botlish_fn_41+0xd6>
			2662: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    2666:	test   rax,rax
    2669:	je     2928 <botlish_fn_41+0x398>
    266f:	mov    rcx,r14
    2672:	and    rcx,rax
    2675:	mov    rdx,rax
    2678:	test   rcx,0x1
    267f:	jne    269e <botlish_fn_41+0x10e>
    2685:	mov    rsi,r14
    2688:	mov    rdi,r15
    268b:	call   2690 <botlish_fn_41+0x100>
			268c: R_X86_64_PLT32	rt_value_eq-0x4
    2690:	test   rax,rax
    2693:	je     2928 <botlish_fn_41+0x398>
    2699:	jmp    26b1 <botlish_fn_41+0x121>
    269e:	mov    eax,0x2
    26a3:	mov    rcx,r14
    26a6:	cmp    rcx,rdx
    26a9:	cmove  rax,QWORD PTR [rip+0x39f]        # 2a50 <botlish_fn_41+0x4c0>
    26b1:	mov    r12d,0x6
    26b7:	cmp    rax,0x6
    26bb:	je     29a0 <botlish_fn_41+0x410>
    26c1:	mov    rdi,r15
    26c4:	call   26c9 <botlish_fn_41+0x139>
			26c5: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    26c9:	test   rax,rax
    26cc:	je     2928 <botlish_fn_41+0x398>
    26d2:	mov    rcx,r14
    26d5:	and    rcx,rax
    26d8:	mov    rdx,rax
    26db:	test   rcx,0x1
    26e2:	jne    2701 <botlish_fn_41+0x171>
    26e8:	mov    rsi,r14
    26eb:	mov    rdi,r15
    26ee:	call   26f3 <botlish_fn_41+0x163>
			26ef: R_X86_64_PLT32	rt_value_eq-0x4
    26f3:	test   rax,rax
    26f6:	je     2928 <botlish_fn_41+0x398>
    26fc:	jmp    2714 <botlish_fn_41+0x184>
    2701:	mov    eax,0x2
    2706:	mov    rcx,r14
    2709:	cmp    rcx,rdx
    270c:	cmove  rax,QWORD PTR [rip+0x33c]        # 2a50 <botlish_fn_41+0x4c0>
    2714:	cmp    rax,0x6
    2718:	je     2728 <botlish_fn_41+0x198>
    271e:	mov    eax,0x2
    2723:	jmp    27ee <botlish_fn_41+0x25e>
    2728:	mov    rsi,rbx
    272b:	mov    rdi,r15
    272e:	call   2733 <botlish_fn_41+0x1a3>
			272f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    2733:	test   rax,rax
    2736:	je     2928 <botlish_fn_41+0x398>
    273c:	xor    ecx,ecx
    273e:	test   rax,0x7
    2744:	je     2752 <botlish_fn_41+0x1c2>
    274a:	mov    rsi,rax
    274d:	jmp    2760 <botlish_fn_41+0x1d0>
    2752:	movzx  r8,BYTE PTR [rax]
    2756:	mov    rsi,rax
    2759:	cmp    r8b,0x8
    275d:	sete   cl
    2760:	test   cl,cl
    2762:	jne    2782 <botlish_fn_41+0x1f2>
    2768:	mov    rdi,r15
    276b:	mov    rax,QWORD PTR [rdi+0x10]
    276f:	mov    rcx,QWORD PTR [rax+0x20]
    2773:	mov    edx,0x8
    2778:	call   277d <botlish_fn_41+0x1ed>
			2779: R_X86_64_PLT32	rt_type_error-0x4
    277d:	jmp    2928 <botlish_fn_41+0x398>
    2782:	mov    rdx,QWORD PTR [rsp+0x28]
    2787:	mov    rdi,r15
    278a:	call   278f <botlish_fn_41+0x1ff>
			278b: R_X86_64_PLT32	rt_mutarray_get-0x4
    278f:	test   rax,rax
    2792:	je     2928 <botlish_fn_41+0x398>
    2798:	mov    rcx,rax
    279b:	and    rcx,r13
    279e:	mov    rsi,rax
    27a1:	test   rcx,0x1
    27a8:	jne    27c7 <botlish_fn_41+0x237>
    27ae:	mov    rdx,r13
    27b1:	mov    rdi,r15
    27b4:	call   27b9 <botlish_fn_41+0x229>
			27b5: R_X86_64_PLT32	rt_value_eq-0x4
    27b9:	test   rax,rax
    27bc:	je     2928 <botlish_fn_41+0x398>
    27c2:	jmp    27d7 <botlish_fn_41+0x247>
    27c7:	mov    eax,0x2
    27cc:	cmp    rsi,r13
    27cf:	cmove  rax,QWORD PTR [rip+0x279]        # 2a50 <botlish_fn_41+0x4c0>
    27d7:	cmp    rax,0x6
    27db:	je     27eb <botlish_fn_41+0x25b>
    27e1:	mov    eax,0x2
    27e6:	jmp    27ee <botlish_fn_41+0x25e>
    27eb:	mov    rax,r12
    27ee:	cmp    rax,0x6
    27f2:	je     2979 <botlish_fn_41+0x3e9>
    27f8:	mov    rdi,r15
    27fb:	call   2800 <botlish_fn_41+0x270>
			27fc: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    2800:	test   rax,rax
    2803:	je     2928 <botlish_fn_41+0x398>
    2809:	mov    rcx,r14
    280c:	mov    rdx,rcx
    280f:	and    rdx,rax
    2812:	mov    rsi,rax
    2815:	test   rdx,0x1
    281c:	jne    283e <botlish_fn_41+0x2ae>
    2822:	mov    rdx,rsi
    2825:	mov    rsi,r14
    2828:	mov    rdi,r15
    282b:	call   2830 <botlish_fn_41+0x2a0>
			282c: R_X86_64_PLT32	rt_value_eq-0x4
    2830:	test   rax,rax
    2833:	je     2928 <botlish_fn_41+0x398>
    2839:	jmp    2854 <botlish_fn_41+0x2c4>
    283e:	mov    rdx,rsi
    2841:	mov    rsi,r14
    2844:	mov    eax,0x2
    2849:	cmp    rsi,rdx
    284c:	cmove  rax,QWORD PTR [rip+0x1fc]        # 2a50 <botlish_fn_41+0x4c0>
    2854:	cmp    rax,0x6
    2858:	je     2869 <botlish_fn_41+0x2d9>
    285e:	mov    r12d,0x2
    2864:	jmp    28ca <botlish_fn_41+0x33a>
    2869:	mov    r14,QWORD PTR [rsp+0x30]
    286e:	test   r14,0x1
    2875:	jne    28a5 <botlish_fn_41+0x315>
    287b:	mov    edx,0x1
    2880:	mov    rsi,r14
    2883:	mov    rdi,r15
    2886:	call   288b <botlish_fn_41+0x2fb>
			2887: R_X86_64_PLT32	rt_int_cmp-0x4
    288b:	mov    ecx,0x2
    2890:	test   rax,rax
    2893:	cmovl  rcx,QWORD PTR [rip+0x1b5]        # 2a50 <botlish_fn_41+0x4c0>
    289b:	mov    QWORD PTR [rsp+0x30],r14
    28a0:	jmp    28ba <botlish_fn_41+0x32a>
    28a5:	mov    ecx,0x2
    28aa:	test   r14,r14
    28ad:	mov    QWORD PTR [rsp+0x30],r14
    28b2:	cmovle rcx,QWORD PTR [rip+0x196]        # 2a50 <botlish_fn_41+0x4c0>
    28ba:	cmp    rcx,0x6
    28be:	je     28ca <botlish_fn_41+0x33a>
    28c4:	mov    r12d,0x2
    28ca:	cmp    r12,0x6
    28ce:	je     290f <botlish_fn_41+0x37f>
    28d4:	mov    rdx,QWORD PTR [rsp+0x28]
    28d9:	mov    rsi,rbx
    28dc:	mov    rdi,r15
    28df:	call   28e4 <botlish_fn_41+0x354>
			28e0: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    28e4:	test   rax,rax
    28e7:	je     2928 <botlish_fn_41+0x398>
    28ed:	mov    QWORD PTR [rsp],rbx
    28f1:	mov    QWORD PTR [rsp+0x8],r13
    28f6:	mov    QWORD PTR [rsp+0x10],rax
    28fb:	mov    rcx,QWORD PTR [rsp+0x30]
    2900:	mov    QWORD PTR [rsp+0x18],rcx
    2905:	mov    QWORD PTR [rsp+0x28],rax
    290a:	jmp    25e0 <botlish_fn_41+0x50>
    290f:	mov    rdx,QWORD PTR [rsp+0x28]
    2914:	mov    rsi,rbx
    2917:	mov    rdi,r15
    291a:	call   291f <botlish_fn_41+0x38f>
			291b: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    291f:	test   rax,rax
    2922:	jne    294d <botlish_fn_41+0x3bd>
    2928:	xor    rax,rax
    292b:	mov    rbx,QWORD PTR [rsp+0x40]
    2930:	mov    r12,QWORD PTR [rsp+0x48]
    2935:	mov    r13,QWORD PTR [rsp+0x50]
    293a:	mov    r14,QWORD PTR [rsp+0x58]
    293f:	mov    r15,QWORD PTR [rsp+0x60]
    2944:	add    rsp,0x70
    2948:	mov    rsp,rbp
    294b:	pop    rbp
    294c:	ret
    294d:	mov    QWORD PTR [rsp],rbx
    2951:	mov    QWORD PTR [rsp+0x8],r13
    2956:	mov    QWORD PTR [rsp+0x10],rax
    295b:	mov    rdx,QWORD PTR [rsp+0x28]
    2960:	mov    QWORD PTR [rsp+0x18],rdx
    2965:	mov    rcx,QWORD PTR [rsp+0x28]
    296a:	mov    QWORD PTR [rsp+0x30],rcx
    296f:	mov    QWORD PTR [rsp+0x28],rax
    2974:	jmp    25e0 <botlish_fn_41+0x50>
    2979:	mov    rax,QWORD PTR [rsp+0x28]
    297e:	mov    rbx,QWORD PTR [rsp+0x40]
    2983:	mov    r12,QWORD PTR [rsp+0x48]
    2988:	mov    r13,QWORD PTR [rsp+0x50]
    298d:	mov    r14,QWORD PTR [rsp+0x58]
    2992:	mov    r15,QWORD PTR [rsp+0x60]
    2997:	add    rsp,0x70
    299b:	mov    rsp,rbp
    299e:	pop    rbp
    299f:	ret
    29a0:	mov    rax,QWORD PTR [rsp+0x30]
    29a5:	test   rax,0x1
    29ab:	jne    29d8 <botlish_fn_41+0x448>
    29b1:	mov    edx,0x1
    29b6:	mov    rdi,r15
    29b9:	mov    rsi,QWORD PTR [rsp+0x30]
    29be:	call   29c3 <botlish_fn_41+0x433>
			29bf: R_X86_64_PLT32	rt_int_cmp-0x4
    29c3:	mov    esi,0x2
    29c8:	test   rax,rax
    29cb:	cmovge rsi,QWORD PTR [rip+0x7d]        # 2a50 <botlish_fn_41+0x4c0>
    29d3:	jmp    29f2 <botlish_fn_41+0x462>
    29d8:	mov    esi,0x2
    29dd:	mov    rax,QWORD PTR [rsp+0x30]
    29e2:	mov    rcx,QWORD PTR [rsp+0x30]
    29e7:	test   rax,rcx
    29ea:	cmovg  rsi,QWORD PTR [rip+0x5e]        # 2a50 <botlish_fn_41+0x4c0>
    29f2:	cmp    rsi,0x6
    29f6:	je     2a23 <botlish_fn_41+0x493>
    29fc:	mov    rax,QWORD PTR [rsp+0x28]
    2a01:	mov    rbx,QWORD PTR [rsp+0x40]
    2a06:	mov    r12,QWORD PTR [rsp+0x48]
    2a0b:	mov    r13,QWORD PTR [rsp+0x50]
    2a10:	mov    r14,QWORD PTR [rsp+0x58]
    2a15:	mov    r15,QWORD PTR [rsp+0x60]
    2a1a:	add    rsp,0x70
    2a1e:	mov    rsp,rbp
    2a21:	pop    rbp
    2a22:	ret
    2a23:	mov    rax,QWORD PTR [rsp+0x30]
    2a28:	mov    rbx,QWORD PTR [rsp+0x40]
    2a2d:	mov    r12,QWORD PTR [rsp+0x48]
    2a32:	mov    r13,QWORD PTR [rsp+0x50]
    2a37:	mov    r14,QWORD PTR [rsp+0x58]
    2a3c:	mov    r15,QWORD PTR [rsp+0x60]
    2a41:	add    rsp,0x70
    2a45:	mov    rsp,rbp
    2a48:	pop    rbp
    2a49:	ret
    2a4a:	add    BYTE PTR [rax],al
    2a4c:	add    BYTE PTR [rax],al
    2a4e:	add    BYTE PTR [rax],al
    2a50:	(bad)
    2a51:	add    BYTE PTR [rax],al
    2a53:	add    BYTE PTR [rax],al
    2a55:	add    BYTE PTR [rax],al
	...

0000000000002a58 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    2a58:	push   rbp
    2a59:	mov    rbp,rsp
    2a5c:	mov    rsi,QWORD PTR [rdx]
    2a5f:	mov    r9,QWORD PTR [rdx+0x8]
    2a63:	mov    rcx,QWORD PTR [rdx+0x10]
    2a67:	mov    r8,QWORD PTR [rdx+0x18]
    2a6b:	mov    rdx,r9
    2a6e:	call   2a73 <botlish_entry_41+0x1b>
			2a6f: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    2a73:	mov    rsp,rbp
    2a76:	pop    rbp
    2a77:	ret

0000000000002a78 <botlish_fn_42: ht_get<any, str>>:
    2a78:	push   rbp
    2a79:	mov    rbp,rsp
    2a7c:	sub    rsp,0x40
    2a80:	mov    QWORD PTR [rsp+0x20],rbx
    2a85:	mov    QWORD PTR [rsp+0x28],r12
    2a8a:	mov    QWORD PTR [rsp+0x30],r13
    2a8f:	mov    rbx,rdi
    2a92:	mov    QWORD PTR [rsp+0x10],0x0
    2a9b:	mov    QWORD PTR [rsp],rsi
    2a9f:	mov    r13,rsi
    2aa2:	mov    QWORD PTR [rsp+0x8],rdx
    2aa7:	mov    r12,rdx
    2aaa:	mov    rdx,r12
    2aad:	mov    rsi,r13
    2ab0:	mov    rdi,rbx
    2ab3:	call   2ab8 <botlish_fn_42+0x40>
			2ab4: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    2ab8:	test   rax,rax
    2abb:	je     2baa <botlish_fn_42+0x132>
    2ac1:	mov    QWORD PTR [rsp+0x10],rax
    2ac6:	mov    rcx,rax
    2ac9:	mov    rdx,r12
    2acc:	mov    rsi,r13
    2acf:	mov    rdi,rbx
    2ad2:	call   2ad7 <botlish_fn_42+0x5f>
			2ad3: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    2ad7:	mov    rcx,rax
    2ada:	mov    r12,rax
    2add:	test   rax,rcx
    2ae0:	je     2baa <botlish_fn_42+0x132>
    2ae6:	mov    rax,r12
    2ae9:	mov    QWORD PTR [rsp+0x8],rax
    2aee:	test   rax,0x1
    2af4:	jne    2b1f <botlish_fn_42+0xa7>
    2afa:	mov    edx,0x1
    2aff:	mov    rsi,r12
    2b02:	mov    rdi,rbx
    2b05:	call   2b0a <botlish_fn_42+0x92>
			2b06: R_X86_64_PLT32	rt_int_cmp-0x4
    2b0a:	mov    ecx,0x2
    2b0f:	test   rax,rax
    2b12:	cmovl  rcx,QWORD PTR [rip+0xe6]        # 2c00 <botlish_fn_42+0x188>
    2b1a:	jmp    2b32 <botlish_fn_42+0xba>
    2b1f:	mov    ecx,0x2
    2b24:	mov    rax,r12
    2b27:	test   rax,rax
    2b2a:	cmovle rcx,QWORD PTR [rip+0xce]        # 2c00 <botlish_fn_42+0x188>
    2b32:	cmp    rcx,0x6
    2b36:	je     2bdd <botlish_fn_42+0x165>
    2b3c:	mov    rsi,r13
    2b3f:	mov    rdi,rbx
    2b42:	call   2b47 <botlish_fn_42+0xcf>
			2b43: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    2b47:	test   rax,rax
    2b4a:	je     2baa <botlish_fn_42+0x132>
    2b50:	xor    ecx,ecx
    2b52:	test   rax,0x7
    2b58:	je     2b66 <botlish_fn_42+0xee>
    2b5e:	mov    rsi,rax
    2b61:	jmp    2b74 <botlish_fn_42+0xfc>
    2b66:	movzx  rcx,BYTE PTR [rax]
    2b6a:	mov    rsi,rax
    2b6d:	rex cmp cl,0x8
    2b71:	sete   cl
    2b74:	test   cl,cl
    2b76:	jne    2b96 <botlish_fn_42+0x11e>
    2b7c:	mov    rdi,rbx
    2b7f:	mov    rax,QWORD PTR [rdi+0x10]
    2b83:	mov    rcx,QWORD PTR [rax+0x20]
    2b87:	mov    edx,0x8
    2b8c:	call   2b91 <botlish_fn_42+0x119>
			2b8d: R_X86_64_PLT32	rt_type_error-0x4
    2b91:	jmp    2baa <botlish_fn_42+0x132>
    2b96:	mov    rdx,r12
    2b99:	mov    rdi,rbx
    2b9c:	call   2ba1 <botlish_fn_42+0x129>
			2b9d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ba1:	test   rax,rax
    2ba4:	jne    2bc5 <botlish_fn_42+0x14d>
    2baa:	xor    rax,rax
    2bad:	mov    rbx,QWORD PTR [rsp+0x20]
    2bb2:	mov    r12,QWORD PTR [rsp+0x28]
    2bb7:	mov    r13,QWORD PTR [rsp+0x30]
    2bbc:	add    rsp,0x40
    2bc0:	mov    rsp,rbp
    2bc3:	pop    rbp
    2bc4:	ret
    2bc5:	mov    rbx,QWORD PTR [rsp+0x20]
    2bca:	mov    r12,QWORD PTR [rsp+0x28]
    2bcf:	mov    r13,QWORD PTR [rsp+0x30]
    2bd4:	add    rsp,0x40
    2bd8:	mov    rsp,rbp
    2bdb:	pop    rbp
    2bdc:	ret
    2bdd:	mov    eax,0xa
    2be2:	mov    rbx,QWORD PTR [rsp+0x20]
    2be7:	mov    r12,QWORD PTR [rsp+0x28]
    2bec:	mov    r13,QWORD PTR [rsp+0x30]
    2bf1:	add    rsp,0x40
    2bf5:	mov    rsp,rbp
    2bf8:	pop    rbp
    2bf9:	ret
    2bfa:	add    BYTE PTR [rax],al
    2bfc:	add    BYTE PTR [rax],al
    2bfe:	add    BYTE PTR [rax],al
    2c00:	(bad)
    2c01:	add    BYTE PTR [rax],al
    2c03:	add    BYTE PTR [rax],al
    2c05:	add    BYTE PTR [rax],al
	...

0000000000002c08 <botlish_entry_42: ht_get<any, str>>:
    2c08:	push   rbp
    2c09:	mov    rbp,rsp
    2c0c:	mov    rsi,QWORD PTR [rdx]
    2c0f:	mov    rdx,QWORD PTR [rdx+0x8]
    2c13:	call   2c18 <botlish_entry_42+0x10>
			2c14: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    2c18:	mov    rsp,rbp
    2c1b:	pop    rbp
    2c1c:	ret
    2c1d:	add    BYTE PTR [rax],al
	...

0000000000002c20 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    2c20:	push   rbp
    2c21:	mov    rbp,rsp
    2c24:	sub    rsp,0x50
    2c28:	mov    QWORD PTR [rsp+0x20],rbx
    2c2d:	mov    QWORD PTR [rsp+0x28],r12
    2c32:	mov    QWORD PTR [rsp+0x30],r13
    2c37:	mov    QWORD PTR [rsp+0x38],r14
    2c3c:	mov    QWORD PTR [rsp+0x40],r15
    2c41:	mov    r13,rdi
    2c44:	mov    QWORD PTR [rsp],rsi
    2c48:	mov    QWORD PTR [rsp+0x8],rdx
    2c4d:	mov    QWORD PTR [rsp+0x10],rcx
    2c52:	mov    r12,rcx
    2c55:	mov    rbx,rsi
    2c58:	mov    r14,rdx
    2c5b:	mov    rdx,r14
    2c5e:	mov    rsi,rbx
    2c61:	mov    rdi,r13
    2c64:	call   2c69 <botlish_fn_43+0x49>
			2c65: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c69:	test   rax,rax
    2c6c:	je     2d2f <botlish_fn_43+0x10f>
    2c72:	mov    QWORD PTR [rsp+0x18],rax
    2c77:	mov    r15,rax
    2c7a:	mov    rdi,r13
    2c7d:	call   2c82 <botlish_fn_43+0x62>
			2c7e: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    2c82:	test   rax,rax
    2c85:	je     2d2f <botlish_fn_43+0x10f>
    2c8b:	mov    rcx,r15
    2c8e:	mov    rdx,rcx
    2c91:	and    rdx,rax
    2c94:	test   rdx,0x1
    2c9b:	jne    2cbd <botlish_fn_43+0x9d>
    2ca1:	mov    rdx,rax
    2ca4:	mov    rsi,r15
    2ca7:	mov    rdi,r13
    2caa:	call   2caf <botlish_fn_43+0x8f>
			2cab: R_X86_64_PLT32	rt_value_eq-0x4
    2caf:	test   rax,rax
    2cb2:	je     2d2f <botlish_fn_43+0x10f>
    2cb8:	jmp    2cd3 <botlish_fn_43+0xb3>
    2cbd:	mov    rdx,rax
    2cc0:	mov    rsi,r15
    2cc3:	mov    eax,0x2
    2cc8:	cmp    rsi,rdx
    2ccb:	cmove  rax,QWORD PTR [rip+0xbd]        # 2d90 <botlish_fn_43+0x170>
    2cd3:	cmp    rax,0x6
    2cd7:	je     2d6a <botlish_fn_43+0x14a>
    2cdd:	mov    QWORD PTR [rsp+0x18],0x3
    2ce6:	mov    rsi,r14
    2ce9:	test   rsi,0x1
    2cf0:	je     2d08 <botlish_fn_43+0xe8>
    2cf6:	mov    rsi,r14
    2cf9:	add    rsi,0x2
    2cfd:	seto   al
    2d00:	test   al,al
    2d02:	je     2d1b <botlish_fn_43+0xfb>
    2d08:	mov    edx,0x3
    2d0d:	mov    rsi,r14
    2d10:	mov    rdi,r13
    2d13:	call   2d18 <botlish_fn_43+0xf8>
			2d14: R_X86_64_PLT32	rt_int_add-0x4
    2d18:	mov    rsi,rax
    2d1b:	mov    rdx,r12
    2d1e:	mov    rdi,r13
    2d21:	call   2d26 <botlish_fn_43+0x106>
			2d22: R_X86_64_PLT32	rt_int_mod-0x4
    2d26:	test   rax,rax
    2d29:	jne    2d54 <botlish_fn_43+0x134>
    2d2f:	xor    rax,rax
    2d32:	mov    rbx,QWORD PTR [rsp+0x20]
    2d37:	mov    r12,QWORD PTR [rsp+0x28]
    2d3c:	mov    r13,QWORD PTR [rsp+0x30]
    2d41:	mov    r14,QWORD PTR [rsp+0x38]
    2d46:	mov    r15,QWORD PTR [rsp+0x40]
    2d4b:	add    rsp,0x50
    2d4f:	mov    rsp,rbp
    2d52:	pop    rbp
    2d53:	ret
    2d54:	mov    QWORD PTR [rsp],rbx
    2d58:	mov    QWORD PTR [rsp+0x8],rax
    2d5d:	mov    QWORD PTR [rsp+0x10],r12
    2d62:	mov    r14,rax
    2d65:	jmp    2c5b <botlish_fn_43+0x3b>
    2d6a:	mov    rax,r14
    2d6d:	mov    rbx,QWORD PTR [rsp+0x20]
    2d72:	mov    r12,QWORD PTR [rsp+0x28]
    2d77:	mov    r13,QWORD PTR [rsp+0x30]
    2d7c:	mov    r14,QWORD PTR [rsp+0x38]
    2d81:	mov    r15,QWORD PTR [rsp+0x40]
    2d86:	add    rsp,0x50
    2d8a:	mov    rsp,rbp
    2d8d:	pop    rbp
    2d8e:	ret
    2d8f:	add    BYTE PTR [rsi],al
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
    2e23:	je     2ed3 <botlish_fn_44+0x11f>
    2e29:	mov    rdx,QWORD PTR [rsp+0x40]
    2e2e:	mov    rdi,r12
    2e31:	call   2e36 <botlish_fn_44+0x82>
			2e32: R_X86_64_PLT32	rt_int_mod-0x4
    2e36:	test   rax,rax
    2e39:	je     2ed3 <botlish_fn_44+0x11f>
    2e3f:	mov    QWORD PTR [rsp+0x30],rax
    2e44:	mov    rcx,QWORD PTR [rsp+0x40]
    2e49:	mov    rdx,rax
    2e4c:	mov    rsi,QWORD PTR [rsp+0x38]
    2e51:	mov    rdi,r12
    2e54:	call   2e59 <botlish_fn_44+0xa5>
			2e55: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    2e59:	test   rax,rax
    2e5c:	je     2ed3 <botlish_fn_44+0x11f>
    2e62:	mov    QWORD PTR [rsp+0x18],rax
    2e67:	mov    QWORD PTR [rsp+0x40],rax
    2e6c:	mov    rdi,r12
    2e6f:	call   2e74 <botlish_fn_44+0xc0>
			2e70: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2e74:	test   rax,rax
    2e77:	mov    rcx,rax
    2e7a:	je     2ed3 <botlish_fn_44+0x11f>
    2e80:	mov    rsi,QWORD PTR [rsp+0x38]
    2e85:	mov    rdx,QWORD PTR [rsp+0x40]
    2e8a:	mov    rdi,r12
    2e8d:	call   2e92 <botlish_fn_44+0xde>
			2e8e: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e92:	test   rax,rax
    2e95:	je     2ed3 <botlish_fn_44+0x11f>
    2e9b:	mov    rcx,r14
    2e9e:	mov    rsi,r15
    2ea1:	mov    rdx,QWORD PTR [rsp+0x40]
    2ea6:	mov    rdi,r12
    2ea9:	call   2eae <botlish_fn_44+0xfa>
			2eaa: R_X86_64_PLT32	rt_mutarray_set-0x4
    2eae:	test   rax,rax
    2eb1:	je     2ed3 <botlish_fn_44+0x11f>
    2eb7:	mov    rcx,r13
    2eba:	mov    rdx,QWORD PTR [rsp+0x40]
    2ebf:	mov    rsi,rbx
    2ec2:	mov    rdi,r12
    2ec5:	call   2eca <botlish_fn_44+0x116>
			2ec6: R_X86_64_PLT32	rt_mutarray_set-0x4
    2eca:	test   rax,rax
    2ecd:	jne    2efb <botlish_fn_44+0x147>
    2ed3:	xor    rax,rax
    2ed6:	mov    rbx,QWORD PTR [rsp+0x50]
    2edb:	mov    r12,QWORD PTR [rsp+0x58]
    2ee0:	mov    r13,QWORD PTR [rsp+0x60]
    2ee5:	mov    r14,QWORD PTR [rsp+0x68]
    2eea:	mov    r15,QWORD PTR [rsp+0x70]
    2eef:	add    rsp,0x80
    2ef6:	mov    rsp,rbp
    2ef9:	pop    rbp
    2efa:	ret
    2efb:	mov    eax,0xa
    2f00:	mov    rbx,QWORD PTR [rsp+0x50]
    2f05:	mov    r12,QWORD PTR [rsp+0x58]
    2f0a:	mov    r13,QWORD PTR [rsp+0x60]
    2f0f:	mov    r14,QWORD PTR [rsp+0x68]
    2f14:	mov    r15,QWORD PTR [rsp+0x70]
    2f19:	add    rsp,0x80
    2f20:	mov    rsp,rbp
    2f23:	pop    rbp
    2f24:	ret

0000000000002f25 <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    2f25:	push   rbp
    2f26:	mov    rbp,rsp
    2f29:	sub    rsp,0x10
    2f2d:	mov    rsi,QWORD PTR [rdx]
    2f30:	mov    r10,QWORD PTR [rdx+0x8]
    2f34:	mov    rcx,QWORD PTR [rdx+0x10]
    2f38:	mov    r8,QWORD PTR [rdx+0x18]
    2f3c:	mov    r9,QWORD PTR [rdx+0x20]
    2f40:	mov    r11,QWORD PTR [rdx+0x28]
    2f44:	mov    QWORD PTR [rsp],r11
    2f48:	mov    rdx,r10
    2f4b:	call   2f50 <botlish_entry_44+0x2b>
			2f4c: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    2f50:	add    rsp,0x10
    2f54:	mov    rsp,rbp
    2f57:	pop    rbp
    2f58:	ret
    2f59:	add    BYTE PTR [rax],al
    2f5b:	add    BYTE PTR [rax],al
    2f5d:	add    BYTE PTR [rax],al
	...

0000000000002f60 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2f60:	push   rbp
    2f61:	mov    rbp,rsp
    2f64:	sub    rsp,0xd0
    2f6b:	mov    QWORD PTR [rsp+0xa0],rbx
    2f73:	mov    QWORD PTR [rsp+0xa8],r12
    2f7b:	mov    QWORD PTR [rsp+0xb0],r13
    2f83:	mov    QWORD PTR [rsp+0xb8],r14
    2f8b:	mov    QWORD PTR [rsp+0xc0],r15
    2f93:	mov    QWORD PTR [rsp+0x68],rdi
    2f98:	mov    r15,QWORD PTR [rbp+0x10]
    2f9c:	mov    r12,QWORD PTR [rbp+0x18]
    2fa0:	mov    r13,QWORD PTR [rbp+0x20]
    2fa4:	mov    r14,QWORD PTR [rbp+0x28]
    2fa8:	mov    QWORD PTR [rsp+0x60],0x0
    2fb1:	mov    QWORD PTR [rsp+0x10],rsi
    2fb6:	mov    QWORD PTR [rsp+0x70],rsi
    2fbb:	mov    QWORD PTR [rsp+0x18],rdx
    2fc0:	mov    QWORD PTR [rsp+0x78],rdx
    2fc5:	mov    QWORD PTR [rsp+0x20],rcx
    2fca:	mov    QWORD PTR [rsp+0x80],rcx
    2fd2:	mov    QWORD PTR [rsp+0x28],r8
    2fd7:	mov    QWORD PTR [rsp+0x30],r9
    2fdc:	mov    QWORD PTR [rsp+0x38],r15
    2fe1:	mov    QWORD PTR [rsp+0x40],r12
    2fe6:	mov    QWORD PTR [rsp+0x48],r13
    2feb:	mov    QWORD PTR [rsp+0x50],r14
    2ff0:	mov    rbx,r9
    2ff3:	mov    rsi,r8
    2ff6:	mov    rax,rsi
    2ff9:	and    rax,rbx
    2ffc:	mov    QWORD PTR [rsp+0x88],rsi
    3004:	test   rax,0x1
    300a:	jne    303a <botlish_fn_45+0xda>
    3010:	mov    rdx,rbx
    3013:	mov    rsi,QWORD PTR [rsp+0x88]
    301b:	mov    rdi,QWORD PTR [rsp+0x68]
    3020:	call   3025 <botlish_fn_45+0xc5>
			3021: R_X86_64_PLT32	rt_int_cmp-0x4
    3025:	mov    ecx,0x2
    302a:	test   rax,rax
    302d:	cmovge rcx,QWORD PTR [rip+0x373]        # 33a8 <botlish_fn_45+0x448>
    3035:	jmp    3052 <botlish_fn_45+0xf2>
    303a:	mov    ecx,0x2
    303f:	mov    rsi,QWORD PTR [rsp+0x88]
    3047:	cmp    rsi,rbx
    304a:	cmovge rcx,QWORD PTR [rip+0x356]        # 33a8 <botlish_fn_45+0x448>
    3052:	cmp    rcx,0x6
    3056:	je     3369 <botlish_fn_45+0x409>
    305c:	xor    eax,eax
    305e:	mov    rsi,QWORD PTR [rsp+0x70]
    3063:	test   rsi,0x7
    306a:	jne    3079 <botlish_fn_45+0x119>
    3070:	movzx  rax,BYTE PTR [rsi]
    3074:	cmp    al,0x8
    3076:	sete   al
    3079:	test   al,al
    307b:	jne    309d <botlish_fn_45+0x13d>
    3081:	mov    rdi,QWORD PTR [rsp+0x68]
    3086:	mov    rax,QWORD PTR [rdi+0x10]
    308a:	mov    rcx,QWORD PTR [rax+0x20]
    308e:	mov    edx,0x8
    3093:	call   3098 <botlish_fn_45+0x138>
			3094: R_X86_64_PLT32	rt_type_error-0x4
    3098:	jmp    3278 <botlish_fn_45+0x318>
    309d:	mov    QWORD PTR [rsp+0x70],rsi
    30a2:	mov    rdx,QWORD PTR [rsp+0x88]
    30aa:	mov    rdi,QWORD PTR [rsp+0x68]
    30af:	call   30b4 <botlish_fn_45+0x154>
			30b0: R_X86_64_PLT32	rt_mutarray_get-0x4
    30b4:	test   rax,rax
    30b7:	je     3278 <botlish_fn_45+0x318>
    30bd:	mov    QWORD PTR [rsp+0x58],rax
    30c2:	mov    QWORD PTR [rsp+0x90],rax
    30ca:	mov    rdi,QWORD PTR [rsp+0x68]
    30cf:	call   30d4 <botlish_fn_45+0x174>
			30d0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    30d4:	test   rax,rax
    30d7:	je     3278 <botlish_fn_45+0x318>
    30dd:	mov    rcx,QWORD PTR [rsp+0x90]
    30e5:	mov    rdx,rcx
    30e8:	and    rdx,rax
    30eb:	test   rdx,0x1
    30f2:	jne    311b <botlish_fn_45+0x1bb>
    30f8:	mov    rdx,rax
    30fb:	mov    rsi,QWORD PTR [rsp+0x90]
    3103:	mov    rdi,QWORD PTR [rsp+0x68]
    3108:	call   310d <botlish_fn_45+0x1ad>
			3109: R_X86_64_PLT32	rt_value_eq-0x4
    310d:	test   rax,rax
    3110:	je     3278 <botlish_fn_45+0x318>
    3116:	jmp    3136 <botlish_fn_45+0x1d6>
    311b:	mov    rdx,rax
    311e:	mov    rsi,QWORD PTR [rsp+0x90]
    3126:	mov    eax,0x2
    312b:	cmp    rsi,rdx
    312e:	cmove  rax,QWORD PTR [rip+0x272]        # 33a8 <botlish_fn_45+0x448>
    3136:	cmp    rax,0x6
    313a:	jne    32af <botlish_fn_45+0x34f>
    3140:	xor    eax,eax
    3142:	mov    rdx,QWORD PTR [rsp+0x78]
    3147:	test   rdx,0x7
    314e:	je     315e <botlish_fn_45+0x1fe>
    3154:	mov    QWORD PTR [rsp+0x78],rdx
    3159:	jmp    316c <botlish_fn_45+0x20c>
    315e:	movzx  rax,BYTE PTR [rdx]
    3162:	mov    QWORD PTR [rsp+0x78],rdx
    3167:	cmp    al,0x8
    3169:	sete   al
    316c:	test   al,al
    316e:	jne    3195 <botlish_fn_45+0x235>
    3174:	mov    rdi,QWORD PTR [rsp+0x68]
    3179:	mov    rax,QWORD PTR [rdi+0x10]
    317d:	mov    rcx,QWORD PTR [rax+0x20]
    3181:	mov    edx,0x8
    3186:	mov    rsi,QWORD PTR [rsp+0x78]
    318b:	call   3190 <botlish_fn_45+0x230>
			318c: R_X86_64_PLT32	rt_type_error-0x4
    3190:	jmp    3278 <botlish_fn_45+0x318>
    3195:	mov    rdx,QWORD PTR [rsp+0x88]
    319d:	mov    rsi,QWORD PTR [rsp+0x78]
    31a2:	mov    rdi,QWORD PTR [rsp+0x68]
    31a7:	call   31ac <botlish_fn_45+0x24c>
			31a8: R_X86_64_PLT32	rt_mutarray_get-0x4
    31ac:	test   rax,rax
    31af:	je     3278 <botlish_fn_45+0x318>
    31b5:	mov    QWORD PTR [rsp+0x58],rax
    31ba:	mov    QWORD PTR [rsp+0x90],rax
    31c2:	xor    eax,eax
    31c4:	mov    rcx,QWORD PTR [rsp+0x80]
    31cc:	test   rcx,0x7
    31d3:	je     31e6 <botlish_fn_45+0x286>
    31d9:	mov    QWORD PTR [rsp+0x80],rcx
    31e1:	jmp    31f9 <botlish_fn_45+0x299>
    31e6:	movzx  rdx,BYTE PTR [rcx]
    31ea:	mov    QWORD PTR [rsp+0x80],rcx
    31f2:	rex cmp dl,0x8
    31f6:	sete   al
    31f9:	test   al,al
    31fb:	jne    3225 <botlish_fn_45+0x2c5>
    3201:	mov    rdi,QWORD PTR [rsp+0x68]
    3206:	mov    rsi,QWORD PTR [rdi+0x10]
    320a:	mov    rcx,QWORD PTR [rsi+0x20]
    320e:	mov    edx,0x8
    3213:	mov    rsi,QWORD PTR [rsp+0x80]
    321b:	call   3220 <botlish_fn_45+0x2c0>
			321c: R_X86_64_PLT32	rt_type_error-0x4
    3220:	jmp    3278 <botlish_fn_45+0x318>
    3225:	mov    rdx,QWORD PTR [rsp+0x88]
    322d:	mov    rsi,QWORD PTR [rsp+0x80]
    3235:	mov    rdi,QWORD PTR [rsp+0x68]
    323a:	call   323f <botlish_fn_45+0x2df>
			323b: R_X86_64_PLT32	rt_mutarray_get-0x4
    323f:	test   rax,rax
    3242:	je     3278 <botlish_fn_45+0x318>
    3248:	mov    QWORD PTR [rsp+0x60],rax
    324d:	mov    QWORD PTR [rsp],rax
    3251:	mov    r9,QWORD PTR [rsp+0x90]
    3259:	mov    rcx,r13
    325c:	mov    rdx,r12
    325f:	mov    rsi,r15
    3262:	mov    rdi,QWORD PTR [rsp+0x68]
    3267:	mov    r8,r14
    326a:	call   326f <botlish_fn_45+0x30f>
			326b: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    326f:	test   rax,rax
    3272:	jne    32af <botlish_fn_45+0x34f>
    3278:	xor    rax,rax
    327b:	mov    rbx,QWORD PTR [rsp+0xa0]
    3283:	mov    r12,QWORD PTR [rsp+0xa8]
    328b:	mov    r13,QWORD PTR [rsp+0xb0]
    3293:	mov    r14,QWORD PTR [rsp+0xb8]
    329b:	mov    r15,QWORD PTR [rsp+0xc0]
    32a3:	add    rsp,0xd0
    32aa:	mov    rsp,rbp
    32ad:	pop    rbp
    32ae:	ret
    32af:	mov    QWORD PTR [rsp+0x58],0x3
    32b8:	mov    rsi,QWORD PTR [rsp+0x88]
    32c0:	test   rsi,0x1
    32c7:	je     32f9 <botlish_fn_45+0x399>
    32cd:	mov    rsi,QWORD PTR [rsp+0x88]
    32d5:	mov    rax,rsi
    32d8:	add    rax,0x2
    32dc:	seto   cl
    32df:	test   cl,cl
    32e1:	jne    32f9 <botlish_fn_45+0x399>
    32e7:	mov    rsi,QWORD PTR [rsp+0x70]
    32ec:	mov    QWORD PTR [rsp+0x88],rax
    32f4:	jmp    331d <botlish_fn_45+0x3bd>
    32f9:	mov    edx,0x3
    32fe:	mov    rsi,QWORD PTR [rsp+0x88]
    3306:	mov    rdi,QWORD PTR [rsp+0x68]
    330b:	call   3310 <botlish_fn_45+0x3b0>
			330c: R_X86_64_PLT32	rt_int_add-0x4
    3310:	mov    rsi,QWORD PTR [rsp+0x70]
    3315:	mov    QWORD PTR [rsp+0x88],rax
    331d:	mov    rsi,QWORD PTR [rsp+0x70]
    3322:	mov    QWORD PTR [rsp+0x10],rsi
    3327:	mov    rsi,QWORD PTR [rsp+0x78]
    332c:	mov    QWORD PTR [rsp+0x18],rsi
    3331:	mov    rsi,QWORD PTR [rsp+0x80]
    3339:	mov    QWORD PTR [rsp+0x20],rsi
    333e:	mov    rsi,QWORD PTR [rsp+0x88]
    3346:	mov    QWORD PTR [rsp+0x28],rsi
    334b:	mov    QWORD PTR [rsp+0x30],rbx
    3350:	mov    QWORD PTR [rsp+0x38],r15
    3355:	mov    QWORD PTR [rsp+0x40],r12
    335a:	mov    QWORD PTR [rsp+0x48],r13
    335f:	mov    QWORD PTR [rsp+0x50],r14
    3364:	jmp    2ff6 <botlish_fn_45+0x96>
    3369:	mov    eax,0xa
    336e:	mov    rbx,QWORD PTR [rsp+0xa0]
    3376:	mov    r12,QWORD PTR [rsp+0xa8]
    337e:	mov    r13,QWORD PTR [rsp+0xb0]
    3386:	mov    r14,QWORD PTR [rsp+0xb8]
    338e:	mov    r15,QWORD PTR [rsp+0xc0]
    3396:	add    rsp,0xd0
    339d:	mov    rsp,rbp
    33a0:	pop    rbp
    33a1:	ret
    33a2:	add    BYTE PTR [rax],al
    33a4:	add    BYTE PTR [rax],al
    33a6:	add    BYTE PTR [rax],al
    33a8:	(bad)
    33a9:	add    BYTE PTR [rax],al
    33ab:	add    BYTE PTR [rax],al
    33ad:	add    BYTE PTR [rax],al
	...

00000000000033b0 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    33b0:	push   rbp
    33b1:	mov    rbp,rsp
    33b4:	sub    rsp,0x30
    33b8:	mov    QWORD PTR [rsp+0x20],r12
    33bd:	mov    rsi,QWORD PTR [rdx]
    33c0:	mov    rax,QWORD PTR [rdx+0x8]
    33c4:	mov    rcx,QWORD PTR [rdx+0x10]
    33c8:	mov    r8,QWORD PTR [rdx+0x18]
    33cc:	mov    r9,QWORD PTR [rdx+0x20]
    33d0:	mov    r10,QWORD PTR [rdx+0x28]
    33d4:	mov    r11,QWORD PTR [rdx+0x30]
    33d8:	mov    r12,QWORD PTR [rdx+0x38]
    33dc:	mov    rdx,QWORD PTR [rdx+0x40]
    33e0:	mov    QWORD PTR [rsp],r10
    33e4:	mov    QWORD PTR [rsp+0x8],r11
    33e9:	mov    QWORD PTR [rsp+0x10],r12
    33ee:	mov    QWORD PTR [rsp+0x18],rdx
    33f3:	mov    rdx,rax
    33f6:	call   33fb <botlish_entry_45+0x4b>
			33f7: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    33fb:	mov    r12,QWORD PTR [rsp+0x20]
    3400:	add    rsp,0x30
    3404:	mov    rsp,rbp
    3407:	pop    rbp
    3408:	ret

0000000000003409 <botlish_fn_46: ht_rehash<mutarray, int>>:
    3409:	push   rbp
    340a:	mov    rbp,rsp
    340d:	sub    rsp,0xd0
    3414:	mov    QWORD PTR [rsp+0xa0],rbx
    341c:	mov    QWORD PTR [rsp+0xa8],r12
    3424:	mov    QWORD PTR [rsp+0xb0],r13
    342c:	mov    QWORD PTR [rsp+0xb8],r14
    3434:	mov    QWORD PTR [rsp+0xc0],r15
    343c:	mov    r13,rdi
    343f:	mov    QWORD PTR [rsp+0x30],0x0
    3448:	mov    QWORD PTR [rsp+0x38],0x0
    3451:	mov    QWORD PTR [rsp+0x40],0x0
    345a:	mov    QWORD PTR [rsp+0x48],0x0
    3463:	mov    QWORD PTR [rsp+0x50],0x0
    346c:	mov    QWORD PTR [rsp+0x58],0x0
    3475:	mov    QWORD PTR [rsp+0x60],0x0
    347e:	mov    QWORD PTR [rsp+0x68],0x0
    3487:	mov    QWORD PTR [rsp+0x20],rsi
    348c:	mov    r12,rsi
    348f:	mov    QWORD PTR [rsp+0x28],rdx
    3494:	mov    rbx,rdx
    3497:	mov    rsi,r12
    349a:	mov    rdi,r13
    349d:	call   34a2 <botlish_fn_46+0x99>
			349e: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    34a2:	test   rax,rax
    34a5:	je     3674 <botlish_fn_46+0x26b>
    34ab:	mov    QWORD PTR [rsp+0x30],rax
    34b0:	mov    r14,rax
    34b3:	mov    rsi,r12
    34b6:	mov    rdi,r13
    34b9:	call   34be <botlish_fn_46+0xb5>
			34ba: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    34be:	test   rax,rax
    34c1:	je     3674 <botlish_fn_46+0x26b>
    34c7:	mov    QWORD PTR [rsp+0x38],rax
    34cc:	mov    r15,rax
    34cf:	mov    rsi,r12
    34d2:	mov    rdi,r13
    34d5:	call   34da <botlish_fn_46+0xd1>
			34d6: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    34da:	test   rax,rax
    34dd:	je     3674 <botlish_fn_46+0x26b>
    34e3:	mov    QWORD PTR [rsp+0x40],rax
    34e8:	mov    QWORD PTR [rsp+0x90],rax
    34f0:	mov    rsi,r12
    34f3:	mov    rdi,r13
    34f6:	call   34fb <botlish_fn_46+0xf2>
			34f7: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    34fb:	test   rax,rax
    34fe:	je     3674 <botlish_fn_46+0x26b>
    3504:	mov    QWORD PTR [rsp+0x48],rax
    3509:	mov    QWORD PTR [rsp+0x88],rax
    3511:	mov    rsi,rbx
    3514:	mov    rdi,r13
    3517:	call   351c <botlish_fn_46+0x113>
			3518: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    351c:	mov    rcx,rax
    351f:	mov    QWORD PTR [rsp+0x80],rax
    3527:	test   rax,rcx
    352a:	je     3674 <botlish_fn_46+0x26b>
    3530:	mov    rax,QWORD PTR [rsp+0x80]
    3538:	mov    QWORD PTR [rsp+0x50],rax
    353d:	mov    edx,0x1
    3542:	mov    QWORD PTR [rsp+0x58],0x1
    354b:	mov    rcx,rbx
    354e:	mov    rsi,QWORD PTR [rsp+0x80]
    3556:	mov    rdi,r13
    3559:	call   355e <botlish_fn_46+0x155>
			355a: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    355e:	test   rax,rax
    3561:	je     3674 <botlish_fn_46+0x26b>
    3567:	mov    rsi,rbx
    356a:	mov    rdi,r13
    356d:	call   3572 <botlish_fn_46+0x169>
			356e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3572:	test   rax,rax
    3575:	je     3674 <botlish_fn_46+0x26b>
    357b:	mov    QWORD PTR [rsp+0x58],rax
    3580:	mov    QWORD PTR [rsp+0x78],rax
    3585:	mov    rsi,rbx
    3588:	mov    rdi,r13
    358b:	call   3590 <botlish_fn_46+0x187>
			358c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3590:	test   rax,rax
    3593:	je     3674 <botlish_fn_46+0x26b>
    3599:	mov    QWORD PTR [rsp+0x60],rax
    359e:	mov    r8d,0x1
    35a4:	mov    QWORD PTR [rsp+0x68],0x1
    35ad:	mov    rcx,QWORD PTR [rsp+0x80]
    35b5:	mov    QWORD PTR [rsp],rcx
    35b9:	mov    rcx,QWORD PTR [rsp+0x78]
    35be:	mov    QWORD PTR [rsp+0x8],rcx
    35c3:	mov    QWORD PTR [rsp+0x10],rax
    35c8:	mov    QWORD PTR [rsp+0x70],rax
    35cd:	mov    QWORD PTR [rsp+0x18],rbx
    35d2:	mov    rcx,QWORD PTR [rsp+0x90]
    35da:	mov    rdx,r15
    35dd:	mov    rsi,r14
    35e0:	mov    r9,QWORD PTR [rsp+0x88]
    35e8:	mov    rdi,r13
    35eb:	call   35f0 <botlish_fn_46+0x1e7>
			35ec: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    35f0:	test   rax,rax
    35f3:	je     3674 <botlish_fn_46+0x26b>
    35f9:	mov    edx,0x1
    35fe:	mov    rcx,QWORD PTR [rsp+0x80]
    3606:	mov    rsi,r12
    3609:	mov    rdi,r13
    360c:	call   3611 <botlish_fn_46+0x208>
			360d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3611:	test   rax,rax
    3614:	je     3674 <botlish_fn_46+0x26b>
    361a:	mov    edx,0x3
    361f:	mov    rcx,QWORD PTR [rsp+0x78]
    3624:	mov    rsi,r12
    3627:	mov    rdi,r13
    362a:	call   362f <botlish_fn_46+0x226>
			362b: R_X86_64_PLT32	rt_mutarray_set-0x4
    362f:	test   rax,rax
    3632:	je     3674 <botlish_fn_46+0x26b>
    3638:	mov    edx,0x5
    363d:	mov    rcx,QWORD PTR [rsp+0x70]
    3642:	mov    rsi,r12
    3645:	mov    rdi,r13
    3648:	call   364d <botlish_fn_46+0x244>
			3649: R_X86_64_PLT32	rt_mutarray_set-0x4
    364d:	test   rax,rax
    3650:	je     3674 <botlish_fn_46+0x26b>
    3656:	mov    edx,0x9
    365b:	mov    ecx,0x1
    3660:	mov    rsi,r12
    3663:	mov    rdi,r13
    3666:	call   366b <botlish_fn_46+0x262>
			3667: R_X86_64_PLT32	rt_mutarray_set-0x4
    366b:	test   rax,rax
    366e:	jne    36ab <botlish_fn_46+0x2a2>
    3674:	xor    rax,rax
    3677:	mov    rbx,QWORD PTR [rsp+0xa0]
    367f:	mov    r12,QWORD PTR [rsp+0xa8]
    3687:	mov    r13,QWORD PTR [rsp+0xb0]
    368f:	mov    r14,QWORD PTR [rsp+0xb8]
    3697:	mov    r15,QWORD PTR [rsp+0xc0]
    369f:	add    rsp,0xd0
    36a6:	mov    rsp,rbp
    36a9:	pop    rbp
    36aa:	ret
    36ab:	mov    eax,0xa
    36b0:	mov    rbx,QWORD PTR [rsp+0xa0]
    36b8:	mov    r12,QWORD PTR [rsp+0xa8]
    36c0:	mov    r13,QWORD PTR [rsp+0xb0]
    36c8:	mov    r14,QWORD PTR [rsp+0xb8]
    36d0:	mov    r15,QWORD PTR [rsp+0xc0]
    36d8:	add    rsp,0xd0
    36df:	mov    rsp,rbp
    36e2:	pop    rbp
    36e3:	ret

00000000000036e4 <botlish_entry_46: ht_rehash<mutarray, int>>:
    36e4:	push   rbp
    36e5:	mov    rbp,rsp
    36e8:	mov    rsi,QWORD PTR [rdx]
    36eb:	mov    rdx,QWORD PTR [rdx+0x8]
    36ef:	call   36f4 <botlish_entry_46+0x10>
			36f0: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    36f4:	mov    rsp,rbp
    36f7:	pop    rbp
    36f8:	ret
    36f9:	add    BYTE PTR [rax],al
    36fb:	add    BYTE PTR [rax],al
    36fd:	add    BYTE PTR [rax],al
	...

0000000000003700 <botlish_fn_47: ht_should_grow<mutarray>>:
    3700:	push   rbp
    3701:	mov    rbp,rsp
    3704:	sub    rsp,0x40
    3708:	mov    QWORD PTR [rsp+0x20],rbx
    370d:	mov    QWORD PTR [rsp+0x28],r12
    3712:	mov    QWORD PTR [rsp+0x30],r13
    3717:	mov    rbx,rdi
    371a:	mov    QWORD PTR [rsp+0x8],0x0
    3723:	mov    QWORD PTR [rsp+0x10],0x0
    372c:	mov    QWORD PTR [rsp],rsi
    3730:	mov    r12,rsi
    3733:	mov    rsi,r12
    3736:	mov    rdi,rbx
    3739:	call   373e <botlish_fn_47+0x3e>
			373a: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    373e:	mov    rcx,rax
    3741:	mov    r13,rax
    3744:	test   rax,rcx
    3747:	je     3937 <botlish_fn_47+0x237>
    374d:	mov    rax,r13
    3750:	mov    QWORD PTR [rsp+0x8],rax
    3755:	mov    rsi,r12
    3758:	mov    rdi,rbx
    375b:	call   3760 <botlish_fn_47+0x60>
			375c: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3760:	mov    rcx,rax
    3763:	test   rcx,rcx
    3766:	je     3937 <botlish_fn_47+0x237>
    376c:	mov    QWORD PTR [rsp+0x10],rcx
    3771:	mov    edx,0x1
    3776:	mov    rax,r13
    3779:	test   rax,0x1
    377f:	jne    37a2 <botlish_fn_47+0xa2>
    3785:	xor    edx,edx
    3787:	mov    rax,r13
    378a:	test   rax,0x7
    3790:	jne    37a2 <botlish_fn_47+0xa2>
    3796:	mov    rax,r13
    3799:	movzx  rax,BYTE PTR [rax]
    379d:	cmp    al,0x1
    379f:	sete   dl
    37a2:	test   dl,dl
    37a4:	jne    37c5 <botlish_fn_47+0xc5>
    37aa:	mov    rdi,rbx
    37ad:	mov    rax,QWORD PTR [rdi+0x10]
    37b1:	mov    rcx,QWORD PTR [rax+0x30]
    37b5:	xor    rdx,rdx
    37b8:	mov    rsi,r13
    37bb:	call   37c0 <botlish_fn_47+0xc0>
			37bc: R_X86_64_PLT32	rt_type_error-0x4
    37c0:	jmp    3937 <botlish_fn_47+0x237>
    37c5:	mov    eax,0x1
    37ca:	test   rcx,0x1
    37d1:	je     37df <botlish_fn_47+0xdf>
    37d7:	mov    r8,rcx
    37da:	jmp    3802 <botlish_fn_47+0x102>
    37df:	xor    eax,eax
    37e1:	test   rcx,0x7
    37e8:	je     37f6 <botlish_fn_47+0xf6>
    37ee:	mov    r8,rcx
    37f1:	jmp    3802 <botlish_fn_47+0x102>
    37f6:	movzx  rax,BYTE PTR [rcx]
    37fa:	mov    r8,rcx
    37fd:	cmp    al,0x1
    37ff:	sete   al
    3802:	test   al,al
    3804:	jne    3825 <botlish_fn_47+0x125>
    380a:	mov    rdi,rbx
    380d:	mov    rax,QWORD PTR [rdi+0x10]
    3811:	mov    rcx,QWORD PTR [rax+0x30]
    3815:	xor    rdx,rdx
    3818:	mov    rsi,r8
    381b:	call   3820 <botlish_fn_47+0x120>
			381c: R_X86_64_PLT32	rt_type_error-0x4
    3820:	jmp    3937 <botlish_fn_47+0x237>
    3825:	mov    rcx,r8
    3828:	mov    rsi,r13
    382b:	mov    rax,rsi
    382e:	and    rax,rcx
    3831:	test   rax,0x1
    3837:	jne    3848 <botlish_fn_47+0x148>
    383d:	mov    rdx,r8
    3840:	mov    rsi,r13
    3843:	jmp    3866 <botlish_fn_47+0x166>
    3848:	mov    rcx,r8
    384b:	lea    rax,[rcx-0x1]
    384f:	mov    rsi,r13
    3852:	add    rsi,rax
    3855:	seto   al
    3858:	test   al,al
    385a:	je     3871 <botlish_fn_47+0x171>
    3860:	mov    rdx,r8
    3863:	mov    rsi,r13
    3866:	mov    rdi,rbx
    3869:	call   386e <botlish_fn_47+0x16e>
			386a: R_X86_64_PLT32	rt_int_add-0x4
    386e:	mov    rsi,rax
    3871:	mov    QWORD PTR [rsp+0x8],rsi
    3876:	mov    QWORD PTR [rsp+0x10],0x3
    387f:	test   rsi,0x1
    3886:	je     38a9 <botlish_fn_47+0x1a9>
    388c:	mov    rax,rsi
    388f:	add    rax,0x2
    3893:	mov    rcx,rax
    3896:	seto   al
    3899:	test   al,al
    389b:	jne    38a9 <botlish_fn_47+0x1a9>
    38a1:	mov    rsi,rcx
    38a4:	jmp    38b9 <botlish_fn_47+0x1b9>
    38a9:	mov    edx,0x3
    38ae:	mov    rdi,rbx
    38b1:	call   38b6 <botlish_fn_47+0x1b6>
			38b2: R_X86_64_PLT32	rt_int_add-0x4
    38b6:	mov    rsi,rax
    38b9:	mov    QWORD PTR [rsp+0x8],rsi
    38be:	mov    edx,0x7
    38c3:	mov    rdi,rdx
    38c6:	mov    QWORD PTR [rsp+0x10],0x7
    38cf:	test   rsi,0x1
    38d6:	jne    38e4 <botlish_fn_47+0x1e4>
    38dc:	mov    rdx,rdi
    38df:	jmp    3910 <botlish_fn_47+0x210>
    38e4:	mov    rax,rsi
    38e7:	sar    rax,1
    38ea:	imul   QWORD PTR [rip+0x117]        # 3a08 <botlish_fn_47+0x308>
    38f1:	seto   cl
    38f4:	or     rax,0x1
    38f8:	test   cl,cl
    38fa:	je     3908 <botlish_fn_47+0x208>
    3900:	mov    rdx,rdi
    3903:	jmp    3910 <botlish_fn_47+0x210>
    3908:	mov    rsi,rax
    390b:	jmp    391b <botlish_fn_47+0x21b>
    3910:	mov    rdi,rbx
    3913:	call   3918 <botlish_fn_47+0x218>
			3914: R_X86_64_PLT32	rt_int_mul-0x4
    3918:	mov    rsi,rax
    391b:	mov    QWORD PTR [rsp+0x8],rsi
    3920:	mov    r13,rsi
    3923:	mov    rsi,r12
    3926:	mov    rdi,rbx
    3929:	call   392e <botlish_fn_47+0x22e>
			392a: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    392e:	test   rax,rax
    3931:	jne    3952 <botlish_fn_47+0x252>
    3937:	xor    rax,rax
    393a:	mov    rbx,QWORD PTR [rsp+0x20]
    393f:	mov    r12,QWORD PTR [rsp+0x28]
    3944:	mov    r13,QWORD PTR [rsp+0x30]
    3949:	add    rsp,0x40
    394d:	mov    rsp,rbp
    3950:	pop    rbp
    3951:	ret
    3952:	mov    QWORD PTR [rsp],rax
    3956:	mov    QWORD PTR [rsp+0x10],0x5
    395f:	test   rax,0x1
    3965:	mov    rsi,rax
    3968:	je     399a <botlish_fn_47+0x29a>
    396e:	mov    rcx,rsi
    3971:	mov    rax,rcx
    3974:	sar    rax,1
    3977:	imul   QWORD PTR [rip+0x92]        # 3a10 <botlish_fn_47+0x310>
    397e:	seto   r9b
    3982:	or     rax,0x1
    3986:	test   r9b,r9b
    3989:	jne    399a <botlish_fn_47+0x29a>
    398f:	mov    rdx,rax
    3992:	mov    rsi,r13
    3995:	jmp    39ad <botlish_fn_47+0x2ad>
    399a:	mov    edx,0x5
    399f:	mov    rdi,rbx
    39a2:	call   39a7 <botlish_fn_47+0x2a7>
			39a3: R_X86_64_PLT32	rt_int_mul-0x4
    39a7:	mov    rdx,rax
    39aa:	mov    rsi,r13
    39ad:	mov    rax,rsi
    39b0:	and    rax,rdx
    39b3:	test   rax,0x1
    39b9:	jne    39e0 <botlish_fn_47+0x2e0>
    39bf:	mov    rdi,rbx
    39c2:	call   39c7 <botlish_fn_47+0x2c7>
			39c3: R_X86_64_PLT32	rt_int_cmp-0x4
    39c7:	mov    r10d,0x2
    39cd:	test   rax,rax
    39d0:	mov    rax,r10
    39d3:	cmovg  rax,QWORD PTR [rip+0x2d]        # 3a08 <botlish_fn_47+0x308>
    39db:	jmp    39f0 <botlish_fn_47+0x2f0>
    39e0:	mov    eax,0x2
    39e5:	cmp    rsi,rdx
    39e8:	cmovg  rax,QWORD PTR [rip+0x18]        # 3a08 <botlish_fn_47+0x308>
    39f0:	mov    rbx,QWORD PTR [rsp+0x20]
    39f5:	mov    r12,QWORD PTR [rsp+0x28]
    39fa:	mov    r13,QWORD PTR [rsp+0x30]
    39ff:	add    rsp,0x40
    3a03:	mov    rsp,rbp
    3a06:	pop    rbp
    3a07:	ret
    3a08:	(bad)
    3a09:	add    BYTE PTR [rax],al
    3a0b:	add    BYTE PTR [rax],al
    3a0d:	add    BYTE PTR [rax],al
    3a0f:	add    BYTE PTR [rax+rax*1],al
    3a12:	add    BYTE PTR [rax],al
    3a14:	add    BYTE PTR [rax],al
	...

0000000000003a18 <botlish_entry_47: ht_should_grow<mutarray>>:
    3a18:	push   rbp
    3a19:	mov    rbp,rsp
    3a1c:	mov    rsi,QWORD PTR [rdx]
    3a1f:	call   3a24 <botlish_entry_47+0xc>
			3a20: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    3a24:	mov    rsp,rbp
    3a27:	pop    rbp
    3a28:	ret
    3a29:	add    BYTE PTR [rax],al
    3a2b:	add    BYTE PTR [rax],al
    3a2d:	add    BYTE PTR [rax],al
	...

0000000000003a30 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    3a30:	push   rbp
    3a31:	mov    rbp,rsp
    3a34:	sub    rsp,0x40
    3a38:	mov    QWORD PTR [rsp+0x20],rbx
    3a3d:	mov    QWORD PTR [rsp+0x28],r12
    3a42:	mov    QWORD PTR [rsp+0x30],r13
    3a47:	mov    rbx,rdi
    3a4a:	mov    QWORD PTR [rsp+0x8],0x0
    3a53:	mov    QWORD PTR [rsp+0x10],0x0
    3a5c:	mov    QWORD PTR [rsp],rsi
    3a60:	mov    r12,rsi
    3a63:	mov    rsi,r12
    3a66:	mov    rdi,rbx
    3a69:	call   3a6e <botlish_fn_48+0x3e>
			3a6a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3a6e:	test   rax,rax
    3a71:	je     3c64 <botlish_fn_48+0x234>
    3a77:	mov    QWORD PTR [rsp+0x8],rax
    3a7c:	mov    r13,rax
    3a7f:	mov    rsi,r12
    3a82:	mov    rdi,rbx
    3a85:	call   3a8a <botlish_fn_48+0x5a>
			3a86: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    3a8a:	mov    rcx,rax
    3a8d:	test   rcx,rcx
    3a90:	je     3c64 <botlish_fn_48+0x234>
    3a96:	mov    edx,0x1
    3a9b:	mov    rax,r13
    3a9e:	test   rax,0x1
    3aa4:	je     3ab2 <botlish_fn_48+0x82>
    3aaa:	mov    r13,rax
    3aad:	jmp    3ad6 <botlish_fn_48+0xa6>
    3ab2:	xor    edx,edx
    3ab4:	test   rax,0x7
    3aba:	je     3ac8 <botlish_fn_48+0x98>
    3ac0:	mov    r13,rax
    3ac3:	jmp    3ad6 <botlish_fn_48+0xa6>
    3ac8:	movzx  rdx,BYTE PTR [rax]
    3acc:	mov    r13,rax
    3acf:	rex cmp dl,0x1
    3ad3:	sete   dl
    3ad6:	test   dl,dl
    3ad8:	jne    3af9 <botlish_fn_48+0xc9>
    3ade:	mov    rdi,rbx
    3ae1:	mov    rsi,QWORD PTR [rdi+0x10]
    3ae5:	mov    rcx,QWORD PTR [rsi+0x38]
    3ae9:	xor    rdx,rdx
    3aec:	mov    rsi,r13
    3aef:	call   3af4 <botlish_fn_48+0xc4>
			3af0: R_X86_64_PLT32	rt_type_error-0x4
    3af4:	jmp    3c64 <botlish_fn_48+0x234>
    3af9:	mov    rsi,r13
    3afc:	mov    eax,0x1
    3b01:	test   rcx,0x1
    3b08:	je     3b16 <botlish_fn_48+0xe6>
    3b0e:	mov    r8,rcx
    3b11:	jmp    3b39 <botlish_fn_48+0x109>
    3b16:	xor    eax,eax
    3b18:	test   rcx,0x7
    3b1f:	je     3b2d <botlish_fn_48+0xfd>
    3b25:	mov    r8,rcx
    3b28:	jmp    3b39 <botlish_fn_48+0x109>
    3b2d:	movzx  rax,BYTE PTR [rcx]
    3b31:	mov    r8,rcx
    3b34:	cmp    al,0x1
    3b36:	sete   al
    3b39:	test   al,al
    3b3b:	jne    3b5c <botlish_fn_48+0x12c>
    3b41:	mov    rdi,rbx
    3b44:	mov    rax,QWORD PTR [rdi+0x10]
    3b48:	mov    rcx,QWORD PTR [rax+0x38]
    3b4c:	xor    rdx,rdx
    3b4f:	mov    rsi,r8
    3b52:	call   3b57 <botlish_fn_48+0x127>
			3b53: R_X86_64_PLT32	rt_type_error-0x4
    3b57:	jmp    3c64 <botlish_fn_48+0x234>
    3b5c:	mov    rcx,r8
    3b5f:	mov    rax,rsi
    3b62:	and    rax,rcx
    3b65:	test   rax,0x1
    3b6b:	jne    3b91 <botlish_fn_48+0x161>
    3b71:	mov    rdx,r8
    3b74:	mov    rdi,rbx
    3b77:	call   3b7c <botlish_fn_48+0x14c>
			3b78: R_X86_64_PLT32	rt_int_cmp-0x4
    3b7c:	mov    ecx,0x2
    3b81:	test   rax,rax
    3b84:	cmovg  rcx,QWORD PTR [rip+0x10c]        # 3c98 <botlish_fn_48+0x268>
    3b8c:	jmp    3ba4 <botlish_fn_48+0x174>
    3b91:	mov    ecx,0x2
    3b96:	mov    r11,r8
    3b99:	cmp    rsi,r11
    3b9c:	cmovg  rcx,QWORD PTR [rip+0xf4]        # 3c98 <botlish_fn_48+0x268>
    3ba4:	cmp    rcx,0x6
    3ba8:	je     3c34 <botlish_fn_48+0x204>
    3bae:	mov    rsi,r12
    3bb1:	mov    rdi,rbx
    3bb4:	call   3bb9 <botlish_fn_48+0x189>
			3bb5: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3bb9:	test   rax,rax
    3bbc:	je     3c64 <botlish_fn_48+0x234>
    3bc2:	mov    QWORD PTR [rsp+0x8],rax
    3bc7:	mov    QWORD PTR [rsp+0x10],0x5
    3bd0:	test   rax,0x1
    3bd6:	mov    rsi,rax
    3bd9:	je     3c06 <botlish_fn_48+0x1d6>
    3bdf:	mov    rcx,rsi
    3be2:	mov    rax,rcx
    3be5:	sar    rax,1
    3be8:	imul   QWORD PTR [rip+0xb1]        # 3ca0 <botlish_fn_48+0x270>
    3bef:	seto   cl
    3bf2:	or     rax,0x1
    3bf6:	test   cl,cl
    3bf8:	jne    3c06 <botlish_fn_48+0x1d6>
    3bfe:	mov    rdx,rax
    3c01:	jmp    3c16 <botlish_fn_48+0x1e6>
    3c06:	mov    edx,0x5
    3c0b:	mov    rdi,rbx
    3c0e:	call   3c13 <botlish_fn_48+0x1e3>
			3c0f: R_X86_64_PLT32	rt_int_mul-0x4
    3c13:	mov    rdx,rax
    3c16:	mov    QWORD PTR [rsp+0x8],rdx
    3c1b:	mov    rsi,r12
    3c1e:	mov    rdi,rbx
    3c21:	call   3c26 <botlish_fn_48+0x1f6>
			3c22: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    3c26:	test   rax,rax
    3c29:	je     3c64 <botlish_fn_48+0x234>
    3c2f:	jmp    3c7f <botlish_fn_48+0x24f>
    3c34:	mov    rsi,r12
    3c37:	mov    rdi,rbx
    3c3a:	call   3c3f <botlish_fn_48+0x20f>
			3c3b: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3c3f:	test   rax,rax
    3c42:	je     3c64 <botlish_fn_48+0x234>
    3c48:	mov    QWORD PTR [rsp+0x8],rax
    3c4d:	mov    rdx,rax
    3c50:	mov    rsi,r12
    3c53:	mov    rdi,rbx
    3c56:	call   3c5b <botlish_fn_48+0x22b>
			3c57: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    3c5b:	test   rax,rax
    3c5e:	jne    3c7f <botlish_fn_48+0x24f>
    3c64:	xor    rax,rax
    3c67:	mov    rbx,QWORD PTR [rsp+0x20]
    3c6c:	mov    r12,QWORD PTR [rsp+0x28]
    3c71:	mov    r13,QWORD PTR [rsp+0x30]
    3c76:	add    rsp,0x40
    3c7a:	mov    rsp,rbp
    3c7d:	pop    rbp
    3c7e:	ret
    3c7f:	mov    rbx,QWORD PTR [rsp+0x20]
    3c84:	mov    r12,QWORD PTR [rsp+0x28]
    3c89:	mov    r13,QWORD PTR [rsp+0x30]
    3c8e:	add    rsp,0x40
    3c92:	mov    rsp,rbp
    3c95:	pop    rbp
    3c96:	ret
    3c97:	add    BYTE PTR [rsi],al
    3c99:	add    BYTE PTR [rax],al
    3c9b:	add    BYTE PTR [rax],al
    3c9d:	add    BYTE PTR [rax],al
    3c9f:	add    BYTE PTR [rax+rax*1],al
    3ca2:	add    BYTE PTR [rax],al
    3ca4:	add    BYTE PTR [rax],al
	...

0000000000003ca8 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    3ca8:	push   rbp
    3ca9:	mov    rbp,rsp
    3cac:	mov    rsi,QWORD PTR [rdx]
    3caf:	call   3cb4 <botlish_entry_48+0xc>
			3cb0: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    3cb4:	mov    rsp,rbp
    3cb7:	pop    rbp
    3cb8:	ret
    3cb9:	add    BYTE PTR [rax],al
    3cbb:	add    BYTE PTR [rax],al
    3cbd:	add    BYTE PTR [rax],al
	...

0000000000003cc0 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    3cc0:	push   rbp
    3cc1:	mov    rbp,rsp
    3cc4:	sub    rsp,0x70
    3cc8:	mov    QWORD PTR [rsp+0x40],rbx
    3ccd:	mov    QWORD PTR [rsp+0x48],r12
    3cd2:	mov    QWORD PTR [rsp+0x50],r13
    3cd7:	mov    QWORD PTR [rsp+0x58],r14
    3cdc:	mov    QWORD PTR [rsp+0x60],r15
    3ce1:	mov    rbx,rdi
    3ce4:	mov    QWORD PTR [rsp+0x20],0x0
    3ced:	mov    QWORD PTR [rsp+0x28],0x0
    3cf6:	mov    QWORD PTR [rsp],rsi
    3cfa:	mov    r12,rsi
    3cfd:	mov    QWORD PTR [rsp+0x8],rdx
    3d02:	mov    r15,rdx
    3d05:	mov    QWORD PTR [rsp+0x10],rcx
    3d0a:	mov    QWORD PTR [rsp+0x30],rcx
    3d0f:	mov    QWORD PTR [rsp+0x18],r8
    3d14:	mov    r14,r8
    3d17:	mov    rsi,r12
    3d1a:	mov    rdi,rbx
    3d1d:	call   3d22 <botlish_fn_49+0x62>
			3d1e: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    3d22:	test   rax,rax
    3d25:	je     40be <botlish_fn_49+0x3fe>
    3d2b:	mov    QWORD PTR [rsp+0x20],rax
    3d30:	xor    ecx,ecx
    3d32:	test   rax,0x7
    3d38:	je     3d48 <botlish_fn_49+0x88>
    3d3e:	mov    QWORD PTR [rsp+0x38],rax
    3d43:	jmp    3d58 <botlish_fn_49+0x98>
    3d48:	movzx  rcx,BYTE PTR [rax]
    3d4c:	mov    QWORD PTR [rsp+0x38],rax
    3d51:	rex cmp cl,0x8
    3d55:	sete   cl
    3d58:	test   cl,cl
    3d5a:	jne    3d7f <botlish_fn_49+0xbf>
    3d60:	mov    rdi,rbx
    3d63:	mov    rax,QWORD PTR [rdi+0x10]
    3d67:	mov    rcx,QWORD PTR [rax+0x20]
    3d6b:	mov    edx,0x8
    3d70:	mov    rsi,QWORD PTR [rsp+0x38]
    3d75:	call   3d7a <botlish_fn_49+0xba>
			3d76: R_X86_64_PLT32	rt_type_error-0x4
    3d7a:	jmp    40be <botlish_fn_49+0x3fe>
    3d7f:	mov    rdx,r15
    3d82:	mov    rsi,QWORD PTR [rsp+0x38]
    3d87:	mov    rdi,rbx
    3d8a:	call   3d8f <botlish_fn_49+0xcf>
			3d8b: R_X86_64_PLT32	rt_mutarray_get-0x4
    3d8f:	test   rax,rax
    3d92:	je     40be <botlish_fn_49+0x3fe>
    3d98:	mov    QWORD PTR [rsp+0x28],rax
    3d9d:	mov    r13,rax
    3da0:	mov    rdi,rbx
    3da3:	call   3da8 <botlish_fn_49+0xe8>
			3da4: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3da8:	test   rax,rax
    3dab:	mov    rcx,rax
    3dae:	je     40be <botlish_fn_49+0x3fe>
    3db4:	mov    rsi,QWORD PTR [rsp+0x38]
    3db9:	mov    rdx,r15
    3dbc:	mov    rdi,rbx
    3dbf:	call   3dc4 <botlish_fn_49+0x104>
			3dc0: R_X86_64_PLT32	rt_mutarray_set-0x4
    3dc4:	test   rax,rax
    3dc7:	je     40be <botlish_fn_49+0x3fe>
    3dcd:	mov    rsi,r12
    3dd0:	mov    rdi,rbx
    3dd3:	call   3dd8 <botlish_fn_49+0x118>
			3dd4: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    3dd8:	test   rax,rax
    3ddb:	je     40be <botlish_fn_49+0x3fe>
    3de1:	xor    ecx,ecx
    3de3:	test   rax,0x7
    3de9:	je     3df7 <botlish_fn_49+0x137>
    3def:	mov    rsi,rax
    3df2:	jmp    3e05 <botlish_fn_49+0x145>
    3df7:	movzx  rcx,BYTE PTR [rax]
    3dfb:	mov    rsi,rax
    3dfe:	rex cmp cl,0x8
    3e02:	sete   cl
    3e05:	test   cl,cl
    3e07:	jne    3e27 <botlish_fn_49+0x167>
    3e0d:	mov    rdi,rbx
    3e10:	mov    rcx,QWORD PTR [rdi+0x10]
    3e14:	mov    rcx,QWORD PTR [rcx+0x40]
    3e18:	mov    edx,0x8
    3e1d:	call   3e22 <botlish_fn_49+0x162>
			3e1e: R_X86_64_PLT32	rt_type_error-0x4
    3e22:	jmp    40be <botlish_fn_49+0x3fe>
    3e27:	mov    rcx,QWORD PTR [rsp+0x30]
    3e2c:	mov    rdx,r15
    3e2f:	mov    rdi,rbx
    3e32:	call   3e37 <botlish_fn_49+0x177>
			3e33: R_X86_64_PLT32	rt_mutarray_set-0x4
    3e37:	test   rax,rax
    3e3a:	je     40be <botlish_fn_49+0x3fe>
    3e40:	mov    rsi,r12
    3e43:	mov    rdi,rbx
    3e46:	call   3e4b <botlish_fn_49+0x18b>
			3e47: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    3e4b:	test   rax,rax
    3e4e:	je     40be <botlish_fn_49+0x3fe>
    3e54:	xor    ecx,ecx
    3e56:	test   rax,0x7
    3e5c:	je     3e6a <botlish_fn_49+0x1aa>
    3e62:	mov    rsi,rax
    3e65:	jmp    3e78 <botlish_fn_49+0x1b8>
    3e6a:	movzx  r11,BYTE PTR [rax]
    3e6e:	mov    rsi,rax
    3e71:	cmp    r11b,0x8
    3e75:	sete   cl
    3e78:	test   cl,cl
    3e7a:	jne    3e9a <botlish_fn_49+0x1da>
    3e80:	mov    rdi,rbx
    3e83:	mov    rax,QWORD PTR [rdi+0x10]
    3e87:	mov    rcx,QWORD PTR [rax+0x40]
    3e8b:	mov    edx,0x8
    3e90:	call   3e95 <botlish_fn_49+0x1d5>
			3e91: R_X86_64_PLT32	rt_type_error-0x4
    3e95:	jmp    40be <botlish_fn_49+0x3fe>
    3e9a:	mov    rcx,r14
    3e9d:	mov    rdx,r15
    3ea0:	mov    rdi,rbx
    3ea3:	call   3ea8 <botlish_fn_49+0x1e8>
			3ea4: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ea8:	test   rax,rax
    3eab:	je     40be <botlish_fn_49+0x3fe>
    3eb1:	mov    QWORD PTR [rsp+0x8],0x7
    3eba:	mov    rsi,r12
    3ebd:	mov    rdi,rbx
    3ec0:	call   3ec5 <botlish_fn_49+0x205>
			3ec1: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    3ec5:	test   rax,rax
    3ec8:	je     40be <botlish_fn_49+0x3fe>
    3ece:	mov    QWORD PTR [rsp+0x10],rax
    3ed3:	mov    QWORD PTR [rsp+0x18],0x3
    3edc:	mov    ecx,0x1
    3ee1:	test   rax,0x1
    3ee7:	je     3ef5 <botlish_fn_49+0x235>
    3eed:	mov    rsi,rax
    3ef0:	jmp    3f19 <botlish_fn_49+0x259>
    3ef5:	xor    ecx,ecx
    3ef7:	test   rax,0x7
    3efd:	je     3f0b <botlish_fn_49+0x24b>
    3f03:	mov    rsi,rax
    3f06:	jmp    3f19 <botlish_fn_49+0x259>
    3f0b:	movzx  rcx,BYTE PTR [rax]
    3f0f:	mov    rsi,rax
    3f12:	rex cmp cl,0x1
    3f16:	sete   cl
    3f19:	test   cl,cl
    3f1b:	jne    3f39 <botlish_fn_49+0x279>
    3f21:	mov    rdi,rbx
    3f24:	mov    rax,QWORD PTR [rdi+0x10]
    3f28:	mov    rcx,QWORD PTR [rax+0x30]
    3f2c:	xor    rdx,rdx
    3f2f:	call   3f34 <botlish_fn_49+0x274>
			3f30: R_X86_64_PLT32	rt_type_error-0x4
    3f34:	jmp    40be <botlish_fn_49+0x3fe>
    3f39:	test   rsi,0x1
    3f40:	je     3f58 <botlish_fn_49+0x298>
    3f46:	mov    rcx,rsi
    3f49:	add    rcx,0x2
    3f4d:	seto   al
    3f50:	test   al,al
    3f52:	je     3f68 <botlish_fn_49+0x2a8>
    3f58:	mov    edx,0x3
    3f5d:	mov    rdi,rbx
    3f60:	call   3f65 <botlish_fn_49+0x2a5>
			3f61: R_X86_64_PLT32	rt_int_add-0x4
    3f65:	mov    rcx,rax
    3f68:	mov    edx,0x7
    3f6d:	mov    rsi,r12
    3f70:	mov    rdi,rbx
    3f73:	call   3f78 <botlish_fn_49+0x2b8>
			3f74: R_X86_64_PLT32	rt_mutarray_set-0x4
    3f78:	test   rax,rax
    3f7b:	je     40be <botlish_fn_49+0x3fe>
    3f81:	mov    rdi,rbx
    3f84:	call   3f89 <botlish_fn_49+0x2c9>
			3f85: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3f89:	test   rax,rax
    3f8c:	je     40be <botlish_fn_49+0x3fe>
    3f92:	mov    rcx,r13
    3f95:	mov    rdx,rcx
    3f98:	and    rdx,rax
    3f9b:	mov    rsi,rax
    3f9e:	test   rdx,0x1
    3fa5:	jne    3fc7 <botlish_fn_49+0x307>
    3fab:	mov    rdx,rsi
    3fae:	mov    rsi,r13
    3fb1:	mov    rdi,rbx
    3fb4:	call   3fb9 <botlish_fn_49+0x2f9>
			3fb5: R_X86_64_PLT32	rt_value_eq-0x4
    3fb9:	test   rax,rax
    3fbc:	je     40be <botlish_fn_49+0x3fe>
    3fc2:	jmp    3fdd <botlish_fn_49+0x31d>
    3fc7:	mov    rdx,rsi
    3fca:	mov    rsi,r13
    3fcd:	mov    eax,0x2
    3fd2:	cmp    rsi,rdx
    3fd5:	cmove  rax,QWORD PTR [rip+0x133]        # 4110 <botlish_fn_49+0x450>
    3fdd:	cmp    rax,0x6
    3fe1:	jne    40e3 <botlish_fn_49+0x423>
    3fe7:	mov    QWORD PTR [rsp+0x8],0x9
    3ff0:	mov    rsi,r12
    3ff3:	mov    rdi,rbx
    3ff6:	call   3ffb <botlish_fn_49+0x33b>
			3ff7: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3ffb:	test   rax,rax
    3ffe:	je     40be <botlish_fn_49+0x3fe>
    4004:	mov    QWORD PTR [rsp+0x10],rax
    4009:	mov    QWORD PTR [rsp+0x18],0x3
    4012:	mov    ecx,0x1
    4017:	test   rax,0x1
    401d:	je     402b <botlish_fn_49+0x36b>
    4023:	mov    rsi,rax
    4026:	jmp    404f <botlish_fn_49+0x38f>
    402b:	xor    ecx,ecx
    402d:	test   rax,0x7
    4033:	je     4041 <botlish_fn_49+0x381>
    4039:	mov    rsi,rax
    403c:	jmp    404f <botlish_fn_49+0x38f>
    4041:	movzx  r10,BYTE PTR [rax]
    4045:	mov    rsi,rax
    4048:	cmp    r10b,0x1
    404c:	sete   cl
    404f:	test   cl,cl
    4051:	jne    406f <botlish_fn_49+0x3af>
    4057:	mov    rdi,rbx
    405a:	mov    rax,QWORD PTR [rdi+0x10]
    405e:	mov    rcx,QWORD PTR [rax+0x48]
    4062:	xor    rdx,rdx
    4065:	call   406a <botlish_fn_49+0x3aa>
			4066: R_X86_64_PLT32	rt_type_error-0x4
    406a:	jmp    40be <botlish_fn_49+0x3fe>
    406f:	test   rsi,0x1
    4076:	je     4095 <botlish_fn_49+0x3d5>
    407c:	mov    rcx,rsi
    407f:	sub    rcx,0x3
    4083:	seto   al
    4086:	add    rcx,0x1
    408d:	test   al,al
    408f:	je     40a5 <botlish_fn_49+0x3e5>
    4095:	mov    edx,0x3
    409a:	mov    rdi,rbx
    409d:	call   40a2 <botlish_fn_49+0x3e2>
			409e: R_X86_64_PLT32	rt_int_sub-0x4
    40a2:	mov    rcx,rax
    40a5:	mov    edx,0x9
    40aa:	mov    rsi,r12
    40ad:	mov    rdi,rbx
    40b0:	call   40b5 <botlish_fn_49+0x3f5>
			40b1: R_X86_64_PLT32	rt_mutarray_set-0x4
    40b5:	test   rax,rax
    40b8:	jne    40e3 <botlish_fn_49+0x423>
    40be:	xor    rax,rax
    40c1:	mov    rbx,QWORD PTR [rsp+0x40]
    40c6:	mov    r12,QWORD PTR [rsp+0x48]
    40cb:	mov    r13,QWORD PTR [rsp+0x50]
    40d0:	mov    r14,QWORD PTR [rsp+0x58]
    40d5:	mov    r15,QWORD PTR [rsp+0x60]
    40da:	add    rsp,0x70
    40de:	mov    rsp,rbp
    40e1:	pop    rbp
    40e2:	ret
    40e3:	mov    eax,0xa
    40e8:	mov    rbx,QWORD PTR [rsp+0x40]
    40ed:	mov    r12,QWORD PTR [rsp+0x48]
    40f2:	mov    r13,QWORD PTR [rsp+0x50]
    40f7:	mov    r14,QWORD PTR [rsp+0x58]
    40fc:	mov    r15,QWORD PTR [rsp+0x60]
    4101:	add    rsp,0x70
    4105:	mov    rsp,rbp
    4108:	pop    rbp
    4109:	ret
    410a:	add    BYTE PTR [rax],al
    410c:	add    BYTE PTR [rax],al
    410e:	add    BYTE PTR [rax],al
    4110:	(bad)
    4111:	add    BYTE PTR [rax],al
    4113:	add    BYTE PTR [rax],al
    4115:	add    BYTE PTR [rax],al
	...

0000000000004118 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    4118:	push   rbp
    4119:	mov    rbp,rsp
    411c:	mov    rsi,QWORD PTR [rdx]
    411f:	mov    r9,QWORD PTR [rdx+0x8]
    4123:	mov    rcx,QWORD PTR [rdx+0x10]
    4127:	mov    r8,QWORD PTR [rdx+0x18]
    412b:	mov    rdx,r9
    412e:	call   4133 <botlish_entry_49+0x1b>
			412f: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    4133:	mov    rsp,rbp
    4136:	pop    rbp
    4137:	ret

0000000000004138 <botlish_fn_50: ht_set<mutarray, any, any>>:
    4138:	push   rbp
    4139:	mov    rbp,rsp
    413c:	sub    rsp,0x70
    4140:	mov    QWORD PTR [rsp+0x40],rbx
    4145:	mov    QWORD PTR [rsp+0x48],r12
    414a:	mov    QWORD PTR [rsp+0x50],r13
    414f:	mov    QWORD PTR [rsp+0x58],r14
    4154:	mov    QWORD PTR [rsp+0x60],r15
    4159:	mov    rbx,rdi
    415c:	mov    QWORD PTR [rsp+0x18],0x0
    4165:	mov    QWORD PTR [rsp+0x20],0x0
    416e:	mov    QWORD PTR [rsp],rsi
    4172:	mov    r14,rsi
    4175:	mov    QWORD PTR [rsp+0x8],rdx
    417a:	mov    r13,rdx
    417d:	mov    QWORD PTR [rsp+0x10],rcx
    4182:	mov    r12,rcx
    4185:	mov    rdx,r13
    4188:	mov    rsi,r14
    418b:	mov    rdi,rbx
    418e:	call   4193 <botlish_fn_50+0x5b>
			418f: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    4193:	test   rax,rax
    4196:	je     442f <botlish_fn_50+0x2f7>
    419c:	mov    QWORD PTR [rsp+0x18],rax
    41a1:	mov    rcx,rax
    41a4:	mov    r8,0xffffffffffffffff
    41ab:	mov    QWORD PTR [rsp+0x30],r8
    41b0:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    41b9:	mov    rdx,r13
    41bc:	mov    rsi,r14
    41bf:	mov    rdi,rbx
    41c2:	call   41c7 <botlish_fn_50+0x8f>
			41c3: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    41c7:	mov    rcx,rax
    41ca:	mov    r15,rax
    41cd:	test   rax,rcx
    41d0:	je     442f <botlish_fn_50+0x2f7>
    41d6:	mov    rax,r15
    41d9:	mov    QWORD PTR [rsp+0x18],rax
    41de:	mov    rsi,r14
    41e1:	mov    rdi,rbx
    41e4:	call   41e9 <botlish_fn_50+0xb1>
			41e5: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    41e9:	test   rax,rax
    41ec:	je     442f <botlish_fn_50+0x2f7>
    41f2:	xor    ecx,ecx
    41f4:	test   rax,0x7
    41fa:	je     4208 <botlish_fn_50+0xd0>
    4200:	mov    r8,rax
    4203:	jmp    4216 <botlish_fn_50+0xde>
    4208:	movzx  rdx,BYTE PTR [rax]
    420c:	mov    r8,rax
    420f:	rex cmp dl,0x8
    4213:	sete   cl
    4216:	test   cl,cl
    4218:	jne    423b <botlish_fn_50+0x103>
    421e:	mov    rdi,rbx
    4221:	mov    rsi,QWORD PTR [rdi+0x10]
    4225:	mov    rcx,QWORD PTR [rsi+0x20]
    4229:	mov    edx,0x8
    422e:	mov    rsi,r8
    4231:	call   4236 <botlish_fn_50+0xfe>
			4232: R_X86_64_PLT32	rt_type_error-0x4
    4236:	jmp    442f <botlish_fn_50+0x2f7>
    423b:	mov    rsi,r8
    423e:	mov    rdx,r15
    4241:	mov    rdi,rbx
    4244:	call   4249 <botlish_fn_50+0x111>
			4245: R_X86_64_PLT32	rt_mutarray_get-0x4
    4249:	test   rax,rax
    424c:	je     442f <botlish_fn_50+0x2f7>
    4252:	mov    QWORD PTR [rsp+0x20],rax
    4257:	mov    QWORD PTR [rsp+0x28],rax
    425c:	mov    rdi,rbx
    425f:	call   4264 <botlish_fn_50+0x12c>
			4260: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    4264:	test   rax,rax
    4267:	je     442f <botlish_fn_50+0x2f7>
    426d:	mov    rcx,QWORD PTR [rsp+0x28]
    4272:	mov    rdx,rcx
    4275:	and    rdx,rax
    4278:	test   rdx,0x1
    427f:	jne    42a3 <botlish_fn_50+0x16b>
    4285:	mov    rdx,rax
    4288:	mov    rsi,QWORD PTR [rsp+0x28]
    428d:	mov    rdi,rbx
    4290:	call   4295 <botlish_fn_50+0x15d>
			4291: R_X86_64_PLT32	rt_value_eq-0x4
    4295:	test   rax,rax
    4298:	je     442f <botlish_fn_50+0x2f7>
    429e:	jmp    42bb <botlish_fn_50+0x183>
    42a3:	mov    rdx,rax
    42a6:	mov    rsi,QWORD PTR [rsp+0x28]
    42ab:	mov    eax,0x2
    42b0:	cmp    rsi,rdx
    42b3:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4480 <botlish_fn_50+0x348>
    42bb:	cmp    rax,0x6
    42bf:	je     43be <botlish_fn_50+0x286>
    42c5:	mov    rsi,r14
    42c8:	mov    rdi,rbx
    42cb:	call   42d0 <botlish_fn_50+0x198>
			42cc: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    42d0:	test   rax,rax
    42d3:	je     442f <botlish_fn_50+0x2f7>
    42d9:	cmp    rax,0x6
    42dd:	je     4322 <botlish_fn_50+0x1ea>
    42e3:	mov    rcx,r13
    42e6:	mov    rdx,r15
    42e9:	mov    rsi,r14
    42ec:	mov    rdi,rbx
    42ef:	mov    r8,r12
    42f2:	call   42f7 <botlish_fn_50+0x1bf>
			42f3: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    42f7:	test   rax,rax
    42fa:	je     442f <botlish_fn_50+0x2f7>
    4300:	mov    rbx,QWORD PTR [rsp+0x40]
    4305:	mov    r12,QWORD PTR [rsp+0x48]
    430a:	mov    r13,QWORD PTR [rsp+0x50]
    430f:	mov    r14,QWORD PTR [rsp+0x58]
    4314:	mov    r15,QWORD PTR [rsp+0x60]
    4319:	add    rsp,0x70
    431d:	mov    rsp,rbp
    4320:	pop    rbp
    4321:	ret
    4322:	mov    rsi,r14
    4325:	mov    rdi,rbx
    4328:	call   432d <botlish_fn_50+0x1f5>
			4329: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    432d:	test   rax,rax
    4330:	je     442f <botlish_fn_50+0x2f7>
    4336:	mov    rdx,r13
    4339:	mov    rsi,r14
    433c:	mov    rdi,rbx
    433f:	call   4344 <botlish_fn_50+0x20c>
			4340: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    4344:	test   rax,rax
    4347:	je     442f <botlish_fn_50+0x2f7>
    434d:	mov    QWORD PTR [rsp+0x18],rax
    4352:	mov    rcx,rax
    4355:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    435e:	mov    r8,QWORD PTR [rsp+0x30]
    4363:	mov    rdx,r13
    4366:	mov    rsi,r14
    4369:	mov    rdi,rbx
    436c:	call   4371 <botlish_fn_50+0x239>
			436d: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    4371:	test   rax,rax
    4374:	je     442f <botlish_fn_50+0x2f7>
    437a:	mov    QWORD PTR [rsp+0x18],rax
    437f:	mov    rcx,r13
    4382:	mov    rdx,rax
    4385:	mov    rsi,r14
    4388:	mov    rdi,rbx
    438b:	mov    r8,r12
    438e:	call   4393 <botlish_fn_50+0x25b>
			438f: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    4393:	test   rax,rax
    4396:	je     442f <botlish_fn_50+0x2f7>
    439c:	mov    rbx,QWORD PTR [rsp+0x40]
    43a1:	mov    r12,QWORD PTR [rsp+0x48]
    43a6:	mov    r13,QWORD PTR [rsp+0x50]
    43ab:	mov    r14,QWORD PTR [rsp+0x58]
    43b0:	mov    r15,QWORD PTR [rsp+0x60]
    43b5:	add    rsp,0x70
    43b9:	mov    rsp,rbp
    43bc:	pop    rbp
    43bd:	ret
    43be:	mov    rsi,r14
    43c1:	mov    rdi,rbx
    43c4:	call   43c9 <botlish_fn_50+0x291>
			43c5: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    43c9:	test   rax,rax
    43cc:	je     442f <botlish_fn_50+0x2f7>
    43d2:	xor    ecx,ecx
    43d4:	test   rax,0x7
    43da:	je     43e8 <botlish_fn_50+0x2b0>
    43e0:	mov    rsi,rax
    43e3:	jmp    43f6 <botlish_fn_50+0x2be>
    43e8:	movzx  rcx,BYTE PTR [rax]
    43ec:	mov    rsi,rax
    43ef:	rex cmp cl,0x8
    43f3:	sete   cl
    43f6:	test   cl,cl
    43f8:	jne    4418 <botlish_fn_50+0x2e0>
    43fe:	mov    rdi,rbx
    4401:	mov    rax,QWORD PTR [rdi+0x10]
    4405:	mov    rcx,QWORD PTR [rax+0x40]
    4409:	mov    edx,0x8
    440e:	call   4413 <botlish_fn_50+0x2db>
			440f: R_X86_64_PLT32	rt_type_error-0x4
    4413:	jmp    442f <botlish_fn_50+0x2f7>
    4418:	mov    rcx,r12
    441b:	mov    rdx,r15
    441e:	mov    rdi,rbx
    4421:	call   4426 <botlish_fn_50+0x2ee>
			4422: R_X86_64_PLT32	rt_mutarray_set-0x4
    4426:	test   rax,rax
    4429:	jne    4454 <botlish_fn_50+0x31c>
    442f:	xor    rax,rax
    4432:	mov    rbx,QWORD PTR [rsp+0x40]
    4437:	mov    r12,QWORD PTR [rsp+0x48]
    443c:	mov    r13,QWORD PTR [rsp+0x50]
    4441:	mov    r14,QWORD PTR [rsp+0x58]
    4446:	mov    r15,QWORD PTR [rsp+0x60]
    444b:	add    rsp,0x70
    444f:	mov    rsp,rbp
    4452:	pop    rbp
    4453:	ret
    4454:	mov    eax,0xa
    4459:	mov    rbx,QWORD PTR [rsp+0x40]
    445e:	mov    r12,QWORD PTR [rsp+0x48]
    4463:	mov    r13,QWORD PTR [rsp+0x50]
    4468:	mov    r14,QWORD PTR [rsp+0x58]
    446d:	mov    r15,QWORD PTR [rsp+0x60]
    4472:	add    rsp,0x70
    4476:	mov    rsp,rbp
    4479:	pop    rbp
    447a:	ret
    447b:	add    BYTE PTR [rax],al
    447d:	add    BYTE PTR [rax],al
    447f:	add    BYTE PTR [rsi],al
    4481:	add    BYTE PTR [rax],al
    4483:	add    BYTE PTR [rax],al
    4485:	add    BYTE PTR [rax],al
	...

0000000000004488 <botlish_entry_50: ht_set<mutarray, any, any>>:
    4488:	push   rbp
    4489:	mov    rbp,rsp
    448c:	mov    rsi,QWORD PTR [rdx]
    448f:	mov    r8,QWORD PTR [rdx+0x8]
    4493:	mov    rcx,QWORD PTR [rdx+0x10]
    4497:	mov    rdx,r8
    449a:	call   449f <botlish_entry_50+0x17>
			449b: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    449f:	mov    rsp,rbp
    44a2:	pop    rbp
    44a3:	ret

00000000000044a4 <botlish_fn_51: row_new<bool, int>>:
    44a4:	push   rbp
    44a5:	mov    rbp,rsp
    44a8:	sub    rsp,0x10
    44ac:	mov    QWORD PTR [rsp],rdx
    44b0:	mov    r8,rdx
    44b3:	cmp    rsi,0x6
    44b7:	je     44d4 <botlish_fn_51+0x30>
    44bd:	call   44c2 <botlish_fn_51+0x1e>
			44be: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    44c2:	test   rax,rax
    44c5:	je     44e5 <botlish_fn_51+0x41>
    44cb:	add    rsp,0x10
    44cf:	mov    rsp,rbp
    44d2:	pop    rbp
    44d3:	ret
    44d4:	mov    rsi,r8
    44d7:	call   44dc <botlish_fn_51+0x38>
			44d8: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    44dc:	test   rax,rax
    44df:	jne    44f1 <botlish_fn_51+0x4d>
    44e5:	xor    rax,rax
    44e8:	add    rsp,0x10
    44ec:	mov    rsp,rbp
    44ef:	pop    rbp
    44f0:	ret
    44f1:	add    rsp,0x10
    44f5:	mov    rsp,rbp
    44f8:	pop    rbp
    44f9:	ret

00000000000044fa <botlish_entry_51: row_new<bool, int>>:
    44fa:	push   rbp
    44fb:	mov    rbp,rsp
    44fe:	mov    rsi,QWORD PTR [rdx]
    4501:	mov    rdx,QWORD PTR [rdx+0x8]
    4505:	call   450a <botlish_entry_51+0x10>
			4506: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    450a:	mov    rsp,rbp
    450d:	pop    rbp
    450e:	ret
	...

0000000000004510 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    4510:	push   rbp
    4511:	mov    rbp,rsp
    4514:	sub    rsp,0x70
    4518:	mov    QWORD PTR [rsp+0x40],rbx
    451d:	mov    QWORD PTR [rsp+0x48],r12
    4522:	mov    QWORD PTR [rsp+0x50],r13
    4527:	mov    QWORD PTR [rsp+0x58],r14
    452c:	mov    QWORD PTR [rsp+0x60],r15
    4531:	mov    rbx,rdx
    4534:	mov    r15,rdi
    4537:	mov    QWORD PTR [rsp],rsi
    453b:	mov    r13,rsi
    453e:	mov    QWORD PTR [rsp+0x8],rdx
    4543:	mov    QWORD PTR [rsp+0x10],rcx
    4548:	mov    QWORD PTR [rsp+0x30],rcx
    454d:	mov    QWORD PTR [rsp+0x18],r8
    4552:	mov    r14,r9
    4555:	mov    rax,r14
    4558:	or     rax,0x1
    455c:	mov    r12,r8
    455f:	mov    rcx,r12
    4562:	and    rcx,rax
    4565:	test   rcx,0x1
    456c:	jne    4599 <botlish_fn_52+0x89>
    4572:	mov    rdx,r14
    4575:	or     rdx,0x1
    4579:	mov    rsi,r12
    457c:	mov    rdi,r15
    457f:	call   4584 <botlish_fn_52+0x74>
			4580: R_X86_64_PLT32	rt_int_cmp-0x4
    4584:	mov    ecx,0x2
    4589:	test   rax,rax
    458c:	cmovge rcx,QWORD PTR [rip+0x20c]        # 47a0 <botlish_fn_52+0x290>
    4594:	jmp    45b0 <botlish_fn_52+0xa0>
    4599:	mov    rdx,r14
    459c:	or     rdx,0x1
    45a0:	mov    ecx,0x2
    45a5:	cmp    r12,rdx
    45a8:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 47a0 <botlish_fn_52+0x290>
    45b0:	cmp    rcx,0x6
    45b4:	je     477a <botlish_fn_52+0x26a>
    45ba:	xor    ecx,ecx
    45bc:	mov    rdx,rbx
    45bf:	test   rdx,0x7
    45c6:	jne    45da <botlish_fn_52+0xca>
    45cc:	mov    rdx,rbx
    45cf:	movzx  r9,BYTE PTR [rdx]
    45d3:	cmp    r9b,0x3
    45d7:	sete   cl
    45da:	test   cl,cl
    45dc:	jne    45ff <botlish_fn_52+0xef>
    45e2:	mov    rdi,r15
    45e5:	mov    rax,QWORD PTR [rdi+0x10]
    45e9:	mov    rcx,QWORD PTR [rax+0x50]
    45ed:	mov    edx,0x4
    45f2:	mov    rsi,rbx
    45f5:	call   45fa <botlish_fn_52+0xea>
			45f6: R_X86_64_PLT32	rt_type_error-0x4
    45fa:	jmp    4724 <botlish_fn_52+0x214>
    45ff:	mov    rsi,rbx
    4602:	test   r12,0x1
    4609:	jne    4617 <botlish_fn_52+0x107>
    460f:	mov    rbx,rsi
    4612:	jmp    462d <botlish_fn_52+0x11d>
    4617:	mov    rax,QWORD PTR [rsi+0x8]
    461b:	mov    rbx,rsi
    461e:	mov    rcx,r12
    4621:	sar    rcx,1
    4624:	cmp    rcx,rax
    4627:	jb     464c <botlish_fn_52+0x13c>
    462d:	mov    rdx,r12
    4630:	mov    rsi,rbx
    4633:	mov    rdi,r15
    4636:	call   463b <botlish_fn_52+0x12b>
			4637: R_X86_64_PLT32	rt_list_get-0x4
    463b:	test   rax,rax
    463e:	je     4724 <botlish_fn_52+0x214>
    4644:	mov    rdx,rax
    4647:	jmp    4654 <botlish_fn_52+0x144>
    464c:	mov    rax,QWORD PTR [rbx+0x10]
    4650:	mov    rdx,QWORD PTR [rax+rcx*8]
    4654:	mov    QWORD PTR [rsp+0x20],rdx
    4659:	mov    QWORD PTR [rsp+0x38],rdx
    465e:	xor    esi,esi
    4660:	mov    rcx,QWORD PTR [rsp+0x30]
    4665:	test   rcx,0x7
    466c:	je     467c <botlish_fn_52+0x16c>
    4672:	mov    QWORD PTR [rsp+0x30],rcx
    4677:	jmp    468b <botlish_fn_52+0x17b>
    467c:	movzx  rax,BYTE PTR [rcx]
    4680:	mov    QWORD PTR [rsp+0x30],rcx
    4685:	cmp    al,0x3
    4687:	sete   sil
    468b:	test   sil,sil
    468e:	jne    46b3 <botlish_fn_52+0x1a3>
    4694:	mov    rdi,r15
    4697:	mov    rax,QWORD PTR [rdi+0x10]
    469b:	mov    rcx,QWORD PTR [rax+0x50]
    469f:	mov    edx,0x4
    46a4:	mov    rsi,QWORD PTR [rsp+0x30]
    46a9:	call   46ae <botlish_fn_52+0x19e>
			46aa: R_X86_64_PLT32	rt_type_error-0x4
    46ae:	jmp    4724 <botlish_fn_52+0x214>
    46b3:	test   r12,0x1
    46ba:	je     46d8 <botlish_fn_52+0x1c8>
    46c0:	mov    rsi,QWORD PTR [rsp+0x30]
    46c5:	mov    rcx,QWORD PTR [rsi+0x8]
    46c9:	mov    rax,r12
    46cc:	sar    rax,1
    46cf:	cmp    rax,rcx
    46d2:	jb     46f9 <botlish_fn_52+0x1e9>
    46d8:	mov    rdx,r12
    46db:	mov    rsi,QWORD PTR [rsp+0x30]
    46e0:	mov    rdi,r15
    46e3:	call   46e8 <botlish_fn_52+0x1d8>
			46e4: R_X86_64_PLT32	rt_list_get-0x4
    46e8:	test   rax,rax
    46eb:	je     4724 <botlish_fn_52+0x214>
    46f1:	mov    rcx,rax
    46f4:	jmp    4706 <botlish_fn_52+0x1f6>
    46f9:	mov    rsi,QWORD PTR [rsp+0x30]
    46fe:	mov    rcx,QWORD PTR [rsi+0x10]
    4702:	mov    rcx,QWORD PTR [rcx+rax*8]
    4706:	mov    QWORD PTR [rsp+0x28],rcx
    470b:	mov    rdx,QWORD PTR [rsp+0x38]
    4710:	mov    rsi,r13
    4713:	mov    rdi,r15
    4716:	call   471b <botlish_fn_52+0x20b>
			4717: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    471b:	test   rax,rax
    471e:	jne    4749 <botlish_fn_52+0x239>
    4724:	xor    rax,rax
    4727:	mov    rbx,QWORD PTR [rsp+0x40]
    472c:	mov    r12,QWORD PTR [rsp+0x48]
    4731:	mov    r13,QWORD PTR [rsp+0x50]
    4736:	mov    r14,QWORD PTR [rsp+0x58]
    473b:	mov    r15,QWORD PTR [rsp+0x60]
    4740:	add    rsp,0x70
    4744:	mov    rsp,rbp
    4747:	pop    rbp
    4748:	ret
    4749:	mov    QWORD PTR [rsp],r13
    474d:	mov    QWORD PTR [rsp+0x8],rbx
    4752:	mov    rsi,QWORD PTR [rsp+0x30]
    4757:	mov    QWORD PTR [rsp+0x10],rsi
    475c:	sar    r12,1
    475f:	add    r12,0x1
    4766:	shl    r12,1
    4769:	or     r12,0x1
    476d:	mov    QWORD PTR [rsp+0x18],r12
    4772:	mov    r8,r12
    4775:	jmp    4555 <botlish_fn_52+0x45>
    477a:	mov    rax,r13
    477d:	mov    rbx,QWORD PTR [rsp+0x40]
    4782:	mov    r12,QWORD PTR [rsp+0x48]
    4787:	mov    r13,QWORD PTR [rsp+0x50]
    478c:	mov    r14,QWORD PTR [rsp+0x58]
    4791:	mov    r15,QWORD PTR [rsp+0x60]
    4796:	add    rsp,0x70
    479a:	mov    rsp,rbp
    479d:	pop    rbp
    479e:	ret
    479f:	add    BYTE PTR [rsi],al
    47a1:	add    BYTE PTR [rax],al
    47a3:	add    BYTE PTR [rax],al
    47a5:	add    BYTE PTR [rax],al
	...

00000000000047a8 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    47a8:	push   rbp
    47a9:	mov    rbp,rsp
    47ac:	mov    rsi,QWORD PTR [rdx]
    47af:	mov    r10,QWORD PTR [rdx+0x8]
    47b3:	mov    rcx,QWORD PTR [rdx+0x10]
    47b7:	mov    r8,QWORD PTR [rdx+0x18]
    47bb:	mov    r9,QWORD PTR [rdx+0x20]
    47bf:	mov    rdx,r10
    47c2:	call   47c7 <botlish_entry_52+0x1f>
			47c3: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    47c7:	mov    rsp,rbp
    47ca:	pop    rbp
    47cb:	ret

00000000000047cc <botlish_fn_53: row_table<any, int, any, bool>>:
    47cc:	push   rbp
    47cd:	mov    rbp,rsp
    47d0:	sub    rsp,0x50
    47d4:	mov    QWORD PTR [rsp+0x30],rbx
    47d9:	mov    QWORD PTR [rsp+0x38],r12
    47de:	mov    QWORD PTR [rsp+0x40],r13
    47e3:	mov    QWORD PTR [rsp+0x48],r14
    47e8:	mov    r12,rdi
    47eb:	mov    QWORD PTR [rsp+0x20],0x0
    47f4:	mov    QWORD PTR [rsp],rsi
    47f8:	mov    r13,rsi
    47fb:	mov    QWORD PTR [rsp+0x8],rdx
    4800:	mov    QWORD PTR [rsp+0x10],rcx
    4805:	mov    rbx,rcx
    4808:	mov    QWORD PTR [rsp+0x18],r8
    480d:	mov    rsi,r8
    4810:	mov    rdi,r12
    4813:	call   4818 <botlish_fn_53+0x4c>
			4814: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    4818:	test   rax,rax
    481b:	je     48b0 <botlish_fn_53+0xe4>
    4821:	mov    QWORD PTR [rsp+0x8],rax
    4826:	mov    r14,rax
    4829:	mov    QWORD PTR [rsp+0x18],0x1
    4832:	xor    eax,eax
    4834:	mov    rcx,rbx
    4837:	test   rcx,0x7
    483e:	je     484c <botlish_fn_53+0x80>
    4844:	mov    rbx,rcx
    4847:	jmp    4858 <botlish_fn_53+0x8c>
    484c:	movzx  rax,BYTE PTR [rcx]
    4850:	mov    rbx,rcx
    4853:	cmp    al,0x3
    4855:	sete   al
    4858:	test   al,al
    485a:	jne    487d <botlish_fn_53+0xb1>
    4860:	mov    rdi,r12
    4863:	mov    rax,QWORD PTR [rdi+0x10]
    4867:	mov    rcx,QWORD PTR [rax+0x58]
    486b:	mov    edx,0x4
    4870:	mov    rsi,rbx
    4873:	call   4878 <botlish_fn_53+0xac>
			4874: R_X86_64_PLT32	rt_type_error-0x4
    4878:	jmp    48b0 <botlish_fn_53+0xe4>
    487d:	mov    rsi,rbx
    4880:	mov    rdi,r12
    4883:	call   4888 <botlish_fn_53+0xbc>
			4884: R_X86_64_PLT32	rt_list_len-0x4
    4888:	mov    QWORD PTR [rsp+0x20],rax
    488d:	mov    r8d,0x1
    4893:	mov    rcx,rbx
    4896:	mov    rdx,r13
    4899:	mov    rsi,r14
    489c:	mov    rdi,r12
    489f:	mov    r9,rax
    48a2:	call   48a7 <botlish_fn_53+0xdb>
			48a3: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    48a7:	test   rax,rax
    48aa:	jne    48d0 <botlish_fn_53+0x104>
    48b0:	xor    rax,rax
    48b3:	mov    rbx,QWORD PTR [rsp+0x30]
    48b8:	mov    r12,QWORD PTR [rsp+0x38]
    48bd:	mov    r13,QWORD PTR [rsp+0x40]
    48c2:	mov    r14,QWORD PTR [rsp+0x48]
    48c7:	add    rsp,0x50
    48cb:	mov    rsp,rbp
    48ce:	pop    rbp
    48cf:	ret
    48d0:	mov    rbx,QWORD PTR [rsp+0x30]
    48d5:	mov    r12,QWORD PTR [rsp+0x38]
    48da:	mov    r13,QWORD PTR [rsp+0x40]
    48df:	mov    r14,QWORD PTR [rsp+0x48]
    48e4:	add    rsp,0x50
    48e8:	mov    rsp,rbp
    48eb:	pop    rbp
    48ec:	ret

00000000000048ed <botlish_entry_53: row_table<any, int, any, bool>>:
    48ed:	push   rbp
    48ee:	mov    rbp,rsp
    48f1:	mov    rsi,QWORD PTR [rdx]
    48f4:	mov    r9,QWORD PTR [rdx+0x8]
    48f8:	mov    rcx,QWORD PTR [rdx+0x10]
    48fc:	mov    r8,QWORD PTR [rdx+0x18]
    4900:	mov    rdx,r9
    4903:	call   4908 <botlish_entry_53+0x1b>
			4904: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    4908:	mov    rsp,rbp
    490b:	pop    rbp
    490c:	ret
    490d:	add    BYTE PTR [rax],al
	...

0000000000004910 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4910:	push   rbp
    4911:	mov    rbp,rsp
    4914:	sub    rsp,0x90
    491b:	mov    QWORD PTR [rsp+0x60],rbx
    4920:	mov    QWORD PTR [rsp+0x68],r12
    4925:	mov    QWORD PTR [rsp+0x70],r13
    492a:	mov    QWORD PTR [rsp+0x78],r14
    492f:	mov    QWORD PTR [rsp+0x80],r15
    4937:	mov    r13,r8
    493a:	mov    QWORD PTR [rsp+0x40],rdi
    493f:	mov    r11,QWORD PTR [rbp+0x10]
    4943:	mov    r15,QWORD PTR [rbp+0x18]
    4947:	mov    QWORD PTR [rsp+0x30],0x0
    4950:	mov    QWORD PTR [rsp+0x38],0x0
    4959:	mov    QWORD PTR [rsp],rsi
    495d:	mov    QWORD PTR [rsp+0x8],rdx
    4962:	mov    r12,rdx
    4965:	mov    QWORD PTR [rsp+0x10],rcx
    496a:	mov    r14,rcx
    496d:	mov    QWORD PTR [rsp+0x18],r9
    4972:	mov    QWORD PTR [rsp+0x20],r11
    4977:	mov    QWORD PTR [rsp+0x50],r11
    497c:	mov    QWORD PTR [rsp+0x28],r15
    4981:	mov    rbx,rsi
    4984:	mov    QWORD PTR [rsp+0x48],r9
    4989:	mov    rsi,rbx
    498c:	mov    rdi,QWORD PTR [rsp+0x40]
    4991:	call   4996 <botlish_fn_54+0x86>
			4992: R_X86_64_PLT32	rt_list_len-0x4
    4996:	mov    rcx,r12
    4999:	and    rcx,rax
    499c:	mov    rdx,rax
    499f:	test   rcx,0x1
    49a6:	jne    49ce <botlish_fn_54+0xbe>
    49ac:	mov    rsi,r12
    49af:	mov    rdi,QWORD PTR [rsp+0x40]
    49b4:	call   49b9 <botlish_fn_54+0xa9>
			49b5: R_X86_64_PLT32	rt_int_cmp-0x4
    49b9:	mov    ecx,0x2
    49be:	test   rax,rax
    49c1:	cmovge rcx,QWORD PTR [rip+0x177]        # 4b40 <botlish_fn_54+0x230>
    49c9:	jmp    49de <botlish_fn_54+0xce>
    49ce:	mov    ecx,0x2
    49d3:	cmp    r12,rdx
    49d6:	cmovge rcx,QWORD PTR [rip+0x162]        # 4b40 <botlish_fn_54+0x230>
    49de:	cmp    rcx,0x6
    49e2:	je     4ac9 <botlish_fn_54+0x1b9>
    49e8:	mov    rax,r13
    49eb:	or     rax,0x1
    49ef:	mov    QWORD PTR [rsp+0x30],rax
    49f4:	test   r12,0x1
    49fb:	je     4a14 <botlish_fn_54+0x104>
    4a01:	mov    rcx,QWORD PTR [rbx+0x8]
    4a05:	mov    rax,r12
    4a08:	sar    rax,1
    4a0b:	cmp    rax,rcx
    4a0e:	jb     4a35 <botlish_fn_54+0x125>
    4a14:	mov    rdx,r12
    4a17:	mov    rsi,rbx
    4a1a:	mov    rdi,QWORD PTR [rsp+0x40]
    4a1f:	call   4a24 <botlish_fn_54+0x114>
			4a20: R_X86_64_PLT32	rt_list_get-0x4
    4a24:	test   rax,rax
    4a27:	je     4ae6 <botlish_fn_54+0x1d6>
    4a2d:	mov    rcx,rax
    4a30:	jmp    4a3d <botlish_fn_54+0x12d>
    4a35:	mov    rsi,QWORD PTR [rbx+0x10]
    4a39:	mov    rcx,QWORD PTR [rsi+rax*8]
    4a3d:	mov    QWORD PTR [rsp+0x38],rcx
    4a42:	mov    rdx,r13
    4a45:	or     rdx,0x1
    4a49:	mov    rsi,r14
    4a4c:	mov    rdi,QWORD PTR [rsp+0x40]
    4a51:	mov    r8,r15
    4a54:	call   4a59 <botlish_fn_54+0x149>
			4a55: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    4a59:	test   rax,rax
    4a5c:	je     4ae6 <botlish_fn_54+0x1d6>
    4a62:	mov    QWORD PTR [rsp+0x8],rax
    4a67:	mov    rcx,rax
    4a6a:	sar    r12,1
    4a6d:	add    r12,0x1
    4a74:	shl    r12,1
    4a77:	or     r12,0x1
    4a7b:	mov    QWORD PTR [rsp+0x30],r12
    4a80:	mov    rdx,QWORD PTR [rsp+0x50]
    4a85:	mov    rsi,QWORD PTR [rsp+0x48]
    4a8a:	mov    rdi,QWORD PTR [rsp+0x40]
    4a8f:	call   4a94 <botlish_fn_54+0x184>
			4a90: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    4a94:	test   rax,rax
    4a97:	je     4ae6 <botlish_fn_54+0x1d6>
    4a9d:	mov    QWORD PTR [rsp],rbx
    4aa1:	mov    QWORD PTR [rsp+0x8],r12
    4aa6:	mov    QWORD PTR [rsp+0x10],r14
    4aab:	mov    QWORD PTR [rsp+0x18],rax
    4ab0:	mov    QWORD PTR [rsp+0x20],rdx
    4ab5:	mov    QWORD PTR [rsp+0x28],r15
    4aba:	mov    QWORD PTR [rsp+0x48],rax
    4abf:	mov    QWORD PTR [rsp+0x50],rdx
    4ac4:	jmp    4989 <botlish_fn_54+0x79>
    4ac9:	mov    rdx,QWORD PTR [rsp+0x50]
    4ace:	mov    rsi,QWORD PTR [rsp+0x48]
    4ad3:	mov    rdi,QWORD PTR [rsp+0x40]
    4ad8:	call   4add <botlish_fn_54+0x1cd>
			4ad9: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    4add:	test   rax,rax
    4ae0:	jne    4b11 <botlish_fn_54+0x201>
    4ae6:	xor    rax,rax
    4ae9:	mov    rbx,QWORD PTR [rsp+0x60]
    4aee:	mov    r12,QWORD PTR [rsp+0x68]
    4af3:	mov    r13,QWORD PTR [rsp+0x70]
    4af8:	mov    r14,QWORD PTR [rsp+0x78]
    4afd:	mov    r15,QWORD PTR [rsp+0x80]
    4b05:	add    rsp,0x90
    4b0c:	mov    rsp,rbp
    4b0f:	pop    rbp
    4b10:	ret
    4b11:	mov    rbx,QWORD PTR [rsp+0x60]
    4b16:	mov    r12,QWORD PTR [rsp+0x68]
    4b1b:	mov    r13,QWORD PTR [rsp+0x70]
    4b20:	mov    r14,QWORD PTR [rsp+0x78]
    4b25:	mov    r15,QWORD PTR [rsp+0x80]
    4b2d:	add    rsp,0x90
    4b34:	mov    rsp,rbp
    4b37:	pop    rbp
    4b38:	ret
    4b39:	add    BYTE PTR [rax],al
    4b3b:	add    BYTE PTR [rax],al
    4b3d:	add    BYTE PTR [rax],al
    4b3f:	add    BYTE PTR [rsi],al
    4b41:	add    BYTE PTR [rax],al
    4b43:	add    BYTE PTR [rax],al
    4b45:	add    BYTE PTR [rax],al
	...

0000000000004b48 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    4b48:	push   rbp
    4b49:	mov    rbp,rsp
    4b4c:	sub    rsp,0x10
    4b50:	mov    rsi,QWORD PTR [rdx]
    4b53:	mov    r10,QWORD PTR [rdx+0x8]
    4b57:	mov    rcx,QWORD PTR [rdx+0x10]
    4b5b:	mov    r8,QWORD PTR [rdx+0x18]
    4b5f:	mov    r9,QWORD PTR [rdx+0x20]
    4b63:	mov    r11,QWORD PTR [rdx+0x28]
    4b67:	mov    rax,QWORD PTR [rdx+0x30]
    4b6b:	mov    QWORD PTR [rsp],r11
    4b6f:	mov    QWORD PTR [rsp+0x8],rax
    4b74:	mov    rdx,r10
    4b77:	call   4b7c <botlish_entry_54+0x34>
			4b78: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4b7c:	add    rsp,0x10
    4b80:	mov    rsp,rbp
    4b83:	pop    rbp
    4b84:	ret

0000000000004b85 <botlish_fn_55: csv_records_generic<str, bool>>:
    4b85:	push   rbp
    4b86:	mov    rbp,rsp
    4b89:	sub    rsp,0x80
    4b90:	mov    QWORD PTR [rsp+0x50],rbx
    4b95:	mov    QWORD PTR [rsp+0x58],r12
    4b9a:	mov    QWORD PTR [rsp+0x60],r13
    4b9f:	mov    QWORD PTR [rsp+0x68],r14
    4ba4:	mov    QWORD PTR [rsp+0x70],r15
    4ba9:	mov    rbx,rdi
    4bac:	mov    QWORD PTR [rsp+0x20],0x0
    4bb5:	mov    QWORD PTR [rsp+0x28],0x0
    4bbe:	mov    QWORD PTR [rsp+0x30],0x0
    4bc7:	mov    QWORD PTR [rsp+0x38],0x0
    4bd0:	mov    QWORD PTR [rsp+0x40],0x0
    4bd9:	mov    QWORD PTR [rsp+0x10],rsi
    4bde:	mov    QWORD PTR [rsp+0x18],rdx
    4be3:	mov    r12,rdx
    4be6:	mov    rdi,rbx
    4be9:	call   4bee <botlish_fn_55+0x69>
			4bea: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    4bee:	mov    rcx,rax
    4bf1:	mov    r13,rax
    4bf4:	test   rax,rcx
    4bf7:	je     4d3d <botlish_fn_55+0x1b8>
    4bfd:	mov    rax,r13
    4c00:	mov    QWORD PTR [rsp+0x10],rax
    4c05:	mov    rsi,r13
    4c08:	mov    rdi,rbx
    4c0b:	call   4c10 <botlish_fn_55+0x8b>
			4c0c: R_X86_64_PLT32	rt_list_len-0x4
    4c10:	sar    rax,1
    4c13:	test   rax,rax
    4c16:	je     4d26 <botlish_fn_55+0x1a1>
    4c1c:	mov    rax,r13
    4c1f:	mov    rax,QWORD PTR [rax+0x8]
    4c23:	test   rax,rax
    4c26:	jne    4c4d <botlish_fn_55+0xc8>
    4c2c:	mov    edx,0x1
    4c31:	mov    rsi,r13
    4c34:	mov    rdi,rbx
    4c37:	call   4c3c <botlish_fn_55+0xb7>
			4c38: R_X86_64_PLT32	rt_list_get-0x4
    4c3c:	test   rax,rax
    4c3f:	je     4d3d <botlish_fn_55+0x1b8>
    4c45:	mov    rsi,rax
    4c48:	jmp    4c5a <botlish_fn_55+0xd5>
    4c4d:	mov    rax,r13
    4c50:	mov    rcx,QWORD PTR [rax+0x10]
    4c54:	mov    rax,QWORD PTR [rcx]
    4c57:	mov    rsi,rax
    4c5a:	mov    QWORD PTR [rsp+0x20],rsi
    4c5f:	mov    QWORD PTR [rsp+0x28],0x3
    4c68:	xor    eax,eax
    4c6a:	test   rsi,0x7
    4c71:	jne    4c80 <botlish_fn_55+0xfb>
    4c77:	movzx  rax,BYTE PTR [rsi]
    4c7b:	cmp    al,0x3
    4c7d:	sete   al
    4c80:	test   al,al
    4c82:	jne    4ca2 <botlish_fn_55+0x11d>
    4c88:	mov    rdi,rbx
    4c8b:	mov    rax,QWORD PTR [rdi+0x10]
    4c8f:	mov    rcx,QWORD PTR [rax+0x58]
    4c93:	mov    edx,0x4
    4c98:	call   4c9d <botlish_fn_55+0x118>
			4c99: R_X86_64_PLT32	rt_type_error-0x4
    4c9d:	jmp    4d3d <botlish_fn_55+0x1b8>
    4ca2:	mov    r14,rsi
    4ca5:	mov    rdi,rbx
    4ca8:	call   4cad <botlish_fn_55+0x128>
			4ca9: R_X86_64_PLT32	rt_list_len-0x4
    4cad:	mov    QWORD PTR [rsp+0x30],rax
    4cb2:	mov    r15,rax
    4cb5:	mov    rdi,rbx
    4cb8:	call   4cbd <botlish_fn_55+0x138>
			4cb9: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    4cbd:	test   rax,rax
    4cc0:	je     4d3d <botlish_fn_55+0x1b8>
    4cc6:	mov    QWORD PTR [rsp+0x38],rax
    4ccb:	mov    r9,rax
    4cce:	mov    QWORD PTR [rsp+0x40],rdx
    4cd3:	mov    rax,rdx
    4cd6:	mov    edx,0x3
    4cdb:	mov    QWORD PTR [rsp],rax
    4cdf:	mov    rax,r12
    4ce2:	mov    QWORD PTR [rsp+0x8],rax
    4ce7:	mov    rcx,r14
    4cea:	mov    rsi,r13
    4ced:	mov    rdi,rbx
    4cf0:	mov    r8,r15
    4cf3:	call   4cf8 <botlish_fn_55+0x173>
			4cf4: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    4cf8:	test   rax,rax
    4cfb:	je     4d3d <botlish_fn_55+0x1b8>
    4d01:	mov    rbx,QWORD PTR [rsp+0x50]
    4d06:	mov    r12,QWORD PTR [rsp+0x58]
    4d0b:	mov    r13,QWORD PTR [rsp+0x60]
    4d10:	mov    r14,QWORD PTR [rsp+0x68]
    4d15:	mov    r15,QWORD PTR [rsp+0x70]
    4d1a:	add    rsp,0x80
    4d21:	mov    rsp,rbp
    4d24:	pop    rbp
    4d25:	ret
    4d26:	xor    rdx,rdx
    4d29:	mov    rdi,rbx
    4d2c:	mov    rsi,rdx
    4d2f:	call   4d34 <botlish_fn_55+0x1af>
			4d30: R_X86_64_PLT32	rt_list_new-0x4
    4d34:	test   rax,rax
    4d37:	jne    4d65 <botlish_fn_55+0x1e0>
    4d3d:	xor    rax,rax
    4d40:	mov    rbx,QWORD PTR [rsp+0x50]
    4d45:	mov    r12,QWORD PTR [rsp+0x58]
    4d4a:	mov    r13,QWORD PTR [rsp+0x60]
    4d4f:	mov    r14,QWORD PTR [rsp+0x68]
    4d54:	mov    r15,QWORD PTR [rsp+0x70]
    4d59:	add    rsp,0x80
    4d60:	mov    rsp,rbp
    4d63:	pop    rbp
    4d64:	ret
    4d65:	mov    rbx,QWORD PTR [rsp+0x50]
    4d6a:	mov    r12,QWORD PTR [rsp+0x58]
    4d6f:	mov    r13,QWORD PTR [rsp+0x60]
    4d74:	mov    r14,QWORD PTR [rsp+0x68]
    4d79:	mov    r15,QWORD PTR [rsp+0x70]
    4d7e:	add    rsp,0x80
    4d85:	mov    rsp,rbp
    4d88:	pop    rbp
    4d89:	ret

0000000000004d8a <botlish_entry_55: csv_records_generic<str, bool>>:
    4d8a:	push   rbp
    4d8b:	mov    rbp,rsp
    4d8e:	mov    rsi,QWORD PTR [rdx]
    4d91:	mov    rdx,QWORD PTR [rdx+0x8]
    4d95:	call   4d9a <botlish_entry_55+0x10>
			4d96: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4d9a:	mov    rsp,rbp
    4d9d:	pop    rbp
    4d9e:	ret

0000000000004d9f <botlish_fn_56: csv_records<str>>:
    4d9f:	push   rbp
    4da0:	mov    rbp,rsp
    4da3:	sub    rsp,0x10
    4da7:	mov    QWORD PTR [rsp],rsi
    4dab:	mov    edx,0x2
    4db0:	mov    QWORD PTR [rsp+0x8],0x2
    4db9:	call   4dbe <botlish_fn_56+0x1f>
			4dba: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4dbe:	test   rax,rax
    4dc1:	jne    4dd3 <botlish_fn_56+0x34>
    4dc7:	xor    rax,rax
    4dca:	add    rsp,0x10
    4dce:	mov    rsp,rbp
    4dd1:	pop    rbp
    4dd2:	ret
    4dd3:	add    rsp,0x10
    4dd7:	mov    rsp,rbp
    4dda:	pop    rbp
    4ddb:	ret

0000000000004ddc <botlish_entry_56: csv_records<str>>:
    4ddc:	push   rbp
    4ddd:	mov    rbp,rsp
    4de0:	mov    rsi,QWORD PTR [rdx]
    4de3:	call   4de8 <botlish_entry_56+0xc>
			4de4: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    4de8:	mov    rsp,rbp
    4deb:	pop    rbp
    4dec:	ret

0000000000004ded <botlish_fn_57: csv_records_presized<str>>:
    4ded:	push   rbp
    4dee:	mov    rbp,rsp
    4df1:	sub    rsp,0x10
    4df5:	mov    QWORD PTR [rsp],rsi
    4df9:	mov    edx,0x6
    4dfe:	mov    QWORD PTR [rsp+0x8],0x6
    4e07:	call   4e0c <botlish_fn_57+0x1f>
			4e08: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    4e0c:	test   rax,rax
    4e0f:	jne    4e21 <botlish_fn_57+0x34>
    4e15:	xor    rax,rax
    4e18:	add    rsp,0x10
    4e1c:	mov    rsp,rbp
    4e1f:	pop    rbp
    4e20:	ret
    4e21:	add    rsp,0x10
    4e25:	mov    rsp,rbp
    4e28:	pop    rbp
    4e29:	ret

0000000000004e2a <botlish_entry_57: csv_records_presized<str>>:
    4e2a:	push   rbp
    4e2b:	mov    rbp,rsp
    4e2e:	mov    rsi,QWORD PTR [rdx]
    4e31:	call   4e36 <botlish_entry_57+0xc>
			4e32: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    4e36:	mov    rsp,rbp
    4e39:	pop    rbp
    4e3a:	ret
    4e3b:	add    BYTE PTR [rax],al
    4e3d:	add    BYTE PTR [rax],al
	...

0000000000004e40 <botlish_fn_58: sample<generic>>:
    4e40:	push   rbp
    4e41:	mov    rbp,rsp
    4e44:	sub    rsp,0xc0
    4e4b:	mov    QWORD PTR [rsp+0x90],rbx
    4e53:	mov    QWORD PTR [rsp+0x98],r12
    4e5b:	mov    QWORD PTR [rsp+0xa0],r13
    4e63:	mov    QWORD PTR [rsp+0xa8],r14
    4e6b:	mov    QWORD PTR [rsp+0xb0],r15
    4e73:	mov    QWORD PTR [rsp+0x8],0x0
    4e7c:	mov    QWORD PTR [rsp+0x10],0x0
    4e85:	mov    QWORD PTR [rsp+0x18],0x0
    4e8e:	mov    QWORD PTR [rsp+0x20],0x0
    4e97:	mov    QWORD PTR [rsp+0x28],0x0
    4ea0:	mov    QWORD PTR [rsp+0x30],0x0
    4ea9:	mov    QWORD PTR [rsp+0x38],0x0
    4eb2:	mov    rax,QWORD PTR [rdi+0x10]
    4eb6:	mov    r13,rdi
    4eb9:	mov    rsi,QWORD PTR [rax+0x60]
    4ebd:	mov    QWORD PTR [rsp],rsi
    4ec1:	call   4ec6 <botlish_fn_58+0x86>
			4ec2: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    4ec6:	mov    rsi,rax
    4ec9:	mov    r12,rax
    4ecc:	test   rax,rsi
    4ecf:	je     5259 <botlish_fn_58+0x419>
    4ed5:	mov    rax,r12
    4ed8:	mov    QWORD PTR [rsp],rax
    4edc:	mov    rdi,r13
    4edf:	mov    rax,QWORD PTR [rdi+0x10]
    4ee3:	mov    rsi,QWORD PTR [rax+0x60]
    4ee7:	mov    QWORD PTR [rsp+0x8],rsi
    4eec:	call   4ef1 <botlish_fn_58+0xb1>
			4eed: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    4ef1:	mov    rbx,rax
    4ef4:	test   rbx,rbx
    4ef7:	je     5259 <botlish_fn_58+0x419>
    4efd:	mov    rax,r12
    4f00:	mov    rax,QWORD PTR [rax+0x8]
    4f04:	test   rax,rax
    4f07:	jne    4f2e <botlish_fn_58+0xee>
    4f0d:	mov    edx,0x1
    4f12:	mov    rsi,r12
    4f15:	mov    rdi,r13
    4f18:	call   4f1d <botlish_fn_58+0xdd>
			4f19: R_X86_64_PLT32	rt_list_get-0x4
    4f1d:	test   rax,rax
    4f20:	je     5259 <botlish_fn_58+0x419>
    4f26:	mov    rsi,rax
    4f29:	jmp    4f36 <botlish_fn_58+0xf6>
    4f2e:	mov    rax,QWORD PTR [r12+0x10]
    4f33:	mov    rsi,QWORD PTR [rax]
    4f36:	mov    QWORD PTR [rsp+0x8],rsi
    4f3b:	mov    r15,rsi
    4f3e:	mov    rax,QWORD PTR [r12+0x8]
    4f43:	cmp    rax,0x1
    4f47:	ja     4f6e <botlish_fn_58+0x12e>
    4f4d:	mov    edx,0x3
    4f52:	mov    rsi,r12
    4f55:	mov    rdi,r13
    4f58:	call   4f5d <botlish_fn_58+0x11d>
			4f59: R_X86_64_PLT32	rt_list_get-0x4
    4f5d:	test   rax,rax
    4f60:	je     5259 <botlish_fn_58+0x419>
    4f66:	mov    rsi,rax
    4f69:	jmp    4f77 <botlish_fn_58+0x137>
    4f6e:	mov    rax,QWORD PTR [r12+0x10]
    4f73:	mov    rsi,QWORD PTR [rax+0x8]
    4f77:	mov    QWORD PTR [rsp+0x10],rsi
    4f7c:	mov    r14,rsi
    4f7f:	mov    rax,QWORD PTR [rbx+0x8]
    4f83:	mov    rsi,rbx
    4f86:	test   rax,rax
    4f89:	jne    4fad <botlish_fn_58+0x16d>
    4f8f:	mov    edx,0x1
    4f94:	mov    rdi,r13
    4f97:	call   4f9c <botlish_fn_58+0x15c>
			4f98: R_X86_64_PLT32	rt_list_get-0x4
    4f9c:	test   rax,rax
    4f9f:	je     5259 <botlish_fn_58+0x419>
    4fa5:	mov    rsi,rax
    4fa8:	jmp    4fb4 <botlish_fn_58+0x174>
    4fad:	mov    rax,QWORD PTR [rsi+0x10]
    4fb1:	mov    rsi,QWORD PTR [rax]
    4fb4:	mov    QWORD PTR [rsp+0x18],rsi
    4fb9:	mov    rdi,r13
    4fbc:	mov    QWORD PTR [rsp+0x78],rsi
    4fc1:	mov    rax,QWORD PTR [rdi+0x10]
    4fc5:	mov    rdx,QWORD PTR [rax+0x68]
    4fc9:	mov    QWORD PTR [rsp+0x20],rdx
    4fce:	mov    rsi,r15
    4fd1:	call   4fd6 <botlish_fn_58+0x196>
			4fd2: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4fd6:	test   rax,rax
    4fd9:	je     5259 <botlish_fn_58+0x419>
    4fdf:	mov    QWORD PTR [rsp+0x20],rax
    4fe4:	mov    rbx,rax
    4fe7:	mov    rdi,r13
    4fea:	mov    rax,QWORD PTR [rdi+0x10]
    4fee:	mov    rdx,QWORD PTR [rax+0x68]
    4ff2:	mov    QWORD PTR [rsp+0x28],rdx
    4ff7:	mov    rsi,QWORD PTR [rsp+0x78]
    4ffc:	call   5001 <botlish_fn_58+0x1c1>
			4ffd: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    5001:	test   rax,rax
    5004:	je     5259 <botlish_fn_58+0x419>
    500a:	mov    rcx,rbx
    500d:	mov    rdx,rcx
    5010:	and    rdx,rax
    5013:	test   rdx,0x1
    501a:	jne    503c <botlish_fn_58+0x1fc>
    5020:	mov    rdx,rax
    5023:	mov    rsi,rbx
    5026:	mov    rdi,r13
    5029:	call   502e <botlish_fn_58+0x1ee>
			502a: R_X86_64_PLT32	rt_value_eq-0x4
    502e:	test   rax,rax
    5031:	je     5259 <botlish_fn_58+0x419>
    5037:	jmp    5052 <botlish_fn_58+0x212>
    503c:	mov    rdx,rax
    503f:	mov    rsi,rbx
    5042:	mov    eax,0x2
    5047:	cmp    rsi,rdx
    504a:	cmove  rax,QWORD PTR [rip+0x276]        # 52c8 <botlish_fn_58+0x488>
    5052:	mov    ebx,0x6
    5057:	cmp    rax,0x6
    505b:	je     5076 <botlish_fn_58+0x236>
    5061:	mov    ebx,0x2
    5066:	mov    QWORD PTR [rsp],0x2
    506e:	mov    rsi,r12
    5071:	jmp    511a <botlish_fn_58+0x2da>
    5076:	mov    rsi,r15
    5079:	mov    rdi,r13
    507c:	call   5081 <botlish_fn_58+0x241>
			507d: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    5081:	test   rax,rax
    5084:	je     5259 <botlish_fn_58+0x419>
    508a:	mov    QWORD PTR [rsp+0x20],rax
    508f:	mov    rsi,QWORD PTR [rsp+0x78]
    5094:	mov    QWORD PTR [rsp+0x88],rax
    509c:	mov    rdi,r13
    509f:	call   50a4 <botlish_fn_58+0x264>
			50a0: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    50a4:	test   rax,rax
    50a7:	je     5259 <botlish_fn_58+0x419>
    50ad:	mov    rcx,QWORD PTR [rsp+0x88]
    50b5:	mov    rdx,rcx
    50b8:	and    rdx,rax
    50bb:	test   rdx,0x1
    50c2:	jne    50e9 <botlish_fn_58+0x2a9>
    50c8:	mov    rdx,rax
    50cb:	mov    rsi,QWORD PTR [rsp+0x88]
    50d3:	mov    rdi,r13
    50d6:	call   50db <botlish_fn_58+0x29b>
			50d7: R_X86_64_PLT32	rt_value_eq-0x4
    50db:	test   rax,rax
    50de:	je     5259 <botlish_fn_58+0x419>
    50e4:	jmp    5104 <botlish_fn_58+0x2c4>
    50e9:	mov    rdx,rax
    50ec:	mov    rsi,QWORD PTR [rsp+0x88]
    50f4:	mov    eax,0x2
    50f9:	cmp    rsi,rdx
    50fc:	cmove  rax,QWORD PTR [rip+0x1c4]        # 52c8 <botlish_fn_58+0x488>
    5104:	cmp    rax,0x6
    5108:	je     5113 <botlish_fn_58+0x2d3>
    510e:	mov    ebx,0x2
    5113:	mov    QWORD PTR [rsp],rbx
    5117:	mov    rsi,r12
    511a:	mov    rdi,r13
    511d:	call   5122 <botlish_fn_58+0x2e2>
			511e: R_X86_64_PLT32	rt_list_len-0x4
    5122:	mov    QWORD PTR [rsp+0x18],rax
    5127:	mov    rdi,r13
    512a:	mov    r12,rax
    512d:	mov    rax,QWORD PTR [rdi+0x10]
    5131:	mov    rdx,QWORD PTR [rax+0x68]
    5135:	mov    QWORD PTR [rsp+0x20],rdx
    513a:	mov    rsi,r15
    513d:	call   5142 <botlish_fn_58+0x302>
			513e: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    5142:	test   rax,rax
    5145:	je     5259 <botlish_fn_58+0x419>
    514b:	mov    QWORD PTR [rsp+0x20],rax
    5150:	mov    rdi,r13
    5153:	mov    QWORD PTR [rsp+0x88],rax
    515b:	mov    rax,QWORD PTR [rdi+0x10]
    515f:	mov    rdx,QWORD PTR [rax+0x70]
    5163:	mov    QWORD PTR [rsp+0x28],rdx
    5168:	mov    rsi,r15
    516b:	call   5170 <botlish_fn_58+0x330>
			516c: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    5170:	test   rax,rax
    5173:	je     5259 <botlish_fn_58+0x419>
    5179:	mov    QWORD PTR [rsp+0x28],rax
    517e:	mov    rdi,r13
    5181:	mov    QWORD PTR [rsp+0x80],rax
    5189:	mov    rax,QWORD PTR [rdi+0x10]
    518d:	mov    rdx,QWORD PTR [rax+0x78]
    5191:	mov    QWORD PTR [rsp+0x30],rdx
    5196:	mov    rsi,r15
    5199:	call   519e <botlish_fn_58+0x35e>
			519a: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    519e:	test   rax,rax
    51a1:	je     5259 <botlish_fn_58+0x419>
    51a7:	mov    QWORD PTR [rsp+0x8],rax
    51ac:	mov    rdi,r13
    51af:	mov    r15,rax
    51b2:	mov    rax,QWORD PTR [rdi+0x10]
    51b6:	mov    rdx,QWORD PTR [rax+0x68]
    51ba:	mov    QWORD PTR [rsp+0x30],rdx
    51bf:	mov    rsi,r14
    51c2:	call   51c7 <botlish_fn_58+0x387>
			51c3: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    51c7:	test   rax,rax
    51ca:	je     5259 <botlish_fn_58+0x419>
    51d0:	mov    QWORD PTR [rsp+0x30],rax
    51d5:	mov    rdi,r13
    51d8:	mov    QWORD PTR [rsp+0x78],rax
    51dd:	mov    rax,QWORD PTR [rdi+0x10]
    51e1:	mov    rdx,QWORD PTR [rax+0x78]
    51e5:	mov    QWORD PTR [rsp+0x38],rdx
    51ea:	mov    rsi,r14
    51ed:	call   51f2 <botlish_fn_58+0x3b2>
			51ee: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    51f2:	test   rax,rax
    51f5:	je     5259 <botlish_fn_58+0x419>
    51fb:	mov    QWORD PTR [rsp+0x10],rax
    5200:	lea    rdx,[rsp+0x40]
    5205:	mov    r10,r12
    5208:	mov    QWORD PTR [rsp+0x40],r10
    520d:	mov    rcx,QWORD PTR [rsp+0x88]
    5215:	mov    QWORD PTR [rsp+0x48],rcx
    521a:	mov    rcx,QWORD PTR [rsp+0x80]
    5222:	mov    QWORD PTR [rsp+0x50],rcx
    5227:	mov    rcx,r15
    522a:	mov    QWORD PTR [rsp+0x58],rcx
    522f:	mov    rcx,QWORD PTR [rsp+0x78]
    5234:	mov    QWORD PTR [rsp+0x60],rcx
    5239:	mov    QWORD PTR [rsp+0x68],rax
    523e:	mov    QWORD PTR [rsp+0x70],rbx
    5243:	mov    esi,0x7
    5248:	mov    rdi,r13
    524b:	call   5250 <botlish_fn_58+0x410>
			524c: R_X86_64_PLT32	rt_list_new-0x4
    5250:	test   rax,rax
    5253:	jne    5290 <botlish_fn_58+0x450>
    5259:	xor    rax,rax
    525c:	mov    rbx,QWORD PTR [rsp+0x90]
    5264:	mov    r12,QWORD PTR [rsp+0x98]
    526c:	mov    r13,QWORD PTR [rsp+0xa0]
    5274:	mov    r14,QWORD PTR [rsp+0xa8]
    527c:	mov    r15,QWORD PTR [rsp+0xb0]
    5284:	add    rsp,0xc0
    528b:	mov    rsp,rbp
    528e:	pop    rbp
    528f:	ret
    5290:	mov    rbx,QWORD PTR [rsp+0x90]
    5298:	mov    r12,QWORD PTR [rsp+0x98]
    52a0:	mov    r13,QWORD PTR [rsp+0xa0]
    52a8:	mov    r14,QWORD PTR [rsp+0xa8]
    52b0:	mov    r15,QWORD PTR [rsp+0xb0]
    52b8:	add    rsp,0xc0
    52bf:	mov    rsp,rbp
    52c2:	pop    rbp
    52c3:	ret
    52c4:	add    BYTE PTR [rax],al
    52c6:	add    BYTE PTR [rax],al
    52c8:	(bad)
    52c9:	add    BYTE PTR [rax],al
    52cb:	add    BYTE PTR [rax],al
    52cd:	add    BYTE PTR [rax],al
	...

00000000000052d0 <botlish_entry_58: sample<generic>>:
    52d0:	push   rbp
    52d1:	mov    rbp,rsp
    52d4:	call   52d9 <botlish_entry_58+0x9>
			52d5: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    52d9:	mov    rsp,rbp
    52dc:	pop    rbp
    52dd:	ret

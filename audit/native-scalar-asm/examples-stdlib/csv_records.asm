; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 27901  (per function: 172 168 437 517 396 396 396 171 453 502 676 887 469 837 584 268 28 28 28 28 524 689 208 557 271 61 125 61 125 61 125 61 125 61 269 269 284 284 332 332 1020 1536 565 556 582 1353 928 953 825 1472 1108 243 860 443 781 683 181 181 1366)
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
      a9:	sub    rsp,0x30
      ad:	mov    QWORD PTR [rsp+0x10],rbx
      b2:	mov    QWORD PTR [rsp+0x18],r12
      b7:	mov    QWORD PTR [rsp+0x20],r13
      bc:	mov    r12,QWORD PTR [rdi+0x20]
      c0:	mov    r13,QWORD PTR [rdi+0x28]
      c4:	lea    r9,[rsp]
      c8:	mov    QWORD PTR [rdi+0x20],r9
      cc:	mov    QWORD PTR [rdi+0x28],0x1
      d4:	mov    rbx,rdi
      d7:	mov    esi,0x1
      dc:	mov    QWORD PTR [rsp],0x1
      e4:	mov    rdi,rbx
      e7:	call   ec <botlish_fn_1+0x47>
			e8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      ec:	test   rax,rax
      ef:	jne    11b <botlish_fn_1+0x76>
      f5:	mov    QWORD PTR [rbx+0x20],r12
      f9:	mov    QWORD PTR [rbx+0x28],r13
      fd:	xor    rdx,rdx
     100:	mov    rax,rdx
     103:	mov    rbx,QWORD PTR [rsp+0x10]
     108:	mov    r12,QWORD PTR [rsp+0x18]
     10d:	mov    r13,QWORD PTR [rsp+0x20]
     112:	add    rsp,0x30
     116:	mov    rsp,rbp
     119:	pop    rbp
     11a:	ret
     11b:	mov    QWORD PTR [rbx+0x20],r12
     11f:	mov    QWORD PTR [rbx+0x28],r13
     123:	mov    edx,0x1
     128:	mov    rbx,QWORD PTR [rsp+0x10]
     12d:	mov    r12,QWORD PTR [rsp+0x18]
     132:	mov    r13,QWORD PTR [rsp+0x20]
     137:	add    rsp,0x30
     13b:	mov    rsp,rbp
     13e:	pop    rbp
     13f:	ret

0000000000000140 <botlish_entry_1: geo_new<generic>>:
     140:	push   rbp
     141:	mov    rbp,rsp
     144:	ud2
	...

0000000000000148 <botlish_fn_2: geo_new_capacity<int, int>>:
     148:	push   rbp
     149:	mov    rbp,rsp
     14c:	sub    rsp,0x50
     150:	mov    QWORD PTR [rsp+0x20],rbx
     155:	mov    QWORD PTR [rsp+0x28],r12
     15a:	mov    QWORD PTR [rsp+0x30],r13
     15f:	mov    QWORD PTR [rsp+0x38],r14
     164:	mov    QWORD PTR [rsp+0x40],r15
     169:	mov    rbx,QWORD PTR [rdi+0x20]
     16d:	mov    r13,QWORD PTR [rdi+0x28]
     171:	lea    rax,[rsp]
     175:	mov    QWORD PTR [rdi+0x20],rax
     179:	mov    QWORD PTR [rdi+0x28],0x3
     181:	mov    QWORD PTR [rsp],rsi
     185:	mov    QWORD PTR [rsp+0x8],rdx
     18a:	mov    r14,rdx
     18d:	mov    QWORD PTR [rsp+0x10],0x5
     196:	test   rsi,0x1
     19d:	je     1c7 <botlish_fn_2+0x7f>
     1a3:	mov    rax,rsi
     1a6:	sar    rax,1
     1a9:	imul   QWORD PTR [rip+0x110]        # 2c0 <botlish_fn_2+0x178>
     1b0:	seto   cl
     1b3:	or     rax,0x1
     1b7:	test   cl,cl
     1b9:	jne    1c7 <botlish_fn_2+0x7f>
     1bf:	mov    r12,rdi
     1c2:	jmp    1d4 <botlish_fn_2+0x8c>
     1c7:	mov    edx,0x5
     1cc:	mov    r12,rdi
     1cf:	call   1d4 <botlish_fn_2+0x8c>
			1d0: R_X86_64_PLT32	rt_int_mul-0x4
     1d4:	mov    rcx,rax
     1d7:	and    rcx,r14
     1da:	mov    r15,rax
     1dd:	test   rcx,0x1
     1e4:	jne    210 <botlish_fn_2+0xc8>
     1ea:	mov    rdx,r14
     1ed:	mov    rsi,r15
     1f0:	mov    rdi,r12
     1f3:	call   1f8 <botlish_fn_2+0xb0>
			1f4: R_X86_64_PLT32	rt_int_cmp-0x4
     1f8:	mov    ecx,0x2
     1fd:	test   rax,rax
     200:	cmovle rcx,QWORD PTR [rip+0xc0]        # 2c8 <botlish_fn_2+0x180>
     208:	mov    rax,r15
     20b:	jmp    223 <botlish_fn_2+0xdb>
     210:	mov    ecx,0x2
     215:	mov    rax,r15
     218:	cmp    rax,r14
     21b:	cmovle rcx,QWORD PTR [rip+0xa5]        # 2c8 <botlish_fn_2+0x180>
     223:	cmp    rcx,0x6
     227:	je     259 <botlish_fn_2+0x111>
     22d:	mov    QWORD PTR [r12+0x20],rbx
     232:	mov    QWORD PTR [r12+0x28],r13
     237:	mov    rbx,QWORD PTR [rsp+0x20]
     23c:	mov    r12,QWORD PTR [rsp+0x28]
     241:	mov    r13,QWORD PTR [rsp+0x30]
     246:	mov    r14,QWORD PTR [rsp+0x38]
     24b:	mov    r15,QWORD PTR [rsp+0x40]
     250:	add    rsp,0x50
     254:	mov    rsp,rbp
     257:	pop    rbp
     258:	ret
     259:	mov    QWORD PTR [rsp],0x3
     261:	test   r14,0x1
     268:	je     280 <botlish_fn_2+0x138>
     26e:	mov    rax,r14
     271:	add    rax,0x2
     275:	seto   cl
     278:	test   cl,cl
     27a:	je     290 <botlish_fn_2+0x148>
     280:	mov    edx,0x3
     285:	mov    rsi,r14
     288:	mov    rdi,r12
     28b:	call   290 <botlish_fn_2+0x148>
			28c: R_X86_64_PLT32	rt_int_add-0x4
     290:	mov    QWORD PTR [r12+0x20],rbx
     295:	mov    QWORD PTR [r12+0x28],r13
     29a:	mov    rbx,QWORD PTR [rsp+0x20]
     29f:	mov    r12,QWORD PTR [rsp+0x28]
     2a4:	mov    r13,QWORD PTR [rsp+0x30]
     2a9:	mov    r14,QWORD PTR [rsp+0x38]
     2ae:	mov    r15,QWORD PTR [rsp+0x40]
     2b3:	add    rsp,0x50
     2b7:	mov    rsp,rbp
     2ba:	pop    rbp
     2bb:	ret
     2bc:	add    BYTE PTR [rax],al
     2be:	add    BYTE PTR [rax],al
     2c0:	add    al,0x0
     2c2:	add    BYTE PTR [rax],al
     2c4:	add    BYTE PTR [rax],al
     2c6:	add    BYTE PTR [rax],al
     2c8:	(bad)
     2c9:	add    BYTE PTR [rax],al
     2cb:	add    BYTE PTR [rax],al
     2cd:	add    BYTE PTR [rax],al
	...

00000000000002d0 <botlish_entry_2: geo_new_capacity<int, int>>:
     2d0:	push   rbp
     2d1:	mov    rbp,rsp
     2d4:	mov    rsi,QWORD PTR [rdx]
     2d7:	mov    rdx,QWORD PTR [rdx+0x8]
     2db:	call   2e0 <botlish_entry_2+0x10>
			2dc: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     2e0:	mov    rsp,rbp
     2e3:	pop    rbp
     2e4:	ret
     2e5:	add    BYTE PTR [rax],al
	...

00000000000002e8 <botlish_fn_3: geo_grow<mutarray, int>>:
     2e8:	push   rbp
     2e9:	mov    rbp,rsp
     2ec:	sub    rsp,0x30
     2f0:	mov    QWORD PTR [rsp],rbx
     2f4:	mov    QWORD PTR [rsp+0x8],r12
     2f9:	mov    QWORD PTR [rsp+0x10],r13
     2fe:	mov    QWORD PTR [rsp+0x18],r14
     303:	mov    QWORD PTR [rsp+0x20],r15
     308:	mov    rbx,QWORD PTR [rdi]
     30b:	mov    rax,QWORD PTR [rdi+0x8]
     30f:	lea    rcx,[rbx+0x18]
     313:	cmp    rcx,rax
     316:	ja     481 <botlish_fn_3+0x199>
     31c:	lea    rax,[rbx+0x18]
     320:	mov    QWORD PTR [rdi],rax
     323:	mov    r13,rdi
     326:	mov    QWORD PTR [rbx],rsi
     329:	mov    r14,rsi
     32c:	mov    QWORD PTR [rbx+0x8],rdx
     330:	mov    r12,rdx
     333:	mov    rsi,r14
     336:	mov    rdi,r13
     339:	call   33e <botlish_fn_3+0x56>
			33a: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     33e:	mov    r15,rax
     341:	mov    QWORD PTR [rbx+0x10],rax
     345:	mov    rcx,r12
     348:	and    rcx,rax
     34b:	test   rcx,0x1
     352:	jne    37e <botlish_fn_3+0x96>
     358:	mov    rdx,r15
     35b:	mov    rsi,r12
     35e:	mov    rdi,r13
     361:	call   366 <botlish_fn_3+0x7e>
			362: R_X86_64_PLT32	rt_int_cmp-0x4
     366:	mov    ecx,0x2
     36b:	test   rax,rax
     36e:	cmovl  rcx,QWORD PTR [rip+0x13a]        # 4b0 <botlish_fn_3+0x1c8>
     376:	mov    rax,r15
     379:	jmp    391 <botlish_fn_3+0xa9>
     37e:	mov    ecx,0x2
     383:	mov    rax,r15
     386:	cmp    r12,rax
     389:	cmovl  rcx,QWORD PTR [rip+0x11f]        # 4b0 <botlish_fn_3+0x1c8>
     391:	cmp    rcx,0x6
     395:	je     457 <botlish_fn_3+0x16f>
     39b:	mov    rsi,rax
     39e:	mov    rdx,r12
     3a1:	mov    rdi,r13
     3a4:	call   3a9 <botlish_fn_3+0xc1>
			3a5: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     3a9:	test   rax,rax
     3ac:	jne    3ba <botlish_fn_3+0xd2>
     3b2:	mov    rdi,r13
     3b5:	jmp    403 <botlish_fn_3+0x11b>
     3ba:	mov    QWORD PTR [rbx+0x10],rax
     3be:	mov    rsi,rax
     3c1:	mov    rdi,r13
     3c4:	call   3c9 <botlish_fn_3+0xe1>
			3c5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3c9:	test   rax,rax
     3cc:	mov    r15,rax
     3cf:	jne    3dd <botlish_fn_3+0xf5>
     3d5:	mov    rdi,r13
     3d8:	jmp    403 <botlish_fn_3+0x11b>
     3dd:	mov    r8d,0x1
     3e3:	mov    rcx,r14
     3e6:	mov    r9,r12
     3e9:	mov    rsi,r15
     3ec:	mov    rdi,r13
     3ef:	mov    rdx,r8
     3f2:	call   3f7 <botlish_fn_3+0x10f>
			3f3: R_X86_64_PLT32	rt_mutarray_copy-0x4
     3f7:	test   rax,rax
     3fa:	jne    42d <botlish_fn_3+0x145>
     400:	mov    rdi,r13
     403:	mov    rdi,r13
     406:	mov    QWORD PTR [rdi],rbx
     409:	xor    rax,rax
     40c:	mov    rbx,QWORD PTR [rsp]
     410:	mov    r12,QWORD PTR [rsp+0x8]
     415:	mov    r13,QWORD PTR [rsp+0x10]
     41a:	mov    r14,QWORD PTR [rsp+0x18]
     41f:	mov    r15,QWORD PTR [rsp+0x20]
     424:	add    rsp,0x30
     428:	mov    rsp,rbp
     42b:	pop    rbp
     42c:	ret
     42d:	mov    rdi,r13
     430:	mov    QWORD PTR [rdi],rbx
     433:	mov    rax,r15
     436:	mov    rbx,QWORD PTR [rsp]
     43a:	mov    r12,QWORD PTR [rsp+0x8]
     43f:	mov    r13,QWORD PTR [rsp+0x10]
     444:	mov    r14,QWORD PTR [rsp+0x18]
     449:	mov    r15,QWORD PTR [rsp+0x20]
     44e:	add    rsp,0x30
     452:	mov    rsp,rbp
     455:	pop    rbp
     456:	ret
     457:	mov    rdi,r13
     45a:	mov    QWORD PTR [rdi],rbx
     45d:	mov    rax,r14
     460:	mov    rbx,QWORD PTR [rsp]
     464:	mov    r12,QWORD PTR [rsp+0x8]
     469:	mov    r13,QWORD PTR [rsp+0x10]
     46e:	mov    r14,QWORD PTR [rsp+0x18]
     473:	mov    r15,QWORD PTR [rsp+0x20]
     478:	add    rsp,0x30
     47c:	mov    rsp,rbp
     47f:	pop    rbp
     480:	ret
     481:	mov    r13,rdi
     484:	call   489 <botlish_fn_3+0x1a1>
			485: R_X86_64_PLT32	rt_stack_overflow-0x4
     489:	xor    rax,rax
     48c:	mov    rbx,QWORD PTR [rsp]
     490:	mov    r12,QWORD PTR [rsp+0x8]
     495:	mov    r13,QWORD PTR [rsp+0x10]
     49a:	mov    r14,QWORD PTR [rsp+0x18]
     49f:	mov    r15,QWORD PTR [rsp+0x20]
     4a4:	add    rsp,0x30
     4a8:	mov    rsp,rbp
     4ab:	pop    rbp
     4ac:	ret
     4ad:	add    BYTE PTR [rax],al
     4af:	add    BYTE PTR [rsi],al
     4b1:	add    BYTE PTR [rax],al
     4b3:	add    BYTE PTR [rax],al
     4b5:	add    BYTE PTR [rax],al
	...

00000000000004b8 <botlish_entry_3: geo_grow<mutarray, int>>:
     4b8:	push   rbp
     4b9:	mov    rbp,rsp
     4bc:	mov    rsi,QWORD PTR [rdx]
     4bf:	mov    rdx,QWORD PTR [rdx+0x8]
     4c3:	call   4c8 <botlish_entry_3+0x10>
			4c4: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     4c8:	mov    rsp,rbp
     4cb:	pop    rbp
     4cc:	ret

00000000000004cd <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     4cd:	push   rbp
     4ce:	mov    rbp,rsp
     4d1:	sub    rsp,0x30
     4d5:	mov    QWORD PTR [rsp],rbx
     4d9:	mov    QWORD PTR [rsp+0x8],r12
     4de:	mov    QWORD PTR [rsp+0x10],r13
     4e3:	mov    QWORD PTR [rsp+0x18],r14
     4e8:	mov    QWORD PTR [rsp+0x20],r15
     4ed:	mov    r12,QWORD PTR [rdi]
     4f0:	mov    r8,QWORD PTR [rdi+0x8]
     4f4:	lea    rax,[r12+0x18]
     4f9:	cmp    rax,r8
     4fc:	ja     60f <botlish_fn_4+0x142>
     502:	lea    rax,[r12+0x18]
     507:	mov    QWORD PTR [rdi],rax
     50a:	mov    r13,rdi
     50d:	mov    QWORD PTR [r12],rsi
     511:	mov    QWORD PTR [r12+0x8],rdx
     516:	mov    rdi,rdx
     519:	mov    QWORD PTR [r12+0x10],rcx
     51e:	mov    r15,rcx
     521:	mov    rbx,rdi
     524:	mov    rdx,rbx
     527:	mov    rdi,r13
     52a:	call   52f <botlish_fn_4+0x62>
			52b: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     52f:	test   rax,rax
     532:	mov    r14,rax
     535:	jne    543 <botlish_fn_4+0x76>
     53b:	mov    rdi,r13
     53e:	jmp    567 <botlish_fn_4+0x9a>
     543:	mov    rax,r14
     546:	mov    QWORD PTR [r12],rax
     54a:	mov    rcx,r15
     54d:	mov    rdx,rbx
     550:	mov    rsi,r14
     553:	mov    rdi,r13
     556:	call   55b <botlish_fn_4+0x8e>
			557: R_X86_64_PLT32	rt_mutarray_set-0x4
     55b:	test   rax,rax
     55e:	jne    594 <botlish_fn_4+0xc7>
     564:	mov    rdi,r13
     567:	mov    rdi,r13
     56a:	mov    QWORD PTR [rdi],r12
     56d:	xor    rdx,rdx
     570:	mov    rax,rdx
     573:	mov    rbx,QWORD PTR [rsp]
     577:	mov    r12,QWORD PTR [rsp+0x8]
     57c:	mov    r13,QWORD PTR [rsp+0x10]
     581:	mov    r14,QWORD PTR [rsp+0x18]
     586:	mov    r15,QWORD PTR [rsp+0x20]
     58b:	add    rsp,0x30
     58f:	mov    rsp,rbp
     592:	pop    rbp
     593:	ret
     594:	mov    QWORD PTR [r12+0x10],0x3
     59d:	test   rbx,0x1
     5a4:	jne    5b2 <botlish_fn_4+0xe5>
     5aa:	mov    rdi,rbx
     5ad:	jmp    5cf <botlish_fn_4+0x102>
     5b2:	mov    rdx,rbx
     5b5:	add    rdx,0x2
     5b9:	mov    rdi,rbx
     5bc:	seto   al
     5bf:	test   al,al
     5c1:	jne    5cf <botlish_fn_4+0x102>
     5c7:	mov    rdi,r13
     5ca:	jmp    5e5 <botlish_fn_4+0x118>
     5cf:	mov    edx,0x3
     5d4:	mov    rsi,rdi
     5d7:	mov    rdi,r13
     5da:	call   5df <botlish_fn_4+0x112>
			5db: R_X86_64_PLT32	rt_int_add-0x4
     5df:	mov    rdx,rax
     5e2:	mov    rdi,r13
     5e5:	mov    rdi,r13
     5e8:	mov    QWORD PTR [rdi],r12
     5eb:	mov    rax,r14
     5ee:	mov    rbx,QWORD PTR [rsp]
     5f2:	mov    r12,QWORD PTR [rsp+0x8]
     5f7:	mov    r13,QWORD PTR [rsp+0x10]
     5fc:	mov    r14,QWORD PTR [rsp+0x18]
     601:	mov    r15,QWORD PTR [rsp+0x20]
     606:	add    rsp,0x30
     60a:	mov    rsp,rbp
     60d:	pop    rbp
     60e:	ret
     60f:	mov    r13,rdi
     612:	call   617 <botlish_fn_4+0x14a>
			613: R_X86_64_PLT32	rt_stack_overflow-0x4
     617:	xor    rdx,rdx
     61a:	mov    rax,rdx
     61d:	mov    rbx,QWORD PTR [rsp]
     621:	mov    r12,QWORD PTR [rsp+0x8]
     626:	mov    r13,QWORD PTR [rsp+0x10]
     62b:	mov    r14,QWORD PTR [rsp+0x18]
     630:	mov    r15,QWORD PTR [rsp+0x20]
     635:	add    rsp,0x30
     639:	mov    rsp,rbp
     63c:	pop    rbp
     63d:	ret

000000000000063e <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     63e:	push   rbp
     63f:	mov    rbp,rsp
     642:	ud2

0000000000000644 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     644:	push   rbp
     645:	mov    rbp,rsp
     648:	sub    rsp,0x30
     64c:	mov    QWORD PTR [rsp],rbx
     650:	mov    QWORD PTR [rsp+0x8],r12
     655:	mov    QWORD PTR [rsp+0x10],r13
     65a:	mov    QWORD PTR [rsp+0x18],r14
     65f:	mov    QWORD PTR [rsp+0x20],r15
     664:	mov    r12,QWORD PTR [rdi]
     667:	mov    r8,QWORD PTR [rdi+0x8]
     66b:	lea    rax,[r12+0x18]
     670:	cmp    rax,r8
     673:	ja     786 <botlish_fn_5+0x142>
     679:	lea    rax,[r12+0x18]
     67e:	mov    QWORD PTR [rdi],rax
     681:	mov    r13,rdi
     684:	mov    QWORD PTR [r12],rsi
     688:	mov    QWORD PTR [r12+0x8],rdx
     68d:	mov    rdi,rdx
     690:	mov    QWORD PTR [r12+0x10],rcx
     695:	mov    r15,rcx
     698:	mov    rbx,rdi
     69b:	mov    rdx,rbx
     69e:	mov    rdi,r13
     6a1:	call   6a6 <botlish_fn_5+0x62>
			6a2: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     6a6:	test   rax,rax
     6a9:	mov    r14,rax
     6ac:	jne    6ba <botlish_fn_5+0x76>
     6b2:	mov    rdi,r13
     6b5:	jmp    6de <botlish_fn_5+0x9a>
     6ba:	mov    rax,r14
     6bd:	mov    QWORD PTR [r12],rax
     6c1:	mov    rcx,r15
     6c4:	mov    rdx,rbx
     6c7:	mov    rsi,r14
     6ca:	mov    rdi,r13
     6cd:	call   6d2 <botlish_fn_5+0x8e>
			6ce: R_X86_64_PLT32	rt_mutarray_set-0x4
     6d2:	test   rax,rax
     6d5:	jne    70b <botlish_fn_5+0xc7>
     6db:	mov    rdi,r13
     6de:	mov    rdi,r13
     6e1:	mov    QWORD PTR [rdi],r12
     6e4:	xor    rdx,rdx
     6e7:	mov    rax,rdx
     6ea:	mov    rbx,QWORD PTR [rsp]
     6ee:	mov    r12,QWORD PTR [rsp+0x8]
     6f3:	mov    r13,QWORD PTR [rsp+0x10]
     6f8:	mov    r14,QWORD PTR [rsp+0x18]
     6fd:	mov    r15,QWORD PTR [rsp+0x20]
     702:	add    rsp,0x30
     706:	mov    rsp,rbp
     709:	pop    rbp
     70a:	ret
     70b:	mov    QWORD PTR [r12+0x10],0x3
     714:	test   rbx,0x1
     71b:	jne    729 <botlish_fn_5+0xe5>
     721:	mov    rdi,rbx
     724:	jmp    746 <botlish_fn_5+0x102>
     729:	mov    rdx,rbx
     72c:	add    rdx,0x2
     730:	mov    rdi,rbx
     733:	seto   al
     736:	test   al,al
     738:	jne    746 <botlish_fn_5+0x102>
     73e:	mov    rdi,r13
     741:	jmp    75c <botlish_fn_5+0x118>
     746:	mov    edx,0x3
     74b:	mov    rsi,rdi
     74e:	mov    rdi,r13
     751:	call   756 <botlish_fn_5+0x112>
			752: R_X86_64_PLT32	rt_int_add-0x4
     756:	mov    rdx,rax
     759:	mov    rdi,r13
     75c:	mov    rdi,r13
     75f:	mov    QWORD PTR [rdi],r12
     762:	mov    rax,r14
     765:	mov    rbx,QWORD PTR [rsp]
     769:	mov    r12,QWORD PTR [rsp+0x8]
     76e:	mov    r13,QWORD PTR [rsp+0x10]
     773:	mov    r14,QWORD PTR [rsp+0x18]
     778:	mov    r15,QWORD PTR [rsp+0x20]
     77d:	add    rsp,0x30
     781:	mov    rsp,rbp
     784:	pop    rbp
     785:	ret
     786:	mov    r13,rdi
     789:	call   78e <botlish_fn_5+0x14a>
			78a: R_X86_64_PLT32	rt_stack_overflow-0x4
     78e:	xor    rdx,rdx
     791:	mov    rax,rdx
     794:	mov    rbx,QWORD PTR [rsp]
     798:	mov    r12,QWORD PTR [rsp+0x8]
     79d:	mov    r13,QWORD PTR [rsp+0x10]
     7a2:	mov    r14,QWORD PTR [rsp+0x18]
     7a7:	mov    r15,QWORD PTR [rsp+0x20]
     7ac:	add    rsp,0x30
     7b0:	mov    rsp,rbp
     7b3:	pop    rbp
     7b4:	ret

00000000000007b5 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     7b5:	push   rbp
     7b6:	mov    rbp,rsp
     7b9:	ud2

00000000000007bb <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     7bb:	push   rbp
     7bc:	mov    rbp,rsp
     7bf:	sub    rsp,0x30
     7c3:	mov    QWORD PTR [rsp],rbx
     7c7:	mov    QWORD PTR [rsp+0x8],r12
     7cc:	mov    QWORD PTR [rsp+0x10],r13
     7d1:	mov    QWORD PTR [rsp+0x18],r14
     7d6:	mov    QWORD PTR [rsp+0x20],r15
     7db:	mov    r12,QWORD PTR [rdi]
     7de:	mov    r8,QWORD PTR [rdi+0x8]
     7e2:	lea    rax,[r12+0x18]
     7e7:	cmp    rax,r8
     7ea:	ja     8fd <botlish_fn_6+0x142>
     7f0:	lea    rax,[r12+0x18]
     7f5:	mov    QWORD PTR [rdi],rax
     7f8:	mov    r13,rdi
     7fb:	mov    QWORD PTR [r12],rsi
     7ff:	mov    QWORD PTR [r12+0x8],rdx
     804:	mov    rdi,rdx
     807:	mov    QWORD PTR [r12+0x10],rcx
     80c:	mov    r15,rcx
     80f:	mov    rbx,rdi
     812:	mov    rdx,rbx
     815:	mov    rdi,r13
     818:	call   81d <botlish_fn_6+0x62>
			819: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     81d:	test   rax,rax
     820:	mov    r14,rax
     823:	jne    831 <botlish_fn_6+0x76>
     829:	mov    rdi,r13
     82c:	jmp    855 <botlish_fn_6+0x9a>
     831:	mov    rax,r14
     834:	mov    QWORD PTR [r12],rax
     838:	mov    rcx,r15
     83b:	mov    rdx,rbx
     83e:	mov    rsi,r14
     841:	mov    rdi,r13
     844:	call   849 <botlish_fn_6+0x8e>
			845: R_X86_64_PLT32	rt_mutarray_set-0x4
     849:	test   rax,rax
     84c:	jne    882 <botlish_fn_6+0xc7>
     852:	mov    rdi,r13
     855:	mov    rdi,r13
     858:	mov    QWORD PTR [rdi],r12
     85b:	xor    rdx,rdx
     85e:	mov    rax,rdx
     861:	mov    rbx,QWORD PTR [rsp]
     865:	mov    r12,QWORD PTR [rsp+0x8]
     86a:	mov    r13,QWORD PTR [rsp+0x10]
     86f:	mov    r14,QWORD PTR [rsp+0x18]
     874:	mov    r15,QWORD PTR [rsp+0x20]
     879:	add    rsp,0x30
     87d:	mov    rsp,rbp
     880:	pop    rbp
     881:	ret
     882:	mov    QWORD PTR [r12+0x10],0x3
     88b:	test   rbx,0x1
     892:	jne    8a0 <botlish_fn_6+0xe5>
     898:	mov    rdi,rbx
     89b:	jmp    8bd <botlish_fn_6+0x102>
     8a0:	mov    rdx,rbx
     8a3:	add    rdx,0x2
     8a7:	mov    rdi,rbx
     8aa:	seto   al
     8ad:	test   al,al
     8af:	jne    8bd <botlish_fn_6+0x102>
     8b5:	mov    rdi,r13
     8b8:	jmp    8d3 <botlish_fn_6+0x118>
     8bd:	mov    edx,0x3
     8c2:	mov    rsi,rdi
     8c5:	mov    rdi,r13
     8c8:	call   8cd <botlish_fn_6+0x112>
			8c9: R_X86_64_PLT32	rt_int_add-0x4
     8cd:	mov    rdx,rax
     8d0:	mov    rdi,r13
     8d3:	mov    rdi,r13
     8d6:	mov    QWORD PTR [rdi],r12
     8d9:	mov    rax,r14
     8dc:	mov    rbx,QWORD PTR [rsp]
     8e0:	mov    r12,QWORD PTR [rsp+0x8]
     8e5:	mov    r13,QWORD PTR [rsp+0x10]
     8ea:	mov    r14,QWORD PTR [rsp+0x18]
     8ef:	mov    r15,QWORD PTR [rsp+0x20]
     8f4:	add    rsp,0x30
     8f8:	mov    rsp,rbp
     8fb:	pop    rbp
     8fc:	ret
     8fd:	mov    r13,rdi
     900:	call   905 <botlish_fn_6+0x14a>
			901: R_X86_64_PLT32	rt_stack_overflow-0x4
     905:	xor    rdx,rdx
     908:	mov    rax,rdx
     90b:	mov    rbx,QWORD PTR [rsp]
     90f:	mov    r12,QWORD PTR [rsp+0x8]
     914:	mov    r13,QWORD PTR [rsp+0x10]
     919:	mov    r14,QWORD PTR [rsp+0x18]
     91e:	mov    r15,QWORD PTR [rsp+0x20]
     923:	add    rsp,0x30
     927:	mov    rsp,rbp
     92a:	pop    rbp
     92b:	ret

000000000000092c <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     92c:	push   rbp
     92d:	mov    rbp,rsp
     930:	ud2

0000000000000932 <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     932:	push   rbp
     933:	mov    rbp,rsp
     936:	sub    rsp,0x30
     93a:	mov    QWORD PTR [rsp+0x10],rbx
     93f:	mov    QWORD PTR [rsp+0x18],r12
     944:	mov    QWORD PTR [rsp+0x20],r13
     949:	mov    r12,QWORD PTR [rdi+0x20]
     94d:	mov    r13,QWORD PTR [rdi+0x28]
     951:	lea    r9,[rsp]
     955:	mov    QWORD PTR [rdi+0x20],r9
     959:	mov    QWORD PTR [rdi+0x28],0x2
     961:	mov    rbx,rdi
     964:	mov    QWORD PTR [rsp],rsi
     968:	mov    QWORD PTR [rsp+0x8],rdx
     96d:	mov    rdi,rbx
     970:	call   975 <botlish_fn_7+0x43>
			971: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     975:	test   rax,rax
     978:	jne    9a1 <botlish_fn_7+0x6f>
     97e:	mov    QWORD PTR [rbx+0x20],r12
     982:	mov    QWORD PTR [rbx+0x28],r13
     986:	xor    rax,rax
     989:	mov    rbx,QWORD PTR [rsp+0x10]
     98e:	mov    r12,QWORD PTR [rsp+0x18]
     993:	mov    r13,QWORD PTR [rsp+0x20]
     998:	add    rsp,0x30
     99c:	mov    rsp,rbp
     99f:	pop    rbp
     9a0:	ret
     9a1:	mov    QWORD PTR [rbx+0x20],r12
     9a5:	mov    QWORD PTR [rbx+0x28],r13
     9a9:	mov    rbx,QWORD PTR [rsp+0x10]
     9ae:	mov    r12,QWORD PTR [rsp+0x18]
     9b3:	mov    r13,QWORD PTR [rsp+0x20]
     9b8:	add    rsp,0x30
     9bc:	mov    rsp,rbp
     9bf:	pop    rbp
     9c0:	ret

00000000000009c1 <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     9c1:	push   rbp
     9c2:	mov    rbp,rsp
     9c5:	mov    rsi,QWORD PTR [rdx]
     9c8:	mov    rdx,QWORD PTR [rdx+0x8]
     9cc:	call   9d1 <botlish_entry_7+0x10>
			9cd: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     9d1:	mov    rsp,rbp
     9d4:	pop    rbp
     9d5:	ret
	...

00000000000009d8 <botlish_fn_8: peek<str, int>>:
     9d8:	push   rbp
     9d9:	mov    rbp,rsp
     9dc:	sub    rsp,0x50
     9e0:	mov    QWORD PTR [rsp+0x20],rbx
     9e5:	mov    QWORD PTR [rsp+0x28],r12
     9ea:	mov    QWORD PTR [rsp+0x30],r13
     9ef:	mov    QWORD PTR [rsp+0x38],r14
     9f4:	mov    QWORD PTR [rsp+0x40],r15
     9f9:	mov    rbx,QWORD PTR [rdi+0x20]
     9fd:	mov    r14,QWORD PTR [rdi+0x28]
     a01:	lea    rax,[rsp]
     a05:	mov    QWORD PTR [rdi+0x20],rax
     a09:	mov    QWORD PTR [rdi+0x28],0x3
     a11:	mov    QWORD PTR [rsp],rsi
     a15:	mov    r15,rsi
     a18:	mov    QWORD PTR [rsp+0x8],rdx
     a1d:	mov    r13,rdx
     a20:	mov    r12,rdi
     a23:	mov    rsi,r15
     a26:	call   a2b <botlish_fn_8+0x53>
			a27: R_X86_64_PLT32	rt_str_len-0x4
     a2b:	mov    rcx,r13
     a2e:	and    rcx,rax
     a31:	mov    rdx,rax
     a34:	test   rcx,0x1
     a3b:	jne    a61 <botlish_fn_8+0x89>
     a41:	mov    rsi,r13
     a44:	mov    rdi,r12
     a47:	call   a4c <botlish_fn_8+0x74>
			a48: R_X86_64_PLT32	rt_int_cmp-0x4
     a4c:	mov    ecx,0x2
     a51:	test   rax,rax
     a54:	cmovge rcx,QWORD PTR [rip+0x10c]        # b68 <botlish_fn_8+0x190>
     a5c:	jmp    a71 <botlish_fn_8+0x99>
     a61:	mov    ecx,0x2
     a66:	cmp    r13,rdx
     a69:	cmovge rcx,QWORD PTR [rip+0xf7]        # b68 <botlish_fn_8+0x190>
     a71:	cmp    rcx,0x6
     a75:	je     b2d <botlish_fn_8+0x155>
     a7b:	mov    QWORD PTR [rsp+0x10],0x3
     a84:	test   r13,0x1
     a8b:	je     aa3 <botlish_fn_8+0xcb>
     a91:	mov    rcx,r13
     a94:	add    rcx,0x2
     a98:	seto   al
     a9b:	test   al,al
     a9d:	je     ab6 <botlish_fn_8+0xde>
     aa3:	mov    edx,0x3
     aa8:	mov    rsi,r13
     aab:	mov    rdi,r12
     aae:	call   ab3 <botlish_fn_8+0xdb>
			aaf: R_X86_64_PLT32	rt_int_add-0x4
     ab3:	mov    rcx,rax
     ab6:	mov    QWORD PTR [rsp+0x10],rcx
     abb:	mov    rdx,r13
     abe:	mov    rsi,r15
     ac1:	mov    rdi,r12
     ac4:	call   ac9 <botlish_fn_8+0xf1>
			ac5: R_X86_64_PLT32	rt_substr-0x4
     ac9:	test   rax,rax
     acc:	jne    b01 <botlish_fn_8+0x129>
     ad2:	mov    QWORD PTR [r12+0x20],rbx
     ad7:	mov    QWORD PTR [r12+0x28],r14
     adc:	xor    rax,rax
     adf:	mov    rbx,QWORD PTR [rsp+0x20]
     ae4:	mov    r12,QWORD PTR [rsp+0x28]
     ae9:	mov    r13,QWORD PTR [rsp+0x30]
     aee:	mov    r14,QWORD PTR [rsp+0x38]
     af3:	mov    r15,QWORD PTR [rsp+0x40]
     af8:	add    rsp,0x50
     afc:	mov    rsp,rbp
     aff:	pop    rbp
     b00:	ret
     b01:	mov    QWORD PTR [r12+0x20],rbx
     b06:	mov    QWORD PTR [r12+0x28],r14
     b0b:	mov    rbx,QWORD PTR [rsp+0x20]
     b10:	mov    r12,QWORD PTR [rsp+0x28]
     b15:	mov    r13,QWORD PTR [rsp+0x30]
     b1a:	mov    r14,QWORD PTR [rsp+0x38]
     b1f:	mov    r15,QWORD PTR [rsp+0x40]
     b24:	add    rsp,0x50
     b28:	mov    rsp,rbp
     b2b:	pop    rbp
     b2c:	ret
     b2d:	mov    rax,QWORD PTR [r12+0x10]
     b32:	mov    rax,QWORD PTR [rax]
     b35:	mov    QWORD PTR [r12+0x20],rbx
     b3a:	mov    QWORD PTR [r12+0x28],r14
     b3f:	mov    rbx,QWORD PTR [rsp+0x20]
     b44:	mov    r12,QWORD PTR [rsp+0x28]
     b49:	mov    r13,QWORD PTR [rsp+0x30]
     b4e:	mov    r14,QWORD PTR [rsp+0x38]
     b53:	mov    r15,QWORD PTR [rsp+0x40]
     b58:	add    rsp,0x50
     b5c:	mov    rsp,rbp
     b5f:	pop    rbp
     b60:	ret
     b61:	add    BYTE PTR [rax],al
     b63:	add    BYTE PTR [rax],al
     b65:	add    BYTE PTR [rax],al
     b67:	add    BYTE PTR [rsi],al
     b69:	add    BYTE PTR [rax],al
     b6b:	add    BYTE PTR [rax],al
     b6d:	add    BYTE PTR [rax],al
	...

0000000000000b70 <botlish_entry_8: peek<str, int>>:
     b70:	push   rbp
     b71:	mov    rbp,rsp
     b74:	mov    rsi,QWORD PTR [rdx]
     b77:	mov    rdx,QWORD PTR [rdx+0x8]
     b7b:	call   b80 <botlish_entry_8+0x10>
			b7c: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     b80:	mov    rsp,rbp
     b83:	pop    rbp
     b84:	ret
     b85:	add    BYTE PTR [rax],al
	...

0000000000000b88 <botlish_fn_9: peek<str, int>>:
     b88:	push   rbp
     b89:	mov    rbp,rsp
     b8c:	sub    rsp,0x60
     b90:	mov    QWORD PTR [rsp+0x30],rbx
     b95:	mov    QWORD PTR [rsp+0x38],r12
     b9a:	mov    QWORD PTR [rsp+0x40],r13
     b9f:	mov    QWORD PTR [rsp+0x48],r14
     ba4:	mov    QWORD PTR [rsp+0x50],r15
     ba9:	mov    r15,rcx
     bac:	mov    rbx,QWORD PTR [rdi+0x20]
     bb0:	mov    r14,QWORD PTR [rdi+0x28]
     bb4:	lea    rax,[rsp]
     bb8:	mov    QWORD PTR [rdi+0x20],rax
     bbc:	mov    QWORD PTR [rdi+0x28],0x3
     bc4:	mov    QWORD PTR [rsp],rsi
     bc8:	mov    QWORD PTR [rsp+0x18],rsi
     bcd:	mov    QWORD PTR [rsp+0x8],rdx
     bd2:	mov    r13,rdx
     bd5:	mov    r12,rdi
     bd8:	mov    rsi,QWORD PTR [rsp+0x18]
     bdd:	call   be2 <botlish_fn_9+0x5a>
			bde: R_X86_64_PLT32	rt_str_len-0x4
     be2:	mov    rcx,r13
     be5:	and    rcx,rax
     be8:	mov    rdx,rax
     beb:	test   rcx,0x1
     bf2:	jne    c18 <botlish_fn_9+0x90>
     bf8:	mov    rsi,r13
     bfb:	mov    rdi,r12
     bfe:	call   c03 <botlish_fn_9+0x7b>
			bff: R_X86_64_PLT32	rt_int_cmp-0x4
     c03:	mov    ecx,0x2
     c08:	test   rax,rax
     c0b:	cmovge rcx,QWORD PTR [rip+0x13d]        # d50 <botlish_fn_9+0x1c8>
     c13:	jmp    c28 <botlish_fn_9+0xa0>
     c18:	mov    ecx,0x2
     c1d:	cmp    r13,rdx
     c20:	cmovge rcx,QWORD PTR [rip+0x128]        # d50 <botlish_fn_9+0x1c8>
     c28:	cmp    rcx,0x6
     c2c:	je     d06 <botlish_fn_9+0x17e>
     c32:	mov    QWORD PTR [rsp+0x10],0x3
     c3b:	test   r13,0x1
     c42:	je     c64 <botlish_fn_9+0xdc>
     c48:	mov    rax,r13
     c4b:	add    rax,0x2
     c4f:	seto   cl
     c52:	test   cl,cl
     c54:	jne    c64 <botlish_fn_9+0xdc>
     c5a:	mov    QWORD PTR [rsp+0x20],rax
     c5f:	jmp    c79 <botlish_fn_9+0xf1>
     c64:	mov    edx,0x3
     c69:	mov    rsi,r13
     c6c:	mov    rdi,r12
     c6f:	call   c74 <botlish_fn_9+0xec>
			c70: R_X86_64_PLT32	rt_int_add-0x4
     c74:	mov    QWORD PTR [rsp+0x20],rax
     c79:	mov    rcx,QWORD PTR [rsp+0x20]
     c7e:	mov    rdx,r13
     c81:	mov    rsi,QWORD PTR [rsp+0x18]
     c86:	mov    rdi,r12
     c89:	call   c8e <botlish_fn_9+0x106>
			c8a: R_X86_64_PLT32	rt_str_region_check-0x4
     c8e:	test   rax,rax
     c91:	jne    cc6 <botlish_fn_9+0x13e>
     c97:	mov    QWORD PTR [r12+0x20],rbx
     c9c:	mov    QWORD PTR [r12+0x28],r14
     ca1:	xor    rax,rax
     ca4:	mov    rbx,QWORD PTR [rsp+0x30]
     ca9:	mov    r12,QWORD PTR [rsp+0x38]
     cae:	mov    r13,QWORD PTR [rsp+0x40]
     cb3:	mov    r14,QWORD PTR [rsp+0x48]
     cb8:	mov    r15,QWORD PTR [rsp+0x50]
     cbd:	add    rsp,0x60
     cc1:	mov    rsp,rbp
     cc4:	pop    rbp
     cc5:	ret
     cc6:	mov    QWORD PTR [r12+0x20],rbx
     ccb:	mov    QWORD PTR [r12+0x28],r14
     cd0:	mov    rcx,r15
     cd3:	mov    QWORD PTR [rcx],r13
     cd6:	mov    rax,QWORD PTR [rsp+0x20]
     cdb:	mov    QWORD PTR [rcx+0x8],rax
     cdf:	mov    rax,QWORD PTR [rsp+0x18]
     ce4:	mov    rbx,QWORD PTR [rsp+0x30]
     ce9:	mov    r12,QWORD PTR [rsp+0x38]
     cee:	mov    r13,QWORD PTR [rsp+0x40]
     cf3:	mov    r14,QWORD PTR [rsp+0x48]
     cf8:	mov    r15,QWORD PTR [rsp+0x50]
     cfd:	add    rsp,0x60
     d01:	mov    rsp,rbp
     d04:	pop    rbp
     d05:	ret
     d06:	mov    rcx,r15
     d09:	mov    rax,QWORD PTR [r12+0x10]
     d0e:	mov    rax,QWORD PTR [rax]
     d11:	mov    QWORD PTR [r12+0x20],rbx
     d16:	mov    QWORD PTR [r12+0x28],r14
     d1b:	mov    QWORD PTR [rcx],0x1
     d22:	mov    QWORD PTR [rcx+0x8],0x1
     d2a:	mov    rbx,QWORD PTR [rsp+0x30]
     d2f:	mov    r12,QWORD PTR [rsp+0x38]
     d34:	mov    r13,QWORD PTR [rsp+0x40]
     d39:	mov    r14,QWORD PTR [rsp+0x48]
     d3e:	mov    r15,QWORD PTR [rsp+0x50]
     d43:	add    rsp,0x60
     d47:	mov    rsp,rbp
     d4a:	pop    rbp
     d4b:	ret
     d4c:	add    BYTE PTR [rax],al
     d4e:	add    BYTE PTR [rax],al
     d50:	(bad)
     d51:	add    BYTE PTR [rax],al
     d53:	add    BYTE PTR [rax],al
     d55:	add    BYTE PTR [rax],al
	...

0000000000000d58 <botlish_entry_9: peek<str, int>>:
     d58:	push   rbp
     d59:	mov    rbp,rsp
     d5c:	ud2

0000000000000d5e <botlish_fn_10: scan_unquoted<str, int, int>>:
     d5e:	push   rbp
     d5f:	mov    rbp,rsp
     d62:	sub    rsp,0x60
     d66:	mov    QWORD PTR [rsp+0x30],rbx
     d6b:	mov    QWORD PTR [rsp+0x38],r12
     d70:	mov    QWORD PTR [rsp+0x40],r13
     d75:	mov    QWORD PTR [rsp+0x48],r14
     d7a:	mov    QWORD PTR [rsp+0x50],r15
     d7f:	mov    r14,QWORD PTR [rdi]
     d82:	mov    rax,QWORD PTR [rdi+0x8]
     d86:	lea    r8,[r14+0x20]
     d8a:	cmp    r8,rax
     d8d:	ja     f9d <botlish_fn_10+0x23f>
     d93:	lea    rax,[r14+0x20]
     d97:	mov    QWORD PTR [rdi],rax
     d9a:	mov    r15,rdi
     d9d:	mov    QWORD PTR [r14+0x18],0x0
     da5:	mov    QWORD PTR [r14],rsi
     da8:	mov    QWORD PTR [rsp+0x10],rsi
     dad:	mov    QWORD PTR [r14+0x8],rdx
     db1:	mov    QWORD PTR [rsp+0x18],rdx
     db6:	mov    QWORD PTR [r14+0x10],rcx
     dba:	lea    rbx,[rsp]
     dbe:	mov    QWORD PTR [rsp+0x20],rcx
     dc3:	mov    rcx,rbx
     dc6:	mov    rdx,QWORD PTR [rsp+0x20]
     dcb:	mov    rsi,QWORD PTR [rsp+0x10]
     dd0:	mov    rdi,r15
     dd3:	call   dd8 <botlish_fn_10+0x7a>
			dd4: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     dd8:	mov    rcx,rax
     ddb:	mov    QWORD PTR [rsp+0x28],rax
     de0:	test   rax,rcx
     de3:	jne    df1 <botlish_fn_10+0x93>
     de9:	mov    rdi,r15
     dec:	jmp    f42 <botlish_fn_10+0x1e4>
     df1:	mov    r12,QWORD PTR [rsp]
     df5:	mov    r13,QWORD PTR [rsp+0x8]
     dfa:	mov    rdi,r15
     dfd:	mov    rcx,QWORD PTR [rdi+0x10]
     e01:	mov    r8,QWORD PTR [rcx]
     e04:	mov    rcx,r13
     e07:	mov    rdx,r12
     e0a:	mov    rsi,QWORD PTR [rsp+0x28]
     e0f:	call   e14 <botlish_fn_10+0xb6>
			e10: R_X86_64_PLT32	rt_str_region_eq-0x4
     e14:	cmp    rax,0x6
     e18:	je     e57 <botlish_fn_10+0xf9>
     e1e:	mov    rdi,r15
     e21:	mov    rax,QWORD PTR [rdi+0x10]
     e25:	mov    r8,QWORD PTR [rax+0x8]
     e29:	mov    rcx,r13
     e2c:	mov    rdx,r12
     e2f:	mov    rsi,QWORD PTR [rsp+0x28]
     e34:	call   e39 <botlish_fn_10+0xdb>
			e35: R_X86_64_PLT32	rt_str_region_eq-0x4
     e39:	cmp    rax,0x6
     e3d:	je     e4d <botlish_fn_10+0xef>
     e43:	mov    eax,0x2
     e48:	jmp    e5c <botlish_fn_10+0xfe>
     e4d:	mov    eax,0x6
     e52:	jmp    e5c <botlish_fn_10+0xfe>
     e57:	mov    eax,0x6
     e5c:	cmp    rax,0x6
     e60:	je     e9f <botlish_fn_10+0x141>
     e66:	mov    rdi,r15
     e69:	mov    rcx,QWORD PTR [rdi+0x10]
     e6d:	mov    r8,QWORD PTR [rcx+0x10]
     e71:	mov    rcx,r13
     e74:	mov    rdx,r12
     e77:	mov    rsi,QWORD PTR [rsp+0x28]
     e7c:	call   e81 <botlish_fn_10+0x123>
			e7d: R_X86_64_PLT32	rt_str_region_eq-0x4
     e81:	cmp    rax,0x6
     e85:	je     e95 <botlish_fn_10+0x137>
     e8b:	mov    eax,0x2
     e90:	jmp    ea4 <botlish_fn_10+0x146>
     e95:	mov    eax,0x6
     e9a:	jmp    ea4 <botlish_fn_10+0x146>
     e9f:	mov    eax,0x6
     ea4:	cmp    rax,0x6
     ea8:	je     f1f <botlish_fn_10+0x1c1>
     eae:	mov    QWORD PTR [r14+0x18],0x3
     eb6:	mov    rsi,QWORD PTR [rsp+0x20]
     ebb:	test   rsi,0x1
     ec2:	je     ee9 <botlish_fn_10+0x18b>
     ec8:	mov    rsi,QWORD PTR [rsp+0x20]
     ecd:	mov    rax,rsi
     ed0:	add    rax,0x2
     ed4:	seto   cl
     ed7:	test   cl,cl
     ed9:	jne    ee9 <botlish_fn_10+0x18b>
     edf:	mov    rsi,QWORD PTR [rsp+0x10]
     ee4:	jmp    f00 <botlish_fn_10+0x1a2>
     ee9:	mov    edx,0x3
     eee:	mov    rsi,QWORD PTR [rsp+0x20]
     ef3:	mov    rdi,r15
     ef6:	call   efb <botlish_fn_10+0x19d>
			ef7: R_X86_64_PLT32	rt_int_add-0x4
     efb:	mov    rsi,QWORD PTR [rsp+0x10]
     f00:	mov    QWORD PTR [r14],rsi
     f03:	mov    rdx,QWORD PTR [rsp+0x18]
     f08:	mov    QWORD PTR [r14+0x8],rdx
     f0c:	mov    QWORD PTR [r14+0x10],rax
     f10:	mov    QWORD PTR [rsp+0x10],rsi
     f15:	mov    QWORD PTR [rsp+0x20],rax
     f1a:	jmp    dc3 <botlish_fn_10+0x65>
     f1f:	mov    rdx,QWORD PTR [rsp+0x18]
     f24:	mov    rsi,QWORD PTR [rsp+0x10]
     f29:	mov    rcx,QWORD PTR [rsp+0x20]
     f2e:	mov    rdi,r15
     f31:	call   f36 <botlish_fn_10+0x1d8>
			f32: R_X86_64_PLT32	rt_substr-0x4
     f36:	test   rax,rax
     f39:	jne    f70 <botlish_fn_10+0x212>
     f3f:	mov    rdi,r15
     f42:	mov    rdi,r15
     f45:	mov    QWORD PTR [rdi],r14
     f48:	xor    rdx,rdx
     f4b:	mov    rax,rdx
     f4e:	mov    rbx,QWORD PTR [rsp+0x30]
     f53:	mov    r12,QWORD PTR [rsp+0x38]
     f58:	mov    r13,QWORD PTR [rsp+0x40]
     f5d:	mov    r14,QWORD PTR [rsp+0x48]
     f62:	mov    r15,QWORD PTR [rsp+0x50]
     f67:	add    rsp,0x60
     f6b:	mov    rsp,rbp
     f6e:	pop    rbp
     f6f:	ret
     f70:	mov    rdi,r15
     f73:	mov    QWORD PTR [rdi],r14
     f76:	mov    rdx,QWORD PTR [rsp+0x20]
     f7b:	mov    rbx,QWORD PTR [rsp+0x30]
     f80:	mov    r12,QWORD PTR [rsp+0x38]
     f85:	mov    r13,QWORD PTR [rsp+0x40]
     f8a:	mov    r14,QWORD PTR [rsp+0x48]
     f8f:	mov    r15,QWORD PTR [rsp+0x50]
     f94:	add    rsp,0x60
     f98:	mov    rsp,rbp
     f9b:	pop    rbp
     f9c:	ret
     f9d:	mov    r15,rdi
     fa0:	call   fa5 <botlish_fn_10+0x247>
			fa1: R_X86_64_PLT32	rt_stack_overflow-0x4
     fa5:	xor    rdx,rdx
     fa8:	mov    rax,rdx
     fab:	mov    rbx,QWORD PTR [rsp+0x30]
     fb0:	mov    r12,QWORD PTR [rsp+0x38]
     fb5:	mov    r13,QWORD PTR [rsp+0x40]
     fba:	mov    r14,QWORD PTR [rsp+0x48]
     fbf:	mov    r15,QWORD PTR [rsp+0x50]
     fc4:	add    rsp,0x60
     fc8:	mov    rsp,rbp
     fcb:	pop    rbp
     fcc:	ret

0000000000000fcd <botlish_entry_10: scan_unquoted<str, int, int>>:
     fcd:	push   rbp
     fce:	mov    rbp,rsp
     fd1:	ud2

0000000000000fd3 <botlish_fn_11: scan_quoted<str, int, str>>:
     fd3:	push   rbp
     fd4:	mov    rbp,rsp
     fd7:	sub    rsp,0x50
     fdb:	mov    QWORD PTR [rsp+0x20],rbx
     fe0:	mov    QWORD PTR [rsp+0x28],r12
     fe5:	mov    QWORD PTR [rsp+0x30],r13
     fea:	mov    QWORD PTR [rsp+0x38],r14
     fef:	mov    QWORD PTR [rsp+0x40],r15
     ff4:	mov    r13,QWORD PTR [rdi]
     ff7:	mov    rax,QWORD PTR [rdi+0x8]
     ffb:	lea    r8,[r13+0x28]
     fff:	cmp    r8,rax
    1002:	ja     12d4 <botlish_fn_11+0x301>
    1008:	lea    rax,[r13+0x28]
    100c:	mov    QWORD PTR [rdi],rax
    100f:	mov    r14,rdi
    1012:	mov    QWORD PTR [r13+0x18],0x0
    101a:	mov    QWORD PTR [r13+0x20],0x0
    1022:	mov    QWORD PTR [r13+0x0],rsi
    1026:	mov    QWORD PTR [r13+0x8],rdx
    102a:	mov    QWORD PTR [r13+0x10],rcx
    102e:	lea    rbx,[rsp]
    1032:	mov    r12,rsi
    1035:	mov    r15,rdx
    1038:	mov    QWORD PTR [rsp+0x10],rcx
    103d:	mov    rdx,r15
    1040:	mov    rsi,r12
    1043:	mov    rdi,r14
    1046:	call   104b <botlish_fn_11+0x78>
			1047: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    104b:	test   rax,rax
    104e:	jne    105c <botlish_fn_11+0x89>
    1054:	mov    rdi,r14
    1057:	jmp    128d <botlish_fn_11+0x2ba>
    105c:	mov    QWORD PTR [r13+0x18],rax
    1060:	mov    rdi,r14
    1063:	mov    QWORD PTR [rsp+0x18],rax
    1068:	mov    rdx,QWORD PTR [rdi+0x10]
    106c:	mov    rsi,QWORD PTR [rdx+0x18]
    1070:	mov    edx,0x1
    1075:	mov    ecx,0x3
    107a:	mov    r8,QWORD PTR [rsp+0x18]
    107f:	call   1084 <botlish_fn_11+0xb1>
			1080: R_X86_64_PLT32	rt_str_region_eq-0x4
    1084:	cmp    rax,0x6
    1088:	je     1115 <botlish_fn_11+0x142>
    108e:	mov    QWORD PTR [r13+0x20],0x3
    1096:	mov    rsi,r15
    1099:	test   rsi,0x1
    10a0:	je     10c2 <botlish_fn_11+0xef>
    10a6:	mov    r8,rsi
    10a9:	add    r8,0x2
    10ad:	seto   r10b
    10b1:	test   r10b,r10b
    10b4:	jne    10c2 <botlish_fn_11+0xef>
    10ba:	mov    rsi,r8
    10bd:	jmp    10d2 <botlish_fn_11+0xff>
    10c2:	mov    edx,0x3
    10c7:	mov    rdi,r14
    10ca:	call   10cf <botlish_fn_11+0xfc>
			10cb: R_X86_64_PLT32	rt_int_add-0x4
    10cf:	mov    rsi,rax
    10d2:	mov    QWORD PTR [r13+0x8],rsi
    10d6:	mov    r15,rsi
    10d9:	mov    rsi,QWORD PTR [rsp+0x10]
    10de:	mov    rdx,QWORD PTR [rsp+0x18]
    10e3:	mov    rdi,r14
    10e6:	call   10eb <botlish_fn_11+0x118>
			10e7: R_X86_64_PLT32	rt_str_cat-0x4
    10eb:	test   rax,rax
    10ee:	jne    10fc <botlish_fn_11+0x129>
    10f4:	mov    rdi,r14
    10f7:	jmp    128d <botlish_fn_11+0x2ba>
    10fc:	mov    QWORD PTR [r13+0x0],r12
    1100:	mov    rsi,r15
    1103:	mov    QWORD PTR [r13+0x8],rsi
    1107:	mov    QWORD PTR [r13+0x10],rax
    110b:	mov    QWORD PTR [rsp+0x10],rax
    1110:	jmp    103d <botlish_fn_11+0x6a>
    1115:	mov    QWORD PTR [r13+0x18],0x3
    111d:	mov    rsi,r15
    1120:	test   rsi,0x1
    1127:	je     1142 <botlish_fn_11+0x16f>
    112d:	mov    rsi,r15
    1130:	mov    rdx,rsi
    1133:	add    rdx,0x2
    1137:	seto   al
    113a:	test   al,al
    113c:	je     1155 <botlish_fn_11+0x182>
    1142:	mov    edx,0x3
    1147:	mov    rsi,r15
    114a:	mov    rdi,r14
    114d:	call   1152 <botlish_fn_11+0x17f>
			114e: R_X86_64_PLT32	rt_int_add-0x4
    1152:	mov    rdx,rax
    1155:	mov    QWORD PTR [r13+0x18],rdx
    1159:	mov    rcx,rbx
    115c:	mov    rsi,r12
    115f:	mov    rdi,r14
    1162:	call   1167 <botlish_fn_11+0x194>
			1163: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1167:	test   rax,rax
    116a:	mov    rsi,rax
    116d:	jne    117b <botlish_fn_11+0x1a8>
    1173:	mov    rdi,r14
    1176:	jmp    128d <botlish_fn_11+0x2ba>
    117b:	mov    rdx,QWORD PTR [rsp]
    117f:	mov    rcx,QWORD PTR [rsp+0x8]
    1184:	mov    rdi,r14
    1187:	mov    rax,QWORD PTR [rdi+0x10]
    118b:	mov    r8,QWORD PTR [rax+0x18]
    118f:	call   1194 <botlish_fn_11+0x1c1>
			1190: R_X86_64_PLT32	rt_str_region_eq-0x4
    1194:	cmp    rax,0x6
    1198:	je     1216 <botlish_fn_11+0x243>
    119e:	mov    QWORD PTR [r13+0x0],0x3
    11a6:	mov    rsi,r15
    11a9:	test   rsi,0x1
    11b0:	je     11d3 <botlish_fn_11+0x200>
    11b6:	mov    rsi,r15
    11b9:	mov    rdx,rsi
    11bc:	add    rdx,0x2
    11c0:	seto   al
    11c3:	test   al,al
    11c5:	jne    11d3 <botlish_fn_11+0x200>
    11cb:	mov    rdi,r14
    11ce:	jmp    11e9 <botlish_fn_11+0x216>
    11d3:	mov    edx,0x3
    11d8:	mov    rsi,r15
    11db:	mov    rdi,r14
    11de:	call   11e3 <botlish_fn_11+0x210>
			11df: R_X86_64_PLT32	rt_int_add-0x4
    11e3:	mov    rdx,rax
    11e6:	mov    rdi,r14
    11e9:	mov    rdi,r14
    11ec:	mov    QWORD PTR [rdi],r13
    11ef:	mov    rax,QWORD PTR [rsp+0x10]
    11f4:	mov    rbx,QWORD PTR [rsp+0x20]
    11f9:	mov    r12,QWORD PTR [rsp+0x28]
    11fe:	mov    r13,QWORD PTR [rsp+0x30]
    1203:	mov    r14,QWORD PTR [rsp+0x38]
    1208:	mov    r15,QWORD PTR [rsp+0x40]
    120d:	add    rsp,0x50
    1211:	mov    rsp,rbp
    1214:	pop    rbp
    1215:	ret
    1216:	mov    QWORD PTR [r13+0x18],0x5
    121e:	mov    rsi,r15
    1221:	test   rsi,0x1
    1228:	je     124e <botlish_fn_11+0x27b>
    122e:	mov    rsi,r15
    1231:	mov    rax,rsi
    1234:	add    rax,0x4
    1238:	seto   cl
    123b:	test   cl,cl
    123d:	jne    124e <botlish_fn_11+0x27b>
    1243:	mov    rsi,rax
    1246:	mov    r15,rax
    1249:	jmp    1264 <botlish_fn_11+0x291>
    124e:	mov    edx,0x5
    1253:	mov    rsi,r15
    1256:	mov    rdi,r14
    1259:	call   125e <botlish_fn_11+0x28b>
			125a: R_X86_64_PLT32	rt_int_add-0x4
    125e:	mov    rsi,rax
    1261:	mov    r15,rax
    1264:	mov    QWORD PTR [r13+0x8],rsi
    1268:	mov    rdi,r14
    126b:	mov    rax,QWORD PTR [rdi+0x10]
    126f:	mov    rdx,QWORD PTR [rax+0x18]
    1273:	mov    QWORD PTR [r13+0x18],rdx
    1277:	mov    rsi,QWORD PTR [rsp+0x10]
    127c:	call   1281 <botlish_fn_11+0x2ae>
			127d: R_X86_64_PLT32	rt_str_cat-0x4
    1281:	test   rax,rax
    1284:	jne    12bb <botlish_fn_11+0x2e8>
    128a:	mov    rdi,r14
    128d:	mov    rdi,r14
    1290:	mov    QWORD PTR [rdi],r13
    1293:	xor    rdx,rdx
    1296:	mov    rax,rdx
    1299:	mov    rbx,QWORD PTR [rsp+0x20]
    129e:	mov    r12,QWORD PTR [rsp+0x28]
    12a3:	mov    r13,QWORD PTR [rsp+0x30]
    12a8:	mov    r14,QWORD PTR [rsp+0x38]
    12ad:	mov    r15,QWORD PTR [rsp+0x40]
    12b2:	add    rsp,0x50
    12b6:	mov    rsp,rbp
    12b9:	pop    rbp
    12ba:	ret
    12bb:	mov    QWORD PTR [r13+0x0],r12
    12bf:	mov    rsi,r15
    12c2:	mov    QWORD PTR [r13+0x8],rsi
    12c6:	mov    QWORD PTR [r13+0x10],rax
    12ca:	mov    QWORD PTR [rsp+0x10],rax
    12cf:	jmp    103d <botlish_fn_11+0x6a>
    12d4:	mov    r14,rdi
    12d7:	call   12dc <botlish_fn_11+0x309>
			12d8: R_X86_64_PLT32	rt_stack_overflow-0x4
    12dc:	xor    rdx,rdx
    12df:	mov    rax,rdx
    12e2:	mov    rbx,QWORD PTR [rsp+0x20]
    12e7:	mov    r12,QWORD PTR [rsp+0x28]
    12ec:	mov    r13,QWORD PTR [rsp+0x30]
    12f1:	mov    r14,QWORD PTR [rsp+0x38]
    12f6:	mov    r15,QWORD PTR [rsp+0x40]
    12fb:	add    rsp,0x50
    12ff:	mov    rsp,rbp
    1302:	pop    rbp
    1303:	ret

0000000000001304 <botlish_entry_11: scan_quoted<str, int, str>>:
    1304:	push   rbp
    1305:	mov    rbp,rsp
    1308:	ud2

000000000000130a <botlish_fn_12: scan_field<str, int>>:
    130a:	push   rbp
    130b:	mov    rbp,rsp
    130e:	sub    rsp,0x30
    1312:	mov    QWORD PTR [rsp+0x10],rbx
    1317:	mov    QWORD PTR [rsp+0x18],r12
    131c:	mov    QWORD PTR [rsp+0x20],r13
    1321:	mov    QWORD PTR [rsp+0x28],r14
    1326:	mov    rbx,QWORD PTR [rdi]
    1329:	mov    rax,QWORD PTR [rdi+0x8]
    132d:	lea    rcx,[rbx+0x18]
    1331:	cmp    rcx,rax
    1334:	ja     1496 <botlish_fn_12+0x18c>
    133a:	lea    rax,[rbx+0x18]
    133e:	mov    QWORD PTR [rdi],rax
    1341:	mov    r12,rdi
    1344:	mov    QWORD PTR [rbx+0x10],0x0
    134c:	mov    QWORD PTR [rbx],rsi
    134f:	mov    r13,rsi
    1352:	mov    QWORD PTR [rbx+0x8],rdx
    1356:	mov    r14,rdx
    1359:	lea    rcx,[rsp]
    135d:	mov    rdx,r14
    1360:	mov    rsi,r13
    1363:	mov    rdi,r12
    1366:	call   136b <botlish_fn_12+0x61>
			1367: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    136b:	test   rax,rax
    136e:	mov    rsi,rax
    1371:	jne    137f <botlish_fn_12+0x75>
    1377:	mov    rdi,r12
    137a:	jmp    144a <botlish_fn_12+0x140>
    137f:	mov    rdx,QWORD PTR [rsp]
    1383:	mov    rcx,QWORD PTR [rsp+0x8]
    1388:	mov    rdi,r12
    138b:	mov    rax,QWORD PTR [rdi+0x10]
    138f:	mov    r8,QWORD PTR [rax+0x18]
    1393:	call   1398 <botlish_fn_12+0x8e>
			1394: R_X86_64_PLT32	rt_str_region_eq-0x4
    1398:	cmp    rax,0x6
    139c:	je     13e7 <botlish_fn_12+0xdd>
    13a2:	mov    rcx,r14
    13a5:	mov    rsi,r13
    13a8:	mov    rdi,r12
    13ab:	mov    rdx,rcx
    13ae:	call   13b3 <botlish_fn_12+0xa9>
			13af: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
    13b3:	test   rax,rax
    13b6:	jne    13c4 <botlish_fn_12+0xba>
    13bc:	mov    rdi,r12
    13bf:	jmp    144a <botlish_fn_12+0x140>
    13c4:	mov    rdi,r12
    13c7:	mov    QWORD PTR [rdi],rbx
    13ca:	mov    rbx,QWORD PTR [rsp+0x10]
    13cf:	mov    r12,QWORD PTR [rsp+0x18]
    13d4:	mov    r13,QWORD PTR [rsp+0x20]
    13d9:	mov    r14,QWORD PTR [rsp+0x28]
    13de:	add    rsp,0x30
    13e2:	mov    rsp,rbp
    13e5:	pop    rbp
    13e6:	ret
    13e7:	mov    QWORD PTR [rbx+0x10],0x3
    13ef:	mov    rdx,r14
    13f2:	test   rdx,0x1
    13f9:	je     1411 <botlish_fn_12+0x107>
    13ff:	mov    rdx,r14
    1402:	add    rdx,0x2
    1406:	seto   al
    1409:	test   al,al
    140b:	je     1424 <botlish_fn_12+0x11a>
    1411:	mov    edx,0x3
    1416:	mov    rsi,r14
    1419:	mov    rdi,r12
    141c:	call   1421 <botlish_fn_12+0x117>
			141d: R_X86_64_PLT32	rt_int_add-0x4
    1421:	mov    rdx,rax
    1424:	mov    QWORD PTR [rbx+0x8],rdx
    1428:	mov    rdi,r12
    142b:	mov    rax,QWORD PTR [rdi+0x10]
    142f:	mov    rcx,QWORD PTR [rax]
    1432:	mov    QWORD PTR [rbx+0x10],rcx
    1436:	mov    rsi,r13
    1439:	call   143e <botlish_fn_12+0x134>
			143a: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
    143e:	test   rax,rax
    1441:	jne    1473 <botlish_fn_12+0x169>
    1447:	mov    rdi,r12
    144a:	mov    rdi,r12
    144d:	mov    QWORD PTR [rdi],rbx
    1450:	xor    rdx,rdx
    1453:	mov    rax,rdx
    1456:	mov    rbx,QWORD PTR [rsp+0x10]
    145b:	mov    r12,QWORD PTR [rsp+0x18]
    1460:	mov    r13,QWORD PTR [rsp+0x20]
    1465:	mov    r14,QWORD PTR [rsp+0x28]
    146a:	add    rsp,0x30
    146e:	mov    rsp,rbp
    1471:	pop    rbp
    1472:	ret
    1473:	mov    rdi,r12
    1476:	mov    QWORD PTR [rdi],rbx
    1479:	mov    rbx,QWORD PTR [rsp+0x10]
    147e:	mov    r12,QWORD PTR [rsp+0x18]
    1483:	mov    r13,QWORD PTR [rsp+0x20]
    1488:	mov    r14,QWORD PTR [rsp+0x28]
    148d:	add    rsp,0x30
    1491:	mov    rsp,rbp
    1494:	pop    rbp
    1495:	ret
    1496:	mov    r12,rdi
    1499:	call   149e <botlish_fn_12+0x194>
			149a: R_X86_64_PLT32	rt_stack_overflow-0x4
    149e:	xor    rdx,rdx
    14a1:	mov    rax,rdx
    14a4:	mov    rbx,QWORD PTR [rsp+0x10]
    14a9:	mov    r12,QWORD PTR [rsp+0x18]
    14ae:	mov    r13,QWORD PTR [rsp+0x20]
    14b3:	mov    r14,QWORD PTR [rsp+0x28]
    14b8:	add    rsp,0x30
    14bc:	mov    rsp,rbp
    14bf:	pop    rbp
    14c0:	ret

00000000000014c1 <botlish_entry_12: scan_field<str, int>>:
    14c1:	push   rbp
    14c2:	mov    rbp,rsp
    14c5:	ud2

00000000000014c7 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
    14c7:	push   rbp
    14c8:	mov    rbp,rsp
    14cb:	sub    rsp,0x70
    14cf:	mov    QWORD PTR [rsp+0x40],rbx
    14d4:	mov    QWORD PTR [rsp+0x48],r12
    14d9:	mov    QWORD PTR [rsp+0x50],r13
    14de:	mov    QWORD PTR [rsp+0x58],r14
    14e3:	mov    QWORD PTR [rsp+0x60],r15
    14e8:	mov    r13,QWORD PTR [rdi]
    14eb:	mov    rax,QWORD PTR [rdi+0x8]
    14ef:	lea    r9,[r13+0x28]
    14f3:	cmp    r9,rax
    14f6:	ja     17b7 <botlish_fn_13+0x2f0>
    14fc:	lea    rax,[r13+0x28]
    1500:	mov    QWORD PTR [rdi],rax
    1503:	mov    QWORD PTR [rsp+0x10],rdi
    1508:	mov    QWORD PTR [r13+0x20],0x0
    1510:	mov    QWORD PTR [r13+0x0],rsi
    1514:	mov    QWORD PTR [r13+0x8],rdx
    1518:	mov    QWORD PTR [r13+0x10],rcx
    151c:	mov    QWORD PTR [r13+0x18],r8
    1520:	lea    rbx,[rsp]
    1524:	mov    r12,rsi
    1527:	mov    r14,r8
    152a:	mov    r15,rcx
    152d:	mov    rsi,r12
    1530:	mov    rdi,QWORD PTR [rsp+0x10]
    1535:	call   153a <botlish_fn_13+0x73>
			1536: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
    153a:	test   rax,rax
    153d:	jne    154d <botlish_fn_13+0x86>
    1543:	mov    rdi,QWORD PTR [rsp+0x10]
    1548:	jmp    168e <botlish_fn_13+0x1c7>
    154d:	mov    QWORD PTR [r13+0x8],rax
    1551:	mov    rcx,rax
    1554:	mov    QWORD PTR [r13+0x20],rdx
    1558:	mov    QWORD PTR [rsp+0x30],rdx
    155d:	mov    rsi,r15
    1560:	mov    rdx,r14
    1563:	mov    rdi,QWORD PTR [rsp+0x10]
    1568:	call   156d <botlish_fn_13+0xa6>
			1569: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    156d:	test   rax,rax
    1570:	jne    1580 <botlish_fn_13+0xb9>
    1576:	mov    rdi,QWORD PTR [rsp+0x10]
    157b:	jmp    168e <botlish_fn_13+0x1c7>
    1580:	mov    QWORD PTR [r13+0x8],rax
    1584:	mov    QWORD PTR [rsp+0x20],rax
    1589:	mov    QWORD PTR [r13+0x10],rdx
    158d:	mov    QWORD PTR [rsp+0x28],rdx
    1592:	mov    rcx,rbx
    1595:	mov    rdx,QWORD PTR [rsp+0x30]
    159a:	mov    rsi,r12
    159d:	mov    rdi,QWORD PTR [rsp+0x10]
    15a2:	call   15a7 <botlish_fn_13+0xe0>
			15a3: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    15a7:	test   rax,rax
    15aa:	mov    QWORD PTR [rsp+0x18],rax
    15af:	jne    15bf <botlish_fn_13+0xf8>
    15b5:	mov    rdi,QWORD PTR [rsp+0x10]
    15ba:	jmp    168e <botlish_fn_13+0x1c7>
    15bf:	mov    r15,QWORD PTR [rsp]
    15c3:	mov    r14,QWORD PTR [rsp+0x8]
    15c8:	mov    rdi,QWORD PTR [rsp+0x10]
    15cd:	mov    rcx,QWORD PTR [rdi+0x10]
    15d1:	mov    r8,QWORD PTR [rcx+0x8]
    15d5:	mov    rcx,r14
    15d8:	mov    rdx,r15
    15db:	mov    rsi,QWORD PTR [rsp+0x18]
    15e0:	call   15e5 <botlish_fn_13+0x11e>
			15e1: R_X86_64_PLT32	rt_str_region_eq-0x4
    15e5:	cmp    rax,0x6
    15e9:	je     1746 <botlish_fn_13+0x27f>
    15ef:	mov    rdi,QWORD PTR [rsp+0x10]
    15f4:	mov    rsi,QWORD PTR [rdi+0x10]
    15f8:	mov    r8,QWORD PTR [rsi+0x10]
    15fc:	mov    rcx,r14
    15ff:	mov    rdx,r15
    1602:	mov    rsi,QWORD PTR [rsp+0x18]
    1607:	call   160c <botlish_fn_13+0x145>
			1608: R_X86_64_PLT32	rt_str_region_eq-0x4
    160c:	cmp    rax,0x6
    1610:	je     166c <botlish_fn_13+0x1a5>
    1616:	mov    rdx,QWORD PTR [rsp+0x28]
    161b:	mov    rsi,QWORD PTR [rsp+0x20]
    1620:	mov    rdi,QWORD PTR [rsp+0x10]
    1625:	call   162a <botlish_fn_13+0x163>
			1626: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    162a:	test   rax,rax
    162d:	jne    163d <botlish_fn_13+0x176>
    1633:	mov    rdi,QWORD PTR [rsp+0x10]
    1638:	jmp    168e <botlish_fn_13+0x1c7>
    163d:	mov    rdi,QWORD PTR [rsp+0x10]
    1642:	mov    QWORD PTR [rdi],r13
    1645:	mov    rdx,QWORD PTR [rsp+0x30]
    164a:	mov    rbx,QWORD PTR [rsp+0x40]
    164f:	mov    r12,QWORD PTR [rsp+0x48]
    1654:	mov    r13,QWORD PTR [rsp+0x50]
    1659:	mov    r14,QWORD PTR [rsp+0x58]
    165e:	mov    r15,QWORD PTR [rsp+0x60]
    1663:	add    rsp,0x70
    1667:	mov    rsp,rbp
    166a:	pop    rbp
    166b:	ret
    166c:	mov    rdx,QWORD PTR [rsp+0x28]
    1671:	mov    rsi,QWORD PTR [rsp+0x20]
    1676:	mov    rdi,QWORD PTR [rsp+0x10]
    167b:	call   1680 <botlish_fn_13+0x1b9>
			167c: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1680:	test   rax,rax
    1683:	jne    16be <botlish_fn_13+0x1f7>
    1689:	mov    rdi,QWORD PTR [rsp+0x10]
    168e:	mov    rdi,QWORD PTR [rsp+0x10]
    1693:	mov    QWORD PTR [rdi],r13
    1696:	xor    rdx,rdx
    1699:	mov    rax,rdx
    169c:	mov    rbx,QWORD PTR [rsp+0x40]
    16a1:	mov    r12,QWORD PTR [rsp+0x48]
    16a6:	mov    r13,QWORD PTR [rsp+0x50]
    16ab:	mov    r14,QWORD PTR [rsp+0x58]
    16b0:	mov    r15,QWORD PTR [rsp+0x60]
    16b5:	add    rsp,0x70
    16b9:	mov    rsp,rbp
    16bc:	pop    rbp
    16bd:	ret
    16be:	mov    QWORD PTR [r13+0x0],rax
    16c2:	mov    rbx,rax
    16c5:	mov    QWORD PTR [r13+0x8],0x3
    16cd:	mov    rdx,QWORD PTR [rsp+0x30]
    16d2:	test   rdx,0x1
    16d9:	je     16fd <botlish_fn_13+0x236>
    16df:	mov    rdx,QWORD PTR [rsp+0x30]
    16e4:	add    rdx,0x2
    16e8:	seto   al
    16eb:	test   al,al
    16ed:	jne    16fd <botlish_fn_13+0x236>
    16f3:	mov    rdi,QWORD PTR [rsp+0x10]
    16f8:	jmp    1719 <botlish_fn_13+0x252>
    16fd:	mov    edx,0x3
    1702:	mov    rsi,QWORD PTR [rsp+0x30]
    1707:	mov    rdi,QWORD PTR [rsp+0x10]
    170c:	call   1711 <botlish_fn_13+0x24a>
			170d: R_X86_64_PLT32	rt_int_add-0x4
    1711:	mov    rdx,rax
    1714:	mov    rdi,QWORD PTR [rsp+0x10]
    1719:	mov    rdi,QWORD PTR [rsp+0x10]
    171e:	mov    QWORD PTR [rdi],r13
    1721:	mov    rax,rbx
    1724:	mov    rbx,QWORD PTR [rsp+0x40]
    1729:	mov    r12,QWORD PTR [rsp+0x48]
    172e:	mov    r13,QWORD PTR [rsp+0x50]
    1733:	mov    r14,QWORD PTR [rsp+0x58]
    1738:	mov    r15,QWORD PTR [rsp+0x60]
    173d:	add    rsp,0x70
    1741:	mov    rsp,rbp
    1744:	pop    rbp
    1745:	ret
    1746:	mov    rsi,QWORD PTR [rsp+0x30]
    174b:	mov    edx,0x3
    1750:	mov    r9,rdx
    1753:	mov    QWORD PTR [r13+0x18],0x3
    175b:	test   rsi,0x1
    1762:	jne    1770 <botlish_fn_13+0x2a9>
    1768:	mov    rdx,r9
    176b:	jmp    1785 <botlish_fn_13+0x2be>
    1770:	mov    rdx,rsi
    1773:	add    rdx,0x2
    1777:	seto   al
    177a:	test   al,al
    177c:	je     1792 <botlish_fn_13+0x2cb>
    1782:	mov    rdx,r9
    1785:	mov    rdi,QWORD PTR [rsp+0x10]
    178a:	call   178f <botlish_fn_13+0x2c8>
			178b: R_X86_64_PLT32	rt_int_add-0x4
    178f:	mov    rdx,rax
    1792:	mov    QWORD PTR [r13+0x0],r12
    1796:	mov    QWORD PTR [r13+0x8],rdx
    179a:	mov    rsi,QWORD PTR [rsp+0x20]
    179f:	mov    QWORD PTR [r13+0x10],rsi
    17a3:	mov    rax,QWORD PTR [rsp+0x28]
    17a8:	mov    QWORD PTR [r13+0x18],rax
    17ac:	mov    r14,rax
    17af:	mov    r15,rsi
    17b2:	jmp    152d <botlish_fn_13+0x66>
    17b7:	mov    QWORD PTR [rsp+0x10],rdi
    17bc:	call   17c1 <botlish_fn_13+0x2fa>
			17bd: R_X86_64_PLT32	rt_stack_overflow-0x4
    17c1:	xor    rdx,rdx
    17c4:	mov    rax,rdx
    17c7:	mov    rbx,QWORD PTR [rsp+0x40]
    17cc:	mov    r12,QWORD PTR [rsp+0x48]
    17d1:	mov    r13,QWORD PTR [rsp+0x50]
    17d6:	mov    r14,QWORD PTR [rsp+0x58]
    17db:	mov    r15,QWORD PTR [rsp+0x60]
    17e0:	add    rsp,0x70
    17e4:	mov    rsp,rbp
    17e7:	pop    rbp
    17e8:	ret

00000000000017e9 <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    17e9:	push   rbp
    17ea:	mov    rbp,rsp
    17ed:	ud2
	...

00000000000017f0 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    17f0:	push   rbp
    17f1:	mov    rbp,rsp
    17f4:	sub    rsp,0x40
    17f8:	mov    QWORD PTR [rsp+0x10],rbx
    17fd:	mov    QWORD PTR [rsp+0x18],r12
    1802:	mov    QWORD PTR [rsp+0x20],r13
    1807:	mov    QWORD PTR [rsp+0x28],r14
    180c:	mov    QWORD PTR [rsp+0x30],r15
    1811:	mov    r12,QWORD PTR [rdi]
    1814:	mov    rax,QWORD PTR [rdi+0x8]
    1818:	lea    r9,[r12+0x30]
    181d:	cmp    r9,rax
    1820:	ja     19c9 <botlish_fn_14+0x1d9>
    1826:	lea    rax,[r12+0x30]
    182b:	mov    QWORD PTR [rdi],rax
    182e:	mov    r14,rdi
    1831:	mov    QWORD PTR [r12+0x20],0x0
    183a:	mov    QWORD PTR [r12+0x28],0x0
    1843:	mov    QWORD PTR [r12],rsi
    1847:	mov    QWORD PTR [r12+0x8],rdx
    184c:	mov    r13,rdx
    184f:	mov    QWORD PTR [r12+0x10],rcx
    1854:	mov    QWORD PTR [r12+0x18],r8
    1859:	mov    rbx,rsi
    185c:	mov    r15,r8
    185f:	mov    QWORD PTR [rsp],rcx
    1863:	mov    rsi,rbx
    1866:	mov    rdi,r14
    1869:	call   186e <botlish_fn_14+0x7e>
			186a: R_X86_64_PLT32	rt_str_len-0x4
    186e:	mov    rcx,r13
    1871:	and    rcx,rax
    1874:	mov    rdx,rax
    1877:	test   rcx,0x1
    187e:	jne    18a4 <botlish_fn_14+0xb4>
    1884:	mov    rsi,r13
    1887:	mov    rdi,r14
    188a:	call   188f <botlish_fn_14+0x9f>
			188b: R_X86_64_PLT32	rt_int_cmp-0x4
    188f:	mov    ecx,0x2
    1894:	test   rax,rax
    1897:	cmovge rcx,QWORD PTR [rip+0x159]        # 19f8 <botlish_fn_14+0x208>
    189f:	jmp    18b7 <botlish_fn_14+0xc7>
    18a4:	mov    ecx,0x2
    18a9:	mov    rax,r13
    18ac:	cmp    rax,rdx
    18af:	cmovge rcx,QWORD PTR [rip+0x141]        # 19f8 <botlish_fn_14+0x208>
    18b7:	cmp    rcx,0x6
    18bb:	je     195b <botlish_fn_14+0x16b>
    18c1:	mov    rdi,r14
    18c4:	call   18c9 <botlish_fn_14+0xd9>
			18c5: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    18c9:	test   rax,rax
    18cc:	jne    18da <botlish_fn_14+0xea>
    18d2:	mov    rdi,r14
    18d5:	jmp    1976 <botlish_fn_14+0x186>
    18da:	mov    QWORD PTR [r12+0x20],rax
    18df:	mov    rcx,rax
    18e2:	mov    QWORD PTR [r12+0x28],rdx
    18e7:	mov    r8,rdx
    18ea:	mov    rdx,r13
    18ed:	mov    rsi,rbx
    18f0:	mov    rdi,r14
    18f3:	call   18f8 <botlish_fn_14+0x108>
			18f4: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    18f8:	test   rax,rax
    18fb:	jne    1909 <botlish_fn_14+0x119>
    1901:	mov    rdi,r14
    1904:	jmp    1976 <botlish_fn_14+0x186>
    1909:	mov    QWORD PTR [r12+0x8],rax
    190e:	mov    rcx,rax
    1911:	mov    QWORD PTR [r12+0x20],rdx
    1916:	mov    r13,rdx
    1919:	mov    rsi,QWORD PTR [rsp]
    191d:	mov    rdx,r15
    1920:	mov    rdi,r14
    1923:	call   1928 <botlish_fn_14+0x138>
			1924: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1928:	test   rax,rax
    192b:	jne    1939 <botlish_fn_14+0x149>
    1931:	mov    rdi,r14
    1934:	jmp    1976 <botlish_fn_14+0x186>
    1939:	mov    QWORD PTR [r12],rbx
    193d:	mov    rcx,r13
    1940:	mov    QWORD PTR [r12+0x8],rcx
    1945:	mov    QWORD PTR [r12+0x10],rax
    194a:	mov    QWORD PTR [r12+0x18],rdx
    194f:	mov    r15,rdx
    1952:	mov    QWORD PTR [rsp],rax
    1956:	jmp    1863 <botlish_fn_14+0x73>
    195b:	mov    rdx,r15
    195e:	mov    rsi,QWORD PTR [rsp]
    1962:	mov    rdi,r14
    1965:	call   196a <botlish_fn_14+0x17a>
			1966: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    196a:	test   rax,rax
    196d:	jne    19a1 <botlish_fn_14+0x1b1>
    1973:	mov    rdi,r14
    1976:	mov    rdi,r14
    1979:	mov    QWORD PTR [rdi],r12
    197c:	xor    rax,rax
    197f:	mov    rbx,QWORD PTR [rsp+0x10]
    1984:	mov    r12,QWORD PTR [rsp+0x18]
    1989:	mov    r13,QWORD PTR [rsp+0x20]
    198e:	mov    r14,QWORD PTR [rsp+0x28]
    1993:	mov    r15,QWORD PTR [rsp+0x30]
    1998:	add    rsp,0x40
    199c:	mov    rsp,rbp
    199f:	pop    rbp
    19a0:	ret
    19a1:	mov    rdi,r14
    19a4:	mov    QWORD PTR [rdi],r12
    19a7:	mov    rbx,QWORD PTR [rsp+0x10]
    19ac:	mov    r12,QWORD PTR [rsp+0x18]
    19b1:	mov    r13,QWORD PTR [rsp+0x20]
    19b6:	mov    r14,QWORD PTR [rsp+0x28]
    19bb:	mov    r15,QWORD PTR [rsp+0x30]
    19c0:	add    rsp,0x40
    19c4:	mov    rsp,rbp
    19c7:	pop    rbp
    19c8:	ret
    19c9:	mov    r14,rdi
    19cc:	call   19d1 <botlish_fn_14+0x1e1>
			19cd: R_X86_64_PLT32	rt_stack_overflow-0x4
    19d1:	xor    rax,rax
    19d4:	mov    rbx,QWORD PTR [rsp+0x10]
    19d9:	mov    r12,QWORD PTR [rsp+0x18]
    19de:	mov    r13,QWORD PTR [rsp+0x20]
    19e3:	mov    r14,QWORD PTR [rsp+0x28]
    19e8:	mov    r15,QWORD PTR [rsp+0x30]
    19ed:	add    rsp,0x40
    19f1:	mov    rsp,rbp
    19f4:	pop    rbp
    19f5:	ret
    19f6:	add    BYTE PTR [rax],al
    19f8:	(bad)
    19f9:	add    BYTE PTR [rax],al
    19fb:	add    BYTE PTR [rax],al
    19fd:	add    BYTE PTR [rax],al
	...

0000000000001a00 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    1a00:	push   rbp
    1a01:	mov    rbp,rsp
    1a04:	mov    rsi,QWORD PTR [rdx]
    1a07:	mov    r9,QWORD PTR [rdx+0x8]
    1a0b:	mov    rcx,QWORD PTR [rdx+0x10]
    1a0f:	mov    r8,QWORD PTR [rdx+0x18]
    1a13:	mov    rdx,r9
    1a16:	call   1a1b <botlish_entry_14+0x1b>
			1a17: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1a1b:	mov    rsp,rbp
    1a1e:	pop    rbp
    1a1f:	ret

0000000000001a20 <botlish_fn_15: csv_parse<str>>:
    1a20:	push   rbp
    1a21:	mov    rbp,rsp
    1a24:	sub    rsp,0x20
    1a28:	mov    QWORD PTR [rsp],rbx
    1a2c:	mov    QWORD PTR [rsp+0x8],r12
    1a31:	mov    QWORD PTR [rsp+0x10],r15
    1a36:	mov    r15,QWORD PTR [rdi]
    1a39:	mov    rax,QWORD PTR [rdi+0x8]
    1a3d:	lea    rcx,[r15+0x20]
    1a41:	cmp    rcx,rax
    1a44:	ja     1af2 <botlish_fn_15+0xd2>
    1a4a:	lea    rax,[r15+0x20]
    1a4e:	mov    QWORD PTR [rdi],rax
    1a51:	mov    rbx,rdi
    1a54:	mov    QWORD PTR [r15+0x10],0x0
    1a5c:	mov    QWORD PTR [r15+0x18],0x0
    1a64:	mov    QWORD PTR [r15],rsi
    1a67:	mov    r12,rsi
    1a6a:	mov    QWORD PTR [r15+0x8],0x1
    1a72:	mov    rdi,rbx
    1a75:	call   1a7a <botlish_fn_15+0x5a>
			1a76: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1a7a:	test   rax,rax
    1a7d:	jne    1a8b <botlish_fn_15+0x6b>
    1a83:	mov    rdi,rbx
    1a86:	jmp    1ab5 <botlish_fn_15+0x95>
    1a8b:	mov    QWORD PTR [r15+0x10],rax
    1a8f:	mov    rcx,rax
    1a92:	mov    QWORD PTR [r15+0x18],rdx
    1a96:	mov    r8,rdx
    1a99:	mov    edx,0x1
    1a9e:	mov    rsi,r12
    1aa1:	mov    rdi,rbx
    1aa4:	call   1aa9 <botlish_fn_15+0x89>
			1aa5: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1aa9:	test   rax,rax
    1aac:	jne    1ad5 <botlish_fn_15+0xb5>
    1ab2:	mov    rdi,rbx
    1ab5:	mov    rdi,rbx
    1ab8:	mov    QWORD PTR [rdi],r15
    1abb:	xor    rax,rax
    1abe:	mov    rbx,QWORD PTR [rsp]
    1ac2:	mov    r12,QWORD PTR [rsp+0x8]
    1ac7:	mov    r15,QWORD PTR [rsp+0x10]
    1acc:	add    rsp,0x20
    1ad0:	mov    rsp,rbp
    1ad3:	pop    rbp
    1ad4:	ret
    1ad5:	mov    rdi,rbx
    1ad8:	mov    QWORD PTR [rdi],r15
    1adb:	mov    rbx,QWORD PTR [rsp]
    1adf:	mov    r12,QWORD PTR [rsp+0x8]
    1ae4:	mov    r15,QWORD PTR [rsp+0x10]
    1ae9:	add    rsp,0x20
    1aed:	mov    rsp,rbp
    1af0:	pop    rbp
    1af1:	ret
    1af2:	mov    rbx,rdi
    1af5:	call   1afa <botlish_fn_15+0xda>
			1af6: R_X86_64_PLT32	rt_stack_overflow-0x4
    1afa:	xor    rax,rax
    1afd:	mov    rbx,QWORD PTR [rsp]
    1b01:	mov    r12,QWORD PTR [rsp+0x8]
    1b06:	mov    r15,QWORD PTR [rsp+0x10]
    1b0b:	add    rsp,0x20
    1b0f:	mov    rsp,rbp
    1b12:	pop    rbp
    1b13:	ret

0000000000001b14 <botlish_entry_15: csv_parse<str>>:
    1b14:	push   rbp
    1b15:	mov    rbp,rsp
    1b18:	mov    rsi,QWORD PTR [rdx]
    1b1b:	call   1b20 <botlish_entry_15+0xc>
			1b1c: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    1b20:	mov    rsp,rbp
    1b23:	pop    rbp
    1b24:	ret

0000000000001b25 <botlish_fn_16: ht_min_capacity<generic>>:
    1b25:	push   rbp
    1b26:	mov    rbp,rsp
    1b29:	mov    eax,0x11
    1b2e:	mov    rsp,rbp
    1b31:	pop    rbp
    1b32:	ret

0000000000001b33 <botlish_entry_16: ht_min_capacity<generic>>:
    1b33:	push   rbp
    1b34:	mov    rbp,rsp
    1b37:	call   1b3c <botlish_entry_16+0x9>
			1b38: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1b3c:	mov    rsp,rbp
    1b3f:	pop    rbp
    1b40:	ret

0000000000001b41 <botlish_fn_17: ht_empty_state<generic>>:
    1b41:	push   rbp
    1b42:	mov    rbp,rsp
    1b45:	mov    eax,0x1
    1b4a:	mov    rsp,rbp
    1b4d:	pop    rbp
    1b4e:	ret

0000000000001b4f <botlish_entry_17: ht_empty_state<generic>>:
    1b4f:	push   rbp
    1b50:	mov    rbp,rsp
    1b53:	call   1b58 <botlish_entry_17+0x9>
			1b54: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1b58:	mov    rsp,rbp
    1b5b:	pop    rbp
    1b5c:	ret

0000000000001b5d <botlish_fn_18: ht_occupied_state<generic>>:
    1b5d:	push   rbp
    1b5e:	mov    rbp,rsp
    1b61:	mov    eax,0x3
    1b66:	mov    rsp,rbp
    1b69:	pop    rbp
    1b6a:	ret

0000000000001b6b <botlish_entry_18: ht_occupied_state<generic>>:
    1b6b:	push   rbp
    1b6c:	mov    rbp,rsp
    1b6f:	call   1b74 <botlish_entry_18+0x9>
			1b70: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    1b74:	mov    rsp,rbp
    1b77:	pop    rbp
    1b78:	ret

0000000000001b79 <botlish_fn_19: ht_tombstone_state<generic>>:
    1b79:	push   rbp
    1b7a:	mov    rbp,rsp
    1b7d:	mov    eax,0x5
    1b82:	mov    rsp,rbp
    1b85:	pop    rbp
    1b86:	ret

0000000000001b87 <botlish_entry_19: ht_tombstone_state<generic>>:
    1b87:	push   rbp
    1b88:	mov    rbp,rsp
    1b8b:	call   1b90 <botlish_entry_19+0x9>
			1b8c: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    1b90:	mov    rsp,rbp
    1b93:	pop    rbp
    1b94:	ret
    1b95:	add    BYTE PTR [rax],al
	...

0000000000001b98 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    1b98:	push   rbp
    1b99:	mov    rbp,rsp
    1b9c:	sub    rsp,0x30
    1ba0:	mov    QWORD PTR [rsp],rbx
    1ba4:	mov    QWORD PTR [rsp+0x8],r12
    1ba9:	mov    QWORD PTR [rsp+0x10],r13
    1bae:	mov    QWORD PTR [rsp+0x18],r14
    1bb3:	mov    QWORD PTR [rsp+0x20],r15
    1bb8:	mov    r13,QWORD PTR [rdi]
    1bbb:	mov    r8,QWORD PTR [rdi+0x8]
    1bbf:	lea    rax,[r13+0x20]
    1bc3:	cmp    rax,r8
    1bc6:	ja     1d30 <botlish_fn_20+0x198>
    1bcc:	lea    rax,[r13+0x20]
    1bd0:	mov    QWORD PTR [rdi],rax
    1bd3:	mov    r14,rdi
    1bd6:	mov    QWORD PTR [r13+0x18],0x0
    1bde:	mov    QWORD PTR [r13+0x0],rsi
    1be2:	mov    r12,rsi
    1be5:	mov    QWORD PTR [r13+0x8],rdx
    1be9:	mov    QWORD PTR [r13+0x10],rcx
    1bed:	mov    rbx,rcx
    1bf0:	mov    rsi,rdx
    1bf3:	mov    rax,rsi
    1bf6:	and    rax,rbx
    1bf9:	mov    r15,rsi
    1bfc:	test   rax,0x1
    1c02:	jne    1c2b <botlish_fn_20+0x93>
    1c08:	mov    rdx,rbx
    1c0b:	mov    rsi,r15
    1c0e:	mov    rdi,r14
    1c11:	call   1c16 <botlish_fn_20+0x7e>
			1c12: R_X86_64_PLT32	rt_int_cmp-0x4
    1c16:	mov    ecx,0x2
    1c1b:	test   rax,rax
    1c1e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 1d60 <botlish_fn_20+0x1c8>
    1c26:	jmp    1c3e <botlish_fn_20+0xa6>
    1c2b:	mov    ecx,0x2
    1c30:	mov    rsi,r15
    1c33:	cmp    rsi,rbx
    1c36:	cmovge rcx,QWORD PTR [rip+0x122]        # 1d60 <botlish_fn_20+0x1c8>
    1c3e:	cmp    rcx,0x6
    1c42:	je     1d04 <botlish_fn_20+0x16c>
    1c48:	mov    rdi,r14
    1c4b:	call   1c50 <botlish_fn_20+0xb8>
			1c4c: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1c50:	test   rax,rax
    1c53:	mov    rcx,rax
    1c56:	jne    1c64 <botlish_fn_20+0xcc>
    1c5c:	mov    rdi,r14
    1c5f:	jmp    1c7e <botlish_fn_20+0xe6>
    1c64:	mov    rdx,r15
    1c67:	mov    rsi,r12
    1c6a:	mov    rdi,r14
    1c6d:	call   1c72 <botlish_fn_20+0xda>
			1c6e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c72:	test   rax,rax
    1c75:	jne    1ca8 <botlish_fn_20+0x110>
    1c7b:	mov    rdi,r14
    1c7e:	mov    rdi,r14
    1c81:	mov    QWORD PTR [rdi],r13
    1c84:	xor    rax,rax
    1c87:	mov    rbx,QWORD PTR [rsp]
    1c8b:	mov    r12,QWORD PTR [rsp+0x8]
    1c90:	mov    r13,QWORD PTR [rsp+0x10]
    1c95:	mov    r14,QWORD PTR [rsp+0x18]
    1c9a:	mov    r15,QWORD PTR [rsp+0x20]
    1c9f:	add    rsp,0x30
    1ca3:	mov    rsp,rbp
    1ca6:	pop    rbp
    1ca7:	ret
    1ca8:	mov    QWORD PTR [r13+0x18],0x3
    1cb0:	mov    rsi,r15
    1cb3:	test   rsi,0x1
    1cba:	je     1cdd <botlish_fn_20+0x145>
    1cc0:	mov    rsi,r15
    1cc3:	mov    rcx,rsi
    1cc6:	add    rcx,0x2
    1cca:	seto   al
    1ccd:	test   al,al
    1ccf:	jne    1cdd <botlish_fn_20+0x145>
    1cd5:	mov    r15,rcx
    1cd8:	jmp    1cf0 <botlish_fn_20+0x158>
    1cdd:	mov    edx,0x3
    1ce2:	mov    rsi,r15
    1ce5:	mov    rdi,r14
    1ce8:	call   1ced <botlish_fn_20+0x155>
			1ce9: R_X86_64_PLT32	rt_int_add-0x4
    1ced:	mov    r15,rax
    1cf0:	mov    QWORD PTR [r13+0x0],r12
    1cf4:	mov    rsi,r15
    1cf7:	mov    QWORD PTR [r13+0x8],rsi
    1cfb:	mov    QWORD PTR [r13+0x10],rbx
    1cff:	jmp    1bf3 <botlish_fn_20+0x5b>
    1d04:	mov    rdi,r14
    1d07:	mov    QWORD PTR [rdi],r13
    1d0a:	mov    eax,0xa
    1d0f:	mov    rbx,QWORD PTR [rsp]
    1d13:	mov    r12,QWORD PTR [rsp+0x8]
    1d18:	mov    r13,QWORD PTR [rsp+0x10]
    1d1d:	mov    r14,QWORD PTR [rsp+0x18]
    1d22:	mov    r15,QWORD PTR [rsp+0x20]
    1d27:	add    rsp,0x30
    1d2b:	mov    rsp,rbp
    1d2e:	pop    rbp
    1d2f:	ret
    1d30:	mov    r14,rdi
    1d33:	call   1d38 <botlish_fn_20+0x1a0>
			1d34: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d38:	xor    rax,rax
    1d3b:	mov    rbx,QWORD PTR [rsp]
    1d3f:	mov    r12,QWORD PTR [rsp+0x8]
    1d44:	mov    r13,QWORD PTR [rsp+0x10]
    1d49:	mov    r14,QWORD PTR [rsp+0x18]
    1d4e:	mov    r15,QWORD PTR [rsp+0x20]
    1d53:	add    rsp,0x30
    1d57:	mov    rsp,rbp
    1d5a:	pop    rbp
    1d5b:	ret
    1d5c:	add    BYTE PTR [rax],al
    1d5e:	add    BYTE PTR [rax],al
    1d60:	(bad)
    1d61:	add    BYTE PTR [rax],al
    1d63:	add    BYTE PTR [rax],al
    1d65:	add    BYTE PTR [rax],al
	...

0000000000001d68 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    1d68:	push   rbp
    1d69:	mov    rbp,rsp
    1d6c:	mov    rsi,QWORD PTR [rdx]
    1d6f:	mov    r8,QWORD PTR [rdx+0x8]
    1d73:	mov    rcx,QWORD PTR [rdx+0x10]
    1d77:	mov    rdx,r8
    1d7a:	call   1d7f <botlish_entry_20+0x17>
			1d7b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1d7f:	mov    rsp,rbp
    1d82:	pop    rbp
    1d83:	ret

0000000000001d84 <botlish_fn_21: ht_alloc<int>>:
    1d84:	push   rbp
    1d85:	mov    rbp,rsp
    1d88:	sub    rsp,0x40
    1d8c:	mov    QWORD PTR [rsp+0x10],rbx
    1d91:	mov    QWORD PTR [rsp+0x18],r12
    1d96:	mov    QWORD PTR [rsp+0x20],r13
    1d9b:	mov    QWORD PTR [rsp+0x28],r14
    1da0:	mov    QWORD PTR [rsp+0x30],r15
    1da5:	mov    rbx,QWORD PTR [rdi]
    1da8:	mov    rax,QWORD PTR [rdi+0x8]
    1dac:	lea    rcx,[rbx+0x20]
    1db0:	cmp    rcx,rax
    1db3:	ja     1fae <botlish_fn_21+0x22a>
    1db9:	lea    rax,[rbx+0x20]
    1dbd:	mov    QWORD PTR [rdi],rax
    1dc0:	mov    r12,rdi
    1dc3:	mov    QWORD PTR [rbx+0x8],0x0
    1dcb:	mov    QWORD PTR [rbx+0x10],0x0
    1dd3:	mov    QWORD PTR [rbx+0x18],0x0
    1ddb:	mov    QWORD PTR [rbx],rsi
    1dde:	mov    r13,rsi
    1de1:	mov    rsi,r13
    1de4:	mov    rdi,r12
    1de7:	call   1dec <botlish_fn_21+0x68>
			1de8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1dec:	test   rax,rax
    1def:	jne    1dfd <botlish_fn_21+0x79>
    1df5:	mov    rdi,r12
    1df8:	jmp    1f57 <botlish_fn_21+0x1d3>
    1dfd:	mov    QWORD PTR [rbx+0x8],rax
    1e01:	mov    r14,rax
    1e04:	mov    edx,0x1
    1e09:	mov    QWORD PTR [rbx+0x10],0x1
    1e11:	mov    rcx,r13
    1e14:	mov    rsi,r14
    1e17:	mov    rdi,r12
    1e1a:	call   1e1f <botlish_fn_21+0x9b>
			1e1b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1e1f:	test   rax,rax
    1e22:	jne    1e30 <botlish_fn_21+0xac>
    1e28:	mov    rdi,r12
    1e2b:	jmp    1f57 <botlish_fn_21+0x1d3>
    1e30:	mov    rsi,r13
    1e33:	mov    rdi,r12
    1e36:	call   1e3b <botlish_fn_21+0xb7>
			1e37: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1e3b:	test   rax,rax
    1e3e:	jne    1e4c <botlish_fn_21+0xc8>
    1e44:	mov    rdi,r12
    1e47:	jmp    1f57 <botlish_fn_21+0x1d3>
    1e4c:	mov    QWORD PTR [rbx+0x10],rax
    1e50:	mov    rsi,r13
    1e53:	mov    r15,rax
    1e56:	mov    rdi,r12
    1e59:	call   1e5e <botlish_fn_21+0xda>
			1e5a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1e5e:	test   rax,rax
    1e61:	jne    1e6f <botlish_fn_21+0xeb>
    1e67:	mov    rdi,r12
    1e6a:	jmp    1f57 <botlish_fn_21+0x1d3>
    1e6f:	mov    QWORD PTR [rbx],rax
    1e72:	mov    r13,rax
    1e75:	mov    esi,0xb
    1e7a:	mov    QWORD PTR [rbx+0x18],0xb
    1e82:	mov    rdi,r12
    1e85:	call   1e8a <botlish_fn_21+0x106>
			1e86: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1e8a:	test   rax,rax
    1e8d:	mov    QWORD PTR [rsp],rax
    1e91:	jne    1e9f <botlish_fn_21+0x11b>
    1e97:	mov    rdi,r12
    1e9a:	jmp    1f57 <botlish_fn_21+0x1d3>
    1e9f:	mov    edx,0x1
    1ea4:	mov    rcx,r14
    1ea7:	mov    rsi,QWORD PTR [rsp]
    1eab:	mov    rdi,r12
    1eae:	call   1eb3 <botlish_fn_21+0x12f>
			1eaf: R_X86_64_PLT32	rt_mutarray_set-0x4
    1eb3:	test   rax,rax
    1eb6:	jne    1ec4 <botlish_fn_21+0x140>
    1ebc:	mov    rdi,r12
    1ebf:	jmp    1f57 <botlish_fn_21+0x1d3>
    1ec4:	mov    edx,0x3
    1ec9:	mov    rcx,r15
    1ecc:	mov    rsi,QWORD PTR [rsp]
    1ed0:	mov    rdi,r12
    1ed3:	call   1ed8 <botlish_fn_21+0x154>
			1ed4: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ed8:	test   rax,rax
    1edb:	jne    1ee9 <botlish_fn_21+0x165>
    1ee1:	mov    rdi,r12
    1ee4:	jmp    1f57 <botlish_fn_21+0x1d3>
    1ee9:	mov    edx,0x5
    1eee:	mov    rcx,r13
    1ef1:	mov    rsi,QWORD PTR [rsp]
    1ef5:	mov    rdi,r12
    1ef8:	call   1efd <botlish_fn_21+0x179>
			1ef9: R_X86_64_PLT32	rt_mutarray_set-0x4
    1efd:	test   rax,rax
    1f00:	jne    1f0e <botlish_fn_21+0x18a>
    1f06:	mov    rdi,r12
    1f09:	jmp    1f57 <botlish_fn_21+0x1d3>
    1f0e:	mov    edx,0x7
    1f13:	mov    ecx,0x1
    1f18:	mov    rsi,QWORD PTR [rsp]
    1f1c:	mov    rdi,r12
    1f1f:	call   1f24 <botlish_fn_21+0x1a0>
			1f20: R_X86_64_PLT32	rt_mutarray_set-0x4
    1f24:	test   rax,rax
    1f27:	jne    1f35 <botlish_fn_21+0x1b1>
    1f2d:	mov    rdi,r12
    1f30:	jmp    1f57 <botlish_fn_21+0x1d3>
    1f35:	mov    edx,0x9
    1f3a:	mov    ecx,0x1
    1f3f:	mov    rsi,QWORD PTR [rsp]
    1f43:	mov    rdi,r12
    1f46:	call   1f4b <botlish_fn_21+0x1c7>
			1f47: R_X86_64_PLT32	rt_mutarray_set-0x4
    1f4b:	test   rax,rax
    1f4e:	jne    1f82 <botlish_fn_21+0x1fe>
    1f54:	mov    rdi,r12
    1f57:	mov    rdi,r12
    1f5a:	mov    QWORD PTR [rdi],rbx
    1f5d:	xor    rax,rax
    1f60:	mov    rbx,QWORD PTR [rsp+0x10]
    1f65:	mov    r12,QWORD PTR [rsp+0x18]
    1f6a:	mov    r13,QWORD PTR [rsp+0x20]
    1f6f:	mov    r14,QWORD PTR [rsp+0x28]
    1f74:	mov    r15,QWORD PTR [rsp+0x30]
    1f79:	add    rsp,0x40
    1f7d:	mov    rsp,rbp
    1f80:	pop    rbp
    1f81:	ret
    1f82:	mov    rdi,r12
    1f85:	mov    QWORD PTR [rdi],rbx
    1f88:	mov    rax,QWORD PTR [rsp]
    1f8c:	mov    rbx,QWORD PTR [rsp+0x10]
    1f91:	mov    r12,QWORD PTR [rsp+0x18]
    1f96:	mov    r13,QWORD PTR [rsp+0x20]
    1f9b:	mov    r14,QWORD PTR [rsp+0x28]
    1fa0:	mov    r15,QWORD PTR [rsp+0x30]
    1fa5:	add    rsp,0x40
    1fa9:	mov    rsp,rbp
    1fac:	pop    rbp
    1fad:	ret
    1fae:	mov    r12,rdi
    1fb1:	call   1fb6 <botlish_fn_21+0x232>
			1fb2: R_X86_64_PLT32	rt_stack_overflow-0x4
    1fb6:	xor    rax,rax
    1fb9:	mov    rbx,QWORD PTR [rsp+0x10]
    1fbe:	mov    r12,QWORD PTR [rsp+0x18]
    1fc3:	mov    r13,QWORD PTR [rsp+0x20]
    1fc8:	mov    r14,QWORD PTR [rsp+0x28]
    1fcd:	mov    r15,QWORD PTR [rsp+0x30]
    1fd2:	add    rsp,0x40
    1fd6:	mov    rsp,rbp
    1fd9:	pop    rbp
    1fda:	ret

0000000000001fdb <botlish_entry_21: ht_alloc<int>>:
    1fdb:	push   rbp
    1fdc:	mov    rbp,rsp
    1fdf:	mov    rsi,QWORD PTR [rdx]
    1fe2:	call   1fe7 <botlish_entry_21+0xc>
			1fe3: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1fe7:	mov    rsp,rbp
    1fea:	pop    rbp
    1feb:	ret

0000000000001fec <botlish_fn_22: ht_new<generic>>:
    1fec:	push   rbp
    1fed:	mov    rbp,rsp
    1ff0:	sub    rsp,0x10
    1ff4:	mov    QWORD PTR [rsp],r12
    1ff8:	mov    QWORD PTR [rsp+0x8],r13
    1ffd:	mov    r12,QWORD PTR [rdi]
    2000:	mov    rax,QWORD PTR [rdi+0x8]
    2004:	lea    rcx,[r12+0x8]
    2009:	cmp    rcx,rax
    200c:	ja     208c <botlish_fn_22+0xa0>
    2012:	lea    rax,[r12+0x8]
    2017:	mov    QWORD PTR [rdi],rax
    201a:	mov    r13,rdi
    201d:	mov    QWORD PTR [r12],0x0
    2025:	mov    rdi,r13
    2028:	call   202d <botlish_fn_22+0x41>
			2029: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    202d:	test   rax,rax
    2030:	jne    203e <botlish_fn_22+0x52>
    2036:	mov    rdi,r13
    2039:	jmp    2059 <botlish_fn_22+0x6d>
    203e:	mov    QWORD PTR [r12],rax
    2042:	mov    rsi,rax
    2045:	mov    rdi,r13
    2048:	call   204d <botlish_fn_22+0x61>
			2049: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    204d:	test   rax,rax
    2050:	jne    2074 <botlish_fn_22+0x88>
    2056:	mov    rdi,r13
    2059:	mov    rdi,r13
    205c:	mov    QWORD PTR [rdi],r12
    205f:	xor    rax,rax
    2062:	mov    r12,QWORD PTR [rsp]
    2066:	mov    r13,QWORD PTR [rsp+0x8]
    206b:	add    rsp,0x10
    206f:	mov    rsp,rbp
    2072:	pop    rbp
    2073:	ret
    2074:	mov    rdi,r13
    2077:	mov    QWORD PTR [rdi],r12
    207a:	mov    r12,QWORD PTR [rsp]
    207e:	mov    r13,QWORD PTR [rsp+0x8]
    2083:	add    rsp,0x10
    2087:	mov    rsp,rbp
    208a:	pop    rbp
    208b:	ret
    208c:	mov    r13,rdi
    208f:	call   2094 <botlish_fn_22+0xa8>
			2090: R_X86_64_PLT32	rt_stack_overflow-0x4
    2094:	xor    rax,rax
    2097:	mov    r12,QWORD PTR [rsp]
    209b:	mov    r13,QWORD PTR [rsp+0x8]
    20a0:	add    rsp,0x10
    20a4:	mov    rsp,rbp
    20a7:	pop    rbp
    20a8:	ret

00000000000020a9 <botlish_entry_22: ht_new<generic>>:
    20a9:	push   rbp
    20aa:	mov    rbp,rsp
    20ad:	call   20b2 <botlish_entry_22+0x9>
			20ae: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    20b2:	mov    rsp,rbp
    20b5:	pop    rbp
    20b6:	ret
	...

00000000000020b8 <botlish_fn_23: ht_capacity_for<int, int>>:
    20b8:	push   rbp
    20b9:	mov    rbp,rsp
    20bc:	sub    rsp,0x60
    20c0:	mov    QWORD PTR [rsp+0x30],rbx
    20c5:	mov    QWORD PTR [rsp+0x38],r12
    20ca:	mov    QWORD PTR [rsp+0x40],r13
    20cf:	mov    QWORD PTR [rsp+0x48],r14
    20d4:	mov    QWORD PTR [rsp+0x50],r15
    20d9:	mov    rbx,QWORD PTR [rdi+0x20]
    20dd:	mov    r12,QWORD PTR [rdi+0x28]
    20e1:	lea    rax,[rsp]
    20e5:	mov    QWORD PTR [rdi+0x20],rax
    20e9:	mov    QWORD PTR [rdi+0x28],0x3
    20f1:	mov    QWORD PTR [rsp],rdx
    20f5:	mov    r13,rsi
    20f8:	or     r13,0x1
    20fc:	sar    r13,1
    20ff:	mov    r14,rsi
    2102:	mov    QWORD PTR [rsp+0x18],rdx
    2107:	mov    rax,r14
    210a:	or     rax,0x1
    210e:	mov    QWORD PTR [rsp+0x8],rax
    2113:	mov    QWORD PTR [rsp+0x10],0x7
    211c:	mov    rax,r13
    211f:	imul   QWORD PTR [rip+0x17a]        # 22a0 <botlish_fn_23+0x1e8>
    2126:	seto   cl
    2129:	or     rax,0x1
    212d:	test   cl,cl
    212f:	jne    2140 <botlish_fn_23+0x88>
    2135:	mov    rsi,rax
    2138:	mov    r15,rdi
    213b:	jmp    2157 <botlish_fn_23+0x9f>
    2140:	mov    rsi,r14
    2143:	or     rsi,0x1
    2147:	mov    edx,0x7
    214c:	mov    r15,rdi
    214f:	call   2154 <botlish_fn_23+0x9c>
			2150: R_X86_64_PLT32	rt_int_mul-0x4
    2154:	mov    rsi,rax
    2157:	mov    QWORD PTR [rsp+0x8],rsi
    215c:	mov    QWORD PTR [rsp+0x20],rsi
    2161:	mov    QWORD PTR [rsp+0x10],0x5
    216a:	mov    rsi,QWORD PTR [rsp+0x18]
    216f:	test   rsi,0x1
    2176:	je     21aa <botlish_fn_23+0xf2>
    217c:	mov    rsi,QWORD PTR [rsp+0x18]
    2181:	mov    rax,rsi
    2184:	sar    rax,1
    2187:	imul   QWORD PTR [rip+0x11a]        # 22a8 <botlish_fn_23+0x1f0>
    218e:	seto   cl
    2191:	or     rax,0x1
    2195:	test   cl,cl
    2197:	jne    21aa <botlish_fn_23+0xf2>
    219d:	mov    rdx,rax
    21a0:	mov    rsi,QWORD PTR [rsp+0x20]
    21a5:	jmp    21c4 <botlish_fn_23+0x10c>
    21aa:	mov    edx,0x5
    21af:	mov    rsi,QWORD PTR [rsp+0x18]
    21b4:	mov    rdi,r15
    21b7:	call   21bc <botlish_fn_23+0x104>
			21b8: R_X86_64_PLT32	rt_int_mul-0x4
    21bc:	mov    rdx,rax
    21bf:	mov    rsi,QWORD PTR [rsp+0x20]
    21c4:	mov    rax,rsi
    21c7:	and    rax,rdx
    21ca:	test   rax,0x1
    21d0:	jne    21f3 <botlish_fn_23+0x13b>
    21d6:	mov    rdi,r15
    21d9:	call   21de <botlish_fn_23+0x126>
			21da: R_X86_64_PLT32	rt_int_cmp-0x4
    21de:	mov    ecx,0x2
    21e3:	test   rax,rax
    21e6:	cmovle rcx,QWORD PTR [rip+0xb2]        # 22a0 <botlish_fn_23+0x1e8>
    21ee:	jmp    2203 <botlish_fn_23+0x14b>
    21f3:	mov    ecx,0x2
    21f8:	cmp    rsi,rdx
    21fb:	cmovle rcx,QWORD PTR [rip+0x9d]        # 22a0 <botlish_fn_23+0x1e8>
    2203:	cmp    rcx,0x6
    2207:	je     226e <botlish_fn_23+0x1b6>
    220d:	mov    QWORD PTR [rsp+0x8],0x5
    2216:	mov    rsi,QWORD PTR [rsp+0x18]
    221b:	test   rsi,0x1
    2222:	je     224b <botlish_fn_23+0x193>
    2228:	mov    rsi,QWORD PTR [rsp+0x18]
    222d:	mov    rax,rsi
    2230:	sar    rax,1
    2233:	imul   QWORD PTR [rip+0x6e]        # 22a8 <botlish_fn_23+0x1f0>
    223a:	seto   r11b
    223e:	or     rax,0x1
    2242:	test   r11b,r11b
    2245:	je     225d <botlish_fn_23+0x1a5>
    224b:	mov    edx,0x5
    2250:	mov    rsi,QWORD PTR [rsp+0x18]
    2255:	mov    rdi,r15
    2258:	call   225d <botlish_fn_23+0x1a5>
			2259: R_X86_64_PLT32	rt_int_mul-0x4
    225d:	mov    QWORD PTR [rsp],rax
    2261:	mov    rdi,r15
    2264:	mov    QWORD PTR [rsp+0x18],rax
    2269:	jmp    2107 <botlish_fn_23+0x4f>
    226e:	mov    QWORD PTR [r15+0x20],rbx
    2272:	mov    QWORD PTR [r15+0x28],r12
    2276:	mov    rax,QWORD PTR [rsp+0x18]
    227b:	mov    rbx,QWORD PTR [rsp+0x30]
    2280:	mov    r12,QWORD PTR [rsp+0x38]
    2285:	mov    r13,QWORD PTR [rsp+0x40]
    228a:	mov    r14,QWORD PTR [rsp+0x48]
    228f:	mov    r15,QWORD PTR [rsp+0x50]
    2294:	add    rsp,0x60
    2298:	mov    rsp,rbp
    229b:	pop    rbp
    229c:	ret
    229d:	add    BYTE PTR [rax],al
    229f:	add    BYTE PTR [rsi],al
    22a1:	add    BYTE PTR [rax],al
    22a3:	add    BYTE PTR [rax],al
    22a5:	add    BYTE PTR [rax],al
    22a7:	add    BYTE PTR [rax+rax*1],al
    22aa:	add    BYTE PTR [rax],al
    22ac:	add    BYTE PTR [rax],al
	...

00000000000022b0 <botlish_entry_23: ht_capacity_for<int, int>>:
    22b0:	push   rbp
    22b1:	mov    rbp,rsp
    22b4:	mov    rsi,QWORD PTR [rdx]
    22b7:	mov    rdx,QWORD PTR [rdx+0x8]
    22bb:	call   22c0 <botlish_entry_23+0x10>
			22bc: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    22c0:	mov    rsp,rbp
    22c3:	pop    rbp
    22c4:	ret

00000000000022c5 <botlish_fn_24: ht_new_sized<int>>:
    22c5:	push   rbp
    22c6:	mov    rbp,rsp
    22c9:	sub    rsp,0x20
    22cd:	mov    QWORD PTR [rsp],rbx
    22d1:	mov    QWORD PTR [rsp+0x8],r14
    22d6:	mov    QWORD PTR [rsp+0x10],r15
    22db:	mov    r14,QWORD PTR [rdi]
    22de:	mov    rax,QWORD PTR [rdi+0x8]
    22e2:	lea    rcx,[r14+0x10]
    22e6:	cmp    rcx,rax
    22e9:	ja     239a <botlish_fn_24+0xd5>
    22ef:	lea    rax,[r14+0x10]
    22f3:	mov    QWORD PTR [rdi],rax
    22f6:	mov    r15,rdi
    22f9:	mov    QWORD PTR [r14+0x8],0x0
    2301:	mov    QWORD PTR [r14],rsi
    2304:	mov    rbx,rsi
    2307:	mov    rdi,r15
    230a:	call   230f <botlish_fn_24+0x4a>
			230b: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    230f:	test   rax,rax
    2312:	jne    2320 <botlish_fn_24+0x5b>
    2318:	mov    rdi,r15
    231b:	jmp    235d <botlish_fn_24+0x98>
    2320:	mov    QWORD PTR [r14+0x8],rax
    2324:	mov    rdx,rax
    2327:	mov    rsi,rbx
    232a:	mov    rdi,r15
    232d:	call   2332 <botlish_fn_24+0x6d>
			232e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    2332:	test   rax,rax
    2335:	jne    2343 <botlish_fn_24+0x7e>
    233b:	mov    rdi,r15
    233e:	jmp    235d <botlish_fn_24+0x98>
    2343:	mov    QWORD PTR [r14],rax
    2346:	mov    rsi,rax
    2349:	mov    rdi,r15
    234c:	call   2351 <botlish_fn_24+0x8c>
			234d: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2351:	test   rax,rax
    2354:	jne    237d <botlish_fn_24+0xb8>
    235a:	mov    rdi,r15
    235d:	mov    rdi,r15
    2360:	mov    QWORD PTR [rdi],r14
    2363:	xor    rax,rax
    2366:	mov    rbx,QWORD PTR [rsp]
    236a:	mov    r14,QWORD PTR [rsp+0x8]
    236f:	mov    r15,QWORD PTR [rsp+0x10]
    2374:	add    rsp,0x20
    2378:	mov    rsp,rbp
    237b:	pop    rbp
    237c:	ret
    237d:	mov    rdi,r15
    2380:	mov    QWORD PTR [rdi],r14
    2383:	mov    rbx,QWORD PTR [rsp]
    2387:	mov    r14,QWORD PTR [rsp+0x8]
    238c:	mov    r15,QWORD PTR [rsp+0x10]
    2391:	add    rsp,0x20
    2395:	mov    rsp,rbp
    2398:	pop    rbp
    2399:	ret
    239a:	mov    r15,rdi
    239d:	call   23a2 <botlish_fn_24+0xdd>
			239e: R_X86_64_PLT32	rt_stack_overflow-0x4
    23a2:	xor    rax,rax
    23a5:	mov    rbx,QWORD PTR [rsp]
    23a9:	mov    r14,QWORD PTR [rsp+0x8]
    23ae:	mov    r15,QWORD PTR [rsp+0x10]
    23b3:	add    rsp,0x20
    23b7:	mov    rsp,rbp
    23ba:	pop    rbp
    23bb:	ret

00000000000023bc <botlish_entry_24: ht_new_sized<int>>:
    23bc:	push   rbp
    23bd:	mov    rbp,rsp
    23c0:	mov    rsi,QWORD PTR [rdx]
    23c3:	call   23c8 <botlish_entry_24+0xc>
			23c4: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    23c8:	mov    rsp,rbp
    23cb:	pop    rbp
    23cc:	ret

00000000000023cd <botlish_fn_25: ht_controls<mutarray>>:
    23cd:	push   rbp
    23ce:	mov    rbp,rsp
    23d1:	mov    edx,0x1
    23d6:	call   23db <botlish_fn_25+0xe>
			23d7: R_X86_64_PLT32	rt_mutarray_get-0x4
    23db:	test   rax,rax
    23de:	jne    23ec <botlish_fn_25+0x1f>
    23e4:	xor    rax,rax
    23e7:	mov    rsp,rbp
    23ea:	pop    rbp
    23eb:	ret
    23ec:	mov    rsp,rbp
    23ef:	pop    rbp
    23f0:	ret

00000000000023f1 <botlish_entry_25: ht_controls<mutarray>>:
    23f1:	push   rbp
    23f2:	mov    rbp,rsp
    23f5:	mov    rsi,QWORD PTR [rdx]
    23f8:	call   23fd <botlish_entry_25+0xc>
			23f9: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    23fd:	mov    rsp,rbp
    2400:	pop    rbp
    2401:	ret

0000000000002402 <botlish_fn_26: ht_controls<generic>>:
    2402:	push   rbp
    2403:	mov    rbp,rsp
    2406:	xor    r8d,r8d
    2409:	test   rsi,0x7
    2410:	jne    2420 <botlish_fn_26+0x1e>
    2416:	movzx  rax,BYTE PTR [rsi]
    241a:	cmp    al,0x8
    241c:	sete   r8b
    2420:	test   r8b,r8b
    2423:	jne    2440 <botlish_fn_26+0x3e>
    2429:	mov    rax,QWORD PTR [rdi+0x10]
    242d:	mov    rcx,QWORD PTR [rax+0x20]
    2431:	mov    edx,0x8
    2436:	call   243b <botlish_fn_26+0x39>
			2437: R_X86_64_PLT32	rt_type_error-0x4
    243b:	jmp    2453 <botlish_fn_26+0x51>
    2440:	mov    edx,0x1
    2445:	call   244a <botlish_fn_26+0x48>
			2446: R_X86_64_PLT32	rt_mutarray_get-0x4
    244a:	test   rax,rax
    244d:	jne    245b <botlish_fn_26+0x59>
    2453:	xor    rax,rax
    2456:	mov    rsp,rbp
    2459:	pop    rbp
    245a:	ret
    245b:	mov    rsp,rbp
    245e:	pop    rbp
    245f:	ret

0000000000002460 <botlish_entry_26: ht_controls<generic>>:
    2460:	push   rbp
    2461:	mov    rbp,rsp
    2464:	mov    rsi,QWORD PTR [rdx]
    2467:	call   246c <botlish_entry_26+0xc>
			2468: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    246c:	mov    rsp,rbp
    246f:	pop    rbp
    2470:	ret

0000000000002471 <botlish_fn_27: ht_keys<mutarray>>:
    2471:	push   rbp
    2472:	mov    rbp,rsp
    2475:	mov    edx,0x3
    247a:	call   247f <botlish_fn_27+0xe>
			247b: R_X86_64_PLT32	rt_mutarray_get-0x4
    247f:	test   rax,rax
    2482:	jne    2490 <botlish_fn_27+0x1f>
    2488:	xor    rax,rax
    248b:	mov    rsp,rbp
    248e:	pop    rbp
    248f:	ret
    2490:	mov    rsp,rbp
    2493:	pop    rbp
    2494:	ret

0000000000002495 <botlish_entry_27: ht_keys<mutarray>>:
    2495:	push   rbp
    2496:	mov    rbp,rsp
    2499:	mov    rsi,QWORD PTR [rdx]
    249c:	call   24a1 <botlish_entry_27+0xc>
			249d: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    24a1:	mov    rsp,rbp
    24a4:	pop    rbp
    24a5:	ret

00000000000024a6 <botlish_fn_28: ht_keys<generic>>:
    24a6:	push   rbp
    24a7:	mov    rbp,rsp
    24aa:	xor    r8d,r8d
    24ad:	test   rsi,0x7
    24b4:	jne    24c4 <botlish_fn_28+0x1e>
    24ba:	movzx  rax,BYTE PTR [rsi]
    24be:	cmp    al,0x8
    24c0:	sete   r8b
    24c4:	test   r8b,r8b
    24c7:	jne    24e4 <botlish_fn_28+0x3e>
    24cd:	mov    rax,QWORD PTR [rdi+0x10]
    24d1:	mov    rcx,QWORD PTR [rax+0x20]
    24d5:	mov    edx,0x8
    24da:	call   24df <botlish_fn_28+0x39>
			24db: R_X86_64_PLT32	rt_type_error-0x4
    24df:	jmp    24f7 <botlish_fn_28+0x51>
    24e4:	mov    edx,0x3
    24e9:	call   24ee <botlish_fn_28+0x48>
			24ea: R_X86_64_PLT32	rt_mutarray_get-0x4
    24ee:	test   rax,rax
    24f1:	jne    24ff <botlish_fn_28+0x59>
    24f7:	xor    rax,rax
    24fa:	mov    rsp,rbp
    24fd:	pop    rbp
    24fe:	ret
    24ff:	mov    rsp,rbp
    2502:	pop    rbp
    2503:	ret

0000000000002504 <botlish_entry_28: ht_keys<generic>>:
    2504:	push   rbp
    2505:	mov    rbp,rsp
    2508:	mov    rsi,QWORD PTR [rdx]
    250b:	call   2510 <botlish_entry_28+0xc>
			250c: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2510:	mov    rsp,rbp
    2513:	pop    rbp
    2514:	ret

0000000000002515 <botlish_fn_29: ht_values<mutarray>>:
    2515:	push   rbp
    2516:	mov    rbp,rsp
    2519:	mov    edx,0x5
    251e:	call   2523 <botlish_fn_29+0xe>
			251f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2523:	test   rax,rax
    2526:	jne    2534 <botlish_fn_29+0x1f>
    252c:	xor    rax,rax
    252f:	mov    rsp,rbp
    2532:	pop    rbp
    2533:	ret
    2534:	mov    rsp,rbp
    2537:	pop    rbp
    2538:	ret

0000000000002539 <botlish_entry_29: ht_values<mutarray>>:
    2539:	push   rbp
    253a:	mov    rbp,rsp
    253d:	mov    rsi,QWORD PTR [rdx]
    2540:	call   2545 <botlish_entry_29+0xc>
			2541: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    2545:	mov    rsp,rbp
    2548:	pop    rbp
    2549:	ret

000000000000254a <botlish_fn_30: ht_values<generic>>:
    254a:	push   rbp
    254b:	mov    rbp,rsp
    254e:	xor    r8d,r8d
    2551:	test   rsi,0x7
    2558:	jne    2568 <botlish_fn_30+0x1e>
    255e:	movzx  rax,BYTE PTR [rsi]
    2562:	cmp    al,0x8
    2564:	sete   r8b
    2568:	test   r8b,r8b
    256b:	jne    2588 <botlish_fn_30+0x3e>
    2571:	mov    rax,QWORD PTR [rdi+0x10]
    2575:	mov    rcx,QWORD PTR [rax+0x20]
    2579:	mov    edx,0x8
    257e:	call   2583 <botlish_fn_30+0x39>
			257f: R_X86_64_PLT32	rt_type_error-0x4
    2583:	jmp    259b <botlish_fn_30+0x51>
    2588:	mov    edx,0x5
    258d:	call   2592 <botlish_fn_30+0x48>
			258e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2592:	test   rax,rax
    2595:	jne    25a3 <botlish_fn_30+0x59>
    259b:	xor    rax,rax
    259e:	mov    rsp,rbp
    25a1:	pop    rbp
    25a2:	ret
    25a3:	mov    rsp,rbp
    25a6:	pop    rbp
    25a7:	ret

00000000000025a8 <botlish_entry_30: ht_values<generic>>:
    25a8:	push   rbp
    25a9:	mov    rbp,rsp
    25ac:	mov    rsi,QWORD PTR [rdx]
    25af:	call   25b4 <botlish_entry_30+0xc>
			25b0: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    25b4:	mov    rsp,rbp
    25b7:	pop    rbp
    25b8:	ret

00000000000025b9 <botlish_fn_31: ht_size<mutarray>>:
    25b9:	push   rbp
    25ba:	mov    rbp,rsp
    25bd:	mov    edx,0x7
    25c2:	call   25c7 <botlish_fn_31+0xe>
			25c3: R_X86_64_PLT32	rt_mutarray_get-0x4
    25c7:	test   rax,rax
    25ca:	jne    25d8 <botlish_fn_31+0x1f>
    25d0:	xor    rax,rax
    25d3:	mov    rsp,rbp
    25d6:	pop    rbp
    25d7:	ret
    25d8:	mov    rsp,rbp
    25db:	pop    rbp
    25dc:	ret

00000000000025dd <botlish_entry_31: ht_size<mutarray>>:
    25dd:	push   rbp
    25de:	mov    rbp,rsp
    25e1:	mov    rsi,QWORD PTR [rdx]
    25e4:	call   25e9 <botlish_entry_31+0xc>
			25e5: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    25e9:	mov    rsp,rbp
    25ec:	pop    rbp
    25ed:	ret

00000000000025ee <botlish_fn_32: ht_size<generic>>:
    25ee:	push   rbp
    25ef:	mov    rbp,rsp
    25f2:	xor    r8d,r8d
    25f5:	test   rsi,0x7
    25fc:	jne    260c <botlish_fn_32+0x1e>
    2602:	movzx  rax,BYTE PTR [rsi]
    2606:	cmp    al,0x8
    2608:	sete   r8b
    260c:	test   r8b,r8b
    260f:	jne    262c <botlish_fn_32+0x3e>
    2615:	mov    rax,QWORD PTR [rdi+0x10]
    2619:	mov    rcx,QWORD PTR [rax+0x20]
    261d:	mov    edx,0x8
    2622:	call   2627 <botlish_fn_32+0x39>
			2623: R_X86_64_PLT32	rt_type_error-0x4
    2627:	jmp    263f <botlish_fn_32+0x51>
    262c:	mov    edx,0x7
    2631:	call   2636 <botlish_fn_32+0x48>
			2632: R_X86_64_PLT32	rt_mutarray_get-0x4
    2636:	test   rax,rax
    2639:	jne    2647 <botlish_fn_32+0x59>
    263f:	xor    rax,rax
    2642:	mov    rsp,rbp
    2645:	pop    rbp
    2646:	ret
    2647:	mov    rsp,rbp
    264a:	pop    rbp
    264b:	ret

000000000000264c <botlish_entry_32: ht_size<generic>>:
    264c:	push   rbp
    264d:	mov    rbp,rsp
    2650:	mov    rsi,QWORD PTR [rdx]
    2653:	call   2658 <botlish_entry_32+0xc>
			2654: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    2658:	mov    rsp,rbp
    265b:	pop    rbp
    265c:	ret

000000000000265d <botlish_fn_33: ht_tombstones<mutarray>>:
    265d:	push   rbp
    265e:	mov    rbp,rsp
    2661:	mov    edx,0x9
    2666:	call   266b <botlish_fn_33+0xe>
			2667: R_X86_64_PLT32	rt_mutarray_get-0x4
    266b:	test   rax,rax
    266e:	jne    267c <botlish_fn_33+0x1f>
    2674:	xor    rax,rax
    2677:	mov    rsp,rbp
    267a:	pop    rbp
    267b:	ret
    267c:	mov    rsp,rbp
    267f:	pop    rbp
    2680:	ret

0000000000002681 <botlish_entry_33: ht_tombstones<mutarray>>:
    2681:	push   rbp
    2682:	mov    rbp,rsp
    2685:	mov    rsi,QWORD PTR [rdx]
    2688:	call   268d <botlish_entry_33+0xc>
			2689: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    268d:	mov    rsp,rbp
    2690:	pop    rbp
    2691:	ret

0000000000002692 <botlish_fn_34: ht_capacity<mutarray>>:
    2692:	push   rbp
    2693:	mov    rbp,rsp
    2696:	sub    rsp,0x10
    269a:	mov    QWORD PTR [rsp],rbx
    269e:	mov    QWORD PTR [rsp+0x8],r12
    26a3:	mov    rbx,QWORD PTR [rdi]
    26a6:	mov    rax,QWORD PTR [rdi+0x8]
    26aa:	lea    rcx,[rbx+0x8]
    26ae:	cmp    rcx,rax
    26b1:	ja     275c <botlish_fn_34+0xca>
    26b7:	lea    rax,[rbx+0x8]
    26bb:	mov    QWORD PTR [rdi],rax
    26be:	mov    r12,rdi
    26c1:	mov    QWORD PTR [rbx],rsi
    26c4:	mov    rdi,r12
    26c7:	call   26cc <botlish_fn_34+0x3a>
			26c8: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    26cc:	test   rax,rax
    26cf:	jne    26dd <botlish_fn_34+0x4b>
    26d5:	mov    rdi,r12
    26d8:	jmp    2721 <botlish_fn_34+0x8f>
    26dd:	xor    ecx,ecx
    26df:	test   rax,0x7
    26e5:	je     26f3 <botlish_fn_34+0x61>
    26eb:	mov    rsi,rax
    26ee:	jmp    2701 <botlish_fn_34+0x6f>
    26f3:	movzx  rcx,BYTE PTR [rax]
    26f7:	mov    rsi,rax
    26fa:	rex cmp cl,0x8
    26fe:	sete   cl
    2701:	test   cl,cl
    2703:	jne    273c <botlish_fn_34+0xaa>
    2709:	mov    rdi,r12
    270c:	mov    rax,QWORD PTR [rdi+0x10]
    2710:	mov    rcx,QWORD PTR [rax+0x28]
    2714:	mov    edx,0x8
    2719:	call   271e <botlish_fn_34+0x8c>
			271a: R_X86_64_PLT32	rt_type_error-0x4
    271e:	mov    rdi,r12
    2721:	mov    rdi,r12
    2724:	mov    QWORD PTR [rdi],rbx
    2727:	xor    rax,rax
    272a:	mov    rbx,QWORD PTR [rsp]
    272e:	mov    r12,QWORD PTR [rsp+0x8]
    2733:	add    rsp,0x10
    2737:	mov    rsp,rbp
    273a:	pop    rbp
    273b:	ret
    273c:	mov    rdi,r12
    273f:	call   2744 <botlish_fn_34+0xb2>
			2740: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2744:	mov    rdi,r12
    2747:	mov    QWORD PTR [rdi],rbx
    274a:	mov    rbx,QWORD PTR [rsp]
    274e:	mov    r12,QWORD PTR [rsp+0x8]
    2753:	add    rsp,0x10
    2757:	mov    rsp,rbp
    275a:	pop    rbp
    275b:	ret
    275c:	mov    r12,rdi
    275f:	call   2764 <botlish_fn_34+0xd2>
			2760: R_X86_64_PLT32	rt_stack_overflow-0x4
    2764:	xor    rax,rax
    2767:	mov    rbx,QWORD PTR [rsp]
    276b:	mov    r12,QWORD PTR [rsp+0x8]
    2770:	add    rsp,0x10
    2774:	mov    rsp,rbp
    2777:	pop    rbp
    2778:	ret

0000000000002779 <botlish_entry_34: ht_capacity<mutarray>>:
    2779:	push   rbp
    277a:	mov    rbp,rsp
    277d:	mov    rsi,QWORD PTR [rdx]
    2780:	call   2785 <botlish_entry_34+0xc>
			2781: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2785:	mov    rsp,rbp
    2788:	pop    rbp
    2789:	ret

000000000000278a <botlish_fn_35: ht_capacity<generic>>:
    278a:	push   rbp
    278b:	mov    rbp,rsp
    278e:	sub    rsp,0x10
    2792:	mov    QWORD PTR [rsp],rbx
    2796:	mov    QWORD PTR [rsp+0x8],r12
    279b:	mov    rbx,QWORD PTR [rdi]
    279e:	mov    rax,QWORD PTR [rdi+0x8]
    27a2:	lea    rcx,[rbx+0x8]
    27a6:	cmp    rcx,rax
    27a9:	ja     2854 <botlish_fn_35+0xca>
    27af:	lea    rax,[rbx+0x8]
    27b3:	mov    QWORD PTR [rdi],rax
    27b6:	mov    r12,rdi
    27b9:	mov    QWORD PTR [rbx],rsi
    27bc:	mov    rdi,r12
    27bf:	call   27c4 <botlish_fn_35+0x3a>
			27c0: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    27c4:	test   rax,rax
    27c7:	jne    27d5 <botlish_fn_35+0x4b>
    27cd:	mov    rdi,r12
    27d0:	jmp    2819 <botlish_fn_35+0x8f>
    27d5:	xor    ecx,ecx
    27d7:	test   rax,0x7
    27dd:	je     27eb <botlish_fn_35+0x61>
    27e3:	mov    rsi,rax
    27e6:	jmp    27f9 <botlish_fn_35+0x6f>
    27eb:	movzx  rcx,BYTE PTR [rax]
    27ef:	mov    rsi,rax
    27f2:	rex cmp cl,0x8
    27f6:	sete   cl
    27f9:	test   cl,cl
    27fb:	jne    2834 <botlish_fn_35+0xaa>
    2801:	mov    rdi,r12
    2804:	mov    rax,QWORD PTR [rdi+0x10]
    2808:	mov    rcx,QWORD PTR [rax+0x28]
    280c:	mov    edx,0x8
    2811:	call   2816 <botlish_fn_35+0x8c>
			2812: R_X86_64_PLT32	rt_type_error-0x4
    2816:	mov    rdi,r12
    2819:	mov    rdi,r12
    281c:	mov    QWORD PTR [rdi],rbx
    281f:	xor    rax,rax
    2822:	mov    rbx,QWORD PTR [rsp]
    2826:	mov    r12,QWORD PTR [rsp+0x8]
    282b:	add    rsp,0x10
    282f:	mov    rsp,rbp
    2832:	pop    rbp
    2833:	ret
    2834:	mov    rdi,r12
    2837:	call   283c <botlish_fn_35+0xb2>
			2838: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    283c:	mov    rdi,r12
    283f:	mov    QWORD PTR [rdi],rbx
    2842:	mov    rbx,QWORD PTR [rsp]
    2846:	mov    r12,QWORD PTR [rsp+0x8]
    284b:	add    rsp,0x10
    284f:	mov    rsp,rbp
    2852:	pop    rbp
    2853:	ret
    2854:	mov    r12,rdi
    2857:	call   285c <botlish_fn_35+0xd2>
			2858: R_X86_64_PLT32	rt_stack_overflow-0x4
    285c:	xor    rax,rax
    285f:	mov    rbx,QWORD PTR [rsp]
    2863:	mov    r12,QWORD PTR [rsp+0x8]
    2868:	add    rsp,0x10
    286c:	mov    rsp,rbp
    286f:	pop    rbp
    2870:	ret

0000000000002871 <botlish_entry_35: ht_capacity<generic>>:
    2871:	push   rbp
    2872:	mov    rbp,rsp
    2875:	mov    rsi,QWORD PTR [rdx]
    2878:	call   287d <botlish_entry_35+0xc>
			2879: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    287d:	mov    rsp,rbp
    2880:	pop    rbp
    2881:	ret

0000000000002882 <botlish_fn_36: ht_probe_start<mutarray, any>>:
    2882:	push   rbp
    2883:	mov    rbp,rsp
    2886:	sub    rsp,0x20
    288a:	mov    QWORD PTR [rsp],rbx
    288e:	mov    QWORD PTR [rsp+0x8],r12
    2893:	mov    QWORD PTR [rsp+0x10],r15
    2898:	mov    r15,QWORD PTR [rdi]
    289b:	mov    rax,QWORD PTR [rdi+0x8]
    289f:	lea    rcx,[r15+0x10]
    28a3:	cmp    rcx,rax
    28a6:	ja     2952 <botlish_fn_36+0xd0>
    28ac:	lea    rax,[r15+0x10]
    28b0:	mov    QWORD PTR [rdi],rax
    28b3:	mov    rbx,rdi
    28b6:	mov    QWORD PTR [r15],rsi
    28b9:	mov    r12,rsi
    28bc:	mov    rsi,rdx
    28bf:	mov    rdi,rbx
    28c2:	call   28c7 <botlish_fn_36+0x45>
			28c3: R_X86_64_PLT32	rt_hash-0x4
    28c7:	test   rax,rax
    28ca:	jne    28d8 <botlish_fn_36+0x56>
    28d0:	mov    rdi,rbx
    28d3:	jmp    2915 <botlish_fn_36+0x93>
    28d8:	mov    QWORD PTR [r15+0x8],rax
    28dc:	mov    rsi,r12
    28df:	mov    r12,rax
    28e2:	mov    rdi,rbx
    28e5:	call   28ea <botlish_fn_36+0x68>
			28e6: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    28ea:	test   rax,rax
    28ed:	mov    rdx,rax
    28f0:	jne    28fe <botlish_fn_36+0x7c>
    28f6:	mov    rdi,rbx
    28f9:	jmp    2915 <botlish_fn_36+0x93>
    28fe:	mov    rsi,r12
    2901:	mov    rdi,rbx
    2904:	call   2909 <botlish_fn_36+0x87>
			2905: R_X86_64_PLT32	rt_int_mod-0x4
    2909:	test   rax,rax
    290c:	jne    2935 <botlish_fn_36+0xb3>
    2912:	mov    rdi,rbx
    2915:	mov    rdi,rbx
    2918:	mov    QWORD PTR [rdi],r15
    291b:	xor    rax,rax
    291e:	mov    rbx,QWORD PTR [rsp]
    2922:	mov    r12,QWORD PTR [rsp+0x8]
    2927:	mov    r15,QWORD PTR [rsp+0x10]
    292c:	add    rsp,0x20
    2930:	mov    rsp,rbp
    2933:	pop    rbp
    2934:	ret
    2935:	mov    rdi,rbx
    2938:	mov    QWORD PTR [rdi],r15
    293b:	mov    rbx,QWORD PTR [rsp]
    293f:	mov    r12,QWORD PTR [rsp+0x8]
    2944:	mov    r15,QWORD PTR [rsp+0x10]
    2949:	add    rsp,0x20
    294d:	mov    rsp,rbp
    2950:	pop    rbp
    2951:	ret
    2952:	mov    rbx,rdi
    2955:	call   295a <botlish_fn_36+0xd8>
			2956: R_X86_64_PLT32	rt_stack_overflow-0x4
    295a:	xor    rax,rax
    295d:	mov    rbx,QWORD PTR [rsp]
    2961:	mov    r12,QWORD PTR [rsp+0x8]
    2966:	mov    r15,QWORD PTR [rsp+0x10]
    296b:	add    rsp,0x20
    296f:	mov    rsp,rbp
    2972:	pop    rbp
    2973:	ret

0000000000002974 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    2974:	push   rbp
    2975:	mov    rbp,rsp
    2978:	mov    rsi,QWORD PTR [rdx]
    297b:	mov    rdx,QWORD PTR [rdx+0x8]
    297f:	call   2984 <botlish_entry_36+0x10>
			2980: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    2984:	mov    rsp,rbp
    2987:	pop    rbp
    2988:	ret

0000000000002989 <botlish_fn_37: ht_probe_start<any, str>>:
    2989:	push   rbp
    298a:	mov    rbp,rsp
    298d:	sub    rsp,0x20
    2991:	mov    QWORD PTR [rsp],rbx
    2995:	mov    QWORD PTR [rsp+0x8],r12
    299a:	mov    QWORD PTR [rsp+0x10],r15
    299f:	mov    r15,QWORD PTR [rdi]
    29a2:	mov    rax,QWORD PTR [rdi+0x8]
    29a6:	lea    rcx,[r15+0x10]
    29aa:	cmp    rcx,rax
    29ad:	ja     2a59 <botlish_fn_37+0xd0>
    29b3:	lea    rax,[r15+0x10]
    29b7:	mov    QWORD PTR [rdi],rax
    29ba:	mov    rbx,rdi
    29bd:	mov    QWORD PTR [r15],rsi
    29c0:	mov    r12,rsi
    29c3:	mov    rsi,rdx
    29c6:	mov    rdi,rbx
    29c9:	call   29ce <botlish_fn_37+0x45>
			29ca: R_X86_64_PLT32	rt_hash-0x4
    29ce:	test   rax,rax
    29d1:	jne    29df <botlish_fn_37+0x56>
    29d7:	mov    rdi,rbx
    29da:	jmp    2a1c <botlish_fn_37+0x93>
    29df:	mov    QWORD PTR [r15+0x8],rax
    29e3:	mov    rsi,r12
    29e6:	mov    r12,rax
    29e9:	mov    rdi,rbx
    29ec:	call   29f1 <botlish_fn_37+0x68>
			29ed: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    29f1:	test   rax,rax
    29f4:	mov    rdx,rax
    29f7:	jne    2a05 <botlish_fn_37+0x7c>
    29fd:	mov    rdi,rbx
    2a00:	jmp    2a1c <botlish_fn_37+0x93>
    2a05:	mov    rsi,r12
    2a08:	mov    rdi,rbx
    2a0b:	call   2a10 <botlish_fn_37+0x87>
			2a0c: R_X86_64_PLT32	rt_int_mod-0x4
    2a10:	test   rax,rax
    2a13:	jne    2a3c <botlish_fn_37+0xb3>
    2a19:	mov    rdi,rbx
    2a1c:	mov    rdi,rbx
    2a1f:	mov    QWORD PTR [rdi],r15
    2a22:	xor    rax,rax
    2a25:	mov    rbx,QWORD PTR [rsp]
    2a29:	mov    r12,QWORD PTR [rsp+0x8]
    2a2e:	mov    r15,QWORD PTR [rsp+0x10]
    2a33:	add    rsp,0x20
    2a37:	mov    rsp,rbp
    2a3a:	pop    rbp
    2a3b:	ret
    2a3c:	mov    rdi,rbx
    2a3f:	mov    QWORD PTR [rdi],r15
    2a42:	mov    rbx,QWORD PTR [rsp]
    2a46:	mov    r12,QWORD PTR [rsp+0x8]
    2a4b:	mov    r15,QWORD PTR [rsp+0x10]
    2a50:	add    rsp,0x20
    2a54:	mov    rsp,rbp
    2a57:	pop    rbp
    2a58:	ret
    2a59:	mov    rbx,rdi
    2a5c:	call   2a61 <botlish_fn_37+0xd8>
			2a5d: R_X86_64_PLT32	rt_stack_overflow-0x4
    2a61:	xor    rax,rax
    2a64:	mov    rbx,QWORD PTR [rsp]
    2a68:	mov    r12,QWORD PTR [rsp+0x8]
    2a6d:	mov    r15,QWORD PTR [rsp+0x10]
    2a72:	add    rsp,0x20
    2a76:	mov    rsp,rbp
    2a79:	pop    rbp
    2a7a:	ret

0000000000002a7b <botlish_entry_37: ht_probe_start<any, str>>:
    2a7b:	push   rbp
    2a7c:	mov    rbp,rsp
    2a7f:	mov    rsi,QWORD PTR [rdx]
    2a82:	mov    rdx,QWORD PTR [rdx+0x8]
    2a86:	call   2a8b <botlish_entry_37+0x10>
			2a87: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    2a8b:	mov    rsp,rbp
    2a8e:	pop    rbp
    2a8f:	ret

0000000000002a90 <botlish_fn_38: ht_probe_next<mutarray, int>>:
    2a90:	push   rbp
    2a91:	mov    rbp,rsp
    2a94:	sub    rsp,0x20
    2a98:	mov    QWORD PTR [rsp],rbx
    2a9c:	mov    QWORD PTR [rsp+0x8],r12
    2aa1:	mov    QWORD PTR [rsp+0x10],r13
    2aa6:	mov    rbx,QWORD PTR [rdi]
    2aa9:	mov    rax,QWORD PTR [rdi+0x8]
    2aad:	lea    rcx,[rbx+0x18]
    2ab1:	cmp    rcx,rax
    2ab4:	ja     2b90 <botlish_fn_38+0x100>
    2aba:	lea    rax,[rbx+0x18]
    2abe:	mov    QWORD PTR [rdi],rax
    2ac1:	mov    r12,rdi
    2ac4:	mov    QWORD PTR [rbx],rsi
    2ac7:	mov    r13,rsi
    2aca:	mov    QWORD PTR [rbx+0x8],rdx
    2ace:	mov    QWORD PTR [rbx+0x10],0x3
    2ad6:	test   rdx,0x1
    2add:	jne    2aeb <botlish_fn_38+0x5b>
    2ae3:	mov    rcx,rdx
    2ae6:	jmp    2b00 <botlish_fn_38+0x70>
    2aeb:	mov    rsi,rdx
    2aee:	add    rsi,0x2
    2af2:	mov    rcx,rdx
    2af5:	seto   al
    2af8:	test   al,al
    2afa:	je     2b13 <botlish_fn_38+0x83>
    2b00:	mov    edx,0x3
    2b05:	mov    rsi,rcx
    2b08:	mov    rdi,r12
    2b0b:	call   2b10 <botlish_fn_38+0x80>
			2b0c: R_X86_64_PLT32	rt_int_add-0x4
    2b10:	mov    rsi,rax
    2b13:	mov    QWORD PTR [rbx+0x8],rsi
    2b17:	mov    rax,rsi
    2b1a:	mov    rsi,r13
    2b1d:	mov    r13,rax
    2b20:	mov    rdi,r12
    2b23:	call   2b28 <botlish_fn_38+0x98>
			2b24: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2b28:	test   rax,rax
    2b2b:	mov    rdx,rax
    2b2e:	jne    2b3c <botlish_fn_38+0xac>
    2b34:	mov    rdi,r12
    2b37:	jmp    2b53 <botlish_fn_38+0xc3>
    2b3c:	mov    rsi,r13
    2b3f:	mov    rdi,r12
    2b42:	call   2b47 <botlish_fn_38+0xb7>
			2b43: R_X86_64_PLT32	rt_int_mod-0x4
    2b47:	test   rax,rax
    2b4a:	jne    2b73 <botlish_fn_38+0xe3>
    2b50:	mov    rdi,r12
    2b53:	mov    rdi,r12
    2b56:	mov    QWORD PTR [rdi],rbx
    2b59:	xor    rax,rax
    2b5c:	mov    rbx,QWORD PTR [rsp]
    2b60:	mov    r12,QWORD PTR [rsp+0x8]
    2b65:	mov    r13,QWORD PTR [rsp+0x10]
    2b6a:	add    rsp,0x20
    2b6e:	mov    rsp,rbp
    2b71:	pop    rbp
    2b72:	ret
    2b73:	mov    rdi,r12
    2b76:	mov    QWORD PTR [rdi],rbx
    2b79:	mov    rbx,QWORD PTR [rsp]
    2b7d:	mov    r12,QWORD PTR [rsp+0x8]
    2b82:	mov    r13,QWORD PTR [rsp+0x10]
    2b87:	add    rsp,0x20
    2b8b:	mov    rsp,rbp
    2b8e:	pop    rbp
    2b8f:	ret
    2b90:	mov    r12,rdi
    2b93:	call   2b98 <botlish_fn_38+0x108>
			2b94: R_X86_64_PLT32	rt_stack_overflow-0x4
    2b98:	xor    rax,rax
    2b9b:	mov    rbx,QWORD PTR [rsp]
    2b9f:	mov    r12,QWORD PTR [rsp+0x8]
    2ba4:	mov    r13,QWORD PTR [rsp+0x10]
    2ba9:	add    rsp,0x20
    2bad:	mov    rsp,rbp
    2bb0:	pop    rbp
    2bb1:	ret

0000000000002bb2 <botlish_entry_38: ht_probe_next<mutarray, int>>:
    2bb2:	push   rbp
    2bb3:	mov    rbp,rsp
    2bb6:	mov    rsi,QWORD PTR [rdx]
    2bb9:	mov    rdx,QWORD PTR [rdx+0x8]
    2bbd:	call   2bc2 <botlish_entry_38+0x10>
			2bbe: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    2bc2:	mov    rsp,rbp
    2bc5:	pop    rbp
    2bc6:	ret

0000000000002bc7 <botlish_fn_39: ht_probe_next<any, int>>:
    2bc7:	push   rbp
    2bc8:	mov    rbp,rsp
    2bcb:	sub    rsp,0x20
    2bcf:	mov    QWORD PTR [rsp],rbx
    2bd3:	mov    QWORD PTR [rsp+0x8],r12
    2bd8:	mov    QWORD PTR [rsp+0x10],r13
    2bdd:	mov    rbx,QWORD PTR [rdi]
    2be0:	mov    rax,QWORD PTR [rdi+0x8]
    2be4:	lea    rcx,[rbx+0x18]
    2be8:	cmp    rcx,rax
    2beb:	ja     2cc7 <botlish_fn_39+0x100>
    2bf1:	lea    rax,[rbx+0x18]
    2bf5:	mov    QWORD PTR [rdi],rax
    2bf8:	mov    r12,rdi
    2bfb:	mov    QWORD PTR [rbx],rsi
    2bfe:	mov    r13,rsi
    2c01:	mov    QWORD PTR [rbx+0x8],rdx
    2c05:	mov    QWORD PTR [rbx+0x10],0x3
    2c0d:	test   rdx,0x1
    2c14:	jne    2c22 <botlish_fn_39+0x5b>
    2c1a:	mov    rcx,rdx
    2c1d:	jmp    2c37 <botlish_fn_39+0x70>
    2c22:	mov    rsi,rdx
    2c25:	add    rsi,0x2
    2c29:	mov    rcx,rdx
    2c2c:	seto   al
    2c2f:	test   al,al
    2c31:	je     2c4a <botlish_fn_39+0x83>
    2c37:	mov    edx,0x3
    2c3c:	mov    rsi,rcx
    2c3f:	mov    rdi,r12
    2c42:	call   2c47 <botlish_fn_39+0x80>
			2c43: R_X86_64_PLT32	rt_int_add-0x4
    2c47:	mov    rsi,rax
    2c4a:	mov    QWORD PTR [rbx+0x8],rsi
    2c4e:	mov    rax,rsi
    2c51:	mov    rsi,r13
    2c54:	mov    r13,rax
    2c57:	mov    rdi,r12
    2c5a:	call   2c5f <botlish_fn_39+0x98>
			2c5b: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2c5f:	test   rax,rax
    2c62:	mov    rdx,rax
    2c65:	jne    2c73 <botlish_fn_39+0xac>
    2c6b:	mov    rdi,r12
    2c6e:	jmp    2c8a <botlish_fn_39+0xc3>
    2c73:	mov    rsi,r13
    2c76:	mov    rdi,r12
    2c79:	call   2c7e <botlish_fn_39+0xb7>
			2c7a: R_X86_64_PLT32	rt_int_mod-0x4
    2c7e:	test   rax,rax
    2c81:	jne    2caa <botlish_fn_39+0xe3>
    2c87:	mov    rdi,r12
    2c8a:	mov    rdi,r12
    2c8d:	mov    QWORD PTR [rdi],rbx
    2c90:	xor    rax,rax
    2c93:	mov    rbx,QWORD PTR [rsp]
    2c97:	mov    r12,QWORD PTR [rsp+0x8]
    2c9c:	mov    r13,QWORD PTR [rsp+0x10]
    2ca1:	add    rsp,0x20
    2ca5:	mov    rsp,rbp
    2ca8:	pop    rbp
    2ca9:	ret
    2caa:	mov    rdi,r12
    2cad:	mov    QWORD PTR [rdi],rbx
    2cb0:	mov    rbx,QWORD PTR [rsp]
    2cb4:	mov    r12,QWORD PTR [rsp+0x8]
    2cb9:	mov    r13,QWORD PTR [rsp+0x10]
    2cbe:	add    rsp,0x20
    2cc2:	mov    rsp,rbp
    2cc5:	pop    rbp
    2cc6:	ret
    2cc7:	mov    r12,rdi
    2cca:	call   2ccf <botlish_fn_39+0x108>
			2ccb: R_X86_64_PLT32	rt_stack_overflow-0x4
    2ccf:	xor    rax,rax
    2cd2:	mov    rbx,QWORD PTR [rsp]
    2cd6:	mov    r12,QWORD PTR [rsp+0x8]
    2cdb:	mov    r13,QWORD PTR [rsp+0x10]
    2ce0:	add    rsp,0x20
    2ce4:	mov    rsp,rbp
    2ce7:	pop    rbp
    2ce8:	ret

0000000000002ce9 <botlish_entry_39: ht_probe_next<any, int>>:
    2ce9:	push   rbp
    2cea:	mov    rbp,rsp
    2ced:	mov    rsi,QWORD PTR [rdx]
    2cf0:	mov    rdx,QWORD PTR [rdx+0x8]
    2cf4:	call   2cf9 <botlish_entry_39+0x10>
			2cf5: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    2cf9:	mov    rsp,rbp
    2cfc:	pop    rbp
    2cfd:	ret
	...

0000000000002d00 <botlish_fn_40: ht_find_get<any, str, int>>:
    2d00:	push   rbp
    2d01:	mov    rbp,rsp
    2d04:	sub    rsp,0x40
    2d08:	mov    QWORD PTR [rsp+0x10],rbx
    2d0d:	mov    QWORD PTR [rsp+0x18],r12
    2d12:	mov    QWORD PTR [rsp+0x20],r13
    2d17:	mov    QWORD PTR [rsp+0x28],r14
    2d1c:	mov    QWORD PTR [rsp+0x30],r15
    2d21:	mov    r13,QWORD PTR [rdi]
    2d24:	mov    rax,QWORD PTR [rdi+0x8]
    2d28:	lea    r8,[r13+0x20]
    2d2c:	cmp    r8,rax
    2d2f:	ja     3071 <botlish_fn_40+0x371>
    2d35:	lea    rax,[r13+0x20]
    2d39:	mov    QWORD PTR [rdi],rax
    2d3c:	mov    r14,rdi
    2d3f:	mov    QWORD PTR [r13+0x18],0x0
    2d47:	mov    QWORD PTR [r13+0x0],rsi
    2d4b:	mov    QWORD PTR [r13+0x8],rdx
    2d4f:	mov    QWORD PTR [rsp],rdx
    2d53:	mov    QWORD PTR [r13+0x10],rcx
    2d57:	mov    r15,rsi
    2d5a:	mov    QWORD PTR [rsp+0x8],rcx
    2d5f:	mov    rsi,r15
    2d62:	mov    rdi,r14
    2d65:	call   2d6a <botlish_fn_40+0x6a>
			2d66: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2d6a:	test   rax,rax
    2d6d:	jne    2d7b <botlish_fn_40+0x7b>
    2d73:	mov    rdi,r14
    2d76:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2d7b:	xor    ecx,ecx
    2d7d:	test   rax,0x7
    2d83:	je     2d91 <botlish_fn_40+0x91>
    2d89:	mov    rsi,rax
    2d8c:	jmp    2d9f <botlish_fn_40+0x9f>
    2d91:	movzx  r11,BYTE PTR [rax]
    2d95:	mov    rsi,rax
    2d98:	cmp    r11b,0x8
    2d9c:	sete   cl
    2d9f:	test   cl,cl
    2da1:	jne    2dc4 <botlish_fn_40+0xc4>
    2da7:	mov    rdi,r14
    2daa:	mov    rax,QWORD PTR [rdi+0x10]
    2dae:	mov    rcx,QWORD PTR [rax+0x20]
    2db2:	mov    edx,0x8
    2db7:	call   2dbc <botlish_fn_40+0xbc>
			2db8: R_X86_64_PLT32	rt_type_error-0x4
    2dbc:	mov    rdi,r14
    2dbf:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2dc4:	mov    rdx,QWORD PTR [rsp+0x8]
    2dc9:	mov    rdi,r14
    2dcc:	call   2dd1 <botlish_fn_40+0xd1>
			2dcd: R_X86_64_PLT32	rt_mutarray_get-0x4
    2dd1:	mov    rcx,rax
    2dd4:	mov    r12,rax
    2dd7:	test   rax,rcx
    2dda:	jne    2de8 <botlish_fn_40+0xe8>
    2de0:	mov    rdi,r14
    2de3:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2de8:	mov    rax,r12
    2deb:	mov    QWORD PTR [r13+0x18],rax
    2def:	mov    rdi,r14
    2df2:	call   2df7 <botlish_fn_40+0xf7>
			2df3: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    2df7:	test   rax,rax
    2dfa:	jne    2e08 <botlish_fn_40+0x108>
    2e00:	mov    rdi,r14
    2e03:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2e08:	mov    rsi,r12
    2e0b:	mov    rcx,rsi
    2e0e:	and    rcx,rax
    2e11:	mov    rdx,rax
    2e14:	test   rcx,0x1
    2e1b:	jne    2e3d <botlish_fn_40+0x13d>
    2e21:	mov    rsi,r12
    2e24:	mov    rdi,r14
    2e27:	call   2e2c <botlish_fn_40+0x12c>
			2e28: R_X86_64_PLT32	rt_value_eq-0x4
    2e2c:	test   rax,rax
    2e2f:	jne    2e4d <botlish_fn_40+0x14d>
    2e35:	mov    rdi,r14
    2e38:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2e3d:	mov    eax,0x2
    2e42:	cmp    r12,rdx
    2e45:	cmove  rax,QWORD PTR [rip+0x253]        # 30a0 <botlish_fn_40+0x3a0>
    2e4d:	mov    ebx,0x6
    2e52:	cmp    rax,0x6
    2e56:	je     3042 <botlish_fn_40+0x342>
    2e5c:	mov    rdi,r14
    2e5f:	call   2e64 <botlish_fn_40+0x164>
			2e60: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    2e64:	test   rax,rax
    2e67:	jne    2e75 <botlish_fn_40+0x175>
    2e6d:	mov    rdi,r14
    2e70:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2e75:	mov    rcx,r12
    2e78:	and    rcx,rax
    2e7b:	mov    rdx,rax
    2e7e:	test   rcx,0x1
    2e85:	jne    2ea7 <botlish_fn_40+0x1a7>
    2e8b:	mov    rsi,r12
    2e8e:	mov    rdi,r14
    2e91:	call   2e96 <botlish_fn_40+0x196>
			2e92: R_X86_64_PLT32	rt_value_eq-0x4
    2e96:	test   rax,rax
    2e99:	jne    2eba <botlish_fn_40+0x1ba>
    2e9f:	mov    rdi,r14
    2ea2:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2ea7:	mov    rsi,r12
    2eaa:	mov    eax,0x2
    2eaf:	cmp    rsi,rdx
    2eb2:	cmove  rax,QWORD PTR [rip+0x1e6]        # 30a0 <botlish_fn_40+0x3a0>
    2eba:	cmp    rax,0x6
    2ebe:	je     2ed2 <botlish_fn_40+0x1d2>
    2ec4:	mov    ebx,0x2
    2ec9:	mov    r12,QWORD PTR [rsp]
    2ecd:	jmp    2faa <botlish_fn_40+0x2aa>
    2ed2:	mov    rsi,r15
    2ed5:	mov    rdi,r14
    2ed8:	call   2edd <botlish_fn_40+0x1dd>
			2ed9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2edd:	test   rax,rax
    2ee0:	jne    2eee <botlish_fn_40+0x1ee>
    2ee6:	mov    rdi,r14
    2ee9:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2eee:	xor    ecx,ecx
    2ef0:	test   rax,0x7
    2ef6:	je     2f04 <botlish_fn_40+0x204>
    2efc:	mov    rsi,rax
    2eff:	jmp    2f12 <botlish_fn_40+0x212>
    2f04:	movzx  rcx,BYTE PTR [rax]
    2f08:	mov    rsi,rax
    2f0b:	rex cmp cl,0x8
    2f0f:	sete   cl
    2f12:	test   cl,cl
    2f14:	jne    2f37 <botlish_fn_40+0x237>
    2f1a:	mov    rdi,r14
    2f1d:	mov    rax,QWORD PTR [rdi+0x10]
    2f21:	mov    rcx,QWORD PTR [rax+0x20]
    2f25:	mov    edx,0x8
    2f2a:	call   2f2f <botlish_fn_40+0x22f>
			2f2b: R_X86_64_PLT32	rt_type_error-0x4
    2f2f:	mov    rdi,r14
    2f32:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2f37:	mov    rdx,QWORD PTR [rsp+0x8]
    2f3c:	mov    rdi,r14
    2f3f:	call   2f44 <botlish_fn_40+0x244>
			2f40: R_X86_64_PLT32	rt_mutarray_get-0x4
    2f44:	test   rax,rax
    2f47:	jne    2f55 <botlish_fn_40+0x255>
    2f4d:	mov    rdi,r14
    2f50:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2f55:	mov    r12,QWORD PTR [rsp]
    2f59:	mov    rcx,rax
    2f5c:	and    rcx,r12
    2f5f:	mov    rsi,rax
    2f62:	test   rcx,0x1
    2f69:	jne    2f8b <botlish_fn_40+0x28b>
    2f6f:	mov    rdx,r12
    2f72:	mov    rdi,r14
    2f75:	call   2f7a <botlish_fn_40+0x27a>
			2f76: R_X86_64_PLT32	rt_value_eq-0x4
    2f7a:	test   rax,rax
    2f7d:	jne    2f9b <botlish_fn_40+0x29b>
    2f83:	mov    rdi,r14
    2f86:	jmp    2fd0 <botlish_fn_40+0x2d0>
    2f8b:	mov    eax,0x2
    2f90:	cmp    rsi,r12
    2f93:	cmove  rax,QWORD PTR [rip+0x105]        # 30a0 <botlish_fn_40+0x3a0>
    2f9b:	cmp    rax,0x6
    2f9f:	je     2faa <botlish_fn_40+0x2aa>
    2fa5:	mov    ebx,0x2
    2faa:	cmp    rbx,0x6
    2fae:	je     3015 <botlish_fn_40+0x315>
    2fb4:	mov    rdx,QWORD PTR [rsp+0x8]
    2fb9:	mov    rsi,r15
    2fbc:	mov    rdi,r14
    2fbf:	call   2fc4 <botlish_fn_40+0x2c4>
			2fc0: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    2fc4:	test   rax,rax
    2fc7:	jne    2ffb <botlish_fn_40+0x2fb>
    2fcd:	mov    rdi,r14
    2fd0:	mov    rdi,r14
    2fd3:	mov    QWORD PTR [rdi],r13
    2fd6:	xor    rax,rax
    2fd9:	mov    rbx,QWORD PTR [rsp+0x10]
    2fde:	mov    r12,QWORD PTR [rsp+0x18]
    2fe3:	mov    r13,QWORD PTR [rsp+0x20]
    2fe8:	mov    r14,QWORD PTR [rsp+0x28]
    2fed:	mov    r15,QWORD PTR [rsp+0x30]
    2ff2:	add    rsp,0x40
    2ff6:	mov    rsp,rbp
    2ff9:	pop    rbp
    2ffa:	ret
    2ffb:	mov    QWORD PTR [r13+0x0],r15
    2fff:	mov    QWORD PTR [r13+0x8],r12
    3003:	mov    QWORD PTR [r13+0x10],rax
    3007:	mov    QWORD PTR [rsp],r12
    300b:	mov    QWORD PTR [rsp+0x8],rax
    3010:	jmp    2d5f <botlish_fn_40+0x5f>
    3015:	mov    rdi,r14
    3018:	mov    QWORD PTR [rdi],r13
    301b:	mov    rax,QWORD PTR [rsp+0x8]
    3020:	mov    rbx,QWORD PTR [rsp+0x10]
    3025:	mov    r12,QWORD PTR [rsp+0x18]
    302a:	mov    r13,QWORD PTR [rsp+0x20]
    302f:	mov    r14,QWORD PTR [rsp+0x28]
    3034:	mov    r15,QWORD PTR [rsp+0x30]
    3039:	add    rsp,0x40
    303d:	mov    rsp,rbp
    3040:	pop    rbp
    3041:	ret
    3042:	mov    rdi,r14
    3045:	mov    QWORD PTR [rdi],r13
    3048:	mov    rax,0xffffffffffffffff
    304f:	mov    rbx,QWORD PTR [rsp+0x10]
    3054:	mov    r12,QWORD PTR [rsp+0x18]
    3059:	mov    r13,QWORD PTR [rsp+0x20]
    305e:	mov    r14,QWORD PTR [rsp+0x28]
    3063:	mov    r15,QWORD PTR [rsp+0x30]
    3068:	add    rsp,0x40
    306c:	mov    rsp,rbp
    306f:	pop    rbp
    3070:	ret
    3071:	mov    r14,rdi
    3074:	call   3079 <botlish_fn_40+0x379>
			3075: R_X86_64_PLT32	rt_stack_overflow-0x4
    3079:	xor    rax,rax
    307c:	mov    rbx,QWORD PTR [rsp+0x10]
    3081:	mov    r12,QWORD PTR [rsp+0x18]
    3086:	mov    r13,QWORD PTR [rsp+0x20]
    308b:	mov    r14,QWORD PTR [rsp+0x28]
    3090:	mov    r15,QWORD PTR [rsp+0x30]
    3095:	add    rsp,0x40
    3099:	mov    rsp,rbp
    309c:	pop    rbp
    309d:	ret
    309e:	add    BYTE PTR [rax],al
    30a0:	(bad)
    30a1:	add    BYTE PTR [rax],al
    30a3:	add    BYTE PTR [rax],al
    30a5:	add    BYTE PTR [rax],al
	...

00000000000030a8 <botlish_entry_40: ht_find_get<any, str, int>>:
    30a8:	push   rbp
    30a9:	mov    rbp,rsp
    30ac:	mov    rsi,QWORD PTR [rdx]
    30af:	mov    r8,QWORD PTR [rdx+0x8]
    30b3:	mov    rcx,QWORD PTR [rdx+0x10]
    30b7:	mov    rdx,r8
    30ba:	call   30bf <botlish_entry_40+0x17>
			30bb: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    30bf:	mov    rsp,rbp
    30c2:	pop    rbp
    30c3:	ret
    30c4:	add    BYTE PTR [rax],al
	...

00000000000030c8 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    30c8:	push   rbp
    30c9:	mov    rbp,rsp
    30cc:	sub    rsp,0x50
    30d0:	mov    QWORD PTR [rsp+0x20],rbx
    30d5:	mov    QWORD PTR [rsp+0x28],r12
    30da:	mov    QWORD PTR [rsp+0x30],r13
    30df:	mov    QWORD PTR [rsp+0x38],r14
    30e4:	mov    QWORD PTR [rsp+0x40],r15
    30e9:	mov    r13,QWORD PTR [rdi]
    30ec:	mov    rax,QWORD PTR [rdi+0x8]
    30f0:	lea    r9,[r13+0x28]
    30f4:	cmp    r9,rax
    30f7:	ja     3618 <botlish_fn_41+0x550>
    30fd:	lea    rax,[r13+0x28]
    3101:	mov    QWORD PTR [rdi],rax
    3104:	mov    QWORD PTR [rsp],rdi
    3108:	mov    QWORD PTR [r13+0x20],0x0
    3110:	mov    QWORD PTR [r13+0x0],rsi
    3114:	mov    QWORD PTR [r13+0x8],rdx
    3118:	mov    r14,rdx
    311b:	mov    QWORD PTR [r13+0x10],rcx
    311f:	mov    QWORD PTR [r13+0x18],r8
    3123:	mov    rbx,rsi
    3126:	mov    r15,r8
    3129:	mov    QWORD PTR [rsp+0x8],rcx
    312e:	mov    rsi,rbx
    3131:	mov    rdi,QWORD PTR [rsp]
    3135:	call   313a <botlish_fn_41+0x72>
			3136: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    313a:	test   rax,rax
    313d:	jne    314c <botlish_fn_41+0x84>
    3143:	mov    rdi,QWORD PTR [rsp]
    3147:	jmp    34eb <botlish_fn_41+0x423>
    314c:	xor    ecx,ecx
    314e:	test   rax,0x7
    3154:	je     3162 <botlish_fn_41+0x9a>
    315a:	mov    rsi,rax
    315d:	jmp    3170 <botlish_fn_41+0xa8>
    3162:	movzx  rcx,BYTE PTR [rax]
    3166:	mov    rsi,rax
    3169:	rex cmp cl,0x8
    316d:	sete   cl
    3170:	test   cl,cl
    3172:	jne    3197 <botlish_fn_41+0xcf>
    3178:	mov    rdi,QWORD PTR [rsp]
    317c:	mov    rax,QWORD PTR [rdi+0x10]
    3180:	mov    rcx,QWORD PTR [rax+0x20]
    3184:	mov    edx,0x8
    3189:	call   318e <botlish_fn_41+0xc6>
			318a: R_X86_64_PLT32	rt_type_error-0x4
    318e:	mov    rdi,QWORD PTR [rsp]
    3192:	jmp    34eb <botlish_fn_41+0x423>
    3197:	mov    rdx,QWORD PTR [rsp+0x8]
    319c:	mov    rdi,QWORD PTR [rsp]
    31a0:	call   31a5 <botlish_fn_41+0xdd>
			31a1: R_X86_64_PLT32	rt_mutarray_get-0x4
    31a5:	mov    rcx,rax
    31a8:	mov    QWORD PTR [rsp+0x10],rax
    31ad:	test   rax,rcx
    31b0:	jne    31bf <botlish_fn_41+0xf7>
    31b6:	mov    rdi,QWORD PTR [rsp]
    31ba:	jmp    34eb <botlish_fn_41+0x423>
    31bf:	mov    rax,QWORD PTR [rsp+0x10]
    31c4:	mov    QWORD PTR [r13+0x20],rax
    31c8:	mov    rdi,QWORD PTR [rsp]
    31cc:	call   31d1 <botlish_fn_41+0x109>
			31cd: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    31d1:	test   rax,rax
    31d4:	jne    31e3 <botlish_fn_41+0x11b>
    31da:	mov    rdi,QWORD PTR [rsp]
    31de:	jmp    34eb <botlish_fn_41+0x423>
    31e3:	mov    rcx,QWORD PTR [rsp+0x10]
    31e8:	and    rcx,rax
    31eb:	mov    rdx,rax
    31ee:	test   rcx,0x1
    31f5:	jne    321b <botlish_fn_41+0x153>
    31fb:	mov    rsi,QWORD PTR [rsp+0x10]
    3200:	mov    rdi,QWORD PTR [rsp]
    3204:	call   3209 <botlish_fn_41+0x141>
			3205: R_X86_64_PLT32	rt_value_eq-0x4
    3209:	test   rax,rax
    320c:	jne    3230 <botlish_fn_41+0x168>
    3212:	mov    rdi,QWORD PTR [rsp]
    3216:	jmp    34eb <botlish_fn_41+0x423>
    321b:	mov    eax,0x2
    3220:	mov    rcx,QWORD PTR [rsp+0x10]
    3225:	cmp    rcx,rdx
    3228:	cmove  rax,QWORD PTR [rip+0x418]        # 3648 <botlish_fn_41+0x580>
    3230:	mov    r12d,0x6
    3236:	cmp    rax,0x6
    323a:	je     3569 <botlish_fn_41+0x4a1>
    3240:	mov    rdi,QWORD PTR [rsp]
    3244:	call   3249 <botlish_fn_41+0x181>
			3245: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3249:	test   rax,rax
    324c:	jne    325b <botlish_fn_41+0x193>
    3252:	mov    rdi,QWORD PTR [rsp]
    3256:	jmp    34eb <botlish_fn_41+0x423>
    325b:	mov    rcx,QWORD PTR [rsp+0x10]
    3260:	and    rcx,rax
    3263:	mov    rdx,rax
    3266:	test   rcx,0x1
    326d:	jne    3293 <botlish_fn_41+0x1cb>
    3273:	mov    rsi,QWORD PTR [rsp+0x10]
    3278:	mov    rdi,QWORD PTR [rsp]
    327c:	call   3281 <botlish_fn_41+0x1b9>
			327d: R_X86_64_PLT32	rt_value_eq-0x4
    3281:	test   rax,rax
    3284:	jne    32a8 <botlish_fn_41+0x1e0>
    328a:	mov    rdi,QWORD PTR [rsp]
    328e:	jmp    34eb <botlish_fn_41+0x423>
    3293:	mov    eax,0x2
    3298:	mov    rsi,QWORD PTR [rsp+0x10]
    329d:	cmp    rsi,rdx
    32a0:	cmove  rax,QWORD PTR [rip+0x3a0]        # 3648 <botlish_fn_41+0x580>
    32a8:	cmp    rax,0x6
    32ac:	je     32bc <botlish_fn_41+0x1f4>
    32b2:	mov    eax,0x2
    32b7:	jmp    33a0 <botlish_fn_41+0x2d8>
    32bc:	mov    rsi,rbx
    32bf:	mov    rdi,QWORD PTR [rsp]
    32c3:	call   32c8 <botlish_fn_41+0x200>
			32c4: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    32c8:	test   rax,rax
    32cb:	jne    32da <botlish_fn_41+0x212>
    32d1:	mov    rdi,QWORD PTR [rsp]
    32d5:	jmp    34eb <botlish_fn_41+0x423>
    32da:	xor    ecx,ecx
    32dc:	test   rax,0x7
    32e2:	je     32f0 <botlish_fn_41+0x228>
    32e8:	mov    rsi,rax
    32eb:	jmp    32fe <botlish_fn_41+0x236>
    32f0:	movzx  rcx,BYTE PTR [rax]
    32f4:	mov    rsi,rax
    32f7:	rex cmp cl,0x8
    32fb:	sete   cl
    32fe:	test   cl,cl
    3300:	jne    3325 <botlish_fn_41+0x25d>
    3306:	mov    rdi,QWORD PTR [rsp]
    330a:	mov    rax,QWORD PTR [rdi+0x10]
    330e:	mov    rcx,QWORD PTR [rax+0x20]
    3312:	mov    edx,0x8
    3317:	call   331c <botlish_fn_41+0x254>
			3318: R_X86_64_PLT32	rt_type_error-0x4
    331c:	mov    rdi,QWORD PTR [rsp]
    3320:	jmp    34eb <botlish_fn_41+0x423>
    3325:	mov    rdx,QWORD PTR [rsp+0x8]
    332a:	mov    rdi,QWORD PTR [rsp]
    332e:	call   3333 <botlish_fn_41+0x26b>
			332f: R_X86_64_PLT32	rt_mutarray_get-0x4
    3333:	test   rax,rax
    3336:	jne    3345 <botlish_fn_41+0x27d>
    333c:	mov    rdi,QWORD PTR [rsp]
    3340:	jmp    34eb <botlish_fn_41+0x423>
    3345:	mov    rcx,rax
    3348:	and    rcx,r14
    334b:	mov    rsi,rax
    334e:	test   rcx,0x1
    3355:	jne    3379 <botlish_fn_41+0x2b1>
    335b:	mov    rdx,r14
    335e:	mov    rdi,QWORD PTR [rsp]
    3362:	call   3367 <botlish_fn_41+0x29f>
			3363: R_X86_64_PLT32	rt_value_eq-0x4
    3367:	test   rax,rax
    336a:	jne    3389 <botlish_fn_41+0x2c1>
    3370:	mov    rdi,QWORD PTR [rsp]
    3374:	jmp    34eb <botlish_fn_41+0x423>
    3379:	mov    eax,0x2
    337e:	cmp    rsi,r14
    3381:	cmove  rax,QWORD PTR [rip+0x2bf]        # 3648 <botlish_fn_41+0x580>
    3389:	cmp    rax,0x6
    338d:	je     339d <botlish_fn_41+0x2d5>
    3393:	mov    eax,0x2
    3398:	jmp    33a0 <botlish_fn_41+0x2d8>
    339d:	mov    rax,r12
    33a0:	cmp    rax,0x6
    33a4:	je     353b <botlish_fn_41+0x473>
    33aa:	mov    rdi,QWORD PTR [rsp]
    33ae:	call   33b3 <botlish_fn_41+0x2eb>
			33af: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    33b3:	test   rax,rax
    33b6:	jne    33c5 <botlish_fn_41+0x2fd>
    33bc:	mov    rdi,QWORD PTR [rsp]
    33c0:	jmp    34eb <botlish_fn_41+0x423>
    33c5:	mov    rcx,QWORD PTR [rsp+0x10]
    33ca:	mov    rdx,rcx
    33cd:	and    rdx,rax
    33d0:	mov    r11,rax
    33d3:	test   rdx,0x1
    33da:	jne    3403 <botlish_fn_41+0x33b>
    33e0:	mov    rdx,r11
    33e3:	mov    rsi,QWORD PTR [rsp+0x10]
    33e8:	mov    rdi,QWORD PTR [rsp]
    33ec:	call   33f1 <botlish_fn_41+0x329>
			33ed: R_X86_64_PLT32	rt_value_eq-0x4
    33f1:	test   rax,rax
    33f4:	jne    341b <botlish_fn_41+0x353>
    33fa:	mov    rdi,QWORD PTR [rsp]
    33fe:	jmp    34eb <botlish_fn_41+0x423>
    3403:	mov    rdx,r11
    3406:	mov    rsi,QWORD PTR [rsp+0x10]
    340b:	mov    eax,0x2
    3410:	cmp    rsi,rdx
    3413:	cmove  rax,QWORD PTR [rip+0x22d]        # 3648 <botlish_fn_41+0x580>
    341b:	cmp    rax,0x6
    341f:	je     3430 <botlish_fn_41+0x368>
    3425:	mov    r12d,0x2
    342b:	jmp    3483 <botlish_fn_41+0x3bb>
    3430:	test   r15,0x1
    3437:	jne    3463 <botlish_fn_41+0x39b>
    343d:	mov    edx,0x1
    3442:	mov    rsi,r15
    3445:	mov    rdi,QWORD PTR [rsp]
    3449:	call   344e <botlish_fn_41+0x386>
			344a: R_X86_64_PLT32	rt_int_cmp-0x4
    344e:	mov    ecx,0x2
    3453:	test   rax,rax
    3456:	cmovl  rcx,QWORD PTR [rip+0x1ea]        # 3648 <botlish_fn_41+0x580>
    345e:	jmp    3473 <botlish_fn_41+0x3ab>
    3463:	mov    ecx,0x2
    3468:	test   r15,r15
    346b:	cmovle rcx,QWORD PTR [rip+0x1d5]        # 3648 <botlish_fn_41+0x580>
    3473:	cmp    rcx,0x6
    3477:	je     3483 <botlish_fn_41+0x3bb>
    347d:	mov    r12d,0x2
    3483:	cmp    r12,0x6
    3487:	je     34cd <botlish_fn_41+0x405>
    348d:	mov    rdx,QWORD PTR [rsp+0x8]
    3492:	mov    rsi,rbx
    3495:	mov    rdi,QWORD PTR [rsp]
    3499:	call   349e <botlish_fn_41+0x3d6>
			349a: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    349e:	test   rax,rax
    34a1:	jne    34b0 <botlish_fn_41+0x3e8>
    34a7:	mov    rdi,QWORD PTR [rsp]
    34ab:	jmp    34eb <botlish_fn_41+0x423>
    34b0:	mov    QWORD PTR [r13+0x0],rbx
    34b4:	mov    QWORD PTR [r13+0x8],r14
    34b8:	mov    QWORD PTR [r13+0x10],rax
    34bc:	mov    rcx,r15
    34bf:	mov    QWORD PTR [r13+0x18],rcx
    34c3:	mov    QWORD PTR [rsp+0x8],rax
    34c8:	jmp    312e <botlish_fn_41+0x66>
    34cd:	mov    rdx,QWORD PTR [rsp+0x8]
    34d2:	mov    rsi,rbx
    34d5:	mov    rdi,QWORD PTR [rsp]
    34d9:	call   34de <botlish_fn_41+0x416>
			34da: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    34de:	test   rax,rax
    34e1:	jne    3517 <botlish_fn_41+0x44f>
    34e7:	mov    rdi,QWORD PTR [rsp]
    34eb:	mov    rdi,QWORD PTR [rsp]
    34ef:	mov    QWORD PTR [rdi],r13
    34f2:	xor    rax,rax
    34f5:	mov    rbx,QWORD PTR [rsp+0x20]
    34fa:	mov    r12,QWORD PTR [rsp+0x28]
    34ff:	mov    r13,QWORD PTR [rsp+0x30]
    3504:	mov    r14,QWORD PTR [rsp+0x38]
    3509:	mov    r15,QWORD PTR [rsp+0x40]
    350e:	add    rsp,0x50
    3512:	mov    rsp,rbp
    3515:	pop    rbp
    3516:	ret
    3517:	mov    QWORD PTR [r13+0x0],rbx
    351b:	mov    QWORD PTR [r13+0x8],r14
    351f:	mov    QWORD PTR [r13+0x10],rax
    3523:	mov    rdx,QWORD PTR [rsp+0x8]
    3528:	mov    QWORD PTR [r13+0x18],rdx
    352c:	mov    r15,QWORD PTR [rsp+0x8]
    3531:	mov    QWORD PTR [rsp+0x8],rax
    3536:	jmp    312e <botlish_fn_41+0x66>
    353b:	mov    rdi,QWORD PTR [rsp]
    353f:	mov    QWORD PTR [rdi],r13
    3542:	mov    rax,QWORD PTR [rsp+0x8]
    3547:	mov    rbx,QWORD PTR [rsp+0x20]
    354c:	mov    r12,QWORD PTR [rsp+0x28]
    3551:	mov    r13,QWORD PTR [rsp+0x30]
    3556:	mov    r14,QWORD PTR [rsp+0x38]
    355b:	mov    r15,QWORD PTR [rsp+0x40]
    3560:	add    rsp,0x50
    3564:	mov    rsp,rbp
    3567:	pop    rbp
    3568:	ret
    3569:	mov    rax,r15
    356c:	test   rax,0x1
    3572:	jne    359e <botlish_fn_41+0x4d6>
    3578:	mov    edx,0x1
    357d:	mov    rsi,r15
    3580:	mov    rdi,QWORD PTR [rsp]
    3584:	call   3589 <botlish_fn_41+0x4c1>
			3585: R_X86_64_PLT32	rt_int_cmp-0x4
    3589:	mov    ecx,0x2
    358e:	test   rax,rax
    3591:	cmovge rcx,QWORD PTR [rip+0xaf]        # 3648 <botlish_fn_41+0x580>
    3599:	jmp    35b4 <botlish_fn_41+0x4ec>
    359e:	mov    ecx,0x2
    35a3:	mov    rax,r15
    35a6:	mov    r10,r15
    35a9:	test   rax,r10
    35ac:	cmovg  rcx,QWORD PTR [rip+0x94]        # 3648 <botlish_fn_41+0x580>
    35b4:	cmp    rcx,0x6
    35b8:	je     35ec <botlish_fn_41+0x524>
    35be:	mov    rdi,QWORD PTR [rsp]
    35c2:	mov    QWORD PTR [rdi],r13
    35c5:	mov    rax,QWORD PTR [rsp+0x8]
    35ca:	mov    rbx,QWORD PTR [rsp+0x20]
    35cf:	mov    r12,QWORD PTR [rsp+0x28]
    35d4:	mov    r13,QWORD PTR [rsp+0x30]
    35d9:	mov    r14,QWORD PTR [rsp+0x38]
    35de:	mov    r15,QWORD PTR [rsp+0x40]
    35e3:	add    rsp,0x50
    35e7:	mov    rsp,rbp
    35ea:	pop    rbp
    35eb:	ret
    35ec:	mov    rdi,QWORD PTR [rsp]
    35f0:	mov    QWORD PTR [rdi],r13
    35f3:	mov    rax,r15
    35f6:	mov    rbx,QWORD PTR [rsp+0x20]
    35fb:	mov    r12,QWORD PTR [rsp+0x28]
    3600:	mov    r13,QWORD PTR [rsp+0x30]
    3605:	mov    r14,QWORD PTR [rsp+0x38]
    360a:	mov    r15,QWORD PTR [rsp+0x40]
    360f:	add    rsp,0x50
    3613:	mov    rsp,rbp
    3616:	pop    rbp
    3617:	ret
    3618:	mov    QWORD PTR [rsp],rdi
    361c:	call   3621 <botlish_fn_41+0x559>
			361d: R_X86_64_PLT32	rt_stack_overflow-0x4
    3621:	xor    rax,rax
    3624:	mov    rbx,QWORD PTR [rsp+0x20]
    3629:	mov    r12,QWORD PTR [rsp+0x28]
    362e:	mov    r13,QWORD PTR [rsp+0x30]
    3633:	mov    r14,QWORD PTR [rsp+0x38]
    3638:	mov    r15,QWORD PTR [rsp+0x40]
    363d:	add    rsp,0x50
    3641:	mov    rsp,rbp
    3644:	pop    rbp
    3645:	ret
    3646:	add    BYTE PTR [rax],al
    3648:	(bad)
    3649:	add    BYTE PTR [rax],al
    364b:	add    BYTE PTR [rax],al
    364d:	add    BYTE PTR [rax],al
	...

0000000000003650 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    3650:	push   rbp
    3651:	mov    rbp,rsp
    3654:	mov    rsi,QWORD PTR [rdx]
    3657:	mov    r9,QWORD PTR [rdx+0x8]
    365b:	mov    rcx,QWORD PTR [rdx+0x10]
    365f:	mov    r8,QWORD PTR [rdx+0x18]
    3663:	mov    rdx,r9
    3666:	call   366b <botlish_entry_41+0x1b>
			3667: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    366b:	mov    rsp,rbp
    366e:	pop    rbp
    366f:	ret

0000000000003670 <botlish_fn_42: ht_get<any, str>>:
    3670:	push   rbp
    3671:	mov    rbp,rsp
    3674:	sub    rsp,0x20
    3678:	mov    QWORD PTR [rsp],rbx
    367c:	mov    QWORD PTR [rsp+0x8],r12
    3681:	mov    QWORD PTR [rsp+0x10],r13
    3686:	mov    QWORD PTR [rsp+0x18],r14
    368b:	mov    rbx,QWORD PTR [rdi]
    368e:	mov    rax,QWORD PTR [rdi+0x8]
    3692:	lea    rcx,[rbx+0x18]
    3696:	cmp    rcx,rax
    3699:	ja     3843 <botlish_fn_42+0x1d3>
    369f:	lea    rax,[rbx+0x18]
    36a3:	mov    QWORD PTR [rdi],rax
    36a6:	mov    r12,rdi
    36a9:	mov    QWORD PTR [rbx+0x10],0x0
    36b1:	mov    QWORD PTR [rbx],rsi
    36b4:	mov    r13,rsi
    36b7:	mov    QWORD PTR [rbx+0x8],rdx
    36bb:	mov    r14,rdx
    36be:	mov    rdx,r14
    36c1:	mov    rsi,r13
    36c4:	mov    rdi,r12
    36c7:	call   36cc <botlish_fn_42+0x5c>
			36c8: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    36cc:	test   rax,rax
    36cf:	jne    36dd <botlish_fn_42+0x6d>
    36d5:	mov    rdi,r12
    36d8:	jmp    37d5 <botlish_fn_42+0x165>
    36dd:	mov    QWORD PTR [rbx+0x10],rax
    36e1:	mov    rcx,rax
    36e4:	mov    rdx,r14
    36e7:	mov    rsi,r13
    36ea:	mov    rdi,r12
    36ed:	call   36f2 <botlish_fn_42+0x82>
			36ee: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    36f2:	mov    r10,rax
    36f5:	mov    r14,rax
    36f8:	test   rax,r10
    36fb:	jne    3709 <botlish_fn_42+0x99>
    3701:	mov    rdi,r12
    3704:	jmp    37d5 <botlish_fn_42+0x165>
    3709:	mov    rax,r14
    370c:	mov    QWORD PTR [rbx+0x8],rax
    3710:	test   rax,0x1
    3716:	jne    3741 <botlish_fn_42+0xd1>
    371c:	mov    edx,0x1
    3721:	mov    rsi,r14
    3724:	mov    rdi,r12
    3727:	call   372c <botlish_fn_42+0xbc>
			3728: R_X86_64_PLT32	rt_int_cmp-0x4
    372c:	mov    ecx,0x2
    3731:	test   rax,rax
    3734:	cmovl  rcx,QWORD PTR [rip+0x134]        # 3870 <botlish_fn_42+0x200>
    373c:	jmp    3754 <botlish_fn_42+0xe4>
    3741:	mov    ecx,0x2
    3746:	mov    rax,r14
    3749:	test   rax,rax
    374c:	cmovle rcx,QWORD PTR [rip+0x11c]        # 3870 <botlish_fn_42+0x200>
    3754:	cmp    rcx,0x6
    3758:	je     381c <botlish_fn_42+0x1ac>
    375e:	mov    rsi,r13
    3761:	mov    rdi,r12
    3764:	call   3769 <botlish_fn_42+0xf9>
			3765: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    3769:	test   rax,rax
    376c:	jne    377a <botlish_fn_42+0x10a>
    3772:	mov    rdi,r12
    3775:	jmp    37d5 <botlish_fn_42+0x165>
    377a:	xor    ecx,ecx
    377c:	test   rax,0x7
    3782:	jne    3793 <botlish_fn_42+0x123>
    3788:	movzx  rcx,BYTE PTR [rax]
    378c:	rex cmp cl,0x8
    3790:	sete   cl
    3793:	test   cl,cl
    3795:	jne    37bb <botlish_fn_42+0x14b>
    379b:	mov    rdi,r12
    379e:	mov    rsi,QWORD PTR [rdi+0x10]
    37a2:	mov    rcx,QWORD PTR [rsi+0x20]
    37a6:	mov    edx,0x8
    37ab:	mov    rsi,rax
    37ae:	call   37b3 <botlish_fn_42+0x143>
			37af: R_X86_64_PLT32	rt_type_error-0x4
    37b3:	mov    rdi,r12
    37b6:	jmp    37d5 <botlish_fn_42+0x165>
    37bb:	mov    rdx,r14
    37be:	mov    rsi,rax
    37c1:	mov    rdi,r12
    37c4:	call   37c9 <botlish_fn_42+0x159>
			37c5: R_X86_64_PLT32	rt_mutarray_get-0x4
    37c9:	test   rax,rax
    37cc:	jne    37fa <botlish_fn_42+0x18a>
    37d2:	mov    rdi,r12
    37d5:	mov    rdi,r12
    37d8:	mov    QWORD PTR [rdi],rbx
    37db:	xor    rax,rax
    37de:	mov    rbx,QWORD PTR [rsp]
    37e2:	mov    r12,QWORD PTR [rsp+0x8]
    37e7:	mov    r13,QWORD PTR [rsp+0x10]
    37ec:	mov    r14,QWORD PTR [rsp+0x18]
    37f1:	add    rsp,0x20
    37f5:	mov    rsp,rbp
    37f8:	pop    rbp
    37f9:	ret
    37fa:	mov    rdi,r12
    37fd:	mov    QWORD PTR [rdi],rbx
    3800:	mov    rbx,QWORD PTR [rsp]
    3804:	mov    r12,QWORD PTR [rsp+0x8]
    3809:	mov    r13,QWORD PTR [rsp+0x10]
    380e:	mov    r14,QWORD PTR [rsp+0x18]
    3813:	add    rsp,0x20
    3817:	mov    rsp,rbp
    381a:	pop    rbp
    381b:	ret
    381c:	mov    rdi,r12
    381f:	mov    QWORD PTR [rdi],rbx
    3822:	mov    eax,0xa
    3827:	mov    rbx,QWORD PTR [rsp]
    382b:	mov    r12,QWORD PTR [rsp+0x8]
    3830:	mov    r13,QWORD PTR [rsp+0x10]
    3835:	mov    r14,QWORD PTR [rsp+0x18]
    383a:	add    rsp,0x20
    383e:	mov    rsp,rbp
    3841:	pop    rbp
    3842:	ret
    3843:	mov    r12,rdi
    3846:	call   384b <botlish_fn_42+0x1db>
			3847: R_X86_64_PLT32	rt_stack_overflow-0x4
    384b:	xor    rax,rax
    384e:	mov    rbx,QWORD PTR [rsp]
    3852:	mov    r12,QWORD PTR [rsp+0x8]
    3857:	mov    r13,QWORD PTR [rsp+0x10]
    385c:	mov    r14,QWORD PTR [rsp+0x18]
    3861:	add    rsp,0x20
    3865:	mov    rsp,rbp
    3868:	pop    rbp
    3869:	ret
    386a:	add    BYTE PTR [rax],al
    386c:	add    BYTE PTR [rax],al
    386e:	add    BYTE PTR [rax],al
    3870:	(bad)
    3871:	add    BYTE PTR [rax],al
    3873:	add    BYTE PTR [rax],al
    3875:	add    BYTE PTR [rax],al
	...

0000000000003878 <botlish_entry_42: ht_get<any, str>>:
    3878:	push   rbp
    3879:	mov    rbp,rsp
    387c:	mov    rsi,QWORD PTR [rdx]
    387f:	mov    rdx,QWORD PTR [rdx+0x8]
    3883:	call   3888 <botlish_entry_42+0x10>
			3884: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    3888:	mov    rsp,rbp
    388b:	pop    rbp
    388c:	ret
    388d:	add    BYTE PTR [rax],al
	...

0000000000003890 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    3890:	push   rbp
    3891:	mov    rbp,rsp
    3894:	sub    rsp,0x40
    3898:	mov    QWORD PTR [rsp+0x10],rbx
    389d:	mov    QWORD PTR [rsp+0x18],r12
    38a2:	mov    QWORD PTR [rsp+0x20],r13
    38a7:	mov    QWORD PTR [rsp+0x28],r14
    38ac:	mov    QWORD PTR [rsp+0x30],r15
    38b1:	mov    r12,QWORD PTR [rdi]
    38b4:	mov    rax,QWORD PTR [rdi+0x8]
    38b8:	lea    r8,[r12+0x20]
    38bd:	cmp    r8,rax
    38c0:	ja     3a3f <botlish_fn_43+0x1af>
    38c6:	lea    rax,[r12+0x20]
    38cb:	mov    QWORD PTR [rdi],rax
    38ce:	mov    r13,rdi
    38d1:	mov    QWORD PTR [r12],rsi
    38d5:	mov    QWORD PTR [r12+0x8],rdx
    38da:	mov    QWORD PTR [r12+0x10],rcx
    38df:	mov    r15,rcx
    38e2:	mov    rbx,rsi
    38e5:	mov    r14,rdx
    38e8:	mov    rdx,r14
    38eb:	mov    rsi,rbx
    38ee:	mov    rdi,r13
    38f1:	call   38f6 <botlish_fn_43+0x66>
			38f2: R_X86_64_PLT32	rt_mutarray_get-0x4
    38f6:	test   rax,rax
    38f9:	jne    3907 <botlish_fn_43+0x77>
    38ff:	mov    rdi,r13
    3902:	jmp    39d3 <botlish_fn_43+0x143>
    3907:	mov    QWORD PTR [r12+0x18],rax
    390c:	mov    QWORD PTR [rsp],rax
    3910:	mov    rdi,r13
    3913:	call   3918 <botlish_fn_43+0x88>
			3914: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    3918:	test   rax,rax
    391b:	jne    3929 <botlish_fn_43+0x99>
    3921:	mov    rdi,r13
    3924:	jmp    39d3 <botlish_fn_43+0x143>
    3929:	mov    rsi,QWORD PTR [rsp]
    392d:	mov    rcx,rsi
    3930:	and    rcx,rax
    3933:	mov    rdx,rax
    3936:	test   rcx,0x1
    393d:	jne    3960 <botlish_fn_43+0xd0>
    3943:	mov    rsi,QWORD PTR [rsp]
    3947:	mov    rdi,r13
    394a:	call   394f <botlish_fn_43+0xbf>
			394b: R_X86_64_PLT32	rt_value_eq-0x4
    394f:	test   rax,rax
    3952:	jne    3974 <botlish_fn_43+0xe4>
    3958:	mov    rdi,r13
    395b:	jmp    39d3 <botlish_fn_43+0x143>
    3960:	mov    rsi,QWORD PTR [rsp]
    3964:	mov    eax,0x2
    3969:	cmp    rsi,rdx
    396c:	cmove  rax,QWORD PTR [rip+0xfc]        # 3a70 <botlish_fn_43+0x1e0>
    3974:	cmp    rax,0x6
    3978:	je     3a14 <botlish_fn_43+0x184>
    397e:	mov    QWORD PTR [r12+0x18],0x3
    3987:	mov    rsi,r14
    398a:	test   rsi,0x1
    3991:	je     39a9 <botlish_fn_43+0x119>
    3997:	mov    rsi,r14
    399a:	add    rsi,0x2
    399e:	seto   al
    39a1:	test   al,al
    39a3:	je     39bc <botlish_fn_43+0x12c>
    39a9:	mov    edx,0x3
    39ae:	mov    rsi,r14
    39b1:	mov    rdi,r13
    39b4:	call   39b9 <botlish_fn_43+0x129>
			39b5: R_X86_64_PLT32	rt_int_add-0x4
    39b9:	mov    rsi,rax
    39bc:	mov    rdx,r15
    39bf:	mov    rdi,r13
    39c2:	call   39c7 <botlish_fn_43+0x137>
			39c3: R_X86_64_PLT32	rt_int_mod-0x4
    39c7:	test   rax,rax
    39ca:	jne    39fe <botlish_fn_43+0x16e>
    39d0:	mov    rdi,r13
    39d3:	mov    rdi,r13
    39d6:	mov    QWORD PTR [rdi],r12
    39d9:	xor    rax,rax
    39dc:	mov    rbx,QWORD PTR [rsp+0x10]
    39e1:	mov    r12,QWORD PTR [rsp+0x18]
    39e6:	mov    r13,QWORD PTR [rsp+0x20]
    39eb:	mov    r14,QWORD PTR [rsp+0x28]
    39f0:	mov    r15,QWORD PTR [rsp+0x30]
    39f5:	add    rsp,0x40
    39f9:	mov    rsp,rbp
    39fc:	pop    rbp
    39fd:	ret
    39fe:	mov    QWORD PTR [r12],rbx
    3a02:	mov    QWORD PTR [r12+0x8],rax
    3a07:	mov    QWORD PTR [r12+0x10],r15
    3a0c:	mov    r14,rax
    3a0f:	jmp    38e8 <botlish_fn_43+0x58>
    3a14:	mov    rdi,r13
    3a17:	mov    QWORD PTR [rdi],r12
    3a1a:	mov    rax,r14
    3a1d:	mov    rbx,QWORD PTR [rsp+0x10]
    3a22:	mov    r12,QWORD PTR [rsp+0x18]
    3a27:	mov    r13,QWORD PTR [rsp+0x20]
    3a2c:	mov    r14,QWORD PTR [rsp+0x28]
    3a31:	mov    r15,QWORD PTR [rsp+0x30]
    3a36:	add    rsp,0x40
    3a3a:	mov    rsp,rbp
    3a3d:	pop    rbp
    3a3e:	ret
    3a3f:	mov    r13,rdi
    3a42:	call   3a47 <botlish_fn_43+0x1b7>
			3a43: R_X86_64_PLT32	rt_stack_overflow-0x4
    3a47:	xor    rax,rax
    3a4a:	mov    rbx,QWORD PTR [rsp+0x10]
    3a4f:	mov    r12,QWORD PTR [rsp+0x18]
    3a54:	mov    r13,QWORD PTR [rsp+0x20]
    3a59:	mov    r14,QWORD PTR [rsp+0x28]
    3a5e:	mov    r15,QWORD PTR [rsp+0x30]
    3a63:	add    rsp,0x40
    3a67:	mov    rsp,rbp
    3a6a:	pop    rbp
    3a6b:	ret
    3a6c:	add    BYTE PTR [rax],al
    3a6e:	add    BYTE PTR [rax],al
    3a70:	(bad)
    3a71:	add    BYTE PTR [rax],al
    3a73:	add    BYTE PTR [rax],al
    3a75:	add    BYTE PTR [rax],al
	...

0000000000003a78 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    3a78:	push   rbp
    3a79:	mov    rbp,rsp
    3a7c:	mov    rsi,QWORD PTR [rdx]
    3a7f:	mov    r8,QWORD PTR [rdx+0x8]
    3a83:	mov    rcx,QWORD PTR [rdx+0x10]
    3a87:	mov    rdx,r8
    3a8a:	call   3a8f <botlish_entry_43+0x17>
			3a8b: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    3a8f:	mov    rsp,rbp
    3a92:	pop    rbp
    3a93:	ret

0000000000003a94 <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    3a94:	push   rbp
    3a95:	mov    rbp,rsp
    3a98:	sub    rsp,0x50
    3a9c:	mov    QWORD PTR [rsp+0x20],rbx
    3aa1:	mov    QWORD PTR [rsp+0x28],r12
    3aa6:	mov    QWORD PTR [rsp+0x30],r13
    3aab:	mov    QWORD PTR [rsp+0x38],r14
    3ab0:	mov    QWORD PTR [rsp+0x40],r15
    3ab5:	mov    r10,QWORD PTR [rbp+0x10]
    3ab9:	mov    rbx,QWORD PTR [rdi]
    3abc:	mov    rax,QWORD PTR [rdi+0x8]
    3ac0:	lea    r11,[rbx+0x38]
    3ac4:	cmp    r11,rax
    3ac7:	ja     3c4f <botlish_fn_44+0x1bb>
    3acd:	lea    rax,[rbx+0x38]
    3ad1:	mov    QWORD PTR [rdi],rax
    3ad4:	mov    r12,rdi
    3ad7:	mov    QWORD PTR [rbx],rsi
    3ada:	mov    QWORD PTR [rsp],rsi
    3ade:	mov    QWORD PTR [rbx+0x8],rdx
    3ae2:	mov    QWORD PTR [rsp+0x8],rdx
    3ae7:	mov    QWORD PTR [rbx+0x10],rcx
    3aeb:	mov    r13,rcx
    3aee:	mov    QWORD PTR [rbx+0x18],r8
    3af2:	mov    QWORD PTR [rsp+0x10],r8
    3af7:	mov    QWORD PTR [rbx+0x20],r9
    3afb:	mov    r15,r9
    3afe:	mov    QWORD PTR [rbx+0x28],r10
    3b02:	mov    r14,r10
    3b05:	mov    rsi,r15
    3b08:	mov    rdi,r12
    3b0b:	call   3b10 <botlish_fn_44+0x7c>
			3b0c: R_X86_64_PLT32	rt_hash-0x4
    3b10:	test   rax,rax
    3b13:	mov    rsi,rax
    3b16:	jne    3b24 <botlish_fn_44+0x90>
    3b1c:	mov    rdi,r12
    3b1f:	jmp    3bf7 <botlish_fn_44+0x163>
    3b24:	mov    rdx,QWORD PTR [rsp+0x10]
    3b29:	mov    rdi,r12
    3b2c:	call   3b31 <botlish_fn_44+0x9d>
			3b2d: R_X86_64_PLT32	rt_int_mod-0x4
    3b31:	test   rax,rax
    3b34:	jne    3b42 <botlish_fn_44+0xae>
    3b3a:	mov    rdi,r12
    3b3d:	jmp    3bf7 <botlish_fn_44+0x163>
    3b42:	mov    QWORD PTR [rbx+0x30],rax
    3b46:	mov    rcx,QWORD PTR [rsp+0x10]
    3b4b:	mov    rdx,rax
    3b4e:	mov    rsi,QWORD PTR [rsp]
    3b52:	mov    rdi,r12
    3b55:	call   3b5a <botlish_fn_44+0xc6>
			3b56: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    3b5a:	test   rax,rax
    3b5d:	jne    3b6b <botlish_fn_44+0xd7>
    3b63:	mov    rdi,r12
    3b66:	jmp    3bf7 <botlish_fn_44+0x163>
    3b6b:	mov    QWORD PTR [rbx+0x18],rax
    3b6f:	mov    QWORD PTR [rsp+0x10],rax
    3b74:	mov    rdi,r12
    3b77:	call   3b7c <botlish_fn_44+0xe8>
			3b78: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3b7c:	test   rax,rax
    3b7f:	mov    rcx,rax
    3b82:	jne    3b90 <botlish_fn_44+0xfc>
    3b88:	mov    rdi,r12
    3b8b:	jmp    3bf7 <botlish_fn_44+0x163>
    3b90:	mov    rsi,QWORD PTR [rsp]
    3b94:	mov    rdx,QWORD PTR [rsp+0x10]
    3b99:	mov    rdi,r12
    3b9c:	call   3ba1 <botlish_fn_44+0x10d>
			3b9d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ba1:	test   rax,rax
    3ba4:	jne    3bb2 <botlish_fn_44+0x11e>
    3baa:	mov    rdi,r12
    3bad:	jmp    3bf7 <botlish_fn_44+0x163>
    3bb2:	mov    rcx,r15
    3bb5:	mov    rsi,QWORD PTR [rsp+0x8]
    3bba:	mov    rdx,QWORD PTR [rsp+0x10]
    3bbf:	mov    rdi,r12
    3bc2:	call   3bc7 <botlish_fn_44+0x133>
			3bc3: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bc7:	test   rax,rax
    3bca:	jne    3bd8 <botlish_fn_44+0x144>
    3bd0:	mov    rdi,r12
    3bd3:	jmp    3bf7 <botlish_fn_44+0x163>
    3bd8:	mov    rcx,r14
    3bdb:	mov    rdx,QWORD PTR [rsp+0x10]
    3be0:	mov    rsi,r13
    3be3:	mov    rdi,r12
    3be6:	call   3beb <botlish_fn_44+0x157>
			3be7: R_X86_64_PLT32	rt_mutarray_set-0x4
    3beb:	test   rax,rax
    3bee:	jne    3c22 <botlish_fn_44+0x18e>
    3bf4:	mov    rdi,r12
    3bf7:	mov    rdi,r12
    3bfa:	mov    QWORD PTR [rdi],rbx
    3bfd:	xor    rax,rax
    3c00:	mov    rbx,QWORD PTR [rsp+0x20]
    3c05:	mov    r12,QWORD PTR [rsp+0x28]
    3c0a:	mov    r13,QWORD PTR [rsp+0x30]
    3c0f:	mov    r14,QWORD PTR [rsp+0x38]
    3c14:	mov    r15,QWORD PTR [rsp+0x40]
    3c19:	add    rsp,0x50
    3c1d:	mov    rsp,rbp
    3c20:	pop    rbp
    3c21:	ret
    3c22:	mov    rdi,r12
    3c25:	mov    QWORD PTR [rdi],rbx
    3c28:	mov    eax,0xa
    3c2d:	mov    rbx,QWORD PTR [rsp+0x20]
    3c32:	mov    r12,QWORD PTR [rsp+0x28]
    3c37:	mov    r13,QWORD PTR [rsp+0x30]
    3c3c:	mov    r14,QWORD PTR [rsp+0x38]
    3c41:	mov    r15,QWORD PTR [rsp+0x40]
    3c46:	add    rsp,0x50
    3c4a:	mov    rsp,rbp
    3c4d:	pop    rbp
    3c4e:	ret
    3c4f:	mov    r12,rdi
    3c52:	call   3c57 <botlish_fn_44+0x1c3>
			3c53: R_X86_64_PLT32	rt_stack_overflow-0x4
    3c57:	xor    rax,rax
    3c5a:	mov    rbx,QWORD PTR [rsp+0x20]
    3c5f:	mov    r12,QWORD PTR [rsp+0x28]
    3c64:	mov    r13,QWORD PTR [rsp+0x30]
    3c69:	mov    r14,QWORD PTR [rsp+0x38]
    3c6e:	mov    r15,QWORD PTR [rsp+0x40]
    3c73:	add    rsp,0x50
    3c77:	mov    rsp,rbp
    3c7a:	pop    rbp
    3c7b:	ret

0000000000003c7c <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    3c7c:	push   rbp
    3c7d:	mov    rbp,rsp
    3c80:	sub    rsp,0x10
    3c84:	mov    rsi,QWORD PTR [rdx]
    3c87:	mov    r10,QWORD PTR [rdx+0x8]
    3c8b:	mov    rcx,QWORD PTR [rdx+0x10]
    3c8f:	mov    r8,QWORD PTR [rdx+0x18]
    3c93:	mov    r9,QWORD PTR [rdx+0x20]
    3c97:	mov    r11,QWORD PTR [rdx+0x28]
    3c9b:	mov    QWORD PTR [rsp],r11
    3c9f:	mov    rdx,r10
    3ca2:	call   3ca7 <botlish_entry_44+0x2b>
			3ca3: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    3ca7:	add    rsp,0x10
    3cab:	mov    rsp,rbp
    3cae:	pop    rbp
    3caf:	ret

0000000000003cb0 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    3cb0:	push   rbp
    3cb1:	mov    rbp,rsp
    3cb4:	sub    rsp,0x80
    3cbb:	mov    QWORD PTR [rsp+0x50],rbx
    3cc0:	mov    QWORD PTR [rsp+0x58],r12
    3cc5:	mov    QWORD PTR [rsp+0x60],r13
    3cca:	mov    QWORD PTR [rsp+0x68],r14
    3ccf:	mov    QWORD PTR [rsp+0x70],r15
    3cd4:	mov    r13,QWORD PTR [rbp+0x10]
    3cd8:	mov    r14,QWORD PTR [rbp+0x18]
    3cdc:	mov    r15,QWORD PTR [rbp+0x20]
    3ce0:	mov    r12,QWORD PTR [rbp+0x28]
    3ce4:	mov    QWORD PTR [rsp+0x38],r12
    3ce9:	mov    r12,QWORD PTR [rdi]
    3cec:	mov    r11,QWORD PTR [rdi+0x8]
    3cf0:	lea    rax,[r12+0x58]
    3cf5:	cmp    rax,r11
    3cf8:	ja     4116 <botlish_fn_45+0x466>
    3cfe:	lea    rax,[r12+0x58]
    3d03:	mov    QWORD PTR [rdi],rax
    3d06:	mov    QWORD PTR [rsp+0x10],rdi
    3d0b:	mov    QWORD PTR [r12+0x50],0x0
    3d14:	mov    QWORD PTR [r12],rsi
    3d18:	mov    QWORD PTR [rsp+0x18],rsi
    3d1d:	mov    QWORD PTR [r12+0x8],rdx
    3d22:	mov    QWORD PTR [rsp+0x20],rdx
    3d27:	mov    QWORD PTR [r12+0x10],rcx
    3d2c:	mov    QWORD PTR [rsp+0x28],rcx
    3d31:	mov    QWORD PTR [r12+0x18],r8
    3d36:	mov    QWORD PTR [r12+0x20],r9
    3d3b:	mov    QWORD PTR [rsp+0x30],r9
    3d40:	mov    QWORD PTR [r12+0x28],r13
    3d45:	mov    QWORD PTR [r12+0x30],r14
    3d4a:	mov    QWORD PTR [r12+0x38],r15
    3d4f:	mov    rax,QWORD PTR [rsp+0x38]
    3d54:	mov    QWORD PTR [r12+0x40],rax
    3d59:	mov    rbx,QWORD PTR [rsp+0x30]
    3d5e:	mov    rsi,r8
    3d61:	mov    rax,rsi
    3d64:	and    rax,rbx
    3d67:	mov    QWORD PTR [rsp+0x40],rsi
    3d6c:	test   rax,0x1
    3d72:	jne    3da4 <botlish_fn_45+0xf4>
    3d78:	mov    rdx,rbx
    3d7b:	mov    rsi,QWORD PTR [rsp+0x40]
    3d80:	mov    rdi,QWORD PTR [rsp+0x10]
    3d85:	call   3d8a <botlish_fn_45+0xda>
			3d86: R_X86_64_PLT32	rt_int_cmp-0x4
    3d8a:	mov    QWORD PTR [rsp+0x30],rbx
    3d8f:	mov    ecx,0x2
    3d94:	test   rax,rax
    3d97:	cmovge rcx,QWORD PTR [rip+0x3a9]        # 4148 <botlish_fn_45+0x498>
    3d9f:	jmp    3dc3 <botlish_fn_45+0x113>
    3da4:	mov    QWORD PTR [rsp+0x30],rbx
    3da9:	mov    ecx,0x2
    3dae:	mov    rsi,QWORD PTR [rsp+0x40]
    3db3:	mov    r9,QWORD PTR [rsp+0x30]
    3db8:	cmp    rsi,r9
    3dbb:	cmovge rcx,QWORD PTR [rip+0x385]        # 4148 <botlish_fn_45+0x498>
    3dc3:	cmp    rcx,0x6
    3dc7:	je     40e4 <botlish_fn_45+0x434>
    3dcd:	xor    eax,eax
    3dcf:	mov    rsi,QWORD PTR [rsp+0x18]
    3dd4:	test   rsi,0x7
    3ddb:	jne    3dea <botlish_fn_45+0x13a>
    3de1:	movzx  rax,BYTE PTR [rsi]
    3de5:	cmp    al,0x8
    3de7:	sete   al
    3dea:	test   al,al
    3dec:	jne    3e13 <botlish_fn_45+0x163>
    3df2:	mov    rdi,QWORD PTR [rsp+0x10]
    3df7:	mov    rax,QWORD PTR [rdi+0x10]
    3dfb:	mov    rcx,QWORD PTR [rax+0x20]
    3dff:	mov    edx,0x8
    3e04:	call   3e09 <botlish_fn_45+0x159>
			3e05: R_X86_64_PLT32	rt_type_error-0x4
    3e09:	mov    rdi,QWORD PTR [rsp+0x10]
    3e0e:	jmp    4001 <botlish_fn_45+0x351>
    3e13:	mov    QWORD PTR [rsp+0x18],rsi
    3e18:	mov    rdx,QWORD PTR [rsp+0x40]
    3e1d:	mov    rdi,QWORD PTR [rsp+0x10]
    3e22:	call   3e27 <botlish_fn_45+0x177>
			3e23: R_X86_64_PLT32	rt_mutarray_get-0x4
    3e27:	test   rax,rax
    3e2a:	jne    3e3a <botlish_fn_45+0x18a>
    3e30:	mov    rdi,QWORD PTR [rsp+0x10]
    3e35:	jmp    4001 <botlish_fn_45+0x351>
    3e3a:	mov    QWORD PTR [r12+0x48],rax
    3e3f:	mov    rbx,rax
    3e42:	mov    rdi,QWORD PTR [rsp+0x10]
    3e47:	call   3e4c <botlish_fn_45+0x19c>
			3e48: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3e4c:	test   rax,rax
    3e4f:	jne    3e5f <botlish_fn_45+0x1af>
    3e55:	mov    rdi,QWORD PTR [rsp+0x10]
    3e5a:	jmp    4001 <botlish_fn_45+0x351>
    3e5f:	mov    rcx,rbx
    3e62:	mov    rdx,rcx
    3e65:	and    rdx,rax
    3e68:	test   rdx,0x1
    3e6f:	jne    3e98 <botlish_fn_45+0x1e8>
    3e75:	mov    rdx,rax
    3e78:	mov    rsi,rbx
    3e7b:	mov    rdi,QWORD PTR [rsp+0x10]
    3e80:	call   3e85 <botlish_fn_45+0x1d5>
			3e81: R_X86_64_PLT32	rt_value_eq-0x4
    3e85:	test   rax,rax
    3e88:	jne    3eae <botlish_fn_45+0x1fe>
    3e8e:	mov    rdi,QWORD PTR [rsp+0x10]
    3e93:	jmp    4001 <botlish_fn_45+0x351>
    3e98:	mov    rdx,rax
    3e9b:	mov    rsi,rbx
    3e9e:	mov    eax,0x2
    3ea3:	cmp    rsi,rdx
    3ea6:	cmove  rax,QWORD PTR [rip+0x29a]        # 4148 <botlish_fn_45+0x498>
    3eae:	cmp    rax,0x6
    3eb2:	je     3ec2 <botlish_fn_45+0x212>
    3eb8:	mov    rbx,QWORD PTR [rsp+0x38]
    3ebd:	jmp    4031 <botlish_fn_45+0x381>
    3ec2:	xor    eax,eax
    3ec4:	mov    rdx,QWORD PTR [rsp+0x20]
    3ec9:	test   rdx,0x7
    3ed0:	je     3ee0 <botlish_fn_45+0x230>
    3ed6:	mov    QWORD PTR [rsp+0x20],rdx
    3edb:	jmp    3eee <botlish_fn_45+0x23e>
    3ee0:	movzx  rax,BYTE PTR [rdx]
    3ee4:	mov    QWORD PTR [rsp+0x20],rdx
    3ee9:	cmp    al,0x8
    3eeb:	sete   al
    3eee:	test   al,al
    3ef0:	jne    3f1c <botlish_fn_45+0x26c>
    3ef6:	mov    rdi,QWORD PTR [rsp+0x10]
    3efb:	mov    rsi,QWORD PTR [rdi+0x10]
    3eff:	mov    rcx,QWORD PTR [rsi+0x20]
    3f03:	mov    edx,0x8
    3f08:	mov    rsi,QWORD PTR [rsp+0x20]
    3f0d:	call   3f12 <botlish_fn_45+0x262>
			3f0e: R_X86_64_PLT32	rt_type_error-0x4
    3f12:	mov    rdi,QWORD PTR [rsp+0x10]
    3f17:	jmp    4001 <botlish_fn_45+0x351>
    3f1c:	mov    rdx,QWORD PTR [rsp+0x40]
    3f21:	mov    rsi,QWORD PTR [rsp+0x20]
    3f26:	mov    rdi,QWORD PTR [rsp+0x10]
    3f2b:	call   3f30 <botlish_fn_45+0x280>
			3f2c: R_X86_64_PLT32	rt_mutarray_get-0x4
    3f30:	test   rax,rax
    3f33:	jne    3f43 <botlish_fn_45+0x293>
    3f39:	mov    rdi,QWORD PTR [rsp+0x10]
    3f3e:	jmp    4001 <botlish_fn_45+0x351>
    3f43:	mov    QWORD PTR [r12+0x48],rax
    3f48:	mov    rbx,rax
    3f4b:	xor    eax,eax
    3f4d:	mov    rcx,QWORD PTR [rsp+0x28]
    3f52:	test   rcx,0x7
    3f59:	je     3f69 <botlish_fn_45+0x2b9>
    3f5f:	mov    QWORD PTR [rsp+0x28],rcx
    3f64:	jmp    3f77 <botlish_fn_45+0x2c7>
    3f69:	movzx  rax,BYTE PTR [rcx]
    3f6d:	mov    QWORD PTR [rsp+0x28],rcx
    3f72:	cmp    al,0x8
    3f74:	sete   al
    3f77:	test   al,al
    3f79:	jne    3fa5 <botlish_fn_45+0x2f5>
    3f7f:	mov    rdi,QWORD PTR [rsp+0x10]
    3f84:	mov    rax,QWORD PTR [rdi+0x10]
    3f88:	mov    rcx,QWORD PTR [rax+0x20]
    3f8c:	mov    edx,0x8
    3f91:	mov    rsi,QWORD PTR [rsp+0x28]
    3f96:	call   3f9b <botlish_fn_45+0x2eb>
			3f97: R_X86_64_PLT32	rt_type_error-0x4
    3f9b:	mov    rdi,QWORD PTR [rsp+0x10]
    3fa0:	jmp    4001 <botlish_fn_45+0x351>
    3fa5:	mov    rdx,QWORD PTR [rsp+0x40]
    3faa:	mov    rsi,QWORD PTR [rsp+0x28]
    3faf:	mov    rdi,QWORD PTR [rsp+0x10]
    3fb4:	call   3fb9 <botlish_fn_45+0x309>
			3fb5: R_X86_64_PLT32	rt_mutarray_get-0x4
    3fb9:	test   rax,rax
    3fbc:	jne    3fcc <botlish_fn_45+0x31c>
    3fc2:	mov    rdi,QWORD PTR [rsp+0x10]
    3fc7:	jmp    4001 <botlish_fn_45+0x351>
    3fcc:	mov    QWORD PTR [r12+0x50],rax
    3fd1:	mov    QWORD PTR [rsp],rax
    3fd5:	mov    r9,rbx
    3fd8:	mov    rbx,QWORD PTR [rsp+0x38]
    3fdd:	mov    rcx,r15
    3fe0:	mov    rdx,r14
    3fe3:	mov    rsi,r13
    3fe6:	mov    rdi,QWORD PTR [rsp+0x10]
    3feb:	mov    r8,rbx
    3fee:	call   3ff3 <botlish_fn_45+0x343>
			3fef: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    3ff3:	test   rax,rax
    3ff6:	jne    4031 <botlish_fn_45+0x381>
    3ffc:	mov    rdi,QWORD PTR [rsp+0x10]
    4001:	mov    rdi,QWORD PTR [rsp+0x10]
    4006:	mov    QWORD PTR [rdi],r12
    4009:	xor    rax,rax
    400c:	mov    rbx,QWORD PTR [rsp+0x50]
    4011:	mov    r12,QWORD PTR [rsp+0x58]
    4016:	mov    r13,QWORD PTR [rsp+0x60]
    401b:	mov    r14,QWORD PTR [rsp+0x68]
    4020:	mov    r15,QWORD PTR [rsp+0x70]
    4025:	add    rsp,0x80
    402c:	mov    rsp,rbp
    402f:	pop    rbp
    4030:	ret
    4031:	mov    QWORD PTR [r12+0x48],0x3
    403a:	mov    rsi,QWORD PTR [rsp+0x40]
    403f:	test   rsi,0x1
    4046:	je     4072 <botlish_fn_45+0x3c2>
    404c:	mov    rsi,QWORD PTR [rsp+0x40]
    4051:	mov    rcx,rsi
    4054:	add    rcx,0x2
    4058:	seto   al
    405b:	test   al,al
    405d:	jne    4072 <botlish_fn_45+0x3c2>
    4063:	mov    rsi,QWORD PTR [rsp+0x18]
    4068:	mov    QWORD PTR [rsp+0x40],rcx
    406d:	jmp    4090 <botlish_fn_45+0x3e0>
    4072:	mov    edx,0x3
    4077:	mov    rsi,QWORD PTR [rsp+0x40]
    407c:	mov    rdi,QWORD PTR [rsp+0x10]
    4081:	call   4086 <botlish_fn_45+0x3d6>
			4082: R_X86_64_PLT32	rt_int_add-0x4
    4086:	mov    rsi,QWORD PTR [rsp+0x18]
    408b:	mov    QWORD PTR [rsp+0x40],rax
    4090:	mov    rsi,QWORD PTR [rsp+0x18]
    4095:	mov    QWORD PTR [r12],rsi
    4099:	mov    rsi,QWORD PTR [rsp+0x20]
    409e:	mov    QWORD PTR [r12+0x8],rsi
    40a3:	mov    rsi,QWORD PTR [rsp+0x28]
    40a8:	mov    QWORD PTR [r12+0x10],rsi
    40ad:	mov    rsi,QWORD PTR [rsp+0x40]
    40b2:	mov    QWORD PTR [r12+0x18],rsi
    40b7:	mov    r9,QWORD PTR [rsp+0x30]
    40bc:	mov    QWORD PTR [r12+0x20],r9
    40c1:	mov    QWORD PTR [r12+0x28],r13
    40c6:	mov    QWORD PTR [r12+0x30],r14
    40cb:	mov    QWORD PTR [r12+0x38],r15
    40d0:	mov    QWORD PTR [r12+0x40],rbx
    40d5:	mov    QWORD PTR [rsp+0x38],rbx
    40da:	mov    rbx,QWORD PTR [rsp+0x30]
    40df:	jmp    3d61 <botlish_fn_45+0xb1>
    40e4:	mov    rdi,QWORD PTR [rsp+0x10]
    40e9:	mov    QWORD PTR [rdi],r12
    40ec:	mov    eax,0xa
    40f1:	mov    rbx,QWORD PTR [rsp+0x50]
    40f6:	mov    r12,QWORD PTR [rsp+0x58]
    40fb:	mov    r13,QWORD PTR [rsp+0x60]
    4100:	mov    r14,QWORD PTR [rsp+0x68]
    4105:	mov    r15,QWORD PTR [rsp+0x70]
    410a:	add    rsp,0x80
    4111:	mov    rsp,rbp
    4114:	pop    rbp
    4115:	ret
    4116:	mov    QWORD PTR [rsp+0x10],rdi
    411b:	call   4120 <botlish_fn_45+0x470>
			411c: R_X86_64_PLT32	rt_stack_overflow-0x4
    4120:	xor    rax,rax
    4123:	mov    rbx,QWORD PTR [rsp+0x50]
    4128:	mov    r12,QWORD PTR [rsp+0x58]
    412d:	mov    r13,QWORD PTR [rsp+0x60]
    4132:	mov    r14,QWORD PTR [rsp+0x68]
    4137:	mov    r15,QWORD PTR [rsp+0x70]
    413c:	add    rsp,0x80
    4143:	mov    rsp,rbp
    4146:	pop    rbp
    4147:	ret
    4148:	(bad)
    4149:	add    BYTE PTR [rax],al
    414b:	add    BYTE PTR [rax],al
    414d:	add    BYTE PTR [rax],al
	...

0000000000004150 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4150:	push   rbp
    4151:	mov    rbp,rsp
    4154:	sub    rsp,0x30
    4158:	mov    QWORD PTR [rsp+0x20],r12
    415d:	mov    rsi,QWORD PTR [rdx]
    4160:	mov    rax,QWORD PTR [rdx+0x8]
    4164:	mov    rcx,QWORD PTR [rdx+0x10]
    4168:	mov    r8,QWORD PTR [rdx+0x18]
    416c:	mov    r9,QWORD PTR [rdx+0x20]
    4170:	mov    r10,QWORD PTR [rdx+0x28]
    4174:	mov    r11,QWORD PTR [rdx+0x30]
    4178:	mov    r12,QWORD PTR [rdx+0x38]
    417c:	mov    rdx,QWORD PTR [rdx+0x40]
    4180:	mov    QWORD PTR [rsp],r10
    4184:	mov    QWORD PTR [rsp+0x8],r11
    4189:	mov    QWORD PTR [rsp+0x10],r12
    418e:	mov    QWORD PTR [rsp+0x18],rdx
    4193:	mov    rdx,rax
    4196:	call   419b <botlish_entry_45+0x4b>
			4197: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    419b:	mov    r12,QWORD PTR [rsp+0x20]
    41a0:	add    rsp,0x30
    41a4:	mov    rsp,rbp
    41a7:	pop    rbp
    41a8:	ret

00000000000041a9 <botlish_fn_46: ht_rehash<mutarray, int>>:
    41a9:	push   rbp
    41aa:	mov    rbp,rsp
    41ad:	sub    rsp,0x80
    41b4:	mov    QWORD PTR [rsp+0x50],rbx
    41b9:	mov    QWORD PTR [rsp+0x58],r12
    41be:	mov    QWORD PTR [rsp+0x60],r13
    41c3:	mov    QWORD PTR [rsp+0x68],r14
    41c8:	mov    QWORD PTR [rsp+0x70],r15
    41cd:	mov    r12,QWORD PTR [rdi]
    41d0:	mov    rax,QWORD PTR [rdi+0x8]
    41d4:	lea    rcx,[r12+0x50]
    41d9:	cmp    rcx,rax
    41dc:	ja     44cb <botlish_fn_46+0x322>
    41e2:	lea    rax,[r12+0x50]
    41e7:	mov    QWORD PTR [rdi],rax
    41ea:	mov    r13,rdi
    41ed:	mov    QWORD PTR [r12+0x10],0x0
    41f6:	mov    QWORD PTR [r12+0x18],0x0
    41ff:	mov    QWORD PTR [r12+0x20],0x0
    4208:	mov    QWORD PTR [r12+0x28],0x0
    4211:	mov    QWORD PTR [r12+0x30],0x0
    421a:	mov    QWORD PTR [r12+0x38],0x0
    4223:	mov    QWORD PTR [r12+0x40],0x0
    422c:	mov    QWORD PTR [r12+0x48],0x0
    4235:	mov    QWORD PTR [r12],rsi
    4239:	mov    r14,rsi
    423c:	mov    QWORD PTR [r12+0x8],rdx
    4241:	mov    rbx,rdx
    4244:	mov    rsi,r14
    4247:	mov    rdi,r13
    424a:	call   424f <botlish_fn_46+0xa6>
			424b: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    424f:	test   rax,rax
    4252:	jne    4260 <botlish_fn_46+0xb7>
    4258:	mov    rdi,r13
    425b:	jmp    446d <botlish_fn_46+0x2c4>
    4260:	mov    QWORD PTR [r12+0x10],rax
    4265:	mov    r15,rax
    4268:	mov    rsi,r14
    426b:	mov    rdi,r13
    426e:	call   4273 <botlish_fn_46+0xca>
			426f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4273:	test   rax,rax
    4276:	jne    4284 <botlish_fn_46+0xdb>
    427c:	mov    rdi,r13
    427f:	jmp    446d <botlish_fn_46+0x2c4>
    4284:	mov    QWORD PTR [r12+0x18],rax
    4289:	mov    QWORD PTR [rsp+0x48],rax
    428e:	mov    rsi,r14
    4291:	mov    rdi,r13
    4294:	call   4299 <botlish_fn_46+0xf0>
			4295: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4299:	test   rax,rax
    429c:	jne    42aa <botlish_fn_46+0x101>
    42a2:	mov    rdi,r13
    42a5:	jmp    446d <botlish_fn_46+0x2c4>
    42aa:	mov    QWORD PTR [r12+0x20],rax
    42af:	mov    QWORD PTR [rsp+0x40],rax
    42b4:	mov    rsi,r14
    42b7:	mov    rdi,r13
    42ba:	call   42bf <botlish_fn_46+0x116>
			42bb: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    42bf:	test   rax,rax
    42c2:	jne    42d0 <botlish_fn_46+0x127>
    42c8:	mov    rdi,r13
    42cb:	jmp    446d <botlish_fn_46+0x2c4>
    42d0:	mov    QWORD PTR [r12+0x28],rax
    42d5:	mov    QWORD PTR [rsp+0x38],rax
    42da:	mov    rsi,rbx
    42dd:	mov    rdi,r13
    42e0:	call   42e5 <botlish_fn_46+0x13c>
			42e1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    42e5:	mov    rcx,rax
    42e8:	mov    QWORD PTR [rsp+0x30],rax
    42ed:	test   rax,rcx
    42f0:	jne    42fe <botlish_fn_46+0x155>
    42f6:	mov    rdi,r13
    42f9:	jmp    446d <botlish_fn_46+0x2c4>
    42fe:	mov    rax,QWORD PTR [rsp+0x30]
    4303:	mov    QWORD PTR [r12+0x30],rax
    4308:	mov    edx,0x1
    430d:	mov    QWORD PTR [r12+0x38],0x1
    4316:	mov    rcx,rbx
    4319:	mov    rsi,QWORD PTR [rsp+0x30]
    431e:	mov    rdi,r13
    4321:	call   4326 <botlish_fn_46+0x17d>
			4322: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    4326:	test   rax,rax
    4329:	jne    4337 <botlish_fn_46+0x18e>
    432f:	mov    rdi,r13
    4332:	jmp    446d <botlish_fn_46+0x2c4>
    4337:	mov    rsi,rbx
    433a:	mov    rdi,r13
    433d:	call   4342 <botlish_fn_46+0x199>
			433e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4342:	test   rax,rax
    4345:	jne    4353 <botlish_fn_46+0x1aa>
    434b:	mov    rdi,r13
    434e:	jmp    446d <botlish_fn_46+0x2c4>
    4353:	mov    QWORD PTR [r12+0x38],rax
    4358:	mov    QWORD PTR [rsp+0x28],rax
    435d:	mov    rsi,rbx
    4360:	mov    rdi,r13
    4363:	call   4368 <botlish_fn_46+0x1bf>
			4364: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4368:	test   rax,rax
    436b:	jne    4379 <botlish_fn_46+0x1d0>
    4371:	mov    rdi,r13
    4374:	jmp    446d <botlish_fn_46+0x2c4>
    4379:	mov    QWORD PTR [r12+0x40],rax
    437e:	mov    r8d,0x1
    4384:	mov    QWORD PTR [r12+0x48],0x1
    438d:	mov    rcx,QWORD PTR [rsp+0x30]
    4392:	mov    QWORD PTR [rsp],rcx
    4396:	mov    rcx,QWORD PTR [rsp+0x28]
    439b:	mov    QWORD PTR [rsp+0x8],rcx
    43a0:	mov    QWORD PTR [rsp+0x10],rax
    43a5:	mov    QWORD PTR [rsp+0x20],rax
    43aa:	mov    QWORD PTR [rsp+0x18],rbx
    43af:	mov    rcx,QWORD PTR [rsp+0x40]
    43b4:	mov    rdx,QWORD PTR [rsp+0x48]
    43b9:	mov    rsi,r15
    43bc:	mov    r9,QWORD PTR [rsp+0x38]
    43c1:	mov    rdi,r13
    43c4:	call   43c9 <botlish_fn_46+0x220>
			43c5: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    43c9:	test   rax,rax
    43cc:	jne    43da <botlish_fn_46+0x231>
    43d2:	mov    rdi,r13
    43d5:	jmp    446d <botlish_fn_46+0x2c4>
    43da:	mov    edx,0x1
    43df:	mov    rcx,QWORD PTR [rsp+0x30]
    43e4:	mov    rsi,r14
    43e7:	mov    rdi,r13
    43ea:	call   43ef <botlish_fn_46+0x246>
			43eb: R_X86_64_PLT32	rt_mutarray_set-0x4
    43ef:	test   rax,rax
    43f2:	jne    4400 <botlish_fn_46+0x257>
    43f8:	mov    rdi,r13
    43fb:	jmp    446d <botlish_fn_46+0x2c4>
    4400:	mov    edx,0x3
    4405:	mov    rcx,QWORD PTR [rsp+0x28]
    440a:	mov    rsi,r14
    440d:	mov    rdi,r13
    4410:	call   4415 <botlish_fn_46+0x26c>
			4411: R_X86_64_PLT32	rt_mutarray_set-0x4
    4415:	test   rax,rax
    4418:	jne    4426 <botlish_fn_46+0x27d>
    441e:	mov    rdi,r13
    4421:	jmp    446d <botlish_fn_46+0x2c4>
    4426:	mov    edx,0x5
    442b:	mov    rcx,QWORD PTR [rsp+0x20]
    4430:	mov    rsi,r14
    4433:	mov    rdi,r13
    4436:	call   443b <botlish_fn_46+0x292>
			4437: R_X86_64_PLT32	rt_mutarray_set-0x4
    443b:	test   rax,rax
    443e:	jne    444c <botlish_fn_46+0x2a3>
    4444:	mov    rdi,r13
    4447:	jmp    446d <botlish_fn_46+0x2c4>
    444c:	mov    edx,0x9
    4451:	mov    ecx,0x1
    4456:	mov    rsi,r14
    4459:	mov    rdi,r13
    445c:	call   4461 <botlish_fn_46+0x2b8>
			445d: R_X86_64_PLT32	rt_mutarray_set-0x4
    4461:	test   rax,rax
    4464:	jne    449b <botlish_fn_46+0x2f2>
    446a:	mov    rdi,r13
    446d:	mov    rdi,r13
    4470:	mov    QWORD PTR [rdi],r12
    4473:	xor    rax,rax
    4476:	mov    rbx,QWORD PTR [rsp+0x50]
    447b:	mov    r12,QWORD PTR [rsp+0x58]
    4480:	mov    r13,QWORD PTR [rsp+0x60]
    4485:	mov    r14,QWORD PTR [rsp+0x68]
    448a:	mov    r15,QWORD PTR [rsp+0x70]
    448f:	add    rsp,0x80
    4496:	mov    rsp,rbp
    4499:	pop    rbp
    449a:	ret
    449b:	mov    rdi,r13
    449e:	mov    QWORD PTR [rdi],r12
    44a1:	mov    eax,0xa
    44a6:	mov    rbx,QWORD PTR [rsp+0x50]
    44ab:	mov    r12,QWORD PTR [rsp+0x58]
    44b0:	mov    r13,QWORD PTR [rsp+0x60]
    44b5:	mov    r14,QWORD PTR [rsp+0x68]
    44ba:	mov    r15,QWORD PTR [rsp+0x70]
    44bf:	add    rsp,0x80
    44c6:	mov    rsp,rbp
    44c9:	pop    rbp
    44ca:	ret
    44cb:	mov    r13,rdi
    44ce:	call   44d3 <botlish_fn_46+0x32a>
			44cf: R_X86_64_PLT32	rt_stack_overflow-0x4
    44d3:	xor    rax,rax
    44d6:	mov    rbx,QWORD PTR [rsp+0x50]
    44db:	mov    r12,QWORD PTR [rsp+0x58]
    44e0:	mov    r13,QWORD PTR [rsp+0x60]
    44e5:	mov    r14,QWORD PTR [rsp+0x68]
    44ea:	mov    r15,QWORD PTR [rsp+0x70]
    44ef:	add    rsp,0x80
    44f6:	mov    rsp,rbp
    44f9:	pop    rbp
    44fa:	ret

00000000000044fb <botlish_entry_46: ht_rehash<mutarray, int>>:
    44fb:	push   rbp
    44fc:	mov    rbp,rsp
    44ff:	mov    rsi,QWORD PTR [rdx]
    4502:	mov    rdx,QWORD PTR [rdx+0x8]
    4506:	call   450b <botlish_entry_46+0x10>
			4507: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    450b:	mov    rsp,rbp
    450e:	pop    rbp
    450f:	ret

0000000000004510 <botlish_fn_47: ht_should_grow<mutarray>>:
    4510:	push   rbp
    4511:	mov    rbp,rsp
    4514:	sub    rsp,0x20
    4518:	mov    QWORD PTR [rsp],rbx
    451c:	mov    QWORD PTR [rsp+0x8],r12
    4521:	mov    QWORD PTR [rsp+0x10],r13
    4526:	mov    QWORD PTR [rsp+0x18],r14
    452b:	mov    r12,QWORD PTR [rdi]
    452e:	mov    r8,QWORD PTR [rdi+0x8]
    4532:	lea    r9,[r12+0x18]
    4537:	cmp    r9,r8
    453a:	ja     486b <botlish_fn_47+0x35b>
    4540:	lea    r9,[r12+0x18]
    4545:	mov    QWORD PTR [rdi],r9
    4548:	mov    r13,rdi
    454b:	mov    QWORD PTR [r12+0x8],0x0
    4554:	mov    QWORD PTR [r12+0x10],0x0
    455d:	mov    QWORD PTR [r12],rsi
    4561:	mov    rbx,rsi
    4564:	mov    rsi,rbx
    4567:	mov    rdi,r13
    456a:	call   456f <botlish_fn_47+0x5f>
			456b: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    456f:	mov    rcx,rax
    4572:	mov    r14,rax
    4575:	test   rax,rcx
    4578:	jne    4586 <botlish_fn_47+0x76>
    457e:	mov    rdi,r13
    4581:	jmp    4783 <botlish_fn_47+0x273>
    4586:	mov    rax,r14
    4589:	mov    QWORD PTR [r12+0x8],rax
    458e:	mov    rsi,rbx
    4591:	mov    rdi,r13
    4594:	call   4599 <botlish_fn_47+0x89>
			4595: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4599:	mov    rcx,rax
    459c:	test   rcx,rcx
    459f:	jne    45ad <botlish_fn_47+0x9d>
    45a5:	mov    rdi,r13
    45a8:	jmp    4783 <botlish_fn_47+0x273>
    45ad:	mov    QWORD PTR [r12+0x10],rcx
    45b2:	mov    edx,0x1
    45b7:	mov    rax,r14
    45ba:	test   rax,0x1
    45c0:	jne    45e3 <botlish_fn_47+0xd3>
    45c6:	xor    edx,edx
    45c8:	mov    rax,r14
    45cb:	test   rax,0x7
    45d1:	jne    45e3 <botlish_fn_47+0xd3>
    45d7:	mov    rax,r14
    45da:	movzx  rax,BYTE PTR [rax]
    45de:	cmp    al,0x1
    45e0:	sete   dl
    45e3:	test   dl,dl
    45e5:	jne    4609 <botlish_fn_47+0xf9>
    45eb:	mov    rdi,r13
    45ee:	mov    rax,QWORD PTR [rdi+0x10]
    45f2:	mov    rcx,QWORD PTR [rax+0x30]
    45f6:	xor    rdx,rdx
    45f9:	mov    rsi,r14
    45fc:	call   4601 <botlish_fn_47+0xf1>
			45fd: R_X86_64_PLT32	rt_type_error-0x4
    4601:	mov    rdi,r13
    4604:	jmp    4783 <botlish_fn_47+0x273>
    4609:	mov    eax,0x1
    460e:	test   rcx,0x1
    4615:	je     4623 <botlish_fn_47+0x113>
    461b:	mov    r8,rcx
    461e:	jmp    4646 <botlish_fn_47+0x136>
    4623:	xor    eax,eax
    4625:	test   rcx,0x7
    462c:	je     463a <botlish_fn_47+0x12a>
    4632:	mov    r8,rcx
    4635:	jmp    4646 <botlish_fn_47+0x136>
    463a:	movzx  rax,BYTE PTR [rcx]
    463e:	mov    r8,rcx
    4641:	cmp    al,0x1
    4643:	sete   al
    4646:	test   al,al
    4648:	jne    466c <botlish_fn_47+0x15c>
    464e:	mov    rdi,r13
    4651:	mov    rax,QWORD PTR [rdi+0x10]
    4655:	mov    rcx,QWORD PTR [rax+0x30]
    4659:	xor    rdx,rdx
    465c:	mov    rsi,r8
    465f:	call   4664 <botlish_fn_47+0x154>
			4660: R_X86_64_PLT32	rt_type_error-0x4
    4664:	mov    rdi,r13
    4667:	jmp    4783 <botlish_fn_47+0x273>
    466c:	mov    rcx,r8
    466f:	mov    rsi,r14
    4672:	mov    rax,rsi
    4675:	and    rax,rcx
    4678:	test   rax,0x1
    467e:	jne    468f <botlish_fn_47+0x17f>
    4684:	mov    rdx,r8
    4687:	mov    rsi,r14
    468a:	jmp    46ad <botlish_fn_47+0x19d>
    468f:	mov    rcx,r8
    4692:	lea    rax,[rcx-0x1]
    4696:	mov    rsi,r14
    4699:	add    rsi,rax
    469c:	seto   al
    469f:	test   al,al
    46a1:	je     46b8 <botlish_fn_47+0x1a8>
    46a7:	mov    rdx,r8
    46aa:	mov    rsi,r14
    46ad:	mov    rdi,r13
    46b0:	call   46b5 <botlish_fn_47+0x1a5>
			46b1: R_X86_64_PLT32	rt_int_add-0x4
    46b5:	mov    rsi,rax
    46b8:	mov    QWORD PTR [r12+0x8],rsi
    46bd:	mov    QWORD PTR [r12+0x10],0x3
    46c6:	test   rsi,0x1
    46cd:	je     46f0 <botlish_fn_47+0x1e0>
    46d3:	mov    rax,rsi
    46d6:	add    rax,0x2
    46da:	mov    rcx,rax
    46dd:	seto   al
    46e0:	test   al,al
    46e2:	jne    46f0 <botlish_fn_47+0x1e0>
    46e8:	mov    rsi,rcx
    46eb:	jmp    4700 <botlish_fn_47+0x1f0>
    46f0:	mov    edx,0x3
    46f5:	mov    rdi,r13
    46f8:	call   46fd <botlish_fn_47+0x1ed>
			46f9: R_X86_64_PLT32	rt_int_add-0x4
    46fd:	mov    rsi,rax
    4700:	mov    QWORD PTR [r12+0x8],rsi
    4705:	mov    edx,0x7
    470a:	mov    rcx,rdx
    470d:	mov    QWORD PTR [r12+0x10],0x7
    4716:	test   rsi,0x1
    471d:	jne    472b <botlish_fn_47+0x21b>
    4723:	mov    rdx,rcx
    4726:	jmp    4759 <botlish_fn_47+0x249>
    472b:	mov    rax,rsi
    472e:	sar    rax,1
    4731:	imul   QWORD PTR [rip+0x160]        # 4898 <botlish_fn_47+0x388>
    4738:	seto   dil
    473c:	or     rax,0x1
    4740:	test   dil,dil
    4743:	je     4751 <botlish_fn_47+0x241>
    4749:	mov    rdx,rcx
    474c:	jmp    4759 <botlish_fn_47+0x249>
    4751:	mov    rsi,rax
    4754:	jmp    4764 <botlish_fn_47+0x254>
    4759:	mov    rdi,r13
    475c:	call   4761 <botlish_fn_47+0x251>
			475d: R_X86_64_PLT32	rt_int_mul-0x4
    4761:	mov    rsi,rax
    4764:	mov    QWORD PTR [r12+0x8],rsi
    4769:	mov    r14,rsi
    476c:	mov    rsi,rbx
    476f:	mov    rdi,r13
    4772:	call   4777 <botlish_fn_47+0x267>
			4773: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4777:	test   rax,rax
    477a:	jne    47a8 <botlish_fn_47+0x298>
    4780:	mov    rdi,r13
    4783:	mov    rdi,r13
    4786:	mov    QWORD PTR [rdi],r12
    4789:	xor    rax,rax
    478c:	mov    rbx,QWORD PTR [rsp]
    4790:	mov    r12,QWORD PTR [rsp+0x8]
    4795:	mov    r13,QWORD PTR [rsp+0x10]
    479a:	mov    r14,QWORD PTR [rsp+0x18]
    479f:	add    rsp,0x20
    47a3:	mov    rsp,rbp
    47a6:	pop    rbp
    47a7:	ret
    47a8:	mov    QWORD PTR [r12],rax
    47ac:	mov    QWORD PTR [r12+0x10],0x5
    47b5:	test   rax,0x1
    47bb:	mov    rsi,rax
    47be:	je     47ee <botlish_fn_47+0x2de>
    47c4:	mov    rcx,rsi
    47c7:	mov    rax,rcx
    47ca:	sar    rax,1
    47cd:	imul   QWORD PTR [rip+0xcc]        # 48a0 <botlish_fn_47+0x390>
    47d4:	seto   cl
    47d7:	or     rax,0x1
    47db:	test   cl,cl
    47dd:	jne    47ee <botlish_fn_47+0x2de>
    47e3:	mov    rdx,rax
    47e6:	mov    rsi,r14
    47e9:	jmp    4801 <botlish_fn_47+0x2f1>
    47ee:	mov    edx,0x5
    47f3:	mov    rdi,r13
    47f6:	call   47fb <botlish_fn_47+0x2eb>
			47f7: R_X86_64_PLT32	rt_int_mul-0x4
    47fb:	mov    rdx,rax
    47fe:	mov    rsi,r14
    4801:	mov    rax,rsi
    4804:	and    rax,rdx
    4807:	test   rax,0x1
    480d:	jne    4836 <botlish_fn_47+0x326>
    4813:	mov    rdi,r13
    4816:	call   481b <botlish_fn_47+0x30b>
			4817: R_X86_64_PLT32	rt_int_cmp-0x4
    481b:	mov    ecx,0x2
    4820:	test   rax,rax
    4823:	mov    rax,rcx
    4826:	cmovg  rax,QWORD PTR [rip+0x6a]        # 4898 <botlish_fn_47+0x388>
    482e:	mov    rdi,r13
    4831:	jmp    4849 <botlish_fn_47+0x339>
    4836:	mov    eax,0x2
    483b:	cmp    rsi,rdx
    483e:	cmovg  rax,QWORD PTR [rip+0x52]        # 4898 <botlish_fn_47+0x388>
    4846:	mov    rdi,r13
    4849:	mov    rdi,r13
    484c:	mov    QWORD PTR [rdi],r12
    484f:	mov    rbx,QWORD PTR [rsp]
    4853:	mov    r12,QWORD PTR [rsp+0x8]
    4858:	mov    r13,QWORD PTR [rsp+0x10]
    485d:	mov    r14,QWORD PTR [rsp+0x18]
    4862:	add    rsp,0x20
    4866:	mov    rsp,rbp
    4869:	pop    rbp
    486a:	ret
    486b:	mov    r13,rdi
    486e:	call   4873 <botlish_fn_47+0x363>
			486f: R_X86_64_PLT32	rt_stack_overflow-0x4
    4873:	xor    rax,rax
    4876:	mov    rbx,QWORD PTR [rsp]
    487a:	mov    r12,QWORD PTR [rsp+0x8]
    487f:	mov    r13,QWORD PTR [rsp+0x10]
    4884:	mov    r14,QWORD PTR [rsp+0x18]
    4889:	add    rsp,0x20
    488d:	mov    rsp,rbp
    4890:	pop    rbp
    4891:	ret
    4892:	add    BYTE PTR [rax],al
    4894:	add    BYTE PTR [rax],al
    4896:	add    BYTE PTR [rax],al
    4898:	(bad)
    4899:	add    BYTE PTR [rax],al
    489b:	add    BYTE PTR [rax],al
    489d:	add    BYTE PTR [rax],al
    489f:	add    BYTE PTR [rax+rax*1],al
    48a2:	add    BYTE PTR [rax],al
    48a4:	add    BYTE PTR [rax],al
	...

00000000000048a8 <botlish_entry_47: ht_should_grow<mutarray>>:
    48a8:	push   rbp
    48a9:	mov    rbp,rsp
    48ac:	mov    rsi,QWORD PTR [rdx]
    48af:	call   48b4 <botlish_entry_47+0xc>
			48b0: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    48b4:	mov    rsp,rbp
    48b7:	pop    rbp
    48b8:	ret
    48b9:	add    BYTE PTR [rax],al
    48bb:	add    BYTE PTR [rax],al
    48bd:	add    BYTE PTR [rax],al
	...

00000000000048c0 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    48c0:	push   rbp
    48c1:	mov    rbp,rsp
    48c4:	sub    rsp,0x20
    48c8:	mov    QWORD PTR [rsp],rbx
    48cc:	mov    QWORD PTR [rsp+0x8],r12
    48d1:	mov    QWORD PTR [rsp+0x10],r13
    48d6:	mov    QWORD PTR [rsp+0x18],r14
    48db:	mov    rbx,QWORD PTR [rdi]
    48de:	mov    rax,QWORD PTR [rdi+0x8]
    48e2:	lea    rcx,[rbx+0x18]
    48e6:	cmp    rcx,rax
    48e9:	ja     4b8b <botlish_fn_48+0x2cb>
    48ef:	lea    rax,[rbx+0x18]
    48f3:	mov    QWORD PTR [rdi],rax
    48f6:	mov    r12,rdi
    48f9:	mov    QWORD PTR [rbx+0x8],0x0
    4901:	mov    QWORD PTR [rbx+0x10],0x0
    4909:	mov    QWORD PTR [rbx],rsi
    490c:	mov    r13,rsi
    490f:	mov    rsi,r13
    4912:	mov    rdi,r12
    4915:	call   491a <botlish_fn_48+0x5a>
			4916: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    491a:	test   rax,rax
    491d:	jne    492b <botlish_fn_48+0x6b>
    4923:	mov    rdi,r12
    4926:	jmp    4b41 <botlish_fn_48+0x281>
    492b:	mov    QWORD PTR [rbx+0x8],rax
    492f:	mov    r14,rax
    4932:	mov    rsi,r13
    4935:	mov    rdi,r12
    4938:	call   493d <botlish_fn_48+0x7d>
			4939: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    493d:	mov    rcx,rax
    4940:	test   rcx,rcx
    4943:	jne    4951 <botlish_fn_48+0x91>
    4949:	mov    rdi,r12
    494c:	jmp    4b41 <botlish_fn_48+0x281>
    4951:	mov    edx,0x1
    4956:	mov    rax,r14
    4959:	test   rax,0x1
    495f:	je     496d <botlish_fn_48+0xad>
    4965:	mov    r14,rax
    4968:	jmp    4991 <botlish_fn_48+0xd1>
    496d:	xor    edx,edx
    496f:	test   rax,0x7
    4975:	je     4983 <botlish_fn_48+0xc3>
    497b:	mov    r14,rax
    497e:	jmp    4991 <botlish_fn_48+0xd1>
    4983:	movzx  rdx,BYTE PTR [rax]
    4987:	mov    r14,rax
    498a:	rex cmp dl,0x1
    498e:	sete   dl
    4991:	test   dl,dl
    4993:	jne    49b7 <botlish_fn_48+0xf7>
    4999:	mov    rdi,r12
    499c:	mov    rax,QWORD PTR [rdi+0x10]
    49a0:	mov    rcx,QWORD PTR [rax+0x38]
    49a4:	xor    rdx,rdx
    49a7:	mov    rsi,r14
    49aa:	call   49af <botlish_fn_48+0xef>
			49ab: R_X86_64_PLT32	rt_type_error-0x4
    49af:	mov    rdi,r12
    49b2:	jmp    4b41 <botlish_fn_48+0x281>
    49b7:	mov    rsi,r14
    49ba:	mov    eax,0x1
    49bf:	test   rcx,0x1
    49c6:	je     49d4 <botlish_fn_48+0x114>
    49cc:	mov    r9,rcx
    49cf:	jmp    49f7 <botlish_fn_48+0x137>
    49d4:	xor    eax,eax
    49d6:	test   rcx,0x7
    49dd:	je     49eb <botlish_fn_48+0x12b>
    49e3:	mov    r9,rcx
    49e6:	jmp    49f7 <botlish_fn_48+0x137>
    49eb:	movzx  rax,BYTE PTR [rcx]
    49ef:	mov    r9,rcx
    49f2:	cmp    al,0x1
    49f4:	sete   al
    49f7:	test   al,al
    49f9:	jne    4a1d <botlish_fn_48+0x15d>
    49ff:	mov    rdi,r12
    4a02:	mov    rax,QWORD PTR [rdi+0x10]
    4a06:	mov    rcx,QWORD PTR [rax+0x38]
    4a0a:	xor    rdx,rdx
    4a0d:	mov    rsi,r9
    4a10:	call   4a15 <botlish_fn_48+0x155>
			4a11: R_X86_64_PLT32	rt_type_error-0x4
    4a15:	mov    rdi,r12
    4a18:	jmp    4b41 <botlish_fn_48+0x281>
    4a1d:	mov    rcx,r9
    4a20:	mov    rax,rsi
    4a23:	and    rax,rcx
    4a26:	test   rax,0x1
    4a2c:	jne    4a53 <botlish_fn_48+0x193>
    4a32:	mov    rdx,r9
    4a35:	mov    rdi,r12
    4a38:	call   4a3d <botlish_fn_48+0x17d>
			4a39: R_X86_64_PLT32	rt_int_cmp-0x4
    4a3d:	mov    r8d,0x2
    4a43:	test   rax,rax
    4a46:	cmovg  r8,QWORD PTR [rip+0x16a]        # 4bb8 <botlish_fn_48+0x2f8>
    4a4e:	jmp    4a67 <botlish_fn_48+0x1a7>
    4a53:	mov    r8d,0x2
    4a59:	mov    rcx,r9
    4a5c:	cmp    rsi,rcx
    4a5f:	cmovg  r8,QWORD PTR [rip+0x151]        # 4bb8 <botlish_fn_48+0x2f8>
    4a67:	cmp    r8,0x6
    4a6b:	je     4b07 <botlish_fn_48+0x247>
    4a71:	mov    rsi,r13
    4a74:	mov    rdi,r12
    4a77:	call   4a7c <botlish_fn_48+0x1bc>
			4a78: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4a7c:	test   rax,rax
    4a7f:	jne    4a8d <botlish_fn_48+0x1cd>
    4a85:	mov    rdi,r12
    4a88:	jmp    4b41 <botlish_fn_48+0x281>
    4a8d:	mov    QWORD PTR [rbx+0x8],rax
    4a91:	mov    QWORD PTR [rbx+0x10],0x5
    4a99:	test   rax,0x1
    4a9f:	mov    rsi,rax
    4aa2:	je     4acf <botlish_fn_48+0x20f>
    4aa8:	mov    rcx,rsi
    4aab:	mov    rax,rcx
    4aae:	sar    rax,1
    4ab1:	imul   QWORD PTR [rip+0x108]        # 4bc0 <botlish_fn_48+0x300>
    4ab8:	seto   cl
    4abb:	or     rax,0x1
    4abf:	test   cl,cl
    4ac1:	jne    4acf <botlish_fn_48+0x20f>
    4ac7:	mov    rdx,rax
    4aca:	jmp    4adf <botlish_fn_48+0x21f>
    4acf:	mov    edx,0x5
    4ad4:	mov    rdi,r12
    4ad7:	call   4adc <botlish_fn_48+0x21c>
			4ad8: R_X86_64_PLT32	rt_int_mul-0x4
    4adc:	mov    rdx,rax
    4adf:	mov    QWORD PTR [rbx+0x8],rdx
    4ae3:	mov    rsi,r13
    4ae6:	mov    rdi,r12
    4ae9:	call   4aee <botlish_fn_48+0x22e>
			4aea: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    4aee:	test   rax,rax
    4af1:	jne    4aff <botlish_fn_48+0x23f>
    4af7:	mov    rdi,r12
    4afa:	jmp    4b41 <botlish_fn_48+0x281>
    4aff:	mov    rdi,r12
    4b02:	jmp    4b69 <botlish_fn_48+0x2a9>
    4b07:	mov    rsi,r13
    4b0a:	mov    rdi,r12
    4b0d:	call   4b12 <botlish_fn_48+0x252>
			4b0e: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4b12:	test   rax,rax
    4b15:	jne    4b23 <botlish_fn_48+0x263>
    4b1b:	mov    rdi,r12
    4b1e:	jmp    4b41 <botlish_fn_48+0x281>
    4b23:	mov    QWORD PTR [rbx+0x8],rax
    4b27:	mov    rdx,rax
    4b2a:	mov    rsi,r13
    4b2d:	mov    rdi,r12
    4b30:	call   4b35 <botlish_fn_48+0x275>
			4b31: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    4b35:	test   rax,rax
    4b38:	jne    4b66 <botlish_fn_48+0x2a6>
    4b3e:	mov    rdi,r12
    4b41:	mov    rdi,r12
    4b44:	mov    QWORD PTR [rdi],rbx
    4b47:	xor    rax,rax
    4b4a:	mov    rbx,QWORD PTR [rsp]
    4b4e:	mov    r12,QWORD PTR [rsp+0x8]
    4b53:	mov    r13,QWORD PTR [rsp+0x10]
    4b58:	mov    r14,QWORD PTR [rsp+0x18]
    4b5d:	add    rsp,0x20
    4b61:	mov    rsp,rbp
    4b64:	pop    rbp
    4b65:	ret
    4b66:	mov    rdi,r12
    4b69:	mov    rdi,r12
    4b6c:	mov    QWORD PTR [rdi],rbx
    4b6f:	mov    rbx,QWORD PTR [rsp]
    4b73:	mov    r12,QWORD PTR [rsp+0x8]
    4b78:	mov    r13,QWORD PTR [rsp+0x10]
    4b7d:	mov    r14,QWORD PTR [rsp+0x18]
    4b82:	add    rsp,0x20
    4b86:	mov    rsp,rbp
    4b89:	pop    rbp
    4b8a:	ret
    4b8b:	mov    r12,rdi
    4b8e:	call   4b93 <botlish_fn_48+0x2d3>
			4b8f: R_X86_64_PLT32	rt_stack_overflow-0x4
    4b93:	xor    rax,rax
    4b96:	mov    rbx,QWORD PTR [rsp]
    4b9a:	mov    r12,QWORD PTR [rsp+0x8]
    4b9f:	mov    r13,QWORD PTR [rsp+0x10]
    4ba4:	mov    r14,QWORD PTR [rsp+0x18]
    4ba9:	add    rsp,0x20
    4bad:	mov    rsp,rbp
    4bb0:	pop    rbp
    4bb1:	ret
    4bb2:	add    BYTE PTR [rax],al
    4bb4:	add    BYTE PTR [rax],al
    4bb6:	add    BYTE PTR [rax],al
    4bb8:	(bad)
    4bb9:	add    BYTE PTR [rax],al
    4bbb:	add    BYTE PTR [rax],al
    4bbd:	add    BYTE PTR [rax],al
    4bbf:	add    BYTE PTR [rax+rax*1],al
    4bc2:	add    BYTE PTR [rax],al
    4bc4:	add    BYTE PTR [rax],al
	...

0000000000004bc8 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    4bc8:	push   rbp
    4bc9:	mov    rbp,rsp
    4bcc:	mov    rsi,QWORD PTR [rdx]
    4bcf:	call   4bd4 <botlish_entry_48+0xc>
			4bd0: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    4bd4:	mov    rsp,rbp
    4bd7:	pop    rbp
    4bd8:	ret
    4bd9:	add    BYTE PTR [rax],al
    4bdb:	add    BYTE PTR [rax],al
    4bdd:	add    BYTE PTR [rax],al
	...

0000000000004be0 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    4be0:	push   rbp
    4be1:	mov    rbp,rsp
    4be4:	sub    rsp,0x50
    4be8:	mov    QWORD PTR [rsp+0x20],rbx
    4bed:	mov    QWORD PTR [rsp+0x28],r12
    4bf2:	mov    QWORD PTR [rsp+0x30],r13
    4bf7:	mov    QWORD PTR [rsp+0x38],r14
    4bfc:	mov    QWORD PTR [rsp+0x40],r15
    4c01:	mov    r12,QWORD PTR [rdi]
    4c04:	mov    rax,QWORD PTR [rdi+0x8]
    4c08:	lea    r9,[r12+0x30]
    4c0d:	cmp    r9,rax
    4c10:	ja     50d2 <botlish_fn_49+0x4f2>
    4c16:	lea    rax,[r12+0x30]
    4c1b:	mov    QWORD PTR [rdi],rax
    4c1e:	mov    r13,rdi
    4c21:	mov    QWORD PTR [r12+0x20],0x0
    4c2a:	mov    QWORD PTR [r12+0x28],0x0
    4c33:	mov    QWORD PTR [r12],rsi
    4c37:	mov    r14,rsi
    4c3a:	mov    QWORD PTR [r12+0x8],rdx
    4c3f:	mov    QWORD PTR [rsp],rdx
    4c43:	mov    QWORD PTR [r12+0x10],rcx
    4c48:	mov    QWORD PTR [rsp+0x8],rcx
    4c4d:	mov    QWORD PTR [r12+0x18],r8
    4c52:	mov    r15,r8
    4c55:	mov    rsi,r14
    4c58:	mov    rdi,r13
    4c5b:	call   4c60 <botlish_fn_49+0x80>
			4c5c: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    4c60:	test   rax,rax
    4c63:	jne    4c71 <botlish_fn_49+0x91>
    4c69:	mov    rdi,r13
    4c6c:	jmp    5077 <botlish_fn_49+0x497>
    4c71:	mov    QWORD PTR [r12+0x20],rax
    4c76:	xor    ecx,ecx
    4c78:	test   rax,0x7
    4c7e:	je     4c8e <botlish_fn_49+0xae>
    4c84:	mov    QWORD PTR [rsp+0x10],rax
    4c89:	jmp    4c9e <botlish_fn_49+0xbe>
    4c8e:	movzx  rcx,BYTE PTR [rax]
    4c92:	mov    QWORD PTR [rsp+0x10],rax
    4c97:	rex cmp cl,0x8
    4c9b:	sete   cl
    4c9e:	test   cl,cl
    4ca0:	jne    4cc8 <botlish_fn_49+0xe8>
    4ca6:	mov    rdi,r13
    4ca9:	mov    rax,QWORD PTR [rdi+0x10]
    4cad:	mov    rcx,QWORD PTR [rax+0x20]
    4cb1:	mov    edx,0x8
    4cb6:	mov    rsi,QWORD PTR [rsp+0x10]
    4cbb:	call   4cc0 <botlish_fn_49+0xe0>
			4cbc: R_X86_64_PLT32	rt_type_error-0x4
    4cc0:	mov    rdi,r13
    4cc3:	jmp    5077 <botlish_fn_49+0x497>
    4cc8:	mov    rdx,QWORD PTR [rsp]
    4ccc:	mov    rsi,QWORD PTR [rsp+0x10]
    4cd1:	mov    rdi,r13
    4cd4:	call   4cd9 <botlish_fn_49+0xf9>
			4cd5: R_X86_64_PLT32	rt_mutarray_get-0x4
    4cd9:	mov    rbx,rax
    4cdc:	test   rbx,rbx
    4cdf:	jne    4ced <botlish_fn_49+0x10d>
    4ce5:	mov    rdi,r13
    4ce8:	jmp    5077 <botlish_fn_49+0x497>
    4ced:	mov    QWORD PTR [r12+0x28],rbx
    4cf2:	mov    rdi,r13
    4cf5:	call   4cfa <botlish_fn_49+0x11a>
			4cf6: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    4cfa:	test   rax,rax
    4cfd:	mov    rcx,rax
    4d00:	jne    4d0e <botlish_fn_49+0x12e>
    4d06:	mov    rdi,r13
    4d09:	jmp    5077 <botlish_fn_49+0x497>
    4d0e:	mov    rsi,QWORD PTR [rsp+0x10]
    4d13:	mov    rdx,QWORD PTR [rsp]
    4d17:	mov    rdi,r13
    4d1a:	call   4d1f <botlish_fn_49+0x13f>
			4d1b: R_X86_64_PLT32	rt_mutarray_set-0x4
    4d1f:	test   rax,rax
    4d22:	jne    4d30 <botlish_fn_49+0x150>
    4d28:	mov    rdi,r13
    4d2b:	jmp    5077 <botlish_fn_49+0x497>
    4d30:	mov    rsi,r14
    4d33:	mov    rdi,r13
    4d36:	call   4d3b <botlish_fn_49+0x15b>
			4d37: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4d3b:	test   rax,rax
    4d3e:	jne    4d4c <botlish_fn_49+0x16c>
    4d44:	mov    rdi,r13
    4d47:	jmp    5077 <botlish_fn_49+0x497>
    4d4c:	xor    ecx,ecx
    4d4e:	test   rax,0x7
    4d54:	je     4d62 <botlish_fn_49+0x182>
    4d5a:	mov    rsi,rax
    4d5d:	jmp    4d70 <botlish_fn_49+0x190>
    4d62:	movzx  rdi,BYTE PTR [rax]
    4d66:	mov    rsi,rax
    4d69:	cmp    dil,0x8
    4d6d:	sete   cl
    4d70:	test   cl,cl
    4d72:	jne    4d95 <botlish_fn_49+0x1b5>
    4d78:	mov    rdi,r13
    4d7b:	mov    r11,QWORD PTR [rdi+0x10]
    4d7f:	mov    rcx,QWORD PTR [r11+0x40]
    4d83:	mov    edx,0x8
    4d88:	call   4d8d <botlish_fn_49+0x1ad>
			4d89: R_X86_64_PLT32	rt_type_error-0x4
    4d8d:	mov    rdi,r13
    4d90:	jmp    5077 <botlish_fn_49+0x497>
    4d95:	mov    rcx,QWORD PTR [rsp+0x8]
    4d9a:	mov    rdx,QWORD PTR [rsp]
    4d9e:	mov    rdi,r13
    4da1:	call   4da6 <botlish_fn_49+0x1c6>
			4da2: R_X86_64_PLT32	rt_mutarray_set-0x4
    4da6:	test   rax,rax
    4da9:	jne    4db7 <botlish_fn_49+0x1d7>
    4daf:	mov    rdi,r13
    4db2:	jmp    5077 <botlish_fn_49+0x497>
    4db7:	mov    rsi,r14
    4dba:	mov    rdi,r13
    4dbd:	call   4dc2 <botlish_fn_49+0x1e2>
			4dbe: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4dc2:	test   rax,rax
    4dc5:	jne    4dd3 <botlish_fn_49+0x1f3>
    4dcb:	mov    rdi,r13
    4dce:	jmp    5077 <botlish_fn_49+0x497>
    4dd3:	xor    ecx,ecx
    4dd5:	test   rax,0x7
    4ddb:	je     4de9 <botlish_fn_49+0x209>
    4de1:	mov    rsi,rax
    4de4:	jmp    4df7 <botlish_fn_49+0x217>
    4de9:	movzx  rcx,BYTE PTR [rax]
    4ded:	mov    rsi,rax
    4df0:	rex cmp cl,0x8
    4df4:	sete   cl
    4df7:	test   cl,cl
    4df9:	jne    4e1c <botlish_fn_49+0x23c>
    4dff:	mov    rdi,r13
    4e02:	mov    rax,QWORD PTR [rdi+0x10]
    4e06:	mov    rcx,QWORD PTR [rax+0x40]
    4e0a:	mov    edx,0x8
    4e0f:	call   4e14 <botlish_fn_49+0x234>
			4e10: R_X86_64_PLT32	rt_type_error-0x4
    4e14:	mov    rdi,r13
    4e17:	jmp    5077 <botlish_fn_49+0x497>
    4e1c:	mov    rcx,r15
    4e1f:	mov    rdx,QWORD PTR [rsp]
    4e23:	mov    rdi,r13
    4e26:	call   4e2b <botlish_fn_49+0x24b>
			4e27: R_X86_64_PLT32	rt_mutarray_set-0x4
    4e2b:	test   rax,rax
    4e2e:	jne    4e3c <botlish_fn_49+0x25c>
    4e34:	mov    rdi,r13
    4e37:	jmp    5077 <botlish_fn_49+0x497>
    4e3c:	mov    QWORD PTR [r12+0x8],0x7
    4e45:	mov    rsi,r14
    4e48:	mov    rdi,r13
    4e4b:	call   4e50 <botlish_fn_49+0x270>
			4e4c: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    4e50:	test   rax,rax
    4e53:	jne    4e61 <botlish_fn_49+0x281>
    4e59:	mov    rdi,r13
    4e5c:	jmp    5077 <botlish_fn_49+0x497>
    4e61:	mov    QWORD PTR [r12+0x10],rax
    4e66:	mov    QWORD PTR [r12+0x18],0x3
    4e6f:	mov    ecx,0x1
    4e74:	test   rax,0x1
    4e7a:	je     4e88 <botlish_fn_49+0x2a8>
    4e80:	mov    rsi,rax
    4e83:	jmp    4eac <botlish_fn_49+0x2cc>
    4e88:	xor    ecx,ecx
    4e8a:	test   rax,0x7
    4e90:	je     4e9e <botlish_fn_49+0x2be>
    4e96:	mov    rsi,rax
    4e99:	jmp    4eac <botlish_fn_49+0x2cc>
    4e9e:	movzx  rcx,BYTE PTR [rax]
    4ea2:	mov    rsi,rax
    4ea5:	rex cmp cl,0x1
    4ea9:	sete   cl
    4eac:	test   cl,cl
    4eae:	jne    4ecf <botlish_fn_49+0x2ef>
    4eb4:	mov    rdi,r13
    4eb7:	mov    rax,QWORD PTR [rdi+0x10]
    4ebb:	mov    rcx,QWORD PTR [rax+0x30]
    4ebf:	xor    rdx,rdx
    4ec2:	call   4ec7 <botlish_fn_49+0x2e7>
			4ec3: R_X86_64_PLT32	rt_type_error-0x4
    4ec7:	mov    rdi,r13
    4eca:	jmp    5077 <botlish_fn_49+0x497>
    4ecf:	test   rsi,0x1
    4ed6:	je     4eee <botlish_fn_49+0x30e>
    4edc:	mov    rcx,rsi
    4edf:	add    rcx,0x2
    4ee3:	seto   al
    4ee6:	test   al,al
    4ee8:	je     4efe <botlish_fn_49+0x31e>
    4eee:	mov    edx,0x3
    4ef3:	mov    rdi,r13
    4ef6:	call   4efb <botlish_fn_49+0x31b>
			4ef7: R_X86_64_PLT32	rt_int_add-0x4
    4efb:	mov    rcx,rax
    4efe:	mov    edx,0x7
    4f03:	mov    rsi,r14
    4f06:	mov    rdi,r13
    4f09:	call   4f0e <botlish_fn_49+0x32e>
			4f0a: R_X86_64_PLT32	rt_mutarray_set-0x4
    4f0e:	test   rax,rax
    4f11:	jne    4f1f <botlish_fn_49+0x33f>
    4f17:	mov    rdi,r13
    4f1a:	jmp    5077 <botlish_fn_49+0x497>
    4f1f:	mov    rdi,r13
    4f22:	call   4f27 <botlish_fn_49+0x347>
			4f23: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    4f27:	test   rax,rax
    4f2a:	jne    4f38 <botlish_fn_49+0x358>
    4f30:	mov    rdi,r13
    4f33:	jmp    5077 <botlish_fn_49+0x497>
    4f38:	mov    rcx,rbx
    4f3b:	and    rcx,rax
    4f3e:	mov    rdx,rax
    4f41:	mov    rax,rbx
    4f44:	test   rcx,0x1
    4f4b:	jne    4f6d <botlish_fn_49+0x38d>
    4f51:	mov    rsi,rax
    4f54:	mov    rdi,r13
    4f57:	call   4f5c <botlish_fn_49+0x37c>
			4f58: R_X86_64_PLT32	rt_value_eq-0x4
    4f5c:	test   rax,rax
    4f5f:	jne    4f80 <botlish_fn_49+0x3a0>
    4f65:	mov    rdi,r13
    4f68:	jmp    5077 <botlish_fn_49+0x497>
    4f6d:	mov    rsi,rax
    4f70:	mov    eax,0x2
    4f75:	cmp    rsi,rdx
    4f78:	cmove  rax,QWORD PTR [rip+0x180]        # 5100 <botlish_fn_49+0x520>
    4f80:	cmp    rax,0x6
    4f84:	je     4f92 <botlish_fn_49+0x3b2>
    4f8a:	mov    rdi,r13
    4f8d:	jmp    50a5 <botlish_fn_49+0x4c5>
    4f92:	mov    QWORD PTR [r12+0x8],0x9
    4f9b:	mov    rsi,r14
    4f9e:	mov    rdi,r13
    4fa1:	call   4fa6 <botlish_fn_49+0x3c6>
			4fa2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4fa6:	test   rax,rax
    4fa9:	jne    4fb7 <botlish_fn_49+0x3d7>
    4faf:	mov    rdi,r13
    4fb2:	jmp    5077 <botlish_fn_49+0x497>
    4fb7:	mov    QWORD PTR [r12+0x10],rax
    4fbc:	mov    QWORD PTR [r12+0x18],0x3
    4fc5:	mov    ecx,0x1
    4fca:	test   rax,0x1
    4fd0:	je     4fde <botlish_fn_49+0x3fe>
    4fd6:	mov    rsi,rax
    4fd9:	jmp    5002 <botlish_fn_49+0x422>
    4fde:	xor    ecx,ecx
    4fe0:	test   rax,0x7
    4fe6:	je     4ff4 <botlish_fn_49+0x414>
    4fec:	mov    rsi,rax
    4fef:	jmp    5002 <botlish_fn_49+0x422>
    4ff4:	movzx  rcx,BYTE PTR [rax]
    4ff8:	mov    rsi,rax
    4ffb:	rex cmp cl,0x1
    4fff:	sete   cl
    5002:	test   cl,cl
    5004:	jne    5025 <botlish_fn_49+0x445>
    500a:	mov    rdi,r13
    500d:	mov    rax,QWORD PTR [rdi+0x10]
    5011:	mov    rcx,QWORD PTR [rax+0x48]
    5015:	xor    rdx,rdx
    5018:	call   501d <botlish_fn_49+0x43d>
			5019: R_X86_64_PLT32	rt_type_error-0x4
    501d:	mov    rdi,r13
    5020:	jmp    5077 <botlish_fn_49+0x497>
    5025:	test   rsi,0x1
    502c:	je     504b <botlish_fn_49+0x46b>
    5032:	mov    rcx,rsi
    5035:	sub    rcx,0x3
    5039:	seto   al
    503c:	add    rcx,0x1
    5043:	test   al,al
    5045:	je     505b <botlish_fn_49+0x47b>
    504b:	mov    edx,0x3
    5050:	mov    rdi,r13
    5053:	call   5058 <botlish_fn_49+0x478>
			5054: R_X86_64_PLT32	rt_int_sub-0x4
    5058:	mov    rcx,rax
    505b:	mov    edx,0x9
    5060:	mov    rsi,r14
    5063:	mov    rdi,r13
    5066:	call   506b <botlish_fn_49+0x48b>
			5067: R_X86_64_PLT32	rt_mutarray_set-0x4
    506b:	test   rax,rax
    506e:	jne    50a2 <botlish_fn_49+0x4c2>
    5074:	mov    rdi,r13
    5077:	mov    rdi,r13
    507a:	mov    QWORD PTR [rdi],r12
    507d:	xor    rax,rax
    5080:	mov    rbx,QWORD PTR [rsp+0x20]
    5085:	mov    r12,QWORD PTR [rsp+0x28]
    508a:	mov    r13,QWORD PTR [rsp+0x30]
    508f:	mov    r14,QWORD PTR [rsp+0x38]
    5094:	mov    r15,QWORD PTR [rsp+0x40]
    5099:	add    rsp,0x50
    509d:	mov    rsp,rbp
    50a0:	pop    rbp
    50a1:	ret
    50a2:	mov    rdi,r13
    50a5:	mov    rdi,r13
    50a8:	mov    QWORD PTR [rdi],r12
    50ab:	mov    eax,0xa
    50b0:	mov    rbx,QWORD PTR [rsp+0x20]
    50b5:	mov    r12,QWORD PTR [rsp+0x28]
    50ba:	mov    r13,QWORD PTR [rsp+0x30]
    50bf:	mov    r14,QWORD PTR [rsp+0x38]
    50c4:	mov    r15,QWORD PTR [rsp+0x40]
    50c9:	add    rsp,0x50
    50cd:	mov    rsp,rbp
    50d0:	pop    rbp
    50d1:	ret
    50d2:	mov    r13,rdi
    50d5:	call   50da <botlish_fn_49+0x4fa>
			50d6: R_X86_64_PLT32	rt_stack_overflow-0x4
    50da:	xor    rax,rax
    50dd:	mov    rbx,QWORD PTR [rsp+0x20]
    50e2:	mov    r12,QWORD PTR [rsp+0x28]
    50e7:	mov    r13,QWORD PTR [rsp+0x30]
    50ec:	mov    r14,QWORD PTR [rsp+0x38]
    50f1:	mov    r15,QWORD PTR [rsp+0x40]
    50f6:	add    rsp,0x50
    50fa:	mov    rsp,rbp
    50fd:	pop    rbp
    50fe:	ret
    50ff:	add    BYTE PTR [rsi],al
    5101:	add    BYTE PTR [rax],al
    5103:	add    BYTE PTR [rax],al
    5105:	add    BYTE PTR [rax],al
	...

0000000000005108 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    5108:	push   rbp
    5109:	mov    rbp,rsp
    510c:	mov    rsi,QWORD PTR [rdx]
    510f:	mov    r9,QWORD PTR [rdx+0x8]
    5113:	mov    rcx,QWORD PTR [rdx+0x10]
    5117:	mov    r8,QWORD PTR [rdx+0x18]
    511b:	mov    rdx,r9
    511e:	call   5123 <botlish_entry_49+0x1b>
			511f: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5123:	mov    rsp,rbp
    5126:	pop    rbp
    5127:	ret

0000000000005128 <botlish_fn_50: ht_set<mutarray, any, any>>:
    5128:	push   rbp
    5129:	mov    rbp,rsp
    512c:	sub    rsp,0x50
    5130:	mov    QWORD PTR [rsp+0x20],rbx
    5135:	mov    QWORD PTR [rsp+0x28],r12
    513a:	mov    QWORD PTR [rsp+0x30],r13
    513f:	mov    QWORD PTR [rsp+0x38],r14
    5144:	mov    QWORD PTR [rsp+0x40],r15
    5149:	mov    rbx,QWORD PTR [rdi]
    514c:	mov    rax,QWORD PTR [rdi+0x8]
    5150:	lea    r8,[rbx+0x28]
    5154:	cmp    r8,rax
    5157:	ja     54f9 <botlish_fn_50+0x3d1>
    515d:	lea    rax,[rbx+0x28]
    5161:	mov    QWORD PTR [rdi],rax
    5164:	mov    r12,rdi
    5167:	mov    QWORD PTR [rbx+0x18],0x0
    516f:	mov    QWORD PTR [rbx+0x20],0x0
    5177:	mov    QWORD PTR [rbx],rsi
    517a:	mov    r15,rsi
    517d:	mov    QWORD PTR [rbx+0x8],rdx
    5181:	mov    r14,rdx
    5184:	mov    QWORD PTR [rbx+0x10],rcx
    5188:	mov    r13,rcx
    518b:	mov    rdx,r14
    518e:	mov    rsi,r15
    5191:	mov    rdi,r12
    5194:	call   5199 <botlish_fn_50+0x71>
			5195: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5199:	test   rax,rax
    519c:	jne    51aa <botlish_fn_50+0x82>
    51a2:	mov    rdi,r12
    51a5:	jmp    54a1 <botlish_fn_50+0x379>
    51aa:	mov    QWORD PTR [rbx+0x18],rax
    51ae:	mov    rcx,rax
    51b1:	mov    r8,0xffffffffffffffff
    51b8:	mov    QWORD PTR [rsp+0x10],r8
    51bd:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    51c5:	mov    rdx,r14
    51c8:	mov    rsi,r15
    51cb:	mov    rdi,r12
    51ce:	call   51d3 <botlish_fn_50+0xab>
			51cf: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    51d3:	mov    rcx,rax
    51d6:	mov    QWORD PTR [rsp+0x8],rax
    51db:	test   rax,rcx
    51de:	jne    51ec <botlish_fn_50+0xc4>
    51e4:	mov    rdi,r12
    51e7:	jmp    54a1 <botlish_fn_50+0x379>
    51ec:	mov    rax,QWORD PTR [rsp+0x8]
    51f1:	mov    QWORD PTR [rbx+0x18],rax
    51f5:	mov    rsi,r15
    51f8:	mov    rdi,r12
    51fb:	call   5200 <botlish_fn_50+0xd8>
			51fc: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    5200:	test   rax,rax
    5203:	jne    5211 <botlish_fn_50+0xe9>
    5209:	mov    rdi,r12
    520c:	jmp    54a1 <botlish_fn_50+0x379>
    5211:	xor    ecx,ecx
    5213:	test   rax,0x7
    5219:	je     5227 <botlish_fn_50+0xff>
    521f:	mov    rsi,rax
    5222:	jmp    5235 <botlish_fn_50+0x10d>
    5227:	movzx  rcx,BYTE PTR [rax]
    522b:	mov    rsi,rax
    522e:	rex cmp cl,0x8
    5232:	sete   cl
    5235:	test   cl,cl
    5237:	jne    525a <botlish_fn_50+0x132>
    523d:	mov    rdi,r12
    5240:	mov    rax,QWORD PTR [rdi+0x10]
    5244:	mov    rcx,QWORD PTR [rax+0x20]
    5248:	mov    edx,0x8
    524d:	call   5252 <botlish_fn_50+0x12a>
			524e: R_X86_64_PLT32	rt_type_error-0x4
    5252:	mov    rdi,r12
    5255:	jmp    54a1 <botlish_fn_50+0x379>
    525a:	mov    rdx,QWORD PTR [rsp+0x8]
    525f:	mov    rdi,r12
    5262:	call   5267 <botlish_fn_50+0x13f>
			5263: R_X86_64_PLT32	rt_mutarray_get-0x4
    5267:	test   rax,rax
    526a:	jne    5278 <botlish_fn_50+0x150>
    5270:	mov    rdi,r12
    5273:	jmp    54a1 <botlish_fn_50+0x379>
    5278:	mov    QWORD PTR [rbx+0x20],rax
    527c:	mov    QWORD PTR [rsp],rax
    5280:	mov    rdi,r12
    5283:	call   5288 <botlish_fn_50+0x160>
			5284: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    5288:	test   rax,rax
    528b:	jne    5299 <botlish_fn_50+0x171>
    5291:	mov    rdi,r12
    5294:	jmp    54a1 <botlish_fn_50+0x379>
    5299:	mov    rcx,QWORD PTR [rsp]
    529d:	mov    rdx,rcx
    52a0:	and    rdx,rax
    52a3:	test   rdx,0x1
    52aa:	jne    52d0 <botlish_fn_50+0x1a8>
    52b0:	mov    rdx,rax
    52b3:	mov    rsi,QWORD PTR [rsp]
    52b7:	mov    rdi,r12
    52ba:	call   52bf <botlish_fn_50+0x197>
			52bb: R_X86_64_PLT32	rt_value_eq-0x4
    52bf:	test   rax,rax
    52c2:	jne    52e7 <botlish_fn_50+0x1bf>
    52c8:	mov    rdi,r12
    52cb:	jmp    54a1 <botlish_fn_50+0x379>
    52d0:	mov    rdx,rax
    52d3:	mov    rsi,QWORD PTR [rsp]
    52d7:	mov    eax,0x2
    52dc:	cmp    rsi,rdx
    52df:	cmove  rax,QWORD PTR [rip+0x241]        # 5528 <botlish_fn_50+0x400>
    52e7:	cmp    rax,0x6
    52eb:	je     5425 <botlish_fn_50+0x2fd>
    52f1:	mov    rsi,r15
    52f4:	mov    rdi,r12
    52f7:	call   52fc <botlish_fn_50+0x1d4>
			52f8: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    52fc:	test   rax,rax
    52ff:	jne    530d <botlish_fn_50+0x1e5>
    5305:	mov    rdi,r12
    5308:	jmp    54a1 <botlish_fn_50+0x379>
    530d:	cmp    rax,0x6
    5311:	je     5366 <botlish_fn_50+0x23e>
    5317:	mov    rcx,r14
    531a:	mov    rdx,QWORD PTR [rsp+0x8]
    531f:	mov    rsi,r15
    5322:	mov    r8,r13
    5325:	mov    rdi,r12
    5328:	call   532d <botlish_fn_50+0x205>
			5329: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    532d:	test   rax,rax
    5330:	jne    533e <botlish_fn_50+0x216>
    5336:	mov    rdi,r12
    5339:	jmp    54a1 <botlish_fn_50+0x379>
    533e:	mov    rdi,r12
    5341:	mov    QWORD PTR [rdi],rbx
    5344:	mov    rbx,QWORD PTR [rsp+0x20]
    5349:	mov    r12,QWORD PTR [rsp+0x28]
    534e:	mov    r13,QWORD PTR [rsp+0x30]
    5353:	mov    r14,QWORD PTR [rsp+0x38]
    5358:	mov    r15,QWORD PTR [rsp+0x40]
    535d:	add    rsp,0x50
    5361:	mov    rsp,rbp
    5364:	pop    rbp
    5365:	ret
    5366:	mov    rsi,r15
    5369:	mov    rdi,r12
    536c:	call   5371 <botlish_fn_50+0x249>
			536d: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    5371:	test   rax,rax
    5374:	jne    5382 <botlish_fn_50+0x25a>
    537a:	mov    rdi,r12
    537d:	jmp    54a1 <botlish_fn_50+0x379>
    5382:	mov    rdx,r14
    5385:	mov    rsi,r15
    5388:	mov    rdi,r12
    538b:	call   5390 <botlish_fn_50+0x268>
			538c: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5390:	test   rax,rax
    5393:	jne    53a1 <botlish_fn_50+0x279>
    5399:	mov    rdi,r12
    539c:	jmp    54a1 <botlish_fn_50+0x379>
    53a1:	mov    QWORD PTR [rbx+0x18],rax
    53a5:	mov    rcx,rax
    53a8:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    53b0:	mov    r8,QWORD PTR [rsp+0x10]
    53b5:	mov    rdx,r14
    53b8:	mov    rsi,r15
    53bb:	mov    rdi,r12
    53be:	call   53c3 <botlish_fn_50+0x29b>
			53bf: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    53c3:	test   rax,rax
    53c6:	jne    53d4 <botlish_fn_50+0x2ac>
    53cc:	mov    rdi,r12
    53cf:	jmp    54a1 <botlish_fn_50+0x379>
    53d4:	mov    QWORD PTR [rbx+0x18],rax
    53d8:	mov    rcx,r14
    53db:	mov    rdx,rax
    53de:	mov    rsi,r15
    53e1:	mov    r8,r13
    53e4:	mov    rdi,r12
    53e7:	call   53ec <botlish_fn_50+0x2c4>
			53e8: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    53ec:	test   rax,rax
    53ef:	jne    53fd <botlish_fn_50+0x2d5>
    53f5:	mov    rdi,r12
    53f8:	jmp    54a1 <botlish_fn_50+0x379>
    53fd:	mov    rdi,r12
    5400:	mov    QWORD PTR [rdi],rbx
    5403:	mov    rbx,QWORD PTR [rsp+0x20]
    5408:	mov    r12,QWORD PTR [rsp+0x28]
    540d:	mov    r13,QWORD PTR [rsp+0x30]
    5412:	mov    r14,QWORD PTR [rsp+0x38]
    5417:	mov    r15,QWORD PTR [rsp+0x40]
    541c:	add    rsp,0x50
    5420:	mov    rsp,rbp
    5423:	pop    rbp
    5424:	ret
    5425:	mov    rsi,r15
    5428:	mov    rdi,r12
    542b:	call   5430 <botlish_fn_50+0x308>
			542c: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    5430:	test   rax,rax
    5433:	jne    5441 <botlish_fn_50+0x319>
    5439:	mov    rdi,r12
    543c:	jmp    54a1 <botlish_fn_50+0x379>
    5441:	xor    ecx,ecx
    5443:	test   rax,0x7
    5449:	jne    545a <botlish_fn_50+0x332>
    544f:	movzx  rsi,BYTE PTR [rax]
    5453:	cmp    sil,0x8
    5457:	sete   cl
    545a:	test   cl,cl
    545c:	jne    5482 <botlish_fn_50+0x35a>
    5462:	mov    rdi,r12
    5465:	mov    r10,QWORD PTR [rdi+0x10]
    5469:	mov    rcx,QWORD PTR [r10+0x40]
    546d:	mov    edx,0x8
    5472:	mov    rsi,rax
    5475:	call   547a <botlish_fn_50+0x352>
			5476: R_X86_64_PLT32	rt_type_error-0x4
    547a:	mov    rdi,r12
    547d:	jmp    54a1 <botlish_fn_50+0x379>
    5482:	mov    rcx,r13
    5485:	mov    rdx,QWORD PTR [rsp+0x8]
    548a:	mov    rsi,rax
    548d:	mov    rdi,r12
    5490:	call   5495 <botlish_fn_50+0x36d>
			5491: R_X86_64_PLT32	rt_mutarray_set-0x4
    5495:	test   rax,rax
    5498:	jne    54cc <botlish_fn_50+0x3a4>
    549e:	mov    rdi,r12
    54a1:	mov    rdi,r12
    54a4:	mov    QWORD PTR [rdi],rbx
    54a7:	xor    rax,rax
    54aa:	mov    rbx,QWORD PTR [rsp+0x20]
    54af:	mov    r12,QWORD PTR [rsp+0x28]
    54b4:	mov    r13,QWORD PTR [rsp+0x30]
    54b9:	mov    r14,QWORD PTR [rsp+0x38]
    54be:	mov    r15,QWORD PTR [rsp+0x40]
    54c3:	add    rsp,0x50
    54c7:	mov    rsp,rbp
    54ca:	pop    rbp
    54cb:	ret
    54cc:	mov    rdi,r12
    54cf:	mov    QWORD PTR [rdi],rbx
    54d2:	mov    eax,0xa
    54d7:	mov    rbx,QWORD PTR [rsp+0x20]
    54dc:	mov    r12,QWORD PTR [rsp+0x28]
    54e1:	mov    r13,QWORD PTR [rsp+0x30]
    54e6:	mov    r14,QWORD PTR [rsp+0x38]
    54eb:	mov    r15,QWORD PTR [rsp+0x40]
    54f0:	add    rsp,0x50
    54f4:	mov    rsp,rbp
    54f7:	pop    rbp
    54f8:	ret
    54f9:	mov    r12,rdi
    54fc:	call   5501 <botlish_fn_50+0x3d9>
			54fd: R_X86_64_PLT32	rt_stack_overflow-0x4
    5501:	xor    rax,rax
    5504:	mov    rbx,QWORD PTR [rsp+0x20]
    5509:	mov    r12,QWORD PTR [rsp+0x28]
    550e:	mov    r13,QWORD PTR [rsp+0x30]
    5513:	mov    r14,QWORD PTR [rsp+0x38]
    5518:	mov    r15,QWORD PTR [rsp+0x40]
    551d:	add    rsp,0x50
    5521:	mov    rsp,rbp
    5524:	pop    rbp
    5525:	ret
    5526:	add    BYTE PTR [rax],al
    5528:	(bad)
    5529:	add    BYTE PTR [rax],al
    552b:	add    BYTE PTR [rax],al
    552d:	add    BYTE PTR [rax],al
	...

0000000000005530 <botlish_entry_50: ht_set<mutarray, any, any>>:
    5530:	push   rbp
    5531:	mov    rbp,rsp
    5534:	mov    rsi,QWORD PTR [rdx]
    5537:	mov    r8,QWORD PTR [rdx+0x8]
    553b:	mov    rcx,QWORD PTR [rdx+0x10]
    553f:	mov    rdx,r8
    5542:	call   5547 <botlish_entry_50+0x17>
			5543: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    5547:	mov    rsp,rbp
    554a:	pop    rbp
    554b:	ret

000000000000554c <botlish_fn_51: row_new<bool, int>>:
    554c:	push   rbp
    554d:	mov    rbp,rsp
    5550:	sub    rsp,0x10
    5554:	mov    QWORD PTR [rsp],r14
    5558:	mov    QWORD PTR [rsp+0x8],r15
    555d:	mov    r14,QWORD PTR [rdi]
    5560:	mov    rax,QWORD PTR [rdi+0x8]
    5564:	lea    rcx,[r14+0x8]
    5568:	cmp    rcx,rax
    556b:	ja     5606 <botlish_fn_51+0xba>
    5571:	lea    rax,[r14+0x8]
    5575:	mov    QWORD PTR [rdi],rax
    5578:	mov    r15,rdi
    557b:	mov    QWORD PTR [r14],rdx
    557e:	mov    rax,rdx
    5581:	cmp    rsi,0x6
    5585:	je     55bc <botlish_fn_51+0x70>
    558b:	mov    rdi,r15
    558e:	call   5593 <botlish_fn_51+0x47>
			558f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    5593:	test   rax,rax
    5596:	jne    55a4 <botlish_fn_51+0x58>
    559c:	mov    rdi,r15
    559f:	jmp    55d3 <botlish_fn_51+0x87>
    55a4:	mov    rdi,r15
    55a7:	mov    QWORD PTR [rdi],r14
    55aa:	mov    r14,QWORD PTR [rsp]
    55ae:	mov    r15,QWORD PTR [rsp+0x8]
    55b3:	add    rsp,0x10
    55b7:	mov    rsp,rbp
    55ba:	pop    rbp
    55bb:	ret
    55bc:	mov    rsi,rax
    55bf:	mov    rdi,r15
    55c2:	call   55c7 <botlish_fn_51+0x7b>
			55c3: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    55c7:	test   rax,rax
    55ca:	jne    55ee <botlish_fn_51+0xa2>
    55d0:	mov    rdi,r15
    55d3:	mov    rdi,r15
    55d6:	mov    QWORD PTR [rdi],r14
    55d9:	xor    rax,rax
    55dc:	mov    r14,QWORD PTR [rsp]
    55e0:	mov    r15,QWORD PTR [rsp+0x8]
    55e5:	add    rsp,0x10
    55e9:	mov    rsp,rbp
    55ec:	pop    rbp
    55ed:	ret
    55ee:	mov    rdi,r15
    55f1:	mov    QWORD PTR [rdi],r14
    55f4:	mov    r14,QWORD PTR [rsp]
    55f8:	mov    r15,QWORD PTR [rsp+0x8]
    55fd:	add    rsp,0x10
    5601:	mov    rsp,rbp
    5604:	pop    rbp
    5605:	ret
    5606:	mov    r15,rdi
    5609:	call   560e <botlish_fn_51+0xc2>
			560a: R_X86_64_PLT32	rt_stack_overflow-0x4
    560e:	xor    rax,rax
    5611:	mov    r14,QWORD PTR [rsp]
    5615:	mov    r15,QWORD PTR [rsp+0x8]
    561a:	add    rsp,0x10
    561e:	mov    rsp,rbp
    5621:	pop    rbp
    5622:	ret

0000000000005623 <botlish_entry_51: row_new<bool, int>>:
    5623:	push   rbp
    5624:	mov    rbp,rsp
    5627:	mov    rsi,QWORD PTR [rdx]
    562a:	mov    rdx,QWORD PTR [rdx+0x8]
    562e:	call   5633 <botlish_entry_51+0x10>
			562f: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    5633:	mov    rsp,rbp
    5636:	pop    rbp
    5637:	ret

0000000000005638 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    5638:	push   rbp
    5639:	mov    rbp,rsp
    563c:	sub    rsp,0x50
    5640:	mov    QWORD PTR [rsp+0x20],rbx
    5645:	mov    QWORD PTR [rsp+0x28],r12
    564a:	mov    QWORD PTR [rsp+0x30],r13
    564f:	mov    QWORD PTR [rsp+0x38],r14
    5654:	mov    QWORD PTR [rsp+0x40],r15
    5659:	mov    r13,rdx
    565c:	mov    r15,QWORD PTR [rdi]
    565f:	mov    rax,QWORD PTR [rdi+0x8]
    5663:	lea    rdx,[r15+0x30]
    5667:	cmp    rdx,rax
    566a:	ja     590a <botlish_fn_52+0x2d2>
    5670:	lea    rdx,[r15+0x30]
    5674:	mov    QWORD PTR [rdi],rdx
    5677:	mov    QWORD PTR [rsp],rdi
    567b:	mov    QWORD PTR [r15],rsi
    567e:	mov    rdx,r13
    5681:	mov    r14,rsi
    5684:	mov    QWORD PTR [r15+0x8],rdx
    5688:	mov    QWORD PTR [r15+0x10],rcx
    568c:	mov    QWORD PTR [rsp+0x8],rcx
    5691:	mov    QWORD PTR [r15+0x18],r8
    5695:	mov    rbx,r9
    5698:	mov    rdi,rbx
    569b:	or     rdi,0x1
    569f:	mov    r12,r8
    56a2:	and    r8,rdi
    56a5:	test   r8,0x1
    56ac:	jne    56da <botlish_fn_52+0xa2>
    56b2:	mov    rdx,rbx
    56b5:	or     rdx,0x1
    56b9:	mov    rsi,r12
    56bc:	mov    rdi,QWORD PTR [rsp]
    56c0:	call   56c5 <botlish_fn_52+0x8d>
			56c1: R_X86_64_PLT32	rt_int_cmp-0x4
    56c5:	mov    ecx,0x2
    56ca:	test   rax,rax
    56cd:	cmovge rcx,QWORD PTR [rip+0x263]        # 5938 <botlish_fn_52+0x300>
    56d5:	jmp    56f1 <botlish_fn_52+0xb9>
    56da:	mov    r11,rbx
    56dd:	or     r11,0x1
    56e1:	mov    ecx,0x2
    56e6:	cmp    r12,r11
    56e9:	cmovge rcx,QWORD PTR [rip+0x247]        # 5938 <botlish_fn_52+0x300>
    56f1:	cmp    rcx,0x6
    56f5:	je     58de <botlish_fn_52+0x2a6>
    56fb:	xor    ecx,ecx
    56fd:	mov    rdx,r13
    5700:	test   rdx,0x7
    5707:	jne    5719 <botlish_fn_52+0xe1>
    570d:	mov    rdx,r13
    5710:	movzx  rax,BYTE PTR [rdx]
    5714:	cmp    al,0x3
    5716:	sete   cl
    5719:	test   cl,cl
    571b:	jne    5743 <botlish_fn_52+0x10b>
    5721:	mov    rdi,QWORD PTR [rsp]
    5725:	mov    rax,QWORD PTR [rdi+0x10]
    5729:	mov    rcx,QWORD PTR [rax+0x50]
    572d:	mov    edx,0x4
    5732:	mov    rsi,r13
    5735:	call   573a <botlish_fn_52+0x102>
			5736: R_X86_64_PLT32	rt_type_error-0x4
    573a:	mov    rdi,QWORD PTR [rsp]
    573e:	jmp    5885 <botlish_fn_52+0x24d>
    5743:	mov    rsi,r13
    5746:	test   r12,0x1
    574d:	jne    575b <botlish_fn_52+0x123>
    5753:	mov    r13,rsi
    5756:	jmp    5771 <botlish_fn_52+0x139>
    575b:	mov    rax,QWORD PTR [rsi+0x8]
    575f:	mov    r13,rsi
    5762:	mov    rcx,r12
    5765:	sar    rcx,1
    5768:	cmp    rcx,rax
    576b:	jb     579a <botlish_fn_52+0x162>
    5771:	mov    rdx,r12
    5774:	mov    rsi,r13
    5777:	mov    rdi,QWORD PTR [rsp]
    577b:	call   5780 <botlish_fn_52+0x148>
			577c: R_X86_64_PLT32	rt_list_get-0x4
    5780:	test   rax,rax
    5783:	jne    5792 <botlish_fn_52+0x15a>
    5789:	mov    rdi,QWORD PTR [rsp]
    578d:	jmp    5885 <botlish_fn_52+0x24d>
    5792:	mov    rdx,rax
    5795:	jmp    57a2 <botlish_fn_52+0x16a>
    579a:	mov    rax,QWORD PTR [r13+0x10]
    579e:	mov    rdx,QWORD PTR [rax+rcx*8]
    57a2:	mov    QWORD PTR [r15+0x20],rdx
    57a6:	mov    QWORD PTR [rsp+0x10],rdx
    57ab:	xor    r11d,r11d
    57ae:	mov    rcx,QWORD PTR [rsp+0x8]
    57b3:	test   rcx,0x7
    57ba:	je     57ca <botlish_fn_52+0x192>
    57c0:	mov    QWORD PTR [rsp+0x8],rcx
    57c5:	jmp    57d9 <botlish_fn_52+0x1a1>
    57ca:	movzx  rax,BYTE PTR [rcx]
    57ce:	mov    QWORD PTR [rsp+0x8],rcx
    57d3:	cmp    al,0x3
    57d5:	sete   r11b
    57d9:	test   r11b,r11b
    57dc:	jne    5806 <botlish_fn_52+0x1ce>
    57e2:	mov    rdi,QWORD PTR [rsp]
    57e6:	mov    rax,QWORD PTR [rdi+0x10]
    57ea:	mov    rcx,QWORD PTR [rax+0x50]
    57ee:	mov    edx,0x4
    57f3:	mov    rsi,QWORD PTR [rsp+0x8]
    57f8:	call   57fd <botlish_fn_52+0x1c5>
			57f9: R_X86_64_PLT32	rt_type_error-0x4
    57fd:	mov    rdi,QWORD PTR [rsp]
    5801:	jmp    5885 <botlish_fn_52+0x24d>
    5806:	test   r12,0x1
    580d:	je     582b <botlish_fn_52+0x1f3>
    5813:	mov    rsi,QWORD PTR [rsp+0x8]
    5818:	mov    rcx,QWORD PTR [rsi+0x8]
    581c:	mov    rax,r12
    581f:	sar    rax,1
    5822:	cmp    rax,rcx
    5825:	jb     5856 <botlish_fn_52+0x21e>
    582b:	mov    rdx,r12
    582e:	mov    rsi,QWORD PTR [rsp+0x8]
    5833:	mov    rdi,QWORD PTR [rsp]
    5837:	call   583c <botlish_fn_52+0x204>
			5838: R_X86_64_PLT32	rt_list_get-0x4
    583c:	test   rax,rax
    583f:	jne    584e <botlish_fn_52+0x216>
    5845:	mov    rdi,QWORD PTR [rsp]
    5849:	jmp    5885 <botlish_fn_52+0x24d>
    584e:	mov    rcx,rax
    5851:	jmp    5863 <botlish_fn_52+0x22b>
    5856:	mov    rsi,QWORD PTR [rsp+0x8]
    585b:	mov    rcx,QWORD PTR [rsi+0x10]
    585f:	mov    rcx,QWORD PTR [rcx+rax*8]
    5863:	mov    QWORD PTR [r15+0x28],rcx
    5867:	mov    rdx,QWORD PTR [rsp+0x10]
    586c:	mov    rsi,r14
    586f:	mov    rdi,QWORD PTR [rsp]
    5873:	call   5878 <botlish_fn_52+0x240>
			5874: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    5878:	test   rax,rax
    587b:	jne    58b1 <botlish_fn_52+0x279>
    5881:	mov    rdi,QWORD PTR [rsp]
    5885:	mov    rdi,QWORD PTR [rsp]
    5889:	mov    QWORD PTR [rdi],r15
    588c:	xor    rax,rax
    588f:	mov    rbx,QWORD PTR [rsp+0x20]
    5894:	mov    r12,QWORD PTR [rsp+0x28]
    5899:	mov    r13,QWORD PTR [rsp+0x30]
    589e:	mov    r14,QWORD PTR [rsp+0x38]
    58a3:	mov    r15,QWORD PTR [rsp+0x40]
    58a8:	add    rsp,0x50
    58ac:	mov    rsp,rbp
    58af:	pop    rbp
    58b0:	ret
    58b1:	mov    QWORD PTR [r15],r14
    58b4:	mov    QWORD PTR [r15+0x8],r13
    58b8:	mov    rsi,QWORD PTR [rsp+0x8]
    58bd:	mov    QWORD PTR [r15+0x10],rsi
    58c1:	sar    r12,1
    58c4:	add    r12,0x1
    58cb:	shl    r12,1
    58ce:	or     r12,0x1
    58d2:	mov    QWORD PTR [r15+0x18],r12
    58d6:	mov    r8,r12
    58d9:	jmp    5698 <botlish_fn_52+0x60>
    58de:	mov    rdi,QWORD PTR [rsp]
    58e2:	mov    QWORD PTR [rdi],r15
    58e5:	mov    rax,r14
    58e8:	mov    rbx,QWORD PTR [rsp+0x20]
    58ed:	mov    r12,QWORD PTR [rsp+0x28]
    58f2:	mov    r13,QWORD PTR [rsp+0x30]
    58f7:	mov    r14,QWORD PTR [rsp+0x38]
    58fc:	mov    r15,QWORD PTR [rsp+0x40]
    5901:	add    rsp,0x50
    5905:	mov    rsp,rbp
    5908:	pop    rbp
    5909:	ret
    590a:	mov    QWORD PTR [rsp],rdi
    590e:	call   5913 <botlish_fn_52+0x2db>
			590f: R_X86_64_PLT32	rt_stack_overflow-0x4
    5913:	xor    rax,rax
    5916:	mov    rbx,QWORD PTR [rsp+0x20]
    591b:	mov    r12,QWORD PTR [rsp+0x28]
    5920:	mov    r13,QWORD PTR [rsp+0x30]
    5925:	mov    r14,QWORD PTR [rsp+0x38]
    592a:	mov    r15,QWORD PTR [rsp+0x40]
    592f:	add    rsp,0x50
    5933:	mov    rsp,rbp
    5936:	pop    rbp
    5937:	ret
    5938:	(bad)
    5939:	add    BYTE PTR [rax],al
    593b:	add    BYTE PTR [rax],al
    593d:	add    BYTE PTR [rax],al
	...

0000000000005940 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    5940:	push   rbp
    5941:	mov    rbp,rsp
    5944:	mov    rsi,QWORD PTR [rdx]
    5947:	mov    r10,QWORD PTR [rdx+0x8]
    594b:	mov    rcx,QWORD PTR [rdx+0x10]
    594f:	mov    r8,QWORD PTR [rdx+0x18]
    5953:	mov    r9,QWORD PTR [rdx+0x20]
    5957:	mov    rdx,r10
    595a:	call   595f <botlish_entry_52+0x1f>
			595b: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    595f:	mov    rsp,rbp
    5962:	pop    rbp
    5963:	ret

0000000000005964 <botlish_fn_53: row_table<any, int, any, bool>>:
    5964:	push   rbp
    5965:	mov    rbp,rsp
    5968:	sub    rsp,0x30
    596c:	mov    QWORD PTR [rsp],rbx
    5970:	mov    QWORD PTR [rsp+0x8],r12
    5975:	mov    QWORD PTR [rsp+0x10],r13
    597a:	mov    QWORD PTR [rsp+0x18],r14
    597f:	mov    QWORD PTR [rsp+0x20],r15
    5984:	mov    rbx,QWORD PTR [rdi]
    5987:	mov    rax,QWORD PTR [rdi+0x8]
    598b:	lea    r9,[rbx+0x28]
    598f:	cmp    r9,rax
    5992:	ja     5abe <botlish_fn_53+0x15a>
    5998:	lea    rax,[rbx+0x28]
    599c:	mov    QWORD PTR [rdi],rax
    599f:	mov    r12,rdi
    59a2:	mov    QWORD PTR [rbx+0x20],0x0
    59aa:	mov    QWORD PTR [rbx],rsi
    59ad:	mov    r14,rsi
    59b0:	mov    QWORD PTR [rbx+0x8],rdx
    59b4:	mov    QWORD PTR [rbx+0x10],rcx
    59b8:	mov    r13,rcx
    59bb:	mov    QWORD PTR [rbx+0x18],r8
    59bf:	mov    rsi,r8
    59c2:	mov    rdi,r12
    59c5:	call   59ca <botlish_fn_53+0x66>
			59c6: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    59ca:	test   rax,rax
    59cd:	jne    59db <botlish_fn_53+0x77>
    59d3:	mov    rdi,r12
    59d6:	jmp    5a6d <botlish_fn_53+0x109>
    59db:	mov    QWORD PTR [rbx+0x8],rax
    59df:	mov    r15,rax
    59e2:	mov    QWORD PTR [rbx+0x18],0x1
    59ea:	xor    ecx,ecx
    59ec:	mov    rdx,r13
    59ef:	test   rdx,0x7
    59f6:	je     5a04 <botlish_fn_53+0xa0>
    59fc:	mov    r13,rdx
    59ff:	jmp    5a10 <botlish_fn_53+0xac>
    5a04:	movzx  rax,BYTE PTR [rdx]
    5a08:	mov    r13,rdx
    5a0b:	cmp    al,0x3
    5a0d:	sete   cl
    5a10:	test   cl,cl
    5a12:	jne    5a38 <botlish_fn_53+0xd4>
    5a18:	mov    rdi,r12
    5a1b:	mov    rax,QWORD PTR [rdi+0x10]
    5a1f:	mov    rcx,QWORD PTR [rax+0x58]
    5a23:	mov    edx,0x4
    5a28:	mov    rsi,r13
    5a2b:	call   5a30 <botlish_fn_53+0xcc>
			5a2c: R_X86_64_PLT32	rt_type_error-0x4
    5a30:	mov    rdi,r12
    5a33:	jmp    5a6d <botlish_fn_53+0x109>
    5a38:	mov    rsi,r13
    5a3b:	mov    rdi,r12
    5a3e:	call   5a43 <botlish_fn_53+0xdf>
			5a3f: R_X86_64_PLT32	rt_list_len-0x4
    5a43:	mov    QWORD PTR [rbx+0x20],rax
    5a47:	mov    r8d,0x1
    5a4d:	mov    rcx,r13
    5a50:	mov    rdx,r14
    5a53:	mov    rsi,r15
    5a56:	mov    r9,rax
    5a59:	mov    rdi,r12
    5a5c:	call   5a61 <botlish_fn_53+0xfd>
			5a5d: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    5a61:	test   rax,rax
    5a64:	jne    5a97 <botlish_fn_53+0x133>
    5a6a:	mov    rdi,r12
    5a6d:	mov    rdi,r12
    5a70:	mov    QWORD PTR [rdi],rbx
    5a73:	xor    rax,rax
    5a76:	mov    rbx,QWORD PTR [rsp]
    5a7a:	mov    r12,QWORD PTR [rsp+0x8]
    5a7f:	mov    r13,QWORD PTR [rsp+0x10]
    5a84:	mov    r14,QWORD PTR [rsp+0x18]
    5a89:	mov    r15,QWORD PTR [rsp+0x20]
    5a8e:	add    rsp,0x30
    5a92:	mov    rsp,rbp
    5a95:	pop    rbp
    5a96:	ret
    5a97:	mov    rdi,r12
    5a9a:	mov    QWORD PTR [rdi],rbx
    5a9d:	mov    rbx,QWORD PTR [rsp]
    5aa1:	mov    r12,QWORD PTR [rsp+0x8]
    5aa6:	mov    r13,QWORD PTR [rsp+0x10]
    5aab:	mov    r14,QWORD PTR [rsp+0x18]
    5ab0:	mov    r15,QWORD PTR [rsp+0x20]
    5ab5:	add    rsp,0x30
    5ab9:	mov    rsp,rbp
    5abc:	pop    rbp
    5abd:	ret
    5abe:	mov    r12,rdi
    5ac1:	call   5ac6 <botlish_fn_53+0x162>
			5ac2: R_X86_64_PLT32	rt_stack_overflow-0x4
    5ac6:	xor    rax,rax
    5ac9:	mov    rbx,QWORD PTR [rsp]
    5acd:	mov    r12,QWORD PTR [rsp+0x8]
    5ad2:	mov    r13,QWORD PTR [rsp+0x10]
    5ad7:	mov    r14,QWORD PTR [rsp+0x18]
    5adc:	mov    r15,QWORD PTR [rsp+0x20]
    5ae1:	add    rsp,0x30
    5ae5:	mov    rsp,rbp
    5ae8:	pop    rbp
    5ae9:	ret

0000000000005aea <botlish_entry_53: row_table<any, int, any, bool>>:
    5aea:	push   rbp
    5aeb:	mov    rbp,rsp
    5aee:	mov    rsi,QWORD PTR [rdx]
    5af1:	mov    r9,QWORD PTR [rdx+0x8]
    5af5:	mov    rcx,QWORD PTR [rdx+0x10]
    5af9:	mov    r8,QWORD PTR [rdx+0x18]
    5afd:	mov    rdx,r9
    5b00:	call   5b05 <botlish_entry_53+0x1b>
			5b01: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    5b05:	mov    rsp,rbp
    5b08:	pop    rbp
    5b09:	ret
    5b0a:	add    BYTE PTR [rax],al
    5b0c:	add    BYTE PTR [rax],al
	...

0000000000005b10 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    5b10:	push   rbp
    5b11:	mov    rbp,rsp
    5b14:	sub    rsp,0x50
    5b18:	mov    QWORD PTR [rsp+0x20],rbx
    5b1d:	mov    QWORD PTR [rsp+0x28],r12
    5b22:	mov    QWORD PTR [rsp+0x30],r13
    5b27:	mov    QWORD PTR [rsp+0x38],r14
    5b2c:	mov    QWORD PTR [rsp+0x40],r15
    5b31:	mov    QWORD PTR [rsp+0x8],r8
    5b36:	mov    r11,QWORD PTR [rbp+0x10]
    5b3a:	mov    r12,QWORD PTR [rbp+0x18]
    5b3e:	mov    r15,r12
    5b41:	mov    r12,QWORD PTR [rdi]
    5b44:	mov    rax,QWORD PTR [rdi+0x8]
    5b48:	lea    r8,[r12+0x40]
    5b4d:	cmp    r8,rax
    5b50:	ja     5d8e <botlish_fn_54+0x27e>
    5b56:	lea    rax,[r12+0x40]
    5b5b:	mov    QWORD PTR [rdi],rax
    5b5e:	mov    QWORD PTR [rsp],rdi
    5b62:	mov    QWORD PTR [r12+0x30],0x0
    5b6b:	mov    QWORD PTR [r12+0x38],0x0
    5b74:	mov    QWORD PTR [r12],rsi
    5b78:	mov    QWORD PTR [r12+0x8],rdx
    5b7d:	mov    rbx,rdx
    5b80:	mov    QWORD PTR [r12+0x10],rcx
    5b85:	mov    r14,rcx
    5b88:	mov    QWORD PTR [r12+0x18],r9
    5b8d:	mov    QWORD PTR [r12+0x20],r11
    5b92:	mov    rax,r15
    5b95:	mov    QWORD PTR [rsp+0x18],r11
    5b9a:	mov    QWORD PTR [r12+0x28],rax
    5b9f:	mov    r13,rsi
    5ba2:	mov    QWORD PTR [rsp+0x10],r9
    5ba7:	mov    rsi,r13
    5baa:	mov    rdi,QWORD PTR [rsp]
    5bae:	call   5bb3 <botlish_fn_54+0xa3>
			5baf: R_X86_64_PLT32	rt_list_len-0x4
    5bb3:	mov    rcx,rbx
    5bb6:	and    rcx,rax
    5bb9:	mov    rdx,rax
    5bbc:	test   rcx,0x1
    5bc3:	jne    5bea <botlish_fn_54+0xda>
    5bc9:	mov    rsi,rbx
    5bcc:	mov    rdi,QWORD PTR [rsp]
    5bd0:	call   5bd5 <botlish_fn_54+0xc5>
			5bd1: R_X86_64_PLT32	rt_int_cmp-0x4
    5bd5:	mov    ecx,0x2
    5bda:	test   rax,rax
    5bdd:	cmovge rcx,QWORD PTR [rip+0x1db]        # 5dc0 <botlish_fn_54+0x2b0>
    5be5:	jmp    5bfa <botlish_fn_54+0xea>
    5bea:	mov    ecx,0x2
    5bef:	cmp    rbx,rdx
    5bf2:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 5dc0 <botlish_fn_54+0x2b0>
    5bfa:	cmp    rcx,0x6
    5bfe:	je     5d19 <botlish_fn_54+0x209>
    5c04:	mov    rcx,QWORD PTR [rsp+0x8]
    5c09:	mov    rsi,rcx
    5c0c:	or     rsi,0x1
    5c10:	mov    QWORD PTR [r12+0x30],rsi
    5c15:	test   rbx,0x1
    5c1c:	je     5c35 <botlish_fn_54+0x125>
    5c22:	mov    r9,QWORD PTR [r13+0x8]
    5c26:	mov    r8,rbx
    5c29:	sar    r8,1
    5c2c:	cmp    r8,r9
    5c2f:	jb     5c5e <botlish_fn_54+0x14e>
    5c35:	mov    rdx,rbx
    5c38:	mov    rsi,r13
    5c3b:	mov    rdi,QWORD PTR [rsp]
    5c3f:	call   5c44 <botlish_fn_54+0x134>
			5c40: R_X86_64_PLT32	rt_list_get-0x4
    5c44:	test   rax,rax
    5c47:	jne    5c56 <botlish_fn_54+0x146>
    5c4d:	mov    rdi,QWORD PTR [rsp]
    5c51:	jmp    5d39 <botlish_fn_54+0x229>
    5c56:	mov    rcx,rax
    5c59:	jmp    5c66 <botlish_fn_54+0x156>
    5c5e:	mov    rax,QWORD PTR [r13+0x10]
    5c62:	mov    rcx,QWORD PTR [rax+r8*8]
    5c66:	mov    QWORD PTR [r12+0x38],rcx
    5c6b:	mov    rax,QWORD PTR [rsp+0x8]
    5c70:	mov    rdx,rax
    5c73:	or     rdx,0x1
    5c77:	mov    rax,r14
    5c7a:	mov    r14,r15
    5c7d:	mov    r15,rax
    5c80:	mov    rsi,r15
    5c83:	mov    rdi,QWORD PTR [rsp]
    5c87:	mov    r8,r14
    5c8a:	call   5c8f <botlish_fn_54+0x17f>
			5c8b: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    5c8f:	test   rax,rax
    5c92:	jne    5ca1 <botlish_fn_54+0x191>
    5c98:	mov    rdi,QWORD PTR [rsp]
    5c9c:	jmp    5d39 <botlish_fn_54+0x229>
    5ca1:	mov    QWORD PTR [r12+0x8],rax
    5ca6:	mov    rcx,rax
    5ca9:	sar    rbx,1
    5cac:	add    rbx,0x1
    5cb3:	shl    rbx,1
    5cb6:	or     rbx,0x1
    5cba:	mov    QWORD PTR [r12+0x30],rbx
    5cbf:	mov    rdx,QWORD PTR [rsp+0x18]
    5cc4:	mov    rsi,QWORD PTR [rsp+0x10]
    5cc9:	mov    rdi,QWORD PTR [rsp]
    5ccd:	call   5cd2 <botlish_fn_54+0x1c2>
			5cce: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    5cd2:	test   rax,rax
    5cd5:	jne    5ce4 <botlish_fn_54+0x1d4>
    5cdb:	mov    rdi,QWORD PTR [rsp]
    5cdf:	jmp    5d39 <botlish_fn_54+0x229>
    5ce4:	mov    QWORD PTR [r12],r13
    5ce8:	mov    QWORD PTR [r12+0x8],rbx
    5ced:	mov    QWORD PTR [r12+0x10],r15
    5cf2:	mov    QWORD PTR [r12+0x18],rax
    5cf7:	mov    QWORD PTR [r12+0x20],rdx
    5cfc:	mov    QWORD PTR [r12+0x28],r14
    5d01:	mov    QWORD PTR [rsp+0x18],rdx
    5d06:	mov    QWORD PTR [rsp+0x10],rax
    5d0b:	mov    rcx,r14
    5d0e:	mov    r14,r15
    5d11:	mov    r15,rcx
    5d14:	jmp    5ba7 <botlish_fn_54+0x97>
    5d19:	mov    rdx,QWORD PTR [rsp+0x18]
    5d1e:	mov    rsi,QWORD PTR [rsp+0x10]
    5d23:	mov    rdi,QWORD PTR [rsp]
    5d27:	call   5d2c <botlish_fn_54+0x21c>
			5d28: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    5d2c:	test   rax,rax
    5d2f:	jne    5d65 <botlish_fn_54+0x255>
    5d35:	mov    rdi,QWORD PTR [rsp]
    5d39:	mov    rdi,QWORD PTR [rsp]
    5d3d:	mov    QWORD PTR [rdi],r12
    5d40:	xor    rax,rax
    5d43:	mov    rbx,QWORD PTR [rsp+0x20]
    5d48:	mov    r12,QWORD PTR [rsp+0x28]
    5d4d:	mov    r13,QWORD PTR [rsp+0x30]
    5d52:	mov    r14,QWORD PTR [rsp+0x38]
    5d57:	mov    r15,QWORD PTR [rsp+0x40]
    5d5c:	add    rsp,0x50
    5d60:	mov    rsp,rbp
    5d63:	pop    rbp
    5d64:	ret
    5d65:	mov    rdi,QWORD PTR [rsp]
    5d69:	mov    QWORD PTR [rdi],r12
    5d6c:	mov    rbx,QWORD PTR [rsp+0x20]
    5d71:	mov    r12,QWORD PTR [rsp+0x28]
    5d76:	mov    r13,QWORD PTR [rsp+0x30]
    5d7b:	mov    r14,QWORD PTR [rsp+0x38]
    5d80:	mov    r15,QWORD PTR [rsp+0x40]
    5d85:	add    rsp,0x50
    5d89:	mov    rsp,rbp
    5d8c:	pop    rbp
    5d8d:	ret
    5d8e:	mov    QWORD PTR [rsp],rdi
    5d92:	call   5d97 <botlish_fn_54+0x287>
			5d93: R_X86_64_PLT32	rt_stack_overflow-0x4
    5d97:	xor    rax,rax
    5d9a:	mov    rbx,QWORD PTR [rsp+0x20]
    5d9f:	mov    r12,QWORD PTR [rsp+0x28]
    5da4:	mov    r13,QWORD PTR [rsp+0x30]
    5da9:	mov    r14,QWORD PTR [rsp+0x38]
    5dae:	mov    r15,QWORD PTR [rsp+0x40]
    5db3:	add    rsp,0x50
    5db7:	mov    rsp,rbp
    5dba:	pop    rbp
    5dbb:	ret
    5dbc:	add    BYTE PTR [rax],al
    5dbe:	add    BYTE PTR [rax],al
    5dc0:	(bad)
    5dc1:	add    BYTE PTR [rax],al
    5dc3:	add    BYTE PTR [rax],al
    5dc5:	add    BYTE PTR [rax],al
	...

0000000000005dc8 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    5dc8:	push   rbp
    5dc9:	mov    rbp,rsp
    5dcc:	sub    rsp,0x10
    5dd0:	mov    rsi,QWORD PTR [rdx]
    5dd3:	mov    r10,QWORD PTR [rdx+0x8]
    5dd7:	mov    rcx,QWORD PTR [rdx+0x10]
    5ddb:	mov    r8,QWORD PTR [rdx+0x18]
    5ddf:	mov    r9,QWORD PTR [rdx+0x20]
    5de3:	mov    r11,QWORD PTR [rdx+0x28]
    5de7:	mov    rax,QWORD PTR [rdx+0x30]
    5deb:	mov    QWORD PTR [rsp],r11
    5def:	mov    QWORD PTR [rsp+0x8],rax
    5df4:	mov    rdx,r10
    5df7:	call   5dfc <botlish_entry_54+0x34>
			5df8: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    5dfc:	add    rsp,0x10
    5e00:	mov    rsp,rbp
    5e03:	pop    rbp
    5e04:	ret

0000000000005e05 <botlish_fn_55: csv_records_generic<str, bool>>:
    5e05:	push   rbp
    5e06:	mov    rbp,rsp
    5e09:	sub    rsp,0x50
    5e0d:	mov    QWORD PTR [rsp+0x20],rbx
    5e12:	mov    QWORD PTR [rsp+0x28],r12
    5e17:	mov    QWORD PTR [rsp+0x30],r13
    5e1c:	mov    QWORD PTR [rsp+0x38],r14
    5e21:	mov    QWORD PTR [rsp+0x40],r15
    5e26:	mov    rbx,QWORD PTR [rdi]
    5e29:	mov    rax,QWORD PTR [rdi+0x8]
    5e2d:	lea    rcx,[rbx+0x38]
    5e31:	cmp    rcx,rax
    5e34:	ja     6048 <botlish_fn_55+0x243>
    5e3a:	lea    rax,[rbx+0x38]
    5e3e:	mov    QWORD PTR [rdi],rax
    5e41:	mov    r12,rdi
    5e44:	mov    QWORD PTR [rbx+0x10],0x0
    5e4c:	mov    QWORD PTR [rbx+0x18],0x0
    5e54:	mov    QWORD PTR [rbx+0x20],0x0
    5e5c:	mov    QWORD PTR [rbx+0x28],0x0
    5e64:	mov    QWORD PTR [rbx+0x30],0x0
    5e6c:	mov    QWORD PTR [rbx],rsi
    5e6f:	mov    QWORD PTR [rbx+0x8],rdx
    5e73:	mov    r13,rdx
    5e76:	mov    rdi,r12
    5e79:	call   5e7e <botlish_fn_55+0x79>
			5e7a: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    5e7e:	mov    rcx,rax
    5e81:	mov    r14,rax
    5e84:	test   rax,rcx
    5e87:	jne    5e95 <botlish_fn_55+0x90>
    5e8d:	mov    rdi,r12
    5e90:	jmp    5ff5 <botlish_fn_55+0x1f0>
    5e95:	mov    rax,r14
    5e98:	mov    QWORD PTR [rbx],rax
    5e9b:	mov    rsi,r14
    5e9e:	mov    rdi,r12
    5ea1:	call   5ea6 <botlish_fn_55+0xa1>
			5ea2: R_X86_64_PLT32	rt_list_len-0x4
    5ea6:	sar    rax,1
    5ea9:	test   rax,rax
    5eac:	je     5fdb <botlish_fn_55+0x1d6>
    5eb2:	mov    rax,r14
    5eb5:	mov    rax,QWORD PTR [rax+0x8]
    5eb9:	test   rax,rax
    5ebc:	jne    5eeb <botlish_fn_55+0xe6>
    5ec2:	mov    edx,0x1
    5ec7:	mov    rsi,r14
    5eca:	mov    rdi,r12
    5ecd:	call   5ed2 <botlish_fn_55+0xcd>
			5ece: R_X86_64_PLT32	rt_list_get-0x4
    5ed2:	test   rax,rax
    5ed5:	jne    5ee3 <botlish_fn_55+0xde>
    5edb:	mov    rdi,r12
    5ede:	jmp    5ff5 <botlish_fn_55+0x1f0>
    5ee3:	mov    rsi,rax
    5ee6:	jmp    5ef8 <botlish_fn_55+0xf3>
    5eeb:	mov    rax,r14
    5eee:	mov    rcx,QWORD PTR [rax+0x10]
    5ef2:	mov    rax,QWORD PTR [rcx]
    5ef5:	mov    rsi,rax
    5ef8:	mov    QWORD PTR [rbx+0x10],rsi
    5efc:	mov    QWORD PTR [rbx+0x18],0x3
    5f04:	xor    eax,eax
    5f06:	test   rsi,0x7
    5f0d:	jne    5f1e <botlish_fn_55+0x119>
    5f13:	movzx  rdi,BYTE PTR [rsi]
    5f17:	cmp    dil,0x3
    5f1b:	sete   al
    5f1e:	test   al,al
    5f20:	jne    5f43 <botlish_fn_55+0x13e>
    5f26:	mov    rdi,r12
    5f29:	mov    r10,QWORD PTR [rdi+0x10]
    5f2d:	mov    rcx,QWORD PTR [r10+0x58]
    5f31:	mov    edx,0x4
    5f36:	call   5f3b <botlish_fn_55+0x136>
			5f37: R_X86_64_PLT32	rt_type_error-0x4
    5f3b:	mov    rdi,r12
    5f3e:	jmp    5ff5 <botlish_fn_55+0x1f0>
    5f43:	mov    r15,rsi
    5f46:	mov    rdi,r12
    5f49:	call   5f4e <botlish_fn_55+0x149>
			5f4a: R_X86_64_PLT32	rt_list_len-0x4
    5f4e:	mov    QWORD PTR [rbx+0x20],rax
    5f52:	mov    QWORD PTR [rsp+0x10],rax
    5f57:	mov    rdi,r12
    5f5a:	call   5f5f <botlish_fn_55+0x15a>
			5f5b: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    5f5f:	test   rax,rax
    5f62:	jne    5f70 <botlish_fn_55+0x16b>
    5f68:	mov    rdi,r12
    5f6b:	jmp    5ff5 <botlish_fn_55+0x1f0>
    5f70:	mov    QWORD PTR [rbx+0x28],rax
    5f74:	mov    r9,rax
    5f77:	mov    QWORD PTR [rbx+0x30],rdx
    5f7b:	mov    rsi,rdx
    5f7e:	mov    edx,0x3
    5f83:	mov    QWORD PTR [rsp],rsi
    5f87:	mov    rax,r13
    5f8a:	mov    QWORD PTR [rsp+0x8],rax
    5f8f:	mov    rcx,r15
    5f92:	mov    rsi,r14
    5f95:	mov    r8,QWORD PTR [rsp+0x10]
    5f9a:	mov    rdi,r12
    5f9d:	call   5fa2 <botlish_fn_55+0x19d>
			5f9e: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    5fa2:	test   rax,rax
    5fa5:	jne    5fb3 <botlish_fn_55+0x1ae>
    5fab:	mov    rdi,r12
    5fae:	jmp    5ff5 <botlish_fn_55+0x1f0>
    5fb3:	mov    rdi,r12
    5fb6:	mov    QWORD PTR [rdi],rbx
    5fb9:	mov    rbx,QWORD PTR [rsp+0x20]
    5fbe:	mov    r12,QWORD PTR [rsp+0x28]
    5fc3:	mov    r13,QWORD PTR [rsp+0x30]
    5fc8:	mov    r14,QWORD PTR [rsp+0x38]
    5fcd:	mov    r15,QWORD PTR [rsp+0x40]
    5fd2:	add    rsp,0x50
    5fd6:	mov    rsp,rbp
    5fd9:	pop    rbp
    5fda:	ret
    5fdb:	xor    rdx,rdx
    5fde:	mov    rdi,r12
    5fe1:	mov    rsi,rdx
    5fe4:	call   5fe9 <botlish_fn_55+0x1e4>
			5fe5: R_X86_64_PLT32	rt_list_new-0x4
    5fe9:	test   rax,rax
    5fec:	jne    6020 <botlish_fn_55+0x21b>
    5ff2:	mov    rdi,r12
    5ff5:	mov    rdi,r12
    5ff8:	mov    QWORD PTR [rdi],rbx
    5ffb:	xor    rax,rax
    5ffe:	mov    rbx,QWORD PTR [rsp+0x20]
    6003:	mov    r12,QWORD PTR [rsp+0x28]
    6008:	mov    r13,QWORD PTR [rsp+0x30]
    600d:	mov    r14,QWORD PTR [rsp+0x38]
    6012:	mov    r15,QWORD PTR [rsp+0x40]
    6017:	add    rsp,0x50
    601b:	mov    rsp,rbp
    601e:	pop    rbp
    601f:	ret
    6020:	mov    rdi,r12
    6023:	mov    QWORD PTR [rdi],rbx
    6026:	mov    rbx,QWORD PTR [rsp+0x20]
    602b:	mov    r12,QWORD PTR [rsp+0x28]
    6030:	mov    r13,QWORD PTR [rsp+0x30]
    6035:	mov    r14,QWORD PTR [rsp+0x38]
    603a:	mov    r15,QWORD PTR [rsp+0x40]
    603f:	add    rsp,0x50
    6043:	mov    rsp,rbp
    6046:	pop    rbp
    6047:	ret
    6048:	mov    r12,rdi
    604b:	call   6050 <botlish_fn_55+0x24b>
			604c: R_X86_64_PLT32	rt_stack_overflow-0x4
    6050:	xor    rax,rax
    6053:	mov    rbx,QWORD PTR [rsp+0x20]
    6058:	mov    r12,QWORD PTR [rsp+0x28]
    605d:	mov    r13,QWORD PTR [rsp+0x30]
    6062:	mov    r14,QWORD PTR [rsp+0x38]
    6067:	mov    r15,QWORD PTR [rsp+0x40]
    606c:	add    rsp,0x50
    6070:	mov    rsp,rbp
    6073:	pop    rbp
    6074:	ret

0000000000006075 <botlish_entry_55: csv_records_generic<str, bool>>:
    6075:	push   rbp
    6076:	mov    rbp,rsp
    6079:	mov    rsi,QWORD PTR [rdx]
    607c:	mov    rdx,QWORD PTR [rdx+0x8]
    6080:	call   6085 <botlish_entry_55+0x10>
			6081: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6085:	mov    rsp,rbp
    6088:	pop    rbp
    6089:	ret

000000000000608a <botlish_fn_56: csv_records<str>>:
    608a:	push   rbp
    608b:	mov    rbp,rsp
    608e:	sub    rsp,0x10
    6092:	mov    QWORD PTR [rsp],r13
    6096:	mov    QWORD PTR [rsp+0x8],r14
    609b:	mov    r13,QWORD PTR [rdi]
    609e:	mov    rax,QWORD PTR [rdi+0x8]
    60a2:	lea    rcx,[r13+0x10]
    60a6:	cmp    rcx,rax
    60a9:	ja     610e <botlish_fn_56+0x84>
    60af:	lea    rax,[r13+0x10]
    60b3:	mov    QWORD PTR [rdi],rax
    60b6:	mov    r14,rdi
    60b9:	mov    QWORD PTR [r13+0x0],rsi
    60bd:	mov    edx,0x2
    60c2:	mov    QWORD PTR [r13+0x8],0x2
    60ca:	mov    rdi,r14
    60cd:	call   60d2 <botlish_fn_56+0x48>
			60ce: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    60d2:	test   rax,rax
    60d5:	jne    60f6 <botlish_fn_56+0x6c>
    60db:	mov    rdi,r14
    60de:	mov    QWORD PTR [rdi],r13
    60e1:	xor    rax,rax
    60e4:	mov    r13,QWORD PTR [rsp]
    60e8:	mov    r14,QWORD PTR [rsp+0x8]
    60ed:	add    rsp,0x10
    60f1:	mov    rsp,rbp
    60f4:	pop    rbp
    60f5:	ret
    60f6:	mov    rdi,r14
    60f9:	mov    QWORD PTR [rdi],r13
    60fc:	mov    r13,QWORD PTR [rsp]
    6100:	mov    r14,QWORD PTR [rsp+0x8]
    6105:	add    rsp,0x10
    6109:	mov    rsp,rbp
    610c:	pop    rbp
    610d:	ret
    610e:	call   6113 <botlish_fn_56+0x89>
			610f: R_X86_64_PLT32	rt_stack_overflow-0x4
    6113:	xor    rax,rax
    6116:	mov    r13,QWORD PTR [rsp]
    611a:	mov    r14,QWORD PTR [rsp+0x8]
    611f:	add    rsp,0x10
    6123:	mov    rsp,rbp
    6126:	pop    rbp
    6127:	ret

0000000000006128 <botlish_entry_56: csv_records<str>>:
    6128:	push   rbp
    6129:	mov    rbp,rsp
    612c:	mov    rsi,QWORD PTR [rdx]
    612f:	call   6134 <botlish_entry_56+0xc>
			6130: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6134:	mov    rsp,rbp
    6137:	pop    rbp
    6138:	ret

0000000000006139 <botlish_fn_57: csv_records_presized<str>>:
    6139:	push   rbp
    613a:	mov    rbp,rsp
    613d:	sub    rsp,0x10
    6141:	mov    QWORD PTR [rsp],r13
    6145:	mov    QWORD PTR [rsp+0x8],r14
    614a:	mov    r13,QWORD PTR [rdi]
    614d:	mov    rax,QWORD PTR [rdi+0x8]
    6151:	lea    rcx,[r13+0x10]
    6155:	cmp    rcx,rax
    6158:	ja     61bd <botlish_fn_57+0x84>
    615e:	lea    rax,[r13+0x10]
    6162:	mov    QWORD PTR [rdi],rax
    6165:	mov    r14,rdi
    6168:	mov    QWORD PTR [r13+0x0],rsi
    616c:	mov    edx,0x6
    6171:	mov    QWORD PTR [r13+0x8],0x6
    6179:	mov    rdi,r14
    617c:	call   6181 <botlish_fn_57+0x48>
			617d: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6181:	test   rax,rax
    6184:	jne    61a5 <botlish_fn_57+0x6c>
    618a:	mov    rdi,r14
    618d:	mov    QWORD PTR [rdi],r13
    6190:	xor    rax,rax
    6193:	mov    r13,QWORD PTR [rsp]
    6197:	mov    r14,QWORD PTR [rsp+0x8]
    619c:	add    rsp,0x10
    61a0:	mov    rsp,rbp
    61a3:	pop    rbp
    61a4:	ret
    61a5:	mov    rdi,r14
    61a8:	mov    QWORD PTR [rdi],r13
    61ab:	mov    r13,QWORD PTR [rsp]
    61af:	mov    r14,QWORD PTR [rsp+0x8]
    61b4:	add    rsp,0x10
    61b8:	mov    rsp,rbp
    61bb:	pop    rbp
    61bc:	ret
    61bd:	call   61c2 <botlish_fn_57+0x89>
			61be: R_X86_64_PLT32	rt_stack_overflow-0x4
    61c2:	xor    rax,rax
    61c5:	mov    r13,QWORD PTR [rsp]
    61c9:	mov    r14,QWORD PTR [rsp+0x8]
    61ce:	add    rsp,0x10
    61d2:	mov    rsp,rbp
    61d5:	pop    rbp
    61d6:	ret

00000000000061d7 <botlish_entry_57: csv_records_presized<str>>:
    61d7:	push   rbp
    61d8:	mov    rbp,rsp
    61db:	mov    rsi,QWORD PTR [rdx]
    61de:	call   61e3 <botlish_entry_57+0xc>
			61df: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    61e3:	mov    rsp,rbp
    61e6:	pop    rbp
    61e7:	ret

00000000000061e8 <botlish_fn_58: sample<generic>>:
    61e8:	push   rbp
    61e9:	mov    rbp,rsp
    61ec:	sub    rsp,0x90
    61f3:	mov    QWORD PTR [rsp+0x60],rbx
    61f8:	mov    QWORD PTR [rsp+0x68],r12
    61fd:	mov    QWORD PTR [rsp+0x70],r13
    6202:	mov    QWORD PTR [rsp+0x78],r14
    6207:	mov    QWORD PTR [rsp+0x80],r15
    620f:	mov    r14,QWORD PTR [rdi]
    6212:	mov    rax,QWORD PTR [rdi+0x8]
    6216:	lea    rcx,[r14+0x40]
    621a:	cmp    rcx,rax
    621d:	ja     66b5 <botlish_fn_58+0x4cd>
    6223:	lea    rax,[r14+0x40]
    6227:	mov    QWORD PTR [rdi],rax
    622a:	mov    QWORD PTR [r14+0x8],0x0
    6232:	mov    QWORD PTR [r14+0x10],0x0
    623a:	mov    QWORD PTR [r14+0x18],0x0
    6242:	mov    QWORD PTR [r14+0x20],0x0
    624a:	mov    QWORD PTR [r14+0x28],0x0
    6252:	mov    QWORD PTR [r14+0x30],0x0
    625a:	mov    QWORD PTR [r14+0x38],0x0
    6262:	mov    rax,QWORD PTR [rdi+0x10]
    6266:	mov    r15,rdi
    6269:	mov    rsi,QWORD PTR [rax+0x60]
    626d:	mov    QWORD PTR [r14],rsi
    6270:	call   6275 <botlish_fn_58+0x8d>
			6271: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6275:	mov    rcx,rax
    6278:	mov    r13,rax
    627b:	test   rax,rcx
    627e:	jne    628c <botlish_fn_58+0xa4>
    6284:	mov    rdi,r15
    6287:	jmp    6656 <botlish_fn_58+0x46e>
    628c:	mov    rax,r13
    628f:	mov    QWORD PTR [r14],rax
    6292:	mov    rdi,r15
    6295:	mov    rax,QWORD PTR [rdi+0x10]
    6299:	mov    rsi,QWORD PTR [rax+0x60]
    629d:	mov    QWORD PTR [r14+0x8],rsi
    62a1:	call   62a6 <botlish_fn_58+0xbe>
			62a2: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    62a6:	mov    r12,rax
    62a9:	test   r12,r12
    62ac:	jne    62ba <botlish_fn_58+0xd2>
    62b2:	mov    rdi,r15
    62b5:	jmp    6656 <botlish_fn_58+0x46e>
    62ba:	mov    rax,r13
    62bd:	mov    rax,QWORD PTR [rax+0x8]
    62c1:	test   rax,rax
    62c4:	jne    62f6 <botlish_fn_58+0x10e>
    62ca:	mov    edx,0x1
    62cf:	mov    rsi,r13
    62d2:	mov    rdi,r15
    62d5:	call   62da <botlish_fn_58+0xf2>
			62d6: R_X86_64_PLT32	rt_list_get-0x4
    62da:	test   rax,rax
    62dd:	jne    62eb <botlish_fn_58+0x103>
    62e3:	mov    rdi,r15
    62e6:	jmp    6656 <botlish_fn_58+0x46e>
    62eb:	mov    rbx,r13
    62ee:	mov    rsi,rax
    62f1:	jmp    6300 <botlish_fn_58+0x118>
    62f6:	mov    rbx,r13
    62f9:	mov    rax,QWORD PTR [rbx+0x10]
    62fd:	mov    rsi,QWORD PTR [rax]
    6300:	mov    QWORD PTR [r14+0x8],rsi
    6304:	mov    QWORD PTR [rsp+0x40],rsi
    6309:	mov    rax,QWORD PTR [rbx+0x8]
    630d:	cmp    rax,0x1
    6311:	ja     6343 <botlish_fn_58+0x15b>
    6317:	mov    edx,0x3
    631c:	mov    rsi,rbx
    631f:	mov    rdi,r15
    6322:	call   6327 <botlish_fn_58+0x13f>
			6323: R_X86_64_PLT32	rt_list_get-0x4
    6327:	test   rax,rax
    632a:	jne    6338 <botlish_fn_58+0x150>
    6330:	mov    rdi,r15
    6333:	jmp    6656 <botlish_fn_58+0x46e>
    6338:	mov    rsi,rax
    633b:	mov    r13,rbx
    633e:	jmp    634e <botlish_fn_58+0x166>
    6343:	mov    rax,QWORD PTR [rbx+0x10]
    6347:	mov    r13,rbx
    634a:	mov    rsi,QWORD PTR [rax+0x8]
    634e:	mov    QWORD PTR [r14+0x10],rsi
    6352:	mov    QWORD PTR [rsp+0x38],rsi
    6357:	mov    rax,QWORD PTR [r12+0x8]
    635c:	mov    rsi,r12
    635f:	test   rax,rax
    6362:	jne    638e <botlish_fn_58+0x1a6>
    6368:	mov    edx,0x1
    636d:	mov    rdi,r15
    6370:	call   6375 <botlish_fn_58+0x18d>
			6371: R_X86_64_PLT32	rt_list_get-0x4
    6375:	test   rax,rax
    6378:	jne    6386 <botlish_fn_58+0x19e>
    637e:	mov    rdi,r15
    6381:	jmp    6656 <botlish_fn_58+0x46e>
    6386:	mov    rsi,rax
    6389:	jmp    6395 <botlish_fn_58+0x1ad>
    638e:	mov    rax,QWORD PTR [rsi+0x10]
    6392:	mov    rsi,QWORD PTR [rax]
    6395:	mov    QWORD PTR [r14+0x18],rsi
    6399:	mov    rdi,r15
    639c:	mov    r12,rsi
    639f:	mov    rax,QWORD PTR [rdi+0x10]
    63a3:	mov    rdx,QWORD PTR [rax+0x68]
    63a7:	mov    QWORD PTR [r14+0x20],rdx
    63ab:	mov    rsi,QWORD PTR [rsp+0x40]
    63b0:	call   63b5 <botlish_fn_58+0x1cd>
			63b1: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    63b5:	test   rax,rax
    63b8:	jne    63c6 <botlish_fn_58+0x1de>
    63be:	mov    rdi,r15
    63c1:	jmp    6656 <botlish_fn_58+0x46e>
    63c6:	mov    QWORD PTR [r14+0x20],rax
    63ca:	mov    rbx,rax
    63cd:	mov    rdi,r15
    63d0:	mov    rsi,QWORD PTR [rdi+0x10]
    63d4:	mov    rdx,QWORD PTR [rsi+0x68]
    63d8:	mov    QWORD PTR [r14+0x28],rdx
    63dc:	mov    rsi,r12
    63df:	call   63e4 <botlish_fn_58+0x1fc>
			63e0: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    63e4:	test   rax,rax
    63e7:	jne    63f5 <botlish_fn_58+0x20d>
    63ed:	mov    rdi,r15
    63f0:	jmp    6656 <botlish_fn_58+0x46e>
    63f5:	mov    rcx,rbx
    63f8:	mov    rdi,rcx
    63fb:	and    rdi,rax
    63fe:	mov    rdx,rax
    6401:	test   rdi,0x1
    6408:	jne    642a <botlish_fn_58+0x242>
    640e:	mov    rsi,rbx
    6411:	mov    rdi,r15
    6414:	call   6419 <botlish_fn_58+0x231>
			6415: R_X86_64_PLT32	rt_value_eq-0x4
    6419:	test   rax,rax
    641c:	jne    643d <botlish_fn_58+0x255>
    6422:	mov    rdi,r15
    6425:	jmp    6656 <botlish_fn_58+0x46e>
    642a:	mov    rsi,rbx
    642d:	mov    eax,0x2
    6432:	cmp    rsi,rdx
    6435:	cmove  rax,QWORD PTR [rip+0x2ab]        # 66e8 <botlish_fn_58+0x500>
    643d:	mov    ebx,0x6
    6442:	cmp    rax,0x6
    6446:	je     6460 <botlish_fn_58+0x278>
    644c:	mov    ebx,0x2
    6451:	mov    QWORD PTR [r14],0x2
    6458:	mov    rsi,r13
    645b:	jmp    6501 <botlish_fn_58+0x319>
    6460:	mov    rsi,QWORD PTR [rsp+0x40]
    6465:	mov    rdi,r15
    6468:	call   646d <botlish_fn_58+0x285>
			6469: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    646d:	test   rax,rax
    6470:	jne    647e <botlish_fn_58+0x296>
    6476:	mov    rdi,r15
    6479:	jmp    6656 <botlish_fn_58+0x46e>
    647e:	mov    QWORD PTR [r14+0x20],rax
    6482:	mov    rsi,r12
    6485:	mov    r12,rax
    6488:	mov    rdi,r15
    648b:	call   6490 <botlish_fn_58+0x2a8>
			648c: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    6490:	test   rax,rax
    6493:	jne    64a1 <botlish_fn_58+0x2b9>
    6499:	mov    rdi,r15
    649c:	jmp    6656 <botlish_fn_58+0x46e>
    64a1:	mov    rcx,r12
    64a4:	mov    rdx,rcx
    64a7:	and    rdx,rax
    64aa:	test   rdx,0x1
    64b1:	jne    64d6 <botlish_fn_58+0x2ee>
    64b7:	mov    rdx,rax
    64ba:	mov    rsi,r12
    64bd:	mov    rdi,r15
    64c0:	call   64c5 <botlish_fn_58+0x2dd>
			64c1: R_X86_64_PLT32	rt_value_eq-0x4
    64c5:	test   rax,rax
    64c8:	jne    64ec <botlish_fn_58+0x304>
    64ce:	mov    rdi,r15
    64d1:	jmp    6656 <botlish_fn_58+0x46e>
    64d6:	mov    rdx,rax
    64d9:	mov    rsi,r12
    64dc:	mov    eax,0x2
    64e1:	cmp    rsi,rdx
    64e4:	cmove  rax,QWORD PTR [rip+0x1fc]        # 66e8 <botlish_fn_58+0x500>
    64ec:	cmp    rax,0x6
    64f0:	je     64fb <botlish_fn_58+0x313>
    64f6:	mov    ebx,0x2
    64fb:	mov    QWORD PTR [r14],rbx
    64fe:	mov    rsi,r13
    6501:	mov    rdi,r15
    6504:	call   6509 <botlish_fn_58+0x321>
			6505: R_X86_64_PLT32	rt_list_len-0x4
    6509:	mov    r12,rax
    650c:	mov    QWORD PTR [r14+0x18],r12
    6510:	mov    rdi,r15
    6513:	mov    rax,QWORD PTR [rdi+0x10]
    6517:	mov    rdx,QWORD PTR [rax+0x68]
    651b:	mov    QWORD PTR [r14+0x20],rdx
    651f:	mov    rsi,QWORD PTR [rsp+0x40]
    6524:	call   6529 <botlish_fn_58+0x341>
			6525: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6529:	mov    r13,rax
    652c:	test   r13,r13
    652f:	jne    653d <botlish_fn_58+0x355>
    6535:	mov    rdi,r15
    6538:	jmp    6656 <botlish_fn_58+0x46e>
    653d:	mov    QWORD PTR [r14+0x20],r13
    6541:	mov    rdi,r15
    6544:	mov    rax,QWORD PTR [rdi+0x10]
    6548:	mov    rdx,QWORD PTR [rax+0x70]
    654c:	mov    QWORD PTR [r14+0x28],rdx
    6550:	mov    rsi,QWORD PTR [rsp+0x40]
    6555:	call   655a <botlish_fn_58+0x372>
			6556: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    655a:	test   rax,rax
    655d:	jne    656b <botlish_fn_58+0x383>
    6563:	mov    rdi,r15
    6566:	jmp    6656 <botlish_fn_58+0x46e>
    656b:	mov    QWORD PTR [r14+0x28],rax
    656f:	mov    rdi,r15
    6572:	mov    QWORD PTR [rsp+0x50],rax
    6577:	mov    rax,QWORD PTR [rdi+0x10]
    657b:	mov    rdx,QWORD PTR [rax+0x78]
    657f:	mov    QWORD PTR [r14+0x30],rdx
    6583:	mov    rsi,QWORD PTR [rsp+0x40]
    6588:	call   658d <botlish_fn_58+0x3a5>
			6589: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    658d:	test   rax,rax
    6590:	jne    659e <botlish_fn_58+0x3b6>
    6596:	mov    rdi,r15
    6599:	jmp    6656 <botlish_fn_58+0x46e>
    659e:	mov    QWORD PTR [r14+0x8],rax
    65a2:	mov    rdi,r15
    65a5:	mov    QWORD PTR [rsp+0x48],rax
    65aa:	mov    rax,QWORD PTR [rdi+0x10]
    65ae:	mov    rdx,QWORD PTR [rax+0x68]
    65b2:	mov    QWORD PTR [r14+0x30],rdx
    65b6:	mov    rsi,QWORD PTR [rsp+0x38]
    65bb:	call   65c0 <botlish_fn_58+0x3d8>
			65bc: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    65c0:	test   rax,rax
    65c3:	jne    65d1 <botlish_fn_58+0x3e9>
    65c9:	mov    rdi,r15
    65cc:	jmp    6656 <botlish_fn_58+0x46e>
    65d1:	mov    QWORD PTR [r14+0x30],rax
    65d5:	mov    rdi,r15
    65d8:	mov    QWORD PTR [rsp+0x40],rax
    65dd:	mov    rax,QWORD PTR [rdi+0x10]
    65e1:	mov    rdx,QWORD PTR [rax+0x78]
    65e5:	mov    QWORD PTR [r14+0x38],rdx
    65e9:	mov    rsi,QWORD PTR [rsp+0x38]
    65ee:	call   65f3 <botlish_fn_58+0x40b>
			65ef: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    65f3:	test   rax,rax
    65f6:	jne    6604 <botlish_fn_58+0x41c>
    65fc:	mov    rdi,r15
    65ff:	jmp    6656 <botlish_fn_58+0x46e>
    6604:	mov    QWORD PTR [r14+0x10],rax
    6608:	lea    rdx,[rsp]
    660c:	mov    QWORD PTR [rsp],r12
    6610:	mov    QWORD PTR [rsp+0x8],r13
    6615:	mov    rcx,QWORD PTR [rsp+0x50]
    661a:	mov    QWORD PTR [rsp+0x10],rcx
    661f:	mov    rcx,QWORD PTR [rsp+0x48]
    6624:	mov    QWORD PTR [rsp+0x18],rcx
    6629:	mov    rcx,QWORD PTR [rsp+0x40]
    662e:	mov    QWORD PTR [rsp+0x20],rcx
    6633:	mov    QWORD PTR [rsp+0x28],rax
    6638:	mov    QWORD PTR [rsp+0x30],rbx
    663d:	mov    esi,0x7
    6642:	mov    rdi,r15
    6645:	call   664a <botlish_fn_58+0x462>
			6646: R_X86_64_PLT32	rt_list_new-0x4
    664a:	test   rax,rax
    664d:	jne    6687 <botlish_fn_58+0x49f>
    6653:	mov    rdi,r15
    6656:	mov    rdi,r15
    6659:	mov    QWORD PTR [rdi],r14
    665c:	xor    rax,rax
    665f:	mov    rbx,QWORD PTR [rsp+0x60]
    6664:	mov    r12,QWORD PTR [rsp+0x68]
    6669:	mov    r13,QWORD PTR [rsp+0x70]
    666e:	mov    r14,QWORD PTR [rsp+0x78]
    6673:	mov    r15,QWORD PTR [rsp+0x80]
    667b:	add    rsp,0x90
    6682:	mov    rsp,rbp
    6685:	pop    rbp
    6686:	ret
    6687:	mov    rdi,r15
    668a:	mov    QWORD PTR [rdi],r14
    668d:	mov    rbx,QWORD PTR [rsp+0x60]
    6692:	mov    r12,QWORD PTR [rsp+0x68]
    6697:	mov    r13,QWORD PTR [rsp+0x70]
    669c:	mov    r14,QWORD PTR [rsp+0x78]
    66a1:	mov    r15,QWORD PTR [rsp+0x80]
    66a9:	add    rsp,0x90
    66b0:	mov    rsp,rbp
    66b3:	pop    rbp
    66b4:	ret
    66b5:	mov    r15,rdi
    66b8:	call   66bd <botlish_fn_58+0x4d5>
			66b9: R_X86_64_PLT32	rt_stack_overflow-0x4
    66bd:	xor    rax,rax
    66c0:	mov    rbx,QWORD PTR [rsp+0x60]
    66c5:	mov    r12,QWORD PTR [rsp+0x68]
    66ca:	mov    r13,QWORD PTR [rsp+0x70]
    66cf:	mov    r14,QWORD PTR [rsp+0x78]
    66d4:	mov    r15,QWORD PTR [rsp+0x80]
    66dc:	add    rsp,0x90
    66e3:	mov    rsp,rbp
    66e6:	pop    rbp
    66e7:	ret
    66e8:	(bad)
    66e9:	add    BYTE PTR [rax],al
    66eb:	add    BYTE PTR [rax],al
    66ed:	add    BYTE PTR [rax],al
	...

00000000000066f0 <botlish_entry_58: sample<generic>>:
    66f0:	push   rbp
    66f1:	mov    rbp,rsp
    66f4:	call   66f9 <botlish_entry_58+0x9>
			66f5: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    66f9:	mov    rsp,rbp
    66fc:	pop    rbp
    66fd:	ret

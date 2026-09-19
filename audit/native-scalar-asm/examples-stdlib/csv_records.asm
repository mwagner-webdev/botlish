; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 29281  (per function: 172 184 461 517 396 396 396 183 469 534 676 887 469 837 584 268 71 71 71 71 524 689 208 581 271 177 251 177 251 177 251 177 251 177 269 269 284 284 332 332 1020 1536 565 556 582 1353 928 953 825 1472 1108 243 860 443 781 683 181 181 1366)
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
      ad:	mov    QWORD PTR [rsp],r13
      b1:	mov    QWORD PTR [rsp+0x8],r14
      b6:	mov    r13,QWORD PTR [rdi]
      b9:	mov    rax,QWORD PTR [rdi+0x8]
      bd:	lea    rcx,[r13+0x8]
      c1:	cmp    rcx,rax
      c4:	ja     12d <botlish_fn_1+0x88>
      ca:	lea    rax,[r13+0x8]
      ce:	mov    QWORD PTR [rdi],rax
      d1:	mov    r14,rdi
      d4:	mov    esi,0x1
      d9:	mov    QWORD PTR [r13+0x0],0x1
      e1:	mov    rdi,r14
      e4:	call   e9 <botlish_fn_1+0x44>
			e5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      e9:	test   rax,rax
      ec:	jne    110 <botlish_fn_1+0x6b>
      f2:	mov    rdi,r14
      f5:	mov    QWORD PTR [rdi],r13
      f8:	xor    rdx,rdx
      fb:	mov    rax,rdx
      fe:	mov    r13,QWORD PTR [rsp]
     102:	mov    r14,QWORD PTR [rsp+0x8]
     107:	add    rsp,0x10
     10b:	mov    rsp,rbp
     10e:	pop    rbp
     10f:	ret
     110:	mov    rdi,r14
     113:	mov    QWORD PTR [rdi],r13
     116:	mov    edx,0x1
     11b:	mov    r13,QWORD PTR [rsp]
     11f:	mov    r14,QWORD PTR [rsp+0x8]
     124:	add    rsp,0x10
     128:	mov    rsp,rbp
     12b:	pop    rbp
     12c:	ret
     12d:	call   132 <botlish_fn_1+0x8d>
			12e: R_X86_64_PLT32	rt_stack_overflow-0x4
     132:	xor    rdx,rdx
     135:	mov    rax,rdx
     138:	mov    r13,QWORD PTR [rsp]
     13c:	mov    r14,QWORD PTR [rsp+0x8]
     141:	add    rsp,0x10
     145:	mov    rsp,rbp
     148:	pop    rbp
     149:	ret

000000000000014a <botlish_entry_1: geo_new<generic>>:
     14a:	push   rbp
     14b:	mov    rbp,rsp
     14e:	ud2

0000000000000150 <botlish_fn_2: geo_new_capacity<int, int>>:
     150:	push   rbp
     151:	mov    rbp,rsp
     154:	sub    rsp,0x20
     158:	mov    QWORD PTR [rsp],rbx
     15c:	mov    QWORD PTR [rsp+0x8],r12
     161:	mov    QWORD PTR [rsp+0x10],r13
     166:	mov    QWORD PTR [rsp+0x18],r14
     16b:	mov    rbx,QWORD PTR [rdi]
     16e:	mov    rax,QWORD PTR [rdi+0x8]
     172:	lea    rcx,[rbx+0x18]
     176:	cmp    rcx,rax
     179:	ja     2af <botlish_fn_2+0x15f>
     17f:	lea    rax,[rbx+0x18]
     183:	mov    QWORD PTR [rdi],rax
     186:	mov    r13,rdi
     189:	mov    QWORD PTR [rbx],rsi
     18c:	mov    QWORD PTR [rbx+0x8],rdx
     190:	mov    r12,rdx
     193:	mov    QWORD PTR [rbx+0x10],0x5
     19b:	test   rsi,0x1
     1a2:	je     1c4 <botlish_fn_2+0x74>
     1a8:	mov    rax,rsi
     1ab:	sar    rax,1
     1ae:	imul   QWORD PTR [rip+0x123]        # 2d8 <botlish_fn_2+0x188>
     1b5:	seto   cl
     1b8:	or     rax,0x1
     1bc:	test   cl,cl
     1be:	je     1d1 <botlish_fn_2+0x81>
     1c4:	mov    edx,0x5
     1c9:	mov    rdi,r13
     1cc:	call   1d1 <botlish_fn_2+0x81>
			1cd: R_X86_64_PLT32	rt_int_mul-0x4
     1d1:	mov    rcx,rax
     1d4:	and    rcx,r12
     1d7:	mov    r14,rax
     1da:	test   rcx,0x1
     1e1:	jne    20d <botlish_fn_2+0xbd>
     1e7:	mov    rdx,r12
     1ea:	mov    rsi,r14
     1ed:	mov    rdi,r13
     1f0:	call   1f5 <botlish_fn_2+0xa5>
			1f1: R_X86_64_PLT32	rt_int_cmp-0x4
     1f5:	mov    ecx,0x2
     1fa:	test   rax,rax
     1fd:	cmovle rcx,QWORD PTR [rip+0xdb]        # 2e0 <botlish_fn_2+0x190>
     205:	mov    rax,r14
     208:	jmp    220 <botlish_fn_2+0xd0>
     20d:	mov    ecx,0x2
     212:	mov    rax,r14
     215:	cmp    rax,r12
     218:	cmovle rcx,QWORD PTR [rip+0xc0]        # 2e0 <botlish_fn_2+0x190>
     220:	cmp    rcx,0x6
     224:	je     24c <botlish_fn_2+0xfc>
     22a:	mov    rdi,r13
     22d:	mov    QWORD PTR [rdi],rbx
     230:	mov    rbx,QWORD PTR [rsp]
     234:	mov    r12,QWORD PTR [rsp+0x8]
     239:	mov    r13,QWORD PTR [rsp+0x10]
     23e:	mov    r14,QWORD PTR [rsp+0x18]
     243:	add    rsp,0x20
     247:	mov    rsp,rbp
     24a:	pop    rbp
     24b:	ret
     24c:	mov    QWORD PTR [rbx],0x3
     253:	test   r12,0x1
     25a:	je     27a <botlish_fn_2+0x12a>
     260:	mov    rax,r12
     263:	add    rax,0x2
     267:	seto   cl
     26a:	test   cl,cl
     26c:	jne    27a <botlish_fn_2+0x12a>
     272:	mov    rdi,r13
     275:	jmp    28d <botlish_fn_2+0x13d>
     27a:	mov    edx,0x3
     27f:	mov    rsi,r12
     282:	mov    rdi,r13
     285:	call   28a <botlish_fn_2+0x13a>
			286: R_X86_64_PLT32	rt_int_add-0x4
     28a:	mov    rdi,r13
     28d:	mov    rdi,r13
     290:	mov    QWORD PTR [rdi],rbx
     293:	mov    rbx,QWORD PTR [rsp]
     297:	mov    r12,QWORD PTR [rsp+0x8]
     29c:	mov    r13,QWORD PTR [rsp+0x10]
     2a1:	mov    r14,QWORD PTR [rsp+0x18]
     2a6:	add    rsp,0x20
     2aa:	mov    rsp,rbp
     2ad:	pop    rbp
     2ae:	ret
     2af:	mov    r13,rdi
     2b2:	call   2b7 <botlish_fn_2+0x167>
			2b3: R_X86_64_PLT32	rt_stack_overflow-0x4
     2b7:	xor    rax,rax
     2ba:	mov    rbx,QWORD PTR [rsp]
     2be:	mov    r12,QWORD PTR [rsp+0x8]
     2c3:	mov    r13,QWORD PTR [rsp+0x10]
     2c8:	mov    r14,QWORD PTR [rsp+0x18]
     2cd:	add    rsp,0x20
     2d1:	mov    rsp,rbp
     2d4:	pop    rbp
     2d5:	ret
     2d6:	add    BYTE PTR [rax],al
     2d8:	add    al,0x0
     2da:	add    BYTE PTR [rax],al
     2dc:	add    BYTE PTR [rax],al
     2de:	add    BYTE PTR [rax],al
     2e0:	(bad)
     2e1:	add    BYTE PTR [rax],al
     2e3:	add    BYTE PTR [rax],al
     2e5:	add    BYTE PTR [rax],al
	...

00000000000002e8 <botlish_entry_2: geo_new_capacity<int, int>>:
     2e8:	push   rbp
     2e9:	mov    rbp,rsp
     2ec:	mov    rsi,QWORD PTR [rdx]
     2ef:	mov    rdx,QWORD PTR [rdx+0x8]
     2f3:	call   2f8 <botlish_entry_2+0x10>
			2f4: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     2f8:	mov    rsp,rbp
     2fb:	pop    rbp
     2fc:	ret
     2fd:	add    BYTE PTR [rax],al
	...

0000000000000300 <botlish_fn_3: geo_grow<mutarray, int>>:
     300:	push   rbp
     301:	mov    rbp,rsp
     304:	sub    rsp,0x30
     308:	mov    QWORD PTR [rsp],rbx
     30c:	mov    QWORD PTR [rsp+0x8],r12
     311:	mov    QWORD PTR [rsp+0x10],r13
     316:	mov    QWORD PTR [rsp+0x18],r14
     31b:	mov    QWORD PTR [rsp+0x20],r15
     320:	mov    rbx,QWORD PTR [rdi]
     323:	mov    rax,QWORD PTR [rdi+0x8]
     327:	lea    rcx,[rbx+0x18]
     32b:	cmp    rcx,rax
     32e:	ja     499 <botlish_fn_3+0x199>
     334:	lea    rax,[rbx+0x18]
     338:	mov    QWORD PTR [rdi],rax
     33b:	mov    r13,rdi
     33e:	mov    QWORD PTR [rbx],rsi
     341:	mov    r14,rsi
     344:	mov    QWORD PTR [rbx+0x8],rdx
     348:	mov    r12,rdx
     34b:	mov    rsi,r14
     34e:	mov    rdi,r13
     351:	call   356 <botlish_fn_3+0x56>
			352: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     356:	mov    r15,rax
     359:	mov    QWORD PTR [rbx+0x10],rax
     35d:	mov    rcx,r12
     360:	and    rcx,rax
     363:	test   rcx,0x1
     36a:	jne    396 <botlish_fn_3+0x96>
     370:	mov    rdx,r15
     373:	mov    rsi,r12
     376:	mov    rdi,r13
     379:	call   37e <botlish_fn_3+0x7e>
			37a: R_X86_64_PLT32	rt_int_cmp-0x4
     37e:	mov    ecx,0x2
     383:	test   rax,rax
     386:	cmovl  rcx,QWORD PTR [rip+0x13a]        # 4c8 <botlish_fn_3+0x1c8>
     38e:	mov    rax,r15
     391:	jmp    3a9 <botlish_fn_3+0xa9>
     396:	mov    ecx,0x2
     39b:	mov    rax,r15
     39e:	cmp    r12,rax
     3a1:	cmovl  rcx,QWORD PTR [rip+0x11f]        # 4c8 <botlish_fn_3+0x1c8>
     3a9:	cmp    rcx,0x6
     3ad:	je     46f <botlish_fn_3+0x16f>
     3b3:	mov    rsi,rax
     3b6:	mov    rdx,r12
     3b9:	mov    rdi,r13
     3bc:	call   3c1 <botlish_fn_3+0xc1>
			3bd: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     3c1:	test   rax,rax
     3c4:	jne    3d2 <botlish_fn_3+0xd2>
     3ca:	mov    rdi,r13
     3cd:	jmp    41b <botlish_fn_3+0x11b>
     3d2:	mov    QWORD PTR [rbx+0x10],rax
     3d6:	mov    rsi,rax
     3d9:	mov    rdi,r13
     3dc:	call   3e1 <botlish_fn_3+0xe1>
			3dd: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3e1:	test   rax,rax
     3e4:	mov    r15,rax
     3e7:	jne    3f5 <botlish_fn_3+0xf5>
     3ed:	mov    rdi,r13
     3f0:	jmp    41b <botlish_fn_3+0x11b>
     3f5:	mov    r8d,0x1
     3fb:	mov    rcx,r14
     3fe:	mov    r9,r12
     401:	mov    rsi,r15
     404:	mov    rdi,r13
     407:	mov    rdx,r8
     40a:	call   40f <botlish_fn_3+0x10f>
			40b: R_X86_64_PLT32	rt_mutarray_copy-0x4
     40f:	test   rax,rax
     412:	jne    445 <botlish_fn_3+0x145>
     418:	mov    rdi,r13
     41b:	mov    rdi,r13
     41e:	mov    QWORD PTR [rdi],rbx
     421:	xor    rax,rax
     424:	mov    rbx,QWORD PTR [rsp]
     428:	mov    r12,QWORD PTR [rsp+0x8]
     42d:	mov    r13,QWORD PTR [rsp+0x10]
     432:	mov    r14,QWORD PTR [rsp+0x18]
     437:	mov    r15,QWORD PTR [rsp+0x20]
     43c:	add    rsp,0x30
     440:	mov    rsp,rbp
     443:	pop    rbp
     444:	ret
     445:	mov    rdi,r13
     448:	mov    QWORD PTR [rdi],rbx
     44b:	mov    rax,r15
     44e:	mov    rbx,QWORD PTR [rsp]
     452:	mov    r12,QWORD PTR [rsp+0x8]
     457:	mov    r13,QWORD PTR [rsp+0x10]
     45c:	mov    r14,QWORD PTR [rsp+0x18]
     461:	mov    r15,QWORD PTR [rsp+0x20]
     466:	add    rsp,0x30
     46a:	mov    rsp,rbp
     46d:	pop    rbp
     46e:	ret
     46f:	mov    rdi,r13
     472:	mov    QWORD PTR [rdi],rbx
     475:	mov    rax,r14
     478:	mov    rbx,QWORD PTR [rsp]
     47c:	mov    r12,QWORD PTR [rsp+0x8]
     481:	mov    r13,QWORD PTR [rsp+0x10]
     486:	mov    r14,QWORD PTR [rsp+0x18]
     48b:	mov    r15,QWORD PTR [rsp+0x20]
     490:	add    rsp,0x30
     494:	mov    rsp,rbp
     497:	pop    rbp
     498:	ret
     499:	mov    r13,rdi
     49c:	call   4a1 <botlish_fn_3+0x1a1>
			49d: R_X86_64_PLT32	rt_stack_overflow-0x4
     4a1:	xor    rax,rax
     4a4:	mov    rbx,QWORD PTR [rsp]
     4a8:	mov    r12,QWORD PTR [rsp+0x8]
     4ad:	mov    r13,QWORD PTR [rsp+0x10]
     4b2:	mov    r14,QWORD PTR [rsp+0x18]
     4b7:	mov    r15,QWORD PTR [rsp+0x20]
     4bc:	add    rsp,0x30
     4c0:	mov    rsp,rbp
     4c3:	pop    rbp
     4c4:	ret
     4c5:	add    BYTE PTR [rax],al
     4c7:	add    BYTE PTR [rsi],al
     4c9:	add    BYTE PTR [rax],al
     4cb:	add    BYTE PTR [rax],al
     4cd:	add    BYTE PTR [rax],al
	...

00000000000004d0 <botlish_entry_3: geo_grow<mutarray, int>>:
     4d0:	push   rbp
     4d1:	mov    rbp,rsp
     4d4:	mov    rsi,QWORD PTR [rdx]
     4d7:	mov    rdx,QWORD PTR [rdx+0x8]
     4db:	call   4e0 <botlish_entry_3+0x10>
			4dc: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     4e0:	mov    rsp,rbp
     4e3:	pop    rbp
     4e4:	ret

00000000000004e5 <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     4e5:	push   rbp
     4e6:	mov    rbp,rsp
     4e9:	sub    rsp,0x30
     4ed:	mov    QWORD PTR [rsp],rbx
     4f1:	mov    QWORD PTR [rsp+0x8],r12
     4f6:	mov    QWORD PTR [rsp+0x10],r13
     4fb:	mov    QWORD PTR [rsp+0x18],r14
     500:	mov    QWORD PTR [rsp+0x20],r15
     505:	mov    r12,QWORD PTR [rdi]
     508:	mov    r8,QWORD PTR [rdi+0x8]
     50c:	lea    rax,[r12+0x18]
     511:	cmp    rax,r8
     514:	ja     627 <botlish_fn_4+0x142>
     51a:	lea    rax,[r12+0x18]
     51f:	mov    QWORD PTR [rdi],rax
     522:	mov    r13,rdi
     525:	mov    QWORD PTR [r12],rsi
     529:	mov    QWORD PTR [r12+0x8],rdx
     52e:	mov    rdi,rdx
     531:	mov    QWORD PTR [r12+0x10],rcx
     536:	mov    r15,rcx
     539:	mov    rbx,rdi
     53c:	mov    rdx,rbx
     53f:	mov    rdi,r13
     542:	call   547 <botlish_fn_4+0x62>
			543: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     547:	test   rax,rax
     54a:	mov    r14,rax
     54d:	jne    55b <botlish_fn_4+0x76>
     553:	mov    rdi,r13
     556:	jmp    57f <botlish_fn_4+0x9a>
     55b:	mov    rax,r14
     55e:	mov    QWORD PTR [r12],rax
     562:	mov    rcx,r15
     565:	mov    rdx,rbx
     568:	mov    rsi,r14
     56b:	mov    rdi,r13
     56e:	call   573 <botlish_fn_4+0x8e>
			56f: R_X86_64_PLT32	rt_mutarray_set-0x4
     573:	test   rax,rax
     576:	jne    5ac <botlish_fn_4+0xc7>
     57c:	mov    rdi,r13
     57f:	mov    rdi,r13
     582:	mov    QWORD PTR [rdi],r12
     585:	xor    rdx,rdx
     588:	mov    rax,rdx
     58b:	mov    rbx,QWORD PTR [rsp]
     58f:	mov    r12,QWORD PTR [rsp+0x8]
     594:	mov    r13,QWORD PTR [rsp+0x10]
     599:	mov    r14,QWORD PTR [rsp+0x18]
     59e:	mov    r15,QWORD PTR [rsp+0x20]
     5a3:	add    rsp,0x30
     5a7:	mov    rsp,rbp
     5aa:	pop    rbp
     5ab:	ret
     5ac:	mov    QWORD PTR [r12+0x10],0x3
     5b5:	test   rbx,0x1
     5bc:	jne    5ca <botlish_fn_4+0xe5>
     5c2:	mov    rdi,rbx
     5c5:	jmp    5e7 <botlish_fn_4+0x102>
     5ca:	mov    rdx,rbx
     5cd:	add    rdx,0x2
     5d1:	mov    rdi,rbx
     5d4:	seto   al
     5d7:	test   al,al
     5d9:	jne    5e7 <botlish_fn_4+0x102>
     5df:	mov    rdi,r13
     5e2:	jmp    5fd <botlish_fn_4+0x118>
     5e7:	mov    edx,0x3
     5ec:	mov    rsi,rdi
     5ef:	mov    rdi,r13
     5f2:	call   5f7 <botlish_fn_4+0x112>
			5f3: R_X86_64_PLT32	rt_int_add-0x4
     5f7:	mov    rdx,rax
     5fa:	mov    rdi,r13
     5fd:	mov    rdi,r13
     600:	mov    QWORD PTR [rdi],r12
     603:	mov    rax,r14
     606:	mov    rbx,QWORD PTR [rsp]
     60a:	mov    r12,QWORD PTR [rsp+0x8]
     60f:	mov    r13,QWORD PTR [rsp+0x10]
     614:	mov    r14,QWORD PTR [rsp+0x18]
     619:	mov    r15,QWORD PTR [rsp+0x20]
     61e:	add    rsp,0x30
     622:	mov    rsp,rbp
     625:	pop    rbp
     626:	ret
     627:	mov    r13,rdi
     62a:	call   62f <botlish_fn_4+0x14a>
			62b: R_X86_64_PLT32	rt_stack_overflow-0x4
     62f:	xor    rdx,rdx
     632:	mov    rax,rdx
     635:	mov    rbx,QWORD PTR [rsp]
     639:	mov    r12,QWORD PTR [rsp+0x8]
     63e:	mov    r13,QWORD PTR [rsp+0x10]
     643:	mov    r14,QWORD PTR [rsp+0x18]
     648:	mov    r15,QWORD PTR [rsp+0x20]
     64d:	add    rsp,0x30
     651:	mov    rsp,rbp
     654:	pop    rbp
     655:	ret

0000000000000656 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     656:	push   rbp
     657:	mov    rbp,rsp
     65a:	ud2

000000000000065c <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     65c:	push   rbp
     65d:	mov    rbp,rsp
     660:	sub    rsp,0x30
     664:	mov    QWORD PTR [rsp],rbx
     668:	mov    QWORD PTR [rsp+0x8],r12
     66d:	mov    QWORD PTR [rsp+0x10],r13
     672:	mov    QWORD PTR [rsp+0x18],r14
     677:	mov    QWORD PTR [rsp+0x20],r15
     67c:	mov    r12,QWORD PTR [rdi]
     67f:	mov    r8,QWORD PTR [rdi+0x8]
     683:	lea    rax,[r12+0x18]
     688:	cmp    rax,r8
     68b:	ja     79e <botlish_fn_5+0x142>
     691:	lea    rax,[r12+0x18]
     696:	mov    QWORD PTR [rdi],rax
     699:	mov    r13,rdi
     69c:	mov    QWORD PTR [r12],rsi
     6a0:	mov    QWORD PTR [r12+0x8],rdx
     6a5:	mov    rdi,rdx
     6a8:	mov    QWORD PTR [r12+0x10],rcx
     6ad:	mov    r15,rcx
     6b0:	mov    rbx,rdi
     6b3:	mov    rdx,rbx
     6b6:	mov    rdi,r13
     6b9:	call   6be <botlish_fn_5+0x62>
			6ba: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     6be:	test   rax,rax
     6c1:	mov    r14,rax
     6c4:	jne    6d2 <botlish_fn_5+0x76>
     6ca:	mov    rdi,r13
     6cd:	jmp    6f6 <botlish_fn_5+0x9a>
     6d2:	mov    rax,r14
     6d5:	mov    QWORD PTR [r12],rax
     6d9:	mov    rcx,r15
     6dc:	mov    rdx,rbx
     6df:	mov    rsi,r14
     6e2:	mov    rdi,r13
     6e5:	call   6ea <botlish_fn_5+0x8e>
			6e6: R_X86_64_PLT32	rt_mutarray_set-0x4
     6ea:	test   rax,rax
     6ed:	jne    723 <botlish_fn_5+0xc7>
     6f3:	mov    rdi,r13
     6f6:	mov    rdi,r13
     6f9:	mov    QWORD PTR [rdi],r12
     6fc:	xor    rdx,rdx
     6ff:	mov    rax,rdx
     702:	mov    rbx,QWORD PTR [rsp]
     706:	mov    r12,QWORD PTR [rsp+0x8]
     70b:	mov    r13,QWORD PTR [rsp+0x10]
     710:	mov    r14,QWORD PTR [rsp+0x18]
     715:	mov    r15,QWORD PTR [rsp+0x20]
     71a:	add    rsp,0x30
     71e:	mov    rsp,rbp
     721:	pop    rbp
     722:	ret
     723:	mov    QWORD PTR [r12+0x10],0x3
     72c:	test   rbx,0x1
     733:	jne    741 <botlish_fn_5+0xe5>
     739:	mov    rdi,rbx
     73c:	jmp    75e <botlish_fn_5+0x102>
     741:	mov    rdx,rbx
     744:	add    rdx,0x2
     748:	mov    rdi,rbx
     74b:	seto   al
     74e:	test   al,al
     750:	jne    75e <botlish_fn_5+0x102>
     756:	mov    rdi,r13
     759:	jmp    774 <botlish_fn_5+0x118>
     75e:	mov    edx,0x3
     763:	mov    rsi,rdi
     766:	mov    rdi,r13
     769:	call   76e <botlish_fn_5+0x112>
			76a: R_X86_64_PLT32	rt_int_add-0x4
     76e:	mov    rdx,rax
     771:	mov    rdi,r13
     774:	mov    rdi,r13
     777:	mov    QWORD PTR [rdi],r12
     77a:	mov    rax,r14
     77d:	mov    rbx,QWORD PTR [rsp]
     781:	mov    r12,QWORD PTR [rsp+0x8]
     786:	mov    r13,QWORD PTR [rsp+0x10]
     78b:	mov    r14,QWORD PTR [rsp+0x18]
     790:	mov    r15,QWORD PTR [rsp+0x20]
     795:	add    rsp,0x30
     799:	mov    rsp,rbp
     79c:	pop    rbp
     79d:	ret
     79e:	mov    r13,rdi
     7a1:	call   7a6 <botlish_fn_5+0x14a>
			7a2: R_X86_64_PLT32	rt_stack_overflow-0x4
     7a6:	xor    rdx,rdx
     7a9:	mov    rax,rdx
     7ac:	mov    rbx,QWORD PTR [rsp]
     7b0:	mov    r12,QWORD PTR [rsp+0x8]
     7b5:	mov    r13,QWORD PTR [rsp+0x10]
     7ba:	mov    r14,QWORD PTR [rsp+0x18]
     7bf:	mov    r15,QWORD PTR [rsp+0x20]
     7c4:	add    rsp,0x30
     7c8:	mov    rsp,rbp
     7cb:	pop    rbp
     7cc:	ret

00000000000007cd <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     7cd:	push   rbp
     7ce:	mov    rbp,rsp
     7d1:	ud2

00000000000007d3 <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     7d3:	push   rbp
     7d4:	mov    rbp,rsp
     7d7:	sub    rsp,0x30
     7db:	mov    QWORD PTR [rsp],rbx
     7df:	mov    QWORD PTR [rsp+0x8],r12
     7e4:	mov    QWORD PTR [rsp+0x10],r13
     7e9:	mov    QWORD PTR [rsp+0x18],r14
     7ee:	mov    QWORD PTR [rsp+0x20],r15
     7f3:	mov    r12,QWORD PTR [rdi]
     7f6:	mov    r8,QWORD PTR [rdi+0x8]
     7fa:	lea    rax,[r12+0x18]
     7ff:	cmp    rax,r8
     802:	ja     915 <botlish_fn_6+0x142>
     808:	lea    rax,[r12+0x18]
     80d:	mov    QWORD PTR [rdi],rax
     810:	mov    r13,rdi
     813:	mov    QWORD PTR [r12],rsi
     817:	mov    QWORD PTR [r12+0x8],rdx
     81c:	mov    rdi,rdx
     81f:	mov    QWORD PTR [r12+0x10],rcx
     824:	mov    r15,rcx
     827:	mov    rbx,rdi
     82a:	mov    rdx,rbx
     82d:	mov    rdi,r13
     830:	call   835 <botlish_fn_6+0x62>
			831: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     835:	test   rax,rax
     838:	mov    r14,rax
     83b:	jne    849 <botlish_fn_6+0x76>
     841:	mov    rdi,r13
     844:	jmp    86d <botlish_fn_6+0x9a>
     849:	mov    rax,r14
     84c:	mov    QWORD PTR [r12],rax
     850:	mov    rcx,r15
     853:	mov    rdx,rbx
     856:	mov    rsi,r14
     859:	mov    rdi,r13
     85c:	call   861 <botlish_fn_6+0x8e>
			85d: R_X86_64_PLT32	rt_mutarray_set-0x4
     861:	test   rax,rax
     864:	jne    89a <botlish_fn_6+0xc7>
     86a:	mov    rdi,r13
     86d:	mov    rdi,r13
     870:	mov    QWORD PTR [rdi],r12
     873:	xor    rdx,rdx
     876:	mov    rax,rdx
     879:	mov    rbx,QWORD PTR [rsp]
     87d:	mov    r12,QWORD PTR [rsp+0x8]
     882:	mov    r13,QWORD PTR [rsp+0x10]
     887:	mov    r14,QWORD PTR [rsp+0x18]
     88c:	mov    r15,QWORD PTR [rsp+0x20]
     891:	add    rsp,0x30
     895:	mov    rsp,rbp
     898:	pop    rbp
     899:	ret
     89a:	mov    QWORD PTR [r12+0x10],0x3
     8a3:	test   rbx,0x1
     8aa:	jne    8b8 <botlish_fn_6+0xe5>
     8b0:	mov    rdi,rbx
     8b3:	jmp    8d5 <botlish_fn_6+0x102>
     8b8:	mov    rdx,rbx
     8bb:	add    rdx,0x2
     8bf:	mov    rdi,rbx
     8c2:	seto   al
     8c5:	test   al,al
     8c7:	jne    8d5 <botlish_fn_6+0x102>
     8cd:	mov    rdi,r13
     8d0:	jmp    8eb <botlish_fn_6+0x118>
     8d5:	mov    edx,0x3
     8da:	mov    rsi,rdi
     8dd:	mov    rdi,r13
     8e0:	call   8e5 <botlish_fn_6+0x112>
			8e1: R_X86_64_PLT32	rt_int_add-0x4
     8e5:	mov    rdx,rax
     8e8:	mov    rdi,r13
     8eb:	mov    rdi,r13
     8ee:	mov    QWORD PTR [rdi],r12
     8f1:	mov    rax,r14
     8f4:	mov    rbx,QWORD PTR [rsp]
     8f8:	mov    r12,QWORD PTR [rsp+0x8]
     8fd:	mov    r13,QWORD PTR [rsp+0x10]
     902:	mov    r14,QWORD PTR [rsp+0x18]
     907:	mov    r15,QWORD PTR [rsp+0x20]
     90c:	add    rsp,0x30
     910:	mov    rsp,rbp
     913:	pop    rbp
     914:	ret
     915:	mov    r13,rdi
     918:	call   91d <botlish_fn_6+0x14a>
			919: R_X86_64_PLT32	rt_stack_overflow-0x4
     91d:	xor    rdx,rdx
     920:	mov    rax,rdx
     923:	mov    rbx,QWORD PTR [rsp]
     927:	mov    r12,QWORD PTR [rsp+0x8]
     92c:	mov    r13,QWORD PTR [rsp+0x10]
     931:	mov    r14,QWORD PTR [rsp+0x18]
     936:	mov    r15,QWORD PTR [rsp+0x20]
     93b:	add    rsp,0x30
     93f:	mov    rsp,rbp
     942:	pop    rbp
     943:	ret

0000000000000944 <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     944:	push   rbp
     945:	mov    rbp,rsp
     948:	ud2

000000000000094a <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     94a:	push   rbp
     94b:	mov    rbp,rsp
     94e:	sub    rsp,0x10
     952:	mov    QWORD PTR [rsp],r13
     956:	mov    QWORD PTR [rsp+0x8],r14
     95b:	mov    r13,QWORD PTR [rdi]
     95e:	mov    rax,QWORD PTR [rdi+0x8]
     962:	lea    rcx,[r13+0x10]
     966:	cmp    rcx,rax
     969:	ja     9c5 <botlish_fn_7+0x7b>
     96f:	lea    rax,[r13+0x10]
     973:	mov    QWORD PTR [rdi],rax
     976:	mov    r14,rdi
     979:	mov    QWORD PTR [r13+0x0],rsi
     97d:	mov    QWORD PTR [r13+0x8],rdx
     981:	mov    rdi,r14
     984:	call   989 <botlish_fn_7+0x3f>
			985: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     989:	test   rax,rax
     98c:	jne    9ad <botlish_fn_7+0x63>
     992:	mov    rdi,r14
     995:	mov    QWORD PTR [rdi],r13
     998:	xor    rax,rax
     99b:	mov    r13,QWORD PTR [rsp]
     99f:	mov    r14,QWORD PTR [rsp+0x8]
     9a4:	add    rsp,0x10
     9a8:	mov    rsp,rbp
     9ab:	pop    rbp
     9ac:	ret
     9ad:	mov    rdi,r14
     9b0:	mov    QWORD PTR [rdi],r13
     9b3:	mov    r13,QWORD PTR [rsp]
     9b7:	mov    r14,QWORD PTR [rsp+0x8]
     9bc:	add    rsp,0x10
     9c0:	mov    rsp,rbp
     9c3:	pop    rbp
     9c4:	ret
     9c5:	call   9ca <botlish_fn_7+0x80>
			9c6: R_X86_64_PLT32	rt_stack_overflow-0x4
     9ca:	xor    rax,rax
     9cd:	mov    r13,QWORD PTR [rsp]
     9d1:	mov    r14,QWORD PTR [rsp+0x8]
     9d6:	add    rsp,0x10
     9da:	mov    rsp,rbp
     9dd:	pop    rbp
     9de:	ret

00000000000009df <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     9df:	push   rbp
     9e0:	mov    rbp,rsp
     9e3:	mov    rsi,QWORD PTR [rdx]
     9e6:	mov    rdx,QWORD PTR [rdx+0x8]
     9ea:	call   9ef <botlish_entry_7+0x10>
			9eb: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     9ef:	mov    rsp,rbp
     9f2:	pop    rbp
     9f3:	ret
     9f4:	add    BYTE PTR [rax],al
	...

00000000000009f8 <botlish_fn_8: peek<str, int>>:
     9f8:	push   rbp
     9f9:	mov    rbp,rsp
     9fc:	sub    rsp,0x20
     a00:	mov    QWORD PTR [rsp],rbx
     a04:	mov    QWORD PTR [rsp+0x8],r12
     a09:	mov    QWORD PTR [rsp+0x10],r13
     a0e:	mov    QWORD PTR [rsp+0x18],r14
     a13:	mov    r12,QWORD PTR [rdi]
     a16:	mov    rax,QWORD PTR [rdi+0x8]
     a1a:	lea    rcx,[r12+0x18]
     a1f:	cmp    rcx,rax
     a22:	ja     b64 <botlish_fn_8+0x16c>
     a28:	lea    rax,[r12+0x18]
     a2d:	mov    QWORD PTR [rdi],rax
     a30:	mov    r13,rdi
     a33:	mov    QWORD PTR [r12],rsi
     a37:	mov    r14,rsi
     a3a:	mov    QWORD PTR [r12+0x8],rdx
     a3f:	mov    rbx,rdx
     a42:	mov    rsi,r14
     a45:	mov    rdi,r13
     a48:	call   a4d <botlish_fn_8+0x55>
			a49: R_X86_64_PLT32	rt_str_len-0x4
     a4d:	mov    rcx,rbx
     a50:	and    rcx,rax
     a53:	mov    rdx,rax
     a56:	test   rcx,0x1
     a5d:	jne    a83 <botlish_fn_8+0x8b>
     a63:	mov    rsi,rbx
     a66:	mov    rdi,r13
     a69:	call   a6e <botlish_fn_8+0x76>
			a6a: R_X86_64_PLT32	rt_int_cmp-0x4
     a6e:	mov    ecx,0x2
     a73:	test   rax,rax
     a76:	cmovge rcx,QWORD PTR [rip+0x112]        # b90 <botlish_fn_8+0x198>
     a7e:	jmp    a93 <botlish_fn_8+0x9b>
     a83:	mov    ecx,0x2
     a88:	cmp    rbx,rdx
     a8b:	cmovge rcx,QWORD PTR [rip+0xfd]        # b90 <botlish_fn_8+0x198>
     a93:	cmp    rcx,0x6
     a97:	je     b3b <botlish_fn_8+0x143>
     a9d:	mov    QWORD PTR [r12+0x10],0x3
     aa6:	test   rbx,0x1
     aad:	je     ac5 <botlish_fn_8+0xcd>
     ab3:	mov    rcx,rbx
     ab6:	add    rcx,0x2
     aba:	seto   al
     abd:	test   al,al
     abf:	je     ad8 <botlish_fn_8+0xe0>
     ac5:	mov    edx,0x3
     aca:	mov    rsi,rbx
     acd:	mov    rdi,r13
     ad0:	call   ad5 <botlish_fn_8+0xdd>
			ad1: R_X86_64_PLT32	rt_int_add-0x4
     ad5:	mov    rcx,rax
     ad8:	mov    QWORD PTR [r12+0x10],rcx
     add:	mov    rdx,rbx
     ae0:	mov    rsi,r14
     ae3:	mov    rdi,r13
     ae6:	call   aeb <botlish_fn_8+0xf3>
			ae7: R_X86_64_PLT32	rt_substr-0x4
     aeb:	test   rax,rax
     aee:	jne    b19 <botlish_fn_8+0x121>
     af4:	mov    rdi,r13
     af7:	mov    QWORD PTR [rdi],r12
     afa:	xor    rax,rax
     afd:	mov    rbx,QWORD PTR [rsp]
     b01:	mov    r12,QWORD PTR [rsp+0x8]
     b06:	mov    r13,QWORD PTR [rsp+0x10]
     b0b:	mov    r14,QWORD PTR [rsp+0x18]
     b10:	add    rsp,0x20
     b14:	mov    rsp,rbp
     b17:	pop    rbp
     b18:	ret
     b19:	mov    rdi,r13
     b1c:	mov    QWORD PTR [rdi],r12
     b1f:	mov    rbx,QWORD PTR [rsp]
     b23:	mov    r12,QWORD PTR [rsp+0x8]
     b28:	mov    r13,QWORD PTR [rsp+0x10]
     b2d:	mov    r14,QWORD PTR [rsp+0x18]
     b32:	add    rsp,0x20
     b36:	mov    rsp,rbp
     b39:	pop    rbp
     b3a:	ret
     b3b:	mov    rdi,r13
     b3e:	mov    rax,QWORD PTR [rdi+0x10]
     b42:	mov    rax,QWORD PTR [rax]
     b45:	mov    QWORD PTR [rdi],r12
     b48:	mov    rbx,QWORD PTR [rsp]
     b4c:	mov    r12,QWORD PTR [rsp+0x8]
     b51:	mov    r13,QWORD PTR [rsp+0x10]
     b56:	mov    r14,QWORD PTR [rsp+0x18]
     b5b:	add    rsp,0x20
     b5f:	mov    rsp,rbp
     b62:	pop    rbp
     b63:	ret
     b64:	mov    r13,rdi
     b67:	call   b6c <botlish_fn_8+0x174>
			b68: R_X86_64_PLT32	rt_stack_overflow-0x4
     b6c:	xor    rax,rax
     b6f:	mov    rbx,QWORD PTR [rsp]
     b73:	mov    r12,QWORD PTR [rsp+0x8]
     b78:	mov    r13,QWORD PTR [rsp+0x10]
     b7d:	mov    r14,QWORD PTR [rsp+0x18]
     b82:	add    rsp,0x20
     b86:	mov    rsp,rbp
     b89:	pop    rbp
     b8a:	ret
     b8b:	add    BYTE PTR [rax],al
     b8d:	add    BYTE PTR [rax],al
     b8f:	add    BYTE PTR [rsi],al
     b91:	add    BYTE PTR [rax],al
     b93:	add    BYTE PTR [rax],al
     b95:	add    BYTE PTR [rax],al
	...

0000000000000b98 <botlish_entry_8: peek<str, int>>:
     b98:	push   rbp
     b99:	mov    rbp,rsp
     b9c:	mov    rsi,QWORD PTR [rdx]
     b9f:	mov    rdx,QWORD PTR [rdx+0x8]
     ba3:	call   ba8 <botlish_entry_8+0x10>
			ba4: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     ba8:	mov    rsp,rbp
     bab:	pop    rbp
     bac:	ret
     bad:	add    BYTE PTR [rax],al
	...

0000000000000bb0 <botlish_fn_9: peek<str, int>>:
     bb0:	push   rbp
     bb1:	mov    rbp,rsp
     bb4:	sub    rsp,0x40
     bb8:	mov    QWORD PTR [rsp+0x10],rbx
     bbd:	mov    QWORD PTR [rsp+0x18],r12
     bc2:	mov    QWORD PTR [rsp+0x20],r13
     bc7:	mov    QWORD PTR [rsp+0x28],r14
     bcc:	mov    QWORD PTR [rsp+0x30],r15
     bd1:	mov    r13,rcx
     bd4:	mov    r12,QWORD PTR [rdi]
     bd7:	mov    rax,QWORD PTR [rdi+0x8]
     bdb:	lea    rcx,[r12+0x18]
     be0:	cmp    rcx,rax
     be3:	ja     d63 <botlish_fn_9+0x1b3>
     be9:	lea    rax,[r12+0x18]
     bee:	mov    QWORD PTR [rdi],rax
     bf1:	mov    r15,rdi
     bf4:	mov    QWORD PTR [r12],rsi
     bf8:	mov    r14,rsi
     bfb:	mov    QWORD PTR [r12+0x8],rdx
     c00:	mov    rbx,rdx
     c03:	mov    rsi,r14
     c06:	mov    rdi,r15
     c09:	call   c0e <botlish_fn_9+0x5e>
			c0a: R_X86_64_PLT32	rt_str_len-0x4
     c0e:	mov    rcx,rbx
     c11:	and    rcx,rax
     c14:	mov    rdx,rax
     c17:	test   rcx,0x1
     c1e:	jne    c44 <botlish_fn_9+0x94>
     c24:	mov    rsi,rbx
     c27:	mov    rdi,r15
     c2a:	call   c2f <botlish_fn_9+0x7f>
			c2b: R_X86_64_PLT32	rt_int_cmp-0x4
     c2f:	mov    ecx,0x2
     c34:	test   rax,rax
     c37:	cmovge rcx,QWORD PTR [rip+0x151]        # d90 <botlish_fn_9+0x1e0>
     c3f:	jmp    c54 <botlish_fn_9+0xa4>
     c44:	mov    ecx,0x2
     c49:	cmp    rbx,rdx
     c4c:	cmovge rcx,QWORD PTR [rip+0x13c]        # d90 <botlish_fn_9+0x1e0>
     c54:	cmp    rcx,0x6
     c58:	je     d22 <botlish_fn_9+0x172>
     c5e:	mov    QWORD PTR [r12+0x10],0x3
     c67:	test   rbx,0x1
     c6e:	je     c8f <botlish_fn_9+0xdf>
     c74:	mov    rax,rbx
     c77:	add    rax,0x2
     c7b:	seto   cl
     c7e:	test   cl,cl
     c80:	jne    c8f <botlish_fn_9+0xdf>
     c86:	mov    QWORD PTR [rsp],rax
     c8a:	jmp    ca3 <botlish_fn_9+0xf3>
     c8f:	mov    edx,0x3
     c94:	mov    rsi,rbx
     c97:	mov    rdi,r15
     c9a:	call   c9f <botlish_fn_9+0xef>
			c9b: R_X86_64_PLT32	rt_int_add-0x4
     c9f:	mov    QWORD PTR [rsp],rax
     ca3:	mov    rcx,QWORD PTR [rsp]
     ca7:	mov    rdx,rbx
     caa:	mov    rsi,r14
     cad:	mov    rdi,r15
     cb0:	call   cb5 <botlish_fn_9+0x105>
			cb1: R_X86_64_PLT32	rt_str_region_check-0x4
     cb5:	test   rax,rax
     cb8:	jne    ce9 <botlish_fn_9+0x139>
     cbe:	mov    rdi,r15
     cc1:	mov    QWORD PTR [rdi],r12
     cc4:	xor    rax,rax
     cc7:	mov    rbx,QWORD PTR [rsp+0x10]
     ccc:	mov    r12,QWORD PTR [rsp+0x18]
     cd1:	mov    r13,QWORD PTR [rsp+0x20]
     cd6:	mov    r14,QWORD PTR [rsp+0x28]
     cdb:	mov    r15,QWORD PTR [rsp+0x30]
     ce0:	add    rsp,0x40
     ce4:	mov    rsp,rbp
     ce7:	pop    rbp
     ce8:	ret
     ce9:	mov    rdi,r15
     cec:	mov    QWORD PTR [rdi],r12
     cef:	mov    rcx,r13
     cf2:	mov    QWORD PTR [rcx],rbx
     cf5:	mov    rax,QWORD PTR [rsp]
     cf9:	mov    QWORD PTR [rcx+0x8],rax
     cfd:	mov    rax,r14
     d00:	mov    rbx,QWORD PTR [rsp+0x10]
     d05:	mov    r12,QWORD PTR [rsp+0x18]
     d0a:	mov    r13,QWORD PTR [rsp+0x20]
     d0f:	mov    r14,QWORD PTR [rsp+0x28]
     d14:	mov    r15,QWORD PTR [rsp+0x30]
     d19:	add    rsp,0x40
     d1d:	mov    rsp,rbp
     d20:	pop    rbp
     d21:	ret
     d22:	mov    rcx,r13
     d25:	mov    rdi,r15
     d28:	mov    rax,QWORD PTR [rdi+0x10]
     d2c:	mov    rax,QWORD PTR [rax]
     d2f:	mov    QWORD PTR [rdi],r12
     d32:	mov    QWORD PTR [rcx],0x1
     d39:	mov    QWORD PTR [rcx+0x8],0x1
     d41:	mov    rbx,QWORD PTR [rsp+0x10]
     d46:	mov    r12,QWORD PTR [rsp+0x18]
     d4b:	mov    r13,QWORD PTR [rsp+0x20]
     d50:	mov    r14,QWORD PTR [rsp+0x28]
     d55:	mov    r15,QWORD PTR [rsp+0x30]
     d5a:	add    rsp,0x40
     d5e:	mov    rsp,rbp
     d61:	pop    rbp
     d62:	ret
     d63:	mov    r15,rdi
     d66:	call   d6b <botlish_fn_9+0x1bb>
			d67: R_X86_64_PLT32	rt_stack_overflow-0x4
     d6b:	xor    rax,rax
     d6e:	mov    rbx,QWORD PTR [rsp+0x10]
     d73:	mov    r12,QWORD PTR [rsp+0x18]
     d78:	mov    r13,QWORD PTR [rsp+0x20]
     d7d:	mov    r14,QWORD PTR [rsp+0x28]
     d82:	mov    r15,QWORD PTR [rsp+0x30]
     d87:	add    rsp,0x40
     d8b:	mov    rsp,rbp
     d8e:	pop    rbp
     d8f:	ret
     d90:	(bad)
     d91:	add    BYTE PTR [rax],al
     d93:	add    BYTE PTR [rax],al
     d95:	add    BYTE PTR [rax],al
	...

0000000000000d98 <botlish_entry_9: peek<str, int>>:
     d98:	push   rbp
     d99:	mov    rbp,rsp
     d9c:	ud2

0000000000000d9e <botlish_fn_10: scan_unquoted<str, int, int>>:
     d9e:	push   rbp
     d9f:	mov    rbp,rsp
     da2:	sub    rsp,0x60
     da6:	mov    QWORD PTR [rsp+0x30],rbx
     dab:	mov    QWORD PTR [rsp+0x38],r12
     db0:	mov    QWORD PTR [rsp+0x40],r13
     db5:	mov    QWORD PTR [rsp+0x48],r14
     dba:	mov    QWORD PTR [rsp+0x50],r15
     dbf:	mov    r14,QWORD PTR [rdi]
     dc2:	mov    rax,QWORD PTR [rdi+0x8]
     dc6:	lea    r8,[r14+0x20]
     dca:	cmp    r8,rax
     dcd:	ja     fdd <botlish_fn_10+0x23f>
     dd3:	lea    rax,[r14+0x20]
     dd7:	mov    QWORD PTR [rdi],rax
     dda:	mov    r15,rdi
     ddd:	mov    QWORD PTR [r14+0x18],0x0
     de5:	mov    QWORD PTR [r14],rsi
     de8:	mov    QWORD PTR [rsp+0x10],rsi
     ded:	mov    QWORD PTR [r14+0x8],rdx
     df1:	mov    QWORD PTR [rsp+0x18],rdx
     df6:	mov    QWORD PTR [r14+0x10],rcx
     dfa:	lea    rbx,[rsp]
     dfe:	mov    QWORD PTR [rsp+0x20],rcx
     e03:	mov    rcx,rbx
     e06:	mov    rdx,QWORD PTR [rsp+0x20]
     e0b:	mov    rsi,QWORD PTR [rsp+0x10]
     e10:	mov    rdi,r15
     e13:	call   e18 <botlish_fn_10+0x7a>
			e14: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     e18:	mov    rcx,rax
     e1b:	mov    QWORD PTR [rsp+0x28],rax
     e20:	test   rax,rcx
     e23:	jne    e31 <botlish_fn_10+0x93>
     e29:	mov    rdi,r15
     e2c:	jmp    f82 <botlish_fn_10+0x1e4>
     e31:	mov    r12,QWORD PTR [rsp]
     e35:	mov    r13,QWORD PTR [rsp+0x8]
     e3a:	mov    rdi,r15
     e3d:	mov    rcx,QWORD PTR [rdi+0x10]
     e41:	mov    r8,QWORD PTR [rcx]
     e44:	mov    rcx,r13
     e47:	mov    rdx,r12
     e4a:	mov    rsi,QWORD PTR [rsp+0x28]
     e4f:	call   e54 <botlish_fn_10+0xb6>
			e50: R_X86_64_PLT32	rt_str_region_eq-0x4
     e54:	cmp    rax,0x6
     e58:	je     e97 <botlish_fn_10+0xf9>
     e5e:	mov    rdi,r15
     e61:	mov    rax,QWORD PTR [rdi+0x10]
     e65:	mov    r8,QWORD PTR [rax+0x8]
     e69:	mov    rcx,r13
     e6c:	mov    rdx,r12
     e6f:	mov    rsi,QWORD PTR [rsp+0x28]
     e74:	call   e79 <botlish_fn_10+0xdb>
			e75: R_X86_64_PLT32	rt_str_region_eq-0x4
     e79:	cmp    rax,0x6
     e7d:	je     e8d <botlish_fn_10+0xef>
     e83:	mov    eax,0x2
     e88:	jmp    e9c <botlish_fn_10+0xfe>
     e8d:	mov    eax,0x6
     e92:	jmp    e9c <botlish_fn_10+0xfe>
     e97:	mov    eax,0x6
     e9c:	cmp    rax,0x6
     ea0:	je     edf <botlish_fn_10+0x141>
     ea6:	mov    rdi,r15
     ea9:	mov    rcx,QWORD PTR [rdi+0x10]
     ead:	mov    r8,QWORD PTR [rcx+0x10]
     eb1:	mov    rcx,r13
     eb4:	mov    rdx,r12
     eb7:	mov    rsi,QWORD PTR [rsp+0x28]
     ebc:	call   ec1 <botlish_fn_10+0x123>
			ebd: R_X86_64_PLT32	rt_str_region_eq-0x4
     ec1:	cmp    rax,0x6
     ec5:	je     ed5 <botlish_fn_10+0x137>
     ecb:	mov    eax,0x2
     ed0:	jmp    ee4 <botlish_fn_10+0x146>
     ed5:	mov    eax,0x6
     eda:	jmp    ee4 <botlish_fn_10+0x146>
     edf:	mov    eax,0x6
     ee4:	cmp    rax,0x6
     ee8:	je     f5f <botlish_fn_10+0x1c1>
     eee:	mov    QWORD PTR [r14+0x18],0x3
     ef6:	mov    rsi,QWORD PTR [rsp+0x20]
     efb:	test   rsi,0x1
     f02:	je     f29 <botlish_fn_10+0x18b>
     f08:	mov    rsi,QWORD PTR [rsp+0x20]
     f0d:	mov    rax,rsi
     f10:	add    rax,0x2
     f14:	seto   cl
     f17:	test   cl,cl
     f19:	jne    f29 <botlish_fn_10+0x18b>
     f1f:	mov    rsi,QWORD PTR [rsp+0x10]
     f24:	jmp    f40 <botlish_fn_10+0x1a2>
     f29:	mov    edx,0x3
     f2e:	mov    rsi,QWORD PTR [rsp+0x20]
     f33:	mov    rdi,r15
     f36:	call   f3b <botlish_fn_10+0x19d>
			f37: R_X86_64_PLT32	rt_int_add-0x4
     f3b:	mov    rsi,QWORD PTR [rsp+0x10]
     f40:	mov    QWORD PTR [r14],rsi
     f43:	mov    rdx,QWORD PTR [rsp+0x18]
     f48:	mov    QWORD PTR [r14+0x8],rdx
     f4c:	mov    QWORD PTR [r14+0x10],rax
     f50:	mov    QWORD PTR [rsp+0x10],rsi
     f55:	mov    QWORD PTR [rsp+0x20],rax
     f5a:	jmp    e03 <botlish_fn_10+0x65>
     f5f:	mov    rdx,QWORD PTR [rsp+0x18]
     f64:	mov    rsi,QWORD PTR [rsp+0x10]
     f69:	mov    rcx,QWORD PTR [rsp+0x20]
     f6e:	mov    rdi,r15
     f71:	call   f76 <botlish_fn_10+0x1d8>
			f72: R_X86_64_PLT32	rt_substr-0x4
     f76:	test   rax,rax
     f79:	jne    fb0 <botlish_fn_10+0x212>
     f7f:	mov    rdi,r15
     f82:	mov    rdi,r15
     f85:	mov    QWORD PTR [rdi],r14
     f88:	xor    rdx,rdx
     f8b:	mov    rax,rdx
     f8e:	mov    rbx,QWORD PTR [rsp+0x30]
     f93:	mov    r12,QWORD PTR [rsp+0x38]
     f98:	mov    r13,QWORD PTR [rsp+0x40]
     f9d:	mov    r14,QWORD PTR [rsp+0x48]
     fa2:	mov    r15,QWORD PTR [rsp+0x50]
     fa7:	add    rsp,0x60
     fab:	mov    rsp,rbp
     fae:	pop    rbp
     faf:	ret
     fb0:	mov    rdi,r15
     fb3:	mov    QWORD PTR [rdi],r14
     fb6:	mov    rdx,QWORD PTR [rsp+0x20]
     fbb:	mov    rbx,QWORD PTR [rsp+0x30]
     fc0:	mov    r12,QWORD PTR [rsp+0x38]
     fc5:	mov    r13,QWORD PTR [rsp+0x40]
     fca:	mov    r14,QWORD PTR [rsp+0x48]
     fcf:	mov    r15,QWORD PTR [rsp+0x50]
     fd4:	add    rsp,0x60
     fd8:	mov    rsp,rbp
     fdb:	pop    rbp
     fdc:	ret
     fdd:	mov    r15,rdi
     fe0:	call   fe5 <botlish_fn_10+0x247>
			fe1: R_X86_64_PLT32	rt_stack_overflow-0x4
     fe5:	xor    rdx,rdx
     fe8:	mov    rax,rdx
     feb:	mov    rbx,QWORD PTR [rsp+0x30]
     ff0:	mov    r12,QWORD PTR [rsp+0x38]
     ff5:	mov    r13,QWORD PTR [rsp+0x40]
     ffa:	mov    r14,QWORD PTR [rsp+0x48]
     fff:	mov    r15,QWORD PTR [rsp+0x50]
    1004:	add    rsp,0x60
    1008:	mov    rsp,rbp
    100b:	pop    rbp
    100c:	ret

000000000000100d <botlish_entry_10: scan_unquoted<str, int, int>>:
    100d:	push   rbp
    100e:	mov    rbp,rsp
    1011:	ud2

0000000000001013 <botlish_fn_11: scan_quoted<str, int, str>>:
    1013:	push   rbp
    1014:	mov    rbp,rsp
    1017:	sub    rsp,0x50
    101b:	mov    QWORD PTR [rsp+0x20],rbx
    1020:	mov    QWORD PTR [rsp+0x28],r12
    1025:	mov    QWORD PTR [rsp+0x30],r13
    102a:	mov    QWORD PTR [rsp+0x38],r14
    102f:	mov    QWORD PTR [rsp+0x40],r15
    1034:	mov    r13,QWORD PTR [rdi]
    1037:	mov    rax,QWORD PTR [rdi+0x8]
    103b:	lea    r8,[r13+0x28]
    103f:	cmp    r8,rax
    1042:	ja     1314 <botlish_fn_11+0x301>
    1048:	lea    rax,[r13+0x28]
    104c:	mov    QWORD PTR [rdi],rax
    104f:	mov    r14,rdi
    1052:	mov    QWORD PTR [r13+0x18],0x0
    105a:	mov    QWORD PTR [r13+0x20],0x0
    1062:	mov    QWORD PTR [r13+0x0],rsi
    1066:	mov    QWORD PTR [r13+0x8],rdx
    106a:	mov    QWORD PTR [r13+0x10],rcx
    106e:	lea    rbx,[rsp]
    1072:	mov    r12,rsi
    1075:	mov    r15,rdx
    1078:	mov    QWORD PTR [rsp+0x10],rcx
    107d:	mov    rdx,r15
    1080:	mov    rsi,r12
    1083:	mov    rdi,r14
    1086:	call   108b <botlish_fn_11+0x78>
			1087: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    108b:	test   rax,rax
    108e:	jne    109c <botlish_fn_11+0x89>
    1094:	mov    rdi,r14
    1097:	jmp    12cd <botlish_fn_11+0x2ba>
    109c:	mov    QWORD PTR [r13+0x18],rax
    10a0:	mov    rdi,r14
    10a3:	mov    QWORD PTR [rsp+0x18],rax
    10a8:	mov    rdx,QWORD PTR [rdi+0x10]
    10ac:	mov    rsi,QWORD PTR [rdx+0x18]
    10b0:	mov    edx,0x1
    10b5:	mov    ecx,0x3
    10ba:	mov    r8,QWORD PTR [rsp+0x18]
    10bf:	call   10c4 <botlish_fn_11+0xb1>
			10c0: R_X86_64_PLT32	rt_str_region_eq-0x4
    10c4:	cmp    rax,0x6
    10c8:	je     1155 <botlish_fn_11+0x142>
    10ce:	mov    QWORD PTR [r13+0x20],0x3
    10d6:	mov    rsi,r15
    10d9:	test   rsi,0x1
    10e0:	je     1102 <botlish_fn_11+0xef>
    10e6:	mov    r8,rsi
    10e9:	add    r8,0x2
    10ed:	seto   r10b
    10f1:	test   r10b,r10b
    10f4:	jne    1102 <botlish_fn_11+0xef>
    10fa:	mov    rsi,r8
    10fd:	jmp    1112 <botlish_fn_11+0xff>
    1102:	mov    edx,0x3
    1107:	mov    rdi,r14
    110a:	call   110f <botlish_fn_11+0xfc>
			110b: R_X86_64_PLT32	rt_int_add-0x4
    110f:	mov    rsi,rax
    1112:	mov    QWORD PTR [r13+0x8],rsi
    1116:	mov    r15,rsi
    1119:	mov    rsi,QWORD PTR [rsp+0x10]
    111e:	mov    rdx,QWORD PTR [rsp+0x18]
    1123:	mov    rdi,r14
    1126:	call   112b <botlish_fn_11+0x118>
			1127: R_X86_64_PLT32	rt_str_cat-0x4
    112b:	test   rax,rax
    112e:	jne    113c <botlish_fn_11+0x129>
    1134:	mov    rdi,r14
    1137:	jmp    12cd <botlish_fn_11+0x2ba>
    113c:	mov    QWORD PTR [r13+0x0],r12
    1140:	mov    rsi,r15
    1143:	mov    QWORD PTR [r13+0x8],rsi
    1147:	mov    QWORD PTR [r13+0x10],rax
    114b:	mov    QWORD PTR [rsp+0x10],rax
    1150:	jmp    107d <botlish_fn_11+0x6a>
    1155:	mov    QWORD PTR [r13+0x18],0x3
    115d:	mov    rsi,r15
    1160:	test   rsi,0x1
    1167:	je     1182 <botlish_fn_11+0x16f>
    116d:	mov    rsi,r15
    1170:	mov    rdx,rsi
    1173:	add    rdx,0x2
    1177:	seto   al
    117a:	test   al,al
    117c:	je     1195 <botlish_fn_11+0x182>
    1182:	mov    edx,0x3
    1187:	mov    rsi,r15
    118a:	mov    rdi,r14
    118d:	call   1192 <botlish_fn_11+0x17f>
			118e: R_X86_64_PLT32	rt_int_add-0x4
    1192:	mov    rdx,rax
    1195:	mov    QWORD PTR [r13+0x18],rdx
    1199:	mov    rcx,rbx
    119c:	mov    rsi,r12
    119f:	mov    rdi,r14
    11a2:	call   11a7 <botlish_fn_11+0x194>
			11a3: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    11a7:	test   rax,rax
    11aa:	mov    rsi,rax
    11ad:	jne    11bb <botlish_fn_11+0x1a8>
    11b3:	mov    rdi,r14
    11b6:	jmp    12cd <botlish_fn_11+0x2ba>
    11bb:	mov    rdx,QWORD PTR [rsp]
    11bf:	mov    rcx,QWORD PTR [rsp+0x8]
    11c4:	mov    rdi,r14
    11c7:	mov    rax,QWORD PTR [rdi+0x10]
    11cb:	mov    r8,QWORD PTR [rax+0x18]
    11cf:	call   11d4 <botlish_fn_11+0x1c1>
			11d0: R_X86_64_PLT32	rt_str_region_eq-0x4
    11d4:	cmp    rax,0x6
    11d8:	je     1256 <botlish_fn_11+0x243>
    11de:	mov    QWORD PTR [r13+0x0],0x3
    11e6:	mov    rsi,r15
    11e9:	test   rsi,0x1
    11f0:	je     1213 <botlish_fn_11+0x200>
    11f6:	mov    rsi,r15
    11f9:	mov    rdx,rsi
    11fc:	add    rdx,0x2
    1200:	seto   al
    1203:	test   al,al
    1205:	jne    1213 <botlish_fn_11+0x200>
    120b:	mov    rdi,r14
    120e:	jmp    1229 <botlish_fn_11+0x216>
    1213:	mov    edx,0x3
    1218:	mov    rsi,r15
    121b:	mov    rdi,r14
    121e:	call   1223 <botlish_fn_11+0x210>
			121f: R_X86_64_PLT32	rt_int_add-0x4
    1223:	mov    rdx,rax
    1226:	mov    rdi,r14
    1229:	mov    rdi,r14
    122c:	mov    QWORD PTR [rdi],r13
    122f:	mov    rax,QWORD PTR [rsp+0x10]
    1234:	mov    rbx,QWORD PTR [rsp+0x20]
    1239:	mov    r12,QWORD PTR [rsp+0x28]
    123e:	mov    r13,QWORD PTR [rsp+0x30]
    1243:	mov    r14,QWORD PTR [rsp+0x38]
    1248:	mov    r15,QWORD PTR [rsp+0x40]
    124d:	add    rsp,0x50
    1251:	mov    rsp,rbp
    1254:	pop    rbp
    1255:	ret
    1256:	mov    QWORD PTR [r13+0x18],0x5
    125e:	mov    rsi,r15
    1261:	test   rsi,0x1
    1268:	je     128e <botlish_fn_11+0x27b>
    126e:	mov    rsi,r15
    1271:	mov    rax,rsi
    1274:	add    rax,0x4
    1278:	seto   cl
    127b:	test   cl,cl
    127d:	jne    128e <botlish_fn_11+0x27b>
    1283:	mov    rsi,rax
    1286:	mov    r15,rax
    1289:	jmp    12a4 <botlish_fn_11+0x291>
    128e:	mov    edx,0x5
    1293:	mov    rsi,r15
    1296:	mov    rdi,r14
    1299:	call   129e <botlish_fn_11+0x28b>
			129a: R_X86_64_PLT32	rt_int_add-0x4
    129e:	mov    rsi,rax
    12a1:	mov    r15,rax
    12a4:	mov    QWORD PTR [r13+0x8],rsi
    12a8:	mov    rdi,r14
    12ab:	mov    rax,QWORD PTR [rdi+0x10]
    12af:	mov    rdx,QWORD PTR [rax+0x18]
    12b3:	mov    QWORD PTR [r13+0x18],rdx
    12b7:	mov    rsi,QWORD PTR [rsp+0x10]
    12bc:	call   12c1 <botlish_fn_11+0x2ae>
			12bd: R_X86_64_PLT32	rt_str_cat-0x4
    12c1:	test   rax,rax
    12c4:	jne    12fb <botlish_fn_11+0x2e8>
    12ca:	mov    rdi,r14
    12cd:	mov    rdi,r14
    12d0:	mov    QWORD PTR [rdi],r13
    12d3:	xor    rdx,rdx
    12d6:	mov    rax,rdx
    12d9:	mov    rbx,QWORD PTR [rsp+0x20]
    12de:	mov    r12,QWORD PTR [rsp+0x28]
    12e3:	mov    r13,QWORD PTR [rsp+0x30]
    12e8:	mov    r14,QWORD PTR [rsp+0x38]
    12ed:	mov    r15,QWORD PTR [rsp+0x40]
    12f2:	add    rsp,0x50
    12f6:	mov    rsp,rbp
    12f9:	pop    rbp
    12fa:	ret
    12fb:	mov    QWORD PTR [r13+0x0],r12
    12ff:	mov    rsi,r15
    1302:	mov    QWORD PTR [r13+0x8],rsi
    1306:	mov    QWORD PTR [r13+0x10],rax
    130a:	mov    QWORD PTR [rsp+0x10],rax
    130f:	jmp    107d <botlish_fn_11+0x6a>
    1314:	mov    r14,rdi
    1317:	call   131c <botlish_fn_11+0x309>
			1318: R_X86_64_PLT32	rt_stack_overflow-0x4
    131c:	xor    rdx,rdx
    131f:	mov    rax,rdx
    1322:	mov    rbx,QWORD PTR [rsp+0x20]
    1327:	mov    r12,QWORD PTR [rsp+0x28]
    132c:	mov    r13,QWORD PTR [rsp+0x30]
    1331:	mov    r14,QWORD PTR [rsp+0x38]
    1336:	mov    r15,QWORD PTR [rsp+0x40]
    133b:	add    rsp,0x50
    133f:	mov    rsp,rbp
    1342:	pop    rbp
    1343:	ret

0000000000001344 <botlish_entry_11: scan_quoted<str, int, str>>:
    1344:	push   rbp
    1345:	mov    rbp,rsp
    1348:	ud2

000000000000134a <botlish_fn_12: scan_field<str, int>>:
    134a:	push   rbp
    134b:	mov    rbp,rsp
    134e:	sub    rsp,0x30
    1352:	mov    QWORD PTR [rsp+0x10],rbx
    1357:	mov    QWORD PTR [rsp+0x18],r12
    135c:	mov    QWORD PTR [rsp+0x20],r13
    1361:	mov    QWORD PTR [rsp+0x28],r14
    1366:	mov    rbx,QWORD PTR [rdi]
    1369:	mov    rax,QWORD PTR [rdi+0x8]
    136d:	lea    rcx,[rbx+0x18]
    1371:	cmp    rcx,rax
    1374:	ja     14d6 <botlish_fn_12+0x18c>
    137a:	lea    rax,[rbx+0x18]
    137e:	mov    QWORD PTR [rdi],rax
    1381:	mov    r12,rdi
    1384:	mov    QWORD PTR [rbx+0x10],0x0
    138c:	mov    QWORD PTR [rbx],rsi
    138f:	mov    r13,rsi
    1392:	mov    QWORD PTR [rbx+0x8],rdx
    1396:	mov    r14,rdx
    1399:	lea    rcx,[rsp]
    139d:	mov    rdx,r14
    13a0:	mov    rsi,r13
    13a3:	mov    rdi,r12
    13a6:	call   13ab <botlish_fn_12+0x61>
			13a7: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    13ab:	test   rax,rax
    13ae:	mov    rsi,rax
    13b1:	jne    13bf <botlish_fn_12+0x75>
    13b7:	mov    rdi,r12
    13ba:	jmp    148a <botlish_fn_12+0x140>
    13bf:	mov    rdx,QWORD PTR [rsp]
    13c3:	mov    rcx,QWORD PTR [rsp+0x8]
    13c8:	mov    rdi,r12
    13cb:	mov    rax,QWORD PTR [rdi+0x10]
    13cf:	mov    r8,QWORD PTR [rax+0x18]
    13d3:	call   13d8 <botlish_fn_12+0x8e>
			13d4: R_X86_64_PLT32	rt_str_region_eq-0x4
    13d8:	cmp    rax,0x6
    13dc:	je     1427 <botlish_fn_12+0xdd>
    13e2:	mov    rcx,r14
    13e5:	mov    rsi,r13
    13e8:	mov    rdi,r12
    13eb:	mov    rdx,rcx
    13ee:	call   13f3 <botlish_fn_12+0xa9>
			13ef: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
    13f3:	test   rax,rax
    13f6:	jne    1404 <botlish_fn_12+0xba>
    13fc:	mov    rdi,r12
    13ff:	jmp    148a <botlish_fn_12+0x140>
    1404:	mov    rdi,r12
    1407:	mov    QWORD PTR [rdi],rbx
    140a:	mov    rbx,QWORD PTR [rsp+0x10]
    140f:	mov    r12,QWORD PTR [rsp+0x18]
    1414:	mov    r13,QWORD PTR [rsp+0x20]
    1419:	mov    r14,QWORD PTR [rsp+0x28]
    141e:	add    rsp,0x30
    1422:	mov    rsp,rbp
    1425:	pop    rbp
    1426:	ret
    1427:	mov    QWORD PTR [rbx+0x10],0x3
    142f:	mov    rdx,r14
    1432:	test   rdx,0x1
    1439:	je     1451 <botlish_fn_12+0x107>
    143f:	mov    rdx,r14
    1442:	add    rdx,0x2
    1446:	seto   al
    1449:	test   al,al
    144b:	je     1464 <botlish_fn_12+0x11a>
    1451:	mov    edx,0x3
    1456:	mov    rsi,r14
    1459:	mov    rdi,r12
    145c:	call   1461 <botlish_fn_12+0x117>
			145d: R_X86_64_PLT32	rt_int_add-0x4
    1461:	mov    rdx,rax
    1464:	mov    QWORD PTR [rbx+0x8],rdx
    1468:	mov    rdi,r12
    146b:	mov    rax,QWORD PTR [rdi+0x10]
    146f:	mov    rcx,QWORD PTR [rax]
    1472:	mov    QWORD PTR [rbx+0x10],rcx
    1476:	mov    rsi,r13
    1479:	call   147e <botlish_fn_12+0x134>
			147a: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
    147e:	test   rax,rax
    1481:	jne    14b3 <botlish_fn_12+0x169>
    1487:	mov    rdi,r12
    148a:	mov    rdi,r12
    148d:	mov    QWORD PTR [rdi],rbx
    1490:	xor    rdx,rdx
    1493:	mov    rax,rdx
    1496:	mov    rbx,QWORD PTR [rsp+0x10]
    149b:	mov    r12,QWORD PTR [rsp+0x18]
    14a0:	mov    r13,QWORD PTR [rsp+0x20]
    14a5:	mov    r14,QWORD PTR [rsp+0x28]
    14aa:	add    rsp,0x30
    14ae:	mov    rsp,rbp
    14b1:	pop    rbp
    14b2:	ret
    14b3:	mov    rdi,r12
    14b6:	mov    QWORD PTR [rdi],rbx
    14b9:	mov    rbx,QWORD PTR [rsp+0x10]
    14be:	mov    r12,QWORD PTR [rsp+0x18]
    14c3:	mov    r13,QWORD PTR [rsp+0x20]
    14c8:	mov    r14,QWORD PTR [rsp+0x28]
    14cd:	add    rsp,0x30
    14d1:	mov    rsp,rbp
    14d4:	pop    rbp
    14d5:	ret
    14d6:	mov    r12,rdi
    14d9:	call   14de <botlish_fn_12+0x194>
			14da: R_X86_64_PLT32	rt_stack_overflow-0x4
    14de:	xor    rdx,rdx
    14e1:	mov    rax,rdx
    14e4:	mov    rbx,QWORD PTR [rsp+0x10]
    14e9:	mov    r12,QWORD PTR [rsp+0x18]
    14ee:	mov    r13,QWORD PTR [rsp+0x20]
    14f3:	mov    r14,QWORD PTR [rsp+0x28]
    14f8:	add    rsp,0x30
    14fc:	mov    rsp,rbp
    14ff:	pop    rbp
    1500:	ret

0000000000001501 <botlish_entry_12: scan_field<str, int>>:
    1501:	push   rbp
    1502:	mov    rbp,rsp
    1505:	ud2

0000000000001507 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
    1507:	push   rbp
    1508:	mov    rbp,rsp
    150b:	sub    rsp,0x70
    150f:	mov    QWORD PTR [rsp+0x40],rbx
    1514:	mov    QWORD PTR [rsp+0x48],r12
    1519:	mov    QWORD PTR [rsp+0x50],r13
    151e:	mov    QWORD PTR [rsp+0x58],r14
    1523:	mov    QWORD PTR [rsp+0x60],r15
    1528:	mov    r13,QWORD PTR [rdi]
    152b:	mov    rax,QWORD PTR [rdi+0x8]
    152f:	lea    r9,[r13+0x28]
    1533:	cmp    r9,rax
    1536:	ja     17f7 <botlish_fn_13+0x2f0>
    153c:	lea    rax,[r13+0x28]
    1540:	mov    QWORD PTR [rdi],rax
    1543:	mov    QWORD PTR [rsp+0x10],rdi
    1548:	mov    QWORD PTR [r13+0x20],0x0
    1550:	mov    QWORD PTR [r13+0x0],rsi
    1554:	mov    QWORD PTR [r13+0x8],rdx
    1558:	mov    QWORD PTR [r13+0x10],rcx
    155c:	mov    QWORD PTR [r13+0x18],r8
    1560:	lea    rbx,[rsp]
    1564:	mov    r12,rsi
    1567:	mov    r14,r8
    156a:	mov    r15,rcx
    156d:	mov    rsi,r12
    1570:	mov    rdi,QWORD PTR [rsp+0x10]
    1575:	call   157a <botlish_fn_13+0x73>
			1576: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
    157a:	test   rax,rax
    157d:	jne    158d <botlish_fn_13+0x86>
    1583:	mov    rdi,QWORD PTR [rsp+0x10]
    1588:	jmp    16ce <botlish_fn_13+0x1c7>
    158d:	mov    QWORD PTR [r13+0x8],rax
    1591:	mov    rcx,rax
    1594:	mov    QWORD PTR [r13+0x20],rdx
    1598:	mov    QWORD PTR [rsp+0x30],rdx
    159d:	mov    rsi,r15
    15a0:	mov    rdx,r14
    15a3:	mov    rdi,QWORD PTR [rsp+0x10]
    15a8:	call   15ad <botlish_fn_13+0xa6>
			15a9: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    15ad:	test   rax,rax
    15b0:	jne    15c0 <botlish_fn_13+0xb9>
    15b6:	mov    rdi,QWORD PTR [rsp+0x10]
    15bb:	jmp    16ce <botlish_fn_13+0x1c7>
    15c0:	mov    QWORD PTR [r13+0x8],rax
    15c4:	mov    QWORD PTR [rsp+0x20],rax
    15c9:	mov    QWORD PTR [r13+0x10],rdx
    15cd:	mov    QWORD PTR [rsp+0x28],rdx
    15d2:	mov    rcx,rbx
    15d5:	mov    rdx,QWORD PTR [rsp+0x30]
    15da:	mov    rsi,r12
    15dd:	mov    rdi,QWORD PTR [rsp+0x10]
    15e2:	call   15e7 <botlish_fn_13+0xe0>
			15e3: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    15e7:	test   rax,rax
    15ea:	mov    QWORD PTR [rsp+0x18],rax
    15ef:	jne    15ff <botlish_fn_13+0xf8>
    15f5:	mov    rdi,QWORD PTR [rsp+0x10]
    15fa:	jmp    16ce <botlish_fn_13+0x1c7>
    15ff:	mov    r15,QWORD PTR [rsp]
    1603:	mov    r14,QWORD PTR [rsp+0x8]
    1608:	mov    rdi,QWORD PTR [rsp+0x10]
    160d:	mov    rcx,QWORD PTR [rdi+0x10]
    1611:	mov    r8,QWORD PTR [rcx+0x8]
    1615:	mov    rcx,r14
    1618:	mov    rdx,r15
    161b:	mov    rsi,QWORD PTR [rsp+0x18]
    1620:	call   1625 <botlish_fn_13+0x11e>
			1621: R_X86_64_PLT32	rt_str_region_eq-0x4
    1625:	cmp    rax,0x6
    1629:	je     1786 <botlish_fn_13+0x27f>
    162f:	mov    rdi,QWORD PTR [rsp+0x10]
    1634:	mov    rsi,QWORD PTR [rdi+0x10]
    1638:	mov    r8,QWORD PTR [rsi+0x10]
    163c:	mov    rcx,r14
    163f:	mov    rdx,r15
    1642:	mov    rsi,QWORD PTR [rsp+0x18]
    1647:	call   164c <botlish_fn_13+0x145>
			1648: R_X86_64_PLT32	rt_str_region_eq-0x4
    164c:	cmp    rax,0x6
    1650:	je     16ac <botlish_fn_13+0x1a5>
    1656:	mov    rdx,QWORD PTR [rsp+0x28]
    165b:	mov    rsi,QWORD PTR [rsp+0x20]
    1660:	mov    rdi,QWORD PTR [rsp+0x10]
    1665:	call   166a <botlish_fn_13+0x163>
			1666: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    166a:	test   rax,rax
    166d:	jne    167d <botlish_fn_13+0x176>
    1673:	mov    rdi,QWORD PTR [rsp+0x10]
    1678:	jmp    16ce <botlish_fn_13+0x1c7>
    167d:	mov    rdi,QWORD PTR [rsp+0x10]
    1682:	mov    QWORD PTR [rdi],r13
    1685:	mov    rdx,QWORD PTR [rsp+0x30]
    168a:	mov    rbx,QWORD PTR [rsp+0x40]
    168f:	mov    r12,QWORD PTR [rsp+0x48]
    1694:	mov    r13,QWORD PTR [rsp+0x50]
    1699:	mov    r14,QWORD PTR [rsp+0x58]
    169e:	mov    r15,QWORD PTR [rsp+0x60]
    16a3:	add    rsp,0x70
    16a7:	mov    rsp,rbp
    16aa:	pop    rbp
    16ab:	ret
    16ac:	mov    rdx,QWORD PTR [rsp+0x28]
    16b1:	mov    rsi,QWORD PTR [rsp+0x20]
    16b6:	mov    rdi,QWORD PTR [rsp+0x10]
    16bb:	call   16c0 <botlish_fn_13+0x1b9>
			16bc: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    16c0:	test   rax,rax
    16c3:	jne    16fe <botlish_fn_13+0x1f7>
    16c9:	mov    rdi,QWORD PTR [rsp+0x10]
    16ce:	mov    rdi,QWORD PTR [rsp+0x10]
    16d3:	mov    QWORD PTR [rdi],r13
    16d6:	xor    rdx,rdx
    16d9:	mov    rax,rdx
    16dc:	mov    rbx,QWORD PTR [rsp+0x40]
    16e1:	mov    r12,QWORD PTR [rsp+0x48]
    16e6:	mov    r13,QWORD PTR [rsp+0x50]
    16eb:	mov    r14,QWORD PTR [rsp+0x58]
    16f0:	mov    r15,QWORD PTR [rsp+0x60]
    16f5:	add    rsp,0x70
    16f9:	mov    rsp,rbp
    16fc:	pop    rbp
    16fd:	ret
    16fe:	mov    QWORD PTR [r13+0x0],rax
    1702:	mov    rbx,rax
    1705:	mov    QWORD PTR [r13+0x8],0x3
    170d:	mov    rdx,QWORD PTR [rsp+0x30]
    1712:	test   rdx,0x1
    1719:	je     173d <botlish_fn_13+0x236>
    171f:	mov    rdx,QWORD PTR [rsp+0x30]
    1724:	add    rdx,0x2
    1728:	seto   al
    172b:	test   al,al
    172d:	jne    173d <botlish_fn_13+0x236>
    1733:	mov    rdi,QWORD PTR [rsp+0x10]
    1738:	jmp    1759 <botlish_fn_13+0x252>
    173d:	mov    edx,0x3
    1742:	mov    rsi,QWORD PTR [rsp+0x30]
    1747:	mov    rdi,QWORD PTR [rsp+0x10]
    174c:	call   1751 <botlish_fn_13+0x24a>
			174d: R_X86_64_PLT32	rt_int_add-0x4
    1751:	mov    rdx,rax
    1754:	mov    rdi,QWORD PTR [rsp+0x10]
    1759:	mov    rdi,QWORD PTR [rsp+0x10]
    175e:	mov    QWORD PTR [rdi],r13
    1761:	mov    rax,rbx
    1764:	mov    rbx,QWORD PTR [rsp+0x40]
    1769:	mov    r12,QWORD PTR [rsp+0x48]
    176e:	mov    r13,QWORD PTR [rsp+0x50]
    1773:	mov    r14,QWORD PTR [rsp+0x58]
    1778:	mov    r15,QWORD PTR [rsp+0x60]
    177d:	add    rsp,0x70
    1781:	mov    rsp,rbp
    1784:	pop    rbp
    1785:	ret
    1786:	mov    rsi,QWORD PTR [rsp+0x30]
    178b:	mov    edx,0x3
    1790:	mov    r9,rdx
    1793:	mov    QWORD PTR [r13+0x18],0x3
    179b:	test   rsi,0x1
    17a2:	jne    17b0 <botlish_fn_13+0x2a9>
    17a8:	mov    rdx,r9
    17ab:	jmp    17c5 <botlish_fn_13+0x2be>
    17b0:	mov    rdx,rsi
    17b3:	add    rdx,0x2
    17b7:	seto   al
    17ba:	test   al,al
    17bc:	je     17d2 <botlish_fn_13+0x2cb>
    17c2:	mov    rdx,r9
    17c5:	mov    rdi,QWORD PTR [rsp+0x10]
    17ca:	call   17cf <botlish_fn_13+0x2c8>
			17cb: R_X86_64_PLT32	rt_int_add-0x4
    17cf:	mov    rdx,rax
    17d2:	mov    QWORD PTR [r13+0x0],r12
    17d6:	mov    QWORD PTR [r13+0x8],rdx
    17da:	mov    rsi,QWORD PTR [rsp+0x20]
    17df:	mov    QWORD PTR [r13+0x10],rsi
    17e3:	mov    rax,QWORD PTR [rsp+0x28]
    17e8:	mov    QWORD PTR [r13+0x18],rax
    17ec:	mov    r14,rax
    17ef:	mov    r15,rsi
    17f2:	jmp    156d <botlish_fn_13+0x66>
    17f7:	mov    QWORD PTR [rsp+0x10],rdi
    17fc:	call   1801 <botlish_fn_13+0x2fa>
			17fd: R_X86_64_PLT32	rt_stack_overflow-0x4
    1801:	xor    rdx,rdx
    1804:	mov    rax,rdx
    1807:	mov    rbx,QWORD PTR [rsp+0x40]
    180c:	mov    r12,QWORD PTR [rsp+0x48]
    1811:	mov    r13,QWORD PTR [rsp+0x50]
    1816:	mov    r14,QWORD PTR [rsp+0x58]
    181b:	mov    r15,QWORD PTR [rsp+0x60]
    1820:	add    rsp,0x70
    1824:	mov    rsp,rbp
    1827:	pop    rbp
    1828:	ret

0000000000001829 <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    1829:	push   rbp
    182a:	mov    rbp,rsp
    182d:	ud2
	...

0000000000001830 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    1830:	push   rbp
    1831:	mov    rbp,rsp
    1834:	sub    rsp,0x40
    1838:	mov    QWORD PTR [rsp+0x10],rbx
    183d:	mov    QWORD PTR [rsp+0x18],r12
    1842:	mov    QWORD PTR [rsp+0x20],r13
    1847:	mov    QWORD PTR [rsp+0x28],r14
    184c:	mov    QWORD PTR [rsp+0x30],r15
    1851:	mov    r12,QWORD PTR [rdi]
    1854:	mov    rax,QWORD PTR [rdi+0x8]
    1858:	lea    r9,[r12+0x30]
    185d:	cmp    r9,rax
    1860:	ja     1a09 <botlish_fn_14+0x1d9>
    1866:	lea    rax,[r12+0x30]
    186b:	mov    QWORD PTR [rdi],rax
    186e:	mov    r14,rdi
    1871:	mov    QWORD PTR [r12+0x20],0x0
    187a:	mov    QWORD PTR [r12+0x28],0x0
    1883:	mov    QWORD PTR [r12],rsi
    1887:	mov    QWORD PTR [r12+0x8],rdx
    188c:	mov    r13,rdx
    188f:	mov    QWORD PTR [r12+0x10],rcx
    1894:	mov    QWORD PTR [r12+0x18],r8
    1899:	mov    rbx,rsi
    189c:	mov    r15,r8
    189f:	mov    QWORD PTR [rsp],rcx
    18a3:	mov    rsi,rbx
    18a6:	mov    rdi,r14
    18a9:	call   18ae <botlish_fn_14+0x7e>
			18aa: R_X86_64_PLT32	rt_str_len-0x4
    18ae:	mov    rcx,r13
    18b1:	and    rcx,rax
    18b4:	mov    rdx,rax
    18b7:	test   rcx,0x1
    18be:	jne    18e4 <botlish_fn_14+0xb4>
    18c4:	mov    rsi,r13
    18c7:	mov    rdi,r14
    18ca:	call   18cf <botlish_fn_14+0x9f>
			18cb: R_X86_64_PLT32	rt_int_cmp-0x4
    18cf:	mov    ecx,0x2
    18d4:	test   rax,rax
    18d7:	cmovge rcx,QWORD PTR [rip+0x159]        # 1a38 <botlish_fn_14+0x208>
    18df:	jmp    18f7 <botlish_fn_14+0xc7>
    18e4:	mov    ecx,0x2
    18e9:	mov    rax,r13
    18ec:	cmp    rax,rdx
    18ef:	cmovge rcx,QWORD PTR [rip+0x141]        # 1a38 <botlish_fn_14+0x208>
    18f7:	cmp    rcx,0x6
    18fb:	je     199b <botlish_fn_14+0x16b>
    1901:	mov    rdi,r14
    1904:	call   1909 <botlish_fn_14+0xd9>
			1905: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1909:	test   rax,rax
    190c:	jne    191a <botlish_fn_14+0xea>
    1912:	mov    rdi,r14
    1915:	jmp    19b6 <botlish_fn_14+0x186>
    191a:	mov    QWORD PTR [r12+0x20],rax
    191f:	mov    rcx,rax
    1922:	mov    QWORD PTR [r12+0x28],rdx
    1927:	mov    r8,rdx
    192a:	mov    rdx,r13
    192d:	mov    rsi,rbx
    1930:	mov    rdi,r14
    1933:	call   1938 <botlish_fn_14+0x108>
			1934: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    1938:	test   rax,rax
    193b:	jne    1949 <botlish_fn_14+0x119>
    1941:	mov    rdi,r14
    1944:	jmp    19b6 <botlish_fn_14+0x186>
    1949:	mov    QWORD PTR [r12+0x8],rax
    194e:	mov    rcx,rax
    1951:	mov    QWORD PTR [r12+0x20],rdx
    1956:	mov    r13,rdx
    1959:	mov    rsi,QWORD PTR [rsp]
    195d:	mov    rdx,r15
    1960:	mov    rdi,r14
    1963:	call   1968 <botlish_fn_14+0x138>
			1964: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1968:	test   rax,rax
    196b:	jne    1979 <botlish_fn_14+0x149>
    1971:	mov    rdi,r14
    1974:	jmp    19b6 <botlish_fn_14+0x186>
    1979:	mov    QWORD PTR [r12],rbx
    197d:	mov    rcx,r13
    1980:	mov    QWORD PTR [r12+0x8],rcx
    1985:	mov    QWORD PTR [r12+0x10],rax
    198a:	mov    QWORD PTR [r12+0x18],rdx
    198f:	mov    r15,rdx
    1992:	mov    QWORD PTR [rsp],rax
    1996:	jmp    18a3 <botlish_fn_14+0x73>
    199b:	mov    rdx,r15
    199e:	mov    rsi,QWORD PTR [rsp]
    19a2:	mov    rdi,r14
    19a5:	call   19aa <botlish_fn_14+0x17a>
			19a6: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    19aa:	test   rax,rax
    19ad:	jne    19e1 <botlish_fn_14+0x1b1>
    19b3:	mov    rdi,r14
    19b6:	mov    rdi,r14
    19b9:	mov    QWORD PTR [rdi],r12
    19bc:	xor    rax,rax
    19bf:	mov    rbx,QWORD PTR [rsp+0x10]
    19c4:	mov    r12,QWORD PTR [rsp+0x18]
    19c9:	mov    r13,QWORD PTR [rsp+0x20]
    19ce:	mov    r14,QWORD PTR [rsp+0x28]
    19d3:	mov    r15,QWORD PTR [rsp+0x30]
    19d8:	add    rsp,0x40
    19dc:	mov    rsp,rbp
    19df:	pop    rbp
    19e0:	ret
    19e1:	mov    rdi,r14
    19e4:	mov    QWORD PTR [rdi],r12
    19e7:	mov    rbx,QWORD PTR [rsp+0x10]
    19ec:	mov    r12,QWORD PTR [rsp+0x18]
    19f1:	mov    r13,QWORD PTR [rsp+0x20]
    19f6:	mov    r14,QWORD PTR [rsp+0x28]
    19fb:	mov    r15,QWORD PTR [rsp+0x30]
    1a00:	add    rsp,0x40
    1a04:	mov    rsp,rbp
    1a07:	pop    rbp
    1a08:	ret
    1a09:	mov    r14,rdi
    1a0c:	call   1a11 <botlish_fn_14+0x1e1>
			1a0d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1a11:	xor    rax,rax
    1a14:	mov    rbx,QWORD PTR [rsp+0x10]
    1a19:	mov    r12,QWORD PTR [rsp+0x18]
    1a1e:	mov    r13,QWORD PTR [rsp+0x20]
    1a23:	mov    r14,QWORD PTR [rsp+0x28]
    1a28:	mov    r15,QWORD PTR [rsp+0x30]
    1a2d:	add    rsp,0x40
    1a31:	mov    rsp,rbp
    1a34:	pop    rbp
    1a35:	ret
    1a36:	add    BYTE PTR [rax],al
    1a38:	(bad)
    1a39:	add    BYTE PTR [rax],al
    1a3b:	add    BYTE PTR [rax],al
    1a3d:	add    BYTE PTR [rax],al
	...

0000000000001a40 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    1a40:	push   rbp
    1a41:	mov    rbp,rsp
    1a44:	mov    rsi,QWORD PTR [rdx]
    1a47:	mov    r9,QWORD PTR [rdx+0x8]
    1a4b:	mov    rcx,QWORD PTR [rdx+0x10]
    1a4f:	mov    r8,QWORD PTR [rdx+0x18]
    1a53:	mov    rdx,r9
    1a56:	call   1a5b <botlish_entry_14+0x1b>
			1a57: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1a5b:	mov    rsp,rbp
    1a5e:	pop    rbp
    1a5f:	ret

0000000000001a60 <botlish_fn_15: csv_parse<str>>:
    1a60:	push   rbp
    1a61:	mov    rbp,rsp
    1a64:	sub    rsp,0x20
    1a68:	mov    QWORD PTR [rsp],rbx
    1a6c:	mov    QWORD PTR [rsp+0x8],r12
    1a71:	mov    QWORD PTR [rsp+0x10],r15
    1a76:	mov    r15,QWORD PTR [rdi]
    1a79:	mov    rax,QWORD PTR [rdi+0x8]
    1a7d:	lea    rcx,[r15+0x20]
    1a81:	cmp    rcx,rax
    1a84:	ja     1b32 <botlish_fn_15+0xd2>
    1a8a:	lea    rax,[r15+0x20]
    1a8e:	mov    QWORD PTR [rdi],rax
    1a91:	mov    rbx,rdi
    1a94:	mov    QWORD PTR [r15+0x10],0x0
    1a9c:	mov    QWORD PTR [r15+0x18],0x0
    1aa4:	mov    QWORD PTR [r15],rsi
    1aa7:	mov    r12,rsi
    1aaa:	mov    QWORD PTR [r15+0x8],0x1
    1ab2:	mov    rdi,rbx
    1ab5:	call   1aba <botlish_fn_15+0x5a>
			1ab6: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1aba:	test   rax,rax
    1abd:	jne    1acb <botlish_fn_15+0x6b>
    1ac3:	mov    rdi,rbx
    1ac6:	jmp    1af5 <botlish_fn_15+0x95>
    1acb:	mov    QWORD PTR [r15+0x10],rax
    1acf:	mov    rcx,rax
    1ad2:	mov    QWORD PTR [r15+0x18],rdx
    1ad6:	mov    r8,rdx
    1ad9:	mov    edx,0x1
    1ade:	mov    rsi,r12
    1ae1:	mov    rdi,rbx
    1ae4:	call   1ae9 <botlish_fn_15+0x89>
			1ae5: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1ae9:	test   rax,rax
    1aec:	jne    1b15 <botlish_fn_15+0xb5>
    1af2:	mov    rdi,rbx
    1af5:	mov    rdi,rbx
    1af8:	mov    QWORD PTR [rdi],r15
    1afb:	xor    rax,rax
    1afe:	mov    rbx,QWORD PTR [rsp]
    1b02:	mov    r12,QWORD PTR [rsp+0x8]
    1b07:	mov    r15,QWORD PTR [rsp+0x10]
    1b0c:	add    rsp,0x20
    1b10:	mov    rsp,rbp
    1b13:	pop    rbp
    1b14:	ret
    1b15:	mov    rdi,rbx
    1b18:	mov    QWORD PTR [rdi],r15
    1b1b:	mov    rbx,QWORD PTR [rsp]
    1b1f:	mov    r12,QWORD PTR [rsp+0x8]
    1b24:	mov    r15,QWORD PTR [rsp+0x10]
    1b29:	add    rsp,0x20
    1b2d:	mov    rsp,rbp
    1b30:	pop    rbp
    1b31:	ret
    1b32:	mov    rbx,rdi
    1b35:	call   1b3a <botlish_fn_15+0xda>
			1b36: R_X86_64_PLT32	rt_stack_overflow-0x4
    1b3a:	xor    rax,rax
    1b3d:	mov    rbx,QWORD PTR [rsp]
    1b41:	mov    r12,QWORD PTR [rsp+0x8]
    1b46:	mov    r15,QWORD PTR [rsp+0x10]
    1b4b:	add    rsp,0x20
    1b4f:	mov    rsp,rbp
    1b52:	pop    rbp
    1b53:	ret

0000000000001b54 <botlish_entry_15: csv_parse<str>>:
    1b54:	push   rbp
    1b55:	mov    rbp,rsp
    1b58:	mov    rsi,QWORD PTR [rdx]
    1b5b:	call   1b60 <botlish_entry_15+0xc>
			1b5c: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    1b60:	mov    rsp,rbp
    1b63:	pop    rbp
    1b64:	ret

0000000000001b65 <botlish_fn_16: ht_min_capacity<generic>>:
    1b65:	push   rbp
    1b66:	mov    rbp,rsp
    1b69:	mov    r8,QWORD PTR [rdi]
    1b6c:	mov    r9,QWORD PTR [rdi+0x8]
    1b70:	lea    r10,[r8+0x8]
    1b74:	cmp    r10,r9
    1b77:	ja     1b8a <botlish_fn_16+0x25>
    1b7d:	mov    QWORD PTR [rdi],r8
    1b80:	mov    eax,0x11
    1b85:	mov    rsp,rbp
    1b88:	pop    rbp
    1b89:	ret
    1b8a:	call   1b8f <botlish_fn_16+0x2a>
			1b8b: R_X86_64_PLT32	rt_stack_overflow-0x4
    1b8f:	xor    rax,rax
    1b92:	mov    rsp,rbp
    1b95:	pop    rbp
    1b96:	ret

0000000000001b97 <botlish_entry_16: ht_min_capacity<generic>>:
    1b97:	push   rbp
    1b98:	mov    rbp,rsp
    1b9b:	call   1ba0 <botlish_entry_16+0x9>
			1b9c: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1ba0:	mov    rsp,rbp
    1ba3:	pop    rbp
    1ba4:	ret

0000000000001ba5 <botlish_fn_17: ht_empty_state<generic>>:
    1ba5:	push   rbp
    1ba6:	mov    rbp,rsp
    1ba9:	mov    r8,QWORD PTR [rdi]
    1bac:	mov    r9,QWORD PTR [rdi+0x8]
    1bb0:	lea    r10,[r8+0x8]
    1bb4:	cmp    r10,r9
    1bb7:	ja     1bca <botlish_fn_17+0x25>
    1bbd:	mov    QWORD PTR [rdi],r8
    1bc0:	mov    eax,0x1
    1bc5:	mov    rsp,rbp
    1bc8:	pop    rbp
    1bc9:	ret
    1bca:	call   1bcf <botlish_fn_17+0x2a>
			1bcb: R_X86_64_PLT32	rt_stack_overflow-0x4
    1bcf:	xor    rax,rax
    1bd2:	mov    rsp,rbp
    1bd5:	pop    rbp
    1bd6:	ret

0000000000001bd7 <botlish_entry_17: ht_empty_state<generic>>:
    1bd7:	push   rbp
    1bd8:	mov    rbp,rsp
    1bdb:	call   1be0 <botlish_entry_17+0x9>
			1bdc: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1be0:	mov    rsp,rbp
    1be3:	pop    rbp
    1be4:	ret

0000000000001be5 <botlish_fn_18: ht_occupied_state<generic>>:
    1be5:	push   rbp
    1be6:	mov    rbp,rsp
    1be9:	mov    r8,QWORD PTR [rdi]
    1bec:	mov    r9,QWORD PTR [rdi+0x8]
    1bf0:	lea    r10,[r8+0x8]
    1bf4:	cmp    r10,r9
    1bf7:	ja     1c0a <botlish_fn_18+0x25>
    1bfd:	mov    QWORD PTR [rdi],r8
    1c00:	mov    eax,0x3
    1c05:	mov    rsp,rbp
    1c08:	pop    rbp
    1c09:	ret
    1c0a:	call   1c0f <botlish_fn_18+0x2a>
			1c0b: R_X86_64_PLT32	rt_stack_overflow-0x4
    1c0f:	xor    rax,rax
    1c12:	mov    rsp,rbp
    1c15:	pop    rbp
    1c16:	ret

0000000000001c17 <botlish_entry_18: ht_occupied_state<generic>>:
    1c17:	push   rbp
    1c18:	mov    rbp,rsp
    1c1b:	call   1c20 <botlish_entry_18+0x9>
			1c1c: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    1c20:	mov    rsp,rbp
    1c23:	pop    rbp
    1c24:	ret

0000000000001c25 <botlish_fn_19: ht_tombstone_state<generic>>:
    1c25:	push   rbp
    1c26:	mov    rbp,rsp
    1c29:	mov    r8,QWORD PTR [rdi]
    1c2c:	mov    r9,QWORD PTR [rdi+0x8]
    1c30:	lea    r10,[r8+0x8]
    1c34:	cmp    r10,r9
    1c37:	ja     1c4a <botlish_fn_19+0x25>
    1c3d:	mov    QWORD PTR [rdi],r8
    1c40:	mov    eax,0x5
    1c45:	mov    rsp,rbp
    1c48:	pop    rbp
    1c49:	ret
    1c4a:	call   1c4f <botlish_fn_19+0x2a>
			1c4b: R_X86_64_PLT32	rt_stack_overflow-0x4
    1c4f:	xor    rax,rax
    1c52:	mov    rsp,rbp
    1c55:	pop    rbp
    1c56:	ret

0000000000001c57 <botlish_entry_19: ht_tombstone_state<generic>>:
    1c57:	push   rbp
    1c58:	mov    rbp,rsp
    1c5b:	call   1c60 <botlish_entry_19+0x9>
			1c5c: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    1c60:	mov    rsp,rbp
    1c63:	pop    rbp
    1c64:	ret
    1c65:	add    BYTE PTR [rax],al
	...

0000000000001c68 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    1c68:	push   rbp
    1c69:	mov    rbp,rsp
    1c6c:	sub    rsp,0x30
    1c70:	mov    QWORD PTR [rsp],rbx
    1c74:	mov    QWORD PTR [rsp+0x8],r12
    1c79:	mov    QWORD PTR [rsp+0x10],r13
    1c7e:	mov    QWORD PTR [rsp+0x18],r14
    1c83:	mov    QWORD PTR [rsp+0x20],r15
    1c88:	mov    r13,QWORD PTR [rdi]
    1c8b:	mov    r8,QWORD PTR [rdi+0x8]
    1c8f:	lea    rax,[r13+0x20]
    1c93:	cmp    rax,r8
    1c96:	ja     1e00 <botlish_fn_20+0x198>
    1c9c:	lea    rax,[r13+0x20]
    1ca0:	mov    QWORD PTR [rdi],rax
    1ca3:	mov    r14,rdi
    1ca6:	mov    QWORD PTR [r13+0x18],0x0
    1cae:	mov    QWORD PTR [r13+0x0],rsi
    1cb2:	mov    r12,rsi
    1cb5:	mov    QWORD PTR [r13+0x8],rdx
    1cb9:	mov    QWORD PTR [r13+0x10],rcx
    1cbd:	mov    rbx,rcx
    1cc0:	mov    rsi,rdx
    1cc3:	mov    rax,rsi
    1cc6:	and    rax,rbx
    1cc9:	mov    r15,rsi
    1ccc:	test   rax,0x1
    1cd2:	jne    1cfb <botlish_fn_20+0x93>
    1cd8:	mov    rdx,rbx
    1cdb:	mov    rsi,r15
    1cde:	mov    rdi,r14
    1ce1:	call   1ce6 <botlish_fn_20+0x7e>
			1ce2: R_X86_64_PLT32	rt_int_cmp-0x4
    1ce6:	mov    ecx,0x2
    1ceb:	test   rax,rax
    1cee:	cmovge rcx,QWORD PTR [rip+0x13a]        # 1e30 <botlish_fn_20+0x1c8>
    1cf6:	jmp    1d0e <botlish_fn_20+0xa6>
    1cfb:	mov    ecx,0x2
    1d00:	mov    rsi,r15
    1d03:	cmp    rsi,rbx
    1d06:	cmovge rcx,QWORD PTR [rip+0x122]        # 1e30 <botlish_fn_20+0x1c8>
    1d0e:	cmp    rcx,0x6
    1d12:	je     1dd4 <botlish_fn_20+0x16c>
    1d18:	mov    rdi,r14
    1d1b:	call   1d20 <botlish_fn_20+0xb8>
			1d1c: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1d20:	test   rax,rax
    1d23:	mov    rcx,rax
    1d26:	jne    1d34 <botlish_fn_20+0xcc>
    1d2c:	mov    rdi,r14
    1d2f:	jmp    1d4e <botlish_fn_20+0xe6>
    1d34:	mov    rdx,r15
    1d37:	mov    rsi,r12
    1d3a:	mov    rdi,r14
    1d3d:	call   1d42 <botlish_fn_20+0xda>
			1d3e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1d42:	test   rax,rax
    1d45:	jne    1d78 <botlish_fn_20+0x110>
    1d4b:	mov    rdi,r14
    1d4e:	mov    rdi,r14
    1d51:	mov    QWORD PTR [rdi],r13
    1d54:	xor    rax,rax
    1d57:	mov    rbx,QWORD PTR [rsp]
    1d5b:	mov    r12,QWORD PTR [rsp+0x8]
    1d60:	mov    r13,QWORD PTR [rsp+0x10]
    1d65:	mov    r14,QWORD PTR [rsp+0x18]
    1d6a:	mov    r15,QWORD PTR [rsp+0x20]
    1d6f:	add    rsp,0x30
    1d73:	mov    rsp,rbp
    1d76:	pop    rbp
    1d77:	ret
    1d78:	mov    QWORD PTR [r13+0x18],0x3
    1d80:	mov    rsi,r15
    1d83:	test   rsi,0x1
    1d8a:	je     1dad <botlish_fn_20+0x145>
    1d90:	mov    rsi,r15
    1d93:	mov    rcx,rsi
    1d96:	add    rcx,0x2
    1d9a:	seto   al
    1d9d:	test   al,al
    1d9f:	jne    1dad <botlish_fn_20+0x145>
    1da5:	mov    r15,rcx
    1da8:	jmp    1dc0 <botlish_fn_20+0x158>
    1dad:	mov    edx,0x3
    1db2:	mov    rsi,r15
    1db5:	mov    rdi,r14
    1db8:	call   1dbd <botlish_fn_20+0x155>
			1db9: R_X86_64_PLT32	rt_int_add-0x4
    1dbd:	mov    r15,rax
    1dc0:	mov    QWORD PTR [r13+0x0],r12
    1dc4:	mov    rsi,r15
    1dc7:	mov    QWORD PTR [r13+0x8],rsi
    1dcb:	mov    QWORD PTR [r13+0x10],rbx
    1dcf:	jmp    1cc3 <botlish_fn_20+0x5b>
    1dd4:	mov    rdi,r14
    1dd7:	mov    QWORD PTR [rdi],r13
    1dda:	mov    eax,0xa
    1ddf:	mov    rbx,QWORD PTR [rsp]
    1de3:	mov    r12,QWORD PTR [rsp+0x8]
    1de8:	mov    r13,QWORD PTR [rsp+0x10]
    1ded:	mov    r14,QWORD PTR [rsp+0x18]
    1df2:	mov    r15,QWORD PTR [rsp+0x20]
    1df7:	add    rsp,0x30
    1dfb:	mov    rsp,rbp
    1dfe:	pop    rbp
    1dff:	ret
    1e00:	mov    r14,rdi
    1e03:	call   1e08 <botlish_fn_20+0x1a0>
			1e04: R_X86_64_PLT32	rt_stack_overflow-0x4
    1e08:	xor    rax,rax
    1e0b:	mov    rbx,QWORD PTR [rsp]
    1e0f:	mov    r12,QWORD PTR [rsp+0x8]
    1e14:	mov    r13,QWORD PTR [rsp+0x10]
    1e19:	mov    r14,QWORD PTR [rsp+0x18]
    1e1e:	mov    r15,QWORD PTR [rsp+0x20]
    1e23:	add    rsp,0x30
    1e27:	mov    rsp,rbp
    1e2a:	pop    rbp
    1e2b:	ret
    1e2c:	add    BYTE PTR [rax],al
    1e2e:	add    BYTE PTR [rax],al
    1e30:	(bad)
    1e31:	add    BYTE PTR [rax],al
    1e33:	add    BYTE PTR [rax],al
    1e35:	add    BYTE PTR [rax],al
	...

0000000000001e38 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    1e38:	push   rbp
    1e39:	mov    rbp,rsp
    1e3c:	mov    rsi,QWORD PTR [rdx]
    1e3f:	mov    r8,QWORD PTR [rdx+0x8]
    1e43:	mov    rcx,QWORD PTR [rdx+0x10]
    1e47:	mov    rdx,r8
    1e4a:	call   1e4f <botlish_entry_20+0x17>
			1e4b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1e4f:	mov    rsp,rbp
    1e52:	pop    rbp
    1e53:	ret

0000000000001e54 <botlish_fn_21: ht_alloc<int>>:
    1e54:	push   rbp
    1e55:	mov    rbp,rsp
    1e58:	sub    rsp,0x40
    1e5c:	mov    QWORD PTR [rsp+0x10],rbx
    1e61:	mov    QWORD PTR [rsp+0x18],r12
    1e66:	mov    QWORD PTR [rsp+0x20],r13
    1e6b:	mov    QWORD PTR [rsp+0x28],r14
    1e70:	mov    QWORD PTR [rsp+0x30],r15
    1e75:	mov    rbx,QWORD PTR [rdi]
    1e78:	mov    rax,QWORD PTR [rdi+0x8]
    1e7c:	lea    rcx,[rbx+0x20]
    1e80:	cmp    rcx,rax
    1e83:	ja     207e <botlish_fn_21+0x22a>
    1e89:	lea    rax,[rbx+0x20]
    1e8d:	mov    QWORD PTR [rdi],rax
    1e90:	mov    r12,rdi
    1e93:	mov    QWORD PTR [rbx+0x8],0x0
    1e9b:	mov    QWORD PTR [rbx+0x10],0x0
    1ea3:	mov    QWORD PTR [rbx+0x18],0x0
    1eab:	mov    QWORD PTR [rbx],rsi
    1eae:	mov    r13,rsi
    1eb1:	mov    rsi,r13
    1eb4:	mov    rdi,r12
    1eb7:	call   1ebc <botlish_fn_21+0x68>
			1eb8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1ebc:	test   rax,rax
    1ebf:	jne    1ecd <botlish_fn_21+0x79>
    1ec5:	mov    rdi,r12
    1ec8:	jmp    2027 <botlish_fn_21+0x1d3>
    1ecd:	mov    QWORD PTR [rbx+0x8],rax
    1ed1:	mov    r14,rax
    1ed4:	mov    edx,0x1
    1ed9:	mov    QWORD PTR [rbx+0x10],0x1
    1ee1:	mov    rcx,r13
    1ee4:	mov    rsi,r14
    1ee7:	mov    rdi,r12
    1eea:	call   1eef <botlish_fn_21+0x9b>
			1eeb: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1eef:	test   rax,rax
    1ef2:	jne    1f00 <botlish_fn_21+0xac>
    1ef8:	mov    rdi,r12
    1efb:	jmp    2027 <botlish_fn_21+0x1d3>
    1f00:	mov    rsi,r13
    1f03:	mov    rdi,r12
    1f06:	call   1f0b <botlish_fn_21+0xb7>
			1f07: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1f0b:	test   rax,rax
    1f0e:	jne    1f1c <botlish_fn_21+0xc8>
    1f14:	mov    rdi,r12
    1f17:	jmp    2027 <botlish_fn_21+0x1d3>
    1f1c:	mov    QWORD PTR [rbx+0x10],rax
    1f20:	mov    rsi,r13
    1f23:	mov    r15,rax
    1f26:	mov    rdi,r12
    1f29:	call   1f2e <botlish_fn_21+0xda>
			1f2a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1f2e:	test   rax,rax
    1f31:	jne    1f3f <botlish_fn_21+0xeb>
    1f37:	mov    rdi,r12
    1f3a:	jmp    2027 <botlish_fn_21+0x1d3>
    1f3f:	mov    QWORD PTR [rbx],rax
    1f42:	mov    r13,rax
    1f45:	mov    esi,0xb
    1f4a:	mov    QWORD PTR [rbx+0x18],0xb
    1f52:	mov    rdi,r12
    1f55:	call   1f5a <botlish_fn_21+0x106>
			1f56: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1f5a:	test   rax,rax
    1f5d:	mov    QWORD PTR [rsp],rax
    1f61:	jne    1f6f <botlish_fn_21+0x11b>
    1f67:	mov    rdi,r12
    1f6a:	jmp    2027 <botlish_fn_21+0x1d3>
    1f6f:	mov    edx,0x1
    1f74:	mov    rcx,r14
    1f77:	mov    rsi,QWORD PTR [rsp]
    1f7b:	mov    rdi,r12
    1f7e:	call   1f83 <botlish_fn_21+0x12f>
			1f7f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1f83:	test   rax,rax
    1f86:	jne    1f94 <botlish_fn_21+0x140>
    1f8c:	mov    rdi,r12
    1f8f:	jmp    2027 <botlish_fn_21+0x1d3>
    1f94:	mov    edx,0x3
    1f99:	mov    rcx,r15
    1f9c:	mov    rsi,QWORD PTR [rsp]
    1fa0:	mov    rdi,r12
    1fa3:	call   1fa8 <botlish_fn_21+0x154>
			1fa4: R_X86_64_PLT32	rt_mutarray_set-0x4
    1fa8:	test   rax,rax
    1fab:	jne    1fb9 <botlish_fn_21+0x165>
    1fb1:	mov    rdi,r12
    1fb4:	jmp    2027 <botlish_fn_21+0x1d3>
    1fb9:	mov    edx,0x5
    1fbe:	mov    rcx,r13
    1fc1:	mov    rsi,QWORD PTR [rsp]
    1fc5:	mov    rdi,r12
    1fc8:	call   1fcd <botlish_fn_21+0x179>
			1fc9: R_X86_64_PLT32	rt_mutarray_set-0x4
    1fcd:	test   rax,rax
    1fd0:	jne    1fde <botlish_fn_21+0x18a>
    1fd6:	mov    rdi,r12
    1fd9:	jmp    2027 <botlish_fn_21+0x1d3>
    1fde:	mov    edx,0x7
    1fe3:	mov    ecx,0x1
    1fe8:	mov    rsi,QWORD PTR [rsp]
    1fec:	mov    rdi,r12
    1fef:	call   1ff4 <botlish_fn_21+0x1a0>
			1ff0: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ff4:	test   rax,rax
    1ff7:	jne    2005 <botlish_fn_21+0x1b1>
    1ffd:	mov    rdi,r12
    2000:	jmp    2027 <botlish_fn_21+0x1d3>
    2005:	mov    edx,0x9
    200a:	mov    ecx,0x1
    200f:	mov    rsi,QWORD PTR [rsp]
    2013:	mov    rdi,r12
    2016:	call   201b <botlish_fn_21+0x1c7>
			2017: R_X86_64_PLT32	rt_mutarray_set-0x4
    201b:	test   rax,rax
    201e:	jne    2052 <botlish_fn_21+0x1fe>
    2024:	mov    rdi,r12
    2027:	mov    rdi,r12
    202a:	mov    QWORD PTR [rdi],rbx
    202d:	xor    rax,rax
    2030:	mov    rbx,QWORD PTR [rsp+0x10]
    2035:	mov    r12,QWORD PTR [rsp+0x18]
    203a:	mov    r13,QWORD PTR [rsp+0x20]
    203f:	mov    r14,QWORD PTR [rsp+0x28]
    2044:	mov    r15,QWORD PTR [rsp+0x30]
    2049:	add    rsp,0x40
    204d:	mov    rsp,rbp
    2050:	pop    rbp
    2051:	ret
    2052:	mov    rdi,r12
    2055:	mov    QWORD PTR [rdi],rbx
    2058:	mov    rax,QWORD PTR [rsp]
    205c:	mov    rbx,QWORD PTR [rsp+0x10]
    2061:	mov    r12,QWORD PTR [rsp+0x18]
    2066:	mov    r13,QWORD PTR [rsp+0x20]
    206b:	mov    r14,QWORD PTR [rsp+0x28]
    2070:	mov    r15,QWORD PTR [rsp+0x30]
    2075:	add    rsp,0x40
    2079:	mov    rsp,rbp
    207c:	pop    rbp
    207d:	ret
    207e:	mov    r12,rdi
    2081:	call   2086 <botlish_fn_21+0x232>
			2082: R_X86_64_PLT32	rt_stack_overflow-0x4
    2086:	xor    rax,rax
    2089:	mov    rbx,QWORD PTR [rsp+0x10]
    208e:	mov    r12,QWORD PTR [rsp+0x18]
    2093:	mov    r13,QWORD PTR [rsp+0x20]
    2098:	mov    r14,QWORD PTR [rsp+0x28]
    209d:	mov    r15,QWORD PTR [rsp+0x30]
    20a2:	add    rsp,0x40
    20a6:	mov    rsp,rbp
    20a9:	pop    rbp
    20aa:	ret

00000000000020ab <botlish_entry_21: ht_alloc<int>>:
    20ab:	push   rbp
    20ac:	mov    rbp,rsp
    20af:	mov    rsi,QWORD PTR [rdx]
    20b2:	call   20b7 <botlish_entry_21+0xc>
			20b3: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    20b7:	mov    rsp,rbp
    20ba:	pop    rbp
    20bb:	ret

00000000000020bc <botlish_fn_22: ht_new<generic>>:
    20bc:	push   rbp
    20bd:	mov    rbp,rsp
    20c0:	sub    rsp,0x10
    20c4:	mov    QWORD PTR [rsp],r12
    20c8:	mov    QWORD PTR [rsp+0x8],r13
    20cd:	mov    r12,QWORD PTR [rdi]
    20d0:	mov    rax,QWORD PTR [rdi+0x8]
    20d4:	lea    rcx,[r12+0x8]
    20d9:	cmp    rcx,rax
    20dc:	ja     215c <botlish_fn_22+0xa0>
    20e2:	lea    rax,[r12+0x8]
    20e7:	mov    QWORD PTR [rdi],rax
    20ea:	mov    r13,rdi
    20ed:	mov    QWORD PTR [r12],0x0
    20f5:	mov    rdi,r13
    20f8:	call   20fd <botlish_fn_22+0x41>
			20f9: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    20fd:	test   rax,rax
    2100:	jne    210e <botlish_fn_22+0x52>
    2106:	mov    rdi,r13
    2109:	jmp    2129 <botlish_fn_22+0x6d>
    210e:	mov    QWORD PTR [r12],rax
    2112:	mov    rsi,rax
    2115:	mov    rdi,r13
    2118:	call   211d <botlish_fn_22+0x61>
			2119: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    211d:	test   rax,rax
    2120:	jne    2144 <botlish_fn_22+0x88>
    2126:	mov    rdi,r13
    2129:	mov    rdi,r13
    212c:	mov    QWORD PTR [rdi],r12
    212f:	xor    rax,rax
    2132:	mov    r12,QWORD PTR [rsp]
    2136:	mov    r13,QWORD PTR [rsp+0x8]
    213b:	add    rsp,0x10
    213f:	mov    rsp,rbp
    2142:	pop    rbp
    2143:	ret
    2144:	mov    rdi,r13
    2147:	mov    QWORD PTR [rdi],r12
    214a:	mov    r12,QWORD PTR [rsp]
    214e:	mov    r13,QWORD PTR [rsp+0x8]
    2153:	add    rsp,0x10
    2157:	mov    rsp,rbp
    215a:	pop    rbp
    215b:	ret
    215c:	mov    r13,rdi
    215f:	call   2164 <botlish_fn_22+0xa8>
			2160: R_X86_64_PLT32	rt_stack_overflow-0x4
    2164:	xor    rax,rax
    2167:	mov    r12,QWORD PTR [rsp]
    216b:	mov    r13,QWORD PTR [rsp+0x8]
    2170:	add    rsp,0x10
    2174:	mov    rsp,rbp
    2177:	pop    rbp
    2178:	ret

0000000000002179 <botlish_entry_22: ht_new<generic>>:
    2179:	push   rbp
    217a:	mov    rbp,rsp
    217d:	call   2182 <botlish_entry_22+0x9>
			217e: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    2182:	mov    rsp,rbp
    2185:	pop    rbp
    2186:	ret
	...

0000000000002188 <botlish_fn_23: ht_capacity_for<int, int>>:
    2188:	push   rbp
    2189:	mov    rbp,rsp
    218c:	sub    rsp,0x40
    2190:	mov    QWORD PTR [rsp+0x10],rbx
    2195:	mov    QWORD PTR [rsp+0x18],r12
    219a:	mov    QWORD PTR [rsp+0x20],r13
    219f:	mov    QWORD PTR [rsp+0x28],r14
    21a4:	mov    QWORD PTR [rsp+0x30],r15
    21a9:	mov    rbx,QWORD PTR [rdi]
    21ac:	mov    rax,QWORD PTR [rdi+0x8]
    21b0:	lea    rcx,[rbx+0x18]
    21b4:	cmp    rcx,rax
    21b7:	ja     234e <botlish_fn_23+0x1c6>
    21bd:	lea    rax,[rbx+0x18]
    21c1:	mov    QWORD PTR [rdi],rax
    21c4:	mov    r14,rdi
    21c7:	mov    QWORD PTR [rbx],rdx
    21ca:	mov    r12,rsi
    21cd:	or     r12,0x1
    21d1:	sar    r12,1
    21d4:	mov    r13,rsi
    21d7:	mov    r15,rdx
    21da:	mov    rax,r13
    21dd:	or     rax,0x1
    21e1:	mov    QWORD PTR [rbx+0x8],rax
    21e5:	mov    QWORD PTR [rbx+0x10],0x7
    21ed:	mov    rax,r12
    21f0:	imul   QWORD PTR [rip+0x189]        # 2380 <botlish_fn_23+0x1f8>
    21f7:	seto   cl
    21fa:	or     rax,0x1
    21fe:	test   cl,cl
    2200:	jne    220e <botlish_fn_23+0x86>
    2206:	mov    rsi,rax
    2209:	jmp    2225 <botlish_fn_23+0x9d>
    220e:	mov    rsi,r13
    2211:	or     rsi,0x1
    2215:	mov    edx,0x7
    221a:	mov    rdi,r14
    221d:	call   2222 <botlish_fn_23+0x9a>
			221e: R_X86_64_PLT32	rt_int_mul-0x4
    2222:	mov    rsi,rax
    2225:	mov    QWORD PTR [rbx+0x8],rsi
    2229:	mov    QWORD PTR [rsp],rsi
    222d:	mov    QWORD PTR [rbx+0x10],0x5
    2235:	mov    rsi,r15
    2238:	test   rsi,0x1
    223f:	je     2270 <botlish_fn_23+0xe8>
    2245:	mov    rsi,r15
    2248:	mov    rax,rsi
    224b:	sar    rax,1
    224e:	imul   QWORD PTR [rip+0x133]        # 2388 <botlish_fn_23+0x200>
    2255:	seto   cl
    2258:	or     rax,0x1
    225c:	test   cl,cl
    225e:	jne    2270 <botlish_fn_23+0xe8>
    2264:	mov    rdx,rax
    2267:	mov    rsi,QWORD PTR [rsp]
    226b:	jmp    2287 <botlish_fn_23+0xff>
    2270:	mov    edx,0x5
    2275:	mov    rsi,r15
    2278:	mov    rdi,r14
    227b:	call   2280 <botlish_fn_23+0xf8>
			227c: R_X86_64_PLT32	rt_int_mul-0x4
    2280:	mov    rdx,rax
    2283:	mov    rsi,QWORD PTR [rsp]
    2287:	mov    rdi,rsi
    228a:	and    rdi,rdx
    228d:	test   rdi,0x1
    2294:	jne    22b7 <botlish_fn_23+0x12f>
    229a:	mov    rdi,r14
    229d:	call   22a2 <botlish_fn_23+0x11a>
			229e: R_X86_64_PLT32	rt_int_cmp-0x4
    22a2:	mov    ecx,0x2
    22a7:	test   rax,rax
    22aa:	cmovle rcx,QWORD PTR [rip+0xce]        # 2380 <botlish_fn_23+0x1f8>
    22b2:	jmp    22c7 <botlish_fn_23+0x13f>
    22b7:	mov    ecx,0x2
    22bc:	cmp    rsi,rdx
    22bf:	cmovle rcx,QWORD PTR [rip+0xb9]        # 2380 <botlish_fn_23+0x1f8>
    22c7:	cmp    rcx,0x6
    22cb:	je     2323 <botlish_fn_23+0x19b>
    22d1:	mov    QWORD PTR [rbx+0x8],0x5
    22d9:	mov    rsi,r15
    22dc:	test   rsi,0x1
    22e3:	je     2308 <botlish_fn_23+0x180>
    22e9:	mov    rsi,r15
    22ec:	mov    rax,rsi
    22ef:	sar    rax,1
    22f2:	imul   QWORD PTR [rip+0x8f]        # 2388 <botlish_fn_23+0x200>
    22f9:	seto   cl
    22fc:	or     rax,0x1
    2300:	test   cl,cl
    2302:	je     2318 <botlish_fn_23+0x190>
    2308:	mov    edx,0x5
    230d:	mov    rsi,r15
    2310:	mov    rdi,r14
    2313:	call   2318 <botlish_fn_23+0x190>
			2314: R_X86_64_PLT32	rt_int_mul-0x4
    2318:	mov    QWORD PTR [rbx],rax
    231b:	mov    r15,rax
    231e:	jmp    21da <botlish_fn_23+0x52>
    2323:	mov    rdi,r14
    2326:	mov    QWORD PTR [rdi],rbx
    2329:	mov    rax,r15
    232c:	mov    rbx,QWORD PTR [rsp+0x10]
    2331:	mov    r12,QWORD PTR [rsp+0x18]
    2336:	mov    r13,QWORD PTR [rsp+0x20]
    233b:	mov    r14,QWORD PTR [rsp+0x28]
    2340:	mov    r15,QWORD PTR [rsp+0x30]
    2345:	add    rsp,0x40
    2349:	mov    rsp,rbp
    234c:	pop    rbp
    234d:	ret
    234e:	mov    r14,rdi
    2351:	call   2356 <botlish_fn_23+0x1ce>
			2352: R_X86_64_PLT32	rt_stack_overflow-0x4
    2356:	xor    rax,rax
    2359:	mov    rbx,QWORD PTR [rsp+0x10]
    235e:	mov    r12,QWORD PTR [rsp+0x18]
    2363:	mov    r13,QWORD PTR [rsp+0x20]
    2368:	mov    r14,QWORD PTR [rsp+0x28]
    236d:	mov    r15,QWORD PTR [rsp+0x30]
    2372:	add    rsp,0x40
    2376:	mov    rsp,rbp
    2379:	pop    rbp
    237a:	ret
    237b:	add    BYTE PTR [rax],al
    237d:	add    BYTE PTR [rax],al
    237f:	add    BYTE PTR [rsi],al
    2381:	add    BYTE PTR [rax],al
    2383:	add    BYTE PTR [rax],al
    2385:	add    BYTE PTR [rax],al
    2387:	add    BYTE PTR [rax+rax*1],al
    238a:	add    BYTE PTR [rax],al
    238c:	add    BYTE PTR [rax],al
	...

0000000000002390 <botlish_entry_23: ht_capacity_for<int, int>>:
    2390:	push   rbp
    2391:	mov    rbp,rsp
    2394:	mov    rsi,QWORD PTR [rdx]
    2397:	mov    rdx,QWORD PTR [rdx+0x8]
    239b:	call   23a0 <botlish_entry_23+0x10>
			239c: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    23a0:	mov    rsp,rbp
    23a3:	pop    rbp
    23a4:	ret

00000000000023a5 <botlish_fn_24: ht_new_sized<int>>:
    23a5:	push   rbp
    23a6:	mov    rbp,rsp
    23a9:	sub    rsp,0x20
    23ad:	mov    QWORD PTR [rsp],rbx
    23b1:	mov    QWORD PTR [rsp+0x8],r14
    23b6:	mov    QWORD PTR [rsp+0x10],r15
    23bb:	mov    r14,QWORD PTR [rdi]
    23be:	mov    rax,QWORD PTR [rdi+0x8]
    23c2:	lea    rcx,[r14+0x10]
    23c6:	cmp    rcx,rax
    23c9:	ja     247a <botlish_fn_24+0xd5>
    23cf:	lea    rax,[r14+0x10]
    23d3:	mov    QWORD PTR [rdi],rax
    23d6:	mov    r15,rdi
    23d9:	mov    QWORD PTR [r14+0x8],0x0
    23e1:	mov    QWORD PTR [r14],rsi
    23e4:	mov    rbx,rsi
    23e7:	mov    rdi,r15
    23ea:	call   23ef <botlish_fn_24+0x4a>
			23eb: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    23ef:	test   rax,rax
    23f2:	jne    2400 <botlish_fn_24+0x5b>
    23f8:	mov    rdi,r15
    23fb:	jmp    243d <botlish_fn_24+0x98>
    2400:	mov    QWORD PTR [r14+0x8],rax
    2404:	mov    rdx,rax
    2407:	mov    rsi,rbx
    240a:	mov    rdi,r15
    240d:	call   2412 <botlish_fn_24+0x6d>
			240e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    2412:	test   rax,rax
    2415:	jne    2423 <botlish_fn_24+0x7e>
    241b:	mov    rdi,r15
    241e:	jmp    243d <botlish_fn_24+0x98>
    2423:	mov    QWORD PTR [r14],rax
    2426:	mov    rsi,rax
    2429:	mov    rdi,r15
    242c:	call   2431 <botlish_fn_24+0x8c>
			242d: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2431:	test   rax,rax
    2434:	jne    245d <botlish_fn_24+0xb8>
    243a:	mov    rdi,r15
    243d:	mov    rdi,r15
    2440:	mov    QWORD PTR [rdi],r14
    2443:	xor    rax,rax
    2446:	mov    rbx,QWORD PTR [rsp]
    244a:	mov    r14,QWORD PTR [rsp+0x8]
    244f:	mov    r15,QWORD PTR [rsp+0x10]
    2454:	add    rsp,0x20
    2458:	mov    rsp,rbp
    245b:	pop    rbp
    245c:	ret
    245d:	mov    rdi,r15
    2460:	mov    QWORD PTR [rdi],r14
    2463:	mov    rbx,QWORD PTR [rsp]
    2467:	mov    r14,QWORD PTR [rsp+0x8]
    246c:	mov    r15,QWORD PTR [rsp+0x10]
    2471:	add    rsp,0x20
    2475:	mov    rsp,rbp
    2478:	pop    rbp
    2479:	ret
    247a:	mov    r15,rdi
    247d:	call   2482 <botlish_fn_24+0xdd>
			247e: R_X86_64_PLT32	rt_stack_overflow-0x4
    2482:	xor    rax,rax
    2485:	mov    rbx,QWORD PTR [rsp]
    2489:	mov    r14,QWORD PTR [rsp+0x8]
    248e:	mov    r15,QWORD PTR [rsp+0x10]
    2493:	add    rsp,0x20
    2497:	mov    rsp,rbp
    249a:	pop    rbp
    249b:	ret

000000000000249c <botlish_entry_24: ht_new_sized<int>>:
    249c:	push   rbp
    249d:	mov    rbp,rsp
    24a0:	mov    rsi,QWORD PTR [rdx]
    24a3:	call   24a8 <botlish_entry_24+0xc>
			24a4: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    24a8:	mov    rsp,rbp
    24ab:	pop    rbp
    24ac:	ret

00000000000024ad <botlish_fn_25: ht_controls<mutarray>>:
    24ad:	push   rbp
    24ae:	mov    rbp,rsp
    24b1:	sub    rsp,0x10
    24b5:	mov    QWORD PTR [rsp],r13
    24b9:	mov    QWORD PTR [rsp+0x8],r14
    24be:	mov    r13,QWORD PTR [rdi]
    24c1:	mov    rax,QWORD PTR [rdi+0x8]
    24c5:	lea    rcx,[r13+0x8]
    24c9:	cmp    rcx,rax
    24cc:	ja     2525 <botlish_fn_25+0x78>
    24d2:	lea    rax,[r13+0x8]
    24d6:	mov    QWORD PTR [rdi],rax
    24d9:	mov    r14,rdi
    24dc:	mov    edx,0x1
    24e1:	mov    rdi,r14
    24e4:	call   24e9 <botlish_fn_25+0x3c>
			24e5: R_X86_64_PLT32	rt_mutarray_get-0x4
    24e9:	test   rax,rax
    24ec:	jne    250d <botlish_fn_25+0x60>
    24f2:	mov    rdi,r14
    24f5:	mov    QWORD PTR [rdi],r13
    24f8:	xor    rax,rax
    24fb:	mov    r13,QWORD PTR [rsp]
    24ff:	mov    r14,QWORD PTR [rsp+0x8]
    2504:	add    rsp,0x10
    2508:	mov    rsp,rbp
    250b:	pop    rbp
    250c:	ret
    250d:	mov    rdi,r14
    2510:	mov    QWORD PTR [rdi],r13
    2513:	mov    r13,QWORD PTR [rsp]
    2517:	mov    r14,QWORD PTR [rsp+0x8]
    251c:	add    rsp,0x10
    2520:	mov    rsp,rbp
    2523:	pop    rbp
    2524:	ret
    2525:	call   252a <botlish_fn_25+0x7d>
			2526: R_X86_64_PLT32	rt_stack_overflow-0x4
    252a:	xor    rax,rax
    252d:	mov    r13,QWORD PTR [rsp]
    2531:	mov    r14,QWORD PTR [rsp+0x8]
    2536:	add    rsp,0x10
    253a:	mov    rsp,rbp
    253d:	pop    rbp
    253e:	ret

000000000000253f <botlish_entry_25: ht_controls<mutarray>>:
    253f:	push   rbp
    2540:	mov    rbp,rsp
    2543:	mov    rsi,QWORD PTR [rdx]
    2546:	call   254b <botlish_entry_25+0xc>
			2547: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    254b:	mov    rsp,rbp
    254e:	pop    rbp
    254f:	ret

0000000000002550 <botlish_fn_26: ht_controls<generic>>:
    2550:	push   rbp
    2551:	mov    rbp,rsp
    2554:	sub    rsp,0x10
    2558:	mov    QWORD PTR [rsp],rbx
    255c:	mov    QWORD PTR [rsp+0x8],r12
    2561:	mov    rbx,QWORD PTR [rdi]
    2564:	mov    rax,QWORD PTR [rdi+0x8]
    2568:	lea    rcx,[rbx+0x8]
    256c:	cmp    rcx,rax
    256f:	ja     2608 <botlish_fn_26+0xb8>
    2575:	lea    rax,[rbx+0x8]
    2579:	mov    QWORD PTR [rdi],rax
    257c:	xor    r11d,r11d
    257f:	test   rsi,0x7
    2586:	jne    2596 <botlish_fn_26+0x46>
    258c:	movzx  rax,BYTE PTR [rsi]
    2590:	cmp    al,0x8
    2592:	sete   r11b
    2596:	test   r11b,r11b
    2599:	jne    25bc <botlish_fn_26+0x6c>
    259f:	mov    rax,QWORD PTR [rdi+0x10]
    25a3:	mov    r12,rdi
    25a6:	mov    rcx,QWORD PTR [rax+0x20]
    25aa:	mov    edx,0x8
    25af:	call   25b4 <botlish_fn_26+0x64>
			25b0: R_X86_64_PLT32	rt_type_error-0x4
    25b4:	mov    rdi,r12
    25b7:	jmp    25d5 <botlish_fn_26+0x85>
    25bc:	mov    r12,rdi
    25bf:	mov    edx,0x1
    25c4:	call   25c9 <botlish_fn_26+0x79>
			25c5: R_X86_64_PLT32	rt_mutarray_get-0x4
    25c9:	test   rax,rax
    25cc:	jne    25f0 <botlish_fn_26+0xa0>
    25d2:	mov    rdi,r12
    25d5:	mov    rdi,r12
    25d8:	mov    QWORD PTR [rdi],rbx
    25db:	xor    rax,rax
    25de:	mov    rbx,QWORD PTR [rsp]
    25e2:	mov    r12,QWORD PTR [rsp+0x8]
    25e7:	add    rsp,0x10
    25eb:	mov    rsp,rbp
    25ee:	pop    rbp
    25ef:	ret
    25f0:	mov    rdi,r12
    25f3:	mov    QWORD PTR [rdi],rbx
    25f6:	mov    rbx,QWORD PTR [rsp]
    25fa:	mov    r12,QWORD PTR [rsp+0x8]
    25ff:	add    rsp,0x10
    2603:	mov    rsp,rbp
    2606:	pop    rbp
    2607:	ret
    2608:	mov    r12,rdi
    260b:	call   2610 <botlish_fn_26+0xc0>
			260c: R_X86_64_PLT32	rt_stack_overflow-0x4
    2610:	xor    rax,rax
    2613:	mov    rbx,QWORD PTR [rsp]
    2617:	mov    r12,QWORD PTR [rsp+0x8]
    261c:	add    rsp,0x10
    2620:	mov    rsp,rbp
    2623:	pop    rbp
    2624:	ret

0000000000002625 <botlish_entry_26: ht_controls<generic>>:
    2625:	push   rbp
    2626:	mov    rbp,rsp
    2629:	mov    rsi,QWORD PTR [rdx]
    262c:	call   2631 <botlish_entry_26+0xc>
			262d: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2631:	mov    rsp,rbp
    2634:	pop    rbp
    2635:	ret

0000000000002636 <botlish_fn_27: ht_keys<mutarray>>:
    2636:	push   rbp
    2637:	mov    rbp,rsp
    263a:	sub    rsp,0x10
    263e:	mov    QWORD PTR [rsp],r13
    2642:	mov    QWORD PTR [rsp+0x8],r14
    2647:	mov    r13,QWORD PTR [rdi]
    264a:	mov    rax,QWORD PTR [rdi+0x8]
    264e:	lea    rcx,[r13+0x8]
    2652:	cmp    rcx,rax
    2655:	ja     26ae <botlish_fn_27+0x78>
    265b:	lea    rax,[r13+0x8]
    265f:	mov    QWORD PTR [rdi],rax
    2662:	mov    r14,rdi
    2665:	mov    edx,0x3
    266a:	mov    rdi,r14
    266d:	call   2672 <botlish_fn_27+0x3c>
			266e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2672:	test   rax,rax
    2675:	jne    2696 <botlish_fn_27+0x60>
    267b:	mov    rdi,r14
    267e:	mov    QWORD PTR [rdi],r13
    2681:	xor    rax,rax
    2684:	mov    r13,QWORD PTR [rsp]
    2688:	mov    r14,QWORD PTR [rsp+0x8]
    268d:	add    rsp,0x10
    2691:	mov    rsp,rbp
    2694:	pop    rbp
    2695:	ret
    2696:	mov    rdi,r14
    2699:	mov    QWORD PTR [rdi],r13
    269c:	mov    r13,QWORD PTR [rsp]
    26a0:	mov    r14,QWORD PTR [rsp+0x8]
    26a5:	add    rsp,0x10
    26a9:	mov    rsp,rbp
    26ac:	pop    rbp
    26ad:	ret
    26ae:	call   26b3 <botlish_fn_27+0x7d>
			26af: R_X86_64_PLT32	rt_stack_overflow-0x4
    26b3:	xor    rax,rax
    26b6:	mov    r13,QWORD PTR [rsp]
    26ba:	mov    r14,QWORD PTR [rsp+0x8]
    26bf:	add    rsp,0x10
    26c3:	mov    rsp,rbp
    26c6:	pop    rbp
    26c7:	ret

00000000000026c8 <botlish_entry_27: ht_keys<mutarray>>:
    26c8:	push   rbp
    26c9:	mov    rbp,rsp
    26cc:	mov    rsi,QWORD PTR [rdx]
    26cf:	call   26d4 <botlish_entry_27+0xc>
			26d0: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    26d4:	mov    rsp,rbp
    26d7:	pop    rbp
    26d8:	ret

00000000000026d9 <botlish_fn_28: ht_keys<generic>>:
    26d9:	push   rbp
    26da:	mov    rbp,rsp
    26dd:	sub    rsp,0x10
    26e1:	mov    QWORD PTR [rsp],rbx
    26e5:	mov    QWORD PTR [rsp+0x8],r12
    26ea:	mov    rbx,QWORD PTR [rdi]
    26ed:	mov    rax,QWORD PTR [rdi+0x8]
    26f1:	lea    rcx,[rbx+0x8]
    26f5:	cmp    rcx,rax
    26f8:	ja     2791 <botlish_fn_28+0xb8>
    26fe:	lea    rax,[rbx+0x8]
    2702:	mov    QWORD PTR [rdi],rax
    2705:	xor    r11d,r11d
    2708:	test   rsi,0x7
    270f:	jne    271f <botlish_fn_28+0x46>
    2715:	movzx  rax,BYTE PTR [rsi]
    2719:	cmp    al,0x8
    271b:	sete   r11b
    271f:	test   r11b,r11b
    2722:	jne    2745 <botlish_fn_28+0x6c>
    2728:	mov    rax,QWORD PTR [rdi+0x10]
    272c:	mov    r12,rdi
    272f:	mov    rcx,QWORD PTR [rax+0x20]
    2733:	mov    edx,0x8
    2738:	call   273d <botlish_fn_28+0x64>
			2739: R_X86_64_PLT32	rt_type_error-0x4
    273d:	mov    rdi,r12
    2740:	jmp    275e <botlish_fn_28+0x85>
    2745:	mov    r12,rdi
    2748:	mov    edx,0x3
    274d:	call   2752 <botlish_fn_28+0x79>
			274e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2752:	test   rax,rax
    2755:	jne    2779 <botlish_fn_28+0xa0>
    275b:	mov    rdi,r12
    275e:	mov    rdi,r12
    2761:	mov    QWORD PTR [rdi],rbx
    2764:	xor    rax,rax
    2767:	mov    rbx,QWORD PTR [rsp]
    276b:	mov    r12,QWORD PTR [rsp+0x8]
    2770:	add    rsp,0x10
    2774:	mov    rsp,rbp
    2777:	pop    rbp
    2778:	ret
    2779:	mov    rdi,r12
    277c:	mov    QWORD PTR [rdi],rbx
    277f:	mov    rbx,QWORD PTR [rsp]
    2783:	mov    r12,QWORD PTR [rsp+0x8]
    2788:	add    rsp,0x10
    278c:	mov    rsp,rbp
    278f:	pop    rbp
    2790:	ret
    2791:	mov    r12,rdi
    2794:	call   2799 <botlish_fn_28+0xc0>
			2795: R_X86_64_PLT32	rt_stack_overflow-0x4
    2799:	xor    rax,rax
    279c:	mov    rbx,QWORD PTR [rsp]
    27a0:	mov    r12,QWORD PTR [rsp+0x8]
    27a5:	add    rsp,0x10
    27a9:	mov    rsp,rbp
    27ac:	pop    rbp
    27ad:	ret

00000000000027ae <botlish_entry_28: ht_keys<generic>>:
    27ae:	push   rbp
    27af:	mov    rbp,rsp
    27b2:	mov    rsi,QWORD PTR [rdx]
    27b5:	call   27ba <botlish_entry_28+0xc>
			27b6: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    27ba:	mov    rsp,rbp
    27bd:	pop    rbp
    27be:	ret

00000000000027bf <botlish_fn_29: ht_values<mutarray>>:
    27bf:	push   rbp
    27c0:	mov    rbp,rsp
    27c3:	sub    rsp,0x10
    27c7:	mov    QWORD PTR [rsp],r13
    27cb:	mov    QWORD PTR [rsp+0x8],r14
    27d0:	mov    r13,QWORD PTR [rdi]
    27d3:	mov    rax,QWORD PTR [rdi+0x8]
    27d7:	lea    rcx,[r13+0x8]
    27db:	cmp    rcx,rax
    27de:	ja     2837 <botlish_fn_29+0x78>
    27e4:	lea    rax,[r13+0x8]
    27e8:	mov    QWORD PTR [rdi],rax
    27eb:	mov    r14,rdi
    27ee:	mov    edx,0x5
    27f3:	mov    rdi,r14
    27f6:	call   27fb <botlish_fn_29+0x3c>
			27f7: R_X86_64_PLT32	rt_mutarray_get-0x4
    27fb:	test   rax,rax
    27fe:	jne    281f <botlish_fn_29+0x60>
    2804:	mov    rdi,r14
    2807:	mov    QWORD PTR [rdi],r13
    280a:	xor    rax,rax
    280d:	mov    r13,QWORD PTR [rsp]
    2811:	mov    r14,QWORD PTR [rsp+0x8]
    2816:	add    rsp,0x10
    281a:	mov    rsp,rbp
    281d:	pop    rbp
    281e:	ret
    281f:	mov    rdi,r14
    2822:	mov    QWORD PTR [rdi],r13
    2825:	mov    r13,QWORD PTR [rsp]
    2829:	mov    r14,QWORD PTR [rsp+0x8]
    282e:	add    rsp,0x10
    2832:	mov    rsp,rbp
    2835:	pop    rbp
    2836:	ret
    2837:	call   283c <botlish_fn_29+0x7d>
			2838: R_X86_64_PLT32	rt_stack_overflow-0x4
    283c:	xor    rax,rax
    283f:	mov    r13,QWORD PTR [rsp]
    2843:	mov    r14,QWORD PTR [rsp+0x8]
    2848:	add    rsp,0x10
    284c:	mov    rsp,rbp
    284f:	pop    rbp
    2850:	ret

0000000000002851 <botlish_entry_29: ht_values<mutarray>>:
    2851:	push   rbp
    2852:	mov    rbp,rsp
    2855:	mov    rsi,QWORD PTR [rdx]
    2858:	call   285d <botlish_entry_29+0xc>
			2859: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    285d:	mov    rsp,rbp
    2860:	pop    rbp
    2861:	ret

0000000000002862 <botlish_fn_30: ht_values<generic>>:
    2862:	push   rbp
    2863:	mov    rbp,rsp
    2866:	sub    rsp,0x10
    286a:	mov    QWORD PTR [rsp],rbx
    286e:	mov    QWORD PTR [rsp+0x8],r12
    2873:	mov    rbx,QWORD PTR [rdi]
    2876:	mov    rax,QWORD PTR [rdi+0x8]
    287a:	lea    rcx,[rbx+0x8]
    287e:	cmp    rcx,rax
    2881:	ja     291a <botlish_fn_30+0xb8>
    2887:	lea    rax,[rbx+0x8]
    288b:	mov    QWORD PTR [rdi],rax
    288e:	xor    r11d,r11d
    2891:	test   rsi,0x7
    2898:	jne    28a8 <botlish_fn_30+0x46>
    289e:	movzx  rax,BYTE PTR [rsi]
    28a2:	cmp    al,0x8
    28a4:	sete   r11b
    28a8:	test   r11b,r11b
    28ab:	jne    28ce <botlish_fn_30+0x6c>
    28b1:	mov    rax,QWORD PTR [rdi+0x10]
    28b5:	mov    r12,rdi
    28b8:	mov    rcx,QWORD PTR [rax+0x20]
    28bc:	mov    edx,0x8
    28c1:	call   28c6 <botlish_fn_30+0x64>
			28c2: R_X86_64_PLT32	rt_type_error-0x4
    28c6:	mov    rdi,r12
    28c9:	jmp    28e7 <botlish_fn_30+0x85>
    28ce:	mov    r12,rdi
    28d1:	mov    edx,0x5
    28d6:	call   28db <botlish_fn_30+0x79>
			28d7: R_X86_64_PLT32	rt_mutarray_get-0x4
    28db:	test   rax,rax
    28de:	jne    2902 <botlish_fn_30+0xa0>
    28e4:	mov    rdi,r12
    28e7:	mov    rdi,r12
    28ea:	mov    QWORD PTR [rdi],rbx
    28ed:	xor    rax,rax
    28f0:	mov    rbx,QWORD PTR [rsp]
    28f4:	mov    r12,QWORD PTR [rsp+0x8]
    28f9:	add    rsp,0x10
    28fd:	mov    rsp,rbp
    2900:	pop    rbp
    2901:	ret
    2902:	mov    rdi,r12
    2905:	mov    QWORD PTR [rdi],rbx
    2908:	mov    rbx,QWORD PTR [rsp]
    290c:	mov    r12,QWORD PTR [rsp+0x8]
    2911:	add    rsp,0x10
    2915:	mov    rsp,rbp
    2918:	pop    rbp
    2919:	ret
    291a:	mov    r12,rdi
    291d:	call   2922 <botlish_fn_30+0xc0>
			291e: R_X86_64_PLT32	rt_stack_overflow-0x4
    2922:	xor    rax,rax
    2925:	mov    rbx,QWORD PTR [rsp]
    2929:	mov    r12,QWORD PTR [rsp+0x8]
    292e:	add    rsp,0x10
    2932:	mov    rsp,rbp
    2935:	pop    rbp
    2936:	ret

0000000000002937 <botlish_entry_30: ht_values<generic>>:
    2937:	push   rbp
    2938:	mov    rbp,rsp
    293b:	mov    rsi,QWORD PTR [rdx]
    293e:	call   2943 <botlish_entry_30+0xc>
			293f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    2943:	mov    rsp,rbp
    2946:	pop    rbp
    2947:	ret

0000000000002948 <botlish_fn_31: ht_size<mutarray>>:
    2948:	push   rbp
    2949:	mov    rbp,rsp
    294c:	sub    rsp,0x10
    2950:	mov    QWORD PTR [rsp],r13
    2954:	mov    QWORD PTR [rsp+0x8],r14
    2959:	mov    r13,QWORD PTR [rdi]
    295c:	mov    rax,QWORD PTR [rdi+0x8]
    2960:	lea    rcx,[r13+0x8]
    2964:	cmp    rcx,rax
    2967:	ja     29c0 <botlish_fn_31+0x78>
    296d:	lea    rax,[r13+0x8]
    2971:	mov    QWORD PTR [rdi],rax
    2974:	mov    r14,rdi
    2977:	mov    edx,0x7
    297c:	mov    rdi,r14
    297f:	call   2984 <botlish_fn_31+0x3c>
			2980: R_X86_64_PLT32	rt_mutarray_get-0x4
    2984:	test   rax,rax
    2987:	jne    29a8 <botlish_fn_31+0x60>
    298d:	mov    rdi,r14
    2990:	mov    QWORD PTR [rdi],r13
    2993:	xor    rax,rax
    2996:	mov    r13,QWORD PTR [rsp]
    299a:	mov    r14,QWORD PTR [rsp+0x8]
    299f:	add    rsp,0x10
    29a3:	mov    rsp,rbp
    29a6:	pop    rbp
    29a7:	ret
    29a8:	mov    rdi,r14
    29ab:	mov    QWORD PTR [rdi],r13
    29ae:	mov    r13,QWORD PTR [rsp]
    29b2:	mov    r14,QWORD PTR [rsp+0x8]
    29b7:	add    rsp,0x10
    29bb:	mov    rsp,rbp
    29be:	pop    rbp
    29bf:	ret
    29c0:	call   29c5 <botlish_fn_31+0x7d>
			29c1: R_X86_64_PLT32	rt_stack_overflow-0x4
    29c5:	xor    rax,rax
    29c8:	mov    r13,QWORD PTR [rsp]
    29cc:	mov    r14,QWORD PTR [rsp+0x8]
    29d1:	add    rsp,0x10
    29d5:	mov    rsp,rbp
    29d8:	pop    rbp
    29d9:	ret

00000000000029da <botlish_entry_31: ht_size<mutarray>>:
    29da:	push   rbp
    29db:	mov    rbp,rsp
    29de:	mov    rsi,QWORD PTR [rdx]
    29e1:	call   29e6 <botlish_entry_31+0xc>
			29e2: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    29e6:	mov    rsp,rbp
    29e9:	pop    rbp
    29ea:	ret

00000000000029eb <botlish_fn_32: ht_size<generic>>:
    29eb:	push   rbp
    29ec:	mov    rbp,rsp
    29ef:	sub    rsp,0x10
    29f3:	mov    QWORD PTR [rsp],rbx
    29f7:	mov    QWORD PTR [rsp+0x8],r12
    29fc:	mov    rbx,QWORD PTR [rdi]
    29ff:	mov    rax,QWORD PTR [rdi+0x8]
    2a03:	lea    rcx,[rbx+0x8]
    2a07:	cmp    rcx,rax
    2a0a:	ja     2aa3 <botlish_fn_32+0xb8>
    2a10:	lea    rax,[rbx+0x8]
    2a14:	mov    QWORD PTR [rdi],rax
    2a17:	xor    r11d,r11d
    2a1a:	test   rsi,0x7
    2a21:	jne    2a31 <botlish_fn_32+0x46>
    2a27:	movzx  rax,BYTE PTR [rsi]
    2a2b:	cmp    al,0x8
    2a2d:	sete   r11b
    2a31:	test   r11b,r11b
    2a34:	jne    2a57 <botlish_fn_32+0x6c>
    2a3a:	mov    rax,QWORD PTR [rdi+0x10]
    2a3e:	mov    r12,rdi
    2a41:	mov    rcx,QWORD PTR [rax+0x20]
    2a45:	mov    edx,0x8
    2a4a:	call   2a4f <botlish_fn_32+0x64>
			2a4b: R_X86_64_PLT32	rt_type_error-0x4
    2a4f:	mov    rdi,r12
    2a52:	jmp    2a70 <botlish_fn_32+0x85>
    2a57:	mov    r12,rdi
    2a5a:	mov    edx,0x7
    2a5f:	call   2a64 <botlish_fn_32+0x79>
			2a60: R_X86_64_PLT32	rt_mutarray_get-0x4
    2a64:	test   rax,rax
    2a67:	jne    2a8b <botlish_fn_32+0xa0>
    2a6d:	mov    rdi,r12
    2a70:	mov    rdi,r12
    2a73:	mov    QWORD PTR [rdi],rbx
    2a76:	xor    rax,rax
    2a79:	mov    rbx,QWORD PTR [rsp]
    2a7d:	mov    r12,QWORD PTR [rsp+0x8]
    2a82:	add    rsp,0x10
    2a86:	mov    rsp,rbp
    2a89:	pop    rbp
    2a8a:	ret
    2a8b:	mov    rdi,r12
    2a8e:	mov    QWORD PTR [rdi],rbx
    2a91:	mov    rbx,QWORD PTR [rsp]
    2a95:	mov    r12,QWORD PTR [rsp+0x8]
    2a9a:	add    rsp,0x10
    2a9e:	mov    rsp,rbp
    2aa1:	pop    rbp
    2aa2:	ret
    2aa3:	mov    r12,rdi
    2aa6:	call   2aab <botlish_fn_32+0xc0>
			2aa7: R_X86_64_PLT32	rt_stack_overflow-0x4
    2aab:	xor    rax,rax
    2aae:	mov    rbx,QWORD PTR [rsp]
    2ab2:	mov    r12,QWORD PTR [rsp+0x8]
    2ab7:	add    rsp,0x10
    2abb:	mov    rsp,rbp
    2abe:	pop    rbp
    2abf:	ret

0000000000002ac0 <botlish_entry_32: ht_size<generic>>:
    2ac0:	push   rbp
    2ac1:	mov    rbp,rsp
    2ac4:	mov    rsi,QWORD PTR [rdx]
    2ac7:	call   2acc <botlish_entry_32+0xc>
			2ac8: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    2acc:	mov    rsp,rbp
    2acf:	pop    rbp
    2ad0:	ret

0000000000002ad1 <botlish_fn_33: ht_tombstones<mutarray>>:
    2ad1:	push   rbp
    2ad2:	mov    rbp,rsp
    2ad5:	sub    rsp,0x10
    2ad9:	mov    QWORD PTR [rsp],r13
    2add:	mov    QWORD PTR [rsp+0x8],r14
    2ae2:	mov    r13,QWORD PTR [rdi]
    2ae5:	mov    rax,QWORD PTR [rdi+0x8]
    2ae9:	lea    rcx,[r13+0x8]
    2aed:	cmp    rcx,rax
    2af0:	ja     2b49 <botlish_fn_33+0x78>
    2af6:	lea    rax,[r13+0x8]
    2afa:	mov    QWORD PTR [rdi],rax
    2afd:	mov    r14,rdi
    2b00:	mov    edx,0x9
    2b05:	mov    rdi,r14
    2b08:	call   2b0d <botlish_fn_33+0x3c>
			2b09: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b0d:	test   rax,rax
    2b10:	jne    2b31 <botlish_fn_33+0x60>
    2b16:	mov    rdi,r14
    2b19:	mov    QWORD PTR [rdi],r13
    2b1c:	xor    rax,rax
    2b1f:	mov    r13,QWORD PTR [rsp]
    2b23:	mov    r14,QWORD PTR [rsp+0x8]
    2b28:	add    rsp,0x10
    2b2c:	mov    rsp,rbp
    2b2f:	pop    rbp
    2b30:	ret
    2b31:	mov    rdi,r14
    2b34:	mov    QWORD PTR [rdi],r13
    2b37:	mov    r13,QWORD PTR [rsp]
    2b3b:	mov    r14,QWORD PTR [rsp+0x8]
    2b40:	add    rsp,0x10
    2b44:	mov    rsp,rbp
    2b47:	pop    rbp
    2b48:	ret
    2b49:	call   2b4e <botlish_fn_33+0x7d>
			2b4a: R_X86_64_PLT32	rt_stack_overflow-0x4
    2b4e:	xor    rax,rax
    2b51:	mov    r13,QWORD PTR [rsp]
    2b55:	mov    r14,QWORD PTR [rsp+0x8]
    2b5a:	add    rsp,0x10
    2b5e:	mov    rsp,rbp
    2b61:	pop    rbp
    2b62:	ret

0000000000002b63 <botlish_entry_33: ht_tombstones<mutarray>>:
    2b63:	push   rbp
    2b64:	mov    rbp,rsp
    2b67:	mov    rsi,QWORD PTR [rdx]
    2b6a:	call   2b6f <botlish_entry_33+0xc>
			2b6b: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    2b6f:	mov    rsp,rbp
    2b72:	pop    rbp
    2b73:	ret

0000000000002b74 <botlish_fn_34: ht_capacity<mutarray>>:
    2b74:	push   rbp
    2b75:	mov    rbp,rsp
    2b78:	sub    rsp,0x10
    2b7c:	mov    QWORD PTR [rsp],rbx
    2b80:	mov    QWORD PTR [rsp+0x8],r12
    2b85:	mov    rbx,QWORD PTR [rdi]
    2b88:	mov    rax,QWORD PTR [rdi+0x8]
    2b8c:	lea    rcx,[rbx+0x8]
    2b90:	cmp    rcx,rax
    2b93:	ja     2c3e <botlish_fn_34+0xca>
    2b99:	lea    rax,[rbx+0x8]
    2b9d:	mov    QWORD PTR [rdi],rax
    2ba0:	mov    r12,rdi
    2ba3:	mov    QWORD PTR [rbx],rsi
    2ba6:	mov    rdi,r12
    2ba9:	call   2bae <botlish_fn_34+0x3a>
			2baa: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    2bae:	test   rax,rax
    2bb1:	jne    2bbf <botlish_fn_34+0x4b>
    2bb7:	mov    rdi,r12
    2bba:	jmp    2c03 <botlish_fn_34+0x8f>
    2bbf:	xor    ecx,ecx
    2bc1:	test   rax,0x7
    2bc7:	je     2bd5 <botlish_fn_34+0x61>
    2bcd:	mov    rsi,rax
    2bd0:	jmp    2be3 <botlish_fn_34+0x6f>
    2bd5:	movzx  rcx,BYTE PTR [rax]
    2bd9:	mov    rsi,rax
    2bdc:	rex cmp cl,0x8
    2be0:	sete   cl
    2be3:	test   cl,cl
    2be5:	jne    2c1e <botlish_fn_34+0xaa>
    2beb:	mov    rdi,r12
    2bee:	mov    rax,QWORD PTR [rdi+0x10]
    2bf2:	mov    rcx,QWORD PTR [rax+0x28]
    2bf6:	mov    edx,0x8
    2bfb:	call   2c00 <botlish_fn_34+0x8c>
			2bfc: R_X86_64_PLT32	rt_type_error-0x4
    2c00:	mov    rdi,r12
    2c03:	mov    rdi,r12
    2c06:	mov    QWORD PTR [rdi],rbx
    2c09:	xor    rax,rax
    2c0c:	mov    rbx,QWORD PTR [rsp]
    2c10:	mov    r12,QWORD PTR [rsp+0x8]
    2c15:	add    rsp,0x10
    2c19:	mov    rsp,rbp
    2c1c:	pop    rbp
    2c1d:	ret
    2c1e:	mov    rdi,r12
    2c21:	call   2c26 <botlish_fn_34+0xb2>
			2c22: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2c26:	mov    rdi,r12
    2c29:	mov    QWORD PTR [rdi],rbx
    2c2c:	mov    rbx,QWORD PTR [rsp]
    2c30:	mov    r12,QWORD PTR [rsp+0x8]
    2c35:	add    rsp,0x10
    2c39:	mov    rsp,rbp
    2c3c:	pop    rbp
    2c3d:	ret
    2c3e:	mov    r12,rdi
    2c41:	call   2c46 <botlish_fn_34+0xd2>
			2c42: R_X86_64_PLT32	rt_stack_overflow-0x4
    2c46:	xor    rax,rax
    2c49:	mov    rbx,QWORD PTR [rsp]
    2c4d:	mov    r12,QWORD PTR [rsp+0x8]
    2c52:	add    rsp,0x10
    2c56:	mov    rsp,rbp
    2c59:	pop    rbp
    2c5a:	ret

0000000000002c5b <botlish_entry_34: ht_capacity<mutarray>>:
    2c5b:	push   rbp
    2c5c:	mov    rbp,rsp
    2c5f:	mov    rsi,QWORD PTR [rdx]
    2c62:	call   2c67 <botlish_entry_34+0xc>
			2c63: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2c67:	mov    rsp,rbp
    2c6a:	pop    rbp
    2c6b:	ret

0000000000002c6c <botlish_fn_35: ht_capacity<generic>>:
    2c6c:	push   rbp
    2c6d:	mov    rbp,rsp
    2c70:	sub    rsp,0x10
    2c74:	mov    QWORD PTR [rsp],rbx
    2c78:	mov    QWORD PTR [rsp+0x8],r12
    2c7d:	mov    rbx,QWORD PTR [rdi]
    2c80:	mov    rax,QWORD PTR [rdi+0x8]
    2c84:	lea    rcx,[rbx+0x8]
    2c88:	cmp    rcx,rax
    2c8b:	ja     2d36 <botlish_fn_35+0xca>
    2c91:	lea    rax,[rbx+0x8]
    2c95:	mov    QWORD PTR [rdi],rax
    2c98:	mov    r12,rdi
    2c9b:	mov    QWORD PTR [rbx],rsi
    2c9e:	mov    rdi,r12
    2ca1:	call   2ca6 <botlish_fn_35+0x3a>
			2ca2: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2ca6:	test   rax,rax
    2ca9:	jne    2cb7 <botlish_fn_35+0x4b>
    2caf:	mov    rdi,r12
    2cb2:	jmp    2cfb <botlish_fn_35+0x8f>
    2cb7:	xor    ecx,ecx
    2cb9:	test   rax,0x7
    2cbf:	je     2ccd <botlish_fn_35+0x61>
    2cc5:	mov    rsi,rax
    2cc8:	jmp    2cdb <botlish_fn_35+0x6f>
    2ccd:	movzx  rcx,BYTE PTR [rax]
    2cd1:	mov    rsi,rax
    2cd4:	rex cmp cl,0x8
    2cd8:	sete   cl
    2cdb:	test   cl,cl
    2cdd:	jne    2d16 <botlish_fn_35+0xaa>
    2ce3:	mov    rdi,r12
    2ce6:	mov    rax,QWORD PTR [rdi+0x10]
    2cea:	mov    rcx,QWORD PTR [rax+0x28]
    2cee:	mov    edx,0x8
    2cf3:	call   2cf8 <botlish_fn_35+0x8c>
			2cf4: R_X86_64_PLT32	rt_type_error-0x4
    2cf8:	mov    rdi,r12
    2cfb:	mov    rdi,r12
    2cfe:	mov    QWORD PTR [rdi],rbx
    2d01:	xor    rax,rax
    2d04:	mov    rbx,QWORD PTR [rsp]
    2d08:	mov    r12,QWORD PTR [rsp+0x8]
    2d0d:	add    rsp,0x10
    2d11:	mov    rsp,rbp
    2d14:	pop    rbp
    2d15:	ret
    2d16:	mov    rdi,r12
    2d19:	call   2d1e <botlish_fn_35+0xb2>
			2d1a: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2d1e:	mov    rdi,r12
    2d21:	mov    QWORD PTR [rdi],rbx
    2d24:	mov    rbx,QWORD PTR [rsp]
    2d28:	mov    r12,QWORD PTR [rsp+0x8]
    2d2d:	add    rsp,0x10
    2d31:	mov    rsp,rbp
    2d34:	pop    rbp
    2d35:	ret
    2d36:	mov    r12,rdi
    2d39:	call   2d3e <botlish_fn_35+0xd2>
			2d3a: R_X86_64_PLT32	rt_stack_overflow-0x4
    2d3e:	xor    rax,rax
    2d41:	mov    rbx,QWORD PTR [rsp]
    2d45:	mov    r12,QWORD PTR [rsp+0x8]
    2d4a:	add    rsp,0x10
    2d4e:	mov    rsp,rbp
    2d51:	pop    rbp
    2d52:	ret

0000000000002d53 <botlish_entry_35: ht_capacity<generic>>:
    2d53:	push   rbp
    2d54:	mov    rbp,rsp
    2d57:	mov    rsi,QWORD PTR [rdx]
    2d5a:	call   2d5f <botlish_entry_35+0xc>
			2d5b: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2d5f:	mov    rsp,rbp
    2d62:	pop    rbp
    2d63:	ret

0000000000002d64 <botlish_fn_36: ht_probe_start<mutarray, any>>:
    2d64:	push   rbp
    2d65:	mov    rbp,rsp
    2d68:	sub    rsp,0x20
    2d6c:	mov    QWORD PTR [rsp],rbx
    2d70:	mov    QWORD PTR [rsp+0x8],r12
    2d75:	mov    QWORD PTR [rsp+0x10],r15
    2d7a:	mov    r15,QWORD PTR [rdi]
    2d7d:	mov    rax,QWORD PTR [rdi+0x8]
    2d81:	lea    rcx,[r15+0x10]
    2d85:	cmp    rcx,rax
    2d88:	ja     2e34 <botlish_fn_36+0xd0>
    2d8e:	lea    rax,[r15+0x10]
    2d92:	mov    QWORD PTR [rdi],rax
    2d95:	mov    rbx,rdi
    2d98:	mov    QWORD PTR [r15],rsi
    2d9b:	mov    r12,rsi
    2d9e:	mov    rsi,rdx
    2da1:	mov    rdi,rbx
    2da4:	call   2da9 <botlish_fn_36+0x45>
			2da5: R_X86_64_PLT32	rt_hash-0x4
    2da9:	test   rax,rax
    2dac:	jne    2dba <botlish_fn_36+0x56>
    2db2:	mov    rdi,rbx
    2db5:	jmp    2df7 <botlish_fn_36+0x93>
    2dba:	mov    QWORD PTR [r15+0x8],rax
    2dbe:	mov    rsi,r12
    2dc1:	mov    r12,rax
    2dc4:	mov    rdi,rbx
    2dc7:	call   2dcc <botlish_fn_36+0x68>
			2dc8: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2dcc:	test   rax,rax
    2dcf:	mov    rdx,rax
    2dd2:	jne    2de0 <botlish_fn_36+0x7c>
    2dd8:	mov    rdi,rbx
    2ddb:	jmp    2df7 <botlish_fn_36+0x93>
    2de0:	mov    rsi,r12
    2de3:	mov    rdi,rbx
    2de6:	call   2deb <botlish_fn_36+0x87>
			2de7: R_X86_64_PLT32	rt_int_mod-0x4
    2deb:	test   rax,rax
    2dee:	jne    2e17 <botlish_fn_36+0xb3>
    2df4:	mov    rdi,rbx
    2df7:	mov    rdi,rbx
    2dfa:	mov    QWORD PTR [rdi],r15
    2dfd:	xor    rax,rax
    2e00:	mov    rbx,QWORD PTR [rsp]
    2e04:	mov    r12,QWORD PTR [rsp+0x8]
    2e09:	mov    r15,QWORD PTR [rsp+0x10]
    2e0e:	add    rsp,0x20
    2e12:	mov    rsp,rbp
    2e15:	pop    rbp
    2e16:	ret
    2e17:	mov    rdi,rbx
    2e1a:	mov    QWORD PTR [rdi],r15
    2e1d:	mov    rbx,QWORD PTR [rsp]
    2e21:	mov    r12,QWORD PTR [rsp+0x8]
    2e26:	mov    r15,QWORD PTR [rsp+0x10]
    2e2b:	add    rsp,0x20
    2e2f:	mov    rsp,rbp
    2e32:	pop    rbp
    2e33:	ret
    2e34:	mov    rbx,rdi
    2e37:	call   2e3c <botlish_fn_36+0xd8>
			2e38: R_X86_64_PLT32	rt_stack_overflow-0x4
    2e3c:	xor    rax,rax
    2e3f:	mov    rbx,QWORD PTR [rsp]
    2e43:	mov    r12,QWORD PTR [rsp+0x8]
    2e48:	mov    r15,QWORD PTR [rsp+0x10]
    2e4d:	add    rsp,0x20
    2e51:	mov    rsp,rbp
    2e54:	pop    rbp
    2e55:	ret

0000000000002e56 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    2e56:	push   rbp
    2e57:	mov    rbp,rsp
    2e5a:	mov    rsi,QWORD PTR [rdx]
    2e5d:	mov    rdx,QWORD PTR [rdx+0x8]
    2e61:	call   2e66 <botlish_entry_36+0x10>
			2e62: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    2e66:	mov    rsp,rbp
    2e69:	pop    rbp
    2e6a:	ret

0000000000002e6b <botlish_fn_37: ht_probe_start<any, str>>:
    2e6b:	push   rbp
    2e6c:	mov    rbp,rsp
    2e6f:	sub    rsp,0x20
    2e73:	mov    QWORD PTR [rsp],rbx
    2e77:	mov    QWORD PTR [rsp+0x8],r12
    2e7c:	mov    QWORD PTR [rsp+0x10],r15
    2e81:	mov    r15,QWORD PTR [rdi]
    2e84:	mov    rax,QWORD PTR [rdi+0x8]
    2e88:	lea    rcx,[r15+0x10]
    2e8c:	cmp    rcx,rax
    2e8f:	ja     2f3b <botlish_fn_37+0xd0>
    2e95:	lea    rax,[r15+0x10]
    2e99:	mov    QWORD PTR [rdi],rax
    2e9c:	mov    rbx,rdi
    2e9f:	mov    QWORD PTR [r15],rsi
    2ea2:	mov    r12,rsi
    2ea5:	mov    rsi,rdx
    2ea8:	mov    rdi,rbx
    2eab:	call   2eb0 <botlish_fn_37+0x45>
			2eac: R_X86_64_PLT32	rt_hash-0x4
    2eb0:	test   rax,rax
    2eb3:	jne    2ec1 <botlish_fn_37+0x56>
    2eb9:	mov    rdi,rbx
    2ebc:	jmp    2efe <botlish_fn_37+0x93>
    2ec1:	mov    QWORD PTR [r15+0x8],rax
    2ec5:	mov    rsi,r12
    2ec8:	mov    r12,rax
    2ecb:	mov    rdi,rbx
    2ece:	call   2ed3 <botlish_fn_37+0x68>
			2ecf: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2ed3:	test   rax,rax
    2ed6:	mov    rdx,rax
    2ed9:	jne    2ee7 <botlish_fn_37+0x7c>
    2edf:	mov    rdi,rbx
    2ee2:	jmp    2efe <botlish_fn_37+0x93>
    2ee7:	mov    rsi,r12
    2eea:	mov    rdi,rbx
    2eed:	call   2ef2 <botlish_fn_37+0x87>
			2eee: R_X86_64_PLT32	rt_int_mod-0x4
    2ef2:	test   rax,rax
    2ef5:	jne    2f1e <botlish_fn_37+0xb3>
    2efb:	mov    rdi,rbx
    2efe:	mov    rdi,rbx
    2f01:	mov    QWORD PTR [rdi],r15
    2f04:	xor    rax,rax
    2f07:	mov    rbx,QWORD PTR [rsp]
    2f0b:	mov    r12,QWORD PTR [rsp+0x8]
    2f10:	mov    r15,QWORD PTR [rsp+0x10]
    2f15:	add    rsp,0x20
    2f19:	mov    rsp,rbp
    2f1c:	pop    rbp
    2f1d:	ret
    2f1e:	mov    rdi,rbx
    2f21:	mov    QWORD PTR [rdi],r15
    2f24:	mov    rbx,QWORD PTR [rsp]
    2f28:	mov    r12,QWORD PTR [rsp+0x8]
    2f2d:	mov    r15,QWORD PTR [rsp+0x10]
    2f32:	add    rsp,0x20
    2f36:	mov    rsp,rbp
    2f39:	pop    rbp
    2f3a:	ret
    2f3b:	mov    rbx,rdi
    2f3e:	call   2f43 <botlish_fn_37+0xd8>
			2f3f: R_X86_64_PLT32	rt_stack_overflow-0x4
    2f43:	xor    rax,rax
    2f46:	mov    rbx,QWORD PTR [rsp]
    2f4a:	mov    r12,QWORD PTR [rsp+0x8]
    2f4f:	mov    r15,QWORD PTR [rsp+0x10]
    2f54:	add    rsp,0x20
    2f58:	mov    rsp,rbp
    2f5b:	pop    rbp
    2f5c:	ret

0000000000002f5d <botlish_entry_37: ht_probe_start<any, str>>:
    2f5d:	push   rbp
    2f5e:	mov    rbp,rsp
    2f61:	mov    rsi,QWORD PTR [rdx]
    2f64:	mov    rdx,QWORD PTR [rdx+0x8]
    2f68:	call   2f6d <botlish_entry_37+0x10>
			2f69: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    2f6d:	mov    rsp,rbp
    2f70:	pop    rbp
    2f71:	ret

0000000000002f72 <botlish_fn_38: ht_probe_next<mutarray, int>>:
    2f72:	push   rbp
    2f73:	mov    rbp,rsp
    2f76:	sub    rsp,0x20
    2f7a:	mov    QWORD PTR [rsp],rbx
    2f7e:	mov    QWORD PTR [rsp+0x8],r12
    2f83:	mov    QWORD PTR [rsp+0x10],r13
    2f88:	mov    rbx,QWORD PTR [rdi]
    2f8b:	mov    rax,QWORD PTR [rdi+0x8]
    2f8f:	lea    rcx,[rbx+0x18]
    2f93:	cmp    rcx,rax
    2f96:	ja     3072 <botlish_fn_38+0x100>
    2f9c:	lea    rax,[rbx+0x18]
    2fa0:	mov    QWORD PTR [rdi],rax
    2fa3:	mov    r12,rdi
    2fa6:	mov    QWORD PTR [rbx],rsi
    2fa9:	mov    r13,rsi
    2fac:	mov    QWORD PTR [rbx+0x8],rdx
    2fb0:	mov    QWORD PTR [rbx+0x10],0x3
    2fb8:	test   rdx,0x1
    2fbf:	jne    2fcd <botlish_fn_38+0x5b>
    2fc5:	mov    rcx,rdx
    2fc8:	jmp    2fe2 <botlish_fn_38+0x70>
    2fcd:	mov    rsi,rdx
    2fd0:	add    rsi,0x2
    2fd4:	mov    rcx,rdx
    2fd7:	seto   al
    2fda:	test   al,al
    2fdc:	je     2ff5 <botlish_fn_38+0x83>
    2fe2:	mov    edx,0x3
    2fe7:	mov    rsi,rcx
    2fea:	mov    rdi,r12
    2fed:	call   2ff2 <botlish_fn_38+0x80>
			2fee: R_X86_64_PLT32	rt_int_add-0x4
    2ff2:	mov    rsi,rax
    2ff5:	mov    QWORD PTR [rbx+0x8],rsi
    2ff9:	mov    rax,rsi
    2ffc:	mov    rsi,r13
    2fff:	mov    r13,rax
    3002:	mov    rdi,r12
    3005:	call   300a <botlish_fn_38+0x98>
			3006: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    300a:	test   rax,rax
    300d:	mov    rdx,rax
    3010:	jne    301e <botlish_fn_38+0xac>
    3016:	mov    rdi,r12
    3019:	jmp    3035 <botlish_fn_38+0xc3>
    301e:	mov    rsi,r13
    3021:	mov    rdi,r12
    3024:	call   3029 <botlish_fn_38+0xb7>
			3025: R_X86_64_PLT32	rt_int_mod-0x4
    3029:	test   rax,rax
    302c:	jne    3055 <botlish_fn_38+0xe3>
    3032:	mov    rdi,r12
    3035:	mov    rdi,r12
    3038:	mov    QWORD PTR [rdi],rbx
    303b:	xor    rax,rax
    303e:	mov    rbx,QWORD PTR [rsp]
    3042:	mov    r12,QWORD PTR [rsp+0x8]
    3047:	mov    r13,QWORD PTR [rsp+0x10]
    304c:	add    rsp,0x20
    3050:	mov    rsp,rbp
    3053:	pop    rbp
    3054:	ret
    3055:	mov    rdi,r12
    3058:	mov    QWORD PTR [rdi],rbx
    305b:	mov    rbx,QWORD PTR [rsp]
    305f:	mov    r12,QWORD PTR [rsp+0x8]
    3064:	mov    r13,QWORD PTR [rsp+0x10]
    3069:	add    rsp,0x20
    306d:	mov    rsp,rbp
    3070:	pop    rbp
    3071:	ret
    3072:	mov    r12,rdi
    3075:	call   307a <botlish_fn_38+0x108>
			3076: R_X86_64_PLT32	rt_stack_overflow-0x4
    307a:	xor    rax,rax
    307d:	mov    rbx,QWORD PTR [rsp]
    3081:	mov    r12,QWORD PTR [rsp+0x8]
    3086:	mov    r13,QWORD PTR [rsp+0x10]
    308b:	add    rsp,0x20
    308f:	mov    rsp,rbp
    3092:	pop    rbp
    3093:	ret

0000000000003094 <botlish_entry_38: ht_probe_next<mutarray, int>>:
    3094:	push   rbp
    3095:	mov    rbp,rsp
    3098:	mov    rsi,QWORD PTR [rdx]
    309b:	mov    rdx,QWORD PTR [rdx+0x8]
    309f:	call   30a4 <botlish_entry_38+0x10>
			30a0: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    30a4:	mov    rsp,rbp
    30a7:	pop    rbp
    30a8:	ret

00000000000030a9 <botlish_fn_39: ht_probe_next<any, int>>:
    30a9:	push   rbp
    30aa:	mov    rbp,rsp
    30ad:	sub    rsp,0x20
    30b1:	mov    QWORD PTR [rsp],rbx
    30b5:	mov    QWORD PTR [rsp+0x8],r12
    30ba:	mov    QWORD PTR [rsp+0x10],r13
    30bf:	mov    rbx,QWORD PTR [rdi]
    30c2:	mov    rax,QWORD PTR [rdi+0x8]
    30c6:	lea    rcx,[rbx+0x18]
    30ca:	cmp    rcx,rax
    30cd:	ja     31a9 <botlish_fn_39+0x100>
    30d3:	lea    rax,[rbx+0x18]
    30d7:	mov    QWORD PTR [rdi],rax
    30da:	mov    r12,rdi
    30dd:	mov    QWORD PTR [rbx],rsi
    30e0:	mov    r13,rsi
    30e3:	mov    QWORD PTR [rbx+0x8],rdx
    30e7:	mov    QWORD PTR [rbx+0x10],0x3
    30ef:	test   rdx,0x1
    30f6:	jne    3104 <botlish_fn_39+0x5b>
    30fc:	mov    rcx,rdx
    30ff:	jmp    3119 <botlish_fn_39+0x70>
    3104:	mov    rsi,rdx
    3107:	add    rsi,0x2
    310b:	mov    rcx,rdx
    310e:	seto   al
    3111:	test   al,al
    3113:	je     312c <botlish_fn_39+0x83>
    3119:	mov    edx,0x3
    311e:	mov    rsi,rcx
    3121:	mov    rdi,r12
    3124:	call   3129 <botlish_fn_39+0x80>
			3125: R_X86_64_PLT32	rt_int_add-0x4
    3129:	mov    rsi,rax
    312c:	mov    QWORD PTR [rbx+0x8],rsi
    3130:	mov    rax,rsi
    3133:	mov    rsi,r13
    3136:	mov    r13,rax
    3139:	mov    rdi,r12
    313c:	call   3141 <botlish_fn_39+0x98>
			313d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    3141:	test   rax,rax
    3144:	mov    rdx,rax
    3147:	jne    3155 <botlish_fn_39+0xac>
    314d:	mov    rdi,r12
    3150:	jmp    316c <botlish_fn_39+0xc3>
    3155:	mov    rsi,r13
    3158:	mov    rdi,r12
    315b:	call   3160 <botlish_fn_39+0xb7>
			315c: R_X86_64_PLT32	rt_int_mod-0x4
    3160:	test   rax,rax
    3163:	jne    318c <botlish_fn_39+0xe3>
    3169:	mov    rdi,r12
    316c:	mov    rdi,r12
    316f:	mov    QWORD PTR [rdi],rbx
    3172:	xor    rax,rax
    3175:	mov    rbx,QWORD PTR [rsp]
    3179:	mov    r12,QWORD PTR [rsp+0x8]
    317e:	mov    r13,QWORD PTR [rsp+0x10]
    3183:	add    rsp,0x20
    3187:	mov    rsp,rbp
    318a:	pop    rbp
    318b:	ret
    318c:	mov    rdi,r12
    318f:	mov    QWORD PTR [rdi],rbx
    3192:	mov    rbx,QWORD PTR [rsp]
    3196:	mov    r12,QWORD PTR [rsp+0x8]
    319b:	mov    r13,QWORD PTR [rsp+0x10]
    31a0:	add    rsp,0x20
    31a4:	mov    rsp,rbp
    31a7:	pop    rbp
    31a8:	ret
    31a9:	mov    r12,rdi
    31ac:	call   31b1 <botlish_fn_39+0x108>
			31ad: R_X86_64_PLT32	rt_stack_overflow-0x4
    31b1:	xor    rax,rax
    31b4:	mov    rbx,QWORD PTR [rsp]
    31b8:	mov    r12,QWORD PTR [rsp+0x8]
    31bd:	mov    r13,QWORD PTR [rsp+0x10]
    31c2:	add    rsp,0x20
    31c6:	mov    rsp,rbp
    31c9:	pop    rbp
    31ca:	ret

00000000000031cb <botlish_entry_39: ht_probe_next<any, int>>:
    31cb:	push   rbp
    31cc:	mov    rbp,rsp
    31cf:	mov    rsi,QWORD PTR [rdx]
    31d2:	mov    rdx,QWORD PTR [rdx+0x8]
    31d6:	call   31db <botlish_entry_39+0x10>
			31d7: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    31db:	mov    rsp,rbp
    31de:	pop    rbp
    31df:	ret

00000000000031e0 <botlish_fn_40: ht_find_get<any, str, int>>:
    31e0:	push   rbp
    31e1:	mov    rbp,rsp
    31e4:	sub    rsp,0x40
    31e8:	mov    QWORD PTR [rsp+0x10],rbx
    31ed:	mov    QWORD PTR [rsp+0x18],r12
    31f2:	mov    QWORD PTR [rsp+0x20],r13
    31f7:	mov    QWORD PTR [rsp+0x28],r14
    31fc:	mov    QWORD PTR [rsp+0x30],r15
    3201:	mov    r13,QWORD PTR [rdi]
    3204:	mov    rax,QWORD PTR [rdi+0x8]
    3208:	lea    r8,[r13+0x20]
    320c:	cmp    r8,rax
    320f:	ja     3551 <botlish_fn_40+0x371>
    3215:	lea    rax,[r13+0x20]
    3219:	mov    QWORD PTR [rdi],rax
    321c:	mov    r14,rdi
    321f:	mov    QWORD PTR [r13+0x18],0x0
    3227:	mov    QWORD PTR [r13+0x0],rsi
    322b:	mov    QWORD PTR [r13+0x8],rdx
    322f:	mov    QWORD PTR [rsp],rdx
    3233:	mov    QWORD PTR [r13+0x10],rcx
    3237:	mov    r15,rsi
    323a:	mov    QWORD PTR [rsp+0x8],rcx
    323f:	mov    rsi,r15
    3242:	mov    rdi,r14
    3245:	call   324a <botlish_fn_40+0x6a>
			3246: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    324a:	test   rax,rax
    324d:	jne    325b <botlish_fn_40+0x7b>
    3253:	mov    rdi,r14
    3256:	jmp    34b0 <botlish_fn_40+0x2d0>
    325b:	xor    ecx,ecx
    325d:	test   rax,0x7
    3263:	je     3271 <botlish_fn_40+0x91>
    3269:	mov    rsi,rax
    326c:	jmp    327f <botlish_fn_40+0x9f>
    3271:	movzx  r11,BYTE PTR [rax]
    3275:	mov    rsi,rax
    3278:	cmp    r11b,0x8
    327c:	sete   cl
    327f:	test   cl,cl
    3281:	jne    32a4 <botlish_fn_40+0xc4>
    3287:	mov    rdi,r14
    328a:	mov    rax,QWORD PTR [rdi+0x10]
    328e:	mov    rcx,QWORD PTR [rax+0x20]
    3292:	mov    edx,0x8
    3297:	call   329c <botlish_fn_40+0xbc>
			3298: R_X86_64_PLT32	rt_type_error-0x4
    329c:	mov    rdi,r14
    329f:	jmp    34b0 <botlish_fn_40+0x2d0>
    32a4:	mov    rdx,QWORD PTR [rsp+0x8]
    32a9:	mov    rdi,r14
    32ac:	call   32b1 <botlish_fn_40+0xd1>
			32ad: R_X86_64_PLT32	rt_mutarray_get-0x4
    32b1:	mov    rcx,rax
    32b4:	mov    r12,rax
    32b7:	test   rax,rcx
    32ba:	jne    32c8 <botlish_fn_40+0xe8>
    32c0:	mov    rdi,r14
    32c3:	jmp    34b0 <botlish_fn_40+0x2d0>
    32c8:	mov    rax,r12
    32cb:	mov    QWORD PTR [r13+0x18],rax
    32cf:	mov    rdi,r14
    32d2:	call   32d7 <botlish_fn_40+0xf7>
			32d3: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    32d7:	test   rax,rax
    32da:	jne    32e8 <botlish_fn_40+0x108>
    32e0:	mov    rdi,r14
    32e3:	jmp    34b0 <botlish_fn_40+0x2d0>
    32e8:	mov    rsi,r12
    32eb:	mov    rcx,rsi
    32ee:	and    rcx,rax
    32f1:	mov    rdx,rax
    32f4:	test   rcx,0x1
    32fb:	jne    331d <botlish_fn_40+0x13d>
    3301:	mov    rsi,r12
    3304:	mov    rdi,r14
    3307:	call   330c <botlish_fn_40+0x12c>
			3308: R_X86_64_PLT32	rt_value_eq-0x4
    330c:	test   rax,rax
    330f:	jne    332d <botlish_fn_40+0x14d>
    3315:	mov    rdi,r14
    3318:	jmp    34b0 <botlish_fn_40+0x2d0>
    331d:	mov    eax,0x2
    3322:	cmp    r12,rdx
    3325:	cmove  rax,QWORD PTR [rip+0x253]        # 3580 <botlish_fn_40+0x3a0>
    332d:	mov    ebx,0x6
    3332:	cmp    rax,0x6
    3336:	je     3522 <botlish_fn_40+0x342>
    333c:	mov    rdi,r14
    333f:	call   3344 <botlish_fn_40+0x164>
			3340: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3344:	test   rax,rax
    3347:	jne    3355 <botlish_fn_40+0x175>
    334d:	mov    rdi,r14
    3350:	jmp    34b0 <botlish_fn_40+0x2d0>
    3355:	mov    rcx,r12
    3358:	and    rcx,rax
    335b:	mov    rdx,rax
    335e:	test   rcx,0x1
    3365:	jne    3387 <botlish_fn_40+0x1a7>
    336b:	mov    rsi,r12
    336e:	mov    rdi,r14
    3371:	call   3376 <botlish_fn_40+0x196>
			3372: R_X86_64_PLT32	rt_value_eq-0x4
    3376:	test   rax,rax
    3379:	jne    339a <botlish_fn_40+0x1ba>
    337f:	mov    rdi,r14
    3382:	jmp    34b0 <botlish_fn_40+0x2d0>
    3387:	mov    rsi,r12
    338a:	mov    eax,0x2
    338f:	cmp    rsi,rdx
    3392:	cmove  rax,QWORD PTR [rip+0x1e6]        # 3580 <botlish_fn_40+0x3a0>
    339a:	cmp    rax,0x6
    339e:	je     33b2 <botlish_fn_40+0x1d2>
    33a4:	mov    ebx,0x2
    33a9:	mov    r12,QWORD PTR [rsp]
    33ad:	jmp    348a <botlish_fn_40+0x2aa>
    33b2:	mov    rsi,r15
    33b5:	mov    rdi,r14
    33b8:	call   33bd <botlish_fn_40+0x1dd>
			33b9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    33bd:	test   rax,rax
    33c0:	jne    33ce <botlish_fn_40+0x1ee>
    33c6:	mov    rdi,r14
    33c9:	jmp    34b0 <botlish_fn_40+0x2d0>
    33ce:	xor    ecx,ecx
    33d0:	test   rax,0x7
    33d6:	je     33e4 <botlish_fn_40+0x204>
    33dc:	mov    rsi,rax
    33df:	jmp    33f2 <botlish_fn_40+0x212>
    33e4:	movzx  rcx,BYTE PTR [rax]
    33e8:	mov    rsi,rax
    33eb:	rex cmp cl,0x8
    33ef:	sete   cl
    33f2:	test   cl,cl
    33f4:	jne    3417 <botlish_fn_40+0x237>
    33fa:	mov    rdi,r14
    33fd:	mov    rax,QWORD PTR [rdi+0x10]
    3401:	mov    rcx,QWORD PTR [rax+0x20]
    3405:	mov    edx,0x8
    340a:	call   340f <botlish_fn_40+0x22f>
			340b: R_X86_64_PLT32	rt_type_error-0x4
    340f:	mov    rdi,r14
    3412:	jmp    34b0 <botlish_fn_40+0x2d0>
    3417:	mov    rdx,QWORD PTR [rsp+0x8]
    341c:	mov    rdi,r14
    341f:	call   3424 <botlish_fn_40+0x244>
			3420: R_X86_64_PLT32	rt_mutarray_get-0x4
    3424:	test   rax,rax
    3427:	jne    3435 <botlish_fn_40+0x255>
    342d:	mov    rdi,r14
    3430:	jmp    34b0 <botlish_fn_40+0x2d0>
    3435:	mov    r12,QWORD PTR [rsp]
    3439:	mov    rcx,rax
    343c:	and    rcx,r12
    343f:	mov    rsi,rax
    3442:	test   rcx,0x1
    3449:	jne    346b <botlish_fn_40+0x28b>
    344f:	mov    rdx,r12
    3452:	mov    rdi,r14
    3455:	call   345a <botlish_fn_40+0x27a>
			3456: R_X86_64_PLT32	rt_value_eq-0x4
    345a:	test   rax,rax
    345d:	jne    347b <botlish_fn_40+0x29b>
    3463:	mov    rdi,r14
    3466:	jmp    34b0 <botlish_fn_40+0x2d0>
    346b:	mov    eax,0x2
    3470:	cmp    rsi,r12
    3473:	cmove  rax,QWORD PTR [rip+0x105]        # 3580 <botlish_fn_40+0x3a0>
    347b:	cmp    rax,0x6
    347f:	je     348a <botlish_fn_40+0x2aa>
    3485:	mov    ebx,0x2
    348a:	cmp    rbx,0x6
    348e:	je     34f5 <botlish_fn_40+0x315>
    3494:	mov    rdx,QWORD PTR [rsp+0x8]
    3499:	mov    rsi,r15
    349c:	mov    rdi,r14
    349f:	call   34a4 <botlish_fn_40+0x2c4>
			34a0: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    34a4:	test   rax,rax
    34a7:	jne    34db <botlish_fn_40+0x2fb>
    34ad:	mov    rdi,r14
    34b0:	mov    rdi,r14
    34b3:	mov    QWORD PTR [rdi],r13
    34b6:	xor    rax,rax
    34b9:	mov    rbx,QWORD PTR [rsp+0x10]
    34be:	mov    r12,QWORD PTR [rsp+0x18]
    34c3:	mov    r13,QWORD PTR [rsp+0x20]
    34c8:	mov    r14,QWORD PTR [rsp+0x28]
    34cd:	mov    r15,QWORD PTR [rsp+0x30]
    34d2:	add    rsp,0x40
    34d6:	mov    rsp,rbp
    34d9:	pop    rbp
    34da:	ret
    34db:	mov    QWORD PTR [r13+0x0],r15
    34df:	mov    QWORD PTR [r13+0x8],r12
    34e3:	mov    QWORD PTR [r13+0x10],rax
    34e7:	mov    QWORD PTR [rsp],r12
    34eb:	mov    QWORD PTR [rsp+0x8],rax
    34f0:	jmp    323f <botlish_fn_40+0x5f>
    34f5:	mov    rdi,r14
    34f8:	mov    QWORD PTR [rdi],r13
    34fb:	mov    rax,QWORD PTR [rsp+0x8]
    3500:	mov    rbx,QWORD PTR [rsp+0x10]
    3505:	mov    r12,QWORD PTR [rsp+0x18]
    350a:	mov    r13,QWORD PTR [rsp+0x20]
    350f:	mov    r14,QWORD PTR [rsp+0x28]
    3514:	mov    r15,QWORD PTR [rsp+0x30]
    3519:	add    rsp,0x40
    351d:	mov    rsp,rbp
    3520:	pop    rbp
    3521:	ret
    3522:	mov    rdi,r14
    3525:	mov    QWORD PTR [rdi],r13
    3528:	mov    rax,0xffffffffffffffff
    352f:	mov    rbx,QWORD PTR [rsp+0x10]
    3534:	mov    r12,QWORD PTR [rsp+0x18]
    3539:	mov    r13,QWORD PTR [rsp+0x20]
    353e:	mov    r14,QWORD PTR [rsp+0x28]
    3543:	mov    r15,QWORD PTR [rsp+0x30]
    3548:	add    rsp,0x40
    354c:	mov    rsp,rbp
    354f:	pop    rbp
    3550:	ret
    3551:	mov    r14,rdi
    3554:	call   3559 <botlish_fn_40+0x379>
			3555: R_X86_64_PLT32	rt_stack_overflow-0x4
    3559:	xor    rax,rax
    355c:	mov    rbx,QWORD PTR [rsp+0x10]
    3561:	mov    r12,QWORD PTR [rsp+0x18]
    3566:	mov    r13,QWORD PTR [rsp+0x20]
    356b:	mov    r14,QWORD PTR [rsp+0x28]
    3570:	mov    r15,QWORD PTR [rsp+0x30]
    3575:	add    rsp,0x40
    3579:	mov    rsp,rbp
    357c:	pop    rbp
    357d:	ret
    357e:	add    BYTE PTR [rax],al
    3580:	(bad)
    3581:	add    BYTE PTR [rax],al
    3583:	add    BYTE PTR [rax],al
    3585:	add    BYTE PTR [rax],al
	...

0000000000003588 <botlish_entry_40: ht_find_get<any, str, int>>:
    3588:	push   rbp
    3589:	mov    rbp,rsp
    358c:	mov    rsi,QWORD PTR [rdx]
    358f:	mov    r8,QWORD PTR [rdx+0x8]
    3593:	mov    rcx,QWORD PTR [rdx+0x10]
    3597:	mov    rdx,r8
    359a:	call   359f <botlish_entry_40+0x17>
			359b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    359f:	mov    rsp,rbp
    35a2:	pop    rbp
    35a3:	ret
    35a4:	add    BYTE PTR [rax],al
	...

00000000000035a8 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    35a8:	push   rbp
    35a9:	mov    rbp,rsp
    35ac:	sub    rsp,0x50
    35b0:	mov    QWORD PTR [rsp+0x20],rbx
    35b5:	mov    QWORD PTR [rsp+0x28],r12
    35ba:	mov    QWORD PTR [rsp+0x30],r13
    35bf:	mov    QWORD PTR [rsp+0x38],r14
    35c4:	mov    QWORD PTR [rsp+0x40],r15
    35c9:	mov    r13,QWORD PTR [rdi]
    35cc:	mov    rax,QWORD PTR [rdi+0x8]
    35d0:	lea    r9,[r13+0x28]
    35d4:	cmp    r9,rax
    35d7:	ja     3af8 <botlish_fn_41+0x550>
    35dd:	lea    rax,[r13+0x28]
    35e1:	mov    QWORD PTR [rdi],rax
    35e4:	mov    QWORD PTR [rsp],rdi
    35e8:	mov    QWORD PTR [r13+0x20],0x0
    35f0:	mov    QWORD PTR [r13+0x0],rsi
    35f4:	mov    QWORD PTR [r13+0x8],rdx
    35f8:	mov    r14,rdx
    35fb:	mov    QWORD PTR [r13+0x10],rcx
    35ff:	mov    QWORD PTR [r13+0x18],r8
    3603:	mov    rbx,rsi
    3606:	mov    r15,r8
    3609:	mov    QWORD PTR [rsp+0x8],rcx
    360e:	mov    rsi,rbx
    3611:	mov    rdi,QWORD PTR [rsp]
    3615:	call   361a <botlish_fn_41+0x72>
			3616: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    361a:	test   rax,rax
    361d:	jne    362c <botlish_fn_41+0x84>
    3623:	mov    rdi,QWORD PTR [rsp]
    3627:	jmp    39cb <botlish_fn_41+0x423>
    362c:	xor    ecx,ecx
    362e:	test   rax,0x7
    3634:	je     3642 <botlish_fn_41+0x9a>
    363a:	mov    rsi,rax
    363d:	jmp    3650 <botlish_fn_41+0xa8>
    3642:	movzx  rcx,BYTE PTR [rax]
    3646:	mov    rsi,rax
    3649:	rex cmp cl,0x8
    364d:	sete   cl
    3650:	test   cl,cl
    3652:	jne    3677 <botlish_fn_41+0xcf>
    3658:	mov    rdi,QWORD PTR [rsp]
    365c:	mov    rax,QWORD PTR [rdi+0x10]
    3660:	mov    rcx,QWORD PTR [rax+0x20]
    3664:	mov    edx,0x8
    3669:	call   366e <botlish_fn_41+0xc6>
			366a: R_X86_64_PLT32	rt_type_error-0x4
    366e:	mov    rdi,QWORD PTR [rsp]
    3672:	jmp    39cb <botlish_fn_41+0x423>
    3677:	mov    rdx,QWORD PTR [rsp+0x8]
    367c:	mov    rdi,QWORD PTR [rsp]
    3680:	call   3685 <botlish_fn_41+0xdd>
			3681: R_X86_64_PLT32	rt_mutarray_get-0x4
    3685:	mov    rcx,rax
    3688:	mov    QWORD PTR [rsp+0x10],rax
    368d:	test   rax,rcx
    3690:	jne    369f <botlish_fn_41+0xf7>
    3696:	mov    rdi,QWORD PTR [rsp]
    369a:	jmp    39cb <botlish_fn_41+0x423>
    369f:	mov    rax,QWORD PTR [rsp+0x10]
    36a4:	mov    QWORD PTR [r13+0x20],rax
    36a8:	mov    rdi,QWORD PTR [rsp]
    36ac:	call   36b1 <botlish_fn_41+0x109>
			36ad: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    36b1:	test   rax,rax
    36b4:	jne    36c3 <botlish_fn_41+0x11b>
    36ba:	mov    rdi,QWORD PTR [rsp]
    36be:	jmp    39cb <botlish_fn_41+0x423>
    36c3:	mov    rcx,QWORD PTR [rsp+0x10]
    36c8:	and    rcx,rax
    36cb:	mov    rdx,rax
    36ce:	test   rcx,0x1
    36d5:	jne    36fb <botlish_fn_41+0x153>
    36db:	mov    rsi,QWORD PTR [rsp+0x10]
    36e0:	mov    rdi,QWORD PTR [rsp]
    36e4:	call   36e9 <botlish_fn_41+0x141>
			36e5: R_X86_64_PLT32	rt_value_eq-0x4
    36e9:	test   rax,rax
    36ec:	jne    3710 <botlish_fn_41+0x168>
    36f2:	mov    rdi,QWORD PTR [rsp]
    36f6:	jmp    39cb <botlish_fn_41+0x423>
    36fb:	mov    eax,0x2
    3700:	mov    rcx,QWORD PTR [rsp+0x10]
    3705:	cmp    rcx,rdx
    3708:	cmove  rax,QWORD PTR [rip+0x418]        # 3b28 <botlish_fn_41+0x580>
    3710:	mov    r12d,0x6
    3716:	cmp    rax,0x6
    371a:	je     3a49 <botlish_fn_41+0x4a1>
    3720:	mov    rdi,QWORD PTR [rsp]
    3724:	call   3729 <botlish_fn_41+0x181>
			3725: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3729:	test   rax,rax
    372c:	jne    373b <botlish_fn_41+0x193>
    3732:	mov    rdi,QWORD PTR [rsp]
    3736:	jmp    39cb <botlish_fn_41+0x423>
    373b:	mov    rcx,QWORD PTR [rsp+0x10]
    3740:	and    rcx,rax
    3743:	mov    rdx,rax
    3746:	test   rcx,0x1
    374d:	jne    3773 <botlish_fn_41+0x1cb>
    3753:	mov    rsi,QWORD PTR [rsp+0x10]
    3758:	mov    rdi,QWORD PTR [rsp]
    375c:	call   3761 <botlish_fn_41+0x1b9>
			375d: R_X86_64_PLT32	rt_value_eq-0x4
    3761:	test   rax,rax
    3764:	jne    3788 <botlish_fn_41+0x1e0>
    376a:	mov    rdi,QWORD PTR [rsp]
    376e:	jmp    39cb <botlish_fn_41+0x423>
    3773:	mov    eax,0x2
    3778:	mov    rsi,QWORD PTR [rsp+0x10]
    377d:	cmp    rsi,rdx
    3780:	cmove  rax,QWORD PTR [rip+0x3a0]        # 3b28 <botlish_fn_41+0x580>
    3788:	cmp    rax,0x6
    378c:	je     379c <botlish_fn_41+0x1f4>
    3792:	mov    eax,0x2
    3797:	jmp    3880 <botlish_fn_41+0x2d8>
    379c:	mov    rsi,rbx
    379f:	mov    rdi,QWORD PTR [rsp]
    37a3:	call   37a8 <botlish_fn_41+0x200>
			37a4: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    37a8:	test   rax,rax
    37ab:	jne    37ba <botlish_fn_41+0x212>
    37b1:	mov    rdi,QWORD PTR [rsp]
    37b5:	jmp    39cb <botlish_fn_41+0x423>
    37ba:	xor    ecx,ecx
    37bc:	test   rax,0x7
    37c2:	je     37d0 <botlish_fn_41+0x228>
    37c8:	mov    rsi,rax
    37cb:	jmp    37de <botlish_fn_41+0x236>
    37d0:	movzx  rcx,BYTE PTR [rax]
    37d4:	mov    rsi,rax
    37d7:	rex cmp cl,0x8
    37db:	sete   cl
    37de:	test   cl,cl
    37e0:	jne    3805 <botlish_fn_41+0x25d>
    37e6:	mov    rdi,QWORD PTR [rsp]
    37ea:	mov    rax,QWORD PTR [rdi+0x10]
    37ee:	mov    rcx,QWORD PTR [rax+0x20]
    37f2:	mov    edx,0x8
    37f7:	call   37fc <botlish_fn_41+0x254>
			37f8: R_X86_64_PLT32	rt_type_error-0x4
    37fc:	mov    rdi,QWORD PTR [rsp]
    3800:	jmp    39cb <botlish_fn_41+0x423>
    3805:	mov    rdx,QWORD PTR [rsp+0x8]
    380a:	mov    rdi,QWORD PTR [rsp]
    380e:	call   3813 <botlish_fn_41+0x26b>
			380f: R_X86_64_PLT32	rt_mutarray_get-0x4
    3813:	test   rax,rax
    3816:	jne    3825 <botlish_fn_41+0x27d>
    381c:	mov    rdi,QWORD PTR [rsp]
    3820:	jmp    39cb <botlish_fn_41+0x423>
    3825:	mov    rcx,rax
    3828:	and    rcx,r14
    382b:	mov    rsi,rax
    382e:	test   rcx,0x1
    3835:	jne    3859 <botlish_fn_41+0x2b1>
    383b:	mov    rdx,r14
    383e:	mov    rdi,QWORD PTR [rsp]
    3842:	call   3847 <botlish_fn_41+0x29f>
			3843: R_X86_64_PLT32	rt_value_eq-0x4
    3847:	test   rax,rax
    384a:	jne    3869 <botlish_fn_41+0x2c1>
    3850:	mov    rdi,QWORD PTR [rsp]
    3854:	jmp    39cb <botlish_fn_41+0x423>
    3859:	mov    eax,0x2
    385e:	cmp    rsi,r14
    3861:	cmove  rax,QWORD PTR [rip+0x2bf]        # 3b28 <botlish_fn_41+0x580>
    3869:	cmp    rax,0x6
    386d:	je     387d <botlish_fn_41+0x2d5>
    3873:	mov    eax,0x2
    3878:	jmp    3880 <botlish_fn_41+0x2d8>
    387d:	mov    rax,r12
    3880:	cmp    rax,0x6
    3884:	je     3a1b <botlish_fn_41+0x473>
    388a:	mov    rdi,QWORD PTR [rsp]
    388e:	call   3893 <botlish_fn_41+0x2eb>
			388f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3893:	test   rax,rax
    3896:	jne    38a5 <botlish_fn_41+0x2fd>
    389c:	mov    rdi,QWORD PTR [rsp]
    38a0:	jmp    39cb <botlish_fn_41+0x423>
    38a5:	mov    rcx,QWORD PTR [rsp+0x10]
    38aa:	mov    rdx,rcx
    38ad:	and    rdx,rax
    38b0:	mov    r11,rax
    38b3:	test   rdx,0x1
    38ba:	jne    38e3 <botlish_fn_41+0x33b>
    38c0:	mov    rdx,r11
    38c3:	mov    rsi,QWORD PTR [rsp+0x10]
    38c8:	mov    rdi,QWORD PTR [rsp]
    38cc:	call   38d1 <botlish_fn_41+0x329>
			38cd: R_X86_64_PLT32	rt_value_eq-0x4
    38d1:	test   rax,rax
    38d4:	jne    38fb <botlish_fn_41+0x353>
    38da:	mov    rdi,QWORD PTR [rsp]
    38de:	jmp    39cb <botlish_fn_41+0x423>
    38e3:	mov    rdx,r11
    38e6:	mov    rsi,QWORD PTR [rsp+0x10]
    38eb:	mov    eax,0x2
    38f0:	cmp    rsi,rdx
    38f3:	cmove  rax,QWORD PTR [rip+0x22d]        # 3b28 <botlish_fn_41+0x580>
    38fb:	cmp    rax,0x6
    38ff:	je     3910 <botlish_fn_41+0x368>
    3905:	mov    r12d,0x2
    390b:	jmp    3963 <botlish_fn_41+0x3bb>
    3910:	test   r15,0x1
    3917:	jne    3943 <botlish_fn_41+0x39b>
    391d:	mov    edx,0x1
    3922:	mov    rsi,r15
    3925:	mov    rdi,QWORD PTR [rsp]
    3929:	call   392e <botlish_fn_41+0x386>
			392a: R_X86_64_PLT32	rt_int_cmp-0x4
    392e:	mov    ecx,0x2
    3933:	test   rax,rax
    3936:	cmovl  rcx,QWORD PTR [rip+0x1ea]        # 3b28 <botlish_fn_41+0x580>
    393e:	jmp    3953 <botlish_fn_41+0x3ab>
    3943:	mov    ecx,0x2
    3948:	test   r15,r15
    394b:	cmovle rcx,QWORD PTR [rip+0x1d5]        # 3b28 <botlish_fn_41+0x580>
    3953:	cmp    rcx,0x6
    3957:	je     3963 <botlish_fn_41+0x3bb>
    395d:	mov    r12d,0x2
    3963:	cmp    r12,0x6
    3967:	je     39ad <botlish_fn_41+0x405>
    396d:	mov    rdx,QWORD PTR [rsp+0x8]
    3972:	mov    rsi,rbx
    3975:	mov    rdi,QWORD PTR [rsp]
    3979:	call   397e <botlish_fn_41+0x3d6>
			397a: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    397e:	test   rax,rax
    3981:	jne    3990 <botlish_fn_41+0x3e8>
    3987:	mov    rdi,QWORD PTR [rsp]
    398b:	jmp    39cb <botlish_fn_41+0x423>
    3990:	mov    QWORD PTR [r13+0x0],rbx
    3994:	mov    QWORD PTR [r13+0x8],r14
    3998:	mov    QWORD PTR [r13+0x10],rax
    399c:	mov    rcx,r15
    399f:	mov    QWORD PTR [r13+0x18],rcx
    39a3:	mov    QWORD PTR [rsp+0x8],rax
    39a8:	jmp    360e <botlish_fn_41+0x66>
    39ad:	mov    rdx,QWORD PTR [rsp+0x8]
    39b2:	mov    rsi,rbx
    39b5:	mov    rdi,QWORD PTR [rsp]
    39b9:	call   39be <botlish_fn_41+0x416>
			39ba: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    39be:	test   rax,rax
    39c1:	jne    39f7 <botlish_fn_41+0x44f>
    39c7:	mov    rdi,QWORD PTR [rsp]
    39cb:	mov    rdi,QWORD PTR [rsp]
    39cf:	mov    QWORD PTR [rdi],r13
    39d2:	xor    rax,rax
    39d5:	mov    rbx,QWORD PTR [rsp+0x20]
    39da:	mov    r12,QWORD PTR [rsp+0x28]
    39df:	mov    r13,QWORD PTR [rsp+0x30]
    39e4:	mov    r14,QWORD PTR [rsp+0x38]
    39e9:	mov    r15,QWORD PTR [rsp+0x40]
    39ee:	add    rsp,0x50
    39f2:	mov    rsp,rbp
    39f5:	pop    rbp
    39f6:	ret
    39f7:	mov    QWORD PTR [r13+0x0],rbx
    39fb:	mov    QWORD PTR [r13+0x8],r14
    39ff:	mov    QWORD PTR [r13+0x10],rax
    3a03:	mov    rdx,QWORD PTR [rsp+0x8]
    3a08:	mov    QWORD PTR [r13+0x18],rdx
    3a0c:	mov    r15,QWORD PTR [rsp+0x8]
    3a11:	mov    QWORD PTR [rsp+0x8],rax
    3a16:	jmp    360e <botlish_fn_41+0x66>
    3a1b:	mov    rdi,QWORD PTR [rsp]
    3a1f:	mov    QWORD PTR [rdi],r13
    3a22:	mov    rax,QWORD PTR [rsp+0x8]
    3a27:	mov    rbx,QWORD PTR [rsp+0x20]
    3a2c:	mov    r12,QWORD PTR [rsp+0x28]
    3a31:	mov    r13,QWORD PTR [rsp+0x30]
    3a36:	mov    r14,QWORD PTR [rsp+0x38]
    3a3b:	mov    r15,QWORD PTR [rsp+0x40]
    3a40:	add    rsp,0x50
    3a44:	mov    rsp,rbp
    3a47:	pop    rbp
    3a48:	ret
    3a49:	mov    rax,r15
    3a4c:	test   rax,0x1
    3a52:	jne    3a7e <botlish_fn_41+0x4d6>
    3a58:	mov    edx,0x1
    3a5d:	mov    rsi,r15
    3a60:	mov    rdi,QWORD PTR [rsp]
    3a64:	call   3a69 <botlish_fn_41+0x4c1>
			3a65: R_X86_64_PLT32	rt_int_cmp-0x4
    3a69:	mov    ecx,0x2
    3a6e:	test   rax,rax
    3a71:	cmovge rcx,QWORD PTR [rip+0xaf]        # 3b28 <botlish_fn_41+0x580>
    3a79:	jmp    3a94 <botlish_fn_41+0x4ec>
    3a7e:	mov    ecx,0x2
    3a83:	mov    rax,r15
    3a86:	mov    r10,r15
    3a89:	test   rax,r10
    3a8c:	cmovg  rcx,QWORD PTR [rip+0x94]        # 3b28 <botlish_fn_41+0x580>
    3a94:	cmp    rcx,0x6
    3a98:	je     3acc <botlish_fn_41+0x524>
    3a9e:	mov    rdi,QWORD PTR [rsp]
    3aa2:	mov    QWORD PTR [rdi],r13
    3aa5:	mov    rax,QWORD PTR [rsp+0x8]
    3aaa:	mov    rbx,QWORD PTR [rsp+0x20]
    3aaf:	mov    r12,QWORD PTR [rsp+0x28]
    3ab4:	mov    r13,QWORD PTR [rsp+0x30]
    3ab9:	mov    r14,QWORD PTR [rsp+0x38]
    3abe:	mov    r15,QWORD PTR [rsp+0x40]
    3ac3:	add    rsp,0x50
    3ac7:	mov    rsp,rbp
    3aca:	pop    rbp
    3acb:	ret
    3acc:	mov    rdi,QWORD PTR [rsp]
    3ad0:	mov    QWORD PTR [rdi],r13
    3ad3:	mov    rax,r15
    3ad6:	mov    rbx,QWORD PTR [rsp+0x20]
    3adb:	mov    r12,QWORD PTR [rsp+0x28]
    3ae0:	mov    r13,QWORD PTR [rsp+0x30]
    3ae5:	mov    r14,QWORD PTR [rsp+0x38]
    3aea:	mov    r15,QWORD PTR [rsp+0x40]
    3aef:	add    rsp,0x50
    3af3:	mov    rsp,rbp
    3af6:	pop    rbp
    3af7:	ret
    3af8:	mov    QWORD PTR [rsp],rdi
    3afc:	call   3b01 <botlish_fn_41+0x559>
			3afd: R_X86_64_PLT32	rt_stack_overflow-0x4
    3b01:	xor    rax,rax
    3b04:	mov    rbx,QWORD PTR [rsp+0x20]
    3b09:	mov    r12,QWORD PTR [rsp+0x28]
    3b0e:	mov    r13,QWORD PTR [rsp+0x30]
    3b13:	mov    r14,QWORD PTR [rsp+0x38]
    3b18:	mov    r15,QWORD PTR [rsp+0x40]
    3b1d:	add    rsp,0x50
    3b21:	mov    rsp,rbp
    3b24:	pop    rbp
    3b25:	ret
    3b26:	add    BYTE PTR [rax],al
    3b28:	(bad)
    3b29:	add    BYTE PTR [rax],al
    3b2b:	add    BYTE PTR [rax],al
    3b2d:	add    BYTE PTR [rax],al
	...

0000000000003b30 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    3b30:	push   rbp
    3b31:	mov    rbp,rsp
    3b34:	mov    rsi,QWORD PTR [rdx]
    3b37:	mov    r9,QWORD PTR [rdx+0x8]
    3b3b:	mov    rcx,QWORD PTR [rdx+0x10]
    3b3f:	mov    r8,QWORD PTR [rdx+0x18]
    3b43:	mov    rdx,r9
    3b46:	call   3b4b <botlish_entry_41+0x1b>
			3b47: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    3b4b:	mov    rsp,rbp
    3b4e:	pop    rbp
    3b4f:	ret

0000000000003b50 <botlish_fn_42: ht_get<any, str>>:
    3b50:	push   rbp
    3b51:	mov    rbp,rsp
    3b54:	sub    rsp,0x20
    3b58:	mov    QWORD PTR [rsp],rbx
    3b5c:	mov    QWORD PTR [rsp+0x8],r12
    3b61:	mov    QWORD PTR [rsp+0x10],r13
    3b66:	mov    QWORD PTR [rsp+0x18],r14
    3b6b:	mov    rbx,QWORD PTR [rdi]
    3b6e:	mov    rax,QWORD PTR [rdi+0x8]
    3b72:	lea    rcx,[rbx+0x18]
    3b76:	cmp    rcx,rax
    3b79:	ja     3d23 <botlish_fn_42+0x1d3>
    3b7f:	lea    rax,[rbx+0x18]
    3b83:	mov    QWORD PTR [rdi],rax
    3b86:	mov    r12,rdi
    3b89:	mov    QWORD PTR [rbx+0x10],0x0
    3b91:	mov    QWORD PTR [rbx],rsi
    3b94:	mov    r13,rsi
    3b97:	mov    QWORD PTR [rbx+0x8],rdx
    3b9b:	mov    r14,rdx
    3b9e:	mov    rdx,r14
    3ba1:	mov    rsi,r13
    3ba4:	mov    rdi,r12
    3ba7:	call   3bac <botlish_fn_42+0x5c>
			3ba8: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    3bac:	test   rax,rax
    3baf:	jne    3bbd <botlish_fn_42+0x6d>
    3bb5:	mov    rdi,r12
    3bb8:	jmp    3cb5 <botlish_fn_42+0x165>
    3bbd:	mov    QWORD PTR [rbx+0x10],rax
    3bc1:	mov    rcx,rax
    3bc4:	mov    rdx,r14
    3bc7:	mov    rsi,r13
    3bca:	mov    rdi,r12
    3bcd:	call   3bd2 <botlish_fn_42+0x82>
			3bce: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    3bd2:	mov    r10,rax
    3bd5:	mov    r14,rax
    3bd8:	test   rax,r10
    3bdb:	jne    3be9 <botlish_fn_42+0x99>
    3be1:	mov    rdi,r12
    3be4:	jmp    3cb5 <botlish_fn_42+0x165>
    3be9:	mov    rax,r14
    3bec:	mov    QWORD PTR [rbx+0x8],rax
    3bf0:	test   rax,0x1
    3bf6:	jne    3c21 <botlish_fn_42+0xd1>
    3bfc:	mov    edx,0x1
    3c01:	mov    rsi,r14
    3c04:	mov    rdi,r12
    3c07:	call   3c0c <botlish_fn_42+0xbc>
			3c08: R_X86_64_PLT32	rt_int_cmp-0x4
    3c0c:	mov    ecx,0x2
    3c11:	test   rax,rax
    3c14:	cmovl  rcx,QWORD PTR [rip+0x134]        # 3d50 <botlish_fn_42+0x200>
    3c1c:	jmp    3c34 <botlish_fn_42+0xe4>
    3c21:	mov    ecx,0x2
    3c26:	mov    rax,r14
    3c29:	test   rax,rax
    3c2c:	cmovle rcx,QWORD PTR [rip+0x11c]        # 3d50 <botlish_fn_42+0x200>
    3c34:	cmp    rcx,0x6
    3c38:	je     3cfc <botlish_fn_42+0x1ac>
    3c3e:	mov    rsi,r13
    3c41:	mov    rdi,r12
    3c44:	call   3c49 <botlish_fn_42+0xf9>
			3c45: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    3c49:	test   rax,rax
    3c4c:	jne    3c5a <botlish_fn_42+0x10a>
    3c52:	mov    rdi,r12
    3c55:	jmp    3cb5 <botlish_fn_42+0x165>
    3c5a:	xor    ecx,ecx
    3c5c:	test   rax,0x7
    3c62:	jne    3c73 <botlish_fn_42+0x123>
    3c68:	movzx  rcx,BYTE PTR [rax]
    3c6c:	rex cmp cl,0x8
    3c70:	sete   cl
    3c73:	test   cl,cl
    3c75:	jne    3c9b <botlish_fn_42+0x14b>
    3c7b:	mov    rdi,r12
    3c7e:	mov    rsi,QWORD PTR [rdi+0x10]
    3c82:	mov    rcx,QWORD PTR [rsi+0x20]
    3c86:	mov    edx,0x8
    3c8b:	mov    rsi,rax
    3c8e:	call   3c93 <botlish_fn_42+0x143>
			3c8f: R_X86_64_PLT32	rt_type_error-0x4
    3c93:	mov    rdi,r12
    3c96:	jmp    3cb5 <botlish_fn_42+0x165>
    3c9b:	mov    rdx,r14
    3c9e:	mov    rsi,rax
    3ca1:	mov    rdi,r12
    3ca4:	call   3ca9 <botlish_fn_42+0x159>
			3ca5: R_X86_64_PLT32	rt_mutarray_get-0x4
    3ca9:	test   rax,rax
    3cac:	jne    3cda <botlish_fn_42+0x18a>
    3cb2:	mov    rdi,r12
    3cb5:	mov    rdi,r12
    3cb8:	mov    QWORD PTR [rdi],rbx
    3cbb:	xor    rax,rax
    3cbe:	mov    rbx,QWORD PTR [rsp]
    3cc2:	mov    r12,QWORD PTR [rsp+0x8]
    3cc7:	mov    r13,QWORD PTR [rsp+0x10]
    3ccc:	mov    r14,QWORD PTR [rsp+0x18]
    3cd1:	add    rsp,0x20
    3cd5:	mov    rsp,rbp
    3cd8:	pop    rbp
    3cd9:	ret
    3cda:	mov    rdi,r12
    3cdd:	mov    QWORD PTR [rdi],rbx
    3ce0:	mov    rbx,QWORD PTR [rsp]
    3ce4:	mov    r12,QWORD PTR [rsp+0x8]
    3ce9:	mov    r13,QWORD PTR [rsp+0x10]
    3cee:	mov    r14,QWORD PTR [rsp+0x18]
    3cf3:	add    rsp,0x20
    3cf7:	mov    rsp,rbp
    3cfa:	pop    rbp
    3cfb:	ret
    3cfc:	mov    rdi,r12
    3cff:	mov    QWORD PTR [rdi],rbx
    3d02:	mov    eax,0xa
    3d07:	mov    rbx,QWORD PTR [rsp]
    3d0b:	mov    r12,QWORD PTR [rsp+0x8]
    3d10:	mov    r13,QWORD PTR [rsp+0x10]
    3d15:	mov    r14,QWORD PTR [rsp+0x18]
    3d1a:	add    rsp,0x20
    3d1e:	mov    rsp,rbp
    3d21:	pop    rbp
    3d22:	ret
    3d23:	mov    r12,rdi
    3d26:	call   3d2b <botlish_fn_42+0x1db>
			3d27: R_X86_64_PLT32	rt_stack_overflow-0x4
    3d2b:	xor    rax,rax
    3d2e:	mov    rbx,QWORD PTR [rsp]
    3d32:	mov    r12,QWORD PTR [rsp+0x8]
    3d37:	mov    r13,QWORD PTR [rsp+0x10]
    3d3c:	mov    r14,QWORD PTR [rsp+0x18]
    3d41:	add    rsp,0x20
    3d45:	mov    rsp,rbp
    3d48:	pop    rbp
    3d49:	ret
    3d4a:	add    BYTE PTR [rax],al
    3d4c:	add    BYTE PTR [rax],al
    3d4e:	add    BYTE PTR [rax],al
    3d50:	(bad)
    3d51:	add    BYTE PTR [rax],al
    3d53:	add    BYTE PTR [rax],al
    3d55:	add    BYTE PTR [rax],al
	...

0000000000003d58 <botlish_entry_42: ht_get<any, str>>:
    3d58:	push   rbp
    3d59:	mov    rbp,rsp
    3d5c:	mov    rsi,QWORD PTR [rdx]
    3d5f:	mov    rdx,QWORD PTR [rdx+0x8]
    3d63:	call   3d68 <botlish_entry_42+0x10>
			3d64: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    3d68:	mov    rsp,rbp
    3d6b:	pop    rbp
    3d6c:	ret
    3d6d:	add    BYTE PTR [rax],al
	...

0000000000003d70 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    3d70:	push   rbp
    3d71:	mov    rbp,rsp
    3d74:	sub    rsp,0x40
    3d78:	mov    QWORD PTR [rsp+0x10],rbx
    3d7d:	mov    QWORD PTR [rsp+0x18],r12
    3d82:	mov    QWORD PTR [rsp+0x20],r13
    3d87:	mov    QWORD PTR [rsp+0x28],r14
    3d8c:	mov    QWORD PTR [rsp+0x30],r15
    3d91:	mov    r12,QWORD PTR [rdi]
    3d94:	mov    rax,QWORD PTR [rdi+0x8]
    3d98:	lea    r8,[r12+0x20]
    3d9d:	cmp    r8,rax
    3da0:	ja     3f1f <botlish_fn_43+0x1af>
    3da6:	lea    rax,[r12+0x20]
    3dab:	mov    QWORD PTR [rdi],rax
    3dae:	mov    r13,rdi
    3db1:	mov    QWORD PTR [r12],rsi
    3db5:	mov    QWORD PTR [r12+0x8],rdx
    3dba:	mov    QWORD PTR [r12+0x10],rcx
    3dbf:	mov    r15,rcx
    3dc2:	mov    rbx,rsi
    3dc5:	mov    r14,rdx
    3dc8:	mov    rdx,r14
    3dcb:	mov    rsi,rbx
    3dce:	mov    rdi,r13
    3dd1:	call   3dd6 <botlish_fn_43+0x66>
			3dd2: R_X86_64_PLT32	rt_mutarray_get-0x4
    3dd6:	test   rax,rax
    3dd9:	jne    3de7 <botlish_fn_43+0x77>
    3ddf:	mov    rdi,r13
    3de2:	jmp    3eb3 <botlish_fn_43+0x143>
    3de7:	mov    QWORD PTR [r12+0x18],rax
    3dec:	mov    QWORD PTR [rsp],rax
    3df0:	mov    rdi,r13
    3df3:	call   3df8 <botlish_fn_43+0x88>
			3df4: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    3df8:	test   rax,rax
    3dfb:	jne    3e09 <botlish_fn_43+0x99>
    3e01:	mov    rdi,r13
    3e04:	jmp    3eb3 <botlish_fn_43+0x143>
    3e09:	mov    rsi,QWORD PTR [rsp]
    3e0d:	mov    rcx,rsi
    3e10:	and    rcx,rax
    3e13:	mov    rdx,rax
    3e16:	test   rcx,0x1
    3e1d:	jne    3e40 <botlish_fn_43+0xd0>
    3e23:	mov    rsi,QWORD PTR [rsp]
    3e27:	mov    rdi,r13
    3e2a:	call   3e2f <botlish_fn_43+0xbf>
			3e2b: R_X86_64_PLT32	rt_value_eq-0x4
    3e2f:	test   rax,rax
    3e32:	jne    3e54 <botlish_fn_43+0xe4>
    3e38:	mov    rdi,r13
    3e3b:	jmp    3eb3 <botlish_fn_43+0x143>
    3e40:	mov    rsi,QWORD PTR [rsp]
    3e44:	mov    eax,0x2
    3e49:	cmp    rsi,rdx
    3e4c:	cmove  rax,QWORD PTR [rip+0xfc]        # 3f50 <botlish_fn_43+0x1e0>
    3e54:	cmp    rax,0x6
    3e58:	je     3ef4 <botlish_fn_43+0x184>
    3e5e:	mov    QWORD PTR [r12+0x18],0x3
    3e67:	mov    rsi,r14
    3e6a:	test   rsi,0x1
    3e71:	je     3e89 <botlish_fn_43+0x119>
    3e77:	mov    rsi,r14
    3e7a:	add    rsi,0x2
    3e7e:	seto   al
    3e81:	test   al,al
    3e83:	je     3e9c <botlish_fn_43+0x12c>
    3e89:	mov    edx,0x3
    3e8e:	mov    rsi,r14
    3e91:	mov    rdi,r13
    3e94:	call   3e99 <botlish_fn_43+0x129>
			3e95: R_X86_64_PLT32	rt_int_add-0x4
    3e99:	mov    rsi,rax
    3e9c:	mov    rdx,r15
    3e9f:	mov    rdi,r13
    3ea2:	call   3ea7 <botlish_fn_43+0x137>
			3ea3: R_X86_64_PLT32	rt_int_mod-0x4
    3ea7:	test   rax,rax
    3eaa:	jne    3ede <botlish_fn_43+0x16e>
    3eb0:	mov    rdi,r13
    3eb3:	mov    rdi,r13
    3eb6:	mov    QWORD PTR [rdi],r12
    3eb9:	xor    rax,rax
    3ebc:	mov    rbx,QWORD PTR [rsp+0x10]
    3ec1:	mov    r12,QWORD PTR [rsp+0x18]
    3ec6:	mov    r13,QWORD PTR [rsp+0x20]
    3ecb:	mov    r14,QWORD PTR [rsp+0x28]
    3ed0:	mov    r15,QWORD PTR [rsp+0x30]
    3ed5:	add    rsp,0x40
    3ed9:	mov    rsp,rbp
    3edc:	pop    rbp
    3edd:	ret
    3ede:	mov    QWORD PTR [r12],rbx
    3ee2:	mov    QWORD PTR [r12+0x8],rax
    3ee7:	mov    QWORD PTR [r12+0x10],r15
    3eec:	mov    r14,rax
    3eef:	jmp    3dc8 <botlish_fn_43+0x58>
    3ef4:	mov    rdi,r13
    3ef7:	mov    QWORD PTR [rdi],r12
    3efa:	mov    rax,r14
    3efd:	mov    rbx,QWORD PTR [rsp+0x10]
    3f02:	mov    r12,QWORD PTR [rsp+0x18]
    3f07:	mov    r13,QWORD PTR [rsp+0x20]
    3f0c:	mov    r14,QWORD PTR [rsp+0x28]
    3f11:	mov    r15,QWORD PTR [rsp+0x30]
    3f16:	add    rsp,0x40
    3f1a:	mov    rsp,rbp
    3f1d:	pop    rbp
    3f1e:	ret
    3f1f:	mov    r13,rdi
    3f22:	call   3f27 <botlish_fn_43+0x1b7>
			3f23: R_X86_64_PLT32	rt_stack_overflow-0x4
    3f27:	xor    rax,rax
    3f2a:	mov    rbx,QWORD PTR [rsp+0x10]
    3f2f:	mov    r12,QWORD PTR [rsp+0x18]
    3f34:	mov    r13,QWORD PTR [rsp+0x20]
    3f39:	mov    r14,QWORD PTR [rsp+0x28]
    3f3e:	mov    r15,QWORD PTR [rsp+0x30]
    3f43:	add    rsp,0x40
    3f47:	mov    rsp,rbp
    3f4a:	pop    rbp
    3f4b:	ret
    3f4c:	add    BYTE PTR [rax],al
    3f4e:	add    BYTE PTR [rax],al
    3f50:	(bad)
    3f51:	add    BYTE PTR [rax],al
    3f53:	add    BYTE PTR [rax],al
    3f55:	add    BYTE PTR [rax],al
	...

0000000000003f58 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    3f58:	push   rbp
    3f59:	mov    rbp,rsp
    3f5c:	mov    rsi,QWORD PTR [rdx]
    3f5f:	mov    r8,QWORD PTR [rdx+0x8]
    3f63:	mov    rcx,QWORD PTR [rdx+0x10]
    3f67:	mov    rdx,r8
    3f6a:	call   3f6f <botlish_entry_43+0x17>
			3f6b: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    3f6f:	mov    rsp,rbp
    3f72:	pop    rbp
    3f73:	ret

0000000000003f74 <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    3f74:	push   rbp
    3f75:	mov    rbp,rsp
    3f78:	sub    rsp,0x50
    3f7c:	mov    QWORD PTR [rsp+0x20],rbx
    3f81:	mov    QWORD PTR [rsp+0x28],r12
    3f86:	mov    QWORD PTR [rsp+0x30],r13
    3f8b:	mov    QWORD PTR [rsp+0x38],r14
    3f90:	mov    QWORD PTR [rsp+0x40],r15
    3f95:	mov    r10,QWORD PTR [rbp+0x10]
    3f99:	mov    rbx,QWORD PTR [rdi]
    3f9c:	mov    rax,QWORD PTR [rdi+0x8]
    3fa0:	lea    r11,[rbx+0x38]
    3fa4:	cmp    r11,rax
    3fa7:	ja     412f <botlish_fn_44+0x1bb>
    3fad:	lea    rax,[rbx+0x38]
    3fb1:	mov    QWORD PTR [rdi],rax
    3fb4:	mov    r12,rdi
    3fb7:	mov    QWORD PTR [rbx],rsi
    3fba:	mov    QWORD PTR [rsp],rsi
    3fbe:	mov    QWORD PTR [rbx+0x8],rdx
    3fc2:	mov    QWORD PTR [rsp+0x8],rdx
    3fc7:	mov    QWORD PTR [rbx+0x10],rcx
    3fcb:	mov    r13,rcx
    3fce:	mov    QWORD PTR [rbx+0x18],r8
    3fd2:	mov    QWORD PTR [rsp+0x10],r8
    3fd7:	mov    QWORD PTR [rbx+0x20],r9
    3fdb:	mov    r15,r9
    3fde:	mov    QWORD PTR [rbx+0x28],r10
    3fe2:	mov    r14,r10
    3fe5:	mov    rsi,r15
    3fe8:	mov    rdi,r12
    3feb:	call   3ff0 <botlish_fn_44+0x7c>
			3fec: R_X86_64_PLT32	rt_hash-0x4
    3ff0:	test   rax,rax
    3ff3:	mov    rsi,rax
    3ff6:	jne    4004 <botlish_fn_44+0x90>
    3ffc:	mov    rdi,r12
    3fff:	jmp    40d7 <botlish_fn_44+0x163>
    4004:	mov    rdx,QWORD PTR [rsp+0x10]
    4009:	mov    rdi,r12
    400c:	call   4011 <botlish_fn_44+0x9d>
			400d: R_X86_64_PLT32	rt_int_mod-0x4
    4011:	test   rax,rax
    4014:	jne    4022 <botlish_fn_44+0xae>
    401a:	mov    rdi,r12
    401d:	jmp    40d7 <botlish_fn_44+0x163>
    4022:	mov    QWORD PTR [rbx+0x30],rax
    4026:	mov    rcx,QWORD PTR [rsp+0x10]
    402b:	mov    rdx,rax
    402e:	mov    rsi,QWORD PTR [rsp]
    4032:	mov    rdi,r12
    4035:	call   403a <botlish_fn_44+0xc6>
			4036: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    403a:	test   rax,rax
    403d:	jne    404b <botlish_fn_44+0xd7>
    4043:	mov    rdi,r12
    4046:	jmp    40d7 <botlish_fn_44+0x163>
    404b:	mov    QWORD PTR [rbx+0x18],rax
    404f:	mov    QWORD PTR [rsp+0x10],rax
    4054:	mov    rdi,r12
    4057:	call   405c <botlish_fn_44+0xe8>
			4058: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    405c:	test   rax,rax
    405f:	mov    rcx,rax
    4062:	jne    4070 <botlish_fn_44+0xfc>
    4068:	mov    rdi,r12
    406b:	jmp    40d7 <botlish_fn_44+0x163>
    4070:	mov    rsi,QWORD PTR [rsp]
    4074:	mov    rdx,QWORD PTR [rsp+0x10]
    4079:	mov    rdi,r12
    407c:	call   4081 <botlish_fn_44+0x10d>
			407d: R_X86_64_PLT32	rt_mutarray_set-0x4
    4081:	test   rax,rax
    4084:	jne    4092 <botlish_fn_44+0x11e>
    408a:	mov    rdi,r12
    408d:	jmp    40d7 <botlish_fn_44+0x163>
    4092:	mov    rcx,r15
    4095:	mov    rsi,QWORD PTR [rsp+0x8]
    409a:	mov    rdx,QWORD PTR [rsp+0x10]
    409f:	mov    rdi,r12
    40a2:	call   40a7 <botlish_fn_44+0x133>
			40a3: R_X86_64_PLT32	rt_mutarray_set-0x4
    40a7:	test   rax,rax
    40aa:	jne    40b8 <botlish_fn_44+0x144>
    40b0:	mov    rdi,r12
    40b3:	jmp    40d7 <botlish_fn_44+0x163>
    40b8:	mov    rcx,r14
    40bb:	mov    rdx,QWORD PTR [rsp+0x10]
    40c0:	mov    rsi,r13
    40c3:	mov    rdi,r12
    40c6:	call   40cb <botlish_fn_44+0x157>
			40c7: R_X86_64_PLT32	rt_mutarray_set-0x4
    40cb:	test   rax,rax
    40ce:	jne    4102 <botlish_fn_44+0x18e>
    40d4:	mov    rdi,r12
    40d7:	mov    rdi,r12
    40da:	mov    QWORD PTR [rdi],rbx
    40dd:	xor    rax,rax
    40e0:	mov    rbx,QWORD PTR [rsp+0x20]
    40e5:	mov    r12,QWORD PTR [rsp+0x28]
    40ea:	mov    r13,QWORD PTR [rsp+0x30]
    40ef:	mov    r14,QWORD PTR [rsp+0x38]
    40f4:	mov    r15,QWORD PTR [rsp+0x40]
    40f9:	add    rsp,0x50
    40fd:	mov    rsp,rbp
    4100:	pop    rbp
    4101:	ret
    4102:	mov    rdi,r12
    4105:	mov    QWORD PTR [rdi],rbx
    4108:	mov    eax,0xa
    410d:	mov    rbx,QWORD PTR [rsp+0x20]
    4112:	mov    r12,QWORD PTR [rsp+0x28]
    4117:	mov    r13,QWORD PTR [rsp+0x30]
    411c:	mov    r14,QWORD PTR [rsp+0x38]
    4121:	mov    r15,QWORD PTR [rsp+0x40]
    4126:	add    rsp,0x50
    412a:	mov    rsp,rbp
    412d:	pop    rbp
    412e:	ret
    412f:	mov    r12,rdi
    4132:	call   4137 <botlish_fn_44+0x1c3>
			4133: R_X86_64_PLT32	rt_stack_overflow-0x4
    4137:	xor    rax,rax
    413a:	mov    rbx,QWORD PTR [rsp+0x20]
    413f:	mov    r12,QWORD PTR [rsp+0x28]
    4144:	mov    r13,QWORD PTR [rsp+0x30]
    4149:	mov    r14,QWORD PTR [rsp+0x38]
    414e:	mov    r15,QWORD PTR [rsp+0x40]
    4153:	add    rsp,0x50
    4157:	mov    rsp,rbp
    415a:	pop    rbp
    415b:	ret

000000000000415c <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    415c:	push   rbp
    415d:	mov    rbp,rsp
    4160:	sub    rsp,0x10
    4164:	mov    rsi,QWORD PTR [rdx]
    4167:	mov    r10,QWORD PTR [rdx+0x8]
    416b:	mov    rcx,QWORD PTR [rdx+0x10]
    416f:	mov    r8,QWORD PTR [rdx+0x18]
    4173:	mov    r9,QWORD PTR [rdx+0x20]
    4177:	mov    r11,QWORD PTR [rdx+0x28]
    417b:	mov    QWORD PTR [rsp],r11
    417f:	mov    rdx,r10
    4182:	call   4187 <botlish_entry_44+0x2b>
			4183: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    4187:	add    rsp,0x10
    418b:	mov    rsp,rbp
    418e:	pop    rbp
    418f:	ret

0000000000004190 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4190:	push   rbp
    4191:	mov    rbp,rsp
    4194:	sub    rsp,0x80
    419b:	mov    QWORD PTR [rsp+0x50],rbx
    41a0:	mov    QWORD PTR [rsp+0x58],r12
    41a5:	mov    QWORD PTR [rsp+0x60],r13
    41aa:	mov    QWORD PTR [rsp+0x68],r14
    41af:	mov    QWORD PTR [rsp+0x70],r15
    41b4:	mov    r13,QWORD PTR [rbp+0x10]
    41b8:	mov    r14,QWORD PTR [rbp+0x18]
    41bc:	mov    r15,QWORD PTR [rbp+0x20]
    41c0:	mov    r12,QWORD PTR [rbp+0x28]
    41c4:	mov    QWORD PTR [rsp+0x38],r12
    41c9:	mov    r12,QWORD PTR [rdi]
    41cc:	mov    r11,QWORD PTR [rdi+0x8]
    41d0:	lea    rax,[r12+0x58]
    41d5:	cmp    rax,r11
    41d8:	ja     45f6 <botlish_fn_45+0x466>
    41de:	lea    rax,[r12+0x58]
    41e3:	mov    QWORD PTR [rdi],rax
    41e6:	mov    QWORD PTR [rsp+0x10],rdi
    41eb:	mov    QWORD PTR [r12+0x50],0x0
    41f4:	mov    QWORD PTR [r12],rsi
    41f8:	mov    QWORD PTR [rsp+0x18],rsi
    41fd:	mov    QWORD PTR [r12+0x8],rdx
    4202:	mov    QWORD PTR [rsp+0x20],rdx
    4207:	mov    QWORD PTR [r12+0x10],rcx
    420c:	mov    QWORD PTR [rsp+0x28],rcx
    4211:	mov    QWORD PTR [r12+0x18],r8
    4216:	mov    QWORD PTR [r12+0x20],r9
    421b:	mov    QWORD PTR [rsp+0x30],r9
    4220:	mov    QWORD PTR [r12+0x28],r13
    4225:	mov    QWORD PTR [r12+0x30],r14
    422a:	mov    QWORD PTR [r12+0x38],r15
    422f:	mov    rax,QWORD PTR [rsp+0x38]
    4234:	mov    QWORD PTR [r12+0x40],rax
    4239:	mov    rbx,QWORD PTR [rsp+0x30]
    423e:	mov    rsi,r8
    4241:	mov    rax,rsi
    4244:	and    rax,rbx
    4247:	mov    QWORD PTR [rsp+0x40],rsi
    424c:	test   rax,0x1
    4252:	jne    4284 <botlish_fn_45+0xf4>
    4258:	mov    rdx,rbx
    425b:	mov    rsi,QWORD PTR [rsp+0x40]
    4260:	mov    rdi,QWORD PTR [rsp+0x10]
    4265:	call   426a <botlish_fn_45+0xda>
			4266: R_X86_64_PLT32	rt_int_cmp-0x4
    426a:	mov    QWORD PTR [rsp+0x30],rbx
    426f:	mov    ecx,0x2
    4274:	test   rax,rax
    4277:	cmovge rcx,QWORD PTR [rip+0x3a9]        # 4628 <botlish_fn_45+0x498>
    427f:	jmp    42a3 <botlish_fn_45+0x113>
    4284:	mov    QWORD PTR [rsp+0x30],rbx
    4289:	mov    ecx,0x2
    428e:	mov    rsi,QWORD PTR [rsp+0x40]
    4293:	mov    r9,QWORD PTR [rsp+0x30]
    4298:	cmp    rsi,r9
    429b:	cmovge rcx,QWORD PTR [rip+0x385]        # 4628 <botlish_fn_45+0x498>
    42a3:	cmp    rcx,0x6
    42a7:	je     45c4 <botlish_fn_45+0x434>
    42ad:	xor    eax,eax
    42af:	mov    rsi,QWORD PTR [rsp+0x18]
    42b4:	test   rsi,0x7
    42bb:	jne    42ca <botlish_fn_45+0x13a>
    42c1:	movzx  rax,BYTE PTR [rsi]
    42c5:	cmp    al,0x8
    42c7:	sete   al
    42ca:	test   al,al
    42cc:	jne    42f3 <botlish_fn_45+0x163>
    42d2:	mov    rdi,QWORD PTR [rsp+0x10]
    42d7:	mov    rax,QWORD PTR [rdi+0x10]
    42db:	mov    rcx,QWORD PTR [rax+0x20]
    42df:	mov    edx,0x8
    42e4:	call   42e9 <botlish_fn_45+0x159>
			42e5: R_X86_64_PLT32	rt_type_error-0x4
    42e9:	mov    rdi,QWORD PTR [rsp+0x10]
    42ee:	jmp    44e1 <botlish_fn_45+0x351>
    42f3:	mov    QWORD PTR [rsp+0x18],rsi
    42f8:	mov    rdx,QWORD PTR [rsp+0x40]
    42fd:	mov    rdi,QWORD PTR [rsp+0x10]
    4302:	call   4307 <botlish_fn_45+0x177>
			4303: R_X86_64_PLT32	rt_mutarray_get-0x4
    4307:	test   rax,rax
    430a:	jne    431a <botlish_fn_45+0x18a>
    4310:	mov    rdi,QWORD PTR [rsp+0x10]
    4315:	jmp    44e1 <botlish_fn_45+0x351>
    431a:	mov    QWORD PTR [r12+0x48],rax
    431f:	mov    rbx,rax
    4322:	mov    rdi,QWORD PTR [rsp+0x10]
    4327:	call   432c <botlish_fn_45+0x19c>
			4328: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    432c:	test   rax,rax
    432f:	jne    433f <botlish_fn_45+0x1af>
    4335:	mov    rdi,QWORD PTR [rsp+0x10]
    433a:	jmp    44e1 <botlish_fn_45+0x351>
    433f:	mov    rcx,rbx
    4342:	mov    rdx,rcx
    4345:	and    rdx,rax
    4348:	test   rdx,0x1
    434f:	jne    4378 <botlish_fn_45+0x1e8>
    4355:	mov    rdx,rax
    4358:	mov    rsi,rbx
    435b:	mov    rdi,QWORD PTR [rsp+0x10]
    4360:	call   4365 <botlish_fn_45+0x1d5>
			4361: R_X86_64_PLT32	rt_value_eq-0x4
    4365:	test   rax,rax
    4368:	jne    438e <botlish_fn_45+0x1fe>
    436e:	mov    rdi,QWORD PTR [rsp+0x10]
    4373:	jmp    44e1 <botlish_fn_45+0x351>
    4378:	mov    rdx,rax
    437b:	mov    rsi,rbx
    437e:	mov    eax,0x2
    4383:	cmp    rsi,rdx
    4386:	cmove  rax,QWORD PTR [rip+0x29a]        # 4628 <botlish_fn_45+0x498>
    438e:	cmp    rax,0x6
    4392:	je     43a2 <botlish_fn_45+0x212>
    4398:	mov    rbx,QWORD PTR [rsp+0x38]
    439d:	jmp    4511 <botlish_fn_45+0x381>
    43a2:	xor    eax,eax
    43a4:	mov    rdx,QWORD PTR [rsp+0x20]
    43a9:	test   rdx,0x7
    43b0:	je     43c0 <botlish_fn_45+0x230>
    43b6:	mov    QWORD PTR [rsp+0x20],rdx
    43bb:	jmp    43ce <botlish_fn_45+0x23e>
    43c0:	movzx  rax,BYTE PTR [rdx]
    43c4:	mov    QWORD PTR [rsp+0x20],rdx
    43c9:	cmp    al,0x8
    43cb:	sete   al
    43ce:	test   al,al
    43d0:	jne    43fc <botlish_fn_45+0x26c>
    43d6:	mov    rdi,QWORD PTR [rsp+0x10]
    43db:	mov    rsi,QWORD PTR [rdi+0x10]
    43df:	mov    rcx,QWORD PTR [rsi+0x20]
    43e3:	mov    edx,0x8
    43e8:	mov    rsi,QWORD PTR [rsp+0x20]
    43ed:	call   43f2 <botlish_fn_45+0x262>
			43ee: R_X86_64_PLT32	rt_type_error-0x4
    43f2:	mov    rdi,QWORD PTR [rsp+0x10]
    43f7:	jmp    44e1 <botlish_fn_45+0x351>
    43fc:	mov    rdx,QWORD PTR [rsp+0x40]
    4401:	mov    rsi,QWORD PTR [rsp+0x20]
    4406:	mov    rdi,QWORD PTR [rsp+0x10]
    440b:	call   4410 <botlish_fn_45+0x280>
			440c: R_X86_64_PLT32	rt_mutarray_get-0x4
    4410:	test   rax,rax
    4413:	jne    4423 <botlish_fn_45+0x293>
    4419:	mov    rdi,QWORD PTR [rsp+0x10]
    441e:	jmp    44e1 <botlish_fn_45+0x351>
    4423:	mov    QWORD PTR [r12+0x48],rax
    4428:	mov    rbx,rax
    442b:	xor    eax,eax
    442d:	mov    rcx,QWORD PTR [rsp+0x28]
    4432:	test   rcx,0x7
    4439:	je     4449 <botlish_fn_45+0x2b9>
    443f:	mov    QWORD PTR [rsp+0x28],rcx
    4444:	jmp    4457 <botlish_fn_45+0x2c7>
    4449:	movzx  rax,BYTE PTR [rcx]
    444d:	mov    QWORD PTR [rsp+0x28],rcx
    4452:	cmp    al,0x8
    4454:	sete   al
    4457:	test   al,al
    4459:	jne    4485 <botlish_fn_45+0x2f5>
    445f:	mov    rdi,QWORD PTR [rsp+0x10]
    4464:	mov    rax,QWORD PTR [rdi+0x10]
    4468:	mov    rcx,QWORD PTR [rax+0x20]
    446c:	mov    edx,0x8
    4471:	mov    rsi,QWORD PTR [rsp+0x28]
    4476:	call   447b <botlish_fn_45+0x2eb>
			4477: R_X86_64_PLT32	rt_type_error-0x4
    447b:	mov    rdi,QWORD PTR [rsp+0x10]
    4480:	jmp    44e1 <botlish_fn_45+0x351>
    4485:	mov    rdx,QWORD PTR [rsp+0x40]
    448a:	mov    rsi,QWORD PTR [rsp+0x28]
    448f:	mov    rdi,QWORD PTR [rsp+0x10]
    4494:	call   4499 <botlish_fn_45+0x309>
			4495: R_X86_64_PLT32	rt_mutarray_get-0x4
    4499:	test   rax,rax
    449c:	jne    44ac <botlish_fn_45+0x31c>
    44a2:	mov    rdi,QWORD PTR [rsp+0x10]
    44a7:	jmp    44e1 <botlish_fn_45+0x351>
    44ac:	mov    QWORD PTR [r12+0x50],rax
    44b1:	mov    QWORD PTR [rsp],rax
    44b5:	mov    r9,rbx
    44b8:	mov    rbx,QWORD PTR [rsp+0x38]
    44bd:	mov    rcx,r15
    44c0:	mov    rdx,r14
    44c3:	mov    rsi,r13
    44c6:	mov    rdi,QWORD PTR [rsp+0x10]
    44cb:	mov    r8,rbx
    44ce:	call   44d3 <botlish_fn_45+0x343>
			44cf: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    44d3:	test   rax,rax
    44d6:	jne    4511 <botlish_fn_45+0x381>
    44dc:	mov    rdi,QWORD PTR [rsp+0x10]
    44e1:	mov    rdi,QWORD PTR [rsp+0x10]
    44e6:	mov    QWORD PTR [rdi],r12
    44e9:	xor    rax,rax
    44ec:	mov    rbx,QWORD PTR [rsp+0x50]
    44f1:	mov    r12,QWORD PTR [rsp+0x58]
    44f6:	mov    r13,QWORD PTR [rsp+0x60]
    44fb:	mov    r14,QWORD PTR [rsp+0x68]
    4500:	mov    r15,QWORD PTR [rsp+0x70]
    4505:	add    rsp,0x80
    450c:	mov    rsp,rbp
    450f:	pop    rbp
    4510:	ret
    4511:	mov    QWORD PTR [r12+0x48],0x3
    451a:	mov    rsi,QWORD PTR [rsp+0x40]
    451f:	test   rsi,0x1
    4526:	je     4552 <botlish_fn_45+0x3c2>
    452c:	mov    rsi,QWORD PTR [rsp+0x40]
    4531:	mov    rcx,rsi
    4534:	add    rcx,0x2
    4538:	seto   al
    453b:	test   al,al
    453d:	jne    4552 <botlish_fn_45+0x3c2>
    4543:	mov    rsi,QWORD PTR [rsp+0x18]
    4548:	mov    QWORD PTR [rsp+0x40],rcx
    454d:	jmp    4570 <botlish_fn_45+0x3e0>
    4552:	mov    edx,0x3
    4557:	mov    rsi,QWORD PTR [rsp+0x40]
    455c:	mov    rdi,QWORD PTR [rsp+0x10]
    4561:	call   4566 <botlish_fn_45+0x3d6>
			4562: R_X86_64_PLT32	rt_int_add-0x4
    4566:	mov    rsi,QWORD PTR [rsp+0x18]
    456b:	mov    QWORD PTR [rsp+0x40],rax
    4570:	mov    rsi,QWORD PTR [rsp+0x18]
    4575:	mov    QWORD PTR [r12],rsi
    4579:	mov    rsi,QWORD PTR [rsp+0x20]
    457e:	mov    QWORD PTR [r12+0x8],rsi
    4583:	mov    rsi,QWORD PTR [rsp+0x28]
    4588:	mov    QWORD PTR [r12+0x10],rsi
    458d:	mov    rsi,QWORD PTR [rsp+0x40]
    4592:	mov    QWORD PTR [r12+0x18],rsi
    4597:	mov    r9,QWORD PTR [rsp+0x30]
    459c:	mov    QWORD PTR [r12+0x20],r9
    45a1:	mov    QWORD PTR [r12+0x28],r13
    45a6:	mov    QWORD PTR [r12+0x30],r14
    45ab:	mov    QWORD PTR [r12+0x38],r15
    45b0:	mov    QWORD PTR [r12+0x40],rbx
    45b5:	mov    QWORD PTR [rsp+0x38],rbx
    45ba:	mov    rbx,QWORD PTR [rsp+0x30]
    45bf:	jmp    4241 <botlish_fn_45+0xb1>
    45c4:	mov    rdi,QWORD PTR [rsp+0x10]
    45c9:	mov    QWORD PTR [rdi],r12
    45cc:	mov    eax,0xa
    45d1:	mov    rbx,QWORD PTR [rsp+0x50]
    45d6:	mov    r12,QWORD PTR [rsp+0x58]
    45db:	mov    r13,QWORD PTR [rsp+0x60]
    45e0:	mov    r14,QWORD PTR [rsp+0x68]
    45e5:	mov    r15,QWORD PTR [rsp+0x70]
    45ea:	add    rsp,0x80
    45f1:	mov    rsp,rbp
    45f4:	pop    rbp
    45f5:	ret
    45f6:	mov    QWORD PTR [rsp+0x10],rdi
    45fb:	call   4600 <botlish_fn_45+0x470>
			45fc: R_X86_64_PLT32	rt_stack_overflow-0x4
    4600:	xor    rax,rax
    4603:	mov    rbx,QWORD PTR [rsp+0x50]
    4608:	mov    r12,QWORD PTR [rsp+0x58]
    460d:	mov    r13,QWORD PTR [rsp+0x60]
    4612:	mov    r14,QWORD PTR [rsp+0x68]
    4617:	mov    r15,QWORD PTR [rsp+0x70]
    461c:	add    rsp,0x80
    4623:	mov    rsp,rbp
    4626:	pop    rbp
    4627:	ret
    4628:	(bad)
    4629:	add    BYTE PTR [rax],al
    462b:	add    BYTE PTR [rax],al
    462d:	add    BYTE PTR [rax],al
	...

0000000000004630 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4630:	push   rbp
    4631:	mov    rbp,rsp
    4634:	sub    rsp,0x30
    4638:	mov    QWORD PTR [rsp+0x20],r12
    463d:	mov    rsi,QWORD PTR [rdx]
    4640:	mov    rax,QWORD PTR [rdx+0x8]
    4644:	mov    rcx,QWORD PTR [rdx+0x10]
    4648:	mov    r8,QWORD PTR [rdx+0x18]
    464c:	mov    r9,QWORD PTR [rdx+0x20]
    4650:	mov    r10,QWORD PTR [rdx+0x28]
    4654:	mov    r11,QWORD PTR [rdx+0x30]
    4658:	mov    r12,QWORD PTR [rdx+0x38]
    465c:	mov    rdx,QWORD PTR [rdx+0x40]
    4660:	mov    QWORD PTR [rsp],r10
    4664:	mov    QWORD PTR [rsp+0x8],r11
    4669:	mov    QWORD PTR [rsp+0x10],r12
    466e:	mov    QWORD PTR [rsp+0x18],rdx
    4673:	mov    rdx,rax
    4676:	call   467b <botlish_entry_45+0x4b>
			4677: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    467b:	mov    r12,QWORD PTR [rsp+0x20]
    4680:	add    rsp,0x30
    4684:	mov    rsp,rbp
    4687:	pop    rbp
    4688:	ret

0000000000004689 <botlish_fn_46: ht_rehash<mutarray, int>>:
    4689:	push   rbp
    468a:	mov    rbp,rsp
    468d:	sub    rsp,0x80
    4694:	mov    QWORD PTR [rsp+0x50],rbx
    4699:	mov    QWORD PTR [rsp+0x58],r12
    469e:	mov    QWORD PTR [rsp+0x60],r13
    46a3:	mov    QWORD PTR [rsp+0x68],r14
    46a8:	mov    QWORD PTR [rsp+0x70],r15
    46ad:	mov    r12,QWORD PTR [rdi]
    46b0:	mov    rax,QWORD PTR [rdi+0x8]
    46b4:	lea    rcx,[r12+0x50]
    46b9:	cmp    rcx,rax
    46bc:	ja     49ab <botlish_fn_46+0x322>
    46c2:	lea    rax,[r12+0x50]
    46c7:	mov    QWORD PTR [rdi],rax
    46ca:	mov    r13,rdi
    46cd:	mov    QWORD PTR [r12+0x10],0x0
    46d6:	mov    QWORD PTR [r12+0x18],0x0
    46df:	mov    QWORD PTR [r12+0x20],0x0
    46e8:	mov    QWORD PTR [r12+0x28],0x0
    46f1:	mov    QWORD PTR [r12+0x30],0x0
    46fa:	mov    QWORD PTR [r12+0x38],0x0
    4703:	mov    QWORD PTR [r12+0x40],0x0
    470c:	mov    QWORD PTR [r12+0x48],0x0
    4715:	mov    QWORD PTR [r12],rsi
    4719:	mov    r14,rsi
    471c:	mov    QWORD PTR [r12+0x8],rdx
    4721:	mov    rbx,rdx
    4724:	mov    rsi,r14
    4727:	mov    rdi,r13
    472a:	call   472f <botlish_fn_46+0xa6>
			472b: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    472f:	test   rax,rax
    4732:	jne    4740 <botlish_fn_46+0xb7>
    4738:	mov    rdi,r13
    473b:	jmp    494d <botlish_fn_46+0x2c4>
    4740:	mov    QWORD PTR [r12+0x10],rax
    4745:	mov    r15,rax
    4748:	mov    rsi,r14
    474b:	mov    rdi,r13
    474e:	call   4753 <botlish_fn_46+0xca>
			474f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4753:	test   rax,rax
    4756:	jne    4764 <botlish_fn_46+0xdb>
    475c:	mov    rdi,r13
    475f:	jmp    494d <botlish_fn_46+0x2c4>
    4764:	mov    QWORD PTR [r12+0x18],rax
    4769:	mov    QWORD PTR [rsp+0x48],rax
    476e:	mov    rsi,r14
    4771:	mov    rdi,r13
    4774:	call   4779 <botlish_fn_46+0xf0>
			4775: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4779:	test   rax,rax
    477c:	jne    478a <botlish_fn_46+0x101>
    4782:	mov    rdi,r13
    4785:	jmp    494d <botlish_fn_46+0x2c4>
    478a:	mov    QWORD PTR [r12+0x20],rax
    478f:	mov    QWORD PTR [rsp+0x40],rax
    4794:	mov    rsi,r14
    4797:	mov    rdi,r13
    479a:	call   479f <botlish_fn_46+0x116>
			479b: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    479f:	test   rax,rax
    47a2:	jne    47b0 <botlish_fn_46+0x127>
    47a8:	mov    rdi,r13
    47ab:	jmp    494d <botlish_fn_46+0x2c4>
    47b0:	mov    QWORD PTR [r12+0x28],rax
    47b5:	mov    QWORD PTR [rsp+0x38],rax
    47ba:	mov    rsi,rbx
    47bd:	mov    rdi,r13
    47c0:	call   47c5 <botlish_fn_46+0x13c>
			47c1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    47c5:	mov    rcx,rax
    47c8:	mov    QWORD PTR [rsp+0x30],rax
    47cd:	test   rax,rcx
    47d0:	jne    47de <botlish_fn_46+0x155>
    47d6:	mov    rdi,r13
    47d9:	jmp    494d <botlish_fn_46+0x2c4>
    47de:	mov    rax,QWORD PTR [rsp+0x30]
    47e3:	mov    QWORD PTR [r12+0x30],rax
    47e8:	mov    edx,0x1
    47ed:	mov    QWORD PTR [r12+0x38],0x1
    47f6:	mov    rcx,rbx
    47f9:	mov    rsi,QWORD PTR [rsp+0x30]
    47fe:	mov    rdi,r13
    4801:	call   4806 <botlish_fn_46+0x17d>
			4802: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    4806:	test   rax,rax
    4809:	jne    4817 <botlish_fn_46+0x18e>
    480f:	mov    rdi,r13
    4812:	jmp    494d <botlish_fn_46+0x2c4>
    4817:	mov    rsi,rbx
    481a:	mov    rdi,r13
    481d:	call   4822 <botlish_fn_46+0x199>
			481e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4822:	test   rax,rax
    4825:	jne    4833 <botlish_fn_46+0x1aa>
    482b:	mov    rdi,r13
    482e:	jmp    494d <botlish_fn_46+0x2c4>
    4833:	mov    QWORD PTR [r12+0x38],rax
    4838:	mov    QWORD PTR [rsp+0x28],rax
    483d:	mov    rsi,rbx
    4840:	mov    rdi,r13
    4843:	call   4848 <botlish_fn_46+0x1bf>
			4844: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4848:	test   rax,rax
    484b:	jne    4859 <botlish_fn_46+0x1d0>
    4851:	mov    rdi,r13
    4854:	jmp    494d <botlish_fn_46+0x2c4>
    4859:	mov    QWORD PTR [r12+0x40],rax
    485e:	mov    r8d,0x1
    4864:	mov    QWORD PTR [r12+0x48],0x1
    486d:	mov    rcx,QWORD PTR [rsp+0x30]
    4872:	mov    QWORD PTR [rsp],rcx
    4876:	mov    rcx,QWORD PTR [rsp+0x28]
    487b:	mov    QWORD PTR [rsp+0x8],rcx
    4880:	mov    QWORD PTR [rsp+0x10],rax
    4885:	mov    QWORD PTR [rsp+0x20],rax
    488a:	mov    QWORD PTR [rsp+0x18],rbx
    488f:	mov    rcx,QWORD PTR [rsp+0x40]
    4894:	mov    rdx,QWORD PTR [rsp+0x48]
    4899:	mov    rsi,r15
    489c:	mov    r9,QWORD PTR [rsp+0x38]
    48a1:	mov    rdi,r13
    48a4:	call   48a9 <botlish_fn_46+0x220>
			48a5: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    48a9:	test   rax,rax
    48ac:	jne    48ba <botlish_fn_46+0x231>
    48b2:	mov    rdi,r13
    48b5:	jmp    494d <botlish_fn_46+0x2c4>
    48ba:	mov    edx,0x1
    48bf:	mov    rcx,QWORD PTR [rsp+0x30]
    48c4:	mov    rsi,r14
    48c7:	mov    rdi,r13
    48ca:	call   48cf <botlish_fn_46+0x246>
			48cb: R_X86_64_PLT32	rt_mutarray_set-0x4
    48cf:	test   rax,rax
    48d2:	jne    48e0 <botlish_fn_46+0x257>
    48d8:	mov    rdi,r13
    48db:	jmp    494d <botlish_fn_46+0x2c4>
    48e0:	mov    edx,0x3
    48e5:	mov    rcx,QWORD PTR [rsp+0x28]
    48ea:	mov    rsi,r14
    48ed:	mov    rdi,r13
    48f0:	call   48f5 <botlish_fn_46+0x26c>
			48f1: R_X86_64_PLT32	rt_mutarray_set-0x4
    48f5:	test   rax,rax
    48f8:	jne    4906 <botlish_fn_46+0x27d>
    48fe:	mov    rdi,r13
    4901:	jmp    494d <botlish_fn_46+0x2c4>
    4906:	mov    edx,0x5
    490b:	mov    rcx,QWORD PTR [rsp+0x20]
    4910:	mov    rsi,r14
    4913:	mov    rdi,r13
    4916:	call   491b <botlish_fn_46+0x292>
			4917: R_X86_64_PLT32	rt_mutarray_set-0x4
    491b:	test   rax,rax
    491e:	jne    492c <botlish_fn_46+0x2a3>
    4924:	mov    rdi,r13
    4927:	jmp    494d <botlish_fn_46+0x2c4>
    492c:	mov    edx,0x9
    4931:	mov    ecx,0x1
    4936:	mov    rsi,r14
    4939:	mov    rdi,r13
    493c:	call   4941 <botlish_fn_46+0x2b8>
			493d: R_X86_64_PLT32	rt_mutarray_set-0x4
    4941:	test   rax,rax
    4944:	jne    497b <botlish_fn_46+0x2f2>
    494a:	mov    rdi,r13
    494d:	mov    rdi,r13
    4950:	mov    QWORD PTR [rdi],r12
    4953:	xor    rax,rax
    4956:	mov    rbx,QWORD PTR [rsp+0x50]
    495b:	mov    r12,QWORD PTR [rsp+0x58]
    4960:	mov    r13,QWORD PTR [rsp+0x60]
    4965:	mov    r14,QWORD PTR [rsp+0x68]
    496a:	mov    r15,QWORD PTR [rsp+0x70]
    496f:	add    rsp,0x80
    4976:	mov    rsp,rbp
    4979:	pop    rbp
    497a:	ret
    497b:	mov    rdi,r13
    497e:	mov    QWORD PTR [rdi],r12
    4981:	mov    eax,0xa
    4986:	mov    rbx,QWORD PTR [rsp+0x50]
    498b:	mov    r12,QWORD PTR [rsp+0x58]
    4990:	mov    r13,QWORD PTR [rsp+0x60]
    4995:	mov    r14,QWORD PTR [rsp+0x68]
    499a:	mov    r15,QWORD PTR [rsp+0x70]
    499f:	add    rsp,0x80
    49a6:	mov    rsp,rbp
    49a9:	pop    rbp
    49aa:	ret
    49ab:	mov    r13,rdi
    49ae:	call   49b3 <botlish_fn_46+0x32a>
			49af: R_X86_64_PLT32	rt_stack_overflow-0x4
    49b3:	xor    rax,rax
    49b6:	mov    rbx,QWORD PTR [rsp+0x50]
    49bb:	mov    r12,QWORD PTR [rsp+0x58]
    49c0:	mov    r13,QWORD PTR [rsp+0x60]
    49c5:	mov    r14,QWORD PTR [rsp+0x68]
    49ca:	mov    r15,QWORD PTR [rsp+0x70]
    49cf:	add    rsp,0x80
    49d6:	mov    rsp,rbp
    49d9:	pop    rbp
    49da:	ret

00000000000049db <botlish_entry_46: ht_rehash<mutarray, int>>:
    49db:	push   rbp
    49dc:	mov    rbp,rsp
    49df:	mov    rsi,QWORD PTR [rdx]
    49e2:	mov    rdx,QWORD PTR [rdx+0x8]
    49e6:	call   49eb <botlish_entry_46+0x10>
			49e7: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    49eb:	mov    rsp,rbp
    49ee:	pop    rbp
    49ef:	ret

00000000000049f0 <botlish_fn_47: ht_should_grow<mutarray>>:
    49f0:	push   rbp
    49f1:	mov    rbp,rsp
    49f4:	sub    rsp,0x20
    49f8:	mov    QWORD PTR [rsp],rbx
    49fc:	mov    QWORD PTR [rsp+0x8],r12
    4a01:	mov    QWORD PTR [rsp+0x10],r13
    4a06:	mov    QWORD PTR [rsp+0x18],r14
    4a0b:	mov    r12,QWORD PTR [rdi]
    4a0e:	mov    r8,QWORD PTR [rdi+0x8]
    4a12:	lea    r9,[r12+0x18]
    4a17:	cmp    r9,r8
    4a1a:	ja     4d4b <botlish_fn_47+0x35b>
    4a20:	lea    r9,[r12+0x18]
    4a25:	mov    QWORD PTR [rdi],r9
    4a28:	mov    r13,rdi
    4a2b:	mov    QWORD PTR [r12+0x8],0x0
    4a34:	mov    QWORD PTR [r12+0x10],0x0
    4a3d:	mov    QWORD PTR [r12],rsi
    4a41:	mov    rbx,rsi
    4a44:	mov    rsi,rbx
    4a47:	mov    rdi,r13
    4a4a:	call   4a4f <botlish_fn_47+0x5f>
			4a4b: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    4a4f:	mov    rcx,rax
    4a52:	mov    r14,rax
    4a55:	test   rax,rcx
    4a58:	jne    4a66 <botlish_fn_47+0x76>
    4a5e:	mov    rdi,r13
    4a61:	jmp    4c63 <botlish_fn_47+0x273>
    4a66:	mov    rax,r14
    4a69:	mov    QWORD PTR [r12+0x8],rax
    4a6e:	mov    rsi,rbx
    4a71:	mov    rdi,r13
    4a74:	call   4a79 <botlish_fn_47+0x89>
			4a75: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4a79:	mov    rcx,rax
    4a7c:	test   rcx,rcx
    4a7f:	jne    4a8d <botlish_fn_47+0x9d>
    4a85:	mov    rdi,r13
    4a88:	jmp    4c63 <botlish_fn_47+0x273>
    4a8d:	mov    QWORD PTR [r12+0x10],rcx
    4a92:	mov    edx,0x1
    4a97:	mov    rax,r14
    4a9a:	test   rax,0x1
    4aa0:	jne    4ac3 <botlish_fn_47+0xd3>
    4aa6:	xor    edx,edx
    4aa8:	mov    rax,r14
    4aab:	test   rax,0x7
    4ab1:	jne    4ac3 <botlish_fn_47+0xd3>
    4ab7:	mov    rax,r14
    4aba:	movzx  rax,BYTE PTR [rax]
    4abe:	cmp    al,0x1
    4ac0:	sete   dl
    4ac3:	test   dl,dl
    4ac5:	jne    4ae9 <botlish_fn_47+0xf9>
    4acb:	mov    rdi,r13
    4ace:	mov    rax,QWORD PTR [rdi+0x10]
    4ad2:	mov    rcx,QWORD PTR [rax+0x30]
    4ad6:	xor    rdx,rdx
    4ad9:	mov    rsi,r14
    4adc:	call   4ae1 <botlish_fn_47+0xf1>
			4add: R_X86_64_PLT32	rt_type_error-0x4
    4ae1:	mov    rdi,r13
    4ae4:	jmp    4c63 <botlish_fn_47+0x273>
    4ae9:	mov    eax,0x1
    4aee:	test   rcx,0x1
    4af5:	je     4b03 <botlish_fn_47+0x113>
    4afb:	mov    r8,rcx
    4afe:	jmp    4b26 <botlish_fn_47+0x136>
    4b03:	xor    eax,eax
    4b05:	test   rcx,0x7
    4b0c:	je     4b1a <botlish_fn_47+0x12a>
    4b12:	mov    r8,rcx
    4b15:	jmp    4b26 <botlish_fn_47+0x136>
    4b1a:	movzx  rax,BYTE PTR [rcx]
    4b1e:	mov    r8,rcx
    4b21:	cmp    al,0x1
    4b23:	sete   al
    4b26:	test   al,al
    4b28:	jne    4b4c <botlish_fn_47+0x15c>
    4b2e:	mov    rdi,r13
    4b31:	mov    rax,QWORD PTR [rdi+0x10]
    4b35:	mov    rcx,QWORD PTR [rax+0x30]
    4b39:	xor    rdx,rdx
    4b3c:	mov    rsi,r8
    4b3f:	call   4b44 <botlish_fn_47+0x154>
			4b40: R_X86_64_PLT32	rt_type_error-0x4
    4b44:	mov    rdi,r13
    4b47:	jmp    4c63 <botlish_fn_47+0x273>
    4b4c:	mov    rcx,r8
    4b4f:	mov    rsi,r14
    4b52:	mov    rax,rsi
    4b55:	and    rax,rcx
    4b58:	test   rax,0x1
    4b5e:	jne    4b6f <botlish_fn_47+0x17f>
    4b64:	mov    rdx,r8
    4b67:	mov    rsi,r14
    4b6a:	jmp    4b8d <botlish_fn_47+0x19d>
    4b6f:	mov    rcx,r8
    4b72:	lea    rax,[rcx-0x1]
    4b76:	mov    rsi,r14
    4b79:	add    rsi,rax
    4b7c:	seto   al
    4b7f:	test   al,al
    4b81:	je     4b98 <botlish_fn_47+0x1a8>
    4b87:	mov    rdx,r8
    4b8a:	mov    rsi,r14
    4b8d:	mov    rdi,r13
    4b90:	call   4b95 <botlish_fn_47+0x1a5>
			4b91: R_X86_64_PLT32	rt_int_add-0x4
    4b95:	mov    rsi,rax
    4b98:	mov    QWORD PTR [r12+0x8],rsi
    4b9d:	mov    QWORD PTR [r12+0x10],0x3
    4ba6:	test   rsi,0x1
    4bad:	je     4bd0 <botlish_fn_47+0x1e0>
    4bb3:	mov    rax,rsi
    4bb6:	add    rax,0x2
    4bba:	mov    rcx,rax
    4bbd:	seto   al
    4bc0:	test   al,al
    4bc2:	jne    4bd0 <botlish_fn_47+0x1e0>
    4bc8:	mov    rsi,rcx
    4bcb:	jmp    4be0 <botlish_fn_47+0x1f0>
    4bd0:	mov    edx,0x3
    4bd5:	mov    rdi,r13
    4bd8:	call   4bdd <botlish_fn_47+0x1ed>
			4bd9: R_X86_64_PLT32	rt_int_add-0x4
    4bdd:	mov    rsi,rax
    4be0:	mov    QWORD PTR [r12+0x8],rsi
    4be5:	mov    edx,0x7
    4bea:	mov    rcx,rdx
    4bed:	mov    QWORD PTR [r12+0x10],0x7
    4bf6:	test   rsi,0x1
    4bfd:	jne    4c0b <botlish_fn_47+0x21b>
    4c03:	mov    rdx,rcx
    4c06:	jmp    4c39 <botlish_fn_47+0x249>
    4c0b:	mov    rax,rsi
    4c0e:	sar    rax,1
    4c11:	imul   QWORD PTR [rip+0x160]        # 4d78 <botlish_fn_47+0x388>
    4c18:	seto   dil
    4c1c:	or     rax,0x1
    4c20:	test   dil,dil
    4c23:	je     4c31 <botlish_fn_47+0x241>
    4c29:	mov    rdx,rcx
    4c2c:	jmp    4c39 <botlish_fn_47+0x249>
    4c31:	mov    rsi,rax
    4c34:	jmp    4c44 <botlish_fn_47+0x254>
    4c39:	mov    rdi,r13
    4c3c:	call   4c41 <botlish_fn_47+0x251>
			4c3d: R_X86_64_PLT32	rt_int_mul-0x4
    4c41:	mov    rsi,rax
    4c44:	mov    QWORD PTR [r12+0x8],rsi
    4c49:	mov    r14,rsi
    4c4c:	mov    rsi,rbx
    4c4f:	mov    rdi,r13
    4c52:	call   4c57 <botlish_fn_47+0x267>
			4c53: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4c57:	test   rax,rax
    4c5a:	jne    4c88 <botlish_fn_47+0x298>
    4c60:	mov    rdi,r13
    4c63:	mov    rdi,r13
    4c66:	mov    QWORD PTR [rdi],r12
    4c69:	xor    rax,rax
    4c6c:	mov    rbx,QWORD PTR [rsp]
    4c70:	mov    r12,QWORD PTR [rsp+0x8]
    4c75:	mov    r13,QWORD PTR [rsp+0x10]
    4c7a:	mov    r14,QWORD PTR [rsp+0x18]
    4c7f:	add    rsp,0x20
    4c83:	mov    rsp,rbp
    4c86:	pop    rbp
    4c87:	ret
    4c88:	mov    QWORD PTR [r12],rax
    4c8c:	mov    QWORD PTR [r12+0x10],0x5
    4c95:	test   rax,0x1
    4c9b:	mov    rsi,rax
    4c9e:	je     4cce <botlish_fn_47+0x2de>
    4ca4:	mov    rcx,rsi
    4ca7:	mov    rax,rcx
    4caa:	sar    rax,1
    4cad:	imul   QWORD PTR [rip+0xcc]        # 4d80 <botlish_fn_47+0x390>
    4cb4:	seto   cl
    4cb7:	or     rax,0x1
    4cbb:	test   cl,cl
    4cbd:	jne    4cce <botlish_fn_47+0x2de>
    4cc3:	mov    rdx,rax
    4cc6:	mov    rsi,r14
    4cc9:	jmp    4ce1 <botlish_fn_47+0x2f1>
    4cce:	mov    edx,0x5
    4cd3:	mov    rdi,r13
    4cd6:	call   4cdb <botlish_fn_47+0x2eb>
			4cd7: R_X86_64_PLT32	rt_int_mul-0x4
    4cdb:	mov    rdx,rax
    4cde:	mov    rsi,r14
    4ce1:	mov    rax,rsi
    4ce4:	and    rax,rdx
    4ce7:	test   rax,0x1
    4ced:	jne    4d16 <botlish_fn_47+0x326>
    4cf3:	mov    rdi,r13
    4cf6:	call   4cfb <botlish_fn_47+0x30b>
			4cf7: R_X86_64_PLT32	rt_int_cmp-0x4
    4cfb:	mov    ecx,0x2
    4d00:	test   rax,rax
    4d03:	mov    rax,rcx
    4d06:	cmovg  rax,QWORD PTR [rip+0x6a]        # 4d78 <botlish_fn_47+0x388>
    4d0e:	mov    rdi,r13
    4d11:	jmp    4d29 <botlish_fn_47+0x339>
    4d16:	mov    eax,0x2
    4d1b:	cmp    rsi,rdx
    4d1e:	cmovg  rax,QWORD PTR [rip+0x52]        # 4d78 <botlish_fn_47+0x388>
    4d26:	mov    rdi,r13
    4d29:	mov    rdi,r13
    4d2c:	mov    QWORD PTR [rdi],r12
    4d2f:	mov    rbx,QWORD PTR [rsp]
    4d33:	mov    r12,QWORD PTR [rsp+0x8]
    4d38:	mov    r13,QWORD PTR [rsp+0x10]
    4d3d:	mov    r14,QWORD PTR [rsp+0x18]
    4d42:	add    rsp,0x20
    4d46:	mov    rsp,rbp
    4d49:	pop    rbp
    4d4a:	ret
    4d4b:	mov    r13,rdi
    4d4e:	call   4d53 <botlish_fn_47+0x363>
			4d4f: R_X86_64_PLT32	rt_stack_overflow-0x4
    4d53:	xor    rax,rax
    4d56:	mov    rbx,QWORD PTR [rsp]
    4d5a:	mov    r12,QWORD PTR [rsp+0x8]
    4d5f:	mov    r13,QWORD PTR [rsp+0x10]
    4d64:	mov    r14,QWORD PTR [rsp+0x18]
    4d69:	add    rsp,0x20
    4d6d:	mov    rsp,rbp
    4d70:	pop    rbp
    4d71:	ret
    4d72:	add    BYTE PTR [rax],al
    4d74:	add    BYTE PTR [rax],al
    4d76:	add    BYTE PTR [rax],al
    4d78:	(bad)
    4d79:	add    BYTE PTR [rax],al
    4d7b:	add    BYTE PTR [rax],al
    4d7d:	add    BYTE PTR [rax],al
    4d7f:	add    BYTE PTR [rax+rax*1],al
    4d82:	add    BYTE PTR [rax],al
    4d84:	add    BYTE PTR [rax],al
	...

0000000000004d88 <botlish_entry_47: ht_should_grow<mutarray>>:
    4d88:	push   rbp
    4d89:	mov    rbp,rsp
    4d8c:	mov    rsi,QWORD PTR [rdx]
    4d8f:	call   4d94 <botlish_entry_47+0xc>
			4d90: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    4d94:	mov    rsp,rbp
    4d97:	pop    rbp
    4d98:	ret
    4d99:	add    BYTE PTR [rax],al
    4d9b:	add    BYTE PTR [rax],al
    4d9d:	add    BYTE PTR [rax],al
	...

0000000000004da0 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    4da0:	push   rbp
    4da1:	mov    rbp,rsp
    4da4:	sub    rsp,0x20
    4da8:	mov    QWORD PTR [rsp],rbx
    4dac:	mov    QWORD PTR [rsp+0x8],r12
    4db1:	mov    QWORD PTR [rsp+0x10],r13
    4db6:	mov    QWORD PTR [rsp+0x18],r14
    4dbb:	mov    rbx,QWORD PTR [rdi]
    4dbe:	mov    rax,QWORD PTR [rdi+0x8]
    4dc2:	lea    rcx,[rbx+0x18]
    4dc6:	cmp    rcx,rax
    4dc9:	ja     506b <botlish_fn_48+0x2cb>
    4dcf:	lea    rax,[rbx+0x18]
    4dd3:	mov    QWORD PTR [rdi],rax
    4dd6:	mov    r12,rdi
    4dd9:	mov    QWORD PTR [rbx+0x8],0x0
    4de1:	mov    QWORD PTR [rbx+0x10],0x0
    4de9:	mov    QWORD PTR [rbx],rsi
    4dec:	mov    r13,rsi
    4def:	mov    rsi,r13
    4df2:	mov    rdi,r12
    4df5:	call   4dfa <botlish_fn_48+0x5a>
			4df6: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4dfa:	test   rax,rax
    4dfd:	jne    4e0b <botlish_fn_48+0x6b>
    4e03:	mov    rdi,r12
    4e06:	jmp    5021 <botlish_fn_48+0x281>
    4e0b:	mov    QWORD PTR [rbx+0x8],rax
    4e0f:	mov    r14,rax
    4e12:	mov    rsi,r13
    4e15:	mov    rdi,r12
    4e18:	call   4e1d <botlish_fn_48+0x7d>
			4e19: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    4e1d:	mov    rcx,rax
    4e20:	test   rcx,rcx
    4e23:	jne    4e31 <botlish_fn_48+0x91>
    4e29:	mov    rdi,r12
    4e2c:	jmp    5021 <botlish_fn_48+0x281>
    4e31:	mov    edx,0x1
    4e36:	mov    rax,r14
    4e39:	test   rax,0x1
    4e3f:	je     4e4d <botlish_fn_48+0xad>
    4e45:	mov    r14,rax
    4e48:	jmp    4e71 <botlish_fn_48+0xd1>
    4e4d:	xor    edx,edx
    4e4f:	test   rax,0x7
    4e55:	je     4e63 <botlish_fn_48+0xc3>
    4e5b:	mov    r14,rax
    4e5e:	jmp    4e71 <botlish_fn_48+0xd1>
    4e63:	movzx  rdx,BYTE PTR [rax]
    4e67:	mov    r14,rax
    4e6a:	rex cmp dl,0x1
    4e6e:	sete   dl
    4e71:	test   dl,dl
    4e73:	jne    4e97 <botlish_fn_48+0xf7>
    4e79:	mov    rdi,r12
    4e7c:	mov    rax,QWORD PTR [rdi+0x10]
    4e80:	mov    rcx,QWORD PTR [rax+0x38]
    4e84:	xor    rdx,rdx
    4e87:	mov    rsi,r14
    4e8a:	call   4e8f <botlish_fn_48+0xef>
			4e8b: R_X86_64_PLT32	rt_type_error-0x4
    4e8f:	mov    rdi,r12
    4e92:	jmp    5021 <botlish_fn_48+0x281>
    4e97:	mov    rsi,r14
    4e9a:	mov    eax,0x1
    4e9f:	test   rcx,0x1
    4ea6:	je     4eb4 <botlish_fn_48+0x114>
    4eac:	mov    r9,rcx
    4eaf:	jmp    4ed7 <botlish_fn_48+0x137>
    4eb4:	xor    eax,eax
    4eb6:	test   rcx,0x7
    4ebd:	je     4ecb <botlish_fn_48+0x12b>
    4ec3:	mov    r9,rcx
    4ec6:	jmp    4ed7 <botlish_fn_48+0x137>
    4ecb:	movzx  rax,BYTE PTR [rcx]
    4ecf:	mov    r9,rcx
    4ed2:	cmp    al,0x1
    4ed4:	sete   al
    4ed7:	test   al,al
    4ed9:	jne    4efd <botlish_fn_48+0x15d>
    4edf:	mov    rdi,r12
    4ee2:	mov    rax,QWORD PTR [rdi+0x10]
    4ee6:	mov    rcx,QWORD PTR [rax+0x38]
    4eea:	xor    rdx,rdx
    4eed:	mov    rsi,r9
    4ef0:	call   4ef5 <botlish_fn_48+0x155>
			4ef1: R_X86_64_PLT32	rt_type_error-0x4
    4ef5:	mov    rdi,r12
    4ef8:	jmp    5021 <botlish_fn_48+0x281>
    4efd:	mov    rcx,r9
    4f00:	mov    rax,rsi
    4f03:	and    rax,rcx
    4f06:	test   rax,0x1
    4f0c:	jne    4f33 <botlish_fn_48+0x193>
    4f12:	mov    rdx,r9
    4f15:	mov    rdi,r12
    4f18:	call   4f1d <botlish_fn_48+0x17d>
			4f19: R_X86_64_PLT32	rt_int_cmp-0x4
    4f1d:	mov    r8d,0x2
    4f23:	test   rax,rax
    4f26:	cmovg  r8,QWORD PTR [rip+0x16a]        # 5098 <botlish_fn_48+0x2f8>
    4f2e:	jmp    4f47 <botlish_fn_48+0x1a7>
    4f33:	mov    r8d,0x2
    4f39:	mov    rcx,r9
    4f3c:	cmp    rsi,rcx
    4f3f:	cmovg  r8,QWORD PTR [rip+0x151]        # 5098 <botlish_fn_48+0x2f8>
    4f47:	cmp    r8,0x6
    4f4b:	je     4fe7 <botlish_fn_48+0x247>
    4f51:	mov    rsi,r13
    4f54:	mov    rdi,r12
    4f57:	call   4f5c <botlish_fn_48+0x1bc>
			4f58: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4f5c:	test   rax,rax
    4f5f:	jne    4f6d <botlish_fn_48+0x1cd>
    4f65:	mov    rdi,r12
    4f68:	jmp    5021 <botlish_fn_48+0x281>
    4f6d:	mov    QWORD PTR [rbx+0x8],rax
    4f71:	mov    QWORD PTR [rbx+0x10],0x5
    4f79:	test   rax,0x1
    4f7f:	mov    rsi,rax
    4f82:	je     4faf <botlish_fn_48+0x20f>
    4f88:	mov    rcx,rsi
    4f8b:	mov    rax,rcx
    4f8e:	sar    rax,1
    4f91:	imul   QWORD PTR [rip+0x108]        # 50a0 <botlish_fn_48+0x300>
    4f98:	seto   cl
    4f9b:	or     rax,0x1
    4f9f:	test   cl,cl
    4fa1:	jne    4faf <botlish_fn_48+0x20f>
    4fa7:	mov    rdx,rax
    4faa:	jmp    4fbf <botlish_fn_48+0x21f>
    4faf:	mov    edx,0x5
    4fb4:	mov    rdi,r12
    4fb7:	call   4fbc <botlish_fn_48+0x21c>
			4fb8: R_X86_64_PLT32	rt_int_mul-0x4
    4fbc:	mov    rdx,rax
    4fbf:	mov    QWORD PTR [rbx+0x8],rdx
    4fc3:	mov    rsi,r13
    4fc6:	mov    rdi,r12
    4fc9:	call   4fce <botlish_fn_48+0x22e>
			4fca: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    4fce:	test   rax,rax
    4fd1:	jne    4fdf <botlish_fn_48+0x23f>
    4fd7:	mov    rdi,r12
    4fda:	jmp    5021 <botlish_fn_48+0x281>
    4fdf:	mov    rdi,r12
    4fe2:	jmp    5049 <botlish_fn_48+0x2a9>
    4fe7:	mov    rsi,r13
    4fea:	mov    rdi,r12
    4fed:	call   4ff2 <botlish_fn_48+0x252>
			4fee: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4ff2:	test   rax,rax
    4ff5:	jne    5003 <botlish_fn_48+0x263>
    4ffb:	mov    rdi,r12
    4ffe:	jmp    5021 <botlish_fn_48+0x281>
    5003:	mov    QWORD PTR [rbx+0x8],rax
    5007:	mov    rdx,rax
    500a:	mov    rsi,r13
    500d:	mov    rdi,r12
    5010:	call   5015 <botlish_fn_48+0x275>
			5011: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    5015:	test   rax,rax
    5018:	jne    5046 <botlish_fn_48+0x2a6>
    501e:	mov    rdi,r12
    5021:	mov    rdi,r12
    5024:	mov    QWORD PTR [rdi],rbx
    5027:	xor    rax,rax
    502a:	mov    rbx,QWORD PTR [rsp]
    502e:	mov    r12,QWORD PTR [rsp+0x8]
    5033:	mov    r13,QWORD PTR [rsp+0x10]
    5038:	mov    r14,QWORD PTR [rsp+0x18]
    503d:	add    rsp,0x20
    5041:	mov    rsp,rbp
    5044:	pop    rbp
    5045:	ret
    5046:	mov    rdi,r12
    5049:	mov    rdi,r12
    504c:	mov    QWORD PTR [rdi],rbx
    504f:	mov    rbx,QWORD PTR [rsp]
    5053:	mov    r12,QWORD PTR [rsp+0x8]
    5058:	mov    r13,QWORD PTR [rsp+0x10]
    505d:	mov    r14,QWORD PTR [rsp+0x18]
    5062:	add    rsp,0x20
    5066:	mov    rsp,rbp
    5069:	pop    rbp
    506a:	ret
    506b:	mov    r12,rdi
    506e:	call   5073 <botlish_fn_48+0x2d3>
			506f: R_X86_64_PLT32	rt_stack_overflow-0x4
    5073:	xor    rax,rax
    5076:	mov    rbx,QWORD PTR [rsp]
    507a:	mov    r12,QWORD PTR [rsp+0x8]
    507f:	mov    r13,QWORD PTR [rsp+0x10]
    5084:	mov    r14,QWORD PTR [rsp+0x18]
    5089:	add    rsp,0x20
    508d:	mov    rsp,rbp
    5090:	pop    rbp
    5091:	ret
    5092:	add    BYTE PTR [rax],al
    5094:	add    BYTE PTR [rax],al
    5096:	add    BYTE PTR [rax],al
    5098:	(bad)
    5099:	add    BYTE PTR [rax],al
    509b:	add    BYTE PTR [rax],al
    509d:	add    BYTE PTR [rax],al
    509f:	add    BYTE PTR [rax+rax*1],al
    50a2:	add    BYTE PTR [rax],al
    50a4:	add    BYTE PTR [rax],al
	...

00000000000050a8 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    50a8:	push   rbp
    50a9:	mov    rbp,rsp
    50ac:	mov    rsi,QWORD PTR [rdx]
    50af:	call   50b4 <botlish_entry_48+0xc>
			50b0: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    50b4:	mov    rsp,rbp
    50b7:	pop    rbp
    50b8:	ret
    50b9:	add    BYTE PTR [rax],al
    50bb:	add    BYTE PTR [rax],al
    50bd:	add    BYTE PTR [rax],al
	...

00000000000050c0 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    50c0:	push   rbp
    50c1:	mov    rbp,rsp
    50c4:	sub    rsp,0x50
    50c8:	mov    QWORD PTR [rsp+0x20],rbx
    50cd:	mov    QWORD PTR [rsp+0x28],r12
    50d2:	mov    QWORD PTR [rsp+0x30],r13
    50d7:	mov    QWORD PTR [rsp+0x38],r14
    50dc:	mov    QWORD PTR [rsp+0x40],r15
    50e1:	mov    r12,QWORD PTR [rdi]
    50e4:	mov    rax,QWORD PTR [rdi+0x8]
    50e8:	lea    r9,[r12+0x30]
    50ed:	cmp    r9,rax
    50f0:	ja     55b2 <botlish_fn_49+0x4f2>
    50f6:	lea    rax,[r12+0x30]
    50fb:	mov    QWORD PTR [rdi],rax
    50fe:	mov    r13,rdi
    5101:	mov    QWORD PTR [r12+0x20],0x0
    510a:	mov    QWORD PTR [r12+0x28],0x0
    5113:	mov    QWORD PTR [r12],rsi
    5117:	mov    r14,rsi
    511a:	mov    QWORD PTR [r12+0x8],rdx
    511f:	mov    QWORD PTR [rsp],rdx
    5123:	mov    QWORD PTR [r12+0x10],rcx
    5128:	mov    QWORD PTR [rsp+0x8],rcx
    512d:	mov    QWORD PTR [r12+0x18],r8
    5132:	mov    r15,r8
    5135:	mov    rsi,r14
    5138:	mov    rdi,r13
    513b:	call   5140 <botlish_fn_49+0x80>
			513c: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    5140:	test   rax,rax
    5143:	jne    5151 <botlish_fn_49+0x91>
    5149:	mov    rdi,r13
    514c:	jmp    5557 <botlish_fn_49+0x497>
    5151:	mov    QWORD PTR [r12+0x20],rax
    5156:	xor    ecx,ecx
    5158:	test   rax,0x7
    515e:	je     516e <botlish_fn_49+0xae>
    5164:	mov    QWORD PTR [rsp+0x10],rax
    5169:	jmp    517e <botlish_fn_49+0xbe>
    516e:	movzx  rcx,BYTE PTR [rax]
    5172:	mov    QWORD PTR [rsp+0x10],rax
    5177:	rex cmp cl,0x8
    517b:	sete   cl
    517e:	test   cl,cl
    5180:	jne    51a8 <botlish_fn_49+0xe8>
    5186:	mov    rdi,r13
    5189:	mov    rax,QWORD PTR [rdi+0x10]
    518d:	mov    rcx,QWORD PTR [rax+0x20]
    5191:	mov    edx,0x8
    5196:	mov    rsi,QWORD PTR [rsp+0x10]
    519b:	call   51a0 <botlish_fn_49+0xe0>
			519c: R_X86_64_PLT32	rt_type_error-0x4
    51a0:	mov    rdi,r13
    51a3:	jmp    5557 <botlish_fn_49+0x497>
    51a8:	mov    rdx,QWORD PTR [rsp]
    51ac:	mov    rsi,QWORD PTR [rsp+0x10]
    51b1:	mov    rdi,r13
    51b4:	call   51b9 <botlish_fn_49+0xf9>
			51b5: R_X86_64_PLT32	rt_mutarray_get-0x4
    51b9:	mov    rbx,rax
    51bc:	test   rbx,rbx
    51bf:	jne    51cd <botlish_fn_49+0x10d>
    51c5:	mov    rdi,r13
    51c8:	jmp    5557 <botlish_fn_49+0x497>
    51cd:	mov    QWORD PTR [r12+0x28],rbx
    51d2:	mov    rdi,r13
    51d5:	call   51da <botlish_fn_49+0x11a>
			51d6: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    51da:	test   rax,rax
    51dd:	mov    rcx,rax
    51e0:	jne    51ee <botlish_fn_49+0x12e>
    51e6:	mov    rdi,r13
    51e9:	jmp    5557 <botlish_fn_49+0x497>
    51ee:	mov    rsi,QWORD PTR [rsp+0x10]
    51f3:	mov    rdx,QWORD PTR [rsp]
    51f7:	mov    rdi,r13
    51fa:	call   51ff <botlish_fn_49+0x13f>
			51fb: R_X86_64_PLT32	rt_mutarray_set-0x4
    51ff:	test   rax,rax
    5202:	jne    5210 <botlish_fn_49+0x150>
    5208:	mov    rdi,r13
    520b:	jmp    5557 <botlish_fn_49+0x497>
    5210:	mov    rsi,r14
    5213:	mov    rdi,r13
    5216:	call   521b <botlish_fn_49+0x15b>
			5217: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    521b:	test   rax,rax
    521e:	jne    522c <botlish_fn_49+0x16c>
    5224:	mov    rdi,r13
    5227:	jmp    5557 <botlish_fn_49+0x497>
    522c:	xor    ecx,ecx
    522e:	test   rax,0x7
    5234:	je     5242 <botlish_fn_49+0x182>
    523a:	mov    rsi,rax
    523d:	jmp    5250 <botlish_fn_49+0x190>
    5242:	movzx  rdi,BYTE PTR [rax]
    5246:	mov    rsi,rax
    5249:	cmp    dil,0x8
    524d:	sete   cl
    5250:	test   cl,cl
    5252:	jne    5275 <botlish_fn_49+0x1b5>
    5258:	mov    rdi,r13
    525b:	mov    r11,QWORD PTR [rdi+0x10]
    525f:	mov    rcx,QWORD PTR [r11+0x40]
    5263:	mov    edx,0x8
    5268:	call   526d <botlish_fn_49+0x1ad>
			5269: R_X86_64_PLT32	rt_type_error-0x4
    526d:	mov    rdi,r13
    5270:	jmp    5557 <botlish_fn_49+0x497>
    5275:	mov    rcx,QWORD PTR [rsp+0x8]
    527a:	mov    rdx,QWORD PTR [rsp]
    527e:	mov    rdi,r13
    5281:	call   5286 <botlish_fn_49+0x1c6>
			5282: R_X86_64_PLT32	rt_mutarray_set-0x4
    5286:	test   rax,rax
    5289:	jne    5297 <botlish_fn_49+0x1d7>
    528f:	mov    rdi,r13
    5292:	jmp    5557 <botlish_fn_49+0x497>
    5297:	mov    rsi,r14
    529a:	mov    rdi,r13
    529d:	call   52a2 <botlish_fn_49+0x1e2>
			529e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    52a2:	test   rax,rax
    52a5:	jne    52b3 <botlish_fn_49+0x1f3>
    52ab:	mov    rdi,r13
    52ae:	jmp    5557 <botlish_fn_49+0x497>
    52b3:	xor    ecx,ecx
    52b5:	test   rax,0x7
    52bb:	je     52c9 <botlish_fn_49+0x209>
    52c1:	mov    rsi,rax
    52c4:	jmp    52d7 <botlish_fn_49+0x217>
    52c9:	movzx  rcx,BYTE PTR [rax]
    52cd:	mov    rsi,rax
    52d0:	rex cmp cl,0x8
    52d4:	sete   cl
    52d7:	test   cl,cl
    52d9:	jne    52fc <botlish_fn_49+0x23c>
    52df:	mov    rdi,r13
    52e2:	mov    rax,QWORD PTR [rdi+0x10]
    52e6:	mov    rcx,QWORD PTR [rax+0x40]
    52ea:	mov    edx,0x8
    52ef:	call   52f4 <botlish_fn_49+0x234>
			52f0: R_X86_64_PLT32	rt_type_error-0x4
    52f4:	mov    rdi,r13
    52f7:	jmp    5557 <botlish_fn_49+0x497>
    52fc:	mov    rcx,r15
    52ff:	mov    rdx,QWORD PTR [rsp]
    5303:	mov    rdi,r13
    5306:	call   530b <botlish_fn_49+0x24b>
			5307: R_X86_64_PLT32	rt_mutarray_set-0x4
    530b:	test   rax,rax
    530e:	jne    531c <botlish_fn_49+0x25c>
    5314:	mov    rdi,r13
    5317:	jmp    5557 <botlish_fn_49+0x497>
    531c:	mov    QWORD PTR [r12+0x8],0x7
    5325:	mov    rsi,r14
    5328:	mov    rdi,r13
    532b:	call   5330 <botlish_fn_49+0x270>
			532c: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    5330:	test   rax,rax
    5333:	jne    5341 <botlish_fn_49+0x281>
    5339:	mov    rdi,r13
    533c:	jmp    5557 <botlish_fn_49+0x497>
    5341:	mov    QWORD PTR [r12+0x10],rax
    5346:	mov    QWORD PTR [r12+0x18],0x3
    534f:	mov    ecx,0x1
    5354:	test   rax,0x1
    535a:	je     5368 <botlish_fn_49+0x2a8>
    5360:	mov    rsi,rax
    5363:	jmp    538c <botlish_fn_49+0x2cc>
    5368:	xor    ecx,ecx
    536a:	test   rax,0x7
    5370:	je     537e <botlish_fn_49+0x2be>
    5376:	mov    rsi,rax
    5379:	jmp    538c <botlish_fn_49+0x2cc>
    537e:	movzx  rcx,BYTE PTR [rax]
    5382:	mov    rsi,rax
    5385:	rex cmp cl,0x1
    5389:	sete   cl
    538c:	test   cl,cl
    538e:	jne    53af <botlish_fn_49+0x2ef>
    5394:	mov    rdi,r13
    5397:	mov    rax,QWORD PTR [rdi+0x10]
    539b:	mov    rcx,QWORD PTR [rax+0x30]
    539f:	xor    rdx,rdx
    53a2:	call   53a7 <botlish_fn_49+0x2e7>
			53a3: R_X86_64_PLT32	rt_type_error-0x4
    53a7:	mov    rdi,r13
    53aa:	jmp    5557 <botlish_fn_49+0x497>
    53af:	test   rsi,0x1
    53b6:	je     53ce <botlish_fn_49+0x30e>
    53bc:	mov    rcx,rsi
    53bf:	add    rcx,0x2
    53c3:	seto   al
    53c6:	test   al,al
    53c8:	je     53de <botlish_fn_49+0x31e>
    53ce:	mov    edx,0x3
    53d3:	mov    rdi,r13
    53d6:	call   53db <botlish_fn_49+0x31b>
			53d7: R_X86_64_PLT32	rt_int_add-0x4
    53db:	mov    rcx,rax
    53de:	mov    edx,0x7
    53e3:	mov    rsi,r14
    53e6:	mov    rdi,r13
    53e9:	call   53ee <botlish_fn_49+0x32e>
			53ea: R_X86_64_PLT32	rt_mutarray_set-0x4
    53ee:	test   rax,rax
    53f1:	jne    53ff <botlish_fn_49+0x33f>
    53f7:	mov    rdi,r13
    53fa:	jmp    5557 <botlish_fn_49+0x497>
    53ff:	mov    rdi,r13
    5402:	call   5407 <botlish_fn_49+0x347>
			5403: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    5407:	test   rax,rax
    540a:	jne    5418 <botlish_fn_49+0x358>
    5410:	mov    rdi,r13
    5413:	jmp    5557 <botlish_fn_49+0x497>
    5418:	mov    rcx,rbx
    541b:	and    rcx,rax
    541e:	mov    rdx,rax
    5421:	mov    rax,rbx
    5424:	test   rcx,0x1
    542b:	jne    544d <botlish_fn_49+0x38d>
    5431:	mov    rsi,rax
    5434:	mov    rdi,r13
    5437:	call   543c <botlish_fn_49+0x37c>
			5438: R_X86_64_PLT32	rt_value_eq-0x4
    543c:	test   rax,rax
    543f:	jne    5460 <botlish_fn_49+0x3a0>
    5445:	mov    rdi,r13
    5448:	jmp    5557 <botlish_fn_49+0x497>
    544d:	mov    rsi,rax
    5450:	mov    eax,0x2
    5455:	cmp    rsi,rdx
    5458:	cmove  rax,QWORD PTR [rip+0x180]        # 55e0 <botlish_fn_49+0x520>
    5460:	cmp    rax,0x6
    5464:	je     5472 <botlish_fn_49+0x3b2>
    546a:	mov    rdi,r13
    546d:	jmp    5585 <botlish_fn_49+0x4c5>
    5472:	mov    QWORD PTR [r12+0x8],0x9
    547b:	mov    rsi,r14
    547e:	mov    rdi,r13
    5481:	call   5486 <botlish_fn_49+0x3c6>
			5482: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    5486:	test   rax,rax
    5489:	jne    5497 <botlish_fn_49+0x3d7>
    548f:	mov    rdi,r13
    5492:	jmp    5557 <botlish_fn_49+0x497>
    5497:	mov    QWORD PTR [r12+0x10],rax
    549c:	mov    QWORD PTR [r12+0x18],0x3
    54a5:	mov    ecx,0x1
    54aa:	test   rax,0x1
    54b0:	je     54be <botlish_fn_49+0x3fe>
    54b6:	mov    rsi,rax
    54b9:	jmp    54e2 <botlish_fn_49+0x422>
    54be:	xor    ecx,ecx
    54c0:	test   rax,0x7
    54c6:	je     54d4 <botlish_fn_49+0x414>
    54cc:	mov    rsi,rax
    54cf:	jmp    54e2 <botlish_fn_49+0x422>
    54d4:	movzx  rcx,BYTE PTR [rax]
    54d8:	mov    rsi,rax
    54db:	rex cmp cl,0x1
    54df:	sete   cl
    54e2:	test   cl,cl
    54e4:	jne    5505 <botlish_fn_49+0x445>
    54ea:	mov    rdi,r13
    54ed:	mov    rax,QWORD PTR [rdi+0x10]
    54f1:	mov    rcx,QWORD PTR [rax+0x48]
    54f5:	xor    rdx,rdx
    54f8:	call   54fd <botlish_fn_49+0x43d>
			54f9: R_X86_64_PLT32	rt_type_error-0x4
    54fd:	mov    rdi,r13
    5500:	jmp    5557 <botlish_fn_49+0x497>
    5505:	test   rsi,0x1
    550c:	je     552b <botlish_fn_49+0x46b>
    5512:	mov    rcx,rsi
    5515:	sub    rcx,0x3
    5519:	seto   al
    551c:	add    rcx,0x1
    5523:	test   al,al
    5525:	je     553b <botlish_fn_49+0x47b>
    552b:	mov    edx,0x3
    5530:	mov    rdi,r13
    5533:	call   5538 <botlish_fn_49+0x478>
			5534: R_X86_64_PLT32	rt_int_sub-0x4
    5538:	mov    rcx,rax
    553b:	mov    edx,0x9
    5540:	mov    rsi,r14
    5543:	mov    rdi,r13
    5546:	call   554b <botlish_fn_49+0x48b>
			5547: R_X86_64_PLT32	rt_mutarray_set-0x4
    554b:	test   rax,rax
    554e:	jne    5582 <botlish_fn_49+0x4c2>
    5554:	mov    rdi,r13
    5557:	mov    rdi,r13
    555a:	mov    QWORD PTR [rdi],r12
    555d:	xor    rax,rax
    5560:	mov    rbx,QWORD PTR [rsp+0x20]
    5565:	mov    r12,QWORD PTR [rsp+0x28]
    556a:	mov    r13,QWORD PTR [rsp+0x30]
    556f:	mov    r14,QWORD PTR [rsp+0x38]
    5574:	mov    r15,QWORD PTR [rsp+0x40]
    5579:	add    rsp,0x50
    557d:	mov    rsp,rbp
    5580:	pop    rbp
    5581:	ret
    5582:	mov    rdi,r13
    5585:	mov    rdi,r13
    5588:	mov    QWORD PTR [rdi],r12
    558b:	mov    eax,0xa
    5590:	mov    rbx,QWORD PTR [rsp+0x20]
    5595:	mov    r12,QWORD PTR [rsp+0x28]
    559a:	mov    r13,QWORD PTR [rsp+0x30]
    559f:	mov    r14,QWORD PTR [rsp+0x38]
    55a4:	mov    r15,QWORD PTR [rsp+0x40]
    55a9:	add    rsp,0x50
    55ad:	mov    rsp,rbp
    55b0:	pop    rbp
    55b1:	ret
    55b2:	mov    r13,rdi
    55b5:	call   55ba <botlish_fn_49+0x4fa>
			55b6: R_X86_64_PLT32	rt_stack_overflow-0x4
    55ba:	xor    rax,rax
    55bd:	mov    rbx,QWORD PTR [rsp+0x20]
    55c2:	mov    r12,QWORD PTR [rsp+0x28]
    55c7:	mov    r13,QWORD PTR [rsp+0x30]
    55cc:	mov    r14,QWORD PTR [rsp+0x38]
    55d1:	mov    r15,QWORD PTR [rsp+0x40]
    55d6:	add    rsp,0x50
    55da:	mov    rsp,rbp
    55dd:	pop    rbp
    55de:	ret
    55df:	add    BYTE PTR [rsi],al
    55e1:	add    BYTE PTR [rax],al
    55e3:	add    BYTE PTR [rax],al
    55e5:	add    BYTE PTR [rax],al
	...

00000000000055e8 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    55e8:	push   rbp
    55e9:	mov    rbp,rsp
    55ec:	mov    rsi,QWORD PTR [rdx]
    55ef:	mov    r9,QWORD PTR [rdx+0x8]
    55f3:	mov    rcx,QWORD PTR [rdx+0x10]
    55f7:	mov    r8,QWORD PTR [rdx+0x18]
    55fb:	mov    rdx,r9
    55fe:	call   5603 <botlish_entry_49+0x1b>
			55ff: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5603:	mov    rsp,rbp
    5606:	pop    rbp
    5607:	ret

0000000000005608 <botlish_fn_50: ht_set<mutarray, any, any>>:
    5608:	push   rbp
    5609:	mov    rbp,rsp
    560c:	sub    rsp,0x50
    5610:	mov    QWORD PTR [rsp+0x20],rbx
    5615:	mov    QWORD PTR [rsp+0x28],r12
    561a:	mov    QWORD PTR [rsp+0x30],r13
    561f:	mov    QWORD PTR [rsp+0x38],r14
    5624:	mov    QWORD PTR [rsp+0x40],r15
    5629:	mov    rbx,QWORD PTR [rdi]
    562c:	mov    rax,QWORD PTR [rdi+0x8]
    5630:	lea    r8,[rbx+0x28]
    5634:	cmp    r8,rax
    5637:	ja     59d9 <botlish_fn_50+0x3d1>
    563d:	lea    rax,[rbx+0x28]
    5641:	mov    QWORD PTR [rdi],rax
    5644:	mov    r12,rdi
    5647:	mov    QWORD PTR [rbx+0x18],0x0
    564f:	mov    QWORD PTR [rbx+0x20],0x0
    5657:	mov    QWORD PTR [rbx],rsi
    565a:	mov    r15,rsi
    565d:	mov    QWORD PTR [rbx+0x8],rdx
    5661:	mov    r14,rdx
    5664:	mov    QWORD PTR [rbx+0x10],rcx
    5668:	mov    r13,rcx
    566b:	mov    rdx,r14
    566e:	mov    rsi,r15
    5671:	mov    rdi,r12
    5674:	call   5679 <botlish_fn_50+0x71>
			5675: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5679:	test   rax,rax
    567c:	jne    568a <botlish_fn_50+0x82>
    5682:	mov    rdi,r12
    5685:	jmp    5981 <botlish_fn_50+0x379>
    568a:	mov    QWORD PTR [rbx+0x18],rax
    568e:	mov    rcx,rax
    5691:	mov    r8,0xffffffffffffffff
    5698:	mov    QWORD PTR [rsp+0x10],r8
    569d:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    56a5:	mov    rdx,r14
    56a8:	mov    rsi,r15
    56ab:	mov    rdi,r12
    56ae:	call   56b3 <botlish_fn_50+0xab>
			56af: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    56b3:	mov    rcx,rax
    56b6:	mov    QWORD PTR [rsp+0x8],rax
    56bb:	test   rax,rcx
    56be:	jne    56cc <botlish_fn_50+0xc4>
    56c4:	mov    rdi,r12
    56c7:	jmp    5981 <botlish_fn_50+0x379>
    56cc:	mov    rax,QWORD PTR [rsp+0x8]
    56d1:	mov    QWORD PTR [rbx+0x18],rax
    56d5:	mov    rsi,r15
    56d8:	mov    rdi,r12
    56db:	call   56e0 <botlish_fn_50+0xd8>
			56dc: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    56e0:	test   rax,rax
    56e3:	jne    56f1 <botlish_fn_50+0xe9>
    56e9:	mov    rdi,r12
    56ec:	jmp    5981 <botlish_fn_50+0x379>
    56f1:	xor    ecx,ecx
    56f3:	test   rax,0x7
    56f9:	je     5707 <botlish_fn_50+0xff>
    56ff:	mov    rsi,rax
    5702:	jmp    5715 <botlish_fn_50+0x10d>
    5707:	movzx  rcx,BYTE PTR [rax]
    570b:	mov    rsi,rax
    570e:	rex cmp cl,0x8
    5712:	sete   cl
    5715:	test   cl,cl
    5717:	jne    573a <botlish_fn_50+0x132>
    571d:	mov    rdi,r12
    5720:	mov    rax,QWORD PTR [rdi+0x10]
    5724:	mov    rcx,QWORD PTR [rax+0x20]
    5728:	mov    edx,0x8
    572d:	call   5732 <botlish_fn_50+0x12a>
			572e: R_X86_64_PLT32	rt_type_error-0x4
    5732:	mov    rdi,r12
    5735:	jmp    5981 <botlish_fn_50+0x379>
    573a:	mov    rdx,QWORD PTR [rsp+0x8]
    573f:	mov    rdi,r12
    5742:	call   5747 <botlish_fn_50+0x13f>
			5743: R_X86_64_PLT32	rt_mutarray_get-0x4
    5747:	test   rax,rax
    574a:	jne    5758 <botlish_fn_50+0x150>
    5750:	mov    rdi,r12
    5753:	jmp    5981 <botlish_fn_50+0x379>
    5758:	mov    QWORD PTR [rbx+0x20],rax
    575c:	mov    QWORD PTR [rsp],rax
    5760:	mov    rdi,r12
    5763:	call   5768 <botlish_fn_50+0x160>
			5764: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    5768:	test   rax,rax
    576b:	jne    5779 <botlish_fn_50+0x171>
    5771:	mov    rdi,r12
    5774:	jmp    5981 <botlish_fn_50+0x379>
    5779:	mov    rcx,QWORD PTR [rsp]
    577d:	mov    rdx,rcx
    5780:	and    rdx,rax
    5783:	test   rdx,0x1
    578a:	jne    57b0 <botlish_fn_50+0x1a8>
    5790:	mov    rdx,rax
    5793:	mov    rsi,QWORD PTR [rsp]
    5797:	mov    rdi,r12
    579a:	call   579f <botlish_fn_50+0x197>
			579b: R_X86_64_PLT32	rt_value_eq-0x4
    579f:	test   rax,rax
    57a2:	jne    57c7 <botlish_fn_50+0x1bf>
    57a8:	mov    rdi,r12
    57ab:	jmp    5981 <botlish_fn_50+0x379>
    57b0:	mov    rdx,rax
    57b3:	mov    rsi,QWORD PTR [rsp]
    57b7:	mov    eax,0x2
    57bc:	cmp    rsi,rdx
    57bf:	cmove  rax,QWORD PTR [rip+0x241]        # 5a08 <botlish_fn_50+0x400>
    57c7:	cmp    rax,0x6
    57cb:	je     5905 <botlish_fn_50+0x2fd>
    57d1:	mov    rsi,r15
    57d4:	mov    rdi,r12
    57d7:	call   57dc <botlish_fn_50+0x1d4>
			57d8: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    57dc:	test   rax,rax
    57df:	jne    57ed <botlish_fn_50+0x1e5>
    57e5:	mov    rdi,r12
    57e8:	jmp    5981 <botlish_fn_50+0x379>
    57ed:	cmp    rax,0x6
    57f1:	je     5846 <botlish_fn_50+0x23e>
    57f7:	mov    rcx,r14
    57fa:	mov    rdx,QWORD PTR [rsp+0x8]
    57ff:	mov    rsi,r15
    5802:	mov    r8,r13
    5805:	mov    rdi,r12
    5808:	call   580d <botlish_fn_50+0x205>
			5809: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    580d:	test   rax,rax
    5810:	jne    581e <botlish_fn_50+0x216>
    5816:	mov    rdi,r12
    5819:	jmp    5981 <botlish_fn_50+0x379>
    581e:	mov    rdi,r12
    5821:	mov    QWORD PTR [rdi],rbx
    5824:	mov    rbx,QWORD PTR [rsp+0x20]
    5829:	mov    r12,QWORD PTR [rsp+0x28]
    582e:	mov    r13,QWORD PTR [rsp+0x30]
    5833:	mov    r14,QWORD PTR [rsp+0x38]
    5838:	mov    r15,QWORD PTR [rsp+0x40]
    583d:	add    rsp,0x50
    5841:	mov    rsp,rbp
    5844:	pop    rbp
    5845:	ret
    5846:	mov    rsi,r15
    5849:	mov    rdi,r12
    584c:	call   5851 <botlish_fn_50+0x249>
			584d: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    5851:	test   rax,rax
    5854:	jne    5862 <botlish_fn_50+0x25a>
    585a:	mov    rdi,r12
    585d:	jmp    5981 <botlish_fn_50+0x379>
    5862:	mov    rdx,r14
    5865:	mov    rsi,r15
    5868:	mov    rdi,r12
    586b:	call   5870 <botlish_fn_50+0x268>
			586c: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5870:	test   rax,rax
    5873:	jne    5881 <botlish_fn_50+0x279>
    5879:	mov    rdi,r12
    587c:	jmp    5981 <botlish_fn_50+0x379>
    5881:	mov    QWORD PTR [rbx+0x18],rax
    5885:	mov    rcx,rax
    5888:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    5890:	mov    r8,QWORD PTR [rsp+0x10]
    5895:	mov    rdx,r14
    5898:	mov    rsi,r15
    589b:	mov    rdi,r12
    589e:	call   58a3 <botlish_fn_50+0x29b>
			589f: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    58a3:	test   rax,rax
    58a6:	jne    58b4 <botlish_fn_50+0x2ac>
    58ac:	mov    rdi,r12
    58af:	jmp    5981 <botlish_fn_50+0x379>
    58b4:	mov    QWORD PTR [rbx+0x18],rax
    58b8:	mov    rcx,r14
    58bb:	mov    rdx,rax
    58be:	mov    rsi,r15
    58c1:	mov    r8,r13
    58c4:	mov    rdi,r12
    58c7:	call   58cc <botlish_fn_50+0x2c4>
			58c8: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    58cc:	test   rax,rax
    58cf:	jne    58dd <botlish_fn_50+0x2d5>
    58d5:	mov    rdi,r12
    58d8:	jmp    5981 <botlish_fn_50+0x379>
    58dd:	mov    rdi,r12
    58e0:	mov    QWORD PTR [rdi],rbx
    58e3:	mov    rbx,QWORD PTR [rsp+0x20]
    58e8:	mov    r12,QWORD PTR [rsp+0x28]
    58ed:	mov    r13,QWORD PTR [rsp+0x30]
    58f2:	mov    r14,QWORD PTR [rsp+0x38]
    58f7:	mov    r15,QWORD PTR [rsp+0x40]
    58fc:	add    rsp,0x50
    5900:	mov    rsp,rbp
    5903:	pop    rbp
    5904:	ret
    5905:	mov    rsi,r15
    5908:	mov    rdi,r12
    590b:	call   5910 <botlish_fn_50+0x308>
			590c: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    5910:	test   rax,rax
    5913:	jne    5921 <botlish_fn_50+0x319>
    5919:	mov    rdi,r12
    591c:	jmp    5981 <botlish_fn_50+0x379>
    5921:	xor    ecx,ecx
    5923:	test   rax,0x7
    5929:	jne    593a <botlish_fn_50+0x332>
    592f:	movzx  rsi,BYTE PTR [rax]
    5933:	cmp    sil,0x8
    5937:	sete   cl
    593a:	test   cl,cl
    593c:	jne    5962 <botlish_fn_50+0x35a>
    5942:	mov    rdi,r12
    5945:	mov    r10,QWORD PTR [rdi+0x10]
    5949:	mov    rcx,QWORD PTR [r10+0x40]
    594d:	mov    edx,0x8
    5952:	mov    rsi,rax
    5955:	call   595a <botlish_fn_50+0x352>
			5956: R_X86_64_PLT32	rt_type_error-0x4
    595a:	mov    rdi,r12
    595d:	jmp    5981 <botlish_fn_50+0x379>
    5962:	mov    rcx,r13
    5965:	mov    rdx,QWORD PTR [rsp+0x8]
    596a:	mov    rsi,rax
    596d:	mov    rdi,r12
    5970:	call   5975 <botlish_fn_50+0x36d>
			5971: R_X86_64_PLT32	rt_mutarray_set-0x4
    5975:	test   rax,rax
    5978:	jne    59ac <botlish_fn_50+0x3a4>
    597e:	mov    rdi,r12
    5981:	mov    rdi,r12
    5984:	mov    QWORD PTR [rdi],rbx
    5987:	xor    rax,rax
    598a:	mov    rbx,QWORD PTR [rsp+0x20]
    598f:	mov    r12,QWORD PTR [rsp+0x28]
    5994:	mov    r13,QWORD PTR [rsp+0x30]
    5999:	mov    r14,QWORD PTR [rsp+0x38]
    599e:	mov    r15,QWORD PTR [rsp+0x40]
    59a3:	add    rsp,0x50
    59a7:	mov    rsp,rbp
    59aa:	pop    rbp
    59ab:	ret
    59ac:	mov    rdi,r12
    59af:	mov    QWORD PTR [rdi],rbx
    59b2:	mov    eax,0xa
    59b7:	mov    rbx,QWORD PTR [rsp+0x20]
    59bc:	mov    r12,QWORD PTR [rsp+0x28]
    59c1:	mov    r13,QWORD PTR [rsp+0x30]
    59c6:	mov    r14,QWORD PTR [rsp+0x38]
    59cb:	mov    r15,QWORD PTR [rsp+0x40]
    59d0:	add    rsp,0x50
    59d4:	mov    rsp,rbp
    59d7:	pop    rbp
    59d8:	ret
    59d9:	mov    r12,rdi
    59dc:	call   59e1 <botlish_fn_50+0x3d9>
			59dd: R_X86_64_PLT32	rt_stack_overflow-0x4
    59e1:	xor    rax,rax
    59e4:	mov    rbx,QWORD PTR [rsp+0x20]
    59e9:	mov    r12,QWORD PTR [rsp+0x28]
    59ee:	mov    r13,QWORD PTR [rsp+0x30]
    59f3:	mov    r14,QWORD PTR [rsp+0x38]
    59f8:	mov    r15,QWORD PTR [rsp+0x40]
    59fd:	add    rsp,0x50
    5a01:	mov    rsp,rbp
    5a04:	pop    rbp
    5a05:	ret
    5a06:	add    BYTE PTR [rax],al
    5a08:	(bad)
    5a09:	add    BYTE PTR [rax],al
    5a0b:	add    BYTE PTR [rax],al
    5a0d:	add    BYTE PTR [rax],al
	...

0000000000005a10 <botlish_entry_50: ht_set<mutarray, any, any>>:
    5a10:	push   rbp
    5a11:	mov    rbp,rsp
    5a14:	mov    rsi,QWORD PTR [rdx]
    5a17:	mov    r8,QWORD PTR [rdx+0x8]
    5a1b:	mov    rcx,QWORD PTR [rdx+0x10]
    5a1f:	mov    rdx,r8
    5a22:	call   5a27 <botlish_entry_50+0x17>
			5a23: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    5a27:	mov    rsp,rbp
    5a2a:	pop    rbp
    5a2b:	ret

0000000000005a2c <botlish_fn_51: row_new<bool, int>>:
    5a2c:	push   rbp
    5a2d:	mov    rbp,rsp
    5a30:	sub    rsp,0x10
    5a34:	mov    QWORD PTR [rsp],r14
    5a38:	mov    QWORD PTR [rsp+0x8],r15
    5a3d:	mov    r14,QWORD PTR [rdi]
    5a40:	mov    rax,QWORD PTR [rdi+0x8]
    5a44:	lea    rcx,[r14+0x8]
    5a48:	cmp    rcx,rax
    5a4b:	ja     5ae6 <botlish_fn_51+0xba>
    5a51:	lea    rax,[r14+0x8]
    5a55:	mov    QWORD PTR [rdi],rax
    5a58:	mov    r15,rdi
    5a5b:	mov    QWORD PTR [r14],rdx
    5a5e:	mov    rax,rdx
    5a61:	cmp    rsi,0x6
    5a65:	je     5a9c <botlish_fn_51+0x70>
    5a6b:	mov    rdi,r15
    5a6e:	call   5a73 <botlish_fn_51+0x47>
			5a6f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    5a73:	test   rax,rax
    5a76:	jne    5a84 <botlish_fn_51+0x58>
    5a7c:	mov    rdi,r15
    5a7f:	jmp    5ab3 <botlish_fn_51+0x87>
    5a84:	mov    rdi,r15
    5a87:	mov    QWORD PTR [rdi],r14
    5a8a:	mov    r14,QWORD PTR [rsp]
    5a8e:	mov    r15,QWORD PTR [rsp+0x8]
    5a93:	add    rsp,0x10
    5a97:	mov    rsp,rbp
    5a9a:	pop    rbp
    5a9b:	ret
    5a9c:	mov    rsi,rax
    5a9f:	mov    rdi,r15
    5aa2:	call   5aa7 <botlish_fn_51+0x7b>
			5aa3: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    5aa7:	test   rax,rax
    5aaa:	jne    5ace <botlish_fn_51+0xa2>
    5ab0:	mov    rdi,r15
    5ab3:	mov    rdi,r15
    5ab6:	mov    QWORD PTR [rdi],r14
    5ab9:	xor    rax,rax
    5abc:	mov    r14,QWORD PTR [rsp]
    5ac0:	mov    r15,QWORD PTR [rsp+0x8]
    5ac5:	add    rsp,0x10
    5ac9:	mov    rsp,rbp
    5acc:	pop    rbp
    5acd:	ret
    5ace:	mov    rdi,r15
    5ad1:	mov    QWORD PTR [rdi],r14
    5ad4:	mov    r14,QWORD PTR [rsp]
    5ad8:	mov    r15,QWORD PTR [rsp+0x8]
    5add:	add    rsp,0x10
    5ae1:	mov    rsp,rbp
    5ae4:	pop    rbp
    5ae5:	ret
    5ae6:	mov    r15,rdi
    5ae9:	call   5aee <botlish_fn_51+0xc2>
			5aea: R_X86_64_PLT32	rt_stack_overflow-0x4
    5aee:	xor    rax,rax
    5af1:	mov    r14,QWORD PTR [rsp]
    5af5:	mov    r15,QWORD PTR [rsp+0x8]
    5afa:	add    rsp,0x10
    5afe:	mov    rsp,rbp
    5b01:	pop    rbp
    5b02:	ret

0000000000005b03 <botlish_entry_51: row_new<bool, int>>:
    5b03:	push   rbp
    5b04:	mov    rbp,rsp
    5b07:	mov    rsi,QWORD PTR [rdx]
    5b0a:	mov    rdx,QWORD PTR [rdx+0x8]
    5b0e:	call   5b13 <botlish_entry_51+0x10>
			5b0f: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    5b13:	mov    rsp,rbp
    5b16:	pop    rbp
    5b17:	ret

0000000000005b18 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    5b18:	push   rbp
    5b19:	mov    rbp,rsp
    5b1c:	sub    rsp,0x50
    5b20:	mov    QWORD PTR [rsp+0x20],rbx
    5b25:	mov    QWORD PTR [rsp+0x28],r12
    5b2a:	mov    QWORD PTR [rsp+0x30],r13
    5b2f:	mov    QWORD PTR [rsp+0x38],r14
    5b34:	mov    QWORD PTR [rsp+0x40],r15
    5b39:	mov    r13,rdx
    5b3c:	mov    r15,QWORD PTR [rdi]
    5b3f:	mov    rax,QWORD PTR [rdi+0x8]
    5b43:	lea    rdx,[r15+0x30]
    5b47:	cmp    rdx,rax
    5b4a:	ja     5dea <botlish_fn_52+0x2d2>
    5b50:	lea    rdx,[r15+0x30]
    5b54:	mov    QWORD PTR [rdi],rdx
    5b57:	mov    QWORD PTR [rsp],rdi
    5b5b:	mov    QWORD PTR [r15],rsi
    5b5e:	mov    rdx,r13
    5b61:	mov    r14,rsi
    5b64:	mov    QWORD PTR [r15+0x8],rdx
    5b68:	mov    QWORD PTR [r15+0x10],rcx
    5b6c:	mov    QWORD PTR [rsp+0x8],rcx
    5b71:	mov    QWORD PTR [r15+0x18],r8
    5b75:	mov    rbx,r9
    5b78:	mov    rdi,rbx
    5b7b:	or     rdi,0x1
    5b7f:	mov    r12,r8
    5b82:	and    r8,rdi
    5b85:	test   r8,0x1
    5b8c:	jne    5bba <botlish_fn_52+0xa2>
    5b92:	mov    rdx,rbx
    5b95:	or     rdx,0x1
    5b99:	mov    rsi,r12
    5b9c:	mov    rdi,QWORD PTR [rsp]
    5ba0:	call   5ba5 <botlish_fn_52+0x8d>
			5ba1: R_X86_64_PLT32	rt_int_cmp-0x4
    5ba5:	mov    ecx,0x2
    5baa:	test   rax,rax
    5bad:	cmovge rcx,QWORD PTR [rip+0x263]        # 5e18 <botlish_fn_52+0x300>
    5bb5:	jmp    5bd1 <botlish_fn_52+0xb9>
    5bba:	mov    r11,rbx
    5bbd:	or     r11,0x1
    5bc1:	mov    ecx,0x2
    5bc6:	cmp    r12,r11
    5bc9:	cmovge rcx,QWORD PTR [rip+0x247]        # 5e18 <botlish_fn_52+0x300>
    5bd1:	cmp    rcx,0x6
    5bd5:	je     5dbe <botlish_fn_52+0x2a6>
    5bdb:	xor    ecx,ecx
    5bdd:	mov    rdx,r13
    5be0:	test   rdx,0x7
    5be7:	jne    5bf9 <botlish_fn_52+0xe1>
    5bed:	mov    rdx,r13
    5bf0:	movzx  rax,BYTE PTR [rdx]
    5bf4:	cmp    al,0x3
    5bf6:	sete   cl
    5bf9:	test   cl,cl
    5bfb:	jne    5c23 <botlish_fn_52+0x10b>
    5c01:	mov    rdi,QWORD PTR [rsp]
    5c05:	mov    rax,QWORD PTR [rdi+0x10]
    5c09:	mov    rcx,QWORD PTR [rax+0x50]
    5c0d:	mov    edx,0x4
    5c12:	mov    rsi,r13
    5c15:	call   5c1a <botlish_fn_52+0x102>
			5c16: R_X86_64_PLT32	rt_type_error-0x4
    5c1a:	mov    rdi,QWORD PTR [rsp]
    5c1e:	jmp    5d65 <botlish_fn_52+0x24d>
    5c23:	mov    rsi,r13
    5c26:	test   r12,0x1
    5c2d:	jne    5c3b <botlish_fn_52+0x123>
    5c33:	mov    r13,rsi
    5c36:	jmp    5c51 <botlish_fn_52+0x139>
    5c3b:	mov    rax,QWORD PTR [rsi+0x8]
    5c3f:	mov    r13,rsi
    5c42:	mov    rcx,r12
    5c45:	sar    rcx,1
    5c48:	cmp    rcx,rax
    5c4b:	jb     5c7a <botlish_fn_52+0x162>
    5c51:	mov    rdx,r12
    5c54:	mov    rsi,r13
    5c57:	mov    rdi,QWORD PTR [rsp]
    5c5b:	call   5c60 <botlish_fn_52+0x148>
			5c5c: R_X86_64_PLT32	rt_list_get-0x4
    5c60:	test   rax,rax
    5c63:	jne    5c72 <botlish_fn_52+0x15a>
    5c69:	mov    rdi,QWORD PTR [rsp]
    5c6d:	jmp    5d65 <botlish_fn_52+0x24d>
    5c72:	mov    rdx,rax
    5c75:	jmp    5c82 <botlish_fn_52+0x16a>
    5c7a:	mov    rax,QWORD PTR [r13+0x10]
    5c7e:	mov    rdx,QWORD PTR [rax+rcx*8]
    5c82:	mov    QWORD PTR [r15+0x20],rdx
    5c86:	mov    QWORD PTR [rsp+0x10],rdx
    5c8b:	xor    r11d,r11d
    5c8e:	mov    rcx,QWORD PTR [rsp+0x8]
    5c93:	test   rcx,0x7
    5c9a:	je     5caa <botlish_fn_52+0x192>
    5ca0:	mov    QWORD PTR [rsp+0x8],rcx
    5ca5:	jmp    5cb9 <botlish_fn_52+0x1a1>
    5caa:	movzx  rax,BYTE PTR [rcx]
    5cae:	mov    QWORD PTR [rsp+0x8],rcx
    5cb3:	cmp    al,0x3
    5cb5:	sete   r11b
    5cb9:	test   r11b,r11b
    5cbc:	jne    5ce6 <botlish_fn_52+0x1ce>
    5cc2:	mov    rdi,QWORD PTR [rsp]
    5cc6:	mov    rax,QWORD PTR [rdi+0x10]
    5cca:	mov    rcx,QWORD PTR [rax+0x50]
    5cce:	mov    edx,0x4
    5cd3:	mov    rsi,QWORD PTR [rsp+0x8]
    5cd8:	call   5cdd <botlish_fn_52+0x1c5>
			5cd9: R_X86_64_PLT32	rt_type_error-0x4
    5cdd:	mov    rdi,QWORD PTR [rsp]
    5ce1:	jmp    5d65 <botlish_fn_52+0x24d>
    5ce6:	test   r12,0x1
    5ced:	je     5d0b <botlish_fn_52+0x1f3>
    5cf3:	mov    rsi,QWORD PTR [rsp+0x8]
    5cf8:	mov    rcx,QWORD PTR [rsi+0x8]
    5cfc:	mov    rax,r12
    5cff:	sar    rax,1
    5d02:	cmp    rax,rcx
    5d05:	jb     5d36 <botlish_fn_52+0x21e>
    5d0b:	mov    rdx,r12
    5d0e:	mov    rsi,QWORD PTR [rsp+0x8]
    5d13:	mov    rdi,QWORD PTR [rsp]
    5d17:	call   5d1c <botlish_fn_52+0x204>
			5d18: R_X86_64_PLT32	rt_list_get-0x4
    5d1c:	test   rax,rax
    5d1f:	jne    5d2e <botlish_fn_52+0x216>
    5d25:	mov    rdi,QWORD PTR [rsp]
    5d29:	jmp    5d65 <botlish_fn_52+0x24d>
    5d2e:	mov    rcx,rax
    5d31:	jmp    5d43 <botlish_fn_52+0x22b>
    5d36:	mov    rsi,QWORD PTR [rsp+0x8]
    5d3b:	mov    rcx,QWORD PTR [rsi+0x10]
    5d3f:	mov    rcx,QWORD PTR [rcx+rax*8]
    5d43:	mov    QWORD PTR [r15+0x28],rcx
    5d47:	mov    rdx,QWORD PTR [rsp+0x10]
    5d4c:	mov    rsi,r14
    5d4f:	mov    rdi,QWORD PTR [rsp]
    5d53:	call   5d58 <botlish_fn_52+0x240>
			5d54: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    5d58:	test   rax,rax
    5d5b:	jne    5d91 <botlish_fn_52+0x279>
    5d61:	mov    rdi,QWORD PTR [rsp]
    5d65:	mov    rdi,QWORD PTR [rsp]
    5d69:	mov    QWORD PTR [rdi],r15
    5d6c:	xor    rax,rax
    5d6f:	mov    rbx,QWORD PTR [rsp+0x20]
    5d74:	mov    r12,QWORD PTR [rsp+0x28]
    5d79:	mov    r13,QWORD PTR [rsp+0x30]
    5d7e:	mov    r14,QWORD PTR [rsp+0x38]
    5d83:	mov    r15,QWORD PTR [rsp+0x40]
    5d88:	add    rsp,0x50
    5d8c:	mov    rsp,rbp
    5d8f:	pop    rbp
    5d90:	ret
    5d91:	mov    QWORD PTR [r15],r14
    5d94:	mov    QWORD PTR [r15+0x8],r13
    5d98:	mov    rsi,QWORD PTR [rsp+0x8]
    5d9d:	mov    QWORD PTR [r15+0x10],rsi
    5da1:	sar    r12,1
    5da4:	add    r12,0x1
    5dab:	shl    r12,1
    5dae:	or     r12,0x1
    5db2:	mov    QWORD PTR [r15+0x18],r12
    5db6:	mov    r8,r12
    5db9:	jmp    5b78 <botlish_fn_52+0x60>
    5dbe:	mov    rdi,QWORD PTR [rsp]
    5dc2:	mov    QWORD PTR [rdi],r15
    5dc5:	mov    rax,r14
    5dc8:	mov    rbx,QWORD PTR [rsp+0x20]
    5dcd:	mov    r12,QWORD PTR [rsp+0x28]
    5dd2:	mov    r13,QWORD PTR [rsp+0x30]
    5dd7:	mov    r14,QWORD PTR [rsp+0x38]
    5ddc:	mov    r15,QWORD PTR [rsp+0x40]
    5de1:	add    rsp,0x50
    5de5:	mov    rsp,rbp
    5de8:	pop    rbp
    5de9:	ret
    5dea:	mov    QWORD PTR [rsp],rdi
    5dee:	call   5df3 <botlish_fn_52+0x2db>
			5def: R_X86_64_PLT32	rt_stack_overflow-0x4
    5df3:	xor    rax,rax
    5df6:	mov    rbx,QWORD PTR [rsp+0x20]
    5dfb:	mov    r12,QWORD PTR [rsp+0x28]
    5e00:	mov    r13,QWORD PTR [rsp+0x30]
    5e05:	mov    r14,QWORD PTR [rsp+0x38]
    5e0a:	mov    r15,QWORD PTR [rsp+0x40]
    5e0f:	add    rsp,0x50
    5e13:	mov    rsp,rbp
    5e16:	pop    rbp
    5e17:	ret
    5e18:	(bad)
    5e19:	add    BYTE PTR [rax],al
    5e1b:	add    BYTE PTR [rax],al
    5e1d:	add    BYTE PTR [rax],al
	...

0000000000005e20 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    5e20:	push   rbp
    5e21:	mov    rbp,rsp
    5e24:	mov    rsi,QWORD PTR [rdx]
    5e27:	mov    r10,QWORD PTR [rdx+0x8]
    5e2b:	mov    rcx,QWORD PTR [rdx+0x10]
    5e2f:	mov    r8,QWORD PTR [rdx+0x18]
    5e33:	mov    r9,QWORD PTR [rdx+0x20]
    5e37:	mov    rdx,r10
    5e3a:	call   5e3f <botlish_entry_52+0x1f>
			5e3b: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    5e3f:	mov    rsp,rbp
    5e42:	pop    rbp
    5e43:	ret

0000000000005e44 <botlish_fn_53: row_table<any, int, any, bool>>:
    5e44:	push   rbp
    5e45:	mov    rbp,rsp
    5e48:	sub    rsp,0x30
    5e4c:	mov    QWORD PTR [rsp],rbx
    5e50:	mov    QWORD PTR [rsp+0x8],r12
    5e55:	mov    QWORD PTR [rsp+0x10],r13
    5e5a:	mov    QWORD PTR [rsp+0x18],r14
    5e5f:	mov    QWORD PTR [rsp+0x20],r15
    5e64:	mov    rbx,QWORD PTR [rdi]
    5e67:	mov    rax,QWORD PTR [rdi+0x8]
    5e6b:	lea    r9,[rbx+0x28]
    5e6f:	cmp    r9,rax
    5e72:	ja     5f9e <botlish_fn_53+0x15a>
    5e78:	lea    rax,[rbx+0x28]
    5e7c:	mov    QWORD PTR [rdi],rax
    5e7f:	mov    r12,rdi
    5e82:	mov    QWORD PTR [rbx+0x20],0x0
    5e8a:	mov    QWORD PTR [rbx],rsi
    5e8d:	mov    r14,rsi
    5e90:	mov    QWORD PTR [rbx+0x8],rdx
    5e94:	mov    QWORD PTR [rbx+0x10],rcx
    5e98:	mov    r13,rcx
    5e9b:	mov    QWORD PTR [rbx+0x18],r8
    5e9f:	mov    rsi,r8
    5ea2:	mov    rdi,r12
    5ea5:	call   5eaa <botlish_fn_53+0x66>
			5ea6: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    5eaa:	test   rax,rax
    5ead:	jne    5ebb <botlish_fn_53+0x77>
    5eb3:	mov    rdi,r12
    5eb6:	jmp    5f4d <botlish_fn_53+0x109>
    5ebb:	mov    QWORD PTR [rbx+0x8],rax
    5ebf:	mov    r15,rax
    5ec2:	mov    QWORD PTR [rbx+0x18],0x1
    5eca:	xor    ecx,ecx
    5ecc:	mov    rdx,r13
    5ecf:	test   rdx,0x7
    5ed6:	je     5ee4 <botlish_fn_53+0xa0>
    5edc:	mov    r13,rdx
    5edf:	jmp    5ef0 <botlish_fn_53+0xac>
    5ee4:	movzx  rax,BYTE PTR [rdx]
    5ee8:	mov    r13,rdx
    5eeb:	cmp    al,0x3
    5eed:	sete   cl
    5ef0:	test   cl,cl
    5ef2:	jne    5f18 <botlish_fn_53+0xd4>
    5ef8:	mov    rdi,r12
    5efb:	mov    rax,QWORD PTR [rdi+0x10]
    5eff:	mov    rcx,QWORD PTR [rax+0x58]
    5f03:	mov    edx,0x4
    5f08:	mov    rsi,r13
    5f0b:	call   5f10 <botlish_fn_53+0xcc>
			5f0c: R_X86_64_PLT32	rt_type_error-0x4
    5f10:	mov    rdi,r12
    5f13:	jmp    5f4d <botlish_fn_53+0x109>
    5f18:	mov    rsi,r13
    5f1b:	mov    rdi,r12
    5f1e:	call   5f23 <botlish_fn_53+0xdf>
			5f1f: R_X86_64_PLT32	rt_list_len-0x4
    5f23:	mov    QWORD PTR [rbx+0x20],rax
    5f27:	mov    r8d,0x1
    5f2d:	mov    rcx,r13
    5f30:	mov    rdx,r14
    5f33:	mov    rsi,r15
    5f36:	mov    r9,rax
    5f39:	mov    rdi,r12
    5f3c:	call   5f41 <botlish_fn_53+0xfd>
			5f3d: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    5f41:	test   rax,rax
    5f44:	jne    5f77 <botlish_fn_53+0x133>
    5f4a:	mov    rdi,r12
    5f4d:	mov    rdi,r12
    5f50:	mov    QWORD PTR [rdi],rbx
    5f53:	xor    rax,rax
    5f56:	mov    rbx,QWORD PTR [rsp]
    5f5a:	mov    r12,QWORD PTR [rsp+0x8]
    5f5f:	mov    r13,QWORD PTR [rsp+0x10]
    5f64:	mov    r14,QWORD PTR [rsp+0x18]
    5f69:	mov    r15,QWORD PTR [rsp+0x20]
    5f6e:	add    rsp,0x30
    5f72:	mov    rsp,rbp
    5f75:	pop    rbp
    5f76:	ret
    5f77:	mov    rdi,r12
    5f7a:	mov    QWORD PTR [rdi],rbx
    5f7d:	mov    rbx,QWORD PTR [rsp]
    5f81:	mov    r12,QWORD PTR [rsp+0x8]
    5f86:	mov    r13,QWORD PTR [rsp+0x10]
    5f8b:	mov    r14,QWORD PTR [rsp+0x18]
    5f90:	mov    r15,QWORD PTR [rsp+0x20]
    5f95:	add    rsp,0x30
    5f99:	mov    rsp,rbp
    5f9c:	pop    rbp
    5f9d:	ret
    5f9e:	mov    r12,rdi
    5fa1:	call   5fa6 <botlish_fn_53+0x162>
			5fa2: R_X86_64_PLT32	rt_stack_overflow-0x4
    5fa6:	xor    rax,rax
    5fa9:	mov    rbx,QWORD PTR [rsp]
    5fad:	mov    r12,QWORD PTR [rsp+0x8]
    5fb2:	mov    r13,QWORD PTR [rsp+0x10]
    5fb7:	mov    r14,QWORD PTR [rsp+0x18]
    5fbc:	mov    r15,QWORD PTR [rsp+0x20]
    5fc1:	add    rsp,0x30
    5fc5:	mov    rsp,rbp
    5fc8:	pop    rbp
    5fc9:	ret

0000000000005fca <botlish_entry_53: row_table<any, int, any, bool>>:
    5fca:	push   rbp
    5fcb:	mov    rbp,rsp
    5fce:	mov    rsi,QWORD PTR [rdx]
    5fd1:	mov    r9,QWORD PTR [rdx+0x8]
    5fd5:	mov    rcx,QWORD PTR [rdx+0x10]
    5fd9:	mov    r8,QWORD PTR [rdx+0x18]
    5fdd:	mov    rdx,r9
    5fe0:	call   5fe5 <botlish_entry_53+0x1b>
			5fe1: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    5fe5:	mov    rsp,rbp
    5fe8:	pop    rbp
    5fe9:	ret
    5fea:	add    BYTE PTR [rax],al
    5fec:	add    BYTE PTR [rax],al
	...

0000000000005ff0 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    5ff0:	push   rbp
    5ff1:	mov    rbp,rsp
    5ff4:	sub    rsp,0x50
    5ff8:	mov    QWORD PTR [rsp+0x20],rbx
    5ffd:	mov    QWORD PTR [rsp+0x28],r12
    6002:	mov    QWORD PTR [rsp+0x30],r13
    6007:	mov    QWORD PTR [rsp+0x38],r14
    600c:	mov    QWORD PTR [rsp+0x40],r15
    6011:	mov    QWORD PTR [rsp+0x8],r8
    6016:	mov    r11,QWORD PTR [rbp+0x10]
    601a:	mov    r12,QWORD PTR [rbp+0x18]
    601e:	mov    r15,r12
    6021:	mov    r12,QWORD PTR [rdi]
    6024:	mov    rax,QWORD PTR [rdi+0x8]
    6028:	lea    r8,[r12+0x40]
    602d:	cmp    r8,rax
    6030:	ja     626e <botlish_fn_54+0x27e>
    6036:	lea    rax,[r12+0x40]
    603b:	mov    QWORD PTR [rdi],rax
    603e:	mov    QWORD PTR [rsp],rdi
    6042:	mov    QWORD PTR [r12+0x30],0x0
    604b:	mov    QWORD PTR [r12+0x38],0x0
    6054:	mov    QWORD PTR [r12],rsi
    6058:	mov    QWORD PTR [r12+0x8],rdx
    605d:	mov    rbx,rdx
    6060:	mov    QWORD PTR [r12+0x10],rcx
    6065:	mov    r14,rcx
    6068:	mov    QWORD PTR [r12+0x18],r9
    606d:	mov    QWORD PTR [r12+0x20],r11
    6072:	mov    rax,r15
    6075:	mov    QWORD PTR [rsp+0x18],r11
    607a:	mov    QWORD PTR [r12+0x28],rax
    607f:	mov    r13,rsi
    6082:	mov    QWORD PTR [rsp+0x10],r9
    6087:	mov    rsi,r13
    608a:	mov    rdi,QWORD PTR [rsp]
    608e:	call   6093 <botlish_fn_54+0xa3>
			608f: R_X86_64_PLT32	rt_list_len-0x4
    6093:	mov    rcx,rbx
    6096:	and    rcx,rax
    6099:	mov    rdx,rax
    609c:	test   rcx,0x1
    60a3:	jne    60ca <botlish_fn_54+0xda>
    60a9:	mov    rsi,rbx
    60ac:	mov    rdi,QWORD PTR [rsp]
    60b0:	call   60b5 <botlish_fn_54+0xc5>
			60b1: R_X86_64_PLT32	rt_int_cmp-0x4
    60b5:	mov    ecx,0x2
    60ba:	test   rax,rax
    60bd:	cmovge rcx,QWORD PTR [rip+0x1db]        # 62a0 <botlish_fn_54+0x2b0>
    60c5:	jmp    60da <botlish_fn_54+0xea>
    60ca:	mov    ecx,0x2
    60cf:	cmp    rbx,rdx
    60d2:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 62a0 <botlish_fn_54+0x2b0>
    60da:	cmp    rcx,0x6
    60de:	je     61f9 <botlish_fn_54+0x209>
    60e4:	mov    rcx,QWORD PTR [rsp+0x8]
    60e9:	mov    rsi,rcx
    60ec:	or     rsi,0x1
    60f0:	mov    QWORD PTR [r12+0x30],rsi
    60f5:	test   rbx,0x1
    60fc:	je     6115 <botlish_fn_54+0x125>
    6102:	mov    r9,QWORD PTR [r13+0x8]
    6106:	mov    r8,rbx
    6109:	sar    r8,1
    610c:	cmp    r8,r9
    610f:	jb     613e <botlish_fn_54+0x14e>
    6115:	mov    rdx,rbx
    6118:	mov    rsi,r13
    611b:	mov    rdi,QWORD PTR [rsp]
    611f:	call   6124 <botlish_fn_54+0x134>
			6120: R_X86_64_PLT32	rt_list_get-0x4
    6124:	test   rax,rax
    6127:	jne    6136 <botlish_fn_54+0x146>
    612d:	mov    rdi,QWORD PTR [rsp]
    6131:	jmp    6219 <botlish_fn_54+0x229>
    6136:	mov    rcx,rax
    6139:	jmp    6146 <botlish_fn_54+0x156>
    613e:	mov    rax,QWORD PTR [r13+0x10]
    6142:	mov    rcx,QWORD PTR [rax+r8*8]
    6146:	mov    QWORD PTR [r12+0x38],rcx
    614b:	mov    rax,QWORD PTR [rsp+0x8]
    6150:	mov    rdx,rax
    6153:	or     rdx,0x1
    6157:	mov    rax,r14
    615a:	mov    r14,r15
    615d:	mov    r15,rax
    6160:	mov    rsi,r15
    6163:	mov    rdi,QWORD PTR [rsp]
    6167:	mov    r8,r14
    616a:	call   616f <botlish_fn_54+0x17f>
			616b: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    616f:	test   rax,rax
    6172:	jne    6181 <botlish_fn_54+0x191>
    6178:	mov    rdi,QWORD PTR [rsp]
    617c:	jmp    6219 <botlish_fn_54+0x229>
    6181:	mov    QWORD PTR [r12+0x8],rax
    6186:	mov    rcx,rax
    6189:	sar    rbx,1
    618c:	add    rbx,0x1
    6193:	shl    rbx,1
    6196:	or     rbx,0x1
    619a:	mov    QWORD PTR [r12+0x30],rbx
    619f:	mov    rdx,QWORD PTR [rsp+0x18]
    61a4:	mov    rsi,QWORD PTR [rsp+0x10]
    61a9:	mov    rdi,QWORD PTR [rsp]
    61ad:	call   61b2 <botlish_fn_54+0x1c2>
			61ae: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    61b2:	test   rax,rax
    61b5:	jne    61c4 <botlish_fn_54+0x1d4>
    61bb:	mov    rdi,QWORD PTR [rsp]
    61bf:	jmp    6219 <botlish_fn_54+0x229>
    61c4:	mov    QWORD PTR [r12],r13
    61c8:	mov    QWORD PTR [r12+0x8],rbx
    61cd:	mov    QWORD PTR [r12+0x10],r15
    61d2:	mov    QWORD PTR [r12+0x18],rax
    61d7:	mov    QWORD PTR [r12+0x20],rdx
    61dc:	mov    QWORD PTR [r12+0x28],r14
    61e1:	mov    QWORD PTR [rsp+0x18],rdx
    61e6:	mov    QWORD PTR [rsp+0x10],rax
    61eb:	mov    rcx,r14
    61ee:	mov    r14,r15
    61f1:	mov    r15,rcx
    61f4:	jmp    6087 <botlish_fn_54+0x97>
    61f9:	mov    rdx,QWORD PTR [rsp+0x18]
    61fe:	mov    rsi,QWORD PTR [rsp+0x10]
    6203:	mov    rdi,QWORD PTR [rsp]
    6207:	call   620c <botlish_fn_54+0x21c>
			6208: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    620c:	test   rax,rax
    620f:	jne    6245 <botlish_fn_54+0x255>
    6215:	mov    rdi,QWORD PTR [rsp]
    6219:	mov    rdi,QWORD PTR [rsp]
    621d:	mov    QWORD PTR [rdi],r12
    6220:	xor    rax,rax
    6223:	mov    rbx,QWORD PTR [rsp+0x20]
    6228:	mov    r12,QWORD PTR [rsp+0x28]
    622d:	mov    r13,QWORD PTR [rsp+0x30]
    6232:	mov    r14,QWORD PTR [rsp+0x38]
    6237:	mov    r15,QWORD PTR [rsp+0x40]
    623c:	add    rsp,0x50
    6240:	mov    rsp,rbp
    6243:	pop    rbp
    6244:	ret
    6245:	mov    rdi,QWORD PTR [rsp]
    6249:	mov    QWORD PTR [rdi],r12
    624c:	mov    rbx,QWORD PTR [rsp+0x20]
    6251:	mov    r12,QWORD PTR [rsp+0x28]
    6256:	mov    r13,QWORD PTR [rsp+0x30]
    625b:	mov    r14,QWORD PTR [rsp+0x38]
    6260:	mov    r15,QWORD PTR [rsp+0x40]
    6265:	add    rsp,0x50
    6269:	mov    rsp,rbp
    626c:	pop    rbp
    626d:	ret
    626e:	mov    QWORD PTR [rsp],rdi
    6272:	call   6277 <botlish_fn_54+0x287>
			6273: R_X86_64_PLT32	rt_stack_overflow-0x4
    6277:	xor    rax,rax
    627a:	mov    rbx,QWORD PTR [rsp+0x20]
    627f:	mov    r12,QWORD PTR [rsp+0x28]
    6284:	mov    r13,QWORD PTR [rsp+0x30]
    6289:	mov    r14,QWORD PTR [rsp+0x38]
    628e:	mov    r15,QWORD PTR [rsp+0x40]
    6293:	add    rsp,0x50
    6297:	mov    rsp,rbp
    629a:	pop    rbp
    629b:	ret
    629c:	add    BYTE PTR [rax],al
    629e:	add    BYTE PTR [rax],al
    62a0:	(bad)
    62a1:	add    BYTE PTR [rax],al
    62a3:	add    BYTE PTR [rax],al
    62a5:	add    BYTE PTR [rax],al
	...

00000000000062a8 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    62a8:	push   rbp
    62a9:	mov    rbp,rsp
    62ac:	sub    rsp,0x10
    62b0:	mov    rsi,QWORD PTR [rdx]
    62b3:	mov    r10,QWORD PTR [rdx+0x8]
    62b7:	mov    rcx,QWORD PTR [rdx+0x10]
    62bb:	mov    r8,QWORD PTR [rdx+0x18]
    62bf:	mov    r9,QWORD PTR [rdx+0x20]
    62c3:	mov    r11,QWORD PTR [rdx+0x28]
    62c7:	mov    rax,QWORD PTR [rdx+0x30]
    62cb:	mov    QWORD PTR [rsp],r11
    62cf:	mov    QWORD PTR [rsp+0x8],rax
    62d4:	mov    rdx,r10
    62d7:	call   62dc <botlish_entry_54+0x34>
			62d8: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    62dc:	add    rsp,0x10
    62e0:	mov    rsp,rbp
    62e3:	pop    rbp
    62e4:	ret

00000000000062e5 <botlish_fn_55: csv_records_generic<str, bool>>:
    62e5:	push   rbp
    62e6:	mov    rbp,rsp
    62e9:	sub    rsp,0x50
    62ed:	mov    QWORD PTR [rsp+0x20],rbx
    62f2:	mov    QWORD PTR [rsp+0x28],r12
    62f7:	mov    QWORD PTR [rsp+0x30],r13
    62fc:	mov    QWORD PTR [rsp+0x38],r14
    6301:	mov    QWORD PTR [rsp+0x40],r15
    6306:	mov    rbx,QWORD PTR [rdi]
    6309:	mov    rax,QWORD PTR [rdi+0x8]
    630d:	lea    rcx,[rbx+0x38]
    6311:	cmp    rcx,rax
    6314:	ja     6528 <botlish_fn_55+0x243>
    631a:	lea    rax,[rbx+0x38]
    631e:	mov    QWORD PTR [rdi],rax
    6321:	mov    r12,rdi
    6324:	mov    QWORD PTR [rbx+0x10],0x0
    632c:	mov    QWORD PTR [rbx+0x18],0x0
    6334:	mov    QWORD PTR [rbx+0x20],0x0
    633c:	mov    QWORD PTR [rbx+0x28],0x0
    6344:	mov    QWORD PTR [rbx+0x30],0x0
    634c:	mov    QWORD PTR [rbx],rsi
    634f:	mov    QWORD PTR [rbx+0x8],rdx
    6353:	mov    r13,rdx
    6356:	mov    rdi,r12
    6359:	call   635e <botlish_fn_55+0x79>
			635a: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    635e:	mov    rcx,rax
    6361:	mov    r14,rax
    6364:	test   rax,rcx
    6367:	jne    6375 <botlish_fn_55+0x90>
    636d:	mov    rdi,r12
    6370:	jmp    64d5 <botlish_fn_55+0x1f0>
    6375:	mov    rax,r14
    6378:	mov    QWORD PTR [rbx],rax
    637b:	mov    rsi,r14
    637e:	mov    rdi,r12
    6381:	call   6386 <botlish_fn_55+0xa1>
			6382: R_X86_64_PLT32	rt_list_len-0x4
    6386:	sar    rax,1
    6389:	test   rax,rax
    638c:	je     64bb <botlish_fn_55+0x1d6>
    6392:	mov    rax,r14
    6395:	mov    rax,QWORD PTR [rax+0x8]
    6399:	test   rax,rax
    639c:	jne    63cb <botlish_fn_55+0xe6>
    63a2:	mov    edx,0x1
    63a7:	mov    rsi,r14
    63aa:	mov    rdi,r12
    63ad:	call   63b2 <botlish_fn_55+0xcd>
			63ae: R_X86_64_PLT32	rt_list_get-0x4
    63b2:	test   rax,rax
    63b5:	jne    63c3 <botlish_fn_55+0xde>
    63bb:	mov    rdi,r12
    63be:	jmp    64d5 <botlish_fn_55+0x1f0>
    63c3:	mov    rsi,rax
    63c6:	jmp    63d8 <botlish_fn_55+0xf3>
    63cb:	mov    rax,r14
    63ce:	mov    rcx,QWORD PTR [rax+0x10]
    63d2:	mov    rax,QWORD PTR [rcx]
    63d5:	mov    rsi,rax
    63d8:	mov    QWORD PTR [rbx+0x10],rsi
    63dc:	mov    QWORD PTR [rbx+0x18],0x3
    63e4:	xor    eax,eax
    63e6:	test   rsi,0x7
    63ed:	jne    63fe <botlish_fn_55+0x119>
    63f3:	movzx  rdi,BYTE PTR [rsi]
    63f7:	cmp    dil,0x3
    63fb:	sete   al
    63fe:	test   al,al
    6400:	jne    6423 <botlish_fn_55+0x13e>
    6406:	mov    rdi,r12
    6409:	mov    r10,QWORD PTR [rdi+0x10]
    640d:	mov    rcx,QWORD PTR [r10+0x58]
    6411:	mov    edx,0x4
    6416:	call   641b <botlish_fn_55+0x136>
			6417: R_X86_64_PLT32	rt_type_error-0x4
    641b:	mov    rdi,r12
    641e:	jmp    64d5 <botlish_fn_55+0x1f0>
    6423:	mov    r15,rsi
    6426:	mov    rdi,r12
    6429:	call   642e <botlish_fn_55+0x149>
			642a: R_X86_64_PLT32	rt_list_len-0x4
    642e:	mov    QWORD PTR [rbx+0x20],rax
    6432:	mov    QWORD PTR [rsp+0x10],rax
    6437:	mov    rdi,r12
    643a:	call   643f <botlish_fn_55+0x15a>
			643b: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    643f:	test   rax,rax
    6442:	jne    6450 <botlish_fn_55+0x16b>
    6448:	mov    rdi,r12
    644b:	jmp    64d5 <botlish_fn_55+0x1f0>
    6450:	mov    QWORD PTR [rbx+0x28],rax
    6454:	mov    r9,rax
    6457:	mov    QWORD PTR [rbx+0x30],rdx
    645b:	mov    rsi,rdx
    645e:	mov    edx,0x3
    6463:	mov    QWORD PTR [rsp],rsi
    6467:	mov    rax,r13
    646a:	mov    QWORD PTR [rsp+0x8],rax
    646f:	mov    rcx,r15
    6472:	mov    rsi,r14
    6475:	mov    r8,QWORD PTR [rsp+0x10]
    647a:	mov    rdi,r12
    647d:	call   6482 <botlish_fn_55+0x19d>
			647e: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    6482:	test   rax,rax
    6485:	jne    6493 <botlish_fn_55+0x1ae>
    648b:	mov    rdi,r12
    648e:	jmp    64d5 <botlish_fn_55+0x1f0>
    6493:	mov    rdi,r12
    6496:	mov    QWORD PTR [rdi],rbx
    6499:	mov    rbx,QWORD PTR [rsp+0x20]
    649e:	mov    r12,QWORD PTR [rsp+0x28]
    64a3:	mov    r13,QWORD PTR [rsp+0x30]
    64a8:	mov    r14,QWORD PTR [rsp+0x38]
    64ad:	mov    r15,QWORD PTR [rsp+0x40]
    64b2:	add    rsp,0x50
    64b6:	mov    rsp,rbp
    64b9:	pop    rbp
    64ba:	ret
    64bb:	xor    rdx,rdx
    64be:	mov    rdi,r12
    64c1:	mov    rsi,rdx
    64c4:	call   64c9 <botlish_fn_55+0x1e4>
			64c5: R_X86_64_PLT32	rt_list_new-0x4
    64c9:	test   rax,rax
    64cc:	jne    6500 <botlish_fn_55+0x21b>
    64d2:	mov    rdi,r12
    64d5:	mov    rdi,r12
    64d8:	mov    QWORD PTR [rdi],rbx
    64db:	xor    rax,rax
    64de:	mov    rbx,QWORD PTR [rsp+0x20]
    64e3:	mov    r12,QWORD PTR [rsp+0x28]
    64e8:	mov    r13,QWORD PTR [rsp+0x30]
    64ed:	mov    r14,QWORD PTR [rsp+0x38]
    64f2:	mov    r15,QWORD PTR [rsp+0x40]
    64f7:	add    rsp,0x50
    64fb:	mov    rsp,rbp
    64fe:	pop    rbp
    64ff:	ret
    6500:	mov    rdi,r12
    6503:	mov    QWORD PTR [rdi],rbx
    6506:	mov    rbx,QWORD PTR [rsp+0x20]
    650b:	mov    r12,QWORD PTR [rsp+0x28]
    6510:	mov    r13,QWORD PTR [rsp+0x30]
    6515:	mov    r14,QWORD PTR [rsp+0x38]
    651a:	mov    r15,QWORD PTR [rsp+0x40]
    651f:	add    rsp,0x50
    6523:	mov    rsp,rbp
    6526:	pop    rbp
    6527:	ret
    6528:	mov    r12,rdi
    652b:	call   6530 <botlish_fn_55+0x24b>
			652c: R_X86_64_PLT32	rt_stack_overflow-0x4
    6530:	xor    rax,rax
    6533:	mov    rbx,QWORD PTR [rsp+0x20]
    6538:	mov    r12,QWORD PTR [rsp+0x28]
    653d:	mov    r13,QWORD PTR [rsp+0x30]
    6542:	mov    r14,QWORD PTR [rsp+0x38]
    6547:	mov    r15,QWORD PTR [rsp+0x40]
    654c:	add    rsp,0x50
    6550:	mov    rsp,rbp
    6553:	pop    rbp
    6554:	ret

0000000000006555 <botlish_entry_55: csv_records_generic<str, bool>>:
    6555:	push   rbp
    6556:	mov    rbp,rsp
    6559:	mov    rsi,QWORD PTR [rdx]
    655c:	mov    rdx,QWORD PTR [rdx+0x8]
    6560:	call   6565 <botlish_entry_55+0x10>
			6561: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6565:	mov    rsp,rbp
    6568:	pop    rbp
    6569:	ret

000000000000656a <botlish_fn_56: csv_records<str>>:
    656a:	push   rbp
    656b:	mov    rbp,rsp
    656e:	sub    rsp,0x10
    6572:	mov    QWORD PTR [rsp],r13
    6576:	mov    QWORD PTR [rsp+0x8],r14
    657b:	mov    r13,QWORD PTR [rdi]
    657e:	mov    rax,QWORD PTR [rdi+0x8]
    6582:	lea    rcx,[r13+0x10]
    6586:	cmp    rcx,rax
    6589:	ja     65ee <botlish_fn_56+0x84>
    658f:	lea    rax,[r13+0x10]
    6593:	mov    QWORD PTR [rdi],rax
    6596:	mov    r14,rdi
    6599:	mov    QWORD PTR [r13+0x0],rsi
    659d:	mov    edx,0x2
    65a2:	mov    QWORD PTR [r13+0x8],0x2
    65aa:	mov    rdi,r14
    65ad:	call   65b2 <botlish_fn_56+0x48>
			65ae: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    65b2:	test   rax,rax
    65b5:	jne    65d6 <botlish_fn_56+0x6c>
    65bb:	mov    rdi,r14
    65be:	mov    QWORD PTR [rdi],r13
    65c1:	xor    rax,rax
    65c4:	mov    r13,QWORD PTR [rsp]
    65c8:	mov    r14,QWORD PTR [rsp+0x8]
    65cd:	add    rsp,0x10
    65d1:	mov    rsp,rbp
    65d4:	pop    rbp
    65d5:	ret
    65d6:	mov    rdi,r14
    65d9:	mov    QWORD PTR [rdi],r13
    65dc:	mov    r13,QWORD PTR [rsp]
    65e0:	mov    r14,QWORD PTR [rsp+0x8]
    65e5:	add    rsp,0x10
    65e9:	mov    rsp,rbp
    65ec:	pop    rbp
    65ed:	ret
    65ee:	call   65f3 <botlish_fn_56+0x89>
			65ef: R_X86_64_PLT32	rt_stack_overflow-0x4
    65f3:	xor    rax,rax
    65f6:	mov    r13,QWORD PTR [rsp]
    65fa:	mov    r14,QWORD PTR [rsp+0x8]
    65ff:	add    rsp,0x10
    6603:	mov    rsp,rbp
    6606:	pop    rbp
    6607:	ret

0000000000006608 <botlish_entry_56: csv_records<str>>:
    6608:	push   rbp
    6609:	mov    rbp,rsp
    660c:	mov    rsi,QWORD PTR [rdx]
    660f:	call   6614 <botlish_entry_56+0xc>
			6610: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6614:	mov    rsp,rbp
    6617:	pop    rbp
    6618:	ret

0000000000006619 <botlish_fn_57: csv_records_presized<str>>:
    6619:	push   rbp
    661a:	mov    rbp,rsp
    661d:	sub    rsp,0x10
    6621:	mov    QWORD PTR [rsp],r13
    6625:	mov    QWORD PTR [rsp+0x8],r14
    662a:	mov    r13,QWORD PTR [rdi]
    662d:	mov    rax,QWORD PTR [rdi+0x8]
    6631:	lea    rcx,[r13+0x10]
    6635:	cmp    rcx,rax
    6638:	ja     669d <botlish_fn_57+0x84>
    663e:	lea    rax,[r13+0x10]
    6642:	mov    QWORD PTR [rdi],rax
    6645:	mov    r14,rdi
    6648:	mov    QWORD PTR [r13+0x0],rsi
    664c:	mov    edx,0x6
    6651:	mov    QWORD PTR [r13+0x8],0x6
    6659:	mov    rdi,r14
    665c:	call   6661 <botlish_fn_57+0x48>
			665d: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6661:	test   rax,rax
    6664:	jne    6685 <botlish_fn_57+0x6c>
    666a:	mov    rdi,r14
    666d:	mov    QWORD PTR [rdi],r13
    6670:	xor    rax,rax
    6673:	mov    r13,QWORD PTR [rsp]
    6677:	mov    r14,QWORD PTR [rsp+0x8]
    667c:	add    rsp,0x10
    6680:	mov    rsp,rbp
    6683:	pop    rbp
    6684:	ret
    6685:	mov    rdi,r14
    6688:	mov    QWORD PTR [rdi],r13
    668b:	mov    r13,QWORD PTR [rsp]
    668f:	mov    r14,QWORD PTR [rsp+0x8]
    6694:	add    rsp,0x10
    6698:	mov    rsp,rbp
    669b:	pop    rbp
    669c:	ret
    669d:	call   66a2 <botlish_fn_57+0x89>
			669e: R_X86_64_PLT32	rt_stack_overflow-0x4
    66a2:	xor    rax,rax
    66a5:	mov    r13,QWORD PTR [rsp]
    66a9:	mov    r14,QWORD PTR [rsp+0x8]
    66ae:	add    rsp,0x10
    66b2:	mov    rsp,rbp
    66b5:	pop    rbp
    66b6:	ret

00000000000066b7 <botlish_entry_57: csv_records_presized<str>>:
    66b7:	push   rbp
    66b8:	mov    rbp,rsp
    66bb:	mov    rsi,QWORD PTR [rdx]
    66be:	call   66c3 <botlish_entry_57+0xc>
			66bf: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    66c3:	mov    rsp,rbp
    66c6:	pop    rbp
    66c7:	ret

00000000000066c8 <botlish_fn_58: sample<generic>>:
    66c8:	push   rbp
    66c9:	mov    rbp,rsp
    66cc:	sub    rsp,0x90
    66d3:	mov    QWORD PTR [rsp+0x60],rbx
    66d8:	mov    QWORD PTR [rsp+0x68],r12
    66dd:	mov    QWORD PTR [rsp+0x70],r13
    66e2:	mov    QWORD PTR [rsp+0x78],r14
    66e7:	mov    QWORD PTR [rsp+0x80],r15
    66ef:	mov    r14,QWORD PTR [rdi]
    66f2:	mov    rax,QWORD PTR [rdi+0x8]
    66f6:	lea    rcx,[r14+0x40]
    66fa:	cmp    rcx,rax
    66fd:	ja     6b95 <botlish_fn_58+0x4cd>
    6703:	lea    rax,[r14+0x40]
    6707:	mov    QWORD PTR [rdi],rax
    670a:	mov    QWORD PTR [r14+0x8],0x0
    6712:	mov    QWORD PTR [r14+0x10],0x0
    671a:	mov    QWORD PTR [r14+0x18],0x0
    6722:	mov    QWORD PTR [r14+0x20],0x0
    672a:	mov    QWORD PTR [r14+0x28],0x0
    6732:	mov    QWORD PTR [r14+0x30],0x0
    673a:	mov    QWORD PTR [r14+0x38],0x0
    6742:	mov    rax,QWORD PTR [rdi+0x10]
    6746:	mov    r15,rdi
    6749:	mov    rsi,QWORD PTR [rax+0x60]
    674d:	mov    QWORD PTR [r14],rsi
    6750:	call   6755 <botlish_fn_58+0x8d>
			6751: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6755:	mov    rcx,rax
    6758:	mov    r13,rax
    675b:	test   rax,rcx
    675e:	jne    676c <botlish_fn_58+0xa4>
    6764:	mov    rdi,r15
    6767:	jmp    6b36 <botlish_fn_58+0x46e>
    676c:	mov    rax,r13
    676f:	mov    QWORD PTR [r14],rax
    6772:	mov    rdi,r15
    6775:	mov    rax,QWORD PTR [rdi+0x10]
    6779:	mov    rsi,QWORD PTR [rax+0x60]
    677d:	mov    QWORD PTR [r14+0x8],rsi
    6781:	call   6786 <botlish_fn_58+0xbe>
			6782: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    6786:	mov    r12,rax
    6789:	test   r12,r12
    678c:	jne    679a <botlish_fn_58+0xd2>
    6792:	mov    rdi,r15
    6795:	jmp    6b36 <botlish_fn_58+0x46e>
    679a:	mov    rax,r13
    679d:	mov    rax,QWORD PTR [rax+0x8]
    67a1:	test   rax,rax
    67a4:	jne    67d6 <botlish_fn_58+0x10e>
    67aa:	mov    edx,0x1
    67af:	mov    rsi,r13
    67b2:	mov    rdi,r15
    67b5:	call   67ba <botlish_fn_58+0xf2>
			67b6: R_X86_64_PLT32	rt_list_get-0x4
    67ba:	test   rax,rax
    67bd:	jne    67cb <botlish_fn_58+0x103>
    67c3:	mov    rdi,r15
    67c6:	jmp    6b36 <botlish_fn_58+0x46e>
    67cb:	mov    rbx,r13
    67ce:	mov    rsi,rax
    67d1:	jmp    67e0 <botlish_fn_58+0x118>
    67d6:	mov    rbx,r13
    67d9:	mov    rax,QWORD PTR [rbx+0x10]
    67dd:	mov    rsi,QWORD PTR [rax]
    67e0:	mov    QWORD PTR [r14+0x8],rsi
    67e4:	mov    QWORD PTR [rsp+0x40],rsi
    67e9:	mov    rax,QWORD PTR [rbx+0x8]
    67ed:	cmp    rax,0x1
    67f1:	ja     6823 <botlish_fn_58+0x15b>
    67f7:	mov    edx,0x3
    67fc:	mov    rsi,rbx
    67ff:	mov    rdi,r15
    6802:	call   6807 <botlish_fn_58+0x13f>
			6803: R_X86_64_PLT32	rt_list_get-0x4
    6807:	test   rax,rax
    680a:	jne    6818 <botlish_fn_58+0x150>
    6810:	mov    rdi,r15
    6813:	jmp    6b36 <botlish_fn_58+0x46e>
    6818:	mov    rsi,rax
    681b:	mov    r13,rbx
    681e:	jmp    682e <botlish_fn_58+0x166>
    6823:	mov    rax,QWORD PTR [rbx+0x10]
    6827:	mov    r13,rbx
    682a:	mov    rsi,QWORD PTR [rax+0x8]
    682e:	mov    QWORD PTR [r14+0x10],rsi
    6832:	mov    QWORD PTR [rsp+0x38],rsi
    6837:	mov    rax,QWORD PTR [r12+0x8]
    683c:	mov    rsi,r12
    683f:	test   rax,rax
    6842:	jne    686e <botlish_fn_58+0x1a6>
    6848:	mov    edx,0x1
    684d:	mov    rdi,r15
    6850:	call   6855 <botlish_fn_58+0x18d>
			6851: R_X86_64_PLT32	rt_list_get-0x4
    6855:	test   rax,rax
    6858:	jne    6866 <botlish_fn_58+0x19e>
    685e:	mov    rdi,r15
    6861:	jmp    6b36 <botlish_fn_58+0x46e>
    6866:	mov    rsi,rax
    6869:	jmp    6875 <botlish_fn_58+0x1ad>
    686e:	mov    rax,QWORD PTR [rsi+0x10]
    6872:	mov    rsi,QWORD PTR [rax]
    6875:	mov    QWORD PTR [r14+0x18],rsi
    6879:	mov    rdi,r15
    687c:	mov    r12,rsi
    687f:	mov    rax,QWORD PTR [rdi+0x10]
    6883:	mov    rdx,QWORD PTR [rax+0x68]
    6887:	mov    QWORD PTR [r14+0x20],rdx
    688b:	mov    rsi,QWORD PTR [rsp+0x40]
    6890:	call   6895 <botlish_fn_58+0x1cd>
			6891: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6895:	test   rax,rax
    6898:	jne    68a6 <botlish_fn_58+0x1de>
    689e:	mov    rdi,r15
    68a1:	jmp    6b36 <botlish_fn_58+0x46e>
    68a6:	mov    QWORD PTR [r14+0x20],rax
    68aa:	mov    rbx,rax
    68ad:	mov    rdi,r15
    68b0:	mov    rsi,QWORD PTR [rdi+0x10]
    68b4:	mov    rdx,QWORD PTR [rsi+0x68]
    68b8:	mov    QWORD PTR [r14+0x28],rdx
    68bc:	mov    rsi,r12
    68bf:	call   68c4 <botlish_fn_58+0x1fc>
			68c0: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    68c4:	test   rax,rax
    68c7:	jne    68d5 <botlish_fn_58+0x20d>
    68cd:	mov    rdi,r15
    68d0:	jmp    6b36 <botlish_fn_58+0x46e>
    68d5:	mov    rcx,rbx
    68d8:	mov    rdi,rcx
    68db:	and    rdi,rax
    68de:	mov    rdx,rax
    68e1:	test   rdi,0x1
    68e8:	jne    690a <botlish_fn_58+0x242>
    68ee:	mov    rsi,rbx
    68f1:	mov    rdi,r15
    68f4:	call   68f9 <botlish_fn_58+0x231>
			68f5: R_X86_64_PLT32	rt_value_eq-0x4
    68f9:	test   rax,rax
    68fc:	jne    691d <botlish_fn_58+0x255>
    6902:	mov    rdi,r15
    6905:	jmp    6b36 <botlish_fn_58+0x46e>
    690a:	mov    rsi,rbx
    690d:	mov    eax,0x2
    6912:	cmp    rsi,rdx
    6915:	cmove  rax,QWORD PTR [rip+0x2ab]        # 6bc8 <botlish_fn_58+0x500>
    691d:	mov    ebx,0x6
    6922:	cmp    rax,0x6
    6926:	je     6940 <botlish_fn_58+0x278>
    692c:	mov    ebx,0x2
    6931:	mov    QWORD PTR [r14],0x2
    6938:	mov    rsi,r13
    693b:	jmp    69e1 <botlish_fn_58+0x319>
    6940:	mov    rsi,QWORD PTR [rsp+0x40]
    6945:	mov    rdi,r15
    6948:	call   694d <botlish_fn_58+0x285>
			6949: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    694d:	test   rax,rax
    6950:	jne    695e <botlish_fn_58+0x296>
    6956:	mov    rdi,r15
    6959:	jmp    6b36 <botlish_fn_58+0x46e>
    695e:	mov    QWORD PTR [r14+0x20],rax
    6962:	mov    rsi,r12
    6965:	mov    r12,rax
    6968:	mov    rdi,r15
    696b:	call   6970 <botlish_fn_58+0x2a8>
			696c: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    6970:	test   rax,rax
    6973:	jne    6981 <botlish_fn_58+0x2b9>
    6979:	mov    rdi,r15
    697c:	jmp    6b36 <botlish_fn_58+0x46e>
    6981:	mov    rcx,r12
    6984:	mov    rdx,rcx
    6987:	and    rdx,rax
    698a:	test   rdx,0x1
    6991:	jne    69b6 <botlish_fn_58+0x2ee>
    6997:	mov    rdx,rax
    699a:	mov    rsi,r12
    699d:	mov    rdi,r15
    69a0:	call   69a5 <botlish_fn_58+0x2dd>
			69a1: R_X86_64_PLT32	rt_value_eq-0x4
    69a5:	test   rax,rax
    69a8:	jne    69cc <botlish_fn_58+0x304>
    69ae:	mov    rdi,r15
    69b1:	jmp    6b36 <botlish_fn_58+0x46e>
    69b6:	mov    rdx,rax
    69b9:	mov    rsi,r12
    69bc:	mov    eax,0x2
    69c1:	cmp    rsi,rdx
    69c4:	cmove  rax,QWORD PTR [rip+0x1fc]        # 6bc8 <botlish_fn_58+0x500>
    69cc:	cmp    rax,0x6
    69d0:	je     69db <botlish_fn_58+0x313>
    69d6:	mov    ebx,0x2
    69db:	mov    QWORD PTR [r14],rbx
    69de:	mov    rsi,r13
    69e1:	mov    rdi,r15
    69e4:	call   69e9 <botlish_fn_58+0x321>
			69e5: R_X86_64_PLT32	rt_list_len-0x4
    69e9:	mov    r12,rax
    69ec:	mov    QWORD PTR [r14+0x18],r12
    69f0:	mov    rdi,r15
    69f3:	mov    rax,QWORD PTR [rdi+0x10]
    69f7:	mov    rdx,QWORD PTR [rax+0x68]
    69fb:	mov    QWORD PTR [r14+0x20],rdx
    69ff:	mov    rsi,QWORD PTR [rsp+0x40]
    6a04:	call   6a09 <botlish_fn_58+0x341>
			6a05: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6a09:	mov    r13,rax
    6a0c:	test   r13,r13
    6a0f:	jne    6a1d <botlish_fn_58+0x355>
    6a15:	mov    rdi,r15
    6a18:	jmp    6b36 <botlish_fn_58+0x46e>
    6a1d:	mov    QWORD PTR [r14+0x20],r13
    6a21:	mov    rdi,r15
    6a24:	mov    rax,QWORD PTR [rdi+0x10]
    6a28:	mov    rdx,QWORD PTR [rax+0x70]
    6a2c:	mov    QWORD PTR [r14+0x28],rdx
    6a30:	mov    rsi,QWORD PTR [rsp+0x40]
    6a35:	call   6a3a <botlish_fn_58+0x372>
			6a36: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6a3a:	test   rax,rax
    6a3d:	jne    6a4b <botlish_fn_58+0x383>
    6a43:	mov    rdi,r15
    6a46:	jmp    6b36 <botlish_fn_58+0x46e>
    6a4b:	mov    QWORD PTR [r14+0x28],rax
    6a4f:	mov    rdi,r15
    6a52:	mov    QWORD PTR [rsp+0x50],rax
    6a57:	mov    rax,QWORD PTR [rdi+0x10]
    6a5b:	mov    rdx,QWORD PTR [rax+0x78]
    6a5f:	mov    QWORD PTR [r14+0x30],rdx
    6a63:	mov    rsi,QWORD PTR [rsp+0x40]
    6a68:	call   6a6d <botlish_fn_58+0x3a5>
			6a69: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6a6d:	test   rax,rax
    6a70:	jne    6a7e <botlish_fn_58+0x3b6>
    6a76:	mov    rdi,r15
    6a79:	jmp    6b36 <botlish_fn_58+0x46e>
    6a7e:	mov    QWORD PTR [r14+0x8],rax
    6a82:	mov    rdi,r15
    6a85:	mov    QWORD PTR [rsp+0x48],rax
    6a8a:	mov    rax,QWORD PTR [rdi+0x10]
    6a8e:	mov    rdx,QWORD PTR [rax+0x68]
    6a92:	mov    QWORD PTR [r14+0x30],rdx
    6a96:	mov    rsi,QWORD PTR [rsp+0x38]
    6a9b:	call   6aa0 <botlish_fn_58+0x3d8>
			6a9c: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6aa0:	test   rax,rax
    6aa3:	jne    6ab1 <botlish_fn_58+0x3e9>
    6aa9:	mov    rdi,r15
    6aac:	jmp    6b36 <botlish_fn_58+0x46e>
    6ab1:	mov    QWORD PTR [r14+0x30],rax
    6ab5:	mov    rdi,r15
    6ab8:	mov    QWORD PTR [rsp+0x40],rax
    6abd:	mov    rax,QWORD PTR [rdi+0x10]
    6ac1:	mov    rdx,QWORD PTR [rax+0x78]
    6ac5:	mov    QWORD PTR [r14+0x38],rdx
    6ac9:	mov    rsi,QWORD PTR [rsp+0x38]
    6ace:	call   6ad3 <botlish_fn_58+0x40b>
			6acf: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6ad3:	test   rax,rax
    6ad6:	jne    6ae4 <botlish_fn_58+0x41c>
    6adc:	mov    rdi,r15
    6adf:	jmp    6b36 <botlish_fn_58+0x46e>
    6ae4:	mov    QWORD PTR [r14+0x10],rax
    6ae8:	lea    rdx,[rsp]
    6aec:	mov    QWORD PTR [rsp],r12
    6af0:	mov    QWORD PTR [rsp+0x8],r13
    6af5:	mov    rcx,QWORD PTR [rsp+0x50]
    6afa:	mov    QWORD PTR [rsp+0x10],rcx
    6aff:	mov    rcx,QWORD PTR [rsp+0x48]
    6b04:	mov    QWORD PTR [rsp+0x18],rcx
    6b09:	mov    rcx,QWORD PTR [rsp+0x40]
    6b0e:	mov    QWORD PTR [rsp+0x20],rcx
    6b13:	mov    QWORD PTR [rsp+0x28],rax
    6b18:	mov    QWORD PTR [rsp+0x30],rbx
    6b1d:	mov    esi,0x7
    6b22:	mov    rdi,r15
    6b25:	call   6b2a <botlish_fn_58+0x462>
			6b26: R_X86_64_PLT32	rt_list_new-0x4
    6b2a:	test   rax,rax
    6b2d:	jne    6b67 <botlish_fn_58+0x49f>
    6b33:	mov    rdi,r15
    6b36:	mov    rdi,r15
    6b39:	mov    QWORD PTR [rdi],r14
    6b3c:	xor    rax,rax
    6b3f:	mov    rbx,QWORD PTR [rsp+0x60]
    6b44:	mov    r12,QWORD PTR [rsp+0x68]
    6b49:	mov    r13,QWORD PTR [rsp+0x70]
    6b4e:	mov    r14,QWORD PTR [rsp+0x78]
    6b53:	mov    r15,QWORD PTR [rsp+0x80]
    6b5b:	add    rsp,0x90
    6b62:	mov    rsp,rbp
    6b65:	pop    rbp
    6b66:	ret
    6b67:	mov    rdi,r15
    6b6a:	mov    QWORD PTR [rdi],r14
    6b6d:	mov    rbx,QWORD PTR [rsp+0x60]
    6b72:	mov    r12,QWORD PTR [rsp+0x68]
    6b77:	mov    r13,QWORD PTR [rsp+0x70]
    6b7c:	mov    r14,QWORD PTR [rsp+0x78]
    6b81:	mov    r15,QWORD PTR [rsp+0x80]
    6b89:	add    rsp,0x90
    6b90:	mov    rsp,rbp
    6b93:	pop    rbp
    6b94:	ret
    6b95:	mov    r15,rdi
    6b98:	call   6b9d <botlish_fn_58+0x4d5>
			6b99: R_X86_64_PLT32	rt_stack_overflow-0x4
    6b9d:	xor    rax,rax
    6ba0:	mov    rbx,QWORD PTR [rsp+0x60]
    6ba5:	mov    r12,QWORD PTR [rsp+0x68]
    6baa:	mov    r13,QWORD PTR [rsp+0x70]
    6baf:	mov    r14,QWORD PTR [rsp+0x78]
    6bb4:	mov    r15,QWORD PTR [rsp+0x80]
    6bbc:	add    rsp,0x90
    6bc3:	mov    rsp,rbp
    6bc6:	pop    rbp
    6bc7:	ret
    6bc8:	(bad)
    6bc9:	add    BYTE PTR [rax],al
    6bcb:	add    BYTE PTR [rax],al
    6bcd:	add    BYTE PTR [rax],al
	...

0000000000006bd0 <botlish_entry_58: sample<generic>>:
    6bd0:	push   rbp
    6bd1:	mov    rbp,rsp
    6bd4:	call   6bd9 <botlish_entry_58+0x9>
			6bd5: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    6bd9:	mov    rsp,rbp
    6bdc:	pop    rbp
    6bdd:	ret

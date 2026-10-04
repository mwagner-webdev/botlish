; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23613  (per function: 45 461 461 461 81 81 81 357 412 412 412 278 278 278 81 365 430 585 1141 352 783 215 488 325 388 524 70 493 114 61 61 61 61 61 168 179 245 804 1248 429 380 439 977 766 817 665 1168 836 107 427 259 629 634 78 78 1222 301)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> mutable_array::create<int, str>
;   botlish_fn_2 / botlish_entry_2 -> mutable_array::create<int, List[str]>
;   botlish_fn_3 / botlish_entry_3 -> mutable_array::create<int, mutarray>
;   botlish_fn_4 / botlish_entry_4 -> geo_new<str>
;   botlish_fn_5 / botlish_entry_5 -> geo_new<List[str]>
;   botlish_fn_6 / botlish_entry_6 -> geo_new<mutarray>
;   botlish_fn_7 / botlish_entry_7 -> geo_new_capacity<int, int>
;   botlish_fn_8 / botlish_entry_8 -> geo_grow<mutarray, int, str>
;   botlish_fn_9 / botlish_entry_9 -> geo_grow<mutarray, int, List[str]>
;   botlish_fn_10 / botlish_entry_10 -> geo_grow<mutarray, int, mutarray>
;   botlish_fn_11 / botlish_entry_11 -> geo_append<mutarray, int, str>
;   botlish_fn_12 / botlish_entry_12 -> geo_append<mutarray, int, List[str]>
;   botlish_fn_13 / botlish_entry_13 -> geo_append<mutarray, int, mutarray>
;   botlish_fn_14 / botlish_entry_14 -> geo_finish<mutarray, int>
;   botlish_fn_15 / botlish_entry_15 -> peek<str, int>
;   botlish_fn_16 / botlish_entry_16 -> peek<str, int>
;   botlish_fn_17 / botlish_entry_17 -> scan_unquoted<str, int, int>
;   botlish_fn_18 / botlish_entry_18 -> scan_quoted<str, int, str>
;   botlish_fn_19 / botlish_entry_19 -> scan_field<str, int>
;   botlish_fn_20 / botlish_entry_20 -> scan_record_rest<str, int, mutarray, int>
;   botlish_fn_21 / botlish_entry_21 -> scan_record<str, int>
;   botlish_fn_22 / botlish_entry_22 -> scan_records<str, int, mutarray, int>
;   botlish_fn_23 / botlish_entry_23 -> csv_parse<str>
;   botlish_fn_24 / botlish_entry_24 -> ht_fill_empty<mutarray, int, int>
;   botlish_fn_25 / botlish_entry_25 -> ht_alloc<int>
;   botlish_fn_26 / botlish_entry_26 -> ht_new<generic>
;   botlish_fn_27 / botlish_entry_27 -> ht_capacity_for<int, int>
;   botlish_fn_28 / botlish_entry_28 -> ht_new_sized<int>
;   botlish_fn_29 / botlish_entry_29 -> ht_controls<mutarray>
;   botlish_fn_30 / botlish_entry_30 -> ht_keys<mutarray>
;   botlish_fn_31 / botlish_entry_31 -> ht_values<mutarray>
;   botlish_fn_32 / botlish_entry_32 -> ht_size<mutarray>
;   botlish_fn_33 / botlish_entry_33 -> ht_tombstones<mutarray>
;   botlish_fn_34 / botlish_entry_34 -> ht_capacity<mutarray>
;   botlish_fn_35 / botlish_entry_35 -> ht_probe_start<mutarray, str>
;   botlish_fn_36 / botlish_entry_36 -> ht_probe_next<mutarray, int>
;   botlish_fn_37 / botlish_entry_37 -> ht_find_get<mutarray, str, int>
;   botlish_fn_38 / botlish_entry_38 -> ht_find_insert<mutarray, str, int, int>
;   botlish_fn_39 / botlish_entry_39 -> ht_get<mutarray, str>
;   botlish_fn_40 / botlish_entry_40 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_41 / botlish_entry_41 -> ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
;   botlish_fn_42 / botlish_entry_42 -> ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
;   botlish_fn_43 / botlish_entry_43 -> ht_rehash<mutarray, int>
;   botlish_fn_44 / botlish_entry_44 -> ht_should_grow<mutarray>
;   botlish_fn_45 / botlish_entry_45 -> ht_grow_or_clean<mutarray>
;   botlish_fn_46 / botlish_entry_46 -> ht_place<mutarray, int, str, str>
;   botlish_fn_47 / botlish_entry_47 -> ht_set<mutarray, str, str>
;   botlish_fn_48 / botlish_entry_48 -> row_new<bool, int>
;   botlish_fn_49 / botlish_entry_49 -> row_fill<mutarray, List[str], List[str], int, int>
;   botlish_fn_50 / botlish_entry_50 -> row_table<List[str], int, List[str], bool>
;   botlish_fn_51 / botlish_entry_51 -> build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
;   botlish_fn_52 / botlish_entry_52 -> csv_records_generic<str, bool>
;   botlish_fn_53 / botlish_entry_53 -> csv_records<str>
;   botlish_fn_54 / botlish_entry_54 -> csv_records_presized<str>
;   botlish_fn_55 / botlish_entry_55 -> sample_checks<generic>
;   botlish_fn_56 / botlish_entry_56 -> sample<generic>


csv_records.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_56-0x4 ; sample<generic>
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
      2d:	add    BYTE PTR [rax],al
	...

0000000000000030 <botlish_fn_1: mutable_array::create<int, str>>:
      30:	push   rbp
      31:	mov    rbp,rsp
      34:	sub    rsp,0x60
      38:	mov    QWORD PTR [rsp+0x30],rbx
      3d:	mov    QWORD PTR [rsp+0x38],r12
      42:	mov    QWORD PTR [rsp+0x40],r13
      47:	mov    QWORD PTR [rsp+0x48],r14
      4c:	mov    QWORD PTR [rsp+0x50],r15
      51:	mov    r13,rdi
      54:	mov    QWORD PTR [rsp+0x10],0x0
      5d:	mov    QWORD PTR [rsp+0x18],0x0
      66:	mov    QWORD PTR [rsp+0x20],0x0
      6f:	mov    QWORD PTR [rsp],rsi
      73:	mov    QWORD PTR [rsp+0x8],rdx
      78:	mov    r12,rdx
      7b:	mov    rbx,rsi
      7e:	mov    rdi,r13
      81:	call   86 <botlish_fn_1+0x56>
			82: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      86:	test   rax,rax
      89:	je     13c <botlish_fn_1+0x10c>
      8f:	mov    QWORD PTR [rsp+0x10],rax
      94:	mov    r15,rax
      97:	mov    esi,0x1
      9c:	mov    r14,rsi
      9f:	mov    QWORD PTR [rsp+0x18],0x1
      a8:	mov    rax,rsi
      ab:	and    rax,rbx
      ae:	mov    r14,rsi
      b1:	test   rax,0x1
      b7:	jne    e0 <botlish_fn_1+0xb0>
      bd:	mov    rdx,rbx
      c0:	mov    rsi,r14
      c3:	mov    rdi,r13
      c6:	call   cb <botlish_fn_1+0x9b>
			c7: R_X86_64_PLT32	rt_int_cmp-0x4
      cb:	mov    ecx,0x2
      d0:	test   rax,rax
      d3:	cmovl  rcx,QWORD PTR [rip+0xe5]        # 1c0 <botlish_fn_1+0x190>
      db:	jmp    f3 <botlish_fn_1+0xc3>
      e0:	mov    ecx,0x2
      e5:	mov    rsi,r14
      e8:	cmp    rsi,rbx
      eb:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 1c0 <botlish_fn_1+0x190>
      f3:	cmp    rcx,0x6
      f7:	je     122 <botlish_fn_1+0xf2>
      fd:	mov    rax,r15
     100:	mov    rbx,QWORD PTR [rsp+0x30]
     105:	mov    r12,QWORD PTR [rsp+0x38]
     10a:	mov    r13,QWORD PTR [rsp+0x40]
     10f:	mov    r14,QWORD PTR [rsp+0x48]
     114:	mov    r15,QWORD PTR [rsp+0x50]
     119:	add    rsp,0x60
     11d:	mov    rsp,rbp
     120:	pop    rbp
     121:	ret
     122:	mov    rcx,r12
     125:	mov    rdx,r14
     128:	mov    rsi,r15
     12b:	mov    rdi,r13
     12e:	call   133 <botlish_fn_1+0x103>
			12f: R_X86_64_PLT32	rt_mutarray_set-0x4
     133:	test   rax,rax
     136:	jne    161 <botlish_fn_1+0x131>
     13c:	xor    rax,rax
     13f:	mov    rbx,QWORD PTR [rsp+0x30]
     144:	mov    r12,QWORD PTR [rsp+0x38]
     149:	mov    r13,QWORD PTR [rsp+0x40]
     14e:	mov    r14,QWORD PTR [rsp+0x48]
     153:	mov    r15,QWORD PTR [rsp+0x50]
     158:	add    rsp,0x60
     15c:	mov    rsp,rbp
     15f:	pop    rbp
     160:	ret
     161:	mov    QWORD PTR [rsp+0x20],0x3
     16a:	mov    rsi,r14
     16d:	test   rsi,0x1
     174:	je     19a <botlish_fn_1+0x16a>
     17a:	mov    rsi,r14
     17d:	mov    rcx,rsi
     180:	add    rcx,0x2
     184:	seto   al
     187:	test   al,al
     189:	jne    19a <botlish_fn_1+0x16a>
     18f:	mov    rsi,rcx
     192:	mov    r14,rcx
     195:	jmp    1b0 <botlish_fn_1+0x180>
     19a:	mov    edx,0x3
     19f:	mov    rsi,r14
     1a2:	mov    rdi,r13
     1a5:	call   1aa <botlish_fn_1+0x17a>
			1a6: R_X86_64_PLT32	rt_int_add-0x4
     1aa:	mov    rsi,rax
     1ad:	mov    r14,rax
     1b0:	mov    QWORD PTR [rsp+0x18],rsi
     1b5:	mov    rsi,r14
     1b8:	jmp    a8 <botlish_fn_1+0x78>
     1bd:	add    BYTE PTR [rax],al
     1bf:	add    BYTE PTR [rsi],al
     1c1:	add    BYTE PTR [rax],al
     1c3:	add    BYTE PTR [rax],al
     1c5:	add    BYTE PTR [rax],al
	...

00000000000001c8 <botlish_entry_1: mutable_array::create<int, str>>:
     1c8:	push   rbp
     1c9:	mov    rbp,rsp
     1cc:	mov    rsi,QWORD PTR [rdx]
     1cf:	mov    rdx,QWORD PTR [rdx+0x8]
     1d3:	call   1d8 <botlish_entry_1+0x10>
			1d4: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     1d8:	mov    rsp,rbp
     1db:	pop    rbp
     1dc:	ret
     1dd:	add    BYTE PTR [rax],al
	...

00000000000001e0 <botlish_fn_2: mutable_array::create<int, List[str]>>:
     1e0:	push   rbp
     1e1:	mov    rbp,rsp
     1e4:	sub    rsp,0x60
     1e8:	mov    QWORD PTR [rsp+0x30],rbx
     1ed:	mov    QWORD PTR [rsp+0x38],r12
     1f2:	mov    QWORD PTR [rsp+0x40],r13
     1f7:	mov    QWORD PTR [rsp+0x48],r14
     1fc:	mov    QWORD PTR [rsp+0x50],r15
     201:	mov    r13,rdi
     204:	mov    QWORD PTR [rsp+0x10],0x0
     20d:	mov    QWORD PTR [rsp+0x18],0x0
     216:	mov    QWORD PTR [rsp+0x20],0x0
     21f:	mov    QWORD PTR [rsp],rsi
     223:	mov    QWORD PTR [rsp+0x8],rdx
     228:	mov    r12,rdx
     22b:	mov    rbx,rsi
     22e:	mov    rdi,r13
     231:	call   236 <botlish_fn_2+0x56>
			232: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     236:	test   rax,rax
     239:	je     2ec <botlish_fn_2+0x10c>
     23f:	mov    QWORD PTR [rsp+0x10],rax
     244:	mov    r15,rax
     247:	mov    esi,0x1
     24c:	mov    r14,rsi
     24f:	mov    QWORD PTR [rsp+0x18],0x1
     258:	mov    rax,rsi
     25b:	and    rax,rbx
     25e:	mov    r14,rsi
     261:	test   rax,0x1
     267:	jne    290 <botlish_fn_2+0xb0>
     26d:	mov    rdx,rbx
     270:	mov    rsi,r14
     273:	mov    rdi,r13
     276:	call   27b <botlish_fn_2+0x9b>
			277: R_X86_64_PLT32	rt_int_cmp-0x4
     27b:	mov    ecx,0x2
     280:	test   rax,rax
     283:	cmovl  rcx,QWORD PTR [rip+0xe5]        # 370 <botlish_fn_2+0x190>
     28b:	jmp    2a3 <botlish_fn_2+0xc3>
     290:	mov    ecx,0x2
     295:	mov    rsi,r14
     298:	cmp    rsi,rbx
     29b:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 370 <botlish_fn_2+0x190>
     2a3:	cmp    rcx,0x6
     2a7:	je     2d2 <botlish_fn_2+0xf2>
     2ad:	mov    rax,r15
     2b0:	mov    rbx,QWORD PTR [rsp+0x30]
     2b5:	mov    r12,QWORD PTR [rsp+0x38]
     2ba:	mov    r13,QWORD PTR [rsp+0x40]
     2bf:	mov    r14,QWORD PTR [rsp+0x48]
     2c4:	mov    r15,QWORD PTR [rsp+0x50]
     2c9:	add    rsp,0x60
     2cd:	mov    rsp,rbp
     2d0:	pop    rbp
     2d1:	ret
     2d2:	mov    rcx,r12
     2d5:	mov    rdx,r14
     2d8:	mov    rsi,r15
     2db:	mov    rdi,r13
     2de:	call   2e3 <botlish_fn_2+0x103>
			2df: R_X86_64_PLT32	rt_mutarray_set-0x4
     2e3:	test   rax,rax
     2e6:	jne    311 <botlish_fn_2+0x131>
     2ec:	xor    rax,rax
     2ef:	mov    rbx,QWORD PTR [rsp+0x30]
     2f4:	mov    r12,QWORD PTR [rsp+0x38]
     2f9:	mov    r13,QWORD PTR [rsp+0x40]
     2fe:	mov    r14,QWORD PTR [rsp+0x48]
     303:	mov    r15,QWORD PTR [rsp+0x50]
     308:	add    rsp,0x60
     30c:	mov    rsp,rbp
     30f:	pop    rbp
     310:	ret
     311:	mov    QWORD PTR [rsp+0x20],0x3
     31a:	mov    rsi,r14
     31d:	test   rsi,0x1
     324:	je     34a <botlish_fn_2+0x16a>
     32a:	mov    rsi,r14
     32d:	mov    rcx,rsi
     330:	add    rcx,0x2
     334:	seto   al
     337:	test   al,al
     339:	jne    34a <botlish_fn_2+0x16a>
     33f:	mov    rsi,rcx
     342:	mov    r14,rcx
     345:	jmp    360 <botlish_fn_2+0x180>
     34a:	mov    edx,0x3
     34f:	mov    rsi,r14
     352:	mov    rdi,r13
     355:	call   35a <botlish_fn_2+0x17a>
			356: R_X86_64_PLT32	rt_int_add-0x4
     35a:	mov    rsi,rax
     35d:	mov    r14,rax
     360:	mov    QWORD PTR [rsp+0x18],rsi
     365:	mov    rsi,r14
     368:	jmp    258 <botlish_fn_2+0x78>
     36d:	add    BYTE PTR [rax],al
     36f:	add    BYTE PTR [rsi],al
     371:	add    BYTE PTR [rax],al
     373:	add    BYTE PTR [rax],al
     375:	add    BYTE PTR [rax],al
	...

0000000000000378 <botlish_entry_2: mutable_array::create<int, List[str]>>:
     378:	push   rbp
     379:	mov    rbp,rsp
     37c:	mov    rsi,QWORD PTR [rdx]
     37f:	mov    rdx,QWORD PTR [rdx+0x8]
     383:	call   388 <botlish_entry_2+0x10>
			384: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     388:	mov    rsp,rbp
     38b:	pop    rbp
     38c:	ret
     38d:	add    BYTE PTR [rax],al
	...

0000000000000390 <botlish_fn_3: mutable_array::create<int, mutarray>>:
     390:	push   rbp
     391:	mov    rbp,rsp
     394:	sub    rsp,0x60
     398:	mov    QWORD PTR [rsp+0x30],rbx
     39d:	mov    QWORD PTR [rsp+0x38],r12
     3a2:	mov    QWORD PTR [rsp+0x40],r13
     3a7:	mov    QWORD PTR [rsp+0x48],r14
     3ac:	mov    QWORD PTR [rsp+0x50],r15
     3b1:	mov    r13,rdi
     3b4:	mov    QWORD PTR [rsp+0x10],0x0
     3bd:	mov    QWORD PTR [rsp+0x18],0x0
     3c6:	mov    QWORD PTR [rsp+0x20],0x0
     3cf:	mov    QWORD PTR [rsp],rsi
     3d3:	mov    QWORD PTR [rsp+0x8],rdx
     3d8:	mov    r12,rdx
     3db:	mov    rbx,rsi
     3de:	mov    rdi,r13
     3e1:	call   3e6 <botlish_fn_3+0x56>
			3e2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3e6:	test   rax,rax
     3e9:	je     49c <botlish_fn_3+0x10c>
     3ef:	mov    QWORD PTR [rsp+0x10],rax
     3f4:	mov    r15,rax
     3f7:	mov    esi,0x1
     3fc:	mov    r14,rsi
     3ff:	mov    QWORD PTR [rsp+0x18],0x1
     408:	mov    rax,rsi
     40b:	and    rax,rbx
     40e:	mov    r14,rsi
     411:	test   rax,0x1
     417:	jne    440 <botlish_fn_3+0xb0>
     41d:	mov    rdx,rbx
     420:	mov    rsi,r14
     423:	mov    rdi,r13
     426:	call   42b <botlish_fn_3+0x9b>
			427: R_X86_64_PLT32	rt_int_cmp-0x4
     42b:	mov    ecx,0x2
     430:	test   rax,rax
     433:	cmovl  rcx,QWORD PTR [rip+0xe5]        # 520 <botlish_fn_3+0x190>
     43b:	jmp    453 <botlish_fn_3+0xc3>
     440:	mov    ecx,0x2
     445:	mov    rsi,r14
     448:	cmp    rsi,rbx
     44b:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 520 <botlish_fn_3+0x190>
     453:	cmp    rcx,0x6
     457:	je     482 <botlish_fn_3+0xf2>
     45d:	mov    rax,r15
     460:	mov    rbx,QWORD PTR [rsp+0x30]
     465:	mov    r12,QWORD PTR [rsp+0x38]
     46a:	mov    r13,QWORD PTR [rsp+0x40]
     46f:	mov    r14,QWORD PTR [rsp+0x48]
     474:	mov    r15,QWORD PTR [rsp+0x50]
     479:	add    rsp,0x60
     47d:	mov    rsp,rbp
     480:	pop    rbp
     481:	ret
     482:	mov    rcx,r12
     485:	mov    rdx,r14
     488:	mov    rsi,r15
     48b:	mov    rdi,r13
     48e:	call   493 <botlish_fn_3+0x103>
			48f: R_X86_64_PLT32	rt_mutarray_set-0x4
     493:	test   rax,rax
     496:	jne    4c1 <botlish_fn_3+0x131>
     49c:	xor    rax,rax
     49f:	mov    rbx,QWORD PTR [rsp+0x30]
     4a4:	mov    r12,QWORD PTR [rsp+0x38]
     4a9:	mov    r13,QWORD PTR [rsp+0x40]
     4ae:	mov    r14,QWORD PTR [rsp+0x48]
     4b3:	mov    r15,QWORD PTR [rsp+0x50]
     4b8:	add    rsp,0x60
     4bc:	mov    rsp,rbp
     4bf:	pop    rbp
     4c0:	ret
     4c1:	mov    QWORD PTR [rsp+0x20],0x3
     4ca:	mov    rsi,r14
     4cd:	test   rsi,0x1
     4d4:	je     4fa <botlish_fn_3+0x16a>
     4da:	mov    rsi,r14
     4dd:	mov    rcx,rsi
     4e0:	add    rcx,0x2
     4e4:	seto   al
     4e7:	test   al,al
     4e9:	jne    4fa <botlish_fn_3+0x16a>
     4ef:	mov    rsi,rcx
     4f2:	mov    r14,rcx
     4f5:	jmp    510 <botlish_fn_3+0x180>
     4fa:	mov    edx,0x3
     4ff:	mov    rsi,r14
     502:	mov    rdi,r13
     505:	call   50a <botlish_fn_3+0x17a>
			506: R_X86_64_PLT32	rt_int_add-0x4
     50a:	mov    rsi,rax
     50d:	mov    r14,rax
     510:	mov    QWORD PTR [rsp+0x18],rsi
     515:	mov    rsi,r14
     518:	jmp    408 <botlish_fn_3+0x78>
     51d:	add    BYTE PTR [rax],al
     51f:	add    BYTE PTR [rsi],al
     521:	add    BYTE PTR [rax],al
     523:	add    BYTE PTR [rax],al
     525:	add    BYTE PTR [rax],al
	...

0000000000000528 <botlish_entry_3: mutable_array::create<int, mutarray>>:
     528:	push   rbp
     529:	mov    rbp,rsp
     52c:	mov    rsi,QWORD PTR [rdx]
     52f:	mov    rdx,QWORD PTR [rdx+0x8]
     533:	call   538 <botlish_entry_3+0x10>
			534: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutable_array::create<int, mutarray>
     538:	mov    rsp,rbp
     53b:	pop    rbp
     53c:	ret

000000000000053d <botlish_fn_4: geo_new<str>>:
     53d:	push   rbp
     53e:	mov    rbp,rsp
     541:	sub    rsp,0x10
     545:	mov    QWORD PTR [rsp],rsi
     549:	mov    rdx,rsi
     54c:	mov    esi,0x3
     551:	mov    QWORD PTR [rsp+0x8],0x3
     55a:	call   55f <botlish_fn_4+0x22>
			55b: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     55f:	test   rax,rax
     562:	jne    574 <botlish_fn_4+0x37>
     568:	xor    rax,rax
     56b:	add    rsp,0x10
     56f:	mov    rsp,rbp
     572:	pop    rbp
     573:	ret
     574:	add    rsp,0x10
     578:	mov    rsp,rbp
     57b:	pop    rbp
     57c:	ret

000000000000057d <botlish_entry_4: geo_new<str>>:
     57d:	push   rbp
     57e:	mov    rbp,rsp
     581:	mov    rsi,QWORD PTR [rdx]
     584:	call   589 <botlish_entry_4+0xc>
			585: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
     589:	mov    rsp,rbp
     58c:	pop    rbp
     58d:	ret

000000000000058e <botlish_fn_5: geo_new<List[str]>>:
     58e:	push   rbp
     58f:	mov    rbp,rsp
     592:	sub    rsp,0x10
     596:	mov    QWORD PTR [rsp],rsi
     59a:	mov    rdx,rsi
     59d:	mov    esi,0x3
     5a2:	mov    QWORD PTR [rsp+0x8],0x3
     5ab:	call   5b0 <botlish_fn_5+0x22>
			5ac: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     5b0:	test   rax,rax
     5b3:	jne    5c5 <botlish_fn_5+0x37>
     5b9:	xor    rax,rax
     5bc:	add    rsp,0x10
     5c0:	mov    rsp,rbp
     5c3:	pop    rbp
     5c4:	ret
     5c5:	add    rsp,0x10
     5c9:	mov    rsp,rbp
     5cc:	pop    rbp
     5cd:	ret

00000000000005ce <botlish_entry_5: geo_new<List[str]>>:
     5ce:	push   rbp
     5cf:	mov    rbp,rsp
     5d2:	mov    rsi,QWORD PTR [rdx]
     5d5:	call   5da <botlish_entry_5+0xc>
			5d6: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
     5da:	mov    rsp,rbp
     5dd:	pop    rbp
     5de:	ret

00000000000005df <botlish_fn_6: geo_new<mutarray>>:
     5df:	push   rbp
     5e0:	mov    rbp,rsp
     5e3:	sub    rsp,0x10
     5e7:	mov    QWORD PTR [rsp],rsi
     5eb:	mov    rdx,rsi
     5ee:	mov    esi,0x3
     5f3:	mov    QWORD PTR [rsp+0x8],0x3
     5fc:	call   601 <botlish_fn_6+0x22>
			5fd: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutable_array::create<int, mutarray>
     601:	test   rax,rax
     604:	jne    616 <botlish_fn_6+0x37>
     60a:	xor    rax,rax
     60d:	add    rsp,0x10
     611:	mov    rsp,rbp
     614:	pop    rbp
     615:	ret
     616:	add    rsp,0x10
     61a:	mov    rsp,rbp
     61d:	pop    rbp
     61e:	ret

000000000000061f <botlish_entry_6: geo_new<mutarray>>:
     61f:	push   rbp
     620:	mov    rbp,rsp
     623:	mov    rsi,QWORD PTR [rdx]
     626:	call   62b <botlish_entry_6+0xc>
			627: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
     62b:	mov    rsp,rbp
     62e:	pop    rbp
     62f:	ret

0000000000000630 <botlish_fn_7: geo_new_capacity<int, int>>:
     630:	push   rbp
     631:	mov    rbp,rsp
     634:	sub    rsp,0x40
     638:	mov    QWORD PTR [rsp+0x20],rbx
     63d:	mov    QWORD PTR [rsp+0x28],r12
     642:	mov    QWORD PTR [rsp+0x30],r13
     647:	mov    r12,rdi
     64a:	mov    QWORD PTR [rsp],rsi
     64e:	mov    QWORD PTR [rsp+0x8],rdx
     653:	mov    rbx,rdx
     656:	mov    QWORD PTR [rsp+0x10],0x5
     65f:	test   rsi,0x1
     666:	je     688 <botlish_fn_7+0x58>
     66c:	mov    rax,rsi
     66f:	sar    rax,1
     672:	imul   QWORD PTR [rip+0xdf]        # 758 <botlish_fn_7+0x128>
     679:	seto   cl
     67c:	or     rax,0x1
     680:	test   cl,cl
     682:	je     695 <botlish_fn_7+0x65>
     688:	mov    edx,0x5
     68d:	mov    rdi,r12
     690:	call   695 <botlish_fn_7+0x65>
			691: R_X86_64_PLT32	rt_int_mul-0x4
     695:	mov    rcx,rax
     698:	and    rcx,rbx
     69b:	mov    r13,rax
     69e:	test   rcx,0x1
     6a5:	jne    6d1 <botlish_fn_7+0xa1>
     6ab:	mov    rdx,rbx
     6ae:	mov    rsi,r13
     6b1:	mov    rdi,r12
     6b4:	call   6b9 <botlish_fn_7+0x89>
			6b5: R_X86_64_PLT32	rt_int_cmp-0x4
     6b9:	mov    ecx,0x2
     6be:	test   rax,rax
     6c1:	cmovle rcx,QWORD PTR [rip+0x97]        # 760 <botlish_fn_7+0x130>
     6c9:	mov    rax,r13
     6cc:	jmp    6e4 <botlish_fn_7+0xb4>
     6d1:	mov    ecx,0x2
     6d6:	mov    rax,r13
     6d9:	cmp    rax,rbx
     6dc:	cmovle rcx,QWORD PTR [rip+0x7c]        # 760 <botlish_fn_7+0x130>
     6e4:	cmp    rcx,0x6
     6e8:	je     706 <botlish_fn_7+0xd6>
     6ee:	mov    rbx,QWORD PTR [rsp+0x20]
     6f3:	mov    r12,QWORD PTR [rsp+0x28]
     6f8:	mov    r13,QWORD PTR [rsp+0x30]
     6fd:	add    rsp,0x40
     701:	mov    rsp,rbp
     704:	pop    rbp
     705:	ret
     706:	mov    QWORD PTR [rsp],0x3
     70e:	test   rbx,0x1
     715:	je     72d <botlish_fn_7+0xfd>
     71b:	mov    rax,rbx
     71e:	add    rax,0x2
     722:	seto   cl
     725:	test   cl,cl
     727:	je     73d <botlish_fn_7+0x10d>
     72d:	mov    edx,0x3
     732:	mov    rsi,rbx
     735:	mov    rdi,r12
     738:	call   73d <botlish_fn_7+0x10d>
			739: R_X86_64_PLT32	rt_int_add-0x4
     73d:	mov    rbx,QWORD PTR [rsp+0x20]
     742:	mov    r12,QWORD PTR [rsp+0x28]
     747:	mov    r13,QWORD PTR [rsp+0x30]
     74c:	add    rsp,0x40
     750:	mov    rsp,rbp
     753:	pop    rbp
     754:	ret
     755:	add    BYTE PTR [rax],al
     757:	add    BYTE PTR [rax+rax*1],al
     75a:	add    BYTE PTR [rax],al
     75c:	add    BYTE PTR [rax],al
     75e:	add    BYTE PTR [rax],al
     760:	(bad)
     761:	add    BYTE PTR [rax],al
     763:	add    BYTE PTR [rax],al
     765:	add    BYTE PTR [rax],al
	...

0000000000000768 <botlish_entry_7: geo_new_capacity<int, int>>:
     768:	push   rbp
     769:	mov    rbp,rsp
     76c:	mov    rsi,QWORD PTR [rdx]
     76f:	mov    rdx,QWORD PTR [rdx+0x8]
     773:	call   778 <botlish_entry_7+0x10>
			774: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     778:	mov    rsp,rbp
     77b:	pop    rbp
     77c:	ret
     77d:	add    BYTE PTR [rax],al
	...

0000000000000780 <botlish_fn_8: geo_grow<mutarray, int, str>>:
     780:	push   rbp
     781:	mov    rbp,rsp
     784:	sub    rsp,0x50
     788:	mov    QWORD PTR [rsp+0x20],rbx
     78d:	mov    QWORD PTR [rsp+0x28],r12
     792:	mov    QWORD PTR [rsp+0x30],r13
     797:	mov    QWORD PTR [rsp+0x38],r14
     79c:	mov    QWORD PTR [rsp+0x40],r15
     7a1:	mov    r13,rdi
     7a4:	mov    QWORD PTR [rsp],rsi
     7a8:	mov    r12,rsi
     7ab:	mov    QWORD PTR [rsp+0x8],rdx
     7b0:	mov    rbx,rdx
     7b3:	mov    QWORD PTR [rsp+0x10],rcx
     7b8:	mov    r14,rcx
     7bb:	mov    rsi,r12
     7be:	mov    rdi,r13
     7c1:	call   7c6 <botlish_fn_8+0x46>
			7c2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     7c6:	mov    r15,rax
     7c9:	mov    QWORD PTR [rsp+0x18],rax
     7ce:	mov    rcx,rbx
     7d1:	and    rcx,rax
     7d4:	test   rcx,0x1
     7db:	jne    807 <botlish_fn_8+0x87>
     7e1:	mov    rdx,r15
     7e4:	mov    rsi,rbx
     7e7:	mov    rdi,r13
     7ea:	call   7ef <botlish_fn_8+0x6f>
			7eb: R_X86_64_PLT32	rt_int_cmp-0x4
     7ef:	mov    ecx,0x2
     7f4:	test   rax,rax
     7f7:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 8e8 <botlish_fn_8+0x168>
     7ff:	mov    rax,r15
     802:	jmp    81a <botlish_fn_8+0x9a>
     807:	mov    ecx,0x2
     80c:	mov    rax,r15
     80f:	cmp    rbx,rax
     812:	cmovl  rcx,QWORD PTR [rip+0xce]        # 8e8 <botlish_fn_8+0x168>
     81a:	cmp    rcx,0x6
     81e:	je     8be <botlish_fn_8+0x13e>
     824:	mov    rsi,rax
     827:	mov    rdx,rbx
     82a:	mov    rdi,r13
     82d:	call   832 <botlish_fn_8+0xb2>
			82e: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     832:	mov    QWORD PTR [rsp+0x18],rax
     837:	mov    rdx,r14
     83a:	mov    rsi,rax
     83d:	mov    rdi,r13
     840:	call   845 <botlish_fn_8+0xc5>
			841: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     845:	test   rax,rax
     848:	mov    r14,rax
     84b:	je     874 <botlish_fn_8+0xf4>
     851:	mov    r8d,0x1
     857:	mov    rcx,r12
     85a:	mov    rdi,r13
     85d:	mov    r9,rbx
     860:	mov    rsi,r14
     863:	mov    rdx,r8
     866:	call   86b <botlish_fn_8+0xeb>
			867: R_X86_64_PLT32	rt_mutarray_copy-0x4
     86b:	test   rax,rax
     86e:	jne    899 <botlish_fn_8+0x119>
     874:	xor    rax,rax
     877:	mov    rbx,QWORD PTR [rsp+0x20]
     87c:	mov    r12,QWORD PTR [rsp+0x28]
     881:	mov    r13,QWORD PTR [rsp+0x30]
     886:	mov    r14,QWORD PTR [rsp+0x38]
     88b:	mov    r15,QWORD PTR [rsp+0x40]
     890:	add    rsp,0x50
     894:	mov    rsp,rbp
     897:	pop    rbp
     898:	ret
     899:	mov    rax,r14
     89c:	mov    rbx,QWORD PTR [rsp+0x20]
     8a1:	mov    r12,QWORD PTR [rsp+0x28]
     8a6:	mov    r13,QWORD PTR [rsp+0x30]
     8ab:	mov    r14,QWORD PTR [rsp+0x38]
     8b0:	mov    r15,QWORD PTR [rsp+0x40]
     8b5:	add    rsp,0x50
     8b9:	mov    rsp,rbp
     8bc:	pop    rbp
     8bd:	ret
     8be:	mov    rax,r12
     8c1:	mov    rbx,QWORD PTR [rsp+0x20]
     8c6:	mov    r12,QWORD PTR [rsp+0x28]
     8cb:	mov    r13,QWORD PTR [rsp+0x30]
     8d0:	mov    r14,QWORD PTR [rsp+0x38]
     8d5:	mov    r15,QWORD PTR [rsp+0x40]
     8da:	add    rsp,0x50
     8de:	mov    rsp,rbp
     8e1:	pop    rbp
     8e2:	ret
     8e3:	add    BYTE PTR [rax],al
     8e5:	add    BYTE PTR [rax],al
     8e7:	add    BYTE PTR [rsi],al
     8e9:	add    BYTE PTR [rax],al
     8eb:	add    BYTE PTR [rax],al
     8ed:	add    BYTE PTR [rax],al
	...

00000000000008f0 <botlish_entry_8: geo_grow<mutarray, int, str>>:
     8f0:	push   rbp
     8f1:	mov    rbp,rsp
     8f4:	mov    rsi,QWORD PTR [rdx]
     8f7:	mov    r8,QWORD PTR [rdx+0x8]
     8fb:	mov    rcx,QWORD PTR [rdx+0x10]
     8ff:	mov    rdx,r8
     902:	call   907 <botlish_entry_8+0x17>
			903: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_grow<mutarray, int, str>
     907:	mov    rsp,rbp
     90a:	pop    rbp
     90b:	ret
     90c:	add    BYTE PTR [rax],al
	...

0000000000000910 <botlish_fn_9: geo_grow<mutarray, int, List[str]>>:
     910:	push   rbp
     911:	mov    rbp,rsp
     914:	sub    rsp,0x50
     918:	mov    QWORD PTR [rsp+0x20],rbx
     91d:	mov    QWORD PTR [rsp+0x28],r12
     922:	mov    QWORD PTR [rsp+0x30],r13
     927:	mov    QWORD PTR [rsp+0x38],r14
     92c:	mov    QWORD PTR [rsp+0x40],r15
     931:	mov    r13,rdi
     934:	mov    QWORD PTR [rsp],rsi
     938:	mov    r12,rsi
     93b:	mov    QWORD PTR [rsp+0x8],rdx
     940:	mov    rbx,rdx
     943:	mov    QWORD PTR [rsp+0x10],rcx
     948:	mov    r14,rcx
     94b:	mov    rsi,r12
     94e:	mov    rdi,r13
     951:	call   956 <botlish_fn_9+0x46>
			952: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     956:	mov    r15,rax
     959:	mov    QWORD PTR [rsp+0x18],rax
     95e:	mov    rcx,rbx
     961:	and    rcx,rax
     964:	test   rcx,0x1
     96b:	jne    997 <botlish_fn_9+0x87>
     971:	mov    rdx,r15
     974:	mov    rsi,rbx
     977:	mov    rdi,r13
     97a:	call   97f <botlish_fn_9+0x6f>
			97b: R_X86_64_PLT32	rt_int_cmp-0x4
     97f:	mov    ecx,0x2
     984:	test   rax,rax
     987:	cmovl  rcx,QWORD PTR [rip+0xe9]        # a78 <botlish_fn_9+0x168>
     98f:	mov    rax,r15
     992:	jmp    9aa <botlish_fn_9+0x9a>
     997:	mov    ecx,0x2
     99c:	mov    rax,r15
     99f:	cmp    rbx,rax
     9a2:	cmovl  rcx,QWORD PTR [rip+0xce]        # a78 <botlish_fn_9+0x168>
     9aa:	cmp    rcx,0x6
     9ae:	je     a4e <botlish_fn_9+0x13e>
     9b4:	mov    rsi,rax
     9b7:	mov    rdx,rbx
     9ba:	mov    rdi,r13
     9bd:	call   9c2 <botlish_fn_9+0xb2>
			9be: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     9c2:	mov    QWORD PTR [rsp+0x18],rax
     9c7:	mov    rdx,r14
     9ca:	mov    rsi,rax
     9cd:	mov    rdi,r13
     9d0:	call   9d5 <botlish_fn_9+0xc5>
			9d1: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     9d5:	test   rax,rax
     9d8:	mov    r14,rax
     9db:	je     a04 <botlish_fn_9+0xf4>
     9e1:	mov    r8d,0x1
     9e7:	mov    rcx,r12
     9ea:	mov    rdi,r13
     9ed:	mov    r9,rbx
     9f0:	mov    rsi,r14
     9f3:	mov    rdx,r8
     9f6:	call   9fb <botlish_fn_9+0xeb>
			9f7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     9fb:	test   rax,rax
     9fe:	jne    a29 <botlish_fn_9+0x119>
     a04:	xor    rax,rax
     a07:	mov    rbx,QWORD PTR [rsp+0x20]
     a0c:	mov    r12,QWORD PTR [rsp+0x28]
     a11:	mov    r13,QWORD PTR [rsp+0x30]
     a16:	mov    r14,QWORD PTR [rsp+0x38]
     a1b:	mov    r15,QWORD PTR [rsp+0x40]
     a20:	add    rsp,0x50
     a24:	mov    rsp,rbp
     a27:	pop    rbp
     a28:	ret
     a29:	mov    rax,r14
     a2c:	mov    rbx,QWORD PTR [rsp+0x20]
     a31:	mov    r12,QWORD PTR [rsp+0x28]
     a36:	mov    r13,QWORD PTR [rsp+0x30]
     a3b:	mov    r14,QWORD PTR [rsp+0x38]
     a40:	mov    r15,QWORD PTR [rsp+0x40]
     a45:	add    rsp,0x50
     a49:	mov    rsp,rbp
     a4c:	pop    rbp
     a4d:	ret
     a4e:	mov    rax,r12
     a51:	mov    rbx,QWORD PTR [rsp+0x20]
     a56:	mov    r12,QWORD PTR [rsp+0x28]
     a5b:	mov    r13,QWORD PTR [rsp+0x30]
     a60:	mov    r14,QWORD PTR [rsp+0x38]
     a65:	mov    r15,QWORD PTR [rsp+0x40]
     a6a:	add    rsp,0x50
     a6e:	mov    rsp,rbp
     a71:	pop    rbp
     a72:	ret
     a73:	add    BYTE PTR [rax],al
     a75:	add    BYTE PTR [rax],al
     a77:	add    BYTE PTR [rsi],al
     a79:	add    BYTE PTR [rax],al
     a7b:	add    BYTE PTR [rax],al
     a7d:	add    BYTE PTR [rax],al
	...

0000000000000a80 <botlish_entry_9: geo_grow<mutarray, int, List[str]>>:
     a80:	push   rbp
     a81:	mov    rbp,rsp
     a84:	mov    rsi,QWORD PTR [rdx]
     a87:	mov    r8,QWORD PTR [rdx+0x8]
     a8b:	mov    rcx,QWORD PTR [rdx+0x10]
     a8f:	mov    rdx,r8
     a92:	call   a97 <botlish_entry_9+0x17>
			a93: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, List[str]>
     a97:	mov    rsp,rbp
     a9a:	pop    rbp
     a9b:	ret
     a9c:	add    BYTE PTR [rax],al
	...

0000000000000aa0 <botlish_fn_10: geo_grow<mutarray, int, mutarray>>:
     aa0:	push   rbp
     aa1:	mov    rbp,rsp
     aa4:	sub    rsp,0x50
     aa8:	mov    QWORD PTR [rsp+0x20],rbx
     aad:	mov    QWORD PTR [rsp+0x28],r12
     ab2:	mov    QWORD PTR [rsp+0x30],r13
     ab7:	mov    QWORD PTR [rsp+0x38],r14
     abc:	mov    QWORD PTR [rsp+0x40],r15
     ac1:	mov    r13,rdi
     ac4:	mov    QWORD PTR [rsp],rsi
     ac8:	mov    r12,rsi
     acb:	mov    QWORD PTR [rsp+0x8],rdx
     ad0:	mov    rbx,rdx
     ad3:	mov    QWORD PTR [rsp+0x10],rcx
     ad8:	mov    r14,rcx
     adb:	mov    rsi,r12
     ade:	mov    rdi,r13
     ae1:	call   ae6 <botlish_fn_10+0x46>
			ae2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     ae6:	mov    r15,rax
     ae9:	mov    QWORD PTR [rsp+0x18],rax
     aee:	mov    rcx,rbx
     af1:	and    rcx,rax
     af4:	test   rcx,0x1
     afb:	jne    b27 <botlish_fn_10+0x87>
     b01:	mov    rdx,r15
     b04:	mov    rsi,rbx
     b07:	mov    rdi,r13
     b0a:	call   b0f <botlish_fn_10+0x6f>
			b0b: R_X86_64_PLT32	rt_int_cmp-0x4
     b0f:	mov    ecx,0x2
     b14:	test   rax,rax
     b17:	cmovl  rcx,QWORD PTR [rip+0xe9]        # c08 <botlish_fn_10+0x168>
     b1f:	mov    rax,r15
     b22:	jmp    b3a <botlish_fn_10+0x9a>
     b27:	mov    ecx,0x2
     b2c:	mov    rax,r15
     b2f:	cmp    rbx,rax
     b32:	cmovl  rcx,QWORD PTR [rip+0xce]        # c08 <botlish_fn_10+0x168>
     b3a:	cmp    rcx,0x6
     b3e:	je     bde <botlish_fn_10+0x13e>
     b44:	mov    rsi,rax
     b47:	mov    rdx,rbx
     b4a:	mov    rdi,r13
     b4d:	call   b52 <botlish_fn_10+0xb2>
			b4e: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     b52:	mov    QWORD PTR [rsp+0x18],rax
     b57:	mov    rdx,r14
     b5a:	mov    rsi,rax
     b5d:	mov    rdi,r13
     b60:	call   b65 <botlish_fn_10+0xc5>
			b61: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutable_array::create<int, mutarray>
     b65:	test   rax,rax
     b68:	mov    r14,rax
     b6b:	je     b94 <botlish_fn_10+0xf4>
     b71:	mov    r8d,0x1
     b77:	mov    rcx,r12
     b7a:	mov    rdi,r13
     b7d:	mov    r9,rbx
     b80:	mov    rsi,r14
     b83:	mov    rdx,r8
     b86:	call   b8b <botlish_fn_10+0xeb>
			b87: R_X86_64_PLT32	rt_mutarray_copy-0x4
     b8b:	test   rax,rax
     b8e:	jne    bb9 <botlish_fn_10+0x119>
     b94:	xor    rax,rax
     b97:	mov    rbx,QWORD PTR [rsp+0x20]
     b9c:	mov    r12,QWORD PTR [rsp+0x28]
     ba1:	mov    r13,QWORD PTR [rsp+0x30]
     ba6:	mov    r14,QWORD PTR [rsp+0x38]
     bab:	mov    r15,QWORD PTR [rsp+0x40]
     bb0:	add    rsp,0x50
     bb4:	mov    rsp,rbp
     bb7:	pop    rbp
     bb8:	ret
     bb9:	mov    rax,r14
     bbc:	mov    rbx,QWORD PTR [rsp+0x20]
     bc1:	mov    r12,QWORD PTR [rsp+0x28]
     bc6:	mov    r13,QWORD PTR [rsp+0x30]
     bcb:	mov    r14,QWORD PTR [rsp+0x38]
     bd0:	mov    r15,QWORD PTR [rsp+0x40]
     bd5:	add    rsp,0x50
     bd9:	mov    rsp,rbp
     bdc:	pop    rbp
     bdd:	ret
     bde:	mov    rax,r12
     be1:	mov    rbx,QWORD PTR [rsp+0x20]
     be6:	mov    r12,QWORD PTR [rsp+0x28]
     beb:	mov    r13,QWORD PTR [rsp+0x30]
     bf0:	mov    r14,QWORD PTR [rsp+0x38]
     bf5:	mov    r15,QWORD PTR [rsp+0x40]
     bfa:	add    rsp,0x50
     bfe:	mov    rsp,rbp
     c01:	pop    rbp
     c02:	ret
     c03:	add    BYTE PTR [rax],al
     c05:	add    BYTE PTR [rax],al
     c07:	add    BYTE PTR [rsi],al
     c09:	add    BYTE PTR [rax],al
     c0b:	add    BYTE PTR [rax],al
     c0d:	add    BYTE PTR [rax],al
	...

0000000000000c10 <botlish_entry_10: geo_grow<mutarray, int, mutarray>>:
     c10:	push   rbp
     c11:	mov    rbp,rsp
     c14:	mov    rsi,QWORD PTR [rdx]
     c17:	mov    r8,QWORD PTR [rdx+0x8]
     c1b:	mov    rcx,QWORD PTR [rdx+0x10]
     c1f:	mov    rdx,r8
     c22:	call   c27 <botlish_entry_10+0x17>
			c23: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_grow<mutarray, int, mutarray>
     c27:	mov    rsp,rbp
     c2a:	pop    rbp
     c2b:	ret

0000000000000c2c <botlish_fn_11: geo_append<mutarray, int, str>>:
     c2c:	push   rbp
     c2d:	mov    rbp,rsp
     c30:	sub    rsp,0x40
     c34:	mov    QWORD PTR [rsp+0x20],rbx
     c39:	mov    QWORD PTR [rsp+0x28],r12
     c3e:	mov    QWORD PTR [rsp+0x30],r13
     c43:	mov    QWORD PTR [rsp+0x38],r14
     c48:	mov    rbx,rdi
     c4b:	mov    QWORD PTR [rsp],rsi
     c4f:	mov    QWORD PTR [rsp+0x8],rdx
     c54:	mov    r14,rdx
     c57:	mov    QWORD PTR [rsp+0x10],rcx
     c5c:	mov    r13,rcx
     c5f:	mov    rcx,r13
     c62:	mov    rdx,r14
     c65:	mov    rdi,rbx
     c68:	call   c6d <botlish_fn_11+0x41>
			c69: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_grow<mutarray, int, str>
     c6d:	test   rax,rax
     c70:	je     cd8 <botlish_fn_11+0xac>
     c76:	xor    ecx,ecx
     c78:	test   rax,0x7
     c7e:	je     c8c <botlish_fn_11+0x60>
     c84:	mov    r12,rax
     c87:	jmp    c9a <botlish_fn_11+0x6e>
     c8c:	movzx  rcx,BYTE PTR [rax]
     c90:	mov    r12,rax
     c93:	rex cmp cl,0x8
     c97:	sete   cl
     c9a:	test   cl,cl
     c9c:	jne    cbe <botlish_fn_11+0x92>
     ca2:	mov    rdi,rbx
     ca5:	mov    rax,QWORD PTR [rdi+0x10]
     ca9:	mov    rcx,QWORD PTR [rax]
     cac:	mov    edx,0x8
     cb1:	mov    rsi,r12
     cb4:	call   cb9 <botlish_fn_11+0x8d>
			cb5: R_X86_64_PLT32	rt_type_error-0x4
     cb9:	jmp    cd8 <botlish_fn_11+0xac>
     cbe:	mov    rcx,r13
     cc1:	mov    rdx,r14
     cc4:	mov    rdi,rbx
     cc7:	mov    rsi,r12
     cca:	call   ccf <botlish_fn_11+0xa3>
			ccb: R_X86_64_PLT32	rt_mutarray_set-0x4
     ccf:	test   rax,rax
     cd2:	jne    cf8 <botlish_fn_11+0xcc>
     cd8:	xor    rax,rax
     cdb:	mov    rbx,QWORD PTR [rsp+0x20]
     ce0:	mov    r12,QWORD PTR [rsp+0x28]
     ce5:	mov    r13,QWORD PTR [rsp+0x30]
     cea:	mov    r14,QWORD PTR [rsp+0x38]
     cef:	add    rsp,0x40
     cf3:	mov    rsp,rbp
     cf6:	pop    rbp
     cf7:	ret
     cf8:	mov    rax,r12
     cfb:	mov    rbx,QWORD PTR [rsp+0x20]
     d00:	mov    r12,QWORD PTR [rsp+0x28]
     d05:	mov    r13,QWORD PTR [rsp+0x30]
     d0a:	mov    r14,QWORD PTR [rsp+0x38]
     d0f:	add    rsp,0x40
     d13:	mov    rsp,rbp
     d16:	pop    rbp
     d17:	ret

0000000000000d18 <botlish_entry_11: geo_append<mutarray, int, str>>:
     d18:	push   rbp
     d19:	mov    rbp,rsp
     d1c:	mov    rsi,QWORD PTR [rdx]
     d1f:	mov    r8,QWORD PTR [rdx+0x8]
     d23:	mov    rcx,QWORD PTR [rdx+0x10]
     d27:	mov    rdx,r8
     d2a:	call   d2f <botlish_entry_11+0x17>
			d2b: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
     d2f:	mov    rsp,rbp
     d32:	pop    rbp
     d33:	ret

0000000000000d34 <botlish_fn_12: geo_append<mutarray, int, List[str]>>:
     d34:	push   rbp
     d35:	mov    rbp,rsp
     d38:	sub    rsp,0x40
     d3c:	mov    QWORD PTR [rsp+0x20],rbx
     d41:	mov    QWORD PTR [rsp+0x28],r12
     d46:	mov    QWORD PTR [rsp+0x30],r13
     d4b:	mov    QWORD PTR [rsp+0x38],r14
     d50:	mov    rbx,rdi
     d53:	mov    QWORD PTR [rsp],rsi
     d57:	mov    QWORD PTR [rsp+0x8],rdx
     d5c:	mov    r14,rdx
     d5f:	mov    QWORD PTR [rsp+0x10],rcx
     d64:	mov    r13,rcx
     d67:	mov    rcx,r13
     d6a:	mov    rdx,r14
     d6d:	mov    rdi,rbx
     d70:	call   d75 <botlish_fn_12+0x41>
			d71: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, List[str]>
     d75:	test   rax,rax
     d78:	je     de0 <botlish_fn_12+0xac>
     d7e:	xor    ecx,ecx
     d80:	test   rax,0x7
     d86:	je     d94 <botlish_fn_12+0x60>
     d8c:	mov    r12,rax
     d8f:	jmp    da2 <botlish_fn_12+0x6e>
     d94:	movzx  rcx,BYTE PTR [rax]
     d98:	mov    r12,rax
     d9b:	rex cmp cl,0x8
     d9f:	sete   cl
     da2:	test   cl,cl
     da4:	jne    dc6 <botlish_fn_12+0x92>
     daa:	mov    rdi,rbx
     dad:	mov    rax,QWORD PTR [rdi+0x10]
     db1:	mov    rcx,QWORD PTR [rax]
     db4:	mov    edx,0x8
     db9:	mov    rsi,r12
     dbc:	call   dc1 <botlish_fn_12+0x8d>
			dbd: R_X86_64_PLT32	rt_type_error-0x4
     dc1:	jmp    de0 <botlish_fn_12+0xac>
     dc6:	mov    rcx,r13
     dc9:	mov    rdx,r14
     dcc:	mov    rdi,rbx
     dcf:	mov    rsi,r12
     dd2:	call   dd7 <botlish_fn_12+0xa3>
			dd3: R_X86_64_PLT32	rt_mutarray_set-0x4
     dd7:	test   rax,rax
     dda:	jne    e00 <botlish_fn_12+0xcc>
     de0:	xor    rax,rax
     de3:	mov    rbx,QWORD PTR [rsp+0x20]
     de8:	mov    r12,QWORD PTR [rsp+0x28]
     ded:	mov    r13,QWORD PTR [rsp+0x30]
     df2:	mov    r14,QWORD PTR [rsp+0x38]
     df7:	add    rsp,0x40
     dfb:	mov    rsp,rbp
     dfe:	pop    rbp
     dff:	ret
     e00:	mov    rax,r12
     e03:	mov    rbx,QWORD PTR [rsp+0x20]
     e08:	mov    r12,QWORD PTR [rsp+0x28]
     e0d:	mov    r13,QWORD PTR [rsp+0x30]
     e12:	mov    r14,QWORD PTR [rsp+0x38]
     e17:	add    rsp,0x40
     e1b:	mov    rsp,rbp
     e1e:	pop    rbp
     e1f:	ret

0000000000000e20 <botlish_entry_12: geo_append<mutarray, int, List[str]>>:
     e20:	push   rbp
     e21:	mov    rbp,rsp
     e24:	mov    rsi,QWORD PTR [rdx]
     e27:	mov    r8,QWORD PTR [rdx+0x8]
     e2b:	mov    rcx,QWORD PTR [rdx+0x10]
     e2f:	mov    rdx,r8
     e32:	call   e37 <botlish_entry_12+0x17>
			e33: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
     e37:	mov    rsp,rbp
     e3a:	pop    rbp
     e3b:	ret

0000000000000e3c <botlish_fn_13: geo_append<mutarray, int, mutarray>>:
     e3c:	push   rbp
     e3d:	mov    rbp,rsp
     e40:	sub    rsp,0x40
     e44:	mov    QWORD PTR [rsp+0x20],rbx
     e49:	mov    QWORD PTR [rsp+0x28],r12
     e4e:	mov    QWORD PTR [rsp+0x30],r13
     e53:	mov    QWORD PTR [rsp+0x38],r14
     e58:	mov    rbx,rdi
     e5b:	mov    QWORD PTR [rsp],rsi
     e5f:	mov    QWORD PTR [rsp+0x8],rdx
     e64:	mov    r14,rdx
     e67:	mov    QWORD PTR [rsp+0x10],rcx
     e6c:	mov    r13,rcx
     e6f:	mov    rcx,r13
     e72:	mov    rdx,r14
     e75:	mov    rdi,rbx
     e78:	call   e7d <botlish_fn_13+0x41>
			e79: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_grow<mutarray, int, mutarray>
     e7d:	test   rax,rax
     e80:	je     ee8 <botlish_fn_13+0xac>
     e86:	xor    ecx,ecx
     e88:	test   rax,0x7
     e8e:	je     e9c <botlish_fn_13+0x60>
     e94:	mov    r12,rax
     e97:	jmp    eaa <botlish_fn_13+0x6e>
     e9c:	movzx  rcx,BYTE PTR [rax]
     ea0:	mov    r12,rax
     ea3:	rex cmp cl,0x8
     ea7:	sete   cl
     eaa:	test   cl,cl
     eac:	jne    ece <botlish_fn_13+0x92>
     eb2:	mov    rdi,rbx
     eb5:	mov    rax,QWORD PTR [rdi+0x10]
     eb9:	mov    rcx,QWORD PTR [rax]
     ebc:	mov    edx,0x8
     ec1:	mov    rsi,r12
     ec4:	call   ec9 <botlish_fn_13+0x8d>
			ec5: R_X86_64_PLT32	rt_type_error-0x4
     ec9:	jmp    ee8 <botlish_fn_13+0xac>
     ece:	mov    rcx,r13
     ed1:	mov    rdx,r14
     ed4:	mov    rdi,rbx
     ed7:	mov    rsi,r12
     eda:	call   edf <botlish_fn_13+0xa3>
			edb: R_X86_64_PLT32	rt_mutarray_set-0x4
     edf:	test   rax,rax
     ee2:	jne    f08 <botlish_fn_13+0xcc>
     ee8:	xor    rax,rax
     eeb:	mov    rbx,QWORD PTR [rsp+0x20]
     ef0:	mov    r12,QWORD PTR [rsp+0x28]
     ef5:	mov    r13,QWORD PTR [rsp+0x30]
     efa:	mov    r14,QWORD PTR [rsp+0x38]
     eff:	add    rsp,0x40
     f03:	mov    rsp,rbp
     f06:	pop    rbp
     f07:	ret
     f08:	mov    rax,r12
     f0b:	mov    rbx,QWORD PTR [rsp+0x20]
     f10:	mov    r12,QWORD PTR [rsp+0x28]
     f15:	mov    r13,QWORD PTR [rsp+0x30]
     f1a:	mov    r14,QWORD PTR [rsp+0x38]
     f1f:	add    rsp,0x40
     f23:	mov    rsp,rbp
     f26:	pop    rbp
     f27:	ret

0000000000000f28 <botlish_entry_13: geo_append<mutarray, int, mutarray>>:
     f28:	push   rbp
     f29:	mov    rbp,rsp
     f2c:	mov    rsi,QWORD PTR [rdx]
     f2f:	mov    r8,QWORD PTR [rdx+0x8]
     f33:	mov    rcx,QWORD PTR [rdx+0x10]
     f37:	mov    rdx,r8
     f3a:	call   f3f <botlish_entry_13+0x17>
			f3b: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
     f3f:	mov    rsp,rbp
     f42:	pop    rbp
     f43:	ret

0000000000000f44 <botlish_fn_14: geo_finish<mutarray, int>>:
     f44:	push   rbp
     f45:	mov    rbp,rsp
     f48:	sub    rsp,0x10
     f4c:	mov    QWORD PTR [rsp],rsi
     f50:	mov    QWORD PTR [rsp+0x8],rdx
     f55:	call   f5a <botlish_fn_14+0x16>
			f56: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     f5a:	test   rax,rax
     f5d:	jne    f6f <botlish_fn_14+0x2b>
     f63:	xor    rax,rax
     f66:	add    rsp,0x10
     f6a:	mov    rsp,rbp
     f6d:	pop    rbp
     f6e:	ret
     f6f:	add    rsp,0x10
     f73:	mov    rsp,rbp
     f76:	pop    rbp
     f77:	ret

0000000000000f78 <botlish_entry_14: geo_finish<mutarray, int>>:
     f78:	push   rbp
     f79:	mov    rbp,rsp
     f7c:	mov    rsi,QWORD PTR [rdx]
     f7f:	mov    rdx,QWORD PTR [rdx+0x8]
     f83:	call   f88 <botlish_entry_14+0x10>
			f84: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
     f88:	mov    rsp,rbp
     f8b:	pop    rbp
     f8c:	ret
     f8d:	add    BYTE PTR [rax],al
	...

0000000000000f90 <botlish_fn_15: peek<str, int>>:
     f90:	push   rbp
     f91:	mov    rbp,rsp
     f94:	sub    rsp,0x40
     f98:	mov    QWORD PTR [rsp+0x20],rbx
     f9d:	mov    QWORD PTR [rsp+0x28],r12
     fa2:	mov    QWORD PTR [rsp+0x30],r13
     fa7:	mov    r13,rdi
     faa:	mov    QWORD PTR [rsp],rsi
     fae:	mov    r12,rsi
     fb1:	mov    QWORD PTR [rsp+0x8],rdx
     fb6:	mov    rbx,rdx
     fb9:	mov    rsi,r12
     fbc:	mov    rdi,r13
     fbf:	call   fc4 <botlish_fn_15+0x34>
			fc0: R_X86_64_PLT32	rt_str_len-0x4
     fc4:	mov    rcx,rbx
     fc7:	and    rcx,rax
     fca:	mov    rdx,rax
     fcd:	test   rcx,0x1
     fd4:	jne    ffa <botlish_fn_15+0x6a>
     fda:	mov    rsi,rbx
     fdd:	mov    rdi,r13
     fe0:	call   fe5 <botlish_fn_15+0x55>
			fe1: R_X86_64_PLT32	rt_int_cmp-0x4
     fe5:	mov    ecx,0x2
     fea:	test   rax,rax
     fed:	cmovge rcx,QWORD PTR [rip+0xd3]        # 10c8 <botlish_fn_15+0x138>
     ff5:	jmp    100a <botlish_fn_15+0x7a>
     ffa:	mov    ecx,0x2
     fff:	cmp    rbx,rdx
    1002:	cmovge rcx,QWORD PTR [rip+0xbe]        # 10c8 <botlish_fn_15+0x138>
    100a:	cmp    rcx,0x6
    100e:	je     109e <botlish_fn_15+0x10e>
    1014:	mov    QWORD PTR [rsp+0x10],0x3
    101d:	test   rbx,0x1
    1024:	je     103c <botlish_fn_15+0xac>
    102a:	mov    rcx,rbx
    102d:	add    rcx,0x2
    1031:	seto   al
    1034:	test   al,al
    1036:	je     104f <botlish_fn_15+0xbf>
    103c:	mov    edx,0x3
    1041:	mov    rsi,rbx
    1044:	mov    rdi,r13
    1047:	call   104c <botlish_fn_15+0xbc>
			1048: R_X86_64_PLT32	rt_int_add-0x4
    104c:	mov    rcx,rax
    104f:	mov    QWORD PTR [rsp+0x10],rcx
    1054:	mov    rdx,rbx
    1057:	mov    rsi,r12
    105a:	mov    rdi,r13
    105d:	call   1062 <botlish_fn_15+0xd2>
			105e: R_X86_64_PLT32	rt_substr-0x4
    1062:	test   rax,rax
    1065:	jne    1086 <botlish_fn_15+0xf6>
    106b:	xor    rax,rax
    106e:	mov    rbx,QWORD PTR [rsp+0x20]
    1073:	mov    r12,QWORD PTR [rsp+0x28]
    1078:	mov    r13,QWORD PTR [rsp+0x30]
    107d:	add    rsp,0x40
    1081:	mov    rsp,rbp
    1084:	pop    rbp
    1085:	ret
    1086:	mov    rbx,QWORD PTR [rsp+0x20]
    108b:	mov    r12,QWORD PTR [rsp+0x28]
    1090:	mov    r13,QWORD PTR [rsp+0x30]
    1095:	add    rsp,0x40
    1099:	mov    rsp,rbp
    109c:	pop    rbp
    109d:	ret
    109e:	mov    rdi,r13
    10a1:	mov    rax,QWORD PTR [rdi+0x10]
    10a5:	mov    rax,QWORD PTR [rax+0x8]
    10a9:	mov    rbx,QWORD PTR [rsp+0x20]
    10ae:	mov    r12,QWORD PTR [rsp+0x28]
    10b3:	mov    r13,QWORD PTR [rsp+0x30]
    10b8:	add    rsp,0x40
    10bc:	mov    rsp,rbp
    10bf:	pop    rbp
    10c0:	ret
    10c1:	add    BYTE PTR [rax],al
    10c3:	add    BYTE PTR [rax],al
    10c5:	add    BYTE PTR [rax],al
    10c7:	add    BYTE PTR [rsi],al
    10c9:	add    BYTE PTR [rax],al
    10cb:	add    BYTE PTR [rax],al
    10cd:	add    BYTE PTR [rax],al
	...

00000000000010d0 <botlish_entry_15: peek<str, int>>:
    10d0:	push   rbp
    10d1:	mov    rbp,rsp
    10d4:	mov    rsi,QWORD PTR [rdx]
    10d7:	mov    rdx,QWORD PTR [rdx+0x8]
    10db:	call   10e0 <botlish_entry_15+0x10>
			10dc: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    10e0:	mov    rsp,rbp
    10e3:	pop    rbp
    10e4:	ret
    10e5:	add    BYTE PTR [rax],al
	...

00000000000010e8 <botlish_fn_16: peek<str, int>>:
    10e8:	push   rbp
    10e9:	mov    rbp,rsp
    10ec:	sub    rsp,0x50
    10f0:	mov    QWORD PTR [rsp+0x20],rbx
    10f5:	mov    QWORD PTR [rsp+0x28],r12
    10fa:	mov    QWORD PTR [rsp+0x30],r13
    10ff:	mov    QWORD PTR [rsp+0x38],r14
    1104:	mov    QWORD PTR [rsp+0x40],r15
    1109:	mov    r12,rcx
    110c:	mov    r14,rdi
    110f:	mov    QWORD PTR [rsp],rsi
    1113:	mov    r13,rsi
    1116:	mov    QWORD PTR [rsp+0x8],rdx
    111b:	mov    rbx,rdx
    111e:	mov    rsi,r13
    1121:	mov    rdi,r14
    1124:	call   1129 <botlish_fn_16+0x41>
			1125: R_X86_64_PLT32	rt_str_len-0x4
    1129:	mov    rcx,rbx
    112c:	and    rcx,rax
    112f:	mov    rdx,rax
    1132:	test   rcx,0x1
    1139:	jne    115f <botlish_fn_16+0x77>
    113f:	mov    rsi,rbx
    1142:	mov    rdi,r14
    1145:	call   114a <botlish_fn_16+0x62>
			1146: R_X86_64_PLT32	rt_int_cmp-0x4
    114a:	mov    ecx,0x2
    114f:	test   rax,rax
    1152:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1278 <botlish_fn_16+0x190>
    115a:	jmp    116f <botlish_fn_16+0x87>
    115f:	mov    ecx,0x2
    1164:	cmp    rbx,rdx
    1167:	cmovge rcx,QWORD PTR [rip+0x109]        # 1278 <botlish_fn_16+0x190>
    116f:	cmp    rcx,0x6
    1173:	je     1233 <botlish_fn_16+0x14b>
    1179:	mov    QWORD PTR [rsp+0x10],0x3
    1182:	test   rbx,0x1
    1189:	je     11ac <botlish_fn_16+0xc4>
    118f:	mov    rax,rbx
    1192:	add    rax,0x2
    1196:	seto   cl
    1199:	test   cl,cl
    119b:	jne    11ac <botlish_fn_16+0xc4>
    11a1:	mov    rdi,r14
    11a4:	mov    r15,rax
    11a7:	jmp    11c2 <botlish_fn_16+0xda>
    11ac:	mov    edx,0x3
    11b1:	mov    rsi,rbx
    11b4:	mov    rdi,r14
    11b7:	call   11bc <botlish_fn_16+0xd4>
			11b8: R_X86_64_PLT32	rt_int_add-0x4
    11bc:	mov    r15,rax
    11bf:	mov    rdi,r14
    11c2:	mov    rdi,r14
    11c5:	mov    rcx,r15
    11c8:	mov    rdx,rbx
    11cb:	mov    rsi,r13
    11ce:	call   11d3 <botlish_fn_16+0xeb>
			11cf: R_X86_64_PLT32	rt_str_region_check-0x4
    11d3:	test   rax,rax
    11d6:	jne    1201 <botlish_fn_16+0x119>
    11dc:	xor    rax,rax
    11df:	mov    rbx,QWORD PTR [rsp+0x20]
    11e4:	mov    r12,QWORD PTR [rsp+0x28]
    11e9:	mov    r13,QWORD PTR [rsp+0x30]
    11ee:	mov    r14,QWORD PTR [rsp+0x38]
    11f3:	mov    r15,QWORD PTR [rsp+0x40]
    11f8:	add    rsp,0x50
    11fc:	mov    rsp,rbp
    11ff:	pop    rbp
    1200:	ret
    1201:	mov    rcx,r12
    1204:	mov    QWORD PTR [rcx],rbx
    1207:	mov    rax,r15
    120a:	mov    QWORD PTR [rcx+0x8],rax
    120e:	mov    rax,r13
    1211:	mov    rbx,QWORD PTR [rsp+0x20]
    1216:	mov    r12,QWORD PTR [rsp+0x28]
    121b:	mov    r13,QWORD PTR [rsp+0x30]
    1220:	mov    r14,QWORD PTR [rsp+0x38]
    1225:	mov    r15,QWORD PTR [rsp+0x40]
    122a:	add    rsp,0x50
    122e:	mov    rsp,rbp
    1231:	pop    rbp
    1232:	ret
    1233:	mov    rcx,r12
    1236:	mov    rdi,r14
    1239:	mov    rax,QWORD PTR [rdi+0x10]
    123d:	mov    rax,QWORD PTR [rax+0x8]
    1241:	mov    QWORD PTR [rcx],0x1
    1248:	mov    QWORD PTR [rcx+0x8],0x1
    1250:	mov    rbx,QWORD PTR [rsp+0x20]
    1255:	mov    r12,QWORD PTR [rsp+0x28]
    125a:	mov    r13,QWORD PTR [rsp+0x30]
    125f:	mov    r14,QWORD PTR [rsp+0x38]
    1264:	mov    r15,QWORD PTR [rsp+0x40]
    1269:	add    rsp,0x50
    126d:	mov    rsp,rbp
    1270:	pop    rbp
    1271:	ret
    1272:	add    BYTE PTR [rax],al
    1274:	add    BYTE PTR [rax],al
    1276:	add    BYTE PTR [rax],al
    1278:	(bad)
    1279:	add    BYTE PTR [rax],al
    127b:	add    BYTE PTR [rax],al
    127d:	add    BYTE PTR [rax],al
	...

0000000000001280 <botlish_entry_16: peek<str, int>>:
    1280:	push   rbp
    1281:	mov    rbp,rsp
    1284:	ud2

0000000000001286 <botlish_fn_17: scan_unquoted<str, int, int>>:
    1286:	push   rbp
    1287:	mov    rbp,rsp
    128a:	sub    rsp,0x80
    1291:	mov    QWORD PTR [rsp+0x50],rbx
    1296:	mov    QWORD PTR [rsp+0x58],r12
    129b:	mov    QWORD PTR [rsp+0x60],r13
    12a0:	mov    QWORD PTR [rsp+0x68],r14
    12a5:	mov    QWORD PTR [rsp+0x70],r15
    12aa:	mov    QWORD PTR [rsp+0x30],rdi
    12af:	mov    QWORD PTR [rsp+0x18],0x0
    12b8:	mov    QWORD PTR [rsp],rsi
    12bc:	mov    r15,rsi
    12bf:	mov    QWORD PTR [rsp+0x8],rdx
    12c4:	mov    r14,rdx
    12c7:	mov    QWORD PTR [rsp+0x10],rcx
    12cc:	lea    r13,[rsp+0x20]
    12d1:	mov    QWORD PTR [rsp+0x38],rcx
    12d6:	mov    rcx,r13
    12d9:	mov    rdx,QWORD PTR [rsp+0x38]
    12de:	mov    rsi,r15
    12e1:	mov    rdi,QWORD PTR [rsp+0x30]
    12e6:	call   12eb <botlish_fn_17+0x65>
			12e7: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    12eb:	mov    rsi,rax
    12ee:	mov    QWORD PTR [rsp+0x40],rax
    12f3:	test   rax,rsi
    12f6:	je     1450 <botlish_fn_17+0x1ca>
    12fc:	mov    rbx,QWORD PTR [rsp+0x20]
    1301:	mov    r12,QWORD PTR [rsp+0x28]
    1306:	mov    rdi,QWORD PTR [rsp+0x30]
    130b:	mov    rcx,QWORD PTR [rdi+0x10]
    130f:	mov    r8,QWORD PTR [rcx+0x8]
    1313:	mov    rcx,r12
    1316:	mov    rdx,rbx
    1319:	mov    rsi,QWORD PTR [rsp+0x40]
    131e:	call   1323 <botlish_fn_17+0x9d>
			131f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1323:	cmp    rax,0x6
    1327:	je     1368 <botlish_fn_17+0xe2>
    132d:	mov    rdi,QWORD PTR [rsp+0x30]
    1332:	mov    rax,QWORD PTR [rdi+0x10]
    1336:	mov    r8,QWORD PTR [rax+0x10]
    133a:	mov    rcx,r12
    133d:	mov    rdx,rbx
    1340:	mov    rsi,QWORD PTR [rsp+0x40]
    1345:	call   134a <botlish_fn_17+0xc4>
			1346: R_X86_64_PLT32	rt_str_region_eq-0x4
    134a:	cmp    rax,0x6
    134e:	je     135e <botlish_fn_17+0xd8>
    1354:	mov    eax,0x2
    1359:	jmp    136d <botlish_fn_17+0xe7>
    135e:	mov    eax,0x6
    1363:	jmp    136d <botlish_fn_17+0xe7>
    1368:	mov    eax,0x6
    136d:	cmp    rax,0x6
    1371:	je     13b2 <botlish_fn_17+0x12c>
    1377:	mov    rdi,QWORD PTR [rsp+0x30]
    137c:	mov    rax,QWORD PTR [rdi+0x10]
    1380:	mov    r8,QWORD PTR [rax+0x18]
    1384:	mov    rcx,r12
    1387:	mov    rdx,rbx
    138a:	mov    rsi,QWORD PTR [rsp+0x40]
    138f:	call   1394 <botlish_fn_17+0x10e>
			1390: R_X86_64_PLT32	rt_str_region_eq-0x4
    1394:	cmp    rax,0x6
    1398:	je     13a8 <botlish_fn_17+0x122>
    139e:	mov    eax,0x2
    13a3:	jmp    13b7 <botlish_fn_17+0x131>
    13a8:	mov    eax,0x6
    13ad:	jmp    13b7 <botlish_fn_17+0x131>
    13b2:	mov    eax,0x6
    13b7:	cmp    rax,0x6
    13bb:	je     1432 <botlish_fn_17+0x1ac>
    13c1:	mov    QWORD PTR [rsp+0x18],0x3
    13ca:	mov    rsi,QWORD PTR [rsp+0x38]
    13cf:	test   rsi,0x1
    13d6:	je     13fd <botlish_fn_17+0x177>
    13dc:	mov    rsi,QWORD PTR [rsp+0x38]
    13e1:	mov    rax,rsi
    13e4:	add    rax,0x2
    13e8:	seto   sil
    13ec:	test   sil,sil
    13ef:	jne    13fd <botlish_fn_17+0x177>
    13f5:	mov    rsi,r15
    13f8:	jmp    1414 <botlish_fn_17+0x18e>
    13fd:	mov    edx,0x3
    1402:	mov    rsi,QWORD PTR [rsp+0x38]
    1407:	mov    rdi,QWORD PTR [rsp+0x30]
    140c:	call   1411 <botlish_fn_17+0x18b>
			140d: R_X86_64_PLT32	rt_int_add-0x4
    1411:	mov    rsi,r15
    1414:	mov    QWORD PTR [rsp],rsi
    1418:	mov    rdx,r14
    141b:	mov    QWORD PTR [rsp+0x8],rdx
    1420:	mov    QWORD PTR [rsp+0x10],rax
    1425:	mov    r15,rsi
    1428:	mov    QWORD PTR [rsp+0x38],rax
    142d:	jmp    12d6 <botlish_fn_17+0x50>
    1432:	mov    rdx,r14
    1435:	mov    rsi,r15
    1438:	mov    rdi,QWORD PTR [rsp+0x30]
    143d:	mov    rcx,QWORD PTR [rsp+0x38]
    1442:	call   1447 <botlish_fn_17+0x1c1>
			1443: R_X86_64_PLT32	rt_substr-0x4
    1447:	test   rax,rax
    144a:	jne    147b <botlish_fn_17+0x1f5>
    1450:	xor    rdx,rdx
    1453:	mov    rax,rdx
    1456:	mov    rbx,QWORD PTR [rsp+0x50]
    145b:	mov    r12,QWORD PTR [rsp+0x58]
    1460:	mov    r13,QWORD PTR [rsp+0x60]
    1465:	mov    r14,QWORD PTR [rsp+0x68]
    146a:	mov    r15,QWORD PTR [rsp+0x70]
    146f:	add    rsp,0x80
    1476:	mov    rsp,rbp
    1479:	pop    rbp
    147a:	ret
    147b:	mov    rdx,QWORD PTR [rsp+0x38]
    1480:	mov    rbx,QWORD PTR [rsp+0x50]
    1485:	mov    r12,QWORD PTR [rsp+0x58]
    148a:	mov    r13,QWORD PTR [rsp+0x60]
    148f:	mov    r14,QWORD PTR [rsp+0x68]
    1494:	mov    r15,QWORD PTR [rsp+0x70]
    1499:	add    rsp,0x80
    14a0:	mov    rsp,rbp
    14a3:	pop    rbp
    14a4:	ret

00000000000014a5 <botlish_entry_17: scan_unquoted<str, int, int>>:
    14a5:	push   rbp
    14a6:	mov    rbp,rsp
    14a9:	ud2

00000000000014ab <botlish_fn_18: scan_quoted<str, int, str>>:
    14ab:	push   rbp
    14ac:	mov    rbp,rsp
    14af:	sub    rsp,0xd0
    14b6:	mov    QWORD PTR [rsp+0xa0],rbx
    14be:	mov    QWORD PTR [rsp+0xa8],r12
    14c6:	mov    QWORD PTR [rsp+0xb0],r13
    14ce:	mov    QWORD PTR [rsp+0xb8],r14
    14d6:	mov    QWORD PTR [rsp+0xc0],r15
    14de:	mov    QWORD PTR [rsp+0x88],rdi
    14e6:	mov    QWORD PTR [rsp+0x18],0x0
    14ef:	mov    QWORD PTR [rsp+0x20],0x0
    14f8:	mov    QWORD PTR [rsp],rsi
    14fc:	mov    QWORD PTR [rsp+0x8],rdx
    1501:	mov    QWORD PTR [rsp+0x10],rcx
    1506:	mov    r13,rcx
    1509:	lea    r14,[rsp+0x68]
    150e:	lea    rbx,[rsp+0x28]
    1513:	mov    r12,rsi
    1516:	mov    QWORD PTR [rsp+0x90],rdx
    151e:	mov    rdx,QWORD PTR [rsp+0x90]
    1526:	mov    rsi,r12
    1529:	mov    rdi,QWORD PTR [rsp+0x88]
    1531:	call   1536 <botlish_fn_18+0x8b>
			1532: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    1536:	test   rax,rax
    1539:	je     1882 <botlish_fn_18+0x3d7>
    153f:	mov    QWORD PTR [rsp+0x18],rax
    1544:	mov    rsi,QWORD PTR [rax+0x8]
    1548:	mov    rcx,rax
    154b:	mov    rax,0xffffffffffffffff
    1552:	test   rsi,rsi
    1555:	jne    1563 <botlish_fn_18+0xb8>
    155b:	mov    r15,rcx
    155e:	jmp    158e <botlish_fn_18+0xe3>
    1563:	mov    r15,rcx
    1566:	movzx  rdi,BYTE PTR [r15+0x18]
    156b:	test   rdi,rdi
    156e:	jne    1589 <botlish_fn_18+0xde>
    1574:	mov    rsi,r15
    1577:	mov    rdi,QWORD PTR [rsp+0x88]
    157f:	call   1584 <botlish_fn_18+0xd9>
			1580: R_X86_64_PLT32	rt_str_to_short-0x4
    1584:	jmp    158e <botlish_fn_18+0xe3>
    1589:	movzx  rax,BYTE PTR [r15+0x19]
    158e:	cmp    rax,0x22
    1592:	je     1652 <botlish_fn_18+0x1a7>
    1598:	mov    QWORD PTR [rsp+0x20],0x3
    15a1:	mov    rsi,QWORD PTR [rsp+0x90]
    15a9:	test   rsi,0x1
    15b0:	je     15d0 <botlish_fn_18+0x125>
    15b6:	mov    rax,rsi
    15b9:	add    rax,0x2
    15bd:	seto   cl
    15c0:	test   cl,cl
    15c2:	jne    15d0 <botlish_fn_18+0x125>
    15c8:	mov    rsi,rax
    15cb:	jmp    15e5 <botlish_fn_18+0x13a>
    15d0:	mov    edx,0x3
    15d5:	mov    rdi,QWORD PTR [rsp+0x88]
    15dd:	call   15e2 <botlish_fn_18+0x137>
			15de: R_X86_64_PLT32	rt_int_add-0x4
    15e2:	mov    rsi,rax
    15e5:	mov    QWORD PTR [rsp+0x8],rsi
    15ea:	mov    QWORD PTR [rsp+0x90],rsi
    15f2:	mov    QWORD PTR [rsp+0x68],0x0
    15fb:	mov    QWORD PTR [rsp+0x70],r13
    1600:	mov    QWORD PTR [rsp+0x78],0x0
    1609:	mov    QWORD PTR [rsp+0x80],r15
    1611:	mov    esi,0x2
    1616:	mov    edx,0x4
    161b:	mov    rcx,r14
    161e:	mov    rdi,QWORD PTR [rsp+0x88]
    1626:	call   162b <botlish_fn_18+0x180>
			1627: R_X86_64_PLT32	rt_construct-0x4
    162b:	test   rax,rax
    162e:	je     1882 <botlish_fn_18+0x3d7>
    1634:	mov    QWORD PTR [rsp],r12
    1638:	mov    rsi,QWORD PTR [rsp+0x90]
    1640:	mov    QWORD PTR [rsp+0x8],rsi
    1645:	mov    QWORD PTR [rsp+0x10],rax
    164a:	mov    r13,rax
    164d:	jmp    151e <botlish_fn_18+0x73>
    1652:	mov    QWORD PTR [rsp+0x18],0x3
    165b:	mov    rsi,QWORD PTR [rsp+0x90]
    1663:	test   rsi,0x1
    166a:	je     168a <botlish_fn_18+0x1df>
    1670:	mov    rsi,QWORD PTR [rsp+0x90]
    1678:	mov    rdx,rsi
    167b:	add    rdx,0x2
    167f:	seto   al
    1682:	test   al,al
    1684:	je     16a7 <botlish_fn_18+0x1fc>
    168a:	mov    edx,0x3
    168f:	mov    rsi,QWORD PTR [rsp+0x90]
    1697:	mov    rdi,QWORD PTR [rsp+0x88]
    169f:	call   16a4 <botlish_fn_18+0x1f9>
			16a0: R_X86_64_PLT32	rt_int_add-0x4
    16a4:	mov    rdx,rax
    16a7:	mov    QWORD PTR [rsp+0x18],rdx
    16ac:	mov    rcx,rbx
    16af:	mov    rsi,r12
    16b2:	mov    rdi,QWORD PTR [rsp+0x88]
    16ba:	call   16bf <botlish_fn_18+0x214>
			16bb: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    16bf:	test   rax,rax
    16c2:	mov    rsi,rax
    16c5:	je     1882 <botlish_fn_18+0x3d7>
    16cb:	mov    rdx,QWORD PTR [rsp+0x28]
    16d0:	mov    rcx,QWORD PTR [rsp+0x30]
    16d5:	mov    rdi,QWORD PTR [rsp+0x88]
    16dd:	mov    rax,QWORD PTR [rdi+0x10]
    16e1:	mov    r8,QWORD PTR [rax+0x20]
    16e5:	call   16ea <botlish_fn_18+0x23f>
			16e6: R_X86_64_PLT32	rt_str_region_eq-0x4
    16ea:	cmp    rax,0x6
    16ee:	je     17c0 <botlish_fn_18+0x315>
    16f4:	xor    rsi,rsi
    16f7:	lea    rcx,[rsp+0x58]
    16fc:	mov    QWORD PTR [rsp+0x58],0x0
    1705:	mov    QWORD PTR [rsp+0x60],r13
    170a:	mov    edx,0x2
    170f:	mov    rdi,QWORD PTR [rsp+0x88]
    1717:	call   171c <botlish_fn_18+0x271>
			1718: R_X86_64_PLT32	rt_construct-0x4
    171c:	test   rax,rax
    171f:	je     1882 <botlish_fn_18+0x3d7>
    1725:	mov    QWORD PTR [rsp],rax
    1729:	mov    rbx,rax
    172c:	mov    QWORD PTR [rsp+0x10],0x3
    1735:	mov    rsi,QWORD PTR [rsp+0x90]
    173d:	test   rsi,0x1
    1744:	je     176c <botlish_fn_18+0x2c1>
    174a:	mov    rsi,QWORD PTR [rsp+0x90]
    1752:	mov    rdx,rsi
    1755:	add    rdx,0x2
    1759:	seto   al
    175c:	test   al,al
    175e:	jne    176c <botlish_fn_18+0x2c1>
    1764:	mov    rax,rbx
    1767:	jmp    178c <botlish_fn_18+0x2e1>
    176c:	mov    edx,0x3
    1771:	mov    rsi,QWORD PTR [rsp+0x90]
    1779:	mov    rdi,QWORD PTR [rsp+0x88]
    1781:	call   1786 <botlish_fn_18+0x2db>
			1782: R_X86_64_PLT32	rt_int_add-0x4
    1786:	mov    rdx,rax
    1789:	mov    rax,rbx
    178c:	mov    rbx,QWORD PTR [rsp+0xa0]
    1794:	mov    r12,QWORD PTR [rsp+0xa8]
    179c:	mov    r13,QWORD PTR [rsp+0xb0]
    17a4:	mov    r14,QWORD PTR [rsp+0xb8]
    17ac:	mov    r15,QWORD PTR [rsp+0xc0]
    17b4:	add    rsp,0xd0
    17bb:	mov    rsp,rbp
    17be:	pop    rbp
    17bf:	ret
    17c0:	mov    QWORD PTR [rsp+0x18],0x5
    17c9:	mov    rsi,QWORD PTR [rsp+0x90]
    17d1:	test   rsi,0x1
    17d8:	je     180a <botlish_fn_18+0x35f>
    17de:	mov    rsi,QWORD PTR [rsp+0x90]
    17e6:	mov    rdi,rsi
    17e9:	add    rdi,0x4
    17ed:	seto   r9b
    17f1:	test   r9b,r9b
    17f4:	jne    180a <botlish_fn_18+0x35f>
    17fa:	mov    rsi,rdi
    17fd:	mov    QWORD PTR [rsp+0x90],rdi
    1805:	jmp    182f <botlish_fn_18+0x384>
    180a:	mov    edx,0x5
    180f:	mov    rsi,QWORD PTR [rsp+0x90]
    1817:	mov    rdi,QWORD PTR [rsp+0x88]
    181f:	call   1824 <botlish_fn_18+0x379>
			1820: R_X86_64_PLT32	rt_int_add-0x4
    1824:	mov    rsi,rax
    1827:	mov    QWORD PTR [rsp+0x90],rax
    182f:	mov    QWORD PTR [rsp+0x8],rsi
    1834:	mov    rdi,QWORD PTR [rsp+0x88]
    183c:	mov    rax,QWORD PTR [rdi+0x10]
    1840:	mov    rax,QWORD PTR [rax+0x20]
    1844:	mov    QWORD PTR [rsp+0x18],rax
    1849:	lea    rcx,[rsp+0x38]
    184e:	mov    QWORD PTR [rsp+0x38],0x0
    1857:	mov    QWORD PTR [rsp+0x40],r13
    185c:	mov    QWORD PTR [rsp+0x48],0x0
    1865:	mov    QWORD PTR [rsp+0x50],rax
    186a:	mov    esi,0x2
    186f:	mov    edx,0x4
    1874:	call   1879 <botlish_fn_18+0x3ce>
			1875: R_X86_64_PLT32	rt_construct-0x4
    1879:	test   rax,rax
    187c:	jne    18bc <botlish_fn_18+0x411>
    1882:	xor    rdx,rdx
    1885:	mov    rax,rdx
    1888:	mov    rbx,QWORD PTR [rsp+0xa0]
    1890:	mov    r12,QWORD PTR [rsp+0xa8]
    1898:	mov    r13,QWORD PTR [rsp+0xb0]
    18a0:	mov    r14,QWORD PTR [rsp+0xb8]
    18a8:	mov    r15,QWORD PTR [rsp+0xc0]
    18b0:	add    rsp,0xd0
    18b7:	mov    rsp,rbp
    18ba:	pop    rbp
    18bb:	ret
    18bc:	mov    QWORD PTR [rsp],r12
    18c0:	mov    rsi,QWORD PTR [rsp+0x90]
    18c8:	mov    QWORD PTR [rsp+0x8],rsi
    18cd:	mov    QWORD PTR [rsp+0x10],rax
    18d2:	mov    r13,rax
    18d5:	jmp    151e <botlish_fn_18+0x73>

00000000000018da <botlish_entry_18: scan_quoted<str, int, str>>:
    18da:	push   rbp
    18db:	mov    rbp,rsp
    18de:	ud2

00000000000018e0 <botlish_fn_19: scan_field<str, int>>:
    18e0:	push   rbp
    18e1:	mov    rbp,rsp
    18e4:	sub    rsp,0x50
    18e8:	mov    QWORD PTR [rsp+0x30],rbx
    18ed:	mov    QWORD PTR [rsp+0x38],r12
    18f2:	mov    QWORD PTR [rsp+0x40],r13
    18f7:	mov    r12,rdi
    18fa:	mov    r13,rdx
    18fd:	mov    QWORD PTR [rsp+0x10],0x0
    1906:	mov    QWORD PTR [rsp],rsi
    190a:	mov    rbx,rsi
    190d:	mov    QWORD PTR [rsp+0x8],rdx
    1912:	lea    rcx,[rsp+0x18]
    1917:	mov    rdx,r13
    191a:	mov    rsi,rbx
    191d:	mov    rdi,r12
    1920:	call   1925 <botlish_fn_19+0x45>
			1921: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1925:	test   rax,rax
    1928:	mov    rsi,rax
    192b:	je     19f6 <botlish_fn_19+0x116>
    1931:	mov    rdx,QWORD PTR [rsp+0x18]
    1936:	mov    rcx,QWORD PTR [rsp+0x20]
    193b:	mov    rdi,r12
    193e:	mov    rax,QWORD PTR [rdi+0x10]
    1942:	mov    r8,QWORD PTR [rax+0x20]
    1946:	call   194b <botlish_fn_19+0x6b>
			1947: R_X86_64_PLT32	rt_str_region_eq-0x4
    194b:	cmp    rax,0x6
    194f:	je     1987 <botlish_fn_19+0xa7>
    1955:	mov    rcx,r13
    1958:	mov    rsi,rbx
    195b:	mov    rdi,r12
    195e:	mov    rdx,rcx
    1961:	call   1966 <botlish_fn_19+0x86>
			1962: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    1966:	test   rax,rax
    1969:	je     19f6 <botlish_fn_19+0x116>
    196f:	mov    rbx,QWORD PTR [rsp+0x30]
    1974:	mov    r12,QWORD PTR [rsp+0x38]
    1979:	mov    r13,QWORD PTR [rsp+0x40]
    197e:	add    rsp,0x50
    1982:	mov    rsp,rbp
    1985:	pop    rbp
    1986:	ret
    1987:	mov    rcx,r13
    198a:	mov    QWORD PTR [rsp+0x10],0x3
    1993:	test   rcx,0x1
    199a:	jne    19a8 <botlish_fn_19+0xc8>
    19a0:	mov    r13,rcx
    19a3:	jmp    19bd <botlish_fn_19+0xdd>
    19a8:	mov    rdx,rcx
    19ab:	add    rdx,0x2
    19af:	mov    r13,rcx
    19b2:	seto   al
    19b5:	test   al,al
    19b7:	je     19d0 <botlish_fn_19+0xf0>
    19bd:	mov    edx,0x3
    19c2:	mov    rsi,r13
    19c5:	mov    rdi,r12
    19c8:	call   19cd <botlish_fn_19+0xed>
			19c9: R_X86_64_PLT32	rt_int_add-0x4
    19cd:	mov    rdx,rax
    19d0:	mov    QWORD PTR [rsp+0x8],rdx
    19d5:	mov    rdi,r12
    19d8:	mov    rax,QWORD PTR [rdi+0x10]
    19dc:	mov    rcx,QWORD PTR [rax+0x8]
    19e0:	mov    QWORD PTR [rsp+0x10],rcx
    19e5:	mov    rsi,rbx
    19e8:	call   19ed <botlish_fn_19+0x10d>
			19e9: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    19ed:	test   rax,rax
    19f0:	jne    1a14 <botlish_fn_19+0x134>
    19f6:	xor    rdx,rdx
    19f9:	mov    rax,rdx
    19fc:	mov    rbx,QWORD PTR [rsp+0x30]
    1a01:	mov    r12,QWORD PTR [rsp+0x38]
    1a06:	mov    r13,QWORD PTR [rsp+0x40]
    1a0b:	add    rsp,0x50
    1a0f:	mov    rsp,rbp
    1a12:	pop    rbp
    1a13:	ret
    1a14:	mov    rbx,QWORD PTR [rsp+0x30]
    1a19:	mov    r12,QWORD PTR [rsp+0x38]
    1a1e:	mov    r13,QWORD PTR [rsp+0x40]
    1a23:	add    rsp,0x50
    1a27:	mov    rsp,rbp
    1a2a:	pop    rbp
    1a2b:	ret

0000000000001a2c <botlish_entry_19: scan_field<str, int>>:
    1a2c:	push   rbp
    1a2d:	mov    rbp,rsp
    1a30:	ud2

0000000000001a32 <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    1a32:	push   rbp
    1a33:	mov    rbp,rsp
    1a36:	sub    rsp,0x90
    1a3d:	mov    QWORD PTR [rsp+0x60],rbx
    1a42:	mov    QWORD PTR [rsp+0x68],r12
    1a47:	mov    QWORD PTR [rsp+0x70],r13
    1a4c:	mov    QWORD PTR [rsp+0x78],r14
    1a51:	mov    QWORD PTR [rsp+0x80],r15
    1a59:	mov    r15,rdi
    1a5c:	mov    QWORD PTR [rsp+0x20],0x0
    1a65:	mov    QWORD PTR [rsp],rsi
    1a69:	mov    QWORD PTR [rsp+0x8],rdx
    1a6e:	mov    QWORD PTR [rsp+0x10],rcx
    1a73:	mov    QWORD PTR [rsp+0x18],r8
    1a78:	lea    r12,[rsp+0x28]
    1a7d:	mov    rbx,rsi
    1a80:	mov    QWORD PTR [rsp+0x38],rdx
    1a85:	mov    QWORD PTR [rsp+0x40],rcx
    1a8a:	mov    QWORD PTR [rsp+0x48],r8
    1a8f:	mov    rcx,r12
    1a92:	mov    rdx,QWORD PTR [rsp+0x38]
    1a97:	mov    rsi,rbx
    1a9a:	mov    rdi,r15
    1a9d:	call   1aa2 <botlish_fn_20+0x70>
			1a9e: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1aa2:	test   rax,rax
    1aa5:	mov    QWORD PTR [rsp+0x50],rax
    1aaa:	je     1c6e <botlish_fn_20+0x23c>
    1ab0:	mov    r14,QWORD PTR [rsp+0x28]
    1ab5:	mov    r13,QWORD PTR [rsp+0x30]
    1aba:	mov    rdi,r15
    1abd:	mov    rcx,QWORD PTR [rdi+0x10]
    1ac1:	mov    r8,QWORD PTR [rcx+0x10]
    1ac5:	mov    rcx,r13
    1ac8:	mov    rdx,r14
    1acb:	mov    rsi,QWORD PTR [rsp+0x50]
    1ad0:	call   1ad5 <botlish_fn_20+0xa3>
			1ad1: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ad5:	cmp    rax,0x6
    1ad9:	je     1be7 <botlish_fn_20+0x1b5>
    1adf:	mov    rdi,r15
    1ae2:	mov    rax,QWORD PTR [rdi+0x10]
    1ae6:	mov    r8,QWORD PTR [rax+0x18]
    1aea:	mov    rcx,r13
    1aed:	mov    rdx,r14
    1af0:	mov    rsi,QWORD PTR [rsp+0x50]
    1af5:	call   1afa <botlish_fn_20+0xc8>
			1af6: R_X86_64_PLT32	rt_str_region_eq-0x4
    1afa:	cmp    rax,0x6
    1afe:	je     1b4c <botlish_fn_20+0x11a>
    1b04:	mov    rdx,QWORD PTR [rsp+0x48]
    1b09:	mov    rsi,QWORD PTR [rsp+0x40]
    1b0e:	mov    rdi,r15
    1b11:	call   1b16 <botlish_fn_20+0xe4>
			1b12: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b16:	test   rax,rax
    1b19:	je     1c6e <botlish_fn_20+0x23c>
    1b1f:	mov    rdx,QWORD PTR [rsp+0x38]
    1b24:	mov    rbx,QWORD PTR [rsp+0x60]
    1b29:	mov    r12,QWORD PTR [rsp+0x68]
    1b2e:	mov    r13,QWORD PTR [rsp+0x70]
    1b33:	mov    r14,QWORD PTR [rsp+0x78]
    1b38:	mov    r15,QWORD PTR [rsp+0x80]
    1b40:	add    rsp,0x90
    1b47:	mov    rsp,rbp
    1b4a:	pop    rbp
    1b4b:	ret
    1b4c:	mov    rdx,QWORD PTR [rsp+0x48]
    1b51:	mov    rsi,QWORD PTR [rsp+0x40]
    1b56:	mov    rdi,r15
    1b59:	call   1b5e <botlish_fn_20+0x12c>
			1b5a: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b5e:	test   rax,rax
    1b61:	je     1c6e <botlish_fn_20+0x23c>
    1b67:	mov    QWORD PTR [rsp],rax
    1b6b:	mov    rbx,rax
    1b6e:	mov    QWORD PTR [rsp+0x10],0x3
    1b77:	mov    rdx,QWORD PTR [rsp+0x38]
    1b7c:	test   rdx,0x1
    1b83:	je     1ba7 <botlish_fn_20+0x175>
    1b89:	mov    rdx,QWORD PTR [rsp+0x38]
    1b8e:	add    rdx,0x2
    1b92:	seto   sil
    1b96:	test   sil,sil
    1b99:	jne    1ba7 <botlish_fn_20+0x175>
    1b9f:	mov    rax,rbx
    1ba2:	jmp    1bbf <botlish_fn_20+0x18d>
    1ba7:	mov    edx,0x3
    1bac:	mov    rsi,QWORD PTR [rsp+0x38]
    1bb1:	mov    rdi,r15
    1bb4:	call   1bb9 <botlish_fn_20+0x187>
			1bb5: R_X86_64_PLT32	rt_int_add-0x4
    1bb9:	mov    rdx,rax
    1bbc:	mov    rax,rbx
    1bbf:	mov    rbx,QWORD PTR [rsp+0x60]
    1bc4:	mov    r12,QWORD PTR [rsp+0x68]
    1bc9:	mov    r13,QWORD PTR [rsp+0x70]
    1bce:	mov    r14,QWORD PTR [rsp+0x78]
    1bd3:	mov    r15,QWORD PTR [rsp+0x80]
    1bdb:	add    rsp,0x90
    1be2:	mov    rsp,rbp
    1be5:	pop    rbp
    1be6:	ret
    1be7:	mov    rsi,QWORD PTR [rsp+0x38]
    1bec:	mov    edx,0x3
    1bf1:	mov    r13,rdx
    1bf4:	mov    QWORD PTR [rsp+0x20],0x3
    1bfd:	test   rsi,0x1
    1c04:	je     1c1c <botlish_fn_20+0x1ea>
    1c0a:	mov    rdx,rsi
    1c0d:	add    rdx,0x2
    1c11:	seto   al
    1c14:	test   al,al
    1c16:	je     1c2a <botlish_fn_20+0x1f8>
    1c1c:	mov    rdx,r13
    1c1f:	mov    rdi,r15
    1c22:	call   1c27 <botlish_fn_20+0x1f5>
			1c23: R_X86_64_PLT32	rt_int_add-0x4
    1c27:	mov    rdx,rax
    1c2a:	mov    QWORD PTR [rsp+0x8],rdx
    1c2f:	mov    rsi,rbx
    1c32:	mov    rdi,r15
    1c35:	call   1c3a <botlish_fn_20+0x208>
			1c36: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1c3a:	test   rax,rax
    1c3d:	je     1c6e <botlish_fn_20+0x23c>
    1c43:	mov    QWORD PTR [rsp+0x8],rax
    1c48:	mov    rcx,rax
    1c4b:	mov    QWORD PTR [rsp+0x20],rdx
    1c50:	mov    rsi,QWORD PTR [rsp+0x40]
    1c55:	mov    r14,rdx
    1c58:	mov    rdx,QWORD PTR [rsp+0x48]
    1c5d:	mov    rdi,r15
    1c60:	call   1c65 <botlish_fn_20+0x233>
			1c61: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1c65:	test   rax,rax
    1c68:	jne    1c9c <botlish_fn_20+0x26a>
    1c6e:	xor    rdx,rdx
    1c71:	mov    rax,rdx
    1c74:	mov    rbx,QWORD PTR [rsp+0x60]
    1c79:	mov    r12,QWORD PTR [rsp+0x68]
    1c7e:	mov    r13,QWORD PTR [rsp+0x70]
    1c83:	mov    r14,QWORD PTR [rsp+0x78]
    1c88:	mov    r15,QWORD PTR [rsp+0x80]
    1c90:	add    rsp,0x90
    1c97:	mov    rsp,rbp
    1c9a:	pop    rbp
    1c9b:	ret
    1c9c:	mov    QWORD PTR [rsp+0x8],rax
    1ca1:	mov    QWORD PTR [rsp+0x38],rax
    1ca6:	mov    QWORD PTR [rsp+0x10],0x3
    1caf:	mov    rdx,QWORD PTR [rsp+0x48]
    1cb4:	test   rdx,0x1
    1cbb:	jne    1cce <botlish_fn_20+0x29c>
    1cc1:	mov    rdx,r13
    1cc4:	mov    rsi,QWORD PTR [rsp+0x48]
    1cc9:	jmp    1ced <botlish_fn_20+0x2bb>
    1cce:	mov    rdx,QWORD PTR [rsp+0x48]
    1cd3:	mov    rax,rdx
    1cd6:	add    rax,0x2
    1cda:	seto   cl
    1cdd:	test   cl,cl
    1cdf:	je     1cf5 <botlish_fn_20+0x2c3>
    1ce5:	mov    rdx,r13
    1ce8:	mov    rsi,QWORD PTR [rsp+0x48]
    1ced:	mov    rdi,r15
    1cf0:	call   1cf5 <botlish_fn_20+0x2c3>
			1cf1: R_X86_64_PLT32	rt_int_add-0x4
    1cf5:	mov    QWORD PTR [rsp],rbx
    1cf9:	mov    rdx,r14
    1cfc:	mov    QWORD PTR [rsp+0x8],rdx
    1d01:	mov    rcx,QWORD PTR [rsp+0x38]
    1d06:	mov    QWORD PTR [rsp+0x10],rcx
    1d0b:	mov    QWORD PTR [rsp+0x18],rax
    1d10:	mov    QWORD PTR [rsp+0x38],rdx
    1d15:	mov    QWORD PTR [rsp+0x40],rcx
    1d1a:	mov    QWORD PTR [rsp+0x48],rax
    1d1f:	jmp    1a8f <botlish_fn_20+0x5d>

0000000000001d24 <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1d24:	push   rbp
    1d25:	mov    rbp,rsp
    1d28:	ud2

0000000000001d2a <botlish_fn_21: scan_record<str, int>>:
    1d2a:	push   rbp
    1d2b:	mov    rbp,rsp
    1d2e:	sub    rsp,0x40
    1d32:	mov    QWORD PTR [rsp+0x20],rbx
    1d37:	mov    QWORD PTR [rsp+0x28],r12
    1d3c:	mov    QWORD PTR [rsp+0x30],r14
    1d41:	mov    r14,rdi
    1d44:	mov    QWORD PTR [rsp+0x10],0x0
    1d4d:	mov    QWORD PTR [rsp+0x18],0x0
    1d56:	mov    QWORD PTR [rsp],rsi
    1d5a:	mov    r12,rsi
    1d5d:	mov    QWORD PTR [rsp+0x8],rdx
    1d62:	mov    rsi,r12
    1d65:	mov    rdi,r14
    1d68:	call   1d6d <botlish_fn_21+0x43>
			1d69: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1d6d:	test   rax,rax
    1d70:	je     1dc5 <botlish_fn_21+0x9b>
    1d76:	mov    QWORD PTR [rsp+0x8],rax
    1d7b:	mov    rsi,rax
    1d7e:	mov    QWORD PTR [rsp+0x10],rdx
    1d83:	mov    rbx,rdx
    1d86:	mov    rdi,r14
    1d89:	call   1d8e <botlish_fn_21+0x64>
			1d8a: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1d8e:	test   rax,rax
    1d91:	je     1dc5 <botlish_fn_21+0x9b>
    1d97:	mov    QWORD PTR [rsp+0x8],rax
    1d9c:	mov    rcx,rax
    1d9f:	mov    r8d,0x3
    1da5:	mov    QWORD PTR [rsp+0x18],0x3
    1dae:	mov    rdx,rbx
    1db1:	mov    rsi,r12
    1db4:	mov    rdi,r14
    1db7:	call   1dbc <botlish_fn_21+0x92>
			1db8: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1dbc:	test   rax,rax
    1dbf:	jne    1de3 <botlish_fn_21+0xb9>
    1dc5:	xor    rdx,rdx
    1dc8:	mov    rax,rdx
    1dcb:	mov    rbx,QWORD PTR [rsp+0x20]
    1dd0:	mov    r12,QWORD PTR [rsp+0x28]
    1dd5:	mov    r14,QWORD PTR [rsp+0x30]
    1dda:	add    rsp,0x40
    1dde:	mov    rsp,rbp
    1de1:	pop    rbp
    1de2:	ret
    1de3:	mov    rbx,QWORD PTR [rsp+0x20]
    1de8:	mov    r12,QWORD PTR [rsp+0x28]
    1ded:	mov    r14,QWORD PTR [rsp+0x30]
    1df2:	add    rsp,0x40
    1df6:	mov    rsp,rbp
    1df9:	pop    rbp
    1dfa:	ret

0000000000001dfb <botlish_entry_21: scan_record<str, int>>:
    1dfb:	push   rbp
    1dfc:	mov    rbp,rsp
    1dff:	ud2
    1e01:	add    BYTE PTR [rax],al
    1e03:	add    BYTE PTR [rax],al
    1e05:	add    BYTE PTR [rax],al
	...

0000000000001e08 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1e08:	push   rbp
    1e09:	mov    rbp,rsp
    1e0c:	sub    rsp,0x60
    1e10:	mov    QWORD PTR [rsp+0x30],rbx
    1e15:	mov    QWORD PTR [rsp+0x38],r12
    1e1a:	mov    QWORD PTR [rsp+0x40],r13
    1e1f:	mov    QWORD PTR [rsp+0x48],r14
    1e24:	mov    QWORD PTR [rsp+0x50],r15
    1e29:	mov    r13,rdi
    1e2c:	mov    QWORD PTR [rsp+0x20],0x0
    1e35:	mov    QWORD PTR [rsp],rsi
    1e39:	mov    QWORD PTR [rsp+0x8],rdx
    1e3e:	mov    r12,rdx
    1e41:	mov    QWORD PTR [rsp+0x10],rcx
    1e46:	mov    QWORD PTR [rsp+0x18],r8
    1e4b:	mov    rbx,rsi
    1e4e:	mov    r14,r8
    1e51:	mov    r15,rcx
    1e54:	mov    rsi,rbx
    1e57:	mov    rdi,r13
    1e5a:	call   1e5f <botlish_fn_22+0x57>
			1e5b: R_X86_64_PLT32	rt_str_len-0x4
    1e5f:	mov    rcx,r12
    1e62:	and    rcx,rax
    1e65:	mov    rdx,rax
    1e68:	test   rcx,0x1
    1e6f:	jne    1e95 <botlish_fn_22+0x8d>
    1e75:	mov    rsi,r12
    1e78:	mov    rdi,r13
    1e7b:	call   1e80 <botlish_fn_22+0x78>
			1e7c: R_X86_64_PLT32	rt_int_cmp-0x4
    1e80:	mov    ecx,0x2
    1e85:	test   rax,rax
    1e88:	cmovge rcx,QWORD PTR [rip+0x128]        # 1fb8 <botlish_fn_22+0x1b0>
    1e90:	jmp    1ea5 <botlish_fn_22+0x9d>
    1e95:	mov    ecx,0x2
    1e9a:	cmp    r12,rdx
    1e9d:	cmovge rcx,QWORD PTR [rip+0x113]        # 1fb8 <botlish_fn_22+0x1b0>
    1ea5:	cmp    rcx,0x6
    1ea9:	je     1f54 <botlish_fn_22+0x14c>
    1eaf:	mov    rdx,r12
    1eb2:	mov    rsi,rbx
    1eb5:	mov    rdi,r13
    1eb8:	call   1ebd <botlish_fn_22+0xb5>
			1eb9: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1ebd:	test   rax,rax
    1ec0:	je     1f6b <botlish_fn_22+0x163>
    1ec6:	mov    QWORD PTR [rsp+0x8],rax
    1ecb:	mov    rcx,rax
    1ece:	mov    QWORD PTR [rsp+0x20],rdx
    1ed3:	mov    rsi,r15
    1ed6:	mov    r12,rdx
    1ed9:	mov    rdx,r14
    1edc:	mov    rdi,r13
    1edf:	call   1ee4 <botlish_fn_22+0xdc>
			1ee0: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1ee4:	test   rax,rax
    1ee7:	je     1f6b <botlish_fn_22+0x163>
    1eed:	mov    QWORD PTR [rsp+0x8],rax
    1ef2:	mov    r15,rax
    1ef5:	mov    QWORD PTR [rsp+0x10],0x3
    1efe:	mov    rsi,r14
    1f01:	test   rsi,0x1
    1f08:	je     1f23 <botlish_fn_22+0x11b>
    1f0e:	mov    rsi,r14
    1f11:	mov    rax,rsi
    1f14:	add    rax,0x2
    1f18:	seto   cl
    1f1b:	test   cl,cl
    1f1d:	je     1f33 <botlish_fn_22+0x12b>
    1f23:	mov    edx,0x3
    1f28:	mov    rsi,r14
    1f2b:	mov    rdi,r13
    1f2e:	call   1f33 <botlish_fn_22+0x12b>
			1f2f: R_X86_64_PLT32	rt_int_add-0x4
    1f33:	mov    QWORD PTR [rsp],rbx
    1f37:	mov    rdx,r12
    1f3a:	mov    QWORD PTR [rsp+0x8],rdx
    1f3f:	mov    rcx,r15
    1f42:	mov    QWORD PTR [rsp+0x10],rcx
    1f47:	mov    QWORD PTR [rsp+0x18],rax
    1f4c:	mov    r14,rax
    1f4f:	jmp    1e54 <botlish_fn_22+0x4c>
    1f54:	mov    rdx,r14
    1f57:	mov    rsi,r15
    1f5a:	mov    rdi,r13
    1f5d:	call   1f62 <botlish_fn_22+0x15a>
			1f5e: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1f62:	test   rax,rax
    1f65:	jne    1f90 <botlish_fn_22+0x188>
    1f6b:	xor    rax,rax
    1f6e:	mov    rbx,QWORD PTR [rsp+0x30]
    1f73:	mov    r12,QWORD PTR [rsp+0x38]
    1f78:	mov    r13,QWORD PTR [rsp+0x40]
    1f7d:	mov    r14,QWORD PTR [rsp+0x48]
    1f82:	mov    r15,QWORD PTR [rsp+0x50]
    1f87:	add    rsp,0x60
    1f8b:	mov    rsp,rbp
    1f8e:	pop    rbp
    1f8f:	ret
    1f90:	mov    rbx,QWORD PTR [rsp+0x30]
    1f95:	mov    r12,QWORD PTR [rsp+0x38]
    1f9a:	mov    r13,QWORD PTR [rsp+0x40]
    1f9f:	mov    r14,QWORD PTR [rsp+0x48]
    1fa4:	mov    r15,QWORD PTR [rsp+0x50]
    1fa9:	add    rsp,0x60
    1fad:	mov    rsp,rbp
    1fb0:	pop    rbp
    1fb1:	ret
    1fb2:	add    BYTE PTR [rax],al
    1fb4:	add    BYTE PTR [rax],al
    1fb6:	add    BYTE PTR [rax],al
    1fb8:	(bad)
    1fb9:	add    BYTE PTR [rax],al
    1fbb:	add    BYTE PTR [rax],al
    1fbd:	add    BYTE PTR [rax],al
	...

0000000000001fc0 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    1fc0:	push   rbp
    1fc1:	mov    rbp,rsp
    1fc4:	mov    rsi,QWORD PTR [rdx]
    1fc7:	mov    r9,QWORD PTR [rdx+0x8]
    1fcb:	mov    rcx,QWORD PTR [rdx+0x10]
    1fcf:	mov    r8,QWORD PTR [rdx+0x18]
    1fd3:	mov    rdx,r9
    1fd6:	call   1fdb <botlish_entry_22+0x1b>
			1fd7: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    1fdb:	mov    rsp,rbp
    1fde:	pop    rbp
    1fdf:	ret

0000000000001fe0 <botlish_fn_23: csv_parse<str>>:
    1fe0:	push   rbp
    1fe1:	mov    rbp,rsp
    1fe4:	sub    rsp,0x40
    1fe8:	mov    QWORD PTR [rsp+0x20],rbx
    1fed:	mov    QWORD PTR [rsp+0x28],r12
    1ff2:	mov    QWORD PTR [rsp+0x30],r13
    1ff7:	mov    rbx,rdi
    1ffa:	mov    QWORD PTR [rsp+0x8],0x0
    2003:	mov    QWORD PTR [rsp+0x10],0x0
    200c:	mov    QWORD PTR [rsp+0x18],0x0
    2015:	mov    QWORD PTR [rsp],rsi
    2019:	mov    r12,rsi
    201c:	mov    rsi,r12
    201f:	mov    rdi,rbx
    2022:	call   2027 <botlish_fn_23+0x47>
			2023: R_X86_64_PLT32	rt_str_len-0x4
    2027:	sar    rax,1
    202a:	test   rax,rax
    202d:	je     20bc <botlish_fn_23+0xdc>
    2033:	mov    edx,0x1
    2038:	mov    QWORD PTR [rsp+0x8],0x1
    2041:	mov    rsi,r12
    2044:	mov    rdi,rbx
    2047:	call   204c <botlish_fn_23+0x6c>
			2048: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    204c:	test   rax,rax
    204f:	je     20d3 <botlish_fn_23+0xf3>
    2055:	mov    QWORD PTR [rsp+0x8],rax
    205a:	mov    rsi,rax
    205d:	mov    QWORD PTR [rsp+0x10],rdx
    2062:	mov    r13,rdx
    2065:	mov    rdi,rbx
    2068:	call   206d <botlish_fn_23+0x8d>
			2069: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    206d:	test   rax,rax
    2070:	je     20d3 <botlish_fn_23+0xf3>
    2076:	mov    QWORD PTR [rsp+0x8],rax
    207b:	mov    rcx,rax
    207e:	mov    r8d,0x3
    2084:	mov    QWORD PTR [rsp+0x18],0x3
    208d:	mov    rdx,r13
    2090:	mov    rsi,r12
    2093:	mov    rdi,rbx
    2096:	call   209b <botlish_fn_23+0xbb>
			2097: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    209b:	test   rax,rax
    209e:	je     20d3 <botlish_fn_23+0xf3>
    20a4:	mov    rbx,QWORD PTR [rsp+0x20]
    20a9:	mov    r12,QWORD PTR [rsp+0x28]
    20ae:	mov    r13,QWORD PTR [rsp+0x30]
    20b3:	add    rsp,0x40
    20b7:	mov    rsp,rbp
    20ba:	pop    rbp
    20bb:	ret
    20bc:	xor    rdx,rdx
    20bf:	mov    rdi,rbx
    20c2:	mov    rsi,rdx
    20c5:	call   20ca <botlish_fn_23+0xea>
			20c6: R_X86_64_PLT32	rt_list_new-0x4
    20ca:	test   rax,rax
    20cd:	jne    20ee <botlish_fn_23+0x10e>
    20d3:	xor    rax,rax
    20d6:	mov    rbx,QWORD PTR [rsp+0x20]
    20db:	mov    r12,QWORD PTR [rsp+0x28]
    20e0:	mov    r13,QWORD PTR [rsp+0x30]
    20e5:	add    rsp,0x40
    20e9:	mov    rsp,rbp
    20ec:	pop    rbp
    20ed:	ret
    20ee:	mov    rbx,QWORD PTR [rsp+0x20]
    20f3:	mov    r12,QWORD PTR [rsp+0x28]
    20f8:	mov    r13,QWORD PTR [rsp+0x30]
    20fd:	add    rsp,0x40
    2101:	mov    rsp,rbp
    2104:	pop    rbp
    2105:	ret

0000000000002106 <botlish_entry_23: csv_parse<str>>:
    2106:	push   rbp
    2107:	mov    rbp,rsp
    210a:	mov    rsi,QWORD PTR [rdx]
    210d:	call   2112 <botlish_entry_23+0xc>
			210e: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    2112:	mov    rsp,rbp
    2115:	pop    rbp
    2116:	ret
	...

0000000000002118 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    2118:	push   rbp
    2119:	mov    rbp,rsp
    211c:	sub    rsp,0x40
    2120:	mov    QWORD PTR [rsp+0x20],rbx
    2125:	mov    QWORD PTR [rsp+0x28],r12
    212a:	mov    QWORD PTR [rsp+0x30],r13
    212f:	mov    QWORD PTR [rsp+0x38],r14
    2134:	mov    r13,rdi
    2137:	mov    QWORD PTR [rsp],rsi
    213b:	mov    rbx,rsi
    213e:	mov    QWORD PTR [rsp+0x8],rdx
    2143:	mov    QWORD PTR [rsp+0x10],rcx
    2148:	mov    r12,rcx
    214b:	mov    rsi,rdx
    214e:	mov    rax,rsi
    2151:	and    rax,r12
    2154:	mov    r14,rsi
    2157:	test   rax,0x1
    215d:	jne    2186 <botlish_fn_24+0x6e>
    2163:	mov    rdx,r12
    2166:	mov    rsi,r14
    2169:	mov    rdi,r13
    216c:	call   2171 <botlish_fn_24+0x59>
			216d: R_X86_64_PLT32	rt_int_cmp-0x4
    2171:	mov    ecx,0x2
    2176:	test   rax,rax
    2179:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2260 <botlish_fn_24+0x148>
    2181:	jmp    2199 <botlish_fn_24+0x81>
    2186:	mov    ecx,0x2
    218b:	mov    rsi,r14
    218e:	cmp    rsi,r12
    2191:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2260 <botlish_fn_24+0x148>
    2199:	cmp    rcx,0x6
    219d:	je     223e <botlish_fn_24+0x126>
    21a3:	mov    ecx,0x1
    21a8:	mov    rdx,r14
    21ab:	mov    rsi,rbx
    21ae:	mov    rdi,r13
    21b1:	call   21b6 <botlish_fn_24+0x9e>
			21b2: R_X86_64_PLT32	rt_mutarray_set-0x4
    21b6:	test   rax,rax
    21b9:	jne    21df <botlish_fn_24+0xc7>
    21bf:	xor    rax,rax
    21c2:	mov    rbx,QWORD PTR [rsp+0x20]
    21c7:	mov    r12,QWORD PTR [rsp+0x28]
    21cc:	mov    r13,QWORD PTR [rsp+0x30]
    21d1:	mov    r14,QWORD PTR [rsp+0x38]
    21d6:	add    rsp,0x40
    21da:	mov    rsp,rbp
    21dd:	pop    rbp
    21de:	ret
    21df:	mov    QWORD PTR [rsp+0x18],0x3
    21e8:	mov    rsi,r14
    21eb:	test   rsi,0x1
    21f2:	je     2215 <botlish_fn_24+0xfd>
    21f8:	mov    rsi,r14
    21fb:	mov    rcx,rsi
    21fe:	add    rcx,0x2
    2202:	seto   al
    2205:	test   al,al
    2207:	jne    2215 <botlish_fn_24+0xfd>
    220d:	mov    r14,rcx
    2210:	jmp    2228 <botlish_fn_24+0x110>
    2215:	mov    edx,0x3
    221a:	mov    rsi,r14
    221d:	mov    rdi,r13
    2220:	call   2225 <botlish_fn_24+0x10d>
			2221: R_X86_64_PLT32	rt_int_add-0x4
    2225:	mov    r14,rax
    2228:	mov    QWORD PTR [rsp],rbx
    222c:	mov    rsi,r14
    222f:	mov    QWORD PTR [rsp+0x8],rsi
    2234:	mov    QWORD PTR [rsp+0x10],r12
    2239:	jmp    214e <botlish_fn_24+0x36>
    223e:	mov    eax,0xa
    2243:	mov    rbx,QWORD PTR [rsp+0x20]
    2248:	mov    r12,QWORD PTR [rsp+0x28]
    224d:	mov    r13,QWORD PTR [rsp+0x30]
    2252:	mov    r14,QWORD PTR [rsp+0x38]
    2257:	add    rsp,0x40
    225b:	mov    rsp,rbp
    225e:	pop    rbp
    225f:	ret
    2260:	(bad)
    2261:	add    BYTE PTR [rax],al
    2263:	add    BYTE PTR [rax],al
    2265:	add    BYTE PTR [rax],al
	...

0000000000002268 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    2268:	push   rbp
    2269:	mov    rbp,rsp
    226c:	mov    rsi,QWORD PTR [rdx]
    226f:	mov    r8,QWORD PTR [rdx+0x8]
    2273:	mov    rcx,QWORD PTR [rdx+0x10]
    2277:	mov    rdx,r8
    227a:	call   227f <botlish_entry_24+0x17>
			227b: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    227f:	mov    rsp,rbp
    2282:	pop    rbp
    2283:	ret

0000000000002284 <botlish_fn_25: ht_alloc<int>>:
    2284:	push   rbp
    2285:	mov    rbp,rsp
    2288:	sub    rsp,0x50
    228c:	mov    QWORD PTR [rsp+0x20],rbx
    2291:	mov    QWORD PTR [rsp+0x28],r12
    2296:	mov    QWORD PTR [rsp+0x30],r13
    229b:	mov    QWORD PTR [rsp+0x38],r14
    22a0:	mov    QWORD PTR [rsp+0x40],r15
    22a5:	mov    rbx,rdi
    22a8:	mov    QWORD PTR [rsp+0x8],0x0
    22b1:	mov    QWORD PTR [rsp+0x10],0x0
    22ba:	mov    QWORD PTR [rsp+0x18],0x0
    22c3:	mov    QWORD PTR [rsp],rsi
    22c7:	mov    r13,rsi
    22ca:	mov    rsi,r13
    22cd:	mov    rdi,rbx
    22d0:	call   22d5 <botlish_fn_25+0x51>
			22d1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22d5:	test   rax,rax
    22d8:	je     23f4 <botlish_fn_25+0x170>
    22de:	mov    QWORD PTR [rsp+0x8],rax
    22e3:	mov    r12,rax
    22e6:	mov    edx,0x1
    22eb:	mov    QWORD PTR [rsp+0x10],0x1
    22f4:	mov    rcx,r13
    22f7:	mov    rsi,r12
    22fa:	mov    rdi,rbx
    22fd:	call   2302 <botlish_fn_25+0x7e>
			22fe: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    2302:	test   rax,rax
    2305:	je     23f4 <botlish_fn_25+0x170>
    230b:	mov    rsi,r13
    230e:	mov    rdi,rbx
    2311:	call   2316 <botlish_fn_25+0x92>
			2312: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2316:	test   rax,rax
    2319:	je     23f4 <botlish_fn_25+0x170>
    231f:	mov    QWORD PTR [rsp+0x10],rax
    2324:	mov    rsi,r13
    2327:	mov    r14,rax
    232a:	mov    rdi,rbx
    232d:	call   2332 <botlish_fn_25+0xae>
			232e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2332:	test   rax,rax
    2335:	je     23f4 <botlish_fn_25+0x170>
    233b:	mov    QWORD PTR [rsp],rax
    233f:	mov    r13,rax
    2342:	mov    esi,0xb
    2347:	mov    QWORD PTR [rsp+0x18],0xb
    2350:	mov    rdi,rbx
    2353:	call   2358 <botlish_fn_25+0xd4>
			2354: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2358:	test   rax,rax
    235b:	mov    r15,rax
    235e:	je     23f4 <botlish_fn_25+0x170>
    2364:	mov    edx,0x1
    2369:	mov    rcx,r12
    236c:	mov    rsi,r15
    236f:	mov    rdi,rbx
    2372:	call   2377 <botlish_fn_25+0xf3>
			2373: R_X86_64_PLT32	rt_mutarray_set-0x4
    2377:	test   rax,rax
    237a:	je     23f4 <botlish_fn_25+0x170>
    2380:	mov    edx,0x3
    2385:	mov    rcx,r14
    2388:	mov    rsi,r15
    238b:	mov    rdi,rbx
    238e:	call   2393 <botlish_fn_25+0x10f>
			238f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2393:	test   rax,rax
    2396:	je     23f4 <botlish_fn_25+0x170>
    239c:	mov    edx,0x5
    23a1:	mov    rcx,r13
    23a4:	mov    rsi,r15
    23a7:	mov    rdi,rbx
    23aa:	call   23af <botlish_fn_25+0x12b>
			23ab: R_X86_64_PLT32	rt_mutarray_set-0x4
    23af:	test   rax,rax
    23b2:	je     23f4 <botlish_fn_25+0x170>
    23b8:	mov    edx,0x7
    23bd:	mov    ecx,0x1
    23c2:	mov    rsi,r15
    23c5:	mov    rdi,rbx
    23c8:	call   23cd <botlish_fn_25+0x149>
			23c9: R_X86_64_PLT32	rt_mutarray_set-0x4
    23cd:	test   rax,rax
    23d0:	je     23f4 <botlish_fn_25+0x170>
    23d6:	mov    edx,0x9
    23db:	mov    ecx,0x1
    23e0:	mov    rdi,rbx
    23e3:	mov    rsi,r15
    23e6:	call   23eb <botlish_fn_25+0x167>
			23e7: R_X86_64_PLT32	rt_mutarray_set-0x4
    23eb:	test   rax,rax
    23ee:	jne    2419 <botlish_fn_25+0x195>
    23f4:	xor    rax,rax
    23f7:	mov    rbx,QWORD PTR [rsp+0x20]
    23fc:	mov    r12,QWORD PTR [rsp+0x28]
    2401:	mov    r13,QWORD PTR [rsp+0x30]
    2406:	mov    r14,QWORD PTR [rsp+0x38]
    240b:	mov    r15,QWORD PTR [rsp+0x40]
    2410:	add    rsp,0x50
    2414:	mov    rsp,rbp
    2417:	pop    rbp
    2418:	ret
    2419:	mov    rax,r15
    241c:	mov    rbx,QWORD PTR [rsp+0x20]
    2421:	mov    r12,QWORD PTR [rsp+0x28]
    2426:	mov    r13,QWORD PTR [rsp+0x30]
    242b:	mov    r14,QWORD PTR [rsp+0x38]
    2430:	mov    r15,QWORD PTR [rsp+0x40]
    2435:	add    rsp,0x50
    2439:	mov    rsp,rbp
    243c:	pop    rbp
    243d:	ret

000000000000243e <botlish_entry_25: ht_alloc<int>>:
    243e:	push   rbp
    243f:	mov    rbp,rsp
    2442:	mov    rsi,QWORD PTR [rdx]
    2445:	call   244a <botlish_entry_25+0xc>
			2446: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    244a:	mov    rsp,rbp
    244d:	pop    rbp
    244e:	ret

000000000000244f <botlish_fn_26: ht_new<generic>>:
    244f:	push   rbp
    2450:	mov    rbp,rsp
    2453:	sub    rsp,0x10
    2457:	mov    esi,0x11
    245c:	mov    QWORD PTR [rsp],0x11
    2464:	call   2469 <botlish_fn_26+0x1a>
			2465: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2469:	test   rax,rax
    246c:	jne    247e <botlish_fn_26+0x2f>
    2472:	xor    rax,rax
    2475:	add    rsp,0x10
    2479:	mov    rsp,rbp
    247c:	pop    rbp
    247d:	ret
    247e:	add    rsp,0x10
    2482:	mov    rsp,rbp
    2485:	pop    rbp
    2486:	ret

0000000000002487 <botlish_entry_26: ht_new<generic>>:
    2487:	push   rbp
    2488:	mov    rbp,rsp
    248b:	call   2490 <botlish_entry_26+0x9>
			248c: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    2490:	mov    rsp,rbp
    2493:	pop    rbp
    2494:	ret
    2495:	add    BYTE PTR [rax],al
	...

0000000000002498 <botlish_fn_27: ht_capacity_for<int, int>>:
    2498:	push   rbp
    2499:	mov    rbp,rsp
    249c:	sub    rsp,0x50
    24a0:	mov    QWORD PTR [rsp+0x20],rbx
    24a5:	mov    QWORD PTR [rsp+0x28],r12
    24aa:	mov    QWORD PTR [rsp+0x30],r13
    24af:	mov    QWORD PTR [rsp+0x38],r14
    24b4:	mov    QWORD PTR [rsp+0x40],r15
    24b9:	mov    r13,rdi
    24bc:	mov    QWORD PTR [rsp],rdx
    24c0:	mov    rbx,rsi
    24c3:	or     rbx,0x1
    24c7:	sar    rbx,1
    24ca:	mov    r12,rsi
    24cd:	mov    r14,rdx
    24d0:	mov    rax,r12
    24d3:	or     rax,0x1
    24d7:	mov    QWORD PTR [rsp+0x8],rax
    24dc:	mov    QWORD PTR [rsp+0x10],0x7
    24e5:	mov    rax,rbx
    24e8:	imul   QWORD PTR [rip+0x159]        # 2648 <botlish_fn_27+0x1b0>
    24ef:	seto   cl
    24f2:	or     rax,0x1
    24f6:	test   cl,cl
    24f8:	jne    2506 <botlish_fn_27+0x6e>
    24fe:	mov    rsi,rax
    2501:	jmp    251d <botlish_fn_27+0x85>
    2506:	mov    rsi,r12
    2509:	or     rsi,0x1
    250d:	mov    edx,0x7
    2512:	mov    rdi,r13
    2515:	call   251a <botlish_fn_27+0x82>
			2516: R_X86_64_PLT32	rt_int_mul-0x4
    251a:	mov    rsi,rax
    251d:	mov    QWORD PTR [rsp+0x8],rsi
    2522:	mov    r15,rsi
    2525:	mov    QWORD PTR [rsp+0x10],0x5
    252e:	mov    rsi,r14
    2531:	test   rsi,0x1
    2538:	je     2568 <botlish_fn_27+0xd0>
    253e:	mov    rsi,r14
    2541:	mov    rax,rsi
    2544:	sar    rax,1
    2547:	imul   QWORD PTR [rip+0x102]        # 2650 <botlish_fn_27+0x1b8>
    254e:	seto   cl
    2551:	or     rax,0x1
    2555:	test   cl,cl
    2557:	jne    2568 <botlish_fn_27+0xd0>
    255d:	mov    rdx,rax
    2560:	mov    rsi,r15
    2563:	jmp    257e <botlish_fn_27+0xe6>
    2568:	mov    edx,0x5
    256d:	mov    rsi,r14
    2570:	mov    rdi,r13
    2573:	call   2578 <botlish_fn_27+0xe0>
			2574: R_X86_64_PLT32	rt_int_mul-0x4
    2578:	mov    rdx,rax
    257b:	mov    rsi,r15
    257e:	mov    rax,rsi
    2581:	and    rax,rdx
    2584:	test   rax,0x1
    258a:	jne    25ad <botlish_fn_27+0x115>
    2590:	mov    rdi,r13
    2593:	call   2598 <botlish_fn_27+0x100>
			2594: R_X86_64_PLT32	rt_int_cmp-0x4
    2598:	mov    ecx,0x2
    259d:	test   rax,rax
    25a0:	cmovle rcx,QWORD PTR [rip+0xa0]        # 2648 <botlish_fn_27+0x1b0>
    25a8:	jmp    25bd <botlish_fn_27+0x125>
    25ad:	mov    ecx,0x2
    25b2:	cmp    rsi,rdx
    25b5:	cmovle rcx,QWORD PTR [rip+0x8b]        # 2648 <botlish_fn_27+0x1b0>
    25bd:	cmp    rcx,0x6
    25c1:	je     261d <botlish_fn_27+0x185>
    25c7:	mov    QWORD PTR [rsp+0x8],0x5
    25d0:	mov    rsi,r14
    25d3:	test   rsi,0x1
    25da:	je     2601 <botlish_fn_27+0x169>
    25e0:	mov    rsi,r14
    25e3:	mov    rax,rsi
    25e6:	sar    rax,1
    25e9:	imul   QWORD PTR [rip+0x60]        # 2650 <botlish_fn_27+0x1b8>
    25f0:	seto   sil
    25f4:	or     rax,0x1
    25f8:	test   sil,sil
    25fb:	je     2611 <botlish_fn_27+0x179>
    2601:	mov    edx,0x5
    2606:	mov    rsi,r14
    2609:	mov    rdi,r13
    260c:	call   2611 <botlish_fn_27+0x179>
			260d: R_X86_64_PLT32	rt_int_mul-0x4
    2611:	mov    QWORD PTR [rsp],rax
    2615:	mov    r14,rax
    2618:	jmp    24d0 <botlish_fn_27+0x38>
    261d:	mov    rax,r14
    2620:	mov    rbx,QWORD PTR [rsp+0x20]
    2625:	mov    r12,QWORD PTR [rsp+0x28]
    262a:	mov    r13,QWORD PTR [rsp+0x30]
    262f:	mov    r14,QWORD PTR [rsp+0x38]
    2634:	mov    r15,QWORD PTR [rsp+0x40]
    2639:	add    rsp,0x50
    263d:	mov    rsp,rbp
    2640:	pop    rbp
    2641:	ret
    2642:	add    BYTE PTR [rax],al
    2644:	add    BYTE PTR [rax],al
    2646:	add    BYTE PTR [rax],al
    2648:	(bad)
    2649:	add    BYTE PTR [rax],al
    264b:	add    BYTE PTR [rax],al
    264d:	add    BYTE PTR [rax],al
    264f:	add    BYTE PTR [rax+rax*1],al
    2652:	add    BYTE PTR [rax],al
    2654:	add    BYTE PTR [rax],al
	...

0000000000002658 <botlish_entry_27: ht_capacity_for<int, int>>:
    2658:	push   rbp
    2659:	mov    rbp,rsp
    265c:	mov    rsi,QWORD PTR [rdx]
    265f:	mov    rdx,QWORD PTR [rdx+0x8]
    2663:	call   2668 <botlish_entry_27+0x10>
			2664: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2668:	mov    rsp,rbp
    266b:	pop    rbp
    266c:	ret

000000000000266d <botlish_fn_28: ht_new_sized<int>>:
    266d:	push   rbp
    266e:	mov    rbp,rsp
    2671:	sub    rsp,0x20
    2675:	mov    QWORD PTR [rsp+0x10],r12
    267a:	mov    r12,rdi
    267d:	mov    QWORD PTR [rsp],rsi
    2681:	mov    edx,0x11
    2686:	mov    QWORD PTR [rsp+0x8],0x11
    268f:	mov    rdi,r12
    2692:	call   2697 <botlish_fn_28+0x2a>
			2693: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2697:	mov    QWORD PTR [rsp],rax
    269b:	mov    rsi,rax
    269e:	mov    rdi,r12
    26a1:	call   26a6 <botlish_fn_28+0x39>
			26a2: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    26a6:	test   rax,rax
    26a9:	jne    26c0 <botlish_fn_28+0x53>
    26af:	xor    rax,rax
    26b2:	mov    r12,QWORD PTR [rsp+0x10]
    26b7:	add    rsp,0x20
    26bb:	mov    rsp,rbp
    26be:	pop    rbp
    26bf:	ret
    26c0:	mov    r12,QWORD PTR [rsp+0x10]
    26c5:	add    rsp,0x20
    26c9:	mov    rsp,rbp
    26cc:	pop    rbp
    26cd:	ret

00000000000026ce <botlish_entry_28: ht_new_sized<int>>:
    26ce:	push   rbp
    26cf:	mov    rbp,rsp
    26d2:	mov    rsi,QWORD PTR [rdx]
    26d5:	call   26da <botlish_entry_28+0xc>
			26d6: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    26da:	mov    rsp,rbp
    26dd:	pop    rbp
    26de:	ret

00000000000026df <botlish_fn_29: ht_controls<mutarray>>:
    26df:	push   rbp
    26e0:	mov    rbp,rsp
    26e3:	mov    edx,0x1
    26e8:	call   26ed <botlish_fn_29+0xe>
			26e9: R_X86_64_PLT32	rt_mutarray_get-0x4
    26ed:	test   rax,rax
    26f0:	jne    26fe <botlish_fn_29+0x1f>
    26f6:	xor    rax,rax
    26f9:	mov    rsp,rbp
    26fc:	pop    rbp
    26fd:	ret
    26fe:	mov    rsp,rbp
    2701:	pop    rbp
    2702:	ret

0000000000002703 <botlish_entry_29: ht_controls<mutarray>>:
    2703:	push   rbp
    2704:	mov    rbp,rsp
    2707:	mov    rsi,QWORD PTR [rdx]
    270a:	call   270f <botlish_entry_29+0xc>
			270b: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    270f:	mov    rsp,rbp
    2712:	pop    rbp
    2713:	ret

0000000000002714 <botlish_fn_30: ht_keys<mutarray>>:
    2714:	push   rbp
    2715:	mov    rbp,rsp
    2718:	mov    edx,0x3
    271d:	call   2722 <botlish_fn_30+0xe>
			271e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2722:	test   rax,rax
    2725:	jne    2733 <botlish_fn_30+0x1f>
    272b:	xor    rax,rax
    272e:	mov    rsp,rbp
    2731:	pop    rbp
    2732:	ret
    2733:	mov    rsp,rbp
    2736:	pop    rbp
    2737:	ret

0000000000002738 <botlish_entry_30: ht_keys<mutarray>>:
    2738:	push   rbp
    2739:	mov    rbp,rsp
    273c:	mov    rsi,QWORD PTR [rdx]
    273f:	call   2744 <botlish_entry_30+0xc>
			2740: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2744:	mov    rsp,rbp
    2747:	pop    rbp
    2748:	ret

0000000000002749 <botlish_fn_31: ht_values<mutarray>>:
    2749:	push   rbp
    274a:	mov    rbp,rsp
    274d:	mov    edx,0x5
    2752:	call   2757 <botlish_fn_31+0xe>
			2753: R_X86_64_PLT32	rt_mutarray_get-0x4
    2757:	test   rax,rax
    275a:	jne    2768 <botlish_fn_31+0x1f>
    2760:	xor    rax,rax
    2763:	mov    rsp,rbp
    2766:	pop    rbp
    2767:	ret
    2768:	mov    rsp,rbp
    276b:	pop    rbp
    276c:	ret

000000000000276d <botlish_entry_31: ht_values<mutarray>>:
    276d:	push   rbp
    276e:	mov    rbp,rsp
    2771:	mov    rsi,QWORD PTR [rdx]
    2774:	call   2779 <botlish_entry_31+0xc>
			2775: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    2779:	mov    rsp,rbp
    277c:	pop    rbp
    277d:	ret

000000000000277e <botlish_fn_32: ht_size<mutarray>>:
    277e:	push   rbp
    277f:	mov    rbp,rsp
    2782:	mov    edx,0x7
    2787:	call   278c <botlish_fn_32+0xe>
			2788: R_X86_64_PLT32	rt_mutarray_get-0x4
    278c:	test   rax,rax
    278f:	jne    279d <botlish_fn_32+0x1f>
    2795:	xor    rax,rax
    2798:	mov    rsp,rbp
    279b:	pop    rbp
    279c:	ret
    279d:	mov    rsp,rbp
    27a0:	pop    rbp
    27a1:	ret

00000000000027a2 <botlish_entry_32: ht_size<mutarray>>:
    27a2:	push   rbp
    27a3:	mov    rbp,rsp
    27a6:	mov    rsi,QWORD PTR [rdx]
    27a9:	call   27ae <botlish_entry_32+0xc>
			27aa: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    27ae:	mov    rsp,rbp
    27b1:	pop    rbp
    27b2:	ret

00000000000027b3 <botlish_fn_33: ht_tombstones<mutarray>>:
    27b3:	push   rbp
    27b4:	mov    rbp,rsp
    27b7:	mov    edx,0x9
    27bc:	call   27c1 <botlish_fn_33+0xe>
			27bd: R_X86_64_PLT32	rt_mutarray_get-0x4
    27c1:	test   rax,rax
    27c4:	jne    27d2 <botlish_fn_33+0x1f>
    27ca:	xor    rax,rax
    27cd:	mov    rsp,rbp
    27d0:	pop    rbp
    27d1:	ret
    27d2:	mov    rsp,rbp
    27d5:	pop    rbp
    27d6:	ret

00000000000027d7 <botlish_entry_33: ht_tombstones<mutarray>>:
    27d7:	push   rbp
    27d8:	mov    rbp,rsp
    27db:	mov    rsi,QWORD PTR [rdx]
    27de:	call   27e3 <botlish_entry_33+0xc>
			27df: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    27e3:	mov    rsp,rbp
    27e6:	pop    rbp
    27e7:	ret

00000000000027e8 <botlish_fn_34: ht_capacity<mutarray>>:
    27e8:	push   rbp
    27e9:	mov    rbp,rsp
    27ec:	sub    rsp,0x10
    27f0:	mov    QWORD PTR [rsp],rbx
    27f4:	mov    rbx,rdi
    27f7:	mov    rdi,rbx
    27fa:	call   27ff <botlish_fn_34+0x17>
			27fb: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    27ff:	test   rax,rax
    2802:	je     284c <botlish_fn_34+0x64>
    2808:	xor    r8d,r8d
    280b:	test   rax,0x7
    2811:	je     281f <botlish_fn_34+0x37>
    2817:	mov    rsi,rax
    281a:	jmp    282e <botlish_fn_34+0x46>
    281f:	movzx  rcx,BYTE PTR [rax]
    2823:	mov    rsi,rax
    2826:	rex cmp cl,0x8
    282a:	sete   r8b
    282e:	test   r8b,r8b
    2831:	jne    285c <botlish_fn_34+0x74>
    2837:	mov    rdi,rbx
    283a:	mov    rax,QWORD PTR [rdi+0x10]
    283e:	mov    rcx,QWORD PTR [rax+0x28]
    2842:	mov    edx,0x8
    2847:	call   284c <botlish_fn_34+0x64>
			2848: R_X86_64_PLT32	rt_type_error-0x4
    284c:	xor    rax,rax
    284f:	mov    rbx,QWORD PTR [rsp]
    2853:	add    rsp,0x10
    2857:	mov    rsp,rbp
    285a:	pop    rbp
    285b:	ret
    285c:	mov    rdi,rbx
    285f:	call   2864 <botlish_fn_34+0x7c>
			2860: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2864:	mov    rbx,QWORD PTR [rsp]
    2868:	add    rsp,0x10
    286c:	mov    rsp,rbp
    286f:	pop    rbp
    2870:	ret

0000000000002871 <botlish_entry_34: ht_capacity<mutarray>>:
    2871:	push   rbp
    2872:	mov    rbp,rsp
    2875:	mov    rsi,QWORD PTR [rdx]
    2878:	call   287d <botlish_entry_34+0xc>
			2879: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    287d:	mov    rsp,rbp
    2880:	pop    rbp
    2881:	ret

0000000000002882 <botlish_fn_35: ht_probe_start<mutarray, str>>:
    2882:	push   rbp
    2883:	mov    rbp,rsp
    2886:	sub    rsp,0x20
    288a:	mov    QWORD PTR [rsp],r12
    288e:	mov    QWORD PTR [rsp+0x8],r13
    2893:	mov    QWORD PTR [rsp+0x10],r14
    2898:	mov    r12,rdi
    289b:	mov    r14,rsi
    289e:	mov    rsi,rdx
    28a1:	mov    rdi,r12
    28a4:	call   28a9 <botlish_fn_35+0x27>
			28a5: R_X86_64_PLT32	rt_hash-0x4
    28a9:	test   rax,rax
    28ac:	mov    r13,rax
    28af:	je     28e0 <botlish_fn_35+0x5e>
    28b5:	mov    rsi,r14
    28b8:	mov    rdi,r12
    28bb:	call   28c0 <botlish_fn_35+0x3e>
			28bc: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    28c0:	test   rax,rax
    28c3:	mov    rdx,rax
    28c6:	je     28e0 <botlish_fn_35+0x5e>
    28cc:	mov    rsi,r13
    28cf:	mov    rdi,r12
    28d2:	call   28d7 <botlish_fn_35+0x55>
			28d3: R_X86_64_PLT32	rt_int_mod-0x4
    28d7:	test   rax,rax
    28da:	jne    28fa <botlish_fn_35+0x78>
    28e0:	xor    rax,rax
    28e3:	mov    r12,QWORD PTR [rsp]
    28e7:	mov    r13,QWORD PTR [rsp+0x8]
    28ec:	mov    r14,QWORD PTR [rsp+0x10]
    28f1:	add    rsp,0x20
    28f5:	mov    rsp,rbp
    28f8:	pop    rbp
    28f9:	ret
    28fa:	mov    r12,QWORD PTR [rsp]
    28fe:	mov    r13,QWORD PTR [rsp+0x8]
    2903:	mov    r14,QWORD PTR [rsp+0x10]
    2908:	add    rsp,0x20
    290c:	mov    rsp,rbp
    290f:	pop    rbp
    2910:	ret

0000000000002911 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    2911:	push   rbp
    2912:	mov    rbp,rsp
    2915:	mov    rsi,QWORD PTR [rdx]
    2918:	mov    rdx,QWORD PTR [rdx+0x8]
    291c:	call   2921 <botlish_entry_35+0x10>
			291d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    2921:	mov    rsp,rbp
    2924:	pop    rbp
    2925:	ret

0000000000002926 <botlish_fn_36: ht_probe_next<mutarray, int>>:
    2926:	push   rbp
    2927:	mov    rbp,rsp
    292a:	sub    rsp,0x40
    292e:	mov    QWORD PTR [rsp+0x20],rbx
    2933:	mov    QWORD PTR [rsp+0x28],r12
    2938:	mov    QWORD PTR [rsp+0x30],r13
    293d:	mov    r13,rdi
    2940:	mov    QWORD PTR [rsp],rsi
    2944:	mov    rbx,rsi
    2947:	mov    QWORD PTR [rsp+0x8],rdx
    294c:	mov    QWORD PTR [rsp+0x10],0x3
    2955:	test   rdx,0x1
    295c:	jne    296a <botlish_fn_36+0x44>
    2962:	mov    rsi,rdx
    2965:	jmp    298a <botlish_fn_36+0x64>
    296a:	mov    rsi,rdx
    296d:	add    rsi,0x2
    2971:	mov    r12,rsi
    2974:	mov    rsi,rdx
    2977:	seto   al
    297a:	test   al,al
    297c:	jne    298a <botlish_fn_36+0x64>
    2982:	mov    rsi,rbx
    2985:	jmp    299d <botlish_fn_36+0x77>
    298a:	mov    edx,0x3
    298f:	mov    rdi,r13
    2992:	call   2997 <botlish_fn_36+0x71>
			2993: R_X86_64_PLT32	rt_int_add-0x4
    2997:	mov    rsi,rbx
    299a:	mov    r12,rax
    299d:	mov    rdi,r13
    29a0:	call   29a5 <botlish_fn_36+0x7f>
			29a1: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    29a5:	test   rax,rax
    29a8:	mov    rdx,rax
    29ab:	je     29c5 <botlish_fn_36+0x9f>
    29b1:	mov    rsi,r12
    29b4:	mov    rdi,r13
    29b7:	call   29bc <botlish_fn_36+0x96>
			29b8: R_X86_64_PLT32	rt_int_mod-0x4
    29bc:	test   rax,rax
    29bf:	jne    29e0 <botlish_fn_36+0xba>
    29c5:	xor    rax,rax
    29c8:	mov    rbx,QWORD PTR [rsp+0x20]
    29cd:	mov    r12,QWORD PTR [rsp+0x28]
    29d2:	mov    r13,QWORD PTR [rsp+0x30]
    29d7:	add    rsp,0x40
    29db:	mov    rsp,rbp
    29de:	pop    rbp
    29df:	ret
    29e0:	mov    rbx,QWORD PTR [rsp+0x20]
    29e5:	mov    r12,QWORD PTR [rsp+0x28]
    29ea:	mov    r13,QWORD PTR [rsp+0x30]
    29ef:	add    rsp,0x40
    29f3:	mov    rsp,rbp
    29f6:	pop    rbp
    29f7:	ret

00000000000029f8 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    29f8:	push   rbp
    29f9:	mov    rbp,rsp
    29fc:	mov    rsi,QWORD PTR [rdx]
    29ff:	mov    rdx,QWORD PTR [rdx+0x8]
    2a03:	call   2a08 <botlish_entry_36+0x10>
			2a04: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2a08:	mov    rsp,rbp
    2a0b:	pop    rbp
    2a0c:	ret
    2a0d:	add    BYTE PTR [rax],al
	...

0000000000002a10 <botlish_fn_37: ht_find_get<mutarray, str, int>>:
    2a10:	push   rbp
    2a11:	mov    rbp,rsp
    2a14:	sub    rsp,0x50
    2a18:	mov    QWORD PTR [rsp+0x20],rbx
    2a1d:	mov    QWORD PTR [rsp+0x28],r12
    2a22:	mov    QWORD PTR [rsp+0x30],r13
    2a27:	mov    QWORD PTR [rsp+0x38],r14
    2a2c:	mov    QWORD PTR [rsp+0x40],r15
    2a31:	mov    r14,rdi
    2a34:	mov    QWORD PTR [rsp],rsi
    2a38:	mov    QWORD PTR [rsp+0x8],rdx
    2a3d:	mov    r13,rdx
    2a40:	mov    QWORD PTR [rsp+0x10],rcx
    2a45:	mov    r12,rsi
    2a48:	mov    r15,rcx
    2a4b:	mov    rsi,r12
    2a4e:	mov    rdi,r14
    2a51:	call   2a56 <botlish_fn_37+0x46>
			2a52: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2a56:	test   rax,rax
    2a59:	je     2c58 <botlish_fn_37+0x248>
    2a5f:	xor    ecx,ecx
    2a61:	test   rax,0x7
    2a67:	je     2a75 <botlish_fn_37+0x65>
    2a6d:	mov    rsi,rax
    2a70:	jmp    2a83 <botlish_fn_37+0x73>
    2a75:	movzx  rcx,BYTE PTR [rax]
    2a79:	mov    rsi,rax
    2a7c:	rex cmp cl,0x8
    2a80:	sete   cl
    2a83:	test   cl,cl
    2a85:	jne    2aa5 <botlish_fn_37+0x95>
    2a8b:	mov    rdi,r14
    2a8e:	mov    rdx,QWORD PTR [rdi+0x10]
    2a92:	mov    rcx,QWORD PTR [rdx+0x30]
    2a96:	mov    edx,0x8
    2a9b:	call   2aa0 <botlish_fn_37+0x90>
			2a9c: R_X86_64_PLT32	rt_type_error-0x4
    2aa0:	jmp    2c58 <botlish_fn_37+0x248>
    2aa5:	mov    rdx,r15
    2aa8:	mov    rdi,r14
    2aab:	call   2ab0 <botlish_fn_37+0xa0>
			2aac: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ab0:	mov    rcx,rax
    2ab3:	mov    QWORD PTR [rsp+0x18],rax
    2ab8:	test   rax,rcx
    2abb:	je     2c58 <botlish_fn_37+0x248>
    2ac1:	mov    rax,QWORD PTR [rsp+0x18]
    2ac6:	test   rax,0x1
    2acc:	jne    2af7 <botlish_fn_37+0xe7>
    2ad2:	mov    edx,0x1
    2ad7:	mov    rsi,QWORD PTR [rsp+0x18]
    2adc:	mov    rdi,r14
    2adf:	call   2ae4 <botlish_fn_37+0xd4>
			2ae0: R_X86_64_PLT32	rt_value_eq-0x4
    2ae4:	test   rax,rax
    2ae7:	je     2c58 <botlish_fn_37+0x248>
    2aed:	mov    rcx,QWORD PTR [rsp+0x18]
    2af2:	jmp    2b0d <botlish_fn_37+0xfd>
    2af7:	mov    eax,0x2
    2afc:	mov    rcx,QWORD PTR [rsp+0x18]
    2b01:	cmp    rcx,0x1
    2b05:	cmove  rax,QWORD PTR [rip+0x1db]        # 2ce8 <botlish_fn_37+0x2d8>
    2b0d:	mov    ebx,0x6
    2b12:	cmp    rax,0x6
    2b16:	je     2cb8 <botlish_fn_37+0x2a8>
    2b1c:	test   rcx,0x1
    2b23:	mov    QWORD PTR [rsp+0x18],rcx
    2b28:	jne    2b4e <botlish_fn_37+0x13e>
    2b2e:	mov    edx,0x3
    2b33:	mov    rsi,QWORD PTR [rsp+0x18]
    2b38:	mov    rdi,r14
    2b3b:	call   2b40 <botlish_fn_37+0x130>
			2b3c: R_X86_64_PLT32	rt_value_eq-0x4
    2b40:	test   rax,rax
    2b43:	je     2c58 <botlish_fn_37+0x248>
    2b49:	jmp    2b64 <botlish_fn_37+0x154>
    2b4e:	mov    rsi,QWORD PTR [rsp+0x18]
    2b53:	mov    eax,0x2
    2b58:	cmp    rsi,0x3
    2b5c:	cmove  rax,QWORD PTR [rip+0x184]        # 2ce8 <botlish_fn_37+0x2d8>
    2b64:	cmp    rax,0x6
    2b68:	je     2b78 <botlish_fn_37+0x168>
    2b6e:	mov    ebx,0x2
    2b73:	jmp    2c37 <botlish_fn_37+0x227>
    2b78:	mov    rsi,r12
    2b7b:	mov    rdi,r14
    2b7e:	call   2b83 <botlish_fn_37+0x173>
			2b7f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2b83:	test   rax,rax
    2b86:	je     2c58 <botlish_fn_37+0x248>
    2b8c:	xor    r10d,r10d
    2b8f:	test   rax,0x7
    2b95:	je     2ba3 <botlish_fn_37+0x193>
    2b9b:	mov    rsi,rax
    2b9e:	jmp    2bb2 <botlish_fn_37+0x1a2>
    2ba3:	movzx  rcx,BYTE PTR [rax]
    2ba7:	mov    rsi,rax
    2baa:	rex cmp cl,0x8
    2bae:	sete   r10b
    2bb2:	test   r10b,r10b
    2bb5:	jne    2bd5 <botlish_fn_37+0x1c5>
    2bbb:	mov    rdi,r14
    2bbe:	mov    rax,QWORD PTR [rdi+0x10]
    2bc2:	mov    rcx,QWORD PTR [rax+0x30]
    2bc6:	mov    edx,0x8
    2bcb:	call   2bd0 <botlish_fn_37+0x1c0>
			2bcc: R_X86_64_PLT32	rt_type_error-0x4
    2bd0:	jmp    2c58 <botlish_fn_37+0x248>
    2bd5:	mov    rdx,r15
    2bd8:	mov    rdi,r14
    2bdb:	call   2be0 <botlish_fn_37+0x1d0>
			2bdc: R_X86_64_PLT32	rt_mutarray_get-0x4
    2be0:	test   rax,rax
    2be3:	je     2c58 <botlish_fn_37+0x248>
    2be9:	mov    rcx,rax
    2bec:	and    rcx,r13
    2bef:	mov    rsi,rax
    2bf2:	test   rcx,0x1
    2bf9:	jne    2c18 <botlish_fn_37+0x208>
    2bff:	mov    rdx,r13
    2c02:	mov    rdi,r14
    2c05:	call   2c0a <botlish_fn_37+0x1fa>
			2c06: R_X86_64_PLT32	rt_value_eq-0x4
    2c0a:	test   rax,rax
    2c0d:	je     2c58 <botlish_fn_37+0x248>
    2c13:	jmp    2c28 <botlish_fn_37+0x218>
    2c18:	mov    eax,0x2
    2c1d:	cmp    rsi,r13
    2c20:	cmove  rax,QWORD PTR [rip+0xc0]        # 2ce8 <botlish_fn_37+0x2d8>
    2c28:	cmp    rax,0x6
    2c2c:	je     2c37 <botlish_fn_37+0x227>
    2c32:	mov    ebx,0x2
    2c37:	cmp    rbx,0x6
    2c3b:	je     2c93 <botlish_fn_37+0x283>
    2c41:	mov    rdx,r15
    2c44:	mov    rsi,r12
    2c47:	mov    rdi,r14
    2c4a:	call   2c4f <botlish_fn_37+0x23f>
			2c4b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2c4f:	test   rax,rax
    2c52:	jne    2c7d <botlish_fn_37+0x26d>
    2c58:	xor    rax,rax
    2c5b:	mov    rbx,QWORD PTR [rsp+0x20]
    2c60:	mov    r12,QWORD PTR [rsp+0x28]
    2c65:	mov    r13,QWORD PTR [rsp+0x30]
    2c6a:	mov    r14,QWORD PTR [rsp+0x38]
    2c6f:	mov    r15,QWORD PTR [rsp+0x40]
    2c74:	add    rsp,0x50
    2c78:	mov    rsp,rbp
    2c7b:	pop    rbp
    2c7c:	ret
    2c7d:	mov    QWORD PTR [rsp],r12
    2c81:	mov    QWORD PTR [rsp+0x8],r13
    2c86:	mov    QWORD PTR [rsp+0x10],rax
    2c8b:	mov    r15,rax
    2c8e:	jmp    2a4b <botlish_fn_37+0x3b>
    2c93:	mov    rax,r15
    2c96:	mov    rbx,QWORD PTR [rsp+0x20]
    2c9b:	mov    r12,QWORD PTR [rsp+0x28]
    2ca0:	mov    r13,QWORD PTR [rsp+0x30]
    2ca5:	mov    r14,QWORD PTR [rsp+0x38]
    2caa:	mov    r15,QWORD PTR [rsp+0x40]
    2caf:	add    rsp,0x50
    2cb3:	mov    rsp,rbp
    2cb6:	pop    rbp
    2cb7:	ret
    2cb8:	mov    rax,0xffffffffffffffff
    2cbf:	mov    rbx,QWORD PTR [rsp+0x20]
    2cc4:	mov    r12,QWORD PTR [rsp+0x28]
    2cc9:	mov    r13,QWORD PTR [rsp+0x30]
    2cce:	mov    r14,QWORD PTR [rsp+0x38]
    2cd3:	mov    r15,QWORD PTR [rsp+0x40]
    2cd8:	add    rsp,0x50
    2cdc:	mov    rsp,rbp
    2cdf:	pop    rbp
    2ce0:	ret
    2ce1:	add    BYTE PTR [rax],al
    2ce3:	add    BYTE PTR [rax],al
    2ce5:	add    BYTE PTR [rax],al
    2ce7:	add    BYTE PTR [rsi],al
    2ce9:	add    BYTE PTR [rax],al
    2ceb:	add    BYTE PTR [rax],al
    2ced:	add    BYTE PTR [rax],al
	...

0000000000002cf0 <botlish_entry_37: ht_find_get<mutarray, str, int>>:
    2cf0:	push   rbp
    2cf1:	mov    rbp,rsp
    2cf4:	mov    rsi,QWORD PTR [rdx]
    2cf7:	mov    r8,QWORD PTR [rdx+0x8]
    2cfb:	mov    rcx,QWORD PTR [rdx+0x10]
    2cff:	mov    rdx,r8
    2d02:	call   2d07 <botlish_entry_37+0x17>
			2d03: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    2d07:	mov    rsp,rbp
    2d0a:	pop    rbp
    2d0b:	ret
    2d0c:	add    BYTE PTR [rax],al
	...

0000000000002d10 <botlish_fn_38: ht_find_insert<mutarray, str, int, int>>:
    2d10:	push   rbp
    2d11:	mov    rbp,rsp
    2d14:	sub    rsp,0x60
    2d18:	mov    QWORD PTR [rsp+0x30],rbx
    2d1d:	mov    QWORD PTR [rsp+0x38],r12
    2d22:	mov    QWORD PTR [rsp+0x40],r13
    2d27:	mov    QWORD PTR [rsp+0x48],r14
    2d2c:	mov    QWORD PTR [rsp+0x50],r15
    2d31:	mov    r15,rdi
    2d34:	mov    QWORD PTR [rsp],rsi
    2d38:	mov    QWORD PTR [rsp+0x8],rdx
    2d3d:	mov    r13,rdx
    2d40:	mov    QWORD PTR [rsp+0x10],rcx
    2d45:	mov    QWORD PTR [rsp+0x18],r8
    2d4a:	mov    rbx,rsi
    2d4d:	mov    QWORD PTR [rsp+0x20],rcx
    2d52:	mov    QWORD PTR [rsp+0x28],r8
    2d57:	mov    rsi,rbx
    2d5a:	mov    rdi,r15
    2d5d:	call   2d62 <botlish_fn_38+0x52>
			2d5e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2d62:	test   rax,rax
    2d65:	je     305d <botlish_fn_38+0x34d>
    2d6b:	xor    ecx,ecx
    2d6d:	test   rax,0x7
    2d73:	je     2d81 <botlish_fn_38+0x71>
    2d79:	mov    rsi,rax
    2d7c:	jmp    2d8f <botlish_fn_38+0x7f>
    2d81:	movzx  rcx,BYTE PTR [rax]
    2d85:	mov    rsi,rax
    2d88:	rex cmp cl,0x8
    2d8c:	sete   cl
    2d8f:	test   cl,cl
    2d91:	jne    2db1 <botlish_fn_38+0xa1>
    2d97:	mov    rdi,r15
    2d9a:	mov    rax,QWORD PTR [rdi+0x10]
    2d9e:	mov    rcx,QWORD PTR [rax+0x30]
    2da2:	mov    edx,0x8
    2da7:	call   2dac <botlish_fn_38+0x9c>
			2da8: R_X86_64_PLT32	rt_type_error-0x4
    2dac:	jmp    305d <botlish_fn_38+0x34d>
    2db1:	mov    rdx,QWORD PTR [rsp+0x20]
    2db6:	mov    rdi,r15
    2db9:	call   2dbe <botlish_fn_38+0xae>
			2dba: R_X86_64_PLT32	rt_mutarray_get-0x4
    2dbe:	mov    rsi,rax
    2dc1:	mov    r14,rax
    2dc4:	test   rax,rsi
    2dc7:	je     305d <botlish_fn_38+0x34d>
    2dcd:	mov    rax,r14
    2dd0:	test   rax,0x1
    2dd6:	jne    2dfa <botlish_fn_38+0xea>
    2ddc:	mov    edx,0x1
    2de1:	mov    rsi,r14
    2de4:	mov    rdi,r15
    2de7:	call   2dec <botlish_fn_38+0xdc>
			2de8: R_X86_64_PLT32	rt_value_eq-0x4
    2dec:	test   rax,rax
    2def:	je     305d <botlish_fn_38+0x34d>
    2df5:	jmp    2e0e <botlish_fn_38+0xfe>
    2dfa:	mov    eax,0x2
    2dff:	mov    rcx,r14
    2e02:	cmp    rcx,0x1
    2e06:	cmove  rax,QWORD PTR [rip+0x372]        # 3180 <botlish_fn_38+0x470>
    2e0e:	mov    r12d,0x6
    2e14:	cmp    rax,0x6
    2e18:	je     30d5 <botlish_fn_38+0x3c5>
    2e1e:	mov    rax,r14
    2e21:	test   rax,0x1
    2e27:	jne    2e4b <botlish_fn_38+0x13b>
    2e2d:	mov    edx,0x3
    2e32:	mov    rsi,r14
    2e35:	mov    rdi,r15
    2e38:	call   2e3d <botlish_fn_38+0x12d>
			2e39: R_X86_64_PLT32	rt_value_eq-0x4
    2e3d:	test   rax,rax
    2e40:	je     305d <botlish_fn_38+0x34d>
    2e46:	jmp    2e5f <botlish_fn_38+0x14f>
    2e4b:	mov    eax,0x2
    2e50:	mov    rcx,r14
    2e53:	cmp    rcx,0x3
    2e57:	cmove  rax,QWORD PTR [rip+0x321]        # 3180 <botlish_fn_38+0x470>
    2e5f:	cmp    rax,0x6
    2e63:	je     2e74 <botlish_fn_38+0x164>
    2e69:	mov    r11d,0x2
    2e6f:	jmp    2f3e <botlish_fn_38+0x22e>
    2e74:	mov    rsi,rbx
    2e77:	mov    rdi,r15
    2e7a:	call   2e7f <botlish_fn_38+0x16f>
			2e7b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2e7f:	test   rax,rax
    2e82:	je     305d <botlish_fn_38+0x34d>
    2e88:	xor    ecx,ecx
    2e8a:	test   rax,0x7
    2e90:	je     2e9e <botlish_fn_38+0x18e>
    2e96:	mov    rsi,rax
    2e99:	jmp    2eac <botlish_fn_38+0x19c>
    2e9e:	movzx  rcx,BYTE PTR [rax]
    2ea2:	mov    rsi,rax
    2ea5:	rex cmp cl,0x8
    2ea9:	sete   cl
    2eac:	test   cl,cl
    2eae:	jne    2ece <botlish_fn_38+0x1be>
    2eb4:	mov    rdi,r15
    2eb7:	mov    rcx,QWORD PTR [rdi+0x10]
    2ebb:	mov    rcx,QWORD PTR [rcx+0x30]
    2ebf:	mov    edx,0x8
    2ec4:	call   2ec9 <botlish_fn_38+0x1b9>
			2ec5: R_X86_64_PLT32	rt_type_error-0x4
    2ec9:	jmp    305d <botlish_fn_38+0x34d>
    2ece:	mov    rdx,QWORD PTR [rsp+0x20]
    2ed3:	mov    rdi,r15
    2ed6:	call   2edb <botlish_fn_38+0x1cb>
			2ed7: R_X86_64_PLT32	rt_mutarray_get-0x4
    2edb:	test   rax,rax
    2ede:	je     305d <botlish_fn_38+0x34d>
    2ee4:	mov    rsi,rax
    2ee7:	and    rsi,r13
    2eea:	test   rsi,0x1
    2ef1:	jne    2f13 <botlish_fn_38+0x203>
    2ef7:	mov    rsi,rax
    2efa:	mov    rdx,r13
    2efd:	mov    rdi,r15
    2f00:	call   2f05 <botlish_fn_38+0x1f5>
			2f01: R_X86_64_PLT32	rt_value_eq-0x4
    2f05:	test   rax,rax
    2f08:	je     305d <botlish_fn_38+0x34d>
    2f0e:	jmp    2f26 <botlish_fn_38+0x216>
    2f13:	mov    rsi,rax
    2f16:	mov    eax,0x2
    2f1b:	cmp    rsi,r13
    2f1e:	cmove  rax,QWORD PTR [rip+0x25a]        # 3180 <botlish_fn_38+0x470>
    2f26:	cmp    rax,0x6
    2f2a:	je     2f3b <botlish_fn_38+0x22b>
    2f30:	mov    r11d,0x2
    2f36:	jmp    2f3e <botlish_fn_38+0x22e>
    2f3b:	mov    r11,r12
    2f3e:	cmp    r11,0x6
    2f42:	je     30ae <botlish_fn_38+0x39e>
    2f48:	mov    rax,r14
    2f4b:	test   rax,0x1
    2f51:	jne    2f75 <botlish_fn_38+0x265>
    2f57:	mov    edx,0x5
    2f5c:	mov    rsi,r14
    2f5f:	mov    rdi,r15
    2f62:	call   2f67 <botlish_fn_38+0x257>
			2f63: R_X86_64_PLT32	rt_value_eq-0x4
    2f67:	test   rax,rax
    2f6a:	je     305d <botlish_fn_38+0x34d>
    2f70:	jmp    2f89 <botlish_fn_38+0x279>
    2f75:	mov    rsi,r14
    2f78:	mov    eax,0x2
    2f7d:	cmp    rsi,0x5
    2f81:	cmove  rax,QWORD PTR [rip+0x1f7]        # 3180 <botlish_fn_38+0x470>
    2f89:	cmp    rax,0x6
    2f8d:	je     2f9e <botlish_fn_38+0x28e>
    2f93:	mov    r12d,0x2
    2f99:	jmp    2fff <botlish_fn_38+0x2ef>
    2f9e:	mov    r14,QWORD PTR [rsp+0x28]
    2fa3:	test   r14,0x1
    2faa:	jne    2fda <botlish_fn_38+0x2ca>
    2fb0:	mov    edx,0x1
    2fb5:	mov    rsi,r14
    2fb8:	mov    rdi,r15
    2fbb:	call   2fc0 <botlish_fn_38+0x2b0>
			2fbc: R_X86_64_PLT32	rt_int_cmp-0x4
    2fc0:	mov    ecx,0x2
    2fc5:	test   rax,rax
    2fc8:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 3180 <botlish_fn_38+0x470>
    2fd0:	mov    QWORD PTR [rsp+0x28],r14
    2fd5:	jmp    2fef <botlish_fn_38+0x2df>
    2fda:	mov    ecx,0x2
    2fdf:	test   r14,r14
    2fe2:	mov    QWORD PTR [rsp+0x28],r14
    2fe7:	cmovle rcx,QWORD PTR [rip+0x191]        # 3180 <botlish_fn_38+0x470>
    2fef:	cmp    rcx,0x6
    2ff3:	je     2fff <botlish_fn_38+0x2ef>
    2ff9:	mov    r12d,0x2
    2fff:	cmp    r12,0x6
    3003:	je     3044 <botlish_fn_38+0x334>
    3009:	mov    rdx,QWORD PTR [rsp+0x20]
    300e:	mov    rsi,rbx
    3011:	mov    rdi,r15
    3014:	call   3019 <botlish_fn_38+0x309>
			3015: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    3019:	test   rax,rax
    301c:	je     305d <botlish_fn_38+0x34d>
    3022:	mov    QWORD PTR [rsp],rbx
    3026:	mov    QWORD PTR [rsp+0x8],r13
    302b:	mov    QWORD PTR [rsp+0x10],rax
    3030:	mov    r11,QWORD PTR [rsp+0x28]
    3035:	mov    QWORD PTR [rsp+0x18],r11
    303a:	mov    QWORD PTR [rsp+0x20],rax
    303f:	jmp    2d57 <botlish_fn_38+0x47>
    3044:	mov    rdx,QWORD PTR [rsp+0x20]
    3049:	mov    rsi,rbx
    304c:	mov    rdi,r15
    304f:	call   3054 <botlish_fn_38+0x344>
			3050: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    3054:	test   rax,rax
    3057:	jne    3082 <botlish_fn_38+0x372>
    305d:	xor    rax,rax
    3060:	mov    rbx,QWORD PTR [rsp+0x30]
    3065:	mov    r12,QWORD PTR [rsp+0x38]
    306a:	mov    r13,QWORD PTR [rsp+0x40]
    306f:	mov    r14,QWORD PTR [rsp+0x48]
    3074:	mov    r15,QWORD PTR [rsp+0x50]
    3079:	add    rsp,0x60
    307d:	mov    rsp,rbp
    3080:	pop    rbp
    3081:	ret
    3082:	mov    QWORD PTR [rsp],rbx
    3086:	mov    QWORD PTR [rsp+0x8],r13
    308b:	mov    QWORD PTR [rsp+0x10],rax
    3090:	mov    rdx,QWORD PTR [rsp+0x20]
    3095:	mov    QWORD PTR [rsp+0x18],rdx
    309a:	mov    rcx,QWORD PTR [rsp+0x20]
    309f:	mov    QWORD PTR [rsp+0x28],rcx
    30a4:	mov    QWORD PTR [rsp+0x20],rax
    30a9:	jmp    2d57 <botlish_fn_38+0x47>
    30ae:	mov    rax,QWORD PTR [rsp+0x20]
    30b3:	mov    rbx,QWORD PTR [rsp+0x30]
    30b8:	mov    r12,QWORD PTR [rsp+0x38]
    30bd:	mov    r13,QWORD PTR [rsp+0x40]
    30c2:	mov    r14,QWORD PTR [rsp+0x48]
    30c7:	mov    r15,QWORD PTR [rsp+0x50]
    30cc:	add    rsp,0x60
    30d0:	mov    rsp,rbp
    30d3:	pop    rbp
    30d4:	ret
    30d5:	mov    rax,QWORD PTR [rsp+0x28]
    30da:	test   rax,0x1
    30e0:	jne    310d <botlish_fn_38+0x3fd>
    30e6:	mov    edx,0x1
    30eb:	mov    rdi,r15
    30ee:	mov    rsi,QWORD PTR [rsp+0x28]
    30f3:	call   30f8 <botlish_fn_38+0x3e8>
			30f4: R_X86_64_PLT32	rt_int_cmp-0x4
    30f8:	mov    ecx,0x2
    30fd:	test   rax,rax
    3100:	cmovge rcx,QWORD PTR [rip+0x78]        # 3180 <botlish_fn_38+0x470>
    3108:	jmp    3127 <botlish_fn_38+0x417>
    310d:	mov    ecx,0x2
    3112:	mov    rax,QWORD PTR [rsp+0x28]
    3117:	mov    rdx,QWORD PTR [rsp+0x28]
    311c:	test   rax,rdx
    311f:	cmovg  rcx,QWORD PTR [rip+0x59]        # 3180 <botlish_fn_38+0x470>
    3127:	cmp    rcx,0x6
    312b:	je     3158 <botlish_fn_38+0x448>
    3131:	mov    rax,QWORD PTR [rsp+0x20]
    3136:	mov    rbx,QWORD PTR [rsp+0x30]
    313b:	mov    r12,QWORD PTR [rsp+0x38]
    3140:	mov    r13,QWORD PTR [rsp+0x40]
    3145:	mov    r14,QWORD PTR [rsp+0x48]
    314a:	mov    r15,QWORD PTR [rsp+0x50]
    314f:	add    rsp,0x60
    3153:	mov    rsp,rbp
    3156:	pop    rbp
    3157:	ret
    3158:	mov    rax,QWORD PTR [rsp+0x28]
    315d:	mov    rbx,QWORD PTR [rsp+0x30]
    3162:	mov    r12,QWORD PTR [rsp+0x38]
    3167:	mov    r13,QWORD PTR [rsp+0x40]
    316c:	mov    r14,QWORD PTR [rsp+0x48]
    3171:	mov    r15,QWORD PTR [rsp+0x50]
    3176:	add    rsp,0x60
    317a:	mov    rsp,rbp
    317d:	pop    rbp
    317e:	ret
    317f:	add    BYTE PTR [rsi],al
    3181:	add    BYTE PTR [rax],al
    3183:	add    BYTE PTR [rax],al
    3185:	add    BYTE PTR [rax],al
	...

0000000000003188 <botlish_entry_38: ht_find_insert<mutarray, str, int, int>>:
    3188:	push   rbp
    3189:	mov    rbp,rsp
    318c:	mov    rsi,QWORD PTR [rdx]
    318f:	mov    r9,QWORD PTR [rdx+0x8]
    3193:	mov    rcx,QWORD PTR [rdx+0x10]
    3197:	mov    r8,QWORD PTR [rdx+0x18]
    319b:	mov    rdx,r9
    319e:	call   31a3 <botlish_entry_38+0x1b>
			319f: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    31a3:	mov    rsp,rbp
    31a6:	pop    rbp
    31a7:	ret

00000000000031a8 <botlish_fn_39: ht_get<mutarray, str>>:
    31a8:	push   rbp
    31a9:	mov    rbp,rsp
    31ac:	sub    rsp,0x40
    31b0:	mov    QWORD PTR [rsp+0x20],rbx
    31b5:	mov    QWORD PTR [rsp+0x28],r12
    31ba:	mov    QWORD PTR [rsp+0x30],r13
    31bf:	mov    rbx,rdi
    31c2:	mov    QWORD PTR [rsp],rsi
    31c6:	mov    r13,rsi
    31c9:	mov    QWORD PTR [rsp+0x8],rdx
    31ce:	mov    r12,rdx
    31d1:	mov    rdx,r12
    31d4:	mov    rsi,r13
    31d7:	mov    rdi,rbx
    31da:	call   31df <botlish_fn_39+0x37>
			31db: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    31df:	test   rax,rax
    31e2:	je     32cc <botlish_fn_39+0x124>
    31e8:	mov    QWORD PTR [rsp+0x10],rax
    31ed:	mov    rcx,rax
    31f0:	mov    rdx,r12
    31f3:	mov    rsi,r13
    31f6:	mov    rdi,rbx
    31f9:	call   31fe <botlish_fn_39+0x56>
			31fa: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    31fe:	mov    rcx,rax
    3201:	mov    r12,rax
    3204:	test   rax,rcx
    3207:	je     32cc <botlish_fn_39+0x124>
    320d:	mov    rax,r12
    3210:	test   rax,0x1
    3216:	jne    3241 <botlish_fn_39+0x99>
    321c:	mov    edx,0x1
    3221:	mov    rsi,r12
    3224:	mov    rdi,rbx
    3227:	call   322c <botlish_fn_39+0x84>
			3228: R_X86_64_PLT32	rt_int_cmp-0x4
    322c:	mov    ecx,0x2
    3231:	test   rax,rax
    3234:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 3320 <botlish_fn_39+0x178>
    323c:	jmp    3254 <botlish_fn_39+0xac>
    3241:	mov    ecx,0x2
    3246:	mov    rax,r12
    3249:	test   rax,rax
    324c:	cmovle rcx,QWORD PTR [rip+0xcc]        # 3320 <botlish_fn_39+0x178>
    3254:	cmp    rcx,0x6
    3258:	je     32ff <botlish_fn_39+0x157>
    325e:	mov    rsi,r13
    3261:	mov    rdi,rbx
    3264:	call   3269 <botlish_fn_39+0xc1>
			3265: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3269:	test   rax,rax
    326c:	je     32cc <botlish_fn_39+0x124>
    3272:	xor    ecx,ecx
    3274:	test   rax,0x7
    327a:	je     3288 <botlish_fn_39+0xe0>
    3280:	mov    rsi,rax
    3283:	jmp    3296 <botlish_fn_39+0xee>
    3288:	movzx  rcx,BYTE PTR [rax]
    328c:	mov    rsi,rax
    328f:	rex cmp cl,0x8
    3293:	sete   cl
    3296:	test   cl,cl
    3298:	jne    32b8 <botlish_fn_39+0x110>
    329e:	mov    rdi,rbx
    32a1:	mov    rax,QWORD PTR [rdi+0x10]
    32a5:	mov    rcx,QWORD PTR [rax+0x30]
    32a9:	mov    edx,0x8
    32ae:	call   32b3 <botlish_fn_39+0x10b>
			32af: R_X86_64_PLT32	rt_type_error-0x4
    32b3:	jmp    32cc <botlish_fn_39+0x124>
    32b8:	mov    rdx,r12
    32bb:	mov    rdi,rbx
    32be:	call   32c3 <botlish_fn_39+0x11b>
			32bf: R_X86_64_PLT32	rt_mutarray_get-0x4
    32c3:	test   rax,rax
    32c6:	jne    32e7 <botlish_fn_39+0x13f>
    32cc:	xor    rax,rax
    32cf:	mov    rbx,QWORD PTR [rsp+0x20]
    32d4:	mov    r12,QWORD PTR [rsp+0x28]
    32d9:	mov    r13,QWORD PTR [rsp+0x30]
    32de:	add    rsp,0x40
    32e2:	mov    rsp,rbp
    32e5:	pop    rbp
    32e6:	ret
    32e7:	mov    rbx,QWORD PTR [rsp+0x20]
    32ec:	mov    r12,QWORD PTR [rsp+0x28]
    32f1:	mov    r13,QWORD PTR [rsp+0x30]
    32f6:	add    rsp,0x40
    32fa:	mov    rsp,rbp
    32fd:	pop    rbp
    32fe:	ret
    32ff:	mov    eax,0xa
    3304:	mov    rbx,QWORD PTR [rsp+0x20]
    3309:	mov    r12,QWORD PTR [rsp+0x28]
    330e:	mov    r13,QWORD PTR [rsp+0x30]
    3313:	add    rsp,0x40
    3317:	mov    rsp,rbp
    331a:	pop    rbp
    331b:	ret
    331c:	add    BYTE PTR [rax],al
    331e:	add    BYTE PTR [rax],al
    3320:	(bad)
    3321:	add    BYTE PTR [rax],al
    3323:	add    BYTE PTR [rax],al
    3325:	add    BYTE PTR [rax],al
	...

0000000000003328 <botlish_entry_39: ht_get<mutarray, str>>:
    3328:	push   rbp
    3329:	mov    rbp,rsp
    332c:	mov    rsi,QWORD PTR [rdx]
    332f:	mov    rdx,QWORD PTR [rdx+0x8]
    3333:	call   3338 <botlish_entry_39+0x10>
			3334: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    3338:	mov    rsp,rbp
    333b:	pop    rbp
    333c:	ret
    333d:	add    BYTE PTR [rax],al
	...

0000000000003340 <botlish_fn_40: ht_rehash_probe<mutarray, int, int>>:
    3340:	push   rbp
    3341:	mov    rbp,rsp
    3344:	sub    rsp,0x40
    3348:	mov    QWORD PTR [rsp+0x20],rbx
    334d:	mov    QWORD PTR [rsp+0x28],r12
    3352:	mov    QWORD PTR [rsp+0x30],r13
    3357:	mov    QWORD PTR [rsp+0x38],r14
    335c:	mov    r13,rdi
    335f:	mov    QWORD PTR [rsp],rsi
    3363:	mov    QWORD PTR [rsp+0x8],rdx
    3368:	mov    QWORD PTR [rsp+0x10],rcx
    336d:	mov    r12,rcx
    3370:	mov    rbx,rsi
    3373:	mov    r14,rdx
    3376:	mov    rdx,r14
    3379:	mov    rsi,rbx
    337c:	mov    rdi,r13
    337f:	call   3384 <botlish_fn_40+0x44>
			3380: R_X86_64_PLT32	rt_mutarray_get-0x4
    3384:	test   rax,rax
    3387:	je     3424 <botlish_fn_40+0xe4>
    338d:	test   rax,0x1
    3393:	mov    rsi,rax
    3396:	jne    33b7 <botlish_fn_40+0x77>
    339c:	mov    edx,0x1
    33a1:	mov    rdi,r13
    33a4:	call   33a9 <botlish_fn_40+0x69>
			33a5: R_X86_64_PLT32	rt_value_eq-0x4
    33a9:	test   rax,rax
    33ac:	je     3424 <botlish_fn_40+0xe4>
    33b2:	jmp    33c8 <botlish_fn_40+0x88>
    33b7:	mov    eax,0x2
    33bc:	cmp    rsi,0x1
    33c0:	cmove  rax,QWORD PTR [rip+0xb8]        # 3480 <botlish_fn_40+0x140>
    33c8:	cmp    rax,0x6
    33cc:	je     345a <botlish_fn_40+0x11a>
    33d2:	mov    QWORD PTR [rsp+0x18],0x3
    33db:	mov    rsi,r14
    33de:	test   rsi,0x1
    33e5:	je     33fd <botlish_fn_40+0xbd>
    33eb:	mov    rsi,r14
    33ee:	add    rsi,0x2
    33f2:	seto   al
    33f5:	test   al,al
    33f7:	je     3410 <botlish_fn_40+0xd0>
    33fd:	mov    edx,0x3
    3402:	mov    rsi,r14
    3405:	mov    rdi,r13
    3408:	call   340d <botlish_fn_40+0xcd>
			3409: R_X86_64_PLT32	rt_int_add-0x4
    340d:	mov    rsi,rax
    3410:	mov    rdx,r12
    3413:	mov    rdi,r13
    3416:	call   341b <botlish_fn_40+0xdb>
			3417: R_X86_64_PLT32	rt_int_mod-0x4
    341b:	test   rax,rax
    341e:	jne    3444 <botlish_fn_40+0x104>
    3424:	xor    rax,rax
    3427:	mov    rbx,QWORD PTR [rsp+0x20]
    342c:	mov    r12,QWORD PTR [rsp+0x28]
    3431:	mov    r13,QWORD PTR [rsp+0x30]
    3436:	mov    r14,QWORD PTR [rsp+0x38]
    343b:	add    rsp,0x40
    343f:	mov    rsp,rbp
    3442:	pop    rbp
    3443:	ret
    3444:	mov    QWORD PTR [rsp],rbx
    3448:	mov    QWORD PTR [rsp+0x8],rax
    344d:	mov    QWORD PTR [rsp+0x10],r12
    3452:	mov    r14,rax
    3455:	jmp    3376 <botlish_fn_40+0x36>
    345a:	mov    rax,r14
    345d:	mov    rbx,QWORD PTR [rsp+0x20]
    3462:	mov    r12,QWORD PTR [rsp+0x28]
    3467:	mov    r13,QWORD PTR [rsp+0x30]
    346c:	mov    r14,QWORD PTR [rsp+0x38]
    3471:	add    rsp,0x40
    3475:	mov    rsp,rbp
    3478:	pop    rbp
    3479:	ret
    347a:	add    BYTE PTR [rax],al
    347c:	add    BYTE PTR [rax],al
    347e:	add    BYTE PTR [rax],al
    3480:	(bad)
    3481:	add    BYTE PTR [rax],al
    3483:	add    BYTE PTR [rax],al
    3485:	add    BYTE PTR [rax],al
	...

0000000000003488 <botlish_entry_40: ht_rehash_probe<mutarray, int, int>>:
    3488:	push   rbp
    3489:	mov    rbp,rsp
    348c:	mov    rsi,QWORD PTR [rdx]
    348f:	mov    r8,QWORD PTR [rdx+0x8]
    3493:	mov    rcx,QWORD PTR [rdx+0x10]
    3497:	mov    rdx,r8
    349a:	call   349f <botlish_entry_40+0x17>
			349b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    349f:	mov    rsp,rbp
    34a2:	pop    rbp
    34a3:	ret

00000000000034a4 <botlish_fn_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    34a4:	push   rbp
    34a5:	mov    rbp,rsp
    34a8:	sub    rsp,0x80
    34af:	mov    QWORD PTR [rsp+0x50],rbx
    34b4:	mov    QWORD PTR [rsp+0x58],r12
    34b9:	mov    QWORD PTR [rsp+0x60],r13
    34be:	mov    QWORD PTR [rsp+0x68],r14
    34c3:	mov    QWORD PTR [rsp+0x70],r15
    34c8:	mov    r12,rdi
    34cb:	mov    rdi,QWORD PTR [rbp+0x10]
    34cf:	mov    QWORD PTR [rsp],rsi
    34d3:	mov    QWORD PTR [rsp+0x38],rsi
    34d8:	mov    QWORD PTR [rsp+0x8],rdx
    34dd:	mov    r15,rdx
    34e0:	mov    QWORD PTR [rsp+0x10],rcx
    34e5:	mov    rbx,rcx
    34e8:	mov    QWORD PTR [rsp+0x18],r8
    34ed:	mov    QWORD PTR [rsp+0x40],r8
    34f2:	mov    QWORD PTR [rsp+0x20],r9
    34f7:	mov    r14,r9
    34fa:	mov    QWORD PTR [rsp+0x28],rdi
    34ff:	mov    r13,rdi
    3502:	mov    rsi,r14
    3505:	mov    rdi,r12
    3508:	call   350d <botlish_fn_41+0x69>
			3509: R_X86_64_PLT32	rt_hash-0x4
    350d:	test   rax,rax
    3510:	mov    rsi,rax
    3513:	je     35b2 <botlish_fn_41+0x10e>
    3519:	mov    rdx,QWORD PTR [rsp+0x40]
    351e:	mov    rdi,r12
    3521:	call   3526 <botlish_fn_41+0x82>
			3522: R_X86_64_PLT32	rt_int_mod-0x4
    3526:	test   rax,rax
    3529:	je     35b2 <botlish_fn_41+0x10e>
    352f:	mov    QWORD PTR [rsp+0x30],rax
    3534:	mov    rcx,QWORD PTR [rsp+0x40]
    3539:	mov    rdx,rax
    353c:	mov    rsi,QWORD PTR [rsp+0x38]
    3541:	mov    rdi,r12
    3544:	call   3549 <botlish_fn_41+0xa5>
			3545: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    3549:	mov    rcx,rax
    354c:	mov    QWORD PTR [rsp+0x40],rax
    3551:	test   rax,rcx
    3554:	je     35b2 <botlish_fn_41+0x10e>
    355a:	mov    ecx,0x3
    355f:	mov    rsi,QWORD PTR [rsp+0x38]
    3564:	mov    rdx,QWORD PTR [rsp+0x40]
    3569:	mov    rdi,r12
    356c:	call   3571 <botlish_fn_41+0xcd>
			356d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3571:	test   rax,rax
    3574:	je     35b2 <botlish_fn_41+0x10e>
    357a:	mov    rcx,r14
    357d:	mov    rsi,r15
    3580:	mov    rdx,QWORD PTR [rsp+0x40]
    3585:	mov    rdi,r12
    3588:	call   358d <botlish_fn_41+0xe9>
			3589: R_X86_64_PLT32	rt_mutarray_set-0x4
    358d:	test   rax,rax
    3590:	je     35b2 <botlish_fn_41+0x10e>
    3596:	mov    rcx,r13
    3599:	mov    rdx,QWORD PTR [rsp+0x40]
    359e:	mov    rsi,rbx
    35a1:	mov    rdi,r12
    35a4:	call   35a9 <botlish_fn_41+0x105>
			35a5: R_X86_64_PLT32	rt_mutarray_set-0x4
    35a9:	test   rax,rax
    35ac:	jne    35da <botlish_fn_41+0x136>
    35b2:	xor    rax,rax
    35b5:	mov    rbx,QWORD PTR [rsp+0x50]
    35ba:	mov    r12,QWORD PTR [rsp+0x58]
    35bf:	mov    r13,QWORD PTR [rsp+0x60]
    35c4:	mov    r14,QWORD PTR [rsp+0x68]
    35c9:	mov    r15,QWORD PTR [rsp+0x70]
    35ce:	add    rsp,0x80
    35d5:	mov    rsp,rbp
    35d8:	pop    rbp
    35d9:	ret
    35da:	mov    eax,0xa
    35df:	mov    rbx,QWORD PTR [rsp+0x50]
    35e4:	mov    r12,QWORD PTR [rsp+0x58]
    35e9:	mov    r13,QWORD PTR [rsp+0x60]
    35ee:	mov    r14,QWORD PTR [rsp+0x68]
    35f3:	mov    r15,QWORD PTR [rsp+0x70]
    35f8:	add    rsp,0x80
    35ff:	mov    rsp,rbp
    3602:	pop    rbp
    3603:	ret

0000000000003604 <botlish_entry_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    3604:	push   rbp
    3605:	mov    rbp,rsp
    3608:	sub    rsp,0x10
    360c:	mov    rsi,QWORD PTR [rdx]
    360f:	mov    r10,QWORD PTR [rdx+0x8]
    3613:	mov    rcx,QWORD PTR [rdx+0x10]
    3617:	mov    r8,QWORD PTR [rdx+0x18]
    361b:	mov    r9,QWORD PTR [rdx+0x20]
    361f:	mov    r11,QWORD PTR [rdx+0x28]
    3623:	mov    QWORD PTR [rsp],r11
    3627:	mov    rdx,r10
    362a:	call   362f <botlish_entry_41+0x2b>
			362b: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    362f:	add    rsp,0x10
    3633:	mov    rsp,rbp
    3636:	pop    rbp
    3637:	ret

0000000000003638 <botlish_fn_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3638:	push   rbp
    3639:	mov    rbp,rsp
    363c:	sub    rsp,0xc0
    3643:	mov    QWORD PTR [rsp+0x90],rbx
    364b:	mov    QWORD PTR [rsp+0x98],r12
    3653:	mov    QWORD PTR [rsp+0xa0],r13
    365b:	mov    QWORD PTR [rsp+0xa8],r14
    3663:	mov    QWORD PTR [rsp+0xb0],r15
    366b:	mov    QWORD PTR [rsp+0x58],rdi
    3670:	mov    r15,QWORD PTR [rbp+0x10]
    3674:	mov    r12,QWORD PTR [rbp+0x18]
    3678:	mov    r13,QWORD PTR [rbp+0x20]
    367c:	mov    r14,QWORD PTR [rbp+0x28]
    3680:	mov    QWORD PTR [rsp+0x10],rsi
    3685:	mov    QWORD PTR [rsp+0x60],rsi
    368a:	mov    QWORD PTR [rsp+0x18],rdx
    368f:	mov    QWORD PTR [rsp+0x68],rdx
    3694:	mov    QWORD PTR [rsp+0x20],rcx
    3699:	mov    QWORD PTR [rsp+0x70],rcx
    369e:	mov    QWORD PTR [rsp+0x28],r15
    36a3:	mov    QWORD PTR [rsp+0x30],r12
    36a8:	mov    QWORD PTR [rsp+0x38],r13
    36ad:	mov    QWORD PTR [rsp+0x40],r14
    36b2:	sar    r8,1
    36b5:	sar    r9,1
    36b8:	mov    QWORD PTR [rsp+0x88],r9
    36c0:	mov    rcx,QWORD PTR [rsp+0x88]
    36c8:	mov    rbx,r8
    36cb:	cmp    rbx,rcx
    36ce:	mov    QWORD PTR [rsp+0x88],rcx
    36d6:	jge    393f <botlish_fn_42+0x307>
    36dc:	xor    eax,eax
    36de:	mov    rsi,QWORD PTR [rsp+0x60]
    36e3:	test   rsi,0x7
    36ea:	jne    36fb <botlish_fn_42+0xc3>
    36f0:	movzx  r10,BYTE PTR [rsi]
    36f4:	cmp    r10b,0x8
    36f8:	sete   al
    36fb:	test   al,al
    36fd:	jne    371f <botlish_fn_42+0xe7>
    3703:	mov    rdi,QWORD PTR [rsp+0x58]
    3708:	mov    rax,QWORD PTR [rdi+0x10]
    370c:	mov    rcx,QWORD PTR [rax+0x30]
    3710:	mov    edx,0x8
    3715:	call   371a <botlish_fn_42+0xe2>
			3716: R_X86_64_PLT32	rt_type_error-0x4
    371a:	jmp    38bd <botlish_fn_42+0x285>
    371f:	mov    QWORD PTR [rsp+0x60],rsi
    3724:	mov    rdx,rbx
    3727:	shl    rdx,1
    372a:	or     rdx,0x1
    372e:	mov    QWORD PTR [rsp+0x80],rdx
    3736:	mov    rdi,QWORD PTR [rsp+0x58]
    373b:	call   3740 <botlish_fn_42+0x108>
			373c: R_X86_64_PLT32	rt_mutarray_get-0x4
    3740:	test   rax,rax
    3743:	je     38bd <botlish_fn_42+0x285>
    3749:	test   rax,0x1
    374f:	mov    rsi,rax
    3752:	jne    3775 <botlish_fn_42+0x13d>
    3758:	mov    edx,0x3
    375d:	mov    rdi,QWORD PTR [rsp+0x58]
    3762:	call   3767 <botlish_fn_42+0x12f>
			3763: R_X86_64_PLT32	rt_value_eq-0x4
    3767:	test   rax,rax
    376a:	je     38bd <botlish_fn_42+0x285>
    3770:	jmp    3786 <botlish_fn_42+0x14e>
    3775:	mov    eax,0x2
    377a:	cmp    rsi,0x3
    377e:	cmove  rax,QWORD PTR [rip+0x1f2]        # 3978 <botlish_fn_42+0x340>
    3786:	cmp    rax,0x6
    378a:	je     379a <botlish_fn_42+0x162>
    3790:	mov    rsi,QWORD PTR [rsp+0x60]
    3795:	jmp    38f9 <botlish_fn_42+0x2c1>
    379a:	xor    esi,esi
    379c:	mov    rdx,QWORD PTR [rsp+0x68]
    37a1:	test   rdx,0x7
    37a8:	je     37b8 <botlish_fn_42+0x180>
    37ae:	mov    QWORD PTR [rsp+0x68],rdx
    37b3:	jmp    37c7 <botlish_fn_42+0x18f>
    37b8:	movzx  rax,BYTE PTR [rdx]
    37bc:	mov    QWORD PTR [rsp+0x68],rdx
    37c1:	cmp    al,0x8
    37c3:	sete   sil
    37c7:	test   sil,sil
    37ca:	jne    37f1 <botlish_fn_42+0x1b9>
    37d0:	mov    rdi,QWORD PTR [rsp+0x58]
    37d5:	mov    rax,QWORD PTR [rdi+0x10]
    37d9:	mov    rcx,QWORD PTR [rax+0x30]
    37dd:	mov    edx,0x8
    37e2:	mov    rsi,QWORD PTR [rsp+0x68]
    37e7:	call   37ec <botlish_fn_42+0x1b4>
			37e8: R_X86_64_PLT32	rt_type_error-0x4
    37ec:	jmp    38bd <botlish_fn_42+0x285>
    37f1:	mov    rdx,QWORD PTR [rsp+0x80]
    37f9:	mov    rsi,QWORD PTR [rsp+0x68]
    37fe:	mov    rdi,QWORD PTR [rsp+0x58]
    3803:	call   3808 <botlish_fn_42+0x1d0>
			3804: R_X86_64_PLT32	rt_mutarray_get-0x4
    3808:	test   rax,rax
    380b:	je     38bd <botlish_fn_42+0x285>
    3811:	mov    QWORD PTR [rsp+0x48],rax
    3816:	mov    QWORD PTR [rsp+0x78],rax
    381b:	xor    eax,eax
    381d:	mov    rcx,QWORD PTR [rsp+0x70]
    3822:	test   rcx,0x7
    3829:	je     3839 <botlish_fn_42+0x201>
    382f:	mov    QWORD PTR [rsp+0x70],rcx
    3834:	jmp    3847 <botlish_fn_42+0x20f>
    3839:	movzx  rax,BYTE PTR [rcx]
    383d:	mov    QWORD PTR [rsp+0x70],rcx
    3842:	cmp    al,0x8
    3844:	sete   al
    3847:	test   al,al
    3849:	jne    3870 <botlish_fn_42+0x238>
    384f:	mov    rdi,QWORD PTR [rsp+0x58]
    3854:	mov    rax,QWORD PTR [rdi+0x10]
    3858:	mov    rcx,QWORD PTR [rax+0x30]
    385c:	mov    edx,0x8
    3861:	mov    rsi,QWORD PTR [rsp+0x70]
    3866:	call   386b <botlish_fn_42+0x233>
			3867: R_X86_64_PLT32	rt_type_error-0x4
    386b:	jmp    38bd <botlish_fn_42+0x285>
    3870:	mov    rdx,QWORD PTR [rsp+0x80]
    3878:	mov    rsi,QWORD PTR [rsp+0x70]
    387d:	mov    rdi,QWORD PTR [rsp+0x58]
    3882:	call   3887 <botlish_fn_42+0x24f>
			3883: R_X86_64_PLT32	rt_mutarray_get-0x4
    3887:	test   rax,rax
    388a:	je     38bd <botlish_fn_42+0x285>
    3890:	mov    QWORD PTR [rsp+0x50],rax
    3895:	mov    QWORD PTR [rsp],rax
    3899:	mov    r9,QWORD PTR [rsp+0x78]
    389e:	mov    rcx,r13
    38a1:	mov    rdx,r12
    38a4:	mov    rsi,r15
    38a7:	mov    rdi,QWORD PTR [rsp+0x58]
    38ac:	mov    r8,r14
    38af:	call   38b4 <botlish_fn_42+0x27c>
			38b0: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    38b4:	test   rax,rax
    38b7:	jne    38f4 <botlish_fn_42+0x2bc>
    38bd:	xor    rax,rax
    38c0:	mov    rbx,QWORD PTR [rsp+0x90]
    38c8:	mov    r12,QWORD PTR [rsp+0x98]
    38d0:	mov    r13,QWORD PTR [rsp+0xa0]
    38d8:	mov    r14,QWORD PTR [rsp+0xa8]
    38e0:	mov    r15,QWORD PTR [rsp+0xb0]
    38e8:	add    rsp,0xc0
    38ef:	mov    rsp,rbp
    38f2:	pop    rbp
    38f3:	ret
    38f4:	mov    rsi,QWORD PTR [rsp+0x60]
    38f9:	mov    rsi,QWORD PTR [rsp+0x60]
    38fe:	mov    QWORD PTR [rsp+0x10],rsi
    3903:	mov    rsi,QWORD PTR [rsp+0x68]
    3908:	mov    QWORD PTR [rsp+0x18],rsi
    390d:	mov    rsi,QWORD PTR [rsp+0x70]
    3912:	mov    QWORD PTR [rsp+0x20],rsi
    3917:	mov    QWORD PTR [rsp+0x28],r15
    391c:	mov    QWORD PTR [rsp+0x30],r12
    3921:	mov    QWORD PTR [rsp+0x38],r13
    3926:	mov    QWORD PTR [rsp+0x40],r14
    392b:	add    rbx,0x1
    3932:	mov    rcx,QWORD PTR [rsp+0x88]
    393a:	jmp    36cb <botlish_fn_42+0x93>
    393f:	mov    eax,0xa
    3944:	mov    rbx,QWORD PTR [rsp+0x90]
    394c:	mov    r12,QWORD PTR [rsp+0x98]
    3954:	mov    r13,QWORD PTR [rsp+0xa0]
    395c:	mov    r14,QWORD PTR [rsp+0xa8]
    3964:	mov    r15,QWORD PTR [rsp+0xb0]
    396c:	add    rsp,0xc0
    3973:	mov    rsp,rbp
    3976:	pop    rbp
    3977:	ret
    3978:	(bad)
    3979:	add    BYTE PTR [rax],al
    397b:	add    BYTE PTR [rax],al
    397d:	add    BYTE PTR [rax],al
	...

0000000000003980 <botlish_entry_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3980:	push   rbp
    3981:	mov    rbp,rsp
    3984:	sub    rsp,0x30
    3988:	mov    QWORD PTR [rsp+0x20],r12
    398d:	mov    rsi,QWORD PTR [rdx]
    3990:	mov    rax,QWORD PTR [rdx+0x8]
    3994:	mov    rcx,QWORD PTR [rdx+0x10]
    3998:	mov    r8,QWORD PTR [rdx+0x18]
    399c:	mov    r9,QWORD PTR [rdx+0x20]
    39a0:	mov    r10,QWORD PTR [rdx+0x28]
    39a4:	mov    r11,QWORD PTR [rdx+0x30]
    39a8:	mov    r12,QWORD PTR [rdx+0x38]
    39ac:	mov    rdx,QWORD PTR [rdx+0x40]
    39b0:	mov    QWORD PTR [rsp],r10
    39b4:	mov    QWORD PTR [rsp+0x8],r11
    39b9:	mov    QWORD PTR [rsp+0x10],r12
    39be:	mov    QWORD PTR [rsp+0x18],rdx
    39c3:	mov    rdx,rax
    39c6:	call   39cb <botlish_entry_42+0x4b>
			39c7: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    39cb:	mov    r12,QWORD PTR [rsp+0x20]
    39d0:	add    rsp,0x30
    39d4:	mov    rsp,rbp
    39d7:	pop    rbp
    39d8:	ret

00000000000039d9 <botlish_fn_43: ht_rehash<mutarray, int>>:
    39d9:	push   rbp
    39da:	mov    rbp,rsp
    39dd:	sub    rsp,0xd0
    39e4:	mov    QWORD PTR [rsp+0xa0],rbx
    39ec:	mov    QWORD PTR [rsp+0xa8],r12
    39f4:	mov    QWORD PTR [rsp+0xb0],r13
    39fc:	mov    QWORD PTR [rsp+0xb8],r14
    3a04:	mov    QWORD PTR [rsp+0xc0],r15
    3a0c:	mov    r13,rdi
    3a0f:	mov    QWORD PTR [rsp+0x50],0x0
    3a18:	mov    QWORD PTR [rsp+0x58],0x0
    3a21:	mov    QWORD PTR [rsp+0x60],0x0
    3a2a:	mov    QWORD PTR [rsp+0x68],0x0
    3a33:	mov    QWORD PTR [rsp+0x20],rsi
    3a38:	mov    r12,rsi
    3a3b:	mov    QWORD PTR [rsp+0x28],rdx
    3a40:	mov    rbx,rdx
    3a43:	mov    rsi,r12
    3a46:	mov    rdi,r13
    3a49:	call   3a4e <botlish_fn_43+0x75>
			3a4a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    3a4e:	test   rax,rax
    3a51:	je     3c20 <botlish_fn_43+0x247>
    3a57:	mov    QWORD PTR [rsp+0x30],rax
    3a5c:	mov    r14,rax
    3a5f:	mov    rsi,r12
    3a62:	mov    rdi,r13
    3a65:	call   3a6a <botlish_fn_43+0x91>
			3a66: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3a6a:	test   rax,rax
    3a6d:	je     3c20 <botlish_fn_43+0x247>
    3a73:	mov    QWORD PTR [rsp+0x38],rax
    3a78:	mov    r15,rax
    3a7b:	mov    rsi,r12
    3a7e:	mov    rdi,r13
    3a81:	call   3a86 <botlish_fn_43+0xad>
			3a82: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3a86:	test   rax,rax
    3a89:	je     3c20 <botlish_fn_43+0x247>
    3a8f:	mov    QWORD PTR [rsp+0x40],rax
    3a94:	mov    QWORD PTR [rsp+0x90],rax
    3a9c:	mov    rsi,r12
    3a9f:	mov    rdi,r13
    3aa2:	call   3aa7 <botlish_fn_43+0xce>
			3aa3: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3aa7:	test   rax,rax
    3aaa:	je     3c20 <botlish_fn_43+0x247>
    3ab0:	mov    QWORD PTR [rsp+0x48],rax
    3ab5:	mov    QWORD PTR [rsp+0x88],rax
    3abd:	mov    rsi,rbx
    3ac0:	mov    rdi,r13
    3ac3:	call   3ac8 <botlish_fn_43+0xef>
			3ac4: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3ac8:	mov    rcx,rax
    3acb:	mov    QWORD PTR [rsp+0x80],rax
    3ad3:	test   rax,rcx
    3ad6:	je     3c20 <botlish_fn_43+0x247>
    3adc:	mov    rax,QWORD PTR [rsp+0x80]
    3ae4:	mov    QWORD PTR [rsp+0x50],rax
    3ae9:	mov    edx,0x1
    3aee:	mov    QWORD PTR [rsp+0x58],0x1
    3af7:	mov    rcx,rbx
    3afa:	mov    rsi,QWORD PTR [rsp+0x80]
    3b02:	mov    rdi,r13
    3b05:	call   3b0a <botlish_fn_43+0x131>
			3b06: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3b0a:	test   rax,rax
    3b0d:	je     3c20 <botlish_fn_43+0x247>
    3b13:	mov    rsi,rbx
    3b16:	mov    rdi,r13
    3b19:	call   3b1e <botlish_fn_43+0x145>
			3b1a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b1e:	test   rax,rax
    3b21:	je     3c20 <botlish_fn_43+0x247>
    3b27:	mov    QWORD PTR [rsp+0x58],rax
    3b2c:	mov    QWORD PTR [rsp+0x78],rax
    3b31:	mov    rsi,rbx
    3b34:	mov    rdi,r13
    3b37:	call   3b3c <botlish_fn_43+0x163>
			3b38: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b3c:	test   rax,rax
    3b3f:	je     3c20 <botlish_fn_43+0x247>
    3b45:	mov    QWORD PTR [rsp+0x60],rax
    3b4a:	mov    r8d,0x1
    3b50:	mov    QWORD PTR [rsp+0x68],0x1
    3b59:	mov    rcx,QWORD PTR [rsp+0x80]
    3b61:	mov    QWORD PTR [rsp],rcx
    3b65:	mov    rcx,QWORD PTR [rsp+0x78]
    3b6a:	mov    QWORD PTR [rsp+0x8],rcx
    3b6f:	mov    QWORD PTR [rsp+0x10],rax
    3b74:	mov    QWORD PTR [rsp+0x70],rax
    3b79:	mov    QWORD PTR [rsp+0x18],rbx
    3b7e:	mov    rcx,QWORD PTR [rsp+0x90]
    3b86:	mov    rdx,r15
    3b89:	mov    rsi,r14
    3b8c:	mov    r9,QWORD PTR [rsp+0x88]
    3b94:	mov    rdi,r13
    3b97:	call   3b9c <botlish_fn_43+0x1c3>
			3b98: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3b9c:	test   rax,rax
    3b9f:	je     3c20 <botlish_fn_43+0x247>
    3ba5:	mov    edx,0x1
    3baa:	mov    rcx,QWORD PTR [rsp+0x80]
    3bb2:	mov    rsi,r12
    3bb5:	mov    rdi,r13
    3bb8:	call   3bbd <botlish_fn_43+0x1e4>
			3bb9: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bbd:	test   rax,rax
    3bc0:	je     3c20 <botlish_fn_43+0x247>
    3bc6:	mov    edx,0x3
    3bcb:	mov    rcx,QWORD PTR [rsp+0x78]
    3bd0:	mov    rsi,r12
    3bd3:	mov    rdi,r13
    3bd6:	call   3bdb <botlish_fn_43+0x202>
			3bd7: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bdb:	test   rax,rax
    3bde:	je     3c20 <botlish_fn_43+0x247>
    3be4:	mov    edx,0x5
    3be9:	mov    rcx,QWORD PTR [rsp+0x70]
    3bee:	mov    rsi,r12
    3bf1:	mov    rdi,r13
    3bf4:	call   3bf9 <botlish_fn_43+0x220>
			3bf5: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bf9:	test   rax,rax
    3bfc:	je     3c20 <botlish_fn_43+0x247>
    3c02:	mov    edx,0x9
    3c07:	mov    ecx,0x1
    3c0c:	mov    rsi,r12
    3c0f:	mov    rdi,r13
    3c12:	call   3c17 <botlish_fn_43+0x23e>
			3c13: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c17:	test   rax,rax
    3c1a:	jne    3c57 <botlish_fn_43+0x27e>
    3c20:	xor    rax,rax
    3c23:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c2b:	mov    r12,QWORD PTR [rsp+0xa8]
    3c33:	mov    r13,QWORD PTR [rsp+0xb0]
    3c3b:	mov    r14,QWORD PTR [rsp+0xb8]
    3c43:	mov    r15,QWORD PTR [rsp+0xc0]
    3c4b:	add    rsp,0xd0
    3c52:	mov    rsp,rbp
    3c55:	pop    rbp
    3c56:	ret
    3c57:	mov    eax,0xa
    3c5c:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c64:	mov    r12,QWORD PTR [rsp+0xa8]
    3c6c:	mov    r13,QWORD PTR [rsp+0xb0]
    3c74:	mov    r14,QWORD PTR [rsp+0xb8]
    3c7c:	mov    r15,QWORD PTR [rsp+0xc0]
    3c84:	add    rsp,0xd0
    3c8b:	mov    rsp,rbp
    3c8e:	pop    rbp
    3c8f:	ret

0000000000003c90 <botlish_entry_43: ht_rehash<mutarray, int>>:
    3c90:	push   rbp
    3c91:	mov    rbp,rsp
    3c94:	mov    rsi,QWORD PTR [rdx]
    3c97:	mov    rdx,QWORD PTR [rdx+0x8]
    3c9b:	call   3ca0 <botlish_entry_43+0x10>
			3c9c: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3ca0:	mov    rsp,rbp
    3ca3:	pop    rbp
    3ca4:	ret
    3ca5:	add    BYTE PTR [rax],al
	...

0000000000003ca8 <botlish_fn_44: ht_should_grow<mutarray>>:
    3ca8:	push   rbp
    3ca9:	mov    rbp,rsp
    3cac:	sub    rsp,0x40
    3cb0:	mov    QWORD PTR [rsp+0x20],rbx
    3cb5:	mov    QWORD PTR [rsp+0x28],r12
    3cba:	mov    QWORD PTR [rsp+0x30],r13
    3cbf:	mov    rbx,rdi
    3cc2:	mov    QWORD PTR [rsp],rsi
    3cc6:	mov    r12,rsi
    3cc9:	mov    rsi,r12
    3ccc:	mov    rdi,rbx
    3ccf:	call   3cd4 <botlish_fn_44+0x2c>
			3cd0: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3cd4:	mov    rcx,rax
    3cd7:	mov    r13,rax
    3cda:	test   rax,rcx
    3cdd:	je     3ecc <botlish_fn_44+0x224>
    3ce3:	mov    rax,r13
    3ce6:	mov    QWORD PTR [rsp+0x8],rax
    3ceb:	mov    rsi,r12
    3cee:	mov    rdi,rbx
    3cf1:	call   3cf6 <botlish_fn_44+0x4e>
			3cf2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3cf6:	mov    rcx,rax
    3cf9:	test   rcx,rcx
    3cfc:	je     3ecc <botlish_fn_44+0x224>
    3d02:	mov    QWORD PTR [rsp+0x10],rcx
    3d07:	mov    edx,0x1
    3d0c:	mov    rax,r13
    3d0f:	test   rax,0x1
    3d15:	jne    3d38 <botlish_fn_44+0x90>
    3d1b:	xor    edx,edx
    3d1d:	mov    rax,r13
    3d20:	test   rax,0x7
    3d26:	jne    3d38 <botlish_fn_44+0x90>
    3d2c:	mov    rax,r13
    3d2f:	movzx  rax,BYTE PTR [rax]
    3d33:	cmp    al,0x1
    3d35:	sete   dl
    3d38:	test   dl,dl
    3d3a:	jne    3d5b <botlish_fn_44+0xb3>
    3d40:	mov    rdi,rbx
    3d43:	mov    rax,QWORD PTR [rdi+0x10]
    3d47:	mov    rcx,QWORD PTR [rax+0x38]
    3d4b:	xor    rdx,rdx
    3d4e:	mov    rsi,r13
    3d51:	call   3d56 <botlish_fn_44+0xae>
			3d52: R_X86_64_PLT32	rt_type_error-0x4
    3d56:	jmp    3ecc <botlish_fn_44+0x224>
    3d5b:	mov    eax,0x1
    3d60:	test   rcx,0x1
    3d67:	je     3d75 <botlish_fn_44+0xcd>
    3d6d:	mov    r8,rcx
    3d70:	jmp    3d98 <botlish_fn_44+0xf0>
    3d75:	xor    eax,eax
    3d77:	test   rcx,0x7
    3d7e:	je     3d8c <botlish_fn_44+0xe4>
    3d84:	mov    r8,rcx
    3d87:	jmp    3d98 <botlish_fn_44+0xf0>
    3d8c:	movzx  rax,BYTE PTR [rcx]
    3d90:	mov    r8,rcx
    3d93:	cmp    al,0x1
    3d95:	sete   al
    3d98:	test   al,al
    3d9a:	jne    3dbb <botlish_fn_44+0x113>
    3da0:	mov    rdi,rbx
    3da3:	mov    rax,QWORD PTR [rdi+0x10]
    3da7:	mov    rcx,QWORD PTR [rax+0x38]
    3dab:	xor    rdx,rdx
    3dae:	mov    rsi,r8
    3db1:	call   3db6 <botlish_fn_44+0x10e>
			3db2: R_X86_64_PLT32	rt_type_error-0x4
    3db6:	jmp    3ecc <botlish_fn_44+0x224>
    3dbb:	mov    rcx,r8
    3dbe:	mov    rsi,r13
    3dc1:	mov    rax,rsi
    3dc4:	and    rax,rcx
    3dc7:	test   rax,0x1
    3dcd:	jne    3dde <botlish_fn_44+0x136>
    3dd3:	mov    rdx,r8
    3dd6:	mov    rsi,r13
    3dd9:	jmp    3dfc <botlish_fn_44+0x154>
    3dde:	mov    rcx,r8
    3de1:	lea    rax,[rcx-0x1]
    3de5:	mov    rsi,r13
    3de8:	add    rsi,rax
    3deb:	seto   al
    3dee:	test   al,al
    3df0:	je     3e07 <botlish_fn_44+0x15f>
    3df6:	mov    rdx,r8
    3df9:	mov    rsi,r13
    3dfc:	mov    rdi,rbx
    3dff:	call   3e04 <botlish_fn_44+0x15c>
			3e00: R_X86_64_PLT32	rt_int_add-0x4
    3e04:	mov    rsi,rax
    3e07:	mov    QWORD PTR [rsp+0x8],rsi
    3e0c:	mov    QWORD PTR [rsp+0x10],0x3
    3e15:	test   rsi,0x1
    3e1c:	je     3e3f <botlish_fn_44+0x197>
    3e22:	mov    rax,rsi
    3e25:	add    rax,0x2
    3e29:	mov    rcx,rax
    3e2c:	seto   al
    3e2f:	test   al,al
    3e31:	jne    3e3f <botlish_fn_44+0x197>
    3e37:	mov    rsi,rcx
    3e3a:	jmp    3e4f <botlish_fn_44+0x1a7>
    3e3f:	mov    edx,0x3
    3e44:	mov    rdi,rbx
    3e47:	call   3e4c <botlish_fn_44+0x1a4>
			3e48: R_X86_64_PLT32	rt_int_add-0x4
    3e4c:	mov    rsi,rax
    3e4f:	mov    QWORD PTR [rsp+0x8],rsi
    3e54:	mov    edx,0x7
    3e59:	mov    rdi,rdx
    3e5c:	mov    QWORD PTR [rsp+0x10],0x7
    3e65:	test   rsi,0x1
    3e6c:	jne    3e7a <botlish_fn_44+0x1d2>
    3e72:	mov    rdx,rdi
    3e75:	jmp    3ea6 <botlish_fn_44+0x1fe>
    3e7a:	mov    rax,rsi
    3e7d:	sar    rax,1
    3e80:	imul   QWORD PTR [rip+0x119]        # 3fa0 <botlish_fn_44+0x2f8>
    3e87:	seto   cl
    3e8a:	or     rax,0x1
    3e8e:	test   cl,cl
    3e90:	je     3e9e <botlish_fn_44+0x1f6>
    3e96:	mov    rdx,rdi
    3e99:	jmp    3ea6 <botlish_fn_44+0x1fe>
    3e9e:	mov    rsi,rax
    3ea1:	jmp    3eb1 <botlish_fn_44+0x209>
    3ea6:	mov    rdi,rbx
    3ea9:	call   3eae <botlish_fn_44+0x206>
			3eaa: R_X86_64_PLT32	rt_int_mul-0x4
    3eae:	mov    rsi,rax
    3eb1:	mov    QWORD PTR [rsp],rsi
    3eb5:	mov    r13,rsi
    3eb8:	mov    rsi,r12
    3ebb:	mov    rdi,rbx
    3ebe:	call   3ec3 <botlish_fn_44+0x21b>
			3ebf: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3ec3:	test   rax,rax
    3ec6:	jne    3ee7 <botlish_fn_44+0x23f>
    3ecc:	xor    rax,rax
    3ecf:	mov    rbx,QWORD PTR [rsp+0x20]
    3ed4:	mov    r12,QWORD PTR [rsp+0x28]
    3ed9:	mov    r13,QWORD PTR [rsp+0x30]
    3ede:	add    rsp,0x40
    3ee2:	mov    rsp,rbp
    3ee5:	pop    rbp
    3ee6:	ret
    3ee7:	mov    QWORD PTR [rsp+0x8],rax
    3eec:	mov    QWORD PTR [rsp+0x10],0x5
    3ef5:	test   rax,0x1
    3efb:	mov    rsi,rax
    3efe:	je     3f30 <botlish_fn_44+0x288>
    3f04:	mov    rcx,rsi
    3f07:	mov    rax,rcx
    3f0a:	sar    rax,1
    3f0d:	imul   QWORD PTR [rip+0x94]        # 3fa8 <botlish_fn_44+0x300>
    3f14:	seto   dil
    3f18:	or     rax,0x1
    3f1c:	test   dil,dil
    3f1f:	jne    3f30 <botlish_fn_44+0x288>
    3f25:	mov    rdx,rax
    3f28:	mov    rsi,r13
    3f2b:	jmp    3f43 <botlish_fn_44+0x29b>
    3f30:	mov    edx,0x5
    3f35:	mov    rdi,rbx
    3f38:	call   3f3d <botlish_fn_44+0x295>
			3f39: R_X86_64_PLT32	rt_int_mul-0x4
    3f3d:	mov    rdx,rax
    3f40:	mov    rsi,r13
    3f43:	mov    r10,rsi
    3f46:	and    r10,rdx
    3f49:	test   r10,0x1
    3f50:	jne    3f77 <botlish_fn_44+0x2cf>
    3f56:	mov    rdi,rbx
    3f59:	call   3f5e <botlish_fn_44+0x2b6>
			3f5a: R_X86_64_PLT32	rt_int_cmp-0x4
    3f5e:	mov    r8d,0x2
    3f64:	test   rax,rax
    3f67:	mov    rax,r8
    3f6a:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3fa0 <botlish_fn_44+0x2f8>
    3f72:	jmp    3f87 <botlish_fn_44+0x2df>
    3f77:	mov    eax,0x2
    3f7c:	cmp    rsi,rdx
    3f7f:	cmovg  rax,QWORD PTR [rip+0x19]        # 3fa0 <botlish_fn_44+0x2f8>
    3f87:	mov    rbx,QWORD PTR [rsp+0x20]
    3f8c:	mov    r12,QWORD PTR [rsp+0x28]
    3f91:	mov    r13,QWORD PTR [rsp+0x30]
    3f96:	add    rsp,0x40
    3f9a:	mov    rsp,rbp
    3f9d:	pop    rbp
    3f9e:	ret
    3f9f:	add    BYTE PTR [rsi],al
    3fa1:	add    BYTE PTR [rax],al
    3fa3:	add    BYTE PTR [rax],al
    3fa5:	add    BYTE PTR [rax],al
    3fa7:	add    BYTE PTR [rax+rax*1],al
    3faa:	add    BYTE PTR [rax],al
    3fac:	add    BYTE PTR [rax],al
	...

0000000000003fb0 <botlish_entry_44: ht_should_grow<mutarray>>:
    3fb0:	push   rbp
    3fb1:	mov    rbp,rsp
    3fb4:	mov    rsi,QWORD PTR [rdx]
    3fb7:	call   3fbc <botlish_entry_44+0xc>
			3fb8: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3fbc:	mov    rsp,rbp
    3fbf:	pop    rbp
    3fc0:	ret
    3fc1:	add    BYTE PTR [rax],al
    3fc3:	add    BYTE PTR [rax],al
    3fc5:	add    BYTE PTR [rax],al
	...

0000000000003fc8 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    3fc8:	push   rbp
    3fc9:	mov    rbp,rsp
    3fcc:	sub    rsp,0x40
    3fd0:	mov    QWORD PTR [rsp+0x20],rbx
    3fd5:	mov    QWORD PTR [rsp+0x28],r12
    3fda:	mov    QWORD PTR [rsp+0x30],r13
    3fdf:	mov    rbx,rdi
    3fe2:	mov    QWORD PTR [rsp+0x10],0x0
    3feb:	mov    QWORD PTR [rsp],rsi
    3fef:	mov    r12,rsi
    3ff2:	mov    rsi,r12
    3ff5:	mov    rdi,rbx
    3ff8:	call   3ffd <botlish_fn_45+0x35>
			3ff9: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3ffd:	test   rax,rax
    4000:	mov    r13,rax
    4003:	je     41f0 <botlish_fn_45+0x228>
    4009:	mov    rsi,r12
    400c:	mov    rdi,rbx
    400f:	call   4014 <botlish_fn_45+0x4c>
			4010: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    4014:	mov    rcx,rax
    4017:	test   rcx,rcx
    401a:	je     41f0 <botlish_fn_45+0x228>
    4020:	mov    edx,0x1
    4025:	mov    rax,r13
    4028:	test   rax,0x1
    402e:	je     403c <botlish_fn_45+0x74>
    4034:	mov    r13,rax
    4037:	jmp    4060 <botlish_fn_45+0x98>
    403c:	xor    edx,edx
    403e:	test   rax,0x7
    4044:	je     4052 <botlish_fn_45+0x8a>
    404a:	mov    r13,rax
    404d:	jmp    4060 <botlish_fn_45+0x98>
    4052:	movzx  rdx,BYTE PTR [rax]
    4056:	mov    r13,rax
    4059:	rex cmp dl,0x1
    405d:	sete   dl
    4060:	test   dl,dl
    4062:	jne    4083 <botlish_fn_45+0xbb>
    4068:	mov    rdi,rbx
    406b:	mov    rsi,QWORD PTR [rdi+0x10]
    406f:	mov    rcx,QWORD PTR [rsi+0x40]
    4073:	xor    rdx,rdx
    4076:	mov    rsi,r13
    4079:	call   407e <botlish_fn_45+0xb6>
			407a: R_X86_64_PLT32	rt_type_error-0x4
    407e:	jmp    41f0 <botlish_fn_45+0x228>
    4083:	mov    rsi,r13
    4086:	mov    eax,0x1
    408b:	test   rcx,0x1
    4092:	je     40a0 <botlish_fn_45+0xd8>
    4098:	mov    r8,rcx
    409b:	jmp    40c5 <botlish_fn_45+0xfd>
    40a0:	xor    eax,eax
    40a2:	test   rcx,0x7
    40a9:	je     40b7 <botlish_fn_45+0xef>
    40af:	mov    r8,rcx
    40b2:	jmp    40c5 <botlish_fn_45+0xfd>
    40b7:	movzx  r11,BYTE PTR [rcx]
    40bb:	mov    r8,rcx
    40be:	cmp    r11b,0x1
    40c2:	sete   al
    40c5:	test   al,al
    40c7:	jne    40e8 <botlish_fn_45+0x120>
    40cd:	mov    rdi,rbx
    40d0:	mov    rax,QWORD PTR [rdi+0x10]
    40d4:	mov    rcx,QWORD PTR [rax+0x40]
    40d8:	xor    rdx,rdx
    40db:	mov    rsi,r8
    40de:	call   40e3 <botlish_fn_45+0x11b>
			40df: R_X86_64_PLT32	rt_type_error-0x4
    40e3:	jmp    41f0 <botlish_fn_45+0x228>
    40e8:	mov    rcx,r8
    40eb:	mov    rax,rsi
    40ee:	and    rax,rcx
    40f1:	test   rax,0x1
    40f7:	jne    411d <botlish_fn_45+0x155>
    40fd:	mov    rdx,r8
    4100:	mov    rdi,rbx
    4103:	call   4108 <botlish_fn_45+0x140>
			4104: R_X86_64_PLT32	rt_int_cmp-0x4
    4108:	mov    ecx,0x2
    410d:	test   rax,rax
    4110:	cmovg  rcx,QWORD PTR [rip+0x110]        # 4228 <botlish_fn_45+0x260>
    4118:	jmp    4130 <botlish_fn_45+0x168>
    411d:	mov    ecx,0x2
    4122:	mov    r9,r8
    4125:	cmp    rsi,r9
    4128:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 4228 <botlish_fn_45+0x260>
    4130:	cmp    rcx,0x6
    4134:	je     41c0 <botlish_fn_45+0x1f8>
    413a:	mov    rsi,r12
    413d:	mov    rdi,rbx
    4140:	call   4145 <botlish_fn_45+0x17d>
			4141: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4145:	test   rax,rax
    4148:	je     41f0 <botlish_fn_45+0x228>
    414e:	mov    QWORD PTR [rsp+0x8],rax
    4153:	mov    QWORD PTR [rsp+0x10],0x5
    415c:	test   rax,0x1
    4162:	mov    rsi,rax
    4165:	je     4192 <botlish_fn_45+0x1ca>
    416b:	mov    rcx,rsi
    416e:	mov    rax,rcx
    4171:	sar    rax,1
    4174:	imul   QWORD PTR [rip+0xb5]        # 4230 <botlish_fn_45+0x268>
    417b:	seto   cl
    417e:	or     rax,0x1
    4182:	test   cl,cl
    4184:	jne    4192 <botlish_fn_45+0x1ca>
    418a:	mov    rdx,rax
    418d:	jmp    41a2 <botlish_fn_45+0x1da>
    4192:	mov    edx,0x5
    4197:	mov    rdi,rbx
    419a:	call   419f <botlish_fn_45+0x1d7>
			419b: R_X86_64_PLT32	rt_int_mul-0x4
    419f:	mov    rdx,rax
    41a2:	mov    QWORD PTR [rsp+0x8],rdx
    41a7:	mov    rsi,r12
    41aa:	mov    rdi,rbx
    41ad:	call   41b2 <botlish_fn_45+0x1ea>
			41ae: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41b2:	test   rax,rax
    41b5:	je     41f0 <botlish_fn_45+0x228>
    41bb:	jmp    420b <botlish_fn_45+0x243>
    41c0:	mov    rsi,r12
    41c3:	mov    rdi,rbx
    41c6:	call   41cb <botlish_fn_45+0x203>
			41c7: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    41cb:	test   rax,rax
    41ce:	je     41f0 <botlish_fn_45+0x228>
    41d4:	mov    QWORD PTR [rsp+0x8],rax
    41d9:	mov    rdx,rax
    41dc:	mov    rsi,r12
    41df:	mov    rdi,rbx
    41e2:	call   41e7 <botlish_fn_45+0x21f>
			41e3: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41e7:	test   rax,rax
    41ea:	jne    420b <botlish_fn_45+0x243>
    41f0:	xor    rax,rax
    41f3:	mov    rbx,QWORD PTR [rsp+0x20]
    41f8:	mov    r12,QWORD PTR [rsp+0x28]
    41fd:	mov    r13,QWORD PTR [rsp+0x30]
    4202:	add    rsp,0x40
    4206:	mov    rsp,rbp
    4209:	pop    rbp
    420a:	ret
    420b:	mov    rbx,QWORD PTR [rsp+0x20]
    4210:	mov    r12,QWORD PTR [rsp+0x28]
    4215:	mov    r13,QWORD PTR [rsp+0x30]
    421a:	add    rsp,0x40
    421e:	mov    rsp,rbp
    4221:	pop    rbp
    4222:	ret
    4223:	add    BYTE PTR [rax],al
    4225:	add    BYTE PTR [rax],al
    4227:	add    BYTE PTR [rsi],al
    4229:	add    BYTE PTR [rax],al
    422b:	add    BYTE PTR [rax],al
    422d:	add    BYTE PTR [rax],al
    422f:	add    BYTE PTR [rax+rax*1],al
    4232:	add    BYTE PTR [rax],al
    4234:	add    BYTE PTR [rax],al
	...

0000000000004238 <botlish_entry_45: ht_grow_or_clean<mutarray>>:
    4238:	push   rbp
    4239:	mov    rbp,rsp
    423c:	mov    rsi,QWORD PTR [rdx]
    423f:	call   4244 <botlish_entry_45+0xc>
			4240: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    4244:	mov    rsp,rbp
    4247:	pop    rbp
    4248:	ret
    4249:	add    BYTE PTR [rax],al
    424b:	add    BYTE PTR [rax],al
    424d:	add    BYTE PTR [rax],al
	...

0000000000004250 <botlish_fn_46: ht_place<mutarray, int, str, str>>:
    4250:	push   rbp
    4251:	mov    rbp,rsp
    4254:	sub    rsp,0x70
    4258:	mov    QWORD PTR [rsp+0x40],rbx
    425d:	mov    QWORD PTR [rsp+0x48],r12
    4262:	mov    QWORD PTR [rsp+0x50],r13
    4267:	mov    QWORD PTR [rsp+0x58],r14
    426c:	mov    QWORD PTR [rsp+0x60],r15
    4271:	mov    rbx,rdi
    4274:	mov    r14,r8
    4277:	mov    r15,rdx
    427a:	mov    QWORD PTR [rsp+0x28],rcx
    427f:	mov    QWORD PTR [rsp],rsi
    4283:	mov    r12,rsi
    4286:	mov    rsi,r12
    4289:	mov    rdi,rbx
    428c:	call   4291 <botlish_fn_46+0x41>
			428d: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    4291:	test   rax,rax
    4294:	je     45f8 <botlish_fn_46+0x3a8>
    429a:	xor    ecx,ecx
    429c:	test   rax,0x7
    42a2:	je     42b2 <botlish_fn_46+0x62>
    42a8:	mov    QWORD PTR [rsp+0x30],rax
    42ad:	jmp    42c2 <botlish_fn_46+0x72>
    42b2:	movzx  rcx,BYTE PTR [rax]
    42b6:	mov    QWORD PTR [rsp+0x30],rax
    42bb:	rex cmp cl,0x8
    42bf:	sete   cl
    42c2:	test   cl,cl
    42c4:	jne    42e9 <botlish_fn_46+0x99>
    42ca:	mov    rdi,rbx
    42cd:	mov    rax,QWORD PTR [rdi+0x10]
    42d1:	mov    rcx,QWORD PTR [rax+0x30]
    42d5:	mov    edx,0x8
    42da:	mov    rsi,QWORD PTR [rsp+0x30]
    42df:	call   42e4 <botlish_fn_46+0x94>
			42e0: R_X86_64_PLT32	rt_type_error-0x4
    42e4:	jmp    45f8 <botlish_fn_46+0x3a8>
    42e9:	mov    rdx,r15
    42ec:	mov    rsi,QWORD PTR [rsp+0x30]
    42f1:	mov    rdi,rbx
    42f4:	call   42f9 <botlish_fn_46+0xa9>
			42f5: R_X86_64_PLT32	rt_mutarray_get-0x4
    42f9:	test   rax,rax
    42fc:	je     45f8 <botlish_fn_46+0x3a8>
    4302:	mov    QWORD PTR [rsp+0x8],rax
    4307:	mov    r13,rax
    430a:	mov    ecx,0x3
    430f:	mov    rsi,QWORD PTR [rsp+0x30]
    4314:	mov    rdx,r15
    4317:	mov    rdi,rbx
    431a:	call   431f <botlish_fn_46+0xcf>
			431b: R_X86_64_PLT32	rt_mutarray_set-0x4
    431f:	test   rax,rax
    4322:	je     45f8 <botlish_fn_46+0x3a8>
    4328:	mov    rsi,r12
    432b:	mov    rdi,rbx
    432e:	call   4333 <botlish_fn_46+0xe3>
			432f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    4333:	test   rax,rax
    4336:	je     45f8 <botlish_fn_46+0x3a8>
    433c:	xor    ecx,ecx
    433e:	test   rax,0x7
    4344:	je     4352 <botlish_fn_46+0x102>
    434a:	mov    rsi,rax
    434d:	jmp    4360 <botlish_fn_46+0x110>
    4352:	movzx  rcx,BYTE PTR [rax]
    4356:	mov    rsi,rax
    4359:	rex cmp cl,0x8
    435d:	sete   cl
    4360:	test   cl,cl
    4362:	jne    4381 <botlish_fn_46+0x131>
    4368:	mov    rdi,rbx
    436b:	mov    rax,QWORD PTR [rdi+0x10]
    436f:	mov    rcx,QWORD PTR [rax]
    4372:	mov    edx,0x8
    4377:	call   437c <botlish_fn_46+0x12c>
			4378: R_X86_64_PLT32	rt_type_error-0x4
    437c:	jmp    45f8 <botlish_fn_46+0x3a8>
    4381:	mov    rcx,QWORD PTR [rsp+0x28]
    4386:	mov    rdx,r15
    4389:	mov    rdi,rbx
    438c:	call   4391 <botlish_fn_46+0x141>
			438d: R_X86_64_PLT32	rt_mutarray_set-0x4
    4391:	test   rax,rax
    4394:	je     45f8 <botlish_fn_46+0x3a8>
    439a:	mov    rsi,r12
    439d:	mov    rdi,rbx
    43a0:	call   43a5 <botlish_fn_46+0x155>
			43a1: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    43a5:	test   rax,rax
    43a8:	je     45f8 <botlish_fn_46+0x3a8>
    43ae:	xor    esi,esi
    43b0:	test   rax,0x7
    43b6:	jne    43c8 <botlish_fn_46+0x178>
    43bc:	movzx  rcx,BYTE PTR [rax]
    43c0:	rex cmp cl,0x8
    43c4:	sete   sil
    43c8:	test   sil,sil
    43cb:	jne    43ed <botlish_fn_46+0x19d>
    43d1:	mov    rdi,rbx
    43d4:	mov    rsi,QWORD PTR [rdi+0x10]
    43d8:	mov    rcx,QWORD PTR [rsi]
    43db:	mov    edx,0x8
    43e0:	mov    rsi,rax
    43e3:	call   43e8 <botlish_fn_46+0x198>
			43e4: R_X86_64_PLT32	rt_type_error-0x4
    43e8:	jmp    45f8 <botlish_fn_46+0x3a8>
    43ed:	mov    rcx,r14
    43f0:	mov    rdx,r15
    43f3:	mov    rsi,rax
    43f6:	mov    rdi,rbx
    43f9:	call   43fe <botlish_fn_46+0x1ae>
			43fa: R_X86_64_PLT32	rt_mutarray_set-0x4
    43fe:	test   rax,rax
    4401:	je     45f8 <botlish_fn_46+0x3a8>
    4407:	mov    QWORD PTR [rsp+0x10],0x7
    4410:	mov    rsi,r12
    4413:	mov    rdi,rbx
    4416:	call   441b <botlish_fn_46+0x1cb>
			4417: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    441b:	test   rax,rax
    441e:	je     45f8 <botlish_fn_46+0x3a8>
    4424:	mov    QWORD PTR [rsp+0x18],rax
    4429:	mov    QWORD PTR [rsp+0x20],0x3
    4432:	mov    ecx,0x1
    4437:	test   rax,0x1
    443d:	je     444b <botlish_fn_46+0x1fb>
    4443:	mov    rsi,rax
    4446:	jmp    446f <botlish_fn_46+0x21f>
    444b:	xor    ecx,ecx
    444d:	test   rax,0x7
    4453:	je     4461 <botlish_fn_46+0x211>
    4459:	mov    rsi,rax
    445c:	jmp    446f <botlish_fn_46+0x21f>
    4461:	movzx  rcx,BYTE PTR [rax]
    4465:	mov    rsi,rax
    4468:	rex cmp cl,0x1
    446c:	sete   cl
    446f:	test   cl,cl
    4471:	jne    448f <botlish_fn_46+0x23f>
    4477:	mov    rdi,rbx
    447a:	mov    rax,QWORD PTR [rdi+0x10]
    447e:	mov    rcx,QWORD PTR [rax+0x38]
    4482:	xor    rdx,rdx
    4485:	call   448a <botlish_fn_46+0x23a>
			4486: R_X86_64_PLT32	rt_type_error-0x4
    448a:	jmp    45f8 <botlish_fn_46+0x3a8>
    448f:	test   rsi,0x1
    4496:	je     44ae <botlish_fn_46+0x25e>
    449c:	mov    rcx,rsi
    449f:	add    rcx,0x2
    44a3:	seto   al
    44a6:	test   al,al
    44a8:	je     44be <botlish_fn_46+0x26e>
    44ae:	mov    edx,0x3
    44b3:	mov    rdi,rbx
    44b6:	call   44bb <botlish_fn_46+0x26b>
			44b7: R_X86_64_PLT32	rt_int_add-0x4
    44bb:	mov    rcx,rax
    44be:	mov    edx,0x7
    44c3:	mov    rsi,r12
    44c6:	mov    rdi,rbx
    44c9:	call   44ce <botlish_fn_46+0x27e>
			44ca: R_X86_64_PLT32	rt_mutarray_set-0x4
    44ce:	test   rax,rax
    44d1:	je     45f8 <botlish_fn_46+0x3a8>
    44d7:	mov    rax,r13
    44da:	test   rax,0x1
    44e0:	jne    4504 <botlish_fn_46+0x2b4>
    44e6:	mov    edx,0x5
    44eb:	mov    rsi,r13
    44ee:	mov    rdi,rbx
    44f1:	call   44f6 <botlish_fn_46+0x2a6>
			44f2: R_X86_64_PLT32	rt_value_eq-0x4
    44f6:	test   rax,rax
    44f9:	je     45f8 <botlish_fn_46+0x3a8>
    44ff:	jmp    4518 <botlish_fn_46+0x2c8>
    4504:	mov    rsi,r13
    4507:	mov    eax,0x2
    450c:	cmp    rsi,0x5
    4510:	cmove  rax,QWORD PTR [rip+0x130]        # 4648 <botlish_fn_46+0x3f8>
    4518:	cmp    rax,0x6
    451c:	jne    461d <botlish_fn_46+0x3cd>
    4522:	mov    QWORD PTR [rsp+0x8],0x9
    452b:	mov    rsi,r12
    452e:	mov    rdi,rbx
    4531:	call   4536 <botlish_fn_46+0x2e6>
			4532: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4536:	test   rax,rax
    4539:	je     45f8 <botlish_fn_46+0x3a8>
    453f:	mov    QWORD PTR [rsp+0x10],rax
    4544:	mov    QWORD PTR [rsp+0x18],0x3
    454d:	mov    ecx,0x1
    4552:	test   rax,0x1
    4558:	je     4566 <botlish_fn_46+0x316>
    455e:	mov    rsi,rax
    4561:	jmp    458a <botlish_fn_46+0x33a>
    4566:	xor    ecx,ecx
    4568:	test   rax,0x7
    456e:	je     457c <botlish_fn_46+0x32c>
    4574:	mov    rsi,rax
    4577:	jmp    458a <botlish_fn_46+0x33a>
    457c:	movzx  rcx,BYTE PTR [rax]
    4580:	mov    rsi,rax
    4583:	rex cmp cl,0x1
    4587:	sete   cl
    458a:	test   cl,cl
    458c:	jne    45aa <botlish_fn_46+0x35a>
    4592:	mov    rdi,rbx
    4595:	mov    rcx,QWORD PTR [rdi+0x10]
    4599:	mov    rcx,QWORD PTR [rcx+0x48]
    459d:	xor    rdx,rdx
    45a0:	call   45a5 <botlish_fn_46+0x355>
			45a1: R_X86_64_PLT32	rt_type_error-0x4
    45a5:	jmp    45f8 <botlish_fn_46+0x3a8>
    45aa:	test   rsi,0x1
    45b1:	je     45cf <botlish_fn_46+0x37f>
    45b7:	mov    r8,rsi
    45ba:	sub    r8,0x3
    45be:	seto   dil
    45c2:	lea    rcx,[r8+0x1]
    45c6:	test   dil,dil
    45c9:	je     45df <botlish_fn_46+0x38f>
    45cf:	mov    edx,0x3
    45d4:	mov    rdi,rbx
    45d7:	call   45dc <botlish_fn_46+0x38c>
			45d8: R_X86_64_PLT32	rt_int_sub-0x4
    45dc:	mov    rcx,rax
    45df:	mov    edx,0x9
    45e4:	mov    rsi,r12
    45e7:	mov    rdi,rbx
    45ea:	call   45ef <botlish_fn_46+0x39f>
			45eb: R_X86_64_PLT32	rt_mutarray_set-0x4
    45ef:	test   rax,rax
    45f2:	jne    461d <botlish_fn_46+0x3cd>
    45f8:	xor    rax,rax
    45fb:	mov    rbx,QWORD PTR [rsp+0x40]
    4600:	mov    r12,QWORD PTR [rsp+0x48]
    4605:	mov    r13,QWORD PTR [rsp+0x50]
    460a:	mov    r14,QWORD PTR [rsp+0x58]
    460f:	mov    r15,QWORD PTR [rsp+0x60]
    4614:	add    rsp,0x70
    4618:	mov    rsp,rbp
    461b:	pop    rbp
    461c:	ret
    461d:	mov    eax,0xa
    4622:	mov    rbx,QWORD PTR [rsp+0x40]
    4627:	mov    r12,QWORD PTR [rsp+0x48]
    462c:	mov    r13,QWORD PTR [rsp+0x50]
    4631:	mov    r14,QWORD PTR [rsp+0x58]
    4636:	mov    r15,QWORD PTR [rsp+0x60]
    463b:	add    rsp,0x70
    463f:	mov    rsp,rbp
    4642:	pop    rbp
    4643:	ret
    4644:	add    BYTE PTR [rax],al
    4646:	add    BYTE PTR [rax],al
    4648:	(bad)
    4649:	add    BYTE PTR [rax],al
    464b:	add    BYTE PTR [rax],al
    464d:	add    BYTE PTR [rax],al
	...

0000000000004650 <botlish_entry_46: ht_place<mutarray, int, str, str>>:
    4650:	push   rbp
    4651:	mov    rbp,rsp
    4654:	mov    rsi,QWORD PTR [rdx]
    4657:	mov    r9,QWORD PTR [rdx+0x8]
    465b:	mov    rcx,QWORD PTR [rdx+0x10]
    465f:	mov    r8,QWORD PTR [rdx+0x18]
    4663:	mov    rdx,r9
    4666:	call   466b <botlish_entry_46+0x1b>
			4667: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    466b:	mov    rsp,rbp
    466e:	pop    rbp
    466f:	ret

0000000000004670 <botlish_fn_47: ht_set<mutarray, str, str>>:
    4670:	push   rbp
    4671:	mov    rbp,rsp
    4674:	sub    rsp,0x60
    4678:	mov    QWORD PTR [rsp+0x30],rbx
    467d:	mov    QWORD PTR [rsp+0x38],r12
    4682:	mov    QWORD PTR [rsp+0x40],r13
    4687:	mov    QWORD PTR [rsp+0x48],r14
    468c:	mov    QWORD PTR [rsp+0x50],r15
    4691:	mov    rbx,rdi
    4694:	mov    r13,rdx
    4697:	mov    QWORD PTR [rsp],rsi
    469b:	mov    r14,rsi
    469e:	mov    QWORD PTR [rsp+0x8],rdx
    46a3:	mov    QWORD PTR [rsp+0x10],rcx
    46a8:	mov    r12,rcx
    46ab:	mov    rdx,r13
    46ae:	mov    rsi,r14
    46b1:	mov    rdi,rbx
    46b4:	call   46b9 <botlish_fn_47+0x49>
			46b5: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    46b9:	test   rax,rax
    46bc:	je     4926 <botlish_fn_47+0x2b6>
    46c2:	mov    QWORD PTR [rsp+0x18],rax
    46c7:	mov    rcx,rax
    46ca:	mov    r8,0xffffffffffffffff
    46d1:	mov    QWORD PTR [rsp+0x28],r8
    46d6:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    46df:	mov    rdx,r13
    46e2:	mov    rsi,r14
    46e5:	mov    rdi,rbx
    46e8:	call   46ed <botlish_fn_47+0x7d>
			46e9: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    46ed:	mov    rcx,rax
    46f0:	mov    r15,rax
    46f3:	test   rax,rcx
    46f6:	je     4926 <botlish_fn_47+0x2b6>
    46fc:	mov    rax,r15
    46ff:	mov    QWORD PTR [rsp+0x18],rax
    4704:	mov    rsi,r14
    4707:	mov    rdi,rbx
    470a:	call   470f <botlish_fn_47+0x9f>
			470b: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    470f:	test   rax,rax
    4712:	je     4926 <botlish_fn_47+0x2b6>
    4718:	xor    ecx,ecx
    471a:	test   rax,0x7
    4720:	je     472e <botlish_fn_47+0xbe>
    4726:	mov    r8,rax
    4729:	jmp    473c <botlish_fn_47+0xcc>
    472e:	movzx  rcx,BYTE PTR [rax]
    4732:	mov    r8,rax
    4735:	rex cmp cl,0x8
    4739:	sete   cl
    473c:	test   cl,cl
    473e:	jne    4761 <botlish_fn_47+0xf1>
    4744:	mov    rdi,rbx
    4747:	mov    rsi,QWORD PTR [rdi+0x10]
    474b:	mov    rcx,QWORD PTR [rsi+0x30]
    474f:	mov    edx,0x8
    4754:	mov    rsi,r8
    4757:	call   475c <botlish_fn_47+0xec>
			4758: R_X86_64_PLT32	rt_type_error-0x4
    475c:	jmp    4926 <botlish_fn_47+0x2b6>
    4761:	mov    rsi,r8
    4764:	mov    rdx,r15
    4767:	mov    rdi,rbx
    476a:	call   476f <botlish_fn_47+0xff>
			476b: R_X86_64_PLT32	rt_mutarray_get-0x4
    476f:	test   rax,rax
    4772:	je     4926 <botlish_fn_47+0x2b6>
    4778:	test   rax,0x1
    477e:	mov    rsi,rax
    4781:	jne    47a2 <botlish_fn_47+0x132>
    4787:	mov    edx,0x3
    478c:	mov    rdi,rbx
    478f:	call   4794 <botlish_fn_47+0x124>
			4790: R_X86_64_PLT32	rt_value_eq-0x4
    4794:	test   rax,rax
    4797:	je     4926 <botlish_fn_47+0x2b6>
    479d:	jmp    47b3 <botlish_fn_47+0x143>
    47a2:	mov    eax,0x2
    47a7:	cmp    rsi,0x3
    47ab:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4978 <botlish_fn_47+0x308>
    47b3:	cmp    rax,0x6
    47b7:	je     48b6 <botlish_fn_47+0x246>
    47bd:	mov    rsi,r14
    47c0:	mov    rdi,rbx
    47c3:	call   47c8 <botlish_fn_47+0x158>
			47c4: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    47c8:	test   rax,rax
    47cb:	je     4926 <botlish_fn_47+0x2b6>
    47d1:	cmp    rax,0x6
    47d5:	je     481a <botlish_fn_47+0x1aa>
    47db:	mov    rcx,r13
    47de:	mov    rdx,r15
    47e1:	mov    rsi,r14
    47e4:	mov    rdi,rbx
    47e7:	mov    r8,r12
    47ea:	call   47ef <botlish_fn_47+0x17f>
			47eb: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    47ef:	test   rax,rax
    47f2:	je     4926 <botlish_fn_47+0x2b6>
    47f8:	mov    rbx,QWORD PTR [rsp+0x30]
    47fd:	mov    r12,QWORD PTR [rsp+0x38]
    4802:	mov    r13,QWORD PTR [rsp+0x40]
    4807:	mov    r14,QWORD PTR [rsp+0x48]
    480c:	mov    r15,QWORD PTR [rsp+0x50]
    4811:	add    rsp,0x60
    4815:	mov    rsp,rbp
    4818:	pop    rbp
    4819:	ret
    481a:	mov    rsi,r14
    481d:	mov    rdi,rbx
    4820:	call   4825 <botlish_fn_47+0x1b5>
			4821: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    4825:	test   rax,rax
    4828:	je     4926 <botlish_fn_47+0x2b6>
    482e:	mov    rdx,r13
    4831:	mov    rsi,r14
    4834:	mov    rdi,rbx
    4837:	call   483c <botlish_fn_47+0x1cc>
			4838: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    483c:	test   rax,rax
    483f:	je     4926 <botlish_fn_47+0x2b6>
    4845:	mov    QWORD PTR [rsp+0x18],rax
    484a:	mov    rcx,rax
    484d:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4856:	mov    r8,QWORD PTR [rsp+0x28]
    485b:	mov    rdx,r13
    485e:	mov    rsi,r14
    4861:	mov    rdi,rbx
    4864:	call   4869 <botlish_fn_47+0x1f9>
			4865: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4869:	test   rax,rax
    486c:	je     4926 <botlish_fn_47+0x2b6>
    4872:	mov    QWORD PTR [rsp+0x18],rax
    4877:	mov    rcx,r13
    487a:	mov    rdx,rax
    487d:	mov    rsi,r14
    4880:	mov    rdi,rbx
    4883:	mov    r8,r12
    4886:	call   488b <botlish_fn_47+0x21b>
			4887: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    488b:	test   rax,rax
    488e:	je     4926 <botlish_fn_47+0x2b6>
    4894:	mov    rbx,QWORD PTR [rsp+0x30]
    4899:	mov    r12,QWORD PTR [rsp+0x38]
    489e:	mov    r13,QWORD PTR [rsp+0x40]
    48a3:	mov    r14,QWORD PTR [rsp+0x48]
    48a8:	mov    r15,QWORD PTR [rsp+0x50]
    48ad:	add    rsp,0x60
    48b1:	mov    rsp,rbp
    48b4:	pop    rbp
    48b5:	ret
    48b6:	mov    rsi,r14
    48b9:	mov    rdi,rbx
    48bc:	call   48c1 <botlish_fn_47+0x251>
			48bd: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    48c1:	test   rax,rax
    48c4:	je     4926 <botlish_fn_47+0x2b6>
    48ca:	xor    ecx,ecx
    48cc:	test   rax,0x7
    48d2:	je     48e0 <botlish_fn_47+0x270>
    48d8:	mov    rsi,rax
    48db:	jmp    48ee <botlish_fn_47+0x27e>
    48e0:	movzx  rcx,BYTE PTR [rax]
    48e4:	mov    rsi,rax
    48e7:	rex cmp cl,0x8
    48eb:	sete   cl
    48ee:	test   cl,cl
    48f0:	jne    490f <botlish_fn_47+0x29f>
    48f6:	mov    rdi,rbx
    48f9:	mov    rax,QWORD PTR [rdi+0x10]
    48fd:	mov    rcx,QWORD PTR [rax]
    4900:	mov    edx,0x8
    4905:	call   490a <botlish_fn_47+0x29a>
			4906: R_X86_64_PLT32	rt_type_error-0x4
    490a:	jmp    4926 <botlish_fn_47+0x2b6>
    490f:	mov    rcx,r12
    4912:	mov    rdx,r15
    4915:	mov    rdi,rbx
    4918:	call   491d <botlish_fn_47+0x2ad>
			4919: R_X86_64_PLT32	rt_mutarray_set-0x4
    491d:	test   rax,rax
    4920:	jne    494b <botlish_fn_47+0x2db>
    4926:	xor    rax,rax
    4929:	mov    rbx,QWORD PTR [rsp+0x30]
    492e:	mov    r12,QWORD PTR [rsp+0x38]
    4933:	mov    r13,QWORD PTR [rsp+0x40]
    4938:	mov    r14,QWORD PTR [rsp+0x48]
    493d:	mov    r15,QWORD PTR [rsp+0x50]
    4942:	add    rsp,0x60
    4946:	mov    rsp,rbp
    4949:	pop    rbp
    494a:	ret
    494b:	mov    eax,0xa
    4950:	mov    rbx,QWORD PTR [rsp+0x30]
    4955:	mov    r12,QWORD PTR [rsp+0x38]
    495a:	mov    r13,QWORD PTR [rsp+0x40]
    495f:	mov    r14,QWORD PTR [rsp+0x48]
    4964:	mov    r15,QWORD PTR [rsp+0x50]
    4969:	add    rsp,0x60
    496d:	mov    rsp,rbp
    4970:	pop    rbp
    4971:	ret
    4972:	add    BYTE PTR [rax],al
    4974:	add    BYTE PTR [rax],al
    4976:	add    BYTE PTR [rax],al
    4978:	(bad)
    4979:	add    BYTE PTR [rax],al
    497b:	add    BYTE PTR [rax],al
    497d:	add    BYTE PTR [rax],al
	...

0000000000004980 <botlish_entry_47: ht_set<mutarray, str, str>>:
    4980:	push   rbp
    4981:	mov    rbp,rsp
    4984:	mov    rsi,QWORD PTR [rdx]
    4987:	mov    r8,QWORD PTR [rdx+0x8]
    498b:	mov    rcx,QWORD PTR [rdx+0x10]
    498f:	mov    rdx,r8
    4992:	call   4997 <botlish_entry_47+0x17>
			4993: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4997:	mov    rsp,rbp
    499a:	pop    rbp
    499b:	ret

000000000000499c <botlish_fn_48: row_new<bool, int>>:
    499c:	push   rbp
    499d:	mov    rbp,rsp
    49a0:	sub    rsp,0x10
    49a4:	mov    QWORD PTR [rsp],rdx
    49a8:	mov    r8,rdx
    49ab:	cmp    rsi,0x6
    49af:	je     49cc <botlish_fn_48+0x30>
    49b5:	call   49ba <botlish_fn_48+0x1e>
			49b6: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    49ba:	test   rax,rax
    49bd:	je     49dd <botlish_fn_48+0x41>
    49c3:	add    rsp,0x10
    49c7:	mov    rsp,rbp
    49ca:	pop    rbp
    49cb:	ret
    49cc:	mov    rsi,r8
    49cf:	call   49d4 <botlish_fn_48+0x38>
			49d0: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    49d4:	test   rax,rax
    49d7:	jne    49e9 <botlish_fn_48+0x4d>
    49dd:	xor    rax,rax
    49e0:	add    rsp,0x10
    49e4:	mov    rsp,rbp
    49e7:	pop    rbp
    49e8:	ret
    49e9:	add    rsp,0x10
    49ed:	mov    rsp,rbp
    49f0:	pop    rbp
    49f1:	ret

00000000000049f2 <botlish_entry_48: row_new<bool, int>>:
    49f2:	push   rbp
    49f3:	mov    rbp,rsp
    49f6:	mov    rsi,QWORD PTR [rdx]
    49f9:	mov    rdx,QWORD PTR [rdx+0x8]
    49fd:	call   4a02 <botlish_entry_48+0x10>
			49fe: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4a02:	mov    rsp,rbp
    4a05:	pop    rbp
    4a06:	ret

0000000000004a07 <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4a07:	push   rbp
    4a08:	mov    rbp,rsp
    4a0b:	sub    rsp,0x70
    4a0f:	mov    QWORD PTR [rsp+0x40],rbx
    4a14:	mov    QWORD PTR [rsp+0x48],r12
    4a19:	mov    QWORD PTR [rsp+0x50],r13
    4a1e:	mov    QWORD PTR [rsp+0x58],r14
    4a23:	mov    QWORD PTR [rsp+0x60],r15
    4a28:	mov    QWORD PTR [rsp+0x28],rdi
    4a2d:	mov    QWORD PTR [rsp],rsi
    4a31:	mov    r14,rsi
    4a34:	mov    QWORD PTR [rsp+0x8],rdx
    4a39:	mov    QWORD PTR [rsp+0x10],rcx
    4a3e:	mov    r13,rcx
    4a41:	sar    r8,1
    4a44:	mov    rbx,r8
    4a47:	mov    r15,r9
    4a4a:	cmp    rbx,r15
    4a4d:	jge    4b58 <botlish_fn_49+0x151>
    4a53:	mov    r12,rdx
    4a56:	mov    rdx,QWORD PTR [r12+0x8]
    4a5b:	mov    rcx,rbx
    4a5e:	shl    rcx,1
    4a61:	or     rcx,0x1
    4a65:	sar    rcx,1
    4a68:	cmp    rcx,rdx
    4a6b:	jb     4a99 <botlish_fn_49+0x92>
    4a71:	mov    rdx,rbx
    4a74:	shl    rdx,1
    4a77:	or     rdx,0x1
    4a7b:	mov    rsi,r12
    4a7e:	mov    rdi,QWORD PTR [rsp+0x28]
    4a83:	call   4a88 <botlish_fn_49+0x81>
			4a84: R_X86_64_PLT32	rt_list_get-0x4
    4a88:	test   rax,rax
    4a8b:	je     4b16 <botlish_fn_49+0x10f>
    4a91:	mov    rdx,rax
    4a94:	jmp    4aa2 <botlish_fn_49+0x9b>
    4a99:	mov    rax,QWORD PTR [r12+0x10]
    4a9e:	mov    rdx,QWORD PTR [rax+rcx*8]
    4aa2:	mov    QWORD PTR [rsp+0x18],rdx
    4aa7:	mov    QWORD PTR [rsp+0x30],rdx
    4aac:	mov    rax,QWORD PTR [r13+0x8]
    4ab0:	mov    rcx,rbx
    4ab3:	shl    rcx,1
    4ab6:	or     rcx,0x1
    4aba:	sar    rcx,1
    4abd:	cmp    rcx,rax
    4ac0:	jb     4aee <botlish_fn_49+0xe7>
    4ac6:	mov    rdx,rbx
    4ac9:	shl    rdx,1
    4acc:	or     rdx,0x1
    4ad0:	mov    rsi,r13
    4ad3:	mov    rdi,QWORD PTR [rsp+0x28]
    4ad8:	call   4add <botlish_fn_49+0xd6>
			4ad9: R_X86_64_PLT32	rt_list_get-0x4
    4add:	test   rax,rax
    4ae0:	je     4b16 <botlish_fn_49+0x10f>
    4ae6:	mov    rcx,rax
    4ae9:	jmp    4af6 <botlish_fn_49+0xef>
    4aee:	mov    rax,QWORD PTR [r13+0x10]
    4af2:	mov    rcx,QWORD PTR [rax+rcx*8]
    4af6:	mov    QWORD PTR [rsp+0x20],rcx
    4afb:	mov    rdx,QWORD PTR [rsp+0x30]
    4b00:	mov    rsi,r14
    4b03:	mov    rdi,QWORD PTR [rsp+0x28]
    4b08:	call   4b0d <botlish_fn_49+0x106>
			4b09: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4b0d:	test   rax,rax
    4b10:	jne    4b3b <botlish_fn_49+0x134>
    4b16:	xor    rax,rax
    4b19:	mov    rbx,QWORD PTR [rsp+0x40]
    4b1e:	mov    r12,QWORD PTR [rsp+0x48]
    4b23:	mov    r13,QWORD PTR [rsp+0x50]
    4b28:	mov    r14,QWORD PTR [rsp+0x58]
    4b2d:	mov    r15,QWORD PTR [rsp+0x60]
    4b32:	add    rsp,0x70
    4b36:	mov    rsp,rbp
    4b39:	pop    rbp
    4b3a:	ret
    4b3b:	mov    QWORD PTR [rsp],r14
    4b3f:	mov    QWORD PTR [rsp+0x8],r12
    4b44:	mov    QWORD PTR [rsp+0x10],r13
    4b49:	add    rbx,0x1
    4b50:	mov    rdx,r12
    4b53:	jmp    4a4a <botlish_fn_49+0x43>
    4b58:	mov    rax,r14
    4b5b:	mov    rbx,QWORD PTR [rsp+0x40]
    4b60:	mov    r12,QWORD PTR [rsp+0x48]
    4b65:	mov    r13,QWORD PTR [rsp+0x50]
    4b6a:	mov    r14,QWORD PTR [rsp+0x58]
    4b6f:	mov    r15,QWORD PTR [rsp+0x60]
    4b74:	add    rsp,0x70
    4b78:	mov    rsp,rbp
    4b7b:	pop    rbp
    4b7c:	ret

0000000000004b7d <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4b7d:	push   rbp
    4b7e:	mov    rbp,rsp
    4b81:	mov    rsi,QWORD PTR [rdx]
    4b84:	mov    r10,QWORD PTR [rdx+0x8]
    4b88:	mov    rcx,QWORD PTR [rdx+0x10]
    4b8c:	mov    r8,QWORD PTR [rdx+0x18]
    4b90:	mov    r9,QWORD PTR [rdx+0x20]
    4b94:	sar    r9,1
    4b97:	mov    rdx,r10
    4b9a:	call   4b9f <botlish_entry_49+0x22>
			4b9b: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4b9f:	mov    rsp,rbp
    4ba2:	pop    rbp
    4ba3:	ret

0000000000004ba4 <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4ba4:	push   rbp
    4ba5:	mov    rbp,rsp
    4ba8:	sub    rsp,0x50
    4bac:	mov    QWORD PTR [rsp+0x20],rbx
    4bb1:	mov    QWORD PTR [rsp+0x28],r12
    4bb6:	mov    QWORD PTR [rsp+0x30],r13
    4bbb:	mov    QWORD PTR [rsp+0x38],r14
    4bc0:	mov    QWORD PTR [rsp+0x40],r15
    4bc5:	mov    r12,rdi
    4bc8:	mov    QWORD PTR [rsp],rsi
    4bcc:	mov    r15,rsi
    4bcf:	mov    QWORD PTR [rsp+0x8],rdx
    4bd4:	mov    QWORD PTR [rsp+0x10],rcx
    4bd9:	mov    r13,rcx
    4bdc:	mov    QWORD PTR [rsp+0x18],r8
    4be1:	mov    rsi,r8
    4be4:	mov    rdi,r12
    4be7:	call   4bec <botlish_fn_50+0x48>
			4be8: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4bec:	test   rax,rax
    4bef:	je     4c39 <botlish_fn_50+0x95>
    4bf5:	mov    QWORD PTR [rsp+0x8],rax
    4bfa:	mov    r14,rax
    4bfd:	mov    ebx,0x1
    4c02:	mov    QWORD PTR [rsp+0x18],0x1
    4c0b:	mov    rsi,r13
    4c0e:	mov    rdi,r12
    4c11:	call   4c16 <botlish_fn_50+0x72>
			4c12: R_X86_64_PLT32	rt_list_len-0x4
    4c16:	mov    r9,rax
    4c19:	sar    r9,1
    4c1c:	mov    rcx,r13
    4c1f:	mov    rdx,r15
    4c22:	mov    rsi,r14
    4c25:	mov    rdi,r12
    4c28:	mov    r8,rbx
    4c2b:	call   4c30 <botlish_fn_50+0x8c>
			4c2c: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4c30:	test   rax,rax
    4c33:	jne    4c5e <botlish_fn_50+0xba>
    4c39:	xor    rax,rax
    4c3c:	mov    rbx,QWORD PTR [rsp+0x20]
    4c41:	mov    r12,QWORD PTR [rsp+0x28]
    4c46:	mov    r13,QWORD PTR [rsp+0x30]
    4c4b:	mov    r14,QWORD PTR [rsp+0x38]
    4c50:	mov    r15,QWORD PTR [rsp+0x40]
    4c55:	add    rsp,0x50
    4c59:	mov    rsp,rbp
    4c5c:	pop    rbp
    4c5d:	ret
    4c5e:	mov    rbx,QWORD PTR [rsp+0x20]
    4c63:	mov    r12,QWORD PTR [rsp+0x28]
    4c68:	mov    r13,QWORD PTR [rsp+0x30]
    4c6d:	mov    r14,QWORD PTR [rsp+0x38]
    4c72:	mov    r15,QWORD PTR [rsp+0x40]
    4c77:	add    rsp,0x50
    4c7b:	mov    rsp,rbp
    4c7e:	pop    rbp
    4c7f:	ret

0000000000004c80 <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4c80:	push   rbp
    4c81:	mov    rbp,rsp
    4c84:	mov    rsi,QWORD PTR [rdx]
    4c87:	mov    r9,QWORD PTR [rdx+0x8]
    4c8b:	mov    rcx,QWORD PTR [rdx+0x10]
    4c8f:	mov    r8,QWORD PTR [rdx+0x18]
    4c93:	mov    rdx,r9
    4c96:	call   4c9b <botlish_entry_50+0x1b>
			4c97: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4c9b:	mov    rsp,rbp
    4c9e:	pop    rbp
    4c9f:	ret

0000000000004ca0 <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4ca0:	push   rbp
    4ca1:	mov    rbp,rsp
    4ca4:	sub    rsp,0x90
    4cab:	mov    QWORD PTR [rsp+0x60],rbx
    4cb0:	mov    QWORD PTR [rsp+0x68],r12
    4cb5:	mov    QWORD PTR [rsp+0x70],r13
    4cba:	mov    QWORD PTR [rsp+0x78],r14
    4cbf:	mov    QWORD PTR [rsp+0x80],r15
    4cc7:	mov    r13,r8
    4cca:	mov    QWORD PTR [rsp+0x38],rdi
    4ccf:	mov    rdi,QWORD PTR [rbp+0x10]
    4cd3:	mov    r15,QWORD PTR [rbp+0x18]
    4cd7:	mov    QWORD PTR [rsp+0x28],0x0
    4ce0:	mov    QWORD PTR [rsp+0x30],0x0
    4ce9:	mov    QWORD PTR [rsp],rsi
    4ced:	mov    QWORD PTR [rsp+0x8],rcx
    4cf2:	mov    r14,rcx
    4cf5:	mov    QWORD PTR [rsp+0x10],r9
    4cfa:	mov    QWORD PTR [rsp+0x18],rdi
    4cff:	mov    QWORD PTR [rsp+0x20],r15
    4d04:	sar    rdx,1
    4d07:	mov    r12,rdx
    4d0a:	mov    rbx,rsi
    4d0d:	mov    QWORD PTR [rsp+0x40],r9
    4d12:	mov    QWORD PTR [rsp+0x48],rdi
    4d17:	mov    rsi,rbx
    4d1a:	mov    rdi,QWORD PTR [rsp+0x38]
    4d1f:	call   4d24 <botlish_fn_51+0x84>
			4d20: R_X86_64_PLT32	rt_list_len-0x4
    4d24:	sar    rax,1
    4d27:	cmp    r12,rax
    4d2a:	jge    4e55 <botlish_fn_51+0x1b5>
    4d30:	mov    rax,r13
    4d33:	or     rax,0x1
    4d37:	mov    QWORD PTR [rsp+0x28],rax
    4d3c:	mov    rcx,QWORD PTR [rbx+0x8]
    4d40:	mov    rax,r12
    4d43:	shl    rax,1
    4d46:	or     rax,0x1
    4d4a:	sar    rax,1
    4d4d:	cmp    rax,rcx
    4d50:	jb     4d7e <botlish_fn_51+0xde>
    4d56:	mov    rdx,r12
    4d59:	shl    rdx,1
    4d5c:	or     rdx,0x1
    4d60:	mov    rsi,rbx
    4d63:	mov    rdi,QWORD PTR [rsp+0x38]
    4d68:	call   4d6d <botlish_fn_51+0xcd>
			4d69: R_X86_64_PLT32	rt_list_get-0x4
    4d6d:	test   rax,rax
    4d70:	je     4e72 <botlish_fn_51+0x1d2>
    4d76:	mov    rcx,rax
    4d79:	jmp    4d86 <botlish_fn_51+0xe6>
    4d7e:	mov    rcx,QWORD PTR [rbx+0x10]
    4d82:	mov    rcx,QWORD PTR [rcx+rax*8]
    4d86:	mov    QWORD PTR [rsp+0x30],rcx
    4d8b:	mov    rdx,r13
    4d8e:	or     rdx,0x1
    4d92:	mov    rsi,r14
    4d95:	mov    rdi,QWORD PTR [rsp+0x38]
    4d9a:	mov    r8,r15
    4d9d:	call   4da2 <botlish_fn_51+0x102>
			4d9e: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4da2:	test   rax,rax
    4da5:	je     4e72 <botlish_fn_51+0x1d2>
    4dab:	mov    QWORD PTR [rsp+0x28],rax
    4db0:	mov    rcx,rax
    4db3:	mov    rsi,QWORD PTR [rsp+0x40]
    4db8:	mov    rdx,QWORD PTR [rsp+0x48]
    4dbd:	mov    rdi,QWORD PTR [rsp+0x38]
    4dc2:	call   4dc7 <botlish_fn_51+0x127>
			4dc3: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4dc7:	test   rax,rax
    4dca:	je     4e72 <botlish_fn_51+0x1d2>
    4dd0:	mov    QWORD PTR [rsp+0x10],rax
    4dd5:	mov    QWORD PTR [rsp+0x50],rax
    4dda:	mov    QWORD PTR [rsp+0x28],0x3
    4de3:	mov    rsi,QWORD PTR [rsp+0x48]
    4de8:	test   rsi,0x1
    4def:	je     4e0e <botlish_fn_51+0x16e>
    4df5:	mov    rsi,QWORD PTR [rsp+0x48]
    4dfa:	mov    rax,rsi
    4dfd:	add    rax,0x2
    4e01:	seto   r10b
    4e05:	test   r10b,r10b
    4e08:	je     4e22 <botlish_fn_51+0x182>
    4e0e:	mov    edx,0x3
    4e13:	mov    rsi,QWORD PTR [rsp+0x48]
    4e18:	mov    rdi,QWORD PTR [rsp+0x38]
    4e1d:	call   4e22 <botlish_fn_51+0x182>
			4e1e: R_X86_64_PLT32	rt_int_add-0x4
    4e22:	mov    QWORD PTR [rsp],rbx
    4e26:	mov    QWORD PTR [rsp+0x8],r14
    4e2b:	mov    rcx,QWORD PTR [rsp+0x50]
    4e30:	mov    QWORD PTR [rsp+0x10],rcx
    4e35:	mov    QWORD PTR [rsp+0x18],rax
    4e3a:	mov    QWORD PTR [rsp+0x20],r15
    4e3f:	add    r12,0x1
    4e46:	mov    QWORD PTR [rsp+0x40],rcx
    4e4b:	mov    QWORD PTR [rsp+0x48],rax
    4e50:	jmp    4d17 <botlish_fn_51+0x77>
    4e55:	mov    rdx,QWORD PTR [rsp+0x48]
    4e5a:	mov    rsi,QWORD PTR [rsp+0x40]
    4e5f:	mov    rdi,QWORD PTR [rsp+0x38]
    4e64:	call   4e69 <botlish_fn_51+0x1c9>
			4e65: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4e69:	test   rax,rax
    4e6c:	jne    4e9d <botlish_fn_51+0x1fd>
    4e72:	xor    rax,rax
    4e75:	mov    rbx,QWORD PTR [rsp+0x60]
    4e7a:	mov    r12,QWORD PTR [rsp+0x68]
    4e7f:	mov    r13,QWORD PTR [rsp+0x70]
    4e84:	mov    r14,QWORD PTR [rsp+0x78]
    4e89:	mov    r15,QWORD PTR [rsp+0x80]
    4e91:	add    rsp,0x90
    4e98:	mov    rsp,rbp
    4e9b:	pop    rbp
    4e9c:	ret
    4e9d:	mov    rbx,QWORD PTR [rsp+0x60]
    4ea2:	mov    r12,QWORD PTR [rsp+0x68]
    4ea7:	mov    r13,QWORD PTR [rsp+0x70]
    4eac:	mov    r14,QWORD PTR [rsp+0x78]
    4eb1:	mov    r15,QWORD PTR [rsp+0x80]
    4eb9:	add    rsp,0x90
    4ec0:	mov    rsp,rbp
    4ec3:	pop    rbp
    4ec4:	ret

0000000000004ec5 <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4ec5:	push   rbp
    4ec6:	mov    rbp,rsp
    4ec9:	sub    rsp,0x10
    4ecd:	mov    rsi,QWORD PTR [rdx]
    4ed0:	mov    r10,QWORD PTR [rdx+0x8]
    4ed4:	mov    rcx,QWORD PTR [rdx+0x10]
    4ed8:	mov    r8,QWORD PTR [rdx+0x18]
    4edc:	mov    r9,QWORD PTR [rdx+0x20]
    4ee0:	mov    r11,QWORD PTR [rdx+0x28]
    4ee4:	mov    rax,QWORD PTR [rdx+0x30]
    4ee8:	mov    QWORD PTR [rsp],r11
    4eec:	mov    QWORD PTR [rsp+0x8],rax
    4ef1:	mov    rdx,r10
    4ef4:	call   4ef9 <botlish_entry_51+0x34>
			4ef5: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4ef9:	add    rsp,0x10
    4efd:	mov    rsp,rbp
    4f00:	pop    rbp
    4f01:	ret

0000000000004f02 <botlish_fn_52: csv_records_generic<str, bool>>:
    4f02:	push   rbp
    4f03:	mov    rbp,rsp
    4f06:	sub    rsp,0x80
    4f0d:	mov    QWORD PTR [rsp+0x50],rbx
    4f12:	mov    QWORD PTR [rsp+0x58],r12
    4f17:	mov    QWORD PTR [rsp+0x60],r13
    4f1c:	mov    QWORD PTR [rsp+0x68],r14
    4f21:	mov    QWORD PTR [rsp+0x70],r15
    4f26:	mov    r12,rdi
    4f29:	mov    QWORD PTR [rsp+0x20],0x0
    4f32:	mov    QWORD PTR [rsp+0x28],0x0
    4f3b:	mov    QWORD PTR [rsp+0x30],0x0
    4f44:	mov    QWORD PTR [rsp+0x38],0x0
    4f4d:	mov    QWORD PTR [rsp+0x40],0x0
    4f56:	mov    QWORD PTR [rsp+0x10],rsi
    4f5b:	mov    QWORD PTR [rsp+0x18],rdx
    4f60:	mov    r13,rdx
    4f63:	mov    rdi,r12
    4f66:	call   4f6b <botlish_fn_52+0x69>
			4f67: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4f6b:	mov    rcx,rax
    4f6e:	mov    r15,rax
    4f71:	test   rax,rcx
    4f74:	je     50ec <botlish_fn_52+0x1ea>
    4f7a:	mov    rax,r15
    4f7d:	mov    QWORD PTR [rsp+0x10],rax
    4f82:	mov    rsi,r15
    4f85:	mov    rdi,r12
    4f88:	call   4f8d <botlish_fn_52+0x8b>
			4f89: R_X86_64_PLT32	rt_list_len-0x4
    4f8d:	sar    rax,1
    4f90:	cmp    rax,0x1
    4f94:	jle    50d5 <botlish_fn_52+0x1d3>
    4f9a:	mov    rax,r15
    4f9d:	mov    rax,QWORD PTR [rax+0x8]
    4fa1:	test   rax,rax
    4fa4:	jne    4fcb <botlish_fn_52+0xc9>
    4faa:	mov    edx,0x1
    4faf:	mov    rsi,r15
    4fb2:	mov    rdi,r12
    4fb5:	call   4fba <botlish_fn_52+0xb8>
			4fb6: R_X86_64_PLT32	rt_list_get-0x4
    4fba:	test   rax,rax
    4fbd:	je     50ec <botlish_fn_52+0x1ea>
    4fc3:	mov    rbx,rax
    4fc6:	jmp    4fd2 <botlish_fn_52+0xd0>
    4fcb:	mov    rax,QWORD PTR [r15+0x10]
    4fcf:	mov    rbx,QWORD PTR [rax]
    4fd2:	mov    QWORD PTR [rsp+0x20],rbx
    4fd7:	mov    rsi,rbx
    4fda:	mov    rdi,r12
    4fdd:	call   4fe2 <botlish_fn_52+0xe0>
			4fde: R_X86_64_PLT32	rt_list_len-0x4
    4fe2:	mov    r14,rax
    4fe5:	mov    QWORD PTR [rsp+0x48],rbx
    4fea:	mov    QWORD PTR [rsp+0x28],r14
    4fef:	mov    rax,QWORD PTR [r15+0x8]
    4ff3:	cmp    rax,0x1
    4ff7:	ja     501e <botlish_fn_52+0x11c>
    4ffd:	mov    edx,0x3
    5002:	mov    rsi,r15
    5005:	mov    rdi,r12
    5008:	call   500d <botlish_fn_52+0x10b>
			5009: R_X86_64_PLT32	rt_list_get-0x4
    500d:	test   rax,rax
    5010:	je     50ec <botlish_fn_52+0x1ea>
    5016:	mov    rcx,rax
    5019:	jmp    5026 <botlish_fn_52+0x124>
    501e:	mov    rax,QWORD PTR [r15+0x10]
    5022:	mov    rcx,QWORD PTR [rax+0x8]
    5026:	mov    QWORD PTR [rsp+0x30],rcx
    502b:	mov    rbx,r13
    502e:	mov    rdx,r14
    5031:	mov    rsi,QWORD PTR [rsp+0x48]
    5036:	mov    rdi,r12
    5039:	mov    r8,rbx
    503c:	call   5041 <botlish_fn_52+0x13f>
			503d: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    5041:	mov    r13,r14
    5044:	test   rax,rax
    5047:	je     50ec <botlish_fn_52+0x1ea>
    504d:	mov    QWORD PTR [rsp+0x30],rax
    5052:	mov    rsi,rax
    5055:	mov    QWORD PTR [rsp+0x38],0x5
    505e:	mov    rdi,r12
    5061:	call   5066 <botlish_fn_52+0x164>
			5062: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    5066:	test   rax,rax
    5069:	je     50ec <botlish_fn_52+0x1ea>
    506f:	mov    QWORD PTR [rsp+0x30],rax
    5074:	mov    r9,rax
    5077:	mov    r10d,0x3
    507d:	mov    QWORD PTR [rsp+0x40],0x3
    5086:	mov    edx,0x5
    508b:	mov    QWORD PTR [rsp],r10
    508f:	mov    QWORD PTR [rsp+0x8],rbx
    5094:	mov    rcx,QWORD PTR [rsp+0x48]
    5099:	mov    rsi,r15
    509c:	mov    rdi,r12
    509f:	mov    r8,r13
    50a2:	call   50a7 <botlish_fn_52+0x1a5>
			50a3: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    50a7:	test   rax,rax
    50aa:	je     50ec <botlish_fn_52+0x1ea>
    50b0:	mov    rbx,QWORD PTR [rsp+0x50]
    50b5:	mov    r12,QWORD PTR [rsp+0x58]
    50ba:	mov    r13,QWORD PTR [rsp+0x60]
    50bf:	mov    r14,QWORD PTR [rsp+0x68]
    50c4:	mov    r15,QWORD PTR [rsp+0x70]
    50c9:	add    rsp,0x80
    50d0:	mov    rsp,rbp
    50d3:	pop    rbp
    50d4:	ret
    50d5:	xor    rdx,rdx
    50d8:	mov    rdi,r12
    50db:	mov    rsi,rdx
    50de:	call   50e3 <botlish_fn_52+0x1e1>
			50df: R_X86_64_PLT32	rt_list_new-0x4
    50e3:	test   rax,rax
    50e6:	jne    5114 <botlish_fn_52+0x212>
    50ec:	xor    rax,rax
    50ef:	mov    rbx,QWORD PTR [rsp+0x50]
    50f4:	mov    r12,QWORD PTR [rsp+0x58]
    50f9:	mov    r13,QWORD PTR [rsp+0x60]
    50fe:	mov    r14,QWORD PTR [rsp+0x68]
    5103:	mov    r15,QWORD PTR [rsp+0x70]
    5108:	add    rsp,0x80
    510f:	mov    rsp,rbp
    5112:	pop    rbp
    5113:	ret
    5114:	mov    rbx,QWORD PTR [rsp+0x50]
    5119:	mov    r12,QWORD PTR [rsp+0x58]
    511e:	mov    r13,QWORD PTR [rsp+0x60]
    5123:	mov    r14,QWORD PTR [rsp+0x68]
    5128:	mov    r15,QWORD PTR [rsp+0x70]
    512d:	add    rsp,0x80
    5134:	mov    rsp,rbp
    5137:	pop    rbp
    5138:	ret

0000000000005139 <botlish_entry_52: csv_records_generic<str, bool>>:
    5139:	push   rbp
    513a:	mov    rbp,rsp
    513d:	mov    rsi,QWORD PTR [rdx]
    5140:	mov    rdx,QWORD PTR [rdx+0x8]
    5144:	call   5149 <botlish_entry_52+0x10>
			5145: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5149:	mov    rsp,rbp
    514c:	pop    rbp
    514d:	ret

000000000000514e <botlish_fn_53: csv_records<str>>:
    514e:	push   rbp
    514f:	mov    rbp,rsp
    5152:	sub    rsp,0x10
    5156:	mov    QWORD PTR [rsp],rsi
    515a:	mov    edx,0x2
    515f:	mov    QWORD PTR [rsp+0x8],0x2
    5168:	call   516d <botlish_fn_53+0x1f>
			5169: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    516d:	test   rax,rax
    5170:	jne    5182 <botlish_fn_53+0x34>
    5176:	xor    rax,rax
    5179:	add    rsp,0x10
    517d:	mov    rsp,rbp
    5180:	pop    rbp
    5181:	ret
    5182:	add    rsp,0x10
    5186:	mov    rsp,rbp
    5189:	pop    rbp
    518a:	ret

000000000000518b <botlish_entry_53: csv_records<str>>:
    518b:	push   rbp
    518c:	mov    rbp,rsp
    518f:	mov    rsi,QWORD PTR [rdx]
    5192:	call   5197 <botlish_entry_53+0xc>
			5193: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    5197:	mov    rsp,rbp
    519a:	pop    rbp
    519b:	ret

000000000000519c <botlish_fn_54: csv_records_presized<str>>:
    519c:	push   rbp
    519d:	mov    rbp,rsp
    51a0:	sub    rsp,0x10
    51a4:	mov    QWORD PTR [rsp],rsi
    51a8:	mov    edx,0x6
    51ad:	mov    QWORD PTR [rsp+0x8],0x6
    51b6:	call   51bb <botlish_fn_54+0x1f>
			51b7: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    51bb:	test   rax,rax
    51be:	jne    51d0 <botlish_fn_54+0x34>
    51c4:	xor    rax,rax
    51c7:	add    rsp,0x10
    51cb:	mov    rsp,rbp
    51ce:	pop    rbp
    51cf:	ret
    51d0:	add    rsp,0x10
    51d4:	mov    rsp,rbp
    51d7:	pop    rbp
    51d8:	ret

00000000000051d9 <botlish_entry_54: csv_records_presized<str>>:
    51d9:	push   rbp
    51da:	mov    rbp,rsp
    51dd:	mov    rsi,QWORD PTR [rdx]
    51e0:	call   51e5 <botlish_entry_54+0xc>
			51e1: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    51e5:	mov    rsp,rbp
    51e8:	pop    rbp
    51e9:	ret
    51ea:	add    BYTE PTR [rax],al
    51ec:	add    BYTE PTR [rax],al
	...

00000000000051f0 <botlish_fn_55: sample_checks<generic>>:
    51f0:	push   rbp
    51f1:	mov    rbp,rsp
    51f4:	sub    rsp,0xc0
    51fb:	mov    QWORD PTR [rsp+0x90],rbx
    5203:	mov    QWORD PTR [rsp+0x98],r12
    520b:	mov    QWORD PTR [rsp+0xa0],r13
    5213:	mov    QWORD PTR [rsp+0xa8],r14
    521b:	mov    QWORD PTR [rsp+0xb0],r15
    5223:	mov    QWORD PTR [rsp+0x8],0x0
    522c:	mov    QWORD PTR [rsp+0x10],0x0
    5235:	mov    QWORD PTR [rsp+0x18],0x0
    523e:	mov    QWORD PTR [rsp+0x20],0x0
    5247:	mov    QWORD PTR [rsp+0x28],0x0
    5250:	mov    QWORD PTR [rsp+0x30],0x0
    5259:	mov    QWORD PTR [rsp+0x38],0x0
    5262:	mov    rax,QWORD PTR [rdi+0x10]
    5266:	mov    r13,rdi
    5269:	mov    rsi,QWORD PTR [rax+0x50]
    526d:	mov    QWORD PTR [rsp],rsi
    5271:	call   5276 <botlish_fn_55+0x86>
			5272: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    5276:	mov    rsi,rax
    5279:	mov    r12,rax
    527c:	test   rax,rsi
    527f:	je     5604 <botlish_fn_55+0x414>
    5285:	mov    rax,r12
    5288:	mov    QWORD PTR [rsp],rax
    528c:	mov    rdi,r13
    528f:	mov    rax,QWORD PTR [rdi+0x10]
    5293:	mov    rsi,QWORD PTR [rax+0x50]
    5297:	mov    QWORD PTR [rsp+0x8],rsi
    529c:	call   52a1 <botlish_fn_55+0xb1>
			529d: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    52a1:	mov    rbx,rax
    52a4:	test   rbx,rbx
    52a7:	je     5604 <botlish_fn_55+0x414>
    52ad:	mov    rax,r12
    52b0:	mov    rax,QWORD PTR [rax+0x8]
    52b4:	test   rax,rax
    52b7:	jne    52de <botlish_fn_55+0xee>
    52bd:	mov    edx,0x1
    52c2:	mov    rsi,r12
    52c5:	mov    rdi,r13
    52c8:	call   52cd <botlish_fn_55+0xdd>
			52c9: R_X86_64_PLT32	rt_list_get-0x4
    52cd:	test   rax,rax
    52d0:	je     5604 <botlish_fn_55+0x414>
    52d6:	mov    rsi,rax
    52d9:	jmp    52e6 <botlish_fn_55+0xf6>
    52de:	mov    rax,QWORD PTR [r12+0x10]
    52e3:	mov    rsi,QWORD PTR [rax]
    52e6:	mov    QWORD PTR [rsp+0x8],rsi
    52eb:	mov    r15,rsi
    52ee:	mov    rax,QWORD PTR [r12+0x8]
    52f3:	cmp    rax,0x1
    52f7:	ja     531e <botlish_fn_55+0x12e>
    52fd:	mov    edx,0x3
    5302:	mov    rsi,r12
    5305:	mov    rdi,r13
    5308:	call   530d <botlish_fn_55+0x11d>
			5309: R_X86_64_PLT32	rt_list_get-0x4
    530d:	test   rax,rax
    5310:	je     5604 <botlish_fn_55+0x414>
    5316:	mov    rsi,rax
    5319:	jmp    5327 <botlish_fn_55+0x137>
    531e:	mov    rax,QWORD PTR [r12+0x10]
    5323:	mov    rsi,QWORD PTR [rax+0x8]
    5327:	mov    QWORD PTR [rsp+0x10],rsi
    532c:	mov    r14,rsi
    532f:	mov    rax,QWORD PTR [rbx+0x8]
    5333:	mov    rsi,rbx
    5336:	test   rax,rax
    5339:	jne    535d <botlish_fn_55+0x16d>
    533f:	mov    edx,0x1
    5344:	mov    rdi,r13
    5347:	call   534c <botlish_fn_55+0x15c>
			5348: R_X86_64_PLT32	rt_list_get-0x4
    534c:	test   rax,rax
    534f:	je     5604 <botlish_fn_55+0x414>
    5355:	mov    rsi,rax
    5358:	jmp    5364 <botlish_fn_55+0x174>
    535d:	mov    rax,QWORD PTR [rsi+0x10]
    5361:	mov    rsi,QWORD PTR [rax]
    5364:	mov    QWORD PTR [rsp+0x18],rsi
    5369:	mov    rdi,r13
    536c:	mov    QWORD PTR [rsp+0x78],rsi
    5371:	mov    rax,QWORD PTR [rdi+0x10]
    5375:	mov    rdx,QWORD PTR [rax+0x58]
    5379:	mov    QWORD PTR [rsp+0x20],rdx
    537e:	mov    rsi,r15
    5381:	call   5386 <botlish_fn_55+0x196>
			5382: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5386:	test   rax,rax
    5389:	je     5604 <botlish_fn_55+0x414>
    538f:	mov    QWORD PTR [rsp+0x20],rax
    5394:	mov    rbx,rax
    5397:	mov    rdi,r13
    539a:	mov    rax,QWORD PTR [rdi+0x10]
    539e:	mov    rdx,QWORD PTR [rax+0x58]
    53a2:	mov    QWORD PTR [rsp+0x28],rdx
    53a7:	mov    rsi,QWORD PTR [rsp+0x78]
    53ac:	call   53b1 <botlish_fn_55+0x1c1>
			53ad: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    53b1:	test   rax,rax
    53b4:	je     5604 <botlish_fn_55+0x414>
    53ba:	mov    rcx,rbx
    53bd:	mov    rdx,rcx
    53c0:	and    rdx,rax
    53c3:	test   rdx,0x1
    53ca:	jne    53ec <botlish_fn_55+0x1fc>
    53d0:	mov    rdx,rax
    53d3:	mov    rsi,rbx
    53d6:	mov    rdi,r13
    53d9:	call   53de <botlish_fn_55+0x1ee>
			53da: R_X86_64_PLT32	rt_value_eq-0x4
    53de:	test   rax,rax
    53e1:	je     5604 <botlish_fn_55+0x414>
    53e7:	jmp    5402 <botlish_fn_55+0x212>
    53ec:	mov    rdx,rax
    53ef:	mov    rsi,rbx
    53f2:	mov    eax,0x2
    53f7:	cmp    rsi,rdx
    53fa:	cmove  rax,QWORD PTR [rip+0x26e]        # 5670 <botlish_fn_55+0x480>
    5402:	mov    ebx,0x6
    5407:	cmp    rax,0x6
    540b:	je     5426 <botlish_fn_55+0x236>
    5411:	mov    ebx,0x2
    5416:	mov    QWORD PTR [rsp],0x2
    541e:	mov    rsi,r12
    5421:	jmp    54c5 <botlish_fn_55+0x2d5>
    5426:	mov    rsi,r15
    5429:	mov    rdi,r13
    542c:	call   5431 <botlish_fn_55+0x241>
			542d: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5431:	test   rax,rax
    5434:	mov    QWORD PTR [rsp+0x88],rax
    543c:	je     5604 <botlish_fn_55+0x414>
    5442:	mov    rsi,QWORD PTR [rsp+0x78]
    5447:	mov    rdi,r13
    544a:	call   544f <botlish_fn_55+0x25f>
			544b: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    544f:	test   rax,rax
    5452:	je     5604 <botlish_fn_55+0x414>
    5458:	mov    rcx,QWORD PTR [rsp+0x88]
    5460:	mov    rdx,rcx
    5463:	and    rdx,rax
    5466:	test   rdx,0x1
    546d:	jne    5494 <botlish_fn_55+0x2a4>
    5473:	mov    rdx,rax
    5476:	mov    rsi,QWORD PTR [rsp+0x88]
    547e:	mov    rdi,r13
    5481:	call   5486 <botlish_fn_55+0x296>
			5482: R_X86_64_PLT32	rt_value_eq-0x4
    5486:	test   rax,rax
    5489:	je     5604 <botlish_fn_55+0x414>
    548f:	jmp    54af <botlish_fn_55+0x2bf>
    5494:	mov    rdx,rax
    5497:	mov    rsi,QWORD PTR [rsp+0x88]
    549f:	mov    eax,0x2
    54a4:	cmp    rsi,rdx
    54a7:	cmove  rax,QWORD PTR [rip+0x1c1]        # 5670 <botlish_fn_55+0x480>
    54af:	cmp    rax,0x6
    54b3:	je     54be <botlish_fn_55+0x2ce>
    54b9:	mov    ebx,0x2
    54be:	mov    QWORD PTR [rsp],rbx
    54c2:	mov    rsi,r12
    54c5:	mov    rdi,r13
    54c8:	call   54cd <botlish_fn_55+0x2dd>
			54c9: R_X86_64_PLT32	rt_list_len-0x4
    54cd:	mov    QWORD PTR [rsp+0x18],rax
    54d2:	mov    rdi,r13
    54d5:	mov    r12,rax
    54d8:	mov    rax,QWORD PTR [rdi+0x10]
    54dc:	mov    rdx,QWORD PTR [rax+0x58]
    54e0:	mov    QWORD PTR [rsp+0x20],rdx
    54e5:	mov    rsi,r15
    54e8:	call   54ed <botlish_fn_55+0x2fd>
			54e9: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54ed:	test   rax,rax
    54f0:	je     5604 <botlish_fn_55+0x414>
    54f6:	mov    QWORD PTR [rsp+0x20],rax
    54fb:	mov    rdi,r13
    54fe:	mov    QWORD PTR [rsp+0x88],rax
    5506:	mov    rax,QWORD PTR [rdi+0x10]
    550a:	mov    rdx,QWORD PTR [rax+0x60]
    550e:	mov    QWORD PTR [rsp+0x28],rdx
    5513:	mov    rsi,r15
    5516:	call   551b <botlish_fn_55+0x32b>
			5517: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    551b:	test   rax,rax
    551e:	je     5604 <botlish_fn_55+0x414>
    5524:	mov    QWORD PTR [rsp+0x28],rax
    5529:	mov    rdi,r13
    552c:	mov    QWORD PTR [rsp+0x80],rax
    5534:	mov    rax,QWORD PTR [rdi+0x10]
    5538:	mov    rdx,QWORD PTR [rax+0x68]
    553c:	mov    QWORD PTR [rsp+0x30],rdx
    5541:	mov    rsi,r15
    5544:	call   5549 <botlish_fn_55+0x359>
			5545: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5549:	test   rax,rax
    554c:	je     5604 <botlish_fn_55+0x414>
    5552:	mov    QWORD PTR [rsp+0x8],rax
    5557:	mov    rdi,r13
    555a:	mov    r15,rax
    555d:	mov    rax,QWORD PTR [rdi+0x10]
    5561:	mov    rdx,QWORD PTR [rax+0x58]
    5565:	mov    QWORD PTR [rsp+0x30],rdx
    556a:	mov    rsi,r14
    556d:	call   5572 <botlish_fn_55+0x382>
			556e: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5572:	test   rax,rax
    5575:	je     5604 <botlish_fn_55+0x414>
    557b:	mov    QWORD PTR [rsp+0x30],rax
    5580:	mov    rdi,r13
    5583:	mov    QWORD PTR [rsp+0x78],rax
    5588:	mov    rax,QWORD PTR [rdi+0x10]
    558c:	mov    rdx,QWORD PTR [rax+0x68]
    5590:	mov    QWORD PTR [rsp+0x38],rdx
    5595:	mov    rsi,r14
    5598:	call   559d <botlish_fn_55+0x3ad>
			5599: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    559d:	test   rax,rax
    55a0:	je     5604 <botlish_fn_55+0x414>
    55a6:	mov    QWORD PTR [rsp+0x10],rax
    55ab:	lea    rdx,[rsp+0x40]
    55b0:	mov    r9,r12
    55b3:	mov    QWORD PTR [rsp+0x40],r9
    55b8:	mov    rcx,QWORD PTR [rsp+0x88]
    55c0:	mov    QWORD PTR [rsp+0x48],rcx
    55c5:	mov    rcx,QWORD PTR [rsp+0x80]
    55cd:	mov    QWORD PTR [rsp+0x50],rcx
    55d2:	mov    rcx,r15
    55d5:	mov    QWORD PTR [rsp+0x58],rcx
    55da:	mov    rcx,QWORD PTR [rsp+0x78]
    55df:	mov    QWORD PTR [rsp+0x60],rcx
    55e4:	mov    QWORD PTR [rsp+0x68],rax
    55e9:	mov    QWORD PTR [rsp+0x70],rbx
    55ee:	mov    esi,0x7
    55f3:	mov    rdi,r13
    55f6:	call   55fb <botlish_fn_55+0x40b>
			55f7: R_X86_64_PLT32	rt_list_new-0x4
    55fb:	test   rax,rax
    55fe:	jne    563b <botlish_fn_55+0x44b>
    5604:	xor    rax,rax
    5607:	mov    rbx,QWORD PTR [rsp+0x90]
    560f:	mov    r12,QWORD PTR [rsp+0x98]
    5617:	mov    r13,QWORD PTR [rsp+0xa0]
    561f:	mov    r14,QWORD PTR [rsp+0xa8]
    5627:	mov    r15,QWORD PTR [rsp+0xb0]
    562f:	add    rsp,0xc0
    5636:	mov    rsp,rbp
    5639:	pop    rbp
    563a:	ret
    563b:	mov    rbx,QWORD PTR [rsp+0x90]
    5643:	mov    r12,QWORD PTR [rsp+0x98]
    564b:	mov    r13,QWORD PTR [rsp+0xa0]
    5653:	mov    r14,QWORD PTR [rsp+0xa8]
    565b:	mov    r15,QWORD PTR [rsp+0xb0]
    5663:	add    rsp,0xc0
    566a:	mov    rsp,rbp
    566d:	pop    rbp
    566e:	ret
    566f:	add    BYTE PTR [rsi],al
    5671:	add    BYTE PTR [rax],al
    5673:	add    BYTE PTR [rax],al
    5675:	add    BYTE PTR [rax],al
	...

0000000000005678 <botlish_entry_55: sample_checks<generic>>:
    5678:	push   rbp
    5679:	mov    rbp,rsp
    567c:	call   5681 <botlish_entry_55+0x9>
			567d: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample_checks<generic>
    5681:	mov    rsp,rbp
    5684:	pop    rbp
    5685:	ret

0000000000005686 <botlish_fn_56: sample<generic>>:
    5686:	push   rbp
    5687:	mov    rbp,rsp
    568a:	sub    rsp,0x10
    568e:	mov    QWORD PTR [rsp],rbx
    5692:	mov    rbx,rdi
    5695:	mov    rdi,rbx
    5698:	call   569d <botlish_fn_56+0x17>
			5699: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample_checks<generic>
    569d:	test   rax,rax
    56a0:	jne    5759 <botlish_fn_56+0xd3>
    56a6:	mov    rdi,rbx
    56a9:	call   56ae <botlish_fn_56+0x28>
			56aa: R_X86_64_PLT32	rt_declared_error-0x4
    56ae:	cmp    rax,0x40000001
    56b4:	je     572a <botlish_fn_56+0xa4>
    56ba:	mov    rdi,rbx
    56bd:	call   56c2 <botlish_fn_56+0x3c>
			56be: R_X86_64_PLT32	rt_declared_error-0x4
    56c2:	cmp    rax,0x40000002
    56c8:	je     5706 <botlish_fn_56+0x80>
    56ce:	mov    rdi,rbx
    56d1:	call   56d6 <botlish_fn_56+0x50>
			56d2: R_X86_64_PLT32	rt_declared_error-0x4
    56d6:	cmp    rax,0x40000003
    56dc:	jne    5749 <botlish_fn_56+0xc3>
    56e2:	mov    rdi,rbx
    56e5:	call   56ea <botlish_fn_56+0x64>
			56e6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    56ea:	xor    rdx,rdx
    56ed:	mov    rdi,rbx
    56f0:	mov    rsi,rdx
    56f3:	call   56f8 <botlish_fn_56+0x72>
			56f4: R_X86_64_PLT32	rt_list_new-0x4
    56f8:	test   rax,rax
    56fb:	je     5749 <botlish_fn_56+0xc3>
    5701:	jmp    5759 <botlish_fn_56+0xd3>
    5706:	mov    rdi,rbx
    5709:	call   570e <botlish_fn_56+0x88>
			570a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    570e:	xor    rdx,rdx
    5711:	mov    rdi,rbx
    5714:	mov    rsi,rdx
    5717:	call   571c <botlish_fn_56+0x96>
			5718: R_X86_64_PLT32	rt_list_new-0x4
    571c:	test   rax,rax
    571f:	je     5749 <botlish_fn_56+0xc3>
    5725:	jmp    5759 <botlish_fn_56+0xd3>
    572a:	mov    rdi,rbx
    572d:	call   5732 <botlish_fn_56+0xac>
			572e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5732:	xor    rdx,rdx
    5735:	mov    rdi,rbx
    5738:	mov    rsi,rdx
    573b:	call   5740 <botlish_fn_56+0xba>
			573c: R_X86_64_PLT32	rt_list_new-0x4
    5740:	test   rax,rax
    5743:	jne    5759 <botlish_fn_56+0xd3>
    5749:	xor    rax,rax
    574c:	mov    rbx,QWORD PTR [rsp]
    5750:	add    rsp,0x10
    5754:	mov    rsp,rbp
    5757:	pop    rbp
    5758:	ret
    5759:	mov    rbx,QWORD PTR [rsp]
    575d:	add    rsp,0x10
    5761:	mov    rsp,rbp
    5764:	pop    rbp
    5765:	ret

0000000000005766 <botlish_entry_56: sample<generic>>:
    5766:	push   rbp
    5767:	mov    rbp,rsp
    576a:	call   576f <botlish_entry_56+0x9>
			576b: R_X86_64_PLT32	botlish_fn_56-0x4 ; sample<generic>
    576f:	mov    rsp,rbp
    5772:	pop    rbp
    5773:	ret

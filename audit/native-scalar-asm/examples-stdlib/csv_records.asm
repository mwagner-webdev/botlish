; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23217  (per function: 45 461 461 461 81 81 81 357 412 412 412 278 278 278 81 365 430 585 1046 352 783 215 488 325 388 524 70 493 114 61 61 61 61 61 168 179 245 804 1248 429 380 439 977 766 817 665 1168 836 107 427 259 629 634 78 78 1222)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> mutarray::create<int, str>
;   botlish_fn_2 / botlish_entry_2 -> mutarray::create<int, List[str]>
;   botlish_fn_3 / botlish_entry_3 -> mutarray::create<int, mutarray>
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
;   botlish_fn_55 / botlish_entry_55 -> sample<generic>


csv_records.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample<generic>
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

0000000000000030 <botlish_fn_1: mutarray::create<int, str>>:
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

00000000000001c8 <botlish_entry_1: mutarray::create<int, str>>:
     1c8:	push   rbp
     1c9:	mov    rbp,rsp
     1cc:	mov    rsi,QWORD PTR [rdx]
     1cf:	mov    rdx,QWORD PTR [rdx+0x8]
     1d3:	call   1d8 <botlish_entry_1+0x10>
			1d4: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
     1d8:	mov    rsp,rbp
     1db:	pop    rbp
     1dc:	ret
     1dd:	add    BYTE PTR [rax],al
	...

00000000000001e0 <botlish_fn_2: mutarray::create<int, List[str]>>:
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

0000000000000378 <botlish_entry_2: mutarray::create<int, List[str]>>:
     378:	push   rbp
     379:	mov    rbp,rsp
     37c:	mov    rsi,QWORD PTR [rdx]
     37f:	mov    rdx,QWORD PTR [rdx+0x8]
     383:	call   388 <botlish_entry_2+0x10>
			384: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
     388:	mov    rsp,rbp
     38b:	pop    rbp
     38c:	ret
     38d:	add    BYTE PTR [rax],al
	...

0000000000000390 <botlish_fn_3: mutarray::create<int, mutarray>>:
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

0000000000000528 <botlish_entry_3: mutarray::create<int, mutarray>>:
     528:	push   rbp
     529:	mov    rbp,rsp
     52c:	mov    rsi,QWORD PTR [rdx]
     52f:	mov    rdx,QWORD PTR [rdx+0x8]
     533:	call   538 <botlish_entry_3+0x10>
			534: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutarray::create<int, mutarray>
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
			55b: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
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
			5ac: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
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
			5fd: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutarray::create<int, mutarray>
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
			841: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
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
			9d1: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
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
			b61: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutarray::create<int, mutarray>
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
    14ab:	add    BYTE PTR [rax],al
    14ad:	add    BYTE PTR [rax],al
	...

00000000000014b0 <botlish_fn_18: scan_quoted<str, int, str>>:
    14b0:	push   rbp
    14b1:	mov    rbp,rsp
    14b4:	sub    rsp,0xd0
    14bb:	mov    QWORD PTR [rsp+0xa0],rbx
    14c3:	mov    QWORD PTR [rsp+0xa8],r12
    14cb:	mov    QWORD PTR [rsp+0xb0],r13
    14d3:	mov    QWORD PTR [rsp+0xb8],r14
    14db:	mov    QWORD PTR [rsp+0xc0],r15
    14e3:	mov    r15,rdi
    14e6:	mov    QWORD PTR [rsp+0x18],0x0
    14ef:	mov    QWORD PTR [rsp+0x20],0x0
    14f8:	mov    QWORD PTR [rsp],rsi
    14fc:	mov    QWORD PTR [rsp+0x8],rdx
    1501:	mov    QWORD PTR [rsp+0x10],rcx
    1506:	mov    r13,rcx
    1509:	lea    r14,[rsp+0x68]
    150e:	lea    rbx,[rsp+0x28]
    1513:	mov    r12,rsi
    1516:	mov    QWORD PTR [rsp+0x88],rdx
    151e:	mov    rdx,QWORD PTR [rsp+0x88]
    1526:	mov    rsi,r12
    1529:	mov    rdi,r15
    152c:	call   1531 <botlish_fn_18+0x81>
			152d: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    1531:	test   rax,rax
    1534:	je     1828 <botlish_fn_18+0x378>
    153a:	mov    QWORD PTR [rsp+0x18],rax
    153f:	mov    rdx,QWORD PTR [rax+0x8]
    1543:	mov    ecx,DWORD PTR [rax+0x14]
    1546:	mov    QWORD PTR [rsp+0x90],rax
    154e:	test   rdx,rdx
    1551:	cmove  rcx,QWORD PTR [rip+0x327]        # 1880 <botlish_fn_18+0x3d0>
    1559:	cmp    rcx,0x22
    155d:	je     161d <botlish_fn_18+0x16d>
    1563:	mov    QWORD PTR [rsp+0x20],0x3
    156c:	mov    rsi,QWORD PTR [rsp+0x88]
    1574:	test   rsi,0x1
    157b:	je     159d <botlish_fn_18+0xed>
    1581:	mov    r8,rsi
    1584:	add    r8,0x2
    1588:	seto   r10b
    158c:	test   r10b,r10b
    158f:	jne    159d <botlish_fn_18+0xed>
    1595:	mov    rsi,r8
    1598:	jmp    15ad <botlish_fn_18+0xfd>
    159d:	mov    edx,0x3
    15a2:	mov    rdi,r15
    15a5:	call   15aa <botlish_fn_18+0xfa>
			15a6: R_X86_64_PLT32	rt_int_add-0x4
    15aa:	mov    rsi,rax
    15ad:	mov    QWORD PTR [rsp+0x8],rsi
    15b2:	mov    QWORD PTR [rsp+0x88],rsi
    15ba:	mov    QWORD PTR [rsp+0x68],0x0
    15c3:	mov    QWORD PTR [rsp+0x70],r13
    15c8:	mov    QWORD PTR [rsp+0x78],0x0
    15d1:	mov    rax,QWORD PTR [rsp+0x90]
    15d9:	mov    QWORD PTR [rsp+0x80],rax
    15e1:	mov    esi,0x2
    15e6:	mov    edx,0x4
    15eb:	mov    rcx,r14
    15ee:	mov    rdi,r15
    15f1:	call   15f6 <botlish_fn_18+0x146>
			15f2: R_X86_64_PLT32	rt_construct-0x4
    15f6:	test   rax,rax
    15f9:	je     1828 <botlish_fn_18+0x378>
    15ff:	mov    QWORD PTR [rsp],r12
    1603:	mov    rsi,QWORD PTR [rsp+0x88]
    160b:	mov    QWORD PTR [rsp+0x8],rsi
    1610:	mov    QWORD PTR [rsp+0x10],rax
    1615:	mov    r13,rax
    1618:	jmp    151e <botlish_fn_18+0x6e>
    161d:	mov    QWORD PTR [rsp+0x18],0x3
    1626:	mov    rsi,QWORD PTR [rsp+0x88]
    162e:	test   rsi,0x1
    1635:	je     1655 <botlish_fn_18+0x1a5>
    163b:	mov    rsi,QWORD PTR [rsp+0x88]
    1643:	mov    rdx,rsi
    1646:	add    rdx,0x2
    164a:	seto   al
    164d:	test   al,al
    164f:	je     166d <botlish_fn_18+0x1bd>
    1655:	mov    edx,0x3
    165a:	mov    rsi,QWORD PTR [rsp+0x88]
    1662:	mov    rdi,r15
    1665:	call   166a <botlish_fn_18+0x1ba>
			1666: R_X86_64_PLT32	rt_int_add-0x4
    166a:	mov    rdx,rax
    166d:	mov    QWORD PTR [rsp+0x18],rdx
    1672:	mov    rcx,rbx
    1675:	mov    rsi,r12
    1678:	mov    rdi,r15
    167b:	call   1680 <botlish_fn_18+0x1d0>
			167c: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1680:	test   rax,rax
    1683:	mov    rsi,rax
    1686:	je     1828 <botlish_fn_18+0x378>
    168c:	mov    rdx,QWORD PTR [rsp+0x28]
    1691:	mov    rcx,QWORD PTR [rsp+0x30]
    1696:	mov    rdi,r15
    1699:	mov    rax,QWORD PTR [rdi+0x10]
    169d:	mov    r8,QWORD PTR [rax+0x20]
    16a1:	call   16a6 <botlish_fn_18+0x1f6>
			16a2: R_X86_64_PLT32	rt_str_region_eq-0x4
    16a6:	cmp    rax,0x6
    16aa:	je     1772 <botlish_fn_18+0x2c2>
    16b0:	xor    rsi,rsi
    16b3:	lea    rcx,[rsp+0x58]
    16b8:	mov    QWORD PTR [rsp+0x58],0x0
    16c1:	mov    QWORD PTR [rsp+0x60],r13
    16c6:	mov    edx,0x2
    16cb:	mov    rdi,r15
    16ce:	call   16d3 <botlish_fn_18+0x223>
			16cf: R_X86_64_PLT32	rt_construct-0x4
    16d3:	test   rax,rax
    16d6:	je     1828 <botlish_fn_18+0x378>
    16dc:	mov    QWORD PTR [rsp],rax
    16e0:	mov    rbx,rax
    16e3:	mov    QWORD PTR [rsp+0x10],0x3
    16ec:	mov    rsi,QWORD PTR [rsp+0x88]
    16f4:	test   rsi,0x1
    16fb:	je     1723 <botlish_fn_18+0x273>
    1701:	mov    rsi,QWORD PTR [rsp+0x88]
    1709:	mov    rdx,rsi
    170c:	add    rdx,0x2
    1710:	seto   al
    1713:	test   al,al
    1715:	jne    1723 <botlish_fn_18+0x273>
    171b:	mov    rax,rbx
    171e:	jmp    173e <botlish_fn_18+0x28e>
    1723:	mov    edx,0x3
    1728:	mov    rsi,QWORD PTR [rsp+0x88]
    1730:	mov    rdi,r15
    1733:	call   1738 <botlish_fn_18+0x288>
			1734: R_X86_64_PLT32	rt_int_add-0x4
    1738:	mov    rdx,rax
    173b:	mov    rax,rbx
    173e:	mov    rbx,QWORD PTR [rsp+0xa0]
    1746:	mov    r12,QWORD PTR [rsp+0xa8]
    174e:	mov    r13,QWORD PTR [rsp+0xb0]
    1756:	mov    r14,QWORD PTR [rsp+0xb8]
    175e:	mov    r15,QWORD PTR [rsp+0xc0]
    1766:	add    rsp,0xd0
    176d:	mov    rsp,rbp
    1770:	pop    rbp
    1771:	ret
    1772:	mov    QWORD PTR [rsp+0x18],0x5
    177b:	mov    rsi,QWORD PTR [rsp+0x88]
    1783:	test   rsi,0x1
    178a:	je     17ba <botlish_fn_18+0x30a>
    1790:	mov    rsi,QWORD PTR [rsp+0x88]
    1798:	mov    rax,rsi
    179b:	add    rax,0x4
    179f:	seto   cl
    17a2:	test   cl,cl
    17a4:	jne    17ba <botlish_fn_18+0x30a>
    17aa:	mov    rsi,rax
    17ad:	mov    QWORD PTR [rsp+0x88],rax
    17b5:	jmp    17da <botlish_fn_18+0x32a>
    17ba:	mov    edx,0x5
    17bf:	mov    rsi,QWORD PTR [rsp+0x88]
    17c7:	mov    rdi,r15
    17ca:	call   17cf <botlish_fn_18+0x31f>
			17cb: R_X86_64_PLT32	rt_int_add-0x4
    17cf:	mov    rsi,rax
    17d2:	mov    QWORD PTR [rsp+0x88],rax
    17da:	mov    QWORD PTR [rsp+0x8],rsi
    17df:	mov    rdi,r15
    17e2:	mov    rsi,QWORD PTR [rdi+0x10]
    17e6:	mov    rsi,QWORD PTR [rsi+0x20]
    17ea:	mov    QWORD PTR [rsp+0x18],rsi
    17ef:	lea    rcx,[rsp+0x38]
    17f4:	mov    QWORD PTR [rsp+0x38],0x0
    17fd:	mov    QWORD PTR [rsp+0x40],r13
    1802:	mov    QWORD PTR [rsp+0x48],0x0
    180b:	mov    QWORD PTR [rsp+0x50],rsi
    1810:	mov    esi,0x2
    1815:	mov    edx,0x4
    181a:	call   181f <botlish_fn_18+0x36f>
			181b: R_X86_64_PLT32	rt_construct-0x4
    181f:	test   rax,rax
    1822:	jne    1862 <botlish_fn_18+0x3b2>
    1828:	xor    rdx,rdx
    182b:	mov    rax,rdx
    182e:	mov    rbx,QWORD PTR [rsp+0xa0]
    1836:	mov    r12,QWORD PTR [rsp+0xa8]
    183e:	mov    r13,QWORD PTR [rsp+0xb0]
    1846:	mov    r14,QWORD PTR [rsp+0xb8]
    184e:	mov    r15,QWORD PTR [rsp+0xc0]
    1856:	add    rsp,0xd0
    185d:	mov    rsp,rbp
    1860:	pop    rbp
    1861:	ret
    1862:	mov    QWORD PTR [rsp],r12
    1866:	mov    rsi,QWORD PTR [rsp+0x88]
    186e:	mov    QWORD PTR [rsp+0x8],rsi
    1873:	mov    QWORD PTR [rsp+0x10],rax
    1878:	mov    r13,rax
    187b:	jmp    151e <botlish_fn_18+0x6e>
    1880:	(bad)
    1881:	(bad)
    1882:	(bad)
    1883:	(bad)
    1884:	(bad)
    1885:	(bad)
    1886:	(bad)
    1887:	.byte 0xff

0000000000001888 <botlish_entry_18: scan_quoted<str, int, str>>:
    1888:	push   rbp
    1889:	mov    rbp,rsp
    188c:	ud2

000000000000188e <botlish_fn_19: scan_field<str, int>>:
    188e:	push   rbp
    188f:	mov    rbp,rsp
    1892:	sub    rsp,0x50
    1896:	mov    QWORD PTR [rsp+0x30],rbx
    189b:	mov    QWORD PTR [rsp+0x38],r12
    18a0:	mov    QWORD PTR [rsp+0x40],r13
    18a5:	mov    r12,rdi
    18a8:	mov    r13,rdx
    18ab:	mov    QWORD PTR [rsp+0x10],0x0
    18b4:	mov    QWORD PTR [rsp],rsi
    18b8:	mov    rbx,rsi
    18bb:	mov    QWORD PTR [rsp+0x8],rdx
    18c0:	lea    rcx,[rsp+0x18]
    18c5:	mov    rdx,r13
    18c8:	mov    rsi,rbx
    18cb:	mov    rdi,r12
    18ce:	call   18d3 <botlish_fn_19+0x45>
			18cf: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    18d3:	test   rax,rax
    18d6:	mov    rsi,rax
    18d9:	je     19a4 <botlish_fn_19+0x116>
    18df:	mov    rdx,QWORD PTR [rsp+0x18]
    18e4:	mov    rcx,QWORD PTR [rsp+0x20]
    18e9:	mov    rdi,r12
    18ec:	mov    rax,QWORD PTR [rdi+0x10]
    18f0:	mov    r8,QWORD PTR [rax+0x20]
    18f4:	call   18f9 <botlish_fn_19+0x6b>
			18f5: R_X86_64_PLT32	rt_str_region_eq-0x4
    18f9:	cmp    rax,0x6
    18fd:	je     1935 <botlish_fn_19+0xa7>
    1903:	mov    rcx,r13
    1906:	mov    rsi,rbx
    1909:	mov    rdi,r12
    190c:	mov    rdx,rcx
    190f:	call   1914 <botlish_fn_19+0x86>
			1910: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    1914:	test   rax,rax
    1917:	je     19a4 <botlish_fn_19+0x116>
    191d:	mov    rbx,QWORD PTR [rsp+0x30]
    1922:	mov    r12,QWORD PTR [rsp+0x38]
    1927:	mov    r13,QWORD PTR [rsp+0x40]
    192c:	add    rsp,0x50
    1930:	mov    rsp,rbp
    1933:	pop    rbp
    1934:	ret
    1935:	mov    rcx,r13
    1938:	mov    QWORD PTR [rsp+0x10],0x3
    1941:	test   rcx,0x1
    1948:	jne    1956 <botlish_fn_19+0xc8>
    194e:	mov    r13,rcx
    1951:	jmp    196b <botlish_fn_19+0xdd>
    1956:	mov    rdx,rcx
    1959:	add    rdx,0x2
    195d:	mov    r13,rcx
    1960:	seto   al
    1963:	test   al,al
    1965:	je     197e <botlish_fn_19+0xf0>
    196b:	mov    edx,0x3
    1970:	mov    rsi,r13
    1973:	mov    rdi,r12
    1976:	call   197b <botlish_fn_19+0xed>
			1977: R_X86_64_PLT32	rt_int_add-0x4
    197b:	mov    rdx,rax
    197e:	mov    QWORD PTR [rsp+0x8],rdx
    1983:	mov    rdi,r12
    1986:	mov    rax,QWORD PTR [rdi+0x10]
    198a:	mov    rcx,QWORD PTR [rax+0x8]
    198e:	mov    QWORD PTR [rsp+0x10],rcx
    1993:	mov    rsi,rbx
    1996:	call   199b <botlish_fn_19+0x10d>
			1997: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    199b:	test   rax,rax
    199e:	jne    19c2 <botlish_fn_19+0x134>
    19a4:	xor    rdx,rdx
    19a7:	mov    rax,rdx
    19aa:	mov    rbx,QWORD PTR [rsp+0x30]
    19af:	mov    r12,QWORD PTR [rsp+0x38]
    19b4:	mov    r13,QWORD PTR [rsp+0x40]
    19b9:	add    rsp,0x50
    19bd:	mov    rsp,rbp
    19c0:	pop    rbp
    19c1:	ret
    19c2:	mov    rbx,QWORD PTR [rsp+0x30]
    19c7:	mov    r12,QWORD PTR [rsp+0x38]
    19cc:	mov    r13,QWORD PTR [rsp+0x40]
    19d1:	add    rsp,0x50
    19d5:	mov    rsp,rbp
    19d8:	pop    rbp
    19d9:	ret

00000000000019da <botlish_entry_19: scan_field<str, int>>:
    19da:	push   rbp
    19db:	mov    rbp,rsp
    19de:	ud2

00000000000019e0 <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    19e0:	push   rbp
    19e1:	mov    rbp,rsp
    19e4:	sub    rsp,0x90
    19eb:	mov    QWORD PTR [rsp+0x60],rbx
    19f0:	mov    QWORD PTR [rsp+0x68],r12
    19f5:	mov    QWORD PTR [rsp+0x70],r13
    19fa:	mov    QWORD PTR [rsp+0x78],r14
    19ff:	mov    QWORD PTR [rsp+0x80],r15
    1a07:	mov    r15,rdi
    1a0a:	mov    QWORD PTR [rsp+0x20],0x0
    1a13:	mov    QWORD PTR [rsp],rsi
    1a17:	mov    QWORD PTR [rsp+0x8],rdx
    1a1c:	mov    QWORD PTR [rsp+0x10],rcx
    1a21:	mov    QWORD PTR [rsp+0x18],r8
    1a26:	lea    r12,[rsp+0x28]
    1a2b:	mov    rbx,rsi
    1a2e:	mov    QWORD PTR [rsp+0x38],rdx
    1a33:	mov    QWORD PTR [rsp+0x40],rcx
    1a38:	mov    QWORD PTR [rsp+0x48],r8
    1a3d:	mov    rcx,r12
    1a40:	mov    rdx,QWORD PTR [rsp+0x38]
    1a45:	mov    rsi,rbx
    1a48:	mov    rdi,r15
    1a4b:	call   1a50 <botlish_fn_20+0x70>
			1a4c: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1a50:	test   rax,rax
    1a53:	mov    QWORD PTR [rsp+0x50],rax
    1a58:	je     1c1c <botlish_fn_20+0x23c>
    1a5e:	mov    r14,QWORD PTR [rsp+0x28]
    1a63:	mov    r13,QWORD PTR [rsp+0x30]
    1a68:	mov    rdi,r15
    1a6b:	mov    rcx,QWORD PTR [rdi+0x10]
    1a6f:	mov    r8,QWORD PTR [rcx+0x10]
    1a73:	mov    rcx,r13
    1a76:	mov    rdx,r14
    1a79:	mov    rsi,QWORD PTR [rsp+0x50]
    1a7e:	call   1a83 <botlish_fn_20+0xa3>
			1a7f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a83:	cmp    rax,0x6
    1a87:	je     1b95 <botlish_fn_20+0x1b5>
    1a8d:	mov    rdi,r15
    1a90:	mov    rax,QWORD PTR [rdi+0x10]
    1a94:	mov    r8,QWORD PTR [rax+0x18]
    1a98:	mov    rcx,r13
    1a9b:	mov    rdx,r14
    1a9e:	mov    rsi,QWORD PTR [rsp+0x50]
    1aa3:	call   1aa8 <botlish_fn_20+0xc8>
			1aa4: R_X86_64_PLT32	rt_str_region_eq-0x4
    1aa8:	cmp    rax,0x6
    1aac:	je     1afa <botlish_fn_20+0x11a>
    1ab2:	mov    rdx,QWORD PTR [rsp+0x48]
    1ab7:	mov    rsi,QWORD PTR [rsp+0x40]
    1abc:	mov    rdi,r15
    1abf:	call   1ac4 <botlish_fn_20+0xe4>
			1ac0: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1ac4:	test   rax,rax
    1ac7:	je     1c1c <botlish_fn_20+0x23c>
    1acd:	mov    rdx,QWORD PTR [rsp+0x38]
    1ad2:	mov    rbx,QWORD PTR [rsp+0x60]
    1ad7:	mov    r12,QWORD PTR [rsp+0x68]
    1adc:	mov    r13,QWORD PTR [rsp+0x70]
    1ae1:	mov    r14,QWORD PTR [rsp+0x78]
    1ae6:	mov    r15,QWORD PTR [rsp+0x80]
    1aee:	add    rsp,0x90
    1af5:	mov    rsp,rbp
    1af8:	pop    rbp
    1af9:	ret
    1afa:	mov    rdx,QWORD PTR [rsp+0x48]
    1aff:	mov    rsi,QWORD PTR [rsp+0x40]
    1b04:	mov    rdi,r15
    1b07:	call   1b0c <botlish_fn_20+0x12c>
			1b08: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b0c:	test   rax,rax
    1b0f:	je     1c1c <botlish_fn_20+0x23c>
    1b15:	mov    QWORD PTR [rsp],rax
    1b19:	mov    rbx,rax
    1b1c:	mov    QWORD PTR [rsp+0x10],0x3
    1b25:	mov    rdx,QWORD PTR [rsp+0x38]
    1b2a:	test   rdx,0x1
    1b31:	je     1b55 <botlish_fn_20+0x175>
    1b37:	mov    rdx,QWORD PTR [rsp+0x38]
    1b3c:	add    rdx,0x2
    1b40:	seto   sil
    1b44:	test   sil,sil
    1b47:	jne    1b55 <botlish_fn_20+0x175>
    1b4d:	mov    rax,rbx
    1b50:	jmp    1b6d <botlish_fn_20+0x18d>
    1b55:	mov    edx,0x3
    1b5a:	mov    rsi,QWORD PTR [rsp+0x38]
    1b5f:	mov    rdi,r15
    1b62:	call   1b67 <botlish_fn_20+0x187>
			1b63: R_X86_64_PLT32	rt_int_add-0x4
    1b67:	mov    rdx,rax
    1b6a:	mov    rax,rbx
    1b6d:	mov    rbx,QWORD PTR [rsp+0x60]
    1b72:	mov    r12,QWORD PTR [rsp+0x68]
    1b77:	mov    r13,QWORD PTR [rsp+0x70]
    1b7c:	mov    r14,QWORD PTR [rsp+0x78]
    1b81:	mov    r15,QWORD PTR [rsp+0x80]
    1b89:	add    rsp,0x90
    1b90:	mov    rsp,rbp
    1b93:	pop    rbp
    1b94:	ret
    1b95:	mov    rsi,QWORD PTR [rsp+0x38]
    1b9a:	mov    edx,0x3
    1b9f:	mov    r13,rdx
    1ba2:	mov    QWORD PTR [rsp+0x20],0x3
    1bab:	test   rsi,0x1
    1bb2:	je     1bca <botlish_fn_20+0x1ea>
    1bb8:	mov    rdx,rsi
    1bbb:	add    rdx,0x2
    1bbf:	seto   al
    1bc2:	test   al,al
    1bc4:	je     1bd8 <botlish_fn_20+0x1f8>
    1bca:	mov    rdx,r13
    1bcd:	mov    rdi,r15
    1bd0:	call   1bd5 <botlish_fn_20+0x1f5>
			1bd1: R_X86_64_PLT32	rt_int_add-0x4
    1bd5:	mov    rdx,rax
    1bd8:	mov    QWORD PTR [rsp+0x8],rdx
    1bdd:	mov    rsi,rbx
    1be0:	mov    rdi,r15
    1be3:	call   1be8 <botlish_fn_20+0x208>
			1be4: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1be8:	test   rax,rax
    1beb:	je     1c1c <botlish_fn_20+0x23c>
    1bf1:	mov    QWORD PTR [rsp+0x8],rax
    1bf6:	mov    rcx,rax
    1bf9:	mov    QWORD PTR [rsp+0x20],rdx
    1bfe:	mov    rsi,QWORD PTR [rsp+0x40]
    1c03:	mov    r14,rdx
    1c06:	mov    rdx,QWORD PTR [rsp+0x48]
    1c0b:	mov    rdi,r15
    1c0e:	call   1c13 <botlish_fn_20+0x233>
			1c0f: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1c13:	test   rax,rax
    1c16:	jne    1c4a <botlish_fn_20+0x26a>
    1c1c:	xor    rdx,rdx
    1c1f:	mov    rax,rdx
    1c22:	mov    rbx,QWORD PTR [rsp+0x60]
    1c27:	mov    r12,QWORD PTR [rsp+0x68]
    1c2c:	mov    r13,QWORD PTR [rsp+0x70]
    1c31:	mov    r14,QWORD PTR [rsp+0x78]
    1c36:	mov    r15,QWORD PTR [rsp+0x80]
    1c3e:	add    rsp,0x90
    1c45:	mov    rsp,rbp
    1c48:	pop    rbp
    1c49:	ret
    1c4a:	mov    QWORD PTR [rsp+0x8],rax
    1c4f:	mov    QWORD PTR [rsp+0x38],rax
    1c54:	mov    QWORD PTR [rsp+0x10],0x3
    1c5d:	mov    rdx,QWORD PTR [rsp+0x48]
    1c62:	test   rdx,0x1
    1c69:	jne    1c7c <botlish_fn_20+0x29c>
    1c6f:	mov    rdx,r13
    1c72:	mov    rsi,QWORD PTR [rsp+0x48]
    1c77:	jmp    1c9b <botlish_fn_20+0x2bb>
    1c7c:	mov    rdx,QWORD PTR [rsp+0x48]
    1c81:	mov    rax,rdx
    1c84:	add    rax,0x2
    1c88:	seto   cl
    1c8b:	test   cl,cl
    1c8d:	je     1ca3 <botlish_fn_20+0x2c3>
    1c93:	mov    rdx,r13
    1c96:	mov    rsi,QWORD PTR [rsp+0x48]
    1c9b:	mov    rdi,r15
    1c9e:	call   1ca3 <botlish_fn_20+0x2c3>
			1c9f: R_X86_64_PLT32	rt_int_add-0x4
    1ca3:	mov    QWORD PTR [rsp],rbx
    1ca7:	mov    rdx,r14
    1caa:	mov    QWORD PTR [rsp+0x8],rdx
    1caf:	mov    rcx,QWORD PTR [rsp+0x38]
    1cb4:	mov    QWORD PTR [rsp+0x10],rcx
    1cb9:	mov    QWORD PTR [rsp+0x18],rax
    1cbe:	mov    QWORD PTR [rsp+0x38],rdx
    1cc3:	mov    QWORD PTR [rsp+0x40],rcx
    1cc8:	mov    QWORD PTR [rsp+0x48],rax
    1ccd:	jmp    1a3d <botlish_fn_20+0x5d>

0000000000001cd2 <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1cd2:	push   rbp
    1cd3:	mov    rbp,rsp
    1cd6:	ud2

0000000000001cd8 <botlish_fn_21: scan_record<str, int>>:
    1cd8:	push   rbp
    1cd9:	mov    rbp,rsp
    1cdc:	sub    rsp,0x40
    1ce0:	mov    QWORD PTR [rsp+0x20],rbx
    1ce5:	mov    QWORD PTR [rsp+0x28],r12
    1cea:	mov    QWORD PTR [rsp+0x30],r14
    1cef:	mov    r14,rdi
    1cf2:	mov    QWORD PTR [rsp+0x10],0x0
    1cfb:	mov    QWORD PTR [rsp+0x18],0x0
    1d04:	mov    QWORD PTR [rsp],rsi
    1d08:	mov    r12,rsi
    1d0b:	mov    QWORD PTR [rsp+0x8],rdx
    1d10:	mov    rsi,r12
    1d13:	mov    rdi,r14
    1d16:	call   1d1b <botlish_fn_21+0x43>
			1d17: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1d1b:	test   rax,rax
    1d1e:	je     1d73 <botlish_fn_21+0x9b>
    1d24:	mov    QWORD PTR [rsp+0x8],rax
    1d29:	mov    rsi,rax
    1d2c:	mov    QWORD PTR [rsp+0x10],rdx
    1d31:	mov    rbx,rdx
    1d34:	mov    rdi,r14
    1d37:	call   1d3c <botlish_fn_21+0x64>
			1d38: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1d3c:	test   rax,rax
    1d3f:	je     1d73 <botlish_fn_21+0x9b>
    1d45:	mov    QWORD PTR [rsp+0x8],rax
    1d4a:	mov    rcx,rax
    1d4d:	mov    r8d,0x3
    1d53:	mov    QWORD PTR [rsp+0x18],0x3
    1d5c:	mov    rdx,rbx
    1d5f:	mov    rsi,r12
    1d62:	mov    rdi,r14
    1d65:	call   1d6a <botlish_fn_21+0x92>
			1d66: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1d6a:	test   rax,rax
    1d6d:	jne    1d91 <botlish_fn_21+0xb9>
    1d73:	xor    rdx,rdx
    1d76:	mov    rax,rdx
    1d79:	mov    rbx,QWORD PTR [rsp+0x20]
    1d7e:	mov    r12,QWORD PTR [rsp+0x28]
    1d83:	mov    r14,QWORD PTR [rsp+0x30]
    1d88:	add    rsp,0x40
    1d8c:	mov    rsp,rbp
    1d8f:	pop    rbp
    1d90:	ret
    1d91:	mov    rbx,QWORD PTR [rsp+0x20]
    1d96:	mov    r12,QWORD PTR [rsp+0x28]
    1d9b:	mov    r14,QWORD PTR [rsp+0x30]
    1da0:	add    rsp,0x40
    1da4:	mov    rsp,rbp
    1da7:	pop    rbp
    1da8:	ret

0000000000001da9 <botlish_entry_21: scan_record<str, int>>:
    1da9:	push   rbp
    1daa:	mov    rbp,rsp
    1dad:	ud2
	...

0000000000001db0 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1db0:	push   rbp
    1db1:	mov    rbp,rsp
    1db4:	sub    rsp,0x60
    1db8:	mov    QWORD PTR [rsp+0x30],rbx
    1dbd:	mov    QWORD PTR [rsp+0x38],r12
    1dc2:	mov    QWORD PTR [rsp+0x40],r13
    1dc7:	mov    QWORD PTR [rsp+0x48],r14
    1dcc:	mov    QWORD PTR [rsp+0x50],r15
    1dd1:	mov    r13,rdi
    1dd4:	mov    QWORD PTR [rsp+0x20],0x0
    1ddd:	mov    QWORD PTR [rsp],rsi
    1de1:	mov    QWORD PTR [rsp+0x8],rdx
    1de6:	mov    r12,rdx
    1de9:	mov    QWORD PTR [rsp+0x10],rcx
    1dee:	mov    QWORD PTR [rsp+0x18],r8
    1df3:	mov    rbx,rsi
    1df6:	mov    r14,r8
    1df9:	mov    r15,rcx
    1dfc:	mov    rsi,rbx
    1dff:	mov    rdi,r13
    1e02:	call   1e07 <botlish_fn_22+0x57>
			1e03: R_X86_64_PLT32	rt_str_len-0x4
    1e07:	mov    rcx,r12
    1e0a:	and    rcx,rax
    1e0d:	mov    rdx,rax
    1e10:	test   rcx,0x1
    1e17:	jne    1e3d <botlish_fn_22+0x8d>
    1e1d:	mov    rsi,r12
    1e20:	mov    rdi,r13
    1e23:	call   1e28 <botlish_fn_22+0x78>
			1e24: R_X86_64_PLT32	rt_int_cmp-0x4
    1e28:	mov    ecx,0x2
    1e2d:	test   rax,rax
    1e30:	cmovge rcx,QWORD PTR [rip+0x128]        # 1f60 <botlish_fn_22+0x1b0>
    1e38:	jmp    1e4d <botlish_fn_22+0x9d>
    1e3d:	mov    ecx,0x2
    1e42:	cmp    r12,rdx
    1e45:	cmovge rcx,QWORD PTR [rip+0x113]        # 1f60 <botlish_fn_22+0x1b0>
    1e4d:	cmp    rcx,0x6
    1e51:	je     1efc <botlish_fn_22+0x14c>
    1e57:	mov    rdx,r12
    1e5a:	mov    rsi,rbx
    1e5d:	mov    rdi,r13
    1e60:	call   1e65 <botlish_fn_22+0xb5>
			1e61: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1e65:	test   rax,rax
    1e68:	je     1f13 <botlish_fn_22+0x163>
    1e6e:	mov    QWORD PTR [rsp+0x8],rax
    1e73:	mov    rcx,rax
    1e76:	mov    QWORD PTR [rsp+0x20],rdx
    1e7b:	mov    rsi,r15
    1e7e:	mov    r12,rdx
    1e81:	mov    rdx,r14
    1e84:	mov    rdi,r13
    1e87:	call   1e8c <botlish_fn_22+0xdc>
			1e88: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1e8c:	test   rax,rax
    1e8f:	je     1f13 <botlish_fn_22+0x163>
    1e95:	mov    QWORD PTR [rsp+0x8],rax
    1e9a:	mov    r15,rax
    1e9d:	mov    QWORD PTR [rsp+0x10],0x3
    1ea6:	mov    rsi,r14
    1ea9:	test   rsi,0x1
    1eb0:	je     1ecb <botlish_fn_22+0x11b>
    1eb6:	mov    rsi,r14
    1eb9:	mov    rax,rsi
    1ebc:	add    rax,0x2
    1ec0:	seto   cl
    1ec3:	test   cl,cl
    1ec5:	je     1edb <botlish_fn_22+0x12b>
    1ecb:	mov    edx,0x3
    1ed0:	mov    rsi,r14
    1ed3:	mov    rdi,r13
    1ed6:	call   1edb <botlish_fn_22+0x12b>
			1ed7: R_X86_64_PLT32	rt_int_add-0x4
    1edb:	mov    QWORD PTR [rsp],rbx
    1edf:	mov    rdx,r12
    1ee2:	mov    QWORD PTR [rsp+0x8],rdx
    1ee7:	mov    rcx,r15
    1eea:	mov    QWORD PTR [rsp+0x10],rcx
    1eef:	mov    QWORD PTR [rsp+0x18],rax
    1ef4:	mov    r14,rax
    1ef7:	jmp    1dfc <botlish_fn_22+0x4c>
    1efc:	mov    rdx,r14
    1eff:	mov    rsi,r15
    1f02:	mov    rdi,r13
    1f05:	call   1f0a <botlish_fn_22+0x15a>
			1f06: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1f0a:	test   rax,rax
    1f0d:	jne    1f38 <botlish_fn_22+0x188>
    1f13:	xor    rax,rax
    1f16:	mov    rbx,QWORD PTR [rsp+0x30]
    1f1b:	mov    r12,QWORD PTR [rsp+0x38]
    1f20:	mov    r13,QWORD PTR [rsp+0x40]
    1f25:	mov    r14,QWORD PTR [rsp+0x48]
    1f2a:	mov    r15,QWORD PTR [rsp+0x50]
    1f2f:	add    rsp,0x60
    1f33:	mov    rsp,rbp
    1f36:	pop    rbp
    1f37:	ret
    1f38:	mov    rbx,QWORD PTR [rsp+0x30]
    1f3d:	mov    r12,QWORD PTR [rsp+0x38]
    1f42:	mov    r13,QWORD PTR [rsp+0x40]
    1f47:	mov    r14,QWORD PTR [rsp+0x48]
    1f4c:	mov    r15,QWORD PTR [rsp+0x50]
    1f51:	add    rsp,0x60
    1f55:	mov    rsp,rbp
    1f58:	pop    rbp
    1f59:	ret
    1f5a:	add    BYTE PTR [rax],al
    1f5c:	add    BYTE PTR [rax],al
    1f5e:	add    BYTE PTR [rax],al
    1f60:	(bad)
    1f61:	add    BYTE PTR [rax],al
    1f63:	add    BYTE PTR [rax],al
    1f65:	add    BYTE PTR [rax],al
	...

0000000000001f68 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    1f68:	push   rbp
    1f69:	mov    rbp,rsp
    1f6c:	mov    rsi,QWORD PTR [rdx]
    1f6f:	mov    r9,QWORD PTR [rdx+0x8]
    1f73:	mov    rcx,QWORD PTR [rdx+0x10]
    1f77:	mov    r8,QWORD PTR [rdx+0x18]
    1f7b:	mov    rdx,r9
    1f7e:	call   1f83 <botlish_entry_22+0x1b>
			1f7f: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    1f83:	mov    rsp,rbp
    1f86:	pop    rbp
    1f87:	ret

0000000000001f88 <botlish_fn_23: csv_parse<str>>:
    1f88:	push   rbp
    1f89:	mov    rbp,rsp
    1f8c:	sub    rsp,0x40
    1f90:	mov    QWORD PTR [rsp+0x20],rbx
    1f95:	mov    QWORD PTR [rsp+0x28],r12
    1f9a:	mov    QWORD PTR [rsp+0x30],r13
    1f9f:	mov    rbx,rdi
    1fa2:	mov    QWORD PTR [rsp+0x8],0x0
    1fab:	mov    QWORD PTR [rsp+0x10],0x0
    1fb4:	mov    QWORD PTR [rsp+0x18],0x0
    1fbd:	mov    QWORD PTR [rsp],rsi
    1fc1:	mov    r12,rsi
    1fc4:	mov    rsi,r12
    1fc7:	mov    rdi,rbx
    1fca:	call   1fcf <botlish_fn_23+0x47>
			1fcb: R_X86_64_PLT32	rt_str_len-0x4
    1fcf:	sar    rax,1
    1fd2:	test   rax,rax
    1fd5:	je     2064 <botlish_fn_23+0xdc>
    1fdb:	mov    edx,0x1
    1fe0:	mov    QWORD PTR [rsp+0x8],0x1
    1fe9:	mov    rsi,r12
    1fec:	mov    rdi,rbx
    1fef:	call   1ff4 <botlish_fn_23+0x6c>
			1ff0: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1ff4:	test   rax,rax
    1ff7:	je     207b <botlish_fn_23+0xf3>
    1ffd:	mov    QWORD PTR [rsp+0x8],rax
    2002:	mov    rsi,rax
    2005:	mov    QWORD PTR [rsp+0x10],rdx
    200a:	mov    r13,rdx
    200d:	mov    rdi,rbx
    2010:	call   2015 <botlish_fn_23+0x8d>
			2011: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    2015:	test   rax,rax
    2018:	je     207b <botlish_fn_23+0xf3>
    201e:	mov    QWORD PTR [rsp+0x8],rax
    2023:	mov    rcx,rax
    2026:	mov    r8d,0x3
    202c:	mov    QWORD PTR [rsp+0x18],0x3
    2035:	mov    rdx,r13
    2038:	mov    rsi,r12
    203b:	mov    rdi,rbx
    203e:	call   2043 <botlish_fn_23+0xbb>
			203f: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    2043:	test   rax,rax
    2046:	je     207b <botlish_fn_23+0xf3>
    204c:	mov    rbx,QWORD PTR [rsp+0x20]
    2051:	mov    r12,QWORD PTR [rsp+0x28]
    2056:	mov    r13,QWORD PTR [rsp+0x30]
    205b:	add    rsp,0x40
    205f:	mov    rsp,rbp
    2062:	pop    rbp
    2063:	ret
    2064:	xor    rdx,rdx
    2067:	mov    rdi,rbx
    206a:	mov    rsi,rdx
    206d:	call   2072 <botlish_fn_23+0xea>
			206e: R_X86_64_PLT32	rt_list_new-0x4
    2072:	test   rax,rax
    2075:	jne    2096 <botlish_fn_23+0x10e>
    207b:	xor    rax,rax
    207e:	mov    rbx,QWORD PTR [rsp+0x20]
    2083:	mov    r12,QWORD PTR [rsp+0x28]
    2088:	mov    r13,QWORD PTR [rsp+0x30]
    208d:	add    rsp,0x40
    2091:	mov    rsp,rbp
    2094:	pop    rbp
    2095:	ret
    2096:	mov    rbx,QWORD PTR [rsp+0x20]
    209b:	mov    r12,QWORD PTR [rsp+0x28]
    20a0:	mov    r13,QWORD PTR [rsp+0x30]
    20a5:	add    rsp,0x40
    20a9:	mov    rsp,rbp
    20ac:	pop    rbp
    20ad:	ret

00000000000020ae <botlish_entry_23: csv_parse<str>>:
    20ae:	push   rbp
    20af:	mov    rbp,rsp
    20b2:	mov    rsi,QWORD PTR [rdx]
    20b5:	call   20ba <botlish_entry_23+0xc>
			20b6: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    20ba:	mov    rsp,rbp
    20bd:	pop    rbp
    20be:	ret
	...

00000000000020c0 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    20c0:	push   rbp
    20c1:	mov    rbp,rsp
    20c4:	sub    rsp,0x40
    20c8:	mov    QWORD PTR [rsp+0x20],rbx
    20cd:	mov    QWORD PTR [rsp+0x28],r12
    20d2:	mov    QWORD PTR [rsp+0x30],r13
    20d7:	mov    QWORD PTR [rsp+0x38],r14
    20dc:	mov    r13,rdi
    20df:	mov    QWORD PTR [rsp],rsi
    20e3:	mov    rbx,rsi
    20e6:	mov    QWORD PTR [rsp+0x8],rdx
    20eb:	mov    QWORD PTR [rsp+0x10],rcx
    20f0:	mov    r12,rcx
    20f3:	mov    rsi,rdx
    20f6:	mov    rax,rsi
    20f9:	and    rax,r12
    20fc:	mov    r14,rsi
    20ff:	test   rax,0x1
    2105:	jne    212e <botlish_fn_24+0x6e>
    210b:	mov    rdx,r12
    210e:	mov    rsi,r14
    2111:	mov    rdi,r13
    2114:	call   2119 <botlish_fn_24+0x59>
			2115: R_X86_64_PLT32	rt_int_cmp-0x4
    2119:	mov    ecx,0x2
    211e:	test   rax,rax
    2121:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2208 <botlish_fn_24+0x148>
    2129:	jmp    2141 <botlish_fn_24+0x81>
    212e:	mov    ecx,0x2
    2133:	mov    rsi,r14
    2136:	cmp    rsi,r12
    2139:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2208 <botlish_fn_24+0x148>
    2141:	cmp    rcx,0x6
    2145:	je     21e6 <botlish_fn_24+0x126>
    214b:	mov    ecx,0x1
    2150:	mov    rdx,r14
    2153:	mov    rsi,rbx
    2156:	mov    rdi,r13
    2159:	call   215e <botlish_fn_24+0x9e>
			215a: R_X86_64_PLT32	rt_mutarray_set-0x4
    215e:	test   rax,rax
    2161:	jne    2187 <botlish_fn_24+0xc7>
    2167:	xor    rax,rax
    216a:	mov    rbx,QWORD PTR [rsp+0x20]
    216f:	mov    r12,QWORD PTR [rsp+0x28]
    2174:	mov    r13,QWORD PTR [rsp+0x30]
    2179:	mov    r14,QWORD PTR [rsp+0x38]
    217e:	add    rsp,0x40
    2182:	mov    rsp,rbp
    2185:	pop    rbp
    2186:	ret
    2187:	mov    QWORD PTR [rsp+0x18],0x3
    2190:	mov    rsi,r14
    2193:	test   rsi,0x1
    219a:	je     21bd <botlish_fn_24+0xfd>
    21a0:	mov    rsi,r14
    21a3:	mov    rcx,rsi
    21a6:	add    rcx,0x2
    21aa:	seto   al
    21ad:	test   al,al
    21af:	jne    21bd <botlish_fn_24+0xfd>
    21b5:	mov    r14,rcx
    21b8:	jmp    21d0 <botlish_fn_24+0x110>
    21bd:	mov    edx,0x3
    21c2:	mov    rsi,r14
    21c5:	mov    rdi,r13
    21c8:	call   21cd <botlish_fn_24+0x10d>
			21c9: R_X86_64_PLT32	rt_int_add-0x4
    21cd:	mov    r14,rax
    21d0:	mov    QWORD PTR [rsp],rbx
    21d4:	mov    rsi,r14
    21d7:	mov    QWORD PTR [rsp+0x8],rsi
    21dc:	mov    QWORD PTR [rsp+0x10],r12
    21e1:	jmp    20f6 <botlish_fn_24+0x36>
    21e6:	mov    eax,0xa
    21eb:	mov    rbx,QWORD PTR [rsp+0x20]
    21f0:	mov    r12,QWORD PTR [rsp+0x28]
    21f5:	mov    r13,QWORD PTR [rsp+0x30]
    21fa:	mov    r14,QWORD PTR [rsp+0x38]
    21ff:	add    rsp,0x40
    2203:	mov    rsp,rbp
    2206:	pop    rbp
    2207:	ret
    2208:	(bad)
    2209:	add    BYTE PTR [rax],al
    220b:	add    BYTE PTR [rax],al
    220d:	add    BYTE PTR [rax],al
	...

0000000000002210 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    2210:	push   rbp
    2211:	mov    rbp,rsp
    2214:	mov    rsi,QWORD PTR [rdx]
    2217:	mov    r8,QWORD PTR [rdx+0x8]
    221b:	mov    rcx,QWORD PTR [rdx+0x10]
    221f:	mov    rdx,r8
    2222:	call   2227 <botlish_entry_24+0x17>
			2223: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    2227:	mov    rsp,rbp
    222a:	pop    rbp
    222b:	ret

000000000000222c <botlish_fn_25: ht_alloc<int>>:
    222c:	push   rbp
    222d:	mov    rbp,rsp
    2230:	sub    rsp,0x50
    2234:	mov    QWORD PTR [rsp+0x20],rbx
    2239:	mov    QWORD PTR [rsp+0x28],r12
    223e:	mov    QWORD PTR [rsp+0x30],r13
    2243:	mov    QWORD PTR [rsp+0x38],r14
    2248:	mov    QWORD PTR [rsp+0x40],r15
    224d:	mov    rbx,rdi
    2250:	mov    QWORD PTR [rsp+0x8],0x0
    2259:	mov    QWORD PTR [rsp+0x10],0x0
    2262:	mov    QWORD PTR [rsp+0x18],0x0
    226b:	mov    QWORD PTR [rsp],rsi
    226f:	mov    r13,rsi
    2272:	mov    rsi,r13
    2275:	mov    rdi,rbx
    2278:	call   227d <botlish_fn_25+0x51>
			2279: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    227d:	test   rax,rax
    2280:	je     239c <botlish_fn_25+0x170>
    2286:	mov    QWORD PTR [rsp+0x8],rax
    228b:	mov    r12,rax
    228e:	mov    edx,0x1
    2293:	mov    QWORD PTR [rsp+0x10],0x1
    229c:	mov    rcx,r13
    229f:	mov    rsi,r12
    22a2:	mov    rdi,rbx
    22a5:	call   22aa <botlish_fn_25+0x7e>
			22a6: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    22aa:	test   rax,rax
    22ad:	je     239c <botlish_fn_25+0x170>
    22b3:	mov    rsi,r13
    22b6:	mov    rdi,rbx
    22b9:	call   22be <botlish_fn_25+0x92>
			22ba: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22be:	test   rax,rax
    22c1:	je     239c <botlish_fn_25+0x170>
    22c7:	mov    QWORD PTR [rsp+0x10],rax
    22cc:	mov    rsi,r13
    22cf:	mov    r14,rax
    22d2:	mov    rdi,rbx
    22d5:	call   22da <botlish_fn_25+0xae>
			22d6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22da:	test   rax,rax
    22dd:	je     239c <botlish_fn_25+0x170>
    22e3:	mov    QWORD PTR [rsp],rax
    22e7:	mov    r13,rax
    22ea:	mov    esi,0xb
    22ef:	mov    QWORD PTR [rsp+0x18],0xb
    22f8:	mov    rdi,rbx
    22fb:	call   2300 <botlish_fn_25+0xd4>
			22fc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2300:	test   rax,rax
    2303:	mov    r15,rax
    2306:	je     239c <botlish_fn_25+0x170>
    230c:	mov    edx,0x1
    2311:	mov    rcx,r12
    2314:	mov    rsi,r15
    2317:	mov    rdi,rbx
    231a:	call   231f <botlish_fn_25+0xf3>
			231b: R_X86_64_PLT32	rt_mutarray_set-0x4
    231f:	test   rax,rax
    2322:	je     239c <botlish_fn_25+0x170>
    2328:	mov    edx,0x3
    232d:	mov    rcx,r14
    2330:	mov    rsi,r15
    2333:	mov    rdi,rbx
    2336:	call   233b <botlish_fn_25+0x10f>
			2337: R_X86_64_PLT32	rt_mutarray_set-0x4
    233b:	test   rax,rax
    233e:	je     239c <botlish_fn_25+0x170>
    2344:	mov    edx,0x5
    2349:	mov    rcx,r13
    234c:	mov    rsi,r15
    234f:	mov    rdi,rbx
    2352:	call   2357 <botlish_fn_25+0x12b>
			2353: R_X86_64_PLT32	rt_mutarray_set-0x4
    2357:	test   rax,rax
    235a:	je     239c <botlish_fn_25+0x170>
    2360:	mov    edx,0x7
    2365:	mov    ecx,0x1
    236a:	mov    rsi,r15
    236d:	mov    rdi,rbx
    2370:	call   2375 <botlish_fn_25+0x149>
			2371: R_X86_64_PLT32	rt_mutarray_set-0x4
    2375:	test   rax,rax
    2378:	je     239c <botlish_fn_25+0x170>
    237e:	mov    edx,0x9
    2383:	mov    ecx,0x1
    2388:	mov    rdi,rbx
    238b:	mov    rsi,r15
    238e:	call   2393 <botlish_fn_25+0x167>
			238f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2393:	test   rax,rax
    2396:	jne    23c1 <botlish_fn_25+0x195>
    239c:	xor    rax,rax
    239f:	mov    rbx,QWORD PTR [rsp+0x20]
    23a4:	mov    r12,QWORD PTR [rsp+0x28]
    23a9:	mov    r13,QWORD PTR [rsp+0x30]
    23ae:	mov    r14,QWORD PTR [rsp+0x38]
    23b3:	mov    r15,QWORD PTR [rsp+0x40]
    23b8:	add    rsp,0x50
    23bc:	mov    rsp,rbp
    23bf:	pop    rbp
    23c0:	ret
    23c1:	mov    rax,r15
    23c4:	mov    rbx,QWORD PTR [rsp+0x20]
    23c9:	mov    r12,QWORD PTR [rsp+0x28]
    23ce:	mov    r13,QWORD PTR [rsp+0x30]
    23d3:	mov    r14,QWORD PTR [rsp+0x38]
    23d8:	mov    r15,QWORD PTR [rsp+0x40]
    23dd:	add    rsp,0x50
    23e1:	mov    rsp,rbp
    23e4:	pop    rbp
    23e5:	ret

00000000000023e6 <botlish_entry_25: ht_alloc<int>>:
    23e6:	push   rbp
    23e7:	mov    rbp,rsp
    23ea:	mov    rsi,QWORD PTR [rdx]
    23ed:	call   23f2 <botlish_entry_25+0xc>
			23ee: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    23f2:	mov    rsp,rbp
    23f5:	pop    rbp
    23f6:	ret

00000000000023f7 <botlish_fn_26: ht_new<generic>>:
    23f7:	push   rbp
    23f8:	mov    rbp,rsp
    23fb:	sub    rsp,0x10
    23ff:	mov    esi,0x11
    2404:	mov    QWORD PTR [rsp],0x11
    240c:	call   2411 <botlish_fn_26+0x1a>
			240d: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2411:	test   rax,rax
    2414:	jne    2426 <botlish_fn_26+0x2f>
    241a:	xor    rax,rax
    241d:	add    rsp,0x10
    2421:	mov    rsp,rbp
    2424:	pop    rbp
    2425:	ret
    2426:	add    rsp,0x10
    242a:	mov    rsp,rbp
    242d:	pop    rbp
    242e:	ret

000000000000242f <botlish_entry_26: ht_new<generic>>:
    242f:	push   rbp
    2430:	mov    rbp,rsp
    2433:	call   2438 <botlish_entry_26+0x9>
			2434: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    2438:	mov    rsp,rbp
    243b:	pop    rbp
    243c:	ret
    243d:	add    BYTE PTR [rax],al
	...

0000000000002440 <botlish_fn_27: ht_capacity_for<int, int>>:
    2440:	push   rbp
    2441:	mov    rbp,rsp
    2444:	sub    rsp,0x50
    2448:	mov    QWORD PTR [rsp+0x20],rbx
    244d:	mov    QWORD PTR [rsp+0x28],r12
    2452:	mov    QWORD PTR [rsp+0x30],r13
    2457:	mov    QWORD PTR [rsp+0x38],r14
    245c:	mov    QWORD PTR [rsp+0x40],r15
    2461:	mov    r13,rdi
    2464:	mov    QWORD PTR [rsp],rdx
    2468:	mov    rbx,rsi
    246b:	or     rbx,0x1
    246f:	sar    rbx,1
    2472:	mov    r12,rsi
    2475:	mov    r14,rdx
    2478:	mov    rax,r12
    247b:	or     rax,0x1
    247f:	mov    QWORD PTR [rsp+0x8],rax
    2484:	mov    QWORD PTR [rsp+0x10],0x7
    248d:	mov    rax,rbx
    2490:	imul   QWORD PTR [rip+0x159]        # 25f0 <botlish_fn_27+0x1b0>
    2497:	seto   cl
    249a:	or     rax,0x1
    249e:	test   cl,cl
    24a0:	jne    24ae <botlish_fn_27+0x6e>
    24a6:	mov    rsi,rax
    24a9:	jmp    24c5 <botlish_fn_27+0x85>
    24ae:	mov    rsi,r12
    24b1:	or     rsi,0x1
    24b5:	mov    edx,0x7
    24ba:	mov    rdi,r13
    24bd:	call   24c2 <botlish_fn_27+0x82>
			24be: R_X86_64_PLT32	rt_int_mul-0x4
    24c2:	mov    rsi,rax
    24c5:	mov    QWORD PTR [rsp+0x8],rsi
    24ca:	mov    r15,rsi
    24cd:	mov    QWORD PTR [rsp+0x10],0x5
    24d6:	mov    rsi,r14
    24d9:	test   rsi,0x1
    24e0:	je     2510 <botlish_fn_27+0xd0>
    24e6:	mov    rsi,r14
    24e9:	mov    rax,rsi
    24ec:	sar    rax,1
    24ef:	imul   QWORD PTR [rip+0x102]        # 25f8 <botlish_fn_27+0x1b8>
    24f6:	seto   cl
    24f9:	or     rax,0x1
    24fd:	test   cl,cl
    24ff:	jne    2510 <botlish_fn_27+0xd0>
    2505:	mov    rdx,rax
    2508:	mov    rsi,r15
    250b:	jmp    2526 <botlish_fn_27+0xe6>
    2510:	mov    edx,0x5
    2515:	mov    rsi,r14
    2518:	mov    rdi,r13
    251b:	call   2520 <botlish_fn_27+0xe0>
			251c: R_X86_64_PLT32	rt_int_mul-0x4
    2520:	mov    rdx,rax
    2523:	mov    rsi,r15
    2526:	mov    rax,rsi
    2529:	and    rax,rdx
    252c:	test   rax,0x1
    2532:	jne    2555 <botlish_fn_27+0x115>
    2538:	mov    rdi,r13
    253b:	call   2540 <botlish_fn_27+0x100>
			253c: R_X86_64_PLT32	rt_int_cmp-0x4
    2540:	mov    ecx,0x2
    2545:	test   rax,rax
    2548:	cmovle rcx,QWORD PTR [rip+0xa0]        # 25f0 <botlish_fn_27+0x1b0>
    2550:	jmp    2565 <botlish_fn_27+0x125>
    2555:	mov    ecx,0x2
    255a:	cmp    rsi,rdx
    255d:	cmovle rcx,QWORD PTR [rip+0x8b]        # 25f0 <botlish_fn_27+0x1b0>
    2565:	cmp    rcx,0x6
    2569:	je     25c5 <botlish_fn_27+0x185>
    256f:	mov    QWORD PTR [rsp+0x8],0x5
    2578:	mov    rsi,r14
    257b:	test   rsi,0x1
    2582:	je     25a9 <botlish_fn_27+0x169>
    2588:	mov    rsi,r14
    258b:	mov    rax,rsi
    258e:	sar    rax,1
    2591:	imul   QWORD PTR [rip+0x60]        # 25f8 <botlish_fn_27+0x1b8>
    2598:	seto   sil
    259c:	or     rax,0x1
    25a0:	test   sil,sil
    25a3:	je     25b9 <botlish_fn_27+0x179>
    25a9:	mov    edx,0x5
    25ae:	mov    rsi,r14
    25b1:	mov    rdi,r13
    25b4:	call   25b9 <botlish_fn_27+0x179>
			25b5: R_X86_64_PLT32	rt_int_mul-0x4
    25b9:	mov    QWORD PTR [rsp],rax
    25bd:	mov    r14,rax
    25c0:	jmp    2478 <botlish_fn_27+0x38>
    25c5:	mov    rax,r14
    25c8:	mov    rbx,QWORD PTR [rsp+0x20]
    25cd:	mov    r12,QWORD PTR [rsp+0x28]
    25d2:	mov    r13,QWORD PTR [rsp+0x30]
    25d7:	mov    r14,QWORD PTR [rsp+0x38]
    25dc:	mov    r15,QWORD PTR [rsp+0x40]
    25e1:	add    rsp,0x50
    25e5:	mov    rsp,rbp
    25e8:	pop    rbp
    25e9:	ret
    25ea:	add    BYTE PTR [rax],al
    25ec:	add    BYTE PTR [rax],al
    25ee:	add    BYTE PTR [rax],al
    25f0:	(bad)
    25f1:	add    BYTE PTR [rax],al
    25f3:	add    BYTE PTR [rax],al
    25f5:	add    BYTE PTR [rax],al
    25f7:	add    BYTE PTR [rax+rax*1],al
    25fa:	add    BYTE PTR [rax],al
    25fc:	add    BYTE PTR [rax],al
	...

0000000000002600 <botlish_entry_27: ht_capacity_for<int, int>>:
    2600:	push   rbp
    2601:	mov    rbp,rsp
    2604:	mov    rsi,QWORD PTR [rdx]
    2607:	mov    rdx,QWORD PTR [rdx+0x8]
    260b:	call   2610 <botlish_entry_27+0x10>
			260c: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2610:	mov    rsp,rbp
    2613:	pop    rbp
    2614:	ret

0000000000002615 <botlish_fn_28: ht_new_sized<int>>:
    2615:	push   rbp
    2616:	mov    rbp,rsp
    2619:	sub    rsp,0x20
    261d:	mov    QWORD PTR [rsp+0x10],r12
    2622:	mov    r12,rdi
    2625:	mov    QWORD PTR [rsp],rsi
    2629:	mov    edx,0x11
    262e:	mov    QWORD PTR [rsp+0x8],0x11
    2637:	mov    rdi,r12
    263a:	call   263f <botlish_fn_28+0x2a>
			263b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    263f:	mov    QWORD PTR [rsp],rax
    2643:	mov    rsi,rax
    2646:	mov    rdi,r12
    2649:	call   264e <botlish_fn_28+0x39>
			264a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    264e:	test   rax,rax
    2651:	jne    2668 <botlish_fn_28+0x53>
    2657:	xor    rax,rax
    265a:	mov    r12,QWORD PTR [rsp+0x10]
    265f:	add    rsp,0x20
    2663:	mov    rsp,rbp
    2666:	pop    rbp
    2667:	ret
    2668:	mov    r12,QWORD PTR [rsp+0x10]
    266d:	add    rsp,0x20
    2671:	mov    rsp,rbp
    2674:	pop    rbp
    2675:	ret

0000000000002676 <botlish_entry_28: ht_new_sized<int>>:
    2676:	push   rbp
    2677:	mov    rbp,rsp
    267a:	mov    rsi,QWORD PTR [rdx]
    267d:	call   2682 <botlish_entry_28+0xc>
			267e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    2682:	mov    rsp,rbp
    2685:	pop    rbp
    2686:	ret

0000000000002687 <botlish_fn_29: ht_controls<mutarray>>:
    2687:	push   rbp
    2688:	mov    rbp,rsp
    268b:	mov    edx,0x1
    2690:	call   2695 <botlish_fn_29+0xe>
			2691: R_X86_64_PLT32	rt_mutarray_get-0x4
    2695:	test   rax,rax
    2698:	jne    26a6 <botlish_fn_29+0x1f>
    269e:	xor    rax,rax
    26a1:	mov    rsp,rbp
    26a4:	pop    rbp
    26a5:	ret
    26a6:	mov    rsp,rbp
    26a9:	pop    rbp
    26aa:	ret

00000000000026ab <botlish_entry_29: ht_controls<mutarray>>:
    26ab:	push   rbp
    26ac:	mov    rbp,rsp
    26af:	mov    rsi,QWORD PTR [rdx]
    26b2:	call   26b7 <botlish_entry_29+0xc>
			26b3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    26b7:	mov    rsp,rbp
    26ba:	pop    rbp
    26bb:	ret

00000000000026bc <botlish_fn_30: ht_keys<mutarray>>:
    26bc:	push   rbp
    26bd:	mov    rbp,rsp
    26c0:	mov    edx,0x3
    26c5:	call   26ca <botlish_fn_30+0xe>
			26c6: R_X86_64_PLT32	rt_mutarray_get-0x4
    26ca:	test   rax,rax
    26cd:	jne    26db <botlish_fn_30+0x1f>
    26d3:	xor    rax,rax
    26d6:	mov    rsp,rbp
    26d9:	pop    rbp
    26da:	ret
    26db:	mov    rsp,rbp
    26de:	pop    rbp
    26df:	ret

00000000000026e0 <botlish_entry_30: ht_keys<mutarray>>:
    26e0:	push   rbp
    26e1:	mov    rbp,rsp
    26e4:	mov    rsi,QWORD PTR [rdx]
    26e7:	call   26ec <botlish_entry_30+0xc>
			26e8: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    26ec:	mov    rsp,rbp
    26ef:	pop    rbp
    26f0:	ret

00000000000026f1 <botlish_fn_31: ht_values<mutarray>>:
    26f1:	push   rbp
    26f2:	mov    rbp,rsp
    26f5:	mov    edx,0x5
    26fa:	call   26ff <botlish_fn_31+0xe>
			26fb: R_X86_64_PLT32	rt_mutarray_get-0x4
    26ff:	test   rax,rax
    2702:	jne    2710 <botlish_fn_31+0x1f>
    2708:	xor    rax,rax
    270b:	mov    rsp,rbp
    270e:	pop    rbp
    270f:	ret
    2710:	mov    rsp,rbp
    2713:	pop    rbp
    2714:	ret

0000000000002715 <botlish_entry_31: ht_values<mutarray>>:
    2715:	push   rbp
    2716:	mov    rbp,rsp
    2719:	mov    rsi,QWORD PTR [rdx]
    271c:	call   2721 <botlish_entry_31+0xc>
			271d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    2721:	mov    rsp,rbp
    2724:	pop    rbp
    2725:	ret

0000000000002726 <botlish_fn_32: ht_size<mutarray>>:
    2726:	push   rbp
    2727:	mov    rbp,rsp
    272a:	mov    edx,0x7
    272f:	call   2734 <botlish_fn_32+0xe>
			2730: R_X86_64_PLT32	rt_mutarray_get-0x4
    2734:	test   rax,rax
    2737:	jne    2745 <botlish_fn_32+0x1f>
    273d:	xor    rax,rax
    2740:	mov    rsp,rbp
    2743:	pop    rbp
    2744:	ret
    2745:	mov    rsp,rbp
    2748:	pop    rbp
    2749:	ret

000000000000274a <botlish_entry_32: ht_size<mutarray>>:
    274a:	push   rbp
    274b:	mov    rbp,rsp
    274e:	mov    rsi,QWORD PTR [rdx]
    2751:	call   2756 <botlish_entry_32+0xc>
			2752: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    2756:	mov    rsp,rbp
    2759:	pop    rbp
    275a:	ret

000000000000275b <botlish_fn_33: ht_tombstones<mutarray>>:
    275b:	push   rbp
    275c:	mov    rbp,rsp
    275f:	mov    edx,0x9
    2764:	call   2769 <botlish_fn_33+0xe>
			2765: R_X86_64_PLT32	rt_mutarray_get-0x4
    2769:	test   rax,rax
    276c:	jne    277a <botlish_fn_33+0x1f>
    2772:	xor    rax,rax
    2775:	mov    rsp,rbp
    2778:	pop    rbp
    2779:	ret
    277a:	mov    rsp,rbp
    277d:	pop    rbp
    277e:	ret

000000000000277f <botlish_entry_33: ht_tombstones<mutarray>>:
    277f:	push   rbp
    2780:	mov    rbp,rsp
    2783:	mov    rsi,QWORD PTR [rdx]
    2786:	call   278b <botlish_entry_33+0xc>
			2787: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    278b:	mov    rsp,rbp
    278e:	pop    rbp
    278f:	ret

0000000000002790 <botlish_fn_34: ht_capacity<mutarray>>:
    2790:	push   rbp
    2791:	mov    rbp,rsp
    2794:	sub    rsp,0x10
    2798:	mov    QWORD PTR [rsp],rbx
    279c:	mov    rbx,rdi
    279f:	mov    rdi,rbx
    27a2:	call   27a7 <botlish_fn_34+0x17>
			27a3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    27a7:	test   rax,rax
    27aa:	je     27f4 <botlish_fn_34+0x64>
    27b0:	xor    r8d,r8d
    27b3:	test   rax,0x7
    27b9:	je     27c7 <botlish_fn_34+0x37>
    27bf:	mov    rsi,rax
    27c2:	jmp    27d6 <botlish_fn_34+0x46>
    27c7:	movzx  rcx,BYTE PTR [rax]
    27cb:	mov    rsi,rax
    27ce:	rex cmp cl,0x8
    27d2:	sete   r8b
    27d6:	test   r8b,r8b
    27d9:	jne    2804 <botlish_fn_34+0x74>
    27df:	mov    rdi,rbx
    27e2:	mov    rax,QWORD PTR [rdi+0x10]
    27e6:	mov    rcx,QWORD PTR [rax+0x28]
    27ea:	mov    edx,0x8
    27ef:	call   27f4 <botlish_fn_34+0x64>
			27f0: R_X86_64_PLT32	rt_type_error-0x4
    27f4:	xor    rax,rax
    27f7:	mov    rbx,QWORD PTR [rsp]
    27fb:	add    rsp,0x10
    27ff:	mov    rsp,rbp
    2802:	pop    rbp
    2803:	ret
    2804:	mov    rdi,rbx
    2807:	call   280c <botlish_fn_34+0x7c>
			2808: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    280c:	mov    rbx,QWORD PTR [rsp]
    2810:	add    rsp,0x10
    2814:	mov    rsp,rbp
    2817:	pop    rbp
    2818:	ret

0000000000002819 <botlish_entry_34: ht_capacity<mutarray>>:
    2819:	push   rbp
    281a:	mov    rbp,rsp
    281d:	mov    rsi,QWORD PTR [rdx]
    2820:	call   2825 <botlish_entry_34+0xc>
			2821: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2825:	mov    rsp,rbp
    2828:	pop    rbp
    2829:	ret

000000000000282a <botlish_fn_35: ht_probe_start<mutarray, str>>:
    282a:	push   rbp
    282b:	mov    rbp,rsp
    282e:	sub    rsp,0x20
    2832:	mov    QWORD PTR [rsp],r12
    2836:	mov    QWORD PTR [rsp+0x8],r13
    283b:	mov    QWORD PTR [rsp+0x10],r14
    2840:	mov    r12,rdi
    2843:	mov    r14,rsi
    2846:	mov    rsi,rdx
    2849:	mov    rdi,r12
    284c:	call   2851 <botlish_fn_35+0x27>
			284d: R_X86_64_PLT32	rt_hash-0x4
    2851:	test   rax,rax
    2854:	mov    r13,rax
    2857:	je     2888 <botlish_fn_35+0x5e>
    285d:	mov    rsi,r14
    2860:	mov    rdi,r12
    2863:	call   2868 <botlish_fn_35+0x3e>
			2864: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2868:	test   rax,rax
    286b:	mov    rdx,rax
    286e:	je     2888 <botlish_fn_35+0x5e>
    2874:	mov    rsi,r13
    2877:	mov    rdi,r12
    287a:	call   287f <botlish_fn_35+0x55>
			287b: R_X86_64_PLT32	rt_int_mod-0x4
    287f:	test   rax,rax
    2882:	jne    28a2 <botlish_fn_35+0x78>
    2888:	xor    rax,rax
    288b:	mov    r12,QWORD PTR [rsp]
    288f:	mov    r13,QWORD PTR [rsp+0x8]
    2894:	mov    r14,QWORD PTR [rsp+0x10]
    2899:	add    rsp,0x20
    289d:	mov    rsp,rbp
    28a0:	pop    rbp
    28a1:	ret
    28a2:	mov    r12,QWORD PTR [rsp]
    28a6:	mov    r13,QWORD PTR [rsp+0x8]
    28ab:	mov    r14,QWORD PTR [rsp+0x10]
    28b0:	add    rsp,0x20
    28b4:	mov    rsp,rbp
    28b7:	pop    rbp
    28b8:	ret

00000000000028b9 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    28b9:	push   rbp
    28ba:	mov    rbp,rsp
    28bd:	mov    rsi,QWORD PTR [rdx]
    28c0:	mov    rdx,QWORD PTR [rdx+0x8]
    28c4:	call   28c9 <botlish_entry_35+0x10>
			28c5: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    28c9:	mov    rsp,rbp
    28cc:	pop    rbp
    28cd:	ret

00000000000028ce <botlish_fn_36: ht_probe_next<mutarray, int>>:
    28ce:	push   rbp
    28cf:	mov    rbp,rsp
    28d2:	sub    rsp,0x40
    28d6:	mov    QWORD PTR [rsp+0x20],rbx
    28db:	mov    QWORD PTR [rsp+0x28],r12
    28e0:	mov    QWORD PTR [rsp+0x30],r13
    28e5:	mov    r13,rdi
    28e8:	mov    QWORD PTR [rsp],rsi
    28ec:	mov    rbx,rsi
    28ef:	mov    QWORD PTR [rsp+0x8],rdx
    28f4:	mov    QWORD PTR [rsp+0x10],0x3
    28fd:	test   rdx,0x1
    2904:	jne    2912 <botlish_fn_36+0x44>
    290a:	mov    rsi,rdx
    290d:	jmp    2932 <botlish_fn_36+0x64>
    2912:	mov    rsi,rdx
    2915:	add    rsi,0x2
    2919:	mov    r12,rsi
    291c:	mov    rsi,rdx
    291f:	seto   al
    2922:	test   al,al
    2924:	jne    2932 <botlish_fn_36+0x64>
    292a:	mov    rsi,rbx
    292d:	jmp    2945 <botlish_fn_36+0x77>
    2932:	mov    edx,0x3
    2937:	mov    rdi,r13
    293a:	call   293f <botlish_fn_36+0x71>
			293b: R_X86_64_PLT32	rt_int_add-0x4
    293f:	mov    rsi,rbx
    2942:	mov    r12,rax
    2945:	mov    rdi,r13
    2948:	call   294d <botlish_fn_36+0x7f>
			2949: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    294d:	test   rax,rax
    2950:	mov    rdx,rax
    2953:	je     296d <botlish_fn_36+0x9f>
    2959:	mov    rsi,r12
    295c:	mov    rdi,r13
    295f:	call   2964 <botlish_fn_36+0x96>
			2960: R_X86_64_PLT32	rt_int_mod-0x4
    2964:	test   rax,rax
    2967:	jne    2988 <botlish_fn_36+0xba>
    296d:	xor    rax,rax
    2970:	mov    rbx,QWORD PTR [rsp+0x20]
    2975:	mov    r12,QWORD PTR [rsp+0x28]
    297a:	mov    r13,QWORD PTR [rsp+0x30]
    297f:	add    rsp,0x40
    2983:	mov    rsp,rbp
    2986:	pop    rbp
    2987:	ret
    2988:	mov    rbx,QWORD PTR [rsp+0x20]
    298d:	mov    r12,QWORD PTR [rsp+0x28]
    2992:	mov    r13,QWORD PTR [rsp+0x30]
    2997:	add    rsp,0x40
    299b:	mov    rsp,rbp
    299e:	pop    rbp
    299f:	ret

00000000000029a0 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    29a0:	push   rbp
    29a1:	mov    rbp,rsp
    29a4:	mov    rsi,QWORD PTR [rdx]
    29a7:	mov    rdx,QWORD PTR [rdx+0x8]
    29ab:	call   29b0 <botlish_entry_36+0x10>
			29ac: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    29b0:	mov    rsp,rbp
    29b3:	pop    rbp
    29b4:	ret
    29b5:	add    BYTE PTR [rax],al
	...

00000000000029b8 <botlish_fn_37: ht_find_get<mutarray, str, int>>:
    29b8:	push   rbp
    29b9:	mov    rbp,rsp
    29bc:	sub    rsp,0x50
    29c0:	mov    QWORD PTR [rsp+0x20],rbx
    29c5:	mov    QWORD PTR [rsp+0x28],r12
    29ca:	mov    QWORD PTR [rsp+0x30],r13
    29cf:	mov    QWORD PTR [rsp+0x38],r14
    29d4:	mov    QWORD PTR [rsp+0x40],r15
    29d9:	mov    r14,rdi
    29dc:	mov    QWORD PTR [rsp],rsi
    29e0:	mov    QWORD PTR [rsp+0x8],rdx
    29e5:	mov    r13,rdx
    29e8:	mov    QWORD PTR [rsp+0x10],rcx
    29ed:	mov    r12,rsi
    29f0:	mov    r15,rcx
    29f3:	mov    rsi,r12
    29f6:	mov    rdi,r14
    29f9:	call   29fe <botlish_fn_37+0x46>
			29fa: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    29fe:	test   rax,rax
    2a01:	je     2c00 <botlish_fn_37+0x248>
    2a07:	xor    ecx,ecx
    2a09:	test   rax,0x7
    2a0f:	je     2a1d <botlish_fn_37+0x65>
    2a15:	mov    rsi,rax
    2a18:	jmp    2a2b <botlish_fn_37+0x73>
    2a1d:	movzx  rcx,BYTE PTR [rax]
    2a21:	mov    rsi,rax
    2a24:	rex cmp cl,0x8
    2a28:	sete   cl
    2a2b:	test   cl,cl
    2a2d:	jne    2a4d <botlish_fn_37+0x95>
    2a33:	mov    rdi,r14
    2a36:	mov    rdx,QWORD PTR [rdi+0x10]
    2a3a:	mov    rcx,QWORD PTR [rdx+0x30]
    2a3e:	mov    edx,0x8
    2a43:	call   2a48 <botlish_fn_37+0x90>
			2a44: R_X86_64_PLT32	rt_type_error-0x4
    2a48:	jmp    2c00 <botlish_fn_37+0x248>
    2a4d:	mov    rdx,r15
    2a50:	mov    rdi,r14
    2a53:	call   2a58 <botlish_fn_37+0xa0>
			2a54: R_X86_64_PLT32	rt_mutarray_get-0x4
    2a58:	mov    rcx,rax
    2a5b:	mov    QWORD PTR [rsp+0x18],rax
    2a60:	test   rax,rcx
    2a63:	je     2c00 <botlish_fn_37+0x248>
    2a69:	mov    rax,QWORD PTR [rsp+0x18]
    2a6e:	test   rax,0x1
    2a74:	jne    2a9f <botlish_fn_37+0xe7>
    2a7a:	mov    edx,0x1
    2a7f:	mov    rsi,QWORD PTR [rsp+0x18]
    2a84:	mov    rdi,r14
    2a87:	call   2a8c <botlish_fn_37+0xd4>
			2a88: R_X86_64_PLT32	rt_value_eq-0x4
    2a8c:	test   rax,rax
    2a8f:	je     2c00 <botlish_fn_37+0x248>
    2a95:	mov    rcx,QWORD PTR [rsp+0x18]
    2a9a:	jmp    2ab5 <botlish_fn_37+0xfd>
    2a9f:	mov    eax,0x2
    2aa4:	mov    rcx,QWORD PTR [rsp+0x18]
    2aa9:	cmp    rcx,0x1
    2aad:	cmove  rax,QWORD PTR [rip+0x1db]        # 2c90 <botlish_fn_37+0x2d8>
    2ab5:	mov    ebx,0x6
    2aba:	cmp    rax,0x6
    2abe:	je     2c60 <botlish_fn_37+0x2a8>
    2ac4:	test   rcx,0x1
    2acb:	mov    QWORD PTR [rsp+0x18],rcx
    2ad0:	jne    2af6 <botlish_fn_37+0x13e>
    2ad6:	mov    edx,0x3
    2adb:	mov    rsi,QWORD PTR [rsp+0x18]
    2ae0:	mov    rdi,r14
    2ae3:	call   2ae8 <botlish_fn_37+0x130>
			2ae4: R_X86_64_PLT32	rt_value_eq-0x4
    2ae8:	test   rax,rax
    2aeb:	je     2c00 <botlish_fn_37+0x248>
    2af1:	jmp    2b0c <botlish_fn_37+0x154>
    2af6:	mov    rsi,QWORD PTR [rsp+0x18]
    2afb:	mov    eax,0x2
    2b00:	cmp    rsi,0x3
    2b04:	cmove  rax,QWORD PTR [rip+0x184]        # 2c90 <botlish_fn_37+0x2d8>
    2b0c:	cmp    rax,0x6
    2b10:	je     2b20 <botlish_fn_37+0x168>
    2b16:	mov    ebx,0x2
    2b1b:	jmp    2bdf <botlish_fn_37+0x227>
    2b20:	mov    rsi,r12
    2b23:	mov    rdi,r14
    2b26:	call   2b2b <botlish_fn_37+0x173>
			2b27: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2b2b:	test   rax,rax
    2b2e:	je     2c00 <botlish_fn_37+0x248>
    2b34:	xor    r10d,r10d
    2b37:	test   rax,0x7
    2b3d:	je     2b4b <botlish_fn_37+0x193>
    2b43:	mov    rsi,rax
    2b46:	jmp    2b5a <botlish_fn_37+0x1a2>
    2b4b:	movzx  rcx,BYTE PTR [rax]
    2b4f:	mov    rsi,rax
    2b52:	rex cmp cl,0x8
    2b56:	sete   r10b
    2b5a:	test   r10b,r10b
    2b5d:	jne    2b7d <botlish_fn_37+0x1c5>
    2b63:	mov    rdi,r14
    2b66:	mov    rax,QWORD PTR [rdi+0x10]
    2b6a:	mov    rcx,QWORD PTR [rax+0x30]
    2b6e:	mov    edx,0x8
    2b73:	call   2b78 <botlish_fn_37+0x1c0>
			2b74: R_X86_64_PLT32	rt_type_error-0x4
    2b78:	jmp    2c00 <botlish_fn_37+0x248>
    2b7d:	mov    rdx,r15
    2b80:	mov    rdi,r14
    2b83:	call   2b88 <botlish_fn_37+0x1d0>
			2b84: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b88:	test   rax,rax
    2b8b:	je     2c00 <botlish_fn_37+0x248>
    2b91:	mov    rcx,rax
    2b94:	and    rcx,r13
    2b97:	mov    rsi,rax
    2b9a:	test   rcx,0x1
    2ba1:	jne    2bc0 <botlish_fn_37+0x208>
    2ba7:	mov    rdx,r13
    2baa:	mov    rdi,r14
    2bad:	call   2bb2 <botlish_fn_37+0x1fa>
			2bae: R_X86_64_PLT32	rt_value_eq-0x4
    2bb2:	test   rax,rax
    2bb5:	je     2c00 <botlish_fn_37+0x248>
    2bbb:	jmp    2bd0 <botlish_fn_37+0x218>
    2bc0:	mov    eax,0x2
    2bc5:	cmp    rsi,r13
    2bc8:	cmove  rax,QWORD PTR [rip+0xc0]        # 2c90 <botlish_fn_37+0x2d8>
    2bd0:	cmp    rax,0x6
    2bd4:	je     2bdf <botlish_fn_37+0x227>
    2bda:	mov    ebx,0x2
    2bdf:	cmp    rbx,0x6
    2be3:	je     2c3b <botlish_fn_37+0x283>
    2be9:	mov    rdx,r15
    2bec:	mov    rsi,r12
    2bef:	mov    rdi,r14
    2bf2:	call   2bf7 <botlish_fn_37+0x23f>
			2bf3: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2bf7:	test   rax,rax
    2bfa:	jne    2c25 <botlish_fn_37+0x26d>
    2c00:	xor    rax,rax
    2c03:	mov    rbx,QWORD PTR [rsp+0x20]
    2c08:	mov    r12,QWORD PTR [rsp+0x28]
    2c0d:	mov    r13,QWORD PTR [rsp+0x30]
    2c12:	mov    r14,QWORD PTR [rsp+0x38]
    2c17:	mov    r15,QWORD PTR [rsp+0x40]
    2c1c:	add    rsp,0x50
    2c20:	mov    rsp,rbp
    2c23:	pop    rbp
    2c24:	ret
    2c25:	mov    QWORD PTR [rsp],r12
    2c29:	mov    QWORD PTR [rsp+0x8],r13
    2c2e:	mov    QWORD PTR [rsp+0x10],rax
    2c33:	mov    r15,rax
    2c36:	jmp    29f3 <botlish_fn_37+0x3b>
    2c3b:	mov    rax,r15
    2c3e:	mov    rbx,QWORD PTR [rsp+0x20]
    2c43:	mov    r12,QWORD PTR [rsp+0x28]
    2c48:	mov    r13,QWORD PTR [rsp+0x30]
    2c4d:	mov    r14,QWORD PTR [rsp+0x38]
    2c52:	mov    r15,QWORD PTR [rsp+0x40]
    2c57:	add    rsp,0x50
    2c5b:	mov    rsp,rbp
    2c5e:	pop    rbp
    2c5f:	ret
    2c60:	mov    rax,0xffffffffffffffff
    2c67:	mov    rbx,QWORD PTR [rsp+0x20]
    2c6c:	mov    r12,QWORD PTR [rsp+0x28]
    2c71:	mov    r13,QWORD PTR [rsp+0x30]
    2c76:	mov    r14,QWORD PTR [rsp+0x38]
    2c7b:	mov    r15,QWORD PTR [rsp+0x40]
    2c80:	add    rsp,0x50
    2c84:	mov    rsp,rbp
    2c87:	pop    rbp
    2c88:	ret
    2c89:	add    BYTE PTR [rax],al
    2c8b:	add    BYTE PTR [rax],al
    2c8d:	add    BYTE PTR [rax],al
    2c8f:	add    BYTE PTR [rsi],al
    2c91:	add    BYTE PTR [rax],al
    2c93:	add    BYTE PTR [rax],al
    2c95:	add    BYTE PTR [rax],al
	...

0000000000002c98 <botlish_entry_37: ht_find_get<mutarray, str, int>>:
    2c98:	push   rbp
    2c99:	mov    rbp,rsp
    2c9c:	mov    rsi,QWORD PTR [rdx]
    2c9f:	mov    r8,QWORD PTR [rdx+0x8]
    2ca3:	mov    rcx,QWORD PTR [rdx+0x10]
    2ca7:	mov    rdx,r8
    2caa:	call   2caf <botlish_entry_37+0x17>
			2cab: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    2caf:	mov    rsp,rbp
    2cb2:	pop    rbp
    2cb3:	ret
    2cb4:	add    BYTE PTR [rax],al
	...

0000000000002cb8 <botlish_fn_38: ht_find_insert<mutarray, str, int, int>>:
    2cb8:	push   rbp
    2cb9:	mov    rbp,rsp
    2cbc:	sub    rsp,0x60
    2cc0:	mov    QWORD PTR [rsp+0x30],rbx
    2cc5:	mov    QWORD PTR [rsp+0x38],r12
    2cca:	mov    QWORD PTR [rsp+0x40],r13
    2ccf:	mov    QWORD PTR [rsp+0x48],r14
    2cd4:	mov    QWORD PTR [rsp+0x50],r15
    2cd9:	mov    r15,rdi
    2cdc:	mov    QWORD PTR [rsp],rsi
    2ce0:	mov    QWORD PTR [rsp+0x8],rdx
    2ce5:	mov    r13,rdx
    2ce8:	mov    QWORD PTR [rsp+0x10],rcx
    2ced:	mov    QWORD PTR [rsp+0x18],r8
    2cf2:	mov    rbx,rsi
    2cf5:	mov    QWORD PTR [rsp+0x20],rcx
    2cfa:	mov    QWORD PTR [rsp+0x28],r8
    2cff:	mov    rsi,rbx
    2d02:	mov    rdi,r15
    2d05:	call   2d0a <botlish_fn_38+0x52>
			2d06: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2d0a:	test   rax,rax
    2d0d:	je     3005 <botlish_fn_38+0x34d>
    2d13:	xor    ecx,ecx
    2d15:	test   rax,0x7
    2d1b:	je     2d29 <botlish_fn_38+0x71>
    2d21:	mov    rsi,rax
    2d24:	jmp    2d37 <botlish_fn_38+0x7f>
    2d29:	movzx  rcx,BYTE PTR [rax]
    2d2d:	mov    rsi,rax
    2d30:	rex cmp cl,0x8
    2d34:	sete   cl
    2d37:	test   cl,cl
    2d39:	jne    2d59 <botlish_fn_38+0xa1>
    2d3f:	mov    rdi,r15
    2d42:	mov    rax,QWORD PTR [rdi+0x10]
    2d46:	mov    rcx,QWORD PTR [rax+0x30]
    2d4a:	mov    edx,0x8
    2d4f:	call   2d54 <botlish_fn_38+0x9c>
			2d50: R_X86_64_PLT32	rt_type_error-0x4
    2d54:	jmp    3005 <botlish_fn_38+0x34d>
    2d59:	mov    rdx,QWORD PTR [rsp+0x20]
    2d5e:	mov    rdi,r15
    2d61:	call   2d66 <botlish_fn_38+0xae>
			2d62: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d66:	mov    rsi,rax
    2d69:	mov    r14,rax
    2d6c:	test   rax,rsi
    2d6f:	je     3005 <botlish_fn_38+0x34d>
    2d75:	mov    rax,r14
    2d78:	test   rax,0x1
    2d7e:	jne    2da2 <botlish_fn_38+0xea>
    2d84:	mov    edx,0x1
    2d89:	mov    rsi,r14
    2d8c:	mov    rdi,r15
    2d8f:	call   2d94 <botlish_fn_38+0xdc>
			2d90: R_X86_64_PLT32	rt_value_eq-0x4
    2d94:	test   rax,rax
    2d97:	je     3005 <botlish_fn_38+0x34d>
    2d9d:	jmp    2db6 <botlish_fn_38+0xfe>
    2da2:	mov    eax,0x2
    2da7:	mov    rcx,r14
    2daa:	cmp    rcx,0x1
    2dae:	cmove  rax,QWORD PTR [rip+0x372]        # 3128 <botlish_fn_38+0x470>
    2db6:	mov    r12d,0x6
    2dbc:	cmp    rax,0x6
    2dc0:	je     307d <botlish_fn_38+0x3c5>
    2dc6:	mov    rax,r14
    2dc9:	test   rax,0x1
    2dcf:	jne    2df3 <botlish_fn_38+0x13b>
    2dd5:	mov    edx,0x3
    2dda:	mov    rsi,r14
    2ddd:	mov    rdi,r15
    2de0:	call   2de5 <botlish_fn_38+0x12d>
			2de1: R_X86_64_PLT32	rt_value_eq-0x4
    2de5:	test   rax,rax
    2de8:	je     3005 <botlish_fn_38+0x34d>
    2dee:	jmp    2e07 <botlish_fn_38+0x14f>
    2df3:	mov    eax,0x2
    2df8:	mov    rcx,r14
    2dfb:	cmp    rcx,0x3
    2dff:	cmove  rax,QWORD PTR [rip+0x321]        # 3128 <botlish_fn_38+0x470>
    2e07:	cmp    rax,0x6
    2e0b:	je     2e1c <botlish_fn_38+0x164>
    2e11:	mov    r11d,0x2
    2e17:	jmp    2ee6 <botlish_fn_38+0x22e>
    2e1c:	mov    rsi,rbx
    2e1f:	mov    rdi,r15
    2e22:	call   2e27 <botlish_fn_38+0x16f>
			2e23: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2e27:	test   rax,rax
    2e2a:	je     3005 <botlish_fn_38+0x34d>
    2e30:	xor    ecx,ecx
    2e32:	test   rax,0x7
    2e38:	je     2e46 <botlish_fn_38+0x18e>
    2e3e:	mov    rsi,rax
    2e41:	jmp    2e54 <botlish_fn_38+0x19c>
    2e46:	movzx  rcx,BYTE PTR [rax]
    2e4a:	mov    rsi,rax
    2e4d:	rex cmp cl,0x8
    2e51:	sete   cl
    2e54:	test   cl,cl
    2e56:	jne    2e76 <botlish_fn_38+0x1be>
    2e5c:	mov    rdi,r15
    2e5f:	mov    rcx,QWORD PTR [rdi+0x10]
    2e63:	mov    rcx,QWORD PTR [rcx+0x30]
    2e67:	mov    edx,0x8
    2e6c:	call   2e71 <botlish_fn_38+0x1b9>
			2e6d: R_X86_64_PLT32	rt_type_error-0x4
    2e71:	jmp    3005 <botlish_fn_38+0x34d>
    2e76:	mov    rdx,QWORD PTR [rsp+0x20]
    2e7b:	mov    rdi,r15
    2e7e:	call   2e83 <botlish_fn_38+0x1cb>
			2e7f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2e83:	test   rax,rax
    2e86:	je     3005 <botlish_fn_38+0x34d>
    2e8c:	mov    rsi,rax
    2e8f:	and    rsi,r13
    2e92:	test   rsi,0x1
    2e99:	jne    2ebb <botlish_fn_38+0x203>
    2e9f:	mov    rsi,rax
    2ea2:	mov    rdx,r13
    2ea5:	mov    rdi,r15
    2ea8:	call   2ead <botlish_fn_38+0x1f5>
			2ea9: R_X86_64_PLT32	rt_value_eq-0x4
    2ead:	test   rax,rax
    2eb0:	je     3005 <botlish_fn_38+0x34d>
    2eb6:	jmp    2ece <botlish_fn_38+0x216>
    2ebb:	mov    rsi,rax
    2ebe:	mov    eax,0x2
    2ec3:	cmp    rsi,r13
    2ec6:	cmove  rax,QWORD PTR [rip+0x25a]        # 3128 <botlish_fn_38+0x470>
    2ece:	cmp    rax,0x6
    2ed2:	je     2ee3 <botlish_fn_38+0x22b>
    2ed8:	mov    r11d,0x2
    2ede:	jmp    2ee6 <botlish_fn_38+0x22e>
    2ee3:	mov    r11,r12
    2ee6:	cmp    r11,0x6
    2eea:	je     3056 <botlish_fn_38+0x39e>
    2ef0:	mov    rax,r14
    2ef3:	test   rax,0x1
    2ef9:	jne    2f1d <botlish_fn_38+0x265>
    2eff:	mov    edx,0x5
    2f04:	mov    rsi,r14
    2f07:	mov    rdi,r15
    2f0a:	call   2f0f <botlish_fn_38+0x257>
			2f0b: R_X86_64_PLT32	rt_value_eq-0x4
    2f0f:	test   rax,rax
    2f12:	je     3005 <botlish_fn_38+0x34d>
    2f18:	jmp    2f31 <botlish_fn_38+0x279>
    2f1d:	mov    rsi,r14
    2f20:	mov    eax,0x2
    2f25:	cmp    rsi,0x5
    2f29:	cmove  rax,QWORD PTR [rip+0x1f7]        # 3128 <botlish_fn_38+0x470>
    2f31:	cmp    rax,0x6
    2f35:	je     2f46 <botlish_fn_38+0x28e>
    2f3b:	mov    r12d,0x2
    2f41:	jmp    2fa7 <botlish_fn_38+0x2ef>
    2f46:	mov    r14,QWORD PTR [rsp+0x28]
    2f4b:	test   r14,0x1
    2f52:	jne    2f82 <botlish_fn_38+0x2ca>
    2f58:	mov    edx,0x1
    2f5d:	mov    rsi,r14
    2f60:	mov    rdi,r15
    2f63:	call   2f68 <botlish_fn_38+0x2b0>
			2f64: R_X86_64_PLT32	rt_int_cmp-0x4
    2f68:	mov    ecx,0x2
    2f6d:	test   rax,rax
    2f70:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 3128 <botlish_fn_38+0x470>
    2f78:	mov    QWORD PTR [rsp+0x28],r14
    2f7d:	jmp    2f97 <botlish_fn_38+0x2df>
    2f82:	mov    ecx,0x2
    2f87:	test   r14,r14
    2f8a:	mov    QWORD PTR [rsp+0x28],r14
    2f8f:	cmovle rcx,QWORD PTR [rip+0x191]        # 3128 <botlish_fn_38+0x470>
    2f97:	cmp    rcx,0x6
    2f9b:	je     2fa7 <botlish_fn_38+0x2ef>
    2fa1:	mov    r12d,0x2
    2fa7:	cmp    r12,0x6
    2fab:	je     2fec <botlish_fn_38+0x334>
    2fb1:	mov    rdx,QWORD PTR [rsp+0x20]
    2fb6:	mov    rsi,rbx
    2fb9:	mov    rdi,r15
    2fbc:	call   2fc1 <botlish_fn_38+0x309>
			2fbd: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2fc1:	test   rax,rax
    2fc4:	je     3005 <botlish_fn_38+0x34d>
    2fca:	mov    QWORD PTR [rsp],rbx
    2fce:	mov    QWORD PTR [rsp+0x8],r13
    2fd3:	mov    QWORD PTR [rsp+0x10],rax
    2fd8:	mov    r11,QWORD PTR [rsp+0x28]
    2fdd:	mov    QWORD PTR [rsp+0x18],r11
    2fe2:	mov    QWORD PTR [rsp+0x20],rax
    2fe7:	jmp    2cff <botlish_fn_38+0x47>
    2fec:	mov    rdx,QWORD PTR [rsp+0x20]
    2ff1:	mov    rsi,rbx
    2ff4:	mov    rdi,r15
    2ff7:	call   2ffc <botlish_fn_38+0x344>
			2ff8: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2ffc:	test   rax,rax
    2fff:	jne    302a <botlish_fn_38+0x372>
    3005:	xor    rax,rax
    3008:	mov    rbx,QWORD PTR [rsp+0x30]
    300d:	mov    r12,QWORD PTR [rsp+0x38]
    3012:	mov    r13,QWORD PTR [rsp+0x40]
    3017:	mov    r14,QWORD PTR [rsp+0x48]
    301c:	mov    r15,QWORD PTR [rsp+0x50]
    3021:	add    rsp,0x60
    3025:	mov    rsp,rbp
    3028:	pop    rbp
    3029:	ret
    302a:	mov    QWORD PTR [rsp],rbx
    302e:	mov    QWORD PTR [rsp+0x8],r13
    3033:	mov    QWORD PTR [rsp+0x10],rax
    3038:	mov    rdx,QWORD PTR [rsp+0x20]
    303d:	mov    QWORD PTR [rsp+0x18],rdx
    3042:	mov    rcx,QWORD PTR [rsp+0x20]
    3047:	mov    QWORD PTR [rsp+0x28],rcx
    304c:	mov    QWORD PTR [rsp+0x20],rax
    3051:	jmp    2cff <botlish_fn_38+0x47>
    3056:	mov    rax,QWORD PTR [rsp+0x20]
    305b:	mov    rbx,QWORD PTR [rsp+0x30]
    3060:	mov    r12,QWORD PTR [rsp+0x38]
    3065:	mov    r13,QWORD PTR [rsp+0x40]
    306a:	mov    r14,QWORD PTR [rsp+0x48]
    306f:	mov    r15,QWORD PTR [rsp+0x50]
    3074:	add    rsp,0x60
    3078:	mov    rsp,rbp
    307b:	pop    rbp
    307c:	ret
    307d:	mov    rax,QWORD PTR [rsp+0x28]
    3082:	test   rax,0x1
    3088:	jne    30b5 <botlish_fn_38+0x3fd>
    308e:	mov    edx,0x1
    3093:	mov    rdi,r15
    3096:	mov    rsi,QWORD PTR [rsp+0x28]
    309b:	call   30a0 <botlish_fn_38+0x3e8>
			309c: R_X86_64_PLT32	rt_int_cmp-0x4
    30a0:	mov    ecx,0x2
    30a5:	test   rax,rax
    30a8:	cmovge rcx,QWORD PTR [rip+0x78]        # 3128 <botlish_fn_38+0x470>
    30b0:	jmp    30cf <botlish_fn_38+0x417>
    30b5:	mov    ecx,0x2
    30ba:	mov    rax,QWORD PTR [rsp+0x28]
    30bf:	mov    rdx,QWORD PTR [rsp+0x28]
    30c4:	test   rax,rdx
    30c7:	cmovg  rcx,QWORD PTR [rip+0x59]        # 3128 <botlish_fn_38+0x470>
    30cf:	cmp    rcx,0x6
    30d3:	je     3100 <botlish_fn_38+0x448>
    30d9:	mov    rax,QWORD PTR [rsp+0x20]
    30de:	mov    rbx,QWORD PTR [rsp+0x30]
    30e3:	mov    r12,QWORD PTR [rsp+0x38]
    30e8:	mov    r13,QWORD PTR [rsp+0x40]
    30ed:	mov    r14,QWORD PTR [rsp+0x48]
    30f2:	mov    r15,QWORD PTR [rsp+0x50]
    30f7:	add    rsp,0x60
    30fb:	mov    rsp,rbp
    30fe:	pop    rbp
    30ff:	ret
    3100:	mov    rax,QWORD PTR [rsp+0x28]
    3105:	mov    rbx,QWORD PTR [rsp+0x30]
    310a:	mov    r12,QWORD PTR [rsp+0x38]
    310f:	mov    r13,QWORD PTR [rsp+0x40]
    3114:	mov    r14,QWORD PTR [rsp+0x48]
    3119:	mov    r15,QWORD PTR [rsp+0x50]
    311e:	add    rsp,0x60
    3122:	mov    rsp,rbp
    3125:	pop    rbp
    3126:	ret
    3127:	add    BYTE PTR [rsi],al
    3129:	add    BYTE PTR [rax],al
    312b:	add    BYTE PTR [rax],al
    312d:	add    BYTE PTR [rax],al
	...

0000000000003130 <botlish_entry_38: ht_find_insert<mutarray, str, int, int>>:
    3130:	push   rbp
    3131:	mov    rbp,rsp
    3134:	mov    rsi,QWORD PTR [rdx]
    3137:	mov    r9,QWORD PTR [rdx+0x8]
    313b:	mov    rcx,QWORD PTR [rdx+0x10]
    313f:	mov    r8,QWORD PTR [rdx+0x18]
    3143:	mov    rdx,r9
    3146:	call   314b <botlish_entry_38+0x1b>
			3147: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    314b:	mov    rsp,rbp
    314e:	pop    rbp
    314f:	ret

0000000000003150 <botlish_fn_39: ht_get<mutarray, str>>:
    3150:	push   rbp
    3151:	mov    rbp,rsp
    3154:	sub    rsp,0x40
    3158:	mov    QWORD PTR [rsp+0x20],rbx
    315d:	mov    QWORD PTR [rsp+0x28],r12
    3162:	mov    QWORD PTR [rsp+0x30],r13
    3167:	mov    rbx,rdi
    316a:	mov    QWORD PTR [rsp],rsi
    316e:	mov    r13,rsi
    3171:	mov    QWORD PTR [rsp+0x8],rdx
    3176:	mov    r12,rdx
    3179:	mov    rdx,r12
    317c:	mov    rsi,r13
    317f:	mov    rdi,rbx
    3182:	call   3187 <botlish_fn_39+0x37>
			3183: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    3187:	test   rax,rax
    318a:	je     3274 <botlish_fn_39+0x124>
    3190:	mov    QWORD PTR [rsp+0x10],rax
    3195:	mov    rcx,rax
    3198:	mov    rdx,r12
    319b:	mov    rsi,r13
    319e:	mov    rdi,rbx
    31a1:	call   31a6 <botlish_fn_39+0x56>
			31a2: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    31a6:	mov    rcx,rax
    31a9:	mov    r12,rax
    31ac:	test   rax,rcx
    31af:	je     3274 <botlish_fn_39+0x124>
    31b5:	mov    rax,r12
    31b8:	test   rax,0x1
    31be:	jne    31e9 <botlish_fn_39+0x99>
    31c4:	mov    edx,0x1
    31c9:	mov    rsi,r12
    31cc:	mov    rdi,rbx
    31cf:	call   31d4 <botlish_fn_39+0x84>
			31d0: R_X86_64_PLT32	rt_int_cmp-0x4
    31d4:	mov    ecx,0x2
    31d9:	test   rax,rax
    31dc:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 32c8 <botlish_fn_39+0x178>
    31e4:	jmp    31fc <botlish_fn_39+0xac>
    31e9:	mov    ecx,0x2
    31ee:	mov    rax,r12
    31f1:	test   rax,rax
    31f4:	cmovle rcx,QWORD PTR [rip+0xcc]        # 32c8 <botlish_fn_39+0x178>
    31fc:	cmp    rcx,0x6
    3200:	je     32a7 <botlish_fn_39+0x157>
    3206:	mov    rsi,r13
    3209:	mov    rdi,rbx
    320c:	call   3211 <botlish_fn_39+0xc1>
			320d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3211:	test   rax,rax
    3214:	je     3274 <botlish_fn_39+0x124>
    321a:	xor    ecx,ecx
    321c:	test   rax,0x7
    3222:	je     3230 <botlish_fn_39+0xe0>
    3228:	mov    rsi,rax
    322b:	jmp    323e <botlish_fn_39+0xee>
    3230:	movzx  rcx,BYTE PTR [rax]
    3234:	mov    rsi,rax
    3237:	rex cmp cl,0x8
    323b:	sete   cl
    323e:	test   cl,cl
    3240:	jne    3260 <botlish_fn_39+0x110>
    3246:	mov    rdi,rbx
    3249:	mov    rax,QWORD PTR [rdi+0x10]
    324d:	mov    rcx,QWORD PTR [rax+0x30]
    3251:	mov    edx,0x8
    3256:	call   325b <botlish_fn_39+0x10b>
			3257: R_X86_64_PLT32	rt_type_error-0x4
    325b:	jmp    3274 <botlish_fn_39+0x124>
    3260:	mov    rdx,r12
    3263:	mov    rdi,rbx
    3266:	call   326b <botlish_fn_39+0x11b>
			3267: R_X86_64_PLT32	rt_mutarray_get-0x4
    326b:	test   rax,rax
    326e:	jne    328f <botlish_fn_39+0x13f>
    3274:	xor    rax,rax
    3277:	mov    rbx,QWORD PTR [rsp+0x20]
    327c:	mov    r12,QWORD PTR [rsp+0x28]
    3281:	mov    r13,QWORD PTR [rsp+0x30]
    3286:	add    rsp,0x40
    328a:	mov    rsp,rbp
    328d:	pop    rbp
    328e:	ret
    328f:	mov    rbx,QWORD PTR [rsp+0x20]
    3294:	mov    r12,QWORD PTR [rsp+0x28]
    3299:	mov    r13,QWORD PTR [rsp+0x30]
    329e:	add    rsp,0x40
    32a2:	mov    rsp,rbp
    32a5:	pop    rbp
    32a6:	ret
    32a7:	mov    eax,0xa
    32ac:	mov    rbx,QWORD PTR [rsp+0x20]
    32b1:	mov    r12,QWORD PTR [rsp+0x28]
    32b6:	mov    r13,QWORD PTR [rsp+0x30]
    32bb:	add    rsp,0x40
    32bf:	mov    rsp,rbp
    32c2:	pop    rbp
    32c3:	ret
    32c4:	add    BYTE PTR [rax],al
    32c6:	add    BYTE PTR [rax],al
    32c8:	(bad)
    32c9:	add    BYTE PTR [rax],al
    32cb:	add    BYTE PTR [rax],al
    32cd:	add    BYTE PTR [rax],al
	...

00000000000032d0 <botlish_entry_39: ht_get<mutarray, str>>:
    32d0:	push   rbp
    32d1:	mov    rbp,rsp
    32d4:	mov    rsi,QWORD PTR [rdx]
    32d7:	mov    rdx,QWORD PTR [rdx+0x8]
    32db:	call   32e0 <botlish_entry_39+0x10>
			32dc: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    32e0:	mov    rsp,rbp
    32e3:	pop    rbp
    32e4:	ret
    32e5:	add    BYTE PTR [rax],al
	...

00000000000032e8 <botlish_fn_40: ht_rehash_probe<mutarray, int, int>>:
    32e8:	push   rbp
    32e9:	mov    rbp,rsp
    32ec:	sub    rsp,0x40
    32f0:	mov    QWORD PTR [rsp+0x20],rbx
    32f5:	mov    QWORD PTR [rsp+0x28],r12
    32fa:	mov    QWORD PTR [rsp+0x30],r13
    32ff:	mov    QWORD PTR [rsp+0x38],r14
    3304:	mov    r13,rdi
    3307:	mov    QWORD PTR [rsp],rsi
    330b:	mov    QWORD PTR [rsp+0x8],rdx
    3310:	mov    QWORD PTR [rsp+0x10],rcx
    3315:	mov    r12,rcx
    3318:	mov    rbx,rsi
    331b:	mov    r14,rdx
    331e:	mov    rdx,r14
    3321:	mov    rsi,rbx
    3324:	mov    rdi,r13
    3327:	call   332c <botlish_fn_40+0x44>
			3328: R_X86_64_PLT32	rt_mutarray_get-0x4
    332c:	test   rax,rax
    332f:	je     33cc <botlish_fn_40+0xe4>
    3335:	test   rax,0x1
    333b:	mov    rsi,rax
    333e:	jne    335f <botlish_fn_40+0x77>
    3344:	mov    edx,0x1
    3349:	mov    rdi,r13
    334c:	call   3351 <botlish_fn_40+0x69>
			334d: R_X86_64_PLT32	rt_value_eq-0x4
    3351:	test   rax,rax
    3354:	je     33cc <botlish_fn_40+0xe4>
    335a:	jmp    3370 <botlish_fn_40+0x88>
    335f:	mov    eax,0x2
    3364:	cmp    rsi,0x1
    3368:	cmove  rax,QWORD PTR [rip+0xb8]        # 3428 <botlish_fn_40+0x140>
    3370:	cmp    rax,0x6
    3374:	je     3402 <botlish_fn_40+0x11a>
    337a:	mov    QWORD PTR [rsp+0x18],0x3
    3383:	mov    rsi,r14
    3386:	test   rsi,0x1
    338d:	je     33a5 <botlish_fn_40+0xbd>
    3393:	mov    rsi,r14
    3396:	add    rsi,0x2
    339a:	seto   al
    339d:	test   al,al
    339f:	je     33b8 <botlish_fn_40+0xd0>
    33a5:	mov    edx,0x3
    33aa:	mov    rsi,r14
    33ad:	mov    rdi,r13
    33b0:	call   33b5 <botlish_fn_40+0xcd>
			33b1: R_X86_64_PLT32	rt_int_add-0x4
    33b5:	mov    rsi,rax
    33b8:	mov    rdx,r12
    33bb:	mov    rdi,r13
    33be:	call   33c3 <botlish_fn_40+0xdb>
			33bf: R_X86_64_PLT32	rt_int_mod-0x4
    33c3:	test   rax,rax
    33c6:	jne    33ec <botlish_fn_40+0x104>
    33cc:	xor    rax,rax
    33cf:	mov    rbx,QWORD PTR [rsp+0x20]
    33d4:	mov    r12,QWORD PTR [rsp+0x28]
    33d9:	mov    r13,QWORD PTR [rsp+0x30]
    33de:	mov    r14,QWORD PTR [rsp+0x38]
    33e3:	add    rsp,0x40
    33e7:	mov    rsp,rbp
    33ea:	pop    rbp
    33eb:	ret
    33ec:	mov    QWORD PTR [rsp],rbx
    33f0:	mov    QWORD PTR [rsp+0x8],rax
    33f5:	mov    QWORD PTR [rsp+0x10],r12
    33fa:	mov    r14,rax
    33fd:	jmp    331e <botlish_fn_40+0x36>
    3402:	mov    rax,r14
    3405:	mov    rbx,QWORD PTR [rsp+0x20]
    340a:	mov    r12,QWORD PTR [rsp+0x28]
    340f:	mov    r13,QWORD PTR [rsp+0x30]
    3414:	mov    r14,QWORD PTR [rsp+0x38]
    3419:	add    rsp,0x40
    341d:	mov    rsp,rbp
    3420:	pop    rbp
    3421:	ret
    3422:	add    BYTE PTR [rax],al
    3424:	add    BYTE PTR [rax],al
    3426:	add    BYTE PTR [rax],al
    3428:	(bad)
    3429:	add    BYTE PTR [rax],al
    342b:	add    BYTE PTR [rax],al
    342d:	add    BYTE PTR [rax],al
	...

0000000000003430 <botlish_entry_40: ht_rehash_probe<mutarray, int, int>>:
    3430:	push   rbp
    3431:	mov    rbp,rsp
    3434:	mov    rsi,QWORD PTR [rdx]
    3437:	mov    r8,QWORD PTR [rdx+0x8]
    343b:	mov    rcx,QWORD PTR [rdx+0x10]
    343f:	mov    rdx,r8
    3442:	call   3447 <botlish_entry_40+0x17>
			3443: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    3447:	mov    rsp,rbp
    344a:	pop    rbp
    344b:	ret

000000000000344c <botlish_fn_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    344c:	push   rbp
    344d:	mov    rbp,rsp
    3450:	sub    rsp,0x80
    3457:	mov    QWORD PTR [rsp+0x50],rbx
    345c:	mov    QWORD PTR [rsp+0x58],r12
    3461:	mov    QWORD PTR [rsp+0x60],r13
    3466:	mov    QWORD PTR [rsp+0x68],r14
    346b:	mov    QWORD PTR [rsp+0x70],r15
    3470:	mov    r12,rdi
    3473:	mov    rdi,QWORD PTR [rbp+0x10]
    3477:	mov    QWORD PTR [rsp],rsi
    347b:	mov    QWORD PTR [rsp+0x38],rsi
    3480:	mov    QWORD PTR [rsp+0x8],rdx
    3485:	mov    r15,rdx
    3488:	mov    QWORD PTR [rsp+0x10],rcx
    348d:	mov    rbx,rcx
    3490:	mov    QWORD PTR [rsp+0x18],r8
    3495:	mov    QWORD PTR [rsp+0x40],r8
    349a:	mov    QWORD PTR [rsp+0x20],r9
    349f:	mov    r14,r9
    34a2:	mov    QWORD PTR [rsp+0x28],rdi
    34a7:	mov    r13,rdi
    34aa:	mov    rsi,r14
    34ad:	mov    rdi,r12
    34b0:	call   34b5 <botlish_fn_41+0x69>
			34b1: R_X86_64_PLT32	rt_hash-0x4
    34b5:	test   rax,rax
    34b8:	mov    rsi,rax
    34bb:	je     355a <botlish_fn_41+0x10e>
    34c1:	mov    rdx,QWORD PTR [rsp+0x40]
    34c6:	mov    rdi,r12
    34c9:	call   34ce <botlish_fn_41+0x82>
			34ca: R_X86_64_PLT32	rt_int_mod-0x4
    34ce:	test   rax,rax
    34d1:	je     355a <botlish_fn_41+0x10e>
    34d7:	mov    QWORD PTR [rsp+0x30],rax
    34dc:	mov    rcx,QWORD PTR [rsp+0x40]
    34e1:	mov    rdx,rax
    34e4:	mov    rsi,QWORD PTR [rsp+0x38]
    34e9:	mov    rdi,r12
    34ec:	call   34f1 <botlish_fn_41+0xa5>
			34ed: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    34f1:	mov    rcx,rax
    34f4:	mov    QWORD PTR [rsp+0x40],rax
    34f9:	test   rax,rcx
    34fc:	je     355a <botlish_fn_41+0x10e>
    3502:	mov    ecx,0x3
    3507:	mov    rsi,QWORD PTR [rsp+0x38]
    350c:	mov    rdx,QWORD PTR [rsp+0x40]
    3511:	mov    rdi,r12
    3514:	call   3519 <botlish_fn_41+0xcd>
			3515: R_X86_64_PLT32	rt_mutarray_set-0x4
    3519:	test   rax,rax
    351c:	je     355a <botlish_fn_41+0x10e>
    3522:	mov    rcx,r14
    3525:	mov    rsi,r15
    3528:	mov    rdx,QWORD PTR [rsp+0x40]
    352d:	mov    rdi,r12
    3530:	call   3535 <botlish_fn_41+0xe9>
			3531: R_X86_64_PLT32	rt_mutarray_set-0x4
    3535:	test   rax,rax
    3538:	je     355a <botlish_fn_41+0x10e>
    353e:	mov    rcx,r13
    3541:	mov    rdx,QWORD PTR [rsp+0x40]
    3546:	mov    rsi,rbx
    3549:	mov    rdi,r12
    354c:	call   3551 <botlish_fn_41+0x105>
			354d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3551:	test   rax,rax
    3554:	jne    3582 <botlish_fn_41+0x136>
    355a:	xor    rax,rax
    355d:	mov    rbx,QWORD PTR [rsp+0x50]
    3562:	mov    r12,QWORD PTR [rsp+0x58]
    3567:	mov    r13,QWORD PTR [rsp+0x60]
    356c:	mov    r14,QWORD PTR [rsp+0x68]
    3571:	mov    r15,QWORD PTR [rsp+0x70]
    3576:	add    rsp,0x80
    357d:	mov    rsp,rbp
    3580:	pop    rbp
    3581:	ret
    3582:	mov    eax,0xa
    3587:	mov    rbx,QWORD PTR [rsp+0x50]
    358c:	mov    r12,QWORD PTR [rsp+0x58]
    3591:	mov    r13,QWORD PTR [rsp+0x60]
    3596:	mov    r14,QWORD PTR [rsp+0x68]
    359b:	mov    r15,QWORD PTR [rsp+0x70]
    35a0:	add    rsp,0x80
    35a7:	mov    rsp,rbp
    35aa:	pop    rbp
    35ab:	ret

00000000000035ac <botlish_entry_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    35ac:	push   rbp
    35ad:	mov    rbp,rsp
    35b0:	sub    rsp,0x10
    35b4:	mov    rsi,QWORD PTR [rdx]
    35b7:	mov    r10,QWORD PTR [rdx+0x8]
    35bb:	mov    rcx,QWORD PTR [rdx+0x10]
    35bf:	mov    r8,QWORD PTR [rdx+0x18]
    35c3:	mov    r9,QWORD PTR [rdx+0x20]
    35c7:	mov    r11,QWORD PTR [rdx+0x28]
    35cb:	mov    QWORD PTR [rsp],r11
    35cf:	mov    rdx,r10
    35d2:	call   35d7 <botlish_entry_41+0x2b>
			35d3: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    35d7:	add    rsp,0x10
    35db:	mov    rsp,rbp
    35de:	pop    rbp
    35df:	ret

00000000000035e0 <botlish_fn_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    35e0:	push   rbp
    35e1:	mov    rbp,rsp
    35e4:	sub    rsp,0xc0
    35eb:	mov    QWORD PTR [rsp+0x90],rbx
    35f3:	mov    QWORD PTR [rsp+0x98],r12
    35fb:	mov    QWORD PTR [rsp+0xa0],r13
    3603:	mov    QWORD PTR [rsp+0xa8],r14
    360b:	mov    QWORD PTR [rsp+0xb0],r15
    3613:	mov    QWORD PTR [rsp+0x58],rdi
    3618:	mov    r15,QWORD PTR [rbp+0x10]
    361c:	mov    r12,QWORD PTR [rbp+0x18]
    3620:	mov    r13,QWORD PTR [rbp+0x20]
    3624:	mov    r14,QWORD PTR [rbp+0x28]
    3628:	mov    QWORD PTR [rsp+0x10],rsi
    362d:	mov    QWORD PTR [rsp+0x60],rsi
    3632:	mov    QWORD PTR [rsp+0x18],rdx
    3637:	mov    QWORD PTR [rsp+0x68],rdx
    363c:	mov    QWORD PTR [rsp+0x20],rcx
    3641:	mov    QWORD PTR [rsp+0x70],rcx
    3646:	mov    QWORD PTR [rsp+0x28],r15
    364b:	mov    QWORD PTR [rsp+0x30],r12
    3650:	mov    QWORD PTR [rsp+0x38],r13
    3655:	mov    QWORD PTR [rsp+0x40],r14
    365a:	sar    r8,1
    365d:	sar    r9,1
    3660:	mov    QWORD PTR [rsp+0x88],r9
    3668:	mov    rcx,QWORD PTR [rsp+0x88]
    3670:	mov    rbx,r8
    3673:	cmp    rbx,rcx
    3676:	mov    QWORD PTR [rsp+0x88],rcx
    367e:	jge    38e7 <botlish_fn_42+0x307>
    3684:	xor    eax,eax
    3686:	mov    rsi,QWORD PTR [rsp+0x60]
    368b:	test   rsi,0x7
    3692:	jne    36a3 <botlish_fn_42+0xc3>
    3698:	movzx  r10,BYTE PTR [rsi]
    369c:	cmp    r10b,0x8
    36a0:	sete   al
    36a3:	test   al,al
    36a5:	jne    36c7 <botlish_fn_42+0xe7>
    36ab:	mov    rdi,QWORD PTR [rsp+0x58]
    36b0:	mov    rax,QWORD PTR [rdi+0x10]
    36b4:	mov    rcx,QWORD PTR [rax+0x30]
    36b8:	mov    edx,0x8
    36bd:	call   36c2 <botlish_fn_42+0xe2>
			36be: R_X86_64_PLT32	rt_type_error-0x4
    36c2:	jmp    3865 <botlish_fn_42+0x285>
    36c7:	mov    QWORD PTR [rsp+0x60],rsi
    36cc:	mov    rdx,rbx
    36cf:	shl    rdx,1
    36d2:	or     rdx,0x1
    36d6:	mov    QWORD PTR [rsp+0x80],rdx
    36de:	mov    rdi,QWORD PTR [rsp+0x58]
    36e3:	call   36e8 <botlish_fn_42+0x108>
			36e4: R_X86_64_PLT32	rt_mutarray_get-0x4
    36e8:	test   rax,rax
    36eb:	je     3865 <botlish_fn_42+0x285>
    36f1:	test   rax,0x1
    36f7:	mov    rsi,rax
    36fa:	jne    371d <botlish_fn_42+0x13d>
    3700:	mov    edx,0x3
    3705:	mov    rdi,QWORD PTR [rsp+0x58]
    370a:	call   370f <botlish_fn_42+0x12f>
			370b: R_X86_64_PLT32	rt_value_eq-0x4
    370f:	test   rax,rax
    3712:	je     3865 <botlish_fn_42+0x285>
    3718:	jmp    372e <botlish_fn_42+0x14e>
    371d:	mov    eax,0x2
    3722:	cmp    rsi,0x3
    3726:	cmove  rax,QWORD PTR [rip+0x1f2]        # 3920 <botlish_fn_42+0x340>
    372e:	cmp    rax,0x6
    3732:	je     3742 <botlish_fn_42+0x162>
    3738:	mov    rsi,QWORD PTR [rsp+0x60]
    373d:	jmp    38a1 <botlish_fn_42+0x2c1>
    3742:	xor    esi,esi
    3744:	mov    rdx,QWORD PTR [rsp+0x68]
    3749:	test   rdx,0x7
    3750:	je     3760 <botlish_fn_42+0x180>
    3756:	mov    QWORD PTR [rsp+0x68],rdx
    375b:	jmp    376f <botlish_fn_42+0x18f>
    3760:	movzx  rax,BYTE PTR [rdx]
    3764:	mov    QWORD PTR [rsp+0x68],rdx
    3769:	cmp    al,0x8
    376b:	sete   sil
    376f:	test   sil,sil
    3772:	jne    3799 <botlish_fn_42+0x1b9>
    3778:	mov    rdi,QWORD PTR [rsp+0x58]
    377d:	mov    rax,QWORD PTR [rdi+0x10]
    3781:	mov    rcx,QWORD PTR [rax+0x30]
    3785:	mov    edx,0x8
    378a:	mov    rsi,QWORD PTR [rsp+0x68]
    378f:	call   3794 <botlish_fn_42+0x1b4>
			3790: R_X86_64_PLT32	rt_type_error-0x4
    3794:	jmp    3865 <botlish_fn_42+0x285>
    3799:	mov    rdx,QWORD PTR [rsp+0x80]
    37a1:	mov    rsi,QWORD PTR [rsp+0x68]
    37a6:	mov    rdi,QWORD PTR [rsp+0x58]
    37ab:	call   37b0 <botlish_fn_42+0x1d0>
			37ac: R_X86_64_PLT32	rt_mutarray_get-0x4
    37b0:	test   rax,rax
    37b3:	je     3865 <botlish_fn_42+0x285>
    37b9:	mov    QWORD PTR [rsp+0x48],rax
    37be:	mov    QWORD PTR [rsp+0x78],rax
    37c3:	xor    eax,eax
    37c5:	mov    rcx,QWORD PTR [rsp+0x70]
    37ca:	test   rcx,0x7
    37d1:	je     37e1 <botlish_fn_42+0x201>
    37d7:	mov    QWORD PTR [rsp+0x70],rcx
    37dc:	jmp    37ef <botlish_fn_42+0x20f>
    37e1:	movzx  rax,BYTE PTR [rcx]
    37e5:	mov    QWORD PTR [rsp+0x70],rcx
    37ea:	cmp    al,0x8
    37ec:	sete   al
    37ef:	test   al,al
    37f1:	jne    3818 <botlish_fn_42+0x238>
    37f7:	mov    rdi,QWORD PTR [rsp+0x58]
    37fc:	mov    rax,QWORD PTR [rdi+0x10]
    3800:	mov    rcx,QWORD PTR [rax+0x30]
    3804:	mov    edx,0x8
    3809:	mov    rsi,QWORD PTR [rsp+0x70]
    380e:	call   3813 <botlish_fn_42+0x233>
			380f: R_X86_64_PLT32	rt_type_error-0x4
    3813:	jmp    3865 <botlish_fn_42+0x285>
    3818:	mov    rdx,QWORD PTR [rsp+0x80]
    3820:	mov    rsi,QWORD PTR [rsp+0x70]
    3825:	mov    rdi,QWORD PTR [rsp+0x58]
    382a:	call   382f <botlish_fn_42+0x24f>
			382b: R_X86_64_PLT32	rt_mutarray_get-0x4
    382f:	test   rax,rax
    3832:	je     3865 <botlish_fn_42+0x285>
    3838:	mov    QWORD PTR [rsp+0x50],rax
    383d:	mov    QWORD PTR [rsp],rax
    3841:	mov    r9,QWORD PTR [rsp+0x78]
    3846:	mov    rcx,r13
    3849:	mov    rdx,r12
    384c:	mov    rsi,r15
    384f:	mov    rdi,QWORD PTR [rsp+0x58]
    3854:	mov    r8,r14
    3857:	call   385c <botlish_fn_42+0x27c>
			3858: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    385c:	test   rax,rax
    385f:	jne    389c <botlish_fn_42+0x2bc>
    3865:	xor    rax,rax
    3868:	mov    rbx,QWORD PTR [rsp+0x90]
    3870:	mov    r12,QWORD PTR [rsp+0x98]
    3878:	mov    r13,QWORD PTR [rsp+0xa0]
    3880:	mov    r14,QWORD PTR [rsp+0xa8]
    3888:	mov    r15,QWORD PTR [rsp+0xb0]
    3890:	add    rsp,0xc0
    3897:	mov    rsp,rbp
    389a:	pop    rbp
    389b:	ret
    389c:	mov    rsi,QWORD PTR [rsp+0x60]
    38a1:	mov    rsi,QWORD PTR [rsp+0x60]
    38a6:	mov    QWORD PTR [rsp+0x10],rsi
    38ab:	mov    rsi,QWORD PTR [rsp+0x68]
    38b0:	mov    QWORD PTR [rsp+0x18],rsi
    38b5:	mov    rsi,QWORD PTR [rsp+0x70]
    38ba:	mov    QWORD PTR [rsp+0x20],rsi
    38bf:	mov    QWORD PTR [rsp+0x28],r15
    38c4:	mov    QWORD PTR [rsp+0x30],r12
    38c9:	mov    QWORD PTR [rsp+0x38],r13
    38ce:	mov    QWORD PTR [rsp+0x40],r14
    38d3:	add    rbx,0x1
    38da:	mov    rcx,QWORD PTR [rsp+0x88]
    38e2:	jmp    3673 <botlish_fn_42+0x93>
    38e7:	mov    eax,0xa
    38ec:	mov    rbx,QWORD PTR [rsp+0x90]
    38f4:	mov    r12,QWORD PTR [rsp+0x98]
    38fc:	mov    r13,QWORD PTR [rsp+0xa0]
    3904:	mov    r14,QWORD PTR [rsp+0xa8]
    390c:	mov    r15,QWORD PTR [rsp+0xb0]
    3914:	add    rsp,0xc0
    391b:	mov    rsp,rbp
    391e:	pop    rbp
    391f:	ret
    3920:	(bad)
    3921:	add    BYTE PTR [rax],al
    3923:	add    BYTE PTR [rax],al
    3925:	add    BYTE PTR [rax],al
	...

0000000000003928 <botlish_entry_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3928:	push   rbp
    3929:	mov    rbp,rsp
    392c:	sub    rsp,0x30
    3930:	mov    QWORD PTR [rsp+0x20],r12
    3935:	mov    rsi,QWORD PTR [rdx]
    3938:	mov    rax,QWORD PTR [rdx+0x8]
    393c:	mov    rcx,QWORD PTR [rdx+0x10]
    3940:	mov    r8,QWORD PTR [rdx+0x18]
    3944:	mov    r9,QWORD PTR [rdx+0x20]
    3948:	mov    r10,QWORD PTR [rdx+0x28]
    394c:	mov    r11,QWORD PTR [rdx+0x30]
    3950:	mov    r12,QWORD PTR [rdx+0x38]
    3954:	mov    rdx,QWORD PTR [rdx+0x40]
    3958:	mov    QWORD PTR [rsp],r10
    395c:	mov    QWORD PTR [rsp+0x8],r11
    3961:	mov    QWORD PTR [rsp+0x10],r12
    3966:	mov    QWORD PTR [rsp+0x18],rdx
    396b:	mov    rdx,rax
    396e:	call   3973 <botlish_entry_42+0x4b>
			396f: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3973:	mov    r12,QWORD PTR [rsp+0x20]
    3978:	add    rsp,0x30
    397c:	mov    rsp,rbp
    397f:	pop    rbp
    3980:	ret

0000000000003981 <botlish_fn_43: ht_rehash<mutarray, int>>:
    3981:	push   rbp
    3982:	mov    rbp,rsp
    3985:	sub    rsp,0xd0
    398c:	mov    QWORD PTR [rsp+0xa0],rbx
    3994:	mov    QWORD PTR [rsp+0xa8],r12
    399c:	mov    QWORD PTR [rsp+0xb0],r13
    39a4:	mov    QWORD PTR [rsp+0xb8],r14
    39ac:	mov    QWORD PTR [rsp+0xc0],r15
    39b4:	mov    r13,rdi
    39b7:	mov    QWORD PTR [rsp+0x50],0x0
    39c0:	mov    QWORD PTR [rsp+0x58],0x0
    39c9:	mov    QWORD PTR [rsp+0x60],0x0
    39d2:	mov    QWORD PTR [rsp+0x68],0x0
    39db:	mov    QWORD PTR [rsp+0x20],rsi
    39e0:	mov    r12,rsi
    39e3:	mov    QWORD PTR [rsp+0x28],rdx
    39e8:	mov    rbx,rdx
    39eb:	mov    rsi,r12
    39ee:	mov    rdi,r13
    39f1:	call   39f6 <botlish_fn_43+0x75>
			39f2: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    39f6:	test   rax,rax
    39f9:	je     3bc8 <botlish_fn_43+0x247>
    39ff:	mov    QWORD PTR [rsp+0x30],rax
    3a04:	mov    r14,rax
    3a07:	mov    rsi,r12
    3a0a:	mov    rdi,r13
    3a0d:	call   3a12 <botlish_fn_43+0x91>
			3a0e: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3a12:	test   rax,rax
    3a15:	je     3bc8 <botlish_fn_43+0x247>
    3a1b:	mov    QWORD PTR [rsp+0x38],rax
    3a20:	mov    r15,rax
    3a23:	mov    rsi,r12
    3a26:	mov    rdi,r13
    3a29:	call   3a2e <botlish_fn_43+0xad>
			3a2a: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3a2e:	test   rax,rax
    3a31:	je     3bc8 <botlish_fn_43+0x247>
    3a37:	mov    QWORD PTR [rsp+0x40],rax
    3a3c:	mov    QWORD PTR [rsp+0x90],rax
    3a44:	mov    rsi,r12
    3a47:	mov    rdi,r13
    3a4a:	call   3a4f <botlish_fn_43+0xce>
			3a4b: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3a4f:	test   rax,rax
    3a52:	je     3bc8 <botlish_fn_43+0x247>
    3a58:	mov    QWORD PTR [rsp+0x48],rax
    3a5d:	mov    QWORD PTR [rsp+0x88],rax
    3a65:	mov    rsi,rbx
    3a68:	mov    rdi,r13
    3a6b:	call   3a70 <botlish_fn_43+0xef>
			3a6c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3a70:	mov    rcx,rax
    3a73:	mov    QWORD PTR [rsp+0x80],rax
    3a7b:	test   rax,rcx
    3a7e:	je     3bc8 <botlish_fn_43+0x247>
    3a84:	mov    rax,QWORD PTR [rsp+0x80]
    3a8c:	mov    QWORD PTR [rsp+0x50],rax
    3a91:	mov    edx,0x1
    3a96:	mov    QWORD PTR [rsp+0x58],0x1
    3a9f:	mov    rcx,rbx
    3aa2:	mov    rsi,QWORD PTR [rsp+0x80]
    3aaa:	mov    rdi,r13
    3aad:	call   3ab2 <botlish_fn_43+0x131>
			3aae: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3ab2:	test   rax,rax
    3ab5:	je     3bc8 <botlish_fn_43+0x247>
    3abb:	mov    rsi,rbx
    3abe:	mov    rdi,r13
    3ac1:	call   3ac6 <botlish_fn_43+0x145>
			3ac2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3ac6:	test   rax,rax
    3ac9:	je     3bc8 <botlish_fn_43+0x247>
    3acf:	mov    QWORD PTR [rsp+0x58],rax
    3ad4:	mov    QWORD PTR [rsp+0x78],rax
    3ad9:	mov    rsi,rbx
    3adc:	mov    rdi,r13
    3adf:	call   3ae4 <botlish_fn_43+0x163>
			3ae0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3ae4:	test   rax,rax
    3ae7:	je     3bc8 <botlish_fn_43+0x247>
    3aed:	mov    QWORD PTR [rsp+0x60],rax
    3af2:	mov    r8d,0x1
    3af8:	mov    QWORD PTR [rsp+0x68],0x1
    3b01:	mov    rcx,QWORD PTR [rsp+0x80]
    3b09:	mov    QWORD PTR [rsp],rcx
    3b0d:	mov    rcx,QWORD PTR [rsp+0x78]
    3b12:	mov    QWORD PTR [rsp+0x8],rcx
    3b17:	mov    QWORD PTR [rsp+0x10],rax
    3b1c:	mov    QWORD PTR [rsp+0x70],rax
    3b21:	mov    QWORD PTR [rsp+0x18],rbx
    3b26:	mov    rcx,QWORD PTR [rsp+0x90]
    3b2e:	mov    rdx,r15
    3b31:	mov    rsi,r14
    3b34:	mov    r9,QWORD PTR [rsp+0x88]
    3b3c:	mov    rdi,r13
    3b3f:	call   3b44 <botlish_fn_43+0x1c3>
			3b40: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3b44:	test   rax,rax
    3b47:	je     3bc8 <botlish_fn_43+0x247>
    3b4d:	mov    edx,0x1
    3b52:	mov    rcx,QWORD PTR [rsp+0x80]
    3b5a:	mov    rsi,r12
    3b5d:	mov    rdi,r13
    3b60:	call   3b65 <botlish_fn_43+0x1e4>
			3b61: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b65:	test   rax,rax
    3b68:	je     3bc8 <botlish_fn_43+0x247>
    3b6e:	mov    edx,0x3
    3b73:	mov    rcx,QWORD PTR [rsp+0x78]
    3b78:	mov    rsi,r12
    3b7b:	mov    rdi,r13
    3b7e:	call   3b83 <botlish_fn_43+0x202>
			3b7f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b83:	test   rax,rax
    3b86:	je     3bc8 <botlish_fn_43+0x247>
    3b8c:	mov    edx,0x5
    3b91:	mov    rcx,QWORD PTR [rsp+0x70]
    3b96:	mov    rsi,r12
    3b99:	mov    rdi,r13
    3b9c:	call   3ba1 <botlish_fn_43+0x220>
			3b9d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ba1:	test   rax,rax
    3ba4:	je     3bc8 <botlish_fn_43+0x247>
    3baa:	mov    edx,0x9
    3baf:	mov    ecx,0x1
    3bb4:	mov    rsi,r12
    3bb7:	mov    rdi,r13
    3bba:	call   3bbf <botlish_fn_43+0x23e>
			3bbb: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bbf:	test   rax,rax
    3bc2:	jne    3bff <botlish_fn_43+0x27e>
    3bc8:	xor    rax,rax
    3bcb:	mov    rbx,QWORD PTR [rsp+0xa0]
    3bd3:	mov    r12,QWORD PTR [rsp+0xa8]
    3bdb:	mov    r13,QWORD PTR [rsp+0xb0]
    3be3:	mov    r14,QWORD PTR [rsp+0xb8]
    3beb:	mov    r15,QWORD PTR [rsp+0xc0]
    3bf3:	add    rsp,0xd0
    3bfa:	mov    rsp,rbp
    3bfd:	pop    rbp
    3bfe:	ret
    3bff:	mov    eax,0xa
    3c04:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c0c:	mov    r12,QWORD PTR [rsp+0xa8]
    3c14:	mov    r13,QWORD PTR [rsp+0xb0]
    3c1c:	mov    r14,QWORD PTR [rsp+0xb8]
    3c24:	mov    r15,QWORD PTR [rsp+0xc0]
    3c2c:	add    rsp,0xd0
    3c33:	mov    rsp,rbp
    3c36:	pop    rbp
    3c37:	ret

0000000000003c38 <botlish_entry_43: ht_rehash<mutarray, int>>:
    3c38:	push   rbp
    3c39:	mov    rbp,rsp
    3c3c:	mov    rsi,QWORD PTR [rdx]
    3c3f:	mov    rdx,QWORD PTR [rdx+0x8]
    3c43:	call   3c48 <botlish_entry_43+0x10>
			3c44: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3c48:	mov    rsp,rbp
    3c4b:	pop    rbp
    3c4c:	ret
    3c4d:	add    BYTE PTR [rax],al
	...

0000000000003c50 <botlish_fn_44: ht_should_grow<mutarray>>:
    3c50:	push   rbp
    3c51:	mov    rbp,rsp
    3c54:	sub    rsp,0x40
    3c58:	mov    QWORD PTR [rsp+0x20],rbx
    3c5d:	mov    QWORD PTR [rsp+0x28],r12
    3c62:	mov    QWORD PTR [rsp+0x30],r13
    3c67:	mov    rbx,rdi
    3c6a:	mov    QWORD PTR [rsp],rsi
    3c6e:	mov    r12,rsi
    3c71:	mov    rsi,r12
    3c74:	mov    rdi,rbx
    3c77:	call   3c7c <botlish_fn_44+0x2c>
			3c78: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3c7c:	mov    rcx,rax
    3c7f:	mov    r13,rax
    3c82:	test   rax,rcx
    3c85:	je     3e74 <botlish_fn_44+0x224>
    3c8b:	mov    rax,r13
    3c8e:	mov    QWORD PTR [rsp+0x8],rax
    3c93:	mov    rsi,r12
    3c96:	mov    rdi,rbx
    3c99:	call   3c9e <botlish_fn_44+0x4e>
			3c9a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3c9e:	mov    rcx,rax
    3ca1:	test   rcx,rcx
    3ca4:	je     3e74 <botlish_fn_44+0x224>
    3caa:	mov    QWORD PTR [rsp+0x10],rcx
    3caf:	mov    edx,0x1
    3cb4:	mov    rax,r13
    3cb7:	test   rax,0x1
    3cbd:	jne    3ce0 <botlish_fn_44+0x90>
    3cc3:	xor    edx,edx
    3cc5:	mov    rax,r13
    3cc8:	test   rax,0x7
    3cce:	jne    3ce0 <botlish_fn_44+0x90>
    3cd4:	mov    rax,r13
    3cd7:	movzx  rax,BYTE PTR [rax]
    3cdb:	cmp    al,0x1
    3cdd:	sete   dl
    3ce0:	test   dl,dl
    3ce2:	jne    3d03 <botlish_fn_44+0xb3>
    3ce8:	mov    rdi,rbx
    3ceb:	mov    rax,QWORD PTR [rdi+0x10]
    3cef:	mov    rcx,QWORD PTR [rax+0x38]
    3cf3:	xor    rdx,rdx
    3cf6:	mov    rsi,r13
    3cf9:	call   3cfe <botlish_fn_44+0xae>
			3cfa: R_X86_64_PLT32	rt_type_error-0x4
    3cfe:	jmp    3e74 <botlish_fn_44+0x224>
    3d03:	mov    eax,0x1
    3d08:	test   rcx,0x1
    3d0f:	je     3d1d <botlish_fn_44+0xcd>
    3d15:	mov    r8,rcx
    3d18:	jmp    3d40 <botlish_fn_44+0xf0>
    3d1d:	xor    eax,eax
    3d1f:	test   rcx,0x7
    3d26:	je     3d34 <botlish_fn_44+0xe4>
    3d2c:	mov    r8,rcx
    3d2f:	jmp    3d40 <botlish_fn_44+0xf0>
    3d34:	movzx  rax,BYTE PTR [rcx]
    3d38:	mov    r8,rcx
    3d3b:	cmp    al,0x1
    3d3d:	sete   al
    3d40:	test   al,al
    3d42:	jne    3d63 <botlish_fn_44+0x113>
    3d48:	mov    rdi,rbx
    3d4b:	mov    rax,QWORD PTR [rdi+0x10]
    3d4f:	mov    rcx,QWORD PTR [rax+0x38]
    3d53:	xor    rdx,rdx
    3d56:	mov    rsi,r8
    3d59:	call   3d5e <botlish_fn_44+0x10e>
			3d5a: R_X86_64_PLT32	rt_type_error-0x4
    3d5e:	jmp    3e74 <botlish_fn_44+0x224>
    3d63:	mov    rcx,r8
    3d66:	mov    rsi,r13
    3d69:	mov    rax,rsi
    3d6c:	and    rax,rcx
    3d6f:	test   rax,0x1
    3d75:	jne    3d86 <botlish_fn_44+0x136>
    3d7b:	mov    rdx,r8
    3d7e:	mov    rsi,r13
    3d81:	jmp    3da4 <botlish_fn_44+0x154>
    3d86:	mov    rcx,r8
    3d89:	lea    rax,[rcx-0x1]
    3d8d:	mov    rsi,r13
    3d90:	add    rsi,rax
    3d93:	seto   al
    3d96:	test   al,al
    3d98:	je     3daf <botlish_fn_44+0x15f>
    3d9e:	mov    rdx,r8
    3da1:	mov    rsi,r13
    3da4:	mov    rdi,rbx
    3da7:	call   3dac <botlish_fn_44+0x15c>
			3da8: R_X86_64_PLT32	rt_int_add-0x4
    3dac:	mov    rsi,rax
    3daf:	mov    QWORD PTR [rsp+0x8],rsi
    3db4:	mov    QWORD PTR [rsp+0x10],0x3
    3dbd:	test   rsi,0x1
    3dc4:	je     3de7 <botlish_fn_44+0x197>
    3dca:	mov    rax,rsi
    3dcd:	add    rax,0x2
    3dd1:	mov    rcx,rax
    3dd4:	seto   al
    3dd7:	test   al,al
    3dd9:	jne    3de7 <botlish_fn_44+0x197>
    3ddf:	mov    rsi,rcx
    3de2:	jmp    3df7 <botlish_fn_44+0x1a7>
    3de7:	mov    edx,0x3
    3dec:	mov    rdi,rbx
    3def:	call   3df4 <botlish_fn_44+0x1a4>
			3df0: R_X86_64_PLT32	rt_int_add-0x4
    3df4:	mov    rsi,rax
    3df7:	mov    QWORD PTR [rsp+0x8],rsi
    3dfc:	mov    edx,0x7
    3e01:	mov    rdi,rdx
    3e04:	mov    QWORD PTR [rsp+0x10],0x7
    3e0d:	test   rsi,0x1
    3e14:	jne    3e22 <botlish_fn_44+0x1d2>
    3e1a:	mov    rdx,rdi
    3e1d:	jmp    3e4e <botlish_fn_44+0x1fe>
    3e22:	mov    rax,rsi
    3e25:	sar    rax,1
    3e28:	imul   QWORD PTR [rip+0x119]        # 3f48 <botlish_fn_44+0x2f8>
    3e2f:	seto   cl
    3e32:	or     rax,0x1
    3e36:	test   cl,cl
    3e38:	je     3e46 <botlish_fn_44+0x1f6>
    3e3e:	mov    rdx,rdi
    3e41:	jmp    3e4e <botlish_fn_44+0x1fe>
    3e46:	mov    rsi,rax
    3e49:	jmp    3e59 <botlish_fn_44+0x209>
    3e4e:	mov    rdi,rbx
    3e51:	call   3e56 <botlish_fn_44+0x206>
			3e52: R_X86_64_PLT32	rt_int_mul-0x4
    3e56:	mov    rsi,rax
    3e59:	mov    QWORD PTR [rsp],rsi
    3e5d:	mov    r13,rsi
    3e60:	mov    rsi,r12
    3e63:	mov    rdi,rbx
    3e66:	call   3e6b <botlish_fn_44+0x21b>
			3e67: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3e6b:	test   rax,rax
    3e6e:	jne    3e8f <botlish_fn_44+0x23f>
    3e74:	xor    rax,rax
    3e77:	mov    rbx,QWORD PTR [rsp+0x20]
    3e7c:	mov    r12,QWORD PTR [rsp+0x28]
    3e81:	mov    r13,QWORD PTR [rsp+0x30]
    3e86:	add    rsp,0x40
    3e8a:	mov    rsp,rbp
    3e8d:	pop    rbp
    3e8e:	ret
    3e8f:	mov    QWORD PTR [rsp+0x8],rax
    3e94:	mov    QWORD PTR [rsp+0x10],0x5
    3e9d:	test   rax,0x1
    3ea3:	mov    rsi,rax
    3ea6:	je     3ed8 <botlish_fn_44+0x288>
    3eac:	mov    rcx,rsi
    3eaf:	mov    rax,rcx
    3eb2:	sar    rax,1
    3eb5:	imul   QWORD PTR [rip+0x94]        # 3f50 <botlish_fn_44+0x300>
    3ebc:	seto   dil
    3ec0:	or     rax,0x1
    3ec4:	test   dil,dil
    3ec7:	jne    3ed8 <botlish_fn_44+0x288>
    3ecd:	mov    rdx,rax
    3ed0:	mov    rsi,r13
    3ed3:	jmp    3eeb <botlish_fn_44+0x29b>
    3ed8:	mov    edx,0x5
    3edd:	mov    rdi,rbx
    3ee0:	call   3ee5 <botlish_fn_44+0x295>
			3ee1: R_X86_64_PLT32	rt_int_mul-0x4
    3ee5:	mov    rdx,rax
    3ee8:	mov    rsi,r13
    3eeb:	mov    r10,rsi
    3eee:	and    r10,rdx
    3ef1:	test   r10,0x1
    3ef8:	jne    3f1f <botlish_fn_44+0x2cf>
    3efe:	mov    rdi,rbx
    3f01:	call   3f06 <botlish_fn_44+0x2b6>
			3f02: R_X86_64_PLT32	rt_int_cmp-0x4
    3f06:	mov    r8d,0x2
    3f0c:	test   rax,rax
    3f0f:	mov    rax,r8
    3f12:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3f48 <botlish_fn_44+0x2f8>
    3f1a:	jmp    3f2f <botlish_fn_44+0x2df>
    3f1f:	mov    eax,0x2
    3f24:	cmp    rsi,rdx
    3f27:	cmovg  rax,QWORD PTR [rip+0x19]        # 3f48 <botlish_fn_44+0x2f8>
    3f2f:	mov    rbx,QWORD PTR [rsp+0x20]
    3f34:	mov    r12,QWORD PTR [rsp+0x28]
    3f39:	mov    r13,QWORD PTR [rsp+0x30]
    3f3e:	add    rsp,0x40
    3f42:	mov    rsp,rbp
    3f45:	pop    rbp
    3f46:	ret
    3f47:	add    BYTE PTR [rsi],al
    3f49:	add    BYTE PTR [rax],al
    3f4b:	add    BYTE PTR [rax],al
    3f4d:	add    BYTE PTR [rax],al
    3f4f:	add    BYTE PTR [rax+rax*1],al
    3f52:	add    BYTE PTR [rax],al
    3f54:	add    BYTE PTR [rax],al
	...

0000000000003f58 <botlish_entry_44: ht_should_grow<mutarray>>:
    3f58:	push   rbp
    3f59:	mov    rbp,rsp
    3f5c:	mov    rsi,QWORD PTR [rdx]
    3f5f:	call   3f64 <botlish_entry_44+0xc>
			3f60: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3f64:	mov    rsp,rbp
    3f67:	pop    rbp
    3f68:	ret
    3f69:	add    BYTE PTR [rax],al
    3f6b:	add    BYTE PTR [rax],al
    3f6d:	add    BYTE PTR [rax],al
	...

0000000000003f70 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    3f70:	push   rbp
    3f71:	mov    rbp,rsp
    3f74:	sub    rsp,0x40
    3f78:	mov    QWORD PTR [rsp+0x20],rbx
    3f7d:	mov    QWORD PTR [rsp+0x28],r12
    3f82:	mov    QWORD PTR [rsp+0x30],r13
    3f87:	mov    rbx,rdi
    3f8a:	mov    QWORD PTR [rsp+0x10],0x0
    3f93:	mov    QWORD PTR [rsp],rsi
    3f97:	mov    r12,rsi
    3f9a:	mov    rsi,r12
    3f9d:	mov    rdi,rbx
    3fa0:	call   3fa5 <botlish_fn_45+0x35>
			3fa1: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3fa5:	test   rax,rax
    3fa8:	mov    r13,rax
    3fab:	je     4198 <botlish_fn_45+0x228>
    3fb1:	mov    rsi,r12
    3fb4:	mov    rdi,rbx
    3fb7:	call   3fbc <botlish_fn_45+0x4c>
			3fb8: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3fbc:	mov    rcx,rax
    3fbf:	test   rcx,rcx
    3fc2:	je     4198 <botlish_fn_45+0x228>
    3fc8:	mov    edx,0x1
    3fcd:	mov    rax,r13
    3fd0:	test   rax,0x1
    3fd6:	je     3fe4 <botlish_fn_45+0x74>
    3fdc:	mov    r13,rax
    3fdf:	jmp    4008 <botlish_fn_45+0x98>
    3fe4:	xor    edx,edx
    3fe6:	test   rax,0x7
    3fec:	je     3ffa <botlish_fn_45+0x8a>
    3ff2:	mov    r13,rax
    3ff5:	jmp    4008 <botlish_fn_45+0x98>
    3ffa:	movzx  rdx,BYTE PTR [rax]
    3ffe:	mov    r13,rax
    4001:	rex cmp dl,0x1
    4005:	sete   dl
    4008:	test   dl,dl
    400a:	jne    402b <botlish_fn_45+0xbb>
    4010:	mov    rdi,rbx
    4013:	mov    rsi,QWORD PTR [rdi+0x10]
    4017:	mov    rcx,QWORD PTR [rsi+0x40]
    401b:	xor    rdx,rdx
    401e:	mov    rsi,r13
    4021:	call   4026 <botlish_fn_45+0xb6>
			4022: R_X86_64_PLT32	rt_type_error-0x4
    4026:	jmp    4198 <botlish_fn_45+0x228>
    402b:	mov    rsi,r13
    402e:	mov    eax,0x1
    4033:	test   rcx,0x1
    403a:	je     4048 <botlish_fn_45+0xd8>
    4040:	mov    r8,rcx
    4043:	jmp    406d <botlish_fn_45+0xfd>
    4048:	xor    eax,eax
    404a:	test   rcx,0x7
    4051:	je     405f <botlish_fn_45+0xef>
    4057:	mov    r8,rcx
    405a:	jmp    406d <botlish_fn_45+0xfd>
    405f:	movzx  r11,BYTE PTR [rcx]
    4063:	mov    r8,rcx
    4066:	cmp    r11b,0x1
    406a:	sete   al
    406d:	test   al,al
    406f:	jne    4090 <botlish_fn_45+0x120>
    4075:	mov    rdi,rbx
    4078:	mov    rax,QWORD PTR [rdi+0x10]
    407c:	mov    rcx,QWORD PTR [rax+0x40]
    4080:	xor    rdx,rdx
    4083:	mov    rsi,r8
    4086:	call   408b <botlish_fn_45+0x11b>
			4087: R_X86_64_PLT32	rt_type_error-0x4
    408b:	jmp    4198 <botlish_fn_45+0x228>
    4090:	mov    rcx,r8
    4093:	mov    rax,rsi
    4096:	and    rax,rcx
    4099:	test   rax,0x1
    409f:	jne    40c5 <botlish_fn_45+0x155>
    40a5:	mov    rdx,r8
    40a8:	mov    rdi,rbx
    40ab:	call   40b0 <botlish_fn_45+0x140>
			40ac: R_X86_64_PLT32	rt_int_cmp-0x4
    40b0:	mov    ecx,0x2
    40b5:	test   rax,rax
    40b8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 41d0 <botlish_fn_45+0x260>
    40c0:	jmp    40d8 <botlish_fn_45+0x168>
    40c5:	mov    ecx,0x2
    40ca:	mov    r9,r8
    40cd:	cmp    rsi,r9
    40d0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 41d0 <botlish_fn_45+0x260>
    40d8:	cmp    rcx,0x6
    40dc:	je     4168 <botlish_fn_45+0x1f8>
    40e2:	mov    rsi,r12
    40e5:	mov    rdi,rbx
    40e8:	call   40ed <botlish_fn_45+0x17d>
			40e9: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    40ed:	test   rax,rax
    40f0:	je     4198 <botlish_fn_45+0x228>
    40f6:	mov    QWORD PTR [rsp+0x8],rax
    40fb:	mov    QWORD PTR [rsp+0x10],0x5
    4104:	test   rax,0x1
    410a:	mov    rsi,rax
    410d:	je     413a <botlish_fn_45+0x1ca>
    4113:	mov    rcx,rsi
    4116:	mov    rax,rcx
    4119:	sar    rax,1
    411c:	imul   QWORD PTR [rip+0xb5]        # 41d8 <botlish_fn_45+0x268>
    4123:	seto   cl
    4126:	or     rax,0x1
    412a:	test   cl,cl
    412c:	jne    413a <botlish_fn_45+0x1ca>
    4132:	mov    rdx,rax
    4135:	jmp    414a <botlish_fn_45+0x1da>
    413a:	mov    edx,0x5
    413f:	mov    rdi,rbx
    4142:	call   4147 <botlish_fn_45+0x1d7>
			4143: R_X86_64_PLT32	rt_int_mul-0x4
    4147:	mov    rdx,rax
    414a:	mov    QWORD PTR [rsp+0x8],rdx
    414f:	mov    rsi,r12
    4152:	mov    rdi,rbx
    4155:	call   415a <botlish_fn_45+0x1ea>
			4156: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    415a:	test   rax,rax
    415d:	je     4198 <botlish_fn_45+0x228>
    4163:	jmp    41b3 <botlish_fn_45+0x243>
    4168:	mov    rsi,r12
    416b:	mov    rdi,rbx
    416e:	call   4173 <botlish_fn_45+0x203>
			416f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4173:	test   rax,rax
    4176:	je     4198 <botlish_fn_45+0x228>
    417c:	mov    QWORD PTR [rsp+0x8],rax
    4181:	mov    rdx,rax
    4184:	mov    rsi,r12
    4187:	mov    rdi,rbx
    418a:	call   418f <botlish_fn_45+0x21f>
			418b: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    418f:	test   rax,rax
    4192:	jne    41b3 <botlish_fn_45+0x243>
    4198:	xor    rax,rax
    419b:	mov    rbx,QWORD PTR [rsp+0x20]
    41a0:	mov    r12,QWORD PTR [rsp+0x28]
    41a5:	mov    r13,QWORD PTR [rsp+0x30]
    41aa:	add    rsp,0x40
    41ae:	mov    rsp,rbp
    41b1:	pop    rbp
    41b2:	ret
    41b3:	mov    rbx,QWORD PTR [rsp+0x20]
    41b8:	mov    r12,QWORD PTR [rsp+0x28]
    41bd:	mov    r13,QWORD PTR [rsp+0x30]
    41c2:	add    rsp,0x40
    41c6:	mov    rsp,rbp
    41c9:	pop    rbp
    41ca:	ret
    41cb:	add    BYTE PTR [rax],al
    41cd:	add    BYTE PTR [rax],al
    41cf:	add    BYTE PTR [rsi],al
    41d1:	add    BYTE PTR [rax],al
    41d3:	add    BYTE PTR [rax],al
    41d5:	add    BYTE PTR [rax],al
    41d7:	add    BYTE PTR [rax+rax*1],al
    41da:	add    BYTE PTR [rax],al
    41dc:	add    BYTE PTR [rax],al
	...

00000000000041e0 <botlish_entry_45: ht_grow_or_clean<mutarray>>:
    41e0:	push   rbp
    41e1:	mov    rbp,rsp
    41e4:	mov    rsi,QWORD PTR [rdx]
    41e7:	call   41ec <botlish_entry_45+0xc>
			41e8: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    41ec:	mov    rsp,rbp
    41ef:	pop    rbp
    41f0:	ret
    41f1:	add    BYTE PTR [rax],al
    41f3:	add    BYTE PTR [rax],al
    41f5:	add    BYTE PTR [rax],al
	...

00000000000041f8 <botlish_fn_46: ht_place<mutarray, int, str, str>>:
    41f8:	push   rbp
    41f9:	mov    rbp,rsp
    41fc:	sub    rsp,0x70
    4200:	mov    QWORD PTR [rsp+0x40],rbx
    4205:	mov    QWORD PTR [rsp+0x48],r12
    420a:	mov    QWORD PTR [rsp+0x50],r13
    420f:	mov    QWORD PTR [rsp+0x58],r14
    4214:	mov    QWORD PTR [rsp+0x60],r15
    4219:	mov    rbx,rdi
    421c:	mov    r14,r8
    421f:	mov    r15,rdx
    4222:	mov    QWORD PTR [rsp+0x28],rcx
    4227:	mov    QWORD PTR [rsp],rsi
    422b:	mov    r12,rsi
    422e:	mov    rsi,r12
    4231:	mov    rdi,rbx
    4234:	call   4239 <botlish_fn_46+0x41>
			4235: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    4239:	test   rax,rax
    423c:	je     45a0 <botlish_fn_46+0x3a8>
    4242:	xor    ecx,ecx
    4244:	test   rax,0x7
    424a:	je     425a <botlish_fn_46+0x62>
    4250:	mov    QWORD PTR [rsp+0x30],rax
    4255:	jmp    426a <botlish_fn_46+0x72>
    425a:	movzx  rcx,BYTE PTR [rax]
    425e:	mov    QWORD PTR [rsp+0x30],rax
    4263:	rex cmp cl,0x8
    4267:	sete   cl
    426a:	test   cl,cl
    426c:	jne    4291 <botlish_fn_46+0x99>
    4272:	mov    rdi,rbx
    4275:	mov    rax,QWORD PTR [rdi+0x10]
    4279:	mov    rcx,QWORD PTR [rax+0x30]
    427d:	mov    edx,0x8
    4282:	mov    rsi,QWORD PTR [rsp+0x30]
    4287:	call   428c <botlish_fn_46+0x94>
			4288: R_X86_64_PLT32	rt_type_error-0x4
    428c:	jmp    45a0 <botlish_fn_46+0x3a8>
    4291:	mov    rdx,r15
    4294:	mov    rsi,QWORD PTR [rsp+0x30]
    4299:	mov    rdi,rbx
    429c:	call   42a1 <botlish_fn_46+0xa9>
			429d: R_X86_64_PLT32	rt_mutarray_get-0x4
    42a1:	test   rax,rax
    42a4:	je     45a0 <botlish_fn_46+0x3a8>
    42aa:	mov    QWORD PTR [rsp+0x8],rax
    42af:	mov    r13,rax
    42b2:	mov    ecx,0x3
    42b7:	mov    rsi,QWORD PTR [rsp+0x30]
    42bc:	mov    rdx,r15
    42bf:	mov    rdi,rbx
    42c2:	call   42c7 <botlish_fn_46+0xcf>
			42c3: R_X86_64_PLT32	rt_mutarray_set-0x4
    42c7:	test   rax,rax
    42ca:	je     45a0 <botlish_fn_46+0x3a8>
    42d0:	mov    rsi,r12
    42d3:	mov    rdi,rbx
    42d6:	call   42db <botlish_fn_46+0xe3>
			42d7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    42db:	test   rax,rax
    42de:	je     45a0 <botlish_fn_46+0x3a8>
    42e4:	xor    ecx,ecx
    42e6:	test   rax,0x7
    42ec:	je     42fa <botlish_fn_46+0x102>
    42f2:	mov    rsi,rax
    42f5:	jmp    4308 <botlish_fn_46+0x110>
    42fa:	movzx  rcx,BYTE PTR [rax]
    42fe:	mov    rsi,rax
    4301:	rex cmp cl,0x8
    4305:	sete   cl
    4308:	test   cl,cl
    430a:	jne    4329 <botlish_fn_46+0x131>
    4310:	mov    rdi,rbx
    4313:	mov    rax,QWORD PTR [rdi+0x10]
    4317:	mov    rcx,QWORD PTR [rax]
    431a:	mov    edx,0x8
    431f:	call   4324 <botlish_fn_46+0x12c>
			4320: R_X86_64_PLT32	rt_type_error-0x4
    4324:	jmp    45a0 <botlish_fn_46+0x3a8>
    4329:	mov    rcx,QWORD PTR [rsp+0x28]
    432e:	mov    rdx,r15
    4331:	mov    rdi,rbx
    4334:	call   4339 <botlish_fn_46+0x141>
			4335: R_X86_64_PLT32	rt_mutarray_set-0x4
    4339:	test   rax,rax
    433c:	je     45a0 <botlish_fn_46+0x3a8>
    4342:	mov    rsi,r12
    4345:	mov    rdi,rbx
    4348:	call   434d <botlish_fn_46+0x155>
			4349: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    434d:	test   rax,rax
    4350:	je     45a0 <botlish_fn_46+0x3a8>
    4356:	xor    esi,esi
    4358:	test   rax,0x7
    435e:	jne    4370 <botlish_fn_46+0x178>
    4364:	movzx  rcx,BYTE PTR [rax]
    4368:	rex cmp cl,0x8
    436c:	sete   sil
    4370:	test   sil,sil
    4373:	jne    4395 <botlish_fn_46+0x19d>
    4379:	mov    rdi,rbx
    437c:	mov    rsi,QWORD PTR [rdi+0x10]
    4380:	mov    rcx,QWORD PTR [rsi]
    4383:	mov    edx,0x8
    4388:	mov    rsi,rax
    438b:	call   4390 <botlish_fn_46+0x198>
			438c: R_X86_64_PLT32	rt_type_error-0x4
    4390:	jmp    45a0 <botlish_fn_46+0x3a8>
    4395:	mov    rcx,r14
    4398:	mov    rdx,r15
    439b:	mov    rsi,rax
    439e:	mov    rdi,rbx
    43a1:	call   43a6 <botlish_fn_46+0x1ae>
			43a2: R_X86_64_PLT32	rt_mutarray_set-0x4
    43a6:	test   rax,rax
    43a9:	je     45a0 <botlish_fn_46+0x3a8>
    43af:	mov    QWORD PTR [rsp+0x10],0x7
    43b8:	mov    rsi,r12
    43bb:	mov    rdi,rbx
    43be:	call   43c3 <botlish_fn_46+0x1cb>
			43bf: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    43c3:	test   rax,rax
    43c6:	je     45a0 <botlish_fn_46+0x3a8>
    43cc:	mov    QWORD PTR [rsp+0x18],rax
    43d1:	mov    QWORD PTR [rsp+0x20],0x3
    43da:	mov    ecx,0x1
    43df:	test   rax,0x1
    43e5:	je     43f3 <botlish_fn_46+0x1fb>
    43eb:	mov    rsi,rax
    43ee:	jmp    4417 <botlish_fn_46+0x21f>
    43f3:	xor    ecx,ecx
    43f5:	test   rax,0x7
    43fb:	je     4409 <botlish_fn_46+0x211>
    4401:	mov    rsi,rax
    4404:	jmp    4417 <botlish_fn_46+0x21f>
    4409:	movzx  rcx,BYTE PTR [rax]
    440d:	mov    rsi,rax
    4410:	rex cmp cl,0x1
    4414:	sete   cl
    4417:	test   cl,cl
    4419:	jne    4437 <botlish_fn_46+0x23f>
    441f:	mov    rdi,rbx
    4422:	mov    rax,QWORD PTR [rdi+0x10]
    4426:	mov    rcx,QWORD PTR [rax+0x38]
    442a:	xor    rdx,rdx
    442d:	call   4432 <botlish_fn_46+0x23a>
			442e: R_X86_64_PLT32	rt_type_error-0x4
    4432:	jmp    45a0 <botlish_fn_46+0x3a8>
    4437:	test   rsi,0x1
    443e:	je     4456 <botlish_fn_46+0x25e>
    4444:	mov    rcx,rsi
    4447:	add    rcx,0x2
    444b:	seto   al
    444e:	test   al,al
    4450:	je     4466 <botlish_fn_46+0x26e>
    4456:	mov    edx,0x3
    445b:	mov    rdi,rbx
    445e:	call   4463 <botlish_fn_46+0x26b>
			445f: R_X86_64_PLT32	rt_int_add-0x4
    4463:	mov    rcx,rax
    4466:	mov    edx,0x7
    446b:	mov    rsi,r12
    446e:	mov    rdi,rbx
    4471:	call   4476 <botlish_fn_46+0x27e>
			4472: R_X86_64_PLT32	rt_mutarray_set-0x4
    4476:	test   rax,rax
    4479:	je     45a0 <botlish_fn_46+0x3a8>
    447f:	mov    rax,r13
    4482:	test   rax,0x1
    4488:	jne    44ac <botlish_fn_46+0x2b4>
    448e:	mov    edx,0x5
    4493:	mov    rsi,r13
    4496:	mov    rdi,rbx
    4499:	call   449e <botlish_fn_46+0x2a6>
			449a: R_X86_64_PLT32	rt_value_eq-0x4
    449e:	test   rax,rax
    44a1:	je     45a0 <botlish_fn_46+0x3a8>
    44a7:	jmp    44c0 <botlish_fn_46+0x2c8>
    44ac:	mov    rsi,r13
    44af:	mov    eax,0x2
    44b4:	cmp    rsi,0x5
    44b8:	cmove  rax,QWORD PTR [rip+0x130]        # 45f0 <botlish_fn_46+0x3f8>
    44c0:	cmp    rax,0x6
    44c4:	jne    45c5 <botlish_fn_46+0x3cd>
    44ca:	mov    QWORD PTR [rsp+0x8],0x9
    44d3:	mov    rsi,r12
    44d6:	mov    rdi,rbx
    44d9:	call   44de <botlish_fn_46+0x2e6>
			44da: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    44de:	test   rax,rax
    44e1:	je     45a0 <botlish_fn_46+0x3a8>
    44e7:	mov    QWORD PTR [rsp+0x10],rax
    44ec:	mov    QWORD PTR [rsp+0x18],0x3
    44f5:	mov    ecx,0x1
    44fa:	test   rax,0x1
    4500:	je     450e <botlish_fn_46+0x316>
    4506:	mov    rsi,rax
    4509:	jmp    4532 <botlish_fn_46+0x33a>
    450e:	xor    ecx,ecx
    4510:	test   rax,0x7
    4516:	je     4524 <botlish_fn_46+0x32c>
    451c:	mov    rsi,rax
    451f:	jmp    4532 <botlish_fn_46+0x33a>
    4524:	movzx  rcx,BYTE PTR [rax]
    4528:	mov    rsi,rax
    452b:	rex cmp cl,0x1
    452f:	sete   cl
    4532:	test   cl,cl
    4534:	jne    4552 <botlish_fn_46+0x35a>
    453a:	mov    rdi,rbx
    453d:	mov    rcx,QWORD PTR [rdi+0x10]
    4541:	mov    rcx,QWORD PTR [rcx+0x48]
    4545:	xor    rdx,rdx
    4548:	call   454d <botlish_fn_46+0x355>
			4549: R_X86_64_PLT32	rt_type_error-0x4
    454d:	jmp    45a0 <botlish_fn_46+0x3a8>
    4552:	test   rsi,0x1
    4559:	je     4577 <botlish_fn_46+0x37f>
    455f:	mov    r8,rsi
    4562:	sub    r8,0x3
    4566:	seto   dil
    456a:	lea    rcx,[r8+0x1]
    456e:	test   dil,dil
    4571:	je     4587 <botlish_fn_46+0x38f>
    4577:	mov    edx,0x3
    457c:	mov    rdi,rbx
    457f:	call   4584 <botlish_fn_46+0x38c>
			4580: R_X86_64_PLT32	rt_int_sub-0x4
    4584:	mov    rcx,rax
    4587:	mov    edx,0x9
    458c:	mov    rsi,r12
    458f:	mov    rdi,rbx
    4592:	call   4597 <botlish_fn_46+0x39f>
			4593: R_X86_64_PLT32	rt_mutarray_set-0x4
    4597:	test   rax,rax
    459a:	jne    45c5 <botlish_fn_46+0x3cd>
    45a0:	xor    rax,rax
    45a3:	mov    rbx,QWORD PTR [rsp+0x40]
    45a8:	mov    r12,QWORD PTR [rsp+0x48]
    45ad:	mov    r13,QWORD PTR [rsp+0x50]
    45b2:	mov    r14,QWORD PTR [rsp+0x58]
    45b7:	mov    r15,QWORD PTR [rsp+0x60]
    45bc:	add    rsp,0x70
    45c0:	mov    rsp,rbp
    45c3:	pop    rbp
    45c4:	ret
    45c5:	mov    eax,0xa
    45ca:	mov    rbx,QWORD PTR [rsp+0x40]
    45cf:	mov    r12,QWORD PTR [rsp+0x48]
    45d4:	mov    r13,QWORD PTR [rsp+0x50]
    45d9:	mov    r14,QWORD PTR [rsp+0x58]
    45de:	mov    r15,QWORD PTR [rsp+0x60]
    45e3:	add    rsp,0x70
    45e7:	mov    rsp,rbp
    45ea:	pop    rbp
    45eb:	ret
    45ec:	add    BYTE PTR [rax],al
    45ee:	add    BYTE PTR [rax],al
    45f0:	(bad)
    45f1:	add    BYTE PTR [rax],al
    45f3:	add    BYTE PTR [rax],al
    45f5:	add    BYTE PTR [rax],al
	...

00000000000045f8 <botlish_entry_46: ht_place<mutarray, int, str, str>>:
    45f8:	push   rbp
    45f9:	mov    rbp,rsp
    45fc:	mov    rsi,QWORD PTR [rdx]
    45ff:	mov    r9,QWORD PTR [rdx+0x8]
    4603:	mov    rcx,QWORD PTR [rdx+0x10]
    4607:	mov    r8,QWORD PTR [rdx+0x18]
    460b:	mov    rdx,r9
    460e:	call   4613 <botlish_entry_46+0x1b>
			460f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4613:	mov    rsp,rbp
    4616:	pop    rbp
    4617:	ret

0000000000004618 <botlish_fn_47: ht_set<mutarray, str, str>>:
    4618:	push   rbp
    4619:	mov    rbp,rsp
    461c:	sub    rsp,0x60
    4620:	mov    QWORD PTR [rsp+0x30],rbx
    4625:	mov    QWORD PTR [rsp+0x38],r12
    462a:	mov    QWORD PTR [rsp+0x40],r13
    462f:	mov    QWORD PTR [rsp+0x48],r14
    4634:	mov    QWORD PTR [rsp+0x50],r15
    4639:	mov    rbx,rdi
    463c:	mov    r13,rdx
    463f:	mov    QWORD PTR [rsp],rsi
    4643:	mov    r14,rsi
    4646:	mov    QWORD PTR [rsp+0x8],rdx
    464b:	mov    QWORD PTR [rsp+0x10],rcx
    4650:	mov    r12,rcx
    4653:	mov    rdx,r13
    4656:	mov    rsi,r14
    4659:	mov    rdi,rbx
    465c:	call   4661 <botlish_fn_47+0x49>
			465d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    4661:	test   rax,rax
    4664:	je     48ce <botlish_fn_47+0x2b6>
    466a:	mov    QWORD PTR [rsp+0x18],rax
    466f:	mov    rcx,rax
    4672:	mov    r8,0xffffffffffffffff
    4679:	mov    QWORD PTR [rsp+0x28],r8
    467e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4687:	mov    rdx,r13
    468a:	mov    rsi,r14
    468d:	mov    rdi,rbx
    4690:	call   4695 <botlish_fn_47+0x7d>
			4691: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4695:	mov    rcx,rax
    4698:	mov    r15,rax
    469b:	test   rax,rcx
    469e:	je     48ce <botlish_fn_47+0x2b6>
    46a4:	mov    rax,r15
    46a7:	mov    QWORD PTR [rsp+0x18],rax
    46ac:	mov    rsi,r14
    46af:	mov    rdi,rbx
    46b2:	call   46b7 <botlish_fn_47+0x9f>
			46b3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    46b7:	test   rax,rax
    46ba:	je     48ce <botlish_fn_47+0x2b6>
    46c0:	xor    ecx,ecx
    46c2:	test   rax,0x7
    46c8:	je     46d6 <botlish_fn_47+0xbe>
    46ce:	mov    r8,rax
    46d1:	jmp    46e4 <botlish_fn_47+0xcc>
    46d6:	movzx  rcx,BYTE PTR [rax]
    46da:	mov    r8,rax
    46dd:	rex cmp cl,0x8
    46e1:	sete   cl
    46e4:	test   cl,cl
    46e6:	jne    4709 <botlish_fn_47+0xf1>
    46ec:	mov    rdi,rbx
    46ef:	mov    rsi,QWORD PTR [rdi+0x10]
    46f3:	mov    rcx,QWORD PTR [rsi+0x30]
    46f7:	mov    edx,0x8
    46fc:	mov    rsi,r8
    46ff:	call   4704 <botlish_fn_47+0xec>
			4700: R_X86_64_PLT32	rt_type_error-0x4
    4704:	jmp    48ce <botlish_fn_47+0x2b6>
    4709:	mov    rsi,r8
    470c:	mov    rdx,r15
    470f:	mov    rdi,rbx
    4712:	call   4717 <botlish_fn_47+0xff>
			4713: R_X86_64_PLT32	rt_mutarray_get-0x4
    4717:	test   rax,rax
    471a:	je     48ce <botlish_fn_47+0x2b6>
    4720:	test   rax,0x1
    4726:	mov    rsi,rax
    4729:	jne    474a <botlish_fn_47+0x132>
    472f:	mov    edx,0x3
    4734:	mov    rdi,rbx
    4737:	call   473c <botlish_fn_47+0x124>
			4738: R_X86_64_PLT32	rt_value_eq-0x4
    473c:	test   rax,rax
    473f:	je     48ce <botlish_fn_47+0x2b6>
    4745:	jmp    475b <botlish_fn_47+0x143>
    474a:	mov    eax,0x2
    474f:	cmp    rsi,0x3
    4753:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4920 <botlish_fn_47+0x308>
    475b:	cmp    rax,0x6
    475f:	je     485e <botlish_fn_47+0x246>
    4765:	mov    rsi,r14
    4768:	mov    rdi,rbx
    476b:	call   4770 <botlish_fn_47+0x158>
			476c: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    4770:	test   rax,rax
    4773:	je     48ce <botlish_fn_47+0x2b6>
    4779:	cmp    rax,0x6
    477d:	je     47c2 <botlish_fn_47+0x1aa>
    4783:	mov    rcx,r13
    4786:	mov    rdx,r15
    4789:	mov    rsi,r14
    478c:	mov    rdi,rbx
    478f:	mov    r8,r12
    4792:	call   4797 <botlish_fn_47+0x17f>
			4793: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4797:	test   rax,rax
    479a:	je     48ce <botlish_fn_47+0x2b6>
    47a0:	mov    rbx,QWORD PTR [rsp+0x30]
    47a5:	mov    r12,QWORD PTR [rsp+0x38]
    47aa:	mov    r13,QWORD PTR [rsp+0x40]
    47af:	mov    r14,QWORD PTR [rsp+0x48]
    47b4:	mov    r15,QWORD PTR [rsp+0x50]
    47b9:	add    rsp,0x60
    47bd:	mov    rsp,rbp
    47c0:	pop    rbp
    47c1:	ret
    47c2:	mov    rsi,r14
    47c5:	mov    rdi,rbx
    47c8:	call   47cd <botlish_fn_47+0x1b5>
			47c9: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    47cd:	test   rax,rax
    47d0:	je     48ce <botlish_fn_47+0x2b6>
    47d6:	mov    rdx,r13
    47d9:	mov    rsi,r14
    47dc:	mov    rdi,rbx
    47df:	call   47e4 <botlish_fn_47+0x1cc>
			47e0: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    47e4:	test   rax,rax
    47e7:	je     48ce <botlish_fn_47+0x2b6>
    47ed:	mov    QWORD PTR [rsp+0x18],rax
    47f2:	mov    rcx,rax
    47f5:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    47fe:	mov    r8,QWORD PTR [rsp+0x28]
    4803:	mov    rdx,r13
    4806:	mov    rsi,r14
    4809:	mov    rdi,rbx
    480c:	call   4811 <botlish_fn_47+0x1f9>
			480d: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4811:	test   rax,rax
    4814:	je     48ce <botlish_fn_47+0x2b6>
    481a:	mov    QWORD PTR [rsp+0x18],rax
    481f:	mov    rcx,r13
    4822:	mov    rdx,rax
    4825:	mov    rsi,r14
    4828:	mov    rdi,rbx
    482b:	mov    r8,r12
    482e:	call   4833 <botlish_fn_47+0x21b>
			482f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4833:	test   rax,rax
    4836:	je     48ce <botlish_fn_47+0x2b6>
    483c:	mov    rbx,QWORD PTR [rsp+0x30]
    4841:	mov    r12,QWORD PTR [rsp+0x38]
    4846:	mov    r13,QWORD PTR [rsp+0x40]
    484b:	mov    r14,QWORD PTR [rsp+0x48]
    4850:	mov    r15,QWORD PTR [rsp+0x50]
    4855:	add    rsp,0x60
    4859:	mov    rsp,rbp
    485c:	pop    rbp
    485d:	ret
    485e:	mov    rsi,r14
    4861:	mov    rdi,rbx
    4864:	call   4869 <botlish_fn_47+0x251>
			4865: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    4869:	test   rax,rax
    486c:	je     48ce <botlish_fn_47+0x2b6>
    4872:	xor    ecx,ecx
    4874:	test   rax,0x7
    487a:	je     4888 <botlish_fn_47+0x270>
    4880:	mov    rsi,rax
    4883:	jmp    4896 <botlish_fn_47+0x27e>
    4888:	movzx  rcx,BYTE PTR [rax]
    488c:	mov    rsi,rax
    488f:	rex cmp cl,0x8
    4893:	sete   cl
    4896:	test   cl,cl
    4898:	jne    48b7 <botlish_fn_47+0x29f>
    489e:	mov    rdi,rbx
    48a1:	mov    rax,QWORD PTR [rdi+0x10]
    48a5:	mov    rcx,QWORD PTR [rax]
    48a8:	mov    edx,0x8
    48ad:	call   48b2 <botlish_fn_47+0x29a>
			48ae: R_X86_64_PLT32	rt_type_error-0x4
    48b2:	jmp    48ce <botlish_fn_47+0x2b6>
    48b7:	mov    rcx,r12
    48ba:	mov    rdx,r15
    48bd:	mov    rdi,rbx
    48c0:	call   48c5 <botlish_fn_47+0x2ad>
			48c1: R_X86_64_PLT32	rt_mutarray_set-0x4
    48c5:	test   rax,rax
    48c8:	jne    48f3 <botlish_fn_47+0x2db>
    48ce:	xor    rax,rax
    48d1:	mov    rbx,QWORD PTR [rsp+0x30]
    48d6:	mov    r12,QWORD PTR [rsp+0x38]
    48db:	mov    r13,QWORD PTR [rsp+0x40]
    48e0:	mov    r14,QWORD PTR [rsp+0x48]
    48e5:	mov    r15,QWORD PTR [rsp+0x50]
    48ea:	add    rsp,0x60
    48ee:	mov    rsp,rbp
    48f1:	pop    rbp
    48f2:	ret
    48f3:	mov    eax,0xa
    48f8:	mov    rbx,QWORD PTR [rsp+0x30]
    48fd:	mov    r12,QWORD PTR [rsp+0x38]
    4902:	mov    r13,QWORD PTR [rsp+0x40]
    4907:	mov    r14,QWORD PTR [rsp+0x48]
    490c:	mov    r15,QWORD PTR [rsp+0x50]
    4911:	add    rsp,0x60
    4915:	mov    rsp,rbp
    4918:	pop    rbp
    4919:	ret
    491a:	add    BYTE PTR [rax],al
    491c:	add    BYTE PTR [rax],al
    491e:	add    BYTE PTR [rax],al
    4920:	(bad)
    4921:	add    BYTE PTR [rax],al
    4923:	add    BYTE PTR [rax],al
    4925:	add    BYTE PTR [rax],al
	...

0000000000004928 <botlish_entry_47: ht_set<mutarray, str, str>>:
    4928:	push   rbp
    4929:	mov    rbp,rsp
    492c:	mov    rsi,QWORD PTR [rdx]
    492f:	mov    r8,QWORD PTR [rdx+0x8]
    4933:	mov    rcx,QWORD PTR [rdx+0x10]
    4937:	mov    rdx,r8
    493a:	call   493f <botlish_entry_47+0x17>
			493b: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    493f:	mov    rsp,rbp
    4942:	pop    rbp
    4943:	ret

0000000000004944 <botlish_fn_48: row_new<bool, int>>:
    4944:	push   rbp
    4945:	mov    rbp,rsp
    4948:	sub    rsp,0x10
    494c:	mov    QWORD PTR [rsp],rdx
    4950:	mov    r8,rdx
    4953:	cmp    rsi,0x6
    4957:	je     4974 <botlish_fn_48+0x30>
    495d:	call   4962 <botlish_fn_48+0x1e>
			495e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    4962:	test   rax,rax
    4965:	je     4985 <botlish_fn_48+0x41>
    496b:	add    rsp,0x10
    496f:	mov    rsp,rbp
    4972:	pop    rbp
    4973:	ret
    4974:	mov    rsi,r8
    4977:	call   497c <botlish_fn_48+0x38>
			4978: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    497c:	test   rax,rax
    497f:	jne    4991 <botlish_fn_48+0x4d>
    4985:	xor    rax,rax
    4988:	add    rsp,0x10
    498c:	mov    rsp,rbp
    498f:	pop    rbp
    4990:	ret
    4991:	add    rsp,0x10
    4995:	mov    rsp,rbp
    4998:	pop    rbp
    4999:	ret

000000000000499a <botlish_entry_48: row_new<bool, int>>:
    499a:	push   rbp
    499b:	mov    rbp,rsp
    499e:	mov    rsi,QWORD PTR [rdx]
    49a1:	mov    rdx,QWORD PTR [rdx+0x8]
    49a5:	call   49aa <botlish_entry_48+0x10>
			49a6: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    49aa:	mov    rsp,rbp
    49ad:	pop    rbp
    49ae:	ret

00000000000049af <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    49af:	push   rbp
    49b0:	mov    rbp,rsp
    49b3:	sub    rsp,0x70
    49b7:	mov    QWORD PTR [rsp+0x40],rbx
    49bc:	mov    QWORD PTR [rsp+0x48],r12
    49c1:	mov    QWORD PTR [rsp+0x50],r13
    49c6:	mov    QWORD PTR [rsp+0x58],r14
    49cb:	mov    QWORD PTR [rsp+0x60],r15
    49d0:	mov    QWORD PTR [rsp+0x28],rdi
    49d5:	mov    QWORD PTR [rsp],rsi
    49d9:	mov    r14,rsi
    49dc:	mov    QWORD PTR [rsp+0x8],rdx
    49e1:	mov    QWORD PTR [rsp+0x10],rcx
    49e6:	mov    r13,rcx
    49e9:	sar    r8,1
    49ec:	mov    rbx,r8
    49ef:	mov    r15,r9
    49f2:	cmp    rbx,r15
    49f5:	jge    4b00 <botlish_fn_49+0x151>
    49fb:	mov    r12,rdx
    49fe:	mov    rdx,QWORD PTR [r12+0x8]
    4a03:	mov    rcx,rbx
    4a06:	shl    rcx,1
    4a09:	or     rcx,0x1
    4a0d:	sar    rcx,1
    4a10:	cmp    rcx,rdx
    4a13:	jb     4a41 <botlish_fn_49+0x92>
    4a19:	mov    rdx,rbx
    4a1c:	shl    rdx,1
    4a1f:	or     rdx,0x1
    4a23:	mov    rsi,r12
    4a26:	mov    rdi,QWORD PTR [rsp+0x28]
    4a2b:	call   4a30 <botlish_fn_49+0x81>
			4a2c: R_X86_64_PLT32	rt_list_get-0x4
    4a30:	test   rax,rax
    4a33:	je     4abe <botlish_fn_49+0x10f>
    4a39:	mov    rdx,rax
    4a3c:	jmp    4a4a <botlish_fn_49+0x9b>
    4a41:	mov    rax,QWORD PTR [r12+0x10]
    4a46:	mov    rdx,QWORD PTR [rax+rcx*8]
    4a4a:	mov    QWORD PTR [rsp+0x18],rdx
    4a4f:	mov    QWORD PTR [rsp+0x30],rdx
    4a54:	mov    rax,QWORD PTR [r13+0x8]
    4a58:	mov    rcx,rbx
    4a5b:	shl    rcx,1
    4a5e:	or     rcx,0x1
    4a62:	sar    rcx,1
    4a65:	cmp    rcx,rax
    4a68:	jb     4a96 <botlish_fn_49+0xe7>
    4a6e:	mov    rdx,rbx
    4a71:	shl    rdx,1
    4a74:	or     rdx,0x1
    4a78:	mov    rsi,r13
    4a7b:	mov    rdi,QWORD PTR [rsp+0x28]
    4a80:	call   4a85 <botlish_fn_49+0xd6>
			4a81: R_X86_64_PLT32	rt_list_get-0x4
    4a85:	test   rax,rax
    4a88:	je     4abe <botlish_fn_49+0x10f>
    4a8e:	mov    rcx,rax
    4a91:	jmp    4a9e <botlish_fn_49+0xef>
    4a96:	mov    rax,QWORD PTR [r13+0x10]
    4a9a:	mov    rcx,QWORD PTR [rax+rcx*8]
    4a9e:	mov    QWORD PTR [rsp+0x20],rcx
    4aa3:	mov    rdx,QWORD PTR [rsp+0x30]
    4aa8:	mov    rsi,r14
    4aab:	mov    rdi,QWORD PTR [rsp+0x28]
    4ab0:	call   4ab5 <botlish_fn_49+0x106>
			4ab1: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4ab5:	test   rax,rax
    4ab8:	jne    4ae3 <botlish_fn_49+0x134>
    4abe:	xor    rax,rax
    4ac1:	mov    rbx,QWORD PTR [rsp+0x40]
    4ac6:	mov    r12,QWORD PTR [rsp+0x48]
    4acb:	mov    r13,QWORD PTR [rsp+0x50]
    4ad0:	mov    r14,QWORD PTR [rsp+0x58]
    4ad5:	mov    r15,QWORD PTR [rsp+0x60]
    4ada:	add    rsp,0x70
    4ade:	mov    rsp,rbp
    4ae1:	pop    rbp
    4ae2:	ret
    4ae3:	mov    QWORD PTR [rsp],r14
    4ae7:	mov    QWORD PTR [rsp+0x8],r12
    4aec:	mov    QWORD PTR [rsp+0x10],r13
    4af1:	add    rbx,0x1
    4af8:	mov    rdx,r12
    4afb:	jmp    49f2 <botlish_fn_49+0x43>
    4b00:	mov    rax,r14
    4b03:	mov    rbx,QWORD PTR [rsp+0x40]
    4b08:	mov    r12,QWORD PTR [rsp+0x48]
    4b0d:	mov    r13,QWORD PTR [rsp+0x50]
    4b12:	mov    r14,QWORD PTR [rsp+0x58]
    4b17:	mov    r15,QWORD PTR [rsp+0x60]
    4b1c:	add    rsp,0x70
    4b20:	mov    rsp,rbp
    4b23:	pop    rbp
    4b24:	ret

0000000000004b25 <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4b25:	push   rbp
    4b26:	mov    rbp,rsp
    4b29:	mov    rsi,QWORD PTR [rdx]
    4b2c:	mov    r10,QWORD PTR [rdx+0x8]
    4b30:	mov    rcx,QWORD PTR [rdx+0x10]
    4b34:	mov    r8,QWORD PTR [rdx+0x18]
    4b38:	mov    r9,QWORD PTR [rdx+0x20]
    4b3c:	sar    r9,1
    4b3f:	mov    rdx,r10
    4b42:	call   4b47 <botlish_entry_49+0x22>
			4b43: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4b47:	mov    rsp,rbp
    4b4a:	pop    rbp
    4b4b:	ret

0000000000004b4c <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4b4c:	push   rbp
    4b4d:	mov    rbp,rsp
    4b50:	sub    rsp,0x50
    4b54:	mov    QWORD PTR [rsp+0x20],rbx
    4b59:	mov    QWORD PTR [rsp+0x28],r12
    4b5e:	mov    QWORD PTR [rsp+0x30],r13
    4b63:	mov    QWORD PTR [rsp+0x38],r14
    4b68:	mov    QWORD PTR [rsp+0x40],r15
    4b6d:	mov    r12,rdi
    4b70:	mov    QWORD PTR [rsp],rsi
    4b74:	mov    r15,rsi
    4b77:	mov    QWORD PTR [rsp+0x8],rdx
    4b7c:	mov    QWORD PTR [rsp+0x10],rcx
    4b81:	mov    r13,rcx
    4b84:	mov    QWORD PTR [rsp+0x18],r8
    4b89:	mov    rsi,r8
    4b8c:	mov    rdi,r12
    4b8f:	call   4b94 <botlish_fn_50+0x48>
			4b90: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4b94:	test   rax,rax
    4b97:	je     4be1 <botlish_fn_50+0x95>
    4b9d:	mov    QWORD PTR [rsp+0x8],rax
    4ba2:	mov    r14,rax
    4ba5:	mov    ebx,0x1
    4baa:	mov    QWORD PTR [rsp+0x18],0x1
    4bb3:	mov    rsi,r13
    4bb6:	mov    rdi,r12
    4bb9:	call   4bbe <botlish_fn_50+0x72>
			4bba: R_X86_64_PLT32	rt_list_len-0x4
    4bbe:	mov    r9,rax
    4bc1:	sar    r9,1
    4bc4:	mov    rcx,r13
    4bc7:	mov    rdx,r15
    4bca:	mov    rsi,r14
    4bcd:	mov    rdi,r12
    4bd0:	mov    r8,rbx
    4bd3:	call   4bd8 <botlish_fn_50+0x8c>
			4bd4: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4bd8:	test   rax,rax
    4bdb:	jne    4c06 <botlish_fn_50+0xba>
    4be1:	xor    rax,rax
    4be4:	mov    rbx,QWORD PTR [rsp+0x20]
    4be9:	mov    r12,QWORD PTR [rsp+0x28]
    4bee:	mov    r13,QWORD PTR [rsp+0x30]
    4bf3:	mov    r14,QWORD PTR [rsp+0x38]
    4bf8:	mov    r15,QWORD PTR [rsp+0x40]
    4bfd:	add    rsp,0x50
    4c01:	mov    rsp,rbp
    4c04:	pop    rbp
    4c05:	ret
    4c06:	mov    rbx,QWORD PTR [rsp+0x20]
    4c0b:	mov    r12,QWORD PTR [rsp+0x28]
    4c10:	mov    r13,QWORD PTR [rsp+0x30]
    4c15:	mov    r14,QWORD PTR [rsp+0x38]
    4c1a:	mov    r15,QWORD PTR [rsp+0x40]
    4c1f:	add    rsp,0x50
    4c23:	mov    rsp,rbp
    4c26:	pop    rbp
    4c27:	ret

0000000000004c28 <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4c28:	push   rbp
    4c29:	mov    rbp,rsp
    4c2c:	mov    rsi,QWORD PTR [rdx]
    4c2f:	mov    r9,QWORD PTR [rdx+0x8]
    4c33:	mov    rcx,QWORD PTR [rdx+0x10]
    4c37:	mov    r8,QWORD PTR [rdx+0x18]
    4c3b:	mov    rdx,r9
    4c3e:	call   4c43 <botlish_entry_50+0x1b>
			4c3f: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4c43:	mov    rsp,rbp
    4c46:	pop    rbp
    4c47:	ret

0000000000004c48 <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4c48:	push   rbp
    4c49:	mov    rbp,rsp
    4c4c:	sub    rsp,0x90
    4c53:	mov    QWORD PTR [rsp+0x60],rbx
    4c58:	mov    QWORD PTR [rsp+0x68],r12
    4c5d:	mov    QWORD PTR [rsp+0x70],r13
    4c62:	mov    QWORD PTR [rsp+0x78],r14
    4c67:	mov    QWORD PTR [rsp+0x80],r15
    4c6f:	mov    r13,r8
    4c72:	mov    QWORD PTR [rsp+0x38],rdi
    4c77:	mov    rdi,QWORD PTR [rbp+0x10]
    4c7b:	mov    r15,QWORD PTR [rbp+0x18]
    4c7f:	mov    QWORD PTR [rsp+0x28],0x0
    4c88:	mov    QWORD PTR [rsp+0x30],0x0
    4c91:	mov    QWORD PTR [rsp],rsi
    4c95:	mov    QWORD PTR [rsp+0x8],rcx
    4c9a:	mov    r14,rcx
    4c9d:	mov    QWORD PTR [rsp+0x10],r9
    4ca2:	mov    QWORD PTR [rsp+0x18],rdi
    4ca7:	mov    QWORD PTR [rsp+0x20],r15
    4cac:	sar    rdx,1
    4caf:	mov    r12,rdx
    4cb2:	mov    rbx,rsi
    4cb5:	mov    QWORD PTR [rsp+0x40],r9
    4cba:	mov    QWORD PTR [rsp+0x48],rdi
    4cbf:	mov    rsi,rbx
    4cc2:	mov    rdi,QWORD PTR [rsp+0x38]
    4cc7:	call   4ccc <botlish_fn_51+0x84>
			4cc8: R_X86_64_PLT32	rt_list_len-0x4
    4ccc:	sar    rax,1
    4ccf:	cmp    r12,rax
    4cd2:	jge    4dfd <botlish_fn_51+0x1b5>
    4cd8:	mov    rax,r13
    4cdb:	or     rax,0x1
    4cdf:	mov    QWORD PTR [rsp+0x28],rax
    4ce4:	mov    rcx,QWORD PTR [rbx+0x8]
    4ce8:	mov    rax,r12
    4ceb:	shl    rax,1
    4cee:	or     rax,0x1
    4cf2:	sar    rax,1
    4cf5:	cmp    rax,rcx
    4cf8:	jb     4d26 <botlish_fn_51+0xde>
    4cfe:	mov    rdx,r12
    4d01:	shl    rdx,1
    4d04:	or     rdx,0x1
    4d08:	mov    rsi,rbx
    4d0b:	mov    rdi,QWORD PTR [rsp+0x38]
    4d10:	call   4d15 <botlish_fn_51+0xcd>
			4d11: R_X86_64_PLT32	rt_list_get-0x4
    4d15:	test   rax,rax
    4d18:	je     4e1a <botlish_fn_51+0x1d2>
    4d1e:	mov    rcx,rax
    4d21:	jmp    4d2e <botlish_fn_51+0xe6>
    4d26:	mov    rcx,QWORD PTR [rbx+0x10]
    4d2a:	mov    rcx,QWORD PTR [rcx+rax*8]
    4d2e:	mov    QWORD PTR [rsp+0x30],rcx
    4d33:	mov    rdx,r13
    4d36:	or     rdx,0x1
    4d3a:	mov    rsi,r14
    4d3d:	mov    rdi,QWORD PTR [rsp+0x38]
    4d42:	mov    r8,r15
    4d45:	call   4d4a <botlish_fn_51+0x102>
			4d46: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4d4a:	test   rax,rax
    4d4d:	je     4e1a <botlish_fn_51+0x1d2>
    4d53:	mov    QWORD PTR [rsp+0x28],rax
    4d58:	mov    rcx,rax
    4d5b:	mov    rsi,QWORD PTR [rsp+0x40]
    4d60:	mov    rdx,QWORD PTR [rsp+0x48]
    4d65:	mov    rdi,QWORD PTR [rsp+0x38]
    4d6a:	call   4d6f <botlish_fn_51+0x127>
			4d6b: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4d6f:	test   rax,rax
    4d72:	je     4e1a <botlish_fn_51+0x1d2>
    4d78:	mov    QWORD PTR [rsp+0x10],rax
    4d7d:	mov    QWORD PTR [rsp+0x50],rax
    4d82:	mov    QWORD PTR [rsp+0x28],0x3
    4d8b:	mov    rsi,QWORD PTR [rsp+0x48]
    4d90:	test   rsi,0x1
    4d97:	je     4db6 <botlish_fn_51+0x16e>
    4d9d:	mov    rsi,QWORD PTR [rsp+0x48]
    4da2:	mov    rax,rsi
    4da5:	add    rax,0x2
    4da9:	seto   r10b
    4dad:	test   r10b,r10b
    4db0:	je     4dca <botlish_fn_51+0x182>
    4db6:	mov    edx,0x3
    4dbb:	mov    rsi,QWORD PTR [rsp+0x48]
    4dc0:	mov    rdi,QWORD PTR [rsp+0x38]
    4dc5:	call   4dca <botlish_fn_51+0x182>
			4dc6: R_X86_64_PLT32	rt_int_add-0x4
    4dca:	mov    QWORD PTR [rsp],rbx
    4dce:	mov    QWORD PTR [rsp+0x8],r14
    4dd3:	mov    rcx,QWORD PTR [rsp+0x50]
    4dd8:	mov    QWORD PTR [rsp+0x10],rcx
    4ddd:	mov    QWORD PTR [rsp+0x18],rax
    4de2:	mov    QWORD PTR [rsp+0x20],r15
    4de7:	add    r12,0x1
    4dee:	mov    QWORD PTR [rsp+0x40],rcx
    4df3:	mov    QWORD PTR [rsp+0x48],rax
    4df8:	jmp    4cbf <botlish_fn_51+0x77>
    4dfd:	mov    rdx,QWORD PTR [rsp+0x48]
    4e02:	mov    rsi,QWORD PTR [rsp+0x40]
    4e07:	mov    rdi,QWORD PTR [rsp+0x38]
    4e0c:	call   4e11 <botlish_fn_51+0x1c9>
			4e0d: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4e11:	test   rax,rax
    4e14:	jne    4e45 <botlish_fn_51+0x1fd>
    4e1a:	xor    rax,rax
    4e1d:	mov    rbx,QWORD PTR [rsp+0x60]
    4e22:	mov    r12,QWORD PTR [rsp+0x68]
    4e27:	mov    r13,QWORD PTR [rsp+0x70]
    4e2c:	mov    r14,QWORD PTR [rsp+0x78]
    4e31:	mov    r15,QWORD PTR [rsp+0x80]
    4e39:	add    rsp,0x90
    4e40:	mov    rsp,rbp
    4e43:	pop    rbp
    4e44:	ret
    4e45:	mov    rbx,QWORD PTR [rsp+0x60]
    4e4a:	mov    r12,QWORD PTR [rsp+0x68]
    4e4f:	mov    r13,QWORD PTR [rsp+0x70]
    4e54:	mov    r14,QWORD PTR [rsp+0x78]
    4e59:	mov    r15,QWORD PTR [rsp+0x80]
    4e61:	add    rsp,0x90
    4e68:	mov    rsp,rbp
    4e6b:	pop    rbp
    4e6c:	ret

0000000000004e6d <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4e6d:	push   rbp
    4e6e:	mov    rbp,rsp
    4e71:	sub    rsp,0x10
    4e75:	mov    rsi,QWORD PTR [rdx]
    4e78:	mov    r10,QWORD PTR [rdx+0x8]
    4e7c:	mov    rcx,QWORD PTR [rdx+0x10]
    4e80:	mov    r8,QWORD PTR [rdx+0x18]
    4e84:	mov    r9,QWORD PTR [rdx+0x20]
    4e88:	mov    r11,QWORD PTR [rdx+0x28]
    4e8c:	mov    rax,QWORD PTR [rdx+0x30]
    4e90:	mov    QWORD PTR [rsp],r11
    4e94:	mov    QWORD PTR [rsp+0x8],rax
    4e99:	mov    rdx,r10
    4e9c:	call   4ea1 <botlish_entry_51+0x34>
			4e9d: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4ea1:	add    rsp,0x10
    4ea5:	mov    rsp,rbp
    4ea8:	pop    rbp
    4ea9:	ret

0000000000004eaa <botlish_fn_52: csv_records_generic<str, bool>>:
    4eaa:	push   rbp
    4eab:	mov    rbp,rsp
    4eae:	sub    rsp,0x80
    4eb5:	mov    QWORD PTR [rsp+0x50],rbx
    4eba:	mov    QWORD PTR [rsp+0x58],r12
    4ebf:	mov    QWORD PTR [rsp+0x60],r13
    4ec4:	mov    QWORD PTR [rsp+0x68],r14
    4ec9:	mov    QWORD PTR [rsp+0x70],r15
    4ece:	mov    r12,rdi
    4ed1:	mov    QWORD PTR [rsp+0x20],0x0
    4eda:	mov    QWORD PTR [rsp+0x28],0x0
    4ee3:	mov    QWORD PTR [rsp+0x30],0x0
    4eec:	mov    QWORD PTR [rsp+0x38],0x0
    4ef5:	mov    QWORD PTR [rsp+0x40],0x0
    4efe:	mov    QWORD PTR [rsp+0x10],rsi
    4f03:	mov    QWORD PTR [rsp+0x18],rdx
    4f08:	mov    r13,rdx
    4f0b:	mov    rdi,r12
    4f0e:	call   4f13 <botlish_fn_52+0x69>
			4f0f: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4f13:	mov    rcx,rax
    4f16:	mov    r15,rax
    4f19:	test   rax,rcx
    4f1c:	je     5094 <botlish_fn_52+0x1ea>
    4f22:	mov    rax,r15
    4f25:	mov    QWORD PTR [rsp+0x10],rax
    4f2a:	mov    rsi,r15
    4f2d:	mov    rdi,r12
    4f30:	call   4f35 <botlish_fn_52+0x8b>
			4f31: R_X86_64_PLT32	rt_list_len-0x4
    4f35:	sar    rax,1
    4f38:	cmp    rax,0x1
    4f3c:	jle    507d <botlish_fn_52+0x1d3>
    4f42:	mov    rax,r15
    4f45:	mov    rax,QWORD PTR [rax+0x8]
    4f49:	test   rax,rax
    4f4c:	jne    4f73 <botlish_fn_52+0xc9>
    4f52:	mov    edx,0x1
    4f57:	mov    rsi,r15
    4f5a:	mov    rdi,r12
    4f5d:	call   4f62 <botlish_fn_52+0xb8>
			4f5e: R_X86_64_PLT32	rt_list_get-0x4
    4f62:	test   rax,rax
    4f65:	je     5094 <botlish_fn_52+0x1ea>
    4f6b:	mov    rbx,rax
    4f6e:	jmp    4f7a <botlish_fn_52+0xd0>
    4f73:	mov    rax,QWORD PTR [r15+0x10]
    4f77:	mov    rbx,QWORD PTR [rax]
    4f7a:	mov    QWORD PTR [rsp+0x20],rbx
    4f7f:	mov    rsi,rbx
    4f82:	mov    rdi,r12
    4f85:	call   4f8a <botlish_fn_52+0xe0>
			4f86: R_X86_64_PLT32	rt_list_len-0x4
    4f8a:	mov    r14,rax
    4f8d:	mov    QWORD PTR [rsp+0x48],rbx
    4f92:	mov    QWORD PTR [rsp+0x28],r14
    4f97:	mov    rax,QWORD PTR [r15+0x8]
    4f9b:	cmp    rax,0x1
    4f9f:	ja     4fc6 <botlish_fn_52+0x11c>
    4fa5:	mov    edx,0x3
    4faa:	mov    rsi,r15
    4fad:	mov    rdi,r12
    4fb0:	call   4fb5 <botlish_fn_52+0x10b>
			4fb1: R_X86_64_PLT32	rt_list_get-0x4
    4fb5:	test   rax,rax
    4fb8:	je     5094 <botlish_fn_52+0x1ea>
    4fbe:	mov    rcx,rax
    4fc1:	jmp    4fce <botlish_fn_52+0x124>
    4fc6:	mov    rax,QWORD PTR [r15+0x10]
    4fca:	mov    rcx,QWORD PTR [rax+0x8]
    4fce:	mov    QWORD PTR [rsp+0x30],rcx
    4fd3:	mov    rbx,r13
    4fd6:	mov    rdx,r14
    4fd9:	mov    rsi,QWORD PTR [rsp+0x48]
    4fde:	mov    rdi,r12
    4fe1:	mov    r8,rbx
    4fe4:	call   4fe9 <botlish_fn_52+0x13f>
			4fe5: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4fe9:	mov    r13,r14
    4fec:	test   rax,rax
    4fef:	je     5094 <botlish_fn_52+0x1ea>
    4ff5:	mov    QWORD PTR [rsp+0x30],rax
    4ffa:	mov    rsi,rax
    4ffd:	mov    QWORD PTR [rsp+0x38],0x5
    5006:	mov    rdi,r12
    5009:	call   500e <botlish_fn_52+0x164>
			500a: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    500e:	test   rax,rax
    5011:	je     5094 <botlish_fn_52+0x1ea>
    5017:	mov    QWORD PTR [rsp+0x30],rax
    501c:	mov    r9,rax
    501f:	mov    r10d,0x3
    5025:	mov    QWORD PTR [rsp+0x40],0x3
    502e:	mov    edx,0x5
    5033:	mov    QWORD PTR [rsp],r10
    5037:	mov    QWORD PTR [rsp+0x8],rbx
    503c:	mov    rcx,QWORD PTR [rsp+0x48]
    5041:	mov    rsi,r15
    5044:	mov    rdi,r12
    5047:	mov    r8,r13
    504a:	call   504f <botlish_fn_52+0x1a5>
			504b: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    504f:	test   rax,rax
    5052:	je     5094 <botlish_fn_52+0x1ea>
    5058:	mov    rbx,QWORD PTR [rsp+0x50]
    505d:	mov    r12,QWORD PTR [rsp+0x58]
    5062:	mov    r13,QWORD PTR [rsp+0x60]
    5067:	mov    r14,QWORD PTR [rsp+0x68]
    506c:	mov    r15,QWORD PTR [rsp+0x70]
    5071:	add    rsp,0x80
    5078:	mov    rsp,rbp
    507b:	pop    rbp
    507c:	ret
    507d:	xor    rdx,rdx
    5080:	mov    rdi,r12
    5083:	mov    rsi,rdx
    5086:	call   508b <botlish_fn_52+0x1e1>
			5087: R_X86_64_PLT32	rt_list_new-0x4
    508b:	test   rax,rax
    508e:	jne    50bc <botlish_fn_52+0x212>
    5094:	xor    rax,rax
    5097:	mov    rbx,QWORD PTR [rsp+0x50]
    509c:	mov    r12,QWORD PTR [rsp+0x58]
    50a1:	mov    r13,QWORD PTR [rsp+0x60]
    50a6:	mov    r14,QWORD PTR [rsp+0x68]
    50ab:	mov    r15,QWORD PTR [rsp+0x70]
    50b0:	add    rsp,0x80
    50b7:	mov    rsp,rbp
    50ba:	pop    rbp
    50bb:	ret
    50bc:	mov    rbx,QWORD PTR [rsp+0x50]
    50c1:	mov    r12,QWORD PTR [rsp+0x58]
    50c6:	mov    r13,QWORD PTR [rsp+0x60]
    50cb:	mov    r14,QWORD PTR [rsp+0x68]
    50d0:	mov    r15,QWORD PTR [rsp+0x70]
    50d5:	add    rsp,0x80
    50dc:	mov    rsp,rbp
    50df:	pop    rbp
    50e0:	ret

00000000000050e1 <botlish_entry_52: csv_records_generic<str, bool>>:
    50e1:	push   rbp
    50e2:	mov    rbp,rsp
    50e5:	mov    rsi,QWORD PTR [rdx]
    50e8:	mov    rdx,QWORD PTR [rdx+0x8]
    50ec:	call   50f1 <botlish_entry_52+0x10>
			50ed: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50f1:	mov    rsp,rbp
    50f4:	pop    rbp
    50f5:	ret

00000000000050f6 <botlish_fn_53: csv_records<str>>:
    50f6:	push   rbp
    50f7:	mov    rbp,rsp
    50fa:	sub    rsp,0x10
    50fe:	mov    QWORD PTR [rsp],rsi
    5102:	mov    edx,0x2
    5107:	mov    QWORD PTR [rsp+0x8],0x2
    5110:	call   5115 <botlish_fn_53+0x1f>
			5111: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5115:	test   rax,rax
    5118:	jne    512a <botlish_fn_53+0x34>
    511e:	xor    rax,rax
    5121:	add    rsp,0x10
    5125:	mov    rsp,rbp
    5128:	pop    rbp
    5129:	ret
    512a:	add    rsp,0x10
    512e:	mov    rsp,rbp
    5131:	pop    rbp
    5132:	ret

0000000000005133 <botlish_entry_53: csv_records<str>>:
    5133:	push   rbp
    5134:	mov    rbp,rsp
    5137:	mov    rsi,QWORD PTR [rdx]
    513a:	call   513f <botlish_entry_53+0xc>
			513b: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    513f:	mov    rsp,rbp
    5142:	pop    rbp
    5143:	ret

0000000000005144 <botlish_fn_54: csv_records_presized<str>>:
    5144:	push   rbp
    5145:	mov    rbp,rsp
    5148:	sub    rsp,0x10
    514c:	mov    QWORD PTR [rsp],rsi
    5150:	mov    edx,0x6
    5155:	mov    QWORD PTR [rsp+0x8],0x6
    515e:	call   5163 <botlish_fn_54+0x1f>
			515f: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5163:	test   rax,rax
    5166:	jne    5178 <botlish_fn_54+0x34>
    516c:	xor    rax,rax
    516f:	add    rsp,0x10
    5173:	mov    rsp,rbp
    5176:	pop    rbp
    5177:	ret
    5178:	add    rsp,0x10
    517c:	mov    rsp,rbp
    517f:	pop    rbp
    5180:	ret

0000000000005181 <botlish_entry_54: csv_records_presized<str>>:
    5181:	push   rbp
    5182:	mov    rbp,rsp
    5185:	mov    rsi,QWORD PTR [rdx]
    5188:	call   518d <botlish_entry_54+0xc>
			5189: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    518d:	mov    rsp,rbp
    5190:	pop    rbp
    5191:	ret
    5192:	add    BYTE PTR [rax],al
    5194:	add    BYTE PTR [rax],al
	...

0000000000005198 <botlish_fn_55: sample<generic>>:
    5198:	push   rbp
    5199:	mov    rbp,rsp
    519c:	sub    rsp,0xc0
    51a3:	mov    QWORD PTR [rsp+0x90],rbx
    51ab:	mov    QWORD PTR [rsp+0x98],r12
    51b3:	mov    QWORD PTR [rsp+0xa0],r13
    51bb:	mov    QWORD PTR [rsp+0xa8],r14
    51c3:	mov    QWORD PTR [rsp+0xb0],r15
    51cb:	mov    QWORD PTR [rsp+0x8],0x0
    51d4:	mov    QWORD PTR [rsp+0x10],0x0
    51dd:	mov    QWORD PTR [rsp+0x18],0x0
    51e6:	mov    QWORD PTR [rsp+0x20],0x0
    51ef:	mov    QWORD PTR [rsp+0x28],0x0
    51f8:	mov    QWORD PTR [rsp+0x30],0x0
    5201:	mov    QWORD PTR [rsp+0x38],0x0
    520a:	mov    rax,QWORD PTR [rdi+0x10]
    520e:	mov    r13,rdi
    5211:	mov    rsi,QWORD PTR [rax+0x50]
    5215:	mov    QWORD PTR [rsp],rsi
    5219:	call   521e <botlish_fn_55+0x86>
			521a: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    521e:	mov    rsi,rax
    5221:	mov    r12,rax
    5224:	test   rax,rsi
    5227:	je     55ac <botlish_fn_55+0x414>
    522d:	mov    rax,r12
    5230:	mov    QWORD PTR [rsp],rax
    5234:	mov    rdi,r13
    5237:	mov    rax,QWORD PTR [rdi+0x10]
    523b:	mov    rsi,QWORD PTR [rax+0x50]
    523f:	mov    QWORD PTR [rsp+0x8],rsi
    5244:	call   5249 <botlish_fn_55+0xb1>
			5245: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5249:	mov    rbx,rax
    524c:	test   rbx,rbx
    524f:	je     55ac <botlish_fn_55+0x414>
    5255:	mov    rax,r12
    5258:	mov    rax,QWORD PTR [rax+0x8]
    525c:	test   rax,rax
    525f:	jne    5286 <botlish_fn_55+0xee>
    5265:	mov    edx,0x1
    526a:	mov    rsi,r12
    526d:	mov    rdi,r13
    5270:	call   5275 <botlish_fn_55+0xdd>
			5271: R_X86_64_PLT32	rt_list_get-0x4
    5275:	test   rax,rax
    5278:	je     55ac <botlish_fn_55+0x414>
    527e:	mov    rsi,rax
    5281:	jmp    528e <botlish_fn_55+0xf6>
    5286:	mov    rax,QWORD PTR [r12+0x10]
    528b:	mov    rsi,QWORD PTR [rax]
    528e:	mov    QWORD PTR [rsp+0x8],rsi
    5293:	mov    r15,rsi
    5296:	mov    rax,QWORD PTR [r12+0x8]
    529b:	cmp    rax,0x1
    529f:	ja     52c6 <botlish_fn_55+0x12e>
    52a5:	mov    edx,0x3
    52aa:	mov    rsi,r12
    52ad:	mov    rdi,r13
    52b0:	call   52b5 <botlish_fn_55+0x11d>
			52b1: R_X86_64_PLT32	rt_list_get-0x4
    52b5:	test   rax,rax
    52b8:	je     55ac <botlish_fn_55+0x414>
    52be:	mov    rsi,rax
    52c1:	jmp    52cf <botlish_fn_55+0x137>
    52c6:	mov    rax,QWORD PTR [r12+0x10]
    52cb:	mov    rsi,QWORD PTR [rax+0x8]
    52cf:	mov    QWORD PTR [rsp+0x10],rsi
    52d4:	mov    r14,rsi
    52d7:	mov    rax,QWORD PTR [rbx+0x8]
    52db:	mov    rsi,rbx
    52de:	test   rax,rax
    52e1:	jne    5305 <botlish_fn_55+0x16d>
    52e7:	mov    edx,0x1
    52ec:	mov    rdi,r13
    52ef:	call   52f4 <botlish_fn_55+0x15c>
			52f0: R_X86_64_PLT32	rt_list_get-0x4
    52f4:	test   rax,rax
    52f7:	je     55ac <botlish_fn_55+0x414>
    52fd:	mov    rsi,rax
    5300:	jmp    530c <botlish_fn_55+0x174>
    5305:	mov    rax,QWORD PTR [rsi+0x10]
    5309:	mov    rsi,QWORD PTR [rax]
    530c:	mov    QWORD PTR [rsp+0x18],rsi
    5311:	mov    rdi,r13
    5314:	mov    QWORD PTR [rsp+0x78],rsi
    5319:	mov    rax,QWORD PTR [rdi+0x10]
    531d:	mov    rdx,QWORD PTR [rax+0x58]
    5321:	mov    QWORD PTR [rsp+0x20],rdx
    5326:	mov    rsi,r15
    5329:	call   532e <botlish_fn_55+0x196>
			532a: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    532e:	test   rax,rax
    5331:	je     55ac <botlish_fn_55+0x414>
    5337:	mov    QWORD PTR [rsp+0x20],rax
    533c:	mov    rbx,rax
    533f:	mov    rdi,r13
    5342:	mov    rax,QWORD PTR [rdi+0x10]
    5346:	mov    rdx,QWORD PTR [rax+0x58]
    534a:	mov    QWORD PTR [rsp+0x28],rdx
    534f:	mov    rsi,QWORD PTR [rsp+0x78]
    5354:	call   5359 <botlish_fn_55+0x1c1>
			5355: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5359:	test   rax,rax
    535c:	je     55ac <botlish_fn_55+0x414>
    5362:	mov    rcx,rbx
    5365:	mov    rdx,rcx
    5368:	and    rdx,rax
    536b:	test   rdx,0x1
    5372:	jne    5394 <botlish_fn_55+0x1fc>
    5378:	mov    rdx,rax
    537b:	mov    rsi,rbx
    537e:	mov    rdi,r13
    5381:	call   5386 <botlish_fn_55+0x1ee>
			5382: R_X86_64_PLT32	rt_value_eq-0x4
    5386:	test   rax,rax
    5389:	je     55ac <botlish_fn_55+0x414>
    538f:	jmp    53aa <botlish_fn_55+0x212>
    5394:	mov    rdx,rax
    5397:	mov    rsi,rbx
    539a:	mov    eax,0x2
    539f:	cmp    rsi,rdx
    53a2:	cmove  rax,QWORD PTR [rip+0x26e]        # 5618 <botlish_fn_55+0x480>
    53aa:	mov    ebx,0x6
    53af:	cmp    rax,0x6
    53b3:	je     53ce <botlish_fn_55+0x236>
    53b9:	mov    ebx,0x2
    53be:	mov    QWORD PTR [rsp],0x2
    53c6:	mov    rsi,r12
    53c9:	jmp    546d <botlish_fn_55+0x2d5>
    53ce:	mov    rsi,r15
    53d1:	mov    rdi,r13
    53d4:	call   53d9 <botlish_fn_55+0x241>
			53d5: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53d9:	test   rax,rax
    53dc:	mov    QWORD PTR [rsp+0x88],rax
    53e4:	je     55ac <botlish_fn_55+0x414>
    53ea:	mov    rsi,QWORD PTR [rsp+0x78]
    53ef:	mov    rdi,r13
    53f2:	call   53f7 <botlish_fn_55+0x25f>
			53f3: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53f7:	test   rax,rax
    53fa:	je     55ac <botlish_fn_55+0x414>
    5400:	mov    rcx,QWORD PTR [rsp+0x88]
    5408:	mov    rdx,rcx
    540b:	and    rdx,rax
    540e:	test   rdx,0x1
    5415:	jne    543c <botlish_fn_55+0x2a4>
    541b:	mov    rdx,rax
    541e:	mov    rsi,QWORD PTR [rsp+0x88]
    5426:	mov    rdi,r13
    5429:	call   542e <botlish_fn_55+0x296>
			542a: R_X86_64_PLT32	rt_value_eq-0x4
    542e:	test   rax,rax
    5431:	je     55ac <botlish_fn_55+0x414>
    5437:	jmp    5457 <botlish_fn_55+0x2bf>
    543c:	mov    rdx,rax
    543f:	mov    rsi,QWORD PTR [rsp+0x88]
    5447:	mov    eax,0x2
    544c:	cmp    rsi,rdx
    544f:	cmove  rax,QWORD PTR [rip+0x1c1]        # 5618 <botlish_fn_55+0x480>
    5457:	cmp    rax,0x6
    545b:	je     5466 <botlish_fn_55+0x2ce>
    5461:	mov    ebx,0x2
    5466:	mov    QWORD PTR [rsp],rbx
    546a:	mov    rsi,r12
    546d:	mov    rdi,r13
    5470:	call   5475 <botlish_fn_55+0x2dd>
			5471: R_X86_64_PLT32	rt_list_len-0x4
    5475:	mov    QWORD PTR [rsp+0x18],rax
    547a:	mov    rdi,r13
    547d:	mov    r12,rax
    5480:	mov    rax,QWORD PTR [rdi+0x10]
    5484:	mov    rdx,QWORD PTR [rax+0x58]
    5488:	mov    QWORD PTR [rsp+0x20],rdx
    548d:	mov    rsi,r15
    5490:	call   5495 <botlish_fn_55+0x2fd>
			5491: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5495:	test   rax,rax
    5498:	je     55ac <botlish_fn_55+0x414>
    549e:	mov    QWORD PTR [rsp+0x20],rax
    54a3:	mov    rdi,r13
    54a6:	mov    QWORD PTR [rsp+0x88],rax
    54ae:	mov    rax,QWORD PTR [rdi+0x10]
    54b2:	mov    rdx,QWORD PTR [rax+0x60]
    54b6:	mov    QWORD PTR [rsp+0x28],rdx
    54bb:	mov    rsi,r15
    54be:	call   54c3 <botlish_fn_55+0x32b>
			54bf: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54c3:	test   rax,rax
    54c6:	je     55ac <botlish_fn_55+0x414>
    54cc:	mov    QWORD PTR [rsp+0x28],rax
    54d1:	mov    rdi,r13
    54d4:	mov    QWORD PTR [rsp+0x80],rax
    54dc:	mov    rax,QWORD PTR [rdi+0x10]
    54e0:	mov    rdx,QWORD PTR [rax+0x68]
    54e4:	mov    QWORD PTR [rsp+0x30],rdx
    54e9:	mov    rsi,r15
    54ec:	call   54f1 <botlish_fn_55+0x359>
			54ed: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54f1:	test   rax,rax
    54f4:	je     55ac <botlish_fn_55+0x414>
    54fa:	mov    QWORD PTR [rsp+0x8],rax
    54ff:	mov    rdi,r13
    5502:	mov    r15,rax
    5505:	mov    rax,QWORD PTR [rdi+0x10]
    5509:	mov    rdx,QWORD PTR [rax+0x58]
    550d:	mov    QWORD PTR [rsp+0x30],rdx
    5512:	mov    rsi,r14
    5515:	call   551a <botlish_fn_55+0x382>
			5516: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    551a:	test   rax,rax
    551d:	je     55ac <botlish_fn_55+0x414>
    5523:	mov    QWORD PTR [rsp+0x30],rax
    5528:	mov    rdi,r13
    552b:	mov    QWORD PTR [rsp+0x78],rax
    5530:	mov    rax,QWORD PTR [rdi+0x10]
    5534:	mov    rdx,QWORD PTR [rax+0x68]
    5538:	mov    QWORD PTR [rsp+0x38],rdx
    553d:	mov    rsi,r14
    5540:	call   5545 <botlish_fn_55+0x3ad>
			5541: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5545:	test   rax,rax
    5548:	je     55ac <botlish_fn_55+0x414>
    554e:	mov    QWORD PTR [rsp+0x10],rax
    5553:	lea    rdx,[rsp+0x40]
    5558:	mov    r9,r12
    555b:	mov    QWORD PTR [rsp+0x40],r9
    5560:	mov    rcx,QWORD PTR [rsp+0x88]
    5568:	mov    QWORD PTR [rsp+0x48],rcx
    556d:	mov    rcx,QWORD PTR [rsp+0x80]
    5575:	mov    QWORD PTR [rsp+0x50],rcx
    557a:	mov    rcx,r15
    557d:	mov    QWORD PTR [rsp+0x58],rcx
    5582:	mov    rcx,QWORD PTR [rsp+0x78]
    5587:	mov    QWORD PTR [rsp+0x60],rcx
    558c:	mov    QWORD PTR [rsp+0x68],rax
    5591:	mov    QWORD PTR [rsp+0x70],rbx
    5596:	mov    esi,0x7
    559b:	mov    rdi,r13
    559e:	call   55a3 <botlish_fn_55+0x40b>
			559f: R_X86_64_PLT32	rt_list_new-0x4
    55a3:	test   rax,rax
    55a6:	jne    55e3 <botlish_fn_55+0x44b>
    55ac:	xor    rax,rax
    55af:	mov    rbx,QWORD PTR [rsp+0x90]
    55b7:	mov    r12,QWORD PTR [rsp+0x98]
    55bf:	mov    r13,QWORD PTR [rsp+0xa0]
    55c7:	mov    r14,QWORD PTR [rsp+0xa8]
    55cf:	mov    r15,QWORD PTR [rsp+0xb0]
    55d7:	add    rsp,0xc0
    55de:	mov    rsp,rbp
    55e1:	pop    rbp
    55e2:	ret
    55e3:	mov    rbx,QWORD PTR [rsp+0x90]
    55eb:	mov    r12,QWORD PTR [rsp+0x98]
    55f3:	mov    r13,QWORD PTR [rsp+0xa0]
    55fb:	mov    r14,QWORD PTR [rsp+0xa8]
    5603:	mov    r15,QWORD PTR [rsp+0xb0]
    560b:	add    rsp,0xc0
    5612:	mov    rsp,rbp
    5615:	pop    rbp
    5616:	ret
    5617:	add    BYTE PTR [rsi],al
    5619:	add    BYTE PTR [rax],al
    561b:	add    BYTE PTR [rax],al
    561d:	add    BYTE PTR [rax],al
	...

0000000000005620 <botlish_entry_55: sample<generic>>:
    5620:	push   rbp
    5621:	mov    rbp,rsp
    5624:	call   5629 <botlish_entry_55+0x9>
			5625: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample<generic>
    5629:	mov    rsp,rbp
    562c:	pop    rbp
    562d:	ret

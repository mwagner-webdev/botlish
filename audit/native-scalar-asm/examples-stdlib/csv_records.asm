; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23234  (per function: 45 461 461 461 81 81 81 357 412 412 412 278 278 278 81 365 430 585 1063 352 783 215 488 325 388 524 70 493 114 61 61 61 61 61 168 179 245 804 1248 429 380 439 977 766 817 665 1168 836 107 427 259 629 634 78 78 1222)
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

00000000000014ab <botlish_fn_18: scan_quoted<str, int, str>>:
    14ab:	push   rbp
    14ac:	mov    rbp,rsp
    14af:	sub    rsp,0xd0
    14b6:	mov    QWORD PTR [rsp+0xa0],rbx
    14be:	mov    QWORD PTR [rsp+0xa8],r12
    14c6:	mov    QWORD PTR [rsp+0xb0],r13
    14ce:	mov    QWORD PTR [rsp+0xb8],r14
    14d6:	mov    QWORD PTR [rsp+0xc0],r15
    14de:	mov    r15,rdi
    14e1:	mov    QWORD PTR [rsp+0x18],0x0
    14ea:	mov    QWORD PTR [rsp+0x20],0x0
    14f3:	mov    QWORD PTR [rsp],rsi
    14f7:	mov    QWORD PTR [rsp+0x8],rdx
    14fc:	mov    QWORD PTR [rsp+0x10],rcx
    1501:	mov    r13,rcx
    1504:	lea    r14,[rsp+0x68]
    1509:	lea    rbx,[rsp+0x28]
    150e:	mov    r12,rsi
    1511:	mov    QWORD PTR [rsp+0x88],rdx
    1519:	mov    rdx,QWORD PTR [rsp+0x88]
    1521:	mov    rsi,r12
    1524:	mov    rdi,r15
    1527:	call   152c <botlish_fn_18+0x81>
			1528: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    152c:	test   rax,rax
    152f:	je     1833 <botlish_fn_18+0x388>
    1535:	mov    QWORD PTR [rsp+0x18],rax
    153a:	mov    rdi,r15
    153d:	mov    QWORD PTR [rsp+0x90],rax
    1545:	mov    rsi,QWORD PTR [rdi+0x10]
    1549:	mov    rsi,QWORD PTR [rsi+0x20]
    154d:	mov    edx,0x1
    1552:	mov    ecx,0x3
    1557:	mov    r8,QWORD PTR [rsp+0x90]
    155f:	call   1564 <botlish_fn_18+0xb9>
			1560: R_X86_64_PLT32	rt_str_region_eq-0x4
    1564:	cmp    rax,0x6
    1568:	je     1628 <botlish_fn_18+0x17d>
    156e:	mov    QWORD PTR [rsp+0x20],0x3
    1577:	mov    rsi,QWORD PTR [rsp+0x88]
    157f:	test   rsi,0x1
    1586:	je     15a8 <botlish_fn_18+0xfd>
    158c:	mov    r9,rsi
    158f:	add    r9,0x2
    1593:	seto   r11b
    1597:	test   r11b,r11b
    159a:	jne    15a8 <botlish_fn_18+0xfd>
    15a0:	mov    rsi,r9
    15a3:	jmp    15b8 <botlish_fn_18+0x10d>
    15a8:	mov    edx,0x3
    15ad:	mov    rdi,r15
    15b0:	call   15b5 <botlish_fn_18+0x10a>
			15b1: R_X86_64_PLT32	rt_int_add-0x4
    15b5:	mov    rsi,rax
    15b8:	mov    QWORD PTR [rsp+0x8],rsi
    15bd:	mov    QWORD PTR [rsp+0x88],rsi
    15c5:	mov    QWORD PTR [rsp+0x68],0x0
    15ce:	mov    QWORD PTR [rsp+0x70],r13
    15d3:	mov    QWORD PTR [rsp+0x78],0x0
    15dc:	mov    rax,QWORD PTR [rsp+0x90]
    15e4:	mov    QWORD PTR [rsp+0x80],rax
    15ec:	mov    esi,0x2
    15f1:	mov    edx,0x4
    15f6:	mov    rcx,r14
    15f9:	mov    rdi,r15
    15fc:	call   1601 <botlish_fn_18+0x156>
			15fd: R_X86_64_PLT32	rt_construct-0x4
    1601:	test   rax,rax
    1604:	je     1833 <botlish_fn_18+0x388>
    160a:	mov    QWORD PTR [rsp],r12
    160e:	mov    rsi,QWORD PTR [rsp+0x88]
    1616:	mov    QWORD PTR [rsp+0x8],rsi
    161b:	mov    QWORD PTR [rsp+0x10],rax
    1620:	mov    r13,rax
    1623:	jmp    1519 <botlish_fn_18+0x6e>
    1628:	mov    QWORD PTR [rsp+0x18],0x3
    1631:	mov    rsi,QWORD PTR [rsp+0x88]
    1639:	test   rsi,0x1
    1640:	je     1660 <botlish_fn_18+0x1b5>
    1646:	mov    rsi,QWORD PTR [rsp+0x88]
    164e:	mov    rdx,rsi
    1651:	add    rdx,0x2
    1655:	seto   al
    1658:	test   al,al
    165a:	je     1678 <botlish_fn_18+0x1cd>
    1660:	mov    edx,0x3
    1665:	mov    rsi,QWORD PTR [rsp+0x88]
    166d:	mov    rdi,r15
    1670:	call   1675 <botlish_fn_18+0x1ca>
			1671: R_X86_64_PLT32	rt_int_add-0x4
    1675:	mov    rdx,rax
    1678:	mov    QWORD PTR [rsp+0x18],rdx
    167d:	mov    rcx,rbx
    1680:	mov    rsi,r12
    1683:	mov    rdi,r15
    1686:	call   168b <botlish_fn_18+0x1e0>
			1687: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    168b:	test   rax,rax
    168e:	mov    rsi,rax
    1691:	je     1833 <botlish_fn_18+0x388>
    1697:	mov    rdx,QWORD PTR [rsp+0x28]
    169c:	mov    rcx,QWORD PTR [rsp+0x30]
    16a1:	mov    rdi,r15
    16a4:	mov    rax,QWORD PTR [rdi+0x10]
    16a8:	mov    r8,QWORD PTR [rax+0x20]
    16ac:	call   16b1 <botlish_fn_18+0x206>
			16ad: R_X86_64_PLT32	rt_str_region_eq-0x4
    16b1:	cmp    rax,0x6
    16b5:	je     177d <botlish_fn_18+0x2d2>
    16bb:	xor    rsi,rsi
    16be:	lea    rcx,[rsp+0x58]
    16c3:	mov    QWORD PTR [rsp+0x58],0x0
    16cc:	mov    QWORD PTR [rsp+0x60],r13
    16d1:	mov    edx,0x2
    16d6:	mov    rdi,r15
    16d9:	call   16de <botlish_fn_18+0x233>
			16da: R_X86_64_PLT32	rt_construct-0x4
    16de:	test   rax,rax
    16e1:	je     1833 <botlish_fn_18+0x388>
    16e7:	mov    QWORD PTR [rsp],rax
    16eb:	mov    rbx,rax
    16ee:	mov    QWORD PTR [rsp+0x10],0x3
    16f7:	mov    rsi,QWORD PTR [rsp+0x88]
    16ff:	test   rsi,0x1
    1706:	je     172e <botlish_fn_18+0x283>
    170c:	mov    rsi,QWORD PTR [rsp+0x88]
    1714:	mov    rdx,rsi
    1717:	add    rdx,0x2
    171b:	seto   al
    171e:	test   al,al
    1720:	jne    172e <botlish_fn_18+0x283>
    1726:	mov    rax,rbx
    1729:	jmp    1749 <botlish_fn_18+0x29e>
    172e:	mov    edx,0x3
    1733:	mov    rsi,QWORD PTR [rsp+0x88]
    173b:	mov    rdi,r15
    173e:	call   1743 <botlish_fn_18+0x298>
			173f: R_X86_64_PLT32	rt_int_add-0x4
    1743:	mov    rdx,rax
    1746:	mov    rax,rbx
    1749:	mov    rbx,QWORD PTR [rsp+0xa0]
    1751:	mov    r12,QWORD PTR [rsp+0xa8]
    1759:	mov    r13,QWORD PTR [rsp+0xb0]
    1761:	mov    r14,QWORD PTR [rsp+0xb8]
    1769:	mov    r15,QWORD PTR [rsp+0xc0]
    1771:	add    rsp,0xd0
    1778:	mov    rsp,rbp
    177b:	pop    rbp
    177c:	ret
    177d:	mov    QWORD PTR [rsp+0x18],0x5
    1786:	mov    rsi,QWORD PTR [rsp+0x88]
    178e:	test   rsi,0x1
    1795:	je     17c5 <botlish_fn_18+0x31a>
    179b:	mov    rsi,QWORD PTR [rsp+0x88]
    17a3:	mov    rax,rsi
    17a6:	add    rax,0x4
    17aa:	seto   cl
    17ad:	test   cl,cl
    17af:	jne    17c5 <botlish_fn_18+0x31a>
    17b5:	mov    rsi,rax
    17b8:	mov    QWORD PTR [rsp+0x88],rax
    17c0:	jmp    17e5 <botlish_fn_18+0x33a>
    17c5:	mov    edx,0x5
    17ca:	mov    rsi,QWORD PTR [rsp+0x88]
    17d2:	mov    rdi,r15
    17d5:	call   17da <botlish_fn_18+0x32f>
			17d6: R_X86_64_PLT32	rt_int_add-0x4
    17da:	mov    rsi,rax
    17dd:	mov    QWORD PTR [rsp+0x88],rax
    17e5:	mov    QWORD PTR [rsp+0x8],rsi
    17ea:	mov    rdi,r15
    17ed:	mov    rsi,QWORD PTR [rdi+0x10]
    17f1:	mov    rsi,QWORD PTR [rsi+0x20]
    17f5:	mov    QWORD PTR [rsp+0x18],rsi
    17fa:	lea    rcx,[rsp+0x38]
    17ff:	mov    QWORD PTR [rsp+0x38],0x0
    1808:	mov    QWORD PTR [rsp+0x40],r13
    180d:	mov    QWORD PTR [rsp+0x48],0x0
    1816:	mov    QWORD PTR [rsp+0x50],rsi
    181b:	mov    esi,0x2
    1820:	mov    edx,0x4
    1825:	call   182a <botlish_fn_18+0x37f>
			1826: R_X86_64_PLT32	rt_construct-0x4
    182a:	test   rax,rax
    182d:	jne    186d <botlish_fn_18+0x3c2>
    1833:	xor    rdx,rdx
    1836:	mov    rax,rdx
    1839:	mov    rbx,QWORD PTR [rsp+0xa0]
    1841:	mov    r12,QWORD PTR [rsp+0xa8]
    1849:	mov    r13,QWORD PTR [rsp+0xb0]
    1851:	mov    r14,QWORD PTR [rsp+0xb8]
    1859:	mov    r15,QWORD PTR [rsp+0xc0]
    1861:	add    rsp,0xd0
    1868:	mov    rsp,rbp
    186b:	pop    rbp
    186c:	ret
    186d:	mov    QWORD PTR [rsp],r12
    1871:	mov    rsi,QWORD PTR [rsp+0x88]
    1879:	mov    QWORD PTR [rsp+0x8],rsi
    187e:	mov    QWORD PTR [rsp+0x10],rax
    1883:	mov    r13,rax
    1886:	jmp    1519 <botlish_fn_18+0x6e>

000000000000188b <botlish_entry_18: scan_quoted<str, int, str>>:
    188b:	push   rbp
    188c:	mov    rbp,rsp
    188f:	ud2

0000000000001891 <botlish_fn_19: scan_field<str, int>>:
    1891:	push   rbp
    1892:	mov    rbp,rsp
    1895:	sub    rsp,0x50
    1899:	mov    QWORD PTR [rsp+0x30],rbx
    189e:	mov    QWORD PTR [rsp+0x38],r12
    18a3:	mov    QWORD PTR [rsp+0x40],r13
    18a8:	mov    r12,rdi
    18ab:	mov    r13,rdx
    18ae:	mov    QWORD PTR [rsp+0x10],0x0
    18b7:	mov    QWORD PTR [rsp],rsi
    18bb:	mov    rbx,rsi
    18be:	mov    QWORD PTR [rsp+0x8],rdx
    18c3:	lea    rcx,[rsp+0x18]
    18c8:	mov    rdx,r13
    18cb:	mov    rsi,rbx
    18ce:	mov    rdi,r12
    18d1:	call   18d6 <botlish_fn_19+0x45>
			18d2: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    18d6:	test   rax,rax
    18d9:	mov    rsi,rax
    18dc:	je     19a7 <botlish_fn_19+0x116>
    18e2:	mov    rdx,QWORD PTR [rsp+0x18]
    18e7:	mov    rcx,QWORD PTR [rsp+0x20]
    18ec:	mov    rdi,r12
    18ef:	mov    rax,QWORD PTR [rdi+0x10]
    18f3:	mov    r8,QWORD PTR [rax+0x20]
    18f7:	call   18fc <botlish_fn_19+0x6b>
			18f8: R_X86_64_PLT32	rt_str_region_eq-0x4
    18fc:	cmp    rax,0x6
    1900:	je     1938 <botlish_fn_19+0xa7>
    1906:	mov    rcx,r13
    1909:	mov    rsi,rbx
    190c:	mov    rdi,r12
    190f:	mov    rdx,rcx
    1912:	call   1917 <botlish_fn_19+0x86>
			1913: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    1917:	test   rax,rax
    191a:	je     19a7 <botlish_fn_19+0x116>
    1920:	mov    rbx,QWORD PTR [rsp+0x30]
    1925:	mov    r12,QWORD PTR [rsp+0x38]
    192a:	mov    r13,QWORD PTR [rsp+0x40]
    192f:	add    rsp,0x50
    1933:	mov    rsp,rbp
    1936:	pop    rbp
    1937:	ret
    1938:	mov    rcx,r13
    193b:	mov    QWORD PTR [rsp+0x10],0x3
    1944:	test   rcx,0x1
    194b:	jne    1959 <botlish_fn_19+0xc8>
    1951:	mov    r13,rcx
    1954:	jmp    196e <botlish_fn_19+0xdd>
    1959:	mov    rdx,rcx
    195c:	add    rdx,0x2
    1960:	mov    r13,rcx
    1963:	seto   al
    1966:	test   al,al
    1968:	je     1981 <botlish_fn_19+0xf0>
    196e:	mov    edx,0x3
    1973:	mov    rsi,r13
    1976:	mov    rdi,r12
    1979:	call   197e <botlish_fn_19+0xed>
			197a: R_X86_64_PLT32	rt_int_add-0x4
    197e:	mov    rdx,rax
    1981:	mov    QWORD PTR [rsp+0x8],rdx
    1986:	mov    rdi,r12
    1989:	mov    rax,QWORD PTR [rdi+0x10]
    198d:	mov    rcx,QWORD PTR [rax+0x8]
    1991:	mov    QWORD PTR [rsp+0x10],rcx
    1996:	mov    rsi,rbx
    1999:	call   199e <botlish_fn_19+0x10d>
			199a: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    199e:	test   rax,rax
    19a1:	jne    19c5 <botlish_fn_19+0x134>
    19a7:	xor    rdx,rdx
    19aa:	mov    rax,rdx
    19ad:	mov    rbx,QWORD PTR [rsp+0x30]
    19b2:	mov    r12,QWORD PTR [rsp+0x38]
    19b7:	mov    r13,QWORD PTR [rsp+0x40]
    19bc:	add    rsp,0x50
    19c0:	mov    rsp,rbp
    19c3:	pop    rbp
    19c4:	ret
    19c5:	mov    rbx,QWORD PTR [rsp+0x30]
    19ca:	mov    r12,QWORD PTR [rsp+0x38]
    19cf:	mov    r13,QWORD PTR [rsp+0x40]
    19d4:	add    rsp,0x50
    19d8:	mov    rsp,rbp
    19db:	pop    rbp
    19dc:	ret

00000000000019dd <botlish_entry_19: scan_field<str, int>>:
    19dd:	push   rbp
    19de:	mov    rbp,rsp
    19e1:	ud2

00000000000019e3 <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    19e3:	push   rbp
    19e4:	mov    rbp,rsp
    19e7:	sub    rsp,0x90
    19ee:	mov    QWORD PTR [rsp+0x60],rbx
    19f3:	mov    QWORD PTR [rsp+0x68],r12
    19f8:	mov    QWORD PTR [rsp+0x70],r13
    19fd:	mov    QWORD PTR [rsp+0x78],r14
    1a02:	mov    QWORD PTR [rsp+0x80],r15
    1a0a:	mov    r15,rdi
    1a0d:	mov    QWORD PTR [rsp+0x20],0x0
    1a16:	mov    QWORD PTR [rsp],rsi
    1a1a:	mov    QWORD PTR [rsp+0x8],rdx
    1a1f:	mov    QWORD PTR [rsp+0x10],rcx
    1a24:	mov    QWORD PTR [rsp+0x18],r8
    1a29:	lea    r12,[rsp+0x28]
    1a2e:	mov    rbx,rsi
    1a31:	mov    QWORD PTR [rsp+0x38],rdx
    1a36:	mov    QWORD PTR [rsp+0x40],rcx
    1a3b:	mov    QWORD PTR [rsp+0x48],r8
    1a40:	mov    rcx,r12
    1a43:	mov    rdx,QWORD PTR [rsp+0x38]
    1a48:	mov    rsi,rbx
    1a4b:	mov    rdi,r15
    1a4e:	call   1a53 <botlish_fn_20+0x70>
			1a4f: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1a53:	test   rax,rax
    1a56:	mov    QWORD PTR [rsp+0x50],rax
    1a5b:	je     1c1f <botlish_fn_20+0x23c>
    1a61:	mov    r14,QWORD PTR [rsp+0x28]
    1a66:	mov    r13,QWORD PTR [rsp+0x30]
    1a6b:	mov    rdi,r15
    1a6e:	mov    rcx,QWORD PTR [rdi+0x10]
    1a72:	mov    r8,QWORD PTR [rcx+0x10]
    1a76:	mov    rcx,r13
    1a79:	mov    rdx,r14
    1a7c:	mov    rsi,QWORD PTR [rsp+0x50]
    1a81:	call   1a86 <botlish_fn_20+0xa3>
			1a82: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a86:	cmp    rax,0x6
    1a8a:	je     1b98 <botlish_fn_20+0x1b5>
    1a90:	mov    rdi,r15
    1a93:	mov    rax,QWORD PTR [rdi+0x10]
    1a97:	mov    r8,QWORD PTR [rax+0x18]
    1a9b:	mov    rcx,r13
    1a9e:	mov    rdx,r14
    1aa1:	mov    rsi,QWORD PTR [rsp+0x50]
    1aa6:	call   1aab <botlish_fn_20+0xc8>
			1aa7: R_X86_64_PLT32	rt_str_region_eq-0x4
    1aab:	cmp    rax,0x6
    1aaf:	je     1afd <botlish_fn_20+0x11a>
    1ab5:	mov    rdx,QWORD PTR [rsp+0x48]
    1aba:	mov    rsi,QWORD PTR [rsp+0x40]
    1abf:	mov    rdi,r15
    1ac2:	call   1ac7 <botlish_fn_20+0xe4>
			1ac3: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1ac7:	test   rax,rax
    1aca:	je     1c1f <botlish_fn_20+0x23c>
    1ad0:	mov    rdx,QWORD PTR [rsp+0x38]
    1ad5:	mov    rbx,QWORD PTR [rsp+0x60]
    1ada:	mov    r12,QWORD PTR [rsp+0x68]
    1adf:	mov    r13,QWORD PTR [rsp+0x70]
    1ae4:	mov    r14,QWORD PTR [rsp+0x78]
    1ae9:	mov    r15,QWORD PTR [rsp+0x80]
    1af1:	add    rsp,0x90
    1af8:	mov    rsp,rbp
    1afb:	pop    rbp
    1afc:	ret
    1afd:	mov    rdx,QWORD PTR [rsp+0x48]
    1b02:	mov    rsi,QWORD PTR [rsp+0x40]
    1b07:	mov    rdi,r15
    1b0a:	call   1b0f <botlish_fn_20+0x12c>
			1b0b: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b0f:	test   rax,rax
    1b12:	je     1c1f <botlish_fn_20+0x23c>
    1b18:	mov    QWORD PTR [rsp],rax
    1b1c:	mov    rbx,rax
    1b1f:	mov    QWORD PTR [rsp+0x10],0x3
    1b28:	mov    rdx,QWORD PTR [rsp+0x38]
    1b2d:	test   rdx,0x1
    1b34:	je     1b58 <botlish_fn_20+0x175>
    1b3a:	mov    rdx,QWORD PTR [rsp+0x38]
    1b3f:	add    rdx,0x2
    1b43:	seto   sil
    1b47:	test   sil,sil
    1b4a:	jne    1b58 <botlish_fn_20+0x175>
    1b50:	mov    rax,rbx
    1b53:	jmp    1b70 <botlish_fn_20+0x18d>
    1b58:	mov    edx,0x3
    1b5d:	mov    rsi,QWORD PTR [rsp+0x38]
    1b62:	mov    rdi,r15
    1b65:	call   1b6a <botlish_fn_20+0x187>
			1b66: R_X86_64_PLT32	rt_int_add-0x4
    1b6a:	mov    rdx,rax
    1b6d:	mov    rax,rbx
    1b70:	mov    rbx,QWORD PTR [rsp+0x60]
    1b75:	mov    r12,QWORD PTR [rsp+0x68]
    1b7a:	mov    r13,QWORD PTR [rsp+0x70]
    1b7f:	mov    r14,QWORD PTR [rsp+0x78]
    1b84:	mov    r15,QWORD PTR [rsp+0x80]
    1b8c:	add    rsp,0x90
    1b93:	mov    rsp,rbp
    1b96:	pop    rbp
    1b97:	ret
    1b98:	mov    rsi,QWORD PTR [rsp+0x38]
    1b9d:	mov    edx,0x3
    1ba2:	mov    r13,rdx
    1ba5:	mov    QWORD PTR [rsp+0x20],0x3
    1bae:	test   rsi,0x1
    1bb5:	je     1bcd <botlish_fn_20+0x1ea>
    1bbb:	mov    rdx,rsi
    1bbe:	add    rdx,0x2
    1bc2:	seto   al
    1bc5:	test   al,al
    1bc7:	je     1bdb <botlish_fn_20+0x1f8>
    1bcd:	mov    rdx,r13
    1bd0:	mov    rdi,r15
    1bd3:	call   1bd8 <botlish_fn_20+0x1f5>
			1bd4: R_X86_64_PLT32	rt_int_add-0x4
    1bd8:	mov    rdx,rax
    1bdb:	mov    QWORD PTR [rsp+0x8],rdx
    1be0:	mov    rsi,rbx
    1be3:	mov    rdi,r15
    1be6:	call   1beb <botlish_fn_20+0x208>
			1be7: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1beb:	test   rax,rax
    1bee:	je     1c1f <botlish_fn_20+0x23c>
    1bf4:	mov    QWORD PTR [rsp+0x8],rax
    1bf9:	mov    rcx,rax
    1bfc:	mov    QWORD PTR [rsp+0x20],rdx
    1c01:	mov    rsi,QWORD PTR [rsp+0x40]
    1c06:	mov    r14,rdx
    1c09:	mov    rdx,QWORD PTR [rsp+0x48]
    1c0e:	mov    rdi,r15
    1c11:	call   1c16 <botlish_fn_20+0x233>
			1c12: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1c16:	test   rax,rax
    1c19:	jne    1c4d <botlish_fn_20+0x26a>
    1c1f:	xor    rdx,rdx
    1c22:	mov    rax,rdx
    1c25:	mov    rbx,QWORD PTR [rsp+0x60]
    1c2a:	mov    r12,QWORD PTR [rsp+0x68]
    1c2f:	mov    r13,QWORD PTR [rsp+0x70]
    1c34:	mov    r14,QWORD PTR [rsp+0x78]
    1c39:	mov    r15,QWORD PTR [rsp+0x80]
    1c41:	add    rsp,0x90
    1c48:	mov    rsp,rbp
    1c4b:	pop    rbp
    1c4c:	ret
    1c4d:	mov    QWORD PTR [rsp+0x8],rax
    1c52:	mov    QWORD PTR [rsp+0x38],rax
    1c57:	mov    QWORD PTR [rsp+0x10],0x3
    1c60:	mov    rdx,QWORD PTR [rsp+0x48]
    1c65:	test   rdx,0x1
    1c6c:	jne    1c7f <botlish_fn_20+0x29c>
    1c72:	mov    rdx,r13
    1c75:	mov    rsi,QWORD PTR [rsp+0x48]
    1c7a:	jmp    1c9e <botlish_fn_20+0x2bb>
    1c7f:	mov    rdx,QWORD PTR [rsp+0x48]
    1c84:	mov    rax,rdx
    1c87:	add    rax,0x2
    1c8b:	seto   cl
    1c8e:	test   cl,cl
    1c90:	je     1ca6 <botlish_fn_20+0x2c3>
    1c96:	mov    rdx,r13
    1c99:	mov    rsi,QWORD PTR [rsp+0x48]
    1c9e:	mov    rdi,r15
    1ca1:	call   1ca6 <botlish_fn_20+0x2c3>
			1ca2: R_X86_64_PLT32	rt_int_add-0x4
    1ca6:	mov    QWORD PTR [rsp],rbx
    1caa:	mov    rdx,r14
    1cad:	mov    QWORD PTR [rsp+0x8],rdx
    1cb2:	mov    rcx,QWORD PTR [rsp+0x38]
    1cb7:	mov    QWORD PTR [rsp+0x10],rcx
    1cbc:	mov    QWORD PTR [rsp+0x18],rax
    1cc1:	mov    QWORD PTR [rsp+0x38],rdx
    1cc6:	mov    QWORD PTR [rsp+0x40],rcx
    1ccb:	mov    QWORD PTR [rsp+0x48],rax
    1cd0:	jmp    1a40 <botlish_fn_20+0x5d>

0000000000001cd5 <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1cd5:	push   rbp
    1cd6:	mov    rbp,rsp
    1cd9:	ud2

0000000000001cdb <botlish_fn_21: scan_record<str, int>>:
    1cdb:	push   rbp
    1cdc:	mov    rbp,rsp
    1cdf:	sub    rsp,0x40
    1ce3:	mov    QWORD PTR [rsp+0x20],rbx
    1ce8:	mov    QWORD PTR [rsp+0x28],r12
    1ced:	mov    QWORD PTR [rsp+0x30],r14
    1cf2:	mov    r14,rdi
    1cf5:	mov    QWORD PTR [rsp+0x10],0x0
    1cfe:	mov    QWORD PTR [rsp+0x18],0x0
    1d07:	mov    QWORD PTR [rsp],rsi
    1d0b:	mov    r12,rsi
    1d0e:	mov    QWORD PTR [rsp+0x8],rdx
    1d13:	mov    rsi,r12
    1d16:	mov    rdi,r14
    1d19:	call   1d1e <botlish_fn_21+0x43>
			1d1a: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1d1e:	test   rax,rax
    1d21:	je     1d76 <botlish_fn_21+0x9b>
    1d27:	mov    QWORD PTR [rsp+0x8],rax
    1d2c:	mov    rsi,rax
    1d2f:	mov    QWORD PTR [rsp+0x10],rdx
    1d34:	mov    rbx,rdx
    1d37:	mov    rdi,r14
    1d3a:	call   1d3f <botlish_fn_21+0x64>
			1d3b: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1d3f:	test   rax,rax
    1d42:	je     1d76 <botlish_fn_21+0x9b>
    1d48:	mov    QWORD PTR [rsp+0x8],rax
    1d4d:	mov    rcx,rax
    1d50:	mov    r8d,0x3
    1d56:	mov    QWORD PTR [rsp+0x18],0x3
    1d5f:	mov    rdx,rbx
    1d62:	mov    rsi,r12
    1d65:	mov    rdi,r14
    1d68:	call   1d6d <botlish_fn_21+0x92>
			1d69: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1d6d:	test   rax,rax
    1d70:	jne    1d94 <botlish_fn_21+0xb9>
    1d76:	xor    rdx,rdx
    1d79:	mov    rax,rdx
    1d7c:	mov    rbx,QWORD PTR [rsp+0x20]
    1d81:	mov    r12,QWORD PTR [rsp+0x28]
    1d86:	mov    r14,QWORD PTR [rsp+0x30]
    1d8b:	add    rsp,0x40
    1d8f:	mov    rsp,rbp
    1d92:	pop    rbp
    1d93:	ret
    1d94:	mov    rbx,QWORD PTR [rsp+0x20]
    1d99:	mov    r12,QWORD PTR [rsp+0x28]
    1d9e:	mov    r14,QWORD PTR [rsp+0x30]
    1da3:	add    rsp,0x40
    1da7:	mov    rsp,rbp
    1daa:	pop    rbp
    1dab:	ret

0000000000001dac <botlish_entry_21: scan_record<str, int>>:
    1dac:	push   rbp
    1dad:	mov    rbp,rsp
    1db0:	ud2
    1db2:	add    BYTE PTR [rax],al
    1db4:	add    BYTE PTR [rax],al
	...

0000000000001db8 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1db8:	push   rbp
    1db9:	mov    rbp,rsp
    1dbc:	sub    rsp,0x60
    1dc0:	mov    QWORD PTR [rsp+0x30],rbx
    1dc5:	mov    QWORD PTR [rsp+0x38],r12
    1dca:	mov    QWORD PTR [rsp+0x40],r13
    1dcf:	mov    QWORD PTR [rsp+0x48],r14
    1dd4:	mov    QWORD PTR [rsp+0x50],r15
    1dd9:	mov    r13,rdi
    1ddc:	mov    QWORD PTR [rsp+0x20],0x0
    1de5:	mov    QWORD PTR [rsp],rsi
    1de9:	mov    QWORD PTR [rsp+0x8],rdx
    1dee:	mov    r12,rdx
    1df1:	mov    QWORD PTR [rsp+0x10],rcx
    1df6:	mov    QWORD PTR [rsp+0x18],r8
    1dfb:	mov    rbx,rsi
    1dfe:	mov    r14,r8
    1e01:	mov    r15,rcx
    1e04:	mov    rsi,rbx
    1e07:	mov    rdi,r13
    1e0a:	call   1e0f <botlish_fn_22+0x57>
			1e0b: R_X86_64_PLT32	rt_str_len-0x4
    1e0f:	mov    rcx,r12
    1e12:	and    rcx,rax
    1e15:	mov    rdx,rax
    1e18:	test   rcx,0x1
    1e1f:	jne    1e45 <botlish_fn_22+0x8d>
    1e25:	mov    rsi,r12
    1e28:	mov    rdi,r13
    1e2b:	call   1e30 <botlish_fn_22+0x78>
			1e2c: R_X86_64_PLT32	rt_int_cmp-0x4
    1e30:	mov    ecx,0x2
    1e35:	test   rax,rax
    1e38:	cmovge rcx,QWORD PTR [rip+0x128]        # 1f68 <botlish_fn_22+0x1b0>
    1e40:	jmp    1e55 <botlish_fn_22+0x9d>
    1e45:	mov    ecx,0x2
    1e4a:	cmp    r12,rdx
    1e4d:	cmovge rcx,QWORD PTR [rip+0x113]        # 1f68 <botlish_fn_22+0x1b0>
    1e55:	cmp    rcx,0x6
    1e59:	je     1f04 <botlish_fn_22+0x14c>
    1e5f:	mov    rdx,r12
    1e62:	mov    rsi,rbx
    1e65:	mov    rdi,r13
    1e68:	call   1e6d <botlish_fn_22+0xb5>
			1e69: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1e6d:	test   rax,rax
    1e70:	je     1f1b <botlish_fn_22+0x163>
    1e76:	mov    QWORD PTR [rsp+0x8],rax
    1e7b:	mov    rcx,rax
    1e7e:	mov    QWORD PTR [rsp+0x20],rdx
    1e83:	mov    rsi,r15
    1e86:	mov    r12,rdx
    1e89:	mov    rdx,r14
    1e8c:	mov    rdi,r13
    1e8f:	call   1e94 <botlish_fn_22+0xdc>
			1e90: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1e94:	test   rax,rax
    1e97:	je     1f1b <botlish_fn_22+0x163>
    1e9d:	mov    QWORD PTR [rsp+0x8],rax
    1ea2:	mov    r15,rax
    1ea5:	mov    QWORD PTR [rsp+0x10],0x3
    1eae:	mov    rsi,r14
    1eb1:	test   rsi,0x1
    1eb8:	je     1ed3 <botlish_fn_22+0x11b>
    1ebe:	mov    rsi,r14
    1ec1:	mov    rax,rsi
    1ec4:	add    rax,0x2
    1ec8:	seto   cl
    1ecb:	test   cl,cl
    1ecd:	je     1ee3 <botlish_fn_22+0x12b>
    1ed3:	mov    edx,0x3
    1ed8:	mov    rsi,r14
    1edb:	mov    rdi,r13
    1ede:	call   1ee3 <botlish_fn_22+0x12b>
			1edf: R_X86_64_PLT32	rt_int_add-0x4
    1ee3:	mov    QWORD PTR [rsp],rbx
    1ee7:	mov    rdx,r12
    1eea:	mov    QWORD PTR [rsp+0x8],rdx
    1eef:	mov    rcx,r15
    1ef2:	mov    QWORD PTR [rsp+0x10],rcx
    1ef7:	mov    QWORD PTR [rsp+0x18],rax
    1efc:	mov    r14,rax
    1eff:	jmp    1e04 <botlish_fn_22+0x4c>
    1f04:	mov    rdx,r14
    1f07:	mov    rsi,r15
    1f0a:	mov    rdi,r13
    1f0d:	call   1f12 <botlish_fn_22+0x15a>
			1f0e: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1f12:	test   rax,rax
    1f15:	jne    1f40 <botlish_fn_22+0x188>
    1f1b:	xor    rax,rax
    1f1e:	mov    rbx,QWORD PTR [rsp+0x30]
    1f23:	mov    r12,QWORD PTR [rsp+0x38]
    1f28:	mov    r13,QWORD PTR [rsp+0x40]
    1f2d:	mov    r14,QWORD PTR [rsp+0x48]
    1f32:	mov    r15,QWORD PTR [rsp+0x50]
    1f37:	add    rsp,0x60
    1f3b:	mov    rsp,rbp
    1f3e:	pop    rbp
    1f3f:	ret
    1f40:	mov    rbx,QWORD PTR [rsp+0x30]
    1f45:	mov    r12,QWORD PTR [rsp+0x38]
    1f4a:	mov    r13,QWORD PTR [rsp+0x40]
    1f4f:	mov    r14,QWORD PTR [rsp+0x48]
    1f54:	mov    r15,QWORD PTR [rsp+0x50]
    1f59:	add    rsp,0x60
    1f5d:	mov    rsp,rbp
    1f60:	pop    rbp
    1f61:	ret
    1f62:	add    BYTE PTR [rax],al
    1f64:	add    BYTE PTR [rax],al
    1f66:	add    BYTE PTR [rax],al
    1f68:	(bad)
    1f69:	add    BYTE PTR [rax],al
    1f6b:	add    BYTE PTR [rax],al
    1f6d:	add    BYTE PTR [rax],al
	...

0000000000001f70 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    1f70:	push   rbp
    1f71:	mov    rbp,rsp
    1f74:	mov    rsi,QWORD PTR [rdx]
    1f77:	mov    r9,QWORD PTR [rdx+0x8]
    1f7b:	mov    rcx,QWORD PTR [rdx+0x10]
    1f7f:	mov    r8,QWORD PTR [rdx+0x18]
    1f83:	mov    rdx,r9
    1f86:	call   1f8b <botlish_entry_22+0x1b>
			1f87: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    1f8b:	mov    rsp,rbp
    1f8e:	pop    rbp
    1f8f:	ret

0000000000001f90 <botlish_fn_23: csv_parse<str>>:
    1f90:	push   rbp
    1f91:	mov    rbp,rsp
    1f94:	sub    rsp,0x40
    1f98:	mov    QWORD PTR [rsp+0x20],rbx
    1f9d:	mov    QWORD PTR [rsp+0x28],r12
    1fa2:	mov    QWORD PTR [rsp+0x30],r13
    1fa7:	mov    rbx,rdi
    1faa:	mov    QWORD PTR [rsp+0x8],0x0
    1fb3:	mov    QWORD PTR [rsp+0x10],0x0
    1fbc:	mov    QWORD PTR [rsp+0x18],0x0
    1fc5:	mov    QWORD PTR [rsp],rsi
    1fc9:	mov    r12,rsi
    1fcc:	mov    rsi,r12
    1fcf:	mov    rdi,rbx
    1fd2:	call   1fd7 <botlish_fn_23+0x47>
			1fd3: R_X86_64_PLT32	rt_str_len-0x4
    1fd7:	sar    rax,1
    1fda:	test   rax,rax
    1fdd:	je     206c <botlish_fn_23+0xdc>
    1fe3:	mov    edx,0x1
    1fe8:	mov    QWORD PTR [rsp+0x8],0x1
    1ff1:	mov    rsi,r12
    1ff4:	mov    rdi,rbx
    1ff7:	call   1ffc <botlish_fn_23+0x6c>
			1ff8: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1ffc:	test   rax,rax
    1fff:	je     2083 <botlish_fn_23+0xf3>
    2005:	mov    QWORD PTR [rsp+0x8],rax
    200a:	mov    rsi,rax
    200d:	mov    QWORD PTR [rsp+0x10],rdx
    2012:	mov    r13,rdx
    2015:	mov    rdi,rbx
    2018:	call   201d <botlish_fn_23+0x8d>
			2019: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    201d:	test   rax,rax
    2020:	je     2083 <botlish_fn_23+0xf3>
    2026:	mov    QWORD PTR [rsp+0x8],rax
    202b:	mov    rcx,rax
    202e:	mov    r8d,0x3
    2034:	mov    QWORD PTR [rsp+0x18],0x3
    203d:	mov    rdx,r13
    2040:	mov    rsi,r12
    2043:	mov    rdi,rbx
    2046:	call   204b <botlish_fn_23+0xbb>
			2047: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    204b:	test   rax,rax
    204e:	je     2083 <botlish_fn_23+0xf3>
    2054:	mov    rbx,QWORD PTR [rsp+0x20]
    2059:	mov    r12,QWORD PTR [rsp+0x28]
    205e:	mov    r13,QWORD PTR [rsp+0x30]
    2063:	add    rsp,0x40
    2067:	mov    rsp,rbp
    206a:	pop    rbp
    206b:	ret
    206c:	xor    rdx,rdx
    206f:	mov    rdi,rbx
    2072:	mov    rsi,rdx
    2075:	call   207a <botlish_fn_23+0xea>
			2076: R_X86_64_PLT32	rt_list_new-0x4
    207a:	test   rax,rax
    207d:	jne    209e <botlish_fn_23+0x10e>
    2083:	xor    rax,rax
    2086:	mov    rbx,QWORD PTR [rsp+0x20]
    208b:	mov    r12,QWORD PTR [rsp+0x28]
    2090:	mov    r13,QWORD PTR [rsp+0x30]
    2095:	add    rsp,0x40
    2099:	mov    rsp,rbp
    209c:	pop    rbp
    209d:	ret
    209e:	mov    rbx,QWORD PTR [rsp+0x20]
    20a3:	mov    r12,QWORD PTR [rsp+0x28]
    20a8:	mov    r13,QWORD PTR [rsp+0x30]
    20ad:	add    rsp,0x40
    20b1:	mov    rsp,rbp
    20b4:	pop    rbp
    20b5:	ret

00000000000020b6 <botlish_entry_23: csv_parse<str>>:
    20b6:	push   rbp
    20b7:	mov    rbp,rsp
    20ba:	mov    rsi,QWORD PTR [rdx]
    20bd:	call   20c2 <botlish_entry_23+0xc>
			20be: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    20c2:	mov    rsp,rbp
    20c5:	pop    rbp
    20c6:	ret
	...

00000000000020c8 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    20c8:	push   rbp
    20c9:	mov    rbp,rsp
    20cc:	sub    rsp,0x40
    20d0:	mov    QWORD PTR [rsp+0x20],rbx
    20d5:	mov    QWORD PTR [rsp+0x28],r12
    20da:	mov    QWORD PTR [rsp+0x30],r13
    20df:	mov    QWORD PTR [rsp+0x38],r14
    20e4:	mov    r13,rdi
    20e7:	mov    QWORD PTR [rsp],rsi
    20eb:	mov    rbx,rsi
    20ee:	mov    QWORD PTR [rsp+0x8],rdx
    20f3:	mov    QWORD PTR [rsp+0x10],rcx
    20f8:	mov    r12,rcx
    20fb:	mov    rsi,rdx
    20fe:	mov    rax,rsi
    2101:	and    rax,r12
    2104:	mov    r14,rsi
    2107:	test   rax,0x1
    210d:	jne    2136 <botlish_fn_24+0x6e>
    2113:	mov    rdx,r12
    2116:	mov    rsi,r14
    2119:	mov    rdi,r13
    211c:	call   2121 <botlish_fn_24+0x59>
			211d: R_X86_64_PLT32	rt_int_cmp-0x4
    2121:	mov    ecx,0x2
    2126:	test   rax,rax
    2129:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2210 <botlish_fn_24+0x148>
    2131:	jmp    2149 <botlish_fn_24+0x81>
    2136:	mov    ecx,0x2
    213b:	mov    rsi,r14
    213e:	cmp    rsi,r12
    2141:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2210 <botlish_fn_24+0x148>
    2149:	cmp    rcx,0x6
    214d:	je     21ee <botlish_fn_24+0x126>
    2153:	mov    ecx,0x1
    2158:	mov    rdx,r14
    215b:	mov    rsi,rbx
    215e:	mov    rdi,r13
    2161:	call   2166 <botlish_fn_24+0x9e>
			2162: R_X86_64_PLT32	rt_mutarray_set-0x4
    2166:	test   rax,rax
    2169:	jne    218f <botlish_fn_24+0xc7>
    216f:	xor    rax,rax
    2172:	mov    rbx,QWORD PTR [rsp+0x20]
    2177:	mov    r12,QWORD PTR [rsp+0x28]
    217c:	mov    r13,QWORD PTR [rsp+0x30]
    2181:	mov    r14,QWORD PTR [rsp+0x38]
    2186:	add    rsp,0x40
    218a:	mov    rsp,rbp
    218d:	pop    rbp
    218e:	ret
    218f:	mov    QWORD PTR [rsp+0x18],0x3
    2198:	mov    rsi,r14
    219b:	test   rsi,0x1
    21a2:	je     21c5 <botlish_fn_24+0xfd>
    21a8:	mov    rsi,r14
    21ab:	mov    rcx,rsi
    21ae:	add    rcx,0x2
    21b2:	seto   al
    21b5:	test   al,al
    21b7:	jne    21c5 <botlish_fn_24+0xfd>
    21bd:	mov    r14,rcx
    21c0:	jmp    21d8 <botlish_fn_24+0x110>
    21c5:	mov    edx,0x3
    21ca:	mov    rsi,r14
    21cd:	mov    rdi,r13
    21d0:	call   21d5 <botlish_fn_24+0x10d>
			21d1: R_X86_64_PLT32	rt_int_add-0x4
    21d5:	mov    r14,rax
    21d8:	mov    QWORD PTR [rsp],rbx
    21dc:	mov    rsi,r14
    21df:	mov    QWORD PTR [rsp+0x8],rsi
    21e4:	mov    QWORD PTR [rsp+0x10],r12
    21e9:	jmp    20fe <botlish_fn_24+0x36>
    21ee:	mov    eax,0xa
    21f3:	mov    rbx,QWORD PTR [rsp+0x20]
    21f8:	mov    r12,QWORD PTR [rsp+0x28]
    21fd:	mov    r13,QWORD PTR [rsp+0x30]
    2202:	mov    r14,QWORD PTR [rsp+0x38]
    2207:	add    rsp,0x40
    220b:	mov    rsp,rbp
    220e:	pop    rbp
    220f:	ret
    2210:	(bad)
    2211:	add    BYTE PTR [rax],al
    2213:	add    BYTE PTR [rax],al
    2215:	add    BYTE PTR [rax],al
	...

0000000000002218 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    2218:	push   rbp
    2219:	mov    rbp,rsp
    221c:	mov    rsi,QWORD PTR [rdx]
    221f:	mov    r8,QWORD PTR [rdx+0x8]
    2223:	mov    rcx,QWORD PTR [rdx+0x10]
    2227:	mov    rdx,r8
    222a:	call   222f <botlish_entry_24+0x17>
			222b: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    222f:	mov    rsp,rbp
    2232:	pop    rbp
    2233:	ret

0000000000002234 <botlish_fn_25: ht_alloc<int>>:
    2234:	push   rbp
    2235:	mov    rbp,rsp
    2238:	sub    rsp,0x50
    223c:	mov    QWORD PTR [rsp+0x20],rbx
    2241:	mov    QWORD PTR [rsp+0x28],r12
    2246:	mov    QWORD PTR [rsp+0x30],r13
    224b:	mov    QWORD PTR [rsp+0x38],r14
    2250:	mov    QWORD PTR [rsp+0x40],r15
    2255:	mov    rbx,rdi
    2258:	mov    QWORD PTR [rsp+0x8],0x0
    2261:	mov    QWORD PTR [rsp+0x10],0x0
    226a:	mov    QWORD PTR [rsp+0x18],0x0
    2273:	mov    QWORD PTR [rsp],rsi
    2277:	mov    r13,rsi
    227a:	mov    rsi,r13
    227d:	mov    rdi,rbx
    2280:	call   2285 <botlish_fn_25+0x51>
			2281: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2285:	test   rax,rax
    2288:	je     23a4 <botlish_fn_25+0x170>
    228e:	mov    QWORD PTR [rsp+0x8],rax
    2293:	mov    r12,rax
    2296:	mov    edx,0x1
    229b:	mov    QWORD PTR [rsp+0x10],0x1
    22a4:	mov    rcx,r13
    22a7:	mov    rsi,r12
    22aa:	mov    rdi,rbx
    22ad:	call   22b2 <botlish_fn_25+0x7e>
			22ae: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    22b2:	test   rax,rax
    22b5:	je     23a4 <botlish_fn_25+0x170>
    22bb:	mov    rsi,r13
    22be:	mov    rdi,rbx
    22c1:	call   22c6 <botlish_fn_25+0x92>
			22c2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22c6:	test   rax,rax
    22c9:	je     23a4 <botlish_fn_25+0x170>
    22cf:	mov    QWORD PTR [rsp+0x10],rax
    22d4:	mov    rsi,r13
    22d7:	mov    r14,rax
    22da:	mov    rdi,rbx
    22dd:	call   22e2 <botlish_fn_25+0xae>
			22de: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22e2:	test   rax,rax
    22e5:	je     23a4 <botlish_fn_25+0x170>
    22eb:	mov    QWORD PTR [rsp],rax
    22ef:	mov    r13,rax
    22f2:	mov    esi,0xb
    22f7:	mov    QWORD PTR [rsp+0x18],0xb
    2300:	mov    rdi,rbx
    2303:	call   2308 <botlish_fn_25+0xd4>
			2304: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2308:	test   rax,rax
    230b:	mov    r15,rax
    230e:	je     23a4 <botlish_fn_25+0x170>
    2314:	mov    edx,0x1
    2319:	mov    rcx,r12
    231c:	mov    rsi,r15
    231f:	mov    rdi,rbx
    2322:	call   2327 <botlish_fn_25+0xf3>
			2323: R_X86_64_PLT32	rt_mutarray_set-0x4
    2327:	test   rax,rax
    232a:	je     23a4 <botlish_fn_25+0x170>
    2330:	mov    edx,0x3
    2335:	mov    rcx,r14
    2338:	mov    rsi,r15
    233b:	mov    rdi,rbx
    233e:	call   2343 <botlish_fn_25+0x10f>
			233f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2343:	test   rax,rax
    2346:	je     23a4 <botlish_fn_25+0x170>
    234c:	mov    edx,0x5
    2351:	mov    rcx,r13
    2354:	mov    rsi,r15
    2357:	mov    rdi,rbx
    235a:	call   235f <botlish_fn_25+0x12b>
			235b: R_X86_64_PLT32	rt_mutarray_set-0x4
    235f:	test   rax,rax
    2362:	je     23a4 <botlish_fn_25+0x170>
    2368:	mov    edx,0x7
    236d:	mov    ecx,0x1
    2372:	mov    rsi,r15
    2375:	mov    rdi,rbx
    2378:	call   237d <botlish_fn_25+0x149>
			2379: R_X86_64_PLT32	rt_mutarray_set-0x4
    237d:	test   rax,rax
    2380:	je     23a4 <botlish_fn_25+0x170>
    2386:	mov    edx,0x9
    238b:	mov    ecx,0x1
    2390:	mov    rdi,rbx
    2393:	mov    rsi,r15
    2396:	call   239b <botlish_fn_25+0x167>
			2397: R_X86_64_PLT32	rt_mutarray_set-0x4
    239b:	test   rax,rax
    239e:	jne    23c9 <botlish_fn_25+0x195>
    23a4:	xor    rax,rax
    23a7:	mov    rbx,QWORD PTR [rsp+0x20]
    23ac:	mov    r12,QWORD PTR [rsp+0x28]
    23b1:	mov    r13,QWORD PTR [rsp+0x30]
    23b6:	mov    r14,QWORD PTR [rsp+0x38]
    23bb:	mov    r15,QWORD PTR [rsp+0x40]
    23c0:	add    rsp,0x50
    23c4:	mov    rsp,rbp
    23c7:	pop    rbp
    23c8:	ret
    23c9:	mov    rax,r15
    23cc:	mov    rbx,QWORD PTR [rsp+0x20]
    23d1:	mov    r12,QWORD PTR [rsp+0x28]
    23d6:	mov    r13,QWORD PTR [rsp+0x30]
    23db:	mov    r14,QWORD PTR [rsp+0x38]
    23e0:	mov    r15,QWORD PTR [rsp+0x40]
    23e5:	add    rsp,0x50
    23e9:	mov    rsp,rbp
    23ec:	pop    rbp
    23ed:	ret

00000000000023ee <botlish_entry_25: ht_alloc<int>>:
    23ee:	push   rbp
    23ef:	mov    rbp,rsp
    23f2:	mov    rsi,QWORD PTR [rdx]
    23f5:	call   23fa <botlish_entry_25+0xc>
			23f6: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    23fa:	mov    rsp,rbp
    23fd:	pop    rbp
    23fe:	ret

00000000000023ff <botlish_fn_26: ht_new<generic>>:
    23ff:	push   rbp
    2400:	mov    rbp,rsp
    2403:	sub    rsp,0x10
    2407:	mov    esi,0x11
    240c:	mov    QWORD PTR [rsp],0x11
    2414:	call   2419 <botlish_fn_26+0x1a>
			2415: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2419:	test   rax,rax
    241c:	jne    242e <botlish_fn_26+0x2f>
    2422:	xor    rax,rax
    2425:	add    rsp,0x10
    2429:	mov    rsp,rbp
    242c:	pop    rbp
    242d:	ret
    242e:	add    rsp,0x10
    2432:	mov    rsp,rbp
    2435:	pop    rbp
    2436:	ret

0000000000002437 <botlish_entry_26: ht_new<generic>>:
    2437:	push   rbp
    2438:	mov    rbp,rsp
    243b:	call   2440 <botlish_entry_26+0x9>
			243c: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    2440:	mov    rsp,rbp
    2443:	pop    rbp
    2444:	ret
    2445:	add    BYTE PTR [rax],al
	...

0000000000002448 <botlish_fn_27: ht_capacity_for<int, int>>:
    2448:	push   rbp
    2449:	mov    rbp,rsp
    244c:	sub    rsp,0x50
    2450:	mov    QWORD PTR [rsp+0x20],rbx
    2455:	mov    QWORD PTR [rsp+0x28],r12
    245a:	mov    QWORD PTR [rsp+0x30],r13
    245f:	mov    QWORD PTR [rsp+0x38],r14
    2464:	mov    QWORD PTR [rsp+0x40],r15
    2469:	mov    r13,rdi
    246c:	mov    QWORD PTR [rsp],rdx
    2470:	mov    rbx,rsi
    2473:	or     rbx,0x1
    2477:	sar    rbx,1
    247a:	mov    r12,rsi
    247d:	mov    r14,rdx
    2480:	mov    rax,r12
    2483:	or     rax,0x1
    2487:	mov    QWORD PTR [rsp+0x8],rax
    248c:	mov    QWORD PTR [rsp+0x10],0x7
    2495:	mov    rax,rbx
    2498:	imul   QWORD PTR [rip+0x159]        # 25f8 <botlish_fn_27+0x1b0>
    249f:	seto   cl
    24a2:	or     rax,0x1
    24a6:	test   cl,cl
    24a8:	jne    24b6 <botlish_fn_27+0x6e>
    24ae:	mov    rsi,rax
    24b1:	jmp    24cd <botlish_fn_27+0x85>
    24b6:	mov    rsi,r12
    24b9:	or     rsi,0x1
    24bd:	mov    edx,0x7
    24c2:	mov    rdi,r13
    24c5:	call   24ca <botlish_fn_27+0x82>
			24c6: R_X86_64_PLT32	rt_int_mul-0x4
    24ca:	mov    rsi,rax
    24cd:	mov    QWORD PTR [rsp+0x8],rsi
    24d2:	mov    r15,rsi
    24d5:	mov    QWORD PTR [rsp+0x10],0x5
    24de:	mov    rsi,r14
    24e1:	test   rsi,0x1
    24e8:	je     2518 <botlish_fn_27+0xd0>
    24ee:	mov    rsi,r14
    24f1:	mov    rax,rsi
    24f4:	sar    rax,1
    24f7:	imul   QWORD PTR [rip+0x102]        # 2600 <botlish_fn_27+0x1b8>
    24fe:	seto   cl
    2501:	or     rax,0x1
    2505:	test   cl,cl
    2507:	jne    2518 <botlish_fn_27+0xd0>
    250d:	mov    rdx,rax
    2510:	mov    rsi,r15
    2513:	jmp    252e <botlish_fn_27+0xe6>
    2518:	mov    edx,0x5
    251d:	mov    rsi,r14
    2520:	mov    rdi,r13
    2523:	call   2528 <botlish_fn_27+0xe0>
			2524: R_X86_64_PLT32	rt_int_mul-0x4
    2528:	mov    rdx,rax
    252b:	mov    rsi,r15
    252e:	mov    rax,rsi
    2531:	and    rax,rdx
    2534:	test   rax,0x1
    253a:	jne    255d <botlish_fn_27+0x115>
    2540:	mov    rdi,r13
    2543:	call   2548 <botlish_fn_27+0x100>
			2544: R_X86_64_PLT32	rt_int_cmp-0x4
    2548:	mov    ecx,0x2
    254d:	test   rax,rax
    2550:	cmovle rcx,QWORD PTR [rip+0xa0]        # 25f8 <botlish_fn_27+0x1b0>
    2558:	jmp    256d <botlish_fn_27+0x125>
    255d:	mov    ecx,0x2
    2562:	cmp    rsi,rdx
    2565:	cmovle rcx,QWORD PTR [rip+0x8b]        # 25f8 <botlish_fn_27+0x1b0>
    256d:	cmp    rcx,0x6
    2571:	je     25cd <botlish_fn_27+0x185>
    2577:	mov    QWORD PTR [rsp+0x8],0x5
    2580:	mov    rsi,r14
    2583:	test   rsi,0x1
    258a:	je     25b1 <botlish_fn_27+0x169>
    2590:	mov    rsi,r14
    2593:	mov    rax,rsi
    2596:	sar    rax,1
    2599:	imul   QWORD PTR [rip+0x60]        # 2600 <botlish_fn_27+0x1b8>
    25a0:	seto   sil
    25a4:	or     rax,0x1
    25a8:	test   sil,sil
    25ab:	je     25c1 <botlish_fn_27+0x179>
    25b1:	mov    edx,0x5
    25b6:	mov    rsi,r14
    25b9:	mov    rdi,r13
    25bc:	call   25c1 <botlish_fn_27+0x179>
			25bd: R_X86_64_PLT32	rt_int_mul-0x4
    25c1:	mov    QWORD PTR [rsp],rax
    25c5:	mov    r14,rax
    25c8:	jmp    2480 <botlish_fn_27+0x38>
    25cd:	mov    rax,r14
    25d0:	mov    rbx,QWORD PTR [rsp+0x20]
    25d5:	mov    r12,QWORD PTR [rsp+0x28]
    25da:	mov    r13,QWORD PTR [rsp+0x30]
    25df:	mov    r14,QWORD PTR [rsp+0x38]
    25e4:	mov    r15,QWORD PTR [rsp+0x40]
    25e9:	add    rsp,0x50
    25ed:	mov    rsp,rbp
    25f0:	pop    rbp
    25f1:	ret
    25f2:	add    BYTE PTR [rax],al
    25f4:	add    BYTE PTR [rax],al
    25f6:	add    BYTE PTR [rax],al
    25f8:	(bad)
    25f9:	add    BYTE PTR [rax],al
    25fb:	add    BYTE PTR [rax],al
    25fd:	add    BYTE PTR [rax],al
    25ff:	add    BYTE PTR [rax+rax*1],al
    2602:	add    BYTE PTR [rax],al
    2604:	add    BYTE PTR [rax],al
	...

0000000000002608 <botlish_entry_27: ht_capacity_for<int, int>>:
    2608:	push   rbp
    2609:	mov    rbp,rsp
    260c:	mov    rsi,QWORD PTR [rdx]
    260f:	mov    rdx,QWORD PTR [rdx+0x8]
    2613:	call   2618 <botlish_entry_27+0x10>
			2614: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2618:	mov    rsp,rbp
    261b:	pop    rbp
    261c:	ret

000000000000261d <botlish_fn_28: ht_new_sized<int>>:
    261d:	push   rbp
    261e:	mov    rbp,rsp
    2621:	sub    rsp,0x20
    2625:	mov    QWORD PTR [rsp+0x10],r12
    262a:	mov    r12,rdi
    262d:	mov    QWORD PTR [rsp],rsi
    2631:	mov    edx,0x11
    2636:	mov    QWORD PTR [rsp+0x8],0x11
    263f:	mov    rdi,r12
    2642:	call   2647 <botlish_fn_28+0x2a>
			2643: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2647:	mov    QWORD PTR [rsp],rax
    264b:	mov    rsi,rax
    264e:	mov    rdi,r12
    2651:	call   2656 <botlish_fn_28+0x39>
			2652: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2656:	test   rax,rax
    2659:	jne    2670 <botlish_fn_28+0x53>
    265f:	xor    rax,rax
    2662:	mov    r12,QWORD PTR [rsp+0x10]
    2667:	add    rsp,0x20
    266b:	mov    rsp,rbp
    266e:	pop    rbp
    266f:	ret
    2670:	mov    r12,QWORD PTR [rsp+0x10]
    2675:	add    rsp,0x20
    2679:	mov    rsp,rbp
    267c:	pop    rbp
    267d:	ret

000000000000267e <botlish_entry_28: ht_new_sized<int>>:
    267e:	push   rbp
    267f:	mov    rbp,rsp
    2682:	mov    rsi,QWORD PTR [rdx]
    2685:	call   268a <botlish_entry_28+0xc>
			2686: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    268a:	mov    rsp,rbp
    268d:	pop    rbp
    268e:	ret

000000000000268f <botlish_fn_29: ht_controls<mutarray>>:
    268f:	push   rbp
    2690:	mov    rbp,rsp
    2693:	mov    edx,0x1
    2698:	call   269d <botlish_fn_29+0xe>
			2699: R_X86_64_PLT32	rt_mutarray_get-0x4
    269d:	test   rax,rax
    26a0:	jne    26ae <botlish_fn_29+0x1f>
    26a6:	xor    rax,rax
    26a9:	mov    rsp,rbp
    26ac:	pop    rbp
    26ad:	ret
    26ae:	mov    rsp,rbp
    26b1:	pop    rbp
    26b2:	ret

00000000000026b3 <botlish_entry_29: ht_controls<mutarray>>:
    26b3:	push   rbp
    26b4:	mov    rbp,rsp
    26b7:	mov    rsi,QWORD PTR [rdx]
    26ba:	call   26bf <botlish_entry_29+0xc>
			26bb: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    26bf:	mov    rsp,rbp
    26c2:	pop    rbp
    26c3:	ret

00000000000026c4 <botlish_fn_30: ht_keys<mutarray>>:
    26c4:	push   rbp
    26c5:	mov    rbp,rsp
    26c8:	mov    edx,0x3
    26cd:	call   26d2 <botlish_fn_30+0xe>
			26ce: R_X86_64_PLT32	rt_mutarray_get-0x4
    26d2:	test   rax,rax
    26d5:	jne    26e3 <botlish_fn_30+0x1f>
    26db:	xor    rax,rax
    26de:	mov    rsp,rbp
    26e1:	pop    rbp
    26e2:	ret
    26e3:	mov    rsp,rbp
    26e6:	pop    rbp
    26e7:	ret

00000000000026e8 <botlish_entry_30: ht_keys<mutarray>>:
    26e8:	push   rbp
    26e9:	mov    rbp,rsp
    26ec:	mov    rsi,QWORD PTR [rdx]
    26ef:	call   26f4 <botlish_entry_30+0xc>
			26f0: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    26f4:	mov    rsp,rbp
    26f7:	pop    rbp
    26f8:	ret

00000000000026f9 <botlish_fn_31: ht_values<mutarray>>:
    26f9:	push   rbp
    26fa:	mov    rbp,rsp
    26fd:	mov    edx,0x5
    2702:	call   2707 <botlish_fn_31+0xe>
			2703: R_X86_64_PLT32	rt_mutarray_get-0x4
    2707:	test   rax,rax
    270a:	jne    2718 <botlish_fn_31+0x1f>
    2710:	xor    rax,rax
    2713:	mov    rsp,rbp
    2716:	pop    rbp
    2717:	ret
    2718:	mov    rsp,rbp
    271b:	pop    rbp
    271c:	ret

000000000000271d <botlish_entry_31: ht_values<mutarray>>:
    271d:	push   rbp
    271e:	mov    rbp,rsp
    2721:	mov    rsi,QWORD PTR [rdx]
    2724:	call   2729 <botlish_entry_31+0xc>
			2725: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    2729:	mov    rsp,rbp
    272c:	pop    rbp
    272d:	ret

000000000000272e <botlish_fn_32: ht_size<mutarray>>:
    272e:	push   rbp
    272f:	mov    rbp,rsp
    2732:	mov    edx,0x7
    2737:	call   273c <botlish_fn_32+0xe>
			2738: R_X86_64_PLT32	rt_mutarray_get-0x4
    273c:	test   rax,rax
    273f:	jne    274d <botlish_fn_32+0x1f>
    2745:	xor    rax,rax
    2748:	mov    rsp,rbp
    274b:	pop    rbp
    274c:	ret
    274d:	mov    rsp,rbp
    2750:	pop    rbp
    2751:	ret

0000000000002752 <botlish_entry_32: ht_size<mutarray>>:
    2752:	push   rbp
    2753:	mov    rbp,rsp
    2756:	mov    rsi,QWORD PTR [rdx]
    2759:	call   275e <botlish_entry_32+0xc>
			275a: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    275e:	mov    rsp,rbp
    2761:	pop    rbp
    2762:	ret

0000000000002763 <botlish_fn_33: ht_tombstones<mutarray>>:
    2763:	push   rbp
    2764:	mov    rbp,rsp
    2767:	mov    edx,0x9
    276c:	call   2771 <botlish_fn_33+0xe>
			276d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2771:	test   rax,rax
    2774:	jne    2782 <botlish_fn_33+0x1f>
    277a:	xor    rax,rax
    277d:	mov    rsp,rbp
    2780:	pop    rbp
    2781:	ret
    2782:	mov    rsp,rbp
    2785:	pop    rbp
    2786:	ret

0000000000002787 <botlish_entry_33: ht_tombstones<mutarray>>:
    2787:	push   rbp
    2788:	mov    rbp,rsp
    278b:	mov    rsi,QWORD PTR [rdx]
    278e:	call   2793 <botlish_entry_33+0xc>
			278f: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    2793:	mov    rsp,rbp
    2796:	pop    rbp
    2797:	ret

0000000000002798 <botlish_fn_34: ht_capacity<mutarray>>:
    2798:	push   rbp
    2799:	mov    rbp,rsp
    279c:	sub    rsp,0x10
    27a0:	mov    QWORD PTR [rsp],rbx
    27a4:	mov    rbx,rdi
    27a7:	mov    rdi,rbx
    27aa:	call   27af <botlish_fn_34+0x17>
			27ab: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    27af:	test   rax,rax
    27b2:	je     27fc <botlish_fn_34+0x64>
    27b8:	xor    r8d,r8d
    27bb:	test   rax,0x7
    27c1:	je     27cf <botlish_fn_34+0x37>
    27c7:	mov    rsi,rax
    27ca:	jmp    27de <botlish_fn_34+0x46>
    27cf:	movzx  rcx,BYTE PTR [rax]
    27d3:	mov    rsi,rax
    27d6:	rex cmp cl,0x8
    27da:	sete   r8b
    27de:	test   r8b,r8b
    27e1:	jne    280c <botlish_fn_34+0x74>
    27e7:	mov    rdi,rbx
    27ea:	mov    rax,QWORD PTR [rdi+0x10]
    27ee:	mov    rcx,QWORD PTR [rax+0x28]
    27f2:	mov    edx,0x8
    27f7:	call   27fc <botlish_fn_34+0x64>
			27f8: R_X86_64_PLT32	rt_type_error-0x4
    27fc:	xor    rax,rax
    27ff:	mov    rbx,QWORD PTR [rsp]
    2803:	add    rsp,0x10
    2807:	mov    rsp,rbp
    280a:	pop    rbp
    280b:	ret
    280c:	mov    rdi,rbx
    280f:	call   2814 <botlish_fn_34+0x7c>
			2810: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2814:	mov    rbx,QWORD PTR [rsp]
    2818:	add    rsp,0x10
    281c:	mov    rsp,rbp
    281f:	pop    rbp
    2820:	ret

0000000000002821 <botlish_entry_34: ht_capacity<mutarray>>:
    2821:	push   rbp
    2822:	mov    rbp,rsp
    2825:	mov    rsi,QWORD PTR [rdx]
    2828:	call   282d <botlish_entry_34+0xc>
			2829: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    282d:	mov    rsp,rbp
    2830:	pop    rbp
    2831:	ret

0000000000002832 <botlish_fn_35: ht_probe_start<mutarray, str>>:
    2832:	push   rbp
    2833:	mov    rbp,rsp
    2836:	sub    rsp,0x20
    283a:	mov    QWORD PTR [rsp],r12
    283e:	mov    QWORD PTR [rsp+0x8],r13
    2843:	mov    QWORD PTR [rsp+0x10],r14
    2848:	mov    r12,rdi
    284b:	mov    r14,rsi
    284e:	mov    rsi,rdx
    2851:	mov    rdi,r12
    2854:	call   2859 <botlish_fn_35+0x27>
			2855: R_X86_64_PLT32	rt_hash-0x4
    2859:	test   rax,rax
    285c:	mov    r13,rax
    285f:	je     2890 <botlish_fn_35+0x5e>
    2865:	mov    rsi,r14
    2868:	mov    rdi,r12
    286b:	call   2870 <botlish_fn_35+0x3e>
			286c: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2870:	test   rax,rax
    2873:	mov    rdx,rax
    2876:	je     2890 <botlish_fn_35+0x5e>
    287c:	mov    rsi,r13
    287f:	mov    rdi,r12
    2882:	call   2887 <botlish_fn_35+0x55>
			2883: R_X86_64_PLT32	rt_int_mod-0x4
    2887:	test   rax,rax
    288a:	jne    28aa <botlish_fn_35+0x78>
    2890:	xor    rax,rax
    2893:	mov    r12,QWORD PTR [rsp]
    2897:	mov    r13,QWORD PTR [rsp+0x8]
    289c:	mov    r14,QWORD PTR [rsp+0x10]
    28a1:	add    rsp,0x20
    28a5:	mov    rsp,rbp
    28a8:	pop    rbp
    28a9:	ret
    28aa:	mov    r12,QWORD PTR [rsp]
    28ae:	mov    r13,QWORD PTR [rsp+0x8]
    28b3:	mov    r14,QWORD PTR [rsp+0x10]
    28b8:	add    rsp,0x20
    28bc:	mov    rsp,rbp
    28bf:	pop    rbp
    28c0:	ret

00000000000028c1 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    28c1:	push   rbp
    28c2:	mov    rbp,rsp
    28c5:	mov    rsi,QWORD PTR [rdx]
    28c8:	mov    rdx,QWORD PTR [rdx+0x8]
    28cc:	call   28d1 <botlish_entry_35+0x10>
			28cd: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    28d1:	mov    rsp,rbp
    28d4:	pop    rbp
    28d5:	ret

00000000000028d6 <botlish_fn_36: ht_probe_next<mutarray, int>>:
    28d6:	push   rbp
    28d7:	mov    rbp,rsp
    28da:	sub    rsp,0x40
    28de:	mov    QWORD PTR [rsp+0x20],rbx
    28e3:	mov    QWORD PTR [rsp+0x28],r12
    28e8:	mov    QWORD PTR [rsp+0x30],r13
    28ed:	mov    r13,rdi
    28f0:	mov    QWORD PTR [rsp],rsi
    28f4:	mov    rbx,rsi
    28f7:	mov    QWORD PTR [rsp+0x8],rdx
    28fc:	mov    QWORD PTR [rsp+0x10],0x3
    2905:	test   rdx,0x1
    290c:	jne    291a <botlish_fn_36+0x44>
    2912:	mov    rsi,rdx
    2915:	jmp    293a <botlish_fn_36+0x64>
    291a:	mov    rsi,rdx
    291d:	add    rsi,0x2
    2921:	mov    r12,rsi
    2924:	mov    rsi,rdx
    2927:	seto   al
    292a:	test   al,al
    292c:	jne    293a <botlish_fn_36+0x64>
    2932:	mov    rsi,rbx
    2935:	jmp    294d <botlish_fn_36+0x77>
    293a:	mov    edx,0x3
    293f:	mov    rdi,r13
    2942:	call   2947 <botlish_fn_36+0x71>
			2943: R_X86_64_PLT32	rt_int_add-0x4
    2947:	mov    rsi,rbx
    294a:	mov    r12,rax
    294d:	mov    rdi,r13
    2950:	call   2955 <botlish_fn_36+0x7f>
			2951: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2955:	test   rax,rax
    2958:	mov    rdx,rax
    295b:	je     2975 <botlish_fn_36+0x9f>
    2961:	mov    rsi,r12
    2964:	mov    rdi,r13
    2967:	call   296c <botlish_fn_36+0x96>
			2968: R_X86_64_PLT32	rt_int_mod-0x4
    296c:	test   rax,rax
    296f:	jne    2990 <botlish_fn_36+0xba>
    2975:	xor    rax,rax
    2978:	mov    rbx,QWORD PTR [rsp+0x20]
    297d:	mov    r12,QWORD PTR [rsp+0x28]
    2982:	mov    r13,QWORD PTR [rsp+0x30]
    2987:	add    rsp,0x40
    298b:	mov    rsp,rbp
    298e:	pop    rbp
    298f:	ret
    2990:	mov    rbx,QWORD PTR [rsp+0x20]
    2995:	mov    r12,QWORD PTR [rsp+0x28]
    299a:	mov    r13,QWORD PTR [rsp+0x30]
    299f:	add    rsp,0x40
    29a3:	mov    rsp,rbp
    29a6:	pop    rbp
    29a7:	ret

00000000000029a8 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    29a8:	push   rbp
    29a9:	mov    rbp,rsp
    29ac:	mov    rsi,QWORD PTR [rdx]
    29af:	mov    rdx,QWORD PTR [rdx+0x8]
    29b3:	call   29b8 <botlish_entry_36+0x10>
			29b4: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    29b8:	mov    rsp,rbp
    29bb:	pop    rbp
    29bc:	ret
    29bd:	add    BYTE PTR [rax],al
	...

00000000000029c0 <botlish_fn_37: ht_find_get<mutarray, str, int>>:
    29c0:	push   rbp
    29c1:	mov    rbp,rsp
    29c4:	sub    rsp,0x50
    29c8:	mov    QWORD PTR [rsp+0x20],rbx
    29cd:	mov    QWORD PTR [rsp+0x28],r12
    29d2:	mov    QWORD PTR [rsp+0x30],r13
    29d7:	mov    QWORD PTR [rsp+0x38],r14
    29dc:	mov    QWORD PTR [rsp+0x40],r15
    29e1:	mov    r14,rdi
    29e4:	mov    QWORD PTR [rsp],rsi
    29e8:	mov    QWORD PTR [rsp+0x8],rdx
    29ed:	mov    r13,rdx
    29f0:	mov    QWORD PTR [rsp+0x10],rcx
    29f5:	mov    r12,rsi
    29f8:	mov    r15,rcx
    29fb:	mov    rsi,r12
    29fe:	mov    rdi,r14
    2a01:	call   2a06 <botlish_fn_37+0x46>
			2a02: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2a06:	test   rax,rax
    2a09:	je     2c08 <botlish_fn_37+0x248>
    2a0f:	xor    ecx,ecx
    2a11:	test   rax,0x7
    2a17:	je     2a25 <botlish_fn_37+0x65>
    2a1d:	mov    rsi,rax
    2a20:	jmp    2a33 <botlish_fn_37+0x73>
    2a25:	movzx  rcx,BYTE PTR [rax]
    2a29:	mov    rsi,rax
    2a2c:	rex cmp cl,0x8
    2a30:	sete   cl
    2a33:	test   cl,cl
    2a35:	jne    2a55 <botlish_fn_37+0x95>
    2a3b:	mov    rdi,r14
    2a3e:	mov    rdx,QWORD PTR [rdi+0x10]
    2a42:	mov    rcx,QWORD PTR [rdx+0x30]
    2a46:	mov    edx,0x8
    2a4b:	call   2a50 <botlish_fn_37+0x90>
			2a4c: R_X86_64_PLT32	rt_type_error-0x4
    2a50:	jmp    2c08 <botlish_fn_37+0x248>
    2a55:	mov    rdx,r15
    2a58:	mov    rdi,r14
    2a5b:	call   2a60 <botlish_fn_37+0xa0>
			2a5c: R_X86_64_PLT32	rt_mutarray_get-0x4
    2a60:	mov    rcx,rax
    2a63:	mov    QWORD PTR [rsp+0x18],rax
    2a68:	test   rax,rcx
    2a6b:	je     2c08 <botlish_fn_37+0x248>
    2a71:	mov    rax,QWORD PTR [rsp+0x18]
    2a76:	test   rax,0x1
    2a7c:	jne    2aa7 <botlish_fn_37+0xe7>
    2a82:	mov    edx,0x1
    2a87:	mov    rsi,QWORD PTR [rsp+0x18]
    2a8c:	mov    rdi,r14
    2a8f:	call   2a94 <botlish_fn_37+0xd4>
			2a90: R_X86_64_PLT32	rt_value_eq-0x4
    2a94:	test   rax,rax
    2a97:	je     2c08 <botlish_fn_37+0x248>
    2a9d:	mov    rcx,QWORD PTR [rsp+0x18]
    2aa2:	jmp    2abd <botlish_fn_37+0xfd>
    2aa7:	mov    eax,0x2
    2aac:	mov    rcx,QWORD PTR [rsp+0x18]
    2ab1:	cmp    rcx,0x1
    2ab5:	cmove  rax,QWORD PTR [rip+0x1db]        # 2c98 <botlish_fn_37+0x2d8>
    2abd:	mov    ebx,0x6
    2ac2:	cmp    rax,0x6
    2ac6:	je     2c68 <botlish_fn_37+0x2a8>
    2acc:	test   rcx,0x1
    2ad3:	mov    QWORD PTR [rsp+0x18],rcx
    2ad8:	jne    2afe <botlish_fn_37+0x13e>
    2ade:	mov    edx,0x3
    2ae3:	mov    rsi,QWORD PTR [rsp+0x18]
    2ae8:	mov    rdi,r14
    2aeb:	call   2af0 <botlish_fn_37+0x130>
			2aec: R_X86_64_PLT32	rt_value_eq-0x4
    2af0:	test   rax,rax
    2af3:	je     2c08 <botlish_fn_37+0x248>
    2af9:	jmp    2b14 <botlish_fn_37+0x154>
    2afe:	mov    rsi,QWORD PTR [rsp+0x18]
    2b03:	mov    eax,0x2
    2b08:	cmp    rsi,0x3
    2b0c:	cmove  rax,QWORD PTR [rip+0x184]        # 2c98 <botlish_fn_37+0x2d8>
    2b14:	cmp    rax,0x6
    2b18:	je     2b28 <botlish_fn_37+0x168>
    2b1e:	mov    ebx,0x2
    2b23:	jmp    2be7 <botlish_fn_37+0x227>
    2b28:	mov    rsi,r12
    2b2b:	mov    rdi,r14
    2b2e:	call   2b33 <botlish_fn_37+0x173>
			2b2f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2b33:	test   rax,rax
    2b36:	je     2c08 <botlish_fn_37+0x248>
    2b3c:	xor    r10d,r10d
    2b3f:	test   rax,0x7
    2b45:	je     2b53 <botlish_fn_37+0x193>
    2b4b:	mov    rsi,rax
    2b4e:	jmp    2b62 <botlish_fn_37+0x1a2>
    2b53:	movzx  rcx,BYTE PTR [rax]
    2b57:	mov    rsi,rax
    2b5a:	rex cmp cl,0x8
    2b5e:	sete   r10b
    2b62:	test   r10b,r10b
    2b65:	jne    2b85 <botlish_fn_37+0x1c5>
    2b6b:	mov    rdi,r14
    2b6e:	mov    rax,QWORD PTR [rdi+0x10]
    2b72:	mov    rcx,QWORD PTR [rax+0x30]
    2b76:	mov    edx,0x8
    2b7b:	call   2b80 <botlish_fn_37+0x1c0>
			2b7c: R_X86_64_PLT32	rt_type_error-0x4
    2b80:	jmp    2c08 <botlish_fn_37+0x248>
    2b85:	mov    rdx,r15
    2b88:	mov    rdi,r14
    2b8b:	call   2b90 <botlish_fn_37+0x1d0>
			2b8c: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b90:	test   rax,rax
    2b93:	je     2c08 <botlish_fn_37+0x248>
    2b99:	mov    rcx,rax
    2b9c:	and    rcx,r13
    2b9f:	mov    rsi,rax
    2ba2:	test   rcx,0x1
    2ba9:	jne    2bc8 <botlish_fn_37+0x208>
    2baf:	mov    rdx,r13
    2bb2:	mov    rdi,r14
    2bb5:	call   2bba <botlish_fn_37+0x1fa>
			2bb6: R_X86_64_PLT32	rt_value_eq-0x4
    2bba:	test   rax,rax
    2bbd:	je     2c08 <botlish_fn_37+0x248>
    2bc3:	jmp    2bd8 <botlish_fn_37+0x218>
    2bc8:	mov    eax,0x2
    2bcd:	cmp    rsi,r13
    2bd0:	cmove  rax,QWORD PTR [rip+0xc0]        # 2c98 <botlish_fn_37+0x2d8>
    2bd8:	cmp    rax,0x6
    2bdc:	je     2be7 <botlish_fn_37+0x227>
    2be2:	mov    ebx,0x2
    2be7:	cmp    rbx,0x6
    2beb:	je     2c43 <botlish_fn_37+0x283>
    2bf1:	mov    rdx,r15
    2bf4:	mov    rsi,r12
    2bf7:	mov    rdi,r14
    2bfa:	call   2bff <botlish_fn_37+0x23f>
			2bfb: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2bff:	test   rax,rax
    2c02:	jne    2c2d <botlish_fn_37+0x26d>
    2c08:	xor    rax,rax
    2c0b:	mov    rbx,QWORD PTR [rsp+0x20]
    2c10:	mov    r12,QWORD PTR [rsp+0x28]
    2c15:	mov    r13,QWORD PTR [rsp+0x30]
    2c1a:	mov    r14,QWORD PTR [rsp+0x38]
    2c1f:	mov    r15,QWORD PTR [rsp+0x40]
    2c24:	add    rsp,0x50
    2c28:	mov    rsp,rbp
    2c2b:	pop    rbp
    2c2c:	ret
    2c2d:	mov    QWORD PTR [rsp],r12
    2c31:	mov    QWORD PTR [rsp+0x8],r13
    2c36:	mov    QWORD PTR [rsp+0x10],rax
    2c3b:	mov    r15,rax
    2c3e:	jmp    29fb <botlish_fn_37+0x3b>
    2c43:	mov    rax,r15
    2c46:	mov    rbx,QWORD PTR [rsp+0x20]
    2c4b:	mov    r12,QWORD PTR [rsp+0x28]
    2c50:	mov    r13,QWORD PTR [rsp+0x30]
    2c55:	mov    r14,QWORD PTR [rsp+0x38]
    2c5a:	mov    r15,QWORD PTR [rsp+0x40]
    2c5f:	add    rsp,0x50
    2c63:	mov    rsp,rbp
    2c66:	pop    rbp
    2c67:	ret
    2c68:	mov    rax,0xffffffffffffffff
    2c6f:	mov    rbx,QWORD PTR [rsp+0x20]
    2c74:	mov    r12,QWORD PTR [rsp+0x28]
    2c79:	mov    r13,QWORD PTR [rsp+0x30]
    2c7e:	mov    r14,QWORD PTR [rsp+0x38]
    2c83:	mov    r15,QWORD PTR [rsp+0x40]
    2c88:	add    rsp,0x50
    2c8c:	mov    rsp,rbp
    2c8f:	pop    rbp
    2c90:	ret
    2c91:	add    BYTE PTR [rax],al
    2c93:	add    BYTE PTR [rax],al
    2c95:	add    BYTE PTR [rax],al
    2c97:	add    BYTE PTR [rsi],al
    2c99:	add    BYTE PTR [rax],al
    2c9b:	add    BYTE PTR [rax],al
    2c9d:	add    BYTE PTR [rax],al
	...

0000000000002ca0 <botlish_entry_37: ht_find_get<mutarray, str, int>>:
    2ca0:	push   rbp
    2ca1:	mov    rbp,rsp
    2ca4:	mov    rsi,QWORD PTR [rdx]
    2ca7:	mov    r8,QWORD PTR [rdx+0x8]
    2cab:	mov    rcx,QWORD PTR [rdx+0x10]
    2caf:	mov    rdx,r8
    2cb2:	call   2cb7 <botlish_entry_37+0x17>
			2cb3: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    2cb7:	mov    rsp,rbp
    2cba:	pop    rbp
    2cbb:	ret
    2cbc:	add    BYTE PTR [rax],al
	...

0000000000002cc0 <botlish_fn_38: ht_find_insert<mutarray, str, int, int>>:
    2cc0:	push   rbp
    2cc1:	mov    rbp,rsp
    2cc4:	sub    rsp,0x60
    2cc8:	mov    QWORD PTR [rsp+0x30],rbx
    2ccd:	mov    QWORD PTR [rsp+0x38],r12
    2cd2:	mov    QWORD PTR [rsp+0x40],r13
    2cd7:	mov    QWORD PTR [rsp+0x48],r14
    2cdc:	mov    QWORD PTR [rsp+0x50],r15
    2ce1:	mov    r15,rdi
    2ce4:	mov    QWORD PTR [rsp],rsi
    2ce8:	mov    QWORD PTR [rsp+0x8],rdx
    2ced:	mov    r13,rdx
    2cf0:	mov    QWORD PTR [rsp+0x10],rcx
    2cf5:	mov    QWORD PTR [rsp+0x18],r8
    2cfa:	mov    rbx,rsi
    2cfd:	mov    QWORD PTR [rsp+0x20],rcx
    2d02:	mov    QWORD PTR [rsp+0x28],r8
    2d07:	mov    rsi,rbx
    2d0a:	mov    rdi,r15
    2d0d:	call   2d12 <botlish_fn_38+0x52>
			2d0e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2d12:	test   rax,rax
    2d15:	je     300d <botlish_fn_38+0x34d>
    2d1b:	xor    ecx,ecx
    2d1d:	test   rax,0x7
    2d23:	je     2d31 <botlish_fn_38+0x71>
    2d29:	mov    rsi,rax
    2d2c:	jmp    2d3f <botlish_fn_38+0x7f>
    2d31:	movzx  rcx,BYTE PTR [rax]
    2d35:	mov    rsi,rax
    2d38:	rex cmp cl,0x8
    2d3c:	sete   cl
    2d3f:	test   cl,cl
    2d41:	jne    2d61 <botlish_fn_38+0xa1>
    2d47:	mov    rdi,r15
    2d4a:	mov    rax,QWORD PTR [rdi+0x10]
    2d4e:	mov    rcx,QWORD PTR [rax+0x30]
    2d52:	mov    edx,0x8
    2d57:	call   2d5c <botlish_fn_38+0x9c>
			2d58: R_X86_64_PLT32	rt_type_error-0x4
    2d5c:	jmp    300d <botlish_fn_38+0x34d>
    2d61:	mov    rdx,QWORD PTR [rsp+0x20]
    2d66:	mov    rdi,r15
    2d69:	call   2d6e <botlish_fn_38+0xae>
			2d6a: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d6e:	mov    rsi,rax
    2d71:	mov    r14,rax
    2d74:	test   rax,rsi
    2d77:	je     300d <botlish_fn_38+0x34d>
    2d7d:	mov    rax,r14
    2d80:	test   rax,0x1
    2d86:	jne    2daa <botlish_fn_38+0xea>
    2d8c:	mov    edx,0x1
    2d91:	mov    rsi,r14
    2d94:	mov    rdi,r15
    2d97:	call   2d9c <botlish_fn_38+0xdc>
			2d98: R_X86_64_PLT32	rt_value_eq-0x4
    2d9c:	test   rax,rax
    2d9f:	je     300d <botlish_fn_38+0x34d>
    2da5:	jmp    2dbe <botlish_fn_38+0xfe>
    2daa:	mov    eax,0x2
    2daf:	mov    rcx,r14
    2db2:	cmp    rcx,0x1
    2db6:	cmove  rax,QWORD PTR [rip+0x372]        # 3130 <botlish_fn_38+0x470>
    2dbe:	mov    r12d,0x6
    2dc4:	cmp    rax,0x6
    2dc8:	je     3085 <botlish_fn_38+0x3c5>
    2dce:	mov    rax,r14
    2dd1:	test   rax,0x1
    2dd7:	jne    2dfb <botlish_fn_38+0x13b>
    2ddd:	mov    edx,0x3
    2de2:	mov    rsi,r14
    2de5:	mov    rdi,r15
    2de8:	call   2ded <botlish_fn_38+0x12d>
			2de9: R_X86_64_PLT32	rt_value_eq-0x4
    2ded:	test   rax,rax
    2df0:	je     300d <botlish_fn_38+0x34d>
    2df6:	jmp    2e0f <botlish_fn_38+0x14f>
    2dfb:	mov    eax,0x2
    2e00:	mov    rcx,r14
    2e03:	cmp    rcx,0x3
    2e07:	cmove  rax,QWORD PTR [rip+0x321]        # 3130 <botlish_fn_38+0x470>
    2e0f:	cmp    rax,0x6
    2e13:	je     2e24 <botlish_fn_38+0x164>
    2e19:	mov    r11d,0x2
    2e1f:	jmp    2eee <botlish_fn_38+0x22e>
    2e24:	mov    rsi,rbx
    2e27:	mov    rdi,r15
    2e2a:	call   2e2f <botlish_fn_38+0x16f>
			2e2b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2e2f:	test   rax,rax
    2e32:	je     300d <botlish_fn_38+0x34d>
    2e38:	xor    ecx,ecx
    2e3a:	test   rax,0x7
    2e40:	je     2e4e <botlish_fn_38+0x18e>
    2e46:	mov    rsi,rax
    2e49:	jmp    2e5c <botlish_fn_38+0x19c>
    2e4e:	movzx  rcx,BYTE PTR [rax]
    2e52:	mov    rsi,rax
    2e55:	rex cmp cl,0x8
    2e59:	sete   cl
    2e5c:	test   cl,cl
    2e5e:	jne    2e7e <botlish_fn_38+0x1be>
    2e64:	mov    rdi,r15
    2e67:	mov    rcx,QWORD PTR [rdi+0x10]
    2e6b:	mov    rcx,QWORD PTR [rcx+0x30]
    2e6f:	mov    edx,0x8
    2e74:	call   2e79 <botlish_fn_38+0x1b9>
			2e75: R_X86_64_PLT32	rt_type_error-0x4
    2e79:	jmp    300d <botlish_fn_38+0x34d>
    2e7e:	mov    rdx,QWORD PTR [rsp+0x20]
    2e83:	mov    rdi,r15
    2e86:	call   2e8b <botlish_fn_38+0x1cb>
			2e87: R_X86_64_PLT32	rt_mutarray_get-0x4
    2e8b:	test   rax,rax
    2e8e:	je     300d <botlish_fn_38+0x34d>
    2e94:	mov    rsi,rax
    2e97:	and    rsi,r13
    2e9a:	test   rsi,0x1
    2ea1:	jne    2ec3 <botlish_fn_38+0x203>
    2ea7:	mov    rsi,rax
    2eaa:	mov    rdx,r13
    2ead:	mov    rdi,r15
    2eb0:	call   2eb5 <botlish_fn_38+0x1f5>
			2eb1: R_X86_64_PLT32	rt_value_eq-0x4
    2eb5:	test   rax,rax
    2eb8:	je     300d <botlish_fn_38+0x34d>
    2ebe:	jmp    2ed6 <botlish_fn_38+0x216>
    2ec3:	mov    rsi,rax
    2ec6:	mov    eax,0x2
    2ecb:	cmp    rsi,r13
    2ece:	cmove  rax,QWORD PTR [rip+0x25a]        # 3130 <botlish_fn_38+0x470>
    2ed6:	cmp    rax,0x6
    2eda:	je     2eeb <botlish_fn_38+0x22b>
    2ee0:	mov    r11d,0x2
    2ee6:	jmp    2eee <botlish_fn_38+0x22e>
    2eeb:	mov    r11,r12
    2eee:	cmp    r11,0x6
    2ef2:	je     305e <botlish_fn_38+0x39e>
    2ef8:	mov    rax,r14
    2efb:	test   rax,0x1
    2f01:	jne    2f25 <botlish_fn_38+0x265>
    2f07:	mov    edx,0x5
    2f0c:	mov    rsi,r14
    2f0f:	mov    rdi,r15
    2f12:	call   2f17 <botlish_fn_38+0x257>
			2f13: R_X86_64_PLT32	rt_value_eq-0x4
    2f17:	test   rax,rax
    2f1a:	je     300d <botlish_fn_38+0x34d>
    2f20:	jmp    2f39 <botlish_fn_38+0x279>
    2f25:	mov    rsi,r14
    2f28:	mov    eax,0x2
    2f2d:	cmp    rsi,0x5
    2f31:	cmove  rax,QWORD PTR [rip+0x1f7]        # 3130 <botlish_fn_38+0x470>
    2f39:	cmp    rax,0x6
    2f3d:	je     2f4e <botlish_fn_38+0x28e>
    2f43:	mov    r12d,0x2
    2f49:	jmp    2faf <botlish_fn_38+0x2ef>
    2f4e:	mov    r14,QWORD PTR [rsp+0x28]
    2f53:	test   r14,0x1
    2f5a:	jne    2f8a <botlish_fn_38+0x2ca>
    2f60:	mov    edx,0x1
    2f65:	mov    rsi,r14
    2f68:	mov    rdi,r15
    2f6b:	call   2f70 <botlish_fn_38+0x2b0>
			2f6c: R_X86_64_PLT32	rt_int_cmp-0x4
    2f70:	mov    ecx,0x2
    2f75:	test   rax,rax
    2f78:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 3130 <botlish_fn_38+0x470>
    2f80:	mov    QWORD PTR [rsp+0x28],r14
    2f85:	jmp    2f9f <botlish_fn_38+0x2df>
    2f8a:	mov    ecx,0x2
    2f8f:	test   r14,r14
    2f92:	mov    QWORD PTR [rsp+0x28],r14
    2f97:	cmovle rcx,QWORD PTR [rip+0x191]        # 3130 <botlish_fn_38+0x470>
    2f9f:	cmp    rcx,0x6
    2fa3:	je     2faf <botlish_fn_38+0x2ef>
    2fa9:	mov    r12d,0x2
    2faf:	cmp    r12,0x6
    2fb3:	je     2ff4 <botlish_fn_38+0x334>
    2fb9:	mov    rdx,QWORD PTR [rsp+0x20]
    2fbe:	mov    rsi,rbx
    2fc1:	mov    rdi,r15
    2fc4:	call   2fc9 <botlish_fn_38+0x309>
			2fc5: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2fc9:	test   rax,rax
    2fcc:	je     300d <botlish_fn_38+0x34d>
    2fd2:	mov    QWORD PTR [rsp],rbx
    2fd6:	mov    QWORD PTR [rsp+0x8],r13
    2fdb:	mov    QWORD PTR [rsp+0x10],rax
    2fe0:	mov    r11,QWORD PTR [rsp+0x28]
    2fe5:	mov    QWORD PTR [rsp+0x18],r11
    2fea:	mov    QWORD PTR [rsp+0x20],rax
    2fef:	jmp    2d07 <botlish_fn_38+0x47>
    2ff4:	mov    rdx,QWORD PTR [rsp+0x20]
    2ff9:	mov    rsi,rbx
    2ffc:	mov    rdi,r15
    2fff:	call   3004 <botlish_fn_38+0x344>
			3000: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    3004:	test   rax,rax
    3007:	jne    3032 <botlish_fn_38+0x372>
    300d:	xor    rax,rax
    3010:	mov    rbx,QWORD PTR [rsp+0x30]
    3015:	mov    r12,QWORD PTR [rsp+0x38]
    301a:	mov    r13,QWORD PTR [rsp+0x40]
    301f:	mov    r14,QWORD PTR [rsp+0x48]
    3024:	mov    r15,QWORD PTR [rsp+0x50]
    3029:	add    rsp,0x60
    302d:	mov    rsp,rbp
    3030:	pop    rbp
    3031:	ret
    3032:	mov    QWORD PTR [rsp],rbx
    3036:	mov    QWORD PTR [rsp+0x8],r13
    303b:	mov    QWORD PTR [rsp+0x10],rax
    3040:	mov    rdx,QWORD PTR [rsp+0x20]
    3045:	mov    QWORD PTR [rsp+0x18],rdx
    304a:	mov    rcx,QWORD PTR [rsp+0x20]
    304f:	mov    QWORD PTR [rsp+0x28],rcx
    3054:	mov    QWORD PTR [rsp+0x20],rax
    3059:	jmp    2d07 <botlish_fn_38+0x47>
    305e:	mov    rax,QWORD PTR [rsp+0x20]
    3063:	mov    rbx,QWORD PTR [rsp+0x30]
    3068:	mov    r12,QWORD PTR [rsp+0x38]
    306d:	mov    r13,QWORD PTR [rsp+0x40]
    3072:	mov    r14,QWORD PTR [rsp+0x48]
    3077:	mov    r15,QWORD PTR [rsp+0x50]
    307c:	add    rsp,0x60
    3080:	mov    rsp,rbp
    3083:	pop    rbp
    3084:	ret
    3085:	mov    rax,QWORD PTR [rsp+0x28]
    308a:	test   rax,0x1
    3090:	jne    30bd <botlish_fn_38+0x3fd>
    3096:	mov    edx,0x1
    309b:	mov    rdi,r15
    309e:	mov    rsi,QWORD PTR [rsp+0x28]
    30a3:	call   30a8 <botlish_fn_38+0x3e8>
			30a4: R_X86_64_PLT32	rt_int_cmp-0x4
    30a8:	mov    ecx,0x2
    30ad:	test   rax,rax
    30b0:	cmovge rcx,QWORD PTR [rip+0x78]        # 3130 <botlish_fn_38+0x470>
    30b8:	jmp    30d7 <botlish_fn_38+0x417>
    30bd:	mov    ecx,0x2
    30c2:	mov    rax,QWORD PTR [rsp+0x28]
    30c7:	mov    rdx,QWORD PTR [rsp+0x28]
    30cc:	test   rax,rdx
    30cf:	cmovg  rcx,QWORD PTR [rip+0x59]        # 3130 <botlish_fn_38+0x470>
    30d7:	cmp    rcx,0x6
    30db:	je     3108 <botlish_fn_38+0x448>
    30e1:	mov    rax,QWORD PTR [rsp+0x20]
    30e6:	mov    rbx,QWORD PTR [rsp+0x30]
    30eb:	mov    r12,QWORD PTR [rsp+0x38]
    30f0:	mov    r13,QWORD PTR [rsp+0x40]
    30f5:	mov    r14,QWORD PTR [rsp+0x48]
    30fa:	mov    r15,QWORD PTR [rsp+0x50]
    30ff:	add    rsp,0x60
    3103:	mov    rsp,rbp
    3106:	pop    rbp
    3107:	ret
    3108:	mov    rax,QWORD PTR [rsp+0x28]
    310d:	mov    rbx,QWORD PTR [rsp+0x30]
    3112:	mov    r12,QWORD PTR [rsp+0x38]
    3117:	mov    r13,QWORD PTR [rsp+0x40]
    311c:	mov    r14,QWORD PTR [rsp+0x48]
    3121:	mov    r15,QWORD PTR [rsp+0x50]
    3126:	add    rsp,0x60
    312a:	mov    rsp,rbp
    312d:	pop    rbp
    312e:	ret
    312f:	add    BYTE PTR [rsi],al
    3131:	add    BYTE PTR [rax],al
    3133:	add    BYTE PTR [rax],al
    3135:	add    BYTE PTR [rax],al
	...

0000000000003138 <botlish_entry_38: ht_find_insert<mutarray, str, int, int>>:
    3138:	push   rbp
    3139:	mov    rbp,rsp
    313c:	mov    rsi,QWORD PTR [rdx]
    313f:	mov    r9,QWORD PTR [rdx+0x8]
    3143:	mov    rcx,QWORD PTR [rdx+0x10]
    3147:	mov    r8,QWORD PTR [rdx+0x18]
    314b:	mov    rdx,r9
    314e:	call   3153 <botlish_entry_38+0x1b>
			314f: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    3153:	mov    rsp,rbp
    3156:	pop    rbp
    3157:	ret

0000000000003158 <botlish_fn_39: ht_get<mutarray, str>>:
    3158:	push   rbp
    3159:	mov    rbp,rsp
    315c:	sub    rsp,0x40
    3160:	mov    QWORD PTR [rsp+0x20],rbx
    3165:	mov    QWORD PTR [rsp+0x28],r12
    316a:	mov    QWORD PTR [rsp+0x30],r13
    316f:	mov    rbx,rdi
    3172:	mov    QWORD PTR [rsp],rsi
    3176:	mov    r13,rsi
    3179:	mov    QWORD PTR [rsp+0x8],rdx
    317e:	mov    r12,rdx
    3181:	mov    rdx,r12
    3184:	mov    rsi,r13
    3187:	mov    rdi,rbx
    318a:	call   318f <botlish_fn_39+0x37>
			318b: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    318f:	test   rax,rax
    3192:	je     327c <botlish_fn_39+0x124>
    3198:	mov    QWORD PTR [rsp+0x10],rax
    319d:	mov    rcx,rax
    31a0:	mov    rdx,r12
    31a3:	mov    rsi,r13
    31a6:	mov    rdi,rbx
    31a9:	call   31ae <botlish_fn_39+0x56>
			31aa: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    31ae:	mov    rcx,rax
    31b1:	mov    r12,rax
    31b4:	test   rax,rcx
    31b7:	je     327c <botlish_fn_39+0x124>
    31bd:	mov    rax,r12
    31c0:	test   rax,0x1
    31c6:	jne    31f1 <botlish_fn_39+0x99>
    31cc:	mov    edx,0x1
    31d1:	mov    rsi,r12
    31d4:	mov    rdi,rbx
    31d7:	call   31dc <botlish_fn_39+0x84>
			31d8: R_X86_64_PLT32	rt_int_cmp-0x4
    31dc:	mov    ecx,0x2
    31e1:	test   rax,rax
    31e4:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 32d0 <botlish_fn_39+0x178>
    31ec:	jmp    3204 <botlish_fn_39+0xac>
    31f1:	mov    ecx,0x2
    31f6:	mov    rax,r12
    31f9:	test   rax,rax
    31fc:	cmovle rcx,QWORD PTR [rip+0xcc]        # 32d0 <botlish_fn_39+0x178>
    3204:	cmp    rcx,0x6
    3208:	je     32af <botlish_fn_39+0x157>
    320e:	mov    rsi,r13
    3211:	mov    rdi,rbx
    3214:	call   3219 <botlish_fn_39+0xc1>
			3215: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3219:	test   rax,rax
    321c:	je     327c <botlish_fn_39+0x124>
    3222:	xor    ecx,ecx
    3224:	test   rax,0x7
    322a:	je     3238 <botlish_fn_39+0xe0>
    3230:	mov    rsi,rax
    3233:	jmp    3246 <botlish_fn_39+0xee>
    3238:	movzx  rcx,BYTE PTR [rax]
    323c:	mov    rsi,rax
    323f:	rex cmp cl,0x8
    3243:	sete   cl
    3246:	test   cl,cl
    3248:	jne    3268 <botlish_fn_39+0x110>
    324e:	mov    rdi,rbx
    3251:	mov    rax,QWORD PTR [rdi+0x10]
    3255:	mov    rcx,QWORD PTR [rax+0x30]
    3259:	mov    edx,0x8
    325e:	call   3263 <botlish_fn_39+0x10b>
			325f: R_X86_64_PLT32	rt_type_error-0x4
    3263:	jmp    327c <botlish_fn_39+0x124>
    3268:	mov    rdx,r12
    326b:	mov    rdi,rbx
    326e:	call   3273 <botlish_fn_39+0x11b>
			326f: R_X86_64_PLT32	rt_mutarray_get-0x4
    3273:	test   rax,rax
    3276:	jne    3297 <botlish_fn_39+0x13f>
    327c:	xor    rax,rax
    327f:	mov    rbx,QWORD PTR [rsp+0x20]
    3284:	mov    r12,QWORD PTR [rsp+0x28]
    3289:	mov    r13,QWORD PTR [rsp+0x30]
    328e:	add    rsp,0x40
    3292:	mov    rsp,rbp
    3295:	pop    rbp
    3296:	ret
    3297:	mov    rbx,QWORD PTR [rsp+0x20]
    329c:	mov    r12,QWORD PTR [rsp+0x28]
    32a1:	mov    r13,QWORD PTR [rsp+0x30]
    32a6:	add    rsp,0x40
    32aa:	mov    rsp,rbp
    32ad:	pop    rbp
    32ae:	ret
    32af:	mov    eax,0xa
    32b4:	mov    rbx,QWORD PTR [rsp+0x20]
    32b9:	mov    r12,QWORD PTR [rsp+0x28]
    32be:	mov    r13,QWORD PTR [rsp+0x30]
    32c3:	add    rsp,0x40
    32c7:	mov    rsp,rbp
    32ca:	pop    rbp
    32cb:	ret
    32cc:	add    BYTE PTR [rax],al
    32ce:	add    BYTE PTR [rax],al
    32d0:	(bad)
    32d1:	add    BYTE PTR [rax],al
    32d3:	add    BYTE PTR [rax],al
    32d5:	add    BYTE PTR [rax],al
	...

00000000000032d8 <botlish_entry_39: ht_get<mutarray, str>>:
    32d8:	push   rbp
    32d9:	mov    rbp,rsp
    32dc:	mov    rsi,QWORD PTR [rdx]
    32df:	mov    rdx,QWORD PTR [rdx+0x8]
    32e3:	call   32e8 <botlish_entry_39+0x10>
			32e4: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    32e8:	mov    rsp,rbp
    32eb:	pop    rbp
    32ec:	ret
    32ed:	add    BYTE PTR [rax],al
	...

00000000000032f0 <botlish_fn_40: ht_rehash_probe<mutarray, int, int>>:
    32f0:	push   rbp
    32f1:	mov    rbp,rsp
    32f4:	sub    rsp,0x40
    32f8:	mov    QWORD PTR [rsp+0x20],rbx
    32fd:	mov    QWORD PTR [rsp+0x28],r12
    3302:	mov    QWORD PTR [rsp+0x30],r13
    3307:	mov    QWORD PTR [rsp+0x38],r14
    330c:	mov    r13,rdi
    330f:	mov    QWORD PTR [rsp],rsi
    3313:	mov    QWORD PTR [rsp+0x8],rdx
    3318:	mov    QWORD PTR [rsp+0x10],rcx
    331d:	mov    r12,rcx
    3320:	mov    rbx,rsi
    3323:	mov    r14,rdx
    3326:	mov    rdx,r14
    3329:	mov    rsi,rbx
    332c:	mov    rdi,r13
    332f:	call   3334 <botlish_fn_40+0x44>
			3330: R_X86_64_PLT32	rt_mutarray_get-0x4
    3334:	test   rax,rax
    3337:	je     33d4 <botlish_fn_40+0xe4>
    333d:	test   rax,0x1
    3343:	mov    rsi,rax
    3346:	jne    3367 <botlish_fn_40+0x77>
    334c:	mov    edx,0x1
    3351:	mov    rdi,r13
    3354:	call   3359 <botlish_fn_40+0x69>
			3355: R_X86_64_PLT32	rt_value_eq-0x4
    3359:	test   rax,rax
    335c:	je     33d4 <botlish_fn_40+0xe4>
    3362:	jmp    3378 <botlish_fn_40+0x88>
    3367:	mov    eax,0x2
    336c:	cmp    rsi,0x1
    3370:	cmove  rax,QWORD PTR [rip+0xb8]        # 3430 <botlish_fn_40+0x140>
    3378:	cmp    rax,0x6
    337c:	je     340a <botlish_fn_40+0x11a>
    3382:	mov    QWORD PTR [rsp+0x18],0x3
    338b:	mov    rsi,r14
    338e:	test   rsi,0x1
    3395:	je     33ad <botlish_fn_40+0xbd>
    339b:	mov    rsi,r14
    339e:	add    rsi,0x2
    33a2:	seto   al
    33a5:	test   al,al
    33a7:	je     33c0 <botlish_fn_40+0xd0>
    33ad:	mov    edx,0x3
    33b2:	mov    rsi,r14
    33b5:	mov    rdi,r13
    33b8:	call   33bd <botlish_fn_40+0xcd>
			33b9: R_X86_64_PLT32	rt_int_add-0x4
    33bd:	mov    rsi,rax
    33c0:	mov    rdx,r12
    33c3:	mov    rdi,r13
    33c6:	call   33cb <botlish_fn_40+0xdb>
			33c7: R_X86_64_PLT32	rt_int_mod-0x4
    33cb:	test   rax,rax
    33ce:	jne    33f4 <botlish_fn_40+0x104>
    33d4:	xor    rax,rax
    33d7:	mov    rbx,QWORD PTR [rsp+0x20]
    33dc:	mov    r12,QWORD PTR [rsp+0x28]
    33e1:	mov    r13,QWORD PTR [rsp+0x30]
    33e6:	mov    r14,QWORD PTR [rsp+0x38]
    33eb:	add    rsp,0x40
    33ef:	mov    rsp,rbp
    33f2:	pop    rbp
    33f3:	ret
    33f4:	mov    QWORD PTR [rsp],rbx
    33f8:	mov    QWORD PTR [rsp+0x8],rax
    33fd:	mov    QWORD PTR [rsp+0x10],r12
    3402:	mov    r14,rax
    3405:	jmp    3326 <botlish_fn_40+0x36>
    340a:	mov    rax,r14
    340d:	mov    rbx,QWORD PTR [rsp+0x20]
    3412:	mov    r12,QWORD PTR [rsp+0x28]
    3417:	mov    r13,QWORD PTR [rsp+0x30]
    341c:	mov    r14,QWORD PTR [rsp+0x38]
    3421:	add    rsp,0x40
    3425:	mov    rsp,rbp
    3428:	pop    rbp
    3429:	ret
    342a:	add    BYTE PTR [rax],al
    342c:	add    BYTE PTR [rax],al
    342e:	add    BYTE PTR [rax],al
    3430:	(bad)
    3431:	add    BYTE PTR [rax],al
    3433:	add    BYTE PTR [rax],al
    3435:	add    BYTE PTR [rax],al
	...

0000000000003438 <botlish_entry_40: ht_rehash_probe<mutarray, int, int>>:
    3438:	push   rbp
    3439:	mov    rbp,rsp
    343c:	mov    rsi,QWORD PTR [rdx]
    343f:	mov    r8,QWORD PTR [rdx+0x8]
    3443:	mov    rcx,QWORD PTR [rdx+0x10]
    3447:	mov    rdx,r8
    344a:	call   344f <botlish_entry_40+0x17>
			344b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    344f:	mov    rsp,rbp
    3452:	pop    rbp
    3453:	ret

0000000000003454 <botlish_fn_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    3454:	push   rbp
    3455:	mov    rbp,rsp
    3458:	sub    rsp,0x80
    345f:	mov    QWORD PTR [rsp+0x50],rbx
    3464:	mov    QWORD PTR [rsp+0x58],r12
    3469:	mov    QWORD PTR [rsp+0x60],r13
    346e:	mov    QWORD PTR [rsp+0x68],r14
    3473:	mov    QWORD PTR [rsp+0x70],r15
    3478:	mov    r12,rdi
    347b:	mov    rdi,QWORD PTR [rbp+0x10]
    347f:	mov    QWORD PTR [rsp],rsi
    3483:	mov    QWORD PTR [rsp+0x38],rsi
    3488:	mov    QWORD PTR [rsp+0x8],rdx
    348d:	mov    r15,rdx
    3490:	mov    QWORD PTR [rsp+0x10],rcx
    3495:	mov    rbx,rcx
    3498:	mov    QWORD PTR [rsp+0x18],r8
    349d:	mov    QWORD PTR [rsp+0x40],r8
    34a2:	mov    QWORD PTR [rsp+0x20],r9
    34a7:	mov    r14,r9
    34aa:	mov    QWORD PTR [rsp+0x28],rdi
    34af:	mov    r13,rdi
    34b2:	mov    rsi,r14
    34b5:	mov    rdi,r12
    34b8:	call   34bd <botlish_fn_41+0x69>
			34b9: R_X86_64_PLT32	rt_hash-0x4
    34bd:	test   rax,rax
    34c0:	mov    rsi,rax
    34c3:	je     3562 <botlish_fn_41+0x10e>
    34c9:	mov    rdx,QWORD PTR [rsp+0x40]
    34ce:	mov    rdi,r12
    34d1:	call   34d6 <botlish_fn_41+0x82>
			34d2: R_X86_64_PLT32	rt_int_mod-0x4
    34d6:	test   rax,rax
    34d9:	je     3562 <botlish_fn_41+0x10e>
    34df:	mov    QWORD PTR [rsp+0x30],rax
    34e4:	mov    rcx,QWORD PTR [rsp+0x40]
    34e9:	mov    rdx,rax
    34ec:	mov    rsi,QWORD PTR [rsp+0x38]
    34f1:	mov    rdi,r12
    34f4:	call   34f9 <botlish_fn_41+0xa5>
			34f5: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    34f9:	mov    rcx,rax
    34fc:	mov    QWORD PTR [rsp+0x40],rax
    3501:	test   rax,rcx
    3504:	je     3562 <botlish_fn_41+0x10e>
    350a:	mov    ecx,0x3
    350f:	mov    rsi,QWORD PTR [rsp+0x38]
    3514:	mov    rdx,QWORD PTR [rsp+0x40]
    3519:	mov    rdi,r12
    351c:	call   3521 <botlish_fn_41+0xcd>
			351d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3521:	test   rax,rax
    3524:	je     3562 <botlish_fn_41+0x10e>
    352a:	mov    rcx,r14
    352d:	mov    rsi,r15
    3530:	mov    rdx,QWORD PTR [rsp+0x40]
    3535:	mov    rdi,r12
    3538:	call   353d <botlish_fn_41+0xe9>
			3539: R_X86_64_PLT32	rt_mutarray_set-0x4
    353d:	test   rax,rax
    3540:	je     3562 <botlish_fn_41+0x10e>
    3546:	mov    rcx,r13
    3549:	mov    rdx,QWORD PTR [rsp+0x40]
    354e:	mov    rsi,rbx
    3551:	mov    rdi,r12
    3554:	call   3559 <botlish_fn_41+0x105>
			3555: R_X86_64_PLT32	rt_mutarray_set-0x4
    3559:	test   rax,rax
    355c:	jne    358a <botlish_fn_41+0x136>
    3562:	xor    rax,rax
    3565:	mov    rbx,QWORD PTR [rsp+0x50]
    356a:	mov    r12,QWORD PTR [rsp+0x58]
    356f:	mov    r13,QWORD PTR [rsp+0x60]
    3574:	mov    r14,QWORD PTR [rsp+0x68]
    3579:	mov    r15,QWORD PTR [rsp+0x70]
    357e:	add    rsp,0x80
    3585:	mov    rsp,rbp
    3588:	pop    rbp
    3589:	ret
    358a:	mov    eax,0xa
    358f:	mov    rbx,QWORD PTR [rsp+0x50]
    3594:	mov    r12,QWORD PTR [rsp+0x58]
    3599:	mov    r13,QWORD PTR [rsp+0x60]
    359e:	mov    r14,QWORD PTR [rsp+0x68]
    35a3:	mov    r15,QWORD PTR [rsp+0x70]
    35a8:	add    rsp,0x80
    35af:	mov    rsp,rbp
    35b2:	pop    rbp
    35b3:	ret

00000000000035b4 <botlish_entry_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    35b4:	push   rbp
    35b5:	mov    rbp,rsp
    35b8:	sub    rsp,0x10
    35bc:	mov    rsi,QWORD PTR [rdx]
    35bf:	mov    r10,QWORD PTR [rdx+0x8]
    35c3:	mov    rcx,QWORD PTR [rdx+0x10]
    35c7:	mov    r8,QWORD PTR [rdx+0x18]
    35cb:	mov    r9,QWORD PTR [rdx+0x20]
    35cf:	mov    r11,QWORD PTR [rdx+0x28]
    35d3:	mov    QWORD PTR [rsp],r11
    35d7:	mov    rdx,r10
    35da:	call   35df <botlish_entry_41+0x2b>
			35db: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    35df:	add    rsp,0x10
    35e3:	mov    rsp,rbp
    35e6:	pop    rbp
    35e7:	ret

00000000000035e8 <botlish_fn_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    35e8:	push   rbp
    35e9:	mov    rbp,rsp
    35ec:	sub    rsp,0xc0
    35f3:	mov    QWORD PTR [rsp+0x90],rbx
    35fb:	mov    QWORD PTR [rsp+0x98],r12
    3603:	mov    QWORD PTR [rsp+0xa0],r13
    360b:	mov    QWORD PTR [rsp+0xa8],r14
    3613:	mov    QWORD PTR [rsp+0xb0],r15
    361b:	mov    QWORD PTR [rsp+0x58],rdi
    3620:	mov    r15,QWORD PTR [rbp+0x10]
    3624:	mov    r12,QWORD PTR [rbp+0x18]
    3628:	mov    r13,QWORD PTR [rbp+0x20]
    362c:	mov    r14,QWORD PTR [rbp+0x28]
    3630:	mov    QWORD PTR [rsp+0x10],rsi
    3635:	mov    QWORD PTR [rsp+0x60],rsi
    363a:	mov    QWORD PTR [rsp+0x18],rdx
    363f:	mov    QWORD PTR [rsp+0x68],rdx
    3644:	mov    QWORD PTR [rsp+0x20],rcx
    3649:	mov    QWORD PTR [rsp+0x70],rcx
    364e:	mov    QWORD PTR [rsp+0x28],r15
    3653:	mov    QWORD PTR [rsp+0x30],r12
    3658:	mov    QWORD PTR [rsp+0x38],r13
    365d:	mov    QWORD PTR [rsp+0x40],r14
    3662:	sar    r8,1
    3665:	sar    r9,1
    3668:	mov    QWORD PTR [rsp+0x88],r9
    3670:	mov    rcx,QWORD PTR [rsp+0x88]
    3678:	mov    rbx,r8
    367b:	cmp    rbx,rcx
    367e:	mov    QWORD PTR [rsp+0x88],rcx
    3686:	jge    38ef <botlish_fn_42+0x307>
    368c:	xor    eax,eax
    368e:	mov    rsi,QWORD PTR [rsp+0x60]
    3693:	test   rsi,0x7
    369a:	jne    36ab <botlish_fn_42+0xc3>
    36a0:	movzx  r10,BYTE PTR [rsi]
    36a4:	cmp    r10b,0x8
    36a8:	sete   al
    36ab:	test   al,al
    36ad:	jne    36cf <botlish_fn_42+0xe7>
    36b3:	mov    rdi,QWORD PTR [rsp+0x58]
    36b8:	mov    rax,QWORD PTR [rdi+0x10]
    36bc:	mov    rcx,QWORD PTR [rax+0x30]
    36c0:	mov    edx,0x8
    36c5:	call   36ca <botlish_fn_42+0xe2>
			36c6: R_X86_64_PLT32	rt_type_error-0x4
    36ca:	jmp    386d <botlish_fn_42+0x285>
    36cf:	mov    QWORD PTR [rsp+0x60],rsi
    36d4:	mov    rdx,rbx
    36d7:	shl    rdx,1
    36da:	or     rdx,0x1
    36de:	mov    QWORD PTR [rsp+0x80],rdx
    36e6:	mov    rdi,QWORD PTR [rsp+0x58]
    36eb:	call   36f0 <botlish_fn_42+0x108>
			36ec: R_X86_64_PLT32	rt_mutarray_get-0x4
    36f0:	test   rax,rax
    36f3:	je     386d <botlish_fn_42+0x285>
    36f9:	test   rax,0x1
    36ff:	mov    rsi,rax
    3702:	jne    3725 <botlish_fn_42+0x13d>
    3708:	mov    edx,0x3
    370d:	mov    rdi,QWORD PTR [rsp+0x58]
    3712:	call   3717 <botlish_fn_42+0x12f>
			3713: R_X86_64_PLT32	rt_value_eq-0x4
    3717:	test   rax,rax
    371a:	je     386d <botlish_fn_42+0x285>
    3720:	jmp    3736 <botlish_fn_42+0x14e>
    3725:	mov    eax,0x2
    372a:	cmp    rsi,0x3
    372e:	cmove  rax,QWORD PTR [rip+0x1f2]        # 3928 <botlish_fn_42+0x340>
    3736:	cmp    rax,0x6
    373a:	je     374a <botlish_fn_42+0x162>
    3740:	mov    rsi,QWORD PTR [rsp+0x60]
    3745:	jmp    38a9 <botlish_fn_42+0x2c1>
    374a:	xor    esi,esi
    374c:	mov    rdx,QWORD PTR [rsp+0x68]
    3751:	test   rdx,0x7
    3758:	je     3768 <botlish_fn_42+0x180>
    375e:	mov    QWORD PTR [rsp+0x68],rdx
    3763:	jmp    3777 <botlish_fn_42+0x18f>
    3768:	movzx  rax,BYTE PTR [rdx]
    376c:	mov    QWORD PTR [rsp+0x68],rdx
    3771:	cmp    al,0x8
    3773:	sete   sil
    3777:	test   sil,sil
    377a:	jne    37a1 <botlish_fn_42+0x1b9>
    3780:	mov    rdi,QWORD PTR [rsp+0x58]
    3785:	mov    rax,QWORD PTR [rdi+0x10]
    3789:	mov    rcx,QWORD PTR [rax+0x30]
    378d:	mov    edx,0x8
    3792:	mov    rsi,QWORD PTR [rsp+0x68]
    3797:	call   379c <botlish_fn_42+0x1b4>
			3798: R_X86_64_PLT32	rt_type_error-0x4
    379c:	jmp    386d <botlish_fn_42+0x285>
    37a1:	mov    rdx,QWORD PTR [rsp+0x80]
    37a9:	mov    rsi,QWORD PTR [rsp+0x68]
    37ae:	mov    rdi,QWORD PTR [rsp+0x58]
    37b3:	call   37b8 <botlish_fn_42+0x1d0>
			37b4: R_X86_64_PLT32	rt_mutarray_get-0x4
    37b8:	test   rax,rax
    37bb:	je     386d <botlish_fn_42+0x285>
    37c1:	mov    QWORD PTR [rsp+0x48],rax
    37c6:	mov    QWORD PTR [rsp+0x78],rax
    37cb:	xor    eax,eax
    37cd:	mov    rcx,QWORD PTR [rsp+0x70]
    37d2:	test   rcx,0x7
    37d9:	je     37e9 <botlish_fn_42+0x201>
    37df:	mov    QWORD PTR [rsp+0x70],rcx
    37e4:	jmp    37f7 <botlish_fn_42+0x20f>
    37e9:	movzx  rax,BYTE PTR [rcx]
    37ed:	mov    QWORD PTR [rsp+0x70],rcx
    37f2:	cmp    al,0x8
    37f4:	sete   al
    37f7:	test   al,al
    37f9:	jne    3820 <botlish_fn_42+0x238>
    37ff:	mov    rdi,QWORD PTR [rsp+0x58]
    3804:	mov    rax,QWORD PTR [rdi+0x10]
    3808:	mov    rcx,QWORD PTR [rax+0x30]
    380c:	mov    edx,0x8
    3811:	mov    rsi,QWORD PTR [rsp+0x70]
    3816:	call   381b <botlish_fn_42+0x233>
			3817: R_X86_64_PLT32	rt_type_error-0x4
    381b:	jmp    386d <botlish_fn_42+0x285>
    3820:	mov    rdx,QWORD PTR [rsp+0x80]
    3828:	mov    rsi,QWORD PTR [rsp+0x70]
    382d:	mov    rdi,QWORD PTR [rsp+0x58]
    3832:	call   3837 <botlish_fn_42+0x24f>
			3833: R_X86_64_PLT32	rt_mutarray_get-0x4
    3837:	test   rax,rax
    383a:	je     386d <botlish_fn_42+0x285>
    3840:	mov    QWORD PTR [rsp+0x50],rax
    3845:	mov    QWORD PTR [rsp],rax
    3849:	mov    r9,QWORD PTR [rsp+0x78]
    384e:	mov    rcx,r13
    3851:	mov    rdx,r12
    3854:	mov    rsi,r15
    3857:	mov    rdi,QWORD PTR [rsp+0x58]
    385c:	mov    r8,r14
    385f:	call   3864 <botlish_fn_42+0x27c>
			3860: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    3864:	test   rax,rax
    3867:	jne    38a4 <botlish_fn_42+0x2bc>
    386d:	xor    rax,rax
    3870:	mov    rbx,QWORD PTR [rsp+0x90]
    3878:	mov    r12,QWORD PTR [rsp+0x98]
    3880:	mov    r13,QWORD PTR [rsp+0xa0]
    3888:	mov    r14,QWORD PTR [rsp+0xa8]
    3890:	mov    r15,QWORD PTR [rsp+0xb0]
    3898:	add    rsp,0xc0
    389f:	mov    rsp,rbp
    38a2:	pop    rbp
    38a3:	ret
    38a4:	mov    rsi,QWORD PTR [rsp+0x60]
    38a9:	mov    rsi,QWORD PTR [rsp+0x60]
    38ae:	mov    QWORD PTR [rsp+0x10],rsi
    38b3:	mov    rsi,QWORD PTR [rsp+0x68]
    38b8:	mov    QWORD PTR [rsp+0x18],rsi
    38bd:	mov    rsi,QWORD PTR [rsp+0x70]
    38c2:	mov    QWORD PTR [rsp+0x20],rsi
    38c7:	mov    QWORD PTR [rsp+0x28],r15
    38cc:	mov    QWORD PTR [rsp+0x30],r12
    38d1:	mov    QWORD PTR [rsp+0x38],r13
    38d6:	mov    QWORD PTR [rsp+0x40],r14
    38db:	add    rbx,0x1
    38e2:	mov    rcx,QWORD PTR [rsp+0x88]
    38ea:	jmp    367b <botlish_fn_42+0x93>
    38ef:	mov    eax,0xa
    38f4:	mov    rbx,QWORD PTR [rsp+0x90]
    38fc:	mov    r12,QWORD PTR [rsp+0x98]
    3904:	mov    r13,QWORD PTR [rsp+0xa0]
    390c:	mov    r14,QWORD PTR [rsp+0xa8]
    3914:	mov    r15,QWORD PTR [rsp+0xb0]
    391c:	add    rsp,0xc0
    3923:	mov    rsp,rbp
    3926:	pop    rbp
    3927:	ret
    3928:	(bad)
    3929:	add    BYTE PTR [rax],al
    392b:	add    BYTE PTR [rax],al
    392d:	add    BYTE PTR [rax],al
	...

0000000000003930 <botlish_entry_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3930:	push   rbp
    3931:	mov    rbp,rsp
    3934:	sub    rsp,0x30
    3938:	mov    QWORD PTR [rsp+0x20],r12
    393d:	mov    rsi,QWORD PTR [rdx]
    3940:	mov    rax,QWORD PTR [rdx+0x8]
    3944:	mov    rcx,QWORD PTR [rdx+0x10]
    3948:	mov    r8,QWORD PTR [rdx+0x18]
    394c:	mov    r9,QWORD PTR [rdx+0x20]
    3950:	mov    r10,QWORD PTR [rdx+0x28]
    3954:	mov    r11,QWORD PTR [rdx+0x30]
    3958:	mov    r12,QWORD PTR [rdx+0x38]
    395c:	mov    rdx,QWORD PTR [rdx+0x40]
    3960:	mov    QWORD PTR [rsp],r10
    3964:	mov    QWORD PTR [rsp+0x8],r11
    3969:	mov    QWORD PTR [rsp+0x10],r12
    396e:	mov    QWORD PTR [rsp+0x18],rdx
    3973:	mov    rdx,rax
    3976:	call   397b <botlish_entry_42+0x4b>
			3977: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    397b:	mov    r12,QWORD PTR [rsp+0x20]
    3980:	add    rsp,0x30
    3984:	mov    rsp,rbp
    3987:	pop    rbp
    3988:	ret

0000000000003989 <botlish_fn_43: ht_rehash<mutarray, int>>:
    3989:	push   rbp
    398a:	mov    rbp,rsp
    398d:	sub    rsp,0xd0
    3994:	mov    QWORD PTR [rsp+0xa0],rbx
    399c:	mov    QWORD PTR [rsp+0xa8],r12
    39a4:	mov    QWORD PTR [rsp+0xb0],r13
    39ac:	mov    QWORD PTR [rsp+0xb8],r14
    39b4:	mov    QWORD PTR [rsp+0xc0],r15
    39bc:	mov    r13,rdi
    39bf:	mov    QWORD PTR [rsp+0x50],0x0
    39c8:	mov    QWORD PTR [rsp+0x58],0x0
    39d1:	mov    QWORD PTR [rsp+0x60],0x0
    39da:	mov    QWORD PTR [rsp+0x68],0x0
    39e3:	mov    QWORD PTR [rsp+0x20],rsi
    39e8:	mov    r12,rsi
    39eb:	mov    QWORD PTR [rsp+0x28],rdx
    39f0:	mov    rbx,rdx
    39f3:	mov    rsi,r12
    39f6:	mov    rdi,r13
    39f9:	call   39fe <botlish_fn_43+0x75>
			39fa: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    39fe:	test   rax,rax
    3a01:	je     3bd0 <botlish_fn_43+0x247>
    3a07:	mov    QWORD PTR [rsp+0x30],rax
    3a0c:	mov    r14,rax
    3a0f:	mov    rsi,r12
    3a12:	mov    rdi,r13
    3a15:	call   3a1a <botlish_fn_43+0x91>
			3a16: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3a1a:	test   rax,rax
    3a1d:	je     3bd0 <botlish_fn_43+0x247>
    3a23:	mov    QWORD PTR [rsp+0x38],rax
    3a28:	mov    r15,rax
    3a2b:	mov    rsi,r12
    3a2e:	mov    rdi,r13
    3a31:	call   3a36 <botlish_fn_43+0xad>
			3a32: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3a36:	test   rax,rax
    3a39:	je     3bd0 <botlish_fn_43+0x247>
    3a3f:	mov    QWORD PTR [rsp+0x40],rax
    3a44:	mov    QWORD PTR [rsp+0x90],rax
    3a4c:	mov    rsi,r12
    3a4f:	mov    rdi,r13
    3a52:	call   3a57 <botlish_fn_43+0xce>
			3a53: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3a57:	test   rax,rax
    3a5a:	je     3bd0 <botlish_fn_43+0x247>
    3a60:	mov    QWORD PTR [rsp+0x48],rax
    3a65:	mov    QWORD PTR [rsp+0x88],rax
    3a6d:	mov    rsi,rbx
    3a70:	mov    rdi,r13
    3a73:	call   3a78 <botlish_fn_43+0xef>
			3a74: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3a78:	mov    rcx,rax
    3a7b:	mov    QWORD PTR [rsp+0x80],rax
    3a83:	test   rax,rcx
    3a86:	je     3bd0 <botlish_fn_43+0x247>
    3a8c:	mov    rax,QWORD PTR [rsp+0x80]
    3a94:	mov    QWORD PTR [rsp+0x50],rax
    3a99:	mov    edx,0x1
    3a9e:	mov    QWORD PTR [rsp+0x58],0x1
    3aa7:	mov    rcx,rbx
    3aaa:	mov    rsi,QWORD PTR [rsp+0x80]
    3ab2:	mov    rdi,r13
    3ab5:	call   3aba <botlish_fn_43+0x131>
			3ab6: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3aba:	test   rax,rax
    3abd:	je     3bd0 <botlish_fn_43+0x247>
    3ac3:	mov    rsi,rbx
    3ac6:	mov    rdi,r13
    3ac9:	call   3ace <botlish_fn_43+0x145>
			3aca: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3ace:	test   rax,rax
    3ad1:	je     3bd0 <botlish_fn_43+0x247>
    3ad7:	mov    QWORD PTR [rsp+0x58],rax
    3adc:	mov    QWORD PTR [rsp+0x78],rax
    3ae1:	mov    rsi,rbx
    3ae4:	mov    rdi,r13
    3ae7:	call   3aec <botlish_fn_43+0x163>
			3ae8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3aec:	test   rax,rax
    3aef:	je     3bd0 <botlish_fn_43+0x247>
    3af5:	mov    QWORD PTR [rsp+0x60],rax
    3afa:	mov    r8d,0x1
    3b00:	mov    QWORD PTR [rsp+0x68],0x1
    3b09:	mov    rcx,QWORD PTR [rsp+0x80]
    3b11:	mov    QWORD PTR [rsp],rcx
    3b15:	mov    rcx,QWORD PTR [rsp+0x78]
    3b1a:	mov    QWORD PTR [rsp+0x8],rcx
    3b1f:	mov    QWORD PTR [rsp+0x10],rax
    3b24:	mov    QWORD PTR [rsp+0x70],rax
    3b29:	mov    QWORD PTR [rsp+0x18],rbx
    3b2e:	mov    rcx,QWORD PTR [rsp+0x90]
    3b36:	mov    rdx,r15
    3b39:	mov    rsi,r14
    3b3c:	mov    r9,QWORD PTR [rsp+0x88]
    3b44:	mov    rdi,r13
    3b47:	call   3b4c <botlish_fn_43+0x1c3>
			3b48: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3b4c:	test   rax,rax
    3b4f:	je     3bd0 <botlish_fn_43+0x247>
    3b55:	mov    edx,0x1
    3b5a:	mov    rcx,QWORD PTR [rsp+0x80]
    3b62:	mov    rsi,r12
    3b65:	mov    rdi,r13
    3b68:	call   3b6d <botlish_fn_43+0x1e4>
			3b69: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b6d:	test   rax,rax
    3b70:	je     3bd0 <botlish_fn_43+0x247>
    3b76:	mov    edx,0x3
    3b7b:	mov    rcx,QWORD PTR [rsp+0x78]
    3b80:	mov    rsi,r12
    3b83:	mov    rdi,r13
    3b86:	call   3b8b <botlish_fn_43+0x202>
			3b87: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b8b:	test   rax,rax
    3b8e:	je     3bd0 <botlish_fn_43+0x247>
    3b94:	mov    edx,0x5
    3b99:	mov    rcx,QWORD PTR [rsp+0x70]
    3b9e:	mov    rsi,r12
    3ba1:	mov    rdi,r13
    3ba4:	call   3ba9 <botlish_fn_43+0x220>
			3ba5: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ba9:	test   rax,rax
    3bac:	je     3bd0 <botlish_fn_43+0x247>
    3bb2:	mov    edx,0x9
    3bb7:	mov    ecx,0x1
    3bbc:	mov    rsi,r12
    3bbf:	mov    rdi,r13
    3bc2:	call   3bc7 <botlish_fn_43+0x23e>
			3bc3: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bc7:	test   rax,rax
    3bca:	jne    3c07 <botlish_fn_43+0x27e>
    3bd0:	xor    rax,rax
    3bd3:	mov    rbx,QWORD PTR [rsp+0xa0]
    3bdb:	mov    r12,QWORD PTR [rsp+0xa8]
    3be3:	mov    r13,QWORD PTR [rsp+0xb0]
    3beb:	mov    r14,QWORD PTR [rsp+0xb8]
    3bf3:	mov    r15,QWORD PTR [rsp+0xc0]
    3bfb:	add    rsp,0xd0
    3c02:	mov    rsp,rbp
    3c05:	pop    rbp
    3c06:	ret
    3c07:	mov    eax,0xa
    3c0c:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c14:	mov    r12,QWORD PTR [rsp+0xa8]
    3c1c:	mov    r13,QWORD PTR [rsp+0xb0]
    3c24:	mov    r14,QWORD PTR [rsp+0xb8]
    3c2c:	mov    r15,QWORD PTR [rsp+0xc0]
    3c34:	add    rsp,0xd0
    3c3b:	mov    rsp,rbp
    3c3e:	pop    rbp
    3c3f:	ret

0000000000003c40 <botlish_entry_43: ht_rehash<mutarray, int>>:
    3c40:	push   rbp
    3c41:	mov    rbp,rsp
    3c44:	mov    rsi,QWORD PTR [rdx]
    3c47:	mov    rdx,QWORD PTR [rdx+0x8]
    3c4b:	call   3c50 <botlish_entry_43+0x10>
			3c4c: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3c50:	mov    rsp,rbp
    3c53:	pop    rbp
    3c54:	ret
    3c55:	add    BYTE PTR [rax],al
	...

0000000000003c58 <botlish_fn_44: ht_should_grow<mutarray>>:
    3c58:	push   rbp
    3c59:	mov    rbp,rsp
    3c5c:	sub    rsp,0x40
    3c60:	mov    QWORD PTR [rsp+0x20],rbx
    3c65:	mov    QWORD PTR [rsp+0x28],r12
    3c6a:	mov    QWORD PTR [rsp+0x30],r13
    3c6f:	mov    rbx,rdi
    3c72:	mov    QWORD PTR [rsp],rsi
    3c76:	mov    r12,rsi
    3c79:	mov    rsi,r12
    3c7c:	mov    rdi,rbx
    3c7f:	call   3c84 <botlish_fn_44+0x2c>
			3c80: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3c84:	mov    rcx,rax
    3c87:	mov    r13,rax
    3c8a:	test   rax,rcx
    3c8d:	je     3e7c <botlish_fn_44+0x224>
    3c93:	mov    rax,r13
    3c96:	mov    QWORD PTR [rsp+0x8],rax
    3c9b:	mov    rsi,r12
    3c9e:	mov    rdi,rbx
    3ca1:	call   3ca6 <botlish_fn_44+0x4e>
			3ca2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3ca6:	mov    rcx,rax
    3ca9:	test   rcx,rcx
    3cac:	je     3e7c <botlish_fn_44+0x224>
    3cb2:	mov    QWORD PTR [rsp+0x10],rcx
    3cb7:	mov    edx,0x1
    3cbc:	mov    rax,r13
    3cbf:	test   rax,0x1
    3cc5:	jne    3ce8 <botlish_fn_44+0x90>
    3ccb:	xor    edx,edx
    3ccd:	mov    rax,r13
    3cd0:	test   rax,0x7
    3cd6:	jne    3ce8 <botlish_fn_44+0x90>
    3cdc:	mov    rax,r13
    3cdf:	movzx  rax,BYTE PTR [rax]
    3ce3:	cmp    al,0x1
    3ce5:	sete   dl
    3ce8:	test   dl,dl
    3cea:	jne    3d0b <botlish_fn_44+0xb3>
    3cf0:	mov    rdi,rbx
    3cf3:	mov    rax,QWORD PTR [rdi+0x10]
    3cf7:	mov    rcx,QWORD PTR [rax+0x38]
    3cfb:	xor    rdx,rdx
    3cfe:	mov    rsi,r13
    3d01:	call   3d06 <botlish_fn_44+0xae>
			3d02: R_X86_64_PLT32	rt_type_error-0x4
    3d06:	jmp    3e7c <botlish_fn_44+0x224>
    3d0b:	mov    eax,0x1
    3d10:	test   rcx,0x1
    3d17:	je     3d25 <botlish_fn_44+0xcd>
    3d1d:	mov    r8,rcx
    3d20:	jmp    3d48 <botlish_fn_44+0xf0>
    3d25:	xor    eax,eax
    3d27:	test   rcx,0x7
    3d2e:	je     3d3c <botlish_fn_44+0xe4>
    3d34:	mov    r8,rcx
    3d37:	jmp    3d48 <botlish_fn_44+0xf0>
    3d3c:	movzx  rax,BYTE PTR [rcx]
    3d40:	mov    r8,rcx
    3d43:	cmp    al,0x1
    3d45:	sete   al
    3d48:	test   al,al
    3d4a:	jne    3d6b <botlish_fn_44+0x113>
    3d50:	mov    rdi,rbx
    3d53:	mov    rax,QWORD PTR [rdi+0x10]
    3d57:	mov    rcx,QWORD PTR [rax+0x38]
    3d5b:	xor    rdx,rdx
    3d5e:	mov    rsi,r8
    3d61:	call   3d66 <botlish_fn_44+0x10e>
			3d62: R_X86_64_PLT32	rt_type_error-0x4
    3d66:	jmp    3e7c <botlish_fn_44+0x224>
    3d6b:	mov    rcx,r8
    3d6e:	mov    rsi,r13
    3d71:	mov    rax,rsi
    3d74:	and    rax,rcx
    3d77:	test   rax,0x1
    3d7d:	jne    3d8e <botlish_fn_44+0x136>
    3d83:	mov    rdx,r8
    3d86:	mov    rsi,r13
    3d89:	jmp    3dac <botlish_fn_44+0x154>
    3d8e:	mov    rcx,r8
    3d91:	lea    rax,[rcx-0x1]
    3d95:	mov    rsi,r13
    3d98:	add    rsi,rax
    3d9b:	seto   al
    3d9e:	test   al,al
    3da0:	je     3db7 <botlish_fn_44+0x15f>
    3da6:	mov    rdx,r8
    3da9:	mov    rsi,r13
    3dac:	mov    rdi,rbx
    3daf:	call   3db4 <botlish_fn_44+0x15c>
			3db0: R_X86_64_PLT32	rt_int_add-0x4
    3db4:	mov    rsi,rax
    3db7:	mov    QWORD PTR [rsp+0x8],rsi
    3dbc:	mov    QWORD PTR [rsp+0x10],0x3
    3dc5:	test   rsi,0x1
    3dcc:	je     3def <botlish_fn_44+0x197>
    3dd2:	mov    rax,rsi
    3dd5:	add    rax,0x2
    3dd9:	mov    rcx,rax
    3ddc:	seto   al
    3ddf:	test   al,al
    3de1:	jne    3def <botlish_fn_44+0x197>
    3de7:	mov    rsi,rcx
    3dea:	jmp    3dff <botlish_fn_44+0x1a7>
    3def:	mov    edx,0x3
    3df4:	mov    rdi,rbx
    3df7:	call   3dfc <botlish_fn_44+0x1a4>
			3df8: R_X86_64_PLT32	rt_int_add-0x4
    3dfc:	mov    rsi,rax
    3dff:	mov    QWORD PTR [rsp+0x8],rsi
    3e04:	mov    edx,0x7
    3e09:	mov    rdi,rdx
    3e0c:	mov    QWORD PTR [rsp+0x10],0x7
    3e15:	test   rsi,0x1
    3e1c:	jne    3e2a <botlish_fn_44+0x1d2>
    3e22:	mov    rdx,rdi
    3e25:	jmp    3e56 <botlish_fn_44+0x1fe>
    3e2a:	mov    rax,rsi
    3e2d:	sar    rax,1
    3e30:	imul   QWORD PTR [rip+0x119]        # 3f50 <botlish_fn_44+0x2f8>
    3e37:	seto   cl
    3e3a:	or     rax,0x1
    3e3e:	test   cl,cl
    3e40:	je     3e4e <botlish_fn_44+0x1f6>
    3e46:	mov    rdx,rdi
    3e49:	jmp    3e56 <botlish_fn_44+0x1fe>
    3e4e:	mov    rsi,rax
    3e51:	jmp    3e61 <botlish_fn_44+0x209>
    3e56:	mov    rdi,rbx
    3e59:	call   3e5e <botlish_fn_44+0x206>
			3e5a: R_X86_64_PLT32	rt_int_mul-0x4
    3e5e:	mov    rsi,rax
    3e61:	mov    QWORD PTR [rsp],rsi
    3e65:	mov    r13,rsi
    3e68:	mov    rsi,r12
    3e6b:	mov    rdi,rbx
    3e6e:	call   3e73 <botlish_fn_44+0x21b>
			3e6f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3e73:	test   rax,rax
    3e76:	jne    3e97 <botlish_fn_44+0x23f>
    3e7c:	xor    rax,rax
    3e7f:	mov    rbx,QWORD PTR [rsp+0x20]
    3e84:	mov    r12,QWORD PTR [rsp+0x28]
    3e89:	mov    r13,QWORD PTR [rsp+0x30]
    3e8e:	add    rsp,0x40
    3e92:	mov    rsp,rbp
    3e95:	pop    rbp
    3e96:	ret
    3e97:	mov    QWORD PTR [rsp+0x8],rax
    3e9c:	mov    QWORD PTR [rsp+0x10],0x5
    3ea5:	test   rax,0x1
    3eab:	mov    rsi,rax
    3eae:	je     3ee0 <botlish_fn_44+0x288>
    3eb4:	mov    rcx,rsi
    3eb7:	mov    rax,rcx
    3eba:	sar    rax,1
    3ebd:	imul   QWORD PTR [rip+0x94]        # 3f58 <botlish_fn_44+0x300>
    3ec4:	seto   dil
    3ec8:	or     rax,0x1
    3ecc:	test   dil,dil
    3ecf:	jne    3ee0 <botlish_fn_44+0x288>
    3ed5:	mov    rdx,rax
    3ed8:	mov    rsi,r13
    3edb:	jmp    3ef3 <botlish_fn_44+0x29b>
    3ee0:	mov    edx,0x5
    3ee5:	mov    rdi,rbx
    3ee8:	call   3eed <botlish_fn_44+0x295>
			3ee9: R_X86_64_PLT32	rt_int_mul-0x4
    3eed:	mov    rdx,rax
    3ef0:	mov    rsi,r13
    3ef3:	mov    r10,rsi
    3ef6:	and    r10,rdx
    3ef9:	test   r10,0x1
    3f00:	jne    3f27 <botlish_fn_44+0x2cf>
    3f06:	mov    rdi,rbx
    3f09:	call   3f0e <botlish_fn_44+0x2b6>
			3f0a: R_X86_64_PLT32	rt_int_cmp-0x4
    3f0e:	mov    r8d,0x2
    3f14:	test   rax,rax
    3f17:	mov    rax,r8
    3f1a:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3f50 <botlish_fn_44+0x2f8>
    3f22:	jmp    3f37 <botlish_fn_44+0x2df>
    3f27:	mov    eax,0x2
    3f2c:	cmp    rsi,rdx
    3f2f:	cmovg  rax,QWORD PTR [rip+0x19]        # 3f50 <botlish_fn_44+0x2f8>
    3f37:	mov    rbx,QWORD PTR [rsp+0x20]
    3f3c:	mov    r12,QWORD PTR [rsp+0x28]
    3f41:	mov    r13,QWORD PTR [rsp+0x30]
    3f46:	add    rsp,0x40
    3f4a:	mov    rsp,rbp
    3f4d:	pop    rbp
    3f4e:	ret
    3f4f:	add    BYTE PTR [rsi],al
    3f51:	add    BYTE PTR [rax],al
    3f53:	add    BYTE PTR [rax],al
    3f55:	add    BYTE PTR [rax],al
    3f57:	add    BYTE PTR [rax+rax*1],al
    3f5a:	add    BYTE PTR [rax],al
    3f5c:	add    BYTE PTR [rax],al
	...

0000000000003f60 <botlish_entry_44: ht_should_grow<mutarray>>:
    3f60:	push   rbp
    3f61:	mov    rbp,rsp
    3f64:	mov    rsi,QWORD PTR [rdx]
    3f67:	call   3f6c <botlish_entry_44+0xc>
			3f68: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3f6c:	mov    rsp,rbp
    3f6f:	pop    rbp
    3f70:	ret
    3f71:	add    BYTE PTR [rax],al
    3f73:	add    BYTE PTR [rax],al
    3f75:	add    BYTE PTR [rax],al
	...

0000000000003f78 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    3f78:	push   rbp
    3f79:	mov    rbp,rsp
    3f7c:	sub    rsp,0x40
    3f80:	mov    QWORD PTR [rsp+0x20],rbx
    3f85:	mov    QWORD PTR [rsp+0x28],r12
    3f8a:	mov    QWORD PTR [rsp+0x30],r13
    3f8f:	mov    rbx,rdi
    3f92:	mov    QWORD PTR [rsp+0x10],0x0
    3f9b:	mov    QWORD PTR [rsp],rsi
    3f9f:	mov    r12,rsi
    3fa2:	mov    rsi,r12
    3fa5:	mov    rdi,rbx
    3fa8:	call   3fad <botlish_fn_45+0x35>
			3fa9: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3fad:	test   rax,rax
    3fb0:	mov    r13,rax
    3fb3:	je     41a0 <botlish_fn_45+0x228>
    3fb9:	mov    rsi,r12
    3fbc:	mov    rdi,rbx
    3fbf:	call   3fc4 <botlish_fn_45+0x4c>
			3fc0: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3fc4:	mov    rcx,rax
    3fc7:	test   rcx,rcx
    3fca:	je     41a0 <botlish_fn_45+0x228>
    3fd0:	mov    edx,0x1
    3fd5:	mov    rax,r13
    3fd8:	test   rax,0x1
    3fde:	je     3fec <botlish_fn_45+0x74>
    3fe4:	mov    r13,rax
    3fe7:	jmp    4010 <botlish_fn_45+0x98>
    3fec:	xor    edx,edx
    3fee:	test   rax,0x7
    3ff4:	je     4002 <botlish_fn_45+0x8a>
    3ffa:	mov    r13,rax
    3ffd:	jmp    4010 <botlish_fn_45+0x98>
    4002:	movzx  rdx,BYTE PTR [rax]
    4006:	mov    r13,rax
    4009:	rex cmp dl,0x1
    400d:	sete   dl
    4010:	test   dl,dl
    4012:	jne    4033 <botlish_fn_45+0xbb>
    4018:	mov    rdi,rbx
    401b:	mov    rsi,QWORD PTR [rdi+0x10]
    401f:	mov    rcx,QWORD PTR [rsi+0x40]
    4023:	xor    rdx,rdx
    4026:	mov    rsi,r13
    4029:	call   402e <botlish_fn_45+0xb6>
			402a: R_X86_64_PLT32	rt_type_error-0x4
    402e:	jmp    41a0 <botlish_fn_45+0x228>
    4033:	mov    rsi,r13
    4036:	mov    eax,0x1
    403b:	test   rcx,0x1
    4042:	je     4050 <botlish_fn_45+0xd8>
    4048:	mov    r8,rcx
    404b:	jmp    4075 <botlish_fn_45+0xfd>
    4050:	xor    eax,eax
    4052:	test   rcx,0x7
    4059:	je     4067 <botlish_fn_45+0xef>
    405f:	mov    r8,rcx
    4062:	jmp    4075 <botlish_fn_45+0xfd>
    4067:	movzx  r11,BYTE PTR [rcx]
    406b:	mov    r8,rcx
    406e:	cmp    r11b,0x1
    4072:	sete   al
    4075:	test   al,al
    4077:	jne    4098 <botlish_fn_45+0x120>
    407d:	mov    rdi,rbx
    4080:	mov    rax,QWORD PTR [rdi+0x10]
    4084:	mov    rcx,QWORD PTR [rax+0x40]
    4088:	xor    rdx,rdx
    408b:	mov    rsi,r8
    408e:	call   4093 <botlish_fn_45+0x11b>
			408f: R_X86_64_PLT32	rt_type_error-0x4
    4093:	jmp    41a0 <botlish_fn_45+0x228>
    4098:	mov    rcx,r8
    409b:	mov    rax,rsi
    409e:	and    rax,rcx
    40a1:	test   rax,0x1
    40a7:	jne    40cd <botlish_fn_45+0x155>
    40ad:	mov    rdx,r8
    40b0:	mov    rdi,rbx
    40b3:	call   40b8 <botlish_fn_45+0x140>
			40b4: R_X86_64_PLT32	rt_int_cmp-0x4
    40b8:	mov    ecx,0x2
    40bd:	test   rax,rax
    40c0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 41d8 <botlish_fn_45+0x260>
    40c8:	jmp    40e0 <botlish_fn_45+0x168>
    40cd:	mov    ecx,0x2
    40d2:	mov    r9,r8
    40d5:	cmp    rsi,r9
    40d8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 41d8 <botlish_fn_45+0x260>
    40e0:	cmp    rcx,0x6
    40e4:	je     4170 <botlish_fn_45+0x1f8>
    40ea:	mov    rsi,r12
    40ed:	mov    rdi,rbx
    40f0:	call   40f5 <botlish_fn_45+0x17d>
			40f1: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    40f5:	test   rax,rax
    40f8:	je     41a0 <botlish_fn_45+0x228>
    40fe:	mov    QWORD PTR [rsp+0x8],rax
    4103:	mov    QWORD PTR [rsp+0x10],0x5
    410c:	test   rax,0x1
    4112:	mov    rsi,rax
    4115:	je     4142 <botlish_fn_45+0x1ca>
    411b:	mov    rcx,rsi
    411e:	mov    rax,rcx
    4121:	sar    rax,1
    4124:	imul   QWORD PTR [rip+0xb5]        # 41e0 <botlish_fn_45+0x268>
    412b:	seto   cl
    412e:	or     rax,0x1
    4132:	test   cl,cl
    4134:	jne    4142 <botlish_fn_45+0x1ca>
    413a:	mov    rdx,rax
    413d:	jmp    4152 <botlish_fn_45+0x1da>
    4142:	mov    edx,0x5
    4147:	mov    rdi,rbx
    414a:	call   414f <botlish_fn_45+0x1d7>
			414b: R_X86_64_PLT32	rt_int_mul-0x4
    414f:	mov    rdx,rax
    4152:	mov    QWORD PTR [rsp+0x8],rdx
    4157:	mov    rsi,r12
    415a:	mov    rdi,rbx
    415d:	call   4162 <botlish_fn_45+0x1ea>
			415e: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    4162:	test   rax,rax
    4165:	je     41a0 <botlish_fn_45+0x228>
    416b:	jmp    41bb <botlish_fn_45+0x243>
    4170:	mov    rsi,r12
    4173:	mov    rdi,rbx
    4176:	call   417b <botlish_fn_45+0x203>
			4177: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    417b:	test   rax,rax
    417e:	je     41a0 <botlish_fn_45+0x228>
    4184:	mov    QWORD PTR [rsp+0x8],rax
    4189:	mov    rdx,rax
    418c:	mov    rsi,r12
    418f:	mov    rdi,rbx
    4192:	call   4197 <botlish_fn_45+0x21f>
			4193: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    4197:	test   rax,rax
    419a:	jne    41bb <botlish_fn_45+0x243>
    41a0:	xor    rax,rax
    41a3:	mov    rbx,QWORD PTR [rsp+0x20]
    41a8:	mov    r12,QWORD PTR [rsp+0x28]
    41ad:	mov    r13,QWORD PTR [rsp+0x30]
    41b2:	add    rsp,0x40
    41b6:	mov    rsp,rbp
    41b9:	pop    rbp
    41ba:	ret
    41bb:	mov    rbx,QWORD PTR [rsp+0x20]
    41c0:	mov    r12,QWORD PTR [rsp+0x28]
    41c5:	mov    r13,QWORD PTR [rsp+0x30]
    41ca:	add    rsp,0x40
    41ce:	mov    rsp,rbp
    41d1:	pop    rbp
    41d2:	ret
    41d3:	add    BYTE PTR [rax],al
    41d5:	add    BYTE PTR [rax],al
    41d7:	add    BYTE PTR [rsi],al
    41d9:	add    BYTE PTR [rax],al
    41db:	add    BYTE PTR [rax],al
    41dd:	add    BYTE PTR [rax],al
    41df:	add    BYTE PTR [rax+rax*1],al
    41e2:	add    BYTE PTR [rax],al
    41e4:	add    BYTE PTR [rax],al
	...

00000000000041e8 <botlish_entry_45: ht_grow_or_clean<mutarray>>:
    41e8:	push   rbp
    41e9:	mov    rbp,rsp
    41ec:	mov    rsi,QWORD PTR [rdx]
    41ef:	call   41f4 <botlish_entry_45+0xc>
			41f0: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    41f4:	mov    rsp,rbp
    41f7:	pop    rbp
    41f8:	ret
    41f9:	add    BYTE PTR [rax],al
    41fb:	add    BYTE PTR [rax],al
    41fd:	add    BYTE PTR [rax],al
	...

0000000000004200 <botlish_fn_46: ht_place<mutarray, int, str, str>>:
    4200:	push   rbp
    4201:	mov    rbp,rsp
    4204:	sub    rsp,0x70
    4208:	mov    QWORD PTR [rsp+0x40],rbx
    420d:	mov    QWORD PTR [rsp+0x48],r12
    4212:	mov    QWORD PTR [rsp+0x50],r13
    4217:	mov    QWORD PTR [rsp+0x58],r14
    421c:	mov    QWORD PTR [rsp+0x60],r15
    4221:	mov    rbx,rdi
    4224:	mov    r14,r8
    4227:	mov    r15,rdx
    422a:	mov    QWORD PTR [rsp+0x28],rcx
    422f:	mov    QWORD PTR [rsp],rsi
    4233:	mov    r12,rsi
    4236:	mov    rsi,r12
    4239:	mov    rdi,rbx
    423c:	call   4241 <botlish_fn_46+0x41>
			423d: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    4241:	test   rax,rax
    4244:	je     45a8 <botlish_fn_46+0x3a8>
    424a:	xor    ecx,ecx
    424c:	test   rax,0x7
    4252:	je     4262 <botlish_fn_46+0x62>
    4258:	mov    QWORD PTR [rsp+0x30],rax
    425d:	jmp    4272 <botlish_fn_46+0x72>
    4262:	movzx  rcx,BYTE PTR [rax]
    4266:	mov    QWORD PTR [rsp+0x30],rax
    426b:	rex cmp cl,0x8
    426f:	sete   cl
    4272:	test   cl,cl
    4274:	jne    4299 <botlish_fn_46+0x99>
    427a:	mov    rdi,rbx
    427d:	mov    rax,QWORD PTR [rdi+0x10]
    4281:	mov    rcx,QWORD PTR [rax+0x30]
    4285:	mov    edx,0x8
    428a:	mov    rsi,QWORD PTR [rsp+0x30]
    428f:	call   4294 <botlish_fn_46+0x94>
			4290: R_X86_64_PLT32	rt_type_error-0x4
    4294:	jmp    45a8 <botlish_fn_46+0x3a8>
    4299:	mov    rdx,r15
    429c:	mov    rsi,QWORD PTR [rsp+0x30]
    42a1:	mov    rdi,rbx
    42a4:	call   42a9 <botlish_fn_46+0xa9>
			42a5: R_X86_64_PLT32	rt_mutarray_get-0x4
    42a9:	test   rax,rax
    42ac:	je     45a8 <botlish_fn_46+0x3a8>
    42b2:	mov    QWORD PTR [rsp+0x8],rax
    42b7:	mov    r13,rax
    42ba:	mov    ecx,0x3
    42bf:	mov    rsi,QWORD PTR [rsp+0x30]
    42c4:	mov    rdx,r15
    42c7:	mov    rdi,rbx
    42ca:	call   42cf <botlish_fn_46+0xcf>
			42cb: R_X86_64_PLT32	rt_mutarray_set-0x4
    42cf:	test   rax,rax
    42d2:	je     45a8 <botlish_fn_46+0x3a8>
    42d8:	mov    rsi,r12
    42db:	mov    rdi,rbx
    42de:	call   42e3 <botlish_fn_46+0xe3>
			42df: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    42e3:	test   rax,rax
    42e6:	je     45a8 <botlish_fn_46+0x3a8>
    42ec:	xor    ecx,ecx
    42ee:	test   rax,0x7
    42f4:	je     4302 <botlish_fn_46+0x102>
    42fa:	mov    rsi,rax
    42fd:	jmp    4310 <botlish_fn_46+0x110>
    4302:	movzx  rcx,BYTE PTR [rax]
    4306:	mov    rsi,rax
    4309:	rex cmp cl,0x8
    430d:	sete   cl
    4310:	test   cl,cl
    4312:	jne    4331 <botlish_fn_46+0x131>
    4318:	mov    rdi,rbx
    431b:	mov    rax,QWORD PTR [rdi+0x10]
    431f:	mov    rcx,QWORD PTR [rax]
    4322:	mov    edx,0x8
    4327:	call   432c <botlish_fn_46+0x12c>
			4328: R_X86_64_PLT32	rt_type_error-0x4
    432c:	jmp    45a8 <botlish_fn_46+0x3a8>
    4331:	mov    rcx,QWORD PTR [rsp+0x28]
    4336:	mov    rdx,r15
    4339:	mov    rdi,rbx
    433c:	call   4341 <botlish_fn_46+0x141>
			433d: R_X86_64_PLT32	rt_mutarray_set-0x4
    4341:	test   rax,rax
    4344:	je     45a8 <botlish_fn_46+0x3a8>
    434a:	mov    rsi,r12
    434d:	mov    rdi,rbx
    4350:	call   4355 <botlish_fn_46+0x155>
			4351: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    4355:	test   rax,rax
    4358:	je     45a8 <botlish_fn_46+0x3a8>
    435e:	xor    esi,esi
    4360:	test   rax,0x7
    4366:	jne    4378 <botlish_fn_46+0x178>
    436c:	movzx  rcx,BYTE PTR [rax]
    4370:	rex cmp cl,0x8
    4374:	sete   sil
    4378:	test   sil,sil
    437b:	jne    439d <botlish_fn_46+0x19d>
    4381:	mov    rdi,rbx
    4384:	mov    rsi,QWORD PTR [rdi+0x10]
    4388:	mov    rcx,QWORD PTR [rsi]
    438b:	mov    edx,0x8
    4390:	mov    rsi,rax
    4393:	call   4398 <botlish_fn_46+0x198>
			4394: R_X86_64_PLT32	rt_type_error-0x4
    4398:	jmp    45a8 <botlish_fn_46+0x3a8>
    439d:	mov    rcx,r14
    43a0:	mov    rdx,r15
    43a3:	mov    rsi,rax
    43a6:	mov    rdi,rbx
    43a9:	call   43ae <botlish_fn_46+0x1ae>
			43aa: R_X86_64_PLT32	rt_mutarray_set-0x4
    43ae:	test   rax,rax
    43b1:	je     45a8 <botlish_fn_46+0x3a8>
    43b7:	mov    QWORD PTR [rsp+0x10],0x7
    43c0:	mov    rsi,r12
    43c3:	mov    rdi,rbx
    43c6:	call   43cb <botlish_fn_46+0x1cb>
			43c7: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    43cb:	test   rax,rax
    43ce:	je     45a8 <botlish_fn_46+0x3a8>
    43d4:	mov    QWORD PTR [rsp+0x18],rax
    43d9:	mov    QWORD PTR [rsp+0x20],0x3
    43e2:	mov    ecx,0x1
    43e7:	test   rax,0x1
    43ed:	je     43fb <botlish_fn_46+0x1fb>
    43f3:	mov    rsi,rax
    43f6:	jmp    441f <botlish_fn_46+0x21f>
    43fb:	xor    ecx,ecx
    43fd:	test   rax,0x7
    4403:	je     4411 <botlish_fn_46+0x211>
    4409:	mov    rsi,rax
    440c:	jmp    441f <botlish_fn_46+0x21f>
    4411:	movzx  rcx,BYTE PTR [rax]
    4415:	mov    rsi,rax
    4418:	rex cmp cl,0x1
    441c:	sete   cl
    441f:	test   cl,cl
    4421:	jne    443f <botlish_fn_46+0x23f>
    4427:	mov    rdi,rbx
    442a:	mov    rax,QWORD PTR [rdi+0x10]
    442e:	mov    rcx,QWORD PTR [rax+0x38]
    4432:	xor    rdx,rdx
    4435:	call   443a <botlish_fn_46+0x23a>
			4436: R_X86_64_PLT32	rt_type_error-0x4
    443a:	jmp    45a8 <botlish_fn_46+0x3a8>
    443f:	test   rsi,0x1
    4446:	je     445e <botlish_fn_46+0x25e>
    444c:	mov    rcx,rsi
    444f:	add    rcx,0x2
    4453:	seto   al
    4456:	test   al,al
    4458:	je     446e <botlish_fn_46+0x26e>
    445e:	mov    edx,0x3
    4463:	mov    rdi,rbx
    4466:	call   446b <botlish_fn_46+0x26b>
			4467: R_X86_64_PLT32	rt_int_add-0x4
    446b:	mov    rcx,rax
    446e:	mov    edx,0x7
    4473:	mov    rsi,r12
    4476:	mov    rdi,rbx
    4479:	call   447e <botlish_fn_46+0x27e>
			447a: R_X86_64_PLT32	rt_mutarray_set-0x4
    447e:	test   rax,rax
    4481:	je     45a8 <botlish_fn_46+0x3a8>
    4487:	mov    rax,r13
    448a:	test   rax,0x1
    4490:	jne    44b4 <botlish_fn_46+0x2b4>
    4496:	mov    edx,0x5
    449b:	mov    rsi,r13
    449e:	mov    rdi,rbx
    44a1:	call   44a6 <botlish_fn_46+0x2a6>
			44a2: R_X86_64_PLT32	rt_value_eq-0x4
    44a6:	test   rax,rax
    44a9:	je     45a8 <botlish_fn_46+0x3a8>
    44af:	jmp    44c8 <botlish_fn_46+0x2c8>
    44b4:	mov    rsi,r13
    44b7:	mov    eax,0x2
    44bc:	cmp    rsi,0x5
    44c0:	cmove  rax,QWORD PTR [rip+0x130]        # 45f8 <botlish_fn_46+0x3f8>
    44c8:	cmp    rax,0x6
    44cc:	jne    45cd <botlish_fn_46+0x3cd>
    44d2:	mov    QWORD PTR [rsp+0x8],0x9
    44db:	mov    rsi,r12
    44de:	mov    rdi,rbx
    44e1:	call   44e6 <botlish_fn_46+0x2e6>
			44e2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    44e6:	test   rax,rax
    44e9:	je     45a8 <botlish_fn_46+0x3a8>
    44ef:	mov    QWORD PTR [rsp+0x10],rax
    44f4:	mov    QWORD PTR [rsp+0x18],0x3
    44fd:	mov    ecx,0x1
    4502:	test   rax,0x1
    4508:	je     4516 <botlish_fn_46+0x316>
    450e:	mov    rsi,rax
    4511:	jmp    453a <botlish_fn_46+0x33a>
    4516:	xor    ecx,ecx
    4518:	test   rax,0x7
    451e:	je     452c <botlish_fn_46+0x32c>
    4524:	mov    rsi,rax
    4527:	jmp    453a <botlish_fn_46+0x33a>
    452c:	movzx  rcx,BYTE PTR [rax]
    4530:	mov    rsi,rax
    4533:	rex cmp cl,0x1
    4537:	sete   cl
    453a:	test   cl,cl
    453c:	jne    455a <botlish_fn_46+0x35a>
    4542:	mov    rdi,rbx
    4545:	mov    rcx,QWORD PTR [rdi+0x10]
    4549:	mov    rcx,QWORD PTR [rcx+0x48]
    454d:	xor    rdx,rdx
    4550:	call   4555 <botlish_fn_46+0x355>
			4551: R_X86_64_PLT32	rt_type_error-0x4
    4555:	jmp    45a8 <botlish_fn_46+0x3a8>
    455a:	test   rsi,0x1
    4561:	je     457f <botlish_fn_46+0x37f>
    4567:	mov    r8,rsi
    456a:	sub    r8,0x3
    456e:	seto   dil
    4572:	lea    rcx,[r8+0x1]
    4576:	test   dil,dil
    4579:	je     458f <botlish_fn_46+0x38f>
    457f:	mov    edx,0x3
    4584:	mov    rdi,rbx
    4587:	call   458c <botlish_fn_46+0x38c>
			4588: R_X86_64_PLT32	rt_int_sub-0x4
    458c:	mov    rcx,rax
    458f:	mov    edx,0x9
    4594:	mov    rsi,r12
    4597:	mov    rdi,rbx
    459a:	call   459f <botlish_fn_46+0x39f>
			459b: R_X86_64_PLT32	rt_mutarray_set-0x4
    459f:	test   rax,rax
    45a2:	jne    45cd <botlish_fn_46+0x3cd>
    45a8:	xor    rax,rax
    45ab:	mov    rbx,QWORD PTR [rsp+0x40]
    45b0:	mov    r12,QWORD PTR [rsp+0x48]
    45b5:	mov    r13,QWORD PTR [rsp+0x50]
    45ba:	mov    r14,QWORD PTR [rsp+0x58]
    45bf:	mov    r15,QWORD PTR [rsp+0x60]
    45c4:	add    rsp,0x70
    45c8:	mov    rsp,rbp
    45cb:	pop    rbp
    45cc:	ret
    45cd:	mov    eax,0xa
    45d2:	mov    rbx,QWORD PTR [rsp+0x40]
    45d7:	mov    r12,QWORD PTR [rsp+0x48]
    45dc:	mov    r13,QWORD PTR [rsp+0x50]
    45e1:	mov    r14,QWORD PTR [rsp+0x58]
    45e6:	mov    r15,QWORD PTR [rsp+0x60]
    45eb:	add    rsp,0x70
    45ef:	mov    rsp,rbp
    45f2:	pop    rbp
    45f3:	ret
    45f4:	add    BYTE PTR [rax],al
    45f6:	add    BYTE PTR [rax],al
    45f8:	(bad)
    45f9:	add    BYTE PTR [rax],al
    45fb:	add    BYTE PTR [rax],al
    45fd:	add    BYTE PTR [rax],al
	...

0000000000004600 <botlish_entry_46: ht_place<mutarray, int, str, str>>:
    4600:	push   rbp
    4601:	mov    rbp,rsp
    4604:	mov    rsi,QWORD PTR [rdx]
    4607:	mov    r9,QWORD PTR [rdx+0x8]
    460b:	mov    rcx,QWORD PTR [rdx+0x10]
    460f:	mov    r8,QWORD PTR [rdx+0x18]
    4613:	mov    rdx,r9
    4616:	call   461b <botlish_entry_46+0x1b>
			4617: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    461b:	mov    rsp,rbp
    461e:	pop    rbp
    461f:	ret

0000000000004620 <botlish_fn_47: ht_set<mutarray, str, str>>:
    4620:	push   rbp
    4621:	mov    rbp,rsp
    4624:	sub    rsp,0x60
    4628:	mov    QWORD PTR [rsp+0x30],rbx
    462d:	mov    QWORD PTR [rsp+0x38],r12
    4632:	mov    QWORD PTR [rsp+0x40],r13
    4637:	mov    QWORD PTR [rsp+0x48],r14
    463c:	mov    QWORD PTR [rsp+0x50],r15
    4641:	mov    rbx,rdi
    4644:	mov    r13,rdx
    4647:	mov    QWORD PTR [rsp],rsi
    464b:	mov    r14,rsi
    464e:	mov    QWORD PTR [rsp+0x8],rdx
    4653:	mov    QWORD PTR [rsp+0x10],rcx
    4658:	mov    r12,rcx
    465b:	mov    rdx,r13
    465e:	mov    rsi,r14
    4661:	mov    rdi,rbx
    4664:	call   4669 <botlish_fn_47+0x49>
			4665: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    4669:	test   rax,rax
    466c:	je     48d6 <botlish_fn_47+0x2b6>
    4672:	mov    QWORD PTR [rsp+0x18],rax
    4677:	mov    rcx,rax
    467a:	mov    r8,0xffffffffffffffff
    4681:	mov    QWORD PTR [rsp+0x28],r8
    4686:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    468f:	mov    rdx,r13
    4692:	mov    rsi,r14
    4695:	mov    rdi,rbx
    4698:	call   469d <botlish_fn_47+0x7d>
			4699: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    469d:	mov    rcx,rax
    46a0:	mov    r15,rax
    46a3:	test   rax,rcx
    46a6:	je     48d6 <botlish_fn_47+0x2b6>
    46ac:	mov    rax,r15
    46af:	mov    QWORD PTR [rsp+0x18],rax
    46b4:	mov    rsi,r14
    46b7:	mov    rdi,rbx
    46ba:	call   46bf <botlish_fn_47+0x9f>
			46bb: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    46bf:	test   rax,rax
    46c2:	je     48d6 <botlish_fn_47+0x2b6>
    46c8:	xor    ecx,ecx
    46ca:	test   rax,0x7
    46d0:	je     46de <botlish_fn_47+0xbe>
    46d6:	mov    r8,rax
    46d9:	jmp    46ec <botlish_fn_47+0xcc>
    46de:	movzx  rcx,BYTE PTR [rax]
    46e2:	mov    r8,rax
    46e5:	rex cmp cl,0x8
    46e9:	sete   cl
    46ec:	test   cl,cl
    46ee:	jne    4711 <botlish_fn_47+0xf1>
    46f4:	mov    rdi,rbx
    46f7:	mov    rsi,QWORD PTR [rdi+0x10]
    46fb:	mov    rcx,QWORD PTR [rsi+0x30]
    46ff:	mov    edx,0x8
    4704:	mov    rsi,r8
    4707:	call   470c <botlish_fn_47+0xec>
			4708: R_X86_64_PLT32	rt_type_error-0x4
    470c:	jmp    48d6 <botlish_fn_47+0x2b6>
    4711:	mov    rsi,r8
    4714:	mov    rdx,r15
    4717:	mov    rdi,rbx
    471a:	call   471f <botlish_fn_47+0xff>
			471b: R_X86_64_PLT32	rt_mutarray_get-0x4
    471f:	test   rax,rax
    4722:	je     48d6 <botlish_fn_47+0x2b6>
    4728:	test   rax,0x1
    472e:	mov    rsi,rax
    4731:	jne    4752 <botlish_fn_47+0x132>
    4737:	mov    edx,0x3
    473c:	mov    rdi,rbx
    473f:	call   4744 <botlish_fn_47+0x124>
			4740: R_X86_64_PLT32	rt_value_eq-0x4
    4744:	test   rax,rax
    4747:	je     48d6 <botlish_fn_47+0x2b6>
    474d:	jmp    4763 <botlish_fn_47+0x143>
    4752:	mov    eax,0x2
    4757:	cmp    rsi,0x3
    475b:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4928 <botlish_fn_47+0x308>
    4763:	cmp    rax,0x6
    4767:	je     4866 <botlish_fn_47+0x246>
    476d:	mov    rsi,r14
    4770:	mov    rdi,rbx
    4773:	call   4778 <botlish_fn_47+0x158>
			4774: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    4778:	test   rax,rax
    477b:	je     48d6 <botlish_fn_47+0x2b6>
    4781:	cmp    rax,0x6
    4785:	je     47ca <botlish_fn_47+0x1aa>
    478b:	mov    rcx,r13
    478e:	mov    rdx,r15
    4791:	mov    rsi,r14
    4794:	mov    rdi,rbx
    4797:	mov    r8,r12
    479a:	call   479f <botlish_fn_47+0x17f>
			479b: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    479f:	test   rax,rax
    47a2:	je     48d6 <botlish_fn_47+0x2b6>
    47a8:	mov    rbx,QWORD PTR [rsp+0x30]
    47ad:	mov    r12,QWORD PTR [rsp+0x38]
    47b2:	mov    r13,QWORD PTR [rsp+0x40]
    47b7:	mov    r14,QWORD PTR [rsp+0x48]
    47bc:	mov    r15,QWORD PTR [rsp+0x50]
    47c1:	add    rsp,0x60
    47c5:	mov    rsp,rbp
    47c8:	pop    rbp
    47c9:	ret
    47ca:	mov    rsi,r14
    47cd:	mov    rdi,rbx
    47d0:	call   47d5 <botlish_fn_47+0x1b5>
			47d1: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    47d5:	test   rax,rax
    47d8:	je     48d6 <botlish_fn_47+0x2b6>
    47de:	mov    rdx,r13
    47e1:	mov    rsi,r14
    47e4:	mov    rdi,rbx
    47e7:	call   47ec <botlish_fn_47+0x1cc>
			47e8: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    47ec:	test   rax,rax
    47ef:	je     48d6 <botlish_fn_47+0x2b6>
    47f5:	mov    QWORD PTR [rsp+0x18],rax
    47fa:	mov    rcx,rax
    47fd:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4806:	mov    r8,QWORD PTR [rsp+0x28]
    480b:	mov    rdx,r13
    480e:	mov    rsi,r14
    4811:	mov    rdi,rbx
    4814:	call   4819 <botlish_fn_47+0x1f9>
			4815: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4819:	test   rax,rax
    481c:	je     48d6 <botlish_fn_47+0x2b6>
    4822:	mov    QWORD PTR [rsp+0x18],rax
    4827:	mov    rcx,r13
    482a:	mov    rdx,rax
    482d:	mov    rsi,r14
    4830:	mov    rdi,rbx
    4833:	mov    r8,r12
    4836:	call   483b <botlish_fn_47+0x21b>
			4837: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    483b:	test   rax,rax
    483e:	je     48d6 <botlish_fn_47+0x2b6>
    4844:	mov    rbx,QWORD PTR [rsp+0x30]
    4849:	mov    r12,QWORD PTR [rsp+0x38]
    484e:	mov    r13,QWORD PTR [rsp+0x40]
    4853:	mov    r14,QWORD PTR [rsp+0x48]
    4858:	mov    r15,QWORD PTR [rsp+0x50]
    485d:	add    rsp,0x60
    4861:	mov    rsp,rbp
    4864:	pop    rbp
    4865:	ret
    4866:	mov    rsi,r14
    4869:	mov    rdi,rbx
    486c:	call   4871 <botlish_fn_47+0x251>
			486d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    4871:	test   rax,rax
    4874:	je     48d6 <botlish_fn_47+0x2b6>
    487a:	xor    ecx,ecx
    487c:	test   rax,0x7
    4882:	je     4890 <botlish_fn_47+0x270>
    4888:	mov    rsi,rax
    488b:	jmp    489e <botlish_fn_47+0x27e>
    4890:	movzx  rcx,BYTE PTR [rax]
    4894:	mov    rsi,rax
    4897:	rex cmp cl,0x8
    489b:	sete   cl
    489e:	test   cl,cl
    48a0:	jne    48bf <botlish_fn_47+0x29f>
    48a6:	mov    rdi,rbx
    48a9:	mov    rax,QWORD PTR [rdi+0x10]
    48ad:	mov    rcx,QWORD PTR [rax]
    48b0:	mov    edx,0x8
    48b5:	call   48ba <botlish_fn_47+0x29a>
			48b6: R_X86_64_PLT32	rt_type_error-0x4
    48ba:	jmp    48d6 <botlish_fn_47+0x2b6>
    48bf:	mov    rcx,r12
    48c2:	mov    rdx,r15
    48c5:	mov    rdi,rbx
    48c8:	call   48cd <botlish_fn_47+0x2ad>
			48c9: R_X86_64_PLT32	rt_mutarray_set-0x4
    48cd:	test   rax,rax
    48d0:	jne    48fb <botlish_fn_47+0x2db>
    48d6:	xor    rax,rax
    48d9:	mov    rbx,QWORD PTR [rsp+0x30]
    48de:	mov    r12,QWORD PTR [rsp+0x38]
    48e3:	mov    r13,QWORD PTR [rsp+0x40]
    48e8:	mov    r14,QWORD PTR [rsp+0x48]
    48ed:	mov    r15,QWORD PTR [rsp+0x50]
    48f2:	add    rsp,0x60
    48f6:	mov    rsp,rbp
    48f9:	pop    rbp
    48fa:	ret
    48fb:	mov    eax,0xa
    4900:	mov    rbx,QWORD PTR [rsp+0x30]
    4905:	mov    r12,QWORD PTR [rsp+0x38]
    490a:	mov    r13,QWORD PTR [rsp+0x40]
    490f:	mov    r14,QWORD PTR [rsp+0x48]
    4914:	mov    r15,QWORD PTR [rsp+0x50]
    4919:	add    rsp,0x60
    491d:	mov    rsp,rbp
    4920:	pop    rbp
    4921:	ret
    4922:	add    BYTE PTR [rax],al
    4924:	add    BYTE PTR [rax],al
    4926:	add    BYTE PTR [rax],al
    4928:	(bad)
    4929:	add    BYTE PTR [rax],al
    492b:	add    BYTE PTR [rax],al
    492d:	add    BYTE PTR [rax],al
	...

0000000000004930 <botlish_entry_47: ht_set<mutarray, str, str>>:
    4930:	push   rbp
    4931:	mov    rbp,rsp
    4934:	mov    rsi,QWORD PTR [rdx]
    4937:	mov    r8,QWORD PTR [rdx+0x8]
    493b:	mov    rcx,QWORD PTR [rdx+0x10]
    493f:	mov    rdx,r8
    4942:	call   4947 <botlish_entry_47+0x17>
			4943: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4947:	mov    rsp,rbp
    494a:	pop    rbp
    494b:	ret

000000000000494c <botlish_fn_48: row_new<bool, int>>:
    494c:	push   rbp
    494d:	mov    rbp,rsp
    4950:	sub    rsp,0x10
    4954:	mov    QWORD PTR [rsp],rdx
    4958:	mov    r8,rdx
    495b:	cmp    rsi,0x6
    495f:	je     497c <botlish_fn_48+0x30>
    4965:	call   496a <botlish_fn_48+0x1e>
			4966: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    496a:	test   rax,rax
    496d:	je     498d <botlish_fn_48+0x41>
    4973:	add    rsp,0x10
    4977:	mov    rsp,rbp
    497a:	pop    rbp
    497b:	ret
    497c:	mov    rsi,r8
    497f:	call   4984 <botlish_fn_48+0x38>
			4980: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    4984:	test   rax,rax
    4987:	jne    4999 <botlish_fn_48+0x4d>
    498d:	xor    rax,rax
    4990:	add    rsp,0x10
    4994:	mov    rsp,rbp
    4997:	pop    rbp
    4998:	ret
    4999:	add    rsp,0x10
    499d:	mov    rsp,rbp
    49a0:	pop    rbp
    49a1:	ret

00000000000049a2 <botlish_entry_48: row_new<bool, int>>:
    49a2:	push   rbp
    49a3:	mov    rbp,rsp
    49a6:	mov    rsi,QWORD PTR [rdx]
    49a9:	mov    rdx,QWORD PTR [rdx+0x8]
    49ad:	call   49b2 <botlish_entry_48+0x10>
			49ae: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    49b2:	mov    rsp,rbp
    49b5:	pop    rbp
    49b6:	ret

00000000000049b7 <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    49b7:	push   rbp
    49b8:	mov    rbp,rsp
    49bb:	sub    rsp,0x70
    49bf:	mov    QWORD PTR [rsp+0x40],rbx
    49c4:	mov    QWORD PTR [rsp+0x48],r12
    49c9:	mov    QWORD PTR [rsp+0x50],r13
    49ce:	mov    QWORD PTR [rsp+0x58],r14
    49d3:	mov    QWORD PTR [rsp+0x60],r15
    49d8:	mov    QWORD PTR [rsp+0x28],rdi
    49dd:	mov    QWORD PTR [rsp],rsi
    49e1:	mov    r14,rsi
    49e4:	mov    QWORD PTR [rsp+0x8],rdx
    49e9:	mov    QWORD PTR [rsp+0x10],rcx
    49ee:	mov    r13,rcx
    49f1:	sar    r8,1
    49f4:	mov    rbx,r8
    49f7:	mov    r15,r9
    49fa:	cmp    rbx,r15
    49fd:	jge    4b08 <botlish_fn_49+0x151>
    4a03:	mov    r12,rdx
    4a06:	mov    rdx,QWORD PTR [r12+0x8]
    4a0b:	mov    rcx,rbx
    4a0e:	shl    rcx,1
    4a11:	or     rcx,0x1
    4a15:	sar    rcx,1
    4a18:	cmp    rcx,rdx
    4a1b:	jb     4a49 <botlish_fn_49+0x92>
    4a21:	mov    rdx,rbx
    4a24:	shl    rdx,1
    4a27:	or     rdx,0x1
    4a2b:	mov    rsi,r12
    4a2e:	mov    rdi,QWORD PTR [rsp+0x28]
    4a33:	call   4a38 <botlish_fn_49+0x81>
			4a34: R_X86_64_PLT32	rt_list_get-0x4
    4a38:	test   rax,rax
    4a3b:	je     4ac6 <botlish_fn_49+0x10f>
    4a41:	mov    rdx,rax
    4a44:	jmp    4a52 <botlish_fn_49+0x9b>
    4a49:	mov    rax,QWORD PTR [r12+0x10]
    4a4e:	mov    rdx,QWORD PTR [rax+rcx*8]
    4a52:	mov    QWORD PTR [rsp+0x18],rdx
    4a57:	mov    QWORD PTR [rsp+0x30],rdx
    4a5c:	mov    rax,QWORD PTR [r13+0x8]
    4a60:	mov    rcx,rbx
    4a63:	shl    rcx,1
    4a66:	or     rcx,0x1
    4a6a:	sar    rcx,1
    4a6d:	cmp    rcx,rax
    4a70:	jb     4a9e <botlish_fn_49+0xe7>
    4a76:	mov    rdx,rbx
    4a79:	shl    rdx,1
    4a7c:	or     rdx,0x1
    4a80:	mov    rsi,r13
    4a83:	mov    rdi,QWORD PTR [rsp+0x28]
    4a88:	call   4a8d <botlish_fn_49+0xd6>
			4a89: R_X86_64_PLT32	rt_list_get-0x4
    4a8d:	test   rax,rax
    4a90:	je     4ac6 <botlish_fn_49+0x10f>
    4a96:	mov    rcx,rax
    4a99:	jmp    4aa6 <botlish_fn_49+0xef>
    4a9e:	mov    rax,QWORD PTR [r13+0x10]
    4aa2:	mov    rcx,QWORD PTR [rax+rcx*8]
    4aa6:	mov    QWORD PTR [rsp+0x20],rcx
    4aab:	mov    rdx,QWORD PTR [rsp+0x30]
    4ab0:	mov    rsi,r14
    4ab3:	mov    rdi,QWORD PTR [rsp+0x28]
    4ab8:	call   4abd <botlish_fn_49+0x106>
			4ab9: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4abd:	test   rax,rax
    4ac0:	jne    4aeb <botlish_fn_49+0x134>
    4ac6:	xor    rax,rax
    4ac9:	mov    rbx,QWORD PTR [rsp+0x40]
    4ace:	mov    r12,QWORD PTR [rsp+0x48]
    4ad3:	mov    r13,QWORD PTR [rsp+0x50]
    4ad8:	mov    r14,QWORD PTR [rsp+0x58]
    4add:	mov    r15,QWORD PTR [rsp+0x60]
    4ae2:	add    rsp,0x70
    4ae6:	mov    rsp,rbp
    4ae9:	pop    rbp
    4aea:	ret
    4aeb:	mov    QWORD PTR [rsp],r14
    4aef:	mov    QWORD PTR [rsp+0x8],r12
    4af4:	mov    QWORD PTR [rsp+0x10],r13
    4af9:	add    rbx,0x1
    4b00:	mov    rdx,r12
    4b03:	jmp    49fa <botlish_fn_49+0x43>
    4b08:	mov    rax,r14
    4b0b:	mov    rbx,QWORD PTR [rsp+0x40]
    4b10:	mov    r12,QWORD PTR [rsp+0x48]
    4b15:	mov    r13,QWORD PTR [rsp+0x50]
    4b1a:	mov    r14,QWORD PTR [rsp+0x58]
    4b1f:	mov    r15,QWORD PTR [rsp+0x60]
    4b24:	add    rsp,0x70
    4b28:	mov    rsp,rbp
    4b2b:	pop    rbp
    4b2c:	ret

0000000000004b2d <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4b2d:	push   rbp
    4b2e:	mov    rbp,rsp
    4b31:	mov    rsi,QWORD PTR [rdx]
    4b34:	mov    r10,QWORD PTR [rdx+0x8]
    4b38:	mov    rcx,QWORD PTR [rdx+0x10]
    4b3c:	mov    r8,QWORD PTR [rdx+0x18]
    4b40:	mov    r9,QWORD PTR [rdx+0x20]
    4b44:	sar    r9,1
    4b47:	mov    rdx,r10
    4b4a:	call   4b4f <botlish_entry_49+0x22>
			4b4b: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4b4f:	mov    rsp,rbp
    4b52:	pop    rbp
    4b53:	ret

0000000000004b54 <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4b54:	push   rbp
    4b55:	mov    rbp,rsp
    4b58:	sub    rsp,0x50
    4b5c:	mov    QWORD PTR [rsp+0x20],rbx
    4b61:	mov    QWORD PTR [rsp+0x28],r12
    4b66:	mov    QWORD PTR [rsp+0x30],r13
    4b6b:	mov    QWORD PTR [rsp+0x38],r14
    4b70:	mov    QWORD PTR [rsp+0x40],r15
    4b75:	mov    r12,rdi
    4b78:	mov    QWORD PTR [rsp],rsi
    4b7c:	mov    r15,rsi
    4b7f:	mov    QWORD PTR [rsp+0x8],rdx
    4b84:	mov    QWORD PTR [rsp+0x10],rcx
    4b89:	mov    r13,rcx
    4b8c:	mov    QWORD PTR [rsp+0x18],r8
    4b91:	mov    rsi,r8
    4b94:	mov    rdi,r12
    4b97:	call   4b9c <botlish_fn_50+0x48>
			4b98: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4b9c:	test   rax,rax
    4b9f:	je     4be9 <botlish_fn_50+0x95>
    4ba5:	mov    QWORD PTR [rsp+0x8],rax
    4baa:	mov    r14,rax
    4bad:	mov    ebx,0x1
    4bb2:	mov    QWORD PTR [rsp+0x18],0x1
    4bbb:	mov    rsi,r13
    4bbe:	mov    rdi,r12
    4bc1:	call   4bc6 <botlish_fn_50+0x72>
			4bc2: R_X86_64_PLT32	rt_list_len-0x4
    4bc6:	mov    r9,rax
    4bc9:	sar    r9,1
    4bcc:	mov    rcx,r13
    4bcf:	mov    rdx,r15
    4bd2:	mov    rsi,r14
    4bd5:	mov    rdi,r12
    4bd8:	mov    r8,rbx
    4bdb:	call   4be0 <botlish_fn_50+0x8c>
			4bdc: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4be0:	test   rax,rax
    4be3:	jne    4c0e <botlish_fn_50+0xba>
    4be9:	xor    rax,rax
    4bec:	mov    rbx,QWORD PTR [rsp+0x20]
    4bf1:	mov    r12,QWORD PTR [rsp+0x28]
    4bf6:	mov    r13,QWORD PTR [rsp+0x30]
    4bfb:	mov    r14,QWORD PTR [rsp+0x38]
    4c00:	mov    r15,QWORD PTR [rsp+0x40]
    4c05:	add    rsp,0x50
    4c09:	mov    rsp,rbp
    4c0c:	pop    rbp
    4c0d:	ret
    4c0e:	mov    rbx,QWORD PTR [rsp+0x20]
    4c13:	mov    r12,QWORD PTR [rsp+0x28]
    4c18:	mov    r13,QWORD PTR [rsp+0x30]
    4c1d:	mov    r14,QWORD PTR [rsp+0x38]
    4c22:	mov    r15,QWORD PTR [rsp+0x40]
    4c27:	add    rsp,0x50
    4c2b:	mov    rsp,rbp
    4c2e:	pop    rbp
    4c2f:	ret

0000000000004c30 <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4c30:	push   rbp
    4c31:	mov    rbp,rsp
    4c34:	mov    rsi,QWORD PTR [rdx]
    4c37:	mov    r9,QWORD PTR [rdx+0x8]
    4c3b:	mov    rcx,QWORD PTR [rdx+0x10]
    4c3f:	mov    r8,QWORD PTR [rdx+0x18]
    4c43:	mov    rdx,r9
    4c46:	call   4c4b <botlish_entry_50+0x1b>
			4c47: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4c4b:	mov    rsp,rbp
    4c4e:	pop    rbp
    4c4f:	ret

0000000000004c50 <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4c50:	push   rbp
    4c51:	mov    rbp,rsp
    4c54:	sub    rsp,0x90
    4c5b:	mov    QWORD PTR [rsp+0x60],rbx
    4c60:	mov    QWORD PTR [rsp+0x68],r12
    4c65:	mov    QWORD PTR [rsp+0x70],r13
    4c6a:	mov    QWORD PTR [rsp+0x78],r14
    4c6f:	mov    QWORD PTR [rsp+0x80],r15
    4c77:	mov    r13,r8
    4c7a:	mov    QWORD PTR [rsp+0x38],rdi
    4c7f:	mov    rdi,QWORD PTR [rbp+0x10]
    4c83:	mov    r15,QWORD PTR [rbp+0x18]
    4c87:	mov    QWORD PTR [rsp+0x28],0x0
    4c90:	mov    QWORD PTR [rsp+0x30],0x0
    4c99:	mov    QWORD PTR [rsp],rsi
    4c9d:	mov    QWORD PTR [rsp+0x8],rcx
    4ca2:	mov    r14,rcx
    4ca5:	mov    QWORD PTR [rsp+0x10],r9
    4caa:	mov    QWORD PTR [rsp+0x18],rdi
    4caf:	mov    QWORD PTR [rsp+0x20],r15
    4cb4:	sar    rdx,1
    4cb7:	mov    r12,rdx
    4cba:	mov    rbx,rsi
    4cbd:	mov    QWORD PTR [rsp+0x40],r9
    4cc2:	mov    QWORD PTR [rsp+0x48],rdi
    4cc7:	mov    rsi,rbx
    4cca:	mov    rdi,QWORD PTR [rsp+0x38]
    4ccf:	call   4cd4 <botlish_fn_51+0x84>
			4cd0: R_X86_64_PLT32	rt_list_len-0x4
    4cd4:	sar    rax,1
    4cd7:	cmp    r12,rax
    4cda:	jge    4e05 <botlish_fn_51+0x1b5>
    4ce0:	mov    rax,r13
    4ce3:	or     rax,0x1
    4ce7:	mov    QWORD PTR [rsp+0x28],rax
    4cec:	mov    rcx,QWORD PTR [rbx+0x8]
    4cf0:	mov    rax,r12
    4cf3:	shl    rax,1
    4cf6:	or     rax,0x1
    4cfa:	sar    rax,1
    4cfd:	cmp    rax,rcx
    4d00:	jb     4d2e <botlish_fn_51+0xde>
    4d06:	mov    rdx,r12
    4d09:	shl    rdx,1
    4d0c:	or     rdx,0x1
    4d10:	mov    rsi,rbx
    4d13:	mov    rdi,QWORD PTR [rsp+0x38]
    4d18:	call   4d1d <botlish_fn_51+0xcd>
			4d19: R_X86_64_PLT32	rt_list_get-0x4
    4d1d:	test   rax,rax
    4d20:	je     4e22 <botlish_fn_51+0x1d2>
    4d26:	mov    rcx,rax
    4d29:	jmp    4d36 <botlish_fn_51+0xe6>
    4d2e:	mov    rcx,QWORD PTR [rbx+0x10]
    4d32:	mov    rcx,QWORD PTR [rcx+rax*8]
    4d36:	mov    QWORD PTR [rsp+0x30],rcx
    4d3b:	mov    rdx,r13
    4d3e:	or     rdx,0x1
    4d42:	mov    rsi,r14
    4d45:	mov    rdi,QWORD PTR [rsp+0x38]
    4d4a:	mov    r8,r15
    4d4d:	call   4d52 <botlish_fn_51+0x102>
			4d4e: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4d52:	test   rax,rax
    4d55:	je     4e22 <botlish_fn_51+0x1d2>
    4d5b:	mov    QWORD PTR [rsp+0x28],rax
    4d60:	mov    rcx,rax
    4d63:	mov    rsi,QWORD PTR [rsp+0x40]
    4d68:	mov    rdx,QWORD PTR [rsp+0x48]
    4d6d:	mov    rdi,QWORD PTR [rsp+0x38]
    4d72:	call   4d77 <botlish_fn_51+0x127>
			4d73: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4d77:	test   rax,rax
    4d7a:	je     4e22 <botlish_fn_51+0x1d2>
    4d80:	mov    QWORD PTR [rsp+0x10],rax
    4d85:	mov    QWORD PTR [rsp+0x50],rax
    4d8a:	mov    QWORD PTR [rsp+0x28],0x3
    4d93:	mov    rsi,QWORD PTR [rsp+0x48]
    4d98:	test   rsi,0x1
    4d9f:	je     4dbe <botlish_fn_51+0x16e>
    4da5:	mov    rsi,QWORD PTR [rsp+0x48]
    4daa:	mov    rax,rsi
    4dad:	add    rax,0x2
    4db1:	seto   r10b
    4db5:	test   r10b,r10b
    4db8:	je     4dd2 <botlish_fn_51+0x182>
    4dbe:	mov    edx,0x3
    4dc3:	mov    rsi,QWORD PTR [rsp+0x48]
    4dc8:	mov    rdi,QWORD PTR [rsp+0x38]
    4dcd:	call   4dd2 <botlish_fn_51+0x182>
			4dce: R_X86_64_PLT32	rt_int_add-0x4
    4dd2:	mov    QWORD PTR [rsp],rbx
    4dd6:	mov    QWORD PTR [rsp+0x8],r14
    4ddb:	mov    rcx,QWORD PTR [rsp+0x50]
    4de0:	mov    QWORD PTR [rsp+0x10],rcx
    4de5:	mov    QWORD PTR [rsp+0x18],rax
    4dea:	mov    QWORD PTR [rsp+0x20],r15
    4def:	add    r12,0x1
    4df6:	mov    QWORD PTR [rsp+0x40],rcx
    4dfb:	mov    QWORD PTR [rsp+0x48],rax
    4e00:	jmp    4cc7 <botlish_fn_51+0x77>
    4e05:	mov    rdx,QWORD PTR [rsp+0x48]
    4e0a:	mov    rsi,QWORD PTR [rsp+0x40]
    4e0f:	mov    rdi,QWORD PTR [rsp+0x38]
    4e14:	call   4e19 <botlish_fn_51+0x1c9>
			4e15: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4e19:	test   rax,rax
    4e1c:	jne    4e4d <botlish_fn_51+0x1fd>
    4e22:	xor    rax,rax
    4e25:	mov    rbx,QWORD PTR [rsp+0x60]
    4e2a:	mov    r12,QWORD PTR [rsp+0x68]
    4e2f:	mov    r13,QWORD PTR [rsp+0x70]
    4e34:	mov    r14,QWORD PTR [rsp+0x78]
    4e39:	mov    r15,QWORD PTR [rsp+0x80]
    4e41:	add    rsp,0x90
    4e48:	mov    rsp,rbp
    4e4b:	pop    rbp
    4e4c:	ret
    4e4d:	mov    rbx,QWORD PTR [rsp+0x60]
    4e52:	mov    r12,QWORD PTR [rsp+0x68]
    4e57:	mov    r13,QWORD PTR [rsp+0x70]
    4e5c:	mov    r14,QWORD PTR [rsp+0x78]
    4e61:	mov    r15,QWORD PTR [rsp+0x80]
    4e69:	add    rsp,0x90
    4e70:	mov    rsp,rbp
    4e73:	pop    rbp
    4e74:	ret

0000000000004e75 <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4e75:	push   rbp
    4e76:	mov    rbp,rsp
    4e79:	sub    rsp,0x10
    4e7d:	mov    rsi,QWORD PTR [rdx]
    4e80:	mov    r10,QWORD PTR [rdx+0x8]
    4e84:	mov    rcx,QWORD PTR [rdx+0x10]
    4e88:	mov    r8,QWORD PTR [rdx+0x18]
    4e8c:	mov    r9,QWORD PTR [rdx+0x20]
    4e90:	mov    r11,QWORD PTR [rdx+0x28]
    4e94:	mov    rax,QWORD PTR [rdx+0x30]
    4e98:	mov    QWORD PTR [rsp],r11
    4e9c:	mov    QWORD PTR [rsp+0x8],rax
    4ea1:	mov    rdx,r10
    4ea4:	call   4ea9 <botlish_entry_51+0x34>
			4ea5: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4ea9:	add    rsp,0x10
    4ead:	mov    rsp,rbp
    4eb0:	pop    rbp
    4eb1:	ret

0000000000004eb2 <botlish_fn_52: csv_records_generic<str, bool>>:
    4eb2:	push   rbp
    4eb3:	mov    rbp,rsp
    4eb6:	sub    rsp,0x80
    4ebd:	mov    QWORD PTR [rsp+0x50],rbx
    4ec2:	mov    QWORD PTR [rsp+0x58],r12
    4ec7:	mov    QWORD PTR [rsp+0x60],r13
    4ecc:	mov    QWORD PTR [rsp+0x68],r14
    4ed1:	mov    QWORD PTR [rsp+0x70],r15
    4ed6:	mov    r12,rdi
    4ed9:	mov    QWORD PTR [rsp+0x20],0x0
    4ee2:	mov    QWORD PTR [rsp+0x28],0x0
    4eeb:	mov    QWORD PTR [rsp+0x30],0x0
    4ef4:	mov    QWORD PTR [rsp+0x38],0x0
    4efd:	mov    QWORD PTR [rsp+0x40],0x0
    4f06:	mov    QWORD PTR [rsp+0x10],rsi
    4f0b:	mov    QWORD PTR [rsp+0x18],rdx
    4f10:	mov    r13,rdx
    4f13:	mov    rdi,r12
    4f16:	call   4f1b <botlish_fn_52+0x69>
			4f17: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4f1b:	mov    rcx,rax
    4f1e:	mov    r15,rax
    4f21:	test   rax,rcx
    4f24:	je     509c <botlish_fn_52+0x1ea>
    4f2a:	mov    rax,r15
    4f2d:	mov    QWORD PTR [rsp+0x10],rax
    4f32:	mov    rsi,r15
    4f35:	mov    rdi,r12
    4f38:	call   4f3d <botlish_fn_52+0x8b>
			4f39: R_X86_64_PLT32	rt_list_len-0x4
    4f3d:	sar    rax,1
    4f40:	cmp    rax,0x1
    4f44:	jle    5085 <botlish_fn_52+0x1d3>
    4f4a:	mov    rax,r15
    4f4d:	mov    rax,QWORD PTR [rax+0x8]
    4f51:	test   rax,rax
    4f54:	jne    4f7b <botlish_fn_52+0xc9>
    4f5a:	mov    edx,0x1
    4f5f:	mov    rsi,r15
    4f62:	mov    rdi,r12
    4f65:	call   4f6a <botlish_fn_52+0xb8>
			4f66: R_X86_64_PLT32	rt_list_get-0x4
    4f6a:	test   rax,rax
    4f6d:	je     509c <botlish_fn_52+0x1ea>
    4f73:	mov    rbx,rax
    4f76:	jmp    4f82 <botlish_fn_52+0xd0>
    4f7b:	mov    rax,QWORD PTR [r15+0x10]
    4f7f:	mov    rbx,QWORD PTR [rax]
    4f82:	mov    QWORD PTR [rsp+0x20],rbx
    4f87:	mov    rsi,rbx
    4f8a:	mov    rdi,r12
    4f8d:	call   4f92 <botlish_fn_52+0xe0>
			4f8e: R_X86_64_PLT32	rt_list_len-0x4
    4f92:	mov    r14,rax
    4f95:	mov    QWORD PTR [rsp+0x48],rbx
    4f9a:	mov    QWORD PTR [rsp+0x28],r14
    4f9f:	mov    rax,QWORD PTR [r15+0x8]
    4fa3:	cmp    rax,0x1
    4fa7:	ja     4fce <botlish_fn_52+0x11c>
    4fad:	mov    edx,0x3
    4fb2:	mov    rsi,r15
    4fb5:	mov    rdi,r12
    4fb8:	call   4fbd <botlish_fn_52+0x10b>
			4fb9: R_X86_64_PLT32	rt_list_get-0x4
    4fbd:	test   rax,rax
    4fc0:	je     509c <botlish_fn_52+0x1ea>
    4fc6:	mov    rcx,rax
    4fc9:	jmp    4fd6 <botlish_fn_52+0x124>
    4fce:	mov    rax,QWORD PTR [r15+0x10]
    4fd2:	mov    rcx,QWORD PTR [rax+0x8]
    4fd6:	mov    QWORD PTR [rsp+0x30],rcx
    4fdb:	mov    rbx,r13
    4fde:	mov    rdx,r14
    4fe1:	mov    rsi,QWORD PTR [rsp+0x48]
    4fe6:	mov    rdi,r12
    4fe9:	mov    r8,rbx
    4fec:	call   4ff1 <botlish_fn_52+0x13f>
			4fed: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4ff1:	mov    r13,r14
    4ff4:	test   rax,rax
    4ff7:	je     509c <botlish_fn_52+0x1ea>
    4ffd:	mov    QWORD PTR [rsp+0x30],rax
    5002:	mov    rsi,rax
    5005:	mov    QWORD PTR [rsp+0x38],0x5
    500e:	mov    rdi,r12
    5011:	call   5016 <botlish_fn_52+0x164>
			5012: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    5016:	test   rax,rax
    5019:	je     509c <botlish_fn_52+0x1ea>
    501f:	mov    QWORD PTR [rsp+0x30],rax
    5024:	mov    r9,rax
    5027:	mov    r10d,0x3
    502d:	mov    QWORD PTR [rsp+0x40],0x3
    5036:	mov    edx,0x5
    503b:	mov    QWORD PTR [rsp],r10
    503f:	mov    QWORD PTR [rsp+0x8],rbx
    5044:	mov    rcx,QWORD PTR [rsp+0x48]
    5049:	mov    rsi,r15
    504c:	mov    rdi,r12
    504f:	mov    r8,r13
    5052:	call   5057 <botlish_fn_52+0x1a5>
			5053: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    5057:	test   rax,rax
    505a:	je     509c <botlish_fn_52+0x1ea>
    5060:	mov    rbx,QWORD PTR [rsp+0x50]
    5065:	mov    r12,QWORD PTR [rsp+0x58]
    506a:	mov    r13,QWORD PTR [rsp+0x60]
    506f:	mov    r14,QWORD PTR [rsp+0x68]
    5074:	mov    r15,QWORD PTR [rsp+0x70]
    5079:	add    rsp,0x80
    5080:	mov    rsp,rbp
    5083:	pop    rbp
    5084:	ret
    5085:	xor    rdx,rdx
    5088:	mov    rdi,r12
    508b:	mov    rsi,rdx
    508e:	call   5093 <botlish_fn_52+0x1e1>
			508f: R_X86_64_PLT32	rt_list_new-0x4
    5093:	test   rax,rax
    5096:	jne    50c4 <botlish_fn_52+0x212>
    509c:	xor    rax,rax
    509f:	mov    rbx,QWORD PTR [rsp+0x50]
    50a4:	mov    r12,QWORD PTR [rsp+0x58]
    50a9:	mov    r13,QWORD PTR [rsp+0x60]
    50ae:	mov    r14,QWORD PTR [rsp+0x68]
    50b3:	mov    r15,QWORD PTR [rsp+0x70]
    50b8:	add    rsp,0x80
    50bf:	mov    rsp,rbp
    50c2:	pop    rbp
    50c3:	ret
    50c4:	mov    rbx,QWORD PTR [rsp+0x50]
    50c9:	mov    r12,QWORD PTR [rsp+0x58]
    50ce:	mov    r13,QWORD PTR [rsp+0x60]
    50d3:	mov    r14,QWORD PTR [rsp+0x68]
    50d8:	mov    r15,QWORD PTR [rsp+0x70]
    50dd:	add    rsp,0x80
    50e4:	mov    rsp,rbp
    50e7:	pop    rbp
    50e8:	ret

00000000000050e9 <botlish_entry_52: csv_records_generic<str, bool>>:
    50e9:	push   rbp
    50ea:	mov    rbp,rsp
    50ed:	mov    rsi,QWORD PTR [rdx]
    50f0:	mov    rdx,QWORD PTR [rdx+0x8]
    50f4:	call   50f9 <botlish_entry_52+0x10>
			50f5: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50f9:	mov    rsp,rbp
    50fc:	pop    rbp
    50fd:	ret

00000000000050fe <botlish_fn_53: csv_records<str>>:
    50fe:	push   rbp
    50ff:	mov    rbp,rsp
    5102:	sub    rsp,0x10
    5106:	mov    QWORD PTR [rsp],rsi
    510a:	mov    edx,0x2
    510f:	mov    QWORD PTR [rsp+0x8],0x2
    5118:	call   511d <botlish_fn_53+0x1f>
			5119: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    511d:	test   rax,rax
    5120:	jne    5132 <botlish_fn_53+0x34>
    5126:	xor    rax,rax
    5129:	add    rsp,0x10
    512d:	mov    rsp,rbp
    5130:	pop    rbp
    5131:	ret
    5132:	add    rsp,0x10
    5136:	mov    rsp,rbp
    5139:	pop    rbp
    513a:	ret

000000000000513b <botlish_entry_53: csv_records<str>>:
    513b:	push   rbp
    513c:	mov    rbp,rsp
    513f:	mov    rsi,QWORD PTR [rdx]
    5142:	call   5147 <botlish_entry_53+0xc>
			5143: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    5147:	mov    rsp,rbp
    514a:	pop    rbp
    514b:	ret

000000000000514c <botlish_fn_54: csv_records_presized<str>>:
    514c:	push   rbp
    514d:	mov    rbp,rsp
    5150:	sub    rsp,0x10
    5154:	mov    QWORD PTR [rsp],rsi
    5158:	mov    edx,0x6
    515d:	mov    QWORD PTR [rsp+0x8],0x6
    5166:	call   516b <botlish_fn_54+0x1f>
			5167: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    516b:	test   rax,rax
    516e:	jne    5180 <botlish_fn_54+0x34>
    5174:	xor    rax,rax
    5177:	add    rsp,0x10
    517b:	mov    rsp,rbp
    517e:	pop    rbp
    517f:	ret
    5180:	add    rsp,0x10
    5184:	mov    rsp,rbp
    5187:	pop    rbp
    5188:	ret

0000000000005189 <botlish_entry_54: csv_records_presized<str>>:
    5189:	push   rbp
    518a:	mov    rbp,rsp
    518d:	mov    rsi,QWORD PTR [rdx]
    5190:	call   5195 <botlish_entry_54+0xc>
			5191: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5195:	mov    rsp,rbp
    5198:	pop    rbp
    5199:	ret
    519a:	add    BYTE PTR [rax],al
    519c:	add    BYTE PTR [rax],al
	...

00000000000051a0 <botlish_fn_55: sample<generic>>:
    51a0:	push   rbp
    51a1:	mov    rbp,rsp
    51a4:	sub    rsp,0xc0
    51ab:	mov    QWORD PTR [rsp+0x90],rbx
    51b3:	mov    QWORD PTR [rsp+0x98],r12
    51bb:	mov    QWORD PTR [rsp+0xa0],r13
    51c3:	mov    QWORD PTR [rsp+0xa8],r14
    51cb:	mov    QWORD PTR [rsp+0xb0],r15
    51d3:	mov    QWORD PTR [rsp+0x8],0x0
    51dc:	mov    QWORD PTR [rsp+0x10],0x0
    51e5:	mov    QWORD PTR [rsp+0x18],0x0
    51ee:	mov    QWORD PTR [rsp+0x20],0x0
    51f7:	mov    QWORD PTR [rsp+0x28],0x0
    5200:	mov    QWORD PTR [rsp+0x30],0x0
    5209:	mov    QWORD PTR [rsp+0x38],0x0
    5212:	mov    rax,QWORD PTR [rdi+0x10]
    5216:	mov    r13,rdi
    5219:	mov    rsi,QWORD PTR [rax+0x50]
    521d:	mov    QWORD PTR [rsp],rsi
    5221:	call   5226 <botlish_fn_55+0x86>
			5222: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    5226:	mov    rsi,rax
    5229:	mov    r12,rax
    522c:	test   rax,rsi
    522f:	je     55b4 <botlish_fn_55+0x414>
    5235:	mov    rax,r12
    5238:	mov    QWORD PTR [rsp],rax
    523c:	mov    rdi,r13
    523f:	mov    rax,QWORD PTR [rdi+0x10]
    5243:	mov    rsi,QWORD PTR [rax+0x50]
    5247:	mov    QWORD PTR [rsp+0x8],rsi
    524c:	call   5251 <botlish_fn_55+0xb1>
			524d: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5251:	mov    rbx,rax
    5254:	test   rbx,rbx
    5257:	je     55b4 <botlish_fn_55+0x414>
    525d:	mov    rax,r12
    5260:	mov    rax,QWORD PTR [rax+0x8]
    5264:	test   rax,rax
    5267:	jne    528e <botlish_fn_55+0xee>
    526d:	mov    edx,0x1
    5272:	mov    rsi,r12
    5275:	mov    rdi,r13
    5278:	call   527d <botlish_fn_55+0xdd>
			5279: R_X86_64_PLT32	rt_list_get-0x4
    527d:	test   rax,rax
    5280:	je     55b4 <botlish_fn_55+0x414>
    5286:	mov    rsi,rax
    5289:	jmp    5296 <botlish_fn_55+0xf6>
    528e:	mov    rax,QWORD PTR [r12+0x10]
    5293:	mov    rsi,QWORD PTR [rax]
    5296:	mov    QWORD PTR [rsp+0x8],rsi
    529b:	mov    r15,rsi
    529e:	mov    rax,QWORD PTR [r12+0x8]
    52a3:	cmp    rax,0x1
    52a7:	ja     52ce <botlish_fn_55+0x12e>
    52ad:	mov    edx,0x3
    52b2:	mov    rsi,r12
    52b5:	mov    rdi,r13
    52b8:	call   52bd <botlish_fn_55+0x11d>
			52b9: R_X86_64_PLT32	rt_list_get-0x4
    52bd:	test   rax,rax
    52c0:	je     55b4 <botlish_fn_55+0x414>
    52c6:	mov    rsi,rax
    52c9:	jmp    52d7 <botlish_fn_55+0x137>
    52ce:	mov    rax,QWORD PTR [r12+0x10]
    52d3:	mov    rsi,QWORD PTR [rax+0x8]
    52d7:	mov    QWORD PTR [rsp+0x10],rsi
    52dc:	mov    r14,rsi
    52df:	mov    rax,QWORD PTR [rbx+0x8]
    52e3:	mov    rsi,rbx
    52e6:	test   rax,rax
    52e9:	jne    530d <botlish_fn_55+0x16d>
    52ef:	mov    edx,0x1
    52f4:	mov    rdi,r13
    52f7:	call   52fc <botlish_fn_55+0x15c>
			52f8: R_X86_64_PLT32	rt_list_get-0x4
    52fc:	test   rax,rax
    52ff:	je     55b4 <botlish_fn_55+0x414>
    5305:	mov    rsi,rax
    5308:	jmp    5314 <botlish_fn_55+0x174>
    530d:	mov    rax,QWORD PTR [rsi+0x10]
    5311:	mov    rsi,QWORD PTR [rax]
    5314:	mov    QWORD PTR [rsp+0x18],rsi
    5319:	mov    rdi,r13
    531c:	mov    QWORD PTR [rsp+0x78],rsi
    5321:	mov    rax,QWORD PTR [rdi+0x10]
    5325:	mov    rdx,QWORD PTR [rax+0x58]
    5329:	mov    QWORD PTR [rsp+0x20],rdx
    532e:	mov    rsi,r15
    5331:	call   5336 <botlish_fn_55+0x196>
			5332: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5336:	test   rax,rax
    5339:	je     55b4 <botlish_fn_55+0x414>
    533f:	mov    QWORD PTR [rsp+0x20],rax
    5344:	mov    rbx,rax
    5347:	mov    rdi,r13
    534a:	mov    rax,QWORD PTR [rdi+0x10]
    534e:	mov    rdx,QWORD PTR [rax+0x58]
    5352:	mov    QWORD PTR [rsp+0x28],rdx
    5357:	mov    rsi,QWORD PTR [rsp+0x78]
    535c:	call   5361 <botlish_fn_55+0x1c1>
			535d: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5361:	test   rax,rax
    5364:	je     55b4 <botlish_fn_55+0x414>
    536a:	mov    rcx,rbx
    536d:	mov    rdx,rcx
    5370:	and    rdx,rax
    5373:	test   rdx,0x1
    537a:	jne    539c <botlish_fn_55+0x1fc>
    5380:	mov    rdx,rax
    5383:	mov    rsi,rbx
    5386:	mov    rdi,r13
    5389:	call   538e <botlish_fn_55+0x1ee>
			538a: R_X86_64_PLT32	rt_value_eq-0x4
    538e:	test   rax,rax
    5391:	je     55b4 <botlish_fn_55+0x414>
    5397:	jmp    53b2 <botlish_fn_55+0x212>
    539c:	mov    rdx,rax
    539f:	mov    rsi,rbx
    53a2:	mov    eax,0x2
    53a7:	cmp    rsi,rdx
    53aa:	cmove  rax,QWORD PTR [rip+0x26e]        # 5620 <botlish_fn_55+0x480>
    53b2:	mov    ebx,0x6
    53b7:	cmp    rax,0x6
    53bb:	je     53d6 <botlish_fn_55+0x236>
    53c1:	mov    ebx,0x2
    53c6:	mov    QWORD PTR [rsp],0x2
    53ce:	mov    rsi,r12
    53d1:	jmp    5475 <botlish_fn_55+0x2d5>
    53d6:	mov    rsi,r15
    53d9:	mov    rdi,r13
    53dc:	call   53e1 <botlish_fn_55+0x241>
			53dd: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53e1:	test   rax,rax
    53e4:	mov    QWORD PTR [rsp+0x88],rax
    53ec:	je     55b4 <botlish_fn_55+0x414>
    53f2:	mov    rsi,QWORD PTR [rsp+0x78]
    53f7:	mov    rdi,r13
    53fa:	call   53ff <botlish_fn_55+0x25f>
			53fb: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53ff:	test   rax,rax
    5402:	je     55b4 <botlish_fn_55+0x414>
    5408:	mov    rcx,QWORD PTR [rsp+0x88]
    5410:	mov    rdx,rcx
    5413:	and    rdx,rax
    5416:	test   rdx,0x1
    541d:	jne    5444 <botlish_fn_55+0x2a4>
    5423:	mov    rdx,rax
    5426:	mov    rsi,QWORD PTR [rsp+0x88]
    542e:	mov    rdi,r13
    5431:	call   5436 <botlish_fn_55+0x296>
			5432: R_X86_64_PLT32	rt_value_eq-0x4
    5436:	test   rax,rax
    5439:	je     55b4 <botlish_fn_55+0x414>
    543f:	jmp    545f <botlish_fn_55+0x2bf>
    5444:	mov    rdx,rax
    5447:	mov    rsi,QWORD PTR [rsp+0x88]
    544f:	mov    eax,0x2
    5454:	cmp    rsi,rdx
    5457:	cmove  rax,QWORD PTR [rip+0x1c1]        # 5620 <botlish_fn_55+0x480>
    545f:	cmp    rax,0x6
    5463:	je     546e <botlish_fn_55+0x2ce>
    5469:	mov    ebx,0x2
    546e:	mov    QWORD PTR [rsp],rbx
    5472:	mov    rsi,r12
    5475:	mov    rdi,r13
    5478:	call   547d <botlish_fn_55+0x2dd>
			5479: R_X86_64_PLT32	rt_list_len-0x4
    547d:	mov    QWORD PTR [rsp+0x18],rax
    5482:	mov    rdi,r13
    5485:	mov    r12,rax
    5488:	mov    rax,QWORD PTR [rdi+0x10]
    548c:	mov    rdx,QWORD PTR [rax+0x58]
    5490:	mov    QWORD PTR [rsp+0x20],rdx
    5495:	mov    rsi,r15
    5498:	call   549d <botlish_fn_55+0x2fd>
			5499: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    549d:	test   rax,rax
    54a0:	je     55b4 <botlish_fn_55+0x414>
    54a6:	mov    QWORD PTR [rsp+0x20],rax
    54ab:	mov    rdi,r13
    54ae:	mov    QWORD PTR [rsp+0x88],rax
    54b6:	mov    rax,QWORD PTR [rdi+0x10]
    54ba:	mov    rdx,QWORD PTR [rax+0x60]
    54be:	mov    QWORD PTR [rsp+0x28],rdx
    54c3:	mov    rsi,r15
    54c6:	call   54cb <botlish_fn_55+0x32b>
			54c7: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54cb:	test   rax,rax
    54ce:	je     55b4 <botlish_fn_55+0x414>
    54d4:	mov    QWORD PTR [rsp+0x28],rax
    54d9:	mov    rdi,r13
    54dc:	mov    QWORD PTR [rsp+0x80],rax
    54e4:	mov    rax,QWORD PTR [rdi+0x10]
    54e8:	mov    rdx,QWORD PTR [rax+0x68]
    54ec:	mov    QWORD PTR [rsp+0x30],rdx
    54f1:	mov    rsi,r15
    54f4:	call   54f9 <botlish_fn_55+0x359>
			54f5: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54f9:	test   rax,rax
    54fc:	je     55b4 <botlish_fn_55+0x414>
    5502:	mov    QWORD PTR [rsp+0x8],rax
    5507:	mov    rdi,r13
    550a:	mov    r15,rax
    550d:	mov    rax,QWORD PTR [rdi+0x10]
    5511:	mov    rdx,QWORD PTR [rax+0x58]
    5515:	mov    QWORD PTR [rsp+0x30],rdx
    551a:	mov    rsi,r14
    551d:	call   5522 <botlish_fn_55+0x382>
			551e: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5522:	test   rax,rax
    5525:	je     55b4 <botlish_fn_55+0x414>
    552b:	mov    QWORD PTR [rsp+0x30],rax
    5530:	mov    rdi,r13
    5533:	mov    QWORD PTR [rsp+0x78],rax
    5538:	mov    rax,QWORD PTR [rdi+0x10]
    553c:	mov    rdx,QWORD PTR [rax+0x68]
    5540:	mov    QWORD PTR [rsp+0x38],rdx
    5545:	mov    rsi,r14
    5548:	call   554d <botlish_fn_55+0x3ad>
			5549: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    554d:	test   rax,rax
    5550:	je     55b4 <botlish_fn_55+0x414>
    5556:	mov    QWORD PTR [rsp+0x10],rax
    555b:	lea    rdx,[rsp+0x40]
    5560:	mov    r9,r12
    5563:	mov    QWORD PTR [rsp+0x40],r9
    5568:	mov    rcx,QWORD PTR [rsp+0x88]
    5570:	mov    QWORD PTR [rsp+0x48],rcx
    5575:	mov    rcx,QWORD PTR [rsp+0x80]
    557d:	mov    QWORD PTR [rsp+0x50],rcx
    5582:	mov    rcx,r15
    5585:	mov    QWORD PTR [rsp+0x58],rcx
    558a:	mov    rcx,QWORD PTR [rsp+0x78]
    558f:	mov    QWORD PTR [rsp+0x60],rcx
    5594:	mov    QWORD PTR [rsp+0x68],rax
    5599:	mov    QWORD PTR [rsp+0x70],rbx
    559e:	mov    esi,0x7
    55a3:	mov    rdi,r13
    55a6:	call   55ab <botlish_fn_55+0x40b>
			55a7: R_X86_64_PLT32	rt_list_new-0x4
    55ab:	test   rax,rax
    55ae:	jne    55eb <botlish_fn_55+0x44b>
    55b4:	xor    rax,rax
    55b7:	mov    rbx,QWORD PTR [rsp+0x90]
    55bf:	mov    r12,QWORD PTR [rsp+0x98]
    55c7:	mov    r13,QWORD PTR [rsp+0xa0]
    55cf:	mov    r14,QWORD PTR [rsp+0xa8]
    55d7:	mov    r15,QWORD PTR [rsp+0xb0]
    55df:	add    rsp,0xc0
    55e6:	mov    rsp,rbp
    55e9:	pop    rbp
    55ea:	ret
    55eb:	mov    rbx,QWORD PTR [rsp+0x90]
    55f3:	mov    r12,QWORD PTR [rsp+0x98]
    55fb:	mov    r13,QWORD PTR [rsp+0xa0]
    5603:	mov    r14,QWORD PTR [rsp+0xa8]
    560b:	mov    r15,QWORD PTR [rsp+0xb0]
    5613:	add    rsp,0xc0
    561a:	mov    rsp,rbp
    561d:	pop    rbp
    561e:	ret
    561f:	add    BYTE PTR [rsi],al
    5621:	add    BYTE PTR [rax],al
    5623:	add    BYTE PTR [rax],al
    5625:	add    BYTE PTR [rax],al
	...

0000000000005628 <botlish_entry_55: sample<generic>>:
    5628:	push   rbp
    5629:	mov    rbp,rsp
    562c:	call   5631 <botlish_entry_55+0x9>
			562d: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample<generic>
    5631:	mov    rsp,rbp
    5634:	pop    rbp
    5635:	ret

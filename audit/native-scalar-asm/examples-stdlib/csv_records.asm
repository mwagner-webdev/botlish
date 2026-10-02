; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23371  (per function: 45 461 461 461 81 81 81 357 412 412 412 278 278 278 81 496 430 585 1069 352 783 215 488 325 388 524 70 493 114 61 61 61 61 61 168 179 245 804 1248 429 380 439 977 766 817 665 1168 836 107 427 259 629 634 78 78 1222)
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
     fa7:	mov    QWORD PTR [rsp+0x38],r14
     fac:	mov    r13,rdi
     faf:	mov    QWORD PTR [rsp],rsi
     fb3:	mov    r12,rsi
     fb6:	mov    QWORD PTR [rsp+0x8],rdx
     fbb:	mov    rbx,rdx
     fbe:	mov    rsi,r12
     fc1:	mov    rdi,r13
     fc4:	call   fc9 <botlish_fn_15+0x39>
			fc5: R_X86_64_PLT32	rt_str_len-0x4
     fc9:	mov    rcx,rbx
     fcc:	and    rcx,rax
     fcf:	mov    rdx,rax
     fd2:	test   rcx,0x1
     fd9:	jne    fff <botlish_fn_15+0x6f>
     fdf:	mov    rsi,rbx
     fe2:	mov    rdi,r13
     fe5:	call   fea <botlish_fn_15+0x5a>
			fe6: R_X86_64_PLT32	rt_int_cmp-0x4
     fea:	mov    ecx,0x2
     fef:	test   rax,rax
     ff2:	cmovge rcx,QWORD PTR [rip+0x106]        # 1100 <botlish_fn_15+0x170>
     ffa:	jmp    1012 <botlish_fn_15+0x82>
     fff:	mov    ecx,0x2
    1004:	mov    rax,rbx
    1007:	cmp    rax,rdx
    100a:	cmovge rcx,QWORD PTR [rip+0xee]        # 1100 <botlish_fn_15+0x170>
    1012:	cmp    rcx,0x6
    1016:	je     10d0 <botlish_fn_15+0x140>
    101c:	mov    QWORD PTR [rsp+0x10],0x3
    1025:	mov    rdx,rbx
    1028:	test   rdx,0x1
    102f:	je     104d <botlish_fn_15+0xbd>
    1035:	mov    rdx,rbx
    1038:	mov    rcx,rdx
    103b:	add    rcx,0x2
    103f:	mov    r14,rcx
    1042:	seto   al
    1045:	test   al,al
    1047:	je     1060 <botlish_fn_15+0xd0>
    104d:	mov    edx,0x3
    1052:	mov    rsi,rbx
    1055:	mov    rdi,r13
    1058:	call   105d <botlish_fn_15+0xcd>
			1059: R_X86_64_PLT32	rt_int_add-0x4
    105d:	mov    r14,rax
    1060:	mov    rcx,r14
    1063:	mov    rdx,rbx
    1066:	mov    rsi,r12
    1069:	mov    rdi,r13
    106c:	call   1071 <botlish_fn_15+0xe1>
			106d: R_X86_64_PLT32	rt_str_region_check-0x4
    1071:	test   rax,rax
    1074:	jne    109d <botlish_fn_15+0x10d>
    107a:	xor    rdx,rdx
    107d:	mov    rax,rdx
    1080:	mov    rbx,QWORD PTR [rsp+0x20]
    1085:	mov    r12,QWORD PTR [rsp+0x28]
    108a:	mov    r13,QWORD PTR [rsp+0x30]
    108f:	mov    r14,QWORD PTR [rsp+0x38]
    1094:	add    rsp,0x40
    1098:	mov    rsp,rbp
    109b:	pop    rbp
    109c:	ret
    109d:	mov    rcx,r14
    10a0:	mov    rdx,rbx
    10a3:	mov    rsi,r12
    10a6:	mov    rdi,r13
    10a9:	call   10ae <botlish_fn_15+0x11e>
			10aa: R_X86_64_PLT32	rt_str_slice_short-0x4
    10ae:	mov    edx,0x1
    10b3:	mov    rbx,QWORD PTR [rsp+0x20]
    10b8:	mov    r12,QWORD PTR [rsp+0x28]
    10bd:	mov    r13,QWORD PTR [rsp+0x30]
    10c2:	mov    r14,QWORD PTR [rsp+0x38]
    10c7:	add    rsp,0x40
    10cb:	mov    rsp,rbp
    10ce:	pop    rbp
    10cf:	ret
    10d0:	mov    rax,0xffffffffffffffff
    10d7:	mov    edx,0x1
    10dc:	mov    rbx,QWORD PTR [rsp+0x20]
    10e1:	mov    r12,QWORD PTR [rsp+0x28]
    10e6:	mov    r13,QWORD PTR [rsp+0x30]
    10eb:	mov    r14,QWORD PTR [rsp+0x38]
    10f0:	add    rsp,0x40
    10f4:	mov    rsp,rbp
    10f7:	pop    rbp
    10f8:	ret
    10f9:	add    BYTE PTR [rax],al
    10fb:	add    BYTE PTR [rax],al
    10fd:	add    BYTE PTR [rax],al
    10ff:	add    BYTE PTR [rsi],al
    1101:	add    BYTE PTR [rax],al
    1103:	add    BYTE PTR [rax],al
    1105:	add    BYTE PTR [rax],al
	...

0000000000001108 <botlish_entry_15: peek<str, int>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	sub    rsp,0x10
    1110:	mov    QWORD PTR [rsp],r12
    1114:	mov    QWORD PTR [rsp+0x8],r15
    1119:	mov    r15,rdi
    111c:	mov    rsi,QWORD PTR [rdx]
    111f:	mov    rdx,QWORD PTR [rdx+0x8]
    1123:	call   1128 <botlish_entry_15+0x20>
			1124: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    1128:	mov    r12,rdx
    112b:	mov    r10,QWORD PTR [rip+0x0]        # 1132 <botlish_entry_15+0x2a>
			112e: R_X86_64_GOTPCREL	rt_short_to_str-0x4
    1132:	mov    rsi,rax
    1135:	mov    rdi,r15
    1138:	call   r10
    113b:	mov    rcx,rax
    113e:	xor    rax,rax
    1141:	mov    rdx,r12
    1144:	test   rdx,rdx
    1147:	cmovne rax,rcx
    114b:	mov    r12,QWORD PTR [rsp]
    114f:	mov    r15,QWORD PTR [rsp+0x8]
    1154:	add    rsp,0x10
    1158:	mov    rsp,rbp
    115b:	pop    rbp
    115c:	ret
    115d:	add    BYTE PTR [rax],al
	...

0000000000001160 <botlish_fn_16: peek<str, int>>:
    1160:	push   rbp
    1161:	mov    rbp,rsp
    1164:	sub    rsp,0x50
    1168:	mov    QWORD PTR [rsp+0x20],rbx
    116d:	mov    QWORD PTR [rsp+0x28],r12
    1172:	mov    QWORD PTR [rsp+0x30],r13
    1177:	mov    QWORD PTR [rsp+0x38],r14
    117c:	mov    QWORD PTR [rsp+0x40],r15
    1181:	mov    r12,rcx
    1184:	mov    r14,rdi
    1187:	mov    QWORD PTR [rsp],rsi
    118b:	mov    r13,rsi
    118e:	mov    QWORD PTR [rsp+0x8],rdx
    1193:	mov    rbx,rdx
    1196:	mov    rsi,r13
    1199:	mov    rdi,r14
    119c:	call   11a1 <botlish_fn_16+0x41>
			119d: R_X86_64_PLT32	rt_str_len-0x4
    11a1:	mov    rcx,rbx
    11a4:	and    rcx,rax
    11a7:	mov    rdx,rax
    11aa:	test   rcx,0x1
    11b1:	jne    11d7 <botlish_fn_16+0x77>
    11b7:	mov    rsi,rbx
    11ba:	mov    rdi,r14
    11bd:	call   11c2 <botlish_fn_16+0x62>
			11be: R_X86_64_PLT32	rt_int_cmp-0x4
    11c2:	mov    ecx,0x2
    11c7:	test   rax,rax
    11ca:	cmovge rcx,QWORD PTR [rip+0x11e]        # 12f0 <botlish_fn_16+0x190>
    11d2:	jmp    11e7 <botlish_fn_16+0x87>
    11d7:	mov    ecx,0x2
    11dc:	cmp    rbx,rdx
    11df:	cmovge rcx,QWORD PTR [rip+0x109]        # 12f0 <botlish_fn_16+0x190>
    11e7:	cmp    rcx,0x6
    11eb:	je     12ab <botlish_fn_16+0x14b>
    11f1:	mov    QWORD PTR [rsp+0x10],0x3
    11fa:	test   rbx,0x1
    1201:	je     1224 <botlish_fn_16+0xc4>
    1207:	mov    rax,rbx
    120a:	add    rax,0x2
    120e:	seto   cl
    1211:	test   cl,cl
    1213:	jne    1224 <botlish_fn_16+0xc4>
    1219:	mov    rdi,r14
    121c:	mov    r15,rax
    121f:	jmp    123a <botlish_fn_16+0xda>
    1224:	mov    edx,0x3
    1229:	mov    rsi,rbx
    122c:	mov    rdi,r14
    122f:	call   1234 <botlish_fn_16+0xd4>
			1230: R_X86_64_PLT32	rt_int_add-0x4
    1234:	mov    r15,rax
    1237:	mov    rdi,r14
    123a:	mov    rdi,r14
    123d:	mov    rcx,r15
    1240:	mov    rdx,rbx
    1243:	mov    rsi,r13
    1246:	call   124b <botlish_fn_16+0xeb>
			1247: R_X86_64_PLT32	rt_str_region_check-0x4
    124b:	test   rax,rax
    124e:	jne    1279 <botlish_fn_16+0x119>
    1254:	xor    rax,rax
    1257:	mov    rbx,QWORD PTR [rsp+0x20]
    125c:	mov    r12,QWORD PTR [rsp+0x28]
    1261:	mov    r13,QWORD PTR [rsp+0x30]
    1266:	mov    r14,QWORD PTR [rsp+0x38]
    126b:	mov    r15,QWORD PTR [rsp+0x40]
    1270:	add    rsp,0x50
    1274:	mov    rsp,rbp
    1277:	pop    rbp
    1278:	ret
    1279:	mov    rcx,r12
    127c:	mov    QWORD PTR [rcx],rbx
    127f:	mov    rax,r15
    1282:	mov    QWORD PTR [rcx+0x8],rax
    1286:	mov    rax,r13
    1289:	mov    rbx,QWORD PTR [rsp+0x20]
    128e:	mov    r12,QWORD PTR [rsp+0x28]
    1293:	mov    r13,QWORD PTR [rsp+0x30]
    1298:	mov    r14,QWORD PTR [rsp+0x38]
    129d:	mov    r15,QWORD PTR [rsp+0x40]
    12a2:	add    rsp,0x50
    12a6:	mov    rsp,rbp
    12a9:	pop    rbp
    12aa:	ret
    12ab:	mov    rcx,r12
    12ae:	mov    rdi,r14
    12b1:	mov    rax,QWORD PTR [rdi+0x10]
    12b5:	mov    rax,QWORD PTR [rax+0x8]
    12b9:	mov    QWORD PTR [rcx],0x1
    12c0:	mov    QWORD PTR [rcx+0x8],0x1
    12c8:	mov    rbx,QWORD PTR [rsp+0x20]
    12cd:	mov    r12,QWORD PTR [rsp+0x28]
    12d2:	mov    r13,QWORD PTR [rsp+0x30]
    12d7:	mov    r14,QWORD PTR [rsp+0x38]
    12dc:	mov    r15,QWORD PTR [rsp+0x40]
    12e1:	add    rsp,0x50
    12e5:	mov    rsp,rbp
    12e8:	pop    rbp
    12e9:	ret
    12ea:	add    BYTE PTR [rax],al
    12ec:	add    BYTE PTR [rax],al
    12ee:	add    BYTE PTR [rax],al
    12f0:	(bad)
    12f1:	add    BYTE PTR [rax],al
    12f3:	add    BYTE PTR [rax],al
    12f5:	add    BYTE PTR [rax],al
	...

00000000000012f8 <botlish_entry_16: peek<str, int>>:
    12f8:	push   rbp
    12f9:	mov    rbp,rsp
    12fc:	ud2

00000000000012fe <botlish_fn_17: scan_unquoted<str, int, int>>:
    12fe:	push   rbp
    12ff:	mov    rbp,rsp
    1302:	sub    rsp,0x80
    1309:	mov    QWORD PTR [rsp+0x50],rbx
    130e:	mov    QWORD PTR [rsp+0x58],r12
    1313:	mov    QWORD PTR [rsp+0x60],r13
    1318:	mov    QWORD PTR [rsp+0x68],r14
    131d:	mov    QWORD PTR [rsp+0x70],r15
    1322:	mov    QWORD PTR [rsp+0x30],rdi
    1327:	mov    QWORD PTR [rsp+0x18],0x0
    1330:	mov    QWORD PTR [rsp],rsi
    1334:	mov    r15,rsi
    1337:	mov    QWORD PTR [rsp+0x8],rdx
    133c:	mov    r14,rdx
    133f:	mov    QWORD PTR [rsp+0x10],rcx
    1344:	lea    r13,[rsp+0x20]
    1349:	mov    QWORD PTR [rsp+0x38],rcx
    134e:	mov    rcx,r13
    1351:	mov    rdx,QWORD PTR [rsp+0x38]
    1356:	mov    rsi,r15
    1359:	mov    rdi,QWORD PTR [rsp+0x30]
    135e:	call   1363 <botlish_fn_17+0x65>
			135f: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1363:	mov    rsi,rax
    1366:	mov    QWORD PTR [rsp+0x40],rax
    136b:	test   rax,rsi
    136e:	je     14c8 <botlish_fn_17+0x1ca>
    1374:	mov    rbx,QWORD PTR [rsp+0x20]
    1379:	mov    r12,QWORD PTR [rsp+0x28]
    137e:	mov    rdi,QWORD PTR [rsp+0x30]
    1383:	mov    rcx,QWORD PTR [rdi+0x10]
    1387:	mov    r8,QWORD PTR [rcx+0x8]
    138b:	mov    rcx,r12
    138e:	mov    rdx,rbx
    1391:	mov    rsi,QWORD PTR [rsp+0x40]
    1396:	call   139b <botlish_fn_17+0x9d>
			1397: R_X86_64_PLT32	rt_str_region_eq-0x4
    139b:	cmp    rax,0x6
    139f:	je     13e0 <botlish_fn_17+0xe2>
    13a5:	mov    rdi,QWORD PTR [rsp+0x30]
    13aa:	mov    rax,QWORD PTR [rdi+0x10]
    13ae:	mov    r8,QWORD PTR [rax+0x10]
    13b2:	mov    rcx,r12
    13b5:	mov    rdx,rbx
    13b8:	mov    rsi,QWORD PTR [rsp+0x40]
    13bd:	call   13c2 <botlish_fn_17+0xc4>
			13be: R_X86_64_PLT32	rt_str_region_eq-0x4
    13c2:	cmp    rax,0x6
    13c6:	je     13d6 <botlish_fn_17+0xd8>
    13cc:	mov    eax,0x2
    13d1:	jmp    13e5 <botlish_fn_17+0xe7>
    13d6:	mov    eax,0x6
    13db:	jmp    13e5 <botlish_fn_17+0xe7>
    13e0:	mov    eax,0x6
    13e5:	cmp    rax,0x6
    13e9:	je     142a <botlish_fn_17+0x12c>
    13ef:	mov    rdi,QWORD PTR [rsp+0x30]
    13f4:	mov    rax,QWORD PTR [rdi+0x10]
    13f8:	mov    r8,QWORD PTR [rax+0x18]
    13fc:	mov    rcx,r12
    13ff:	mov    rdx,rbx
    1402:	mov    rsi,QWORD PTR [rsp+0x40]
    1407:	call   140c <botlish_fn_17+0x10e>
			1408: R_X86_64_PLT32	rt_str_region_eq-0x4
    140c:	cmp    rax,0x6
    1410:	je     1420 <botlish_fn_17+0x122>
    1416:	mov    eax,0x2
    141b:	jmp    142f <botlish_fn_17+0x131>
    1420:	mov    eax,0x6
    1425:	jmp    142f <botlish_fn_17+0x131>
    142a:	mov    eax,0x6
    142f:	cmp    rax,0x6
    1433:	je     14aa <botlish_fn_17+0x1ac>
    1439:	mov    QWORD PTR [rsp+0x18],0x3
    1442:	mov    rsi,QWORD PTR [rsp+0x38]
    1447:	test   rsi,0x1
    144e:	je     1475 <botlish_fn_17+0x177>
    1454:	mov    rsi,QWORD PTR [rsp+0x38]
    1459:	mov    rax,rsi
    145c:	add    rax,0x2
    1460:	seto   sil
    1464:	test   sil,sil
    1467:	jne    1475 <botlish_fn_17+0x177>
    146d:	mov    rsi,r15
    1470:	jmp    148c <botlish_fn_17+0x18e>
    1475:	mov    edx,0x3
    147a:	mov    rsi,QWORD PTR [rsp+0x38]
    147f:	mov    rdi,QWORD PTR [rsp+0x30]
    1484:	call   1489 <botlish_fn_17+0x18b>
			1485: R_X86_64_PLT32	rt_int_add-0x4
    1489:	mov    rsi,r15
    148c:	mov    QWORD PTR [rsp],rsi
    1490:	mov    rdx,r14
    1493:	mov    QWORD PTR [rsp+0x8],rdx
    1498:	mov    QWORD PTR [rsp+0x10],rax
    149d:	mov    r15,rsi
    14a0:	mov    QWORD PTR [rsp+0x38],rax
    14a5:	jmp    134e <botlish_fn_17+0x50>
    14aa:	mov    rdx,r14
    14ad:	mov    rsi,r15
    14b0:	mov    rdi,QWORD PTR [rsp+0x30]
    14b5:	mov    rcx,QWORD PTR [rsp+0x38]
    14ba:	call   14bf <botlish_fn_17+0x1c1>
			14bb: R_X86_64_PLT32	rt_substr-0x4
    14bf:	test   rax,rax
    14c2:	jne    14f3 <botlish_fn_17+0x1f5>
    14c8:	xor    rdx,rdx
    14cb:	mov    rax,rdx
    14ce:	mov    rbx,QWORD PTR [rsp+0x50]
    14d3:	mov    r12,QWORD PTR [rsp+0x58]
    14d8:	mov    r13,QWORD PTR [rsp+0x60]
    14dd:	mov    r14,QWORD PTR [rsp+0x68]
    14e2:	mov    r15,QWORD PTR [rsp+0x70]
    14e7:	add    rsp,0x80
    14ee:	mov    rsp,rbp
    14f1:	pop    rbp
    14f2:	ret
    14f3:	mov    rdx,QWORD PTR [rsp+0x38]
    14f8:	mov    rbx,QWORD PTR [rsp+0x50]
    14fd:	mov    r12,QWORD PTR [rsp+0x58]
    1502:	mov    r13,QWORD PTR [rsp+0x60]
    1507:	mov    r14,QWORD PTR [rsp+0x68]
    150c:	mov    r15,QWORD PTR [rsp+0x70]
    1511:	add    rsp,0x80
    1518:	mov    rsp,rbp
    151b:	pop    rbp
    151c:	ret

000000000000151d <botlish_entry_17: scan_unquoted<str, int, int>>:
    151d:	push   rbp
    151e:	mov    rbp,rsp
    1521:	ud2

0000000000001523 <botlish_fn_18: scan_quoted<str, int, str>>:
    1523:	push   rbp
    1524:	mov    rbp,rsp
    1527:	sub    rsp,0xc0
    152e:	mov    QWORD PTR [rsp+0x90],rbx
    1536:	mov    QWORD PTR [rsp+0x98],r12
    153e:	mov    QWORD PTR [rsp+0xa0],r13
    1546:	mov    QWORD PTR [rsp+0xa8],r14
    154e:	mov    QWORD PTR [rsp+0xb0],r15
    1556:	mov    r15,rdi
    1559:	mov    QWORD PTR [rsp+0x18],0x0
    1562:	mov    QWORD PTR [rsp],rsi
    1566:	mov    QWORD PTR [rsp+0x8],rdx
    156b:	mov    QWORD PTR [rsp+0x10],rcx
    1570:	mov    r13,rcx
    1573:	lea    r14,[rsp+0x60]
    1578:	lea    rbx,[rsp+0x20]
    157d:	mov    r12,rsi
    1580:	mov    QWORD PTR [rsp+0x80],rdx
    1588:	mov    rdx,QWORD PTR [rsp+0x80]
    1590:	mov    rsi,r12
    1593:	mov    rdi,r15
    1596:	call   159b <botlish_fn_18+0x78>
			1597: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    159b:	test   rdx,rdx
    159e:	je     18bb <botlish_fn_18+0x398>
    15a4:	cmp    rax,0x22
    15a8:	mov    QWORD PTR [rsp+0x88],rax
    15b0:	je     16b4 <botlish_fn_18+0x191>
    15b6:	mov    QWORD PTR [rsp+0x18],0x3
    15bf:	mov    rsi,QWORD PTR [rsp+0x80]
    15c7:	test   rsi,0x1
    15ce:	je     15f0 <botlish_fn_18+0xcd>
    15d4:	mov    rdi,rsi
    15d7:	add    rdi,0x2
    15db:	seto   r8b
    15df:	test   r8b,r8b
    15e2:	jne    15f0 <botlish_fn_18+0xcd>
    15e8:	mov    rsi,rdi
    15eb:	jmp    1600 <botlish_fn_18+0xdd>
    15f0:	mov    edx,0x3
    15f5:	mov    rdi,r15
    15f8:	call   15fd <botlish_fn_18+0xda>
			15f9: R_X86_64_PLT32	rt_int_add-0x4
    15fd:	mov    rsi,rax
    1600:	mov    QWORD PTR [rsp+0x8],rsi
    1605:	mov    rax,QWORD PTR [rsp+0x88]
    160d:	mov    QWORD PTR [rsp+0x80],rsi
    1615:	lea    rcx,[rax+0x1]
    1619:	cmp    rcx,0x101
    1620:	jb     1633 <botlish_fn_18+0x110>
    1626:	mov    rsi,QWORD PTR [rsp+0x88]
    162e:	jmp    164f <botlish_fn_18+0x12c>
    1633:	mov    rdi,r15
    1636:	mov    rax,QWORD PTR [rdi+rcx*8+0x648]
    163e:	test   rax,rax
    1641:	jne    1657 <botlish_fn_18+0x134>
    1647:	mov    rsi,QWORD PTR [rsp+0x88]
    164f:	mov    rdi,r15
    1652:	call   1657 <botlish_fn_18+0x134>
			1653: R_X86_64_PLT32	rt_short_to_str-0x4
    1657:	mov    QWORD PTR [rsp+0x18],rax
    165c:	mov    QWORD PTR [rsp+0x60],0x0
    1665:	mov    QWORD PTR [rsp+0x68],r13
    166a:	mov    QWORD PTR [rsp+0x70],0x0
    1673:	mov    QWORD PTR [rsp+0x78],rax
    1678:	mov    esi,0x2
    167d:	mov    edx,0x4
    1682:	mov    rcx,r14
    1685:	mov    rdi,r15
    1688:	call   168d <botlish_fn_18+0x16a>
			1689: R_X86_64_PLT32	rt_construct-0x4
    168d:	test   rax,rax
    1690:	je     18bb <botlish_fn_18+0x398>
    1696:	mov    QWORD PTR [rsp],r12
    169a:	mov    rsi,QWORD PTR [rsp+0x80]
    16a2:	mov    QWORD PTR [rsp+0x8],rsi
    16a7:	mov    QWORD PTR [rsp+0x10],rax
    16ac:	mov    r13,rax
    16af:	jmp    1588 <botlish_fn_18+0x65>
    16b4:	mov    QWORD PTR [rsp+0x18],0x3
    16bd:	mov    rsi,QWORD PTR [rsp+0x80]
    16c5:	test   rsi,0x1
    16cc:	je     16ec <botlish_fn_18+0x1c9>
    16d2:	mov    rsi,QWORD PTR [rsp+0x80]
    16da:	mov    rdx,rsi
    16dd:	add    rdx,0x2
    16e1:	seto   al
    16e4:	test   al,al
    16e6:	je     1704 <botlish_fn_18+0x1e1>
    16ec:	mov    edx,0x3
    16f1:	mov    rsi,QWORD PTR [rsp+0x80]
    16f9:	mov    rdi,r15
    16fc:	call   1701 <botlish_fn_18+0x1de>
			16fd: R_X86_64_PLT32	rt_int_add-0x4
    1701:	mov    rdx,rax
    1704:	mov    QWORD PTR [rsp+0x18],rdx
    1709:	mov    rcx,rbx
    170c:	mov    rsi,r12
    170f:	mov    rdi,r15
    1712:	call   1717 <botlish_fn_18+0x1f4>
			1713: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1717:	test   rax,rax
    171a:	mov    rsi,rax
    171d:	je     18bb <botlish_fn_18+0x398>
    1723:	mov    rdx,QWORD PTR [rsp+0x20]
    1728:	mov    rcx,QWORD PTR [rsp+0x28]
    172d:	mov    rdi,r15
    1730:	mov    rax,QWORD PTR [rdi+0x10]
    1734:	mov    r8,QWORD PTR [rax+0x20]
    1738:	call   173d <botlish_fn_18+0x21a>
			1739: R_X86_64_PLT32	rt_str_region_eq-0x4
    173d:	cmp    rax,0x6
    1741:	je     1809 <botlish_fn_18+0x2e6>
    1747:	xor    rsi,rsi
    174a:	lea    rcx,[rsp+0x50]
    174f:	mov    QWORD PTR [rsp+0x50],0x0
    1758:	mov    QWORD PTR [rsp+0x58],r13
    175d:	mov    edx,0x2
    1762:	mov    rdi,r15
    1765:	call   176a <botlish_fn_18+0x247>
			1766: R_X86_64_PLT32	rt_construct-0x4
    176a:	test   rax,rax
    176d:	je     18bb <botlish_fn_18+0x398>
    1773:	mov    QWORD PTR [rsp],rax
    1777:	mov    rbx,rax
    177a:	mov    QWORD PTR [rsp+0x10],0x3
    1783:	mov    rsi,QWORD PTR [rsp+0x80]
    178b:	test   rsi,0x1
    1792:	je     17ba <botlish_fn_18+0x297>
    1798:	mov    rsi,QWORD PTR [rsp+0x80]
    17a0:	mov    rdx,rsi
    17a3:	add    rdx,0x2
    17a7:	seto   al
    17aa:	test   al,al
    17ac:	jne    17ba <botlish_fn_18+0x297>
    17b2:	mov    rax,rbx
    17b5:	jmp    17d5 <botlish_fn_18+0x2b2>
    17ba:	mov    edx,0x3
    17bf:	mov    rsi,QWORD PTR [rsp+0x80]
    17c7:	mov    rdi,r15
    17ca:	call   17cf <botlish_fn_18+0x2ac>
			17cb: R_X86_64_PLT32	rt_int_add-0x4
    17cf:	mov    rdx,rax
    17d2:	mov    rax,rbx
    17d5:	mov    rbx,QWORD PTR [rsp+0x90]
    17dd:	mov    r12,QWORD PTR [rsp+0x98]
    17e5:	mov    r13,QWORD PTR [rsp+0xa0]
    17ed:	mov    r14,QWORD PTR [rsp+0xa8]
    17f5:	mov    r15,QWORD PTR [rsp+0xb0]
    17fd:	add    rsp,0xc0
    1804:	mov    rsp,rbp
    1807:	pop    rbp
    1808:	ret
    1809:	mov    QWORD PTR [rsp+0x18],0x5
    1812:	mov    rsi,QWORD PTR [rsp+0x80]
    181a:	test   rsi,0x1
    1821:	je     184d <botlish_fn_18+0x32a>
    1827:	mov    rsi,QWORD PTR [rsp+0x80]
    182f:	add    rsi,0x4
    1833:	seto   dil
    1837:	test   dil,dil
    183a:	jne    184d <botlish_fn_18+0x32a>
    1840:	mov    QWORD PTR [rsp+0x80],rsi
    1848:	jmp    186d <botlish_fn_18+0x34a>
    184d:	mov    edx,0x5
    1852:	mov    rsi,QWORD PTR [rsp+0x80]
    185a:	mov    rdi,r15
    185d:	call   1862 <botlish_fn_18+0x33f>
			185e: R_X86_64_PLT32	rt_int_add-0x4
    1862:	mov    rsi,rax
    1865:	mov    QWORD PTR [rsp+0x80],rax
    186d:	mov    QWORD PTR [rsp+0x8],rsi
    1872:	mov    rdi,r15
    1875:	mov    rax,QWORD PTR [rdi+0x10]
    1879:	mov    rax,QWORD PTR [rax+0x20]
    187d:	mov    QWORD PTR [rsp+0x18],rax
    1882:	lea    rcx,[rsp+0x30]
    1887:	mov    QWORD PTR [rsp+0x30],0x0
    1890:	mov    QWORD PTR [rsp+0x38],r13
    1895:	mov    QWORD PTR [rsp+0x40],0x0
    189e:	mov    QWORD PTR [rsp+0x48],rax
    18a3:	mov    esi,0x2
    18a8:	mov    edx,0x4
    18ad:	call   18b2 <botlish_fn_18+0x38f>
			18ae: R_X86_64_PLT32	rt_construct-0x4
    18b2:	test   rax,rax
    18b5:	jne    18f5 <botlish_fn_18+0x3d2>
    18bb:	xor    rdx,rdx
    18be:	mov    rax,rdx
    18c1:	mov    rbx,QWORD PTR [rsp+0x90]
    18c9:	mov    r12,QWORD PTR [rsp+0x98]
    18d1:	mov    r13,QWORD PTR [rsp+0xa0]
    18d9:	mov    r14,QWORD PTR [rsp+0xa8]
    18e1:	mov    r15,QWORD PTR [rsp+0xb0]
    18e9:	add    rsp,0xc0
    18f0:	mov    rsp,rbp
    18f3:	pop    rbp
    18f4:	ret
    18f5:	mov    QWORD PTR [rsp],r12
    18f9:	mov    rsi,QWORD PTR [rsp+0x80]
    1901:	mov    QWORD PTR [rsp+0x8],rsi
    1906:	mov    QWORD PTR [rsp+0x10],rax
    190b:	mov    r13,rax
    190e:	jmp    1588 <botlish_fn_18+0x65>

0000000000001913 <botlish_entry_18: scan_quoted<str, int, str>>:
    1913:	push   rbp
    1914:	mov    rbp,rsp
    1917:	ud2

0000000000001919 <botlish_fn_19: scan_field<str, int>>:
    1919:	push   rbp
    191a:	mov    rbp,rsp
    191d:	sub    rsp,0x50
    1921:	mov    QWORD PTR [rsp+0x30],rbx
    1926:	mov    QWORD PTR [rsp+0x38],r12
    192b:	mov    QWORD PTR [rsp+0x40],r13
    1930:	mov    r12,rdi
    1933:	mov    r13,rdx
    1936:	mov    QWORD PTR [rsp+0x10],0x0
    193f:	mov    QWORD PTR [rsp],rsi
    1943:	mov    rbx,rsi
    1946:	mov    QWORD PTR [rsp+0x8],rdx
    194b:	lea    rcx,[rsp+0x18]
    1950:	mov    rdx,r13
    1953:	mov    rsi,rbx
    1956:	mov    rdi,r12
    1959:	call   195e <botlish_fn_19+0x45>
			195a: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    195e:	test   rax,rax
    1961:	mov    rsi,rax
    1964:	je     1a2f <botlish_fn_19+0x116>
    196a:	mov    rdx,QWORD PTR [rsp+0x18]
    196f:	mov    rcx,QWORD PTR [rsp+0x20]
    1974:	mov    rdi,r12
    1977:	mov    rax,QWORD PTR [rdi+0x10]
    197b:	mov    r8,QWORD PTR [rax+0x20]
    197f:	call   1984 <botlish_fn_19+0x6b>
			1980: R_X86_64_PLT32	rt_str_region_eq-0x4
    1984:	cmp    rax,0x6
    1988:	je     19c0 <botlish_fn_19+0xa7>
    198e:	mov    rcx,r13
    1991:	mov    rsi,rbx
    1994:	mov    rdi,r12
    1997:	mov    rdx,rcx
    199a:	call   199f <botlish_fn_19+0x86>
			199b: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    199f:	test   rax,rax
    19a2:	je     1a2f <botlish_fn_19+0x116>
    19a8:	mov    rbx,QWORD PTR [rsp+0x30]
    19ad:	mov    r12,QWORD PTR [rsp+0x38]
    19b2:	mov    r13,QWORD PTR [rsp+0x40]
    19b7:	add    rsp,0x50
    19bb:	mov    rsp,rbp
    19be:	pop    rbp
    19bf:	ret
    19c0:	mov    rcx,r13
    19c3:	mov    QWORD PTR [rsp+0x10],0x3
    19cc:	test   rcx,0x1
    19d3:	jne    19e1 <botlish_fn_19+0xc8>
    19d9:	mov    r13,rcx
    19dc:	jmp    19f6 <botlish_fn_19+0xdd>
    19e1:	mov    rdx,rcx
    19e4:	add    rdx,0x2
    19e8:	mov    r13,rcx
    19eb:	seto   al
    19ee:	test   al,al
    19f0:	je     1a09 <botlish_fn_19+0xf0>
    19f6:	mov    edx,0x3
    19fb:	mov    rsi,r13
    19fe:	mov    rdi,r12
    1a01:	call   1a06 <botlish_fn_19+0xed>
			1a02: R_X86_64_PLT32	rt_int_add-0x4
    1a06:	mov    rdx,rax
    1a09:	mov    QWORD PTR [rsp+0x8],rdx
    1a0e:	mov    rdi,r12
    1a11:	mov    rax,QWORD PTR [rdi+0x10]
    1a15:	mov    rcx,QWORD PTR [rax+0x8]
    1a19:	mov    QWORD PTR [rsp+0x10],rcx
    1a1e:	mov    rsi,rbx
    1a21:	call   1a26 <botlish_fn_19+0x10d>
			1a22: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    1a26:	test   rax,rax
    1a29:	jne    1a4d <botlish_fn_19+0x134>
    1a2f:	xor    rdx,rdx
    1a32:	mov    rax,rdx
    1a35:	mov    rbx,QWORD PTR [rsp+0x30]
    1a3a:	mov    r12,QWORD PTR [rsp+0x38]
    1a3f:	mov    r13,QWORD PTR [rsp+0x40]
    1a44:	add    rsp,0x50
    1a48:	mov    rsp,rbp
    1a4b:	pop    rbp
    1a4c:	ret
    1a4d:	mov    rbx,QWORD PTR [rsp+0x30]
    1a52:	mov    r12,QWORD PTR [rsp+0x38]
    1a57:	mov    r13,QWORD PTR [rsp+0x40]
    1a5c:	add    rsp,0x50
    1a60:	mov    rsp,rbp
    1a63:	pop    rbp
    1a64:	ret

0000000000001a65 <botlish_entry_19: scan_field<str, int>>:
    1a65:	push   rbp
    1a66:	mov    rbp,rsp
    1a69:	ud2

0000000000001a6b <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    1a6b:	push   rbp
    1a6c:	mov    rbp,rsp
    1a6f:	sub    rsp,0x90
    1a76:	mov    QWORD PTR [rsp+0x60],rbx
    1a7b:	mov    QWORD PTR [rsp+0x68],r12
    1a80:	mov    QWORD PTR [rsp+0x70],r13
    1a85:	mov    QWORD PTR [rsp+0x78],r14
    1a8a:	mov    QWORD PTR [rsp+0x80],r15
    1a92:	mov    r15,rdi
    1a95:	mov    QWORD PTR [rsp+0x20],0x0
    1a9e:	mov    QWORD PTR [rsp],rsi
    1aa2:	mov    QWORD PTR [rsp+0x8],rdx
    1aa7:	mov    QWORD PTR [rsp+0x10],rcx
    1aac:	mov    QWORD PTR [rsp+0x18],r8
    1ab1:	lea    r12,[rsp+0x28]
    1ab6:	mov    rbx,rsi
    1ab9:	mov    QWORD PTR [rsp+0x38],rdx
    1abe:	mov    QWORD PTR [rsp+0x40],rcx
    1ac3:	mov    QWORD PTR [rsp+0x48],r8
    1ac8:	mov    rcx,r12
    1acb:	mov    rdx,QWORD PTR [rsp+0x38]
    1ad0:	mov    rsi,rbx
    1ad3:	mov    rdi,r15
    1ad6:	call   1adb <botlish_fn_20+0x70>
			1ad7: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1adb:	test   rax,rax
    1ade:	mov    QWORD PTR [rsp+0x50],rax
    1ae3:	je     1ca7 <botlish_fn_20+0x23c>
    1ae9:	mov    r14,QWORD PTR [rsp+0x28]
    1aee:	mov    r13,QWORD PTR [rsp+0x30]
    1af3:	mov    rdi,r15
    1af6:	mov    rcx,QWORD PTR [rdi+0x10]
    1afa:	mov    r8,QWORD PTR [rcx+0x10]
    1afe:	mov    rcx,r13
    1b01:	mov    rdx,r14
    1b04:	mov    rsi,QWORD PTR [rsp+0x50]
    1b09:	call   1b0e <botlish_fn_20+0xa3>
			1b0a: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b0e:	cmp    rax,0x6
    1b12:	je     1c20 <botlish_fn_20+0x1b5>
    1b18:	mov    rdi,r15
    1b1b:	mov    rax,QWORD PTR [rdi+0x10]
    1b1f:	mov    r8,QWORD PTR [rax+0x18]
    1b23:	mov    rcx,r13
    1b26:	mov    rdx,r14
    1b29:	mov    rsi,QWORD PTR [rsp+0x50]
    1b2e:	call   1b33 <botlish_fn_20+0xc8>
			1b2f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b33:	cmp    rax,0x6
    1b37:	je     1b85 <botlish_fn_20+0x11a>
    1b3d:	mov    rdx,QWORD PTR [rsp+0x48]
    1b42:	mov    rsi,QWORD PTR [rsp+0x40]
    1b47:	mov    rdi,r15
    1b4a:	call   1b4f <botlish_fn_20+0xe4>
			1b4b: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b4f:	test   rax,rax
    1b52:	je     1ca7 <botlish_fn_20+0x23c>
    1b58:	mov    rdx,QWORD PTR [rsp+0x38]
    1b5d:	mov    rbx,QWORD PTR [rsp+0x60]
    1b62:	mov    r12,QWORD PTR [rsp+0x68]
    1b67:	mov    r13,QWORD PTR [rsp+0x70]
    1b6c:	mov    r14,QWORD PTR [rsp+0x78]
    1b71:	mov    r15,QWORD PTR [rsp+0x80]
    1b79:	add    rsp,0x90
    1b80:	mov    rsp,rbp
    1b83:	pop    rbp
    1b84:	ret
    1b85:	mov    rdx,QWORD PTR [rsp+0x48]
    1b8a:	mov    rsi,QWORD PTR [rsp+0x40]
    1b8f:	mov    rdi,r15
    1b92:	call   1b97 <botlish_fn_20+0x12c>
			1b93: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b97:	test   rax,rax
    1b9a:	je     1ca7 <botlish_fn_20+0x23c>
    1ba0:	mov    QWORD PTR [rsp],rax
    1ba4:	mov    rbx,rax
    1ba7:	mov    QWORD PTR [rsp+0x10],0x3
    1bb0:	mov    rdx,QWORD PTR [rsp+0x38]
    1bb5:	test   rdx,0x1
    1bbc:	je     1be0 <botlish_fn_20+0x175>
    1bc2:	mov    rdx,QWORD PTR [rsp+0x38]
    1bc7:	add    rdx,0x2
    1bcb:	seto   sil
    1bcf:	test   sil,sil
    1bd2:	jne    1be0 <botlish_fn_20+0x175>
    1bd8:	mov    rax,rbx
    1bdb:	jmp    1bf8 <botlish_fn_20+0x18d>
    1be0:	mov    edx,0x3
    1be5:	mov    rsi,QWORD PTR [rsp+0x38]
    1bea:	mov    rdi,r15
    1bed:	call   1bf2 <botlish_fn_20+0x187>
			1bee: R_X86_64_PLT32	rt_int_add-0x4
    1bf2:	mov    rdx,rax
    1bf5:	mov    rax,rbx
    1bf8:	mov    rbx,QWORD PTR [rsp+0x60]
    1bfd:	mov    r12,QWORD PTR [rsp+0x68]
    1c02:	mov    r13,QWORD PTR [rsp+0x70]
    1c07:	mov    r14,QWORD PTR [rsp+0x78]
    1c0c:	mov    r15,QWORD PTR [rsp+0x80]
    1c14:	add    rsp,0x90
    1c1b:	mov    rsp,rbp
    1c1e:	pop    rbp
    1c1f:	ret
    1c20:	mov    rsi,QWORD PTR [rsp+0x38]
    1c25:	mov    edx,0x3
    1c2a:	mov    r13,rdx
    1c2d:	mov    QWORD PTR [rsp+0x20],0x3
    1c36:	test   rsi,0x1
    1c3d:	je     1c55 <botlish_fn_20+0x1ea>
    1c43:	mov    rdx,rsi
    1c46:	add    rdx,0x2
    1c4a:	seto   al
    1c4d:	test   al,al
    1c4f:	je     1c63 <botlish_fn_20+0x1f8>
    1c55:	mov    rdx,r13
    1c58:	mov    rdi,r15
    1c5b:	call   1c60 <botlish_fn_20+0x1f5>
			1c5c: R_X86_64_PLT32	rt_int_add-0x4
    1c60:	mov    rdx,rax
    1c63:	mov    QWORD PTR [rsp+0x8],rdx
    1c68:	mov    rsi,rbx
    1c6b:	mov    rdi,r15
    1c6e:	call   1c73 <botlish_fn_20+0x208>
			1c6f: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1c73:	test   rax,rax
    1c76:	je     1ca7 <botlish_fn_20+0x23c>
    1c7c:	mov    QWORD PTR [rsp+0x8],rax
    1c81:	mov    rcx,rax
    1c84:	mov    QWORD PTR [rsp+0x20],rdx
    1c89:	mov    rsi,QWORD PTR [rsp+0x40]
    1c8e:	mov    r14,rdx
    1c91:	mov    rdx,QWORD PTR [rsp+0x48]
    1c96:	mov    rdi,r15
    1c99:	call   1c9e <botlish_fn_20+0x233>
			1c9a: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1c9e:	test   rax,rax
    1ca1:	jne    1cd5 <botlish_fn_20+0x26a>
    1ca7:	xor    rdx,rdx
    1caa:	mov    rax,rdx
    1cad:	mov    rbx,QWORD PTR [rsp+0x60]
    1cb2:	mov    r12,QWORD PTR [rsp+0x68]
    1cb7:	mov    r13,QWORD PTR [rsp+0x70]
    1cbc:	mov    r14,QWORD PTR [rsp+0x78]
    1cc1:	mov    r15,QWORD PTR [rsp+0x80]
    1cc9:	add    rsp,0x90
    1cd0:	mov    rsp,rbp
    1cd3:	pop    rbp
    1cd4:	ret
    1cd5:	mov    QWORD PTR [rsp+0x8],rax
    1cda:	mov    QWORD PTR [rsp+0x38],rax
    1cdf:	mov    QWORD PTR [rsp+0x10],0x3
    1ce8:	mov    rdx,QWORD PTR [rsp+0x48]
    1ced:	test   rdx,0x1
    1cf4:	jne    1d07 <botlish_fn_20+0x29c>
    1cfa:	mov    rdx,r13
    1cfd:	mov    rsi,QWORD PTR [rsp+0x48]
    1d02:	jmp    1d26 <botlish_fn_20+0x2bb>
    1d07:	mov    rdx,QWORD PTR [rsp+0x48]
    1d0c:	mov    rax,rdx
    1d0f:	add    rax,0x2
    1d13:	seto   cl
    1d16:	test   cl,cl
    1d18:	je     1d2e <botlish_fn_20+0x2c3>
    1d1e:	mov    rdx,r13
    1d21:	mov    rsi,QWORD PTR [rsp+0x48]
    1d26:	mov    rdi,r15
    1d29:	call   1d2e <botlish_fn_20+0x2c3>
			1d2a: R_X86_64_PLT32	rt_int_add-0x4
    1d2e:	mov    QWORD PTR [rsp],rbx
    1d32:	mov    rdx,r14
    1d35:	mov    QWORD PTR [rsp+0x8],rdx
    1d3a:	mov    rcx,QWORD PTR [rsp+0x38]
    1d3f:	mov    QWORD PTR [rsp+0x10],rcx
    1d44:	mov    QWORD PTR [rsp+0x18],rax
    1d49:	mov    QWORD PTR [rsp+0x38],rdx
    1d4e:	mov    QWORD PTR [rsp+0x40],rcx
    1d53:	mov    QWORD PTR [rsp+0x48],rax
    1d58:	jmp    1ac8 <botlish_fn_20+0x5d>

0000000000001d5d <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1d5d:	push   rbp
    1d5e:	mov    rbp,rsp
    1d61:	ud2

0000000000001d63 <botlish_fn_21: scan_record<str, int>>:
    1d63:	push   rbp
    1d64:	mov    rbp,rsp
    1d67:	sub    rsp,0x40
    1d6b:	mov    QWORD PTR [rsp+0x20],rbx
    1d70:	mov    QWORD PTR [rsp+0x28],r12
    1d75:	mov    QWORD PTR [rsp+0x30],r14
    1d7a:	mov    r14,rdi
    1d7d:	mov    QWORD PTR [rsp+0x10],0x0
    1d86:	mov    QWORD PTR [rsp+0x18],0x0
    1d8f:	mov    QWORD PTR [rsp],rsi
    1d93:	mov    r12,rsi
    1d96:	mov    QWORD PTR [rsp+0x8],rdx
    1d9b:	mov    rsi,r12
    1d9e:	mov    rdi,r14
    1da1:	call   1da6 <botlish_fn_21+0x43>
			1da2: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1da6:	test   rax,rax
    1da9:	je     1dfe <botlish_fn_21+0x9b>
    1daf:	mov    QWORD PTR [rsp+0x8],rax
    1db4:	mov    rsi,rax
    1db7:	mov    QWORD PTR [rsp+0x10],rdx
    1dbc:	mov    rbx,rdx
    1dbf:	mov    rdi,r14
    1dc2:	call   1dc7 <botlish_fn_21+0x64>
			1dc3: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1dc7:	test   rax,rax
    1dca:	je     1dfe <botlish_fn_21+0x9b>
    1dd0:	mov    QWORD PTR [rsp+0x8],rax
    1dd5:	mov    rcx,rax
    1dd8:	mov    r8d,0x3
    1dde:	mov    QWORD PTR [rsp+0x18],0x3
    1de7:	mov    rdx,rbx
    1dea:	mov    rsi,r12
    1ded:	mov    rdi,r14
    1df0:	call   1df5 <botlish_fn_21+0x92>
			1df1: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1df5:	test   rax,rax
    1df8:	jne    1e1c <botlish_fn_21+0xb9>
    1dfe:	xor    rdx,rdx
    1e01:	mov    rax,rdx
    1e04:	mov    rbx,QWORD PTR [rsp+0x20]
    1e09:	mov    r12,QWORD PTR [rsp+0x28]
    1e0e:	mov    r14,QWORD PTR [rsp+0x30]
    1e13:	add    rsp,0x40
    1e17:	mov    rsp,rbp
    1e1a:	pop    rbp
    1e1b:	ret
    1e1c:	mov    rbx,QWORD PTR [rsp+0x20]
    1e21:	mov    r12,QWORD PTR [rsp+0x28]
    1e26:	mov    r14,QWORD PTR [rsp+0x30]
    1e2b:	add    rsp,0x40
    1e2f:	mov    rsp,rbp
    1e32:	pop    rbp
    1e33:	ret

0000000000001e34 <botlish_entry_21: scan_record<str, int>>:
    1e34:	push   rbp
    1e35:	mov    rbp,rsp
    1e38:	ud2
    1e3a:	add    BYTE PTR [rax],al
    1e3c:	add    BYTE PTR [rax],al
	...

0000000000001e40 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1e40:	push   rbp
    1e41:	mov    rbp,rsp
    1e44:	sub    rsp,0x60
    1e48:	mov    QWORD PTR [rsp+0x30],rbx
    1e4d:	mov    QWORD PTR [rsp+0x38],r12
    1e52:	mov    QWORD PTR [rsp+0x40],r13
    1e57:	mov    QWORD PTR [rsp+0x48],r14
    1e5c:	mov    QWORD PTR [rsp+0x50],r15
    1e61:	mov    r13,rdi
    1e64:	mov    QWORD PTR [rsp+0x20],0x0
    1e6d:	mov    QWORD PTR [rsp],rsi
    1e71:	mov    QWORD PTR [rsp+0x8],rdx
    1e76:	mov    r12,rdx
    1e79:	mov    QWORD PTR [rsp+0x10],rcx
    1e7e:	mov    QWORD PTR [rsp+0x18],r8
    1e83:	mov    rbx,rsi
    1e86:	mov    r14,r8
    1e89:	mov    r15,rcx
    1e8c:	mov    rsi,rbx
    1e8f:	mov    rdi,r13
    1e92:	call   1e97 <botlish_fn_22+0x57>
			1e93: R_X86_64_PLT32	rt_str_len-0x4
    1e97:	mov    rcx,r12
    1e9a:	and    rcx,rax
    1e9d:	mov    rdx,rax
    1ea0:	test   rcx,0x1
    1ea7:	jne    1ecd <botlish_fn_22+0x8d>
    1ead:	mov    rsi,r12
    1eb0:	mov    rdi,r13
    1eb3:	call   1eb8 <botlish_fn_22+0x78>
			1eb4: R_X86_64_PLT32	rt_int_cmp-0x4
    1eb8:	mov    ecx,0x2
    1ebd:	test   rax,rax
    1ec0:	cmovge rcx,QWORD PTR [rip+0x128]        # 1ff0 <botlish_fn_22+0x1b0>
    1ec8:	jmp    1edd <botlish_fn_22+0x9d>
    1ecd:	mov    ecx,0x2
    1ed2:	cmp    r12,rdx
    1ed5:	cmovge rcx,QWORD PTR [rip+0x113]        # 1ff0 <botlish_fn_22+0x1b0>
    1edd:	cmp    rcx,0x6
    1ee1:	je     1f8c <botlish_fn_22+0x14c>
    1ee7:	mov    rdx,r12
    1eea:	mov    rsi,rbx
    1eed:	mov    rdi,r13
    1ef0:	call   1ef5 <botlish_fn_22+0xb5>
			1ef1: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1ef5:	test   rax,rax
    1ef8:	je     1fa3 <botlish_fn_22+0x163>
    1efe:	mov    QWORD PTR [rsp+0x8],rax
    1f03:	mov    rcx,rax
    1f06:	mov    QWORD PTR [rsp+0x20],rdx
    1f0b:	mov    rsi,r15
    1f0e:	mov    r12,rdx
    1f11:	mov    rdx,r14
    1f14:	mov    rdi,r13
    1f17:	call   1f1c <botlish_fn_22+0xdc>
			1f18: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1f1c:	test   rax,rax
    1f1f:	je     1fa3 <botlish_fn_22+0x163>
    1f25:	mov    QWORD PTR [rsp+0x8],rax
    1f2a:	mov    r15,rax
    1f2d:	mov    QWORD PTR [rsp+0x10],0x3
    1f36:	mov    rsi,r14
    1f39:	test   rsi,0x1
    1f40:	je     1f5b <botlish_fn_22+0x11b>
    1f46:	mov    rsi,r14
    1f49:	mov    rax,rsi
    1f4c:	add    rax,0x2
    1f50:	seto   cl
    1f53:	test   cl,cl
    1f55:	je     1f6b <botlish_fn_22+0x12b>
    1f5b:	mov    edx,0x3
    1f60:	mov    rsi,r14
    1f63:	mov    rdi,r13
    1f66:	call   1f6b <botlish_fn_22+0x12b>
			1f67: R_X86_64_PLT32	rt_int_add-0x4
    1f6b:	mov    QWORD PTR [rsp],rbx
    1f6f:	mov    rdx,r12
    1f72:	mov    QWORD PTR [rsp+0x8],rdx
    1f77:	mov    rcx,r15
    1f7a:	mov    QWORD PTR [rsp+0x10],rcx
    1f7f:	mov    QWORD PTR [rsp+0x18],rax
    1f84:	mov    r14,rax
    1f87:	jmp    1e8c <botlish_fn_22+0x4c>
    1f8c:	mov    rdx,r14
    1f8f:	mov    rsi,r15
    1f92:	mov    rdi,r13
    1f95:	call   1f9a <botlish_fn_22+0x15a>
			1f96: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1f9a:	test   rax,rax
    1f9d:	jne    1fc8 <botlish_fn_22+0x188>
    1fa3:	xor    rax,rax
    1fa6:	mov    rbx,QWORD PTR [rsp+0x30]
    1fab:	mov    r12,QWORD PTR [rsp+0x38]
    1fb0:	mov    r13,QWORD PTR [rsp+0x40]
    1fb5:	mov    r14,QWORD PTR [rsp+0x48]
    1fba:	mov    r15,QWORD PTR [rsp+0x50]
    1fbf:	add    rsp,0x60
    1fc3:	mov    rsp,rbp
    1fc6:	pop    rbp
    1fc7:	ret
    1fc8:	mov    rbx,QWORD PTR [rsp+0x30]
    1fcd:	mov    r12,QWORD PTR [rsp+0x38]
    1fd2:	mov    r13,QWORD PTR [rsp+0x40]
    1fd7:	mov    r14,QWORD PTR [rsp+0x48]
    1fdc:	mov    r15,QWORD PTR [rsp+0x50]
    1fe1:	add    rsp,0x60
    1fe5:	mov    rsp,rbp
    1fe8:	pop    rbp
    1fe9:	ret
    1fea:	add    BYTE PTR [rax],al
    1fec:	add    BYTE PTR [rax],al
    1fee:	add    BYTE PTR [rax],al
    1ff0:	(bad)
    1ff1:	add    BYTE PTR [rax],al
    1ff3:	add    BYTE PTR [rax],al
    1ff5:	add    BYTE PTR [rax],al
	...

0000000000001ff8 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    1ff8:	push   rbp
    1ff9:	mov    rbp,rsp
    1ffc:	mov    rsi,QWORD PTR [rdx]
    1fff:	mov    r9,QWORD PTR [rdx+0x8]
    2003:	mov    rcx,QWORD PTR [rdx+0x10]
    2007:	mov    r8,QWORD PTR [rdx+0x18]
    200b:	mov    rdx,r9
    200e:	call   2013 <botlish_entry_22+0x1b>
			200f: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    2013:	mov    rsp,rbp
    2016:	pop    rbp
    2017:	ret

0000000000002018 <botlish_fn_23: csv_parse<str>>:
    2018:	push   rbp
    2019:	mov    rbp,rsp
    201c:	sub    rsp,0x40
    2020:	mov    QWORD PTR [rsp+0x20],rbx
    2025:	mov    QWORD PTR [rsp+0x28],r12
    202a:	mov    QWORD PTR [rsp+0x30],r13
    202f:	mov    rbx,rdi
    2032:	mov    QWORD PTR [rsp+0x8],0x0
    203b:	mov    QWORD PTR [rsp+0x10],0x0
    2044:	mov    QWORD PTR [rsp+0x18],0x0
    204d:	mov    QWORD PTR [rsp],rsi
    2051:	mov    r12,rsi
    2054:	mov    rsi,r12
    2057:	mov    rdi,rbx
    205a:	call   205f <botlish_fn_23+0x47>
			205b: R_X86_64_PLT32	rt_str_len-0x4
    205f:	sar    rax,1
    2062:	test   rax,rax
    2065:	je     20f4 <botlish_fn_23+0xdc>
    206b:	mov    edx,0x1
    2070:	mov    QWORD PTR [rsp+0x8],0x1
    2079:	mov    rsi,r12
    207c:	mov    rdi,rbx
    207f:	call   2084 <botlish_fn_23+0x6c>
			2080: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    2084:	test   rax,rax
    2087:	je     210b <botlish_fn_23+0xf3>
    208d:	mov    QWORD PTR [rsp+0x8],rax
    2092:	mov    rsi,rax
    2095:	mov    QWORD PTR [rsp+0x10],rdx
    209a:	mov    r13,rdx
    209d:	mov    rdi,rbx
    20a0:	call   20a5 <botlish_fn_23+0x8d>
			20a1: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    20a5:	test   rax,rax
    20a8:	je     210b <botlish_fn_23+0xf3>
    20ae:	mov    QWORD PTR [rsp+0x8],rax
    20b3:	mov    rcx,rax
    20b6:	mov    r8d,0x3
    20bc:	mov    QWORD PTR [rsp+0x18],0x3
    20c5:	mov    rdx,r13
    20c8:	mov    rsi,r12
    20cb:	mov    rdi,rbx
    20ce:	call   20d3 <botlish_fn_23+0xbb>
			20cf: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    20d3:	test   rax,rax
    20d6:	je     210b <botlish_fn_23+0xf3>
    20dc:	mov    rbx,QWORD PTR [rsp+0x20]
    20e1:	mov    r12,QWORD PTR [rsp+0x28]
    20e6:	mov    r13,QWORD PTR [rsp+0x30]
    20eb:	add    rsp,0x40
    20ef:	mov    rsp,rbp
    20f2:	pop    rbp
    20f3:	ret
    20f4:	xor    rdx,rdx
    20f7:	mov    rdi,rbx
    20fa:	mov    rsi,rdx
    20fd:	call   2102 <botlish_fn_23+0xea>
			20fe: R_X86_64_PLT32	rt_list_new-0x4
    2102:	test   rax,rax
    2105:	jne    2126 <botlish_fn_23+0x10e>
    210b:	xor    rax,rax
    210e:	mov    rbx,QWORD PTR [rsp+0x20]
    2113:	mov    r12,QWORD PTR [rsp+0x28]
    2118:	mov    r13,QWORD PTR [rsp+0x30]
    211d:	add    rsp,0x40
    2121:	mov    rsp,rbp
    2124:	pop    rbp
    2125:	ret
    2126:	mov    rbx,QWORD PTR [rsp+0x20]
    212b:	mov    r12,QWORD PTR [rsp+0x28]
    2130:	mov    r13,QWORD PTR [rsp+0x30]
    2135:	add    rsp,0x40
    2139:	mov    rsp,rbp
    213c:	pop    rbp
    213d:	ret

000000000000213e <botlish_entry_23: csv_parse<str>>:
    213e:	push   rbp
    213f:	mov    rbp,rsp
    2142:	mov    rsi,QWORD PTR [rdx]
    2145:	call   214a <botlish_entry_23+0xc>
			2146: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    214a:	mov    rsp,rbp
    214d:	pop    rbp
    214e:	ret
	...

0000000000002150 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    2150:	push   rbp
    2151:	mov    rbp,rsp
    2154:	sub    rsp,0x40
    2158:	mov    QWORD PTR [rsp+0x20],rbx
    215d:	mov    QWORD PTR [rsp+0x28],r12
    2162:	mov    QWORD PTR [rsp+0x30],r13
    2167:	mov    QWORD PTR [rsp+0x38],r14
    216c:	mov    r13,rdi
    216f:	mov    QWORD PTR [rsp],rsi
    2173:	mov    rbx,rsi
    2176:	mov    QWORD PTR [rsp+0x8],rdx
    217b:	mov    QWORD PTR [rsp+0x10],rcx
    2180:	mov    r12,rcx
    2183:	mov    rsi,rdx
    2186:	mov    rax,rsi
    2189:	and    rax,r12
    218c:	mov    r14,rsi
    218f:	test   rax,0x1
    2195:	jne    21be <botlish_fn_24+0x6e>
    219b:	mov    rdx,r12
    219e:	mov    rsi,r14
    21a1:	mov    rdi,r13
    21a4:	call   21a9 <botlish_fn_24+0x59>
			21a5: R_X86_64_PLT32	rt_int_cmp-0x4
    21a9:	mov    ecx,0x2
    21ae:	test   rax,rax
    21b1:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2298 <botlish_fn_24+0x148>
    21b9:	jmp    21d1 <botlish_fn_24+0x81>
    21be:	mov    ecx,0x2
    21c3:	mov    rsi,r14
    21c6:	cmp    rsi,r12
    21c9:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2298 <botlish_fn_24+0x148>
    21d1:	cmp    rcx,0x6
    21d5:	je     2276 <botlish_fn_24+0x126>
    21db:	mov    ecx,0x1
    21e0:	mov    rdx,r14
    21e3:	mov    rsi,rbx
    21e6:	mov    rdi,r13
    21e9:	call   21ee <botlish_fn_24+0x9e>
			21ea: R_X86_64_PLT32	rt_mutarray_set-0x4
    21ee:	test   rax,rax
    21f1:	jne    2217 <botlish_fn_24+0xc7>
    21f7:	xor    rax,rax
    21fa:	mov    rbx,QWORD PTR [rsp+0x20]
    21ff:	mov    r12,QWORD PTR [rsp+0x28]
    2204:	mov    r13,QWORD PTR [rsp+0x30]
    2209:	mov    r14,QWORD PTR [rsp+0x38]
    220e:	add    rsp,0x40
    2212:	mov    rsp,rbp
    2215:	pop    rbp
    2216:	ret
    2217:	mov    QWORD PTR [rsp+0x18],0x3
    2220:	mov    rsi,r14
    2223:	test   rsi,0x1
    222a:	je     224d <botlish_fn_24+0xfd>
    2230:	mov    rsi,r14
    2233:	mov    rcx,rsi
    2236:	add    rcx,0x2
    223a:	seto   al
    223d:	test   al,al
    223f:	jne    224d <botlish_fn_24+0xfd>
    2245:	mov    r14,rcx
    2248:	jmp    2260 <botlish_fn_24+0x110>
    224d:	mov    edx,0x3
    2252:	mov    rsi,r14
    2255:	mov    rdi,r13
    2258:	call   225d <botlish_fn_24+0x10d>
			2259: R_X86_64_PLT32	rt_int_add-0x4
    225d:	mov    r14,rax
    2260:	mov    QWORD PTR [rsp],rbx
    2264:	mov    rsi,r14
    2267:	mov    QWORD PTR [rsp+0x8],rsi
    226c:	mov    QWORD PTR [rsp+0x10],r12
    2271:	jmp    2186 <botlish_fn_24+0x36>
    2276:	mov    eax,0xa
    227b:	mov    rbx,QWORD PTR [rsp+0x20]
    2280:	mov    r12,QWORD PTR [rsp+0x28]
    2285:	mov    r13,QWORD PTR [rsp+0x30]
    228a:	mov    r14,QWORD PTR [rsp+0x38]
    228f:	add    rsp,0x40
    2293:	mov    rsp,rbp
    2296:	pop    rbp
    2297:	ret
    2298:	(bad)
    2299:	add    BYTE PTR [rax],al
    229b:	add    BYTE PTR [rax],al
    229d:	add    BYTE PTR [rax],al
	...

00000000000022a0 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    22a0:	push   rbp
    22a1:	mov    rbp,rsp
    22a4:	mov    rsi,QWORD PTR [rdx]
    22a7:	mov    r8,QWORD PTR [rdx+0x8]
    22ab:	mov    rcx,QWORD PTR [rdx+0x10]
    22af:	mov    rdx,r8
    22b2:	call   22b7 <botlish_entry_24+0x17>
			22b3: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    22b7:	mov    rsp,rbp
    22ba:	pop    rbp
    22bb:	ret

00000000000022bc <botlish_fn_25: ht_alloc<int>>:
    22bc:	push   rbp
    22bd:	mov    rbp,rsp
    22c0:	sub    rsp,0x50
    22c4:	mov    QWORD PTR [rsp+0x20],rbx
    22c9:	mov    QWORD PTR [rsp+0x28],r12
    22ce:	mov    QWORD PTR [rsp+0x30],r13
    22d3:	mov    QWORD PTR [rsp+0x38],r14
    22d8:	mov    QWORD PTR [rsp+0x40],r15
    22dd:	mov    rbx,rdi
    22e0:	mov    QWORD PTR [rsp+0x8],0x0
    22e9:	mov    QWORD PTR [rsp+0x10],0x0
    22f2:	mov    QWORD PTR [rsp+0x18],0x0
    22fb:	mov    QWORD PTR [rsp],rsi
    22ff:	mov    r13,rsi
    2302:	mov    rsi,r13
    2305:	mov    rdi,rbx
    2308:	call   230d <botlish_fn_25+0x51>
			2309: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    230d:	test   rax,rax
    2310:	je     242c <botlish_fn_25+0x170>
    2316:	mov    QWORD PTR [rsp+0x8],rax
    231b:	mov    r12,rax
    231e:	mov    edx,0x1
    2323:	mov    QWORD PTR [rsp+0x10],0x1
    232c:	mov    rcx,r13
    232f:	mov    rsi,r12
    2332:	mov    rdi,rbx
    2335:	call   233a <botlish_fn_25+0x7e>
			2336: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    233a:	test   rax,rax
    233d:	je     242c <botlish_fn_25+0x170>
    2343:	mov    rsi,r13
    2346:	mov    rdi,rbx
    2349:	call   234e <botlish_fn_25+0x92>
			234a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    234e:	test   rax,rax
    2351:	je     242c <botlish_fn_25+0x170>
    2357:	mov    QWORD PTR [rsp+0x10],rax
    235c:	mov    rsi,r13
    235f:	mov    r14,rax
    2362:	mov    rdi,rbx
    2365:	call   236a <botlish_fn_25+0xae>
			2366: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    236a:	test   rax,rax
    236d:	je     242c <botlish_fn_25+0x170>
    2373:	mov    QWORD PTR [rsp],rax
    2377:	mov    r13,rax
    237a:	mov    esi,0xb
    237f:	mov    QWORD PTR [rsp+0x18],0xb
    2388:	mov    rdi,rbx
    238b:	call   2390 <botlish_fn_25+0xd4>
			238c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2390:	test   rax,rax
    2393:	mov    r15,rax
    2396:	je     242c <botlish_fn_25+0x170>
    239c:	mov    edx,0x1
    23a1:	mov    rcx,r12
    23a4:	mov    rsi,r15
    23a7:	mov    rdi,rbx
    23aa:	call   23af <botlish_fn_25+0xf3>
			23ab: R_X86_64_PLT32	rt_mutarray_set-0x4
    23af:	test   rax,rax
    23b2:	je     242c <botlish_fn_25+0x170>
    23b8:	mov    edx,0x3
    23bd:	mov    rcx,r14
    23c0:	mov    rsi,r15
    23c3:	mov    rdi,rbx
    23c6:	call   23cb <botlish_fn_25+0x10f>
			23c7: R_X86_64_PLT32	rt_mutarray_set-0x4
    23cb:	test   rax,rax
    23ce:	je     242c <botlish_fn_25+0x170>
    23d4:	mov    edx,0x5
    23d9:	mov    rcx,r13
    23dc:	mov    rsi,r15
    23df:	mov    rdi,rbx
    23e2:	call   23e7 <botlish_fn_25+0x12b>
			23e3: R_X86_64_PLT32	rt_mutarray_set-0x4
    23e7:	test   rax,rax
    23ea:	je     242c <botlish_fn_25+0x170>
    23f0:	mov    edx,0x7
    23f5:	mov    ecx,0x1
    23fa:	mov    rsi,r15
    23fd:	mov    rdi,rbx
    2400:	call   2405 <botlish_fn_25+0x149>
			2401: R_X86_64_PLT32	rt_mutarray_set-0x4
    2405:	test   rax,rax
    2408:	je     242c <botlish_fn_25+0x170>
    240e:	mov    edx,0x9
    2413:	mov    ecx,0x1
    2418:	mov    rdi,rbx
    241b:	mov    rsi,r15
    241e:	call   2423 <botlish_fn_25+0x167>
			241f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2423:	test   rax,rax
    2426:	jne    2451 <botlish_fn_25+0x195>
    242c:	xor    rax,rax
    242f:	mov    rbx,QWORD PTR [rsp+0x20]
    2434:	mov    r12,QWORD PTR [rsp+0x28]
    2439:	mov    r13,QWORD PTR [rsp+0x30]
    243e:	mov    r14,QWORD PTR [rsp+0x38]
    2443:	mov    r15,QWORD PTR [rsp+0x40]
    2448:	add    rsp,0x50
    244c:	mov    rsp,rbp
    244f:	pop    rbp
    2450:	ret
    2451:	mov    rax,r15
    2454:	mov    rbx,QWORD PTR [rsp+0x20]
    2459:	mov    r12,QWORD PTR [rsp+0x28]
    245e:	mov    r13,QWORD PTR [rsp+0x30]
    2463:	mov    r14,QWORD PTR [rsp+0x38]
    2468:	mov    r15,QWORD PTR [rsp+0x40]
    246d:	add    rsp,0x50
    2471:	mov    rsp,rbp
    2474:	pop    rbp
    2475:	ret

0000000000002476 <botlish_entry_25: ht_alloc<int>>:
    2476:	push   rbp
    2477:	mov    rbp,rsp
    247a:	mov    rsi,QWORD PTR [rdx]
    247d:	call   2482 <botlish_entry_25+0xc>
			247e: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2482:	mov    rsp,rbp
    2485:	pop    rbp
    2486:	ret

0000000000002487 <botlish_fn_26: ht_new<generic>>:
    2487:	push   rbp
    2488:	mov    rbp,rsp
    248b:	sub    rsp,0x10
    248f:	mov    esi,0x11
    2494:	mov    QWORD PTR [rsp],0x11
    249c:	call   24a1 <botlish_fn_26+0x1a>
			249d: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    24a1:	test   rax,rax
    24a4:	jne    24b6 <botlish_fn_26+0x2f>
    24aa:	xor    rax,rax
    24ad:	add    rsp,0x10
    24b1:	mov    rsp,rbp
    24b4:	pop    rbp
    24b5:	ret
    24b6:	add    rsp,0x10
    24ba:	mov    rsp,rbp
    24bd:	pop    rbp
    24be:	ret

00000000000024bf <botlish_entry_26: ht_new<generic>>:
    24bf:	push   rbp
    24c0:	mov    rbp,rsp
    24c3:	call   24c8 <botlish_entry_26+0x9>
			24c4: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    24c8:	mov    rsp,rbp
    24cb:	pop    rbp
    24cc:	ret
    24cd:	add    BYTE PTR [rax],al
	...

00000000000024d0 <botlish_fn_27: ht_capacity_for<int, int>>:
    24d0:	push   rbp
    24d1:	mov    rbp,rsp
    24d4:	sub    rsp,0x50
    24d8:	mov    QWORD PTR [rsp+0x20],rbx
    24dd:	mov    QWORD PTR [rsp+0x28],r12
    24e2:	mov    QWORD PTR [rsp+0x30],r13
    24e7:	mov    QWORD PTR [rsp+0x38],r14
    24ec:	mov    QWORD PTR [rsp+0x40],r15
    24f1:	mov    r13,rdi
    24f4:	mov    QWORD PTR [rsp],rdx
    24f8:	mov    rbx,rsi
    24fb:	or     rbx,0x1
    24ff:	sar    rbx,1
    2502:	mov    r12,rsi
    2505:	mov    r14,rdx
    2508:	mov    rax,r12
    250b:	or     rax,0x1
    250f:	mov    QWORD PTR [rsp+0x8],rax
    2514:	mov    QWORD PTR [rsp+0x10],0x7
    251d:	mov    rax,rbx
    2520:	imul   QWORD PTR [rip+0x159]        # 2680 <botlish_fn_27+0x1b0>
    2527:	seto   cl
    252a:	or     rax,0x1
    252e:	test   cl,cl
    2530:	jne    253e <botlish_fn_27+0x6e>
    2536:	mov    rsi,rax
    2539:	jmp    2555 <botlish_fn_27+0x85>
    253e:	mov    rsi,r12
    2541:	or     rsi,0x1
    2545:	mov    edx,0x7
    254a:	mov    rdi,r13
    254d:	call   2552 <botlish_fn_27+0x82>
			254e: R_X86_64_PLT32	rt_int_mul-0x4
    2552:	mov    rsi,rax
    2555:	mov    QWORD PTR [rsp+0x8],rsi
    255a:	mov    r15,rsi
    255d:	mov    QWORD PTR [rsp+0x10],0x5
    2566:	mov    rsi,r14
    2569:	test   rsi,0x1
    2570:	je     25a0 <botlish_fn_27+0xd0>
    2576:	mov    rsi,r14
    2579:	mov    rax,rsi
    257c:	sar    rax,1
    257f:	imul   QWORD PTR [rip+0x102]        # 2688 <botlish_fn_27+0x1b8>
    2586:	seto   cl
    2589:	or     rax,0x1
    258d:	test   cl,cl
    258f:	jne    25a0 <botlish_fn_27+0xd0>
    2595:	mov    rdx,rax
    2598:	mov    rsi,r15
    259b:	jmp    25b6 <botlish_fn_27+0xe6>
    25a0:	mov    edx,0x5
    25a5:	mov    rsi,r14
    25a8:	mov    rdi,r13
    25ab:	call   25b0 <botlish_fn_27+0xe0>
			25ac: R_X86_64_PLT32	rt_int_mul-0x4
    25b0:	mov    rdx,rax
    25b3:	mov    rsi,r15
    25b6:	mov    rax,rsi
    25b9:	and    rax,rdx
    25bc:	test   rax,0x1
    25c2:	jne    25e5 <botlish_fn_27+0x115>
    25c8:	mov    rdi,r13
    25cb:	call   25d0 <botlish_fn_27+0x100>
			25cc: R_X86_64_PLT32	rt_int_cmp-0x4
    25d0:	mov    ecx,0x2
    25d5:	test   rax,rax
    25d8:	cmovle rcx,QWORD PTR [rip+0xa0]        # 2680 <botlish_fn_27+0x1b0>
    25e0:	jmp    25f5 <botlish_fn_27+0x125>
    25e5:	mov    ecx,0x2
    25ea:	cmp    rsi,rdx
    25ed:	cmovle rcx,QWORD PTR [rip+0x8b]        # 2680 <botlish_fn_27+0x1b0>
    25f5:	cmp    rcx,0x6
    25f9:	je     2655 <botlish_fn_27+0x185>
    25ff:	mov    QWORD PTR [rsp+0x8],0x5
    2608:	mov    rsi,r14
    260b:	test   rsi,0x1
    2612:	je     2639 <botlish_fn_27+0x169>
    2618:	mov    rsi,r14
    261b:	mov    rax,rsi
    261e:	sar    rax,1
    2621:	imul   QWORD PTR [rip+0x60]        # 2688 <botlish_fn_27+0x1b8>
    2628:	seto   sil
    262c:	or     rax,0x1
    2630:	test   sil,sil
    2633:	je     2649 <botlish_fn_27+0x179>
    2639:	mov    edx,0x5
    263e:	mov    rsi,r14
    2641:	mov    rdi,r13
    2644:	call   2649 <botlish_fn_27+0x179>
			2645: R_X86_64_PLT32	rt_int_mul-0x4
    2649:	mov    QWORD PTR [rsp],rax
    264d:	mov    r14,rax
    2650:	jmp    2508 <botlish_fn_27+0x38>
    2655:	mov    rax,r14
    2658:	mov    rbx,QWORD PTR [rsp+0x20]
    265d:	mov    r12,QWORD PTR [rsp+0x28]
    2662:	mov    r13,QWORD PTR [rsp+0x30]
    2667:	mov    r14,QWORD PTR [rsp+0x38]
    266c:	mov    r15,QWORD PTR [rsp+0x40]
    2671:	add    rsp,0x50
    2675:	mov    rsp,rbp
    2678:	pop    rbp
    2679:	ret
    267a:	add    BYTE PTR [rax],al
    267c:	add    BYTE PTR [rax],al
    267e:	add    BYTE PTR [rax],al
    2680:	(bad)
    2681:	add    BYTE PTR [rax],al
    2683:	add    BYTE PTR [rax],al
    2685:	add    BYTE PTR [rax],al
    2687:	add    BYTE PTR [rax+rax*1],al
    268a:	add    BYTE PTR [rax],al
    268c:	add    BYTE PTR [rax],al
	...

0000000000002690 <botlish_entry_27: ht_capacity_for<int, int>>:
    2690:	push   rbp
    2691:	mov    rbp,rsp
    2694:	mov    rsi,QWORD PTR [rdx]
    2697:	mov    rdx,QWORD PTR [rdx+0x8]
    269b:	call   26a0 <botlish_entry_27+0x10>
			269c: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    26a0:	mov    rsp,rbp
    26a3:	pop    rbp
    26a4:	ret

00000000000026a5 <botlish_fn_28: ht_new_sized<int>>:
    26a5:	push   rbp
    26a6:	mov    rbp,rsp
    26a9:	sub    rsp,0x20
    26ad:	mov    QWORD PTR [rsp+0x10],r12
    26b2:	mov    r12,rdi
    26b5:	mov    QWORD PTR [rsp],rsi
    26b9:	mov    edx,0x11
    26be:	mov    QWORD PTR [rsp+0x8],0x11
    26c7:	mov    rdi,r12
    26ca:	call   26cf <botlish_fn_28+0x2a>
			26cb: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    26cf:	mov    QWORD PTR [rsp],rax
    26d3:	mov    rsi,rax
    26d6:	mov    rdi,r12
    26d9:	call   26de <botlish_fn_28+0x39>
			26da: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    26de:	test   rax,rax
    26e1:	jne    26f8 <botlish_fn_28+0x53>
    26e7:	xor    rax,rax
    26ea:	mov    r12,QWORD PTR [rsp+0x10]
    26ef:	add    rsp,0x20
    26f3:	mov    rsp,rbp
    26f6:	pop    rbp
    26f7:	ret
    26f8:	mov    r12,QWORD PTR [rsp+0x10]
    26fd:	add    rsp,0x20
    2701:	mov    rsp,rbp
    2704:	pop    rbp
    2705:	ret

0000000000002706 <botlish_entry_28: ht_new_sized<int>>:
    2706:	push   rbp
    2707:	mov    rbp,rsp
    270a:	mov    rsi,QWORD PTR [rdx]
    270d:	call   2712 <botlish_entry_28+0xc>
			270e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    2712:	mov    rsp,rbp
    2715:	pop    rbp
    2716:	ret

0000000000002717 <botlish_fn_29: ht_controls<mutarray>>:
    2717:	push   rbp
    2718:	mov    rbp,rsp
    271b:	mov    edx,0x1
    2720:	call   2725 <botlish_fn_29+0xe>
			2721: R_X86_64_PLT32	rt_mutarray_get-0x4
    2725:	test   rax,rax
    2728:	jne    2736 <botlish_fn_29+0x1f>
    272e:	xor    rax,rax
    2731:	mov    rsp,rbp
    2734:	pop    rbp
    2735:	ret
    2736:	mov    rsp,rbp
    2739:	pop    rbp
    273a:	ret

000000000000273b <botlish_entry_29: ht_controls<mutarray>>:
    273b:	push   rbp
    273c:	mov    rbp,rsp
    273f:	mov    rsi,QWORD PTR [rdx]
    2742:	call   2747 <botlish_entry_29+0xc>
			2743: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2747:	mov    rsp,rbp
    274a:	pop    rbp
    274b:	ret

000000000000274c <botlish_fn_30: ht_keys<mutarray>>:
    274c:	push   rbp
    274d:	mov    rbp,rsp
    2750:	mov    edx,0x3
    2755:	call   275a <botlish_fn_30+0xe>
			2756: R_X86_64_PLT32	rt_mutarray_get-0x4
    275a:	test   rax,rax
    275d:	jne    276b <botlish_fn_30+0x1f>
    2763:	xor    rax,rax
    2766:	mov    rsp,rbp
    2769:	pop    rbp
    276a:	ret
    276b:	mov    rsp,rbp
    276e:	pop    rbp
    276f:	ret

0000000000002770 <botlish_entry_30: ht_keys<mutarray>>:
    2770:	push   rbp
    2771:	mov    rbp,rsp
    2774:	mov    rsi,QWORD PTR [rdx]
    2777:	call   277c <botlish_entry_30+0xc>
			2778: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    277c:	mov    rsp,rbp
    277f:	pop    rbp
    2780:	ret

0000000000002781 <botlish_fn_31: ht_values<mutarray>>:
    2781:	push   rbp
    2782:	mov    rbp,rsp
    2785:	mov    edx,0x5
    278a:	call   278f <botlish_fn_31+0xe>
			278b: R_X86_64_PLT32	rt_mutarray_get-0x4
    278f:	test   rax,rax
    2792:	jne    27a0 <botlish_fn_31+0x1f>
    2798:	xor    rax,rax
    279b:	mov    rsp,rbp
    279e:	pop    rbp
    279f:	ret
    27a0:	mov    rsp,rbp
    27a3:	pop    rbp
    27a4:	ret

00000000000027a5 <botlish_entry_31: ht_values<mutarray>>:
    27a5:	push   rbp
    27a6:	mov    rbp,rsp
    27a9:	mov    rsi,QWORD PTR [rdx]
    27ac:	call   27b1 <botlish_entry_31+0xc>
			27ad: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    27b1:	mov    rsp,rbp
    27b4:	pop    rbp
    27b5:	ret

00000000000027b6 <botlish_fn_32: ht_size<mutarray>>:
    27b6:	push   rbp
    27b7:	mov    rbp,rsp
    27ba:	mov    edx,0x7
    27bf:	call   27c4 <botlish_fn_32+0xe>
			27c0: R_X86_64_PLT32	rt_mutarray_get-0x4
    27c4:	test   rax,rax
    27c7:	jne    27d5 <botlish_fn_32+0x1f>
    27cd:	xor    rax,rax
    27d0:	mov    rsp,rbp
    27d3:	pop    rbp
    27d4:	ret
    27d5:	mov    rsp,rbp
    27d8:	pop    rbp
    27d9:	ret

00000000000027da <botlish_entry_32: ht_size<mutarray>>:
    27da:	push   rbp
    27db:	mov    rbp,rsp
    27de:	mov    rsi,QWORD PTR [rdx]
    27e1:	call   27e6 <botlish_entry_32+0xc>
			27e2: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    27e6:	mov    rsp,rbp
    27e9:	pop    rbp
    27ea:	ret

00000000000027eb <botlish_fn_33: ht_tombstones<mutarray>>:
    27eb:	push   rbp
    27ec:	mov    rbp,rsp
    27ef:	mov    edx,0x9
    27f4:	call   27f9 <botlish_fn_33+0xe>
			27f5: R_X86_64_PLT32	rt_mutarray_get-0x4
    27f9:	test   rax,rax
    27fc:	jne    280a <botlish_fn_33+0x1f>
    2802:	xor    rax,rax
    2805:	mov    rsp,rbp
    2808:	pop    rbp
    2809:	ret
    280a:	mov    rsp,rbp
    280d:	pop    rbp
    280e:	ret

000000000000280f <botlish_entry_33: ht_tombstones<mutarray>>:
    280f:	push   rbp
    2810:	mov    rbp,rsp
    2813:	mov    rsi,QWORD PTR [rdx]
    2816:	call   281b <botlish_entry_33+0xc>
			2817: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    281b:	mov    rsp,rbp
    281e:	pop    rbp
    281f:	ret

0000000000002820 <botlish_fn_34: ht_capacity<mutarray>>:
    2820:	push   rbp
    2821:	mov    rbp,rsp
    2824:	sub    rsp,0x10
    2828:	mov    QWORD PTR [rsp],rbx
    282c:	mov    rbx,rdi
    282f:	mov    rdi,rbx
    2832:	call   2837 <botlish_fn_34+0x17>
			2833: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2837:	test   rax,rax
    283a:	je     2884 <botlish_fn_34+0x64>
    2840:	xor    r8d,r8d
    2843:	test   rax,0x7
    2849:	je     2857 <botlish_fn_34+0x37>
    284f:	mov    rsi,rax
    2852:	jmp    2866 <botlish_fn_34+0x46>
    2857:	movzx  rcx,BYTE PTR [rax]
    285b:	mov    rsi,rax
    285e:	rex cmp cl,0x8
    2862:	sete   r8b
    2866:	test   r8b,r8b
    2869:	jne    2894 <botlish_fn_34+0x74>
    286f:	mov    rdi,rbx
    2872:	mov    rax,QWORD PTR [rdi+0x10]
    2876:	mov    rcx,QWORD PTR [rax+0x28]
    287a:	mov    edx,0x8
    287f:	call   2884 <botlish_fn_34+0x64>
			2880: R_X86_64_PLT32	rt_type_error-0x4
    2884:	xor    rax,rax
    2887:	mov    rbx,QWORD PTR [rsp]
    288b:	add    rsp,0x10
    288f:	mov    rsp,rbp
    2892:	pop    rbp
    2893:	ret
    2894:	mov    rdi,rbx
    2897:	call   289c <botlish_fn_34+0x7c>
			2898: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    289c:	mov    rbx,QWORD PTR [rsp]
    28a0:	add    rsp,0x10
    28a4:	mov    rsp,rbp
    28a7:	pop    rbp
    28a8:	ret

00000000000028a9 <botlish_entry_34: ht_capacity<mutarray>>:
    28a9:	push   rbp
    28aa:	mov    rbp,rsp
    28ad:	mov    rsi,QWORD PTR [rdx]
    28b0:	call   28b5 <botlish_entry_34+0xc>
			28b1: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    28b5:	mov    rsp,rbp
    28b8:	pop    rbp
    28b9:	ret

00000000000028ba <botlish_fn_35: ht_probe_start<mutarray, str>>:
    28ba:	push   rbp
    28bb:	mov    rbp,rsp
    28be:	sub    rsp,0x20
    28c2:	mov    QWORD PTR [rsp],r12
    28c6:	mov    QWORD PTR [rsp+0x8],r13
    28cb:	mov    QWORD PTR [rsp+0x10],r14
    28d0:	mov    r12,rdi
    28d3:	mov    r14,rsi
    28d6:	mov    rsi,rdx
    28d9:	mov    rdi,r12
    28dc:	call   28e1 <botlish_fn_35+0x27>
			28dd: R_X86_64_PLT32	rt_hash-0x4
    28e1:	test   rax,rax
    28e4:	mov    r13,rax
    28e7:	je     2918 <botlish_fn_35+0x5e>
    28ed:	mov    rsi,r14
    28f0:	mov    rdi,r12
    28f3:	call   28f8 <botlish_fn_35+0x3e>
			28f4: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    28f8:	test   rax,rax
    28fb:	mov    rdx,rax
    28fe:	je     2918 <botlish_fn_35+0x5e>
    2904:	mov    rsi,r13
    2907:	mov    rdi,r12
    290a:	call   290f <botlish_fn_35+0x55>
			290b: R_X86_64_PLT32	rt_int_mod-0x4
    290f:	test   rax,rax
    2912:	jne    2932 <botlish_fn_35+0x78>
    2918:	xor    rax,rax
    291b:	mov    r12,QWORD PTR [rsp]
    291f:	mov    r13,QWORD PTR [rsp+0x8]
    2924:	mov    r14,QWORD PTR [rsp+0x10]
    2929:	add    rsp,0x20
    292d:	mov    rsp,rbp
    2930:	pop    rbp
    2931:	ret
    2932:	mov    r12,QWORD PTR [rsp]
    2936:	mov    r13,QWORD PTR [rsp+0x8]
    293b:	mov    r14,QWORD PTR [rsp+0x10]
    2940:	add    rsp,0x20
    2944:	mov    rsp,rbp
    2947:	pop    rbp
    2948:	ret

0000000000002949 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    2949:	push   rbp
    294a:	mov    rbp,rsp
    294d:	mov    rsi,QWORD PTR [rdx]
    2950:	mov    rdx,QWORD PTR [rdx+0x8]
    2954:	call   2959 <botlish_entry_35+0x10>
			2955: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    2959:	mov    rsp,rbp
    295c:	pop    rbp
    295d:	ret

000000000000295e <botlish_fn_36: ht_probe_next<mutarray, int>>:
    295e:	push   rbp
    295f:	mov    rbp,rsp
    2962:	sub    rsp,0x40
    2966:	mov    QWORD PTR [rsp+0x20],rbx
    296b:	mov    QWORD PTR [rsp+0x28],r12
    2970:	mov    QWORD PTR [rsp+0x30],r13
    2975:	mov    r13,rdi
    2978:	mov    QWORD PTR [rsp],rsi
    297c:	mov    rbx,rsi
    297f:	mov    QWORD PTR [rsp+0x8],rdx
    2984:	mov    QWORD PTR [rsp+0x10],0x3
    298d:	test   rdx,0x1
    2994:	jne    29a2 <botlish_fn_36+0x44>
    299a:	mov    rsi,rdx
    299d:	jmp    29c2 <botlish_fn_36+0x64>
    29a2:	mov    rsi,rdx
    29a5:	add    rsi,0x2
    29a9:	mov    r12,rsi
    29ac:	mov    rsi,rdx
    29af:	seto   al
    29b2:	test   al,al
    29b4:	jne    29c2 <botlish_fn_36+0x64>
    29ba:	mov    rsi,rbx
    29bd:	jmp    29d5 <botlish_fn_36+0x77>
    29c2:	mov    edx,0x3
    29c7:	mov    rdi,r13
    29ca:	call   29cf <botlish_fn_36+0x71>
			29cb: R_X86_64_PLT32	rt_int_add-0x4
    29cf:	mov    rsi,rbx
    29d2:	mov    r12,rax
    29d5:	mov    rdi,r13
    29d8:	call   29dd <botlish_fn_36+0x7f>
			29d9: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    29dd:	test   rax,rax
    29e0:	mov    rdx,rax
    29e3:	je     29fd <botlish_fn_36+0x9f>
    29e9:	mov    rsi,r12
    29ec:	mov    rdi,r13
    29ef:	call   29f4 <botlish_fn_36+0x96>
			29f0: R_X86_64_PLT32	rt_int_mod-0x4
    29f4:	test   rax,rax
    29f7:	jne    2a18 <botlish_fn_36+0xba>
    29fd:	xor    rax,rax
    2a00:	mov    rbx,QWORD PTR [rsp+0x20]
    2a05:	mov    r12,QWORD PTR [rsp+0x28]
    2a0a:	mov    r13,QWORD PTR [rsp+0x30]
    2a0f:	add    rsp,0x40
    2a13:	mov    rsp,rbp
    2a16:	pop    rbp
    2a17:	ret
    2a18:	mov    rbx,QWORD PTR [rsp+0x20]
    2a1d:	mov    r12,QWORD PTR [rsp+0x28]
    2a22:	mov    r13,QWORD PTR [rsp+0x30]
    2a27:	add    rsp,0x40
    2a2b:	mov    rsp,rbp
    2a2e:	pop    rbp
    2a2f:	ret

0000000000002a30 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    2a30:	push   rbp
    2a31:	mov    rbp,rsp
    2a34:	mov    rsi,QWORD PTR [rdx]
    2a37:	mov    rdx,QWORD PTR [rdx+0x8]
    2a3b:	call   2a40 <botlish_entry_36+0x10>
			2a3c: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2a40:	mov    rsp,rbp
    2a43:	pop    rbp
    2a44:	ret
    2a45:	add    BYTE PTR [rax],al
	...

0000000000002a48 <botlish_fn_37: ht_find_get<mutarray, str, int>>:
    2a48:	push   rbp
    2a49:	mov    rbp,rsp
    2a4c:	sub    rsp,0x50
    2a50:	mov    QWORD PTR [rsp+0x20],rbx
    2a55:	mov    QWORD PTR [rsp+0x28],r12
    2a5a:	mov    QWORD PTR [rsp+0x30],r13
    2a5f:	mov    QWORD PTR [rsp+0x38],r14
    2a64:	mov    QWORD PTR [rsp+0x40],r15
    2a69:	mov    r14,rdi
    2a6c:	mov    QWORD PTR [rsp],rsi
    2a70:	mov    QWORD PTR [rsp+0x8],rdx
    2a75:	mov    r13,rdx
    2a78:	mov    QWORD PTR [rsp+0x10],rcx
    2a7d:	mov    r12,rsi
    2a80:	mov    r15,rcx
    2a83:	mov    rsi,r12
    2a86:	mov    rdi,r14
    2a89:	call   2a8e <botlish_fn_37+0x46>
			2a8a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2a8e:	test   rax,rax
    2a91:	je     2c90 <botlish_fn_37+0x248>
    2a97:	xor    ecx,ecx
    2a99:	test   rax,0x7
    2a9f:	je     2aad <botlish_fn_37+0x65>
    2aa5:	mov    rsi,rax
    2aa8:	jmp    2abb <botlish_fn_37+0x73>
    2aad:	movzx  rcx,BYTE PTR [rax]
    2ab1:	mov    rsi,rax
    2ab4:	rex cmp cl,0x8
    2ab8:	sete   cl
    2abb:	test   cl,cl
    2abd:	jne    2add <botlish_fn_37+0x95>
    2ac3:	mov    rdi,r14
    2ac6:	mov    rdx,QWORD PTR [rdi+0x10]
    2aca:	mov    rcx,QWORD PTR [rdx+0x30]
    2ace:	mov    edx,0x8
    2ad3:	call   2ad8 <botlish_fn_37+0x90>
			2ad4: R_X86_64_PLT32	rt_type_error-0x4
    2ad8:	jmp    2c90 <botlish_fn_37+0x248>
    2add:	mov    rdx,r15
    2ae0:	mov    rdi,r14
    2ae3:	call   2ae8 <botlish_fn_37+0xa0>
			2ae4: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ae8:	mov    rcx,rax
    2aeb:	mov    QWORD PTR [rsp+0x18],rax
    2af0:	test   rax,rcx
    2af3:	je     2c90 <botlish_fn_37+0x248>
    2af9:	mov    rax,QWORD PTR [rsp+0x18]
    2afe:	test   rax,0x1
    2b04:	jne    2b2f <botlish_fn_37+0xe7>
    2b0a:	mov    edx,0x1
    2b0f:	mov    rsi,QWORD PTR [rsp+0x18]
    2b14:	mov    rdi,r14
    2b17:	call   2b1c <botlish_fn_37+0xd4>
			2b18: R_X86_64_PLT32	rt_value_eq-0x4
    2b1c:	test   rax,rax
    2b1f:	je     2c90 <botlish_fn_37+0x248>
    2b25:	mov    rcx,QWORD PTR [rsp+0x18]
    2b2a:	jmp    2b45 <botlish_fn_37+0xfd>
    2b2f:	mov    eax,0x2
    2b34:	mov    rcx,QWORD PTR [rsp+0x18]
    2b39:	cmp    rcx,0x1
    2b3d:	cmove  rax,QWORD PTR [rip+0x1db]        # 2d20 <botlish_fn_37+0x2d8>
    2b45:	mov    ebx,0x6
    2b4a:	cmp    rax,0x6
    2b4e:	je     2cf0 <botlish_fn_37+0x2a8>
    2b54:	test   rcx,0x1
    2b5b:	mov    QWORD PTR [rsp+0x18],rcx
    2b60:	jne    2b86 <botlish_fn_37+0x13e>
    2b66:	mov    edx,0x3
    2b6b:	mov    rsi,QWORD PTR [rsp+0x18]
    2b70:	mov    rdi,r14
    2b73:	call   2b78 <botlish_fn_37+0x130>
			2b74: R_X86_64_PLT32	rt_value_eq-0x4
    2b78:	test   rax,rax
    2b7b:	je     2c90 <botlish_fn_37+0x248>
    2b81:	jmp    2b9c <botlish_fn_37+0x154>
    2b86:	mov    rsi,QWORD PTR [rsp+0x18]
    2b8b:	mov    eax,0x2
    2b90:	cmp    rsi,0x3
    2b94:	cmove  rax,QWORD PTR [rip+0x184]        # 2d20 <botlish_fn_37+0x2d8>
    2b9c:	cmp    rax,0x6
    2ba0:	je     2bb0 <botlish_fn_37+0x168>
    2ba6:	mov    ebx,0x2
    2bab:	jmp    2c6f <botlish_fn_37+0x227>
    2bb0:	mov    rsi,r12
    2bb3:	mov    rdi,r14
    2bb6:	call   2bbb <botlish_fn_37+0x173>
			2bb7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2bbb:	test   rax,rax
    2bbe:	je     2c90 <botlish_fn_37+0x248>
    2bc4:	xor    r10d,r10d
    2bc7:	test   rax,0x7
    2bcd:	je     2bdb <botlish_fn_37+0x193>
    2bd3:	mov    rsi,rax
    2bd6:	jmp    2bea <botlish_fn_37+0x1a2>
    2bdb:	movzx  rcx,BYTE PTR [rax]
    2bdf:	mov    rsi,rax
    2be2:	rex cmp cl,0x8
    2be6:	sete   r10b
    2bea:	test   r10b,r10b
    2bed:	jne    2c0d <botlish_fn_37+0x1c5>
    2bf3:	mov    rdi,r14
    2bf6:	mov    rax,QWORD PTR [rdi+0x10]
    2bfa:	mov    rcx,QWORD PTR [rax+0x30]
    2bfe:	mov    edx,0x8
    2c03:	call   2c08 <botlish_fn_37+0x1c0>
			2c04: R_X86_64_PLT32	rt_type_error-0x4
    2c08:	jmp    2c90 <botlish_fn_37+0x248>
    2c0d:	mov    rdx,r15
    2c10:	mov    rdi,r14
    2c13:	call   2c18 <botlish_fn_37+0x1d0>
			2c14: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c18:	test   rax,rax
    2c1b:	je     2c90 <botlish_fn_37+0x248>
    2c21:	mov    rcx,rax
    2c24:	and    rcx,r13
    2c27:	mov    rsi,rax
    2c2a:	test   rcx,0x1
    2c31:	jne    2c50 <botlish_fn_37+0x208>
    2c37:	mov    rdx,r13
    2c3a:	mov    rdi,r14
    2c3d:	call   2c42 <botlish_fn_37+0x1fa>
			2c3e: R_X86_64_PLT32	rt_value_eq-0x4
    2c42:	test   rax,rax
    2c45:	je     2c90 <botlish_fn_37+0x248>
    2c4b:	jmp    2c60 <botlish_fn_37+0x218>
    2c50:	mov    eax,0x2
    2c55:	cmp    rsi,r13
    2c58:	cmove  rax,QWORD PTR [rip+0xc0]        # 2d20 <botlish_fn_37+0x2d8>
    2c60:	cmp    rax,0x6
    2c64:	je     2c6f <botlish_fn_37+0x227>
    2c6a:	mov    ebx,0x2
    2c6f:	cmp    rbx,0x6
    2c73:	je     2ccb <botlish_fn_37+0x283>
    2c79:	mov    rdx,r15
    2c7c:	mov    rsi,r12
    2c7f:	mov    rdi,r14
    2c82:	call   2c87 <botlish_fn_37+0x23f>
			2c83: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2c87:	test   rax,rax
    2c8a:	jne    2cb5 <botlish_fn_37+0x26d>
    2c90:	xor    rax,rax
    2c93:	mov    rbx,QWORD PTR [rsp+0x20]
    2c98:	mov    r12,QWORD PTR [rsp+0x28]
    2c9d:	mov    r13,QWORD PTR [rsp+0x30]
    2ca2:	mov    r14,QWORD PTR [rsp+0x38]
    2ca7:	mov    r15,QWORD PTR [rsp+0x40]
    2cac:	add    rsp,0x50
    2cb0:	mov    rsp,rbp
    2cb3:	pop    rbp
    2cb4:	ret
    2cb5:	mov    QWORD PTR [rsp],r12
    2cb9:	mov    QWORD PTR [rsp+0x8],r13
    2cbe:	mov    QWORD PTR [rsp+0x10],rax
    2cc3:	mov    r15,rax
    2cc6:	jmp    2a83 <botlish_fn_37+0x3b>
    2ccb:	mov    rax,r15
    2cce:	mov    rbx,QWORD PTR [rsp+0x20]
    2cd3:	mov    r12,QWORD PTR [rsp+0x28]
    2cd8:	mov    r13,QWORD PTR [rsp+0x30]
    2cdd:	mov    r14,QWORD PTR [rsp+0x38]
    2ce2:	mov    r15,QWORD PTR [rsp+0x40]
    2ce7:	add    rsp,0x50
    2ceb:	mov    rsp,rbp
    2cee:	pop    rbp
    2cef:	ret
    2cf0:	mov    rax,0xffffffffffffffff
    2cf7:	mov    rbx,QWORD PTR [rsp+0x20]
    2cfc:	mov    r12,QWORD PTR [rsp+0x28]
    2d01:	mov    r13,QWORD PTR [rsp+0x30]
    2d06:	mov    r14,QWORD PTR [rsp+0x38]
    2d0b:	mov    r15,QWORD PTR [rsp+0x40]
    2d10:	add    rsp,0x50
    2d14:	mov    rsp,rbp
    2d17:	pop    rbp
    2d18:	ret
    2d19:	add    BYTE PTR [rax],al
    2d1b:	add    BYTE PTR [rax],al
    2d1d:	add    BYTE PTR [rax],al
    2d1f:	add    BYTE PTR [rsi],al
    2d21:	add    BYTE PTR [rax],al
    2d23:	add    BYTE PTR [rax],al
    2d25:	add    BYTE PTR [rax],al
	...

0000000000002d28 <botlish_entry_37: ht_find_get<mutarray, str, int>>:
    2d28:	push   rbp
    2d29:	mov    rbp,rsp
    2d2c:	mov    rsi,QWORD PTR [rdx]
    2d2f:	mov    r8,QWORD PTR [rdx+0x8]
    2d33:	mov    rcx,QWORD PTR [rdx+0x10]
    2d37:	mov    rdx,r8
    2d3a:	call   2d3f <botlish_entry_37+0x17>
			2d3b: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    2d3f:	mov    rsp,rbp
    2d42:	pop    rbp
    2d43:	ret
    2d44:	add    BYTE PTR [rax],al
	...

0000000000002d48 <botlish_fn_38: ht_find_insert<mutarray, str, int, int>>:
    2d48:	push   rbp
    2d49:	mov    rbp,rsp
    2d4c:	sub    rsp,0x60
    2d50:	mov    QWORD PTR [rsp+0x30],rbx
    2d55:	mov    QWORD PTR [rsp+0x38],r12
    2d5a:	mov    QWORD PTR [rsp+0x40],r13
    2d5f:	mov    QWORD PTR [rsp+0x48],r14
    2d64:	mov    QWORD PTR [rsp+0x50],r15
    2d69:	mov    r15,rdi
    2d6c:	mov    QWORD PTR [rsp],rsi
    2d70:	mov    QWORD PTR [rsp+0x8],rdx
    2d75:	mov    r13,rdx
    2d78:	mov    QWORD PTR [rsp+0x10],rcx
    2d7d:	mov    QWORD PTR [rsp+0x18],r8
    2d82:	mov    rbx,rsi
    2d85:	mov    QWORD PTR [rsp+0x20],rcx
    2d8a:	mov    QWORD PTR [rsp+0x28],r8
    2d8f:	mov    rsi,rbx
    2d92:	mov    rdi,r15
    2d95:	call   2d9a <botlish_fn_38+0x52>
			2d96: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2d9a:	test   rax,rax
    2d9d:	je     3095 <botlish_fn_38+0x34d>
    2da3:	xor    ecx,ecx
    2da5:	test   rax,0x7
    2dab:	je     2db9 <botlish_fn_38+0x71>
    2db1:	mov    rsi,rax
    2db4:	jmp    2dc7 <botlish_fn_38+0x7f>
    2db9:	movzx  rcx,BYTE PTR [rax]
    2dbd:	mov    rsi,rax
    2dc0:	rex cmp cl,0x8
    2dc4:	sete   cl
    2dc7:	test   cl,cl
    2dc9:	jne    2de9 <botlish_fn_38+0xa1>
    2dcf:	mov    rdi,r15
    2dd2:	mov    rax,QWORD PTR [rdi+0x10]
    2dd6:	mov    rcx,QWORD PTR [rax+0x30]
    2dda:	mov    edx,0x8
    2ddf:	call   2de4 <botlish_fn_38+0x9c>
			2de0: R_X86_64_PLT32	rt_type_error-0x4
    2de4:	jmp    3095 <botlish_fn_38+0x34d>
    2de9:	mov    rdx,QWORD PTR [rsp+0x20]
    2dee:	mov    rdi,r15
    2df1:	call   2df6 <botlish_fn_38+0xae>
			2df2: R_X86_64_PLT32	rt_mutarray_get-0x4
    2df6:	mov    rsi,rax
    2df9:	mov    r14,rax
    2dfc:	test   rax,rsi
    2dff:	je     3095 <botlish_fn_38+0x34d>
    2e05:	mov    rax,r14
    2e08:	test   rax,0x1
    2e0e:	jne    2e32 <botlish_fn_38+0xea>
    2e14:	mov    edx,0x1
    2e19:	mov    rsi,r14
    2e1c:	mov    rdi,r15
    2e1f:	call   2e24 <botlish_fn_38+0xdc>
			2e20: R_X86_64_PLT32	rt_value_eq-0x4
    2e24:	test   rax,rax
    2e27:	je     3095 <botlish_fn_38+0x34d>
    2e2d:	jmp    2e46 <botlish_fn_38+0xfe>
    2e32:	mov    eax,0x2
    2e37:	mov    rcx,r14
    2e3a:	cmp    rcx,0x1
    2e3e:	cmove  rax,QWORD PTR [rip+0x372]        # 31b8 <botlish_fn_38+0x470>
    2e46:	mov    r12d,0x6
    2e4c:	cmp    rax,0x6
    2e50:	je     310d <botlish_fn_38+0x3c5>
    2e56:	mov    rax,r14
    2e59:	test   rax,0x1
    2e5f:	jne    2e83 <botlish_fn_38+0x13b>
    2e65:	mov    edx,0x3
    2e6a:	mov    rsi,r14
    2e6d:	mov    rdi,r15
    2e70:	call   2e75 <botlish_fn_38+0x12d>
			2e71: R_X86_64_PLT32	rt_value_eq-0x4
    2e75:	test   rax,rax
    2e78:	je     3095 <botlish_fn_38+0x34d>
    2e7e:	jmp    2e97 <botlish_fn_38+0x14f>
    2e83:	mov    eax,0x2
    2e88:	mov    rcx,r14
    2e8b:	cmp    rcx,0x3
    2e8f:	cmove  rax,QWORD PTR [rip+0x321]        # 31b8 <botlish_fn_38+0x470>
    2e97:	cmp    rax,0x6
    2e9b:	je     2eac <botlish_fn_38+0x164>
    2ea1:	mov    r11d,0x2
    2ea7:	jmp    2f76 <botlish_fn_38+0x22e>
    2eac:	mov    rsi,rbx
    2eaf:	mov    rdi,r15
    2eb2:	call   2eb7 <botlish_fn_38+0x16f>
			2eb3: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2eb7:	test   rax,rax
    2eba:	je     3095 <botlish_fn_38+0x34d>
    2ec0:	xor    ecx,ecx
    2ec2:	test   rax,0x7
    2ec8:	je     2ed6 <botlish_fn_38+0x18e>
    2ece:	mov    rsi,rax
    2ed1:	jmp    2ee4 <botlish_fn_38+0x19c>
    2ed6:	movzx  rcx,BYTE PTR [rax]
    2eda:	mov    rsi,rax
    2edd:	rex cmp cl,0x8
    2ee1:	sete   cl
    2ee4:	test   cl,cl
    2ee6:	jne    2f06 <botlish_fn_38+0x1be>
    2eec:	mov    rdi,r15
    2eef:	mov    rcx,QWORD PTR [rdi+0x10]
    2ef3:	mov    rcx,QWORD PTR [rcx+0x30]
    2ef7:	mov    edx,0x8
    2efc:	call   2f01 <botlish_fn_38+0x1b9>
			2efd: R_X86_64_PLT32	rt_type_error-0x4
    2f01:	jmp    3095 <botlish_fn_38+0x34d>
    2f06:	mov    rdx,QWORD PTR [rsp+0x20]
    2f0b:	mov    rdi,r15
    2f0e:	call   2f13 <botlish_fn_38+0x1cb>
			2f0f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2f13:	test   rax,rax
    2f16:	je     3095 <botlish_fn_38+0x34d>
    2f1c:	mov    rsi,rax
    2f1f:	and    rsi,r13
    2f22:	test   rsi,0x1
    2f29:	jne    2f4b <botlish_fn_38+0x203>
    2f2f:	mov    rsi,rax
    2f32:	mov    rdx,r13
    2f35:	mov    rdi,r15
    2f38:	call   2f3d <botlish_fn_38+0x1f5>
			2f39: R_X86_64_PLT32	rt_value_eq-0x4
    2f3d:	test   rax,rax
    2f40:	je     3095 <botlish_fn_38+0x34d>
    2f46:	jmp    2f5e <botlish_fn_38+0x216>
    2f4b:	mov    rsi,rax
    2f4e:	mov    eax,0x2
    2f53:	cmp    rsi,r13
    2f56:	cmove  rax,QWORD PTR [rip+0x25a]        # 31b8 <botlish_fn_38+0x470>
    2f5e:	cmp    rax,0x6
    2f62:	je     2f73 <botlish_fn_38+0x22b>
    2f68:	mov    r11d,0x2
    2f6e:	jmp    2f76 <botlish_fn_38+0x22e>
    2f73:	mov    r11,r12
    2f76:	cmp    r11,0x6
    2f7a:	je     30e6 <botlish_fn_38+0x39e>
    2f80:	mov    rax,r14
    2f83:	test   rax,0x1
    2f89:	jne    2fad <botlish_fn_38+0x265>
    2f8f:	mov    edx,0x5
    2f94:	mov    rsi,r14
    2f97:	mov    rdi,r15
    2f9a:	call   2f9f <botlish_fn_38+0x257>
			2f9b: R_X86_64_PLT32	rt_value_eq-0x4
    2f9f:	test   rax,rax
    2fa2:	je     3095 <botlish_fn_38+0x34d>
    2fa8:	jmp    2fc1 <botlish_fn_38+0x279>
    2fad:	mov    rsi,r14
    2fb0:	mov    eax,0x2
    2fb5:	cmp    rsi,0x5
    2fb9:	cmove  rax,QWORD PTR [rip+0x1f7]        # 31b8 <botlish_fn_38+0x470>
    2fc1:	cmp    rax,0x6
    2fc5:	je     2fd6 <botlish_fn_38+0x28e>
    2fcb:	mov    r12d,0x2
    2fd1:	jmp    3037 <botlish_fn_38+0x2ef>
    2fd6:	mov    r14,QWORD PTR [rsp+0x28]
    2fdb:	test   r14,0x1
    2fe2:	jne    3012 <botlish_fn_38+0x2ca>
    2fe8:	mov    edx,0x1
    2fed:	mov    rsi,r14
    2ff0:	mov    rdi,r15
    2ff3:	call   2ff8 <botlish_fn_38+0x2b0>
			2ff4: R_X86_64_PLT32	rt_int_cmp-0x4
    2ff8:	mov    ecx,0x2
    2ffd:	test   rax,rax
    3000:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 31b8 <botlish_fn_38+0x470>
    3008:	mov    QWORD PTR [rsp+0x28],r14
    300d:	jmp    3027 <botlish_fn_38+0x2df>
    3012:	mov    ecx,0x2
    3017:	test   r14,r14
    301a:	mov    QWORD PTR [rsp+0x28],r14
    301f:	cmovle rcx,QWORD PTR [rip+0x191]        # 31b8 <botlish_fn_38+0x470>
    3027:	cmp    rcx,0x6
    302b:	je     3037 <botlish_fn_38+0x2ef>
    3031:	mov    r12d,0x2
    3037:	cmp    r12,0x6
    303b:	je     307c <botlish_fn_38+0x334>
    3041:	mov    rdx,QWORD PTR [rsp+0x20]
    3046:	mov    rsi,rbx
    3049:	mov    rdi,r15
    304c:	call   3051 <botlish_fn_38+0x309>
			304d: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    3051:	test   rax,rax
    3054:	je     3095 <botlish_fn_38+0x34d>
    305a:	mov    QWORD PTR [rsp],rbx
    305e:	mov    QWORD PTR [rsp+0x8],r13
    3063:	mov    QWORD PTR [rsp+0x10],rax
    3068:	mov    r11,QWORD PTR [rsp+0x28]
    306d:	mov    QWORD PTR [rsp+0x18],r11
    3072:	mov    QWORD PTR [rsp+0x20],rax
    3077:	jmp    2d8f <botlish_fn_38+0x47>
    307c:	mov    rdx,QWORD PTR [rsp+0x20]
    3081:	mov    rsi,rbx
    3084:	mov    rdi,r15
    3087:	call   308c <botlish_fn_38+0x344>
			3088: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    308c:	test   rax,rax
    308f:	jne    30ba <botlish_fn_38+0x372>
    3095:	xor    rax,rax
    3098:	mov    rbx,QWORD PTR [rsp+0x30]
    309d:	mov    r12,QWORD PTR [rsp+0x38]
    30a2:	mov    r13,QWORD PTR [rsp+0x40]
    30a7:	mov    r14,QWORD PTR [rsp+0x48]
    30ac:	mov    r15,QWORD PTR [rsp+0x50]
    30b1:	add    rsp,0x60
    30b5:	mov    rsp,rbp
    30b8:	pop    rbp
    30b9:	ret
    30ba:	mov    QWORD PTR [rsp],rbx
    30be:	mov    QWORD PTR [rsp+0x8],r13
    30c3:	mov    QWORD PTR [rsp+0x10],rax
    30c8:	mov    rdx,QWORD PTR [rsp+0x20]
    30cd:	mov    QWORD PTR [rsp+0x18],rdx
    30d2:	mov    rcx,QWORD PTR [rsp+0x20]
    30d7:	mov    QWORD PTR [rsp+0x28],rcx
    30dc:	mov    QWORD PTR [rsp+0x20],rax
    30e1:	jmp    2d8f <botlish_fn_38+0x47>
    30e6:	mov    rax,QWORD PTR [rsp+0x20]
    30eb:	mov    rbx,QWORD PTR [rsp+0x30]
    30f0:	mov    r12,QWORD PTR [rsp+0x38]
    30f5:	mov    r13,QWORD PTR [rsp+0x40]
    30fa:	mov    r14,QWORD PTR [rsp+0x48]
    30ff:	mov    r15,QWORD PTR [rsp+0x50]
    3104:	add    rsp,0x60
    3108:	mov    rsp,rbp
    310b:	pop    rbp
    310c:	ret
    310d:	mov    rax,QWORD PTR [rsp+0x28]
    3112:	test   rax,0x1
    3118:	jne    3145 <botlish_fn_38+0x3fd>
    311e:	mov    edx,0x1
    3123:	mov    rdi,r15
    3126:	mov    rsi,QWORD PTR [rsp+0x28]
    312b:	call   3130 <botlish_fn_38+0x3e8>
			312c: R_X86_64_PLT32	rt_int_cmp-0x4
    3130:	mov    ecx,0x2
    3135:	test   rax,rax
    3138:	cmovge rcx,QWORD PTR [rip+0x78]        # 31b8 <botlish_fn_38+0x470>
    3140:	jmp    315f <botlish_fn_38+0x417>
    3145:	mov    ecx,0x2
    314a:	mov    rax,QWORD PTR [rsp+0x28]
    314f:	mov    rdx,QWORD PTR [rsp+0x28]
    3154:	test   rax,rdx
    3157:	cmovg  rcx,QWORD PTR [rip+0x59]        # 31b8 <botlish_fn_38+0x470>
    315f:	cmp    rcx,0x6
    3163:	je     3190 <botlish_fn_38+0x448>
    3169:	mov    rax,QWORD PTR [rsp+0x20]
    316e:	mov    rbx,QWORD PTR [rsp+0x30]
    3173:	mov    r12,QWORD PTR [rsp+0x38]
    3178:	mov    r13,QWORD PTR [rsp+0x40]
    317d:	mov    r14,QWORD PTR [rsp+0x48]
    3182:	mov    r15,QWORD PTR [rsp+0x50]
    3187:	add    rsp,0x60
    318b:	mov    rsp,rbp
    318e:	pop    rbp
    318f:	ret
    3190:	mov    rax,QWORD PTR [rsp+0x28]
    3195:	mov    rbx,QWORD PTR [rsp+0x30]
    319a:	mov    r12,QWORD PTR [rsp+0x38]
    319f:	mov    r13,QWORD PTR [rsp+0x40]
    31a4:	mov    r14,QWORD PTR [rsp+0x48]
    31a9:	mov    r15,QWORD PTR [rsp+0x50]
    31ae:	add    rsp,0x60
    31b2:	mov    rsp,rbp
    31b5:	pop    rbp
    31b6:	ret
    31b7:	add    BYTE PTR [rsi],al
    31b9:	add    BYTE PTR [rax],al
    31bb:	add    BYTE PTR [rax],al
    31bd:	add    BYTE PTR [rax],al
	...

00000000000031c0 <botlish_entry_38: ht_find_insert<mutarray, str, int, int>>:
    31c0:	push   rbp
    31c1:	mov    rbp,rsp
    31c4:	mov    rsi,QWORD PTR [rdx]
    31c7:	mov    r9,QWORD PTR [rdx+0x8]
    31cb:	mov    rcx,QWORD PTR [rdx+0x10]
    31cf:	mov    r8,QWORD PTR [rdx+0x18]
    31d3:	mov    rdx,r9
    31d6:	call   31db <botlish_entry_38+0x1b>
			31d7: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    31db:	mov    rsp,rbp
    31de:	pop    rbp
    31df:	ret

00000000000031e0 <botlish_fn_39: ht_get<mutarray, str>>:
    31e0:	push   rbp
    31e1:	mov    rbp,rsp
    31e4:	sub    rsp,0x40
    31e8:	mov    QWORD PTR [rsp+0x20],rbx
    31ed:	mov    QWORD PTR [rsp+0x28],r12
    31f2:	mov    QWORD PTR [rsp+0x30],r13
    31f7:	mov    rbx,rdi
    31fa:	mov    QWORD PTR [rsp],rsi
    31fe:	mov    r13,rsi
    3201:	mov    QWORD PTR [rsp+0x8],rdx
    3206:	mov    r12,rdx
    3209:	mov    rdx,r12
    320c:	mov    rsi,r13
    320f:	mov    rdi,rbx
    3212:	call   3217 <botlish_fn_39+0x37>
			3213: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    3217:	test   rax,rax
    321a:	je     3304 <botlish_fn_39+0x124>
    3220:	mov    QWORD PTR [rsp+0x10],rax
    3225:	mov    rcx,rax
    3228:	mov    rdx,r12
    322b:	mov    rsi,r13
    322e:	mov    rdi,rbx
    3231:	call   3236 <botlish_fn_39+0x56>
			3232: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    3236:	mov    rcx,rax
    3239:	mov    r12,rax
    323c:	test   rax,rcx
    323f:	je     3304 <botlish_fn_39+0x124>
    3245:	mov    rax,r12
    3248:	test   rax,0x1
    324e:	jne    3279 <botlish_fn_39+0x99>
    3254:	mov    edx,0x1
    3259:	mov    rsi,r12
    325c:	mov    rdi,rbx
    325f:	call   3264 <botlish_fn_39+0x84>
			3260: R_X86_64_PLT32	rt_int_cmp-0x4
    3264:	mov    ecx,0x2
    3269:	test   rax,rax
    326c:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 3358 <botlish_fn_39+0x178>
    3274:	jmp    328c <botlish_fn_39+0xac>
    3279:	mov    ecx,0x2
    327e:	mov    rax,r12
    3281:	test   rax,rax
    3284:	cmovle rcx,QWORD PTR [rip+0xcc]        # 3358 <botlish_fn_39+0x178>
    328c:	cmp    rcx,0x6
    3290:	je     3337 <botlish_fn_39+0x157>
    3296:	mov    rsi,r13
    3299:	mov    rdi,rbx
    329c:	call   32a1 <botlish_fn_39+0xc1>
			329d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    32a1:	test   rax,rax
    32a4:	je     3304 <botlish_fn_39+0x124>
    32aa:	xor    ecx,ecx
    32ac:	test   rax,0x7
    32b2:	je     32c0 <botlish_fn_39+0xe0>
    32b8:	mov    rsi,rax
    32bb:	jmp    32ce <botlish_fn_39+0xee>
    32c0:	movzx  rcx,BYTE PTR [rax]
    32c4:	mov    rsi,rax
    32c7:	rex cmp cl,0x8
    32cb:	sete   cl
    32ce:	test   cl,cl
    32d0:	jne    32f0 <botlish_fn_39+0x110>
    32d6:	mov    rdi,rbx
    32d9:	mov    rax,QWORD PTR [rdi+0x10]
    32dd:	mov    rcx,QWORD PTR [rax+0x30]
    32e1:	mov    edx,0x8
    32e6:	call   32eb <botlish_fn_39+0x10b>
			32e7: R_X86_64_PLT32	rt_type_error-0x4
    32eb:	jmp    3304 <botlish_fn_39+0x124>
    32f0:	mov    rdx,r12
    32f3:	mov    rdi,rbx
    32f6:	call   32fb <botlish_fn_39+0x11b>
			32f7: R_X86_64_PLT32	rt_mutarray_get-0x4
    32fb:	test   rax,rax
    32fe:	jne    331f <botlish_fn_39+0x13f>
    3304:	xor    rax,rax
    3307:	mov    rbx,QWORD PTR [rsp+0x20]
    330c:	mov    r12,QWORD PTR [rsp+0x28]
    3311:	mov    r13,QWORD PTR [rsp+0x30]
    3316:	add    rsp,0x40
    331a:	mov    rsp,rbp
    331d:	pop    rbp
    331e:	ret
    331f:	mov    rbx,QWORD PTR [rsp+0x20]
    3324:	mov    r12,QWORD PTR [rsp+0x28]
    3329:	mov    r13,QWORD PTR [rsp+0x30]
    332e:	add    rsp,0x40
    3332:	mov    rsp,rbp
    3335:	pop    rbp
    3336:	ret
    3337:	mov    eax,0xa
    333c:	mov    rbx,QWORD PTR [rsp+0x20]
    3341:	mov    r12,QWORD PTR [rsp+0x28]
    3346:	mov    r13,QWORD PTR [rsp+0x30]
    334b:	add    rsp,0x40
    334f:	mov    rsp,rbp
    3352:	pop    rbp
    3353:	ret
    3354:	add    BYTE PTR [rax],al
    3356:	add    BYTE PTR [rax],al
    3358:	(bad)
    3359:	add    BYTE PTR [rax],al
    335b:	add    BYTE PTR [rax],al
    335d:	add    BYTE PTR [rax],al
	...

0000000000003360 <botlish_entry_39: ht_get<mutarray, str>>:
    3360:	push   rbp
    3361:	mov    rbp,rsp
    3364:	mov    rsi,QWORD PTR [rdx]
    3367:	mov    rdx,QWORD PTR [rdx+0x8]
    336b:	call   3370 <botlish_entry_39+0x10>
			336c: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    3370:	mov    rsp,rbp
    3373:	pop    rbp
    3374:	ret
    3375:	add    BYTE PTR [rax],al
	...

0000000000003378 <botlish_fn_40: ht_rehash_probe<mutarray, int, int>>:
    3378:	push   rbp
    3379:	mov    rbp,rsp
    337c:	sub    rsp,0x40
    3380:	mov    QWORD PTR [rsp+0x20],rbx
    3385:	mov    QWORD PTR [rsp+0x28],r12
    338a:	mov    QWORD PTR [rsp+0x30],r13
    338f:	mov    QWORD PTR [rsp+0x38],r14
    3394:	mov    r13,rdi
    3397:	mov    QWORD PTR [rsp],rsi
    339b:	mov    QWORD PTR [rsp+0x8],rdx
    33a0:	mov    QWORD PTR [rsp+0x10],rcx
    33a5:	mov    r12,rcx
    33a8:	mov    rbx,rsi
    33ab:	mov    r14,rdx
    33ae:	mov    rdx,r14
    33b1:	mov    rsi,rbx
    33b4:	mov    rdi,r13
    33b7:	call   33bc <botlish_fn_40+0x44>
			33b8: R_X86_64_PLT32	rt_mutarray_get-0x4
    33bc:	test   rax,rax
    33bf:	je     345c <botlish_fn_40+0xe4>
    33c5:	test   rax,0x1
    33cb:	mov    rsi,rax
    33ce:	jne    33ef <botlish_fn_40+0x77>
    33d4:	mov    edx,0x1
    33d9:	mov    rdi,r13
    33dc:	call   33e1 <botlish_fn_40+0x69>
			33dd: R_X86_64_PLT32	rt_value_eq-0x4
    33e1:	test   rax,rax
    33e4:	je     345c <botlish_fn_40+0xe4>
    33ea:	jmp    3400 <botlish_fn_40+0x88>
    33ef:	mov    eax,0x2
    33f4:	cmp    rsi,0x1
    33f8:	cmove  rax,QWORD PTR [rip+0xb8]        # 34b8 <botlish_fn_40+0x140>
    3400:	cmp    rax,0x6
    3404:	je     3492 <botlish_fn_40+0x11a>
    340a:	mov    QWORD PTR [rsp+0x18],0x3
    3413:	mov    rsi,r14
    3416:	test   rsi,0x1
    341d:	je     3435 <botlish_fn_40+0xbd>
    3423:	mov    rsi,r14
    3426:	add    rsi,0x2
    342a:	seto   al
    342d:	test   al,al
    342f:	je     3448 <botlish_fn_40+0xd0>
    3435:	mov    edx,0x3
    343a:	mov    rsi,r14
    343d:	mov    rdi,r13
    3440:	call   3445 <botlish_fn_40+0xcd>
			3441: R_X86_64_PLT32	rt_int_add-0x4
    3445:	mov    rsi,rax
    3448:	mov    rdx,r12
    344b:	mov    rdi,r13
    344e:	call   3453 <botlish_fn_40+0xdb>
			344f: R_X86_64_PLT32	rt_int_mod-0x4
    3453:	test   rax,rax
    3456:	jne    347c <botlish_fn_40+0x104>
    345c:	xor    rax,rax
    345f:	mov    rbx,QWORD PTR [rsp+0x20]
    3464:	mov    r12,QWORD PTR [rsp+0x28]
    3469:	mov    r13,QWORD PTR [rsp+0x30]
    346e:	mov    r14,QWORD PTR [rsp+0x38]
    3473:	add    rsp,0x40
    3477:	mov    rsp,rbp
    347a:	pop    rbp
    347b:	ret
    347c:	mov    QWORD PTR [rsp],rbx
    3480:	mov    QWORD PTR [rsp+0x8],rax
    3485:	mov    QWORD PTR [rsp+0x10],r12
    348a:	mov    r14,rax
    348d:	jmp    33ae <botlish_fn_40+0x36>
    3492:	mov    rax,r14
    3495:	mov    rbx,QWORD PTR [rsp+0x20]
    349a:	mov    r12,QWORD PTR [rsp+0x28]
    349f:	mov    r13,QWORD PTR [rsp+0x30]
    34a4:	mov    r14,QWORD PTR [rsp+0x38]
    34a9:	add    rsp,0x40
    34ad:	mov    rsp,rbp
    34b0:	pop    rbp
    34b1:	ret
    34b2:	add    BYTE PTR [rax],al
    34b4:	add    BYTE PTR [rax],al
    34b6:	add    BYTE PTR [rax],al
    34b8:	(bad)
    34b9:	add    BYTE PTR [rax],al
    34bb:	add    BYTE PTR [rax],al
    34bd:	add    BYTE PTR [rax],al
	...

00000000000034c0 <botlish_entry_40: ht_rehash_probe<mutarray, int, int>>:
    34c0:	push   rbp
    34c1:	mov    rbp,rsp
    34c4:	mov    rsi,QWORD PTR [rdx]
    34c7:	mov    r8,QWORD PTR [rdx+0x8]
    34cb:	mov    rcx,QWORD PTR [rdx+0x10]
    34cf:	mov    rdx,r8
    34d2:	call   34d7 <botlish_entry_40+0x17>
			34d3: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    34d7:	mov    rsp,rbp
    34da:	pop    rbp
    34db:	ret

00000000000034dc <botlish_fn_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    34dc:	push   rbp
    34dd:	mov    rbp,rsp
    34e0:	sub    rsp,0x80
    34e7:	mov    QWORD PTR [rsp+0x50],rbx
    34ec:	mov    QWORD PTR [rsp+0x58],r12
    34f1:	mov    QWORD PTR [rsp+0x60],r13
    34f6:	mov    QWORD PTR [rsp+0x68],r14
    34fb:	mov    QWORD PTR [rsp+0x70],r15
    3500:	mov    r12,rdi
    3503:	mov    rdi,QWORD PTR [rbp+0x10]
    3507:	mov    QWORD PTR [rsp],rsi
    350b:	mov    QWORD PTR [rsp+0x38],rsi
    3510:	mov    QWORD PTR [rsp+0x8],rdx
    3515:	mov    r15,rdx
    3518:	mov    QWORD PTR [rsp+0x10],rcx
    351d:	mov    rbx,rcx
    3520:	mov    QWORD PTR [rsp+0x18],r8
    3525:	mov    QWORD PTR [rsp+0x40],r8
    352a:	mov    QWORD PTR [rsp+0x20],r9
    352f:	mov    r14,r9
    3532:	mov    QWORD PTR [rsp+0x28],rdi
    3537:	mov    r13,rdi
    353a:	mov    rsi,r14
    353d:	mov    rdi,r12
    3540:	call   3545 <botlish_fn_41+0x69>
			3541: R_X86_64_PLT32	rt_hash-0x4
    3545:	test   rax,rax
    3548:	mov    rsi,rax
    354b:	je     35ea <botlish_fn_41+0x10e>
    3551:	mov    rdx,QWORD PTR [rsp+0x40]
    3556:	mov    rdi,r12
    3559:	call   355e <botlish_fn_41+0x82>
			355a: R_X86_64_PLT32	rt_int_mod-0x4
    355e:	test   rax,rax
    3561:	je     35ea <botlish_fn_41+0x10e>
    3567:	mov    QWORD PTR [rsp+0x30],rax
    356c:	mov    rcx,QWORD PTR [rsp+0x40]
    3571:	mov    rdx,rax
    3574:	mov    rsi,QWORD PTR [rsp+0x38]
    3579:	mov    rdi,r12
    357c:	call   3581 <botlish_fn_41+0xa5>
			357d: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    3581:	mov    rcx,rax
    3584:	mov    QWORD PTR [rsp+0x40],rax
    3589:	test   rax,rcx
    358c:	je     35ea <botlish_fn_41+0x10e>
    3592:	mov    ecx,0x3
    3597:	mov    rsi,QWORD PTR [rsp+0x38]
    359c:	mov    rdx,QWORD PTR [rsp+0x40]
    35a1:	mov    rdi,r12
    35a4:	call   35a9 <botlish_fn_41+0xcd>
			35a5: R_X86_64_PLT32	rt_mutarray_set-0x4
    35a9:	test   rax,rax
    35ac:	je     35ea <botlish_fn_41+0x10e>
    35b2:	mov    rcx,r14
    35b5:	mov    rsi,r15
    35b8:	mov    rdx,QWORD PTR [rsp+0x40]
    35bd:	mov    rdi,r12
    35c0:	call   35c5 <botlish_fn_41+0xe9>
			35c1: R_X86_64_PLT32	rt_mutarray_set-0x4
    35c5:	test   rax,rax
    35c8:	je     35ea <botlish_fn_41+0x10e>
    35ce:	mov    rcx,r13
    35d1:	mov    rdx,QWORD PTR [rsp+0x40]
    35d6:	mov    rsi,rbx
    35d9:	mov    rdi,r12
    35dc:	call   35e1 <botlish_fn_41+0x105>
			35dd: R_X86_64_PLT32	rt_mutarray_set-0x4
    35e1:	test   rax,rax
    35e4:	jne    3612 <botlish_fn_41+0x136>
    35ea:	xor    rax,rax
    35ed:	mov    rbx,QWORD PTR [rsp+0x50]
    35f2:	mov    r12,QWORD PTR [rsp+0x58]
    35f7:	mov    r13,QWORD PTR [rsp+0x60]
    35fc:	mov    r14,QWORD PTR [rsp+0x68]
    3601:	mov    r15,QWORD PTR [rsp+0x70]
    3606:	add    rsp,0x80
    360d:	mov    rsp,rbp
    3610:	pop    rbp
    3611:	ret
    3612:	mov    eax,0xa
    3617:	mov    rbx,QWORD PTR [rsp+0x50]
    361c:	mov    r12,QWORD PTR [rsp+0x58]
    3621:	mov    r13,QWORD PTR [rsp+0x60]
    3626:	mov    r14,QWORD PTR [rsp+0x68]
    362b:	mov    r15,QWORD PTR [rsp+0x70]
    3630:	add    rsp,0x80
    3637:	mov    rsp,rbp
    363a:	pop    rbp
    363b:	ret

000000000000363c <botlish_entry_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    363c:	push   rbp
    363d:	mov    rbp,rsp
    3640:	sub    rsp,0x10
    3644:	mov    rsi,QWORD PTR [rdx]
    3647:	mov    r10,QWORD PTR [rdx+0x8]
    364b:	mov    rcx,QWORD PTR [rdx+0x10]
    364f:	mov    r8,QWORD PTR [rdx+0x18]
    3653:	mov    r9,QWORD PTR [rdx+0x20]
    3657:	mov    r11,QWORD PTR [rdx+0x28]
    365b:	mov    QWORD PTR [rsp],r11
    365f:	mov    rdx,r10
    3662:	call   3667 <botlish_entry_41+0x2b>
			3663: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    3667:	add    rsp,0x10
    366b:	mov    rsp,rbp
    366e:	pop    rbp
    366f:	ret

0000000000003670 <botlish_fn_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3670:	push   rbp
    3671:	mov    rbp,rsp
    3674:	sub    rsp,0xc0
    367b:	mov    QWORD PTR [rsp+0x90],rbx
    3683:	mov    QWORD PTR [rsp+0x98],r12
    368b:	mov    QWORD PTR [rsp+0xa0],r13
    3693:	mov    QWORD PTR [rsp+0xa8],r14
    369b:	mov    QWORD PTR [rsp+0xb0],r15
    36a3:	mov    QWORD PTR [rsp+0x58],rdi
    36a8:	mov    r15,QWORD PTR [rbp+0x10]
    36ac:	mov    r12,QWORD PTR [rbp+0x18]
    36b0:	mov    r13,QWORD PTR [rbp+0x20]
    36b4:	mov    r14,QWORD PTR [rbp+0x28]
    36b8:	mov    QWORD PTR [rsp+0x10],rsi
    36bd:	mov    QWORD PTR [rsp+0x60],rsi
    36c2:	mov    QWORD PTR [rsp+0x18],rdx
    36c7:	mov    QWORD PTR [rsp+0x68],rdx
    36cc:	mov    QWORD PTR [rsp+0x20],rcx
    36d1:	mov    QWORD PTR [rsp+0x70],rcx
    36d6:	mov    QWORD PTR [rsp+0x28],r15
    36db:	mov    QWORD PTR [rsp+0x30],r12
    36e0:	mov    QWORD PTR [rsp+0x38],r13
    36e5:	mov    QWORD PTR [rsp+0x40],r14
    36ea:	sar    r8,1
    36ed:	sar    r9,1
    36f0:	mov    QWORD PTR [rsp+0x88],r9
    36f8:	mov    rcx,QWORD PTR [rsp+0x88]
    3700:	mov    rbx,r8
    3703:	cmp    rbx,rcx
    3706:	mov    QWORD PTR [rsp+0x88],rcx
    370e:	jge    3977 <botlish_fn_42+0x307>
    3714:	xor    eax,eax
    3716:	mov    rsi,QWORD PTR [rsp+0x60]
    371b:	test   rsi,0x7
    3722:	jne    3733 <botlish_fn_42+0xc3>
    3728:	movzx  r10,BYTE PTR [rsi]
    372c:	cmp    r10b,0x8
    3730:	sete   al
    3733:	test   al,al
    3735:	jne    3757 <botlish_fn_42+0xe7>
    373b:	mov    rdi,QWORD PTR [rsp+0x58]
    3740:	mov    rax,QWORD PTR [rdi+0x10]
    3744:	mov    rcx,QWORD PTR [rax+0x30]
    3748:	mov    edx,0x8
    374d:	call   3752 <botlish_fn_42+0xe2>
			374e: R_X86_64_PLT32	rt_type_error-0x4
    3752:	jmp    38f5 <botlish_fn_42+0x285>
    3757:	mov    QWORD PTR [rsp+0x60],rsi
    375c:	mov    rdx,rbx
    375f:	shl    rdx,1
    3762:	or     rdx,0x1
    3766:	mov    QWORD PTR [rsp+0x80],rdx
    376e:	mov    rdi,QWORD PTR [rsp+0x58]
    3773:	call   3778 <botlish_fn_42+0x108>
			3774: R_X86_64_PLT32	rt_mutarray_get-0x4
    3778:	test   rax,rax
    377b:	je     38f5 <botlish_fn_42+0x285>
    3781:	test   rax,0x1
    3787:	mov    rsi,rax
    378a:	jne    37ad <botlish_fn_42+0x13d>
    3790:	mov    edx,0x3
    3795:	mov    rdi,QWORD PTR [rsp+0x58]
    379a:	call   379f <botlish_fn_42+0x12f>
			379b: R_X86_64_PLT32	rt_value_eq-0x4
    379f:	test   rax,rax
    37a2:	je     38f5 <botlish_fn_42+0x285>
    37a8:	jmp    37be <botlish_fn_42+0x14e>
    37ad:	mov    eax,0x2
    37b2:	cmp    rsi,0x3
    37b6:	cmove  rax,QWORD PTR [rip+0x1f2]        # 39b0 <botlish_fn_42+0x340>
    37be:	cmp    rax,0x6
    37c2:	je     37d2 <botlish_fn_42+0x162>
    37c8:	mov    rsi,QWORD PTR [rsp+0x60]
    37cd:	jmp    3931 <botlish_fn_42+0x2c1>
    37d2:	xor    esi,esi
    37d4:	mov    rdx,QWORD PTR [rsp+0x68]
    37d9:	test   rdx,0x7
    37e0:	je     37f0 <botlish_fn_42+0x180>
    37e6:	mov    QWORD PTR [rsp+0x68],rdx
    37eb:	jmp    37ff <botlish_fn_42+0x18f>
    37f0:	movzx  rax,BYTE PTR [rdx]
    37f4:	mov    QWORD PTR [rsp+0x68],rdx
    37f9:	cmp    al,0x8
    37fb:	sete   sil
    37ff:	test   sil,sil
    3802:	jne    3829 <botlish_fn_42+0x1b9>
    3808:	mov    rdi,QWORD PTR [rsp+0x58]
    380d:	mov    rax,QWORD PTR [rdi+0x10]
    3811:	mov    rcx,QWORD PTR [rax+0x30]
    3815:	mov    edx,0x8
    381a:	mov    rsi,QWORD PTR [rsp+0x68]
    381f:	call   3824 <botlish_fn_42+0x1b4>
			3820: R_X86_64_PLT32	rt_type_error-0x4
    3824:	jmp    38f5 <botlish_fn_42+0x285>
    3829:	mov    rdx,QWORD PTR [rsp+0x80]
    3831:	mov    rsi,QWORD PTR [rsp+0x68]
    3836:	mov    rdi,QWORD PTR [rsp+0x58]
    383b:	call   3840 <botlish_fn_42+0x1d0>
			383c: R_X86_64_PLT32	rt_mutarray_get-0x4
    3840:	test   rax,rax
    3843:	je     38f5 <botlish_fn_42+0x285>
    3849:	mov    QWORD PTR [rsp+0x48],rax
    384e:	mov    QWORD PTR [rsp+0x78],rax
    3853:	xor    eax,eax
    3855:	mov    rcx,QWORD PTR [rsp+0x70]
    385a:	test   rcx,0x7
    3861:	je     3871 <botlish_fn_42+0x201>
    3867:	mov    QWORD PTR [rsp+0x70],rcx
    386c:	jmp    387f <botlish_fn_42+0x20f>
    3871:	movzx  rax,BYTE PTR [rcx]
    3875:	mov    QWORD PTR [rsp+0x70],rcx
    387a:	cmp    al,0x8
    387c:	sete   al
    387f:	test   al,al
    3881:	jne    38a8 <botlish_fn_42+0x238>
    3887:	mov    rdi,QWORD PTR [rsp+0x58]
    388c:	mov    rax,QWORD PTR [rdi+0x10]
    3890:	mov    rcx,QWORD PTR [rax+0x30]
    3894:	mov    edx,0x8
    3899:	mov    rsi,QWORD PTR [rsp+0x70]
    389e:	call   38a3 <botlish_fn_42+0x233>
			389f: R_X86_64_PLT32	rt_type_error-0x4
    38a3:	jmp    38f5 <botlish_fn_42+0x285>
    38a8:	mov    rdx,QWORD PTR [rsp+0x80]
    38b0:	mov    rsi,QWORD PTR [rsp+0x70]
    38b5:	mov    rdi,QWORD PTR [rsp+0x58]
    38ba:	call   38bf <botlish_fn_42+0x24f>
			38bb: R_X86_64_PLT32	rt_mutarray_get-0x4
    38bf:	test   rax,rax
    38c2:	je     38f5 <botlish_fn_42+0x285>
    38c8:	mov    QWORD PTR [rsp+0x50],rax
    38cd:	mov    QWORD PTR [rsp],rax
    38d1:	mov    r9,QWORD PTR [rsp+0x78]
    38d6:	mov    rcx,r13
    38d9:	mov    rdx,r12
    38dc:	mov    rsi,r15
    38df:	mov    rdi,QWORD PTR [rsp+0x58]
    38e4:	mov    r8,r14
    38e7:	call   38ec <botlish_fn_42+0x27c>
			38e8: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    38ec:	test   rax,rax
    38ef:	jne    392c <botlish_fn_42+0x2bc>
    38f5:	xor    rax,rax
    38f8:	mov    rbx,QWORD PTR [rsp+0x90]
    3900:	mov    r12,QWORD PTR [rsp+0x98]
    3908:	mov    r13,QWORD PTR [rsp+0xa0]
    3910:	mov    r14,QWORD PTR [rsp+0xa8]
    3918:	mov    r15,QWORD PTR [rsp+0xb0]
    3920:	add    rsp,0xc0
    3927:	mov    rsp,rbp
    392a:	pop    rbp
    392b:	ret
    392c:	mov    rsi,QWORD PTR [rsp+0x60]
    3931:	mov    rsi,QWORD PTR [rsp+0x60]
    3936:	mov    QWORD PTR [rsp+0x10],rsi
    393b:	mov    rsi,QWORD PTR [rsp+0x68]
    3940:	mov    QWORD PTR [rsp+0x18],rsi
    3945:	mov    rsi,QWORD PTR [rsp+0x70]
    394a:	mov    QWORD PTR [rsp+0x20],rsi
    394f:	mov    QWORD PTR [rsp+0x28],r15
    3954:	mov    QWORD PTR [rsp+0x30],r12
    3959:	mov    QWORD PTR [rsp+0x38],r13
    395e:	mov    QWORD PTR [rsp+0x40],r14
    3963:	add    rbx,0x1
    396a:	mov    rcx,QWORD PTR [rsp+0x88]
    3972:	jmp    3703 <botlish_fn_42+0x93>
    3977:	mov    eax,0xa
    397c:	mov    rbx,QWORD PTR [rsp+0x90]
    3984:	mov    r12,QWORD PTR [rsp+0x98]
    398c:	mov    r13,QWORD PTR [rsp+0xa0]
    3994:	mov    r14,QWORD PTR [rsp+0xa8]
    399c:	mov    r15,QWORD PTR [rsp+0xb0]
    39a4:	add    rsp,0xc0
    39ab:	mov    rsp,rbp
    39ae:	pop    rbp
    39af:	ret
    39b0:	(bad)
    39b1:	add    BYTE PTR [rax],al
    39b3:	add    BYTE PTR [rax],al
    39b5:	add    BYTE PTR [rax],al
	...

00000000000039b8 <botlish_entry_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    39b8:	push   rbp
    39b9:	mov    rbp,rsp
    39bc:	sub    rsp,0x30
    39c0:	mov    QWORD PTR [rsp+0x20],r12
    39c5:	mov    rsi,QWORD PTR [rdx]
    39c8:	mov    rax,QWORD PTR [rdx+0x8]
    39cc:	mov    rcx,QWORD PTR [rdx+0x10]
    39d0:	mov    r8,QWORD PTR [rdx+0x18]
    39d4:	mov    r9,QWORD PTR [rdx+0x20]
    39d8:	mov    r10,QWORD PTR [rdx+0x28]
    39dc:	mov    r11,QWORD PTR [rdx+0x30]
    39e0:	mov    r12,QWORD PTR [rdx+0x38]
    39e4:	mov    rdx,QWORD PTR [rdx+0x40]
    39e8:	mov    QWORD PTR [rsp],r10
    39ec:	mov    QWORD PTR [rsp+0x8],r11
    39f1:	mov    QWORD PTR [rsp+0x10],r12
    39f6:	mov    QWORD PTR [rsp+0x18],rdx
    39fb:	mov    rdx,rax
    39fe:	call   3a03 <botlish_entry_42+0x4b>
			39ff: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3a03:	mov    r12,QWORD PTR [rsp+0x20]
    3a08:	add    rsp,0x30
    3a0c:	mov    rsp,rbp
    3a0f:	pop    rbp
    3a10:	ret

0000000000003a11 <botlish_fn_43: ht_rehash<mutarray, int>>:
    3a11:	push   rbp
    3a12:	mov    rbp,rsp
    3a15:	sub    rsp,0xd0
    3a1c:	mov    QWORD PTR [rsp+0xa0],rbx
    3a24:	mov    QWORD PTR [rsp+0xa8],r12
    3a2c:	mov    QWORD PTR [rsp+0xb0],r13
    3a34:	mov    QWORD PTR [rsp+0xb8],r14
    3a3c:	mov    QWORD PTR [rsp+0xc0],r15
    3a44:	mov    r13,rdi
    3a47:	mov    QWORD PTR [rsp+0x50],0x0
    3a50:	mov    QWORD PTR [rsp+0x58],0x0
    3a59:	mov    QWORD PTR [rsp+0x60],0x0
    3a62:	mov    QWORD PTR [rsp+0x68],0x0
    3a6b:	mov    QWORD PTR [rsp+0x20],rsi
    3a70:	mov    r12,rsi
    3a73:	mov    QWORD PTR [rsp+0x28],rdx
    3a78:	mov    rbx,rdx
    3a7b:	mov    rsi,r12
    3a7e:	mov    rdi,r13
    3a81:	call   3a86 <botlish_fn_43+0x75>
			3a82: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    3a86:	test   rax,rax
    3a89:	je     3c58 <botlish_fn_43+0x247>
    3a8f:	mov    QWORD PTR [rsp+0x30],rax
    3a94:	mov    r14,rax
    3a97:	mov    rsi,r12
    3a9a:	mov    rdi,r13
    3a9d:	call   3aa2 <botlish_fn_43+0x91>
			3a9e: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3aa2:	test   rax,rax
    3aa5:	je     3c58 <botlish_fn_43+0x247>
    3aab:	mov    QWORD PTR [rsp+0x38],rax
    3ab0:	mov    r15,rax
    3ab3:	mov    rsi,r12
    3ab6:	mov    rdi,r13
    3ab9:	call   3abe <botlish_fn_43+0xad>
			3aba: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3abe:	test   rax,rax
    3ac1:	je     3c58 <botlish_fn_43+0x247>
    3ac7:	mov    QWORD PTR [rsp+0x40],rax
    3acc:	mov    QWORD PTR [rsp+0x90],rax
    3ad4:	mov    rsi,r12
    3ad7:	mov    rdi,r13
    3ada:	call   3adf <botlish_fn_43+0xce>
			3adb: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3adf:	test   rax,rax
    3ae2:	je     3c58 <botlish_fn_43+0x247>
    3ae8:	mov    QWORD PTR [rsp+0x48],rax
    3aed:	mov    QWORD PTR [rsp+0x88],rax
    3af5:	mov    rsi,rbx
    3af8:	mov    rdi,r13
    3afb:	call   3b00 <botlish_fn_43+0xef>
			3afc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b00:	mov    rcx,rax
    3b03:	mov    QWORD PTR [rsp+0x80],rax
    3b0b:	test   rax,rcx
    3b0e:	je     3c58 <botlish_fn_43+0x247>
    3b14:	mov    rax,QWORD PTR [rsp+0x80]
    3b1c:	mov    QWORD PTR [rsp+0x50],rax
    3b21:	mov    edx,0x1
    3b26:	mov    QWORD PTR [rsp+0x58],0x1
    3b2f:	mov    rcx,rbx
    3b32:	mov    rsi,QWORD PTR [rsp+0x80]
    3b3a:	mov    rdi,r13
    3b3d:	call   3b42 <botlish_fn_43+0x131>
			3b3e: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3b42:	test   rax,rax
    3b45:	je     3c58 <botlish_fn_43+0x247>
    3b4b:	mov    rsi,rbx
    3b4e:	mov    rdi,r13
    3b51:	call   3b56 <botlish_fn_43+0x145>
			3b52: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b56:	test   rax,rax
    3b59:	je     3c58 <botlish_fn_43+0x247>
    3b5f:	mov    QWORD PTR [rsp+0x58],rax
    3b64:	mov    QWORD PTR [rsp+0x78],rax
    3b69:	mov    rsi,rbx
    3b6c:	mov    rdi,r13
    3b6f:	call   3b74 <botlish_fn_43+0x163>
			3b70: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b74:	test   rax,rax
    3b77:	je     3c58 <botlish_fn_43+0x247>
    3b7d:	mov    QWORD PTR [rsp+0x60],rax
    3b82:	mov    r8d,0x1
    3b88:	mov    QWORD PTR [rsp+0x68],0x1
    3b91:	mov    rcx,QWORD PTR [rsp+0x80]
    3b99:	mov    QWORD PTR [rsp],rcx
    3b9d:	mov    rcx,QWORD PTR [rsp+0x78]
    3ba2:	mov    QWORD PTR [rsp+0x8],rcx
    3ba7:	mov    QWORD PTR [rsp+0x10],rax
    3bac:	mov    QWORD PTR [rsp+0x70],rax
    3bb1:	mov    QWORD PTR [rsp+0x18],rbx
    3bb6:	mov    rcx,QWORD PTR [rsp+0x90]
    3bbe:	mov    rdx,r15
    3bc1:	mov    rsi,r14
    3bc4:	mov    r9,QWORD PTR [rsp+0x88]
    3bcc:	mov    rdi,r13
    3bcf:	call   3bd4 <botlish_fn_43+0x1c3>
			3bd0: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3bd4:	test   rax,rax
    3bd7:	je     3c58 <botlish_fn_43+0x247>
    3bdd:	mov    edx,0x1
    3be2:	mov    rcx,QWORD PTR [rsp+0x80]
    3bea:	mov    rsi,r12
    3bed:	mov    rdi,r13
    3bf0:	call   3bf5 <botlish_fn_43+0x1e4>
			3bf1: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bf5:	test   rax,rax
    3bf8:	je     3c58 <botlish_fn_43+0x247>
    3bfe:	mov    edx,0x3
    3c03:	mov    rcx,QWORD PTR [rsp+0x78]
    3c08:	mov    rsi,r12
    3c0b:	mov    rdi,r13
    3c0e:	call   3c13 <botlish_fn_43+0x202>
			3c0f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c13:	test   rax,rax
    3c16:	je     3c58 <botlish_fn_43+0x247>
    3c1c:	mov    edx,0x5
    3c21:	mov    rcx,QWORD PTR [rsp+0x70]
    3c26:	mov    rsi,r12
    3c29:	mov    rdi,r13
    3c2c:	call   3c31 <botlish_fn_43+0x220>
			3c2d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c31:	test   rax,rax
    3c34:	je     3c58 <botlish_fn_43+0x247>
    3c3a:	mov    edx,0x9
    3c3f:	mov    ecx,0x1
    3c44:	mov    rsi,r12
    3c47:	mov    rdi,r13
    3c4a:	call   3c4f <botlish_fn_43+0x23e>
			3c4b: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c4f:	test   rax,rax
    3c52:	jne    3c8f <botlish_fn_43+0x27e>
    3c58:	xor    rax,rax
    3c5b:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c63:	mov    r12,QWORD PTR [rsp+0xa8]
    3c6b:	mov    r13,QWORD PTR [rsp+0xb0]
    3c73:	mov    r14,QWORD PTR [rsp+0xb8]
    3c7b:	mov    r15,QWORD PTR [rsp+0xc0]
    3c83:	add    rsp,0xd0
    3c8a:	mov    rsp,rbp
    3c8d:	pop    rbp
    3c8e:	ret
    3c8f:	mov    eax,0xa
    3c94:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c9c:	mov    r12,QWORD PTR [rsp+0xa8]
    3ca4:	mov    r13,QWORD PTR [rsp+0xb0]
    3cac:	mov    r14,QWORD PTR [rsp+0xb8]
    3cb4:	mov    r15,QWORD PTR [rsp+0xc0]
    3cbc:	add    rsp,0xd0
    3cc3:	mov    rsp,rbp
    3cc6:	pop    rbp
    3cc7:	ret

0000000000003cc8 <botlish_entry_43: ht_rehash<mutarray, int>>:
    3cc8:	push   rbp
    3cc9:	mov    rbp,rsp
    3ccc:	mov    rsi,QWORD PTR [rdx]
    3ccf:	mov    rdx,QWORD PTR [rdx+0x8]
    3cd3:	call   3cd8 <botlish_entry_43+0x10>
			3cd4: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3cd8:	mov    rsp,rbp
    3cdb:	pop    rbp
    3cdc:	ret
    3cdd:	add    BYTE PTR [rax],al
	...

0000000000003ce0 <botlish_fn_44: ht_should_grow<mutarray>>:
    3ce0:	push   rbp
    3ce1:	mov    rbp,rsp
    3ce4:	sub    rsp,0x40
    3ce8:	mov    QWORD PTR [rsp+0x20],rbx
    3ced:	mov    QWORD PTR [rsp+0x28],r12
    3cf2:	mov    QWORD PTR [rsp+0x30],r13
    3cf7:	mov    rbx,rdi
    3cfa:	mov    QWORD PTR [rsp],rsi
    3cfe:	mov    r12,rsi
    3d01:	mov    rsi,r12
    3d04:	mov    rdi,rbx
    3d07:	call   3d0c <botlish_fn_44+0x2c>
			3d08: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3d0c:	mov    rcx,rax
    3d0f:	mov    r13,rax
    3d12:	test   rax,rcx
    3d15:	je     3f04 <botlish_fn_44+0x224>
    3d1b:	mov    rax,r13
    3d1e:	mov    QWORD PTR [rsp+0x8],rax
    3d23:	mov    rsi,r12
    3d26:	mov    rdi,rbx
    3d29:	call   3d2e <botlish_fn_44+0x4e>
			3d2a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3d2e:	mov    rcx,rax
    3d31:	test   rcx,rcx
    3d34:	je     3f04 <botlish_fn_44+0x224>
    3d3a:	mov    QWORD PTR [rsp+0x10],rcx
    3d3f:	mov    edx,0x1
    3d44:	mov    rax,r13
    3d47:	test   rax,0x1
    3d4d:	jne    3d70 <botlish_fn_44+0x90>
    3d53:	xor    edx,edx
    3d55:	mov    rax,r13
    3d58:	test   rax,0x7
    3d5e:	jne    3d70 <botlish_fn_44+0x90>
    3d64:	mov    rax,r13
    3d67:	movzx  rax,BYTE PTR [rax]
    3d6b:	cmp    al,0x1
    3d6d:	sete   dl
    3d70:	test   dl,dl
    3d72:	jne    3d93 <botlish_fn_44+0xb3>
    3d78:	mov    rdi,rbx
    3d7b:	mov    rax,QWORD PTR [rdi+0x10]
    3d7f:	mov    rcx,QWORD PTR [rax+0x38]
    3d83:	xor    rdx,rdx
    3d86:	mov    rsi,r13
    3d89:	call   3d8e <botlish_fn_44+0xae>
			3d8a: R_X86_64_PLT32	rt_type_error-0x4
    3d8e:	jmp    3f04 <botlish_fn_44+0x224>
    3d93:	mov    eax,0x1
    3d98:	test   rcx,0x1
    3d9f:	je     3dad <botlish_fn_44+0xcd>
    3da5:	mov    r8,rcx
    3da8:	jmp    3dd0 <botlish_fn_44+0xf0>
    3dad:	xor    eax,eax
    3daf:	test   rcx,0x7
    3db6:	je     3dc4 <botlish_fn_44+0xe4>
    3dbc:	mov    r8,rcx
    3dbf:	jmp    3dd0 <botlish_fn_44+0xf0>
    3dc4:	movzx  rax,BYTE PTR [rcx]
    3dc8:	mov    r8,rcx
    3dcb:	cmp    al,0x1
    3dcd:	sete   al
    3dd0:	test   al,al
    3dd2:	jne    3df3 <botlish_fn_44+0x113>
    3dd8:	mov    rdi,rbx
    3ddb:	mov    rax,QWORD PTR [rdi+0x10]
    3ddf:	mov    rcx,QWORD PTR [rax+0x38]
    3de3:	xor    rdx,rdx
    3de6:	mov    rsi,r8
    3de9:	call   3dee <botlish_fn_44+0x10e>
			3dea: R_X86_64_PLT32	rt_type_error-0x4
    3dee:	jmp    3f04 <botlish_fn_44+0x224>
    3df3:	mov    rcx,r8
    3df6:	mov    rsi,r13
    3df9:	mov    rax,rsi
    3dfc:	and    rax,rcx
    3dff:	test   rax,0x1
    3e05:	jne    3e16 <botlish_fn_44+0x136>
    3e0b:	mov    rdx,r8
    3e0e:	mov    rsi,r13
    3e11:	jmp    3e34 <botlish_fn_44+0x154>
    3e16:	mov    rcx,r8
    3e19:	lea    rax,[rcx-0x1]
    3e1d:	mov    rsi,r13
    3e20:	add    rsi,rax
    3e23:	seto   al
    3e26:	test   al,al
    3e28:	je     3e3f <botlish_fn_44+0x15f>
    3e2e:	mov    rdx,r8
    3e31:	mov    rsi,r13
    3e34:	mov    rdi,rbx
    3e37:	call   3e3c <botlish_fn_44+0x15c>
			3e38: R_X86_64_PLT32	rt_int_add-0x4
    3e3c:	mov    rsi,rax
    3e3f:	mov    QWORD PTR [rsp+0x8],rsi
    3e44:	mov    QWORD PTR [rsp+0x10],0x3
    3e4d:	test   rsi,0x1
    3e54:	je     3e77 <botlish_fn_44+0x197>
    3e5a:	mov    rax,rsi
    3e5d:	add    rax,0x2
    3e61:	mov    rcx,rax
    3e64:	seto   al
    3e67:	test   al,al
    3e69:	jne    3e77 <botlish_fn_44+0x197>
    3e6f:	mov    rsi,rcx
    3e72:	jmp    3e87 <botlish_fn_44+0x1a7>
    3e77:	mov    edx,0x3
    3e7c:	mov    rdi,rbx
    3e7f:	call   3e84 <botlish_fn_44+0x1a4>
			3e80: R_X86_64_PLT32	rt_int_add-0x4
    3e84:	mov    rsi,rax
    3e87:	mov    QWORD PTR [rsp+0x8],rsi
    3e8c:	mov    edx,0x7
    3e91:	mov    rdi,rdx
    3e94:	mov    QWORD PTR [rsp+0x10],0x7
    3e9d:	test   rsi,0x1
    3ea4:	jne    3eb2 <botlish_fn_44+0x1d2>
    3eaa:	mov    rdx,rdi
    3ead:	jmp    3ede <botlish_fn_44+0x1fe>
    3eb2:	mov    rax,rsi
    3eb5:	sar    rax,1
    3eb8:	imul   QWORD PTR [rip+0x119]        # 3fd8 <botlish_fn_44+0x2f8>
    3ebf:	seto   cl
    3ec2:	or     rax,0x1
    3ec6:	test   cl,cl
    3ec8:	je     3ed6 <botlish_fn_44+0x1f6>
    3ece:	mov    rdx,rdi
    3ed1:	jmp    3ede <botlish_fn_44+0x1fe>
    3ed6:	mov    rsi,rax
    3ed9:	jmp    3ee9 <botlish_fn_44+0x209>
    3ede:	mov    rdi,rbx
    3ee1:	call   3ee6 <botlish_fn_44+0x206>
			3ee2: R_X86_64_PLT32	rt_int_mul-0x4
    3ee6:	mov    rsi,rax
    3ee9:	mov    QWORD PTR [rsp],rsi
    3eed:	mov    r13,rsi
    3ef0:	mov    rsi,r12
    3ef3:	mov    rdi,rbx
    3ef6:	call   3efb <botlish_fn_44+0x21b>
			3ef7: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3efb:	test   rax,rax
    3efe:	jne    3f1f <botlish_fn_44+0x23f>
    3f04:	xor    rax,rax
    3f07:	mov    rbx,QWORD PTR [rsp+0x20]
    3f0c:	mov    r12,QWORD PTR [rsp+0x28]
    3f11:	mov    r13,QWORD PTR [rsp+0x30]
    3f16:	add    rsp,0x40
    3f1a:	mov    rsp,rbp
    3f1d:	pop    rbp
    3f1e:	ret
    3f1f:	mov    QWORD PTR [rsp+0x8],rax
    3f24:	mov    QWORD PTR [rsp+0x10],0x5
    3f2d:	test   rax,0x1
    3f33:	mov    rsi,rax
    3f36:	je     3f68 <botlish_fn_44+0x288>
    3f3c:	mov    rcx,rsi
    3f3f:	mov    rax,rcx
    3f42:	sar    rax,1
    3f45:	imul   QWORD PTR [rip+0x94]        # 3fe0 <botlish_fn_44+0x300>
    3f4c:	seto   dil
    3f50:	or     rax,0x1
    3f54:	test   dil,dil
    3f57:	jne    3f68 <botlish_fn_44+0x288>
    3f5d:	mov    rdx,rax
    3f60:	mov    rsi,r13
    3f63:	jmp    3f7b <botlish_fn_44+0x29b>
    3f68:	mov    edx,0x5
    3f6d:	mov    rdi,rbx
    3f70:	call   3f75 <botlish_fn_44+0x295>
			3f71: R_X86_64_PLT32	rt_int_mul-0x4
    3f75:	mov    rdx,rax
    3f78:	mov    rsi,r13
    3f7b:	mov    r10,rsi
    3f7e:	and    r10,rdx
    3f81:	test   r10,0x1
    3f88:	jne    3faf <botlish_fn_44+0x2cf>
    3f8e:	mov    rdi,rbx
    3f91:	call   3f96 <botlish_fn_44+0x2b6>
			3f92: R_X86_64_PLT32	rt_int_cmp-0x4
    3f96:	mov    r8d,0x2
    3f9c:	test   rax,rax
    3f9f:	mov    rax,r8
    3fa2:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3fd8 <botlish_fn_44+0x2f8>
    3faa:	jmp    3fbf <botlish_fn_44+0x2df>
    3faf:	mov    eax,0x2
    3fb4:	cmp    rsi,rdx
    3fb7:	cmovg  rax,QWORD PTR [rip+0x19]        # 3fd8 <botlish_fn_44+0x2f8>
    3fbf:	mov    rbx,QWORD PTR [rsp+0x20]
    3fc4:	mov    r12,QWORD PTR [rsp+0x28]
    3fc9:	mov    r13,QWORD PTR [rsp+0x30]
    3fce:	add    rsp,0x40
    3fd2:	mov    rsp,rbp
    3fd5:	pop    rbp
    3fd6:	ret
    3fd7:	add    BYTE PTR [rsi],al
    3fd9:	add    BYTE PTR [rax],al
    3fdb:	add    BYTE PTR [rax],al
    3fdd:	add    BYTE PTR [rax],al
    3fdf:	add    BYTE PTR [rax+rax*1],al
    3fe2:	add    BYTE PTR [rax],al
    3fe4:	add    BYTE PTR [rax],al
	...

0000000000003fe8 <botlish_entry_44: ht_should_grow<mutarray>>:
    3fe8:	push   rbp
    3fe9:	mov    rbp,rsp
    3fec:	mov    rsi,QWORD PTR [rdx]
    3fef:	call   3ff4 <botlish_entry_44+0xc>
			3ff0: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3ff4:	mov    rsp,rbp
    3ff7:	pop    rbp
    3ff8:	ret
    3ff9:	add    BYTE PTR [rax],al
    3ffb:	add    BYTE PTR [rax],al
    3ffd:	add    BYTE PTR [rax],al
	...

0000000000004000 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    4000:	push   rbp
    4001:	mov    rbp,rsp
    4004:	sub    rsp,0x40
    4008:	mov    QWORD PTR [rsp+0x20],rbx
    400d:	mov    QWORD PTR [rsp+0x28],r12
    4012:	mov    QWORD PTR [rsp+0x30],r13
    4017:	mov    rbx,rdi
    401a:	mov    QWORD PTR [rsp+0x10],0x0
    4023:	mov    QWORD PTR [rsp],rsi
    4027:	mov    r12,rsi
    402a:	mov    rsi,r12
    402d:	mov    rdi,rbx
    4030:	call   4035 <botlish_fn_45+0x35>
			4031: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4035:	test   rax,rax
    4038:	mov    r13,rax
    403b:	je     4228 <botlish_fn_45+0x228>
    4041:	mov    rsi,r12
    4044:	mov    rdi,rbx
    4047:	call   404c <botlish_fn_45+0x4c>
			4048: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    404c:	mov    rcx,rax
    404f:	test   rcx,rcx
    4052:	je     4228 <botlish_fn_45+0x228>
    4058:	mov    edx,0x1
    405d:	mov    rax,r13
    4060:	test   rax,0x1
    4066:	je     4074 <botlish_fn_45+0x74>
    406c:	mov    r13,rax
    406f:	jmp    4098 <botlish_fn_45+0x98>
    4074:	xor    edx,edx
    4076:	test   rax,0x7
    407c:	je     408a <botlish_fn_45+0x8a>
    4082:	mov    r13,rax
    4085:	jmp    4098 <botlish_fn_45+0x98>
    408a:	movzx  rdx,BYTE PTR [rax]
    408e:	mov    r13,rax
    4091:	rex cmp dl,0x1
    4095:	sete   dl
    4098:	test   dl,dl
    409a:	jne    40bb <botlish_fn_45+0xbb>
    40a0:	mov    rdi,rbx
    40a3:	mov    rsi,QWORD PTR [rdi+0x10]
    40a7:	mov    rcx,QWORD PTR [rsi+0x40]
    40ab:	xor    rdx,rdx
    40ae:	mov    rsi,r13
    40b1:	call   40b6 <botlish_fn_45+0xb6>
			40b2: R_X86_64_PLT32	rt_type_error-0x4
    40b6:	jmp    4228 <botlish_fn_45+0x228>
    40bb:	mov    rsi,r13
    40be:	mov    eax,0x1
    40c3:	test   rcx,0x1
    40ca:	je     40d8 <botlish_fn_45+0xd8>
    40d0:	mov    r8,rcx
    40d3:	jmp    40fd <botlish_fn_45+0xfd>
    40d8:	xor    eax,eax
    40da:	test   rcx,0x7
    40e1:	je     40ef <botlish_fn_45+0xef>
    40e7:	mov    r8,rcx
    40ea:	jmp    40fd <botlish_fn_45+0xfd>
    40ef:	movzx  r11,BYTE PTR [rcx]
    40f3:	mov    r8,rcx
    40f6:	cmp    r11b,0x1
    40fa:	sete   al
    40fd:	test   al,al
    40ff:	jne    4120 <botlish_fn_45+0x120>
    4105:	mov    rdi,rbx
    4108:	mov    rax,QWORD PTR [rdi+0x10]
    410c:	mov    rcx,QWORD PTR [rax+0x40]
    4110:	xor    rdx,rdx
    4113:	mov    rsi,r8
    4116:	call   411b <botlish_fn_45+0x11b>
			4117: R_X86_64_PLT32	rt_type_error-0x4
    411b:	jmp    4228 <botlish_fn_45+0x228>
    4120:	mov    rcx,r8
    4123:	mov    rax,rsi
    4126:	and    rax,rcx
    4129:	test   rax,0x1
    412f:	jne    4155 <botlish_fn_45+0x155>
    4135:	mov    rdx,r8
    4138:	mov    rdi,rbx
    413b:	call   4140 <botlish_fn_45+0x140>
			413c: R_X86_64_PLT32	rt_int_cmp-0x4
    4140:	mov    ecx,0x2
    4145:	test   rax,rax
    4148:	cmovg  rcx,QWORD PTR [rip+0x110]        # 4260 <botlish_fn_45+0x260>
    4150:	jmp    4168 <botlish_fn_45+0x168>
    4155:	mov    ecx,0x2
    415a:	mov    r9,r8
    415d:	cmp    rsi,r9
    4160:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 4260 <botlish_fn_45+0x260>
    4168:	cmp    rcx,0x6
    416c:	je     41f8 <botlish_fn_45+0x1f8>
    4172:	mov    rsi,r12
    4175:	mov    rdi,rbx
    4178:	call   417d <botlish_fn_45+0x17d>
			4179: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    417d:	test   rax,rax
    4180:	je     4228 <botlish_fn_45+0x228>
    4186:	mov    QWORD PTR [rsp+0x8],rax
    418b:	mov    QWORD PTR [rsp+0x10],0x5
    4194:	test   rax,0x1
    419a:	mov    rsi,rax
    419d:	je     41ca <botlish_fn_45+0x1ca>
    41a3:	mov    rcx,rsi
    41a6:	mov    rax,rcx
    41a9:	sar    rax,1
    41ac:	imul   QWORD PTR [rip+0xb5]        # 4268 <botlish_fn_45+0x268>
    41b3:	seto   cl
    41b6:	or     rax,0x1
    41ba:	test   cl,cl
    41bc:	jne    41ca <botlish_fn_45+0x1ca>
    41c2:	mov    rdx,rax
    41c5:	jmp    41da <botlish_fn_45+0x1da>
    41ca:	mov    edx,0x5
    41cf:	mov    rdi,rbx
    41d2:	call   41d7 <botlish_fn_45+0x1d7>
			41d3: R_X86_64_PLT32	rt_int_mul-0x4
    41d7:	mov    rdx,rax
    41da:	mov    QWORD PTR [rsp+0x8],rdx
    41df:	mov    rsi,r12
    41e2:	mov    rdi,rbx
    41e5:	call   41ea <botlish_fn_45+0x1ea>
			41e6: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41ea:	test   rax,rax
    41ed:	je     4228 <botlish_fn_45+0x228>
    41f3:	jmp    4243 <botlish_fn_45+0x243>
    41f8:	mov    rsi,r12
    41fb:	mov    rdi,rbx
    41fe:	call   4203 <botlish_fn_45+0x203>
			41ff: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4203:	test   rax,rax
    4206:	je     4228 <botlish_fn_45+0x228>
    420c:	mov    QWORD PTR [rsp+0x8],rax
    4211:	mov    rdx,rax
    4214:	mov    rsi,r12
    4217:	mov    rdi,rbx
    421a:	call   421f <botlish_fn_45+0x21f>
			421b: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    421f:	test   rax,rax
    4222:	jne    4243 <botlish_fn_45+0x243>
    4228:	xor    rax,rax
    422b:	mov    rbx,QWORD PTR [rsp+0x20]
    4230:	mov    r12,QWORD PTR [rsp+0x28]
    4235:	mov    r13,QWORD PTR [rsp+0x30]
    423a:	add    rsp,0x40
    423e:	mov    rsp,rbp
    4241:	pop    rbp
    4242:	ret
    4243:	mov    rbx,QWORD PTR [rsp+0x20]
    4248:	mov    r12,QWORD PTR [rsp+0x28]
    424d:	mov    r13,QWORD PTR [rsp+0x30]
    4252:	add    rsp,0x40
    4256:	mov    rsp,rbp
    4259:	pop    rbp
    425a:	ret
    425b:	add    BYTE PTR [rax],al
    425d:	add    BYTE PTR [rax],al
    425f:	add    BYTE PTR [rsi],al
    4261:	add    BYTE PTR [rax],al
    4263:	add    BYTE PTR [rax],al
    4265:	add    BYTE PTR [rax],al
    4267:	add    BYTE PTR [rax+rax*1],al
    426a:	add    BYTE PTR [rax],al
    426c:	add    BYTE PTR [rax],al
	...

0000000000004270 <botlish_entry_45: ht_grow_or_clean<mutarray>>:
    4270:	push   rbp
    4271:	mov    rbp,rsp
    4274:	mov    rsi,QWORD PTR [rdx]
    4277:	call   427c <botlish_entry_45+0xc>
			4278: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    427c:	mov    rsp,rbp
    427f:	pop    rbp
    4280:	ret
    4281:	add    BYTE PTR [rax],al
    4283:	add    BYTE PTR [rax],al
    4285:	add    BYTE PTR [rax],al
	...

0000000000004288 <botlish_fn_46: ht_place<mutarray, int, str, str>>:
    4288:	push   rbp
    4289:	mov    rbp,rsp
    428c:	sub    rsp,0x70
    4290:	mov    QWORD PTR [rsp+0x40],rbx
    4295:	mov    QWORD PTR [rsp+0x48],r12
    429a:	mov    QWORD PTR [rsp+0x50],r13
    429f:	mov    QWORD PTR [rsp+0x58],r14
    42a4:	mov    QWORD PTR [rsp+0x60],r15
    42a9:	mov    rbx,rdi
    42ac:	mov    r14,r8
    42af:	mov    r15,rdx
    42b2:	mov    QWORD PTR [rsp+0x28],rcx
    42b7:	mov    QWORD PTR [rsp],rsi
    42bb:	mov    r12,rsi
    42be:	mov    rsi,r12
    42c1:	mov    rdi,rbx
    42c4:	call   42c9 <botlish_fn_46+0x41>
			42c5: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    42c9:	test   rax,rax
    42cc:	je     4630 <botlish_fn_46+0x3a8>
    42d2:	xor    ecx,ecx
    42d4:	test   rax,0x7
    42da:	je     42ea <botlish_fn_46+0x62>
    42e0:	mov    QWORD PTR [rsp+0x30],rax
    42e5:	jmp    42fa <botlish_fn_46+0x72>
    42ea:	movzx  rcx,BYTE PTR [rax]
    42ee:	mov    QWORD PTR [rsp+0x30],rax
    42f3:	rex cmp cl,0x8
    42f7:	sete   cl
    42fa:	test   cl,cl
    42fc:	jne    4321 <botlish_fn_46+0x99>
    4302:	mov    rdi,rbx
    4305:	mov    rax,QWORD PTR [rdi+0x10]
    4309:	mov    rcx,QWORD PTR [rax+0x30]
    430d:	mov    edx,0x8
    4312:	mov    rsi,QWORD PTR [rsp+0x30]
    4317:	call   431c <botlish_fn_46+0x94>
			4318: R_X86_64_PLT32	rt_type_error-0x4
    431c:	jmp    4630 <botlish_fn_46+0x3a8>
    4321:	mov    rdx,r15
    4324:	mov    rsi,QWORD PTR [rsp+0x30]
    4329:	mov    rdi,rbx
    432c:	call   4331 <botlish_fn_46+0xa9>
			432d: R_X86_64_PLT32	rt_mutarray_get-0x4
    4331:	test   rax,rax
    4334:	je     4630 <botlish_fn_46+0x3a8>
    433a:	mov    QWORD PTR [rsp+0x8],rax
    433f:	mov    r13,rax
    4342:	mov    ecx,0x3
    4347:	mov    rsi,QWORD PTR [rsp+0x30]
    434c:	mov    rdx,r15
    434f:	mov    rdi,rbx
    4352:	call   4357 <botlish_fn_46+0xcf>
			4353: R_X86_64_PLT32	rt_mutarray_set-0x4
    4357:	test   rax,rax
    435a:	je     4630 <botlish_fn_46+0x3a8>
    4360:	mov    rsi,r12
    4363:	mov    rdi,rbx
    4366:	call   436b <botlish_fn_46+0xe3>
			4367: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    436b:	test   rax,rax
    436e:	je     4630 <botlish_fn_46+0x3a8>
    4374:	xor    ecx,ecx
    4376:	test   rax,0x7
    437c:	je     438a <botlish_fn_46+0x102>
    4382:	mov    rsi,rax
    4385:	jmp    4398 <botlish_fn_46+0x110>
    438a:	movzx  rcx,BYTE PTR [rax]
    438e:	mov    rsi,rax
    4391:	rex cmp cl,0x8
    4395:	sete   cl
    4398:	test   cl,cl
    439a:	jne    43b9 <botlish_fn_46+0x131>
    43a0:	mov    rdi,rbx
    43a3:	mov    rax,QWORD PTR [rdi+0x10]
    43a7:	mov    rcx,QWORD PTR [rax]
    43aa:	mov    edx,0x8
    43af:	call   43b4 <botlish_fn_46+0x12c>
			43b0: R_X86_64_PLT32	rt_type_error-0x4
    43b4:	jmp    4630 <botlish_fn_46+0x3a8>
    43b9:	mov    rcx,QWORD PTR [rsp+0x28]
    43be:	mov    rdx,r15
    43c1:	mov    rdi,rbx
    43c4:	call   43c9 <botlish_fn_46+0x141>
			43c5: R_X86_64_PLT32	rt_mutarray_set-0x4
    43c9:	test   rax,rax
    43cc:	je     4630 <botlish_fn_46+0x3a8>
    43d2:	mov    rsi,r12
    43d5:	mov    rdi,rbx
    43d8:	call   43dd <botlish_fn_46+0x155>
			43d9: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    43dd:	test   rax,rax
    43e0:	je     4630 <botlish_fn_46+0x3a8>
    43e6:	xor    esi,esi
    43e8:	test   rax,0x7
    43ee:	jne    4400 <botlish_fn_46+0x178>
    43f4:	movzx  rcx,BYTE PTR [rax]
    43f8:	rex cmp cl,0x8
    43fc:	sete   sil
    4400:	test   sil,sil
    4403:	jne    4425 <botlish_fn_46+0x19d>
    4409:	mov    rdi,rbx
    440c:	mov    rsi,QWORD PTR [rdi+0x10]
    4410:	mov    rcx,QWORD PTR [rsi]
    4413:	mov    edx,0x8
    4418:	mov    rsi,rax
    441b:	call   4420 <botlish_fn_46+0x198>
			441c: R_X86_64_PLT32	rt_type_error-0x4
    4420:	jmp    4630 <botlish_fn_46+0x3a8>
    4425:	mov    rcx,r14
    4428:	mov    rdx,r15
    442b:	mov    rsi,rax
    442e:	mov    rdi,rbx
    4431:	call   4436 <botlish_fn_46+0x1ae>
			4432: R_X86_64_PLT32	rt_mutarray_set-0x4
    4436:	test   rax,rax
    4439:	je     4630 <botlish_fn_46+0x3a8>
    443f:	mov    QWORD PTR [rsp+0x10],0x7
    4448:	mov    rsi,r12
    444b:	mov    rdi,rbx
    444e:	call   4453 <botlish_fn_46+0x1cb>
			444f: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    4453:	test   rax,rax
    4456:	je     4630 <botlish_fn_46+0x3a8>
    445c:	mov    QWORD PTR [rsp+0x18],rax
    4461:	mov    QWORD PTR [rsp+0x20],0x3
    446a:	mov    ecx,0x1
    446f:	test   rax,0x1
    4475:	je     4483 <botlish_fn_46+0x1fb>
    447b:	mov    rsi,rax
    447e:	jmp    44a7 <botlish_fn_46+0x21f>
    4483:	xor    ecx,ecx
    4485:	test   rax,0x7
    448b:	je     4499 <botlish_fn_46+0x211>
    4491:	mov    rsi,rax
    4494:	jmp    44a7 <botlish_fn_46+0x21f>
    4499:	movzx  rcx,BYTE PTR [rax]
    449d:	mov    rsi,rax
    44a0:	rex cmp cl,0x1
    44a4:	sete   cl
    44a7:	test   cl,cl
    44a9:	jne    44c7 <botlish_fn_46+0x23f>
    44af:	mov    rdi,rbx
    44b2:	mov    rax,QWORD PTR [rdi+0x10]
    44b6:	mov    rcx,QWORD PTR [rax+0x38]
    44ba:	xor    rdx,rdx
    44bd:	call   44c2 <botlish_fn_46+0x23a>
			44be: R_X86_64_PLT32	rt_type_error-0x4
    44c2:	jmp    4630 <botlish_fn_46+0x3a8>
    44c7:	test   rsi,0x1
    44ce:	je     44e6 <botlish_fn_46+0x25e>
    44d4:	mov    rcx,rsi
    44d7:	add    rcx,0x2
    44db:	seto   al
    44de:	test   al,al
    44e0:	je     44f6 <botlish_fn_46+0x26e>
    44e6:	mov    edx,0x3
    44eb:	mov    rdi,rbx
    44ee:	call   44f3 <botlish_fn_46+0x26b>
			44ef: R_X86_64_PLT32	rt_int_add-0x4
    44f3:	mov    rcx,rax
    44f6:	mov    edx,0x7
    44fb:	mov    rsi,r12
    44fe:	mov    rdi,rbx
    4501:	call   4506 <botlish_fn_46+0x27e>
			4502: R_X86_64_PLT32	rt_mutarray_set-0x4
    4506:	test   rax,rax
    4509:	je     4630 <botlish_fn_46+0x3a8>
    450f:	mov    rax,r13
    4512:	test   rax,0x1
    4518:	jne    453c <botlish_fn_46+0x2b4>
    451e:	mov    edx,0x5
    4523:	mov    rsi,r13
    4526:	mov    rdi,rbx
    4529:	call   452e <botlish_fn_46+0x2a6>
			452a: R_X86_64_PLT32	rt_value_eq-0x4
    452e:	test   rax,rax
    4531:	je     4630 <botlish_fn_46+0x3a8>
    4537:	jmp    4550 <botlish_fn_46+0x2c8>
    453c:	mov    rsi,r13
    453f:	mov    eax,0x2
    4544:	cmp    rsi,0x5
    4548:	cmove  rax,QWORD PTR [rip+0x130]        # 4680 <botlish_fn_46+0x3f8>
    4550:	cmp    rax,0x6
    4554:	jne    4655 <botlish_fn_46+0x3cd>
    455a:	mov    QWORD PTR [rsp+0x8],0x9
    4563:	mov    rsi,r12
    4566:	mov    rdi,rbx
    4569:	call   456e <botlish_fn_46+0x2e6>
			456a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    456e:	test   rax,rax
    4571:	je     4630 <botlish_fn_46+0x3a8>
    4577:	mov    QWORD PTR [rsp+0x10],rax
    457c:	mov    QWORD PTR [rsp+0x18],0x3
    4585:	mov    ecx,0x1
    458a:	test   rax,0x1
    4590:	je     459e <botlish_fn_46+0x316>
    4596:	mov    rsi,rax
    4599:	jmp    45c2 <botlish_fn_46+0x33a>
    459e:	xor    ecx,ecx
    45a0:	test   rax,0x7
    45a6:	je     45b4 <botlish_fn_46+0x32c>
    45ac:	mov    rsi,rax
    45af:	jmp    45c2 <botlish_fn_46+0x33a>
    45b4:	movzx  rcx,BYTE PTR [rax]
    45b8:	mov    rsi,rax
    45bb:	rex cmp cl,0x1
    45bf:	sete   cl
    45c2:	test   cl,cl
    45c4:	jne    45e2 <botlish_fn_46+0x35a>
    45ca:	mov    rdi,rbx
    45cd:	mov    rcx,QWORD PTR [rdi+0x10]
    45d1:	mov    rcx,QWORD PTR [rcx+0x48]
    45d5:	xor    rdx,rdx
    45d8:	call   45dd <botlish_fn_46+0x355>
			45d9: R_X86_64_PLT32	rt_type_error-0x4
    45dd:	jmp    4630 <botlish_fn_46+0x3a8>
    45e2:	test   rsi,0x1
    45e9:	je     4607 <botlish_fn_46+0x37f>
    45ef:	mov    r8,rsi
    45f2:	sub    r8,0x3
    45f6:	seto   dil
    45fa:	lea    rcx,[r8+0x1]
    45fe:	test   dil,dil
    4601:	je     4617 <botlish_fn_46+0x38f>
    4607:	mov    edx,0x3
    460c:	mov    rdi,rbx
    460f:	call   4614 <botlish_fn_46+0x38c>
			4610: R_X86_64_PLT32	rt_int_sub-0x4
    4614:	mov    rcx,rax
    4617:	mov    edx,0x9
    461c:	mov    rsi,r12
    461f:	mov    rdi,rbx
    4622:	call   4627 <botlish_fn_46+0x39f>
			4623: R_X86_64_PLT32	rt_mutarray_set-0x4
    4627:	test   rax,rax
    462a:	jne    4655 <botlish_fn_46+0x3cd>
    4630:	xor    rax,rax
    4633:	mov    rbx,QWORD PTR [rsp+0x40]
    4638:	mov    r12,QWORD PTR [rsp+0x48]
    463d:	mov    r13,QWORD PTR [rsp+0x50]
    4642:	mov    r14,QWORD PTR [rsp+0x58]
    4647:	mov    r15,QWORD PTR [rsp+0x60]
    464c:	add    rsp,0x70
    4650:	mov    rsp,rbp
    4653:	pop    rbp
    4654:	ret
    4655:	mov    eax,0xa
    465a:	mov    rbx,QWORD PTR [rsp+0x40]
    465f:	mov    r12,QWORD PTR [rsp+0x48]
    4664:	mov    r13,QWORD PTR [rsp+0x50]
    4669:	mov    r14,QWORD PTR [rsp+0x58]
    466e:	mov    r15,QWORD PTR [rsp+0x60]
    4673:	add    rsp,0x70
    4677:	mov    rsp,rbp
    467a:	pop    rbp
    467b:	ret
    467c:	add    BYTE PTR [rax],al
    467e:	add    BYTE PTR [rax],al
    4680:	(bad)
    4681:	add    BYTE PTR [rax],al
    4683:	add    BYTE PTR [rax],al
    4685:	add    BYTE PTR [rax],al
	...

0000000000004688 <botlish_entry_46: ht_place<mutarray, int, str, str>>:
    4688:	push   rbp
    4689:	mov    rbp,rsp
    468c:	mov    rsi,QWORD PTR [rdx]
    468f:	mov    r9,QWORD PTR [rdx+0x8]
    4693:	mov    rcx,QWORD PTR [rdx+0x10]
    4697:	mov    r8,QWORD PTR [rdx+0x18]
    469b:	mov    rdx,r9
    469e:	call   46a3 <botlish_entry_46+0x1b>
			469f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    46a3:	mov    rsp,rbp
    46a6:	pop    rbp
    46a7:	ret

00000000000046a8 <botlish_fn_47: ht_set<mutarray, str, str>>:
    46a8:	push   rbp
    46a9:	mov    rbp,rsp
    46ac:	sub    rsp,0x60
    46b0:	mov    QWORD PTR [rsp+0x30],rbx
    46b5:	mov    QWORD PTR [rsp+0x38],r12
    46ba:	mov    QWORD PTR [rsp+0x40],r13
    46bf:	mov    QWORD PTR [rsp+0x48],r14
    46c4:	mov    QWORD PTR [rsp+0x50],r15
    46c9:	mov    rbx,rdi
    46cc:	mov    r13,rdx
    46cf:	mov    QWORD PTR [rsp],rsi
    46d3:	mov    r14,rsi
    46d6:	mov    QWORD PTR [rsp+0x8],rdx
    46db:	mov    QWORD PTR [rsp+0x10],rcx
    46e0:	mov    r12,rcx
    46e3:	mov    rdx,r13
    46e6:	mov    rsi,r14
    46e9:	mov    rdi,rbx
    46ec:	call   46f1 <botlish_fn_47+0x49>
			46ed: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    46f1:	test   rax,rax
    46f4:	je     495e <botlish_fn_47+0x2b6>
    46fa:	mov    QWORD PTR [rsp+0x18],rax
    46ff:	mov    rcx,rax
    4702:	mov    r8,0xffffffffffffffff
    4709:	mov    QWORD PTR [rsp+0x28],r8
    470e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4717:	mov    rdx,r13
    471a:	mov    rsi,r14
    471d:	mov    rdi,rbx
    4720:	call   4725 <botlish_fn_47+0x7d>
			4721: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4725:	mov    rcx,rax
    4728:	mov    r15,rax
    472b:	test   rax,rcx
    472e:	je     495e <botlish_fn_47+0x2b6>
    4734:	mov    rax,r15
    4737:	mov    QWORD PTR [rsp+0x18],rax
    473c:	mov    rsi,r14
    473f:	mov    rdi,rbx
    4742:	call   4747 <botlish_fn_47+0x9f>
			4743: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    4747:	test   rax,rax
    474a:	je     495e <botlish_fn_47+0x2b6>
    4750:	xor    ecx,ecx
    4752:	test   rax,0x7
    4758:	je     4766 <botlish_fn_47+0xbe>
    475e:	mov    r8,rax
    4761:	jmp    4774 <botlish_fn_47+0xcc>
    4766:	movzx  rcx,BYTE PTR [rax]
    476a:	mov    r8,rax
    476d:	rex cmp cl,0x8
    4771:	sete   cl
    4774:	test   cl,cl
    4776:	jne    4799 <botlish_fn_47+0xf1>
    477c:	mov    rdi,rbx
    477f:	mov    rsi,QWORD PTR [rdi+0x10]
    4783:	mov    rcx,QWORD PTR [rsi+0x30]
    4787:	mov    edx,0x8
    478c:	mov    rsi,r8
    478f:	call   4794 <botlish_fn_47+0xec>
			4790: R_X86_64_PLT32	rt_type_error-0x4
    4794:	jmp    495e <botlish_fn_47+0x2b6>
    4799:	mov    rsi,r8
    479c:	mov    rdx,r15
    479f:	mov    rdi,rbx
    47a2:	call   47a7 <botlish_fn_47+0xff>
			47a3: R_X86_64_PLT32	rt_mutarray_get-0x4
    47a7:	test   rax,rax
    47aa:	je     495e <botlish_fn_47+0x2b6>
    47b0:	test   rax,0x1
    47b6:	mov    rsi,rax
    47b9:	jne    47da <botlish_fn_47+0x132>
    47bf:	mov    edx,0x3
    47c4:	mov    rdi,rbx
    47c7:	call   47cc <botlish_fn_47+0x124>
			47c8: R_X86_64_PLT32	rt_value_eq-0x4
    47cc:	test   rax,rax
    47cf:	je     495e <botlish_fn_47+0x2b6>
    47d5:	jmp    47eb <botlish_fn_47+0x143>
    47da:	mov    eax,0x2
    47df:	cmp    rsi,0x3
    47e3:	cmove  rax,QWORD PTR [rip+0x1c5]        # 49b0 <botlish_fn_47+0x308>
    47eb:	cmp    rax,0x6
    47ef:	je     48ee <botlish_fn_47+0x246>
    47f5:	mov    rsi,r14
    47f8:	mov    rdi,rbx
    47fb:	call   4800 <botlish_fn_47+0x158>
			47fc: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    4800:	test   rax,rax
    4803:	je     495e <botlish_fn_47+0x2b6>
    4809:	cmp    rax,0x6
    480d:	je     4852 <botlish_fn_47+0x1aa>
    4813:	mov    rcx,r13
    4816:	mov    rdx,r15
    4819:	mov    rsi,r14
    481c:	mov    rdi,rbx
    481f:	mov    r8,r12
    4822:	call   4827 <botlish_fn_47+0x17f>
			4823: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4827:	test   rax,rax
    482a:	je     495e <botlish_fn_47+0x2b6>
    4830:	mov    rbx,QWORD PTR [rsp+0x30]
    4835:	mov    r12,QWORD PTR [rsp+0x38]
    483a:	mov    r13,QWORD PTR [rsp+0x40]
    483f:	mov    r14,QWORD PTR [rsp+0x48]
    4844:	mov    r15,QWORD PTR [rsp+0x50]
    4849:	add    rsp,0x60
    484d:	mov    rsp,rbp
    4850:	pop    rbp
    4851:	ret
    4852:	mov    rsi,r14
    4855:	mov    rdi,rbx
    4858:	call   485d <botlish_fn_47+0x1b5>
			4859: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    485d:	test   rax,rax
    4860:	je     495e <botlish_fn_47+0x2b6>
    4866:	mov    rdx,r13
    4869:	mov    rsi,r14
    486c:	mov    rdi,rbx
    486f:	call   4874 <botlish_fn_47+0x1cc>
			4870: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    4874:	test   rax,rax
    4877:	je     495e <botlish_fn_47+0x2b6>
    487d:	mov    QWORD PTR [rsp+0x18],rax
    4882:	mov    rcx,rax
    4885:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    488e:	mov    r8,QWORD PTR [rsp+0x28]
    4893:	mov    rdx,r13
    4896:	mov    rsi,r14
    4899:	mov    rdi,rbx
    489c:	call   48a1 <botlish_fn_47+0x1f9>
			489d: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    48a1:	test   rax,rax
    48a4:	je     495e <botlish_fn_47+0x2b6>
    48aa:	mov    QWORD PTR [rsp+0x18],rax
    48af:	mov    rcx,r13
    48b2:	mov    rdx,rax
    48b5:	mov    rsi,r14
    48b8:	mov    rdi,rbx
    48bb:	mov    r8,r12
    48be:	call   48c3 <botlish_fn_47+0x21b>
			48bf: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    48c3:	test   rax,rax
    48c6:	je     495e <botlish_fn_47+0x2b6>
    48cc:	mov    rbx,QWORD PTR [rsp+0x30]
    48d1:	mov    r12,QWORD PTR [rsp+0x38]
    48d6:	mov    r13,QWORD PTR [rsp+0x40]
    48db:	mov    r14,QWORD PTR [rsp+0x48]
    48e0:	mov    r15,QWORD PTR [rsp+0x50]
    48e5:	add    rsp,0x60
    48e9:	mov    rsp,rbp
    48ec:	pop    rbp
    48ed:	ret
    48ee:	mov    rsi,r14
    48f1:	mov    rdi,rbx
    48f4:	call   48f9 <botlish_fn_47+0x251>
			48f5: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    48f9:	test   rax,rax
    48fc:	je     495e <botlish_fn_47+0x2b6>
    4902:	xor    ecx,ecx
    4904:	test   rax,0x7
    490a:	je     4918 <botlish_fn_47+0x270>
    4910:	mov    rsi,rax
    4913:	jmp    4926 <botlish_fn_47+0x27e>
    4918:	movzx  rcx,BYTE PTR [rax]
    491c:	mov    rsi,rax
    491f:	rex cmp cl,0x8
    4923:	sete   cl
    4926:	test   cl,cl
    4928:	jne    4947 <botlish_fn_47+0x29f>
    492e:	mov    rdi,rbx
    4931:	mov    rax,QWORD PTR [rdi+0x10]
    4935:	mov    rcx,QWORD PTR [rax]
    4938:	mov    edx,0x8
    493d:	call   4942 <botlish_fn_47+0x29a>
			493e: R_X86_64_PLT32	rt_type_error-0x4
    4942:	jmp    495e <botlish_fn_47+0x2b6>
    4947:	mov    rcx,r12
    494a:	mov    rdx,r15
    494d:	mov    rdi,rbx
    4950:	call   4955 <botlish_fn_47+0x2ad>
			4951: R_X86_64_PLT32	rt_mutarray_set-0x4
    4955:	test   rax,rax
    4958:	jne    4983 <botlish_fn_47+0x2db>
    495e:	xor    rax,rax
    4961:	mov    rbx,QWORD PTR [rsp+0x30]
    4966:	mov    r12,QWORD PTR [rsp+0x38]
    496b:	mov    r13,QWORD PTR [rsp+0x40]
    4970:	mov    r14,QWORD PTR [rsp+0x48]
    4975:	mov    r15,QWORD PTR [rsp+0x50]
    497a:	add    rsp,0x60
    497e:	mov    rsp,rbp
    4981:	pop    rbp
    4982:	ret
    4983:	mov    eax,0xa
    4988:	mov    rbx,QWORD PTR [rsp+0x30]
    498d:	mov    r12,QWORD PTR [rsp+0x38]
    4992:	mov    r13,QWORD PTR [rsp+0x40]
    4997:	mov    r14,QWORD PTR [rsp+0x48]
    499c:	mov    r15,QWORD PTR [rsp+0x50]
    49a1:	add    rsp,0x60
    49a5:	mov    rsp,rbp
    49a8:	pop    rbp
    49a9:	ret
    49aa:	add    BYTE PTR [rax],al
    49ac:	add    BYTE PTR [rax],al
    49ae:	add    BYTE PTR [rax],al
    49b0:	(bad)
    49b1:	add    BYTE PTR [rax],al
    49b3:	add    BYTE PTR [rax],al
    49b5:	add    BYTE PTR [rax],al
	...

00000000000049b8 <botlish_entry_47: ht_set<mutarray, str, str>>:
    49b8:	push   rbp
    49b9:	mov    rbp,rsp
    49bc:	mov    rsi,QWORD PTR [rdx]
    49bf:	mov    r8,QWORD PTR [rdx+0x8]
    49c3:	mov    rcx,QWORD PTR [rdx+0x10]
    49c7:	mov    rdx,r8
    49ca:	call   49cf <botlish_entry_47+0x17>
			49cb: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    49cf:	mov    rsp,rbp
    49d2:	pop    rbp
    49d3:	ret

00000000000049d4 <botlish_fn_48: row_new<bool, int>>:
    49d4:	push   rbp
    49d5:	mov    rbp,rsp
    49d8:	sub    rsp,0x10
    49dc:	mov    QWORD PTR [rsp],rdx
    49e0:	mov    r8,rdx
    49e3:	cmp    rsi,0x6
    49e7:	je     4a04 <botlish_fn_48+0x30>
    49ed:	call   49f2 <botlish_fn_48+0x1e>
			49ee: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    49f2:	test   rax,rax
    49f5:	je     4a15 <botlish_fn_48+0x41>
    49fb:	add    rsp,0x10
    49ff:	mov    rsp,rbp
    4a02:	pop    rbp
    4a03:	ret
    4a04:	mov    rsi,r8
    4a07:	call   4a0c <botlish_fn_48+0x38>
			4a08: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    4a0c:	test   rax,rax
    4a0f:	jne    4a21 <botlish_fn_48+0x4d>
    4a15:	xor    rax,rax
    4a18:	add    rsp,0x10
    4a1c:	mov    rsp,rbp
    4a1f:	pop    rbp
    4a20:	ret
    4a21:	add    rsp,0x10
    4a25:	mov    rsp,rbp
    4a28:	pop    rbp
    4a29:	ret

0000000000004a2a <botlish_entry_48: row_new<bool, int>>:
    4a2a:	push   rbp
    4a2b:	mov    rbp,rsp
    4a2e:	mov    rsi,QWORD PTR [rdx]
    4a31:	mov    rdx,QWORD PTR [rdx+0x8]
    4a35:	call   4a3a <botlish_entry_48+0x10>
			4a36: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4a3a:	mov    rsp,rbp
    4a3d:	pop    rbp
    4a3e:	ret

0000000000004a3f <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4a3f:	push   rbp
    4a40:	mov    rbp,rsp
    4a43:	sub    rsp,0x70
    4a47:	mov    QWORD PTR [rsp+0x40],rbx
    4a4c:	mov    QWORD PTR [rsp+0x48],r12
    4a51:	mov    QWORD PTR [rsp+0x50],r13
    4a56:	mov    QWORD PTR [rsp+0x58],r14
    4a5b:	mov    QWORD PTR [rsp+0x60],r15
    4a60:	mov    QWORD PTR [rsp+0x28],rdi
    4a65:	mov    QWORD PTR [rsp],rsi
    4a69:	mov    r14,rsi
    4a6c:	mov    QWORD PTR [rsp+0x8],rdx
    4a71:	mov    QWORD PTR [rsp+0x10],rcx
    4a76:	mov    r13,rcx
    4a79:	sar    r8,1
    4a7c:	mov    rbx,r8
    4a7f:	mov    r15,r9
    4a82:	cmp    rbx,r15
    4a85:	jge    4b90 <botlish_fn_49+0x151>
    4a8b:	mov    r12,rdx
    4a8e:	mov    rdx,QWORD PTR [r12+0x8]
    4a93:	mov    rcx,rbx
    4a96:	shl    rcx,1
    4a99:	or     rcx,0x1
    4a9d:	sar    rcx,1
    4aa0:	cmp    rcx,rdx
    4aa3:	jb     4ad1 <botlish_fn_49+0x92>
    4aa9:	mov    rdx,rbx
    4aac:	shl    rdx,1
    4aaf:	or     rdx,0x1
    4ab3:	mov    rsi,r12
    4ab6:	mov    rdi,QWORD PTR [rsp+0x28]
    4abb:	call   4ac0 <botlish_fn_49+0x81>
			4abc: R_X86_64_PLT32	rt_list_get-0x4
    4ac0:	test   rax,rax
    4ac3:	je     4b4e <botlish_fn_49+0x10f>
    4ac9:	mov    rdx,rax
    4acc:	jmp    4ada <botlish_fn_49+0x9b>
    4ad1:	mov    rax,QWORD PTR [r12+0x10]
    4ad6:	mov    rdx,QWORD PTR [rax+rcx*8]
    4ada:	mov    QWORD PTR [rsp+0x18],rdx
    4adf:	mov    QWORD PTR [rsp+0x30],rdx
    4ae4:	mov    rax,QWORD PTR [r13+0x8]
    4ae8:	mov    rcx,rbx
    4aeb:	shl    rcx,1
    4aee:	or     rcx,0x1
    4af2:	sar    rcx,1
    4af5:	cmp    rcx,rax
    4af8:	jb     4b26 <botlish_fn_49+0xe7>
    4afe:	mov    rdx,rbx
    4b01:	shl    rdx,1
    4b04:	or     rdx,0x1
    4b08:	mov    rsi,r13
    4b0b:	mov    rdi,QWORD PTR [rsp+0x28]
    4b10:	call   4b15 <botlish_fn_49+0xd6>
			4b11: R_X86_64_PLT32	rt_list_get-0x4
    4b15:	test   rax,rax
    4b18:	je     4b4e <botlish_fn_49+0x10f>
    4b1e:	mov    rcx,rax
    4b21:	jmp    4b2e <botlish_fn_49+0xef>
    4b26:	mov    rax,QWORD PTR [r13+0x10]
    4b2a:	mov    rcx,QWORD PTR [rax+rcx*8]
    4b2e:	mov    QWORD PTR [rsp+0x20],rcx
    4b33:	mov    rdx,QWORD PTR [rsp+0x30]
    4b38:	mov    rsi,r14
    4b3b:	mov    rdi,QWORD PTR [rsp+0x28]
    4b40:	call   4b45 <botlish_fn_49+0x106>
			4b41: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4b45:	test   rax,rax
    4b48:	jne    4b73 <botlish_fn_49+0x134>
    4b4e:	xor    rax,rax
    4b51:	mov    rbx,QWORD PTR [rsp+0x40]
    4b56:	mov    r12,QWORD PTR [rsp+0x48]
    4b5b:	mov    r13,QWORD PTR [rsp+0x50]
    4b60:	mov    r14,QWORD PTR [rsp+0x58]
    4b65:	mov    r15,QWORD PTR [rsp+0x60]
    4b6a:	add    rsp,0x70
    4b6e:	mov    rsp,rbp
    4b71:	pop    rbp
    4b72:	ret
    4b73:	mov    QWORD PTR [rsp],r14
    4b77:	mov    QWORD PTR [rsp+0x8],r12
    4b7c:	mov    QWORD PTR [rsp+0x10],r13
    4b81:	add    rbx,0x1
    4b88:	mov    rdx,r12
    4b8b:	jmp    4a82 <botlish_fn_49+0x43>
    4b90:	mov    rax,r14
    4b93:	mov    rbx,QWORD PTR [rsp+0x40]
    4b98:	mov    r12,QWORD PTR [rsp+0x48]
    4b9d:	mov    r13,QWORD PTR [rsp+0x50]
    4ba2:	mov    r14,QWORD PTR [rsp+0x58]
    4ba7:	mov    r15,QWORD PTR [rsp+0x60]
    4bac:	add    rsp,0x70
    4bb0:	mov    rsp,rbp
    4bb3:	pop    rbp
    4bb4:	ret

0000000000004bb5 <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4bb5:	push   rbp
    4bb6:	mov    rbp,rsp
    4bb9:	mov    rsi,QWORD PTR [rdx]
    4bbc:	mov    r10,QWORD PTR [rdx+0x8]
    4bc0:	mov    rcx,QWORD PTR [rdx+0x10]
    4bc4:	mov    r8,QWORD PTR [rdx+0x18]
    4bc8:	mov    r9,QWORD PTR [rdx+0x20]
    4bcc:	sar    r9,1
    4bcf:	mov    rdx,r10
    4bd2:	call   4bd7 <botlish_entry_49+0x22>
			4bd3: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4bd7:	mov    rsp,rbp
    4bda:	pop    rbp
    4bdb:	ret

0000000000004bdc <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4bdc:	push   rbp
    4bdd:	mov    rbp,rsp
    4be0:	sub    rsp,0x50
    4be4:	mov    QWORD PTR [rsp+0x20],rbx
    4be9:	mov    QWORD PTR [rsp+0x28],r12
    4bee:	mov    QWORD PTR [rsp+0x30],r13
    4bf3:	mov    QWORD PTR [rsp+0x38],r14
    4bf8:	mov    QWORD PTR [rsp+0x40],r15
    4bfd:	mov    r12,rdi
    4c00:	mov    QWORD PTR [rsp],rsi
    4c04:	mov    r15,rsi
    4c07:	mov    QWORD PTR [rsp+0x8],rdx
    4c0c:	mov    QWORD PTR [rsp+0x10],rcx
    4c11:	mov    r13,rcx
    4c14:	mov    QWORD PTR [rsp+0x18],r8
    4c19:	mov    rsi,r8
    4c1c:	mov    rdi,r12
    4c1f:	call   4c24 <botlish_fn_50+0x48>
			4c20: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4c24:	test   rax,rax
    4c27:	je     4c71 <botlish_fn_50+0x95>
    4c2d:	mov    QWORD PTR [rsp+0x8],rax
    4c32:	mov    r14,rax
    4c35:	mov    ebx,0x1
    4c3a:	mov    QWORD PTR [rsp+0x18],0x1
    4c43:	mov    rsi,r13
    4c46:	mov    rdi,r12
    4c49:	call   4c4e <botlish_fn_50+0x72>
			4c4a: R_X86_64_PLT32	rt_list_len-0x4
    4c4e:	mov    r9,rax
    4c51:	sar    r9,1
    4c54:	mov    rcx,r13
    4c57:	mov    rdx,r15
    4c5a:	mov    rsi,r14
    4c5d:	mov    rdi,r12
    4c60:	mov    r8,rbx
    4c63:	call   4c68 <botlish_fn_50+0x8c>
			4c64: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4c68:	test   rax,rax
    4c6b:	jne    4c96 <botlish_fn_50+0xba>
    4c71:	xor    rax,rax
    4c74:	mov    rbx,QWORD PTR [rsp+0x20]
    4c79:	mov    r12,QWORD PTR [rsp+0x28]
    4c7e:	mov    r13,QWORD PTR [rsp+0x30]
    4c83:	mov    r14,QWORD PTR [rsp+0x38]
    4c88:	mov    r15,QWORD PTR [rsp+0x40]
    4c8d:	add    rsp,0x50
    4c91:	mov    rsp,rbp
    4c94:	pop    rbp
    4c95:	ret
    4c96:	mov    rbx,QWORD PTR [rsp+0x20]
    4c9b:	mov    r12,QWORD PTR [rsp+0x28]
    4ca0:	mov    r13,QWORD PTR [rsp+0x30]
    4ca5:	mov    r14,QWORD PTR [rsp+0x38]
    4caa:	mov    r15,QWORD PTR [rsp+0x40]
    4caf:	add    rsp,0x50
    4cb3:	mov    rsp,rbp
    4cb6:	pop    rbp
    4cb7:	ret

0000000000004cb8 <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4cb8:	push   rbp
    4cb9:	mov    rbp,rsp
    4cbc:	mov    rsi,QWORD PTR [rdx]
    4cbf:	mov    r9,QWORD PTR [rdx+0x8]
    4cc3:	mov    rcx,QWORD PTR [rdx+0x10]
    4cc7:	mov    r8,QWORD PTR [rdx+0x18]
    4ccb:	mov    rdx,r9
    4cce:	call   4cd3 <botlish_entry_50+0x1b>
			4ccf: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4cd3:	mov    rsp,rbp
    4cd6:	pop    rbp
    4cd7:	ret

0000000000004cd8 <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4cd8:	push   rbp
    4cd9:	mov    rbp,rsp
    4cdc:	sub    rsp,0x90
    4ce3:	mov    QWORD PTR [rsp+0x60],rbx
    4ce8:	mov    QWORD PTR [rsp+0x68],r12
    4ced:	mov    QWORD PTR [rsp+0x70],r13
    4cf2:	mov    QWORD PTR [rsp+0x78],r14
    4cf7:	mov    QWORD PTR [rsp+0x80],r15
    4cff:	mov    r13,r8
    4d02:	mov    QWORD PTR [rsp+0x38],rdi
    4d07:	mov    rdi,QWORD PTR [rbp+0x10]
    4d0b:	mov    r15,QWORD PTR [rbp+0x18]
    4d0f:	mov    QWORD PTR [rsp+0x28],0x0
    4d18:	mov    QWORD PTR [rsp+0x30],0x0
    4d21:	mov    QWORD PTR [rsp],rsi
    4d25:	mov    QWORD PTR [rsp+0x8],rcx
    4d2a:	mov    r14,rcx
    4d2d:	mov    QWORD PTR [rsp+0x10],r9
    4d32:	mov    QWORD PTR [rsp+0x18],rdi
    4d37:	mov    QWORD PTR [rsp+0x20],r15
    4d3c:	sar    rdx,1
    4d3f:	mov    r12,rdx
    4d42:	mov    rbx,rsi
    4d45:	mov    QWORD PTR [rsp+0x40],r9
    4d4a:	mov    QWORD PTR [rsp+0x48],rdi
    4d4f:	mov    rsi,rbx
    4d52:	mov    rdi,QWORD PTR [rsp+0x38]
    4d57:	call   4d5c <botlish_fn_51+0x84>
			4d58: R_X86_64_PLT32	rt_list_len-0x4
    4d5c:	sar    rax,1
    4d5f:	cmp    r12,rax
    4d62:	jge    4e8d <botlish_fn_51+0x1b5>
    4d68:	mov    rax,r13
    4d6b:	or     rax,0x1
    4d6f:	mov    QWORD PTR [rsp+0x28],rax
    4d74:	mov    rcx,QWORD PTR [rbx+0x8]
    4d78:	mov    rax,r12
    4d7b:	shl    rax,1
    4d7e:	or     rax,0x1
    4d82:	sar    rax,1
    4d85:	cmp    rax,rcx
    4d88:	jb     4db6 <botlish_fn_51+0xde>
    4d8e:	mov    rdx,r12
    4d91:	shl    rdx,1
    4d94:	or     rdx,0x1
    4d98:	mov    rsi,rbx
    4d9b:	mov    rdi,QWORD PTR [rsp+0x38]
    4da0:	call   4da5 <botlish_fn_51+0xcd>
			4da1: R_X86_64_PLT32	rt_list_get-0x4
    4da5:	test   rax,rax
    4da8:	je     4eaa <botlish_fn_51+0x1d2>
    4dae:	mov    rcx,rax
    4db1:	jmp    4dbe <botlish_fn_51+0xe6>
    4db6:	mov    rcx,QWORD PTR [rbx+0x10]
    4dba:	mov    rcx,QWORD PTR [rcx+rax*8]
    4dbe:	mov    QWORD PTR [rsp+0x30],rcx
    4dc3:	mov    rdx,r13
    4dc6:	or     rdx,0x1
    4dca:	mov    rsi,r14
    4dcd:	mov    rdi,QWORD PTR [rsp+0x38]
    4dd2:	mov    r8,r15
    4dd5:	call   4dda <botlish_fn_51+0x102>
			4dd6: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4dda:	test   rax,rax
    4ddd:	je     4eaa <botlish_fn_51+0x1d2>
    4de3:	mov    QWORD PTR [rsp+0x28],rax
    4de8:	mov    rcx,rax
    4deb:	mov    rsi,QWORD PTR [rsp+0x40]
    4df0:	mov    rdx,QWORD PTR [rsp+0x48]
    4df5:	mov    rdi,QWORD PTR [rsp+0x38]
    4dfa:	call   4dff <botlish_fn_51+0x127>
			4dfb: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4dff:	test   rax,rax
    4e02:	je     4eaa <botlish_fn_51+0x1d2>
    4e08:	mov    QWORD PTR [rsp+0x10],rax
    4e0d:	mov    QWORD PTR [rsp+0x50],rax
    4e12:	mov    QWORD PTR [rsp+0x28],0x3
    4e1b:	mov    rsi,QWORD PTR [rsp+0x48]
    4e20:	test   rsi,0x1
    4e27:	je     4e46 <botlish_fn_51+0x16e>
    4e2d:	mov    rsi,QWORD PTR [rsp+0x48]
    4e32:	mov    rax,rsi
    4e35:	add    rax,0x2
    4e39:	seto   r10b
    4e3d:	test   r10b,r10b
    4e40:	je     4e5a <botlish_fn_51+0x182>
    4e46:	mov    edx,0x3
    4e4b:	mov    rsi,QWORD PTR [rsp+0x48]
    4e50:	mov    rdi,QWORD PTR [rsp+0x38]
    4e55:	call   4e5a <botlish_fn_51+0x182>
			4e56: R_X86_64_PLT32	rt_int_add-0x4
    4e5a:	mov    QWORD PTR [rsp],rbx
    4e5e:	mov    QWORD PTR [rsp+0x8],r14
    4e63:	mov    rcx,QWORD PTR [rsp+0x50]
    4e68:	mov    QWORD PTR [rsp+0x10],rcx
    4e6d:	mov    QWORD PTR [rsp+0x18],rax
    4e72:	mov    QWORD PTR [rsp+0x20],r15
    4e77:	add    r12,0x1
    4e7e:	mov    QWORD PTR [rsp+0x40],rcx
    4e83:	mov    QWORD PTR [rsp+0x48],rax
    4e88:	jmp    4d4f <botlish_fn_51+0x77>
    4e8d:	mov    rdx,QWORD PTR [rsp+0x48]
    4e92:	mov    rsi,QWORD PTR [rsp+0x40]
    4e97:	mov    rdi,QWORD PTR [rsp+0x38]
    4e9c:	call   4ea1 <botlish_fn_51+0x1c9>
			4e9d: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4ea1:	test   rax,rax
    4ea4:	jne    4ed5 <botlish_fn_51+0x1fd>
    4eaa:	xor    rax,rax
    4ead:	mov    rbx,QWORD PTR [rsp+0x60]
    4eb2:	mov    r12,QWORD PTR [rsp+0x68]
    4eb7:	mov    r13,QWORD PTR [rsp+0x70]
    4ebc:	mov    r14,QWORD PTR [rsp+0x78]
    4ec1:	mov    r15,QWORD PTR [rsp+0x80]
    4ec9:	add    rsp,0x90
    4ed0:	mov    rsp,rbp
    4ed3:	pop    rbp
    4ed4:	ret
    4ed5:	mov    rbx,QWORD PTR [rsp+0x60]
    4eda:	mov    r12,QWORD PTR [rsp+0x68]
    4edf:	mov    r13,QWORD PTR [rsp+0x70]
    4ee4:	mov    r14,QWORD PTR [rsp+0x78]
    4ee9:	mov    r15,QWORD PTR [rsp+0x80]
    4ef1:	add    rsp,0x90
    4ef8:	mov    rsp,rbp
    4efb:	pop    rbp
    4efc:	ret

0000000000004efd <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4efd:	push   rbp
    4efe:	mov    rbp,rsp
    4f01:	sub    rsp,0x10
    4f05:	mov    rsi,QWORD PTR [rdx]
    4f08:	mov    r10,QWORD PTR [rdx+0x8]
    4f0c:	mov    rcx,QWORD PTR [rdx+0x10]
    4f10:	mov    r8,QWORD PTR [rdx+0x18]
    4f14:	mov    r9,QWORD PTR [rdx+0x20]
    4f18:	mov    r11,QWORD PTR [rdx+0x28]
    4f1c:	mov    rax,QWORD PTR [rdx+0x30]
    4f20:	mov    QWORD PTR [rsp],r11
    4f24:	mov    QWORD PTR [rsp+0x8],rax
    4f29:	mov    rdx,r10
    4f2c:	call   4f31 <botlish_entry_51+0x34>
			4f2d: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4f31:	add    rsp,0x10
    4f35:	mov    rsp,rbp
    4f38:	pop    rbp
    4f39:	ret

0000000000004f3a <botlish_fn_52: csv_records_generic<str, bool>>:
    4f3a:	push   rbp
    4f3b:	mov    rbp,rsp
    4f3e:	sub    rsp,0x80
    4f45:	mov    QWORD PTR [rsp+0x50],rbx
    4f4a:	mov    QWORD PTR [rsp+0x58],r12
    4f4f:	mov    QWORD PTR [rsp+0x60],r13
    4f54:	mov    QWORD PTR [rsp+0x68],r14
    4f59:	mov    QWORD PTR [rsp+0x70],r15
    4f5e:	mov    r12,rdi
    4f61:	mov    QWORD PTR [rsp+0x20],0x0
    4f6a:	mov    QWORD PTR [rsp+0x28],0x0
    4f73:	mov    QWORD PTR [rsp+0x30],0x0
    4f7c:	mov    QWORD PTR [rsp+0x38],0x0
    4f85:	mov    QWORD PTR [rsp+0x40],0x0
    4f8e:	mov    QWORD PTR [rsp+0x10],rsi
    4f93:	mov    QWORD PTR [rsp+0x18],rdx
    4f98:	mov    r13,rdx
    4f9b:	mov    rdi,r12
    4f9e:	call   4fa3 <botlish_fn_52+0x69>
			4f9f: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4fa3:	mov    rcx,rax
    4fa6:	mov    r15,rax
    4fa9:	test   rax,rcx
    4fac:	je     5124 <botlish_fn_52+0x1ea>
    4fb2:	mov    rax,r15
    4fb5:	mov    QWORD PTR [rsp+0x10],rax
    4fba:	mov    rsi,r15
    4fbd:	mov    rdi,r12
    4fc0:	call   4fc5 <botlish_fn_52+0x8b>
			4fc1: R_X86_64_PLT32	rt_list_len-0x4
    4fc5:	sar    rax,1
    4fc8:	cmp    rax,0x1
    4fcc:	jle    510d <botlish_fn_52+0x1d3>
    4fd2:	mov    rax,r15
    4fd5:	mov    rax,QWORD PTR [rax+0x8]
    4fd9:	test   rax,rax
    4fdc:	jne    5003 <botlish_fn_52+0xc9>
    4fe2:	mov    edx,0x1
    4fe7:	mov    rsi,r15
    4fea:	mov    rdi,r12
    4fed:	call   4ff2 <botlish_fn_52+0xb8>
			4fee: R_X86_64_PLT32	rt_list_get-0x4
    4ff2:	test   rax,rax
    4ff5:	je     5124 <botlish_fn_52+0x1ea>
    4ffb:	mov    rbx,rax
    4ffe:	jmp    500a <botlish_fn_52+0xd0>
    5003:	mov    rax,QWORD PTR [r15+0x10]
    5007:	mov    rbx,QWORD PTR [rax]
    500a:	mov    QWORD PTR [rsp+0x20],rbx
    500f:	mov    rsi,rbx
    5012:	mov    rdi,r12
    5015:	call   501a <botlish_fn_52+0xe0>
			5016: R_X86_64_PLT32	rt_list_len-0x4
    501a:	mov    r14,rax
    501d:	mov    QWORD PTR [rsp+0x48],rbx
    5022:	mov    QWORD PTR [rsp+0x28],r14
    5027:	mov    rax,QWORD PTR [r15+0x8]
    502b:	cmp    rax,0x1
    502f:	ja     5056 <botlish_fn_52+0x11c>
    5035:	mov    edx,0x3
    503a:	mov    rsi,r15
    503d:	mov    rdi,r12
    5040:	call   5045 <botlish_fn_52+0x10b>
			5041: R_X86_64_PLT32	rt_list_get-0x4
    5045:	test   rax,rax
    5048:	je     5124 <botlish_fn_52+0x1ea>
    504e:	mov    rcx,rax
    5051:	jmp    505e <botlish_fn_52+0x124>
    5056:	mov    rax,QWORD PTR [r15+0x10]
    505a:	mov    rcx,QWORD PTR [rax+0x8]
    505e:	mov    QWORD PTR [rsp+0x30],rcx
    5063:	mov    rbx,r13
    5066:	mov    rdx,r14
    5069:	mov    rsi,QWORD PTR [rsp+0x48]
    506e:	mov    rdi,r12
    5071:	mov    r8,rbx
    5074:	call   5079 <botlish_fn_52+0x13f>
			5075: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    5079:	mov    r13,r14
    507c:	test   rax,rax
    507f:	je     5124 <botlish_fn_52+0x1ea>
    5085:	mov    QWORD PTR [rsp+0x30],rax
    508a:	mov    rsi,rax
    508d:	mov    QWORD PTR [rsp+0x38],0x5
    5096:	mov    rdi,r12
    5099:	call   509e <botlish_fn_52+0x164>
			509a: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    509e:	test   rax,rax
    50a1:	je     5124 <botlish_fn_52+0x1ea>
    50a7:	mov    QWORD PTR [rsp+0x30],rax
    50ac:	mov    r9,rax
    50af:	mov    r10d,0x3
    50b5:	mov    QWORD PTR [rsp+0x40],0x3
    50be:	mov    edx,0x5
    50c3:	mov    QWORD PTR [rsp],r10
    50c7:	mov    QWORD PTR [rsp+0x8],rbx
    50cc:	mov    rcx,QWORD PTR [rsp+0x48]
    50d1:	mov    rsi,r15
    50d4:	mov    rdi,r12
    50d7:	mov    r8,r13
    50da:	call   50df <botlish_fn_52+0x1a5>
			50db: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    50df:	test   rax,rax
    50e2:	je     5124 <botlish_fn_52+0x1ea>
    50e8:	mov    rbx,QWORD PTR [rsp+0x50]
    50ed:	mov    r12,QWORD PTR [rsp+0x58]
    50f2:	mov    r13,QWORD PTR [rsp+0x60]
    50f7:	mov    r14,QWORD PTR [rsp+0x68]
    50fc:	mov    r15,QWORD PTR [rsp+0x70]
    5101:	add    rsp,0x80
    5108:	mov    rsp,rbp
    510b:	pop    rbp
    510c:	ret
    510d:	xor    rdx,rdx
    5110:	mov    rdi,r12
    5113:	mov    rsi,rdx
    5116:	call   511b <botlish_fn_52+0x1e1>
			5117: R_X86_64_PLT32	rt_list_new-0x4
    511b:	test   rax,rax
    511e:	jne    514c <botlish_fn_52+0x212>
    5124:	xor    rax,rax
    5127:	mov    rbx,QWORD PTR [rsp+0x50]
    512c:	mov    r12,QWORD PTR [rsp+0x58]
    5131:	mov    r13,QWORD PTR [rsp+0x60]
    5136:	mov    r14,QWORD PTR [rsp+0x68]
    513b:	mov    r15,QWORD PTR [rsp+0x70]
    5140:	add    rsp,0x80
    5147:	mov    rsp,rbp
    514a:	pop    rbp
    514b:	ret
    514c:	mov    rbx,QWORD PTR [rsp+0x50]
    5151:	mov    r12,QWORD PTR [rsp+0x58]
    5156:	mov    r13,QWORD PTR [rsp+0x60]
    515b:	mov    r14,QWORD PTR [rsp+0x68]
    5160:	mov    r15,QWORD PTR [rsp+0x70]
    5165:	add    rsp,0x80
    516c:	mov    rsp,rbp
    516f:	pop    rbp
    5170:	ret

0000000000005171 <botlish_entry_52: csv_records_generic<str, bool>>:
    5171:	push   rbp
    5172:	mov    rbp,rsp
    5175:	mov    rsi,QWORD PTR [rdx]
    5178:	mov    rdx,QWORD PTR [rdx+0x8]
    517c:	call   5181 <botlish_entry_52+0x10>
			517d: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5181:	mov    rsp,rbp
    5184:	pop    rbp
    5185:	ret

0000000000005186 <botlish_fn_53: csv_records<str>>:
    5186:	push   rbp
    5187:	mov    rbp,rsp
    518a:	sub    rsp,0x10
    518e:	mov    QWORD PTR [rsp],rsi
    5192:	mov    edx,0x2
    5197:	mov    QWORD PTR [rsp+0x8],0x2
    51a0:	call   51a5 <botlish_fn_53+0x1f>
			51a1: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    51a5:	test   rax,rax
    51a8:	jne    51ba <botlish_fn_53+0x34>
    51ae:	xor    rax,rax
    51b1:	add    rsp,0x10
    51b5:	mov    rsp,rbp
    51b8:	pop    rbp
    51b9:	ret
    51ba:	add    rsp,0x10
    51be:	mov    rsp,rbp
    51c1:	pop    rbp
    51c2:	ret

00000000000051c3 <botlish_entry_53: csv_records<str>>:
    51c3:	push   rbp
    51c4:	mov    rbp,rsp
    51c7:	mov    rsi,QWORD PTR [rdx]
    51ca:	call   51cf <botlish_entry_53+0xc>
			51cb: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    51cf:	mov    rsp,rbp
    51d2:	pop    rbp
    51d3:	ret

00000000000051d4 <botlish_fn_54: csv_records_presized<str>>:
    51d4:	push   rbp
    51d5:	mov    rbp,rsp
    51d8:	sub    rsp,0x10
    51dc:	mov    QWORD PTR [rsp],rsi
    51e0:	mov    edx,0x6
    51e5:	mov    QWORD PTR [rsp+0x8],0x6
    51ee:	call   51f3 <botlish_fn_54+0x1f>
			51ef: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    51f3:	test   rax,rax
    51f6:	jne    5208 <botlish_fn_54+0x34>
    51fc:	xor    rax,rax
    51ff:	add    rsp,0x10
    5203:	mov    rsp,rbp
    5206:	pop    rbp
    5207:	ret
    5208:	add    rsp,0x10
    520c:	mov    rsp,rbp
    520f:	pop    rbp
    5210:	ret

0000000000005211 <botlish_entry_54: csv_records_presized<str>>:
    5211:	push   rbp
    5212:	mov    rbp,rsp
    5215:	mov    rsi,QWORD PTR [rdx]
    5218:	call   521d <botlish_entry_54+0xc>
			5219: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    521d:	mov    rsp,rbp
    5220:	pop    rbp
    5221:	ret
    5222:	add    BYTE PTR [rax],al
    5224:	add    BYTE PTR [rax],al
	...

0000000000005228 <botlish_fn_55: sample<generic>>:
    5228:	push   rbp
    5229:	mov    rbp,rsp
    522c:	sub    rsp,0xc0
    5233:	mov    QWORD PTR [rsp+0x90],rbx
    523b:	mov    QWORD PTR [rsp+0x98],r12
    5243:	mov    QWORD PTR [rsp+0xa0],r13
    524b:	mov    QWORD PTR [rsp+0xa8],r14
    5253:	mov    QWORD PTR [rsp+0xb0],r15
    525b:	mov    QWORD PTR [rsp+0x8],0x0
    5264:	mov    QWORD PTR [rsp+0x10],0x0
    526d:	mov    QWORD PTR [rsp+0x18],0x0
    5276:	mov    QWORD PTR [rsp+0x20],0x0
    527f:	mov    QWORD PTR [rsp+0x28],0x0
    5288:	mov    QWORD PTR [rsp+0x30],0x0
    5291:	mov    QWORD PTR [rsp+0x38],0x0
    529a:	mov    rax,QWORD PTR [rdi+0x10]
    529e:	mov    r13,rdi
    52a1:	mov    rsi,QWORD PTR [rax+0x50]
    52a5:	mov    QWORD PTR [rsp],rsi
    52a9:	call   52ae <botlish_fn_55+0x86>
			52aa: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    52ae:	mov    rsi,rax
    52b1:	mov    r12,rax
    52b4:	test   rax,rsi
    52b7:	je     563c <botlish_fn_55+0x414>
    52bd:	mov    rax,r12
    52c0:	mov    QWORD PTR [rsp],rax
    52c4:	mov    rdi,r13
    52c7:	mov    rax,QWORD PTR [rdi+0x10]
    52cb:	mov    rsi,QWORD PTR [rax+0x50]
    52cf:	mov    QWORD PTR [rsp+0x8],rsi
    52d4:	call   52d9 <botlish_fn_55+0xb1>
			52d5: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    52d9:	mov    rbx,rax
    52dc:	test   rbx,rbx
    52df:	je     563c <botlish_fn_55+0x414>
    52e5:	mov    rax,r12
    52e8:	mov    rax,QWORD PTR [rax+0x8]
    52ec:	test   rax,rax
    52ef:	jne    5316 <botlish_fn_55+0xee>
    52f5:	mov    edx,0x1
    52fa:	mov    rsi,r12
    52fd:	mov    rdi,r13
    5300:	call   5305 <botlish_fn_55+0xdd>
			5301: R_X86_64_PLT32	rt_list_get-0x4
    5305:	test   rax,rax
    5308:	je     563c <botlish_fn_55+0x414>
    530e:	mov    rsi,rax
    5311:	jmp    531e <botlish_fn_55+0xf6>
    5316:	mov    rax,QWORD PTR [r12+0x10]
    531b:	mov    rsi,QWORD PTR [rax]
    531e:	mov    QWORD PTR [rsp+0x8],rsi
    5323:	mov    r15,rsi
    5326:	mov    rax,QWORD PTR [r12+0x8]
    532b:	cmp    rax,0x1
    532f:	ja     5356 <botlish_fn_55+0x12e>
    5335:	mov    edx,0x3
    533a:	mov    rsi,r12
    533d:	mov    rdi,r13
    5340:	call   5345 <botlish_fn_55+0x11d>
			5341: R_X86_64_PLT32	rt_list_get-0x4
    5345:	test   rax,rax
    5348:	je     563c <botlish_fn_55+0x414>
    534e:	mov    rsi,rax
    5351:	jmp    535f <botlish_fn_55+0x137>
    5356:	mov    rax,QWORD PTR [r12+0x10]
    535b:	mov    rsi,QWORD PTR [rax+0x8]
    535f:	mov    QWORD PTR [rsp+0x10],rsi
    5364:	mov    r14,rsi
    5367:	mov    rax,QWORD PTR [rbx+0x8]
    536b:	mov    rsi,rbx
    536e:	test   rax,rax
    5371:	jne    5395 <botlish_fn_55+0x16d>
    5377:	mov    edx,0x1
    537c:	mov    rdi,r13
    537f:	call   5384 <botlish_fn_55+0x15c>
			5380: R_X86_64_PLT32	rt_list_get-0x4
    5384:	test   rax,rax
    5387:	je     563c <botlish_fn_55+0x414>
    538d:	mov    rsi,rax
    5390:	jmp    539c <botlish_fn_55+0x174>
    5395:	mov    rax,QWORD PTR [rsi+0x10]
    5399:	mov    rsi,QWORD PTR [rax]
    539c:	mov    QWORD PTR [rsp+0x18],rsi
    53a1:	mov    rdi,r13
    53a4:	mov    QWORD PTR [rsp+0x78],rsi
    53a9:	mov    rax,QWORD PTR [rdi+0x10]
    53ad:	mov    rdx,QWORD PTR [rax+0x58]
    53b1:	mov    QWORD PTR [rsp+0x20],rdx
    53b6:	mov    rsi,r15
    53b9:	call   53be <botlish_fn_55+0x196>
			53ba: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    53be:	test   rax,rax
    53c1:	je     563c <botlish_fn_55+0x414>
    53c7:	mov    QWORD PTR [rsp+0x20],rax
    53cc:	mov    rbx,rax
    53cf:	mov    rdi,r13
    53d2:	mov    rax,QWORD PTR [rdi+0x10]
    53d6:	mov    rdx,QWORD PTR [rax+0x58]
    53da:	mov    QWORD PTR [rsp+0x28],rdx
    53df:	mov    rsi,QWORD PTR [rsp+0x78]
    53e4:	call   53e9 <botlish_fn_55+0x1c1>
			53e5: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    53e9:	test   rax,rax
    53ec:	je     563c <botlish_fn_55+0x414>
    53f2:	mov    rcx,rbx
    53f5:	mov    rdx,rcx
    53f8:	and    rdx,rax
    53fb:	test   rdx,0x1
    5402:	jne    5424 <botlish_fn_55+0x1fc>
    5408:	mov    rdx,rax
    540b:	mov    rsi,rbx
    540e:	mov    rdi,r13
    5411:	call   5416 <botlish_fn_55+0x1ee>
			5412: R_X86_64_PLT32	rt_value_eq-0x4
    5416:	test   rax,rax
    5419:	je     563c <botlish_fn_55+0x414>
    541f:	jmp    543a <botlish_fn_55+0x212>
    5424:	mov    rdx,rax
    5427:	mov    rsi,rbx
    542a:	mov    eax,0x2
    542f:	cmp    rsi,rdx
    5432:	cmove  rax,QWORD PTR [rip+0x26e]        # 56a8 <botlish_fn_55+0x480>
    543a:	mov    ebx,0x6
    543f:	cmp    rax,0x6
    5443:	je     545e <botlish_fn_55+0x236>
    5449:	mov    ebx,0x2
    544e:	mov    QWORD PTR [rsp],0x2
    5456:	mov    rsi,r12
    5459:	jmp    54fd <botlish_fn_55+0x2d5>
    545e:	mov    rsi,r15
    5461:	mov    rdi,r13
    5464:	call   5469 <botlish_fn_55+0x241>
			5465: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5469:	test   rax,rax
    546c:	mov    QWORD PTR [rsp+0x88],rax
    5474:	je     563c <botlish_fn_55+0x414>
    547a:	mov    rsi,QWORD PTR [rsp+0x78]
    547f:	mov    rdi,r13
    5482:	call   5487 <botlish_fn_55+0x25f>
			5483: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5487:	test   rax,rax
    548a:	je     563c <botlish_fn_55+0x414>
    5490:	mov    rcx,QWORD PTR [rsp+0x88]
    5498:	mov    rdx,rcx
    549b:	and    rdx,rax
    549e:	test   rdx,0x1
    54a5:	jne    54cc <botlish_fn_55+0x2a4>
    54ab:	mov    rdx,rax
    54ae:	mov    rsi,QWORD PTR [rsp+0x88]
    54b6:	mov    rdi,r13
    54b9:	call   54be <botlish_fn_55+0x296>
			54ba: R_X86_64_PLT32	rt_value_eq-0x4
    54be:	test   rax,rax
    54c1:	je     563c <botlish_fn_55+0x414>
    54c7:	jmp    54e7 <botlish_fn_55+0x2bf>
    54cc:	mov    rdx,rax
    54cf:	mov    rsi,QWORD PTR [rsp+0x88]
    54d7:	mov    eax,0x2
    54dc:	cmp    rsi,rdx
    54df:	cmove  rax,QWORD PTR [rip+0x1c1]        # 56a8 <botlish_fn_55+0x480>
    54e7:	cmp    rax,0x6
    54eb:	je     54f6 <botlish_fn_55+0x2ce>
    54f1:	mov    ebx,0x2
    54f6:	mov    QWORD PTR [rsp],rbx
    54fa:	mov    rsi,r12
    54fd:	mov    rdi,r13
    5500:	call   5505 <botlish_fn_55+0x2dd>
			5501: R_X86_64_PLT32	rt_list_len-0x4
    5505:	mov    QWORD PTR [rsp+0x18],rax
    550a:	mov    rdi,r13
    550d:	mov    r12,rax
    5510:	mov    rax,QWORD PTR [rdi+0x10]
    5514:	mov    rdx,QWORD PTR [rax+0x58]
    5518:	mov    QWORD PTR [rsp+0x20],rdx
    551d:	mov    rsi,r15
    5520:	call   5525 <botlish_fn_55+0x2fd>
			5521: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5525:	test   rax,rax
    5528:	je     563c <botlish_fn_55+0x414>
    552e:	mov    QWORD PTR [rsp+0x20],rax
    5533:	mov    rdi,r13
    5536:	mov    QWORD PTR [rsp+0x88],rax
    553e:	mov    rax,QWORD PTR [rdi+0x10]
    5542:	mov    rdx,QWORD PTR [rax+0x60]
    5546:	mov    QWORD PTR [rsp+0x28],rdx
    554b:	mov    rsi,r15
    554e:	call   5553 <botlish_fn_55+0x32b>
			554f: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5553:	test   rax,rax
    5556:	je     563c <botlish_fn_55+0x414>
    555c:	mov    QWORD PTR [rsp+0x28],rax
    5561:	mov    rdi,r13
    5564:	mov    QWORD PTR [rsp+0x80],rax
    556c:	mov    rax,QWORD PTR [rdi+0x10]
    5570:	mov    rdx,QWORD PTR [rax+0x68]
    5574:	mov    QWORD PTR [rsp+0x30],rdx
    5579:	mov    rsi,r15
    557c:	call   5581 <botlish_fn_55+0x359>
			557d: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5581:	test   rax,rax
    5584:	je     563c <botlish_fn_55+0x414>
    558a:	mov    QWORD PTR [rsp+0x8],rax
    558f:	mov    rdi,r13
    5592:	mov    r15,rax
    5595:	mov    rax,QWORD PTR [rdi+0x10]
    5599:	mov    rdx,QWORD PTR [rax+0x58]
    559d:	mov    QWORD PTR [rsp+0x30],rdx
    55a2:	mov    rsi,r14
    55a5:	call   55aa <botlish_fn_55+0x382>
			55a6: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    55aa:	test   rax,rax
    55ad:	je     563c <botlish_fn_55+0x414>
    55b3:	mov    QWORD PTR [rsp+0x30],rax
    55b8:	mov    rdi,r13
    55bb:	mov    QWORD PTR [rsp+0x78],rax
    55c0:	mov    rax,QWORD PTR [rdi+0x10]
    55c4:	mov    rdx,QWORD PTR [rax+0x68]
    55c8:	mov    QWORD PTR [rsp+0x38],rdx
    55cd:	mov    rsi,r14
    55d0:	call   55d5 <botlish_fn_55+0x3ad>
			55d1: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    55d5:	test   rax,rax
    55d8:	je     563c <botlish_fn_55+0x414>
    55de:	mov    QWORD PTR [rsp+0x10],rax
    55e3:	lea    rdx,[rsp+0x40]
    55e8:	mov    r9,r12
    55eb:	mov    QWORD PTR [rsp+0x40],r9
    55f0:	mov    rcx,QWORD PTR [rsp+0x88]
    55f8:	mov    QWORD PTR [rsp+0x48],rcx
    55fd:	mov    rcx,QWORD PTR [rsp+0x80]
    5605:	mov    QWORD PTR [rsp+0x50],rcx
    560a:	mov    rcx,r15
    560d:	mov    QWORD PTR [rsp+0x58],rcx
    5612:	mov    rcx,QWORD PTR [rsp+0x78]
    5617:	mov    QWORD PTR [rsp+0x60],rcx
    561c:	mov    QWORD PTR [rsp+0x68],rax
    5621:	mov    QWORD PTR [rsp+0x70],rbx
    5626:	mov    esi,0x7
    562b:	mov    rdi,r13
    562e:	call   5633 <botlish_fn_55+0x40b>
			562f: R_X86_64_PLT32	rt_list_new-0x4
    5633:	test   rax,rax
    5636:	jne    5673 <botlish_fn_55+0x44b>
    563c:	xor    rax,rax
    563f:	mov    rbx,QWORD PTR [rsp+0x90]
    5647:	mov    r12,QWORD PTR [rsp+0x98]
    564f:	mov    r13,QWORD PTR [rsp+0xa0]
    5657:	mov    r14,QWORD PTR [rsp+0xa8]
    565f:	mov    r15,QWORD PTR [rsp+0xb0]
    5667:	add    rsp,0xc0
    566e:	mov    rsp,rbp
    5671:	pop    rbp
    5672:	ret
    5673:	mov    rbx,QWORD PTR [rsp+0x90]
    567b:	mov    r12,QWORD PTR [rsp+0x98]
    5683:	mov    r13,QWORD PTR [rsp+0xa0]
    568b:	mov    r14,QWORD PTR [rsp+0xa8]
    5693:	mov    r15,QWORD PTR [rsp+0xb0]
    569b:	add    rsp,0xc0
    56a2:	mov    rsp,rbp
    56a5:	pop    rbp
    56a6:	ret
    56a7:	add    BYTE PTR [rsi],al
    56a9:	add    BYTE PTR [rax],al
    56ab:	add    BYTE PTR [rax],al
    56ad:	add    BYTE PTR [rax],al
	...

00000000000056b0 <botlish_entry_55: sample<generic>>:
    56b0:	push   rbp
    56b1:	mov    rbp,rsp
    56b4:	call   56b9 <botlish_entry_55+0x9>
			56b5: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample<generic>
    56b9:	mov    rsp,rbp
    56bc:	pop    rbp
    56bd:	ret

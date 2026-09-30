; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23391  (per function: 45 461 461 461 81 81 81 357 412 412 412 278 278 278 81 365 430 664 1122 364 961 239 520 337 388 524 70 493 114 61 61 61 61 61 168 179 245 804 1248 429 380 401 724 807 817 665 1168 836 107 427 270 629 634 78 78 1222)
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
    128a:	sub    rsp,0x90
    1291:	mov    QWORD PTR [rsp+0x60],rbx
    1296:	mov    QWORD PTR [rsp+0x68],r12
    129b:	mov    QWORD PTR [rsp+0x70],r13
    12a0:	mov    QWORD PTR [rsp+0x78],r14
    12a5:	mov    QWORD PTR [rsp+0x80],r15
    12ad:	mov    r14,rdi
    12b0:	mov    QWORD PTR [rsp+0x18],0x0
    12b9:	mov    QWORD PTR [rsp],rsi
    12bd:	mov    QWORD PTR [rsp+0x40],rsi
    12c2:	mov    QWORD PTR [rsp+0x8],rdx
    12c7:	mov    r15,rdx
    12ca:	mov    QWORD PTR [rsp+0x10],rcx
    12cf:	lea    r13,[rsp+0x20]
    12d4:	mov    QWORD PTR [rsp+0x48],rcx
    12d9:	mov    rcx,r13
    12dc:	mov    rdx,QWORD PTR [rsp+0x48]
    12e1:	mov    rsi,QWORD PTR [rsp+0x40]
    12e6:	mov    rdi,r14
    12e9:	call   12ee <botlish_fn_17+0x68>
			12ea: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    12ee:	mov    r10,rax
    12f1:	mov    QWORD PTR [rsp+0x50],rax
    12f6:	test   rax,r10
    12f9:	je     145b <botlish_fn_17+0x1d5>
    12ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1304:	mov    r12,QWORD PTR [rsp+0x28]
    1309:	mov    rdi,r14
    130c:	mov    rcx,QWORD PTR [rdi+0x10]
    1310:	mov    r8,QWORD PTR [rcx+0x8]
    1314:	mov    rcx,r12
    1317:	mov    rdx,rbx
    131a:	mov    rsi,QWORD PTR [rsp+0x50]
    131f:	call   1324 <botlish_fn_17+0x9e>
			1320: R_X86_64_PLT32	rt_str_region_eq-0x4
    1324:	cmp    rax,0x6
    1328:	je     1367 <botlish_fn_17+0xe1>
    132e:	mov    rdi,r14
    1331:	mov    rax,QWORD PTR [rdi+0x10]
    1335:	mov    r8,QWORD PTR [rax+0x10]
    1339:	mov    rcx,r12
    133c:	mov    rdx,rbx
    133f:	mov    rsi,QWORD PTR [rsp+0x50]
    1344:	call   1349 <botlish_fn_17+0xc3>
			1345: R_X86_64_PLT32	rt_str_region_eq-0x4
    1349:	cmp    rax,0x6
    134d:	je     135d <botlish_fn_17+0xd7>
    1353:	mov    eax,0x2
    1358:	jmp    136c <botlish_fn_17+0xe6>
    135d:	mov    eax,0x6
    1362:	jmp    136c <botlish_fn_17+0xe6>
    1367:	mov    eax,0x6
    136c:	cmp    rax,0x6
    1370:	je     13af <botlish_fn_17+0x129>
    1376:	mov    rdi,r14
    1379:	mov    rax,QWORD PTR [rdi+0x10]
    137d:	mov    r8,QWORD PTR [rax+0x18]
    1381:	mov    rcx,r12
    1384:	mov    rdx,rbx
    1387:	mov    rsi,QWORD PTR [rsp+0x50]
    138c:	call   1391 <botlish_fn_17+0x10b>
			138d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1391:	cmp    rax,0x6
    1395:	je     13a5 <botlish_fn_17+0x11f>
    139b:	mov    eax,0x2
    13a0:	jmp    13b4 <botlish_fn_17+0x12e>
    13a5:	mov    eax,0x6
    13aa:	jmp    13b4 <botlish_fn_17+0x12e>
    13af:	mov    eax,0x6
    13b4:	cmp    rax,0x6
    13b8:	je     143d <botlish_fn_17+0x1b7>
    13be:	mov    QWORD PTR [rsp+0x18],0x3
    13c7:	mov    rsi,QWORD PTR [rsp+0x48]
    13cc:	test   rsi,0x1
    13d3:	je     1401 <botlish_fn_17+0x17b>
    13d9:	mov    rsi,QWORD PTR [rsp+0x48]
    13de:	mov    rdi,rsi
    13e1:	add    rdi,0x2
    13e5:	seto   r9b
    13e9:	test   r9b,r9b
    13ec:	jne    1401 <botlish_fn_17+0x17b>
    13f2:	mov    rsi,QWORD PTR [rsp+0x40]
    13f7:	mov    QWORD PTR [rsp+0x48],rdi
    13fc:	jmp    141d <botlish_fn_17+0x197>
    1401:	mov    edx,0x3
    1406:	mov    rsi,QWORD PTR [rsp+0x48]
    140b:	mov    rdi,r14
    140e:	call   1413 <botlish_fn_17+0x18d>
			140f: R_X86_64_PLT32	rt_int_add-0x4
    1413:	mov    rsi,QWORD PTR [rsp+0x40]
    1418:	mov    QWORD PTR [rsp+0x48],rax
    141d:	mov    QWORD PTR [rsp],rsi
    1421:	mov    rdx,r15
    1424:	mov    QWORD PTR [rsp+0x8],rdx
    1429:	mov    rax,QWORD PTR [rsp+0x48]
    142e:	mov    QWORD PTR [rsp+0x10],rax
    1433:	mov    QWORD PTR [rsp+0x40],rsi
    1438:	jmp    12d9 <botlish_fn_17+0x53>
    143d:	mov    rdx,r15
    1440:	mov    rsi,QWORD PTR [rsp+0x40]
    1445:	mov    rcx,QWORD PTR [rsp+0x48]
    144a:	mov    rdi,r14
    144d:	call   1452 <botlish_fn_17+0x1cc>
			144e: R_X86_64_PLT32	rt_substr-0x4
    1452:	test   rax,rax
    1455:	jne    1486 <botlish_fn_17+0x200>
    145b:	xor    rax,rax
    145e:	mov    rbx,QWORD PTR [rsp+0x60]
    1463:	mov    r12,QWORD PTR [rsp+0x68]
    1468:	mov    r13,QWORD PTR [rsp+0x70]
    146d:	mov    r14,QWORD PTR [rsp+0x78]
    1472:	mov    r15,QWORD PTR [rsp+0x80]
    147a:	add    rsp,0x90
    1481:	mov    rsp,rbp
    1484:	pop    rbp
    1485:	ret
    1486:	mov    QWORD PTR [rsp],rax
    148a:	lea    rcx,[rsp+0x30]
    148f:	mov    QWORD PTR [rsp+0x30],rax
    1494:	mov    rsi,QWORD PTR [rsp+0x48]
    1499:	mov    QWORD PTR [rsp+0x38],rsi
    149e:	mov    esi,0x1
    14a3:	mov    edx,0x2
    14a8:	mov    rdi,r14
    14ab:	call   14b0 <botlish_fn_17+0x22a>
			14ac: R_X86_64_PLT32	rt_struct_new-0x4
    14b0:	mov    rbx,QWORD PTR [rsp+0x60]
    14b5:	mov    r12,QWORD PTR [rsp+0x68]
    14ba:	mov    r13,QWORD PTR [rsp+0x70]
    14bf:	mov    r14,QWORD PTR [rsp+0x78]
    14c4:	mov    r15,QWORD PTR [rsp+0x80]
    14cc:	add    rsp,0x90
    14d3:	mov    rsp,rbp
    14d6:	pop    rbp
    14d7:	ret

00000000000014d8 <botlish_entry_17: scan_unquoted<str, int, int>>:
    14d8:	push   rbp
    14d9:	mov    rbp,rsp
    14dc:	mov    rsi,QWORD PTR [rdx]
    14df:	mov    r8,QWORD PTR [rdx+0x8]
    14e3:	mov    rcx,QWORD PTR [rdx+0x10]
    14e7:	mov    rdx,r8
    14ea:	call   14ef <botlish_entry_17+0x17>
			14eb: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    14ef:	mov    rsp,rbp
    14f2:	pop    rbp
    14f3:	ret

00000000000014f4 <botlish_fn_18: scan_quoted<str, int, str>>:
    14f4:	push   rbp
    14f5:	mov    rbp,rsp
    14f8:	sub    rsp,0xe0
    14ff:	mov    QWORD PTR [rsp+0xb0],rbx
    1507:	mov    QWORD PTR [rsp+0xb8],r12
    150f:	mov    QWORD PTR [rsp+0xc0],r13
    1517:	mov    QWORD PTR [rsp+0xc8],r14
    151f:	mov    QWORD PTR [rsp+0xd0],r15
    1527:	mov    r14,rdi
    152a:	mov    QWORD PTR [rsp+0x18],0x0
    1533:	mov    QWORD PTR [rsp+0x20],0x0
    153c:	mov    QWORD PTR [rsp],rsi
    1540:	mov    QWORD PTR [rsp+0x8],rdx
    1545:	mov    QWORD PTR [rsp+0x10],rcx
    154a:	mov    r12,rcx
    154d:	lea    r13,[rsp+0x78]
    1552:	lea    rbx,[rsp+0x28]
    1557:	mov    r15,rsi
    155a:	mov    QWORD PTR [rsp+0x98],rdx
    1562:	mov    rdx,QWORD PTR [rsp+0x98]
    156a:	mov    rsi,r15
    156d:	mov    rdi,r14
    1570:	call   1575 <botlish_fn_18+0x81>
			1571: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    1575:	test   rax,rax
    1578:	je     189a <botlish_fn_18+0x3a6>
    157e:	mov    QWORD PTR [rsp+0x18],rax
    1583:	mov    rdi,r14
    1586:	mov    QWORD PTR [rsp+0xa0],rax
    158e:	mov    rdi,QWORD PTR [rdi+0x10]
    1592:	mov    rsi,QWORD PTR [rdi+0x20]
    1596:	mov    edx,0x1
    159b:	mov    ecx,0x3
    15a0:	mov    rdi,r14
    15a3:	mov    r8,QWORD PTR [rsp+0xa0]
    15ab:	call   15b0 <botlish_fn_18+0xbc>
			15ac: R_X86_64_PLT32	rt_str_region_eq-0x4
    15b0:	cmp    rax,0x6
    15b4:	je     1678 <botlish_fn_18+0x184>
    15ba:	mov    QWORD PTR [rsp+0x20],0x3
    15c3:	mov    rsi,QWORD PTR [rsp+0x98]
    15cb:	test   rsi,0x1
    15d2:	je     15f2 <botlish_fn_18+0xfe>
    15d8:	mov    rcx,rsi
    15db:	add    rcx,0x2
    15df:	seto   al
    15e2:	test   al,al
    15e4:	jne    15f2 <botlish_fn_18+0xfe>
    15ea:	mov    rsi,rcx
    15ed:	jmp    1602 <botlish_fn_18+0x10e>
    15f2:	mov    edx,0x3
    15f7:	mov    rdi,r14
    15fa:	call   15ff <botlish_fn_18+0x10b>
			15fb: R_X86_64_PLT32	rt_int_add-0x4
    15ff:	mov    rsi,rax
    1602:	mov    QWORD PTR [rsp+0x8],rsi
    1607:	mov    QWORD PTR [rsp+0x98],rsi
    160f:	mov    QWORD PTR [rsp+0x78],0x0
    1618:	mov    QWORD PTR [rsp+0x80],r12
    1620:	mov    QWORD PTR [rsp+0x88],0x0
    162c:	mov    rax,QWORD PTR [rsp+0xa0]
    1634:	mov    QWORD PTR [rsp+0x90],rax
    163c:	mov    esi,0x2
    1641:	mov    edx,0x4
    1646:	mov    rcx,r13
    1649:	mov    rdi,r14
    164c:	call   1651 <botlish_fn_18+0x15d>
			164d: R_X86_64_PLT32	rt_construct-0x4
    1651:	test   rax,rax
    1654:	je     189a <botlish_fn_18+0x3a6>
    165a:	mov    QWORD PTR [rsp],r15
    165e:	mov    rsi,QWORD PTR [rsp+0x98]
    1666:	mov    QWORD PTR [rsp+0x8],rsi
    166b:	mov    QWORD PTR [rsp+0x10],rax
    1670:	mov    r12,rax
    1673:	jmp    1562 <botlish_fn_18+0x6e>
    1678:	mov    QWORD PTR [rsp+0x18],0x3
    1681:	mov    rsi,QWORD PTR [rsp+0x98]
    1689:	test   rsi,0x1
    1690:	je     16b0 <botlish_fn_18+0x1bc>
    1696:	mov    rsi,QWORD PTR [rsp+0x98]
    169e:	mov    rdx,rsi
    16a1:	add    rdx,0x2
    16a5:	seto   al
    16a8:	test   al,al
    16aa:	je     16c8 <botlish_fn_18+0x1d4>
    16b0:	mov    edx,0x3
    16b5:	mov    rsi,QWORD PTR [rsp+0x98]
    16bd:	mov    rdi,r14
    16c0:	call   16c5 <botlish_fn_18+0x1d1>
			16c1: R_X86_64_PLT32	rt_int_add-0x4
    16c5:	mov    rdx,rax
    16c8:	mov    QWORD PTR [rsp+0x18],rdx
    16cd:	mov    rcx,rbx
    16d0:	mov    rsi,r15
    16d3:	mov    rdi,r14
    16d6:	call   16db <botlish_fn_18+0x1e7>
			16d7: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    16db:	test   rax,rax
    16de:	mov    rsi,rax
    16e1:	je     189a <botlish_fn_18+0x3a6>
    16e7:	mov    rdx,QWORD PTR [rsp+0x28]
    16ec:	mov    rcx,QWORD PTR [rsp+0x30]
    16f1:	mov    rdi,r14
    16f4:	mov    rax,QWORD PTR [rdi+0x10]
    16f8:	mov    r8,QWORD PTR [rax+0x20]
    16fc:	call   1701 <botlish_fn_18+0x20d>
			16fd: R_X86_64_PLT32	rt_str_region_eq-0x4
    1701:	cmp    rax,0x6
    1705:	je     17e8 <botlish_fn_18+0x2f4>
    170b:	xor    rsi,rsi
    170e:	lea    rcx,[rsp+0x58]
    1713:	mov    QWORD PTR [rsp+0x58],0x0
    171c:	mov    QWORD PTR [rsp+0x60],r12
    1721:	mov    edx,0x2
    1726:	mov    rdi,r14
    1729:	call   172e <botlish_fn_18+0x23a>
			172a: R_X86_64_PLT32	rt_construct-0x4
    172e:	test   rax,rax
    1731:	je     189a <botlish_fn_18+0x3a6>
    1737:	mov    QWORD PTR [rsp],rax
    173b:	mov    rbx,rax
    173e:	mov    QWORD PTR [rsp+0x10],0x3
    1747:	mov    rsi,QWORD PTR [rsp+0x98]
    174f:	test   rsi,0x1
    1756:	je     1776 <botlish_fn_18+0x282>
    175c:	mov    rsi,QWORD PTR [rsp+0x98]
    1764:	mov    rax,rsi
    1767:	add    rax,0x2
    176b:	seto   cl
    176e:	test   cl,cl
    1770:	je     178b <botlish_fn_18+0x297>
    1776:	mov    edx,0x3
    177b:	mov    rsi,QWORD PTR [rsp+0x98]
    1783:	mov    rdi,r14
    1786:	call   178b <botlish_fn_18+0x297>
			1787: R_X86_64_PLT32	rt_int_add-0x4
    178b:	mov    QWORD PTR [rsp+0x8],rax
    1790:	lea    rcx,[rsp+0x68]
    1795:	mov    rdx,rbx
    1798:	mov    QWORD PTR [rsp+0x68],rdx
    179d:	mov    QWORD PTR [rsp+0x70],rax
    17a2:	mov    esi,0x1
    17a7:	mov    edx,0x2
    17ac:	mov    rdi,r14
    17af:	call   17b4 <botlish_fn_18+0x2c0>
			17b0: R_X86_64_PLT32	rt_struct_new-0x4
    17b4:	mov    rbx,QWORD PTR [rsp+0xb0]
    17bc:	mov    r12,QWORD PTR [rsp+0xb8]
    17c4:	mov    r13,QWORD PTR [rsp+0xc0]
    17cc:	mov    r14,QWORD PTR [rsp+0xc8]
    17d4:	mov    r15,QWORD PTR [rsp+0xd0]
    17dc:	add    rsp,0xe0
    17e3:	mov    rsp,rbp
    17e6:	pop    rbp
    17e7:	ret
    17e8:	mov    QWORD PTR [rsp+0x18],0x5
    17f1:	mov    rsi,QWORD PTR [rsp+0x98]
    17f9:	test   rsi,0x1
    1800:	je     182c <botlish_fn_18+0x338>
    1806:	mov    rsi,QWORD PTR [rsp+0x98]
    180e:	add    rsi,0x4
    1812:	seto   r8b
    1816:	test   r8b,r8b
    1819:	jne    182c <botlish_fn_18+0x338>
    181f:	mov    QWORD PTR [rsp+0x98],rsi
    1827:	jmp    184c <botlish_fn_18+0x358>
    182c:	mov    edx,0x5
    1831:	mov    rsi,QWORD PTR [rsp+0x98]
    1839:	mov    rdi,r14
    183c:	call   1841 <botlish_fn_18+0x34d>
			183d: R_X86_64_PLT32	rt_int_add-0x4
    1841:	mov    rsi,rax
    1844:	mov    QWORD PTR [rsp+0x98],rax
    184c:	mov    QWORD PTR [rsp+0x8],rsi
    1851:	mov    rdi,r14
    1854:	mov    rax,QWORD PTR [rdi+0x10]
    1858:	mov    rax,QWORD PTR [rax+0x20]
    185c:	mov    QWORD PTR [rsp+0x18],rax
    1861:	lea    rcx,[rsp+0x38]
    1866:	mov    QWORD PTR [rsp+0x38],0x0
    186f:	mov    QWORD PTR [rsp+0x40],r12
    1874:	mov    QWORD PTR [rsp+0x48],0x0
    187d:	mov    QWORD PTR [rsp+0x50],rax
    1882:	mov    esi,0x2
    1887:	mov    edx,0x4
    188c:	call   1891 <botlish_fn_18+0x39d>
			188d: R_X86_64_PLT32	rt_construct-0x4
    1891:	test   rax,rax
    1894:	jne    18d1 <botlish_fn_18+0x3dd>
    189a:	xor    rax,rax
    189d:	mov    rbx,QWORD PTR [rsp+0xb0]
    18a5:	mov    r12,QWORD PTR [rsp+0xb8]
    18ad:	mov    r13,QWORD PTR [rsp+0xc0]
    18b5:	mov    r14,QWORD PTR [rsp+0xc8]
    18bd:	mov    r15,QWORD PTR [rsp+0xd0]
    18c5:	add    rsp,0xe0
    18cc:	mov    rsp,rbp
    18cf:	pop    rbp
    18d0:	ret
    18d1:	mov    QWORD PTR [rsp],r15
    18d5:	mov    rsi,QWORD PTR [rsp+0x98]
    18dd:	mov    QWORD PTR [rsp+0x8],rsi
    18e2:	mov    QWORD PTR [rsp+0x10],rax
    18e7:	mov    r12,rax
    18ea:	jmp    1562 <botlish_fn_18+0x6e>

00000000000018ef <botlish_entry_18: scan_quoted<str, int, str>>:
    18ef:	push   rbp
    18f0:	mov    rbp,rsp
    18f3:	mov    rsi,QWORD PTR [rdx]
    18f6:	mov    r8,QWORD PTR [rdx+0x8]
    18fa:	mov    rcx,QWORD PTR [rdx+0x10]
    18fe:	mov    rdx,r8
    1901:	call   1906 <botlish_entry_18+0x17>
			1902: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    1906:	mov    rsp,rbp
    1909:	pop    rbp
    190a:	ret

000000000000190b <botlish_fn_19: scan_field<str, int>>:
    190b:	push   rbp
    190c:	mov    rbp,rsp
    190f:	sub    rsp,0x50
    1913:	mov    QWORD PTR [rsp+0x30],rbx
    1918:	mov    QWORD PTR [rsp+0x38],r12
    191d:	mov    QWORD PTR [rsp+0x40],r13
    1922:	mov    r12,rdi
    1925:	mov    r13,rdx
    1928:	mov    QWORD PTR [rsp+0x10],0x0
    1931:	mov    QWORD PTR [rsp],rsi
    1935:	mov    rbx,rsi
    1938:	mov    QWORD PTR [rsp+0x8],rdx
    193d:	lea    rcx,[rsp+0x18]
    1942:	mov    rdx,r13
    1945:	mov    rsi,rbx
    1948:	mov    rdi,r12
    194b:	call   1950 <botlish_fn_19+0x45>
			194c: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1950:	test   rax,rax
    1953:	mov    rsi,rax
    1956:	je     1a21 <botlish_fn_19+0x116>
    195c:	mov    rdx,QWORD PTR [rsp+0x18]
    1961:	mov    rcx,QWORD PTR [rsp+0x20]
    1966:	mov    rdi,r12
    1969:	mov    rax,QWORD PTR [rdi+0x10]
    196d:	mov    r8,QWORD PTR [rax+0x20]
    1971:	call   1976 <botlish_fn_19+0x6b>
			1972: R_X86_64_PLT32	rt_str_region_eq-0x4
    1976:	cmp    rax,0x6
    197a:	je     19b2 <botlish_fn_19+0xa7>
    1980:	mov    rcx,r13
    1983:	mov    rsi,rbx
    1986:	mov    rdi,r12
    1989:	mov    rdx,rcx
    198c:	call   1991 <botlish_fn_19+0x86>
			198d: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    1991:	test   rax,rax
    1994:	je     1a21 <botlish_fn_19+0x116>
    199a:	mov    rbx,QWORD PTR [rsp+0x30]
    199f:	mov    r12,QWORD PTR [rsp+0x38]
    19a4:	mov    r13,QWORD PTR [rsp+0x40]
    19a9:	add    rsp,0x50
    19ad:	mov    rsp,rbp
    19b0:	pop    rbp
    19b1:	ret
    19b2:	mov    rcx,r13
    19b5:	mov    QWORD PTR [rsp+0x10],0x3
    19be:	test   rcx,0x1
    19c5:	jne    19d3 <botlish_fn_19+0xc8>
    19cb:	mov    r13,rcx
    19ce:	jmp    19e8 <botlish_fn_19+0xdd>
    19d3:	mov    rdx,rcx
    19d6:	add    rdx,0x2
    19da:	mov    r13,rcx
    19dd:	seto   al
    19e0:	test   al,al
    19e2:	je     19fb <botlish_fn_19+0xf0>
    19e8:	mov    edx,0x3
    19ed:	mov    rsi,r13
    19f0:	mov    rdi,r12
    19f3:	call   19f8 <botlish_fn_19+0xed>
			19f4: R_X86_64_PLT32	rt_int_add-0x4
    19f8:	mov    rdx,rax
    19fb:	mov    QWORD PTR [rsp+0x8],rdx
    1a00:	mov    rdi,r12
    1a03:	mov    rax,QWORD PTR [rdi+0x10]
    1a07:	mov    rcx,QWORD PTR [rax+0x8]
    1a0b:	mov    QWORD PTR [rsp+0x10],rcx
    1a10:	mov    rsi,rbx
    1a13:	call   1a18 <botlish_fn_19+0x10d>
			1a14: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    1a18:	test   rax,rax
    1a1b:	jne    1a3c <botlish_fn_19+0x131>
    1a21:	xor    rax,rax
    1a24:	mov    rbx,QWORD PTR [rsp+0x30]
    1a29:	mov    r12,QWORD PTR [rsp+0x38]
    1a2e:	mov    r13,QWORD PTR [rsp+0x40]
    1a33:	add    rsp,0x50
    1a37:	mov    rsp,rbp
    1a3a:	pop    rbp
    1a3b:	ret
    1a3c:	mov    rbx,QWORD PTR [rsp+0x30]
    1a41:	mov    r12,QWORD PTR [rsp+0x38]
    1a46:	mov    r13,QWORD PTR [rsp+0x40]
    1a4b:	add    rsp,0x50
    1a4f:	mov    rsp,rbp
    1a52:	pop    rbp
    1a53:	ret

0000000000001a54 <botlish_entry_19: scan_field<str, int>>:
    1a54:	push   rbp
    1a55:	mov    rbp,rsp
    1a58:	mov    rsi,QWORD PTR [rdx]
    1a5b:	mov    rdx,QWORD PTR [rdx+0x8]
    1a5f:	call   1a64 <botlish_entry_19+0x10>
			1a60: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1a64:	mov    rsp,rbp
    1a67:	pop    rbp
    1a68:	ret

0000000000001a69 <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    1a69:	push   rbp
    1a6a:	mov    rbp,rsp
    1a6d:	sub    rsp,0xb0
    1a74:	mov    QWORD PTR [rsp+0x80],rbx
    1a7c:	mov    QWORD PTR [rsp+0x88],r12
    1a84:	mov    QWORD PTR [rsp+0x90],r13
    1a8c:	mov    QWORD PTR [rsp+0x98],r14
    1a94:	mov    QWORD PTR [rsp+0xa0],r15
    1a9c:	mov    r15,rdi
    1a9f:	mov    QWORD PTR [rsp+0x20],0x0
    1aa8:	mov    QWORD PTR [rsp],rsi
    1aac:	mov    QWORD PTR [rsp+0x8],rdx
    1ab1:	mov    QWORD PTR [rsp+0x10],rcx
    1ab6:	mov    QWORD PTR [rsp+0x18],r8
    1abb:	lea    rbx,[rsp+0x28]
    1ac0:	mov    r12,rsi
    1ac3:	mov    QWORD PTR [rsp+0x58],rdx
    1ac8:	mov    QWORD PTR [rsp+0x60],rcx
    1acd:	mov    QWORD PTR [rsp+0x68],r8
    1ad2:	mov    rcx,rbx
    1ad5:	mov    rdx,QWORD PTR [rsp+0x58]
    1ada:	mov    rsi,r12
    1add:	mov    rdi,r15
    1ae0:	call   1ae5 <botlish_fn_20+0x7c>
			1ae1: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1ae5:	test   rax,rax
    1ae8:	mov    QWORD PTR [rsp+0x70],rax
    1aed:	je     1d1e <botlish_fn_20+0x2b5>
    1af3:	mov    r14,QWORD PTR [rsp+0x28]
    1af8:	mov    r13,QWORD PTR [rsp+0x30]
    1afd:	mov    rdi,r15
    1b00:	mov    rcx,QWORD PTR [rdi+0x10]
    1b04:	mov    r8,QWORD PTR [rcx+0x10]
    1b08:	mov    rcx,r13
    1b0b:	mov    rdx,r14
    1b0e:	mov    rsi,QWORD PTR [rsp+0x70]
    1b13:	call   1b18 <botlish_fn_20+0xaf>
			1b14: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b18:	cmp    rax,0x6
    1b1c:	je     1c7f <botlish_fn_20+0x216>
    1b22:	mov    rdi,r15
    1b25:	mov    rcx,QWORD PTR [rdi+0x10]
    1b29:	mov    r8,QWORD PTR [rcx+0x18]
    1b2d:	mov    rcx,r13
    1b30:	mov    rdx,r14
    1b33:	mov    rsi,QWORD PTR [rsp+0x70]
    1b38:	call   1b3d <botlish_fn_20+0xd4>
			1b39: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b3d:	cmp    rax,0x6
    1b41:	je     1bbe <botlish_fn_20+0x155>
    1b47:	mov    rdx,QWORD PTR [rsp+0x68]
    1b4c:	mov    rsi,QWORD PTR [rsp+0x60]
    1b51:	mov    rdi,r15
    1b54:	call   1b59 <botlish_fn_20+0xf0>
			1b55: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b59:	test   rax,rax
    1b5c:	je     1d1e <botlish_fn_20+0x2b5>
    1b62:	mov    QWORD PTR [rsp],rax
    1b66:	lea    rcx,[rsp+0x48]
    1b6b:	mov    QWORD PTR [rsp+0x48],rax
    1b70:	mov    rsi,QWORD PTR [rsp+0x58]
    1b75:	mov    QWORD PTR [rsp+0x50],rsi
    1b7a:	xor    rsi,rsi
    1b7d:	mov    edx,0x2
    1b82:	mov    rdi,r15
    1b85:	call   1b8a <botlish_fn_20+0x121>
			1b86: R_X86_64_PLT32	rt_struct_new-0x4
    1b8a:	mov    rbx,QWORD PTR [rsp+0x80]
    1b92:	mov    r12,QWORD PTR [rsp+0x88]
    1b9a:	mov    r13,QWORD PTR [rsp+0x90]
    1ba2:	mov    r14,QWORD PTR [rsp+0x98]
    1baa:	mov    r15,QWORD PTR [rsp+0xa0]
    1bb2:	add    rsp,0xb0
    1bb9:	mov    rsp,rbp
    1bbc:	pop    rbp
    1bbd:	ret
    1bbe:	mov    rdx,QWORD PTR [rsp+0x68]
    1bc3:	mov    rsi,QWORD PTR [rsp+0x60]
    1bc8:	mov    rdi,r15
    1bcb:	call   1bd0 <botlish_fn_20+0x167>
			1bcc: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1bd0:	test   rax,rax
    1bd3:	je     1d1e <botlish_fn_20+0x2b5>
    1bd9:	mov    QWORD PTR [rsp],rax
    1bdd:	mov    rbx,rax
    1be0:	mov    QWORD PTR [rsp+0x10],0x3
    1be9:	mov    rsi,QWORD PTR [rsp+0x58]
    1bee:	test   rsi,0x1
    1bf5:	je     1c12 <botlish_fn_20+0x1a9>
    1bfb:	mov    rsi,QWORD PTR [rsp+0x58]
    1c00:	mov    rax,rsi
    1c03:	add    rax,0x2
    1c07:	seto   cl
    1c0a:	test   cl,cl
    1c0c:	je     1c24 <botlish_fn_20+0x1bb>
    1c12:	mov    edx,0x3
    1c17:	mov    rsi,QWORD PTR [rsp+0x58]
    1c1c:	mov    rdi,r15
    1c1f:	call   1c24 <botlish_fn_20+0x1bb>
			1c20: R_X86_64_PLT32	rt_int_add-0x4
    1c24:	mov    QWORD PTR [rsp+0x8],rax
    1c29:	lea    rcx,[rsp+0x38]
    1c2e:	mov    rdx,rbx
    1c31:	mov    QWORD PTR [rsp+0x38],rdx
    1c36:	mov    QWORD PTR [rsp+0x40],rax
    1c3b:	xor    rsi,rsi
    1c3e:	mov    edx,0x2
    1c43:	mov    rdi,r15
    1c46:	call   1c4b <botlish_fn_20+0x1e2>
			1c47: R_X86_64_PLT32	rt_struct_new-0x4
    1c4b:	mov    rbx,QWORD PTR [rsp+0x80]
    1c53:	mov    r12,QWORD PTR [rsp+0x88]
    1c5b:	mov    r13,QWORD PTR [rsp+0x90]
    1c63:	mov    r14,QWORD PTR [rsp+0x98]
    1c6b:	mov    r15,QWORD PTR [rsp+0xa0]
    1c73:	add    rsp,0xb0
    1c7a:	mov    rsp,rbp
    1c7d:	pop    rbp
    1c7e:	ret
    1c7f:	mov    edx,0x3
    1c84:	mov    r13,rdx
    1c87:	mov    QWORD PTR [rsp+0x20],0x3
    1c90:	mov    rsi,QWORD PTR [rsp+0x58]
    1c95:	test   rsi,0x1
    1c9c:	jne    1cac <botlish_fn_20+0x243>
    1ca2:	mov    rsi,QWORD PTR [rsp+0x58]
    1ca7:	jmp    1cc8 <botlish_fn_20+0x25f>
    1cac:	mov    rsi,QWORD PTR [rsp+0x58]
    1cb1:	mov    rdx,rsi
    1cb4:	add    rdx,0x2
    1cb8:	seto   al
    1cbb:	test   al,al
    1cbd:	je     1cd6 <botlish_fn_20+0x26d>
    1cc3:	mov    rsi,QWORD PTR [rsp+0x58]
    1cc8:	mov    rdx,r13
    1ccb:	mov    rdi,r15
    1cce:	call   1cd3 <botlish_fn_20+0x26a>
			1ccf: R_X86_64_PLT32	rt_int_add-0x4
    1cd3:	mov    rdx,rax
    1cd6:	mov    QWORD PTR [rsp+0x8],rdx
    1cdb:	mov    rsi,r12
    1cde:	mov    rdi,r15
    1ce1:	call   1ce6 <botlish_fn_20+0x27d>
			1ce2: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1ce6:	test   rax,rax
    1ce9:	je     1d1e <botlish_fn_20+0x2b5>
    1cef:	mov    QWORD PTR [rsp+0x8],rax
    1cf4:	mov    rcx,QWORD PTR [rax+0x18]
    1cf8:	mov    r14,rax
    1cfb:	mov    rcx,QWORD PTR [rcx]
    1cfe:	mov    QWORD PTR [rsp+0x20],rcx
    1d03:	mov    rsi,QWORD PTR [rsp+0x60]
    1d08:	mov    rdx,QWORD PTR [rsp+0x68]
    1d0d:	mov    rdi,r15
    1d10:	call   1d15 <botlish_fn_20+0x2ac>
			1d11: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1d15:	test   rax,rax
    1d18:	jne    1d55 <botlish_fn_20+0x2ec>
    1d1e:	xor    rax,rax
    1d21:	mov    rbx,QWORD PTR [rsp+0x80]
    1d29:	mov    r12,QWORD PTR [rsp+0x88]
    1d31:	mov    r13,QWORD PTR [rsp+0x90]
    1d39:	mov    r14,QWORD PTR [rsp+0x98]
    1d41:	mov    r15,QWORD PTR [rsp+0xa0]
    1d49:	add    rsp,0xb0
    1d50:	mov    rsp,rbp
    1d53:	pop    rbp
    1d54:	ret
    1d55:	mov    QWORD PTR [rsp+0x8],rax
    1d5a:	mov    rcx,rax
    1d5d:	mov    rax,r14
    1d60:	mov    r14,rcx
    1d63:	mov    rax,QWORD PTR [rax+0x18]
    1d67:	mov    rsi,QWORD PTR [rax+0x8]
    1d6b:	mov    QWORD PTR [rsp+0x58],rsi
    1d70:	mov    QWORD PTR [rsp+0x10],rsi
    1d75:	mov    QWORD PTR [rsp+0x20],0x3
    1d7e:	mov    rdx,QWORD PTR [rsp+0x68]
    1d83:	test   rdx,0x1
    1d8a:	jne    1d9d <botlish_fn_20+0x334>
    1d90:	mov    rdx,r13
    1d93:	mov    rsi,QWORD PTR [rsp+0x68]
    1d98:	jmp    1dbc <botlish_fn_20+0x353>
    1d9d:	mov    rdx,QWORD PTR [rsp+0x68]
    1da2:	mov    rax,rdx
    1da5:	add    rax,0x2
    1da9:	seto   cl
    1dac:	test   cl,cl
    1dae:	je     1dc4 <botlish_fn_20+0x35b>
    1db4:	mov    rdx,r13
    1db7:	mov    rsi,QWORD PTR [rsp+0x68]
    1dbc:	mov    rdi,r15
    1dbf:	call   1dc4 <botlish_fn_20+0x35b>
			1dc0: R_X86_64_PLT32	rt_int_add-0x4
    1dc4:	mov    QWORD PTR [rsp],r12
    1dc8:	mov    rsi,QWORD PTR [rsp+0x58]
    1dcd:	mov    QWORD PTR [rsp+0x8],rsi
    1dd2:	mov    rcx,r14
    1dd5:	mov    QWORD PTR [rsp+0x10],rcx
    1dda:	mov    QWORD PTR [rsp+0x18],rax
    1ddf:	mov    QWORD PTR [rsp+0x60],rcx
    1de4:	mov    QWORD PTR [rsp+0x68],rax
    1de9:	jmp    1ad2 <botlish_fn_20+0x69>

0000000000001dee <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1dee:	push   rbp
    1def:	mov    rbp,rsp
    1df2:	mov    rsi,QWORD PTR [rdx]
    1df5:	mov    r9,QWORD PTR [rdx+0x8]
    1df9:	mov    rcx,QWORD PTR [rdx+0x10]
    1dfd:	mov    r8,QWORD PTR [rdx+0x18]
    1e01:	mov    rdx,r9
    1e04:	call   1e09 <botlish_entry_20+0x1b>
			1e05: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1e09:	mov    rsp,rbp
    1e0c:	pop    rbp
    1e0d:	ret

0000000000001e0e <botlish_fn_21: scan_record<str, int>>:
    1e0e:	push   rbp
    1e0f:	mov    rbp,rsp
    1e12:	sub    rsp,0x40
    1e16:	mov    QWORD PTR [rsp+0x20],rbx
    1e1b:	mov    QWORD PTR [rsp+0x28],r12
    1e20:	mov    QWORD PTR [rsp+0x30],r14
    1e25:	mov    rbx,rdi
    1e28:	mov    QWORD PTR [rsp+0x10],0x0
    1e31:	mov    QWORD PTR [rsp+0x18],0x0
    1e3a:	mov    QWORD PTR [rsp],rsi
    1e3e:	mov    r14,rsi
    1e41:	mov    QWORD PTR [rsp+0x8],rdx
    1e46:	mov    rsi,r14
    1e49:	mov    rdi,rbx
    1e4c:	call   1e51 <botlish_fn_21+0x43>
			1e4d: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1e51:	test   rax,rax
    1e54:	je     1eb5 <botlish_fn_21+0xa7>
    1e5a:	mov    rcx,QWORD PTR [rax+0x18]
    1e5e:	mov    rdx,QWORD PTR [rcx+0x8]
    1e62:	mov    QWORD PTR [rsp+0x8],rdx
    1e67:	mov    r12,rdx
    1e6a:	mov    rax,QWORD PTR [rax+0x18]
    1e6e:	mov    rsi,QWORD PTR [rax]
    1e71:	mov    QWORD PTR [rsp+0x10],rsi
    1e76:	mov    rdi,rbx
    1e79:	call   1e7e <botlish_fn_21+0x70>
			1e7a: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1e7e:	test   rax,rax
    1e81:	je     1eb5 <botlish_fn_21+0xa7>
    1e87:	mov    QWORD PTR [rsp+0x10],rax
    1e8c:	mov    rcx,rax
    1e8f:	mov    r8d,0x3
    1e95:	mov    QWORD PTR [rsp+0x18],0x3
    1e9e:	mov    rdx,r12
    1ea1:	mov    rsi,r14
    1ea4:	mov    rdi,rbx
    1ea7:	call   1eac <botlish_fn_21+0x9e>
			1ea8: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1eac:	test   rax,rax
    1eaf:	jne    1ed0 <botlish_fn_21+0xc2>
    1eb5:	xor    rax,rax
    1eb8:	mov    rbx,QWORD PTR [rsp+0x20]
    1ebd:	mov    r12,QWORD PTR [rsp+0x28]
    1ec2:	mov    r14,QWORD PTR [rsp+0x30]
    1ec7:	add    rsp,0x40
    1ecb:	mov    rsp,rbp
    1ece:	pop    rbp
    1ecf:	ret
    1ed0:	mov    rbx,QWORD PTR [rsp+0x20]
    1ed5:	mov    r12,QWORD PTR [rsp+0x28]
    1eda:	mov    r14,QWORD PTR [rsp+0x30]
    1edf:	add    rsp,0x40
    1ee3:	mov    rsp,rbp
    1ee6:	pop    rbp
    1ee7:	ret

0000000000001ee8 <botlish_entry_21: scan_record<str, int>>:
    1ee8:	push   rbp
    1ee9:	mov    rbp,rsp
    1eec:	mov    rsi,QWORD PTR [rdx]
    1eef:	mov    rdx,QWORD PTR [rdx+0x8]
    1ef3:	call   1ef8 <botlish_entry_21+0x10>
			1ef4: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1ef8:	mov    rsp,rbp
    1efb:	pop    rbp
    1efc:	ret
    1efd:	add    BYTE PTR [rax],al
	...

0000000000001f00 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1f00:	push   rbp
    1f01:	mov    rbp,rsp
    1f04:	sub    rsp,0x60
    1f08:	mov    QWORD PTR [rsp+0x30],rbx
    1f0d:	mov    QWORD PTR [rsp+0x38],r12
    1f12:	mov    QWORD PTR [rsp+0x40],r13
    1f17:	mov    QWORD PTR [rsp+0x48],r14
    1f1c:	mov    QWORD PTR [rsp+0x50],r15
    1f21:	mov    r13,rdi
    1f24:	mov    QWORD PTR [rsp+0x20],0x0
    1f2d:	mov    QWORD PTR [rsp],rsi
    1f31:	mov    QWORD PTR [rsp+0x8],rdx
    1f36:	mov    r12,rdx
    1f39:	mov    QWORD PTR [rsp+0x10],rcx
    1f3e:	mov    QWORD PTR [rsp+0x18],r8
    1f43:	mov    rbx,rsi
    1f46:	mov    r14,r8
    1f49:	mov    r15,rcx
    1f4c:	mov    rsi,rbx
    1f4f:	mov    rdi,r13
    1f52:	call   1f57 <botlish_fn_22+0x57>
			1f53: R_X86_64_PLT32	rt_str_len-0x4
    1f57:	mov    rcx,r12
    1f5a:	and    rcx,rax
    1f5d:	mov    rdx,rax
    1f60:	test   rcx,0x1
    1f67:	jne    1f8d <botlish_fn_22+0x8d>
    1f6d:	mov    rsi,r12
    1f70:	mov    rdi,r13
    1f73:	call   1f78 <botlish_fn_22+0x78>
			1f74: R_X86_64_PLT32	rt_int_cmp-0x4
    1f78:	mov    ecx,0x2
    1f7d:	test   rax,rax
    1f80:	cmovge rcx,QWORD PTR [rip+0x140]        # 20c8 <botlish_fn_22+0x1c8>
    1f88:	jmp    1fa0 <botlish_fn_22+0xa0>
    1f8d:	mov    ecx,0x2
    1f92:	mov    rax,r12
    1f95:	cmp    rax,rdx
    1f98:	cmovge rcx,QWORD PTR [rip+0x128]        # 20c8 <botlish_fn_22+0x1c8>
    1fa0:	cmp    rcx,0x6
    1fa4:	je     2066 <botlish_fn_22+0x166>
    1faa:	mov    rdx,r12
    1fad:	mov    rsi,rbx
    1fb0:	mov    rdi,r13
    1fb3:	call   1fb8 <botlish_fn_22+0xb8>
			1fb4: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1fb8:	test   rax,rax
    1fbb:	je     207d <botlish_fn_22+0x17d>
    1fc1:	mov    QWORD PTR [rsp+0x8],rax
    1fc6:	mov    rcx,QWORD PTR [rax+0x18]
    1fca:	mov    r12,rax
    1fcd:	mov    rcx,QWORD PTR [rcx]
    1fd0:	mov    QWORD PTR [rsp+0x20],rcx
    1fd5:	mov    rsi,r15
    1fd8:	mov    rdx,r14
    1fdb:	mov    rdi,r13
    1fde:	call   1fe3 <botlish_fn_22+0xe3>
			1fdf: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1fe3:	test   rax,rax
    1fe6:	je     207d <botlish_fn_22+0x17d>
    1fec:	mov    QWORD PTR [rsp+0x8],rax
    1ff1:	mov    r15,rax
    1ff4:	mov    rax,r12
    1ff7:	mov    rax,QWORD PTR [rax+0x18]
    1ffb:	mov    rdx,QWORD PTR [rax+0x8]
    1fff:	mov    r12,rdx
    2002:	mov    QWORD PTR [rsp+0x10],rdx
    2007:	mov    QWORD PTR [rsp+0x20],0x3
    2010:	mov    rsi,r14
    2013:	test   rsi,0x1
    201a:	je     2035 <botlish_fn_22+0x135>
    2020:	mov    rsi,r14
    2023:	mov    rax,rsi
    2026:	add    rax,0x2
    202a:	seto   cl
    202d:	test   cl,cl
    202f:	je     2045 <botlish_fn_22+0x145>
    2035:	mov    edx,0x3
    203a:	mov    rsi,r14
    203d:	mov    rdi,r13
    2040:	call   2045 <botlish_fn_22+0x145>
			2041: R_X86_64_PLT32	rt_int_add-0x4
    2045:	mov    QWORD PTR [rsp],rbx
    2049:	mov    rdx,r12
    204c:	mov    QWORD PTR [rsp+0x8],rdx
    2051:	mov    rcx,r15
    2054:	mov    QWORD PTR [rsp+0x10],rcx
    2059:	mov    QWORD PTR [rsp+0x18],rax
    205e:	mov    r14,rax
    2061:	jmp    1f4c <botlish_fn_22+0x4c>
    2066:	mov    rdx,r14
    2069:	mov    rsi,r15
    206c:	mov    rdi,r13
    206f:	call   2074 <botlish_fn_22+0x174>
			2070: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    2074:	test   rax,rax
    2077:	jne    20a2 <botlish_fn_22+0x1a2>
    207d:	xor    rax,rax
    2080:	mov    rbx,QWORD PTR [rsp+0x30]
    2085:	mov    r12,QWORD PTR [rsp+0x38]
    208a:	mov    r13,QWORD PTR [rsp+0x40]
    208f:	mov    r14,QWORD PTR [rsp+0x48]
    2094:	mov    r15,QWORD PTR [rsp+0x50]
    2099:	add    rsp,0x60
    209d:	mov    rsp,rbp
    20a0:	pop    rbp
    20a1:	ret
    20a2:	mov    rbx,QWORD PTR [rsp+0x30]
    20a7:	mov    r12,QWORD PTR [rsp+0x38]
    20ac:	mov    r13,QWORD PTR [rsp+0x40]
    20b1:	mov    r14,QWORD PTR [rsp+0x48]
    20b6:	mov    r15,QWORD PTR [rsp+0x50]
    20bb:	add    rsp,0x60
    20bf:	mov    rsp,rbp
    20c2:	pop    rbp
    20c3:	ret
    20c4:	add    BYTE PTR [rax],al
    20c6:	add    BYTE PTR [rax],al
    20c8:	(bad)
    20c9:	add    BYTE PTR [rax],al
    20cb:	add    BYTE PTR [rax],al
    20cd:	add    BYTE PTR [rax],al
	...

00000000000020d0 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    20d0:	push   rbp
    20d1:	mov    rbp,rsp
    20d4:	mov    rsi,QWORD PTR [rdx]
    20d7:	mov    r9,QWORD PTR [rdx+0x8]
    20db:	mov    rcx,QWORD PTR [rdx+0x10]
    20df:	mov    r8,QWORD PTR [rdx+0x18]
    20e3:	mov    rdx,r9
    20e6:	call   20eb <botlish_entry_22+0x1b>
			20e7: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    20eb:	mov    rsp,rbp
    20ee:	pop    rbp
    20ef:	ret

00000000000020f0 <botlish_fn_23: csv_parse<str>>:
    20f0:	push   rbp
    20f1:	mov    rbp,rsp
    20f4:	sub    rsp,0x40
    20f8:	mov    QWORD PTR [rsp+0x20],rbx
    20fd:	mov    QWORD PTR [rsp+0x28],r12
    2102:	mov    QWORD PTR [rsp+0x30],r13
    2107:	mov    rbx,rdi
    210a:	mov    QWORD PTR [rsp+0x8],0x0
    2113:	mov    QWORD PTR [rsp+0x10],0x0
    211c:	mov    QWORD PTR [rsp+0x18],0x0
    2125:	mov    QWORD PTR [rsp],rsi
    2129:	mov    r12,rsi
    212c:	mov    rsi,r12
    212f:	mov    rdi,rbx
    2132:	call   2137 <botlish_fn_23+0x47>
			2133: R_X86_64_PLT32	rt_str_len-0x4
    2137:	sar    rax,1
    213a:	test   rax,rax
    213d:	je     21d8 <botlish_fn_23+0xe8>
    2143:	mov    edx,0x1
    2148:	mov    QWORD PTR [rsp+0x8],0x1
    2151:	mov    rsi,r12
    2154:	mov    rdi,rbx
    2157:	call   215c <botlish_fn_23+0x6c>
			2158: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    215c:	test   rax,rax
    215f:	je     21ef <botlish_fn_23+0xff>
    2165:	mov    rcx,QWORD PTR [rax+0x18]
    2169:	mov    rdx,QWORD PTR [rcx+0x8]
    216d:	mov    QWORD PTR [rsp+0x8],rdx
    2172:	mov    r13,rdx
    2175:	mov    rax,QWORD PTR [rax+0x18]
    2179:	mov    rsi,QWORD PTR [rax]
    217c:	mov    QWORD PTR [rsp+0x10],rsi
    2181:	mov    rdi,rbx
    2184:	call   2189 <botlish_fn_23+0x99>
			2185: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    2189:	test   rax,rax
    218c:	je     21ef <botlish_fn_23+0xff>
    2192:	mov    QWORD PTR [rsp+0x10],rax
    2197:	mov    rcx,rax
    219a:	mov    r8d,0x3
    21a0:	mov    QWORD PTR [rsp+0x18],0x3
    21a9:	mov    rdx,r13
    21ac:	mov    rsi,r12
    21af:	mov    rdi,rbx
    21b2:	call   21b7 <botlish_fn_23+0xc7>
			21b3: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    21b7:	test   rax,rax
    21ba:	je     21ef <botlish_fn_23+0xff>
    21c0:	mov    rbx,QWORD PTR [rsp+0x20]
    21c5:	mov    r12,QWORD PTR [rsp+0x28]
    21ca:	mov    r13,QWORD PTR [rsp+0x30]
    21cf:	add    rsp,0x40
    21d3:	mov    rsp,rbp
    21d6:	pop    rbp
    21d7:	ret
    21d8:	xor    rdx,rdx
    21db:	mov    rdi,rbx
    21de:	mov    rsi,rdx
    21e1:	call   21e6 <botlish_fn_23+0xf6>
			21e2: R_X86_64_PLT32	rt_list_new-0x4
    21e6:	test   rax,rax
    21e9:	jne    220a <botlish_fn_23+0x11a>
    21ef:	xor    rax,rax
    21f2:	mov    rbx,QWORD PTR [rsp+0x20]
    21f7:	mov    r12,QWORD PTR [rsp+0x28]
    21fc:	mov    r13,QWORD PTR [rsp+0x30]
    2201:	add    rsp,0x40
    2205:	mov    rsp,rbp
    2208:	pop    rbp
    2209:	ret
    220a:	mov    rbx,QWORD PTR [rsp+0x20]
    220f:	mov    r12,QWORD PTR [rsp+0x28]
    2214:	mov    r13,QWORD PTR [rsp+0x30]
    2219:	add    rsp,0x40
    221d:	mov    rsp,rbp
    2220:	pop    rbp
    2221:	ret

0000000000002222 <botlish_entry_23: csv_parse<str>>:
    2222:	push   rbp
    2223:	mov    rbp,rsp
    2226:	mov    rsi,QWORD PTR [rdx]
    2229:	call   222e <botlish_entry_23+0xc>
			222a: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    222e:	mov    rsp,rbp
    2231:	pop    rbp
    2232:	ret
    2233:	add    BYTE PTR [rax],al
    2235:	add    BYTE PTR [rax],al
	...

0000000000002238 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    2238:	push   rbp
    2239:	mov    rbp,rsp
    223c:	sub    rsp,0x40
    2240:	mov    QWORD PTR [rsp+0x20],rbx
    2245:	mov    QWORD PTR [rsp+0x28],r12
    224a:	mov    QWORD PTR [rsp+0x30],r13
    224f:	mov    QWORD PTR [rsp+0x38],r14
    2254:	mov    r13,rdi
    2257:	mov    QWORD PTR [rsp],rsi
    225b:	mov    rbx,rsi
    225e:	mov    QWORD PTR [rsp+0x8],rdx
    2263:	mov    QWORD PTR [rsp+0x10],rcx
    2268:	mov    r12,rcx
    226b:	mov    rsi,rdx
    226e:	mov    rax,rsi
    2271:	and    rax,r12
    2274:	mov    r14,rsi
    2277:	test   rax,0x1
    227d:	jne    22a6 <botlish_fn_24+0x6e>
    2283:	mov    rdx,r12
    2286:	mov    rsi,r14
    2289:	mov    rdi,r13
    228c:	call   2291 <botlish_fn_24+0x59>
			228d: R_X86_64_PLT32	rt_int_cmp-0x4
    2291:	mov    ecx,0x2
    2296:	test   rax,rax
    2299:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2380 <botlish_fn_24+0x148>
    22a1:	jmp    22b9 <botlish_fn_24+0x81>
    22a6:	mov    ecx,0x2
    22ab:	mov    rsi,r14
    22ae:	cmp    rsi,r12
    22b1:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2380 <botlish_fn_24+0x148>
    22b9:	cmp    rcx,0x6
    22bd:	je     235e <botlish_fn_24+0x126>
    22c3:	mov    ecx,0x1
    22c8:	mov    rdx,r14
    22cb:	mov    rsi,rbx
    22ce:	mov    rdi,r13
    22d1:	call   22d6 <botlish_fn_24+0x9e>
			22d2: R_X86_64_PLT32	rt_mutarray_set-0x4
    22d6:	test   rax,rax
    22d9:	jne    22ff <botlish_fn_24+0xc7>
    22df:	xor    rax,rax
    22e2:	mov    rbx,QWORD PTR [rsp+0x20]
    22e7:	mov    r12,QWORD PTR [rsp+0x28]
    22ec:	mov    r13,QWORD PTR [rsp+0x30]
    22f1:	mov    r14,QWORD PTR [rsp+0x38]
    22f6:	add    rsp,0x40
    22fa:	mov    rsp,rbp
    22fd:	pop    rbp
    22fe:	ret
    22ff:	mov    QWORD PTR [rsp+0x18],0x3
    2308:	mov    rsi,r14
    230b:	test   rsi,0x1
    2312:	je     2335 <botlish_fn_24+0xfd>
    2318:	mov    rsi,r14
    231b:	mov    rcx,rsi
    231e:	add    rcx,0x2
    2322:	seto   al
    2325:	test   al,al
    2327:	jne    2335 <botlish_fn_24+0xfd>
    232d:	mov    r14,rcx
    2330:	jmp    2348 <botlish_fn_24+0x110>
    2335:	mov    edx,0x3
    233a:	mov    rsi,r14
    233d:	mov    rdi,r13
    2340:	call   2345 <botlish_fn_24+0x10d>
			2341: R_X86_64_PLT32	rt_int_add-0x4
    2345:	mov    r14,rax
    2348:	mov    QWORD PTR [rsp],rbx
    234c:	mov    rsi,r14
    234f:	mov    QWORD PTR [rsp+0x8],rsi
    2354:	mov    QWORD PTR [rsp+0x10],r12
    2359:	jmp    226e <botlish_fn_24+0x36>
    235e:	mov    eax,0xa
    2363:	mov    rbx,QWORD PTR [rsp+0x20]
    2368:	mov    r12,QWORD PTR [rsp+0x28]
    236d:	mov    r13,QWORD PTR [rsp+0x30]
    2372:	mov    r14,QWORD PTR [rsp+0x38]
    2377:	add    rsp,0x40
    237b:	mov    rsp,rbp
    237e:	pop    rbp
    237f:	ret
    2380:	(bad)
    2381:	add    BYTE PTR [rax],al
    2383:	add    BYTE PTR [rax],al
    2385:	add    BYTE PTR [rax],al
	...

0000000000002388 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    2388:	push   rbp
    2389:	mov    rbp,rsp
    238c:	mov    rsi,QWORD PTR [rdx]
    238f:	mov    r8,QWORD PTR [rdx+0x8]
    2393:	mov    rcx,QWORD PTR [rdx+0x10]
    2397:	mov    rdx,r8
    239a:	call   239f <botlish_entry_24+0x17>
			239b: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    239f:	mov    rsp,rbp
    23a2:	pop    rbp
    23a3:	ret

00000000000023a4 <botlish_fn_25: ht_alloc<int>>:
    23a4:	push   rbp
    23a5:	mov    rbp,rsp
    23a8:	sub    rsp,0x50
    23ac:	mov    QWORD PTR [rsp+0x20],rbx
    23b1:	mov    QWORD PTR [rsp+0x28],r12
    23b6:	mov    QWORD PTR [rsp+0x30],r13
    23bb:	mov    QWORD PTR [rsp+0x38],r14
    23c0:	mov    QWORD PTR [rsp+0x40],r15
    23c5:	mov    rbx,rdi
    23c8:	mov    QWORD PTR [rsp+0x8],0x0
    23d1:	mov    QWORD PTR [rsp+0x10],0x0
    23da:	mov    QWORD PTR [rsp+0x18],0x0
    23e3:	mov    QWORD PTR [rsp],rsi
    23e7:	mov    r13,rsi
    23ea:	mov    rsi,r13
    23ed:	mov    rdi,rbx
    23f0:	call   23f5 <botlish_fn_25+0x51>
			23f1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    23f5:	test   rax,rax
    23f8:	je     2514 <botlish_fn_25+0x170>
    23fe:	mov    QWORD PTR [rsp+0x8],rax
    2403:	mov    r12,rax
    2406:	mov    edx,0x1
    240b:	mov    QWORD PTR [rsp+0x10],0x1
    2414:	mov    rcx,r13
    2417:	mov    rsi,r12
    241a:	mov    rdi,rbx
    241d:	call   2422 <botlish_fn_25+0x7e>
			241e: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    2422:	test   rax,rax
    2425:	je     2514 <botlish_fn_25+0x170>
    242b:	mov    rsi,r13
    242e:	mov    rdi,rbx
    2431:	call   2436 <botlish_fn_25+0x92>
			2432: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2436:	test   rax,rax
    2439:	je     2514 <botlish_fn_25+0x170>
    243f:	mov    QWORD PTR [rsp+0x10],rax
    2444:	mov    rsi,r13
    2447:	mov    r14,rax
    244a:	mov    rdi,rbx
    244d:	call   2452 <botlish_fn_25+0xae>
			244e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2452:	test   rax,rax
    2455:	je     2514 <botlish_fn_25+0x170>
    245b:	mov    QWORD PTR [rsp],rax
    245f:	mov    r13,rax
    2462:	mov    esi,0xb
    2467:	mov    QWORD PTR [rsp+0x18],0xb
    2470:	mov    rdi,rbx
    2473:	call   2478 <botlish_fn_25+0xd4>
			2474: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2478:	test   rax,rax
    247b:	mov    r15,rax
    247e:	je     2514 <botlish_fn_25+0x170>
    2484:	mov    edx,0x1
    2489:	mov    rcx,r12
    248c:	mov    rsi,r15
    248f:	mov    rdi,rbx
    2492:	call   2497 <botlish_fn_25+0xf3>
			2493: R_X86_64_PLT32	rt_mutarray_set-0x4
    2497:	test   rax,rax
    249a:	je     2514 <botlish_fn_25+0x170>
    24a0:	mov    edx,0x3
    24a5:	mov    rcx,r14
    24a8:	mov    rsi,r15
    24ab:	mov    rdi,rbx
    24ae:	call   24b3 <botlish_fn_25+0x10f>
			24af: R_X86_64_PLT32	rt_mutarray_set-0x4
    24b3:	test   rax,rax
    24b6:	je     2514 <botlish_fn_25+0x170>
    24bc:	mov    edx,0x5
    24c1:	mov    rcx,r13
    24c4:	mov    rsi,r15
    24c7:	mov    rdi,rbx
    24ca:	call   24cf <botlish_fn_25+0x12b>
			24cb: R_X86_64_PLT32	rt_mutarray_set-0x4
    24cf:	test   rax,rax
    24d2:	je     2514 <botlish_fn_25+0x170>
    24d8:	mov    edx,0x7
    24dd:	mov    ecx,0x1
    24e2:	mov    rsi,r15
    24e5:	mov    rdi,rbx
    24e8:	call   24ed <botlish_fn_25+0x149>
			24e9: R_X86_64_PLT32	rt_mutarray_set-0x4
    24ed:	test   rax,rax
    24f0:	je     2514 <botlish_fn_25+0x170>
    24f6:	mov    edx,0x9
    24fb:	mov    ecx,0x1
    2500:	mov    rdi,rbx
    2503:	mov    rsi,r15
    2506:	call   250b <botlish_fn_25+0x167>
			2507: R_X86_64_PLT32	rt_mutarray_set-0x4
    250b:	test   rax,rax
    250e:	jne    2539 <botlish_fn_25+0x195>
    2514:	xor    rax,rax
    2517:	mov    rbx,QWORD PTR [rsp+0x20]
    251c:	mov    r12,QWORD PTR [rsp+0x28]
    2521:	mov    r13,QWORD PTR [rsp+0x30]
    2526:	mov    r14,QWORD PTR [rsp+0x38]
    252b:	mov    r15,QWORD PTR [rsp+0x40]
    2530:	add    rsp,0x50
    2534:	mov    rsp,rbp
    2537:	pop    rbp
    2538:	ret
    2539:	mov    rax,r15
    253c:	mov    rbx,QWORD PTR [rsp+0x20]
    2541:	mov    r12,QWORD PTR [rsp+0x28]
    2546:	mov    r13,QWORD PTR [rsp+0x30]
    254b:	mov    r14,QWORD PTR [rsp+0x38]
    2550:	mov    r15,QWORD PTR [rsp+0x40]
    2555:	add    rsp,0x50
    2559:	mov    rsp,rbp
    255c:	pop    rbp
    255d:	ret

000000000000255e <botlish_entry_25: ht_alloc<int>>:
    255e:	push   rbp
    255f:	mov    rbp,rsp
    2562:	mov    rsi,QWORD PTR [rdx]
    2565:	call   256a <botlish_entry_25+0xc>
			2566: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    256a:	mov    rsp,rbp
    256d:	pop    rbp
    256e:	ret

000000000000256f <botlish_fn_26: ht_new<generic>>:
    256f:	push   rbp
    2570:	mov    rbp,rsp
    2573:	sub    rsp,0x10
    2577:	mov    esi,0x11
    257c:	mov    QWORD PTR [rsp],0x11
    2584:	call   2589 <botlish_fn_26+0x1a>
			2585: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2589:	test   rax,rax
    258c:	jne    259e <botlish_fn_26+0x2f>
    2592:	xor    rax,rax
    2595:	add    rsp,0x10
    2599:	mov    rsp,rbp
    259c:	pop    rbp
    259d:	ret
    259e:	add    rsp,0x10
    25a2:	mov    rsp,rbp
    25a5:	pop    rbp
    25a6:	ret

00000000000025a7 <botlish_entry_26: ht_new<generic>>:
    25a7:	push   rbp
    25a8:	mov    rbp,rsp
    25ab:	call   25b0 <botlish_entry_26+0x9>
			25ac: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    25b0:	mov    rsp,rbp
    25b3:	pop    rbp
    25b4:	ret
    25b5:	add    BYTE PTR [rax],al
	...

00000000000025b8 <botlish_fn_27: ht_capacity_for<int, int>>:
    25b8:	push   rbp
    25b9:	mov    rbp,rsp
    25bc:	sub    rsp,0x50
    25c0:	mov    QWORD PTR [rsp+0x20],rbx
    25c5:	mov    QWORD PTR [rsp+0x28],r12
    25ca:	mov    QWORD PTR [rsp+0x30],r13
    25cf:	mov    QWORD PTR [rsp+0x38],r14
    25d4:	mov    QWORD PTR [rsp+0x40],r15
    25d9:	mov    r13,rdi
    25dc:	mov    QWORD PTR [rsp],rdx
    25e0:	mov    rbx,rsi
    25e3:	or     rbx,0x1
    25e7:	sar    rbx,1
    25ea:	mov    r12,rsi
    25ed:	mov    r14,rdx
    25f0:	mov    rax,r12
    25f3:	or     rax,0x1
    25f7:	mov    QWORD PTR [rsp+0x8],rax
    25fc:	mov    QWORD PTR [rsp+0x10],0x7
    2605:	mov    rax,rbx
    2608:	imul   QWORD PTR [rip+0x159]        # 2768 <botlish_fn_27+0x1b0>
    260f:	seto   cl
    2612:	or     rax,0x1
    2616:	test   cl,cl
    2618:	jne    2626 <botlish_fn_27+0x6e>
    261e:	mov    rsi,rax
    2621:	jmp    263d <botlish_fn_27+0x85>
    2626:	mov    rsi,r12
    2629:	or     rsi,0x1
    262d:	mov    edx,0x7
    2632:	mov    rdi,r13
    2635:	call   263a <botlish_fn_27+0x82>
			2636: R_X86_64_PLT32	rt_int_mul-0x4
    263a:	mov    rsi,rax
    263d:	mov    QWORD PTR [rsp+0x8],rsi
    2642:	mov    r15,rsi
    2645:	mov    QWORD PTR [rsp+0x10],0x5
    264e:	mov    rsi,r14
    2651:	test   rsi,0x1
    2658:	je     2688 <botlish_fn_27+0xd0>
    265e:	mov    rsi,r14
    2661:	mov    rax,rsi
    2664:	sar    rax,1
    2667:	imul   QWORD PTR [rip+0x102]        # 2770 <botlish_fn_27+0x1b8>
    266e:	seto   cl
    2671:	or     rax,0x1
    2675:	test   cl,cl
    2677:	jne    2688 <botlish_fn_27+0xd0>
    267d:	mov    rdx,rax
    2680:	mov    rsi,r15
    2683:	jmp    269e <botlish_fn_27+0xe6>
    2688:	mov    edx,0x5
    268d:	mov    rsi,r14
    2690:	mov    rdi,r13
    2693:	call   2698 <botlish_fn_27+0xe0>
			2694: R_X86_64_PLT32	rt_int_mul-0x4
    2698:	mov    rdx,rax
    269b:	mov    rsi,r15
    269e:	mov    rax,rsi
    26a1:	and    rax,rdx
    26a4:	test   rax,0x1
    26aa:	jne    26cd <botlish_fn_27+0x115>
    26b0:	mov    rdi,r13
    26b3:	call   26b8 <botlish_fn_27+0x100>
			26b4: R_X86_64_PLT32	rt_int_cmp-0x4
    26b8:	mov    ecx,0x2
    26bd:	test   rax,rax
    26c0:	cmovle rcx,QWORD PTR [rip+0xa0]        # 2768 <botlish_fn_27+0x1b0>
    26c8:	jmp    26dd <botlish_fn_27+0x125>
    26cd:	mov    ecx,0x2
    26d2:	cmp    rsi,rdx
    26d5:	cmovle rcx,QWORD PTR [rip+0x8b]        # 2768 <botlish_fn_27+0x1b0>
    26dd:	cmp    rcx,0x6
    26e1:	je     273d <botlish_fn_27+0x185>
    26e7:	mov    QWORD PTR [rsp+0x8],0x5
    26f0:	mov    rsi,r14
    26f3:	test   rsi,0x1
    26fa:	je     2721 <botlish_fn_27+0x169>
    2700:	mov    rsi,r14
    2703:	mov    rax,rsi
    2706:	sar    rax,1
    2709:	imul   QWORD PTR [rip+0x60]        # 2770 <botlish_fn_27+0x1b8>
    2710:	seto   sil
    2714:	or     rax,0x1
    2718:	test   sil,sil
    271b:	je     2731 <botlish_fn_27+0x179>
    2721:	mov    edx,0x5
    2726:	mov    rsi,r14
    2729:	mov    rdi,r13
    272c:	call   2731 <botlish_fn_27+0x179>
			272d: R_X86_64_PLT32	rt_int_mul-0x4
    2731:	mov    QWORD PTR [rsp],rax
    2735:	mov    r14,rax
    2738:	jmp    25f0 <botlish_fn_27+0x38>
    273d:	mov    rax,r14
    2740:	mov    rbx,QWORD PTR [rsp+0x20]
    2745:	mov    r12,QWORD PTR [rsp+0x28]
    274a:	mov    r13,QWORD PTR [rsp+0x30]
    274f:	mov    r14,QWORD PTR [rsp+0x38]
    2754:	mov    r15,QWORD PTR [rsp+0x40]
    2759:	add    rsp,0x50
    275d:	mov    rsp,rbp
    2760:	pop    rbp
    2761:	ret
    2762:	add    BYTE PTR [rax],al
    2764:	add    BYTE PTR [rax],al
    2766:	add    BYTE PTR [rax],al
    2768:	(bad)
    2769:	add    BYTE PTR [rax],al
    276b:	add    BYTE PTR [rax],al
    276d:	add    BYTE PTR [rax],al
    276f:	add    BYTE PTR [rax+rax*1],al
    2772:	add    BYTE PTR [rax],al
    2774:	add    BYTE PTR [rax],al
	...

0000000000002778 <botlish_entry_27: ht_capacity_for<int, int>>:
    2778:	push   rbp
    2779:	mov    rbp,rsp
    277c:	mov    rsi,QWORD PTR [rdx]
    277f:	mov    rdx,QWORD PTR [rdx+0x8]
    2783:	call   2788 <botlish_entry_27+0x10>
			2784: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2788:	mov    rsp,rbp
    278b:	pop    rbp
    278c:	ret

000000000000278d <botlish_fn_28: ht_new_sized<int>>:
    278d:	push   rbp
    278e:	mov    rbp,rsp
    2791:	sub    rsp,0x20
    2795:	mov    QWORD PTR [rsp+0x10],r12
    279a:	mov    r12,rdi
    279d:	mov    QWORD PTR [rsp],rsi
    27a1:	mov    edx,0x11
    27a6:	mov    QWORD PTR [rsp+0x8],0x11
    27af:	mov    rdi,r12
    27b2:	call   27b7 <botlish_fn_28+0x2a>
			27b3: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    27b7:	mov    QWORD PTR [rsp],rax
    27bb:	mov    rsi,rax
    27be:	mov    rdi,r12
    27c1:	call   27c6 <botlish_fn_28+0x39>
			27c2: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    27c6:	test   rax,rax
    27c9:	jne    27e0 <botlish_fn_28+0x53>
    27cf:	xor    rax,rax
    27d2:	mov    r12,QWORD PTR [rsp+0x10]
    27d7:	add    rsp,0x20
    27db:	mov    rsp,rbp
    27de:	pop    rbp
    27df:	ret
    27e0:	mov    r12,QWORD PTR [rsp+0x10]
    27e5:	add    rsp,0x20
    27e9:	mov    rsp,rbp
    27ec:	pop    rbp
    27ed:	ret

00000000000027ee <botlish_entry_28: ht_new_sized<int>>:
    27ee:	push   rbp
    27ef:	mov    rbp,rsp
    27f2:	mov    rsi,QWORD PTR [rdx]
    27f5:	call   27fa <botlish_entry_28+0xc>
			27f6: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    27fa:	mov    rsp,rbp
    27fd:	pop    rbp
    27fe:	ret

00000000000027ff <botlish_fn_29: ht_controls<mutarray>>:
    27ff:	push   rbp
    2800:	mov    rbp,rsp
    2803:	mov    edx,0x1
    2808:	call   280d <botlish_fn_29+0xe>
			2809: R_X86_64_PLT32	rt_mutarray_get-0x4
    280d:	test   rax,rax
    2810:	jne    281e <botlish_fn_29+0x1f>
    2816:	xor    rax,rax
    2819:	mov    rsp,rbp
    281c:	pop    rbp
    281d:	ret
    281e:	mov    rsp,rbp
    2821:	pop    rbp
    2822:	ret

0000000000002823 <botlish_entry_29: ht_controls<mutarray>>:
    2823:	push   rbp
    2824:	mov    rbp,rsp
    2827:	mov    rsi,QWORD PTR [rdx]
    282a:	call   282f <botlish_entry_29+0xc>
			282b: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    282f:	mov    rsp,rbp
    2832:	pop    rbp
    2833:	ret

0000000000002834 <botlish_fn_30: ht_keys<mutarray>>:
    2834:	push   rbp
    2835:	mov    rbp,rsp
    2838:	mov    edx,0x3
    283d:	call   2842 <botlish_fn_30+0xe>
			283e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2842:	test   rax,rax
    2845:	jne    2853 <botlish_fn_30+0x1f>
    284b:	xor    rax,rax
    284e:	mov    rsp,rbp
    2851:	pop    rbp
    2852:	ret
    2853:	mov    rsp,rbp
    2856:	pop    rbp
    2857:	ret

0000000000002858 <botlish_entry_30: ht_keys<mutarray>>:
    2858:	push   rbp
    2859:	mov    rbp,rsp
    285c:	mov    rsi,QWORD PTR [rdx]
    285f:	call   2864 <botlish_entry_30+0xc>
			2860: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2864:	mov    rsp,rbp
    2867:	pop    rbp
    2868:	ret

0000000000002869 <botlish_fn_31: ht_values<mutarray>>:
    2869:	push   rbp
    286a:	mov    rbp,rsp
    286d:	mov    edx,0x5
    2872:	call   2877 <botlish_fn_31+0xe>
			2873: R_X86_64_PLT32	rt_mutarray_get-0x4
    2877:	test   rax,rax
    287a:	jne    2888 <botlish_fn_31+0x1f>
    2880:	xor    rax,rax
    2883:	mov    rsp,rbp
    2886:	pop    rbp
    2887:	ret
    2888:	mov    rsp,rbp
    288b:	pop    rbp
    288c:	ret

000000000000288d <botlish_entry_31: ht_values<mutarray>>:
    288d:	push   rbp
    288e:	mov    rbp,rsp
    2891:	mov    rsi,QWORD PTR [rdx]
    2894:	call   2899 <botlish_entry_31+0xc>
			2895: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    2899:	mov    rsp,rbp
    289c:	pop    rbp
    289d:	ret

000000000000289e <botlish_fn_32: ht_size<mutarray>>:
    289e:	push   rbp
    289f:	mov    rbp,rsp
    28a2:	mov    edx,0x7
    28a7:	call   28ac <botlish_fn_32+0xe>
			28a8: R_X86_64_PLT32	rt_mutarray_get-0x4
    28ac:	test   rax,rax
    28af:	jne    28bd <botlish_fn_32+0x1f>
    28b5:	xor    rax,rax
    28b8:	mov    rsp,rbp
    28bb:	pop    rbp
    28bc:	ret
    28bd:	mov    rsp,rbp
    28c0:	pop    rbp
    28c1:	ret

00000000000028c2 <botlish_entry_32: ht_size<mutarray>>:
    28c2:	push   rbp
    28c3:	mov    rbp,rsp
    28c6:	mov    rsi,QWORD PTR [rdx]
    28c9:	call   28ce <botlish_entry_32+0xc>
			28ca: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    28ce:	mov    rsp,rbp
    28d1:	pop    rbp
    28d2:	ret

00000000000028d3 <botlish_fn_33: ht_tombstones<mutarray>>:
    28d3:	push   rbp
    28d4:	mov    rbp,rsp
    28d7:	mov    edx,0x9
    28dc:	call   28e1 <botlish_fn_33+0xe>
			28dd: R_X86_64_PLT32	rt_mutarray_get-0x4
    28e1:	test   rax,rax
    28e4:	jne    28f2 <botlish_fn_33+0x1f>
    28ea:	xor    rax,rax
    28ed:	mov    rsp,rbp
    28f0:	pop    rbp
    28f1:	ret
    28f2:	mov    rsp,rbp
    28f5:	pop    rbp
    28f6:	ret

00000000000028f7 <botlish_entry_33: ht_tombstones<mutarray>>:
    28f7:	push   rbp
    28f8:	mov    rbp,rsp
    28fb:	mov    rsi,QWORD PTR [rdx]
    28fe:	call   2903 <botlish_entry_33+0xc>
			28ff: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    2903:	mov    rsp,rbp
    2906:	pop    rbp
    2907:	ret

0000000000002908 <botlish_fn_34: ht_capacity<mutarray>>:
    2908:	push   rbp
    2909:	mov    rbp,rsp
    290c:	sub    rsp,0x10
    2910:	mov    QWORD PTR [rsp],rbx
    2914:	mov    rbx,rdi
    2917:	mov    rdi,rbx
    291a:	call   291f <botlish_fn_34+0x17>
			291b: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    291f:	test   rax,rax
    2922:	je     296c <botlish_fn_34+0x64>
    2928:	xor    r8d,r8d
    292b:	test   rax,0x7
    2931:	je     293f <botlish_fn_34+0x37>
    2937:	mov    rsi,rax
    293a:	jmp    294e <botlish_fn_34+0x46>
    293f:	movzx  rcx,BYTE PTR [rax]
    2943:	mov    rsi,rax
    2946:	rex cmp cl,0x8
    294a:	sete   r8b
    294e:	test   r8b,r8b
    2951:	jne    297c <botlish_fn_34+0x74>
    2957:	mov    rdi,rbx
    295a:	mov    rax,QWORD PTR [rdi+0x10]
    295e:	mov    rcx,QWORD PTR [rax+0x28]
    2962:	mov    edx,0x8
    2967:	call   296c <botlish_fn_34+0x64>
			2968: R_X86_64_PLT32	rt_type_error-0x4
    296c:	xor    rax,rax
    296f:	mov    rbx,QWORD PTR [rsp]
    2973:	add    rsp,0x10
    2977:	mov    rsp,rbp
    297a:	pop    rbp
    297b:	ret
    297c:	mov    rdi,rbx
    297f:	call   2984 <botlish_fn_34+0x7c>
			2980: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2984:	mov    rbx,QWORD PTR [rsp]
    2988:	add    rsp,0x10
    298c:	mov    rsp,rbp
    298f:	pop    rbp
    2990:	ret

0000000000002991 <botlish_entry_34: ht_capacity<mutarray>>:
    2991:	push   rbp
    2992:	mov    rbp,rsp
    2995:	mov    rsi,QWORD PTR [rdx]
    2998:	call   299d <botlish_entry_34+0xc>
			2999: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    299d:	mov    rsp,rbp
    29a0:	pop    rbp
    29a1:	ret

00000000000029a2 <botlish_fn_35: ht_probe_start<mutarray, str>>:
    29a2:	push   rbp
    29a3:	mov    rbp,rsp
    29a6:	sub    rsp,0x20
    29aa:	mov    QWORD PTR [rsp],r12
    29ae:	mov    QWORD PTR [rsp+0x8],r13
    29b3:	mov    QWORD PTR [rsp+0x10],r14
    29b8:	mov    r12,rdi
    29bb:	mov    r14,rsi
    29be:	mov    rsi,rdx
    29c1:	mov    rdi,r12
    29c4:	call   29c9 <botlish_fn_35+0x27>
			29c5: R_X86_64_PLT32	rt_hash-0x4
    29c9:	test   rax,rax
    29cc:	mov    r13,rax
    29cf:	je     2a00 <botlish_fn_35+0x5e>
    29d5:	mov    rsi,r14
    29d8:	mov    rdi,r12
    29db:	call   29e0 <botlish_fn_35+0x3e>
			29dc: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    29e0:	test   rax,rax
    29e3:	mov    rdx,rax
    29e6:	je     2a00 <botlish_fn_35+0x5e>
    29ec:	mov    rsi,r13
    29ef:	mov    rdi,r12
    29f2:	call   29f7 <botlish_fn_35+0x55>
			29f3: R_X86_64_PLT32	rt_int_mod-0x4
    29f7:	test   rax,rax
    29fa:	jne    2a1a <botlish_fn_35+0x78>
    2a00:	xor    rax,rax
    2a03:	mov    r12,QWORD PTR [rsp]
    2a07:	mov    r13,QWORD PTR [rsp+0x8]
    2a0c:	mov    r14,QWORD PTR [rsp+0x10]
    2a11:	add    rsp,0x20
    2a15:	mov    rsp,rbp
    2a18:	pop    rbp
    2a19:	ret
    2a1a:	mov    r12,QWORD PTR [rsp]
    2a1e:	mov    r13,QWORD PTR [rsp+0x8]
    2a23:	mov    r14,QWORD PTR [rsp+0x10]
    2a28:	add    rsp,0x20
    2a2c:	mov    rsp,rbp
    2a2f:	pop    rbp
    2a30:	ret

0000000000002a31 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    2a31:	push   rbp
    2a32:	mov    rbp,rsp
    2a35:	mov    rsi,QWORD PTR [rdx]
    2a38:	mov    rdx,QWORD PTR [rdx+0x8]
    2a3c:	call   2a41 <botlish_entry_35+0x10>
			2a3d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    2a41:	mov    rsp,rbp
    2a44:	pop    rbp
    2a45:	ret

0000000000002a46 <botlish_fn_36: ht_probe_next<mutarray, int>>:
    2a46:	push   rbp
    2a47:	mov    rbp,rsp
    2a4a:	sub    rsp,0x40
    2a4e:	mov    QWORD PTR [rsp+0x20],rbx
    2a53:	mov    QWORD PTR [rsp+0x28],r12
    2a58:	mov    QWORD PTR [rsp+0x30],r13
    2a5d:	mov    r13,rdi
    2a60:	mov    QWORD PTR [rsp],rsi
    2a64:	mov    rbx,rsi
    2a67:	mov    QWORD PTR [rsp+0x8],rdx
    2a6c:	mov    QWORD PTR [rsp+0x10],0x3
    2a75:	test   rdx,0x1
    2a7c:	jne    2a8a <botlish_fn_36+0x44>
    2a82:	mov    rsi,rdx
    2a85:	jmp    2aaa <botlish_fn_36+0x64>
    2a8a:	mov    rsi,rdx
    2a8d:	add    rsi,0x2
    2a91:	mov    r12,rsi
    2a94:	mov    rsi,rdx
    2a97:	seto   al
    2a9a:	test   al,al
    2a9c:	jne    2aaa <botlish_fn_36+0x64>
    2aa2:	mov    rsi,rbx
    2aa5:	jmp    2abd <botlish_fn_36+0x77>
    2aaa:	mov    edx,0x3
    2aaf:	mov    rdi,r13
    2ab2:	call   2ab7 <botlish_fn_36+0x71>
			2ab3: R_X86_64_PLT32	rt_int_add-0x4
    2ab7:	mov    rsi,rbx
    2aba:	mov    r12,rax
    2abd:	mov    rdi,r13
    2ac0:	call   2ac5 <botlish_fn_36+0x7f>
			2ac1: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2ac5:	test   rax,rax
    2ac8:	mov    rdx,rax
    2acb:	je     2ae5 <botlish_fn_36+0x9f>
    2ad1:	mov    rsi,r12
    2ad4:	mov    rdi,r13
    2ad7:	call   2adc <botlish_fn_36+0x96>
			2ad8: R_X86_64_PLT32	rt_int_mod-0x4
    2adc:	test   rax,rax
    2adf:	jne    2b00 <botlish_fn_36+0xba>
    2ae5:	xor    rax,rax
    2ae8:	mov    rbx,QWORD PTR [rsp+0x20]
    2aed:	mov    r12,QWORD PTR [rsp+0x28]
    2af2:	mov    r13,QWORD PTR [rsp+0x30]
    2af7:	add    rsp,0x40
    2afb:	mov    rsp,rbp
    2afe:	pop    rbp
    2aff:	ret
    2b00:	mov    rbx,QWORD PTR [rsp+0x20]
    2b05:	mov    r12,QWORD PTR [rsp+0x28]
    2b0a:	mov    r13,QWORD PTR [rsp+0x30]
    2b0f:	add    rsp,0x40
    2b13:	mov    rsp,rbp
    2b16:	pop    rbp
    2b17:	ret

0000000000002b18 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    2b18:	push   rbp
    2b19:	mov    rbp,rsp
    2b1c:	mov    rsi,QWORD PTR [rdx]
    2b1f:	mov    rdx,QWORD PTR [rdx+0x8]
    2b23:	call   2b28 <botlish_entry_36+0x10>
			2b24: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2b28:	mov    rsp,rbp
    2b2b:	pop    rbp
    2b2c:	ret
    2b2d:	add    BYTE PTR [rax],al
	...

0000000000002b30 <botlish_fn_37: ht_find_get<mutarray, str, int>>:
    2b30:	push   rbp
    2b31:	mov    rbp,rsp
    2b34:	sub    rsp,0x50
    2b38:	mov    QWORD PTR [rsp+0x20],rbx
    2b3d:	mov    QWORD PTR [rsp+0x28],r12
    2b42:	mov    QWORD PTR [rsp+0x30],r13
    2b47:	mov    QWORD PTR [rsp+0x38],r14
    2b4c:	mov    QWORD PTR [rsp+0x40],r15
    2b51:	mov    r14,rdi
    2b54:	mov    QWORD PTR [rsp],rsi
    2b58:	mov    QWORD PTR [rsp+0x8],rdx
    2b5d:	mov    r13,rdx
    2b60:	mov    QWORD PTR [rsp+0x10],rcx
    2b65:	mov    r12,rsi
    2b68:	mov    r15,rcx
    2b6b:	mov    rsi,r12
    2b6e:	mov    rdi,r14
    2b71:	call   2b76 <botlish_fn_37+0x46>
			2b72: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2b76:	test   rax,rax
    2b79:	je     2d78 <botlish_fn_37+0x248>
    2b7f:	xor    ecx,ecx
    2b81:	test   rax,0x7
    2b87:	je     2b95 <botlish_fn_37+0x65>
    2b8d:	mov    rsi,rax
    2b90:	jmp    2ba3 <botlish_fn_37+0x73>
    2b95:	movzx  rcx,BYTE PTR [rax]
    2b99:	mov    rsi,rax
    2b9c:	rex cmp cl,0x8
    2ba0:	sete   cl
    2ba3:	test   cl,cl
    2ba5:	jne    2bc5 <botlish_fn_37+0x95>
    2bab:	mov    rdi,r14
    2bae:	mov    rdx,QWORD PTR [rdi+0x10]
    2bb2:	mov    rcx,QWORD PTR [rdx+0x30]
    2bb6:	mov    edx,0x8
    2bbb:	call   2bc0 <botlish_fn_37+0x90>
			2bbc: R_X86_64_PLT32	rt_type_error-0x4
    2bc0:	jmp    2d78 <botlish_fn_37+0x248>
    2bc5:	mov    rdx,r15
    2bc8:	mov    rdi,r14
    2bcb:	call   2bd0 <botlish_fn_37+0xa0>
			2bcc: R_X86_64_PLT32	rt_mutarray_get-0x4
    2bd0:	mov    rcx,rax
    2bd3:	mov    QWORD PTR [rsp+0x18],rax
    2bd8:	test   rax,rcx
    2bdb:	je     2d78 <botlish_fn_37+0x248>
    2be1:	mov    rax,QWORD PTR [rsp+0x18]
    2be6:	test   rax,0x1
    2bec:	jne    2c17 <botlish_fn_37+0xe7>
    2bf2:	mov    edx,0x1
    2bf7:	mov    rsi,QWORD PTR [rsp+0x18]
    2bfc:	mov    rdi,r14
    2bff:	call   2c04 <botlish_fn_37+0xd4>
			2c00: R_X86_64_PLT32	rt_value_eq-0x4
    2c04:	test   rax,rax
    2c07:	je     2d78 <botlish_fn_37+0x248>
    2c0d:	mov    rcx,QWORD PTR [rsp+0x18]
    2c12:	jmp    2c2d <botlish_fn_37+0xfd>
    2c17:	mov    eax,0x2
    2c1c:	mov    rcx,QWORD PTR [rsp+0x18]
    2c21:	cmp    rcx,0x1
    2c25:	cmove  rax,QWORD PTR [rip+0x1db]        # 2e08 <botlish_fn_37+0x2d8>
    2c2d:	mov    ebx,0x6
    2c32:	cmp    rax,0x6
    2c36:	je     2dd8 <botlish_fn_37+0x2a8>
    2c3c:	test   rcx,0x1
    2c43:	mov    QWORD PTR [rsp+0x18],rcx
    2c48:	jne    2c6e <botlish_fn_37+0x13e>
    2c4e:	mov    edx,0x3
    2c53:	mov    rsi,QWORD PTR [rsp+0x18]
    2c58:	mov    rdi,r14
    2c5b:	call   2c60 <botlish_fn_37+0x130>
			2c5c: R_X86_64_PLT32	rt_value_eq-0x4
    2c60:	test   rax,rax
    2c63:	je     2d78 <botlish_fn_37+0x248>
    2c69:	jmp    2c84 <botlish_fn_37+0x154>
    2c6e:	mov    rsi,QWORD PTR [rsp+0x18]
    2c73:	mov    eax,0x2
    2c78:	cmp    rsi,0x3
    2c7c:	cmove  rax,QWORD PTR [rip+0x184]        # 2e08 <botlish_fn_37+0x2d8>
    2c84:	cmp    rax,0x6
    2c88:	je     2c98 <botlish_fn_37+0x168>
    2c8e:	mov    ebx,0x2
    2c93:	jmp    2d57 <botlish_fn_37+0x227>
    2c98:	mov    rsi,r12
    2c9b:	mov    rdi,r14
    2c9e:	call   2ca3 <botlish_fn_37+0x173>
			2c9f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2ca3:	test   rax,rax
    2ca6:	je     2d78 <botlish_fn_37+0x248>
    2cac:	xor    r10d,r10d
    2caf:	test   rax,0x7
    2cb5:	je     2cc3 <botlish_fn_37+0x193>
    2cbb:	mov    rsi,rax
    2cbe:	jmp    2cd2 <botlish_fn_37+0x1a2>
    2cc3:	movzx  rcx,BYTE PTR [rax]
    2cc7:	mov    rsi,rax
    2cca:	rex cmp cl,0x8
    2cce:	sete   r10b
    2cd2:	test   r10b,r10b
    2cd5:	jne    2cf5 <botlish_fn_37+0x1c5>
    2cdb:	mov    rdi,r14
    2cde:	mov    rax,QWORD PTR [rdi+0x10]
    2ce2:	mov    rcx,QWORD PTR [rax+0x30]
    2ce6:	mov    edx,0x8
    2ceb:	call   2cf0 <botlish_fn_37+0x1c0>
			2cec: R_X86_64_PLT32	rt_type_error-0x4
    2cf0:	jmp    2d78 <botlish_fn_37+0x248>
    2cf5:	mov    rdx,r15
    2cf8:	mov    rdi,r14
    2cfb:	call   2d00 <botlish_fn_37+0x1d0>
			2cfc: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d00:	test   rax,rax
    2d03:	je     2d78 <botlish_fn_37+0x248>
    2d09:	mov    rcx,rax
    2d0c:	and    rcx,r13
    2d0f:	mov    rsi,rax
    2d12:	test   rcx,0x1
    2d19:	jne    2d38 <botlish_fn_37+0x208>
    2d1f:	mov    rdx,r13
    2d22:	mov    rdi,r14
    2d25:	call   2d2a <botlish_fn_37+0x1fa>
			2d26: R_X86_64_PLT32	rt_value_eq-0x4
    2d2a:	test   rax,rax
    2d2d:	je     2d78 <botlish_fn_37+0x248>
    2d33:	jmp    2d48 <botlish_fn_37+0x218>
    2d38:	mov    eax,0x2
    2d3d:	cmp    rsi,r13
    2d40:	cmove  rax,QWORD PTR [rip+0xc0]        # 2e08 <botlish_fn_37+0x2d8>
    2d48:	cmp    rax,0x6
    2d4c:	je     2d57 <botlish_fn_37+0x227>
    2d52:	mov    ebx,0x2
    2d57:	cmp    rbx,0x6
    2d5b:	je     2db3 <botlish_fn_37+0x283>
    2d61:	mov    rdx,r15
    2d64:	mov    rsi,r12
    2d67:	mov    rdi,r14
    2d6a:	call   2d6f <botlish_fn_37+0x23f>
			2d6b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2d6f:	test   rax,rax
    2d72:	jne    2d9d <botlish_fn_37+0x26d>
    2d78:	xor    rax,rax
    2d7b:	mov    rbx,QWORD PTR [rsp+0x20]
    2d80:	mov    r12,QWORD PTR [rsp+0x28]
    2d85:	mov    r13,QWORD PTR [rsp+0x30]
    2d8a:	mov    r14,QWORD PTR [rsp+0x38]
    2d8f:	mov    r15,QWORD PTR [rsp+0x40]
    2d94:	add    rsp,0x50
    2d98:	mov    rsp,rbp
    2d9b:	pop    rbp
    2d9c:	ret
    2d9d:	mov    QWORD PTR [rsp],r12
    2da1:	mov    QWORD PTR [rsp+0x8],r13
    2da6:	mov    QWORD PTR [rsp+0x10],rax
    2dab:	mov    r15,rax
    2dae:	jmp    2b6b <botlish_fn_37+0x3b>
    2db3:	mov    rax,r15
    2db6:	mov    rbx,QWORD PTR [rsp+0x20]
    2dbb:	mov    r12,QWORD PTR [rsp+0x28]
    2dc0:	mov    r13,QWORD PTR [rsp+0x30]
    2dc5:	mov    r14,QWORD PTR [rsp+0x38]
    2dca:	mov    r15,QWORD PTR [rsp+0x40]
    2dcf:	add    rsp,0x50
    2dd3:	mov    rsp,rbp
    2dd6:	pop    rbp
    2dd7:	ret
    2dd8:	mov    rax,0xffffffffffffffff
    2ddf:	mov    rbx,QWORD PTR [rsp+0x20]
    2de4:	mov    r12,QWORD PTR [rsp+0x28]
    2de9:	mov    r13,QWORD PTR [rsp+0x30]
    2dee:	mov    r14,QWORD PTR [rsp+0x38]
    2df3:	mov    r15,QWORD PTR [rsp+0x40]
    2df8:	add    rsp,0x50
    2dfc:	mov    rsp,rbp
    2dff:	pop    rbp
    2e00:	ret
    2e01:	add    BYTE PTR [rax],al
    2e03:	add    BYTE PTR [rax],al
    2e05:	add    BYTE PTR [rax],al
    2e07:	add    BYTE PTR [rsi],al
    2e09:	add    BYTE PTR [rax],al
    2e0b:	add    BYTE PTR [rax],al
    2e0d:	add    BYTE PTR [rax],al
	...

0000000000002e10 <botlish_entry_37: ht_find_get<mutarray, str, int>>:
    2e10:	push   rbp
    2e11:	mov    rbp,rsp
    2e14:	mov    rsi,QWORD PTR [rdx]
    2e17:	mov    r8,QWORD PTR [rdx+0x8]
    2e1b:	mov    rcx,QWORD PTR [rdx+0x10]
    2e1f:	mov    rdx,r8
    2e22:	call   2e27 <botlish_entry_37+0x17>
			2e23: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    2e27:	mov    rsp,rbp
    2e2a:	pop    rbp
    2e2b:	ret
    2e2c:	add    BYTE PTR [rax],al
	...

0000000000002e30 <botlish_fn_38: ht_find_insert<mutarray, str, int, int>>:
    2e30:	push   rbp
    2e31:	mov    rbp,rsp
    2e34:	sub    rsp,0x60
    2e38:	mov    QWORD PTR [rsp+0x30],rbx
    2e3d:	mov    QWORD PTR [rsp+0x38],r12
    2e42:	mov    QWORD PTR [rsp+0x40],r13
    2e47:	mov    QWORD PTR [rsp+0x48],r14
    2e4c:	mov    QWORD PTR [rsp+0x50],r15
    2e51:	mov    r15,rdi
    2e54:	mov    QWORD PTR [rsp],rsi
    2e58:	mov    QWORD PTR [rsp+0x8],rdx
    2e5d:	mov    r13,rdx
    2e60:	mov    QWORD PTR [rsp+0x10],rcx
    2e65:	mov    QWORD PTR [rsp+0x18],r8
    2e6a:	mov    rbx,rsi
    2e6d:	mov    QWORD PTR [rsp+0x20],rcx
    2e72:	mov    QWORD PTR [rsp+0x28],r8
    2e77:	mov    rsi,rbx
    2e7a:	mov    rdi,r15
    2e7d:	call   2e82 <botlish_fn_38+0x52>
			2e7e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2e82:	test   rax,rax
    2e85:	je     317d <botlish_fn_38+0x34d>
    2e8b:	xor    ecx,ecx
    2e8d:	test   rax,0x7
    2e93:	je     2ea1 <botlish_fn_38+0x71>
    2e99:	mov    rsi,rax
    2e9c:	jmp    2eaf <botlish_fn_38+0x7f>
    2ea1:	movzx  rcx,BYTE PTR [rax]
    2ea5:	mov    rsi,rax
    2ea8:	rex cmp cl,0x8
    2eac:	sete   cl
    2eaf:	test   cl,cl
    2eb1:	jne    2ed1 <botlish_fn_38+0xa1>
    2eb7:	mov    rdi,r15
    2eba:	mov    rax,QWORD PTR [rdi+0x10]
    2ebe:	mov    rcx,QWORD PTR [rax+0x30]
    2ec2:	mov    edx,0x8
    2ec7:	call   2ecc <botlish_fn_38+0x9c>
			2ec8: R_X86_64_PLT32	rt_type_error-0x4
    2ecc:	jmp    317d <botlish_fn_38+0x34d>
    2ed1:	mov    rdx,QWORD PTR [rsp+0x20]
    2ed6:	mov    rdi,r15
    2ed9:	call   2ede <botlish_fn_38+0xae>
			2eda: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ede:	mov    rsi,rax
    2ee1:	mov    r14,rax
    2ee4:	test   rax,rsi
    2ee7:	je     317d <botlish_fn_38+0x34d>
    2eed:	mov    rax,r14
    2ef0:	test   rax,0x1
    2ef6:	jne    2f1a <botlish_fn_38+0xea>
    2efc:	mov    edx,0x1
    2f01:	mov    rsi,r14
    2f04:	mov    rdi,r15
    2f07:	call   2f0c <botlish_fn_38+0xdc>
			2f08: R_X86_64_PLT32	rt_value_eq-0x4
    2f0c:	test   rax,rax
    2f0f:	je     317d <botlish_fn_38+0x34d>
    2f15:	jmp    2f2e <botlish_fn_38+0xfe>
    2f1a:	mov    eax,0x2
    2f1f:	mov    rcx,r14
    2f22:	cmp    rcx,0x1
    2f26:	cmove  rax,QWORD PTR [rip+0x372]        # 32a0 <botlish_fn_38+0x470>
    2f2e:	mov    r12d,0x6
    2f34:	cmp    rax,0x6
    2f38:	je     31f5 <botlish_fn_38+0x3c5>
    2f3e:	mov    rax,r14
    2f41:	test   rax,0x1
    2f47:	jne    2f6b <botlish_fn_38+0x13b>
    2f4d:	mov    edx,0x3
    2f52:	mov    rsi,r14
    2f55:	mov    rdi,r15
    2f58:	call   2f5d <botlish_fn_38+0x12d>
			2f59: R_X86_64_PLT32	rt_value_eq-0x4
    2f5d:	test   rax,rax
    2f60:	je     317d <botlish_fn_38+0x34d>
    2f66:	jmp    2f7f <botlish_fn_38+0x14f>
    2f6b:	mov    eax,0x2
    2f70:	mov    rcx,r14
    2f73:	cmp    rcx,0x3
    2f77:	cmove  rax,QWORD PTR [rip+0x321]        # 32a0 <botlish_fn_38+0x470>
    2f7f:	cmp    rax,0x6
    2f83:	je     2f94 <botlish_fn_38+0x164>
    2f89:	mov    r11d,0x2
    2f8f:	jmp    305e <botlish_fn_38+0x22e>
    2f94:	mov    rsi,rbx
    2f97:	mov    rdi,r15
    2f9a:	call   2f9f <botlish_fn_38+0x16f>
			2f9b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2f9f:	test   rax,rax
    2fa2:	je     317d <botlish_fn_38+0x34d>
    2fa8:	xor    ecx,ecx
    2faa:	test   rax,0x7
    2fb0:	je     2fbe <botlish_fn_38+0x18e>
    2fb6:	mov    rsi,rax
    2fb9:	jmp    2fcc <botlish_fn_38+0x19c>
    2fbe:	movzx  rcx,BYTE PTR [rax]
    2fc2:	mov    rsi,rax
    2fc5:	rex cmp cl,0x8
    2fc9:	sete   cl
    2fcc:	test   cl,cl
    2fce:	jne    2fee <botlish_fn_38+0x1be>
    2fd4:	mov    rdi,r15
    2fd7:	mov    rcx,QWORD PTR [rdi+0x10]
    2fdb:	mov    rcx,QWORD PTR [rcx+0x30]
    2fdf:	mov    edx,0x8
    2fe4:	call   2fe9 <botlish_fn_38+0x1b9>
			2fe5: R_X86_64_PLT32	rt_type_error-0x4
    2fe9:	jmp    317d <botlish_fn_38+0x34d>
    2fee:	mov    rdx,QWORD PTR [rsp+0x20]
    2ff3:	mov    rdi,r15
    2ff6:	call   2ffb <botlish_fn_38+0x1cb>
			2ff7: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ffb:	test   rax,rax
    2ffe:	je     317d <botlish_fn_38+0x34d>
    3004:	mov    rsi,rax
    3007:	and    rsi,r13
    300a:	test   rsi,0x1
    3011:	jne    3033 <botlish_fn_38+0x203>
    3017:	mov    rsi,rax
    301a:	mov    rdx,r13
    301d:	mov    rdi,r15
    3020:	call   3025 <botlish_fn_38+0x1f5>
			3021: R_X86_64_PLT32	rt_value_eq-0x4
    3025:	test   rax,rax
    3028:	je     317d <botlish_fn_38+0x34d>
    302e:	jmp    3046 <botlish_fn_38+0x216>
    3033:	mov    rsi,rax
    3036:	mov    eax,0x2
    303b:	cmp    rsi,r13
    303e:	cmove  rax,QWORD PTR [rip+0x25a]        # 32a0 <botlish_fn_38+0x470>
    3046:	cmp    rax,0x6
    304a:	je     305b <botlish_fn_38+0x22b>
    3050:	mov    r11d,0x2
    3056:	jmp    305e <botlish_fn_38+0x22e>
    305b:	mov    r11,r12
    305e:	cmp    r11,0x6
    3062:	je     31ce <botlish_fn_38+0x39e>
    3068:	mov    rax,r14
    306b:	test   rax,0x1
    3071:	jne    3095 <botlish_fn_38+0x265>
    3077:	mov    edx,0x5
    307c:	mov    rsi,r14
    307f:	mov    rdi,r15
    3082:	call   3087 <botlish_fn_38+0x257>
			3083: R_X86_64_PLT32	rt_value_eq-0x4
    3087:	test   rax,rax
    308a:	je     317d <botlish_fn_38+0x34d>
    3090:	jmp    30a9 <botlish_fn_38+0x279>
    3095:	mov    rsi,r14
    3098:	mov    eax,0x2
    309d:	cmp    rsi,0x5
    30a1:	cmove  rax,QWORD PTR [rip+0x1f7]        # 32a0 <botlish_fn_38+0x470>
    30a9:	cmp    rax,0x6
    30ad:	je     30be <botlish_fn_38+0x28e>
    30b3:	mov    r12d,0x2
    30b9:	jmp    311f <botlish_fn_38+0x2ef>
    30be:	mov    r14,QWORD PTR [rsp+0x28]
    30c3:	test   r14,0x1
    30ca:	jne    30fa <botlish_fn_38+0x2ca>
    30d0:	mov    edx,0x1
    30d5:	mov    rsi,r14
    30d8:	mov    rdi,r15
    30db:	call   30e0 <botlish_fn_38+0x2b0>
			30dc: R_X86_64_PLT32	rt_int_cmp-0x4
    30e0:	mov    ecx,0x2
    30e5:	test   rax,rax
    30e8:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 32a0 <botlish_fn_38+0x470>
    30f0:	mov    QWORD PTR [rsp+0x28],r14
    30f5:	jmp    310f <botlish_fn_38+0x2df>
    30fa:	mov    ecx,0x2
    30ff:	test   r14,r14
    3102:	mov    QWORD PTR [rsp+0x28],r14
    3107:	cmovle rcx,QWORD PTR [rip+0x191]        # 32a0 <botlish_fn_38+0x470>
    310f:	cmp    rcx,0x6
    3113:	je     311f <botlish_fn_38+0x2ef>
    3119:	mov    r12d,0x2
    311f:	cmp    r12,0x6
    3123:	je     3164 <botlish_fn_38+0x334>
    3129:	mov    rdx,QWORD PTR [rsp+0x20]
    312e:	mov    rsi,rbx
    3131:	mov    rdi,r15
    3134:	call   3139 <botlish_fn_38+0x309>
			3135: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    3139:	test   rax,rax
    313c:	je     317d <botlish_fn_38+0x34d>
    3142:	mov    QWORD PTR [rsp],rbx
    3146:	mov    QWORD PTR [rsp+0x8],r13
    314b:	mov    QWORD PTR [rsp+0x10],rax
    3150:	mov    r11,QWORD PTR [rsp+0x28]
    3155:	mov    QWORD PTR [rsp+0x18],r11
    315a:	mov    QWORD PTR [rsp+0x20],rax
    315f:	jmp    2e77 <botlish_fn_38+0x47>
    3164:	mov    rdx,QWORD PTR [rsp+0x20]
    3169:	mov    rsi,rbx
    316c:	mov    rdi,r15
    316f:	call   3174 <botlish_fn_38+0x344>
			3170: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    3174:	test   rax,rax
    3177:	jne    31a2 <botlish_fn_38+0x372>
    317d:	xor    rax,rax
    3180:	mov    rbx,QWORD PTR [rsp+0x30]
    3185:	mov    r12,QWORD PTR [rsp+0x38]
    318a:	mov    r13,QWORD PTR [rsp+0x40]
    318f:	mov    r14,QWORD PTR [rsp+0x48]
    3194:	mov    r15,QWORD PTR [rsp+0x50]
    3199:	add    rsp,0x60
    319d:	mov    rsp,rbp
    31a0:	pop    rbp
    31a1:	ret
    31a2:	mov    QWORD PTR [rsp],rbx
    31a6:	mov    QWORD PTR [rsp+0x8],r13
    31ab:	mov    QWORD PTR [rsp+0x10],rax
    31b0:	mov    rdx,QWORD PTR [rsp+0x20]
    31b5:	mov    QWORD PTR [rsp+0x18],rdx
    31ba:	mov    rcx,QWORD PTR [rsp+0x20]
    31bf:	mov    QWORD PTR [rsp+0x28],rcx
    31c4:	mov    QWORD PTR [rsp+0x20],rax
    31c9:	jmp    2e77 <botlish_fn_38+0x47>
    31ce:	mov    rax,QWORD PTR [rsp+0x20]
    31d3:	mov    rbx,QWORD PTR [rsp+0x30]
    31d8:	mov    r12,QWORD PTR [rsp+0x38]
    31dd:	mov    r13,QWORD PTR [rsp+0x40]
    31e2:	mov    r14,QWORD PTR [rsp+0x48]
    31e7:	mov    r15,QWORD PTR [rsp+0x50]
    31ec:	add    rsp,0x60
    31f0:	mov    rsp,rbp
    31f3:	pop    rbp
    31f4:	ret
    31f5:	mov    rax,QWORD PTR [rsp+0x28]
    31fa:	test   rax,0x1
    3200:	jne    322d <botlish_fn_38+0x3fd>
    3206:	mov    edx,0x1
    320b:	mov    rdi,r15
    320e:	mov    rsi,QWORD PTR [rsp+0x28]
    3213:	call   3218 <botlish_fn_38+0x3e8>
			3214: R_X86_64_PLT32	rt_int_cmp-0x4
    3218:	mov    ecx,0x2
    321d:	test   rax,rax
    3220:	cmovge rcx,QWORD PTR [rip+0x78]        # 32a0 <botlish_fn_38+0x470>
    3228:	jmp    3247 <botlish_fn_38+0x417>
    322d:	mov    ecx,0x2
    3232:	mov    rax,QWORD PTR [rsp+0x28]
    3237:	mov    rdx,QWORD PTR [rsp+0x28]
    323c:	test   rax,rdx
    323f:	cmovg  rcx,QWORD PTR [rip+0x59]        # 32a0 <botlish_fn_38+0x470>
    3247:	cmp    rcx,0x6
    324b:	je     3278 <botlish_fn_38+0x448>
    3251:	mov    rax,QWORD PTR [rsp+0x20]
    3256:	mov    rbx,QWORD PTR [rsp+0x30]
    325b:	mov    r12,QWORD PTR [rsp+0x38]
    3260:	mov    r13,QWORD PTR [rsp+0x40]
    3265:	mov    r14,QWORD PTR [rsp+0x48]
    326a:	mov    r15,QWORD PTR [rsp+0x50]
    326f:	add    rsp,0x60
    3273:	mov    rsp,rbp
    3276:	pop    rbp
    3277:	ret
    3278:	mov    rax,QWORD PTR [rsp+0x28]
    327d:	mov    rbx,QWORD PTR [rsp+0x30]
    3282:	mov    r12,QWORD PTR [rsp+0x38]
    3287:	mov    r13,QWORD PTR [rsp+0x40]
    328c:	mov    r14,QWORD PTR [rsp+0x48]
    3291:	mov    r15,QWORD PTR [rsp+0x50]
    3296:	add    rsp,0x60
    329a:	mov    rsp,rbp
    329d:	pop    rbp
    329e:	ret
    329f:	add    BYTE PTR [rsi],al
    32a1:	add    BYTE PTR [rax],al
    32a3:	add    BYTE PTR [rax],al
    32a5:	add    BYTE PTR [rax],al
	...

00000000000032a8 <botlish_entry_38: ht_find_insert<mutarray, str, int, int>>:
    32a8:	push   rbp
    32a9:	mov    rbp,rsp
    32ac:	mov    rsi,QWORD PTR [rdx]
    32af:	mov    r9,QWORD PTR [rdx+0x8]
    32b3:	mov    rcx,QWORD PTR [rdx+0x10]
    32b7:	mov    r8,QWORD PTR [rdx+0x18]
    32bb:	mov    rdx,r9
    32be:	call   32c3 <botlish_entry_38+0x1b>
			32bf: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    32c3:	mov    rsp,rbp
    32c6:	pop    rbp
    32c7:	ret

00000000000032c8 <botlish_fn_39: ht_get<mutarray, str>>:
    32c8:	push   rbp
    32c9:	mov    rbp,rsp
    32cc:	sub    rsp,0x40
    32d0:	mov    QWORD PTR [rsp+0x20],rbx
    32d5:	mov    QWORD PTR [rsp+0x28],r12
    32da:	mov    QWORD PTR [rsp+0x30],r13
    32df:	mov    rbx,rdi
    32e2:	mov    QWORD PTR [rsp],rsi
    32e6:	mov    r13,rsi
    32e9:	mov    QWORD PTR [rsp+0x8],rdx
    32ee:	mov    r12,rdx
    32f1:	mov    rdx,r12
    32f4:	mov    rsi,r13
    32f7:	mov    rdi,rbx
    32fa:	call   32ff <botlish_fn_39+0x37>
			32fb: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    32ff:	test   rax,rax
    3302:	je     33ec <botlish_fn_39+0x124>
    3308:	mov    QWORD PTR [rsp+0x10],rax
    330d:	mov    rcx,rax
    3310:	mov    rdx,r12
    3313:	mov    rsi,r13
    3316:	mov    rdi,rbx
    3319:	call   331e <botlish_fn_39+0x56>
			331a: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    331e:	mov    rcx,rax
    3321:	mov    r12,rax
    3324:	test   rax,rcx
    3327:	je     33ec <botlish_fn_39+0x124>
    332d:	mov    rax,r12
    3330:	test   rax,0x1
    3336:	jne    3361 <botlish_fn_39+0x99>
    333c:	mov    edx,0x1
    3341:	mov    rsi,r12
    3344:	mov    rdi,rbx
    3347:	call   334c <botlish_fn_39+0x84>
			3348: R_X86_64_PLT32	rt_int_cmp-0x4
    334c:	mov    ecx,0x2
    3351:	test   rax,rax
    3354:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 3440 <botlish_fn_39+0x178>
    335c:	jmp    3374 <botlish_fn_39+0xac>
    3361:	mov    ecx,0x2
    3366:	mov    rax,r12
    3369:	test   rax,rax
    336c:	cmovle rcx,QWORD PTR [rip+0xcc]        # 3440 <botlish_fn_39+0x178>
    3374:	cmp    rcx,0x6
    3378:	je     341f <botlish_fn_39+0x157>
    337e:	mov    rsi,r13
    3381:	mov    rdi,rbx
    3384:	call   3389 <botlish_fn_39+0xc1>
			3385: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3389:	test   rax,rax
    338c:	je     33ec <botlish_fn_39+0x124>
    3392:	xor    ecx,ecx
    3394:	test   rax,0x7
    339a:	je     33a8 <botlish_fn_39+0xe0>
    33a0:	mov    rsi,rax
    33a3:	jmp    33b6 <botlish_fn_39+0xee>
    33a8:	movzx  rcx,BYTE PTR [rax]
    33ac:	mov    rsi,rax
    33af:	rex cmp cl,0x8
    33b3:	sete   cl
    33b6:	test   cl,cl
    33b8:	jne    33d8 <botlish_fn_39+0x110>
    33be:	mov    rdi,rbx
    33c1:	mov    rax,QWORD PTR [rdi+0x10]
    33c5:	mov    rcx,QWORD PTR [rax+0x30]
    33c9:	mov    edx,0x8
    33ce:	call   33d3 <botlish_fn_39+0x10b>
			33cf: R_X86_64_PLT32	rt_type_error-0x4
    33d3:	jmp    33ec <botlish_fn_39+0x124>
    33d8:	mov    rdx,r12
    33db:	mov    rdi,rbx
    33de:	call   33e3 <botlish_fn_39+0x11b>
			33df: R_X86_64_PLT32	rt_mutarray_get-0x4
    33e3:	test   rax,rax
    33e6:	jne    3407 <botlish_fn_39+0x13f>
    33ec:	xor    rax,rax
    33ef:	mov    rbx,QWORD PTR [rsp+0x20]
    33f4:	mov    r12,QWORD PTR [rsp+0x28]
    33f9:	mov    r13,QWORD PTR [rsp+0x30]
    33fe:	add    rsp,0x40
    3402:	mov    rsp,rbp
    3405:	pop    rbp
    3406:	ret
    3407:	mov    rbx,QWORD PTR [rsp+0x20]
    340c:	mov    r12,QWORD PTR [rsp+0x28]
    3411:	mov    r13,QWORD PTR [rsp+0x30]
    3416:	add    rsp,0x40
    341a:	mov    rsp,rbp
    341d:	pop    rbp
    341e:	ret
    341f:	mov    eax,0xa
    3424:	mov    rbx,QWORD PTR [rsp+0x20]
    3429:	mov    r12,QWORD PTR [rsp+0x28]
    342e:	mov    r13,QWORD PTR [rsp+0x30]
    3433:	add    rsp,0x40
    3437:	mov    rsp,rbp
    343a:	pop    rbp
    343b:	ret
    343c:	add    BYTE PTR [rax],al
    343e:	add    BYTE PTR [rax],al
    3440:	(bad)
    3441:	add    BYTE PTR [rax],al
    3443:	add    BYTE PTR [rax],al
    3445:	add    BYTE PTR [rax],al
	...

0000000000003448 <botlish_entry_39: ht_get<mutarray, str>>:
    3448:	push   rbp
    3449:	mov    rbp,rsp
    344c:	mov    rsi,QWORD PTR [rdx]
    344f:	mov    rdx,QWORD PTR [rdx+0x8]
    3453:	call   3458 <botlish_entry_39+0x10>
			3454: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    3458:	mov    rsp,rbp
    345b:	pop    rbp
    345c:	ret
    345d:	add    BYTE PTR [rax],al
	...

0000000000003460 <botlish_fn_40: ht_rehash_probe<mutarray, int, int>>:
    3460:	push   rbp
    3461:	mov    rbp,rsp
    3464:	sub    rsp,0x40
    3468:	mov    QWORD PTR [rsp+0x20],rbx
    346d:	mov    QWORD PTR [rsp+0x28],r12
    3472:	mov    QWORD PTR [rsp+0x30],r13
    3477:	mov    QWORD PTR [rsp+0x38],r14
    347c:	mov    r13,rdi
    347f:	mov    QWORD PTR [rsp],rsi
    3483:	mov    QWORD PTR [rsp+0x8],rdx
    3488:	mov    QWORD PTR [rsp+0x10],rcx
    348d:	mov    r12,rcx
    3490:	mov    rbx,rsi
    3493:	mov    r14,rdx
    3496:	mov    rdx,r14
    3499:	mov    rsi,rbx
    349c:	mov    rdi,r13
    349f:	call   34a4 <botlish_fn_40+0x44>
			34a0: R_X86_64_PLT32	rt_mutarray_get-0x4
    34a4:	test   rax,rax
    34a7:	je     3544 <botlish_fn_40+0xe4>
    34ad:	test   rax,0x1
    34b3:	mov    rsi,rax
    34b6:	jne    34d7 <botlish_fn_40+0x77>
    34bc:	mov    edx,0x1
    34c1:	mov    rdi,r13
    34c4:	call   34c9 <botlish_fn_40+0x69>
			34c5: R_X86_64_PLT32	rt_value_eq-0x4
    34c9:	test   rax,rax
    34cc:	je     3544 <botlish_fn_40+0xe4>
    34d2:	jmp    34e8 <botlish_fn_40+0x88>
    34d7:	mov    eax,0x2
    34dc:	cmp    rsi,0x1
    34e0:	cmove  rax,QWORD PTR [rip+0xb8]        # 35a0 <botlish_fn_40+0x140>
    34e8:	cmp    rax,0x6
    34ec:	je     357a <botlish_fn_40+0x11a>
    34f2:	mov    QWORD PTR [rsp+0x18],0x3
    34fb:	mov    rsi,r14
    34fe:	test   rsi,0x1
    3505:	je     351d <botlish_fn_40+0xbd>
    350b:	mov    rsi,r14
    350e:	add    rsi,0x2
    3512:	seto   al
    3515:	test   al,al
    3517:	je     3530 <botlish_fn_40+0xd0>
    351d:	mov    edx,0x3
    3522:	mov    rsi,r14
    3525:	mov    rdi,r13
    3528:	call   352d <botlish_fn_40+0xcd>
			3529: R_X86_64_PLT32	rt_int_add-0x4
    352d:	mov    rsi,rax
    3530:	mov    rdx,r12
    3533:	mov    rdi,r13
    3536:	call   353b <botlish_fn_40+0xdb>
			3537: R_X86_64_PLT32	rt_int_mod-0x4
    353b:	test   rax,rax
    353e:	jne    3564 <botlish_fn_40+0x104>
    3544:	xor    rax,rax
    3547:	mov    rbx,QWORD PTR [rsp+0x20]
    354c:	mov    r12,QWORD PTR [rsp+0x28]
    3551:	mov    r13,QWORD PTR [rsp+0x30]
    3556:	mov    r14,QWORD PTR [rsp+0x38]
    355b:	add    rsp,0x40
    355f:	mov    rsp,rbp
    3562:	pop    rbp
    3563:	ret
    3564:	mov    QWORD PTR [rsp],rbx
    3568:	mov    QWORD PTR [rsp+0x8],rax
    356d:	mov    QWORD PTR [rsp+0x10],r12
    3572:	mov    r14,rax
    3575:	jmp    3496 <botlish_fn_40+0x36>
    357a:	mov    rax,r14
    357d:	mov    rbx,QWORD PTR [rsp+0x20]
    3582:	mov    r12,QWORD PTR [rsp+0x28]
    3587:	mov    r13,QWORD PTR [rsp+0x30]
    358c:	mov    r14,QWORD PTR [rsp+0x38]
    3591:	add    rsp,0x40
    3595:	mov    rsp,rbp
    3598:	pop    rbp
    3599:	ret
    359a:	add    BYTE PTR [rax],al
    359c:	add    BYTE PTR [rax],al
    359e:	add    BYTE PTR [rax],al
    35a0:	(bad)
    35a1:	add    BYTE PTR [rax],al
    35a3:	add    BYTE PTR [rax],al
    35a5:	add    BYTE PTR [rax],al
	...

00000000000035a8 <botlish_entry_40: ht_rehash_probe<mutarray, int, int>>:
    35a8:	push   rbp
    35a9:	mov    rbp,rsp
    35ac:	mov    rsi,QWORD PTR [rdx]
    35af:	mov    r8,QWORD PTR [rdx+0x8]
    35b3:	mov    rcx,QWORD PTR [rdx+0x10]
    35b7:	mov    rdx,r8
    35ba:	call   35bf <botlish_entry_40+0x17>
			35bb: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    35bf:	mov    rsp,rbp
    35c2:	pop    rbp
    35c3:	ret

00000000000035c4 <botlish_fn_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    35c4:	push   rbp
    35c5:	mov    rbp,rsp
    35c8:	sub    rsp,0x70
    35cc:	mov    QWORD PTR [rsp+0x40],rbx
    35d1:	mov    QWORD PTR [rsp+0x48],r12
    35d6:	mov    QWORD PTR [rsp+0x50],r13
    35db:	mov    QWORD PTR [rsp+0x58],r14
    35e0:	mov    QWORD PTR [rsp+0x60],r15
    35e5:	mov    r13,rdi
    35e8:	mov    QWORD PTR [rsp],rsi
    35ec:	mov    QWORD PTR [rsp+0x8],rdx
    35f1:	mov    r15,rdx
    35f4:	mov    QWORD PTR [rsp+0x10],rcx
    35f9:	mov    r14,rcx
    35fc:	mov    QWORD PTR [rsp+0x18],r8
    3601:	mov    r12,r8
    3604:	mov    rax,QWORD PTR [rsi+0x18]
    3608:	mov    rbx,rsi
    360b:	mov    rsi,QWORD PTR [rax]
    360e:	mov    QWORD PTR [rsp+0x20],rsi
    3613:	mov    QWORD PTR [rsp+0x30],rsi
    3618:	mov    rsi,r14
    361b:	mov    rdi,r13
    361e:	call   3623 <botlish_fn_41+0x5f>
			361f: R_X86_64_PLT32	rt_hash-0x4
    3623:	test   rax,rax
    3626:	mov    rsi,rax
    3629:	je     36c6 <botlish_fn_41+0x102>
    362f:	mov    rdx,r15
    3632:	mov    rdi,r13
    3635:	call   363a <botlish_fn_41+0x76>
			3636: R_X86_64_PLT32	rt_int_mod-0x4
    363a:	test   rax,rax
    363d:	je     36c6 <botlish_fn_41+0x102>
    3643:	mov    QWORD PTR [rsp+0x28],rax
    3648:	mov    rcx,r15
    364b:	mov    rdx,rax
    364e:	mov    rsi,QWORD PTR [rsp+0x30]
    3653:	mov    rdi,r13
    3656:	call   365b <botlish_fn_41+0x97>
			3657: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    365b:	mov    rcx,rax
    365e:	mov    r15,rax
    3661:	test   rax,rcx
    3664:	je     36c6 <botlish_fn_41+0x102>
    366a:	mov    ecx,0x3
    366f:	mov    rsi,QWORD PTR [rsp+0x30]
    3674:	mov    rdx,r15
    3677:	mov    rdi,r13
    367a:	call   367f <botlish_fn_41+0xbb>
			367b: R_X86_64_PLT32	rt_mutarray_set-0x4
    367f:	test   rax,rax
    3682:	je     36c6 <botlish_fn_41+0x102>
    3688:	mov    rax,QWORD PTR [rbx+0x18]
    368c:	mov    rsi,QWORD PTR [rax+0x8]
    3690:	mov    rcx,r14
    3693:	mov    rdx,r15
    3696:	mov    rdi,r13
    3699:	call   369e <botlish_fn_41+0xda>
			369a: R_X86_64_PLT32	rt_mutarray_set-0x4
    369e:	test   rax,rax
    36a1:	je     36c6 <botlish_fn_41+0x102>
    36a7:	mov    rax,QWORD PTR [rbx+0x18]
    36ab:	mov    rsi,QWORD PTR [rax+0x10]
    36af:	mov    rcx,r12
    36b2:	mov    rdx,r15
    36b5:	mov    rdi,r13
    36b8:	call   36bd <botlish_fn_41+0xf9>
			36b9: R_X86_64_PLT32	rt_mutarray_set-0x4
    36bd:	test   rax,rax
    36c0:	jne    36eb <botlish_fn_41+0x127>
    36c6:	xor    rax,rax
    36c9:	mov    rbx,QWORD PTR [rsp+0x40]
    36ce:	mov    r12,QWORD PTR [rsp+0x48]
    36d3:	mov    r13,QWORD PTR [rsp+0x50]
    36d8:	mov    r14,QWORD PTR [rsp+0x58]
    36dd:	mov    r15,QWORD PTR [rsp+0x60]
    36e2:	add    rsp,0x70
    36e6:	mov    rsp,rbp
    36e9:	pop    rbp
    36ea:	ret
    36eb:	mov    eax,0xa
    36f0:	mov    rbx,QWORD PTR [rsp+0x40]
    36f5:	mov    r12,QWORD PTR [rsp+0x48]
    36fa:	mov    r13,QWORD PTR [rsp+0x50]
    36ff:	mov    r14,QWORD PTR [rsp+0x58]
    3704:	mov    r15,QWORD PTR [rsp+0x60]
    3709:	add    rsp,0x70
    370d:	mov    rsp,rbp
    3710:	pop    rbp
    3711:	ret

0000000000003712 <botlish_entry_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    3712:	push   rbp
    3713:	mov    rbp,rsp
    3716:	mov    rsi,QWORD PTR [rdx]
    3719:	mov    r9,QWORD PTR [rdx+0x8]
    371d:	mov    rcx,QWORD PTR [rdx+0x10]
    3721:	mov    r8,QWORD PTR [rdx+0x18]
    3725:	mov    rdx,r9
    3728:	call   372d <botlish_entry_41+0x1b>
			3729: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    372d:	mov    rsp,rbp
    3730:	pop    rbp
    3731:	ret
    3732:	add    BYTE PTR [rax],al
    3734:	add    BYTE PTR [rax],al
	...

0000000000003738 <botlish_fn_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3738:	push   rbp
    3739:	mov    rbp,rsp
    373c:	sub    rsp,0x70
    3740:	mov    QWORD PTR [rsp+0x40],rbx
    3745:	mov    QWORD PTR [rsp+0x48],r12
    374a:	mov    QWORD PTR [rsp+0x50],r13
    374f:	mov    QWORD PTR [rsp+0x58],r14
    3754:	mov    QWORD PTR [rsp+0x60],r15
    3759:	mov    QWORD PTR [rsp+0x28],rdi
    375e:	mov    QWORD PTR [rsp],rsi
    3762:	mov    QWORD PTR [rsp+0x8],r8
    3767:	mov    r13,r8
    376a:	mov    QWORD PTR [rsp+0x10],r9
    376f:	mov    r12,r9
    3772:	sar    rdx,1
    3775:	sar    rcx,1
    3778:	mov    rbx,rcx
    377b:	mov    r15,rdx
    377e:	cmp    r15,rbx
    3781:	jge    3982 <botlish_fn_42+0x24a>
    3787:	mov    r14,rsi
    378a:	mov    rcx,QWORD PTR [r14+0x18]
    378e:	mov    rsi,QWORD PTR [rcx]
    3791:	xor    eax,eax
    3793:	test   rsi,0x7
    379a:	jne    37ab <botlish_fn_42+0x73>
    37a0:	movzx  rdi,BYTE PTR [rsi]
    37a4:	cmp    dil,0x8
    37a8:	sete   al
    37ab:	test   al,al
    37ad:	jne    37cf <botlish_fn_42+0x97>
    37b3:	mov    rdi,QWORD PTR [rsp+0x28]
    37b8:	mov    r8,QWORD PTR [rdi+0x10]
    37bc:	mov    rcx,QWORD PTR [r8+0x30]
    37c0:	mov    edx,0x8
    37c5:	call   37ca <botlish_fn_42+0x92>
			37c6: R_X86_64_PLT32	rt_type_error-0x4
    37ca:	jmp    3937 <botlish_fn_42+0x1ff>
    37cf:	mov    rdx,r15
    37d2:	shl    rdx,1
    37d5:	or     rdx,0x1
    37d9:	mov    QWORD PTR [rsp+0x38],rdx
    37de:	mov    rdi,QWORD PTR [rsp+0x28]
    37e3:	call   37e8 <botlish_fn_42+0xb0>
			37e4: R_X86_64_PLT32	rt_mutarray_get-0x4
    37e8:	test   rax,rax
    37eb:	je     3937 <botlish_fn_42+0x1ff>
    37f1:	test   rax,0x1
    37f7:	mov    rsi,rax
    37fa:	jne    381d <botlish_fn_42+0xe5>
    3800:	mov    edx,0x3
    3805:	mov    rdi,QWORD PTR [rsp+0x28]
    380a:	call   380f <botlish_fn_42+0xd7>
			380b: R_X86_64_PLT32	rt_value_eq-0x4
    380f:	test   rax,rax
    3812:	je     3937 <botlish_fn_42+0x1ff>
    3818:	jmp    382e <botlish_fn_42+0xf6>
    381d:	mov    eax,0x2
    3822:	cmp    rsi,0x3
    3826:	cmove  rax,QWORD PTR [rip+0x182]        # 39b0 <botlish_fn_42+0x278>
    382e:	cmp    rax,0x6
    3832:	je     3846 <botlish_fn_42+0x10e>
    3838:	mov    rax,r12
    383b:	mov    r12,r13
    383e:	mov    r13,rax
    3841:	jmp    395c <botlish_fn_42+0x224>
    3846:	mov    rax,QWORD PTR [r14+0x18]
    384a:	mov    rsi,QWORD PTR [rax+0x8]
    384e:	xor    eax,eax
    3850:	test   rsi,0x7
    3857:	jne    3866 <botlish_fn_42+0x12e>
    385d:	movzx  rax,BYTE PTR [rsi]
    3861:	cmp    al,0x8
    3863:	sete   al
    3866:	test   al,al
    3868:	jne    388a <botlish_fn_42+0x152>
    386e:	mov    rdi,QWORD PTR [rsp+0x28]
    3873:	mov    rax,QWORD PTR [rdi+0x10]
    3877:	mov    rcx,QWORD PTR [rax+0x30]
    387b:	mov    edx,0x8
    3880:	call   3885 <botlish_fn_42+0x14d>
			3881: R_X86_64_PLT32	rt_type_error-0x4
    3885:	jmp    3937 <botlish_fn_42+0x1ff>
    388a:	mov    rdx,QWORD PTR [rsp+0x38]
    388f:	mov    rdi,QWORD PTR [rsp+0x28]
    3894:	call   3899 <botlish_fn_42+0x161>
			3895: R_X86_64_PLT32	rt_mutarray_get-0x4
    3899:	test   rax,rax
    389c:	je     3937 <botlish_fn_42+0x1ff>
    38a2:	mov    QWORD PTR [rsp+0x18],rax
    38a7:	mov    QWORD PTR [rsp+0x30],rax
    38ac:	mov    rax,QWORD PTR [r14+0x18]
    38b0:	mov    rsi,QWORD PTR [rax+0x10]
    38b4:	xor    eax,eax
    38b6:	test   rsi,0x7
    38bd:	jne    38cc <botlish_fn_42+0x194>
    38c3:	movzx  rax,BYTE PTR [rsi]
    38c7:	cmp    al,0x8
    38c9:	sete   al
    38cc:	test   al,al
    38ce:	jne    38f0 <botlish_fn_42+0x1b8>
    38d4:	mov    rdi,QWORD PTR [rsp+0x28]
    38d9:	mov    rax,QWORD PTR [rdi+0x10]
    38dd:	mov    rcx,QWORD PTR [rax+0x30]
    38e1:	mov    edx,0x8
    38e6:	call   38eb <botlish_fn_42+0x1b3>
			38e7: R_X86_64_PLT32	rt_type_error-0x4
    38eb:	jmp    3937 <botlish_fn_42+0x1ff>
    38f0:	mov    rdx,QWORD PTR [rsp+0x38]
    38f5:	mov    rdi,QWORD PTR [rsp+0x28]
    38fa:	call   38ff <botlish_fn_42+0x1c7>
			38fb: R_X86_64_PLT32	rt_mutarray_get-0x4
    38ff:	test   rax,rax
    3902:	je     3937 <botlish_fn_42+0x1ff>
    3908:	mov    QWORD PTR [rsp+0x20],rax
    390d:	mov    r9,r12
    3910:	mov    r12,r13
    3913:	mov    r13,r9
    3916:	mov    r8,rax
    3919:	mov    rcx,QWORD PTR [rsp+0x30]
    391e:	mov    rdx,r13
    3921:	mov    rsi,r12
    3924:	mov    rdi,QWORD PTR [rsp+0x28]
    3929:	call   392e <botlish_fn_42+0x1f6>
			392a: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    392e:	test   rax,rax
    3931:	jne    395c <botlish_fn_42+0x224>
    3937:	xor    rax,rax
    393a:	mov    rbx,QWORD PTR [rsp+0x40]
    393f:	mov    r12,QWORD PTR [rsp+0x48]
    3944:	mov    r13,QWORD PTR [rsp+0x50]
    3949:	mov    r14,QWORD PTR [rsp+0x58]
    394e:	mov    r15,QWORD PTR [rsp+0x60]
    3953:	add    rsp,0x70
    3957:	mov    rsp,rbp
    395a:	pop    rbp
    395b:	ret
    395c:	mov    QWORD PTR [rsp],r14
    3960:	mov    QWORD PTR [rsp+0x8],r12
    3965:	mov    QWORD PTR [rsp+0x10],r13
    396a:	add    r15,0x1
    3971:	mov    rax,r12
    3974:	mov    r12,r13
    3977:	mov    r13,rax
    397a:	mov    rsi,r14
    397d:	jmp    377e <botlish_fn_42+0x46>
    3982:	mov    eax,0xa
    3987:	mov    rbx,QWORD PTR [rsp+0x40]
    398c:	mov    r12,QWORD PTR [rsp+0x48]
    3991:	mov    r13,QWORD PTR [rsp+0x50]
    3996:	mov    r14,QWORD PTR [rsp+0x58]
    399b:	mov    r15,QWORD PTR [rsp+0x60]
    39a0:	add    rsp,0x70
    39a4:	mov    rsp,rbp
    39a7:	pop    rbp
    39a8:	ret
    39a9:	add    BYTE PTR [rax],al
    39ab:	add    BYTE PTR [rax],al
    39ad:	add    BYTE PTR [rax],al
    39af:	add    BYTE PTR [rsi],al
    39b1:	add    BYTE PTR [rax],al
    39b3:	add    BYTE PTR [rax],al
    39b5:	add    BYTE PTR [rax],al
	...

00000000000039b8 <botlish_entry_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    39b8:	push   rbp
    39b9:	mov    rbp,rsp
    39bc:	mov    rsi,QWORD PTR [rdx]
    39bf:	mov    r10,QWORD PTR [rdx+0x8]
    39c3:	mov    rcx,QWORD PTR [rdx+0x10]
    39c7:	mov    r8,QWORD PTR [rdx+0x18]
    39cb:	mov    r9,QWORD PTR [rdx+0x20]
    39cf:	mov    rdx,r10
    39d2:	call   39d7 <botlish_entry_42+0x1f>
			39d3: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    39d7:	mov    rsp,rbp
    39da:	pop    rbp
    39db:	ret

00000000000039dc <botlish_fn_43: ht_rehash<mutarray, int>>:
    39dc:	push   rbp
    39dd:	mov    rbp,rsp
    39e0:	sub    rsp,0xb0
    39e7:	mov    QWORD PTR [rsp+0x80],rbx
    39ef:	mov    QWORD PTR [rsp+0x88],r12
    39f7:	mov    QWORD PTR [rsp+0x90],r13
    39ff:	mov    QWORD PTR [rsp+0x98],r14
    3a07:	mov    QWORD PTR [rsp+0xa0],r15
    3a0f:	mov    r13,rdi
    3a12:	mov    QWORD PTR [rsp+0x28],0x0
    3a1b:	mov    QWORD PTR [rsp+0x30],0x0
    3a24:	mov    QWORD PTR [rsp],rsi
    3a28:	mov    rbx,rsi
    3a2b:	mov    QWORD PTR [rsp+0x8],rdx
    3a30:	mov    r12,rdx
    3a33:	mov    rsi,rbx
    3a36:	mov    rdi,r13
    3a39:	call   3a3e <botlish_fn_43+0x62>
			3a3a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    3a3e:	test   rax,rax
    3a41:	je     3c3f <botlish_fn_43+0x263>
    3a47:	mov    QWORD PTR [rsp+0x10],rax
    3a4c:	mov    r14,rax
    3a4f:	mov    rsi,rbx
    3a52:	mov    rdi,r13
    3a55:	call   3a5a <botlish_fn_43+0x7e>
			3a56: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3a5a:	test   rax,rax
    3a5d:	je     3c3f <botlish_fn_43+0x263>
    3a63:	mov    QWORD PTR [rsp+0x18],rax
    3a68:	mov    r15,rax
    3a6b:	mov    rsi,rbx
    3a6e:	mov    rdi,r13
    3a71:	call   3a76 <botlish_fn_43+0x9a>
			3a72: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3a76:	test   rax,rax
    3a79:	je     3c3f <botlish_fn_43+0x263>
    3a7f:	mov    QWORD PTR [rsp+0x20],rax
    3a84:	lea    rcx,[rsp+0x38]
    3a89:	mov    rdx,r14
    3a8c:	mov    QWORD PTR [rsp+0x38],rdx
    3a91:	mov    rdx,r15
    3a94:	mov    QWORD PTR [rsp+0x40],rdx
    3a99:	mov    QWORD PTR [rsp+0x48],rax
    3a9e:	mov    esi,0x2
    3aa3:	mov    edx,0x3
    3aa8:	mov    rdi,r13
    3aab:	call   3ab0 <botlish_fn_43+0xd4>
			3aac: R_X86_64_PLT32	rt_struct_new-0x4
    3ab0:	mov    QWORD PTR [rsp+0x10],rax
    3ab5:	mov    r14,rax
    3ab8:	mov    rsi,rbx
    3abb:	mov    rdi,r13
    3abe:	call   3ac3 <botlish_fn_43+0xe7>
			3abf: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3ac3:	test   rax,rax
    3ac6:	je     3c3f <botlish_fn_43+0x263>
    3acc:	mov    QWORD PTR [rsp+0x18],rax
    3ad1:	mov    r15,rax
    3ad4:	mov    rsi,r12
    3ad7:	mov    rdi,r13
    3ada:	call   3adf <botlish_fn_43+0x103>
			3adb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3adf:	test   rax,rax
    3ae2:	je     3c3f <botlish_fn_43+0x263>
    3ae8:	mov    QWORD PTR [rsp+0x20],rax
    3aed:	mov    QWORD PTR [rsp+0x70],rax
    3af2:	mov    edx,0x1
    3af7:	mov    QWORD PTR [rsp+0x28],0x1
    3b00:	mov    rcx,r12
    3b03:	mov    rsi,QWORD PTR [rsp+0x70]
    3b08:	mov    rdi,r13
    3b0b:	call   3b10 <botlish_fn_43+0x134>
			3b0c: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3b10:	test   rax,rax
    3b13:	je     3c3f <botlish_fn_43+0x263>
    3b19:	mov    rsi,r12
    3b1c:	mov    rdi,r13
    3b1f:	call   3b24 <botlish_fn_43+0x148>
			3b20: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b24:	test   rax,rax
    3b27:	je     3c3f <botlish_fn_43+0x263>
    3b2d:	mov    QWORD PTR [rsp+0x28],rax
    3b32:	mov    QWORD PTR [rsp+0x68],rax
    3b37:	mov    rsi,r12
    3b3a:	mov    rdi,r13
    3b3d:	call   3b42 <botlish_fn_43+0x166>
			3b3e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b42:	test   rax,rax
    3b45:	je     3c3f <botlish_fn_43+0x263>
    3b4b:	mov    QWORD PTR [rsp+0x30],rax
    3b50:	lea    rcx,[rsp+0x50]
    3b55:	mov    rdx,QWORD PTR [rsp+0x70]
    3b5a:	mov    QWORD PTR [rsp+0x50],rdx
    3b5f:	mov    rdx,QWORD PTR [rsp+0x68]
    3b64:	mov    QWORD PTR [rsp+0x58],rdx
    3b69:	mov    QWORD PTR [rsp+0x60],rax
    3b6e:	mov    esi,0x2
    3b73:	mov    edx,0x3
    3b78:	mov    rdi,r13
    3b7b:	call   3b80 <botlish_fn_43+0x1a4>
			3b7c: R_X86_64_PLT32	rt_struct_new-0x4
    3b80:	mov    QWORD PTR [rsp+0x20],rax
    3b85:	mov    QWORD PTR [rsp+0x68],rax
    3b8a:	mov    edx,0x1
    3b8f:	mov    QWORD PTR [rsp+0x28],0x1
    3b98:	mov    rcx,r15
    3b9b:	mov    rsi,r14
    3b9e:	mov    r9,r12
    3ba1:	mov    rdi,r13
    3ba4:	mov    r8,QWORD PTR [rsp+0x68]
    3ba9:	call   3bae <botlish_fn_43+0x1d2>
			3baa: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3bae:	test   rax,rax
    3bb1:	je     3c3f <botlish_fn_43+0x263>
    3bb7:	mov    r12,QWORD PTR [rsp+0x68]
    3bbc:	mov    rcx,QWORD PTR [r12+0x18]
    3bc1:	mov    rcx,QWORD PTR [rcx]
    3bc4:	mov    edx,0x1
    3bc9:	mov    rsi,rbx
    3bcc:	mov    rdi,r13
    3bcf:	call   3bd4 <botlish_fn_43+0x1f8>
			3bd0: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bd4:	test   rax,rax
    3bd7:	je     3c3f <botlish_fn_43+0x263>
    3bdd:	mov    rax,QWORD PTR [r12+0x18]
    3be2:	mov    rcx,QWORD PTR [rax+0x8]
    3be6:	mov    edx,0x3
    3beb:	mov    rsi,rbx
    3bee:	mov    rdi,r13
    3bf1:	call   3bf6 <botlish_fn_43+0x21a>
			3bf2: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bf6:	test   rax,rax
    3bf9:	je     3c3f <botlish_fn_43+0x263>
    3bff:	mov    rax,QWORD PTR [r12+0x18]
    3c04:	mov    rcx,QWORD PTR [rax+0x10]
    3c08:	mov    edx,0x5
    3c0d:	mov    rsi,rbx
    3c10:	mov    rdi,r13
    3c13:	call   3c18 <botlish_fn_43+0x23c>
			3c14: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c18:	test   rax,rax
    3c1b:	je     3c3f <botlish_fn_43+0x263>
    3c21:	mov    edx,0x9
    3c26:	mov    ecx,0x1
    3c2b:	mov    rsi,rbx
    3c2e:	mov    rdi,r13
    3c31:	call   3c36 <botlish_fn_43+0x25a>
			3c32: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c36:	test   rax,rax
    3c39:	jne    3c76 <botlish_fn_43+0x29a>
    3c3f:	xor    rax,rax
    3c42:	mov    rbx,QWORD PTR [rsp+0x80]
    3c4a:	mov    r12,QWORD PTR [rsp+0x88]
    3c52:	mov    r13,QWORD PTR [rsp+0x90]
    3c5a:	mov    r14,QWORD PTR [rsp+0x98]
    3c62:	mov    r15,QWORD PTR [rsp+0xa0]
    3c6a:	add    rsp,0xb0
    3c71:	mov    rsp,rbp
    3c74:	pop    rbp
    3c75:	ret
    3c76:	mov    eax,0xa
    3c7b:	mov    rbx,QWORD PTR [rsp+0x80]
    3c83:	mov    r12,QWORD PTR [rsp+0x88]
    3c8b:	mov    r13,QWORD PTR [rsp+0x90]
    3c93:	mov    r14,QWORD PTR [rsp+0x98]
    3c9b:	mov    r15,QWORD PTR [rsp+0xa0]
    3ca3:	add    rsp,0xb0
    3caa:	mov    rsp,rbp
    3cad:	pop    rbp
    3cae:	ret

0000000000003caf <botlish_entry_43: ht_rehash<mutarray, int>>:
    3caf:	push   rbp
    3cb0:	mov    rbp,rsp
    3cb3:	mov    rsi,QWORD PTR [rdx]
    3cb6:	mov    rdx,QWORD PTR [rdx+0x8]
    3cba:	call   3cbf <botlish_entry_43+0x10>
			3cbb: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3cbf:	mov    rsp,rbp
    3cc2:	pop    rbp
    3cc3:	ret
    3cc4:	add    BYTE PTR [rax],al
	...

0000000000003cc8 <botlish_fn_44: ht_should_grow<mutarray>>:
    3cc8:	push   rbp
    3cc9:	mov    rbp,rsp
    3ccc:	sub    rsp,0x40
    3cd0:	mov    QWORD PTR [rsp+0x20],rbx
    3cd5:	mov    QWORD PTR [rsp+0x28],r12
    3cda:	mov    QWORD PTR [rsp+0x30],r13
    3cdf:	mov    rbx,rdi
    3ce2:	mov    QWORD PTR [rsp],rsi
    3ce6:	mov    r12,rsi
    3ce9:	mov    rsi,r12
    3cec:	mov    rdi,rbx
    3cef:	call   3cf4 <botlish_fn_44+0x2c>
			3cf0: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3cf4:	mov    rcx,rax
    3cf7:	mov    r13,rax
    3cfa:	test   rax,rcx
    3cfd:	je     3eec <botlish_fn_44+0x224>
    3d03:	mov    rax,r13
    3d06:	mov    QWORD PTR [rsp+0x8],rax
    3d0b:	mov    rsi,r12
    3d0e:	mov    rdi,rbx
    3d11:	call   3d16 <botlish_fn_44+0x4e>
			3d12: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3d16:	mov    rcx,rax
    3d19:	test   rcx,rcx
    3d1c:	je     3eec <botlish_fn_44+0x224>
    3d22:	mov    QWORD PTR [rsp+0x10],rcx
    3d27:	mov    edx,0x1
    3d2c:	mov    rax,r13
    3d2f:	test   rax,0x1
    3d35:	jne    3d58 <botlish_fn_44+0x90>
    3d3b:	xor    edx,edx
    3d3d:	mov    rax,r13
    3d40:	test   rax,0x7
    3d46:	jne    3d58 <botlish_fn_44+0x90>
    3d4c:	mov    rax,r13
    3d4f:	movzx  rax,BYTE PTR [rax]
    3d53:	cmp    al,0x1
    3d55:	sete   dl
    3d58:	test   dl,dl
    3d5a:	jne    3d7b <botlish_fn_44+0xb3>
    3d60:	mov    rdi,rbx
    3d63:	mov    rax,QWORD PTR [rdi+0x10]
    3d67:	mov    rcx,QWORD PTR [rax+0x38]
    3d6b:	xor    rdx,rdx
    3d6e:	mov    rsi,r13
    3d71:	call   3d76 <botlish_fn_44+0xae>
			3d72: R_X86_64_PLT32	rt_type_error-0x4
    3d76:	jmp    3eec <botlish_fn_44+0x224>
    3d7b:	mov    eax,0x1
    3d80:	test   rcx,0x1
    3d87:	je     3d95 <botlish_fn_44+0xcd>
    3d8d:	mov    r8,rcx
    3d90:	jmp    3db8 <botlish_fn_44+0xf0>
    3d95:	xor    eax,eax
    3d97:	test   rcx,0x7
    3d9e:	je     3dac <botlish_fn_44+0xe4>
    3da4:	mov    r8,rcx
    3da7:	jmp    3db8 <botlish_fn_44+0xf0>
    3dac:	movzx  rax,BYTE PTR [rcx]
    3db0:	mov    r8,rcx
    3db3:	cmp    al,0x1
    3db5:	sete   al
    3db8:	test   al,al
    3dba:	jne    3ddb <botlish_fn_44+0x113>
    3dc0:	mov    rdi,rbx
    3dc3:	mov    rax,QWORD PTR [rdi+0x10]
    3dc7:	mov    rcx,QWORD PTR [rax+0x38]
    3dcb:	xor    rdx,rdx
    3dce:	mov    rsi,r8
    3dd1:	call   3dd6 <botlish_fn_44+0x10e>
			3dd2: R_X86_64_PLT32	rt_type_error-0x4
    3dd6:	jmp    3eec <botlish_fn_44+0x224>
    3ddb:	mov    rcx,r8
    3dde:	mov    rsi,r13
    3de1:	mov    rax,rsi
    3de4:	and    rax,rcx
    3de7:	test   rax,0x1
    3ded:	jne    3dfe <botlish_fn_44+0x136>
    3df3:	mov    rdx,r8
    3df6:	mov    rsi,r13
    3df9:	jmp    3e1c <botlish_fn_44+0x154>
    3dfe:	mov    rcx,r8
    3e01:	lea    rax,[rcx-0x1]
    3e05:	mov    rsi,r13
    3e08:	add    rsi,rax
    3e0b:	seto   al
    3e0e:	test   al,al
    3e10:	je     3e27 <botlish_fn_44+0x15f>
    3e16:	mov    rdx,r8
    3e19:	mov    rsi,r13
    3e1c:	mov    rdi,rbx
    3e1f:	call   3e24 <botlish_fn_44+0x15c>
			3e20: R_X86_64_PLT32	rt_int_add-0x4
    3e24:	mov    rsi,rax
    3e27:	mov    QWORD PTR [rsp+0x8],rsi
    3e2c:	mov    QWORD PTR [rsp+0x10],0x3
    3e35:	test   rsi,0x1
    3e3c:	je     3e5f <botlish_fn_44+0x197>
    3e42:	mov    rax,rsi
    3e45:	add    rax,0x2
    3e49:	mov    rcx,rax
    3e4c:	seto   al
    3e4f:	test   al,al
    3e51:	jne    3e5f <botlish_fn_44+0x197>
    3e57:	mov    rsi,rcx
    3e5a:	jmp    3e6f <botlish_fn_44+0x1a7>
    3e5f:	mov    edx,0x3
    3e64:	mov    rdi,rbx
    3e67:	call   3e6c <botlish_fn_44+0x1a4>
			3e68: R_X86_64_PLT32	rt_int_add-0x4
    3e6c:	mov    rsi,rax
    3e6f:	mov    QWORD PTR [rsp+0x8],rsi
    3e74:	mov    edx,0x7
    3e79:	mov    rdi,rdx
    3e7c:	mov    QWORD PTR [rsp+0x10],0x7
    3e85:	test   rsi,0x1
    3e8c:	jne    3e9a <botlish_fn_44+0x1d2>
    3e92:	mov    rdx,rdi
    3e95:	jmp    3ec6 <botlish_fn_44+0x1fe>
    3e9a:	mov    rax,rsi
    3e9d:	sar    rax,1
    3ea0:	imul   QWORD PTR [rip+0x119]        # 3fc0 <botlish_fn_44+0x2f8>
    3ea7:	seto   cl
    3eaa:	or     rax,0x1
    3eae:	test   cl,cl
    3eb0:	je     3ebe <botlish_fn_44+0x1f6>
    3eb6:	mov    rdx,rdi
    3eb9:	jmp    3ec6 <botlish_fn_44+0x1fe>
    3ebe:	mov    rsi,rax
    3ec1:	jmp    3ed1 <botlish_fn_44+0x209>
    3ec6:	mov    rdi,rbx
    3ec9:	call   3ece <botlish_fn_44+0x206>
			3eca: R_X86_64_PLT32	rt_int_mul-0x4
    3ece:	mov    rsi,rax
    3ed1:	mov    QWORD PTR [rsp],rsi
    3ed5:	mov    r13,rsi
    3ed8:	mov    rsi,r12
    3edb:	mov    rdi,rbx
    3ede:	call   3ee3 <botlish_fn_44+0x21b>
			3edf: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3ee3:	test   rax,rax
    3ee6:	jne    3f07 <botlish_fn_44+0x23f>
    3eec:	xor    rax,rax
    3eef:	mov    rbx,QWORD PTR [rsp+0x20]
    3ef4:	mov    r12,QWORD PTR [rsp+0x28]
    3ef9:	mov    r13,QWORD PTR [rsp+0x30]
    3efe:	add    rsp,0x40
    3f02:	mov    rsp,rbp
    3f05:	pop    rbp
    3f06:	ret
    3f07:	mov    QWORD PTR [rsp+0x8],rax
    3f0c:	mov    QWORD PTR [rsp+0x10],0x5
    3f15:	test   rax,0x1
    3f1b:	mov    rsi,rax
    3f1e:	je     3f50 <botlish_fn_44+0x288>
    3f24:	mov    rcx,rsi
    3f27:	mov    rax,rcx
    3f2a:	sar    rax,1
    3f2d:	imul   QWORD PTR [rip+0x94]        # 3fc8 <botlish_fn_44+0x300>
    3f34:	seto   dil
    3f38:	or     rax,0x1
    3f3c:	test   dil,dil
    3f3f:	jne    3f50 <botlish_fn_44+0x288>
    3f45:	mov    rdx,rax
    3f48:	mov    rsi,r13
    3f4b:	jmp    3f63 <botlish_fn_44+0x29b>
    3f50:	mov    edx,0x5
    3f55:	mov    rdi,rbx
    3f58:	call   3f5d <botlish_fn_44+0x295>
			3f59: R_X86_64_PLT32	rt_int_mul-0x4
    3f5d:	mov    rdx,rax
    3f60:	mov    rsi,r13
    3f63:	mov    r10,rsi
    3f66:	and    r10,rdx
    3f69:	test   r10,0x1
    3f70:	jne    3f97 <botlish_fn_44+0x2cf>
    3f76:	mov    rdi,rbx
    3f79:	call   3f7e <botlish_fn_44+0x2b6>
			3f7a: R_X86_64_PLT32	rt_int_cmp-0x4
    3f7e:	mov    r8d,0x2
    3f84:	test   rax,rax
    3f87:	mov    rax,r8
    3f8a:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3fc0 <botlish_fn_44+0x2f8>
    3f92:	jmp    3fa7 <botlish_fn_44+0x2df>
    3f97:	mov    eax,0x2
    3f9c:	cmp    rsi,rdx
    3f9f:	cmovg  rax,QWORD PTR [rip+0x19]        # 3fc0 <botlish_fn_44+0x2f8>
    3fa7:	mov    rbx,QWORD PTR [rsp+0x20]
    3fac:	mov    r12,QWORD PTR [rsp+0x28]
    3fb1:	mov    r13,QWORD PTR [rsp+0x30]
    3fb6:	add    rsp,0x40
    3fba:	mov    rsp,rbp
    3fbd:	pop    rbp
    3fbe:	ret
    3fbf:	add    BYTE PTR [rsi],al
    3fc1:	add    BYTE PTR [rax],al
    3fc3:	add    BYTE PTR [rax],al
    3fc5:	add    BYTE PTR [rax],al
    3fc7:	add    BYTE PTR [rax+rax*1],al
    3fca:	add    BYTE PTR [rax],al
    3fcc:	add    BYTE PTR [rax],al
	...

0000000000003fd0 <botlish_entry_44: ht_should_grow<mutarray>>:
    3fd0:	push   rbp
    3fd1:	mov    rbp,rsp
    3fd4:	mov    rsi,QWORD PTR [rdx]
    3fd7:	call   3fdc <botlish_entry_44+0xc>
			3fd8: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3fdc:	mov    rsp,rbp
    3fdf:	pop    rbp
    3fe0:	ret
    3fe1:	add    BYTE PTR [rax],al
    3fe3:	add    BYTE PTR [rax],al
    3fe5:	add    BYTE PTR [rax],al
	...

0000000000003fe8 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    3fe8:	push   rbp
    3fe9:	mov    rbp,rsp
    3fec:	sub    rsp,0x40
    3ff0:	mov    QWORD PTR [rsp+0x20],rbx
    3ff5:	mov    QWORD PTR [rsp+0x28],r12
    3ffa:	mov    QWORD PTR [rsp+0x30],r13
    3fff:	mov    rbx,rdi
    4002:	mov    QWORD PTR [rsp+0x10],0x0
    400b:	mov    QWORD PTR [rsp],rsi
    400f:	mov    r12,rsi
    4012:	mov    rsi,r12
    4015:	mov    rdi,rbx
    4018:	call   401d <botlish_fn_45+0x35>
			4019: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    401d:	test   rax,rax
    4020:	mov    r13,rax
    4023:	je     4210 <botlish_fn_45+0x228>
    4029:	mov    rsi,r12
    402c:	mov    rdi,rbx
    402f:	call   4034 <botlish_fn_45+0x4c>
			4030: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    4034:	mov    rcx,rax
    4037:	test   rcx,rcx
    403a:	je     4210 <botlish_fn_45+0x228>
    4040:	mov    edx,0x1
    4045:	mov    rax,r13
    4048:	test   rax,0x1
    404e:	je     405c <botlish_fn_45+0x74>
    4054:	mov    r13,rax
    4057:	jmp    4080 <botlish_fn_45+0x98>
    405c:	xor    edx,edx
    405e:	test   rax,0x7
    4064:	je     4072 <botlish_fn_45+0x8a>
    406a:	mov    r13,rax
    406d:	jmp    4080 <botlish_fn_45+0x98>
    4072:	movzx  rdx,BYTE PTR [rax]
    4076:	mov    r13,rax
    4079:	rex cmp dl,0x1
    407d:	sete   dl
    4080:	test   dl,dl
    4082:	jne    40a3 <botlish_fn_45+0xbb>
    4088:	mov    rdi,rbx
    408b:	mov    rsi,QWORD PTR [rdi+0x10]
    408f:	mov    rcx,QWORD PTR [rsi+0x40]
    4093:	xor    rdx,rdx
    4096:	mov    rsi,r13
    4099:	call   409e <botlish_fn_45+0xb6>
			409a: R_X86_64_PLT32	rt_type_error-0x4
    409e:	jmp    4210 <botlish_fn_45+0x228>
    40a3:	mov    rsi,r13
    40a6:	mov    eax,0x1
    40ab:	test   rcx,0x1
    40b2:	je     40c0 <botlish_fn_45+0xd8>
    40b8:	mov    r8,rcx
    40bb:	jmp    40e5 <botlish_fn_45+0xfd>
    40c0:	xor    eax,eax
    40c2:	test   rcx,0x7
    40c9:	je     40d7 <botlish_fn_45+0xef>
    40cf:	mov    r8,rcx
    40d2:	jmp    40e5 <botlish_fn_45+0xfd>
    40d7:	movzx  r11,BYTE PTR [rcx]
    40db:	mov    r8,rcx
    40de:	cmp    r11b,0x1
    40e2:	sete   al
    40e5:	test   al,al
    40e7:	jne    4108 <botlish_fn_45+0x120>
    40ed:	mov    rdi,rbx
    40f0:	mov    rax,QWORD PTR [rdi+0x10]
    40f4:	mov    rcx,QWORD PTR [rax+0x40]
    40f8:	xor    rdx,rdx
    40fb:	mov    rsi,r8
    40fe:	call   4103 <botlish_fn_45+0x11b>
			40ff: R_X86_64_PLT32	rt_type_error-0x4
    4103:	jmp    4210 <botlish_fn_45+0x228>
    4108:	mov    rcx,r8
    410b:	mov    rax,rsi
    410e:	and    rax,rcx
    4111:	test   rax,0x1
    4117:	jne    413d <botlish_fn_45+0x155>
    411d:	mov    rdx,r8
    4120:	mov    rdi,rbx
    4123:	call   4128 <botlish_fn_45+0x140>
			4124: R_X86_64_PLT32	rt_int_cmp-0x4
    4128:	mov    ecx,0x2
    412d:	test   rax,rax
    4130:	cmovg  rcx,QWORD PTR [rip+0x110]        # 4248 <botlish_fn_45+0x260>
    4138:	jmp    4150 <botlish_fn_45+0x168>
    413d:	mov    ecx,0x2
    4142:	mov    r9,r8
    4145:	cmp    rsi,r9
    4148:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 4248 <botlish_fn_45+0x260>
    4150:	cmp    rcx,0x6
    4154:	je     41e0 <botlish_fn_45+0x1f8>
    415a:	mov    rsi,r12
    415d:	mov    rdi,rbx
    4160:	call   4165 <botlish_fn_45+0x17d>
			4161: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4165:	test   rax,rax
    4168:	je     4210 <botlish_fn_45+0x228>
    416e:	mov    QWORD PTR [rsp+0x8],rax
    4173:	mov    QWORD PTR [rsp+0x10],0x5
    417c:	test   rax,0x1
    4182:	mov    rsi,rax
    4185:	je     41b2 <botlish_fn_45+0x1ca>
    418b:	mov    rcx,rsi
    418e:	mov    rax,rcx
    4191:	sar    rax,1
    4194:	imul   QWORD PTR [rip+0xb5]        # 4250 <botlish_fn_45+0x268>
    419b:	seto   cl
    419e:	or     rax,0x1
    41a2:	test   cl,cl
    41a4:	jne    41b2 <botlish_fn_45+0x1ca>
    41aa:	mov    rdx,rax
    41ad:	jmp    41c2 <botlish_fn_45+0x1da>
    41b2:	mov    edx,0x5
    41b7:	mov    rdi,rbx
    41ba:	call   41bf <botlish_fn_45+0x1d7>
			41bb: R_X86_64_PLT32	rt_int_mul-0x4
    41bf:	mov    rdx,rax
    41c2:	mov    QWORD PTR [rsp+0x8],rdx
    41c7:	mov    rsi,r12
    41ca:	mov    rdi,rbx
    41cd:	call   41d2 <botlish_fn_45+0x1ea>
			41ce: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41d2:	test   rax,rax
    41d5:	je     4210 <botlish_fn_45+0x228>
    41db:	jmp    422b <botlish_fn_45+0x243>
    41e0:	mov    rsi,r12
    41e3:	mov    rdi,rbx
    41e6:	call   41eb <botlish_fn_45+0x203>
			41e7: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    41eb:	test   rax,rax
    41ee:	je     4210 <botlish_fn_45+0x228>
    41f4:	mov    QWORD PTR [rsp+0x8],rax
    41f9:	mov    rdx,rax
    41fc:	mov    rsi,r12
    41ff:	mov    rdi,rbx
    4202:	call   4207 <botlish_fn_45+0x21f>
			4203: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    4207:	test   rax,rax
    420a:	jne    422b <botlish_fn_45+0x243>
    4210:	xor    rax,rax
    4213:	mov    rbx,QWORD PTR [rsp+0x20]
    4218:	mov    r12,QWORD PTR [rsp+0x28]
    421d:	mov    r13,QWORD PTR [rsp+0x30]
    4222:	add    rsp,0x40
    4226:	mov    rsp,rbp
    4229:	pop    rbp
    422a:	ret
    422b:	mov    rbx,QWORD PTR [rsp+0x20]
    4230:	mov    r12,QWORD PTR [rsp+0x28]
    4235:	mov    r13,QWORD PTR [rsp+0x30]
    423a:	add    rsp,0x40
    423e:	mov    rsp,rbp
    4241:	pop    rbp
    4242:	ret
    4243:	add    BYTE PTR [rax],al
    4245:	add    BYTE PTR [rax],al
    4247:	add    BYTE PTR [rsi],al
    4249:	add    BYTE PTR [rax],al
    424b:	add    BYTE PTR [rax],al
    424d:	add    BYTE PTR [rax],al
    424f:	add    BYTE PTR [rax+rax*1],al
    4252:	add    BYTE PTR [rax],al
    4254:	add    BYTE PTR [rax],al
	...

0000000000004258 <botlish_entry_45: ht_grow_or_clean<mutarray>>:
    4258:	push   rbp
    4259:	mov    rbp,rsp
    425c:	mov    rsi,QWORD PTR [rdx]
    425f:	call   4264 <botlish_entry_45+0xc>
			4260: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    4264:	mov    rsp,rbp
    4267:	pop    rbp
    4268:	ret
    4269:	add    BYTE PTR [rax],al
    426b:	add    BYTE PTR [rax],al
    426d:	add    BYTE PTR [rax],al
	...

0000000000004270 <botlish_fn_46: ht_place<mutarray, int, str, str>>:
    4270:	push   rbp
    4271:	mov    rbp,rsp
    4274:	sub    rsp,0x70
    4278:	mov    QWORD PTR [rsp+0x40],rbx
    427d:	mov    QWORD PTR [rsp+0x48],r12
    4282:	mov    QWORD PTR [rsp+0x50],r13
    4287:	mov    QWORD PTR [rsp+0x58],r14
    428c:	mov    QWORD PTR [rsp+0x60],r15
    4291:	mov    rbx,rdi
    4294:	mov    r14,r8
    4297:	mov    r15,rdx
    429a:	mov    QWORD PTR [rsp+0x28],rcx
    429f:	mov    QWORD PTR [rsp],rsi
    42a3:	mov    r12,rsi
    42a6:	mov    rsi,r12
    42a9:	mov    rdi,rbx
    42ac:	call   42b1 <botlish_fn_46+0x41>
			42ad: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    42b1:	test   rax,rax
    42b4:	je     4618 <botlish_fn_46+0x3a8>
    42ba:	xor    ecx,ecx
    42bc:	test   rax,0x7
    42c2:	je     42d2 <botlish_fn_46+0x62>
    42c8:	mov    QWORD PTR [rsp+0x30],rax
    42cd:	jmp    42e2 <botlish_fn_46+0x72>
    42d2:	movzx  rcx,BYTE PTR [rax]
    42d6:	mov    QWORD PTR [rsp+0x30],rax
    42db:	rex cmp cl,0x8
    42df:	sete   cl
    42e2:	test   cl,cl
    42e4:	jne    4309 <botlish_fn_46+0x99>
    42ea:	mov    rdi,rbx
    42ed:	mov    rax,QWORD PTR [rdi+0x10]
    42f1:	mov    rcx,QWORD PTR [rax+0x30]
    42f5:	mov    edx,0x8
    42fa:	mov    rsi,QWORD PTR [rsp+0x30]
    42ff:	call   4304 <botlish_fn_46+0x94>
			4300: R_X86_64_PLT32	rt_type_error-0x4
    4304:	jmp    4618 <botlish_fn_46+0x3a8>
    4309:	mov    rdx,r15
    430c:	mov    rsi,QWORD PTR [rsp+0x30]
    4311:	mov    rdi,rbx
    4314:	call   4319 <botlish_fn_46+0xa9>
			4315: R_X86_64_PLT32	rt_mutarray_get-0x4
    4319:	test   rax,rax
    431c:	je     4618 <botlish_fn_46+0x3a8>
    4322:	mov    QWORD PTR [rsp+0x8],rax
    4327:	mov    r13,rax
    432a:	mov    ecx,0x3
    432f:	mov    rsi,QWORD PTR [rsp+0x30]
    4334:	mov    rdx,r15
    4337:	mov    rdi,rbx
    433a:	call   433f <botlish_fn_46+0xcf>
			433b: R_X86_64_PLT32	rt_mutarray_set-0x4
    433f:	test   rax,rax
    4342:	je     4618 <botlish_fn_46+0x3a8>
    4348:	mov    rsi,r12
    434b:	mov    rdi,rbx
    434e:	call   4353 <botlish_fn_46+0xe3>
			434f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    4353:	test   rax,rax
    4356:	je     4618 <botlish_fn_46+0x3a8>
    435c:	xor    ecx,ecx
    435e:	test   rax,0x7
    4364:	je     4372 <botlish_fn_46+0x102>
    436a:	mov    rsi,rax
    436d:	jmp    4380 <botlish_fn_46+0x110>
    4372:	movzx  rcx,BYTE PTR [rax]
    4376:	mov    rsi,rax
    4379:	rex cmp cl,0x8
    437d:	sete   cl
    4380:	test   cl,cl
    4382:	jne    43a1 <botlish_fn_46+0x131>
    4388:	mov    rdi,rbx
    438b:	mov    rax,QWORD PTR [rdi+0x10]
    438f:	mov    rcx,QWORD PTR [rax]
    4392:	mov    edx,0x8
    4397:	call   439c <botlish_fn_46+0x12c>
			4398: R_X86_64_PLT32	rt_type_error-0x4
    439c:	jmp    4618 <botlish_fn_46+0x3a8>
    43a1:	mov    rcx,QWORD PTR [rsp+0x28]
    43a6:	mov    rdx,r15
    43a9:	mov    rdi,rbx
    43ac:	call   43b1 <botlish_fn_46+0x141>
			43ad: R_X86_64_PLT32	rt_mutarray_set-0x4
    43b1:	test   rax,rax
    43b4:	je     4618 <botlish_fn_46+0x3a8>
    43ba:	mov    rsi,r12
    43bd:	mov    rdi,rbx
    43c0:	call   43c5 <botlish_fn_46+0x155>
			43c1: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    43c5:	test   rax,rax
    43c8:	je     4618 <botlish_fn_46+0x3a8>
    43ce:	xor    esi,esi
    43d0:	test   rax,0x7
    43d6:	jne    43e8 <botlish_fn_46+0x178>
    43dc:	movzx  rcx,BYTE PTR [rax]
    43e0:	rex cmp cl,0x8
    43e4:	sete   sil
    43e8:	test   sil,sil
    43eb:	jne    440d <botlish_fn_46+0x19d>
    43f1:	mov    rdi,rbx
    43f4:	mov    rsi,QWORD PTR [rdi+0x10]
    43f8:	mov    rcx,QWORD PTR [rsi]
    43fb:	mov    edx,0x8
    4400:	mov    rsi,rax
    4403:	call   4408 <botlish_fn_46+0x198>
			4404: R_X86_64_PLT32	rt_type_error-0x4
    4408:	jmp    4618 <botlish_fn_46+0x3a8>
    440d:	mov    rcx,r14
    4410:	mov    rdx,r15
    4413:	mov    rsi,rax
    4416:	mov    rdi,rbx
    4419:	call   441e <botlish_fn_46+0x1ae>
			441a: R_X86_64_PLT32	rt_mutarray_set-0x4
    441e:	test   rax,rax
    4421:	je     4618 <botlish_fn_46+0x3a8>
    4427:	mov    QWORD PTR [rsp+0x10],0x7
    4430:	mov    rsi,r12
    4433:	mov    rdi,rbx
    4436:	call   443b <botlish_fn_46+0x1cb>
			4437: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    443b:	test   rax,rax
    443e:	je     4618 <botlish_fn_46+0x3a8>
    4444:	mov    QWORD PTR [rsp+0x18],rax
    4449:	mov    QWORD PTR [rsp+0x20],0x3
    4452:	mov    ecx,0x1
    4457:	test   rax,0x1
    445d:	je     446b <botlish_fn_46+0x1fb>
    4463:	mov    rsi,rax
    4466:	jmp    448f <botlish_fn_46+0x21f>
    446b:	xor    ecx,ecx
    446d:	test   rax,0x7
    4473:	je     4481 <botlish_fn_46+0x211>
    4479:	mov    rsi,rax
    447c:	jmp    448f <botlish_fn_46+0x21f>
    4481:	movzx  rcx,BYTE PTR [rax]
    4485:	mov    rsi,rax
    4488:	rex cmp cl,0x1
    448c:	sete   cl
    448f:	test   cl,cl
    4491:	jne    44af <botlish_fn_46+0x23f>
    4497:	mov    rdi,rbx
    449a:	mov    rax,QWORD PTR [rdi+0x10]
    449e:	mov    rcx,QWORD PTR [rax+0x38]
    44a2:	xor    rdx,rdx
    44a5:	call   44aa <botlish_fn_46+0x23a>
			44a6: R_X86_64_PLT32	rt_type_error-0x4
    44aa:	jmp    4618 <botlish_fn_46+0x3a8>
    44af:	test   rsi,0x1
    44b6:	je     44ce <botlish_fn_46+0x25e>
    44bc:	mov    rcx,rsi
    44bf:	add    rcx,0x2
    44c3:	seto   al
    44c6:	test   al,al
    44c8:	je     44de <botlish_fn_46+0x26e>
    44ce:	mov    edx,0x3
    44d3:	mov    rdi,rbx
    44d6:	call   44db <botlish_fn_46+0x26b>
			44d7: R_X86_64_PLT32	rt_int_add-0x4
    44db:	mov    rcx,rax
    44de:	mov    edx,0x7
    44e3:	mov    rsi,r12
    44e6:	mov    rdi,rbx
    44e9:	call   44ee <botlish_fn_46+0x27e>
			44ea: R_X86_64_PLT32	rt_mutarray_set-0x4
    44ee:	test   rax,rax
    44f1:	je     4618 <botlish_fn_46+0x3a8>
    44f7:	mov    rax,r13
    44fa:	test   rax,0x1
    4500:	jne    4524 <botlish_fn_46+0x2b4>
    4506:	mov    edx,0x5
    450b:	mov    rsi,r13
    450e:	mov    rdi,rbx
    4511:	call   4516 <botlish_fn_46+0x2a6>
			4512: R_X86_64_PLT32	rt_value_eq-0x4
    4516:	test   rax,rax
    4519:	je     4618 <botlish_fn_46+0x3a8>
    451f:	jmp    4538 <botlish_fn_46+0x2c8>
    4524:	mov    rsi,r13
    4527:	mov    eax,0x2
    452c:	cmp    rsi,0x5
    4530:	cmove  rax,QWORD PTR [rip+0x130]        # 4668 <botlish_fn_46+0x3f8>
    4538:	cmp    rax,0x6
    453c:	jne    463d <botlish_fn_46+0x3cd>
    4542:	mov    QWORD PTR [rsp+0x8],0x9
    454b:	mov    rsi,r12
    454e:	mov    rdi,rbx
    4551:	call   4556 <botlish_fn_46+0x2e6>
			4552: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4556:	test   rax,rax
    4559:	je     4618 <botlish_fn_46+0x3a8>
    455f:	mov    QWORD PTR [rsp+0x10],rax
    4564:	mov    QWORD PTR [rsp+0x18],0x3
    456d:	mov    ecx,0x1
    4572:	test   rax,0x1
    4578:	je     4586 <botlish_fn_46+0x316>
    457e:	mov    rsi,rax
    4581:	jmp    45aa <botlish_fn_46+0x33a>
    4586:	xor    ecx,ecx
    4588:	test   rax,0x7
    458e:	je     459c <botlish_fn_46+0x32c>
    4594:	mov    rsi,rax
    4597:	jmp    45aa <botlish_fn_46+0x33a>
    459c:	movzx  rcx,BYTE PTR [rax]
    45a0:	mov    rsi,rax
    45a3:	rex cmp cl,0x1
    45a7:	sete   cl
    45aa:	test   cl,cl
    45ac:	jne    45ca <botlish_fn_46+0x35a>
    45b2:	mov    rdi,rbx
    45b5:	mov    rcx,QWORD PTR [rdi+0x10]
    45b9:	mov    rcx,QWORD PTR [rcx+0x48]
    45bd:	xor    rdx,rdx
    45c0:	call   45c5 <botlish_fn_46+0x355>
			45c1: R_X86_64_PLT32	rt_type_error-0x4
    45c5:	jmp    4618 <botlish_fn_46+0x3a8>
    45ca:	test   rsi,0x1
    45d1:	je     45ef <botlish_fn_46+0x37f>
    45d7:	mov    r8,rsi
    45da:	sub    r8,0x3
    45de:	seto   dil
    45e2:	lea    rcx,[r8+0x1]
    45e6:	test   dil,dil
    45e9:	je     45ff <botlish_fn_46+0x38f>
    45ef:	mov    edx,0x3
    45f4:	mov    rdi,rbx
    45f7:	call   45fc <botlish_fn_46+0x38c>
			45f8: R_X86_64_PLT32	rt_int_sub-0x4
    45fc:	mov    rcx,rax
    45ff:	mov    edx,0x9
    4604:	mov    rsi,r12
    4607:	mov    rdi,rbx
    460a:	call   460f <botlish_fn_46+0x39f>
			460b: R_X86_64_PLT32	rt_mutarray_set-0x4
    460f:	test   rax,rax
    4612:	jne    463d <botlish_fn_46+0x3cd>
    4618:	xor    rax,rax
    461b:	mov    rbx,QWORD PTR [rsp+0x40]
    4620:	mov    r12,QWORD PTR [rsp+0x48]
    4625:	mov    r13,QWORD PTR [rsp+0x50]
    462a:	mov    r14,QWORD PTR [rsp+0x58]
    462f:	mov    r15,QWORD PTR [rsp+0x60]
    4634:	add    rsp,0x70
    4638:	mov    rsp,rbp
    463b:	pop    rbp
    463c:	ret
    463d:	mov    eax,0xa
    4642:	mov    rbx,QWORD PTR [rsp+0x40]
    4647:	mov    r12,QWORD PTR [rsp+0x48]
    464c:	mov    r13,QWORD PTR [rsp+0x50]
    4651:	mov    r14,QWORD PTR [rsp+0x58]
    4656:	mov    r15,QWORD PTR [rsp+0x60]
    465b:	add    rsp,0x70
    465f:	mov    rsp,rbp
    4662:	pop    rbp
    4663:	ret
    4664:	add    BYTE PTR [rax],al
    4666:	add    BYTE PTR [rax],al
    4668:	(bad)
    4669:	add    BYTE PTR [rax],al
    466b:	add    BYTE PTR [rax],al
    466d:	add    BYTE PTR [rax],al
	...

0000000000004670 <botlish_entry_46: ht_place<mutarray, int, str, str>>:
    4670:	push   rbp
    4671:	mov    rbp,rsp
    4674:	mov    rsi,QWORD PTR [rdx]
    4677:	mov    r9,QWORD PTR [rdx+0x8]
    467b:	mov    rcx,QWORD PTR [rdx+0x10]
    467f:	mov    r8,QWORD PTR [rdx+0x18]
    4683:	mov    rdx,r9
    4686:	call   468b <botlish_entry_46+0x1b>
			4687: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    468b:	mov    rsp,rbp
    468e:	pop    rbp
    468f:	ret

0000000000004690 <botlish_fn_47: ht_set<mutarray, str, str>>:
    4690:	push   rbp
    4691:	mov    rbp,rsp
    4694:	sub    rsp,0x60
    4698:	mov    QWORD PTR [rsp+0x30],rbx
    469d:	mov    QWORD PTR [rsp+0x38],r12
    46a2:	mov    QWORD PTR [rsp+0x40],r13
    46a7:	mov    QWORD PTR [rsp+0x48],r14
    46ac:	mov    QWORD PTR [rsp+0x50],r15
    46b1:	mov    rbx,rdi
    46b4:	mov    r13,rdx
    46b7:	mov    QWORD PTR [rsp],rsi
    46bb:	mov    r14,rsi
    46be:	mov    QWORD PTR [rsp+0x8],rdx
    46c3:	mov    QWORD PTR [rsp+0x10],rcx
    46c8:	mov    r12,rcx
    46cb:	mov    rdx,r13
    46ce:	mov    rsi,r14
    46d1:	mov    rdi,rbx
    46d4:	call   46d9 <botlish_fn_47+0x49>
			46d5: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    46d9:	test   rax,rax
    46dc:	je     4946 <botlish_fn_47+0x2b6>
    46e2:	mov    QWORD PTR [rsp+0x18],rax
    46e7:	mov    rcx,rax
    46ea:	mov    r8,0xffffffffffffffff
    46f1:	mov    QWORD PTR [rsp+0x28],r8
    46f6:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    46ff:	mov    rdx,r13
    4702:	mov    rsi,r14
    4705:	mov    rdi,rbx
    4708:	call   470d <botlish_fn_47+0x7d>
			4709: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    470d:	mov    rcx,rax
    4710:	mov    r15,rax
    4713:	test   rax,rcx
    4716:	je     4946 <botlish_fn_47+0x2b6>
    471c:	mov    rax,r15
    471f:	mov    QWORD PTR [rsp+0x18],rax
    4724:	mov    rsi,r14
    4727:	mov    rdi,rbx
    472a:	call   472f <botlish_fn_47+0x9f>
			472b: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    472f:	test   rax,rax
    4732:	je     4946 <botlish_fn_47+0x2b6>
    4738:	xor    ecx,ecx
    473a:	test   rax,0x7
    4740:	je     474e <botlish_fn_47+0xbe>
    4746:	mov    r8,rax
    4749:	jmp    475c <botlish_fn_47+0xcc>
    474e:	movzx  rcx,BYTE PTR [rax]
    4752:	mov    r8,rax
    4755:	rex cmp cl,0x8
    4759:	sete   cl
    475c:	test   cl,cl
    475e:	jne    4781 <botlish_fn_47+0xf1>
    4764:	mov    rdi,rbx
    4767:	mov    rsi,QWORD PTR [rdi+0x10]
    476b:	mov    rcx,QWORD PTR [rsi+0x30]
    476f:	mov    edx,0x8
    4774:	mov    rsi,r8
    4777:	call   477c <botlish_fn_47+0xec>
			4778: R_X86_64_PLT32	rt_type_error-0x4
    477c:	jmp    4946 <botlish_fn_47+0x2b6>
    4781:	mov    rsi,r8
    4784:	mov    rdx,r15
    4787:	mov    rdi,rbx
    478a:	call   478f <botlish_fn_47+0xff>
			478b: R_X86_64_PLT32	rt_mutarray_get-0x4
    478f:	test   rax,rax
    4792:	je     4946 <botlish_fn_47+0x2b6>
    4798:	test   rax,0x1
    479e:	mov    rsi,rax
    47a1:	jne    47c2 <botlish_fn_47+0x132>
    47a7:	mov    edx,0x3
    47ac:	mov    rdi,rbx
    47af:	call   47b4 <botlish_fn_47+0x124>
			47b0: R_X86_64_PLT32	rt_value_eq-0x4
    47b4:	test   rax,rax
    47b7:	je     4946 <botlish_fn_47+0x2b6>
    47bd:	jmp    47d3 <botlish_fn_47+0x143>
    47c2:	mov    eax,0x2
    47c7:	cmp    rsi,0x3
    47cb:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4998 <botlish_fn_47+0x308>
    47d3:	cmp    rax,0x6
    47d7:	je     48d6 <botlish_fn_47+0x246>
    47dd:	mov    rsi,r14
    47e0:	mov    rdi,rbx
    47e3:	call   47e8 <botlish_fn_47+0x158>
			47e4: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    47e8:	test   rax,rax
    47eb:	je     4946 <botlish_fn_47+0x2b6>
    47f1:	cmp    rax,0x6
    47f5:	je     483a <botlish_fn_47+0x1aa>
    47fb:	mov    rcx,r13
    47fe:	mov    rdx,r15
    4801:	mov    rsi,r14
    4804:	mov    rdi,rbx
    4807:	mov    r8,r12
    480a:	call   480f <botlish_fn_47+0x17f>
			480b: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    480f:	test   rax,rax
    4812:	je     4946 <botlish_fn_47+0x2b6>
    4818:	mov    rbx,QWORD PTR [rsp+0x30]
    481d:	mov    r12,QWORD PTR [rsp+0x38]
    4822:	mov    r13,QWORD PTR [rsp+0x40]
    4827:	mov    r14,QWORD PTR [rsp+0x48]
    482c:	mov    r15,QWORD PTR [rsp+0x50]
    4831:	add    rsp,0x60
    4835:	mov    rsp,rbp
    4838:	pop    rbp
    4839:	ret
    483a:	mov    rsi,r14
    483d:	mov    rdi,rbx
    4840:	call   4845 <botlish_fn_47+0x1b5>
			4841: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    4845:	test   rax,rax
    4848:	je     4946 <botlish_fn_47+0x2b6>
    484e:	mov    rdx,r13
    4851:	mov    rsi,r14
    4854:	mov    rdi,rbx
    4857:	call   485c <botlish_fn_47+0x1cc>
			4858: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    485c:	test   rax,rax
    485f:	je     4946 <botlish_fn_47+0x2b6>
    4865:	mov    QWORD PTR [rsp+0x18],rax
    486a:	mov    rcx,rax
    486d:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4876:	mov    r8,QWORD PTR [rsp+0x28]
    487b:	mov    rdx,r13
    487e:	mov    rsi,r14
    4881:	mov    rdi,rbx
    4884:	call   4889 <botlish_fn_47+0x1f9>
			4885: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4889:	test   rax,rax
    488c:	je     4946 <botlish_fn_47+0x2b6>
    4892:	mov    QWORD PTR [rsp+0x18],rax
    4897:	mov    rcx,r13
    489a:	mov    rdx,rax
    489d:	mov    rsi,r14
    48a0:	mov    rdi,rbx
    48a3:	mov    r8,r12
    48a6:	call   48ab <botlish_fn_47+0x21b>
			48a7: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    48ab:	test   rax,rax
    48ae:	je     4946 <botlish_fn_47+0x2b6>
    48b4:	mov    rbx,QWORD PTR [rsp+0x30]
    48b9:	mov    r12,QWORD PTR [rsp+0x38]
    48be:	mov    r13,QWORD PTR [rsp+0x40]
    48c3:	mov    r14,QWORD PTR [rsp+0x48]
    48c8:	mov    r15,QWORD PTR [rsp+0x50]
    48cd:	add    rsp,0x60
    48d1:	mov    rsp,rbp
    48d4:	pop    rbp
    48d5:	ret
    48d6:	mov    rsi,r14
    48d9:	mov    rdi,rbx
    48dc:	call   48e1 <botlish_fn_47+0x251>
			48dd: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    48e1:	test   rax,rax
    48e4:	je     4946 <botlish_fn_47+0x2b6>
    48ea:	xor    ecx,ecx
    48ec:	test   rax,0x7
    48f2:	je     4900 <botlish_fn_47+0x270>
    48f8:	mov    rsi,rax
    48fb:	jmp    490e <botlish_fn_47+0x27e>
    4900:	movzx  rcx,BYTE PTR [rax]
    4904:	mov    rsi,rax
    4907:	rex cmp cl,0x8
    490b:	sete   cl
    490e:	test   cl,cl
    4910:	jne    492f <botlish_fn_47+0x29f>
    4916:	mov    rdi,rbx
    4919:	mov    rax,QWORD PTR [rdi+0x10]
    491d:	mov    rcx,QWORD PTR [rax]
    4920:	mov    edx,0x8
    4925:	call   492a <botlish_fn_47+0x29a>
			4926: R_X86_64_PLT32	rt_type_error-0x4
    492a:	jmp    4946 <botlish_fn_47+0x2b6>
    492f:	mov    rcx,r12
    4932:	mov    rdx,r15
    4935:	mov    rdi,rbx
    4938:	call   493d <botlish_fn_47+0x2ad>
			4939: R_X86_64_PLT32	rt_mutarray_set-0x4
    493d:	test   rax,rax
    4940:	jne    496b <botlish_fn_47+0x2db>
    4946:	xor    rax,rax
    4949:	mov    rbx,QWORD PTR [rsp+0x30]
    494e:	mov    r12,QWORD PTR [rsp+0x38]
    4953:	mov    r13,QWORD PTR [rsp+0x40]
    4958:	mov    r14,QWORD PTR [rsp+0x48]
    495d:	mov    r15,QWORD PTR [rsp+0x50]
    4962:	add    rsp,0x60
    4966:	mov    rsp,rbp
    4969:	pop    rbp
    496a:	ret
    496b:	mov    eax,0xa
    4970:	mov    rbx,QWORD PTR [rsp+0x30]
    4975:	mov    r12,QWORD PTR [rsp+0x38]
    497a:	mov    r13,QWORD PTR [rsp+0x40]
    497f:	mov    r14,QWORD PTR [rsp+0x48]
    4984:	mov    r15,QWORD PTR [rsp+0x50]
    4989:	add    rsp,0x60
    498d:	mov    rsp,rbp
    4990:	pop    rbp
    4991:	ret
    4992:	add    BYTE PTR [rax],al
    4994:	add    BYTE PTR [rax],al
    4996:	add    BYTE PTR [rax],al
    4998:	(bad)
    4999:	add    BYTE PTR [rax],al
    499b:	add    BYTE PTR [rax],al
    499d:	add    BYTE PTR [rax],al
	...

00000000000049a0 <botlish_entry_47: ht_set<mutarray, str, str>>:
    49a0:	push   rbp
    49a1:	mov    rbp,rsp
    49a4:	mov    rsi,QWORD PTR [rdx]
    49a7:	mov    r8,QWORD PTR [rdx+0x8]
    49ab:	mov    rcx,QWORD PTR [rdx+0x10]
    49af:	mov    rdx,r8
    49b2:	call   49b7 <botlish_entry_47+0x17>
			49b3: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    49b7:	mov    rsp,rbp
    49ba:	pop    rbp
    49bb:	ret

00000000000049bc <botlish_fn_48: row_new<bool, int>>:
    49bc:	push   rbp
    49bd:	mov    rbp,rsp
    49c0:	sub    rsp,0x10
    49c4:	mov    QWORD PTR [rsp],rdx
    49c8:	mov    r8,rdx
    49cb:	cmp    rsi,0x6
    49cf:	je     49ec <botlish_fn_48+0x30>
    49d5:	call   49da <botlish_fn_48+0x1e>
			49d6: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    49da:	test   rax,rax
    49dd:	je     49fd <botlish_fn_48+0x41>
    49e3:	add    rsp,0x10
    49e7:	mov    rsp,rbp
    49ea:	pop    rbp
    49eb:	ret
    49ec:	mov    rsi,r8
    49ef:	call   49f4 <botlish_fn_48+0x38>
			49f0: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    49f4:	test   rax,rax
    49f7:	jne    4a09 <botlish_fn_48+0x4d>
    49fd:	xor    rax,rax
    4a00:	add    rsp,0x10
    4a04:	mov    rsp,rbp
    4a07:	pop    rbp
    4a08:	ret
    4a09:	add    rsp,0x10
    4a0d:	mov    rsp,rbp
    4a10:	pop    rbp
    4a11:	ret

0000000000004a12 <botlish_entry_48: row_new<bool, int>>:
    4a12:	push   rbp
    4a13:	mov    rbp,rsp
    4a16:	mov    rsi,QWORD PTR [rdx]
    4a19:	mov    rdx,QWORD PTR [rdx+0x8]
    4a1d:	call   4a22 <botlish_entry_48+0x10>
			4a1e: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4a22:	mov    rsp,rbp
    4a25:	pop    rbp
    4a26:	ret

0000000000004a27 <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4a27:	push   rbp
    4a28:	mov    rbp,rsp
    4a2b:	sub    rsp,0x70
    4a2f:	mov    QWORD PTR [rsp+0x40],rbx
    4a34:	mov    QWORD PTR [rsp+0x48],r12
    4a39:	mov    QWORD PTR [rsp+0x50],r13
    4a3e:	mov    QWORD PTR [rsp+0x58],r14
    4a43:	mov    QWORD PTR [rsp+0x60],r15
    4a48:	mov    QWORD PTR [rsp+0x28],rdi
    4a4d:	mov    QWORD PTR [rsp],rsi
    4a51:	mov    r14,rsi
    4a54:	mov    QWORD PTR [rsp+0x8],rdx
    4a59:	mov    QWORD PTR [rsp+0x10],rcx
    4a5e:	mov    r13,rcx
    4a61:	sar    r8,1
    4a64:	mov    r15,r8
    4a67:	sar    r9,1
    4a6a:	mov    rbx,r9
    4a6d:	cmp    r15,rbx
    4a70:	jge    4b7b <botlish_fn_49+0x154>
    4a76:	mov    r12,rdx
    4a79:	mov    rdx,QWORD PTR [r12+0x8]
    4a7e:	mov    rcx,r15
    4a81:	shl    rcx,1
    4a84:	or     rcx,0x1
    4a88:	sar    rcx,1
    4a8b:	cmp    rcx,rdx
    4a8e:	jb     4abc <botlish_fn_49+0x95>
    4a94:	mov    rdx,r15
    4a97:	shl    rdx,1
    4a9a:	or     rdx,0x1
    4a9e:	mov    rsi,r12
    4aa1:	mov    rdi,QWORD PTR [rsp+0x28]
    4aa6:	call   4aab <botlish_fn_49+0x84>
			4aa7: R_X86_64_PLT32	rt_list_get-0x4
    4aab:	test   rax,rax
    4aae:	je     4b39 <botlish_fn_49+0x112>
    4ab4:	mov    rdx,rax
    4ab7:	jmp    4ac5 <botlish_fn_49+0x9e>
    4abc:	mov    rax,QWORD PTR [r12+0x10]
    4ac1:	mov    rdx,QWORD PTR [rax+rcx*8]
    4ac5:	mov    QWORD PTR [rsp+0x18],rdx
    4aca:	mov    QWORD PTR [rsp+0x30],rdx
    4acf:	mov    rax,QWORD PTR [r13+0x8]
    4ad3:	mov    rcx,r15
    4ad6:	shl    rcx,1
    4ad9:	or     rcx,0x1
    4add:	sar    rcx,1
    4ae0:	cmp    rcx,rax
    4ae3:	jb     4b11 <botlish_fn_49+0xea>
    4ae9:	mov    rdx,r15
    4aec:	shl    rdx,1
    4aef:	or     rdx,0x1
    4af3:	mov    rsi,r13
    4af6:	mov    rdi,QWORD PTR [rsp+0x28]
    4afb:	call   4b00 <botlish_fn_49+0xd9>
			4afc: R_X86_64_PLT32	rt_list_get-0x4
    4b00:	test   rax,rax
    4b03:	je     4b39 <botlish_fn_49+0x112>
    4b09:	mov    rcx,rax
    4b0c:	jmp    4b19 <botlish_fn_49+0xf2>
    4b11:	mov    rax,QWORD PTR [r13+0x10]
    4b15:	mov    rcx,QWORD PTR [rax+rcx*8]
    4b19:	mov    QWORD PTR [rsp+0x20],rcx
    4b1e:	mov    rdx,QWORD PTR [rsp+0x30]
    4b23:	mov    rsi,r14
    4b26:	mov    rdi,QWORD PTR [rsp+0x28]
    4b2b:	call   4b30 <botlish_fn_49+0x109>
			4b2c: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4b30:	test   rax,rax
    4b33:	jne    4b5e <botlish_fn_49+0x137>
    4b39:	xor    rax,rax
    4b3c:	mov    rbx,QWORD PTR [rsp+0x40]
    4b41:	mov    r12,QWORD PTR [rsp+0x48]
    4b46:	mov    r13,QWORD PTR [rsp+0x50]
    4b4b:	mov    r14,QWORD PTR [rsp+0x58]
    4b50:	mov    r15,QWORD PTR [rsp+0x60]
    4b55:	add    rsp,0x70
    4b59:	mov    rsp,rbp
    4b5c:	pop    rbp
    4b5d:	ret
    4b5e:	mov    QWORD PTR [rsp],r14
    4b62:	mov    QWORD PTR [rsp+0x8],r12
    4b67:	mov    QWORD PTR [rsp+0x10],r13
    4b6c:	add    r15,0x1
    4b73:	mov    rdx,r12
    4b76:	jmp    4a6d <botlish_fn_49+0x46>
    4b7b:	mov    rax,r14
    4b7e:	mov    rbx,QWORD PTR [rsp+0x40]
    4b83:	mov    r12,QWORD PTR [rsp+0x48]
    4b88:	mov    r13,QWORD PTR [rsp+0x50]
    4b8d:	mov    r14,QWORD PTR [rsp+0x58]
    4b92:	mov    r15,QWORD PTR [rsp+0x60]
    4b97:	add    rsp,0x70
    4b9b:	mov    rsp,rbp
    4b9e:	pop    rbp
    4b9f:	ret

0000000000004ba0 <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4ba0:	push   rbp
    4ba1:	mov    rbp,rsp
    4ba4:	mov    rsi,QWORD PTR [rdx]
    4ba7:	mov    r10,QWORD PTR [rdx+0x8]
    4bab:	mov    rcx,QWORD PTR [rdx+0x10]
    4baf:	mov    r8,QWORD PTR [rdx+0x18]
    4bb3:	mov    r9,QWORD PTR [rdx+0x20]
    4bb7:	mov    rdx,r10
    4bba:	call   4bbf <botlish_entry_49+0x1f>
			4bbb: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4bbf:	mov    rsp,rbp
    4bc2:	pop    rbp
    4bc3:	ret

0000000000004bc4 <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4bc4:	push   rbp
    4bc5:	mov    rbp,rsp
    4bc8:	sub    rsp,0x60
    4bcc:	mov    QWORD PTR [rsp+0x30],rbx
    4bd1:	mov    QWORD PTR [rsp+0x38],r12
    4bd6:	mov    QWORD PTR [rsp+0x40],r13
    4bdb:	mov    QWORD PTR [rsp+0x48],r14
    4be0:	mov    QWORD PTR [rsp+0x50],r15
    4be5:	mov    r13,rdi
    4be8:	mov    QWORD PTR [rsp+0x20],0x0
    4bf1:	mov    QWORD PTR [rsp],rsi
    4bf5:	mov    r14,rsi
    4bf8:	mov    QWORD PTR [rsp+0x8],rdx
    4bfd:	mov    QWORD PTR [rsp+0x10],rcx
    4c02:	mov    r12,rcx
    4c05:	mov    QWORD PTR [rsp+0x18],r8
    4c0a:	mov    rsi,r8
    4c0d:	mov    rdi,r13
    4c10:	call   4c15 <botlish_fn_50+0x51>
			4c11: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4c15:	test   rax,rax
    4c18:	je     4c64 <botlish_fn_50+0xa0>
    4c1e:	mov    QWORD PTR [rsp+0x8],rax
    4c23:	mov    r15,rax
    4c26:	mov    ebx,0x1
    4c2b:	mov    QWORD PTR [rsp+0x18],0x1
    4c34:	mov    rsi,r12
    4c37:	mov    rdi,r13
    4c3a:	call   4c3f <botlish_fn_50+0x7b>
			4c3b: R_X86_64_PLT32	rt_list_len-0x4
    4c3f:	mov    QWORD PTR [rsp+0x20],rax
    4c44:	mov    rcx,r12
    4c47:	mov    rdx,r14
    4c4a:	mov    rsi,r15
    4c4d:	mov    rdi,r13
    4c50:	mov    r8,rbx
    4c53:	mov    r9,rax
    4c56:	call   4c5b <botlish_fn_50+0x97>
			4c57: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4c5b:	test   rax,rax
    4c5e:	jne    4c89 <botlish_fn_50+0xc5>
    4c64:	xor    rax,rax
    4c67:	mov    rbx,QWORD PTR [rsp+0x30]
    4c6c:	mov    r12,QWORD PTR [rsp+0x38]
    4c71:	mov    r13,QWORD PTR [rsp+0x40]
    4c76:	mov    r14,QWORD PTR [rsp+0x48]
    4c7b:	mov    r15,QWORD PTR [rsp+0x50]
    4c80:	add    rsp,0x60
    4c84:	mov    rsp,rbp
    4c87:	pop    rbp
    4c88:	ret
    4c89:	mov    rbx,QWORD PTR [rsp+0x30]
    4c8e:	mov    r12,QWORD PTR [rsp+0x38]
    4c93:	mov    r13,QWORD PTR [rsp+0x40]
    4c98:	mov    r14,QWORD PTR [rsp+0x48]
    4c9d:	mov    r15,QWORD PTR [rsp+0x50]
    4ca2:	add    rsp,0x60
    4ca6:	mov    rsp,rbp
    4ca9:	pop    rbp
    4caa:	ret

0000000000004cab <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4cab:	push   rbp
    4cac:	mov    rbp,rsp
    4caf:	mov    rsi,QWORD PTR [rdx]
    4cb2:	mov    r9,QWORD PTR [rdx+0x8]
    4cb6:	mov    rcx,QWORD PTR [rdx+0x10]
    4cba:	mov    r8,QWORD PTR [rdx+0x18]
    4cbe:	mov    rdx,r9
    4cc1:	call   4cc6 <botlish_entry_50+0x1b>
			4cc2: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4cc6:	mov    rsp,rbp
    4cc9:	pop    rbp
    4cca:	ret

0000000000004ccb <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4ccb:	push   rbp
    4ccc:	mov    rbp,rsp
    4ccf:	sub    rsp,0x90
    4cd6:	mov    QWORD PTR [rsp+0x60],rbx
    4cdb:	mov    QWORD PTR [rsp+0x68],r12
    4ce0:	mov    QWORD PTR [rsp+0x70],r13
    4ce5:	mov    QWORD PTR [rsp+0x78],r14
    4cea:	mov    QWORD PTR [rsp+0x80],r15
    4cf2:	mov    r13,r8
    4cf5:	mov    QWORD PTR [rsp+0x38],rdi
    4cfa:	mov    rdi,QWORD PTR [rbp+0x10]
    4cfe:	mov    r15,QWORD PTR [rbp+0x18]
    4d02:	mov    QWORD PTR [rsp+0x28],0x0
    4d0b:	mov    QWORD PTR [rsp+0x30],0x0
    4d14:	mov    QWORD PTR [rsp],rsi
    4d18:	mov    QWORD PTR [rsp+0x8],rcx
    4d1d:	mov    r14,rcx
    4d20:	mov    QWORD PTR [rsp+0x10],r9
    4d25:	mov    QWORD PTR [rsp+0x18],rdi
    4d2a:	mov    QWORD PTR [rsp+0x20],r15
    4d2f:	sar    rdx,1
    4d32:	mov    r12,rdx
    4d35:	mov    rbx,rsi
    4d38:	mov    QWORD PTR [rsp+0x40],r9
    4d3d:	mov    QWORD PTR [rsp+0x48],rdi
    4d42:	mov    rsi,rbx
    4d45:	mov    rdi,QWORD PTR [rsp+0x38]
    4d4a:	call   4d4f <botlish_fn_51+0x84>
			4d4b: R_X86_64_PLT32	rt_list_len-0x4
    4d4f:	sar    rax,1
    4d52:	cmp    r12,rax
    4d55:	jge    4e80 <botlish_fn_51+0x1b5>
    4d5b:	mov    rax,r13
    4d5e:	or     rax,0x1
    4d62:	mov    QWORD PTR [rsp+0x28],rax
    4d67:	mov    rcx,QWORD PTR [rbx+0x8]
    4d6b:	mov    rax,r12
    4d6e:	shl    rax,1
    4d71:	or     rax,0x1
    4d75:	sar    rax,1
    4d78:	cmp    rax,rcx
    4d7b:	jb     4da9 <botlish_fn_51+0xde>
    4d81:	mov    rdx,r12
    4d84:	shl    rdx,1
    4d87:	or     rdx,0x1
    4d8b:	mov    rsi,rbx
    4d8e:	mov    rdi,QWORD PTR [rsp+0x38]
    4d93:	call   4d98 <botlish_fn_51+0xcd>
			4d94: R_X86_64_PLT32	rt_list_get-0x4
    4d98:	test   rax,rax
    4d9b:	je     4e9d <botlish_fn_51+0x1d2>
    4da1:	mov    rcx,rax
    4da4:	jmp    4db1 <botlish_fn_51+0xe6>
    4da9:	mov    rcx,QWORD PTR [rbx+0x10]
    4dad:	mov    rcx,QWORD PTR [rcx+rax*8]
    4db1:	mov    QWORD PTR [rsp+0x30],rcx
    4db6:	mov    rdx,r13
    4db9:	or     rdx,0x1
    4dbd:	mov    rsi,r14
    4dc0:	mov    rdi,QWORD PTR [rsp+0x38]
    4dc5:	mov    r8,r15
    4dc8:	call   4dcd <botlish_fn_51+0x102>
			4dc9: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4dcd:	test   rax,rax
    4dd0:	je     4e9d <botlish_fn_51+0x1d2>
    4dd6:	mov    QWORD PTR [rsp+0x28],rax
    4ddb:	mov    rcx,rax
    4dde:	mov    rsi,QWORD PTR [rsp+0x40]
    4de3:	mov    rdx,QWORD PTR [rsp+0x48]
    4de8:	mov    rdi,QWORD PTR [rsp+0x38]
    4ded:	call   4df2 <botlish_fn_51+0x127>
			4dee: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4df2:	test   rax,rax
    4df5:	je     4e9d <botlish_fn_51+0x1d2>
    4dfb:	mov    QWORD PTR [rsp+0x10],rax
    4e00:	mov    QWORD PTR [rsp+0x50],rax
    4e05:	mov    QWORD PTR [rsp+0x28],0x3
    4e0e:	mov    rsi,QWORD PTR [rsp+0x48]
    4e13:	test   rsi,0x1
    4e1a:	je     4e39 <botlish_fn_51+0x16e>
    4e20:	mov    rsi,QWORD PTR [rsp+0x48]
    4e25:	mov    rax,rsi
    4e28:	add    rax,0x2
    4e2c:	seto   r10b
    4e30:	test   r10b,r10b
    4e33:	je     4e4d <botlish_fn_51+0x182>
    4e39:	mov    edx,0x3
    4e3e:	mov    rsi,QWORD PTR [rsp+0x48]
    4e43:	mov    rdi,QWORD PTR [rsp+0x38]
    4e48:	call   4e4d <botlish_fn_51+0x182>
			4e49: R_X86_64_PLT32	rt_int_add-0x4
    4e4d:	mov    QWORD PTR [rsp],rbx
    4e51:	mov    QWORD PTR [rsp+0x8],r14
    4e56:	mov    rcx,QWORD PTR [rsp+0x50]
    4e5b:	mov    QWORD PTR [rsp+0x10],rcx
    4e60:	mov    QWORD PTR [rsp+0x18],rax
    4e65:	mov    QWORD PTR [rsp+0x20],r15
    4e6a:	add    r12,0x1
    4e71:	mov    QWORD PTR [rsp+0x40],rcx
    4e76:	mov    QWORD PTR [rsp+0x48],rax
    4e7b:	jmp    4d42 <botlish_fn_51+0x77>
    4e80:	mov    rdx,QWORD PTR [rsp+0x48]
    4e85:	mov    rsi,QWORD PTR [rsp+0x40]
    4e8a:	mov    rdi,QWORD PTR [rsp+0x38]
    4e8f:	call   4e94 <botlish_fn_51+0x1c9>
			4e90: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4e94:	test   rax,rax
    4e97:	jne    4ec8 <botlish_fn_51+0x1fd>
    4e9d:	xor    rax,rax
    4ea0:	mov    rbx,QWORD PTR [rsp+0x60]
    4ea5:	mov    r12,QWORD PTR [rsp+0x68]
    4eaa:	mov    r13,QWORD PTR [rsp+0x70]
    4eaf:	mov    r14,QWORD PTR [rsp+0x78]
    4eb4:	mov    r15,QWORD PTR [rsp+0x80]
    4ebc:	add    rsp,0x90
    4ec3:	mov    rsp,rbp
    4ec6:	pop    rbp
    4ec7:	ret
    4ec8:	mov    rbx,QWORD PTR [rsp+0x60]
    4ecd:	mov    r12,QWORD PTR [rsp+0x68]
    4ed2:	mov    r13,QWORD PTR [rsp+0x70]
    4ed7:	mov    r14,QWORD PTR [rsp+0x78]
    4edc:	mov    r15,QWORD PTR [rsp+0x80]
    4ee4:	add    rsp,0x90
    4eeb:	mov    rsp,rbp
    4eee:	pop    rbp
    4eef:	ret

0000000000004ef0 <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4ef0:	push   rbp
    4ef1:	mov    rbp,rsp
    4ef4:	sub    rsp,0x10
    4ef8:	mov    rsi,QWORD PTR [rdx]
    4efb:	mov    r10,QWORD PTR [rdx+0x8]
    4eff:	mov    rcx,QWORD PTR [rdx+0x10]
    4f03:	mov    r8,QWORD PTR [rdx+0x18]
    4f07:	mov    r9,QWORD PTR [rdx+0x20]
    4f0b:	mov    r11,QWORD PTR [rdx+0x28]
    4f0f:	mov    rax,QWORD PTR [rdx+0x30]
    4f13:	mov    QWORD PTR [rsp],r11
    4f17:	mov    QWORD PTR [rsp+0x8],rax
    4f1c:	mov    rdx,r10
    4f1f:	call   4f24 <botlish_entry_51+0x34>
			4f20: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4f24:	add    rsp,0x10
    4f28:	mov    rsp,rbp
    4f2b:	pop    rbp
    4f2c:	ret

0000000000004f2d <botlish_fn_52: csv_records_generic<str, bool>>:
    4f2d:	push   rbp
    4f2e:	mov    rbp,rsp
    4f31:	sub    rsp,0x80
    4f38:	mov    QWORD PTR [rsp+0x50],rbx
    4f3d:	mov    QWORD PTR [rsp+0x58],r12
    4f42:	mov    QWORD PTR [rsp+0x60],r13
    4f47:	mov    QWORD PTR [rsp+0x68],r14
    4f4c:	mov    QWORD PTR [rsp+0x70],r15
    4f51:	mov    r12,rdi
    4f54:	mov    QWORD PTR [rsp+0x20],0x0
    4f5d:	mov    QWORD PTR [rsp+0x28],0x0
    4f66:	mov    QWORD PTR [rsp+0x30],0x0
    4f6f:	mov    QWORD PTR [rsp+0x38],0x0
    4f78:	mov    QWORD PTR [rsp+0x40],0x0
    4f81:	mov    QWORD PTR [rsp+0x10],rsi
    4f86:	mov    QWORD PTR [rsp+0x18],rdx
    4f8b:	mov    r13,rdx
    4f8e:	mov    rdi,r12
    4f91:	call   4f96 <botlish_fn_52+0x69>
			4f92: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4f96:	mov    rcx,rax
    4f99:	mov    r15,rax
    4f9c:	test   rax,rcx
    4f9f:	je     5117 <botlish_fn_52+0x1ea>
    4fa5:	mov    rax,r15
    4fa8:	mov    QWORD PTR [rsp+0x10],rax
    4fad:	mov    rsi,r15
    4fb0:	mov    rdi,r12
    4fb3:	call   4fb8 <botlish_fn_52+0x8b>
			4fb4: R_X86_64_PLT32	rt_list_len-0x4
    4fb8:	sar    rax,1
    4fbb:	cmp    rax,0x1
    4fbf:	jle    5100 <botlish_fn_52+0x1d3>
    4fc5:	mov    rax,r15
    4fc8:	mov    rax,QWORD PTR [rax+0x8]
    4fcc:	test   rax,rax
    4fcf:	jne    4ff6 <botlish_fn_52+0xc9>
    4fd5:	mov    edx,0x1
    4fda:	mov    rsi,r15
    4fdd:	mov    rdi,r12
    4fe0:	call   4fe5 <botlish_fn_52+0xb8>
			4fe1: R_X86_64_PLT32	rt_list_get-0x4
    4fe5:	test   rax,rax
    4fe8:	je     5117 <botlish_fn_52+0x1ea>
    4fee:	mov    rbx,rax
    4ff1:	jmp    4ffd <botlish_fn_52+0xd0>
    4ff6:	mov    rax,QWORD PTR [r15+0x10]
    4ffa:	mov    rbx,QWORD PTR [rax]
    4ffd:	mov    QWORD PTR [rsp+0x20],rbx
    5002:	mov    rsi,rbx
    5005:	mov    rdi,r12
    5008:	call   500d <botlish_fn_52+0xe0>
			5009: R_X86_64_PLT32	rt_list_len-0x4
    500d:	mov    r14,rax
    5010:	mov    QWORD PTR [rsp+0x48],rbx
    5015:	mov    QWORD PTR [rsp+0x28],r14
    501a:	mov    rax,QWORD PTR [r15+0x8]
    501e:	cmp    rax,0x1
    5022:	ja     5049 <botlish_fn_52+0x11c>
    5028:	mov    edx,0x3
    502d:	mov    rsi,r15
    5030:	mov    rdi,r12
    5033:	call   5038 <botlish_fn_52+0x10b>
			5034: R_X86_64_PLT32	rt_list_get-0x4
    5038:	test   rax,rax
    503b:	je     5117 <botlish_fn_52+0x1ea>
    5041:	mov    rcx,rax
    5044:	jmp    5051 <botlish_fn_52+0x124>
    5049:	mov    rax,QWORD PTR [r15+0x10]
    504d:	mov    rcx,QWORD PTR [rax+0x8]
    5051:	mov    QWORD PTR [rsp+0x30],rcx
    5056:	mov    rbx,r13
    5059:	mov    rdx,r14
    505c:	mov    rsi,QWORD PTR [rsp+0x48]
    5061:	mov    rdi,r12
    5064:	mov    r8,rbx
    5067:	call   506c <botlish_fn_52+0x13f>
			5068: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    506c:	mov    r13,r14
    506f:	test   rax,rax
    5072:	je     5117 <botlish_fn_52+0x1ea>
    5078:	mov    QWORD PTR [rsp+0x30],rax
    507d:	mov    rsi,rax
    5080:	mov    QWORD PTR [rsp+0x38],0x5
    5089:	mov    rdi,r12
    508c:	call   5091 <botlish_fn_52+0x164>
			508d: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    5091:	test   rax,rax
    5094:	je     5117 <botlish_fn_52+0x1ea>
    509a:	mov    QWORD PTR [rsp+0x30],rax
    509f:	mov    r9,rax
    50a2:	mov    r10d,0x3
    50a8:	mov    QWORD PTR [rsp+0x40],0x3
    50b1:	mov    edx,0x5
    50b6:	mov    QWORD PTR [rsp],r10
    50ba:	mov    QWORD PTR [rsp+0x8],rbx
    50bf:	mov    rcx,QWORD PTR [rsp+0x48]
    50c4:	mov    rsi,r15
    50c7:	mov    rdi,r12
    50ca:	mov    r8,r13
    50cd:	call   50d2 <botlish_fn_52+0x1a5>
			50ce: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    50d2:	test   rax,rax
    50d5:	je     5117 <botlish_fn_52+0x1ea>
    50db:	mov    rbx,QWORD PTR [rsp+0x50]
    50e0:	mov    r12,QWORD PTR [rsp+0x58]
    50e5:	mov    r13,QWORD PTR [rsp+0x60]
    50ea:	mov    r14,QWORD PTR [rsp+0x68]
    50ef:	mov    r15,QWORD PTR [rsp+0x70]
    50f4:	add    rsp,0x80
    50fb:	mov    rsp,rbp
    50fe:	pop    rbp
    50ff:	ret
    5100:	xor    rdx,rdx
    5103:	mov    rdi,r12
    5106:	mov    rsi,rdx
    5109:	call   510e <botlish_fn_52+0x1e1>
			510a: R_X86_64_PLT32	rt_list_new-0x4
    510e:	test   rax,rax
    5111:	jne    513f <botlish_fn_52+0x212>
    5117:	xor    rax,rax
    511a:	mov    rbx,QWORD PTR [rsp+0x50]
    511f:	mov    r12,QWORD PTR [rsp+0x58]
    5124:	mov    r13,QWORD PTR [rsp+0x60]
    5129:	mov    r14,QWORD PTR [rsp+0x68]
    512e:	mov    r15,QWORD PTR [rsp+0x70]
    5133:	add    rsp,0x80
    513a:	mov    rsp,rbp
    513d:	pop    rbp
    513e:	ret
    513f:	mov    rbx,QWORD PTR [rsp+0x50]
    5144:	mov    r12,QWORD PTR [rsp+0x58]
    5149:	mov    r13,QWORD PTR [rsp+0x60]
    514e:	mov    r14,QWORD PTR [rsp+0x68]
    5153:	mov    r15,QWORD PTR [rsp+0x70]
    5158:	add    rsp,0x80
    515f:	mov    rsp,rbp
    5162:	pop    rbp
    5163:	ret

0000000000005164 <botlish_entry_52: csv_records_generic<str, bool>>:
    5164:	push   rbp
    5165:	mov    rbp,rsp
    5168:	mov    rsi,QWORD PTR [rdx]
    516b:	mov    rdx,QWORD PTR [rdx+0x8]
    516f:	call   5174 <botlish_entry_52+0x10>
			5170: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5174:	mov    rsp,rbp
    5177:	pop    rbp
    5178:	ret

0000000000005179 <botlish_fn_53: csv_records<str>>:
    5179:	push   rbp
    517a:	mov    rbp,rsp
    517d:	sub    rsp,0x10
    5181:	mov    QWORD PTR [rsp],rsi
    5185:	mov    edx,0x2
    518a:	mov    QWORD PTR [rsp+0x8],0x2
    5193:	call   5198 <botlish_fn_53+0x1f>
			5194: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5198:	test   rax,rax
    519b:	jne    51ad <botlish_fn_53+0x34>
    51a1:	xor    rax,rax
    51a4:	add    rsp,0x10
    51a8:	mov    rsp,rbp
    51ab:	pop    rbp
    51ac:	ret
    51ad:	add    rsp,0x10
    51b1:	mov    rsp,rbp
    51b4:	pop    rbp
    51b5:	ret

00000000000051b6 <botlish_entry_53: csv_records<str>>:
    51b6:	push   rbp
    51b7:	mov    rbp,rsp
    51ba:	mov    rsi,QWORD PTR [rdx]
    51bd:	call   51c2 <botlish_entry_53+0xc>
			51be: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    51c2:	mov    rsp,rbp
    51c5:	pop    rbp
    51c6:	ret

00000000000051c7 <botlish_fn_54: csv_records_presized<str>>:
    51c7:	push   rbp
    51c8:	mov    rbp,rsp
    51cb:	sub    rsp,0x10
    51cf:	mov    QWORD PTR [rsp],rsi
    51d3:	mov    edx,0x6
    51d8:	mov    QWORD PTR [rsp+0x8],0x6
    51e1:	call   51e6 <botlish_fn_54+0x1f>
			51e2: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    51e6:	test   rax,rax
    51e9:	jne    51fb <botlish_fn_54+0x34>
    51ef:	xor    rax,rax
    51f2:	add    rsp,0x10
    51f6:	mov    rsp,rbp
    51f9:	pop    rbp
    51fa:	ret
    51fb:	add    rsp,0x10
    51ff:	mov    rsp,rbp
    5202:	pop    rbp
    5203:	ret

0000000000005204 <botlish_entry_54: csv_records_presized<str>>:
    5204:	push   rbp
    5205:	mov    rbp,rsp
    5208:	mov    rsi,QWORD PTR [rdx]
    520b:	call   5210 <botlish_entry_54+0xc>
			520c: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5210:	mov    rsp,rbp
    5213:	pop    rbp
    5214:	ret
    5215:	add    BYTE PTR [rax],al
	...

0000000000005218 <botlish_fn_55: sample<generic>>:
    5218:	push   rbp
    5219:	mov    rbp,rsp
    521c:	sub    rsp,0xc0
    5223:	mov    QWORD PTR [rsp+0x90],rbx
    522b:	mov    QWORD PTR [rsp+0x98],r12
    5233:	mov    QWORD PTR [rsp+0xa0],r13
    523b:	mov    QWORD PTR [rsp+0xa8],r14
    5243:	mov    QWORD PTR [rsp+0xb0],r15
    524b:	mov    QWORD PTR [rsp+0x8],0x0
    5254:	mov    QWORD PTR [rsp+0x10],0x0
    525d:	mov    QWORD PTR [rsp+0x18],0x0
    5266:	mov    QWORD PTR [rsp+0x20],0x0
    526f:	mov    QWORD PTR [rsp+0x28],0x0
    5278:	mov    QWORD PTR [rsp+0x30],0x0
    5281:	mov    QWORD PTR [rsp+0x38],0x0
    528a:	mov    rax,QWORD PTR [rdi+0x10]
    528e:	mov    r13,rdi
    5291:	mov    rsi,QWORD PTR [rax+0x50]
    5295:	mov    QWORD PTR [rsp],rsi
    5299:	call   529e <botlish_fn_55+0x86>
			529a: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    529e:	mov    rsi,rax
    52a1:	mov    r12,rax
    52a4:	test   rax,rsi
    52a7:	je     562c <botlish_fn_55+0x414>
    52ad:	mov    rax,r12
    52b0:	mov    QWORD PTR [rsp],rax
    52b4:	mov    rdi,r13
    52b7:	mov    rax,QWORD PTR [rdi+0x10]
    52bb:	mov    rsi,QWORD PTR [rax+0x50]
    52bf:	mov    QWORD PTR [rsp+0x8],rsi
    52c4:	call   52c9 <botlish_fn_55+0xb1>
			52c5: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    52c9:	mov    rbx,rax
    52cc:	test   rbx,rbx
    52cf:	je     562c <botlish_fn_55+0x414>
    52d5:	mov    rax,r12
    52d8:	mov    rax,QWORD PTR [rax+0x8]
    52dc:	test   rax,rax
    52df:	jne    5306 <botlish_fn_55+0xee>
    52e5:	mov    edx,0x1
    52ea:	mov    rsi,r12
    52ed:	mov    rdi,r13
    52f0:	call   52f5 <botlish_fn_55+0xdd>
			52f1: R_X86_64_PLT32	rt_list_get-0x4
    52f5:	test   rax,rax
    52f8:	je     562c <botlish_fn_55+0x414>
    52fe:	mov    rsi,rax
    5301:	jmp    530e <botlish_fn_55+0xf6>
    5306:	mov    rax,QWORD PTR [r12+0x10]
    530b:	mov    rsi,QWORD PTR [rax]
    530e:	mov    QWORD PTR [rsp+0x8],rsi
    5313:	mov    r15,rsi
    5316:	mov    rax,QWORD PTR [r12+0x8]
    531b:	cmp    rax,0x1
    531f:	ja     5346 <botlish_fn_55+0x12e>
    5325:	mov    edx,0x3
    532a:	mov    rsi,r12
    532d:	mov    rdi,r13
    5330:	call   5335 <botlish_fn_55+0x11d>
			5331: R_X86_64_PLT32	rt_list_get-0x4
    5335:	test   rax,rax
    5338:	je     562c <botlish_fn_55+0x414>
    533e:	mov    rsi,rax
    5341:	jmp    534f <botlish_fn_55+0x137>
    5346:	mov    rax,QWORD PTR [r12+0x10]
    534b:	mov    rsi,QWORD PTR [rax+0x8]
    534f:	mov    QWORD PTR [rsp+0x10],rsi
    5354:	mov    r14,rsi
    5357:	mov    rax,QWORD PTR [rbx+0x8]
    535b:	mov    rsi,rbx
    535e:	test   rax,rax
    5361:	jne    5385 <botlish_fn_55+0x16d>
    5367:	mov    edx,0x1
    536c:	mov    rdi,r13
    536f:	call   5374 <botlish_fn_55+0x15c>
			5370: R_X86_64_PLT32	rt_list_get-0x4
    5374:	test   rax,rax
    5377:	je     562c <botlish_fn_55+0x414>
    537d:	mov    rsi,rax
    5380:	jmp    538c <botlish_fn_55+0x174>
    5385:	mov    rax,QWORD PTR [rsi+0x10]
    5389:	mov    rsi,QWORD PTR [rax]
    538c:	mov    QWORD PTR [rsp+0x18],rsi
    5391:	mov    rdi,r13
    5394:	mov    QWORD PTR [rsp+0x78],rsi
    5399:	mov    rax,QWORD PTR [rdi+0x10]
    539d:	mov    rdx,QWORD PTR [rax+0x58]
    53a1:	mov    QWORD PTR [rsp+0x20],rdx
    53a6:	mov    rsi,r15
    53a9:	call   53ae <botlish_fn_55+0x196>
			53aa: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    53ae:	test   rax,rax
    53b1:	je     562c <botlish_fn_55+0x414>
    53b7:	mov    QWORD PTR [rsp+0x20],rax
    53bc:	mov    rbx,rax
    53bf:	mov    rdi,r13
    53c2:	mov    rax,QWORD PTR [rdi+0x10]
    53c6:	mov    rdx,QWORD PTR [rax+0x58]
    53ca:	mov    QWORD PTR [rsp+0x28],rdx
    53cf:	mov    rsi,QWORD PTR [rsp+0x78]
    53d4:	call   53d9 <botlish_fn_55+0x1c1>
			53d5: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    53d9:	test   rax,rax
    53dc:	je     562c <botlish_fn_55+0x414>
    53e2:	mov    rcx,rbx
    53e5:	mov    rdx,rcx
    53e8:	and    rdx,rax
    53eb:	test   rdx,0x1
    53f2:	jne    5414 <botlish_fn_55+0x1fc>
    53f8:	mov    rdx,rax
    53fb:	mov    rsi,rbx
    53fe:	mov    rdi,r13
    5401:	call   5406 <botlish_fn_55+0x1ee>
			5402: R_X86_64_PLT32	rt_value_eq-0x4
    5406:	test   rax,rax
    5409:	je     562c <botlish_fn_55+0x414>
    540f:	jmp    542a <botlish_fn_55+0x212>
    5414:	mov    rdx,rax
    5417:	mov    rsi,rbx
    541a:	mov    eax,0x2
    541f:	cmp    rsi,rdx
    5422:	cmove  rax,QWORD PTR [rip+0x26e]        # 5698 <botlish_fn_55+0x480>
    542a:	mov    ebx,0x6
    542f:	cmp    rax,0x6
    5433:	je     544e <botlish_fn_55+0x236>
    5439:	mov    ebx,0x2
    543e:	mov    QWORD PTR [rsp],0x2
    5446:	mov    rsi,r12
    5449:	jmp    54ed <botlish_fn_55+0x2d5>
    544e:	mov    rsi,r15
    5451:	mov    rdi,r13
    5454:	call   5459 <botlish_fn_55+0x241>
			5455: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5459:	test   rax,rax
    545c:	mov    QWORD PTR [rsp+0x88],rax
    5464:	je     562c <botlish_fn_55+0x414>
    546a:	mov    rsi,QWORD PTR [rsp+0x78]
    546f:	mov    rdi,r13
    5472:	call   5477 <botlish_fn_55+0x25f>
			5473: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5477:	test   rax,rax
    547a:	je     562c <botlish_fn_55+0x414>
    5480:	mov    rcx,QWORD PTR [rsp+0x88]
    5488:	mov    rdx,rcx
    548b:	and    rdx,rax
    548e:	test   rdx,0x1
    5495:	jne    54bc <botlish_fn_55+0x2a4>
    549b:	mov    rdx,rax
    549e:	mov    rsi,QWORD PTR [rsp+0x88]
    54a6:	mov    rdi,r13
    54a9:	call   54ae <botlish_fn_55+0x296>
			54aa: R_X86_64_PLT32	rt_value_eq-0x4
    54ae:	test   rax,rax
    54b1:	je     562c <botlish_fn_55+0x414>
    54b7:	jmp    54d7 <botlish_fn_55+0x2bf>
    54bc:	mov    rdx,rax
    54bf:	mov    rsi,QWORD PTR [rsp+0x88]
    54c7:	mov    eax,0x2
    54cc:	cmp    rsi,rdx
    54cf:	cmove  rax,QWORD PTR [rip+0x1c1]        # 5698 <botlish_fn_55+0x480>
    54d7:	cmp    rax,0x6
    54db:	je     54e6 <botlish_fn_55+0x2ce>
    54e1:	mov    ebx,0x2
    54e6:	mov    QWORD PTR [rsp],rbx
    54ea:	mov    rsi,r12
    54ed:	mov    rdi,r13
    54f0:	call   54f5 <botlish_fn_55+0x2dd>
			54f1: R_X86_64_PLT32	rt_list_len-0x4
    54f5:	mov    QWORD PTR [rsp+0x18],rax
    54fa:	mov    rdi,r13
    54fd:	mov    r12,rax
    5500:	mov    rax,QWORD PTR [rdi+0x10]
    5504:	mov    rdx,QWORD PTR [rax+0x58]
    5508:	mov    QWORD PTR [rsp+0x20],rdx
    550d:	mov    rsi,r15
    5510:	call   5515 <botlish_fn_55+0x2fd>
			5511: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5515:	test   rax,rax
    5518:	je     562c <botlish_fn_55+0x414>
    551e:	mov    QWORD PTR [rsp+0x20],rax
    5523:	mov    rdi,r13
    5526:	mov    QWORD PTR [rsp+0x88],rax
    552e:	mov    rax,QWORD PTR [rdi+0x10]
    5532:	mov    rdx,QWORD PTR [rax+0x60]
    5536:	mov    QWORD PTR [rsp+0x28],rdx
    553b:	mov    rsi,r15
    553e:	call   5543 <botlish_fn_55+0x32b>
			553f: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5543:	test   rax,rax
    5546:	je     562c <botlish_fn_55+0x414>
    554c:	mov    QWORD PTR [rsp+0x28],rax
    5551:	mov    rdi,r13
    5554:	mov    QWORD PTR [rsp+0x80],rax
    555c:	mov    rax,QWORD PTR [rdi+0x10]
    5560:	mov    rdx,QWORD PTR [rax+0x68]
    5564:	mov    QWORD PTR [rsp+0x30],rdx
    5569:	mov    rsi,r15
    556c:	call   5571 <botlish_fn_55+0x359>
			556d: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5571:	test   rax,rax
    5574:	je     562c <botlish_fn_55+0x414>
    557a:	mov    QWORD PTR [rsp+0x8],rax
    557f:	mov    rdi,r13
    5582:	mov    r15,rax
    5585:	mov    rax,QWORD PTR [rdi+0x10]
    5589:	mov    rdx,QWORD PTR [rax+0x58]
    558d:	mov    QWORD PTR [rsp+0x30],rdx
    5592:	mov    rsi,r14
    5595:	call   559a <botlish_fn_55+0x382>
			5596: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    559a:	test   rax,rax
    559d:	je     562c <botlish_fn_55+0x414>
    55a3:	mov    QWORD PTR [rsp+0x30],rax
    55a8:	mov    rdi,r13
    55ab:	mov    QWORD PTR [rsp+0x78],rax
    55b0:	mov    rax,QWORD PTR [rdi+0x10]
    55b4:	mov    rdx,QWORD PTR [rax+0x68]
    55b8:	mov    QWORD PTR [rsp+0x38],rdx
    55bd:	mov    rsi,r14
    55c0:	call   55c5 <botlish_fn_55+0x3ad>
			55c1: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    55c5:	test   rax,rax
    55c8:	je     562c <botlish_fn_55+0x414>
    55ce:	mov    QWORD PTR [rsp+0x10],rax
    55d3:	lea    rdx,[rsp+0x40]
    55d8:	mov    r9,r12
    55db:	mov    QWORD PTR [rsp+0x40],r9
    55e0:	mov    rcx,QWORD PTR [rsp+0x88]
    55e8:	mov    QWORD PTR [rsp+0x48],rcx
    55ed:	mov    rcx,QWORD PTR [rsp+0x80]
    55f5:	mov    QWORD PTR [rsp+0x50],rcx
    55fa:	mov    rcx,r15
    55fd:	mov    QWORD PTR [rsp+0x58],rcx
    5602:	mov    rcx,QWORD PTR [rsp+0x78]
    5607:	mov    QWORD PTR [rsp+0x60],rcx
    560c:	mov    QWORD PTR [rsp+0x68],rax
    5611:	mov    QWORD PTR [rsp+0x70],rbx
    5616:	mov    esi,0x7
    561b:	mov    rdi,r13
    561e:	call   5623 <botlish_fn_55+0x40b>
			561f: R_X86_64_PLT32	rt_list_new-0x4
    5623:	test   rax,rax
    5626:	jne    5663 <botlish_fn_55+0x44b>
    562c:	xor    rax,rax
    562f:	mov    rbx,QWORD PTR [rsp+0x90]
    5637:	mov    r12,QWORD PTR [rsp+0x98]
    563f:	mov    r13,QWORD PTR [rsp+0xa0]
    5647:	mov    r14,QWORD PTR [rsp+0xa8]
    564f:	mov    r15,QWORD PTR [rsp+0xb0]
    5657:	add    rsp,0xc0
    565e:	mov    rsp,rbp
    5661:	pop    rbp
    5662:	ret
    5663:	mov    rbx,QWORD PTR [rsp+0x90]
    566b:	mov    r12,QWORD PTR [rsp+0x98]
    5673:	mov    r13,QWORD PTR [rsp+0xa0]
    567b:	mov    r14,QWORD PTR [rsp+0xa8]
    5683:	mov    r15,QWORD PTR [rsp+0xb0]
    568b:	add    rsp,0xc0
    5692:	mov    rsp,rbp
    5695:	pop    rbp
    5696:	ret
    5697:	add    BYTE PTR [rsi],al
    5699:	add    BYTE PTR [rax],al
    569b:	add    BYTE PTR [rax],al
    569d:	add    BYTE PTR [rax],al
	...

00000000000056a0 <botlish_entry_55: sample<generic>>:
    56a0:	push   rbp
    56a1:	mov    rbp,rsp
    56a4:	call   56a9 <botlish_entry_55+0x9>
			56a5: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample<generic>
    56a9:	mov    rsp,rbp
    56ac:	pop    rbp
    56ad:	ret

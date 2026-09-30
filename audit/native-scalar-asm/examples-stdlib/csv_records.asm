; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23650  (per function: 45 461 461 461 81 81 81 357 412 412 412 278 278 278 81 365 430 585 1063 352 783 215 488 325 388 524 70 493 114 61 61 61 61 61 168 179 179 245 804 1248 429 380 439 977 766 817 665 1168 836 107 524 335 629 698 78 78 1222)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> mutarray::create<int, str>
;   botlish_fn_2 / botlish_entry_2 -> mutarray::create<int, list>
;   botlish_fn_3 / botlish_entry_3 -> mutarray::create<int, mutarray>
;   botlish_fn_4 / botlish_entry_4 -> geo_new<str>
;   botlish_fn_5 / botlish_entry_5 -> geo_new<list>
;   botlish_fn_6 / botlish_entry_6 -> geo_new<mutarray>
;   botlish_fn_7 / botlish_entry_7 -> geo_new_capacity<int, int>
;   botlish_fn_8 / botlish_entry_8 -> geo_grow<mutarray, int, str>
;   botlish_fn_9 / botlish_entry_9 -> geo_grow<mutarray, int, list>
;   botlish_fn_10 / botlish_entry_10 -> geo_grow<mutarray, int, mutarray>
;   botlish_fn_11 / botlish_entry_11 -> geo_append<mutarray, int, str>
;   botlish_fn_12 / botlish_entry_12 -> geo_append<mutarray, int, list>
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
;   botlish_fn_35 / botlish_entry_35 -> ht_probe_start<mutarray, any>
;   botlish_fn_36 / botlish_entry_36 -> ht_probe_start<mutarray, str>
;   botlish_fn_37 / botlish_entry_37 -> ht_probe_next<mutarray, int>
;   botlish_fn_38 / botlish_entry_38 -> ht_find_get<mutarray, str, int>
;   botlish_fn_39 / botlish_entry_39 -> ht_find_insert<mutarray, any, int, int>
;   botlish_fn_40 / botlish_entry_40 -> ht_get<mutarray, str>
;   botlish_fn_41 / botlish_entry_41 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_42 / botlish_entry_42 -> ht_rehash_insert<List[mutarray], int, any, any>
;   botlish_fn_43 / botlish_entry_43 -> ht_rehash_scan<list, int, int, List[mutarray], int>
;   botlish_fn_44 / botlish_entry_44 -> ht_rehash<mutarray, int>
;   botlish_fn_45 / botlish_entry_45 -> ht_should_grow<mutarray>
;   botlish_fn_46 / botlish_entry_46 -> ht_grow_or_clean<mutarray>
;   botlish_fn_47 / botlish_entry_47 -> ht_place<mutarray, int, any, any>
;   botlish_fn_48 / botlish_entry_48 -> ht_set<mutarray, any, any>
;   botlish_fn_49 / botlish_entry_49 -> row_new<bool, int>
;   botlish_fn_50 / botlish_entry_50 -> row_fill<mutarray, list, any, int, int>
;   botlish_fn_51 / botlish_entry_51 -> row_table<list, int, any, bool>
;   botlish_fn_52 / botlish_entry_52 -> build_rows<list, int, list, int, mutarray, int, bool>
;   botlish_fn_53 / botlish_entry_53 -> csv_records_generic<str, bool>
;   botlish_fn_54 / botlish_entry_54 -> csv_records<str>
;   botlish_fn_55 / botlish_entry_55 -> csv_records_presized<str>
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

00000000000001e0 <botlish_fn_2: mutarray::create<int, list>>:
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

0000000000000378 <botlish_entry_2: mutarray::create<int, list>>:
     378:	push   rbp
     379:	mov    rbp,rsp
     37c:	mov    rsi,QWORD PTR [rdx]
     37f:	mov    rdx,QWORD PTR [rdx+0x8]
     383:	call   388 <botlish_entry_2+0x10>
			384: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, list>
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

000000000000058e <botlish_fn_5: geo_new<list>>:
     58e:	push   rbp
     58f:	mov    rbp,rsp
     592:	sub    rsp,0x10
     596:	mov    QWORD PTR [rsp],rsi
     59a:	mov    rdx,rsi
     59d:	mov    esi,0x3
     5a2:	mov    QWORD PTR [rsp+0x8],0x3
     5ab:	call   5b0 <botlish_fn_5+0x22>
			5ac: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, list>
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

00000000000005ce <botlish_entry_5: geo_new<list>>:
     5ce:	push   rbp
     5cf:	mov    rbp,rsp
     5d2:	mov    rsi,QWORD PTR [rdx]
     5d5:	call   5da <botlish_entry_5+0xc>
			5d6: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<list>
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

0000000000000910 <botlish_fn_9: geo_grow<mutarray, int, list>>:
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
			9d1: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, list>
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

0000000000000a80 <botlish_entry_9: geo_grow<mutarray, int, list>>:
     a80:	push   rbp
     a81:	mov    rbp,rsp
     a84:	mov    rsi,QWORD PTR [rdx]
     a87:	mov    r8,QWORD PTR [rdx+0x8]
     a8b:	mov    rcx,QWORD PTR [rdx+0x10]
     a8f:	mov    rdx,r8
     a92:	call   a97 <botlish_entry_9+0x17>
			a93: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, list>
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

0000000000000d34 <botlish_fn_12: geo_append<mutarray, int, list>>:
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
			d71: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, list>
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

0000000000000e20 <botlish_entry_12: geo_append<mutarray, int, list>>:
     e20:	push   rbp
     e21:	mov    rbp,rsp
     e24:	mov    rsi,QWORD PTR [rdx]
     e27:	mov    r8,QWORD PTR [rdx+0x8]
     e2b:	mov    rcx,QWORD PTR [rdx+0x10]
     e2f:	mov    rdx,r8
     e32:	call   e37 <botlish_entry_12+0x17>
			e33: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, list>
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
			1e90: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, list>
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
			2019: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<list>
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

0000000000002832 <botlish_fn_35: ht_probe_start<mutarray, any>>:
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

00000000000028c1 <botlish_entry_35: ht_probe_start<mutarray, any>>:
    28c1:	push   rbp
    28c2:	mov    rbp,rsp
    28c5:	mov    rsi,QWORD PTR [rdx]
    28c8:	mov    rdx,QWORD PTR [rdx+0x8]
    28cc:	call   28d1 <botlish_entry_35+0x10>
			28cd: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, any>
    28d1:	mov    rsp,rbp
    28d4:	pop    rbp
    28d5:	ret

00000000000028d6 <botlish_fn_36: ht_probe_start<mutarray, str>>:
    28d6:	push   rbp
    28d7:	mov    rbp,rsp
    28da:	sub    rsp,0x20
    28de:	mov    QWORD PTR [rsp],r12
    28e2:	mov    QWORD PTR [rsp+0x8],r13
    28e7:	mov    QWORD PTR [rsp+0x10],r14
    28ec:	mov    r12,rdi
    28ef:	mov    r14,rsi
    28f2:	mov    rsi,rdx
    28f5:	mov    rdi,r12
    28f8:	call   28fd <botlish_fn_36+0x27>
			28f9: R_X86_64_PLT32	rt_hash-0x4
    28fd:	test   rax,rax
    2900:	mov    r13,rax
    2903:	je     2934 <botlish_fn_36+0x5e>
    2909:	mov    rsi,r14
    290c:	mov    rdi,r12
    290f:	call   2914 <botlish_fn_36+0x3e>
			2910: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2914:	test   rax,rax
    2917:	mov    rdx,rax
    291a:	je     2934 <botlish_fn_36+0x5e>
    2920:	mov    rsi,r13
    2923:	mov    rdi,r12
    2926:	call   292b <botlish_fn_36+0x55>
			2927: R_X86_64_PLT32	rt_int_mod-0x4
    292b:	test   rax,rax
    292e:	jne    294e <botlish_fn_36+0x78>
    2934:	xor    rax,rax
    2937:	mov    r12,QWORD PTR [rsp]
    293b:	mov    r13,QWORD PTR [rsp+0x8]
    2940:	mov    r14,QWORD PTR [rsp+0x10]
    2945:	add    rsp,0x20
    2949:	mov    rsp,rbp
    294c:	pop    rbp
    294d:	ret
    294e:	mov    r12,QWORD PTR [rsp]
    2952:	mov    r13,QWORD PTR [rsp+0x8]
    2957:	mov    r14,QWORD PTR [rsp+0x10]
    295c:	add    rsp,0x20
    2960:	mov    rsp,rbp
    2963:	pop    rbp
    2964:	ret

0000000000002965 <botlish_entry_36: ht_probe_start<mutarray, str>>:
    2965:	push   rbp
    2966:	mov    rbp,rsp
    2969:	mov    rsi,QWORD PTR [rdx]
    296c:	mov    rdx,QWORD PTR [rdx+0x8]
    2970:	call   2975 <botlish_entry_36+0x10>
			2971: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, str>
    2975:	mov    rsp,rbp
    2978:	pop    rbp
    2979:	ret

000000000000297a <botlish_fn_37: ht_probe_next<mutarray, int>>:
    297a:	push   rbp
    297b:	mov    rbp,rsp
    297e:	sub    rsp,0x40
    2982:	mov    QWORD PTR [rsp+0x20],rbx
    2987:	mov    QWORD PTR [rsp+0x28],r12
    298c:	mov    QWORD PTR [rsp+0x30],r13
    2991:	mov    r13,rdi
    2994:	mov    QWORD PTR [rsp],rsi
    2998:	mov    rbx,rsi
    299b:	mov    QWORD PTR [rsp+0x8],rdx
    29a0:	mov    QWORD PTR [rsp+0x10],0x3
    29a9:	test   rdx,0x1
    29b0:	jne    29be <botlish_fn_37+0x44>
    29b6:	mov    rsi,rdx
    29b9:	jmp    29de <botlish_fn_37+0x64>
    29be:	mov    rsi,rdx
    29c1:	add    rsi,0x2
    29c5:	mov    r12,rsi
    29c8:	mov    rsi,rdx
    29cb:	seto   al
    29ce:	test   al,al
    29d0:	jne    29de <botlish_fn_37+0x64>
    29d6:	mov    rsi,rbx
    29d9:	jmp    29f1 <botlish_fn_37+0x77>
    29de:	mov    edx,0x3
    29e3:	mov    rdi,r13
    29e6:	call   29eb <botlish_fn_37+0x71>
			29e7: R_X86_64_PLT32	rt_int_add-0x4
    29eb:	mov    rsi,rbx
    29ee:	mov    r12,rax
    29f1:	mov    rdi,r13
    29f4:	call   29f9 <botlish_fn_37+0x7f>
			29f5: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    29f9:	test   rax,rax
    29fc:	mov    rdx,rax
    29ff:	je     2a19 <botlish_fn_37+0x9f>
    2a05:	mov    rsi,r12
    2a08:	mov    rdi,r13
    2a0b:	call   2a10 <botlish_fn_37+0x96>
			2a0c: R_X86_64_PLT32	rt_int_mod-0x4
    2a10:	test   rax,rax
    2a13:	jne    2a34 <botlish_fn_37+0xba>
    2a19:	xor    rax,rax
    2a1c:	mov    rbx,QWORD PTR [rsp+0x20]
    2a21:	mov    r12,QWORD PTR [rsp+0x28]
    2a26:	mov    r13,QWORD PTR [rsp+0x30]
    2a2b:	add    rsp,0x40
    2a2f:	mov    rsp,rbp
    2a32:	pop    rbp
    2a33:	ret
    2a34:	mov    rbx,QWORD PTR [rsp+0x20]
    2a39:	mov    r12,QWORD PTR [rsp+0x28]
    2a3e:	mov    r13,QWORD PTR [rsp+0x30]
    2a43:	add    rsp,0x40
    2a47:	mov    rsp,rbp
    2a4a:	pop    rbp
    2a4b:	ret

0000000000002a4c <botlish_entry_37: ht_probe_next<mutarray, int>>:
    2a4c:	push   rbp
    2a4d:	mov    rbp,rsp
    2a50:	mov    rsi,QWORD PTR [rdx]
    2a53:	mov    rdx,QWORD PTR [rdx+0x8]
    2a57:	call   2a5c <botlish_entry_37+0x10>
			2a58: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_next<mutarray, int>
    2a5c:	mov    rsp,rbp
    2a5f:	pop    rbp
    2a60:	ret
    2a61:	add    BYTE PTR [rax],al
    2a63:	add    BYTE PTR [rax],al
    2a65:	add    BYTE PTR [rax],al
	...

0000000000002a68 <botlish_fn_38: ht_find_get<mutarray, str, int>>:
    2a68:	push   rbp
    2a69:	mov    rbp,rsp
    2a6c:	sub    rsp,0x50
    2a70:	mov    QWORD PTR [rsp+0x20],rbx
    2a75:	mov    QWORD PTR [rsp+0x28],r12
    2a7a:	mov    QWORD PTR [rsp+0x30],r13
    2a7f:	mov    QWORD PTR [rsp+0x38],r14
    2a84:	mov    QWORD PTR [rsp+0x40],r15
    2a89:	mov    r14,rdi
    2a8c:	mov    QWORD PTR [rsp],rsi
    2a90:	mov    QWORD PTR [rsp+0x8],rdx
    2a95:	mov    r13,rdx
    2a98:	mov    QWORD PTR [rsp+0x10],rcx
    2a9d:	mov    r12,rsi
    2aa0:	mov    r15,rcx
    2aa3:	mov    rsi,r12
    2aa6:	mov    rdi,r14
    2aa9:	call   2aae <botlish_fn_38+0x46>
			2aaa: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2aae:	test   rax,rax
    2ab1:	je     2cb0 <botlish_fn_38+0x248>
    2ab7:	xor    ecx,ecx
    2ab9:	test   rax,0x7
    2abf:	je     2acd <botlish_fn_38+0x65>
    2ac5:	mov    rsi,rax
    2ac8:	jmp    2adb <botlish_fn_38+0x73>
    2acd:	movzx  rcx,BYTE PTR [rax]
    2ad1:	mov    rsi,rax
    2ad4:	rex cmp cl,0x8
    2ad8:	sete   cl
    2adb:	test   cl,cl
    2add:	jne    2afd <botlish_fn_38+0x95>
    2ae3:	mov    rdi,r14
    2ae6:	mov    rdx,QWORD PTR [rdi+0x10]
    2aea:	mov    rcx,QWORD PTR [rdx+0x30]
    2aee:	mov    edx,0x8
    2af3:	call   2af8 <botlish_fn_38+0x90>
			2af4: R_X86_64_PLT32	rt_type_error-0x4
    2af8:	jmp    2cb0 <botlish_fn_38+0x248>
    2afd:	mov    rdx,r15
    2b00:	mov    rdi,r14
    2b03:	call   2b08 <botlish_fn_38+0xa0>
			2b04: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b08:	mov    rcx,rax
    2b0b:	mov    QWORD PTR [rsp+0x18],rax
    2b10:	test   rax,rcx
    2b13:	je     2cb0 <botlish_fn_38+0x248>
    2b19:	mov    rax,QWORD PTR [rsp+0x18]
    2b1e:	test   rax,0x1
    2b24:	jne    2b4f <botlish_fn_38+0xe7>
    2b2a:	mov    edx,0x1
    2b2f:	mov    rsi,QWORD PTR [rsp+0x18]
    2b34:	mov    rdi,r14
    2b37:	call   2b3c <botlish_fn_38+0xd4>
			2b38: R_X86_64_PLT32	rt_value_eq-0x4
    2b3c:	test   rax,rax
    2b3f:	je     2cb0 <botlish_fn_38+0x248>
    2b45:	mov    rcx,QWORD PTR [rsp+0x18]
    2b4a:	jmp    2b65 <botlish_fn_38+0xfd>
    2b4f:	mov    eax,0x2
    2b54:	mov    rcx,QWORD PTR [rsp+0x18]
    2b59:	cmp    rcx,0x1
    2b5d:	cmove  rax,QWORD PTR [rip+0x1db]        # 2d40 <botlish_fn_38+0x2d8>
    2b65:	mov    ebx,0x6
    2b6a:	cmp    rax,0x6
    2b6e:	je     2d10 <botlish_fn_38+0x2a8>
    2b74:	test   rcx,0x1
    2b7b:	mov    QWORD PTR [rsp+0x18],rcx
    2b80:	jne    2ba6 <botlish_fn_38+0x13e>
    2b86:	mov    edx,0x3
    2b8b:	mov    rsi,QWORD PTR [rsp+0x18]
    2b90:	mov    rdi,r14
    2b93:	call   2b98 <botlish_fn_38+0x130>
			2b94: R_X86_64_PLT32	rt_value_eq-0x4
    2b98:	test   rax,rax
    2b9b:	je     2cb0 <botlish_fn_38+0x248>
    2ba1:	jmp    2bbc <botlish_fn_38+0x154>
    2ba6:	mov    rsi,QWORD PTR [rsp+0x18]
    2bab:	mov    eax,0x2
    2bb0:	cmp    rsi,0x3
    2bb4:	cmove  rax,QWORD PTR [rip+0x184]        # 2d40 <botlish_fn_38+0x2d8>
    2bbc:	cmp    rax,0x6
    2bc0:	je     2bd0 <botlish_fn_38+0x168>
    2bc6:	mov    ebx,0x2
    2bcb:	jmp    2c8f <botlish_fn_38+0x227>
    2bd0:	mov    rsi,r12
    2bd3:	mov    rdi,r14
    2bd6:	call   2bdb <botlish_fn_38+0x173>
			2bd7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2bdb:	test   rax,rax
    2bde:	je     2cb0 <botlish_fn_38+0x248>
    2be4:	xor    r10d,r10d
    2be7:	test   rax,0x7
    2bed:	je     2bfb <botlish_fn_38+0x193>
    2bf3:	mov    rsi,rax
    2bf6:	jmp    2c0a <botlish_fn_38+0x1a2>
    2bfb:	movzx  rcx,BYTE PTR [rax]
    2bff:	mov    rsi,rax
    2c02:	rex cmp cl,0x8
    2c06:	sete   r10b
    2c0a:	test   r10b,r10b
    2c0d:	jne    2c2d <botlish_fn_38+0x1c5>
    2c13:	mov    rdi,r14
    2c16:	mov    rax,QWORD PTR [rdi+0x10]
    2c1a:	mov    rcx,QWORD PTR [rax+0x30]
    2c1e:	mov    edx,0x8
    2c23:	call   2c28 <botlish_fn_38+0x1c0>
			2c24: R_X86_64_PLT32	rt_type_error-0x4
    2c28:	jmp    2cb0 <botlish_fn_38+0x248>
    2c2d:	mov    rdx,r15
    2c30:	mov    rdi,r14
    2c33:	call   2c38 <botlish_fn_38+0x1d0>
			2c34: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c38:	test   rax,rax
    2c3b:	je     2cb0 <botlish_fn_38+0x248>
    2c41:	mov    rcx,rax
    2c44:	and    rcx,r13
    2c47:	mov    rsi,rax
    2c4a:	test   rcx,0x1
    2c51:	jne    2c70 <botlish_fn_38+0x208>
    2c57:	mov    rdx,r13
    2c5a:	mov    rdi,r14
    2c5d:	call   2c62 <botlish_fn_38+0x1fa>
			2c5e: R_X86_64_PLT32	rt_value_eq-0x4
    2c62:	test   rax,rax
    2c65:	je     2cb0 <botlish_fn_38+0x248>
    2c6b:	jmp    2c80 <botlish_fn_38+0x218>
    2c70:	mov    eax,0x2
    2c75:	cmp    rsi,r13
    2c78:	cmove  rax,QWORD PTR [rip+0xc0]        # 2d40 <botlish_fn_38+0x2d8>
    2c80:	cmp    rax,0x6
    2c84:	je     2c8f <botlish_fn_38+0x227>
    2c8a:	mov    ebx,0x2
    2c8f:	cmp    rbx,0x6
    2c93:	je     2ceb <botlish_fn_38+0x283>
    2c99:	mov    rdx,r15
    2c9c:	mov    rsi,r12
    2c9f:	mov    rdi,r14
    2ca2:	call   2ca7 <botlish_fn_38+0x23f>
			2ca3: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_next<mutarray, int>
    2ca7:	test   rax,rax
    2caa:	jne    2cd5 <botlish_fn_38+0x26d>
    2cb0:	xor    rax,rax
    2cb3:	mov    rbx,QWORD PTR [rsp+0x20]
    2cb8:	mov    r12,QWORD PTR [rsp+0x28]
    2cbd:	mov    r13,QWORD PTR [rsp+0x30]
    2cc2:	mov    r14,QWORD PTR [rsp+0x38]
    2cc7:	mov    r15,QWORD PTR [rsp+0x40]
    2ccc:	add    rsp,0x50
    2cd0:	mov    rsp,rbp
    2cd3:	pop    rbp
    2cd4:	ret
    2cd5:	mov    QWORD PTR [rsp],r12
    2cd9:	mov    QWORD PTR [rsp+0x8],r13
    2cde:	mov    QWORD PTR [rsp+0x10],rax
    2ce3:	mov    r15,rax
    2ce6:	jmp    2aa3 <botlish_fn_38+0x3b>
    2ceb:	mov    rax,r15
    2cee:	mov    rbx,QWORD PTR [rsp+0x20]
    2cf3:	mov    r12,QWORD PTR [rsp+0x28]
    2cf8:	mov    r13,QWORD PTR [rsp+0x30]
    2cfd:	mov    r14,QWORD PTR [rsp+0x38]
    2d02:	mov    r15,QWORD PTR [rsp+0x40]
    2d07:	add    rsp,0x50
    2d0b:	mov    rsp,rbp
    2d0e:	pop    rbp
    2d0f:	ret
    2d10:	mov    rax,0xffffffffffffffff
    2d17:	mov    rbx,QWORD PTR [rsp+0x20]
    2d1c:	mov    r12,QWORD PTR [rsp+0x28]
    2d21:	mov    r13,QWORD PTR [rsp+0x30]
    2d26:	mov    r14,QWORD PTR [rsp+0x38]
    2d2b:	mov    r15,QWORD PTR [rsp+0x40]
    2d30:	add    rsp,0x50
    2d34:	mov    rsp,rbp
    2d37:	pop    rbp
    2d38:	ret
    2d39:	add    BYTE PTR [rax],al
    2d3b:	add    BYTE PTR [rax],al
    2d3d:	add    BYTE PTR [rax],al
    2d3f:	add    BYTE PTR [rsi],al
    2d41:	add    BYTE PTR [rax],al
    2d43:	add    BYTE PTR [rax],al
    2d45:	add    BYTE PTR [rax],al
	...

0000000000002d48 <botlish_entry_38: ht_find_get<mutarray, str, int>>:
    2d48:	push   rbp
    2d49:	mov    rbp,rsp
    2d4c:	mov    rsi,QWORD PTR [rdx]
    2d4f:	mov    r8,QWORD PTR [rdx+0x8]
    2d53:	mov    rcx,QWORD PTR [rdx+0x10]
    2d57:	mov    rdx,r8
    2d5a:	call   2d5f <botlish_entry_38+0x17>
			2d5b: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_get<mutarray, str, int>
    2d5f:	mov    rsp,rbp
    2d62:	pop    rbp
    2d63:	ret
    2d64:	add    BYTE PTR [rax],al
	...

0000000000002d68 <botlish_fn_39: ht_find_insert<mutarray, any, int, int>>:
    2d68:	push   rbp
    2d69:	mov    rbp,rsp
    2d6c:	sub    rsp,0x60
    2d70:	mov    QWORD PTR [rsp+0x30],rbx
    2d75:	mov    QWORD PTR [rsp+0x38],r12
    2d7a:	mov    QWORD PTR [rsp+0x40],r13
    2d7f:	mov    QWORD PTR [rsp+0x48],r14
    2d84:	mov    QWORD PTR [rsp+0x50],r15
    2d89:	mov    r15,rdi
    2d8c:	mov    QWORD PTR [rsp],rsi
    2d90:	mov    QWORD PTR [rsp+0x8],rdx
    2d95:	mov    r13,rdx
    2d98:	mov    QWORD PTR [rsp+0x10],rcx
    2d9d:	mov    QWORD PTR [rsp+0x18],r8
    2da2:	mov    rbx,rsi
    2da5:	mov    QWORD PTR [rsp+0x20],rcx
    2daa:	mov    QWORD PTR [rsp+0x28],r8
    2daf:	mov    rsi,rbx
    2db2:	mov    rdi,r15
    2db5:	call   2dba <botlish_fn_39+0x52>
			2db6: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2dba:	test   rax,rax
    2dbd:	je     30b5 <botlish_fn_39+0x34d>
    2dc3:	xor    ecx,ecx
    2dc5:	test   rax,0x7
    2dcb:	je     2dd9 <botlish_fn_39+0x71>
    2dd1:	mov    rsi,rax
    2dd4:	jmp    2de7 <botlish_fn_39+0x7f>
    2dd9:	movzx  rcx,BYTE PTR [rax]
    2ddd:	mov    rsi,rax
    2de0:	rex cmp cl,0x8
    2de4:	sete   cl
    2de7:	test   cl,cl
    2de9:	jne    2e09 <botlish_fn_39+0xa1>
    2def:	mov    rdi,r15
    2df2:	mov    rax,QWORD PTR [rdi+0x10]
    2df6:	mov    rcx,QWORD PTR [rax+0x30]
    2dfa:	mov    edx,0x8
    2dff:	call   2e04 <botlish_fn_39+0x9c>
			2e00: R_X86_64_PLT32	rt_type_error-0x4
    2e04:	jmp    30b5 <botlish_fn_39+0x34d>
    2e09:	mov    rdx,QWORD PTR [rsp+0x20]
    2e0e:	mov    rdi,r15
    2e11:	call   2e16 <botlish_fn_39+0xae>
			2e12: R_X86_64_PLT32	rt_mutarray_get-0x4
    2e16:	mov    rsi,rax
    2e19:	mov    r14,rax
    2e1c:	test   rax,rsi
    2e1f:	je     30b5 <botlish_fn_39+0x34d>
    2e25:	mov    rax,r14
    2e28:	test   rax,0x1
    2e2e:	jne    2e52 <botlish_fn_39+0xea>
    2e34:	mov    edx,0x1
    2e39:	mov    rsi,r14
    2e3c:	mov    rdi,r15
    2e3f:	call   2e44 <botlish_fn_39+0xdc>
			2e40: R_X86_64_PLT32	rt_value_eq-0x4
    2e44:	test   rax,rax
    2e47:	je     30b5 <botlish_fn_39+0x34d>
    2e4d:	jmp    2e66 <botlish_fn_39+0xfe>
    2e52:	mov    eax,0x2
    2e57:	mov    rcx,r14
    2e5a:	cmp    rcx,0x1
    2e5e:	cmove  rax,QWORD PTR [rip+0x372]        # 31d8 <botlish_fn_39+0x470>
    2e66:	mov    r12d,0x6
    2e6c:	cmp    rax,0x6
    2e70:	je     312d <botlish_fn_39+0x3c5>
    2e76:	mov    rax,r14
    2e79:	test   rax,0x1
    2e7f:	jne    2ea3 <botlish_fn_39+0x13b>
    2e85:	mov    edx,0x3
    2e8a:	mov    rsi,r14
    2e8d:	mov    rdi,r15
    2e90:	call   2e95 <botlish_fn_39+0x12d>
			2e91: R_X86_64_PLT32	rt_value_eq-0x4
    2e95:	test   rax,rax
    2e98:	je     30b5 <botlish_fn_39+0x34d>
    2e9e:	jmp    2eb7 <botlish_fn_39+0x14f>
    2ea3:	mov    eax,0x2
    2ea8:	mov    rcx,r14
    2eab:	cmp    rcx,0x3
    2eaf:	cmove  rax,QWORD PTR [rip+0x321]        # 31d8 <botlish_fn_39+0x470>
    2eb7:	cmp    rax,0x6
    2ebb:	je     2ecc <botlish_fn_39+0x164>
    2ec1:	mov    r11d,0x2
    2ec7:	jmp    2f96 <botlish_fn_39+0x22e>
    2ecc:	mov    rsi,rbx
    2ecf:	mov    rdi,r15
    2ed2:	call   2ed7 <botlish_fn_39+0x16f>
			2ed3: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2ed7:	test   rax,rax
    2eda:	je     30b5 <botlish_fn_39+0x34d>
    2ee0:	xor    ecx,ecx
    2ee2:	test   rax,0x7
    2ee8:	je     2ef6 <botlish_fn_39+0x18e>
    2eee:	mov    rsi,rax
    2ef1:	jmp    2f04 <botlish_fn_39+0x19c>
    2ef6:	movzx  rcx,BYTE PTR [rax]
    2efa:	mov    rsi,rax
    2efd:	rex cmp cl,0x8
    2f01:	sete   cl
    2f04:	test   cl,cl
    2f06:	jne    2f26 <botlish_fn_39+0x1be>
    2f0c:	mov    rdi,r15
    2f0f:	mov    rcx,QWORD PTR [rdi+0x10]
    2f13:	mov    rcx,QWORD PTR [rcx+0x30]
    2f17:	mov    edx,0x8
    2f1c:	call   2f21 <botlish_fn_39+0x1b9>
			2f1d: R_X86_64_PLT32	rt_type_error-0x4
    2f21:	jmp    30b5 <botlish_fn_39+0x34d>
    2f26:	mov    rdx,QWORD PTR [rsp+0x20]
    2f2b:	mov    rdi,r15
    2f2e:	call   2f33 <botlish_fn_39+0x1cb>
			2f2f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2f33:	test   rax,rax
    2f36:	je     30b5 <botlish_fn_39+0x34d>
    2f3c:	mov    rsi,rax
    2f3f:	and    rsi,r13
    2f42:	test   rsi,0x1
    2f49:	jne    2f6b <botlish_fn_39+0x203>
    2f4f:	mov    rsi,rax
    2f52:	mov    rdx,r13
    2f55:	mov    rdi,r15
    2f58:	call   2f5d <botlish_fn_39+0x1f5>
			2f59: R_X86_64_PLT32	rt_value_eq-0x4
    2f5d:	test   rax,rax
    2f60:	je     30b5 <botlish_fn_39+0x34d>
    2f66:	jmp    2f7e <botlish_fn_39+0x216>
    2f6b:	mov    rsi,rax
    2f6e:	mov    eax,0x2
    2f73:	cmp    rsi,r13
    2f76:	cmove  rax,QWORD PTR [rip+0x25a]        # 31d8 <botlish_fn_39+0x470>
    2f7e:	cmp    rax,0x6
    2f82:	je     2f93 <botlish_fn_39+0x22b>
    2f88:	mov    r11d,0x2
    2f8e:	jmp    2f96 <botlish_fn_39+0x22e>
    2f93:	mov    r11,r12
    2f96:	cmp    r11,0x6
    2f9a:	je     3106 <botlish_fn_39+0x39e>
    2fa0:	mov    rax,r14
    2fa3:	test   rax,0x1
    2fa9:	jne    2fcd <botlish_fn_39+0x265>
    2faf:	mov    edx,0x5
    2fb4:	mov    rsi,r14
    2fb7:	mov    rdi,r15
    2fba:	call   2fbf <botlish_fn_39+0x257>
			2fbb: R_X86_64_PLT32	rt_value_eq-0x4
    2fbf:	test   rax,rax
    2fc2:	je     30b5 <botlish_fn_39+0x34d>
    2fc8:	jmp    2fe1 <botlish_fn_39+0x279>
    2fcd:	mov    rsi,r14
    2fd0:	mov    eax,0x2
    2fd5:	cmp    rsi,0x5
    2fd9:	cmove  rax,QWORD PTR [rip+0x1f7]        # 31d8 <botlish_fn_39+0x470>
    2fe1:	cmp    rax,0x6
    2fe5:	je     2ff6 <botlish_fn_39+0x28e>
    2feb:	mov    r12d,0x2
    2ff1:	jmp    3057 <botlish_fn_39+0x2ef>
    2ff6:	mov    r14,QWORD PTR [rsp+0x28]
    2ffb:	test   r14,0x1
    3002:	jne    3032 <botlish_fn_39+0x2ca>
    3008:	mov    edx,0x1
    300d:	mov    rsi,r14
    3010:	mov    rdi,r15
    3013:	call   3018 <botlish_fn_39+0x2b0>
			3014: R_X86_64_PLT32	rt_int_cmp-0x4
    3018:	mov    ecx,0x2
    301d:	test   rax,rax
    3020:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 31d8 <botlish_fn_39+0x470>
    3028:	mov    QWORD PTR [rsp+0x28],r14
    302d:	jmp    3047 <botlish_fn_39+0x2df>
    3032:	mov    ecx,0x2
    3037:	test   r14,r14
    303a:	mov    QWORD PTR [rsp+0x28],r14
    303f:	cmovle rcx,QWORD PTR [rip+0x191]        # 31d8 <botlish_fn_39+0x470>
    3047:	cmp    rcx,0x6
    304b:	je     3057 <botlish_fn_39+0x2ef>
    3051:	mov    r12d,0x2
    3057:	cmp    r12,0x6
    305b:	je     309c <botlish_fn_39+0x334>
    3061:	mov    rdx,QWORD PTR [rsp+0x20]
    3066:	mov    rsi,rbx
    3069:	mov    rdi,r15
    306c:	call   3071 <botlish_fn_39+0x309>
			306d: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_next<mutarray, int>
    3071:	test   rax,rax
    3074:	je     30b5 <botlish_fn_39+0x34d>
    307a:	mov    QWORD PTR [rsp],rbx
    307e:	mov    QWORD PTR [rsp+0x8],r13
    3083:	mov    QWORD PTR [rsp+0x10],rax
    3088:	mov    r11,QWORD PTR [rsp+0x28]
    308d:	mov    QWORD PTR [rsp+0x18],r11
    3092:	mov    QWORD PTR [rsp+0x20],rax
    3097:	jmp    2daf <botlish_fn_39+0x47>
    309c:	mov    rdx,QWORD PTR [rsp+0x20]
    30a1:	mov    rsi,rbx
    30a4:	mov    rdi,r15
    30a7:	call   30ac <botlish_fn_39+0x344>
			30a8: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_next<mutarray, int>
    30ac:	test   rax,rax
    30af:	jne    30da <botlish_fn_39+0x372>
    30b5:	xor    rax,rax
    30b8:	mov    rbx,QWORD PTR [rsp+0x30]
    30bd:	mov    r12,QWORD PTR [rsp+0x38]
    30c2:	mov    r13,QWORD PTR [rsp+0x40]
    30c7:	mov    r14,QWORD PTR [rsp+0x48]
    30cc:	mov    r15,QWORD PTR [rsp+0x50]
    30d1:	add    rsp,0x60
    30d5:	mov    rsp,rbp
    30d8:	pop    rbp
    30d9:	ret
    30da:	mov    QWORD PTR [rsp],rbx
    30de:	mov    QWORD PTR [rsp+0x8],r13
    30e3:	mov    QWORD PTR [rsp+0x10],rax
    30e8:	mov    rdx,QWORD PTR [rsp+0x20]
    30ed:	mov    QWORD PTR [rsp+0x18],rdx
    30f2:	mov    rcx,QWORD PTR [rsp+0x20]
    30f7:	mov    QWORD PTR [rsp+0x28],rcx
    30fc:	mov    QWORD PTR [rsp+0x20],rax
    3101:	jmp    2daf <botlish_fn_39+0x47>
    3106:	mov    rax,QWORD PTR [rsp+0x20]
    310b:	mov    rbx,QWORD PTR [rsp+0x30]
    3110:	mov    r12,QWORD PTR [rsp+0x38]
    3115:	mov    r13,QWORD PTR [rsp+0x40]
    311a:	mov    r14,QWORD PTR [rsp+0x48]
    311f:	mov    r15,QWORD PTR [rsp+0x50]
    3124:	add    rsp,0x60
    3128:	mov    rsp,rbp
    312b:	pop    rbp
    312c:	ret
    312d:	mov    rax,QWORD PTR [rsp+0x28]
    3132:	test   rax,0x1
    3138:	jne    3165 <botlish_fn_39+0x3fd>
    313e:	mov    edx,0x1
    3143:	mov    rdi,r15
    3146:	mov    rsi,QWORD PTR [rsp+0x28]
    314b:	call   3150 <botlish_fn_39+0x3e8>
			314c: R_X86_64_PLT32	rt_int_cmp-0x4
    3150:	mov    ecx,0x2
    3155:	test   rax,rax
    3158:	cmovge rcx,QWORD PTR [rip+0x78]        # 31d8 <botlish_fn_39+0x470>
    3160:	jmp    317f <botlish_fn_39+0x417>
    3165:	mov    ecx,0x2
    316a:	mov    rax,QWORD PTR [rsp+0x28]
    316f:	mov    rdx,QWORD PTR [rsp+0x28]
    3174:	test   rax,rdx
    3177:	cmovg  rcx,QWORD PTR [rip+0x59]        # 31d8 <botlish_fn_39+0x470>
    317f:	cmp    rcx,0x6
    3183:	je     31b0 <botlish_fn_39+0x448>
    3189:	mov    rax,QWORD PTR [rsp+0x20]
    318e:	mov    rbx,QWORD PTR [rsp+0x30]
    3193:	mov    r12,QWORD PTR [rsp+0x38]
    3198:	mov    r13,QWORD PTR [rsp+0x40]
    319d:	mov    r14,QWORD PTR [rsp+0x48]
    31a2:	mov    r15,QWORD PTR [rsp+0x50]
    31a7:	add    rsp,0x60
    31ab:	mov    rsp,rbp
    31ae:	pop    rbp
    31af:	ret
    31b0:	mov    rax,QWORD PTR [rsp+0x28]
    31b5:	mov    rbx,QWORD PTR [rsp+0x30]
    31ba:	mov    r12,QWORD PTR [rsp+0x38]
    31bf:	mov    r13,QWORD PTR [rsp+0x40]
    31c4:	mov    r14,QWORD PTR [rsp+0x48]
    31c9:	mov    r15,QWORD PTR [rsp+0x50]
    31ce:	add    rsp,0x60
    31d2:	mov    rsp,rbp
    31d5:	pop    rbp
    31d6:	ret
    31d7:	add    BYTE PTR [rsi],al
    31d9:	add    BYTE PTR [rax],al
    31db:	add    BYTE PTR [rax],al
    31dd:	add    BYTE PTR [rax],al
	...

00000000000031e0 <botlish_entry_39: ht_find_insert<mutarray, any, int, int>>:
    31e0:	push   rbp
    31e1:	mov    rbp,rsp
    31e4:	mov    rsi,QWORD PTR [rdx]
    31e7:	mov    r9,QWORD PTR [rdx+0x8]
    31eb:	mov    rcx,QWORD PTR [rdx+0x10]
    31ef:	mov    r8,QWORD PTR [rdx+0x18]
    31f3:	mov    rdx,r9
    31f6:	call   31fb <botlish_entry_39+0x1b>
			31f7: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_find_insert<mutarray, any, int, int>
    31fb:	mov    rsp,rbp
    31fe:	pop    rbp
    31ff:	ret

0000000000003200 <botlish_fn_40: ht_get<mutarray, str>>:
    3200:	push   rbp
    3201:	mov    rbp,rsp
    3204:	sub    rsp,0x40
    3208:	mov    QWORD PTR [rsp+0x20],rbx
    320d:	mov    QWORD PTR [rsp+0x28],r12
    3212:	mov    QWORD PTR [rsp+0x30],r13
    3217:	mov    rbx,rdi
    321a:	mov    QWORD PTR [rsp],rsi
    321e:	mov    r13,rsi
    3221:	mov    QWORD PTR [rsp+0x8],rdx
    3226:	mov    r12,rdx
    3229:	mov    rdx,r12
    322c:	mov    rsi,r13
    322f:	mov    rdi,rbx
    3232:	call   3237 <botlish_fn_40+0x37>
			3233: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, str>
    3237:	test   rax,rax
    323a:	je     3324 <botlish_fn_40+0x124>
    3240:	mov    QWORD PTR [rsp+0x10],rax
    3245:	mov    rcx,rax
    3248:	mov    rdx,r12
    324b:	mov    rsi,r13
    324e:	mov    rdi,rbx
    3251:	call   3256 <botlish_fn_40+0x56>
			3252: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_get<mutarray, str, int>
    3256:	mov    rcx,rax
    3259:	mov    r12,rax
    325c:	test   rax,rcx
    325f:	je     3324 <botlish_fn_40+0x124>
    3265:	mov    rax,r12
    3268:	test   rax,0x1
    326e:	jne    3299 <botlish_fn_40+0x99>
    3274:	mov    edx,0x1
    3279:	mov    rsi,r12
    327c:	mov    rdi,rbx
    327f:	call   3284 <botlish_fn_40+0x84>
			3280: R_X86_64_PLT32	rt_int_cmp-0x4
    3284:	mov    ecx,0x2
    3289:	test   rax,rax
    328c:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 3378 <botlish_fn_40+0x178>
    3294:	jmp    32ac <botlish_fn_40+0xac>
    3299:	mov    ecx,0x2
    329e:	mov    rax,r12
    32a1:	test   rax,rax
    32a4:	cmovle rcx,QWORD PTR [rip+0xcc]        # 3378 <botlish_fn_40+0x178>
    32ac:	cmp    rcx,0x6
    32b0:	je     3357 <botlish_fn_40+0x157>
    32b6:	mov    rsi,r13
    32b9:	mov    rdi,rbx
    32bc:	call   32c1 <botlish_fn_40+0xc1>
			32bd: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    32c1:	test   rax,rax
    32c4:	je     3324 <botlish_fn_40+0x124>
    32ca:	xor    ecx,ecx
    32cc:	test   rax,0x7
    32d2:	je     32e0 <botlish_fn_40+0xe0>
    32d8:	mov    rsi,rax
    32db:	jmp    32ee <botlish_fn_40+0xee>
    32e0:	movzx  rcx,BYTE PTR [rax]
    32e4:	mov    rsi,rax
    32e7:	rex cmp cl,0x8
    32eb:	sete   cl
    32ee:	test   cl,cl
    32f0:	jne    3310 <botlish_fn_40+0x110>
    32f6:	mov    rdi,rbx
    32f9:	mov    rax,QWORD PTR [rdi+0x10]
    32fd:	mov    rcx,QWORD PTR [rax+0x30]
    3301:	mov    edx,0x8
    3306:	call   330b <botlish_fn_40+0x10b>
			3307: R_X86_64_PLT32	rt_type_error-0x4
    330b:	jmp    3324 <botlish_fn_40+0x124>
    3310:	mov    rdx,r12
    3313:	mov    rdi,rbx
    3316:	call   331b <botlish_fn_40+0x11b>
			3317: R_X86_64_PLT32	rt_mutarray_get-0x4
    331b:	test   rax,rax
    331e:	jne    333f <botlish_fn_40+0x13f>
    3324:	xor    rax,rax
    3327:	mov    rbx,QWORD PTR [rsp+0x20]
    332c:	mov    r12,QWORD PTR [rsp+0x28]
    3331:	mov    r13,QWORD PTR [rsp+0x30]
    3336:	add    rsp,0x40
    333a:	mov    rsp,rbp
    333d:	pop    rbp
    333e:	ret
    333f:	mov    rbx,QWORD PTR [rsp+0x20]
    3344:	mov    r12,QWORD PTR [rsp+0x28]
    3349:	mov    r13,QWORD PTR [rsp+0x30]
    334e:	add    rsp,0x40
    3352:	mov    rsp,rbp
    3355:	pop    rbp
    3356:	ret
    3357:	mov    eax,0xa
    335c:	mov    rbx,QWORD PTR [rsp+0x20]
    3361:	mov    r12,QWORD PTR [rsp+0x28]
    3366:	mov    r13,QWORD PTR [rsp+0x30]
    336b:	add    rsp,0x40
    336f:	mov    rsp,rbp
    3372:	pop    rbp
    3373:	ret
    3374:	add    BYTE PTR [rax],al
    3376:	add    BYTE PTR [rax],al
    3378:	(bad)
    3379:	add    BYTE PTR [rax],al
    337b:	add    BYTE PTR [rax],al
    337d:	add    BYTE PTR [rax],al
	...

0000000000003380 <botlish_entry_40: ht_get<mutarray, str>>:
    3380:	push   rbp
    3381:	mov    rbp,rsp
    3384:	mov    rsi,QWORD PTR [rdx]
    3387:	mov    rdx,QWORD PTR [rdx+0x8]
    338b:	call   3390 <botlish_entry_40+0x10>
			338c: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    3390:	mov    rsp,rbp
    3393:	pop    rbp
    3394:	ret
    3395:	add    BYTE PTR [rax],al
	...

0000000000003398 <botlish_fn_41: ht_rehash_probe<mutarray, int, int>>:
    3398:	push   rbp
    3399:	mov    rbp,rsp
    339c:	sub    rsp,0x40
    33a0:	mov    QWORD PTR [rsp+0x20],rbx
    33a5:	mov    QWORD PTR [rsp+0x28],r12
    33aa:	mov    QWORD PTR [rsp+0x30],r13
    33af:	mov    QWORD PTR [rsp+0x38],r14
    33b4:	mov    r13,rdi
    33b7:	mov    QWORD PTR [rsp],rsi
    33bb:	mov    QWORD PTR [rsp+0x8],rdx
    33c0:	mov    QWORD PTR [rsp+0x10],rcx
    33c5:	mov    r12,rcx
    33c8:	mov    rbx,rsi
    33cb:	mov    r14,rdx
    33ce:	mov    rdx,r14
    33d1:	mov    rsi,rbx
    33d4:	mov    rdi,r13
    33d7:	call   33dc <botlish_fn_41+0x44>
			33d8: R_X86_64_PLT32	rt_mutarray_get-0x4
    33dc:	test   rax,rax
    33df:	je     347c <botlish_fn_41+0xe4>
    33e5:	test   rax,0x1
    33eb:	mov    rsi,rax
    33ee:	jne    340f <botlish_fn_41+0x77>
    33f4:	mov    edx,0x1
    33f9:	mov    rdi,r13
    33fc:	call   3401 <botlish_fn_41+0x69>
			33fd: R_X86_64_PLT32	rt_value_eq-0x4
    3401:	test   rax,rax
    3404:	je     347c <botlish_fn_41+0xe4>
    340a:	jmp    3420 <botlish_fn_41+0x88>
    340f:	mov    eax,0x2
    3414:	cmp    rsi,0x1
    3418:	cmove  rax,QWORD PTR [rip+0xb8]        # 34d8 <botlish_fn_41+0x140>
    3420:	cmp    rax,0x6
    3424:	je     34b2 <botlish_fn_41+0x11a>
    342a:	mov    QWORD PTR [rsp+0x18],0x3
    3433:	mov    rsi,r14
    3436:	test   rsi,0x1
    343d:	je     3455 <botlish_fn_41+0xbd>
    3443:	mov    rsi,r14
    3446:	add    rsi,0x2
    344a:	seto   al
    344d:	test   al,al
    344f:	je     3468 <botlish_fn_41+0xd0>
    3455:	mov    edx,0x3
    345a:	mov    rsi,r14
    345d:	mov    rdi,r13
    3460:	call   3465 <botlish_fn_41+0xcd>
			3461: R_X86_64_PLT32	rt_int_add-0x4
    3465:	mov    rsi,rax
    3468:	mov    rdx,r12
    346b:	mov    rdi,r13
    346e:	call   3473 <botlish_fn_41+0xdb>
			346f: R_X86_64_PLT32	rt_int_mod-0x4
    3473:	test   rax,rax
    3476:	jne    349c <botlish_fn_41+0x104>
    347c:	xor    rax,rax
    347f:	mov    rbx,QWORD PTR [rsp+0x20]
    3484:	mov    r12,QWORD PTR [rsp+0x28]
    3489:	mov    r13,QWORD PTR [rsp+0x30]
    348e:	mov    r14,QWORD PTR [rsp+0x38]
    3493:	add    rsp,0x40
    3497:	mov    rsp,rbp
    349a:	pop    rbp
    349b:	ret
    349c:	mov    QWORD PTR [rsp],rbx
    34a0:	mov    QWORD PTR [rsp+0x8],rax
    34a5:	mov    QWORD PTR [rsp+0x10],r12
    34aa:	mov    r14,rax
    34ad:	jmp    33ce <botlish_fn_41+0x36>
    34b2:	mov    rax,r14
    34b5:	mov    rbx,QWORD PTR [rsp+0x20]
    34ba:	mov    r12,QWORD PTR [rsp+0x28]
    34bf:	mov    r13,QWORD PTR [rsp+0x30]
    34c4:	mov    r14,QWORD PTR [rsp+0x38]
    34c9:	add    rsp,0x40
    34cd:	mov    rsp,rbp
    34d0:	pop    rbp
    34d1:	ret
    34d2:	add    BYTE PTR [rax],al
    34d4:	add    BYTE PTR [rax],al
    34d6:	add    BYTE PTR [rax],al
    34d8:	(bad)
    34d9:	add    BYTE PTR [rax],al
    34db:	add    BYTE PTR [rax],al
    34dd:	add    BYTE PTR [rax],al
	...

00000000000034e0 <botlish_entry_41: ht_rehash_probe<mutarray, int, int>>:
    34e0:	push   rbp
    34e1:	mov    rbp,rsp
    34e4:	mov    rsi,QWORD PTR [rdx]
    34e7:	mov    r8,QWORD PTR [rdx+0x8]
    34eb:	mov    rcx,QWORD PTR [rdx+0x10]
    34ef:	mov    rdx,r8
    34f2:	call   34f7 <botlish_entry_41+0x17>
			34f3: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_probe<mutarray, int, int>
    34f7:	mov    rsp,rbp
    34fa:	pop    rbp
    34fb:	ret

00000000000034fc <botlish_fn_42: ht_rehash_insert<List[mutarray], int, any, any>>:
    34fc:	push   rbp
    34fd:	mov    rbp,rsp
    3500:	sub    rsp,0x80
    3507:	mov    QWORD PTR [rsp+0x50],rbx
    350c:	mov    QWORD PTR [rsp+0x58],r12
    3511:	mov    QWORD PTR [rsp+0x60],r13
    3516:	mov    QWORD PTR [rsp+0x68],r14
    351b:	mov    QWORD PTR [rsp+0x70],r15
    3520:	mov    r12,rdi
    3523:	mov    rdi,QWORD PTR [rbp+0x10]
    3527:	mov    QWORD PTR [rsp],rsi
    352b:	mov    QWORD PTR [rsp+0x38],rsi
    3530:	mov    QWORD PTR [rsp+0x8],rdx
    3535:	mov    r15,rdx
    3538:	mov    QWORD PTR [rsp+0x10],rcx
    353d:	mov    rbx,rcx
    3540:	mov    QWORD PTR [rsp+0x18],r8
    3545:	mov    QWORD PTR [rsp+0x40],r8
    354a:	mov    QWORD PTR [rsp+0x20],r9
    354f:	mov    r14,r9
    3552:	mov    QWORD PTR [rsp+0x28],rdi
    3557:	mov    r13,rdi
    355a:	mov    rsi,r14
    355d:	mov    rdi,r12
    3560:	call   3565 <botlish_fn_42+0x69>
			3561: R_X86_64_PLT32	rt_hash-0x4
    3565:	test   rax,rax
    3568:	mov    rsi,rax
    356b:	je     360a <botlish_fn_42+0x10e>
    3571:	mov    rdx,QWORD PTR [rsp+0x40]
    3576:	mov    rdi,r12
    3579:	call   357e <botlish_fn_42+0x82>
			357a: R_X86_64_PLT32	rt_int_mod-0x4
    357e:	test   rax,rax
    3581:	je     360a <botlish_fn_42+0x10e>
    3587:	mov    QWORD PTR [rsp+0x30],rax
    358c:	mov    rcx,QWORD PTR [rsp+0x40]
    3591:	mov    rdx,rax
    3594:	mov    rsi,QWORD PTR [rsp+0x38]
    3599:	mov    rdi,r12
    359c:	call   35a1 <botlish_fn_42+0xa5>
			359d: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_probe<mutarray, int, int>
    35a1:	mov    rcx,rax
    35a4:	mov    QWORD PTR [rsp+0x40],rax
    35a9:	test   rax,rcx
    35ac:	je     360a <botlish_fn_42+0x10e>
    35b2:	mov    ecx,0x3
    35b7:	mov    rsi,QWORD PTR [rsp+0x38]
    35bc:	mov    rdx,QWORD PTR [rsp+0x40]
    35c1:	mov    rdi,r12
    35c4:	call   35c9 <botlish_fn_42+0xcd>
			35c5: R_X86_64_PLT32	rt_mutarray_set-0x4
    35c9:	test   rax,rax
    35cc:	je     360a <botlish_fn_42+0x10e>
    35d2:	mov    rcx,r14
    35d5:	mov    rsi,r15
    35d8:	mov    rdx,QWORD PTR [rsp+0x40]
    35dd:	mov    rdi,r12
    35e0:	call   35e5 <botlish_fn_42+0xe9>
			35e1: R_X86_64_PLT32	rt_mutarray_set-0x4
    35e5:	test   rax,rax
    35e8:	je     360a <botlish_fn_42+0x10e>
    35ee:	mov    rcx,r13
    35f1:	mov    rdx,QWORD PTR [rsp+0x40]
    35f6:	mov    rsi,rbx
    35f9:	mov    rdi,r12
    35fc:	call   3601 <botlish_fn_42+0x105>
			35fd: R_X86_64_PLT32	rt_mutarray_set-0x4
    3601:	test   rax,rax
    3604:	jne    3632 <botlish_fn_42+0x136>
    360a:	xor    rax,rax
    360d:	mov    rbx,QWORD PTR [rsp+0x50]
    3612:	mov    r12,QWORD PTR [rsp+0x58]
    3617:	mov    r13,QWORD PTR [rsp+0x60]
    361c:	mov    r14,QWORD PTR [rsp+0x68]
    3621:	mov    r15,QWORD PTR [rsp+0x70]
    3626:	add    rsp,0x80
    362d:	mov    rsp,rbp
    3630:	pop    rbp
    3631:	ret
    3632:	mov    eax,0xa
    3637:	mov    rbx,QWORD PTR [rsp+0x50]
    363c:	mov    r12,QWORD PTR [rsp+0x58]
    3641:	mov    r13,QWORD PTR [rsp+0x60]
    3646:	mov    r14,QWORD PTR [rsp+0x68]
    364b:	mov    r15,QWORD PTR [rsp+0x70]
    3650:	add    rsp,0x80
    3657:	mov    rsp,rbp
    365a:	pop    rbp
    365b:	ret

000000000000365c <botlish_entry_42: ht_rehash_insert<List[mutarray], int, any, any>>:
    365c:	push   rbp
    365d:	mov    rbp,rsp
    3660:	sub    rsp,0x10
    3664:	mov    rsi,QWORD PTR [rdx]
    3667:	mov    r10,QWORD PTR [rdx+0x8]
    366b:	mov    rcx,QWORD PTR [rdx+0x10]
    366f:	mov    r8,QWORD PTR [rdx+0x18]
    3673:	mov    r9,QWORD PTR [rdx+0x20]
    3677:	mov    r11,QWORD PTR [rdx+0x28]
    367b:	mov    QWORD PTR [rsp],r11
    367f:	mov    rdx,r10
    3682:	call   3687 <botlish_entry_42+0x2b>
			3683: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_insert<List[mutarray], int, any, any>
    3687:	add    rsp,0x10
    368b:	mov    rsp,rbp
    368e:	pop    rbp
    368f:	ret

0000000000003690 <botlish_fn_43: ht_rehash_scan<list, int, int, List[mutarray], int>>:
    3690:	push   rbp
    3691:	mov    rbp,rsp
    3694:	sub    rsp,0xc0
    369b:	mov    QWORD PTR [rsp+0x90],rbx
    36a3:	mov    QWORD PTR [rsp+0x98],r12
    36ab:	mov    QWORD PTR [rsp+0xa0],r13
    36b3:	mov    QWORD PTR [rsp+0xa8],r14
    36bb:	mov    QWORD PTR [rsp+0xb0],r15
    36c3:	mov    QWORD PTR [rsp+0x58],rdi
    36c8:	mov    r15,QWORD PTR [rbp+0x10]
    36cc:	mov    r12,QWORD PTR [rbp+0x18]
    36d0:	mov    r13,QWORD PTR [rbp+0x20]
    36d4:	mov    r14,QWORD PTR [rbp+0x28]
    36d8:	mov    QWORD PTR [rsp+0x10],rsi
    36dd:	mov    QWORD PTR [rsp+0x60],rsi
    36e2:	mov    QWORD PTR [rsp+0x18],rdx
    36e7:	mov    QWORD PTR [rsp+0x68],rdx
    36ec:	mov    QWORD PTR [rsp+0x20],rcx
    36f1:	mov    QWORD PTR [rsp+0x70],rcx
    36f6:	mov    QWORD PTR [rsp+0x28],r15
    36fb:	mov    QWORD PTR [rsp+0x30],r12
    3700:	mov    QWORD PTR [rsp+0x38],r13
    3705:	mov    QWORD PTR [rsp+0x40],r14
    370a:	sar    r8,1
    370d:	sar    r9,1
    3710:	mov    QWORD PTR [rsp+0x88],r9
    3718:	mov    rcx,QWORD PTR [rsp+0x88]
    3720:	mov    rbx,r8
    3723:	cmp    rbx,rcx
    3726:	mov    QWORD PTR [rsp+0x88],rcx
    372e:	jge    3997 <botlish_fn_43+0x307>
    3734:	xor    eax,eax
    3736:	mov    rsi,QWORD PTR [rsp+0x60]
    373b:	test   rsi,0x7
    3742:	jne    3753 <botlish_fn_43+0xc3>
    3748:	movzx  r10,BYTE PTR [rsi]
    374c:	cmp    r10b,0x8
    3750:	sete   al
    3753:	test   al,al
    3755:	jne    3777 <botlish_fn_43+0xe7>
    375b:	mov    rdi,QWORD PTR [rsp+0x58]
    3760:	mov    rax,QWORD PTR [rdi+0x10]
    3764:	mov    rcx,QWORD PTR [rax+0x30]
    3768:	mov    edx,0x8
    376d:	call   3772 <botlish_fn_43+0xe2>
			376e: R_X86_64_PLT32	rt_type_error-0x4
    3772:	jmp    3915 <botlish_fn_43+0x285>
    3777:	mov    QWORD PTR [rsp+0x60],rsi
    377c:	mov    rdx,rbx
    377f:	shl    rdx,1
    3782:	or     rdx,0x1
    3786:	mov    QWORD PTR [rsp+0x80],rdx
    378e:	mov    rdi,QWORD PTR [rsp+0x58]
    3793:	call   3798 <botlish_fn_43+0x108>
			3794: R_X86_64_PLT32	rt_mutarray_get-0x4
    3798:	test   rax,rax
    379b:	je     3915 <botlish_fn_43+0x285>
    37a1:	test   rax,0x1
    37a7:	mov    rsi,rax
    37aa:	jne    37cd <botlish_fn_43+0x13d>
    37b0:	mov    edx,0x3
    37b5:	mov    rdi,QWORD PTR [rsp+0x58]
    37ba:	call   37bf <botlish_fn_43+0x12f>
			37bb: R_X86_64_PLT32	rt_value_eq-0x4
    37bf:	test   rax,rax
    37c2:	je     3915 <botlish_fn_43+0x285>
    37c8:	jmp    37de <botlish_fn_43+0x14e>
    37cd:	mov    eax,0x2
    37d2:	cmp    rsi,0x3
    37d6:	cmove  rax,QWORD PTR [rip+0x1f2]        # 39d0 <botlish_fn_43+0x340>
    37de:	cmp    rax,0x6
    37e2:	je     37f2 <botlish_fn_43+0x162>
    37e8:	mov    rsi,QWORD PTR [rsp+0x60]
    37ed:	jmp    3951 <botlish_fn_43+0x2c1>
    37f2:	xor    esi,esi
    37f4:	mov    rdx,QWORD PTR [rsp+0x68]
    37f9:	test   rdx,0x7
    3800:	je     3810 <botlish_fn_43+0x180>
    3806:	mov    QWORD PTR [rsp+0x68],rdx
    380b:	jmp    381f <botlish_fn_43+0x18f>
    3810:	movzx  rax,BYTE PTR [rdx]
    3814:	mov    QWORD PTR [rsp+0x68],rdx
    3819:	cmp    al,0x8
    381b:	sete   sil
    381f:	test   sil,sil
    3822:	jne    3849 <botlish_fn_43+0x1b9>
    3828:	mov    rdi,QWORD PTR [rsp+0x58]
    382d:	mov    rax,QWORD PTR [rdi+0x10]
    3831:	mov    rcx,QWORD PTR [rax+0x30]
    3835:	mov    edx,0x8
    383a:	mov    rsi,QWORD PTR [rsp+0x68]
    383f:	call   3844 <botlish_fn_43+0x1b4>
			3840: R_X86_64_PLT32	rt_type_error-0x4
    3844:	jmp    3915 <botlish_fn_43+0x285>
    3849:	mov    rdx,QWORD PTR [rsp+0x80]
    3851:	mov    rsi,QWORD PTR [rsp+0x68]
    3856:	mov    rdi,QWORD PTR [rsp+0x58]
    385b:	call   3860 <botlish_fn_43+0x1d0>
			385c: R_X86_64_PLT32	rt_mutarray_get-0x4
    3860:	test   rax,rax
    3863:	je     3915 <botlish_fn_43+0x285>
    3869:	mov    QWORD PTR [rsp+0x48],rax
    386e:	mov    QWORD PTR [rsp+0x78],rax
    3873:	xor    eax,eax
    3875:	mov    rcx,QWORD PTR [rsp+0x70]
    387a:	test   rcx,0x7
    3881:	je     3891 <botlish_fn_43+0x201>
    3887:	mov    QWORD PTR [rsp+0x70],rcx
    388c:	jmp    389f <botlish_fn_43+0x20f>
    3891:	movzx  rax,BYTE PTR [rcx]
    3895:	mov    QWORD PTR [rsp+0x70],rcx
    389a:	cmp    al,0x8
    389c:	sete   al
    389f:	test   al,al
    38a1:	jne    38c8 <botlish_fn_43+0x238>
    38a7:	mov    rdi,QWORD PTR [rsp+0x58]
    38ac:	mov    rax,QWORD PTR [rdi+0x10]
    38b0:	mov    rcx,QWORD PTR [rax+0x30]
    38b4:	mov    edx,0x8
    38b9:	mov    rsi,QWORD PTR [rsp+0x70]
    38be:	call   38c3 <botlish_fn_43+0x233>
			38bf: R_X86_64_PLT32	rt_type_error-0x4
    38c3:	jmp    3915 <botlish_fn_43+0x285>
    38c8:	mov    rdx,QWORD PTR [rsp+0x80]
    38d0:	mov    rsi,QWORD PTR [rsp+0x70]
    38d5:	mov    rdi,QWORD PTR [rsp+0x58]
    38da:	call   38df <botlish_fn_43+0x24f>
			38db: R_X86_64_PLT32	rt_mutarray_get-0x4
    38df:	test   rax,rax
    38e2:	je     3915 <botlish_fn_43+0x285>
    38e8:	mov    QWORD PTR [rsp+0x50],rax
    38ed:	mov    QWORD PTR [rsp],rax
    38f1:	mov    r9,QWORD PTR [rsp+0x78]
    38f6:	mov    rcx,r13
    38f9:	mov    rdx,r12
    38fc:	mov    rsi,r15
    38ff:	mov    rdi,QWORD PTR [rsp+0x58]
    3904:	mov    r8,r14
    3907:	call   390c <botlish_fn_43+0x27c>
			3908: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_insert<List[mutarray], int, any, any>
    390c:	test   rax,rax
    390f:	jne    394c <botlish_fn_43+0x2bc>
    3915:	xor    rax,rax
    3918:	mov    rbx,QWORD PTR [rsp+0x90]
    3920:	mov    r12,QWORD PTR [rsp+0x98]
    3928:	mov    r13,QWORD PTR [rsp+0xa0]
    3930:	mov    r14,QWORD PTR [rsp+0xa8]
    3938:	mov    r15,QWORD PTR [rsp+0xb0]
    3940:	add    rsp,0xc0
    3947:	mov    rsp,rbp
    394a:	pop    rbp
    394b:	ret
    394c:	mov    rsi,QWORD PTR [rsp+0x60]
    3951:	mov    rsi,QWORD PTR [rsp+0x60]
    3956:	mov    QWORD PTR [rsp+0x10],rsi
    395b:	mov    rsi,QWORD PTR [rsp+0x68]
    3960:	mov    QWORD PTR [rsp+0x18],rsi
    3965:	mov    rsi,QWORD PTR [rsp+0x70]
    396a:	mov    QWORD PTR [rsp+0x20],rsi
    396f:	mov    QWORD PTR [rsp+0x28],r15
    3974:	mov    QWORD PTR [rsp+0x30],r12
    3979:	mov    QWORD PTR [rsp+0x38],r13
    397e:	mov    QWORD PTR [rsp+0x40],r14
    3983:	add    rbx,0x1
    398a:	mov    rcx,QWORD PTR [rsp+0x88]
    3992:	jmp    3723 <botlish_fn_43+0x93>
    3997:	mov    eax,0xa
    399c:	mov    rbx,QWORD PTR [rsp+0x90]
    39a4:	mov    r12,QWORD PTR [rsp+0x98]
    39ac:	mov    r13,QWORD PTR [rsp+0xa0]
    39b4:	mov    r14,QWORD PTR [rsp+0xa8]
    39bc:	mov    r15,QWORD PTR [rsp+0xb0]
    39c4:	add    rsp,0xc0
    39cb:	mov    rsp,rbp
    39ce:	pop    rbp
    39cf:	ret
    39d0:	(bad)
    39d1:	add    BYTE PTR [rax],al
    39d3:	add    BYTE PTR [rax],al
    39d5:	add    BYTE PTR [rax],al
	...

00000000000039d8 <botlish_entry_43: ht_rehash_scan<list, int, int, List[mutarray], int>>:
    39d8:	push   rbp
    39d9:	mov    rbp,rsp
    39dc:	sub    rsp,0x30
    39e0:	mov    QWORD PTR [rsp+0x20],r12
    39e5:	mov    rsi,QWORD PTR [rdx]
    39e8:	mov    rax,QWORD PTR [rdx+0x8]
    39ec:	mov    rcx,QWORD PTR [rdx+0x10]
    39f0:	mov    r8,QWORD PTR [rdx+0x18]
    39f4:	mov    r9,QWORD PTR [rdx+0x20]
    39f8:	mov    r10,QWORD PTR [rdx+0x28]
    39fc:	mov    r11,QWORD PTR [rdx+0x30]
    3a00:	mov    r12,QWORD PTR [rdx+0x38]
    3a04:	mov    rdx,QWORD PTR [rdx+0x40]
    3a08:	mov    QWORD PTR [rsp],r10
    3a0c:	mov    QWORD PTR [rsp+0x8],r11
    3a11:	mov    QWORD PTR [rsp+0x10],r12
    3a16:	mov    QWORD PTR [rsp+0x18],rdx
    3a1b:	mov    rdx,rax
    3a1e:	call   3a23 <botlish_entry_43+0x4b>
			3a1f: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    3a23:	mov    r12,QWORD PTR [rsp+0x20]
    3a28:	add    rsp,0x30
    3a2c:	mov    rsp,rbp
    3a2f:	pop    rbp
    3a30:	ret

0000000000003a31 <botlish_fn_44: ht_rehash<mutarray, int>>:
    3a31:	push   rbp
    3a32:	mov    rbp,rsp
    3a35:	sub    rsp,0xd0
    3a3c:	mov    QWORD PTR [rsp+0xa0],rbx
    3a44:	mov    QWORD PTR [rsp+0xa8],r12
    3a4c:	mov    QWORD PTR [rsp+0xb0],r13
    3a54:	mov    QWORD PTR [rsp+0xb8],r14
    3a5c:	mov    QWORD PTR [rsp+0xc0],r15
    3a64:	mov    r13,rdi
    3a67:	mov    QWORD PTR [rsp+0x50],0x0
    3a70:	mov    QWORD PTR [rsp+0x58],0x0
    3a79:	mov    QWORD PTR [rsp+0x60],0x0
    3a82:	mov    QWORD PTR [rsp+0x68],0x0
    3a8b:	mov    QWORD PTR [rsp+0x20],rsi
    3a90:	mov    r12,rsi
    3a93:	mov    QWORD PTR [rsp+0x28],rdx
    3a98:	mov    rbx,rdx
    3a9b:	mov    rsi,r12
    3a9e:	mov    rdi,r13
    3aa1:	call   3aa6 <botlish_fn_44+0x75>
			3aa2: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    3aa6:	test   rax,rax
    3aa9:	je     3c78 <botlish_fn_44+0x247>
    3aaf:	mov    QWORD PTR [rsp+0x30],rax
    3ab4:	mov    r14,rax
    3ab7:	mov    rsi,r12
    3aba:	mov    rdi,r13
    3abd:	call   3ac2 <botlish_fn_44+0x91>
			3abe: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3ac2:	test   rax,rax
    3ac5:	je     3c78 <botlish_fn_44+0x247>
    3acb:	mov    QWORD PTR [rsp+0x38],rax
    3ad0:	mov    r15,rax
    3ad3:	mov    rsi,r12
    3ad6:	mov    rdi,r13
    3ad9:	call   3ade <botlish_fn_44+0xad>
			3ada: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3ade:	test   rax,rax
    3ae1:	je     3c78 <botlish_fn_44+0x247>
    3ae7:	mov    QWORD PTR [rsp+0x40],rax
    3aec:	mov    QWORD PTR [rsp+0x90],rax
    3af4:	mov    rsi,r12
    3af7:	mov    rdi,r13
    3afa:	call   3aff <botlish_fn_44+0xce>
			3afb: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3aff:	test   rax,rax
    3b02:	je     3c78 <botlish_fn_44+0x247>
    3b08:	mov    QWORD PTR [rsp+0x48],rax
    3b0d:	mov    QWORD PTR [rsp+0x88],rax
    3b15:	mov    rsi,rbx
    3b18:	mov    rdi,r13
    3b1b:	call   3b20 <botlish_fn_44+0xef>
			3b1c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b20:	mov    rcx,rax
    3b23:	mov    QWORD PTR [rsp+0x80],rax
    3b2b:	test   rax,rcx
    3b2e:	je     3c78 <botlish_fn_44+0x247>
    3b34:	mov    rax,QWORD PTR [rsp+0x80]
    3b3c:	mov    QWORD PTR [rsp+0x50],rax
    3b41:	mov    edx,0x1
    3b46:	mov    QWORD PTR [rsp+0x58],0x1
    3b4f:	mov    rcx,rbx
    3b52:	mov    rsi,QWORD PTR [rsp+0x80]
    3b5a:	mov    rdi,r13
    3b5d:	call   3b62 <botlish_fn_44+0x131>
			3b5e: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3b62:	test   rax,rax
    3b65:	je     3c78 <botlish_fn_44+0x247>
    3b6b:	mov    rsi,rbx
    3b6e:	mov    rdi,r13
    3b71:	call   3b76 <botlish_fn_44+0x145>
			3b72: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b76:	test   rax,rax
    3b79:	je     3c78 <botlish_fn_44+0x247>
    3b7f:	mov    QWORD PTR [rsp+0x58],rax
    3b84:	mov    QWORD PTR [rsp+0x78],rax
    3b89:	mov    rsi,rbx
    3b8c:	mov    rdi,r13
    3b8f:	call   3b94 <botlish_fn_44+0x163>
			3b90: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b94:	test   rax,rax
    3b97:	je     3c78 <botlish_fn_44+0x247>
    3b9d:	mov    QWORD PTR [rsp+0x60],rax
    3ba2:	mov    r8d,0x1
    3ba8:	mov    QWORD PTR [rsp+0x68],0x1
    3bb1:	mov    rcx,QWORD PTR [rsp+0x80]
    3bb9:	mov    QWORD PTR [rsp],rcx
    3bbd:	mov    rcx,QWORD PTR [rsp+0x78]
    3bc2:	mov    QWORD PTR [rsp+0x8],rcx
    3bc7:	mov    QWORD PTR [rsp+0x10],rax
    3bcc:	mov    QWORD PTR [rsp+0x70],rax
    3bd1:	mov    QWORD PTR [rsp+0x18],rbx
    3bd6:	mov    rcx,QWORD PTR [rsp+0x90]
    3bde:	mov    rdx,r15
    3be1:	mov    rsi,r14
    3be4:	mov    r9,QWORD PTR [rsp+0x88]
    3bec:	mov    rdi,r13
    3bef:	call   3bf4 <botlish_fn_44+0x1c3>
			3bf0: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    3bf4:	test   rax,rax
    3bf7:	je     3c78 <botlish_fn_44+0x247>
    3bfd:	mov    edx,0x1
    3c02:	mov    rcx,QWORD PTR [rsp+0x80]
    3c0a:	mov    rsi,r12
    3c0d:	mov    rdi,r13
    3c10:	call   3c15 <botlish_fn_44+0x1e4>
			3c11: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c15:	test   rax,rax
    3c18:	je     3c78 <botlish_fn_44+0x247>
    3c1e:	mov    edx,0x3
    3c23:	mov    rcx,QWORD PTR [rsp+0x78]
    3c28:	mov    rsi,r12
    3c2b:	mov    rdi,r13
    3c2e:	call   3c33 <botlish_fn_44+0x202>
			3c2f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c33:	test   rax,rax
    3c36:	je     3c78 <botlish_fn_44+0x247>
    3c3c:	mov    edx,0x5
    3c41:	mov    rcx,QWORD PTR [rsp+0x70]
    3c46:	mov    rsi,r12
    3c49:	mov    rdi,r13
    3c4c:	call   3c51 <botlish_fn_44+0x220>
			3c4d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c51:	test   rax,rax
    3c54:	je     3c78 <botlish_fn_44+0x247>
    3c5a:	mov    edx,0x9
    3c5f:	mov    ecx,0x1
    3c64:	mov    rsi,r12
    3c67:	mov    rdi,r13
    3c6a:	call   3c6f <botlish_fn_44+0x23e>
			3c6b: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c6f:	test   rax,rax
    3c72:	jne    3caf <botlish_fn_44+0x27e>
    3c78:	xor    rax,rax
    3c7b:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c83:	mov    r12,QWORD PTR [rsp+0xa8]
    3c8b:	mov    r13,QWORD PTR [rsp+0xb0]
    3c93:	mov    r14,QWORD PTR [rsp+0xb8]
    3c9b:	mov    r15,QWORD PTR [rsp+0xc0]
    3ca3:	add    rsp,0xd0
    3caa:	mov    rsp,rbp
    3cad:	pop    rbp
    3cae:	ret
    3caf:	mov    eax,0xa
    3cb4:	mov    rbx,QWORD PTR [rsp+0xa0]
    3cbc:	mov    r12,QWORD PTR [rsp+0xa8]
    3cc4:	mov    r13,QWORD PTR [rsp+0xb0]
    3ccc:	mov    r14,QWORD PTR [rsp+0xb8]
    3cd4:	mov    r15,QWORD PTR [rsp+0xc0]
    3cdc:	add    rsp,0xd0
    3ce3:	mov    rsp,rbp
    3ce6:	pop    rbp
    3ce7:	ret

0000000000003ce8 <botlish_entry_44: ht_rehash<mutarray, int>>:
    3ce8:	push   rbp
    3ce9:	mov    rbp,rsp
    3cec:	mov    rsi,QWORD PTR [rdx]
    3cef:	mov    rdx,QWORD PTR [rdx+0x8]
    3cf3:	call   3cf8 <botlish_entry_44+0x10>
			3cf4: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash<mutarray, int>
    3cf8:	mov    rsp,rbp
    3cfb:	pop    rbp
    3cfc:	ret
    3cfd:	add    BYTE PTR [rax],al
	...

0000000000003d00 <botlish_fn_45: ht_should_grow<mutarray>>:
    3d00:	push   rbp
    3d01:	mov    rbp,rsp
    3d04:	sub    rsp,0x40
    3d08:	mov    QWORD PTR [rsp+0x20],rbx
    3d0d:	mov    QWORD PTR [rsp+0x28],r12
    3d12:	mov    QWORD PTR [rsp+0x30],r13
    3d17:	mov    rbx,rdi
    3d1a:	mov    QWORD PTR [rsp],rsi
    3d1e:	mov    r12,rsi
    3d21:	mov    rsi,r12
    3d24:	mov    rdi,rbx
    3d27:	call   3d2c <botlish_fn_45+0x2c>
			3d28: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3d2c:	mov    rcx,rax
    3d2f:	mov    r13,rax
    3d32:	test   rax,rcx
    3d35:	je     3f24 <botlish_fn_45+0x224>
    3d3b:	mov    rax,r13
    3d3e:	mov    QWORD PTR [rsp+0x8],rax
    3d43:	mov    rsi,r12
    3d46:	mov    rdi,rbx
    3d49:	call   3d4e <botlish_fn_45+0x4e>
			3d4a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3d4e:	mov    rcx,rax
    3d51:	test   rcx,rcx
    3d54:	je     3f24 <botlish_fn_45+0x224>
    3d5a:	mov    QWORD PTR [rsp+0x10],rcx
    3d5f:	mov    edx,0x1
    3d64:	mov    rax,r13
    3d67:	test   rax,0x1
    3d6d:	jne    3d90 <botlish_fn_45+0x90>
    3d73:	xor    edx,edx
    3d75:	mov    rax,r13
    3d78:	test   rax,0x7
    3d7e:	jne    3d90 <botlish_fn_45+0x90>
    3d84:	mov    rax,r13
    3d87:	movzx  rax,BYTE PTR [rax]
    3d8b:	cmp    al,0x1
    3d8d:	sete   dl
    3d90:	test   dl,dl
    3d92:	jne    3db3 <botlish_fn_45+0xb3>
    3d98:	mov    rdi,rbx
    3d9b:	mov    rax,QWORD PTR [rdi+0x10]
    3d9f:	mov    rcx,QWORD PTR [rax+0x38]
    3da3:	xor    rdx,rdx
    3da6:	mov    rsi,r13
    3da9:	call   3dae <botlish_fn_45+0xae>
			3daa: R_X86_64_PLT32	rt_type_error-0x4
    3dae:	jmp    3f24 <botlish_fn_45+0x224>
    3db3:	mov    eax,0x1
    3db8:	test   rcx,0x1
    3dbf:	je     3dcd <botlish_fn_45+0xcd>
    3dc5:	mov    r8,rcx
    3dc8:	jmp    3df0 <botlish_fn_45+0xf0>
    3dcd:	xor    eax,eax
    3dcf:	test   rcx,0x7
    3dd6:	je     3de4 <botlish_fn_45+0xe4>
    3ddc:	mov    r8,rcx
    3ddf:	jmp    3df0 <botlish_fn_45+0xf0>
    3de4:	movzx  rax,BYTE PTR [rcx]
    3de8:	mov    r8,rcx
    3deb:	cmp    al,0x1
    3ded:	sete   al
    3df0:	test   al,al
    3df2:	jne    3e13 <botlish_fn_45+0x113>
    3df8:	mov    rdi,rbx
    3dfb:	mov    rax,QWORD PTR [rdi+0x10]
    3dff:	mov    rcx,QWORD PTR [rax+0x38]
    3e03:	xor    rdx,rdx
    3e06:	mov    rsi,r8
    3e09:	call   3e0e <botlish_fn_45+0x10e>
			3e0a: R_X86_64_PLT32	rt_type_error-0x4
    3e0e:	jmp    3f24 <botlish_fn_45+0x224>
    3e13:	mov    rcx,r8
    3e16:	mov    rsi,r13
    3e19:	mov    rax,rsi
    3e1c:	and    rax,rcx
    3e1f:	test   rax,0x1
    3e25:	jne    3e36 <botlish_fn_45+0x136>
    3e2b:	mov    rdx,r8
    3e2e:	mov    rsi,r13
    3e31:	jmp    3e54 <botlish_fn_45+0x154>
    3e36:	mov    rcx,r8
    3e39:	lea    rax,[rcx-0x1]
    3e3d:	mov    rsi,r13
    3e40:	add    rsi,rax
    3e43:	seto   al
    3e46:	test   al,al
    3e48:	je     3e5f <botlish_fn_45+0x15f>
    3e4e:	mov    rdx,r8
    3e51:	mov    rsi,r13
    3e54:	mov    rdi,rbx
    3e57:	call   3e5c <botlish_fn_45+0x15c>
			3e58: R_X86_64_PLT32	rt_int_add-0x4
    3e5c:	mov    rsi,rax
    3e5f:	mov    QWORD PTR [rsp+0x8],rsi
    3e64:	mov    QWORD PTR [rsp+0x10],0x3
    3e6d:	test   rsi,0x1
    3e74:	je     3e97 <botlish_fn_45+0x197>
    3e7a:	mov    rax,rsi
    3e7d:	add    rax,0x2
    3e81:	mov    rcx,rax
    3e84:	seto   al
    3e87:	test   al,al
    3e89:	jne    3e97 <botlish_fn_45+0x197>
    3e8f:	mov    rsi,rcx
    3e92:	jmp    3ea7 <botlish_fn_45+0x1a7>
    3e97:	mov    edx,0x3
    3e9c:	mov    rdi,rbx
    3e9f:	call   3ea4 <botlish_fn_45+0x1a4>
			3ea0: R_X86_64_PLT32	rt_int_add-0x4
    3ea4:	mov    rsi,rax
    3ea7:	mov    QWORD PTR [rsp+0x8],rsi
    3eac:	mov    edx,0x7
    3eb1:	mov    rdi,rdx
    3eb4:	mov    QWORD PTR [rsp+0x10],0x7
    3ebd:	test   rsi,0x1
    3ec4:	jne    3ed2 <botlish_fn_45+0x1d2>
    3eca:	mov    rdx,rdi
    3ecd:	jmp    3efe <botlish_fn_45+0x1fe>
    3ed2:	mov    rax,rsi
    3ed5:	sar    rax,1
    3ed8:	imul   QWORD PTR [rip+0x119]        # 3ff8 <botlish_fn_45+0x2f8>
    3edf:	seto   cl
    3ee2:	or     rax,0x1
    3ee6:	test   cl,cl
    3ee8:	je     3ef6 <botlish_fn_45+0x1f6>
    3eee:	mov    rdx,rdi
    3ef1:	jmp    3efe <botlish_fn_45+0x1fe>
    3ef6:	mov    rsi,rax
    3ef9:	jmp    3f09 <botlish_fn_45+0x209>
    3efe:	mov    rdi,rbx
    3f01:	call   3f06 <botlish_fn_45+0x206>
			3f02: R_X86_64_PLT32	rt_int_mul-0x4
    3f06:	mov    rsi,rax
    3f09:	mov    QWORD PTR [rsp],rsi
    3f0d:	mov    r13,rsi
    3f10:	mov    rsi,r12
    3f13:	mov    rdi,rbx
    3f16:	call   3f1b <botlish_fn_45+0x21b>
			3f17: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3f1b:	test   rax,rax
    3f1e:	jne    3f3f <botlish_fn_45+0x23f>
    3f24:	xor    rax,rax
    3f27:	mov    rbx,QWORD PTR [rsp+0x20]
    3f2c:	mov    r12,QWORD PTR [rsp+0x28]
    3f31:	mov    r13,QWORD PTR [rsp+0x30]
    3f36:	add    rsp,0x40
    3f3a:	mov    rsp,rbp
    3f3d:	pop    rbp
    3f3e:	ret
    3f3f:	mov    QWORD PTR [rsp+0x8],rax
    3f44:	mov    QWORD PTR [rsp+0x10],0x5
    3f4d:	test   rax,0x1
    3f53:	mov    rsi,rax
    3f56:	je     3f88 <botlish_fn_45+0x288>
    3f5c:	mov    rcx,rsi
    3f5f:	mov    rax,rcx
    3f62:	sar    rax,1
    3f65:	imul   QWORD PTR [rip+0x94]        # 4000 <botlish_fn_45+0x300>
    3f6c:	seto   dil
    3f70:	or     rax,0x1
    3f74:	test   dil,dil
    3f77:	jne    3f88 <botlish_fn_45+0x288>
    3f7d:	mov    rdx,rax
    3f80:	mov    rsi,r13
    3f83:	jmp    3f9b <botlish_fn_45+0x29b>
    3f88:	mov    edx,0x5
    3f8d:	mov    rdi,rbx
    3f90:	call   3f95 <botlish_fn_45+0x295>
			3f91: R_X86_64_PLT32	rt_int_mul-0x4
    3f95:	mov    rdx,rax
    3f98:	mov    rsi,r13
    3f9b:	mov    r10,rsi
    3f9e:	and    r10,rdx
    3fa1:	test   r10,0x1
    3fa8:	jne    3fcf <botlish_fn_45+0x2cf>
    3fae:	mov    rdi,rbx
    3fb1:	call   3fb6 <botlish_fn_45+0x2b6>
			3fb2: R_X86_64_PLT32	rt_int_cmp-0x4
    3fb6:	mov    r8d,0x2
    3fbc:	test   rax,rax
    3fbf:	mov    rax,r8
    3fc2:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3ff8 <botlish_fn_45+0x2f8>
    3fca:	jmp    3fdf <botlish_fn_45+0x2df>
    3fcf:	mov    eax,0x2
    3fd4:	cmp    rsi,rdx
    3fd7:	cmovg  rax,QWORD PTR [rip+0x19]        # 3ff8 <botlish_fn_45+0x2f8>
    3fdf:	mov    rbx,QWORD PTR [rsp+0x20]
    3fe4:	mov    r12,QWORD PTR [rsp+0x28]
    3fe9:	mov    r13,QWORD PTR [rsp+0x30]
    3fee:	add    rsp,0x40
    3ff2:	mov    rsp,rbp
    3ff5:	pop    rbp
    3ff6:	ret
    3ff7:	add    BYTE PTR [rsi],al
    3ff9:	add    BYTE PTR [rax],al
    3ffb:	add    BYTE PTR [rax],al
    3ffd:	add    BYTE PTR [rax],al
    3fff:	add    BYTE PTR [rax+rax*1],al
    4002:	add    BYTE PTR [rax],al
    4004:	add    BYTE PTR [rax],al
	...

0000000000004008 <botlish_entry_45: ht_should_grow<mutarray>>:
    4008:	push   rbp
    4009:	mov    rbp,rsp
    400c:	mov    rsi,QWORD PTR [rdx]
    400f:	call   4014 <botlish_entry_45+0xc>
			4010: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_should_grow<mutarray>
    4014:	mov    rsp,rbp
    4017:	pop    rbp
    4018:	ret
    4019:	add    BYTE PTR [rax],al
    401b:	add    BYTE PTR [rax],al
    401d:	add    BYTE PTR [rax],al
	...

0000000000004020 <botlish_fn_46: ht_grow_or_clean<mutarray>>:
    4020:	push   rbp
    4021:	mov    rbp,rsp
    4024:	sub    rsp,0x40
    4028:	mov    QWORD PTR [rsp+0x20],rbx
    402d:	mov    QWORD PTR [rsp+0x28],r12
    4032:	mov    QWORD PTR [rsp+0x30],r13
    4037:	mov    rbx,rdi
    403a:	mov    QWORD PTR [rsp+0x10],0x0
    4043:	mov    QWORD PTR [rsp],rsi
    4047:	mov    r12,rsi
    404a:	mov    rsi,r12
    404d:	mov    rdi,rbx
    4050:	call   4055 <botlish_fn_46+0x35>
			4051: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4055:	test   rax,rax
    4058:	mov    r13,rax
    405b:	je     4248 <botlish_fn_46+0x228>
    4061:	mov    rsi,r12
    4064:	mov    rdi,rbx
    4067:	call   406c <botlish_fn_46+0x4c>
			4068: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    406c:	mov    rcx,rax
    406f:	test   rcx,rcx
    4072:	je     4248 <botlish_fn_46+0x228>
    4078:	mov    edx,0x1
    407d:	mov    rax,r13
    4080:	test   rax,0x1
    4086:	je     4094 <botlish_fn_46+0x74>
    408c:	mov    r13,rax
    408f:	jmp    40b8 <botlish_fn_46+0x98>
    4094:	xor    edx,edx
    4096:	test   rax,0x7
    409c:	je     40aa <botlish_fn_46+0x8a>
    40a2:	mov    r13,rax
    40a5:	jmp    40b8 <botlish_fn_46+0x98>
    40aa:	movzx  rdx,BYTE PTR [rax]
    40ae:	mov    r13,rax
    40b1:	rex cmp dl,0x1
    40b5:	sete   dl
    40b8:	test   dl,dl
    40ba:	jne    40db <botlish_fn_46+0xbb>
    40c0:	mov    rdi,rbx
    40c3:	mov    rsi,QWORD PTR [rdi+0x10]
    40c7:	mov    rcx,QWORD PTR [rsi+0x40]
    40cb:	xor    rdx,rdx
    40ce:	mov    rsi,r13
    40d1:	call   40d6 <botlish_fn_46+0xb6>
			40d2: R_X86_64_PLT32	rt_type_error-0x4
    40d6:	jmp    4248 <botlish_fn_46+0x228>
    40db:	mov    rsi,r13
    40de:	mov    eax,0x1
    40e3:	test   rcx,0x1
    40ea:	je     40f8 <botlish_fn_46+0xd8>
    40f0:	mov    r8,rcx
    40f3:	jmp    411d <botlish_fn_46+0xfd>
    40f8:	xor    eax,eax
    40fa:	test   rcx,0x7
    4101:	je     410f <botlish_fn_46+0xef>
    4107:	mov    r8,rcx
    410a:	jmp    411d <botlish_fn_46+0xfd>
    410f:	movzx  r11,BYTE PTR [rcx]
    4113:	mov    r8,rcx
    4116:	cmp    r11b,0x1
    411a:	sete   al
    411d:	test   al,al
    411f:	jne    4140 <botlish_fn_46+0x120>
    4125:	mov    rdi,rbx
    4128:	mov    rax,QWORD PTR [rdi+0x10]
    412c:	mov    rcx,QWORD PTR [rax+0x40]
    4130:	xor    rdx,rdx
    4133:	mov    rsi,r8
    4136:	call   413b <botlish_fn_46+0x11b>
			4137: R_X86_64_PLT32	rt_type_error-0x4
    413b:	jmp    4248 <botlish_fn_46+0x228>
    4140:	mov    rcx,r8
    4143:	mov    rax,rsi
    4146:	and    rax,rcx
    4149:	test   rax,0x1
    414f:	jne    4175 <botlish_fn_46+0x155>
    4155:	mov    rdx,r8
    4158:	mov    rdi,rbx
    415b:	call   4160 <botlish_fn_46+0x140>
			415c: R_X86_64_PLT32	rt_int_cmp-0x4
    4160:	mov    ecx,0x2
    4165:	test   rax,rax
    4168:	cmovg  rcx,QWORD PTR [rip+0x110]        # 4280 <botlish_fn_46+0x260>
    4170:	jmp    4188 <botlish_fn_46+0x168>
    4175:	mov    ecx,0x2
    417a:	mov    r9,r8
    417d:	cmp    rsi,r9
    4180:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 4280 <botlish_fn_46+0x260>
    4188:	cmp    rcx,0x6
    418c:	je     4218 <botlish_fn_46+0x1f8>
    4192:	mov    rsi,r12
    4195:	mov    rdi,rbx
    4198:	call   419d <botlish_fn_46+0x17d>
			4199: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    419d:	test   rax,rax
    41a0:	je     4248 <botlish_fn_46+0x228>
    41a6:	mov    QWORD PTR [rsp+0x8],rax
    41ab:	mov    QWORD PTR [rsp+0x10],0x5
    41b4:	test   rax,0x1
    41ba:	mov    rsi,rax
    41bd:	je     41ea <botlish_fn_46+0x1ca>
    41c3:	mov    rcx,rsi
    41c6:	mov    rax,rcx
    41c9:	sar    rax,1
    41cc:	imul   QWORD PTR [rip+0xb5]        # 4288 <botlish_fn_46+0x268>
    41d3:	seto   cl
    41d6:	or     rax,0x1
    41da:	test   cl,cl
    41dc:	jne    41ea <botlish_fn_46+0x1ca>
    41e2:	mov    rdx,rax
    41e5:	jmp    41fa <botlish_fn_46+0x1da>
    41ea:	mov    edx,0x5
    41ef:	mov    rdi,rbx
    41f2:	call   41f7 <botlish_fn_46+0x1d7>
			41f3: R_X86_64_PLT32	rt_int_mul-0x4
    41f7:	mov    rdx,rax
    41fa:	mov    QWORD PTR [rsp+0x8],rdx
    41ff:	mov    rsi,r12
    4202:	mov    rdi,rbx
    4205:	call   420a <botlish_fn_46+0x1ea>
			4206: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash<mutarray, int>
    420a:	test   rax,rax
    420d:	je     4248 <botlish_fn_46+0x228>
    4213:	jmp    4263 <botlish_fn_46+0x243>
    4218:	mov    rsi,r12
    421b:	mov    rdi,rbx
    421e:	call   4223 <botlish_fn_46+0x203>
			421f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4223:	test   rax,rax
    4226:	je     4248 <botlish_fn_46+0x228>
    422c:	mov    QWORD PTR [rsp+0x8],rax
    4231:	mov    rdx,rax
    4234:	mov    rsi,r12
    4237:	mov    rdi,rbx
    423a:	call   423f <botlish_fn_46+0x21f>
			423b: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash<mutarray, int>
    423f:	test   rax,rax
    4242:	jne    4263 <botlish_fn_46+0x243>
    4248:	xor    rax,rax
    424b:	mov    rbx,QWORD PTR [rsp+0x20]
    4250:	mov    r12,QWORD PTR [rsp+0x28]
    4255:	mov    r13,QWORD PTR [rsp+0x30]
    425a:	add    rsp,0x40
    425e:	mov    rsp,rbp
    4261:	pop    rbp
    4262:	ret
    4263:	mov    rbx,QWORD PTR [rsp+0x20]
    4268:	mov    r12,QWORD PTR [rsp+0x28]
    426d:	mov    r13,QWORD PTR [rsp+0x30]
    4272:	add    rsp,0x40
    4276:	mov    rsp,rbp
    4279:	pop    rbp
    427a:	ret
    427b:	add    BYTE PTR [rax],al
    427d:	add    BYTE PTR [rax],al
    427f:	add    BYTE PTR [rsi],al
    4281:	add    BYTE PTR [rax],al
    4283:	add    BYTE PTR [rax],al
    4285:	add    BYTE PTR [rax],al
    4287:	add    BYTE PTR [rax+rax*1],al
    428a:	add    BYTE PTR [rax],al
    428c:	add    BYTE PTR [rax],al
	...

0000000000004290 <botlish_entry_46: ht_grow_or_clean<mutarray>>:
    4290:	push   rbp
    4291:	mov    rbp,rsp
    4294:	mov    rsi,QWORD PTR [rdx]
    4297:	call   429c <botlish_entry_46+0xc>
			4298: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_grow_or_clean<mutarray>
    429c:	mov    rsp,rbp
    429f:	pop    rbp
    42a0:	ret
    42a1:	add    BYTE PTR [rax],al
    42a3:	add    BYTE PTR [rax],al
    42a5:	add    BYTE PTR [rax],al
	...

00000000000042a8 <botlish_fn_47: ht_place<mutarray, int, any, any>>:
    42a8:	push   rbp
    42a9:	mov    rbp,rsp
    42ac:	sub    rsp,0x70
    42b0:	mov    QWORD PTR [rsp+0x40],rbx
    42b5:	mov    QWORD PTR [rsp+0x48],r12
    42ba:	mov    QWORD PTR [rsp+0x50],r13
    42bf:	mov    QWORD PTR [rsp+0x58],r14
    42c4:	mov    QWORD PTR [rsp+0x60],r15
    42c9:	mov    rbx,rdi
    42cc:	mov    r14,r8
    42cf:	mov    r15,rdx
    42d2:	mov    QWORD PTR [rsp+0x28],rcx
    42d7:	mov    QWORD PTR [rsp],rsi
    42db:	mov    r12,rsi
    42de:	mov    rsi,r12
    42e1:	mov    rdi,rbx
    42e4:	call   42e9 <botlish_fn_47+0x41>
			42e5: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    42e9:	test   rax,rax
    42ec:	je     4650 <botlish_fn_47+0x3a8>
    42f2:	xor    ecx,ecx
    42f4:	test   rax,0x7
    42fa:	je     430a <botlish_fn_47+0x62>
    4300:	mov    QWORD PTR [rsp+0x30],rax
    4305:	jmp    431a <botlish_fn_47+0x72>
    430a:	movzx  rcx,BYTE PTR [rax]
    430e:	mov    QWORD PTR [rsp+0x30],rax
    4313:	rex cmp cl,0x8
    4317:	sete   cl
    431a:	test   cl,cl
    431c:	jne    4341 <botlish_fn_47+0x99>
    4322:	mov    rdi,rbx
    4325:	mov    rax,QWORD PTR [rdi+0x10]
    4329:	mov    rcx,QWORD PTR [rax+0x30]
    432d:	mov    edx,0x8
    4332:	mov    rsi,QWORD PTR [rsp+0x30]
    4337:	call   433c <botlish_fn_47+0x94>
			4338: R_X86_64_PLT32	rt_type_error-0x4
    433c:	jmp    4650 <botlish_fn_47+0x3a8>
    4341:	mov    rdx,r15
    4344:	mov    rsi,QWORD PTR [rsp+0x30]
    4349:	mov    rdi,rbx
    434c:	call   4351 <botlish_fn_47+0xa9>
			434d: R_X86_64_PLT32	rt_mutarray_get-0x4
    4351:	test   rax,rax
    4354:	je     4650 <botlish_fn_47+0x3a8>
    435a:	mov    QWORD PTR [rsp+0x8],rax
    435f:	mov    r13,rax
    4362:	mov    ecx,0x3
    4367:	mov    rsi,QWORD PTR [rsp+0x30]
    436c:	mov    rdx,r15
    436f:	mov    rdi,rbx
    4372:	call   4377 <botlish_fn_47+0xcf>
			4373: R_X86_64_PLT32	rt_mutarray_set-0x4
    4377:	test   rax,rax
    437a:	je     4650 <botlish_fn_47+0x3a8>
    4380:	mov    rsi,r12
    4383:	mov    rdi,rbx
    4386:	call   438b <botlish_fn_47+0xe3>
			4387: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    438b:	test   rax,rax
    438e:	je     4650 <botlish_fn_47+0x3a8>
    4394:	xor    ecx,ecx
    4396:	test   rax,0x7
    439c:	je     43aa <botlish_fn_47+0x102>
    43a2:	mov    rsi,rax
    43a5:	jmp    43b8 <botlish_fn_47+0x110>
    43aa:	movzx  rcx,BYTE PTR [rax]
    43ae:	mov    rsi,rax
    43b1:	rex cmp cl,0x8
    43b5:	sete   cl
    43b8:	test   cl,cl
    43ba:	jne    43d9 <botlish_fn_47+0x131>
    43c0:	mov    rdi,rbx
    43c3:	mov    rax,QWORD PTR [rdi+0x10]
    43c7:	mov    rcx,QWORD PTR [rax]
    43ca:	mov    edx,0x8
    43cf:	call   43d4 <botlish_fn_47+0x12c>
			43d0: R_X86_64_PLT32	rt_type_error-0x4
    43d4:	jmp    4650 <botlish_fn_47+0x3a8>
    43d9:	mov    rcx,QWORD PTR [rsp+0x28]
    43de:	mov    rdx,r15
    43e1:	mov    rdi,rbx
    43e4:	call   43e9 <botlish_fn_47+0x141>
			43e5: R_X86_64_PLT32	rt_mutarray_set-0x4
    43e9:	test   rax,rax
    43ec:	je     4650 <botlish_fn_47+0x3a8>
    43f2:	mov    rsi,r12
    43f5:	mov    rdi,rbx
    43f8:	call   43fd <botlish_fn_47+0x155>
			43f9: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    43fd:	test   rax,rax
    4400:	je     4650 <botlish_fn_47+0x3a8>
    4406:	xor    esi,esi
    4408:	test   rax,0x7
    440e:	jne    4420 <botlish_fn_47+0x178>
    4414:	movzx  rcx,BYTE PTR [rax]
    4418:	rex cmp cl,0x8
    441c:	sete   sil
    4420:	test   sil,sil
    4423:	jne    4445 <botlish_fn_47+0x19d>
    4429:	mov    rdi,rbx
    442c:	mov    rsi,QWORD PTR [rdi+0x10]
    4430:	mov    rcx,QWORD PTR [rsi]
    4433:	mov    edx,0x8
    4438:	mov    rsi,rax
    443b:	call   4440 <botlish_fn_47+0x198>
			443c: R_X86_64_PLT32	rt_type_error-0x4
    4440:	jmp    4650 <botlish_fn_47+0x3a8>
    4445:	mov    rcx,r14
    4448:	mov    rdx,r15
    444b:	mov    rsi,rax
    444e:	mov    rdi,rbx
    4451:	call   4456 <botlish_fn_47+0x1ae>
			4452: R_X86_64_PLT32	rt_mutarray_set-0x4
    4456:	test   rax,rax
    4459:	je     4650 <botlish_fn_47+0x3a8>
    445f:	mov    QWORD PTR [rsp+0x10],0x7
    4468:	mov    rsi,r12
    446b:	mov    rdi,rbx
    446e:	call   4473 <botlish_fn_47+0x1cb>
			446f: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    4473:	test   rax,rax
    4476:	je     4650 <botlish_fn_47+0x3a8>
    447c:	mov    QWORD PTR [rsp+0x18],rax
    4481:	mov    QWORD PTR [rsp+0x20],0x3
    448a:	mov    ecx,0x1
    448f:	test   rax,0x1
    4495:	je     44a3 <botlish_fn_47+0x1fb>
    449b:	mov    rsi,rax
    449e:	jmp    44c7 <botlish_fn_47+0x21f>
    44a3:	xor    ecx,ecx
    44a5:	test   rax,0x7
    44ab:	je     44b9 <botlish_fn_47+0x211>
    44b1:	mov    rsi,rax
    44b4:	jmp    44c7 <botlish_fn_47+0x21f>
    44b9:	movzx  rcx,BYTE PTR [rax]
    44bd:	mov    rsi,rax
    44c0:	rex cmp cl,0x1
    44c4:	sete   cl
    44c7:	test   cl,cl
    44c9:	jne    44e7 <botlish_fn_47+0x23f>
    44cf:	mov    rdi,rbx
    44d2:	mov    rax,QWORD PTR [rdi+0x10]
    44d6:	mov    rcx,QWORD PTR [rax+0x38]
    44da:	xor    rdx,rdx
    44dd:	call   44e2 <botlish_fn_47+0x23a>
			44de: R_X86_64_PLT32	rt_type_error-0x4
    44e2:	jmp    4650 <botlish_fn_47+0x3a8>
    44e7:	test   rsi,0x1
    44ee:	je     4506 <botlish_fn_47+0x25e>
    44f4:	mov    rcx,rsi
    44f7:	add    rcx,0x2
    44fb:	seto   al
    44fe:	test   al,al
    4500:	je     4516 <botlish_fn_47+0x26e>
    4506:	mov    edx,0x3
    450b:	mov    rdi,rbx
    450e:	call   4513 <botlish_fn_47+0x26b>
			450f: R_X86_64_PLT32	rt_int_add-0x4
    4513:	mov    rcx,rax
    4516:	mov    edx,0x7
    451b:	mov    rsi,r12
    451e:	mov    rdi,rbx
    4521:	call   4526 <botlish_fn_47+0x27e>
			4522: R_X86_64_PLT32	rt_mutarray_set-0x4
    4526:	test   rax,rax
    4529:	je     4650 <botlish_fn_47+0x3a8>
    452f:	mov    rax,r13
    4532:	test   rax,0x1
    4538:	jne    455c <botlish_fn_47+0x2b4>
    453e:	mov    edx,0x5
    4543:	mov    rsi,r13
    4546:	mov    rdi,rbx
    4549:	call   454e <botlish_fn_47+0x2a6>
			454a: R_X86_64_PLT32	rt_value_eq-0x4
    454e:	test   rax,rax
    4551:	je     4650 <botlish_fn_47+0x3a8>
    4557:	jmp    4570 <botlish_fn_47+0x2c8>
    455c:	mov    rsi,r13
    455f:	mov    eax,0x2
    4564:	cmp    rsi,0x5
    4568:	cmove  rax,QWORD PTR [rip+0x130]        # 46a0 <botlish_fn_47+0x3f8>
    4570:	cmp    rax,0x6
    4574:	jne    4675 <botlish_fn_47+0x3cd>
    457a:	mov    QWORD PTR [rsp+0x8],0x9
    4583:	mov    rsi,r12
    4586:	mov    rdi,rbx
    4589:	call   458e <botlish_fn_47+0x2e6>
			458a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    458e:	test   rax,rax
    4591:	je     4650 <botlish_fn_47+0x3a8>
    4597:	mov    QWORD PTR [rsp+0x10],rax
    459c:	mov    QWORD PTR [rsp+0x18],0x3
    45a5:	mov    ecx,0x1
    45aa:	test   rax,0x1
    45b0:	je     45be <botlish_fn_47+0x316>
    45b6:	mov    rsi,rax
    45b9:	jmp    45e2 <botlish_fn_47+0x33a>
    45be:	xor    ecx,ecx
    45c0:	test   rax,0x7
    45c6:	je     45d4 <botlish_fn_47+0x32c>
    45cc:	mov    rsi,rax
    45cf:	jmp    45e2 <botlish_fn_47+0x33a>
    45d4:	movzx  rcx,BYTE PTR [rax]
    45d8:	mov    rsi,rax
    45db:	rex cmp cl,0x1
    45df:	sete   cl
    45e2:	test   cl,cl
    45e4:	jne    4602 <botlish_fn_47+0x35a>
    45ea:	mov    rdi,rbx
    45ed:	mov    rcx,QWORD PTR [rdi+0x10]
    45f1:	mov    rcx,QWORD PTR [rcx+0x48]
    45f5:	xor    rdx,rdx
    45f8:	call   45fd <botlish_fn_47+0x355>
			45f9: R_X86_64_PLT32	rt_type_error-0x4
    45fd:	jmp    4650 <botlish_fn_47+0x3a8>
    4602:	test   rsi,0x1
    4609:	je     4627 <botlish_fn_47+0x37f>
    460f:	mov    r8,rsi
    4612:	sub    r8,0x3
    4616:	seto   dil
    461a:	lea    rcx,[r8+0x1]
    461e:	test   dil,dil
    4621:	je     4637 <botlish_fn_47+0x38f>
    4627:	mov    edx,0x3
    462c:	mov    rdi,rbx
    462f:	call   4634 <botlish_fn_47+0x38c>
			4630: R_X86_64_PLT32	rt_int_sub-0x4
    4634:	mov    rcx,rax
    4637:	mov    edx,0x9
    463c:	mov    rsi,r12
    463f:	mov    rdi,rbx
    4642:	call   4647 <botlish_fn_47+0x39f>
			4643: R_X86_64_PLT32	rt_mutarray_set-0x4
    4647:	test   rax,rax
    464a:	jne    4675 <botlish_fn_47+0x3cd>
    4650:	xor    rax,rax
    4653:	mov    rbx,QWORD PTR [rsp+0x40]
    4658:	mov    r12,QWORD PTR [rsp+0x48]
    465d:	mov    r13,QWORD PTR [rsp+0x50]
    4662:	mov    r14,QWORD PTR [rsp+0x58]
    4667:	mov    r15,QWORD PTR [rsp+0x60]
    466c:	add    rsp,0x70
    4670:	mov    rsp,rbp
    4673:	pop    rbp
    4674:	ret
    4675:	mov    eax,0xa
    467a:	mov    rbx,QWORD PTR [rsp+0x40]
    467f:	mov    r12,QWORD PTR [rsp+0x48]
    4684:	mov    r13,QWORD PTR [rsp+0x50]
    4689:	mov    r14,QWORD PTR [rsp+0x58]
    468e:	mov    r15,QWORD PTR [rsp+0x60]
    4693:	add    rsp,0x70
    4697:	mov    rsp,rbp
    469a:	pop    rbp
    469b:	ret
    469c:	add    BYTE PTR [rax],al
    469e:	add    BYTE PTR [rax],al
    46a0:	(bad)
    46a1:	add    BYTE PTR [rax],al
    46a3:	add    BYTE PTR [rax],al
    46a5:	add    BYTE PTR [rax],al
	...

00000000000046a8 <botlish_entry_47: ht_place<mutarray, int, any, any>>:
    46a8:	push   rbp
    46a9:	mov    rbp,rsp
    46ac:	mov    rsi,QWORD PTR [rdx]
    46af:	mov    r9,QWORD PTR [rdx+0x8]
    46b3:	mov    rcx,QWORD PTR [rdx+0x10]
    46b7:	mov    r8,QWORD PTR [rdx+0x18]
    46bb:	mov    rdx,r9
    46be:	call   46c3 <botlish_entry_47+0x1b>
			46bf: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_place<mutarray, int, any, any>
    46c3:	mov    rsp,rbp
    46c6:	pop    rbp
    46c7:	ret

00000000000046c8 <botlish_fn_48: ht_set<mutarray, any, any>>:
    46c8:	push   rbp
    46c9:	mov    rbp,rsp
    46cc:	sub    rsp,0x60
    46d0:	mov    QWORD PTR [rsp+0x30],rbx
    46d5:	mov    QWORD PTR [rsp+0x38],r12
    46da:	mov    QWORD PTR [rsp+0x40],r13
    46df:	mov    QWORD PTR [rsp+0x48],r14
    46e4:	mov    QWORD PTR [rsp+0x50],r15
    46e9:	mov    rbx,rdi
    46ec:	mov    r13,rdx
    46ef:	mov    QWORD PTR [rsp],rsi
    46f3:	mov    r14,rsi
    46f6:	mov    QWORD PTR [rsp+0x8],rdx
    46fb:	mov    QWORD PTR [rsp+0x10],rcx
    4700:	mov    r12,rcx
    4703:	mov    rdx,r13
    4706:	mov    rsi,r14
    4709:	mov    rdi,rbx
    470c:	call   4711 <botlish_fn_48+0x49>
			470d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, any>
    4711:	test   rax,rax
    4714:	je     497e <botlish_fn_48+0x2b6>
    471a:	mov    QWORD PTR [rsp+0x18],rax
    471f:	mov    rcx,rax
    4722:	mov    r8,0xffffffffffffffff
    4729:	mov    QWORD PTR [rsp+0x28],r8
    472e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    4737:	mov    rdx,r13
    473a:	mov    rsi,r14
    473d:	mov    rdi,rbx
    4740:	call   4745 <botlish_fn_48+0x7d>
			4741: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_find_insert<mutarray, any, int, int>
    4745:	mov    rcx,rax
    4748:	mov    r15,rax
    474b:	test   rax,rcx
    474e:	je     497e <botlish_fn_48+0x2b6>
    4754:	mov    rax,r15
    4757:	mov    QWORD PTR [rsp+0x18],rax
    475c:	mov    rsi,r14
    475f:	mov    rdi,rbx
    4762:	call   4767 <botlish_fn_48+0x9f>
			4763: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    4767:	test   rax,rax
    476a:	je     497e <botlish_fn_48+0x2b6>
    4770:	xor    ecx,ecx
    4772:	test   rax,0x7
    4778:	je     4786 <botlish_fn_48+0xbe>
    477e:	mov    r8,rax
    4781:	jmp    4794 <botlish_fn_48+0xcc>
    4786:	movzx  rcx,BYTE PTR [rax]
    478a:	mov    r8,rax
    478d:	rex cmp cl,0x8
    4791:	sete   cl
    4794:	test   cl,cl
    4796:	jne    47b9 <botlish_fn_48+0xf1>
    479c:	mov    rdi,rbx
    479f:	mov    rsi,QWORD PTR [rdi+0x10]
    47a3:	mov    rcx,QWORD PTR [rsi+0x30]
    47a7:	mov    edx,0x8
    47ac:	mov    rsi,r8
    47af:	call   47b4 <botlish_fn_48+0xec>
			47b0: R_X86_64_PLT32	rt_type_error-0x4
    47b4:	jmp    497e <botlish_fn_48+0x2b6>
    47b9:	mov    rsi,r8
    47bc:	mov    rdx,r15
    47bf:	mov    rdi,rbx
    47c2:	call   47c7 <botlish_fn_48+0xff>
			47c3: R_X86_64_PLT32	rt_mutarray_get-0x4
    47c7:	test   rax,rax
    47ca:	je     497e <botlish_fn_48+0x2b6>
    47d0:	test   rax,0x1
    47d6:	mov    rsi,rax
    47d9:	jne    47fa <botlish_fn_48+0x132>
    47df:	mov    edx,0x3
    47e4:	mov    rdi,rbx
    47e7:	call   47ec <botlish_fn_48+0x124>
			47e8: R_X86_64_PLT32	rt_value_eq-0x4
    47ec:	test   rax,rax
    47ef:	je     497e <botlish_fn_48+0x2b6>
    47f5:	jmp    480b <botlish_fn_48+0x143>
    47fa:	mov    eax,0x2
    47ff:	cmp    rsi,0x3
    4803:	cmove  rax,QWORD PTR [rip+0x1c5]        # 49d0 <botlish_fn_48+0x308>
    480b:	cmp    rax,0x6
    480f:	je     490e <botlish_fn_48+0x246>
    4815:	mov    rsi,r14
    4818:	mov    rdi,rbx
    481b:	call   4820 <botlish_fn_48+0x158>
			481c: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_should_grow<mutarray>
    4820:	test   rax,rax
    4823:	je     497e <botlish_fn_48+0x2b6>
    4829:	cmp    rax,0x6
    482d:	je     4872 <botlish_fn_48+0x1aa>
    4833:	mov    rcx,r13
    4836:	mov    rdx,r15
    4839:	mov    rsi,r14
    483c:	mov    rdi,rbx
    483f:	mov    r8,r12
    4842:	call   4847 <botlish_fn_48+0x17f>
			4843: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_place<mutarray, int, any, any>
    4847:	test   rax,rax
    484a:	je     497e <botlish_fn_48+0x2b6>
    4850:	mov    rbx,QWORD PTR [rsp+0x30]
    4855:	mov    r12,QWORD PTR [rsp+0x38]
    485a:	mov    r13,QWORD PTR [rsp+0x40]
    485f:	mov    r14,QWORD PTR [rsp+0x48]
    4864:	mov    r15,QWORD PTR [rsp+0x50]
    4869:	add    rsp,0x60
    486d:	mov    rsp,rbp
    4870:	pop    rbp
    4871:	ret
    4872:	mov    rsi,r14
    4875:	mov    rdi,rbx
    4878:	call   487d <botlish_fn_48+0x1b5>
			4879: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_grow_or_clean<mutarray>
    487d:	test   rax,rax
    4880:	je     497e <botlish_fn_48+0x2b6>
    4886:	mov    rdx,r13
    4889:	mov    rsi,r14
    488c:	mov    rdi,rbx
    488f:	call   4894 <botlish_fn_48+0x1cc>
			4890: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, any>
    4894:	test   rax,rax
    4897:	je     497e <botlish_fn_48+0x2b6>
    489d:	mov    QWORD PTR [rsp+0x18],rax
    48a2:	mov    rcx,rax
    48a5:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    48ae:	mov    r8,QWORD PTR [rsp+0x28]
    48b3:	mov    rdx,r13
    48b6:	mov    rsi,r14
    48b9:	mov    rdi,rbx
    48bc:	call   48c1 <botlish_fn_48+0x1f9>
			48bd: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_find_insert<mutarray, any, int, int>
    48c1:	test   rax,rax
    48c4:	je     497e <botlish_fn_48+0x2b6>
    48ca:	mov    QWORD PTR [rsp+0x18],rax
    48cf:	mov    rcx,r13
    48d2:	mov    rdx,rax
    48d5:	mov    rsi,r14
    48d8:	mov    rdi,rbx
    48db:	mov    r8,r12
    48de:	call   48e3 <botlish_fn_48+0x21b>
			48df: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_place<mutarray, int, any, any>
    48e3:	test   rax,rax
    48e6:	je     497e <botlish_fn_48+0x2b6>
    48ec:	mov    rbx,QWORD PTR [rsp+0x30]
    48f1:	mov    r12,QWORD PTR [rsp+0x38]
    48f6:	mov    r13,QWORD PTR [rsp+0x40]
    48fb:	mov    r14,QWORD PTR [rsp+0x48]
    4900:	mov    r15,QWORD PTR [rsp+0x50]
    4905:	add    rsp,0x60
    4909:	mov    rsp,rbp
    490c:	pop    rbp
    490d:	ret
    490e:	mov    rsi,r14
    4911:	mov    rdi,rbx
    4914:	call   4919 <botlish_fn_48+0x251>
			4915: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    4919:	test   rax,rax
    491c:	je     497e <botlish_fn_48+0x2b6>
    4922:	xor    ecx,ecx
    4924:	test   rax,0x7
    492a:	je     4938 <botlish_fn_48+0x270>
    4930:	mov    rsi,rax
    4933:	jmp    4946 <botlish_fn_48+0x27e>
    4938:	movzx  rcx,BYTE PTR [rax]
    493c:	mov    rsi,rax
    493f:	rex cmp cl,0x8
    4943:	sete   cl
    4946:	test   cl,cl
    4948:	jne    4967 <botlish_fn_48+0x29f>
    494e:	mov    rdi,rbx
    4951:	mov    rax,QWORD PTR [rdi+0x10]
    4955:	mov    rcx,QWORD PTR [rax]
    4958:	mov    edx,0x8
    495d:	call   4962 <botlish_fn_48+0x29a>
			495e: R_X86_64_PLT32	rt_type_error-0x4
    4962:	jmp    497e <botlish_fn_48+0x2b6>
    4967:	mov    rcx,r12
    496a:	mov    rdx,r15
    496d:	mov    rdi,rbx
    4970:	call   4975 <botlish_fn_48+0x2ad>
			4971: R_X86_64_PLT32	rt_mutarray_set-0x4
    4975:	test   rax,rax
    4978:	jne    49a3 <botlish_fn_48+0x2db>
    497e:	xor    rax,rax
    4981:	mov    rbx,QWORD PTR [rsp+0x30]
    4986:	mov    r12,QWORD PTR [rsp+0x38]
    498b:	mov    r13,QWORD PTR [rsp+0x40]
    4990:	mov    r14,QWORD PTR [rsp+0x48]
    4995:	mov    r15,QWORD PTR [rsp+0x50]
    499a:	add    rsp,0x60
    499e:	mov    rsp,rbp
    49a1:	pop    rbp
    49a2:	ret
    49a3:	mov    eax,0xa
    49a8:	mov    rbx,QWORD PTR [rsp+0x30]
    49ad:	mov    r12,QWORD PTR [rsp+0x38]
    49b2:	mov    r13,QWORD PTR [rsp+0x40]
    49b7:	mov    r14,QWORD PTR [rsp+0x48]
    49bc:	mov    r15,QWORD PTR [rsp+0x50]
    49c1:	add    rsp,0x60
    49c5:	mov    rsp,rbp
    49c8:	pop    rbp
    49c9:	ret
    49ca:	add    BYTE PTR [rax],al
    49cc:	add    BYTE PTR [rax],al
    49ce:	add    BYTE PTR [rax],al
    49d0:	(bad)
    49d1:	add    BYTE PTR [rax],al
    49d3:	add    BYTE PTR [rax],al
    49d5:	add    BYTE PTR [rax],al
	...

00000000000049d8 <botlish_entry_48: ht_set<mutarray, any, any>>:
    49d8:	push   rbp
    49d9:	mov    rbp,rsp
    49dc:	mov    rsi,QWORD PTR [rdx]
    49df:	mov    r8,QWORD PTR [rdx+0x8]
    49e3:	mov    rcx,QWORD PTR [rdx+0x10]
    49e7:	mov    rdx,r8
    49ea:	call   49ef <botlish_entry_48+0x17>
			49eb: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_set<mutarray, any, any>
    49ef:	mov    rsp,rbp
    49f2:	pop    rbp
    49f3:	ret

00000000000049f4 <botlish_fn_49: row_new<bool, int>>:
    49f4:	push   rbp
    49f5:	mov    rbp,rsp
    49f8:	sub    rsp,0x10
    49fc:	mov    QWORD PTR [rsp],rdx
    4a00:	mov    r8,rdx
    4a03:	cmp    rsi,0x6
    4a07:	je     4a24 <botlish_fn_49+0x30>
    4a0d:	call   4a12 <botlish_fn_49+0x1e>
			4a0e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    4a12:	test   rax,rax
    4a15:	je     4a35 <botlish_fn_49+0x41>
    4a1b:	add    rsp,0x10
    4a1f:	mov    rsp,rbp
    4a22:	pop    rbp
    4a23:	ret
    4a24:	mov    rsi,r8
    4a27:	call   4a2c <botlish_fn_49+0x38>
			4a28: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    4a2c:	test   rax,rax
    4a2f:	jne    4a41 <botlish_fn_49+0x4d>
    4a35:	xor    rax,rax
    4a38:	add    rsp,0x10
    4a3c:	mov    rsp,rbp
    4a3f:	pop    rbp
    4a40:	ret
    4a41:	add    rsp,0x10
    4a45:	mov    rsp,rbp
    4a48:	pop    rbp
    4a49:	ret

0000000000004a4a <botlish_entry_49: row_new<bool, int>>:
    4a4a:	push   rbp
    4a4b:	mov    rbp,rsp
    4a4e:	mov    rsi,QWORD PTR [rdx]
    4a51:	mov    rdx,QWORD PTR [rdx+0x8]
    4a55:	call   4a5a <botlish_entry_49+0x10>
			4a56: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_new<bool, int>
    4a5a:	mov    rsp,rbp
    4a5d:	pop    rbp
    4a5e:	ret

0000000000004a5f <botlish_fn_50: row_fill<mutarray, list, any, int, int>>:
    4a5f:	push   rbp
    4a60:	mov    rbp,rsp
    4a63:	sub    rsp,0x70
    4a67:	mov    QWORD PTR [rsp+0x40],rbx
    4a6c:	mov    QWORD PTR [rsp+0x48],r12
    4a71:	mov    QWORD PTR [rsp+0x50],r13
    4a76:	mov    QWORD PTR [rsp+0x58],r14
    4a7b:	mov    QWORD PTR [rsp+0x60],r15
    4a80:	mov    QWORD PTR [rsp+0x28],rdi
    4a85:	mov    QWORD PTR [rsp],rsi
    4a89:	mov    r13,rsi
    4a8c:	mov    QWORD PTR [rsp+0x8],rdx
    4a91:	mov    QWORD PTR [rsp+0x10],rcx
    4a96:	mov    r15,rcx
    4a99:	sar    r8,1
    4a9c:	mov    r14,r8
    4a9f:	sar    r9,1
    4aa2:	mov    rbx,r9
    4aa5:	cmp    r14,rbx
    4aa8:	jge    4c09 <botlish_fn_50+0x1aa>
    4aae:	mov    r12,rdx
    4ab1:	mov    rdx,QWORD PTR [r12+0x8]
    4ab6:	mov    rcx,r14
    4ab9:	shl    rcx,1
    4abc:	or     rcx,0x1
    4ac0:	sar    rcx,1
    4ac3:	cmp    rcx,rdx
    4ac6:	jb     4af4 <botlish_fn_50+0x95>
    4acc:	mov    rdx,r14
    4acf:	shl    rdx,1
    4ad2:	or     rdx,0x1
    4ad6:	mov    rsi,r12
    4ad9:	mov    rdi,QWORD PTR [rsp+0x28]
    4ade:	call   4ae3 <botlish_fn_50+0x84>
			4adf: R_X86_64_PLT32	rt_list_get-0x4
    4ae3:	test   rax,rax
    4ae6:	je     4bc4 <botlish_fn_50+0x165>
    4aec:	mov    rdx,rax
    4aef:	jmp    4afd <botlish_fn_50+0x9e>
    4af4:	mov    rax,QWORD PTR [r12+0x10]
    4af9:	mov    rdx,QWORD PTR [rax+rcx*8]
    4afd:	mov    QWORD PTR [rsp+0x18],rdx
    4b02:	mov    QWORD PTR [rsp+0x30],rdx
    4b07:	xor    ecx,ecx
    4b09:	mov    rdx,r15
    4b0c:	test   rdx,0x7
    4b13:	je     4b21 <botlish_fn_50+0xc2>
    4b19:	mov    r15,rdx
    4b1c:	jmp    4b2d <botlish_fn_50+0xce>
    4b21:	movzx  rax,BYTE PTR [rdx]
    4b25:	mov    r15,rdx
    4b28:	cmp    al,0x3
    4b2a:	sete   cl
    4b2d:	test   cl,cl
    4b2f:	jne    4b54 <botlish_fn_50+0xf5>
    4b35:	mov    rdi,QWORD PTR [rsp+0x28]
    4b3a:	mov    rsi,QWORD PTR [rdi+0x10]
    4b3e:	mov    rcx,QWORD PTR [rsi+0x50]
    4b42:	mov    edx,0x4
    4b47:	mov    rsi,r15
    4b4a:	call   4b4f <botlish_fn_50+0xf0>
			4b4b: R_X86_64_PLT32	rt_type_error-0x4
    4b4f:	jmp    4bc4 <botlish_fn_50+0x165>
    4b54:	mov    rsi,r15
    4b57:	mov    rdi,QWORD PTR [rsi+0x8]
    4b5b:	mov    rsi,r14
    4b5e:	shl    rsi,1
    4b61:	or     rsi,0x1
    4b65:	sar    rsi,1
    4b68:	cmp    rsi,rdi
    4b6b:	jb     4b99 <botlish_fn_50+0x13a>
    4b71:	mov    rdx,r14
    4b74:	shl    rdx,1
    4b77:	or     rdx,0x1
    4b7b:	mov    rsi,r15
    4b7e:	mov    rdi,QWORD PTR [rsp+0x28]
    4b83:	call   4b88 <botlish_fn_50+0x129>
			4b84: R_X86_64_PLT32	rt_list_get-0x4
    4b88:	test   rax,rax
    4b8b:	je     4bc4 <botlish_fn_50+0x165>
    4b91:	mov    rcx,rax
    4b94:	jmp    4ba4 <botlish_fn_50+0x145>
    4b99:	mov    rax,r15
    4b9c:	mov    r11,QWORD PTR [rax+0x10]
    4ba0:	mov    rcx,QWORD PTR [r11+rsi*8]
    4ba4:	mov    QWORD PTR [rsp+0x20],rcx
    4ba9:	mov    rdx,QWORD PTR [rsp+0x30]
    4bae:	mov    rsi,r13
    4bb1:	mov    rdi,QWORD PTR [rsp+0x28]
    4bb6:	call   4bbb <botlish_fn_50+0x15c>
			4bb7: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_set<mutarray, any, any>
    4bbb:	test   rax,rax
    4bbe:	jne    4be9 <botlish_fn_50+0x18a>
    4bc4:	xor    rax,rax
    4bc7:	mov    rbx,QWORD PTR [rsp+0x40]
    4bcc:	mov    r12,QWORD PTR [rsp+0x48]
    4bd1:	mov    r13,QWORD PTR [rsp+0x50]
    4bd6:	mov    r14,QWORD PTR [rsp+0x58]
    4bdb:	mov    r15,QWORD PTR [rsp+0x60]
    4be0:	add    rsp,0x70
    4be4:	mov    rsp,rbp
    4be7:	pop    rbp
    4be8:	ret
    4be9:	mov    QWORD PTR [rsp],r13
    4bed:	mov    QWORD PTR [rsp+0x8],r12
    4bf2:	mov    rsi,r15
    4bf5:	mov    QWORD PTR [rsp+0x10],rsi
    4bfa:	add    r14,0x1
    4c01:	mov    rdx,r12
    4c04:	jmp    4aa5 <botlish_fn_50+0x46>
    4c09:	mov    rax,r13
    4c0c:	mov    rbx,QWORD PTR [rsp+0x40]
    4c11:	mov    r12,QWORD PTR [rsp+0x48]
    4c16:	mov    r13,QWORD PTR [rsp+0x50]
    4c1b:	mov    r14,QWORD PTR [rsp+0x58]
    4c20:	mov    r15,QWORD PTR [rsp+0x60]
    4c25:	add    rsp,0x70
    4c29:	mov    rsp,rbp
    4c2c:	pop    rbp
    4c2d:	ret

0000000000004c2e <botlish_entry_50: row_fill<mutarray, list, any, int, int>>:
    4c2e:	push   rbp
    4c2f:	mov    rbp,rsp
    4c32:	mov    rsi,QWORD PTR [rdx]
    4c35:	mov    r10,QWORD PTR [rdx+0x8]
    4c39:	mov    rcx,QWORD PTR [rdx+0x10]
    4c3d:	mov    r8,QWORD PTR [rdx+0x18]
    4c41:	mov    r9,QWORD PTR [rdx+0x20]
    4c45:	mov    rdx,r10
    4c48:	call   4c4d <botlish_entry_50+0x1f>
			4c49: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_fill<mutarray, list, any, int, int>
    4c4d:	mov    rsp,rbp
    4c50:	pop    rbp
    4c51:	ret

0000000000004c52 <botlish_fn_51: row_table<list, int, any, bool>>:
    4c52:	push   rbp
    4c53:	mov    rbp,rsp
    4c56:	sub    rsp,0x50
    4c5a:	mov    QWORD PTR [rsp+0x30],rbx
    4c5f:	mov    QWORD PTR [rsp+0x38],r12
    4c64:	mov    QWORD PTR [rsp+0x40],r13
    4c69:	mov    QWORD PTR [rsp+0x48],r14
    4c6e:	mov    r12,rdi
    4c71:	mov    QWORD PTR [rsp+0x20],0x0
    4c7a:	mov    QWORD PTR [rsp],rsi
    4c7e:	mov    r13,rsi
    4c81:	mov    QWORD PTR [rsp+0x8],rdx
    4c86:	mov    QWORD PTR [rsp+0x10],rcx
    4c8b:	mov    rbx,rcx
    4c8e:	mov    QWORD PTR [rsp+0x18],r8
    4c93:	mov    rsi,r8
    4c96:	mov    rdi,r12
    4c99:	call   4c9e <botlish_fn_51+0x4c>
			4c9a: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_new<bool, int>
    4c9e:	test   rax,rax
    4ca1:	je     4d36 <botlish_fn_51+0xe4>
    4ca7:	mov    QWORD PTR [rsp+0x8],rax
    4cac:	mov    r14,rax
    4caf:	mov    QWORD PTR [rsp+0x18],0x1
    4cb8:	xor    eax,eax
    4cba:	mov    rcx,rbx
    4cbd:	test   rcx,0x7
    4cc4:	je     4cd2 <botlish_fn_51+0x80>
    4cca:	mov    rbx,rcx
    4ccd:	jmp    4cde <botlish_fn_51+0x8c>
    4cd2:	movzx  rax,BYTE PTR [rcx]
    4cd6:	mov    rbx,rcx
    4cd9:	cmp    al,0x3
    4cdb:	sete   al
    4cde:	test   al,al
    4ce0:	jne    4d03 <botlish_fn_51+0xb1>
    4ce6:	mov    rdi,r12
    4ce9:	mov    rax,QWORD PTR [rdi+0x10]
    4ced:	mov    rcx,QWORD PTR [rax+0x58]
    4cf1:	mov    edx,0x4
    4cf6:	mov    rsi,rbx
    4cf9:	call   4cfe <botlish_fn_51+0xac>
			4cfa: R_X86_64_PLT32	rt_type_error-0x4
    4cfe:	jmp    4d36 <botlish_fn_51+0xe4>
    4d03:	mov    rsi,rbx
    4d06:	mov    rdi,r12
    4d09:	call   4d0e <botlish_fn_51+0xbc>
			4d0a: R_X86_64_PLT32	rt_list_len-0x4
    4d0e:	mov    QWORD PTR [rsp+0x20],rax
    4d13:	mov    r8d,0x1
    4d19:	mov    rcx,rbx
    4d1c:	mov    rdx,r13
    4d1f:	mov    rsi,r14
    4d22:	mov    rdi,r12
    4d25:	mov    r9,rax
    4d28:	call   4d2d <botlish_fn_51+0xdb>
			4d29: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_fill<mutarray, list, any, int, int>
    4d2d:	test   rax,rax
    4d30:	jne    4d56 <botlish_fn_51+0x104>
    4d36:	xor    rax,rax
    4d39:	mov    rbx,QWORD PTR [rsp+0x30]
    4d3e:	mov    r12,QWORD PTR [rsp+0x38]
    4d43:	mov    r13,QWORD PTR [rsp+0x40]
    4d48:	mov    r14,QWORD PTR [rsp+0x48]
    4d4d:	add    rsp,0x50
    4d51:	mov    rsp,rbp
    4d54:	pop    rbp
    4d55:	ret
    4d56:	mov    rbx,QWORD PTR [rsp+0x30]
    4d5b:	mov    r12,QWORD PTR [rsp+0x38]
    4d60:	mov    r13,QWORD PTR [rsp+0x40]
    4d65:	mov    r14,QWORD PTR [rsp+0x48]
    4d6a:	add    rsp,0x50
    4d6e:	mov    rsp,rbp
    4d71:	pop    rbp
    4d72:	ret

0000000000004d73 <botlish_entry_51: row_table<list, int, any, bool>>:
    4d73:	push   rbp
    4d74:	mov    rbp,rsp
    4d77:	mov    rsi,QWORD PTR [rdx]
    4d7a:	mov    r9,QWORD PTR [rdx+0x8]
    4d7e:	mov    rcx,QWORD PTR [rdx+0x10]
    4d82:	mov    r8,QWORD PTR [rdx+0x18]
    4d86:	mov    rdx,r9
    4d89:	call   4d8e <botlish_entry_51+0x1b>
			4d8a: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_table<list, int, any, bool>
    4d8e:	mov    rsp,rbp
    4d91:	pop    rbp
    4d92:	ret

0000000000004d93 <botlish_fn_52: build_rows<list, int, list, int, mutarray, int, bool>>:
    4d93:	push   rbp
    4d94:	mov    rbp,rsp
    4d97:	sub    rsp,0x90
    4d9e:	mov    QWORD PTR [rsp+0x60],rbx
    4da3:	mov    QWORD PTR [rsp+0x68],r12
    4da8:	mov    QWORD PTR [rsp+0x70],r13
    4dad:	mov    QWORD PTR [rsp+0x78],r14
    4db2:	mov    QWORD PTR [rsp+0x80],r15
    4dba:	mov    r13,r8
    4dbd:	mov    QWORD PTR [rsp+0x38],rdi
    4dc2:	mov    rdi,QWORD PTR [rbp+0x10]
    4dc6:	mov    r15,QWORD PTR [rbp+0x18]
    4dca:	mov    QWORD PTR [rsp+0x28],0x0
    4dd3:	mov    QWORD PTR [rsp+0x30],0x0
    4ddc:	mov    QWORD PTR [rsp],rsi
    4de0:	mov    QWORD PTR [rsp+0x8],rcx
    4de5:	mov    r14,rcx
    4de8:	mov    QWORD PTR [rsp+0x10],r9
    4ded:	mov    QWORD PTR [rsp+0x18],rdi
    4df2:	mov    QWORD PTR [rsp+0x20],r15
    4df7:	sar    rdx,1
    4dfa:	mov    r12,rdx
    4dfd:	mov    rbx,rsi
    4e00:	mov    QWORD PTR [rsp+0x40],r9
    4e05:	mov    QWORD PTR [rsp+0x48],rdi
    4e0a:	mov    rsi,rbx
    4e0d:	mov    rdi,QWORD PTR [rsp+0x38]
    4e12:	call   4e17 <botlish_fn_52+0x84>
			4e13: R_X86_64_PLT32	rt_list_len-0x4
    4e17:	sar    rax,1
    4e1a:	cmp    r12,rax
    4e1d:	jge    4f48 <botlish_fn_52+0x1b5>
    4e23:	mov    rax,r13
    4e26:	or     rax,0x1
    4e2a:	mov    QWORD PTR [rsp+0x28],rax
    4e2f:	mov    rcx,QWORD PTR [rbx+0x8]
    4e33:	mov    rax,r12
    4e36:	shl    rax,1
    4e39:	or     rax,0x1
    4e3d:	sar    rax,1
    4e40:	cmp    rax,rcx
    4e43:	jb     4e71 <botlish_fn_52+0xde>
    4e49:	mov    rdx,r12
    4e4c:	shl    rdx,1
    4e4f:	or     rdx,0x1
    4e53:	mov    rsi,rbx
    4e56:	mov    rdi,QWORD PTR [rsp+0x38]
    4e5b:	call   4e60 <botlish_fn_52+0xcd>
			4e5c: R_X86_64_PLT32	rt_list_get-0x4
    4e60:	test   rax,rax
    4e63:	je     4f65 <botlish_fn_52+0x1d2>
    4e69:	mov    rcx,rax
    4e6c:	jmp    4e79 <botlish_fn_52+0xe6>
    4e71:	mov    rcx,QWORD PTR [rbx+0x10]
    4e75:	mov    rcx,QWORD PTR [rcx+rax*8]
    4e79:	mov    QWORD PTR [rsp+0x30],rcx
    4e7e:	mov    rdx,r13
    4e81:	or     rdx,0x1
    4e85:	mov    rsi,r14
    4e88:	mov    rdi,QWORD PTR [rsp+0x38]
    4e8d:	mov    r8,r15
    4e90:	call   4e95 <botlish_fn_52+0x102>
			4e91: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_table<list, int, any, bool>
    4e95:	test   rax,rax
    4e98:	je     4f65 <botlish_fn_52+0x1d2>
    4e9e:	mov    QWORD PTR [rsp+0x28],rax
    4ea3:	mov    rcx,rax
    4ea6:	mov    rsi,QWORD PTR [rsp+0x40]
    4eab:	mov    rdx,QWORD PTR [rsp+0x48]
    4eb0:	mov    rdi,QWORD PTR [rsp+0x38]
    4eb5:	call   4eba <botlish_fn_52+0x127>
			4eb6: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4eba:	test   rax,rax
    4ebd:	je     4f65 <botlish_fn_52+0x1d2>
    4ec3:	mov    QWORD PTR [rsp+0x10],rax
    4ec8:	mov    QWORD PTR [rsp+0x50],rax
    4ecd:	mov    QWORD PTR [rsp+0x28],0x3
    4ed6:	mov    rsi,QWORD PTR [rsp+0x48]
    4edb:	test   rsi,0x1
    4ee2:	je     4f01 <botlish_fn_52+0x16e>
    4ee8:	mov    rsi,QWORD PTR [rsp+0x48]
    4eed:	mov    rax,rsi
    4ef0:	add    rax,0x2
    4ef4:	seto   r10b
    4ef8:	test   r10b,r10b
    4efb:	je     4f15 <botlish_fn_52+0x182>
    4f01:	mov    edx,0x3
    4f06:	mov    rsi,QWORD PTR [rsp+0x48]
    4f0b:	mov    rdi,QWORD PTR [rsp+0x38]
    4f10:	call   4f15 <botlish_fn_52+0x182>
			4f11: R_X86_64_PLT32	rt_int_add-0x4
    4f15:	mov    QWORD PTR [rsp],rbx
    4f19:	mov    QWORD PTR [rsp+0x8],r14
    4f1e:	mov    rcx,QWORD PTR [rsp+0x50]
    4f23:	mov    QWORD PTR [rsp+0x10],rcx
    4f28:	mov    QWORD PTR [rsp+0x18],rax
    4f2d:	mov    QWORD PTR [rsp+0x20],r15
    4f32:	add    r12,0x1
    4f39:	mov    QWORD PTR [rsp+0x40],rcx
    4f3e:	mov    QWORD PTR [rsp+0x48],rax
    4f43:	jmp    4e0a <botlish_fn_52+0x77>
    4f48:	mov    rdx,QWORD PTR [rsp+0x48]
    4f4d:	mov    rsi,QWORD PTR [rsp+0x40]
    4f52:	mov    rdi,QWORD PTR [rsp+0x38]
    4f57:	call   4f5c <botlish_fn_52+0x1c9>
			4f58: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4f5c:	test   rax,rax
    4f5f:	jne    4f90 <botlish_fn_52+0x1fd>
    4f65:	xor    rax,rax
    4f68:	mov    rbx,QWORD PTR [rsp+0x60]
    4f6d:	mov    r12,QWORD PTR [rsp+0x68]
    4f72:	mov    r13,QWORD PTR [rsp+0x70]
    4f77:	mov    r14,QWORD PTR [rsp+0x78]
    4f7c:	mov    r15,QWORD PTR [rsp+0x80]
    4f84:	add    rsp,0x90
    4f8b:	mov    rsp,rbp
    4f8e:	pop    rbp
    4f8f:	ret
    4f90:	mov    rbx,QWORD PTR [rsp+0x60]
    4f95:	mov    r12,QWORD PTR [rsp+0x68]
    4f9a:	mov    r13,QWORD PTR [rsp+0x70]
    4f9f:	mov    r14,QWORD PTR [rsp+0x78]
    4fa4:	mov    r15,QWORD PTR [rsp+0x80]
    4fac:	add    rsp,0x90
    4fb3:	mov    rsp,rbp
    4fb6:	pop    rbp
    4fb7:	ret

0000000000004fb8 <botlish_entry_52: build_rows<list, int, list, int, mutarray, int, bool>>:
    4fb8:	push   rbp
    4fb9:	mov    rbp,rsp
    4fbc:	sub    rsp,0x10
    4fc0:	mov    rsi,QWORD PTR [rdx]
    4fc3:	mov    r10,QWORD PTR [rdx+0x8]
    4fc7:	mov    rcx,QWORD PTR [rdx+0x10]
    4fcb:	mov    r8,QWORD PTR [rdx+0x18]
    4fcf:	mov    r9,QWORD PTR [rdx+0x20]
    4fd3:	mov    r11,QWORD PTR [rdx+0x28]
    4fd7:	mov    rax,QWORD PTR [rdx+0x30]
    4fdb:	mov    QWORD PTR [rsp],r11
    4fdf:	mov    QWORD PTR [rsp+0x8],rax
    4fe4:	mov    rdx,r10
    4fe7:	call   4fec <botlish_entry_52+0x34>
			4fe8: R_X86_64_PLT32	botlish_fn_52-0x4 ; build_rows<list, int, list, int, mutarray, int, bool>
    4fec:	add    rsp,0x10
    4ff0:	mov    rsp,rbp
    4ff3:	pop    rbp
    4ff4:	ret

0000000000004ff5 <botlish_fn_53: csv_records_generic<str, bool>>:
    4ff5:	push   rbp
    4ff6:	mov    rbp,rsp
    4ff9:	sub    rsp,0x80
    5000:	mov    QWORD PTR [rsp+0x50],rbx
    5005:	mov    QWORD PTR [rsp+0x58],r12
    500a:	mov    QWORD PTR [rsp+0x60],r13
    500f:	mov    QWORD PTR [rsp+0x68],r14
    5014:	mov    QWORD PTR [rsp+0x70],r15
    5019:	mov    r13,rdi
    501c:	mov    QWORD PTR [rsp+0x20],0x0
    5025:	mov    QWORD PTR [rsp+0x28],0x0
    502e:	mov    QWORD PTR [rsp+0x30],0x0
    5037:	mov    QWORD PTR [rsp+0x38],0x0
    5040:	mov    QWORD PTR [rsp+0x40],0x0
    5049:	mov    QWORD PTR [rsp+0x10],rsi
    504e:	mov    QWORD PTR [rsp+0x18],rdx
    5053:	mov    r14,rdx
    5056:	mov    rdi,r13
    5059:	call   505e <botlish_fn_53+0x69>
			505a: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    505e:	mov    r9,rax
    5061:	mov    r15,rax
    5064:	test   rax,r9
    5067:	je     5226 <botlish_fn_53+0x231>
    506d:	mov    rax,r15
    5070:	mov    QWORD PTR [rsp+0x10],rax
    5075:	mov    rsi,r15
    5078:	mov    rdi,r13
    507b:	call   5080 <botlish_fn_53+0x8b>
			507c: R_X86_64_PLT32	rt_list_len-0x4
    5080:	sar    rax,1
    5083:	cmp    rax,0x1
    5087:	jle    520f <botlish_fn_53+0x21a>
    508d:	mov    rax,r15
    5090:	mov    rax,QWORD PTR [rax+0x8]
    5094:	test   rax,rax
    5097:	jne    50c1 <botlish_fn_53+0xcc>
    509d:	mov    edx,0x1
    50a2:	mov    rsi,r15
    50a5:	mov    rdi,r13
    50a8:	call   50ad <botlish_fn_53+0xb8>
			50a9: R_X86_64_PLT32	rt_list_get-0x4
    50ad:	test   rax,rax
    50b0:	je     5226 <botlish_fn_53+0x231>
    50b6:	mov    rsi,rax
    50b9:	mov    r12,r15
    50bc:	jmp    50cc <botlish_fn_53+0xd7>
    50c1:	mov    r12,r15
    50c4:	mov    rax,QWORD PTR [r12+0x10]
    50c9:	mov    rsi,QWORD PTR [rax]
    50cc:	mov    QWORD PTR [rsp+0x20],rsi
    50d1:	xor    ecx,ecx
    50d3:	test   rsi,0x7
    50da:	jne    50eb <botlish_fn_53+0xf6>
    50e0:	movzx  rdi,BYTE PTR [rsi]
    50e4:	cmp    dil,0x3
    50e8:	sete   cl
    50eb:	test   cl,cl
    50ed:	jne    5110 <botlish_fn_53+0x11b>
    50f3:	mov    rdi,r13
    50f6:	mov    rdi,QWORD PTR [rdi+0x10]
    50fa:	mov    rcx,QWORD PTR [rdi+0x58]
    50fe:	mov    edx,0x4
    5103:	mov    rdi,r13
    5106:	call   510b <botlish_fn_53+0x116>
			5107: R_X86_64_PLT32	rt_type_error-0x4
    510b:	jmp    5226 <botlish_fn_53+0x231>
    5110:	mov    QWORD PTR [rsp+0x48],rsi
    5115:	mov    rdi,r13
    5118:	call   511d <botlish_fn_53+0x128>
			5119: R_X86_64_PLT32	rt_list_len-0x4
    511d:	mov    rbx,rax
    5120:	mov    QWORD PTR [rsp+0x28],rbx
    5125:	mov    r10,QWORD PTR [r12+0x8]
    512a:	cmp    r10,0x1
    512e:	ja     5158 <botlish_fn_53+0x163>
    5134:	mov    edx,0x3
    5139:	mov    rsi,r12
    513c:	mov    rdi,r13
    513f:	call   5144 <botlish_fn_53+0x14f>
			5140: R_X86_64_PLT32	rt_list_get-0x4
    5144:	test   rax,rax
    5147:	je     5226 <botlish_fn_53+0x231>
    514d:	mov    rcx,rax
    5150:	mov    r15,r12
    5153:	jmp    5164 <botlish_fn_53+0x16f>
    5158:	mov    rax,QWORD PTR [r12+0x10]
    515d:	mov    r15,r12
    5160:	mov    rcx,QWORD PTR [rax+0x8]
    5164:	mov    QWORD PTR [rsp+0x30],rcx
    5169:	mov    r12,r14
    516c:	mov    rdx,rbx
    516f:	mov    rsi,QWORD PTR [rsp+0x48]
    5174:	mov    rdi,r13
    5177:	mov    r8,r12
    517a:	call   517f <botlish_fn_53+0x18a>
			517b: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_table<list, int, any, bool>
    517f:	test   rax,rax
    5182:	je     5226 <botlish_fn_53+0x231>
    5188:	mov    QWORD PTR [rsp+0x30],rax
    518d:	mov    rsi,rax
    5190:	mov    QWORD PTR [rsp+0x38],0x5
    5199:	mov    rdi,r13
    519c:	call   51a1 <botlish_fn_53+0x1ac>
			519d: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    51a1:	test   rax,rax
    51a4:	je     5226 <botlish_fn_53+0x231>
    51aa:	mov    QWORD PTR [rsp+0x30],rax
    51af:	mov    r9,rax
    51b2:	mov    eax,0x3
    51b7:	mov    QWORD PTR [rsp+0x40],0x3
    51c0:	mov    edx,0x5
    51c5:	mov    QWORD PTR [rsp],rax
    51c9:	mov    QWORD PTR [rsp+0x8],r12
    51ce:	mov    rcx,QWORD PTR [rsp+0x48]
    51d3:	mov    rsi,r15
    51d6:	mov    rdi,r13
    51d9:	mov    r8,rbx
    51dc:	call   51e1 <botlish_fn_53+0x1ec>
			51dd: R_X86_64_PLT32	botlish_fn_52-0x4 ; build_rows<list, int, list, int, mutarray, int, bool>
    51e1:	test   rax,rax
    51e4:	je     5226 <botlish_fn_53+0x231>
    51ea:	mov    rbx,QWORD PTR [rsp+0x50]
    51ef:	mov    r12,QWORD PTR [rsp+0x58]
    51f4:	mov    r13,QWORD PTR [rsp+0x60]
    51f9:	mov    r14,QWORD PTR [rsp+0x68]
    51fe:	mov    r15,QWORD PTR [rsp+0x70]
    5203:	add    rsp,0x80
    520a:	mov    rsp,rbp
    520d:	pop    rbp
    520e:	ret
    520f:	xor    rdx,rdx
    5212:	mov    rdi,r13
    5215:	mov    rsi,rdx
    5218:	call   521d <botlish_fn_53+0x228>
			5219: R_X86_64_PLT32	rt_list_new-0x4
    521d:	test   rax,rax
    5220:	jne    524e <botlish_fn_53+0x259>
    5226:	xor    rax,rax
    5229:	mov    rbx,QWORD PTR [rsp+0x50]
    522e:	mov    r12,QWORD PTR [rsp+0x58]
    5233:	mov    r13,QWORD PTR [rsp+0x60]
    5238:	mov    r14,QWORD PTR [rsp+0x68]
    523d:	mov    r15,QWORD PTR [rsp+0x70]
    5242:	add    rsp,0x80
    5249:	mov    rsp,rbp
    524c:	pop    rbp
    524d:	ret
    524e:	mov    rbx,QWORD PTR [rsp+0x50]
    5253:	mov    r12,QWORD PTR [rsp+0x58]
    5258:	mov    r13,QWORD PTR [rsp+0x60]
    525d:	mov    r14,QWORD PTR [rsp+0x68]
    5262:	mov    r15,QWORD PTR [rsp+0x70]
    5267:	add    rsp,0x80
    526e:	mov    rsp,rbp
    5271:	pop    rbp
    5272:	ret

0000000000005273 <botlish_entry_53: csv_records_generic<str, bool>>:
    5273:	push   rbp
    5274:	mov    rbp,rsp
    5277:	mov    rsi,QWORD PTR [rdx]
    527a:	mov    rdx,QWORD PTR [rdx+0x8]
    527e:	call   5283 <botlish_entry_53+0x10>
			527f: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_generic<str, bool>
    5283:	mov    rsp,rbp
    5286:	pop    rbp
    5287:	ret

0000000000005288 <botlish_fn_54: csv_records<str>>:
    5288:	push   rbp
    5289:	mov    rbp,rsp
    528c:	sub    rsp,0x10
    5290:	mov    QWORD PTR [rsp],rsi
    5294:	mov    edx,0x2
    5299:	mov    QWORD PTR [rsp+0x8],0x2
    52a2:	call   52a7 <botlish_fn_54+0x1f>
			52a3: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_generic<str, bool>
    52a7:	test   rax,rax
    52aa:	jne    52bc <botlish_fn_54+0x34>
    52b0:	xor    rax,rax
    52b3:	add    rsp,0x10
    52b7:	mov    rsp,rbp
    52ba:	pop    rbp
    52bb:	ret
    52bc:	add    rsp,0x10
    52c0:	mov    rsp,rbp
    52c3:	pop    rbp
    52c4:	ret

00000000000052c5 <botlish_entry_54: csv_records<str>>:
    52c5:	push   rbp
    52c6:	mov    rbp,rsp
    52c9:	mov    rsi,QWORD PTR [rdx]
    52cc:	call   52d1 <botlish_entry_54+0xc>
			52cd: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records<str>
    52d1:	mov    rsp,rbp
    52d4:	pop    rbp
    52d5:	ret

00000000000052d6 <botlish_fn_55: csv_records_presized<str>>:
    52d6:	push   rbp
    52d7:	mov    rbp,rsp
    52da:	sub    rsp,0x10
    52de:	mov    QWORD PTR [rsp],rsi
    52e2:	mov    edx,0x6
    52e7:	mov    QWORD PTR [rsp+0x8],0x6
    52f0:	call   52f5 <botlish_fn_55+0x1f>
			52f1: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records_generic<str, bool>
    52f5:	test   rax,rax
    52f8:	jne    530a <botlish_fn_55+0x34>
    52fe:	xor    rax,rax
    5301:	add    rsp,0x10
    5305:	mov    rsp,rbp
    5308:	pop    rbp
    5309:	ret
    530a:	add    rsp,0x10
    530e:	mov    rsp,rbp
    5311:	pop    rbp
    5312:	ret

0000000000005313 <botlish_entry_55: csv_records_presized<str>>:
    5313:	push   rbp
    5314:	mov    rbp,rsp
    5317:	mov    rsi,QWORD PTR [rdx]
    531a:	call   531f <botlish_entry_55+0xc>
			531b: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_presized<str>
    531f:	mov    rsp,rbp
    5322:	pop    rbp
    5323:	ret
    5324:	add    BYTE PTR [rax],al
	...

0000000000005328 <botlish_fn_56: sample<generic>>:
    5328:	push   rbp
    5329:	mov    rbp,rsp
    532c:	sub    rsp,0xc0
    5333:	mov    QWORD PTR [rsp+0x90],rbx
    533b:	mov    QWORD PTR [rsp+0x98],r12
    5343:	mov    QWORD PTR [rsp+0xa0],r13
    534b:	mov    QWORD PTR [rsp+0xa8],r14
    5353:	mov    QWORD PTR [rsp+0xb0],r15
    535b:	mov    QWORD PTR [rsp+0x8],0x0
    5364:	mov    QWORD PTR [rsp+0x10],0x0
    536d:	mov    QWORD PTR [rsp+0x18],0x0
    5376:	mov    QWORD PTR [rsp+0x20],0x0
    537f:	mov    QWORD PTR [rsp+0x28],0x0
    5388:	mov    QWORD PTR [rsp+0x30],0x0
    5391:	mov    QWORD PTR [rsp+0x38],0x0
    539a:	mov    rax,QWORD PTR [rdi+0x10]
    539e:	mov    r13,rdi
    53a1:	mov    rsi,QWORD PTR [rax+0x60]
    53a5:	mov    QWORD PTR [rsp],rsi
    53a9:	call   53ae <botlish_fn_56+0x86>
			53aa: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records<str>
    53ae:	mov    rsi,rax
    53b1:	mov    r12,rax
    53b4:	test   rax,rsi
    53b7:	je     573c <botlish_fn_56+0x414>
    53bd:	mov    rax,r12
    53c0:	mov    QWORD PTR [rsp],rax
    53c4:	mov    rdi,r13
    53c7:	mov    rax,QWORD PTR [rdi+0x10]
    53cb:	mov    rsi,QWORD PTR [rax+0x60]
    53cf:	mov    QWORD PTR [rsp+0x8],rsi
    53d4:	call   53d9 <botlish_fn_56+0xb1>
			53d5: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_presized<str>
    53d9:	mov    rbx,rax
    53dc:	test   rbx,rbx
    53df:	je     573c <botlish_fn_56+0x414>
    53e5:	mov    rax,r12
    53e8:	mov    rax,QWORD PTR [rax+0x8]
    53ec:	test   rax,rax
    53ef:	jne    5416 <botlish_fn_56+0xee>
    53f5:	mov    edx,0x1
    53fa:	mov    rsi,r12
    53fd:	mov    rdi,r13
    5400:	call   5405 <botlish_fn_56+0xdd>
			5401: R_X86_64_PLT32	rt_list_get-0x4
    5405:	test   rax,rax
    5408:	je     573c <botlish_fn_56+0x414>
    540e:	mov    rsi,rax
    5411:	jmp    541e <botlish_fn_56+0xf6>
    5416:	mov    rax,QWORD PTR [r12+0x10]
    541b:	mov    rsi,QWORD PTR [rax]
    541e:	mov    QWORD PTR [rsp+0x8],rsi
    5423:	mov    r15,rsi
    5426:	mov    rax,QWORD PTR [r12+0x8]
    542b:	cmp    rax,0x1
    542f:	ja     5456 <botlish_fn_56+0x12e>
    5435:	mov    edx,0x3
    543a:	mov    rsi,r12
    543d:	mov    rdi,r13
    5440:	call   5445 <botlish_fn_56+0x11d>
			5441: R_X86_64_PLT32	rt_list_get-0x4
    5445:	test   rax,rax
    5448:	je     573c <botlish_fn_56+0x414>
    544e:	mov    rsi,rax
    5451:	jmp    545f <botlish_fn_56+0x137>
    5456:	mov    rax,QWORD PTR [r12+0x10]
    545b:	mov    rsi,QWORD PTR [rax+0x8]
    545f:	mov    QWORD PTR [rsp+0x10],rsi
    5464:	mov    r14,rsi
    5467:	mov    rax,QWORD PTR [rbx+0x8]
    546b:	mov    rsi,rbx
    546e:	test   rax,rax
    5471:	jne    5495 <botlish_fn_56+0x16d>
    5477:	mov    edx,0x1
    547c:	mov    rdi,r13
    547f:	call   5484 <botlish_fn_56+0x15c>
			5480: R_X86_64_PLT32	rt_list_get-0x4
    5484:	test   rax,rax
    5487:	je     573c <botlish_fn_56+0x414>
    548d:	mov    rsi,rax
    5490:	jmp    549c <botlish_fn_56+0x174>
    5495:	mov    rax,QWORD PTR [rsi+0x10]
    5499:	mov    rsi,QWORD PTR [rax]
    549c:	mov    QWORD PTR [rsp+0x18],rsi
    54a1:	mov    rdi,r13
    54a4:	mov    QWORD PTR [rsp+0x78],rsi
    54a9:	mov    rax,QWORD PTR [rdi+0x10]
    54ad:	mov    rdx,QWORD PTR [rax+0x68]
    54b1:	mov    QWORD PTR [rsp+0x20],rdx
    54b6:	mov    rsi,r15
    54b9:	call   54be <botlish_fn_56+0x196>
			54ba: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    54be:	test   rax,rax
    54c1:	je     573c <botlish_fn_56+0x414>
    54c7:	mov    QWORD PTR [rsp+0x20],rax
    54cc:	mov    rbx,rax
    54cf:	mov    rdi,r13
    54d2:	mov    rax,QWORD PTR [rdi+0x10]
    54d6:	mov    rdx,QWORD PTR [rax+0x68]
    54da:	mov    QWORD PTR [rsp+0x28],rdx
    54df:	mov    rsi,QWORD PTR [rsp+0x78]
    54e4:	call   54e9 <botlish_fn_56+0x1c1>
			54e5: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    54e9:	test   rax,rax
    54ec:	je     573c <botlish_fn_56+0x414>
    54f2:	mov    rcx,rbx
    54f5:	mov    rdx,rcx
    54f8:	and    rdx,rax
    54fb:	test   rdx,0x1
    5502:	jne    5524 <botlish_fn_56+0x1fc>
    5508:	mov    rdx,rax
    550b:	mov    rsi,rbx
    550e:	mov    rdi,r13
    5511:	call   5516 <botlish_fn_56+0x1ee>
			5512: R_X86_64_PLT32	rt_value_eq-0x4
    5516:	test   rax,rax
    5519:	je     573c <botlish_fn_56+0x414>
    551f:	jmp    553a <botlish_fn_56+0x212>
    5524:	mov    rdx,rax
    5527:	mov    rsi,rbx
    552a:	mov    eax,0x2
    552f:	cmp    rsi,rdx
    5532:	cmove  rax,QWORD PTR [rip+0x26e]        # 57a8 <botlish_fn_56+0x480>
    553a:	mov    ebx,0x6
    553f:	cmp    rax,0x6
    5543:	je     555e <botlish_fn_56+0x236>
    5549:	mov    ebx,0x2
    554e:	mov    QWORD PTR [rsp],0x2
    5556:	mov    rsi,r12
    5559:	jmp    55fd <botlish_fn_56+0x2d5>
    555e:	mov    rsi,r15
    5561:	mov    rdi,r13
    5564:	call   5569 <botlish_fn_56+0x241>
			5565: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5569:	test   rax,rax
    556c:	mov    QWORD PTR [rsp+0x88],rax
    5574:	je     573c <botlish_fn_56+0x414>
    557a:	mov    rsi,QWORD PTR [rsp+0x78]
    557f:	mov    rdi,r13
    5582:	call   5587 <botlish_fn_56+0x25f>
			5583: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5587:	test   rax,rax
    558a:	je     573c <botlish_fn_56+0x414>
    5590:	mov    rcx,QWORD PTR [rsp+0x88]
    5598:	mov    rdx,rcx
    559b:	and    rdx,rax
    559e:	test   rdx,0x1
    55a5:	jne    55cc <botlish_fn_56+0x2a4>
    55ab:	mov    rdx,rax
    55ae:	mov    rsi,QWORD PTR [rsp+0x88]
    55b6:	mov    rdi,r13
    55b9:	call   55be <botlish_fn_56+0x296>
			55ba: R_X86_64_PLT32	rt_value_eq-0x4
    55be:	test   rax,rax
    55c1:	je     573c <botlish_fn_56+0x414>
    55c7:	jmp    55e7 <botlish_fn_56+0x2bf>
    55cc:	mov    rdx,rax
    55cf:	mov    rsi,QWORD PTR [rsp+0x88]
    55d7:	mov    eax,0x2
    55dc:	cmp    rsi,rdx
    55df:	cmove  rax,QWORD PTR [rip+0x1c1]        # 57a8 <botlish_fn_56+0x480>
    55e7:	cmp    rax,0x6
    55eb:	je     55f6 <botlish_fn_56+0x2ce>
    55f1:	mov    ebx,0x2
    55f6:	mov    QWORD PTR [rsp],rbx
    55fa:	mov    rsi,r12
    55fd:	mov    rdi,r13
    5600:	call   5605 <botlish_fn_56+0x2dd>
			5601: R_X86_64_PLT32	rt_list_len-0x4
    5605:	mov    QWORD PTR [rsp+0x18],rax
    560a:	mov    rdi,r13
    560d:	mov    r12,rax
    5610:	mov    rax,QWORD PTR [rdi+0x10]
    5614:	mov    rdx,QWORD PTR [rax+0x68]
    5618:	mov    QWORD PTR [rsp+0x20],rdx
    561d:	mov    rsi,r15
    5620:	call   5625 <botlish_fn_56+0x2fd>
			5621: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    5625:	test   rax,rax
    5628:	je     573c <botlish_fn_56+0x414>
    562e:	mov    QWORD PTR [rsp+0x20],rax
    5633:	mov    rdi,r13
    5636:	mov    QWORD PTR [rsp+0x88],rax
    563e:	mov    rax,QWORD PTR [rdi+0x10]
    5642:	mov    rdx,QWORD PTR [rax+0x70]
    5646:	mov    QWORD PTR [rsp+0x28],rdx
    564b:	mov    rsi,r15
    564e:	call   5653 <botlish_fn_56+0x32b>
			564f: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    5653:	test   rax,rax
    5656:	je     573c <botlish_fn_56+0x414>
    565c:	mov    QWORD PTR [rsp+0x28],rax
    5661:	mov    rdi,r13
    5664:	mov    QWORD PTR [rsp+0x80],rax
    566c:	mov    rax,QWORD PTR [rdi+0x10]
    5670:	mov    rdx,QWORD PTR [rax+0x78]
    5674:	mov    QWORD PTR [rsp+0x30],rdx
    5679:	mov    rsi,r15
    567c:	call   5681 <botlish_fn_56+0x359>
			567d: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    5681:	test   rax,rax
    5684:	je     573c <botlish_fn_56+0x414>
    568a:	mov    QWORD PTR [rsp+0x8],rax
    568f:	mov    rdi,r13
    5692:	mov    r15,rax
    5695:	mov    rax,QWORD PTR [rdi+0x10]
    5699:	mov    rdx,QWORD PTR [rax+0x68]
    569d:	mov    QWORD PTR [rsp+0x30],rdx
    56a2:	mov    rsi,r14
    56a5:	call   56aa <botlish_fn_56+0x382>
			56a6: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    56aa:	test   rax,rax
    56ad:	je     573c <botlish_fn_56+0x414>
    56b3:	mov    QWORD PTR [rsp+0x30],rax
    56b8:	mov    rdi,r13
    56bb:	mov    QWORD PTR [rsp+0x78],rax
    56c0:	mov    rax,QWORD PTR [rdi+0x10]
    56c4:	mov    rdx,QWORD PTR [rax+0x78]
    56c8:	mov    QWORD PTR [rsp+0x38],rdx
    56cd:	mov    rsi,r14
    56d0:	call   56d5 <botlish_fn_56+0x3ad>
			56d1: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_get<mutarray, str>
    56d5:	test   rax,rax
    56d8:	je     573c <botlish_fn_56+0x414>
    56de:	mov    QWORD PTR [rsp+0x10],rax
    56e3:	lea    rdx,[rsp+0x40]
    56e8:	mov    r9,r12
    56eb:	mov    QWORD PTR [rsp+0x40],r9
    56f0:	mov    rcx,QWORD PTR [rsp+0x88]
    56f8:	mov    QWORD PTR [rsp+0x48],rcx
    56fd:	mov    rcx,QWORD PTR [rsp+0x80]
    5705:	mov    QWORD PTR [rsp+0x50],rcx
    570a:	mov    rcx,r15
    570d:	mov    QWORD PTR [rsp+0x58],rcx
    5712:	mov    rcx,QWORD PTR [rsp+0x78]
    5717:	mov    QWORD PTR [rsp+0x60],rcx
    571c:	mov    QWORD PTR [rsp+0x68],rax
    5721:	mov    QWORD PTR [rsp+0x70],rbx
    5726:	mov    esi,0x7
    572b:	mov    rdi,r13
    572e:	call   5733 <botlish_fn_56+0x40b>
			572f: R_X86_64_PLT32	rt_list_new-0x4
    5733:	test   rax,rax
    5736:	jne    5773 <botlish_fn_56+0x44b>
    573c:	xor    rax,rax
    573f:	mov    rbx,QWORD PTR [rsp+0x90]
    5747:	mov    r12,QWORD PTR [rsp+0x98]
    574f:	mov    r13,QWORD PTR [rsp+0xa0]
    5757:	mov    r14,QWORD PTR [rsp+0xa8]
    575f:	mov    r15,QWORD PTR [rsp+0xb0]
    5767:	add    rsp,0xc0
    576e:	mov    rsp,rbp
    5771:	pop    rbp
    5772:	ret
    5773:	mov    rbx,QWORD PTR [rsp+0x90]
    577b:	mov    r12,QWORD PTR [rsp+0x98]
    5783:	mov    r13,QWORD PTR [rsp+0xa0]
    578b:	mov    r14,QWORD PTR [rsp+0xa8]
    5793:	mov    r15,QWORD PTR [rsp+0xb0]
    579b:	add    rsp,0xc0
    57a2:	mov    rsp,rbp
    57a5:	pop    rbp
    57a6:	ret
    57a7:	add    BYTE PTR [rsi],al
    57a9:	add    BYTE PTR [rax],al
    57ab:	add    BYTE PTR [rax],al
    57ad:	add    BYTE PTR [rax],al
	...

00000000000057b0 <botlish_entry_56: sample<generic>>:
    57b0:	push   rbp
    57b1:	mov    rbp,rsp
    57b4:	call   57b9 <botlish_entry_56+0x9>
			57b5: R_X86_64_PLT32	botlish_fn_56-0x4 ; sample<generic>
    57b9:	mov    rsp,rbp
    57bc:	pop    rbp
    57bd:	ret

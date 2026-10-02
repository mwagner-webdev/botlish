; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23204  (per function: 45 461 461 461 81 81 81 360 420 420 420 278 278 278 81 365 430 585 1063 352 783 215 488 325 388 524 70 504 112 61 61 61 61 61 199 185 252 804 1248 429 380 439 977 784 809 665 1168 836 90 427 231 604 584 78 78 1222)
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
     64a:	mov    QWORD PTR [rsp],rdx
     64e:	mov    rbx,rdx
     651:	shl    rsi,1
     654:	mov    rax,rsi
     657:	or     rax,0x1
     65b:	mov    QWORD PTR [rsp+0x8],rax
     660:	mov    QWORD PTR [rsp+0x10],0x5
     669:	mov    rax,rsi
     66c:	or     rax,0x1
     670:	sar    rax,1
     673:	imul   QWORD PTR [rip+0xe6]        # 760 <botlish_fn_7+0x130>
     67a:	seto   cl
     67d:	or     rax,0x1
     681:	test   cl,cl
     683:	je     69a <botlish_fn_7+0x6a>
     689:	or     rsi,0x1
     68d:	mov    edx,0x5
     692:	mov    rdi,r12
     695:	call   69a <botlish_fn_7+0x6a>
			696: R_X86_64_PLT32	rt_int_mul-0x4
     69a:	mov    rcx,rax
     69d:	and    rcx,rbx
     6a0:	mov    r13,rax
     6a3:	test   rcx,0x1
     6aa:	jne    6d6 <botlish_fn_7+0xa6>
     6b0:	mov    rdx,rbx
     6b3:	mov    rsi,r13
     6b6:	mov    rdi,r12
     6b9:	call   6be <botlish_fn_7+0x8e>
			6ba: R_X86_64_PLT32	rt_int_cmp-0x4
     6be:	mov    ecx,0x2
     6c3:	test   rax,rax
     6c6:	cmovle rcx,QWORD PTR [rip+0x9a]        # 768 <botlish_fn_7+0x138>
     6ce:	mov    rax,r13
     6d1:	jmp    6e9 <botlish_fn_7+0xb9>
     6d6:	mov    ecx,0x2
     6db:	mov    rax,r13
     6de:	cmp    rax,rbx
     6e1:	cmovle rcx,QWORD PTR [rip+0x7f]        # 768 <botlish_fn_7+0x138>
     6e9:	cmp    rcx,0x6
     6ed:	je     70b <botlish_fn_7+0xdb>
     6f3:	mov    rbx,QWORD PTR [rsp+0x20]
     6f8:	mov    r12,QWORD PTR [rsp+0x28]
     6fd:	mov    r13,QWORD PTR [rsp+0x30]
     702:	add    rsp,0x40
     706:	mov    rsp,rbp
     709:	pop    rbp
     70a:	ret
     70b:	mov    QWORD PTR [rsp+0x8],0x3
     714:	test   rbx,0x1
     71b:	je     733 <botlish_fn_7+0x103>
     721:	mov    rax,rbx
     724:	add    rax,0x2
     728:	seto   cl
     72b:	test   cl,cl
     72d:	je     743 <botlish_fn_7+0x113>
     733:	mov    edx,0x3
     738:	mov    rsi,rbx
     73b:	mov    rdi,r12
     73e:	call   743 <botlish_fn_7+0x113>
			73f: R_X86_64_PLT32	rt_int_add-0x4
     743:	mov    rbx,QWORD PTR [rsp+0x20]
     748:	mov    r12,QWORD PTR [rsp+0x28]
     74d:	mov    r13,QWORD PTR [rsp+0x30]
     752:	add    rsp,0x40
     756:	mov    rsp,rbp
     759:	pop    rbp
     75a:	ret
     75b:	add    BYTE PTR [rax],al
     75d:	add    BYTE PTR [rax],al
     75f:	add    BYTE PTR [rax+rax*1],al
     762:	add    BYTE PTR [rax],al
     764:	add    BYTE PTR [rax],al
     766:	add    BYTE PTR [rax],al
     768:	(bad)
     769:	add    BYTE PTR [rax],al
     76b:	add    BYTE PTR [rax],al
     76d:	add    BYTE PTR [rax],al
	...

0000000000000770 <botlish_entry_7: geo_new_capacity<int, int>>:
     770:	push   rbp
     771:	mov    rbp,rsp
     774:	mov    rsi,QWORD PTR [rdx]
     777:	mov    rdx,QWORD PTR [rdx+0x8]
     77b:	sar    rsi,1
     77e:	call   783 <botlish_entry_7+0x13>
			77f: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     783:	mov    rsp,rbp
     786:	pop    rbp
     787:	ret

0000000000000788 <botlish_fn_8: geo_grow<mutarray, int, str>>:
     788:	push   rbp
     789:	mov    rbp,rsp
     78c:	sub    rsp,0x50
     790:	mov    QWORD PTR [rsp+0x20],rbx
     795:	mov    QWORD PTR [rsp+0x28],r12
     79a:	mov    QWORD PTR [rsp+0x30],r13
     79f:	mov    QWORD PTR [rsp+0x38],r14
     7a4:	mov    QWORD PTR [rsp+0x40],r15
     7a9:	mov    r13,rdi
     7ac:	mov    QWORD PTR [rsp+0x18],0x0
     7b5:	mov    QWORD PTR [rsp],rsi
     7b9:	mov    r12,rsi
     7bc:	mov    QWORD PTR [rsp+0x8],rdx
     7c1:	mov    rbx,rdx
     7c4:	mov    QWORD PTR [rsp+0x10],rcx
     7c9:	mov    r14,rcx
     7cc:	mov    rsi,r12
     7cf:	mov    rdi,r13
     7d2:	call   7d7 <botlish_fn_8+0x4f>
			7d3: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     7d7:	mov    rcx,rbx
     7da:	and    rcx,rax
     7dd:	mov    r15,rax
     7e0:	test   rcx,0x1
     7e7:	jne    813 <botlish_fn_8+0x8b>
     7ed:	mov    rdx,r15
     7f0:	mov    rsi,rbx
     7f3:	mov    rdi,r13
     7f6:	call   7fb <botlish_fn_8+0x73>
			7f7: R_X86_64_PLT32	rt_int_cmp-0x4
     7fb:	mov    ecx,0x2
     800:	test   rax,rax
     803:	cmovl  rcx,QWORD PTR [rip+0xed]        # 8f8 <botlish_fn_8+0x170>
     80b:	mov    rax,r15
     80e:	jmp    826 <botlish_fn_8+0x9e>
     813:	mov    ecx,0x2
     818:	mov    rax,r15
     81b:	cmp    rbx,rax
     81e:	cmovl  rcx,QWORD PTR [rip+0xd2]        # 8f8 <botlish_fn_8+0x170>
     826:	cmp    rcx,0x6
     82a:	je     8cd <botlish_fn_8+0x145>
     830:	mov    rsi,rax
     833:	sar    rsi,1
     836:	mov    rdx,rbx
     839:	mov    rdi,r13
     83c:	call   841 <botlish_fn_8+0xb9>
			83d: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     841:	mov    QWORD PTR [rsp+0x18],rax
     846:	mov    rdx,r14
     849:	mov    rsi,rax
     84c:	mov    rdi,r13
     84f:	call   854 <botlish_fn_8+0xcc>
			850: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
     854:	test   rax,rax
     857:	mov    r14,rax
     85a:	je     883 <botlish_fn_8+0xfb>
     860:	mov    r8d,0x1
     866:	mov    rcx,r12
     869:	mov    rdi,r13
     86c:	mov    r9,rbx
     86f:	mov    rsi,r14
     872:	mov    rdx,r8
     875:	call   87a <botlish_fn_8+0xf2>
			876: R_X86_64_PLT32	rt_mutarray_copy-0x4
     87a:	test   rax,rax
     87d:	jne    8a8 <botlish_fn_8+0x120>
     883:	xor    rax,rax
     886:	mov    rbx,QWORD PTR [rsp+0x20]
     88b:	mov    r12,QWORD PTR [rsp+0x28]
     890:	mov    r13,QWORD PTR [rsp+0x30]
     895:	mov    r14,QWORD PTR [rsp+0x38]
     89a:	mov    r15,QWORD PTR [rsp+0x40]
     89f:	add    rsp,0x50
     8a3:	mov    rsp,rbp
     8a6:	pop    rbp
     8a7:	ret
     8a8:	mov    rax,r14
     8ab:	mov    rbx,QWORD PTR [rsp+0x20]
     8b0:	mov    r12,QWORD PTR [rsp+0x28]
     8b5:	mov    r13,QWORD PTR [rsp+0x30]
     8ba:	mov    r14,QWORD PTR [rsp+0x38]
     8bf:	mov    r15,QWORD PTR [rsp+0x40]
     8c4:	add    rsp,0x50
     8c8:	mov    rsp,rbp
     8cb:	pop    rbp
     8cc:	ret
     8cd:	mov    rax,r12
     8d0:	mov    rbx,QWORD PTR [rsp+0x20]
     8d5:	mov    r12,QWORD PTR [rsp+0x28]
     8da:	mov    r13,QWORD PTR [rsp+0x30]
     8df:	mov    r14,QWORD PTR [rsp+0x38]
     8e4:	mov    r15,QWORD PTR [rsp+0x40]
     8e9:	add    rsp,0x50
     8ed:	mov    rsp,rbp
     8f0:	pop    rbp
     8f1:	ret
     8f2:	add    BYTE PTR [rax],al
     8f4:	add    BYTE PTR [rax],al
     8f6:	add    BYTE PTR [rax],al
     8f8:	(bad)
     8f9:	add    BYTE PTR [rax],al
     8fb:	add    BYTE PTR [rax],al
     8fd:	add    BYTE PTR [rax],al
	...

0000000000000900 <botlish_entry_8: geo_grow<mutarray, int, str>>:
     900:	push   rbp
     901:	mov    rbp,rsp
     904:	mov    rsi,QWORD PTR [rdx]
     907:	mov    r8,QWORD PTR [rdx+0x8]
     90b:	mov    rcx,QWORD PTR [rdx+0x10]
     90f:	mov    rdx,r8
     912:	call   917 <botlish_entry_8+0x17>
			913: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_grow<mutarray, int, str>
     917:	mov    rsp,rbp
     91a:	pop    rbp
     91b:	ret
     91c:	add    BYTE PTR [rax],al
	...

0000000000000920 <botlish_fn_9: geo_grow<mutarray, int, List[str]>>:
     920:	push   rbp
     921:	mov    rbp,rsp
     924:	sub    rsp,0x50
     928:	mov    QWORD PTR [rsp+0x20],rbx
     92d:	mov    QWORD PTR [rsp+0x28],r12
     932:	mov    QWORD PTR [rsp+0x30],r13
     937:	mov    QWORD PTR [rsp+0x38],r14
     93c:	mov    QWORD PTR [rsp+0x40],r15
     941:	mov    r13,rdi
     944:	mov    QWORD PTR [rsp+0x18],0x0
     94d:	mov    QWORD PTR [rsp],rsi
     951:	mov    r12,rsi
     954:	mov    QWORD PTR [rsp+0x8],rdx
     959:	mov    rbx,rdx
     95c:	mov    QWORD PTR [rsp+0x10],rcx
     961:	mov    r14,rcx
     964:	mov    rsi,r12
     967:	mov    rdi,r13
     96a:	call   96f <botlish_fn_9+0x4f>
			96b: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     96f:	mov    rcx,rbx
     972:	and    rcx,rax
     975:	mov    r15,rax
     978:	test   rcx,0x1
     97f:	jne    9ab <botlish_fn_9+0x8b>
     985:	mov    rdx,r15
     988:	mov    rsi,rbx
     98b:	mov    rdi,r13
     98e:	call   993 <botlish_fn_9+0x73>
			98f: R_X86_64_PLT32	rt_int_cmp-0x4
     993:	mov    ecx,0x2
     998:	test   rax,rax
     99b:	cmovl  rcx,QWORD PTR [rip+0xed]        # a90 <botlish_fn_9+0x170>
     9a3:	mov    rax,r15
     9a6:	jmp    9be <botlish_fn_9+0x9e>
     9ab:	mov    ecx,0x2
     9b0:	mov    rax,r15
     9b3:	cmp    rbx,rax
     9b6:	cmovl  rcx,QWORD PTR [rip+0xd2]        # a90 <botlish_fn_9+0x170>
     9be:	cmp    rcx,0x6
     9c2:	je     a65 <botlish_fn_9+0x145>
     9c8:	mov    rsi,rax
     9cb:	sar    rsi,1
     9ce:	mov    rdx,rbx
     9d1:	mov    rdi,r13
     9d4:	call   9d9 <botlish_fn_9+0xb9>
			9d5: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     9d9:	mov    QWORD PTR [rsp+0x18],rax
     9de:	mov    rdx,r14
     9e1:	mov    rsi,rax
     9e4:	mov    rdi,r13
     9e7:	call   9ec <botlish_fn_9+0xcc>
			9e8: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
     9ec:	test   rax,rax
     9ef:	mov    r14,rax
     9f2:	je     a1b <botlish_fn_9+0xfb>
     9f8:	mov    r8d,0x1
     9fe:	mov    rcx,r12
     a01:	mov    rdi,r13
     a04:	mov    r9,rbx
     a07:	mov    rsi,r14
     a0a:	mov    rdx,r8
     a0d:	call   a12 <botlish_fn_9+0xf2>
			a0e: R_X86_64_PLT32	rt_mutarray_copy-0x4
     a12:	test   rax,rax
     a15:	jne    a40 <botlish_fn_9+0x120>
     a1b:	xor    rax,rax
     a1e:	mov    rbx,QWORD PTR [rsp+0x20]
     a23:	mov    r12,QWORD PTR [rsp+0x28]
     a28:	mov    r13,QWORD PTR [rsp+0x30]
     a2d:	mov    r14,QWORD PTR [rsp+0x38]
     a32:	mov    r15,QWORD PTR [rsp+0x40]
     a37:	add    rsp,0x50
     a3b:	mov    rsp,rbp
     a3e:	pop    rbp
     a3f:	ret
     a40:	mov    rax,r14
     a43:	mov    rbx,QWORD PTR [rsp+0x20]
     a48:	mov    r12,QWORD PTR [rsp+0x28]
     a4d:	mov    r13,QWORD PTR [rsp+0x30]
     a52:	mov    r14,QWORD PTR [rsp+0x38]
     a57:	mov    r15,QWORD PTR [rsp+0x40]
     a5c:	add    rsp,0x50
     a60:	mov    rsp,rbp
     a63:	pop    rbp
     a64:	ret
     a65:	mov    rax,r12
     a68:	mov    rbx,QWORD PTR [rsp+0x20]
     a6d:	mov    r12,QWORD PTR [rsp+0x28]
     a72:	mov    r13,QWORD PTR [rsp+0x30]
     a77:	mov    r14,QWORD PTR [rsp+0x38]
     a7c:	mov    r15,QWORD PTR [rsp+0x40]
     a81:	add    rsp,0x50
     a85:	mov    rsp,rbp
     a88:	pop    rbp
     a89:	ret
     a8a:	add    BYTE PTR [rax],al
     a8c:	add    BYTE PTR [rax],al
     a8e:	add    BYTE PTR [rax],al
     a90:	(bad)
     a91:	add    BYTE PTR [rax],al
     a93:	add    BYTE PTR [rax],al
     a95:	add    BYTE PTR [rax],al
	...

0000000000000a98 <botlish_entry_9: geo_grow<mutarray, int, List[str]>>:
     a98:	push   rbp
     a99:	mov    rbp,rsp
     a9c:	mov    rsi,QWORD PTR [rdx]
     a9f:	mov    r8,QWORD PTR [rdx+0x8]
     aa3:	mov    rcx,QWORD PTR [rdx+0x10]
     aa7:	mov    rdx,r8
     aaa:	call   aaf <botlish_entry_9+0x17>
			aab: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, List[str]>
     aaf:	mov    rsp,rbp
     ab2:	pop    rbp
     ab3:	ret
     ab4:	add    BYTE PTR [rax],al
	...

0000000000000ab8 <botlish_fn_10: geo_grow<mutarray, int, mutarray>>:
     ab8:	push   rbp
     ab9:	mov    rbp,rsp
     abc:	sub    rsp,0x50
     ac0:	mov    QWORD PTR [rsp+0x20],rbx
     ac5:	mov    QWORD PTR [rsp+0x28],r12
     aca:	mov    QWORD PTR [rsp+0x30],r13
     acf:	mov    QWORD PTR [rsp+0x38],r14
     ad4:	mov    QWORD PTR [rsp+0x40],r15
     ad9:	mov    r13,rdi
     adc:	mov    QWORD PTR [rsp+0x18],0x0
     ae5:	mov    QWORD PTR [rsp],rsi
     ae9:	mov    r12,rsi
     aec:	mov    QWORD PTR [rsp+0x8],rdx
     af1:	mov    rbx,rdx
     af4:	mov    QWORD PTR [rsp+0x10],rcx
     af9:	mov    r14,rcx
     afc:	mov    rsi,r12
     aff:	mov    rdi,r13
     b02:	call   b07 <botlish_fn_10+0x4f>
			b03: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     b07:	mov    rcx,rbx
     b0a:	and    rcx,rax
     b0d:	mov    r15,rax
     b10:	test   rcx,0x1
     b17:	jne    b43 <botlish_fn_10+0x8b>
     b1d:	mov    rdx,r15
     b20:	mov    rsi,rbx
     b23:	mov    rdi,r13
     b26:	call   b2b <botlish_fn_10+0x73>
			b27: R_X86_64_PLT32	rt_int_cmp-0x4
     b2b:	mov    ecx,0x2
     b30:	test   rax,rax
     b33:	cmovl  rcx,QWORD PTR [rip+0xed]        # c28 <botlish_fn_10+0x170>
     b3b:	mov    rax,r15
     b3e:	jmp    b56 <botlish_fn_10+0x9e>
     b43:	mov    ecx,0x2
     b48:	mov    rax,r15
     b4b:	cmp    rbx,rax
     b4e:	cmovl  rcx,QWORD PTR [rip+0xd2]        # c28 <botlish_fn_10+0x170>
     b56:	cmp    rcx,0x6
     b5a:	je     bfd <botlish_fn_10+0x145>
     b60:	mov    rsi,rax
     b63:	sar    rsi,1
     b66:	mov    rdx,rbx
     b69:	mov    rdi,r13
     b6c:	call   b71 <botlish_fn_10+0xb9>
			b6d: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     b71:	mov    QWORD PTR [rsp+0x18],rax
     b76:	mov    rdx,r14
     b79:	mov    rsi,rax
     b7c:	mov    rdi,r13
     b7f:	call   b84 <botlish_fn_10+0xcc>
			b80: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutarray::create<int, mutarray>
     b84:	test   rax,rax
     b87:	mov    r14,rax
     b8a:	je     bb3 <botlish_fn_10+0xfb>
     b90:	mov    r8d,0x1
     b96:	mov    rcx,r12
     b99:	mov    rdi,r13
     b9c:	mov    r9,rbx
     b9f:	mov    rsi,r14
     ba2:	mov    rdx,r8
     ba5:	call   baa <botlish_fn_10+0xf2>
			ba6: R_X86_64_PLT32	rt_mutarray_copy-0x4
     baa:	test   rax,rax
     bad:	jne    bd8 <botlish_fn_10+0x120>
     bb3:	xor    rax,rax
     bb6:	mov    rbx,QWORD PTR [rsp+0x20]
     bbb:	mov    r12,QWORD PTR [rsp+0x28]
     bc0:	mov    r13,QWORD PTR [rsp+0x30]
     bc5:	mov    r14,QWORD PTR [rsp+0x38]
     bca:	mov    r15,QWORD PTR [rsp+0x40]
     bcf:	add    rsp,0x50
     bd3:	mov    rsp,rbp
     bd6:	pop    rbp
     bd7:	ret
     bd8:	mov    rax,r14
     bdb:	mov    rbx,QWORD PTR [rsp+0x20]
     be0:	mov    r12,QWORD PTR [rsp+0x28]
     be5:	mov    r13,QWORD PTR [rsp+0x30]
     bea:	mov    r14,QWORD PTR [rsp+0x38]
     bef:	mov    r15,QWORD PTR [rsp+0x40]
     bf4:	add    rsp,0x50
     bf8:	mov    rsp,rbp
     bfb:	pop    rbp
     bfc:	ret
     bfd:	mov    rax,r12
     c00:	mov    rbx,QWORD PTR [rsp+0x20]
     c05:	mov    r12,QWORD PTR [rsp+0x28]
     c0a:	mov    r13,QWORD PTR [rsp+0x30]
     c0f:	mov    r14,QWORD PTR [rsp+0x38]
     c14:	mov    r15,QWORD PTR [rsp+0x40]
     c19:	add    rsp,0x50
     c1d:	mov    rsp,rbp
     c20:	pop    rbp
     c21:	ret
     c22:	add    BYTE PTR [rax],al
     c24:	add    BYTE PTR [rax],al
     c26:	add    BYTE PTR [rax],al
     c28:	(bad)
     c29:	add    BYTE PTR [rax],al
     c2b:	add    BYTE PTR [rax],al
     c2d:	add    BYTE PTR [rax],al
	...

0000000000000c30 <botlish_entry_10: geo_grow<mutarray, int, mutarray>>:
     c30:	push   rbp
     c31:	mov    rbp,rsp
     c34:	mov    rsi,QWORD PTR [rdx]
     c37:	mov    r8,QWORD PTR [rdx+0x8]
     c3b:	mov    rcx,QWORD PTR [rdx+0x10]
     c3f:	mov    rdx,r8
     c42:	call   c47 <botlish_entry_10+0x17>
			c43: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_grow<mutarray, int, mutarray>
     c47:	mov    rsp,rbp
     c4a:	pop    rbp
     c4b:	ret

0000000000000c4c <botlish_fn_11: geo_append<mutarray, int, str>>:
     c4c:	push   rbp
     c4d:	mov    rbp,rsp
     c50:	sub    rsp,0x40
     c54:	mov    QWORD PTR [rsp+0x20],rbx
     c59:	mov    QWORD PTR [rsp+0x28],r12
     c5e:	mov    QWORD PTR [rsp+0x30],r13
     c63:	mov    QWORD PTR [rsp+0x38],r14
     c68:	mov    rbx,rdi
     c6b:	mov    QWORD PTR [rsp],rsi
     c6f:	mov    QWORD PTR [rsp+0x8],rdx
     c74:	mov    r14,rdx
     c77:	mov    QWORD PTR [rsp+0x10],rcx
     c7c:	mov    r13,rcx
     c7f:	mov    rcx,r13
     c82:	mov    rdx,r14
     c85:	mov    rdi,rbx
     c88:	call   c8d <botlish_fn_11+0x41>
			c89: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_grow<mutarray, int, str>
     c8d:	test   rax,rax
     c90:	je     cf8 <botlish_fn_11+0xac>
     c96:	xor    ecx,ecx
     c98:	test   rax,0x7
     c9e:	je     cac <botlish_fn_11+0x60>
     ca4:	mov    r12,rax
     ca7:	jmp    cba <botlish_fn_11+0x6e>
     cac:	movzx  rcx,BYTE PTR [rax]
     cb0:	mov    r12,rax
     cb3:	rex cmp cl,0x8
     cb7:	sete   cl
     cba:	test   cl,cl
     cbc:	jne    cde <botlish_fn_11+0x92>
     cc2:	mov    rdi,rbx
     cc5:	mov    rax,QWORD PTR [rdi+0x10]
     cc9:	mov    rcx,QWORD PTR [rax]
     ccc:	mov    edx,0x8
     cd1:	mov    rsi,r12
     cd4:	call   cd9 <botlish_fn_11+0x8d>
			cd5: R_X86_64_PLT32	rt_type_error-0x4
     cd9:	jmp    cf8 <botlish_fn_11+0xac>
     cde:	mov    rcx,r13
     ce1:	mov    rdx,r14
     ce4:	mov    rdi,rbx
     ce7:	mov    rsi,r12
     cea:	call   cef <botlish_fn_11+0xa3>
			ceb: R_X86_64_PLT32	rt_mutarray_set-0x4
     cef:	test   rax,rax
     cf2:	jne    d18 <botlish_fn_11+0xcc>
     cf8:	xor    rax,rax
     cfb:	mov    rbx,QWORD PTR [rsp+0x20]
     d00:	mov    r12,QWORD PTR [rsp+0x28]
     d05:	mov    r13,QWORD PTR [rsp+0x30]
     d0a:	mov    r14,QWORD PTR [rsp+0x38]
     d0f:	add    rsp,0x40
     d13:	mov    rsp,rbp
     d16:	pop    rbp
     d17:	ret
     d18:	mov    rax,r12
     d1b:	mov    rbx,QWORD PTR [rsp+0x20]
     d20:	mov    r12,QWORD PTR [rsp+0x28]
     d25:	mov    r13,QWORD PTR [rsp+0x30]
     d2a:	mov    r14,QWORD PTR [rsp+0x38]
     d2f:	add    rsp,0x40
     d33:	mov    rsp,rbp
     d36:	pop    rbp
     d37:	ret

0000000000000d38 <botlish_entry_11: geo_append<mutarray, int, str>>:
     d38:	push   rbp
     d39:	mov    rbp,rsp
     d3c:	mov    rsi,QWORD PTR [rdx]
     d3f:	mov    r8,QWORD PTR [rdx+0x8]
     d43:	mov    rcx,QWORD PTR [rdx+0x10]
     d47:	mov    rdx,r8
     d4a:	call   d4f <botlish_entry_11+0x17>
			d4b: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
     d4f:	mov    rsp,rbp
     d52:	pop    rbp
     d53:	ret

0000000000000d54 <botlish_fn_12: geo_append<mutarray, int, List[str]>>:
     d54:	push   rbp
     d55:	mov    rbp,rsp
     d58:	sub    rsp,0x40
     d5c:	mov    QWORD PTR [rsp+0x20],rbx
     d61:	mov    QWORD PTR [rsp+0x28],r12
     d66:	mov    QWORD PTR [rsp+0x30],r13
     d6b:	mov    QWORD PTR [rsp+0x38],r14
     d70:	mov    rbx,rdi
     d73:	mov    QWORD PTR [rsp],rsi
     d77:	mov    QWORD PTR [rsp+0x8],rdx
     d7c:	mov    r14,rdx
     d7f:	mov    QWORD PTR [rsp+0x10],rcx
     d84:	mov    r13,rcx
     d87:	mov    rcx,r13
     d8a:	mov    rdx,r14
     d8d:	mov    rdi,rbx
     d90:	call   d95 <botlish_fn_12+0x41>
			d91: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, List[str]>
     d95:	test   rax,rax
     d98:	je     e00 <botlish_fn_12+0xac>
     d9e:	xor    ecx,ecx
     da0:	test   rax,0x7
     da6:	je     db4 <botlish_fn_12+0x60>
     dac:	mov    r12,rax
     daf:	jmp    dc2 <botlish_fn_12+0x6e>
     db4:	movzx  rcx,BYTE PTR [rax]
     db8:	mov    r12,rax
     dbb:	rex cmp cl,0x8
     dbf:	sete   cl
     dc2:	test   cl,cl
     dc4:	jne    de6 <botlish_fn_12+0x92>
     dca:	mov    rdi,rbx
     dcd:	mov    rax,QWORD PTR [rdi+0x10]
     dd1:	mov    rcx,QWORD PTR [rax]
     dd4:	mov    edx,0x8
     dd9:	mov    rsi,r12
     ddc:	call   de1 <botlish_fn_12+0x8d>
			ddd: R_X86_64_PLT32	rt_type_error-0x4
     de1:	jmp    e00 <botlish_fn_12+0xac>
     de6:	mov    rcx,r13
     de9:	mov    rdx,r14
     dec:	mov    rdi,rbx
     def:	mov    rsi,r12
     df2:	call   df7 <botlish_fn_12+0xa3>
			df3: R_X86_64_PLT32	rt_mutarray_set-0x4
     df7:	test   rax,rax
     dfa:	jne    e20 <botlish_fn_12+0xcc>
     e00:	xor    rax,rax
     e03:	mov    rbx,QWORD PTR [rsp+0x20]
     e08:	mov    r12,QWORD PTR [rsp+0x28]
     e0d:	mov    r13,QWORD PTR [rsp+0x30]
     e12:	mov    r14,QWORD PTR [rsp+0x38]
     e17:	add    rsp,0x40
     e1b:	mov    rsp,rbp
     e1e:	pop    rbp
     e1f:	ret
     e20:	mov    rax,r12
     e23:	mov    rbx,QWORD PTR [rsp+0x20]
     e28:	mov    r12,QWORD PTR [rsp+0x28]
     e2d:	mov    r13,QWORD PTR [rsp+0x30]
     e32:	mov    r14,QWORD PTR [rsp+0x38]
     e37:	add    rsp,0x40
     e3b:	mov    rsp,rbp
     e3e:	pop    rbp
     e3f:	ret

0000000000000e40 <botlish_entry_12: geo_append<mutarray, int, List[str]>>:
     e40:	push   rbp
     e41:	mov    rbp,rsp
     e44:	mov    rsi,QWORD PTR [rdx]
     e47:	mov    r8,QWORD PTR [rdx+0x8]
     e4b:	mov    rcx,QWORD PTR [rdx+0x10]
     e4f:	mov    rdx,r8
     e52:	call   e57 <botlish_entry_12+0x17>
			e53: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
     e57:	mov    rsp,rbp
     e5a:	pop    rbp
     e5b:	ret

0000000000000e5c <botlish_fn_13: geo_append<mutarray, int, mutarray>>:
     e5c:	push   rbp
     e5d:	mov    rbp,rsp
     e60:	sub    rsp,0x40
     e64:	mov    QWORD PTR [rsp+0x20],rbx
     e69:	mov    QWORD PTR [rsp+0x28],r12
     e6e:	mov    QWORD PTR [rsp+0x30],r13
     e73:	mov    QWORD PTR [rsp+0x38],r14
     e78:	mov    rbx,rdi
     e7b:	mov    QWORD PTR [rsp],rsi
     e7f:	mov    QWORD PTR [rsp+0x8],rdx
     e84:	mov    r14,rdx
     e87:	mov    QWORD PTR [rsp+0x10],rcx
     e8c:	mov    r13,rcx
     e8f:	mov    rcx,r13
     e92:	mov    rdx,r14
     e95:	mov    rdi,rbx
     e98:	call   e9d <botlish_fn_13+0x41>
			e99: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_grow<mutarray, int, mutarray>
     e9d:	test   rax,rax
     ea0:	je     f08 <botlish_fn_13+0xac>
     ea6:	xor    ecx,ecx
     ea8:	test   rax,0x7
     eae:	je     ebc <botlish_fn_13+0x60>
     eb4:	mov    r12,rax
     eb7:	jmp    eca <botlish_fn_13+0x6e>
     ebc:	movzx  rcx,BYTE PTR [rax]
     ec0:	mov    r12,rax
     ec3:	rex cmp cl,0x8
     ec7:	sete   cl
     eca:	test   cl,cl
     ecc:	jne    eee <botlish_fn_13+0x92>
     ed2:	mov    rdi,rbx
     ed5:	mov    rax,QWORD PTR [rdi+0x10]
     ed9:	mov    rcx,QWORD PTR [rax]
     edc:	mov    edx,0x8
     ee1:	mov    rsi,r12
     ee4:	call   ee9 <botlish_fn_13+0x8d>
			ee5: R_X86_64_PLT32	rt_type_error-0x4
     ee9:	jmp    f08 <botlish_fn_13+0xac>
     eee:	mov    rcx,r13
     ef1:	mov    rdx,r14
     ef4:	mov    rdi,rbx
     ef7:	mov    rsi,r12
     efa:	call   eff <botlish_fn_13+0xa3>
			efb: R_X86_64_PLT32	rt_mutarray_set-0x4
     eff:	test   rax,rax
     f02:	jne    f28 <botlish_fn_13+0xcc>
     f08:	xor    rax,rax
     f0b:	mov    rbx,QWORD PTR [rsp+0x20]
     f10:	mov    r12,QWORD PTR [rsp+0x28]
     f15:	mov    r13,QWORD PTR [rsp+0x30]
     f1a:	mov    r14,QWORD PTR [rsp+0x38]
     f1f:	add    rsp,0x40
     f23:	mov    rsp,rbp
     f26:	pop    rbp
     f27:	ret
     f28:	mov    rax,r12
     f2b:	mov    rbx,QWORD PTR [rsp+0x20]
     f30:	mov    r12,QWORD PTR [rsp+0x28]
     f35:	mov    r13,QWORD PTR [rsp+0x30]
     f3a:	mov    r14,QWORD PTR [rsp+0x38]
     f3f:	add    rsp,0x40
     f43:	mov    rsp,rbp
     f46:	pop    rbp
     f47:	ret

0000000000000f48 <botlish_entry_13: geo_append<mutarray, int, mutarray>>:
     f48:	push   rbp
     f49:	mov    rbp,rsp
     f4c:	mov    rsi,QWORD PTR [rdx]
     f4f:	mov    r8,QWORD PTR [rdx+0x8]
     f53:	mov    rcx,QWORD PTR [rdx+0x10]
     f57:	mov    rdx,r8
     f5a:	call   f5f <botlish_entry_13+0x17>
			f5b: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
     f5f:	mov    rsp,rbp
     f62:	pop    rbp
     f63:	ret

0000000000000f64 <botlish_fn_14: geo_finish<mutarray, int>>:
     f64:	push   rbp
     f65:	mov    rbp,rsp
     f68:	sub    rsp,0x10
     f6c:	mov    QWORD PTR [rsp],rsi
     f70:	mov    QWORD PTR [rsp+0x8],rdx
     f75:	call   f7a <botlish_fn_14+0x16>
			f76: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     f7a:	test   rax,rax
     f7d:	jne    f8f <botlish_fn_14+0x2b>
     f83:	xor    rax,rax
     f86:	add    rsp,0x10
     f8a:	mov    rsp,rbp
     f8d:	pop    rbp
     f8e:	ret
     f8f:	add    rsp,0x10
     f93:	mov    rsp,rbp
     f96:	pop    rbp
     f97:	ret

0000000000000f98 <botlish_entry_14: geo_finish<mutarray, int>>:
     f98:	push   rbp
     f99:	mov    rbp,rsp
     f9c:	mov    rsi,QWORD PTR [rdx]
     f9f:	mov    rdx,QWORD PTR [rdx+0x8]
     fa3:	call   fa8 <botlish_entry_14+0x10>
			fa4: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
     fa8:	mov    rsp,rbp
     fab:	pop    rbp
     fac:	ret
     fad:	add    BYTE PTR [rax],al
	...

0000000000000fb0 <botlish_fn_15: peek<str, int>>:
     fb0:	push   rbp
     fb1:	mov    rbp,rsp
     fb4:	sub    rsp,0x40
     fb8:	mov    QWORD PTR [rsp+0x20],rbx
     fbd:	mov    QWORD PTR [rsp+0x28],r12
     fc2:	mov    QWORD PTR [rsp+0x30],r13
     fc7:	mov    r13,rdi
     fca:	mov    QWORD PTR [rsp],rsi
     fce:	mov    r12,rsi
     fd1:	mov    QWORD PTR [rsp+0x8],rdx
     fd6:	mov    rbx,rdx
     fd9:	mov    rsi,r12
     fdc:	mov    rdi,r13
     fdf:	call   fe4 <botlish_fn_15+0x34>
			fe0: R_X86_64_PLT32	rt_str_len-0x4
     fe4:	mov    rcx,rbx
     fe7:	and    rcx,rax
     fea:	mov    rdx,rax
     fed:	test   rcx,0x1
     ff4:	jne    101a <botlish_fn_15+0x6a>
     ffa:	mov    rsi,rbx
     ffd:	mov    rdi,r13
    1000:	call   1005 <botlish_fn_15+0x55>
			1001: R_X86_64_PLT32	rt_int_cmp-0x4
    1005:	mov    ecx,0x2
    100a:	test   rax,rax
    100d:	cmovge rcx,QWORD PTR [rip+0xd3]        # 10e8 <botlish_fn_15+0x138>
    1015:	jmp    102a <botlish_fn_15+0x7a>
    101a:	mov    ecx,0x2
    101f:	cmp    rbx,rdx
    1022:	cmovge rcx,QWORD PTR [rip+0xbe]        # 10e8 <botlish_fn_15+0x138>
    102a:	cmp    rcx,0x6
    102e:	je     10be <botlish_fn_15+0x10e>
    1034:	mov    QWORD PTR [rsp+0x10],0x3
    103d:	test   rbx,0x1
    1044:	je     105c <botlish_fn_15+0xac>
    104a:	mov    rcx,rbx
    104d:	add    rcx,0x2
    1051:	seto   al
    1054:	test   al,al
    1056:	je     106f <botlish_fn_15+0xbf>
    105c:	mov    edx,0x3
    1061:	mov    rsi,rbx
    1064:	mov    rdi,r13
    1067:	call   106c <botlish_fn_15+0xbc>
			1068: R_X86_64_PLT32	rt_int_add-0x4
    106c:	mov    rcx,rax
    106f:	mov    QWORD PTR [rsp+0x10],rcx
    1074:	mov    rdx,rbx
    1077:	mov    rsi,r12
    107a:	mov    rdi,r13
    107d:	call   1082 <botlish_fn_15+0xd2>
			107e: R_X86_64_PLT32	rt_substr-0x4
    1082:	test   rax,rax
    1085:	jne    10a6 <botlish_fn_15+0xf6>
    108b:	xor    rax,rax
    108e:	mov    rbx,QWORD PTR [rsp+0x20]
    1093:	mov    r12,QWORD PTR [rsp+0x28]
    1098:	mov    r13,QWORD PTR [rsp+0x30]
    109d:	add    rsp,0x40
    10a1:	mov    rsp,rbp
    10a4:	pop    rbp
    10a5:	ret
    10a6:	mov    rbx,QWORD PTR [rsp+0x20]
    10ab:	mov    r12,QWORD PTR [rsp+0x28]
    10b0:	mov    r13,QWORD PTR [rsp+0x30]
    10b5:	add    rsp,0x40
    10b9:	mov    rsp,rbp
    10bc:	pop    rbp
    10bd:	ret
    10be:	mov    rdi,r13
    10c1:	mov    rax,QWORD PTR [rdi+0x10]
    10c5:	mov    rax,QWORD PTR [rax+0x8]
    10c9:	mov    rbx,QWORD PTR [rsp+0x20]
    10ce:	mov    r12,QWORD PTR [rsp+0x28]
    10d3:	mov    r13,QWORD PTR [rsp+0x30]
    10d8:	add    rsp,0x40
    10dc:	mov    rsp,rbp
    10df:	pop    rbp
    10e0:	ret
    10e1:	add    BYTE PTR [rax],al
    10e3:	add    BYTE PTR [rax],al
    10e5:	add    BYTE PTR [rax],al
    10e7:	add    BYTE PTR [rsi],al
    10e9:	add    BYTE PTR [rax],al
    10eb:	add    BYTE PTR [rax],al
    10ed:	add    BYTE PTR [rax],al
	...

00000000000010f0 <botlish_entry_15: peek<str, int>>:
    10f0:	push   rbp
    10f1:	mov    rbp,rsp
    10f4:	mov    rsi,QWORD PTR [rdx]
    10f7:	mov    rdx,QWORD PTR [rdx+0x8]
    10fb:	call   1100 <botlish_entry_15+0x10>
			10fc: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    1100:	mov    rsp,rbp
    1103:	pop    rbp
    1104:	ret
    1105:	add    BYTE PTR [rax],al
	...

0000000000001108 <botlish_fn_16: peek<str, int>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	sub    rsp,0x50
    1110:	mov    QWORD PTR [rsp+0x20],rbx
    1115:	mov    QWORD PTR [rsp+0x28],r12
    111a:	mov    QWORD PTR [rsp+0x30],r13
    111f:	mov    QWORD PTR [rsp+0x38],r14
    1124:	mov    QWORD PTR [rsp+0x40],r15
    1129:	mov    r12,rcx
    112c:	mov    r14,rdi
    112f:	mov    QWORD PTR [rsp],rsi
    1133:	mov    r13,rsi
    1136:	mov    QWORD PTR [rsp+0x8],rdx
    113b:	mov    rbx,rdx
    113e:	mov    rsi,r13
    1141:	mov    rdi,r14
    1144:	call   1149 <botlish_fn_16+0x41>
			1145: R_X86_64_PLT32	rt_str_len-0x4
    1149:	mov    rcx,rbx
    114c:	and    rcx,rax
    114f:	mov    rdx,rax
    1152:	test   rcx,0x1
    1159:	jne    117f <botlish_fn_16+0x77>
    115f:	mov    rsi,rbx
    1162:	mov    rdi,r14
    1165:	call   116a <botlish_fn_16+0x62>
			1166: R_X86_64_PLT32	rt_int_cmp-0x4
    116a:	mov    ecx,0x2
    116f:	test   rax,rax
    1172:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1298 <botlish_fn_16+0x190>
    117a:	jmp    118f <botlish_fn_16+0x87>
    117f:	mov    ecx,0x2
    1184:	cmp    rbx,rdx
    1187:	cmovge rcx,QWORD PTR [rip+0x109]        # 1298 <botlish_fn_16+0x190>
    118f:	cmp    rcx,0x6
    1193:	je     1253 <botlish_fn_16+0x14b>
    1199:	mov    QWORD PTR [rsp+0x10],0x3
    11a2:	test   rbx,0x1
    11a9:	je     11cc <botlish_fn_16+0xc4>
    11af:	mov    rax,rbx
    11b2:	add    rax,0x2
    11b6:	seto   cl
    11b9:	test   cl,cl
    11bb:	jne    11cc <botlish_fn_16+0xc4>
    11c1:	mov    rdi,r14
    11c4:	mov    r15,rax
    11c7:	jmp    11e2 <botlish_fn_16+0xda>
    11cc:	mov    edx,0x3
    11d1:	mov    rsi,rbx
    11d4:	mov    rdi,r14
    11d7:	call   11dc <botlish_fn_16+0xd4>
			11d8: R_X86_64_PLT32	rt_int_add-0x4
    11dc:	mov    r15,rax
    11df:	mov    rdi,r14
    11e2:	mov    rdi,r14
    11e5:	mov    rcx,r15
    11e8:	mov    rdx,rbx
    11eb:	mov    rsi,r13
    11ee:	call   11f3 <botlish_fn_16+0xeb>
			11ef: R_X86_64_PLT32	rt_str_region_check-0x4
    11f3:	test   rax,rax
    11f6:	jne    1221 <botlish_fn_16+0x119>
    11fc:	xor    rax,rax
    11ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1204:	mov    r12,QWORD PTR [rsp+0x28]
    1209:	mov    r13,QWORD PTR [rsp+0x30]
    120e:	mov    r14,QWORD PTR [rsp+0x38]
    1213:	mov    r15,QWORD PTR [rsp+0x40]
    1218:	add    rsp,0x50
    121c:	mov    rsp,rbp
    121f:	pop    rbp
    1220:	ret
    1221:	mov    rcx,r12
    1224:	mov    QWORD PTR [rcx],rbx
    1227:	mov    rax,r15
    122a:	mov    QWORD PTR [rcx+0x8],rax
    122e:	mov    rax,r13
    1231:	mov    rbx,QWORD PTR [rsp+0x20]
    1236:	mov    r12,QWORD PTR [rsp+0x28]
    123b:	mov    r13,QWORD PTR [rsp+0x30]
    1240:	mov    r14,QWORD PTR [rsp+0x38]
    1245:	mov    r15,QWORD PTR [rsp+0x40]
    124a:	add    rsp,0x50
    124e:	mov    rsp,rbp
    1251:	pop    rbp
    1252:	ret
    1253:	mov    rcx,r12
    1256:	mov    rdi,r14
    1259:	mov    rax,QWORD PTR [rdi+0x10]
    125d:	mov    rax,QWORD PTR [rax+0x8]
    1261:	mov    QWORD PTR [rcx],0x1
    1268:	mov    QWORD PTR [rcx+0x8],0x1
    1270:	mov    rbx,QWORD PTR [rsp+0x20]
    1275:	mov    r12,QWORD PTR [rsp+0x28]
    127a:	mov    r13,QWORD PTR [rsp+0x30]
    127f:	mov    r14,QWORD PTR [rsp+0x38]
    1284:	mov    r15,QWORD PTR [rsp+0x40]
    1289:	add    rsp,0x50
    128d:	mov    rsp,rbp
    1290:	pop    rbp
    1291:	ret
    1292:	add    BYTE PTR [rax],al
    1294:	add    BYTE PTR [rax],al
    1296:	add    BYTE PTR [rax],al
    1298:	(bad)
    1299:	add    BYTE PTR [rax],al
    129b:	add    BYTE PTR [rax],al
    129d:	add    BYTE PTR [rax],al
	...

00000000000012a0 <botlish_entry_16: peek<str, int>>:
    12a0:	push   rbp
    12a1:	mov    rbp,rsp
    12a4:	ud2

00000000000012a6 <botlish_fn_17: scan_unquoted<str, int, int>>:
    12a6:	push   rbp
    12a7:	mov    rbp,rsp
    12aa:	sub    rsp,0x80
    12b1:	mov    QWORD PTR [rsp+0x50],rbx
    12b6:	mov    QWORD PTR [rsp+0x58],r12
    12bb:	mov    QWORD PTR [rsp+0x60],r13
    12c0:	mov    QWORD PTR [rsp+0x68],r14
    12c5:	mov    QWORD PTR [rsp+0x70],r15
    12ca:	mov    QWORD PTR [rsp+0x30],rdi
    12cf:	mov    QWORD PTR [rsp+0x18],0x0
    12d8:	mov    QWORD PTR [rsp],rsi
    12dc:	mov    r15,rsi
    12df:	mov    QWORD PTR [rsp+0x8],rdx
    12e4:	mov    r14,rdx
    12e7:	mov    QWORD PTR [rsp+0x10],rcx
    12ec:	lea    r13,[rsp+0x20]
    12f1:	mov    QWORD PTR [rsp+0x38],rcx
    12f6:	mov    rcx,r13
    12f9:	mov    rdx,QWORD PTR [rsp+0x38]
    12fe:	mov    rsi,r15
    1301:	mov    rdi,QWORD PTR [rsp+0x30]
    1306:	call   130b <botlish_fn_17+0x65>
			1307: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    130b:	mov    rsi,rax
    130e:	mov    QWORD PTR [rsp+0x40],rax
    1313:	test   rax,rsi
    1316:	je     1470 <botlish_fn_17+0x1ca>
    131c:	mov    rbx,QWORD PTR [rsp+0x20]
    1321:	mov    r12,QWORD PTR [rsp+0x28]
    1326:	mov    rdi,QWORD PTR [rsp+0x30]
    132b:	mov    rcx,QWORD PTR [rdi+0x10]
    132f:	mov    r8,QWORD PTR [rcx+0x8]
    1333:	mov    rcx,r12
    1336:	mov    rdx,rbx
    1339:	mov    rsi,QWORD PTR [rsp+0x40]
    133e:	call   1343 <botlish_fn_17+0x9d>
			133f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1343:	cmp    rax,0x6
    1347:	je     1388 <botlish_fn_17+0xe2>
    134d:	mov    rdi,QWORD PTR [rsp+0x30]
    1352:	mov    rax,QWORD PTR [rdi+0x10]
    1356:	mov    r8,QWORD PTR [rax+0x10]
    135a:	mov    rcx,r12
    135d:	mov    rdx,rbx
    1360:	mov    rsi,QWORD PTR [rsp+0x40]
    1365:	call   136a <botlish_fn_17+0xc4>
			1366: R_X86_64_PLT32	rt_str_region_eq-0x4
    136a:	cmp    rax,0x6
    136e:	je     137e <botlish_fn_17+0xd8>
    1374:	mov    eax,0x2
    1379:	jmp    138d <botlish_fn_17+0xe7>
    137e:	mov    eax,0x6
    1383:	jmp    138d <botlish_fn_17+0xe7>
    1388:	mov    eax,0x6
    138d:	cmp    rax,0x6
    1391:	je     13d2 <botlish_fn_17+0x12c>
    1397:	mov    rdi,QWORD PTR [rsp+0x30]
    139c:	mov    rax,QWORD PTR [rdi+0x10]
    13a0:	mov    r8,QWORD PTR [rax+0x18]
    13a4:	mov    rcx,r12
    13a7:	mov    rdx,rbx
    13aa:	mov    rsi,QWORD PTR [rsp+0x40]
    13af:	call   13b4 <botlish_fn_17+0x10e>
			13b0: R_X86_64_PLT32	rt_str_region_eq-0x4
    13b4:	cmp    rax,0x6
    13b8:	je     13c8 <botlish_fn_17+0x122>
    13be:	mov    eax,0x2
    13c3:	jmp    13d7 <botlish_fn_17+0x131>
    13c8:	mov    eax,0x6
    13cd:	jmp    13d7 <botlish_fn_17+0x131>
    13d2:	mov    eax,0x6
    13d7:	cmp    rax,0x6
    13db:	je     1452 <botlish_fn_17+0x1ac>
    13e1:	mov    QWORD PTR [rsp+0x18],0x3
    13ea:	mov    rsi,QWORD PTR [rsp+0x38]
    13ef:	test   rsi,0x1
    13f6:	je     141d <botlish_fn_17+0x177>
    13fc:	mov    rsi,QWORD PTR [rsp+0x38]
    1401:	mov    rax,rsi
    1404:	add    rax,0x2
    1408:	seto   sil
    140c:	test   sil,sil
    140f:	jne    141d <botlish_fn_17+0x177>
    1415:	mov    rsi,r15
    1418:	jmp    1434 <botlish_fn_17+0x18e>
    141d:	mov    edx,0x3
    1422:	mov    rsi,QWORD PTR [rsp+0x38]
    1427:	mov    rdi,QWORD PTR [rsp+0x30]
    142c:	call   1431 <botlish_fn_17+0x18b>
			142d: R_X86_64_PLT32	rt_int_add-0x4
    1431:	mov    rsi,r15
    1434:	mov    QWORD PTR [rsp],rsi
    1438:	mov    rdx,r14
    143b:	mov    QWORD PTR [rsp+0x8],rdx
    1440:	mov    QWORD PTR [rsp+0x10],rax
    1445:	mov    r15,rsi
    1448:	mov    QWORD PTR [rsp+0x38],rax
    144d:	jmp    12f6 <botlish_fn_17+0x50>
    1452:	mov    rdx,r14
    1455:	mov    rsi,r15
    1458:	mov    rdi,QWORD PTR [rsp+0x30]
    145d:	mov    rcx,QWORD PTR [rsp+0x38]
    1462:	call   1467 <botlish_fn_17+0x1c1>
			1463: R_X86_64_PLT32	rt_substr-0x4
    1467:	test   rax,rax
    146a:	jne    149b <botlish_fn_17+0x1f5>
    1470:	xor    rdx,rdx
    1473:	mov    rax,rdx
    1476:	mov    rbx,QWORD PTR [rsp+0x50]
    147b:	mov    r12,QWORD PTR [rsp+0x58]
    1480:	mov    r13,QWORD PTR [rsp+0x60]
    1485:	mov    r14,QWORD PTR [rsp+0x68]
    148a:	mov    r15,QWORD PTR [rsp+0x70]
    148f:	add    rsp,0x80
    1496:	mov    rsp,rbp
    1499:	pop    rbp
    149a:	ret
    149b:	mov    rdx,QWORD PTR [rsp+0x38]
    14a0:	mov    rbx,QWORD PTR [rsp+0x50]
    14a5:	mov    r12,QWORD PTR [rsp+0x58]
    14aa:	mov    r13,QWORD PTR [rsp+0x60]
    14af:	mov    r14,QWORD PTR [rsp+0x68]
    14b4:	mov    r15,QWORD PTR [rsp+0x70]
    14b9:	add    rsp,0x80
    14c0:	mov    rsp,rbp
    14c3:	pop    rbp
    14c4:	ret

00000000000014c5 <botlish_entry_17: scan_unquoted<str, int, int>>:
    14c5:	push   rbp
    14c6:	mov    rbp,rsp
    14c9:	ud2

00000000000014cb <botlish_fn_18: scan_quoted<str, int, str>>:
    14cb:	push   rbp
    14cc:	mov    rbp,rsp
    14cf:	sub    rsp,0xd0
    14d6:	mov    QWORD PTR [rsp+0xa0],rbx
    14de:	mov    QWORD PTR [rsp+0xa8],r12
    14e6:	mov    QWORD PTR [rsp+0xb0],r13
    14ee:	mov    QWORD PTR [rsp+0xb8],r14
    14f6:	mov    QWORD PTR [rsp+0xc0],r15
    14fe:	mov    r15,rdi
    1501:	mov    QWORD PTR [rsp+0x18],0x0
    150a:	mov    QWORD PTR [rsp+0x20],0x0
    1513:	mov    QWORD PTR [rsp],rsi
    1517:	mov    QWORD PTR [rsp+0x8],rdx
    151c:	mov    QWORD PTR [rsp+0x10],rcx
    1521:	mov    r13,rcx
    1524:	lea    r14,[rsp+0x68]
    1529:	lea    rbx,[rsp+0x28]
    152e:	mov    r12,rsi
    1531:	mov    QWORD PTR [rsp+0x88],rdx
    1539:	mov    rdx,QWORD PTR [rsp+0x88]
    1541:	mov    rsi,r12
    1544:	mov    rdi,r15
    1547:	call   154c <botlish_fn_18+0x81>
			1548: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    154c:	test   rax,rax
    154f:	je     1853 <botlish_fn_18+0x388>
    1555:	mov    QWORD PTR [rsp+0x18],rax
    155a:	mov    rdi,r15
    155d:	mov    QWORD PTR [rsp+0x90],rax
    1565:	mov    rsi,QWORD PTR [rdi+0x10]
    1569:	mov    rsi,QWORD PTR [rsi+0x20]
    156d:	mov    edx,0x1
    1572:	mov    ecx,0x3
    1577:	mov    r8,QWORD PTR [rsp+0x90]
    157f:	call   1584 <botlish_fn_18+0xb9>
			1580: R_X86_64_PLT32	rt_str_region_eq-0x4
    1584:	cmp    rax,0x6
    1588:	je     1648 <botlish_fn_18+0x17d>
    158e:	mov    QWORD PTR [rsp+0x20],0x3
    1597:	mov    rsi,QWORD PTR [rsp+0x88]
    159f:	test   rsi,0x1
    15a6:	je     15c8 <botlish_fn_18+0xfd>
    15ac:	mov    r9,rsi
    15af:	add    r9,0x2
    15b3:	seto   r11b
    15b7:	test   r11b,r11b
    15ba:	jne    15c8 <botlish_fn_18+0xfd>
    15c0:	mov    rsi,r9
    15c3:	jmp    15d8 <botlish_fn_18+0x10d>
    15c8:	mov    edx,0x3
    15cd:	mov    rdi,r15
    15d0:	call   15d5 <botlish_fn_18+0x10a>
			15d1: R_X86_64_PLT32	rt_int_add-0x4
    15d5:	mov    rsi,rax
    15d8:	mov    QWORD PTR [rsp+0x8],rsi
    15dd:	mov    QWORD PTR [rsp+0x88],rsi
    15e5:	mov    QWORD PTR [rsp+0x68],0x0
    15ee:	mov    QWORD PTR [rsp+0x70],r13
    15f3:	mov    QWORD PTR [rsp+0x78],0x0
    15fc:	mov    rax,QWORD PTR [rsp+0x90]
    1604:	mov    QWORD PTR [rsp+0x80],rax
    160c:	mov    esi,0x2
    1611:	mov    edx,0x4
    1616:	mov    rcx,r14
    1619:	mov    rdi,r15
    161c:	call   1621 <botlish_fn_18+0x156>
			161d: R_X86_64_PLT32	rt_construct-0x4
    1621:	test   rax,rax
    1624:	je     1853 <botlish_fn_18+0x388>
    162a:	mov    QWORD PTR [rsp],r12
    162e:	mov    rsi,QWORD PTR [rsp+0x88]
    1636:	mov    QWORD PTR [rsp+0x8],rsi
    163b:	mov    QWORD PTR [rsp+0x10],rax
    1640:	mov    r13,rax
    1643:	jmp    1539 <botlish_fn_18+0x6e>
    1648:	mov    QWORD PTR [rsp+0x18],0x3
    1651:	mov    rsi,QWORD PTR [rsp+0x88]
    1659:	test   rsi,0x1
    1660:	je     1680 <botlish_fn_18+0x1b5>
    1666:	mov    rsi,QWORD PTR [rsp+0x88]
    166e:	mov    rdx,rsi
    1671:	add    rdx,0x2
    1675:	seto   al
    1678:	test   al,al
    167a:	je     1698 <botlish_fn_18+0x1cd>
    1680:	mov    edx,0x3
    1685:	mov    rsi,QWORD PTR [rsp+0x88]
    168d:	mov    rdi,r15
    1690:	call   1695 <botlish_fn_18+0x1ca>
			1691: R_X86_64_PLT32	rt_int_add-0x4
    1695:	mov    rdx,rax
    1698:	mov    QWORD PTR [rsp+0x18],rdx
    169d:	mov    rcx,rbx
    16a0:	mov    rsi,r12
    16a3:	mov    rdi,r15
    16a6:	call   16ab <botlish_fn_18+0x1e0>
			16a7: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    16ab:	test   rax,rax
    16ae:	mov    rsi,rax
    16b1:	je     1853 <botlish_fn_18+0x388>
    16b7:	mov    rdx,QWORD PTR [rsp+0x28]
    16bc:	mov    rcx,QWORD PTR [rsp+0x30]
    16c1:	mov    rdi,r15
    16c4:	mov    rax,QWORD PTR [rdi+0x10]
    16c8:	mov    r8,QWORD PTR [rax+0x20]
    16cc:	call   16d1 <botlish_fn_18+0x206>
			16cd: R_X86_64_PLT32	rt_str_region_eq-0x4
    16d1:	cmp    rax,0x6
    16d5:	je     179d <botlish_fn_18+0x2d2>
    16db:	xor    rsi,rsi
    16de:	lea    rcx,[rsp+0x58]
    16e3:	mov    QWORD PTR [rsp+0x58],0x0
    16ec:	mov    QWORD PTR [rsp+0x60],r13
    16f1:	mov    edx,0x2
    16f6:	mov    rdi,r15
    16f9:	call   16fe <botlish_fn_18+0x233>
			16fa: R_X86_64_PLT32	rt_construct-0x4
    16fe:	test   rax,rax
    1701:	je     1853 <botlish_fn_18+0x388>
    1707:	mov    QWORD PTR [rsp],rax
    170b:	mov    rbx,rax
    170e:	mov    QWORD PTR [rsp+0x10],0x3
    1717:	mov    rsi,QWORD PTR [rsp+0x88]
    171f:	test   rsi,0x1
    1726:	je     174e <botlish_fn_18+0x283>
    172c:	mov    rsi,QWORD PTR [rsp+0x88]
    1734:	mov    rdx,rsi
    1737:	add    rdx,0x2
    173b:	seto   al
    173e:	test   al,al
    1740:	jne    174e <botlish_fn_18+0x283>
    1746:	mov    rax,rbx
    1749:	jmp    1769 <botlish_fn_18+0x29e>
    174e:	mov    edx,0x3
    1753:	mov    rsi,QWORD PTR [rsp+0x88]
    175b:	mov    rdi,r15
    175e:	call   1763 <botlish_fn_18+0x298>
			175f: R_X86_64_PLT32	rt_int_add-0x4
    1763:	mov    rdx,rax
    1766:	mov    rax,rbx
    1769:	mov    rbx,QWORD PTR [rsp+0xa0]
    1771:	mov    r12,QWORD PTR [rsp+0xa8]
    1779:	mov    r13,QWORD PTR [rsp+0xb0]
    1781:	mov    r14,QWORD PTR [rsp+0xb8]
    1789:	mov    r15,QWORD PTR [rsp+0xc0]
    1791:	add    rsp,0xd0
    1798:	mov    rsp,rbp
    179b:	pop    rbp
    179c:	ret
    179d:	mov    QWORD PTR [rsp+0x18],0x5
    17a6:	mov    rsi,QWORD PTR [rsp+0x88]
    17ae:	test   rsi,0x1
    17b5:	je     17e5 <botlish_fn_18+0x31a>
    17bb:	mov    rsi,QWORD PTR [rsp+0x88]
    17c3:	mov    rax,rsi
    17c6:	add    rax,0x4
    17ca:	seto   cl
    17cd:	test   cl,cl
    17cf:	jne    17e5 <botlish_fn_18+0x31a>
    17d5:	mov    rsi,rax
    17d8:	mov    QWORD PTR [rsp+0x88],rax
    17e0:	jmp    1805 <botlish_fn_18+0x33a>
    17e5:	mov    edx,0x5
    17ea:	mov    rsi,QWORD PTR [rsp+0x88]
    17f2:	mov    rdi,r15
    17f5:	call   17fa <botlish_fn_18+0x32f>
			17f6: R_X86_64_PLT32	rt_int_add-0x4
    17fa:	mov    rsi,rax
    17fd:	mov    QWORD PTR [rsp+0x88],rax
    1805:	mov    QWORD PTR [rsp+0x8],rsi
    180a:	mov    rdi,r15
    180d:	mov    rsi,QWORD PTR [rdi+0x10]
    1811:	mov    rsi,QWORD PTR [rsi+0x20]
    1815:	mov    QWORD PTR [rsp+0x18],rsi
    181a:	lea    rcx,[rsp+0x38]
    181f:	mov    QWORD PTR [rsp+0x38],0x0
    1828:	mov    QWORD PTR [rsp+0x40],r13
    182d:	mov    QWORD PTR [rsp+0x48],0x0
    1836:	mov    QWORD PTR [rsp+0x50],rsi
    183b:	mov    esi,0x2
    1840:	mov    edx,0x4
    1845:	call   184a <botlish_fn_18+0x37f>
			1846: R_X86_64_PLT32	rt_construct-0x4
    184a:	test   rax,rax
    184d:	jne    188d <botlish_fn_18+0x3c2>
    1853:	xor    rdx,rdx
    1856:	mov    rax,rdx
    1859:	mov    rbx,QWORD PTR [rsp+0xa0]
    1861:	mov    r12,QWORD PTR [rsp+0xa8]
    1869:	mov    r13,QWORD PTR [rsp+0xb0]
    1871:	mov    r14,QWORD PTR [rsp+0xb8]
    1879:	mov    r15,QWORD PTR [rsp+0xc0]
    1881:	add    rsp,0xd0
    1888:	mov    rsp,rbp
    188b:	pop    rbp
    188c:	ret
    188d:	mov    QWORD PTR [rsp],r12
    1891:	mov    rsi,QWORD PTR [rsp+0x88]
    1899:	mov    QWORD PTR [rsp+0x8],rsi
    189e:	mov    QWORD PTR [rsp+0x10],rax
    18a3:	mov    r13,rax
    18a6:	jmp    1539 <botlish_fn_18+0x6e>

00000000000018ab <botlish_entry_18: scan_quoted<str, int, str>>:
    18ab:	push   rbp
    18ac:	mov    rbp,rsp
    18af:	ud2

00000000000018b1 <botlish_fn_19: scan_field<str, int>>:
    18b1:	push   rbp
    18b2:	mov    rbp,rsp
    18b5:	sub    rsp,0x50
    18b9:	mov    QWORD PTR [rsp+0x30],rbx
    18be:	mov    QWORD PTR [rsp+0x38],r12
    18c3:	mov    QWORD PTR [rsp+0x40],r13
    18c8:	mov    r12,rdi
    18cb:	mov    r13,rdx
    18ce:	mov    QWORD PTR [rsp+0x10],0x0
    18d7:	mov    QWORD PTR [rsp],rsi
    18db:	mov    rbx,rsi
    18de:	mov    QWORD PTR [rsp+0x8],rdx
    18e3:	lea    rcx,[rsp+0x18]
    18e8:	mov    rdx,r13
    18eb:	mov    rsi,rbx
    18ee:	mov    rdi,r12
    18f1:	call   18f6 <botlish_fn_19+0x45>
			18f2: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    18f6:	test   rax,rax
    18f9:	mov    rsi,rax
    18fc:	je     19c7 <botlish_fn_19+0x116>
    1902:	mov    rdx,QWORD PTR [rsp+0x18]
    1907:	mov    rcx,QWORD PTR [rsp+0x20]
    190c:	mov    rdi,r12
    190f:	mov    rax,QWORD PTR [rdi+0x10]
    1913:	mov    r8,QWORD PTR [rax+0x20]
    1917:	call   191c <botlish_fn_19+0x6b>
			1918: R_X86_64_PLT32	rt_str_region_eq-0x4
    191c:	cmp    rax,0x6
    1920:	je     1958 <botlish_fn_19+0xa7>
    1926:	mov    rcx,r13
    1929:	mov    rsi,rbx
    192c:	mov    rdi,r12
    192f:	mov    rdx,rcx
    1932:	call   1937 <botlish_fn_19+0x86>
			1933: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    1937:	test   rax,rax
    193a:	je     19c7 <botlish_fn_19+0x116>
    1940:	mov    rbx,QWORD PTR [rsp+0x30]
    1945:	mov    r12,QWORD PTR [rsp+0x38]
    194a:	mov    r13,QWORD PTR [rsp+0x40]
    194f:	add    rsp,0x50
    1953:	mov    rsp,rbp
    1956:	pop    rbp
    1957:	ret
    1958:	mov    rcx,r13
    195b:	mov    QWORD PTR [rsp+0x10],0x3
    1964:	test   rcx,0x1
    196b:	jne    1979 <botlish_fn_19+0xc8>
    1971:	mov    r13,rcx
    1974:	jmp    198e <botlish_fn_19+0xdd>
    1979:	mov    rdx,rcx
    197c:	add    rdx,0x2
    1980:	mov    r13,rcx
    1983:	seto   al
    1986:	test   al,al
    1988:	je     19a1 <botlish_fn_19+0xf0>
    198e:	mov    edx,0x3
    1993:	mov    rsi,r13
    1996:	mov    rdi,r12
    1999:	call   199e <botlish_fn_19+0xed>
			199a: R_X86_64_PLT32	rt_int_add-0x4
    199e:	mov    rdx,rax
    19a1:	mov    QWORD PTR [rsp+0x8],rdx
    19a6:	mov    rdi,r12
    19a9:	mov    rax,QWORD PTR [rdi+0x10]
    19ad:	mov    rcx,QWORD PTR [rax+0x8]
    19b1:	mov    QWORD PTR [rsp+0x10],rcx
    19b6:	mov    rsi,rbx
    19b9:	call   19be <botlish_fn_19+0x10d>
			19ba: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    19be:	test   rax,rax
    19c1:	jne    19e5 <botlish_fn_19+0x134>
    19c7:	xor    rdx,rdx
    19ca:	mov    rax,rdx
    19cd:	mov    rbx,QWORD PTR [rsp+0x30]
    19d2:	mov    r12,QWORD PTR [rsp+0x38]
    19d7:	mov    r13,QWORD PTR [rsp+0x40]
    19dc:	add    rsp,0x50
    19e0:	mov    rsp,rbp
    19e3:	pop    rbp
    19e4:	ret
    19e5:	mov    rbx,QWORD PTR [rsp+0x30]
    19ea:	mov    r12,QWORD PTR [rsp+0x38]
    19ef:	mov    r13,QWORD PTR [rsp+0x40]
    19f4:	add    rsp,0x50
    19f8:	mov    rsp,rbp
    19fb:	pop    rbp
    19fc:	ret

00000000000019fd <botlish_entry_19: scan_field<str, int>>:
    19fd:	push   rbp
    19fe:	mov    rbp,rsp
    1a01:	ud2

0000000000001a03 <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    1a03:	push   rbp
    1a04:	mov    rbp,rsp
    1a07:	sub    rsp,0x90
    1a0e:	mov    QWORD PTR [rsp+0x60],rbx
    1a13:	mov    QWORD PTR [rsp+0x68],r12
    1a18:	mov    QWORD PTR [rsp+0x70],r13
    1a1d:	mov    QWORD PTR [rsp+0x78],r14
    1a22:	mov    QWORD PTR [rsp+0x80],r15
    1a2a:	mov    r15,rdi
    1a2d:	mov    QWORD PTR [rsp+0x20],0x0
    1a36:	mov    QWORD PTR [rsp],rsi
    1a3a:	mov    QWORD PTR [rsp+0x8],rdx
    1a3f:	mov    QWORD PTR [rsp+0x10],rcx
    1a44:	mov    QWORD PTR [rsp+0x18],r8
    1a49:	lea    r12,[rsp+0x28]
    1a4e:	mov    rbx,rsi
    1a51:	mov    QWORD PTR [rsp+0x38],rdx
    1a56:	mov    QWORD PTR [rsp+0x40],rcx
    1a5b:	mov    QWORD PTR [rsp+0x48],r8
    1a60:	mov    rcx,r12
    1a63:	mov    rdx,QWORD PTR [rsp+0x38]
    1a68:	mov    rsi,rbx
    1a6b:	mov    rdi,r15
    1a6e:	call   1a73 <botlish_fn_20+0x70>
			1a6f: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1a73:	test   rax,rax
    1a76:	mov    QWORD PTR [rsp+0x50],rax
    1a7b:	je     1c3f <botlish_fn_20+0x23c>
    1a81:	mov    r14,QWORD PTR [rsp+0x28]
    1a86:	mov    r13,QWORD PTR [rsp+0x30]
    1a8b:	mov    rdi,r15
    1a8e:	mov    rcx,QWORD PTR [rdi+0x10]
    1a92:	mov    r8,QWORD PTR [rcx+0x10]
    1a96:	mov    rcx,r13
    1a99:	mov    rdx,r14
    1a9c:	mov    rsi,QWORD PTR [rsp+0x50]
    1aa1:	call   1aa6 <botlish_fn_20+0xa3>
			1aa2: R_X86_64_PLT32	rt_str_region_eq-0x4
    1aa6:	cmp    rax,0x6
    1aaa:	je     1bb8 <botlish_fn_20+0x1b5>
    1ab0:	mov    rdi,r15
    1ab3:	mov    rax,QWORD PTR [rdi+0x10]
    1ab7:	mov    r8,QWORD PTR [rax+0x18]
    1abb:	mov    rcx,r13
    1abe:	mov    rdx,r14
    1ac1:	mov    rsi,QWORD PTR [rsp+0x50]
    1ac6:	call   1acb <botlish_fn_20+0xc8>
			1ac7: R_X86_64_PLT32	rt_str_region_eq-0x4
    1acb:	cmp    rax,0x6
    1acf:	je     1b1d <botlish_fn_20+0x11a>
    1ad5:	mov    rdx,QWORD PTR [rsp+0x48]
    1ada:	mov    rsi,QWORD PTR [rsp+0x40]
    1adf:	mov    rdi,r15
    1ae2:	call   1ae7 <botlish_fn_20+0xe4>
			1ae3: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1ae7:	test   rax,rax
    1aea:	je     1c3f <botlish_fn_20+0x23c>
    1af0:	mov    rdx,QWORD PTR [rsp+0x38]
    1af5:	mov    rbx,QWORD PTR [rsp+0x60]
    1afa:	mov    r12,QWORD PTR [rsp+0x68]
    1aff:	mov    r13,QWORD PTR [rsp+0x70]
    1b04:	mov    r14,QWORD PTR [rsp+0x78]
    1b09:	mov    r15,QWORD PTR [rsp+0x80]
    1b11:	add    rsp,0x90
    1b18:	mov    rsp,rbp
    1b1b:	pop    rbp
    1b1c:	ret
    1b1d:	mov    rdx,QWORD PTR [rsp+0x48]
    1b22:	mov    rsi,QWORD PTR [rsp+0x40]
    1b27:	mov    rdi,r15
    1b2a:	call   1b2f <botlish_fn_20+0x12c>
			1b2b: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b2f:	test   rax,rax
    1b32:	je     1c3f <botlish_fn_20+0x23c>
    1b38:	mov    QWORD PTR [rsp],rax
    1b3c:	mov    rbx,rax
    1b3f:	mov    QWORD PTR [rsp+0x10],0x3
    1b48:	mov    rdx,QWORD PTR [rsp+0x38]
    1b4d:	test   rdx,0x1
    1b54:	je     1b78 <botlish_fn_20+0x175>
    1b5a:	mov    rdx,QWORD PTR [rsp+0x38]
    1b5f:	add    rdx,0x2
    1b63:	seto   sil
    1b67:	test   sil,sil
    1b6a:	jne    1b78 <botlish_fn_20+0x175>
    1b70:	mov    rax,rbx
    1b73:	jmp    1b90 <botlish_fn_20+0x18d>
    1b78:	mov    edx,0x3
    1b7d:	mov    rsi,QWORD PTR [rsp+0x38]
    1b82:	mov    rdi,r15
    1b85:	call   1b8a <botlish_fn_20+0x187>
			1b86: R_X86_64_PLT32	rt_int_add-0x4
    1b8a:	mov    rdx,rax
    1b8d:	mov    rax,rbx
    1b90:	mov    rbx,QWORD PTR [rsp+0x60]
    1b95:	mov    r12,QWORD PTR [rsp+0x68]
    1b9a:	mov    r13,QWORD PTR [rsp+0x70]
    1b9f:	mov    r14,QWORD PTR [rsp+0x78]
    1ba4:	mov    r15,QWORD PTR [rsp+0x80]
    1bac:	add    rsp,0x90
    1bb3:	mov    rsp,rbp
    1bb6:	pop    rbp
    1bb7:	ret
    1bb8:	mov    rsi,QWORD PTR [rsp+0x38]
    1bbd:	mov    edx,0x3
    1bc2:	mov    r13,rdx
    1bc5:	mov    QWORD PTR [rsp+0x20],0x3
    1bce:	test   rsi,0x1
    1bd5:	je     1bed <botlish_fn_20+0x1ea>
    1bdb:	mov    rdx,rsi
    1bde:	add    rdx,0x2
    1be2:	seto   al
    1be5:	test   al,al
    1be7:	je     1bfb <botlish_fn_20+0x1f8>
    1bed:	mov    rdx,r13
    1bf0:	mov    rdi,r15
    1bf3:	call   1bf8 <botlish_fn_20+0x1f5>
			1bf4: R_X86_64_PLT32	rt_int_add-0x4
    1bf8:	mov    rdx,rax
    1bfb:	mov    QWORD PTR [rsp+0x8],rdx
    1c00:	mov    rsi,rbx
    1c03:	mov    rdi,r15
    1c06:	call   1c0b <botlish_fn_20+0x208>
			1c07: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1c0b:	test   rax,rax
    1c0e:	je     1c3f <botlish_fn_20+0x23c>
    1c14:	mov    QWORD PTR [rsp+0x8],rax
    1c19:	mov    rcx,rax
    1c1c:	mov    QWORD PTR [rsp+0x20],rdx
    1c21:	mov    rsi,QWORD PTR [rsp+0x40]
    1c26:	mov    r14,rdx
    1c29:	mov    rdx,QWORD PTR [rsp+0x48]
    1c2e:	mov    rdi,r15
    1c31:	call   1c36 <botlish_fn_20+0x233>
			1c32: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1c36:	test   rax,rax
    1c39:	jne    1c6d <botlish_fn_20+0x26a>
    1c3f:	xor    rdx,rdx
    1c42:	mov    rax,rdx
    1c45:	mov    rbx,QWORD PTR [rsp+0x60]
    1c4a:	mov    r12,QWORD PTR [rsp+0x68]
    1c4f:	mov    r13,QWORD PTR [rsp+0x70]
    1c54:	mov    r14,QWORD PTR [rsp+0x78]
    1c59:	mov    r15,QWORD PTR [rsp+0x80]
    1c61:	add    rsp,0x90
    1c68:	mov    rsp,rbp
    1c6b:	pop    rbp
    1c6c:	ret
    1c6d:	mov    QWORD PTR [rsp+0x8],rax
    1c72:	mov    QWORD PTR [rsp+0x38],rax
    1c77:	mov    QWORD PTR [rsp+0x10],0x3
    1c80:	mov    rdx,QWORD PTR [rsp+0x48]
    1c85:	test   rdx,0x1
    1c8c:	jne    1c9f <botlish_fn_20+0x29c>
    1c92:	mov    rdx,r13
    1c95:	mov    rsi,QWORD PTR [rsp+0x48]
    1c9a:	jmp    1cbe <botlish_fn_20+0x2bb>
    1c9f:	mov    rdx,QWORD PTR [rsp+0x48]
    1ca4:	mov    rax,rdx
    1ca7:	add    rax,0x2
    1cab:	seto   cl
    1cae:	test   cl,cl
    1cb0:	je     1cc6 <botlish_fn_20+0x2c3>
    1cb6:	mov    rdx,r13
    1cb9:	mov    rsi,QWORD PTR [rsp+0x48]
    1cbe:	mov    rdi,r15
    1cc1:	call   1cc6 <botlish_fn_20+0x2c3>
			1cc2: R_X86_64_PLT32	rt_int_add-0x4
    1cc6:	mov    QWORD PTR [rsp],rbx
    1cca:	mov    rdx,r14
    1ccd:	mov    QWORD PTR [rsp+0x8],rdx
    1cd2:	mov    rcx,QWORD PTR [rsp+0x38]
    1cd7:	mov    QWORD PTR [rsp+0x10],rcx
    1cdc:	mov    QWORD PTR [rsp+0x18],rax
    1ce1:	mov    QWORD PTR [rsp+0x38],rdx
    1ce6:	mov    QWORD PTR [rsp+0x40],rcx
    1ceb:	mov    QWORD PTR [rsp+0x48],rax
    1cf0:	jmp    1a60 <botlish_fn_20+0x5d>

0000000000001cf5 <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1cf5:	push   rbp
    1cf6:	mov    rbp,rsp
    1cf9:	ud2

0000000000001cfb <botlish_fn_21: scan_record<str, int>>:
    1cfb:	push   rbp
    1cfc:	mov    rbp,rsp
    1cff:	sub    rsp,0x40
    1d03:	mov    QWORD PTR [rsp+0x20],rbx
    1d08:	mov    QWORD PTR [rsp+0x28],r12
    1d0d:	mov    QWORD PTR [rsp+0x30],r14
    1d12:	mov    r14,rdi
    1d15:	mov    QWORD PTR [rsp+0x10],0x0
    1d1e:	mov    QWORD PTR [rsp+0x18],0x0
    1d27:	mov    QWORD PTR [rsp],rsi
    1d2b:	mov    r12,rsi
    1d2e:	mov    QWORD PTR [rsp+0x8],rdx
    1d33:	mov    rsi,r12
    1d36:	mov    rdi,r14
    1d39:	call   1d3e <botlish_fn_21+0x43>
			1d3a: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1d3e:	test   rax,rax
    1d41:	je     1d96 <botlish_fn_21+0x9b>
    1d47:	mov    QWORD PTR [rsp+0x8],rax
    1d4c:	mov    rsi,rax
    1d4f:	mov    QWORD PTR [rsp+0x10],rdx
    1d54:	mov    rbx,rdx
    1d57:	mov    rdi,r14
    1d5a:	call   1d5f <botlish_fn_21+0x64>
			1d5b: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1d5f:	test   rax,rax
    1d62:	je     1d96 <botlish_fn_21+0x9b>
    1d68:	mov    QWORD PTR [rsp+0x8],rax
    1d6d:	mov    rcx,rax
    1d70:	mov    r8d,0x3
    1d76:	mov    QWORD PTR [rsp+0x18],0x3
    1d7f:	mov    rdx,rbx
    1d82:	mov    rsi,r12
    1d85:	mov    rdi,r14
    1d88:	call   1d8d <botlish_fn_21+0x92>
			1d89: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1d8d:	test   rax,rax
    1d90:	jne    1db4 <botlish_fn_21+0xb9>
    1d96:	xor    rdx,rdx
    1d99:	mov    rax,rdx
    1d9c:	mov    rbx,QWORD PTR [rsp+0x20]
    1da1:	mov    r12,QWORD PTR [rsp+0x28]
    1da6:	mov    r14,QWORD PTR [rsp+0x30]
    1dab:	add    rsp,0x40
    1daf:	mov    rsp,rbp
    1db2:	pop    rbp
    1db3:	ret
    1db4:	mov    rbx,QWORD PTR [rsp+0x20]
    1db9:	mov    r12,QWORD PTR [rsp+0x28]
    1dbe:	mov    r14,QWORD PTR [rsp+0x30]
    1dc3:	add    rsp,0x40
    1dc7:	mov    rsp,rbp
    1dca:	pop    rbp
    1dcb:	ret

0000000000001dcc <botlish_entry_21: scan_record<str, int>>:
    1dcc:	push   rbp
    1dcd:	mov    rbp,rsp
    1dd0:	ud2
    1dd2:	add    BYTE PTR [rax],al
    1dd4:	add    BYTE PTR [rax],al
	...

0000000000001dd8 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1dd8:	push   rbp
    1dd9:	mov    rbp,rsp
    1ddc:	sub    rsp,0x60
    1de0:	mov    QWORD PTR [rsp+0x30],rbx
    1de5:	mov    QWORD PTR [rsp+0x38],r12
    1dea:	mov    QWORD PTR [rsp+0x40],r13
    1def:	mov    QWORD PTR [rsp+0x48],r14
    1df4:	mov    QWORD PTR [rsp+0x50],r15
    1df9:	mov    r13,rdi
    1dfc:	mov    QWORD PTR [rsp+0x20],0x0
    1e05:	mov    QWORD PTR [rsp],rsi
    1e09:	mov    QWORD PTR [rsp+0x8],rdx
    1e0e:	mov    r12,rdx
    1e11:	mov    QWORD PTR [rsp+0x10],rcx
    1e16:	mov    QWORD PTR [rsp+0x18],r8
    1e1b:	mov    rbx,rsi
    1e1e:	mov    r14,r8
    1e21:	mov    r15,rcx
    1e24:	mov    rsi,rbx
    1e27:	mov    rdi,r13
    1e2a:	call   1e2f <botlish_fn_22+0x57>
			1e2b: R_X86_64_PLT32	rt_str_len-0x4
    1e2f:	mov    rcx,r12
    1e32:	and    rcx,rax
    1e35:	mov    rdx,rax
    1e38:	test   rcx,0x1
    1e3f:	jne    1e65 <botlish_fn_22+0x8d>
    1e45:	mov    rsi,r12
    1e48:	mov    rdi,r13
    1e4b:	call   1e50 <botlish_fn_22+0x78>
			1e4c: R_X86_64_PLT32	rt_int_cmp-0x4
    1e50:	mov    ecx,0x2
    1e55:	test   rax,rax
    1e58:	cmovge rcx,QWORD PTR [rip+0x128]        # 1f88 <botlish_fn_22+0x1b0>
    1e60:	jmp    1e75 <botlish_fn_22+0x9d>
    1e65:	mov    ecx,0x2
    1e6a:	cmp    r12,rdx
    1e6d:	cmovge rcx,QWORD PTR [rip+0x113]        # 1f88 <botlish_fn_22+0x1b0>
    1e75:	cmp    rcx,0x6
    1e79:	je     1f24 <botlish_fn_22+0x14c>
    1e7f:	mov    rdx,r12
    1e82:	mov    rsi,rbx
    1e85:	mov    rdi,r13
    1e88:	call   1e8d <botlish_fn_22+0xb5>
			1e89: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1e8d:	test   rax,rax
    1e90:	je     1f3b <botlish_fn_22+0x163>
    1e96:	mov    QWORD PTR [rsp+0x8],rax
    1e9b:	mov    rcx,rax
    1e9e:	mov    QWORD PTR [rsp+0x20],rdx
    1ea3:	mov    rsi,r15
    1ea6:	mov    r12,rdx
    1ea9:	mov    rdx,r14
    1eac:	mov    rdi,r13
    1eaf:	call   1eb4 <botlish_fn_22+0xdc>
			1eb0: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1eb4:	test   rax,rax
    1eb7:	je     1f3b <botlish_fn_22+0x163>
    1ebd:	mov    QWORD PTR [rsp+0x8],rax
    1ec2:	mov    r15,rax
    1ec5:	mov    QWORD PTR [rsp+0x10],0x3
    1ece:	mov    rsi,r14
    1ed1:	test   rsi,0x1
    1ed8:	je     1ef3 <botlish_fn_22+0x11b>
    1ede:	mov    rsi,r14
    1ee1:	mov    rax,rsi
    1ee4:	add    rax,0x2
    1ee8:	seto   cl
    1eeb:	test   cl,cl
    1eed:	je     1f03 <botlish_fn_22+0x12b>
    1ef3:	mov    edx,0x3
    1ef8:	mov    rsi,r14
    1efb:	mov    rdi,r13
    1efe:	call   1f03 <botlish_fn_22+0x12b>
			1eff: R_X86_64_PLT32	rt_int_add-0x4
    1f03:	mov    QWORD PTR [rsp],rbx
    1f07:	mov    rdx,r12
    1f0a:	mov    QWORD PTR [rsp+0x8],rdx
    1f0f:	mov    rcx,r15
    1f12:	mov    QWORD PTR [rsp+0x10],rcx
    1f17:	mov    QWORD PTR [rsp+0x18],rax
    1f1c:	mov    r14,rax
    1f1f:	jmp    1e24 <botlish_fn_22+0x4c>
    1f24:	mov    rdx,r14
    1f27:	mov    rsi,r15
    1f2a:	mov    rdi,r13
    1f2d:	call   1f32 <botlish_fn_22+0x15a>
			1f2e: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1f32:	test   rax,rax
    1f35:	jne    1f60 <botlish_fn_22+0x188>
    1f3b:	xor    rax,rax
    1f3e:	mov    rbx,QWORD PTR [rsp+0x30]
    1f43:	mov    r12,QWORD PTR [rsp+0x38]
    1f48:	mov    r13,QWORD PTR [rsp+0x40]
    1f4d:	mov    r14,QWORD PTR [rsp+0x48]
    1f52:	mov    r15,QWORD PTR [rsp+0x50]
    1f57:	add    rsp,0x60
    1f5b:	mov    rsp,rbp
    1f5e:	pop    rbp
    1f5f:	ret
    1f60:	mov    rbx,QWORD PTR [rsp+0x30]
    1f65:	mov    r12,QWORD PTR [rsp+0x38]
    1f6a:	mov    r13,QWORD PTR [rsp+0x40]
    1f6f:	mov    r14,QWORD PTR [rsp+0x48]
    1f74:	mov    r15,QWORD PTR [rsp+0x50]
    1f79:	add    rsp,0x60
    1f7d:	mov    rsp,rbp
    1f80:	pop    rbp
    1f81:	ret
    1f82:	add    BYTE PTR [rax],al
    1f84:	add    BYTE PTR [rax],al
    1f86:	add    BYTE PTR [rax],al
    1f88:	(bad)
    1f89:	add    BYTE PTR [rax],al
    1f8b:	add    BYTE PTR [rax],al
    1f8d:	add    BYTE PTR [rax],al
	...

0000000000001f90 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    1f90:	push   rbp
    1f91:	mov    rbp,rsp
    1f94:	mov    rsi,QWORD PTR [rdx]
    1f97:	mov    r9,QWORD PTR [rdx+0x8]
    1f9b:	mov    rcx,QWORD PTR [rdx+0x10]
    1f9f:	mov    r8,QWORD PTR [rdx+0x18]
    1fa3:	mov    rdx,r9
    1fa6:	call   1fab <botlish_entry_22+0x1b>
			1fa7: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    1fab:	mov    rsp,rbp
    1fae:	pop    rbp
    1faf:	ret

0000000000001fb0 <botlish_fn_23: csv_parse<str>>:
    1fb0:	push   rbp
    1fb1:	mov    rbp,rsp
    1fb4:	sub    rsp,0x40
    1fb8:	mov    QWORD PTR [rsp+0x20],rbx
    1fbd:	mov    QWORD PTR [rsp+0x28],r12
    1fc2:	mov    QWORD PTR [rsp+0x30],r13
    1fc7:	mov    rbx,rdi
    1fca:	mov    QWORD PTR [rsp+0x8],0x0
    1fd3:	mov    QWORD PTR [rsp+0x10],0x0
    1fdc:	mov    QWORD PTR [rsp+0x18],0x0
    1fe5:	mov    QWORD PTR [rsp],rsi
    1fe9:	mov    r12,rsi
    1fec:	mov    rsi,r12
    1fef:	mov    rdi,rbx
    1ff2:	call   1ff7 <botlish_fn_23+0x47>
			1ff3: R_X86_64_PLT32	rt_str_len-0x4
    1ff7:	sar    rax,1
    1ffa:	test   rax,rax
    1ffd:	je     208c <botlish_fn_23+0xdc>
    2003:	mov    edx,0x1
    2008:	mov    QWORD PTR [rsp+0x8],0x1
    2011:	mov    rsi,r12
    2014:	mov    rdi,rbx
    2017:	call   201c <botlish_fn_23+0x6c>
			2018: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    201c:	test   rax,rax
    201f:	je     20a3 <botlish_fn_23+0xf3>
    2025:	mov    QWORD PTR [rsp+0x8],rax
    202a:	mov    rsi,rax
    202d:	mov    QWORD PTR [rsp+0x10],rdx
    2032:	mov    r13,rdx
    2035:	mov    rdi,rbx
    2038:	call   203d <botlish_fn_23+0x8d>
			2039: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    203d:	test   rax,rax
    2040:	je     20a3 <botlish_fn_23+0xf3>
    2046:	mov    QWORD PTR [rsp+0x8],rax
    204b:	mov    rcx,rax
    204e:	mov    r8d,0x3
    2054:	mov    QWORD PTR [rsp+0x18],0x3
    205d:	mov    rdx,r13
    2060:	mov    rsi,r12
    2063:	mov    rdi,rbx
    2066:	call   206b <botlish_fn_23+0xbb>
			2067: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    206b:	test   rax,rax
    206e:	je     20a3 <botlish_fn_23+0xf3>
    2074:	mov    rbx,QWORD PTR [rsp+0x20]
    2079:	mov    r12,QWORD PTR [rsp+0x28]
    207e:	mov    r13,QWORD PTR [rsp+0x30]
    2083:	add    rsp,0x40
    2087:	mov    rsp,rbp
    208a:	pop    rbp
    208b:	ret
    208c:	xor    rdx,rdx
    208f:	mov    rdi,rbx
    2092:	mov    rsi,rdx
    2095:	call   209a <botlish_fn_23+0xea>
			2096: R_X86_64_PLT32	rt_list_new-0x4
    209a:	test   rax,rax
    209d:	jne    20be <botlish_fn_23+0x10e>
    20a3:	xor    rax,rax
    20a6:	mov    rbx,QWORD PTR [rsp+0x20]
    20ab:	mov    r12,QWORD PTR [rsp+0x28]
    20b0:	mov    r13,QWORD PTR [rsp+0x30]
    20b5:	add    rsp,0x40
    20b9:	mov    rsp,rbp
    20bc:	pop    rbp
    20bd:	ret
    20be:	mov    rbx,QWORD PTR [rsp+0x20]
    20c3:	mov    r12,QWORD PTR [rsp+0x28]
    20c8:	mov    r13,QWORD PTR [rsp+0x30]
    20cd:	add    rsp,0x40
    20d1:	mov    rsp,rbp
    20d4:	pop    rbp
    20d5:	ret

00000000000020d6 <botlish_entry_23: csv_parse<str>>:
    20d6:	push   rbp
    20d7:	mov    rbp,rsp
    20da:	mov    rsi,QWORD PTR [rdx]
    20dd:	call   20e2 <botlish_entry_23+0xc>
			20de: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    20e2:	mov    rsp,rbp
    20e5:	pop    rbp
    20e6:	ret
	...

00000000000020e8 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    20e8:	push   rbp
    20e9:	mov    rbp,rsp
    20ec:	sub    rsp,0x40
    20f0:	mov    QWORD PTR [rsp+0x20],rbx
    20f5:	mov    QWORD PTR [rsp+0x28],r12
    20fa:	mov    QWORD PTR [rsp+0x30],r13
    20ff:	mov    QWORD PTR [rsp+0x38],r14
    2104:	mov    r13,rdi
    2107:	mov    QWORD PTR [rsp],rsi
    210b:	mov    rbx,rsi
    210e:	mov    QWORD PTR [rsp+0x8],rdx
    2113:	mov    QWORD PTR [rsp+0x10],rcx
    2118:	mov    r12,rcx
    211b:	mov    rsi,rdx
    211e:	mov    rax,rsi
    2121:	and    rax,r12
    2124:	mov    r14,rsi
    2127:	test   rax,0x1
    212d:	jne    2156 <botlish_fn_24+0x6e>
    2133:	mov    rdx,r12
    2136:	mov    rsi,r14
    2139:	mov    rdi,r13
    213c:	call   2141 <botlish_fn_24+0x59>
			213d: R_X86_64_PLT32	rt_int_cmp-0x4
    2141:	mov    ecx,0x2
    2146:	test   rax,rax
    2149:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2230 <botlish_fn_24+0x148>
    2151:	jmp    2169 <botlish_fn_24+0x81>
    2156:	mov    ecx,0x2
    215b:	mov    rsi,r14
    215e:	cmp    rsi,r12
    2161:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2230 <botlish_fn_24+0x148>
    2169:	cmp    rcx,0x6
    216d:	je     220e <botlish_fn_24+0x126>
    2173:	mov    ecx,0x1
    2178:	mov    rdx,r14
    217b:	mov    rsi,rbx
    217e:	mov    rdi,r13
    2181:	call   2186 <botlish_fn_24+0x9e>
			2182: R_X86_64_PLT32	rt_mutarray_set-0x4
    2186:	test   rax,rax
    2189:	jne    21af <botlish_fn_24+0xc7>
    218f:	xor    rax,rax
    2192:	mov    rbx,QWORD PTR [rsp+0x20]
    2197:	mov    r12,QWORD PTR [rsp+0x28]
    219c:	mov    r13,QWORD PTR [rsp+0x30]
    21a1:	mov    r14,QWORD PTR [rsp+0x38]
    21a6:	add    rsp,0x40
    21aa:	mov    rsp,rbp
    21ad:	pop    rbp
    21ae:	ret
    21af:	mov    QWORD PTR [rsp+0x18],0x3
    21b8:	mov    rsi,r14
    21bb:	test   rsi,0x1
    21c2:	je     21e5 <botlish_fn_24+0xfd>
    21c8:	mov    rsi,r14
    21cb:	mov    rcx,rsi
    21ce:	add    rcx,0x2
    21d2:	seto   al
    21d5:	test   al,al
    21d7:	jne    21e5 <botlish_fn_24+0xfd>
    21dd:	mov    r14,rcx
    21e0:	jmp    21f8 <botlish_fn_24+0x110>
    21e5:	mov    edx,0x3
    21ea:	mov    rsi,r14
    21ed:	mov    rdi,r13
    21f0:	call   21f5 <botlish_fn_24+0x10d>
			21f1: R_X86_64_PLT32	rt_int_add-0x4
    21f5:	mov    r14,rax
    21f8:	mov    QWORD PTR [rsp],rbx
    21fc:	mov    rsi,r14
    21ff:	mov    QWORD PTR [rsp+0x8],rsi
    2204:	mov    QWORD PTR [rsp+0x10],r12
    2209:	jmp    211e <botlish_fn_24+0x36>
    220e:	mov    eax,0xa
    2213:	mov    rbx,QWORD PTR [rsp+0x20]
    2218:	mov    r12,QWORD PTR [rsp+0x28]
    221d:	mov    r13,QWORD PTR [rsp+0x30]
    2222:	mov    r14,QWORD PTR [rsp+0x38]
    2227:	add    rsp,0x40
    222b:	mov    rsp,rbp
    222e:	pop    rbp
    222f:	ret
    2230:	(bad)
    2231:	add    BYTE PTR [rax],al
    2233:	add    BYTE PTR [rax],al
    2235:	add    BYTE PTR [rax],al
	...

0000000000002238 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    2238:	push   rbp
    2239:	mov    rbp,rsp
    223c:	mov    rsi,QWORD PTR [rdx]
    223f:	mov    r8,QWORD PTR [rdx+0x8]
    2243:	mov    rcx,QWORD PTR [rdx+0x10]
    2247:	mov    rdx,r8
    224a:	call   224f <botlish_entry_24+0x17>
			224b: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    224f:	mov    rsp,rbp
    2252:	pop    rbp
    2253:	ret

0000000000002254 <botlish_fn_25: ht_alloc<int>>:
    2254:	push   rbp
    2255:	mov    rbp,rsp
    2258:	sub    rsp,0x50
    225c:	mov    QWORD PTR [rsp+0x20],rbx
    2261:	mov    QWORD PTR [rsp+0x28],r12
    2266:	mov    QWORD PTR [rsp+0x30],r13
    226b:	mov    QWORD PTR [rsp+0x38],r14
    2270:	mov    QWORD PTR [rsp+0x40],r15
    2275:	mov    rbx,rdi
    2278:	mov    QWORD PTR [rsp+0x8],0x0
    2281:	mov    QWORD PTR [rsp+0x10],0x0
    228a:	mov    QWORD PTR [rsp+0x18],0x0
    2293:	mov    QWORD PTR [rsp],rsi
    2297:	mov    r13,rsi
    229a:	mov    rsi,r13
    229d:	mov    rdi,rbx
    22a0:	call   22a5 <botlish_fn_25+0x51>
			22a1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22a5:	test   rax,rax
    22a8:	je     23c4 <botlish_fn_25+0x170>
    22ae:	mov    QWORD PTR [rsp+0x8],rax
    22b3:	mov    r12,rax
    22b6:	mov    edx,0x1
    22bb:	mov    QWORD PTR [rsp+0x10],0x1
    22c4:	mov    rcx,r13
    22c7:	mov    rsi,r12
    22ca:	mov    rdi,rbx
    22cd:	call   22d2 <botlish_fn_25+0x7e>
			22ce: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    22d2:	test   rax,rax
    22d5:	je     23c4 <botlish_fn_25+0x170>
    22db:	mov    rsi,r13
    22de:	mov    rdi,rbx
    22e1:	call   22e6 <botlish_fn_25+0x92>
			22e2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22e6:	test   rax,rax
    22e9:	je     23c4 <botlish_fn_25+0x170>
    22ef:	mov    QWORD PTR [rsp+0x10],rax
    22f4:	mov    rsi,r13
    22f7:	mov    r14,rax
    22fa:	mov    rdi,rbx
    22fd:	call   2302 <botlish_fn_25+0xae>
			22fe: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2302:	test   rax,rax
    2305:	je     23c4 <botlish_fn_25+0x170>
    230b:	mov    QWORD PTR [rsp],rax
    230f:	mov    r13,rax
    2312:	mov    esi,0xb
    2317:	mov    QWORD PTR [rsp+0x18],0xb
    2320:	mov    rdi,rbx
    2323:	call   2328 <botlish_fn_25+0xd4>
			2324: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2328:	test   rax,rax
    232b:	mov    r15,rax
    232e:	je     23c4 <botlish_fn_25+0x170>
    2334:	mov    edx,0x1
    2339:	mov    rcx,r12
    233c:	mov    rsi,r15
    233f:	mov    rdi,rbx
    2342:	call   2347 <botlish_fn_25+0xf3>
			2343: R_X86_64_PLT32	rt_mutarray_set-0x4
    2347:	test   rax,rax
    234a:	je     23c4 <botlish_fn_25+0x170>
    2350:	mov    edx,0x3
    2355:	mov    rcx,r14
    2358:	mov    rsi,r15
    235b:	mov    rdi,rbx
    235e:	call   2363 <botlish_fn_25+0x10f>
			235f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2363:	test   rax,rax
    2366:	je     23c4 <botlish_fn_25+0x170>
    236c:	mov    edx,0x5
    2371:	mov    rcx,r13
    2374:	mov    rsi,r15
    2377:	mov    rdi,rbx
    237a:	call   237f <botlish_fn_25+0x12b>
			237b: R_X86_64_PLT32	rt_mutarray_set-0x4
    237f:	test   rax,rax
    2382:	je     23c4 <botlish_fn_25+0x170>
    2388:	mov    edx,0x7
    238d:	mov    ecx,0x1
    2392:	mov    rsi,r15
    2395:	mov    rdi,rbx
    2398:	call   239d <botlish_fn_25+0x149>
			2399: R_X86_64_PLT32	rt_mutarray_set-0x4
    239d:	test   rax,rax
    23a0:	je     23c4 <botlish_fn_25+0x170>
    23a6:	mov    edx,0x9
    23ab:	mov    ecx,0x1
    23b0:	mov    rdi,rbx
    23b3:	mov    rsi,r15
    23b6:	call   23bb <botlish_fn_25+0x167>
			23b7: R_X86_64_PLT32	rt_mutarray_set-0x4
    23bb:	test   rax,rax
    23be:	jne    23e9 <botlish_fn_25+0x195>
    23c4:	xor    rax,rax
    23c7:	mov    rbx,QWORD PTR [rsp+0x20]
    23cc:	mov    r12,QWORD PTR [rsp+0x28]
    23d1:	mov    r13,QWORD PTR [rsp+0x30]
    23d6:	mov    r14,QWORD PTR [rsp+0x38]
    23db:	mov    r15,QWORD PTR [rsp+0x40]
    23e0:	add    rsp,0x50
    23e4:	mov    rsp,rbp
    23e7:	pop    rbp
    23e8:	ret
    23e9:	mov    rax,r15
    23ec:	mov    rbx,QWORD PTR [rsp+0x20]
    23f1:	mov    r12,QWORD PTR [rsp+0x28]
    23f6:	mov    r13,QWORD PTR [rsp+0x30]
    23fb:	mov    r14,QWORD PTR [rsp+0x38]
    2400:	mov    r15,QWORD PTR [rsp+0x40]
    2405:	add    rsp,0x50
    2409:	mov    rsp,rbp
    240c:	pop    rbp
    240d:	ret

000000000000240e <botlish_entry_25: ht_alloc<int>>:
    240e:	push   rbp
    240f:	mov    rbp,rsp
    2412:	mov    rsi,QWORD PTR [rdx]
    2415:	call   241a <botlish_entry_25+0xc>
			2416: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    241a:	mov    rsp,rbp
    241d:	pop    rbp
    241e:	ret

000000000000241f <botlish_fn_26: ht_new<generic>>:
    241f:	push   rbp
    2420:	mov    rbp,rsp
    2423:	sub    rsp,0x10
    2427:	mov    esi,0x11
    242c:	mov    QWORD PTR [rsp],0x11
    2434:	call   2439 <botlish_fn_26+0x1a>
			2435: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2439:	test   rax,rax
    243c:	jne    244e <botlish_fn_26+0x2f>
    2442:	xor    rax,rax
    2445:	add    rsp,0x10
    2449:	mov    rsp,rbp
    244c:	pop    rbp
    244d:	ret
    244e:	add    rsp,0x10
    2452:	mov    rsp,rbp
    2455:	pop    rbp
    2456:	ret

0000000000002457 <botlish_entry_26: ht_new<generic>>:
    2457:	push   rbp
    2458:	mov    rbp,rsp
    245b:	call   2460 <botlish_entry_26+0x9>
			245c: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    2460:	mov    rsp,rbp
    2463:	pop    rbp
    2464:	ret
    2465:	add    BYTE PTR [rax],al
	...

0000000000002468 <botlish_fn_27: ht_capacity_for<int, int>>:
    2468:	push   rbp
    2469:	mov    rbp,rsp
    246c:	sub    rsp,0x50
    2470:	mov    QWORD PTR [rsp+0x20],rbx
    2475:	mov    QWORD PTR [rsp+0x28],r12
    247a:	mov    QWORD PTR [rsp+0x30],r13
    247f:	mov    QWORD PTR [rsp+0x38],r14
    2484:	mov    QWORD PTR [rsp+0x40],r15
    2489:	mov    r13,rdi
    248c:	mov    QWORD PTR [rsp],rdx
    2490:	shl    rsi,1
    2493:	mov    rbx,rsi
    2496:	or     rbx,0x1
    249a:	sar    rbx,1
    249d:	mov    r12,rsi
    24a0:	mov    r14,rdx
    24a3:	mov    rax,r12
    24a6:	or     rax,0x1
    24aa:	mov    QWORD PTR [rsp+0x8],rax
    24af:	mov    QWORD PTR [rsp+0x10],0x7
    24b8:	mov    rax,rbx
    24bb:	imul   QWORD PTR [rip+0x156]        # 2618 <botlish_fn_27+0x1b0>
    24c2:	seto   cl
    24c5:	or     rax,0x1
    24c9:	test   cl,cl
    24cb:	jne    24d9 <botlish_fn_27+0x71>
    24d1:	mov    rsi,rax
    24d4:	jmp    24f0 <botlish_fn_27+0x88>
    24d9:	mov    rsi,r12
    24dc:	or     rsi,0x1
    24e0:	mov    edx,0x7
    24e5:	mov    rdi,r13
    24e8:	call   24ed <botlish_fn_27+0x85>
			24e9: R_X86_64_PLT32	rt_int_mul-0x4
    24ed:	mov    rsi,rax
    24f0:	mov    QWORD PTR [rsp+0x8],rsi
    24f5:	mov    r15,rsi
    24f8:	mov    QWORD PTR [rsp+0x10],0x5
    2501:	mov    rsi,r14
    2504:	test   rsi,0x1
    250b:	je     253b <botlish_fn_27+0xd3>
    2511:	mov    rsi,r14
    2514:	mov    rax,rsi
    2517:	sar    rax,1
    251a:	imul   QWORD PTR [rip+0xff]        # 2620 <botlish_fn_27+0x1b8>
    2521:	seto   cl
    2524:	or     rax,0x1
    2528:	test   cl,cl
    252a:	jne    253b <botlish_fn_27+0xd3>
    2530:	mov    rdx,rax
    2533:	mov    rsi,r15
    2536:	jmp    2551 <botlish_fn_27+0xe9>
    253b:	mov    edx,0x5
    2540:	mov    rsi,r14
    2543:	mov    rdi,r13
    2546:	call   254b <botlish_fn_27+0xe3>
			2547: R_X86_64_PLT32	rt_int_mul-0x4
    254b:	mov    rdx,rax
    254e:	mov    rsi,r15
    2551:	mov    rax,rsi
    2554:	and    rax,rdx
    2557:	test   rax,0x1
    255d:	jne    2580 <botlish_fn_27+0x118>
    2563:	mov    rdi,r13
    2566:	call   256b <botlish_fn_27+0x103>
			2567: R_X86_64_PLT32	rt_int_cmp-0x4
    256b:	mov    ecx,0x2
    2570:	test   rax,rax
    2573:	cmovle rcx,QWORD PTR [rip+0x9d]        # 2618 <botlish_fn_27+0x1b0>
    257b:	jmp    2590 <botlish_fn_27+0x128>
    2580:	mov    ecx,0x2
    2585:	cmp    rsi,rdx
    2588:	cmovle rcx,QWORD PTR [rip+0x88]        # 2618 <botlish_fn_27+0x1b0>
    2590:	cmp    rcx,0x6
    2594:	je     25f0 <botlish_fn_27+0x188>
    259a:	mov    QWORD PTR [rsp+0x8],0x5
    25a3:	mov    rsi,r14
    25a6:	test   rsi,0x1
    25ad:	je     25d4 <botlish_fn_27+0x16c>
    25b3:	mov    rsi,r14
    25b6:	mov    rax,rsi
    25b9:	sar    rax,1
    25bc:	imul   QWORD PTR [rip+0x5d]        # 2620 <botlish_fn_27+0x1b8>
    25c3:	seto   dil
    25c7:	or     rax,0x1
    25cb:	test   dil,dil
    25ce:	je     25e4 <botlish_fn_27+0x17c>
    25d4:	mov    edx,0x5
    25d9:	mov    rsi,r14
    25dc:	mov    rdi,r13
    25df:	call   25e4 <botlish_fn_27+0x17c>
			25e0: R_X86_64_PLT32	rt_int_mul-0x4
    25e4:	mov    QWORD PTR [rsp],rax
    25e8:	mov    r14,rax
    25eb:	jmp    24a3 <botlish_fn_27+0x3b>
    25f0:	mov    rax,r14
    25f3:	mov    rbx,QWORD PTR [rsp+0x20]
    25f8:	mov    r12,QWORD PTR [rsp+0x28]
    25fd:	mov    r13,QWORD PTR [rsp+0x30]
    2602:	mov    r14,QWORD PTR [rsp+0x38]
    2607:	mov    r15,QWORD PTR [rsp+0x40]
    260c:	add    rsp,0x50
    2610:	mov    rsp,rbp
    2613:	pop    rbp
    2614:	ret
    2615:	add    BYTE PTR [rax],al
    2617:	add    BYTE PTR [rsi],al
    2619:	add    BYTE PTR [rax],al
    261b:	add    BYTE PTR [rax],al
    261d:	add    BYTE PTR [rax],al
    261f:	add    BYTE PTR [rax+rax*1],al
    2622:	add    BYTE PTR [rax],al
    2624:	add    BYTE PTR [rax],al
	...

0000000000002628 <botlish_entry_27: ht_capacity_for<int, int>>:
    2628:	push   rbp
    2629:	mov    rbp,rsp
    262c:	mov    rsi,QWORD PTR [rdx]
    262f:	mov    rdx,QWORD PTR [rdx+0x8]
    2633:	sar    rsi,1
    2636:	call   263b <botlish_entry_27+0x13>
			2637: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    263b:	mov    rsp,rbp
    263e:	pop    rbp
    263f:	ret

0000000000002640 <botlish_fn_28: ht_new_sized<int>>:
    2640:	push   rbp
    2641:	mov    rbp,rsp
    2644:	sub    rsp,0x20
    2648:	mov    QWORD PTR [rsp+0x10],r12
    264d:	mov    r12,rdi
    2650:	mov    edx,0x11
    2655:	mov    QWORD PTR [rsp],0x11
    265d:	mov    rdi,r12
    2660:	call   2665 <botlish_fn_28+0x25>
			2661: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2665:	mov    QWORD PTR [rsp],rax
    2669:	mov    rsi,rax
    266c:	mov    rdi,r12
    266f:	call   2674 <botlish_fn_28+0x34>
			2670: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2674:	test   rax,rax
    2677:	jne    268e <botlish_fn_28+0x4e>
    267d:	xor    rax,rax
    2680:	mov    r12,QWORD PTR [rsp+0x10]
    2685:	add    rsp,0x20
    2689:	mov    rsp,rbp
    268c:	pop    rbp
    268d:	ret
    268e:	mov    r12,QWORD PTR [rsp+0x10]
    2693:	add    rsp,0x20
    2697:	mov    rsp,rbp
    269a:	pop    rbp
    269b:	ret

000000000000269c <botlish_entry_28: ht_new_sized<int>>:
    269c:	push   rbp
    269d:	mov    rbp,rsp
    26a0:	mov    rsi,QWORD PTR [rdx]
    26a3:	sar    rsi,1
    26a6:	call   26ab <botlish_entry_28+0xf>
			26a7: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    26ab:	mov    rsp,rbp
    26ae:	pop    rbp
    26af:	ret

00000000000026b0 <botlish_fn_29: ht_controls<mutarray>>:
    26b0:	push   rbp
    26b1:	mov    rbp,rsp
    26b4:	mov    edx,0x1
    26b9:	call   26be <botlish_fn_29+0xe>
			26ba: R_X86_64_PLT32	rt_mutarray_get-0x4
    26be:	test   rax,rax
    26c1:	jne    26cf <botlish_fn_29+0x1f>
    26c7:	xor    rax,rax
    26ca:	mov    rsp,rbp
    26cd:	pop    rbp
    26ce:	ret
    26cf:	mov    rsp,rbp
    26d2:	pop    rbp
    26d3:	ret

00000000000026d4 <botlish_entry_29: ht_controls<mutarray>>:
    26d4:	push   rbp
    26d5:	mov    rbp,rsp
    26d8:	mov    rsi,QWORD PTR [rdx]
    26db:	call   26e0 <botlish_entry_29+0xc>
			26dc: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    26e0:	mov    rsp,rbp
    26e3:	pop    rbp
    26e4:	ret

00000000000026e5 <botlish_fn_30: ht_keys<mutarray>>:
    26e5:	push   rbp
    26e6:	mov    rbp,rsp
    26e9:	mov    edx,0x3
    26ee:	call   26f3 <botlish_fn_30+0xe>
			26ef: R_X86_64_PLT32	rt_mutarray_get-0x4
    26f3:	test   rax,rax
    26f6:	jne    2704 <botlish_fn_30+0x1f>
    26fc:	xor    rax,rax
    26ff:	mov    rsp,rbp
    2702:	pop    rbp
    2703:	ret
    2704:	mov    rsp,rbp
    2707:	pop    rbp
    2708:	ret

0000000000002709 <botlish_entry_30: ht_keys<mutarray>>:
    2709:	push   rbp
    270a:	mov    rbp,rsp
    270d:	mov    rsi,QWORD PTR [rdx]
    2710:	call   2715 <botlish_entry_30+0xc>
			2711: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2715:	mov    rsp,rbp
    2718:	pop    rbp
    2719:	ret

000000000000271a <botlish_fn_31: ht_values<mutarray>>:
    271a:	push   rbp
    271b:	mov    rbp,rsp
    271e:	mov    edx,0x5
    2723:	call   2728 <botlish_fn_31+0xe>
			2724: R_X86_64_PLT32	rt_mutarray_get-0x4
    2728:	test   rax,rax
    272b:	jne    2739 <botlish_fn_31+0x1f>
    2731:	xor    rax,rax
    2734:	mov    rsp,rbp
    2737:	pop    rbp
    2738:	ret
    2739:	mov    rsp,rbp
    273c:	pop    rbp
    273d:	ret

000000000000273e <botlish_entry_31: ht_values<mutarray>>:
    273e:	push   rbp
    273f:	mov    rbp,rsp
    2742:	mov    rsi,QWORD PTR [rdx]
    2745:	call   274a <botlish_entry_31+0xc>
			2746: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    274a:	mov    rsp,rbp
    274d:	pop    rbp
    274e:	ret

000000000000274f <botlish_fn_32: ht_size<mutarray>>:
    274f:	push   rbp
    2750:	mov    rbp,rsp
    2753:	mov    edx,0x7
    2758:	call   275d <botlish_fn_32+0xe>
			2759: R_X86_64_PLT32	rt_mutarray_get-0x4
    275d:	test   rax,rax
    2760:	jne    276e <botlish_fn_32+0x1f>
    2766:	xor    rax,rax
    2769:	mov    rsp,rbp
    276c:	pop    rbp
    276d:	ret
    276e:	mov    rsp,rbp
    2771:	pop    rbp
    2772:	ret

0000000000002773 <botlish_entry_32: ht_size<mutarray>>:
    2773:	push   rbp
    2774:	mov    rbp,rsp
    2777:	mov    rsi,QWORD PTR [rdx]
    277a:	call   277f <botlish_entry_32+0xc>
			277b: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    277f:	mov    rsp,rbp
    2782:	pop    rbp
    2783:	ret

0000000000002784 <botlish_fn_33: ht_tombstones<mutarray>>:
    2784:	push   rbp
    2785:	mov    rbp,rsp
    2788:	mov    edx,0x9
    278d:	call   2792 <botlish_fn_33+0xe>
			278e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2792:	test   rax,rax
    2795:	jne    27a3 <botlish_fn_33+0x1f>
    279b:	xor    rax,rax
    279e:	mov    rsp,rbp
    27a1:	pop    rbp
    27a2:	ret
    27a3:	mov    rsp,rbp
    27a6:	pop    rbp
    27a7:	ret

00000000000027a8 <botlish_entry_33: ht_tombstones<mutarray>>:
    27a8:	push   rbp
    27a9:	mov    rbp,rsp
    27ac:	mov    rsi,QWORD PTR [rdx]
    27af:	call   27b4 <botlish_entry_33+0xc>
			27b0: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    27b4:	mov    rsp,rbp
    27b7:	pop    rbp
    27b8:	ret

00000000000027b9 <botlish_fn_34: ht_capacity<mutarray>>:
    27b9:	push   rbp
    27ba:	mov    rbp,rsp
    27bd:	sub    rsp,0x10
    27c1:	mov    QWORD PTR [rsp],rbx
    27c5:	mov    rbx,rdi
    27c8:	mov    rdi,rbx
    27cb:	call   27d0 <botlish_fn_34+0x17>
			27cc: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    27d0:	test   rax,rax
    27d3:	je     281d <botlish_fn_34+0x64>
    27d9:	xor    r8d,r8d
    27dc:	test   rax,0x7
    27e2:	je     27f0 <botlish_fn_34+0x37>
    27e8:	mov    rsi,rax
    27eb:	jmp    27ff <botlish_fn_34+0x46>
    27f0:	movzx  rcx,BYTE PTR [rax]
    27f4:	mov    rsi,rax
    27f7:	rex cmp cl,0x8
    27fb:	sete   r8b
    27ff:	test   r8b,r8b
    2802:	jne    2830 <botlish_fn_34+0x77>
    2808:	mov    rdi,rbx
    280b:	mov    rax,QWORD PTR [rdi+0x10]
    280f:	mov    rcx,QWORD PTR [rax+0x28]
    2813:	mov    edx,0x8
    2818:	call   281d <botlish_fn_34+0x64>
			2819: R_X86_64_PLT32	rt_type_error-0x4
    281d:	xor    rdx,rdx
    2820:	mov    rax,rdx
    2823:	mov    rbx,QWORD PTR [rsp]
    2827:	add    rsp,0x10
    282b:	mov    rsp,rbp
    282e:	pop    rbp
    282f:	ret
    2830:	mov    rdi,rbx
    2833:	call   2838 <botlish_fn_34+0x7f>
			2834: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2838:	mov    edx,0x1
    283d:	sar    rax,1
    2840:	mov    rbx,QWORD PTR [rsp]
    2844:	add    rsp,0x10
    2848:	mov    rsp,rbp
    284b:	pop    rbp
    284c:	ret

000000000000284d <botlish_entry_34: ht_capacity<mutarray>>:
    284d:	push   rbp
    284e:	mov    rbp,rsp
    2851:	mov    rsi,QWORD PTR [rdx]
    2854:	call   2859 <botlish_entry_34+0xc>
			2855: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2859:	shl    rax,1
    285c:	or     rax,0x1
    2860:	mov    rcx,rax
    2863:	xor    rax,rax
    2866:	test   rdx,rdx
    2869:	cmovne rax,rcx
    286d:	mov    rsp,rbp
    2870:	pop    rbp
    2871:	ret

0000000000002872 <botlish_fn_35: ht_probe_start<mutarray, str>>:
    2872:	push   rbp
    2873:	mov    rbp,rsp
    2876:	sub    rsp,0x20
    287a:	mov    QWORD PTR [rsp],rbx
    287e:	mov    QWORD PTR [rsp+0x8],r12
    2883:	mov    QWORD PTR [rsp+0x10],r15
    2888:	mov    rbx,rsi
    288b:	mov    r12,rdi
    288e:	mov    rsi,rdx
    2891:	mov    rdi,r12
    2894:	call   2899 <botlish_fn_35+0x27>
			2895: R_X86_64_PLT32	rt_hash-0x4
    2899:	test   rax,rax
    289c:	mov    r15,rax
    289f:	je     28d7 <botlish_fn_35+0x65>
    28a5:	mov    rsi,rbx
    28a8:	mov    rdi,r12
    28ab:	call   28b0 <botlish_fn_35+0x3e>
			28ac: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    28b0:	test   rdx,rdx
    28b3:	je     28d7 <botlish_fn_35+0x65>
    28b9:	shl    rax,1
    28bc:	mov    rdx,rax
    28bf:	or     rdx,0x1
    28c3:	mov    rsi,r15
    28c6:	mov    rdi,r12
    28c9:	call   28ce <botlish_fn_35+0x5c>
			28ca: R_X86_64_PLT32	rt_int_mod-0x4
    28ce:	test   rax,rax
    28d1:	jne    28f1 <botlish_fn_35+0x7f>
    28d7:	xor    rax,rax
    28da:	mov    rbx,QWORD PTR [rsp]
    28de:	mov    r12,QWORD PTR [rsp+0x8]
    28e3:	mov    r15,QWORD PTR [rsp+0x10]
    28e8:	add    rsp,0x20
    28ec:	mov    rsp,rbp
    28ef:	pop    rbp
    28f0:	ret
    28f1:	mov    rbx,QWORD PTR [rsp]
    28f5:	mov    r12,QWORD PTR [rsp+0x8]
    28fa:	mov    r15,QWORD PTR [rsp+0x10]
    28ff:	add    rsp,0x20
    2903:	mov    rsp,rbp
    2906:	pop    rbp
    2907:	ret

0000000000002908 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    2908:	push   rbp
    2909:	mov    rbp,rsp
    290c:	mov    rsi,QWORD PTR [rdx]
    290f:	mov    rdx,QWORD PTR [rdx+0x8]
    2913:	call   2918 <botlish_entry_35+0x10>
			2914: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    2918:	mov    rsp,rbp
    291b:	pop    rbp
    291c:	ret

000000000000291d <botlish_fn_36: ht_probe_next<mutarray, int>>:
    291d:	push   rbp
    291e:	mov    rbp,rsp
    2921:	sub    rsp,0x40
    2925:	mov    QWORD PTR [rsp+0x20],rbx
    292a:	mov    QWORD PTR [rsp+0x28],r12
    292f:	mov    QWORD PTR [rsp+0x30],r13
    2934:	mov    rbx,rdi
    2937:	mov    QWORD PTR [rsp],rsi
    293b:	mov    r12,rsi
    293e:	mov    QWORD PTR [rsp+0x8],rdx
    2943:	mov    QWORD PTR [rsp+0x10],0x3
    294c:	test   rdx,0x1
    2953:	jne    2961 <botlish_fn_36+0x44>
    2959:	mov    rsi,rdx
    295c:	jmp    2981 <botlish_fn_36+0x64>
    2961:	mov    rsi,rdx
    2964:	add    rsi,0x2
    2968:	mov    r13,rsi
    296b:	mov    rsi,rdx
    296e:	seto   al
    2971:	test   al,al
    2973:	jne    2981 <botlish_fn_36+0x64>
    2979:	mov    rsi,r12
    297c:	jmp    2994 <botlish_fn_36+0x77>
    2981:	mov    edx,0x3
    2986:	mov    rdi,rbx
    2989:	call   298e <botlish_fn_36+0x71>
			298a: R_X86_64_PLT32	rt_int_add-0x4
    298e:	mov    rsi,r12
    2991:	mov    r13,rax
    2994:	mov    rdi,rbx
    2997:	call   299c <botlish_fn_36+0x7f>
			2998: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    299c:	test   rdx,rdx
    299f:	je     29c3 <botlish_fn_36+0xa6>
    29a5:	shl    rax,1
    29a8:	mov    rdx,rax
    29ab:	or     rdx,0x1
    29af:	mov    rsi,r13
    29b2:	mov    rdi,rbx
    29b5:	call   29ba <botlish_fn_36+0x9d>
			29b6: R_X86_64_PLT32	rt_int_mod-0x4
    29ba:	test   rax,rax
    29bd:	jne    29de <botlish_fn_36+0xc1>
    29c3:	xor    rax,rax
    29c6:	mov    rbx,QWORD PTR [rsp+0x20]
    29cb:	mov    r12,QWORD PTR [rsp+0x28]
    29d0:	mov    r13,QWORD PTR [rsp+0x30]
    29d5:	add    rsp,0x40
    29d9:	mov    rsp,rbp
    29dc:	pop    rbp
    29dd:	ret
    29de:	mov    rbx,QWORD PTR [rsp+0x20]
    29e3:	mov    r12,QWORD PTR [rsp+0x28]
    29e8:	mov    r13,QWORD PTR [rsp+0x30]
    29ed:	add    rsp,0x40
    29f1:	mov    rsp,rbp
    29f4:	pop    rbp
    29f5:	ret

00000000000029f6 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    29f6:	push   rbp
    29f7:	mov    rbp,rsp
    29fa:	mov    rsi,QWORD PTR [rdx]
    29fd:	mov    rdx,QWORD PTR [rdx+0x8]
    2a01:	call   2a06 <botlish_entry_36+0x10>
			2a02: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2a06:	mov    rsp,rbp
    2a09:	pop    rbp
    2a0a:	ret
    2a0b:	add    BYTE PTR [rax],al
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
    3a38:	mov    rbx,rsi
    3a3b:	mov    QWORD PTR [rsp+0x28],rdx
    3a40:	mov    r12,rdx
    3a43:	mov    rsi,rbx
    3a46:	mov    rdi,r13
    3a49:	call   3a4e <botlish_fn_43+0x75>
			3a4a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    3a4e:	test   rax,rax
    3a51:	je     3c31 <botlish_fn_43+0x258>
    3a57:	mov    QWORD PTR [rsp+0x30],rax
    3a5c:	mov    r14,rax
    3a5f:	mov    rsi,rbx
    3a62:	mov    rdi,r13
    3a65:	call   3a6a <botlish_fn_43+0x91>
			3a66: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3a6a:	test   rax,rax
    3a6d:	je     3c31 <botlish_fn_43+0x258>
    3a73:	mov    QWORD PTR [rsp+0x38],rax
    3a78:	mov    r15,rax
    3a7b:	mov    rsi,rbx
    3a7e:	mov    rdi,r13
    3a81:	call   3a86 <botlish_fn_43+0xad>
			3a82: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3a86:	test   rax,rax
    3a89:	je     3c31 <botlish_fn_43+0x258>
    3a8f:	mov    QWORD PTR [rsp+0x40],rax
    3a94:	mov    QWORD PTR [rsp+0x90],rax
    3a9c:	mov    rsi,rbx
    3a9f:	mov    rdi,r13
    3aa2:	call   3aa7 <botlish_fn_43+0xce>
			3aa3: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3aa7:	test   rdx,rdx
    3aaa:	je     3c31 <botlish_fn_43+0x258>
    3ab0:	shl    rax,1
    3ab3:	mov    rcx,rax
    3ab6:	or     rcx,0x1
    3aba:	mov    QWORD PTR [rsp+0x88],rax
    3ac2:	mov    QWORD PTR [rsp+0x48],rcx
    3ac7:	mov    rsi,r12
    3aca:	mov    rdi,r13
    3acd:	call   3ad2 <botlish_fn_43+0xf9>
			3ace: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3ad2:	mov    rcx,rax
    3ad5:	mov    QWORD PTR [rsp+0x80],rax
    3add:	test   rax,rcx
    3ae0:	je     3c31 <botlish_fn_43+0x258>
    3ae6:	mov    rax,QWORD PTR [rsp+0x80]
    3aee:	mov    QWORD PTR [rsp+0x50],rax
    3af3:	mov    edx,0x1
    3af8:	mov    QWORD PTR [rsp+0x58],0x1
    3b01:	mov    rcx,r12
    3b04:	mov    rsi,QWORD PTR [rsp+0x80]
    3b0c:	mov    rdi,r13
    3b0f:	call   3b14 <botlish_fn_43+0x13b>
			3b10: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3b14:	test   rax,rax
    3b17:	je     3c31 <botlish_fn_43+0x258>
    3b1d:	mov    rsi,r12
    3b20:	mov    rdi,r13
    3b23:	call   3b28 <botlish_fn_43+0x14f>
			3b24: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b28:	test   rax,rax
    3b2b:	je     3c31 <botlish_fn_43+0x258>
    3b31:	mov    QWORD PTR [rsp+0x58],rax
    3b36:	mov    QWORD PTR [rsp+0x78],rax
    3b3b:	mov    rsi,r12
    3b3e:	mov    rdi,r13
    3b41:	call   3b46 <botlish_fn_43+0x16d>
			3b42: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b46:	test   rax,rax
    3b49:	je     3c31 <botlish_fn_43+0x258>
    3b4f:	mov    QWORD PTR [rsp+0x60],rax
    3b54:	mov    r8d,0x1
    3b5a:	mov    QWORD PTR [rsp+0x68],0x1
    3b63:	mov    rcx,QWORD PTR [rsp+0x88]
    3b6b:	mov    r9,rcx
    3b6e:	or     r9,0x1
    3b72:	mov    rcx,QWORD PTR [rsp+0x80]
    3b7a:	mov    QWORD PTR [rsp],rcx
    3b7e:	mov    rcx,QWORD PTR [rsp+0x78]
    3b83:	mov    QWORD PTR [rsp+0x8],rcx
    3b88:	mov    QWORD PTR [rsp+0x10],rax
    3b8d:	mov    QWORD PTR [rsp+0x70],rax
    3b92:	mov    QWORD PTR [rsp+0x18],r12
    3b97:	mov    rcx,QWORD PTR [rsp+0x90]
    3b9f:	mov    rdx,r15
    3ba2:	mov    rsi,r14
    3ba5:	mov    rdi,r13
    3ba8:	call   3bad <botlish_fn_43+0x1d4>
			3ba9: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3bad:	test   rax,rax
    3bb0:	je     3c31 <botlish_fn_43+0x258>
    3bb6:	mov    edx,0x1
    3bbb:	mov    rcx,QWORD PTR [rsp+0x80]
    3bc3:	mov    rsi,rbx
    3bc6:	mov    rdi,r13
    3bc9:	call   3bce <botlish_fn_43+0x1f5>
			3bca: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bce:	test   rax,rax
    3bd1:	je     3c31 <botlish_fn_43+0x258>
    3bd7:	mov    edx,0x3
    3bdc:	mov    rcx,QWORD PTR [rsp+0x78]
    3be1:	mov    rsi,rbx
    3be4:	mov    rdi,r13
    3be7:	call   3bec <botlish_fn_43+0x213>
			3be8: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bec:	test   rax,rax
    3bef:	je     3c31 <botlish_fn_43+0x258>
    3bf5:	mov    edx,0x5
    3bfa:	mov    rcx,QWORD PTR [rsp+0x70]
    3bff:	mov    rsi,rbx
    3c02:	mov    rdi,r13
    3c05:	call   3c0a <botlish_fn_43+0x231>
			3c06: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c0a:	test   rax,rax
    3c0d:	je     3c31 <botlish_fn_43+0x258>
    3c13:	mov    edx,0x9
    3c18:	mov    ecx,0x1
    3c1d:	mov    rsi,rbx
    3c20:	mov    rdi,r13
    3c23:	call   3c28 <botlish_fn_43+0x24f>
			3c24: R_X86_64_PLT32	rt_mutarray_set-0x4
    3c28:	test   rax,rax
    3c2b:	jne    3c68 <botlish_fn_43+0x28f>
    3c31:	xor    rax,rax
    3c34:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c3c:	mov    r12,QWORD PTR [rsp+0xa8]
    3c44:	mov    r13,QWORD PTR [rsp+0xb0]
    3c4c:	mov    r14,QWORD PTR [rsp+0xb8]
    3c54:	mov    r15,QWORD PTR [rsp+0xc0]
    3c5c:	add    rsp,0xd0
    3c63:	mov    rsp,rbp
    3c66:	pop    rbp
    3c67:	ret
    3c68:	mov    eax,0xa
    3c6d:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c75:	mov    r12,QWORD PTR [rsp+0xa8]
    3c7d:	mov    r13,QWORD PTR [rsp+0xb0]
    3c85:	mov    r14,QWORD PTR [rsp+0xb8]
    3c8d:	mov    r15,QWORD PTR [rsp+0xc0]
    3c95:	add    rsp,0xd0
    3c9c:	mov    rsp,rbp
    3c9f:	pop    rbp
    3ca0:	ret

0000000000003ca1 <botlish_entry_43: ht_rehash<mutarray, int>>:
    3ca1:	push   rbp
    3ca2:	mov    rbp,rsp
    3ca5:	mov    rsi,QWORD PTR [rdx]
    3ca8:	mov    rdx,QWORD PTR [rdx+0x8]
    3cac:	call   3cb1 <botlish_entry_43+0x10>
			3cad: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3cb1:	mov    rsp,rbp
    3cb4:	pop    rbp
    3cb5:	ret
	...

0000000000003cb8 <botlish_fn_44: ht_should_grow<mutarray>>:
    3cb8:	push   rbp
    3cb9:	mov    rbp,rsp
    3cbc:	sub    rsp,0x40
    3cc0:	mov    QWORD PTR [rsp+0x20],rbx
    3cc5:	mov    QWORD PTR [rsp+0x28],r12
    3cca:	mov    QWORD PTR [rsp+0x30],r13
    3ccf:	mov    r12,rdi
    3cd2:	mov    QWORD PTR [rsp],rsi
    3cd6:	mov    r13,rsi
    3cd9:	mov    rsi,r13
    3cdc:	mov    rdi,r12
    3cdf:	call   3ce4 <botlish_fn_44+0x2c>
			3ce0: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3ce4:	mov    rcx,rax
    3ce7:	mov    rbx,rax
    3cea:	test   rax,rcx
    3ced:	je     3edc <botlish_fn_44+0x224>
    3cf3:	mov    rax,rbx
    3cf6:	mov    QWORD PTR [rsp+0x8],rax
    3cfb:	mov    rsi,r13
    3cfe:	mov    rdi,r12
    3d01:	call   3d06 <botlish_fn_44+0x4e>
			3d02: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3d06:	mov    rcx,rax
    3d09:	test   rcx,rcx
    3d0c:	je     3edc <botlish_fn_44+0x224>
    3d12:	mov    QWORD PTR [rsp+0x10],rcx
    3d17:	mov    edx,0x1
    3d1c:	mov    rax,rbx
    3d1f:	test   rax,0x1
    3d25:	jne    3d48 <botlish_fn_44+0x90>
    3d2b:	xor    edx,edx
    3d2d:	mov    rax,rbx
    3d30:	test   rax,0x7
    3d36:	jne    3d48 <botlish_fn_44+0x90>
    3d3c:	mov    rax,rbx
    3d3f:	movzx  rax,BYTE PTR [rax]
    3d43:	cmp    al,0x1
    3d45:	sete   dl
    3d48:	test   dl,dl
    3d4a:	jne    3d6b <botlish_fn_44+0xb3>
    3d50:	mov    rdi,r12
    3d53:	mov    rax,QWORD PTR [rdi+0x10]
    3d57:	mov    rcx,QWORD PTR [rax+0x38]
    3d5b:	xor    rdx,rdx
    3d5e:	mov    rsi,rbx
    3d61:	call   3d66 <botlish_fn_44+0xae>
			3d62: R_X86_64_PLT32	rt_type_error-0x4
    3d66:	jmp    3edc <botlish_fn_44+0x224>
    3d6b:	mov    eax,0x1
    3d70:	test   rcx,0x1
    3d77:	je     3d85 <botlish_fn_44+0xcd>
    3d7d:	mov    r8,rcx
    3d80:	jmp    3da8 <botlish_fn_44+0xf0>
    3d85:	xor    eax,eax
    3d87:	test   rcx,0x7
    3d8e:	je     3d9c <botlish_fn_44+0xe4>
    3d94:	mov    r8,rcx
    3d97:	jmp    3da8 <botlish_fn_44+0xf0>
    3d9c:	movzx  rax,BYTE PTR [rcx]
    3da0:	mov    r8,rcx
    3da3:	cmp    al,0x1
    3da5:	sete   al
    3da8:	test   al,al
    3daa:	jne    3dcb <botlish_fn_44+0x113>
    3db0:	mov    rdi,r12
    3db3:	mov    rax,QWORD PTR [rdi+0x10]
    3db7:	mov    rcx,QWORD PTR [rax+0x38]
    3dbb:	xor    rdx,rdx
    3dbe:	mov    rsi,r8
    3dc1:	call   3dc6 <botlish_fn_44+0x10e>
			3dc2: R_X86_64_PLT32	rt_type_error-0x4
    3dc6:	jmp    3edc <botlish_fn_44+0x224>
    3dcb:	mov    rcx,r8
    3dce:	mov    rsi,rbx
    3dd1:	mov    rax,rsi
    3dd4:	and    rax,rcx
    3dd7:	test   rax,0x1
    3ddd:	jne    3dee <botlish_fn_44+0x136>
    3de3:	mov    rdx,r8
    3de6:	mov    rsi,rbx
    3de9:	jmp    3e0c <botlish_fn_44+0x154>
    3dee:	mov    rcx,r8
    3df1:	lea    rax,[rcx-0x1]
    3df5:	mov    rsi,rbx
    3df8:	add    rsi,rax
    3dfb:	seto   al
    3dfe:	test   al,al
    3e00:	je     3e17 <botlish_fn_44+0x15f>
    3e06:	mov    rdx,r8
    3e09:	mov    rsi,rbx
    3e0c:	mov    rdi,r12
    3e0f:	call   3e14 <botlish_fn_44+0x15c>
			3e10: R_X86_64_PLT32	rt_int_add-0x4
    3e14:	mov    rsi,rax
    3e17:	mov    QWORD PTR [rsp+0x8],rsi
    3e1c:	mov    QWORD PTR [rsp+0x10],0x3
    3e25:	test   rsi,0x1
    3e2c:	je     3e4f <botlish_fn_44+0x197>
    3e32:	mov    rax,rsi
    3e35:	add    rax,0x2
    3e39:	mov    rcx,rax
    3e3c:	seto   al
    3e3f:	test   al,al
    3e41:	jne    3e4f <botlish_fn_44+0x197>
    3e47:	mov    rsi,rcx
    3e4a:	jmp    3e5f <botlish_fn_44+0x1a7>
    3e4f:	mov    edx,0x3
    3e54:	mov    rdi,r12
    3e57:	call   3e5c <botlish_fn_44+0x1a4>
			3e58: R_X86_64_PLT32	rt_int_add-0x4
    3e5c:	mov    rsi,rax
    3e5f:	mov    QWORD PTR [rsp+0x8],rsi
    3e64:	mov    edx,0x7
    3e69:	mov    rdi,rdx
    3e6c:	mov    QWORD PTR [rsp+0x10],0x7
    3e75:	test   rsi,0x1
    3e7c:	jne    3e8a <botlish_fn_44+0x1d2>
    3e82:	mov    rdx,rdi
    3e85:	jmp    3eb6 <botlish_fn_44+0x1fe>
    3e8a:	mov    rax,rsi
    3e8d:	sar    rax,1
    3e90:	imul   QWORD PTR [rip+0x111]        # 3fa8 <botlish_fn_44+0x2f0>
    3e97:	seto   cl
    3e9a:	or     rax,0x1
    3e9e:	test   cl,cl
    3ea0:	je     3eae <botlish_fn_44+0x1f6>
    3ea6:	mov    rdx,rdi
    3ea9:	jmp    3eb6 <botlish_fn_44+0x1fe>
    3eae:	mov    rsi,rax
    3eb1:	jmp    3ec1 <botlish_fn_44+0x209>
    3eb6:	mov    rdi,r12
    3eb9:	call   3ebe <botlish_fn_44+0x206>
			3eba: R_X86_64_PLT32	rt_int_mul-0x4
    3ebe:	mov    rsi,rax
    3ec1:	mov    QWORD PTR [rsp],rsi
    3ec5:	mov    rbx,rsi
    3ec8:	mov    rsi,r13
    3ecb:	mov    rdi,r12
    3ece:	call   3ed3 <botlish_fn_44+0x21b>
			3ecf: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3ed3:	test   rdx,rdx
    3ed6:	jne    3ef7 <botlish_fn_44+0x23f>
    3edc:	xor    rax,rax
    3edf:	mov    rbx,QWORD PTR [rsp+0x20]
    3ee4:	mov    r12,QWORD PTR [rsp+0x28]
    3ee9:	mov    r13,QWORD PTR [rsp+0x30]
    3eee:	add    rsp,0x40
    3ef2:	mov    rsp,rbp
    3ef5:	pop    rbp
    3ef6:	ret
    3ef7:	shl    rax,1
    3efa:	mov    rsi,rax
    3efd:	or     rsi,0x1
    3f01:	mov    QWORD PTR [rsp+0x8],rsi
    3f06:	mov    QWORD PTR [rsp+0x10],0x5
    3f0f:	mov    rax,rsi
    3f12:	sar    rax,1
    3f15:	imul   QWORD PTR [rip+0x94]        # 3fb0 <botlish_fn_44+0x2f8>
    3f1c:	seto   dil
    3f20:	or     rax,0x1
    3f24:	test   dil,dil
    3f27:	jne    3f38 <botlish_fn_44+0x280>
    3f2d:	mov    rdx,rax
    3f30:	mov    rsi,rbx
    3f33:	jmp    3f4b <botlish_fn_44+0x293>
    3f38:	mov    edx,0x5
    3f3d:	mov    rdi,r12
    3f40:	call   3f45 <botlish_fn_44+0x28d>
			3f41: R_X86_64_PLT32	rt_int_mul-0x4
    3f45:	mov    rdx,rax
    3f48:	mov    rsi,rbx
    3f4b:	mov    r9,rsi
    3f4e:	and    r9,rdx
    3f51:	test   r9,0x1
    3f58:	jne    3f7e <botlish_fn_44+0x2c6>
    3f5e:	mov    rdi,r12
    3f61:	call   3f66 <botlish_fn_44+0x2ae>
			3f62: R_X86_64_PLT32	rt_int_cmp-0x4
    3f66:	mov    edi,0x2
    3f6b:	test   rax,rax
    3f6e:	mov    rax,rdi
    3f71:	cmovg  rax,QWORD PTR [rip+0x2f]        # 3fa8 <botlish_fn_44+0x2f0>
    3f79:	jmp    3f8e <botlish_fn_44+0x2d6>
    3f7e:	mov    eax,0x2
    3f83:	cmp    rsi,rdx
    3f86:	cmovg  rax,QWORD PTR [rip+0x1a]        # 3fa8 <botlish_fn_44+0x2f0>
    3f8e:	mov    rbx,QWORD PTR [rsp+0x20]
    3f93:	mov    r12,QWORD PTR [rsp+0x28]
    3f98:	mov    r13,QWORD PTR [rsp+0x30]
    3f9d:	add    rsp,0x40
    3fa1:	mov    rsp,rbp
    3fa4:	pop    rbp
    3fa5:	ret
    3fa6:	add    BYTE PTR [rax],al
    3fa8:	(bad)
    3fa9:	add    BYTE PTR [rax],al
    3fab:	add    BYTE PTR [rax],al
    3fad:	add    BYTE PTR [rax],al
    3faf:	add    BYTE PTR [rax+rax*1],al
    3fb2:	add    BYTE PTR [rax],al
    3fb4:	add    BYTE PTR [rax],al
	...

0000000000003fb8 <botlish_entry_44: ht_should_grow<mutarray>>:
    3fb8:	push   rbp
    3fb9:	mov    rbp,rsp
    3fbc:	mov    rsi,QWORD PTR [rdx]
    3fbf:	call   3fc4 <botlish_entry_44+0xc>
			3fc0: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3fc4:	mov    rsp,rbp
    3fc7:	pop    rbp
    3fc8:	ret
    3fc9:	add    BYTE PTR [rax],al
    3fcb:	add    BYTE PTR [rax],al
    3fcd:	add    BYTE PTR [rax],al
	...

0000000000003fd0 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    3fd0:	push   rbp
    3fd1:	mov    rbp,rsp
    3fd4:	sub    rsp,0x40
    3fd8:	mov    QWORD PTR [rsp+0x20],rbx
    3fdd:	mov    QWORD PTR [rsp+0x28],r12
    3fe2:	mov    QWORD PTR [rsp+0x30],r13
    3fe7:	mov    rbx,rdi
    3fea:	mov    QWORD PTR [rsp+0x10],0x0
    3ff3:	mov    QWORD PTR [rsp],rsi
    3ff7:	mov    r12,rsi
    3ffa:	mov    rsi,r12
    3ffd:	mov    rdi,rbx
    4000:	call   4005 <botlish_fn_45+0x35>
			4001: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4005:	test   rax,rax
    4008:	mov    r13,rax
    400b:	je     41f5 <botlish_fn_45+0x225>
    4011:	mov    rsi,r12
    4014:	mov    rdi,rbx
    4017:	call   401c <botlish_fn_45+0x4c>
			4018: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    401c:	mov    rcx,rax
    401f:	test   rcx,rcx
    4022:	je     41f5 <botlish_fn_45+0x225>
    4028:	mov    edx,0x1
    402d:	mov    rax,r13
    4030:	test   rax,0x1
    4036:	je     4044 <botlish_fn_45+0x74>
    403c:	mov    r13,rax
    403f:	jmp    4068 <botlish_fn_45+0x98>
    4044:	xor    edx,edx
    4046:	test   rax,0x7
    404c:	je     405a <botlish_fn_45+0x8a>
    4052:	mov    r13,rax
    4055:	jmp    4068 <botlish_fn_45+0x98>
    405a:	movzx  rsi,BYTE PTR [rax]
    405e:	mov    r13,rax
    4061:	cmp    sil,0x1
    4065:	sete   dl
    4068:	test   dl,dl
    406a:	jne    408b <botlish_fn_45+0xbb>
    4070:	mov    rdi,rbx
    4073:	mov    r10,QWORD PTR [rdi+0x10]
    4077:	mov    rcx,QWORD PTR [r10+0x40]
    407b:	xor    rdx,rdx
    407e:	mov    rsi,r13
    4081:	call   4086 <botlish_fn_45+0xb6>
			4082: R_X86_64_PLT32	rt_type_error-0x4
    4086:	jmp    41f5 <botlish_fn_45+0x225>
    408b:	mov    rsi,r13
    408e:	mov    eax,0x1
    4093:	test   rcx,0x1
    409a:	je     40a8 <botlish_fn_45+0xd8>
    40a0:	mov    r8,rcx
    40a3:	jmp    40cb <botlish_fn_45+0xfb>
    40a8:	xor    eax,eax
    40aa:	test   rcx,0x7
    40b1:	je     40bf <botlish_fn_45+0xef>
    40b7:	mov    r8,rcx
    40ba:	jmp    40cb <botlish_fn_45+0xfb>
    40bf:	movzx  rax,BYTE PTR [rcx]
    40c3:	mov    r8,rcx
    40c6:	cmp    al,0x1
    40c8:	sete   al
    40cb:	test   al,al
    40cd:	jne    40ee <botlish_fn_45+0x11e>
    40d3:	mov    rdi,rbx
    40d6:	mov    rax,QWORD PTR [rdi+0x10]
    40da:	mov    rcx,QWORD PTR [rax+0x40]
    40de:	xor    rdx,rdx
    40e1:	mov    rsi,r8
    40e4:	call   40e9 <botlish_fn_45+0x119>
			40e5: R_X86_64_PLT32	rt_type_error-0x4
    40e9:	jmp    41f5 <botlish_fn_45+0x225>
    40ee:	mov    rcx,r8
    40f1:	mov    rax,rsi
    40f4:	and    rax,rcx
    40f7:	test   rax,0x1
    40fd:	jne    4123 <botlish_fn_45+0x153>
    4103:	mov    rdx,r8
    4106:	mov    rdi,rbx
    4109:	call   410e <botlish_fn_45+0x13e>
			410a: R_X86_64_PLT32	rt_int_cmp-0x4
    410e:	mov    ecx,0x2
    4113:	test   rax,rax
    4116:	cmovg  rcx,QWORD PTR [rip+0x10a]        # 4228 <botlish_fn_45+0x258>
    411e:	jmp    4136 <botlish_fn_45+0x166>
    4123:	mov    ecx,0x2
    4128:	mov    rax,r8
    412b:	cmp    rsi,rax
    412e:	cmovg  rcx,QWORD PTR [rip+0xf2]        # 4228 <botlish_fn_45+0x258>
    4136:	cmp    rcx,0x6
    413a:	je     41be <botlish_fn_45+0x1ee>
    4140:	mov    rsi,r12
    4143:	mov    rdi,rbx
    4146:	call   414b <botlish_fn_45+0x17b>
			4147: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    414b:	test   rdx,rdx
    414e:	je     41f5 <botlish_fn_45+0x225>
    4154:	shl    rax,1
    4157:	mov    rsi,rax
    415a:	or     rsi,0x1
    415e:	mov    QWORD PTR [rsp+0x8],rsi
    4163:	mov    QWORD PTR [rsp+0x10],0x5
    416c:	mov    rax,rsi
    416f:	sar    rax,1
    4172:	imul   QWORD PTR [rip+0xb7]        # 4230 <botlish_fn_45+0x260>
    4179:	seto   cl
    417c:	or     rax,0x1
    4180:	test   cl,cl
    4182:	jne    4190 <botlish_fn_45+0x1c0>
    4188:	mov    rdx,rax
    418b:	jmp    41a0 <botlish_fn_45+0x1d0>
    4190:	mov    edx,0x5
    4195:	mov    rdi,rbx
    4198:	call   419d <botlish_fn_45+0x1cd>
			4199: R_X86_64_PLT32	rt_int_mul-0x4
    419d:	mov    rdx,rax
    41a0:	mov    QWORD PTR [rsp+0x8],rdx
    41a5:	mov    rsi,r12
    41a8:	mov    rdi,rbx
    41ab:	call   41b0 <botlish_fn_45+0x1e0>
			41ac: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41b0:	test   rax,rax
    41b3:	je     41f5 <botlish_fn_45+0x225>
    41b9:	jmp    4210 <botlish_fn_45+0x240>
    41be:	mov    rsi,r12
    41c1:	mov    rdi,rbx
    41c4:	call   41c9 <botlish_fn_45+0x1f9>
			41c5: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    41c9:	test   rdx,rdx
    41cc:	je     41f5 <botlish_fn_45+0x225>
    41d2:	shl    rax,1
    41d5:	mov    rdx,rax
    41d8:	or     rdx,0x1
    41dc:	mov    QWORD PTR [rsp+0x8],rdx
    41e1:	mov    rsi,r12
    41e4:	mov    rdi,rbx
    41e7:	call   41ec <botlish_fn_45+0x21c>
			41e8: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41ec:	test   rax,rax
    41ef:	jne    4210 <botlish_fn_45+0x240>
    41f5:	xor    rax,rax
    41f8:	mov    rbx,QWORD PTR [rsp+0x20]
    41fd:	mov    r12,QWORD PTR [rsp+0x28]
    4202:	mov    r13,QWORD PTR [rsp+0x30]
    4207:	add    rsp,0x40
    420b:	mov    rsp,rbp
    420e:	pop    rbp
    420f:	ret
    4210:	mov    rbx,QWORD PTR [rsp+0x20]
    4215:	mov    r12,QWORD PTR [rsp+0x28]
    421a:	mov    r13,QWORD PTR [rsp+0x30]
    421f:	add    rsp,0x40
    4223:	mov    rsp,rbp
    4226:	pop    rbp
    4227:	ret
    4228:	(bad)
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
    49a0:	mov    r8,rdx
    49a3:	cmp    rsi,0x6
    49a7:	je     49c0 <botlish_fn_48+0x24>
    49ad:	call   49b2 <botlish_fn_48+0x16>
			49ae: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    49b2:	test   rax,rax
    49b5:	je     49d1 <botlish_fn_48+0x35>
    49bb:	mov    rsp,rbp
    49be:	pop    rbp
    49bf:	ret
    49c0:	mov    rsi,r8
    49c3:	call   49c8 <botlish_fn_48+0x2c>
			49c4: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    49c8:	test   rax,rax
    49cb:	jne    49d9 <botlish_fn_48+0x3d>
    49d1:	xor    rax,rax
    49d4:	mov    rsp,rbp
    49d7:	pop    rbp
    49d8:	ret
    49d9:	mov    rsp,rbp
    49dc:	pop    rbp
    49dd:	ret

00000000000049de <botlish_entry_48: row_new<bool, int>>:
    49de:	push   rbp
    49df:	mov    rbp,rsp
    49e2:	mov    rsi,QWORD PTR [rdx]
    49e5:	mov    rdx,QWORD PTR [rdx+0x8]
    49e9:	sar    rdx,1
    49ec:	call   49f1 <botlish_entry_48+0x13>
			49ed: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    49f1:	mov    rsp,rbp
    49f4:	pop    rbp
    49f5:	ret

00000000000049f6 <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    49f6:	push   rbp
    49f7:	mov    rbp,rsp
    49fa:	sub    rsp,0x70
    49fe:	mov    QWORD PTR [rsp+0x40],rbx
    4a03:	mov    QWORD PTR [rsp+0x48],r12
    4a08:	mov    QWORD PTR [rsp+0x50],r13
    4a0d:	mov    QWORD PTR [rsp+0x58],r14
    4a12:	mov    QWORD PTR [rsp+0x60],r15
    4a17:	mov    QWORD PTR [rsp+0x28],rdi
    4a1c:	mov    QWORD PTR [rsp],rsi
    4a20:	mov    r14,rsi
    4a23:	mov    QWORD PTR [rsp+0x8],rdx
    4a28:	mov    QWORD PTR [rsp+0x10],rcx
    4a2d:	mov    r13,rcx
    4a30:	mov    rbx,r8
    4a33:	mov    r15,r9
    4a36:	cmp    rbx,r15
    4a39:	jge    4b44 <botlish_fn_49+0x14e>
    4a3f:	mov    r12,rdx
    4a42:	mov    rdx,QWORD PTR [r12+0x8]
    4a47:	mov    rcx,rbx
    4a4a:	shl    rcx,1
    4a4d:	or     rcx,0x1
    4a51:	sar    rcx,1
    4a54:	cmp    rcx,rdx
    4a57:	jb     4a85 <botlish_fn_49+0x8f>
    4a5d:	mov    rdx,rbx
    4a60:	shl    rdx,1
    4a63:	or     rdx,0x1
    4a67:	mov    rsi,r12
    4a6a:	mov    rdi,QWORD PTR [rsp+0x28]
    4a6f:	call   4a74 <botlish_fn_49+0x7e>
			4a70: R_X86_64_PLT32	rt_list_get-0x4
    4a74:	test   rax,rax
    4a77:	je     4b02 <botlish_fn_49+0x10c>
    4a7d:	mov    rdx,rax
    4a80:	jmp    4a8e <botlish_fn_49+0x98>
    4a85:	mov    rax,QWORD PTR [r12+0x10]
    4a8a:	mov    rdx,QWORD PTR [rax+rcx*8]
    4a8e:	mov    QWORD PTR [rsp+0x18],rdx
    4a93:	mov    QWORD PTR [rsp+0x30],rdx
    4a98:	mov    rax,QWORD PTR [r13+0x8]
    4a9c:	mov    rcx,rbx
    4a9f:	shl    rcx,1
    4aa2:	or     rcx,0x1
    4aa6:	sar    rcx,1
    4aa9:	cmp    rcx,rax
    4aac:	jb     4ada <botlish_fn_49+0xe4>
    4ab2:	mov    rdx,rbx
    4ab5:	shl    rdx,1
    4ab8:	or     rdx,0x1
    4abc:	mov    rsi,r13
    4abf:	mov    rdi,QWORD PTR [rsp+0x28]
    4ac4:	call   4ac9 <botlish_fn_49+0xd3>
			4ac5: R_X86_64_PLT32	rt_list_get-0x4
    4ac9:	test   rax,rax
    4acc:	je     4b02 <botlish_fn_49+0x10c>
    4ad2:	mov    rcx,rax
    4ad5:	jmp    4ae2 <botlish_fn_49+0xec>
    4ada:	mov    rax,QWORD PTR [r13+0x10]
    4ade:	mov    rcx,QWORD PTR [rax+rcx*8]
    4ae2:	mov    QWORD PTR [rsp+0x20],rcx
    4ae7:	mov    rdx,QWORD PTR [rsp+0x30]
    4aec:	mov    rsi,r14
    4aef:	mov    rdi,QWORD PTR [rsp+0x28]
    4af4:	call   4af9 <botlish_fn_49+0x103>
			4af5: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4af9:	test   rax,rax
    4afc:	jne    4b27 <botlish_fn_49+0x131>
    4b02:	xor    rax,rax
    4b05:	mov    rbx,QWORD PTR [rsp+0x40]
    4b0a:	mov    r12,QWORD PTR [rsp+0x48]
    4b0f:	mov    r13,QWORD PTR [rsp+0x50]
    4b14:	mov    r14,QWORD PTR [rsp+0x58]
    4b19:	mov    r15,QWORD PTR [rsp+0x60]
    4b1e:	add    rsp,0x70
    4b22:	mov    rsp,rbp
    4b25:	pop    rbp
    4b26:	ret
    4b27:	mov    QWORD PTR [rsp],r14
    4b2b:	mov    QWORD PTR [rsp+0x8],r12
    4b30:	mov    QWORD PTR [rsp+0x10],r13
    4b35:	add    rbx,0x1
    4b3c:	mov    rdx,r12
    4b3f:	jmp    4a36 <botlish_fn_49+0x40>
    4b44:	mov    rax,r14
    4b47:	mov    rbx,QWORD PTR [rsp+0x40]
    4b4c:	mov    r12,QWORD PTR [rsp+0x48]
    4b51:	mov    r13,QWORD PTR [rsp+0x50]
    4b56:	mov    r14,QWORD PTR [rsp+0x58]
    4b5b:	mov    r15,QWORD PTR [rsp+0x60]
    4b60:	add    rsp,0x70
    4b64:	mov    rsp,rbp
    4b67:	pop    rbp
    4b68:	ret

0000000000004b69 <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4b69:	push   rbp
    4b6a:	mov    rbp,rsp
    4b6d:	mov    rsi,QWORD PTR [rdx]
    4b70:	mov    r10,QWORD PTR [rdx+0x8]
    4b74:	mov    rcx,QWORD PTR [rdx+0x10]
    4b78:	mov    r8,QWORD PTR [rdx+0x18]
    4b7c:	mov    r9,QWORD PTR [rdx+0x20]
    4b80:	sar    r8,1
    4b83:	sar    r9,1
    4b86:	mov    rdx,r10
    4b89:	call   4b8e <botlish_entry_49+0x25>
			4b8a: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4b8e:	mov    rsp,rbp
    4b91:	pop    rbp
    4b92:	ret

0000000000004b93 <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4b93:	push   rbp
    4b94:	mov    rbp,rsp
    4b97:	sub    rsp,0x40
    4b9b:	mov    QWORD PTR [rsp+0x20],rbx
    4ba0:	mov    QWORD PTR [rsp+0x28],r12
    4ba5:	mov    QWORD PTR [rsp+0x30],r13
    4baa:	mov    QWORD PTR [rsp+0x38],r14
    4baf:	mov    r12,rdi
    4bb2:	mov    QWORD PTR [rsp],rsi
    4bb6:	mov    rbx,rsi
    4bb9:	mov    QWORD PTR [rsp+0x8],rcx
    4bbe:	mov    r14,rcx
    4bc1:	mov    QWORD PTR [rsp+0x10],r8
    4bc6:	mov    rsi,r8
    4bc9:	mov    rdi,r12
    4bcc:	call   4bd1 <botlish_fn_50+0x3e>
			4bcd: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4bd1:	test   rax,rax
    4bd4:	je     4c10 <botlish_fn_50+0x7d>
    4bda:	mov    QWORD PTR [rsp+0x10],rax
    4bdf:	mov    r13,rax
    4be2:	mov    rsi,r14
    4be5:	mov    rdi,r12
    4be8:	call   4bed <botlish_fn_50+0x5a>
			4be9: R_X86_64_PLT32	rt_list_len-0x4
    4bed:	xor    r8,r8
    4bf0:	mov    r9,rax
    4bf3:	sar    r9,1
    4bf6:	mov    rcx,r14
    4bf9:	mov    rdx,rbx
    4bfc:	mov    rsi,r13
    4bff:	mov    rdi,r12
    4c02:	call   4c07 <botlish_fn_50+0x74>
			4c03: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4c07:	test   rax,rax
    4c0a:	jne    4c30 <botlish_fn_50+0x9d>
    4c10:	xor    rax,rax
    4c13:	mov    rbx,QWORD PTR [rsp+0x20]
    4c18:	mov    r12,QWORD PTR [rsp+0x28]
    4c1d:	mov    r13,QWORD PTR [rsp+0x30]
    4c22:	mov    r14,QWORD PTR [rsp+0x38]
    4c27:	add    rsp,0x40
    4c2b:	mov    rsp,rbp
    4c2e:	pop    rbp
    4c2f:	ret
    4c30:	mov    rbx,QWORD PTR [rsp+0x20]
    4c35:	mov    r12,QWORD PTR [rsp+0x28]
    4c3a:	mov    r13,QWORD PTR [rsp+0x30]
    4c3f:	mov    r14,QWORD PTR [rsp+0x38]
    4c44:	add    rsp,0x40
    4c48:	mov    rsp,rbp
    4c4b:	pop    rbp
    4c4c:	ret

0000000000004c4d <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4c4d:	push   rbp
    4c4e:	mov    rbp,rsp
    4c51:	mov    rsi,QWORD PTR [rdx]
    4c54:	mov    r8,QWORD PTR [rdx+0x8]
    4c58:	mov    r9,r8
    4c5b:	mov    rcx,QWORD PTR [rdx+0x10]
    4c5f:	mov    r8,QWORD PTR [rdx+0x18]
    4c63:	mov    rdx,r9
    4c66:	sar    rdx,1
    4c69:	call   4c6e <botlish_entry_50+0x21>
			4c6a: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4c6e:	mov    rsp,rbp
    4c71:	pop    rbp
    4c72:	ret

0000000000004c73 <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4c73:	push   rbp
    4c74:	mov    rbp,rsp
    4c77:	sub    rsp,0x80
    4c7e:	mov    QWORD PTR [rsp+0x50],rbx
    4c83:	mov    QWORD PTR [rsp+0x58],r12
    4c88:	mov    QWORD PTR [rsp+0x60],r13
    4c8d:	mov    QWORD PTR [rsp+0x68],r14
    4c92:	mov    QWORD PTR [rsp+0x70],r15
    4c97:	mov    r12,rdx
    4c9a:	mov    r15,r8
    4c9d:	mov    QWORD PTR [rsp+0x30],rdi
    4ca2:	mov    rdi,QWORD PTR [rbp+0x10]
    4ca6:	mov    r14,QWORD PTR [rbp+0x18]
    4caa:	mov    QWORD PTR [rsp+0x28],0x0
    4cb3:	mov    QWORD PTR [rsp],rsi
    4cb7:	mov    QWORD PTR [rsp+0x8],rcx
    4cbc:	mov    r13,rcx
    4cbf:	mov    QWORD PTR [rsp+0x10],r9
    4cc4:	mov    QWORD PTR [rsp+0x18],rdi
    4cc9:	mov    QWORD PTR [rsp+0x20],r14
    4cce:	mov    rbx,rsi
    4cd1:	mov    QWORD PTR [rsp+0x38],r9
    4cd6:	mov    QWORD PTR [rsp+0x40],rdi
    4cdb:	mov    rsi,rbx
    4cde:	mov    rdi,QWORD PTR [rsp+0x30]
    4ce3:	call   4ce8 <botlish_fn_51+0x75>
			4ce4: R_X86_64_PLT32	rt_list_len-0x4
    4ce8:	sar    rax,1
    4ceb:	cmp    r12,rax
    4cee:	jge    4e09 <botlish_fn_51+0x196>
    4cf4:	mov    rcx,QWORD PTR [rbx+0x8]
    4cf8:	mov    rax,r12
    4cfb:	shl    rax,1
    4cfe:	or     rax,0x1
    4d02:	sar    rax,1
    4d05:	cmp    rax,rcx
    4d08:	jb     4d36 <botlish_fn_51+0xc3>
    4d0e:	mov    rdx,r12
    4d11:	shl    rdx,1
    4d14:	or     rdx,0x1
    4d18:	mov    rsi,rbx
    4d1b:	mov    rdi,QWORD PTR [rsp+0x30]
    4d20:	call   4d25 <botlish_fn_51+0xb2>
			4d21: R_X86_64_PLT32	rt_list_get-0x4
    4d25:	test   rax,rax
    4d28:	je     4e26 <botlish_fn_51+0x1b3>
    4d2e:	mov    rcx,rax
    4d31:	jmp    4d3e <botlish_fn_51+0xcb>
    4d36:	mov    rcx,QWORD PTR [rbx+0x10]
    4d3a:	mov    rcx,QWORD PTR [rcx+rax*8]
    4d3e:	mov    QWORD PTR [rsp+0x28],rcx
    4d43:	mov    rdx,r15
    4d46:	mov    rsi,r13
    4d49:	mov    rdi,QWORD PTR [rsp+0x30]
    4d4e:	mov    r8,r14
    4d51:	call   4d56 <botlish_fn_51+0xe3>
			4d52: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4d56:	test   rax,rax
    4d59:	je     4e26 <botlish_fn_51+0x1b3>
    4d5f:	mov    QWORD PTR [rsp+0x28],rax
    4d64:	mov    rcx,rax
    4d67:	mov    rsi,QWORD PTR [rsp+0x38]
    4d6c:	mov    rdx,QWORD PTR [rsp+0x40]
    4d71:	mov    rdi,QWORD PTR [rsp+0x30]
    4d76:	call   4d7b <botlish_fn_51+0x108>
			4d77: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4d7b:	test   rax,rax
    4d7e:	je     4e26 <botlish_fn_51+0x1b3>
    4d84:	mov    QWORD PTR [rsp+0x10],rax
    4d89:	mov    QWORD PTR [rsp+0x48],rax
    4d8e:	mov    QWORD PTR [rsp+0x28],0x3
    4d97:	mov    rsi,QWORD PTR [rsp+0x40]
    4d9c:	test   rsi,0x1
    4da3:	je     4dc2 <botlish_fn_51+0x14f>
    4da9:	mov    rsi,QWORD PTR [rsp+0x40]
    4dae:	mov    rax,rsi
    4db1:	add    rax,0x2
    4db5:	seto   sil
    4db9:	test   sil,sil
    4dbc:	je     4dd6 <botlish_fn_51+0x163>
    4dc2:	mov    edx,0x3
    4dc7:	mov    rsi,QWORD PTR [rsp+0x40]
    4dcc:	mov    rdi,QWORD PTR [rsp+0x30]
    4dd1:	call   4dd6 <botlish_fn_51+0x163>
			4dd2: R_X86_64_PLT32	rt_int_add-0x4
    4dd6:	mov    QWORD PTR [rsp],rbx
    4dda:	mov    QWORD PTR [rsp+0x8],r13
    4ddf:	mov    rcx,QWORD PTR [rsp+0x48]
    4de4:	mov    QWORD PTR [rsp+0x10],rcx
    4de9:	mov    QWORD PTR [rsp+0x18],rax
    4dee:	mov    QWORD PTR [rsp+0x20],r14
    4df3:	add    r12,0x1
    4dfa:	mov    QWORD PTR [rsp+0x38],rcx
    4dff:	mov    QWORD PTR [rsp+0x40],rax
    4e04:	jmp    4cdb <botlish_fn_51+0x68>
    4e09:	mov    rdx,QWORD PTR [rsp+0x40]
    4e0e:	mov    rsi,QWORD PTR [rsp+0x38]
    4e13:	mov    rdi,QWORD PTR [rsp+0x30]
    4e18:	call   4e1d <botlish_fn_51+0x1aa>
			4e19: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4e1d:	test   rax,rax
    4e20:	jne    4e4e <botlish_fn_51+0x1db>
    4e26:	xor    rax,rax
    4e29:	mov    rbx,QWORD PTR [rsp+0x50]
    4e2e:	mov    r12,QWORD PTR [rsp+0x58]
    4e33:	mov    r13,QWORD PTR [rsp+0x60]
    4e38:	mov    r14,QWORD PTR [rsp+0x68]
    4e3d:	mov    r15,QWORD PTR [rsp+0x70]
    4e42:	add    rsp,0x80
    4e49:	mov    rsp,rbp
    4e4c:	pop    rbp
    4e4d:	ret
    4e4e:	mov    rbx,QWORD PTR [rsp+0x50]
    4e53:	mov    r12,QWORD PTR [rsp+0x58]
    4e58:	mov    r13,QWORD PTR [rsp+0x60]
    4e5d:	mov    r14,QWORD PTR [rsp+0x68]
    4e62:	mov    r15,QWORD PTR [rsp+0x70]
    4e67:	add    rsp,0x80
    4e6e:	mov    rsp,rbp
    4e71:	pop    rbp
    4e72:	ret

0000000000004e73 <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4e73:	push   rbp
    4e74:	mov    rbp,rsp
    4e77:	sub    rsp,0x10
    4e7b:	mov    rsi,QWORD PTR [rdx]
    4e7e:	mov    r8,QWORD PTR [rdx+0x8]
    4e82:	mov    r11,r8
    4e85:	mov    rcx,QWORD PTR [rdx+0x10]
    4e89:	mov    r8,QWORD PTR [rdx+0x18]
    4e8d:	mov    r9,QWORD PTR [rdx+0x20]
    4e91:	mov    rax,QWORD PTR [rdx+0x28]
    4e95:	mov    r10,QWORD PTR [rdx+0x30]
    4e99:	mov    rdx,r11
    4e9c:	sar    rdx,1
    4e9f:	sar    r8,1
    4ea2:	mov    QWORD PTR [rsp],rax
    4ea6:	mov    QWORD PTR [rsp+0x8],r10
    4eab:	call   4eb0 <botlish_entry_51+0x3d>
			4eac: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4eb0:	add    rsp,0x10
    4eb4:	mov    rsp,rbp
    4eb7:	pop    rbp
    4eb8:	ret

0000000000004eb9 <botlish_fn_52: csv_records_generic<str, bool>>:
    4eb9:	push   rbp
    4eba:	mov    rbp,rsp
    4ebd:	sub    rsp,0x70
    4ec1:	mov    QWORD PTR [rsp+0x40],rbx
    4ec6:	mov    QWORD PTR [rsp+0x48],r12
    4ecb:	mov    QWORD PTR [rsp+0x50],r13
    4ed0:	mov    QWORD PTR [rsp+0x58],r14
    4ed5:	mov    QWORD PTR [rsp+0x60],r15
    4eda:	mov    r12,rdi
    4edd:	mov    QWORD PTR [rsp+0x20],0x0
    4ee6:	mov    QWORD PTR [rsp+0x28],0x0
    4eef:	mov    QWORD PTR [rsp+0x30],0x0
    4ef8:	mov    QWORD PTR [rsp+0x10],rsi
    4efd:	mov    QWORD PTR [rsp+0x18],rdx
    4f02:	mov    r13,rdx
    4f05:	mov    rdi,r12
    4f08:	call   4f0d <botlish_fn_52+0x54>
			4f09: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4f0d:	mov    rcx,rax
    4f10:	mov    r14,rax
    4f13:	test   rax,rcx
    4f16:	je     507f <botlish_fn_52+0x1c6>
    4f1c:	mov    rax,r14
    4f1f:	mov    QWORD PTR [rsp+0x10],rax
    4f24:	mov    rsi,r14
    4f27:	mov    rdi,r12
    4f2a:	call   4f2f <botlish_fn_52+0x76>
			4f2b: R_X86_64_PLT32	rt_list_len-0x4
    4f2f:	sar    rax,1
    4f32:	cmp    rax,0x1
    4f36:	jle    5068 <botlish_fn_52+0x1af>
    4f3c:	mov    rax,r14
    4f3f:	mov    rax,QWORD PTR [rax+0x8]
    4f43:	test   rax,rax
    4f46:	jne    4f6d <botlish_fn_52+0xb4>
    4f4c:	mov    edx,0x1
    4f51:	mov    rsi,r14
    4f54:	mov    rdi,r12
    4f57:	call   4f5c <botlish_fn_52+0xa3>
			4f58: R_X86_64_PLT32	rt_list_get-0x4
    4f5c:	test   rax,rax
    4f5f:	je     507f <botlish_fn_52+0x1c6>
    4f65:	mov    rbx,rax
    4f68:	jmp    4f74 <botlish_fn_52+0xbb>
    4f6d:	mov    rax,QWORD PTR [r14+0x10]
    4f71:	mov    rbx,QWORD PTR [rax]
    4f74:	mov    QWORD PTR [rsp+0x20],rbx
    4f79:	mov    rsi,rbx
    4f7c:	mov    rdi,r12
    4f7f:	call   4f84 <botlish_fn_52+0xcb>
			4f80: R_X86_64_PLT32	rt_list_len-0x4
    4f84:	mov    r15,rbx
    4f87:	mov    rbx,rax
    4f8a:	mov    rax,QWORD PTR [r14+0x8]
    4f8e:	cmp    rax,0x1
    4f92:	ja     4fb9 <botlish_fn_52+0x100>
    4f98:	mov    edx,0x3
    4f9d:	mov    rsi,r14
    4fa0:	mov    rdi,r12
    4fa3:	call   4fa8 <botlish_fn_52+0xef>
			4fa4: R_X86_64_PLT32	rt_list_get-0x4
    4fa8:	test   rax,rax
    4fab:	je     507f <botlish_fn_52+0x1c6>
    4fb1:	mov    rcx,rax
    4fb4:	jmp    4fc1 <botlish_fn_52+0x108>
    4fb9:	mov    rax,QWORD PTR [r14+0x10]
    4fbd:	mov    rcx,QWORD PTR [rax+0x8]
    4fc1:	mov    QWORD PTR [rsp+0x28],rcx
    4fc6:	mov    rax,rbx
    4fc9:	mov    r8,rax
    4fcc:	sar    r8,1
    4fcf:	mov    rbx,r13
    4fd2:	mov    r13,r8
    4fd5:	mov    rdx,r13
    4fd8:	mov    rsi,r15
    4fdb:	mov    rdi,r12
    4fde:	mov    r8,rbx
    4fe1:	call   4fe6 <botlish_fn_52+0x12d>
			4fe2: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4fe6:	test   rax,rax
    4fe9:	je     507f <botlish_fn_52+0x1c6>
    4fef:	mov    QWORD PTR [rsp+0x28],rax
    4ff4:	mov    rsi,rax
    4ff7:	mov    rdi,r12
    4ffa:	call   4fff <botlish_fn_52+0x146>
			4ffb: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    4fff:	test   rax,rax
    5002:	je     507f <botlish_fn_52+0x1c6>
    5008:	mov    QWORD PTR [rsp+0x28],rax
    500d:	mov    r9,rax
    5010:	mov    edi,0x3
    5015:	mov    QWORD PTR [rsp+0x30],0x3
    501e:	mov    edx,0x2
    5023:	mov    QWORD PTR [rsp],rdi
    5027:	mov    QWORD PTR [rsp+0x8],rbx
    502c:	mov    rcx,r15
    502f:	mov    rsi,r14
    5032:	mov    rdi,r12
    5035:	mov    r8,r13
    5038:	call   503d <botlish_fn_52+0x184>
			5039: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    503d:	test   rax,rax
    5040:	je     507f <botlish_fn_52+0x1c6>
    5046:	mov    rbx,QWORD PTR [rsp+0x40]
    504b:	mov    r12,QWORD PTR [rsp+0x48]
    5050:	mov    r13,QWORD PTR [rsp+0x50]
    5055:	mov    r14,QWORD PTR [rsp+0x58]
    505a:	mov    r15,QWORD PTR [rsp+0x60]
    505f:	add    rsp,0x70
    5063:	mov    rsp,rbp
    5066:	pop    rbp
    5067:	ret
    5068:	xor    rdx,rdx
    506b:	mov    rdi,r12
    506e:	mov    rsi,rdx
    5071:	call   5076 <botlish_fn_52+0x1bd>
			5072: R_X86_64_PLT32	rt_list_new-0x4
    5076:	test   rax,rax
    5079:	jne    50a4 <botlish_fn_52+0x1eb>
    507f:	xor    rax,rax
    5082:	mov    rbx,QWORD PTR [rsp+0x40]
    5087:	mov    r12,QWORD PTR [rsp+0x48]
    508c:	mov    r13,QWORD PTR [rsp+0x50]
    5091:	mov    r14,QWORD PTR [rsp+0x58]
    5096:	mov    r15,QWORD PTR [rsp+0x60]
    509b:	add    rsp,0x70
    509f:	mov    rsp,rbp
    50a2:	pop    rbp
    50a3:	ret
    50a4:	mov    rbx,QWORD PTR [rsp+0x40]
    50a9:	mov    r12,QWORD PTR [rsp+0x48]
    50ae:	mov    r13,QWORD PTR [rsp+0x50]
    50b3:	mov    r14,QWORD PTR [rsp+0x58]
    50b8:	mov    r15,QWORD PTR [rsp+0x60]
    50bd:	add    rsp,0x70
    50c1:	mov    rsp,rbp
    50c4:	pop    rbp
    50c5:	ret

00000000000050c6 <botlish_entry_52: csv_records_generic<str, bool>>:
    50c6:	push   rbp
    50c7:	mov    rbp,rsp
    50ca:	mov    rsi,QWORD PTR [rdx]
    50cd:	mov    rdx,QWORD PTR [rdx+0x8]
    50d1:	call   50d6 <botlish_entry_52+0x10>
			50d2: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50d6:	mov    rsp,rbp
    50d9:	pop    rbp
    50da:	ret

00000000000050db <botlish_fn_53: csv_records<str>>:
    50db:	push   rbp
    50dc:	mov    rbp,rsp
    50df:	sub    rsp,0x10
    50e3:	mov    QWORD PTR [rsp],rsi
    50e7:	mov    edx,0x2
    50ec:	mov    QWORD PTR [rsp+0x8],0x2
    50f5:	call   50fa <botlish_fn_53+0x1f>
			50f6: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50fa:	test   rax,rax
    50fd:	jne    510f <botlish_fn_53+0x34>
    5103:	xor    rax,rax
    5106:	add    rsp,0x10
    510a:	mov    rsp,rbp
    510d:	pop    rbp
    510e:	ret
    510f:	add    rsp,0x10
    5113:	mov    rsp,rbp
    5116:	pop    rbp
    5117:	ret

0000000000005118 <botlish_entry_53: csv_records<str>>:
    5118:	push   rbp
    5119:	mov    rbp,rsp
    511c:	mov    rsi,QWORD PTR [rdx]
    511f:	call   5124 <botlish_entry_53+0xc>
			5120: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    5124:	mov    rsp,rbp
    5127:	pop    rbp
    5128:	ret

0000000000005129 <botlish_fn_54: csv_records_presized<str>>:
    5129:	push   rbp
    512a:	mov    rbp,rsp
    512d:	sub    rsp,0x10
    5131:	mov    QWORD PTR [rsp],rsi
    5135:	mov    edx,0x6
    513a:	mov    QWORD PTR [rsp+0x8],0x6
    5143:	call   5148 <botlish_fn_54+0x1f>
			5144: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5148:	test   rax,rax
    514b:	jne    515d <botlish_fn_54+0x34>
    5151:	xor    rax,rax
    5154:	add    rsp,0x10
    5158:	mov    rsp,rbp
    515b:	pop    rbp
    515c:	ret
    515d:	add    rsp,0x10
    5161:	mov    rsp,rbp
    5164:	pop    rbp
    5165:	ret

0000000000005166 <botlish_entry_54: csv_records_presized<str>>:
    5166:	push   rbp
    5167:	mov    rbp,rsp
    516a:	mov    rsi,QWORD PTR [rdx]
    516d:	call   5172 <botlish_entry_54+0xc>
			516e: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5172:	mov    rsp,rbp
    5175:	pop    rbp
    5176:	ret
	...

0000000000005178 <botlish_fn_55: sample<generic>>:
    5178:	push   rbp
    5179:	mov    rbp,rsp
    517c:	sub    rsp,0xc0
    5183:	mov    QWORD PTR [rsp+0x90],rbx
    518b:	mov    QWORD PTR [rsp+0x98],r12
    5193:	mov    QWORD PTR [rsp+0xa0],r13
    519b:	mov    QWORD PTR [rsp+0xa8],r14
    51a3:	mov    QWORD PTR [rsp+0xb0],r15
    51ab:	mov    QWORD PTR [rsp+0x8],0x0
    51b4:	mov    QWORD PTR [rsp+0x10],0x0
    51bd:	mov    QWORD PTR [rsp+0x18],0x0
    51c6:	mov    QWORD PTR [rsp+0x20],0x0
    51cf:	mov    QWORD PTR [rsp+0x28],0x0
    51d8:	mov    QWORD PTR [rsp+0x30],0x0
    51e1:	mov    QWORD PTR [rsp+0x38],0x0
    51ea:	mov    rax,QWORD PTR [rdi+0x10]
    51ee:	mov    r13,rdi
    51f1:	mov    rsi,QWORD PTR [rax+0x50]
    51f5:	mov    QWORD PTR [rsp],rsi
    51f9:	call   51fe <botlish_fn_55+0x86>
			51fa: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    51fe:	mov    rsi,rax
    5201:	mov    r12,rax
    5204:	test   rax,rsi
    5207:	je     558c <botlish_fn_55+0x414>
    520d:	mov    rax,r12
    5210:	mov    QWORD PTR [rsp],rax
    5214:	mov    rdi,r13
    5217:	mov    rax,QWORD PTR [rdi+0x10]
    521b:	mov    rsi,QWORD PTR [rax+0x50]
    521f:	mov    QWORD PTR [rsp+0x8],rsi
    5224:	call   5229 <botlish_fn_55+0xb1>
			5225: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5229:	mov    rbx,rax
    522c:	test   rbx,rbx
    522f:	je     558c <botlish_fn_55+0x414>
    5235:	mov    rax,r12
    5238:	mov    rax,QWORD PTR [rax+0x8]
    523c:	test   rax,rax
    523f:	jne    5266 <botlish_fn_55+0xee>
    5245:	mov    edx,0x1
    524a:	mov    rsi,r12
    524d:	mov    rdi,r13
    5250:	call   5255 <botlish_fn_55+0xdd>
			5251: R_X86_64_PLT32	rt_list_get-0x4
    5255:	test   rax,rax
    5258:	je     558c <botlish_fn_55+0x414>
    525e:	mov    rsi,rax
    5261:	jmp    526e <botlish_fn_55+0xf6>
    5266:	mov    rax,QWORD PTR [r12+0x10]
    526b:	mov    rsi,QWORD PTR [rax]
    526e:	mov    QWORD PTR [rsp+0x8],rsi
    5273:	mov    r15,rsi
    5276:	mov    rax,QWORD PTR [r12+0x8]
    527b:	cmp    rax,0x1
    527f:	ja     52a6 <botlish_fn_55+0x12e>
    5285:	mov    edx,0x3
    528a:	mov    rsi,r12
    528d:	mov    rdi,r13
    5290:	call   5295 <botlish_fn_55+0x11d>
			5291: R_X86_64_PLT32	rt_list_get-0x4
    5295:	test   rax,rax
    5298:	je     558c <botlish_fn_55+0x414>
    529e:	mov    rsi,rax
    52a1:	jmp    52af <botlish_fn_55+0x137>
    52a6:	mov    rax,QWORD PTR [r12+0x10]
    52ab:	mov    rsi,QWORD PTR [rax+0x8]
    52af:	mov    QWORD PTR [rsp+0x10],rsi
    52b4:	mov    r14,rsi
    52b7:	mov    rax,QWORD PTR [rbx+0x8]
    52bb:	mov    rsi,rbx
    52be:	test   rax,rax
    52c1:	jne    52e5 <botlish_fn_55+0x16d>
    52c7:	mov    edx,0x1
    52cc:	mov    rdi,r13
    52cf:	call   52d4 <botlish_fn_55+0x15c>
			52d0: R_X86_64_PLT32	rt_list_get-0x4
    52d4:	test   rax,rax
    52d7:	je     558c <botlish_fn_55+0x414>
    52dd:	mov    rsi,rax
    52e0:	jmp    52ec <botlish_fn_55+0x174>
    52e5:	mov    rax,QWORD PTR [rsi+0x10]
    52e9:	mov    rsi,QWORD PTR [rax]
    52ec:	mov    QWORD PTR [rsp+0x18],rsi
    52f1:	mov    rdi,r13
    52f4:	mov    QWORD PTR [rsp+0x78],rsi
    52f9:	mov    rax,QWORD PTR [rdi+0x10]
    52fd:	mov    rdx,QWORD PTR [rax+0x58]
    5301:	mov    QWORD PTR [rsp+0x20],rdx
    5306:	mov    rsi,r15
    5309:	call   530e <botlish_fn_55+0x196>
			530a: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    530e:	test   rax,rax
    5311:	je     558c <botlish_fn_55+0x414>
    5317:	mov    QWORD PTR [rsp+0x20],rax
    531c:	mov    rbx,rax
    531f:	mov    rdi,r13
    5322:	mov    rax,QWORD PTR [rdi+0x10]
    5326:	mov    rdx,QWORD PTR [rax+0x58]
    532a:	mov    QWORD PTR [rsp+0x28],rdx
    532f:	mov    rsi,QWORD PTR [rsp+0x78]
    5334:	call   5339 <botlish_fn_55+0x1c1>
			5335: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5339:	test   rax,rax
    533c:	je     558c <botlish_fn_55+0x414>
    5342:	mov    rcx,rbx
    5345:	mov    rdx,rcx
    5348:	and    rdx,rax
    534b:	test   rdx,0x1
    5352:	jne    5374 <botlish_fn_55+0x1fc>
    5358:	mov    rdx,rax
    535b:	mov    rsi,rbx
    535e:	mov    rdi,r13
    5361:	call   5366 <botlish_fn_55+0x1ee>
			5362: R_X86_64_PLT32	rt_value_eq-0x4
    5366:	test   rax,rax
    5369:	je     558c <botlish_fn_55+0x414>
    536f:	jmp    538a <botlish_fn_55+0x212>
    5374:	mov    rdx,rax
    5377:	mov    rsi,rbx
    537a:	mov    eax,0x2
    537f:	cmp    rsi,rdx
    5382:	cmove  rax,QWORD PTR [rip+0x26e]        # 55f8 <botlish_fn_55+0x480>
    538a:	mov    ebx,0x6
    538f:	cmp    rax,0x6
    5393:	je     53ae <botlish_fn_55+0x236>
    5399:	mov    ebx,0x2
    539e:	mov    QWORD PTR [rsp],0x2
    53a6:	mov    rsi,r12
    53a9:	jmp    544d <botlish_fn_55+0x2d5>
    53ae:	mov    rsi,r15
    53b1:	mov    rdi,r13
    53b4:	call   53b9 <botlish_fn_55+0x241>
			53b5: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53b9:	test   rax,rax
    53bc:	mov    QWORD PTR [rsp+0x88],rax
    53c4:	je     558c <botlish_fn_55+0x414>
    53ca:	mov    rsi,QWORD PTR [rsp+0x78]
    53cf:	mov    rdi,r13
    53d2:	call   53d7 <botlish_fn_55+0x25f>
			53d3: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53d7:	test   rax,rax
    53da:	je     558c <botlish_fn_55+0x414>
    53e0:	mov    rcx,QWORD PTR [rsp+0x88]
    53e8:	mov    rdx,rcx
    53eb:	and    rdx,rax
    53ee:	test   rdx,0x1
    53f5:	jne    541c <botlish_fn_55+0x2a4>
    53fb:	mov    rdx,rax
    53fe:	mov    rsi,QWORD PTR [rsp+0x88]
    5406:	mov    rdi,r13
    5409:	call   540e <botlish_fn_55+0x296>
			540a: R_X86_64_PLT32	rt_value_eq-0x4
    540e:	test   rax,rax
    5411:	je     558c <botlish_fn_55+0x414>
    5417:	jmp    5437 <botlish_fn_55+0x2bf>
    541c:	mov    rdx,rax
    541f:	mov    rsi,QWORD PTR [rsp+0x88]
    5427:	mov    eax,0x2
    542c:	cmp    rsi,rdx
    542f:	cmove  rax,QWORD PTR [rip+0x1c1]        # 55f8 <botlish_fn_55+0x480>
    5437:	cmp    rax,0x6
    543b:	je     5446 <botlish_fn_55+0x2ce>
    5441:	mov    ebx,0x2
    5446:	mov    QWORD PTR [rsp],rbx
    544a:	mov    rsi,r12
    544d:	mov    rdi,r13
    5450:	call   5455 <botlish_fn_55+0x2dd>
			5451: R_X86_64_PLT32	rt_list_len-0x4
    5455:	mov    QWORD PTR [rsp+0x18],rax
    545a:	mov    rdi,r13
    545d:	mov    r12,rax
    5460:	mov    rax,QWORD PTR [rdi+0x10]
    5464:	mov    rdx,QWORD PTR [rax+0x58]
    5468:	mov    QWORD PTR [rsp+0x20],rdx
    546d:	mov    rsi,r15
    5470:	call   5475 <botlish_fn_55+0x2fd>
			5471: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5475:	test   rax,rax
    5478:	je     558c <botlish_fn_55+0x414>
    547e:	mov    QWORD PTR [rsp+0x20],rax
    5483:	mov    rdi,r13
    5486:	mov    QWORD PTR [rsp+0x88],rax
    548e:	mov    rax,QWORD PTR [rdi+0x10]
    5492:	mov    rdx,QWORD PTR [rax+0x60]
    5496:	mov    QWORD PTR [rsp+0x28],rdx
    549b:	mov    rsi,r15
    549e:	call   54a3 <botlish_fn_55+0x32b>
			549f: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54a3:	test   rax,rax
    54a6:	je     558c <botlish_fn_55+0x414>
    54ac:	mov    QWORD PTR [rsp+0x28],rax
    54b1:	mov    rdi,r13
    54b4:	mov    QWORD PTR [rsp+0x80],rax
    54bc:	mov    rax,QWORD PTR [rdi+0x10]
    54c0:	mov    rdx,QWORD PTR [rax+0x68]
    54c4:	mov    QWORD PTR [rsp+0x30],rdx
    54c9:	mov    rsi,r15
    54cc:	call   54d1 <botlish_fn_55+0x359>
			54cd: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54d1:	test   rax,rax
    54d4:	je     558c <botlish_fn_55+0x414>
    54da:	mov    QWORD PTR [rsp+0x8],rax
    54df:	mov    rdi,r13
    54e2:	mov    r15,rax
    54e5:	mov    rax,QWORD PTR [rdi+0x10]
    54e9:	mov    rdx,QWORD PTR [rax+0x58]
    54ed:	mov    QWORD PTR [rsp+0x30],rdx
    54f2:	mov    rsi,r14
    54f5:	call   54fa <botlish_fn_55+0x382>
			54f6: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54fa:	test   rax,rax
    54fd:	je     558c <botlish_fn_55+0x414>
    5503:	mov    QWORD PTR [rsp+0x30],rax
    5508:	mov    rdi,r13
    550b:	mov    QWORD PTR [rsp+0x78],rax
    5510:	mov    rax,QWORD PTR [rdi+0x10]
    5514:	mov    rdx,QWORD PTR [rax+0x68]
    5518:	mov    QWORD PTR [rsp+0x38],rdx
    551d:	mov    rsi,r14
    5520:	call   5525 <botlish_fn_55+0x3ad>
			5521: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5525:	test   rax,rax
    5528:	je     558c <botlish_fn_55+0x414>
    552e:	mov    QWORD PTR [rsp+0x10],rax
    5533:	lea    rdx,[rsp+0x40]
    5538:	mov    r9,r12
    553b:	mov    QWORD PTR [rsp+0x40],r9
    5540:	mov    rcx,QWORD PTR [rsp+0x88]
    5548:	mov    QWORD PTR [rsp+0x48],rcx
    554d:	mov    rcx,QWORD PTR [rsp+0x80]
    5555:	mov    QWORD PTR [rsp+0x50],rcx
    555a:	mov    rcx,r15
    555d:	mov    QWORD PTR [rsp+0x58],rcx
    5562:	mov    rcx,QWORD PTR [rsp+0x78]
    5567:	mov    QWORD PTR [rsp+0x60],rcx
    556c:	mov    QWORD PTR [rsp+0x68],rax
    5571:	mov    QWORD PTR [rsp+0x70],rbx
    5576:	mov    esi,0x7
    557b:	mov    rdi,r13
    557e:	call   5583 <botlish_fn_55+0x40b>
			557f: R_X86_64_PLT32	rt_list_new-0x4
    5583:	test   rax,rax
    5586:	jne    55c3 <botlish_fn_55+0x44b>
    558c:	xor    rax,rax
    558f:	mov    rbx,QWORD PTR [rsp+0x90]
    5597:	mov    r12,QWORD PTR [rsp+0x98]
    559f:	mov    r13,QWORD PTR [rsp+0xa0]
    55a7:	mov    r14,QWORD PTR [rsp+0xa8]
    55af:	mov    r15,QWORD PTR [rsp+0xb0]
    55b7:	add    rsp,0xc0
    55be:	mov    rsp,rbp
    55c1:	pop    rbp
    55c2:	ret
    55c3:	mov    rbx,QWORD PTR [rsp+0x90]
    55cb:	mov    r12,QWORD PTR [rsp+0x98]
    55d3:	mov    r13,QWORD PTR [rsp+0xa0]
    55db:	mov    r14,QWORD PTR [rsp+0xa8]
    55e3:	mov    r15,QWORD PTR [rsp+0xb0]
    55eb:	add    rsp,0xc0
    55f2:	mov    rsp,rbp
    55f5:	pop    rbp
    55f6:	ret
    55f7:	add    BYTE PTR [rsi],al
    55f9:	add    BYTE PTR [rax],al
    55fb:	add    BYTE PTR [rax],al
    55fd:	add    BYTE PTR [rax],al
	...

0000000000005600 <botlish_entry_55: sample<generic>>:
    5600:	push   rbp
    5601:	mov    rbp,rsp
    5604:	call   5609 <botlish_entry_55+0x9>
			5605: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample<generic>
    5609:	mov    rsp,rbp
    560c:	pop    rbp
    560d:	ret

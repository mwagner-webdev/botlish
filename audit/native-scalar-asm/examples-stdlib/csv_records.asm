; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23429  (per function: 45 453 453 453 81 81 81 357 412 412 412 278 278 278 81 365 438 585 1141 352 783 215 480 318 388 490 70 493 114 61 61 61 61 61 168 179 245 804 1248 429 380 439 977 766 817 665 1168 836 107 427 259 629 515 78 78 1222 301)
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
      89:	jne    b4 <botlish_fn_1+0x84>
      8f:	xor    rax,rax
      92:	mov    rbx,QWORD PTR [rsp+0x30]
      97:	mov    r12,QWORD PTR [rsp+0x38]
      9c:	mov    r13,QWORD PTR [rsp+0x40]
      a1:	mov    r14,QWORD PTR [rsp+0x48]
      a6:	mov    r15,QWORD PTR [rsp+0x50]
      ab:	add    rsp,0x60
      af:	mov    rsp,rbp
      b2:	pop    rbp
      b3:	ret
      b4:	mov    QWORD PTR [rsp+0x10],rax
      b9:	mov    r15,rax
      bc:	mov    esi,0x1
      c1:	mov    r14,rsi
      c4:	mov    QWORD PTR [rsp+0x18],0x1
      cd:	mov    rax,rsi
      d0:	and    rax,rbx
      d3:	mov    r14,rsi
      d6:	test   rax,0x1
      dc:	jne    105 <botlish_fn_1+0xd5>
      e2:	mov    rdx,rbx
      e5:	mov    rsi,r14
      e8:	mov    rdi,r13
      eb:	call   f0 <botlish_fn_1+0xc0>
			ec: R_X86_64_PLT32	rt_int_cmp-0x4
      f0:	mov    ecx,0x2
      f5:	test   rax,rax
      f8:	cmovl  rcx,QWORD PTR [rip+0xb8]        # 1b8 <botlish_fn_1+0x188>
     100:	jmp    118 <botlish_fn_1+0xe8>
     105:	mov    ecx,0x2
     10a:	mov    rsi,r14
     10d:	cmp    rsi,rbx
     110:	cmovl  rcx,QWORD PTR [rip+0xa0]        # 1b8 <botlish_fn_1+0x188>
     118:	cmp    rcx,0x6
     11c:	je     147 <botlish_fn_1+0x117>
     122:	mov    rax,r15
     125:	mov    rbx,QWORD PTR [rsp+0x30]
     12a:	mov    r12,QWORD PTR [rsp+0x38]
     12f:	mov    r13,QWORD PTR [rsp+0x40]
     134:	mov    r14,QWORD PTR [rsp+0x48]
     139:	mov    r15,QWORD PTR [rsp+0x50]
     13e:	add    rsp,0x60
     142:	mov    rsp,rbp
     145:	pop    rbp
     146:	ret
     147:	mov    rcx,r12
     14a:	mov    rdx,r14
     14d:	mov    rsi,r15
     150:	mov    rdi,r13
     153:	call   158 <botlish_fn_1+0x128>
			154: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     158:	mov    QWORD PTR [rsp+0x20],0x3
     161:	mov    rsi,r14
     164:	test   rsi,0x1
     16b:	je     191 <botlish_fn_1+0x161>
     171:	mov    rsi,r14
     174:	mov    rcx,rsi
     177:	add    rcx,0x2
     17b:	seto   al
     17e:	test   al,al
     180:	jne    191 <botlish_fn_1+0x161>
     186:	mov    rsi,rcx
     189:	mov    r14,rcx
     18c:	jmp    1a7 <botlish_fn_1+0x177>
     191:	mov    edx,0x3
     196:	mov    rsi,r14
     199:	mov    rdi,r13
     19c:	call   1a1 <botlish_fn_1+0x171>
			19d: R_X86_64_PLT32	rt_int_add-0x4
     1a1:	mov    rsi,rax
     1a4:	mov    r14,rax
     1a7:	mov    QWORD PTR [rsp+0x18],rsi
     1ac:	mov    rsi,r14
     1af:	jmp    cd <botlish_fn_1+0x9d>
     1b4:	add    BYTE PTR [rax],al
     1b6:	add    BYTE PTR [rax],al
     1b8:	(bad)
     1b9:	add    BYTE PTR [rax],al
     1bb:	add    BYTE PTR [rax],al
     1bd:	add    BYTE PTR [rax],al
	...

00000000000001c0 <botlish_entry_1: mutable_array::create<int, str>>:
     1c0:	push   rbp
     1c1:	mov    rbp,rsp
     1c4:	mov    rsi,QWORD PTR [rdx]
     1c7:	mov    rdx,QWORD PTR [rdx+0x8]
     1cb:	call   1d0 <botlish_entry_1+0x10>
			1cc: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     1d0:	mov    rsp,rbp
     1d3:	pop    rbp
     1d4:	ret
     1d5:	add    BYTE PTR [rax],al
	...

00000000000001d8 <botlish_fn_2: mutable_array::create<int, List[str]>>:
     1d8:	push   rbp
     1d9:	mov    rbp,rsp
     1dc:	sub    rsp,0x60
     1e0:	mov    QWORD PTR [rsp+0x30],rbx
     1e5:	mov    QWORD PTR [rsp+0x38],r12
     1ea:	mov    QWORD PTR [rsp+0x40],r13
     1ef:	mov    QWORD PTR [rsp+0x48],r14
     1f4:	mov    QWORD PTR [rsp+0x50],r15
     1f9:	mov    r13,rdi
     1fc:	mov    QWORD PTR [rsp+0x10],0x0
     205:	mov    QWORD PTR [rsp+0x18],0x0
     20e:	mov    QWORD PTR [rsp+0x20],0x0
     217:	mov    QWORD PTR [rsp],rsi
     21b:	mov    QWORD PTR [rsp+0x8],rdx
     220:	mov    r12,rdx
     223:	mov    rbx,rsi
     226:	mov    rdi,r13
     229:	call   22e <botlish_fn_2+0x56>
			22a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     22e:	test   rax,rax
     231:	jne    25c <botlish_fn_2+0x84>
     237:	xor    rax,rax
     23a:	mov    rbx,QWORD PTR [rsp+0x30]
     23f:	mov    r12,QWORD PTR [rsp+0x38]
     244:	mov    r13,QWORD PTR [rsp+0x40]
     249:	mov    r14,QWORD PTR [rsp+0x48]
     24e:	mov    r15,QWORD PTR [rsp+0x50]
     253:	add    rsp,0x60
     257:	mov    rsp,rbp
     25a:	pop    rbp
     25b:	ret
     25c:	mov    QWORD PTR [rsp+0x10],rax
     261:	mov    r15,rax
     264:	mov    esi,0x1
     269:	mov    r14,rsi
     26c:	mov    QWORD PTR [rsp+0x18],0x1
     275:	mov    rax,rsi
     278:	and    rax,rbx
     27b:	mov    r14,rsi
     27e:	test   rax,0x1
     284:	jne    2ad <botlish_fn_2+0xd5>
     28a:	mov    rdx,rbx
     28d:	mov    rsi,r14
     290:	mov    rdi,r13
     293:	call   298 <botlish_fn_2+0xc0>
			294: R_X86_64_PLT32	rt_int_cmp-0x4
     298:	mov    ecx,0x2
     29d:	test   rax,rax
     2a0:	cmovl  rcx,QWORD PTR [rip+0xb8]        # 360 <botlish_fn_2+0x188>
     2a8:	jmp    2c0 <botlish_fn_2+0xe8>
     2ad:	mov    ecx,0x2
     2b2:	mov    rsi,r14
     2b5:	cmp    rsi,rbx
     2b8:	cmovl  rcx,QWORD PTR [rip+0xa0]        # 360 <botlish_fn_2+0x188>
     2c0:	cmp    rcx,0x6
     2c4:	je     2ef <botlish_fn_2+0x117>
     2ca:	mov    rax,r15
     2cd:	mov    rbx,QWORD PTR [rsp+0x30]
     2d2:	mov    r12,QWORD PTR [rsp+0x38]
     2d7:	mov    r13,QWORD PTR [rsp+0x40]
     2dc:	mov    r14,QWORD PTR [rsp+0x48]
     2e1:	mov    r15,QWORD PTR [rsp+0x50]
     2e6:	add    rsp,0x60
     2ea:	mov    rsp,rbp
     2ed:	pop    rbp
     2ee:	ret
     2ef:	mov    rcx,r12
     2f2:	mov    rdx,r14
     2f5:	mov    rsi,r15
     2f8:	mov    rdi,r13
     2fb:	call   300 <botlish_fn_2+0x128>
			2fc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     300:	mov    QWORD PTR [rsp+0x20],0x3
     309:	mov    rsi,r14
     30c:	test   rsi,0x1
     313:	je     339 <botlish_fn_2+0x161>
     319:	mov    rsi,r14
     31c:	mov    rcx,rsi
     31f:	add    rcx,0x2
     323:	seto   al
     326:	test   al,al
     328:	jne    339 <botlish_fn_2+0x161>
     32e:	mov    rsi,rcx
     331:	mov    r14,rcx
     334:	jmp    34f <botlish_fn_2+0x177>
     339:	mov    edx,0x3
     33e:	mov    rsi,r14
     341:	mov    rdi,r13
     344:	call   349 <botlish_fn_2+0x171>
			345: R_X86_64_PLT32	rt_int_add-0x4
     349:	mov    rsi,rax
     34c:	mov    r14,rax
     34f:	mov    QWORD PTR [rsp+0x18],rsi
     354:	mov    rsi,r14
     357:	jmp    275 <botlish_fn_2+0x9d>
     35c:	add    BYTE PTR [rax],al
     35e:	add    BYTE PTR [rax],al
     360:	(bad)
     361:	add    BYTE PTR [rax],al
     363:	add    BYTE PTR [rax],al
     365:	add    BYTE PTR [rax],al
	...

0000000000000368 <botlish_entry_2: mutable_array::create<int, List[str]>>:
     368:	push   rbp
     369:	mov    rbp,rsp
     36c:	mov    rsi,QWORD PTR [rdx]
     36f:	mov    rdx,QWORD PTR [rdx+0x8]
     373:	call   378 <botlish_entry_2+0x10>
			374: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     378:	mov    rsp,rbp
     37b:	pop    rbp
     37c:	ret
     37d:	add    BYTE PTR [rax],al
	...

0000000000000380 <botlish_fn_3: mutable_array::create<int, mutarray>>:
     380:	push   rbp
     381:	mov    rbp,rsp
     384:	sub    rsp,0x60
     388:	mov    QWORD PTR [rsp+0x30],rbx
     38d:	mov    QWORD PTR [rsp+0x38],r12
     392:	mov    QWORD PTR [rsp+0x40],r13
     397:	mov    QWORD PTR [rsp+0x48],r14
     39c:	mov    QWORD PTR [rsp+0x50],r15
     3a1:	mov    r13,rdi
     3a4:	mov    QWORD PTR [rsp+0x10],0x0
     3ad:	mov    QWORD PTR [rsp+0x18],0x0
     3b6:	mov    QWORD PTR [rsp+0x20],0x0
     3bf:	mov    QWORD PTR [rsp],rsi
     3c3:	mov    QWORD PTR [rsp+0x8],rdx
     3c8:	mov    r12,rdx
     3cb:	mov    rbx,rsi
     3ce:	mov    rdi,r13
     3d1:	call   3d6 <botlish_fn_3+0x56>
			3d2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3d6:	test   rax,rax
     3d9:	jne    404 <botlish_fn_3+0x84>
     3df:	xor    rax,rax
     3e2:	mov    rbx,QWORD PTR [rsp+0x30]
     3e7:	mov    r12,QWORD PTR [rsp+0x38]
     3ec:	mov    r13,QWORD PTR [rsp+0x40]
     3f1:	mov    r14,QWORD PTR [rsp+0x48]
     3f6:	mov    r15,QWORD PTR [rsp+0x50]
     3fb:	add    rsp,0x60
     3ff:	mov    rsp,rbp
     402:	pop    rbp
     403:	ret
     404:	mov    QWORD PTR [rsp+0x10],rax
     409:	mov    r15,rax
     40c:	mov    esi,0x1
     411:	mov    r14,rsi
     414:	mov    QWORD PTR [rsp+0x18],0x1
     41d:	mov    rax,rsi
     420:	and    rax,rbx
     423:	mov    r14,rsi
     426:	test   rax,0x1
     42c:	jne    455 <botlish_fn_3+0xd5>
     432:	mov    rdx,rbx
     435:	mov    rsi,r14
     438:	mov    rdi,r13
     43b:	call   440 <botlish_fn_3+0xc0>
			43c: R_X86_64_PLT32	rt_int_cmp-0x4
     440:	mov    ecx,0x2
     445:	test   rax,rax
     448:	cmovl  rcx,QWORD PTR [rip+0xb8]        # 508 <botlish_fn_3+0x188>
     450:	jmp    468 <botlish_fn_3+0xe8>
     455:	mov    ecx,0x2
     45a:	mov    rsi,r14
     45d:	cmp    rsi,rbx
     460:	cmovl  rcx,QWORD PTR [rip+0xa0]        # 508 <botlish_fn_3+0x188>
     468:	cmp    rcx,0x6
     46c:	je     497 <botlish_fn_3+0x117>
     472:	mov    rax,r15
     475:	mov    rbx,QWORD PTR [rsp+0x30]
     47a:	mov    r12,QWORD PTR [rsp+0x38]
     47f:	mov    r13,QWORD PTR [rsp+0x40]
     484:	mov    r14,QWORD PTR [rsp+0x48]
     489:	mov    r15,QWORD PTR [rsp+0x50]
     48e:	add    rsp,0x60
     492:	mov    rsp,rbp
     495:	pop    rbp
     496:	ret
     497:	mov    rcx,r12
     49a:	mov    rdx,r14
     49d:	mov    rsi,r15
     4a0:	mov    rdi,r13
     4a3:	call   4a8 <botlish_fn_3+0x128>
			4a4: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     4a8:	mov    QWORD PTR [rsp+0x20],0x3
     4b1:	mov    rsi,r14
     4b4:	test   rsi,0x1
     4bb:	je     4e1 <botlish_fn_3+0x161>
     4c1:	mov    rsi,r14
     4c4:	mov    rcx,rsi
     4c7:	add    rcx,0x2
     4cb:	seto   al
     4ce:	test   al,al
     4d0:	jne    4e1 <botlish_fn_3+0x161>
     4d6:	mov    rsi,rcx
     4d9:	mov    r14,rcx
     4dc:	jmp    4f7 <botlish_fn_3+0x177>
     4e1:	mov    edx,0x3
     4e6:	mov    rsi,r14
     4e9:	mov    rdi,r13
     4ec:	call   4f1 <botlish_fn_3+0x171>
			4ed: R_X86_64_PLT32	rt_int_add-0x4
     4f1:	mov    rsi,rax
     4f4:	mov    r14,rax
     4f7:	mov    QWORD PTR [rsp+0x18],rsi
     4fc:	mov    rsi,r14
     4ff:	jmp    41d <botlish_fn_3+0x9d>
     504:	add    BYTE PTR [rax],al
     506:	add    BYTE PTR [rax],al
     508:	(bad)
     509:	add    BYTE PTR [rax],al
     50b:	add    BYTE PTR [rax],al
     50d:	add    BYTE PTR [rax],al
	...

0000000000000510 <botlish_entry_3: mutable_array::create<int, mutarray>>:
     510:	push   rbp
     511:	mov    rbp,rsp
     514:	mov    rsi,QWORD PTR [rdx]
     517:	mov    rdx,QWORD PTR [rdx+0x8]
     51b:	call   520 <botlish_entry_3+0x10>
			51c: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutable_array::create<int, mutarray>
     520:	mov    rsp,rbp
     523:	pop    rbp
     524:	ret

0000000000000525 <botlish_fn_4: geo_new<str>>:
     525:	push   rbp
     526:	mov    rbp,rsp
     529:	sub    rsp,0x10
     52d:	mov    QWORD PTR [rsp],rsi
     531:	mov    rdx,rsi
     534:	mov    esi,0x3
     539:	mov    QWORD PTR [rsp+0x8],0x3
     542:	call   547 <botlish_fn_4+0x22>
			543: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     547:	test   rax,rax
     54a:	jne    55c <botlish_fn_4+0x37>
     550:	xor    rax,rax
     553:	add    rsp,0x10
     557:	mov    rsp,rbp
     55a:	pop    rbp
     55b:	ret
     55c:	add    rsp,0x10
     560:	mov    rsp,rbp
     563:	pop    rbp
     564:	ret

0000000000000565 <botlish_entry_4: geo_new<str>>:
     565:	push   rbp
     566:	mov    rbp,rsp
     569:	mov    rsi,QWORD PTR [rdx]
     56c:	call   571 <botlish_entry_4+0xc>
			56d: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
     571:	mov    rsp,rbp
     574:	pop    rbp
     575:	ret

0000000000000576 <botlish_fn_5: geo_new<List[str]>>:
     576:	push   rbp
     577:	mov    rbp,rsp
     57a:	sub    rsp,0x10
     57e:	mov    QWORD PTR [rsp],rsi
     582:	mov    rdx,rsi
     585:	mov    esi,0x3
     58a:	mov    QWORD PTR [rsp+0x8],0x3
     593:	call   598 <botlish_fn_5+0x22>
			594: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     598:	test   rax,rax
     59b:	jne    5ad <botlish_fn_5+0x37>
     5a1:	xor    rax,rax
     5a4:	add    rsp,0x10
     5a8:	mov    rsp,rbp
     5ab:	pop    rbp
     5ac:	ret
     5ad:	add    rsp,0x10
     5b1:	mov    rsp,rbp
     5b4:	pop    rbp
     5b5:	ret

00000000000005b6 <botlish_entry_5: geo_new<List[str]>>:
     5b6:	push   rbp
     5b7:	mov    rbp,rsp
     5ba:	mov    rsi,QWORD PTR [rdx]
     5bd:	call   5c2 <botlish_entry_5+0xc>
			5be: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
     5c2:	mov    rsp,rbp
     5c5:	pop    rbp
     5c6:	ret

00000000000005c7 <botlish_fn_6: geo_new<mutarray>>:
     5c7:	push   rbp
     5c8:	mov    rbp,rsp
     5cb:	sub    rsp,0x10
     5cf:	mov    QWORD PTR [rsp],rsi
     5d3:	mov    rdx,rsi
     5d6:	mov    esi,0x3
     5db:	mov    QWORD PTR [rsp+0x8],0x3
     5e4:	call   5e9 <botlish_fn_6+0x22>
			5e5: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutable_array::create<int, mutarray>
     5e9:	test   rax,rax
     5ec:	jne    5fe <botlish_fn_6+0x37>
     5f2:	xor    rax,rax
     5f5:	add    rsp,0x10
     5f9:	mov    rsp,rbp
     5fc:	pop    rbp
     5fd:	ret
     5fe:	add    rsp,0x10
     602:	mov    rsp,rbp
     605:	pop    rbp
     606:	ret

0000000000000607 <botlish_entry_6: geo_new<mutarray>>:
     607:	push   rbp
     608:	mov    rbp,rsp
     60b:	mov    rsi,QWORD PTR [rdx]
     60e:	call   613 <botlish_entry_6+0xc>
			60f: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
     613:	mov    rsp,rbp
     616:	pop    rbp
     617:	ret

0000000000000618 <botlish_fn_7: geo_new_capacity<int, int>>:
     618:	push   rbp
     619:	mov    rbp,rsp
     61c:	sub    rsp,0x40
     620:	mov    QWORD PTR [rsp+0x20],rbx
     625:	mov    QWORD PTR [rsp+0x28],r12
     62a:	mov    QWORD PTR [rsp+0x30],r13
     62f:	mov    r12,rdi
     632:	mov    QWORD PTR [rsp],rsi
     636:	mov    QWORD PTR [rsp+0x8],rdx
     63b:	mov    rbx,rdx
     63e:	mov    QWORD PTR [rsp+0x10],0x5
     647:	test   rsi,0x1
     64e:	je     670 <botlish_fn_7+0x58>
     654:	mov    rax,rsi
     657:	sar    rax,1
     65a:	imul   QWORD PTR [rip+0xdf]        # 740 <botlish_fn_7+0x128>
     661:	seto   cl
     664:	or     rax,0x1
     668:	test   cl,cl
     66a:	je     67d <botlish_fn_7+0x65>
     670:	mov    edx,0x5
     675:	mov    rdi,r12
     678:	call   67d <botlish_fn_7+0x65>
			679: R_X86_64_PLT32	rt_int_mul-0x4
     67d:	mov    rcx,rax
     680:	and    rcx,rbx
     683:	mov    r13,rax
     686:	test   rcx,0x1
     68d:	jne    6b9 <botlish_fn_7+0xa1>
     693:	mov    rdx,rbx
     696:	mov    rsi,r13
     699:	mov    rdi,r12
     69c:	call   6a1 <botlish_fn_7+0x89>
			69d: R_X86_64_PLT32	rt_int_cmp-0x4
     6a1:	mov    ecx,0x2
     6a6:	test   rax,rax
     6a9:	cmovle rcx,QWORD PTR [rip+0x97]        # 748 <botlish_fn_7+0x130>
     6b1:	mov    rax,r13
     6b4:	jmp    6cc <botlish_fn_7+0xb4>
     6b9:	mov    ecx,0x2
     6be:	mov    rax,r13
     6c1:	cmp    rax,rbx
     6c4:	cmovle rcx,QWORD PTR [rip+0x7c]        # 748 <botlish_fn_7+0x130>
     6cc:	cmp    rcx,0x6
     6d0:	je     6ee <botlish_fn_7+0xd6>
     6d6:	mov    rbx,QWORD PTR [rsp+0x20]
     6db:	mov    r12,QWORD PTR [rsp+0x28]
     6e0:	mov    r13,QWORD PTR [rsp+0x30]
     6e5:	add    rsp,0x40
     6e9:	mov    rsp,rbp
     6ec:	pop    rbp
     6ed:	ret
     6ee:	mov    QWORD PTR [rsp],0x3
     6f6:	test   rbx,0x1
     6fd:	je     715 <botlish_fn_7+0xfd>
     703:	mov    rax,rbx
     706:	add    rax,0x2
     70a:	seto   cl
     70d:	test   cl,cl
     70f:	je     725 <botlish_fn_7+0x10d>
     715:	mov    edx,0x3
     71a:	mov    rsi,rbx
     71d:	mov    rdi,r12
     720:	call   725 <botlish_fn_7+0x10d>
			721: R_X86_64_PLT32	rt_int_add-0x4
     725:	mov    rbx,QWORD PTR [rsp+0x20]
     72a:	mov    r12,QWORD PTR [rsp+0x28]
     72f:	mov    r13,QWORD PTR [rsp+0x30]
     734:	add    rsp,0x40
     738:	mov    rsp,rbp
     73b:	pop    rbp
     73c:	ret
     73d:	add    BYTE PTR [rax],al
     73f:	add    BYTE PTR [rax+rax*1],al
     742:	add    BYTE PTR [rax],al
     744:	add    BYTE PTR [rax],al
     746:	add    BYTE PTR [rax],al
     748:	(bad)
     749:	add    BYTE PTR [rax],al
     74b:	add    BYTE PTR [rax],al
     74d:	add    BYTE PTR [rax],al
	...

0000000000000750 <botlish_entry_7: geo_new_capacity<int, int>>:
     750:	push   rbp
     751:	mov    rbp,rsp
     754:	mov    rsi,QWORD PTR [rdx]
     757:	mov    rdx,QWORD PTR [rdx+0x8]
     75b:	call   760 <botlish_entry_7+0x10>
			75c: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     760:	mov    rsp,rbp
     763:	pop    rbp
     764:	ret
     765:	add    BYTE PTR [rax],al
	...

0000000000000768 <botlish_fn_8: geo_grow<mutarray, int, str>>:
     768:	push   rbp
     769:	mov    rbp,rsp
     76c:	sub    rsp,0x50
     770:	mov    QWORD PTR [rsp+0x20],rbx
     775:	mov    QWORD PTR [rsp+0x28],r12
     77a:	mov    QWORD PTR [rsp+0x30],r13
     77f:	mov    QWORD PTR [rsp+0x38],r14
     784:	mov    QWORD PTR [rsp+0x40],r15
     789:	mov    r13,rdi
     78c:	mov    QWORD PTR [rsp],rsi
     790:	mov    r12,rsi
     793:	mov    QWORD PTR [rsp+0x8],rdx
     798:	mov    rbx,rdx
     79b:	mov    QWORD PTR [rsp+0x10],rcx
     7a0:	mov    r14,rcx
     7a3:	mov    rsi,r12
     7a6:	mov    rdi,r13
     7a9:	call   7ae <botlish_fn_8+0x46>
			7aa: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     7ae:	mov    r15,rax
     7b1:	mov    QWORD PTR [rsp+0x18],rax
     7b6:	mov    rcx,rbx
     7b9:	and    rcx,rax
     7bc:	test   rcx,0x1
     7c3:	jne    7ef <botlish_fn_8+0x87>
     7c9:	mov    rdx,r15
     7cc:	mov    rsi,rbx
     7cf:	mov    rdi,r13
     7d2:	call   7d7 <botlish_fn_8+0x6f>
			7d3: R_X86_64_PLT32	rt_int_cmp-0x4
     7d7:	mov    ecx,0x2
     7dc:	test   rax,rax
     7df:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 8d0 <botlish_fn_8+0x168>
     7e7:	mov    rax,r15
     7ea:	jmp    802 <botlish_fn_8+0x9a>
     7ef:	mov    ecx,0x2
     7f4:	mov    rax,r15
     7f7:	cmp    rbx,rax
     7fa:	cmovl  rcx,QWORD PTR [rip+0xce]        # 8d0 <botlish_fn_8+0x168>
     802:	cmp    rcx,0x6
     806:	je     8a6 <botlish_fn_8+0x13e>
     80c:	mov    rsi,rax
     80f:	mov    rdx,rbx
     812:	mov    rdi,r13
     815:	call   81a <botlish_fn_8+0xb2>
			816: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     81a:	mov    QWORD PTR [rsp+0x18],rax
     81f:	mov    rdx,r14
     822:	mov    rsi,rax
     825:	mov    rdi,r13
     828:	call   82d <botlish_fn_8+0xc5>
			829: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     82d:	test   rax,rax
     830:	mov    r14,rax
     833:	je     85c <botlish_fn_8+0xf4>
     839:	mov    r8d,0x1
     83f:	mov    rcx,r12
     842:	mov    rdi,r13
     845:	mov    r9,rbx
     848:	mov    rsi,r14
     84b:	mov    rdx,r8
     84e:	call   853 <botlish_fn_8+0xeb>
			84f: R_X86_64_PLT32	rt_mutarray_copy-0x4
     853:	test   rax,rax
     856:	jne    881 <botlish_fn_8+0x119>
     85c:	xor    rax,rax
     85f:	mov    rbx,QWORD PTR [rsp+0x20]
     864:	mov    r12,QWORD PTR [rsp+0x28]
     869:	mov    r13,QWORD PTR [rsp+0x30]
     86e:	mov    r14,QWORD PTR [rsp+0x38]
     873:	mov    r15,QWORD PTR [rsp+0x40]
     878:	add    rsp,0x50
     87c:	mov    rsp,rbp
     87f:	pop    rbp
     880:	ret
     881:	mov    rax,r14
     884:	mov    rbx,QWORD PTR [rsp+0x20]
     889:	mov    r12,QWORD PTR [rsp+0x28]
     88e:	mov    r13,QWORD PTR [rsp+0x30]
     893:	mov    r14,QWORD PTR [rsp+0x38]
     898:	mov    r15,QWORD PTR [rsp+0x40]
     89d:	add    rsp,0x50
     8a1:	mov    rsp,rbp
     8a4:	pop    rbp
     8a5:	ret
     8a6:	mov    rax,r12
     8a9:	mov    rbx,QWORD PTR [rsp+0x20]
     8ae:	mov    r12,QWORD PTR [rsp+0x28]
     8b3:	mov    r13,QWORD PTR [rsp+0x30]
     8b8:	mov    r14,QWORD PTR [rsp+0x38]
     8bd:	mov    r15,QWORD PTR [rsp+0x40]
     8c2:	add    rsp,0x50
     8c6:	mov    rsp,rbp
     8c9:	pop    rbp
     8ca:	ret
     8cb:	add    BYTE PTR [rax],al
     8cd:	add    BYTE PTR [rax],al
     8cf:	add    BYTE PTR [rsi],al
     8d1:	add    BYTE PTR [rax],al
     8d3:	add    BYTE PTR [rax],al
     8d5:	add    BYTE PTR [rax],al
	...

00000000000008d8 <botlish_entry_8: geo_grow<mutarray, int, str>>:
     8d8:	push   rbp
     8d9:	mov    rbp,rsp
     8dc:	mov    rsi,QWORD PTR [rdx]
     8df:	mov    r8,QWORD PTR [rdx+0x8]
     8e3:	mov    rcx,QWORD PTR [rdx+0x10]
     8e7:	mov    rdx,r8
     8ea:	call   8ef <botlish_entry_8+0x17>
			8eb: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_grow<mutarray, int, str>
     8ef:	mov    rsp,rbp
     8f2:	pop    rbp
     8f3:	ret
     8f4:	add    BYTE PTR [rax],al
	...

00000000000008f8 <botlish_fn_9: geo_grow<mutarray, int, List[str]>>:
     8f8:	push   rbp
     8f9:	mov    rbp,rsp
     8fc:	sub    rsp,0x50
     900:	mov    QWORD PTR [rsp+0x20],rbx
     905:	mov    QWORD PTR [rsp+0x28],r12
     90a:	mov    QWORD PTR [rsp+0x30],r13
     90f:	mov    QWORD PTR [rsp+0x38],r14
     914:	mov    QWORD PTR [rsp+0x40],r15
     919:	mov    r13,rdi
     91c:	mov    QWORD PTR [rsp],rsi
     920:	mov    r12,rsi
     923:	mov    QWORD PTR [rsp+0x8],rdx
     928:	mov    rbx,rdx
     92b:	mov    QWORD PTR [rsp+0x10],rcx
     930:	mov    r14,rcx
     933:	mov    rsi,r12
     936:	mov    rdi,r13
     939:	call   93e <botlish_fn_9+0x46>
			93a: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     93e:	mov    r15,rax
     941:	mov    QWORD PTR [rsp+0x18],rax
     946:	mov    rcx,rbx
     949:	and    rcx,rax
     94c:	test   rcx,0x1
     953:	jne    97f <botlish_fn_9+0x87>
     959:	mov    rdx,r15
     95c:	mov    rsi,rbx
     95f:	mov    rdi,r13
     962:	call   967 <botlish_fn_9+0x6f>
			963: R_X86_64_PLT32	rt_int_cmp-0x4
     967:	mov    ecx,0x2
     96c:	test   rax,rax
     96f:	cmovl  rcx,QWORD PTR [rip+0xe9]        # a60 <botlish_fn_9+0x168>
     977:	mov    rax,r15
     97a:	jmp    992 <botlish_fn_9+0x9a>
     97f:	mov    ecx,0x2
     984:	mov    rax,r15
     987:	cmp    rbx,rax
     98a:	cmovl  rcx,QWORD PTR [rip+0xce]        # a60 <botlish_fn_9+0x168>
     992:	cmp    rcx,0x6
     996:	je     a36 <botlish_fn_9+0x13e>
     99c:	mov    rsi,rax
     99f:	mov    rdx,rbx
     9a2:	mov    rdi,r13
     9a5:	call   9aa <botlish_fn_9+0xb2>
			9a6: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     9aa:	mov    QWORD PTR [rsp+0x18],rax
     9af:	mov    rdx,r14
     9b2:	mov    rsi,rax
     9b5:	mov    rdi,r13
     9b8:	call   9bd <botlish_fn_9+0xc5>
			9b9: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     9bd:	test   rax,rax
     9c0:	mov    r14,rax
     9c3:	je     9ec <botlish_fn_9+0xf4>
     9c9:	mov    r8d,0x1
     9cf:	mov    rcx,r12
     9d2:	mov    rdi,r13
     9d5:	mov    r9,rbx
     9d8:	mov    rsi,r14
     9db:	mov    rdx,r8
     9de:	call   9e3 <botlish_fn_9+0xeb>
			9df: R_X86_64_PLT32	rt_mutarray_copy-0x4
     9e3:	test   rax,rax
     9e6:	jne    a11 <botlish_fn_9+0x119>
     9ec:	xor    rax,rax
     9ef:	mov    rbx,QWORD PTR [rsp+0x20]
     9f4:	mov    r12,QWORD PTR [rsp+0x28]
     9f9:	mov    r13,QWORD PTR [rsp+0x30]
     9fe:	mov    r14,QWORD PTR [rsp+0x38]
     a03:	mov    r15,QWORD PTR [rsp+0x40]
     a08:	add    rsp,0x50
     a0c:	mov    rsp,rbp
     a0f:	pop    rbp
     a10:	ret
     a11:	mov    rax,r14
     a14:	mov    rbx,QWORD PTR [rsp+0x20]
     a19:	mov    r12,QWORD PTR [rsp+0x28]
     a1e:	mov    r13,QWORD PTR [rsp+0x30]
     a23:	mov    r14,QWORD PTR [rsp+0x38]
     a28:	mov    r15,QWORD PTR [rsp+0x40]
     a2d:	add    rsp,0x50
     a31:	mov    rsp,rbp
     a34:	pop    rbp
     a35:	ret
     a36:	mov    rax,r12
     a39:	mov    rbx,QWORD PTR [rsp+0x20]
     a3e:	mov    r12,QWORD PTR [rsp+0x28]
     a43:	mov    r13,QWORD PTR [rsp+0x30]
     a48:	mov    r14,QWORD PTR [rsp+0x38]
     a4d:	mov    r15,QWORD PTR [rsp+0x40]
     a52:	add    rsp,0x50
     a56:	mov    rsp,rbp
     a59:	pop    rbp
     a5a:	ret
     a5b:	add    BYTE PTR [rax],al
     a5d:	add    BYTE PTR [rax],al
     a5f:	add    BYTE PTR [rsi],al
     a61:	add    BYTE PTR [rax],al
     a63:	add    BYTE PTR [rax],al
     a65:	add    BYTE PTR [rax],al
	...

0000000000000a68 <botlish_entry_9: geo_grow<mutarray, int, List[str]>>:
     a68:	push   rbp
     a69:	mov    rbp,rsp
     a6c:	mov    rsi,QWORD PTR [rdx]
     a6f:	mov    r8,QWORD PTR [rdx+0x8]
     a73:	mov    rcx,QWORD PTR [rdx+0x10]
     a77:	mov    rdx,r8
     a7a:	call   a7f <botlish_entry_9+0x17>
			a7b: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, List[str]>
     a7f:	mov    rsp,rbp
     a82:	pop    rbp
     a83:	ret
     a84:	add    BYTE PTR [rax],al
	...

0000000000000a88 <botlish_fn_10: geo_grow<mutarray, int, mutarray>>:
     a88:	push   rbp
     a89:	mov    rbp,rsp
     a8c:	sub    rsp,0x50
     a90:	mov    QWORD PTR [rsp+0x20],rbx
     a95:	mov    QWORD PTR [rsp+0x28],r12
     a9a:	mov    QWORD PTR [rsp+0x30],r13
     a9f:	mov    QWORD PTR [rsp+0x38],r14
     aa4:	mov    QWORD PTR [rsp+0x40],r15
     aa9:	mov    r13,rdi
     aac:	mov    QWORD PTR [rsp],rsi
     ab0:	mov    r12,rsi
     ab3:	mov    QWORD PTR [rsp+0x8],rdx
     ab8:	mov    rbx,rdx
     abb:	mov    QWORD PTR [rsp+0x10],rcx
     ac0:	mov    r14,rcx
     ac3:	mov    rsi,r12
     ac6:	mov    rdi,r13
     ac9:	call   ace <botlish_fn_10+0x46>
			aca: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     ace:	mov    r15,rax
     ad1:	mov    QWORD PTR [rsp+0x18],rax
     ad6:	mov    rcx,rbx
     ad9:	and    rcx,rax
     adc:	test   rcx,0x1
     ae3:	jne    b0f <botlish_fn_10+0x87>
     ae9:	mov    rdx,r15
     aec:	mov    rsi,rbx
     aef:	mov    rdi,r13
     af2:	call   af7 <botlish_fn_10+0x6f>
			af3: R_X86_64_PLT32	rt_int_cmp-0x4
     af7:	mov    ecx,0x2
     afc:	test   rax,rax
     aff:	cmovl  rcx,QWORD PTR [rip+0xe9]        # bf0 <botlish_fn_10+0x168>
     b07:	mov    rax,r15
     b0a:	jmp    b22 <botlish_fn_10+0x9a>
     b0f:	mov    ecx,0x2
     b14:	mov    rax,r15
     b17:	cmp    rbx,rax
     b1a:	cmovl  rcx,QWORD PTR [rip+0xce]        # bf0 <botlish_fn_10+0x168>
     b22:	cmp    rcx,0x6
     b26:	je     bc6 <botlish_fn_10+0x13e>
     b2c:	mov    rsi,rax
     b2f:	mov    rdx,rbx
     b32:	mov    rdi,r13
     b35:	call   b3a <botlish_fn_10+0xb2>
			b36: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_new_capacity<int, int>
     b3a:	mov    QWORD PTR [rsp+0x18],rax
     b3f:	mov    rdx,r14
     b42:	mov    rsi,rax
     b45:	mov    rdi,r13
     b48:	call   b4d <botlish_fn_10+0xc5>
			b49: R_X86_64_PLT32	botlish_fn_3-0x4 ; mutable_array::create<int, mutarray>
     b4d:	test   rax,rax
     b50:	mov    r14,rax
     b53:	je     b7c <botlish_fn_10+0xf4>
     b59:	mov    r8d,0x1
     b5f:	mov    rcx,r12
     b62:	mov    rdi,r13
     b65:	mov    r9,rbx
     b68:	mov    rsi,r14
     b6b:	mov    rdx,r8
     b6e:	call   b73 <botlish_fn_10+0xeb>
			b6f: R_X86_64_PLT32	rt_mutarray_copy-0x4
     b73:	test   rax,rax
     b76:	jne    ba1 <botlish_fn_10+0x119>
     b7c:	xor    rax,rax
     b7f:	mov    rbx,QWORD PTR [rsp+0x20]
     b84:	mov    r12,QWORD PTR [rsp+0x28]
     b89:	mov    r13,QWORD PTR [rsp+0x30]
     b8e:	mov    r14,QWORD PTR [rsp+0x38]
     b93:	mov    r15,QWORD PTR [rsp+0x40]
     b98:	add    rsp,0x50
     b9c:	mov    rsp,rbp
     b9f:	pop    rbp
     ba0:	ret
     ba1:	mov    rax,r14
     ba4:	mov    rbx,QWORD PTR [rsp+0x20]
     ba9:	mov    r12,QWORD PTR [rsp+0x28]
     bae:	mov    r13,QWORD PTR [rsp+0x30]
     bb3:	mov    r14,QWORD PTR [rsp+0x38]
     bb8:	mov    r15,QWORD PTR [rsp+0x40]
     bbd:	add    rsp,0x50
     bc1:	mov    rsp,rbp
     bc4:	pop    rbp
     bc5:	ret
     bc6:	mov    rax,r12
     bc9:	mov    rbx,QWORD PTR [rsp+0x20]
     bce:	mov    r12,QWORD PTR [rsp+0x28]
     bd3:	mov    r13,QWORD PTR [rsp+0x30]
     bd8:	mov    r14,QWORD PTR [rsp+0x38]
     bdd:	mov    r15,QWORD PTR [rsp+0x40]
     be2:	add    rsp,0x50
     be6:	mov    rsp,rbp
     be9:	pop    rbp
     bea:	ret
     beb:	add    BYTE PTR [rax],al
     bed:	add    BYTE PTR [rax],al
     bef:	add    BYTE PTR [rsi],al
     bf1:	add    BYTE PTR [rax],al
     bf3:	add    BYTE PTR [rax],al
     bf5:	add    BYTE PTR [rax],al
	...

0000000000000bf8 <botlish_entry_10: geo_grow<mutarray, int, mutarray>>:
     bf8:	push   rbp
     bf9:	mov    rbp,rsp
     bfc:	mov    rsi,QWORD PTR [rdx]
     bff:	mov    r8,QWORD PTR [rdx+0x8]
     c03:	mov    rcx,QWORD PTR [rdx+0x10]
     c07:	mov    rdx,r8
     c0a:	call   c0f <botlish_entry_10+0x17>
			c0b: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_grow<mutarray, int, mutarray>
     c0f:	mov    rsp,rbp
     c12:	pop    rbp
     c13:	ret

0000000000000c14 <botlish_fn_11: geo_append<mutarray, int, str>>:
     c14:	push   rbp
     c15:	mov    rbp,rsp
     c18:	sub    rsp,0x40
     c1c:	mov    QWORD PTR [rsp+0x20],rbx
     c21:	mov    QWORD PTR [rsp+0x28],r12
     c26:	mov    QWORD PTR [rsp+0x30],r13
     c2b:	mov    QWORD PTR [rsp+0x38],r14
     c30:	mov    rbx,rdi
     c33:	mov    QWORD PTR [rsp],rsi
     c37:	mov    QWORD PTR [rsp+0x8],rdx
     c3c:	mov    r14,rdx
     c3f:	mov    QWORD PTR [rsp+0x10],rcx
     c44:	mov    r13,rcx
     c47:	mov    rcx,r13
     c4a:	mov    rdx,r14
     c4d:	mov    rdi,rbx
     c50:	call   c55 <botlish_fn_11+0x41>
			c51: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_grow<mutarray, int, str>
     c55:	test   rax,rax
     c58:	je     cc0 <botlish_fn_11+0xac>
     c5e:	xor    ecx,ecx
     c60:	test   rax,0x7
     c66:	je     c74 <botlish_fn_11+0x60>
     c6c:	mov    r12,rax
     c6f:	jmp    c82 <botlish_fn_11+0x6e>
     c74:	movzx  rcx,BYTE PTR [rax]
     c78:	mov    r12,rax
     c7b:	rex cmp cl,0x8
     c7f:	sete   cl
     c82:	test   cl,cl
     c84:	jne    ca6 <botlish_fn_11+0x92>
     c8a:	mov    rdi,rbx
     c8d:	mov    rax,QWORD PTR [rdi+0x10]
     c91:	mov    rcx,QWORD PTR [rax]
     c94:	mov    edx,0x8
     c99:	mov    rsi,r12
     c9c:	call   ca1 <botlish_fn_11+0x8d>
			c9d: R_X86_64_PLT32	rt_type_error-0x4
     ca1:	jmp    cc0 <botlish_fn_11+0xac>
     ca6:	mov    rcx,r13
     ca9:	mov    rdx,r14
     cac:	mov    rdi,rbx
     caf:	mov    rsi,r12
     cb2:	call   cb7 <botlish_fn_11+0xa3>
			cb3: R_X86_64_PLT32	rt_mutarray_set-0x4
     cb7:	test   rax,rax
     cba:	jne    ce0 <botlish_fn_11+0xcc>
     cc0:	xor    rax,rax
     cc3:	mov    rbx,QWORD PTR [rsp+0x20]
     cc8:	mov    r12,QWORD PTR [rsp+0x28]
     ccd:	mov    r13,QWORD PTR [rsp+0x30]
     cd2:	mov    r14,QWORD PTR [rsp+0x38]
     cd7:	add    rsp,0x40
     cdb:	mov    rsp,rbp
     cde:	pop    rbp
     cdf:	ret
     ce0:	mov    rax,r12
     ce3:	mov    rbx,QWORD PTR [rsp+0x20]
     ce8:	mov    r12,QWORD PTR [rsp+0x28]
     ced:	mov    r13,QWORD PTR [rsp+0x30]
     cf2:	mov    r14,QWORD PTR [rsp+0x38]
     cf7:	add    rsp,0x40
     cfb:	mov    rsp,rbp
     cfe:	pop    rbp
     cff:	ret

0000000000000d00 <botlish_entry_11: geo_append<mutarray, int, str>>:
     d00:	push   rbp
     d01:	mov    rbp,rsp
     d04:	mov    rsi,QWORD PTR [rdx]
     d07:	mov    r8,QWORD PTR [rdx+0x8]
     d0b:	mov    rcx,QWORD PTR [rdx+0x10]
     d0f:	mov    rdx,r8
     d12:	call   d17 <botlish_entry_11+0x17>
			d13: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
     d17:	mov    rsp,rbp
     d1a:	pop    rbp
     d1b:	ret

0000000000000d1c <botlish_fn_12: geo_append<mutarray, int, List[str]>>:
     d1c:	push   rbp
     d1d:	mov    rbp,rsp
     d20:	sub    rsp,0x40
     d24:	mov    QWORD PTR [rsp+0x20],rbx
     d29:	mov    QWORD PTR [rsp+0x28],r12
     d2e:	mov    QWORD PTR [rsp+0x30],r13
     d33:	mov    QWORD PTR [rsp+0x38],r14
     d38:	mov    rbx,rdi
     d3b:	mov    QWORD PTR [rsp],rsi
     d3f:	mov    QWORD PTR [rsp+0x8],rdx
     d44:	mov    r14,rdx
     d47:	mov    QWORD PTR [rsp+0x10],rcx
     d4c:	mov    r13,rcx
     d4f:	mov    rcx,r13
     d52:	mov    rdx,r14
     d55:	mov    rdi,rbx
     d58:	call   d5d <botlish_fn_12+0x41>
			d59: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_grow<mutarray, int, List[str]>
     d5d:	test   rax,rax
     d60:	je     dc8 <botlish_fn_12+0xac>
     d66:	xor    ecx,ecx
     d68:	test   rax,0x7
     d6e:	je     d7c <botlish_fn_12+0x60>
     d74:	mov    r12,rax
     d77:	jmp    d8a <botlish_fn_12+0x6e>
     d7c:	movzx  rcx,BYTE PTR [rax]
     d80:	mov    r12,rax
     d83:	rex cmp cl,0x8
     d87:	sete   cl
     d8a:	test   cl,cl
     d8c:	jne    dae <botlish_fn_12+0x92>
     d92:	mov    rdi,rbx
     d95:	mov    rax,QWORD PTR [rdi+0x10]
     d99:	mov    rcx,QWORD PTR [rax]
     d9c:	mov    edx,0x8
     da1:	mov    rsi,r12
     da4:	call   da9 <botlish_fn_12+0x8d>
			da5: R_X86_64_PLT32	rt_type_error-0x4
     da9:	jmp    dc8 <botlish_fn_12+0xac>
     dae:	mov    rcx,r13
     db1:	mov    rdx,r14
     db4:	mov    rdi,rbx
     db7:	mov    rsi,r12
     dba:	call   dbf <botlish_fn_12+0xa3>
			dbb: R_X86_64_PLT32	rt_mutarray_set-0x4
     dbf:	test   rax,rax
     dc2:	jne    de8 <botlish_fn_12+0xcc>
     dc8:	xor    rax,rax
     dcb:	mov    rbx,QWORD PTR [rsp+0x20]
     dd0:	mov    r12,QWORD PTR [rsp+0x28]
     dd5:	mov    r13,QWORD PTR [rsp+0x30]
     dda:	mov    r14,QWORD PTR [rsp+0x38]
     ddf:	add    rsp,0x40
     de3:	mov    rsp,rbp
     de6:	pop    rbp
     de7:	ret
     de8:	mov    rax,r12
     deb:	mov    rbx,QWORD PTR [rsp+0x20]
     df0:	mov    r12,QWORD PTR [rsp+0x28]
     df5:	mov    r13,QWORD PTR [rsp+0x30]
     dfa:	mov    r14,QWORD PTR [rsp+0x38]
     dff:	add    rsp,0x40
     e03:	mov    rsp,rbp
     e06:	pop    rbp
     e07:	ret

0000000000000e08 <botlish_entry_12: geo_append<mutarray, int, List[str]>>:
     e08:	push   rbp
     e09:	mov    rbp,rsp
     e0c:	mov    rsi,QWORD PTR [rdx]
     e0f:	mov    r8,QWORD PTR [rdx+0x8]
     e13:	mov    rcx,QWORD PTR [rdx+0x10]
     e17:	mov    rdx,r8
     e1a:	call   e1f <botlish_entry_12+0x17>
			e1b: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
     e1f:	mov    rsp,rbp
     e22:	pop    rbp
     e23:	ret

0000000000000e24 <botlish_fn_13: geo_append<mutarray, int, mutarray>>:
     e24:	push   rbp
     e25:	mov    rbp,rsp
     e28:	sub    rsp,0x40
     e2c:	mov    QWORD PTR [rsp+0x20],rbx
     e31:	mov    QWORD PTR [rsp+0x28],r12
     e36:	mov    QWORD PTR [rsp+0x30],r13
     e3b:	mov    QWORD PTR [rsp+0x38],r14
     e40:	mov    rbx,rdi
     e43:	mov    QWORD PTR [rsp],rsi
     e47:	mov    QWORD PTR [rsp+0x8],rdx
     e4c:	mov    r14,rdx
     e4f:	mov    QWORD PTR [rsp+0x10],rcx
     e54:	mov    r13,rcx
     e57:	mov    rcx,r13
     e5a:	mov    rdx,r14
     e5d:	mov    rdi,rbx
     e60:	call   e65 <botlish_fn_13+0x41>
			e61: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_grow<mutarray, int, mutarray>
     e65:	test   rax,rax
     e68:	je     ed0 <botlish_fn_13+0xac>
     e6e:	xor    ecx,ecx
     e70:	test   rax,0x7
     e76:	je     e84 <botlish_fn_13+0x60>
     e7c:	mov    r12,rax
     e7f:	jmp    e92 <botlish_fn_13+0x6e>
     e84:	movzx  rcx,BYTE PTR [rax]
     e88:	mov    r12,rax
     e8b:	rex cmp cl,0x8
     e8f:	sete   cl
     e92:	test   cl,cl
     e94:	jne    eb6 <botlish_fn_13+0x92>
     e9a:	mov    rdi,rbx
     e9d:	mov    rax,QWORD PTR [rdi+0x10]
     ea1:	mov    rcx,QWORD PTR [rax]
     ea4:	mov    edx,0x8
     ea9:	mov    rsi,r12
     eac:	call   eb1 <botlish_fn_13+0x8d>
			ead: R_X86_64_PLT32	rt_type_error-0x4
     eb1:	jmp    ed0 <botlish_fn_13+0xac>
     eb6:	mov    rcx,r13
     eb9:	mov    rdx,r14
     ebc:	mov    rdi,rbx
     ebf:	mov    rsi,r12
     ec2:	call   ec7 <botlish_fn_13+0xa3>
			ec3: R_X86_64_PLT32	rt_mutarray_set-0x4
     ec7:	test   rax,rax
     eca:	jne    ef0 <botlish_fn_13+0xcc>
     ed0:	xor    rax,rax
     ed3:	mov    rbx,QWORD PTR [rsp+0x20]
     ed8:	mov    r12,QWORD PTR [rsp+0x28]
     edd:	mov    r13,QWORD PTR [rsp+0x30]
     ee2:	mov    r14,QWORD PTR [rsp+0x38]
     ee7:	add    rsp,0x40
     eeb:	mov    rsp,rbp
     eee:	pop    rbp
     eef:	ret
     ef0:	mov    rax,r12
     ef3:	mov    rbx,QWORD PTR [rsp+0x20]
     ef8:	mov    r12,QWORD PTR [rsp+0x28]
     efd:	mov    r13,QWORD PTR [rsp+0x30]
     f02:	mov    r14,QWORD PTR [rsp+0x38]
     f07:	add    rsp,0x40
     f0b:	mov    rsp,rbp
     f0e:	pop    rbp
     f0f:	ret

0000000000000f10 <botlish_entry_13: geo_append<mutarray, int, mutarray>>:
     f10:	push   rbp
     f11:	mov    rbp,rsp
     f14:	mov    rsi,QWORD PTR [rdx]
     f17:	mov    r8,QWORD PTR [rdx+0x8]
     f1b:	mov    rcx,QWORD PTR [rdx+0x10]
     f1f:	mov    rdx,r8
     f22:	call   f27 <botlish_entry_13+0x17>
			f23: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
     f27:	mov    rsp,rbp
     f2a:	pop    rbp
     f2b:	ret

0000000000000f2c <botlish_fn_14: geo_finish<mutarray, int>>:
     f2c:	push   rbp
     f2d:	mov    rbp,rsp
     f30:	sub    rsp,0x10
     f34:	mov    QWORD PTR [rsp],rsi
     f38:	mov    QWORD PTR [rsp+0x8],rdx
     f3d:	call   f42 <botlish_fn_14+0x16>
			f3e: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     f42:	test   rax,rax
     f45:	jne    f57 <botlish_fn_14+0x2b>
     f4b:	xor    rax,rax
     f4e:	add    rsp,0x10
     f52:	mov    rsp,rbp
     f55:	pop    rbp
     f56:	ret
     f57:	add    rsp,0x10
     f5b:	mov    rsp,rbp
     f5e:	pop    rbp
     f5f:	ret

0000000000000f60 <botlish_entry_14: geo_finish<mutarray, int>>:
     f60:	push   rbp
     f61:	mov    rbp,rsp
     f64:	mov    rsi,QWORD PTR [rdx]
     f67:	mov    rdx,QWORD PTR [rdx+0x8]
     f6b:	call   f70 <botlish_entry_14+0x10>
			f6c: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
     f70:	mov    rsp,rbp
     f73:	pop    rbp
     f74:	ret
     f75:	add    BYTE PTR [rax],al
	...

0000000000000f78 <botlish_fn_15: peek<str, int>>:
     f78:	push   rbp
     f79:	mov    rbp,rsp
     f7c:	sub    rsp,0x40
     f80:	mov    QWORD PTR [rsp+0x20],rbx
     f85:	mov    QWORD PTR [rsp+0x28],r12
     f8a:	mov    QWORD PTR [rsp+0x30],r13
     f8f:	mov    rbx,rdx
     f92:	mov    r13,rdi
     f95:	mov    QWORD PTR [rsp],rsi
     f99:	mov    QWORD PTR [rsp+0x8],rdx
     f9e:	mov    rdx,QWORD PTR [rsi+0x8]
     fa2:	mov    r12,rsi
     fa5:	shl    rdx,1
     fa8:	mov    rax,rdx
     fab:	or     rax,0x1
     faf:	mov    rcx,rbx
     fb2:	and    rcx,rax
     fb5:	test   rcx,0x1
     fbc:	jne    fe6 <botlish_fn_15+0x6e>
     fc2:	or     rdx,0x1
     fc6:	mov    rsi,rbx
     fc9:	mov    rdi,r13
     fcc:	call   fd1 <botlish_fn_15+0x59>
			fcd: R_X86_64_PLT32	rt_int_cmp-0x4
     fd1:	mov    ecx,0x2
     fd6:	test   rax,rax
     fd9:	cmovge rcx,QWORD PTR [rip+0xd7]        # 10b8 <botlish_fn_15+0x140>
     fe1:	jmp    ffa <botlish_fn_15+0x82>
     fe6:	or     rdx,0x1
     fea:	mov    ecx,0x2
     fef:	cmp    rbx,rdx
     ff2:	cmovge rcx,QWORD PTR [rip+0xbe]        # 10b8 <botlish_fn_15+0x140>
     ffa:	cmp    rcx,0x6
     ffe:	je     108e <botlish_fn_15+0x116>
    1004:	mov    QWORD PTR [rsp+0x10],0x3
    100d:	test   rbx,0x1
    1014:	je     102c <botlish_fn_15+0xb4>
    101a:	mov    rcx,rbx
    101d:	add    rcx,0x2
    1021:	seto   al
    1024:	test   al,al
    1026:	je     103f <botlish_fn_15+0xc7>
    102c:	mov    edx,0x3
    1031:	mov    rsi,rbx
    1034:	mov    rdi,r13
    1037:	call   103c <botlish_fn_15+0xc4>
			1038: R_X86_64_PLT32	rt_int_add-0x4
    103c:	mov    rcx,rax
    103f:	mov    QWORD PTR [rsp+0x10],rcx
    1044:	mov    rdx,rbx
    1047:	mov    rsi,r12
    104a:	mov    rdi,r13
    104d:	call   1052 <botlish_fn_15+0xda>
			104e: R_X86_64_PLT32	rt_substr-0x4
    1052:	test   rax,rax
    1055:	jne    1076 <botlish_fn_15+0xfe>
    105b:	xor    rax,rax
    105e:	mov    rbx,QWORD PTR [rsp+0x20]
    1063:	mov    r12,QWORD PTR [rsp+0x28]
    1068:	mov    r13,QWORD PTR [rsp+0x30]
    106d:	add    rsp,0x40
    1071:	mov    rsp,rbp
    1074:	pop    rbp
    1075:	ret
    1076:	mov    rbx,QWORD PTR [rsp+0x20]
    107b:	mov    r12,QWORD PTR [rsp+0x28]
    1080:	mov    r13,QWORD PTR [rsp+0x30]
    1085:	add    rsp,0x40
    1089:	mov    rsp,rbp
    108c:	pop    rbp
    108d:	ret
    108e:	mov    rdi,r13
    1091:	mov    rax,QWORD PTR [rdi+0x10]
    1095:	mov    rax,QWORD PTR [rax+0x8]
    1099:	mov    rbx,QWORD PTR [rsp+0x20]
    109e:	mov    r12,QWORD PTR [rsp+0x28]
    10a3:	mov    r13,QWORD PTR [rsp+0x30]
    10a8:	add    rsp,0x40
    10ac:	mov    rsp,rbp
    10af:	pop    rbp
    10b0:	ret
    10b1:	add    BYTE PTR [rax],al
    10b3:	add    BYTE PTR [rax],al
    10b5:	add    BYTE PTR [rax],al
    10b7:	add    BYTE PTR [rsi],al
    10b9:	add    BYTE PTR [rax],al
    10bb:	add    BYTE PTR [rax],al
    10bd:	add    BYTE PTR [rax],al
	...

00000000000010c0 <botlish_entry_15: peek<str, int>>:
    10c0:	push   rbp
    10c1:	mov    rbp,rsp
    10c4:	mov    rsi,QWORD PTR [rdx]
    10c7:	mov    rdx,QWORD PTR [rdx+0x8]
    10cb:	call   10d0 <botlish_entry_15+0x10>
			10cc: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    10d0:	mov    rsp,rbp
    10d3:	pop    rbp
    10d4:	ret
    10d5:	add    BYTE PTR [rax],al
	...

00000000000010d8 <botlish_fn_16: peek<str, int>>:
    10d8:	push   rbp
    10d9:	mov    rbp,rsp
    10dc:	sub    rsp,0x50
    10e0:	mov    QWORD PTR [rsp+0x20],rbx
    10e5:	mov    QWORD PTR [rsp+0x28],r12
    10ea:	mov    QWORD PTR [rsp+0x30],r13
    10ef:	mov    QWORD PTR [rsp+0x38],r14
    10f4:	mov    QWORD PTR [rsp+0x40],r15
    10f9:	mov    rbx,rdx
    10fc:	mov    r12,rcx
    10ff:	mov    r14,rdi
    1102:	mov    QWORD PTR [rsp],rsi
    1106:	mov    QWORD PTR [rsp+0x8],rdx
    110b:	mov    rdx,QWORD PTR [rsi+0x8]
    110f:	mov    r13,rsi
    1112:	shl    rdx,1
    1115:	mov    rax,rdx
    1118:	or     rax,0x1
    111c:	mov    rcx,rbx
    111f:	and    rcx,rax
    1122:	test   rcx,0x1
    1129:	jne    1153 <botlish_fn_16+0x7b>
    112f:	or     rdx,0x1
    1133:	mov    rsi,rbx
    1136:	mov    rdi,r14
    1139:	call   113e <botlish_fn_16+0x66>
			113a: R_X86_64_PLT32	rt_int_cmp-0x4
    113e:	mov    ecx,0x2
    1143:	test   rax,rax
    1146:	cmovge rcx,QWORD PTR [rip+0x122]        # 1270 <botlish_fn_16+0x198>
    114e:	jmp    1167 <botlish_fn_16+0x8f>
    1153:	or     rdx,0x1
    1157:	mov    ecx,0x2
    115c:	cmp    rbx,rdx
    115f:	cmovge rcx,QWORD PTR [rip+0x109]        # 1270 <botlish_fn_16+0x198>
    1167:	cmp    rcx,0x6
    116b:	je     122b <botlish_fn_16+0x153>
    1171:	mov    QWORD PTR [rsp+0x10],0x3
    117a:	test   rbx,0x1
    1181:	je     11a4 <botlish_fn_16+0xcc>
    1187:	mov    rax,rbx
    118a:	add    rax,0x2
    118e:	seto   cl
    1191:	test   cl,cl
    1193:	jne    11a4 <botlish_fn_16+0xcc>
    1199:	mov    rdi,r14
    119c:	mov    r15,rax
    119f:	jmp    11ba <botlish_fn_16+0xe2>
    11a4:	mov    edx,0x3
    11a9:	mov    rsi,rbx
    11ac:	mov    rdi,r14
    11af:	call   11b4 <botlish_fn_16+0xdc>
			11b0: R_X86_64_PLT32	rt_int_add-0x4
    11b4:	mov    r15,rax
    11b7:	mov    rdi,r14
    11ba:	mov    rdi,r14
    11bd:	mov    rcx,r15
    11c0:	mov    rdx,rbx
    11c3:	mov    rsi,r13
    11c6:	call   11cb <botlish_fn_16+0xf3>
			11c7: R_X86_64_PLT32	rt_str_region_check-0x4
    11cb:	test   rax,rax
    11ce:	jne    11f9 <botlish_fn_16+0x121>
    11d4:	xor    rax,rax
    11d7:	mov    rbx,QWORD PTR [rsp+0x20]
    11dc:	mov    r12,QWORD PTR [rsp+0x28]
    11e1:	mov    r13,QWORD PTR [rsp+0x30]
    11e6:	mov    r14,QWORD PTR [rsp+0x38]
    11eb:	mov    r15,QWORD PTR [rsp+0x40]
    11f0:	add    rsp,0x50
    11f4:	mov    rsp,rbp
    11f7:	pop    rbp
    11f8:	ret
    11f9:	mov    rcx,r12
    11fc:	mov    QWORD PTR [rcx],rbx
    11ff:	mov    rax,r15
    1202:	mov    QWORD PTR [rcx+0x8],rax
    1206:	mov    rax,r13
    1209:	mov    rbx,QWORD PTR [rsp+0x20]
    120e:	mov    r12,QWORD PTR [rsp+0x28]
    1213:	mov    r13,QWORD PTR [rsp+0x30]
    1218:	mov    r14,QWORD PTR [rsp+0x38]
    121d:	mov    r15,QWORD PTR [rsp+0x40]
    1222:	add    rsp,0x50
    1226:	mov    rsp,rbp
    1229:	pop    rbp
    122a:	ret
    122b:	mov    rcx,r12
    122e:	mov    rdi,r14
    1231:	mov    rax,QWORD PTR [rdi+0x10]
    1235:	mov    rax,QWORD PTR [rax+0x8]
    1239:	mov    QWORD PTR [rcx],0x1
    1240:	mov    QWORD PTR [rcx+0x8],0x1
    1248:	mov    rbx,QWORD PTR [rsp+0x20]
    124d:	mov    r12,QWORD PTR [rsp+0x28]
    1252:	mov    r13,QWORD PTR [rsp+0x30]
    1257:	mov    r14,QWORD PTR [rsp+0x38]
    125c:	mov    r15,QWORD PTR [rsp+0x40]
    1261:	add    rsp,0x50
    1265:	mov    rsp,rbp
    1268:	pop    rbp
    1269:	ret
    126a:	add    BYTE PTR [rax],al
    126c:	add    BYTE PTR [rax],al
    126e:	add    BYTE PTR [rax],al
    1270:	(bad)
    1271:	add    BYTE PTR [rax],al
    1273:	add    BYTE PTR [rax],al
    1275:	add    BYTE PTR [rax],al
	...

0000000000001278 <botlish_entry_16: peek<str, int>>:
    1278:	push   rbp
    1279:	mov    rbp,rsp
    127c:	ud2

000000000000127e <botlish_fn_17: scan_unquoted<str, int, int>>:
    127e:	push   rbp
    127f:	mov    rbp,rsp
    1282:	sub    rsp,0x80
    1289:	mov    QWORD PTR [rsp+0x50],rbx
    128e:	mov    QWORD PTR [rsp+0x58],r12
    1293:	mov    QWORD PTR [rsp+0x60],r13
    1298:	mov    QWORD PTR [rsp+0x68],r14
    129d:	mov    QWORD PTR [rsp+0x70],r15
    12a2:	mov    QWORD PTR [rsp+0x30],rdi
    12a7:	mov    QWORD PTR [rsp+0x18],0x0
    12b0:	mov    QWORD PTR [rsp],rsi
    12b4:	mov    r15,rsi
    12b7:	mov    QWORD PTR [rsp+0x8],rdx
    12bc:	mov    r14,rdx
    12bf:	mov    QWORD PTR [rsp+0x10],rcx
    12c4:	lea    r13,[rsp+0x20]
    12c9:	mov    QWORD PTR [rsp+0x38],rcx
    12ce:	mov    rcx,r13
    12d1:	mov    rdx,QWORD PTR [rsp+0x38]
    12d6:	mov    rsi,r15
    12d9:	mov    rdi,QWORD PTR [rsp+0x30]
    12de:	call   12e3 <botlish_fn_17+0x65>
			12df: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    12e3:	mov    rsi,rax
    12e6:	mov    QWORD PTR [rsp+0x40],rax
    12eb:	test   rax,rsi
    12ee:	je     1448 <botlish_fn_17+0x1ca>
    12f4:	mov    rbx,QWORD PTR [rsp+0x20]
    12f9:	mov    r12,QWORD PTR [rsp+0x28]
    12fe:	mov    rdi,QWORD PTR [rsp+0x30]
    1303:	mov    rcx,QWORD PTR [rdi+0x10]
    1307:	mov    r8,QWORD PTR [rcx+0x8]
    130b:	mov    rcx,r12
    130e:	mov    rdx,rbx
    1311:	mov    rsi,QWORD PTR [rsp+0x40]
    1316:	call   131b <botlish_fn_17+0x9d>
			1317: R_X86_64_PLT32	rt_str_region_eq-0x4
    131b:	cmp    rax,0x6
    131f:	je     1360 <botlish_fn_17+0xe2>
    1325:	mov    rdi,QWORD PTR [rsp+0x30]
    132a:	mov    rax,QWORD PTR [rdi+0x10]
    132e:	mov    r8,QWORD PTR [rax+0x10]
    1332:	mov    rcx,r12
    1335:	mov    rdx,rbx
    1338:	mov    rsi,QWORD PTR [rsp+0x40]
    133d:	call   1342 <botlish_fn_17+0xc4>
			133e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1342:	cmp    rax,0x6
    1346:	je     1356 <botlish_fn_17+0xd8>
    134c:	mov    eax,0x2
    1351:	jmp    1365 <botlish_fn_17+0xe7>
    1356:	mov    eax,0x6
    135b:	jmp    1365 <botlish_fn_17+0xe7>
    1360:	mov    eax,0x6
    1365:	cmp    rax,0x6
    1369:	je     13aa <botlish_fn_17+0x12c>
    136f:	mov    rdi,QWORD PTR [rsp+0x30]
    1374:	mov    rax,QWORD PTR [rdi+0x10]
    1378:	mov    r8,QWORD PTR [rax+0x18]
    137c:	mov    rcx,r12
    137f:	mov    rdx,rbx
    1382:	mov    rsi,QWORD PTR [rsp+0x40]
    1387:	call   138c <botlish_fn_17+0x10e>
			1388: R_X86_64_PLT32	rt_str_region_eq-0x4
    138c:	cmp    rax,0x6
    1390:	je     13a0 <botlish_fn_17+0x122>
    1396:	mov    eax,0x2
    139b:	jmp    13af <botlish_fn_17+0x131>
    13a0:	mov    eax,0x6
    13a5:	jmp    13af <botlish_fn_17+0x131>
    13aa:	mov    eax,0x6
    13af:	cmp    rax,0x6
    13b3:	je     142a <botlish_fn_17+0x1ac>
    13b9:	mov    QWORD PTR [rsp+0x18],0x3
    13c2:	mov    rsi,QWORD PTR [rsp+0x38]
    13c7:	test   rsi,0x1
    13ce:	je     13f5 <botlish_fn_17+0x177>
    13d4:	mov    rsi,QWORD PTR [rsp+0x38]
    13d9:	mov    rax,rsi
    13dc:	add    rax,0x2
    13e0:	seto   sil
    13e4:	test   sil,sil
    13e7:	jne    13f5 <botlish_fn_17+0x177>
    13ed:	mov    rsi,r15
    13f0:	jmp    140c <botlish_fn_17+0x18e>
    13f5:	mov    edx,0x3
    13fa:	mov    rsi,QWORD PTR [rsp+0x38]
    13ff:	mov    rdi,QWORD PTR [rsp+0x30]
    1404:	call   1409 <botlish_fn_17+0x18b>
			1405: R_X86_64_PLT32	rt_int_add-0x4
    1409:	mov    rsi,r15
    140c:	mov    QWORD PTR [rsp],rsi
    1410:	mov    rdx,r14
    1413:	mov    QWORD PTR [rsp+0x8],rdx
    1418:	mov    QWORD PTR [rsp+0x10],rax
    141d:	mov    r15,rsi
    1420:	mov    QWORD PTR [rsp+0x38],rax
    1425:	jmp    12ce <botlish_fn_17+0x50>
    142a:	mov    rdx,r14
    142d:	mov    rsi,r15
    1430:	mov    rdi,QWORD PTR [rsp+0x30]
    1435:	mov    rcx,QWORD PTR [rsp+0x38]
    143a:	call   143f <botlish_fn_17+0x1c1>
			143b: R_X86_64_PLT32	rt_substr-0x4
    143f:	test   rax,rax
    1442:	jne    1473 <botlish_fn_17+0x1f5>
    1448:	xor    rdx,rdx
    144b:	mov    rax,rdx
    144e:	mov    rbx,QWORD PTR [rsp+0x50]
    1453:	mov    r12,QWORD PTR [rsp+0x58]
    1458:	mov    r13,QWORD PTR [rsp+0x60]
    145d:	mov    r14,QWORD PTR [rsp+0x68]
    1462:	mov    r15,QWORD PTR [rsp+0x70]
    1467:	add    rsp,0x80
    146e:	mov    rsp,rbp
    1471:	pop    rbp
    1472:	ret
    1473:	mov    rdx,QWORD PTR [rsp+0x38]
    1478:	mov    rbx,QWORD PTR [rsp+0x50]
    147d:	mov    r12,QWORD PTR [rsp+0x58]
    1482:	mov    r13,QWORD PTR [rsp+0x60]
    1487:	mov    r14,QWORD PTR [rsp+0x68]
    148c:	mov    r15,QWORD PTR [rsp+0x70]
    1491:	add    rsp,0x80
    1498:	mov    rsp,rbp
    149b:	pop    rbp
    149c:	ret

000000000000149d <botlish_entry_17: scan_unquoted<str, int, int>>:
    149d:	push   rbp
    149e:	mov    rbp,rsp
    14a1:	ud2

00000000000014a3 <botlish_fn_18: scan_quoted<str, int, str>>:
    14a3:	push   rbp
    14a4:	mov    rbp,rsp
    14a7:	sub    rsp,0xd0
    14ae:	mov    QWORD PTR [rsp+0xa0],rbx
    14b6:	mov    QWORD PTR [rsp+0xa8],r12
    14be:	mov    QWORD PTR [rsp+0xb0],r13
    14c6:	mov    QWORD PTR [rsp+0xb8],r14
    14ce:	mov    QWORD PTR [rsp+0xc0],r15
    14d6:	mov    QWORD PTR [rsp+0x88],rdi
    14de:	mov    QWORD PTR [rsp+0x18],0x0
    14e7:	mov    QWORD PTR [rsp+0x20],0x0
    14f0:	mov    QWORD PTR [rsp],rsi
    14f4:	mov    QWORD PTR [rsp+0x8],rdx
    14f9:	mov    QWORD PTR [rsp+0x10],rcx
    14fe:	mov    r13,rcx
    1501:	lea    r14,[rsp+0x68]
    1506:	lea    rbx,[rsp+0x28]
    150b:	mov    r12,rsi
    150e:	mov    QWORD PTR [rsp+0x90],rdx
    1516:	mov    rdx,QWORD PTR [rsp+0x90]
    151e:	mov    rsi,r12
    1521:	mov    rdi,QWORD PTR [rsp+0x88]
    1529:	call   152e <botlish_fn_18+0x8b>
			152a: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    152e:	test   rax,rax
    1531:	je     187a <botlish_fn_18+0x3d7>
    1537:	mov    QWORD PTR [rsp+0x18],rax
    153c:	mov    rsi,QWORD PTR [rax+0x8]
    1540:	mov    rcx,rax
    1543:	mov    rax,0xffffffffffffffff
    154a:	test   rsi,rsi
    154d:	jne    155b <botlish_fn_18+0xb8>
    1553:	mov    r15,rcx
    1556:	jmp    1586 <botlish_fn_18+0xe3>
    155b:	mov    r15,rcx
    155e:	movzx  rdi,BYTE PTR [r15+0x18]
    1563:	test   rdi,rdi
    1566:	jne    1581 <botlish_fn_18+0xde>
    156c:	mov    rsi,r15
    156f:	mov    rdi,QWORD PTR [rsp+0x88]
    1577:	call   157c <botlish_fn_18+0xd9>
			1578: R_X86_64_PLT32	rt_str_to_short-0x4
    157c:	jmp    1586 <botlish_fn_18+0xe3>
    1581:	movzx  rax,BYTE PTR [r15+0x19]
    1586:	cmp    rax,0x22
    158a:	je     164a <botlish_fn_18+0x1a7>
    1590:	mov    QWORD PTR [rsp+0x20],0x3
    1599:	mov    rsi,QWORD PTR [rsp+0x90]
    15a1:	test   rsi,0x1
    15a8:	je     15c8 <botlish_fn_18+0x125>
    15ae:	mov    rax,rsi
    15b1:	add    rax,0x2
    15b5:	seto   cl
    15b8:	test   cl,cl
    15ba:	jne    15c8 <botlish_fn_18+0x125>
    15c0:	mov    rsi,rax
    15c3:	jmp    15dd <botlish_fn_18+0x13a>
    15c8:	mov    edx,0x3
    15cd:	mov    rdi,QWORD PTR [rsp+0x88]
    15d5:	call   15da <botlish_fn_18+0x137>
			15d6: R_X86_64_PLT32	rt_int_add-0x4
    15da:	mov    rsi,rax
    15dd:	mov    QWORD PTR [rsp+0x8],rsi
    15e2:	mov    QWORD PTR [rsp+0x90],rsi
    15ea:	mov    QWORD PTR [rsp+0x68],0x0
    15f3:	mov    QWORD PTR [rsp+0x70],r13
    15f8:	mov    QWORD PTR [rsp+0x78],0x0
    1601:	mov    QWORD PTR [rsp+0x80],r15
    1609:	mov    esi,0x2
    160e:	mov    edx,0x4
    1613:	mov    rcx,r14
    1616:	mov    rdi,QWORD PTR [rsp+0x88]
    161e:	call   1623 <botlish_fn_18+0x180>
			161f: R_X86_64_PLT32	rt_construct-0x4
    1623:	test   rax,rax
    1626:	je     187a <botlish_fn_18+0x3d7>
    162c:	mov    QWORD PTR [rsp],r12
    1630:	mov    rsi,QWORD PTR [rsp+0x90]
    1638:	mov    QWORD PTR [rsp+0x8],rsi
    163d:	mov    QWORD PTR [rsp+0x10],rax
    1642:	mov    r13,rax
    1645:	jmp    1516 <botlish_fn_18+0x73>
    164a:	mov    QWORD PTR [rsp+0x18],0x3
    1653:	mov    rsi,QWORD PTR [rsp+0x90]
    165b:	test   rsi,0x1
    1662:	je     1682 <botlish_fn_18+0x1df>
    1668:	mov    rsi,QWORD PTR [rsp+0x90]
    1670:	mov    rdx,rsi
    1673:	add    rdx,0x2
    1677:	seto   al
    167a:	test   al,al
    167c:	je     169f <botlish_fn_18+0x1fc>
    1682:	mov    edx,0x3
    1687:	mov    rsi,QWORD PTR [rsp+0x90]
    168f:	mov    rdi,QWORD PTR [rsp+0x88]
    1697:	call   169c <botlish_fn_18+0x1f9>
			1698: R_X86_64_PLT32	rt_int_add-0x4
    169c:	mov    rdx,rax
    169f:	mov    QWORD PTR [rsp+0x18],rdx
    16a4:	mov    rcx,rbx
    16a7:	mov    rsi,r12
    16aa:	mov    rdi,QWORD PTR [rsp+0x88]
    16b2:	call   16b7 <botlish_fn_18+0x214>
			16b3: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    16b7:	test   rax,rax
    16ba:	mov    rsi,rax
    16bd:	je     187a <botlish_fn_18+0x3d7>
    16c3:	mov    rdx,QWORD PTR [rsp+0x28]
    16c8:	mov    rcx,QWORD PTR [rsp+0x30]
    16cd:	mov    rdi,QWORD PTR [rsp+0x88]
    16d5:	mov    rax,QWORD PTR [rdi+0x10]
    16d9:	mov    r8,QWORD PTR [rax+0x20]
    16dd:	call   16e2 <botlish_fn_18+0x23f>
			16de: R_X86_64_PLT32	rt_str_region_eq-0x4
    16e2:	cmp    rax,0x6
    16e6:	je     17b8 <botlish_fn_18+0x315>
    16ec:	xor    rsi,rsi
    16ef:	lea    rcx,[rsp+0x58]
    16f4:	mov    QWORD PTR [rsp+0x58],0x0
    16fd:	mov    QWORD PTR [rsp+0x60],r13
    1702:	mov    edx,0x2
    1707:	mov    rdi,QWORD PTR [rsp+0x88]
    170f:	call   1714 <botlish_fn_18+0x271>
			1710: R_X86_64_PLT32	rt_construct-0x4
    1714:	test   rax,rax
    1717:	je     187a <botlish_fn_18+0x3d7>
    171d:	mov    QWORD PTR [rsp],rax
    1721:	mov    rbx,rax
    1724:	mov    QWORD PTR [rsp+0x10],0x3
    172d:	mov    rsi,QWORD PTR [rsp+0x90]
    1735:	test   rsi,0x1
    173c:	je     1764 <botlish_fn_18+0x2c1>
    1742:	mov    rsi,QWORD PTR [rsp+0x90]
    174a:	mov    rdx,rsi
    174d:	add    rdx,0x2
    1751:	seto   al
    1754:	test   al,al
    1756:	jne    1764 <botlish_fn_18+0x2c1>
    175c:	mov    rax,rbx
    175f:	jmp    1784 <botlish_fn_18+0x2e1>
    1764:	mov    edx,0x3
    1769:	mov    rsi,QWORD PTR [rsp+0x90]
    1771:	mov    rdi,QWORD PTR [rsp+0x88]
    1779:	call   177e <botlish_fn_18+0x2db>
			177a: R_X86_64_PLT32	rt_int_add-0x4
    177e:	mov    rdx,rax
    1781:	mov    rax,rbx
    1784:	mov    rbx,QWORD PTR [rsp+0xa0]
    178c:	mov    r12,QWORD PTR [rsp+0xa8]
    1794:	mov    r13,QWORD PTR [rsp+0xb0]
    179c:	mov    r14,QWORD PTR [rsp+0xb8]
    17a4:	mov    r15,QWORD PTR [rsp+0xc0]
    17ac:	add    rsp,0xd0
    17b3:	mov    rsp,rbp
    17b6:	pop    rbp
    17b7:	ret
    17b8:	mov    QWORD PTR [rsp+0x18],0x5
    17c1:	mov    rsi,QWORD PTR [rsp+0x90]
    17c9:	test   rsi,0x1
    17d0:	je     1802 <botlish_fn_18+0x35f>
    17d6:	mov    rsi,QWORD PTR [rsp+0x90]
    17de:	mov    rdi,rsi
    17e1:	add    rdi,0x4
    17e5:	seto   r9b
    17e9:	test   r9b,r9b
    17ec:	jne    1802 <botlish_fn_18+0x35f>
    17f2:	mov    rsi,rdi
    17f5:	mov    QWORD PTR [rsp+0x90],rdi
    17fd:	jmp    1827 <botlish_fn_18+0x384>
    1802:	mov    edx,0x5
    1807:	mov    rsi,QWORD PTR [rsp+0x90]
    180f:	mov    rdi,QWORD PTR [rsp+0x88]
    1817:	call   181c <botlish_fn_18+0x379>
			1818: R_X86_64_PLT32	rt_int_add-0x4
    181c:	mov    rsi,rax
    181f:	mov    QWORD PTR [rsp+0x90],rax
    1827:	mov    QWORD PTR [rsp+0x8],rsi
    182c:	mov    rdi,QWORD PTR [rsp+0x88]
    1834:	mov    rax,QWORD PTR [rdi+0x10]
    1838:	mov    rax,QWORD PTR [rax+0x20]
    183c:	mov    QWORD PTR [rsp+0x18],rax
    1841:	lea    rcx,[rsp+0x38]
    1846:	mov    QWORD PTR [rsp+0x38],0x0
    184f:	mov    QWORD PTR [rsp+0x40],r13
    1854:	mov    QWORD PTR [rsp+0x48],0x0
    185d:	mov    QWORD PTR [rsp+0x50],rax
    1862:	mov    esi,0x2
    1867:	mov    edx,0x4
    186c:	call   1871 <botlish_fn_18+0x3ce>
			186d: R_X86_64_PLT32	rt_construct-0x4
    1871:	test   rax,rax
    1874:	jne    18b4 <botlish_fn_18+0x411>
    187a:	xor    rdx,rdx
    187d:	mov    rax,rdx
    1880:	mov    rbx,QWORD PTR [rsp+0xa0]
    1888:	mov    r12,QWORD PTR [rsp+0xa8]
    1890:	mov    r13,QWORD PTR [rsp+0xb0]
    1898:	mov    r14,QWORD PTR [rsp+0xb8]
    18a0:	mov    r15,QWORD PTR [rsp+0xc0]
    18a8:	add    rsp,0xd0
    18af:	mov    rsp,rbp
    18b2:	pop    rbp
    18b3:	ret
    18b4:	mov    QWORD PTR [rsp],r12
    18b8:	mov    rsi,QWORD PTR [rsp+0x90]
    18c0:	mov    QWORD PTR [rsp+0x8],rsi
    18c5:	mov    QWORD PTR [rsp+0x10],rax
    18ca:	mov    r13,rax
    18cd:	jmp    1516 <botlish_fn_18+0x73>

00000000000018d2 <botlish_entry_18: scan_quoted<str, int, str>>:
    18d2:	push   rbp
    18d3:	mov    rbp,rsp
    18d6:	ud2

00000000000018d8 <botlish_fn_19: scan_field<str, int>>:
    18d8:	push   rbp
    18d9:	mov    rbp,rsp
    18dc:	sub    rsp,0x50
    18e0:	mov    QWORD PTR [rsp+0x30],rbx
    18e5:	mov    QWORD PTR [rsp+0x38],r12
    18ea:	mov    QWORD PTR [rsp+0x40],r13
    18ef:	mov    r12,rdi
    18f2:	mov    r13,rdx
    18f5:	mov    QWORD PTR [rsp+0x10],0x0
    18fe:	mov    QWORD PTR [rsp],rsi
    1902:	mov    rbx,rsi
    1905:	mov    QWORD PTR [rsp+0x8],rdx
    190a:	lea    rcx,[rsp+0x18]
    190f:	mov    rdx,r13
    1912:	mov    rsi,rbx
    1915:	mov    rdi,r12
    1918:	call   191d <botlish_fn_19+0x45>
			1919: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    191d:	test   rax,rax
    1920:	mov    rsi,rax
    1923:	je     19ee <botlish_fn_19+0x116>
    1929:	mov    rdx,QWORD PTR [rsp+0x18]
    192e:	mov    rcx,QWORD PTR [rsp+0x20]
    1933:	mov    rdi,r12
    1936:	mov    rax,QWORD PTR [rdi+0x10]
    193a:	mov    r8,QWORD PTR [rax+0x20]
    193e:	call   1943 <botlish_fn_19+0x6b>
			193f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1943:	cmp    rax,0x6
    1947:	je     197f <botlish_fn_19+0xa7>
    194d:	mov    rcx,r13
    1950:	mov    rsi,rbx
    1953:	mov    rdi,r12
    1956:	mov    rdx,rcx
    1959:	call   195e <botlish_fn_19+0x86>
			195a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    195e:	test   rax,rax
    1961:	je     19ee <botlish_fn_19+0x116>
    1967:	mov    rbx,QWORD PTR [rsp+0x30]
    196c:	mov    r12,QWORD PTR [rsp+0x38]
    1971:	mov    r13,QWORD PTR [rsp+0x40]
    1976:	add    rsp,0x50
    197a:	mov    rsp,rbp
    197d:	pop    rbp
    197e:	ret
    197f:	mov    rcx,r13
    1982:	mov    QWORD PTR [rsp+0x10],0x3
    198b:	test   rcx,0x1
    1992:	jne    19a0 <botlish_fn_19+0xc8>
    1998:	mov    r13,rcx
    199b:	jmp    19b5 <botlish_fn_19+0xdd>
    19a0:	mov    rdx,rcx
    19a3:	add    rdx,0x2
    19a7:	mov    r13,rcx
    19aa:	seto   al
    19ad:	test   al,al
    19af:	je     19c8 <botlish_fn_19+0xf0>
    19b5:	mov    edx,0x3
    19ba:	mov    rsi,r13
    19bd:	mov    rdi,r12
    19c0:	call   19c5 <botlish_fn_19+0xed>
			19c1: R_X86_64_PLT32	rt_int_add-0x4
    19c5:	mov    rdx,rax
    19c8:	mov    QWORD PTR [rsp+0x8],rdx
    19cd:	mov    rdi,r12
    19d0:	mov    rax,QWORD PTR [rdi+0x10]
    19d4:	mov    rcx,QWORD PTR [rax+0x8]
    19d8:	mov    QWORD PTR [rsp+0x10],rcx
    19dd:	mov    rsi,rbx
    19e0:	call   19e5 <botlish_fn_19+0x10d>
			19e1: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    19e5:	test   rax,rax
    19e8:	jne    1a0c <botlish_fn_19+0x134>
    19ee:	xor    rdx,rdx
    19f1:	mov    rax,rdx
    19f4:	mov    rbx,QWORD PTR [rsp+0x30]
    19f9:	mov    r12,QWORD PTR [rsp+0x38]
    19fe:	mov    r13,QWORD PTR [rsp+0x40]
    1a03:	add    rsp,0x50
    1a07:	mov    rsp,rbp
    1a0a:	pop    rbp
    1a0b:	ret
    1a0c:	mov    rbx,QWORD PTR [rsp+0x30]
    1a11:	mov    r12,QWORD PTR [rsp+0x38]
    1a16:	mov    r13,QWORD PTR [rsp+0x40]
    1a1b:	add    rsp,0x50
    1a1f:	mov    rsp,rbp
    1a22:	pop    rbp
    1a23:	ret

0000000000001a24 <botlish_entry_19: scan_field<str, int>>:
    1a24:	push   rbp
    1a25:	mov    rbp,rsp
    1a28:	ud2

0000000000001a2a <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    1a2a:	push   rbp
    1a2b:	mov    rbp,rsp
    1a2e:	sub    rsp,0x90
    1a35:	mov    QWORD PTR [rsp+0x60],rbx
    1a3a:	mov    QWORD PTR [rsp+0x68],r12
    1a3f:	mov    QWORD PTR [rsp+0x70],r13
    1a44:	mov    QWORD PTR [rsp+0x78],r14
    1a49:	mov    QWORD PTR [rsp+0x80],r15
    1a51:	mov    r15,rdi
    1a54:	mov    QWORD PTR [rsp+0x20],0x0
    1a5d:	mov    QWORD PTR [rsp],rsi
    1a61:	mov    QWORD PTR [rsp+0x8],rdx
    1a66:	mov    QWORD PTR [rsp+0x10],rcx
    1a6b:	mov    QWORD PTR [rsp+0x18],r8
    1a70:	lea    r12,[rsp+0x28]
    1a75:	mov    rbx,rsi
    1a78:	mov    QWORD PTR [rsp+0x38],rdx
    1a7d:	mov    QWORD PTR [rsp+0x40],rcx
    1a82:	mov    QWORD PTR [rsp+0x48],r8
    1a87:	mov    rcx,r12
    1a8a:	mov    rdx,QWORD PTR [rsp+0x38]
    1a8f:	mov    rsi,rbx
    1a92:	mov    rdi,r15
    1a95:	call   1a9a <botlish_fn_20+0x70>
			1a96: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1a9a:	test   rax,rax
    1a9d:	mov    QWORD PTR [rsp+0x50],rax
    1aa2:	je     1c66 <botlish_fn_20+0x23c>
    1aa8:	mov    r14,QWORD PTR [rsp+0x28]
    1aad:	mov    r13,QWORD PTR [rsp+0x30]
    1ab2:	mov    rdi,r15
    1ab5:	mov    rcx,QWORD PTR [rdi+0x10]
    1ab9:	mov    r8,QWORD PTR [rcx+0x10]
    1abd:	mov    rcx,r13
    1ac0:	mov    rdx,r14
    1ac3:	mov    rsi,QWORD PTR [rsp+0x50]
    1ac8:	call   1acd <botlish_fn_20+0xa3>
			1ac9: R_X86_64_PLT32	rt_str_region_eq-0x4
    1acd:	cmp    rax,0x6
    1ad1:	je     1bdf <botlish_fn_20+0x1b5>
    1ad7:	mov    rdi,r15
    1ada:	mov    rax,QWORD PTR [rdi+0x10]
    1ade:	mov    r8,QWORD PTR [rax+0x18]
    1ae2:	mov    rcx,r13
    1ae5:	mov    rdx,r14
    1ae8:	mov    rsi,QWORD PTR [rsp+0x50]
    1aed:	call   1af2 <botlish_fn_20+0xc8>
			1aee: R_X86_64_PLT32	rt_str_region_eq-0x4
    1af2:	cmp    rax,0x6
    1af6:	je     1b44 <botlish_fn_20+0x11a>
    1afc:	mov    rdx,QWORD PTR [rsp+0x48]
    1b01:	mov    rsi,QWORD PTR [rsp+0x40]
    1b06:	mov    rdi,r15
    1b09:	call   1b0e <botlish_fn_20+0xe4>
			1b0a: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b0e:	test   rax,rax
    1b11:	je     1c66 <botlish_fn_20+0x23c>
    1b17:	mov    rdx,QWORD PTR [rsp+0x38]
    1b1c:	mov    rbx,QWORD PTR [rsp+0x60]
    1b21:	mov    r12,QWORD PTR [rsp+0x68]
    1b26:	mov    r13,QWORD PTR [rsp+0x70]
    1b2b:	mov    r14,QWORD PTR [rsp+0x78]
    1b30:	mov    r15,QWORD PTR [rsp+0x80]
    1b38:	add    rsp,0x90
    1b3f:	mov    rsp,rbp
    1b42:	pop    rbp
    1b43:	ret
    1b44:	mov    rdx,QWORD PTR [rsp+0x48]
    1b49:	mov    rsi,QWORD PTR [rsp+0x40]
    1b4e:	mov    rdi,r15
    1b51:	call   1b56 <botlish_fn_20+0x12c>
			1b52: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b56:	test   rax,rax
    1b59:	je     1c66 <botlish_fn_20+0x23c>
    1b5f:	mov    QWORD PTR [rsp],rax
    1b63:	mov    rbx,rax
    1b66:	mov    QWORD PTR [rsp+0x10],0x3
    1b6f:	mov    rdx,QWORD PTR [rsp+0x38]
    1b74:	test   rdx,0x1
    1b7b:	je     1b9f <botlish_fn_20+0x175>
    1b81:	mov    rdx,QWORD PTR [rsp+0x38]
    1b86:	add    rdx,0x2
    1b8a:	seto   sil
    1b8e:	test   sil,sil
    1b91:	jne    1b9f <botlish_fn_20+0x175>
    1b97:	mov    rax,rbx
    1b9a:	jmp    1bb7 <botlish_fn_20+0x18d>
    1b9f:	mov    edx,0x3
    1ba4:	mov    rsi,QWORD PTR [rsp+0x38]
    1ba9:	mov    rdi,r15
    1bac:	call   1bb1 <botlish_fn_20+0x187>
			1bad: R_X86_64_PLT32	rt_int_add-0x4
    1bb1:	mov    rdx,rax
    1bb4:	mov    rax,rbx
    1bb7:	mov    rbx,QWORD PTR [rsp+0x60]
    1bbc:	mov    r12,QWORD PTR [rsp+0x68]
    1bc1:	mov    r13,QWORD PTR [rsp+0x70]
    1bc6:	mov    r14,QWORD PTR [rsp+0x78]
    1bcb:	mov    r15,QWORD PTR [rsp+0x80]
    1bd3:	add    rsp,0x90
    1bda:	mov    rsp,rbp
    1bdd:	pop    rbp
    1bde:	ret
    1bdf:	mov    rsi,QWORD PTR [rsp+0x38]
    1be4:	mov    edx,0x3
    1be9:	mov    r13,rdx
    1bec:	mov    QWORD PTR [rsp+0x20],0x3
    1bf5:	test   rsi,0x1
    1bfc:	je     1c14 <botlish_fn_20+0x1ea>
    1c02:	mov    rdx,rsi
    1c05:	add    rdx,0x2
    1c09:	seto   al
    1c0c:	test   al,al
    1c0e:	je     1c22 <botlish_fn_20+0x1f8>
    1c14:	mov    rdx,r13
    1c17:	mov    rdi,r15
    1c1a:	call   1c1f <botlish_fn_20+0x1f5>
			1c1b: R_X86_64_PLT32	rt_int_add-0x4
    1c1f:	mov    rdx,rax
    1c22:	mov    QWORD PTR [rsp+0x8],rdx
    1c27:	mov    rsi,rbx
    1c2a:	mov    rdi,r15
    1c2d:	call   1c32 <botlish_fn_20+0x208>
			1c2e: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1c32:	test   rax,rax
    1c35:	je     1c66 <botlish_fn_20+0x23c>
    1c3b:	mov    QWORD PTR [rsp+0x8],rax
    1c40:	mov    rcx,rax
    1c43:	mov    QWORD PTR [rsp+0x20],rdx
    1c48:	mov    rsi,QWORD PTR [rsp+0x40]
    1c4d:	mov    r14,rdx
    1c50:	mov    rdx,QWORD PTR [rsp+0x48]
    1c55:	mov    rdi,r15
    1c58:	call   1c5d <botlish_fn_20+0x233>
			1c59: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1c5d:	test   rax,rax
    1c60:	jne    1c94 <botlish_fn_20+0x26a>
    1c66:	xor    rdx,rdx
    1c69:	mov    rax,rdx
    1c6c:	mov    rbx,QWORD PTR [rsp+0x60]
    1c71:	mov    r12,QWORD PTR [rsp+0x68]
    1c76:	mov    r13,QWORD PTR [rsp+0x70]
    1c7b:	mov    r14,QWORD PTR [rsp+0x78]
    1c80:	mov    r15,QWORD PTR [rsp+0x80]
    1c88:	add    rsp,0x90
    1c8f:	mov    rsp,rbp
    1c92:	pop    rbp
    1c93:	ret
    1c94:	mov    QWORD PTR [rsp+0x8],rax
    1c99:	mov    QWORD PTR [rsp+0x38],rax
    1c9e:	mov    QWORD PTR [rsp+0x10],0x3
    1ca7:	mov    rdx,QWORD PTR [rsp+0x48]
    1cac:	test   rdx,0x1
    1cb3:	jne    1cc6 <botlish_fn_20+0x29c>
    1cb9:	mov    rdx,r13
    1cbc:	mov    rsi,QWORD PTR [rsp+0x48]
    1cc1:	jmp    1ce5 <botlish_fn_20+0x2bb>
    1cc6:	mov    rdx,QWORD PTR [rsp+0x48]
    1ccb:	mov    rax,rdx
    1cce:	add    rax,0x2
    1cd2:	seto   cl
    1cd5:	test   cl,cl
    1cd7:	je     1ced <botlish_fn_20+0x2c3>
    1cdd:	mov    rdx,r13
    1ce0:	mov    rsi,QWORD PTR [rsp+0x48]
    1ce5:	mov    rdi,r15
    1ce8:	call   1ced <botlish_fn_20+0x2c3>
			1ce9: R_X86_64_PLT32	rt_int_add-0x4
    1ced:	mov    QWORD PTR [rsp],rbx
    1cf1:	mov    rdx,r14
    1cf4:	mov    QWORD PTR [rsp+0x8],rdx
    1cf9:	mov    rcx,QWORD PTR [rsp+0x38]
    1cfe:	mov    QWORD PTR [rsp+0x10],rcx
    1d03:	mov    QWORD PTR [rsp+0x18],rax
    1d08:	mov    QWORD PTR [rsp+0x38],rdx
    1d0d:	mov    QWORD PTR [rsp+0x40],rcx
    1d12:	mov    QWORD PTR [rsp+0x48],rax
    1d17:	jmp    1a87 <botlish_fn_20+0x5d>

0000000000001d1c <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1d1c:	push   rbp
    1d1d:	mov    rbp,rsp
    1d20:	ud2

0000000000001d22 <botlish_fn_21: scan_record<str, int>>:
    1d22:	push   rbp
    1d23:	mov    rbp,rsp
    1d26:	sub    rsp,0x40
    1d2a:	mov    QWORD PTR [rsp+0x20],rbx
    1d2f:	mov    QWORD PTR [rsp+0x28],r12
    1d34:	mov    QWORD PTR [rsp+0x30],r14
    1d39:	mov    r14,rdi
    1d3c:	mov    QWORD PTR [rsp+0x10],0x0
    1d45:	mov    QWORD PTR [rsp+0x18],0x0
    1d4e:	mov    QWORD PTR [rsp],rsi
    1d52:	mov    r12,rsi
    1d55:	mov    QWORD PTR [rsp+0x8],rdx
    1d5a:	mov    rsi,r12
    1d5d:	mov    rdi,r14
    1d60:	call   1d65 <botlish_fn_21+0x43>
			1d61: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1d65:	test   rax,rax
    1d68:	je     1dbd <botlish_fn_21+0x9b>
    1d6e:	mov    QWORD PTR [rsp+0x8],rax
    1d73:	mov    rsi,rax
    1d76:	mov    QWORD PTR [rsp+0x10],rdx
    1d7b:	mov    rbx,rdx
    1d7e:	mov    rdi,r14
    1d81:	call   1d86 <botlish_fn_21+0x64>
			1d82: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1d86:	test   rax,rax
    1d89:	je     1dbd <botlish_fn_21+0x9b>
    1d8f:	mov    QWORD PTR [rsp+0x8],rax
    1d94:	mov    rcx,rax
    1d97:	mov    r8d,0x3
    1d9d:	mov    QWORD PTR [rsp+0x18],0x3
    1da6:	mov    rdx,rbx
    1da9:	mov    rsi,r12
    1dac:	mov    rdi,r14
    1daf:	call   1db4 <botlish_fn_21+0x92>
			1db0: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1db4:	test   rax,rax
    1db7:	jne    1ddb <botlish_fn_21+0xb9>
    1dbd:	xor    rdx,rdx
    1dc0:	mov    rax,rdx
    1dc3:	mov    rbx,QWORD PTR [rsp+0x20]
    1dc8:	mov    r12,QWORD PTR [rsp+0x28]
    1dcd:	mov    r14,QWORD PTR [rsp+0x30]
    1dd2:	add    rsp,0x40
    1dd6:	mov    rsp,rbp
    1dd9:	pop    rbp
    1dda:	ret
    1ddb:	mov    rbx,QWORD PTR [rsp+0x20]
    1de0:	mov    r12,QWORD PTR [rsp+0x28]
    1de5:	mov    r14,QWORD PTR [rsp+0x30]
    1dea:	add    rsp,0x40
    1dee:	mov    rsp,rbp
    1df1:	pop    rbp
    1df2:	ret

0000000000001df3 <botlish_entry_21: scan_record<str, int>>:
    1df3:	push   rbp
    1df4:	mov    rbp,rsp
    1df7:	ud2
    1df9:	add    BYTE PTR [rax],al
    1dfb:	add    BYTE PTR [rax],al
    1dfd:	add    BYTE PTR [rax],al
	...

0000000000001e00 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1e00:	push   rbp
    1e01:	mov    rbp,rsp
    1e04:	sub    rsp,0x60
    1e08:	mov    QWORD PTR [rsp+0x30],rbx
    1e0d:	mov    QWORD PTR [rsp+0x38],r12
    1e12:	mov    QWORD PTR [rsp+0x40],r13
    1e17:	mov    QWORD PTR [rsp+0x48],r14
    1e1c:	mov    QWORD PTR [rsp+0x50],r15
    1e21:	mov    r13,rdi
    1e24:	mov    QWORD PTR [rsp+0x20],0x0
    1e2d:	mov    QWORD PTR [rsp],rsi
    1e31:	mov    QWORD PTR [rsp+0x8],rdx
    1e36:	mov    rax,rdx
    1e39:	mov    QWORD PTR [rsp+0x10],rcx
    1e3e:	mov    QWORD PTR [rsp+0x18],r8
    1e43:	mov    rbx,rsi
    1e46:	mov    r14,r8
    1e49:	mov    r15,rcx
    1e4c:	mov    rdx,QWORD PTR [rbx+0x8]
    1e50:	shl    rdx,1
    1e53:	or     rdx,0x1
    1e57:	mov    r12,rax
    1e5a:	and    rax,rdx
    1e5d:	test   rax,0x1
    1e63:	jne    1e89 <botlish_fn_22+0x89>
    1e69:	mov    rsi,r12
    1e6c:	mov    rdi,r13
    1e6f:	call   1e74 <botlish_fn_22+0x74>
			1e70: R_X86_64_PLT32	rt_int_cmp-0x4
    1e74:	mov    ecx,0x2
    1e79:	test   rax,rax
    1e7c:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1fb0 <botlish_fn_22+0x1b0>
    1e84:	jmp    1e99 <botlish_fn_22+0x99>
    1e89:	mov    ecx,0x2
    1e8e:	cmp    r12,rdx
    1e91:	cmovge rcx,QWORD PTR [rip+0x117]        # 1fb0 <botlish_fn_22+0x1b0>
    1e99:	cmp    rcx,0x6
    1e9d:	je     1f4b <botlish_fn_22+0x14b>
    1ea3:	mov    rdx,r12
    1ea6:	mov    rsi,rbx
    1ea9:	mov    rdi,r13
    1eac:	call   1eb1 <botlish_fn_22+0xb1>
			1ead: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1eb1:	test   rax,rax
    1eb4:	je     1f62 <botlish_fn_22+0x162>
    1eba:	mov    QWORD PTR [rsp+0x8],rax
    1ebf:	mov    rcx,rax
    1ec2:	mov    QWORD PTR [rsp+0x20],rdx
    1ec7:	mov    rsi,r15
    1eca:	mov    r12,rdx
    1ecd:	mov    rdx,r14
    1ed0:	mov    rdi,r13
    1ed3:	call   1ed8 <botlish_fn_22+0xd8>
			1ed4: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1ed8:	test   rax,rax
    1edb:	je     1f62 <botlish_fn_22+0x162>
    1ee1:	mov    QWORD PTR [rsp+0x8],rax
    1ee6:	mov    r15,rax
    1ee9:	mov    QWORD PTR [rsp+0x10],0x3
    1ef2:	mov    rsi,r14
    1ef5:	test   rsi,0x1
    1efc:	je     1f17 <botlish_fn_22+0x117>
    1f02:	mov    rsi,r14
    1f05:	mov    rax,rsi
    1f08:	add    rax,0x2
    1f0c:	seto   cl
    1f0f:	test   cl,cl
    1f11:	je     1f27 <botlish_fn_22+0x127>
    1f17:	mov    edx,0x3
    1f1c:	mov    rsi,r14
    1f1f:	mov    rdi,r13
    1f22:	call   1f27 <botlish_fn_22+0x127>
			1f23: R_X86_64_PLT32	rt_int_add-0x4
    1f27:	mov    QWORD PTR [rsp],rbx
    1f2b:	mov    rdx,r12
    1f2e:	mov    QWORD PTR [rsp+0x8],rdx
    1f33:	mov    rcx,r15
    1f36:	mov    QWORD PTR [rsp+0x10],rcx
    1f3b:	mov    QWORD PTR [rsp+0x18],rax
    1f40:	mov    r14,rax
    1f43:	mov    rax,rdx
    1f46:	jmp    1e4c <botlish_fn_22+0x4c>
    1f4b:	mov    rdx,r14
    1f4e:	mov    rsi,r15
    1f51:	mov    rdi,r13
    1f54:	call   1f59 <botlish_fn_22+0x159>
			1f55: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1f59:	test   rax,rax
    1f5c:	jne    1f87 <botlish_fn_22+0x187>
    1f62:	xor    rax,rax
    1f65:	mov    rbx,QWORD PTR [rsp+0x30]
    1f6a:	mov    r12,QWORD PTR [rsp+0x38]
    1f6f:	mov    r13,QWORD PTR [rsp+0x40]
    1f74:	mov    r14,QWORD PTR [rsp+0x48]
    1f79:	mov    r15,QWORD PTR [rsp+0x50]
    1f7e:	add    rsp,0x60
    1f82:	mov    rsp,rbp
    1f85:	pop    rbp
    1f86:	ret
    1f87:	mov    rbx,QWORD PTR [rsp+0x30]
    1f8c:	mov    r12,QWORD PTR [rsp+0x38]
    1f91:	mov    r13,QWORD PTR [rsp+0x40]
    1f96:	mov    r14,QWORD PTR [rsp+0x48]
    1f9b:	mov    r15,QWORD PTR [rsp+0x50]
    1fa0:	add    rsp,0x60
    1fa4:	mov    rsp,rbp
    1fa7:	pop    rbp
    1fa8:	ret
    1fa9:	add    BYTE PTR [rax],al
    1fab:	add    BYTE PTR [rax],al
    1fad:	add    BYTE PTR [rax],al
    1faf:	add    BYTE PTR [rsi],al
    1fb1:	add    BYTE PTR [rax],al
    1fb3:	add    BYTE PTR [rax],al
    1fb5:	add    BYTE PTR [rax],al
	...

0000000000001fb8 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    1fb8:	push   rbp
    1fb9:	mov    rbp,rsp
    1fbc:	mov    rsi,QWORD PTR [rdx]
    1fbf:	mov    r9,QWORD PTR [rdx+0x8]
    1fc3:	mov    rcx,QWORD PTR [rdx+0x10]
    1fc7:	mov    r8,QWORD PTR [rdx+0x18]
    1fcb:	mov    rdx,r9
    1fce:	call   1fd3 <botlish_entry_22+0x1b>
			1fcf: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    1fd3:	mov    rsp,rbp
    1fd6:	pop    rbp
    1fd7:	ret

0000000000001fd8 <botlish_fn_23: csv_parse<str>>:
    1fd8:	push   rbp
    1fd9:	mov    rbp,rsp
    1fdc:	sub    rsp,0x40
    1fe0:	mov    QWORD PTR [rsp+0x20],rbx
    1fe5:	mov    QWORD PTR [rsp+0x28],r12
    1fea:	mov    QWORD PTR [rsp+0x30],r13
    1fef:	mov    rbx,rdi
    1ff2:	mov    QWORD PTR [rsp+0x8],0x0
    1ffb:	mov    QWORD PTR [rsp+0x10],0x0
    2004:	mov    QWORD PTR [rsp+0x18],0x0
    200d:	mov    QWORD PTR [rsp],rsi
    2011:	mov    rax,QWORD PTR [rsi+0x8]
    2015:	mov    r12,rsi
    2018:	shl    rax,1
    201b:	or     rax,0x1
    201f:	sar    rax,1
    2022:	test   rax,rax
    2025:	je     20b4 <botlish_fn_23+0xdc>
    202b:	mov    edx,0x1
    2030:	mov    QWORD PTR [rsp+0x8],0x1
    2039:	mov    rsi,r12
    203c:	mov    rdi,rbx
    203f:	call   2044 <botlish_fn_23+0x6c>
			2040: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    2044:	test   rax,rax
    2047:	je     20cb <botlish_fn_23+0xf3>
    204d:	mov    QWORD PTR [rsp+0x8],rax
    2052:	mov    rsi,rax
    2055:	mov    QWORD PTR [rsp+0x10],rdx
    205a:	mov    r13,rdx
    205d:	mov    rdi,rbx
    2060:	call   2065 <botlish_fn_23+0x8d>
			2061: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    2065:	test   rax,rax
    2068:	je     20cb <botlish_fn_23+0xf3>
    206e:	mov    QWORD PTR [rsp+0x8],rax
    2073:	mov    rcx,rax
    2076:	mov    r8d,0x3
    207c:	mov    QWORD PTR [rsp+0x18],0x3
    2085:	mov    rdx,r13
    2088:	mov    rsi,r12
    208b:	mov    rdi,rbx
    208e:	call   2093 <botlish_fn_23+0xbb>
			208f: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    2093:	test   rax,rax
    2096:	je     20cb <botlish_fn_23+0xf3>
    209c:	mov    rbx,QWORD PTR [rsp+0x20]
    20a1:	mov    r12,QWORD PTR [rsp+0x28]
    20a6:	mov    r13,QWORD PTR [rsp+0x30]
    20ab:	add    rsp,0x40
    20af:	mov    rsp,rbp
    20b2:	pop    rbp
    20b3:	ret
    20b4:	xor    rdx,rdx
    20b7:	mov    rdi,rbx
    20ba:	mov    rsi,rdx
    20bd:	call   20c2 <botlish_fn_23+0xea>
			20be: R_X86_64_PLT32	rt_list_new-0x4
    20c2:	test   rax,rax
    20c5:	jne    20e6 <botlish_fn_23+0x10e>
    20cb:	xor    rax,rax
    20ce:	mov    rbx,QWORD PTR [rsp+0x20]
    20d3:	mov    r12,QWORD PTR [rsp+0x28]
    20d8:	mov    r13,QWORD PTR [rsp+0x30]
    20dd:	add    rsp,0x40
    20e1:	mov    rsp,rbp
    20e4:	pop    rbp
    20e5:	ret
    20e6:	mov    rbx,QWORD PTR [rsp+0x20]
    20eb:	mov    r12,QWORD PTR [rsp+0x28]
    20f0:	mov    r13,QWORD PTR [rsp+0x30]
    20f5:	add    rsp,0x40
    20f9:	mov    rsp,rbp
    20fc:	pop    rbp
    20fd:	ret

00000000000020fe <botlish_entry_23: csv_parse<str>>:
    20fe:	push   rbp
    20ff:	mov    rbp,rsp
    2102:	mov    rsi,QWORD PTR [rdx]
    2105:	call   210a <botlish_entry_23+0xc>
			2106: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    210a:	mov    rsp,rbp
    210d:	pop    rbp
    210e:	ret
	...

0000000000002110 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    2110:	push   rbp
    2111:	mov    rbp,rsp
    2114:	sub    rsp,0x40
    2118:	mov    QWORD PTR [rsp+0x20],rbx
    211d:	mov    QWORD PTR [rsp+0x28],r12
    2122:	mov    QWORD PTR [rsp+0x30],r13
    2127:	mov    QWORD PTR [rsp+0x38],r14
    212c:	mov    r13,rdi
    212f:	mov    QWORD PTR [rsp],rsi
    2133:	mov    rbx,rsi
    2136:	mov    QWORD PTR [rsp+0x8],rdx
    213b:	mov    QWORD PTR [rsp+0x10],rcx
    2140:	mov    r12,rcx
    2143:	mov    rsi,rdx
    2146:	mov    rax,rsi
    2149:	and    rax,r12
    214c:	mov    r14,rsi
    214f:	test   rax,0x1
    2155:	jne    217e <botlish_fn_24+0x6e>
    215b:	mov    rdx,r12
    215e:	mov    rsi,r14
    2161:	mov    rdi,r13
    2164:	call   2169 <botlish_fn_24+0x59>
			2165: R_X86_64_PLT32	rt_int_cmp-0x4
    2169:	mov    ecx,0x2
    216e:	test   rax,rax
    2171:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2258 <botlish_fn_24+0x148>
    2179:	jmp    2191 <botlish_fn_24+0x81>
    217e:	mov    ecx,0x2
    2183:	mov    rsi,r14
    2186:	cmp    rsi,r12
    2189:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2258 <botlish_fn_24+0x148>
    2191:	cmp    rcx,0x6
    2195:	je     2236 <botlish_fn_24+0x126>
    219b:	mov    ecx,0x1
    21a0:	mov    rdx,r14
    21a3:	mov    rsi,rbx
    21a6:	mov    rdi,r13
    21a9:	call   21ae <botlish_fn_24+0x9e>
			21aa: R_X86_64_PLT32	rt_mutarray_set-0x4
    21ae:	test   rax,rax
    21b1:	jne    21d7 <botlish_fn_24+0xc7>
    21b7:	xor    rax,rax
    21ba:	mov    rbx,QWORD PTR [rsp+0x20]
    21bf:	mov    r12,QWORD PTR [rsp+0x28]
    21c4:	mov    r13,QWORD PTR [rsp+0x30]
    21c9:	mov    r14,QWORD PTR [rsp+0x38]
    21ce:	add    rsp,0x40
    21d2:	mov    rsp,rbp
    21d5:	pop    rbp
    21d6:	ret
    21d7:	mov    QWORD PTR [rsp+0x18],0x3
    21e0:	mov    rsi,r14
    21e3:	test   rsi,0x1
    21ea:	je     220d <botlish_fn_24+0xfd>
    21f0:	mov    rsi,r14
    21f3:	mov    rcx,rsi
    21f6:	add    rcx,0x2
    21fa:	seto   al
    21fd:	test   al,al
    21ff:	jne    220d <botlish_fn_24+0xfd>
    2205:	mov    r14,rcx
    2208:	jmp    2220 <botlish_fn_24+0x110>
    220d:	mov    edx,0x3
    2212:	mov    rsi,r14
    2215:	mov    rdi,r13
    2218:	call   221d <botlish_fn_24+0x10d>
			2219: R_X86_64_PLT32	rt_int_add-0x4
    221d:	mov    r14,rax
    2220:	mov    QWORD PTR [rsp],rbx
    2224:	mov    rsi,r14
    2227:	mov    QWORD PTR [rsp+0x8],rsi
    222c:	mov    QWORD PTR [rsp+0x10],r12
    2231:	jmp    2146 <botlish_fn_24+0x36>
    2236:	mov    eax,0xa
    223b:	mov    rbx,QWORD PTR [rsp+0x20]
    2240:	mov    r12,QWORD PTR [rsp+0x28]
    2245:	mov    r13,QWORD PTR [rsp+0x30]
    224a:	mov    r14,QWORD PTR [rsp+0x38]
    224f:	add    rsp,0x40
    2253:	mov    rsp,rbp
    2256:	pop    rbp
    2257:	ret
    2258:	(bad)
    2259:	add    BYTE PTR [rax],al
    225b:	add    BYTE PTR [rax],al
    225d:	add    BYTE PTR [rax],al
	...

0000000000002260 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    2260:	push   rbp
    2261:	mov    rbp,rsp
    2264:	mov    rsi,QWORD PTR [rdx]
    2267:	mov    r8,QWORD PTR [rdx+0x8]
    226b:	mov    rcx,QWORD PTR [rdx+0x10]
    226f:	mov    rdx,r8
    2272:	call   2277 <botlish_entry_24+0x17>
			2273: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    2277:	mov    rsp,rbp
    227a:	pop    rbp
    227b:	ret

000000000000227c <botlish_fn_25: ht_alloc<int>>:
    227c:	push   rbp
    227d:	mov    rbp,rsp
    2280:	sub    rsp,0x60
    2284:	mov    QWORD PTR [rsp+0x30],rbx
    2289:	mov    QWORD PTR [rsp+0x38],r12
    228e:	mov    QWORD PTR [rsp+0x40],r13
    2293:	mov    QWORD PTR [rsp+0x48],r14
    2298:	mov    QWORD PTR [rsp+0x50],r15
    229d:	mov    r12,rdi
    22a0:	mov    QWORD PTR [rsp+0x8],0x0
    22a9:	mov    QWORD PTR [rsp+0x10],0x0
    22b2:	mov    QWORD PTR [rsp+0x18],0x0
    22bb:	mov    QWORD PTR [rsp],rsi
    22bf:	mov    rbx,rsi
    22c2:	mov    rsi,rbx
    22c5:	mov    rdi,r12
    22c8:	call   22cd <botlish_fn_25+0x51>
			22c9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22cd:	test   rax,rax
    22d0:	je     235e <botlish_fn_25+0xe2>
    22d6:	mov    QWORD PTR [rsp+0x8],rax
    22db:	mov    r13,rax
    22de:	mov    edx,0x1
    22e3:	mov    QWORD PTR [rsp+0x10],0x1
    22ec:	mov    rcx,rbx
    22ef:	mov    rsi,r13
    22f2:	mov    rdi,r12
    22f5:	call   22fa <botlish_fn_25+0x7e>
			22f6: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    22fa:	test   rax,rax
    22fd:	je     235e <botlish_fn_25+0xe2>
    2303:	mov    rsi,rbx
    2306:	mov    rdi,r12
    2309:	call   230e <botlish_fn_25+0x92>
			230a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    230e:	test   rax,rax
    2311:	je     235e <botlish_fn_25+0xe2>
    2317:	mov    QWORD PTR [rsp+0x10],rax
    231c:	mov    rsi,rbx
    231f:	mov    r14,rax
    2322:	mov    rdi,r12
    2325:	call   232a <botlish_fn_25+0xae>
			2326: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    232a:	test   rax,rax
    232d:	je     235e <botlish_fn_25+0xe2>
    2333:	mov    QWORD PTR [rsp],rax
    2337:	mov    r15,rax
    233a:	mov    esi,0xb
    233f:	mov    QWORD PTR [rsp+0x18],0xb
    2348:	mov    rdi,r12
    234b:	call   2350 <botlish_fn_25+0xd4>
			234c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2350:	test   rax,rax
    2353:	mov    QWORD PTR [rsp+0x20],rax
    2358:	jne    2383 <botlish_fn_25+0x107>
    235e:	xor    rax,rax
    2361:	mov    rbx,QWORD PTR [rsp+0x30]
    2366:	mov    r12,QWORD PTR [rsp+0x38]
    236b:	mov    r13,QWORD PTR [rsp+0x40]
    2370:	mov    r14,QWORD PTR [rsp+0x48]
    2375:	mov    r15,QWORD PTR [rsp+0x50]
    237a:	add    rsp,0x60
    237e:	mov    rsp,rbp
    2381:	pop    rbp
    2382:	ret
    2383:	mov    ebx,0x1
    2388:	mov    rcx,r13
    238b:	mov    rdx,rbx
    238e:	mov    rsi,QWORD PTR [rsp+0x20]
    2393:	mov    rdi,r12
    2396:	call   239b <botlish_fn_25+0x11f>
			2397: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    239b:	mov    edx,0x3
    23a0:	mov    rcx,r14
    23a3:	mov    rsi,QWORD PTR [rsp+0x20]
    23a8:	mov    rdi,r12
    23ab:	call   23b0 <botlish_fn_25+0x134>
			23ac: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23b0:	mov    edx,0x5
    23b5:	mov    rcx,r15
    23b8:	mov    rsi,QWORD PTR [rsp+0x20]
    23bd:	mov    rdi,r12
    23c0:	call   23c5 <botlish_fn_25+0x149>
			23c1: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23c5:	mov    edx,0x7
    23ca:	mov    rcx,rbx
    23cd:	mov    rsi,QWORD PTR [rsp+0x20]
    23d2:	mov    rdi,r12
    23d5:	call   23da <botlish_fn_25+0x15e>
			23d6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23da:	mov    edx,0x9
    23df:	mov    rcx,rbx
    23e2:	mov    rdi,r12
    23e5:	mov    rsi,QWORD PTR [rsp+0x20]
    23ea:	call   23ef <botlish_fn_25+0x173>
			23eb: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23ef:	mov    rax,QWORD PTR [rsp+0x20]
    23f4:	mov    rbx,QWORD PTR [rsp+0x30]
    23f9:	mov    r12,QWORD PTR [rsp+0x38]
    23fe:	mov    r13,QWORD PTR [rsp+0x40]
    2403:	mov    r14,QWORD PTR [rsp+0x48]
    2408:	mov    r15,QWORD PTR [rsp+0x50]
    240d:	add    rsp,0x60
    2411:	mov    rsp,rbp
    2414:	pop    rbp
    2415:	ret

0000000000002416 <botlish_entry_25: ht_alloc<int>>:
    2416:	push   rbp
    2417:	mov    rbp,rsp
    241a:	mov    rsi,QWORD PTR [rdx]
    241d:	call   2422 <botlish_entry_25+0xc>
			241e: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2422:	mov    rsp,rbp
    2425:	pop    rbp
    2426:	ret

0000000000002427 <botlish_fn_26: ht_new<generic>>:
    2427:	push   rbp
    2428:	mov    rbp,rsp
    242b:	sub    rsp,0x10
    242f:	mov    esi,0x11
    2434:	mov    QWORD PTR [rsp],0x11
    243c:	call   2441 <botlish_fn_26+0x1a>
			243d: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2441:	test   rax,rax
    2444:	jne    2456 <botlish_fn_26+0x2f>
    244a:	xor    rax,rax
    244d:	add    rsp,0x10
    2451:	mov    rsp,rbp
    2454:	pop    rbp
    2455:	ret
    2456:	add    rsp,0x10
    245a:	mov    rsp,rbp
    245d:	pop    rbp
    245e:	ret

000000000000245f <botlish_entry_26: ht_new<generic>>:
    245f:	push   rbp
    2460:	mov    rbp,rsp
    2463:	call   2468 <botlish_entry_26+0x9>
			2464: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    2468:	mov    rsp,rbp
    246b:	pop    rbp
    246c:	ret
    246d:	add    BYTE PTR [rax],al
	...

0000000000002470 <botlish_fn_27: ht_capacity_for<int, int>>:
    2470:	push   rbp
    2471:	mov    rbp,rsp
    2474:	sub    rsp,0x50
    2478:	mov    QWORD PTR [rsp+0x20],rbx
    247d:	mov    QWORD PTR [rsp+0x28],r12
    2482:	mov    QWORD PTR [rsp+0x30],r13
    2487:	mov    QWORD PTR [rsp+0x38],r14
    248c:	mov    QWORD PTR [rsp+0x40],r15
    2491:	mov    r13,rdi
    2494:	mov    QWORD PTR [rsp],rdx
    2498:	mov    rbx,rsi
    249b:	or     rbx,0x1
    249f:	sar    rbx,1
    24a2:	mov    r12,rsi
    24a5:	mov    r14,rdx
    24a8:	mov    rax,r12
    24ab:	or     rax,0x1
    24af:	mov    QWORD PTR [rsp+0x8],rax
    24b4:	mov    QWORD PTR [rsp+0x10],0x7
    24bd:	mov    rax,rbx
    24c0:	imul   QWORD PTR [rip+0x159]        # 2620 <botlish_fn_27+0x1b0>
    24c7:	seto   cl
    24ca:	or     rax,0x1
    24ce:	test   cl,cl
    24d0:	jne    24de <botlish_fn_27+0x6e>
    24d6:	mov    rsi,rax
    24d9:	jmp    24f5 <botlish_fn_27+0x85>
    24de:	mov    rsi,r12
    24e1:	or     rsi,0x1
    24e5:	mov    edx,0x7
    24ea:	mov    rdi,r13
    24ed:	call   24f2 <botlish_fn_27+0x82>
			24ee: R_X86_64_PLT32	rt_int_mul-0x4
    24f2:	mov    rsi,rax
    24f5:	mov    QWORD PTR [rsp+0x8],rsi
    24fa:	mov    r15,rsi
    24fd:	mov    QWORD PTR [rsp+0x10],0x5
    2506:	mov    rsi,r14
    2509:	test   rsi,0x1
    2510:	je     2540 <botlish_fn_27+0xd0>
    2516:	mov    rsi,r14
    2519:	mov    rax,rsi
    251c:	sar    rax,1
    251f:	imul   QWORD PTR [rip+0x102]        # 2628 <botlish_fn_27+0x1b8>
    2526:	seto   cl
    2529:	or     rax,0x1
    252d:	test   cl,cl
    252f:	jne    2540 <botlish_fn_27+0xd0>
    2535:	mov    rdx,rax
    2538:	mov    rsi,r15
    253b:	jmp    2556 <botlish_fn_27+0xe6>
    2540:	mov    edx,0x5
    2545:	mov    rsi,r14
    2548:	mov    rdi,r13
    254b:	call   2550 <botlish_fn_27+0xe0>
			254c: R_X86_64_PLT32	rt_int_mul-0x4
    2550:	mov    rdx,rax
    2553:	mov    rsi,r15
    2556:	mov    rax,rsi
    2559:	and    rax,rdx
    255c:	test   rax,0x1
    2562:	jne    2585 <botlish_fn_27+0x115>
    2568:	mov    rdi,r13
    256b:	call   2570 <botlish_fn_27+0x100>
			256c: R_X86_64_PLT32	rt_int_cmp-0x4
    2570:	mov    ecx,0x2
    2575:	test   rax,rax
    2578:	cmovle rcx,QWORD PTR [rip+0xa0]        # 2620 <botlish_fn_27+0x1b0>
    2580:	jmp    2595 <botlish_fn_27+0x125>
    2585:	mov    ecx,0x2
    258a:	cmp    rsi,rdx
    258d:	cmovle rcx,QWORD PTR [rip+0x8b]        # 2620 <botlish_fn_27+0x1b0>
    2595:	cmp    rcx,0x6
    2599:	je     25f5 <botlish_fn_27+0x185>
    259f:	mov    QWORD PTR [rsp+0x8],0x5
    25a8:	mov    rsi,r14
    25ab:	test   rsi,0x1
    25b2:	je     25d9 <botlish_fn_27+0x169>
    25b8:	mov    rsi,r14
    25bb:	mov    rax,rsi
    25be:	sar    rax,1
    25c1:	imul   QWORD PTR [rip+0x60]        # 2628 <botlish_fn_27+0x1b8>
    25c8:	seto   sil
    25cc:	or     rax,0x1
    25d0:	test   sil,sil
    25d3:	je     25e9 <botlish_fn_27+0x179>
    25d9:	mov    edx,0x5
    25de:	mov    rsi,r14
    25e1:	mov    rdi,r13
    25e4:	call   25e9 <botlish_fn_27+0x179>
			25e5: R_X86_64_PLT32	rt_int_mul-0x4
    25e9:	mov    QWORD PTR [rsp],rax
    25ed:	mov    r14,rax
    25f0:	jmp    24a8 <botlish_fn_27+0x38>
    25f5:	mov    rax,r14
    25f8:	mov    rbx,QWORD PTR [rsp+0x20]
    25fd:	mov    r12,QWORD PTR [rsp+0x28]
    2602:	mov    r13,QWORD PTR [rsp+0x30]
    2607:	mov    r14,QWORD PTR [rsp+0x38]
    260c:	mov    r15,QWORD PTR [rsp+0x40]
    2611:	add    rsp,0x50
    2615:	mov    rsp,rbp
    2618:	pop    rbp
    2619:	ret
    261a:	add    BYTE PTR [rax],al
    261c:	add    BYTE PTR [rax],al
    261e:	add    BYTE PTR [rax],al
    2620:	(bad)
    2621:	add    BYTE PTR [rax],al
    2623:	add    BYTE PTR [rax],al
    2625:	add    BYTE PTR [rax],al
    2627:	add    BYTE PTR [rax+rax*1],al
    262a:	add    BYTE PTR [rax],al
    262c:	add    BYTE PTR [rax],al
	...

0000000000002630 <botlish_entry_27: ht_capacity_for<int, int>>:
    2630:	push   rbp
    2631:	mov    rbp,rsp
    2634:	mov    rsi,QWORD PTR [rdx]
    2637:	mov    rdx,QWORD PTR [rdx+0x8]
    263b:	call   2640 <botlish_entry_27+0x10>
			263c: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2640:	mov    rsp,rbp
    2643:	pop    rbp
    2644:	ret

0000000000002645 <botlish_fn_28: ht_new_sized<int>>:
    2645:	push   rbp
    2646:	mov    rbp,rsp
    2649:	sub    rsp,0x20
    264d:	mov    QWORD PTR [rsp+0x10],r12
    2652:	mov    r12,rdi
    2655:	mov    QWORD PTR [rsp],rsi
    2659:	mov    edx,0x11
    265e:	mov    QWORD PTR [rsp+0x8],0x11
    2667:	mov    rdi,r12
    266a:	call   266f <botlish_fn_28+0x2a>
			266b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    266f:	mov    QWORD PTR [rsp],rax
    2673:	mov    rsi,rax
    2676:	mov    rdi,r12
    2679:	call   267e <botlish_fn_28+0x39>
			267a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    267e:	test   rax,rax
    2681:	jne    2698 <botlish_fn_28+0x53>
    2687:	xor    rax,rax
    268a:	mov    r12,QWORD PTR [rsp+0x10]
    268f:	add    rsp,0x20
    2693:	mov    rsp,rbp
    2696:	pop    rbp
    2697:	ret
    2698:	mov    r12,QWORD PTR [rsp+0x10]
    269d:	add    rsp,0x20
    26a1:	mov    rsp,rbp
    26a4:	pop    rbp
    26a5:	ret

00000000000026a6 <botlish_entry_28: ht_new_sized<int>>:
    26a6:	push   rbp
    26a7:	mov    rbp,rsp
    26aa:	mov    rsi,QWORD PTR [rdx]
    26ad:	call   26b2 <botlish_entry_28+0xc>
			26ae: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    26b2:	mov    rsp,rbp
    26b5:	pop    rbp
    26b6:	ret

00000000000026b7 <botlish_fn_29: ht_controls<mutarray>>:
    26b7:	push   rbp
    26b8:	mov    rbp,rsp
    26bb:	mov    edx,0x1
    26c0:	call   26c5 <botlish_fn_29+0xe>
			26c1: R_X86_64_PLT32	rt_mutarray_get-0x4
    26c5:	test   rax,rax
    26c8:	jne    26d6 <botlish_fn_29+0x1f>
    26ce:	xor    rax,rax
    26d1:	mov    rsp,rbp
    26d4:	pop    rbp
    26d5:	ret
    26d6:	mov    rsp,rbp
    26d9:	pop    rbp
    26da:	ret

00000000000026db <botlish_entry_29: ht_controls<mutarray>>:
    26db:	push   rbp
    26dc:	mov    rbp,rsp
    26df:	mov    rsi,QWORD PTR [rdx]
    26e2:	call   26e7 <botlish_entry_29+0xc>
			26e3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    26e7:	mov    rsp,rbp
    26ea:	pop    rbp
    26eb:	ret

00000000000026ec <botlish_fn_30: ht_keys<mutarray>>:
    26ec:	push   rbp
    26ed:	mov    rbp,rsp
    26f0:	mov    edx,0x3
    26f5:	call   26fa <botlish_fn_30+0xe>
			26f6: R_X86_64_PLT32	rt_mutarray_get-0x4
    26fa:	test   rax,rax
    26fd:	jne    270b <botlish_fn_30+0x1f>
    2703:	xor    rax,rax
    2706:	mov    rsp,rbp
    2709:	pop    rbp
    270a:	ret
    270b:	mov    rsp,rbp
    270e:	pop    rbp
    270f:	ret

0000000000002710 <botlish_entry_30: ht_keys<mutarray>>:
    2710:	push   rbp
    2711:	mov    rbp,rsp
    2714:	mov    rsi,QWORD PTR [rdx]
    2717:	call   271c <botlish_entry_30+0xc>
			2718: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    271c:	mov    rsp,rbp
    271f:	pop    rbp
    2720:	ret

0000000000002721 <botlish_fn_31: ht_values<mutarray>>:
    2721:	push   rbp
    2722:	mov    rbp,rsp
    2725:	mov    edx,0x5
    272a:	call   272f <botlish_fn_31+0xe>
			272b: R_X86_64_PLT32	rt_mutarray_get-0x4
    272f:	test   rax,rax
    2732:	jne    2740 <botlish_fn_31+0x1f>
    2738:	xor    rax,rax
    273b:	mov    rsp,rbp
    273e:	pop    rbp
    273f:	ret
    2740:	mov    rsp,rbp
    2743:	pop    rbp
    2744:	ret

0000000000002745 <botlish_entry_31: ht_values<mutarray>>:
    2745:	push   rbp
    2746:	mov    rbp,rsp
    2749:	mov    rsi,QWORD PTR [rdx]
    274c:	call   2751 <botlish_entry_31+0xc>
			274d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    2751:	mov    rsp,rbp
    2754:	pop    rbp
    2755:	ret

0000000000002756 <botlish_fn_32: ht_size<mutarray>>:
    2756:	push   rbp
    2757:	mov    rbp,rsp
    275a:	mov    edx,0x7
    275f:	call   2764 <botlish_fn_32+0xe>
			2760: R_X86_64_PLT32	rt_mutarray_get-0x4
    2764:	test   rax,rax
    2767:	jne    2775 <botlish_fn_32+0x1f>
    276d:	xor    rax,rax
    2770:	mov    rsp,rbp
    2773:	pop    rbp
    2774:	ret
    2775:	mov    rsp,rbp
    2778:	pop    rbp
    2779:	ret

000000000000277a <botlish_entry_32: ht_size<mutarray>>:
    277a:	push   rbp
    277b:	mov    rbp,rsp
    277e:	mov    rsi,QWORD PTR [rdx]
    2781:	call   2786 <botlish_entry_32+0xc>
			2782: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    2786:	mov    rsp,rbp
    2789:	pop    rbp
    278a:	ret

000000000000278b <botlish_fn_33: ht_tombstones<mutarray>>:
    278b:	push   rbp
    278c:	mov    rbp,rsp
    278f:	mov    edx,0x9
    2794:	call   2799 <botlish_fn_33+0xe>
			2795: R_X86_64_PLT32	rt_mutarray_get-0x4
    2799:	test   rax,rax
    279c:	jne    27aa <botlish_fn_33+0x1f>
    27a2:	xor    rax,rax
    27a5:	mov    rsp,rbp
    27a8:	pop    rbp
    27a9:	ret
    27aa:	mov    rsp,rbp
    27ad:	pop    rbp
    27ae:	ret

00000000000027af <botlish_entry_33: ht_tombstones<mutarray>>:
    27af:	push   rbp
    27b0:	mov    rbp,rsp
    27b3:	mov    rsi,QWORD PTR [rdx]
    27b6:	call   27bb <botlish_entry_33+0xc>
			27b7: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    27bb:	mov    rsp,rbp
    27be:	pop    rbp
    27bf:	ret

00000000000027c0 <botlish_fn_34: ht_capacity<mutarray>>:
    27c0:	push   rbp
    27c1:	mov    rbp,rsp
    27c4:	sub    rsp,0x10
    27c8:	mov    QWORD PTR [rsp],rbx
    27cc:	mov    rbx,rdi
    27cf:	mov    rdi,rbx
    27d2:	call   27d7 <botlish_fn_34+0x17>
			27d3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    27d7:	test   rax,rax
    27da:	je     2824 <botlish_fn_34+0x64>
    27e0:	xor    r8d,r8d
    27e3:	test   rax,0x7
    27e9:	je     27f7 <botlish_fn_34+0x37>
    27ef:	mov    rsi,rax
    27f2:	jmp    2806 <botlish_fn_34+0x46>
    27f7:	movzx  rcx,BYTE PTR [rax]
    27fb:	mov    rsi,rax
    27fe:	rex cmp cl,0x8
    2802:	sete   r8b
    2806:	test   r8b,r8b
    2809:	jne    2834 <botlish_fn_34+0x74>
    280f:	mov    rdi,rbx
    2812:	mov    rax,QWORD PTR [rdi+0x10]
    2816:	mov    rcx,QWORD PTR [rax+0x28]
    281a:	mov    edx,0x8
    281f:	call   2824 <botlish_fn_34+0x64>
			2820: R_X86_64_PLT32	rt_type_error-0x4
    2824:	xor    rax,rax
    2827:	mov    rbx,QWORD PTR [rsp]
    282b:	add    rsp,0x10
    282f:	mov    rsp,rbp
    2832:	pop    rbp
    2833:	ret
    2834:	mov    rdi,rbx
    2837:	call   283c <botlish_fn_34+0x7c>
			2838: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    283c:	mov    rbx,QWORD PTR [rsp]
    2840:	add    rsp,0x10
    2844:	mov    rsp,rbp
    2847:	pop    rbp
    2848:	ret

0000000000002849 <botlish_entry_34: ht_capacity<mutarray>>:
    2849:	push   rbp
    284a:	mov    rbp,rsp
    284d:	mov    rsi,QWORD PTR [rdx]
    2850:	call   2855 <botlish_entry_34+0xc>
			2851: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2855:	mov    rsp,rbp
    2858:	pop    rbp
    2859:	ret

000000000000285a <botlish_fn_35: ht_probe_start<mutarray, str>>:
    285a:	push   rbp
    285b:	mov    rbp,rsp
    285e:	sub    rsp,0x20
    2862:	mov    QWORD PTR [rsp],r12
    2866:	mov    QWORD PTR [rsp+0x8],r13
    286b:	mov    QWORD PTR [rsp+0x10],r14
    2870:	mov    r12,rdi
    2873:	mov    r14,rsi
    2876:	mov    rsi,rdx
    2879:	mov    rdi,r12
    287c:	call   2881 <botlish_fn_35+0x27>
			287d: R_X86_64_PLT32	rt_hash-0x4
    2881:	test   rax,rax
    2884:	mov    r13,rax
    2887:	je     28b8 <botlish_fn_35+0x5e>
    288d:	mov    rsi,r14
    2890:	mov    rdi,r12
    2893:	call   2898 <botlish_fn_35+0x3e>
			2894: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2898:	test   rax,rax
    289b:	mov    rdx,rax
    289e:	je     28b8 <botlish_fn_35+0x5e>
    28a4:	mov    rsi,r13
    28a7:	mov    rdi,r12
    28aa:	call   28af <botlish_fn_35+0x55>
			28ab: R_X86_64_PLT32	rt_int_mod-0x4
    28af:	test   rax,rax
    28b2:	jne    28d2 <botlish_fn_35+0x78>
    28b8:	xor    rax,rax
    28bb:	mov    r12,QWORD PTR [rsp]
    28bf:	mov    r13,QWORD PTR [rsp+0x8]
    28c4:	mov    r14,QWORD PTR [rsp+0x10]
    28c9:	add    rsp,0x20
    28cd:	mov    rsp,rbp
    28d0:	pop    rbp
    28d1:	ret
    28d2:	mov    r12,QWORD PTR [rsp]
    28d6:	mov    r13,QWORD PTR [rsp+0x8]
    28db:	mov    r14,QWORD PTR [rsp+0x10]
    28e0:	add    rsp,0x20
    28e4:	mov    rsp,rbp
    28e7:	pop    rbp
    28e8:	ret

00000000000028e9 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    28e9:	push   rbp
    28ea:	mov    rbp,rsp
    28ed:	mov    rsi,QWORD PTR [rdx]
    28f0:	mov    rdx,QWORD PTR [rdx+0x8]
    28f4:	call   28f9 <botlish_entry_35+0x10>
			28f5: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    28f9:	mov    rsp,rbp
    28fc:	pop    rbp
    28fd:	ret

00000000000028fe <botlish_fn_36: ht_probe_next<mutarray, int>>:
    28fe:	push   rbp
    28ff:	mov    rbp,rsp
    2902:	sub    rsp,0x40
    2906:	mov    QWORD PTR [rsp+0x20],rbx
    290b:	mov    QWORD PTR [rsp+0x28],r12
    2910:	mov    QWORD PTR [rsp+0x30],r13
    2915:	mov    r13,rdi
    2918:	mov    QWORD PTR [rsp],rsi
    291c:	mov    rbx,rsi
    291f:	mov    QWORD PTR [rsp+0x8],rdx
    2924:	mov    QWORD PTR [rsp+0x10],0x3
    292d:	test   rdx,0x1
    2934:	jne    2942 <botlish_fn_36+0x44>
    293a:	mov    rsi,rdx
    293d:	jmp    2962 <botlish_fn_36+0x64>
    2942:	mov    rsi,rdx
    2945:	add    rsi,0x2
    2949:	mov    r12,rsi
    294c:	mov    rsi,rdx
    294f:	seto   al
    2952:	test   al,al
    2954:	jne    2962 <botlish_fn_36+0x64>
    295a:	mov    rsi,rbx
    295d:	jmp    2975 <botlish_fn_36+0x77>
    2962:	mov    edx,0x3
    2967:	mov    rdi,r13
    296a:	call   296f <botlish_fn_36+0x71>
			296b: R_X86_64_PLT32	rt_int_add-0x4
    296f:	mov    rsi,rbx
    2972:	mov    r12,rax
    2975:	mov    rdi,r13
    2978:	call   297d <botlish_fn_36+0x7f>
			2979: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    297d:	test   rax,rax
    2980:	mov    rdx,rax
    2983:	je     299d <botlish_fn_36+0x9f>
    2989:	mov    rsi,r12
    298c:	mov    rdi,r13
    298f:	call   2994 <botlish_fn_36+0x96>
			2990: R_X86_64_PLT32	rt_int_mod-0x4
    2994:	test   rax,rax
    2997:	jne    29b8 <botlish_fn_36+0xba>
    299d:	xor    rax,rax
    29a0:	mov    rbx,QWORD PTR [rsp+0x20]
    29a5:	mov    r12,QWORD PTR [rsp+0x28]
    29aa:	mov    r13,QWORD PTR [rsp+0x30]
    29af:	add    rsp,0x40
    29b3:	mov    rsp,rbp
    29b6:	pop    rbp
    29b7:	ret
    29b8:	mov    rbx,QWORD PTR [rsp+0x20]
    29bd:	mov    r12,QWORD PTR [rsp+0x28]
    29c2:	mov    r13,QWORD PTR [rsp+0x30]
    29c7:	add    rsp,0x40
    29cb:	mov    rsp,rbp
    29ce:	pop    rbp
    29cf:	ret

00000000000029d0 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    29d0:	push   rbp
    29d1:	mov    rbp,rsp
    29d4:	mov    rsi,QWORD PTR [rdx]
    29d7:	mov    rdx,QWORD PTR [rdx+0x8]
    29db:	call   29e0 <botlish_entry_36+0x10>
			29dc: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    29e0:	mov    rsp,rbp
    29e3:	pop    rbp
    29e4:	ret
    29e5:	add    BYTE PTR [rax],al
	...

00000000000029e8 <botlish_fn_37: ht_find_get<mutarray, str, int>>:
    29e8:	push   rbp
    29e9:	mov    rbp,rsp
    29ec:	sub    rsp,0x50
    29f0:	mov    QWORD PTR [rsp+0x20],rbx
    29f5:	mov    QWORD PTR [rsp+0x28],r12
    29fa:	mov    QWORD PTR [rsp+0x30],r13
    29ff:	mov    QWORD PTR [rsp+0x38],r14
    2a04:	mov    QWORD PTR [rsp+0x40],r15
    2a09:	mov    r14,rdi
    2a0c:	mov    QWORD PTR [rsp],rsi
    2a10:	mov    QWORD PTR [rsp+0x8],rdx
    2a15:	mov    r13,rdx
    2a18:	mov    QWORD PTR [rsp+0x10],rcx
    2a1d:	mov    r12,rsi
    2a20:	mov    r15,rcx
    2a23:	mov    rsi,r12
    2a26:	mov    rdi,r14
    2a29:	call   2a2e <botlish_fn_37+0x46>
			2a2a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2a2e:	test   rax,rax
    2a31:	je     2c30 <botlish_fn_37+0x248>
    2a37:	xor    ecx,ecx
    2a39:	test   rax,0x7
    2a3f:	je     2a4d <botlish_fn_37+0x65>
    2a45:	mov    rsi,rax
    2a48:	jmp    2a5b <botlish_fn_37+0x73>
    2a4d:	movzx  rcx,BYTE PTR [rax]
    2a51:	mov    rsi,rax
    2a54:	rex cmp cl,0x8
    2a58:	sete   cl
    2a5b:	test   cl,cl
    2a5d:	jne    2a7d <botlish_fn_37+0x95>
    2a63:	mov    rdi,r14
    2a66:	mov    rdx,QWORD PTR [rdi+0x10]
    2a6a:	mov    rcx,QWORD PTR [rdx+0x30]
    2a6e:	mov    edx,0x8
    2a73:	call   2a78 <botlish_fn_37+0x90>
			2a74: R_X86_64_PLT32	rt_type_error-0x4
    2a78:	jmp    2c30 <botlish_fn_37+0x248>
    2a7d:	mov    rdx,r15
    2a80:	mov    rdi,r14
    2a83:	call   2a88 <botlish_fn_37+0xa0>
			2a84: R_X86_64_PLT32	rt_mutarray_get-0x4
    2a88:	mov    rcx,rax
    2a8b:	mov    QWORD PTR [rsp+0x18],rax
    2a90:	test   rax,rcx
    2a93:	je     2c30 <botlish_fn_37+0x248>
    2a99:	mov    rax,QWORD PTR [rsp+0x18]
    2a9e:	test   rax,0x1
    2aa4:	jne    2acf <botlish_fn_37+0xe7>
    2aaa:	mov    edx,0x1
    2aaf:	mov    rsi,QWORD PTR [rsp+0x18]
    2ab4:	mov    rdi,r14
    2ab7:	call   2abc <botlish_fn_37+0xd4>
			2ab8: R_X86_64_PLT32	rt_value_eq-0x4
    2abc:	test   rax,rax
    2abf:	je     2c30 <botlish_fn_37+0x248>
    2ac5:	mov    rcx,QWORD PTR [rsp+0x18]
    2aca:	jmp    2ae5 <botlish_fn_37+0xfd>
    2acf:	mov    eax,0x2
    2ad4:	mov    rcx,QWORD PTR [rsp+0x18]
    2ad9:	cmp    rcx,0x1
    2add:	cmove  rax,QWORD PTR [rip+0x1db]        # 2cc0 <botlish_fn_37+0x2d8>
    2ae5:	mov    ebx,0x6
    2aea:	cmp    rax,0x6
    2aee:	je     2c90 <botlish_fn_37+0x2a8>
    2af4:	test   rcx,0x1
    2afb:	mov    QWORD PTR [rsp+0x18],rcx
    2b00:	jne    2b26 <botlish_fn_37+0x13e>
    2b06:	mov    edx,0x3
    2b0b:	mov    rsi,QWORD PTR [rsp+0x18]
    2b10:	mov    rdi,r14
    2b13:	call   2b18 <botlish_fn_37+0x130>
			2b14: R_X86_64_PLT32	rt_value_eq-0x4
    2b18:	test   rax,rax
    2b1b:	je     2c30 <botlish_fn_37+0x248>
    2b21:	jmp    2b3c <botlish_fn_37+0x154>
    2b26:	mov    rsi,QWORD PTR [rsp+0x18]
    2b2b:	mov    eax,0x2
    2b30:	cmp    rsi,0x3
    2b34:	cmove  rax,QWORD PTR [rip+0x184]        # 2cc0 <botlish_fn_37+0x2d8>
    2b3c:	cmp    rax,0x6
    2b40:	je     2b50 <botlish_fn_37+0x168>
    2b46:	mov    ebx,0x2
    2b4b:	jmp    2c0f <botlish_fn_37+0x227>
    2b50:	mov    rsi,r12
    2b53:	mov    rdi,r14
    2b56:	call   2b5b <botlish_fn_37+0x173>
			2b57: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2b5b:	test   rax,rax
    2b5e:	je     2c30 <botlish_fn_37+0x248>
    2b64:	xor    r10d,r10d
    2b67:	test   rax,0x7
    2b6d:	je     2b7b <botlish_fn_37+0x193>
    2b73:	mov    rsi,rax
    2b76:	jmp    2b8a <botlish_fn_37+0x1a2>
    2b7b:	movzx  rcx,BYTE PTR [rax]
    2b7f:	mov    rsi,rax
    2b82:	rex cmp cl,0x8
    2b86:	sete   r10b
    2b8a:	test   r10b,r10b
    2b8d:	jne    2bad <botlish_fn_37+0x1c5>
    2b93:	mov    rdi,r14
    2b96:	mov    rax,QWORD PTR [rdi+0x10]
    2b9a:	mov    rcx,QWORD PTR [rax+0x30]
    2b9e:	mov    edx,0x8
    2ba3:	call   2ba8 <botlish_fn_37+0x1c0>
			2ba4: R_X86_64_PLT32	rt_type_error-0x4
    2ba8:	jmp    2c30 <botlish_fn_37+0x248>
    2bad:	mov    rdx,r15
    2bb0:	mov    rdi,r14
    2bb3:	call   2bb8 <botlish_fn_37+0x1d0>
			2bb4: R_X86_64_PLT32	rt_mutarray_get-0x4
    2bb8:	test   rax,rax
    2bbb:	je     2c30 <botlish_fn_37+0x248>
    2bc1:	mov    rcx,rax
    2bc4:	and    rcx,r13
    2bc7:	mov    rsi,rax
    2bca:	test   rcx,0x1
    2bd1:	jne    2bf0 <botlish_fn_37+0x208>
    2bd7:	mov    rdx,r13
    2bda:	mov    rdi,r14
    2bdd:	call   2be2 <botlish_fn_37+0x1fa>
			2bde: R_X86_64_PLT32	rt_value_eq-0x4
    2be2:	test   rax,rax
    2be5:	je     2c30 <botlish_fn_37+0x248>
    2beb:	jmp    2c00 <botlish_fn_37+0x218>
    2bf0:	mov    eax,0x2
    2bf5:	cmp    rsi,r13
    2bf8:	cmove  rax,QWORD PTR [rip+0xc0]        # 2cc0 <botlish_fn_37+0x2d8>
    2c00:	cmp    rax,0x6
    2c04:	je     2c0f <botlish_fn_37+0x227>
    2c0a:	mov    ebx,0x2
    2c0f:	cmp    rbx,0x6
    2c13:	je     2c6b <botlish_fn_37+0x283>
    2c19:	mov    rdx,r15
    2c1c:	mov    rsi,r12
    2c1f:	mov    rdi,r14
    2c22:	call   2c27 <botlish_fn_37+0x23f>
			2c23: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2c27:	test   rax,rax
    2c2a:	jne    2c55 <botlish_fn_37+0x26d>
    2c30:	xor    rax,rax
    2c33:	mov    rbx,QWORD PTR [rsp+0x20]
    2c38:	mov    r12,QWORD PTR [rsp+0x28]
    2c3d:	mov    r13,QWORD PTR [rsp+0x30]
    2c42:	mov    r14,QWORD PTR [rsp+0x38]
    2c47:	mov    r15,QWORD PTR [rsp+0x40]
    2c4c:	add    rsp,0x50
    2c50:	mov    rsp,rbp
    2c53:	pop    rbp
    2c54:	ret
    2c55:	mov    QWORD PTR [rsp],r12
    2c59:	mov    QWORD PTR [rsp+0x8],r13
    2c5e:	mov    QWORD PTR [rsp+0x10],rax
    2c63:	mov    r15,rax
    2c66:	jmp    2a23 <botlish_fn_37+0x3b>
    2c6b:	mov    rax,r15
    2c6e:	mov    rbx,QWORD PTR [rsp+0x20]
    2c73:	mov    r12,QWORD PTR [rsp+0x28]
    2c78:	mov    r13,QWORD PTR [rsp+0x30]
    2c7d:	mov    r14,QWORD PTR [rsp+0x38]
    2c82:	mov    r15,QWORD PTR [rsp+0x40]
    2c87:	add    rsp,0x50
    2c8b:	mov    rsp,rbp
    2c8e:	pop    rbp
    2c8f:	ret
    2c90:	mov    rax,0xffffffffffffffff
    2c97:	mov    rbx,QWORD PTR [rsp+0x20]
    2c9c:	mov    r12,QWORD PTR [rsp+0x28]
    2ca1:	mov    r13,QWORD PTR [rsp+0x30]
    2ca6:	mov    r14,QWORD PTR [rsp+0x38]
    2cab:	mov    r15,QWORD PTR [rsp+0x40]
    2cb0:	add    rsp,0x50
    2cb4:	mov    rsp,rbp
    2cb7:	pop    rbp
    2cb8:	ret
    2cb9:	add    BYTE PTR [rax],al
    2cbb:	add    BYTE PTR [rax],al
    2cbd:	add    BYTE PTR [rax],al
    2cbf:	add    BYTE PTR [rsi],al
    2cc1:	add    BYTE PTR [rax],al
    2cc3:	add    BYTE PTR [rax],al
    2cc5:	add    BYTE PTR [rax],al
	...

0000000000002cc8 <botlish_entry_37: ht_find_get<mutarray, str, int>>:
    2cc8:	push   rbp
    2cc9:	mov    rbp,rsp
    2ccc:	mov    rsi,QWORD PTR [rdx]
    2ccf:	mov    r8,QWORD PTR [rdx+0x8]
    2cd3:	mov    rcx,QWORD PTR [rdx+0x10]
    2cd7:	mov    rdx,r8
    2cda:	call   2cdf <botlish_entry_37+0x17>
			2cdb: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    2cdf:	mov    rsp,rbp
    2ce2:	pop    rbp
    2ce3:	ret
    2ce4:	add    BYTE PTR [rax],al
	...

0000000000002ce8 <botlish_fn_38: ht_find_insert<mutarray, str, int, int>>:
    2ce8:	push   rbp
    2ce9:	mov    rbp,rsp
    2cec:	sub    rsp,0x60
    2cf0:	mov    QWORD PTR [rsp+0x30],rbx
    2cf5:	mov    QWORD PTR [rsp+0x38],r12
    2cfa:	mov    QWORD PTR [rsp+0x40],r13
    2cff:	mov    QWORD PTR [rsp+0x48],r14
    2d04:	mov    QWORD PTR [rsp+0x50],r15
    2d09:	mov    r15,rdi
    2d0c:	mov    QWORD PTR [rsp],rsi
    2d10:	mov    QWORD PTR [rsp+0x8],rdx
    2d15:	mov    r13,rdx
    2d18:	mov    QWORD PTR [rsp+0x10],rcx
    2d1d:	mov    QWORD PTR [rsp+0x18],r8
    2d22:	mov    rbx,rsi
    2d25:	mov    QWORD PTR [rsp+0x20],rcx
    2d2a:	mov    QWORD PTR [rsp+0x28],r8
    2d2f:	mov    rsi,rbx
    2d32:	mov    rdi,r15
    2d35:	call   2d3a <botlish_fn_38+0x52>
			2d36: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2d3a:	test   rax,rax
    2d3d:	je     3035 <botlish_fn_38+0x34d>
    2d43:	xor    ecx,ecx
    2d45:	test   rax,0x7
    2d4b:	je     2d59 <botlish_fn_38+0x71>
    2d51:	mov    rsi,rax
    2d54:	jmp    2d67 <botlish_fn_38+0x7f>
    2d59:	movzx  rcx,BYTE PTR [rax]
    2d5d:	mov    rsi,rax
    2d60:	rex cmp cl,0x8
    2d64:	sete   cl
    2d67:	test   cl,cl
    2d69:	jne    2d89 <botlish_fn_38+0xa1>
    2d6f:	mov    rdi,r15
    2d72:	mov    rax,QWORD PTR [rdi+0x10]
    2d76:	mov    rcx,QWORD PTR [rax+0x30]
    2d7a:	mov    edx,0x8
    2d7f:	call   2d84 <botlish_fn_38+0x9c>
			2d80: R_X86_64_PLT32	rt_type_error-0x4
    2d84:	jmp    3035 <botlish_fn_38+0x34d>
    2d89:	mov    rdx,QWORD PTR [rsp+0x20]
    2d8e:	mov    rdi,r15
    2d91:	call   2d96 <botlish_fn_38+0xae>
			2d92: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d96:	mov    rsi,rax
    2d99:	mov    r14,rax
    2d9c:	test   rax,rsi
    2d9f:	je     3035 <botlish_fn_38+0x34d>
    2da5:	mov    rax,r14
    2da8:	test   rax,0x1
    2dae:	jne    2dd2 <botlish_fn_38+0xea>
    2db4:	mov    edx,0x1
    2db9:	mov    rsi,r14
    2dbc:	mov    rdi,r15
    2dbf:	call   2dc4 <botlish_fn_38+0xdc>
			2dc0: R_X86_64_PLT32	rt_value_eq-0x4
    2dc4:	test   rax,rax
    2dc7:	je     3035 <botlish_fn_38+0x34d>
    2dcd:	jmp    2de6 <botlish_fn_38+0xfe>
    2dd2:	mov    eax,0x2
    2dd7:	mov    rcx,r14
    2dda:	cmp    rcx,0x1
    2dde:	cmove  rax,QWORD PTR [rip+0x372]        # 3158 <botlish_fn_38+0x470>
    2de6:	mov    r12d,0x6
    2dec:	cmp    rax,0x6
    2df0:	je     30ad <botlish_fn_38+0x3c5>
    2df6:	mov    rax,r14
    2df9:	test   rax,0x1
    2dff:	jne    2e23 <botlish_fn_38+0x13b>
    2e05:	mov    edx,0x3
    2e0a:	mov    rsi,r14
    2e0d:	mov    rdi,r15
    2e10:	call   2e15 <botlish_fn_38+0x12d>
			2e11: R_X86_64_PLT32	rt_value_eq-0x4
    2e15:	test   rax,rax
    2e18:	je     3035 <botlish_fn_38+0x34d>
    2e1e:	jmp    2e37 <botlish_fn_38+0x14f>
    2e23:	mov    eax,0x2
    2e28:	mov    rcx,r14
    2e2b:	cmp    rcx,0x3
    2e2f:	cmove  rax,QWORD PTR [rip+0x321]        # 3158 <botlish_fn_38+0x470>
    2e37:	cmp    rax,0x6
    2e3b:	je     2e4c <botlish_fn_38+0x164>
    2e41:	mov    r11d,0x2
    2e47:	jmp    2f16 <botlish_fn_38+0x22e>
    2e4c:	mov    rsi,rbx
    2e4f:	mov    rdi,r15
    2e52:	call   2e57 <botlish_fn_38+0x16f>
			2e53: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2e57:	test   rax,rax
    2e5a:	je     3035 <botlish_fn_38+0x34d>
    2e60:	xor    ecx,ecx
    2e62:	test   rax,0x7
    2e68:	je     2e76 <botlish_fn_38+0x18e>
    2e6e:	mov    rsi,rax
    2e71:	jmp    2e84 <botlish_fn_38+0x19c>
    2e76:	movzx  rcx,BYTE PTR [rax]
    2e7a:	mov    rsi,rax
    2e7d:	rex cmp cl,0x8
    2e81:	sete   cl
    2e84:	test   cl,cl
    2e86:	jne    2ea6 <botlish_fn_38+0x1be>
    2e8c:	mov    rdi,r15
    2e8f:	mov    rcx,QWORD PTR [rdi+0x10]
    2e93:	mov    rcx,QWORD PTR [rcx+0x30]
    2e97:	mov    edx,0x8
    2e9c:	call   2ea1 <botlish_fn_38+0x1b9>
			2e9d: R_X86_64_PLT32	rt_type_error-0x4
    2ea1:	jmp    3035 <botlish_fn_38+0x34d>
    2ea6:	mov    rdx,QWORD PTR [rsp+0x20]
    2eab:	mov    rdi,r15
    2eae:	call   2eb3 <botlish_fn_38+0x1cb>
			2eaf: R_X86_64_PLT32	rt_mutarray_get-0x4
    2eb3:	test   rax,rax
    2eb6:	je     3035 <botlish_fn_38+0x34d>
    2ebc:	mov    rsi,rax
    2ebf:	and    rsi,r13
    2ec2:	test   rsi,0x1
    2ec9:	jne    2eeb <botlish_fn_38+0x203>
    2ecf:	mov    rsi,rax
    2ed2:	mov    rdx,r13
    2ed5:	mov    rdi,r15
    2ed8:	call   2edd <botlish_fn_38+0x1f5>
			2ed9: R_X86_64_PLT32	rt_value_eq-0x4
    2edd:	test   rax,rax
    2ee0:	je     3035 <botlish_fn_38+0x34d>
    2ee6:	jmp    2efe <botlish_fn_38+0x216>
    2eeb:	mov    rsi,rax
    2eee:	mov    eax,0x2
    2ef3:	cmp    rsi,r13
    2ef6:	cmove  rax,QWORD PTR [rip+0x25a]        # 3158 <botlish_fn_38+0x470>
    2efe:	cmp    rax,0x6
    2f02:	je     2f13 <botlish_fn_38+0x22b>
    2f08:	mov    r11d,0x2
    2f0e:	jmp    2f16 <botlish_fn_38+0x22e>
    2f13:	mov    r11,r12
    2f16:	cmp    r11,0x6
    2f1a:	je     3086 <botlish_fn_38+0x39e>
    2f20:	mov    rax,r14
    2f23:	test   rax,0x1
    2f29:	jne    2f4d <botlish_fn_38+0x265>
    2f2f:	mov    edx,0x5
    2f34:	mov    rsi,r14
    2f37:	mov    rdi,r15
    2f3a:	call   2f3f <botlish_fn_38+0x257>
			2f3b: R_X86_64_PLT32	rt_value_eq-0x4
    2f3f:	test   rax,rax
    2f42:	je     3035 <botlish_fn_38+0x34d>
    2f48:	jmp    2f61 <botlish_fn_38+0x279>
    2f4d:	mov    rsi,r14
    2f50:	mov    eax,0x2
    2f55:	cmp    rsi,0x5
    2f59:	cmove  rax,QWORD PTR [rip+0x1f7]        # 3158 <botlish_fn_38+0x470>
    2f61:	cmp    rax,0x6
    2f65:	je     2f76 <botlish_fn_38+0x28e>
    2f6b:	mov    r12d,0x2
    2f71:	jmp    2fd7 <botlish_fn_38+0x2ef>
    2f76:	mov    r14,QWORD PTR [rsp+0x28]
    2f7b:	test   r14,0x1
    2f82:	jne    2fb2 <botlish_fn_38+0x2ca>
    2f88:	mov    edx,0x1
    2f8d:	mov    rsi,r14
    2f90:	mov    rdi,r15
    2f93:	call   2f98 <botlish_fn_38+0x2b0>
			2f94: R_X86_64_PLT32	rt_int_cmp-0x4
    2f98:	mov    ecx,0x2
    2f9d:	test   rax,rax
    2fa0:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 3158 <botlish_fn_38+0x470>
    2fa8:	mov    QWORD PTR [rsp+0x28],r14
    2fad:	jmp    2fc7 <botlish_fn_38+0x2df>
    2fb2:	mov    ecx,0x2
    2fb7:	test   r14,r14
    2fba:	mov    QWORD PTR [rsp+0x28],r14
    2fbf:	cmovle rcx,QWORD PTR [rip+0x191]        # 3158 <botlish_fn_38+0x470>
    2fc7:	cmp    rcx,0x6
    2fcb:	je     2fd7 <botlish_fn_38+0x2ef>
    2fd1:	mov    r12d,0x2
    2fd7:	cmp    r12,0x6
    2fdb:	je     301c <botlish_fn_38+0x334>
    2fe1:	mov    rdx,QWORD PTR [rsp+0x20]
    2fe6:	mov    rsi,rbx
    2fe9:	mov    rdi,r15
    2fec:	call   2ff1 <botlish_fn_38+0x309>
			2fed: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2ff1:	test   rax,rax
    2ff4:	je     3035 <botlish_fn_38+0x34d>
    2ffa:	mov    QWORD PTR [rsp],rbx
    2ffe:	mov    QWORD PTR [rsp+0x8],r13
    3003:	mov    QWORD PTR [rsp+0x10],rax
    3008:	mov    r11,QWORD PTR [rsp+0x28]
    300d:	mov    QWORD PTR [rsp+0x18],r11
    3012:	mov    QWORD PTR [rsp+0x20],rax
    3017:	jmp    2d2f <botlish_fn_38+0x47>
    301c:	mov    rdx,QWORD PTR [rsp+0x20]
    3021:	mov    rsi,rbx
    3024:	mov    rdi,r15
    3027:	call   302c <botlish_fn_38+0x344>
			3028: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    302c:	test   rax,rax
    302f:	jne    305a <botlish_fn_38+0x372>
    3035:	xor    rax,rax
    3038:	mov    rbx,QWORD PTR [rsp+0x30]
    303d:	mov    r12,QWORD PTR [rsp+0x38]
    3042:	mov    r13,QWORD PTR [rsp+0x40]
    3047:	mov    r14,QWORD PTR [rsp+0x48]
    304c:	mov    r15,QWORD PTR [rsp+0x50]
    3051:	add    rsp,0x60
    3055:	mov    rsp,rbp
    3058:	pop    rbp
    3059:	ret
    305a:	mov    QWORD PTR [rsp],rbx
    305e:	mov    QWORD PTR [rsp+0x8],r13
    3063:	mov    QWORD PTR [rsp+0x10],rax
    3068:	mov    rdx,QWORD PTR [rsp+0x20]
    306d:	mov    QWORD PTR [rsp+0x18],rdx
    3072:	mov    rcx,QWORD PTR [rsp+0x20]
    3077:	mov    QWORD PTR [rsp+0x28],rcx
    307c:	mov    QWORD PTR [rsp+0x20],rax
    3081:	jmp    2d2f <botlish_fn_38+0x47>
    3086:	mov    rax,QWORD PTR [rsp+0x20]
    308b:	mov    rbx,QWORD PTR [rsp+0x30]
    3090:	mov    r12,QWORD PTR [rsp+0x38]
    3095:	mov    r13,QWORD PTR [rsp+0x40]
    309a:	mov    r14,QWORD PTR [rsp+0x48]
    309f:	mov    r15,QWORD PTR [rsp+0x50]
    30a4:	add    rsp,0x60
    30a8:	mov    rsp,rbp
    30ab:	pop    rbp
    30ac:	ret
    30ad:	mov    rax,QWORD PTR [rsp+0x28]
    30b2:	test   rax,0x1
    30b8:	jne    30e5 <botlish_fn_38+0x3fd>
    30be:	mov    edx,0x1
    30c3:	mov    rdi,r15
    30c6:	mov    rsi,QWORD PTR [rsp+0x28]
    30cb:	call   30d0 <botlish_fn_38+0x3e8>
			30cc: R_X86_64_PLT32	rt_int_cmp-0x4
    30d0:	mov    ecx,0x2
    30d5:	test   rax,rax
    30d8:	cmovge rcx,QWORD PTR [rip+0x78]        # 3158 <botlish_fn_38+0x470>
    30e0:	jmp    30ff <botlish_fn_38+0x417>
    30e5:	mov    ecx,0x2
    30ea:	mov    rax,QWORD PTR [rsp+0x28]
    30ef:	mov    rdx,QWORD PTR [rsp+0x28]
    30f4:	test   rax,rdx
    30f7:	cmovg  rcx,QWORD PTR [rip+0x59]        # 3158 <botlish_fn_38+0x470>
    30ff:	cmp    rcx,0x6
    3103:	je     3130 <botlish_fn_38+0x448>
    3109:	mov    rax,QWORD PTR [rsp+0x20]
    310e:	mov    rbx,QWORD PTR [rsp+0x30]
    3113:	mov    r12,QWORD PTR [rsp+0x38]
    3118:	mov    r13,QWORD PTR [rsp+0x40]
    311d:	mov    r14,QWORD PTR [rsp+0x48]
    3122:	mov    r15,QWORD PTR [rsp+0x50]
    3127:	add    rsp,0x60
    312b:	mov    rsp,rbp
    312e:	pop    rbp
    312f:	ret
    3130:	mov    rax,QWORD PTR [rsp+0x28]
    3135:	mov    rbx,QWORD PTR [rsp+0x30]
    313a:	mov    r12,QWORD PTR [rsp+0x38]
    313f:	mov    r13,QWORD PTR [rsp+0x40]
    3144:	mov    r14,QWORD PTR [rsp+0x48]
    3149:	mov    r15,QWORD PTR [rsp+0x50]
    314e:	add    rsp,0x60
    3152:	mov    rsp,rbp
    3155:	pop    rbp
    3156:	ret
    3157:	add    BYTE PTR [rsi],al
    3159:	add    BYTE PTR [rax],al
    315b:	add    BYTE PTR [rax],al
    315d:	add    BYTE PTR [rax],al
	...

0000000000003160 <botlish_entry_38: ht_find_insert<mutarray, str, int, int>>:
    3160:	push   rbp
    3161:	mov    rbp,rsp
    3164:	mov    rsi,QWORD PTR [rdx]
    3167:	mov    r9,QWORD PTR [rdx+0x8]
    316b:	mov    rcx,QWORD PTR [rdx+0x10]
    316f:	mov    r8,QWORD PTR [rdx+0x18]
    3173:	mov    rdx,r9
    3176:	call   317b <botlish_entry_38+0x1b>
			3177: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    317b:	mov    rsp,rbp
    317e:	pop    rbp
    317f:	ret

0000000000003180 <botlish_fn_39: ht_get<mutarray, str>>:
    3180:	push   rbp
    3181:	mov    rbp,rsp
    3184:	sub    rsp,0x40
    3188:	mov    QWORD PTR [rsp+0x20],rbx
    318d:	mov    QWORD PTR [rsp+0x28],r12
    3192:	mov    QWORD PTR [rsp+0x30],r13
    3197:	mov    rbx,rdi
    319a:	mov    QWORD PTR [rsp],rsi
    319e:	mov    r13,rsi
    31a1:	mov    QWORD PTR [rsp+0x8],rdx
    31a6:	mov    r12,rdx
    31a9:	mov    rdx,r12
    31ac:	mov    rsi,r13
    31af:	mov    rdi,rbx
    31b2:	call   31b7 <botlish_fn_39+0x37>
			31b3: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    31b7:	test   rax,rax
    31ba:	je     32a4 <botlish_fn_39+0x124>
    31c0:	mov    QWORD PTR [rsp+0x10],rax
    31c5:	mov    rcx,rax
    31c8:	mov    rdx,r12
    31cb:	mov    rsi,r13
    31ce:	mov    rdi,rbx
    31d1:	call   31d6 <botlish_fn_39+0x56>
			31d2: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    31d6:	mov    rcx,rax
    31d9:	mov    r12,rax
    31dc:	test   rax,rcx
    31df:	je     32a4 <botlish_fn_39+0x124>
    31e5:	mov    rax,r12
    31e8:	test   rax,0x1
    31ee:	jne    3219 <botlish_fn_39+0x99>
    31f4:	mov    edx,0x1
    31f9:	mov    rsi,r12
    31fc:	mov    rdi,rbx
    31ff:	call   3204 <botlish_fn_39+0x84>
			3200: R_X86_64_PLT32	rt_int_cmp-0x4
    3204:	mov    ecx,0x2
    3209:	test   rax,rax
    320c:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 32f8 <botlish_fn_39+0x178>
    3214:	jmp    322c <botlish_fn_39+0xac>
    3219:	mov    ecx,0x2
    321e:	mov    rax,r12
    3221:	test   rax,rax
    3224:	cmovle rcx,QWORD PTR [rip+0xcc]        # 32f8 <botlish_fn_39+0x178>
    322c:	cmp    rcx,0x6
    3230:	je     32d7 <botlish_fn_39+0x157>
    3236:	mov    rsi,r13
    3239:	mov    rdi,rbx
    323c:	call   3241 <botlish_fn_39+0xc1>
			323d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3241:	test   rax,rax
    3244:	je     32a4 <botlish_fn_39+0x124>
    324a:	xor    ecx,ecx
    324c:	test   rax,0x7
    3252:	je     3260 <botlish_fn_39+0xe0>
    3258:	mov    rsi,rax
    325b:	jmp    326e <botlish_fn_39+0xee>
    3260:	movzx  rcx,BYTE PTR [rax]
    3264:	mov    rsi,rax
    3267:	rex cmp cl,0x8
    326b:	sete   cl
    326e:	test   cl,cl
    3270:	jne    3290 <botlish_fn_39+0x110>
    3276:	mov    rdi,rbx
    3279:	mov    rax,QWORD PTR [rdi+0x10]
    327d:	mov    rcx,QWORD PTR [rax+0x30]
    3281:	mov    edx,0x8
    3286:	call   328b <botlish_fn_39+0x10b>
			3287: R_X86_64_PLT32	rt_type_error-0x4
    328b:	jmp    32a4 <botlish_fn_39+0x124>
    3290:	mov    rdx,r12
    3293:	mov    rdi,rbx
    3296:	call   329b <botlish_fn_39+0x11b>
			3297: R_X86_64_PLT32	rt_mutarray_get-0x4
    329b:	test   rax,rax
    329e:	jne    32bf <botlish_fn_39+0x13f>
    32a4:	xor    rax,rax
    32a7:	mov    rbx,QWORD PTR [rsp+0x20]
    32ac:	mov    r12,QWORD PTR [rsp+0x28]
    32b1:	mov    r13,QWORD PTR [rsp+0x30]
    32b6:	add    rsp,0x40
    32ba:	mov    rsp,rbp
    32bd:	pop    rbp
    32be:	ret
    32bf:	mov    rbx,QWORD PTR [rsp+0x20]
    32c4:	mov    r12,QWORD PTR [rsp+0x28]
    32c9:	mov    r13,QWORD PTR [rsp+0x30]
    32ce:	add    rsp,0x40
    32d2:	mov    rsp,rbp
    32d5:	pop    rbp
    32d6:	ret
    32d7:	mov    eax,0xa
    32dc:	mov    rbx,QWORD PTR [rsp+0x20]
    32e1:	mov    r12,QWORD PTR [rsp+0x28]
    32e6:	mov    r13,QWORD PTR [rsp+0x30]
    32eb:	add    rsp,0x40
    32ef:	mov    rsp,rbp
    32f2:	pop    rbp
    32f3:	ret
    32f4:	add    BYTE PTR [rax],al
    32f6:	add    BYTE PTR [rax],al
    32f8:	(bad)
    32f9:	add    BYTE PTR [rax],al
    32fb:	add    BYTE PTR [rax],al
    32fd:	add    BYTE PTR [rax],al
	...

0000000000003300 <botlish_entry_39: ht_get<mutarray, str>>:
    3300:	push   rbp
    3301:	mov    rbp,rsp
    3304:	mov    rsi,QWORD PTR [rdx]
    3307:	mov    rdx,QWORD PTR [rdx+0x8]
    330b:	call   3310 <botlish_entry_39+0x10>
			330c: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    3310:	mov    rsp,rbp
    3313:	pop    rbp
    3314:	ret
    3315:	add    BYTE PTR [rax],al
	...

0000000000003318 <botlish_fn_40: ht_rehash_probe<mutarray, int, int>>:
    3318:	push   rbp
    3319:	mov    rbp,rsp
    331c:	sub    rsp,0x40
    3320:	mov    QWORD PTR [rsp+0x20],rbx
    3325:	mov    QWORD PTR [rsp+0x28],r12
    332a:	mov    QWORD PTR [rsp+0x30],r13
    332f:	mov    QWORD PTR [rsp+0x38],r14
    3334:	mov    r13,rdi
    3337:	mov    QWORD PTR [rsp],rsi
    333b:	mov    QWORD PTR [rsp+0x8],rdx
    3340:	mov    QWORD PTR [rsp+0x10],rcx
    3345:	mov    r12,rcx
    3348:	mov    rbx,rsi
    334b:	mov    r14,rdx
    334e:	mov    rdx,r14
    3351:	mov    rsi,rbx
    3354:	mov    rdi,r13
    3357:	call   335c <botlish_fn_40+0x44>
			3358: R_X86_64_PLT32	rt_mutarray_get-0x4
    335c:	test   rax,rax
    335f:	je     33fc <botlish_fn_40+0xe4>
    3365:	test   rax,0x1
    336b:	mov    rsi,rax
    336e:	jne    338f <botlish_fn_40+0x77>
    3374:	mov    edx,0x1
    3379:	mov    rdi,r13
    337c:	call   3381 <botlish_fn_40+0x69>
			337d: R_X86_64_PLT32	rt_value_eq-0x4
    3381:	test   rax,rax
    3384:	je     33fc <botlish_fn_40+0xe4>
    338a:	jmp    33a0 <botlish_fn_40+0x88>
    338f:	mov    eax,0x2
    3394:	cmp    rsi,0x1
    3398:	cmove  rax,QWORD PTR [rip+0xb8]        # 3458 <botlish_fn_40+0x140>
    33a0:	cmp    rax,0x6
    33a4:	je     3432 <botlish_fn_40+0x11a>
    33aa:	mov    QWORD PTR [rsp+0x18],0x3
    33b3:	mov    rsi,r14
    33b6:	test   rsi,0x1
    33bd:	je     33d5 <botlish_fn_40+0xbd>
    33c3:	mov    rsi,r14
    33c6:	add    rsi,0x2
    33ca:	seto   al
    33cd:	test   al,al
    33cf:	je     33e8 <botlish_fn_40+0xd0>
    33d5:	mov    edx,0x3
    33da:	mov    rsi,r14
    33dd:	mov    rdi,r13
    33e0:	call   33e5 <botlish_fn_40+0xcd>
			33e1: R_X86_64_PLT32	rt_int_add-0x4
    33e5:	mov    rsi,rax
    33e8:	mov    rdx,r12
    33eb:	mov    rdi,r13
    33ee:	call   33f3 <botlish_fn_40+0xdb>
			33ef: R_X86_64_PLT32	rt_int_mod-0x4
    33f3:	test   rax,rax
    33f6:	jne    341c <botlish_fn_40+0x104>
    33fc:	xor    rax,rax
    33ff:	mov    rbx,QWORD PTR [rsp+0x20]
    3404:	mov    r12,QWORD PTR [rsp+0x28]
    3409:	mov    r13,QWORD PTR [rsp+0x30]
    340e:	mov    r14,QWORD PTR [rsp+0x38]
    3413:	add    rsp,0x40
    3417:	mov    rsp,rbp
    341a:	pop    rbp
    341b:	ret
    341c:	mov    QWORD PTR [rsp],rbx
    3420:	mov    QWORD PTR [rsp+0x8],rax
    3425:	mov    QWORD PTR [rsp+0x10],r12
    342a:	mov    r14,rax
    342d:	jmp    334e <botlish_fn_40+0x36>
    3432:	mov    rax,r14
    3435:	mov    rbx,QWORD PTR [rsp+0x20]
    343a:	mov    r12,QWORD PTR [rsp+0x28]
    343f:	mov    r13,QWORD PTR [rsp+0x30]
    3444:	mov    r14,QWORD PTR [rsp+0x38]
    3449:	add    rsp,0x40
    344d:	mov    rsp,rbp
    3450:	pop    rbp
    3451:	ret
    3452:	add    BYTE PTR [rax],al
    3454:	add    BYTE PTR [rax],al
    3456:	add    BYTE PTR [rax],al
    3458:	(bad)
    3459:	add    BYTE PTR [rax],al
    345b:	add    BYTE PTR [rax],al
    345d:	add    BYTE PTR [rax],al
	...

0000000000003460 <botlish_entry_40: ht_rehash_probe<mutarray, int, int>>:
    3460:	push   rbp
    3461:	mov    rbp,rsp
    3464:	mov    rsi,QWORD PTR [rdx]
    3467:	mov    r8,QWORD PTR [rdx+0x8]
    346b:	mov    rcx,QWORD PTR [rdx+0x10]
    346f:	mov    rdx,r8
    3472:	call   3477 <botlish_entry_40+0x17>
			3473: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    3477:	mov    rsp,rbp
    347a:	pop    rbp
    347b:	ret

000000000000347c <botlish_fn_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    347c:	push   rbp
    347d:	mov    rbp,rsp
    3480:	sub    rsp,0x80
    3487:	mov    QWORD PTR [rsp+0x50],rbx
    348c:	mov    QWORD PTR [rsp+0x58],r12
    3491:	mov    QWORD PTR [rsp+0x60],r13
    3496:	mov    QWORD PTR [rsp+0x68],r14
    349b:	mov    QWORD PTR [rsp+0x70],r15
    34a0:	mov    r12,rdi
    34a3:	mov    rdi,QWORD PTR [rbp+0x10]
    34a7:	mov    QWORD PTR [rsp],rsi
    34ab:	mov    QWORD PTR [rsp+0x38],rsi
    34b0:	mov    QWORD PTR [rsp+0x8],rdx
    34b5:	mov    r15,rdx
    34b8:	mov    QWORD PTR [rsp+0x10],rcx
    34bd:	mov    rbx,rcx
    34c0:	mov    QWORD PTR [rsp+0x18],r8
    34c5:	mov    QWORD PTR [rsp+0x40],r8
    34ca:	mov    QWORD PTR [rsp+0x20],r9
    34cf:	mov    r14,r9
    34d2:	mov    QWORD PTR [rsp+0x28],rdi
    34d7:	mov    r13,rdi
    34da:	mov    rsi,r14
    34dd:	mov    rdi,r12
    34e0:	call   34e5 <botlish_fn_41+0x69>
			34e1: R_X86_64_PLT32	rt_hash-0x4
    34e5:	test   rax,rax
    34e8:	mov    rsi,rax
    34eb:	je     358a <botlish_fn_41+0x10e>
    34f1:	mov    rdx,QWORD PTR [rsp+0x40]
    34f6:	mov    rdi,r12
    34f9:	call   34fe <botlish_fn_41+0x82>
			34fa: R_X86_64_PLT32	rt_int_mod-0x4
    34fe:	test   rax,rax
    3501:	je     358a <botlish_fn_41+0x10e>
    3507:	mov    QWORD PTR [rsp+0x30],rax
    350c:	mov    rcx,QWORD PTR [rsp+0x40]
    3511:	mov    rdx,rax
    3514:	mov    rsi,QWORD PTR [rsp+0x38]
    3519:	mov    rdi,r12
    351c:	call   3521 <botlish_fn_41+0xa5>
			351d: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    3521:	mov    rcx,rax
    3524:	mov    QWORD PTR [rsp+0x40],rax
    3529:	test   rax,rcx
    352c:	je     358a <botlish_fn_41+0x10e>
    3532:	mov    ecx,0x3
    3537:	mov    rsi,QWORD PTR [rsp+0x38]
    353c:	mov    rdx,QWORD PTR [rsp+0x40]
    3541:	mov    rdi,r12
    3544:	call   3549 <botlish_fn_41+0xcd>
			3545: R_X86_64_PLT32	rt_mutarray_set-0x4
    3549:	test   rax,rax
    354c:	je     358a <botlish_fn_41+0x10e>
    3552:	mov    rcx,r14
    3555:	mov    rsi,r15
    3558:	mov    rdx,QWORD PTR [rsp+0x40]
    355d:	mov    rdi,r12
    3560:	call   3565 <botlish_fn_41+0xe9>
			3561: R_X86_64_PLT32	rt_mutarray_set-0x4
    3565:	test   rax,rax
    3568:	je     358a <botlish_fn_41+0x10e>
    356e:	mov    rcx,r13
    3571:	mov    rdx,QWORD PTR [rsp+0x40]
    3576:	mov    rsi,rbx
    3579:	mov    rdi,r12
    357c:	call   3581 <botlish_fn_41+0x105>
			357d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3581:	test   rax,rax
    3584:	jne    35b2 <botlish_fn_41+0x136>
    358a:	xor    rax,rax
    358d:	mov    rbx,QWORD PTR [rsp+0x50]
    3592:	mov    r12,QWORD PTR [rsp+0x58]
    3597:	mov    r13,QWORD PTR [rsp+0x60]
    359c:	mov    r14,QWORD PTR [rsp+0x68]
    35a1:	mov    r15,QWORD PTR [rsp+0x70]
    35a6:	add    rsp,0x80
    35ad:	mov    rsp,rbp
    35b0:	pop    rbp
    35b1:	ret
    35b2:	mov    eax,0xa
    35b7:	mov    rbx,QWORD PTR [rsp+0x50]
    35bc:	mov    r12,QWORD PTR [rsp+0x58]
    35c1:	mov    r13,QWORD PTR [rsp+0x60]
    35c6:	mov    r14,QWORD PTR [rsp+0x68]
    35cb:	mov    r15,QWORD PTR [rsp+0x70]
    35d0:	add    rsp,0x80
    35d7:	mov    rsp,rbp
    35da:	pop    rbp
    35db:	ret

00000000000035dc <botlish_entry_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    35dc:	push   rbp
    35dd:	mov    rbp,rsp
    35e0:	sub    rsp,0x10
    35e4:	mov    rsi,QWORD PTR [rdx]
    35e7:	mov    r10,QWORD PTR [rdx+0x8]
    35eb:	mov    rcx,QWORD PTR [rdx+0x10]
    35ef:	mov    r8,QWORD PTR [rdx+0x18]
    35f3:	mov    r9,QWORD PTR [rdx+0x20]
    35f7:	mov    r11,QWORD PTR [rdx+0x28]
    35fb:	mov    QWORD PTR [rsp],r11
    35ff:	mov    rdx,r10
    3602:	call   3607 <botlish_entry_41+0x2b>
			3603: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    3607:	add    rsp,0x10
    360b:	mov    rsp,rbp
    360e:	pop    rbp
    360f:	ret

0000000000003610 <botlish_fn_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3610:	push   rbp
    3611:	mov    rbp,rsp
    3614:	sub    rsp,0xc0
    361b:	mov    QWORD PTR [rsp+0x90],rbx
    3623:	mov    QWORD PTR [rsp+0x98],r12
    362b:	mov    QWORD PTR [rsp+0xa0],r13
    3633:	mov    QWORD PTR [rsp+0xa8],r14
    363b:	mov    QWORD PTR [rsp+0xb0],r15
    3643:	mov    QWORD PTR [rsp+0x58],rdi
    3648:	mov    r15,QWORD PTR [rbp+0x10]
    364c:	mov    r12,QWORD PTR [rbp+0x18]
    3650:	mov    r13,QWORD PTR [rbp+0x20]
    3654:	mov    r14,QWORD PTR [rbp+0x28]
    3658:	mov    QWORD PTR [rsp+0x10],rsi
    365d:	mov    QWORD PTR [rsp+0x60],rsi
    3662:	mov    QWORD PTR [rsp+0x18],rdx
    3667:	mov    QWORD PTR [rsp+0x68],rdx
    366c:	mov    QWORD PTR [rsp+0x20],rcx
    3671:	mov    QWORD PTR [rsp+0x70],rcx
    3676:	mov    QWORD PTR [rsp+0x28],r15
    367b:	mov    QWORD PTR [rsp+0x30],r12
    3680:	mov    QWORD PTR [rsp+0x38],r13
    3685:	mov    QWORD PTR [rsp+0x40],r14
    368a:	sar    r8,1
    368d:	sar    r9,1
    3690:	mov    QWORD PTR [rsp+0x88],r9
    3698:	mov    rcx,QWORD PTR [rsp+0x88]
    36a0:	mov    rbx,r8
    36a3:	cmp    rbx,rcx
    36a6:	mov    QWORD PTR [rsp+0x88],rcx
    36ae:	jge    3917 <botlish_fn_42+0x307>
    36b4:	xor    eax,eax
    36b6:	mov    rsi,QWORD PTR [rsp+0x60]
    36bb:	test   rsi,0x7
    36c2:	jne    36d3 <botlish_fn_42+0xc3>
    36c8:	movzx  r10,BYTE PTR [rsi]
    36cc:	cmp    r10b,0x8
    36d0:	sete   al
    36d3:	test   al,al
    36d5:	jne    36f7 <botlish_fn_42+0xe7>
    36db:	mov    rdi,QWORD PTR [rsp+0x58]
    36e0:	mov    rax,QWORD PTR [rdi+0x10]
    36e4:	mov    rcx,QWORD PTR [rax+0x30]
    36e8:	mov    edx,0x8
    36ed:	call   36f2 <botlish_fn_42+0xe2>
			36ee: R_X86_64_PLT32	rt_type_error-0x4
    36f2:	jmp    3895 <botlish_fn_42+0x285>
    36f7:	mov    QWORD PTR [rsp+0x60],rsi
    36fc:	mov    rdx,rbx
    36ff:	shl    rdx,1
    3702:	or     rdx,0x1
    3706:	mov    QWORD PTR [rsp+0x80],rdx
    370e:	mov    rdi,QWORD PTR [rsp+0x58]
    3713:	call   3718 <botlish_fn_42+0x108>
			3714: R_X86_64_PLT32	rt_mutarray_get-0x4
    3718:	test   rax,rax
    371b:	je     3895 <botlish_fn_42+0x285>
    3721:	test   rax,0x1
    3727:	mov    rsi,rax
    372a:	jne    374d <botlish_fn_42+0x13d>
    3730:	mov    edx,0x3
    3735:	mov    rdi,QWORD PTR [rsp+0x58]
    373a:	call   373f <botlish_fn_42+0x12f>
			373b: R_X86_64_PLT32	rt_value_eq-0x4
    373f:	test   rax,rax
    3742:	je     3895 <botlish_fn_42+0x285>
    3748:	jmp    375e <botlish_fn_42+0x14e>
    374d:	mov    eax,0x2
    3752:	cmp    rsi,0x3
    3756:	cmove  rax,QWORD PTR [rip+0x1f2]        # 3950 <botlish_fn_42+0x340>
    375e:	cmp    rax,0x6
    3762:	je     3772 <botlish_fn_42+0x162>
    3768:	mov    rsi,QWORD PTR [rsp+0x60]
    376d:	jmp    38d1 <botlish_fn_42+0x2c1>
    3772:	xor    esi,esi
    3774:	mov    rdx,QWORD PTR [rsp+0x68]
    3779:	test   rdx,0x7
    3780:	je     3790 <botlish_fn_42+0x180>
    3786:	mov    QWORD PTR [rsp+0x68],rdx
    378b:	jmp    379f <botlish_fn_42+0x18f>
    3790:	movzx  rax,BYTE PTR [rdx]
    3794:	mov    QWORD PTR [rsp+0x68],rdx
    3799:	cmp    al,0x8
    379b:	sete   sil
    379f:	test   sil,sil
    37a2:	jne    37c9 <botlish_fn_42+0x1b9>
    37a8:	mov    rdi,QWORD PTR [rsp+0x58]
    37ad:	mov    rax,QWORD PTR [rdi+0x10]
    37b1:	mov    rcx,QWORD PTR [rax+0x30]
    37b5:	mov    edx,0x8
    37ba:	mov    rsi,QWORD PTR [rsp+0x68]
    37bf:	call   37c4 <botlish_fn_42+0x1b4>
			37c0: R_X86_64_PLT32	rt_type_error-0x4
    37c4:	jmp    3895 <botlish_fn_42+0x285>
    37c9:	mov    rdx,QWORD PTR [rsp+0x80]
    37d1:	mov    rsi,QWORD PTR [rsp+0x68]
    37d6:	mov    rdi,QWORD PTR [rsp+0x58]
    37db:	call   37e0 <botlish_fn_42+0x1d0>
			37dc: R_X86_64_PLT32	rt_mutarray_get-0x4
    37e0:	test   rax,rax
    37e3:	je     3895 <botlish_fn_42+0x285>
    37e9:	mov    QWORD PTR [rsp+0x48],rax
    37ee:	mov    QWORD PTR [rsp+0x78],rax
    37f3:	xor    eax,eax
    37f5:	mov    rcx,QWORD PTR [rsp+0x70]
    37fa:	test   rcx,0x7
    3801:	je     3811 <botlish_fn_42+0x201>
    3807:	mov    QWORD PTR [rsp+0x70],rcx
    380c:	jmp    381f <botlish_fn_42+0x20f>
    3811:	movzx  rax,BYTE PTR [rcx]
    3815:	mov    QWORD PTR [rsp+0x70],rcx
    381a:	cmp    al,0x8
    381c:	sete   al
    381f:	test   al,al
    3821:	jne    3848 <botlish_fn_42+0x238>
    3827:	mov    rdi,QWORD PTR [rsp+0x58]
    382c:	mov    rax,QWORD PTR [rdi+0x10]
    3830:	mov    rcx,QWORD PTR [rax+0x30]
    3834:	mov    edx,0x8
    3839:	mov    rsi,QWORD PTR [rsp+0x70]
    383e:	call   3843 <botlish_fn_42+0x233>
			383f: R_X86_64_PLT32	rt_type_error-0x4
    3843:	jmp    3895 <botlish_fn_42+0x285>
    3848:	mov    rdx,QWORD PTR [rsp+0x80]
    3850:	mov    rsi,QWORD PTR [rsp+0x70]
    3855:	mov    rdi,QWORD PTR [rsp+0x58]
    385a:	call   385f <botlish_fn_42+0x24f>
			385b: R_X86_64_PLT32	rt_mutarray_get-0x4
    385f:	test   rax,rax
    3862:	je     3895 <botlish_fn_42+0x285>
    3868:	mov    QWORD PTR [rsp+0x50],rax
    386d:	mov    QWORD PTR [rsp],rax
    3871:	mov    r9,QWORD PTR [rsp+0x78]
    3876:	mov    rcx,r13
    3879:	mov    rdx,r12
    387c:	mov    rsi,r15
    387f:	mov    rdi,QWORD PTR [rsp+0x58]
    3884:	mov    r8,r14
    3887:	call   388c <botlish_fn_42+0x27c>
			3888: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    388c:	test   rax,rax
    388f:	jne    38cc <botlish_fn_42+0x2bc>
    3895:	xor    rax,rax
    3898:	mov    rbx,QWORD PTR [rsp+0x90]
    38a0:	mov    r12,QWORD PTR [rsp+0x98]
    38a8:	mov    r13,QWORD PTR [rsp+0xa0]
    38b0:	mov    r14,QWORD PTR [rsp+0xa8]
    38b8:	mov    r15,QWORD PTR [rsp+0xb0]
    38c0:	add    rsp,0xc0
    38c7:	mov    rsp,rbp
    38ca:	pop    rbp
    38cb:	ret
    38cc:	mov    rsi,QWORD PTR [rsp+0x60]
    38d1:	mov    rsi,QWORD PTR [rsp+0x60]
    38d6:	mov    QWORD PTR [rsp+0x10],rsi
    38db:	mov    rsi,QWORD PTR [rsp+0x68]
    38e0:	mov    QWORD PTR [rsp+0x18],rsi
    38e5:	mov    rsi,QWORD PTR [rsp+0x70]
    38ea:	mov    QWORD PTR [rsp+0x20],rsi
    38ef:	mov    QWORD PTR [rsp+0x28],r15
    38f4:	mov    QWORD PTR [rsp+0x30],r12
    38f9:	mov    QWORD PTR [rsp+0x38],r13
    38fe:	mov    QWORD PTR [rsp+0x40],r14
    3903:	add    rbx,0x1
    390a:	mov    rcx,QWORD PTR [rsp+0x88]
    3912:	jmp    36a3 <botlish_fn_42+0x93>
    3917:	mov    eax,0xa
    391c:	mov    rbx,QWORD PTR [rsp+0x90]
    3924:	mov    r12,QWORD PTR [rsp+0x98]
    392c:	mov    r13,QWORD PTR [rsp+0xa0]
    3934:	mov    r14,QWORD PTR [rsp+0xa8]
    393c:	mov    r15,QWORD PTR [rsp+0xb0]
    3944:	add    rsp,0xc0
    394b:	mov    rsp,rbp
    394e:	pop    rbp
    394f:	ret
    3950:	(bad)
    3951:	add    BYTE PTR [rax],al
    3953:	add    BYTE PTR [rax],al
    3955:	add    BYTE PTR [rax],al
	...

0000000000003958 <botlish_entry_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3958:	push   rbp
    3959:	mov    rbp,rsp
    395c:	sub    rsp,0x30
    3960:	mov    QWORD PTR [rsp+0x20],r12
    3965:	mov    rsi,QWORD PTR [rdx]
    3968:	mov    rax,QWORD PTR [rdx+0x8]
    396c:	mov    rcx,QWORD PTR [rdx+0x10]
    3970:	mov    r8,QWORD PTR [rdx+0x18]
    3974:	mov    r9,QWORD PTR [rdx+0x20]
    3978:	mov    r10,QWORD PTR [rdx+0x28]
    397c:	mov    r11,QWORD PTR [rdx+0x30]
    3980:	mov    r12,QWORD PTR [rdx+0x38]
    3984:	mov    rdx,QWORD PTR [rdx+0x40]
    3988:	mov    QWORD PTR [rsp],r10
    398c:	mov    QWORD PTR [rsp+0x8],r11
    3991:	mov    QWORD PTR [rsp+0x10],r12
    3996:	mov    QWORD PTR [rsp+0x18],rdx
    399b:	mov    rdx,rax
    399e:	call   39a3 <botlish_entry_42+0x4b>
			399f: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    39a3:	mov    r12,QWORD PTR [rsp+0x20]
    39a8:	add    rsp,0x30
    39ac:	mov    rsp,rbp
    39af:	pop    rbp
    39b0:	ret

00000000000039b1 <botlish_fn_43: ht_rehash<mutarray, int>>:
    39b1:	push   rbp
    39b2:	mov    rbp,rsp
    39b5:	sub    rsp,0xd0
    39bc:	mov    QWORD PTR [rsp+0xa0],rbx
    39c4:	mov    QWORD PTR [rsp+0xa8],r12
    39cc:	mov    QWORD PTR [rsp+0xb0],r13
    39d4:	mov    QWORD PTR [rsp+0xb8],r14
    39dc:	mov    QWORD PTR [rsp+0xc0],r15
    39e4:	mov    r13,rdi
    39e7:	mov    QWORD PTR [rsp+0x50],0x0
    39f0:	mov    QWORD PTR [rsp+0x58],0x0
    39f9:	mov    QWORD PTR [rsp+0x60],0x0
    3a02:	mov    QWORD PTR [rsp+0x68],0x0
    3a0b:	mov    QWORD PTR [rsp+0x20],rsi
    3a10:	mov    r12,rsi
    3a13:	mov    QWORD PTR [rsp+0x28],rdx
    3a18:	mov    rbx,rdx
    3a1b:	mov    rsi,r12
    3a1e:	mov    rdi,r13
    3a21:	call   3a26 <botlish_fn_43+0x75>
			3a22: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    3a26:	test   rax,rax
    3a29:	je     3bf8 <botlish_fn_43+0x247>
    3a2f:	mov    QWORD PTR [rsp+0x30],rax
    3a34:	mov    r14,rax
    3a37:	mov    rsi,r12
    3a3a:	mov    rdi,r13
    3a3d:	call   3a42 <botlish_fn_43+0x91>
			3a3e: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3a42:	test   rax,rax
    3a45:	je     3bf8 <botlish_fn_43+0x247>
    3a4b:	mov    QWORD PTR [rsp+0x38],rax
    3a50:	mov    r15,rax
    3a53:	mov    rsi,r12
    3a56:	mov    rdi,r13
    3a59:	call   3a5e <botlish_fn_43+0xad>
			3a5a: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3a5e:	test   rax,rax
    3a61:	je     3bf8 <botlish_fn_43+0x247>
    3a67:	mov    QWORD PTR [rsp+0x40],rax
    3a6c:	mov    QWORD PTR [rsp+0x90],rax
    3a74:	mov    rsi,r12
    3a77:	mov    rdi,r13
    3a7a:	call   3a7f <botlish_fn_43+0xce>
			3a7b: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3a7f:	test   rax,rax
    3a82:	je     3bf8 <botlish_fn_43+0x247>
    3a88:	mov    QWORD PTR [rsp+0x48],rax
    3a8d:	mov    QWORD PTR [rsp+0x88],rax
    3a95:	mov    rsi,rbx
    3a98:	mov    rdi,r13
    3a9b:	call   3aa0 <botlish_fn_43+0xef>
			3a9c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3aa0:	mov    rcx,rax
    3aa3:	mov    QWORD PTR [rsp+0x80],rax
    3aab:	test   rax,rcx
    3aae:	je     3bf8 <botlish_fn_43+0x247>
    3ab4:	mov    rax,QWORD PTR [rsp+0x80]
    3abc:	mov    QWORD PTR [rsp+0x50],rax
    3ac1:	mov    edx,0x1
    3ac6:	mov    QWORD PTR [rsp+0x58],0x1
    3acf:	mov    rcx,rbx
    3ad2:	mov    rsi,QWORD PTR [rsp+0x80]
    3ada:	mov    rdi,r13
    3add:	call   3ae2 <botlish_fn_43+0x131>
			3ade: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3ae2:	test   rax,rax
    3ae5:	je     3bf8 <botlish_fn_43+0x247>
    3aeb:	mov    rsi,rbx
    3aee:	mov    rdi,r13
    3af1:	call   3af6 <botlish_fn_43+0x145>
			3af2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3af6:	test   rax,rax
    3af9:	je     3bf8 <botlish_fn_43+0x247>
    3aff:	mov    QWORD PTR [rsp+0x58],rax
    3b04:	mov    QWORD PTR [rsp+0x78],rax
    3b09:	mov    rsi,rbx
    3b0c:	mov    rdi,r13
    3b0f:	call   3b14 <botlish_fn_43+0x163>
			3b10: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b14:	test   rax,rax
    3b17:	je     3bf8 <botlish_fn_43+0x247>
    3b1d:	mov    QWORD PTR [rsp+0x60],rax
    3b22:	mov    r8d,0x1
    3b28:	mov    QWORD PTR [rsp+0x68],0x1
    3b31:	mov    rcx,QWORD PTR [rsp+0x80]
    3b39:	mov    QWORD PTR [rsp],rcx
    3b3d:	mov    rcx,QWORD PTR [rsp+0x78]
    3b42:	mov    QWORD PTR [rsp+0x8],rcx
    3b47:	mov    QWORD PTR [rsp+0x10],rax
    3b4c:	mov    QWORD PTR [rsp+0x70],rax
    3b51:	mov    QWORD PTR [rsp+0x18],rbx
    3b56:	mov    rcx,QWORD PTR [rsp+0x90]
    3b5e:	mov    rdx,r15
    3b61:	mov    rsi,r14
    3b64:	mov    r9,QWORD PTR [rsp+0x88]
    3b6c:	mov    rdi,r13
    3b6f:	call   3b74 <botlish_fn_43+0x1c3>
			3b70: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3b74:	test   rax,rax
    3b77:	je     3bf8 <botlish_fn_43+0x247>
    3b7d:	mov    edx,0x1
    3b82:	mov    rcx,QWORD PTR [rsp+0x80]
    3b8a:	mov    rsi,r12
    3b8d:	mov    rdi,r13
    3b90:	call   3b95 <botlish_fn_43+0x1e4>
			3b91: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b95:	test   rax,rax
    3b98:	je     3bf8 <botlish_fn_43+0x247>
    3b9e:	mov    edx,0x3
    3ba3:	mov    rcx,QWORD PTR [rsp+0x78]
    3ba8:	mov    rsi,r12
    3bab:	mov    rdi,r13
    3bae:	call   3bb3 <botlish_fn_43+0x202>
			3baf: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bb3:	test   rax,rax
    3bb6:	je     3bf8 <botlish_fn_43+0x247>
    3bbc:	mov    edx,0x5
    3bc1:	mov    rcx,QWORD PTR [rsp+0x70]
    3bc6:	mov    rsi,r12
    3bc9:	mov    rdi,r13
    3bcc:	call   3bd1 <botlish_fn_43+0x220>
			3bcd: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bd1:	test   rax,rax
    3bd4:	je     3bf8 <botlish_fn_43+0x247>
    3bda:	mov    edx,0x9
    3bdf:	mov    ecx,0x1
    3be4:	mov    rsi,r12
    3be7:	mov    rdi,r13
    3bea:	call   3bef <botlish_fn_43+0x23e>
			3beb: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bef:	test   rax,rax
    3bf2:	jne    3c2f <botlish_fn_43+0x27e>
    3bf8:	xor    rax,rax
    3bfb:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c03:	mov    r12,QWORD PTR [rsp+0xa8]
    3c0b:	mov    r13,QWORD PTR [rsp+0xb0]
    3c13:	mov    r14,QWORD PTR [rsp+0xb8]
    3c1b:	mov    r15,QWORD PTR [rsp+0xc0]
    3c23:	add    rsp,0xd0
    3c2a:	mov    rsp,rbp
    3c2d:	pop    rbp
    3c2e:	ret
    3c2f:	mov    eax,0xa
    3c34:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c3c:	mov    r12,QWORD PTR [rsp+0xa8]
    3c44:	mov    r13,QWORD PTR [rsp+0xb0]
    3c4c:	mov    r14,QWORD PTR [rsp+0xb8]
    3c54:	mov    r15,QWORD PTR [rsp+0xc0]
    3c5c:	add    rsp,0xd0
    3c63:	mov    rsp,rbp
    3c66:	pop    rbp
    3c67:	ret

0000000000003c68 <botlish_entry_43: ht_rehash<mutarray, int>>:
    3c68:	push   rbp
    3c69:	mov    rbp,rsp
    3c6c:	mov    rsi,QWORD PTR [rdx]
    3c6f:	mov    rdx,QWORD PTR [rdx+0x8]
    3c73:	call   3c78 <botlish_entry_43+0x10>
			3c74: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3c78:	mov    rsp,rbp
    3c7b:	pop    rbp
    3c7c:	ret
    3c7d:	add    BYTE PTR [rax],al
	...

0000000000003c80 <botlish_fn_44: ht_should_grow<mutarray>>:
    3c80:	push   rbp
    3c81:	mov    rbp,rsp
    3c84:	sub    rsp,0x40
    3c88:	mov    QWORD PTR [rsp+0x20],rbx
    3c8d:	mov    QWORD PTR [rsp+0x28],r12
    3c92:	mov    QWORD PTR [rsp+0x30],r13
    3c97:	mov    rbx,rdi
    3c9a:	mov    QWORD PTR [rsp],rsi
    3c9e:	mov    r12,rsi
    3ca1:	mov    rsi,r12
    3ca4:	mov    rdi,rbx
    3ca7:	call   3cac <botlish_fn_44+0x2c>
			3ca8: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3cac:	mov    rcx,rax
    3caf:	mov    r13,rax
    3cb2:	test   rax,rcx
    3cb5:	je     3ea4 <botlish_fn_44+0x224>
    3cbb:	mov    rax,r13
    3cbe:	mov    QWORD PTR [rsp+0x8],rax
    3cc3:	mov    rsi,r12
    3cc6:	mov    rdi,rbx
    3cc9:	call   3cce <botlish_fn_44+0x4e>
			3cca: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3cce:	mov    rcx,rax
    3cd1:	test   rcx,rcx
    3cd4:	je     3ea4 <botlish_fn_44+0x224>
    3cda:	mov    QWORD PTR [rsp+0x10],rcx
    3cdf:	mov    edx,0x1
    3ce4:	mov    rax,r13
    3ce7:	test   rax,0x1
    3ced:	jne    3d10 <botlish_fn_44+0x90>
    3cf3:	xor    edx,edx
    3cf5:	mov    rax,r13
    3cf8:	test   rax,0x7
    3cfe:	jne    3d10 <botlish_fn_44+0x90>
    3d04:	mov    rax,r13
    3d07:	movzx  rax,BYTE PTR [rax]
    3d0b:	cmp    al,0x1
    3d0d:	sete   dl
    3d10:	test   dl,dl
    3d12:	jne    3d33 <botlish_fn_44+0xb3>
    3d18:	mov    rdi,rbx
    3d1b:	mov    rax,QWORD PTR [rdi+0x10]
    3d1f:	mov    rcx,QWORD PTR [rax+0x38]
    3d23:	xor    rdx,rdx
    3d26:	mov    rsi,r13
    3d29:	call   3d2e <botlish_fn_44+0xae>
			3d2a: R_X86_64_PLT32	rt_type_error-0x4
    3d2e:	jmp    3ea4 <botlish_fn_44+0x224>
    3d33:	mov    eax,0x1
    3d38:	test   rcx,0x1
    3d3f:	je     3d4d <botlish_fn_44+0xcd>
    3d45:	mov    r8,rcx
    3d48:	jmp    3d70 <botlish_fn_44+0xf0>
    3d4d:	xor    eax,eax
    3d4f:	test   rcx,0x7
    3d56:	je     3d64 <botlish_fn_44+0xe4>
    3d5c:	mov    r8,rcx
    3d5f:	jmp    3d70 <botlish_fn_44+0xf0>
    3d64:	movzx  rax,BYTE PTR [rcx]
    3d68:	mov    r8,rcx
    3d6b:	cmp    al,0x1
    3d6d:	sete   al
    3d70:	test   al,al
    3d72:	jne    3d93 <botlish_fn_44+0x113>
    3d78:	mov    rdi,rbx
    3d7b:	mov    rax,QWORD PTR [rdi+0x10]
    3d7f:	mov    rcx,QWORD PTR [rax+0x38]
    3d83:	xor    rdx,rdx
    3d86:	mov    rsi,r8
    3d89:	call   3d8e <botlish_fn_44+0x10e>
			3d8a: R_X86_64_PLT32	rt_type_error-0x4
    3d8e:	jmp    3ea4 <botlish_fn_44+0x224>
    3d93:	mov    rcx,r8
    3d96:	mov    rsi,r13
    3d99:	mov    rax,rsi
    3d9c:	and    rax,rcx
    3d9f:	test   rax,0x1
    3da5:	jne    3db6 <botlish_fn_44+0x136>
    3dab:	mov    rdx,r8
    3dae:	mov    rsi,r13
    3db1:	jmp    3dd4 <botlish_fn_44+0x154>
    3db6:	mov    rcx,r8
    3db9:	lea    rax,[rcx-0x1]
    3dbd:	mov    rsi,r13
    3dc0:	add    rsi,rax
    3dc3:	seto   al
    3dc6:	test   al,al
    3dc8:	je     3ddf <botlish_fn_44+0x15f>
    3dce:	mov    rdx,r8
    3dd1:	mov    rsi,r13
    3dd4:	mov    rdi,rbx
    3dd7:	call   3ddc <botlish_fn_44+0x15c>
			3dd8: R_X86_64_PLT32	rt_int_add-0x4
    3ddc:	mov    rsi,rax
    3ddf:	mov    QWORD PTR [rsp+0x8],rsi
    3de4:	mov    QWORD PTR [rsp+0x10],0x3
    3ded:	test   rsi,0x1
    3df4:	je     3e17 <botlish_fn_44+0x197>
    3dfa:	mov    rax,rsi
    3dfd:	add    rax,0x2
    3e01:	mov    rcx,rax
    3e04:	seto   al
    3e07:	test   al,al
    3e09:	jne    3e17 <botlish_fn_44+0x197>
    3e0f:	mov    rsi,rcx
    3e12:	jmp    3e27 <botlish_fn_44+0x1a7>
    3e17:	mov    edx,0x3
    3e1c:	mov    rdi,rbx
    3e1f:	call   3e24 <botlish_fn_44+0x1a4>
			3e20: R_X86_64_PLT32	rt_int_add-0x4
    3e24:	mov    rsi,rax
    3e27:	mov    QWORD PTR [rsp+0x8],rsi
    3e2c:	mov    edx,0x7
    3e31:	mov    rdi,rdx
    3e34:	mov    QWORD PTR [rsp+0x10],0x7
    3e3d:	test   rsi,0x1
    3e44:	jne    3e52 <botlish_fn_44+0x1d2>
    3e4a:	mov    rdx,rdi
    3e4d:	jmp    3e7e <botlish_fn_44+0x1fe>
    3e52:	mov    rax,rsi
    3e55:	sar    rax,1
    3e58:	imul   QWORD PTR [rip+0x119]        # 3f78 <botlish_fn_44+0x2f8>
    3e5f:	seto   cl
    3e62:	or     rax,0x1
    3e66:	test   cl,cl
    3e68:	je     3e76 <botlish_fn_44+0x1f6>
    3e6e:	mov    rdx,rdi
    3e71:	jmp    3e7e <botlish_fn_44+0x1fe>
    3e76:	mov    rsi,rax
    3e79:	jmp    3e89 <botlish_fn_44+0x209>
    3e7e:	mov    rdi,rbx
    3e81:	call   3e86 <botlish_fn_44+0x206>
			3e82: R_X86_64_PLT32	rt_int_mul-0x4
    3e86:	mov    rsi,rax
    3e89:	mov    QWORD PTR [rsp],rsi
    3e8d:	mov    r13,rsi
    3e90:	mov    rsi,r12
    3e93:	mov    rdi,rbx
    3e96:	call   3e9b <botlish_fn_44+0x21b>
			3e97: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3e9b:	test   rax,rax
    3e9e:	jne    3ebf <botlish_fn_44+0x23f>
    3ea4:	xor    rax,rax
    3ea7:	mov    rbx,QWORD PTR [rsp+0x20]
    3eac:	mov    r12,QWORD PTR [rsp+0x28]
    3eb1:	mov    r13,QWORD PTR [rsp+0x30]
    3eb6:	add    rsp,0x40
    3eba:	mov    rsp,rbp
    3ebd:	pop    rbp
    3ebe:	ret
    3ebf:	mov    QWORD PTR [rsp+0x8],rax
    3ec4:	mov    QWORD PTR [rsp+0x10],0x5
    3ecd:	test   rax,0x1
    3ed3:	mov    rsi,rax
    3ed6:	je     3f08 <botlish_fn_44+0x288>
    3edc:	mov    rcx,rsi
    3edf:	mov    rax,rcx
    3ee2:	sar    rax,1
    3ee5:	imul   QWORD PTR [rip+0x94]        # 3f80 <botlish_fn_44+0x300>
    3eec:	seto   dil
    3ef0:	or     rax,0x1
    3ef4:	test   dil,dil
    3ef7:	jne    3f08 <botlish_fn_44+0x288>
    3efd:	mov    rdx,rax
    3f00:	mov    rsi,r13
    3f03:	jmp    3f1b <botlish_fn_44+0x29b>
    3f08:	mov    edx,0x5
    3f0d:	mov    rdi,rbx
    3f10:	call   3f15 <botlish_fn_44+0x295>
			3f11: R_X86_64_PLT32	rt_int_mul-0x4
    3f15:	mov    rdx,rax
    3f18:	mov    rsi,r13
    3f1b:	mov    r10,rsi
    3f1e:	and    r10,rdx
    3f21:	test   r10,0x1
    3f28:	jne    3f4f <botlish_fn_44+0x2cf>
    3f2e:	mov    rdi,rbx
    3f31:	call   3f36 <botlish_fn_44+0x2b6>
			3f32: R_X86_64_PLT32	rt_int_cmp-0x4
    3f36:	mov    r8d,0x2
    3f3c:	test   rax,rax
    3f3f:	mov    rax,r8
    3f42:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3f78 <botlish_fn_44+0x2f8>
    3f4a:	jmp    3f5f <botlish_fn_44+0x2df>
    3f4f:	mov    eax,0x2
    3f54:	cmp    rsi,rdx
    3f57:	cmovg  rax,QWORD PTR [rip+0x19]        # 3f78 <botlish_fn_44+0x2f8>
    3f5f:	mov    rbx,QWORD PTR [rsp+0x20]
    3f64:	mov    r12,QWORD PTR [rsp+0x28]
    3f69:	mov    r13,QWORD PTR [rsp+0x30]
    3f6e:	add    rsp,0x40
    3f72:	mov    rsp,rbp
    3f75:	pop    rbp
    3f76:	ret
    3f77:	add    BYTE PTR [rsi],al
    3f79:	add    BYTE PTR [rax],al
    3f7b:	add    BYTE PTR [rax],al
    3f7d:	add    BYTE PTR [rax],al
    3f7f:	add    BYTE PTR [rax+rax*1],al
    3f82:	add    BYTE PTR [rax],al
    3f84:	add    BYTE PTR [rax],al
	...

0000000000003f88 <botlish_entry_44: ht_should_grow<mutarray>>:
    3f88:	push   rbp
    3f89:	mov    rbp,rsp
    3f8c:	mov    rsi,QWORD PTR [rdx]
    3f8f:	call   3f94 <botlish_entry_44+0xc>
			3f90: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3f94:	mov    rsp,rbp
    3f97:	pop    rbp
    3f98:	ret
    3f99:	add    BYTE PTR [rax],al
    3f9b:	add    BYTE PTR [rax],al
    3f9d:	add    BYTE PTR [rax],al
	...

0000000000003fa0 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    3fa0:	push   rbp
    3fa1:	mov    rbp,rsp
    3fa4:	sub    rsp,0x40
    3fa8:	mov    QWORD PTR [rsp+0x20],rbx
    3fad:	mov    QWORD PTR [rsp+0x28],r12
    3fb2:	mov    QWORD PTR [rsp+0x30],r13
    3fb7:	mov    rbx,rdi
    3fba:	mov    QWORD PTR [rsp+0x10],0x0
    3fc3:	mov    QWORD PTR [rsp],rsi
    3fc7:	mov    r12,rsi
    3fca:	mov    rsi,r12
    3fcd:	mov    rdi,rbx
    3fd0:	call   3fd5 <botlish_fn_45+0x35>
			3fd1: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3fd5:	test   rax,rax
    3fd8:	mov    r13,rax
    3fdb:	je     41c8 <botlish_fn_45+0x228>
    3fe1:	mov    rsi,r12
    3fe4:	mov    rdi,rbx
    3fe7:	call   3fec <botlish_fn_45+0x4c>
			3fe8: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3fec:	mov    rcx,rax
    3fef:	test   rcx,rcx
    3ff2:	je     41c8 <botlish_fn_45+0x228>
    3ff8:	mov    edx,0x1
    3ffd:	mov    rax,r13
    4000:	test   rax,0x1
    4006:	je     4014 <botlish_fn_45+0x74>
    400c:	mov    r13,rax
    400f:	jmp    4038 <botlish_fn_45+0x98>
    4014:	xor    edx,edx
    4016:	test   rax,0x7
    401c:	je     402a <botlish_fn_45+0x8a>
    4022:	mov    r13,rax
    4025:	jmp    4038 <botlish_fn_45+0x98>
    402a:	movzx  rdx,BYTE PTR [rax]
    402e:	mov    r13,rax
    4031:	rex cmp dl,0x1
    4035:	sete   dl
    4038:	test   dl,dl
    403a:	jne    405b <botlish_fn_45+0xbb>
    4040:	mov    rdi,rbx
    4043:	mov    rsi,QWORD PTR [rdi+0x10]
    4047:	mov    rcx,QWORD PTR [rsi+0x40]
    404b:	xor    rdx,rdx
    404e:	mov    rsi,r13
    4051:	call   4056 <botlish_fn_45+0xb6>
			4052: R_X86_64_PLT32	rt_type_error-0x4
    4056:	jmp    41c8 <botlish_fn_45+0x228>
    405b:	mov    rsi,r13
    405e:	mov    eax,0x1
    4063:	test   rcx,0x1
    406a:	je     4078 <botlish_fn_45+0xd8>
    4070:	mov    r8,rcx
    4073:	jmp    409d <botlish_fn_45+0xfd>
    4078:	xor    eax,eax
    407a:	test   rcx,0x7
    4081:	je     408f <botlish_fn_45+0xef>
    4087:	mov    r8,rcx
    408a:	jmp    409d <botlish_fn_45+0xfd>
    408f:	movzx  r11,BYTE PTR [rcx]
    4093:	mov    r8,rcx
    4096:	cmp    r11b,0x1
    409a:	sete   al
    409d:	test   al,al
    409f:	jne    40c0 <botlish_fn_45+0x120>
    40a5:	mov    rdi,rbx
    40a8:	mov    rax,QWORD PTR [rdi+0x10]
    40ac:	mov    rcx,QWORD PTR [rax+0x40]
    40b0:	xor    rdx,rdx
    40b3:	mov    rsi,r8
    40b6:	call   40bb <botlish_fn_45+0x11b>
			40b7: R_X86_64_PLT32	rt_type_error-0x4
    40bb:	jmp    41c8 <botlish_fn_45+0x228>
    40c0:	mov    rcx,r8
    40c3:	mov    rax,rsi
    40c6:	and    rax,rcx
    40c9:	test   rax,0x1
    40cf:	jne    40f5 <botlish_fn_45+0x155>
    40d5:	mov    rdx,r8
    40d8:	mov    rdi,rbx
    40db:	call   40e0 <botlish_fn_45+0x140>
			40dc: R_X86_64_PLT32	rt_int_cmp-0x4
    40e0:	mov    ecx,0x2
    40e5:	test   rax,rax
    40e8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 4200 <botlish_fn_45+0x260>
    40f0:	jmp    4108 <botlish_fn_45+0x168>
    40f5:	mov    ecx,0x2
    40fa:	mov    r9,r8
    40fd:	cmp    rsi,r9
    4100:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 4200 <botlish_fn_45+0x260>
    4108:	cmp    rcx,0x6
    410c:	je     4198 <botlish_fn_45+0x1f8>
    4112:	mov    rsi,r12
    4115:	mov    rdi,rbx
    4118:	call   411d <botlish_fn_45+0x17d>
			4119: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    411d:	test   rax,rax
    4120:	je     41c8 <botlish_fn_45+0x228>
    4126:	mov    QWORD PTR [rsp+0x8],rax
    412b:	mov    QWORD PTR [rsp+0x10],0x5
    4134:	test   rax,0x1
    413a:	mov    rsi,rax
    413d:	je     416a <botlish_fn_45+0x1ca>
    4143:	mov    rcx,rsi
    4146:	mov    rax,rcx
    4149:	sar    rax,1
    414c:	imul   QWORD PTR [rip+0xb5]        # 4208 <botlish_fn_45+0x268>
    4153:	seto   cl
    4156:	or     rax,0x1
    415a:	test   cl,cl
    415c:	jne    416a <botlish_fn_45+0x1ca>
    4162:	mov    rdx,rax
    4165:	jmp    417a <botlish_fn_45+0x1da>
    416a:	mov    edx,0x5
    416f:	mov    rdi,rbx
    4172:	call   4177 <botlish_fn_45+0x1d7>
			4173: R_X86_64_PLT32	rt_int_mul-0x4
    4177:	mov    rdx,rax
    417a:	mov    QWORD PTR [rsp+0x8],rdx
    417f:	mov    rsi,r12
    4182:	mov    rdi,rbx
    4185:	call   418a <botlish_fn_45+0x1ea>
			4186: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    418a:	test   rax,rax
    418d:	je     41c8 <botlish_fn_45+0x228>
    4193:	jmp    41e3 <botlish_fn_45+0x243>
    4198:	mov    rsi,r12
    419b:	mov    rdi,rbx
    419e:	call   41a3 <botlish_fn_45+0x203>
			419f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    41a3:	test   rax,rax
    41a6:	je     41c8 <botlish_fn_45+0x228>
    41ac:	mov    QWORD PTR [rsp+0x8],rax
    41b1:	mov    rdx,rax
    41b4:	mov    rsi,r12
    41b7:	mov    rdi,rbx
    41ba:	call   41bf <botlish_fn_45+0x21f>
			41bb: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41bf:	test   rax,rax
    41c2:	jne    41e3 <botlish_fn_45+0x243>
    41c8:	xor    rax,rax
    41cb:	mov    rbx,QWORD PTR [rsp+0x20]
    41d0:	mov    r12,QWORD PTR [rsp+0x28]
    41d5:	mov    r13,QWORD PTR [rsp+0x30]
    41da:	add    rsp,0x40
    41de:	mov    rsp,rbp
    41e1:	pop    rbp
    41e2:	ret
    41e3:	mov    rbx,QWORD PTR [rsp+0x20]
    41e8:	mov    r12,QWORD PTR [rsp+0x28]
    41ed:	mov    r13,QWORD PTR [rsp+0x30]
    41f2:	add    rsp,0x40
    41f6:	mov    rsp,rbp
    41f9:	pop    rbp
    41fa:	ret
    41fb:	add    BYTE PTR [rax],al
    41fd:	add    BYTE PTR [rax],al
    41ff:	add    BYTE PTR [rsi],al
    4201:	add    BYTE PTR [rax],al
    4203:	add    BYTE PTR [rax],al
    4205:	add    BYTE PTR [rax],al
    4207:	add    BYTE PTR [rax+rax*1],al
    420a:	add    BYTE PTR [rax],al
    420c:	add    BYTE PTR [rax],al
	...

0000000000004210 <botlish_entry_45: ht_grow_or_clean<mutarray>>:
    4210:	push   rbp
    4211:	mov    rbp,rsp
    4214:	mov    rsi,QWORD PTR [rdx]
    4217:	call   421c <botlish_entry_45+0xc>
			4218: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    421c:	mov    rsp,rbp
    421f:	pop    rbp
    4220:	ret
    4221:	add    BYTE PTR [rax],al
    4223:	add    BYTE PTR [rax],al
    4225:	add    BYTE PTR [rax],al
	...

0000000000004228 <botlish_fn_46: ht_place<mutarray, int, str, str>>:
    4228:	push   rbp
    4229:	mov    rbp,rsp
    422c:	sub    rsp,0x70
    4230:	mov    QWORD PTR [rsp+0x40],rbx
    4235:	mov    QWORD PTR [rsp+0x48],r12
    423a:	mov    QWORD PTR [rsp+0x50],r13
    423f:	mov    QWORD PTR [rsp+0x58],r14
    4244:	mov    QWORD PTR [rsp+0x60],r15
    4249:	mov    rbx,rdi
    424c:	mov    r14,r8
    424f:	mov    r15,rdx
    4252:	mov    QWORD PTR [rsp+0x28],rcx
    4257:	mov    QWORD PTR [rsp],rsi
    425b:	mov    r12,rsi
    425e:	mov    rsi,r12
    4261:	mov    rdi,rbx
    4264:	call   4269 <botlish_fn_46+0x41>
			4265: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    4269:	test   rax,rax
    426c:	je     45d0 <botlish_fn_46+0x3a8>
    4272:	xor    ecx,ecx
    4274:	test   rax,0x7
    427a:	je     428a <botlish_fn_46+0x62>
    4280:	mov    QWORD PTR [rsp+0x30],rax
    4285:	jmp    429a <botlish_fn_46+0x72>
    428a:	movzx  rcx,BYTE PTR [rax]
    428e:	mov    QWORD PTR [rsp+0x30],rax
    4293:	rex cmp cl,0x8
    4297:	sete   cl
    429a:	test   cl,cl
    429c:	jne    42c1 <botlish_fn_46+0x99>
    42a2:	mov    rdi,rbx
    42a5:	mov    rax,QWORD PTR [rdi+0x10]
    42a9:	mov    rcx,QWORD PTR [rax+0x30]
    42ad:	mov    edx,0x8
    42b2:	mov    rsi,QWORD PTR [rsp+0x30]
    42b7:	call   42bc <botlish_fn_46+0x94>
			42b8: R_X86_64_PLT32	rt_type_error-0x4
    42bc:	jmp    45d0 <botlish_fn_46+0x3a8>
    42c1:	mov    rdx,r15
    42c4:	mov    rsi,QWORD PTR [rsp+0x30]
    42c9:	mov    rdi,rbx
    42cc:	call   42d1 <botlish_fn_46+0xa9>
			42cd: R_X86_64_PLT32	rt_mutarray_get-0x4
    42d1:	test   rax,rax
    42d4:	je     45d0 <botlish_fn_46+0x3a8>
    42da:	mov    QWORD PTR [rsp+0x8],rax
    42df:	mov    r13,rax
    42e2:	mov    ecx,0x3
    42e7:	mov    rsi,QWORD PTR [rsp+0x30]
    42ec:	mov    rdx,r15
    42ef:	mov    rdi,rbx
    42f2:	call   42f7 <botlish_fn_46+0xcf>
			42f3: R_X86_64_PLT32	rt_mutarray_set-0x4
    42f7:	test   rax,rax
    42fa:	je     45d0 <botlish_fn_46+0x3a8>
    4300:	mov    rsi,r12
    4303:	mov    rdi,rbx
    4306:	call   430b <botlish_fn_46+0xe3>
			4307: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    430b:	test   rax,rax
    430e:	je     45d0 <botlish_fn_46+0x3a8>
    4314:	xor    ecx,ecx
    4316:	test   rax,0x7
    431c:	je     432a <botlish_fn_46+0x102>
    4322:	mov    rsi,rax
    4325:	jmp    4338 <botlish_fn_46+0x110>
    432a:	movzx  rcx,BYTE PTR [rax]
    432e:	mov    rsi,rax
    4331:	rex cmp cl,0x8
    4335:	sete   cl
    4338:	test   cl,cl
    433a:	jne    4359 <botlish_fn_46+0x131>
    4340:	mov    rdi,rbx
    4343:	mov    rax,QWORD PTR [rdi+0x10]
    4347:	mov    rcx,QWORD PTR [rax]
    434a:	mov    edx,0x8
    434f:	call   4354 <botlish_fn_46+0x12c>
			4350: R_X86_64_PLT32	rt_type_error-0x4
    4354:	jmp    45d0 <botlish_fn_46+0x3a8>
    4359:	mov    rcx,QWORD PTR [rsp+0x28]
    435e:	mov    rdx,r15
    4361:	mov    rdi,rbx
    4364:	call   4369 <botlish_fn_46+0x141>
			4365: R_X86_64_PLT32	rt_mutarray_set-0x4
    4369:	test   rax,rax
    436c:	je     45d0 <botlish_fn_46+0x3a8>
    4372:	mov    rsi,r12
    4375:	mov    rdi,rbx
    4378:	call   437d <botlish_fn_46+0x155>
			4379: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    437d:	test   rax,rax
    4380:	je     45d0 <botlish_fn_46+0x3a8>
    4386:	xor    esi,esi
    4388:	test   rax,0x7
    438e:	jne    43a0 <botlish_fn_46+0x178>
    4394:	movzx  rcx,BYTE PTR [rax]
    4398:	rex cmp cl,0x8
    439c:	sete   sil
    43a0:	test   sil,sil
    43a3:	jne    43c5 <botlish_fn_46+0x19d>
    43a9:	mov    rdi,rbx
    43ac:	mov    rsi,QWORD PTR [rdi+0x10]
    43b0:	mov    rcx,QWORD PTR [rsi]
    43b3:	mov    edx,0x8
    43b8:	mov    rsi,rax
    43bb:	call   43c0 <botlish_fn_46+0x198>
			43bc: R_X86_64_PLT32	rt_type_error-0x4
    43c0:	jmp    45d0 <botlish_fn_46+0x3a8>
    43c5:	mov    rcx,r14
    43c8:	mov    rdx,r15
    43cb:	mov    rsi,rax
    43ce:	mov    rdi,rbx
    43d1:	call   43d6 <botlish_fn_46+0x1ae>
			43d2: R_X86_64_PLT32	rt_mutarray_set-0x4
    43d6:	test   rax,rax
    43d9:	je     45d0 <botlish_fn_46+0x3a8>
    43df:	mov    QWORD PTR [rsp+0x10],0x7
    43e8:	mov    rsi,r12
    43eb:	mov    rdi,rbx
    43ee:	call   43f3 <botlish_fn_46+0x1cb>
			43ef: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    43f3:	test   rax,rax
    43f6:	je     45d0 <botlish_fn_46+0x3a8>
    43fc:	mov    QWORD PTR [rsp+0x18],rax
    4401:	mov    QWORD PTR [rsp+0x20],0x3
    440a:	mov    ecx,0x1
    440f:	test   rax,0x1
    4415:	je     4423 <botlish_fn_46+0x1fb>
    441b:	mov    rsi,rax
    441e:	jmp    4447 <botlish_fn_46+0x21f>
    4423:	xor    ecx,ecx
    4425:	test   rax,0x7
    442b:	je     4439 <botlish_fn_46+0x211>
    4431:	mov    rsi,rax
    4434:	jmp    4447 <botlish_fn_46+0x21f>
    4439:	movzx  rcx,BYTE PTR [rax]
    443d:	mov    rsi,rax
    4440:	rex cmp cl,0x1
    4444:	sete   cl
    4447:	test   cl,cl
    4449:	jne    4467 <botlish_fn_46+0x23f>
    444f:	mov    rdi,rbx
    4452:	mov    rax,QWORD PTR [rdi+0x10]
    4456:	mov    rcx,QWORD PTR [rax+0x38]
    445a:	xor    rdx,rdx
    445d:	call   4462 <botlish_fn_46+0x23a>
			445e: R_X86_64_PLT32	rt_type_error-0x4
    4462:	jmp    45d0 <botlish_fn_46+0x3a8>
    4467:	test   rsi,0x1
    446e:	je     4486 <botlish_fn_46+0x25e>
    4474:	mov    rcx,rsi
    4477:	add    rcx,0x2
    447b:	seto   al
    447e:	test   al,al
    4480:	je     4496 <botlish_fn_46+0x26e>
    4486:	mov    edx,0x3
    448b:	mov    rdi,rbx
    448e:	call   4493 <botlish_fn_46+0x26b>
			448f: R_X86_64_PLT32	rt_int_add-0x4
    4493:	mov    rcx,rax
    4496:	mov    edx,0x7
    449b:	mov    rsi,r12
    449e:	mov    rdi,rbx
    44a1:	call   44a6 <botlish_fn_46+0x27e>
			44a2: R_X86_64_PLT32	rt_mutarray_set-0x4
    44a6:	test   rax,rax
    44a9:	je     45d0 <botlish_fn_46+0x3a8>
    44af:	mov    rax,r13
    44b2:	test   rax,0x1
    44b8:	jne    44dc <botlish_fn_46+0x2b4>
    44be:	mov    edx,0x5
    44c3:	mov    rsi,r13
    44c6:	mov    rdi,rbx
    44c9:	call   44ce <botlish_fn_46+0x2a6>
			44ca: R_X86_64_PLT32	rt_value_eq-0x4
    44ce:	test   rax,rax
    44d1:	je     45d0 <botlish_fn_46+0x3a8>
    44d7:	jmp    44f0 <botlish_fn_46+0x2c8>
    44dc:	mov    rsi,r13
    44df:	mov    eax,0x2
    44e4:	cmp    rsi,0x5
    44e8:	cmove  rax,QWORD PTR [rip+0x130]        # 4620 <botlish_fn_46+0x3f8>
    44f0:	cmp    rax,0x6
    44f4:	jne    45f5 <botlish_fn_46+0x3cd>
    44fa:	mov    QWORD PTR [rsp+0x8],0x9
    4503:	mov    rsi,r12
    4506:	mov    rdi,rbx
    4509:	call   450e <botlish_fn_46+0x2e6>
			450a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    450e:	test   rax,rax
    4511:	je     45d0 <botlish_fn_46+0x3a8>
    4517:	mov    QWORD PTR [rsp+0x10],rax
    451c:	mov    QWORD PTR [rsp+0x18],0x3
    4525:	mov    ecx,0x1
    452a:	test   rax,0x1
    4530:	je     453e <botlish_fn_46+0x316>
    4536:	mov    rsi,rax
    4539:	jmp    4562 <botlish_fn_46+0x33a>
    453e:	xor    ecx,ecx
    4540:	test   rax,0x7
    4546:	je     4554 <botlish_fn_46+0x32c>
    454c:	mov    rsi,rax
    454f:	jmp    4562 <botlish_fn_46+0x33a>
    4554:	movzx  rcx,BYTE PTR [rax]
    4558:	mov    rsi,rax
    455b:	rex cmp cl,0x1
    455f:	sete   cl
    4562:	test   cl,cl
    4564:	jne    4582 <botlish_fn_46+0x35a>
    456a:	mov    rdi,rbx
    456d:	mov    rcx,QWORD PTR [rdi+0x10]
    4571:	mov    rcx,QWORD PTR [rcx+0x48]
    4575:	xor    rdx,rdx
    4578:	call   457d <botlish_fn_46+0x355>
			4579: R_X86_64_PLT32	rt_type_error-0x4
    457d:	jmp    45d0 <botlish_fn_46+0x3a8>
    4582:	test   rsi,0x1
    4589:	je     45a7 <botlish_fn_46+0x37f>
    458f:	mov    r8,rsi
    4592:	sub    r8,0x3
    4596:	seto   dil
    459a:	lea    rcx,[r8+0x1]
    459e:	test   dil,dil
    45a1:	je     45b7 <botlish_fn_46+0x38f>
    45a7:	mov    edx,0x3
    45ac:	mov    rdi,rbx
    45af:	call   45b4 <botlish_fn_46+0x38c>
			45b0: R_X86_64_PLT32	rt_int_sub-0x4
    45b4:	mov    rcx,rax
    45b7:	mov    edx,0x9
    45bc:	mov    rsi,r12
    45bf:	mov    rdi,rbx
    45c2:	call   45c7 <botlish_fn_46+0x39f>
			45c3: R_X86_64_PLT32	rt_mutarray_set-0x4
    45c7:	test   rax,rax
    45ca:	jne    45f5 <botlish_fn_46+0x3cd>
    45d0:	xor    rax,rax
    45d3:	mov    rbx,QWORD PTR [rsp+0x40]
    45d8:	mov    r12,QWORD PTR [rsp+0x48]
    45dd:	mov    r13,QWORD PTR [rsp+0x50]
    45e2:	mov    r14,QWORD PTR [rsp+0x58]
    45e7:	mov    r15,QWORD PTR [rsp+0x60]
    45ec:	add    rsp,0x70
    45f0:	mov    rsp,rbp
    45f3:	pop    rbp
    45f4:	ret
    45f5:	mov    eax,0xa
    45fa:	mov    rbx,QWORD PTR [rsp+0x40]
    45ff:	mov    r12,QWORD PTR [rsp+0x48]
    4604:	mov    r13,QWORD PTR [rsp+0x50]
    4609:	mov    r14,QWORD PTR [rsp+0x58]
    460e:	mov    r15,QWORD PTR [rsp+0x60]
    4613:	add    rsp,0x70
    4617:	mov    rsp,rbp
    461a:	pop    rbp
    461b:	ret
    461c:	add    BYTE PTR [rax],al
    461e:	add    BYTE PTR [rax],al
    4620:	(bad)
    4621:	add    BYTE PTR [rax],al
    4623:	add    BYTE PTR [rax],al
    4625:	add    BYTE PTR [rax],al
	...

0000000000004628 <botlish_entry_46: ht_place<mutarray, int, str, str>>:
    4628:	push   rbp
    4629:	mov    rbp,rsp
    462c:	mov    rsi,QWORD PTR [rdx]
    462f:	mov    r9,QWORD PTR [rdx+0x8]
    4633:	mov    rcx,QWORD PTR [rdx+0x10]
    4637:	mov    r8,QWORD PTR [rdx+0x18]
    463b:	mov    rdx,r9
    463e:	call   4643 <botlish_entry_46+0x1b>
			463f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4643:	mov    rsp,rbp
    4646:	pop    rbp
    4647:	ret

0000000000004648 <botlish_fn_47: ht_set<mutarray, str, str>>:
    4648:	push   rbp
    4649:	mov    rbp,rsp
    464c:	sub    rsp,0x60
    4650:	mov    QWORD PTR [rsp+0x30],rbx
    4655:	mov    QWORD PTR [rsp+0x38],r12
    465a:	mov    QWORD PTR [rsp+0x40],r13
    465f:	mov    QWORD PTR [rsp+0x48],r14
    4664:	mov    QWORD PTR [rsp+0x50],r15
    4669:	mov    rbx,rdi
    466c:	mov    r13,rdx
    466f:	mov    QWORD PTR [rsp],rsi
    4673:	mov    r14,rsi
    4676:	mov    QWORD PTR [rsp+0x8],rdx
    467b:	mov    QWORD PTR [rsp+0x10],rcx
    4680:	mov    r12,rcx
    4683:	mov    rdx,r13
    4686:	mov    rsi,r14
    4689:	mov    rdi,rbx
    468c:	call   4691 <botlish_fn_47+0x49>
			468d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    4691:	test   rax,rax
    4694:	je     48fe <botlish_fn_47+0x2b6>
    469a:	mov    QWORD PTR [rsp+0x18],rax
    469f:	mov    rcx,rax
    46a2:	mov    r8,0xffffffffffffffff
    46a9:	mov    QWORD PTR [rsp+0x28],r8
    46ae:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    46b7:	mov    rdx,r13
    46ba:	mov    rsi,r14
    46bd:	mov    rdi,rbx
    46c0:	call   46c5 <botlish_fn_47+0x7d>
			46c1: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    46c5:	mov    rcx,rax
    46c8:	mov    r15,rax
    46cb:	test   rax,rcx
    46ce:	je     48fe <botlish_fn_47+0x2b6>
    46d4:	mov    rax,r15
    46d7:	mov    QWORD PTR [rsp+0x18],rax
    46dc:	mov    rsi,r14
    46df:	mov    rdi,rbx
    46e2:	call   46e7 <botlish_fn_47+0x9f>
			46e3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    46e7:	test   rax,rax
    46ea:	je     48fe <botlish_fn_47+0x2b6>
    46f0:	xor    ecx,ecx
    46f2:	test   rax,0x7
    46f8:	je     4706 <botlish_fn_47+0xbe>
    46fe:	mov    r8,rax
    4701:	jmp    4714 <botlish_fn_47+0xcc>
    4706:	movzx  rcx,BYTE PTR [rax]
    470a:	mov    r8,rax
    470d:	rex cmp cl,0x8
    4711:	sete   cl
    4714:	test   cl,cl
    4716:	jne    4739 <botlish_fn_47+0xf1>
    471c:	mov    rdi,rbx
    471f:	mov    rsi,QWORD PTR [rdi+0x10]
    4723:	mov    rcx,QWORD PTR [rsi+0x30]
    4727:	mov    edx,0x8
    472c:	mov    rsi,r8
    472f:	call   4734 <botlish_fn_47+0xec>
			4730: R_X86_64_PLT32	rt_type_error-0x4
    4734:	jmp    48fe <botlish_fn_47+0x2b6>
    4739:	mov    rsi,r8
    473c:	mov    rdx,r15
    473f:	mov    rdi,rbx
    4742:	call   4747 <botlish_fn_47+0xff>
			4743: R_X86_64_PLT32	rt_mutarray_get-0x4
    4747:	test   rax,rax
    474a:	je     48fe <botlish_fn_47+0x2b6>
    4750:	test   rax,0x1
    4756:	mov    rsi,rax
    4759:	jne    477a <botlish_fn_47+0x132>
    475f:	mov    edx,0x3
    4764:	mov    rdi,rbx
    4767:	call   476c <botlish_fn_47+0x124>
			4768: R_X86_64_PLT32	rt_value_eq-0x4
    476c:	test   rax,rax
    476f:	je     48fe <botlish_fn_47+0x2b6>
    4775:	jmp    478b <botlish_fn_47+0x143>
    477a:	mov    eax,0x2
    477f:	cmp    rsi,0x3
    4783:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4950 <botlish_fn_47+0x308>
    478b:	cmp    rax,0x6
    478f:	je     488e <botlish_fn_47+0x246>
    4795:	mov    rsi,r14
    4798:	mov    rdi,rbx
    479b:	call   47a0 <botlish_fn_47+0x158>
			479c: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    47a0:	test   rax,rax
    47a3:	je     48fe <botlish_fn_47+0x2b6>
    47a9:	cmp    rax,0x6
    47ad:	je     47f2 <botlish_fn_47+0x1aa>
    47b3:	mov    rcx,r13
    47b6:	mov    rdx,r15
    47b9:	mov    rsi,r14
    47bc:	mov    rdi,rbx
    47bf:	mov    r8,r12
    47c2:	call   47c7 <botlish_fn_47+0x17f>
			47c3: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    47c7:	test   rax,rax
    47ca:	je     48fe <botlish_fn_47+0x2b6>
    47d0:	mov    rbx,QWORD PTR [rsp+0x30]
    47d5:	mov    r12,QWORD PTR [rsp+0x38]
    47da:	mov    r13,QWORD PTR [rsp+0x40]
    47df:	mov    r14,QWORD PTR [rsp+0x48]
    47e4:	mov    r15,QWORD PTR [rsp+0x50]
    47e9:	add    rsp,0x60
    47ed:	mov    rsp,rbp
    47f0:	pop    rbp
    47f1:	ret
    47f2:	mov    rsi,r14
    47f5:	mov    rdi,rbx
    47f8:	call   47fd <botlish_fn_47+0x1b5>
			47f9: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    47fd:	test   rax,rax
    4800:	je     48fe <botlish_fn_47+0x2b6>
    4806:	mov    rdx,r13
    4809:	mov    rsi,r14
    480c:	mov    rdi,rbx
    480f:	call   4814 <botlish_fn_47+0x1cc>
			4810: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    4814:	test   rax,rax
    4817:	je     48fe <botlish_fn_47+0x2b6>
    481d:	mov    QWORD PTR [rsp+0x18],rax
    4822:	mov    rcx,rax
    4825:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    482e:	mov    r8,QWORD PTR [rsp+0x28]
    4833:	mov    rdx,r13
    4836:	mov    rsi,r14
    4839:	mov    rdi,rbx
    483c:	call   4841 <botlish_fn_47+0x1f9>
			483d: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4841:	test   rax,rax
    4844:	je     48fe <botlish_fn_47+0x2b6>
    484a:	mov    QWORD PTR [rsp+0x18],rax
    484f:	mov    rcx,r13
    4852:	mov    rdx,rax
    4855:	mov    rsi,r14
    4858:	mov    rdi,rbx
    485b:	mov    r8,r12
    485e:	call   4863 <botlish_fn_47+0x21b>
			485f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4863:	test   rax,rax
    4866:	je     48fe <botlish_fn_47+0x2b6>
    486c:	mov    rbx,QWORD PTR [rsp+0x30]
    4871:	mov    r12,QWORD PTR [rsp+0x38]
    4876:	mov    r13,QWORD PTR [rsp+0x40]
    487b:	mov    r14,QWORD PTR [rsp+0x48]
    4880:	mov    r15,QWORD PTR [rsp+0x50]
    4885:	add    rsp,0x60
    4889:	mov    rsp,rbp
    488c:	pop    rbp
    488d:	ret
    488e:	mov    rsi,r14
    4891:	mov    rdi,rbx
    4894:	call   4899 <botlish_fn_47+0x251>
			4895: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    4899:	test   rax,rax
    489c:	je     48fe <botlish_fn_47+0x2b6>
    48a2:	xor    ecx,ecx
    48a4:	test   rax,0x7
    48aa:	je     48b8 <botlish_fn_47+0x270>
    48b0:	mov    rsi,rax
    48b3:	jmp    48c6 <botlish_fn_47+0x27e>
    48b8:	movzx  rcx,BYTE PTR [rax]
    48bc:	mov    rsi,rax
    48bf:	rex cmp cl,0x8
    48c3:	sete   cl
    48c6:	test   cl,cl
    48c8:	jne    48e7 <botlish_fn_47+0x29f>
    48ce:	mov    rdi,rbx
    48d1:	mov    rax,QWORD PTR [rdi+0x10]
    48d5:	mov    rcx,QWORD PTR [rax]
    48d8:	mov    edx,0x8
    48dd:	call   48e2 <botlish_fn_47+0x29a>
			48de: R_X86_64_PLT32	rt_type_error-0x4
    48e2:	jmp    48fe <botlish_fn_47+0x2b6>
    48e7:	mov    rcx,r12
    48ea:	mov    rdx,r15
    48ed:	mov    rdi,rbx
    48f0:	call   48f5 <botlish_fn_47+0x2ad>
			48f1: R_X86_64_PLT32	rt_mutarray_set-0x4
    48f5:	test   rax,rax
    48f8:	jne    4923 <botlish_fn_47+0x2db>
    48fe:	xor    rax,rax
    4901:	mov    rbx,QWORD PTR [rsp+0x30]
    4906:	mov    r12,QWORD PTR [rsp+0x38]
    490b:	mov    r13,QWORD PTR [rsp+0x40]
    4910:	mov    r14,QWORD PTR [rsp+0x48]
    4915:	mov    r15,QWORD PTR [rsp+0x50]
    491a:	add    rsp,0x60
    491e:	mov    rsp,rbp
    4921:	pop    rbp
    4922:	ret
    4923:	mov    eax,0xa
    4928:	mov    rbx,QWORD PTR [rsp+0x30]
    492d:	mov    r12,QWORD PTR [rsp+0x38]
    4932:	mov    r13,QWORD PTR [rsp+0x40]
    4937:	mov    r14,QWORD PTR [rsp+0x48]
    493c:	mov    r15,QWORD PTR [rsp+0x50]
    4941:	add    rsp,0x60
    4945:	mov    rsp,rbp
    4948:	pop    rbp
    4949:	ret
    494a:	add    BYTE PTR [rax],al
    494c:	add    BYTE PTR [rax],al
    494e:	add    BYTE PTR [rax],al
    4950:	(bad)
    4951:	add    BYTE PTR [rax],al
    4953:	add    BYTE PTR [rax],al
    4955:	add    BYTE PTR [rax],al
	...

0000000000004958 <botlish_entry_47: ht_set<mutarray, str, str>>:
    4958:	push   rbp
    4959:	mov    rbp,rsp
    495c:	mov    rsi,QWORD PTR [rdx]
    495f:	mov    r8,QWORD PTR [rdx+0x8]
    4963:	mov    rcx,QWORD PTR [rdx+0x10]
    4967:	mov    rdx,r8
    496a:	call   496f <botlish_entry_47+0x17>
			496b: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    496f:	mov    rsp,rbp
    4972:	pop    rbp
    4973:	ret

0000000000004974 <botlish_fn_48: row_new<bool, int>>:
    4974:	push   rbp
    4975:	mov    rbp,rsp
    4978:	sub    rsp,0x10
    497c:	mov    QWORD PTR [rsp],rdx
    4980:	mov    r8,rdx
    4983:	cmp    rsi,0x6
    4987:	je     49a4 <botlish_fn_48+0x30>
    498d:	call   4992 <botlish_fn_48+0x1e>
			498e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    4992:	test   rax,rax
    4995:	je     49b5 <botlish_fn_48+0x41>
    499b:	add    rsp,0x10
    499f:	mov    rsp,rbp
    49a2:	pop    rbp
    49a3:	ret
    49a4:	mov    rsi,r8
    49a7:	call   49ac <botlish_fn_48+0x38>
			49a8: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    49ac:	test   rax,rax
    49af:	jne    49c1 <botlish_fn_48+0x4d>
    49b5:	xor    rax,rax
    49b8:	add    rsp,0x10
    49bc:	mov    rsp,rbp
    49bf:	pop    rbp
    49c0:	ret
    49c1:	add    rsp,0x10
    49c5:	mov    rsp,rbp
    49c8:	pop    rbp
    49c9:	ret

00000000000049ca <botlish_entry_48: row_new<bool, int>>:
    49ca:	push   rbp
    49cb:	mov    rbp,rsp
    49ce:	mov    rsi,QWORD PTR [rdx]
    49d1:	mov    rdx,QWORD PTR [rdx+0x8]
    49d5:	call   49da <botlish_entry_48+0x10>
			49d6: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    49da:	mov    rsp,rbp
    49dd:	pop    rbp
    49de:	ret

00000000000049df <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    49df:	push   rbp
    49e0:	mov    rbp,rsp
    49e3:	sub    rsp,0x70
    49e7:	mov    QWORD PTR [rsp+0x40],rbx
    49ec:	mov    QWORD PTR [rsp+0x48],r12
    49f1:	mov    QWORD PTR [rsp+0x50],r13
    49f6:	mov    QWORD PTR [rsp+0x58],r14
    49fb:	mov    QWORD PTR [rsp+0x60],r15
    4a00:	mov    QWORD PTR [rsp+0x28],rdi
    4a05:	mov    QWORD PTR [rsp],rsi
    4a09:	mov    r14,rsi
    4a0c:	mov    QWORD PTR [rsp+0x8],rdx
    4a11:	mov    QWORD PTR [rsp+0x10],rcx
    4a16:	mov    r13,rcx
    4a19:	sar    r8,1
    4a1c:	mov    rbx,r8
    4a1f:	mov    r15,r9
    4a22:	cmp    rbx,r15
    4a25:	jge    4b30 <botlish_fn_49+0x151>
    4a2b:	mov    r12,rdx
    4a2e:	mov    rdx,QWORD PTR [r12+0x8]
    4a33:	mov    rcx,rbx
    4a36:	shl    rcx,1
    4a39:	or     rcx,0x1
    4a3d:	sar    rcx,1
    4a40:	cmp    rcx,rdx
    4a43:	jb     4a71 <botlish_fn_49+0x92>
    4a49:	mov    rdx,rbx
    4a4c:	shl    rdx,1
    4a4f:	or     rdx,0x1
    4a53:	mov    rsi,r12
    4a56:	mov    rdi,QWORD PTR [rsp+0x28]
    4a5b:	call   4a60 <botlish_fn_49+0x81>
			4a5c: R_X86_64_PLT32	rt_list_get-0x4
    4a60:	test   rax,rax
    4a63:	je     4aee <botlish_fn_49+0x10f>
    4a69:	mov    rdx,rax
    4a6c:	jmp    4a7a <botlish_fn_49+0x9b>
    4a71:	mov    rax,QWORD PTR [r12+0x10]
    4a76:	mov    rdx,QWORD PTR [rax+rcx*8]
    4a7a:	mov    QWORD PTR [rsp+0x18],rdx
    4a7f:	mov    QWORD PTR [rsp+0x30],rdx
    4a84:	mov    rax,QWORD PTR [r13+0x8]
    4a88:	mov    rcx,rbx
    4a8b:	shl    rcx,1
    4a8e:	or     rcx,0x1
    4a92:	sar    rcx,1
    4a95:	cmp    rcx,rax
    4a98:	jb     4ac6 <botlish_fn_49+0xe7>
    4a9e:	mov    rdx,rbx
    4aa1:	shl    rdx,1
    4aa4:	or     rdx,0x1
    4aa8:	mov    rsi,r13
    4aab:	mov    rdi,QWORD PTR [rsp+0x28]
    4ab0:	call   4ab5 <botlish_fn_49+0xd6>
			4ab1: R_X86_64_PLT32	rt_list_get-0x4
    4ab5:	test   rax,rax
    4ab8:	je     4aee <botlish_fn_49+0x10f>
    4abe:	mov    rcx,rax
    4ac1:	jmp    4ace <botlish_fn_49+0xef>
    4ac6:	mov    rax,QWORD PTR [r13+0x10]
    4aca:	mov    rcx,QWORD PTR [rax+rcx*8]
    4ace:	mov    QWORD PTR [rsp+0x20],rcx
    4ad3:	mov    rdx,QWORD PTR [rsp+0x30]
    4ad8:	mov    rsi,r14
    4adb:	mov    rdi,QWORD PTR [rsp+0x28]
    4ae0:	call   4ae5 <botlish_fn_49+0x106>
			4ae1: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4ae5:	test   rax,rax
    4ae8:	jne    4b13 <botlish_fn_49+0x134>
    4aee:	xor    rax,rax
    4af1:	mov    rbx,QWORD PTR [rsp+0x40]
    4af6:	mov    r12,QWORD PTR [rsp+0x48]
    4afb:	mov    r13,QWORD PTR [rsp+0x50]
    4b00:	mov    r14,QWORD PTR [rsp+0x58]
    4b05:	mov    r15,QWORD PTR [rsp+0x60]
    4b0a:	add    rsp,0x70
    4b0e:	mov    rsp,rbp
    4b11:	pop    rbp
    4b12:	ret
    4b13:	mov    QWORD PTR [rsp],r14
    4b17:	mov    QWORD PTR [rsp+0x8],r12
    4b1c:	mov    QWORD PTR [rsp+0x10],r13
    4b21:	add    rbx,0x1
    4b28:	mov    rdx,r12
    4b2b:	jmp    4a22 <botlish_fn_49+0x43>
    4b30:	mov    rax,r14
    4b33:	mov    rbx,QWORD PTR [rsp+0x40]
    4b38:	mov    r12,QWORD PTR [rsp+0x48]
    4b3d:	mov    r13,QWORD PTR [rsp+0x50]
    4b42:	mov    r14,QWORD PTR [rsp+0x58]
    4b47:	mov    r15,QWORD PTR [rsp+0x60]
    4b4c:	add    rsp,0x70
    4b50:	mov    rsp,rbp
    4b53:	pop    rbp
    4b54:	ret

0000000000004b55 <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4b55:	push   rbp
    4b56:	mov    rbp,rsp
    4b59:	mov    rsi,QWORD PTR [rdx]
    4b5c:	mov    r10,QWORD PTR [rdx+0x8]
    4b60:	mov    rcx,QWORD PTR [rdx+0x10]
    4b64:	mov    r8,QWORD PTR [rdx+0x18]
    4b68:	mov    r9,QWORD PTR [rdx+0x20]
    4b6c:	sar    r9,1
    4b6f:	mov    rdx,r10
    4b72:	call   4b77 <botlish_entry_49+0x22>
			4b73: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4b77:	mov    rsp,rbp
    4b7a:	pop    rbp
    4b7b:	ret

0000000000004b7c <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4b7c:	push   rbp
    4b7d:	mov    rbp,rsp
    4b80:	sub    rsp,0x50
    4b84:	mov    QWORD PTR [rsp+0x20],rbx
    4b89:	mov    QWORD PTR [rsp+0x28],r12
    4b8e:	mov    QWORD PTR [rsp+0x30],r13
    4b93:	mov    QWORD PTR [rsp+0x38],r14
    4b98:	mov    QWORD PTR [rsp+0x40],r15
    4b9d:	mov    r12,rdi
    4ba0:	mov    QWORD PTR [rsp],rsi
    4ba4:	mov    r15,rsi
    4ba7:	mov    QWORD PTR [rsp+0x8],rdx
    4bac:	mov    QWORD PTR [rsp+0x10],rcx
    4bb1:	mov    r13,rcx
    4bb4:	mov    QWORD PTR [rsp+0x18],r8
    4bb9:	mov    rsi,r8
    4bbc:	mov    rdi,r12
    4bbf:	call   4bc4 <botlish_fn_50+0x48>
			4bc0: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4bc4:	test   rax,rax
    4bc7:	je     4c11 <botlish_fn_50+0x95>
    4bcd:	mov    QWORD PTR [rsp+0x8],rax
    4bd2:	mov    r14,rax
    4bd5:	mov    ebx,0x1
    4bda:	mov    QWORD PTR [rsp+0x18],0x1
    4be3:	mov    rsi,r13
    4be6:	mov    rdi,r12
    4be9:	call   4bee <botlish_fn_50+0x72>
			4bea: R_X86_64_PLT32	rt_list_len-0x4
    4bee:	mov    r9,rax
    4bf1:	sar    r9,1
    4bf4:	mov    rcx,r13
    4bf7:	mov    rdx,r15
    4bfa:	mov    rsi,r14
    4bfd:	mov    rdi,r12
    4c00:	mov    r8,rbx
    4c03:	call   4c08 <botlish_fn_50+0x8c>
			4c04: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4c08:	test   rax,rax
    4c0b:	jne    4c36 <botlish_fn_50+0xba>
    4c11:	xor    rax,rax
    4c14:	mov    rbx,QWORD PTR [rsp+0x20]
    4c19:	mov    r12,QWORD PTR [rsp+0x28]
    4c1e:	mov    r13,QWORD PTR [rsp+0x30]
    4c23:	mov    r14,QWORD PTR [rsp+0x38]
    4c28:	mov    r15,QWORD PTR [rsp+0x40]
    4c2d:	add    rsp,0x50
    4c31:	mov    rsp,rbp
    4c34:	pop    rbp
    4c35:	ret
    4c36:	mov    rbx,QWORD PTR [rsp+0x20]
    4c3b:	mov    r12,QWORD PTR [rsp+0x28]
    4c40:	mov    r13,QWORD PTR [rsp+0x30]
    4c45:	mov    r14,QWORD PTR [rsp+0x38]
    4c4a:	mov    r15,QWORD PTR [rsp+0x40]
    4c4f:	add    rsp,0x50
    4c53:	mov    rsp,rbp
    4c56:	pop    rbp
    4c57:	ret

0000000000004c58 <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4c58:	push   rbp
    4c59:	mov    rbp,rsp
    4c5c:	mov    rsi,QWORD PTR [rdx]
    4c5f:	mov    r9,QWORD PTR [rdx+0x8]
    4c63:	mov    rcx,QWORD PTR [rdx+0x10]
    4c67:	mov    r8,QWORD PTR [rdx+0x18]
    4c6b:	mov    rdx,r9
    4c6e:	call   4c73 <botlish_entry_50+0x1b>
			4c6f: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4c73:	mov    rsp,rbp
    4c76:	pop    rbp
    4c77:	ret

0000000000004c78 <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4c78:	push   rbp
    4c79:	mov    rbp,rsp
    4c7c:	sub    rsp,0x90
    4c83:	mov    QWORD PTR [rsp+0x60],rbx
    4c88:	mov    QWORD PTR [rsp+0x68],r12
    4c8d:	mov    QWORD PTR [rsp+0x70],r13
    4c92:	mov    QWORD PTR [rsp+0x78],r14
    4c97:	mov    QWORD PTR [rsp+0x80],r15
    4c9f:	mov    r13,r8
    4ca2:	mov    QWORD PTR [rsp+0x38],rdi
    4ca7:	mov    rdi,QWORD PTR [rbp+0x10]
    4cab:	mov    r15,QWORD PTR [rbp+0x18]
    4caf:	mov    QWORD PTR [rsp+0x28],0x0
    4cb8:	mov    QWORD PTR [rsp+0x30],0x0
    4cc1:	mov    QWORD PTR [rsp],rsi
    4cc5:	mov    QWORD PTR [rsp+0x8],rcx
    4cca:	mov    r14,rcx
    4ccd:	mov    QWORD PTR [rsp+0x10],r9
    4cd2:	mov    QWORD PTR [rsp+0x18],rdi
    4cd7:	mov    QWORD PTR [rsp+0x20],r15
    4cdc:	sar    rdx,1
    4cdf:	mov    r12,rdx
    4ce2:	mov    rbx,rsi
    4ce5:	mov    QWORD PTR [rsp+0x40],r9
    4cea:	mov    QWORD PTR [rsp+0x48],rdi
    4cef:	mov    rsi,rbx
    4cf2:	mov    rdi,QWORD PTR [rsp+0x38]
    4cf7:	call   4cfc <botlish_fn_51+0x84>
			4cf8: R_X86_64_PLT32	rt_list_len-0x4
    4cfc:	sar    rax,1
    4cff:	cmp    r12,rax
    4d02:	jge    4e2d <botlish_fn_51+0x1b5>
    4d08:	mov    rax,r13
    4d0b:	or     rax,0x1
    4d0f:	mov    QWORD PTR [rsp+0x28],rax
    4d14:	mov    rcx,QWORD PTR [rbx+0x8]
    4d18:	mov    rax,r12
    4d1b:	shl    rax,1
    4d1e:	or     rax,0x1
    4d22:	sar    rax,1
    4d25:	cmp    rax,rcx
    4d28:	jb     4d56 <botlish_fn_51+0xde>
    4d2e:	mov    rdx,r12
    4d31:	shl    rdx,1
    4d34:	or     rdx,0x1
    4d38:	mov    rsi,rbx
    4d3b:	mov    rdi,QWORD PTR [rsp+0x38]
    4d40:	call   4d45 <botlish_fn_51+0xcd>
			4d41: R_X86_64_PLT32	rt_list_get-0x4
    4d45:	test   rax,rax
    4d48:	je     4e4a <botlish_fn_51+0x1d2>
    4d4e:	mov    rcx,rax
    4d51:	jmp    4d5e <botlish_fn_51+0xe6>
    4d56:	mov    rcx,QWORD PTR [rbx+0x10]
    4d5a:	mov    rcx,QWORD PTR [rcx+rax*8]
    4d5e:	mov    QWORD PTR [rsp+0x30],rcx
    4d63:	mov    rdx,r13
    4d66:	or     rdx,0x1
    4d6a:	mov    rsi,r14
    4d6d:	mov    rdi,QWORD PTR [rsp+0x38]
    4d72:	mov    r8,r15
    4d75:	call   4d7a <botlish_fn_51+0x102>
			4d76: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4d7a:	test   rax,rax
    4d7d:	je     4e4a <botlish_fn_51+0x1d2>
    4d83:	mov    QWORD PTR [rsp+0x28],rax
    4d88:	mov    rcx,rax
    4d8b:	mov    rsi,QWORD PTR [rsp+0x40]
    4d90:	mov    rdx,QWORD PTR [rsp+0x48]
    4d95:	mov    rdi,QWORD PTR [rsp+0x38]
    4d9a:	call   4d9f <botlish_fn_51+0x127>
			4d9b: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4d9f:	test   rax,rax
    4da2:	je     4e4a <botlish_fn_51+0x1d2>
    4da8:	mov    QWORD PTR [rsp+0x10],rax
    4dad:	mov    QWORD PTR [rsp+0x50],rax
    4db2:	mov    QWORD PTR [rsp+0x28],0x3
    4dbb:	mov    rsi,QWORD PTR [rsp+0x48]
    4dc0:	test   rsi,0x1
    4dc7:	je     4de6 <botlish_fn_51+0x16e>
    4dcd:	mov    rsi,QWORD PTR [rsp+0x48]
    4dd2:	mov    rax,rsi
    4dd5:	add    rax,0x2
    4dd9:	seto   r10b
    4ddd:	test   r10b,r10b
    4de0:	je     4dfa <botlish_fn_51+0x182>
    4de6:	mov    edx,0x3
    4deb:	mov    rsi,QWORD PTR [rsp+0x48]
    4df0:	mov    rdi,QWORD PTR [rsp+0x38]
    4df5:	call   4dfa <botlish_fn_51+0x182>
			4df6: R_X86_64_PLT32	rt_int_add-0x4
    4dfa:	mov    QWORD PTR [rsp],rbx
    4dfe:	mov    QWORD PTR [rsp+0x8],r14
    4e03:	mov    rcx,QWORD PTR [rsp+0x50]
    4e08:	mov    QWORD PTR [rsp+0x10],rcx
    4e0d:	mov    QWORD PTR [rsp+0x18],rax
    4e12:	mov    QWORD PTR [rsp+0x20],r15
    4e17:	add    r12,0x1
    4e1e:	mov    QWORD PTR [rsp+0x40],rcx
    4e23:	mov    QWORD PTR [rsp+0x48],rax
    4e28:	jmp    4cef <botlish_fn_51+0x77>
    4e2d:	mov    rdx,QWORD PTR [rsp+0x48]
    4e32:	mov    rsi,QWORD PTR [rsp+0x40]
    4e37:	mov    rdi,QWORD PTR [rsp+0x38]
    4e3c:	call   4e41 <botlish_fn_51+0x1c9>
			4e3d: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4e41:	test   rax,rax
    4e44:	jne    4e75 <botlish_fn_51+0x1fd>
    4e4a:	xor    rax,rax
    4e4d:	mov    rbx,QWORD PTR [rsp+0x60]
    4e52:	mov    r12,QWORD PTR [rsp+0x68]
    4e57:	mov    r13,QWORD PTR [rsp+0x70]
    4e5c:	mov    r14,QWORD PTR [rsp+0x78]
    4e61:	mov    r15,QWORD PTR [rsp+0x80]
    4e69:	add    rsp,0x90
    4e70:	mov    rsp,rbp
    4e73:	pop    rbp
    4e74:	ret
    4e75:	mov    rbx,QWORD PTR [rsp+0x60]
    4e7a:	mov    r12,QWORD PTR [rsp+0x68]
    4e7f:	mov    r13,QWORD PTR [rsp+0x70]
    4e84:	mov    r14,QWORD PTR [rsp+0x78]
    4e89:	mov    r15,QWORD PTR [rsp+0x80]
    4e91:	add    rsp,0x90
    4e98:	mov    rsp,rbp
    4e9b:	pop    rbp
    4e9c:	ret

0000000000004e9d <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4e9d:	push   rbp
    4e9e:	mov    rbp,rsp
    4ea1:	sub    rsp,0x10
    4ea5:	mov    rsi,QWORD PTR [rdx]
    4ea8:	mov    r10,QWORD PTR [rdx+0x8]
    4eac:	mov    rcx,QWORD PTR [rdx+0x10]
    4eb0:	mov    r8,QWORD PTR [rdx+0x18]
    4eb4:	mov    r9,QWORD PTR [rdx+0x20]
    4eb8:	mov    r11,QWORD PTR [rdx+0x28]
    4ebc:	mov    rax,QWORD PTR [rdx+0x30]
    4ec0:	mov    QWORD PTR [rsp],r11
    4ec4:	mov    QWORD PTR [rsp+0x8],rax
    4ec9:	mov    rdx,r10
    4ecc:	call   4ed1 <botlish_entry_51+0x34>
			4ecd: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4ed1:	add    rsp,0x10
    4ed5:	mov    rsp,rbp
    4ed8:	pop    rbp
    4ed9:	ret

0000000000004eda <botlish_fn_52: csv_records_generic<str, bool>>:
    4eda:	push   rbp
    4edb:	mov    rbp,rsp
    4ede:	sub    rsp,0x80
    4ee5:	mov    QWORD PTR [rsp+0x50],rbx
    4eea:	mov    QWORD PTR [rsp+0x58],r12
    4eef:	mov    QWORD PTR [rsp+0x60],r13
    4ef4:	mov    QWORD PTR [rsp+0x68],r14
    4ef9:	mov    QWORD PTR [rsp+0x70],r15
    4efe:	mov    r12,rdi
    4f01:	mov    QWORD PTR [rsp+0x20],0x0
    4f0a:	mov    QWORD PTR [rsp+0x28],0x0
    4f13:	mov    QWORD PTR [rsp+0x30],0x0
    4f1c:	mov    QWORD PTR [rsp+0x38],0x0
    4f25:	mov    QWORD PTR [rsp+0x40],0x0
    4f2e:	mov    QWORD PTR [rsp+0x10],rsi
    4f33:	mov    QWORD PTR [rsp+0x18],rdx
    4f38:	mov    r13,rdx
    4f3b:	mov    rdi,r12
    4f3e:	call   4f43 <botlish_fn_52+0x69>
			4f3f: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4f43:	mov    rcx,rax
    4f46:	mov    r14,rax
    4f49:	test   rax,rcx
    4f4c:	je     5066 <botlish_fn_52+0x18c>
    4f52:	mov    rax,r14
    4f55:	mov    QWORD PTR [rsp+0x10],rax
    4f5a:	mov    rsi,r14
    4f5d:	mov    rdi,r12
    4f60:	call   4f65 <botlish_fn_52+0x8b>
			4f61: R_X86_64_PLT32	rt_list_len-0x4
    4f65:	sar    rax,1
    4f68:	cmp    rax,0x1
    4f6c:	jle    504f <botlish_fn_52+0x175>
    4f72:	mov    rax,r14
    4f75:	mov    rax,QWORD PTR [rax+0x10]
    4f79:	mov    rbx,QWORD PTR [rax]
    4f7c:	mov    QWORD PTR [rsp+0x20],rbx
    4f81:	mov    rsi,rbx
    4f84:	mov    rdi,r12
    4f87:	call   4f8c <botlish_fn_52+0xb2>
			4f88: R_X86_64_PLT32	rt_list_len-0x4
    4f8c:	mov    r15,rbx
    4f8f:	mov    QWORD PTR [rsp+0x28],rax
    4f94:	mov    QWORD PTR [rsp+0x48],rax
    4f99:	mov    rax,r14
    4f9c:	mov    rcx,QWORD PTR [rax+0x10]
    4fa0:	mov    rcx,QWORD PTR [rcx+0x8]
    4fa4:	mov    QWORD PTR [rsp+0x30],rcx
    4fa9:	mov    rbx,r13
    4fac:	mov    rdx,QWORD PTR [rsp+0x48]
    4fb1:	mov    rsi,r15
    4fb4:	mov    rdi,r12
    4fb7:	mov    r8,rbx
    4fba:	call   4fbf <botlish_fn_52+0xe5>
			4fbb: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4fbf:	test   rax,rax
    4fc2:	je     5066 <botlish_fn_52+0x18c>
    4fc8:	mov    QWORD PTR [rsp+0x30],rax
    4fcd:	mov    rsi,rax
    4fd0:	mov    QWORD PTR [rsp+0x38],0x5
    4fd9:	mov    rdi,r12
    4fdc:	call   4fe1 <botlish_fn_52+0x107>
			4fdd: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    4fe1:	test   rax,rax
    4fe4:	je     5066 <botlish_fn_52+0x18c>
    4fea:	mov    QWORD PTR [rsp+0x30],rax
    4fef:	mov    r9,rax
    4ff2:	mov    eax,0x3
    4ff7:	mov    QWORD PTR [rsp+0x40],0x3
    5000:	mov    edx,0x5
    5005:	mov    QWORD PTR [rsp],rax
    5009:	mov    QWORD PTR [rsp+0x8],rbx
    500e:	mov    rcx,r15
    5011:	mov    rsi,r14
    5014:	mov    rdi,r12
    5017:	mov    r8,QWORD PTR [rsp+0x48]
    501c:	call   5021 <botlish_fn_52+0x147>
			501d: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    5021:	test   rax,rax
    5024:	je     5066 <botlish_fn_52+0x18c>
    502a:	mov    rbx,QWORD PTR [rsp+0x50]
    502f:	mov    r12,QWORD PTR [rsp+0x58]
    5034:	mov    r13,QWORD PTR [rsp+0x60]
    5039:	mov    r14,QWORD PTR [rsp+0x68]
    503e:	mov    r15,QWORD PTR [rsp+0x70]
    5043:	add    rsp,0x80
    504a:	mov    rsp,rbp
    504d:	pop    rbp
    504e:	ret
    504f:	xor    rdx,rdx
    5052:	mov    rdi,r12
    5055:	mov    rsi,rdx
    5058:	call   505d <botlish_fn_52+0x183>
			5059: R_X86_64_PLT32	rt_list_new-0x4
    505d:	test   rax,rax
    5060:	jne    508e <botlish_fn_52+0x1b4>
    5066:	xor    rax,rax
    5069:	mov    rbx,QWORD PTR [rsp+0x50]
    506e:	mov    r12,QWORD PTR [rsp+0x58]
    5073:	mov    r13,QWORD PTR [rsp+0x60]
    5078:	mov    r14,QWORD PTR [rsp+0x68]
    507d:	mov    r15,QWORD PTR [rsp+0x70]
    5082:	add    rsp,0x80
    5089:	mov    rsp,rbp
    508c:	pop    rbp
    508d:	ret
    508e:	mov    rbx,QWORD PTR [rsp+0x50]
    5093:	mov    r12,QWORD PTR [rsp+0x58]
    5098:	mov    r13,QWORD PTR [rsp+0x60]
    509d:	mov    r14,QWORD PTR [rsp+0x68]
    50a2:	mov    r15,QWORD PTR [rsp+0x70]
    50a7:	add    rsp,0x80
    50ae:	mov    rsp,rbp
    50b1:	pop    rbp
    50b2:	ret

00000000000050b3 <botlish_entry_52: csv_records_generic<str, bool>>:
    50b3:	push   rbp
    50b4:	mov    rbp,rsp
    50b7:	mov    rsi,QWORD PTR [rdx]
    50ba:	mov    rdx,QWORD PTR [rdx+0x8]
    50be:	call   50c3 <botlish_entry_52+0x10>
			50bf: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50c3:	mov    rsp,rbp
    50c6:	pop    rbp
    50c7:	ret

00000000000050c8 <botlish_fn_53: csv_records<str>>:
    50c8:	push   rbp
    50c9:	mov    rbp,rsp
    50cc:	sub    rsp,0x10
    50d0:	mov    QWORD PTR [rsp],rsi
    50d4:	mov    edx,0x2
    50d9:	mov    QWORD PTR [rsp+0x8],0x2
    50e2:	call   50e7 <botlish_fn_53+0x1f>
			50e3: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50e7:	test   rax,rax
    50ea:	jne    50fc <botlish_fn_53+0x34>
    50f0:	xor    rax,rax
    50f3:	add    rsp,0x10
    50f7:	mov    rsp,rbp
    50fa:	pop    rbp
    50fb:	ret
    50fc:	add    rsp,0x10
    5100:	mov    rsp,rbp
    5103:	pop    rbp
    5104:	ret

0000000000005105 <botlish_entry_53: csv_records<str>>:
    5105:	push   rbp
    5106:	mov    rbp,rsp
    5109:	mov    rsi,QWORD PTR [rdx]
    510c:	call   5111 <botlish_entry_53+0xc>
			510d: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    5111:	mov    rsp,rbp
    5114:	pop    rbp
    5115:	ret

0000000000005116 <botlish_fn_54: csv_records_presized<str>>:
    5116:	push   rbp
    5117:	mov    rbp,rsp
    511a:	sub    rsp,0x10
    511e:	mov    QWORD PTR [rsp],rsi
    5122:	mov    edx,0x6
    5127:	mov    QWORD PTR [rsp+0x8],0x6
    5130:	call   5135 <botlish_fn_54+0x1f>
			5131: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5135:	test   rax,rax
    5138:	jne    514a <botlish_fn_54+0x34>
    513e:	xor    rax,rax
    5141:	add    rsp,0x10
    5145:	mov    rsp,rbp
    5148:	pop    rbp
    5149:	ret
    514a:	add    rsp,0x10
    514e:	mov    rsp,rbp
    5151:	pop    rbp
    5152:	ret

0000000000005153 <botlish_entry_54: csv_records_presized<str>>:
    5153:	push   rbp
    5154:	mov    rbp,rsp
    5157:	mov    rsi,QWORD PTR [rdx]
    515a:	call   515f <botlish_entry_54+0xc>
			515b: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    515f:	mov    rsp,rbp
    5162:	pop    rbp
    5163:	ret
    5164:	add    BYTE PTR [rax],al
	...

0000000000005168 <botlish_fn_55: sample_checks<generic>>:
    5168:	push   rbp
    5169:	mov    rbp,rsp
    516c:	sub    rsp,0xc0
    5173:	mov    QWORD PTR [rsp+0x90],rbx
    517b:	mov    QWORD PTR [rsp+0x98],r12
    5183:	mov    QWORD PTR [rsp+0xa0],r13
    518b:	mov    QWORD PTR [rsp+0xa8],r14
    5193:	mov    QWORD PTR [rsp+0xb0],r15
    519b:	mov    QWORD PTR [rsp+0x8],0x0
    51a4:	mov    QWORD PTR [rsp+0x10],0x0
    51ad:	mov    QWORD PTR [rsp+0x18],0x0
    51b6:	mov    QWORD PTR [rsp+0x20],0x0
    51bf:	mov    QWORD PTR [rsp+0x28],0x0
    51c8:	mov    QWORD PTR [rsp+0x30],0x0
    51d1:	mov    QWORD PTR [rsp+0x38],0x0
    51da:	mov    rax,QWORD PTR [rdi+0x10]
    51de:	mov    r13,rdi
    51e1:	mov    rsi,QWORD PTR [rax+0x50]
    51e5:	mov    QWORD PTR [rsp],rsi
    51e9:	call   51ee <botlish_fn_55+0x86>
			51ea: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    51ee:	mov    rsi,rax
    51f1:	mov    r12,rax
    51f4:	test   rax,rsi
    51f7:	je     557c <botlish_fn_55+0x414>
    51fd:	mov    rax,r12
    5200:	mov    QWORD PTR [rsp],rax
    5204:	mov    rdi,r13
    5207:	mov    rax,QWORD PTR [rdi+0x10]
    520b:	mov    rsi,QWORD PTR [rax+0x50]
    520f:	mov    QWORD PTR [rsp+0x8],rsi
    5214:	call   5219 <botlish_fn_55+0xb1>
			5215: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5219:	mov    rbx,rax
    521c:	test   rbx,rbx
    521f:	je     557c <botlish_fn_55+0x414>
    5225:	mov    rax,r12
    5228:	mov    rax,QWORD PTR [rax+0x8]
    522c:	test   rax,rax
    522f:	jne    5256 <botlish_fn_55+0xee>
    5235:	mov    edx,0x1
    523a:	mov    rsi,r12
    523d:	mov    rdi,r13
    5240:	call   5245 <botlish_fn_55+0xdd>
			5241: R_X86_64_PLT32	rt_list_get-0x4
    5245:	test   rax,rax
    5248:	je     557c <botlish_fn_55+0x414>
    524e:	mov    rsi,rax
    5251:	jmp    525e <botlish_fn_55+0xf6>
    5256:	mov    rax,QWORD PTR [r12+0x10]
    525b:	mov    rsi,QWORD PTR [rax]
    525e:	mov    QWORD PTR [rsp+0x8],rsi
    5263:	mov    r15,rsi
    5266:	mov    rax,QWORD PTR [r12+0x8]
    526b:	cmp    rax,0x1
    526f:	ja     5296 <botlish_fn_55+0x12e>
    5275:	mov    edx,0x3
    527a:	mov    rsi,r12
    527d:	mov    rdi,r13
    5280:	call   5285 <botlish_fn_55+0x11d>
			5281: R_X86_64_PLT32	rt_list_get-0x4
    5285:	test   rax,rax
    5288:	je     557c <botlish_fn_55+0x414>
    528e:	mov    rsi,rax
    5291:	jmp    529f <botlish_fn_55+0x137>
    5296:	mov    rax,QWORD PTR [r12+0x10]
    529b:	mov    rsi,QWORD PTR [rax+0x8]
    529f:	mov    QWORD PTR [rsp+0x10],rsi
    52a4:	mov    r14,rsi
    52a7:	mov    rax,QWORD PTR [rbx+0x8]
    52ab:	mov    rsi,rbx
    52ae:	test   rax,rax
    52b1:	jne    52d5 <botlish_fn_55+0x16d>
    52b7:	mov    edx,0x1
    52bc:	mov    rdi,r13
    52bf:	call   52c4 <botlish_fn_55+0x15c>
			52c0: R_X86_64_PLT32	rt_list_get-0x4
    52c4:	test   rax,rax
    52c7:	je     557c <botlish_fn_55+0x414>
    52cd:	mov    rsi,rax
    52d0:	jmp    52dc <botlish_fn_55+0x174>
    52d5:	mov    rax,QWORD PTR [rsi+0x10]
    52d9:	mov    rsi,QWORD PTR [rax]
    52dc:	mov    QWORD PTR [rsp+0x18],rsi
    52e1:	mov    rdi,r13
    52e4:	mov    QWORD PTR [rsp+0x78],rsi
    52e9:	mov    rax,QWORD PTR [rdi+0x10]
    52ed:	mov    rdx,QWORD PTR [rax+0x58]
    52f1:	mov    QWORD PTR [rsp+0x20],rdx
    52f6:	mov    rsi,r15
    52f9:	call   52fe <botlish_fn_55+0x196>
			52fa: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    52fe:	test   rax,rax
    5301:	je     557c <botlish_fn_55+0x414>
    5307:	mov    QWORD PTR [rsp+0x20],rax
    530c:	mov    rbx,rax
    530f:	mov    rdi,r13
    5312:	mov    rax,QWORD PTR [rdi+0x10]
    5316:	mov    rdx,QWORD PTR [rax+0x58]
    531a:	mov    QWORD PTR [rsp+0x28],rdx
    531f:	mov    rsi,QWORD PTR [rsp+0x78]
    5324:	call   5329 <botlish_fn_55+0x1c1>
			5325: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5329:	test   rax,rax
    532c:	je     557c <botlish_fn_55+0x414>
    5332:	mov    rcx,rbx
    5335:	mov    rdx,rcx
    5338:	and    rdx,rax
    533b:	test   rdx,0x1
    5342:	jne    5364 <botlish_fn_55+0x1fc>
    5348:	mov    rdx,rax
    534b:	mov    rsi,rbx
    534e:	mov    rdi,r13
    5351:	call   5356 <botlish_fn_55+0x1ee>
			5352: R_X86_64_PLT32	rt_value_eq-0x4
    5356:	test   rax,rax
    5359:	je     557c <botlish_fn_55+0x414>
    535f:	jmp    537a <botlish_fn_55+0x212>
    5364:	mov    rdx,rax
    5367:	mov    rsi,rbx
    536a:	mov    eax,0x2
    536f:	cmp    rsi,rdx
    5372:	cmove  rax,QWORD PTR [rip+0x26e]        # 55e8 <botlish_fn_55+0x480>
    537a:	mov    ebx,0x6
    537f:	cmp    rax,0x6
    5383:	je     539e <botlish_fn_55+0x236>
    5389:	mov    ebx,0x2
    538e:	mov    QWORD PTR [rsp],0x2
    5396:	mov    rsi,r12
    5399:	jmp    543d <botlish_fn_55+0x2d5>
    539e:	mov    rsi,r15
    53a1:	mov    rdi,r13
    53a4:	call   53a9 <botlish_fn_55+0x241>
			53a5: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53a9:	test   rax,rax
    53ac:	mov    QWORD PTR [rsp+0x88],rax
    53b4:	je     557c <botlish_fn_55+0x414>
    53ba:	mov    rsi,QWORD PTR [rsp+0x78]
    53bf:	mov    rdi,r13
    53c2:	call   53c7 <botlish_fn_55+0x25f>
			53c3: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53c7:	test   rax,rax
    53ca:	je     557c <botlish_fn_55+0x414>
    53d0:	mov    rcx,QWORD PTR [rsp+0x88]
    53d8:	mov    rdx,rcx
    53db:	and    rdx,rax
    53de:	test   rdx,0x1
    53e5:	jne    540c <botlish_fn_55+0x2a4>
    53eb:	mov    rdx,rax
    53ee:	mov    rsi,QWORD PTR [rsp+0x88]
    53f6:	mov    rdi,r13
    53f9:	call   53fe <botlish_fn_55+0x296>
			53fa: R_X86_64_PLT32	rt_value_eq-0x4
    53fe:	test   rax,rax
    5401:	je     557c <botlish_fn_55+0x414>
    5407:	jmp    5427 <botlish_fn_55+0x2bf>
    540c:	mov    rdx,rax
    540f:	mov    rsi,QWORD PTR [rsp+0x88]
    5417:	mov    eax,0x2
    541c:	cmp    rsi,rdx
    541f:	cmove  rax,QWORD PTR [rip+0x1c1]        # 55e8 <botlish_fn_55+0x480>
    5427:	cmp    rax,0x6
    542b:	je     5436 <botlish_fn_55+0x2ce>
    5431:	mov    ebx,0x2
    5436:	mov    QWORD PTR [rsp],rbx
    543a:	mov    rsi,r12
    543d:	mov    rdi,r13
    5440:	call   5445 <botlish_fn_55+0x2dd>
			5441: R_X86_64_PLT32	rt_list_len-0x4
    5445:	mov    QWORD PTR [rsp+0x18],rax
    544a:	mov    rdi,r13
    544d:	mov    r12,rax
    5450:	mov    rax,QWORD PTR [rdi+0x10]
    5454:	mov    rdx,QWORD PTR [rax+0x58]
    5458:	mov    QWORD PTR [rsp+0x20],rdx
    545d:	mov    rsi,r15
    5460:	call   5465 <botlish_fn_55+0x2fd>
			5461: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5465:	test   rax,rax
    5468:	je     557c <botlish_fn_55+0x414>
    546e:	mov    QWORD PTR [rsp+0x20],rax
    5473:	mov    rdi,r13
    5476:	mov    QWORD PTR [rsp+0x88],rax
    547e:	mov    rax,QWORD PTR [rdi+0x10]
    5482:	mov    rdx,QWORD PTR [rax+0x60]
    5486:	mov    QWORD PTR [rsp+0x28],rdx
    548b:	mov    rsi,r15
    548e:	call   5493 <botlish_fn_55+0x32b>
			548f: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5493:	test   rax,rax
    5496:	je     557c <botlish_fn_55+0x414>
    549c:	mov    QWORD PTR [rsp+0x28],rax
    54a1:	mov    rdi,r13
    54a4:	mov    QWORD PTR [rsp+0x80],rax
    54ac:	mov    rax,QWORD PTR [rdi+0x10]
    54b0:	mov    rdx,QWORD PTR [rax+0x68]
    54b4:	mov    QWORD PTR [rsp+0x30],rdx
    54b9:	mov    rsi,r15
    54bc:	call   54c1 <botlish_fn_55+0x359>
			54bd: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54c1:	test   rax,rax
    54c4:	je     557c <botlish_fn_55+0x414>
    54ca:	mov    QWORD PTR [rsp+0x8],rax
    54cf:	mov    rdi,r13
    54d2:	mov    r15,rax
    54d5:	mov    rax,QWORD PTR [rdi+0x10]
    54d9:	mov    rdx,QWORD PTR [rax+0x58]
    54dd:	mov    QWORD PTR [rsp+0x30],rdx
    54e2:	mov    rsi,r14
    54e5:	call   54ea <botlish_fn_55+0x382>
			54e6: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54ea:	test   rax,rax
    54ed:	je     557c <botlish_fn_55+0x414>
    54f3:	mov    QWORD PTR [rsp+0x30],rax
    54f8:	mov    rdi,r13
    54fb:	mov    QWORD PTR [rsp+0x78],rax
    5500:	mov    rax,QWORD PTR [rdi+0x10]
    5504:	mov    rdx,QWORD PTR [rax+0x68]
    5508:	mov    QWORD PTR [rsp+0x38],rdx
    550d:	mov    rsi,r14
    5510:	call   5515 <botlish_fn_55+0x3ad>
			5511: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5515:	test   rax,rax
    5518:	je     557c <botlish_fn_55+0x414>
    551e:	mov    QWORD PTR [rsp+0x10],rax
    5523:	lea    rdx,[rsp+0x40]
    5528:	mov    r9,r12
    552b:	mov    QWORD PTR [rsp+0x40],r9
    5530:	mov    rcx,QWORD PTR [rsp+0x88]
    5538:	mov    QWORD PTR [rsp+0x48],rcx
    553d:	mov    rcx,QWORD PTR [rsp+0x80]
    5545:	mov    QWORD PTR [rsp+0x50],rcx
    554a:	mov    rcx,r15
    554d:	mov    QWORD PTR [rsp+0x58],rcx
    5552:	mov    rcx,QWORD PTR [rsp+0x78]
    5557:	mov    QWORD PTR [rsp+0x60],rcx
    555c:	mov    QWORD PTR [rsp+0x68],rax
    5561:	mov    QWORD PTR [rsp+0x70],rbx
    5566:	mov    esi,0x7
    556b:	mov    rdi,r13
    556e:	call   5573 <botlish_fn_55+0x40b>
			556f: R_X86_64_PLT32	rt_list_new-0x4
    5573:	test   rax,rax
    5576:	jne    55b3 <botlish_fn_55+0x44b>
    557c:	xor    rax,rax
    557f:	mov    rbx,QWORD PTR [rsp+0x90]
    5587:	mov    r12,QWORD PTR [rsp+0x98]
    558f:	mov    r13,QWORD PTR [rsp+0xa0]
    5597:	mov    r14,QWORD PTR [rsp+0xa8]
    559f:	mov    r15,QWORD PTR [rsp+0xb0]
    55a7:	add    rsp,0xc0
    55ae:	mov    rsp,rbp
    55b1:	pop    rbp
    55b2:	ret
    55b3:	mov    rbx,QWORD PTR [rsp+0x90]
    55bb:	mov    r12,QWORD PTR [rsp+0x98]
    55c3:	mov    r13,QWORD PTR [rsp+0xa0]
    55cb:	mov    r14,QWORD PTR [rsp+0xa8]
    55d3:	mov    r15,QWORD PTR [rsp+0xb0]
    55db:	add    rsp,0xc0
    55e2:	mov    rsp,rbp
    55e5:	pop    rbp
    55e6:	ret
    55e7:	add    BYTE PTR [rsi],al
    55e9:	add    BYTE PTR [rax],al
    55eb:	add    BYTE PTR [rax],al
    55ed:	add    BYTE PTR [rax],al
	...

00000000000055f0 <botlish_entry_55: sample_checks<generic>>:
    55f0:	push   rbp
    55f1:	mov    rbp,rsp
    55f4:	call   55f9 <botlish_entry_55+0x9>
			55f5: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample_checks<generic>
    55f9:	mov    rsp,rbp
    55fc:	pop    rbp
    55fd:	ret

00000000000055fe <botlish_fn_56: sample<generic>>:
    55fe:	push   rbp
    55ff:	mov    rbp,rsp
    5602:	sub    rsp,0x10
    5606:	mov    QWORD PTR [rsp],rbx
    560a:	mov    rbx,rdi
    560d:	mov    rdi,rbx
    5610:	call   5615 <botlish_fn_56+0x17>
			5611: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample_checks<generic>
    5615:	test   rax,rax
    5618:	jne    56d1 <botlish_fn_56+0xd3>
    561e:	mov    rdi,rbx
    5621:	call   5626 <botlish_fn_56+0x28>
			5622: R_X86_64_PLT32	rt_declared_error-0x4
    5626:	cmp    rax,0x40000001
    562c:	je     56a2 <botlish_fn_56+0xa4>
    5632:	mov    rdi,rbx
    5635:	call   563a <botlish_fn_56+0x3c>
			5636: R_X86_64_PLT32	rt_declared_error-0x4
    563a:	cmp    rax,0x40000002
    5640:	je     567e <botlish_fn_56+0x80>
    5646:	mov    rdi,rbx
    5649:	call   564e <botlish_fn_56+0x50>
			564a: R_X86_64_PLT32	rt_declared_error-0x4
    564e:	cmp    rax,0x40000003
    5654:	jne    56c1 <botlish_fn_56+0xc3>
    565a:	mov    rdi,rbx
    565d:	call   5662 <botlish_fn_56+0x64>
			565e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5662:	xor    rdx,rdx
    5665:	mov    rdi,rbx
    5668:	mov    rsi,rdx
    566b:	call   5670 <botlish_fn_56+0x72>
			566c: R_X86_64_PLT32	rt_list_new-0x4
    5670:	test   rax,rax
    5673:	je     56c1 <botlish_fn_56+0xc3>
    5679:	jmp    56d1 <botlish_fn_56+0xd3>
    567e:	mov    rdi,rbx
    5681:	call   5686 <botlish_fn_56+0x88>
			5682: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5686:	xor    rdx,rdx
    5689:	mov    rdi,rbx
    568c:	mov    rsi,rdx
    568f:	call   5694 <botlish_fn_56+0x96>
			5690: R_X86_64_PLT32	rt_list_new-0x4
    5694:	test   rax,rax
    5697:	je     56c1 <botlish_fn_56+0xc3>
    569d:	jmp    56d1 <botlish_fn_56+0xd3>
    56a2:	mov    rdi,rbx
    56a5:	call   56aa <botlish_fn_56+0xac>
			56a6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    56aa:	xor    rdx,rdx
    56ad:	mov    rdi,rbx
    56b0:	mov    rsi,rdx
    56b3:	call   56b8 <botlish_fn_56+0xba>
			56b4: R_X86_64_PLT32	rt_list_new-0x4
    56b8:	test   rax,rax
    56bb:	jne    56d1 <botlish_fn_56+0xd3>
    56c1:	xor    rax,rax
    56c4:	mov    rbx,QWORD PTR [rsp]
    56c8:	add    rsp,0x10
    56cc:	mov    rsp,rbp
    56cf:	pop    rbp
    56d0:	ret
    56d1:	mov    rbx,QWORD PTR [rsp]
    56d5:	add    rsp,0x10
    56d9:	mov    rsp,rbp
    56dc:	pop    rbp
    56dd:	ret

00000000000056de <botlish_entry_56: sample<generic>>:
    56de:	push   rbp
    56df:	mov    rbp,rsp
    56e2:	call   56e7 <botlish_entry_56+0x9>
			56e3: R_X86_64_PLT32	botlish_fn_56-0x4 ; sample<generic>
    56e7:	mov    rsp,rbp
    56ea:	pop    rbp
    56eb:	ret

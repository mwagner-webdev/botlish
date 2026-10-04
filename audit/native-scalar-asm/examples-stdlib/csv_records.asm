; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23436  (per function: 45 453 453 453 81 81 81 357 412 412 412 278 278 278 81 365 430 585 1141 352 783 215 488 325 388 490 70 493 114 61 61 61 61 61 168 179 245 804 1248 429 380 439 977 766 817 665 1168 836 107 427 259 629 515 78 78 1222 301)
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
     f8f:	mov    r13,rdi
     f92:	mov    QWORD PTR [rsp],rsi
     f96:	mov    r12,rsi
     f99:	mov    QWORD PTR [rsp+0x8],rdx
     f9e:	mov    rbx,rdx
     fa1:	mov    rsi,r12
     fa4:	mov    rdi,r13
     fa7:	call   fac <botlish_fn_15+0x34>
			fa8: R_X86_64_PLT32	rt_str_len-0x4
     fac:	mov    rcx,rbx
     faf:	and    rcx,rax
     fb2:	mov    rdx,rax
     fb5:	test   rcx,0x1
     fbc:	jne    fe2 <botlish_fn_15+0x6a>
     fc2:	mov    rsi,rbx
     fc5:	mov    rdi,r13
     fc8:	call   fcd <botlish_fn_15+0x55>
			fc9: R_X86_64_PLT32	rt_int_cmp-0x4
     fcd:	mov    ecx,0x2
     fd2:	test   rax,rax
     fd5:	cmovge rcx,QWORD PTR [rip+0xd3]        # 10b0 <botlish_fn_15+0x138>
     fdd:	jmp    ff2 <botlish_fn_15+0x7a>
     fe2:	mov    ecx,0x2
     fe7:	cmp    rbx,rdx
     fea:	cmovge rcx,QWORD PTR [rip+0xbe]        # 10b0 <botlish_fn_15+0x138>
     ff2:	cmp    rcx,0x6
     ff6:	je     1086 <botlish_fn_15+0x10e>
     ffc:	mov    QWORD PTR [rsp+0x10],0x3
    1005:	test   rbx,0x1
    100c:	je     1024 <botlish_fn_15+0xac>
    1012:	mov    rcx,rbx
    1015:	add    rcx,0x2
    1019:	seto   al
    101c:	test   al,al
    101e:	je     1037 <botlish_fn_15+0xbf>
    1024:	mov    edx,0x3
    1029:	mov    rsi,rbx
    102c:	mov    rdi,r13
    102f:	call   1034 <botlish_fn_15+0xbc>
			1030: R_X86_64_PLT32	rt_int_add-0x4
    1034:	mov    rcx,rax
    1037:	mov    QWORD PTR [rsp+0x10],rcx
    103c:	mov    rdx,rbx
    103f:	mov    rsi,r12
    1042:	mov    rdi,r13
    1045:	call   104a <botlish_fn_15+0xd2>
			1046: R_X86_64_PLT32	rt_substr-0x4
    104a:	test   rax,rax
    104d:	jne    106e <botlish_fn_15+0xf6>
    1053:	xor    rax,rax
    1056:	mov    rbx,QWORD PTR [rsp+0x20]
    105b:	mov    r12,QWORD PTR [rsp+0x28]
    1060:	mov    r13,QWORD PTR [rsp+0x30]
    1065:	add    rsp,0x40
    1069:	mov    rsp,rbp
    106c:	pop    rbp
    106d:	ret
    106e:	mov    rbx,QWORD PTR [rsp+0x20]
    1073:	mov    r12,QWORD PTR [rsp+0x28]
    1078:	mov    r13,QWORD PTR [rsp+0x30]
    107d:	add    rsp,0x40
    1081:	mov    rsp,rbp
    1084:	pop    rbp
    1085:	ret
    1086:	mov    rdi,r13
    1089:	mov    rax,QWORD PTR [rdi+0x10]
    108d:	mov    rax,QWORD PTR [rax+0x8]
    1091:	mov    rbx,QWORD PTR [rsp+0x20]
    1096:	mov    r12,QWORD PTR [rsp+0x28]
    109b:	mov    r13,QWORD PTR [rsp+0x30]
    10a0:	add    rsp,0x40
    10a4:	mov    rsp,rbp
    10a7:	pop    rbp
    10a8:	ret
    10a9:	add    BYTE PTR [rax],al
    10ab:	add    BYTE PTR [rax],al
    10ad:	add    BYTE PTR [rax],al
    10af:	add    BYTE PTR [rsi],al
    10b1:	add    BYTE PTR [rax],al
    10b3:	add    BYTE PTR [rax],al
    10b5:	add    BYTE PTR [rax],al
	...

00000000000010b8 <botlish_entry_15: peek<str, int>>:
    10b8:	push   rbp
    10b9:	mov    rbp,rsp
    10bc:	mov    rsi,QWORD PTR [rdx]
    10bf:	mov    rdx,QWORD PTR [rdx+0x8]
    10c3:	call   10c8 <botlish_entry_15+0x10>
			10c4: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    10c8:	mov    rsp,rbp
    10cb:	pop    rbp
    10cc:	ret
    10cd:	add    BYTE PTR [rax],al
	...

00000000000010d0 <botlish_fn_16: peek<str, int>>:
    10d0:	push   rbp
    10d1:	mov    rbp,rsp
    10d4:	sub    rsp,0x50
    10d8:	mov    QWORD PTR [rsp+0x20],rbx
    10dd:	mov    QWORD PTR [rsp+0x28],r12
    10e2:	mov    QWORD PTR [rsp+0x30],r13
    10e7:	mov    QWORD PTR [rsp+0x38],r14
    10ec:	mov    QWORD PTR [rsp+0x40],r15
    10f1:	mov    r12,rcx
    10f4:	mov    r14,rdi
    10f7:	mov    QWORD PTR [rsp],rsi
    10fb:	mov    r13,rsi
    10fe:	mov    QWORD PTR [rsp+0x8],rdx
    1103:	mov    rbx,rdx
    1106:	mov    rsi,r13
    1109:	mov    rdi,r14
    110c:	call   1111 <botlish_fn_16+0x41>
			110d: R_X86_64_PLT32	rt_str_len-0x4
    1111:	mov    rcx,rbx
    1114:	and    rcx,rax
    1117:	mov    rdx,rax
    111a:	test   rcx,0x1
    1121:	jne    1147 <botlish_fn_16+0x77>
    1127:	mov    rsi,rbx
    112a:	mov    rdi,r14
    112d:	call   1132 <botlish_fn_16+0x62>
			112e: R_X86_64_PLT32	rt_int_cmp-0x4
    1132:	mov    ecx,0x2
    1137:	test   rax,rax
    113a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1260 <botlish_fn_16+0x190>
    1142:	jmp    1157 <botlish_fn_16+0x87>
    1147:	mov    ecx,0x2
    114c:	cmp    rbx,rdx
    114f:	cmovge rcx,QWORD PTR [rip+0x109]        # 1260 <botlish_fn_16+0x190>
    1157:	cmp    rcx,0x6
    115b:	je     121b <botlish_fn_16+0x14b>
    1161:	mov    QWORD PTR [rsp+0x10],0x3
    116a:	test   rbx,0x1
    1171:	je     1194 <botlish_fn_16+0xc4>
    1177:	mov    rax,rbx
    117a:	add    rax,0x2
    117e:	seto   cl
    1181:	test   cl,cl
    1183:	jne    1194 <botlish_fn_16+0xc4>
    1189:	mov    rdi,r14
    118c:	mov    r15,rax
    118f:	jmp    11aa <botlish_fn_16+0xda>
    1194:	mov    edx,0x3
    1199:	mov    rsi,rbx
    119c:	mov    rdi,r14
    119f:	call   11a4 <botlish_fn_16+0xd4>
			11a0: R_X86_64_PLT32	rt_int_add-0x4
    11a4:	mov    r15,rax
    11a7:	mov    rdi,r14
    11aa:	mov    rdi,r14
    11ad:	mov    rcx,r15
    11b0:	mov    rdx,rbx
    11b3:	mov    rsi,r13
    11b6:	call   11bb <botlish_fn_16+0xeb>
			11b7: R_X86_64_PLT32	rt_str_region_check-0x4
    11bb:	test   rax,rax
    11be:	jne    11e9 <botlish_fn_16+0x119>
    11c4:	xor    rax,rax
    11c7:	mov    rbx,QWORD PTR [rsp+0x20]
    11cc:	mov    r12,QWORD PTR [rsp+0x28]
    11d1:	mov    r13,QWORD PTR [rsp+0x30]
    11d6:	mov    r14,QWORD PTR [rsp+0x38]
    11db:	mov    r15,QWORD PTR [rsp+0x40]
    11e0:	add    rsp,0x50
    11e4:	mov    rsp,rbp
    11e7:	pop    rbp
    11e8:	ret
    11e9:	mov    rcx,r12
    11ec:	mov    QWORD PTR [rcx],rbx
    11ef:	mov    rax,r15
    11f2:	mov    QWORD PTR [rcx+0x8],rax
    11f6:	mov    rax,r13
    11f9:	mov    rbx,QWORD PTR [rsp+0x20]
    11fe:	mov    r12,QWORD PTR [rsp+0x28]
    1203:	mov    r13,QWORD PTR [rsp+0x30]
    1208:	mov    r14,QWORD PTR [rsp+0x38]
    120d:	mov    r15,QWORD PTR [rsp+0x40]
    1212:	add    rsp,0x50
    1216:	mov    rsp,rbp
    1219:	pop    rbp
    121a:	ret
    121b:	mov    rcx,r12
    121e:	mov    rdi,r14
    1221:	mov    rax,QWORD PTR [rdi+0x10]
    1225:	mov    rax,QWORD PTR [rax+0x8]
    1229:	mov    QWORD PTR [rcx],0x1
    1230:	mov    QWORD PTR [rcx+0x8],0x1
    1238:	mov    rbx,QWORD PTR [rsp+0x20]
    123d:	mov    r12,QWORD PTR [rsp+0x28]
    1242:	mov    r13,QWORD PTR [rsp+0x30]
    1247:	mov    r14,QWORD PTR [rsp+0x38]
    124c:	mov    r15,QWORD PTR [rsp+0x40]
    1251:	add    rsp,0x50
    1255:	mov    rsp,rbp
    1258:	pop    rbp
    1259:	ret
    125a:	add    BYTE PTR [rax],al
    125c:	add    BYTE PTR [rax],al
    125e:	add    BYTE PTR [rax],al
    1260:	(bad)
    1261:	add    BYTE PTR [rax],al
    1263:	add    BYTE PTR [rax],al
    1265:	add    BYTE PTR [rax],al
	...

0000000000001268 <botlish_entry_16: peek<str, int>>:
    1268:	push   rbp
    1269:	mov    rbp,rsp
    126c:	ud2

000000000000126e <botlish_fn_17: scan_unquoted<str, int, int>>:
    126e:	push   rbp
    126f:	mov    rbp,rsp
    1272:	sub    rsp,0x80
    1279:	mov    QWORD PTR [rsp+0x50],rbx
    127e:	mov    QWORD PTR [rsp+0x58],r12
    1283:	mov    QWORD PTR [rsp+0x60],r13
    1288:	mov    QWORD PTR [rsp+0x68],r14
    128d:	mov    QWORD PTR [rsp+0x70],r15
    1292:	mov    QWORD PTR [rsp+0x30],rdi
    1297:	mov    QWORD PTR [rsp+0x18],0x0
    12a0:	mov    QWORD PTR [rsp],rsi
    12a4:	mov    r15,rsi
    12a7:	mov    QWORD PTR [rsp+0x8],rdx
    12ac:	mov    r14,rdx
    12af:	mov    QWORD PTR [rsp+0x10],rcx
    12b4:	lea    r13,[rsp+0x20]
    12b9:	mov    QWORD PTR [rsp+0x38],rcx
    12be:	mov    rcx,r13
    12c1:	mov    rdx,QWORD PTR [rsp+0x38]
    12c6:	mov    rsi,r15
    12c9:	mov    rdi,QWORD PTR [rsp+0x30]
    12ce:	call   12d3 <botlish_fn_17+0x65>
			12cf: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    12d3:	mov    rsi,rax
    12d6:	mov    QWORD PTR [rsp+0x40],rax
    12db:	test   rax,rsi
    12de:	je     1438 <botlish_fn_17+0x1ca>
    12e4:	mov    rbx,QWORD PTR [rsp+0x20]
    12e9:	mov    r12,QWORD PTR [rsp+0x28]
    12ee:	mov    rdi,QWORD PTR [rsp+0x30]
    12f3:	mov    rcx,QWORD PTR [rdi+0x10]
    12f7:	mov    r8,QWORD PTR [rcx+0x8]
    12fb:	mov    rcx,r12
    12fe:	mov    rdx,rbx
    1301:	mov    rsi,QWORD PTR [rsp+0x40]
    1306:	call   130b <botlish_fn_17+0x9d>
			1307: R_X86_64_PLT32	rt_str_region_eq-0x4
    130b:	cmp    rax,0x6
    130f:	je     1350 <botlish_fn_17+0xe2>
    1315:	mov    rdi,QWORD PTR [rsp+0x30]
    131a:	mov    rax,QWORD PTR [rdi+0x10]
    131e:	mov    r8,QWORD PTR [rax+0x10]
    1322:	mov    rcx,r12
    1325:	mov    rdx,rbx
    1328:	mov    rsi,QWORD PTR [rsp+0x40]
    132d:	call   1332 <botlish_fn_17+0xc4>
			132e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1332:	cmp    rax,0x6
    1336:	je     1346 <botlish_fn_17+0xd8>
    133c:	mov    eax,0x2
    1341:	jmp    1355 <botlish_fn_17+0xe7>
    1346:	mov    eax,0x6
    134b:	jmp    1355 <botlish_fn_17+0xe7>
    1350:	mov    eax,0x6
    1355:	cmp    rax,0x6
    1359:	je     139a <botlish_fn_17+0x12c>
    135f:	mov    rdi,QWORD PTR [rsp+0x30]
    1364:	mov    rax,QWORD PTR [rdi+0x10]
    1368:	mov    r8,QWORD PTR [rax+0x18]
    136c:	mov    rcx,r12
    136f:	mov    rdx,rbx
    1372:	mov    rsi,QWORD PTR [rsp+0x40]
    1377:	call   137c <botlish_fn_17+0x10e>
			1378: R_X86_64_PLT32	rt_str_region_eq-0x4
    137c:	cmp    rax,0x6
    1380:	je     1390 <botlish_fn_17+0x122>
    1386:	mov    eax,0x2
    138b:	jmp    139f <botlish_fn_17+0x131>
    1390:	mov    eax,0x6
    1395:	jmp    139f <botlish_fn_17+0x131>
    139a:	mov    eax,0x6
    139f:	cmp    rax,0x6
    13a3:	je     141a <botlish_fn_17+0x1ac>
    13a9:	mov    QWORD PTR [rsp+0x18],0x3
    13b2:	mov    rsi,QWORD PTR [rsp+0x38]
    13b7:	test   rsi,0x1
    13be:	je     13e5 <botlish_fn_17+0x177>
    13c4:	mov    rsi,QWORD PTR [rsp+0x38]
    13c9:	mov    rax,rsi
    13cc:	add    rax,0x2
    13d0:	seto   sil
    13d4:	test   sil,sil
    13d7:	jne    13e5 <botlish_fn_17+0x177>
    13dd:	mov    rsi,r15
    13e0:	jmp    13fc <botlish_fn_17+0x18e>
    13e5:	mov    edx,0x3
    13ea:	mov    rsi,QWORD PTR [rsp+0x38]
    13ef:	mov    rdi,QWORD PTR [rsp+0x30]
    13f4:	call   13f9 <botlish_fn_17+0x18b>
			13f5: R_X86_64_PLT32	rt_int_add-0x4
    13f9:	mov    rsi,r15
    13fc:	mov    QWORD PTR [rsp],rsi
    1400:	mov    rdx,r14
    1403:	mov    QWORD PTR [rsp+0x8],rdx
    1408:	mov    QWORD PTR [rsp+0x10],rax
    140d:	mov    r15,rsi
    1410:	mov    QWORD PTR [rsp+0x38],rax
    1415:	jmp    12be <botlish_fn_17+0x50>
    141a:	mov    rdx,r14
    141d:	mov    rsi,r15
    1420:	mov    rdi,QWORD PTR [rsp+0x30]
    1425:	mov    rcx,QWORD PTR [rsp+0x38]
    142a:	call   142f <botlish_fn_17+0x1c1>
			142b: R_X86_64_PLT32	rt_substr-0x4
    142f:	test   rax,rax
    1432:	jne    1463 <botlish_fn_17+0x1f5>
    1438:	xor    rdx,rdx
    143b:	mov    rax,rdx
    143e:	mov    rbx,QWORD PTR [rsp+0x50]
    1443:	mov    r12,QWORD PTR [rsp+0x58]
    1448:	mov    r13,QWORD PTR [rsp+0x60]
    144d:	mov    r14,QWORD PTR [rsp+0x68]
    1452:	mov    r15,QWORD PTR [rsp+0x70]
    1457:	add    rsp,0x80
    145e:	mov    rsp,rbp
    1461:	pop    rbp
    1462:	ret
    1463:	mov    rdx,QWORD PTR [rsp+0x38]
    1468:	mov    rbx,QWORD PTR [rsp+0x50]
    146d:	mov    r12,QWORD PTR [rsp+0x58]
    1472:	mov    r13,QWORD PTR [rsp+0x60]
    1477:	mov    r14,QWORD PTR [rsp+0x68]
    147c:	mov    r15,QWORD PTR [rsp+0x70]
    1481:	add    rsp,0x80
    1488:	mov    rsp,rbp
    148b:	pop    rbp
    148c:	ret

000000000000148d <botlish_entry_17: scan_unquoted<str, int, int>>:
    148d:	push   rbp
    148e:	mov    rbp,rsp
    1491:	ud2

0000000000001493 <botlish_fn_18: scan_quoted<str, int, str>>:
    1493:	push   rbp
    1494:	mov    rbp,rsp
    1497:	sub    rsp,0xd0
    149e:	mov    QWORD PTR [rsp+0xa0],rbx
    14a6:	mov    QWORD PTR [rsp+0xa8],r12
    14ae:	mov    QWORD PTR [rsp+0xb0],r13
    14b6:	mov    QWORD PTR [rsp+0xb8],r14
    14be:	mov    QWORD PTR [rsp+0xc0],r15
    14c6:	mov    QWORD PTR [rsp+0x88],rdi
    14ce:	mov    QWORD PTR [rsp+0x18],0x0
    14d7:	mov    QWORD PTR [rsp+0x20],0x0
    14e0:	mov    QWORD PTR [rsp],rsi
    14e4:	mov    QWORD PTR [rsp+0x8],rdx
    14e9:	mov    QWORD PTR [rsp+0x10],rcx
    14ee:	mov    r13,rcx
    14f1:	lea    r14,[rsp+0x68]
    14f6:	lea    rbx,[rsp+0x28]
    14fb:	mov    r12,rsi
    14fe:	mov    QWORD PTR [rsp+0x90],rdx
    1506:	mov    rdx,QWORD PTR [rsp+0x90]
    150e:	mov    rsi,r12
    1511:	mov    rdi,QWORD PTR [rsp+0x88]
    1519:	call   151e <botlish_fn_18+0x8b>
			151a: R_X86_64_PLT32	botlish_fn_15-0x4 ; peek<str, int>
    151e:	test   rax,rax
    1521:	je     186a <botlish_fn_18+0x3d7>
    1527:	mov    QWORD PTR [rsp+0x18],rax
    152c:	mov    rsi,QWORD PTR [rax+0x8]
    1530:	mov    rcx,rax
    1533:	mov    rax,0xffffffffffffffff
    153a:	test   rsi,rsi
    153d:	jne    154b <botlish_fn_18+0xb8>
    1543:	mov    r15,rcx
    1546:	jmp    1576 <botlish_fn_18+0xe3>
    154b:	mov    r15,rcx
    154e:	movzx  rdi,BYTE PTR [r15+0x18]
    1553:	test   rdi,rdi
    1556:	jne    1571 <botlish_fn_18+0xde>
    155c:	mov    rsi,r15
    155f:	mov    rdi,QWORD PTR [rsp+0x88]
    1567:	call   156c <botlish_fn_18+0xd9>
			1568: R_X86_64_PLT32	rt_str_to_short-0x4
    156c:	jmp    1576 <botlish_fn_18+0xe3>
    1571:	movzx  rax,BYTE PTR [r15+0x19]
    1576:	cmp    rax,0x22
    157a:	je     163a <botlish_fn_18+0x1a7>
    1580:	mov    QWORD PTR [rsp+0x20],0x3
    1589:	mov    rsi,QWORD PTR [rsp+0x90]
    1591:	test   rsi,0x1
    1598:	je     15b8 <botlish_fn_18+0x125>
    159e:	mov    rax,rsi
    15a1:	add    rax,0x2
    15a5:	seto   cl
    15a8:	test   cl,cl
    15aa:	jne    15b8 <botlish_fn_18+0x125>
    15b0:	mov    rsi,rax
    15b3:	jmp    15cd <botlish_fn_18+0x13a>
    15b8:	mov    edx,0x3
    15bd:	mov    rdi,QWORD PTR [rsp+0x88]
    15c5:	call   15ca <botlish_fn_18+0x137>
			15c6: R_X86_64_PLT32	rt_int_add-0x4
    15ca:	mov    rsi,rax
    15cd:	mov    QWORD PTR [rsp+0x8],rsi
    15d2:	mov    QWORD PTR [rsp+0x90],rsi
    15da:	mov    QWORD PTR [rsp+0x68],0x0
    15e3:	mov    QWORD PTR [rsp+0x70],r13
    15e8:	mov    QWORD PTR [rsp+0x78],0x0
    15f1:	mov    QWORD PTR [rsp+0x80],r15
    15f9:	mov    esi,0x2
    15fe:	mov    edx,0x4
    1603:	mov    rcx,r14
    1606:	mov    rdi,QWORD PTR [rsp+0x88]
    160e:	call   1613 <botlish_fn_18+0x180>
			160f: R_X86_64_PLT32	rt_construct-0x4
    1613:	test   rax,rax
    1616:	je     186a <botlish_fn_18+0x3d7>
    161c:	mov    QWORD PTR [rsp],r12
    1620:	mov    rsi,QWORD PTR [rsp+0x90]
    1628:	mov    QWORD PTR [rsp+0x8],rsi
    162d:	mov    QWORD PTR [rsp+0x10],rax
    1632:	mov    r13,rax
    1635:	jmp    1506 <botlish_fn_18+0x73>
    163a:	mov    QWORD PTR [rsp+0x18],0x3
    1643:	mov    rsi,QWORD PTR [rsp+0x90]
    164b:	test   rsi,0x1
    1652:	je     1672 <botlish_fn_18+0x1df>
    1658:	mov    rsi,QWORD PTR [rsp+0x90]
    1660:	mov    rdx,rsi
    1663:	add    rdx,0x2
    1667:	seto   al
    166a:	test   al,al
    166c:	je     168f <botlish_fn_18+0x1fc>
    1672:	mov    edx,0x3
    1677:	mov    rsi,QWORD PTR [rsp+0x90]
    167f:	mov    rdi,QWORD PTR [rsp+0x88]
    1687:	call   168c <botlish_fn_18+0x1f9>
			1688: R_X86_64_PLT32	rt_int_add-0x4
    168c:	mov    rdx,rax
    168f:	mov    QWORD PTR [rsp+0x18],rdx
    1694:	mov    rcx,rbx
    1697:	mov    rsi,r12
    169a:	mov    rdi,QWORD PTR [rsp+0x88]
    16a2:	call   16a7 <botlish_fn_18+0x214>
			16a3: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    16a7:	test   rax,rax
    16aa:	mov    rsi,rax
    16ad:	je     186a <botlish_fn_18+0x3d7>
    16b3:	mov    rdx,QWORD PTR [rsp+0x28]
    16b8:	mov    rcx,QWORD PTR [rsp+0x30]
    16bd:	mov    rdi,QWORD PTR [rsp+0x88]
    16c5:	mov    rax,QWORD PTR [rdi+0x10]
    16c9:	mov    r8,QWORD PTR [rax+0x20]
    16cd:	call   16d2 <botlish_fn_18+0x23f>
			16ce: R_X86_64_PLT32	rt_str_region_eq-0x4
    16d2:	cmp    rax,0x6
    16d6:	je     17a8 <botlish_fn_18+0x315>
    16dc:	xor    rsi,rsi
    16df:	lea    rcx,[rsp+0x58]
    16e4:	mov    QWORD PTR [rsp+0x58],0x0
    16ed:	mov    QWORD PTR [rsp+0x60],r13
    16f2:	mov    edx,0x2
    16f7:	mov    rdi,QWORD PTR [rsp+0x88]
    16ff:	call   1704 <botlish_fn_18+0x271>
			1700: R_X86_64_PLT32	rt_construct-0x4
    1704:	test   rax,rax
    1707:	je     186a <botlish_fn_18+0x3d7>
    170d:	mov    QWORD PTR [rsp],rax
    1711:	mov    rbx,rax
    1714:	mov    QWORD PTR [rsp+0x10],0x3
    171d:	mov    rsi,QWORD PTR [rsp+0x90]
    1725:	test   rsi,0x1
    172c:	je     1754 <botlish_fn_18+0x2c1>
    1732:	mov    rsi,QWORD PTR [rsp+0x90]
    173a:	mov    rdx,rsi
    173d:	add    rdx,0x2
    1741:	seto   al
    1744:	test   al,al
    1746:	jne    1754 <botlish_fn_18+0x2c1>
    174c:	mov    rax,rbx
    174f:	jmp    1774 <botlish_fn_18+0x2e1>
    1754:	mov    edx,0x3
    1759:	mov    rsi,QWORD PTR [rsp+0x90]
    1761:	mov    rdi,QWORD PTR [rsp+0x88]
    1769:	call   176e <botlish_fn_18+0x2db>
			176a: R_X86_64_PLT32	rt_int_add-0x4
    176e:	mov    rdx,rax
    1771:	mov    rax,rbx
    1774:	mov    rbx,QWORD PTR [rsp+0xa0]
    177c:	mov    r12,QWORD PTR [rsp+0xa8]
    1784:	mov    r13,QWORD PTR [rsp+0xb0]
    178c:	mov    r14,QWORD PTR [rsp+0xb8]
    1794:	mov    r15,QWORD PTR [rsp+0xc0]
    179c:	add    rsp,0xd0
    17a3:	mov    rsp,rbp
    17a6:	pop    rbp
    17a7:	ret
    17a8:	mov    QWORD PTR [rsp+0x18],0x5
    17b1:	mov    rsi,QWORD PTR [rsp+0x90]
    17b9:	test   rsi,0x1
    17c0:	je     17f2 <botlish_fn_18+0x35f>
    17c6:	mov    rsi,QWORD PTR [rsp+0x90]
    17ce:	mov    rdi,rsi
    17d1:	add    rdi,0x4
    17d5:	seto   r9b
    17d9:	test   r9b,r9b
    17dc:	jne    17f2 <botlish_fn_18+0x35f>
    17e2:	mov    rsi,rdi
    17e5:	mov    QWORD PTR [rsp+0x90],rdi
    17ed:	jmp    1817 <botlish_fn_18+0x384>
    17f2:	mov    edx,0x5
    17f7:	mov    rsi,QWORD PTR [rsp+0x90]
    17ff:	mov    rdi,QWORD PTR [rsp+0x88]
    1807:	call   180c <botlish_fn_18+0x379>
			1808: R_X86_64_PLT32	rt_int_add-0x4
    180c:	mov    rsi,rax
    180f:	mov    QWORD PTR [rsp+0x90],rax
    1817:	mov    QWORD PTR [rsp+0x8],rsi
    181c:	mov    rdi,QWORD PTR [rsp+0x88]
    1824:	mov    rax,QWORD PTR [rdi+0x10]
    1828:	mov    rax,QWORD PTR [rax+0x20]
    182c:	mov    QWORD PTR [rsp+0x18],rax
    1831:	lea    rcx,[rsp+0x38]
    1836:	mov    QWORD PTR [rsp+0x38],0x0
    183f:	mov    QWORD PTR [rsp+0x40],r13
    1844:	mov    QWORD PTR [rsp+0x48],0x0
    184d:	mov    QWORD PTR [rsp+0x50],rax
    1852:	mov    esi,0x2
    1857:	mov    edx,0x4
    185c:	call   1861 <botlish_fn_18+0x3ce>
			185d: R_X86_64_PLT32	rt_construct-0x4
    1861:	test   rax,rax
    1864:	jne    18a4 <botlish_fn_18+0x411>
    186a:	xor    rdx,rdx
    186d:	mov    rax,rdx
    1870:	mov    rbx,QWORD PTR [rsp+0xa0]
    1878:	mov    r12,QWORD PTR [rsp+0xa8]
    1880:	mov    r13,QWORD PTR [rsp+0xb0]
    1888:	mov    r14,QWORD PTR [rsp+0xb8]
    1890:	mov    r15,QWORD PTR [rsp+0xc0]
    1898:	add    rsp,0xd0
    189f:	mov    rsp,rbp
    18a2:	pop    rbp
    18a3:	ret
    18a4:	mov    QWORD PTR [rsp],r12
    18a8:	mov    rsi,QWORD PTR [rsp+0x90]
    18b0:	mov    QWORD PTR [rsp+0x8],rsi
    18b5:	mov    QWORD PTR [rsp+0x10],rax
    18ba:	mov    r13,rax
    18bd:	jmp    1506 <botlish_fn_18+0x73>

00000000000018c2 <botlish_entry_18: scan_quoted<str, int, str>>:
    18c2:	push   rbp
    18c3:	mov    rbp,rsp
    18c6:	ud2

00000000000018c8 <botlish_fn_19: scan_field<str, int>>:
    18c8:	push   rbp
    18c9:	mov    rbp,rsp
    18cc:	sub    rsp,0x50
    18d0:	mov    QWORD PTR [rsp+0x30],rbx
    18d5:	mov    QWORD PTR [rsp+0x38],r12
    18da:	mov    QWORD PTR [rsp+0x40],r13
    18df:	mov    r12,rdi
    18e2:	mov    r13,rdx
    18e5:	mov    QWORD PTR [rsp+0x10],0x0
    18ee:	mov    QWORD PTR [rsp],rsi
    18f2:	mov    rbx,rsi
    18f5:	mov    QWORD PTR [rsp+0x8],rdx
    18fa:	lea    rcx,[rsp+0x18]
    18ff:	mov    rdx,r13
    1902:	mov    rsi,rbx
    1905:	mov    rdi,r12
    1908:	call   190d <botlish_fn_19+0x45>
			1909: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    190d:	test   rax,rax
    1910:	mov    rsi,rax
    1913:	je     19de <botlish_fn_19+0x116>
    1919:	mov    rdx,QWORD PTR [rsp+0x18]
    191e:	mov    rcx,QWORD PTR [rsp+0x20]
    1923:	mov    rdi,r12
    1926:	mov    rax,QWORD PTR [rdi+0x10]
    192a:	mov    r8,QWORD PTR [rax+0x20]
    192e:	call   1933 <botlish_fn_19+0x6b>
			192f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1933:	cmp    rax,0x6
    1937:	je     196f <botlish_fn_19+0xa7>
    193d:	mov    rcx,r13
    1940:	mov    rsi,rbx
    1943:	mov    rdi,r12
    1946:	mov    rdx,rcx
    1949:	call   194e <botlish_fn_19+0x86>
			194a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_unquoted<str, int, int>
    194e:	test   rax,rax
    1951:	je     19de <botlish_fn_19+0x116>
    1957:	mov    rbx,QWORD PTR [rsp+0x30]
    195c:	mov    r12,QWORD PTR [rsp+0x38]
    1961:	mov    r13,QWORD PTR [rsp+0x40]
    1966:	add    rsp,0x50
    196a:	mov    rsp,rbp
    196d:	pop    rbp
    196e:	ret
    196f:	mov    rcx,r13
    1972:	mov    QWORD PTR [rsp+0x10],0x3
    197b:	test   rcx,0x1
    1982:	jne    1990 <botlish_fn_19+0xc8>
    1988:	mov    r13,rcx
    198b:	jmp    19a5 <botlish_fn_19+0xdd>
    1990:	mov    rdx,rcx
    1993:	add    rdx,0x2
    1997:	mov    r13,rcx
    199a:	seto   al
    199d:	test   al,al
    199f:	je     19b8 <botlish_fn_19+0xf0>
    19a5:	mov    edx,0x3
    19aa:	mov    rsi,r13
    19ad:	mov    rdi,r12
    19b0:	call   19b5 <botlish_fn_19+0xed>
			19b1: R_X86_64_PLT32	rt_int_add-0x4
    19b5:	mov    rdx,rax
    19b8:	mov    QWORD PTR [rsp+0x8],rdx
    19bd:	mov    rdi,r12
    19c0:	mov    rax,QWORD PTR [rdi+0x10]
    19c4:	mov    rcx,QWORD PTR [rax+0x8]
    19c8:	mov    QWORD PTR [rsp+0x10],rcx
    19cd:	mov    rsi,rbx
    19d0:	call   19d5 <botlish_fn_19+0x10d>
			19d1: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_quoted<str, int, str>
    19d5:	test   rax,rax
    19d8:	jne    19fc <botlish_fn_19+0x134>
    19de:	xor    rdx,rdx
    19e1:	mov    rax,rdx
    19e4:	mov    rbx,QWORD PTR [rsp+0x30]
    19e9:	mov    r12,QWORD PTR [rsp+0x38]
    19ee:	mov    r13,QWORD PTR [rsp+0x40]
    19f3:	add    rsp,0x50
    19f7:	mov    rsp,rbp
    19fa:	pop    rbp
    19fb:	ret
    19fc:	mov    rbx,QWORD PTR [rsp+0x30]
    1a01:	mov    r12,QWORD PTR [rsp+0x38]
    1a06:	mov    r13,QWORD PTR [rsp+0x40]
    1a0b:	add    rsp,0x50
    1a0f:	mov    rsp,rbp
    1a12:	pop    rbp
    1a13:	ret

0000000000001a14 <botlish_entry_19: scan_field<str, int>>:
    1a14:	push   rbp
    1a15:	mov    rbp,rsp
    1a18:	ud2

0000000000001a1a <botlish_fn_20: scan_record_rest<str, int, mutarray, int>>:
    1a1a:	push   rbp
    1a1b:	mov    rbp,rsp
    1a1e:	sub    rsp,0x90
    1a25:	mov    QWORD PTR [rsp+0x60],rbx
    1a2a:	mov    QWORD PTR [rsp+0x68],r12
    1a2f:	mov    QWORD PTR [rsp+0x70],r13
    1a34:	mov    QWORD PTR [rsp+0x78],r14
    1a39:	mov    QWORD PTR [rsp+0x80],r15
    1a41:	mov    r15,rdi
    1a44:	mov    QWORD PTR [rsp+0x20],0x0
    1a4d:	mov    QWORD PTR [rsp],rsi
    1a51:	mov    QWORD PTR [rsp+0x8],rdx
    1a56:	mov    QWORD PTR [rsp+0x10],rcx
    1a5b:	mov    QWORD PTR [rsp+0x18],r8
    1a60:	lea    r12,[rsp+0x28]
    1a65:	mov    rbx,rsi
    1a68:	mov    QWORD PTR [rsp+0x38],rdx
    1a6d:	mov    QWORD PTR [rsp+0x40],rcx
    1a72:	mov    QWORD PTR [rsp+0x48],r8
    1a77:	mov    rcx,r12
    1a7a:	mov    rdx,QWORD PTR [rsp+0x38]
    1a7f:	mov    rsi,rbx
    1a82:	mov    rdi,r15
    1a85:	call   1a8a <botlish_fn_20+0x70>
			1a86: R_X86_64_PLT32	botlish_fn_16-0x4 ; peek<str, int>
    1a8a:	test   rax,rax
    1a8d:	mov    QWORD PTR [rsp+0x50],rax
    1a92:	je     1c56 <botlish_fn_20+0x23c>
    1a98:	mov    r14,QWORD PTR [rsp+0x28]
    1a9d:	mov    r13,QWORD PTR [rsp+0x30]
    1aa2:	mov    rdi,r15
    1aa5:	mov    rcx,QWORD PTR [rdi+0x10]
    1aa9:	mov    r8,QWORD PTR [rcx+0x10]
    1aad:	mov    rcx,r13
    1ab0:	mov    rdx,r14
    1ab3:	mov    rsi,QWORD PTR [rsp+0x50]
    1ab8:	call   1abd <botlish_fn_20+0xa3>
			1ab9: R_X86_64_PLT32	rt_str_region_eq-0x4
    1abd:	cmp    rax,0x6
    1ac1:	je     1bcf <botlish_fn_20+0x1b5>
    1ac7:	mov    rdi,r15
    1aca:	mov    rax,QWORD PTR [rdi+0x10]
    1ace:	mov    r8,QWORD PTR [rax+0x18]
    1ad2:	mov    rcx,r13
    1ad5:	mov    rdx,r14
    1ad8:	mov    rsi,QWORD PTR [rsp+0x50]
    1add:	call   1ae2 <botlish_fn_20+0xc8>
			1ade: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ae2:	cmp    rax,0x6
    1ae6:	je     1b34 <botlish_fn_20+0x11a>
    1aec:	mov    rdx,QWORD PTR [rsp+0x48]
    1af1:	mov    rsi,QWORD PTR [rsp+0x40]
    1af6:	mov    rdi,r15
    1af9:	call   1afe <botlish_fn_20+0xe4>
			1afa: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1afe:	test   rax,rax
    1b01:	je     1c56 <botlish_fn_20+0x23c>
    1b07:	mov    rdx,QWORD PTR [rsp+0x38]
    1b0c:	mov    rbx,QWORD PTR [rsp+0x60]
    1b11:	mov    r12,QWORD PTR [rsp+0x68]
    1b16:	mov    r13,QWORD PTR [rsp+0x70]
    1b1b:	mov    r14,QWORD PTR [rsp+0x78]
    1b20:	mov    r15,QWORD PTR [rsp+0x80]
    1b28:	add    rsp,0x90
    1b2f:	mov    rsp,rbp
    1b32:	pop    rbp
    1b33:	ret
    1b34:	mov    rdx,QWORD PTR [rsp+0x48]
    1b39:	mov    rsi,QWORD PTR [rsp+0x40]
    1b3e:	mov    rdi,r15
    1b41:	call   1b46 <botlish_fn_20+0x12c>
			1b42: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1b46:	test   rax,rax
    1b49:	je     1c56 <botlish_fn_20+0x23c>
    1b4f:	mov    QWORD PTR [rsp],rax
    1b53:	mov    rbx,rax
    1b56:	mov    QWORD PTR [rsp+0x10],0x3
    1b5f:	mov    rdx,QWORD PTR [rsp+0x38]
    1b64:	test   rdx,0x1
    1b6b:	je     1b8f <botlish_fn_20+0x175>
    1b71:	mov    rdx,QWORD PTR [rsp+0x38]
    1b76:	add    rdx,0x2
    1b7a:	seto   sil
    1b7e:	test   sil,sil
    1b81:	jne    1b8f <botlish_fn_20+0x175>
    1b87:	mov    rax,rbx
    1b8a:	jmp    1ba7 <botlish_fn_20+0x18d>
    1b8f:	mov    edx,0x3
    1b94:	mov    rsi,QWORD PTR [rsp+0x38]
    1b99:	mov    rdi,r15
    1b9c:	call   1ba1 <botlish_fn_20+0x187>
			1b9d: R_X86_64_PLT32	rt_int_add-0x4
    1ba1:	mov    rdx,rax
    1ba4:	mov    rax,rbx
    1ba7:	mov    rbx,QWORD PTR [rsp+0x60]
    1bac:	mov    r12,QWORD PTR [rsp+0x68]
    1bb1:	mov    r13,QWORD PTR [rsp+0x70]
    1bb6:	mov    r14,QWORD PTR [rsp+0x78]
    1bbb:	mov    r15,QWORD PTR [rsp+0x80]
    1bc3:	add    rsp,0x90
    1bca:	mov    rsp,rbp
    1bcd:	pop    rbp
    1bce:	ret
    1bcf:	mov    rsi,QWORD PTR [rsp+0x38]
    1bd4:	mov    edx,0x3
    1bd9:	mov    r13,rdx
    1bdc:	mov    QWORD PTR [rsp+0x20],0x3
    1be5:	test   rsi,0x1
    1bec:	je     1c04 <botlish_fn_20+0x1ea>
    1bf2:	mov    rdx,rsi
    1bf5:	add    rdx,0x2
    1bf9:	seto   al
    1bfc:	test   al,al
    1bfe:	je     1c12 <botlish_fn_20+0x1f8>
    1c04:	mov    rdx,r13
    1c07:	mov    rdi,r15
    1c0a:	call   1c0f <botlish_fn_20+0x1f5>
			1c0b: R_X86_64_PLT32	rt_int_add-0x4
    1c0f:	mov    rdx,rax
    1c12:	mov    QWORD PTR [rsp+0x8],rdx
    1c17:	mov    rsi,rbx
    1c1a:	mov    rdi,r15
    1c1d:	call   1c22 <botlish_fn_20+0x208>
			1c1e: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1c22:	test   rax,rax
    1c25:	je     1c56 <botlish_fn_20+0x23c>
    1c2b:	mov    QWORD PTR [rsp+0x8],rax
    1c30:	mov    rcx,rax
    1c33:	mov    QWORD PTR [rsp+0x20],rdx
    1c38:	mov    rsi,QWORD PTR [rsp+0x40]
    1c3d:	mov    r14,rdx
    1c40:	mov    rdx,QWORD PTR [rsp+0x48]
    1c45:	mov    rdi,r15
    1c48:	call   1c4d <botlish_fn_20+0x233>
			1c49: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_append<mutarray, int, str>
    1c4d:	test   rax,rax
    1c50:	jne    1c84 <botlish_fn_20+0x26a>
    1c56:	xor    rdx,rdx
    1c59:	mov    rax,rdx
    1c5c:	mov    rbx,QWORD PTR [rsp+0x60]
    1c61:	mov    r12,QWORD PTR [rsp+0x68]
    1c66:	mov    r13,QWORD PTR [rsp+0x70]
    1c6b:	mov    r14,QWORD PTR [rsp+0x78]
    1c70:	mov    r15,QWORD PTR [rsp+0x80]
    1c78:	add    rsp,0x90
    1c7f:	mov    rsp,rbp
    1c82:	pop    rbp
    1c83:	ret
    1c84:	mov    QWORD PTR [rsp+0x8],rax
    1c89:	mov    QWORD PTR [rsp+0x38],rax
    1c8e:	mov    QWORD PTR [rsp+0x10],0x3
    1c97:	mov    rdx,QWORD PTR [rsp+0x48]
    1c9c:	test   rdx,0x1
    1ca3:	jne    1cb6 <botlish_fn_20+0x29c>
    1ca9:	mov    rdx,r13
    1cac:	mov    rsi,QWORD PTR [rsp+0x48]
    1cb1:	jmp    1cd5 <botlish_fn_20+0x2bb>
    1cb6:	mov    rdx,QWORD PTR [rsp+0x48]
    1cbb:	mov    rax,rdx
    1cbe:	add    rax,0x2
    1cc2:	seto   cl
    1cc5:	test   cl,cl
    1cc7:	je     1cdd <botlish_fn_20+0x2c3>
    1ccd:	mov    rdx,r13
    1cd0:	mov    rsi,QWORD PTR [rsp+0x48]
    1cd5:	mov    rdi,r15
    1cd8:	call   1cdd <botlish_fn_20+0x2c3>
			1cd9: R_X86_64_PLT32	rt_int_add-0x4
    1cdd:	mov    QWORD PTR [rsp],rbx
    1ce1:	mov    rdx,r14
    1ce4:	mov    QWORD PTR [rsp+0x8],rdx
    1ce9:	mov    rcx,QWORD PTR [rsp+0x38]
    1cee:	mov    QWORD PTR [rsp+0x10],rcx
    1cf3:	mov    QWORD PTR [rsp+0x18],rax
    1cf8:	mov    QWORD PTR [rsp+0x38],rdx
    1cfd:	mov    QWORD PTR [rsp+0x40],rcx
    1d02:	mov    QWORD PTR [rsp+0x48],rax
    1d07:	jmp    1a77 <botlish_fn_20+0x5d>

0000000000001d0c <botlish_entry_20: scan_record_rest<str, int, mutarray, int>>:
    1d0c:	push   rbp
    1d0d:	mov    rbp,rsp
    1d10:	ud2

0000000000001d12 <botlish_fn_21: scan_record<str, int>>:
    1d12:	push   rbp
    1d13:	mov    rbp,rsp
    1d16:	sub    rsp,0x40
    1d1a:	mov    QWORD PTR [rsp+0x20],rbx
    1d1f:	mov    QWORD PTR [rsp+0x28],r12
    1d24:	mov    QWORD PTR [rsp+0x30],r14
    1d29:	mov    r14,rdi
    1d2c:	mov    QWORD PTR [rsp+0x10],0x0
    1d35:	mov    QWORD PTR [rsp+0x18],0x0
    1d3e:	mov    QWORD PTR [rsp],rsi
    1d42:	mov    r12,rsi
    1d45:	mov    QWORD PTR [rsp+0x8],rdx
    1d4a:	mov    rsi,r12
    1d4d:	mov    rdi,r14
    1d50:	call   1d55 <botlish_fn_21+0x43>
			1d51: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_field<str, int>
    1d55:	test   rax,rax
    1d58:	je     1dad <botlish_fn_21+0x9b>
    1d5e:	mov    QWORD PTR [rsp+0x8],rax
    1d63:	mov    rsi,rax
    1d66:	mov    QWORD PTR [rsp+0x10],rdx
    1d6b:	mov    rbx,rdx
    1d6e:	mov    rdi,r14
    1d71:	call   1d76 <botlish_fn_21+0x64>
			1d72: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<str>
    1d76:	test   rax,rax
    1d79:	je     1dad <botlish_fn_21+0x9b>
    1d7f:	mov    QWORD PTR [rsp+0x8],rax
    1d84:	mov    rcx,rax
    1d87:	mov    r8d,0x3
    1d8d:	mov    QWORD PTR [rsp+0x18],0x3
    1d96:	mov    rdx,rbx
    1d99:	mov    rsi,r12
    1d9c:	mov    rdi,r14
    1d9f:	call   1da4 <botlish_fn_21+0x92>
			1da0: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_record_rest<str, int, mutarray, int>
    1da4:	test   rax,rax
    1da7:	jne    1dcb <botlish_fn_21+0xb9>
    1dad:	xor    rdx,rdx
    1db0:	mov    rax,rdx
    1db3:	mov    rbx,QWORD PTR [rsp+0x20]
    1db8:	mov    r12,QWORD PTR [rsp+0x28]
    1dbd:	mov    r14,QWORD PTR [rsp+0x30]
    1dc2:	add    rsp,0x40
    1dc6:	mov    rsp,rbp
    1dc9:	pop    rbp
    1dca:	ret
    1dcb:	mov    rbx,QWORD PTR [rsp+0x20]
    1dd0:	mov    r12,QWORD PTR [rsp+0x28]
    1dd5:	mov    r14,QWORD PTR [rsp+0x30]
    1dda:	add    rsp,0x40
    1dde:	mov    rsp,rbp
    1de1:	pop    rbp
    1de2:	ret

0000000000001de3 <botlish_entry_21: scan_record<str, int>>:
    1de3:	push   rbp
    1de4:	mov    rbp,rsp
    1de7:	ud2
    1de9:	add    BYTE PTR [rax],al
    1deb:	add    BYTE PTR [rax],al
    1ded:	add    BYTE PTR [rax],al
	...

0000000000001df0 <botlish_fn_22: scan_records<str, int, mutarray, int>>:
    1df0:	push   rbp
    1df1:	mov    rbp,rsp
    1df4:	sub    rsp,0x60
    1df8:	mov    QWORD PTR [rsp+0x30],rbx
    1dfd:	mov    QWORD PTR [rsp+0x38],r12
    1e02:	mov    QWORD PTR [rsp+0x40],r13
    1e07:	mov    QWORD PTR [rsp+0x48],r14
    1e0c:	mov    QWORD PTR [rsp+0x50],r15
    1e11:	mov    r13,rdi
    1e14:	mov    QWORD PTR [rsp+0x20],0x0
    1e1d:	mov    QWORD PTR [rsp],rsi
    1e21:	mov    QWORD PTR [rsp+0x8],rdx
    1e26:	mov    r12,rdx
    1e29:	mov    QWORD PTR [rsp+0x10],rcx
    1e2e:	mov    QWORD PTR [rsp+0x18],r8
    1e33:	mov    rbx,rsi
    1e36:	mov    r14,r8
    1e39:	mov    r15,rcx
    1e3c:	mov    rsi,rbx
    1e3f:	mov    rdi,r13
    1e42:	call   1e47 <botlish_fn_22+0x57>
			1e43: R_X86_64_PLT32	rt_str_len-0x4
    1e47:	mov    rcx,r12
    1e4a:	and    rcx,rax
    1e4d:	mov    rdx,rax
    1e50:	test   rcx,0x1
    1e57:	jne    1e7d <botlish_fn_22+0x8d>
    1e5d:	mov    rsi,r12
    1e60:	mov    rdi,r13
    1e63:	call   1e68 <botlish_fn_22+0x78>
			1e64: R_X86_64_PLT32	rt_int_cmp-0x4
    1e68:	mov    ecx,0x2
    1e6d:	test   rax,rax
    1e70:	cmovge rcx,QWORD PTR [rip+0x128]        # 1fa0 <botlish_fn_22+0x1b0>
    1e78:	jmp    1e8d <botlish_fn_22+0x9d>
    1e7d:	mov    ecx,0x2
    1e82:	cmp    r12,rdx
    1e85:	cmovge rcx,QWORD PTR [rip+0x113]        # 1fa0 <botlish_fn_22+0x1b0>
    1e8d:	cmp    rcx,0x6
    1e91:	je     1f3c <botlish_fn_22+0x14c>
    1e97:	mov    rdx,r12
    1e9a:	mov    rsi,rbx
    1e9d:	mov    rdi,r13
    1ea0:	call   1ea5 <botlish_fn_22+0xb5>
			1ea1: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    1ea5:	test   rax,rax
    1ea8:	je     1f53 <botlish_fn_22+0x163>
    1eae:	mov    QWORD PTR [rsp+0x8],rax
    1eb3:	mov    rcx,rax
    1eb6:	mov    QWORD PTR [rsp+0x20],rdx
    1ebb:	mov    rsi,r15
    1ebe:	mov    r12,rdx
    1ec1:	mov    rdx,r14
    1ec4:	mov    rdi,r13
    1ec7:	call   1ecc <botlish_fn_22+0xdc>
			1ec8: R_X86_64_PLT32	botlish_fn_12-0x4 ; geo_append<mutarray, int, List[str]>
    1ecc:	test   rax,rax
    1ecf:	je     1f53 <botlish_fn_22+0x163>
    1ed5:	mov    QWORD PTR [rsp+0x8],rax
    1eda:	mov    r15,rax
    1edd:	mov    QWORD PTR [rsp+0x10],0x3
    1ee6:	mov    rsi,r14
    1ee9:	test   rsi,0x1
    1ef0:	je     1f0b <botlish_fn_22+0x11b>
    1ef6:	mov    rsi,r14
    1ef9:	mov    rax,rsi
    1efc:	add    rax,0x2
    1f00:	seto   cl
    1f03:	test   cl,cl
    1f05:	je     1f1b <botlish_fn_22+0x12b>
    1f0b:	mov    edx,0x3
    1f10:	mov    rsi,r14
    1f13:	mov    rdi,r13
    1f16:	call   1f1b <botlish_fn_22+0x12b>
			1f17: R_X86_64_PLT32	rt_int_add-0x4
    1f1b:	mov    QWORD PTR [rsp],rbx
    1f1f:	mov    rdx,r12
    1f22:	mov    QWORD PTR [rsp+0x8],rdx
    1f27:	mov    rcx,r15
    1f2a:	mov    QWORD PTR [rsp+0x10],rcx
    1f2f:	mov    QWORD PTR [rsp+0x18],rax
    1f34:	mov    r14,rax
    1f37:	jmp    1e3c <botlish_fn_22+0x4c>
    1f3c:	mov    rdx,r14
    1f3f:	mov    rsi,r15
    1f42:	mov    rdi,r13
    1f45:	call   1f4a <botlish_fn_22+0x15a>
			1f46: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    1f4a:	test   rax,rax
    1f4d:	jne    1f78 <botlish_fn_22+0x188>
    1f53:	xor    rax,rax
    1f56:	mov    rbx,QWORD PTR [rsp+0x30]
    1f5b:	mov    r12,QWORD PTR [rsp+0x38]
    1f60:	mov    r13,QWORD PTR [rsp+0x40]
    1f65:	mov    r14,QWORD PTR [rsp+0x48]
    1f6a:	mov    r15,QWORD PTR [rsp+0x50]
    1f6f:	add    rsp,0x60
    1f73:	mov    rsp,rbp
    1f76:	pop    rbp
    1f77:	ret
    1f78:	mov    rbx,QWORD PTR [rsp+0x30]
    1f7d:	mov    r12,QWORD PTR [rsp+0x38]
    1f82:	mov    r13,QWORD PTR [rsp+0x40]
    1f87:	mov    r14,QWORD PTR [rsp+0x48]
    1f8c:	mov    r15,QWORD PTR [rsp+0x50]
    1f91:	add    rsp,0x60
    1f95:	mov    rsp,rbp
    1f98:	pop    rbp
    1f99:	ret
    1f9a:	add    BYTE PTR [rax],al
    1f9c:	add    BYTE PTR [rax],al
    1f9e:	add    BYTE PTR [rax],al
    1fa0:	(bad)
    1fa1:	add    BYTE PTR [rax],al
    1fa3:	add    BYTE PTR [rax],al
    1fa5:	add    BYTE PTR [rax],al
	...

0000000000001fa8 <botlish_entry_22: scan_records<str, int, mutarray, int>>:
    1fa8:	push   rbp
    1fa9:	mov    rbp,rsp
    1fac:	mov    rsi,QWORD PTR [rdx]
    1faf:	mov    r9,QWORD PTR [rdx+0x8]
    1fb3:	mov    rcx,QWORD PTR [rdx+0x10]
    1fb7:	mov    r8,QWORD PTR [rdx+0x18]
    1fbb:	mov    rdx,r9
    1fbe:	call   1fc3 <botlish_entry_22+0x1b>
			1fbf: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    1fc3:	mov    rsp,rbp
    1fc6:	pop    rbp
    1fc7:	ret

0000000000001fc8 <botlish_fn_23: csv_parse<str>>:
    1fc8:	push   rbp
    1fc9:	mov    rbp,rsp
    1fcc:	sub    rsp,0x40
    1fd0:	mov    QWORD PTR [rsp+0x20],rbx
    1fd5:	mov    QWORD PTR [rsp+0x28],r12
    1fda:	mov    QWORD PTR [rsp+0x30],r13
    1fdf:	mov    rbx,rdi
    1fe2:	mov    QWORD PTR [rsp+0x8],0x0
    1feb:	mov    QWORD PTR [rsp+0x10],0x0
    1ff4:	mov    QWORD PTR [rsp+0x18],0x0
    1ffd:	mov    QWORD PTR [rsp],rsi
    2001:	mov    r12,rsi
    2004:	mov    rsi,r12
    2007:	mov    rdi,rbx
    200a:	call   200f <botlish_fn_23+0x47>
			200b: R_X86_64_PLT32	rt_str_len-0x4
    200f:	sar    rax,1
    2012:	test   rax,rax
    2015:	je     20a4 <botlish_fn_23+0xdc>
    201b:	mov    edx,0x1
    2020:	mov    QWORD PTR [rsp+0x8],0x1
    2029:	mov    rsi,r12
    202c:	mov    rdi,rbx
    202f:	call   2034 <botlish_fn_23+0x6c>
			2030: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_record<str, int>
    2034:	test   rax,rax
    2037:	je     20bb <botlish_fn_23+0xf3>
    203d:	mov    QWORD PTR [rsp+0x8],rax
    2042:	mov    rsi,rax
    2045:	mov    QWORD PTR [rsp+0x10],rdx
    204a:	mov    r13,rdx
    204d:	mov    rdi,rbx
    2050:	call   2055 <botlish_fn_23+0x8d>
			2051: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new<List[str]>
    2055:	test   rax,rax
    2058:	je     20bb <botlish_fn_23+0xf3>
    205e:	mov    QWORD PTR [rsp+0x8],rax
    2063:	mov    rcx,rax
    2066:	mov    r8d,0x3
    206c:	mov    QWORD PTR [rsp+0x18],0x3
    2075:	mov    rdx,r13
    2078:	mov    rsi,r12
    207b:	mov    rdi,rbx
    207e:	call   2083 <botlish_fn_23+0xbb>
			207f: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_records<str, int, mutarray, int>
    2083:	test   rax,rax
    2086:	je     20bb <botlish_fn_23+0xf3>
    208c:	mov    rbx,QWORD PTR [rsp+0x20]
    2091:	mov    r12,QWORD PTR [rsp+0x28]
    2096:	mov    r13,QWORD PTR [rsp+0x30]
    209b:	add    rsp,0x40
    209f:	mov    rsp,rbp
    20a2:	pop    rbp
    20a3:	ret
    20a4:	xor    rdx,rdx
    20a7:	mov    rdi,rbx
    20aa:	mov    rsi,rdx
    20ad:	call   20b2 <botlish_fn_23+0xea>
			20ae: R_X86_64_PLT32	rt_list_new-0x4
    20b2:	test   rax,rax
    20b5:	jne    20d6 <botlish_fn_23+0x10e>
    20bb:	xor    rax,rax
    20be:	mov    rbx,QWORD PTR [rsp+0x20]
    20c3:	mov    r12,QWORD PTR [rsp+0x28]
    20c8:	mov    r13,QWORD PTR [rsp+0x30]
    20cd:	add    rsp,0x40
    20d1:	mov    rsp,rbp
    20d4:	pop    rbp
    20d5:	ret
    20d6:	mov    rbx,QWORD PTR [rsp+0x20]
    20db:	mov    r12,QWORD PTR [rsp+0x28]
    20e0:	mov    r13,QWORD PTR [rsp+0x30]
    20e5:	add    rsp,0x40
    20e9:	mov    rsp,rbp
    20ec:	pop    rbp
    20ed:	ret

00000000000020ee <botlish_entry_23: csv_parse<str>>:
    20ee:	push   rbp
    20ef:	mov    rbp,rsp
    20f2:	mov    rsi,QWORD PTR [rdx]
    20f5:	call   20fa <botlish_entry_23+0xc>
			20f6: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    20fa:	mov    rsp,rbp
    20fd:	pop    rbp
    20fe:	ret
	...

0000000000002100 <botlish_fn_24: ht_fill_empty<mutarray, int, int>>:
    2100:	push   rbp
    2101:	mov    rbp,rsp
    2104:	sub    rsp,0x40
    2108:	mov    QWORD PTR [rsp+0x20],rbx
    210d:	mov    QWORD PTR [rsp+0x28],r12
    2112:	mov    QWORD PTR [rsp+0x30],r13
    2117:	mov    QWORD PTR [rsp+0x38],r14
    211c:	mov    r13,rdi
    211f:	mov    QWORD PTR [rsp],rsi
    2123:	mov    rbx,rsi
    2126:	mov    QWORD PTR [rsp+0x8],rdx
    212b:	mov    QWORD PTR [rsp+0x10],rcx
    2130:	mov    r12,rcx
    2133:	mov    rsi,rdx
    2136:	mov    rax,rsi
    2139:	and    rax,r12
    213c:	mov    r14,rsi
    213f:	test   rax,0x1
    2145:	jne    216e <botlish_fn_24+0x6e>
    214b:	mov    rdx,r12
    214e:	mov    rsi,r14
    2151:	mov    rdi,r13
    2154:	call   2159 <botlish_fn_24+0x59>
			2155: R_X86_64_PLT32	rt_int_cmp-0x4
    2159:	mov    ecx,0x2
    215e:	test   rax,rax
    2161:	cmovge rcx,QWORD PTR [rip+0xdf]        # 2248 <botlish_fn_24+0x148>
    2169:	jmp    2181 <botlish_fn_24+0x81>
    216e:	mov    ecx,0x2
    2173:	mov    rsi,r14
    2176:	cmp    rsi,r12
    2179:	cmovge rcx,QWORD PTR [rip+0xc7]        # 2248 <botlish_fn_24+0x148>
    2181:	cmp    rcx,0x6
    2185:	je     2226 <botlish_fn_24+0x126>
    218b:	mov    ecx,0x1
    2190:	mov    rdx,r14
    2193:	mov    rsi,rbx
    2196:	mov    rdi,r13
    2199:	call   219e <botlish_fn_24+0x9e>
			219a: R_X86_64_PLT32	rt_mutarray_set-0x4
    219e:	test   rax,rax
    21a1:	jne    21c7 <botlish_fn_24+0xc7>
    21a7:	xor    rax,rax
    21aa:	mov    rbx,QWORD PTR [rsp+0x20]
    21af:	mov    r12,QWORD PTR [rsp+0x28]
    21b4:	mov    r13,QWORD PTR [rsp+0x30]
    21b9:	mov    r14,QWORD PTR [rsp+0x38]
    21be:	add    rsp,0x40
    21c2:	mov    rsp,rbp
    21c5:	pop    rbp
    21c6:	ret
    21c7:	mov    QWORD PTR [rsp+0x18],0x3
    21d0:	mov    rsi,r14
    21d3:	test   rsi,0x1
    21da:	je     21fd <botlish_fn_24+0xfd>
    21e0:	mov    rsi,r14
    21e3:	mov    rcx,rsi
    21e6:	add    rcx,0x2
    21ea:	seto   al
    21ed:	test   al,al
    21ef:	jne    21fd <botlish_fn_24+0xfd>
    21f5:	mov    r14,rcx
    21f8:	jmp    2210 <botlish_fn_24+0x110>
    21fd:	mov    edx,0x3
    2202:	mov    rsi,r14
    2205:	mov    rdi,r13
    2208:	call   220d <botlish_fn_24+0x10d>
			2209: R_X86_64_PLT32	rt_int_add-0x4
    220d:	mov    r14,rax
    2210:	mov    QWORD PTR [rsp],rbx
    2214:	mov    rsi,r14
    2217:	mov    QWORD PTR [rsp+0x8],rsi
    221c:	mov    QWORD PTR [rsp+0x10],r12
    2221:	jmp    2136 <botlish_fn_24+0x36>
    2226:	mov    eax,0xa
    222b:	mov    rbx,QWORD PTR [rsp+0x20]
    2230:	mov    r12,QWORD PTR [rsp+0x28]
    2235:	mov    r13,QWORD PTR [rsp+0x30]
    223a:	mov    r14,QWORD PTR [rsp+0x38]
    223f:	add    rsp,0x40
    2243:	mov    rsp,rbp
    2246:	pop    rbp
    2247:	ret
    2248:	(bad)
    2249:	add    BYTE PTR [rax],al
    224b:	add    BYTE PTR [rax],al
    224d:	add    BYTE PTR [rax],al
	...

0000000000002250 <botlish_entry_24: ht_fill_empty<mutarray, int, int>>:
    2250:	push   rbp
    2251:	mov    rbp,rsp
    2254:	mov    rsi,QWORD PTR [rdx]
    2257:	mov    r8,QWORD PTR [rdx+0x8]
    225b:	mov    rcx,QWORD PTR [rdx+0x10]
    225f:	mov    rdx,r8
    2262:	call   2267 <botlish_entry_24+0x17>
			2263: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    2267:	mov    rsp,rbp
    226a:	pop    rbp
    226b:	ret

000000000000226c <botlish_fn_25: ht_alloc<int>>:
    226c:	push   rbp
    226d:	mov    rbp,rsp
    2270:	sub    rsp,0x60
    2274:	mov    QWORD PTR [rsp+0x30],rbx
    2279:	mov    QWORD PTR [rsp+0x38],r12
    227e:	mov    QWORD PTR [rsp+0x40],r13
    2283:	mov    QWORD PTR [rsp+0x48],r14
    2288:	mov    QWORD PTR [rsp+0x50],r15
    228d:	mov    r12,rdi
    2290:	mov    QWORD PTR [rsp+0x8],0x0
    2299:	mov    QWORD PTR [rsp+0x10],0x0
    22a2:	mov    QWORD PTR [rsp+0x18],0x0
    22ab:	mov    QWORD PTR [rsp],rsi
    22af:	mov    rbx,rsi
    22b2:	mov    rsi,rbx
    22b5:	mov    rdi,r12
    22b8:	call   22bd <botlish_fn_25+0x51>
			22b9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22bd:	test   rax,rax
    22c0:	je     234e <botlish_fn_25+0xe2>
    22c6:	mov    QWORD PTR [rsp+0x8],rax
    22cb:	mov    r13,rax
    22ce:	mov    edx,0x1
    22d3:	mov    QWORD PTR [rsp+0x10],0x1
    22dc:	mov    rcx,rbx
    22df:	mov    rsi,r13
    22e2:	mov    rdi,r12
    22e5:	call   22ea <botlish_fn_25+0x7e>
			22e6: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    22ea:	test   rax,rax
    22ed:	je     234e <botlish_fn_25+0xe2>
    22f3:	mov    rsi,rbx
    22f6:	mov    rdi,r12
    22f9:	call   22fe <botlish_fn_25+0x92>
			22fa: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    22fe:	test   rax,rax
    2301:	je     234e <botlish_fn_25+0xe2>
    2307:	mov    QWORD PTR [rsp+0x10],rax
    230c:	mov    rsi,rbx
    230f:	mov    r14,rax
    2312:	mov    rdi,r12
    2315:	call   231a <botlish_fn_25+0xae>
			2316: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    231a:	test   rax,rax
    231d:	je     234e <botlish_fn_25+0xe2>
    2323:	mov    QWORD PTR [rsp],rax
    2327:	mov    r15,rax
    232a:	mov    esi,0xb
    232f:	mov    QWORD PTR [rsp+0x18],0xb
    2338:	mov    rdi,r12
    233b:	call   2340 <botlish_fn_25+0xd4>
			233c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2340:	test   rax,rax
    2343:	mov    QWORD PTR [rsp+0x20],rax
    2348:	jne    2373 <botlish_fn_25+0x107>
    234e:	xor    rax,rax
    2351:	mov    rbx,QWORD PTR [rsp+0x30]
    2356:	mov    r12,QWORD PTR [rsp+0x38]
    235b:	mov    r13,QWORD PTR [rsp+0x40]
    2360:	mov    r14,QWORD PTR [rsp+0x48]
    2365:	mov    r15,QWORD PTR [rsp+0x50]
    236a:	add    rsp,0x60
    236e:	mov    rsp,rbp
    2371:	pop    rbp
    2372:	ret
    2373:	mov    ebx,0x1
    2378:	mov    rcx,r13
    237b:	mov    rdx,rbx
    237e:	mov    rsi,QWORD PTR [rsp+0x20]
    2383:	mov    rdi,r12
    2386:	call   238b <botlish_fn_25+0x11f>
			2387: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    238b:	mov    edx,0x3
    2390:	mov    rcx,r14
    2393:	mov    rsi,QWORD PTR [rsp+0x20]
    2398:	mov    rdi,r12
    239b:	call   23a0 <botlish_fn_25+0x134>
			239c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23a0:	mov    edx,0x5
    23a5:	mov    rcx,r15
    23a8:	mov    rsi,QWORD PTR [rsp+0x20]
    23ad:	mov    rdi,r12
    23b0:	call   23b5 <botlish_fn_25+0x149>
			23b1: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23b5:	mov    edx,0x7
    23ba:	mov    rcx,rbx
    23bd:	mov    rsi,QWORD PTR [rsp+0x20]
    23c2:	mov    rdi,r12
    23c5:	call   23ca <botlish_fn_25+0x15e>
			23c6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23ca:	mov    edx,0x9
    23cf:	mov    rcx,rbx
    23d2:	mov    rdi,r12
    23d5:	mov    rsi,QWORD PTR [rsp+0x20]
    23da:	call   23df <botlish_fn_25+0x173>
			23db: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    23df:	mov    rax,QWORD PTR [rsp+0x20]
    23e4:	mov    rbx,QWORD PTR [rsp+0x30]
    23e9:	mov    r12,QWORD PTR [rsp+0x38]
    23ee:	mov    r13,QWORD PTR [rsp+0x40]
    23f3:	mov    r14,QWORD PTR [rsp+0x48]
    23f8:	mov    r15,QWORD PTR [rsp+0x50]
    23fd:	add    rsp,0x60
    2401:	mov    rsp,rbp
    2404:	pop    rbp
    2405:	ret

0000000000002406 <botlish_entry_25: ht_alloc<int>>:
    2406:	push   rbp
    2407:	mov    rbp,rsp
    240a:	mov    rsi,QWORD PTR [rdx]
    240d:	call   2412 <botlish_entry_25+0xc>
			240e: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2412:	mov    rsp,rbp
    2415:	pop    rbp
    2416:	ret

0000000000002417 <botlish_fn_26: ht_new<generic>>:
    2417:	push   rbp
    2418:	mov    rbp,rsp
    241b:	sub    rsp,0x10
    241f:	mov    esi,0x11
    2424:	mov    QWORD PTR [rsp],0x11
    242c:	call   2431 <botlish_fn_26+0x1a>
			242d: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    2431:	test   rax,rax
    2434:	jne    2446 <botlish_fn_26+0x2f>
    243a:	xor    rax,rax
    243d:	add    rsp,0x10
    2441:	mov    rsp,rbp
    2444:	pop    rbp
    2445:	ret
    2446:	add    rsp,0x10
    244a:	mov    rsp,rbp
    244d:	pop    rbp
    244e:	ret

000000000000244f <botlish_entry_26: ht_new<generic>>:
    244f:	push   rbp
    2450:	mov    rbp,rsp
    2453:	call   2458 <botlish_entry_26+0x9>
			2454: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    2458:	mov    rsp,rbp
    245b:	pop    rbp
    245c:	ret
    245d:	add    BYTE PTR [rax],al
	...

0000000000002460 <botlish_fn_27: ht_capacity_for<int, int>>:
    2460:	push   rbp
    2461:	mov    rbp,rsp
    2464:	sub    rsp,0x50
    2468:	mov    QWORD PTR [rsp+0x20],rbx
    246d:	mov    QWORD PTR [rsp+0x28],r12
    2472:	mov    QWORD PTR [rsp+0x30],r13
    2477:	mov    QWORD PTR [rsp+0x38],r14
    247c:	mov    QWORD PTR [rsp+0x40],r15
    2481:	mov    r13,rdi
    2484:	mov    QWORD PTR [rsp],rdx
    2488:	mov    rbx,rsi
    248b:	or     rbx,0x1
    248f:	sar    rbx,1
    2492:	mov    r12,rsi
    2495:	mov    r14,rdx
    2498:	mov    rax,r12
    249b:	or     rax,0x1
    249f:	mov    QWORD PTR [rsp+0x8],rax
    24a4:	mov    QWORD PTR [rsp+0x10],0x7
    24ad:	mov    rax,rbx
    24b0:	imul   QWORD PTR [rip+0x159]        # 2610 <botlish_fn_27+0x1b0>
    24b7:	seto   cl
    24ba:	or     rax,0x1
    24be:	test   cl,cl
    24c0:	jne    24ce <botlish_fn_27+0x6e>
    24c6:	mov    rsi,rax
    24c9:	jmp    24e5 <botlish_fn_27+0x85>
    24ce:	mov    rsi,r12
    24d1:	or     rsi,0x1
    24d5:	mov    edx,0x7
    24da:	mov    rdi,r13
    24dd:	call   24e2 <botlish_fn_27+0x82>
			24de: R_X86_64_PLT32	rt_int_mul-0x4
    24e2:	mov    rsi,rax
    24e5:	mov    QWORD PTR [rsp+0x8],rsi
    24ea:	mov    r15,rsi
    24ed:	mov    QWORD PTR [rsp+0x10],0x5
    24f6:	mov    rsi,r14
    24f9:	test   rsi,0x1
    2500:	je     2530 <botlish_fn_27+0xd0>
    2506:	mov    rsi,r14
    2509:	mov    rax,rsi
    250c:	sar    rax,1
    250f:	imul   QWORD PTR [rip+0x102]        # 2618 <botlish_fn_27+0x1b8>
    2516:	seto   cl
    2519:	or     rax,0x1
    251d:	test   cl,cl
    251f:	jne    2530 <botlish_fn_27+0xd0>
    2525:	mov    rdx,rax
    2528:	mov    rsi,r15
    252b:	jmp    2546 <botlish_fn_27+0xe6>
    2530:	mov    edx,0x5
    2535:	mov    rsi,r14
    2538:	mov    rdi,r13
    253b:	call   2540 <botlish_fn_27+0xe0>
			253c: R_X86_64_PLT32	rt_int_mul-0x4
    2540:	mov    rdx,rax
    2543:	mov    rsi,r15
    2546:	mov    rax,rsi
    2549:	and    rax,rdx
    254c:	test   rax,0x1
    2552:	jne    2575 <botlish_fn_27+0x115>
    2558:	mov    rdi,r13
    255b:	call   2560 <botlish_fn_27+0x100>
			255c: R_X86_64_PLT32	rt_int_cmp-0x4
    2560:	mov    ecx,0x2
    2565:	test   rax,rax
    2568:	cmovle rcx,QWORD PTR [rip+0xa0]        # 2610 <botlish_fn_27+0x1b0>
    2570:	jmp    2585 <botlish_fn_27+0x125>
    2575:	mov    ecx,0x2
    257a:	cmp    rsi,rdx
    257d:	cmovle rcx,QWORD PTR [rip+0x8b]        # 2610 <botlish_fn_27+0x1b0>
    2585:	cmp    rcx,0x6
    2589:	je     25e5 <botlish_fn_27+0x185>
    258f:	mov    QWORD PTR [rsp+0x8],0x5
    2598:	mov    rsi,r14
    259b:	test   rsi,0x1
    25a2:	je     25c9 <botlish_fn_27+0x169>
    25a8:	mov    rsi,r14
    25ab:	mov    rax,rsi
    25ae:	sar    rax,1
    25b1:	imul   QWORD PTR [rip+0x60]        # 2618 <botlish_fn_27+0x1b8>
    25b8:	seto   sil
    25bc:	or     rax,0x1
    25c0:	test   sil,sil
    25c3:	je     25d9 <botlish_fn_27+0x179>
    25c9:	mov    edx,0x5
    25ce:	mov    rsi,r14
    25d1:	mov    rdi,r13
    25d4:	call   25d9 <botlish_fn_27+0x179>
			25d5: R_X86_64_PLT32	rt_int_mul-0x4
    25d9:	mov    QWORD PTR [rsp],rax
    25dd:	mov    r14,rax
    25e0:	jmp    2498 <botlish_fn_27+0x38>
    25e5:	mov    rax,r14
    25e8:	mov    rbx,QWORD PTR [rsp+0x20]
    25ed:	mov    r12,QWORD PTR [rsp+0x28]
    25f2:	mov    r13,QWORD PTR [rsp+0x30]
    25f7:	mov    r14,QWORD PTR [rsp+0x38]
    25fc:	mov    r15,QWORD PTR [rsp+0x40]
    2601:	add    rsp,0x50
    2605:	mov    rsp,rbp
    2608:	pop    rbp
    2609:	ret
    260a:	add    BYTE PTR [rax],al
    260c:	add    BYTE PTR [rax],al
    260e:	add    BYTE PTR [rax],al
    2610:	(bad)
    2611:	add    BYTE PTR [rax],al
    2613:	add    BYTE PTR [rax],al
    2615:	add    BYTE PTR [rax],al
    2617:	add    BYTE PTR [rax+rax*1],al
    261a:	add    BYTE PTR [rax],al
    261c:	add    BYTE PTR [rax],al
	...

0000000000002620 <botlish_entry_27: ht_capacity_for<int, int>>:
    2620:	push   rbp
    2621:	mov    rbp,rsp
    2624:	mov    rsi,QWORD PTR [rdx]
    2627:	mov    rdx,QWORD PTR [rdx+0x8]
    262b:	call   2630 <botlish_entry_27+0x10>
			262c: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    2630:	mov    rsp,rbp
    2633:	pop    rbp
    2634:	ret

0000000000002635 <botlish_fn_28: ht_new_sized<int>>:
    2635:	push   rbp
    2636:	mov    rbp,rsp
    2639:	sub    rsp,0x20
    263d:	mov    QWORD PTR [rsp+0x10],r12
    2642:	mov    r12,rdi
    2645:	mov    QWORD PTR [rsp],rsi
    2649:	mov    edx,0x11
    264e:	mov    QWORD PTR [rsp+0x8],0x11
    2657:	mov    rdi,r12
    265a:	call   265f <botlish_fn_28+0x2a>
			265b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_capacity_for<int, int>
    265f:	mov    QWORD PTR [rsp],rax
    2663:	mov    rsi,rax
    2666:	mov    rdi,r12
    2669:	call   266e <botlish_fn_28+0x39>
			266a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_alloc<int>
    266e:	test   rax,rax
    2671:	jne    2688 <botlish_fn_28+0x53>
    2677:	xor    rax,rax
    267a:	mov    r12,QWORD PTR [rsp+0x10]
    267f:	add    rsp,0x20
    2683:	mov    rsp,rbp
    2686:	pop    rbp
    2687:	ret
    2688:	mov    r12,QWORD PTR [rsp+0x10]
    268d:	add    rsp,0x20
    2691:	mov    rsp,rbp
    2694:	pop    rbp
    2695:	ret

0000000000002696 <botlish_entry_28: ht_new_sized<int>>:
    2696:	push   rbp
    2697:	mov    rbp,rsp
    269a:	mov    rsi,QWORD PTR [rdx]
    269d:	call   26a2 <botlish_entry_28+0xc>
			269e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    26a2:	mov    rsp,rbp
    26a5:	pop    rbp
    26a6:	ret

00000000000026a7 <botlish_fn_29: ht_controls<mutarray>>:
    26a7:	push   rbp
    26a8:	mov    rbp,rsp
    26ab:	mov    edx,0x1
    26b0:	call   26b5 <botlish_fn_29+0xe>
			26b1: R_X86_64_PLT32	rt_mutarray_get-0x4
    26b5:	test   rax,rax
    26b8:	jne    26c6 <botlish_fn_29+0x1f>
    26be:	xor    rax,rax
    26c1:	mov    rsp,rbp
    26c4:	pop    rbp
    26c5:	ret
    26c6:	mov    rsp,rbp
    26c9:	pop    rbp
    26ca:	ret

00000000000026cb <botlish_entry_29: ht_controls<mutarray>>:
    26cb:	push   rbp
    26cc:	mov    rbp,rsp
    26cf:	mov    rsi,QWORD PTR [rdx]
    26d2:	call   26d7 <botlish_entry_29+0xc>
			26d3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    26d7:	mov    rsp,rbp
    26da:	pop    rbp
    26db:	ret

00000000000026dc <botlish_fn_30: ht_keys<mutarray>>:
    26dc:	push   rbp
    26dd:	mov    rbp,rsp
    26e0:	mov    edx,0x3
    26e5:	call   26ea <botlish_fn_30+0xe>
			26e6: R_X86_64_PLT32	rt_mutarray_get-0x4
    26ea:	test   rax,rax
    26ed:	jne    26fb <botlish_fn_30+0x1f>
    26f3:	xor    rax,rax
    26f6:	mov    rsp,rbp
    26f9:	pop    rbp
    26fa:	ret
    26fb:	mov    rsp,rbp
    26fe:	pop    rbp
    26ff:	ret

0000000000002700 <botlish_entry_30: ht_keys<mutarray>>:
    2700:	push   rbp
    2701:	mov    rbp,rsp
    2704:	mov    rsi,QWORD PTR [rdx]
    2707:	call   270c <botlish_entry_30+0xc>
			2708: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    270c:	mov    rsp,rbp
    270f:	pop    rbp
    2710:	ret

0000000000002711 <botlish_fn_31: ht_values<mutarray>>:
    2711:	push   rbp
    2712:	mov    rbp,rsp
    2715:	mov    edx,0x5
    271a:	call   271f <botlish_fn_31+0xe>
			271b: R_X86_64_PLT32	rt_mutarray_get-0x4
    271f:	test   rax,rax
    2722:	jne    2730 <botlish_fn_31+0x1f>
    2728:	xor    rax,rax
    272b:	mov    rsp,rbp
    272e:	pop    rbp
    272f:	ret
    2730:	mov    rsp,rbp
    2733:	pop    rbp
    2734:	ret

0000000000002735 <botlish_entry_31: ht_values<mutarray>>:
    2735:	push   rbp
    2736:	mov    rbp,rsp
    2739:	mov    rsi,QWORD PTR [rdx]
    273c:	call   2741 <botlish_entry_31+0xc>
			273d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    2741:	mov    rsp,rbp
    2744:	pop    rbp
    2745:	ret

0000000000002746 <botlish_fn_32: ht_size<mutarray>>:
    2746:	push   rbp
    2747:	mov    rbp,rsp
    274a:	mov    edx,0x7
    274f:	call   2754 <botlish_fn_32+0xe>
			2750: R_X86_64_PLT32	rt_mutarray_get-0x4
    2754:	test   rax,rax
    2757:	jne    2765 <botlish_fn_32+0x1f>
    275d:	xor    rax,rax
    2760:	mov    rsp,rbp
    2763:	pop    rbp
    2764:	ret
    2765:	mov    rsp,rbp
    2768:	pop    rbp
    2769:	ret

000000000000276a <botlish_entry_32: ht_size<mutarray>>:
    276a:	push   rbp
    276b:	mov    rbp,rsp
    276e:	mov    rsi,QWORD PTR [rdx]
    2771:	call   2776 <botlish_entry_32+0xc>
			2772: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    2776:	mov    rsp,rbp
    2779:	pop    rbp
    277a:	ret

000000000000277b <botlish_fn_33: ht_tombstones<mutarray>>:
    277b:	push   rbp
    277c:	mov    rbp,rsp
    277f:	mov    edx,0x9
    2784:	call   2789 <botlish_fn_33+0xe>
			2785: R_X86_64_PLT32	rt_mutarray_get-0x4
    2789:	test   rax,rax
    278c:	jne    279a <botlish_fn_33+0x1f>
    2792:	xor    rax,rax
    2795:	mov    rsp,rbp
    2798:	pop    rbp
    2799:	ret
    279a:	mov    rsp,rbp
    279d:	pop    rbp
    279e:	ret

000000000000279f <botlish_entry_33: ht_tombstones<mutarray>>:
    279f:	push   rbp
    27a0:	mov    rbp,rsp
    27a3:	mov    rsi,QWORD PTR [rdx]
    27a6:	call   27ab <botlish_entry_33+0xc>
			27a7: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    27ab:	mov    rsp,rbp
    27ae:	pop    rbp
    27af:	ret

00000000000027b0 <botlish_fn_34: ht_capacity<mutarray>>:
    27b0:	push   rbp
    27b1:	mov    rbp,rsp
    27b4:	sub    rsp,0x10
    27b8:	mov    QWORD PTR [rsp],rbx
    27bc:	mov    rbx,rdi
    27bf:	mov    rdi,rbx
    27c2:	call   27c7 <botlish_fn_34+0x17>
			27c3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    27c7:	test   rax,rax
    27ca:	je     2814 <botlish_fn_34+0x64>
    27d0:	xor    r8d,r8d
    27d3:	test   rax,0x7
    27d9:	je     27e7 <botlish_fn_34+0x37>
    27df:	mov    rsi,rax
    27e2:	jmp    27f6 <botlish_fn_34+0x46>
    27e7:	movzx  rcx,BYTE PTR [rax]
    27eb:	mov    rsi,rax
    27ee:	rex cmp cl,0x8
    27f2:	sete   r8b
    27f6:	test   r8b,r8b
    27f9:	jne    2824 <botlish_fn_34+0x74>
    27ff:	mov    rdi,rbx
    2802:	mov    rax,QWORD PTR [rdi+0x10]
    2806:	mov    rcx,QWORD PTR [rax+0x28]
    280a:	mov    edx,0x8
    280f:	call   2814 <botlish_fn_34+0x64>
			2810: R_X86_64_PLT32	rt_type_error-0x4
    2814:	xor    rax,rax
    2817:	mov    rbx,QWORD PTR [rsp]
    281b:	add    rsp,0x10
    281f:	mov    rsp,rbp
    2822:	pop    rbp
    2823:	ret
    2824:	mov    rdi,rbx
    2827:	call   282c <botlish_fn_34+0x7c>
			2828: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    282c:	mov    rbx,QWORD PTR [rsp]
    2830:	add    rsp,0x10
    2834:	mov    rsp,rbp
    2837:	pop    rbp
    2838:	ret

0000000000002839 <botlish_entry_34: ht_capacity<mutarray>>:
    2839:	push   rbp
    283a:	mov    rbp,rsp
    283d:	mov    rsi,QWORD PTR [rdx]
    2840:	call   2845 <botlish_entry_34+0xc>
			2841: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2845:	mov    rsp,rbp
    2848:	pop    rbp
    2849:	ret

000000000000284a <botlish_fn_35: ht_probe_start<mutarray, str>>:
    284a:	push   rbp
    284b:	mov    rbp,rsp
    284e:	sub    rsp,0x20
    2852:	mov    QWORD PTR [rsp],r12
    2856:	mov    QWORD PTR [rsp+0x8],r13
    285b:	mov    QWORD PTR [rsp+0x10],r14
    2860:	mov    r12,rdi
    2863:	mov    r14,rsi
    2866:	mov    rsi,rdx
    2869:	mov    rdi,r12
    286c:	call   2871 <botlish_fn_35+0x27>
			286d: R_X86_64_PLT32	rt_hash-0x4
    2871:	test   rax,rax
    2874:	mov    r13,rax
    2877:	je     28a8 <botlish_fn_35+0x5e>
    287d:	mov    rsi,r14
    2880:	mov    rdi,r12
    2883:	call   2888 <botlish_fn_35+0x3e>
			2884: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2888:	test   rax,rax
    288b:	mov    rdx,rax
    288e:	je     28a8 <botlish_fn_35+0x5e>
    2894:	mov    rsi,r13
    2897:	mov    rdi,r12
    289a:	call   289f <botlish_fn_35+0x55>
			289b: R_X86_64_PLT32	rt_int_mod-0x4
    289f:	test   rax,rax
    28a2:	jne    28c2 <botlish_fn_35+0x78>
    28a8:	xor    rax,rax
    28ab:	mov    r12,QWORD PTR [rsp]
    28af:	mov    r13,QWORD PTR [rsp+0x8]
    28b4:	mov    r14,QWORD PTR [rsp+0x10]
    28b9:	add    rsp,0x20
    28bd:	mov    rsp,rbp
    28c0:	pop    rbp
    28c1:	ret
    28c2:	mov    r12,QWORD PTR [rsp]
    28c6:	mov    r13,QWORD PTR [rsp+0x8]
    28cb:	mov    r14,QWORD PTR [rsp+0x10]
    28d0:	add    rsp,0x20
    28d4:	mov    rsp,rbp
    28d7:	pop    rbp
    28d8:	ret

00000000000028d9 <botlish_entry_35: ht_probe_start<mutarray, str>>:
    28d9:	push   rbp
    28da:	mov    rbp,rsp
    28dd:	mov    rsi,QWORD PTR [rdx]
    28e0:	mov    rdx,QWORD PTR [rdx+0x8]
    28e4:	call   28e9 <botlish_entry_35+0x10>
			28e5: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    28e9:	mov    rsp,rbp
    28ec:	pop    rbp
    28ed:	ret

00000000000028ee <botlish_fn_36: ht_probe_next<mutarray, int>>:
    28ee:	push   rbp
    28ef:	mov    rbp,rsp
    28f2:	sub    rsp,0x40
    28f6:	mov    QWORD PTR [rsp+0x20],rbx
    28fb:	mov    QWORD PTR [rsp+0x28],r12
    2900:	mov    QWORD PTR [rsp+0x30],r13
    2905:	mov    r13,rdi
    2908:	mov    QWORD PTR [rsp],rsi
    290c:	mov    rbx,rsi
    290f:	mov    QWORD PTR [rsp+0x8],rdx
    2914:	mov    QWORD PTR [rsp+0x10],0x3
    291d:	test   rdx,0x1
    2924:	jne    2932 <botlish_fn_36+0x44>
    292a:	mov    rsi,rdx
    292d:	jmp    2952 <botlish_fn_36+0x64>
    2932:	mov    rsi,rdx
    2935:	add    rsi,0x2
    2939:	mov    r12,rsi
    293c:	mov    rsi,rdx
    293f:	seto   al
    2942:	test   al,al
    2944:	jne    2952 <botlish_fn_36+0x64>
    294a:	mov    rsi,rbx
    294d:	jmp    2965 <botlish_fn_36+0x77>
    2952:	mov    edx,0x3
    2957:	mov    rdi,r13
    295a:	call   295f <botlish_fn_36+0x71>
			295b: R_X86_64_PLT32	rt_int_add-0x4
    295f:	mov    rsi,rbx
    2962:	mov    r12,rax
    2965:	mov    rdi,r13
    2968:	call   296d <botlish_fn_36+0x7f>
			2969: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    296d:	test   rax,rax
    2970:	mov    rdx,rax
    2973:	je     298d <botlish_fn_36+0x9f>
    2979:	mov    rsi,r12
    297c:	mov    rdi,r13
    297f:	call   2984 <botlish_fn_36+0x96>
			2980: R_X86_64_PLT32	rt_int_mod-0x4
    2984:	test   rax,rax
    2987:	jne    29a8 <botlish_fn_36+0xba>
    298d:	xor    rax,rax
    2990:	mov    rbx,QWORD PTR [rsp+0x20]
    2995:	mov    r12,QWORD PTR [rsp+0x28]
    299a:	mov    r13,QWORD PTR [rsp+0x30]
    299f:	add    rsp,0x40
    29a3:	mov    rsp,rbp
    29a6:	pop    rbp
    29a7:	ret
    29a8:	mov    rbx,QWORD PTR [rsp+0x20]
    29ad:	mov    r12,QWORD PTR [rsp+0x28]
    29b2:	mov    r13,QWORD PTR [rsp+0x30]
    29b7:	add    rsp,0x40
    29bb:	mov    rsp,rbp
    29be:	pop    rbp
    29bf:	ret

00000000000029c0 <botlish_entry_36: ht_probe_next<mutarray, int>>:
    29c0:	push   rbp
    29c1:	mov    rbp,rsp
    29c4:	mov    rsi,QWORD PTR [rdx]
    29c7:	mov    rdx,QWORD PTR [rdx+0x8]
    29cb:	call   29d0 <botlish_entry_36+0x10>
			29cc: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    29d0:	mov    rsp,rbp
    29d3:	pop    rbp
    29d4:	ret
    29d5:	add    BYTE PTR [rax],al
	...

00000000000029d8 <botlish_fn_37: ht_find_get<mutarray, str, int>>:
    29d8:	push   rbp
    29d9:	mov    rbp,rsp
    29dc:	sub    rsp,0x50
    29e0:	mov    QWORD PTR [rsp+0x20],rbx
    29e5:	mov    QWORD PTR [rsp+0x28],r12
    29ea:	mov    QWORD PTR [rsp+0x30],r13
    29ef:	mov    QWORD PTR [rsp+0x38],r14
    29f4:	mov    QWORD PTR [rsp+0x40],r15
    29f9:	mov    r14,rdi
    29fc:	mov    QWORD PTR [rsp],rsi
    2a00:	mov    QWORD PTR [rsp+0x8],rdx
    2a05:	mov    r13,rdx
    2a08:	mov    QWORD PTR [rsp+0x10],rcx
    2a0d:	mov    r12,rsi
    2a10:	mov    r15,rcx
    2a13:	mov    rsi,r12
    2a16:	mov    rdi,r14
    2a19:	call   2a1e <botlish_fn_37+0x46>
			2a1a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2a1e:	test   rax,rax
    2a21:	je     2c20 <botlish_fn_37+0x248>
    2a27:	xor    ecx,ecx
    2a29:	test   rax,0x7
    2a2f:	je     2a3d <botlish_fn_37+0x65>
    2a35:	mov    rsi,rax
    2a38:	jmp    2a4b <botlish_fn_37+0x73>
    2a3d:	movzx  rcx,BYTE PTR [rax]
    2a41:	mov    rsi,rax
    2a44:	rex cmp cl,0x8
    2a48:	sete   cl
    2a4b:	test   cl,cl
    2a4d:	jne    2a6d <botlish_fn_37+0x95>
    2a53:	mov    rdi,r14
    2a56:	mov    rdx,QWORD PTR [rdi+0x10]
    2a5a:	mov    rcx,QWORD PTR [rdx+0x30]
    2a5e:	mov    edx,0x8
    2a63:	call   2a68 <botlish_fn_37+0x90>
			2a64: R_X86_64_PLT32	rt_type_error-0x4
    2a68:	jmp    2c20 <botlish_fn_37+0x248>
    2a6d:	mov    rdx,r15
    2a70:	mov    rdi,r14
    2a73:	call   2a78 <botlish_fn_37+0xa0>
			2a74: R_X86_64_PLT32	rt_mutarray_get-0x4
    2a78:	mov    rcx,rax
    2a7b:	mov    QWORD PTR [rsp+0x18],rax
    2a80:	test   rax,rcx
    2a83:	je     2c20 <botlish_fn_37+0x248>
    2a89:	mov    rax,QWORD PTR [rsp+0x18]
    2a8e:	test   rax,0x1
    2a94:	jne    2abf <botlish_fn_37+0xe7>
    2a9a:	mov    edx,0x1
    2a9f:	mov    rsi,QWORD PTR [rsp+0x18]
    2aa4:	mov    rdi,r14
    2aa7:	call   2aac <botlish_fn_37+0xd4>
			2aa8: R_X86_64_PLT32	rt_value_eq-0x4
    2aac:	test   rax,rax
    2aaf:	je     2c20 <botlish_fn_37+0x248>
    2ab5:	mov    rcx,QWORD PTR [rsp+0x18]
    2aba:	jmp    2ad5 <botlish_fn_37+0xfd>
    2abf:	mov    eax,0x2
    2ac4:	mov    rcx,QWORD PTR [rsp+0x18]
    2ac9:	cmp    rcx,0x1
    2acd:	cmove  rax,QWORD PTR [rip+0x1db]        # 2cb0 <botlish_fn_37+0x2d8>
    2ad5:	mov    ebx,0x6
    2ada:	cmp    rax,0x6
    2ade:	je     2c80 <botlish_fn_37+0x2a8>
    2ae4:	test   rcx,0x1
    2aeb:	mov    QWORD PTR [rsp+0x18],rcx
    2af0:	jne    2b16 <botlish_fn_37+0x13e>
    2af6:	mov    edx,0x3
    2afb:	mov    rsi,QWORD PTR [rsp+0x18]
    2b00:	mov    rdi,r14
    2b03:	call   2b08 <botlish_fn_37+0x130>
			2b04: R_X86_64_PLT32	rt_value_eq-0x4
    2b08:	test   rax,rax
    2b0b:	je     2c20 <botlish_fn_37+0x248>
    2b11:	jmp    2b2c <botlish_fn_37+0x154>
    2b16:	mov    rsi,QWORD PTR [rsp+0x18]
    2b1b:	mov    eax,0x2
    2b20:	cmp    rsi,0x3
    2b24:	cmove  rax,QWORD PTR [rip+0x184]        # 2cb0 <botlish_fn_37+0x2d8>
    2b2c:	cmp    rax,0x6
    2b30:	je     2b40 <botlish_fn_37+0x168>
    2b36:	mov    ebx,0x2
    2b3b:	jmp    2bff <botlish_fn_37+0x227>
    2b40:	mov    rsi,r12
    2b43:	mov    rdi,r14
    2b46:	call   2b4b <botlish_fn_37+0x173>
			2b47: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2b4b:	test   rax,rax
    2b4e:	je     2c20 <botlish_fn_37+0x248>
    2b54:	xor    r10d,r10d
    2b57:	test   rax,0x7
    2b5d:	je     2b6b <botlish_fn_37+0x193>
    2b63:	mov    rsi,rax
    2b66:	jmp    2b7a <botlish_fn_37+0x1a2>
    2b6b:	movzx  rcx,BYTE PTR [rax]
    2b6f:	mov    rsi,rax
    2b72:	rex cmp cl,0x8
    2b76:	sete   r10b
    2b7a:	test   r10b,r10b
    2b7d:	jne    2b9d <botlish_fn_37+0x1c5>
    2b83:	mov    rdi,r14
    2b86:	mov    rax,QWORD PTR [rdi+0x10]
    2b8a:	mov    rcx,QWORD PTR [rax+0x30]
    2b8e:	mov    edx,0x8
    2b93:	call   2b98 <botlish_fn_37+0x1c0>
			2b94: R_X86_64_PLT32	rt_type_error-0x4
    2b98:	jmp    2c20 <botlish_fn_37+0x248>
    2b9d:	mov    rdx,r15
    2ba0:	mov    rdi,r14
    2ba3:	call   2ba8 <botlish_fn_37+0x1d0>
			2ba4: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ba8:	test   rax,rax
    2bab:	je     2c20 <botlish_fn_37+0x248>
    2bb1:	mov    rcx,rax
    2bb4:	and    rcx,r13
    2bb7:	mov    rsi,rax
    2bba:	test   rcx,0x1
    2bc1:	jne    2be0 <botlish_fn_37+0x208>
    2bc7:	mov    rdx,r13
    2bca:	mov    rdi,r14
    2bcd:	call   2bd2 <botlish_fn_37+0x1fa>
			2bce: R_X86_64_PLT32	rt_value_eq-0x4
    2bd2:	test   rax,rax
    2bd5:	je     2c20 <botlish_fn_37+0x248>
    2bdb:	jmp    2bf0 <botlish_fn_37+0x218>
    2be0:	mov    eax,0x2
    2be5:	cmp    rsi,r13
    2be8:	cmove  rax,QWORD PTR [rip+0xc0]        # 2cb0 <botlish_fn_37+0x2d8>
    2bf0:	cmp    rax,0x6
    2bf4:	je     2bff <botlish_fn_37+0x227>
    2bfa:	mov    ebx,0x2
    2bff:	cmp    rbx,0x6
    2c03:	je     2c5b <botlish_fn_37+0x283>
    2c09:	mov    rdx,r15
    2c0c:	mov    rsi,r12
    2c0f:	mov    rdi,r14
    2c12:	call   2c17 <botlish_fn_37+0x23f>
			2c13: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2c17:	test   rax,rax
    2c1a:	jne    2c45 <botlish_fn_37+0x26d>
    2c20:	xor    rax,rax
    2c23:	mov    rbx,QWORD PTR [rsp+0x20]
    2c28:	mov    r12,QWORD PTR [rsp+0x28]
    2c2d:	mov    r13,QWORD PTR [rsp+0x30]
    2c32:	mov    r14,QWORD PTR [rsp+0x38]
    2c37:	mov    r15,QWORD PTR [rsp+0x40]
    2c3c:	add    rsp,0x50
    2c40:	mov    rsp,rbp
    2c43:	pop    rbp
    2c44:	ret
    2c45:	mov    QWORD PTR [rsp],r12
    2c49:	mov    QWORD PTR [rsp+0x8],r13
    2c4e:	mov    QWORD PTR [rsp+0x10],rax
    2c53:	mov    r15,rax
    2c56:	jmp    2a13 <botlish_fn_37+0x3b>
    2c5b:	mov    rax,r15
    2c5e:	mov    rbx,QWORD PTR [rsp+0x20]
    2c63:	mov    r12,QWORD PTR [rsp+0x28]
    2c68:	mov    r13,QWORD PTR [rsp+0x30]
    2c6d:	mov    r14,QWORD PTR [rsp+0x38]
    2c72:	mov    r15,QWORD PTR [rsp+0x40]
    2c77:	add    rsp,0x50
    2c7b:	mov    rsp,rbp
    2c7e:	pop    rbp
    2c7f:	ret
    2c80:	mov    rax,0xffffffffffffffff
    2c87:	mov    rbx,QWORD PTR [rsp+0x20]
    2c8c:	mov    r12,QWORD PTR [rsp+0x28]
    2c91:	mov    r13,QWORD PTR [rsp+0x30]
    2c96:	mov    r14,QWORD PTR [rsp+0x38]
    2c9b:	mov    r15,QWORD PTR [rsp+0x40]
    2ca0:	add    rsp,0x50
    2ca4:	mov    rsp,rbp
    2ca7:	pop    rbp
    2ca8:	ret
    2ca9:	add    BYTE PTR [rax],al
    2cab:	add    BYTE PTR [rax],al
    2cad:	add    BYTE PTR [rax],al
    2caf:	add    BYTE PTR [rsi],al
    2cb1:	add    BYTE PTR [rax],al
    2cb3:	add    BYTE PTR [rax],al
    2cb5:	add    BYTE PTR [rax],al
	...

0000000000002cb8 <botlish_entry_37: ht_find_get<mutarray, str, int>>:
    2cb8:	push   rbp
    2cb9:	mov    rbp,rsp
    2cbc:	mov    rsi,QWORD PTR [rdx]
    2cbf:	mov    r8,QWORD PTR [rdx+0x8]
    2cc3:	mov    rcx,QWORD PTR [rdx+0x10]
    2cc7:	mov    rdx,r8
    2cca:	call   2ccf <botlish_entry_37+0x17>
			2ccb: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    2ccf:	mov    rsp,rbp
    2cd2:	pop    rbp
    2cd3:	ret
    2cd4:	add    BYTE PTR [rax],al
	...

0000000000002cd8 <botlish_fn_38: ht_find_insert<mutarray, str, int, int>>:
    2cd8:	push   rbp
    2cd9:	mov    rbp,rsp
    2cdc:	sub    rsp,0x60
    2ce0:	mov    QWORD PTR [rsp+0x30],rbx
    2ce5:	mov    QWORD PTR [rsp+0x38],r12
    2cea:	mov    QWORD PTR [rsp+0x40],r13
    2cef:	mov    QWORD PTR [rsp+0x48],r14
    2cf4:	mov    QWORD PTR [rsp+0x50],r15
    2cf9:	mov    r15,rdi
    2cfc:	mov    QWORD PTR [rsp],rsi
    2d00:	mov    QWORD PTR [rsp+0x8],rdx
    2d05:	mov    r13,rdx
    2d08:	mov    QWORD PTR [rsp+0x10],rcx
    2d0d:	mov    QWORD PTR [rsp+0x18],r8
    2d12:	mov    rbx,rsi
    2d15:	mov    QWORD PTR [rsp+0x20],rcx
    2d1a:	mov    QWORD PTR [rsp+0x28],r8
    2d1f:	mov    rsi,rbx
    2d22:	mov    rdi,r15
    2d25:	call   2d2a <botlish_fn_38+0x52>
			2d26: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    2d2a:	test   rax,rax
    2d2d:	je     3025 <botlish_fn_38+0x34d>
    2d33:	xor    ecx,ecx
    2d35:	test   rax,0x7
    2d3b:	je     2d49 <botlish_fn_38+0x71>
    2d41:	mov    rsi,rax
    2d44:	jmp    2d57 <botlish_fn_38+0x7f>
    2d49:	movzx  rcx,BYTE PTR [rax]
    2d4d:	mov    rsi,rax
    2d50:	rex cmp cl,0x8
    2d54:	sete   cl
    2d57:	test   cl,cl
    2d59:	jne    2d79 <botlish_fn_38+0xa1>
    2d5f:	mov    rdi,r15
    2d62:	mov    rax,QWORD PTR [rdi+0x10]
    2d66:	mov    rcx,QWORD PTR [rax+0x30]
    2d6a:	mov    edx,0x8
    2d6f:	call   2d74 <botlish_fn_38+0x9c>
			2d70: R_X86_64_PLT32	rt_type_error-0x4
    2d74:	jmp    3025 <botlish_fn_38+0x34d>
    2d79:	mov    rdx,QWORD PTR [rsp+0x20]
    2d7e:	mov    rdi,r15
    2d81:	call   2d86 <botlish_fn_38+0xae>
			2d82: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d86:	mov    rsi,rax
    2d89:	mov    r14,rax
    2d8c:	test   rax,rsi
    2d8f:	je     3025 <botlish_fn_38+0x34d>
    2d95:	mov    rax,r14
    2d98:	test   rax,0x1
    2d9e:	jne    2dc2 <botlish_fn_38+0xea>
    2da4:	mov    edx,0x1
    2da9:	mov    rsi,r14
    2dac:	mov    rdi,r15
    2daf:	call   2db4 <botlish_fn_38+0xdc>
			2db0: R_X86_64_PLT32	rt_value_eq-0x4
    2db4:	test   rax,rax
    2db7:	je     3025 <botlish_fn_38+0x34d>
    2dbd:	jmp    2dd6 <botlish_fn_38+0xfe>
    2dc2:	mov    eax,0x2
    2dc7:	mov    rcx,r14
    2dca:	cmp    rcx,0x1
    2dce:	cmove  rax,QWORD PTR [rip+0x372]        # 3148 <botlish_fn_38+0x470>
    2dd6:	mov    r12d,0x6
    2ddc:	cmp    rax,0x6
    2de0:	je     309d <botlish_fn_38+0x3c5>
    2de6:	mov    rax,r14
    2de9:	test   rax,0x1
    2def:	jne    2e13 <botlish_fn_38+0x13b>
    2df5:	mov    edx,0x3
    2dfa:	mov    rsi,r14
    2dfd:	mov    rdi,r15
    2e00:	call   2e05 <botlish_fn_38+0x12d>
			2e01: R_X86_64_PLT32	rt_value_eq-0x4
    2e05:	test   rax,rax
    2e08:	je     3025 <botlish_fn_38+0x34d>
    2e0e:	jmp    2e27 <botlish_fn_38+0x14f>
    2e13:	mov    eax,0x2
    2e18:	mov    rcx,r14
    2e1b:	cmp    rcx,0x3
    2e1f:	cmove  rax,QWORD PTR [rip+0x321]        # 3148 <botlish_fn_38+0x470>
    2e27:	cmp    rax,0x6
    2e2b:	je     2e3c <botlish_fn_38+0x164>
    2e31:	mov    r11d,0x2
    2e37:	jmp    2f06 <botlish_fn_38+0x22e>
    2e3c:	mov    rsi,rbx
    2e3f:	mov    rdi,r15
    2e42:	call   2e47 <botlish_fn_38+0x16f>
			2e43: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    2e47:	test   rax,rax
    2e4a:	je     3025 <botlish_fn_38+0x34d>
    2e50:	xor    ecx,ecx
    2e52:	test   rax,0x7
    2e58:	je     2e66 <botlish_fn_38+0x18e>
    2e5e:	mov    rsi,rax
    2e61:	jmp    2e74 <botlish_fn_38+0x19c>
    2e66:	movzx  rcx,BYTE PTR [rax]
    2e6a:	mov    rsi,rax
    2e6d:	rex cmp cl,0x8
    2e71:	sete   cl
    2e74:	test   cl,cl
    2e76:	jne    2e96 <botlish_fn_38+0x1be>
    2e7c:	mov    rdi,r15
    2e7f:	mov    rcx,QWORD PTR [rdi+0x10]
    2e83:	mov    rcx,QWORD PTR [rcx+0x30]
    2e87:	mov    edx,0x8
    2e8c:	call   2e91 <botlish_fn_38+0x1b9>
			2e8d: R_X86_64_PLT32	rt_type_error-0x4
    2e91:	jmp    3025 <botlish_fn_38+0x34d>
    2e96:	mov    rdx,QWORD PTR [rsp+0x20]
    2e9b:	mov    rdi,r15
    2e9e:	call   2ea3 <botlish_fn_38+0x1cb>
			2e9f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ea3:	test   rax,rax
    2ea6:	je     3025 <botlish_fn_38+0x34d>
    2eac:	mov    rsi,rax
    2eaf:	and    rsi,r13
    2eb2:	test   rsi,0x1
    2eb9:	jne    2edb <botlish_fn_38+0x203>
    2ebf:	mov    rsi,rax
    2ec2:	mov    rdx,r13
    2ec5:	mov    rdi,r15
    2ec8:	call   2ecd <botlish_fn_38+0x1f5>
			2ec9: R_X86_64_PLT32	rt_value_eq-0x4
    2ecd:	test   rax,rax
    2ed0:	je     3025 <botlish_fn_38+0x34d>
    2ed6:	jmp    2eee <botlish_fn_38+0x216>
    2edb:	mov    rsi,rax
    2ede:	mov    eax,0x2
    2ee3:	cmp    rsi,r13
    2ee6:	cmove  rax,QWORD PTR [rip+0x25a]        # 3148 <botlish_fn_38+0x470>
    2eee:	cmp    rax,0x6
    2ef2:	je     2f03 <botlish_fn_38+0x22b>
    2ef8:	mov    r11d,0x2
    2efe:	jmp    2f06 <botlish_fn_38+0x22e>
    2f03:	mov    r11,r12
    2f06:	cmp    r11,0x6
    2f0a:	je     3076 <botlish_fn_38+0x39e>
    2f10:	mov    rax,r14
    2f13:	test   rax,0x1
    2f19:	jne    2f3d <botlish_fn_38+0x265>
    2f1f:	mov    edx,0x5
    2f24:	mov    rsi,r14
    2f27:	mov    rdi,r15
    2f2a:	call   2f2f <botlish_fn_38+0x257>
			2f2b: R_X86_64_PLT32	rt_value_eq-0x4
    2f2f:	test   rax,rax
    2f32:	je     3025 <botlish_fn_38+0x34d>
    2f38:	jmp    2f51 <botlish_fn_38+0x279>
    2f3d:	mov    rsi,r14
    2f40:	mov    eax,0x2
    2f45:	cmp    rsi,0x5
    2f49:	cmove  rax,QWORD PTR [rip+0x1f7]        # 3148 <botlish_fn_38+0x470>
    2f51:	cmp    rax,0x6
    2f55:	je     2f66 <botlish_fn_38+0x28e>
    2f5b:	mov    r12d,0x2
    2f61:	jmp    2fc7 <botlish_fn_38+0x2ef>
    2f66:	mov    r14,QWORD PTR [rsp+0x28]
    2f6b:	test   r14,0x1
    2f72:	jne    2fa2 <botlish_fn_38+0x2ca>
    2f78:	mov    edx,0x1
    2f7d:	mov    rsi,r14
    2f80:	mov    rdi,r15
    2f83:	call   2f88 <botlish_fn_38+0x2b0>
			2f84: R_X86_64_PLT32	rt_int_cmp-0x4
    2f88:	mov    ecx,0x2
    2f8d:	test   rax,rax
    2f90:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # 3148 <botlish_fn_38+0x470>
    2f98:	mov    QWORD PTR [rsp+0x28],r14
    2f9d:	jmp    2fb7 <botlish_fn_38+0x2df>
    2fa2:	mov    ecx,0x2
    2fa7:	test   r14,r14
    2faa:	mov    QWORD PTR [rsp+0x28],r14
    2faf:	cmovle rcx,QWORD PTR [rip+0x191]        # 3148 <botlish_fn_38+0x470>
    2fb7:	cmp    rcx,0x6
    2fbb:	je     2fc7 <botlish_fn_38+0x2ef>
    2fc1:	mov    r12d,0x2
    2fc7:	cmp    r12,0x6
    2fcb:	je     300c <botlish_fn_38+0x334>
    2fd1:	mov    rdx,QWORD PTR [rsp+0x20]
    2fd6:	mov    rsi,rbx
    2fd9:	mov    rdi,r15
    2fdc:	call   2fe1 <botlish_fn_38+0x309>
			2fdd: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    2fe1:	test   rax,rax
    2fe4:	je     3025 <botlish_fn_38+0x34d>
    2fea:	mov    QWORD PTR [rsp],rbx
    2fee:	mov    QWORD PTR [rsp+0x8],r13
    2ff3:	mov    QWORD PTR [rsp+0x10],rax
    2ff8:	mov    r11,QWORD PTR [rsp+0x28]
    2ffd:	mov    QWORD PTR [rsp+0x18],r11
    3002:	mov    QWORD PTR [rsp+0x20],rax
    3007:	jmp    2d1f <botlish_fn_38+0x47>
    300c:	mov    rdx,QWORD PTR [rsp+0x20]
    3011:	mov    rsi,rbx
    3014:	mov    rdi,r15
    3017:	call   301c <botlish_fn_38+0x344>
			3018: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_next<mutarray, int>
    301c:	test   rax,rax
    301f:	jne    304a <botlish_fn_38+0x372>
    3025:	xor    rax,rax
    3028:	mov    rbx,QWORD PTR [rsp+0x30]
    302d:	mov    r12,QWORD PTR [rsp+0x38]
    3032:	mov    r13,QWORD PTR [rsp+0x40]
    3037:	mov    r14,QWORD PTR [rsp+0x48]
    303c:	mov    r15,QWORD PTR [rsp+0x50]
    3041:	add    rsp,0x60
    3045:	mov    rsp,rbp
    3048:	pop    rbp
    3049:	ret
    304a:	mov    QWORD PTR [rsp],rbx
    304e:	mov    QWORD PTR [rsp+0x8],r13
    3053:	mov    QWORD PTR [rsp+0x10],rax
    3058:	mov    rdx,QWORD PTR [rsp+0x20]
    305d:	mov    QWORD PTR [rsp+0x18],rdx
    3062:	mov    rcx,QWORD PTR [rsp+0x20]
    3067:	mov    QWORD PTR [rsp+0x28],rcx
    306c:	mov    QWORD PTR [rsp+0x20],rax
    3071:	jmp    2d1f <botlish_fn_38+0x47>
    3076:	mov    rax,QWORD PTR [rsp+0x20]
    307b:	mov    rbx,QWORD PTR [rsp+0x30]
    3080:	mov    r12,QWORD PTR [rsp+0x38]
    3085:	mov    r13,QWORD PTR [rsp+0x40]
    308a:	mov    r14,QWORD PTR [rsp+0x48]
    308f:	mov    r15,QWORD PTR [rsp+0x50]
    3094:	add    rsp,0x60
    3098:	mov    rsp,rbp
    309b:	pop    rbp
    309c:	ret
    309d:	mov    rax,QWORD PTR [rsp+0x28]
    30a2:	test   rax,0x1
    30a8:	jne    30d5 <botlish_fn_38+0x3fd>
    30ae:	mov    edx,0x1
    30b3:	mov    rdi,r15
    30b6:	mov    rsi,QWORD PTR [rsp+0x28]
    30bb:	call   30c0 <botlish_fn_38+0x3e8>
			30bc: R_X86_64_PLT32	rt_int_cmp-0x4
    30c0:	mov    ecx,0x2
    30c5:	test   rax,rax
    30c8:	cmovge rcx,QWORD PTR [rip+0x78]        # 3148 <botlish_fn_38+0x470>
    30d0:	jmp    30ef <botlish_fn_38+0x417>
    30d5:	mov    ecx,0x2
    30da:	mov    rax,QWORD PTR [rsp+0x28]
    30df:	mov    rdx,QWORD PTR [rsp+0x28]
    30e4:	test   rax,rdx
    30e7:	cmovg  rcx,QWORD PTR [rip+0x59]        # 3148 <botlish_fn_38+0x470>
    30ef:	cmp    rcx,0x6
    30f3:	je     3120 <botlish_fn_38+0x448>
    30f9:	mov    rax,QWORD PTR [rsp+0x20]
    30fe:	mov    rbx,QWORD PTR [rsp+0x30]
    3103:	mov    r12,QWORD PTR [rsp+0x38]
    3108:	mov    r13,QWORD PTR [rsp+0x40]
    310d:	mov    r14,QWORD PTR [rsp+0x48]
    3112:	mov    r15,QWORD PTR [rsp+0x50]
    3117:	add    rsp,0x60
    311b:	mov    rsp,rbp
    311e:	pop    rbp
    311f:	ret
    3120:	mov    rax,QWORD PTR [rsp+0x28]
    3125:	mov    rbx,QWORD PTR [rsp+0x30]
    312a:	mov    r12,QWORD PTR [rsp+0x38]
    312f:	mov    r13,QWORD PTR [rsp+0x40]
    3134:	mov    r14,QWORD PTR [rsp+0x48]
    3139:	mov    r15,QWORD PTR [rsp+0x50]
    313e:	add    rsp,0x60
    3142:	mov    rsp,rbp
    3145:	pop    rbp
    3146:	ret
    3147:	add    BYTE PTR [rsi],al
    3149:	add    BYTE PTR [rax],al
    314b:	add    BYTE PTR [rax],al
    314d:	add    BYTE PTR [rax],al
	...

0000000000003150 <botlish_entry_38: ht_find_insert<mutarray, str, int, int>>:
    3150:	push   rbp
    3151:	mov    rbp,rsp
    3154:	mov    rsi,QWORD PTR [rdx]
    3157:	mov    r9,QWORD PTR [rdx+0x8]
    315b:	mov    rcx,QWORD PTR [rdx+0x10]
    315f:	mov    r8,QWORD PTR [rdx+0x18]
    3163:	mov    rdx,r9
    3166:	call   316b <botlish_entry_38+0x1b>
			3167: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    316b:	mov    rsp,rbp
    316e:	pop    rbp
    316f:	ret

0000000000003170 <botlish_fn_39: ht_get<mutarray, str>>:
    3170:	push   rbp
    3171:	mov    rbp,rsp
    3174:	sub    rsp,0x40
    3178:	mov    QWORD PTR [rsp+0x20],rbx
    317d:	mov    QWORD PTR [rsp+0x28],r12
    3182:	mov    QWORD PTR [rsp+0x30],r13
    3187:	mov    rbx,rdi
    318a:	mov    QWORD PTR [rsp],rsi
    318e:	mov    r13,rsi
    3191:	mov    QWORD PTR [rsp+0x8],rdx
    3196:	mov    r12,rdx
    3199:	mov    rdx,r12
    319c:	mov    rsi,r13
    319f:	mov    rdi,rbx
    31a2:	call   31a7 <botlish_fn_39+0x37>
			31a3: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    31a7:	test   rax,rax
    31aa:	je     3294 <botlish_fn_39+0x124>
    31b0:	mov    QWORD PTR [rsp+0x10],rax
    31b5:	mov    rcx,rax
    31b8:	mov    rdx,r12
    31bb:	mov    rsi,r13
    31be:	mov    rdi,rbx
    31c1:	call   31c6 <botlish_fn_39+0x56>
			31c2: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_find_get<mutarray, str, int>
    31c6:	mov    rcx,rax
    31c9:	mov    r12,rax
    31cc:	test   rax,rcx
    31cf:	je     3294 <botlish_fn_39+0x124>
    31d5:	mov    rax,r12
    31d8:	test   rax,0x1
    31de:	jne    3209 <botlish_fn_39+0x99>
    31e4:	mov    edx,0x1
    31e9:	mov    rsi,r12
    31ec:	mov    rdi,rbx
    31ef:	call   31f4 <botlish_fn_39+0x84>
			31f0: R_X86_64_PLT32	rt_int_cmp-0x4
    31f4:	mov    ecx,0x2
    31f9:	test   rax,rax
    31fc:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 32e8 <botlish_fn_39+0x178>
    3204:	jmp    321c <botlish_fn_39+0xac>
    3209:	mov    ecx,0x2
    320e:	mov    rax,r12
    3211:	test   rax,rax
    3214:	cmovle rcx,QWORD PTR [rip+0xcc]        # 32e8 <botlish_fn_39+0x178>
    321c:	cmp    rcx,0x6
    3220:	je     32c7 <botlish_fn_39+0x157>
    3226:	mov    rsi,r13
    3229:	mov    rdi,rbx
    322c:	call   3231 <botlish_fn_39+0xc1>
			322d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3231:	test   rax,rax
    3234:	je     3294 <botlish_fn_39+0x124>
    323a:	xor    ecx,ecx
    323c:	test   rax,0x7
    3242:	je     3250 <botlish_fn_39+0xe0>
    3248:	mov    rsi,rax
    324b:	jmp    325e <botlish_fn_39+0xee>
    3250:	movzx  rcx,BYTE PTR [rax]
    3254:	mov    rsi,rax
    3257:	rex cmp cl,0x8
    325b:	sete   cl
    325e:	test   cl,cl
    3260:	jne    3280 <botlish_fn_39+0x110>
    3266:	mov    rdi,rbx
    3269:	mov    rax,QWORD PTR [rdi+0x10]
    326d:	mov    rcx,QWORD PTR [rax+0x30]
    3271:	mov    edx,0x8
    3276:	call   327b <botlish_fn_39+0x10b>
			3277: R_X86_64_PLT32	rt_type_error-0x4
    327b:	jmp    3294 <botlish_fn_39+0x124>
    3280:	mov    rdx,r12
    3283:	mov    rdi,rbx
    3286:	call   328b <botlish_fn_39+0x11b>
			3287: R_X86_64_PLT32	rt_mutarray_get-0x4
    328b:	test   rax,rax
    328e:	jne    32af <botlish_fn_39+0x13f>
    3294:	xor    rax,rax
    3297:	mov    rbx,QWORD PTR [rsp+0x20]
    329c:	mov    r12,QWORD PTR [rsp+0x28]
    32a1:	mov    r13,QWORD PTR [rsp+0x30]
    32a6:	add    rsp,0x40
    32aa:	mov    rsp,rbp
    32ad:	pop    rbp
    32ae:	ret
    32af:	mov    rbx,QWORD PTR [rsp+0x20]
    32b4:	mov    r12,QWORD PTR [rsp+0x28]
    32b9:	mov    r13,QWORD PTR [rsp+0x30]
    32be:	add    rsp,0x40
    32c2:	mov    rsp,rbp
    32c5:	pop    rbp
    32c6:	ret
    32c7:	mov    eax,0xa
    32cc:	mov    rbx,QWORD PTR [rsp+0x20]
    32d1:	mov    r12,QWORD PTR [rsp+0x28]
    32d6:	mov    r13,QWORD PTR [rsp+0x30]
    32db:	add    rsp,0x40
    32df:	mov    rsp,rbp
    32e2:	pop    rbp
    32e3:	ret
    32e4:	add    BYTE PTR [rax],al
    32e6:	add    BYTE PTR [rax],al
    32e8:	(bad)
    32e9:	add    BYTE PTR [rax],al
    32eb:	add    BYTE PTR [rax],al
    32ed:	add    BYTE PTR [rax],al
	...

00000000000032f0 <botlish_entry_39: ht_get<mutarray, str>>:
    32f0:	push   rbp
    32f1:	mov    rbp,rsp
    32f4:	mov    rsi,QWORD PTR [rdx]
    32f7:	mov    rdx,QWORD PTR [rdx+0x8]
    32fb:	call   3300 <botlish_entry_39+0x10>
			32fc: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    3300:	mov    rsp,rbp
    3303:	pop    rbp
    3304:	ret
    3305:	add    BYTE PTR [rax],al
	...

0000000000003308 <botlish_fn_40: ht_rehash_probe<mutarray, int, int>>:
    3308:	push   rbp
    3309:	mov    rbp,rsp
    330c:	sub    rsp,0x40
    3310:	mov    QWORD PTR [rsp+0x20],rbx
    3315:	mov    QWORD PTR [rsp+0x28],r12
    331a:	mov    QWORD PTR [rsp+0x30],r13
    331f:	mov    QWORD PTR [rsp+0x38],r14
    3324:	mov    r13,rdi
    3327:	mov    QWORD PTR [rsp],rsi
    332b:	mov    QWORD PTR [rsp+0x8],rdx
    3330:	mov    QWORD PTR [rsp+0x10],rcx
    3335:	mov    r12,rcx
    3338:	mov    rbx,rsi
    333b:	mov    r14,rdx
    333e:	mov    rdx,r14
    3341:	mov    rsi,rbx
    3344:	mov    rdi,r13
    3347:	call   334c <botlish_fn_40+0x44>
			3348: R_X86_64_PLT32	rt_mutarray_get-0x4
    334c:	test   rax,rax
    334f:	je     33ec <botlish_fn_40+0xe4>
    3355:	test   rax,0x1
    335b:	mov    rsi,rax
    335e:	jne    337f <botlish_fn_40+0x77>
    3364:	mov    edx,0x1
    3369:	mov    rdi,r13
    336c:	call   3371 <botlish_fn_40+0x69>
			336d: R_X86_64_PLT32	rt_value_eq-0x4
    3371:	test   rax,rax
    3374:	je     33ec <botlish_fn_40+0xe4>
    337a:	jmp    3390 <botlish_fn_40+0x88>
    337f:	mov    eax,0x2
    3384:	cmp    rsi,0x1
    3388:	cmove  rax,QWORD PTR [rip+0xb8]        # 3448 <botlish_fn_40+0x140>
    3390:	cmp    rax,0x6
    3394:	je     3422 <botlish_fn_40+0x11a>
    339a:	mov    QWORD PTR [rsp+0x18],0x3
    33a3:	mov    rsi,r14
    33a6:	test   rsi,0x1
    33ad:	je     33c5 <botlish_fn_40+0xbd>
    33b3:	mov    rsi,r14
    33b6:	add    rsi,0x2
    33ba:	seto   al
    33bd:	test   al,al
    33bf:	je     33d8 <botlish_fn_40+0xd0>
    33c5:	mov    edx,0x3
    33ca:	mov    rsi,r14
    33cd:	mov    rdi,r13
    33d0:	call   33d5 <botlish_fn_40+0xcd>
			33d1: R_X86_64_PLT32	rt_int_add-0x4
    33d5:	mov    rsi,rax
    33d8:	mov    rdx,r12
    33db:	mov    rdi,r13
    33de:	call   33e3 <botlish_fn_40+0xdb>
			33df: R_X86_64_PLT32	rt_int_mod-0x4
    33e3:	test   rax,rax
    33e6:	jne    340c <botlish_fn_40+0x104>
    33ec:	xor    rax,rax
    33ef:	mov    rbx,QWORD PTR [rsp+0x20]
    33f4:	mov    r12,QWORD PTR [rsp+0x28]
    33f9:	mov    r13,QWORD PTR [rsp+0x30]
    33fe:	mov    r14,QWORD PTR [rsp+0x38]
    3403:	add    rsp,0x40
    3407:	mov    rsp,rbp
    340a:	pop    rbp
    340b:	ret
    340c:	mov    QWORD PTR [rsp],rbx
    3410:	mov    QWORD PTR [rsp+0x8],rax
    3415:	mov    QWORD PTR [rsp+0x10],r12
    341a:	mov    r14,rax
    341d:	jmp    333e <botlish_fn_40+0x36>
    3422:	mov    rax,r14
    3425:	mov    rbx,QWORD PTR [rsp+0x20]
    342a:	mov    r12,QWORD PTR [rsp+0x28]
    342f:	mov    r13,QWORD PTR [rsp+0x30]
    3434:	mov    r14,QWORD PTR [rsp+0x38]
    3439:	add    rsp,0x40
    343d:	mov    rsp,rbp
    3440:	pop    rbp
    3441:	ret
    3442:	add    BYTE PTR [rax],al
    3444:	add    BYTE PTR [rax],al
    3446:	add    BYTE PTR [rax],al
    3448:	(bad)
    3449:	add    BYTE PTR [rax],al
    344b:	add    BYTE PTR [rax],al
    344d:	add    BYTE PTR [rax],al
	...

0000000000003450 <botlish_entry_40: ht_rehash_probe<mutarray, int, int>>:
    3450:	push   rbp
    3451:	mov    rbp,rsp
    3454:	mov    rsi,QWORD PTR [rdx]
    3457:	mov    r8,QWORD PTR [rdx+0x8]
    345b:	mov    rcx,QWORD PTR [rdx+0x10]
    345f:	mov    rdx,r8
    3462:	call   3467 <botlish_entry_40+0x17>
			3463: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    3467:	mov    rsp,rbp
    346a:	pop    rbp
    346b:	ret

000000000000346c <botlish_fn_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    346c:	push   rbp
    346d:	mov    rbp,rsp
    3470:	sub    rsp,0x80
    3477:	mov    QWORD PTR [rsp+0x50],rbx
    347c:	mov    QWORD PTR [rsp+0x58],r12
    3481:	mov    QWORD PTR [rsp+0x60],r13
    3486:	mov    QWORD PTR [rsp+0x68],r14
    348b:	mov    QWORD PTR [rsp+0x70],r15
    3490:	mov    r12,rdi
    3493:	mov    rdi,QWORD PTR [rbp+0x10]
    3497:	mov    QWORD PTR [rsp],rsi
    349b:	mov    QWORD PTR [rsp+0x38],rsi
    34a0:	mov    QWORD PTR [rsp+0x8],rdx
    34a5:	mov    r15,rdx
    34a8:	mov    QWORD PTR [rsp+0x10],rcx
    34ad:	mov    rbx,rcx
    34b0:	mov    QWORD PTR [rsp+0x18],r8
    34b5:	mov    QWORD PTR [rsp+0x40],r8
    34ba:	mov    QWORD PTR [rsp+0x20],r9
    34bf:	mov    r14,r9
    34c2:	mov    QWORD PTR [rsp+0x28],rdi
    34c7:	mov    r13,rdi
    34ca:	mov    rsi,r14
    34cd:	mov    rdi,r12
    34d0:	call   34d5 <botlish_fn_41+0x69>
			34d1: R_X86_64_PLT32	rt_hash-0x4
    34d5:	test   rax,rax
    34d8:	mov    rsi,rax
    34db:	je     357a <botlish_fn_41+0x10e>
    34e1:	mov    rdx,QWORD PTR [rsp+0x40]
    34e6:	mov    rdi,r12
    34e9:	call   34ee <botlish_fn_41+0x82>
			34ea: R_X86_64_PLT32	rt_int_mod-0x4
    34ee:	test   rax,rax
    34f1:	je     357a <botlish_fn_41+0x10e>
    34f7:	mov    QWORD PTR [rsp+0x30],rax
    34fc:	mov    rcx,QWORD PTR [rsp+0x40]
    3501:	mov    rdx,rax
    3504:	mov    rsi,QWORD PTR [rsp+0x38]
    3509:	mov    rdi,r12
    350c:	call   3511 <botlish_fn_41+0xa5>
			350d: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_rehash_probe<mutarray, int, int>
    3511:	mov    rcx,rax
    3514:	mov    QWORD PTR [rsp+0x40],rax
    3519:	test   rax,rcx
    351c:	je     357a <botlish_fn_41+0x10e>
    3522:	mov    ecx,0x3
    3527:	mov    rsi,QWORD PTR [rsp+0x38]
    352c:	mov    rdx,QWORD PTR [rsp+0x40]
    3531:	mov    rdi,r12
    3534:	call   3539 <botlish_fn_41+0xcd>
			3535: R_X86_64_PLT32	rt_mutarray_set-0x4
    3539:	test   rax,rax
    353c:	je     357a <botlish_fn_41+0x10e>
    3542:	mov    rcx,r14
    3545:	mov    rsi,r15
    3548:	mov    rdx,QWORD PTR [rsp+0x40]
    354d:	mov    rdi,r12
    3550:	call   3555 <botlish_fn_41+0xe9>
			3551: R_X86_64_PLT32	rt_mutarray_set-0x4
    3555:	test   rax,rax
    3558:	je     357a <botlish_fn_41+0x10e>
    355e:	mov    rcx,r13
    3561:	mov    rdx,QWORD PTR [rsp+0x40]
    3566:	mov    rsi,rbx
    3569:	mov    rdi,r12
    356c:	call   3571 <botlish_fn_41+0x105>
			356d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3571:	test   rax,rax
    3574:	jne    35a2 <botlish_fn_41+0x136>
    357a:	xor    rax,rax
    357d:	mov    rbx,QWORD PTR [rsp+0x50]
    3582:	mov    r12,QWORD PTR [rsp+0x58]
    3587:	mov    r13,QWORD PTR [rsp+0x60]
    358c:	mov    r14,QWORD PTR [rsp+0x68]
    3591:	mov    r15,QWORD PTR [rsp+0x70]
    3596:	add    rsp,0x80
    359d:	mov    rsp,rbp
    35a0:	pop    rbp
    35a1:	ret
    35a2:	mov    eax,0xa
    35a7:	mov    rbx,QWORD PTR [rsp+0x50]
    35ac:	mov    r12,QWORD PTR [rsp+0x58]
    35b1:	mov    r13,QWORD PTR [rsp+0x60]
    35b6:	mov    r14,QWORD PTR [rsp+0x68]
    35bb:	mov    r15,QWORD PTR [rsp+0x70]
    35c0:	add    rsp,0x80
    35c7:	mov    rsp,rbp
    35ca:	pop    rbp
    35cb:	ret

00000000000035cc <botlish_entry_41: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    35cc:	push   rbp
    35cd:	mov    rbp,rsp
    35d0:	sub    rsp,0x10
    35d4:	mov    rsi,QWORD PTR [rdx]
    35d7:	mov    r10,QWORD PTR [rdx+0x8]
    35db:	mov    rcx,QWORD PTR [rdx+0x10]
    35df:	mov    r8,QWORD PTR [rdx+0x18]
    35e3:	mov    r9,QWORD PTR [rdx+0x20]
    35e7:	mov    r11,QWORD PTR [rdx+0x28]
    35eb:	mov    QWORD PTR [rsp],r11
    35ef:	mov    rdx,r10
    35f2:	call   35f7 <botlish_entry_41+0x2b>
			35f3: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    35f7:	add    rsp,0x10
    35fb:	mov    rsp,rbp
    35fe:	pop    rbp
    35ff:	ret

0000000000003600 <botlish_fn_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3600:	push   rbp
    3601:	mov    rbp,rsp
    3604:	sub    rsp,0xc0
    360b:	mov    QWORD PTR [rsp+0x90],rbx
    3613:	mov    QWORD PTR [rsp+0x98],r12
    361b:	mov    QWORD PTR [rsp+0xa0],r13
    3623:	mov    QWORD PTR [rsp+0xa8],r14
    362b:	mov    QWORD PTR [rsp+0xb0],r15
    3633:	mov    QWORD PTR [rsp+0x58],rdi
    3638:	mov    r15,QWORD PTR [rbp+0x10]
    363c:	mov    r12,QWORD PTR [rbp+0x18]
    3640:	mov    r13,QWORD PTR [rbp+0x20]
    3644:	mov    r14,QWORD PTR [rbp+0x28]
    3648:	mov    QWORD PTR [rsp+0x10],rsi
    364d:	mov    QWORD PTR [rsp+0x60],rsi
    3652:	mov    QWORD PTR [rsp+0x18],rdx
    3657:	mov    QWORD PTR [rsp+0x68],rdx
    365c:	mov    QWORD PTR [rsp+0x20],rcx
    3661:	mov    QWORD PTR [rsp+0x70],rcx
    3666:	mov    QWORD PTR [rsp+0x28],r15
    366b:	mov    QWORD PTR [rsp+0x30],r12
    3670:	mov    QWORD PTR [rsp+0x38],r13
    3675:	mov    QWORD PTR [rsp+0x40],r14
    367a:	sar    r8,1
    367d:	sar    r9,1
    3680:	mov    QWORD PTR [rsp+0x88],r9
    3688:	mov    rcx,QWORD PTR [rsp+0x88]
    3690:	mov    rbx,r8
    3693:	cmp    rbx,rcx
    3696:	mov    QWORD PTR [rsp+0x88],rcx
    369e:	jge    3907 <botlish_fn_42+0x307>
    36a4:	xor    eax,eax
    36a6:	mov    rsi,QWORD PTR [rsp+0x60]
    36ab:	test   rsi,0x7
    36b2:	jne    36c3 <botlish_fn_42+0xc3>
    36b8:	movzx  r10,BYTE PTR [rsi]
    36bc:	cmp    r10b,0x8
    36c0:	sete   al
    36c3:	test   al,al
    36c5:	jne    36e7 <botlish_fn_42+0xe7>
    36cb:	mov    rdi,QWORD PTR [rsp+0x58]
    36d0:	mov    rax,QWORD PTR [rdi+0x10]
    36d4:	mov    rcx,QWORD PTR [rax+0x30]
    36d8:	mov    edx,0x8
    36dd:	call   36e2 <botlish_fn_42+0xe2>
			36de: R_X86_64_PLT32	rt_type_error-0x4
    36e2:	jmp    3885 <botlish_fn_42+0x285>
    36e7:	mov    QWORD PTR [rsp+0x60],rsi
    36ec:	mov    rdx,rbx
    36ef:	shl    rdx,1
    36f2:	or     rdx,0x1
    36f6:	mov    QWORD PTR [rsp+0x80],rdx
    36fe:	mov    rdi,QWORD PTR [rsp+0x58]
    3703:	call   3708 <botlish_fn_42+0x108>
			3704: R_X86_64_PLT32	rt_mutarray_get-0x4
    3708:	test   rax,rax
    370b:	je     3885 <botlish_fn_42+0x285>
    3711:	test   rax,0x1
    3717:	mov    rsi,rax
    371a:	jne    373d <botlish_fn_42+0x13d>
    3720:	mov    edx,0x3
    3725:	mov    rdi,QWORD PTR [rsp+0x58]
    372a:	call   372f <botlish_fn_42+0x12f>
			372b: R_X86_64_PLT32	rt_value_eq-0x4
    372f:	test   rax,rax
    3732:	je     3885 <botlish_fn_42+0x285>
    3738:	jmp    374e <botlish_fn_42+0x14e>
    373d:	mov    eax,0x2
    3742:	cmp    rsi,0x3
    3746:	cmove  rax,QWORD PTR [rip+0x1f2]        # 3940 <botlish_fn_42+0x340>
    374e:	cmp    rax,0x6
    3752:	je     3762 <botlish_fn_42+0x162>
    3758:	mov    rsi,QWORD PTR [rsp+0x60]
    375d:	jmp    38c1 <botlish_fn_42+0x2c1>
    3762:	xor    esi,esi
    3764:	mov    rdx,QWORD PTR [rsp+0x68]
    3769:	test   rdx,0x7
    3770:	je     3780 <botlish_fn_42+0x180>
    3776:	mov    QWORD PTR [rsp+0x68],rdx
    377b:	jmp    378f <botlish_fn_42+0x18f>
    3780:	movzx  rax,BYTE PTR [rdx]
    3784:	mov    QWORD PTR [rsp+0x68],rdx
    3789:	cmp    al,0x8
    378b:	sete   sil
    378f:	test   sil,sil
    3792:	jne    37b9 <botlish_fn_42+0x1b9>
    3798:	mov    rdi,QWORD PTR [rsp+0x58]
    379d:	mov    rax,QWORD PTR [rdi+0x10]
    37a1:	mov    rcx,QWORD PTR [rax+0x30]
    37a5:	mov    edx,0x8
    37aa:	mov    rsi,QWORD PTR [rsp+0x68]
    37af:	call   37b4 <botlish_fn_42+0x1b4>
			37b0: R_X86_64_PLT32	rt_type_error-0x4
    37b4:	jmp    3885 <botlish_fn_42+0x285>
    37b9:	mov    rdx,QWORD PTR [rsp+0x80]
    37c1:	mov    rsi,QWORD PTR [rsp+0x68]
    37c6:	mov    rdi,QWORD PTR [rsp+0x58]
    37cb:	call   37d0 <botlish_fn_42+0x1d0>
			37cc: R_X86_64_PLT32	rt_mutarray_get-0x4
    37d0:	test   rax,rax
    37d3:	je     3885 <botlish_fn_42+0x285>
    37d9:	mov    QWORD PTR [rsp+0x48],rax
    37de:	mov    QWORD PTR [rsp+0x78],rax
    37e3:	xor    eax,eax
    37e5:	mov    rcx,QWORD PTR [rsp+0x70]
    37ea:	test   rcx,0x7
    37f1:	je     3801 <botlish_fn_42+0x201>
    37f7:	mov    QWORD PTR [rsp+0x70],rcx
    37fc:	jmp    380f <botlish_fn_42+0x20f>
    3801:	movzx  rax,BYTE PTR [rcx]
    3805:	mov    QWORD PTR [rsp+0x70],rcx
    380a:	cmp    al,0x8
    380c:	sete   al
    380f:	test   al,al
    3811:	jne    3838 <botlish_fn_42+0x238>
    3817:	mov    rdi,QWORD PTR [rsp+0x58]
    381c:	mov    rax,QWORD PTR [rdi+0x10]
    3820:	mov    rcx,QWORD PTR [rax+0x30]
    3824:	mov    edx,0x8
    3829:	mov    rsi,QWORD PTR [rsp+0x70]
    382e:	call   3833 <botlish_fn_42+0x233>
			382f: R_X86_64_PLT32	rt_type_error-0x4
    3833:	jmp    3885 <botlish_fn_42+0x285>
    3838:	mov    rdx,QWORD PTR [rsp+0x80]
    3840:	mov    rsi,QWORD PTR [rsp+0x70]
    3845:	mov    rdi,QWORD PTR [rsp+0x58]
    384a:	call   384f <botlish_fn_42+0x24f>
			384b: R_X86_64_PLT32	rt_mutarray_get-0x4
    384f:	test   rax,rax
    3852:	je     3885 <botlish_fn_42+0x285>
    3858:	mov    QWORD PTR [rsp+0x50],rax
    385d:	mov    QWORD PTR [rsp],rax
    3861:	mov    r9,QWORD PTR [rsp+0x78]
    3866:	mov    rcx,r13
    3869:	mov    rdx,r12
    386c:	mov    rsi,r15
    386f:	mov    rdi,QWORD PTR [rsp+0x58]
    3874:	mov    r8,r14
    3877:	call   387c <botlish_fn_42+0x27c>
			3878: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    387c:	test   rax,rax
    387f:	jne    38bc <botlish_fn_42+0x2bc>
    3885:	xor    rax,rax
    3888:	mov    rbx,QWORD PTR [rsp+0x90]
    3890:	mov    r12,QWORD PTR [rsp+0x98]
    3898:	mov    r13,QWORD PTR [rsp+0xa0]
    38a0:	mov    r14,QWORD PTR [rsp+0xa8]
    38a8:	mov    r15,QWORD PTR [rsp+0xb0]
    38b0:	add    rsp,0xc0
    38b7:	mov    rsp,rbp
    38ba:	pop    rbp
    38bb:	ret
    38bc:	mov    rsi,QWORD PTR [rsp+0x60]
    38c1:	mov    rsi,QWORD PTR [rsp+0x60]
    38c6:	mov    QWORD PTR [rsp+0x10],rsi
    38cb:	mov    rsi,QWORD PTR [rsp+0x68]
    38d0:	mov    QWORD PTR [rsp+0x18],rsi
    38d5:	mov    rsi,QWORD PTR [rsp+0x70]
    38da:	mov    QWORD PTR [rsp+0x20],rsi
    38df:	mov    QWORD PTR [rsp+0x28],r15
    38e4:	mov    QWORD PTR [rsp+0x30],r12
    38e9:	mov    QWORD PTR [rsp+0x38],r13
    38ee:	mov    QWORD PTR [rsp+0x40],r14
    38f3:	add    rbx,0x1
    38fa:	mov    rcx,QWORD PTR [rsp+0x88]
    3902:	jmp    3693 <botlish_fn_42+0x93>
    3907:	mov    eax,0xa
    390c:	mov    rbx,QWORD PTR [rsp+0x90]
    3914:	mov    r12,QWORD PTR [rsp+0x98]
    391c:	mov    r13,QWORD PTR [rsp+0xa0]
    3924:	mov    r14,QWORD PTR [rsp+0xa8]
    392c:	mov    r15,QWORD PTR [rsp+0xb0]
    3934:	add    rsp,0xc0
    393b:	mov    rsp,rbp
    393e:	pop    rbp
    393f:	ret
    3940:	(bad)
    3941:	add    BYTE PTR [rax],al
    3943:	add    BYTE PTR [rax],al
    3945:	add    BYTE PTR [rax],al
	...

0000000000003948 <botlish_entry_42: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    3948:	push   rbp
    3949:	mov    rbp,rsp
    394c:	sub    rsp,0x30
    3950:	mov    QWORD PTR [rsp+0x20],r12
    3955:	mov    rsi,QWORD PTR [rdx]
    3958:	mov    rax,QWORD PTR [rdx+0x8]
    395c:	mov    rcx,QWORD PTR [rdx+0x10]
    3960:	mov    r8,QWORD PTR [rdx+0x18]
    3964:	mov    r9,QWORD PTR [rdx+0x20]
    3968:	mov    r10,QWORD PTR [rdx+0x28]
    396c:	mov    r11,QWORD PTR [rdx+0x30]
    3970:	mov    r12,QWORD PTR [rdx+0x38]
    3974:	mov    rdx,QWORD PTR [rdx+0x40]
    3978:	mov    QWORD PTR [rsp],r10
    397c:	mov    QWORD PTR [rsp+0x8],r11
    3981:	mov    QWORD PTR [rsp+0x10],r12
    3986:	mov    QWORD PTR [rsp+0x18],rdx
    398b:	mov    rdx,rax
    398e:	call   3993 <botlish_entry_42+0x4b>
			398f: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3993:	mov    r12,QWORD PTR [rsp+0x20]
    3998:	add    rsp,0x30
    399c:	mov    rsp,rbp
    399f:	pop    rbp
    39a0:	ret

00000000000039a1 <botlish_fn_43: ht_rehash<mutarray, int>>:
    39a1:	push   rbp
    39a2:	mov    rbp,rsp
    39a5:	sub    rsp,0xd0
    39ac:	mov    QWORD PTR [rsp+0xa0],rbx
    39b4:	mov    QWORD PTR [rsp+0xa8],r12
    39bc:	mov    QWORD PTR [rsp+0xb0],r13
    39c4:	mov    QWORD PTR [rsp+0xb8],r14
    39cc:	mov    QWORD PTR [rsp+0xc0],r15
    39d4:	mov    r13,rdi
    39d7:	mov    QWORD PTR [rsp+0x50],0x0
    39e0:	mov    QWORD PTR [rsp+0x58],0x0
    39e9:	mov    QWORD PTR [rsp+0x60],0x0
    39f2:	mov    QWORD PTR [rsp+0x68],0x0
    39fb:	mov    QWORD PTR [rsp+0x20],rsi
    3a00:	mov    r12,rsi
    3a03:	mov    QWORD PTR [rsp+0x28],rdx
    3a08:	mov    rbx,rdx
    3a0b:	mov    rsi,r12
    3a0e:	mov    rdi,r13
    3a11:	call   3a16 <botlish_fn_43+0x75>
			3a12: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    3a16:	test   rax,rax
    3a19:	je     3be8 <botlish_fn_43+0x247>
    3a1f:	mov    QWORD PTR [rsp+0x30],rax
    3a24:	mov    r14,rax
    3a27:	mov    rsi,r12
    3a2a:	mov    rdi,r13
    3a2d:	call   3a32 <botlish_fn_43+0x91>
			3a2e: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    3a32:	test   rax,rax
    3a35:	je     3be8 <botlish_fn_43+0x247>
    3a3b:	mov    QWORD PTR [rsp+0x38],rax
    3a40:	mov    r15,rax
    3a43:	mov    rsi,r12
    3a46:	mov    rdi,r13
    3a49:	call   3a4e <botlish_fn_43+0xad>
			3a4a: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    3a4e:	test   rax,rax
    3a51:	je     3be8 <botlish_fn_43+0x247>
    3a57:	mov    QWORD PTR [rsp+0x40],rax
    3a5c:	mov    QWORD PTR [rsp+0x90],rax
    3a64:	mov    rsi,r12
    3a67:	mov    rdi,r13
    3a6a:	call   3a6f <botlish_fn_43+0xce>
			3a6b: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3a6f:	test   rax,rax
    3a72:	je     3be8 <botlish_fn_43+0x247>
    3a78:	mov    QWORD PTR [rsp+0x48],rax
    3a7d:	mov    QWORD PTR [rsp+0x88],rax
    3a85:	mov    rsi,rbx
    3a88:	mov    rdi,r13
    3a8b:	call   3a90 <botlish_fn_43+0xef>
			3a8c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3a90:	mov    rcx,rax
    3a93:	mov    QWORD PTR [rsp+0x80],rax
    3a9b:	test   rax,rcx
    3a9e:	je     3be8 <botlish_fn_43+0x247>
    3aa4:	mov    rax,QWORD PTR [rsp+0x80]
    3aac:	mov    QWORD PTR [rsp+0x50],rax
    3ab1:	mov    edx,0x1
    3ab6:	mov    QWORD PTR [rsp+0x58],0x1
    3abf:	mov    rcx,rbx
    3ac2:	mov    rsi,QWORD PTR [rsp+0x80]
    3aca:	mov    rdi,r13
    3acd:	call   3ad2 <botlish_fn_43+0x131>
			3ace: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_fill_empty<mutarray, int, int>
    3ad2:	test   rax,rax
    3ad5:	je     3be8 <botlish_fn_43+0x247>
    3adb:	mov    rsi,rbx
    3ade:	mov    rdi,r13
    3ae1:	call   3ae6 <botlish_fn_43+0x145>
			3ae2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3ae6:	test   rax,rax
    3ae9:	je     3be8 <botlish_fn_43+0x247>
    3aef:	mov    QWORD PTR [rsp+0x58],rax
    3af4:	mov    QWORD PTR [rsp+0x78],rax
    3af9:	mov    rsi,rbx
    3afc:	mov    rdi,r13
    3aff:	call   3b04 <botlish_fn_43+0x163>
			3b00: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    3b04:	test   rax,rax
    3b07:	je     3be8 <botlish_fn_43+0x247>
    3b0d:	mov    QWORD PTR [rsp+0x60],rax
    3b12:	mov    r8d,0x1
    3b18:	mov    QWORD PTR [rsp+0x68],0x1
    3b21:	mov    rcx,QWORD PTR [rsp+0x80]
    3b29:	mov    QWORD PTR [rsp],rcx
    3b2d:	mov    rcx,QWORD PTR [rsp+0x78]
    3b32:	mov    QWORD PTR [rsp+0x8],rcx
    3b37:	mov    QWORD PTR [rsp+0x10],rax
    3b3c:	mov    QWORD PTR [rsp+0x70],rax
    3b41:	mov    QWORD PTR [rsp+0x18],rbx
    3b46:	mov    rcx,QWORD PTR [rsp+0x90]
    3b4e:	mov    rdx,r15
    3b51:	mov    rsi,r14
    3b54:	mov    r9,QWORD PTR [rsp+0x88]
    3b5c:	mov    rdi,r13
    3b5f:	call   3b64 <botlish_fn_43+0x1c3>
			3b60: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    3b64:	test   rax,rax
    3b67:	je     3be8 <botlish_fn_43+0x247>
    3b6d:	mov    edx,0x1
    3b72:	mov    rcx,QWORD PTR [rsp+0x80]
    3b7a:	mov    rsi,r12
    3b7d:	mov    rdi,r13
    3b80:	call   3b85 <botlish_fn_43+0x1e4>
			3b81: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b85:	test   rax,rax
    3b88:	je     3be8 <botlish_fn_43+0x247>
    3b8e:	mov    edx,0x3
    3b93:	mov    rcx,QWORD PTR [rsp+0x78]
    3b98:	mov    rsi,r12
    3b9b:	mov    rdi,r13
    3b9e:	call   3ba3 <botlish_fn_43+0x202>
			3b9f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ba3:	test   rax,rax
    3ba6:	je     3be8 <botlish_fn_43+0x247>
    3bac:	mov    edx,0x5
    3bb1:	mov    rcx,QWORD PTR [rsp+0x70]
    3bb6:	mov    rsi,r12
    3bb9:	mov    rdi,r13
    3bbc:	call   3bc1 <botlish_fn_43+0x220>
			3bbd: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bc1:	test   rax,rax
    3bc4:	je     3be8 <botlish_fn_43+0x247>
    3bca:	mov    edx,0x9
    3bcf:	mov    ecx,0x1
    3bd4:	mov    rsi,r12
    3bd7:	mov    rdi,r13
    3bda:	call   3bdf <botlish_fn_43+0x23e>
			3bdb: R_X86_64_PLT32	rt_mutarray_set-0x4
    3bdf:	test   rax,rax
    3be2:	jne    3c1f <botlish_fn_43+0x27e>
    3be8:	xor    rax,rax
    3beb:	mov    rbx,QWORD PTR [rsp+0xa0]
    3bf3:	mov    r12,QWORD PTR [rsp+0xa8]
    3bfb:	mov    r13,QWORD PTR [rsp+0xb0]
    3c03:	mov    r14,QWORD PTR [rsp+0xb8]
    3c0b:	mov    r15,QWORD PTR [rsp+0xc0]
    3c13:	add    rsp,0xd0
    3c1a:	mov    rsp,rbp
    3c1d:	pop    rbp
    3c1e:	ret
    3c1f:	mov    eax,0xa
    3c24:	mov    rbx,QWORD PTR [rsp+0xa0]
    3c2c:	mov    r12,QWORD PTR [rsp+0xa8]
    3c34:	mov    r13,QWORD PTR [rsp+0xb0]
    3c3c:	mov    r14,QWORD PTR [rsp+0xb8]
    3c44:	mov    r15,QWORD PTR [rsp+0xc0]
    3c4c:	add    rsp,0xd0
    3c53:	mov    rsp,rbp
    3c56:	pop    rbp
    3c57:	ret

0000000000003c58 <botlish_entry_43: ht_rehash<mutarray, int>>:
    3c58:	push   rbp
    3c59:	mov    rbp,rsp
    3c5c:	mov    rsi,QWORD PTR [rdx]
    3c5f:	mov    rdx,QWORD PTR [rdx+0x8]
    3c63:	call   3c68 <botlish_entry_43+0x10>
			3c64: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    3c68:	mov    rsp,rbp
    3c6b:	pop    rbp
    3c6c:	ret
    3c6d:	add    BYTE PTR [rax],al
	...

0000000000003c70 <botlish_fn_44: ht_should_grow<mutarray>>:
    3c70:	push   rbp
    3c71:	mov    rbp,rsp
    3c74:	sub    rsp,0x40
    3c78:	mov    QWORD PTR [rsp+0x20],rbx
    3c7d:	mov    QWORD PTR [rsp+0x28],r12
    3c82:	mov    QWORD PTR [rsp+0x30],r13
    3c87:	mov    rbx,rdi
    3c8a:	mov    QWORD PTR [rsp],rsi
    3c8e:	mov    r12,rsi
    3c91:	mov    rsi,r12
    3c94:	mov    rdi,rbx
    3c97:	call   3c9c <botlish_fn_44+0x2c>
			3c98: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3c9c:	mov    rcx,rax
    3c9f:	mov    r13,rax
    3ca2:	test   rax,rcx
    3ca5:	je     3e94 <botlish_fn_44+0x224>
    3cab:	mov    rax,r13
    3cae:	mov    QWORD PTR [rsp+0x8],rax
    3cb3:	mov    rsi,r12
    3cb6:	mov    rdi,rbx
    3cb9:	call   3cbe <botlish_fn_44+0x4e>
			3cba: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3cbe:	mov    rcx,rax
    3cc1:	test   rcx,rcx
    3cc4:	je     3e94 <botlish_fn_44+0x224>
    3cca:	mov    QWORD PTR [rsp+0x10],rcx
    3ccf:	mov    edx,0x1
    3cd4:	mov    rax,r13
    3cd7:	test   rax,0x1
    3cdd:	jne    3d00 <botlish_fn_44+0x90>
    3ce3:	xor    edx,edx
    3ce5:	mov    rax,r13
    3ce8:	test   rax,0x7
    3cee:	jne    3d00 <botlish_fn_44+0x90>
    3cf4:	mov    rax,r13
    3cf7:	movzx  rax,BYTE PTR [rax]
    3cfb:	cmp    al,0x1
    3cfd:	sete   dl
    3d00:	test   dl,dl
    3d02:	jne    3d23 <botlish_fn_44+0xb3>
    3d08:	mov    rdi,rbx
    3d0b:	mov    rax,QWORD PTR [rdi+0x10]
    3d0f:	mov    rcx,QWORD PTR [rax+0x38]
    3d13:	xor    rdx,rdx
    3d16:	mov    rsi,r13
    3d19:	call   3d1e <botlish_fn_44+0xae>
			3d1a: R_X86_64_PLT32	rt_type_error-0x4
    3d1e:	jmp    3e94 <botlish_fn_44+0x224>
    3d23:	mov    eax,0x1
    3d28:	test   rcx,0x1
    3d2f:	je     3d3d <botlish_fn_44+0xcd>
    3d35:	mov    r8,rcx
    3d38:	jmp    3d60 <botlish_fn_44+0xf0>
    3d3d:	xor    eax,eax
    3d3f:	test   rcx,0x7
    3d46:	je     3d54 <botlish_fn_44+0xe4>
    3d4c:	mov    r8,rcx
    3d4f:	jmp    3d60 <botlish_fn_44+0xf0>
    3d54:	movzx  rax,BYTE PTR [rcx]
    3d58:	mov    r8,rcx
    3d5b:	cmp    al,0x1
    3d5d:	sete   al
    3d60:	test   al,al
    3d62:	jne    3d83 <botlish_fn_44+0x113>
    3d68:	mov    rdi,rbx
    3d6b:	mov    rax,QWORD PTR [rdi+0x10]
    3d6f:	mov    rcx,QWORD PTR [rax+0x38]
    3d73:	xor    rdx,rdx
    3d76:	mov    rsi,r8
    3d79:	call   3d7e <botlish_fn_44+0x10e>
			3d7a: R_X86_64_PLT32	rt_type_error-0x4
    3d7e:	jmp    3e94 <botlish_fn_44+0x224>
    3d83:	mov    rcx,r8
    3d86:	mov    rsi,r13
    3d89:	mov    rax,rsi
    3d8c:	and    rax,rcx
    3d8f:	test   rax,0x1
    3d95:	jne    3da6 <botlish_fn_44+0x136>
    3d9b:	mov    rdx,r8
    3d9e:	mov    rsi,r13
    3da1:	jmp    3dc4 <botlish_fn_44+0x154>
    3da6:	mov    rcx,r8
    3da9:	lea    rax,[rcx-0x1]
    3dad:	mov    rsi,r13
    3db0:	add    rsi,rax
    3db3:	seto   al
    3db6:	test   al,al
    3db8:	je     3dcf <botlish_fn_44+0x15f>
    3dbe:	mov    rdx,r8
    3dc1:	mov    rsi,r13
    3dc4:	mov    rdi,rbx
    3dc7:	call   3dcc <botlish_fn_44+0x15c>
			3dc8: R_X86_64_PLT32	rt_int_add-0x4
    3dcc:	mov    rsi,rax
    3dcf:	mov    QWORD PTR [rsp+0x8],rsi
    3dd4:	mov    QWORD PTR [rsp+0x10],0x3
    3ddd:	test   rsi,0x1
    3de4:	je     3e07 <botlish_fn_44+0x197>
    3dea:	mov    rax,rsi
    3ded:	add    rax,0x2
    3df1:	mov    rcx,rax
    3df4:	seto   al
    3df7:	test   al,al
    3df9:	jne    3e07 <botlish_fn_44+0x197>
    3dff:	mov    rsi,rcx
    3e02:	jmp    3e17 <botlish_fn_44+0x1a7>
    3e07:	mov    edx,0x3
    3e0c:	mov    rdi,rbx
    3e0f:	call   3e14 <botlish_fn_44+0x1a4>
			3e10: R_X86_64_PLT32	rt_int_add-0x4
    3e14:	mov    rsi,rax
    3e17:	mov    QWORD PTR [rsp+0x8],rsi
    3e1c:	mov    edx,0x7
    3e21:	mov    rdi,rdx
    3e24:	mov    QWORD PTR [rsp+0x10],0x7
    3e2d:	test   rsi,0x1
    3e34:	jne    3e42 <botlish_fn_44+0x1d2>
    3e3a:	mov    rdx,rdi
    3e3d:	jmp    3e6e <botlish_fn_44+0x1fe>
    3e42:	mov    rax,rsi
    3e45:	sar    rax,1
    3e48:	imul   QWORD PTR [rip+0x119]        # 3f68 <botlish_fn_44+0x2f8>
    3e4f:	seto   cl
    3e52:	or     rax,0x1
    3e56:	test   cl,cl
    3e58:	je     3e66 <botlish_fn_44+0x1f6>
    3e5e:	mov    rdx,rdi
    3e61:	jmp    3e6e <botlish_fn_44+0x1fe>
    3e66:	mov    rsi,rax
    3e69:	jmp    3e79 <botlish_fn_44+0x209>
    3e6e:	mov    rdi,rbx
    3e71:	call   3e76 <botlish_fn_44+0x206>
			3e72: R_X86_64_PLT32	rt_int_mul-0x4
    3e76:	mov    rsi,rax
    3e79:	mov    QWORD PTR [rsp],rsi
    3e7d:	mov    r13,rsi
    3e80:	mov    rsi,r12
    3e83:	mov    rdi,rbx
    3e86:	call   3e8b <botlish_fn_44+0x21b>
			3e87: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3e8b:	test   rax,rax
    3e8e:	jne    3eaf <botlish_fn_44+0x23f>
    3e94:	xor    rax,rax
    3e97:	mov    rbx,QWORD PTR [rsp+0x20]
    3e9c:	mov    r12,QWORD PTR [rsp+0x28]
    3ea1:	mov    r13,QWORD PTR [rsp+0x30]
    3ea6:	add    rsp,0x40
    3eaa:	mov    rsp,rbp
    3ead:	pop    rbp
    3eae:	ret
    3eaf:	mov    QWORD PTR [rsp+0x8],rax
    3eb4:	mov    QWORD PTR [rsp+0x10],0x5
    3ebd:	test   rax,0x1
    3ec3:	mov    rsi,rax
    3ec6:	je     3ef8 <botlish_fn_44+0x288>
    3ecc:	mov    rcx,rsi
    3ecf:	mov    rax,rcx
    3ed2:	sar    rax,1
    3ed5:	imul   QWORD PTR [rip+0x94]        # 3f70 <botlish_fn_44+0x300>
    3edc:	seto   dil
    3ee0:	or     rax,0x1
    3ee4:	test   dil,dil
    3ee7:	jne    3ef8 <botlish_fn_44+0x288>
    3eed:	mov    rdx,rax
    3ef0:	mov    rsi,r13
    3ef3:	jmp    3f0b <botlish_fn_44+0x29b>
    3ef8:	mov    edx,0x5
    3efd:	mov    rdi,rbx
    3f00:	call   3f05 <botlish_fn_44+0x295>
			3f01: R_X86_64_PLT32	rt_int_mul-0x4
    3f05:	mov    rdx,rax
    3f08:	mov    rsi,r13
    3f0b:	mov    r10,rsi
    3f0e:	and    r10,rdx
    3f11:	test   r10,0x1
    3f18:	jne    3f3f <botlish_fn_44+0x2cf>
    3f1e:	mov    rdi,rbx
    3f21:	call   3f26 <botlish_fn_44+0x2b6>
			3f22: R_X86_64_PLT32	rt_int_cmp-0x4
    3f26:	mov    r8d,0x2
    3f2c:	test   rax,rax
    3f2f:	mov    rax,r8
    3f32:	cmovg  rax,QWORD PTR [rip+0x2e]        # 3f68 <botlish_fn_44+0x2f8>
    3f3a:	jmp    3f4f <botlish_fn_44+0x2df>
    3f3f:	mov    eax,0x2
    3f44:	cmp    rsi,rdx
    3f47:	cmovg  rax,QWORD PTR [rip+0x19]        # 3f68 <botlish_fn_44+0x2f8>
    3f4f:	mov    rbx,QWORD PTR [rsp+0x20]
    3f54:	mov    r12,QWORD PTR [rsp+0x28]
    3f59:	mov    r13,QWORD PTR [rsp+0x30]
    3f5e:	add    rsp,0x40
    3f62:	mov    rsp,rbp
    3f65:	pop    rbp
    3f66:	ret
    3f67:	add    BYTE PTR [rsi],al
    3f69:	add    BYTE PTR [rax],al
    3f6b:	add    BYTE PTR [rax],al
    3f6d:	add    BYTE PTR [rax],al
    3f6f:	add    BYTE PTR [rax+rax*1],al
    3f72:	add    BYTE PTR [rax],al
    3f74:	add    BYTE PTR [rax],al
	...

0000000000003f78 <botlish_entry_44: ht_should_grow<mutarray>>:
    3f78:	push   rbp
    3f79:	mov    rbp,rsp
    3f7c:	mov    rsi,QWORD PTR [rdx]
    3f7f:	call   3f84 <botlish_entry_44+0xc>
			3f80: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    3f84:	mov    rsp,rbp
    3f87:	pop    rbp
    3f88:	ret
    3f89:	add    BYTE PTR [rax],al
    3f8b:	add    BYTE PTR [rax],al
    3f8d:	add    BYTE PTR [rax],al
	...

0000000000003f90 <botlish_fn_45: ht_grow_or_clean<mutarray>>:
    3f90:	push   rbp
    3f91:	mov    rbp,rsp
    3f94:	sub    rsp,0x40
    3f98:	mov    QWORD PTR [rsp+0x20],rbx
    3f9d:	mov    QWORD PTR [rsp+0x28],r12
    3fa2:	mov    QWORD PTR [rsp+0x30],r13
    3fa7:	mov    rbx,rdi
    3faa:	mov    QWORD PTR [rsp+0x10],0x0
    3fb3:	mov    QWORD PTR [rsp],rsi
    3fb7:	mov    r12,rsi
    3fba:	mov    rsi,r12
    3fbd:	mov    rdi,rbx
    3fc0:	call   3fc5 <botlish_fn_45+0x35>
			3fc1: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3fc5:	test   rax,rax
    3fc8:	mov    r13,rax
    3fcb:	je     41b8 <botlish_fn_45+0x228>
    3fd1:	mov    rsi,r12
    3fd4:	mov    rdi,rbx
    3fd7:	call   3fdc <botlish_fn_45+0x4c>
			3fd8: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    3fdc:	mov    rcx,rax
    3fdf:	test   rcx,rcx
    3fe2:	je     41b8 <botlish_fn_45+0x228>
    3fe8:	mov    edx,0x1
    3fed:	mov    rax,r13
    3ff0:	test   rax,0x1
    3ff6:	je     4004 <botlish_fn_45+0x74>
    3ffc:	mov    r13,rax
    3fff:	jmp    4028 <botlish_fn_45+0x98>
    4004:	xor    edx,edx
    4006:	test   rax,0x7
    400c:	je     401a <botlish_fn_45+0x8a>
    4012:	mov    r13,rax
    4015:	jmp    4028 <botlish_fn_45+0x98>
    401a:	movzx  rdx,BYTE PTR [rax]
    401e:	mov    r13,rax
    4021:	rex cmp dl,0x1
    4025:	sete   dl
    4028:	test   dl,dl
    402a:	jne    404b <botlish_fn_45+0xbb>
    4030:	mov    rdi,rbx
    4033:	mov    rsi,QWORD PTR [rdi+0x10]
    4037:	mov    rcx,QWORD PTR [rsi+0x40]
    403b:	xor    rdx,rdx
    403e:	mov    rsi,r13
    4041:	call   4046 <botlish_fn_45+0xb6>
			4042: R_X86_64_PLT32	rt_type_error-0x4
    4046:	jmp    41b8 <botlish_fn_45+0x228>
    404b:	mov    rsi,r13
    404e:	mov    eax,0x1
    4053:	test   rcx,0x1
    405a:	je     4068 <botlish_fn_45+0xd8>
    4060:	mov    r8,rcx
    4063:	jmp    408d <botlish_fn_45+0xfd>
    4068:	xor    eax,eax
    406a:	test   rcx,0x7
    4071:	je     407f <botlish_fn_45+0xef>
    4077:	mov    r8,rcx
    407a:	jmp    408d <botlish_fn_45+0xfd>
    407f:	movzx  r11,BYTE PTR [rcx]
    4083:	mov    r8,rcx
    4086:	cmp    r11b,0x1
    408a:	sete   al
    408d:	test   al,al
    408f:	jne    40b0 <botlish_fn_45+0x120>
    4095:	mov    rdi,rbx
    4098:	mov    rax,QWORD PTR [rdi+0x10]
    409c:	mov    rcx,QWORD PTR [rax+0x40]
    40a0:	xor    rdx,rdx
    40a3:	mov    rsi,r8
    40a6:	call   40ab <botlish_fn_45+0x11b>
			40a7: R_X86_64_PLT32	rt_type_error-0x4
    40ab:	jmp    41b8 <botlish_fn_45+0x228>
    40b0:	mov    rcx,r8
    40b3:	mov    rax,rsi
    40b6:	and    rax,rcx
    40b9:	test   rax,0x1
    40bf:	jne    40e5 <botlish_fn_45+0x155>
    40c5:	mov    rdx,r8
    40c8:	mov    rdi,rbx
    40cb:	call   40d0 <botlish_fn_45+0x140>
			40cc: R_X86_64_PLT32	rt_int_cmp-0x4
    40d0:	mov    ecx,0x2
    40d5:	test   rax,rax
    40d8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 41f0 <botlish_fn_45+0x260>
    40e0:	jmp    40f8 <botlish_fn_45+0x168>
    40e5:	mov    ecx,0x2
    40ea:	mov    r9,r8
    40ed:	cmp    rsi,r9
    40f0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 41f0 <botlish_fn_45+0x260>
    40f8:	cmp    rcx,0x6
    40fc:	je     4188 <botlish_fn_45+0x1f8>
    4102:	mov    rsi,r12
    4105:	mov    rdi,rbx
    4108:	call   410d <botlish_fn_45+0x17d>
			4109: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    410d:	test   rax,rax
    4110:	je     41b8 <botlish_fn_45+0x228>
    4116:	mov    QWORD PTR [rsp+0x8],rax
    411b:	mov    QWORD PTR [rsp+0x10],0x5
    4124:	test   rax,0x1
    412a:	mov    rsi,rax
    412d:	je     415a <botlish_fn_45+0x1ca>
    4133:	mov    rcx,rsi
    4136:	mov    rax,rcx
    4139:	sar    rax,1
    413c:	imul   QWORD PTR [rip+0xb5]        # 41f8 <botlish_fn_45+0x268>
    4143:	seto   cl
    4146:	or     rax,0x1
    414a:	test   cl,cl
    414c:	jne    415a <botlish_fn_45+0x1ca>
    4152:	mov    rdx,rax
    4155:	jmp    416a <botlish_fn_45+0x1da>
    415a:	mov    edx,0x5
    415f:	mov    rdi,rbx
    4162:	call   4167 <botlish_fn_45+0x1d7>
			4163: R_X86_64_PLT32	rt_int_mul-0x4
    4167:	mov    rdx,rax
    416a:	mov    QWORD PTR [rsp+0x8],rdx
    416f:	mov    rsi,r12
    4172:	mov    rdi,rbx
    4175:	call   417a <botlish_fn_45+0x1ea>
			4176: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    417a:	test   rax,rax
    417d:	je     41b8 <botlish_fn_45+0x228>
    4183:	jmp    41d3 <botlish_fn_45+0x243>
    4188:	mov    rsi,r12
    418b:	mov    rdi,rbx
    418e:	call   4193 <botlish_fn_45+0x203>
			418f: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4193:	test   rax,rax
    4196:	je     41b8 <botlish_fn_45+0x228>
    419c:	mov    QWORD PTR [rsp+0x8],rax
    41a1:	mov    rdx,rax
    41a4:	mov    rsi,r12
    41a7:	mov    rdi,rbx
    41aa:	call   41af <botlish_fn_45+0x21f>
			41ab: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash<mutarray, int>
    41af:	test   rax,rax
    41b2:	jne    41d3 <botlish_fn_45+0x243>
    41b8:	xor    rax,rax
    41bb:	mov    rbx,QWORD PTR [rsp+0x20]
    41c0:	mov    r12,QWORD PTR [rsp+0x28]
    41c5:	mov    r13,QWORD PTR [rsp+0x30]
    41ca:	add    rsp,0x40
    41ce:	mov    rsp,rbp
    41d1:	pop    rbp
    41d2:	ret
    41d3:	mov    rbx,QWORD PTR [rsp+0x20]
    41d8:	mov    r12,QWORD PTR [rsp+0x28]
    41dd:	mov    r13,QWORD PTR [rsp+0x30]
    41e2:	add    rsp,0x40
    41e6:	mov    rsp,rbp
    41e9:	pop    rbp
    41ea:	ret
    41eb:	add    BYTE PTR [rax],al
    41ed:	add    BYTE PTR [rax],al
    41ef:	add    BYTE PTR [rsi],al
    41f1:	add    BYTE PTR [rax],al
    41f3:	add    BYTE PTR [rax],al
    41f5:	add    BYTE PTR [rax],al
    41f7:	add    BYTE PTR [rax+rax*1],al
    41fa:	add    BYTE PTR [rax],al
    41fc:	add    BYTE PTR [rax],al
	...

0000000000004200 <botlish_entry_45: ht_grow_or_clean<mutarray>>:
    4200:	push   rbp
    4201:	mov    rbp,rsp
    4204:	mov    rsi,QWORD PTR [rdx]
    4207:	call   420c <botlish_entry_45+0xc>
			4208: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    420c:	mov    rsp,rbp
    420f:	pop    rbp
    4210:	ret
    4211:	add    BYTE PTR [rax],al
    4213:	add    BYTE PTR [rax],al
    4215:	add    BYTE PTR [rax],al
	...

0000000000004218 <botlish_fn_46: ht_place<mutarray, int, str, str>>:
    4218:	push   rbp
    4219:	mov    rbp,rsp
    421c:	sub    rsp,0x70
    4220:	mov    QWORD PTR [rsp+0x40],rbx
    4225:	mov    QWORD PTR [rsp+0x48],r12
    422a:	mov    QWORD PTR [rsp+0x50],r13
    422f:	mov    QWORD PTR [rsp+0x58],r14
    4234:	mov    QWORD PTR [rsp+0x60],r15
    4239:	mov    rbx,rdi
    423c:	mov    r14,r8
    423f:	mov    r15,rdx
    4242:	mov    QWORD PTR [rsp+0x28],rcx
    4247:	mov    QWORD PTR [rsp],rsi
    424b:	mov    r12,rsi
    424e:	mov    rsi,r12
    4251:	mov    rdi,rbx
    4254:	call   4259 <botlish_fn_46+0x41>
			4255: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    4259:	test   rax,rax
    425c:	je     45c0 <botlish_fn_46+0x3a8>
    4262:	xor    ecx,ecx
    4264:	test   rax,0x7
    426a:	je     427a <botlish_fn_46+0x62>
    4270:	mov    QWORD PTR [rsp+0x30],rax
    4275:	jmp    428a <botlish_fn_46+0x72>
    427a:	movzx  rcx,BYTE PTR [rax]
    427e:	mov    QWORD PTR [rsp+0x30],rax
    4283:	rex cmp cl,0x8
    4287:	sete   cl
    428a:	test   cl,cl
    428c:	jne    42b1 <botlish_fn_46+0x99>
    4292:	mov    rdi,rbx
    4295:	mov    rax,QWORD PTR [rdi+0x10]
    4299:	mov    rcx,QWORD PTR [rax+0x30]
    429d:	mov    edx,0x8
    42a2:	mov    rsi,QWORD PTR [rsp+0x30]
    42a7:	call   42ac <botlish_fn_46+0x94>
			42a8: R_X86_64_PLT32	rt_type_error-0x4
    42ac:	jmp    45c0 <botlish_fn_46+0x3a8>
    42b1:	mov    rdx,r15
    42b4:	mov    rsi,QWORD PTR [rsp+0x30]
    42b9:	mov    rdi,rbx
    42bc:	call   42c1 <botlish_fn_46+0xa9>
			42bd: R_X86_64_PLT32	rt_mutarray_get-0x4
    42c1:	test   rax,rax
    42c4:	je     45c0 <botlish_fn_46+0x3a8>
    42ca:	mov    QWORD PTR [rsp+0x8],rax
    42cf:	mov    r13,rax
    42d2:	mov    ecx,0x3
    42d7:	mov    rsi,QWORD PTR [rsp+0x30]
    42dc:	mov    rdx,r15
    42df:	mov    rdi,rbx
    42e2:	call   42e7 <botlish_fn_46+0xcf>
			42e3: R_X86_64_PLT32	rt_mutarray_set-0x4
    42e7:	test   rax,rax
    42ea:	je     45c0 <botlish_fn_46+0x3a8>
    42f0:	mov    rsi,r12
    42f3:	mov    rdi,rbx
    42f6:	call   42fb <botlish_fn_46+0xe3>
			42f7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_keys<mutarray>
    42fb:	test   rax,rax
    42fe:	je     45c0 <botlish_fn_46+0x3a8>
    4304:	xor    ecx,ecx
    4306:	test   rax,0x7
    430c:	je     431a <botlish_fn_46+0x102>
    4312:	mov    rsi,rax
    4315:	jmp    4328 <botlish_fn_46+0x110>
    431a:	movzx  rcx,BYTE PTR [rax]
    431e:	mov    rsi,rax
    4321:	rex cmp cl,0x8
    4325:	sete   cl
    4328:	test   cl,cl
    432a:	jne    4349 <botlish_fn_46+0x131>
    4330:	mov    rdi,rbx
    4333:	mov    rax,QWORD PTR [rdi+0x10]
    4337:	mov    rcx,QWORD PTR [rax]
    433a:	mov    edx,0x8
    433f:	call   4344 <botlish_fn_46+0x12c>
			4340: R_X86_64_PLT32	rt_type_error-0x4
    4344:	jmp    45c0 <botlish_fn_46+0x3a8>
    4349:	mov    rcx,QWORD PTR [rsp+0x28]
    434e:	mov    rdx,r15
    4351:	mov    rdi,rbx
    4354:	call   4359 <botlish_fn_46+0x141>
			4355: R_X86_64_PLT32	rt_mutarray_set-0x4
    4359:	test   rax,rax
    435c:	je     45c0 <botlish_fn_46+0x3a8>
    4362:	mov    rsi,r12
    4365:	mov    rdi,rbx
    4368:	call   436d <botlish_fn_46+0x155>
			4369: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    436d:	test   rax,rax
    4370:	je     45c0 <botlish_fn_46+0x3a8>
    4376:	xor    esi,esi
    4378:	test   rax,0x7
    437e:	jne    4390 <botlish_fn_46+0x178>
    4384:	movzx  rcx,BYTE PTR [rax]
    4388:	rex cmp cl,0x8
    438c:	sete   sil
    4390:	test   sil,sil
    4393:	jne    43b5 <botlish_fn_46+0x19d>
    4399:	mov    rdi,rbx
    439c:	mov    rsi,QWORD PTR [rdi+0x10]
    43a0:	mov    rcx,QWORD PTR [rsi]
    43a3:	mov    edx,0x8
    43a8:	mov    rsi,rax
    43ab:	call   43b0 <botlish_fn_46+0x198>
			43ac: R_X86_64_PLT32	rt_type_error-0x4
    43b0:	jmp    45c0 <botlish_fn_46+0x3a8>
    43b5:	mov    rcx,r14
    43b8:	mov    rdx,r15
    43bb:	mov    rsi,rax
    43be:	mov    rdi,rbx
    43c1:	call   43c6 <botlish_fn_46+0x1ae>
			43c2: R_X86_64_PLT32	rt_mutarray_set-0x4
    43c6:	test   rax,rax
    43c9:	je     45c0 <botlish_fn_46+0x3a8>
    43cf:	mov    QWORD PTR [rsp+0x10],0x7
    43d8:	mov    rsi,r12
    43db:	mov    rdi,rbx
    43de:	call   43e3 <botlish_fn_46+0x1cb>
			43df: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    43e3:	test   rax,rax
    43e6:	je     45c0 <botlish_fn_46+0x3a8>
    43ec:	mov    QWORD PTR [rsp+0x18],rax
    43f1:	mov    QWORD PTR [rsp+0x20],0x3
    43fa:	mov    ecx,0x1
    43ff:	test   rax,0x1
    4405:	je     4413 <botlish_fn_46+0x1fb>
    440b:	mov    rsi,rax
    440e:	jmp    4437 <botlish_fn_46+0x21f>
    4413:	xor    ecx,ecx
    4415:	test   rax,0x7
    441b:	je     4429 <botlish_fn_46+0x211>
    4421:	mov    rsi,rax
    4424:	jmp    4437 <botlish_fn_46+0x21f>
    4429:	movzx  rcx,BYTE PTR [rax]
    442d:	mov    rsi,rax
    4430:	rex cmp cl,0x1
    4434:	sete   cl
    4437:	test   cl,cl
    4439:	jne    4457 <botlish_fn_46+0x23f>
    443f:	mov    rdi,rbx
    4442:	mov    rax,QWORD PTR [rdi+0x10]
    4446:	mov    rcx,QWORD PTR [rax+0x38]
    444a:	xor    rdx,rdx
    444d:	call   4452 <botlish_fn_46+0x23a>
			444e: R_X86_64_PLT32	rt_type_error-0x4
    4452:	jmp    45c0 <botlish_fn_46+0x3a8>
    4457:	test   rsi,0x1
    445e:	je     4476 <botlish_fn_46+0x25e>
    4464:	mov    rcx,rsi
    4467:	add    rcx,0x2
    446b:	seto   al
    446e:	test   al,al
    4470:	je     4486 <botlish_fn_46+0x26e>
    4476:	mov    edx,0x3
    447b:	mov    rdi,rbx
    447e:	call   4483 <botlish_fn_46+0x26b>
			447f: R_X86_64_PLT32	rt_int_add-0x4
    4483:	mov    rcx,rax
    4486:	mov    edx,0x7
    448b:	mov    rsi,r12
    448e:	mov    rdi,rbx
    4491:	call   4496 <botlish_fn_46+0x27e>
			4492: R_X86_64_PLT32	rt_mutarray_set-0x4
    4496:	test   rax,rax
    4499:	je     45c0 <botlish_fn_46+0x3a8>
    449f:	mov    rax,r13
    44a2:	test   rax,0x1
    44a8:	jne    44cc <botlish_fn_46+0x2b4>
    44ae:	mov    edx,0x5
    44b3:	mov    rsi,r13
    44b6:	mov    rdi,rbx
    44b9:	call   44be <botlish_fn_46+0x2a6>
			44ba: R_X86_64_PLT32	rt_value_eq-0x4
    44be:	test   rax,rax
    44c1:	je     45c0 <botlish_fn_46+0x3a8>
    44c7:	jmp    44e0 <botlish_fn_46+0x2c8>
    44cc:	mov    rsi,r13
    44cf:	mov    eax,0x2
    44d4:	cmp    rsi,0x5
    44d8:	cmove  rax,QWORD PTR [rip+0x130]        # 4610 <botlish_fn_46+0x3f8>
    44e0:	cmp    rax,0x6
    44e4:	jne    45e5 <botlish_fn_46+0x3cd>
    44ea:	mov    QWORD PTR [rsp+0x8],0x9
    44f3:	mov    rsi,r12
    44f6:	mov    rdi,rbx
    44f9:	call   44fe <botlish_fn_46+0x2e6>
			44fa: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    44fe:	test   rax,rax
    4501:	je     45c0 <botlish_fn_46+0x3a8>
    4507:	mov    QWORD PTR [rsp+0x10],rax
    450c:	mov    QWORD PTR [rsp+0x18],0x3
    4515:	mov    ecx,0x1
    451a:	test   rax,0x1
    4520:	je     452e <botlish_fn_46+0x316>
    4526:	mov    rsi,rax
    4529:	jmp    4552 <botlish_fn_46+0x33a>
    452e:	xor    ecx,ecx
    4530:	test   rax,0x7
    4536:	je     4544 <botlish_fn_46+0x32c>
    453c:	mov    rsi,rax
    453f:	jmp    4552 <botlish_fn_46+0x33a>
    4544:	movzx  rcx,BYTE PTR [rax]
    4548:	mov    rsi,rax
    454b:	rex cmp cl,0x1
    454f:	sete   cl
    4552:	test   cl,cl
    4554:	jne    4572 <botlish_fn_46+0x35a>
    455a:	mov    rdi,rbx
    455d:	mov    rcx,QWORD PTR [rdi+0x10]
    4561:	mov    rcx,QWORD PTR [rcx+0x48]
    4565:	xor    rdx,rdx
    4568:	call   456d <botlish_fn_46+0x355>
			4569: R_X86_64_PLT32	rt_type_error-0x4
    456d:	jmp    45c0 <botlish_fn_46+0x3a8>
    4572:	test   rsi,0x1
    4579:	je     4597 <botlish_fn_46+0x37f>
    457f:	mov    r8,rsi
    4582:	sub    r8,0x3
    4586:	seto   dil
    458a:	lea    rcx,[r8+0x1]
    458e:	test   dil,dil
    4591:	je     45a7 <botlish_fn_46+0x38f>
    4597:	mov    edx,0x3
    459c:	mov    rdi,rbx
    459f:	call   45a4 <botlish_fn_46+0x38c>
			45a0: R_X86_64_PLT32	rt_int_sub-0x4
    45a4:	mov    rcx,rax
    45a7:	mov    edx,0x9
    45ac:	mov    rsi,r12
    45af:	mov    rdi,rbx
    45b2:	call   45b7 <botlish_fn_46+0x39f>
			45b3: R_X86_64_PLT32	rt_mutarray_set-0x4
    45b7:	test   rax,rax
    45ba:	jne    45e5 <botlish_fn_46+0x3cd>
    45c0:	xor    rax,rax
    45c3:	mov    rbx,QWORD PTR [rsp+0x40]
    45c8:	mov    r12,QWORD PTR [rsp+0x48]
    45cd:	mov    r13,QWORD PTR [rsp+0x50]
    45d2:	mov    r14,QWORD PTR [rsp+0x58]
    45d7:	mov    r15,QWORD PTR [rsp+0x60]
    45dc:	add    rsp,0x70
    45e0:	mov    rsp,rbp
    45e3:	pop    rbp
    45e4:	ret
    45e5:	mov    eax,0xa
    45ea:	mov    rbx,QWORD PTR [rsp+0x40]
    45ef:	mov    r12,QWORD PTR [rsp+0x48]
    45f4:	mov    r13,QWORD PTR [rsp+0x50]
    45f9:	mov    r14,QWORD PTR [rsp+0x58]
    45fe:	mov    r15,QWORD PTR [rsp+0x60]
    4603:	add    rsp,0x70
    4607:	mov    rsp,rbp
    460a:	pop    rbp
    460b:	ret
    460c:	add    BYTE PTR [rax],al
    460e:	add    BYTE PTR [rax],al
    4610:	(bad)
    4611:	add    BYTE PTR [rax],al
    4613:	add    BYTE PTR [rax],al
    4615:	add    BYTE PTR [rax],al
	...

0000000000004618 <botlish_entry_46: ht_place<mutarray, int, str, str>>:
    4618:	push   rbp
    4619:	mov    rbp,rsp
    461c:	mov    rsi,QWORD PTR [rdx]
    461f:	mov    r9,QWORD PTR [rdx+0x8]
    4623:	mov    rcx,QWORD PTR [rdx+0x10]
    4627:	mov    r8,QWORD PTR [rdx+0x18]
    462b:	mov    rdx,r9
    462e:	call   4633 <botlish_entry_46+0x1b>
			462f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4633:	mov    rsp,rbp
    4636:	pop    rbp
    4637:	ret

0000000000004638 <botlish_fn_47: ht_set<mutarray, str, str>>:
    4638:	push   rbp
    4639:	mov    rbp,rsp
    463c:	sub    rsp,0x60
    4640:	mov    QWORD PTR [rsp+0x30],rbx
    4645:	mov    QWORD PTR [rsp+0x38],r12
    464a:	mov    QWORD PTR [rsp+0x40],r13
    464f:	mov    QWORD PTR [rsp+0x48],r14
    4654:	mov    QWORD PTR [rsp+0x50],r15
    4659:	mov    rbx,rdi
    465c:	mov    r13,rdx
    465f:	mov    QWORD PTR [rsp],rsi
    4663:	mov    r14,rsi
    4666:	mov    QWORD PTR [rsp+0x8],rdx
    466b:	mov    QWORD PTR [rsp+0x10],rcx
    4670:	mov    r12,rcx
    4673:	mov    rdx,r13
    4676:	mov    rsi,r14
    4679:	mov    rdi,rbx
    467c:	call   4681 <botlish_fn_47+0x49>
			467d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    4681:	test   rax,rax
    4684:	je     48ee <botlish_fn_47+0x2b6>
    468a:	mov    QWORD PTR [rsp+0x18],rax
    468f:	mov    rcx,rax
    4692:	mov    r8,0xffffffffffffffff
    4699:	mov    QWORD PTR [rsp+0x28],r8
    469e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    46a7:	mov    rdx,r13
    46aa:	mov    rsi,r14
    46ad:	mov    rdi,rbx
    46b0:	call   46b5 <botlish_fn_47+0x7d>
			46b1: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    46b5:	mov    rcx,rax
    46b8:	mov    r15,rax
    46bb:	test   rax,rcx
    46be:	je     48ee <botlish_fn_47+0x2b6>
    46c4:	mov    rax,r15
    46c7:	mov    QWORD PTR [rsp+0x18],rax
    46cc:	mov    rsi,r14
    46cf:	mov    rdi,rbx
    46d2:	call   46d7 <botlish_fn_47+0x9f>
			46d3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_controls<mutarray>
    46d7:	test   rax,rax
    46da:	je     48ee <botlish_fn_47+0x2b6>
    46e0:	xor    ecx,ecx
    46e2:	test   rax,0x7
    46e8:	je     46f6 <botlish_fn_47+0xbe>
    46ee:	mov    r8,rax
    46f1:	jmp    4704 <botlish_fn_47+0xcc>
    46f6:	movzx  rcx,BYTE PTR [rax]
    46fa:	mov    r8,rax
    46fd:	rex cmp cl,0x8
    4701:	sete   cl
    4704:	test   cl,cl
    4706:	jne    4729 <botlish_fn_47+0xf1>
    470c:	mov    rdi,rbx
    470f:	mov    rsi,QWORD PTR [rdi+0x10]
    4713:	mov    rcx,QWORD PTR [rsi+0x30]
    4717:	mov    edx,0x8
    471c:	mov    rsi,r8
    471f:	call   4724 <botlish_fn_47+0xec>
			4720: R_X86_64_PLT32	rt_type_error-0x4
    4724:	jmp    48ee <botlish_fn_47+0x2b6>
    4729:	mov    rsi,r8
    472c:	mov    rdx,r15
    472f:	mov    rdi,rbx
    4732:	call   4737 <botlish_fn_47+0xff>
			4733: R_X86_64_PLT32	rt_mutarray_get-0x4
    4737:	test   rax,rax
    473a:	je     48ee <botlish_fn_47+0x2b6>
    4740:	test   rax,0x1
    4746:	mov    rsi,rax
    4749:	jne    476a <botlish_fn_47+0x132>
    474f:	mov    edx,0x3
    4754:	mov    rdi,rbx
    4757:	call   475c <botlish_fn_47+0x124>
			4758: R_X86_64_PLT32	rt_value_eq-0x4
    475c:	test   rax,rax
    475f:	je     48ee <botlish_fn_47+0x2b6>
    4765:	jmp    477b <botlish_fn_47+0x143>
    476a:	mov    eax,0x2
    476f:	cmp    rsi,0x3
    4773:	cmove  rax,QWORD PTR [rip+0x1c5]        # 4940 <botlish_fn_47+0x308>
    477b:	cmp    rax,0x6
    477f:	je     487e <botlish_fn_47+0x246>
    4785:	mov    rsi,r14
    4788:	mov    rdi,rbx
    478b:	call   4790 <botlish_fn_47+0x158>
			478c: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_should_grow<mutarray>
    4790:	test   rax,rax
    4793:	je     48ee <botlish_fn_47+0x2b6>
    4799:	cmp    rax,0x6
    479d:	je     47e2 <botlish_fn_47+0x1aa>
    47a3:	mov    rcx,r13
    47a6:	mov    rdx,r15
    47a9:	mov    rsi,r14
    47ac:	mov    rdi,rbx
    47af:	mov    r8,r12
    47b2:	call   47b7 <botlish_fn_47+0x17f>
			47b3: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    47b7:	test   rax,rax
    47ba:	je     48ee <botlish_fn_47+0x2b6>
    47c0:	mov    rbx,QWORD PTR [rsp+0x30]
    47c5:	mov    r12,QWORD PTR [rsp+0x38]
    47ca:	mov    r13,QWORD PTR [rsp+0x40]
    47cf:	mov    r14,QWORD PTR [rsp+0x48]
    47d4:	mov    r15,QWORD PTR [rsp+0x50]
    47d9:	add    rsp,0x60
    47dd:	mov    rsp,rbp
    47e0:	pop    rbp
    47e1:	ret
    47e2:	mov    rsi,r14
    47e5:	mov    rdi,rbx
    47e8:	call   47ed <botlish_fn_47+0x1b5>
			47e9: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_grow_or_clean<mutarray>
    47ed:	test   rax,rax
    47f0:	je     48ee <botlish_fn_47+0x2b6>
    47f6:	mov    rdx,r13
    47f9:	mov    rsi,r14
    47fc:	mov    rdi,rbx
    47ff:	call   4804 <botlish_fn_47+0x1cc>
			4800: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_probe_start<mutarray, str>
    4804:	test   rax,rax
    4807:	je     48ee <botlish_fn_47+0x2b6>
    480d:	mov    QWORD PTR [rsp+0x18],rax
    4812:	mov    rcx,rax
    4815:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    481e:	mov    r8,QWORD PTR [rsp+0x28]
    4823:	mov    rdx,r13
    4826:	mov    rsi,r14
    4829:	mov    rdi,rbx
    482c:	call   4831 <botlish_fn_47+0x1f9>
			482d: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_find_insert<mutarray, str, int, int>
    4831:	test   rax,rax
    4834:	je     48ee <botlish_fn_47+0x2b6>
    483a:	mov    QWORD PTR [rsp+0x18],rax
    483f:	mov    rcx,r13
    4842:	mov    rdx,rax
    4845:	mov    rsi,r14
    4848:	mov    rdi,rbx
    484b:	mov    r8,r12
    484e:	call   4853 <botlish_fn_47+0x21b>
			484f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_place<mutarray, int, str, str>
    4853:	test   rax,rax
    4856:	je     48ee <botlish_fn_47+0x2b6>
    485c:	mov    rbx,QWORD PTR [rsp+0x30]
    4861:	mov    r12,QWORD PTR [rsp+0x38]
    4866:	mov    r13,QWORD PTR [rsp+0x40]
    486b:	mov    r14,QWORD PTR [rsp+0x48]
    4870:	mov    r15,QWORD PTR [rsp+0x50]
    4875:	add    rsp,0x60
    4879:	mov    rsp,rbp
    487c:	pop    rbp
    487d:	ret
    487e:	mov    rsi,r14
    4881:	mov    rdi,rbx
    4884:	call   4889 <botlish_fn_47+0x251>
			4885: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_values<mutarray>
    4889:	test   rax,rax
    488c:	je     48ee <botlish_fn_47+0x2b6>
    4892:	xor    ecx,ecx
    4894:	test   rax,0x7
    489a:	je     48a8 <botlish_fn_47+0x270>
    48a0:	mov    rsi,rax
    48a3:	jmp    48b6 <botlish_fn_47+0x27e>
    48a8:	movzx  rcx,BYTE PTR [rax]
    48ac:	mov    rsi,rax
    48af:	rex cmp cl,0x8
    48b3:	sete   cl
    48b6:	test   cl,cl
    48b8:	jne    48d7 <botlish_fn_47+0x29f>
    48be:	mov    rdi,rbx
    48c1:	mov    rax,QWORD PTR [rdi+0x10]
    48c5:	mov    rcx,QWORD PTR [rax]
    48c8:	mov    edx,0x8
    48cd:	call   48d2 <botlish_fn_47+0x29a>
			48ce: R_X86_64_PLT32	rt_type_error-0x4
    48d2:	jmp    48ee <botlish_fn_47+0x2b6>
    48d7:	mov    rcx,r12
    48da:	mov    rdx,r15
    48dd:	mov    rdi,rbx
    48e0:	call   48e5 <botlish_fn_47+0x2ad>
			48e1: R_X86_64_PLT32	rt_mutarray_set-0x4
    48e5:	test   rax,rax
    48e8:	jne    4913 <botlish_fn_47+0x2db>
    48ee:	xor    rax,rax
    48f1:	mov    rbx,QWORD PTR [rsp+0x30]
    48f6:	mov    r12,QWORD PTR [rsp+0x38]
    48fb:	mov    r13,QWORD PTR [rsp+0x40]
    4900:	mov    r14,QWORD PTR [rsp+0x48]
    4905:	mov    r15,QWORD PTR [rsp+0x50]
    490a:	add    rsp,0x60
    490e:	mov    rsp,rbp
    4911:	pop    rbp
    4912:	ret
    4913:	mov    eax,0xa
    4918:	mov    rbx,QWORD PTR [rsp+0x30]
    491d:	mov    r12,QWORD PTR [rsp+0x38]
    4922:	mov    r13,QWORD PTR [rsp+0x40]
    4927:	mov    r14,QWORD PTR [rsp+0x48]
    492c:	mov    r15,QWORD PTR [rsp+0x50]
    4931:	add    rsp,0x60
    4935:	mov    rsp,rbp
    4938:	pop    rbp
    4939:	ret
    493a:	add    BYTE PTR [rax],al
    493c:	add    BYTE PTR [rax],al
    493e:	add    BYTE PTR [rax],al
    4940:	(bad)
    4941:	add    BYTE PTR [rax],al
    4943:	add    BYTE PTR [rax],al
    4945:	add    BYTE PTR [rax],al
	...

0000000000004948 <botlish_entry_47: ht_set<mutarray, str, str>>:
    4948:	push   rbp
    4949:	mov    rbp,rsp
    494c:	mov    rsi,QWORD PTR [rdx]
    494f:	mov    r8,QWORD PTR [rdx+0x8]
    4953:	mov    rcx,QWORD PTR [rdx+0x10]
    4957:	mov    rdx,r8
    495a:	call   495f <botlish_entry_47+0x17>
			495b: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    495f:	mov    rsp,rbp
    4962:	pop    rbp
    4963:	ret

0000000000004964 <botlish_fn_48: row_new<bool, int>>:
    4964:	push   rbp
    4965:	mov    rbp,rsp
    4968:	sub    rsp,0x10
    496c:	mov    QWORD PTR [rsp],rdx
    4970:	mov    r8,rdx
    4973:	cmp    rsi,0x6
    4977:	je     4994 <botlish_fn_48+0x30>
    497d:	call   4982 <botlish_fn_48+0x1e>
			497e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_new<generic>
    4982:	test   rax,rax
    4985:	je     49a5 <botlish_fn_48+0x41>
    498b:	add    rsp,0x10
    498f:	mov    rsp,rbp
    4992:	pop    rbp
    4993:	ret
    4994:	mov    rsi,r8
    4997:	call   499c <botlish_fn_48+0x38>
			4998: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_new_sized<int>
    499c:	test   rax,rax
    499f:	jne    49b1 <botlish_fn_48+0x4d>
    49a5:	xor    rax,rax
    49a8:	add    rsp,0x10
    49ac:	mov    rsp,rbp
    49af:	pop    rbp
    49b0:	ret
    49b1:	add    rsp,0x10
    49b5:	mov    rsp,rbp
    49b8:	pop    rbp
    49b9:	ret

00000000000049ba <botlish_entry_48: row_new<bool, int>>:
    49ba:	push   rbp
    49bb:	mov    rbp,rsp
    49be:	mov    rsi,QWORD PTR [rdx]
    49c1:	mov    rdx,QWORD PTR [rdx+0x8]
    49c5:	call   49ca <botlish_entry_48+0x10>
			49c6: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    49ca:	mov    rsp,rbp
    49cd:	pop    rbp
    49ce:	ret

00000000000049cf <botlish_fn_49: row_fill<mutarray, List[str], List[str], int, int>>:
    49cf:	push   rbp
    49d0:	mov    rbp,rsp
    49d3:	sub    rsp,0x70
    49d7:	mov    QWORD PTR [rsp+0x40],rbx
    49dc:	mov    QWORD PTR [rsp+0x48],r12
    49e1:	mov    QWORD PTR [rsp+0x50],r13
    49e6:	mov    QWORD PTR [rsp+0x58],r14
    49eb:	mov    QWORD PTR [rsp+0x60],r15
    49f0:	mov    QWORD PTR [rsp+0x28],rdi
    49f5:	mov    QWORD PTR [rsp],rsi
    49f9:	mov    r14,rsi
    49fc:	mov    QWORD PTR [rsp+0x8],rdx
    4a01:	mov    QWORD PTR [rsp+0x10],rcx
    4a06:	mov    r13,rcx
    4a09:	sar    r8,1
    4a0c:	mov    rbx,r8
    4a0f:	mov    r15,r9
    4a12:	cmp    rbx,r15
    4a15:	jge    4b20 <botlish_fn_49+0x151>
    4a1b:	mov    r12,rdx
    4a1e:	mov    rdx,QWORD PTR [r12+0x8]
    4a23:	mov    rcx,rbx
    4a26:	shl    rcx,1
    4a29:	or     rcx,0x1
    4a2d:	sar    rcx,1
    4a30:	cmp    rcx,rdx
    4a33:	jb     4a61 <botlish_fn_49+0x92>
    4a39:	mov    rdx,rbx
    4a3c:	shl    rdx,1
    4a3f:	or     rdx,0x1
    4a43:	mov    rsi,r12
    4a46:	mov    rdi,QWORD PTR [rsp+0x28]
    4a4b:	call   4a50 <botlish_fn_49+0x81>
			4a4c: R_X86_64_PLT32	rt_list_get-0x4
    4a50:	test   rax,rax
    4a53:	je     4ade <botlish_fn_49+0x10f>
    4a59:	mov    rdx,rax
    4a5c:	jmp    4a6a <botlish_fn_49+0x9b>
    4a61:	mov    rax,QWORD PTR [r12+0x10]
    4a66:	mov    rdx,QWORD PTR [rax+rcx*8]
    4a6a:	mov    QWORD PTR [rsp+0x18],rdx
    4a6f:	mov    QWORD PTR [rsp+0x30],rdx
    4a74:	mov    rax,QWORD PTR [r13+0x8]
    4a78:	mov    rcx,rbx
    4a7b:	shl    rcx,1
    4a7e:	or     rcx,0x1
    4a82:	sar    rcx,1
    4a85:	cmp    rcx,rax
    4a88:	jb     4ab6 <botlish_fn_49+0xe7>
    4a8e:	mov    rdx,rbx
    4a91:	shl    rdx,1
    4a94:	or     rdx,0x1
    4a98:	mov    rsi,r13
    4a9b:	mov    rdi,QWORD PTR [rsp+0x28]
    4aa0:	call   4aa5 <botlish_fn_49+0xd6>
			4aa1: R_X86_64_PLT32	rt_list_get-0x4
    4aa5:	test   rax,rax
    4aa8:	je     4ade <botlish_fn_49+0x10f>
    4aae:	mov    rcx,rax
    4ab1:	jmp    4abe <botlish_fn_49+0xef>
    4ab6:	mov    rax,QWORD PTR [r13+0x10]
    4aba:	mov    rcx,QWORD PTR [rax+rcx*8]
    4abe:	mov    QWORD PTR [rsp+0x20],rcx
    4ac3:	mov    rdx,QWORD PTR [rsp+0x30]
    4ac8:	mov    rsi,r14
    4acb:	mov    rdi,QWORD PTR [rsp+0x28]
    4ad0:	call   4ad5 <botlish_fn_49+0x106>
			4ad1: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_set<mutarray, str, str>
    4ad5:	test   rax,rax
    4ad8:	jne    4b03 <botlish_fn_49+0x134>
    4ade:	xor    rax,rax
    4ae1:	mov    rbx,QWORD PTR [rsp+0x40]
    4ae6:	mov    r12,QWORD PTR [rsp+0x48]
    4aeb:	mov    r13,QWORD PTR [rsp+0x50]
    4af0:	mov    r14,QWORD PTR [rsp+0x58]
    4af5:	mov    r15,QWORD PTR [rsp+0x60]
    4afa:	add    rsp,0x70
    4afe:	mov    rsp,rbp
    4b01:	pop    rbp
    4b02:	ret
    4b03:	mov    QWORD PTR [rsp],r14
    4b07:	mov    QWORD PTR [rsp+0x8],r12
    4b0c:	mov    QWORD PTR [rsp+0x10],r13
    4b11:	add    rbx,0x1
    4b18:	mov    rdx,r12
    4b1b:	jmp    4a12 <botlish_fn_49+0x43>
    4b20:	mov    rax,r14
    4b23:	mov    rbx,QWORD PTR [rsp+0x40]
    4b28:	mov    r12,QWORD PTR [rsp+0x48]
    4b2d:	mov    r13,QWORD PTR [rsp+0x50]
    4b32:	mov    r14,QWORD PTR [rsp+0x58]
    4b37:	mov    r15,QWORD PTR [rsp+0x60]
    4b3c:	add    rsp,0x70
    4b40:	mov    rsp,rbp
    4b43:	pop    rbp
    4b44:	ret

0000000000004b45 <botlish_entry_49: row_fill<mutarray, List[str], List[str], int, int>>:
    4b45:	push   rbp
    4b46:	mov    rbp,rsp
    4b49:	mov    rsi,QWORD PTR [rdx]
    4b4c:	mov    r10,QWORD PTR [rdx+0x8]
    4b50:	mov    rcx,QWORD PTR [rdx+0x10]
    4b54:	mov    r8,QWORD PTR [rdx+0x18]
    4b58:	mov    r9,QWORD PTR [rdx+0x20]
    4b5c:	sar    r9,1
    4b5f:	mov    rdx,r10
    4b62:	call   4b67 <botlish_entry_49+0x22>
			4b63: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4b67:	mov    rsp,rbp
    4b6a:	pop    rbp
    4b6b:	ret

0000000000004b6c <botlish_fn_50: row_table<List[str], int, List[str], bool>>:
    4b6c:	push   rbp
    4b6d:	mov    rbp,rsp
    4b70:	sub    rsp,0x50
    4b74:	mov    QWORD PTR [rsp+0x20],rbx
    4b79:	mov    QWORD PTR [rsp+0x28],r12
    4b7e:	mov    QWORD PTR [rsp+0x30],r13
    4b83:	mov    QWORD PTR [rsp+0x38],r14
    4b88:	mov    QWORD PTR [rsp+0x40],r15
    4b8d:	mov    r12,rdi
    4b90:	mov    QWORD PTR [rsp],rsi
    4b94:	mov    r15,rsi
    4b97:	mov    QWORD PTR [rsp+0x8],rdx
    4b9c:	mov    QWORD PTR [rsp+0x10],rcx
    4ba1:	mov    r13,rcx
    4ba4:	mov    QWORD PTR [rsp+0x18],r8
    4ba9:	mov    rsi,r8
    4bac:	mov    rdi,r12
    4baf:	call   4bb4 <botlish_fn_50+0x48>
			4bb0: R_X86_64_PLT32	botlish_fn_48-0x4 ; row_new<bool, int>
    4bb4:	test   rax,rax
    4bb7:	je     4c01 <botlish_fn_50+0x95>
    4bbd:	mov    QWORD PTR [rsp+0x8],rax
    4bc2:	mov    r14,rax
    4bc5:	mov    ebx,0x1
    4bca:	mov    QWORD PTR [rsp+0x18],0x1
    4bd3:	mov    rsi,r13
    4bd6:	mov    rdi,r12
    4bd9:	call   4bde <botlish_fn_50+0x72>
			4bda: R_X86_64_PLT32	rt_list_len-0x4
    4bde:	mov    r9,rax
    4be1:	sar    r9,1
    4be4:	mov    rcx,r13
    4be7:	mov    rdx,r15
    4bea:	mov    rsi,r14
    4bed:	mov    rdi,r12
    4bf0:	mov    r8,rbx
    4bf3:	call   4bf8 <botlish_fn_50+0x8c>
			4bf4: R_X86_64_PLT32	botlish_fn_49-0x4 ; row_fill<mutarray, List[str], List[str], int, int>
    4bf8:	test   rax,rax
    4bfb:	jne    4c26 <botlish_fn_50+0xba>
    4c01:	xor    rax,rax
    4c04:	mov    rbx,QWORD PTR [rsp+0x20]
    4c09:	mov    r12,QWORD PTR [rsp+0x28]
    4c0e:	mov    r13,QWORD PTR [rsp+0x30]
    4c13:	mov    r14,QWORD PTR [rsp+0x38]
    4c18:	mov    r15,QWORD PTR [rsp+0x40]
    4c1d:	add    rsp,0x50
    4c21:	mov    rsp,rbp
    4c24:	pop    rbp
    4c25:	ret
    4c26:	mov    rbx,QWORD PTR [rsp+0x20]
    4c2b:	mov    r12,QWORD PTR [rsp+0x28]
    4c30:	mov    r13,QWORD PTR [rsp+0x30]
    4c35:	mov    r14,QWORD PTR [rsp+0x38]
    4c3a:	mov    r15,QWORD PTR [rsp+0x40]
    4c3f:	add    rsp,0x50
    4c43:	mov    rsp,rbp
    4c46:	pop    rbp
    4c47:	ret

0000000000004c48 <botlish_entry_50: row_table<List[str], int, List[str], bool>>:
    4c48:	push   rbp
    4c49:	mov    rbp,rsp
    4c4c:	mov    rsi,QWORD PTR [rdx]
    4c4f:	mov    r9,QWORD PTR [rdx+0x8]
    4c53:	mov    rcx,QWORD PTR [rdx+0x10]
    4c57:	mov    r8,QWORD PTR [rdx+0x18]
    4c5b:	mov    rdx,r9
    4c5e:	call   4c63 <botlish_entry_50+0x1b>
			4c5f: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4c63:	mov    rsp,rbp
    4c66:	pop    rbp
    4c67:	ret

0000000000004c68 <botlish_fn_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4c68:	push   rbp
    4c69:	mov    rbp,rsp
    4c6c:	sub    rsp,0x90
    4c73:	mov    QWORD PTR [rsp+0x60],rbx
    4c78:	mov    QWORD PTR [rsp+0x68],r12
    4c7d:	mov    QWORD PTR [rsp+0x70],r13
    4c82:	mov    QWORD PTR [rsp+0x78],r14
    4c87:	mov    QWORD PTR [rsp+0x80],r15
    4c8f:	mov    r13,r8
    4c92:	mov    QWORD PTR [rsp+0x38],rdi
    4c97:	mov    rdi,QWORD PTR [rbp+0x10]
    4c9b:	mov    r15,QWORD PTR [rbp+0x18]
    4c9f:	mov    QWORD PTR [rsp+0x28],0x0
    4ca8:	mov    QWORD PTR [rsp+0x30],0x0
    4cb1:	mov    QWORD PTR [rsp],rsi
    4cb5:	mov    QWORD PTR [rsp+0x8],rcx
    4cba:	mov    r14,rcx
    4cbd:	mov    QWORD PTR [rsp+0x10],r9
    4cc2:	mov    QWORD PTR [rsp+0x18],rdi
    4cc7:	mov    QWORD PTR [rsp+0x20],r15
    4ccc:	sar    rdx,1
    4ccf:	mov    r12,rdx
    4cd2:	mov    rbx,rsi
    4cd5:	mov    QWORD PTR [rsp+0x40],r9
    4cda:	mov    QWORD PTR [rsp+0x48],rdi
    4cdf:	mov    rsi,rbx
    4ce2:	mov    rdi,QWORD PTR [rsp+0x38]
    4ce7:	call   4cec <botlish_fn_51+0x84>
			4ce8: R_X86_64_PLT32	rt_list_len-0x4
    4cec:	sar    rax,1
    4cef:	cmp    r12,rax
    4cf2:	jge    4e1d <botlish_fn_51+0x1b5>
    4cf8:	mov    rax,r13
    4cfb:	or     rax,0x1
    4cff:	mov    QWORD PTR [rsp+0x28],rax
    4d04:	mov    rcx,QWORD PTR [rbx+0x8]
    4d08:	mov    rax,r12
    4d0b:	shl    rax,1
    4d0e:	or     rax,0x1
    4d12:	sar    rax,1
    4d15:	cmp    rax,rcx
    4d18:	jb     4d46 <botlish_fn_51+0xde>
    4d1e:	mov    rdx,r12
    4d21:	shl    rdx,1
    4d24:	or     rdx,0x1
    4d28:	mov    rsi,rbx
    4d2b:	mov    rdi,QWORD PTR [rsp+0x38]
    4d30:	call   4d35 <botlish_fn_51+0xcd>
			4d31: R_X86_64_PLT32	rt_list_get-0x4
    4d35:	test   rax,rax
    4d38:	je     4e3a <botlish_fn_51+0x1d2>
    4d3e:	mov    rcx,rax
    4d41:	jmp    4d4e <botlish_fn_51+0xe6>
    4d46:	mov    rcx,QWORD PTR [rbx+0x10]
    4d4a:	mov    rcx,QWORD PTR [rcx+rax*8]
    4d4e:	mov    QWORD PTR [rsp+0x30],rcx
    4d53:	mov    rdx,r13
    4d56:	or     rdx,0x1
    4d5a:	mov    rsi,r14
    4d5d:	mov    rdi,QWORD PTR [rsp+0x38]
    4d62:	mov    r8,r15
    4d65:	call   4d6a <botlish_fn_51+0x102>
			4d66: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4d6a:	test   rax,rax
    4d6d:	je     4e3a <botlish_fn_51+0x1d2>
    4d73:	mov    QWORD PTR [rsp+0x28],rax
    4d78:	mov    rcx,rax
    4d7b:	mov    rsi,QWORD PTR [rsp+0x40]
    4d80:	mov    rdx,QWORD PTR [rsp+0x48]
    4d85:	mov    rdi,QWORD PTR [rsp+0x38]
    4d8a:	call   4d8f <botlish_fn_51+0x127>
			4d8b: R_X86_64_PLT32	botlish_fn_13-0x4 ; geo_append<mutarray, int, mutarray>
    4d8f:	test   rax,rax
    4d92:	je     4e3a <botlish_fn_51+0x1d2>
    4d98:	mov    QWORD PTR [rsp+0x10],rax
    4d9d:	mov    QWORD PTR [rsp+0x50],rax
    4da2:	mov    QWORD PTR [rsp+0x28],0x3
    4dab:	mov    rsi,QWORD PTR [rsp+0x48]
    4db0:	test   rsi,0x1
    4db7:	je     4dd6 <botlish_fn_51+0x16e>
    4dbd:	mov    rsi,QWORD PTR [rsp+0x48]
    4dc2:	mov    rax,rsi
    4dc5:	add    rax,0x2
    4dc9:	seto   r10b
    4dcd:	test   r10b,r10b
    4dd0:	je     4dea <botlish_fn_51+0x182>
    4dd6:	mov    edx,0x3
    4ddb:	mov    rsi,QWORD PTR [rsp+0x48]
    4de0:	mov    rdi,QWORD PTR [rsp+0x38]
    4de5:	call   4dea <botlish_fn_51+0x182>
			4de6: R_X86_64_PLT32	rt_int_add-0x4
    4dea:	mov    QWORD PTR [rsp],rbx
    4dee:	mov    QWORD PTR [rsp+0x8],r14
    4df3:	mov    rcx,QWORD PTR [rsp+0x50]
    4df8:	mov    QWORD PTR [rsp+0x10],rcx
    4dfd:	mov    QWORD PTR [rsp+0x18],rax
    4e02:	mov    QWORD PTR [rsp+0x20],r15
    4e07:	add    r12,0x1
    4e0e:	mov    QWORD PTR [rsp+0x40],rcx
    4e13:	mov    QWORD PTR [rsp+0x48],rax
    4e18:	jmp    4cdf <botlish_fn_51+0x77>
    4e1d:	mov    rdx,QWORD PTR [rsp+0x48]
    4e22:	mov    rsi,QWORD PTR [rsp+0x40]
    4e27:	mov    rdi,QWORD PTR [rsp+0x38]
    4e2c:	call   4e31 <botlish_fn_51+0x1c9>
			4e2d: R_X86_64_PLT32	botlish_fn_14-0x4 ; geo_finish<mutarray, int>
    4e31:	test   rax,rax
    4e34:	jne    4e65 <botlish_fn_51+0x1fd>
    4e3a:	xor    rax,rax
    4e3d:	mov    rbx,QWORD PTR [rsp+0x60]
    4e42:	mov    r12,QWORD PTR [rsp+0x68]
    4e47:	mov    r13,QWORD PTR [rsp+0x70]
    4e4c:	mov    r14,QWORD PTR [rsp+0x78]
    4e51:	mov    r15,QWORD PTR [rsp+0x80]
    4e59:	add    rsp,0x90
    4e60:	mov    rsp,rbp
    4e63:	pop    rbp
    4e64:	ret
    4e65:	mov    rbx,QWORD PTR [rsp+0x60]
    4e6a:	mov    r12,QWORD PTR [rsp+0x68]
    4e6f:	mov    r13,QWORD PTR [rsp+0x70]
    4e74:	mov    r14,QWORD PTR [rsp+0x78]
    4e79:	mov    r15,QWORD PTR [rsp+0x80]
    4e81:	add    rsp,0x90
    4e88:	mov    rsp,rbp
    4e8b:	pop    rbp
    4e8c:	ret

0000000000004e8d <botlish_entry_51: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4e8d:	push   rbp
    4e8e:	mov    rbp,rsp
    4e91:	sub    rsp,0x10
    4e95:	mov    rsi,QWORD PTR [rdx]
    4e98:	mov    r10,QWORD PTR [rdx+0x8]
    4e9c:	mov    rcx,QWORD PTR [rdx+0x10]
    4ea0:	mov    r8,QWORD PTR [rdx+0x18]
    4ea4:	mov    r9,QWORD PTR [rdx+0x20]
    4ea8:	mov    r11,QWORD PTR [rdx+0x28]
    4eac:	mov    rax,QWORD PTR [rdx+0x30]
    4eb0:	mov    QWORD PTR [rsp],r11
    4eb4:	mov    QWORD PTR [rsp+0x8],rax
    4eb9:	mov    rdx,r10
    4ebc:	call   4ec1 <botlish_entry_51+0x34>
			4ebd: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4ec1:	add    rsp,0x10
    4ec5:	mov    rsp,rbp
    4ec8:	pop    rbp
    4ec9:	ret

0000000000004eca <botlish_fn_52: csv_records_generic<str, bool>>:
    4eca:	push   rbp
    4ecb:	mov    rbp,rsp
    4ece:	sub    rsp,0x80
    4ed5:	mov    QWORD PTR [rsp+0x50],rbx
    4eda:	mov    QWORD PTR [rsp+0x58],r12
    4edf:	mov    QWORD PTR [rsp+0x60],r13
    4ee4:	mov    QWORD PTR [rsp+0x68],r14
    4ee9:	mov    QWORD PTR [rsp+0x70],r15
    4eee:	mov    r12,rdi
    4ef1:	mov    QWORD PTR [rsp+0x20],0x0
    4efa:	mov    QWORD PTR [rsp+0x28],0x0
    4f03:	mov    QWORD PTR [rsp+0x30],0x0
    4f0c:	mov    QWORD PTR [rsp+0x38],0x0
    4f15:	mov    QWORD PTR [rsp+0x40],0x0
    4f1e:	mov    QWORD PTR [rsp+0x10],rsi
    4f23:	mov    QWORD PTR [rsp+0x18],rdx
    4f28:	mov    r13,rdx
    4f2b:	mov    rdi,r12
    4f2e:	call   4f33 <botlish_fn_52+0x69>
			4f2f: R_X86_64_PLT32	botlish_fn_23-0x4 ; csv_parse<str>
    4f33:	mov    rcx,rax
    4f36:	mov    r14,rax
    4f39:	test   rax,rcx
    4f3c:	je     5056 <botlish_fn_52+0x18c>
    4f42:	mov    rax,r14
    4f45:	mov    QWORD PTR [rsp+0x10],rax
    4f4a:	mov    rsi,r14
    4f4d:	mov    rdi,r12
    4f50:	call   4f55 <botlish_fn_52+0x8b>
			4f51: R_X86_64_PLT32	rt_list_len-0x4
    4f55:	sar    rax,1
    4f58:	cmp    rax,0x1
    4f5c:	jle    503f <botlish_fn_52+0x175>
    4f62:	mov    rax,r14
    4f65:	mov    rax,QWORD PTR [rax+0x10]
    4f69:	mov    rbx,QWORD PTR [rax]
    4f6c:	mov    QWORD PTR [rsp+0x20],rbx
    4f71:	mov    rsi,rbx
    4f74:	mov    rdi,r12
    4f77:	call   4f7c <botlish_fn_52+0xb2>
			4f78: R_X86_64_PLT32	rt_list_len-0x4
    4f7c:	mov    r15,rbx
    4f7f:	mov    QWORD PTR [rsp+0x28],rax
    4f84:	mov    QWORD PTR [rsp+0x48],rax
    4f89:	mov    rax,r14
    4f8c:	mov    rcx,QWORD PTR [rax+0x10]
    4f90:	mov    rcx,QWORD PTR [rcx+0x8]
    4f94:	mov    QWORD PTR [rsp+0x30],rcx
    4f99:	mov    rbx,r13
    4f9c:	mov    rdx,QWORD PTR [rsp+0x48]
    4fa1:	mov    rsi,r15
    4fa4:	mov    rdi,r12
    4fa7:	mov    r8,rbx
    4faa:	call   4faf <botlish_fn_52+0xe5>
			4fab: R_X86_64_PLT32	botlish_fn_50-0x4 ; row_table<List[str], int, List[str], bool>
    4faf:	test   rax,rax
    4fb2:	je     5056 <botlish_fn_52+0x18c>
    4fb8:	mov    QWORD PTR [rsp+0x30],rax
    4fbd:	mov    rsi,rax
    4fc0:	mov    QWORD PTR [rsp+0x38],0x5
    4fc9:	mov    rdi,r12
    4fcc:	call   4fd1 <botlish_fn_52+0x107>
			4fcd: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_new<mutarray>
    4fd1:	test   rax,rax
    4fd4:	je     5056 <botlish_fn_52+0x18c>
    4fda:	mov    QWORD PTR [rsp+0x30],rax
    4fdf:	mov    r9,rax
    4fe2:	mov    eax,0x3
    4fe7:	mov    QWORD PTR [rsp+0x40],0x3
    4ff0:	mov    edx,0x5
    4ff5:	mov    QWORD PTR [rsp],rax
    4ff9:	mov    QWORD PTR [rsp+0x8],rbx
    4ffe:	mov    rcx,r15
    5001:	mov    rsi,r14
    5004:	mov    rdi,r12
    5007:	mov    r8,QWORD PTR [rsp+0x48]
    500c:	call   5011 <botlish_fn_52+0x147>
			500d: R_X86_64_PLT32	botlish_fn_51-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    5011:	test   rax,rax
    5014:	je     5056 <botlish_fn_52+0x18c>
    501a:	mov    rbx,QWORD PTR [rsp+0x50]
    501f:	mov    r12,QWORD PTR [rsp+0x58]
    5024:	mov    r13,QWORD PTR [rsp+0x60]
    5029:	mov    r14,QWORD PTR [rsp+0x68]
    502e:	mov    r15,QWORD PTR [rsp+0x70]
    5033:	add    rsp,0x80
    503a:	mov    rsp,rbp
    503d:	pop    rbp
    503e:	ret
    503f:	xor    rdx,rdx
    5042:	mov    rdi,r12
    5045:	mov    rsi,rdx
    5048:	call   504d <botlish_fn_52+0x183>
			5049: R_X86_64_PLT32	rt_list_new-0x4
    504d:	test   rax,rax
    5050:	jne    507e <botlish_fn_52+0x1b4>
    5056:	xor    rax,rax
    5059:	mov    rbx,QWORD PTR [rsp+0x50]
    505e:	mov    r12,QWORD PTR [rsp+0x58]
    5063:	mov    r13,QWORD PTR [rsp+0x60]
    5068:	mov    r14,QWORD PTR [rsp+0x68]
    506d:	mov    r15,QWORD PTR [rsp+0x70]
    5072:	add    rsp,0x80
    5079:	mov    rsp,rbp
    507c:	pop    rbp
    507d:	ret
    507e:	mov    rbx,QWORD PTR [rsp+0x50]
    5083:	mov    r12,QWORD PTR [rsp+0x58]
    5088:	mov    r13,QWORD PTR [rsp+0x60]
    508d:	mov    r14,QWORD PTR [rsp+0x68]
    5092:	mov    r15,QWORD PTR [rsp+0x70]
    5097:	add    rsp,0x80
    509e:	mov    rsp,rbp
    50a1:	pop    rbp
    50a2:	ret

00000000000050a3 <botlish_entry_52: csv_records_generic<str, bool>>:
    50a3:	push   rbp
    50a4:	mov    rbp,rsp
    50a7:	mov    rsi,QWORD PTR [rdx]
    50aa:	mov    rdx,QWORD PTR [rdx+0x8]
    50ae:	call   50b3 <botlish_entry_52+0x10>
			50af: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50b3:	mov    rsp,rbp
    50b6:	pop    rbp
    50b7:	ret

00000000000050b8 <botlish_fn_53: csv_records<str>>:
    50b8:	push   rbp
    50b9:	mov    rbp,rsp
    50bc:	sub    rsp,0x10
    50c0:	mov    QWORD PTR [rsp],rsi
    50c4:	mov    edx,0x2
    50c9:	mov    QWORD PTR [rsp+0x8],0x2
    50d2:	call   50d7 <botlish_fn_53+0x1f>
			50d3: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    50d7:	test   rax,rax
    50da:	jne    50ec <botlish_fn_53+0x34>
    50e0:	xor    rax,rax
    50e3:	add    rsp,0x10
    50e7:	mov    rsp,rbp
    50ea:	pop    rbp
    50eb:	ret
    50ec:	add    rsp,0x10
    50f0:	mov    rsp,rbp
    50f3:	pop    rbp
    50f4:	ret

00000000000050f5 <botlish_entry_53: csv_records<str>>:
    50f5:	push   rbp
    50f6:	mov    rbp,rsp
    50f9:	mov    rsi,QWORD PTR [rdx]
    50fc:	call   5101 <botlish_entry_53+0xc>
			50fd: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    5101:	mov    rsp,rbp
    5104:	pop    rbp
    5105:	ret

0000000000005106 <botlish_fn_54: csv_records_presized<str>>:
    5106:	push   rbp
    5107:	mov    rbp,rsp
    510a:	sub    rsp,0x10
    510e:	mov    QWORD PTR [rsp],rsi
    5112:	mov    edx,0x6
    5117:	mov    QWORD PTR [rsp+0x8],0x6
    5120:	call   5125 <botlish_fn_54+0x1f>
			5121: R_X86_64_PLT32	botlish_fn_52-0x4 ; csv_records_generic<str, bool>
    5125:	test   rax,rax
    5128:	jne    513a <botlish_fn_54+0x34>
    512e:	xor    rax,rax
    5131:	add    rsp,0x10
    5135:	mov    rsp,rbp
    5138:	pop    rbp
    5139:	ret
    513a:	add    rsp,0x10
    513e:	mov    rsp,rbp
    5141:	pop    rbp
    5142:	ret

0000000000005143 <botlish_entry_54: csv_records_presized<str>>:
    5143:	push   rbp
    5144:	mov    rbp,rsp
    5147:	mov    rsi,QWORD PTR [rdx]
    514a:	call   514f <botlish_entry_54+0xc>
			514b: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    514f:	mov    rsp,rbp
    5152:	pop    rbp
    5153:	ret
    5154:	add    BYTE PTR [rax],al
	...

0000000000005158 <botlish_fn_55: sample_checks<generic>>:
    5158:	push   rbp
    5159:	mov    rbp,rsp
    515c:	sub    rsp,0xc0
    5163:	mov    QWORD PTR [rsp+0x90],rbx
    516b:	mov    QWORD PTR [rsp+0x98],r12
    5173:	mov    QWORD PTR [rsp+0xa0],r13
    517b:	mov    QWORD PTR [rsp+0xa8],r14
    5183:	mov    QWORD PTR [rsp+0xb0],r15
    518b:	mov    QWORD PTR [rsp+0x8],0x0
    5194:	mov    QWORD PTR [rsp+0x10],0x0
    519d:	mov    QWORD PTR [rsp+0x18],0x0
    51a6:	mov    QWORD PTR [rsp+0x20],0x0
    51af:	mov    QWORD PTR [rsp+0x28],0x0
    51b8:	mov    QWORD PTR [rsp+0x30],0x0
    51c1:	mov    QWORD PTR [rsp+0x38],0x0
    51ca:	mov    rax,QWORD PTR [rdi+0x10]
    51ce:	mov    r13,rdi
    51d1:	mov    rsi,QWORD PTR [rax+0x50]
    51d5:	mov    QWORD PTR [rsp],rsi
    51d9:	call   51de <botlish_fn_55+0x86>
			51da: R_X86_64_PLT32	botlish_fn_53-0x4 ; csv_records<str>
    51de:	mov    rsi,rax
    51e1:	mov    r12,rax
    51e4:	test   rax,rsi
    51e7:	je     556c <botlish_fn_55+0x414>
    51ed:	mov    rax,r12
    51f0:	mov    QWORD PTR [rsp],rax
    51f4:	mov    rdi,r13
    51f7:	mov    rax,QWORD PTR [rdi+0x10]
    51fb:	mov    rsi,QWORD PTR [rax+0x50]
    51ff:	mov    QWORD PTR [rsp+0x8],rsi
    5204:	call   5209 <botlish_fn_55+0xb1>
			5205: R_X86_64_PLT32	botlish_fn_54-0x4 ; csv_records_presized<str>
    5209:	mov    rbx,rax
    520c:	test   rbx,rbx
    520f:	je     556c <botlish_fn_55+0x414>
    5215:	mov    rax,r12
    5218:	mov    rax,QWORD PTR [rax+0x8]
    521c:	test   rax,rax
    521f:	jne    5246 <botlish_fn_55+0xee>
    5225:	mov    edx,0x1
    522a:	mov    rsi,r12
    522d:	mov    rdi,r13
    5230:	call   5235 <botlish_fn_55+0xdd>
			5231: R_X86_64_PLT32	rt_list_get-0x4
    5235:	test   rax,rax
    5238:	je     556c <botlish_fn_55+0x414>
    523e:	mov    rsi,rax
    5241:	jmp    524e <botlish_fn_55+0xf6>
    5246:	mov    rax,QWORD PTR [r12+0x10]
    524b:	mov    rsi,QWORD PTR [rax]
    524e:	mov    QWORD PTR [rsp+0x8],rsi
    5253:	mov    r15,rsi
    5256:	mov    rax,QWORD PTR [r12+0x8]
    525b:	cmp    rax,0x1
    525f:	ja     5286 <botlish_fn_55+0x12e>
    5265:	mov    edx,0x3
    526a:	mov    rsi,r12
    526d:	mov    rdi,r13
    5270:	call   5275 <botlish_fn_55+0x11d>
			5271: R_X86_64_PLT32	rt_list_get-0x4
    5275:	test   rax,rax
    5278:	je     556c <botlish_fn_55+0x414>
    527e:	mov    rsi,rax
    5281:	jmp    528f <botlish_fn_55+0x137>
    5286:	mov    rax,QWORD PTR [r12+0x10]
    528b:	mov    rsi,QWORD PTR [rax+0x8]
    528f:	mov    QWORD PTR [rsp+0x10],rsi
    5294:	mov    r14,rsi
    5297:	mov    rax,QWORD PTR [rbx+0x8]
    529b:	mov    rsi,rbx
    529e:	test   rax,rax
    52a1:	jne    52c5 <botlish_fn_55+0x16d>
    52a7:	mov    edx,0x1
    52ac:	mov    rdi,r13
    52af:	call   52b4 <botlish_fn_55+0x15c>
			52b0: R_X86_64_PLT32	rt_list_get-0x4
    52b4:	test   rax,rax
    52b7:	je     556c <botlish_fn_55+0x414>
    52bd:	mov    rsi,rax
    52c0:	jmp    52cc <botlish_fn_55+0x174>
    52c5:	mov    rax,QWORD PTR [rsi+0x10]
    52c9:	mov    rsi,QWORD PTR [rax]
    52cc:	mov    QWORD PTR [rsp+0x18],rsi
    52d1:	mov    rdi,r13
    52d4:	mov    QWORD PTR [rsp+0x78],rsi
    52d9:	mov    rax,QWORD PTR [rdi+0x10]
    52dd:	mov    rdx,QWORD PTR [rax+0x58]
    52e1:	mov    QWORD PTR [rsp+0x20],rdx
    52e6:	mov    rsi,r15
    52e9:	call   52ee <botlish_fn_55+0x196>
			52ea: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    52ee:	test   rax,rax
    52f1:	je     556c <botlish_fn_55+0x414>
    52f7:	mov    QWORD PTR [rsp+0x20],rax
    52fc:	mov    rbx,rax
    52ff:	mov    rdi,r13
    5302:	mov    rax,QWORD PTR [rdi+0x10]
    5306:	mov    rdx,QWORD PTR [rax+0x58]
    530a:	mov    QWORD PTR [rsp+0x28],rdx
    530f:	mov    rsi,QWORD PTR [rsp+0x78]
    5314:	call   5319 <botlish_fn_55+0x1c1>
			5315: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5319:	test   rax,rax
    531c:	je     556c <botlish_fn_55+0x414>
    5322:	mov    rcx,rbx
    5325:	mov    rdx,rcx
    5328:	and    rdx,rax
    532b:	test   rdx,0x1
    5332:	jne    5354 <botlish_fn_55+0x1fc>
    5338:	mov    rdx,rax
    533b:	mov    rsi,rbx
    533e:	mov    rdi,r13
    5341:	call   5346 <botlish_fn_55+0x1ee>
			5342: R_X86_64_PLT32	rt_value_eq-0x4
    5346:	test   rax,rax
    5349:	je     556c <botlish_fn_55+0x414>
    534f:	jmp    536a <botlish_fn_55+0x212>
    5354:	mov    rdx,rax
    5357:	mov    rsi,rbx
    535a:	mov    eax,0x2
    535f:	cmp    rsi,rdx
    5362:	cmove  rax,QWORD PTR [rip+0x26e]        # 55d8 <botlish_fn_55+0x480>
    536a:	mov    ebx,0x6
    536f:	cmp    rax,0x6
    5373:	je     538e <botlish_fn_55+0x236>
    5379:	mov    ebx,0x2
    537e:	mov    QWORD PTR [rsp],0x2
    5386:	mov    rsi,r12
    5389:	jmp    542d <botlish_fn_55+0x2d5>
    538e:	mov    rsi,r15
    5391:	mov    rdi,r13
    5394:	call   5399 <botlish_fn_55+0x241>
			5395: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    5399:	test   rax,rax
    539c:	mov    QWORD PTR [rsp+0x88],rax
    53a4:	je     556c <botlish_fn_55+0x414>
    53aa:	mov    rsi,QWORD PTR [rsp+0x78]
    53af:	mov    rdi,r13
    53b2:	call   53b7 <botlish_fn_55+0x25f>
			53b3: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<mutarray>
    53b7:	test   rax,rax
    53ba:	je     556c <botlish_fn_55+0x414>
    53c0:	mov    rcx,QWORD PTR [rsp+0x88]
    53c8:	mov    rdx,rcx
    53cb:	and    rdx,rax
    53ce:	test   rdx,0x1
    53d5:	jne    53fc <botlish_fn_55+0x2a4>
    53db:	mov    rdx,rax
    53de:	mov    rsi,QWORD PTR [rsp+0x88]
    53e6:	mov    rdi,r13
    53e9:	call   53ee <botlish_fn_55+0x296>
			53ea: R_X86_64_PLT32	rt_value_eq-0x4
    53ee:	test   rax,rax
    53f1:	je     556c <botlish_fn_55+0x414>
    53f7:	jmp    5417 <botlish_fn_55+0x2bf>
    53fc:	mov    rdx,rax
    53ff:	mov    rsi,QWORD PTR [rsp+0x88]
    5407:	mov    eax,0x2
    540c:	cmp    rsi,rdx
    540f:	cmove  rax,QWORD PTR [rip+0x1c1]        # 55d8 <botlish_fn_55+0x480>
    5417:	cmp    rax,0x6
    541b:	je     5426 <botlish_fn_55+0x2ce>
    5421:	mov    ebx,0x2
    5426:	mov    QWORD PTR [rsp],rbx
    542a:	mov    rsi,r12
    542d:	mov    rdi,r13
    5430:	call   5435 <botlish_fn_55+0x2dd>
			5431: R_X86_64_PLT32	rt_list_len-0x4
    5435:	mov    QWORD PTR [rsp+0x18],rax
    543a:	mov    rdi,r13
    543d:	mov    r12,rax
    5440:	mov    rax,QWORD PTR [rdi+0x10]
    5444:	mov    rdx,QWORD PTR [rax+0x58]
    5448:	mov    QWORD PTR [rsp+0x20],rdx
    544d:	mov    rsi,r15
    5450:	call   5455 <botlish_fn_55+0x2fd>
			5451: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5455:	test   rax,rax
    5458:	je     556c <botlish_fn_55+0x414>
    545e:	mov    QWORD PTR [rsp+0x20],rax
    5463:	mov    rdi,r13
    5466:	mov    QWORD PTR [rsp+0x88],rax
    546e:	mov    rax,QWORD PTR [rdi+0x10]
    5472:	mov    rdx,QWORD PTR [rax+0x60]
    5476:	mov    QWORD PTR [rsp+0x28],rdx
    547b:	mov    rsi,r15
    547e:	call   5483 <botlish_fn_55+0x32b>
			547f: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5483:	test   rax,rax
    5486:	je     556c <botlish_fn_55+0x414>
    548c:	mov    QWORD PTR [rsp+0x28],rax
    5491:	mov    rdi,r13
    5494:	mov    QWORD PTR [rsp+0x80],rax
    549c:	mov    rax,QWORD PTR [rdi+0x10]
    54a0:	mov    rdx,QWORD PTR [rax+0x68]
    54a4:	mov    QWORD PTR [rsp+0x30],rdx
    54a9:	mov    rsi,r15
    54ac:	call   54b1 <botlish_fn_55+0x359>
			54ad: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54b1:	test   rax,rax
    54b4:	je     556c <botlish_fn_55+0x414>
    54ba:	mov    QWORD PTR [rsp+0x8],rax
    54bf:	mov    rdi,r13
    54c2:	mov    r15,rax
    54c5:	mov    rax,QWORD PTR [rdi+0x10]
    54c9:	mov    rdx,QWORD PTR [rax+0x58]
    54cd:	mov    QWORD PTR [rsp+0x30],rdx
    54d2:	mov    rsi,r14
    54d5:	call   54da <botlish_fn_55+0x382>
			54d6: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    54da:	test   rax,rax
    54dd:	je     556c <botlish_fn_55+0x414>
    54e3:	mov    QWORD PTR [rsp+0x30],rax
    54e8:	mov    rdi,r13
    54eb:	mov    QWORD PTR [rsp+0x78],rax
    54f0:	mov    rax,QWORD PTR [rdi+0x10]
    54f4:	mov    rdx,QWORD PTR [rax+0x68]
    54f8:	mov    QWORD PTR [rsp+0x38],rdx
    54fd:	mov    rsi,r14
    5500:	call   5505 <botlish_fn_55+0x3ad>
			5501: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_get<mutarray, str>
    5505:	test   rax,rax
    5508:	je     556c <botlish_fn_55+0x414>
    550e:	mov    QWORD PTR [rsp+0x10],rax
    5513:	lea    rdx,[rsp+0x40]
    5518:	mov    r9,r12
    551b:	mov    QWORD PTR [rsp+0x40],r9
    5520:	mov    rcx,QWORD PTR [rsp+0x88]
    5528:	mov    QWORD PTR [rsp+0x48],rcx
    552d:	mov    rcx,QWORD PTR [rsp+0x80]
    5535:	mov    QWORD PTR [rsp+0x50],rcx
    553a:	mov    rcx,r15
    553d:	mov    QWORD PTR [rsp+0x58],rcx
    5542:	mov    rcx,QWORD PTR [rsp+0x78]
    5547:	mov    QWORD PTR [rsp+0x60],rcx
    554c:	mov    QWORD PTR [rsp+0x68],rax
    5551:	mov    QWORD PTR [rsp+0x70],rbx
    5556:	mov    esi,0x7
    555b:	mov    rdi,r13
    555e:	call   5563 <botlish_fn_55+0x40b>
			555f: R_X86_64_PLT32	rt_list_new-0x4
    5563:	test   rax,rax
    5566:	jne    55a3 <botlish_fn_55+0x44b>
    556c:	xor    rax,rax
    556f:	mov    rbx,QWORD PTR [rsp+0x90]
    5577:	mov    r12,QWORD PTR [rsp+0x98]
    557f:	mov    r13,QWORD PTR [rsp+0xa0]
    5587:	mov    r14,QWORD PTR [rsp+0xa8]
    558f:	mov    r15,QWORD PTR [rsp+0xb0]
    5597:	add    rsp,0xc0
    559e:	mov    rsp,rbp
    55a1:	pop    rbp
    55a2:	ret
    55a3:	mov    rbx,QWORD PTR [rsp+0x90]
    55ab:	mov    r12,QWORD PTR [rsp+0x98]
    55b3:	mov    r13,QWORD PTR [rsp+0xa0]
    55bb:	mov    r14,QWORD PTR [rsp+0xa8]
    55c3:	mov    r15,QWORD PTR [rsp+0xb0]
    55cb:	add    rsp,0xc0
    55d2:	mov    rsp,rbp
    55d5:	pop    rbp
    55d6:	ret
    55d7:	add    BYTE PTR [rsi],al
    55d9:	add    BYTE PTR [rax],al
    55db:	add    BYTE PTR [rax],al
    55dd:	add    BYTE PTR [rax],al
	...

00000000000055e0 <botlish_entry_55: sample_checks<generic>>:
    55e0:	push   rbp
    55e1:	mov    rbp,rsp
    55e4:	call   55e9 <botlish_entry_55+0x9>
			55e5: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample_checks<generic>
    55e9:	mov    rsp,rbp
    55ec:	pop    rbp
    55ed:	ret

00000000000055ee <botlish_fn_56: sample<generic>>:
    55ee:	push   rbp
    55ef:	mov    rbp,rsp
    55f2:	sub    rsp,0x10
    55f6:	mov    QWORD PTR [rsp],rbx
    55fa:	mov    rbx,rdi
    55fd:	mov    rdi,rbx
    5600:	call   5605 <botlish_fn_56+0x17>
			5601: R_X86_64_PLT32	botlish_fn_55-0x4 ; sample_checks<generic>
    5605:	test   rax,rax
    5608:	jne    56c1 <botlish_fn_56+0xd3>
    560e:	mov    rdi,rbx
    5611:	call   5616 <botlish_fn_56+0x28>
			5612: R_X86_64_PLT32	rt_declared_error-0x4
    5616:	cmp    rax,0x40000001
    561c:	je     5692 <botlish_fn_56+0xa4>
    5622:	mov    rdi,rbx
    5625:	call   562a <botlish_fn_56+0x3c>
			5626: R_X86_64_PLT32	rt_declared_error-0x4
    562a:	cmp    rax,0x40000002
    5630:	je     566e <botlish_fn_56+0x80>
    5636:	mov    rdi,rbx
    5639:	call   563e <botlish_fn_56+0x50>
			563a: R_X86_64_PLT32	rt_declared_error-0x4
    563e:	cmp    rax,0x40000003
    5644:	jne    56b1 <botlish_fn_56+0xc3>
    564a:	mov    rdi,rbx
    564d:	call   5652 <botlish_fn_56+0x64>
			564e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5652:	xor    rdx,rdx
    5655:	mov    rdi,rbx
    5658:	mov    rsi,rdx
    565b:	call   5660 <botlish_fn_56+0x72>
			565c: R_X86_64_PLT32	rt_list_new-0x4
    5660:	test   rax,rax
    5663:	je     56b1 <botlish_fn_56+0xc3>
    5669:	jmp    56c1 <botlish_fn_56+0xd3>
    566e:	mov    rdi,rbx
    5671:	call   5676 <botlish_fn_56+0x88>
			5672: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5676:	xor    rdx,rdx
    5679:	mov    rdi,rbx
    567c:	mov    rsi,rdx
    567f:	call   5684 <botlish_fn_56+0x96>
			5680: R_X86_64_PLT32	rt_list_new-0x4
    5684:	test   rax,rax
    5687:	je     56b1 <botlish_fn_56+0xc3>
    568d:	jmp    56c1 <botlish_fn_56+0xd3>
    5692:	mov    rdi,rbx
    5695:	call   569a <botlish_fn_56+0xac>
			5696: R_X86_64_PLT32	rt_clear_declared_error-0x4
    569a:	xor    rdx,rdx
    569d:	mov    rdi,rbx
    56a0:	mov    rsi,rdx
    56a3:	call   56a8 <botlish_fn_56+0xba>
			56a4: R_X86_64_PLT32	rt_list_new-0x4
    56a8:	test   rax,rax
    56ab:	jne    56c1 <botlish_fn_56+0xd3>
    56b1:	xor    rax,rax
    56b4:	mov    rbx,QWORD PTR [rsp]
    56b8:	add    rsp,0x10
    56bc:	mov    rsp,rbp
    56bf:	pop    rbp
    56c0:	ret
    56c1:	mov    rbx,QWORD PTR [rsp]
    56c5:	add    rsp,0x10
    56c9:	mov    rsp,rbp
    56cc:	pop    rbp
    56cd:	ret

00000000000056ce <botlish_entry_56: sample<generic>>:
    56ce:	push   rbp
    56cf:	mov    rbp,rsp
    56d2:	call   56d7 <botlish_entry_56+0x9>
			56d3: R_X86_64_PLT32	botlish_fn_56-0x4 ; sample<generic>
    56d7:	mov    rsp,rbp
    56da:	pop    rbp
    56db:	ret

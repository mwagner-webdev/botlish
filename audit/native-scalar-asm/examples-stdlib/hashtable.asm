; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 17415  (per function: 172 28 28 28 28 540 712 220 61 61 61 61 61 280 297 347 1036 1592 589 389 572 612 1585 1030 977 841 1496 1132 1477 1102)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> ht_min_capacity<generic>
;   botlish_fn_2 / botlish_entry_2 -> ht_empty_state<generic>
;   botlish_fn_3 / botlish_entry_3 -> ht_occupied_state<generic>
;   botlish_fn_4 / botlish_entry_4 -> ht_tombstone_state<generic>
;   botlish_fn_5 / botlish_entry_5 -> ht_fill_empty<mutarray, int, int>
;   botlish_fn_6 / botlish_entry_6 -> ht_alloc<int>
;   botlish_fn_7 / botlish_entry_7 -> ht_new<generic>
;   botlish_fn_8 / botlish_entry_8 -> ht_controls<mutarray>
;   botlish_fn_9 / botlish_entry_9 -> ht_keys<mutarray>
;   botlish_fn_10 / botlish_entry_10 -> ht_values<mutarray>
;   botlish_fn_11 / botlish_entry_11 -> ht_size<mutarray>
;   botlish_fn_12 / botlish_entry_12 -> ht_tombstones<mutarray>
;   botlish_fn_13 / botlish_entry_13 -> ht_capacity<mutarray>
;   botlish_fn_14 / botlish_entry_14 -> ht_probe_start<mutarray, str>
;   botlish_fn_15 / botlish_entry_15 -> ht_probe_next<mutarray, int>
;   botlish_fn_16 / botlish_entry_16 -> ht_find_get<mutarray, str, int>
;   botlish_fn_17 / botlish_entry_17 -> ht_find_insert<mutarray, str, int, int>
;   botlish_fn_18 / botlish_entry_18 -> ht_get<mutarray, str>
;   botlish_fn_19 / botlish_entry_19 -> ht_contains<mutarray, str>
;   botlish_fn_20 / botlish_entry_20 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_21 / botlish_entry_21 -> ht_rehash_insert<list<mutarray>, int, any, any>
;   botlish_fn_22 / botlish_entry_22 -> ht_rehash_scan<list, int, int, list<mutarray>, int>
;   botlish_fn_23 / botlish_entry_23 -> ht_rehash<mutarray, int>
;   botlish_fn_24 / botlish_entry_24 -> ht_should_grow<mutarray>
;   botlish_fn_25 / botlish_entry_25 -> ht_grow_or_clean<mutarray>
;   botlish_fn_26 / botlish_entry_26 -> ht_place<mutarray, int, str, str>
;   botlish_fn_27 / botlish_entry_27 -> ht_set<mutarray, str, str>
;   botlish_fn_28 / botlish_entry_28 -> ht_delete<mutarray, str>
;   botlish_fn_29 / botlish_entry_29 -> sample<generic>


hashtable.asm.o:     file format elf64-x86-64


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
			3d: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
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

00000000000000a5 <botlish_fn_1: ht_min_capacity<generic>>:
      a5:	push   rbp
      a6:	mov    rbp,rsp
      a9:	mov    eax,0x11
      ae:	mov    rsp,rbp
      b1:	pop    rbp
      b2:	ret

00000000000000b3 <botlish_entry_1: ht_min_capacity<generic>>:
      b3:	push   rbp
      b4:	mov    rbp,rsp
      b7:	call   bc <botlish_entry_1+0x9>
			b8: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
      bc:	mov    rsp,rbp
      bf:	pop    rbp
      c0:	ret

00000000000000c1 <botlish_fn_2: ht_empty_state<generic>>:
      c1:	push   rbp
      c2:	mov    rbp,rsp
      c5:	mov    eax,0x1
      ca:	mov    rsp,rbp
      cd:	pop    rbp
      ce:	ret

00000000000000cf <botlish_entry_2: ht_empty_state<generic>>:
      cf:	push   rbp
      d0:	mov    rbp,rsp
      d3:	call   d8 <botlish_entry_2+0x9>
			d4: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
      d8:	mov    rsp,rbp
      db:	pop    rbp
      dc:	ret

00000000000000dd <botlish_fn_3: ht_occupied_state<generic>>:
      dd:	push   rbp
      de:	mov    rbp,rsp
      e1:	mov    eax,0x3
      e6:	mov    rsp,rbp
      e9:	pop    rbp
      ea:	ret

00000000000000eb <botlish_entry_3: ht_occupied_state<generic>>:
      eb:	push   rbp
      ec:	mov    rbp,rsp
      ef:	call   f4 <botlish_entry_3+0x9>
			f0: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
      f4:	mov    rsp,rbp
      f7:	pop    rbp
      f8:	ret

00000000000000f9 <botlish_fn_4: ht_tombstone_state<generic>>:
      f9:	push   rbp
      fa:	mov    rbp,rsp
      fd:	mov    eax,0x5
     102:	mov    rsp,rbp
     105:	pop    rbp
     106:	ret

0000000000000107 <botlish_entry_4: ht_tombstone_state<generic>>:
     107:	push   rbp
     108:	mov    rbp,rsp
     10b:	call   110 <botlish_entry_4+0x9>
			10c: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
     110:	mov    rsp,rbp
     113:	pop    rbp
     114:	ret
     115:	add    BYTE PTR [rax],al
	...

0000000000000118 <botlish_fn_5: ht_fill_empty<mutarray, int, int>>:
     118:	push   rbp
     119:	mov    rbp,rsp
     11c:	sub    rsp,0x50
     120:	mov    QWORD PTR [rsp+0x20],rbx
     125:	mov    QWORD PTR [rsp+0x28],r12
     12a:	mov    QWORD PTR [rsp+0x30],r13
     12f:	mov    QWORD PTR [rsp+0x38],r14
     134:	mov    QWORD PTR [rsp+0x40],r15
     139:	mov    r13,QWORD PTR [rdi]
     13c:	mov    r8,QWORD PTR [rdi+0x8]
     140:	lea    rax,[r13+0x8]
     144:	cmp    rax,r8
     147:	ja     2c1 <botlish_fn_5+0x1a9>
     14d:	lea    rax,[r13+0x8]
     151:	mov    QWORD PTR [rdi],rax
     154:	mov    r14,rdi
     157:	mov    QWORD PTR [r13+0x0],0x0
     15f:	mov    QWORD PTR [rsp+0x18],0x0
     168:	mov    QWORD PTR [rsp],rsi
     16c:	mov    r12,rsi
     16f:	mov    QWORD PTR [rsp+0x8],rdx
     174:	mov    QWORD PTR [rsp+0x10],rcx
     179:	mov    rbx,rcx
     17c:	mov    rsi,rdx
     17f:	mov    rax,rsi
     182:	and    rax,rbx
     185:	mov    r15,rsi
     188:	test   rax,0x1
     18e:	jne    1b7 <botlish_fn_5+0x9f>
     194:	mov    rdx,rbx
     197:	mov    rsi,r15
     19a:	mov    rdi,r14
     19d:	call   1a2 <botlish_fn_5+0x8a>
			19e: R_X86_64_PLT32	rt_int_cmp-0x4
     1a2:	mov    ecx,0x2
     1a7:	test   rax,rax
     1aa:	cmovge rcx,QWORD PTR [rip+0x13e]        # 2f0 <botlish_fn_5+0x1d8>
     1b2:	jmp    1ca <botlish_fn_5+0xb2>
     1b7:	mov    ecx,0x2
     1bc:	mov    rsi,r15
     1bf:	cmp    rsi,rbx
     1c2:	cmovge rcx,QWORD PTR [rip+0x126]        # 2f0 <botlish_fn_5+0x1d8>
     1ca:	cmp    rcx,0x6
     1ce:	je     294 <botlish_fn_5+0x17c>
     1d4:	mov    rdi,r14
     1d7:	call   1dc <botlish_fn_5+0xc4>
			1d8: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     1dc:	test   rax,rax
     1df:	mov    rcx,rax
     1e2:	jne    1f0 <botlish_fn_5+0xd8>
     1e8:	mov    rdi,r14
     1eb:	jmp    20a <botlish_fn_5+0xf2>
     1f0:	mov    rdx,r15
     1f3:	mov    rsi,r12
     1f6:	mov    rdi,r14
     1f9:	call   1fe <botlish_fn_5+0xe6>
			1fa: R_X86_64_PLT32	rt_mutarray_set-0x4
     1fe:	test   rax,rax
     201:	jne    235 <botlish_fn_5+0x11d>
     207:	mov    rdi,r14
     20a:	mov    rdi,r14
     20d:	mov    QWORD PTR [rdi],r13
     210:	xor    rax,rax
     213:	mov    rbx,QWORD PTR [rsp+0x20]
     218:	mov    r12,QWORD PTR [rsp+0x28]
     21d:	mov    r13,QWORD PTR [rsp+0x30]
     222:	mov    r14,QWORD PTR [rsp+0x38]
     227:	mov    r15,QWORD PTR [rsp+0x40]
     22c:	add    rsp,0x50
     230:	mov    rsp,rbp
     233:	pop    rbp
     234:	ret
     235:	mov    QWORD PTR [rsp+0x18],0x3
     23e:	mov    rsi,r15
     241:	test   rsi,0x1
     248:	je     26b <botlish_fn_5+0x153>
     24e:	mov    rsi,r15
     251:	mov    rcx,rsi
     254:	add    rcx,0x2
     258:	seto   al
     25b:	test   al,al
     25d:	jne    26b <botlish_fn_5+0x153>
     263:	mov    r15,rcx
     266:	jmp    27e <botlish_fn_5+0x166>
     26b:	mov    edx,0x3
     270:	mov    rsi,r15
     273:	mov    rdi,r14
     276:	call   27b <botlish_fn_5+0x163>
			277: R_X86_64_PLT32	rt_int_add-0x4
     27b:	mov    r15,rax
     27e:	mov    QWORD PTR [rsp],r12
     282:	mov    rsi,r15
     285:	mov    QWORD PTR [rsp+0x8],rsi
     28a:	mov    QWORD PTR [rsp+0x10],rbx
     28f:	jmp    17f <botlish_fn_5+0x67>
     294:	mov    rdi,r14
     297:	mov    QWORD PTR [rdi],r13
     29a:	mov    eax,0xa
     29f:	mov    rbx,QWORD PTR [rsp+0x20]
     2a4:	mov    r12,QWORD PTR [rsp+0x28]
     2a9:	mov    r13,QWORD PTR [rsp+0x30]
     2ae:	mov    r14,QWORD PTR [rsp+0x38]
     2b3:	mov    r15,QWORD PTR [rsp+0x40]
     2b8:	add    rsp,0x50
     2bc:	mov    rsp,rbp
     2bf:	pop    rbp
     2c0:	ret
     2c1:	mov    r14,rdi
     2c4:	call   2c9 <botlish_fn_5+0x1b1>
			2c5: R_X86_64_PLT32	rt_stack_overflow-0x4
     2c9:	xor    rax,rax
     2cc:	mov    rbx,QWORD PTR [rsp+0x20]
     2d1:	mov    r12,QWORD PTR [rsp+0x28]
     2d6:	mov    r13,QWORD PTR [rsp+0x30]
     2db:	mov    r14,QWORD PTR [rsp+0x38]
     2e0:	mov    r15,QWORD PTR [rsp+0x40]
     2e5:	add    rsp,0x50
     2e9:	mov    rsp,rbp
     2ec:	pop    rbp
     2ed:	ret
     2ee:	add    BYTE PTR [rax],al
     2f0:	(bad)
     2f1:	add    BYTE PTR [rax],al
     2f3:	add    BYTE PTR [rax],al
     2f5:	add    BYTE PTR [rax],al
	...

00000000000002f8 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     2f8:	push   rbp
     2f9:	mov    rbp,rsp
     2fc:	mov    rsi,QWORD PTR [rdx]
     2ff:	mov    r8,QWORD PTR [rdx+0x8]
     303:	mov    rcx,QWORD PTR [rdx+0x10]
     307:	mov    rdx,r8
     30a:	call   30f <botlish_entry_5+0x17>
			30b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     30f:	mov    rsp,rbp
     312:	pop    rbp
     313:	ret

0000000000000314 <botlish_fn_6: ht_alloc<int>>:
     314:	push   rbp
     315:	mov    rbp,rsp
     318:	sub    rsp,0x60
     31c:	mov    QWORD PTR [rsp+0x30],rbx
     321:	mov    QWORD PTR [rsp+0x38],r12
     326:	mov    QWORD PTR [rsp+0x40],r13
     32b:	mov    QWORD PTR [rsp+0x48],r14
     330:	mov    QWORD PTR [rsp+0x50],r15
     335:	mov    rbx,QWORD PTR [rdi]
     338:	mov    rax,QWORD PTR [rdi+0x8]
     33c:	lea    rcx,[rbx+0x8]
     340:	cmp    rcx,rax
     343:	ja     555 <botlish_fn_6+0x241>
     349:	lea    rax,[rbx+0x8]
     34d:	mov    QWORD PTR [rdi],rax
     350:	mov    r12,rdi
     353:	mov    QWORD PTR [rbx],0x0
     35a:	mov    QWORD PTR [rsp+0x8],0x0
     363:	mov    QWORD PTR [rsp+0x10],0x0
     36c:	mov    QWORD PTR [rsp+0x18],0x0
     375:	mov    QWORD PTR [rsp],rsi
     379:	mov    r13,rsi
     37c:	mov    rsi,r13
     37f:	mov    rdi,r12
     382:	call   387 <botlish_fn_6+0x73>
			383: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     387:	test   rax,rax
     38a:	jne    398 <botlish_fn_6+0x84>
     390:	mov    rdi,r12
     393:	jmp    4fd <botlish_fn_6+0x1e9>
     398:	mov    QWORD PTR [rsp+0x8],rax
     39d:	mov    r14,rax
     3a0:	mov    edx,0x1
     3a5:	mov    QWORD PTR [rsp+0x10],0x1
     3ae:	mov    rcx,r13
     3b1:	mov    rsi,r14
     3b4:	mov    rdi,r12
     3b7:	call   3bc <botlish_fn_6+0xa8>
			3b8: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     3bc:	test   rax,rax
     3bf:	jne    3cd <botlish_fn_6+0xb9>
     3c5:	mov    rdi,r12
     3c8:	jmp    4fd <botlish_fn_6+0x1e9>
     3cd:	mov    rsi,r13
     3d0:	mov    rdi,r12
     3d3:	call   3d8 <botlish_fn_6+0xc4>
			3d4: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3d8:	test   rax,rax
     3db:	jne    3e9 <botlish_fn_6+0xd5>
     3e1:	mov    rdi,r12
     3e4:	jmp    4fd <botlish_fn_6+0x1e9>
     3e9:	mov    QWORD PTR [rsp+0x10],rax
     3ee:	mov    rsi,r13
     3f1:	mov    r15,rax
     3f4:	mov    rdi,r12
     3f7:	call   3fc <botlish_fn_6+0xe8>
			3f8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3fc:	test   rax,rax
     3ff:	jne    40d <botlish_fn_6+0xf9>
     405:	mov    rdi,r12
     408:	jmp    4fd <botlish_fn_6+0x1e9>
     40d:	mov    QWORD PTR [rsp],rax
     411:	mov    r13,rax
     414:	mov    esi,0xb
     419:	mov    QWORD PTR [rsp+0x18],0xb
     422:	mov    rdi,r12
     425:	call   42a <botlish_fn_6+0x116>
			426: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     42a:	test   rax,rax
     42d:	mov    QWORD PTR [rsp+0x20],rax
     432:	jne    440 <botlish_fn_6+0x12c>
     438:	mov    rdi,r12
     43b:	jmp    4fd <botlish_fn_6+0x1e9>
     440:	mov    edx,0x1
     445:	mov    rcx,r14
     448:	mov    rsi,QWORD PTR [rsp+0x20]
     44d:	mov    rdi,r12
     450:	call   455 <botlish_fn_6+0x141>
			451: R_X86_64_PLT32	rt_mutarray_set-0x4
     455:	test   rax,rax
     458:	jne    466 <botlish_fn_6+0x152>
     45e:	mov    rdi,r12
     461:	jmp    4fd <botlish_fn_6+0x1e9>
     466:	mov    edx,0x3
     46b:	mov    rcx,r15
     46e:	mov    rsi,QWORD PTR [rsp+0x20]
     473:	mov    rdi,r12
     476:	call   47b <botlish_fn_6+0x167>
			477: R_X86_64_PLT32	rt_mutarray_set-0x4
     47b:	test   rax,rax
     47e:	jne    48c <botlish_fn_6+0x178>
     484:	mov    rdi,r12
     487:	jmp    4fd <botlish_fn_6+0x1e9>
     48c:	mov    edx,0x5
     491:	mov    rcx,r13
     494:	mov    rsi,QWORD PTR [rsp+0x20]
     499:	mov    rdi,r12
     49c:	call   4a1 <botlish_fn_6+0x18d>
			49d: R_X86_64_PLT32	rt_mutarray_set-0x4
     4a1:	test   rax,rax
     4a4:	jne    4b2 <botlish_fn_6+0x19e>
     4aa:	mov    rdi,r12
     4ad:	jmp    4fd <botlish_fn_6+0x1e9>
     4b2:	mov    edx,0x7
     4b7:	mov    ecx,0x1
     4bc:	mov    rsi,QWORD PTR [rsp+0x20]
     4c1:	mov    rdi,r12
     4c4:	call   4c9 <botlish_fn_6+0x1b5>
			4c5: R_X86_64_PLT32	rt_mutarray_set-0x4
     4c9:	test   rax,rax
     4cc:	jne    4da <botlish_fn_6+0x1c6>
     4d2:	mov    rdi,r12
     4d5:	jmp    4fd <botlish_fn_6+0x1e9>
     4da:	mov    edx,0x9
     4df:	mov    ecx,0x1
     4e4:	mov    rsi,QWORD PTR [rsp+0x20]
     4e9:	mov    rdi,r12
     4ec:	call   4f1 <botlish_fn_6+0x1dd>
			4ed: R_X86_64_PLT32	rt_mutarray_set-0x4
     4f1:	test   rax,rax
     4f4:	jne    528 <botlish_fn_6+0x214>
     4fa:	mov    rdi,r12
     4fd:	mov    rdi,r12
     500:	mov    QWORD PTR [rdi],rbx
     503:	xor    rax,rax
     506:	mov    rbx,QWORD PTR [rsp+0x30]
     50b:	mov    r12,QWORD PTR [rsp+0x38]
     510:	mov    r13,QWORD PTR [rsp+0x40]
     515:	mov    r14,QWORD PTR [rsp+0x48]
     51a:	mov    r15,QWORD PTR [rsp+0x50]
     51f:	add    rsp,0x60
     523:	mov    rsp,rbp
     526:	pop    rbp
     527:	ret
     528:	mov    rdi,r12
     52b:	mov    QWORD PTR [rdi],rbx
     52e:	mov    rax,QWORD PTR [rsp+0x20]
     533:	mov    rbx,QWORD PTR [rsp+0x30]
     538:	mov    r12,QWORD PTR [rsp+0x38]
     53d:	mov    r13,QWORD PTR [rsp+0x40]
     542:	mov    r14,QWORD PTR [rsp+0x48]
     547:	mov    r15,QWORD PTR [rsp+0x50]
     54c:	add    rsp,0x60
     550:	mov    rsp,rbp
     553:	pop    rbp
     554:	ret
     555:	mov    r12,rdi
     558:	call   55d <botlish_fn_6+0x249>
			559: R_X86_64_PLT32	rt_stack_overflow-0x4
     55d:	xor    rax,rax
     560:	mov    rbx,QWORD PTR [rsp+0x30]
     565:	mov    r12,QWORD PTR [rsp+0x38]
     56a:	mov    r13,QWORD PTR [rsp+0x40]
     56f:	mov    r14,QWORD PTR [rsp+0x48]
     574:	mov    r15,QWORD PTR [rsp+0x50]
     579:	add    rsp,0x60
     57d:	mov    rsp,rbp
     580:	pop    rbp
     581:	ret

0000000000000582 <botlish_entry_6: ht_alloc<int>>:
     582:	push   rbp
     583:	mov    rbp,rsp
     586:	mov    rsi,QWORD PTR [rdx]
     589:	call   58e <botlish_entry_6+0xc>
			58a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     58e:	mov    rsp,rbp
     591:	pop    rbp
     592:	ret

0000000000000593 <botlish_fn_7: ht_new<generic>>:
     593:	push   rbp
     594:	mov    rbp,rsp
     597:	sub    rsp,0x20
     59b:	mov    QWORD PTR [rsp+0x10],r12
     5a0:	mov    QWORD PTR [rsp+0x18],r13
     5a5:	mov    r12,QWORD PTR [rdi]
     5a8:	mov    rax,QWORD PTR [rdi+0x8]
     5ac:	lea    rcx,[r12+0x8]
     5b1:	cmp    rcx,rax
     5b4:	ja     63e <botlish_fn_7+0xab>
     5ba:	lea    rax,[r12+0x8]
     5bf:	mov    QWORD PTR [rdi],rax
     5c2:	mov    r13,rdi
     5c5:	mov    QWORD PTR [r12],0x0
     5cd:	mov    QWORD PTR [rsp],0x0
     5d5:	mov    rdi,r13
     5d8:	call   5dd <botlish_fn_7+0x4a>
			5d9: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     5dd:	test   rax,rax
     5e0:	jne    5ee <botlish_fn_7+0x5b>
     5e6:	mov    rdi,r13
     5e9:	jmp    609 <botlish_fn_7+0x76>
     5ee:	mov    QWORD PTR [rsp],rax
     5f2:	mov    rsi,rax
     5f5:	mov    rdi,r13
     5f8:	call   5fd <botlish_fn_7+0x6a>
			5f9: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     5fd:	test   rax,rax
     600:	jne    625 <botlish_fn_7+0x92>
     606:	mov    rdi,r13
     609:	mov    rdi,r13
     60c:	mov    QWORD PTR [rdi],r12
     60f:	xor    rax,rax
     612:	mov    r12,QWORD PTR [rsp+0x10]
     617:	mov    r13,QWORD PTR [rsp+0x18]
     61c:	add    rsp,0x20
     620:	mov    rsp,rbp
     623:	pop    rbp
     624:	ret
     625:	mov    rdi,r13
     628:	mov    QWORD PTR [rdi],r12
     62b:	mov    r12,QWORD PTR [rsp+0x10]
     630:	mov    r13,QWORD PTR [rsp+0x18]
     635:	add    rsp,0x20
     639:	mov    rsp,rbp
     63c:	pop    rbp
     63d:	ret
     63e:	mov    r13,rdi
     641:	call   646 <botlish_fn_7+0xb3>
			642: R_X86_64_PLT32	rt_stack_overflow-0x4
     646:	xor    rax,rax
     649:	mov    r12,QWORD PTR [rsp+0x10]
     64e:	mov    r13,QWORD PTR [rsp+0x18]
     653:	add    rsp,0x20
     657:	mov    rsp,rbp
     65a:	pop    rbp
     65b:	ret

000000000000065c <botlish_entry_7: ht_new<generic>>:
     65c:	push   rbp
     65d:	mov    rbp,rsp
     660:	call   665 <botlish_entry_7+0x9>
			661: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     665:	mov    rsp,rbp
     668:	pop    rbp
     669:	ret

000000000000066a <botlish_fn_8: ht_controls<mutarray>>:
     66a:	push   rbp
     66b:	mov    rbp,rsp
     66e:	mov    edx,0x1
     673:	call   678 <botlish_fn_8+0xe>
			674: R_X86_64_PLT32	rt_mutarray_get-0x4
     678:	test   rax,rax
     67b:	jne    689 <botlish_fn_8+0x1f>
     681:	xor    rax,rax
     684:	mov    rsp,rbp
     687:	pop    rbp
     688:	ret
     689:	mov    rsp,rbp
     68c:	pop    rbp
     68d:	ret

000000000000068e <botlish_entry_8: ht_controls<mutarray>>:
     68e:	push   rbp
     68f:	mov    rbp,rsp
     692:	mov    rsi,QWORD PTR [rdx]
     695:	call   69a <botlish_entry_8+0xc>
			696: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     69a:	mov    rsp,rbp
     69d:	pop    rbp
     69e:	ret

000000000000069f <botlish_fn_9: ht_keys<mutarray>>:
     69f:	push   rbp
     6a0:	mov    rbp,rsp
     6a3:	mov    edx,0x3
     6a8:	call   6ad <botlish_fn_9+0xe>
			6a9: R_X86_64_PLT32	rt_mutarray_get-0x4
     6ad:	test   rax,rax
     6b0:	jne    6be <botlish_fn_9+0x1f>
     6b6:	xor    rax,rax
     6b9:	mov    rsp,rbp
     6bc:	pop    rbp
     6bd:	ret
     6be:	mov    rsp,rbp
     6c1:	pop    rbp
     6c2:	ret

00000000000006c3 <botlish_entry_9: ht_keys<mutarray>>:
     6c3:	push   rbp
     6c4:	mov    rbp,rsp
     6c7:	mov    rsi,QWORD PTR [rdx]
     6ca:	call   6cf <botlish_entry_9+0xc>
			6cb: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     6cf:	mov    rsp,rbp
     6d2:	pop    rbp
     6d3:	ret

00000000000006d4 <botlish_fn_10: ht_values<mutarray>>:
     6d4:	push   rbp
     6d5:	mov    rbp,rsp
     6d8:	mov    edx,0x5
     6dd:	call   6e2 <botlish_fn_10+0xe>
			6de: R_X86_64_PLT32	rt_mutarray_get-0x4
     6e2:	test   rax,rax
     6e5:	jne    6f3 <botlish_fn_10+0x1f>
     6eb:	xor    rax,rax
     6ee:	mov    rsp,rbp
     6f1:	pop    rbp
     6f2:	ret
     6f3:	mov    rsp,rbp
     6f6:	pop    rbp
     6f7:	ret

00000000000006f8 <botlish_entry_10: ht_values<mutarray>>:
     6f8:	push   rbp
     6f9:	mov    rbp,rsp
     6fc:	mov    rsi,QWORD PTR [rdx]
     6ff:	call   704 <botlish_entry_10+0xc>
			700: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     704:	mov    rsp,rbp
     707:	pop    rbp
     708:	ret

0000000000000709 <botlish_fn_11: ht_size<mutarray>>:
     709:	push   rbp
     70a:	mov    rbp,rsp
     70d:	mov    edx,0x7
     712:	call   717 <botlish_fn_11+0xe>
			713: R_X86_64_PLT32	rt_mutarray_get-0x4
     717:	test   rax,rax
     71a:	jne    728 <botlish_fn_11+0x1f>
     720:	xor    rax,rax
     723:	mov    rsp,rbp
     726:	pop    rbp
     727:	ret
     728:	mov    rsp,rbp
     72b:	pop    rbp
     72c:	ret

000000000000072d <botlish_entry_11: ht_size<mutarray>>:
     72d:	push   rbp
     72e:	mov    rbp,rsp
     731:	mov    rsi,QWORD PTR [rdx]
     734:	call   739 <botlish_entry_11+0xc>
			735: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     739:	mov    rsp,rbp
     73c:	pop    rbp
     73d:	ret

000000000000073e <botlish_fn_12: ht_tombstones<mutarray>>:
     73e:	push   rbp
     73f:	mov    rbp,rsp
     742:	mov    edx,0x9
     747:	call   74c <botlish_fn_12+0xe>
			748: R_X86_64_PLT32	rt_mutarray_get-0x4
     74c:	test   rax,rax
     74f:	jne    75d <botlish_fn_12+0x1f>
     755:	xor    rax,rax
     758:	mov    rsp,rbp
     75b:	pop    rbp
     75c:	ret
     75d:	mov    rsp,rbp
     760:	pop    rbp
     761:	ret

0000000000000762 <botlish_entry_12: ht_tombstones<mutarray>>:
     762:	push   rbp
     763:	mov    rbp,rsp
     766:	mov    rsi,QWORD PTR [rdx]
     769:	call   76e <botlish_entry_12+0xc>
			76a: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     76e:	mov    rsp,rbp
     771:	pop    rbp
     772:	ret

0000000000000773 <botlish_fn_13: ht_capacity<mutarray>>:
     773:	push   rbp
     774:	mov    rbp,rsp
     777:	sub    rsp,0x20
     77b:	mov    QWORD PTR [rsp+0x10],rbx
     780:	mov    QWORD PTR [rsp+0x18],r12
     785:	mov    rbx,QWORD PTR [rdi]
     788:	mov    rax,QWORD PTR [rdi+0x8]
     78c:	lea    rcx,[rbx+0x8]
     790:	cmp    rcx,rax
     793:	ja     847 <botlish_fn_13+0xd4>
     799:	lea    rax,[rbx+0x8]
     79d:	mov    QWORD PTR [rdi],rax
     7a0:	mov    r12,rdi
     7a3:	mov    QWORD PTR [rbx],0x0
     7aa:	mov    QWORD PTR [rsp],rsi
     7ae:	mov    rdi,r12
     7b1:	call   7b6 <botlish_fn_13+0x43>
			7b2: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     7b6:	test   rax,rax
     7b9:	jne    7c7 <botlish_fn_13+0x54>
     7bf:	mov    rdi,r12
     7c2:	jmp    80a <botlish_fn_13+0x97>
     7c7:	xor    ecx,ecx
     7c9:	test   rax,0x7
     7cf:	je     7dd <botlish_fn_13+0x6a>
     7d5:	mov    rsi,rax
     7d8:	jmp    7eb <botlish_fn_13+0x78>
     7dd:	movzx  rcx,BYTE PTR [rax]
     7e1:	mov    rsi,rax
     7e4:	rex cmp cl,0x8
     7e8:	sete   cl
     7eb:	test   cl,cl
     7ed:	jne    826 <botlish_fn_13+0xb3>
     7f3:	mov    rdi,r12
     7f6:	mov    rax,QWORD PTR [rdi+0x10]
     7fa:	mov    rcx,QWORD PTR [rax]
     7fd:	mov    edx,0x8
     802:	call   807 <botlish_fn_13+0x94>
			803: R_X86_64_PLT32	rt_type_error-0x4
     807:	mov    rdi,r12
     80a:	mov    rdi,r12
     80d:	mov    QWORD PTR [rdi],rbx
     810:	xor    rax,rax
     813:	mov    rbx,QWORD PTR [rsp+0x10]
     818:	mov    r12,QWORD PTR [rsp+0x18]
     81d:	add    rsp,0x20
     821:	mov    rsp,rbp
     824:	pop    rbp
     825:	ret
     826:	mov    rdi,r12
     829:	call   82e <botlish_fn_13+0xbb>
			82a: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     82e:	mov    rdi,r12
     831:	mov    QWORD PTR [rdi],rbx
     834:	mov    rbx,QWORD PTR [rsp+0x10]
     839:	mov    r12,QWORD PTR [rsp+0x18]
     83e:	add    rsp,0x20
     842:	mov    rsp,rbp
     845:	pop    rbp
     846:	ret
     847:	mov    r12,rdi
     84a:	call   84f <botlish_fn_13+0xdc>
			84b: R_X86_64_PLT32	rt_stack_overflow-0x4
     84f:	xor    rax,rax
     852:	mov    rbx,QWORD PTR [rsp+0x10]
     857:	mov    r12,QWORD PTR [rsp+0x18]
     85c:	add    rsp,0x20
     860:	mov    rsp,rbp
     863:	pop    rbp
     864:	ret

0000000000000865 <botlish_entry_13: ht_capacity<mutarray>>:
     865:	push   rbp
     866:	mov    rbp,rsp
     869:	mov    rsi,QWORD PTR [rdx]
     86c:	call   871 <botlish_entry_13+0xc>
			86d: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     871:	mov    rsp,rbp
     874:	pop    rbp
     875:	ret

0000000000000876 <botlish_fn_14: ht_probe_start<mutarray, str>>:
     876:	push   rbp
     877:	mov    rbp,rsp
     87a:	sub    rsp,0x30
     87e:	mov    QWORD PTR [rsp+0x10],rbx
     883:	mov    QWORD PTR [rsp+0x18],r12
     888:	mov    QWORD PTR [rsp+0x20],r15
     88d:	mov    r15,QWORD PTR [rdi]
     890:	mov    rax,QWORD PTR [rdi+0x8]
     894:	lea    rcx,[r15+0x8]
     898:	cmp    rcx,rax
     89b:	ja     952 <botlish_fn_14+0xdc>
     8a1:	lea    rax,[r15+0x8]
     8a5:	mov    QWORD PTR [rdi],rax
     8a8:	mov    rbx,rdi
     8ab:	mov    QWORD PTR [r15],0x0
     8b2:	mov    QWORD PTR [rsp],rsi
     8b6:	mov    r12,rsi
     8b9:	mov    rsi,rdx
     8bc:	mov    rdi,rbx
     8bf:	call   8c4 <botlish_fn_14+0x4e>
			8c0: R_X86_64_PLT32	rt_hash-0x4
     8c4:	test   rax,rax
     8c7:	jne    8d5 <botlish_fn_14+0x5f>
     8cd:	mov    rdi,rbx
     8d0:	jmp    913 <botlish_fn_14+0x9d>
     8d5:	mov    QWORD PTR [rsp+0x8],rax
     8da:	mov    rsi,r12
     8dd:	mov    r12,rax
     8e0:	mov    rdi,rbx
     8e3:	call   8e8 <botlish_fn_14+0x72>
			8e4: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     8e8:	test   rax,rax
     8eb:	mov    rdx,rax
     8ee:	jne    8fc <botlish_fn_14+0x86>
     8f4:	mov    rdi,rbx
     8f7:	jmp    913 <botlish_fn_14+0x9d>
     8fc:	mov    rsi,r12
     8ff:	mov    rdi,rbx
     902:	call   907 <botlish_fn_14+0x91>
			903: R_X86_64_PLT32	rt_int_mod-0x4
     907:	test   rax,rax
     90a:	jne    934 <botlish_fn_14+0xbe>
     910:	mov    rdi,rbx
     913:	mov    rdi,rbx
     916:	mov    QWORD PTR [rdi],r15
     919:	xor    rax,rax
     91c:	mov    rbx,QWORD PTR [rsp+0x10]
     921:	mov    r12,QWORD PTR [rsp+0x18]
     926:	mov    r15,QWORD PTR [rsp+0x20]
     92b:	add    rsp,0x30
     92f:	mov    rsp,rbp
     932:	pop    rbp
     933:	ret
     934:	mov    rdi,rbx
     937:	mov    QWORD PTR [rdi],r15
     93a:	mov    rbx,QWORD PTR [rsp+0x10]
     93f:	mov    r12,QWORD PTR [rsp+0x18]
     944:	mov    r15,QWORD PTR [rsp+0x20]
     949:	add    rsp,0x30
     94d:	mov    rsp,rbp
     950:	pop    rbp
     951:	ret
     952:	mov    rbx,rdi
     955:	call   95a <botlish_fn_14+0xe4>
			956: R_X86_64_PLT32	rt_stack_overflow-0x4
     95a:	xor    rax,rax
     95d:	mov    rbx,QWORD PTR [rsp+0x10]
     962:	mov    r12,QWORD PTR [rsp+0x18]
     967:	mov    r15,QWORD PTR [rsp+0x20]
     96c:	add    rsp,0x30
     970:	mov    rsp,rbp
     973:	pop    rbp
     974:	ret

0000000000000975 <botlish_entry_14: ht_probe_start<mutarray, str>>:
     975:	push   rbp
     976:	mov    rbp,rsp
     979:	mov    rsi,QWORD PTR [rdx]
     97c:	mov    rdx,QWORD PTR [rdx+0x8]
     980:	call   985 <botlish_entry_14+0x10>
			981: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     985:	mov    rsp,rbp
     988:	pop    rbp
     989:	ret

000000000000098a <botlish_fn_15: ht_probe_next<mutarray, int>>:
     98a:	push   rbp
     98b:	mov    rbp,rsp
     98e:	sub    rsp,0x40
     992:	mov    QWORD PTR [rsp+0x20],rbx
     997:	mov    QWORD PTR [rsp+0x28],r12
     99c:	mov    QWORD PTR [rsp+0x30],r13
     9a1:	mov    rbx,QWORD PTR [rdi]
     9a4:	mov    rax,QWORD PTR [rdi+0x8]
     9a8:	lea    rcx,[rbx+0x8]
     9ac:	cmp    rcx,rax
     9af:	ja     a98 <botlish_fn_15+0x10e>
     9b5:	lea    rax,[rbx+0x8]
     9b9:	mov    QWORD PTR [rdi],rax
     9bc:	mov    r12,rdi
     9bf:	mov    QWORD PTR [rbx],0x0
     9c6:	mov    QWORD PTR [rsp],rsi
     9ca:	mov    r13,rsi
     9cd:	mov    QWORD PTR [rsp+0x8],rdx
     9d2:	mov    QWORD PTR [rsp+0x10],0x3
     9db:	test   rdx,0x1
     9e2:	jne    9f0 <botlish_fn_15+0x66>
     9e8:	mov    rcx,rdx
     9eb:	jmp    a05 <botlish_fn_15+0x7b>
     9f0:	mov    rsi,rdx
     9f3:	add    rsi,0x2
     9f7:	mov    rcx,rdx
     9fa:	seto   al
     9fd:	test   al,al
     9ff:	je     a18 <botlish_fn_15+0x8e>
     a05:	mov    edx,0x3
     a0a:	mov    rsi,rcx
     a0d:	mov    rdi,r12
     a10:	call   a15 <botlish_fn_15+0x8b>
			a11: R_X86_64_PLT32	rt_int_add-0x4
     a15:	mov    rsi,rax
     a18:	mov    QWORD PTR [rsp+0x8],rsi
     a1d:	mov    rax,rsi
     a20:	mov    rsi,r13
     a23:	mov    r13,rax
     a26:	mov    rdi,r12
     a29:	call   a2e <botlish_fn_15+0xa4>
			a2a: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     a2e:	test   rax,rax
     a31:	mov    rdx,rax
     a34:	jne    a42 <botlish_fn_15+0xb8>
     a3a:	mov    rdi,r12
     a3d:	jmp    a59 <botlish_fn_15+0xcf>
     a42:	mov    rsi,r13
     a45:	mov    rdi,r12
     a48:	call   a4d <botlish_fn_15+0xc3>
			a49: R_X86_64_PLT32	rt_int_mod-0x4
     a4d:	test   rax,rax
     a50:	jne    a7a <botlish_fn_15+0xf0>
     a56:	mov    rdi,r12
     a59:	mov    rdi,r12
     a5c:	mov    QWORD PTR [rdi],rbx
     a5f:	xor    rax,rax
     a62:	mov    rbx,QWORD PTR [rsp+0x20]
     a67:	mov    r12,QWORD PTR [rsp+0x28]
     a6c:	mov    r13,QWORD PTR [rsp+0x30]
     a71:	add    rsp,0x40
     a75:	mov    rsp,rbp
     a78:	pop    rbp
     a79:	ret
     a7a:	mov    rdi,r12
     a7d:	mov    QWORD PTR [rdi],rbx
     a80:	mov    rbx,QWORD PTR [rsp+0x20]
     a85:	mov    r12,QWORD PTR [rsp+0x28]
     a8a:	mov    r13,QWORD PTR [rsp+0x30]
     a8f:	add    rsp,0x40
     a93:	mov    rsp,rbp
     a96:	pop    rbp
     a97:	ret
     a98:	mov    r12,rdi
     a9b:	call   aa0 <botlish_fn_15+0x116>
			a9c: R_X86_64_PLT32	rt_stack_overflow-0x4
     aa0:	xor    rax,rax
     aa3:	mov    rbx,QWORD PTR [rsp+0x20]
     aa8:	mov    r12,QWORD PTR [rsp+0x28]
     aad:	mov    r13,QWORD PTR [rsp+0x30]
     ab2:	add    rsp,0x40
     ab6:	mov    rsp,rbp
     ab9:	pop    rbp
     aba:	ret

0000000000000abb <botlish_entry_15: ht_probe_next<mutarray, int>>:
     abb:	push   rbp
     abc:	mov    rbp,rsp
     abf:	mov    rsi,QWORD PTR [rdx]
     ac2:	mov    rdx,QWORD PTR [rdx+0x8]
     ac6:	call   acb <botlish_entry_15+0x10>
			ac7: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     acb:	mov    rsp,rbp
     ace:	pop    rbp
     acf:	ret

0000000000000ad0 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     ad0:	push   rbp
     ad1:	mov    rbp,rsp
     ad4:	sub    rsp,0x60
     ad8:	mov    QWORD PTR [rsp+0x30],rbx
     add:	mov    QWORD PTR [rsp+0x38],r12
     ae2:	mov    QWORD PTR [rsp+0x40],r13
     ae7:	mov    QWORD PTR [rsp+0x48],r14
     aec:	mov    QWORD PTR [rsp+0x50],r15
     af1:	mov    r14,QWORD PTR [rdi]
     af4:	mov    rax,QWORD PTR [rdi+0x8]
     af8:	lea    r8,[r14+0x8]
     afc:	cmp    r8,rax
     aff:	ja     e55 <botlish_fn_16+0x385>
     b05:	lea    rax,[r14+0x8]
     b09:	mov    QWORD PTR [rdi],rax
     b0c:	mov    r15,rdi
     b0f:	mov    QWORD PTR [r14],0x0
     b16:	mov    QWORD PTR [rsp+0x18],0x0
     b1f:	mov    QWORD PTR [rsp],rsi
     b23:	mov    QWORD PTR [rsp+0x8],rdx
     b28:	mov    QWORD PTR [rsp+0x20],rdx
     b2d:	mov    QWORD PTR [rsp+0x10],rcx
     b32:	mov    rbx,rsi
     b35:	mov    QWORD PTR [rsp+0x28],rcx
     b3a:	mov    rsi,rbx
     b3d:	mov    rdi,r15
     b40:	call   b45 <botlish_fn_16+0x75>
			b41: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     b45:	test   rax,rax
     b48:	jne    b56 <botlish_fn_16+0x86>
     b4e:	mov    rdi,r15
     b51:	jmp    db1 <botlish_fn_16+0x2e1>
     b56:	xor    ecx,ecx
     b58:	test   rax,0x7
     b5e:	je     b6c <botlish_fn_16+0x9c>
     b64:	mov    rsi,rax
     b67:	jmp    b7a <botlish_fn_16+0xaa>
     b6c:	movzx  rcx,BYTE PTR [rax]
     b70:	mov    rsi,rax
     b73:	rex cmp cl,0x8
     b77:	sete   cl
     b7a:	test   cl,cl
     b7c:	jne    b9f <botlish_fn_16+0xcf>
     b82:	mov    rdi,r15
     b85:	mov    rax,QWORD PTR [rdi+0x10]
     b89:	mov    rcx,QWORD PTR [rax+0x8]
     b8d:	mov    edx,0x8
     b92:	call   b97 <botlish_fn_16+0xc7>
			b93: R_X86_64_PLT32	rt_type_error-0x4
     b97:	mov    rdi,r15
     b9a:	jmp    db1 <botlish_fn_16+0x2e1>
     b9f:	mov    rdx,QWORD PTR [rsp+0x28]
     ba4:	mov    rdi,r15
     ba7:	call   bac <botlish_fn_16+0xdc>
			ba8: R_X86_64_PLT32	rt_mutarray_get-0x4
     bac:	mov    rcx,rax
     baf:	mov    r13,rax
     bb2:	test   rax,rcx
     bb5:	jne    bc3 <botlish_fn_16+0xf3>
     bbb:	mov    rdi,r15
     bbe:	jmp    db1 <botlish_fn_16+0x2e1>
     bc3:	mov    rax,r13
     bc6:	mov    QWORD PTR [rsp+0x18],rax
     bcb:	mov    rdi,r15
     bce:	call   bd3 <botlish_fn_16+0x103>
			bcf: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     bd3:	test   rax,rax
     bd6:	jne    be4 <botlish_fn_16+0x114>
     bdc:	mov    rdi,r15
     bdf:	jmp    db1 <botlish_fn_16+0x2e1>
     be4:	mov    rsi,r13
     be7:	mov    rcx,rsi
     bea:	and    rcx,rax
     bed:	mov    rdx,rax
     bf0:	test   rcx,0x1
     bf7:	jne    c19 <botlish_fn_16+0x149>
     bfd:	mov    rsi,r13
     c00:	mov    rdi,r15
     c03:	call   c08 <botlish_fn_16+0x138>
			c04: R_X86_64_PLT32	rt_value_eq-0x4
     c08:	test   rax,rax
     c0b:	jne    c29 <botlish_fn_16+0x159>
     c11:	mov    rdi,r15
     c14:	jmp    db1 <botlish_fn_16+0x2e1>
     c19:	mov    eax,0x2
     c1e:	cmp    r13,rdx
     c21:	cmove  rax,QWORD PTR [rip+0x25f]        # e88 <botlish_fn_16+0x3b8>
     c29:	mov    r12d,0x6
     c2f:	cmp    rax,0x6
     c33:	je     e26 <botlish_fn_16+0x356>
     c39:	mov    rdi,r15
     c3c:	call   c41 <botlish_fn_16+0x171>
			c3d: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     c41:	test   rax,rax
     c44:	jne    c52 <botlish_fn_16+0x182>
     c4a:	mov    rdi,r15
     c4d:	jmp    db1 <botlish_fn_16+0x2e1>
     c52:	mov    rcx,r13
     c55:	and    rcx,rax
     c58:	mov    rdx,rax
     c5b:	test   rcx,0x1
     c62:	jne    c84 <botlish_fn_16+0x1b4>
     c68:	mov    rsi,r13
     c6b:	mov    rdi,r15
     c6e:	call   c73 <botlish_fn_16+0x1a3>
			c6f: R_X86_64_PLT32	rt_value_eq-0x4
     c73:	test   rax,rax
     c76:	jne    c97 <botlish_fn_16+0x1c7>
     c7c:	mov    rdi,r15
     c7f:	jmp    db1 <botlish_fn_16+0x2e1>
     c84:	mov    rsi,r13
     c87:	mov    eax,0x2
     c8c:	cmp    rsi,rdx
     c8f:	cmove  rax,QWORD PTR [rip+0x1f1]        # e88 <botlish_fn_16+0x3b8>
     c97:	cmp    rax,0x6
     c9b:	je     cb1 <botlish_fn_16+0x1e1>
     ca1:	mov    r12d,0x2
     ca7:	mov    r13,QWORD PTR [rsp+0x20]
     cac:	jmp    d8b <botlish_fn_16+0x2bb>
     cb1:	mov    rsi,rbx
     cb4:	mov    rdi,r15
     cb7:	call   cbc <botlish_fn_16+0x1ec>
			cb8: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     cbc:	test   rax,rax
     cbf:	jne    ccd <botlish_fn_16+0x1fd>
     cc5:	mov    rdi,r15
     cc8:	jmp    db1 <botlish_fn_16+0x2e1>
     ccd:	xor    ecx,ecx
     ccf:	test   rax,0x7
     cd5:	je     ce3 <botlish_fn_16+0x213>
     cdb:	mov    rsi,rax
     cde:	jmp    cf1 <botlish_fn_16+0x221>
     ce3:	movzx  rcx,BYTE PTR [rax]
     ce7:	mov    rsi,rax
     cea:	rex cmp cl,0x8
     cee:	sete   cl
     cf1:	test   cl,cl
     cf3:	jne    d16 <botlish_fn_16+0x246>
     cf9:	mov    rdi,r15
     cfc:	mov    rax,QWORD PTR [rdi+0x10]
     d00:	mov    rcx,QWORD PTR [rax+0x8]
     d04:	mov    edx,0x8
     d09:	call   d0e <botlish_fn_16+0x23e>
			d0a: R_X86_64_PLT32	rt_type_error-0x4
     d0e:	mov    rdi,r15
     d11:	jmp    db1 <botlish_fn_16+0x2e1>
     d16:	mov    rdx,QWORD PTR [rsp+0x28]
     d1b:	mov    rdi,r15
     d1e:	call   d23 <botlish_fn_16+0x253>
			d1f: R_X86_64_PLT32	rt_mutarray_get-0x4
     d23:	test   rax,rax
     d26:	jne    d34 <botlish_fn_16+0x264>
     d2c:	mov    rdi,r15
     d2f:	jmp    db1 <botlish_fn_16+0x2e1>
     d34:	mov    r13,QWORD PTR [rsp+0x20]
     d39:	mov    rcx,rax
     d3c:	and    rcx,r13
     d3f:	mov    rsi,rax
     d42:	test   rcx,0x1
     d49:	jne    d6b <botlish_fn_16+0x29b>
     d4f:	mov    rdx,r13
     d52:	mov    rdi,r15
     d55:	call   d5a <botlish_fn_16+0x28a>
			d56: R_X86_64_PLT32	rt_value_eq-0x4
     d5a:	test   rax,rax
     d5d:	jne    d7b <botlish_fn_16+0x2ab>
     d63:	mov    rdi,r15
     d66:	jmp    db1 <botlish_fn_16+0x2e1>
     d6b:	mov    eax,0x2
     d70:	cmp    rsi,r13
     d73:	cmove  rax,QWORD PTR [rip+0x10d]        # e88 <botlish_fn_16+0x3b8>
     d7b:	cmp    rax,0x6
     d7f:	je     d8b <botlish_fn_16+0x2bb>
     d85:	mov    r12d,0x2
     d8b:	cmp    r12,0x6
     d8f:	je     df9 <botlish_fn_16+0x329>
     d95:	mov    rdx,QWORD PTR [rsp+0x28]
     d9a:	mov    rsi,rbx
     d9d:	mov    rdi,r15
     da0:	call   da5 <botlish_fn_16+0x2d5>
			da1: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     da5:	test   rax,rax
     da8:	jne    ddc <botlish_fn_16+0x30c>
     dae:	mov    rdi,r15
     db1:	mov    rdi,r15
     db4:	mov    QWORD PTR [rdi],r14
     db7:	xor    rax,rax
     dba:	mov    rbx,QWORD PTR [rsp+0x30]
     dbf:	mov    r12,QWORD PTR [rsp+0x38]
     dc4:	mov    r13,QWORD PTR [rsp+0x40]
     dc9:	mov    r14,QWORD PTR [rsp+0x48]
     dce:	mov    r15,QWORD PTR [rsp+0x50]
     dd3:	add    rsp,0x60
     dd7:	mov    rsp,rbp
     dda:	pop    rbp
     ddb:	ret
     ddc:	mov    QWORD PTR [rsp],rbx
     de0:	mov    QWORD PTR [rsp+0x8],r13
     de5:	mov    QWORD PTR [rsp+0x10],rax
     dea:	mov    QWORD PTR [rsp+0x20],r13
     def:	mov    QWORD PTR [rsp+0x28],rax
     df4:	jmp    b3a <botlish_fn_16+0x6a>
     df9:	mov    rdi,r15
     dfc:	mov    QWORD PTR [rdi],r14
     dff:	mov    rax,QWORD PTR [rsp+0x28]
     e04:	mov    rbx,QWORD PTR [rsp+0x30]
     e09:	mov    r12,QWORD PTR [rsp+0x38]
     e0e:	mov    r13,QWORD PTR [rsp+0x40]
     e13:	mov    r14,QWORD PTR [rsp+0x48]
     e18:	mov    r15,QWORD PTR [rsp+0x50]
     e1d:	add    rsp,0x60
     e21:	mov    rsp,rbp
     e24:	pop    rbp
     e25:	ret
     e26:	mov    rdi,r15
     e29:	mov    QWORD PTR [rdi],r14
     e2c:	mov    rax,0xffffffffffffffff
     e33:	mov    rbx,QWORD PTR [rsp+0x30]
     e38:	mov    r12,QWORD PTR [rsp+0x38]
     e3d:	mov    r13,QWORD PTR [rsp+0x40]
     e42:	mov    r14,QWORD PTR [rsp+0x48]
     e47:	mov    r15,QWORD PTR [rsp+0x50]
     e4c:	add    rsp,0x60
     e50:	mov    rsp,rbp
     e53:	pop    rbp
     e54:	ret
     e55:	mov    r15,rdi
     e58:	call   e5d <botlish_fn_16+0x38d>
			e59: R_X86_64_PLT32	rt_stack_overflow-0x4
     e5d:	xor    rax,rax
     e60:	mov    rbx,QWORD PTR [rsp+0x30]
     e65:	mov    r12,QWORD PTR [rsp+0x38]
     e6a:	mov    r13,QWORD PTR [rsp+0x40]
     e6f:	mov    r14,QWORD PTR [rsp+0x48]
     e74:	mov    r15,QWORD PTR [rsp+0x50]
     e79:	add    rsp,0x60
     e7d:	mov    rsp,rbp
     e80:	pop    rbp
     e81:	ret
     e82:	add    BYTE PTR [rax],al
     e84:	add    BYTE PTR [rax],al
     e86:	add    BYTE PTR [rax],al
     e88:	(bad)
     e89:	add    BYTE PTR [rax],al
     e8b:	add    BYTE PTR [rax],al
     e8d:	add    BYTE PTR [rax],al
	...

0000000000000e90 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
     e90:	push   rbp
     e91:	mov    rbp,rsp
     e94:	mov    rsi,QWORD PTR [rdx]
     e97:	mov    r8,QWORD PTR [rdx+0x8]
     e9b:	mov    rcx,QWORD PTR [rdx+0x10]
     e9f:	mov    rdx,r8
     ea2:	call   ea7 <botlish_entry_16+0x17>
			ea3: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
     ea7:	mov    rsp,rbp
     eaa:	pop    rbp
     eab:	ret
     eac:	add    BYTE PTR [rax],al
	...

0000000000000eb0 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
     eb0:	push   rbp
     eb1:	mov    rbp,rsp
     eb4:	sub    rsp,0x70
     eb8:	mov    QWORD PTR [rsp+0x40],rbx
     ebd:	mov    QWORD PTR [rsp+0x48],r12
     ec2:	mov    QWORD PTR [rsp+0x50],r13
     ec7:	mov    QWORD PTR [rsp+0x58],r14
     ecc:	mov    QWORD PTR [rsp+0x60],r15
     ed1:	mov    rbx,QWORD PTR [rdi]
     ed4:	mov    rax,QWORD PTR [rdi+0x8]
     ed8:	lea    r9,[rbx+0x8]
     edc:	cmp    r9,rax
     edf:	ja     144c <botlish_fn_17+0x59c>
     ee5:	lea    rax,[rbx+0x8]
     ee9:	mov    QWORD PTR [rdi],rax
     eec:	mov    QWORD PTR [rsp+0x28],rdi
     ef1:	mov    QWORD PTR [rbx],0x0
     ef8:	mov    QWORD PTR [rsp+0x20],0x0
     f01:	mov    QWORD PTR [rsp],rsi
     f05:	mov    QWORD PTR [rsp+0x8],rdx
     f0a:	mov    r14,rdx
     f0d:	mov    QWORD PTR [rsp+0x10],rcx
     f12:	mov    QWORD PTR [rsp+0x18],r8
     f17:	mov    r12,rsi
     f1a:	mov    QWORD PTR [rsp+0x30],rcx
     f1f:	mov    QWORD PTR [rsp+0x38],r8
     f24:	mov    rsi,r12
     f27:	mov    rdi,QWORD PTR [rsp+0x28]
     f2c:	call   f31 <botlish_fn_17+0x81>
			f2d: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     f31:	test   rax,rax
     f34:	jne    f44 <botlish_fn_17+0x94>
     f3a:	mov    rdi,QWORD PTR [rsp+0x28]
     f3f:	jmp    1308 <botlish_fn_17+0x458>
     f44:	xor    ecx,ecx
     f46:	test   rax,0x7
     f4c:	je     f5a <botlish_fn_17+0xaa>
     f52:	mov    rsi,rax
     f55:	jmp    f68 <botlish_fn_17+0xb8>
     f5a:	movzx  rcx,BYTE PTR [rax]
     f5e:	mov    rsi,rax
     f61:	rex cmp cl,0x8
     f65:	sete   cl
     f68:	test   cl,cl
     f6a:	jne    f91 <botlish_fn_17+0xe1>
     f70:	mov    rdi,QWORD PTR [rsp+0x28]
     f75:	mov    rax,QWORD PTR [rdi+0x10]
     f79:	mov    rcx,QWORD PTR [rax+0x8]
     f7d:	mov    edx,0x8
     f82:	call   f87 <botlish_fn_17+0xd7>
			f83: R_X86_64_PLT32	rt_type_error-0x4
     f87:	mov    rdi,QWORD PTR [rsp+0x28]
     f8c:	jmp    1308 <botlish_fn_17+0x458>
     f91:	mov    rdx,QWORD PTR [rsp+0x30]
     f96:	mov    rdi,QWORD PTR [rsp+0x28]
     f9b:	call   fa0 <botlish_fn_17+0xf0>
			f9c: R_X86_64_PLT32	rt_mutarray_get-0x4
     fa0:	mov    rcx,rax
     fa3:	mov    r15,rax
     fa6:	test   rax,rcx
     fa9:	jne    fb9 <botlish_fn_17+0x109>
     faf:	mov    rdi,QWORD PTR [rsp+0x28]
     fb4:	jmp    1308 <botlish_fn_17+0x458>
     fb9:	mov    rax,r15
     fbc:	mov    QWORD PTR [rsp+0x20],rax
     fc1:	mov    rdi,QWORD PTR [rsp+0x28]
     fc6:	call   fcb <botlish_fn_17+0x11b>
			fc7: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     fcb:	test   rax,rax
     fce:	jne    fde <botlish_fn_17+0x12e>
     fd4:	mov    rdi,QWORD PTR [rsp+0x28]
     fd9:	jmp    1308 <botlish_fn_17+0x458>
     fde:	mov    rcx,r15
     fe1:	and    rcx,rax
     fe4:	mov    rdx,rax
     fe7:	test   rcx,0x1
     fee:	jne    1014 <botlish_fn_17+0x164>
     ff4:	mov    rsi,r15
     ff7:	mov    rdi,QWORD PTR [rsp+0x28]
     ffc:	call   1001 <botlish_fn_17+0x151>
			ffd: R_X86_64_PLT32	rt_value_eq-0x4
    1001:	test   rax,rax
    1004:	jne    1027 <botlish_fn_17+0x177>
    100a:	mov    rdi,QWORD PTR [rsp+0x28]
    100f:	jmp    1308 <botlish_fn_17+0x458>
    1014:	mov    eax,0x2
    1019:	mov    rcx,r15
    101c:	cmp    rcx,rdx
    101f:	cmove  rax,QWORD PTR [rip+0x459]        # 1480 <botlish_fn_17+0x5d0>
    1027:	mov    r13d,0x6
    102d:	cmp    rax,0x6
    1031:	je     1390 <botlish_fn_17+0x4e0>
    1037:	mov    rdi,QWORD PTR [rsp+0x28]
    103c:	call   1041 <botlish_fn_17+0x191>
			103d: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1041:	test   rax,rax
    1044:	jne    1054 <botlish_fn_17+0x1a4>
    104a:	mov    rdi,QWORD PTR [rsp+0x28]
    104f:	jmp    1308 <botlish_fn_17+0x458>
    1054:	mov    rcx,r15
    1057:	mov    rdx,rcx
    105a:	and    rdx,rax
    105d:	mov    rdi,rax
    1060:	test   rdx,0x1
    1067:	jne    1090 <botlish_fn_17+0x1e0>
    106d:	mov    rdx,rdi
    1070:	mov    rsi,r15
    1073:	mov    rdi,QWORD PTR [rsp+0x28]
    1078:	call   107d <botlish_fn_17+0x1cd>
			1079: R_X86_64_PLT32	rt_value_eq-0x4
    107d:	test   rax,rax
    1080:	jne    10a6 <botlish_fn_17+0x1f6>
    1086:	mov    rdi,QWORD PTR [rsp+0x28]
    108b:	jmp    1308 <botlish_fn_17+0x458>
    1090:	mov    rdx,rdi
    1093:	mov    eax,0x2
    1098:	mov    rdi,r15
    109b:	cmp    rdi,rdx
    109e:	cmove  rax,QWORD PTR [rip+0x3da]        # 1480 <botlish_fn_17+0x5d0>
    10a6:	cmp    rax,0x6
    10aa:	je     10ba <botlish_fn_17+0x20a>
    10b0:	mov    eax,0x2
    10b5:	jmp    11a6 <botlish_fn_17+0x2f6>
    10ba:	mov    rsi,r12
    10bd:	mov    rdi,QWORD PTR [rsp+0x28]
    10c2:	call   10c7 <botlish_fn_17+0x217>
			10c3: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    10c7:	test   rax,rax
    10ca:	jne    10da <botlish_fn_17+0x22a>
    10d0:	mov    rdi,QWORD PTR [rsp+0x28]
    10d5:	jmp    1308 <botlish_fn_17+0x458>
    10da:	xor    ecx,ecx
    10dc:	test   rax,0x7
    10e2:	je     10f0 <botlish_fn_17+0x240>
    10e8:	mov    rsi,rax
    10eb:	jmp    10fe <botlish_fn_17+0x24e>
    10f0:	movzx  rcx,BYTE PTR [rax]
    10f4:	mov    rsi,rax
    10f7:	rex cmp cl,0x8
    10fb:	sete   cl
    10fe:	test   cl,cl
    1100:	jne    1127 <botlish_fn_17+0x277>
    1106:	mov    rdi,QWORD PTR [rsp+0x28]
    110b:	mov    rax,QWORD PTR [rdi+0x10]
    110f:	mov    rcx,QWORD PTR [rax+0x8]
    1113:	mov    edx,0x8
    1118:	call   111d <botlish_fn_17+0x26d>
			1119: R_X86_64_PLT32	rt_type_error-0x4
    111d:	mov    rdi,QWORD PTR [rsp+0x28]
    1122:	jmp    1308 <botlish_fn_17+0x458>
    1127:	mov    rdx,QWORD PTR [rsp+0x30]
    112c:	mov    rdi,QWORD PTR [rsp+0x28]
    1131:	call   1136 <botlish_fn_17+0x286>
			1132: R_X86_64_PLT32	rt_mutarray_get-0x4
    1136:	test   rax,rax
    1139:	jne    1149 <botlish_fn_17+0x299>
    113f:	mov    rdi,QWORD PTR [rsp+0x28]
    1144:	jmp    1308 <botlish_fn_17+0x458>
    1149:	mov    rcx,rax
    114c:	and    rcx,r14
    114f:	mov    rsi,rax
    1152:	test   rcx,0x1
    1159:	jne    117f <botlish_fn_17+0x2cf>
    115f:	mov    rdx,r14
    1162:	mov    rdi,QWORD PTR [rsp+0x28]
    1167:	call   116c <botlish_fn_17+0x2bc>
			1168: R_X86_64_PLT32	rt_value_eq-0x4
    116c:	test   rax,rax
    116f:	jne    118f <botlish_fn_17+0x2df>
    1175:	mov    rdi,QWORD PTR [rsp+0x28]
    117a:	jmp    1308 <botlish_fn_17+0x458>
    117f:	mov    eax,0x2
    1184:	cmp    rsi,r14
    1187:	cmove  rax,QWORD PTR [rip+0x2f1]        # 1480 <botlish_fn_17+0x5d0>
    118f:	cmp    rax,0x6
    1193:	je     11a3 <botlish_fn_17+0x2f3>
    1199:	mov    eax,0x2
    119e:	jmp    11a6 <botlish_fn_17+0x2f6>
    11a3:	mov    rax,r13
    11a6:	cmp    rax,0x6
    11aa:	je     1361 <botlish_fn_17+0x4b1>
    11b0:	mov    rdi,QWORD PTR [rsp+0x28]
    11b5:	call   11ba <botlish_fn_17+0x30a>
			11b6: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    11ba:	test   rax,rax
    11bd:	jne    11cd <botlish_fn_17+0x31d>
    11c3:	mov    rdi,QWORD PTR [rsp+0x28]
    11c8:	jmp    1308 <botlish_fn_17+0x458>
    11cd:	mov    rcx,r15
    11d0:	mov    rdx,rcx
    11d3:	and    rdx,rax
    11d6:	mov    r11,rax
    11d9:	test   rdx,0x1
    11e0:	jne    1209 <botlish_fn_17+0x359>
    11e6:	mov    rdx,r11
    11e9:	mov    rsi,r15
    11ec:	mov    rdi,QWORD PTR [rsp+0x28]
    11f1:	call   11f6 <botlish_fn_17+0x346>
			11f2: R_X86_64_PLT32	rt_value_eq-0x4
    11f6:	test   rax,rax
    11f9:	jne    121f <botlish_fn_17+0x36f>
    11ff:	mov    rdi,QWORD PTR [rsp+0x28]
    1204:	jmp    1308 <botlish_fn_17+0x458>
    1209:	mov    rdx,r11
    120c:	mov    rsi,r15
    120f:	mov    eax,0x2
    1214:	cmp    rsi,rdx
    1217:	cmove  rax,QWORD PTR [rip+0x261]        # 1480 <botlish_fn_17+0x5d0>
    121f:	cmp    rax,0x6
    1223:	je     1234 <botlish_fn_17+0x384>
    1229:	mov    r13d,0x2
    122f:	jmp    1297 <botlish_fn_17+0x3e7>
    1234:	mov    r15,QWORD PTR [rsp+0x38]
    1239:	test   r15,0x1
    1240:	jne    1272 <botlish_fn_17+0x3c2>
    1246:	mov    edx,0x1
    124b:	mov    rsi,r15
    124e:	mov    rdi,QWORD PTR [rsp+0x28]
    1253:	call   1258 <botlish_fn_17+0x3a8>
			1254: R_X86_64_PLT32	rt_int_cmp-0x4
    1258:	mov    ecx,0x2
    125d:	test   rax,rax
    1260:	cmovl  rcx,QWORD PTR [rip+0x218]        # 1480 <botlish_fn_17+0x5d0>
    1268:	mov    QWORD PTR [rsp+0x38],r15
    126d:	jmp    1287 <botlish_fn_17+0x3d7>
    1272:	mov    ecx,0x2
    1277:	test   r15,r15
    127a:	mov    QWORD PTR [rsp+0x38],r15
    127f:	cmovle rcx,QWORD PTR [rip+0x1f9]        # 1480 <botlish_fn_17+0x5d0>
    1287:	cmp    rcx,0x6
    128b:	je     1297 <botlish_fn_17+0x3e7>
    1291:	mov    r13d,0x2
    1297:	cmp    r13,0x6
    129b:	je     12e8 <botlish_fn_17+0x438>
    12a1:	mov    rdx,QWORD PTR [rsp+0x30]
    12a6:	mov    rsi,r12
    12a9:	mov    rdi,QWORD PTR [rsp+0x28]
    12ae:	call   12b3 <botlish_fn_17+0x403>
			12af: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    12b3:	test   rax,rax
    12b6:	jne    12c6 <botlish_fn_17+0x416>
    12bc:	mov    rdi,QWORD PTR [rsp+0x28]
    12c1:	jmp    1308 <botlish_fn_17+0x458>
    12c6:	mov    QWORD PTR [rsp],r12
    12ca:	mov    QWORD PTR [rsp+0x8],r14
    12cf:	mov    QWORD PTR [rsp+0x10],rax
    12d4:	mov    rcx,QWORD PTR [rsp+0x38]
    12d9:	mov    QWORD PTR [rsp+0x18],rcx
    12de:	mov    QWORD PTR [rsp+0x30],rax
    12e3:	jmp    f24 <botlish_fn_17+0x74>
    12e8:	mov    rdx,QWORD PTR [rsp+0x30]
    12ed:	mov    rsi,r12
    12f0:	mov    rdi,QWORD PTR [rsp+0x28]
    12f5:	call   12fa <botlish_fn_17+0x44a>
			12f6: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    12fa:	test   rax,rax
    12fd:	jne    1335 <botlish_fn_17+0x485>
    1303:	mov    rdi,QWORD PTR [rsp+0x28]
    1308:	mov    rdi,QWORD PTR [rsp+0x28]
    130d:	mov    QWORD PTR [rdi],rbx
    1310:	xor    rax,rax
    1313:	mov    rbx,QWORD PTR [rsp+0x40]
    1318:	mov    r12,QWORD PTR [rsp+0x48]
    131d:	mov    r13,QWORD PTR [rsp+0x50]
    1322:	mov    r14,QWORD PTR [rsp+0x58]
    1327:	mov    r15,QWORD PTR [rsp+0x60]
    132c:	add    rsp,0x70
    1330:	mov    rsp,rbp
    1333:	pop    rbp
    1334:	ret
    1335:	mov    QWORD PTR [rsp],r12
    1339:	mov    QWORD PTR [rsp+0x8],r14
    133e:	mov    QWORD PTR [rsp+0x10],rax
    1343:	mov    rdx,QWORD PTR [rsp+0x30]
    1348:	mov    QWORD PTR [rsp+0x18],rdx
    134d:	mov    rcx,QWORD PTR [rsp+0x30]
    1352:	mov    QWORD PTR [rsp+0x38],rcx
    1357:	mov    QWORD PTR [rsp+0x30],rax
    135c:	jmp    f24 <botlish_fn_17+0x74>
    1361:	mov    rdi,QWORD PTR [rsp+0x28]
    1366:	mov    QWORD PTR [rdi],rbx
    1369:	mov    rax,QWORD PTR [rsp+0x30]
    136e:	mov    rbx,QWORD PTR [rsp+0x40]
    1373:	mov    r12,QWORD PTR [rsp+0x48]
    1378:	mov    r13,QWORD PTR [rsp+0x50]
    137d:	mov    r14,QWORD PTR [rsp+0x58]
    1382:	mov    r15,QWORD PTR [rsp+0x60]
    1387:	add    rsp,0x70
    138b:	mov    rsp,rbp
    138e:	pop    rbp
    138f:	ret
    1390:	mov    rax,QWORD PTR [rsp+0x38]
    1395:	test   rax,0x1
    139b:	jne    13ca <botlish_fn_17+0x51a>
    13a1:	mov    edx,0x1
    13a6:	mov    rsi,QWORD PTR [rsp+0x38]
    13ab:	mov    rdi,QWORD PTR [rsp+0x28]
    13b0:	call   13b5 <botlish_fn_17+0x505>
			13b1: R_X86_64_PLT32	rt_int_cmp-0x4
    13b5:	mov    ecx,0x2
    13ba:	test   rax,rax
    13bd:	cmovge rcx,QWORD PTR [rip+0xbb]        # 1480 <botlish_fn_17+0x5d0>
    13c5:	jmp    13e4 <botlish_fn_17+0x534>
    13ca:	mov    ecx,0x2
    13cf:	mov    rax,QWORD PTR [rsp+0x38]
    13d4:	mov    r11,QWORD PTR [rsp+0x38]
    13d9:	test   rax,r11
    13dc:	cmovg  rcx,QWORD PTR [rip+0x9c]        # 1480 <botlish_fn_17+0x5d0>
    13e4:	cmp    rcx,0x6
    13e8:	je     141d <botlish_fn_17+0x56d>
    13ee:	mov    rdi,QWORD PTR [rsp+0x28]
    13f3:	mov    QWORD PTR [rdi],rbx
    13f6:	mov    rax,QWORD PTR [rsp+0x30]
    13fb:	mov    rbx,QWORD PTR [rsp+0x40]
    1400:	mov    r12,QWORD PTR [rsp+0x48]
    1405:	mov    r13,QWORD PTR [rsp+0x50]
    140a:	mov    r14,QWORD PTR [rsp+0x58]
    140f:	mov    r15,QWORD PTR [rsp+0x60]
    1414:	add    rsp,0x70
    1418:	mov    rsp,rbp
    141b:	pop    rbp
    141c:	ret
    141d:	mov    rdi,QWORD PTR [rsp+0x28]
    1422:	mov    QWORD PTR [rdi],rbx
    1425:	mov    rax,QWORD PTR [rsp+0x38]
    142a:	mov    rbx,QWORD PTR [rsp+0x40]
    142f:	mov    r12,QWORD PTR [rsp+0x48]
    1434:	mov    r13,QWORD PTR [rsp+0x50]
    1439:	mov    r14,QWORD PTR [rsp+0x58]
    143e:	mov    r15,QWORD PTR [rsp+0x60]
    1443:	add    rsp,0x70
    1447:	mov    rsp,rbp
    144a:	pop    rbp
    144b:	ret
    144c:	mov    QWORD PTR [rsp+0x28],rdi
    1451:	call   1456 <botlish_fn_17+0x5a6>
			1452: R_X86_64_PLT32	rt_stack_overflow-0x4
    1456:	xor    rax,rax
    1459:	mov    rbx,QWORD PTR [rsp+0x40]
    145e:	mov    r12,QWORD PTR [rsp+0x48]
    1463:	mov    r13,QWORD PTR [rsp+0x50]
    1468:	mov    r14,QWORD PTR [rsp+0x58]
    146d:	mov    r15,QWORD PTR [rsp+0x60]
    1472:	add    rsp,0x70
    1476:	mov    rsp,rbp
    1479:	pop    rbp
    147a:	ret
    147b:	add    BYTE PTR [rax],al
    147d:	add    BYTE PTR [rax],al
    147f:	add    BYTE PTR [rsi],al
    1481:	add    BYTE PTR [rax],al
    1483:	add    BYTE PTR [rax],al
    1485:	add    BYTE PTR [rax],al
	...

0000000000001488 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
    1488:	push   rbp
    1489:	mov    rbp,rsp
    148c:	mov    rsi,QWORD PTR [rdx]
    148f:	mov    r9,QWORD PTR [rdx+0x8]
    1493:	mov    rcx,QWORD PTR [rdx+0x10]
    1497:	mov    r8,QWORD PTR [rdx+0x18]
    149b:	mov    rdx,r9
    149e:	call   14a3 <botlish_entry_17+0x1b>
			149f: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    14a3:	mov    rsp,rbp
    14a6:	pop    rbp
    14a7:	ret

00000000000014a8 <botlish_fn_18: ht_get<mutarray, str>>:
    14a8:	push   rbp
    14a9:	mov    rbp,rsp
    14ac:	sub    rsp,0x40
    14b0:	mov    QWORD PTR [rsp+0x20],rbx
    14b5:	mov    QWORD PTR [rsp+0x28],r12
    14ba:	mov    QWORD PTR [rsp+0x30],r13
    14bf:	mov    QWORD PTR [rsp+0x38],r14
    14c4:	mov    rbx,QWORD PTR [rdi]
    14c7:	mov    rax,QWORD PTR [rdi+0x8]
    14cb:	lea    rcx,[rbx+0x8]
    14cf:	cmp    rcx,rax
    14d2:	ja     168b <botlish_fn_18+0x1e3>
    14d8:	lea    rax,[rbx+0x8]
    14dc:	mov    QWORD PTR [rdi],rax
    14df:	mov    r12,rdi
    14e2:	mov    QWORD PTR [rbx],0x0
    14e9:	mov    QWORD PTR [rsp+0x10],0x0
    14f2:	mov    QWORD PTR [rsp],rsi
    14f6:	mov    r13,rsi
    14f9:	mov    QWORD PTR [rsp+0x8],rdx
    14fe:	mov    r14,rdx
    1501:	mov    rdx,r14
    1504:	mov    rsi,r13
    1507:	mov    rdi,r12
    150a:	call   150f <botlish_fn_18+0x67>
			150b: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    150f:	test   rax,rax
    1512:	jne    1520 <botlish_fn_18+0x78>
    1518:	mov    rdi,r12
    151b:	jmp    161a <botlish_fn_18+0x172>
    1520:	mov    QWORD PTR [rsp+0x10],rax
    1525:	mov    rcx,rax
    1528:	mov    rdx,r14
    152b:	mov    rsi,r13
    152e:	mov    rdi,r12
    1531:	call   1536 <botlish_fn_18+0x8e>
			1532: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1536:	mov    r11,rax
    1539:	mov    r14,rax
    153c:	test   rax,r11
    153f:	jne    154d <botlish_fn_18+0xa5>
    1545:	mov    rdi,r12
    1548:	jmp    161a <botlish_fn_18+0x172>
    154d:	mov    rax,r14
    1550:	mov    QWORD PTR [rsp+0x8],rax
    1555:	test   rax,0x1
    155b:	jne    1586 <botlish_fn_18+0xde>
    1561:	mov    edx,0x1
    1566:	mov    rsi,r14
    1569:	mov    rdi,r12
    156c:	call   1571 <botlish_fn_18+0xc9>
			156d: R_X86_64_PLT32	rt_int_cmp-0x4
    1571:	mov    ecx,0x2
    1576:	test   rax,rax
    1579:	cmovl  rcx,QWORD PTR [rip+0x137]        # 16b8 <botlish_fn_18+0x210>
    1581:	jmp    1599 <botlish_fn_18+0xf1>
    1586:	mov    ecx,0x2
    158b:	mov    rax,r14
    158e:	test   rax,rax
    1591:	cmovle rcx,QWORD PTR [rip+0x11f]        # 16b8 <botlish_fn_18+0x210>
    1599:	cmp    rcx,0x6
    159d:	je     1663 <botlish_fn_18+0x1bb>
    15a3:	mov    rsi,r13
    15a6:	mov    rdi,r12
    15a9:	call   15ae <botlish_fn_18+0x106>
			15aa: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    15ae:	test   rax,rax
    15b1:	jne    15bf <botlish_fn_18+0x117>
    15b7:	mov    rdi,r12
    15ba:	jmp    161a <botlish_fn_18+0x172>
    15bf:	xor    ecx,ecx
    15c1:	test   rax,0x7
    15c7:	jne    15d8 <botlish_fn_18+0x130>
    15cd:	movzx  rcx,BYTE PTR [rax]
    15d1:	rex cmp cl,0x8
    15d5:	sete   cl
    15d8:	test   cl,cl
    15da:	jne    1600 <botlish_fn_18+0x158>
    15e0:	mov    rdi,r12
    15e3:	mov    rsi,QWORD PTR [rdi+0x10]
    15e7:	mov    rcx,QWORD PTR [rsi+0x8]
    15eb:	mov    edx,0x8
    15f0:	mov    rsi,rax
    15f3:	call   15f8 <botlish_fn_18+0x150>
			15f4: R_X86_64_PLT32	rt_type_error-0x4
    15f8:	mov    rdi,r12
    15fb:	jmp    161a <botlish_fn_18+0x172>
    1600:	mov    rdx,r14
    1603:	mov    rsi,rax
    1606:	mov    rdi,r12
    1609:	call   160e <botlish_fn_18+0x166>
			160a: R_X86_64_PLT32	rt_mutarray_get-0x4
    160e:	test   rax,rax
    1611:	jne    1640 <botlish_fn_18+0x198>
    1617:	mov    rdi,r12
    161a:	mov    rdi,r12
    161d:	mov    QWORD PTR [rdi],rbx
    1620:	xor    rax,rax
    1623:	mov    rbx,QWORD PTR [rsp+0x20]
    1628:	mov    r12,QWORD PTR [rsp+0x28]
    162d:	mov    r13,QWORD PTR [rsp+0x30]
    1632:	mov    r14,QWORD PTR [rsp+0x38]
    1637:	add    rsp,0x40
    163b:	mov    rsp,rbp
    163e:	pop    rbp
    163f:	ret
    1640:	mov    rdi,r12
    1643:	mov    QWORD PTR [rdi],rbx
    1646:	mov    rbx,QWORD PTR [rsp+0x20]
    164b:	mov    r12,QWORD PTR [rsp+0x28]
    1650:	mov    r13,QWORD PTR [rsp+0x30]
    1655:	mov    r14,QWORD PTR [rsp+0x38]
    165a:	add    rsp,0x40
    165e:	mov    rsp,rbp
    1661:	pop    rbp
    1662:	ret
    1663:	mov    rdi,r12
    1666:	mov    QWORD PTR [rdi],rbx
    1669:	mov    eax,0xa
    166e:	mov    rbx,QWORD PTR [rsp+0x20]
    1673:	mov    r12,QWORD PTR [rsp+0x28]
    1678:	mov    r13,QWORD PTR [rsp+0x30]
    167d:	mov    r14,QWORD PTR [rsp+0x38]
    1682:	add    rsp,0x40
    1686:	mov    rsp,rbp
    1689:	pop    rbp
    168a:	ret
    168b:	mov    r12,rdi
    168e:	call   1693 <botlish_fn_18+0x1eb>
			168f: R_X86_64_PLT32	rt_stack_overflow-0x4
    1693:	xor    rax,rax
    1696:	mov    rbx,QWORD PTR [rsp+0x20]
    169b:	mov    r12,QWORD PTR [rsp+0x28]
    16a0:	mov    r13,QWORD PTR [rsp+0x30]
    16a5:	mov    r14,QWORD PTR [rsp+0x38]
    16aa:	add    rsp,0x40
    16ae:	mov    rsp,rbp
    16b1:	pop    rbp
    16b2:	ret
    16b3:	add    BYTE PTR [rax],al
    16b5:	add    BYTE PTR [rax],al
    16b7:	add    BYTE PTR [rsi],al
    16b9:	add    BYTE PTR [rax],al
    16bb:	add    BYTE PTR [rax],al
    16bd:	add    BYTE PTR [rax],al
	...

00000000000016c0 <botlish_entry_18: ht_get<mutarray, str>>:
    16c0:	push   rbp
    16c1:	mov    rbp,rsp
    16c4:	mov    rsi,QWORD PTR [rdx]
    16c7:	mov    rdx,QWORD PTR [rdx+0x8]
    16cb:	call   16d0 <botlish_entry_18+0x10>
			16cc: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    16d0:	mov    rsp,rbp
    16d3:	pop    rbp
    16d4:	ret
    16d5:	add    BYTE PTR [rax],al
	...

00000000000016d8 <botlish_fn_19: ht_contains<mutarray, str>>:
    16d8:	push   rbp
    16d9:	mov    rbp,rsp
    16dc:	sub    rsp,0x40
    16e0:	mov    QWORD PTR [rsp+0x20],rbx
    16e5:	mov    QWORD PTR [rsp+0x28],r12
    16ea:	mov    QWORD PTR [rsp+0x30],r13
    16ef:	mov    QWORD PTR [rsp+0x38],r14
    16f4:	mov    rbx,QWORD PTR [rdi]
    16f7:	mov    rax,QWORD PTR [rdi+0x8]
    16fb:	lea    rcx,[rbx+0x8]
    16ff:	cmp    rcx,rax
    1702:	ja     1805 <botlish_fn_19+0x12d>
    1708:	lea    rax,[rbx+0x8]
    170c:	mov    QWORD PTR [rdi],rax
    170f:	mov    r12,rdi
    1712:	mov    QWORD PTR [rbx],0x0
    1719:	mov    QWORD PTR [rsp+0x10],0x0
    1722:	mov    QWORD PTR [rsp],rsi
    1726:	mov    r14,rsi
    1729:	mov    QWORD PTR [rsp+0x8],rdx
    172e:	mov    r13,rdx
    1731:	mov    rdx,r13
    1734:	mov    rsi,r14
    1737:	mov    rdi,r12
    173a:	call   173f <botlish_fn_19+0x67>
			173b: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    173f:	test   rax,rax
    1742:	jne    1750 <botlish_fn_19+0x78>
    1748:	mov    rdi,r12
    174b:	jmp    1772 <botlish_fn_19+0x9a>
    1750:	mov    QWORD PTR [rsp+0x10],rax
    1755:	mov    rcx,rax
    1758:	mov    rdx,r13
    175b:	mov    rsi,r14
    175e:	mov    rdi,r12
    1761:	call   1766 <botlish_fn_19+0x8e>
			1762: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1766:	test   rax,rax
    1769:	jne    1798 <botlish_fn_19+0xc0>
    176f:	mov    rdi,r12
    1772:	mov    rdi,r12
    1775:	mov    QWORD PTR [rdi],rbx
    1778:	xor    rax,rax
    177b:	mov    rbx,QWORD PTR [rsp+0x20]
    1780:	mov    r12,QWORD PTR [rsp+0x28]
    1785:	mov    r13,QWORD PTR [rsp+0x30]
    178a:	mov    r14,QWORD PTR [rsp+0x38]
    178f:	add    rsp,0x40
    1793:	mov    rsp,rbp
    1796:	pop    rbp
    1797:	ret
    1798:	test   rax,0x1
    179e:	mov    rsi,rax
    17a1:	jne    17cf <botlish_fn_19+0xf7>
    17a7:	mov    edx,0x1
    17ac:	mov    rdi,r12
    17af:	call   17b4 <botlish_fn_19+0xdc>
			17b0: R_X86_64_PLT32	rt_int_cmp-0x4
    17b4:	mov    ecx,0x2
    17b9:	test   rax,rax
    17bc:	mov    rax,rcx
    17bf:	cmovge rax,QWORD PTR [rip+0x69]        # 1830 <botlish_fn_19+0x158>
    17c7:	mov    rdi,r12
    17ca:	jmp    17e2 <botlish_fn_19+0x10a>
    17cf:	mov    eax,0x2
    17d4:	test   rsi,rsi
    17d7:	cmovg  rax,QWORD PTR [rip+0x51]        # 1830 <botlish_fn_19+0x158>
    17df:	mov    rdi,r12
    17e2:	mov    rdi,r12
    17e5:	mov    QWORD PTR [rdi],rbx
    17e8:	mov    rbx,QWORD PTR [rsp+0x20]
    17ed:	mov    r12,QWORD PTR [rsp+0x28]
    17f2:	mov    r13,QWORD PTR [rsp+0x30]
    17f7:	mov    r14,QWORD PTR [rsp+0x38]
    17fc:	add    rsp,0x40
    1800:	mov    rsp,rbp
    1803:	pop    rbp
    1804:	ret
    1805:	mov    r12,rdi
    1808:	call   180d <botlish_fn_19+0x135>
			1809: R_X86_64_PLT32	rt_stack_overflow-0x4
    180d:	xor    rax,rax
    1810:	mov    rbx,QWORD PTR [rsp+0x20]
    1815:	mov    r12,QWORD PTR [rsp+0x28]
    181a:	mov    r13,QWORD PTR [rsp+0x30]
    181f:	mov    r14,QWORD PTR [rsp+0x38]
    1824:	add    rsp,0x40
    1828:	mov    rsp,rbp
    182b:	pop    rbp
    182c:	ret
    182d:	add    BYTE PTR [rax],al
    182f:	add    BYTE PTR [rsi],al
    1831:	add    BYTE PTR [rax],al
    1833:	add    BYTE PTR [rax],al
    1835:	add    BYTE PTR [rax],al
	...

0000000000001838 <botlish_entry_19: ht_contains<mutarray, str>>:
    1838:	push   rbp
    1839:	mov    rbp,rsp
    183c:	mov    rsi,QWORD PTR [rdx]
    183f:	mov    rdx,QWORD PTR [rdx+0x8]
    1843:	call   1848 <botlish_entry_19+0x10>
			1844: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    1848:	mov    rsp,rbp
    184b:	pop    rbp
    184c:	ret
    184d:	add    BYTE PTR [rax],al
	...

0000000000001850 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    1850:	push   rbp
    1851:	mov    rbp,rsp
    1854:	sub    rsp,0x60
    1858:	mov    QWORD PTR [rsp+0x30],rbx
    185d:	mov    QWORD PTR [rsp+0x38],r12
    1862:	mov    QWORD PTR [rsp+0x40],r13
    1867:	mov    QWORD PTR [rsp+0x48],r14
    186c:	mov    QWORD PTR [rsp+0x50],r15
    1871:	mov    r12,QWORD PTR [rdi]
    1874:	mov    rax,QWORD PTR [rdi+0x8]
    1878:	lea    r8,[r12+0x8]
    187d:	cmp    r8,rax
    1880:	ja     1a0b <botlish_fn_20+0x1bb>
    1886:	lea    rax,[r12+0x8]
    188b:	mov    QWORD PTR [rdi],rax
    188e:	mov    r14,rdi
    1891:	mov    QWORD PTR [r12],0x0
    1899:	mov    QWORD PTR [rsp],rsi
    189d:	mov    QWORD PTR [rsp+0x8],rdx
    18a2:	mov    QWORD PTR [rsp+0x10],rcx
    18a7:	mov    r13,rcx
    18aa:	mov    rbx,rsi
    18ad:	mov    r15,rdx
    18b0:	mov    rdx,r15
    18b3:	mov    rsi,rbx
    18b6:	mov    rdi,r14
    18b9:	call   18be <botlish_fn_20+0x6e>
			18ba: R_X86_64_PLT32	rt_mutarray_get-0x4
    18be:	test   rax,rax
    18c1:	jne    18cf <botlish_fn_20+0x7f>
    18c7:	mov    rdi,r14
    18ca:	jmp    199f <botlish_fn_20+0x14f>
    18cf:	mov    QWORD PTR [rsp+0x18],rax
    18d4:	mov    QWORD PTR [rsp+0x20],rax
    18d9:	mov    rdi,r14
    18dc:	call   18e1 <botlish_fn_20+0x91>
			18dd: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    18e1:	test   rax,rax
    18e4:	jne    18f2 <botlish_fn_20+0xa2>
    18ea:	mov    rdi,r14
    18ed:	jmp    199f <botlish_fn_20+0x14f>
    18f2:	mov    rsi,QWORD PTR [rsp+0x20]
    18f7:	mov    rcx,rsi
    18fa:	and    rcx,rax
    18fd:	mov    rdx,rax
    1900:	test   rcx,0x1
    1907:	jne    192b <botlish_fn_20+0xdb>
    190d:	mov    rsi,QWORD PTR [rsp+0x20]
    1912:	mov    rdi,r14
    1915:	call   191a <botlish_fn_20+0xca>
			1916: R_X86_64_PLT32	rt_value_eq-0x4
    191a:	test   rax,rax
    191d:	jne    1940 <botlish_fn_20+0xf0>
    1923:	mov    rdi,r14
    1926:	jmp    199f <botlish_fn_20+0x14f>
    192b:	mov    rsi,QWORD PTR [rsp+0x20]
    1930:	mov    eax,0x2
    1935:	cmp    rsi,rdx
    1938:	cmove  rax,QWORD PTR [rip+0xf8]        # 1a38 <botlish_fn_20+0x1e8>
    1940:	cmp    rax,0x6
    1944:	je     19e0 <botlish_fn_20+0x190>
    194a:	mov    QWORD PTR [rsp+0x18],0x3
    1953:	mov    rsi,r15
    1956:	test   rsi,0x1
    195d:	je     1975 <botlish_fn_20+0x125>
    1963:	mov    rsi,r15
    1966:	add    rsi,0x2
    196a:	seto   al
    196d:	test   al,al
    196f:	je     1988 <botlish_fn_20+0x138>
    1975:	mov    edx,0x3
    197a:	mov    rsi,r15
    197d:	mov    rdi,r14
    1980:	call   1985 <botlish_fn_20+0x135>
			1981: R_X86_64_PLT32	rt_int_add-0x4
    1985:	mov    rsi,rax
    1988:	mov    rdx,r13
    198b:	mov    rdi,r14
    198e:	call   1993 <botlish_fn_20+0x143>
			198f: R_X86_64_PLT32	rt_int_mod-0x4
    1993:	test   rax,rax
    1996:	jne    19ca <botlish_fn_20+0x17a>
    199c:	mov    rdi,r14
    199f:	mov    rdi,r14
    19a2:	mov    QWORD PTR [rdi],r12
    19a5:	xor    rax,rax
    19a8:	mov    rbx,QWORD PTR [rsp+0x30]
    19ad:	mov    r12,QWORD PTR [rsp+0x38]
    19b2:	mov    r13,QWORD PTR [rsp+0x40]
    19b7:	mov    r14,QWORD PTR [rsp+0x48]
    19bc:	mov    r15,QWORD PTR [rsp+0x50]
    19c1:	add    rsp,0x60
    19c5:	mov    rsp,rbp
    19c8:	pop    rbp
    19c9:	ret
    19ca:	mov    QWORD PTR [rsp],rbx
    19ce:	mov    QWORD PTR [rsp+0x8],rax
    19d3:	mov    QWORD PTR [rsp+0x10],r13
    19d8:	mov    r15,rax
    19db:	jmp    18b0 <botlish_fn_20+0x60>
    19e0:	mov    rdi,r14
    19e3:	mov    QWORD PTR [rdi],r12
    19e6:	mov    rax,r15
    19e9:	mov    rbx,QWORD PTR [rsp+0x30]
    19ee:	mov    r12,QWORD PTR [rsp+0x38]
    19f3:	mov    r13,QWORD PTR [rsp+0x40]
    19f8:	mov    r14,QWORD PTR [rsp+0x48]
    19fd:	mov    r15,QWORD PTR [rsp+0x50]
    1a02:	add    rsp,0x60
    1a06:	mov    rsp,rbp
    1a09:	pop    rbp
    1a0a:	ret
    1a0b:	mov    r14,rdi
    1a0e:	call   1a13 <botlish_fn_20+0x1c3>
			1a0f: R_X86_64_PLT32	rt_stack_overflow-0x4
    1a13:	xor    rax,rax
    1a16:	mov    rbx,QWORD PTR [rsp+0x30]
    1a1b:	mov    r12,QWORD PTR [rsp+0x38]
    1a20:	mov    r13,QWORD PTR [rsp+0x40]
    1a25:	mov    r14,QWORD PTR [rsp+0x48]
    1a2a:	mov    r15,QWORD PTR [rsp+0x50]
    1a2f:	add    rsp,0x60
    1a33:	mov    rsp,rbp
    1a36:	pop    rbp
    1a37:	ret
    1a38:	(bad)
    1a39:	add    BYTE PTR [rax],al
    1a3b:	add    BYTE PTR [rax],al
    1a3d:	add    BYTE PTR [rax],al
	...

0000000000001a40 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    1a40:	push   rbp
    1a41:	mov    rbp,rsp
    1a44:	mov    rsi,QWORD PTR [rdx]
    1a47:	mov    r8,QWORD PTR [rdx+0x8]
    1a4b:	mov    rcx,QWORD PTR [rdx+0x10]
    1a4f:	mov    rdx,r8
    1a52:	call   1a57 <botlish_entry_20+0x17>
			1a53: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1a57:	mov    rsp,rbp
    1a5a:	pop    rbp
    1a5b:	ret

0000000000001a5c <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1a5c:	push   rbp
    1a5d:	mov    rbp,rsp
    1a60:	sub    rsp,0x80
    1a67:	mov    QWORD PTR [rsp+0x50],rbx
    1a6c:	mov    QWORD PTR [rsp+0x58],r12
    1a71:	mov    QWORD PTR [rsp+0x60],r13
    1a76:	mov    QWORD PTR [rsp+0x68],r14
    1a7b:	mov    QWORD PTR [rsp+0x70],r15
    1a80:	mov    r10,QWORD PTR [rbp+0x10]
    1a84:	mov    rbx,QWORD PTR [rdi]
    1a87:	mov    rax,QWORD PTR [rdi+0x8]
    1a8b:	lea    r11,[rbx+0x8]
    1a8f:	cmp    r11,rax
    1a92:	ja     1c32 <botlish_fn_21+0x1d6>
    1a98:	lea    rax,[rbx+0x8]
    1a9c:	mov    QWORD PTR [rdi],rax
    1a9f:	mov    r12,rdi
    1aa2:	mov    QWORD PTR [rbx],0x0
    1aa9:	mov    QWORD PTR [rsp],rsi
    1aad:	mov    QWORD PTR [rsp+0x38],rsi
    1ab2:	mov    QWORD PTR [rsp+0x8],rdx
    1ab7:	mov    QWORD PTR [rsp+0x40],rdx
    1abc:	mov    QWORD PTR [rsp+0x10],rcx
    1ac1:	mov    r13,rcx
    1ac4:	mov    QWORD PTR [rsp+0x18],r8
    1ac9:	mov    QWORD PTR [rsp+0x48],r8
    1ace:	mov    QWORD PTR [rsp+0x20],r9
    1ad3:	mov    r15,r9
    1ad6:	mov    QWORD PTR [rsp+0x28],r10
    1adb:	mov    r14,r10
    1ade:	mov    rsi,r15
    1ae1:	mov    rdi,r12
    1ae4:	call   1ae9 <botlish_fn_21+0x8d>
			1ae5: R_X86_64_PLT32	rt_hash-0x4
    1ae9:	test   rax,rax
    1aec:	mov    rsi,rax
    1aef:	jne    1afd <botlish_fn_21+0xa1>
    1af5:	mov    rdi,r12
    1af8:	jmp    1bd4 <botlish_fn_21+0x178>
    1afd:	mov    rdx,QWORD PTR [rsp+0x48]
    1b02:	mov    rdi,r12
    1b05:	call   1b0a <botlish_fn_21+0xae>
			1b06: R_X86_64_PLT32	rt_int_mod-0x4
    1b0a:	test   rax,rax
    1b0d:	jne    1b1b <botlish_fn_21+0xbf>
    1b13:	mov    rdi,r12
    1b16:	jmp    1bd4 <botlish_fn_21+0x178>
    1b1b:	mov    QWORD PTR [rsp+0x30],rax
    1b20:	mov    rcx,QWORD PTR [rsp+0x48]
    1b25:	mov    rdx,rax
    1b28:	mov    rsi,QWORD PTR [rsp+0x38]
    1b2d:	mov    rdi,r12
    1b30:	call   1b35 <botlish_fn_21+0xd9>
			1b31: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1b35:	test   rax,rax
    1b38:	jne    1b46 <botlish_fn_21+0xea>
    1b3e:	mov    rdi,r12
    1b41:	jmp    1bd4 <botlish_fn_21+0x178>
    1b46:	mov    QWORD PTR [rsp+0x18],rax
    1b4b:	mov    QWORD PTR [rsp+0x48],rax
    1b50:	mov    rdi,r12
    1b53:	call   1b58 <botlish_fn_21+0xfc>
			1b54: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1b58:	test   rax,rax
    1b5b:	mov    rcx,rax
    1b5e:	jne    1b6c <botlish_fn_21+0x110>
    1b64:	mov    rdi,r12
    1b67:	jmp    1bd4 <botlish_fn_21+0x178>
    1b6c:	mov    rsi,QWORD PTR [rsp+0x38]
    1b71:	mov    rdx,QWORD PTR [rsp+0x48]
    1b76:	mov    rdi,r12
    1b79:	call   1b7e <botlish_fn_21+0x122>
			1b7a: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b7e:	test   rax,rax
    1b81:	jne    1b8f <botlish_fn_21+0x133>
    1b87:	mov    rdi,r12
    1b8a:	jmp    1bd4 <botlish_fn_21+0x178>
    1b8f:	mov    rcx,r15
    1b92:	mov    rsi,QWORD PTR [rsp+0x40]
    1b97:	mov    rdx,QWORD PTR [rsp+0x48]
    1b9c:	mov    rdi,r12
    1b9f:	call   1ba4 <botlish_fn_21+0x148>
			1ba0: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ba4:	test   rax,rax
    1ba7:	jne    1bb5 <botlish_fn_21+0x159>
    1bad:	mov    rdi,r12
    1bb0:	jmp    1bd4 <botlish_fn_21+0x178>
    1bb5:	mov    rcx,r14
    1bb8:	mov    rdx,QWORD PTR [rsp+0x48]
    1bbd:	mov    rsi,r13
    1bc0:	mov    rdi,r12
    1bc3:	call   1bc8 <botlish_fn_21+0x16c>
			1bc4: R_X86_64_PLT32	rt_mutarray_set-0x4
    1bc8:	test   rax,rax
    1bcb:	jne    1c02 <botlish_fn_21+0x1a6>
    1bd1:	mov    rdi,r12
    1bd4:	mov    rdi,r12
    1bd7:	mov    QWORD PTR [rdi],rbx
    1bda:	xor    rax,rax
    1bdd:	mov    rbx,QWORD PTR [rsp+0x50]
    1be2:	mov    r12,QWORD PTR [rsp+0x58]
    1be7:	mov    r13,QWORD PTR [rsp+0x60]
    1bec:	mov    r14,QWORD PTR [rsp+0x68]
    1bf1:	mov    r15,QWORD PTR [rsp+0x70]
    1bf6:	add    rsp,0x80
    1bfd:	mov    rsp,rbp
    1c00:	pop    rbp
    1c01:	ret
    1c02:	mov    rdi,r12
    1c05:	mov    QWORD PTR [rdi],rbx
    1c08:	mov    eax,0xa
    1c0d:	mov    rbx,QWORD PTR [rsp+0x50]
    1c12:	mov    r12,QWORD PTR [rsp+0x58]
    1c17:	mov    r13,QWORD PTR [rsp+0x60]
    1c1c:	mov    r14,QWORD PTR [rsp+0x68]
    1c21:	mov    r15,QWORD PTR [rsp+0x70]
    1c26:	add    rsp,0x80
    1c2d:	mov    rsp,rbp
    1c30:	pop    rbp
    1c31:	ret
    1c32:	mov    r12,rdi
    1c35:	call   1c3a <botlish_fn_21+0x1de>
			1c36: R_X86_64_PLT32	rt_stack_overflow-0x4
    1c3a:	xor    rax,rax
    1c3d:	mov    rbx,QWORD PTR [rsp+0x50]
    1c42:	mov    r12,QWORD PTR [rsp+0x58]
    1c47:	mov    r13,QWORD PTR [rsp+0x60]
    1c4c:	mov    r14,QWORD PTR [rsp+0x68]
    1c51:	mov    r15,QWORD PTR [rsp+0x70]
    1c56:	add    rsp,0x80
    1c5d:	mov    rsp,rbp
    1c60:	pop    rbp
    1c61:	ret

0000000000001c62 <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1c62:	push   rbp
    1c63:	mov    rbp,rsp
    1c66:	sub    rsp,0x10
    1c6a:	mov    rsi,QWORD PTR [rdx]
    1c6d:	mov    r10,QWORD PTR [rdx+0x8]
    1c71:	mov    rcx,QWORD PTR [rdx+0x10]
    1c75:	mov    r8,QWORD PTR [rdx+0x18]
    1c79:	mov    r9,QWORD PTR [rdx+0x20]
    1c7d:	mov    r11,QWORD PTR [rdx+0x28]
    1c81:	mov    QWORD PTR [rsp],r11
    1c85:	mov    rdx,r10
    1c88:	call   1c8d <botlish_entry_21+0x2b>
			1c89: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    1c8d:	add    rsp,0x10
    1c91:	mov    rsp,rbp
    1c94:	pop    rbp
    1c95:	ret
	...

0000000000001c98 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1c98:	push   rbp
    1c99:	mov    rbp,rsp
    1c9c:	sub    rsp,0xd0
    1ca3:	mov    QWORD PTR [rsp+0xa0],rbx
    1cab:	mov    QWORD PTR [rsp+0xa8],r12
    1cb3:	mov    QWORD PTR [rsp+0xb0],r13
    1cbb:	mov    QWORD PTR [rsp+0xb8],r14
    1cc3:	mov    QWORD PTR [rsp+0xc0],r15
    1ccb:	mov    r13,QWORD PTR [rbp+0x10]
    1ccf:	mov    r14,QWORD PTR [rbp+0x18]
    1cd3:	mov    r15,QWORD PTR [rbp+0x20]
    1cd7:	mov    r12,QWORD PTR [rbp+0x28]
    1cdb:	mov    r10,QWORD PTR [rdi]
    1cde:	mov    r11,QWORD PTR [rdi+0x8]
    1ce2:	lea    rax,[r10+0x8]
    1ce6:	cmp    rax,r11
    1ce9:	ja     21d9 <botlish_fn_22+0x541>
    1cef:	lea    rax,[r10+0x8]
    1cf3:	mov    QWORD PTR [rdi],rax
    1cf6:	mov    QWORD PTR [rsp+0x68],rdi
    1cfb:	mov    QWORD PTR [r10],0x0
    1d02:	mov    QWORD PTR [rsp+0x98],r10
    1d0a:	mov    QWORD PTR [rsp+0x60],0x0
    1d13:	mov    QWORD PTR [rsp+0x10],rsi
    1d18:	mov    QWORD PTR [rsp+0x70],rsi
    1d1d:	mov    QWORD PTR [rsp+0x18],rdx
    1d22:	mov    QWORD PTR [rsp+0x78],rdx
    1d27:	mov    QWORD PTR [rsp+0x20],rcx
    1d2c:	mov    QWORD PTR [rsp+0x80],rcx
    1d34:	mov    QWORD PTR [rsp+0x28],r8
    1d39:	mov    QWORD PTR [rsp+0x30],r9
    1d3e:	mov    QWORD PTR [rsp+0x88],r9
    1d46:	mov    QWORD PTR [rsp+0x38],r13
    1d4b:	mov    QWORD PTR [rsp+0x40],r14
    1d50:	mov    QWORD PTR [rsp+0x48],r15
    1d55:	mov    QWORD PTR [rsp+0x50],r12
    1d5a:	mov    rbx,QWORD PTR [rsp+0x88]
    1d62:	mov    rsi,r8
    1d65:	mov    rax,rsi
    1d68:	and    rax,rbx
    1d6b:	mov    QWORD PTR [rsp+0x90],rsi
    1d73:	test   rax,0x1
    1d79:	jne    1db1 <botlish_fn_22+0x119>
    1d7f:	mov    rdx,rbx
    1d82:	mov    rsi,QWORD PTR [rsp+0x90]
    1d8a:	mov    rdi,QWORD PTR [rsp+0x68]
    1d8f:	call   1d94 <botlish_fn_22+0xfc>
			1d90: R_X86_64_PLT32	rt_int_cmp-0x4
    1d94:	mov    QWORD PTR [rsp+0x88],rbx
    1d9c:	mov    ecx,0x2
    1da1:	test   rax,rax
    1da4:	cmovge rcx,QWORD PTR [rip+0x474]        # 2220 <botlish_fn_22+0x588>
    1dac:	jmp    1dd9 <botlish_fn_22+0x141>
    1db1:	mov    QWORD PTR [rsp+0x88],rbx
    1db9:	mov    ecx,0x2
    1dbe:	mov    rsi,QWORD PTR [rsp+0x90]
    1dc6:	mov    r9,QWORD PTR [rsp+0x88]
    1dce:	cmp    rsi,r9
    1dd1:	cmovge rcx,QWORD PTR [rip+0x447]        # 2220 <botlish_fn_22+0x588>
    1dd9:	cmp    rcx,0x6
    1ddd:	je     2190 <botlish_fn_22+0x4f8>
    1de3:	xor    eax,eax
    1de5:	mov    rsi,QWORD PTR [rsp+0x70]
    1dea:	test   rsi,0x7
    1df1:	jne    1e00 <botlish_fn_22+0x168>
    1df7:	movzx  rax,BYTE PTR [rsi]
    1dfb:	cmp    al,0x8
    1dfd:	sete   al
    1e00:	test   al,al
    1e02:	jne    1e31 <botlish_fn_22+0x199>
    1e08:	mov    rdi,QWORD PTR [rsp+0x68]
    1e0d:	mov    rax,QWORD PTR [rdi+0x10]
    1e11:	mov    rcx,QWORD PTR [rax+0x8]
    1e15:	mov    edx,0x8
    1e1a:	call   1e1f <botlish_fn_22+0x187>
			1e1b: R_X86_64_PLT32	rt_type_error-0x4
    1e1f:	mov    rbx,QWORD PTR [rsp+0x98]
    1e27:	mov    rdi,QWORD PTR [rsp+0x68]
    1e2c:	jmp    2077 <botlish_fn_22+0x3df>
    1e31:	mov    QWORD PTR [rsp+0x70],rsi
    1e36:	mov    rdx,QWORD PTR [rsp+0x90]
    1e3e:	mov    rdi,QWORD PTR [rsp+0x68]
    1e43:	call   1e48 <botlish_fn_22+0x1b0>
			1e44: R_X86_64_PLT32	rt_mutarray_get-0x4
    1e48:	test   rax,rax
    1e4b:	jne    1e63 <botlish_fn_22+0x1cb>
    1e51:	mov    rbx,QWORD PTR [rsp+0x98]
    1e59:	mov    rdi,QWORD PTR [rsp+0x68]
    1e5e:	jmp    2077 <botlish_fn_22+0x3df>
    1e63:	mov    QWORD PTR [rsp+0x58],rax
    1e68:	mov    rbx,rax
    1e6b:	mov    rdi,QWORD PTR [rsp+0x68]
    1e70:	call   1e75 <botlish_fn_22+0x1dd>
			1e71: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1e75:	test   rax,rax
    1e78:	jne    1e90 <botlish_fn_22+0x1f8>
    1e7e:	mov    rbx,QWORD PTR [rsp+0x98]
    1e86:	mov    rdi,QWORD PTR [rsp+0x68]
    1e8b:	jmp    2077 <botlish_fn_22+0x3df>
    1e90:	mov    rcx,rbx
    1e93:	mov    rdx,rcx
    1e96:	and    rdx,rax
    1e99:	test   rdx,0x1
    1ea0:	jne    1ed1 <botlish_fn_22+0x239>
    1ea6:	mov    rdx,rax
    1ea9:	mov    rsi,rbx
    1eac:	mov    rdi,QWORD PTR [rsp+0x68]
    1eb1:	call   1eb6 <botlish_fn_22+0x21e>
			1eb2: R_X86_64_PLT32	rt_value_eq-0x4
    1eb6:	test   rax,rax
    1eb9:	jne    1ee7 <botlish_fn_22+0x24f>
    1ebf:	mov    rbx,QWORD PTR [rsp+0x98]
    1ec7:	mov    rdi,QWORD PTR [rsp+0x68]
    1ecc:	jmp    2077 <botlish_fn_22+0x3df>
    1ed1:	mov    rdx,rax
    1ed4:	mov    rsi,rbx
    1ed7:	mov    eax,0x2
    1edc:	cmp    rsi,rdx
    1edf:	cmove  rax,QWORD PTR [rip+0x339]        # 2220 <botlish_fn_22+0x588>
    1ee7:	cmp    rax,0x6
    1eeb:	je     1efe <botlish_fn_22+0x266>
    1ef1:	mov    rbx,QWORD PTR [rsp+0x98]
    1ef9:	jmp    20be <botlish_fn_22+0x426>
    1efe:	xor    eax,eax
    1f00:	mov    rdx,QWORD PTR [rsp+0x78]
    1f05:	test   rdx,0x7
    1f0c:	je     1f1c <botlish_fn_22+0x284>
    1f12:	mov    QWORD PTR [rsp+0x78],rdx
    1f17:	jmp    1f2c <botlish_fn_22+0x294>
    1f1c:	movzx  rcx,BYTE PTR [rdx]
    1f20:	mov    QWORD PTR [rsp+0x78],rdx
    1f25:	rex cmp cl,0x8
    1f29:	sete   al
    1f2c:	test   al,al
    1f2e:	jne    1f62 <botlish_fn_22+0x2ca>
    1f34:	mov    rdi,QWORD PTR [rsp+0x68]
    1f39:	mov    rsi,QWORD PTR [rdi+0x10]
    1f3d:	mov    rcx,QWORD PTR [rsi+0x8]
    1f41:	mov    edx,0x8
    1f46:	mov    rsi,QWORD PTR [rsp+0x78]
    1f4b:	call   1f50 <botlish_fn_22+0x2b8>
			1f4c: R_X86_64_PLT32	rt_type_error-0x4
    1f50:	mov    rbx,QWORD PTR [rsp+0x98]
    1f58:	mov    rdi,QWORD PTR [rsp+0x68]
    1f5d:	jmp    2077 <botlish_fn_22+0x3df>
    1f62:	mov    rdx,QWORD PTR [rsp+0x90]
    1f6a:	mov    rsi,QWORD PTR [rsp+0x78]
    1f6f:	mov    rdi,QWORD PTR [rsp+0x68]
    1f74:	call   1f79 <botlish_fn_22+0x2e1>
			1f75: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f79:	test   rax,rax
    1f7c:	jne    1f94 <botlish_fn_22+0x2fc>
    1f82:	mov    rbx,QWORD PTR [rsp+0x98]
    1f8a:	mov    rdi,QWORD PTR [rsp+0x68]
    1f8f:	jmp    2077 <botlish_fn_22+0x3df>
    1f94:	mov    QWORD PTR [rsp+0x58],rax
    1f99:	mov    rbx,rax
    1f9c:	xor    eax,eax
    1f9e:	mov    rcx,QWORD PTR [rsp+0x80]
    1fa6:	test   rcx,0x7
    1fad:	je     1fc0 <botlish_fn_22+0x328>
    1fb3:	mov    QWORD PTR [rsp+0x80],rcx
    1fbb:	jmp    1fd1 <botlish_fn_22+0x339>
    1fc0:	movzx  rax,BYTE PTR [rcx]
    1fc4:	mov    QWORD PTR [rsp+0x80],rcx
    1fcc:	cmp    al,0x8
    1fce:	sete   al
    1fd1:	test   al,al
    1fd3:	jne    200a <botlish_fn_22+0x372>
    1fd9:	mov    rdi,QWORD PTR [rsp+0x68]
    1fde:	mov    rax,QWORD PTR [rdi+0x10]
    1fe2:	mov    rcx,QWORD PTR [rax+0x8]
    1fe6:	mov    edx,0x8
    1feb:	mov    rsi,QWORD PTR [rsp+0x80]
    1ff3:	call   1ff8 <botlish_fn_22+0x360>
			1ff4: R_X86_64_PLT32	rt_type_error-0x4
    1ff8:	mov    rbx,QWORD PTR [rsp+0x98]
    2000:	mov    rdi,QWORD PTR [rsp+0x68]
    2005:	jmp    2077 <botlish_fn_22+0x3df>
    200a:	mov    rdx,QWORD PTR [rsp+0x90]
    2012:	mov    rsi,QWORD PTR [rsp+0x80]
    201a:	mov    rdi,QWORD PTR [rsp+0x68]
    201f:	call   2024 <botlish_fn_22+0x38c>
			2020: R_X86_64_PLT32	rt_mutarray_get-0x4
    2024:	test   rax,rax
    2027:	jne    203f <botlish_fn_22+0x3a7>
    202d:	mov    rbx,QWORD PTR [rsp+0x98]
    2035:	mov    rdi,QWORD PTR [rsp+0x68]
    203a:	jmp    2077 <botlish_fn_22+0x3df>
    203f:	mov    QWORD PTR [rsp+0x60],rax
    2044:	mov    QWORD PTR [rsp],rax
    2048:	mov    r9,rbx
    204b:	mov    rcx,r15
    204e:	mov    rdx,r14
    2051:	mov    rsi,r13
    2054:	mov    rdi,QWORD PTR [rsp+0x68]
    2059:	mov    r8,r12
    205c:	call   2061 <botlish_fn_22+0x3c9>
			205d: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    2061:	test   rax,rax
    2064:	jne    20b6 <botlish_fn_22+0x41e>
    206a:	mov    rbx,QWORD PTR [rsp+0x98]
    2072:	mov    rdi,QWORD PTR [rsp+0x68]
    2077:	mov    rdi,QWORD PTR [rsp+0x68]
    207c:	mov    QWORD PTR [rdi],rbx
    207f:	xor    rax,rax
    2082:	mov    rbx,QWORD PTR [rsp+0xa0]
    208a:	mov    r12,QWORD PTR [rsp+0xa8]
    2092:	mov    r13,QWORD PTR [rsp+0xb0]
    209a:	mov    r14,QWORD PTR [rsp+0xb8]
    20a2:	mov    r15,QWORD PTR [rsp+0xc0]
    20aa:	add    rsp,0xd0
    20b1:	mov    rsp,rbp
    20b4:	pop    rbp
    20b5:	ret
    20b6:	mov    rbx,QWORD PTR [rsp+0x98]
    20be:	mov    QWORD PTR [rsp+0x58],0x3
    20c7:	mov    rsi,QWORD PTR [rsp+0x90]
    20cf:	test   rsi,0x1
    20d6:	je     2108 <botlish_fn_22+0x470>
    20dc:	mov    rsi,QWORD PTR [rsp+0x90]
    20e4:	mov    rcx,rsi
    20e7:	add    rcx,0x2
    20eb:	seto   al
    20ee:	test   al,al
    20f0:	jne    2108 <botlish_fn_22+0x470>
    20f6:	mov    rsi,QWORD PTR [rsp+0x70]
    20fb:	mov    QWORD PTR [rsp+0x90],rcx
    2103:	jmp    212c <botlish_fn_22+0x494>
    2108:	mov    edx,0x3
    210d:	mov    rsi,QWORD PTR [rsp+0x90]
    2115:	mov    rdi,QWORD PTR [rsp+0x68]
    211a:	call   211f <botlish_fn_22+0x487>
			211b: R_X86_64_PLT32	rt_int_add-0x4
    211f:	mov    rsi,QWORD PTR [rsp+0x70]
    2124:	mov    QWORD PTR [rsp+0x90],rax
    212c:	mov    rsi,QWORD PTR [rsp+0x70]
    2131:	mov    QWORD PTR [rsp+0x10],rsi
    2136:	mov    rsi,QWORD PTR [rsp+0x78]
    213b:	mov    QWORD PTR [rsp+0x18],rsi
    2140:	mov    rsi,QWORD PTR [rsp+0x80]
    2148:	mov    QWORD PTR [rsp+0x20],rsi
    214d:	mov    rsi,QWORD PTR [rsp+0x90]
    2155:	mov    QWORD PTR [rsp+0x28],rsi
    215a:	mov    r9,QWORD PTR [rsp+0x88]
    2162:	mov    QWORD PTR [rsp+0x30],r9
    2167:	mov    QWORD PTR [rsp+0x38],r13
    216c:	mov    QWORD PTR [rsp+0x40],r14
    2171:	mov    QWORD PTR [rsp+0x48],r15
    2176:	mov    QWORD PTR [rsp+0x50],r12
    217b:	mov    QWORD PTR [rsp+0x98],rbx
    2183:	mov    rbx,QWORD PTR [rsp+0x88]
    218b:	jmp    1d65 <botlish_fn_22+0xcd>
    2190:	mov    rbx,QWORD PTR [rsp+0x98]
    2198:	mov    rdi,QWORD PTR [rsp+0x68]
    219d:	mov    QWORD PTR [rdi],rbx
    21a0:	mov    eax,0xa
    21a5:	mov    rbx,QWORD PTR [rsp+0xa0]
    21ad:	mov    r12,QWORD PTR [rsp+0xa8]
    21b5:	mov    r13,QWORD PTR [rsp+0xb0]
    21bd:	mov    r14,QWORD PTR [rsp+0xb8]
    21c5:	mov    r15,QWORD PTR [rsp+0xc0]
    21cd:	add    rsp,0xd0
    21d4:	mov    rsp,rbp
    21d7:	pop    rbp
    21d8:	ret
    21d9:	mov    QWORD PTR [rsp+0x68],rdi
    21de:	call   21e3 <botlish_fn_22+0x54b>
			21df: R_X86_64_PLT32	rt_stack_overflow-0x4
    21e3:	xor    rax,rax
    21e6:	mov    rbx,QWORD PTR [rsp+0xa0]
    21ee:	mov    r12,QWORD PTR [rsp+0xa8]
    21f6:	mov    r13,QWORD PTR [rsp+0xb0]
    21fe:	mov    r14,QWORD PTR [rsp+0xb8]
    2206:	mov    r15,QWORD PTR [rsp+0xc0]
    220e:	add    rsp,0xd0
    2215:	mov    rsp,rbp
    2218:	pop    rbp
    2219:	ret
    221a:	add    BYTE PTR [rax],al
    221c:	add    BYTE PTR [rax],al
    221e:	add    BYTE PTR [rax],al
    2220:	(bad)
    2221:	add    BYTE PTR [rax],al
    2223:	add    BYTE PTR [rax],al
    2225:	add    BYTE PTR [rax],al
	...

0000000000002228 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2228:	push   rbp
    2229:	mov    rbp,rsp
    222c:	sub    rsp,0x30
    2230:	mov    QWORD PTR [rsp+0x20],r12
    2235:	mov    rsi,QWORD PTR [rdx]
    2238:	mov    rax,QWORD PTR [rdx+0x8]
    223c:	mov    rcx,QWORD PTR [rdx+0x10]
    2240:	mov    r8,QWORD PTR [rdx+0x18]
    2244:	mov    r9,QWORD PTR [rdx+0x20]
    2248:	mov    r10,QWORD PTR [rdx+0x28]
    224c:	mov    r11,QWORD PTR [rdx+0x30]
    2250:	mov    r12,QWORD PTR [rdx+0x38]
    2254:	mov    rdx,QWORD PTR [rdx+0x40]
    2258:	mov    QWORD PTR [rsp],r10
    225c:	mov    QWORD PTR [rsp+0x8],r11
    2261:	mov    QWORD PTR [rsp+0x10],r12
    2266:	mov    QWORD PTR [rsp+0x18],rdx
    226b:	mov    rdx,rax
    226e:	call   2273 <botlish_entry_22+0x4b>
			226f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    2273:	mov    r12,QWORD PTR [rsp+0x20]
    2278:	add    rsp,0x30
    227c:	mov    rsp,rbp
    227f:	pop    rbp
    2280:	ret

0000000000002281 <botlish_fn_23: ht_rehash<mutarray, int>>:
    2281:	push   rbp
    2282:	mov    rbp,rsp
    2285:	sub    rsp,0xd0
    228c:	mov    QWORD PTR [rsp+0xa0],rbx
    2294:	mov    QWORD PTR [rsp+0xa8],r12
    229c:	mov    QWORD PTR [rsp+0xb0],r13
    22a4:	mov    QWORD PTR [rsp+0xb8],r14
    22ac:	mov    QWORD PTR [rsp+0xc0],r15
    22b4:	mov    r12,QWORD PTR [rdi]
    22b7:	mov    rax,QWORD PTR [rdi+0x8]
    22bb:	lea    rcx,[r12+0x8]
    22c0:	cmp    rcx,rax
    22c3:	ja     25fa <botlish_fn_23+0x379>
    22c9:	lea    rax,[r12+0x8]
    22ce:	mov    QWORD PTR [rdi],rax
    22d1:	mov    r13,rdi
    22d4:	mov    QWORD PTR [r12],0x0
    22dc:	mov    QWORD PTR [rsp+0x30],0x0
    22e5:	mov    QWORD PTR [rsp+0x38],0x0
    22ee:	mov    QWORD PTR [rsp+0x40],0x0
    22f7:	mov    QWORD PTR [rsp+0x48],0x0
    2300:	mov    QWORD PTR [rsp+0x50],0x0
    2309:	mov    QWORD PTR [rsp+0x58],0x0
    2312:	mov    QWORD PTR [rsp+0x60],0x0
    231b:	mov    QWORD PTR [rsp+0x68],0x0
    2324:	mov    QWORD PTR [rsp+0x20],rsi
    2329:	mov    r14,rsi
    232c:	mov    QWORD PTR [rsp+0x28],rdx
    2331:	mov    rbx,rdx
    2334:	mov    rsi,r14
    2337:	mov    rdi,r13
    233a:	call   233f <botlish_fn_23+0xbe>
			233b: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    233f:	test   rax,rax
    2342:	jne    2350 <botlish_fn_23+0xcf>
    2348:	mov    rdi,r13
    234b:	jmp    257e <botlish_fn_23+0x2fd>
    2350:	mov    QWORD PTR [rsp+0x30],rax
    2355:	mov    r15,rax
    2358:	mov    rsi,r14
    235b:	mov    rdi,r13
    235e:	call   2363 <botlish_fn_23+0xe2>
			235f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2363:	test   rax,rax
    2366:	jne    2374 <botlish_fn_23+0xf3>
    236c:	mov    rdi,r13
    236f:	jmp    257e <botlish_fn_23+0x2fd>
    2374:	mov    QWORD PTR [rsp+0x38],rax
    2379:	mov    QWORD PTR [rsp+0x98],rax
    2381:	mov    rsi,r14
    2384:	mov    rdi,r13
    2387:	call   238c <botlish_fn_23+0x10b>
			2388: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    238c:	test   rax,rax
    238f:	jne    239d <botlish_fn_23+0x11c>
    2395:	mov    rdi,r13
    2398:	jmp    257e <botlish_fn_23+0x2fd>
    239d:	mov    QWORD PTR [rsp+0x40],rax
    23a2:	mov    QWORD PTR [rsp+0x90],rax
    23aa:	mov    rsi,r14
    23ad:	mov    rdi,r13
    23b0:	call   23b5 <botlish_fn_23+0x134>
			23b1: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    23b5:	test   rax,rax
    23b8:	jne    23c6 <botlish_fn_23+0x145>
    23be:	mov    rdi,r13
    23c1:	jmp    257e <botlish_fn_23+0x2fd>
    23c6:	mov    QWORD PTR [rsp+0x48],rax
    23cb:	mov    QWORD PTR [rsp+0x88],rax
    23d3:	mov    rsi,rbx
    23d6:	mov    rdi,r13
    23d9:	call   23de <botlish_fn_23+0x15d>
			23da: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    23de:	mov    rcx,rax
    23e1:	mov    QWORD PTR [rsp+0x80],rax
    23e9:	test   rax,rcx
    23ec:	jne    23fa <botlish_fn_23+0x179>
    23f2:	mov    rdi,r13
    23f5:	jmp    257e <botlish_fn_23+0x2fd>
    23fa:	mov    rax,QWORD PTR [rsp+0x80]
    2402:	mov    QWORD PTR [rsp+0x50],rax
    2407:	mov    edx,0x1
    240c:	mov    QWORD PTR [rsp+0x58],0x1
    2415:	mov    rcx,rbx
    2418:	mov    rsi,QWORD PTR [rsp+0x80]
    2420:	mov    rdi,r13
    2423:	call   2428 <botlish_fn_23+0x1a7>
			2424: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    2428:	test   rax,rax
    242b:	jne    2439 <botlish_fn_23+0x1b8>
    2431:	mov    rdi,r13
    2434:	jmp    257e <botlish_fn_23+0x2fd>
    2439:	mov    rsi,rbx
    243c:	mov    rdi,r13
    243f:	call   2444 <botlish_fn_23+0x1c3>
			2440: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2444:	test   rax,rax
    2447:	jne    2455 <botlish_fn_23+0x1d4>
    244d:	mov    rdi,r13
    2450:	jmp    257e <botlish_fn_23+0x2fd>
    2455:	mov    QWORD PTR [rsp+0x58],rax
    245a:	mov    QWORD PTR [rsp+0x78],rax
    245f:	mov    rsi,rbx
    2462:	mov    rdi,r13
    2465:	call   246a <botlish_fn_23+0x1e9>
			2466: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    246a:	test   rax,rax
    246d:	jne    247b <botlish_fn_23+0x1fa>
    2473:	mov    rdi,r13
    2476:	jmp    257e <botlish_fn_23+0x2fd>
    247b:	mov    QWORD PTR [rsp+0x60],rax
    2480:	mov    r8d,0x1
    2486:	mov    QWORD PTR [rsp+0x68],0x1
    248f:	mov    rcx,QWORD PTR [rsp+0x80]
    2497:	mov    QWORD PTR [rsp],rcx
    249b:	mov    rcx,QWORD PTR [rsp+0x78]
    24a0:	mov    QWORD PTR [rsp+0x8],rcx
    24a5:	mov    QWORD PTR [rsp+0x10],rax
    24aa:	mov    QWORD PTR [rsp+0x70],rax
    24af:	mov    QWORD PTR [rsp+0x18],rbx
    24b4:	mov    rcx,QWORD PTR [rsp+0x90]
    24bc:	mov    rdx,QWORD PTR [rsp+0x98]
    24c4:	mov    rsi,r15
    24c7:	mov    r9,QWORD PTR [rsp+0x88]
    24cf:	mov    rdi,r13
    24d2:	call   24d7 <botlish_fn_23+0x256>
			24d3: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    24d7:	test   rax,rax
    24da:	jne    24e8 <botlish_fn_23+0x267>
    24e0:	mov    rdi,r13
    24e3:	jmp    257e <botlish_fn_23+0x2fd>
    24e8:	mov    edx,0x1
    24ed:	mov    rcx,QWORD PTR [rsp+0x80]
    24f5:	mov    rsi,r14
    24f8:	mov    rdi,r13
    24fb:	call   2500 <botlish_fn_23+0x27f>
			24fc: R_X86_64_PLT32	rt_mutarray_set-0x4
    2500:	test   rax,rax
    2503:	jne    2511 <botlish_fn_23+0x290>
    2509:	mov    rdi,r13
    250c:	jmp    257e <botlish_fn_23+0x2fd>
    2511:	mov    edx,0x3
    2516:	mov    rcx,QWORD PTR [rsp+0x78]
    251b:	mov    rsi,r14
    251e:	mov    rdi,r13
    2521:	call   2526 <botlish_fn_23+0x2a5>
			2522: R_X86_64_PLT32	rt_mutarray_set-0x4
    2526:	test   rax,rax
    2529:	jne    2537 <botlish_fn_23+0x2b6>
    252f:	mov    rdi,r13
    2532:	jmp    257e <botlish_fn_23+0x2fd>
    2537:	mov    edx,0x5
    253c:	mov    rcx,QWORD PTR [rsp+0x70]
    2541:	mov    rsi,r14
    2544:	mov    rdi,r13
    2547:	call   254c <botlish_fn_23+0x2cb>
			2548: R_X86_64_PLT32	rt_mutarray_set-0x4
    254c:	test   rax,rax
    254f:	jne    255d <botlish_fn_23+0x2dc>
    2555:	mov    rdi,r13
    2558:	jmp    257e <botlish_fn_23+0x2fd>
    255d:	mov    edx,0x9
    2562:	mov    ecx,0x1
    2567:	mov    rsi,r14
    256a:	mov    rdi,r13
    256d:	call   2572 <botlish_fn_23+0x2f1>
			256e: R_X86_64_PLT32	rt_mutarray_set-0x4
    2572:	test   rax,rax
    2575:	jne    25bb <botlish_fn_23+0x33a>
    257b:	mov    rdi,r13
    257e:	mov    rdi,r13
    2581:	mov    QWORD PTR [rdi],r12
    2584:	xor    rax,rax
    2587:	mov    rbx,QWORD PTR [rsp+0xa0]
    258f:	mov    r12,QWORD PTR [rsp+0xa8]
    2597:	mov    r13,QWORD PTR [rsp+0xb0]
    259f:	mov    r14,QWORD PTR [rsp+0xb8]
    25a7:	mov    r15,QWORD PTR [rsp+0xc0]
    25af:	add    rsp,0xd0
    25b6:	mov    rsp,rbp
    25b9:	pop    rbp
    25ba:	ret
    25bb:	mov    rdi,r13
    25be:	mov    QWORD PTR [rdi],r12
    25c1:	mov    eax,0xa
    25c6:	mov    rbx,QWORD PTR [rsp+0xa0]
    25ce:	mov    r12,QWORD PTR [rsp+0xa8]
    25d6:	mov    r13,QWORD PTR [rsp+0xb0]
    25de:	mov    r14,QWORD PTR [rsp+0xb8]
    25e6:	mov    r15,QWORD PTR [rsp+0xc0]
    25ee:	add    rsp,0xd0
    25f5:	mov    rsp,rbp
    25f8:	pop    rbp
    25f9:	ret
    25fa:	mov    r13,rdi
    25fd:	call   2602 <botlish_fn_23+0x381>
			25fe: R_X86_64_PLT32	rt_stack_overflow-0x4
    2602:	xor    rax,rax
    2605:	mov    rbx,QWORD PTR [rsp+0xa0]
    260d:	mov    r12,QWORD PTR [rsp+0xa8]
    2615:	mov    r13,QWORD PTR [rsp+0xb0]
    261d:	mov    r14,QWORD PTR [rsp+0xb8]
    2625:	mov    r15,QWORD PTR [rsp+0xc0]
    262d:	add    rsp,0xd0
    2634:	mov    rsp,rbp
    2637:	pop    rbp
    2638:	ret

0000000000002639 <botlish_entry_23: ht_rehash<mutarray, int>>:
    2639:	push   rbp
    263a:	mov    rbp,rsp
    263d:	mov    rsi,QWORD PTR [rdx]
    2640:	mov    rdx,QWORD PTR [rdx+0x8]
    2644:	call   2649 <botlish_entry_23+0x10>
			2645: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2649:	mov    rsp,rbp
    264c:	pop    rbp
    264d:	ret
	...

0000000000002650 <botlish_fn_24: ht_should_grow<mutarray>>:
    2650:	push   rbp
    2651:	mov    rbp,rsp
    2654:	sub    rsp,0x40
    2658:	mov    QWORD PTR [rsp+0x20],rbx
    265d:	mov    QWORD PTR [rsp+0x28],r12
    2662:	mov    QWORD PTR [rsp+0x30],r13
    2667:	mov    QWORD PTR [rsp+0x38],r14
    266c:	mov    r12,QWORD PTR [rdi]
    266f:	mov    r8,QWORD PTR [rdi+0x8]
    2673:	lea    r9,[r12+0x8]
    2678:	cmp    r9,r8
    267b:	ja     29b6 <botlish_fn_24+0x366>
    2681:	lea    r9,[r12+0x8]
    2686:	mov    QWORD PTR [rdi],r9
    2689:	mov    r13,rdi
    268c:	mov    QWORD PTR [r12],0x0
    2694:	mov    QWORD PTR [rsp+0x8],0x0
    269d:	mov    QWORD PTR [rsp+0x10],0x0
    26a6:	mov    QWORD PTR [rsp],rsi
    26aa:	mov    rbx,rsi
    26ad:	mov    rsi,rbx
    26b0:	mov    rdi,r13
    26b3:	call   26b8 <botlish_fn_24+0x68>
			26b4: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    26b8:	mov    rcx,rax
    26bb:	mov    r14,rax
    26be:	test   rax,rcx
    26c1:	jne    26cf <botlish_fn_24+0x7f>
    26c7:	mov    rdi,r13
    26ca:	jmp    28cc <botlish_fn_24+0x27c>
    26cf:	mov    rax,r14
    26d2:	mov    QWORD PTR [rsp+0x8],rax
    26d7:	mov    rsi,rbx
    26da:	mov    rdi,r13
    26dd:	call   26e2 <botlish_fn_24+0x92>
			26de: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    26e2:	mov    rcx,rax
    26e5:	test   rcx,rcx
    26e8:	jne    26f6 <botlish_fn_24+0xa6>
    26ee:	mov    rdi,r13
    26f1:	jmp    28cc <botlish_fn_24+0x27c>
    26f6:	mov    QWORD PTR [rsp+0x10],rcx
    26fb:	mov    edx,0x1
    2700:	mov    rax,r14
    2703:	test   rax,0x1
    2709:	jne    272c <botlish_fn_24+0xdc>
    270f:	xor    edx,edx
    2711:	mov    rax,r14
    2714:	test   rax,0x7
    271a:	jne    272c <botlish_fn_24+0xdc>
    2720:	mov    rax,r14
    2723:	movzx  rax,BYTE PTR [rax]
    2727:	cmp    al,0x1
    2729:	sete   dl
    272c:	test   dl,dl
    272e:	jne    2752 <botlish_fn_24+0x102>
    2734:	mov    rdi,r13
    2737:	mov    rax,QWORD PTR [rdi+0x10]
    273b:	mov    rcx,QWORD PTR [rax+0x10]
    273f:	xor    rdx,rdx
    2742:	mov    rsi,r14
    2745:	call   274a <botlish_fn_24+0xfa>
			2746: R_X86_64_PLT32	rt_type_error-0x4
    274a:	mov    rdi,r13
    274d:	jmp    28cc <botlish_fn_24+0x27c>
    2752:	mov    eax,0x1
    2757:	test   rcx,0x1
    275e:	je     276c <botlish_fn_24+0x11c>
    2764:	mov    r8,rcx
    2767:	jmp    278f <botlish_fn_24+0x13f>
    276c:	xor    eax,eax
    276e:	test   rcx,0x7
    2775:	je     2783 <botlish_fn_24+0x133>
    277b:	mov    r8,rcx
    277e:	jmp    278f <botlish_fn_24+0x13f>
    2783:	movzx  rax,BYTE PTR [rcx]
    2787:	mov    r8,rcx
    278a:	cmp    al,0x1
    278c:	sete   al
    278f:	test   al,al
    2791:	jne    27b5 <botlish_fn_24+0x165>
    2797:	mov    rdi,r13
    279a:	mov    rax,QWORD PTR [rdi+0x10]
    279e:	mov    rcx,QWORD PTR [rax+0x10]
    27a2:	xor    rdx,rdx
    27a5:	mov    rsi,r8
    27a8:	call   27ad <botlish_fn_24+0x15d>
			27a9: R_X86_64_PLT32	rt_type_error-0x4
    27ad:	mov    rdi,r13
    27b0:	jmp    28cc <botlish_fn_24+0x27c>
    27b5:	mov    rcx,r8
    27b8:	mov    rsi,r14
    27bb:	mov    rax,rsi
    27be:	and    rax,rcx
    27c1:	test   rax,0x1
    27c7:	jne    27d8 <botlish_fn_24+0x188>
    27cd:	mov    rdx,r8
    27d0:	mov    rsi,r14
    27d3:	jmp    27f6 <botlish_fn_24+0x1a6>
    27d8:	mov    rcx,r8
    27db:	lea    rax,[rcx-0x1]
    27df:	mov    rsi,r14
    27e2:	add    rsi,rax
    27e5:	seto   al
    27e8:	test   al,al
    27ea:	je     2801 <botlish_fn_24+0x1b1>
    27f0:	mov    rdx,r8
    27f3:	mov    rsi,r14
    27f6:	mov    rdi,r13
    27f9:	call   27fe <botlish_fn_24+0x1ae>
			27fa: R_X86_64_PLT32	rt_int_add-0x4
    27fe:	mov    rsi,rax
    2801:	mov    QWORD PTR [rsp+0x8],rsi
    2806:	mov    QWORD PTR [rsp+0x10],0x3
    280f:	test   rsi,0x1
    2816:	je     2839 <botlish_fn_24+0x1e9>
    281c:	mov    rax,rsi
    281f:	add    rax,0x2
    2823:	mov    rcx,rax
    2826:	seto   al
    2829:	test   al,al
    282b:	jne    2839 <botlish_fn_24+0x1e9>
    2831:	mov    rsi,rcx
    2834:	jmp    2849 <botlish_fn_24+0x1f9>
    2839:	mov    edx,0x3
    283e:	mov    rdi,r13
    2841:	call   2846 <botlish_fn_24+0x1f6>
			2842: R_X86_64_PLT32	rt_int_add-0x4
    2846:	mov    rsi,rax
    2849:	mov    QWORD PTR [rsp+0x8],rsi
    284e:	mov    edx,0x7
    2853:	mov    rcx,rdx
    2856:	mov    QWORD PTR [rsp+0x10],0x7
    285f:	test   rsi,0x1
    2866:	jne    2874 <botlish_fn_24+0x224>
    286c:	mov    rdx,rcx
    286f:	jmp    28a2 <botlish_fn_24+0x252>
    2874:	mov    rax,rsi
    2877:	sar    rax,1
    287a:	imul   QWORD PTR [rip+0x15f]        # 29e0 <botlish_fn_24+0x390>
    2881:	seto   dil
    2885:	or     rax,0x1
    2889:	test   dil,dil
    288c:	je     289a <botlish_fn_24+0x24a>
    2892:	mov    rdx,rcx
    2895:	jmp    28a2 <botlish_fn_24+0x252>
    289a:	mov    rsi,rax
    289d:	jmp    28ad <botlish_fn_24+0x25d>
    28a2:	mov    rdi,r13
    28a5:	call   28aa <botlish_fn_24+0x25a>
			28a6: R_X86_64_PLT32	rt_int_mul-0x4
    28aa:	mov    rsi,rax
    28ad:	mov    QWORD PTR [rsp+0x8],rsi
    28b2:	mov    r14,rsi
    28b5:	mov    rsi,rbx
    28b8:	mov    rdi,r13
    28bb:	call   28c0 <botlish_fn_24+0x270>
			28bc: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    28c0:	test   rax,rax
    28c3:	jne    28f2 <botlish_fn_24+0x2a2>
    28c9:	mov    rdi,r13
    28cc:	mov    rdi,r13
    28cf:	mov    QWORD PTR [rdi],r12
    28d2:	xor    rax,rax
    28d5:	mov    rbx,QWORD PTR [rsp+0x20]
    28da:	mov    r12,QWORD PTR [rsp+0x28]
    28df:	mov    r13,QWORD PTR [rsp+0x30]
    28e4:	mov    r14,QWORD PTR [rsp+0x38]
    28e9:	add    rsp,0x40
    28ed:	mov    rsp,rbp
    28f0:	pop    rbp
    28f1:	ret
    28f2:	mov    QWORD PTR [rsp],rax
    28f6:	mov    QWORD PTR [rsp+0x10],0x5
    28ff:	test   rax,0x1
    2905:	mov    rsi,rax
    2908:	je     2938 <botlish_fn_24+0x2e8>
    290e:	mov    rcx,rsi
    2911:	mov    rax,rcx
    2914:	sar    rax,1
    2917:	imul   QWORD PTR [rip+0xca]        # 29e8 <botlish_fn_24+0x398>
    291e:	seto   cl
    2921:	or     rax,0x1
    2925:	test   cl,cl
    2927:	jne    2938 <botlish_fn_24+0x2e8>
    292d:	mov    rdx,rax
    2930:	mov    rsi,r14
    2933:	jmp    294b <botlish_fn_24+0x2fb>
    2938:	mov    edx,0x5
    293d:	mov    rdi,r13
    2940:	call   2945 <botlish_fn_24+0x2f5>
			2941: R_X86_64_PLT32	rt_int_mul-0x4
    2945:	mov    rdx,rax
    2948:	mov    rsi,r14
    294b:	mov    rax,rsi
    294e:	and    rax,rdx
    2951:	test   rax,0x1
    2957:	jne    2980 <botlish_fn_24+0x330>
    295d:	mov    rdi,r13
    2960:	call   2965 <botlish_fn_24+0x315>
			2961: R_X86_64_PLT32	rt_int_cmp-0x4
    2965:	mov    ecx,0x2
    296a:	test   rax,rax
    296d:	mov    rax,rcx
    2970:	cmovg  rax,QWORD PTR [rip+0x68]        # 29e0 <botlish_fn_24+0x390>
    2978:	mov    rdi,r13
    297b:	jmp    2993 <botlish_fn_24+0x343>
    2980:	mov    eax,0x2
    2985:	cmp    rsi,rdx
    2988:	cmovg  rax,QWORD PTR [rip+0x50]        # 29e0 <botlish_fn_24+0x390>
    2990:	mov    rdi,r13
    2993:	mov    rdi,r13
    2996:	mov    QWORD PTR [rdi],r12
    2999:	mov    rbx,QWORD PTR [rsp+0x20]
    299e:	mov    r12,QWORD PTR [rsp+0x28]
    29a3:	mov    r13,QWORD PTR [rsp+0x30]
    29a8:	mov    r14,QWORD PTR [rsp+0x38]
    29ad:	add    rsp,0x40
    29b1:	mov    rsp,rbp
    29b4:	pop    rbp
    29b5:	ret
    29b6:	mov    r13,rdi
    29b9:	call   29be <botlish_fn_24+0x36e>
			29ba: R_X86_64_PLT32	rt_stack_overflow-0x4
    29be:	xor    rax,rax
    29c1:	mov    rbx,QWORD PTR [rsp+0x20]
    29c6:	mov    r12,QWORD PTR [rsp+0x28]
    29cb:	mov    r13,QWORD PTR [rsp+0x30]
    29d0:	mov    r14,QWORD PTR [rsp+0x38]
    29d5:	add    rsp,0x40
    29d9:	mov    rsp,rbp
    29dc:	pop    rbp
    29dd:	ret
    29de:	add    BYTE PTR [rax],al
    29e0:	(bad)
    29e1:	add    BYTE PTR [rax],al
    29e3:	add    BYTE PTR [rax],al
    29e5:	add    BYTE PTR [rax],al
    29e7:	add    BYTE PTR [rax+rax*1],al
    29ea:	add    BYTE PTR [rax],al
    29ec:	add    BYTE PTR [rax],al
	...

00000000000029f0 <botlish_entry_24: ht_should_grow<mutarray>>:
    29f0:	push   rbp
    29f1:	mov    rbp,rsp
    29f4:	mov    rsi,QWORD PTR [rdx]
    29f7:	call   29fc <botlish_entry_24+0xc>
			29f8: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    29fc:	mov    rsp,rbp
    29ff:	pop    rbp
    2a00:	ret
    2a01:	add    BYTE PTR [rax],al
    2a03:	add    BYTE PTR [rax],al
    2a05:	add    BYTE PTR [rax],al
	...

0000000000002a08 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    2a08:	push   rbp
    2a09:	mov    rbp,rsp
    2a0c:	sub    rsp,0x40
    2a10:	mov    QWORD PTR [rsp+0x20],rbx
    2a15:	mov    QWORD PTR [rsp+0x28],r12
    2a1a:	mov    QWORD PTR [rsp+0x30],r13
    2a1f:	mov    QWORD PTR [rsp+0x38],r14
    2a24:	mov    rbx,QWORD PTR [rdi]
    2a27:	mov    rax,QWORD PTR [rdi+0x8]
    2a2b:	lea    rcx,[rbx+0x8]
    2a2f:	cmp    rcx,rax
    2a32:	ja     2ce5 <botlish_fn_25+0x2dd>
    2a38:	lea    rax,[rbx+0x8]
    2a3c:	mov    QWORD PTR [rdi],rax
    2a3f:	mov    r12,rdi
    2a42:	mov    QWORD PTR [rbx],0x0
    2a49:	mov    QWORD PTR [rsp+0x8],0x0
    2a52:	mov    QWORD PTR [rsp+0x10],0x0
    2a5b:	mov    QWORD PTR [rsp],rsi
    2a5f:	mov    r13,rsi
    2a62:	mov    rsi,r13
    2a65:	mov    rdi,r12
    2a68:	call   2a6d <botlish_fn_25+0x65>
			2a69: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2a6d:	test   rax,rax
    2a70:	jne    2a7e <botlish_fn_25+0x76>
    2a76:	mov    rdi,r12
    2a79:	jmp    2c99 <botlish_fn_25+0x291>
    2a7e:	mov    QWORD PTR [rsp+0x8],rax
    2a83:	mov    r14,rax
    2a86:	mov    rsi,r13
    2a89:	mov    rdi,r12
    2a8c:	call   2a91 <botlish_fn_25+0x89>
			2a8d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2a91:	mov    rcx,rax
    2a94:	test   rcx,rcx
    2a97:	jne    2aa5 <botlish_fn_25+0x9d>
    2a9d:	mov    rdi,r12
    2aa0:	jmp    2c99 <botlish_fn_25+0x291>
    2aa5:	mov    edx,0x1
    2aaa:	mov    rax,r14
    2aad:	test   rax,0x1
    2ab3:	je     2ac1 <botlish_fn_25+0xb9>
    2ab9:	mov    r14,rax
    2abc:	jmp    2ae5 <botlish_fn_25+0xdd>
    2ac1:	xor    edx,edx
    2ac3:	test   rax,0x7
    2ac9:	je     2ad7 <botlish_fn_25+0xcf>
    2acf:	mov    r14,rax
    2ad2:	jmp    2ae5 <botlish_fn_25+0xdd>
    2ad7:	movzx  rdx,BYTE PTR [rax]
    2adb:	mov    r14,rax
    2ade:	rex cmp dl,0x1
    2ae2:	sete   dl
    2ae5:	test   dl,dl
    2ae7:	jne    2b0b <botlish_fn_25+0x103>
    2aed:	mov    rdi,r12
    2af0:	mov    rax,QWORD PTR [rdi+0x10]
    2af4:	mov    rcx,QWORD PTR [rax+0x18]
    2af8:	xor    rdx,rdx
    2afb:	mov    rsi,r14
    2afe:	call   2b03 <botlish_fn_25+0xfb>
			2aff: R_X86_64_PLT32	rt_type_error-0x4
    2b03:	mov    rdi,r12
    2b06:	jmp    2c99 <botlish_fn_25+0x291>
    2b0b:	mov    rsi,r14
    2b0e:	mov    eax,0x1
    2b13:	test   rcx,0x1
    2b1a:	je     2b28 <botlish_fn_25+0x120>
    2b20:	mov    r8,rcx
    2b23:	jmp    2b4b <botlish_fn_25+0x143>
    2b28:	xor    eax,eax
    2b2a:	test   rcx,0x7
    2b31:	je     2b3f <botlish_fn_25+0x137>
    2b37:	mov    r8,rcx
    2b3a:	jmp    2b4b <botlish_fn_25+0x143>
    2b3f:	movzx  rax,BYTE PTR [rcx]
    2b43:	mov    r8,rcx
    2b46:	cmp    al,0x1
    2b48:	sete   al
    2b4b:	test   al,al
    2b4d:	jne    2b71 <botlish_fn_25+0x169>
    2b53:	mov    rdi,r12
    2b56:	mov    rax,QWORD PTR [rdi+0x10]
    2b5a:	mov    rcx,QWORD PTR [rax+0x18]
    2b5e:	xor    rdx,rdx
    2b61:	mov    rsi,r8
    2b64:	call   2b69 <botlish_fn_25+0x161>
			2b65: R_X86_64_PLT32	rt_type_error-0x4
    2b69:	mov    rdi,r12
    2b6c:	jmp    2c99 <botlish_fn_25+0x291>
    2b71:	mov    rcx,r8
    2b74:	mov    rax,rsi
    2b77:	and    rax,rcx
    2b7a:	test   rax,0x1
    2b80:	jne    2ba7 <botlish_fn_25+0x19f>
    2b86:	mov    rdx,r8
    2b89:	mov    rdi,r12
    2b8c:	call   2b91 <botlish_fn_25+0x189>
			2b8d: R_X86_64_PLT32	rt_int_cmp-0x4
    2b91:	mov    r9d,0x2
    2b97:	test   rax,rax
    2b9a:	cmovg  r9,QWORD PTR [rip+0x16e]        # 2d10 <botlish_fn_25+0x308>
    2ba2:	jmp    2bbb <botlish_fn_25+0x1b3>
    2ba7:	mov    r9d,0x2
    2bad:	mov    rcx,r8
    2bb0:	cmp    rsi,rcx
    2bb3:	cmovg  r9,QWORD PTR [rip+0x155]        # 2d10 <botlish_fn_25+0x308>
    2bbb:	cmp    r9,0x6
    2bbf:	je     2c5e <botlish_fn_25+0x256>
    2bc5:	mov    rsi,r13
    2bc8:	mov    rdi,r12
    2bcb:	call   2bd0 <botlish_fn_25+0x1c8>
			2bcc: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2bd0:	test   rax,rax
    2bd3:	jne    2be1 <botlish_fn_25+0x1d9>
    2bd9:	mov    rdi,r12
    2bdc:	jmp    2c99 <botlish_fn_25+0x291>
    2be1:	mov    QWORD PTR [rsp+0x8],rax
    2be6:	mov    QWORD PTR [rsp+0x10],0x5
    2bef:	test   rax,0x1
    2bf5:	mov    rsi,rax
    2bf8:	je     2c25 <botlish_fn_25+0x21d>
    2bfe:	mov    rcx,rsi
    2c01:	mov    rax,rcx
    2c04:	sar    rax,1
    2c07:	imul   QWORD PTR [rip+0x10a]        # 2d18 <botlish_fn_25+0x310>
    2c0e:	seto   cl
    2c11:	or     rax,0x1
    2c15:	test   cl,cl
    2c17:	jne    2c25 <botlish_fn_25+0x21d>
    2c1d:	mov    rdx,rax
    2c20:	jmp    2c35 <botlish_fn_25+0x22d>
    2c25:	mov    edx,0x5
    2c2a:	mov    rdi,r12
    2c2d:	call   2c32 <botlish_fn_25+0x22a>
			2c2e: R_X86_64_PLT32	rt_int_mul-0x4
    2c32:	mov    rdx,rax
    2c35:	mov    QWORD PTR [rsp+0x8],rdx
    2c3a:	mov    rsi,r13
    2c3d:	mov    rdi,r12
    2c40:	call   2c45 <botlish_fn_25+0x23d>
			2c41: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2c45:	test   rax,rax
    2c48:	jne    2c56 <botlish_fn_25+0x24e>
    2c4e:	mov    rdi,r12
    2c51:	jmp    2c99 <botlish_fn_25+0x291>
    2c56:	mov    rdi,r12
    2c59:	jmp    2cc2 <botlish_fn_25+0x2ba>
    2c5e:	mov    rsi,r13
    2c61:	mov    rdi,r12
    2c64:	call   2c69 <botlish_fn_25+0x261>
			2c65: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2c69:	test   rax,rax
    2c6c:	jne    2c7a <botlish_fn_25+0x272>
    2c72:	mov    rdi,r12
    2c75:	jmp    2c99 <botlish_fn_25+0x291>
    2c7a:	mov    QWORD PTR [rsp+0x8],rax
    2c7f:	mov    rdx,rax
    2c82:	mov    rsi,r13
    2c85:	mov    rdi,r12
    2c88:	call   2c8d <botlish_fn_25+0x285>
			2c89: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2c8d:	test   rax,rax
    2c90:	jne    2cbf <botlish_fn_25+0x2b7>
    2c96:	mov    rdi,r12
    2c99:	mov    rdi,r12
    2c9c:	mov    QWORD PTR [rdi],rbx
    2c9f:	xor    rax,rax
    2ca2:	mov    rbx,QWORD PTR [rsp+0x20]
    2ca7:	mov    r12,QWORD PTR [rsp+0x28]
    2cac:	mov    r13,QWORD PTR [rsp+0x30]
    2cb1:	mov    r14,QWORD PTR [rsp+0x38]
    2cb6:	add    rsp,0x40
    2cba:	mov    rsp,rbp
    2cbd:	pop    rbp
    2cbe:	ret
    2cbf:	mov    rdi,r12
    2cc2:	mov    rdi,r12
    2cc5:	mov    QWORD PTR [rdi],rbx
    2cc8:	mov    rbx,QWORD PTR [rsp+0x20]
    2ccd:	mov    r12,QWORD PTR [rsp+0x28]
    2cd2:	mov    r13,QWORD PTR [rsp+0x30]
    2cd7:	mov    r14,QWORD PTR [rsp+0x38]
    2cdc:	add    rsp,0x40
    2ce0:	mov    rsp,rbp
    2ce3:	pop    rbp
    2ce4:	ret
    2ce5:	mov    r12,rdi
    2ce8:	call   2ced <botlish_fn_25+0x2e5>
			2ce9: R_X86_64_PLT32	rt_stack_overflow-0x4
    2ced:	xor    rax,rax
    2cf0:	mov    rbx,QWORD PTR [rsp+0x20]
    2cf5:	mov    r12,QWORD PTR [rsp+0x28]
    2cfa:	mov    r13,QWORD PTR [rsp+0x30]
    2cff:	mov    r14,QWORD PTR [rsp+0x38]
    2d04:	add    rsp,0x40
    2d08:	mov    rsp,rbp
    2d0b:	pop    rbp
    2d0c:	ret
    2d0d:	add    BYTE PTR [rax],al
    2d0f:	add    BYTE PTR [rsi],al
    2d11:	add    BYTE PTR [rax],al
    2d13:	add    BYTE PTR [rax],al
    2d15:	add    BYTE PTR [rax],al
    2d17:	add    BYTE PTR [rax+rax*1],al
    2d1a:	add    BYTE PTR [rax],al
    2d1c:	add    BYTE PTR [rax],al
	...

0000000000002d20 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    2d20:	push   rbp
    2d21:	mov    rbp,rsp
    2d24:	mov    rsi,QWORD PTR [rdx]
    2d27:	call   2d2c <botlish_entry_25+0xc>
			2d28: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    2d2c:	mov    rsp,rbp
    2d2f:	pop    rbp
    2d30:	ret
    2d31:	add    BYTE PTR [rax],al
    2d33:	add    BYTE PTR [rax],al
    2d35:	add    BYTE PTR [rax],al
	...

0000000000002d38 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    2d38:	push   rbp
    2d39:	mov    rbp,rsp
    2d3c:	sub    rsp,0x80
    2d43:	mov    QWORD PTR [rsp+0x50],rbx
    2d48:	mov    QWORD PTR [rsp+0x58],r12
    2d4d:	mov    QWORD PTR [rsp+0x60],r13
    2d52:	mov    QWORD PTR [rsp+0x68],r14
    2d57:	mov    QWORD PTR [rsp+0x70],r15
    2d5c:	mov    rbx,QWORD PTR [rdi]
    2d5f:	mov    rax,QWORD PTR [rdi+0x8]
    2d63:	lea    r9,[rbx+0x8]
    2d67:	cmp    r9,rax
    2d6a:	ja     3243 <botlish_fn_26+0x50b>
    2d70:	lea    rax,[rbx+0x8]
    2d74:	mov    QWORD PTR [rdi],rax
    2d77:	mov    r12,rdi
    2d7a:	mov    QWORD PTR [rbx],0x0
    2d81:	mov    QWORD PTR [rsp+0x20],0x0
    2d8a:	mov    QWORD PTR [rsp+0x28],0x0
    2d93:	mov    QWORD PTR [rsp],rsi
    2d97:	mov    r13,rsi
    2d9a:	mov    QWORD PTR [rsp+0x8],rdx
    2d9f:	mov    QWORD PTR [rsp+0x30],rdx
    2da4:	mov    QWORD PTR [rsp+0x10],rcx
    2da9:	mov    QWORD PTR [rsp+0x38],rcx
    2dae:	mov    QWORD PTR [rsp+0x18],r8
    2db3:	mov    r15,r8
    2db6:	mov    rsi,r13
    2db9:	mov    rdi,r12
    2dbc:	call   2dc1 <botlish_fn_26+0x89>
			2dbd: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    2dc1:	test   rax,rax
    2dc4:	jne    2dd2 <botlish_fn_26+0x9a>
    2dca:	mov    rdi,r12
    2dcd:	jmp    31e2 <botlish_fn_26+0x4aa>
    2dd2:	mov    QWORD PTR [rsp+0x20],rax
    2dd7:	xor    ecx,ecx
    2dd9:	test   rax,0x7
    2ddf:	je     2def <botlish_fn_26+0xb7>
    2de5:	mov    QWORD PTR [rsp+0x40],rax
    2dea:	jmp    2dff <botlish_fn_26+0xc7>
    2def:	movzx  rcx,BYTE PTR [rax]
    2df3:	mov    QWORD PTR [rsp+0x40],rax
    2df8:	rex cmp cl,0x8
    2dfc:	sete   cl
    2dff:	test   cl,cl
    2e01:	jne    2e29 <botlish_fn_26+0xf1>
    2e07:	mov    rdi,r12
    2e0a:	mov    rax,QWORD PTR [rdi+0x10]
    2e0e:	mov    rcx,QWORD PTR [rax+0x8]
    2e12:	mov    edx,0x8
    2e17:	mov    rsi,QWORD PTR [rsp+0x40]
    2e1c:	call   2e21 <botlish_fn_26+0xe9>
			2e1d: R_X86_64_PLT32	rt_type_error-0x4
    2e21:	mov    rdi,r12
    2e24:	jmp    31e2 <botlish_fn_26+0x4aa>
    2e29:	mov    rdx,QWORD PTR [rsp+0x30]
    2e2e:	mov    rsi,QWORD PTR [rsp+0x40]
    2e33:	mov    rdi,r12
    2e36:	call   2e3b <botlish_fn_26+0x103>
			2e37: R_X86_64_PLT32	rt_mutarray_get-0x4
    2e3b:	test   rax,rax
    2e3e:	jne    2e4c <botlish_fn_26+0x114>
    2e44:	mov    rdi,r12
    2e47:	jmp    31e2 <botlish_fn_26+0x4aa>
    2e4c:	mov    QWORD PTR [rsp+0x28],rax
    2e51:	mov    r14,rax
    2e54:	mov    rdi,r12
    2e57:	call   2e5c <botlish_fn_26+0x124>
			2e58: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    2e5c:	test   rax,rax
    2e5f:	mov    rcx,rax
    2e62:	jne    2e70 <botlish_fn_26+0x138>
    2e68:	mov    rdi,r12
    2e6b:	jmp    31e2 <botlish_fn_26+0x4aa>
    2e70:	mov    rsi,QWORD PTR [rsp+0x40]
    2e75:	mov    rdx,QWORD PTR [rsp+0x30]
    2e7a:	mov    rdi,r12
    2e7d:	call   2e82 <botlish_fn_26+0x14a>
			2e7e: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e82:	test   rax,rax
    2e85:	jne    2e93 <botlish_fn_26+0x15b>
    2e8b:	mov    rdi,r12
    2e8e:	jmp    31e2 <botlish_fn_26+0x4aa>
    2e93:	mov    rsi,r13
    2e96:	mov    rdi,r12
    2e99:	call   2e9e <botlish_fn_26+0x166>
			2e9a: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2e9e:	test   rax,rax
    2ea1:	jne    2eaf <botlish_fn_26+0x177>
    2ea7:	mov    rdi,r12
    2eaa:	jmp    31e2 <botlish_fn_26+0x4aa>
    2eaf:	xor    ecx,ecx
    2eb1:	test   rax,0x7
    2eb7:	je     2ec5 <botlish_fn_26+0x18d>
    2ebd:	mov    rsi,rax
    2ec0:	jmp    2ed3 <botlish_fn_26+0x19b>
    2ec5:	movzx  r8,BYTE PTR [rax]
    2ec9:	mov    rsi,rax
    2ecc:	cmp    r8b,0x8
    2ed0:	sete   cl
    2ed3:	test   cl,cl
    2ed5:	jne    2ef8 <botlish_fn_26+0x1c0>
    2edb:	mov    rdi,r12
    2ede:	mov    rax,QWORD PTR [rdi+0x10]
    2ee2:	mov    rcx,QWORD PTR [rax+0x20]
    2ee6:	mov    edx,0x8
    2eeb:	call   2ef0 <botlish_fn_26+0x1b8>
			2eec: R_X86_64_PLT32	rt_type_error-0x4
    2ef0:	mov    rdi,r12
    2ef3:	jmp    31e2 <botlish_fn_26+0x4aa>
    2ef8:	mov    rcx,QWORD PTR [rsp+0x38]
    2efd:	mov    rdx,QWORD PTR [rsp+0x30]
    2f02:	mov    rdi,r12
    2f05:	call   2f0a <botlish_fn_26+0x1d2>
			2f06: R_X86_64_PLT32	rt_mutarray_set-0x4
    2f0a:	test   rax,rax
    2f0d:	jne    2f1b <botlish_fn_26+0x1e3>
    2f13:	mov    rdi,r12
    2f16:	jmp    31e2 <botlish_fn_26+0x4aa>
    2f1b:	mov    rsi,r13
    2f1e:	mov    rdi,r12
    2f21:	call   2f26 <botlish_fn_26+0x1ee>
			2f22: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2f26:	test   rax,rax
    2f29:	jne    2f37 <botlish_fn_26+0x1ff>
    2f2f:	mov    rdi,r12
    2f32:	jmp    31e2 <botlish_fn_26+0x4aa>
    2f37:	xor    ecx,ecx
    2f39:	test   rax,0x7
    2f3f:	je     2f4d <botlish_fn_26+0x215>
    2f45:	mov    rsi,rax
    2f48:	jmp    2f5b <botlish_fn_26+0x223>
    2f4d:	movzx  rcx,BYTE PTR [rax]
    2f51:	mov    rsi,rax
    2f54:	rex cmp cl,0x8
    2f58:	sete   cl
    2f5b:	test   cl,cl
    2f5d:	jne    2f80 <botlish_fn_26+0x248>
    2f63:	mov    rdi,r12
    2f66:	mov    rax,QWORD PTR [rdi+0x10]
    2f6a:	mov    rcx,QWORD PTR [rax+0x20]
    2f6e:	mov    edx,0x8
    2f73:	call   2f78 <botlish_fn_26+0x240>
			2f74: R_X86_64_PLT32	rt_type_error-0x4
    2f78:	mov    rdi,r12
    2f7b:	jmp    31e2 <botlish_fn_26+0x4aa>
    2f80:	mov    rcx,r15
    2f83:	mov    rdx,QWORD PTR [rsp+0x30]
    2f88:	mov    rdi,r12
    2f8b:	call   2f90 <botlish_fn_26+0x258>
			2f8c: R_X86_64_PLT32	rt_mutarray_set-0x4
    2f90:	test   rax,rax
    2f93:	jne    2fa1 <botlish_fn_26+0x269>
    2f99:	mov    rdi,r12
    2f9c:	jmp    31e2 <botlish_fn_26+0x4aa>
    2fa1:	mov    QWORD PTR [rsp+0x8],0x7
    2faa:	mov    rsi,r13
    2fad:	mov    rdi,r12
    2fb0:	call   2fb5 <botlish_fn_26+0x27d>
			2fb1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2fb5:	test   rax,rax
    2fb8:	jne    2fc6 <botlish_fn_26+0x28e>
    2fbe:	mov    rdi,r12
    2fc1:	jmp    31e2 <botlish_fn_26+0x4aa>
    2fc6:	mov    QWORD PTR [rsp+0x10],rax
    2fcb:	mov    QWORD PTR [rsp+0x18],0x3
    2fd4:	mov    ecx,0x1
    2fd9:	test   rax,0x1
    2fdf:	je     2fed <botlish_fn_26+0x2b5>
    2fe5:	mov    rsi,rax
    2fe8:	jmp    3011 <botlish_fn_26+0x2d9>
    2fed:	xor    ecx,ecx
    2fef:	test   rax,0x7
    2ff5:	je     3003 <botlish_fn_26+0x2cb>
    2ffb:	mov    rsi,rax
    2ffe:	jmp    3011 <botlish_fn_26+0x2d9>
    3003:	movzx  rcx,BYTE PTR [rax]
    3007:	mov    rsi,rax
    300a:	rex cmp cl,0x1
    300e:	sete   cl
    3011:	test   cl,cl
    3013:	jne    3034 <botlish_fn_26+0x2fc>
    3019:	mov    rdi,r12
    301c:	mov    rax,QWORD PTR [rdi+0x10]
    3020:	mov    rcx,QWORD PTR [rax+0x10]
    3024:	xor    rdx,rdx
    3027:	call   302c <botlish_fn_26+0x2f4>
			3028: R_X86_64_PLT32	rt_type_error-0x4
    302c:	mov    rdi,r12
    302f:	jmp    31e2 <botlish_fn_26+0x4aa>
    3034:	test   rsi,0x1
    303b:	je     3053 <botlish_fn_26+0x31b>
    3041:	mov    rcx,rsi
    3044:	add    rcx,0x2
    3048:	seto   al
    304b:	test   al,al
    304d:	je     3063 <botlish_fn_26+0x32b>
    3053:	mov    edx,0x3
    3058:	mov    rdi,r12
    305b:	call   3060 <botlish_fn_26+0x328>
			305c: R_X86_64_PLT32	rt_int_add-0x4
    3060:	mov    rcx,rax
    3063:	mov    edx,0x7
    3068:	mov    rsi,r13
    306b:	mov    rdi,r12
    306e:	call   3073 <botlish_fn_26+0x33b>
			306f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3073:	test   rax,rax
    3076:	jne    3084 <botlish_fn_26+0x34c>
    307c:	mov    rdi,r12
    307f:	jmp    31e2 <botlish_fn_26+0x4aa>
    3084:	mov    rdi,r12
    3087:	call   308c <botlish_fn_26+0x354>
			3088: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    308c:	test   rax,rax
    308f:	jne    309d <botlish_fn_26+0x365>
    3095:	mov    rdi,r12
    3098:	jmp    31e2 <botlish_fn_26+0x4aa>
    309d:	mov    rcx,r14
    30a0:	mov    rdx,rcx
    30a3:	and    rdx,rax
    30a6:	mov    r8,rax
    30a9:	test   rdx,0x1
    30b0:	jne    30d5 <botlish_fn_26+0x39d>
    30b6:	mov    rdx,r8
    30b9:	mov    rsi,r14
    30bc:	mov    rdi,r12
    30bf:	call   30c4 <botlish_fn_26+0x38c>
			30c0: R_X86_64_PLT32	rt_value_eq-0x4
    30c4:	test   rax,rax
    30c7:	jne    30eb <botlish_fn_26+0x3b3>
    30cd:	mov    rdi,r12
    30d0:	jmp    31e2 <botlish_fn_26+0x4aa>
    30d5:	mov    rdx,r8
    30d8:	mov    rsi,r14
    30db:	mov    eax,0x2
    30e0:	cmp    rsi,rdx
    30e3:	cmove  rax,QWORD PTR [rip+0x18d]        # 3278 <botlish_fn_26+0x540>
    30eb:	cmp    rax,0x6
    30ef:	je     30fd <botlish_fn_26+0x3c5>
    30f5:	mov    rdi,r12
    30f8:	jmp    3213 <botlish_fn_26+0x4db>
    30fd:	mov    QWORD PTR [rsp+0x8],0x9
    3106:	mov    rsi,r13
    3109:	mov    rdi,r12
    310c:	call   3111 <botlish_fn_26+0x3d9>
			310d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3111:	test   rax,rax
    3114:	jne    3122 <botlish_fn_26+0x3ea>
    311a:	mov    rdi,r12
    311d:	jmp    31e2 <botlish_fn_26+0x4aa>
    3122:	mov    QWORD PTR [rsp+0x10],rax
    3127:	mov    QWORD PTR [rsp+0x18],0x3
    3130:	mov    ecx,0x1
    3135:	test   rax,0x1
    313b:	je     3149 <botlish_fn_26+0x411>
    3141:	mov    rsi,rax
    3144:	jmp    316d <botlish_fn_26+0x435>
    3149:	xor    ecx,ecx
    314b:	test   rax,0x7
    3151:	je     315f <botlish_fn_26+0x427>
    3157:	mov    rsi,rax
    315a:	jmp    316d <botlish_fn_26+0x435>
    315f:	movzx  rcx,BYTE PTR [rax]
    3163:	mov    rsi,rax
    3166:	rex cmp cl,0x1
    316a:	sete   cl
    316d:	test   cl,cl
    316f:	jne    3190 <botlish_fn_26+0x458>
    3175:	mov    rdi,r12
    3178:	mov    rax,QWORD PTR [rdi+0x10]
    317c:	mov    rcx,QWORD PTR [rax+0x28]
    3180:	xor    rdx,rdx
    3183:	call   3188 <botlish_fn_26+0x450>
			3184: R_X86_64_PLT32	rt_type_error-0x4
    3188:	mov    rdi,r12
    318b:	jmp    31e2 <botlish_fn_26+0x4aa>
    3190:	test   rsi,0x1
    3197:	je     31b6 <botlish_fn_26+0x47e>
    319d:	mov    rcx,rsi
    31a0:	sub    rcx,0x3
    31a4:	seto   al
    31a7:	add    rcx,0x1
    31ae:	test   al,al
    31b0:	je     31c6 <botlish_fn_26+0x48e>
    31b6:	mov    edx,0x3
    31bb:	mov    rdi,r12
    31be:	call   31c3 <botlish_fn_26+0x48b>
			31bf: R_X86_64_PLT32	rt_int_sub-0x4
    31c3:	mov    rcx,rax
    31c6:	mov    edx,0x9
    31cb:	mov    rsi,r13
    31ce:	mov    rdi,r12
    31d1:	call   31d6 <botlish_fn_26+0x49e>
			31d2: R_X86_64_PLT32	rt_mutarray_set-0x4
    31d6:	test   rax,rax
    31d9:	jne    3210 <botlish_fn_26+0x4d8>
    31df:	mov    rdi,r12
    31e2:	mov    rdi,r12
    31e5:	mov    QWORD PTR [rdi],rbx
    31e8:	xor    rax,rax
    31eb:	mov    rbx,QWORD PTR [rsp+0x50]
    31f0:	mov    r12,QWORD PTR [rsp+0x58]
    31f5:	mov    r13,QWORD PTR [rsp+0x60]
    31fa:	mov    r14,QWORD PTR [rsp+0x68]
    31ff:	mov    r15,QWORD PTR [rsp+0x70]
    3204:	add    rsp,0x80
    320b:	mov    rsp,rbp
    320e:	pop    rbp
    320f:	ret
    3210:	mov    rdi,r12
    3213:	mov    rdi,r12
    3216:	mov    QWORD PTR [rdi],rbx
    3219:	mov    eax,0xa
    321e:	mov    rbx,QWORD PTR [rsp+0x50]
    3223:	mov    r12,QWORD PTR [rsp+0x58]
    3228:	mov    r13,QWORD PTR [rsp+0x60]
    322d:	mov    r14,QWORD PTR [rsp+0x68]
    3232:	mov    r15,QWORD PTR [rsp+0x70]
    3237:	add    rsp,0x80
    323e:	mov    rsp,rbp
    3241:	pop    rbp
    3242:	ret
    3243:	mov    r12,rdi
    3246:	call   324b <botlish_fn_26+0x513>
			3247: R_X86_64_PLT32	rt_stack_overflow-0x4
    324b:	xor    rax,rax
    324e:	mov    rbx,QWORD PTR [rsp+0x50]
    3253:	mov    r12,QWORD PTR [rsp+0x58]
    3258:	mov    r13,QWORD PTR [rsp+0x60]
    325d:	mov    r14,QWORD PTR [rsp+0x68]
    3262:	mov    r15,QWORD PTR [rsp+0x70]
    3267:	add    rsp,0x80
    326e:	mov    rsp,rbp
    3271:	pop    rbp
    3272:	ret
    3273:	add    BYTE PTR [rax],al
    3275:	add    BYTE PTR [rax],al
    3277:	add    BYTE PTR [rsi],al
    3279:	add    BYTE PTR [rax],al
    327b:	add    BYTE PTR [rax],al
    327d:	add    BYTE PTR [rax],al
	...

0000000000003280 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    3280:	push   rbp
    3281:	mov    rbp,rsp
    3284:	mov    rsi,QWORD PTR [rdx]
    3287:	mov    r9,QWORD PTR [rdx+0x8]
    328b:	mov    rcx,QWORD PTR [rdx+0x10]
    328f:	mov    r8,QWORD PTR [rdx+0x18]
    3293:	mov    rdx,r9
    3296:	call   329b <botlish_entry_26+0x1b>
			3297: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    329b:	mov    rsp,rbp
    329e:	pop    rbp
    329f:	ret

00000000000032a0 <botlish_fn_27: ht_set<mutarray, str, str>>:
    32a0:	push   rbp
    32a1:	mov    rbp,rsp
    32a4:	sub    rsp,0x70
    32a8:	mov    QWORD PTR [rsp+0x40],rbx
    32ad:	mov    QWORD PTR [rsp+0x48],r12
    32b2:	mov    QWORD PTR [rsp+0x50],r13
    32b7:	mov    QWORD PTR [rsp+0x58],r14
    32bc:	mov    QWORD PTR [rsp+0x60],r15
    32c1:	mov    rbx,QWORD PTR [rdi]
    32c4:	mov    rax,QWORD PTR [rdi+0x8]
    32c8:	lea    r8,[rbx+0x8]
    32cc:	cmp    r8,rax
    32cf:	ja     368d <botlish_fn_27+0x3ed>
    32d5:	lea    rax,[rbx+0x8]
    32d9:	mov    QWORD PTR [rdi],rax
    32dc:	mov    r12,rdi
    32df:	mov    QWORD PTR [rbx],0x0
    32e6:	mov    QWORD PTR [rsp+0x18],0x0
    32ef:	mov    QWORD PTR [rsp+0x20],0x0
    32f8:	mov    QWORD PTR [rsp],rsi
    32fc:	mov    r15,rsi
    32ff:	mov    QWORD PTR [rsp+0x8],rdx
    3304:	mov    r14,rdx
    3307:	mov    QWORD PTR [rsp+0x10],rcx
    330c:	mov    r13,rcx
    330f:	mov    rdx,r14
    3312:	mov    rsi,r15
    3315:	mov    rdi,r12
    3318:	call   331d <botlish_fn_27+0x7d>
			3319: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    331d:	test   rax,rax
    3320:	jne    332e <botlish_fn_27+0x8e>
    3326:	mov    rdi,r12
    3329:	jmp    3635 <botlish_fn_27+0x395>
    332e:	mov    QWORD PTR [rsp+0x18],rax
    3333:	mov    rcx,rax
    3336:	mov    r8,0xffffffffffffffff
    333d:	mov    QWORD PTR [rsp+0x38],r8
    3342:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    334b:	mov    rdx,r14
    334e:	mov    rsi,r15
    3351:	mov    rdi,r12
    3354:	call   3359 <botlish_fn_27+0xb9>
			3355: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    3359:	mov    rcx,rax
    335c:	mov    QWORD PTR [rsp+0x30],rax
    3361:	test   rax,rcx
    3364:	jne    3372 <botlish_fn_27+0xd2>
    336a:	mov    rdi,r12
    336d:	jmp    3635 <botlish_fn_27+0x395>
    3372:	mov    rax,QWORD PTR [rsp+0x30]
    3377:	mov    QWORD PTR [rsp+0x18],rax
    337c:	mov    rsi,r15
    337f:	mov    rdi,r12
    3382:	call   3387 <botlish_fn_27+0xe7>
			3383: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    3387:	test   rax,rax
    338a:	jne    3398 <botlish_fn_27+0xf8>
    3390:	mov    rdi,r12
    3393:	jmp    3635 <botlish_fn_27+0x395>
    3398:	xor    ecx,ecx
    339a:	test   rax,0x7
    33a0:	je     33ae <botlish_fn_27+0x10e>
    33a6:	mov    rsi,rax
    33a9:	jmp    33bc <botlish_fn_27+0x11c>
    33ae:	movzx  rcx,BYTE PTR [rax]
    33b2:	mov    rsi,rax
    33b5:	rex cmp cl,0x8
    33b9:	sete   cl
    33bc:	test   cl,cl
    33be:	jne    33e1 <botlish_fn_27+0x141>
    33c4:	mov    rdi,r12
    33c7:	mov    rax,QWORD PTR [rdi+0x10]
    33cb:	mov    rcx,QWORD PTR [rax+0x8]
    33cf:	mov    edx,0x8
    33d4:	call   33d9 <botlish_fn_27+0x139>
			33d5: R_X86_64_PLT32	rt_type_error-0x4
    33d9:	mov    rdi,r12
    33dc:	jmp    3635 <botlish_fn_27+0x395>
    33e1:	mov    rdx,QWORD PTR [rsp+0x30]
    33e6:	mov    rdi,r12
    33e9:	call   33ee <botlish_fn_27+0x14e>
			33ea: R_X86_64_PLT32	rt_mutarray_get-0x4
    33ee:	test   rax,rax
    33f1:	jne    33ff <botlish_fn_27+0x15f>
    33f7:	mov    rdi,r12
    33fa:	jmp    3635 <botlish_fn_27+0x395>
    33ff:	mov    QWORD PTR [rsp+0x20],rax
    3404:	mov    QWORD PTR [rsp+0x28],rax
    3409:	mov    rdi,r12
    340c:	call   3411 <botlish_fn_27+0x171>
			340d: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    3411:	test   rax,rax
    3414:	jne    3422 <botlish_fn_27+0x182>
    341a:	mov    rdi,r12
    341d:	jmp    3635 <botlish_fn_27+0x395>
    3422:	mov    rcx,QWORD PTR [rsp+0x28]
    3427:	mov    rdx,rcx
    342a:	and    rdx,rax
    342d:	test   rdx,0x1
    3434:	jne    345b <botlish_fn_27+0x1bb>
    343a:	mov    rdx,rax
    343d:	mov    rsi,QWORD PTR [rsp+0x28]
    3442:	mov    rdi,r12
    3445:	call   344a <botlish_fn_27+0x1aa>
			3446: R_X86_64_PLT32	rt_value_eq-0x4
    344a:	test   rax,rax
    344d:	jne    3473 <botlish_fn_27+0x1d3>
    3453:	mov    rdi,r12
    3456:	jmp    3635 <botlish_fn_27+0x395>
    345b:	mov    rdx,rax
    345e:	mov    rsi,QWORD PTR [rsp+0x28]
    3463:	mov    eax,0x2
    3468:	cmp    rsi,rdx
    346b:	cmove  rax,QWORD PTR [rip+0x24d]        # 36c0 <botlish_fn_27+0x420>
    3473:	cmp    rax,0x6
    3477:	je     35b4 <botlish_fn_27+0x314>
    347d:	mov    rsi,r15
    3480:	mov    rdi,r12
    3483:	call   3488 <botlish_fn_27+0x1e8>
			3484: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    3488:	test   rax,rax
    348b:	jne    3499 <botlish_fn_27+0x1f9>
    3491:	mov    rdi,r12
    3494:	jmp    3635 <botlish_fn_27+0x395>
    3499:	cmp    rax,0x6
    349d:	je     34f2 <botlish_fn_27+0x252>
    34a3:	mov    rcx,r14
    34a6:	mov    rdx,QWORD PTR [rsp+0x30]
    34ab:	mov    rsi,r15
    34ae:	mov    r8,r13
    34b1:	mov    rdi,r12
    34b4:	call   34b9 <botlish_fn_27+0x219>
			34b5: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    34b9:	test   rax,rax
    34bc:	jne    34ca <botlish_fn_27+0x22a>
    34c2:	mov    rdi,r12
    34c5:	jmp    3635 <botlish_fn_27+0x395>
    34ca:	mov    rdi,r12
    34cd:	mov    QWORD PTR [rdi],rbx
    34d0:	mov    rbx,QWORD PTR [rsp+0x40]
    34d5:	mov    r12,QWORD PTR [rsp+0x48]
    34da:	mov    r13,QWORD PTR [rsp+0x50]
    34df:	mov    r14,QWORD PTR [rsp+0x58]
    34e4:	mov    r15,QWORD PTR [rsp+0x60]
    34e9:	add    rsp,0x70
    34ed:	mov    rsp,rbp
    34f0:	pop    rbp
    34f1:	ret
    34f2:	mov    rsi,r15
    34f5:	mov    rdi,r12
    34f8:	call   34fd <botlish_fn_27+0x25d>
			34f9: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    34fd:	test   rax,rax
    3500:	jne    350e <botlish_fn_27+0x26e>
    3506:	mov    rdi,r12
    3509:	jmp    3635 <botlish_fn_27+0x395>
    350e:	mov    rdx,r14
    3511:	mov    rsi,r15
    3514:	mov    rdi,r12
    3517:	call   351c <botlish_fn_27+0x27c>
			3518: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    351c:	test   rax,rax
    351f:	jne    352d <botlish_fn_27+0x28d>
    3525:	mov    rdi,r12
    3528:	jmp    3635 <botlish_fn_27+0x395>
    352d:	mov    QWORD PTR [rsp+0x18],rax
    3532:	mov    rcx,rax
    3535:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    353e:	mov    r8,QWORD PTR [rsp+0x38]
    3543:	mov    rdx,r14
    3546:	mov    rsi,r15
    3549:	mov    rdi,r12
    354c:	call   3551 <botlish_fn_27+0x2b1>
			354d: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    3551:	test   rax,rax
    3554:	jne    3562 <botlish_fn_27+0x2c2>
    355a:	mov    rdi,r12
    355d:	jmp    3635 <botlish_fn_27+0x395>
    3562:	mov    QWORD PTR [rsp+0x18],rax
    3567:	mov    rcx,r14
    356a:	mov    rdx,rax
    356d:	mov    rsi,r15
    3570:	mov    r8,r13
    3573:	mov    rdi,r12
    3576:	call   357b <botlish_fn_27+0x2db>
			3577: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    357b:	test   rax,rax
    357e:	jne    358c <botlish_fn_27+0x2ec>
    3584:	mov    rdi,r12
    3587:	jmp    3635 <botlish_fn_27+0x395>
    358c:	mov    rdi,r12
    358f:	mov    QWORD PTR [rdi],rbx
    3592:	mov    rbx,QWORD PTR [rsp+0x40]
    3597:	mov    r12,QWORD PTR [rsp+0x48]
    359c:	mov    r13,QWORD PTR [rsp+0x50]
    35a1:	mov    r14,QWORD PTR [rsp+0x58]
    35a6:	mov    r15,QWORD PTR [rsp+0x60]
    35ab:	add    rsp,0x70
    35af:	mov    rsp,rbp
    35b2:	pop    rbp
    35b3:	ret
    35b4:	mov    rsi,r15
    35b7:	mov    rdi,r12
    35ba:	call   35bf <botlish_fn_27+0x31f>
			35bb: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    35bf:	test   rax,rax
    35c2:	jne    35d0 <botlish_fn_27+0x330>
    35c8:	mov    rdi,r12
    35cb:	jmp    3635 <botlish_fn_27+0x395>
    35d0:	xor    ecx,ecx
    35d2:	test   rax,0x7
    35d8:	je     35e6 <botlish_fn_27+0x346>
    35de:	mov    rsi,rax
    35e1:	jmp    35f4 <botlish_fn_27+0x354>
    35e6:	movzx  rdi,BYTE PTR [rax]
    35ea:	mov    rsi,rax
    35ed:	cmp    dil,0x8
    35f1:	sete   cl
    35f4:	test   cl,cl
    35f6:	jne    3619 <botlish_fn_27+0x379>
    35fc:	mov    rdi,r12
    35ff:	mov    r11,QWORD PTR [rdi+0x10]
    3603:	mov    rcx,QWORD PTR [r11+0x20]
    3607:	mov    edx,0x8
    360c:	call   3611 <botlish_fn_27+0x371>
			360d: R_X86_64_PLT32	rt_type_error-0x4
    3611:	mov    rdi,r12
    3614:	jmp    3635 <botlish_fn_27+0x395>
    3619:	mov    rcx,r13
    361c:	mov    rdx,QWORD PTR [rsp+0x30]
    3621:	mov    rdi,r12
    3624:	call   3629 <botlish_fn_27+0x389>
			3625: R_X86_64_PLT32	rt_mutarray_set-0x4
    3629:	test   rax,rax
    362c:	jne    3660 <botlish_fn_27+0x3c0>
    3632:	mov    rdi,r12
    3635:	mov    rdi,r12
    3638:	mov    QWORD PTR [rdi],rbx
    363b:	xor    rax,rax
    363e:	mov    rbx,QWORD PTR [rsp+0x40]
    3643:	mov    r12,QWORD PTR [rsp+0x48]
    3648:	mov    r13,QWORD PTR [rsp+0x50]
    364d:	mov    r14,QWORD PTR [rsp+0x58]
    3652:	mov    r15,QWORD PTR [rsp+0x60]
    3657:	add    rsp,0x70
    365b:	mov    rsp,rbp
    365e:	pop    rbp
    365f:	ret
    3660:	mov    rdi,r12
    3663:	mov    QWORD PTR [rdi],rbx
    3666:	mov    eax,0xa
    366b:	mov    rbx,QWORD PTR [rsp+0x40]
    3670:	mov    r12,QWORD PTR [rsp+0x48]
    3675:	mov    r13,QWORD PTR [rsp+0x50]
    367a:	mov    r14,QWORD PTR [rsp+0x58]
    367f:	mov    r15,QWORD PTR [rsp+0x60]
    3684:	add    rsp,0x70
    3688:	mov    rsp,rbp
    368b:	pop    rbp
    368c:	ret
    368d:	mov    r12,rdi
    3690:	call   3695 <botlish_fn_27+0x3f5>
			3691: R_X86_64_PLT32	rt_stack_overflow-0x4
    3695:	xor    rax,rax
    3698:	mov    rbx,QWORD PTR [rsp+0x40]
    369d:	mov    r12,QWORD PTR [rsp+0x48]
    36a2:	mov    r13,QWORD PTR [rsp+0x50]
    36a7:	mov    r14,QWORD PTR [rsp+0x58]
    36ac:	mov    r15,QWORD PTR [rsp+0x60]
    36b1:	add    rsp,0x70
    36b5:	mov    rsp,rbp
    36b8:	pop    rbp
    36b9:	ret
    36ba:	add    BYTE PTR [rax],al
    36bc:	add    BYTE PTR [rax],al
    36be:	add    BYTE PTR [rax],al
    36c0:	(bad)
    36c1:	add    BYTE PTR [rax],al
    36c3:	add    BYTE PTR [rax],al
    36c5:	add    BYTE PTR [rax],al
	...

00000000000036c8 <botlish_entry_27: ht_set<mutarray, str, str>>:
    36c8:	push   rbp
    36c9:	mov    rbp,rsp
    36cc:	mov    rsi,QWORD PTR [rdx]
    36cf:	mov    r8,QWORD PTR [rdx+0x8]
    36d3:	mov    rcx,QWORD PTR [rdx+0x10]
    36d7:	mov    rdx,r8
    36da:	call   36df <botlish_entry_27+0x17>
			36db: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    36df:	mov    rsp,rbp
    36e2:	pop    rbp
    36e3:	ret
    36e4:	add    BYTE PTR [rax],al
	...

00000000000036e8 <botlish_fn_28: ht_delete<mutarray, str>>:
    36e8:	push   rbp
    36e9:	mov    rbp,rsp
    36ec:	sub    rsp,0x50
    36f0:	mov    QWORD PTR [rsp+0x20],rbx
    36f5:	mov    QWORD PTR [rsp+0x28],r12
    36fa:	mov    QWORD PTR [rsp+0x30],r13
    36ff:	mov    QWORD PTR [rsp+0x38],r14
    3704:	mov    QWORD PTR [rsp+0x40],r15
    3709:	mov    rbx,QWORD PTR [rdi]
    370c:	mov    rax,QWORD PTR [rdi+0x8]
    3710:	lea    rcx,[rbx+0x8]
    3714:	cmp    rcx,rax
    3717:	ja     3c03 <botlish_fn_28+0x51b>
    371d:	lea    rax,[rbx+0x8]
    3721:	mov    QWORD PTR [rdi],rax
    3724:	mov    r12,rdi
    3727:	mov    QWORD PTR [rbx],0x0
    372e:	mov    QWORD PTR [rsp+0x10],0x0
    3737:	mov    QWORD PTR [rsp+0x18],0x0
    3740:	mov    QWORD PTR [rsp],rsi
    3744:	mov    r13,rsi
    3747:	mov    QWORD PTR [rsp+0x8],rdx
    374c:	mov    r14,rdx
    374f:	mov    rdx,r14
    3752:	mov    rsi,r13
    3755:	mov    rdi,r12
    3758:	call   375d <botlish_fn_28+0x75>
			3759: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    375d:	test   rax,rax
    3760:	jne    376e <botlish_fn_28+0x86>
    3766:	mov    rdi,r12
    3769:	jmp    3b7e <botlish_fn_28+0x496>
    376e:	mov    QWORD PTR [rsp+0x10],rax
    3773:	mov    rcx,rax
    3776:	mov    rdx,r14
    3779:	mov    rsi,r13
    377c:	mov    rdi,r12
    377f:	call   3784 <botlish_fn_28+0x9c>
			3780: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    3784:	mov    rcx,rax
    3787:	mov    r14,rax
    378a:	test   rax,rcx
    378d:	jne    379b <botlish_fn_28+0xb3>
    3793:	mov    rdi,r12
    3796:	jmp    3b7e <botlish_fn_28+0x496>
    379b:	mov    rax,r14
    379e:	mov    QWORD PTR [rsp+0x8],rax
    37a3:	test   rax,0x1
    37a9:	jne    37d4 <botlish_fn_28+0xec>
    37af:	mov    edx,0x1
    37b4:	mov    rsi,r14
    37b7:	mov    rdi,r12
    37ba:	call   37bf <botlish_fn_28+0xd7>
			37bb: R_X86_64_PLT32	rt_int_cmp-0x4
    37bf:	mov    ecx,0x2
    37c4:	test   rax,rax
    37c7:	cmovl  rcx,QWORD PTR [rip+0x461]        # 3c30 <botlish_fn_28+0x548>
    37cf:	jmp    37ea <botlish_fn_28+0x102>
    37d4:	mov    ecx,0x2
    37d9:	mov    rax,r14
    37dc:	mov    rdx,r14
    37df:	test   rax,rdx
    37e2:	cmovle rcx,QWORD PTR [rip+0x446]        # 3c30 <botlish_fn_28+0x548>
    37ea:	cmp    rcx,0x6
    37ee:	je     3bd6 <botlish_fn_28+0x4ee>
    37f4:	mov    rsi,r13
    37f7:	mov    rdi,r12
    37fa:	call   37ff <botlish_fn_28+0x117>
			37fb: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    37ff:	test   rax,rax
    3802:	jne    3810 <botlish_fn_28+0x128>
    3808:	mov    rdi,r12
    380b:	jmp    3b7e <botlish_fn_28+0x496>
    3810:	mov    QWORD PTR [rsp+0x10],rax
    3815:	mov    r15,rax
    3818:	mov    rdi,r12
    381b:	call   3820 <botlish_fn_28+0x138>
			381c: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    3820:	test   rax,rax
    3823:	mov    rsi,rax
    3826:	jne    3834 <botlish_fn_28+0x14c>
    382c:	mov    rdi,r12
    382f:	jmp    3b7e <botlish_fn_28+0x496>
    3834:	xor    ecx,ecx
    3836:	mov    rax,r15
    3839:	test   rax,0x7
    383f:	je     384d <botlish_fn_28+0x165>
    3845:	mov    r15,rax
    3848:	jmp    385b <botlish_fn_28+0x173>
    384d:	movzx  r8,BYTE PTR [rax]
    3851:	mov    r15,rax
    3854:	cmp    r8b,0x8
    3858:	sete   cl
    385b:	test   cl,cl
    385d:	jne    3883 <botlish_fn_28+0x19b>
    3863:	mov    rdi,r12
    3866:	mov    rax,QWORD PTR [rdi+0x10]
    386a:	mov    rcx,QWORD PTR [rax+0x20]
    386e:	mov    edx,0x8
    3873:	mov    rsi,r15
    3876:	call   387b <botlish_fn_28+0x193>
			3877: R_X86_64_PLT32	rt_type_error-0x4
    387b:	mov    rdi,r12
    387e:	jmp    3b7e <botlish_fn_28+0x496>
    3883:	mov    rcx,rsi
    3886:	mov    rsi,r15
    3889:	mov    rdx,r14
    388c:	mov    rdi,r12
    388f:	call   3894 <botlish_fn_28+0x1ac>
			3890: R_X86_64_PLT32	rt_mutarray_set-0x4
    3894:	test   rax,rax
    3897:	jne    38a5 <botlish_fn_28+0x1bd>
    389d:	mov    rdi,r12
    38a0:	jmp    3b7e <botlish_fn_28+0x496>
    38a5:	mov    rsi,r13
    38a8:	mov    rdi,r12
    38ab:	call   38b0 <botlish_fn_28+0x1c8>
			38ac: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    38b0:	test   rax,rax
    38b3:	jne    38c1 <botlish_fn_28+0x1d9>
    38b9:	mov    rdi,r12
    38bc:	jmp    3b7e <botlish_fn_28+0x496>
    38c1:	xor    ecx,ecx
    38c3:	test   rax,0x7
    38c9:	je     38d7 <botlish_fn_28+0x1ef>
    38cf:	mov    rsi,rax
    38d2:	jmp    38e5 <botlish_fn_28+0x1fd>
    38d7:	movzx  rcx,BYTE PTR [rax]
    38db:	mov    rsi,rax
    38de:	rex cmp cl,0x8
    38e2:	sete   cl
    38e5:	test   cl,cl
    38e7:	jne    390a <botlish_fn_28+0x222>
    38ed:	mov    rdi,r12
    38f0:	mov    rax,QWORD PTR [rdi+0x10]
    38f4:	mov    rcx,QWORD PTR [rax+0x20]
    38f8:	mov    edx,0x8
    38fd:	call   3902 <botlish_fn_28+0x21a>
			38fe: R_X86_64_PLT32	rt_type_error-0x4
    3902:	mov    rdi,r12
    3905:	jmp    3b7e <botlish_fn_28+0x496>
    390a:	mov    ecx,0xa
    390f:	mov    rdx,r14
    3912:	mov    rdi,r12
    3915:	call   391a <botlish_fn_28+0x232>
			3916: R_X86_64_PLT32	rt_mutarray_set-0x4
    391a:	test   rax,rax
    391d:	jne    392b <botlish_fn_28+0x243>
    3923:	mov    rdi,r12
    3926:	jmp    3b7e <botlish_fn_28+0x496>
    392b:	mov    rsi,r13
    392e:	mov    rdi,r12
    3931:	call   3936 <botlish_fn_28+0x24e>
			3932: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3936:	test   rax,rax
    3939:	jne    3947 <botlish_fn_28+0x25f>
    393f:	mov    rdi,r12
    3942:	jmp    3b7e <botlish_fn_28+0x496>
    3947:	xor    ecx,ecx
    3949:	test   rax,0x7
    394f:	je     395d <botlish_fn_28+0x275>
    3955:	mov    rsi,rax
    3958:	jmp    396b <botlish_fn_28+0x283>
    395d:	movzx  rcx,BYTE PTR [rax]
    3961:	mov    rsi,rax
    3964:	rex cmp cl,0x8
    3968:	sete   cl
    396b:	test   cl,cl
    396d:	jne    3990 <botlish_fn_28+0x2a8>
    3973:	mov    rdi,r12
    3976:	mov    rax,QWORD PTR [rdi+0x10]
    397a:	mov    rcx,QWORD PTR [rax+0x20]
    397e:	mov    edx,0x8
    3983:	call   3988 <botlish_fn_28+0x2a0>
			3984: R_X86_64_PLT32	rt_type_error-0x4
    3988:	mov    rdi,r12
    398b:	jmp    3b7e <botlish_fn_28+0x496>
    3990:	mov    ecx,0xa
    3995:	mov    rdx,r14
    3998:	mov    rdi,r12
    399b:	call   39a0 <botlish_fn_28+0x2b8>
			399c: R_X86_64_PLT32	rt_mutarray_set-0x4
    39a0:	test   rax,rax
    39a3:	jne    39b1 <botlish_fn_28+0x2c9>
    39a9:	mov    rdi,r12
    39ac:	jmp    3b7e <botlish_fn_28+0x496>
    39b1:	mov    QWORD PTR [rsp+0x8],0x7
    39ba:	mov    rsi,r13
    39bd:	mov    rdi,r12
    39c0:	call   39c5 <botlish_fn_28+0x2dd>
			39c1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    39c5:	test   rax,rax
    39c8:	jne    39d6 <botlish_fn_28+0x2ee>
    39ce:	mov    rdi,r12
    39d1:	jmp    3b7e <botlish_fn_28+0x496>
    39d6:	mov    QWORD PTR [rsp+0x10],rax
    39db:	mov    QWORD PTR [rsp+0x18],0x3
    39e4:	mov    esi,0x1
    39e9:	test   rax,0x1
    39ef:	je     39fd <botlish_fn_28+0x315>
    39f5:	mov    r8,rax
    39f8:	jmp    3a22 <botlish_fn_28+0x33a>
    39fd:	xor    esi,esi
    39ff:	test   rax,0x7
    3a05:	je     3a13 <botlish_fn_28+0x32b>
    3a0b:	mov    r8,rax
    3a0e:	jmp    3a22 <botlish_fn_28+0x33a>
    3a13:	movzx  rcx,BYTE PTR [rax]
    3a17:	mov    r8,rax
    3a1a:	rex cmp cl,0x1
    3a1e:	sete   sil
    3a22:	test   sil,sil
    3a25:	jne    3a49 <botlish_fn_28+0x361>
    3a2b:	mov    rdi,r12
    3a2e:	mov    rax,QWORD PTR [rdi+0x10]
    3a32:	mov    rcx,QWORD PTR [rax+0x28]
    3a36:	xor    rdx,rdx
    3a39:	mov    rsi,r8
    3a3c:	call   3a41 <botlish_fn_28+0x359>
			3a3d: R_X86_64_PLT32	rt_type_error-0x4
    3a41:	mov    rdi,r12
    3a44:	jmp    3b7e <botlish_fn_28+0x496>
    3a49:	mov    rsi,r8
    3a4c:	test   rsi,0x1
    3a53:	je     3a6f <botlish_fn_28+0x387>
    3a59:	mov    rax,rsi
    3a5c:	sub    rax,0x3
    3a60:	seto   dl
    3a63:	lea    rcx,[rax+0x1]
    3a67:	test   dl,dl
    3a69:	je     3a7f <botlish_fn_28+0x397>
    3a6f:	mov    edx,0x3
    3a74:	mov    rdi,r12
    3a77:	call   3a7c <botlish_fn_28+0x394>
			3a78: R_X86_64_PLT32	rt_int_sub-0x4
    3a7c:	mov    rcx,rax
    3a7f:	mov    edx,0x7
    3a84:	mov    rsi,r13
    3a87:	mov    rdi,r12
    3a8a:	call   3a8f <botlish_fn_28+0x3a7>
			3a8b: R_X86_64_PLT32	rt_mutarray_set-0x4
    3a8f:	test   rax,rax
    3a92:	jne    3aa0 <botlish_fn_28+0x3b8>
    3a98:	mov    rdi,r12
    3a9b:	jmp    3b7e <botlish_fn_28+0x496>
    3aa0:	mov    QWORD PTR [rsp+0x8],0x9
    3aa9:	mov    rsi,r13
    3aac:	mov    rdi,r12
    3aaf:	call   3ab4 <botlish_fn_28+0x3cc>
			3ab0: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3ab4:	test   rax,rax
    3ab7:	jne    3ac5 <botlish_fn_28+0x3dd>
    3abd:	mov    rdi,r12
    3ac0:	jmp    3b7e <botlish_fn_28+0x496>
    3ac5:	mov    QWORD PTR [rsp+0x10],rax
    3aca:	mov    QWORD PTR [rsp+0x18],0x3
    3ad3:	mov    ecx,0x1
    3ad8:	test   rax,0x1
    3ade:	je     3aec <botlish_fn_28+0x404>
    3ae4:	mov    rsi,rax
    3ae7:	jmp    3b10 <botlish_fn_28+0x428>
    3aec:	xor    ecx,ecx
    3aee:	test   rax,0x7
    3af4:	je     3b02 <botlish_fn_28+0x41a>
    3afa:	mov    rsi,rax
    3afd:	jmp    3b10 <botlish_fn_28+0x428>
    3b02:	movzx  rcx,BYTE PTR [rax]
    3b06:	mov    rsi,rax
    3b09:	rex cmp cl,0x1
    3b0d:	sete   cl
    3b10:	test   cl,cl
    3b12:	jne    3b33 <botlish_fn_28+0x44b>
    3b18:	mov    rdi,r12
    3b1b:	mov    rax,QWORD PTR [rdi+0x10]
    3b1f:	mov    rcx,QWORD PTR [rax+0x10]
    3b23:	xor    rdx,rdx
    3b26:	call   3b2b <botlish_fn_28+0x443>
			3b27: R_X86_64_PLT32	rt_type_error-0x4
    3b2b:	mov    rdi,r12
    3b2e:	jmp    3b7e <botlish_fn_28+0x496>
    3b33:	test   rsi,0x1
    3b3a:	je     3b52 <botlish_fn_28+0x46a>
    3b40:	mov    rcx,rsi
    3b43:	add    rcx,0x2
    3b47:	seto   al
    3b4a:	test   al,al
    3b4c:	je     3b62 <botlish_fn_28+0x47a>
    3b52:	mov    edx,0x3
    3b57:	mov    rdi,r12
    3b5a:	call   3b5f <botlish_fn_28+0x477>
			3b5b: R_X86_64_PLT32	rt_int_add-0x4
    3b5f:	mov    rcx,rax
    3b62:	mov    edx,0x9
    3b67:	mov    rsi,r13
    3b6a:	mov    rdi,r12
    3b6d:	call   3b72 <botlish_fn_28+0x48a>
			3b6e: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b72:	test   rax,rax
    3b75:	jne    3ba9 <botlish_fn_28+0x4c1>
    3b7b:	mov    rdi,r12
    3b7e:	mov    rdi,r12
    3b81:	mov    QWORD PTR [rdi],rbx
    3b84:	xor    rax,rax
    3b87:	mov    rbx,QWORD PTR [rsp+0x20]
    3b8c:	mov    r12,QWORD PTR [rsp+0x28]
    3b91:	mov    r13,QWORD PTR [rsp+0x30]
    3b96:	mov    r14,QWORD PTR [rsp+0x38]
    3b9b:	mov    r15,QWORD PTR [rsp+0x40]
    3ba0:	add    rsp,0x50
    3ba4:	mov    rsp,rbp
    3ba7:	pop    rbp
    3ba8:	ret
    3ba9:	mov    rdi,r12
    3bac:	mov    QWORD PTR [rdi],rbx
    3baf:	mov    eax,0xa
    3bb4:	mov    rbx,QWORD PTR [rsp+0x20]
    3bb9:	mov    r12,QWORD PTR [rsp+0x28]
    3bbe:	mov    r13,QWORD PTR [rsp+0x30]
    3bc3:	mov    r14,QWORD PTR [rsp+0x38]
    3bc8:	mov    r15,QWORD PTR [rsp+0x40]
    3bcd:	add    rsp,0x50
    3bd1:	mov    rsp,rbp
    3bd4:	pop    rbp
    3bd5:	ret
    3bd6:	mov    rdi,r12
    3bd9:	mov    QWORD PTR [rdi],rbx
    3bdc:	mov    eax,0xa
    3be1:	mov    rbx,QWORD PTR [rsp+0x20]
    3be6:	mov    r12,QWORD PTR [rsp+0x28]
    3beb:	mov    r13,QWORD PTR [rsp+0x30]
    3bf0:	mov    r14,QWORD PTR [rsp+0x38]
    3bf5:	mov    r15,QWORD PTR [rsp+0x40]
    3bfa:	add    rsp,0x50
    3bfe:	mov    rsp,rbp
    3c01:	pop    rbp
    3c02:	ret
    3c03:	mov    r12,rdi
    3c06:	call   3c0b <botlish_fn_28+0x523>
			3c07: R_X86_64_PLT32	rt_stack_overflow-0x4
    3c0b:	xor    rax,rax
    3c0e:	mov    rbx,QWORD PTR [rsp+0x20]
    3c13:	mov    r12,QWORD PTR [rsp+0x28]
    3c18:	mov    r13,QWORD PTR [rsp+0x30]
    3c1d:	mov    r14,QWORD PTR [rsp+0x38]
    3c22:	mov    r15,QWORD PTR [rsp+0x40]
    3c27:	add    rsp,0x50
    3c2b:	mov    rsp,rbp
    3c2e:	pop    rbp
    3c2f:	ret
    3c30:	(bad)
    3c31:	add    BYTE PTR [rax],al
    3c33:	add    BYTE PTR [rax],al
    3c35:	add    BYTE PTR [rax],al
	...

0000000000003c38 <botlish_entry_28: ht_delete<mutarray, str>>:
    3c38:	push   rbp
    3c39:	mov    rbp,rsp
    3c3c:	mov    rsi,QWORD PTR [rdx]
    3c3f:	mov    rdx,QWORD PTR [rdx+0x8]
    3c43:	call   3c48 <botlish_entry_28+0x10>
			3c44: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3c48:	mov    rsp,rbp
    3c4b:	pop    rbp
    3c4c:	ret
    3c4d:	add    BYTE PTR [rax],al
	...

0000000000003c50 <botlish_fn_29: sample<generic>>:
    3c50:	push   rbp
    3c51:	mov    rbp,rsp
    3c54:	sub    rsp,0xb0
    3c5b:	mov    QWORD PTR [rsp+0x80],rbx
    3c63:	mov    QWORD PTR [rsp+0x88],r12
    3c6b:	mov    QWORD PTR [rsp+0x90],r13
    3c73:	mov    QWORD PTR [rsp+0x98],r14
    3c7b:	mov    QWORD PTR [rsp+0xa0],r15
    3c83:	mov    rbx,QWORD PTR [rdi]
    3c86:	mov    rax,QWORD PTR [rdi+0x8]
    3c8a:	lea    rcx,[rbx+0x8]
    3c8e:	cmp    rcx,rax
    3c91:	ja     4027 <botlish_fn_29+0x3d7>
    3c97:	lea    rax,[rbx+0x8]
    3c9b:	mov    QWORD PTR [rdi],rax
    3c9e:	mov    r15,rdi
    3ca1:	mov    QWORD PTR [rbx],0x0
    3ca8:	mov    QWORD PTR [rsp],0x0
    3cb0:	mov    QWORD PTR [rsp+0x8],0x0
    3cb9:	mov    QWORD PTR [rsp+0x10],0x0
    3cc2:	mov    QWORD PTR [rsp+0x18],0x0
    3ccb:	mov    QWORD PTR [rsp+0x20],0x0
    3cd4:	mov    QWORD PTR [rsp+0x28],0x0
    3cdd:	mov    rdi,r15
    3ce0:	call   3ce5 <botlish_fn_29+0x95>
			3ce1: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    3ce5:	mov    rcx,rax
    3ce8:	mov    QWORD PTR [rsp+0x70],rax
    3ced:	test   rax,rcx
    3cf0:	jne    3cfe <botlish_fn_29+0xae>
    3cf6:	mov    rdi,r15
    3cf9:	jmp    3fb0 <botlish_fn_29+0x360>
    3cfe:	mov    rax,QWORD PTR [rsp+0x70]
    3d03:	mov    QWORD PTR [rsp],rax
    3d07:	mov    rdi,r15
    3d0a:	mov    r10,QWORD PTR [rdi+0x10]
    3d0e:	mov    rdx,QWORD PTR [r10+0x30]
    3d12:	mov    QWORD PTR [rsp+0x8],rdx
    3d17:	mov    r11,QWORD PTR [rdi+0x10]
    3d1b:	mov    rcx,QWORD PTR [r11+0x38]
    3d1f:	mov    QWORD PTR [rsp+0x10],rcx
    3d24:	mov    rsi,QWORD PTR [rsp+0x70]
    3d29:	call   3d2e <botlish_fn_29+0xde>
			3d2a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3d2e:	test   rax,rax
    3d31:	jne    3d3f <botlish_fn_29+0xef>
    3d37:	mov    rdi,r15
    3d3a:	jmp    3fb0 <botlish_fn_29+0x360>
    3d3f:	mov    rdi,r15
    3d42:	mov    rax,QWORD PTR [rdi+0x10]
    3d46:	mov    rdx,QWORD PTR [rax+0x40]
    3d4a:	mov    QWORD PTR [rsp+0x8],rdx
    3d4f:	mov    rax,QWORD PTR [rdi+0x10]
    3d53:	mov    rcx,QWORD PTR [rax+0x48]
    3d57:	mov    QWORD PTR [rsp+0x10],rcx
    3d5c:	mov    rsi,QWORD PTR [rsp+0x70]
    3d61:	call   3d66 <botlish_fn_29+0x116>
			3d62: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3d66:	test   rax,rax
    3d69:	jne    3d77 <botlish_fn_29+0x127>
    3d6f:	mov    rdi,r15
    3d72:	jmp    3fb0 <botlish_fn_29+0x360>
    3d77:	mov    rdi,r15
    3d7a:	mov    rax,QWORD PTR [rdi+0x10]
    3d7e:	mov    rdx,QWORD PTR [rax+0x30]
    3d82:	mov    QWORD PTR [rsp+0x8],rdx
    3d87:	mov    rax,QWORD PTR [rdi+0x10]
    3d8b:	mov    rcx,QWORD PTR [rax+0x50]
    3d8f:	mov    QWORD PTR [rsp+0x10],rcx
    3d94:	mov    rsi,QWORD PTR [rsp+0x70]
    3d99:	call   3d9e <botlish_fn_29+0x14e>
			3d9a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3d9e:	test   rax,rax
    3da1:	jne    3daf <botlish_fn_29+0x15f>
    3da7:	mov    rdi,r15
    3daa:	jmp    3fb0 <botlish_fn_29+0x360>
    3daf:	mov    rdi,r15
    3db2:	mov    rax,QWORD PTR [rdi+0x10]
    3db6:	mov    rdx,QWORD PTR [rax+0x40]
    3dba:	mov    QWORD PTR [rsp+0x8],rdx
    3dbf:	mov    rsi,QWORD PTR [rsp+0x70]
    3dc4:	call   3dc9 <botlish_fn_29+0x179>
			3dc5: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3dc9:	mov    r12,rax
    3dcc:	test   r12,r12
    3dcf:	jne    3ddd <botlish_fn_29+0x18d>
    3dd5:	mov    rdi,r15
    3dd8:	jmp    3fb0 <botlish_fn_29+0x360>
    3ddd:	mov    QWORD PTR [rsp+0x8],r12
    3de2:	mov    rdi,r15
    3de5:	mov    rax,QWORD PTR [rdi+0x10]
    3de9:	mov    rdx,QWORD PTR [rax+0x40]
    3ded:	mov    QWORD PTR [rsp+0x10],rdx
    3df2:	mov    rsi,QWORD PTR [rsp+0x70]
    3df7:	call   3dfc <botlish_fn_29+0x1ac>
			3df8: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3dfc:	test   rax,rax
    3dff:	jne    3e0d <botlish_fn_29+0x1bd>
    3e05:	mov    rdi,r15
    3e08:	jmp    3fb0 <botlish_fn_29+0x360>
    3e0d:	mov    rdi,r15
    3e10:	mov    rax,QWORD PTR [rdi+0x10]
    3e14:	mov    rdx,QWORD PTR [rax+0x30]
    3e18:	mov    QWORD PTR [rsp+0x10],rdx
    3e1d:	mov    rsi,QWORD PTR [rsp+0x70]
    3e22:	call   3e27 <botlish_fn_29+0x1d7>
			3e23: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    3e27:	test   rax,rax
    3e2a:	jne    3e38 <botlish_fn_29+0x1e8>
    3e30:	mov    rdi,r15
    3e33:	jmp    3fb0 <botlish_fn_29+0x360>
    3e38:	mov    rdi,r15
    3e3b:	mov    rcx,QWORD PTR [rdi+0x10]
    3e3f:	mov    rdx,QWORD PTR [rcx+0x50]
    3e43:	mov    rcx,rax
    3e46:	and    rcx,rdx
    3e49:	mov    rsi,rax
    3e4c:	test   rcx,0x1
    3e53:	jne    3e72 <botlish_fn_29+0x222>
    3e59:	mov    rdi,r15
    3e5c:	call   3e61 <botlish_fn_29+0x211>
			3e5d: R_X86_64_PLT32	rt_value_eq-0x4
    3e61:	test   rax,rax
    3e64:	jne    3e82 <botlish_fn_29+0x232>
    3e6a:	mov    rdi,r15
    3e6d:	jmp    3fb0 <botlish_fn_29+0x360>
    3e72:	mov    eax,0x2
    3e77:	cmp    rsi,rdx
    3e7a:	cmove  rax,QWORD PTR [rip+0x1e6]        # 4068 <botlish_fn_29+0x418>
    3e82:	mov    QWORD PTR [rsp+0x10],rax
    3e87:	mov    rdi,r15
    3e8a:	mov    QWORD PTR [rsp+0x60],rax
    3e8f:	mov    rax,QWORD PTR [rdi+0x10]
    3e93:	mov    rdx,QWORD PTR [rax+0x40]
    3e97:	mov    QWORD PTR [rsp+0x18],rdx
    3e9c:	mov    rsi,QWORD PTR [rsp+0x70]
    3ea1:	call   3ea6 <botlish_fn_29+0x256>
			3ea2: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3ea6:	mov    r13,rax
    3ea9:	test   r13,r13
    3eac:	jne    3eba <botlish_fn_29+0x26a>
    3eb2:	mov    rdi,r15
    3eb5:	jmp    3fb0 <botlish_fn_29+0x360>
    3eba:	mov    QWORD PTR [rsp+0x18],r13
    3ebf:	mov    rdi,r15
    3ec2:	mov    rax,QWORD PTR [rdi+0x10]
    3ec6:	mov    rdx,QWORD PTR [rax+0x58]
    3eca:	mov    QWORD PTR [rsp+0x20],rdx
    3ecf:	mov    rsi,QWORD PTR [rsp+0x70]
    3ed4:	call   3ed9 <botlish_fn_29+0x289>
			3ed5: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3ed9:	mov    r14,rax
    3edc:	test   r14,r14
    3edf:	jne    3eed <botlish_fn_29+0x29d>
    3ee5:	mov    rdi,r15
    3ee8:	jmp    3fb0 <botlish_fn_29+0x360>
    3eed:	mov    QWORD PTR [rsp+0x20],r14
    3ef2:	mov    rdi,r15
    3ef5:	mov    rax,QWORD PTR [rdi+0x10]
    3ef9:	mov    rdx,QWORD PTR [rax+0x58]
    3efd:	mov    QWORD PTR [rsp+0x28],rdx
    3f02:	mov    rsi,QWORD PTR [rsp+0x70]
    3f07:	call   3f0c <botlish_fn_29+0x2bc>
			3f08: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    3f0c:	test   rax,rax
    3f0f:	mov    rsi,rax
    3f12:	jne    3f20 <botlish_fn_29+0x2d0>
    3f18:	mov    rdi,r15
    3f1b:	jmp    3fb0 <botlish_fn_29+0x360>
    3f20:	mov    edx,0xa
    3f25:	mov    rdi,r15
    3f28:	call   3f2d <botlish_fn_29+0x2dd>
			3f29: R_X86_64_PLT32	rt_value_eq-0x4
    3f2d:	test   rax,rax
    3f30:	jne    3f3e <botlish_fn_29+0x2ee>
    3f36:	mov    rdi,r15
    3f39:	jmp    3fb0 <botlish_fn_29+0x360>
    3f3e:	mov    QWORD PTR [rsp+0x28],rax
    3f43:	mov    rsi,QWORD PTR [rsp+0x70]
    3f48:	mov    QWORD PTR [rsp+0x68],rax
    3f4d:	mov    rdi,r15
    3f50:	call   3f55 <botlish_fn_29+0x305>
			3f51: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3f55:	test   rax,rax
    3f58:	jne    3f66 <botlish_fn_29+0x316>
    3f5e:	mov    rdi,r15
    3f61:	jmp    3fb0 <botlish_fn_29+0x360>
    3f66:	mov    QWORD PTR [rsp],rax
    3f6a:	lea    rdx,[rsp+0x30]
    3f6f:	mov    rcx,QWORD PTR [rsp+0x60]
    3f74:	mov    QWORD PTR [rsp+0x30],rcx
    3f79:	mov    QWORD PTR [rsp+0x38],r12
    3f7e:	mov    QWORD PTR [rsp+0x40],r13
    3f83:	mov    QWORD PTR [rsp+0x48],r14
    3f88:	mov    rcx,QWORD PTR [rsp+0x68]
    3f8d:	mov    QWORD PTR [rsp+0x50],rcx
    3f92:	mov    QWORD PTR [rsp+0x58],rax
    3f97:	mov    esi,0x6
    3f9c:	mov    rdi,r15
    3f9f:	call   3fa4 <botlish_fn_29+0x354>
			3fa0: R_X86_64_PLT32	rt_list_new-0x4
    3fa4:	test   rax,rax
    3fa7:	jne    3fed <botlish_fn_29+0x39d>
    3fad:	mov    rdi,r15
    3fb0:	mov    rdi,r15
    3fb3:	mov    QWORD PTR [rdi],rbx
    3fb6:	xor    rax,rax
    3fb9:	mov    rbx,QWORD PTR [rsp+0x80]
    3fc1:	mov    r12,QWORD PTR [rsp+0x88]
    3fc9:	mov    r13,QWORD PTR [rsp+0x90]
    3fd1:	mov    r14,QWORD PTR [rsp+0x98]
    3fd9:	mov    r15,QWORD PTR [rsp+0xa0]
    3fe1:	add    rsp,0xb0
    3fe8:	mov    rsp,rbp
    3feb:	pop    rbp
    3fec:	ret
    3fed:	mov    rdi,r15
    3ff0:	mov    QWORD PTR [rdi],rbx
    3ff3:	mov    rbx,QWORD PTR [rsp+0x80]
    3ffb:	mov    r12,QWORD PTR [rsp+0x88]
    4003:	mov    r13,QWORD PTR [rsp+0x90]
    400b:	mov    r14,QWORD PTR [rsp+0x98]
    4013:	mov    r15,QWORD PTR [rsp+0xa0]
    401b:	add    rsp,0xb0
    4022:	mov    rsp,rbp
    4025:	pop    rbp
    4026:	ret
    4027:	mov    r15,rdi
    402a:	call   402f <botlish_fn_29+0x3df>
			402b: R_X86_64_PLT32	rt_stack_overflow-0x4
    402f:	xor    rax,rax
    4032:	mov    rbx,QWORD PTR [rsp+0x80]
    403a:	mov    r12,QWORD PTR [rsp+0x88]
    4042:	mov    r13,QWORD PTR [rsp+0x90]
    404a:	mov    r14,QWORD PTR [rsp+0x98]
    4052:	mov    r15,QWORD PTR [rsp+0xa0]
    405a:	add    rsp,0xb0
    4061:	mov    rsp,rbp
    4064:	pop    rbp
    4065:	ret
    4066:	add    BYTE PTR [rax],al
    4068:	(bad)
    4069:	add    BYTE PTR [rax],al
    406b:	add    BYTE PTR [rax],al
    406d:	add    BYTE PTR [rax],al
	...

0000000000004070 <botlish_entry_29: sample<generic>>:
    4070:	push   rbp
    4071:	mov    rbp,rsp
    4074:	call   4079 <botlish_entry_29+0x9>
			4075: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    4079:	mov    rsp,rbp
    407c:	pop    rbp
    407d:	ret

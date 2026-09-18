; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 17970  (per function: 172 85 85 85 85 548 696 208 184 184 184 184 184 268 299 355 1036 1568 581 389 596 639 1433 945 961 833 1528 1132 1469 1054)
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
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r12+0x8]
      1d:	cmp    rcx,rax
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
      7d:	mov    rax,QWORD PTR [rip+0x0]        # 84 <botlish_fn_0+0x84>
			80: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      84:	call   rax
      86:	xor    rax,rax
      89:	mov    r12,QWORD PTR [rsp]
      8d:	mov    r13,QWORD PTR [rsp+0x8]
      92:	add    rsp,0x10
      96:	mov    rsp,rbp
      99:	pop    rbp
      9a:	ret

000000000000009b <botlish_entry_0: <program entry>>:
      9b:	push   rbp
      9c:	mov    rbp,rsp
      9f:	call   a4 <botlish_entry_0+0x9>
			a0: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a4:	mov    rsp,rbp
      a7:	pop    rbp
      a8:	ret

00000000000000a9 <botlish_fn_1: ht_min_capacity<generic>>:
      a9:	push   rbp
      aa:	mov    rbp,rsp
      ad:	mov    r10,QWORD PTR [rdi]
      b0:	mov    r11,QWORD PTR [rdi+0x8]
      b4:	lea    rax,[r10+0x8]
      b8:	cmp    rax,r11
      bb:	ja     dc <botlish_fn_1+0x33>
      c1:	lea    rax,[r10+0x8]
      c5:	mov    QWORD PTR [rdi],rax
      c8:	mov    QWORD PTR [r10],0x0
      cf:	mov    QWORD PTR [rdi],r10
      d2:	mov    eax,0x11
      d7:	mov    rsp,rbp
      da:	pop    rbp
      db:	ret
      dc:	mov    rax,QWORD PTR [rip+0x0]        # e3 <botlish_fn_1+0x3a>
			df: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      e3:	call   rax
      e5:	xor    rax,rax
      e8:	mov    rsp,rbp
      eb:	pop    rbp
      ec:	ret

00000000000000ed <botlish_entry_1: ht_min_capacity<generic>>:
      ed:	push   rbp
      ee:	mov    rbp,rsp
      f1:	call   f6 <botlish_entry_1+0x9>
			f2: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
      f6:	mov    rsp,rbp
      f9:	pop    rbp
      fa:	ret

00000000000000fb <botlish_fn_2: ht_empty_state<generic>>:
      fb:	push   rbp
      fc:	mov    rbp,rsp
      ff:	mov    r10,QWORD PTR [rdi]
     102:	mov    r11,QWORD PTR [rdi+0x8]
     106:	lea    rax,[r10+0x8]
     10a:	cmp    rax,r11
     10d:	ja     12e <botlish_fn_2+0x33>
     113:	lea    rax,[r10+0x8]
     117:	mov    QWORD PTR [rdi],rax
     11a:	mov    QWORD PTR [r10],0x0
     121:	mov    QWORD PTR [rdi],r10
     124:	mov    eax,0x1
     129:	mov    rsp,rbp
     12c:	pop    rbp
     12d:	ret
     12e:	mov    rax,QWORD PTR [rip+0x0]        # 135 <botlish_fn_2+0x3a>
			131: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     135:	call   rax
     137:	xor    rax,rax
     13a:	mov    rsp,rbp
     13d:	pop    rbp
     13e:	ret

000000000000013f <botlish_entry_2: ht_empty_state<generic>>:
     13f:	push   rbp
     140:	mov    rbp,rsp
     143:	call   148 <botlish_entry_2+0x9>
			144: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     148:	mov    rsp,rbp
     14b:	pop    rbp
     14c:	ret

000000000000014d <botlish_fn_3: ht_occupied_state<generic>>:
     14d:	push   rbp
     14e:	mov    rbp,rsp
     151:	mov    r10,QWORD PTR [rdi]
     154:	mov    r11,QWORD PTR [rdi+0x8]
     158:	lea    rax,[r10+0x8]
     15c:	cmp    rax,r11
     15f:	ja     180 <botlish_fn_3+0x33>
     165:	lea    rax,[r10+0x8]
     169:	mov    QWORD PTR [rdi],rax
     16c:	mov    QWORD PTR [r10],0x0
     173:	mov    QWORD PTR [rdi],r10
     176:	mov    eax,0x3
     17b:	mov    rsp,rbp
     17e:	pop    rbp
     17f:	ret
     180:	mov    rax,QWORD PTR [rip+0x0]        # 187 <botlish_fn_3+0x3a>
			183: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     187:	call   rax
     189:	xor    rax,rax
     18c:	mov    rsp,rbp
     18f:	pop    rbp
     190:	ret

0000000000000191 <botlish_entry_3: ht_occupied_state<generic>>:
     191:	push   rbp
     192:	mov    rbp,rsp
     195:	call   19a <botlish_entry_3+0x9>
			196: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     19a:	mov    rsp,rbp
     19d:	pop    rbp
     19e:	ret

000000000000019f <botlish_fn_4: ht_tombstone_state<generic>>:
     19f:	push   rbp
     1a0:	mov    rbp,rsp
     1a3:	mov    r10,QWORD PTR [rdi]
     1a6:	mov    r11,QWORD PTR [rdi+0x8]
     1aa:	lea    rax,[r10+0x8]
     1ae:	cmp    rax,r11
     1b1:	ja     1d2 <botlish_fn_4+0x33>
     1b7:	lea    rax,[r10+0x8]
     1bb:	mov    QWORD PTR [rdi],rax
     1be:	mov    QWORD PTR [r10],0x0
     1c5:	mov    QWORD PTR [rdi],r10
     1c8:	mov    eax,0x5
     1cd:	mov    rsp,rbp
     1d0:	pop    rbp
     1d1:	ret
     1d2:	mov    rax,QWORD PTR [rip+0x0]        # 1d9 <botlish_fn_4+0x3a>
			1d5: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     1d9:	call   rax
     1db:	xor    rax,rax
     1de:	mov    rsp,rbp
     1e1:	pop    rbp
     1e2:	ret

00000000000001e3 <botlish_entry_4: ht_tombstone_state<generic>>:
     1e3:	push   rbp
     1e4:	mov    rbp,rsp
     1e7:	call   1ec <botlish_entry_4+0x9>
			1e8: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
     1ec:	mov    rsp,rbp
     1ef:	pop    rbp
     1f0:	ret
     1f1:	add    BYTE PTR [rax],al
     1f3:	add    BYTE PTR [rax],al
     1f5:	add    BYTE PTR [rax],al
	...

00000000000001f8 <botlish_fn_5: ht_fill_empty<mutarray, int, int>>:
     1f8:	push   rbp
     1f9:	mov    rbp,rsp
     1fc:	sub    rsp,0x30
     200:	mov    QWORD PTR [rsp],rbx
     204:	mov    QWORD PTR [rsp+0x8],r12
     209:	mov    QWORD PTR [rsp+0x10],r13
     20e:	mov    QWORD PTR [rsp+0x18],r14
     213:	mov    QWORD PTR [rsp+0x20],r15
     218:	mov    r13,QWORD PTR [rdi]
     21b:	mov    r8,QWORD PTR [rdi+0x8]
     21f:	lea    rax,[r13+0x20]
     223:	cmp    rax,r8
     226:	ja     3b7 <botlish_fn_5+0x1bf>
     22c:	lea    rax,[r13+0x20]
     230:	mov    QWORD PTR [rdi],rax
     233:	mov    r14,rdi
     236:	mov    QWORD PTR [r13+0x0],0x0
     23e:	mov    QWORD PTR [r13+0x8],0x0
     246:	mov    QWORD PTR [r13+0x10],0x0
     24e:	mov    QWORD PTR [r13+0x18],0x0
     256:	mov    QWORD PTR [r13+0x0],rsi
     25a:	mov    r12,rsi
     25d:	mov    QWORD PTR [r13+0x8],rdx
     261:	mov    QWORD PTR [r13+0x10],rcx
     265:	mov    rbx,rcx
     268:	mov    rsi,rdx
     26b:	mov    rax,rsi
     26e:	and    rax,rbx
     271:	mov    r15,rsi
     274:	test   rax,0x1
     27a:	jne    2a7 <botlish_fn_5+0xaf>
     280:	mov    rax,QWORD PTR [rip+0x0]        # 287 <botlish_fn_5+0x8f>
			283: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     287:	mov    rdx,rbx
     28a:	mov    rsi,r15
     28d:	mov    rdi,r14
     290:	call   rax
     292:	mov    ecx,0x2
     297:	test   rax,rax
     29a:	cmovge rcx,QWORD PTR [rip+0x146]        # 3e8 <botlish_fn_5+0x1f0>
     2a2:	jmp    2ba <botlish_fn_5+0xc2>
     2a7:	mov    ecx,0x2
     2ac:	mov    rsi,r15
     2af:	cmp    rsi,rbx
     2b2:	cmovge rcx,QWORD PTR [rip+0x12e]        # 3e8 <botlish_fn_5+0x1f0>
     2ba:	cmp    rcx,0x6
     2be:	je     38b <botlish_fn_5+0x193>
     2c4:	mov    rdi,r14
     2c7:	call   2cc <botlish_fn_5+0xd4>
			2c8: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     2cc:	test   rax,rax
     2cf:	mov    rcx,rax
     2d2:	jne    2e0 <botlish_fn_5+0xe8>
     2d8:	mov    rdi,r14
     2db:	jmp    2fe <botlish_fn_5+0x106>
     2e0:	mov    rax,QWORD PTR [rip+0x0]        # 2e7 <botlish_fn_5+0xef>
			2e3: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     2e7:	mov    rdx,r15
     2ea:	mov    rsi,r12
     2ed:	mov    rdi,r14
     2f0:	call   rax
     2f2:	test   rax,rax
     2f5:	jne    328 <botlish_fn_5+0x130>
     2fb:	mov    rdi,r14
     2fe:	mov    rdi,r14
     301:	mov    QWORD PTR [rdi],r13
     304:	xor    rax,rax
     307:	mov    rbx,QWORD PTR [rsp]
     30b:	mov    r12,QWORD PTR [rsp+0x8]
     310:	mov    r13,QWORD PTR [rsp+0x10]
     315:	mov    r14,QWORD PTR [rsp+0x18]
     31a:	mov    r15,QWORD PTR [rsp+0x20]
     31f:	add    rsp,0x30
     323:	mov    rsp,rbp
     326:	pop    rbp
     327:	ret
     328:	mov    QWORD PTR [r13+0x18],0x3
     330:	mov    rsi,r15
     333:	test   rsi,0x1
     33a:	je     35f <botlish_fn_5+0x167>
     340:	mov    rsi,r15
     343:	mov    rcx,rsi
     346:	add    rcx,0x2
     34a:	seto   sil
     34e:	test   sil,sil
     351:	jne    35f <botlish_fn_5+0x167>
     357:	mov    r15,rcx
     35a:	jmp    377 <botlish_fn_5+0x17f>
     35f:	mov    edx,0x3
     364:	mov    r8,QWORD PTR [rip+0x0]        # 36b <botlish_fn_5+0x173>
			367: R_X86_64_GOTPCREL	rt_int_add-0x4
     36b:	mov    rsi,r15
     36e:	mov    rdi,r14
     371:	call   r8
     374:	mov    r15,rax
     377:	mov    QWORD PTR [r13+0x0],r12
     37b:	mov    rsi,r15
     37e:	mov    QWORD PTR [r13+0x8],rsi
     382:	mov    QWORD PTR [r13+0x10],rbx
     386:	jmp    26b <botlish_fn_5+0x73>
     38b:	mov    rdi,r14
     38e:	mov    QWORD PTR [rdi],r13
     391:	mov    eax,0xa
     396:	mov    rbx,QWORD PTR [rsp]
     39a:	mov    r12,QWORD PTR [rsp+0x8]
     39f:	mov    r13,QWORD PTR [rsp+0x10]
     3a4:	mov    r14,QWORD PTR [rsp+0x18]
     3a9:	mov    r15,QWORD PTR [rsp+0x20]
     3ae:	add    rsp,0x30
     3b2:	mov    rsp,rbp
     3b5:	pop    rbp
     3b6:	ret
     3b7:	mov    r14,rdi
     3ba:	mov    rax,QWORD PTR [rip+0x0]        # 3c1 <botlish_fn_5+0x1c9>
			3bd: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     3c1:	call   rax
     3c3:	xor    rax,rax
     3c6:	mov    rbx,QWORD PTR [rsp]
     3ca:	mov    r12,QWORD PTR [rsp+0x8]
     3cf:	mov    r13,QWORD PTR [rsp+0x10]
     3d4:	mov    r14,QWORD PTR [rsp+0x18]
     3d9:	mov    r15,QWORD PTR [rsp+0x20]
     3de:	add    rsp,0x30
     3e2:	mov    rsp,rbp
     3e5:	pop    rbp
     3e6:	ret
     3e7:	add    BYTE PTR [rsi],al
     3e9:	add    BYTE PTR [rax],al
     3eb:	add    BYTE PTR [rax],al
     3ed:	add    BYTE PTR [rax],al
	...

00000000000003f0 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     3f0:	push   rbp
     3f1:	mov    rbp,rsp
     3f4:	mov    rsi,QWORD PTR [rdx]
     3f7:	mov    r8,QWORD PTR [rdx+0x8]
     3fb:	mov    rcx,QWORD PTR [rdx+0x10]
     3ff:	mov    rdx,r8
     402:	call   407 <botlish_entry_5+0x17>
			403: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     407:	mov    rsp,rbp
     40a:	pop    rbp
     40b:	ret

000000000000040c <botlish_fn_6: ht_alloc<int>>:
     40c:	push   rbp
     40d:	mov    rbp,rsp
     410:	sub    rsp,0x40
     414:	mov    QWORD PTR [rsp+0x10],rbx
     419:	mov    QWORD PTR [rsp+0x18],r12
     41e:	mov    QWORD PTR [rsp+0x20],r13
     423:	mov    QWORD PTR [rsp+0x28],r14
     428:	mov    QWORD PTR [rsp+0x30],r15
     42d:	mov    rbx,QWORD PTR [rdi]
     430:	mov    rax,QWORD PTR [rdi+0x8]
     434:	lea    rcx,[rbx+0x20]
     438:	cmp    rcx,rax
     43b:	ja     664 <botlish_fn_6+0x258>
     441:	lea    rax,[rbx+0x20]
     445:	mov    QWORD PTR [rdi],rax
     448:	mov    r12,rdi
     44b:	mov    QWORD PTR [rbx],0x0
     452:	mov    QWORD PTR [rbx+0x8],0x0
     45a:	mov    QWORD PTR [rbx+0x10],0x0
     462:	mov    QWORD PTR [rbx+0x18],0x0
     46a:	mov    QWORD PTR [rbx],rsi
     46d:	mov    r13,rsi
     470:	mov    rax,QWORD PTR [rip+0x0]        # 477 <botlish_fn_6+0x6b>
			473: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     477:	mov    rsi,r13
     47a:	mov    rdi,r12
     47d:	call   rax
     47f:	test   rax,rax
     482:	jne    490 <botlish_fn_6+0x84>
     488:	mov    rdi,r12
     48b:	jmp    60d <botlish_fn_6+0x201>
     490:	mov    QWORD PTR [rbx+0x8],rax
     494:	mov    r14,rax
     497:	mov    edx,0x1
     49c:	mov    QWORD PTR [rbx+0x10],0x1
     4a4:	mov    rcx,r13
     4a7:	mov    rsi,r14
     4aa:	mov    rdi,r12
     4ad:	call   4b2 <botlish_fn_6+0xa6>
			4ae: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     4b2:	test   rax,rax
     4b5:	jne    4c3 <botlish_fn_6+0xb7>
     4bb:	mov    rdi,r12
     4be:	jmp    60d <botlish_fn_6+0x201>
     4c3:	mov    rax,QWORD PTR [rip+0x0]        # 4ca <botlish_fn_6+0xbe>
			4c6: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     4ca:	mov    rsi,r13
     4cd:	mov    rdi,r12
     4d0:	call   rax
     4d2:	test   rax,rax
     4d5:	jne    4e3 <botlish_fn_6+0xd7>
     4db:	mov    rdi,r12
     4de:	jmp    60d <botlish_fn_6+0x201>
     4e3:	mov    QWORD PTR [rbx+0x10],rax
     4e7:	mov    r15,rax
     4ea:	mov    rax,QWORD PTR [rip+0x0]        # 4f1 <botlish_fn_6+0xe5>
			4ed: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     4f1:	mov    rsi,r13
     4f4:	mov    rdi,r12
     4f7:	call   rax
     4f9:	test   rax,rax
     4fc:	jne    50a <botlish_fn_6+0xfe>
     502:	mov    rdi,r12
     505:	jmp    60d <botlish_fn_6+0x201>
     50a:	mov    QWORD PTR [rbx],rax
     50d:	mov    r13,rax
     510:	mov    esi,0xb
     515:	mov    QWORD PTR [rbx+0x18],0xb
     51d:	mov    r8,QWORD PTR [rip+0x0]        # 524 <botlish_fn_6+0x118>
			520: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     524:	mov    rdi,r12
     527:	call   r8
     52a:	test   rax,rax
     52d:	mov    QWORD PTR [rsp],rax
     531:	jne    53f <botlish_fn_6+0x133>
     537:	mov    rdi,r12
     53a:	jmp    60d <botlish_fn_6+0x201>
     53f:	mov    edx,0x1
     544:	mov    r8,QWORD PTR [rip+0x0]        # 54b <botlish_fn_6+0x13f>
			547: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     54b:	mov    rcx,r14
     54e:	mov    rsi,QWORD PTR [rsp]
     552:	mov    rdi,r12
     555:	call   r8
     558:	test   rax,rax
     55b:	jne    569 <botlish_fn_6+0x15d>
     561:	mov    rdi,r12
     564:	jmp    60d <botlish_fn_6+0x201>
     569:	mov    edx,0x3
     56e:	mov    r9,QWORD PTR [rip+0x0]        # 575 <botlish_fn_6+0x169>
			571: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     575:	mov    rcx,r15
     578:	mov    rsi,QWORD PTR [rsp]
     57c:	mov    rdi,r12
     57f:	call   r9
     582:	test   rax,rax
     585:	jne    593 <botlish_fn_6+0x187>
     58b:	mov    rdi,r12
     58e:	jmp    60d <botlish_fn_6+0x201>
     593:	mov    edx,0x5
     598:	mov    rax,QWORD PTR [rip+0x0]        # 59f <botlish_fn_6+0x193>
			59b: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     59f:	mov    rcx,r13
     5a2:	mov    rsi,QWORD PTR [rsp]
     5a6:	mov    rdi,r12
     5a9:	call   rax
     5ab:	test   rax,rax
     5ae:	jne    5bc <botlish_fn_6+0x1b0>
     5b4:	mov    rdi,r12
     5b7:	jmp    60d <botlish_fn_6+0x201>
     5bc:	mov    edx,0x7
     5c1:	mov    ecx,0x1
     5c6:	mov    rax,QWORD PTR [rip+0x0]        # 5cd <botlish_fn_6+0x1c1>
			5c9: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     5cd:	mov    rsi,QWORD PTR [rsp]
     5d1:	mov    rdi,r12
     5d4:	call   rax
     5d6:	test   rax,rax
     5d9:	jne    5e7 <botlish_fn_6+0x1db>
     5df:	mov    rdi,r12
     5e2:	jmp    60d <botlish_fn_6+0x201>
     5e7:	mov    edx,0x9
     5ec:	mov    ecx,0x1
     5f1:	mov    rax,QWORD PTR [rip+0x0]        # 5f8 <botlish_fn_6+0x1ec>
			5f4: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     5f8:	mov    rsi,QWORD PTR [rsp]
     5fc:	mov    rdi,r12
     5ff:	call   rax
     601:	test   rax,rax
     604:	jne    638 <botlish_fn_6+0x22c>
     60a:	mov    rdi,r12
     60d:	mov    rdi,r12
     610:	mov    QWORD PTR [rdi],rbx
     613:	xor    rax,rax
     616:	mov    rbx,QWORD PTR [rsp+0x10]
     61b:	mov    r12,QWORD PTR [rsp+0x18]
     620:	mov    r13,QWORD PTR [rsp+0x20]
     625:	mov    r14,QWORD PTR [rsp+0x28]
     62a:	mov    r15,QWORD PTR [rsp+0x30]
     62f:	add    rsp,0x40
     633:	mov    rsp,rbp
     636:	pop    rbp
     637:	ret
     638:	mov    rdi,r12
     63b:	mov    QWORD PTR [rdi],rbx
     63e:	mov    rax,QWORD PTR [rsp]
     642:	mov    rbx,QWORD PTR [rsp+0x10]
     647:	mov    r12,QWORD PTR [rsp+0x18]
     64c:	mov    r13,QWORD PTR [rsp+0x20]
     651:	mov    r14,QWORD PTR [rsp+0x28]
     656:	mov    r15,QWORD PTR [rsp+0x30]
     65b:	add    rsp,0x40
     65f:	mov    rsp,rbp
     662:	pop    rbp
     663:	ret
     664:	mov    r12,rdi
     667:	mov    rax,QWORD PTR [rip+0x0]        # 66e <botlish_fn_6+0x262>
			66a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     66e:	call   rax
     670:	xor    rax,rax
     673:	mov    rbx,QWORD PTR [rsp+0x10]
     678:	mov    r12,QWORD PTR [rsp+0x18]
     67d:	mov    r13,QWORD PTR [rsp+0x20]
     682:	mov    r14,QWORD PTR [rsp+0x28]
     687:	mov    r15,QWORD PTR [rsp+0x30]
     68c:	add    rsp,0x40
     690:	mov    rsp,rbp
     693:	pop    rbp
     694:	ret

0000000000000695 <botlish_entry_6: ht_alloc<int>>:
     695:	push   rbp
     696:	mov    rbp,rsp
     699:	mov    rsi,QWORD PTR [rdx]
     69c:	call   6a1 <botlish_entry_6+0xc>
			69d: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     6a1:	mov    rsp,rbp
     6a4:	pop    rbp
     6a5:	ret

00000000000006a6 <botlish_fn_7: ht_new<generic>>:
     6a6:	push   rbp
     6a7:	mov    rbp,rsp
     6aa:	sub    rsp,0x10
     6ae:	mov    QWORD PTR [rsp],r13
     6b2:	mov    QWORD PTR [rsp+0x8],r14
     6b7:	mov    r13,QWORD PTR [rdi]
     6ba:	mov    rax,QWORD PTR [rdi+0x8]
     6be:	lea    rcx,[r13+0x8]
     6c2:	cmp    rcx,rax
     6c5:	ja     744 <botlish_fn_7+0x9e>
     6cb:	lea    rax,[r13+0x8]
     6cf:	mov    QWORD PTR [rdi],rax
     6d2:	mov    r14,rdi
     6d5:	mov    QWORD PTR [r13+0x0],0x0
     6dd:	mov    rdi,r14
     6e0:	call   6e5 <botlish_fn_7+0x3f>
			6e1: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     6e5:	test   rax,rax
     6e8:	jne    6f6 <botlish_fn_7+0x50>
     6ee:	mov    rdi,r14
     6f1:	jmp    711 <botlish_fn_7+0x6b>
     6f6:	mov    QWORD PTR [r13+0x0],rax
     6fa:	mov    rsi,rax
     6fd:	mov    rdi,r14
     700:	call   705 <botlish_fn_7+0x5f>
			701: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     705:	test   rax,rax
     708:	jne    72c <botlish_fn_7+0x86>
     70e:	mov    rdi,r14
     711:	mov    rdi,r14
     714:	mov    QWORD PTR [rdi],r13
     717:	xor    rax,rax
     71a:	mov    r13,QWORD PTR [rsp]
     71e:	mov    r14,QWORD PTR [rsp+0x8]
     723:	add    rsp,0x10
     727:	mov    rsp,rbp
     72a:	pop    rbp
     72b:	ret
     72c:	mov    rdi,r14
     72f:	mov    QWORD PTR [rdi],r13
     732:	mov    r13,QWORD PTR [rsp]
     736:	mov    r14,QWORD PTR [rsp+0x8]
     73b:	add    rsp,0x10
     73f:	mov    rsp,rbp
     742:	pop    rbp
     743:	ret
     744:	mov    r14,rdi
     747:	mov    rax,QWORD PTR [rip+0x0]        # 74e <botlish_fn_7+0xa8>
			74a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     74e:	call   rax
     750:	xor    rax,rax
     753:	mov    r13,QWORD PTR [rsp]
     757:	mov    r14,QWORD PTR [rsp+0x8]
     75c:	add    rsp,0x10
     760:	mov    rsp,rbp
     763:	pop    rbp
     764:	ret

0000000000000765 <botlish_entry_7: ht_new<generic>>:
     765:	push   rbp
     766:	mov    rbp,rsp
     769:	call   76e <botlish_entry_7+0x9>
			76a: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     76e:	mov    rsp,rbp
     771:	pop    rbp
     772:	ret

0000000000000773 <botlish_fn_8: ht_controls<mutarray>>:
     773:	push   rbp
     774:	mov    rbp,rsp
     777:	sub    rsp,0x10
     77b:	mov    QWORD PTR [rsp],rbx
     77f:	mov    QWORD PTR [rsp+0x8],r15
     784:	mov    r15,QWORD PTR [rdi]
     787:	mov    rax,QWORD PTR [rdi+0x8]
     78b:	lea    rcx,[r15+0x8]
     78f:	cmp    rcx,rax
     792:	ja     7f6 <botlish_fn_8+0x83>
     798:	lea    rax,[r15+0x8]
     79c:	mov    QWORD PTR [rdi],rax
     79f:	mov    rbx,rdi
     7a2:	mov    QWORD PTR [r15],0x0
     7a9:	mov    edx,0x1
     7ae:	mov    rax,QWORD PTR [rip+0x0]        # 7b5 <botlish_fn_8+0x42>
			7b1: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
     7b5:	mov    rdi,rbx
     7b8:	call   rax
     7ba:	test   rax,rax
     7bd:	jne    7de <botlish_fn_8+0x6b>
     7c3:	mov    rdi,rbx
     7c6:	mov    QWORD PTR [rdi],r15
     7c9:	xor    rax,rax
     7cc:	mov    rbx,QWORD PTR [rsp]
     7d0:	mov    r15,QWORD PTR [rsp+0x8]
     7d5:	add    rsp,0x10
     7d9:	mov    rsp,rbp
     7dc:	pop    rbp
     7dd:	ret
     7de:	mov    rdi,rbx
     7e1:	mov    QWORD PTR [rdi],r15
     7e4:	mov    rbx,QWORD PTR [rsp]
     7e8:	mov    r15,QWORD PTR [rsp+0x8]
     7ed:	add    rsp,0x10
     7f1:	mov    rsp,rbp
     7f4:	pop    rbp
     7f5:	ret
     7f6:	mov    rax,QWORD PTR [rip+0x0]        # 7fd <botlish_fn_8+0x8a>
			7f9: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     7fd:	call   rax
     7ff:	xor    rax,rax
     802:	mov    rbx,QWORD PTR [rsp]
     806:	mov    r15,QWORD PTR [rsp+0x8]
     80b:	add    rsp,0x10
     80f:	mov    rsp,rbp
     812:	pop    rbp
     813:	ret

0000000000000814 <botlish_entry_8: ht_controls<mutarray>>:
     814:	push   rbp
     815:	mov    rbp,rsp
     818:	mov    rsi,QWORD PTR [rdx]
     81b:	call   820 <botlish_entry_8+0xc>
			81c: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     820:	mov    rsp,rbp
     823:	pop    rbp
     824:	ret

0000000000000825 <botlish_fn_9: ht_keys<mutarray>>:
     825:	push   rbp
     826:	mov    rbp,rsp
     829:	sub    rsp,0x10
     82d:	mov    QWORD PTR [rsp],rbx
     831:	mov    QWORD PTR [rsp+0x8],r15
     836:	mov    r15,QWORD PTR [rdi]
     839:	mov    rax,QWORD PTR [rdi+0x8]
     83d:	lea    rcx,[r15+0x8]
     841:	cmp    rcx,rax
     844:	ja     8a8 <botlish_fn_9+0x83>
     84a:	lea    rax,[r15+0x8]
     84e:	mov    QWORD PTR [rdi],rax
     851:	mov    rbx,rdi
     854:	mov    QWORD PTR [r15],0x0
     85b:	mov    edx,0x3
     860:	mov    rax,QWORD PTR [rip+0x0]        # 867 <botlish_fn_9+0x42>
			863: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
     867:	mov    rdi,rbx
     86a:	call   rax
     86c:	test   rax,rax
     86f:	jne    890 <botlish_fn_9+0x6b>
     875:	mov    rdi,rbx
     878:	mov    QWORD PTR [rdi],r15
     87b:	xor    rax,rax
     87e:	mov    rbx,QWORD PTR [rsp]
     882:	mov    r15,QWORD PTR [rsp+0x8]
     887:	add    rsp,0x10
     88b:	mov    rsp,rbp
     88e:	pop    rbp
     88f:	ret
     890:	mov    rdi,rbx
     893:	mov    QWORD PTR [rdi],r15
     896:	mov    rbx,QWORD PTR [rsp]
     89a:	mov    r15,QWORD PTR [rsp+0x8]
     89f:	add    rsp,0x10
     8a3:	mov    rsp,rbp
     8a6:	pop    rbp
     8a7:	ret
     8a8:	mov    rax,QWORD PTR [rip+0x0]        # 8af <botlish_fn_9+0x8a>
			8ab: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     8af:	call   rax
     8b1:	xor    rax,rax
     8b4:	mov    rbx,QWORD PTR [rsp]
     8b8:	mov    r15,QWORD PTR [rsp+0x8]
     8bd:	add    rsp,0x10
     8c1:	mov    rsp,rbp
     8c4:	pop    rbp
     8c5:	ret

00000000000008c6 <botlish_entry_9: ht_keys<mutarray>>:
     8c6:	push   rbp
     8c7:	mov    rbp,rsp
     8ca:	mov    rsi,QWORD PTR [rdx]
     8cd:	call   8d2 <botlish_entry_9+0xc>
			8ce: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     8d2:	mov    rsp,rbp
     8d5:	pop    rbp
     8d6:	ret

00000000000008d7 <botlish_fn_10: ht_values<mutarray>>:
     8d7:	push   rbp
     8d8:	mov    rbp,rsp
     8db:	sub    rsp,0x10
     8df:	mov    QWORD PTR [rsp],rbx
     8e3:	mov    QWORD PTR [rsp+0x8],r15
     8e8:	mov    r15,QWORD PTR [rdi]
     8eb:	mov    rax,QWORD PTR [rdi+0x8]
     8ef:	lea    rcx,[r15+0x8]
     8f3:	cmp    rcx,rax
     8f6:	ja     95a <botlish_fn_10+0x83>
     8fc:	lea    rax,[r15+0x8]
     900:	mov    QWORD PTR [rdi],rax
     903:	mov    rbx,rdi
     906:	mov    QWORD PTR [r15],0x0
     90d:	mov    edx,0x5
     912:	mov    rax,QWORD PTR [rip+0x0]        # 919 <botlish_fn_10+0x42>
			915: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
     919:	mov    rdi,rbx
     91c:	call   rax
     91e:	test   rax,rax
     921:	jne    942 <botlish_fn_10+0x6b>
     927:	mov    rdi,rbx
     92a:	mov    QWORD PTR [rdi],r15
     92d:	xor    rax,rax
     930:	mov    rbx,QWORD PTR [rsp]
     934:	mov    r15,QWORD PTR [rsp+0x8]
     939:	add    rsp,0x10
     93d:	mov    rsp,rbp
     940:	pop    rbp
     941:	ret
     942:	mov    rdi,rbx
     945:	mov    QWORD PTR [rdi],r15
     948:	mov    rbx,QWORD PTR [rsp]
     94c:	mov    r15,QWORD PTR [rsp+0x8]
     951:	add    rsp,0x10
     955:	mov    rsp,rbp
     958:	pop    rbp
     959:	ret
     95a:	mov    rax,QWORD PTR [rip+0x0]        # 961 <botlish_fn_10+0x8a>
			95d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     961:	call   rax
     963:	xor    rax,rax
     966:	mov    rbx,QWORD PTR [rsp]
     96a:	mov    r15,QWORD PTR [rsp+0x8]
     96f:	add    rsp,0x10
     973:	mov    rsp,rbp
     976:	pop    rbp
     977:	ret

0000000000000978 <botlish_entry_10: ht_values<mutarray>>:
     978:	push   rbp
     979:	mov    rbp,rsp
     97c:	mov    rsi,QWORD PTR [rdx]
     97f:	call   984 <botlish_entry_10+0xc>
			980: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     984:	mov    rsp,rbp
     987:	pop    rbp
     988:	ret

0000000000000989 <botlish_fn_11: ht_size<mutarray>>:
     989:	push   rbp
     98a:	mov    rbp,rsp
     98d:	sub    rsp,0x10
     991:	mov    QWORD PTR [rsp],rbx
     995:	mov    QWORD PTR [rsp+0x8],r15
     99a:	mov    r15,QWORD PTR [rdi]
     99d:	mov    rax,QWORD PTR [rdi+0x8]
     9a1:	lea    rcx,[r15+0x8]
     9a5:	cmp    rcx,rax
     9a8:	ja     a0c <botlish_fn_11+0x83>
     9ae:	lea    rax,[r15+0x8]
     9b2:	mov    QWORD PTR [rdi],rax
     9b5:	mov    rbx,rdi
     9b8:	mov    QWORD PTR [r15],0x0
     9bf:	mov    edx,0x7
     9c4:	mov    rax,QWORD PTR [rip+0x0]        # 9cb <botlish_fn_11+0x42>
			9c7: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
     9cb:	mov    rdi,rbx
     9ce:	call   rax
     9d0:	test   rax,rax
     9d3:	jne    9f4 <botlish_fn_11+0x6b>
     9d9:	mov    rdi,rbx
     9dc:	mov    QWORD PTR [rdi],r15
     9df:	xor    rax,rax
     9e2:	mov    rbx,QWORD PTR [rsp]
     9e6:	mov    r15,QWORD PTR [rsp+0x8]
     9eb:	add    rsp,0x10
     9ef:	mov    rsp,rbp
     9f2:	pop    rbp
     9f3:	ret
     9f4:	mov    rdi,rbx
     9f7:	mov    QWORD PTR [rdi],r15
     9fa:	mov    rbx,QWORD PTR [rsp]
     9fe:	mov    r15,QWORD PTR [rsp+0x8]
     a03:	add    rsp,0x10
     a07:	mov    rsp,rbp
     a0a:	pop    rbp
     a0b:	ret
     a0c:	mov    rax,QWORD PTR [rip+0x0]        # a13 <botlish_fn_11+0x8a>
			a0f: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     a13:	call   rax
     a15:	xor    rax,rax
     a18:	mov    rbx,QWORD PTR [rsp]
     a1c:	mov    r15,QWORD PTR [rsp+0x8]
     a21:	add    rsp,0x10
     a25:	mov    rsp,rbp
     a28:	pop    rbp
     a29:	ret

0000000000000a2a <botlish_entry_11: ht_size<mutarray>>:
     a2a:	push   rbp
     a2b:	mov    rbp,rsp
     a2e:	mov    rsi,QWORD PTR [rdx]
     a31:	call   a36 <botlish_entry_11+0xc>
			a32: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     a36:	mov    rsp,rbp
     a39:	pop    rbp
     a3a:	ret

0000000000000a3b <botlish_fn_12: ht_tombstones<mutarray>>:
     a3b:	push   rbp
     a3c:	mov    rbp,rsp
     a3f:	sub    rsp,0x10
     a43:	mov    QWORD PTR [rsp],rbx
     a47:	mov    QWORD PTR [rsp+0x8],r15
     a4c:	mov    r15,QWORD PTR [rdi]
     a4f:	mov    rax,QWORD PTR [rdi+0x8]
     a53:	lea    rcx,[r15+0x8]
     a57:	cmp    rcx,rax
     a5a:	ja     abe <botlish_fn_12+0x83>
     a60:	lea    rax,[r15+0x8]
     a64:	mov    QWORD PTR [rdi],rax
     a67:	mov    rbx,rdi
     a6a:	mov    QWORD PTR [r15],0x0
     a71:	mov    edx,0x9
     a76:	mov    rax,QWORD PTR [rip+0x0]        # a7d <botlish_fn_12+0x42>
			a79: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
     a7d:	mov    rdi,rbx
     a80:	call   rax
     a82:	test   rax,rax
     a85:	jne    aa6 <botlish_fn_12+0x6b>
     a8b:	mov    rdi,rbx
     a8e:	mov    QWORD PTR [rdi],r15
     a91:	xor    rax,rax
     a94:	mov    rbx,QWORD PTR [rsp]
     a98:	mov    r15,QWORD PTR [rsp+0x8]
     a9d:	add    rsp,0x10
     aa1:	mov    rsp,rbp
     aa4:	pop    rbp
     aa5:	ret
     aa6:	mov    rdi,rbx
     aa9:	mov    QWORD PTR [rdi],r15
     aac:	mov    rbx,QWORD PTR [rsp]
     ab0:	mov    r15,QWORD PTR [rsp+0x8]
     ab5:	add    rsp,0x10
     ab9:	mov    rsp,rbp
     abc:	pop    rbp
     abd:	ret
     abe:	mov    rax,QWORD PTR [rip+0x0]        # ac5 <botlish_fn_12+0x8a>
			ac1: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     ac5:	call   rax
     ac7:	xor    rax,rax
     aca:	mov    rbx,QWORD PTR [rsp]
     ace:	mov    r15,QWORD PTR [rsp+0x8]
     ad3:	add    rsp,0x10
     ad7:	mov    rsp,rbp
     ada:	pop    rbp
     adb:	ret

0000000000000adc <botlish_entry_12: ht_tombstones<mutarray>>:
     adc:	push   rbp
     add:	mov    rbp,rsp
     ae0:	mov    rsi,QWORD PTR [rdx]
     ae3:	call   ae8 <botlish_entry_12+0xc>
			ae4: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     ae8:	mov    rsp,rbp
     aeb:	pop    rbp
     aec:	ret

0000000000000aed <botlish_fn_13: ht_capacity<mutarray>>:
     aed:	push   rbp
     aee:	mov    rbp,rsp
     af1:	sub    rsp,0x10
     af5:	mov    QWORD PTR [rsp],rbx
     af9:	mov    QWORD PTR [rsp+0x8],r12
     afe:	mov    rbx,QWORD PTR [rdi]
     b01:	mov    rax,QWORD PTR [rdi+0x8]
     b05:	lea    rcx,[rbx+0x8]
     b09:	cmp    rcx,rax
     b0c:	ja     bbe <botlish_fn_13+0xd1>
     b12:	lea    rax,[rbx+0x8]
     b16:	mov    QWORD PTR [rdi],rax
     b19:	mov    r12,rdi
     b1c:	mov    QWORD PTR [rbx],rsi
     b1f:	mov    rdi,r12
     b22:	call   b27 <botlish_fn_13+0x3a>
			b23: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     b27:	test   rax,rax
     b2a:	jne    b38 <botlish_fn_13+0x4b>
     b30:	mov    rdi,r12
     b33:	jmp    b7f <botlish_fn_13+0x92>
     b38:	xor    ecx,ecx
     b3a:	test   rax,0x7
     b40:	je     b4e <botlish_fn_13+0x61>
     b46:	mov    rsi,rax
     b49:	jmp    b5c <botlish_fn_13+0x6f>
     b4e:	movzx  rcx,BYTE PTR [rax]
     b52:	mov    rsi,rax
     b55:	rex cmp cl,0x8
     b59:	sete   cl
     b5c:	test   cl,cl
     b5e:	jne    b9a <botlish_fn_13+0xad>
     b64:	mov    rdi,r12
     b67:	mov    rax,QWORD PTR [rdi+0x10]
     b6b:	mov    rcx,QWORD PTR [rax]
     b6e:	mov    edx,0x8
     b73:	mov    rax,QWORD PTR [rip+0x0]        # b7a <botlish_fn_13+0x8d>
			b76: R_X86_64_GOTPCREL	rt_type_error-0x4
     b7a:	call   rax
     b7c:	mov    rdi,r12
     b7f:	mov    rdi,r12
     b82:	mov    QWORD PTR [rdi],rbx
     b85:	xor    rax,rax
     b88:	mov    rbx,QWORD PTR [rsp]
     b8c:	mov    r12,QWORD PTR [rsp+0x8]
     b91:	add    rsp,0x10
     b95:	mov    rsp,rbp
     b98:	pop    rbp
     b99:	ret
     b9a:	mov    rax,QWORD PTR [rip+0x0]        # ba1 <botlish_fn_13+0xb4>
			b9d: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
     ba1:	mov    rdi,r12
     ba4:	call   rax
     ba6:	mov    rdi,r12
     ba9:	mov    QWORD PTR [rdi],rbx
     bac:	mov    rbx,QWORD PTR [rsp]
     bb0:	mov    r12,QWORD PTR [rsp+0x8]
     bb5:	add    rsp,0x10
     bb9:	mov    rsp,rbp
     bbc:	pop    rbp
     bbd:	ret
     bbe:	mov    r12,rdi
     bc1:	mov    rax,QWORD PTR [rip+0x0]        # bc8 <botlish_fn_13+0xdb>
			bc4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     bc8:	call   rax
     bca:	xor    rax,rax
     bcd:	mov    rbx,QWORD PTR [rsp]
     bd1:	mov    r12,QWORD PTR [rsp+0x8]
     bd6:	add    rsp,0x10
     bda:	mov    rsp,rbp
     bdd:	pop    rbp
     bde:	ret

0000000000000bdf <botlish_entry_13: ht_capacity<mutarray>>:
     bdf:	push   rbp
     be0:	mov    rbp,rsp
     be3:	mov    rsi,QWORD PTR [rdx]
     be6:	call   beb <botlish_entry_13+0xc>
			be7: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     beb:	mov    rsp,rbp
     bee:	pop    rbp
     bef:	ret

0000000000000bf0 <botlish_fn_14: ht_probe_start<mutarray, str>>:
     bf0:	push   rbp
     bf1:	mov    rbp,rsp
     bf4:	sub    rsp,0x20
     bf8:	mov    QWORD PTR [rsp],rbx
     bfc:	mov    QWORD PTR [rsp+0x8],r12
     c01:	mov    QWORD PTR [rsp+0x10],r13
     c06:	mov    rbx,QWORD PTR [rdi]
     c09:	mov    rax,QWORD PTR [rdi+0x8]
     c0d:	lea    rcx,[rbx+0x10]
     c11:	cmp    rcx,rax
     c14:	ja     cd7 <botlish_fn_14+0xe7>
     c1a:	lea    rax,[rbx+0x10]
     c1e:	mov    QWORD PTR [rdi],rax
     c21:	mov    r12,rdi
     c24:	mov    QWORD PTR [rbx],0x0
     c2b:	mov    QWORD PTR [rbx+0x8],0x0
     c33:	mov    QWORD PTR [rbx],rsi
     c36:	mov    r13,rsi
     c39:	mov    rax,QWORD PTR [rip+0x0]        # c40 <botlish_fn_14+0x50>
			c3c: R_X86_64_GOTPCREL	rt_hash-0x4
     c40:	mov    rsi,rdx
     c43:	mov    rdi,r12
     c46:	call   rax
     c48:	test   rax,rax
     c4b:	jne    c59 <botlish_fn_14+0x69>
     c51:	mov    rdi,r12
     c54:	jmp    c9a <botlish_fn_14+0xaa>
     c59:	mov    QWORD PTR [rbx+0x8],rax
     c5d:	mov    rsi,r13
     c60:	mov    r13,rax
     c63:	mov    rdi,r12
     c66:	call   c6b <botlish_fn_14+0x7b>
			c67: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     c6b:	test   rax,rax
     c6e:	mov    rdx,rax
     c71:	jne    c7f <botlish_fn_14+0x8f>
     c77:	mov    rdi,r12
     c7a:	jmp    c9a <botlish_fn_14+0xaa>
     c7f:	mov    rax,QWORD PTR [rip+0x0]        # c86 <botlish_fn_14+0x96>
			c82: R_X86_64_GOTPCREL	rt_int_mod-0x4
     c86:	mov    rsi,r13
     c89:	mov    rdi,r12
     c8c:	call   rax
     c8e:	test   rax,rax
     c91:	jne    cba <botlish_fn_14+0xca>
     c97:	mov    rdi,r12
     c9a:	mov    rdi,r12
     c9d:	mov    QWORD PTR [rdi],rbx
     ca0:	xor    rax,rax
     ca3:	mov    rbx,QWORD PTR [rsp]
     ca7:	mov    r12,QWORD PTR [rsp+0x8]
     cac:	mov    r13,QWORD PTR [rsp+0x10]
     cb1:	add    rsp,0x20
     cb5:	mov    rsp,rbp
     cb8:	pop    rbp
     cb9:	ret
     cba:	mov    rdi,r12
     cbd:	mov    QWORD PTR [rdi],rbx
     cc0:	mov    rbx,QWORD PTR [rsp]
     cc4:	mov    r12,QWORD PTR [rsp+0x8]
     cc9:	mov    r13,QWORD PTR [rsp+0x10]
     cce:	add    rsp,0x20
     cd2:	mov    rsp,rbp
     cd5:	pop    rbp
     cd6:	ret
     cd7:	mov    r12,rdi
     cda:	mov    rax,QWORD PTR [rip+0x0]        # ce1 <botlish_fn_14+0xf1>
			cdd: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     ce1:	call   rax
     ce3:	xor    rax,rax
     ce6:	mov    rbx,QWORD PTR [rsp]
     cea:	mov    r12,QWORD PTR [rsp+0x8]
     cef:	mov    r13,QWORD PTR [rsp+0x10]
     cf4:	add    rsp,0x20
     cf8:	mov    rsp,rbp
     cfb:	pop    rbp
     cfc:	ret

0000000000000cfd <botlish_entry_14: ht_probe_start<mutarray, str>>:
     cfd:	push   rbp
     cfe:	mov    rbp,rsp
     d01:	mov    rsi,QWORD PTR [rdx]
     d04:	mov    rdx,QWORD PTR [rdx+0x8]
     d08:	call   d0d <botlish_entry_14+0x10>
			d09: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     d0d:	mov    rsp,rbp
     d10:	pop    rbp
     d11:	ret

0000000000000d12 <botlish_fn_15: ht_probe_next<mutarray, int>>:
     d12:	push   rbp
     d13:	mov    rbp,rsp
     d16:	sub    rsp,0x20
     d1a:	mov    QWORD PTR [rsp],rbx
     d1e:	mov    QWORD PTR [rsp+0x8],r12
     d23:	mov    QWORD PTR [rsp+0x10],r13
     d28:	mov    rbx,QWORD PTR [rdi]
     d2b:	mov    rax,QWORD PTR [rdi+0x8]
     d2f:	lea    rcx,[rbx+0x18]
     d33:	cmp    rcx,rax
     d36:	ja     e31 <botlish_fn_15+0x11f>
     d3c:	lea    rax,[rbx+0x18]
     d40:	mov    QWORD PTR [rdi],rax
     d43:	mov    r12,rdi
     d46:	mov    QWORD PTR [rbx],0x0
     d4d:	mov    QWORD PTR [rbx+0x8],0x0
     d55:	mov    QWORD PTR [rbx+0x10],0x0
     d5d:	mov    QWORD PTR [rbx],rsi
     d60:	mov    r13,rsi
     d63:	mov    QWORD PTR [rbx+0x8],rdx
     d67:	mov    QWORD PTR [rbx+0x10],0x3
     d6f:	test   rdx,0x1
     d76:	jne    d84 <botlish_fn_15+0x72>
     d7c:	mov    rcx,rdx
     d7f:	jmp    d99 <botlish_fn_15+0x87>
     d84:	mov    rsi,rdx
     d87:	add    rsi,0x2
     d8b:	mov    rcx,rdx
     d8e:	seto   al
     d91:	test   al,al
     d93:	je     db0 <botlish_fn_15+0x9e>
     d99:	mov    edx,0x3
     d9e:	mov    rax,QWORD PTR [rip+0x0]        # da5 <botlish_fn_15+0x93>
			da1: R_X86_64_GOTPCREL	rt_int_add-0x4
     da5:	mov    rsi,rcx
     da8:	mov    rdi,r12
     dab:	call   rax
     dad:	mov    rsi,rax
     db0:	mov    QWORD PTR [rbx+0x8],rsi
     db4:	mov    rax,rsi
     db7:	mov    rsi,r13
     dba:	mov    r13,rax
     dbd:	mov    rdi,r12
     dc0:	call   dc5 <botlish_fn_15+0xb3>
			dc1: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     dc5:	test   rax,rax
     dc8:	mov    rdx,rax
     dcb:	jne    dd9 <botlish_fn_15+0xc7>
     dd1:	mov    rdi,r12
     dd4:	jmp    df4 <botlish_fn_15+0xe2>
     dd9:	mov    rax,QWORD PTR [rip+0x0]        # de0 <botlish_fn_15+0xce>
			ddc: R_X86_64_GOTPCREL	rt_int_mod-0x4
     de0:	mov    rsi,r13
     de3:	mov    rdi,r12
     de6:	call   rax
     de8:	test   rax,rax
     deb:	jne    e14 <botlish_fn_15+0x102>
     df1:	mov    rdi,r12
     df4:	mov    rdi,r12
     df7:	mov    QWORD PTR [rdi],rbx
     dfa:	xor    rax,rax
     dfd:	mov    rbx,QWORD PTR [rsp]
     e01:	mov    r12,QWORD PTR [rsp+0x8]
     e06:	mov    r13,QWORD PTR [rsp+0x10]
     e0b:	add    rsp,0x20
     e0f:	mov    rsp,rbp
     e12:	pop    rbp
     e13:	ret
     e14:	mov    rdi,r12
     e17:	mov    QWORD PTR [rdi],rbx
     e1a:	mov    rbx,QWORD PTR [rsp]
     e1e:	mov    r12,QWORD PTR [rsp+0x8]
     e23:	mov    r13,QWORD PTR [rsp+0x10]
     e28:	add    rsp,0x20
     e2c:	mov    rsp,rbp
     e2f:	pop    rbp
     e30:	ret
     e31:	mov    r12,rdi
     e34:	mov    rax,QWORD PTR [rip+0x0]        # e3b <botlish_fn_15+0x129>
			e37: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     e3b:	call   rax
     e3d:	xor    rax,rax
     e40:	mov    rbx,QWORD PTR [rsp]
     e44:	mov    r12,QWORD PTR [rsp+0x8]
     e49:	mov    r13,QWORD PTR [rsp+0x10]
     e4e:	add    rsp,0x20
     e52:	mov    rsp,rbp
     e55:	pop    rbp
     e56:	ret

0000000000000e57 <botlish_entry_15: ht_probe_next<mutarray, int>>:
     e57:	push   rbp
     e58:	mov    rbp,rsp
     e5b:	mov    rsi,QWORD PTR [rdx]
     e5e:	mov    rdx,QWORD PTR [rdx+0x8]
     e62:	call   e67 <botlish_entry_15+0x10>
			e63: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     e67:	mov    rsp,rbp
     e6a:	pop    rbp
     e6b:	ret
     e6c:	add    BYTE PTR [rax],al
	...

0000000000000e70 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     e70:	push   rbp
     e71:	mov    rbp,rsp
     e74:	sub    rsp,0x40
     e78:	mov    QWORD PTR [rsp+0x10],rbx
     e7d:	mov    QWORD PTR [rsp+0x18],r12
     e82:	mov    QWORD PTR [rsp+0x20],r13
     e87:	mov    QWORD PTR [rsp+0x28],r14
     e8c:	mov    QWORD PTR [rsp+0x30],r15
     e91:	mov    r14,QWORD PTR [rdi]
     e94:	mov    r8,QWORD PTR [rdi+0x8]
     e98:	lea    r9,[r14+0x20]
     e9c:	cmp    r9,r8
     e9f:	ja     120f <botlish_fn_16+0x39f>
     ea5:	lea    r8,[r14+0x20]
     ea9:	mov    QWORD PTR [rdi],r8
     eac:	mov    r15,rdi
     eaf:	mov    QWORD PTR [r14],0x0
     eb6:	mov    QWORD PTR [r14+0x8],0x0
     ebe:	mov    QWORD PTR [r14+0x10],0x0
     ec6:	mov    QWORD PTR [r14+0x18],0x0
     ece:	mov    QWORD PTR [r14],rsi
     ed1:	mov    QWORD PTR [r14+0x8],rdx
     ed5:	mov    QWORD PTR [rsp],rdx
     ed9:	mov    QWORD PTR [r14+0x10],rcx
     edd:	mov    rbx,rsi
     ee0:	mov    QWORD PTR [rsp+0x8],rcx
     ee5:	mov    rsi,rbx
     ee8:	mov    rdi,r15
     eeb:	call   ef0 <botlish_fn_16+0x80>
			eec: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     ef0:	test   rax,rax
     ef3:	jne    f01 <botlish_fn_16+0x91>
     ef9:	mov    rdi,r15
     efc:	jmp    116f <botlish_fn_16+0x2ff>
     f01:	xor    ecx,ecx
     f03:	test   rax,0x7
     f09:	je     f17 <botlish_fn_16+0xa7>
     f0f:	mov    rsi,rax
     f12:	jmp    f25 <botlish_fn_16+0xb5>
     f17:	movzx  rcx,BYTE PTR [rax]
     f1b:	mov    rsi,rax
     f1e:	rex cmp cl,0x8
     f22:	sete   cl
     f25:	test   cl,cl
     f27:	jne    f4e <botlish_fn_16+0xde>
     f2d:	mov    rdi,r15
     f30:	mov    rax,QWORD PTR [rdi+0x10]
     f34:	mov    rcx,QWORD PTR [rax+0x8]
     f38:	mov    edx,0x8
     f3d:	mov    rax,QWORD PTR [rip+0x0]        # f44 <botlish_fn_16+0xd4>
			f40: R_X86_64_GOTPCREL	rt_type_error-0x4
     f44:	call   rax
     f46:	mov    rdi,r15
     f49:	jmp    116f <botlish_fn_16+0x2ff>
     f4e:	mov    rax,QWORD PTR [rip+0x0]        # f55 <botlish_fn_16+0xe5>
			f51: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
     f55:	mov    rdx,QWORD PTR [rsp+0x8]
     f5a:	mov    rdi,r15
     f5d:	call   rax
     f5f:	mov    rsi,rax
     f62:	mov    r13,rax
     f65:	test   rax,rsi
     f68:	jne    f76 <botlish_fn_16+0x106>
     f6e:	mov    rdi,r15
     f71:	jmp    116f <botlish_fn_16+0x2ff>
     f76:	mov    rax,r13
     f79:	mov    QWORD PTR [r14+0x18],rax
     f7d:	mov    rdi,r15
     f80:	call   f85 <botlish_fn_16+0x115>
			f81: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     f85:	test   rax,rax
     f88:	jne    f96 <botlish_fn_16+0x126>
     f8e:	mov    rdi,r15
     f91:	jmp    116f <botlish_fn_16+0x2ff>
     f96:	mov    rcx,r13
     f99:	and    rcx,rax
     f9c:	mov    rdx,rax
     f9f:	test   rcx,0x1
     fa6:	jne    fcc <botlish_fn_16+0x15c>
     fac:	mov    rax,QWORD PTR [rip+0x0]        # fb3 <botlish_fn_16+0x143>
			faf: R_X86_64_GOTPCREL	rt_value_eq-0x4
     fb3:	mov    rsi,r13
     fb6:	mov    rdi,r15
     fb9:	call   rax
     fbb:	test   rax,rax
     fbe:	jne    fdc <botlish_fn_16+0x16c>
     fc4:	mov    rdi,r15
     fc7:	jmp    116f <botlish_fn_16+0x2ff>
     fcc:	mov    eax,0x2
     fd1:	cmp    r13,rdx
     fd4:	cmove  rax,QWORD PTR [rip+0x264]        # 1240 <botlish_fn_16+0x3d0>
     fdc:	mov    r12d,0x6
     fe2:	cmp    rax,0x6
     fe6:	je     11e0 <botlish_fn_16+0x370>
     fec:	mov    rdi,r15
     fef:	call   ff4 <botlish_fn_16+0x184>
			ff0: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     ff4:	test   rax,rax
     ff7:	jne    1005 <botlish_fn_16+0x195>
     ffd:	mov    rdi,r15
    1000:	jmp    116f <botlish_fn_16+0x2ff>
    1005:	mov    rcx,r13
    1008:	and    rcx,rax
    100b:	mov    rdx,rax
    100e:	test   rcx,0x1
    1015:	jne    103b <botlish_fn_16+0x1cb>
    101b:	mov    rax,QWORD PTR [rip+0x0]        # 1022 <botlish_fn_16+0x1b2>
			101e: R_X86_64_GOTPCREL	rt_value_eq-0x4
    1022:	mov    rsi,r13
    1025:	mov    rdi,r15
    1028:	call   rax
    102a:	test   rax,rax
    102d:	jne    104e <botlish_fn_16+0x1de>
    1033:	mov    rdi,r15
    1036:	jmp    116f <botlish_fn_16+0x2ff>
    103b:	mov    rsi,r13
    103e:	mov    eax,0x2
    1043:	cmp    rsi,rdx
    1046:	cmove  rax,QWORD PTR [rip+0x1f2]        # 1240 <botlish_fn_16+0x3d0>
    104e:	cmp    rax,0x6
    1052:	je     1067 <botlish_fn_16+0x1f7>
    1058:	mov    r12d,0x2
    105e:	mov    r13,QWORD PTR [rsp]
    1062:	jmp    1149 <botlish_fn_16+0x2d9>
    1067:	mov    rsi,rbx
    106a:	mov    rdi,r15
    106d:	call   1072 <botlish_fn_16+0x202>
			106e: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    1072:	test   rax,rax
    1075:	jne    1083 <botlish_fn_16+0x213>
    107b:	mov    rdi,r15
    107e:	jmp    116f <botlish_fn_16+0x2ff>
    1083:	xor    ecx,ecx
    1085:	test   rax,0x7
    108b:	jne    109c <botlish_fn_16+0x22c>
    1091:	movzx  rdx,BYTE PTR [rax]
    1095:	rex cmp dl,0x8
    1099:	sete   cl
    109c:	test   cl,cl
    109e:	jne    10c9 <botlish_fn_16+0x259>
    10a4:	mov    rdi,r15
    10a7:	mov    rsi,QWORD PTR [rdi+0x10]
    10ab:	mov    rcx,QWORD PTR [rsi+0x8]
    10af:	mov    edx,0x8
    10b4:	mov    r8,QWORD PTR [rip+0x0]        # 10bb <botlish_fn_16+0x24b>
			10b7: R_X86_64_GOTPCREL	rt_type_error-0x4
    10bb:	mov    rsi,rax
    10be:	call   r8
    10c1:	mov    rdi,r15
    10c4:	jmp    116f <botlish_fn_16+0x2ff>
    10c9:	mov    rsi,rax
    10cc:	mov    r8,QWORD PTR [rip+0x0]        # 10d3 <botlish_fn_16+0x263>
			10cf: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    10d3:	mov    rdx,QWORD PTR [rsp+0x8]
    10d8:	mov    rdi,r15
    10db:	call   r8
    10de:	test   rax,rax
    10e1:	jne    10ef <botlish_fn_16+0x27f>
    10e7:	mov    rdi,r15
    10ea:	jmp    116f <botlish_fn_16+0x2ff>
    10ef:	mov    r13,QWORD PTR [rsp]
    10f3:	mov    r10,rax
    10f6:	and    r10,r13
    10f9:	mov    rsi,rax
    10fc:	test   r10,0x1
    1103:	jne    1129 <botlish_fn_16+0x2b9>
    1109:	mov    rax,QWORD PTR [rip+0x0]        # 1110 <botlish_fn_16+0x2a0>
			110c: R_X86_64_GOTPCREL	rt_value_eq-0x4
    1110:	mov    rdx,r13
    1113:	mov    rdi,r15
    1116:	call   rax
    1118:	test   rax,rax
    111b:	jne    1139 <botlish_fn_16+0x2c9>
    1121:	mov    rdi,r15
    1124:	jmp    116f <botlish_fn_16+0x2ff>
    1129:	mov    eax,0x2
    112e:	cmp    rsi,r13
    1131:	cmove  rax,QWORD PTR [rip+0x107]        # 1240 <botlish_fn_16+0x3d0>
    1139:	cmp    rax,0x6
    113d:	je     1149 <botlish_fn_16+0x2d9>
    1143:	mov    r12d,0x2
    1149:	cmp    r12,0x6
    114d:	je     11b3 <botlish_fn_16+0x343>
    1153:	mov    rdx,QWORD PTR [rsp+0x8]
    1158:	mov    rsi,rbx
    115b:	mov    rdi,r15
    115e:	call   1163 <botlish_fn_16+0x2f3>
			115f: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    1163:	test   rax,rax
    1166:	jne    119a <botlish_fn_16+0x32a>
    116c:	mov    rdi,r15
    116f:	mov    rdi,r15
    1172:	mov    QWORD PTR [rdi],r14
    1175:	xor    rax,rax
    1178:	mov    rbx,QWORD PTR [rsp+0x10]
    117d:	mov    r12,QWORD PTR [rsp+0x18]
    1182:	mov    r13,QWORD PTR [rsp+0x20]
    1187:	mov    r14,QWORD PTR [rsp+0x28]
    118c:	mov    r15,QWORD PTR [rsp+0x30]
    1191:	add    rsp,0x40
    1195:	mov    rsp,rbp
    1198:	pop    rbp
    1199:	ret
    119a:	mov    QWORD PTR [r14],rbx
    119d:	mov    QWORD PTR [r14+0x8],r13
    11a1:	mov    QWORD PTR [r14+0x10],rax
    11a5:	mov    QWORD PTR [rsp],r13
    11a9:	mov    QWORD PTR [rsp+0x8],rax
    11ae:	jmp    ee5 <botlish_fn_16+0x75>
    11b3:	mov    rdi,r15
    11b6:	mov    QWORD PTR [rdi],r14
    11b9:	mov    rax,QWORD PTR [rsp+0x8]
    11be:	mov    rbx,QWORD PTR [rsp+0x10]
    11c3:	mov    r12,QWORD PTR [rsp+0x18]
    11c8:	mov    r13,QWORD PTR [rsp+0x20]
    11cd:	mov    r14,QWORD PTR [rsp+0x28]
    11d2:	mov    r15,QWORD PTR [rsp+0x30]
    11d7:	add    rsp,0x40
    11db:	mov    rsp,rbp
    11de:	pop    rbp
    11df:	ret
    11e0:	mov    rdi,r15
    11e3:	mov    QWORD PTR [rdi],r14
    11e6:	mov    rax,0xffffffffffffffff
    11ed:	mov    rbx,QWORD PTR [rsp+0x10]
    11f2:	mov    r12,QWORD PTR [rsp+0x18]
    11f7:	mov    r13,QWORD PTR [rsp+0x20]
    11fc:	mov    r14,QWORD PTR [rsp+0x28]
    1201:	mov    r15,QWORD PTR [rsp+0x30]
    1206:	add    rsp,0x40
    120a:	mov    rsp,rbp
    120d:	pop    rbp
    120e:	ret
    120f:	mov    r15,rdi
    1212:	mov    rax,QWORD PTR [rip+0x0]        # 1219 <botlish_fn_16+0x3a9>
			1215: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1219:	call   rax
    121b:	xor    rax,rax
    121e:	mov    rbx,QWORD PTR [rsp+0x10]
    1223:	mov    r12,QWORD PTR [rsp+0x18]
    1228:	mov    r13,QWORD PTR [rsp+0x20]
    122d:	mov    r14,QWORD PTR [rsp+0x28]
    1232:	mov    r15,QWORD PTR [rsp+0x30]
    1237:	add    rsp,0x40
    123b:	mov    rsp,rbp
    123e:	pop    rbp
    123f:	ret
    1240:	(bad)
    1241:	add    BYTE PTR [rax],al
    1243:	add    BYTE PTR [rax],al
    1245:	add    BYTE PTR [rax],al
	...

0000000000001248 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
    1248:	push   rbp
    1249:	mov    rbp,rsp
    124c:	mov    rsi,QWORD PTR [rdx]
    124f:	mov    r8,QWORD PTR [rdx+0x8]
    1253:	mov    rcx,QWORD PTR [rdx+0x10]
    1257:	mov    rdx,r8
    125a:	call   125f <botlish_entry_16+0x17>
			125b: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    125f:	mov    rsp,rbp
    1262:	pop    rbp
    1263:	ret
    1264:	add    BYTE PTR [rax],al
	...

0000000000001268 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
    1268:	push   rbp
    1269:	mov    rbp,rsp
    126c:	sub    rsp,0x50
    1270:	mov    QWORD PTR [rsp+0x20],rbx
    1275:	mov    QWORD PTR [rsp+0x28],r12
    127a:	mov    QWORD PTR [rsp+0x30],r13
    127f:	mov    QWORD PTR [rsp+0x38],r14
    1284:	mov    QWORD PTR [rsp+0x40],r15
    1289:	mov    r13,QWORD PTR [rdi]
    128c:	mov    rax,QWORD PTR [rdi+0x8]
    1290:	lea    r9,[r13+0x28]
    1294:	cmp    r9,rax
    1297:	ja     180b <botlish_fn_17+0x5a3>
    129d:	lea    rax,[r13+0x28]
    12a1:	mov    QWORD PTR [rdi],rax
    12a4:	mov    QWORD PTR [rsp],rdi
    12a8:	mov    QWORD PTR [r13+0x0],0x0
    12b0:	mov    QWORD PTR [r13+0x8],0x0
    12b8:	mov    QWORD PTR [r13+0x10],0x0
    12c0:	mov    QWORD PTR [r13+0x18],0x0
    12c8:	mov    QWORD PTR [r13+0x20],0x0
    12d0:	mov    QWORD PTR [r13+0x0],rsi
    12d4:	mov    QWORD PTR [r13+0x8],rdx
    12d8:	mov    r14,rdx
    12db:	mov    QWORD PTR [r13+0x10],rcx
    12df:	mov    QWORD PTR [r13+0x18],r8
    12e3:	mov    rbx,rsi
    12e6:	mov    r15,r8
    12e9:	mov    QWORD PTR [rsp+0x8],rcx
    12ee:	mov    rsi,rbx
    12f1:	mov    rdi,QWORD PTR [rsp]
    12f5:	call   12fa <botlish_fn_17+0x92>
			12f6: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    12fa:	test   rax,rax
    12fd:	jne    130c <botlish_fn_17+0xa4>
    1303:	mov    rdi,QWORD PTR [rsp]
    1307:	jmp    16da <botlish_fn_17+0x472>
    130c:	xor    ecx,ecx
    130e:	test   rax,0x7
    1314:	je     1322 <botlish_fn_17+0xba>
    131a:	mov    rsi,rax
    131d:	jmp    1330 <botlish_fn_17+0xc8>
    1322:	movzx  rcx,BYTE PTR [rax]
    1326:	mov    rsi,rax
    1329:	rex cmp cl,0x8
    132d:	sete   cl
    1330:	test   cl,cl
    1332:	jne    135b <botlish_fn_17+0xf3>
    1338:	mov    rdi,QWORD PTR [rsp]
    133c:	mov    rax,QWORD PTR [rdi+0x10]
    1340:	mov    rcx,QWORD PTR [rax+0x8]
    1344:	mov    edx,0x8
    1349:	mov    rax,QWORD PTR [rip+0x0]        # 1350 <botlish_fn_17+0xe8>
			134c: R_X86_64_GOTPCREL	rt_type_error-0x4
    1350:	call   rax
    1352:	mov    rdi,QWORD PTR [rsp]
    1356:	jmp    16da <botlish_fn_17+0x472>
    135b:	mov    rax,QWORD PTR [rip+0x0]        # 1362 <botlish_fn_17+0xfa>
			135e: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    1362:	mov    rdx,QWORD PTR [rsp+0x8]
    1367:	mov    rdi,QWORD PTR [rsp]
    136b:	call   rax
    136d:	mov    rcx,rax
    1370:	mov    QWORD PTR [rsp+0x10],rax
    1375:	test   rax,rcx
    1378:	jne    1387 <botlish_fn_17+0x11f>
    137e:	mov    rdi,QWORD PTR [rsp]
    1382:	jmp    16da <botlish_fn_17+0x472>
    1387:	mov    rax,QWORD PTR [rsp+0x10]
    138c:	mov    QWORD PTR [r13+0x20],rax
    1390:	mov    rdi,QWORD PTR [rsp]
    1394:	call   1399 <botlish_fn_17+0x131>
			1395: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    1399:	test   rax,rax
    139c:	jne    13ab <botlish_fn_17+0x143>
    13a2:	mov    rdi,QWORD PTR [rsp]
    13a6:	jmp    16da <botlish_fn_17+0x472>
    13ab:	mov    rcx,QWORD PTR [rsp+0x10]
    13b0:	mov    rdx,rcx
    13b3:	and    rdx,rax
    13b6:	mov    r10,rax
    13b9:	test   rdx,0x1
    13c0:	jne    13ee <botlish_fn_17+0x186>
    13c6:	mov    r8,QWORD PTR [rip+0x0]        # 13cd <botlish_fn_17+0x165>
			13c9: R_X86_64_GOTPCREL	rt_value_eq-0x4
    13cd:	mov    rdx,r10
    13d0:	mov    rsi,QWORD PTR [rsp+0x10]
    13d5:	mov    rdi,QWORD PTR [rsp]
    13d9:	call   r8
    13dc:	test   rax,rax
    13df:	jne    1406 <botlish_fn_17+0x19e>
    13e5:	mov    rdi,QWORD PTR [rsp]
    13e9:	jmp    16da <botlish_fn_17+0x472>
    13ee:	mov    rdx,r10
    13f1:	mov    eax,0x2
    13f6:	mov    rsi,QWORD PTR [rsp+0x10]
    13fb:	cmp    rsi,rdx
    13fe:	cmove  rax,QWORD PTR [rip+0x43a]        # 1840 <botlish_fn_17+0x5d8>
    1406:	mov    r12d,0x6
    140c:	cmp    rax,0x6
    1410:	je     1758 <botlish_fn_17+0x4f0>
    1416:	mov    rdi,QWORD PTR [rsp]
    141a:	call   141f <botlish_fn_17+0x1b7>
			141b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    141f:	test   rax,rax
    1422:	jne    1431 <botlish_fn_17+0x1c9>
    1428:	mov    rdi,QWORD PTR [rsp]
    142c:	jmp    16da <botlish_fn_17+0x472>
    1431:	mov    rcx,QWORD PTR [rsp+0x10]
    1436:	and    rcx,rax
    1439:	mov    rdx,rax
    143c:	test   rcx,0x1
    1443:	jne    146d <botlish_fn_17+0x205>
    1449:	mov    rax,QWORD PTR [rip+0x0]        # 1450 <botlish_fn_17+0x1e8>
			144c: R_X86_64_GOTPCREL	rt_value_eq-0x4
    1450:	mov    rsi,QWORD PTR [rsp+0x10]
    1455:	mov    rdi,QWORD PTR [rsp]
    1459:	call   rax
    145b:	test   rax,rax
    145e:	jne    1482 <botlish_fn_17+0x21a>
    1464:	mov    rdi,QWORD PTR [rsp]
    1468:	jmp    16da <botlish_fn_17+0x472>
    146d:	mov    eax,0x2
    1472:	mov    rcx,QWORD PTR [rsp+0x10]
    1477:	cmp    rcx,rdx
    147a:	cmove  rax,QWORD PTR [rip+0x3be]        # 1840 <botlish_fn_17+0x5d8>
    1482:	cmp    rax,0x6
    1486:	je     1496 <botlish_fn_17+0x22e>
    148c:	mov    eax,0x2
    1491:	jmp    1586 <botlish_fn_17+0x31e>
    1496:	mov    rsi,rbx
    1499:	mov    rdi,QWORD PTR [rsp]
    149d:	call   14a2 <botlish_fn_17+0x23a>
			149e: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    14a2:	test   rax,rax
    14a5:	jne    14b4 <botlish_fn_17+0x24c>
    14ab:	mov    rdi,QWORD PTR [rsp]
    14af:	jmp    16da <botlish_fn_17+0x472>
    14b4:	xor    ecx,ecx
    14b6:	test   rax,0x7
    14bc:	je     14ca <botlish_fn_17+0x262>
    14c2:	mov    rsi,rax
    14c5:	jmp    14d8 <botlish_fn_17+0x270>
    14ca:	movzx  rcx,BYTE PTR [rax]
    14ce:	mov    rsi,rax
    14d1:	rex cmp cl,0x8
    14d5:	sete   cl
    14d8:	test   cl,cl
    14da:	jne    1503 <botlish_fn_17+0x29b>
    14e0:	mov    rdi,QWORD PTR [rsp]
    14e4:	mov    rax,QWORD PTR [rdi+0x10]
    14e8:	mov    rcx,QWORD PTR [rax+0x8]
    14ec:	mov    edx,0x8
    14f1:	mov    rax,QWORD PTR [rip+0x0]        # 14f8 <botlish_fn_17+0x290>
			14f4: R_X86_64_GOTPCREL	rt_type_error-0x4
    14f8:	call   rax
    14fa:	mov    rdi,QWORD PTR [rsp]
    14fe:	jmp    16da <botlish_fn_17+0x472>
    1503:	mov    rax,QWORD PTR [rip+0x0]        # 150a <botlish_fn_17+0x2a2>
			1506: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    150a:	mov    rdx,QWORD PTR [rsp+0x8]
    150f:	mov    rdi,QWORD PTR [rsp]
    1513:	call   rax
    1515:	test   rax,rax
    1518:	jne    1527 <botlish_fn_17+0x2bf>
    151e:	mov    rdi,QWORD PTR [rsp]
    1522:	jmp    16da <botlish_fn_17+0x472>
    1527:	mov    rcx,rax
    152a:	and    rcx,r14
    152d:	mov    rsi,rax
    1530:	test   rcx,0x1
    1537:	jne    155f <botlish_fn_17+0x2f7>
    153d:	mov    rax,QWORD PTR [rip+0x0]        # 1544 <botlish_fn_17+0x2dc>
			1540: R_X86_64_GOTPCREL	rt_value_eq-0x4
    1544:	mov    rdx,r14
    1547:	mov    rdi,QWORD PTR [rsp]
    154b:	call   rax
    154d:	test   rax,rax
    1550:	jne    156f <botlish_fn_17+0x307>
    1556:	mov    rdi,QWORD PTR [rsp]
    155a:	jmp    16da <botlish_fn_17+0x472>
    155f:	mov    eax,0x2
    1564:	cmp    rsi,r14
    1567:	cmove  rax,QWORD PTR [rip+0x2d1]        # 1840 <botlish_fn_17+0x5d8>
    156f:	cmp    rax,0x6
    1573:	je     1583 <botlish_fn_17+0x31b>
    1579:	mov    eax,0x2
    157e:	jmp    1586 <botlish_fn_17+0x31e>
    1583:	mov    rax,r12
    1586:	cmp    rax,0x6
    158a:	je     172a <botlish_fn_17+0x4c2>
    1590:	mov    rdi,QWORD PTR [rsp]
    1594:	call   1599 <botlish_fn_17+0x331>
			1595: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    1599:	test   rax,rax
    159c:	jne    15ab <botlish_fn_17+0x343>
    15a2:	mov    rdi,QWORD PTR [rsp]
    15a6:	jmp    16da <botlish_fn_17+0x472>
    15ab:	mov    rcx,QWORD PTR [rsp+0x10]
    15b0:	mov    rdx,rcx
    15b3:	and    rdx,rax
    15b6:	mov    rcx,rax
    15b9:	test   rdx,0x1
    15c0:	jne    15ed <botlish_fn_17+0x385>
    15c6:	mov    rax,QWORD PTR [rip+0x0]        # 15cd <botlish_fn_17+0x365>
			15c9: R_X86_64_GOTPCREL	rt_value_eq-0x4
    15cd:	mov    rdx,rcx
    15d0:	mov    rsi,QWORD PTR [rsp+0x10]
    15d5:	mov    rdi,QWORD PTR [rsp]
    15d9:	call   rax
    15db:	test   rax,rax
    15de:	jne    1605 <botlish_fn_17+0x39d>
    15e4:	mov    rdi,QWORD PTR [rsp]
    15e8:	jmp    16da <botlish_fn_17+0x472>
    15ed:	mov    rdx,rcx
    15f0:	mov    rsi,QWORD PTR [rsp+0x10]
    15f5:	mov    eax,0x2
    15fa:	cmp    rsi,rdx
    15fd:	cmove  rax,QWORD PTR [rip+0x23b]        # 1840 <botlish_fn_17+0x5d8>
    1605:	cmp    rax,0x6
    1609:	je     161a <botlish_fn_17+0x3b2>
    160f:	mov    r12d,0x2
    1615:	jmp    1672 <botlish_fn_17+0x40a>
    161a:	test   r15,0x1
    1621:	jne    1652 <botlish_fn_17+0x3ea>
    1627:	mov    edx,0x1
    162c:	mov    r10,QWORD PTR [rip+0x0]        # 1633 <botlish_fn_17+0x3cb>
			162f: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1633:	mov    rsi,r15
    1636:	mov    rdi,QWORD PTR [rsp]
    163a:	call   r10
    163d:	mov    ecx,0x2
    1642:	test   rax,rax
    1645:	cmovl  rcx,QWORD PTR [rip+0x1f3]        # 1840 <botlish_fn_17+0x5d8>
    164d:	jmp    1662 <botlish_fn_17+0x3fa>
    1652:	mov    ecx,0x2
    1657:	test   r15,r15
    165a:	cmovle rcx,QWORD PTR [rip+0x1de]        # 1840 <botlish_fn_17+0x5d8>
    1662:	cmp    rcx,0x6
    1666:	je     1672 <botlish_fn_17+0x40a>
    166c:	mov    r12d,0x2
    1672:	cmp    r12,0x6
    1676:	je     16bc <botlish_fn_17+0x454>
    167c:	mov    rdx,QWORD PTR [rsp+0x8]
    1681:	mov    rsi,rbx
    1684:	mov    rdi,QWORD PTR [rsp]
    1688:	call   168d <botlish_fn_17+0x425>
			1689: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    168d:	test   rax,rax
    1690:	jne    169f <botlish_fn_17+0x437>
    1696:	mov    rdi,QWORD PTR [rsp]
    169a:	jmp    16da <botlish_fn_17+0x472>
    169f:	mov    QWORD PTR [r13+0x0],rbx
    16a3:	mov    QWORD PTR [r13+0x8],r14
    16a7:	mov    QWORD PTR [r13+0x10],rax
    16ab:	mov    rcx,r15
    16ae:	mov    QWORD PTR [r13+0x18],rcx
    16b2:	mov    QWORD PTR [rsp+0x8],rax
    16b7:	jmp    12ee <botlish_fn_17+0x86>
    16bc:	mov    rdx,QWORD PTR [rsp+0x8]
    16c1:	mov    rsi,rbx
    16c4:	mov    rdi,QWORD PTR [rsp]
    16c8:	call   16cd <botlish_fn_17+0x465>
			16c9: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    16cd:	test   rax,rax
    16d0:	jne    1706 <botlish_fn_17+0x49e>
    16d6:	mov    rdi,QWORD PTR [rsp]
    16da:	mov    rdi,QWORD PTR [rsp]
    16de:	mov    QWORD PTR [rdi],r13
    16e1:	xor    rax,rax
    16e4:	mov    rbx,QWORD PTR [rsp+0x20]
    16e9:	mov    r12,QWORD PTR [rsp+0x28]
    16ee:	mov    r13,QWORD PTR [rsp+0x30]
    16f3:	mov    r14,QWORD PTR [rsp+0x38]
    16f8:	mov    r15,QWORD PTR [rsp+0x40]
    16fd:	add    rsp,0x50
    1701:	mov    rsp,rbp
    1704:	pop    rbp
    1705:	ret
    1706:	mov    QWORD PTR [r13+0x0],rbx
    170a:	mov    QWORD PTR [r13+0x8],r14
    170e:	mov    QWORD PTR [r13+0x10],rax
    1712:	mov    rdx,QWORD PTR [rsp+0x8]
    1717:	mov    QWORD PTR [r13+0x18],rdx
    171b:	mov    r15,QWORD PTR [rsp+0x8]
    1720:	mov    QWORD PTR [rsp+0x8],rax
    1725:	jmp    12ee <botlish_fn_17+0x86>
    172a:	mov    rdi,QWORD PTR [rsp]
    172e:	mov    QWORD PTR [rdi],r13
    1731:	mov    rax,QWORD PTR [rsp+0x8]
    1736:	mov    rbx,QWORD PTR [rsp+0x20]
    173b:	mov    r12,QWORD PTR [rsp+0x28]
    1740:	mov    r13,QWORD PTR [rsp+0x30]
    1745:	mov    r14,QWORD PTR [rsp+0x38]
    174a:	mov    r15,QWORD PTR [rsp+0x40]
    174f:	add    rsp,0x50
    1753:	mov    rsp,rbp
    1756:	pop    rbp
    1757:	ret
    1758:	mov    rax,r15
    175b:	test   rax,0x1
    1761:	jne    1791 <botlish_fn_17+0x529>
    1767:	mov    edx,0x1
    176c:	mov    rax,QWORD PTR [rip+0x0]        # 1773 <botlish_fn_17+0x50b>
			176f: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1773:	mov    rsi,r15
    1776:	mov    rdi,QWORD PTR [rsp]
    177a:	call   rax
    177c:	mov    ecx,0x2
    1781:	test   rax,rax
    1784:	cmovge rcx,QWORD PTR [rip+0xb4]        # 1840 <botlish_fn_17+0x5d8>
    178c:	jmp    17a7 <botlish_fn_17+0x53f>
    1791:	mov    ecx,0x2
    1796:	mov    rax,r15
    1799:	mov    rdx,r15
    179c:	test   rax,rdx
    179f:	cmovg  rcx,QWORD PTR [rip+0x99]        # 1840 <botlish_fn_17+0x5d8>
    17a7:	cmp    rcx,0x6
    17ab:	je     17df <botlish_fn_17+0x577>
    17b1:	mov    rdi,QWORD PTR [rsp]
    17b5:	mov    QWORD PTR [rdi],r13
    17b8:	mov    rax,QWORD PTR [rsp+0x8]
    17bd:	mov    rbx,QWORD PTR [rsp+0x20]
    17c2:	mov    r12,QWORD PTR [rsp+0x28]
    17c7:	mov    r13,QWORD PTR [rsp+0x30]
    17cc:	mov    r14,QWORD PTR [rsp+0x38]
    17d1:	mov    r15,QWORD PTR [rsp+0x40]
    17d6:	add    rsp,0x50
    17da:	mov    rsp,rbp
    17dd:	pop    rbp
    17de:	ret
    17df:	mov    rdi,QWORD PTR [rsp]
    17e3:	mov    QWORD PTR [rdi],r13
    17e6:	mov    rax,r15
    17e9:	mov    rbx,QWORD PTR [rsp+0x20]
    17ee:	mov    r12,QWORD PTR [rsp+0x28]
    17f3:	mov    r13,QWORD PTR [rsp+0x30]
    17f8:	mov    r14,QWORD PTR [rsp+0x38]
    17fd:	mov    r15,QWORD PTR [rsp+0x40]
    1802:	add    rsp,0x50
    1806:	mov    rsp,rbp
    1809:	pop    rbp
    180a:	ret
    180b:	mov    QWORD PTR [rsp],rdi
    180f:	mov    rax,QWORD PTR [rip+0x0]        # 1816 <botlish_fn_17+0x5ae>
			1812: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1816:	call   rax
    1818:	xor    rax,rax
    181b:	mov    rbx,QWORD PTR [rsp+0x20]
    1820:	mov    r12,QWORD PTR [rsp+0x28]
    1825:	mov    r13,QWORD PTR [rsp+0x30]
    182a:	mov    r14,QWORD PTR [rsp+0x38]
    182f:	mov    r15,QWORD PTR [rsp+0x40]
    1834:	add    rsp,0x50
    1838:	mov    rsp,rbp
    183b:	pop    rbp
    183c:	ret
    183d:	add    BYTE PTR [rax],al
    183f:	add    BYTE PTR [rsi],al
    1841:	add    BYTE PTR [rax],al
    1843:	add    BYTE PTR [rax],al
    1845:	add    BYTE PTR [rax],al
	...

0000000000001848 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
    1848:	push   rbp
    1849:	mov    rbp,rsp
    184c:	mov    rsi,QWORD PTR [rdx]
    184f:	mov    r9,QWORD PTR [rdx+0x8]
    1853:	mov    rcx,QWORD PTR [rdx+0x10]
    1857:	mov    r8,QWORD PTR [rdx+0x18]
    185b:	mov    rdx,r9
    185e:	call   1863 <botlish_entry_17+0x1b>
			185f: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    1863:	mov    rsp,rbp
    1866:	pop    rbp
    1867:	ret

0000000000001868 <botlish_fn_18: ht_get<mutarray, str>>:
    1868:	push   rbp
    1869:	mov    rbp,rsp
    186c:	sub    rsp,0x20
    1870:	mov    QWORD PTR [rsp],rbx
    1874:	mov    QWORD PTR [rsp+0x8],r12
    1879:	mov    QWORD PTR [rsp+0x10],r13
    187e:	mov    QWORD PTR [rsp+0x18],r14
    1883:	mov    rbx,QWORD PTR [rdi]
    1886:	mov    rax,QWORD PTR [rdi+0x8]
    188a:	lea    rcx,[rbx+0x18]
    188e:	cmp    rcx,rax
    1891:	ja     1a58 <botlish_fn_18+0x1f0>
    1897:	lea    rax,[rbx+0x18]
    189b:	mov    QWORD PTR [rdi],rax
    189e:	mov    r12,rdi
    18a1:	mov    QWORD PTR [rbx],0x0
    18a8:	mov    QWORD PTR [rbx+0x8],0x0
    18b0:	mov    QWORD PTR [rbx+0x10],0x0
    18b8:	mov    QWORD PTR [rbx],rsi
    18bb:	mov    r13,rsi
    18be:	mov    QWORD PTR [rbx+0x8],rdx
    18c2:	mov    r14,rdx
    18c5:	mov    rdx,r14
    18c8:	mov    rsi,r13
    18cb:	mov    rdi,r12
    18ce:	call   18d3 <botlish_fn_18+0x6b>
			18cf: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    18d3:	test   rax,rax
    18d6:	jne    18e4 <botlish_fn_18+0x7c>
    18dc:	mov    rdi,r12
    18df:	jmp    19ea <botlish_fn_18+0x182>
    18e4:	mov    QWORD PTR [rbx+0x10],rax
    18e8:	mov    rcx,rax
    18eb:	mov    rdx,r14
    18ee:	mov    rsi,r13
    18f1:	mov    rdi,r12
    18f4:	call   18f9 <botlish_fn_18+0x91>
			18f5: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    18f9:	mov    rcx,rax
    18fc:	mov    r14,rax
    18ff:	test   rax,rcx
    1902:	jne    1910 <botlish_fn_18+0xa8>
    1908:	mov    rdi,r12
    190b:	jmp    19ea <botlish_fn_18+0x182>
    1910:	mov    rax,r14
    1913:	mov    QWORD PTR [rbx+0x8],rax
    1917:	test   rax,0x1
    191d:	jne    194c <botlish_fn_18+0xe4>
    1923:	mov    edx,0x1
    1928:	mov    rax,QWORD PTR [rip+0x0]        # 192f <botlish_fn_18+0xc7>
			192b: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    192f:	mov    rsi,r14
    1932:	mov    rdi,r12
    1935:	call   rax
    1937:	mov    ecx,0x2
    193c:	test   rax,rax
    193f:	cmovl  rcx,QWORD PTR [rip+0x141]        # 1a88 <botlish_fn_18+0x220>
    1947:	jmp    195f <botlish_fn_18+0xf7>
    194c:	mov    ecx,0x2
    1951:	mov    rax,r14
    1954:	test   rax,rax
    1957:	cmovle rcx,QWORD PTR [rip+0x129]        # 1a88 <botlish_fn_18+0x220>
    195f:	cmp    rcx,0x6
    1963:	je     1a31 <botlish_fn_18+0x1c9>
    1969:	mov    rsi,r13
    196c:	mov    rdi,r12
    196f:	call   1974 <botlish_fn_18+0x10c>
			1970: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    1974:	test   rax,rax
    1977:	jne    1985 <botlish_fn_18+0x11d>
    197d:	mov    rdi,r12
    1980:	jmp    19ea <botlish_fn_18+0x182>
    1985:	xor    ecx,ecx
    1987:	test   rax,0x7
    198d:	jne    199e <botlish_fn_18+0x136>
    1993:	movzx  rsi,BYTE PTR [rax]
    1997:	cmp    sil,0x8
    199b:	sete   cl
    199e:	test   cl,cl
    19a0:	jne    19cb <botlish_fn_18+0x163>
    19a6:	mov    rdi,r12
    19a9:	mov    r10,QWORD PTR [rdi+0x10]
    19ad:	mov    rcx,QWORD PTR [r10+0x8]
    19b1:	mov    edx,0x8
    19b6:	mov    r10,QWORD PTR [rip+0x0]        # 19bd <botlish_fn_18+0x155>
			19b9: R_X86_64_GOTPCREL	rt_type_error-0x4
    19bd:	mov    rsi,rax
    19c0:	call   r10
    19c3:	mov    rdi,r12
    19c6:	jmp    19ea <botlish_fn_18+0x182>
    19cb:	mov    rsi,rax
    19ce:	mov    r11,QWORD PTR [rip+0x0]        # 19d5 <botlish_fn_18+0x16d>
			19d1: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    19d5:	mov    rdx,r14
    19d8:	mov    rdi,r12
    19db:	call   r11
    19de:	test   rax,rax
    19e1:	jne    1a0f <botlish_fn_18+0x1a7>
    19e7:	mov    rdi,r12
    19ea:	mov    rdi,r12
    19ed:	mov    QWORD PTR [rdi],rbx
    19f0:	xor    rax,rax
    19f3:	mov    rbx,QWORD PTR [rsp]
    19f7:	mov    r12,QWORD PTR [rsp+0x8]
    19fc:	mov    r13,QWORD PTR [rsp+0x10]
    1a01:	mov    r14,QWORD PTR [rsp+0x18]
    1a06:	add    rsp,0x20
    1a0a:	mov    rsp,rbp
    1a0d:	pop    rbp
    1a0e:	ret
    1a0f:	mov    rdi,r12
    1a12:	mov    QWORD PTR [rdi],rbx
    1a15:	mov    rbx,QWORD PTR [rsp]
    1a19:	mov    r12,QWORD PTR [rsp+0x8]
    1a1e:	mov    r13,QWORD PTR [rsp+0x10]
    1a23:	mov    r14,QWORD PTR [rsp+0x18]
    1a28:	add    rsp,0x20
    1a2c:	mov    rsp,rbp
    1a2f:	pop    rbp
    1a30:	ret
    1a31:	mov    rdi,r12
    1a34:	mov    QWORD PTR [rdi],rbx
    1a37:	mov    eax,0xa
    1a3c:	mov    rbx,QWORD PTR [rsp]
    1a40:	mov    r12,QWORD PTR [rsp+0x8]
    1a45:	mov    r13,QWORD PTR [rsp+0x10]
    1a4a:	mov    r14,QWORD PTR [rsp+0x18]
    1a4f:	add    rsp,0x20
    1a53:	mov    rsp,rbp
    1a56:	pop    rbp
    1a57:	ret
    1a58:	mov    r12,rdi
    1a5b:	mov    rax,QWORD PTR [rip+0x0]        # 1a62 <botlish_fn_18+0x1fa>
			1a5e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1a62:	call   rax
    1a64:	xor    rax,rax
    1a67:	mov    rbx,QWORD PTR [rsp]
    1a6b:	mov    r12,QWORD PTR [rsp+0x8]
    1a70:	mov    r13,QWORD PTR [rsp+0x10]
    1a75:	mov    r14,QWORD PTR [rsp+0x18]
    1a7a:	add    rsp,0x20
    1a7e:	mov    rsp,rbp
    1a81:	pop    rbp
    1a82:	ret
    1a83:	add    BYTE PTR [rax],al
    1a85:	add    BYTE PTR [rax],al
    1a87:	add    BYTE PTR [rsi],al
    1a89:	add    BYTE PTR [rax],al
    1a8b:	add    BYTE PTR [rax],al
    1a8d:	add    BYTE PTR [rax],al
	...

0000000000001a90 <botlish_entry_18: ht_get<mutarray, str>>:
    1a90:	push   rbp
    1a91:	mov    rbp,rsp
    1a94:	mov    rsi,QWORD PTR [rdx]
    1a97:	mov    rdx,QWORD PTR [rdx+0x8]
    1a9b:	call   1aa0 <botlish_entry_18+0x10>
			1a9c: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    1aa0:	mov    rsp,rbp
    1aa3:	pop    rbp
    1aa4:	ret
    1aa5:	add    BYTE PTR [rax],al
	...

0000000000001aa8 <botlish_fn_19: ht_contains<mutarray, str>>:
    1aa8:	push   rbp
    1aa9:	mov    rbp,rsp
    1aac:	sub    rsp,0x20
    1ab0:	mov    QWORD PTR [rsp],rbx
    1ab4:	mov    QWORD PTR [rsp+0x8],r12
    1ab9:	mov    QWORD PTR [rsp+0x10],r13
    1abe:	mov    QWORD PTR [rsp+0x18],r14
    1ac3:	mov    rbx,QWORD PTR [rdi]
    1ac6:	mov    rax,QWORD PTR [rdi+0x8]
    1aca:	lea    rcx,[rbx+0x18]
    1ace:	cmp    rcx,rax
    1ad1:	ja     1bda <botlish_fn_19+0x132>
    1ad7:	lea    rax,[rbx+0x18]
    1adb:	mov    QWORD PTR [rdi],rax
    1ade:	mov    r12,rdi
    1ae1:	mov    QWORD PTR [rbx],0x0
    1ae8:	mov    QWORD PTR [rbx+0x8],0x0
    1af0:	mov    QWORD PTR [rbx+0x10],0x0
    1af8:	mov    QWORD PTR [rbx],rsi
    1afb:	mov    r14,rsi
    1afe:	mov    QWORD PTR [rbx+0x8],rdx
    1b02:	mov    r13,rdx
    1b05:	mov    rdx,r13
    1b08:	mov    rsi,r14
    1b0b:	mov    rdi,r12
    1b0e:	call   1b13 <botlish_fn_19+0x6b>
			1b0f: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    1b13:	test   rax,rax
    1b16:	jne    1b24 <botlish_fn_19+0x7c>
    1b1c:	mov    rdi,r12
    1b1f:	jmp    1b45 <botlish_fn_19+0x9d>
    1b24:	mov    QWORD PTR [rbx+0x10],rax
    1b28:	mov    rcx,rax
    1b2b:	mov    rdx,r13
    1b2e:	mov    rsi,r14
    1b31:	mov    rdi,r12
    1b34:	call   1b39 <botlish_fn_19+0x91>
			1b35: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1b39:	test   rax,rax
    1b3c:	jne    1b6a <botlish_fn_19+0xc2>
    1b42:	mov    rdi,r12
    1b45:	mov    rdi,r12
    1b48:	mov    QWORD PTR [rdi],rbx
    1b4b:	xor    rax,rax
    1b4e:	mov    rbx,QWORD PTR [rsp]
    1b52:	mov    r12,QWORD PTR [rsp+0x8]
    1b57:	mov    r13,QWORD PTR [rsp+0x10]
    1b5c:	mov    r14,QWORD PTR [rsp+0x18]
    1b61:	add    rsp,0x20
    1b65:	mov    rsp,rbp
    1b68:	pop    rbp
    1b69:	ret
    1b6a:	test   rax,0x1
    1b70:	mov    rsi,rax
    1b73:	jne    1ba5 <botlish_fn_19+0xfd>
    1b79:	mov    edx,0x1
    1b7e:	mov    rax,QWORD PTR [rip+0x0]        # 1b85 <botlish_fn_19+0xdd>
			1b81: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1b85:	mov    rdi,r12
    1b88:	call   rax
    1b8a:	mov    ecx,0x2
    1b8f:	test   rax,rax
    1b92:	mov    rax,rcx
    1b95:	cmovge rax,QWORD PTR [rip+0x6b]        # 1c08 <botlish_fn_19+0x160>
    1b9d:	mov    rdi,r12
    1ba0:	jmp    1bb8 <botlish_fn_19+0x110>
    1ba5:	mov    eax,0x2
    1baa:	test   rsi,rsi
    1bad:	cmovg  rax,QWORD PTR [rip+0x53]        # 1c08 <botlish_fn_19+0x160>
    1bb5:	mov    rdi,r12
    1bb8:	mov    rdi,r12
    1bbb:	mov    QWORD PTR [rdi],rbx
    1bbe:	mov    rbx,QWORD PTR [rsp]
    1bc2:	mov    r12,QWORD PTR [rsp+0x8]
    1bc7:	mov    r13,QWORD PTR [rsp+0x10]
    1bcc:	mov    r14,QWORD PTR [rsp+0x18]
    1bd1:	add    rsp,0x20
    1bd5:	mov    rsp,rbp
    1bd8:	pop    rbp
    1bd9:	ret
    1bda:	mov    r12,rdi
    1bdd:	mov    rax,QWORD PTR [rip+0x0]        # 1be4 <botlish_fn_19+0x13c>
			1be0: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1be4:	call   rax
    1be6:	xor    rax,rax
    1be9:	mov    rbx,QWORD PTR [rsp]
    1bed:	mov    r12,QWORD PTR [rsp+0x8]
    1bf2:	mov    r13,QWORD PTR [rsp+0x10]
    1bf7:	mov    r14,QWORD PTR [rsp+0x18]
    1bfc:	add    rsp,0x20
    1c00:	mov    rsp,rbp
    1c03:	pop    rbp
    1c04:	ret
    1c05:	add    BYTE PTR [rax],al
    1c07:	add    BYTE PTR [rsi],al
    1c09:	add    BYTE PTR [rax],al
    1c0b:	add    BYTE PTR [rax],al
    1c0d:	add    BYTE PTR [rax],al
	...

0000000000001c10 <botlish_entry_19: ht_contains<mutarray, str>>:
    1c10:	push   rbp
    1c11:	mov    rbp,rsp
    1c14:	mov    rsi,QWORD PTR [rdx]
    1c17:	mov    rdx,QWORD PTR [rdx+0x8]
    1c1b:	call   1c20 <botlish_entry_19+0x10>
			1c1c: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    1c20:	mov    rsp,rbp
    1c23:	pop    rbp
    1c24:	ret
    1c25:	add    BYTE PTR [rax],al
	...

0000000000001c28 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    1c28:	push   rbp
    1c29:	mov    rbp,rsp
    1c2c:	sub    rsp,0x40
    1c30:	mov    QWORD PTR [rsp+0x10],rbx
    1c35:	mov    QWORD PTR [rsp+0x18],r12
    1c3a:	mov    QWORD PTR [rsp+0x20],r13
    1c3f:	mov    QWORD PTR [rsp+0x28],r14
    1c44:	mov    QWORD PTR [rsp+0x30],r15
    1c49:	mov    r12,QWORD PTR [rdi]
    1c4c:	mov    rax,QWORD PTR [rdi+0x8]
    1c50:	lea    r8,[r12+0x20]
    1c55:	cmp    r8,rax
    1c58:	ja     1e14 <botlish_fn_20+0x1ec>
    1c5e:	lea    rax,[r12+0x20]
    1c63:	mov    QWORD PTR [rdi],rax
    1c66:	mov    r14,rdi
    1c69:	mov    QWORD PTR [r12],0x0
    1c71:	mov    QWORD PTR [r12+0x8],0x0
    1c7a:	mov    QWORD PTR [r12+0x10],0x0
    1c83:	mov    QWORD PTR [r12+0x18],0x0
    1c8c:	mov    QWORD PTR [r12],rsi
    1c90:	mov    QWORD PTR [r12+0x8],rdx
    1c95:	mov    QWORD PTR [r12+0x10],rcx
    1c9a:	mov    r13,rcx
    1c9d:	mov    r15,rdx
    1ca0:	mov    rax,QWORD PTR [rip+0x0]        # 1ca7 <botlish_fn_20+0x7f>
			1ca3: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    1ca7:	mov    rbx,rsi
    1caa:	mov    rdx,r15
    1cad:	mov    rdi,r14
    1cb0:	call   rax
    1cb2:	test   rax,rax
    1cb5:	jne    1cc3 <botlish_fn_20+0x9b>
    1cbb:	mov    rdi,r14
    1cbe:	jmp    1da5 <botlish_fn_20+0x17d>
    1cc3:	mov    QWORD PTR [r12+0x18],rax
    1cc8:	mov    QWORD PTR [rsp],rax
    1ccc:	mov    rdi,r14
    1ccf:	call   1cd4 <botlish_fn_20+0xac>
			1cd0: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    1cd4:	test   rax,rax
    1cd7:	jne    1ce5 <botlish_fn_20+0xbd>
    1cdd:	mov    rdi,r14
    1ce0:	jmp    1da5 <botlish_fn_20+0x17d>
    1ce5:	mov    rcx,QWORD PTR [rsp]
    1ce9:	mov    rdx,rcx
    1cec:	and    rdx,rax
    1cef:	mov    rcx,rax
    1cf2:	test   rdx,0x1
    1cf9:	jne    1d23 <botlish_fn_20+0xfb>
    1cff:	mov    rax,QWORD PTR [rip+0x0]        # 1d06 <botlish_fn_20+0xde>
			1d02: R_X86_64_GOTPCREL	rt_value_eq-0x4
    1d06:	mov    rdx,rcx
    1d09:	mov    rsi,QWORD PTR [rsp]
    1d0d:	mov    rdi,r14
    1d10:	call   rax
    1d12:	test   rax,rax
    1d15:	jne    1d3a <botlish_fn_20+0x112>
    1d1b:	mov    rdi,r14
    1d1e:	jmp    1da5 <botlish_fn_20+0x17d>
    1d23:	mov    rdx,rcx
    1d26:	mov    rsi,QWORD PTR [rsp]
    1d2a:	mov    eax,0x2
    1d2f:	cmp    rsi,rdx
    1d32:	cmove  rax,QWORD PTR [rip+0x10e]        # 1e48 <botlish_fn_20+0x220>
    1d3a:	cmp    rax,0x6
    1d3e:	je     1de9 <botlish_fn_20+0x1c1>
    1d44:	mov    QWORD PTR [r12+0x18],0x3
    1d4d:	mov    rsi,r15
    1d50:	test   rsi,0x1
    1d57:	je     1d71 <botlish_fn_20+0x149>
    1d5d:	mov    rsi,r15
    1d60:	add    rsi,0x2
    1d64:	seto   dil
    1d68:	test   dil,dil
    1d6b:	je     1d89 <botlish_fn_20+0x161>
    1d71:	mov    edx,0x3
    1d76:	mov    r8,QWORD PTR [rip+0x0]        # 1d7d <botlish_fn_20+0x155>
			1d79: R_X86_64_GOTPCREL	rt_int_add-0x4
    1d7d:	mov    rsi,r15
    1d80:	mov    rdi,r14
    1d83:	call   r8
    1d86:	mov    rsi,rax
    1d89:	mov    r8,QWORD PTR [rip+0x0]        # 1d90 <botlish_fn_20+0x168>
			1d8c: R_X86_64_GOTPCREL	rt_int_mod-0x4
    1d90:	mov    rdx,r13
    1d93:	mov    rdi,r14
    1d96:	call   r8
    1d99:	test   rax,rax
    1d9c:	jne    1dd0 <botlish_fn_20+0x1a8>
    1da2:	mov    rdi,r14
    1da5:	mov    rdi,r14
    1da8:	mov    QWORD PTR [rdi],r12
    1dab:	xor    rax,rax
    1dae:	mov    rbx,QWORD PTR [rsp+0x10]
    1db3:	mov    r12,QWORD PTR [rsp+0x18]
    1db8:	mov    r13,QWORD PTR [rsp+0x20]
    1dbd:	mov    r14,QWORD PTR [rsp+0x28]
    1dc2:	mov    r15,QWORD PTR [rsp+0x30]
    1dc7:	add    rsp,0x40
    1dcb:	mov    rsp,rbp
    1dce:	pop    rbp
    1dcf:	ret
    1dd0:	mov    QWORD PTR [r12],rbx
    1dd4:	mov    QWORD PTR [r12+0x8],rax
    1dd9:	mov    QWORD PTR [r12+0x10],r13
    1dde:	mov    rsi,rbx
    1de1:	mov    r15,rax
    1de4:	jmp    1ca0 <botlish_fn_20+0x78>
    1de9:	mov    rdi,r14
    1dec:	mov    QWORD PTR [rdi],r12
    1def:	mov    rax,r15
    1df2:	mov    rbx,QWORD PTR [rsp+0x10]
    1df7:	mov    r12,QWORD PTR [rsp+0x18]
    1dfc:	mov    r13,QWORD PTR [rsp+0x20]
    1e01:	mov    r14,QWORD PTR [rsp+0x28]
    1e06:	mov    r15,QWORD PTR [rsp+0x30]
    1e0b:	add    rsp,0x40
    1e0f:	mov    rsp,rbp
    1e12:	pop    rbp
    1e13:	ret
    1e14:	mov    r14,rdi
    1e17:	mov    rax,QWORD PTR [rip+0x0]        # 1e1e <botlish_fn_20+0x1f6>
			1e1a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1e1e:	call   rax
    1e20:	xor    rax,rax
    1e23:	mov    rbx,QWORD PTR [rsp+0x10]
    1e28:	mov    r12,QWORD PTR [rsp+0x18]
    1e2d:	mov    r13,QWORD PTR [rsp+0x20]
    1e32:	mov    r14,QWORD PTR [rsp+0x28]
    1e37:	mov    r15,QWORD PTR [rsp+0x30]
    1e3c:	add    rsp,0x40
    1e40:	mov    rsp,rbp
    1e43:	pop    rbp
    1e44:	ret
    1e45:	add    BYTE PTR [rax],al
    1e47:	add    BYTE PTR [rsi],al
    1e49:	add    BYTE PTR [rax],al
    1e4b:	add    BYTE PTR [rax],al
    1e4d:	add    BYTE PTR [rax],al
	...

0000000000001e50 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    1e50:	push   rbp
    1e51:	mov    rbp,rsp
    1e54:	mov    rsi,QWORD PTR [rdx]
    1e57:	mov    r8,QWORD PTR [rdx+0x8]
    1e5b:	mov    rcx,QWORD PTR [rdx+0x10]
    1e5f:	mov    rdx,r8
    1e62:	call   1e67 <botlish_entry_20+0x17>
			1e63: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1e67:	mov    rsp,rbp
    1e6a:	pop    rbp
    1e6b:	ret

0000000000001e6c <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1e6c:	push   rbp
    1e6d:	mov    rbp,rsp
    1e70:	sub    rsp,0x50
    1e74:	mov    QWORD PTR [rsp+0x20],rbx
    1e79:	mov    QWORD PTR [rsp+0x28],r12
    1e7e:	mov    QWORD PTR [rsp+0x30],r13
    1e83:	mov    QWORD PTR [rsp+0x38],r14
    1e88:	mov    QWORD PTR [rsp+0x40],r15
    1e8d:	mov    r10,QWORD PTR [rbp+0x10]
    1e91:	mov    rbx,QWORD PTR [rdi]
    1e94:	mov    rax,QWORD PTR [rdi+0x8]
    1e98:	lea    r11,[rbx+0x38]
    1e9c:	cmp    r11,rax
    1e9f:	ja     2074 <botlish_fn_21+0x208>
    1ea5:	lea    rax,[rbx+0x38]
    1ea9:	mov    QWORD PTR [rdi],rax
    1eac:	mov    r12,rdi
    1eaf:	mov    QWORD PTR [rbx],0x0
    1eb6:	mov    QWORD PTR [rbx+0x8],0x0
    1ebe:	mov    QWORD PTR [rbx+0x10],0x0
    1ec6:	mov    QWORD PTR [rbx+0x18],0x0
    1ece:	mov    QWORD PTR [rbx+0x20],0x0
    1ed6:	mov    QWORD PTR [rbx+0x28],0x0
    1ede:	mov    QWORD PTR [rbx+0x30],0x0
    1ee6:	mov    QWORD PTR [rbx],rsi
    1ee9:	mov    QWORD PTR [rsp],rsi
    1eed:	mov    QWORD PTR [rbx+0x8],rdx
    1ef1:	mov    QWORD PTR [rsp+0x8],rdx
    1ef6:	mov    QWORD PTR [rbx+0x10],rcx
    1efa:	mov    r13,rcx
    1efd:	mov    QWORD PTR [rbx+0x18],r8
    1f01:	mov    QWORD PTR [rsp+0x10],r8
    1f06:	mov    QWORD PTR [rbx+0x20],r9
    1f0a:	mov    r15,r9
    1f0d:	mov    QWORD PTR [rbx+0x28],r10
    1f11:	mov    r14,r10
    1f14:	mov    rax,QWORD PTR [rip+0x0]        # 1f1b <botlish_fn_21+0xaf>
			1f17: R_X86_64_GOTPCREL	rt_hash-0x4
    1f1b:	mov    rsi,r15
    1f1e:	mov    rdi,r12
    1f21:	call   rax
    1f23:	test   rax,rax
    1f26:	mov    rsi,rax
    1f29:	jne    1f37 <botlish_fn_21+0xcb>
    1f2f:	mov    rdi,r12
    1f32:	jmp    201c <botlish_fn_21+0x1b0>
    1f37:	mov    rax,QWORD PTR [rip+0x0]        # 1f3e <botlish_fn_21+0xd2>
			1f3a: R_X86_64_GOTPCREL	rt_int_mod-0x4
    1f3e:	mov    rdx,QWORD PTR [rsp+0x10]
    1f43:	mov    rdi,r12
    1f46:	call   rax
    1f48:	test   rax,rax
    1f4b:	jne    1f59 <botlish_fn_21+0xed>
    1f51:	mov    rdi,r12
    1f54:	jmp    201c <botlish_fn_21+0x1b0>
    1f59:	mov    QWORD PTR [rbx+0x30],rax
    1f5d:	mov    rcx,QWORD PTR [rsp+0x10]
    1f62:	mov    rdx,rax
    1f65:	mov    rsi,QWORD PTR [rsp]
    1f69:	mov    rdi,r12
    1f6c:	call   1f71 <botlish_fn_21+0x105>
			1f6d: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1f71:	test   rax,rax
    1f74:	jne    1f82 <botlish_fn_21+0x116>
    1f7a:	mov    rdi,r12
    1f7d:	jmp    201c <botlish_fn_21+0x1b0>
    1f82:	mov    QWORD PTR [rbx+0x18],rax
    1f86:	mov    QWORD PTR [rsp+0x10],rax
    1f8b:	mov    rdi,r12
    1f8e:	call   1f93 <botlish_fn_21+0x127>
			1f8f: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1f93:	test   rax,rax
    1f96:	mov    rcx,rax
    1f99:	jne    1fa7 <botlish_fn_21+0x13b>
    1f9f:	mov    rdi,r12
    1fa2:	jmp    201c <botlish_fn_21+0x1b0>
    1fa7:	mov    rax,QWORD PTR [rip+0x0]        # 1fae <botlish_fn_21+0x142>
			1faa: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    1fae:	mov    rsi,QWORD PTR [rsp]
    1fb2:	mov    rdx,QWORD PTR [rsp+0x10]
    1fb7:	mov    rdi,r12
    1fba:	call   rax
    1fbc:	test   rax,rax
    1fbf:	jne    1fcd <botlish_fn_21+0x161>
    1fc5:	mov    rdi,r12
    1fc8:	jmp    201c <botlish_fn_21+0x1b0>
    1fcd:	mov    r8,QWORD PTR [rip+0x0]        # 1fd4 <botlish_fn_21+0x168>
			1fd0: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    1fd4:	mov    rcx,r15
    1fd7:	mov    rsi,QWORD PTR [rsp+0x8]
    1fdc:	mov    rdx,QWORD PTR [rsp+0x10]
    1fe1:	mov    rdi,r12
    1fe4:	call   r8
    1fe7:	test   rax,rax
    1fea:	jne    1ff8 <botlish_fn_21+0x18c>
    1ff0:	mov    rdi,r12
    1ff3:	jmp    201c <botlish_fn_21+0x1b0>
    1ff8:	mov    r8,QWORD PTR [rip+0x0]        # 1fff <botlish_fn_21+0x193>
			1ffb: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    1fff:	mov    rcx,r14
    2002:	mov    rdx,QWORD PTR [rsp+0x10]
    2007:	mov    rsi,r13
    200a:	mov    rdi,r12
    200d:	call   r8
    2010:	test   rax,rax
    2013:	jne    2047 <botlish_fn_21+0x1db>
    2019:	mov    rdi,r12
    201c:	mov    rdi,r12
    201f:	mov    QWORD PTR [rdi],rbx
    2022:	xor    rax,rax
    2025:	mov    rbx,QWORD PTR [rsp+0x20]
    202a:	mov    r12,QWORD PTR [rsp+0x28]
    202f:	mov    r13,QWORD PTR [rsp+0x30]
    2034:	mov    r14,QWORD PTR [rsp+0x38]
    2039:	mov    r15,QWORD PTR [rsp+0x40]
    203e:	add    rsp,0x50
    2042:	mov    rsp,rbp
    2045:	pop    rbp
    2046:	ret
    2047:	mov    rdi,r12
    204a:	mov    QWORD PTR [rdi],rbx
    204d:	mov    eax,0xa
    2052:	mov    rbx,QWORD PTR [rsp+0x20]
    2057:	mov    r12,QWORD PTR [rsp+0x28]
    205c:	mov    r13,QWORD PTR [rsp+0x30]
    2061:	mov    r14,QWORD PTR [rsp+0x38]
    2066:	mov    r15,QWORD PTR [rsp+0x40]
    206b:	add    rsp,0x50
    206f:	mov    rsp,rbp
    2072:	pop    rbp
    2073:	ret
    2074:	mov    r12,rdi
    2077:	mov    rax,QWORD PTR [rip+0x0]        # 207e <botlish_fn_21+0x212>
			207a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    207e:	call   rax
    2080:	xor    rax,rax
    2083:	mov    rbx,QWORD PTR [rsp+0x20]
    2088:	mov    r12,QWORD PTR [rsp+0x28]
    208d:	mov    r13,QWORD PTR [rsp+0x30]
    2092:	mov    r14,QWORD PTR [rsp+0x38]
    2097:	mov    r15,QWORD PTR [rsp+0x40]
    209c:	add    rsp,0x50
    20a0:	mov    rsp,rbp
    20a3:	pop    rbp
    20a4:	ret

00000000000020a5 <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    20a5:	push   rbp
    20a6:	mov    rbp,rsp
    20a9:	sub    rsp,0x10
    20ad:	mov    rsi,QWORD PTR [rdx]
    20b0:	mov    r10,QWORD PTR [rdx+0x8]
    20b4:	mov    rcx,QWORD PTR [rdx+0x10]
    20b8:	mov    r8,QWORD PTR [rdx+0x18]
    20bc:	mov    r9,QWORD PTR [rdx+0x20]
    20c0:	mov    r11,QWORD PTR [rdx+0x28]
    20c4:	mov    QWORD PTR [rsp],r11
    20c8:	mov    rdx,r10
    20cb:	call   20d0 <botlish_entry_21+0x2b>
			20cc: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    20d0:	add    rsp,0x10
    20d4:	mov    rsp,rbp
    20d7:	pop    rbp
    20d8:	ret
    20d9:	add    BYTE PTR [rax],al
    20db:	add    BYTE PTR [rax],al
    20dd:	add    BYTE PTR [rax],al
	...

00000000000020e0 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    20e0:	push   rbp
    20e1:	mov    rbp,rsp
    20e4:	sub    rsp,0x80
    20eb:	mov    QWORD PTR [rsp+0x50],rbx
    20f0:	mov    QWORD PTR [rsp+0x58],r12
    20f5:	mov    QWORD PTR [rsp+0x60],r13
    20fa:	mov    QWORD PTR [rsp+0x68],r14
    20ff:	mov    QWORD PTR [rsp+0x70],r15
    2104:	mov    r13,QWORD PTR [rbp+0x10]
    2108:	mov    r14,QWORD PTR [rbp+0x18]
    210c:	mov    r15,QWORD PTR [rbp+0x20]
    2110:	mov    r12,QWORD PTR [rbp+0x28]
    2114:	mov    QWORD PTR [rsp+0x38],r12
    2119:	mov    r12,QWORD PTR [rdi]
    211c:	mov    rax,QWORD PTR [rdi+0x8]
    2120:	lea    r10,[r12+0x58]
    2125:	cmp    r10,rax
    2128:	ja     25c3 <botlish_fn_22+0x4e3>
    212e:	lea    rax,[r12+0x58]
    2133:	mov    QWORD PTR [rdi],rax
    2136:	mov    QWORD PTR [rsp+0x10],rdi
    213b:	mov    QWORD PTR [r12],0x0
    2143:	mov    QWORD PTR [r12+0x8],0x0
    214c:	mov    QWORD PTR [r12+0x10],0x0
    2155:	mov    QWORD PTR [r12+0x18],0x0
    215e:	mov    QWORD PTR [r12+0x20],0x0
    2167:	mov    QWORD PTR [r12+0x28],0x0
    2170:	mov    QWORD PTR [r12+0x30],0x0
    2179:	mov    QWORD PTR [r12+0x38],0x0
    2182:	mov    QWORD PTR [r12+0x40],0x0
    218b:	mov    QWORD PTR [r12+0x48],0x0
    2194:	mov    QWORD PTR [r12+0x50],0x0
    219d:	mov    QWORD PTR [r12],rsi
    21a1:	mov    QWORD PTR [rsp+0x18],rsi
    21a6:	mov    QWORD PTR [r12+0x8],rdx
    21ab:	mov    QWORD PTR [rsp+0x20],rdx
    21b0:	mov    QWORD PTR [r12+0x10],rcx
    21b5:	mov    QWORD PTR [rsp+0x28],rcx
    21ba:	mov    QWORD PTR [r12+0x18],r8
    21bf:	mov    QWORD PTR [r12+0x20],r9
    21c4:	mov    QWORD PTR [rsp+0x30],r9
    21c9:	mov    QWORD PTR [r12+0x28],r13
    21ce:	mov    QWORD PTR [r12+0x30],r14
    21d3:	mov    QWORD PTR [r12+0x38],r15
    21d8:	mov    rax,QWORD PTR [rsp+0x38]
    21dd:	mov    QWORD PTR [r12+0x40],rax
    21e2:	mov    rbx,QWORD PTR [rsp+0x30]
    21e7:	mov    rsi,r8
    21ea:	mov    rax,rsi
    21ed:	and    rax,rbx
    21f0:	mov    QWORD PTR [rsp+0x40],rsi
    21f5:	test   rax,0x1
    21fb:	jne    2231 <botlish_fn_22+0x151>
    2201:	mov    rax,QWORD PTR [rip+0x0]        # 2208 <botlish_fn_22+0x128>
			2204: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    2208:	mov    rdx,rbx
    220b:	mov    rsi,QWORD PTR [rsp+0x40]
    2210:	mov    rdi,QWORD PTR [rsp+0x10]
    2215:	call   rax
    2217:	mov    QWORD PTR [rsp+0x30],rbx
    221c:	mov    ecx,0x2
    2221:	test   rax,rax
    2224:	cmovge rcx,QWORD PTR [rip+0x3d4]        # 2600 <botlish_fn_22+0x520>
    222c:	jmp    2250 <botlish_fn_22+0x170>
    2231:	mov    QWORD PTR [rsp+0x30],rbx
    2236:	mov    ecx,0x2
    223b:	mov    rsi,QWORD PTR [rsp+0x40]
    2240:	mov    r9,QWORD PTR [rsp+0x30]
    2245:	cmp    rsi,r9
    2248:	cmovge rcx,QWORD PTR [rip+0x3b0]        # 2600 <botlish_fn_22+0x520>
    2250:	cmp    rcx,0x6
    2254:	je     2591 <botlish_fn_22+0x4b1>
    225a:	xor    eax,eax
    225c:	mov    rsi,QWORD PTR [rsp+0x18]
    2261:	test   rsi,0x7
    2268:	jne    2277 <botlish_fn_22+0x197>
    226e:	movzx  rax,BYTE PTR [rsi]
    2272:	cmp    al,0x8
    2274:	sete   al
    2277:	test   al,al
    2279:	jne    22a4 <botlish_fn_22+0x1c4>
    227f:	mov    rdi,QWORD PTR [rsp+0x10]
    2284:	mov    rax,QWORD PTR [rdi+0x10]
    2288:	mov    rcx,QWORD PTR [rax+0x8]
    228c:	mov    edx,0x8
    2291:	mov    rax,QWORD PTR [rip+0x0]        # 2298 <botlish_fn_22+0x1b8>
			2294: R_X86_64_GOTPCREL	rt_type_error-0x4
    2298:	call   rax
    229a:	mov    rdi,QWORD PTR [rsp+0x10]
    229f:	jmp    24aa <botlish_fn_22+0x3ca>
    22a4:	mov    QWORD PTR [rsp+0x18],rsi
    22a9:	mov    rax,QWORD PTR [rip+0x0]        # 22b0 <botlish_fn_22+0x1d0>
			22ac: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    22b0:	mov    rdx,QWORD PTR [rsp+0x40]
    22b5:	mov    rdi,QWORD PTR [rsp+0x10]
    22ba:	call   rax
    22bc:	test   rax,rax
    22bf:	jne    22cf <botlish_fn_22+0x1ef>
    22c5:	mov    rdi,QWORD PTR [rsp+0x10]
    22ca:	jmp    24aa <botlish_fn_22+0x3ca>
    22cf:	mov    QWORD PTR [r12+0x48],rax
    22d4:	mov    rbx,rax
    22d7:	mov    rdi,QWORD PTR [rsp+0x10]
    22dc:	call   22e1 <botlish_fn_22+0x201>
			22dd: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    22e1:	test   rax,rax
    22e4:	jne    22f4 <botlish_fn_22+0x214>
    22ea:	mov    rdi,QWORD PTR [rsp+0x10]
    22ef:	jmp    24aa <botlish_fn_22+0x3ca>
    22f4:	mov    r9,rbx
    22f7:	mov    rsi,r9
    22fa:	and    rsi,rax
    22fd:	mov    rdx,rax
    2300:	test   rsi,0x1
    2307:	jne    2332 <botlish_fn_22+0x252>
    230d:	mov    r8,QWORD PTR [rip+0x0]        # 2314 <botlish_fn_22+0x234>
			2310: R_X86_64_GOTPCREL	rt_value_eq-0x4
    2314:	mov    rsi,rbx
    2317:	mov    rdi,QWORD PTR [rsp+0x10]
    231c:	call   r8
    231f:	test   rax,rax
    2322:	jne    2345 <botlish_fn_22+0x265>
    2328:	mov    rdi,QWORD PTR [rsp+0x10]
    232d:	jmp    24aa <botlish_fn_22+0x3ca>
    2332:	mov    rsi,rbx
    2335:	mov    eax,0x2
    233a:	cmp    rsi,rdx
    233d:	cmove  rax,QWORD PTR [rip+0x2bb]        # 2600 <botlish_fn_22+0x520>
    2345:	cmp    rax,0x6
    2349:	je     2359 <botlish_fn_22+0x279>
    234f:	mov    rbx,QWORD PTR [rsp+0x38]
    2354:	jmp    24da <botlish_fn_22+0x3fa>
    2359:	xor    eax,eax
    235b:	mov    rdx,QWORD PTR [rsp+0x20]
    2360:	test   rdx,0x7
    2367:	je     2377 <botlish_fn_22+0x297>
    236d:	mov    QWORD PTR [rsp+0x20],rdx
    2372:	jmp    2385 <botlish_fn_22+0x2a5>
    2377:	movzx  rax,BYTE PTR [rdx]
    237b:	mov    QWORD PTR [rsp+0x20],rdx
    2380:	cmp    al,0x8
    2382:	sete   al
    2385:	test   al,al
    2387:	jne    23b7 <botlish_fn_22+0x2d7>
    238d:	mov    rdi,QWORD PTR [rsp+0x10]
    2392:	mov    rax,QWORD PTR [rdi+0x10]
    2396:	mov    rcx,QWORD PTR [rax+0x8]
    239a:	mov    edx,0x8
    239f:	mov    rax,QWORD PTR [rip+0x0]        # 23a6 <botlish_fn_22+0x2c6>
			23a2: R_X86_64_GOTPCREL	rt_type_error-0x4
    23a6:	mov    rsi,QWORD PTR [rsp+0x20]
    23ab:	call   rax
    23ad:	mov    rdi,QWORD PTR [rsp+0x10]
    23b2:	jmp    24aa <botlish_fn_22+0x3ca>
    23b7:	mov    rax,QWORD PTR [rip+0x0]        # 23be <botlish_fn_22+0x2de>
			23ba: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    23be:	mov    rdx,QWORD PTR [rsp+0x40]
    23c3:	mov    rsi,QWORD PTR [rsp+0x20]
    23c8:	mov    rdi,QWORD PTR [rsp+0x10]
    23cd:	call   rax
    23cf:	test   rax,rax
    23d2:	jne    23e2 <botlish_fn_22+0x302>
    23d8:	mov    rdi,QWORD PTR [rsp+0x10]
    23dd:	jmp    24aa <botlish_fn_22+0x3ca>
    23e2:	mov    QWORD PTR [r12+0x48],rax
    23e7:	mov    rbx,rax
    23ea:	xor    esi,esi
    23ec:	mov    rcx,QWORD PTR [rsp+0x28]
    23f1:	test   rcx,0x7
    23f8:	je     2408 <botlish_fn_22+0x328>
    23fe:	mov    QWORD PTR [rsp+0x28],rcx
    2403:	jmp    2417 <botlish_fn_22+0x337>
    2408:	movzx  rax,BYTE PTR [rcx]
    240c:	mov    QWORD PTR [rsp+0x28],rcx
    2411:	cmp    al,0x8
    2413:	sete   sil
    2417:	test   sil,sil
    241a:	jne    244a <botlish_fn_22+0x36a>
    2420:	mov    rdi,QWORD PTR [rsp+0x10]
    2425:	mov    rax,QWORD PTR [rdi+0x10]
    2429:	mov    rcx,QWORD PTR [rax+0x8]
    242d:	mov    edx,0x8
    2432:	mov    rax,QWORD PTR [rip+0x0]        # 2439 <botlish_fn_22+0x359>
			2435: R_X86_64_GOTPCREL	rt_type_error-0x4
    2439:	mov    rsi,QWORD PTR [rsp+0x28]
    243e:	call   rax
    2440:	mov    rdi,QWORD PTR [rsp+0x10]
    2445:	jmp    24aa <botlish_fn_22+0x3ca>
    244a:	mov    rax,QWORD PTR [rip+0x0]        # 2451 <botlish_fn_22+0x371>
			244d: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2451:	mov    rdx,QWORD PTR [rsp+0x40]
    2456:	mov    rsi,QWORD PTR [rsp+0x28]
    245b:	mov    rdi,QWORD PTR [rsp+0x10]
    2460:	call   rax
    2462:	test   rax,rax
    2465:	jne    2475 <botlish_fn_22+0x395>
    246b:	mov    rdi,QWORD PTR [rsp+0x10]
    2470:	jmp    24aa <botlish_fn_22+0x3ca>
    2475:	mov    QWORD PTR [r12+0x50],rax
    247a:	mov    QWORD PTR [rsp],rax
    247e:	mov    r9,rbx
    2481:	mov    rbx,QWORD PTR [rsp+0x38]
    2486:	mov    rcx,r15
    2489:	mov    rdx,r14
    248c:	mov    rsi,r13
    248f:	mov    rdi,QWORD PTR [rsp+0x10]
    2494:	mov    r8,rbx
    2497:	call   249c <botlish_fn_22+0x3bc>
			2498: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    249c:	test   rax,rax
    249f:	jne    24da <botlish_fn_22+0x3fa>
    24a5:	mov    rdi,QWORD PTR [rsp+0x10]
    24aa:	mov    rdi,QWORD PTR [rsp+0x10]
    24af:	mov    QWORD PTR [rdi],r12
    24b2:	xor    rax,rax
    24b5:	mov    rbx,QWORD PTR [rsp+0x50]
    24ba:	mov    r12,QWORD PTR [rsp+0x58]
    24bf:	mov    r13,QWORD PTR [rsp+0x60]
    24c4:	mov    r14,QWORD PTR [rsp+0x68]
    24c9:	mov    r15,QWORD PTR [rsp+0x70]
    24ce:	add    rsp,0x80
    24d5:	mov    rsp,rbp
    24d8:	pop    rbp
    24d9:	ret
    24da:	mov    QWORD PTR [r12+0x48],0x3
    24e3:	mov    rsi,QWORD PTR [rsp+0x40]
    24e8:	test   rsi,0x1
    24ef:	je     251b <botlish_fn_22+0x43b>
    24f5:	mov    rsi,QWORD PTR [rsp+0x40]
    24fa:	mov    rcx,rsi
    24fd:	add    rcx,0x2
    2501:	seto   al
    2504:	test   al,al
    2506:	jne    251b <botlish_fn_22+0x43b>
    250c:	mov    rsi,QWORD PTR [rsp+0x18]
    2511:	mov    QWORD PTR [rsp+0x40],rcx
    2516:	jmp    253d <botlish_fn_22+0x45d>
    251b:	mov    edx,0x3
    2520:	mov    rax,QWORD PTR [rip+0x0]        # 2527 <botlish_fn_22+0x447>
			2523: R_X86_64_GOTPCREL	rt_int_add-0x4
    2527:	mov    rsi,QWORD PTR [rsp+0x40]
    252c:	mov    rdi,QWORD PTR [rsp+0x10]
    2531:	call   rax
    2533:	mov    rsi,QWORD PTR [rsp+0x18]
    2538:	mov    QWORD PTR [rsp+0x40],rax
    253d:	mov    rsi,QWORD PTR [rsp+0x18]
    2542:	mov    QWORD PTR [r12],rsi
    2546:	mov    rsi,QWORD PTR [rsp+0x20]
    254b:	mov    QWORD PTR [r12+0x8],rsi
    2550:	mov    rsi,QWORD PTR [rsp+0x28]
    2555:	mov    QWORD PTR [r12+0x10],rsi
    255a:	mov    rsi,QWORD PTR [rsp+0x40]
    255f:	mov    QWORD PTR [r12+0x18],rsi
    2564:	mov    r9,QWORD PTR [rsp+0x30]
    2569:	mov    QWORD PTR [r12+0x20],r9
    256e:	mov    QWORD PTR [r12+0x28],r13
    2573:	mov    QWORD PTR [r12+0x30],r14
    2578:	mov    QWORD PTR [r12+0x38],r15
    257d:	mov    QWORD PTR [r12+0x40],rbx
    2582:	mov    QWORD PTR [rsp+0x38],rbx
    2587:	mov    rbx,QWORD PTR [rsp+0x30]
    258c:	jmp    21ea <botlish_fn_22+0x10a>
    2591:	mov    rdi,QWORD PTR [rsp+0x10]
    2596:	mov    QWORD PTR [rdi],r12
    2599:	mov    eax,0xa
    259e:	mov    rbx,QWORD PTR [rsp+0x50]
    25a3:	mov    r12,QWORD PTR [rsp+0x58]
    25a8:	mov    r13,QWORD PTR [rsp+0x60]
    25ad:	mov    r14,QWORD PTR [rsp+0x68]
    25b2:	mov    r15,QWORD PTR [rsp+0x70]
    25b7:	add    rsp,0x80
    25be:	mov    rsp,rbp
    25c1:	pop    rbp
    25c2:	ret
    25c3:	mov    QWORD PTR [rsp+0x10],rdi
    25c8:	mov    rsi,QWORD PTR [rip+0x0]        # 25cf <botlish_fn_22+0x4ef>
			25cb: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    25cf:	call   rsi
    25d1:	xor    rax,rax
    25d4:	mov    rbx,QWORD PTR [rsp+0x50]
    25d9:	mov    r12,QWORD PTR [rsp+0x58]
    25de:	mov    r13,QWORD PTR [rsp+0x60]
    25e3:	mov    r14,QWORD PTR [rsp+0x68]
    25e8:	mov    r15,QWORD PTR [rsp+0x70]
    25ed:	add    rsp,0x80
    25f4:	mov    rsp,rbp
    25f7:	pop    rbp
    25f8:	ret
    25f9:	add    BYTE PTR [rax],al
    25fb:	add    BYTE PTR [rax],al
    25fd:	add    BYTE PTR [rax],al
    25ff:	add    BYTE PTR [rsi],al
    2601:	add    BYTE PTR [rax],al
    2603:	add    BYTE PTR [rax],al
    2605:	add    BYTE PTR [rax],al
	...

0000000000002608 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2608:	push   rbp
    2609:	mov    rbp,rsp
    260c:	sub    rsp,0x30
    2610:	mov    QWORD PTR [rsp+0x20],r12
    2615:	mov    rsi,QWORD PTR [rdx]
    2618:	mov    rax,QWORD PTR [rdx+0x8]
    261c:	mov    rcx,QWORD PTR [rdx+0x10]
    2620:	mov    r8,QWORD PTR [rdx+0x18]
    2624:	mov    r9,QWORD PTR [rdx+0x20]
    2628:	mov    r10,QWORD PTR [rdx+0x28]
    262c:	mov    r11,QWORD PTR [rdx+0x30]
    2630:	mov    r12,QWORD PTR [rdx+0x38]
    2634:	mov    rdx,QWORD PTR [rdx+0x40]
    2638:	mov    QWORD PTR [rsp],r10
    263c:	mov    QWORD PTR [rsp+0x8],r11
    2641:	mov    QWORD PTR [rsp+0x10],r12
    2646:	mov    QWORD PTR [rsp+0x18],rdx
    264b:	mov    rdx,rax
    264e:	call   2653 <botlish_entry_22+0x4b>
			264f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    2653:	mov    r12,QWORD PTR [rsp+0x20]
    2658:	add    rsp,0x30
    265c:	mov    rsp,rbp
    265f:	pop    rbp
    2660:	ret

0000000000002661 <botlish_fn_23: ht_rehash<mutarray, int>>:
    2661:	push   rbp
    2662:	mov    rbp,rsp
    2665:	sub    rsp,0x80
    266c:	mov    QWORD PTR [rsp+0x50],rbx
    2671:	mov    QWORD PTR [rsp+0x58],r12
    2676:	mov    QWORD PTR [rsp+0x60],r13
    267b:	mov    QWORD PTR [rsp+0x68],r14
    2680:	mov    QWORD PTR [rsp+0x70],r15
    2685:	mov    r12,QWORD PTR [rdi]
    2688:	mov    rax,QWORD PTR [rdi+0x8]
    268c:	lea    rcx,[r12+0x50]
    2691:	cmp    rcx,rax
    2694:	ja     29b1 <botlish_fn_23+0x350>
    269a:	lea    rax,[r12+0x50]
    269f:	mov    QWORD PTR [rdi],rax
    26a2:	mov    r13,rdi
    26a5:	mov    QWORD PTR [r12],0x0
    26ad:	mov    QWORD PTR [r12+0x8],0x0
    26b6:	mov    QWORD PTR [r12+0x10],0x0
    26bf:	mov    QWORD PTR [r12+0x18],0x0
    26c8:	mov    QWORD PTR [r12+0x20],0x0
    26d1:	mov    QWORD PTR [r12+0x28],0x0
    26da:	mov    QWORD PTR [r12+0x30],0x0
    26e3:	mov    QWORD PTR [r12+0x38],0x0
    26ec:	mov    QWORD PTR [r12+0x40],0x0
    26f5:	mov    QWORD PTR [r12+0x48],0x0
    26fe:	mov    QWORD PTR [r12],rsi
    2702:	mov    r14,rsi
    2705:	mov    QWORD PTR [r12+0x8],rdx
    270a:	mov    rbx,rdx
    270d:	mov    rsi,r14
    2710:	mov    rdi,r13
    2713:	call   2718 <botlish_fn_23+0xb7>
			2714: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    2718:	test   rax,rax
    271b:	jne    2729 <botlish_fn_23+0xc8>
    2721:	mov    rdi,r13
    2724:	jmp    2953 <botlish_fn_23+0x2f2>
    2729:	mov    QWORD PTR [r12+0x10],rax
    272e:	mov    r15,rax
    2731:	mov    rsi,r14
    2734:	mov    rdi,r13
    2737:	call   273c <botlish_fn_23+0xdb>
			2738: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    273c:	test   rax,rax
    273f:	jne    274d <botlish_fn_23+0xec>
    2745:	mov    rdi,r13
    2748:	jmp    2953 <botlish_fn_23+0x2f2>
    274d:	mov    QWORD PTR [r12+0x18],rax
    2752:	mov    QWORD PTR [rsp+0x48],rax
    2757:	mov    rsi,r14
    275a:	mov    rdi,r13
    275d:	call   2762 <botlish_fn_23+0x101>
			275e: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2762:	test   rax,rax
    2765:	jne    2773 <botlish_fn_23+0x112>
    276b:	mov    rdi,r13
    276e:	jmp    2953 <botlish_fn_23+0x2f2>
    2773:	mov    QWORD PTR [r12+0x20],rax
    2778:	mov    QWORD PTR [rsp+0x40],rax
    277d:	mov    rsi,r14
    2780:	mov    rdi,r13
    2783:	call   2788 <botlish_fn_23+0x127>
			2784: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2788:	test   rax,rax
    278b:	jne    2799 <botlish_fn_23+0x138>
    2791:	mov    rdi,r13
    2794:	jmp    2953 <botlish_fn_23+0x2f2>
    2799:	mov    QWORD PTR [r12+0x28],rax
    279e:	mov    QWORD PTR [rsp+0x38],rax
    27a3:	mov    r10,QWORD PTR [rip+0x0]        # 27aa <botlish_fn_23+0x149>
			27a6: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    27aa:	mov    rsi,rbx
    27ad:	mov    rdi,r13
    27b0:	call   r10
    27b3:	mov    rcx,rax
    27b6:	mov    QWORD PTR [rsp+0x30],rax
    27bb:	test   rax,rcx
    27be:	jne    27cc <botlish_fn_23+0x16b>
    27c4:	mov    rdi,r13
    27c7:	jmp    2953 <botlish_fn_23+0x2f2>
    27cc:	mov    rax,QWORD PTR [rsp+0x30]
    27d1:	mov    QWORD PTR [r12+0x30],rax
    27d6:	mov    edx,0x1
    27db:	mov    QWORD PTR [r12+0x38],0x1
    27e4:	mov    rcx,rbx
    27e7:	mov    rsi,QWORD PTR [rsp+0x30]
    27ec:	mov    rdi,r13
    27ef:	call   27f4 <botlish_fn_23+0x193>
			27f0: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    27f4:	test   rax,rax
    27f7:	jne    2805 <botlish_fn_23+0x1a4>
    27fd:	mov    rdi,r13
    2800:	jmp    2953 <botlish_fn_23+0x2f2>
    2805:	mov    rax,QWORD PTR [rip+0x0]        # 280c <botlish_fn_23+0x1ab>
			2808: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    280c:	mov    rsi,rbx
    280f:	mov    rdi,r13
    2812:	call   rax
    2814:	test   rax,rax
    2817:	jne    2825 <botlish_fn_23+0x1c4>
    281d:	mov    rdi,r13
    2820:	jmp    2953 <botlish_fn_23+0x2f2>
    2825:	mov    QWORD PTR [r12+0x38],rax
    282a:	mov    QWORD PTR [rsp+0x28],rax
    282f:	mov    rax,QWORD PTR [rip+0x0]        # 2836 <botlish_fn_23+0x1d5>
			2832: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    2836:	mov    rsi,rbx
    2839:	mov    rdi,r13
    283c:	call   rax
    283e:	test   rax,rax
    2841:	jne    284f <botlish_fn_23+0x1ee>
    2847:	mov    rdi,r13
    284a:	jmp    2953 <botlish_fn_23+0x2f2>
    284f:	mov    QWORD PTR [r12+0x40],rax
    2854:	mov    r8d,0x1
    285a:	mov    QWORD PTR [r12+0x48],0x1
    2863:	mov    r9,QWORD PTR [rsp+0x30]
    2868:	mov    QWORD PTR [rsp],r9
    286c:	mov    r10,QWORD PTR [rsp+0x28]
    2871:	mov    QWORD PTR [rsp+0x8],r10
    2876:	mov    QWORD PTR [rsp+0x10],rax
    287b:	mov    QWORD PTR [rsp+0x20],rax
    2880:	mov    QWORD PTR [rsp+0x18],rbx
    2885:	mov    rcx,QWORD PTR [rsp+0x40]
    288a:	mov    rdx,QWORD PTR [rsp+0x48]
    288f:	mov    rsi,r15
    2892:	mov    r9,QWORD PTR [rsp+0x38]
    2897:	mov    rdi,r13
    289a:	call   289f <botlish_fn_23+0x23e>
			289b: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    289f:	test   rax,rax
    28a2:	jne    28b0 <botlish_fn_23+0x24f>
    28a8:	mov    rdi,r13
    28ab:	jmp    2953 <botlish_fn_23+0x2f2>
    28b0:	mov    edx,0x1
    28b5:	mov    rax,QWORD PTR [rip+0x0]        # 28bc <botlish_fn_23+0x25b>
			28b8: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    28bc:	mov    rcx,QWORD PTR [rsp+0x30]
    28c1:	mov    rsi,r14
    28c4:	mov    rdi,r13
    28c7:	call   rax
    28c9:	test   rax,rax
    28cc:	jne    28da <botlish_fn_23+0x279>
    28d2:	mov    rdi,r13
    28d5:	jmp    2953 <botlish_fn_23+0x2f2>
    28da:	mov    edx,0x3
    28df:	mov    rax,QWORD PTR [rip+0x0]        # 28e6 <botlish_fn_23+0x285>
			28e2: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    28e6:	mov    rcx,QWORD PTR [rsp+0x28]
    28eb:	mov    rsi,r14
    28ee:	mov    rdi,r13
    28f1:	call   rax
    28f3:	test   rax,rax
    28f6:	jne    2904 <botlish_fn_23+0x2a3>
    28fc:	mov    rdi,r13
    28ff:	jmp    2953 <botlish_fn_23+0x2f2>
    2904:	mov    edx,0x5
    2909:	mov    rax,QWORD PTR [rip+0x0]        # 2910 <botlish_fn_23+0x2af>
			290c: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    2910:	mov    rcx,QWORD PTR [rsp+0x20]
    2915:	mov    rsi,r14
    2918:	mov    rdi,r13
    291b:	call   rax
    291d:	test   rax,rax
    2920:	jne    292e <botlish_fn_23+0x2cd>
    2926:	mov    rdi,r13
    2929:	jmp    2953 <botlish_fn_23+0x2f2>
    292e:	mov    edx,0x9
    2933:	mov    ecx,0x1
    2938:	mov    rax,QWORD PTR [rip+0x0]        # 293f <botlish_fn_23+0x2de>
			293b: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    293f:	mov    rsi,r14
    2942:	mov    rdi,r13
    2945:	call   rax
    2947:	test   rax,rax
    294a:	jne    2981 <botlish_fn_23+0x320>
    2950:	mov    rdi,r13
    2953:	mov    rdi,r13
    2956:	mov    QWORD PTR [rdi],r12
    2959:	xor    rax,rax
    295c:	mov    rbx,QWORD PTR [rsp+0x50]
    2961:	mov    r12,QWORD PTR [rsp+0x58]
    2966:	mov    r13,QWORD PTR [rsp+0x60]
    296b:	mov    r14,QWORD PTR [rsp+0x68]
    2970:	mov    r15,QWORD PTR [rsp+0x70]
    2975:	add    rsp,0x80
    297c:	mov    rsp,rbp
    297f:	pop    rbp
    2980:	ret
    2981:	mov    rdi,r13
    2984:	mov    QWORD PTR [rdi],r12
    2987:	mov    eax,0xa
    298c:	mov    rbx,QWORD PTR [rsp+0x50]
    2991:	mov    r12,QWORD PTR [rsp+0x58]
    2996:	mov    r13,QWORD PTR [rsp+0x60]
    299b:	mov    r14,QWORD PTR [rsp+0x68]
    29a0:	mov    r15,QWORD PTR [rsp+0x70]
    29a5:	add    rsp,0x80
    29ac:	mov    rsp,rbp
    29af:	pop    rbp
    29b0:	ret
    29b1:	mov    r13,rdi
    29b4:	mov    rax,QWORD PTR [rip+0x0]        # 29bb <botlish_fn_23+0x35a>
			29b7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    29bb:	call   rax
    29bd:	xor    rax,rax
    29c0:	mov    rbx,QWORD PTR [rsp+0x50]
    29c5:	mov    r12,QWORD PTR [rsp+0x58]
    29ca:	mov    r13,QWORD PTR [rsp+0x60]
    29cf:	mov    r14,QWORD PTR [rsp+0x68]
    29d4:	mov    r15,QWORD PTR [rsp+0x70]
    29d9:	add    rsp,0x80
    29e0:	mov    rsp,rbp
    29e3:	pop    rbp
    29e4:	ret

00000000000029e5 <botlish_entry_23: ht_rehash<mutarray, int>>:
    29e5:	push   rbp
    29e6:	mov    rbp,rsp
    29e9:	mov    rsi,QWORD PTR [rdx]
    29ec:	mov    rdx,QWORD PTR [rdx+0x8]
    29f0:	call   29f5 <botlish_entry_23+0x10>
			29f1: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    29f5:	mov    rsp,rbp
    29f8:	pop    rbp
    29f9:	ret
    29fa:	add    BYTE PTR [rax],al
    29fc:	add    BYTE PTR [rax],al
	...

0000000000002a00 <botlish_fn_24: ht_should_grow<mutarray>>:
    2a00:	push   rbp
    2a01:	mov    rbp,rsp
    2a04:	sub    rsp,0x20
    2a08:	mov    QWORD PTR [rsp],rbx
    2a0c:	mov    QWORD PTR [rsp+0x8],r12
    2a11:	mov    QWORD PTR [rsp+0x10],r13
    2a16:	mov    QWORD PTR [rsp+0x18],r15
    2a1b:	mov    r15,QWORD PTR [rdi]
    2a1e:	mov    rax,QWORD PTR [rdi+0x8]
    2a22:	lea    rcx,[r15+0x18]
    2a26:	cmp    rcx,rax
    2a29:	ja     2d56 <botlish_fn_24+0x356>
    2a2f:	lea    rax,[r15+0x18]
    2a33:	mov    QWORD PTR [rdi],rax
    2a36:	mov    rbx,rdi
    2a39:	mov    QWORD PTR [r15],0x0
    2a40:	mov    QWORD PTR [r15+0x8],0x0
    2a48:	mov    QWORD PTR [r15+0x10],0x0
    2a50:	mov    QWORD PTR [r15],rsi
    2a53:	mov    r12,rsi
    2a56:	mov    rsi,r12
    2a59:	mov    rdi,rbx
    2a5c:	call   2a61 <botlish_fn_24+0x61>
			2a5d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2a61:	mov    rcx,rax
    2a64:	mov    r13,rax
    2a67:	test   rax,rcx
    2a6a:	jne    2a78 <botlish_fn_24+0x78>
    2a70:	mov    rdi,rbx
    2a73:	jmp    2c68 <botlish_fn_24+0x268>
    2a78:	mov    rax,r13
    2a7b:	mov    QWORD PTR [r15+0x8],rax
    2a7f:	mov    rsi,r12
    2a82:	mov    rdi,rbx
    2a85:	call   2a8a <botlish_fn_24+0x8a>
			2a86: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2a8a:	mov    rcx,rax
    2a8d:	test   rcx,rcx
    2a90:	jne    2a9e <botlish_fn_24+0x9e>
    2a96:	mov    rdi,rbx
    2a99:	jmp    2c68 <botlish_fn_24+0x268>
    2a9e:	mov    QWORD PTR [r15+0x10],rcx
    2aa2:	mov    edx,0x1
    2aa7:	mov    rax,r13
    2aaa:	test   rax,0x1
    2ab0:	jne    2ad3 <botlish_fn_24+0xd3>
    2ab6:	xor    edx,edx
    2ab8:	mov    rax,r13
    2abb:	test   rax,0x7
    2ac1:	jne    2ad3 <botlish_fn_24+0xd3>
    2ac7:	mov    rax,r13
    2aca:	movzx  rax,BYTE PTR [rax]
    2ace:	cmp    al,0x1
    2ad0:	sete   dl
    2ad3:	test   dl,dl
    2ad5:	jne    2afd <botlish_fn_24+0xfd>
    2adb:	mov    rdi,rbx
    2ade:	mov    rax,QWORD PTR [rdi+0x10]
    2ae2:	mov    rcx,QWORD PTR [rax+0x10]
    2ae6:	xor    rdx,rdx
    2ae9:	mov    rax,QWORD PTR [rip+0x0]        # 2af0 <botlish_fn_24+0xf0>
			2aec: R_X86_64_GOTPCREL	rt_type_error-0x4
    2af0:	mov    rsi,r13
    2af3:	call   rax
    2af5:	mov    rdi,rbx
    2af8:	jmp    2c68 <botlish_fn_24+0x268>
    2afd:	mov    eax,0x1
    2b02:	test   rcx,0x1
    2b09:	je     2b17 <botlish_fn_24+0x117>
    2b0f:	mov    r8,rcx
    2b12:	jmp    2b3a <botlish_fn_24+0x13a>
    2b17:	xor    eax,eax
    2b19:	test   rcx,0x7
    2b20:	je     2b2e <botlish_fn_24+0x12e>
    2b26:	mov    r8,rcx
    2b29:	jmp    2b3a <botlish_fn_24+0x13a>
    2b2e:	movzx  rax,BYTE PTR [rcx]
    2b32:	mov    r8,rcx
    2b35:	cmp    al,0x1
    2b37:	sete   al
    2b3a:	test   al,al
    2b3c:	jne    2b64 <botlish_fn_24+0x164>
    2b42:	mov    rdi,rbx
    2b45:	mov    rax,QWORD PTR [rdi+0x10]
    2b49:	mov    rcx,QWORD PTR [rax+0x10]
    2b4d:	xor    rdx,rdx
    2b50:	mov    rax,QWORD PTR [rip+0x0]        # 2b57 <botlish_fn_24+0x157>
			2b53: R_X86_64_GOTPCREL	rt_type_error-0x4
    2b57:	mov    rsi,r8
    2b5a:	call   rax
    2b5c:	mov    rdi,rbx
    2b5f:	jmp    2c68 <botlish_fn_24+0x268>
    2b64:	mov    rcx,r8
    2b67:	mov    rsi,r13
    2b6a:	mov    rax,rsi
    2b6d:	and    rax,rcx
    2b70:	test   rax,0x1
    2b76:	je     2b94 <botlish_fn_24+0x194>
    2b7c:	mov    rcx,r8
    2b7f:	lea    rax,[rcx-0x1]
    2b83:	mov    rsi,r13
    2b86:	add    rsi,rax
    2b89:	seto   al
    2b8c:	test   al,al
    2b8e:	je     2ba9 <botlish_fn_24+0x1a9>
    2b94:	mov    rax,QWORD PTR [rip+0x0]        # 2b9b <botlish_fn_24+0x19b>
			2b97: R_X86_64_GOTPCREL	rt_int_add-0x4
    2b9b:	mov    rdx,r8
    2b9e:	mov    rsi,r13
    2ba1:	mov    rdi,rbx
    2ba4:	call   rax
    2ba6:	mov    rsi,rax
    2ba9:	mov    QWORD PTR [r15+0x8],rsi
    2bad:	mov    QWORD PTR [r15+0x10],0x3
    2bb5:	test   rsi,0x1
    2bbc:	je     2bde <botlish_fn_24+0x1de>
    2bc2:	mov    rax,rsi
    2bc5:	add    rax,0x2
    2bc9:	seto   dil
    2bcd:	test   dil,dil
    2bd0:	jne    2bde <botlish_fn_24+0x1de>
    2bd6:	mov    rsi,rax
    2bd9:	jmp    2bf3 <botlish_fn_24+0x1f3>
    2bde:	mov    edx,0x3
    2be3:	mov    r8,QWORD PTR [rip+0x0]        # 2bea <botlish_fn_24+0x1ea>
			2be6: R_X86_64_GOTPCREL	rt_int_add-0x4
    2bea:	mov    rdi,rbx
    2bed:	call   r8
    2bf0:	mov    rsi,rax
    2bf3:	mov    QWORD PTR [r15+0x8],rsi
    2bf7:	mov    edx,0x7
    2bfc:	mov    rdi,rdx
    2bff:	mov    QWORD PTR [r15+0x10],0x7
    2c07:	test   rsi,0x1
    2c0e:	je     2c38 <botlish_fn_24+0x238>
    2c14:	mov    rax,rsi
    2c17:	sar    rax,1
    2c1a:	imul   QWORD PTR [rip+0x167]        # 2d88 <botlish_fn_24+0x388>
    2c21:	seto   cl
    2c24:	or     rax,0x1
    2c28:	test   cl,cl
    2c2a:	jne    2c38 <botlish_fn_24+0x238>
    2c30:	mov    rsi,rax
    2c33:	jmp    2c4a <botlish_fn_24+0x24a>
    2c38:	mov    rax,QWORD PTR [rip+0x0]        # 2c3f <botlish_fn_24+0x23f>
			2c3b: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2c3f:	mov    rdx,rdi
    2c42:	mov    rdi,rbx
    2c45:	call   rax
    2c47:	mov    rsi,rax
    2c4a:	mov    QWORD PTR [r15+0x8],rsi
    2c4e:	mov    r13,rsi
    2c51:	mov    rsi,r12
    2c54:	mov    rdi,rbx
    2c57:	call   2c5c <botlish_fn_24+0x25c>
			2c58: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2c5c:	test   rax,rax
    2c5f:	jne    2c8d <botlish_fn_24+0x28d>
    2c65:	mov    rdi,rbx
    2c68:	mov    rdi,rbx
    2c6b:	mov    QWORD PTR [rdi],r15
    2c6e:	xor    rax,rax
    2c71:	mov    rbx,QWORD PTR [rsp]
    2c75:	mov    r12,QWORD PTR [rsp+0x8]
    2c7a:	mov    r13,QWORD PTR [rsp+0x10]
    2c7f:	mov    r15,QWORD PTR [rsp+0x18]
    2c84:	add    rsp,0x20
    2c88:	mov    rsp,rbp
    2c8b:	pop    rbp
    2c8c:	ret
    2c8d:	mov    QWORD PTR [r15],rax
    2c90:	mov    QWORD PTR [r15+0x10],0x5
    2c98:	test   rax,0x1
    2c9e:	mov    rsi,rax
    2ca1:	je     2cd1 <botlish_fn_24+0x2d1>
    2ca7:	mov    rcx,rsi
    2caa:	mov    rax,rcx
    2cad:	sar    rax,1
    2cb0:	imul   QWORD PTR [rip+0xd9]        # 2d90 <botlish_fn_24+0x390>
    2cb7:	seto   cl
    2cba:	or     rax,0x1
    2cbe:	test   cl,cl
    2cc0:	jne    2cd1 <botlish_fn_24+0x2d1>
    2cc6:	mov    rdx,rax
    2cc9:	mov    rsi,r13
    2ccc:	jmp    2ce8 <botlish_fn_24+0x2e8>
    2cd1:	mov    edx,0x5
    2cd6:	mov    rax,QWORD PTR [rip+0x0]        # 2cdd <botlish_fn_24+0x2dd>
			2cd9: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2cdd:	mov    rdi,rbx
    2ce0:	call   rax
    2ce2:	mov    rdx,rax
    2ce5:	mov    rsi,r13
    2ce8:	mov    rax,rsi
    2ceb:	and    rax,rdx
    2cee:	test   rax,0x1
    2cf4:	jne    2d21 <botlish_fn_24+0x321>
    2cfa:	mov    rax,QWORD PTR [rip+0x0]        # 2d01 <botlish_fn_24+0x301>
			2cfd: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    2d01:	mov    rdi,rbx
    2d04:	call   rax
    2d06:	mov    ecx,0x2
    2d0b:	test   rax,rax
    2d0e:	mov    rax,rcx
    2d11:	cmovg  rax,QWORD PTR [rip+0x6f]        # 2d88 <botlish_fn_24+0x388>
    2d19:	mov    rdi,rbx
    2d1c:	jmp    2d34 <botlish_fn_24+0x334>
    2d21:	mov    eax,0x2
    2d26:	cmp    rsi,rdx
    2d29:	cmovg  rax,QWORD PTR [rip+0x57]        # 2d88 <botlish_fn_24+0x388>
    2d31:	mov    rdi,rbx
    2d34:	mov    rdi,rbx
    2d37:	mov    QWORD PTR [rdi],r15
    2d3a:	mov    rbx,QWORD PTR [rsp]
    2d3e:	mov    r12,QWORD PTR [rsp+0x8]
    2d43:	mov    r13,QWORD PTR [rsp+0x10]
    2d48:	mov    r15,QWORD PTR [rsp+0x18]
    2d4d:	add    rsp,0x20
    2d51:	mov    rsp,rbp
    2d54:	pop    rbp
    2d55:	ret
    2d56:	mov    rbx,rdi
    2d59:	mov    rax,QWORD PTR [rip+0x0]        # 2d60 <botlish_fn_24+0x360>
			2d5c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2d60:	call   rax
    2d62:	xor    rax,rax
    2d65:	mov    rbx,QWORD PTR [rsp]
    2d69:	mov    r12,QWORD PTR [rsp+0x8]
    2d6e:	mov    r13,QWORD PTR [rsp+0x10]
    2d73:	mov    r15,QWORD PTR [rsp+0x18]
    2d78:	add    rsp,0x20
    2d7c:	mov    rsp,rbp
    2d7f:	pop    rbp
    2d80:	ret
    2d81:	add    BYTE PTR [rax],al
    2d83:	add    BYTE PTR [rax],al
    2d85:	add    BYTE PTR [rax],al
    2d87:	add    BYTE PTR [rsi],al
    2d89:	add    BYTE PTR [rax],al
    2d8b:	add    BYTE PTR [rax],al
    2d8d:	add    BYTE PTR [rax],al
    2d8f:	add    BYTE PTR [rax+rax*1],al
    2d92:	add    BYTE PTR [rax],al
    2d94:	add    BYTE PTR [rax],al
	...

0000000000002d98 <botlish_entry_24: ht_should_grow<mutarray>>:
    2d98:	push   rbp
    2d99:	mov    rbp,rsp
    2d9c:	mov    rsi,QWORD PTR [rdx]
    2d9f:	call   2da4 <botlish_entry_24+0xc>
			2da0: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2da4:	mov    rsp,rbp
    2da7:	pop    rbp
    2da8:	ret
    2da9:	add    BYTE PTR [rax],al
    2dab:	add    BYTE PTR [rax],al
    2dad:	add    BYTE PTR [rax],al
	...

0000000000002db0 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    2db0:	push   rbp
    2db1:	mov    rbp,rsp
    2db4:	sub    rsp,0x20
    2db8:	mov    QWORD PTR [rsp],rbx
    2dbc:	mov    QWORD PTR [rsp+0x8],r12
    2dc1:	mov    QWORD PTR [rsp+0x10],r13
    2dc6:	mov    QWORD PTR [rsp+0x18],r14
    2dcb:	mov    rbx,QWORD PTR [rdi]
    2dce:	mov    rax,QWORD PTR [rdi+0x8]
    2dd2:	lea    rcx,[rbx+0x18]
    2dd6:	cmp    rcx,rax
    2dd9:	ja     3090 <botlish_fn_25+0x2e0>
    2ddf:	lea    rax,[rbx+0x18]
    2de3:	mov    QWORD PTR [rdi],rax
    2de6:	mov    r12,rdi
    2de9:	mov    QWORD PTR [rbx],0x0
    2df0:	mov    QWORD PTR [rbx+0x8],0x0
    2df8:	mov    QWORD PTR [rbx+0x10],0x0
    2e00:	mov    QWORD PTR [rbx],rsi
    2e03:	mov    r13,rsi
    2e06:	mov    rsi,r13
    2e09:	mov    rdi,r12
    2e0c:	call   2e11 <botlish_fn_25+0x61>
			2e0d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2e11:	test   rax,rax
    2e14:	jne    2e22 <botlish_fn_25+0x72>
    2e1a:	mov    rdi,r12
    2e1d:	jmp    3046 <botlish_fn_25+0x296>
    2e22:	mov    QWORD PTR [rbx+0x8],rax
    2e26:	mov    r14,rax
    2e29:	mov    rsi,r13
    2e2c:	mov    rdi,r12
    2e2f:	call   2e34 <botlish_fn_25+0x84>
			2e30: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2e34:	mov    rcx,rax
    2e37:	test   rcx,rcx
    2e3a:	jne    2e48 <botlish_fn_25+0x98>
    2e40:	mov    rdi,r12
    2e43:	jmp    3046 <botlish_fn_25+0x296>
    2e48:	mov    edx,0x1
    2e4d:	mov    rax,r14
    2e50:	test   rax,0x1
    2e56:	je     2e64 <botlish_fn_25+0xb4>
    2e5c:	mov    r14,rax
    2e5f:	jmp    2e88 <botlish_fn_25+0xd8>
    2e64:	xor    edx,edx
    2e66:	test   rax,0x7
    2e6c:	je     2e7a <botlish_fn_25+0xca>
    2e72:	mov    r14,rax
    2e75:	jmp    2e88 <botlish_fn_25+0xd8>
    2e7a:	movzx  rdx,BYTE PTR [rax]
    2e7e:	mov    r14,rax
    2e81:	rex cmp dl,0x1
    2e85:	sete   dl
    2e88:	test   dl,dl
    2e8a:	jne    2eb2 <botlish_fn_25+0x102>
    2e90:	mov    rdi,r12
    2e93:	mov    rax,QWORD PTR [rdi+0x10]
    2e97:	mov    rcx,QWORD PTR [rax+0x18]
    2e9b:	xor    rdx,rdx
    2e9e:	mov    rax,QWORD PTR [rip+0x0]        # 2ea5 <botlish_fn_25+0xf5>
			2ea1: R_X86_64_GOTPCREL	rt_type_error-0x4
    2ea5:	mov    rsi,r14
    2ea8:	call   rax
    2eaa:	mov    rdi,r12
    2ead:	jmp    3046 <botlish_fn_25+0x296>
    2eb2:	mov    rsi,r14
    2eb5:	mov    eax,0x1
    2eba:	test   rcx,0x1
    2ec1:	je     2ecf <botlish_fn_25+0x11f>
    2ec7:	mov    r8,rcx
    2eca:	jmp    2ef2 <botlish_fn_25+0x142>
    2ecf:	xor    eax,eax
    2ed1:	test   rcx,0x7
    2ed8:	je     2ee6 <botlish_fn_25+0x136>
    2ede:	mov    r8,rcx
    2ee1:	jmp    2ef2 <botlish_fn_25+0x142>
    2ee6:	movzx  rax,BYTE PTR [rcx]
    2eea:	mov    r8,rcx
    2eed:	cmp    al,0x1
    2eef:	sete   al
    2ef2:	test   al,al
    2ef4:	jne    2f1c <botlish_fn_25+0x16c>
    2efa:	mov    rdi,r12
    2efd:	mov    rax,QWORD PTR [rdi+0x10]
    2f01:	mov    rcx,QWORD PTR [rax+0x18]
    2f05:	xor    rdx,rdx
    2f08:	mov    rax,QWORD PTR [rip+0x0]        # 2f0f <botlish_fn_25+0x15f>
			2f0b: R_X86_64_GOTPCREL	rt_type_error-0x4
    2f0f:	mov    rsi,r8
    2f12:	call   rax
    2f14:	mov    rdi,r12
    2f17:	jmp    3046 <botlish_fn_25+0x296>
    2f1c:	mov    rcx,r8
    2f1f:	mov    rax,rsi
    2f22:	and    rax,rcx
    2f25:	test   rax,0x1
    2f2b:	jne    2f55 <botlish_fn_25+0x1a5>
    2f31:	mov    rax,QWORD PTR [rip+0x0]        # 2f38 <botlish_fn_25+0x188>
			2f34: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    2f38:	mov    rdx,r8
    2f3b:	mov    rdi,r12
    2f3e:	call   rax
    2f40:	mov    ecx,0x2
    2f45:	test   rax,rax
    2f48:	cmovg  rcx,QWORD PTR [rip+0x170]        # 30c0 <botlish_fn_25+0x310>
    2f50:	jmp    2f68 <botlish_fn_25+0x1b8>
    2f55:	mov    ecx,0x2
    2f5a:	mov    rax,r8
    2f5d:	cmp    rsi,rax
    2f60:	cmovg  rcx,QWORD PTR [rip+0x158]        # 30c0 <botlish_fn_25+0x310>
    2f68:	cmp    rcx,0x6
    2f6c:	je     300c <botlish_fn_25+0x25c>
    2f72:	mov    rsi,r13
    2f75:	mov    rdi,r12
    2f78:	call   2f7d <botlish_fn_25+0x1cd>
			2f79: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2f7d:	test   rax,rax
    2f80:	jne    2f8e <botlish_fn_25+0x1de>
    2f86:	mov    rdi,r12
    2f89:	jmp    3046 <botlish_fn_25+0x296>
    2f8e:	mov    QWORD PTR [rbx+0x8],rax
    2f92:	mov    QWORD PTR [rbx+0x10],0x5
    2f9a:	test   rax,0x1
    2fa0:	mov    rsi,rax
    2fa3:	je     2fd0 <botlish_fn_25+0x220>
    2fa9:	mov    rcx,rsi
    2fac:	mov    rax,rcx
    2faf:	sar    rax,1
    2fb2:	imul   QWORD PTR [rip+0x10f]        # 30c8 <botlish_fn_25+0x318>
    2fb9:	seto   cl
    2fbc:	or     rax,0x1
    2fc0:	test   cl,cl
    2fc2:	jne    2fd0 <botlish_fn_25+0x220>
    2fc8:	mov    rdx,rax
    2fcb:	jmp    2fe4 <botlish_fn_25+0x234>
    2fd0:	mov    edx,0x5
    2fd5:	mov    rax,QWORD PTR [rip+0x0]        # 2fdc <botlish_fn_25+0x22c>
			2fd8: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2fdc:	mov    rdi,r12
    2fdf:	call   rax
    2fe1:	mov    rdx,rax
    2fe4:	mov    QWORD PTR [rbx+0x8],rdx
    2fe8:	mov    rsi,r13
    2feb:	mov    rdi,r12
    2fee:	call   2ff3 <botlish_fn_25+0x243>
			2fef: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2ff3:	test   rax,rax
    2ff6:	jne    3004 <botlish_fn_25+0x254>
    2ffc:	mov    rdi,r12
    2fff:	jmp    3046 <botlish_fn_25+0x296>
    3004:	mov    rdi,r12
    3007:	jmp    306e <botlish_fn_25+0x2be>
    300c:	mov    rsi,r13
    300f:	mov    rdi,r12
    3012:	call   3017 <botlish_fn_25+0x267>
			3013: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    3017:	test   rax,rax
    301a:	jne    3028 <botlish_fn_25+0x278>
    3020:	mov    rdi,r12
    3023:	jmp    3046 <botlish_fn_25+0x296>
    3028:	mov    QWORD PTR [rbx+0x8],rax
    302c:	mov    rdx,rax
    302f:	mov    rsi,r13
    3032:	mov    rdi,r12
    3035:	call   303a <botlish_fn_25+0x28a>
			3036: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    303a:	test   rax,rax
    303d:	jne    306b <botlish_fn_25+0x2bb>
    3043:	mov    rdi,r12
    3046:	mov    rdi,r12
    3049:	mov    QWORD PTR [rdi],rbx
    304c:	xor    rax,rax
    304f:	mov    rbx,QWORD PTR [rsp]
    3053:	mov    r12,QWORD PTR [rsp+0x8]
    3058:	mov    r13,QWORD PTR [rsp+0x10]
    305d:	mov    r14,QWORD PTR [rsp+0x18]
    3062:	add    rsp,0x20
    3066:	mov    rsp,rbp
    3069:	pop    rbp
    306a:	ret
    306b:	mov    rdi,r12
    306e:	mov    rdi,r12
    3071:	mov    QWORD PTR [rdi],rbx
    3074:	mov    rbx,QWORD PTR [rsp]
    3078:	mov    r12,QWORD PTR [rsp+0x8]
    307d:	mov    r13,QWORD PTR [rsp+0x10]
    3082:	mov    r14,QWORD PTR [rsp+0x18]
    3087:	add    rsp,0x20
    308b:	mov    rsp,rbp
    308e:	pop    rbp
    308f:	ret
    3090:	mov    r12,rdi
    3093:	mov    r8,QWORD PTR [rip+0x0]        # 309a <botlish_fn_25+0x2ea>
			3096: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    309a:	call   r8
    309d:	xor    rax,rax
    30a0:	mov    rbx,QWORD PTR [rsp]
    30a4:	mov    r12,QWORD PTR [rsp+0x8]
    30a9:	mov    r13,QWORD PTR [rsp+0x10]
    30ae:	mov    r14,QWORD PTR [rsp+0x18]
    30b3:	add    rsp,0x20
    30b7:	mov    rsp,rbp
    30ba:	pop    rbp
    30bb:	ret
    30bc:	add    BYTE PTR [rax],al
    30be:	add    BYTE PTR [rax],al
    30c0:	(bad)
    30c1:	add    BYTE PTR [rax],al
    30c3:	add    BYTE PTR [rax],al
    30c5:	add    BYTE PTR [rax],al
    30c7:	add    BYTE PTR [rax+rax*1],al
    30ca:	add    BYTE PTR [rax],al
    30cc:	add    BYTE PTR [rax],al
	...

00000000000030d0 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    30d0:	push   rbp
    30d1:	mov    rbp,rsp
    30d4:	mov    rsi,QWORD PTR [rdx]
    30d7:	call   30dc <botlish_entry_25+0xc>
			30d8: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    30dc:	mov    rsp,rbp
    30df:	pop    rbp
    30e0:	ret
    30e1:	add    BYTE PTR [rax],al
    30e3:	add    BYTE PTR [rax],al
    30e5:	add    BYTE PTR [rax],al
	...

00000000000030e8 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    30e8:	push   rbp
    30e9:	mov    rbp,rsp
    30ec:	sub    rsp,0x50
    30f0:	mov    QWORD PTR [rsp+0x20],rbx
    30f5:	mov    QWORD PTR [rsp+0x28],r12
    30fa:	mov    QWORD PTR [rsp+0x30],r13
    30ff:	mov    QWORD PTR [rsp+0x38],r14
    3104:	mov    QWORD PTR [rsp+0x40],r15
    3109:	mov    r12,QWORD PTR [rdi]
    310c:	mov    rax,QWORD PTR [rdi+0x8]
    3110:	lea    r9,[r12+0x30]
    3115:	cmp    r9,rax
    3118:	ja     3658 <botlish_fn_26+0x570>
    311e:	lea    rax,[r12+0x30]
    3123:	mov    QWORD PTR [rdi],rax
    3126:	mov    r13,rdi
    3129:	mov    QWORD PTR [r12],0x0
    3131:	mov    QWORD PTR [r12+0x8],0x0
    313a:	mov    QWORD PTR [r12+0x10],0x0
    3143:	mov    QWORD PTR [r12+0x18],0x0
    314c:	mov    QWORD PTR [r12+0x20],0x0
    3155:	mov    QWORD PTR [r12+0x28],0x0
    315e:	mov    QWORD PTR [r12],rsi
    3162:	mov    r14,rsi
    3165:	mov    QWORD PTR [r12+0x8],rdx
    316a:	mov    QWORD PTR [rsp],rdx
    316e:	mov    QWORD PTR [r12+0x10],rcx
    3173:	mov    QWORD PTR [rsp+0x8],rcx
    3178:	mov    QWORD PTR [r12+0x18],r8
    317d:	mov    r15,r8
    3180:	mov    rsi,r14
    3183:	mov    rdi,r13
    3186:	call   318b <botlish_fn_26+0xa3>
			3187: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    318b:	test   rax,rax
    318e:	jne    319c <botlish_fn_26+0xb4>
    3194:	mov    rdi,r13
    3197:	jmp    35fd <botlish_fn_26+0x515>
    319c:	mov    QWORD PTR [r12+0x20],rax
    31a1:	xor    ecx,ecx
    31a3:	test   rax,0x7
    31a9:	je     31b9 <botlish_fn_26+0xd1>
    31af:	mov    QWORD PTR [rsp+0x10],rax
    31b4:	jmp    31c9 <botlish_fn_26+0xe1>
    31b9:	movzx  rsi,BYTE PTR [rax]
    31bd:	mov    QWORD PTR [rsp+0x10],rax
    31c2:	cmp    sil,0x8
    31c6:	sete   cl
    31c9:	test   cl,cl
    31cb:	jne    31f8 <botlish_fn_26+0x110>
    31d1:	mov    rdi,r13
    31d4:	mov    r9,QWORD PTR [rdi+0x10]
    31d8:	mov    rcx,QWORD PTR [r9+0x8]
    31dc:	mov    edx,0x8
    31e1:	mov    r9,QWORD PTR [rip+0x0]        # 31e8 <botlish_fn_26+0x100>
			31e4: R_X86_64_GOTPCREL	rt_type_error-0x4
    31e8:	mov    rsi,QWORD PTR [rsp+0x10]
    31ed:	call   r9
    31f0:	mov    rdi,r13
    31f3:	jmp    35fd <botlish_fn_26+0x515>
    31f8:	mov    r10,QWORD PTR [rip+0x0]        # 31ff <botlish_fn_26+0x117>
			31fb: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    31ff:	mov    rdx,QWORD PTR [rsp]
    3203:	mov    rsi,QWORD PTR [rsp+0x10]
    3208:	mov    rdi,r13
    320b:	call   r10
    320e:	mov    rbx,rax
    3211:	test   rbx,rbx
    3214:	jne    3222 <botlish_fn_26+0x13a>
    321a:	mov    rdi,r13
    321d:	jmp    35fd <botlish_fn_26+0x515>
    3222:	mov    QWORD PTR [r12+0x28],rbx
    3227:	mov    rdi,r13
    322a:	call   322f <botlish_fn_26+0x147>
			322b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    322f:	test   rax,rax
    3232:	mov    rcx,rax
    3235:	jne    3243 <botlish_fn_26+0x15b>
    323b:	mov    rdi,r13
    323e:	jmp    35fd <botlish_fn_26+0x515>
    3243:	mov    rax,QWORD PTR [rip+0x0]        # 324a <botlish_fn_26+0x162>
			3246: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    324a:	mov    rsi,QWORD PTR [rsp+0x10]
    324f:	mov    rdx,QWORD PTR [rsp]
    3253:	mov    rdi,r13
    3256:	call   rax
    3258:	test   rax,rax
    325b:	jne    3269 <botlish_fn_26+0x181>
    3261:	mov    rdi,r13
    3264:	jmp    35fd <botlish_fn_26+0x515>
    3269:	mov    rsi,r14
    326c:	mov    rdi,r13
    326f:	call   3274 <botlish_fn_26+0x18c>
			3270: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    3274:	test   rax,rax
    3277:	jne    3285 <botlish_fn_26+0x19d>
    327d:	mov    rdi,r13
    3280:	jmp    35fd <botlish_fn_26+0x515>
    3285:	xor    esi,esi
    3287:	test   rax,0x7
    328d:	je     329b <botlish_fn_26+0x1b3>
    3293:	mov    r8,rax
    3296:	jmp    32aa <botlish_fn_26+0x1c2>
    329b:	movzx  rcx,BYTE PTR [rax]
    329f:	mov    r8,rax
    32a2:	rex cmp cl,0x8
    32a6:	sete   sil
    32aa:	test   sil,sil
    32ad:	jne    32d7 <botlish_fn_26+0x1ef>
    32b3:	mov    rdi,r13
    32b6:	mov    rax,QWORD PTR [rdi+0x10]
    32ba:	mov    rcx,QWORD PTR [rax+0x20]
    32be:	mov    edx,0x8
    32c3:	mov    rax,QWORD PTR [rip+0x0]        # 32ca <botlish_fn_26+0x1e2>
			32c6: R_X86_64_GOTPCREL	rt_type_error-0x4
    32ca:	mov    rsi,r8
    32cd:	call   rax
    32cf:	mov    rdi,r13
    32d2:	jmp    35fd <botlish_fn_26+0x515>
    32d7:	mov    rsi,r8
    32da:	mov    rax,QWORD PTR [rip+0x0]        # 32e1 <botlish_fn_26+0x1f9>
			32dd: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    32e1:	mov    rcx,QWORD PTR [rsp+0x8]
    32e6:	mov    rdx,QWORD PTR [rsp]
    32ea:	mov    rdi,r13
    32ed:	call   rax
    32ef:	test   rax,rax
    32f2:	jne    3300 <botlish_fn_26+0x218>
    32f8:	mov    rdi,r13
    32fb:	jmp    35fd <botlish_fn_26+0x515>
    3300:	mov    rsi,r14
    3303:	mov    rdi,r13
    3306:	call   330b <botlish_fn_26+0x223>
			3307: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    330b:	test   rax,rax
    330e:	jne    331c <botlish_fn_26+0x234>
    3314:	mov    rdi,r13
    3317:	jmp    35fd <botlish_fn_26+0x515>
    331c:	xor    ecx,ecx
    331e:	test   rax,0x7
    3324:	je     3332 <botlish_fn_26+0x24a>
    332a:	mov    rsi,rax
    332d:	jmp    3340 <botlish_fn_26+0x258>
    3332:	movzx  rcx,BYTE PTR [rax]
    3336:	mov    rsi,rax
    3339:	rex cmp cl,0x8
    333d:	sete   cl
    3340:	test   cl,cl
    3342:	jne    3369 <botlish_fn_26+0x281>
    3348:	mov    rdi,r13
    334b:	mov    rax,QWORD PTR [rdi+0x10]
    334f:	mov    rcx,QWORD PTR [rax+0x20]
    3353:	mov    edx,0x8
    3358:	mov    rax,QWORD PTR [rip+0x0]        # 335f <botlish_fn_26+0x277>
			335b: R_X86_64_GOTPCREL	rt_type_error-0x4
    335f:	call   rax
    3361:	mov    rdi,r13
    3364:	jmp    35fd <botlish_fn_26+0x515>
    3369:	mov    rax,QWORD PTR [rip+0x0]        # 3370 <botlish_fn_26+0x288>
			336c: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3370:	mov    rcx,r15
    3373:	mov    rdx,QWORD PTR [rsp]
    3377:	mov    rdi,r13
    337a:	call   rax
    337c:	test   rax,rax
    337f:	jne    338d <botlish_fn_26+0x2a5>
    3385:	mov    rdi,r13
    3388:	jmp    35fd <botlish_fn_26+0x515>
    338d:	mov    QWORD PTR [r12+0x8],0x7
    3396:	mov    rsi,r14
    3399:	mov    rdi,r13
    339c:	call   33a1 <botlish_fn_26+0x2b9>
			339d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    33a1:	test   rax,rax
    33a4:	jne    33b2 <botlish_fn_26+0x2ca>
    33aa:	mov    rdi,r13
    33ad:	jmp    35fd <botlish_fn_26+0x515>
    33b2:	mov    QWORD PTR [r12+0x10],rax
    33b7:	mov    QWORD PTR [r12+0x18],0x3
    33c0:	mov    ecx,0x1
    33c5:	test   rax,0x1
    33cb:	je     33d9 <botlish_fn_26+0x2f1>
    33d1:	mov    rsi,rax
    33d4:	jmp    33fd <botlish_fn_26+0x315>
    33d9:	xor    ecx,ecx
    33db:	test   rax,0x7
    33e1:	je     33ef <botlish_fn_26+0x307>
    33e7:	mov    rsi,rax
    33ea:	jmp    33fd <botlish_fn_26+0x315>
    33ef:	movzx  rcx,BYTE PTR [rax]
    33f3:	mov    rsi,rax
    33f6:	rex cmp cl,0x1
    33fa:	sete   cl
    33fd:	test   cl,cl
    33ff:	jne    3425 <botlish_fn_26+0x33d>
    3405:	mov    rdi,r13
    3408:	mov    rcx,QWORD PTR [rdi+0x10]
    340c:	mov    rcx,QWORD PTR [rcx+0x10]
    3410:	xor    rdx,rdx
    3413:	mov    r8,QWORD PTR [rip+0x0]        # 341a <botlish_fn_26+0x332>
			3416: R_X86_64_GOTPCREL	rt_type_error-0x4
    341a:	call   r8
    341d:	mov    rdi,r13
    3420:	jmp    35fd <botlish_fn_26+0x515>
    3425:	test   rsi,0x1
    342c:	je     3446 <botlish_fn_26+0x35e>
    3432:	mov    rcx,rsi
    3435:	add    rcx,0x2
    3439:	seto   dil
    343d:	test   dil,dil
    3440:	je     345b <botlish_fn_26+0x373>
    3446:	mov    edx,0x3
    344b:	mov    r9,QWORD PTR [rip+0x0]        # 3452 <botlish_fn_26+0x36a>
			344e: R_X86_64_GOTPCREL	rt_int_add-0x4
    3452:	mov    rdi,r13
    3455:	call   r9
    3458:	mov    rcx,rax
    345b:	mov    edx,0x7
    3460:	mov    r10,QWORD PTR [rip+0x0]        # 3467 <botlish_fn_26+0x37f>
			3463: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3467:	mov    rsi,r14
    346a:	mov    rdi,r13
    346d:	call   r10
    3470:	test   rax,rax
    3473:	jne    3481 <botlish_fn_26+0x399>
    3479:	mov    rdi,r13
    347c:	jmp    35fd <botlish_fn_26+0x515>
    3481:	mov    rdi,r13
    3484:	call   3489 <botlish_fn_26+0x3a1>
			3485: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    3489:	test   rax,rax
    348c:	jne    349a <botlish_fn_26+0x3b2>
    3492:	mov    rdi,r13
    3495:	jmp    35fd <botlish_fn_26+0x515>
    349a:	mov    rcx,rbx
    349d:	and    rcx,rax
    34a0:	mov    rdx,rbx
    34a3:	mov    rsi,rax
    34a6:	test   rcx,0x1
    34ad:	jne    34d9 <botlish_fn_26+0x3f1>
    34b3:	mov    rax,QWORD PTR [rip+0x0]        # 34ba <botlish_fn_26+0x3d2>
			34b6: R_X86_64_GOTPCREL	rt_value_eq-0x4
    34ba:	mov    rcx,rdx
    34bd:	mov    rdx,rsi
    34c0:	mov    rsi,rcx
    34c3:	mov    rdi,r13
    34c6:	call   rax
    34c8:	test   rax,rax
    34cb:	jne    34f2 <botlish_fn_26+0x40a>
    34d1:	mov    rdi,r13
    34d4:	jmp    35fd <botlish_fn_26+0x515>
    34d9:	mov    rax,rdx
    34dc:	mov    rdx,rsi
    34df:	mov    rsi,rax
    34e2:	mov    eax,0x2
    34e7:	cmp    rsi,rdx
    34ea:	cmove  rax,QWORD PTR [rip+0x19e]        # 3690 <botlish_fn_26+0x5a8>
    34f2:	cmp    rax,0x6
    34f6:	je     3504 <botlish_fn_26+0x41c>
    34fc:	mov    rdi,r13
    34ff:	jmp    362b <botlish_fn_26+0x543>
    3504:	mov    QWORD PTR [r12+0x8],0x9
    350d:	mov    rsi,r14
    3510:	mov    rdi,r13
    3513:	call   3518 <botlish_fn_26+0x430>
			3514: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3518:	test   rax,rax
    351b:	jne    3529 <botlish_fn_26+0x441>
    3521:	mov    rdi,r13
    3524:	jmp    35fd <botlish_fn_26+0x515>
    3529:	mov    QWORD PTR [r12+0x10],rax
    352e:	mov    QWORD PTR [r12+0x18],0x3
    3537:	mov    esi,0x1
    353c:	test   rax,0x1
    3542:	je     3550 <botlish_fn_26+0x468>
    3548:	mov    r11,rax
    354b:	jmp    3575 <botlish_fn_26+0x48d>
    3550:	xor    esi,esi
    3552:	test   rax,0x7
    3558:	je     3566 <botlish_fn_26+0x47e>
    355e:	mov    r11,rax
    3561:	jmp    3575 <botlish_fn_26+0x48d>
    3566:	movzx  rcx,BYTE PTR [rax]
    356a:	mov    r11,rax
    356d:	rex cmp cl,0x1
    3571:	sete   sil
    3575:	test   sil,sil
    3578:	jne    35a0 <botlish_fn_26+0x4b8>
    357e:	mov    rdi,r13
    3581:	mov    rax,QWORD PTR [rdi+0x10]
    3585:	mov    rcx,QWORD PTR [rax+0x28]
    3589:	xor    rdx,rdx
    358c:	mov    rax,QWORD PTR [rip+0x0]        # 3593 <botlish_fn_26+0x4ab>
			358f: R_X86_64_GOTPCREL	rt_type_error-0x4
    3593:	mov    rsi,r11
    3596:	call   rax
    3598:	mov    rdi,r13
    359b:	jmp    35fd <botlish_fn_26+0x515>
    35a0:	mov    rsi,r11
    35a3:	test   rsi,0x1
    35aa:	je     35c9 <botlish_fn_26+0x4e1>
    35b0:	mov    rcx,rsi
    35b3:	sub    rcx,0x3
    35b7:	seto   al
    35ba:	add    rcx,0x1
    35c1:	test   al,al
    35c3:	je     35dd <botlish_fn_26+0x4f5>
    35c9:	mov    edx,0x3
    35ce:	mov    rax,QWORD PTR [rip+0x0]        # 35d5 <botlish_fn_26+0x4ed>
			35d1: R_X86_64_GOTPCREL	rt_int_sub-0x4
    35d5:	mov    rdi,r13
    35d8:	call   rax
    35da:	mov    rcx,rax
    35dd:	mov    edx,0x9
    35e2:	mov    rax,QWORD PTR [rip+0x0]        # 35e9 <botlish_fn_26+0x501>
			35e5: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    35e9:	mov    rsi,r14
    35ec:	mov    rdi,r13
    35ef:	call   rax
    35f1:	test   rax,rax
    35f4:	jne    3628 <botlish_fn_26+0x540>
    35fa:	mov    rdi,r13
    35fd:	mov    rdi,r13
    3600:	mov    QWORD PTR [rdi],r12
    3603:	xor    rax,rax
    3606:	mov    rbx,QWORD PTR [rsp+0x20]
    360b:	mov    r12,QWORD PTR [rsp+0x28]
    3610:	mov    r13,QWORD PTR [rsp+0x30]
    3615:	mov    r14,QWORD PTR [rsp+0x38]
    361a:	mov    r15,QWORD PTR [rsp+0x40]
    361f:	add    rsp,0x50
    3623:	mov    rsp,rbp
    3626:	pop    rbp
    3627:	ret
    3628:	mov    rdi,r13
    362b:	mov    rdi,r13
    362e:	mov    QWORD PTR [rdi],r12
    3631:	mov    eax,0xa
    3636:	mov    rbx,QWORD PTR [rsp+0x20]
    363b:	mov    r12,QWORD PTR [rsp+0x28]
    3640:	mov    r13,QWORD PTR [rsp+0x30]
    3645:	mov    r14,QWORD PTR [rsp+0x38]
    364a:	mov    r15,QWORD PTR [rsp+0x40]
    364f:	add    rsp,0x50
    3653:	mov    rsp,rbp
    3656:	pop    rbp
    3657:	ret
    3658:	mov    r13,rdi
    365b:	mov    rax,QWORD PTR [rip+0x0]        # 3662 <botlish_fn_26+0x57a>
			365e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3662:	call   rax
    3664:	xor    rax,rax
    3667:	mov    rbx,QWORD PTR [rsp+0x20]
    366c:	mov    r12,QWORD PTR [rsp+0x28]
    3671:	mov    r13,QWORD PTR [rsp+0x30]
    3676:	mov    r14,QWORD PTR [rsp+0x38]
    367b:	mov    r15,QWORD PTR [rsp+0x40]
    3680:	add    rsp,0x50
    3684:	mov    rsp,rbp
    3687:	pop    rbp
    3688:	ret
    3689:	add    BYTE PTR [rax],al
    368b:	add    BYTE PTR [rax],al
    368d:	add    BYTE PTR [rax],al
    368f:	add    BYTE PTR [rsi],al
    3691:	add    BYTE PTR [rax],al
    3693:	add    BYTE PTR [rax],al
    3695:	add    BYTE PTR [rax],al
	...

0000000000003698 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    3698:	push   rbp
    3699:	mov    rbp,rsp
    369c:	mov    rsi,QWORD PTR [rdx]
    369f:	mov    r9,QWORD PTR [rdx+0x8]
    36a3:	mov    rcx,QWORD PTR [rdx+0x10]
    36a7:	mov    r8,QWORD PTR [rdx+0x18]
    36ab:	mov    rdx,r9
    36ae:	call   36b3 <botlish_entry_26+0x1b>
			36af: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    36b3:	mov    rsp,rbp
    36b6:	pop    rbp
    36b7:	ret

00000000000036b8 <botlish_fn_27: ht_set<mutarray, str, str>>:
    36b8:	push   rbp
    36b9:	mov    rbp,rsp
    36bc:	sub    rsp,0x50
    36c0:	mov    QWORD PTR [rsp+0x20],rbx
    36c5:	mov    QWORD PTR [rsp+0x28],r12
    36ca:	mov    QWORD PTR [rsp+0x30],r13
    36cf:	mov    QWORD PTR [rsp+0x38],r14
    36d4:	mov    QWORD PTR [rsp+0x40],r15
    36d9:	mov    rbx,QWORD PTR [rdi]
    36dc:	mov    rax,QWORD PTR [rdi+0x8]
    36e0:	lea    r8,[rbx+0x28]
    36e4:	cmp    r8,rax
    36e7:	ja     3abc <botlish_fn_27+0x404>
    36ed:	lea    rax,[rbx+0x28]
    36f1:	mov    QWORD PTR [rdi],rax
    36f4:	mov    r12,rdi
    36f7:	mov    QWORD PTR [rbx],0x0
    36fe:	mov    QWORD PTR [rbx+0x8],0x0
    3706:	mov    QWORD PTR [rbx+0x10],0x0
    370e:	mov    QWORD PTR [rbx+0x18],0x0
    3716:	mov    QWORD PTR [rbx+0x20],0x0
    371e:	mov    QWORD PTR [rbx],rsi
    3721:	mov    r15,rsi
    3724:	mov    QWORD PTR [rbx+0x8],rdx
    3728:	mov    r14,rdx
    372b:	mov    QWORD PTR [rbx+0x10],rcx
    372f:	mov    r13,rcx
    3732:	mov    rdx,r14
    3735:	mov    rsi,r15
    3738:	mov    rdi,r12
    373b:	call   3740 <botlish_fn_27+0x88>
			373c: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3740:	test   rax,rax
    3743:	jne    3751 <botlish_fn_27+0x99>
    3749:	mov    rdi,r12
    374c:	jmp    3a64 <botlish_fn_27+0x3ac>
    3751:	mov    QWORD PTR [rbx+0x18],rax
    3755:	mov    rcx,rax
    3758:	mov    r8,0xffffffffffffffff
    375f:	mov    QWORD PTR [rsp+0x10],r8
    3764:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    376c:	mov    rdx,r14
    376f:	mov    rsi,r15
    3772:	mov    rdi,r12
    3775:	call   377a <botlish_fn_27+0xc2>
			3776: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    377a:	mov    rcx,rax
    377d:	mov    QWORD PTR [rsp+0x8],rax
    3782:	test   rax,rcx
    3785:	jne    3793 <botlish_fn_27+0xdb>
    378b:	mov    rdi,r12
    378e:	jmp    3a64 <botlish_fn_27+0x3ac>
    3793:	mov    rax,QWORD PTR [rsp+0x8]
    3798:	mov    QWORD PTR [rbx+0x18],rax
    379c:	mov    rsi,r15
    379f:	mov    rdi,r12
    37a2:	call   37a7 <botlish_fn_27+0xef>
			37a3: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    37a7:	test   rax,rax
    37aa:	jne    37b8 <botlish_fn_27+0x100>
    37b0:	mov    rdi,r12
    37b3:	jmp    3a64 <botlish_fn_27+0x3ac>
    37b8:	xor    ecx,ecx
    37ba:	test   rax,0x7
    37c0:	je     37ce <botlish_fn_27+0x116>
    37c6:	mov    rsi,rax
    37c9:	jmp    37dc <botlish_fn_27+0x124>
    37ce:	movzx  rcx,BYTE PTR [rax]
    37d2:	mov    rsi,rax
    37d5:	rex cmp cl,0x8
    37d9:	sete   cl
    37dc:	test   cl,cl
    37de:	jne    3805 <botlish_fn_27+0x14d>
    37e4:	mov    rdi,r12
    37e7:	mov    rax,QWORD PTR [rdi+0x10]
    37eb:	mov    rcx,QWORD PTR [rax+0x8]
    37ef:	mov    edx,0x8
    37f4:	mov    rax,QWORD PTR [rip+0x0]        # 37fb <botlish_fn_27+0x143>
			37f7: R_X86_64_GOTPCREL	rt_type_error-0x4
    37fb:	call   rax
    37fd:	mov    rdi,r12
    3800:	jmp    3a64 <botlish_fn_27+0x3ac>
    3805:	mov    rax,QWORD PTR [rip+0x0]        # 380c <botlish_fn_27+0x154>
			3808: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    380c:	mov    rdx,QWORD PTR [rsp+0x8]
    3811:	mov    rdi,r12
    3814:	call   rax
    3816:	test   rax,rax
    3819:	jne    3827 <botlish_fn_27+0x16f>
    381f:	mov    rdi,r12
    3822:	jmp    3a64 <botlish_fn_27+0x3ac>
    3827:	mov    QWORD PTR [rbx+0x20],rax
    382b:	mov    QWORD PTR [rsp],rax
    382f:	mov    rdi,r12
    3832:	call   3837 <botlish_fn_27+0x17f>
			3833: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    3837:	test   rax,rax
    383a:	jne    3848 <botlish_fn_27+0x190>
    3840:	mov    rdi,r12
    3843:	jmp    3a64 <botlish_fn_27+0x3ac>
    3848:	mov    rcx,QWORD PTR [rsp]
    384c:	mov    rdx,rcx
    384f:	and    rdx,rax
    3852:	mov    rcx,rax
    3855:	test   rdx,0x1
    385c:	jne    3886 <botlish_fn_27+0x1ce>
    3862:	mov    rax,QWORD PTR [rip+0x0]        # 3869 <botlish_fn_27+0x1b1>
			3865: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3869:	mov    rdx,rcx
    386c:	mov    rsi,QWORD PTR [rsp]
    3870:	mov    rdi,r12
    3873:	call   rax
    3875:	test   rax,rax
    3878:	jne    389d <botlish_fn_27+0x1e5>
    387e:	mov    rdi,r12
    3881:	jmp    3a64 <botlish_fn_27+0x3ac>
    3886:	mov    rdx,rcx
    3889:	mov    rsi,QWORD PTR [rsp]
    388d:	mov    eax,0x2
    3892:	cmp    rsi,rdx
    3895:	cmove  rax,QWORD PTR [rip+0x253]        # 3af0 <botlish_fn_27+0x438>
    389d:	cmp    rax,0x6
    38a1:	je     39db <botlish_fn_27+0x323>
    38a7:	mov    rsi,r15
    38aa:	mov    rdi,r12
    38ad:	call   38b2 <botlish_fn_27+0x1fa>
			38ae: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    38b2:	test   rax,rax
    38b5:	jne    38c3 <botlish_fn_27+0x20b>
    38bb:	mov    rdi,r12
    38be:	jmp    3a64 <botlish_fn_27+0x3ac>
    38c3:	cmp    rax,0x6
    38c7:	je     391c <botlish_fn_27+0x264>
    38cd:	mov    rcx,r14
    38d0:	mov    rdx,QWORD PTR [rsp+0x8]
    38d5:	mov    rsi,r15
    38d8:	mov    r8,r13
    38db:	mov    rdi,r12
    38de:	call   38e3 <botlish_fn_27+0x22b>
			38df: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    38e3:	test   rax,rax
    38e6:	jne    38f4 <botlish_fn_27+0x23c>
    38ec:	mov    rdi,r12
    38ef:	jmp    3a64 <botlish_fn_27+0x3ac>
    38f4:	mov    rdi,r12
    38f7:	mov    QWORD PTR [rdi],rbx
    38fa:	mov    rbx,QWORD PTR [rsp+0x20]
    38ff:	mov    r12,QWORD PTR [rsp+0x28]
    3904:	mov    r13,QWORD PTR [rsp+0x30]
    3909:	mov    r14,QWORD PTR [rsp+0x38]
    390e:	mov    r15,QWORD PTR [rsp+0x40]
    3913:	add    rsp,0x50
    3917:	mov    rsp,rbp
    391a:	pop    rbp
    391b:	ret
    391c:	mov    rsi,r15
    391f:	mov    rdi,r12
    3922:	call   3927 <botlish_fn_27+0x26f>
			3923: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    3927:	test   rax,rax
    392a:	jne    3938 <botlish_fn_27+0x280>
    3930:	mov    rdi,r12
    3933:	jmp    3a64 <botlish_fn_27+0x3ac>
    3938:	mov    rdx,r14
    393b:	mov    rsi,r15
    393e:	mov    rdi,r12
    3941:	call   3946 <botlish_fn_27+0x28e>
			3942: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3946:	test   rax,rax
    3949:	jne    3957 <botlish_fn_27+0x29f>
    394f:	mov    rdi,r12
    3952:	jmp    3a64 <botlish_fn_27+0x3ac>
    3957:	mov    QWORD PTR [rbx+0x18],rax
    395b:	mov    rcx,rax
    395e:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    3966:	mov    r8,QWORD PTR [rsp+0x10]
    396b:	mov    rdx,r14
    396e:	mov    rsi,r15
    3971:	mov    rdi,r12
    3974:	call   3979 <botlish_fn_27+0x2c1>
			3975: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    3979:	test   rax,rax
    397c:	jne    398a <botlish_fn_27+0x2d2>
    3982:	mov    rdi,r12
    3985:	jmp    3a64 <botlish_fn_27+0x3ac>
    398a:	mov    QWORD PTR [rbx+0x18],rax
    398e:	mov    rcx,r14
    3991:	mov    rdx,rax
    3994:	mov    rsi,r15
    3997:	mov    r8,r13
    399a:	mov    rdi,r12
    399d:	call   39a2 <botlish_fn_27+0x2ea>
			399e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    39a2:	test   rax,rax
    39a5:	jne    39b3 <botlish_fn_27+0x2fb>
    39ab:	mov    rdi,r12
    39ae:	jmp    3a64 <botlish_fn_27+0x3ac>
    39b3:	mov    rdi,r12
    39b6:	mov    QWORD PTR [rdi],rbx
    39b9:	mov    rbx,QWORD PTR [rsp+0x20]
    39be:	mov    r12,QWORD PTR [rsp+0x28]
    39c3:	mov    r13,QWORD PTR [rsp+0x30]
    39c8:	mov    r14,QWORD PTR [rsp+0x38]
    39cd:	mov    r15,QWORD PTR [rsp+0x40]
    39d2:	add    rsp,0x50
    39d6:	mov    rsp,rbp
    39d9:	pop    rbp
    39da:	ret
    39db:	mov    rsi,r15
    39de:	mov    rdi,r12
    39e1:	call   39e6 <botlish_fn_27+0x32e>
			39e2: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    39e6:	test   rax,rax
    39e9:	jne    39f7 <botlish_fn_27+0x33f>
    39ef:	mov    rdi,r12
    39f2:	jmp    3a64 <botlish_fn_27+0x3ac>
    39f7:	xor    ecx,ecx
    39f9:	test   rax,0x7
    39ff:	je     3a0d <botlish_fn_27+0x355>
    3a05:	mov    rsi,rax
    3a08:	jmp    3a1b <botlish_fn_27+0x363>
    3a0d:	movzx  rcx,BYTE PTR [rax]
    3a11:	mov    rsi,rax
    3a14:	rex cmp cl,0x8
    3a18:	sete   cl
    3a1b:	test   cl,cl
    3a1d:	jne    3a44 <botlish_fn_27+0x38c>
    3a23:	mov    rdi,r12
    3a26:	mov    rax,QWORD PTR [rdi+0x10]
    3a2a:	mov    rcx,QWORD PTR [rax+0x20]
    3a2e:	mov    edx,0x8
    3a33:	mov    rax,QWORD PTR [rip+0x0]        # 3a3a <botlish_fn_27+0x382>
			3a36: R_X86_64_GOTPCREL	rt_type_error-0x4
    3a3a:	call   rax
    3a3c:	mov    rdi,r12
    3a3f:	jmp    3a64 <botlish_fn_27+0x3ac>
    3a44:	mov    rax,QWORD PTR [rip+0x0]        # 3a4b <botlish_fn_27+0x393>
			3a47: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3a4b:	mov    rcx,r13
    3a4e:	mov    rdx,QWORD PTR [rsp+0x8]
    3a53:	mov    rdi,r12
    3a56:	call   rax
    3a58:	test   rax,rax
    3a5b:	jne    3a8f <botlish_fn_27+0x3d7>
    3a61:	mov    rdi,r12
    3a64:	mov    rdi,r12
    3a67:	mov    QWORD PTR [rdi],rbx
    3a6a:	xor    rax,rax
    3a6d:	mov    rbx,QWORD PTR [rsp+0x20]
    3a72:	mov    r12,QWORD PTR [rsp+0x28]
    3a77:	mov    r13,QWORD PTR [rsp+0x30]
    3a7c:	mov    r14,QWORD PTR [rsp+0x38]
    3a81:	mov    r15,QWORD PTR [rsp+0x40]
    3a86:	add    rsp,0x50
    3a8a:	mov    rsp,rbp
    3a8d:	pop    rbp
    3a8e:	ret
    3a8f:	mov    rdi,r12
    3a92:	mov    QWORD PTR [rdi],rbx
    3a95:	mov    eax,0xa
    3a9a:	mov    rbx,QWORD PTR [rsp+0x20]
    3a9f:	mov    r12,QWORD PTR [rsp+0x28]
    3aa4:	mov    r13,QWORD PTR [rsp+0x30]
    3aa9:	mov    r14,QWORD PTR [rsp+0x38]
    3aae:	mov    r15,QWORD PTR [rsp+0x40]
    3ab3:	add    rsp,0x50
    3ab7:	mov    rsp,rbp
    3aba:	pop    rbp
    3abb:	ret
    3abc:	mov    r12,rdi
    3abf:	mov    rax,QWORD PTR [rip+0x0]        # 3ac6 <botlish_fn_27+0x40e>
			3ac2: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3ac6:	call   rax
    3ac8:	xor    rax,rax
    3acb:	mov    rbx,QWORD PTR [rsp+0x20]
    3ad0:	mov    r12,QWORD PTR [rsp+0x28]
    3ad5:	mov    r13,QWORD PTR [rsp+0x30]
    3ada:	mov    r14,QWORD PTR [rsp+0x38]
    3adf:	mov    r15,QWORD PTR [rsp+0x40]
    3ae4:	add    rsp,0x50
    3ae8:	mov    rsp,rbp
    3aeb:	pop    rbp
    3aec:	ret
    3aed:	add    BYTE PTR [rax],al
    3aef:	add    BYTE PTR [rsi],al
    3af1:	add    BYTE PTR [rax],al
    3af3:	add    BYTE PTR [rax],al
    3af5:	add    BYTE PTR [rax],al
	...

0000000000003af8 <botlish_entry_27: ht_set<mutarray, str, str>>:
    3af8:	push   rbp
    3af9:	mov    rbp,rsp
    3afc:	mov    rsi,QWORD PTR [rdx]
    3aff:	mov    r8,QWORD PTR [rdx+0x8]
    3b03:	mov    rcx,QWORD PTR [rdx+0x10]
    3b07:	mov    rdx,r8
    3b0a:	call   3b0f <botlish_entry_27+0x17>
			3b0b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3b0f:	mov    rsp,rbp
    3b12:	pop    rbp
    3b13:	ret
    3b14:	add    BYTE PTR [rax],al
	...

0000000000003b18 <botlish_fn_28: ht_delete<mutarray, str>>:
    3b18:	push   rbp
    3b19:	mov    rbp,rsp
    3b1c:	sub    rsp,0x30
    3b20:	mov    QWORD PTR [rsp],rbx
    3b24:	mov    QWORD PTR [rsp+0x8],r12
    3b29:	mov    QWORD PTR [rsp+0x10],r13
    3b2e:	mov    QWORD PTR [rsp+0x18],r14
    3b33:	mov    QWORD PTR [rsp+0x20],r15
    3b38:	mov    rbx,QWORD PTR [rdi]
    3b3b:	mov    rax,QWORD PTR [rdi+0x8]
    3b3f:	lea    rcx,[rbx+0x20]
    3b43:	cmp    rcx,rax
    3b46:	ja     405a <botlish_fn_28+0x542>
    3b4c:	lea    rax,[rbx+0x20]
    3b50:	mov    QWORD PTR [rdi],rax
    3b53:	mov    r12,rdi
    3b56:	mov    QWORD PTR [rbx],0x0
    3b5d:	mov    QWORD PTR [rbx+0x8],0x0
    3b65:	mov    QWORD PTR [rbx+0x10],0x0
    3b6d:	mov    QWORD PTR [rbx+0x18],0x0
    3b75:	mov    QWORD PTR [rbx],rsi
    3b78:	mov    r13,rsi
    3b7b:	mov    QWORD PTR [rbx+0x8],rdx
    3b7f:	mov    r15,rdx
    3b82:	mov    rdx,r15
    3b85:	mov    rsi,r13
    3b88:	mov    rdi,r12
    3b8b:	call   3b90 <botlish_fn_28+0x78>
			3b8c: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3b90:	test   rax,rax
    3b93:	jne    3ba1 <botlish_fn_28+0x89>
    3b99:	mov    rdi,r12
    3b9c:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3ba1:	mov    QWORD PTR [rbx+0x10],rax
    3ba5:	mov    rcx,rax
    3ba8:	mov    rdx,r15
    3bab:	mov    rsi,r13
    3bae:	mov    rdi,r12
    3bb1:	call   3bb6 <botlish_fn_28+0x9e>
			3bb2: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    3bb6:	mov    rcx,rax
    3bb9:	mov    r14,rax
    3bbc:	test   rax,rcx
    3bbf:	jne    3bcd <botlish_fn_28+0xb5>
    3bc5:	mov    rdi,r12
    3bc8:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3bcd:	mov    rax,r14
    3bd0:	mov    QWORD PTR [rbx+0x8],rax
    3bd4:	test   rax,0x1
    3bda:	jne    3c0a <botlish_fn_28+0xf2>
    3be0:	mov    edx,0x1
    3be5:	mov    r8,QWORD PTR [rip+0x0]        # 3bec <botlish_fn_28+0xd4>
			3be8: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    3bec:	mov    rsi,r14
    3bef:	mov    rdi,r12
    3bf2:	call   r8
    3bf5:	mov    ecx,0x2
    3bfa:	test   rax,rax
    3bfd:	cmovl  rcx,QWORD PTR [rip+0x48b]        # 4090 <botlish_fn_28+0x578>
    3c05:	jmp    3c20 <botlish_fn_28+0x108>
    3c0a:	mov    ecx,0x2
    3c0f:	mov    rax,r14
    3c12:	mov    rdx,r14
    3c15:	test   rax,rdx
    3c18:	cmovle rcx,QWORD PTR [rip+0x470]        # 4090 <botlish_fn_28+0x578>
    3c20:	cmp    rcx,0x6
    3c24:	je     402e <botlish_fn_28+0x516>
    3c2a:	mov    rsi,r13
    3c2d:	mov    rdi,r12
    3c30:	call   3c35 <botlish_fn_28+0x11d>
			3c31: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    3c35:	test   rax,rax
    3c38:	jne    3c46 <botlish_fn_28+0x12e>
    3c3e:	mov    rdi,r12
    3c41:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3c46:	mov    QWORD PTR [rbx+0x10],rax
    3c4a:	mov    r15,rax
    3c4d:	mov    rdi,r12
    3c50:	call   3c55 <botlish_fn_28+0x13d>
			3c51: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    3c55:	test   rax,rax
    3c58:	mov    rdx,rax
    3c5b:	jne    3c69 <botlish_fn_28+0x151>
    3c61:	mov    rdi,r12
    3c64:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3c69:	xor    ecx,ecx
    3c6b:	mov    rax,r15
    3c6e:	test   rax,0x7
    3c74:	je     3c82 <botlish_fn_28+0x16a>
    3c7a:	mov    r15,rax
    3c7d:	jmp    3c90 <botlish_fn_28+0x178>
    3c82:	movzx  rcx,BYTE PTR [rax]
    3c86:	mov    r15,rax
    3c89:	rex cmp cl,0x8
    3c8d:	sete   cl
    3c90:	test   cl,cl
    3c92:	jne    3cbc <botlish_fn_28+0x1a4>
    3c98:	mov    rdi,r12
    3c9b:	mov    rax,QWORD PTR [rdi+0x10]
    3c9f:	mov    rcx,QWORD PTR [rax+0x20]
    3ca3:	mov    edx,0x8
    3ca8:	mov    rax,QWORD PTR [rip+0x0]        # 3caf <botlish_fn_28+0x197>
			3cab: R_X86_64_GOTPCREL	rt_type_error-0x4
    3caf:	mov    rsi,r15
    3cb2:	call   rax
    3cb4:	mov    rdi,r12
    3cb7:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3cbc:	mov    rsi,r15
    3cbf:	mov    rax,QWORD PTR [rip+0x0]        # 3cc6 <botlish_fn_28+0x1ae>
			3cc2: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3cc6:	mov    rcx,rdx
    3cc9:	mov    rdx,r14
    3ccc:	mov    rdi,r12
    3ccf:	call   rax
    3cd1:	test   rax,rax
    3cd4:	jne    3ce2 <botlish_fn_28+0x1ca>
    3cda:	mov    rdi,r12
    3cdd:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3ce2:	mov    rsi,r13
    3ce5:	mov    rdi,r12
    3ce8:	call   3ced <botlish_fn_28+0x1d5>
			3ce9: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    3ced:	test   rax,rax
    3cf0:	jne    3cfe <botlish_fn_28+0x1e6>
    3cf6:	mov    rdi,r12
    3cf9:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3cfe:	xor    ecx,ecx
    3d00:	test   rax,0x7
    3d06:	je     3d14 <botlish_fn_28+0x1fc>
    3d0c:	mov    rsi,rax
    3d0f:	jmp    3d22 <botlish_fn_28+0x20a>
    3d14:	movzx  rcx,BYTE PTR [rax]
    3d18:	mov    rsi,rax
    3d1b:	rex cmp cl,0x8
    3d1f:	sete   cl
    3d22:	test   cl,cl
    3d24:	jne    3d4b <botlish_fn_28+0x233>
    3d2a:	mov    rdi,r12
    3d2d:	mov    rax,QWORD PTR [rdi+0x10]
    3d31:	mov    rcx,QWORD PTR [rax+0x20]
    3d35:	mov    edx,0x8
    3d3a:	mov    rax,QWORD PTR [rip+0x0]        # 3d41 <botlish_fn_28+0x229>
			3d3d: R_X86_64_GOTPCREL	rt_type_error-0x4
    3d41:	call   rax
    3d43:	mov    rdi,r12
    3d46:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3d4b:	mov    ecx,0xa
    3d50:	mov    rax,QWORD PTR [rip+0x0]        # 3d57 <botlish_fn_28+0x23f>
			3d53: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3d57:	mov    rdx,r14
    3d5a:	mov    rdi,r12
    3d5d:	call   rax
    3d5f:	test   rax,rax
    3d62:	jne    3d70 <botlish_fn_28+0x258>
    3d68:	mov    rdi,r12
    3d6b:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3d70:	mov    rsi,r13
    3d73:	mov    rdi,r12
    3d76:	call   3d7b <botlish_fn_28+0x263>
			3d77: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3d7b:	test   rax,rax
    3d7e:	jne    3d8c <botlish_fn_28+0x274>
    3d84:	mov    rdi,r12
    3d87:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3d8c:	xor    ecx,ecx
    3d8e:	test   rax,0x7
    3d94:	je     3da2 <botlish_fn_28+0x28a>
    3d9a:	mov    rsi,rax
    3d9d:	jmp    3db0 <botlish_fn_28+0x298>
    3da2:	movzx  rcx,BYTE PTR [rax]
    3da6:	mov    rsi,rax
    3da9:	rex cmp cl,0x8
    3dad:	sete   cl
    3db0:	test   cl,cl
    3db2:	jne    3dd9 <botlish_fn_28+0x2c1>
    3db8:	mov    rdi,r12
    3dbb:	mov    rax,QWORD PTR [rdi+0x10]
    3dbf:	mov    rcx,QWORD PTR [rax+0x20]
    3dc3:	mov    edx,0x8
    3dc8:	mov    rax,QWORD PTR [rip+0x0]        # 3dcf <botlish_fn_28+0x2b7>
			3dcb: R_X86_64_GOTPCREL	rt_type_error-0x4
    3dcf:	call   rax
    3dd1:	mov    rdi,r12
    3dd4:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3dd9:	mov    ecx,0xa
    3dde:	mov    rax,QWORD PTR [rip+0x0]        # 3de5 <botlish_fn_28+0x2cd>
			3de1: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3de5:	mov    rdx,r14
    3de8:	mov    rdi,r12
    3deb:	call   rax
    3ded:	test   rax,rax
    3df0:	jne    3dfe <botlish_fn_28+0x2e6>
    3df6:	mov    rdi,r12
    3df9:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3dfe:	mov    QWORD PTR [rbx+0x8],0x7
    3e06:	mov    rsi,r13
    3e09:	mov    rdi,r12
    3e0c:	call   3e11 <botlish_fn_28+0x2f9>
			3e0d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3e11:	test   rax,rax
    3e14:	jne    3e22 <botlish_fn_28+0x30a>
    3e1a:	mov    rdi,r12
    3e1d:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3e22:	mov    QWORD PTR [rbx+0x10],rax
    3e26:	mov    QWORD PTR [rbx+0x18],0x3
    3e2e:	mov    ecx,0x1
    3e33:	test   rax,0x1
    3e39:	je     3e47 <botlish_fn_28+0x32f>
    3e3f:	mov    rsi,rax
    3e42:	jmp    3e6b <botlish_fn_28+0x353>
    3e47:	xor    ecx,ecx
    3e49:	test   rax,0x7
    3e4f:	je     3e5d <botlish_fn_28+0x345>
    3e55:	mov    rsi,rax
    3e58:	jmp    3e6b <botlish_fn_28+0x353>
    3e5d:	movzx  r8,BYTE PTR [rax]
    3e61:	mov    rsi,rax
    3e64:	cmp    r8b,0x1
    3e68:	sete   cl
    3e6b:	test   cl,cl
    3e6d:	jne    3e92 <botlish_fn_28+0x37a>
    3e73:	mov    rdi,r12
    3e76:	mov    rax,QWORD PTR [rdi+0x10]
    3e7a:	mov    rcx,QWORD PTR [rax+0x28]
    3e7e:	xor    rdx,rdx
    3e81:	mov    rax,QWORD PTR [rip+0x0]        # 3e88 <botlish_fn_28+0x370>
			3e84: R_X86_64_GOTPCREL	rt_type_error-0x4
    3e88:	call   rax
    3e8a:	mov    rdi,r12
    3e8d:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3e92:	test   rsi,0x1
    3e99:	je     3eb8 <botlish_fn_28+0x3a0>
    3e9f:	mov    rcx,rsi
    3ea2:	sub    rcx,0x3
    3ea6:	seto   al
    3ea9:	add    rcx,0x1
    3eb0:	test   al,al
    3eb2:	je     3ecc <botlish_fn_28+0x3b4>
    3eb8:	mov    edx,0x3
    3ebd:	mov    rax,QWORD PTR [rip+0x0]        # 3ec4 <botlish_fn_28+0x3ac>
			3ec0: R_X86_64_GOTPCREL	rt_int_sub-0x4
    3ec4:	mov    rdi,r12
    3ec7:	call   rax
    3ec9:	mov    rcx,rax
    3ecc:	mov    edx,0x7
    3ed1:	mov    rax,QWORD PTR [rip+0x0]        # 3ed8 <botlish_fn_28+0x3c0>
			3ed4: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3ed8:	mov    rsi,r13
    3edb:	mov    rdi,r12
    3ede:	call   rax
    3ee0:	test   rax,rax
    3ee3:	jne    3ef1 <botlish_fn_28+0x3d9>
    3ee9:	mov    rdi,r12
    3eec:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3ef1:	mov    QWORD PTR [rbx+0x8],0x9
    3ef9:	mov    rsi,r13
    3efc:	mov    rdi,r12
    3eff:	call   3f04 <botlish_fn_28+0x3ec>
			3f00: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3f04:	test   rax,rax
    3f07:	jne    3f15 <botlish_fn_28+0x3fd>
    3f0d:	mov    rdi,r12
    3f10:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3f15:	mov    QWORD PTR [rbx+0x10],rax
    3f19:	mov    QWORD PTR [rbx+0x18],0x3
    3f21:	mov    edx,0x1
    3f26:	test   rax,0x1
    3f2c:	je     3f3a <botlish_fn_28+0x422>
    3f32:	mov    rsi,rax
    3f35:	jmp    3f5e <botlish_fn_28+0x446>
    3f3a:	xor    edx,edx
    3f3c:	test   rax,0x7
    3f42:	je     3f50 <botlish_fn_28+0x438>
    3f48:	mov    rsi,rax
    3f4b:	jmp    3f5e <botlish_fn_28+0x446>
    3f50:	movzx  rcx,BYTE PTR [rax]
    3f54:	mov    rsi,rax
    3f57:	rex cmp cl,0x1
    3f5b:	sete   dl
    3f5e:	test   dl,dl
    3f60:	jne    3f85 <botlish_fn_28+0x46d>
    3f66:	mov    rdi,r12
    3f69:	mov    rax,QWORD PTR [rdi+0x10]
    3f6d:	mov    rcx,QWORD PTR [rax+0x10]
    3f71:	xor    rdx,rdx
    3f74:	mov    rax,QWORD PTR [rip+0x0]        # 3f7b <botlish_fn_28+0x463>
			3f77: R_X86_64_GOTPCREL	rt_type_error-0x4
    3f7b:	call   rax
    3f7d:	mov    rdi,r12
    3f80:	jmp    3fd8 <botlish_fn_28+0x4c0>
    3f85:	test   rsi,0x1
    3f8c:	je     3fa4 <botlish_fn_28+0x48c>
    3f92:	mov    rcx,rsi
    3f95:	add    rcx,0x2
    3f99:	seto   al
    3f9c:	test   al,al
    3f9e:	je     3fb8 <botlish_fn_28+0x4a0>
    3fa4:	mov    edx,0x3
    3fa9:	mov    rax,QWORD PTR [rip+0x0]        # 3fb0 <botlish_fn_28+0x498>
			3fac: R_X86_64_GOTPCREL	rt_int_add-0x4
    3fb0:	mov    rdi,r12
    3fb3:	call   rax
    3fb5:	mov    rcx,rax
    3fb8:	mov    edx,0x9
    3fbd:	mov    rax,QWORD PTR [rip+0x0]        # 3fc4 <botlish_fn_28+0x4ac>
			3fc0: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3fc4:	mov    rsi,r13
    3fc7:	mov    rdi,r12
    3fca:	call   rax
    3fcc:	test   rax,rax
    3fcf:	jne    4002 <botlish_fn_28+0x4ea>
    3fd5:	mov    rdi,r12
    3fd8:	mov    rdi,r12
    3fdb:	mov    QWORD PTR [rdi],rbx
    3fde:	xor    rax,rax
    3fe1:	mov    rbx,QWORD PTR [rsp]
    3fe5:	mov    r12,QWORD PTR [rsp+0x8]
    3fea:	mov    r13,QWORD PTR [rsp+0x10]
    3fef:	mov    r14,QWORD PTR [rsp+0x18]
    3ff4:	mov    r15,QWORD PTR [rsp+0x20]
    3ff9:	add    rsp,0x30
    3ffd:	mov    rsp,rbp
    4000:	pop    rbp
    4001:	ret
    4002:	mov    rdi,r12
    4005:	mov    QWORD PTR [rdi],rbx
    4008:	mov    eax,0xa
    400d:	mov    rbx,QWORD PTR [rsp]
    4011:	mov    r12,QWORD PTR [rsp+0x8]
    4016:	mov    r13,QWORD PTR [rsp+0x10]
    401b:	mov    r14,QWORD PTR [rsp+0x18]
    4020:	mov    r15,QWORD PTR [rsp+0x20]
    4025:	add    rsp,0x30
    4029:	mov    rsp,rbp
    402c:	pop    rbp
    402d:	ret
    402e:	mov    rdi,r12
    4031:	mov    QWORD PTR [rdi],rbx
    4034:	mov    eax,0xa
    4039:	mov    rbx,QWORD PTR [rsp]
    403d:	mov    r12,QWORD PTR [rsp+0x8]
    4042:	mov    r13,QWORD PTR [rsp+0x10]
    4047:	mov    r14,QWORD PTR [rsp+0x18]
    404c:	mov    r15,QWORD PTR [rsp+0x20]
    4051:	add    rsp,0x30
    4055:	mov    rsp,rbp
    4058:	pop    rbp
    4059:	ret
    405a:	mov    r12,rdi
    405d:	mov    rax,QWORD PTR [rip+0x0]        # 4064 <botlish_fn_28+0x54c>
			4060: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    4064:	call   rax
    4066:	xor    rax,rax
    4069:	mov    rbx,QWORD PTR [rsp]
    406d:	mov    r12,QWORD PTR [rsp+0x8]
    4072:	mov    r13,QWORD PTR [rsp+0x10]
    4077:	mov    r14,QWORD PTR [rsp+0x18]
    407c:	mov    r15,QWORD PTR [rsp+0x20]
    4081:	add    rsp,0x30
    4085:	mov    rsp,rbp
    4088:	pop    rbp
    4089:	ret
    408a:	add    BYTE PTR [rax],al
    408c:	add    BYTE PTR [rax],al
    408e:	add    BYTE PTR [rax],al
    4090:	(bad)
    4091:	add    BYTE PTR [rax],al
    4093:	add    BYTE PTR [rax],al
    4095:	add    BYTE PTR [rax],al
	...

0000000000004098 <botlish_entry_28: ht_delete<mutarray, str>>:
    4098:	push   rbp
    4099:	mov    rbp,rsp
    409c:	mov    rsi,QWORD PTR [rdx]
    409f:	mov    rdx,QWORD PTR [rdx+0x8]
    40a3:	call   40a8 <botlish_entry_28+0x10>
			40a4: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    40a8:	mov    rsp,rbp
    40ab:	pop    rbp
    40ac:	ret
    40ad:	add    BYTE PTR [rax],al
	...

00000000000040b0 <botlish_fn_29: sample<generic>>:
    40b0:	push   rbp
    40b1:	mov    rbp,rsp
    40b4:	sub    rsp,0x70
    40b8:	mov    QWORD PTR [rsp+0x40],rbx
    40bd:	mov    QWORD PTR [rsp+0x48],r12
    40c2:	mov    QWORD PTR [rsp+0x50],r13
    40c7:	mov    QWORD PTR [rsp+0x58],r14
    40cc:	mov    QWORD PTR [rsp+0x60],r15
    40d1:	mov    r12,QWORD PTR [rdi]
    40d4:	mov    rax,QWORD PTR [rdi+0x8]
    40d8:	lea    rcx,[r12+0x30]
    40dd:	cmp    rcx,rax
    40e0:	ja     4479 <botlish_fn_29+0x3c9>
    40e6:	lea    rcx,[r12+0x30]
    40eb:	mov    QWORD PTR [rdi],rcx
    40ee:	mov    QWORD PTR [rsp+0x30],rdi
    40f3:	mov    QWORD PTR [r12],0x0
    40fb:	mov    QWORD PTR [r12+0x8],0x0
    4104:	mov    QWORD PTR [r12+0x10],0x0
    410d:	mov    QWORD PTR [r12+0x18],0x0
    4116:	mov    QWORD PTR [r12+0x20],0x0
    411f:	mov    QWORD PTR [r12+0x28],0x0
    4128:	mov    rdi,QWORD PTR [rsp+0x30]
    412d:	call   4132 <botlish_fn_29+0x82>
			412e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    4132:	mov    rbx,rax
    4135:	test   rbx,rbx
    4138:	jne    4148 <botlish_fn_29+0x98>
    413e:	mov    rdi,QWORD PTR [rsp+0x30]
    4143:	jmp    4422 <botlish_fn_29+0x372>
    4148:	mov    QWORD PTR [r12],rbx
    414c:	mov    rdi,QWORD PTR [rsp+0x30]
    4151:	mov    rax,QWORD PTR [rdi+0x10]
    4155:	mov    rdx,QWORD PTR [rax+0x30]
    4159:	mov    QWORD PTR [r12+0x8],rdx
    415e:	mov    rax,QWORD PTR [rdi+0x10]
    4162:	mov    rcx,QWORD PTR [rax+0x38]
    4166:	mov    QWORD PTR [r12+0x10],rcx
    416b:	mov    rsi,rbx
    416e:	call   4173 <botlish_fn_29+0xc3>
			416f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    4173:	test   rax,rax
    4176:	jne    4186 <botlish_fn_29+0xd6>
    417c:	mov    rdi,QWORD PTR [rsp+0x30]
    4181:	jmp    4422 <botlish_fn_29+0x372>
    4186:	mov    rdi,QWORD PTR [rsp+0x30]
    418b:	mov    rax,QWORD PTR [rdi+0x10]
    418f:	mov    rdx,QWORD PTR [rax+0x40]
    4193:	mov    QWORD PTR [r12+0x8],rdx
    4198:	mov    rax,QWORD PTR [rdi+0x10]
    419c:	mov    rcx,QWORD PTR [rax+0x48]
    41a0:	mov    QWORD PTR [r12+0x10],rcx
    41a5:	mov    rsi,rbx
    41a8:	call   41ad <botlish_fn_29+0xfd>
			41a9: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    41ad:	test   rax,rax
    41b0:	jne    41c0 <botlish_fn_29+0x110>
    41b6:	mov    rdi,QWORD PTR [rsp+0x30]
    41bb:	jmp    4422 <botlish_fn_29+0x372>
    41c0:	mov    rdi,QWORD PTR [rsp+0x30]
    41c5:	mov    rax,QWORD PTR [rdi+0x10]
    41c9:	mov    rdx,QWORD PTR [rax+0x30]
    41cd:	mov    QWORD PTR [r12+0x8],rdx
    41d2:	mov    rax,QWORD PTR [rdi+0x10]
    41d6:	mov    rcx,QWORD PTR [rax+0x50]
    41da:	mov    QWORD PTR [r12+0x10],rcx
    41df:	mov    rsi,rbx
    41e2:	call   41e7 <botlish_fn_29+0x137>
			41e3: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    41e7:	test   rax,rax
    41ea:	jne    41fa <botlish_fn_29+0x14a>
    41f0:	mov    rdi,QWORD PTR [rsp+0x30]
    41f5:	jmp    4422 <botlish_fn_29+0x372>
    41fa:	mov    rdi,QWORD PTR [rsp+0x30]
    41ff:	mov    rax,QWORD PTR [rdi+0x10]
    4203:	mov    rdx,QWORD PTR [rax+0x40]
    4207:	mov    QWORD PTR [r12+0x8],rdx
    420c:	mov    rsi,rbx
    420f:	call   4214 <botlish_fn_29+0x164>
			4210: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    4214:	mov    rcx,rax
    4217:	test   rcx,rcx
    421a:	jne    422a <botlish_fn_29+0x17a>
    4220:	mov    rdi,QWORD PTR [rsp+0x30]
    4225:	jmp    4422 <botlish_fn_29+0x372>
    422a:	mov    QWORD PTR [r12+0x8],rcx
    422f:	mov    rdi,QWORD PTR [rsp+0x30]
    4234:	mov    QWORD PTR [rsp+0x38],rcx
    4239:	mov    rax,QWORD PTR [rdi+0x10]
    423d:	mov    rdx,QWORD PTR [rax+0x40]
    4241:	mov    QWORD PTR [r12+0x10],rdx
    4246:	mov    rsi,rbx
    4249:	call   424e <botlish_fn_29+0x19e>
			424a: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    424e:	test   rax,rax
    4251:	jne    4261 <botlish_fn_29+0x1b1>
    4257:	mov    rdi,QWORD PTR [rsp+0x30]
    425c:	jmp    4422 <botlish_fn_29+0x372>
    4261:	mov    rdi,QWORD PTR [rsp+0x30]
    4266:	mov    rax,QWORD PTR [rdi+0x10]
    426a:	mov    rdx,QWORD PTR [rax+0x30]
    426e:	mov    QWORD PTR [r12+0x10],rdx
    4273:	mov    rsi,rbx
    4276:	call   427b <botlish_fn_29+0x1cb>
			4277: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    427b:	test   rax,rax
    427e:	jne    428e <botlish_fn_29+0x1de>
    4284:	mov    rdi,QWORD PTR [rsp+0x30]
    4289:	jmp    4422 <botlish_fn_29+0x372>
    428e:	mov    rdi,QWORD PTR [rsp+0x30]
    4293:	mov    rcx,QWORD PTR [rdi+0x10]
    4297:	mov    rdx,QWORD PTR [rcx+0x50]
    429b:	mov    rcx,rax
    429e:	and    rcx,rdx
    42a1:	mov    rsi,rax
    42a4:	test   rcx,0x1
    42ab:	jne    42d5 <botlish_fn_29+0x225>
    42b1:	mov    rax,QWORD PTR [rip+0x0]        # 42b8 <botlish_fn_29+0x208>
			42b4: R_X86_64_GOTPCREL	rt_value_eq-0x4
    42b8:	mov    rdi,QWORD PTR [rsp+0x30]
    42bd:	call   rax
    42bf:	mov    r13,rax
    42c2:	test   r13,r13
    42c5:	jne    42e6 <botlish_fn_29+0x236>
    42cb:	mov    rdi,QWORD PTR [rsp+0x30]
    42d0:	jmp    4422 <botlish_fn_29+0x372>
    42d5:	mov    r13d,0x2
    42db:	cmp    rsi,rdx
    42de:	cmove  r13,QWORD PTR [rip+0x1ca]        # 44b0 <botlish_fn_29+0x400>
    42e6:	mov    QWORD PTR [r12+0x10],r13
    42eb:	mov    rdi,QWORD PTR [rsp+0x30]
    42f0:	mov    rax,QWORD PTR [rdi+0x10]
    42f4:	mov    rdx,QWORD PTR [rax+0x40]
    42f8:	mov    QWORD PTR [r12+0x18],rdx
    42fd:	mov    rsi,rbx
    4300:	call   4305 <botlish_fn_29+0x255>
			4301: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    4305:	mov    r14,rax
    4308:	test   r14,r14
    430b:	jne    431b <botlish_fn_29+0x26b>
    4311:	mov    rdi,QWORD PTR [rsp+0x30]
    4316:	jmp    4422 <botlish_fn_29+0x372>
    431b:	mov    QWORD PTR [r12+0x18],r14
    4320:	mov    rdi,QWORD PTR [rsp+0x30]
    4325:	mov    rax,QWORD PTR [rdi+0x10]
    4329:	mov    rdx,QWORD PTR [rax+0x58]
    432d:	mov    QWORD PTR [r12+0x20],rdx
    4332:	mov    rsi,rbx
    4335:	call   433a <botlish_fn_29+0x28a>
			4336: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    433a:	mov    r15,rax
    433d:	test   r15,r15
    4340:	jne    4350 <botlish_fn_29+0x2a0>
    4346:	mov    rdi,QWORD PTR [rsp+0x30]
    434b:	jmp    4422 <botlish_fn_29+0x372>
    4350:	mov    QWORD PTR [r12+0x20],r15
    4355:	mov    rdi,QWORD PTR [rsp+0x30]
    435a:	mov    rax,QWORD PTR [rdi+0x10]
    435e:	mov    rdx,QWORD PTR [rax+0x58]
    4362:	mov    QWORD PTR [r12+0x28],rdx
    4367:	mov    rsi,rbx
    436a:	call   436f <botlish_fn_29+0x2bf>
			436b: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    436f:	test   rax,rax
    4372:	mov    rsi,rax
    4375:	jne    4385 <botlish_fn_29+0x2d5>
    437b:	mov    rdi,QWORD PTR [rsp+0x30]
    4380:	jmp    4422 <botlish_fn_29+0x372>
    4385:	mov    edx,0xa
    438a:	mov    r8,QWORD PTR [rip+0x0]        # 4391 <botlish_fn_29+0x2e1>
			438d: R_X86_64_GOTPCREL	rt_value_eq-0x4
    4391:	mov    rdi,QWORD PTR [rsp+0x30]
    4396:	call   r8
    4399:	test   rax,rax
    439c:	jne    43ac <botlish_fn_29+0x2fc>
    43a2:	mov    rdi,QWORD PTR [rsp+0x30]
    43a7:	jmp    4422 <botlish_fn_29+0x372>
    43ac:	mov    QWORD PTR [r12+0x28],rax
    43b1:	mov    rsi,rbx
    43b4:	mov    rbx,rax
    43b7:	mov    rdi,QWORD PTR [rsp+0x30]
    43bc:	call   43c1 <botlish_fn_29+0x311>
			43bd: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    43c1:	test   rax,rax
    43c4:	jne    43d4 <botlish_fn_29+0x324>
    43ca:	mov    rdi,QWORD PTR [rsp+0x30]
    43cf:	jmp    4422 <botlish_fn_29+0x372>
    43d4:	mov    QWORD PTR [r12],rax
    43d8:	lea    rdx,[rsp]
    43dc:	mov    QWORD PTR [rsp],r13
    43e0:	mov    rcx,QWORD PTR [rsp+0x38]
    43e5:	mov    QWORD PTR [rsp+0x8],rcx
    43ea:	mov    QWORD PTR [rsp+0x10],r14
    43ef:	mov    QWORD PTR [rsp+0x18],r15
    43f4:	mov    rcx,rbx
    43f7:	mov    QWORD PTR [rsp+0x20],rcx
    43fc:	mov    QWORD PTR [rsp+0x28],rax
    4401:	mov    esi,0x6
    4406:	mov    rax,QWORD PTR [rip+0x0]        # 440d <botlish_fn_29+0x35d>
			4409: R_X86_64_GOTPCREL	rt_list_new-0x4
    440d:	mov    rdi,QWORD PTR [rsp+0x30]
    4412:	call   rax
    4414:	test   rax,rax
    4417:	jne    444f <botlish_fn_29+0x39f>
    441d:	mov    rdi,QWORD PTR [rsp+0x30]
    4422:	mov    rdi,QWORD PTR [rsp+0x30]
    4427:	mov    QWORD PTR [rdi],r12
    442a:	xor    rax,rax
    442d:	mov    rbx,QWORD PTR [rsp+0x40]
    4432:	mov    r12,QWORD PTR [rsp+0x48]
    4437:	mov    r13,QWORD PTR [rsp+0x50]
    443c:	mov    r14,QWORD PTR [rsp+0x58]
    4441:	mov    r15,QWORD PTR [rsp+0x60]
    4446:	add    rsp,0x70
    444a:	mov    rsp,rbp
    444d:	pop    rbp
    444e:	ret
    444f:	mov    rdi,QWORD PTR [rsp+0x30]
    4454:	mov    QWORD PTR [rdi],r12
    4457:	mov    rbx,QWORD PTR [rsp+0x40]
    445c:	mov    r12,QWORD PTR [rsp+0x48]
    4461:	mov    r13,QWORD PTR [rsp+0x50]
    4466:	mov    r14,QWORD PTR [rsp+0x58]
    446b:	mov    r15,QWORD PTR [rsp+0x60]
    4470:	add    rsp,0x70
    4474:	mov    rsp,rbp
    4477:	pop    rbp
    4478:	ret
    4479:	mov    QWORD PTR [rsp+0x30],rdi
    447e:	mov    rax,QWORD PTR [rip+0x0]        # 4485 <botlish_fn_29+0x3d5>
			4481: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    4485:	call   rax
    4487:	xor    rax,rax
    448a:	mov    rbx,QWORD PTR [rsp+0x40]
    448f:	mov    r12,QWORD PTR [rsp+0x48]
    4494:	mov    r13,QWORD PTR [rsp+0x50]
    4499:	mov    r14,QWORD PTR [rsp+0x58]
    449e:	mov    r15,QWORD PTR [rsp+0x60]
    44a3:	add    rsp,0x70
    44a7:	mov    rsp,rbp
    44aa:	pop    rbp
    44ab:	ret
    44ac:	add    BYTE PTR [rax],al
    44ae:	add    BYTE PTR [rax],al
    44b0:	(bad)
    44b1:	add    BYTE PTR [rax],al
    44b3:	add    BYTE PTR [rax],al
    44b5:	add    BYTE PTR [rax],al
	...

00000000000044b8 <botlish_entry_29: sample<generic>>:
    44b8:	push   rbp
    44b9:	mov    rbp,rsp
    44bc:	call   44c1 <botlish_entry_29+0x9>
			44bd: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    44c1:	mov    rsp,rbp
    44c4:	pop    rbp
    44c5:	ret

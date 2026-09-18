; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 18061  (per function: 172 85 85 85 85 548 696 208 184 184 184 184 184 268 299 355 1036 1568 581 389 596 708 1276 1124 961 833 1528 1132 1469 1054)
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
    1e70:	sub    rsp,0x40
    1e74:	mov    QWORD PTR [rsp+0x10],rbx
    1e79:	mov    QWORD PTR [rsp+0x18],r12
    1e7e:	mov    QWORD PTR [rsp+0x20],r13
    1e83:	mov    QWORD PTR [rsp+0x28],r14
    1e88:	mov    QWORD PTR [rsp+0x30],r15
    1e8d:	mov    rbx,QWORD PTR [rdi]
    1e90:	mov    rax,QWORD PTR [rdi+0x8]
    1e94:	lea    r9,[rbx+0x30]
    1e98:	cmp    r9,rax
    1e9b:	ja     20c4 <botlish_fn_21+0x258>
    1ea1:	lea    rax,[rbx+0x30]
    1ea5:	mov    QWORD PTR [rdi],rax
    1ea8:	mov    r13,rdi
    1eab:	mov    QWORD PTR [rbx],0x0
    1eb2:	mov    QWORD PTR [rbx+0x8],0x0
    1eba:	mov    QWORD PTR [rbx+0x10],0x0
    1ec2:	mov    QWORD PTR [rbx+0x18],0x0
    1eca:	mov    QWORD PTR [rbx+0x20],0x0
    1ed2:	mov    QWORD PTR [rbx+0x28],0x0
    1eda:	mov    QWORD PTR [rbx],rsi
    1edd:	mov    r15,rsi
    1ee0:	mov    QWORD PTR [rbx+0x8],rdx
    1ee4:	mov    r12,rdx
    1ee7:	mov    QWORD PTR [rbx+0x10],rcx
    1eeb:	mov    QWORD PTR [rsp],rcx
    1eef:	mov    QWORD PTR [rbx+0x18],r8
    1ef3:	mov    r14,r8
    1ef6:	mov    edx,0x1
    1efb:	mov    rax,QWORD PTR [rip+0x0]        # 1f02 <botlish_fn_21+0x96>
			1efe: R_X86_64_GOTPCREL	rt_list_get-0x4
    1f02:	mov    rsi,r15
    1f05:	mov    rdi,r13
    1f08:	call   rax
    1f0a:	test   rax,rax
    1f0d:	jne    1f1b <botlish_fn_21+0xaf>
    1f13:	mov    rdi,r13
    1f16:	jmp    206c <botlish_fn_21+0x200>
    1f1b:	mov    QWORD PTR [rbx+0x20],rax
    1f1f:	mov    QWORD PTR [rsp+0x8],rax
    1f24:	mov    rax,QWORD PTR [rip+0x0]        # 1f2b <botlish_fn_21+0xbf>
			1f27: R_X86_64_GOTPCREL	rt_hash-0x4
    1f2b:	mov    rsi,QWORD PTR [rsp]
    1f2f:	mov    rdi,r13
    1f32:	call   rax
    1f34:	test   rax,rax
    1f37:	mov    rsi,rax
    1f3a:	jne    1f48 <botlish_fn_21+0xdc>
    1f40:	mov    rdi,r13
    1f43:	jmp    206c <botlish_fn_21+0x200>
    1f48:	mov    rax,QWORD PTR [rip+0x0]        # 1f4f <botlish_fn_21+0xe3>
			1f4b: R_X86_64_GOTPCREL	rt_int_mod-0x4
    1f4f:	mov    rdx,r12
    1f52:	mov    rdi,r13
    1f55:	call   rax
    1f57:	test   rax,rax
    1f5a:	jne    1f68 <botlish_fn_21+0xfc>
    1f60:	mov    rdi,r13
    1f63:	jmp    206c <botlish_fn_21+0x200>
    1f68:	mov    QWORD PTR [rbx+0x28],rax
    1f6c:	mov    rcx,r12
    1f6f:	mov    rdx,rax
    1f72:	mov    rsi,QWORD PTR [rsp+0x8]
    1f77:	mov    rdi,r13
    1f7a:	call   1f7f <botlish_fn_21+0x113>
			1f7b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1f7f:	mov    r12,rax
    1f82:	test   r12,r12
    1f85:	jne    1f93 <botlish_fn_21+0x127>
    1f8b:	mov    rdi,r13
    1f8e:	jmp    206c <botlish_fn_21+0x200>
    1f93:	mov    QWORD PTR [rbx+0x8],r12
    1f97:	mov    rdi,r13
    1f9a:	call   1f9f <botlish_fn_21+0x133>
			1f9b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1f9f:	test   rax,rax
    1fa2:	mov    rcx,rax
    1fa5:	jne    1fb3 <botlish_fn_21+0x147>
    1fab:	mov    rdi,r13
    1fae:	jmp    206c <botlish_fn_21+0x200>
    1fb3:	mov    r8,QWORD PTR [rip+0x0]        # 1fba <botlish_fn_21+0x14e>
			1fb6: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    1fba:	mov    rsi,QWORD PTR [rsp+0x8]
    1fbf:	mov    rdx,r12
    1fc2:	mov    rdi,r13
    1fc5:	call   r8
    1fc8:	test   rax,rax
    1fcb:	jne    1fd9 <botlish_fn_21+0x16d>
    1fd1:	mov    rdi,r13
    1fd4:	jmp    206c <botlish_fn_21+0x200>
    1fd9:	mov    edx,0x3
    1fde:	mov    r9,QWORD PTR [rip+0x0]        # 1fe5 <botlish_fn_21+0x179>
			1fe1: R_X86_64_GOTPCREL	rt_list_get-0x4
    1fe5:	mov    rsi,r15
    1fe8:	mov    rdi,r13
    1feb:	call   r9
    1fee:	test   rax,rax
    1ff1:	mov    rsi,rax
    1ff4:	jne    2002 <botlish_fn_21+0x196>
    1ffa:	mov    rdi,r13
    1ffd:	jmp    206c <botlish_fn_21+0x200>
    2002:	mov    rax,QWORD PTR [rip+0x0]        # 2009 <botlish_fn_21+0x19d>
			2005: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    2009:	mov    rcx,QWORD PTR [rsp]
    200d:	mov    rdx,r12
    2010:	mov    rdi,r13
    2013:	call   rax
    2015:	test   rax,rax
    2018:	jne    2026 <botlish_fn_21+0x1ba>
    201e:	mov    rdi,r13
    2021:	jmp    206c <botlish_fn_21+0x200>
    2026:	mov    edx,0x5
    202b:	mov    rax,QWORD PTR [rip+0x0]        # 2032 <botlish_fn_21+0x1c6>
			202e: R_X86_64_GOTPCREL	rt_list_get-0x4
    2032:	mov    rsi,r15
    2035:	mov    rdi,r13
    2038:	call   rax
    203a:	test   rax,rax
    203d:	mov    rsi,rax
    2040:	jne    204e <botlish_fn_21+0x1e2>
    2046:	mov    rdi,r13
    2049:	jmp    206c <botlish_fn_21+0x200>
    204e:	mov    rax,QWORD PTR [rip+0x0]        # 2055 <botlish_fn_21+0x1e9>
			2051: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    2055:	mov    rcx,r14
    2058:	mov    rdx,r12
    205b:	mov    rdi,r13
    205e:	call   rax
    2060:	test   rax,rax
    2063:	jne    2097 <botlish_fn_21+0x22b>
    2069:	mov    rdi,r13
    206c:	mov    rdi,r13
    206f:	mov    QWORD PTR [rdi],rbx
    2072:	xor    rax,rax
    2075:	mov    rbx,QWORD PTR [rsp+0x10]
    207a:	mov    r12,QWORD PTR [rsp+0x18]
    207f:	mov    r13,QWORD PTR [rsp+0x20]
    2084:	mov    r14,QWORD PTR [rsp+0x28]
    2089:	mov    r15,QWORD PTR [rsp+0x30]
    208e:	add    rsp,0x40
    2092:	mov    rsp,rbp
    2095:	pop    rbp
    2096:	ret
    2097:	mov    rdi,r13
    209a:	mov    QWORD PTR [rdi],rbx
    209d:	mov    eax,0xa
    20a2:	mov    rbx,QWORD PTR [rsp+0x10]
    20a7:	mov    r12,QWORD PTR [rsp+0x18]
    20ac:	mov    r13,QWORD PTR [rsp+0x20]
    20b1:	mov    r14,QWORD PTR [rsp+0x28]
    20b6:	mov    r15,QWORD PTR [rsp+0x30]
    20bb:	add    rsp,0x40
    20bf:	mov    rsp,rbp
    20c2:	pop    rbp
    20c3:	ret
    20c4:	mov    r13,rdi
    20c7:	mov    rax,QWORD PTR [rip+0x0]        # 20ce <botlish_fn_21+0x262>
			20ca: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    20ce:	call   rax
    20d0:	xor    rax,rax
    20d3:	mov    rbx,QWORD PTR [rsp+0x10]
    20d8:	mov    r12,QWORD PTR [rsp+0x18]
    20dd:	mov    r13,QWORD PTR [rsp+0x20]
    20e2:	mov    r14,QWORD PTR [rsp+0x28]
    20e7:	mov    r15,QWORD PTR [rsp+0x30]
    20ec:	add    rsp,0x40
    20f0:	mov    rsp,rbp
    20f3:	pop    rbp
    20f4:	ret

00000000000020f5 <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    20f5:	push   rbp
    20f6:	mov    rbp,rsp
    20f9:	mov    rsi,QWORD PTR [rdx]
    20fc:	mov    r9,QWORD PTR [rdx+0x8]
    2100:	mov    rcx,QWORD PTR [rdx+0x10]
    2104:	mov    r8,QWORD PTR [rdx+0x18]
    2108:	mov    rdx,r9
    210b:	call   2110 <botlish_entry_21+0x1b>
			210c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    2110:	mov    rsp,rbp
    2113:	pop    rbp
    2114:	ret
    2115:	add    BYTE PTR [rax],al
	...

0000000000002118 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2118:	push   rbp
    2119:	mov    rbp,rsp
    211c:	sub    rsp,0x50
    2120:	mov    QWORD PTR [rsp+0x20],rbx
    2125:	mov    QWORD PTR [rsp+0x28],r12
    212a:	mov    QWORD PTR [rsp+0x30],r13
    212f:	mov    QWORD PTR [rsp+0x38],r14
    2134:	mov    QWORD PTR [rsp+0x40],r15
    2139:	mov    r15,QWORD PTR [rdi]
    213c:	mov    rax,QWORD PTR [rdi+0x8]
    2140:	lea    r10,[r15+0x38]
    2144:	cmp    r10,rax
    2147:	ja     258c <botlish_fn_22+0x474>
    214d:	lea    rax,[r15+0x38]
    2151:	mov    QWORD PTR [rdi],rax
    2154:	mov    QWORD PTR [rsp],rdi
    2158:	mov    QWORD PTR [r15],0x0
    215f:	mov    QWORD PTR [r15+0x8],0x0
    2167:	mov    QWORD PTR [r15+0x10],0x0
    216f:	mov    QWORD PTR [r15+0x18],0x0
    2177:	mov    QWORD PTR [r15+0x20],0x0
    217f:	mov    QWORD PTR [r15+0x28],0x0
    2187:	mov    QWORD PTR [r15+0x30],0x0
    218f:	mov    QWORD PTR [r15],rsi
    2192:	mov    r12,rsi
    2195:	mov    QWORD PTR [r15+0x8],rdx
    2199:	mov    QWORD PTR [r15+0x10],rcx
    219d:	mov    QWORD PTR [r15+0x18],r8
    21a1:	mov    r14,r8
    21a4:	mov    QWORD PTR [r15+0x20],r9
    21a8:	mov    r13,r9
    21ab:	mov    rbx,rcx
    21ae:	mov    rsi,rdx
    21b1:	mov    rax,rsi
    21b4:	and    rax,rbx
    21b7:	mov    QWORD PTR [rsp+0x8],rsi
    21bc:	test   rax,0x1
    21c2:	jne    21f2 <botlish_fn_22+0xda>
    21c8:	mov    rax,QWORD PTR [rip+0x0]        # 21cf <botlish_fn_22+0xb7>
			21cb: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    21cf:	mov    rdx,rbx
    21d2:	mov    rsi,QWORD PTR [rsp+0x8]
    21d7:	mov    rdi,QWORD PTR [rsp]
    21db:	call   rax
    21dd:	mov    ecx,0x2
    21e2:	test   rax,rax
    21e5:	cmovge rcx,QWORD PTR [rip+0x3d3]        # 25c0 <botlish_fn_22+0x4a8>
    21ed:	jmp    2207 <botlish_fn_22+0xef>
    21f2:	mov    ecx,0x2
    21f7:	mov    rsi,QWORD PTR [rsp+0x8]
    21fc:	cmp    rsi,rbx
    21ff:	cmovge rcx,QWORD PTR [rip+0x3b9]        # 25c0 <botlish_fn_22+0x4a8>
    2207:	cmp    rcx,0x6
    220b:	je     255e <botlish_fn_22+0x446>
    2211:	mov    edx,0x1
    2216:	mov    rax,QWORD PTR [rip+0x0]        # 221d <botlish_fn_22+0x105>
			2219: R_X86_64_GOTPCREL	rt_list_get-0x4
    221d:	mov    rsi,r12
    2220:	mov    rdi,QWORD PTR [rsp]
    2224:	call   rax
    2226:	test   rax,rax
    2229:	jne    2238 <botlish_fn_22+0x120>
    222f:	mov    rdi,QWORD PTR [rsp]
    2233:	jmp    24b5 <botlish_fn_22+0x39d>
    2238:	xor    ecx,ecx
    223a:	test   rax,0x7
    2240:	je     224e <botlish_fn_22+0x136>
    2246:	mov    rsi,rax
    2249:	jmp    225c <botlish_fn_22+0x144>
    224e:	movzx  rcx,BYTE PTR [rax]
    2252:	mov    rsi,rax
    2255:	rex cmp cl,0x8
    2259:	sete   cl
    225c:	test   cl,cl
    225e:	jne    2287 <botlish_fn_22+0x16f>
    2264:	mov    rdi,QWORD PTR [rsp]
    2268:	mov    rax,QWORD PTR [rdi+0x10]
    226c:	mov    rcx,QWORD PTR [rax+0x8]
    2270:	mov    edx,0x8
    2275:	mov    rax,QWORD PTR [rip+0x0]        # 227c <botlish_fn_22+0x164>
			2278: R_X86_64_GOTPCREL	rt_type_error-0x4
    227c:	call   rax
    227e:	mov    rdi,QWORD PTR [rsp]
    2282:	jmp    24b5 <botlish_fn_22+0x39d>
    2287:	mov    rax,QWORD PTR [rip+0x0]        # 228e <botlish_fn_22+0x176>
			228a: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    228e:	mov    rdx,QWORD PTR [rsp+0x8]
    2293:	mov    rdi,QWORD PTR [rsp]
    2297:	call   rax
    2299:	test   rax,rax
    229c:	jne    22ab <botlish_fn_22+0x193>
    22a2:	mov    rdi,QWORD PTR [rsp]
    22a6:	jmp    24b5 <botlish_fn_22+0x39d>
    22ab:	mov    QWORD PTR [r15+0x28],rax
    22af:	mov    QWORD PTR [rsp+0x10],rax
    22b4:	mov    rdi,QWORD PTR [rsp]
    22b8:	call   22bd <botlish_fn_22+0x1a5>
			22b9: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    22bd:	test   rax,rax
    22c0:	jne    22cf <botlish_fn_22+0x1b7>
    22c6:	mov    rdi,QWORD PTR [rsp]
    22ca:	jmp    24b5 <botlish_fn_22+0x39d>
    22cf:	mov    rsi,QWORD PTR [rsp+0x10]
    22d4:	mov    rdx,rsi
    22d7:	and    rdx,rax
    22da:	test   rdx,0x1
    22e1:	jne    230f <botlish_fn_22+0x1f7>
    22e7:	mov    r8,QWORD PTR [rip+0x0]        # 22ee <botlish_fn_22+0x1d6>
			22ea: R_X86_64_GOTPCREL	rt_value_eq-0x4
    22ee:	mov    rdx,rax
    22f1:	mov    rsi,QWORD PTR [rsp+0x10]
    22f6:	mov    rdi,QWORD PTR [rsp]
    22fa:	call   r8
    22fd:	test   rax,rax
    2300:	jne    2327 <botlish_fn_22+0x20f>
    2306:	mov    rdi,QWORD PTR [rsp]
    230a:	jmp    24b5 <botlish_fn_22+0x39d>
    230f:	mov    rdx,rax
    2312:	mov    rsi,QWORD PTR [rsp+0x10]
    2317:	mov    eax,0x2
    231c:	cmp    rsi,rdx
    231f:	cmove  rax,QWORD PTR [rip+0x299]        # 25c0 <botlish_fn_22+0x4a8>
    2327:	cmp    rax,0x6
    232b:	je     233f <botlish_fn_22+0x227>
    2331:	mov    rax,r13
    2334:	mov    r13,r14
    2337:	mov    r14,rax
    233a:	jmp    24e1 <botlish_fn_22+0x3c9>
    233f:	mov    edx,0x3
    2344:	mov    rax,QWORD PTR [rip+0x0]        # 234b <botlish_fn_22+0x233>
			2347: R_X86_64_GOTPCREL	rt_list_get-0x4
    234b:	mov    rsi,r12
    234e:	mov    rdi,QWORD PTR [rsp]
    2352:	call   rax
    2354:	test   rax,rax
    2357:	jne    2366 <botlish_fn_22+0x24e>
    235d:	mov    rdi,QWORD PTR [rsp]
    2361:	jmp    24b5 <botlish_fn_22+0x39d>
    2366:	xor    ecx,ecx
    2368:	test   rax,0x7
    236e:	je     237c <botlish_fn_22+0x264>
    2374:	mov    rsi,rax
    2377:	jmp    238a <botlish_fn_22+0x272>
    237c:	movzx  rcx,BYTE PTR [rax]
    2380:	mov    rsi,rax
    2383:	rex cmp cl,0x8
    2387:	sete   cl
    238a:	test   cl,cl
    238c:	jne    23b5 <botlish_fn_22+0x29d>
    2392:	mov    rdi,QWORD PTR [rsp]
    2396:	mov    rax,QWORD PTR [rdi+0x10]
    239a:	mov    rcx,QWORD PTR [rax+0x8]
    239e:	mov    edx,0x8
    23a3:	mov    rax,QWORD PTR [rip+0x0]        # 23aa <botlish_fn_22+0x292>
			23a6: R_X86_64_GOTPCREL	rt_type_error-0x4
    23aa:	call   rax
    23ac:	mov    rdi,QWORD PTR [rsp]
    23b0:	jmp    24b5 <botlish_fn_22+0x39d>
    23b5:	mov    rax,QWORD PTR [rip+0x0]        # 23bc <botlish_fn_22+0x2a4>
			23b8: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    23bc:	mov    rdx,QWORD PTR [rsp+0x8]
    23c1:	mov    rdi,QWORD PTR [rsp]
    23c5:	call   rax
    23c7:	test   rax,rax
    23ca:	jne    23d9 <botlish_fn_22+0x2c1>
    23d0:	mov    rdi,QWORD PTR [rsp]
    23d4:	jmp    24b5 <botlish_fn_22+0x39d>
    23d9:	mov    QWORD PTR [r15+0x28],rax
    23dd:	mov    QWORD PTR [rsp+0x10],rax
    23e2:	mov    edx,0x5
    23e7:	mov    rax,QWORD PTR [rip+0x0]        # 23ee <botlish_fn_22+0x2d6>
			23ea: R_X86_64_GOTPCREL	rt_list_get-0x4
    23ee:	mov    rsi,r12
    23f1:	mov    rdi,QWORD PTR [rsp]
    23f5:	call   rax
    23f7:	test   rax,rax
    23fa:	jne    2409 <botlish_fn_22+0x2f1>
    2400:	mov    rdi,QWORD PTR [rsp]
    2404:	jmp    24b5 <botlish_fn_22+0x39d>
    2409:	xor    esi,esi
    240b:	test   rax,0x7
    2411:	je     241f <botlish_fn_22+0x307>
    2417:	mov    r8,rax
    241a:	jmp    242e <botlish_fn_22+0x316>
    241f:	movzx  rcx,BYTE PTR [rax]
    2423:	mov    r8,rax
    2426:	rex cmp cl,0x8
    242a:	sete   sil
    242e:	test   sil,sil
    2431:	jne    245d <botlish_fn_22+0x345>
    2437:	mov    rdi,QWORD PTR [rsp]
    243b:	mov    rax,QWORD PTR [rdi+0x10]
    243f:	mov    rcx,QWORD PTR [rax+0x8]
    2443:	mov    edx,0x8
    2448:	mov    rax,QWORD PTR [rip+0x0]        # 244f <botlish_fn_22+0x337>
			244b: R_X86_64_GOTPCREL	rt_type_error-0x4
    244f:	mov    rsi,r8
    2452:	call   rax
    2454:	mov    rdi,QWORD PTR [rsp]
    2458:	jmp    24b5 <botlish_fn_22+0x39d>
    245d:	mov    rsi,r8
    2460:	mov    rax,QWORD PTR [rip+0x0]        # 2467 <botlish_fn_22+0x34f>
			2463: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2467:	mov    rdx,QWORD PTR [rsp+0x8]
    246c:	mov    rdi,QWORD PTR [rsp]
    2470:	call   rax
    2472:	test   rax,rax
    2475:	jne    2484 <botlish_fn_22+0x36c>
    247b:	mov    rdi,QWORD PTR [rsp]
    247f:	jmp    24b5 <botlish_fn_22+0x39d>
    2484:	mov    QWORD PTR [r15+0x30],rax
    2488:	mov    r9,r13
    248b:	mov    r13,r14
    248e:	mov    r14,r9
    2491:	mov    r8,rax
    2494:	mov    rcx,QWORD PTR [rsp+0x10]
    2499:	mov    rdx,r14
    249c:	mov    rsi,r13
    249f:	mov    rdi,QWORD PTR [rsp]
    24a3:	call   24a8 <botlish_fn_22+0x390>
			24a4: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    24a8:	test   rax,rax
    24ab:	jne    24e1 <botlish_fn_22+0x3c9>
    24b1:	mov    rdi,QWORD PTR [rsp]
    24b5:	mov    rdi,QWORD PTR [rsp]
    24b9:	mov    QWORD PTR [rdi],r15
    24bc:	xor    rax,rax
    24bf:	mov    rbx,QWORD PTR [rsp+0x20]
    24c4:	mov    r12,QWORD PTR [rsp+0x28]
    24c9:	mov    r13,QWORD PTR [rsp+0x30]
    24ce:	mov    r14,QWORD PTR [rsp+0x38]
    24d3:	mov    r15,QWORD PTR [rsp+0x40]
    24d8:	add    rsp,0x50
    24dc:	mov    rsp,rbp
    24df:	pop    rbp
    24e0:	ret
    24e1:	mov    edx,0x3
    24e6:	mov    QWORD PTR [r15+0x28],0x3
    24ee:	mov    rsi,QWORD PTR [rsp+0x8]
    24f3:	test   rsi,0x1
    24fa:	je     2521 <botlish_fn_22+0x409>
    2500:	mov    rsi,QWORD PTR [rsp+0x8]
    2505:	mov    rax,rsi
    2508:	add    rax,0x2
    250c:	seto   cl
    250f:	test   cl,cl
    2511:	jne    2521 <botlish_fn_22+0x409>
    2517:	mov    QWORD PTR [rsp+0x8],rax
    251c:	jmp    2538 <botlish_fn_22+0x420>
    2521:	mov    rax,QWORD PTR [rip+0x0]        # 2528 <botlish_fn_22+0x410>
			2524: R_X86_64_GOTPCREL	rt_int_add-0x4
    2528:	mov    rsi,QWORD PTR [rsp+0x8]
    252d:	mov    rdi,QWORD PTR [rsp]
    2531:	call   rax
    2533:	mov    QWORD PTR [rsp+0x8],rax
    2538:	mov    QWORD PTR [r15],r12
    253b:	mov    rsi,QWORD PTR [rsp+0x8]
    2540:	mov    QWORD PTR [r15+0x8],rsi
    2544:	mov    QWORD PTR [r15+0x10],rbx
    2548:	mov    QWORD PTR [r15+0x18],r13
    254c:	mov    QWORD PTR [r15+0x20],r14
    2550:	mov    rax,r13
    2553:	mov    r13,r14
    2556:	mov    r14,rax
    2559:	jmp    21b1 <botlish_fn_22+0x99>
    255e:	mov    rdi,QWORD PTR [rsp]
    2562:	mov    QWORD PTR [rdi],r15
    2565:	mov    eax,0xa
    256a:	mov    rbx,QWORD PTR [rsp+0x20]
    256f:	mov    r12,QWORD PTR [rsp+0x28]
    2574:	mov    r13,QWORD PTR [rsp+0x30]
    2579:	mov    r14,QWORD PTR [rsp+0x38]
    257e:	mov    r15,QWORD PTR [rsp+0x40]
    2583:	add    rsp,0x50
    2587:	mov    rsp,rbp
    258a:	pop    rbp
    258b:	ret
    258c:	mov    QWORD PTR [rsp],rdi
    2590:	mov    rsi,QWORD PTR [rip+0x0]        # 2597 <botlish_fn_22+0x47f>
			2593: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2597:	call   rsi
    2599:	xor    rax,rax
    259c:	mov    rbx,QWORD PTR [rsp+0x20]
    25a1:	mov    r12,QWORD PTR [rsp+0x28]
    25a6:	mov    r13,QWORD PTR [rsp+0x30]
    25ab:	mov    r14,QWORD PTR [rsp+0x38]
    25b0:	mov    r15,QWORD PTR [rsp+0x40]
    25b5:	add    rsp,0x50
    25b9:	mov    rsp,rbp
    25bc:	pop    rbp
    25bd:	ret
    25be:	add    BYTE PTR [rax],al
    25c0:	(bad)
    25c1:	add    BYTE PTR [rax],al
    25c3:	add    BYTE PTR [rax],al
    25c5:	add    BYTE PTR [rax],al
	...

00000000000025c8 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    25c8:	push   rbp
    25c9:	mov    rbp,rsp
    25cc:	mov    rsi,QWORD PTR [rdx]
    25cf:	mov    r10,QWORD PTR [rdx+0x8]
    25d3:	mov    rcx,QWORD PTR [rdx+0x10]
    25d7:	mov    r8,QWORD PTR [rdx+0x18]
    25db:	mov    r9,QWORD PTR [rdx+0x20]
    25df:	mov    rdx,r10
    25e2:	call   25e7 <botlish_entry_22+0x1f>
			25e3: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    25e7:	mov    rsp,rbp
    25ea:	pop    rbp
    25eb:	ret

00000000000025ec <botlish_fn_23: ht_rehash<mutarray, int>>:
    25ec:	push   rbp
    25ed:	mov    rbp,rsp
    25f0:	sub    rsp,0x80
    25f7:	mov    QWORD PTR [rsp+0x50],rbx
    25fc:	mov    QWORD PTR [rsp+0x58],r12
    2601:	mov    QWORD PTR [rsp+0x60],r13
    2606:	mov    QWORD PTR [rsp+0x68],r14
    260b:	mov    QWORD PTR [rsp+0x70],r15
    2610:	mov    rbx,QWORD PTR [rdi]
    2613:	mov    rax,QWORD PTR [rdi+0x8]
    2617:	lea    rcx,[rbx+0x38]
    261b:	cmp    rcx,rax
    261e:	ja     29e0 <botlish_fn_23+0x3f4>
    2624:	lea    rax,[rbx+0x38]
    2628:	mov    QWORD PTR [rdi],rax
    262b:	mov    r12,rdi
    262e:	mov    QWORD PTR [rbx],0x0
    2635:	mov    QWORD PTR [rbx+0x8],0x0
    263d:	mov    QWORD PTR [rbx+0x10],0x0
    2645:	mov    QWORD PTR [rbx+0x18],0x0
    264d:	mov    QWORD PTR [rbx+0x20],0x0
    2655:	mov    QWORD PTR [rbx+0x28],0x0
    265d:	mov    QWORD PTR [rbx+0x30],0x0
    2665:	mov    QWORD PTR [rbx],rsi
    2668:	mov    r13,rsi
    266b:	mov    QWORD PTR [rbx+0x8],rdx
    266f:	mov    r14,rdx
    2672:	mov    rsi,r13
    2675:	mov    rdi,r12
    2678:	call   267d <botlish_fn_23+0x91>
			2679: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    267d:	test   rax,rax
    2680:	jne    268e <botlish_fn_23+0xa2>
    2686:	mov    rdi,r12
    2689:	jmp    2982 <botlish_fn_23+0x396>
    268e:	mov    QWORD PTR [rbx+0x10],rax
    2692:	mov    r15,rax
    2695:	mov    rsi,r13
    2698:	mov    rdi,r12
    269b:	call   26a0 <botlish_fn_23+0xb4>
			269c: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    26a0:	test   rax,rax
    26a3:	jne    26b1 <botlish_fn_23+0xc5>
    26a9:	mov    rdi,r12
    26ac:	jmp    2982 <botlish_fn_23+0x396>
    26b1:	mov    QWORD PTR [rbx+0x18],rax
    26b5:	mov    QWORD PTR [rsp+0x40],rax
    26ba:	mov    rsi,r13
    26bd:	mov    rdi,r12
    26c0:	call   26c5 <botlish_fn_23+0xd9>
			26c1: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    26c5:	test   rax,rax
    26c8:	jne    26d6 <botlish_fn_23+0xea>
    26ce:	mov    rdi,r12
    26d1:	jmp    2982 <botlish_fn_23+0x396>
    26d6:	mov    QWORD PTR [rbx+0x20],rax
    26da:	lea    rdx,[rsp]
    26de:	mov    rcx,r15
    26e1:	mov    QWORD PTR [rsp],rcx
    26e5:	mov    rcx,QWORD PTR [rsp+0x40]
    26ea:	mov    QWORD PTR [rsp+0x8],rcx
    26ef:	mov    QWORD PTR [rsp+0x10],rax
    26f4:	mov    esi,0x3
    26f9:	mov    rax,QWORD PTR [rip+0x0]        # 2700 <botlish_fn_23+0x114>
			26fc: R_X86_64_GOTPCREL	rt_list_new-0x4
    2700:	mov    rdi,r12
    2703:	call   rax
    2705:	test   rax,rax
    2708:	jne    2716 <botlish_fn_23+0x12a>
    270e:	mov    rdi,r12
    2711:	jmp    2982 <botlish_fn_23+0x396>
    2716:	mov    QWORD PTR [rbx+0x10],rax
    271a:	mov    r15,rax
    271d:	mov    rsi,r13
    2720:	mov    rdi,r12
    2723:	call   2728 <botlish_fn_23+0x13c>
			2724: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2728:	test   rax,rax
    272b:	jne    2739 <botlish_fn_23+0x14d>
    2731:	mov    rdi,r12
    2734:	jmp    2982 <botlish_fn_23+0x396>
    2739:	mov    QWORD PTR [rbx+0x18],rax
    273d:	mov    QWORD PTR [rsp+0x40],rax
    2742:	mov    rax,QWORD PTR [rip+0x0]        # 2749 <botlish_fn_23+0x15d>
			2745: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    2749:	mov    rsi,r14
    274c:	mov    rdi,r12
    274f:	call   rax
    2751:	test   rax,rax
    2754:	jne    2762 <botlish_fn_23+0x176>
    275a:	mov    rdi,r12
    275d:	jmp    2982 <botlish_fn_23+0x396>
    2762:	mov    QWORD PTR [rbx+0x20],rax
    2766:	mov    QWORD PTR [rsp+0x38],rax
    276b:	mov    edx,0x1
    2770:	mov    QWORD PTR [rbx+0x28],0x1
    2778:	mov    rcx,r14
    277b:	mov    rsi,QWORD PTR [rsp+0x38]
    2780:	mov    rdi,r12
    2783:	call   2788 <botlish_fn_23+0x19c>
			2784: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    2788:	test   rax,rax
    278b:	jne    2799 <botlish_fn_23+0x1ad>
    2791:	mov    rdi,r12
    2794:	jmp    2982 <botlish_fn_23+0x396>
    2799:	mov    rax,QWORD PTR [rip+0x0]        # 27a0 <botlish_fn_23+0x1b4>
			279c: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    27a0:	mov    rsi,r14
    27a3:	mov    rdi,r12
    27a6:	call   rax
    27a8:	test   rax,rax
    27ab:	jne    27b9 <botlish_fn_23+0x1cd>
    27b1:	mov    rdi,r12
    27b4:	jmp    2982 <botlish_fn_23+0x396>
    27b9:	mov    QWORD PTR [rbx+0x28],rax
    27bd:	mov    QWORD PTR [rsp+0x30],rax
    27c2:	mov    rax,QWORD PTR [rip+0x0]        # 27c9 <botlish_fn_23+0x1dd>
			27c5: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    27c9:	mov    rsi,r14
    27cc:	mov    rdi,r12
    27cf:	call   rax
    27d1:	test   rax,rax
    27d4:	jne    27e2 <botlish_fn_23+0x1f6>
    27da:	mov    rdi,r12
    27dd:	jmp    2982 <botlish_fn_23+0x396>
    27e2:	mov    QWORD PTR [rbx+0x30],rax
    27e6:	lea    rdx,[rsp+0x18]
    27eb:	mov    rcx,QWORD PTR [rsp+0x38]
    27f0:	mov    QWORD PTR [rsp+0x18],rcx
    27f5:	mov    rcx,QWORD PTR [rsp+0x30]
    27fa:	mov    QWORD PTR [rsp+0x20],rcx
    27ff:	mov    QWORD PTR [rsp+0x28],rax
    2804:	mov    esi,0x3
    2809:	mov    rax,QWORD PTR [rip+0x0]        # 2810 <botlish_fn_23+0x224>
			280c: R_X86_64_GOTPCREL	rt_list_new-0x4
    2810:	mov    rdi,r12
    2813:	call   rax
    2815:	mov    rcx,rax
    2818:	mov    QWORD PTR [rsp+0x30],rax
    281d:	test   rax,rcx
    2820:	jne    282e <botlish_fn_23+0x242>
    2826:	mov    rdi,r12
    2829:	jmp    2982 <botlish_fn_23+0x396>
    282e:	mov    rax,QWORD PTR [rsp+0x30]
    2833:	mov    QWORD PTR [rbx+0x20],rax
    2837:	mov    edx,0x1
    283c:	mov    QWORD PTR [rbx+0x28],0x1
    2844:	mov    rcx,QWORD PTR [rsp+0x40]
    2849:	mov    rsi,r15
    284c:	mov    r9,r14
    284f:	mov    rdi,r12
    2852:	mov    r8,QWORD PTR [rsp+0x30]
    2857:	call   285c <botlish_fn_23+0x270>
			2858: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    285c:	test   rax,rax
    285f:	jne    286d <botlish_fn_23+0x281>
    2865:	mov    rdi,r12
    2868:	jmp    2982 <botlish_fn_23+0x396>
    286d:	mov    edx,0x1
    2872:	mov    rax,QWORD PTR [rip+0x0]        # 2879 <botlish_fn_23+0x28d>
			2875: R_X86_64_GOTPCREL	rt_list_get-0x4
    2879:	mov    rsi,QWORD PTR [rsp+0x30]
    287e:	mov    rdi,r12
    2881:	call   rax
    2883:	test   rax,rax
    2886:	mov    rcx,rax
    2889:	jne    2897 <botlish_fn_23+0x2ab>
    288f:	mov    rdi,r12
    2892:	jmp    2982 <botlish_fn_23+0x396>
    2897:	mov    edx,0x1
    289c:	mov    rax,QWORD PTR [rip+0x0]        # 28a3 <botlish_fn_23+0x2b7>
			289f: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    28a3:	mov    rsi,r13
    28a6:	mov    rdi,r12
    28a9:	call   rax
    28ab:	test   rax,rax
    28ae:	jne    28bc <botlish_fn_23+0x2d0>
    28b4:	mov    rdi,r12
    28b7:	jmp    2982 <botlish_fn_23+0x396>
    28bc:	mov    edx,0x3
    28c1:	mov    rcx,QWORD PTR [rip+0x0]        # 28c8 <botlish_fn_23+0x2dc>
			28c4: R_X86_64_GOTPCREL	rt_list_get-0x4
    28c8:	mov    rsi,QWORD PTR [rsp+0x30]
    28cd:	mov    rdi,r12
    28d0:	call   rcx
    28d2:	test   rax,rax
    28d5:	mov    rcx,rax
    28d8:	jne    28e6 <botlish_fn_23+0x2fa>
    28de:	mov    rdi,r12
    28e1:	jmp    2982 <botlish_fn_23+0x396>
    28e6:	mov    edx,0x3
    28eb:	mov    r8,QWORD PTR [rip+0x0]        # 28f2 <botlish_fn_23+0x306>
			28ee: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    28f2:	mov    rsi,r13
    28f5:	mov    rdi,r12
    28f8:	call   r8
    28fb:	test   rax,rax
    28fe:	jne    290c <botlish_fn_23+0x320>
    2904:	mov    rdi,r12
    2907:	jmp    2982 <botlish_fn_23+0x396>
    290c:	mov    edx,0x5
    2911:	mov    r8,QWORD PTR [rip+0x0]        # 2918 <botlish_fn_23+0x32c>
			2914: R_X86_64_GOTPCREL	rt_list_get-0x4
    2918:	mov    rsi,QWORD PTR [rsp+0x30]
    291d:	mov    rdi,r12
    2920:	call   r8
    2923:	test   rax,rax
    2926:	mov    rcx,rax
    2929:	jne    2937 <botlish_fn_23+0x34b>
    292f:	mov    rdi,r12
    2932:	jmp    2982 <botlish_fn_23+0x396>
    2937:	mov    edx,0x5
    293c:	mov    r10,QWORD PTR [rip+0x0]        # 2943 <botlish_fn_23+0x357>
			293f: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    2943:	mov    rsi,r13
    2946:	mov    rdi,r12
    2949:	call   r10
    294c:	test   rax,rax
    294f:	jne    295d <botlish_fn_23+0x371>
    2955:	mov    rdi,r12
    2958:	jmp    2982 <botlish_fn_23+0x396>
    295d:	mov    edx,0x9
    2962:	mov    ecx,0x1
    2967:	mov    rax,QWORD PTR [rip+0x0]        # 296e <botlish_fn_23+0x382>
			296a: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    296e:	mov    rsi,r13
    2971:	mov    rdi,r12
    2974:	call   rax
    2976:	test   rax,rax
    2979:	jne    29b0 <botlish_fn_23+0x3c4>
    297f:	mov    rdi,r12
    2982:	mov    rdi,r12
    2985:	mov    QWORD PTR [rdi],rbx
    2988:	xor    rax,rax
    298b:	mov    rbx,QWORD PTR [rsp+0x50]
    2990:	mov    r12,QWORD PTR [rsp+0x58]
    2995:	mov    r13,QWORD PTR [rsp+0x60]
    299a:	mov    r14,QWORD PTR [rsp+0x68]
    299f:	mov    r15,QWORD PTR [rsp+0x70]
    29a4:	add    rsp,0x80
    29ab:	mov    rsp,rbp
    29ae:	pop    rbp
    29af:	ret
    29b0:	mov    rdi,r12
    29b3:	mov    QWORD PTR [rdi],rbx
    29b6:	mov    eax,0xa
    29bb:	mov    rbx,QWORD PTR [rsp+0x50]
    29c0:	mov    r12,QWORD PTR [rsp+0x58]
    29c5:	mov    r13,QWORD PTR [rsp+0x60]
    29ca:	mov    r14,QWORD PTR [rsp+0x68]
    29cf:	mov    r15,QWORD PTR [rsp+0x70]
    29d4:	add    rsp,0x80
    29db:	mov    rsp,rbp
    29de:	pop    rbp
    29df:	ret
    29e0:	mov    r12,rdi
    29e3:	mov    rax,QWORD PTR [rip+0x0]        # 29ea <botlish_fn_23+0x3fe>
			29e6: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    29ea:	call   rax
    29ec:	xor    rax,rax
    29ef:	mov    rbx,QWORD PTR [rsp+0x50]
    29f4:	mov    r12,QWORD PTR [rsp+0x58]
    29f9:	mov    r13,QWORD PTR [rsp+0x60]
    29fe:	mov    r14,QWORD PTR [rsp+0x68]
    2a03:	mov    r15,QWORD PTR [rsp+0x70]
    2a08:	add    rsp,0x80
    2a0f:	mov    rsp,rbp
    2a12:	pop    rbp
    2a13:	ret

0000000000002a14 <botlish_entry_23: ht_rehash<mutarray, int>>:
    2a14:	push   rbp
    2a15:	mov    rbp,rsp
    2a18:	mov    rsi,QWORD PTR [rdx]
    2a1b:	mov    rdx,QWORD PTR [rdx+0x8]
    2a1f:	call   2a24 <botlish_entry_23+0x10>
			2a20: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2a24:	mov    rsp,rbp
    2a27:	pop    rbp
    2a28:	ret
    2a29:	add    BYTE PTR [rax],al
    2a2b:	add    BYTE PTR [rax],al
    2a2d:	add    BYTE PTR [rax],al
	...

0000000000002a30 <botlish_fn_24: ht_should_grow<mutarray>>:
    2a30:	push   rbp
    2a31:	mov    rbp,rsp
    2a34:	sub    rsp,0x20
    2a38:	mov    QWORD PTR [rsp],rbx
    2a3c:	mov    QWORD PTR [rsp+0x8],r12
    2a41:	mov    QWORD PTR [rsp+0x10],r13
    2a46:	mov    QWORD PTR [rsp+0x18],r15
    2a4b:	mov    r15,QWORD PTR [rdi]
    2a4e:	mov    rax,QWORD PTR [rdi+0x8]
    2a52:	lea    rcx,[r15+0x18]
    2a56:	cmp    rcx,rax
    2a59:	ja     2d86 <botlish_fn_24+0x356>
    2a5f:	lea    rax,[r15+0x18]
    2a63:	mov    QWORD PTR [rdi],rax
    2a66:	mov    rbx,rdi
    2a69:	mov    QWORD PTR [r15],0x0
    2a70:	mov    QWORD PTR [r15+0x8],0x0
    2a78:	mov    QWORD PTR [r15+0x10],0x0
    2a80:	mov    QWORD PTR [r15],rsi
    2a83:	mov    r12,rsi
    2a86:	mov    rsi,r12
    2a89:	mov    rdi,rbx
    2a8c:	call   2a91 <botlish_fn_24+0x61>
			2a8d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2a91:	mov    rcx,rax
    2a94:	mov    r13,rax
    2a97:	test   rax,rcx
    2a9a:	jne    2aa8 <botlish_fn_24+0x78>
    2aa0:	mov    rdi,rbx
    2aa3:	jmp    2c98 <botlish_fn_24+0x268>
    2aa8:	mov    rax,r13
    2aab:	mov    QWORD PTR [r15+0x8],rax
    2aaf:	mov    rsi,r12
    2ab2:	mov    rdi,rbx
    2ab5:	call   2aba <botlish_fn_24+0x8a>
			2ab6: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2aba:	mov    rcx,rax
    2abd:	test   rcx,rcx
    2ac0:	jne    2ace <botlish_fn_24+0x9e>
    2ac6:	mov    rdi,rbx
    2ac9:	jmp    2c98 <botlish_fn_24+0x268>
    2ace:	mov    QWORD PTR [r15+0x10],rcx
    2ad2:	mov    edx,0x1
    2ad7:	mov    rax,r13
    2ada:	test   rax,0x1
    2ae0:	jne    2b03 <botlish_fn_24+0xd3>
    2ae6:	xor    edx,edx
    2ae8:	mov    rax,r13
    2aeb:	test   rax,0x7
    2af1:	jne    2b03 <botlish_fn_24+0xd3>
    2af7:	mov    rax,r13
    2afa:	movzx  rax,BYTE PTR [rax]
    2afe:	cmp    al,0x1
    2b00:	sete   dl
    2b03:	test   dl,dl
    2b05:	jne    2b2d <botlish_fn_24+0xfd>
    2b0b:	mov    rdi,rbx
    2b0e:	mov    rax,QWORD PTR [rdi+0x10]
    2b12:	mov    rcx,QWORD PTR [rax+0x10]
    2b16:	xor    rdx,rdx
    2b19:	mov    rax,QWORD PTR [rip+0x0]        # 2b20 <botlish_fn_24+0xf0>
			2b1c: R_X86_64_GOTPCREL	rt_type_error-0x4
    2b20:	mov    rsi,r13
    2b23:	call   rax
    2b25:	mov    rdi,rbx
    2b28:	jmp    2c98 <botlish_fn_24+0x268>
    2b2d:	mov    eax,0x1
    2b32:	test   rcx,0x1
    2b39:	je     2b47 <botlish_fn_24+0x117>
    2b3f:	mov    r8,rcx
    2b42:	jmp    2b6a <botlish_fn_24+0x13a>
    2b47:	xor    eax,eax
    2b49:	test   rcx,0x7
    2b50:	je     2b5e <botlish_fn_24+0x12e>
    2b56:	mov    r8,rcx
    2b59:	jmp    2b6a <botlish_fn_24+0x13a>
    2b5e:	movzx  rax,BYTE PTR [rcx]
    2b62:	mov    r8,rcx
    2b65:	cmp    al,0x1
    2b67:	sete   al
    2b6a:	test   al,al
    2b6c:	jne    2b94 <botlish_fn_24+0x164>
    2b72:	mov    rdi,rbx
    2b75:	mov    rax,QWORD PTR [rdi+0x10]
    2b79:	mov    rcx,QWORD PTR [rax+0x10]
    2b7d:	xor    rdx,rdx
    2b80:	mov    rax,QWORD PTR [rip+0x0]        # 2b87 <botlish_fn_24+0x157>
			2b83: R_X86_64_GOTPCREL	rt_type_error-0x4
    2b87:	mov    rsi,r8
    2b8a:	call   rax
    2b8c:	mov    rdi,rbx
    2b8f:	jmp    2c98 <botlish_fn_24+0x268>
    2b94:	mov    rcx,r8
    2b97:	mov    rsi,r13
    2b9a:	mov    rax,rsi
    2b9d:	and    rax,rcx
    2ba0:	test   rax,0x1
    2ba6:	je     2bc4 <botlish_fn_24+0x194>
    2bac:	mov    rcx,r8
    2baf:	lea    rax,[rcx-0x1]
    2bb3:	mov    rsi,r13
    2bb6:	add    rsi,rax
    2bb9:	seto   al
    2bbc:	test   al,al
    2bbe:	je     2bd9 <botlish_fn_24+0x1a9>
    2bc4:	mov    rax,QWORD PTR [rip+0x0]        # 2bcb <botlish_fn_24+0x19b>
			2bc7: R_X86_64_GOTPCREL	rt_int_add-0x4
    2bcb:	mov    rdx,r8
    2bce:	mov    rsi,r13
    2bd1:	mov    rdi,rbx
    2bd4:	call   rax
    2bd6:	mov    rsi,rax
    2bd9:	mov    QWORD PTR [r15+0x8],rsi
    2bdd:	mov    QWORD PTR [r15+0x10],0x3
    2be5:	test   rsi,0x1
    2bec:	je     2c0e <botlish_fn_24+0x1de>
    2bf2:	mov    rax,rsi
    2bf5:	add    rax,0x2
    2bf9:	seto   dil
    2bfd:	test   dil,dil
    2c00:	jne    2c0e <botlish_fn_24+0x1de>
    2c06:	mov    rsi,rax
    2c09:	jmp    2c23 <botlish_fn_24+0x1f3>
    2c0e:	mov    edx,0x3
    2c13:	mov    r8,QWORD PTR [rip+0x0]        # 2c1a <botlish_fn_24+0x1ea>
			2c16: R_X86_64_GOTPCREL	rt_int_add-0x4
    2c1a:	mov    rdi,rbx
    2c1d:	call   r8
    2c20:	mov    rsi,rax
    2c23:	mov    QWORD PTR [r15+0x8],rsi
    2c27:	mov    edx,0x7
    2c2c:	mov    rdi,rdx
    2c2f:	mov    QWORD PTR [r15+0x10],0x7
    2c37:	test   rsi,0x1
    2c3e:	je     2c68 <botlish_fn_24+0x238>
    2c44:	mov    rax,rsi
    2c47:	sar    rax,1
    2c4a:	imul   QWORD PTR [rip+0x167]        # 2db8 <botlish_fn_24+0x388>
    2c51:	seto   cl
    2c54:	or     rax,0x1
    2c58:	test   cl,cl
    2c5a:	jne    2c68 <botlish_fn_24+0x238>
    2c60:	mov    rsi,rax
    2c63:	jmp    2c7a <botlish_fn_24+0x24a>
    2c68:	mov    rax,QWORD PTR [rip+0x0]        # 2c6f <botlish_fn_24+0x23f>
			2c6b: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2c6f:	mov    rdx,rdi
    2c72:	mov    rdi,rbx
    2c75:	call   rax
    2c77:	mov    rsi,rax
    2c7a:	mov    QWORD PTR [r15+0x8],rsi
    2c7e:	mov    r13,rsi
    2c81:	mov    rsi,r12
    2c84:	mov    rdi,rbx
    2c87:	call   2c8c <botlish_fn_24+0x25c>
			2c88: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2c8c:	test   rax,rax
    2c8f:	jne    2cbd <botlish_fn_24+0x28d>
    2c95:	mov    rdi,rbx
    2c98:	mov    rdi,rbx
    2c9b:	mov    QWORD PTR [rdi],r15
    2c9e:	xor    rax,rax
    2ca1:	mov    rbx,QWORD PTR [rsp]
    2ca5:	mov    r12,QWORD PTR [rsp+0x8]
    2caa:	mov    r13,QWORD PTR [rsp+0x10]
    2caf:	mov    r15,QWORD PTR [rsp+0x18]
    2cb4:	add    rsp,0x20
    2cb8:	mov    rsp,rbp
    2cbb:	pop    rbp
    2cbc:	ret
    2cbd:	mov    QWORD PTR [r15],rax
    2cc0:	mov    QWORD PTR [r15+0x10],0x5
    2cc8:	test   rax,0x1
    2cce:	mov    rsi,rax
    2cd1:	je     2d01 <botlish_fn_24+0x2d1>
    2cd7:	mov    rcx,rsi
    2cda:	mov    rax,rcx
    2cdd:	sar    rax,1
    2ce0:	imul   QWORD PTR [rip+0xd9]        # 2dc0 <botlish_fn_24+0x390>
    2ce7:	seto   cl
    2cea:	or     rax,0x1
    2cee:	test   cl,cl
    2cf0:	jne    2d01 <botlish_fn_24+0x2d1>
    2cf6:	mov    rdx,rax
    2cf9:	mov    rsi,r13
    2cfc:	jmp    2d18 <botlish_fn_24+0x2e8>
    2d01:	mov    edx,0x5
    2d06:	mov    rax,QWORD PTR [rip+0x0]        # 2d0d <botlish_fn_24+0x2dd>
			2d09: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2d0d:	mov    rdi,rbx
    2d10:	call   rax
    2d12:	mov    rdx,rax
    2d15:	mov    rsi,r13
    2d18:	mov    rax,rsi
    2d1b:	and    rax,rdx
    2d1e:	test   rax,0x1
    2d24:	jne    2d51 <botlish_fn_24+0x321>
    2d2a:	mov    rax,QWORD PTR [rip+0x0]        # 2d31 <botlish_fn_24+0x301>
			2d2d: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    2d31:	mov    rdi,rbx
    2d34:	call   rax
    2d36:	mov    ecx,0x2
    2d3b:	test   rax,rax
    2d3e:	mov    rax,rcx
    2d41:	cmovg  rax,QWORD PTR [rip+0x6f]        # 2db8 <botlish_fn_24+0x388>
    2d49:	mov    rdi,rbx
    2d4c:	jmp    2d64 <botlish_fn_24+0x334>
    2d51:	mov    eax,0x2
    2d56:	cmp    rsi,rdx
    2d59:	cmovg  rax,QWORD PTR [rip+0x57]        # 2db8 <botlish_fn_24+0x388>
    2d61:	mov    rdi,rbx
    2d64:	mov    rdi,rbx
    2d67:	mov    QWORD PTR [rdi],r15
    2d6a:	mov    rbx,QWORD PTR [rsp]
    2d6e:	mov    r12,QWORD PTR [rsp+0x8]
    2d73:	mov    r13,QWORD PTR [rsp+0x10]
    2d78:	mov    r15,QWORD PTR [rsp+0x18]
    2d7d:	add    rsp,0x20
    2d81:	mov    rsp,rbp
    2d84:	pop    rbp
    2d85:	ret
    2d86:	mov    rbx,rdi
    2d89:	mov    rax,QWORD PTR [rip+0x0]        # 2d90 <botlish_fn_24+0x360>
			2d8c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2d90:	call   rax
    2d92:	xor    rax,rax
    2d95:	mov    rbx,QWORD PTR [rsp]
    2d99:	mov    r12,QWORD PTR [rsp+0x8]
    2d9e:	mov    r13,QWORD PTR [rsp+0x10]
    2da3:	mov    r15,QWORD PTR [rsp+0x18]
    2da8:	add    rsp,0x20
    2dac:	mov    rsp,rbp
    2daf:	pop    rbp
    2db0:	ret
    2db1:	add    BYTE PTR [rax],al
    2db3:	add    BYTE PTR [rax],al
    2db5:	add    BYTE PTR [rax],al
    2db7:	add    BYTE PTR [rsi],al
    2db9:	add    BYTE PTR [rax],al
    2dbb:	add    BYTE PTR [rax],al
    2dbd:	add    BYTE PTR [rax],al
    2dbf:	add    BYTE PTR [rax+rax*1],al
    2dc2:	add    BYTE PTR [rax],al
    2dc4:	add    BYTE PTR [rax],al
	...

0000000000002dc8 <botlish_entry_24: ht_should_grow<mutarray>>:
    2dc8:	push   rbp
    2dc9:	mov    rbp,rsp
    2dcc:	mov    rsi,QWORD PTR [rdx]
    2dcf:	call   2dd4 <botlish_entry_24+0xc>
			2dd0: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2dd4:	mov    rsp,rbp
    2dd7:	pop    rbp
    2dd8:	ret
    2dd9:	add    BYTE PTR [rax],al
    2ddb:	add    BYTE PTR [rax],al
    2ddd:	add    BYTE PTR [rax],al
	...

0000000000002de0 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    2de0:	push   rbp
    2de1:	mov    rbp,rsp
    2de4:	sub    rsp,0x20
    2de8:	mov    QWORD PTR [rsp],rbx
    2dec:	mov    QWORD PTR [rsp+0x8],r12
    2df1:	mov    QWORD PTR [rsp+0x10],r13
    2df6:	mov    QWORD PTR [rsp+0x18],r14
    2dfb:	mov    rbx,QWORD PTR [rdi]
    2dfe:	mov    rax,QWORD PTR [rdi+0x8]
    2e02:	lea    rcx,[rbx+0x18]
    2e06:	cmp    rcx,rax
    2e09:	ja     30c0 <botlish_fn_25+0x2e0>
    2e0f:	lea    rax,[rbx+0x18]
    2e13:	mov    QWORD PTR [rdi],rax
    2e16:	mov    r12,rdi
    2e19:	mov    QWORD PTR [rbx],0x0
    2e20:	mov    QWORD PTR [rbx+0x8],0x0
    2e28:	mov    QWORD PTR [rbx+0x10],0x0
    2e30:	mov    QWORD PTR [rbx],rsi
    2e33:	mov    r13,rsi
    2e36:	mov    rsi,r13
    2e39:	mov    rdi,r12
    2e3c:	call   2e41 <botlish_fn_25+0x61>
			2e3d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2e41:	test   rax,rax
    2e44:	jne    2e52 <botlish_fn_25+0x72>
    2e4a:	mov    rdi,r12
    2e4d:	jmp    3076 <botlish_fn_25+0x296>
    2e52:	mov    QWORD PTR [rbx+0x8],rax
    2e56:	mov    r14,rax
    2e59:	mov    rsi,r13
    2e5c:	mov    rdi,r12
    2e5f:	call   2e64 <botlish_fn_25+0x84>
			2e60: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2e64:	mov    rcx,rax
    2e67:	test   rcx,rcx
    2e6a:	jne    2e78 <botlish_fn_25+0x98>
    2e70:	mov    rdi,r12
    2e73:	jmp    3076 <botlish_fn_25+0x296>
    2e78:	mov    edx,0x1
    2e7d:	mov    rax,r14
    2e80:	test   rax,0x1
    2e86:	je     2e94 <botlish_fn_25+0xb4>
    2e8c:	mov    r14,rax
    2e8f:	jmp    2eb8 <botlish_fn_25+0xd8>
    2e94:	xor    edx,edx
    2e96:	test   rax,0x7
    2e9c:	je     2eaa <botlish_fn_25+0xca>
    2ea2:	mov    r14,rax
    2ea5:	jmp    2eb8 <botlish_fn_25+0xd8>
    2eaa:	movzx  rdx,BYTE PTR [rax]
    2eae:	mov    r14,rax
    2eb1:	rex cmp dl,0x1
    2eb5:	sete   dl
    2eb8:	test   dl,dl
    2eba:	jne    2ee2 <botlish_fn_25+0x102>
    2ec0:	mov    rdi,r12
    2ec3:	mov    rax,QWORD PTR [rdi+0x10]
    2ec7:	mov    rcx,QWORD PTR [rax+0x18]
    2ecb:	xor    rdx,rdx
    2ece:	mov    rax,QWORD PTR [rip+0x0]        # 2ed5 <botlish_fn_25+0xf5>
			2ed1: R_X86_64_GOTPCREL	rt_type_error-0x4
    2ed5:	mov    rsi,r14
    2ed8:	call   rax
    2eda:	mov    rdi,r12
    2edd:	jmp    3076 <botlish_fn_25+0x296>
    2ee2:	mov    rsi,r14
    2ee5:	mov    eax,0x1
    2eea:	test   rcx,0x1
    2ef1:	je     2eff <botlish_fn_25+0x11f>
    2ef7:	mov    r8,rcx
    2efa:	jmp    2f22 <botlish_fn_25+0x142>
    2eff:	xor    eax,eax
    2f01:	test   rcx,0x7
    2f08:	je     2f16 <botlish_fn_25+0x136>
    2f0e:	mov    r8,rcx
    2f11:	jmp    2f22 <botlish_fn_25+0x142>
    2f16:	movzx  rax,BYTE PTR [rcx]
    2f1a:	mov    r8,rcx
    2f1d:	cmp    al,0x1
    2f1f:	sete   al
    2f22:	test   al,al
    2f24:	jne    2f4c <botlish_fn_25+0x16c>
    2f2a:	mov    rdi,r12
    2f2d:	mov    rax,QWORD PTR [rdi+0x10]
    2f31:	mov    rcx,QWORD PTR [rax+0x18]
    2f35:	xor    rdx,rdx
    2f38:	mov    rax,QWORD PTR [rip+0x0]        # 2f3f <botlish_fn_25+0x15f>
			2f3b: R_X86_64_GOTPCREL	rt_type_error-0x4
    2f3f:	mov    rsi,r8
    2f42:	call   rax
    2f44:	mov    rdi,r12
    2f47:	jmp    3076 <botlish_fn_25+0x296>
    2f4c:	mov    rcx,r8
    2f4f:	mov    rax,rsi
    2f52:	and    rax,rcx
    2f55:	test   rax,0x1
    2f5b:	jne    2f85 <botlish_fn_25+0x1a5>
    2f61:	mov    rax,QWORD PTR [rip+0x0]        # 2f68 <botlish_fn_25+0x188>
			2f64: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    2f68:	mov    rdx,r8
    2f6b:	mov    rdi,r12
    2f6e:	call   rax
    2f70:	mov    ecx,0x2
    2f75:	test   rax,rax
    2f78:	cmovg  rcx,QWORD PTR [rip+0x170]        # 30f0 <botlish_fn_25+0x310>
    2f80:	jmp    2f98 <botlish_fn_25+0x1b8>
    2f85:	mov    ecx,0x2
    2f8a:	mov    rax,r8
    2f8d:	cmp    rsi,rax
    2f90:	cmovg  rcx,QWORD PTR [rip+0x158]        # 30f0 <botlish_fn_25+0x310>
    2f98:	cmp    rcx,0x6
    2f9c:	je     303c <botlish_fn_25+0x25c>
    2fa2:	mov    rsi,r13
    2fa5:	mov    rdi,r12
    2fa8:	call   2fad <botlish_fn_25+0x1cd>
			2fa9: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2fad:	test   rax,rax
    2fb0:	jne    2fbe <botlish_fn_25+0x1de>
    2fb6:	mov    rdi,r12
    2fb9:	jmp    3076 <botlish_fn_25+0x296>
    2fbe:	mov    QWORD PTR [rbx+0x8],rax
    2fc2:	mov    QWORD PTR [rbx+0x10],0x5
    2fca:	test   rax,0x1
    2fd0:	mov    rsi,rax
    2fd3:	je     3000 <botlish_fn_25+0x220>
    2fd9:	mov    rcx,rsi
    2fdc:	mov    rax,rcx
    2fdf:	sar    rax,1
    2fe2:	imul   QWORD PTR [rip+0x10f]        # 30f8 <botlish_fn_25+0x318>
    2fe9:	seto   cl
    2fec:	or     rax,0x1
    2ff0:	test   cl,cl
    2ff2:	jne    3000 <botlish_fn_25+0x220>
    2ff8:	mov    rdx,rax
    2ffb:	jmp    3014 <botlish_fn_25+0x234>
    3000:	mov    edx,0x5
    3005:	mov    rax,QWORD PTR [rip+0x0]        # 300c <botlish_fn_25+0x22c>
			3008: R_X86_64_GOTPCREL	rt_int_mul-0x4
    300c:	mov    rdi,r12
    300f:	call   rax
    3011:	mov    rdx,rax
    3014:	mov    QWORD PTR [rbx+0x8],rdx
    3018:	mov    rsi,r13
    301b:	mov    rdi,r12
    301e:	call   3023 <botlish_fn_25+0x243>
			301f: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    3023:	test   rax,rax
    3026:	jne    3034 <botlish_fn_25+0x254>
    302c:	mov    rdi,r12
    302f:	jmp    3076 <botlish_fn_25+0x296>
    3034:	mov    rdi,r12
    3037:	jmp    309e <botlish_fn_25+0x2be>
    303c:	mov    rsi,r13
    303f:	mov    rdi,r12
    3042:	call   3047 <botlish_fn_25+0x267>
			3043: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    3047:	test   rax,rax
    304a:	jne    3058 <botlish_fn_25+0x278>
    3050:	mov    rdi,r12
    3053:	jmp    3076 <botlish_fn_25+0x296>
    3058:	mov    QWORD PTR [rbx+0x8],rax
    305c:	mov    rdx,rax
    305f:	mov    rsi,r13
    3062:	mov    rdi,r12
    3065:	call   306a <botlish_fn_25+0x28a>
			3066: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    306a:	test   rax,rax
    306d:	jne    309b <botlish_fn_25+0x2bb>
    3073:	mov    rdi,r12
    3076:	mov    rdi,r12
    3079:	mov    QWORD PTR [rdi],rbx
    307c:	xor    rax,rax
    307f:	mov    rbx,QWORD PTR [rsp]
    3083:	mov    r12,QWORD PTR [rsp+0x8]
    3088:	mov    r13,QWORD PTR [rsp+0x10]
    308d:	mov    r14,QWORD PTR [rsp+0x18]
    3092:	add    rsp,0x20
    3096:	mov    rsp,rbp
    3099:	pop    rbp
    309a:	ret
    309b:	mov    rdi,r12
    309e:	mov    rdi,r12
    30a1:	mov    QWORD PTR [rdi],rbx
    30a4:	mov    rbx,QWORD PTR [rsp]
    30a8:	mov    r12,QWORD PTR [rsp+0x8]
    30ad:	mov    r13,QWORD PTR [rsp+0x10]
    30b2:	mov    r14,QWORD PTR [rsp+0x18]
    30b7:	add    rsp,0x20
    30bb:	mov    rsp,rbp
    30be:	pop    rbp
    30bf:	ret
    30c0:	mov    r12,rdi
    30c3:	mov    r8,QWORD PTR [rip+0x0]        # 30ca <botlish_fn_25+0x2ea>
			30c6: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    30ca:	call   r8
    30cd:	xor    rax,rax
    30d0:	mov    rbx,QWORD PTR [rsp]
    30d4:	mov    r12,QWORD PTR [rsp+0x8]
    30d9:	mov    r13,QWORD PTR [rsp+0x10]
    30de:	mov    r14,QWORD PTR [rsp+0x18]
    30e3:	add    rsp,0x20
    30e7:	mov    rsp,rbp
    30ea:	pop    rbp
    30eb:	ret
    30ec:	add    BYTE PTR [rax],al
    30ee:	add    BYTE PTR [rax],al
    30f0:	(bad)
    30f1:	add    BYTE PTR [rax],al
    30f3:	add    BYTE PTR [rax],al
    30f5:	add    BYTE PTR [rax],al
    30f7:	add    BYTE PTR [rax+rax*1],al
    30fa:	add    BYTE PTR [rax],al
    30fc:	add    BYTE PTR [rax],al
	...

0000000000003100 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    3100:	push   rbp
    3101:	mov    rbp,rsp
    3104:	mov    rsi,QWORD PTR [rdx]
    3107:	call   310c <botlish_entry_25+0xc>
			3108: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    310c:	mov    rsp,rbp
    310f:	pop    rbp
    3110:	ret
    3111:	add    BYTE PTR [rax],al
    3113:	add    BYTE PTR [rax],al
    3115:	add    BYTE PTR [rax],al
	...

0000000000003118 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    3118:	push   rbp
    3119:	mov    rbp,rsp
    311c:	sub    rsp,0x50
    3120:	mov    QWORD PTR [rsp+0x20],rbx
    3125:	mov    QWORD PTR [rsp+0x28],r12
    312a:	mov    QWORD PTR [rsp+0x30],r13
    312f:	mov    QWORD PTR [rsp+0x38],r14
    3134:	mov    QWORD PTR [rsp+0x40],r15
    3139:	mov    r12,QWORD PTR [rdi]
    313c:	mov    rax,QWORD PTR [rdi+0x8]
    3140:	lea    r9,[r12+0x30]
    3145:	cmp    r9,rax
    3148:	ja     3688 <botlish_fn_26+0x570>
    314e:	lea    rax,[r12+0x30]
    3153:	mov    QWORD PTR [rdi],rax
    3156:	mov    r13,rdi
    3159:	mov    QWORD PTR [r12],0x0
    3161:	mov    QWORD PTR [r12+0x8],0x0
    316a:	mov    QWORD PTR [r12+0x10],0x0
    3173:	mov    QWORD PTR [r12+0x18],0x0
    317c:	mov    QWORD PTR [r12+0x20],0x0
    3185:	mov    QWORD PTR [r12+0x28],0x0
    318e:	mov    QWORD PTR [r12],rsi
    3192:	mov    r14,rsi
    3195:	mov    QWORD PTR [r12+0x8],rdx
    319a:	mov    QWORD PTR [rsp],rdx
    319e:	mov    QWORD PTR [r12+0x10],rcx
    31a3:	mov    QWORD PTR [rsp+0x8],rcx
    31a8:	mov    QWORD PTR [r12+0x18],r8
    31ad:	mov    r15,r8
    31b0:	mov    rsi,r14
    31b3:	mov    rdi,r13
    31b6:	call   31bb <botlish_fn_26+0xa3>
			31b7: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    31bb:	test   rax,rax
    31be:	jne    31cc <botlish_fn_26+0xb4>
    31c4:	mov    rdi,r13
    31c7:	jmp    362d <botlish_fn_26+0x515>
    31cc:	mov    QWORD PTR [r12+0x20],rax
    31d1:	xor    ecx,ecx
    31d3:	test   rax,0x7
    31d9:	je     31e9 <botlish_fn_26+0xd1>
    31df:	mov    QWORD PTR [rsp+0x10],rax
    31e4:	jmp    31f9 <botlish_fn_26+0xe1>
    31e9:	movzx  rsi,BYTE PTR [rax]
    31ed:	mov    QWORD PTR [rsp+0x10],rax
    31f2:	cmp    sil,0x8
    31f6:	sete   cl
    31f9:	test   cl,cl
    31fb:	jne    3228 <botlish_fn_26+0x110>
    3201:	mov    rdi,r13
    3204:	mov    r9,QWORD PTR [rdi+0x10]
    3208:	mov    rcx,QWORD PTR [r9+0x8]
    320c:	mov    edx,0x8
    3211:	mov    r9,QWORD PTR [rip+0x0]        # 3218 <botlish_fn_26+0x100>
			3214: R_X86_64_GOTPCREL	rt_type_error-0x4
    3218:	mov    rsi,QWORD PTR [rsp+0x10]
    321d:	call   r9
    3220:	mov    rdi,r13
    3223:	jmp    362d <botlish_fn_26+0x515>
    3228:	mov    r10,QWORD PTR [rip+0x0]        # 322f <botlish_fn_26+0x117>
			322b: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    322f:	mov    rdx,QWORD PTR [rsp]
    3233:	mov    rsi,QWORD PTR [rsp+0x10]
    3238:	mov    rdi,r13
    323b:	call   r10
    323e:	mov    rbx,rax
    3241:	test   rbx,rbx
    3244:	jne    3252 <botlish_fn_26+0x13a>
    324a:	mov    rdi,r13
    324d:	jmp    362d <botlish_fn_26+0x515>
    3252:	mov    QWORD PTR [r12+0x28],rbx
    3257:	mov    rdi,r13
    325a:	call   325f <botlish_fn_26+0x147>
			325b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    325f:	test   rax,rax
    3262:	mov    rcx,rax
    3265:	jne    3273 <botlish_fn_26+0x15b>
    326b:	mov    rdi,r13
    326e:	jmp    362d <botlish_fn_26+0x515>
    3273:	mov    rax,QWORD PTR [rip+0x0]        # 327a <botlish_fn_26+0x162>
			3276: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    327a:	mov    rsi,QWORD PTR [rsp+0x10]
    327f:	mov    rdx,QWORD PTR [rsp]
    3283:	mov    rdi,r13
    3286:	call   rax
    3288:	test   rax,rax
    328b:	jne    3299 <botlish_fn_26+0x181>
    3291:	mov    rdi,r13
    3294:	jmp    362d <botlish_fn_26+0x515>
    3299:	mov    rsi,r14
    329c:	mov    rdi,r13
    329f:	call   32a4 <botlish_fn_26+0x18c>
			32a0: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    32a4:	test   rax,rax
    32a7:	jne    32b5 <botlish_fn_26+0x19d>
    32ad:	mov    rdi,r13
    32b0:	jmp    362d <botlish_fn_26+0x515>
    32b5:	xor    esi,esi
    32b7:	test   rax,0x7
    32bd:	je     32cb <botlish_fn_26+0x1b3>
    32c3:	mov    r8,rax
    32c6:	jmp    32da <botlish_fn_26+0x1c2>
    32cb:	movzx  rcx,BYTE PTR [rax]
    32cf:	mov    r8,rax
    32d2:	rex cmp cl,0x8
    32d6:	sete   sil
    32da:	test   sil,sil
    32dd:	jne    3307 <botlish_fn_26+0x1ef>
    32e3:	mov    rdi,r13
    32e6:	mov    rax,QWORD PTR [rdi+0x10]
    32ea:	mov    rcx,QWORD PTR [rax+0x20]
    32ee:	mov    edx,0x8
    32f3:	mov    rax,QWORD PTR [rip+0x0]        # 32fa <botlish_fn_26+0x1e2>
			32f6: R_X86_64_GOTPCREL	rt_type_error-0x4
    32fa:	mov    rsi,r8
    32fd:	call   rax
    32ff:	mov    rdi,r13
    3302:	jmp    362d <botlish_fn_26+0x515>
    3307:	mov    rsi,r8
    330a:	mov    rax,QWORD PTR [rip+0x0]        # 3311 <botlish_fn_26+0x1f9>
			330d: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3311:	mov    rcx,QWORD PTR [rsp+0x8]
    3316:	mov    rdx,QWORD PTR [rsp]
    331a:	mov    rdi,r13
    331d:	call   rax
    331f:	test   rax,rax
    3322:	jne    3330 <botlish_fn_26+0x218>
    3328:	mov    rdi,r13
    332b:	jmp    362d <botlish_fn_26+0x515>
    3330:	mov    rsi,r14
    3333:	mov    rdi,r13
    3336:	call   333b <botlish_fn_26+0x223>
			3337: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    333b:	test   rax,rax
    333e:	jne    334c <botlish_fn_26+0x234>
    3344:	mov    rdi,r13
    3347:	jmp    362d <botlish_fn_26+0x515>
    334c:	xor    ecx,ecx
    334e:	test   rax,0x7
    3354:	je     3362 <botlish_fn_26+0x24a>
    335a:	mov    rsi,rax
    335d:	jmp    3370 <botlish_fn_26+0x258>
    3362:	movzx  rcx,BYTE PTR [rax]
    3366:	mov    rsi,rax
    3369:	rex cmp cl,0x8
    336d:	sete   cl
    3370:	test   cl,cl
    3372:	jne    3399 <botlish_fn_26+0x281>
    3378:	mov    rdi,r13
    337b:	mov    rax,QWORD PTR [rdi+0x10]
    337f:	mov    rcx,QWORD PTR [rax+0x20]
    3383:	mov    edx,0x8
    3388:	mov    rax,QWORD PTR [rip+0x0]        # 338f <botlish_fn_26+0x277>
			338b: R_X86_64_GOTPCREL	rt_type_error-0x4
    338f:	call   rax
    3391:	mov    rdi,r13
    3394:	jmp    362d <botlish_fn_26+0x515>
    3399:	mov    rax,QWORD PTR [rip+0x0]        # 33a0 <botlish_fn_26+0x288>
			339c: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    33a0:	mov    rcx,r15
    33a3:	mov    rdx,QWORD PTR [rsp]
    33a7:	mov    rdi,r13
    33aa:	call   rax
    33ac:	test   rax,rax
    33af:	jne    33bd <botlish_fn_26+0x2a5>
    33b5:	mov    rdi,r13
    33b8:	jmp    362d <botlish_fn_26+0x515>
    33bd:	mov    QWORD PTR [r12+0x8],0x7
    33c6:	mov    rsi,r14
    33c9:	mov    rdi,r13
    33cc:	call   33d1 <botlish_fn_26+0x2b9>
			33cd: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    33d1:	test   rax,rax
    33d4:	jne    33e2 <botlish_fn_26+0x2ca>
    33da:	mov    rdi,r13
    33dd:	jmp    362d <botlish_fn_26+0x515>
    33e2:	mov    QWORD PTR [r12+0x10],rax
    33e7:	mov    QWORD PTR [r12+0x18],0x3
    33f0:	mov    ecx,0x1
    33f5:	test   rax,0x1
    33fb:	je     3409 <botlish_fn_26+0x2f1>
    3401:	mov    rsi,rax
    3404:	jmp    342d <botlish_fn_26+0x315>
    3409:	xor    ecx,ecx
    340b:	test   rax,0x7
    3411:	je     341f <botlish_fn_26+0x307>
    3417:	mov    rsi,rax
    341a:	jmp    342d <botlish_fn_26+0x315>
    341f:	movzx  rcx,BYTE PTR [rax]
    3423:	mov    rsi,rax
    3426:	rex cmp cl,0x1
    342a:	sete   cl
    342d:	test   cl,cl
    342f:	jne    3455 <botlish_fn_26+0x33d>
    3435:	mov    rdi,r13
    3438:	mov    rcx,QWORD PTR [rdi+0x10]
    343c:	mov    rcx,QWORD PTR [rcx+0x10]
    3440:	xor    rdx,rdx
    3443:	mov    r8,QWORD PTR [rip+0x0]        # 344a <botlish_fn_26+0x332>
			3446: R_X86_64_GOTPCREL	rt_type_error-0x4
    344a:	call   r8
    344d:	mov    rdi,r13
    3450:	jmp    362d <botlish_fn_26+0x515>
    3455:	test   rsi,0x1
    345c:	je     3476 <botlish_fn_26+0x35e>
    3462:	mov    rcx,rsi
    3465:	add    rcx,0x2
    3469:	seto   dil
    346d:	test   dil,dil
    3470:	je     348b <botlish_fn_26+0x373>
    3476:	mov    edx,0x3
    347b:	mov    r9,QWORD PTR [rip+0x0]        # 3482 <botlish_fn_26+0x36a>
			347e: R_X86_64_GOTPCREL	rt_int_add-0x4
    3482:	mov    rdi,r13
    3485:	call   r9
    3488:	mov    rcx,rax
    348b:	mov    edx,0x7
    3490:	mov    r10,QWORD PTR [rip+0x0]        # 3497 <botlish_fn_26+0x37f>
			3493: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3497:	mov    rsi,r14
    349a:	mov    rdi,r13
    349d:	call   r10
    34a0:	test   rax,rax
    34a3:	jne    34b1 <botlish_fn_26+0x399>
    34a9:	mov    rdi,r13
    34ac:	jmp    362d <botlish_fn_26+0x515>
    34b1:	mov    rdi,r13
    34b4:	call   34b9 <botlish_fn_26+0x3a1>
			34b5: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    34b9:	test   rax,rax
    34bc:	jne    34ca <botlish_fn_26+0x3b2>
    34c2:	mov    rdi,r13
    34c5:	jmp    362d <botlish_fn_26+0x515>
    34ca:	mov    rcx,rbx
    34cd:	and    rcx,rax
    34d0:	mov    rdx,rbx
    34d3:	mov    rsi,rax
    34d6:	test   rcx,0x1
    34dd:	jne    3509 <botlish_fn_26+0x3f1>
    34e3:	mov    rax,QWORD PTR [rip+0x0]        # 34ea <botlish_fn_26+0x3d2>
			34e6: R_X86_64_GOTPCREL	rt_value_eq-0x4
    34ea:	mov    rcx,rdx
    34ed:	mov    rdx,rsi
    34f0:	mov    rsi,rcx
    34f3:	mov    rdi,r13
    34f6:	call   rax
    34f8:	test   rax,rax
    34fb:	jne    3522 <botlish_fn_26+0x40a>
    3501:	mov    rdi,r13
    3504:	jmp    362d <botlish_fn_26+0x515>
    3509:	mov    rax,rdx
    350c:	mov    rdx,rsi
    350f:	mov    rsi,rax
    3512:	mov    eax,0x2
    3517:	cmp    rsi,rdx
    351a:	cmove  rax,QWORD PTR [rip+0x19e]        # 36c0 <botlish_fn_26+0x5a8>
    3522:	cmp    rax,0x6
    3526:	je     3534 <botlish_fn_26+0x41c>
    352c:	mov    rdi,r13
    352f:	jmp    365b <botlish_fn_26+0x543>
    3534:	mov    QWORD PTR [r12+0x8],0x9
    353d:	mov    rsi,r14
    3540:	mov    rdi,r13
    3543:	call   3548 <botlish_fn_26+0x430>
			3544: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3548:	test   rax,rax
    354b:	jne    3559 <botlish_fn_26+0x441>
    3551:	mov    rdi,r13
    3554:	jmp    362d <botlish_fn_26+0x515>
    3559:	mov    QWORD PTR [r12+0x10],rax
    355e:	mov    QWORD PTR [r12+0x18],0x3
    3567:	mov    esi,0x1
    356c:	test   rax,0x1
    3572:	je     3580 <botlish_fn_26+0x468>
    3578:	mov    r11,rax
    357b:	jmp    35a5 <botlish_fn_26+0x48d>
    3580:	xor    esi,esi
    3582:	test   rax,0x7
    3588:	je     3596 <botlish_fn_26+0x47e>
    358e:	mov    r11,rax
    3591:	jmp    35a5 <botlish_fn_26+0x48d>
    3596:	movzx  rcx,BYTE PTR [rax]
    359a:	mov    r11,rax
    359d:	rex cmp cl,0x1
    35a1:	sete   sil
    35a5:	test   sil,sil
    35a8:	jne    35d0 <botlish_fn_26+0x4b8>
    35ae:	mov    rdi,r13
    35b1:	mov    rax,QWORD PTR [rdi+0x10]
    35b5:	mov    rcx,QWORD PTR [rax+0x28]
    35b9:	xor    rdx,rdx
    35bc:	mov    rax,QWORD PTR [rip+0x0]        # 35c3 <botlish_fn_26+0x4ab>
			35bf: R_X86_64_GOTPCREL	rt_type_error-0x4
    35c3:	mov    rsi,r11
    35c6:	call   rax
    35c8:	mov    rdi,r13
    35cb:	jmp    362d <botlish_fn_26+0x515>
    35d0:	mov    rsi,r11
    35d3:	test   rsi,0x1
    35da:	je     35f9 <botlish_fn_26+0x4e1>
    35e0:	mov    rcx,rsi
    35e3:	sub    rcx,0x3
    35e7:	seto   al
    35ea:	add    rcx,0x1
    35f1:	test   al,al
    35f3:	je     360d <botlish_fn_26+0x4f5>
    35f9:	mov    edx,0x3
    35fe:	mov    rax,QWORD PTR [rip+0x0]        # 3605 <botlish_fn_26+0x4ed>
			3601: R_X86_64_GOTPCREL	rt_int_sub-0x4
    3605:	mov    rdi,r13
    3608:	call   rax
    360a:	mov    rcx,rax
    360d:	mov    edx,0x9
    3612:	mov    rax,QWORD PTR [rip+0x0]        # 3619 <botlish_fn_26+0x501>
			3615: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3619:	mov    rsi,r14
    361c:	mov    rdi,r13
    361f:	call   rax
    3621:	test   rax,rax
    3624:	jne    3658 <botlish_fn_26+0x540>
    362a:	mov    rdi,r13
    362d:	mov    rdi,r13
    3630:	mov    QWORD PTR [rdi],r12
    3633:	xor    rax,rax
    3636:	mov    rbx,QWORD PTR [rsp+0x20]
    363b:	mov    r12,QWORD PTR [rsp+0x28]
    3640:	mov    r13,QWORD PTR [rsp+0x30]
    3645:	mov    r14,QWORD PTR [rsp+0x38]
    364a:	mov    r15,QWORD PTR [rsp+0x40]
    364f:	add    rsp,0x50
    3653:	mov    rsp,rbp
    3656:	pop    rbp
    3657:	ret
    3658:	mov    rdi,r13
    365b:	mov    rdi,r13
    365e:	mov    QWORD PTR [rdi],r12
    3661:	mov    eax,0xa
    3666:	mov    rbx,QWORD PTR [rsp+0x20]
    366b:	mov    r12,QWORD PTR [rsp+0x28]
    3670:	mov    r13,QWORD PTR [rsp+0x30]
    3675:	mov    r14,QWORD PTR [rsp+0x38]
    367a:	mov    r15,QWORD PTR [rsp+0x40]
    367f:	add    rsp,0x50
    3683:	mov    rsp,rbp
    3686:	pop    rbp
    3687:	ret
    3688:	mov    r13,rdi
    368b:	mov    rax,QWORD PTR [rip+0x0]        # 3692 <botlish_fn_26+0x57a>
			368e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3692:	call   rax
    3694:	xor    rax,rax
    3697:	mov    rbx,QWORD PTR [rsp+0x20]
    369c:	mov    r12,QWORD PTR [rsp+0x28]
    36a1:	mov    r13,QWORD PTR [rsp+0x30]
    36a6:	mov    r14,QWORD PTR [rsp+0x38]
    36ab:	mov    r15,QWORD PTR [rsp+0x40]
    36b0:	add    rsp,0x50
    36b4:	mov    rsp,rbp
    36b7:	pop    rbp
    36b8:	ret
    36b9:	add    BYTE PTR [rax],al
    36bb:	add    BYTE PTR [rax],al
    36bd:	add    BYTE PTR [rax],al
    36bf:	add    BYTE PTR [rsi],al
    36c1:	add    BYTE PTR [rax],al
    36c3:	add    BYTE PTR [rax],al
    36c5:	add    BYTE PTR [rax],al
	...

00000000000036c8 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    36c8:	push   rbp
    36c9:	mov    rbp,rsp
    36cc:	mov    rsi,QWORD PTR [rdx]
    36cf:	mov    r9,QWORD PTR [rdx+0x8]
    36d3:	mov    rcx,QWORD PTR [rdx+0x10]
    36d7:	mov    r8,QWORD PTR [rdx+0x18]
    36db:	mov    rdx,r9
    36de:	call   36e3 <botlish_entry_26+0x1b>
			36df: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    36e3:	mov    rsp,rbp
    36e6:	pop    rbp
    36e7:	ret

00000000000036e8 <botlish_fn_27: ht_set<mutarray, str, str>>:
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
    3710:	lea    r8,[rbx+0x28]
    3714:	cmp    r8,rax
    3717:	ja     3aec <botlish_fn_27+0x404>
    371d:	lea    rax,[rbx+0x28]
    3721:	mov    QWORD PTR [rdi],rax
    3724:	mov    r12,rdi
    3727:	mov    QWORD PTR [rbx],0x0
    372e:	mov    QWORD PTR [rbx+0x8],0x0
    3736:	mov    QWORD PTR [rbx+0x10],0x0
    373e:	mov    QWORD PTR [rbx+0x18],0x0
    3746:	mov    QWORD PTR [rbx+0x20],0x0
    374e:	mov    QWORD PTR [rbx],rsi
    3751:	mov    r15,rsi
    3754:	mov    QWORD PTR [rbx+0x8],rdx
    3758:	mov    r14,rdx
    375b:	mov    QWORD PTR [rbx+0x10],rcx
    375f:	mov    r13,rcx
    3762:	mov    rdx,r14
    3765:	mov    rsi,r15
    3768:	mov    rdi,r12
    376b:	call   3770 <botlish_fn_27+0x88>
			376c: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3770:	test   rax,rax
    3773:	jne    3781 <botlish_fn_27+0x99>
    3779:	mov    rdi,r12
    377c:	jmp    3a94 <botlish_fn_27+0x3ac>
    3781:	mov    QWORD PTR [rbx+0x18],rax
    3785:	mov    rcx,rax
    3788:	mov    r8,0xffffffffffffffff
    378f:	mov    QWORD PTR [rsp+0x10],r8
    3794:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    379c:	mov    rdx,r14
    379f:	mov    rsi,r15
    37a2:	mov    rdi,r12
    37a5:	call   37aa <botlish_fn_27+0xc2>
			37a6: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    37aa:	mov    rcx,rax
    37ad:	mov    QWORD PTR [rsp+0x8],rax
    37b2:	test   rax,rcx
    37b5:	jne    37c3 <botlish_fn_27+0xdb>
    37bb:	mov    rdi,r12
    37be:	jmp    3a94 <botlish_fn_27+0x3ac>
    37c3:	mov    rax,QWORD PTR [rsp+0x8]
    37c8:	mov    QWORD PTR [rbx+0x18],rax
    37cc:	mov    rsi,r15
    37cf:	mov    rdi,r12
    37d2:	call   37d7 <botlish_fn_27+0xef>
			37d3: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    37d7:	test   rax,rax
    37da:	jne    37e8 <botlish_fn_27+0x100>
    37e0:	mov    rdi,r12
    37e3:	jmp    3a94 <botlish_fn_27+0x3ac>
    37e8:	xor    ecx,ecx
    37ea:	test   rax,0x7
    37f0:	je     37fe <botlish_fn_27+0x116>
    37f6:	mov    rsi,rax
    37f9:	jmp    380c <botlish_fn_27+0x124>
    37fe:	movzx  rcx,BYTE PTR [rax]
    3802:	mov    rsi,rax
    3805:	rex cmp cl,0x8
    3809:	sete   cl
    380c:	test   cl,cl
    380e:	jne    3835 <botlish_fn_27+0x14d>
    3814:	mov    rdi,r12
    3817:	mov    rax,QWORD PTR [rdi+0x10]
    381b:	mov    rcx,QWORD PTR [rax+0x8]
    381f:	mov    edx,0x8
    3824:	mov    rax,QWORD PTR [rip+0x0]        # 382b <botlish_fn_27+0x143>
			3827: R_X86_64_GOTPCREL	rt_type_error-0x4
    382b:	call   rax
    382d:	mov    rdi,r12
    3830:	jmp    3a94 <botlish_fn_27+0x3ac>
    3835:	mov    rax,QWORD PTR [rip+0x0]        # 383c <botlish_fn_27+0x154>
			3838: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    383c:	mov    rdx,QWORD PTR [rsp+0x8]
    3841:	mov    rdi,r12
    3844:	call   rax
    3846:	test   rax,rax
    3849:	jne    3857 <botlish_fn_27+0x16f>
    384f:	mov    rdi,r12
    3852:	jmp    3a94 <botlish_fn_27+0x3ac>
    3857:	mov    QWORD PTR [rbx+0x20],rax
    385b:	mov    QWORD PTR [rsp],rax
    385f:	mov    rdi,r12
    3862:	call   3867 <botlish_fn_27+0x17f>
			3863: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    3867:	test   rax,rax
    386a:	jne    3878 <botlish_fn_27+0x190>
    3870:	mov    rdi,r12
    3873:	jmp    3a94 <botlish_fn_27+0x3ac>
    3878:	mov    rcx,QWORD PTR [rsp]
    387c:	mov    rdx,rcx
    387f:	and    rdx,rax
    3882:	mov    rcx,rax
    3885:	test   rdx,0x1
    388c:	jne    38b6 <botlish_fn_27+0x1ce>
    3892:	mov    rax,QWORD PTR [rip+0x0]        # 3899 <botlish_fn_27+0x1b1>
			3895: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3899:	mov    rdx,rcx
    389c:	mov    rsi,QWORD PTR [rsp]
    38a0:	mov    rdi,r12
    38a3:	call   rax
    38a5:	test   rax,rax
    38a8:	jne    38cd <botlish_fn_27+0x1e5>
    38ae:	mov    rdi,r12
    38b1:	jmp    3a94 <botlish_fn_27+0x3ac>
    38b6:	mov    rdx,rcx
    38b9:	mov    rsi,QWORD PTR [rsp]
    38bd:	mov    eax,0x2
    38c2:	cmp    rsi,rdx
    38c5:	cmove  rax,QWORD PTR [rip+0x253]        # 3b20 <botlish_fn_27+0x438>
    38cd:	cmp    rax,0x6
    38d1:	je     3a0b <botlish_fn_27+0x323>
    38d7:	mov    rsi,r15
    38da:	mov    rdi,r12
    38dd:	call   38e2 <botlish_fn_27+0x1fa>
			38de: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    38e2:	test   rax,rax
    38e5:	jne    38f3 <botlish_fn_27+0x20b>
    38eb:	mov    rdi,r12
    38ee:	jmp    3a94 <botlish_fn_27+0x3ac>
    38f3:	cmp    rax,0x6
    38f7:	je     394c <botlish_fn_27+0x264>
    38fd:	mov    rcx,r14
    3900:	mov    rdx,QWORD PTR [rsp+0x8]
    3905:	mov    rsi,r15
    3908:	mov    r8,r13
    390b:	mov    rdi,r12
    390e:	call   3913 <botlish_fn_27+0x22b>
			390f: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    3913:	test   rax,rax
    3916:	jne    3924 <botlish_fn_27+0x23c>
    391c:	mov    rdi,r12
    391f:	jmp    3a94 <botlish_fn_27+0x3ac>
    3924:	mov    rdi,r12
    3927:	mov    QWORD PTR [rdi],rbx
    392a:	mov    rbx,QWORD PTR [rsp+0x20]
    392f:	mov    r12,QWORD PTR [rsp+0x28]
    3934:	mov    r13,QWORD PTR [rsp+0x30]
    3939:	mov    r14,QWORD PTR [rsp+0x38]
    393e:	mov    r15,QWORD PTR [rsp+0x40]
    3943:	add    rsp,0x50
    3947:	mov    rsp,rbp
    394a:	pop    rbp
    394b:	ret
    394c:	mov    rsi,r15
    394f:	mov    rdi,r12
    3952:	call   3957 <botlish_fn_27+0x26f>
			3953: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    3957:	test   rax,rax
    395a:	jne    3968 <botlish_fn_27+0x280>
    3960:	mov    rdi,r12
    3963:	jmp    3a94 <botlish_fn_27+0x3ac>
    3968:	mov    rdx,r14
    396b:	mov    rsi,r15
    396e:	mov    rdi,r12
    3971:	call   3976 <botlish_fn_27+0x28e>
			3972: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3976:	test   rax,rax
    3979:	jne    3987 <botlish_fn_27+0x29f>
    397f:	mov    rdi,r12
    3982:	jmp    3a94 <botlish_fn_27+0x3ac>
    3987:	mov    QWORD PTR [rbx+0x18],rax
    398b:	mov    rcx,rax
    398e:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    3996:	mov    r8,QWORD PTR [rsp+0x10]
    399b:	mov    rdx,r14
    399e:	mov    rsi,r15
    39a1:	mov    rdi,r12
    39a4:	call   39a9 <botlish_fn_27+0x2c1>
			39a5: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    39a9:	test   rax,rax
    39ac:	jne    39ba <botlish_fn_27+0x2d2>
    39b2:	mov    rdi,r12
    39b5:	jmp    3a94 <botlish_fn_27+0x3ac>
    39ba:	mov    QWORD PTR [rbx+0x18],rax
    39be:	mov    rcx,r14
    39c1:	mov    rdx,rax
    39c4:	mov    rsi,r15
    39c7:	mov    r8,r13
    39ca:	mov    rdi,r12
    39cd:	call   39d2 <botlish_fn_27+0x2ea>
			39ce: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    39d2:	test   rax,rax
    39d5:	jne    39e3 <botlish_fn_27+0x2fb>
    39db:	mov    rdi,r12
    39de:	jmp    3a94 <botlish_fn_27+0x3ac>
    39e3:	mov    rdi,r12
    39e6:	mov    QWORD PTR [rdi],rbx
    39e9:	mov    rbx,QWORD PTR [rsp+0x20]
    39ee:	mov    r12,QWORD PTR [rsp+0x28]
    39f3:	mov    r13,QWORD PTR [rsp+0x30]
    39f8:	mov    r14,QWORD PTR [rsp+0x38]
    39fd:	mov    r15,QWORD PTR [rsp+0x40]
    3a02:	add    rsp,0x50
    3a06:	mov    rsp,rbp
    3a09:	pop    rbp
    3a0a:	ret
    3a0b:	mov    rsi,r15
    3a0e:	mov    rdi,r12
    3a11:	call   3a16 <botlish_fn_27+0x32e>
			3a12: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3a16:	test   rax,rax
    3a19:	jne    3a27 <botlish_fn_27+0x33f>
    3a1f:	mov    rdi,r12
    3a22:	jmp    3a94 <botlish_fn_27+0x3ac>
    3a27:	xor    ecx,ecx
    3a29:	test   rax,0x7
    3a2f:	je     3a3d <botlish_fn_27+0x355>
    3a35:	mov    rsi,rax
    3a38:	jmp    3a4b <botlish_fn_27+0x363>
    3a3d:	movzx  rcx,BYTE PTR [rax]
    3a41:	mov    rsi,rax
    3a44:	rex cmp cl,0x8
    3a48:	sete   cl
    3a4b:	test   cl,cl
    3a4d:	jne    3a74 <botlish_fn_27+0x38c>
    3a53:	mov    rdi,r12
    3a56:	mov    rax,QWORD PTR [rdi+0x10]
    3a5a:	mov    rcx,QWORD PTR [rax+0x20]
    3a5e:	mov    edx,0x8
    3a63:	mov    rax,QWORD PTR [rip+0x0]        # 3a6a <botlish_fn_27+0x382>
			3a66: R_X86_64_GOTPCREL	rt_type_error-0x4
    3a6a:	call   rax
    3a6c:	mov    rdi,r12
    3a6f:	jmp    3a94 <botlish_fn_27+0x3ac>
    3a74:	mov    rax,QWORD PTR [rip+0x0]        # 3a7b <botlish_fn_27+0x393>
			3a77: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3a7b:	mov    rcx,r13
    3a7e:	mov    rdx,QWORD PTR [rsp+0x8]
    3a83:	mov    rdi,r12
    3a86:	call   rax
    3a88:	test   rax,rax
    3a8b:	jne    3abf <botlish_fn_27+0x3d7>
    3a91:	mov    rdi,r12
    3a94:	mov    rdi,r12
    3a97:	mov    QWORD PTR [rdi],rbx
    3a9a:	xor    rax,rax
    3a9d:	mov    rbx,QWORD PTR [rsp+0x20]
    3aa2:	mov    r12,QWORD PTR [rsp+0x28]
    3aa7:	mov    r13,QWORD PTR [rsp+0x30]
    3aac:	mov    r14,QWORD PTR [rsp+0x38]
    3ab1:	mov    r15,QWORD PTR [rsp+0x40]
    3ab6:	add    rsp,0x50
    3aba:	mov    rsp,rbp
    3abd:	pop    rbp
    3abe:	ret
    3abf:	mov    rdi,r12
    3ac2:	mov    QWORD PTR [rdi],rbx
    3ac5:	mov    eax,0xa
    3aca:	mov    rbx,QWORD PTR [rsp+0x20]
    3acf:	mov    r12,QWORD PTR [rsp+0x28]
    3ad4:	mov    r13,QWORD PTR [rsp+0x30]
    3ad9:	mov    r14,QWORD PTR [rsp+0x38]
    3ade:	mov    r15,QWORD PTR [rsp+0x40]
    3ae3:	add    rsp,0x50
    3ae7:	mov    rsp,rbp
    3aea:	pop    rbp
    3aeb:	ret
    3aec:	mov    r12,rdi
    3aef:	mov    rax,QWORD PTR [rip+0x0]        # 3af6 <botlish_fn_27+0x40e>
			3af2: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3af6:	call   rax
    3af8:	xor    rax,rax
    3afb:	mov    rbx,QWORD PTR [rsp+0x20]
    3b00:	mov    r12,QWORD PTR [rsp+0x28]
    3b05:	mov    r13,QWORD PTR [rsp+0x30]
    3b0a:	mov    r14,QWORD PTR [rsp+0x38]
    3b0f:	mov    r15,QWORD PTR [rsp+0x40]
    3b14:	add    rsp,0x50
    3b18:	mov    rsp,rbp
    3b1b:	pop    rbp
    3b1c:	ret
    3b1d:	add    BYTE PTR [rax],al
    3b1f:	add    BYTE PTR [rsi],al
    3b21:	add    BYTE PTR [rax],al
    3b23:	add    BYTE PTR [rax],al
    3b25:	add    BYTE PTR [rax],al
	...

0000000000003b28 <botlish_entry_27: ht_set<mutarray, str, str>>:
    3b28:	push   rbp
    3b29:	mov    rbp,rsp
    3b2c:	mov    rsi,QWORD PTR [rdx]
    3b2f:	mov    r8,QWORD PTR [rdx+0x8]
    3b33:	mov    rcx,QWORD PTR [rdx+0x10]
    3b37:	mov    rdx,r8
    3b3a:	call   3b3f <botlish_entry_27+0x17>
			3b3b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3b3f:	mov    rsp,rbp
    3b42:	pop    rbp
    3b43:	ret
    3b44:	add    BYTE PTR [rax],al
	...

0000000000003b48 <botlish_fn_28: ht_delete<mutarray, str>>:
    3b48:	push   rbp
    3b49:	mov    rbp,rsp
    3b4c:	sub    rsp,0x30
    3b50:	mov    QWORD PTR [rsp],rbx
    3b54:	mov    QWORD PTR [rsp+0x8],r12
    3b59:	mov    QWORD PTR [rsp+0x10],r13
    3b5e:	mov    QWORD PTR [rsp+0x18],r14
    3b63:	mov    QWORD PTR [rsp+0x20],r15
    3b68:	mov    rbx,QWORD PTR [rdi]
    3b6b:	mov    rax,QWORD PTR [rdi+0x8]
    3b6f:	lea    rcx,[rbx+0x20]
    3b73:	cmp    rcx,rax
    3b76:	ja     408a <botlish_fn_28+0x542>
    3b7c:	lea    rax,[rbx+0x20]
    3b80:	mov    QWORD PTR [rdi],rax
    3b83:	mov    r12,rdi
    3b86:	mov    QWORD PTR [rbx],0x0
    3b8d:	mov    QWORD PTR [rbx+0x8],0x0
    3b95:	mov    QWORD PTR [rbx+0x10],0x0
    3b9d:	mov    QWORD PTR [rbx+0x18],0x0
    3ba5:	mov    QWORD PTR [rbx],rsi
    3ba8:	mov    r13,rsi
    3bab:	mov    QWORD PTR [rbx+0x8],rdx
    3baf:	mov    r15,rdx
    3bb2:	mov    rdx,r15
    3bb5:	mov    rsi,r13
    3bb8:	mov    rdi,r12
    3bbb:	call   3bc0 <botlish_fn_28+0x78>
			3bbc: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3bc0:	test   rax,rax
    3bc3:	jne    3bd1 <botlish_fn_28+0x89>
    3bc9:	mov    rdi,r12
    3bcc:	jmp    4008 <botlish_fn_28+0x4c0>
    3bd1:	mov    QWORD PTR [rbx+0x10],rax
    3bd5:	mov    rcx,rax
    3bd8:	mov    rdx,r15
    3bdb:	mov    rsi,r13
    3bde:	mov    rdi,r12
    3be1:	call   3be6 <botlish_fn_28+0x9e>
			3be2: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    3be6:	mov    rcx,rax
    3be9:	mov    r14,rax
    3bec:	test   rax,rcx
    3bef:	jne    3bfd <botlish_fn_28+0xb5>
    3bf5:	mov    rdi,r12
    3bf8:	jmp    4008 <botlish_fn_28+0x4c0>
    3bfd:	mov    rax,r14
    3c00:	mov    QWORD PTR [rbx+0x8],rax
    3c04:	test   rax,0x1
    3c0a:	jne    3c3a <botlish_fn_28+0xf2>
    3c10:	mov    edx,0x1
    3c15:	mov    r8,QWORD PTR [rip+0x0]        # 3c1c <botlish_fn_28+0xd4>
			3c18: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    3c1c:	mov    rsi,r14
    3c1f:	mov    rdi,r12
    3c22:	call   r8
    3c25:	mov    ecx,0x2
    3c2a:	test   rax,rax
    3c2d:	cmovl  rcx,QWORD PTR [rip+0x48b]        # 40c0 <botlish_fn_28+0x578>
    3c35:	jmp    3c50 <botlish_fn_28+0x108>
    3c3a:	mov    ecx,0x2
    3c3f:	mov    rax,r14
    3c42:	mov    rdx,r14
    3c45:	test   rax,rdx
    3c48:	cmovle rcx,QWORD PTR [rip+0x470]        # 40c0 <botlish_fn_28+0x578>
    3c50:	cmp    rcx,0x6
    3c54:	je     405e <botlish_fn_28+0x516>
    3c5a:	mov    rsi,r13
    3c5d:	mov    rdi,r12
    3c60:	call   3c65 <botlish_fn_28+0x11d>
			3c61: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    3c65:	test   rax,rax
    3c68:	jne    3c76 <botlish_fn_28+0x12e>
    3c6e:	mov    rdi,r12
    3c71:	jmp    4008 <botlish_fn_28+0x4c0>
    3c76:	mov    QWORD PTR [rbx+0x10],rax
    3c7a:	mov    r15,rax
    3c7d:	mov    rdi,r12
    3c80:	call   3c85 <botlish_fn_28+0x13d>
			3c81: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    3c85:	test   rax,rax
    3c88:	mov    rdx,rax
    3c8b:	jne    3c99 <botlish_fn_28+0x151>
    3c91:	mov    rdi,r12
    3c94:	jmp    4008 <botlish_fn_28+0x4c0>
    3c99:	xor    ecx,ecx
    3c9b:	mov    rax,r15
    3c9e:	test   rax,0x7
    3ca4:	je     3cb2 <botlish_fn_28+0x16a>
    3caa:	mov    r15,rax
    3cad:	jmp    3cc0 <botlish_fn_28+0x178>
    3cb2:	movzx  rcx,BYTE PTR [rax]
    3cb6:	mov    r15,rax
    3cb9:	rex cmp cl,0x8
    3cbd:	sete   cl
    3cc0:	test   cl,cl
    3cc2:	jne    3cec <botlish_fn_28+0x1a4>
    3cc8:	mov    rdi,r12
    3ccb:	mov    rax,QWORD PTR [rdi+0x10]
    3ccf:	mov    rcx,QWORD PTR [rax+0x20]
    3cd3:	mov    edx,0x8
    3cd8:	mov    rax,QWORD PTR [rip+0x0]        # 3cdf <botlish_fn_28+0x197>
			3cdb: R_X86_64_GOTPCREL	rt_type_error-0x4
    3cdf:	mov    rsi,r15
    3ce2:	call   rax
    3ce4:	mov    rdi,r12
    3ce7:	jmp    4008 <botlish_fn_28+0x4c0>
    3cec:	mov    rsi,r15
    3cef:	mov    rax,QWORD PTR [rip+0x0]        # 3cf6 <botlish_fn_28+0x1ae>
			3cf2: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3cf6:	mov    rcx,rdx
    3cf9:	mov    rdx,r14
    3cfc:	mov    rdi,r12
    3cff:	call   rax
    3d01:	test   rax,rax
    3d04:	jne    3d12 <botlish_fn_28+0x1ca>
    3d0a:	mov    rdi,r12
    3d0d:	jmp    4008 <botlish_fn_28+0x4c0>
    3d12:	mov    rsi,r13
    3d15:	mov    rdi,r12
    3d18:	call   3d1d <botlish_fn_28+0x1d5>
			3d19: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    3d1d:	test   rax,rax
    3d20:	jne    3d2e <botlish_fn_28+0x1e6>
    3d26:	mov    rdi,r12
    3d29:	jmp    4008 <botlish_fn_28+0x4c0>
    3d2e:	xor    ecx,ecx
    3d30:	test   rax,0x7
    3d36:	je     3d44 <botlish_fn_28+0x1fc>
    3d3c:	mov    rsi,rax
    3d3f:	jmp    3d52 <botlish_fn_28+0x20a>
    3d44:	movzx  rcx,BYTE PTR [rax]
    3d48:	mov    rsi,rax
    3d4b:	rex cmp cl,0x8
    3d4f:	sete   cl
    3d52:	test   cl,cl
    3d54:	jne    3d7b <botlish_fn_28+0x233>
    3d5a:	mov    rdi,r12
    3d5d:	mov    rax,QWORD PTR [rdi+0x10]
    3d61:	mov    rcx,QWORD PTR [rax+0x20]
    3d65:	mov    edx,0x8
    3d6a:	mov    rax,QWORD PTR [rip+0x0]        # 3d71 <botlish_fn_28+0x229>
			3d6d: R_X86_64_GOTPCREL	rt_type_error-0x4
    3d71:	call   rax
    3d73:	mov    rdi,r12
    3d76:	jmp    4008 <botlish_fn_28+0x4c0>
    3d7b:	mov    ecx,0xa
    3d80:	mov    rax,QWORD PTR [rip+0x0]        # 3d87 <botlish_fn_28+0x23f>
			3d83: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3d87:	mov    rdx,r14
    3d8a:	mov    rdi,r12
    3d8d:	call   rax
    3d8f:	test   rax,rax
    3d92:	jne    3da0 <botlish_fn_28+0x258>
    3d98:	mov    rdi,r12
    3d9b:	jmp    4008 <botlish_fn_28+0x4c0>
    3da0:	mov    rsi,r13
    3da3:	mov    rdi,r12
    3da6:	call   3dab <botlish_fn_28+0x263>
			3da7: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3dab:	test   rax,rax
    3dae:	jne    3dbc <botlish_fn_28+0x274>
    3db4:	mov    rdi,r12
    3db7:	jmp    4008 <botlish_fn_28+0x4c0>
    3dbc:	xor    ecx,ecx
    3dbe:	test   rax,0x7
    3dc4:	je     3dd2 <botlish_fn_28+0x28a>
    3dca:	mov    rsi,rax
    3dcd:	jmp    3de0 <botlish_fn_28+0x298>
    3dd2:	movzx  rcx,BYTE PTR [rax]
    3dd6:	mov    rsi,rax
    3dd9:	rex cmp cl,0x8
    3ddd:	sete   cl
    3de0:	test   cl,cl
    3de2:	jne    3e09 <botlish_fn_28+0x2c1>
    3de8:	mov    rdi,r12
    3deb:	mov    rax,QWORD PTR [rdi+0x10]
    3def:	mov    rcx,QWORD PTR [rax+0x20]
    3df3:	mov    edx,0x8
    3df8:	mov    rax,QWORD PTR [rip+0x0]        # 3dff <botlish_fn_28+0x2b7>
			3dfb: R_X86_64_GOTPCREL	rt_type_error-0x4
    3dff:	call   rax
    3e01:	mov    rdi,r12
    3e04:	jmp    4008 <botlish_fn_28+0x4c0>
    3e09:	mov    ecx,0xa
    3e0e:	mov    rax,QWORD PTR [rip+0x0]        # 3e15 <botlish_fn_28+0x2cd>
			3e11: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3e15:	mov    rdx,r14
    3e18:	mov    rdi,r12
    3e1b:	call   rax
    3e1d:	test   rax,rax
    3e20:	jne    3e2e <botlish_fn_28+0x2e6>
    3e26:	mov    rdi,r12
    3e29:	jmp    4008 <botlish_fn_28+0x4c0>
    3e2e:	mov    QWORD PTR [rbx+0x8],0x7
    3e36:	mov    rsi,r13
    3e39:	mov    rdi,r12
    3e3c:	call   3e41 <botlish_fn_28+0x2f9>
			3e3d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3e41:	test   rax,rax
    3e44:	jne    3e52 <botlish_fn_28+0x30a>
    3e4a:	mov    rdi,r12
    3e4d:	jmp    4008 <botlish_fn_28+0x4c0>
    3e52:	mov    QWORD PTR [rbx+0x10],rax
    3e56:	mov    QWORD PTR [rbx+0x18],0x3
    3e5e:	mov    ecx,0x1
    3e63:	test   rax,0x1
    3e69:	je     3e77 <botlish_fn_28+0x32f>
    3e6f:	mov    rsi,rax
    3e72:	jmp    3e9b <botlish_fn_28+0x353>
    3e77:	xor    ecx,ecx
    3e79:	test   rax,0x7
    3e7f:	je     3e8d <botlish_fn_28+0x345>
    3e85:	mov    rsi,rax
    3e88:	jmp    3e9b <botlish_fn_28+0x353>
    3e8d:	movzx  r8,BYTE PTR [rax]
    3e91:	mov    rsi,rax
    3e94:	cmp    r8b,0x1
    3e98:	sete   cl
    3e9b:	test   cl,cl
    3e9d:	jne    3ec2 <botlish_fn_28+0x37a>
    3ea3:	mov    rdi,r12
    3ea6:	mov    rax,QWORD PTR [rdi+0x10]
    3eaa:	mov    rcx,QWORD PTR [rax+0x28]
    3eae:	xor    rdx,rdx
    3eb1:	mov    rax,QWORD PTR [rip+0x0]        # 3eb8 <botlish_fn_28+0x370>
			3eb4: R_X86_64_GOTPCREL	rt_type_error-0x4
    3eb8:	call   rax
    3eba:	mov    rdi,r12
    3ebd:	jmp    4008 <botlish_fn_28+0x4c0>
    3ec2:	test   rsi,0x1
    3ec9:	je     3ee8 <botlish_fn_28+0x3a0>
    3ecf:	mov    rcx,rsi
    3ed2:	sub    rcx,0x3
    3ed6:	seto   al
    3ed9:	add    rcx,0x1
    3ee0:	test   al,al
    3ee2:	je     3efc <botlish_fn_28+0x3b4>
    3ee8:	mov    edx,0x3
    3eed:	mov    rax,QWORD PTR [rip+0x0]        # 3ef4 <botlish_fn_28+0x3ac>
			3ef0: R_X86_64_GOTPCREL	rt_int_sub-0x4
    3ef4:	mov    rdi,r12
    3ef7:	call   rax
    3ef9:	mov    rcx,rax
    3efc:	mov    edx,0x7
    3f01:	mov    rax,QWORD PTR [rip+0x0]        # 3f08 <botlish_fn_28+0x3c0>
			3f04: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3f08:	mov    rsi,r13
    3f0b:	mov    rdi,r12
    3f0e:	call   rax
    3f10:	test   rax,rax
    3f13:	jne    3f21 <botlish_fn_28+0x3d9>
    3f19:	mov    rdi,r12
    3f1c:	jmp    4008 <botlish_fn_28+0x4c0>
    3f21:	mov    QWORD PTR [rbx+0x8],0x9
    3f29:	mov    rsi,r13
    3f2c:	mov    rdi,r12
    3f2f:	call   3f34 <botlish_fn_28+0x3ec>
			3f30: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3f34:	test   rax,rax
    3f37:	jne    3f45 <botlish_fn_28+0x3fd>
    3f3d:	mov    rdi,r12
    3f40:	jmp    4008 <botlish_fn_28+0x4c0>
    3f45:	mov    QWORD PTR [rbx+0x10],rax
    3f49:	mov    QWORD PTR [rbx+0x18],0x3
    3f51:	mov    edx,0x1
    3f56:	test   rax,0x1
    3f5c:	je     3f6a <botlish_fn_28+0x422>
    3f62:	mov    rsi,rax
    3f65:	jmp    3f8e <botlish_fn_28+0x446>
    3f6a:	xor    edx,edx
    3f6c:	test   rax,0x7
    3f72:	je     3f80 <botlish_fn_28+0x438>
    3f78:	mov    rsi,rax
    3f7b:	jmp    3f8e <botlish_fn_28+0x446>
    3f80:	movzx  rcx,BYTE PTR [rax]
    3f84:	mov    rsi,rax
    3f87:	rex cmp cl,0x1
    3f8b:	sete   dl
    3f8e:	test   dl,dl
    3f90:	jne    3fb5 <botlish_fn_28+0x46d>
    3f96:	mov    rdi,r12
    3f99:	mov    rax,QWORD PTR [rdi+0x10]
    3f9d:	mov    rcx,QWORD PTR [rax+0x10]
    3fa1:	xor    rdx,rdx
    3fa4:	mov    rax,QWORD PTR [rip+0x0]        # 3fab <botlish_fn_28+0x463>
			3fa7: R_X86_64_GOTPCREL	rt_type_error-0x4
    3fab:	call   rax
    3fad:	mov    rdi,r12
    3fb0:	jmp    4008 <botlish_fn_28+0x4c0>
    3fb5:	test   rsi,0x1
    3fbc:	je     3fd4 <botlish_fn_28+0x48c>
    3fc2:	mov    rcx,rsi
    3fc5:	add    rcx,0x2
    3fc9:	seto   al
    3fcc:	test   al,al
    3fce:	je     3fe8 <botlish_fn_28+0x4a0>
    3fd4:	mov    edx,0x3
    3fd9:	mov    rax,QWORD PTR [rip+0x0]        # 3fe0 <botlish_fn_28+0x498>
			3fdc: R_X86_64_GOTPCREL	rt_int_add-0x4
    3fe0:	mov    rdi,r12
    3fe3:	call   rax
    3fe5:	mov    rcx,rax
    3fe8:	mov    edx,0x9
    3fed:	mov    rax,QWORD PTR [rip+0x0]        # 3ff4 <botlish_fn_28+0x4ac>
			3ff0: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    3ff4:	mov    rsi,r13
    3ff7:	mov    rdi,r12
    3ffa:	call   rax
    3ffc:	test   rax,rax
    3fff:	jne    4032 <botlish_fn_28+0x4ea>
    4005:	mov    rdi,r12
    4008:	mov    rdi,r12
    400b:	mov    QWORD PTR [rdi],rbx
    400e:	xor    rax,rax
    4011:	mov    rbx,QWORD PTR [rsp]
    4015:	mov    r12,QWORD PTR [rsp+0x8]
    401a:	mov    r13,QWORD PTR [rsp+0x10]
    401f:	mov    r14,QWORD PTR [rsp+0x18]
    4024:	mov    r15,QWORD PTR [rsp+0x20]
    4029:	add    rsp,0x30
    402d:	mov    rsp,rbp
    4030:	pop    rbp
    4031:	ret
    4032:	mov    rdi,r12
    4035:	mov    QWORD PTR [rdi],rbx
    4038:	mov    eax,0xa
    403d:	mov    rbx,QWORD PTR [rsp]
    4041:	mov    r12,QWORD PTR [rsp+0x8]
    4046:	mov    r13,QWORD PTR [rsp+0x10]
    404b:	mov    r14,QWORD PTR [rsp+0x18]
    4050:	mov    r15,QWORD PTR [rsp+0x20]
    4055:	add    rsp,0x30
    4059:	mov    rsp,rbp
    405c:	pop    rbp
    405d:	ret
    405e:	mov    rdi,r12
    4061:	mov    QWORD PTR [rdi],rbx
    4064:	mov    eax,0xa
    4069:	mov    rbx,QWORD PTR [rsp]
    406d:	mov    r12,QWORD PTR [rsp+0x8]
    4072:	mov    r13,QWORD PTR [rsp+0x10]
    4077:	mov    r14,QWORD PTR [rsp+0x18]
    407c:	mov    r15,QWORD PTR [rsp+0x20]
    4081:	add    rsp,0x30
    4085:	mov    rsp,rbp
    4088:	pop    rbp
    4089:	ret
    408a:	mov    r12,rdi
    408d:	mov    rax,QWORD PTR [rip+0x0]        # 4094 <botlish_fn_28+0x54c>
			4090: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    4094:	call   rax
    4096:	xor    rax,rax
    4099:	mov    rbx,QWORD PTR [rsp]
    409d:	mov    r12,QWORD PTR [rsp+0x8]
    40a2:	mov    r13,QWORD PTR [rsp+0x10]
    40a7:	mov    r14,QWORD PTR [rsp+0x18]
    40ac:	mov    r15,QWORD PTR [rsp+0x20]
    40b1:	add    rsp,0x30
    40b5:	mov    rsp,rbp
    40b8:	pop    rbp
    40b9:	ret
    40ba:	add    BYTE PTR [rax],al
    40bc:	add    BYTE PTR [rax],al
    40be:	add    BYTE PTR [rax],al
    40c0:	(bad)
    40c1:	add    BYTE PTR [rax],al
    40c3:	add    BYTE PTR [rax],al
    40c5:	add    BYTE PTR [rax],al
	...

00000000000040c8 <botlish_entry_28: ht_delete<mutarray, str>>:
    40c8:	push   rbp
    40c9:	mov    rbp,rsp
    40cc:	mov    rsi,QWORD PTR [rdx]
    40cf:	mov    rdx,QWORD PTR [rdx+0x8]
    40d3:	call   40d8 <botlish_entry_28+0x10>
			40d4: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    40d8:	mov    rsp,rbp
    40db:	pop    rbp
    40dc:	ret
    40dd:	add    BYTE PTR [rax],al
	...

00000000000040e0 <botlish_fn_29: sample<generic>>:
    40e0:	push   rbp
    40e1:	mov    rbp,rsp
    40e4:	sub    rsp,0x70
    40e8:	mov    QWORD PTR [rsp+0x40],rbx
    40ed:	mov    QWORD PTR [rsp+0x48],r12
    40f2:	mov    QWORD PTR [rsp+0x50],r13
    40f7:	mov    QWORD PTR [rsp+0x58],r14
    40fc:	mov    QWORD PTR [rsp+0x60],r15
    4101:	mov    r12,QWORD PTR [rdi]
    4104:	mov    rax,QWORD PTR [rdi+0x8]
    4108:	lea    rcx,[r12+0x30]
    410d:	cmp    rcx,rax
    4110:	ja     44a9 <botlish_fn_29+0x3c9>
    4116:	lea    rcx,[r12+0x30]
    411b:	mov    QWORD PTR [rdi],rcx
    411e:	mov    QWORD PTR [rsp+0x30],rdi
    4123:	mov    QWORD PTR [r12],0x0
    412b:	mov    QWORD PTR [r12+0x8],0x0
    4134:	mov    QWORD PTR [r12+0x10],0x0
    413d:	mov    QWORD PTR [r12+0x18],0x0
    4146:	mov    QWORD PTR [r12+0x20],0x0
    414f:	mov    QWORD PTR [r12+0x28],0x0
    4158:	mov    rdi,QWORD PTR [rsp+0x30]
    415d:	call   4162 <botlish_fn_29+0x82>
			415e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    4162:	mov    rbx,rax
    4165:	test   rbx,rbx
    4168:	jne    4178 <botlish_fn_29+0x98>
    416e:	mov    rdi,QWORD PTR [rsp+0x30]
    4173:	jmp    4452 <botlish_fn_29+0x372>
    4178:	mov    QWORD PTR [r12],rbx
    417c:	mov    rdi,QWORD PTR [rsp+0x30]
    4181:	mov    rax,QWORD PTR [rdi+0x10]
    4185:	mov    rdx,QWORD PTR [rax+0x30]
    4189:	mov    QWORD PTR [r12+0x8],rdx
    418e:	mov    rax,QWORD PTR [rdi+0x10]
    4192:	mov    rcx,QWORD PTR [rax+0x38]
    4196:	mov    QWORD PTR [r12+0x10],rcx
    419b:	mov    rsi,rbx
    419e:	call   41a3 <botlish_fn_29+0xc3>
			419f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    41a3:	test   rax,rax
    41a6:	jne    41b6 <botlish_fn_29+0xd6>
    41ac:	mov    rdi,QWORD PTR [rsp+0x30]
    41b1:	jmp    4452 <botlish_fn_29+0x372>
    41b6:	mov    rdi,QWORD PTR [rsp+0x30]
    41bb:	mov    rax,QWORD PTR [rdi+0x10]
    41bf:	mov    rdx,QWORD PTR [rax+0x40]
    41c3:	mov    QWORD PTR [r12+0x8],rdx
    41c8:	mov    rax,QWORD PTR [rdi+0x10]
    41cc:	mov    rcx,QWORD PTR [rax+0x48]
    41d0:	mov    QWORD PTR [r12+0x10],rcx
    41d5:	mov    rsi,rbx
    41d8:	call   41dd <botlish_fn_29+0xfd>
			41d9: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    41dd:	test   rax,rax
    41e0:	jne    41f0 <botlish_fn_29+0x110>
    41e6:	mov    rdi,QWORD PTR [rsp+0x30]
    41eb:	jmp    4452 <botlish_fn_29+0x372>
    41f0:	mov    rdi,QWORD PTR [rsp+0x30]
    41f5:	mov    rax,QWORD PTR [rdi+0x10]
    41f9:	mov    rdx,QWORD PTR [rax+0x30]
    41fd:	mov    QWORD PTR [r12+0x8],rdx
    4202:	mov    rax,QWORD PTR [rdi+0x10]
    4206:	mov    rcx,QWORD PTR [rax+0x50]
    420a:	mov    QWORD PTR [r12+0x10],rcx
    420f:	mov    rsi,rbx
    4212:	call   4217 <botlish_fn_29+0x137>
			4213: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    4217:	test   rax,rax
    421a:	jne    422a <botlish_fn_29+0x14a>
    4220:	mov    rdi,QWORD PTR [rsp+0x30]
    4225:	jmp    4452 <botlish_fn_29+0x372>
    422a:	mov    rdi,QWORD PTR [rsp+0x30]
    422f:	mov    rax,QWORD PTR [rdi+0x10]
    4233:	mov    rdx,QWORD PTR [rax+0x40]
    4237:	mov    QWORD PTR [r12+0x8],rdx
    423c:	mov    rsi,rbx
    423f:	call   4244 <botlish_fn_29+0x164>
			4240: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    4244:	mov    rcx,rax
    4247:	test   rcx,rcx
    424a:	jne    425a <botlish_fn_29+0x17a>
    4250:	mov    rdi,QWORD PTR [rsp+0x30]
    4255:	jmp    4452 <botlish_fn_29+0x372>
    425a:	mov    QWORD PTR [r12+0x8],rcx
    425f:	mov    rdi,QWORD PTR [rsp+0x30]
    4264:	mov    QWORD PTR [rsp+0x38],rcx
    4269:	mov    rax,QWORD PTR [rdi+0x10]
    426d:	mov    rdx,QWORD PTR [rax+0x40]
    4271:	mov    QWORD PTR [r12+0x10],rdx
    4276:	mov    rsi,rbx
    4279:	call   427e <botlish_fn_29+0x19e>
			427a: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    427e:	test   rax,rax
    4281:	jne    4291 <botlish_fn_29+0x1b1>
    4287:	mov    rdi,QWORD PTR [rsp+0x30]
    428c:	jmp    4452 <botlish_fn_29+0x372>
    4291:	mov    rdi,QWORD PTR [rsp+0x30]
    4296:	mov    rax,QWORD PTR [rdi+0x10]
    429a:	mov    rdx,QWORD PTR [rax+0x30]
    429e:	mov    QWORD PTR [r12+0x10],rdx
    42a3:	mov    rsi,rbx
    42a6:	call   42ab <botlish_fn_29+0x1cb>
			42a7: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    42ab:	test   rax,rax
    42ae:	jne    42be <botlish_fn_29+0x1de>
    42b4:	mov    rdi,QWORD PTR [rsp+0x30]
    42b9:	jmp    4452 <botlish_fn_29+0x372>
    42be:	mov    rdi,QWORD PTR [rsp+0x30]
    42c3:	mov    rcx,QWORD PTR [rdi+0x10]
    42c7:	mov    rdx,QWORD PTR [rcx+0x50]
    42cb:	mov    rcx,rax
    42ce:	and    rcx,rdx
    42d1:	mov    rsi,rax
    42d4:	test   rcx,0x1
    42db:	jne    4305 <botlish_fn_29+0x225>
    42e1:	mov    rax,QWORD PTR [rip+0x0]        # 42e8 <botlish_fn_29+0x208>
			42e4: R_X86_64_GOTPCREL	rt_value_eq-0x4
    42e8:	mov    rdi,QWORD PTR [rsp+0x30]
    42ed:	call   rax
    42ef:	mov    r13,rax
    42f2:	test   r13,r13
    42f5:	jne    4316 <botlish_fn_29+0x236>
    42fb:	mov    rdi,QWORD PTR [rsp+0x30]
    4300:	jmp    4452 <botlish_fn_29+0x372>
    4305:	mov    r13d,0x2
    430b:	cmp    rsi,rdx
    430e:	cmove  r13,QWORD PTR [rip+0x1ca]        # 44e0 <botlish_fn_29+0x400>
    4316:	mov    QWORD PTR [r12+0x10],r13
    431b:	mov    rdi,QWORD PTR [rsp+0x30]
    4320:	mov    rax,QWORD PTR [rdi+0x10]
    4324:	mov    rdx,QWORD PTR [rax+0x40]
    4328:	mov    QWORD PTR [r12+0x18],rdx
    432d:	mov    rsi,rbx
    4330:	call   4335 <botlish_fn_29+0x255>
			4331: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    4335:	mov    r14,rax
    4338:	test   r14,r14
    433b:	jne    434b <botlish_fn_29+0x26b>
    4341:	mov    rdi,QWORD PTR [rsp+0x30]
    4346:	jmp    4452 <botlish_fn_29+0x372>
    434b:	mov    QWORD PTR [r12+0x18],r14
    4350:	mov    rdi,QWORD PTR [rsp+0x30]
    4355:	mov    rax,QWORD PTR [rdi+0x10]
    4359:	mov    rdx,QWORD PTR [rax+0x58]
    435d:	mov    QWORD PTR [r12+0x20],rdx
    4362:	mov    rsi,rbx
    4365:	call   436a <botlish_fn_29+0x28a>
			4366: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    436a:	mov    r15,rax
    436d:	test   r15,r15
    4370:	jne    4380 <botlish_fn_29+0x2a0>
    4376:	mov    rdi,QWORD PTR [rsp+0x30]
    437b:	jmp    4452 <botlish_fn_29+0x372>
    4380:	mov    QWORD PTR [r12+0x20],r15
    4385:	mov    rdi,QWORD PTR [rsp+0x30]
    438a:	mov    rax,QWORD PTR [rdi+0x10]
    438e:	mov    rdx,QWORD PTR [rax+0x58]
    4392:	mov    QWORD PTR [r12+0x28],rdx
    4397:	mov    rsi,rbx
    439a:	call   439f <botlish_fn_29+0x2bf>
			439b: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    439f:	test   rax,rax
    43a2:	mov    rsi,rax
    43a5:	jne    43b5 <botlish_fn_29+0x2d5>
    43ab:	mov    rdi,QWORD PTR [rsp+0x30]
    43b0:	jmp    4452 <botlish_fn_29+0x372>
    43b5:	mov    edx,0xa
    43ba:	mov    r8,QWORD PTR [rip+0x0]        # 43c1 <botlish_fn_29+0x2e1>
			43bd: R_X86_64_GOTPCREL	rt_value_eq-0x4
    43c1:	mov    rdi,QWORD PTR [rsp+0x30]
    43c6:	call   r8
    43c9:	test   rax,rax
    43cc:	jne    43dc <botlish_fn_29+0x2fc>
    43d2:	mov    rdi,QWORD PTR [rsp+0x30]
    43d7:	jmp    4452 <botlish_fn_29+0x372>
    43dc:	mov    QWORD PTR [r12+0x28],rax
    43e1:	mov    rsi,rbx
    43e4:	mov    rbx,rax
    43e7:	mov    rdi,QWORD PTR [rsp+0x30]
    43ec:	call   43f1 <botlish_fn_29+0x311>
			43ed: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    43f1:	test   rax,rax
    43f4:	jne    4404 <botlish_fn_29+0x324>
    43fa:	mov    rdi,QWORD PTR [rsp+0x30]
    43ff:	jmp    4452 <botlish_fn_29+0x372>
    4404:	mov    QWORD PTR [r12],rax
    4408:	lea    rdx,[rsp]
    440c:	mov    QWORD PTR [rsp],r13
    4410:	mov    rcx,QWORD PTR [rsp+0x38]
    4415:	mov    QWORD PTR [rsp+0x8],rcx
    441a:	mov    QWORD PTR [rsp+0x10],r14
    441f:	mov    QWORD PTR [rsp+0x18],r15
    4424:	mov    rcx,rbx
    4427:	mov    QWORD PTR [rsp+0x20],rcx
    442c:	mov    QWORD PTR [rsp+0x28],rax
    4431:	mov    esi,0x6
    4436:	mov    rax,QWORD PTR [rip+0x0]        # 443d <botlish_fn_29+0x35d>
			4439: R_X86_64_GOTPCREL	rt_list_new-0x4
    443d:	mov    rdi,QWORD PTR [rsp+0x30]
    4442:	call   rax
    4444:	test   rax,rax
    4447:	jne    447f <botlish_fn_29+0x39f>
    444d:	mov    rdi,QWORD PTR [rsp+0x30]
    4452:	mov    rdi,QWORD PTR [rsp+0x30]
    4457:	mov    QWORD PTR [rdi],r12
    445a:	xor    rax,rax
    445d:	mov    rbx,QWORD PTR [rsp+0x40]
    4462:	mov    r12,QWORD PTR [rsp+0x48]
    4467:	mov    r13,QWORD PTR [rsp+0x50]
    446c:	mov    r14,QWORD PTR [rsp+0x58]
    4471:	mov    r15,QWORD PTR [rsp+0x60]
    4476:	add    rsp,0x70
    447a:	mov    rsp,rbp
    447d:	pop    rbp
    447e:	ret
    447f:	mov    rdi,QWORD PTR [rsp+0x30]
    4484:	mov    QWORD PTR [rdi],r12
    4487:	mov    rbx,QWORD PTR [rsp+0x40]
    448c:	mov    r12,QWORD PTR [rsp+0x48]
    4491:	mov    r13,QWORD PTR [rsp+0x50]
    4496:	mov    r14,QWORD PTR [rsp+0x58]
    449b:	mov    r15,QWORD PTR [rsp+0x60]
    44a0:	add    rsp,0x70
    44a4:	mov    rsp,rbp
    44a7:	pop    rbp
    44a8:	ret
    44a9:	mov    QWORD PTR [rsp+0x30],rdi
    44ae:	mov    rax,QWORD PTR [rip+0x0]        # 44b5 <botlish_fn_29+0x3d5>
			44b1: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    44b5:	call   rax
    44b7:	xor    rax,rax
    44ba:	mov    rbx,QWORD PTR [rsp+0x40]
    44bf:	mov    r12,QWORD PTR [rsp+0x48]
    44c4:	mov    r13,QWORD PTR [rsp+0x50]
    44c9:	mov    r14,QWORD PTR [rsp+0x58]
    44ce:	mov    r15,QWORD PTR [rsp+0x60]
    44d3:	add    rsp,0x70
    44d7:	mov    rsp,rbp
    44da:	pop    rbp
    44db:	ret
    44dc:	add    BYTE PTR [rax],al
    44de:	add    BYTE PTR [rax],al
    44e0:	(bad)
    44e1:	add    BYTE PTR [rax],al
    44e3:	add    BYTE PTR [rax],al
    44e5:	add    BYTE PTR [rax],al
	...

00000000000044e8 <botlish_entry_29: sample<generic>>:
    44e8:	push   rbp
    44e9:	mov    rbp,rsp
    44ec:	call   44f1 <botlish_entry_29+0x9>
			44ed: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    44f1:	mov    rsp,rbp
    44f4:	pop    rbp
    44f5:	ret

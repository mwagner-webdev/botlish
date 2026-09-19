; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16680  (per function: 172 28 28 28 28 524 689 208 61 61 61 61 61 268 284 332 1020 1536 565 373 556 582 1353 928 953 825 1472 1108 1461 1054)
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
     11c:	sub    rsp,0x30
     120:	mov    QWORD PTR [rsp],rbx
     124:	mov    QWORD PTR [rsp+0x8],r12
     129:	mov    QWORD PTR [rsp+0x10],r13
     12e:	mov    QWORD PTR [rsp+0x18],r14
     133:	mov    QWORD PTR [rsp+0x20],r15
     138:	mov    r13,QWORD PTR [rdi]
     13b:	mov    r8,QWORD PTR [rdi+0x8]
     13f:	lea    rax,[r13+0x20]
     143:	cmp    rax,r8
     146:	ja     2b0 <botlish_fn_5+0x198>
     14c:	lea    rax,[r13+0x20]
     150:	mov    QWORD PTR [rdi],rax
     153:	mov    r14,rdi
     156:	mov    QWORD PTR [r13+0x18],0x0
     15e:	mov    QWORD PTR [r13+0x0],rsi
     162:	mov    r12,rsi
     165:	mov    QWORD PTR [r13+0x8],rdx
     169:	mov    QWORD PTR [r13+0x10],rcx
     16d:	mov    rbx,rcx
     170:	mov    rsi,rdx
     173:	mov    rax,rsi
     176:	and    rax,rbx
     179:	mov    r15,rsi
     17c:	test   rax,0x1
     182:	jne    1ab <botlish_fn_5+0x93>
     188:	mov    rdx,rbx
     18b:	mov    rsi,r15
     18e:	mov    rdi,r14
     191:	call   196 <botlish_fn_5+0x7e>
			192: R_X86_64_PLT32	rt_int_cmp-0x4
     196:	mov    ecx,0x2
     19b:	test   rax,rax
     19e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 2e0 <botlish_fn_5+0x1c8>
     1a6:	jmp    1be <botlish_fn_5+0xa6>
     1ab:	mov    ecx,0x2
     1b0:	mov    rsi,r15
     1b3:	cmp    rsi,rbx
     1b6:	cmovge rcx,QWORD PTR [rip+0x122]        # 2e0 <botlish_fn_5+0x1c8>
     1be:	cmp    rcx,0x6
     1c2:	je     284 <botlish_fn_5+0x16c>
     1c8:	mov    rdi,r14
     1cb:	call   1d0 <botlish_fn_5+0xb8>
			1cc: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     1d0:	test   rax,rax
     1d3:	mov    rcx,rax
     1d6:	jne    1e4 <botlish_fn_5+0xcc>
     1dc:	mov    rdi,r14
     1df:	jmp    1fe <botlish_fn_5+0xe6>
     1e4:	mov    rdx,r15
     1e7:	mov    rsi,r12
     1ea:	mov    rdi,r14
     1ed:	call   1f2 <botlish_fn_5+0xda>
			1ee: R_X86_64_PLT32	rt_mutarray_set-0x4
     1f2:	test   rax,rax
     1f5:	jne    228 <botlish_fn_5+0x110>
     1fb:	mov    rdi,r14
     1fe:	mov    rdi,r14
     201:	mov    QWORD PTR [rdi],r13
     204:	xor    rax,rax
     207:	mov    rbx,QWORD PTR [rsp]
     20b:	mov    r12,QWORD PTR [rsp+0x8]
     210:	mov    r13,QWORD PTR [rsp+0x10]
     215:	mov    r14,QWORD PTR [rsp+0x18]
     21a:	mov    r15,QWORD PTR [rsp+0x20]
     21f:	add    rsp,0x30
     223:	mov    rsp,rbp
     226:	pop    rbp
     227:	ret
     228:	mov    QWORD PTR [r13+0x18],0x3
     230:	mov    rsi,r15
     233:	test   rsi,0x1
     23a:	je     25d <botlish_fn_5+0x145>
     240:	mov    rsi,r15
     243:	mov    rcx,rsi
     246:	add    rcx,0x2
     24a:	seto   al
     24d:	test   al,al
     24f:	jne    25d <botlish_fn_5+0x145>
     255:	mov    r15,rcx
     258:	jmp    270 <botlish_fn_5+0x158>
     25d:	mov    edx,0x3
     262:	mov    rsi,r15
     265:	mov    rdi,r14
     268:	call   26d <botlish_fn_5+0x155>
			269: R_X86_64_PLT32	rt_int_add-0x4
     26d:	mov    r15,rax
     270:	mov    QWORD PTR [r13+0x0],r12
     274:	mov    rsi,r15
     277:	mov    QWORD PTR [r13+0x8],rsi
     27b:	mov    QWORD PTR [r13+0x10],rbx
     27f:	jmp    173 <botlish_fn_5+0x5b>
     284:	mov    rdi,r14
     287:	mov    QWORD PTR [rdi],r13
     28a:	mov    eax,0xa
     28f:	mov    rbx,QWORD PTR [rsp]
     293:	mov    r12,QWORD PTR [rsp+0x8]
     298:	mov    r13,QWORD PTR [rsp+0x10]
     29d:	mov    r14,QWORD PTR [rsp+0x18]
     2a2:	mov    r15,QWORD PTR [rsp+0x20]
     2a7:	add    rsp,0x30
     2ab:	mov    rsp,rbp
     2ae:	pop    rbp
     2af:	ret
     2b0:	mov    r14,rdi
     2b3:	call   2b8 <botlish_fn_5+0x1a0>
			2b4: R_X86_64_PLT32	rt_stack_overflow-0x4
     2b8:	xor    rax,rax
     2bb:	mov    rbx,QWORD PTR [rsp]
     2bf:	mov    r12,QWORD PTR [rsp+0x8]
     2c4:	mov    r13,QWORD PTR [rsp+0x10]
     2c9:	mov    r14,QWORD PTR [rsp+0x18]
     2ce:	mov    r15,QWORD PTR [rsp+0x20]
     2d3:	add    rsp,0x30
     2d7:	mov    rsp,rbp
     2da:	pop    rbp
     2db:	ret
     2dc:	add    BYTE PTR [rax],al
     2de:	add    BYTE PTR [rax],al
     2e0:	(bad)
     2e1:	add    BYTE PTR [rax],al
     2e3:	add    BYTE PTR [rax],al
     2e5:	add    BYTE PTR [rax],al
	...

00000000000002e8 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     2e8:	push   rbp
     2e9:	mov    rbp,rsp
     2ec:	mov    rsi,QWORD PTR [rdx]
     2ef:	mov    r8,QWORD PTR [rdx+0x8]
     2f3:	mov    rcx,QWORD PTR [rdx+0x10]
     2f7:	mov    rdx,r8
     2fa:	call   2ff <botlish_entry_5+0x17>
			2fb: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     2ff:	mov    rsp,rbp
     302:	pop    rbp
     303:	ret

0000000000000304 <botlish_fn_6: ht_alloc<int>>:
     304:	push   rbp
     305:	mov    rbp,rsp
     308:	sub    rsp,0x40
     30c:	mov    QWORD PTR [rsp+0x10],rbx
     311:	mov    QWORD PTR [rsp+0x18],r12
     316:	mov    QWORD PTR [rsp+0x20],r13
     31b:	mov    QWORD PTR [rsp+0x28],r14
     320:	mov    QWORD PTR [rsp+0x30],r15
     325:	mov    rbx,QWORD PTR [rdi]
     328:	mov    rax,QWORD PTR [rdi+0x8]
     32c:	lea    rcx,[rbx+0x20]
     330:	cmp    rcx,rax
     333:	ja     52e <botlish_fn_6+0x22a>
     339:	lea    rax,[rbx+0x20]
     33d:	mov    QWORD PTR [rdi],rax
     340:	mov    r12,rdi
     343:	mov    QWORD PTR [rbx+0x8],0x0
     34b:	mov    QWORD PTR [rbx+0x10],0x0
     353:	mov    QWORD PTR [rbx+0x18],0x0
     35b:	mov    QWORD PTR [rbx],rsi
     35e:	mov    r13,rsi
     361:	mov    rsi,r13
     364:	mov    rdi,r12
     367:	call   36c <botlish_fn_6+0x68>
			368: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     36c:	test   rax,rax
     36f:	jne    37d <botlish_fn_6+0x79>
     375:	mov    rdi,r12
     378:	jmp    4d7 <botlish_fn_6+0x1d3>
     37d:	mov    QWORD PTR [rbx+0x8],rax
     381:	mov    r14,rax
     384:	mov    edx,0x1
     389:	mov    QWORD PTR [rbx+0x10],0x1
     391:	mov    rcx,r13
     394:	mov    rsi,r14
     397:	mov    rdi,r12
     39a:	call   39f <botlish_fn_6+0x9b>
			39b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     39f:	test   rax,rax
     3a2:	jne    3b0 <botlish_fn_6+0xac>
     3a8:	mov    rdi,r12
     3ab:	jmp    4d7 <botlish_fn_6+0x1d3>
     3b0:	mov    rsi,r13
     3b3:	mov    rdi,r12
     3b6:	call   3bb <botlish_fn_6+0xb7>
			3b7: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3bb:	test   rax,rax
     3be:	jne    3cc <botlish_fn_6+0xc8>
     3c4:	mov    rdi,r12
     3c7:	jmp    4d7 <botlish_fn_6+0x1d3>
     3cc:	mov    QWORD PTR [rbx+0x10],rax
     3d0:	mov    rsi,r13
     3d3:	mov    r15,rax
     3d6:	mov    rdi,r12
     3d9:	call   3de <botlish_fn_6+0xda>
			3da: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3de:	test   rax,rax
     3e1:	jne    3ef <botlish_fn_6+0xeb>
     3e7:	mov    rdi,r12
     3ea:	jmp    4d7 <botlish_fn_6+0x1d3>
     3ef:	mov    QWORD PTR [rbx],rax
     3f2:	mov    r13,rax
     3f5:	mov    esi,0xb
     3fa:	mov    QWORD PTR [rbx+0x18],0xb
     402:	mov    rdi,r12
     405:	call   40a <botlish_fn_6+0x106>
			406: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     40a:	test   rax,rax
     40d:	mov    QWORD PTR [rsp],rax
     411:	jne    41f <botlish_fn_6+0x11b>
     417:	mov    rdi,r12
     41a:	jmp    4d7 <botlish_fn_6+0x1d3>
     41f:	mov    edx,0x1
     424:	mov    rcx,r14
     427:	mov    rsi,QWORD PTR [rsp]
     42b:	mov    rdi,r12
     42e:	call   433 <botlish_fn_6+0x12f>
			42f: R_X86_64_PLT32	rt_mutarray_set-0x4
     433:	test   rax,rax
     436:	jne    444 <botlish_fn_6+0x140>
     43c:	mov    rdi,r12
     43f:	jmp    4d7 <botlish_fn_6+0x1d3>
     444:	mov    edx,0x3
     449:	mov    rcx,r15
     44c:	mov    rsi,QWORD PTR [rsp]
     450:	mov    rdi,r12
     453:	call   458 <botlish_fn_6+0x154>
			454: R_X86_64_PLT32	rt_mutarray_set-0x4
     458:	test   rax,rax
     45b:	jne    469 <botlish_fn_6+0x165>
     461:	mov    rdi,r12
     464:	jmp    4d7 <botlish_fn_6+0x1d3>
     469:	mov    edx,0x5
     46e:	mov    rcx,r13
     471:	mov    rsi,QWORD PTR [rsp]
     475:	mov    rdi,r12
     478:	call   47d <botlish_fn_6+0x179>
			479: R_X86_64_PLT32	rt_mutarray_set-0x4
     47d:	test   rax,rax
     480:	jne    48e <botlish_fn_6+0x18a>
     486:	mov    rdi,r12
     489:	jmp    4d7 <botlish_fn_6+0x1d3>
     48e:	mov    edx,0x7
     493:	mov    ecx,0x1
     498:	mov    rsi,QWORD PTR [rsp]
     49c:	mov    rdi,r12
     49f:	call   4a4 <botlish_fn_6+0x1a0>
			4a0: R_X86_64_PLT32	rt_mutarray_set-0x4
     4a4:	test   rax,rax
     4a7:	jne    4b5 <botlish_fn_6+0x1b1>
     4ad:	mov    rdi,r12
     4b0:	jmp    4d7 <botlish_fn_6+0x1d3>
     4b5:	mov    edx,0x9
     4ba:	mov    ecx,0x1
     4bf:	mov    rsi,QWORD PTR [rsp]
     4c3:	mov    rdi,r12
     4c6:	call   4cb <botlish_fn_6+0x1c7>
			4c7: R_X86_64_PLT32	rt_mutarray_set-0x4
     4cb:	test   rax,rax
     4ce:	jne    502 <botlish_fn_6+0x1fe>
     4d4:	mov    rdi,r12
     4d7:	mov    rdi,r12
     4da:	mov    QWORD PTR [rdi],rbx
     4dd:	xor    rax,rax
     4e0:	mov    rbx,QWORD PTR [rsp+0x10]
     4e5:	mov    r12,QWORD PTR [rsp+0x18]
     4ea:	mov    r13,QWORD PTR [rsp+0x20]
     4ef:	mov    r14,QWORD PTR [rsp+0x28]
     4f4:	mov    r15,QWORD PTR [rsp+0x30]
     4f9:	add    rsp,0x40
     4fd:	mov    rsp,rbp
     500:	pop    rbp
     501:	ret
     502:	mov    rdi,r12
     505:	mov    QWORD PTR [rdi],rbx
     508:	mov    rax,QWORD PTR [rsp]
     50c:	mov    rbx,QWORD PTR [rsp+0x10]
     511:	mov    r12,QWORD PTR [rsp+0x18]
     516:	mov    r13,QWORD PTR [rsp+0x20]
     51b:	mov    r14,QWORD PTR [rsp+0x28]
     520:	mov    r15,QWORD PTR [rsp+0x30]
     525:	add    rsp,0x40
     529:	mov    rsp,rbp
     52c:	pop    rbp
     52d:	ret
     52e:	mov    r12,rdi
     531:	call   536 <botlish_fn_6+0x232>
			532: R_X86_64_PLT32	rt_stack_overflow-0x4
     536:	xor    rax,rax
     539:	mov    rbx,QWORD PTR [rsp+0x10]
     53e:	mov    r12,QWORD PTR [rsp+0x18]
     543:	mov    r13,QWORD PTR [rsp+0x20]
     548:	mov    r14,QWORD PTR [rsp+0x28]
     54d:	mov    r15,QWORD PTR [rsp+0x30]
     552:	add    rsp,0x40
     556:	mov    rsp,rbp
     559:	pop    rbp
     55a:	ret

000000000000055b <botlish_entry_6: ht_alloc<int>>:
     55b:	push   rbp
     55c:	mov    rbp,rsp
     55f:	mov    rsi,QWORD PTR [rdx]
     562:	call   567 <botlish_entry_6+0xc>
			563: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     567:	mov    rsp,rbp
     56a:	pop    rbp
     56b:	ret

000000000000056c <botlish_fn_7: ht_new<generic>>:
     56c:	push   rbp
     56d:	mov    rbp,rsp
     570:	sub    rsp,0x10
     574:	mov    QWORD PTR [rsp],r12
     578:	mov    QWORD PTR [rsp+0x8],r13
     57d:	mov    r12,QWORD PTR [rdi]
     580:	mov    rax,QWORD PTR [rdi+0x8]
     584:	lea    rcx,[r12+0x8]
     589:	cmp    rcx,rax
     58c:	ja     60c <botlish_fn_7+0xa0>
     592:	lea    rax,[r12+0x8]
     597:	mov    QWORD PTR [rdi],rax
     59a:	mov    r13,rdi
     59d:	mov    QWORD PTR [r12],0x0
     5a5:	mov    rdi,r13
     5a8:	call   5ad <botlish_fn_7+0x41>
			5a9: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     5ad:	test   rax,rax
     5b0:	jne    5be <botlish_fn_7+0x52>
     5b6:	mov    rdi,r13
     5b9:	jmp    5d9 <botlish_fn_7+0x6d>
     5be:	mov    QWORD PTR [r12],rax
     5c2:	mov    rsi,rax
     5c5:	mov    rdi,r13
     5c8:	call   5cd <botlish_fn_7+0x61>
			5c9: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     5cd:	test   rax,rax
     5d0:	jne    5f4 <botlish_fn_7+0x88>
     5d6:	mov    rdi,r13
     5d9:	mov    rdi,r13
     5dc:	mov    QWORD PTR [rdi],r12
     5df:	xor    rax,rax
     5e2:	mov    r12,QWORD PTR [rsp]
     5e6:	mov    r13,QWORD PTR [rsp+0x8]
     5eb:	add    rsp,0x10
     5ef:	mov    rsp,rbp
     5f2:	pop    rbp
     5f3:	ret
     5f4:	mov    rdi,r13
     5f7:	mov    QWORD PTR [rdi],r12
     5fa:	mov    r12,QWORD PTR [rsp]
     5fe:	mov    r13,QWORD PTR [rsp+0x8]
     603:	add    rsp,0x10
     607:	mov    rsp,rbp
     60a:	pop    rbp
     60b:	ret
     60c:	mov    r13,rdi
     60f:	call   614 <botlish_fn_7+0xa8>
			610: R_X86_64_PLT32	rt_stack_overflow-0x4
     614:	xor    rax,rax
     617:	mov    r12,QWORD PTR [rsp]
     61b:	mov    r13,QWORD PTR [rsp+0x8]
     620:	add    rsp,0x10
     624:	mov    rsp,rbp
     627:	pop    rbp
     628:	ret

0000000000000629 <botlish_entry_7: ht_new<generic>>:
     629:	push   rbp
     62a:	mov    rbp,rsp
     62d:	call   632 <botlish_entry_7+0x9>
			62e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     632:	mov    rsp,rbp
     635:	pop    rbp
     636:	ret

0000000000000637 <botlish_fn_8: ht_controls<mutarray>>:
     637:	push   rbp
     638:	mov    rbp,rsp
     63b:	mov    edx,0x1
     640:	call   645 <botlish_fn_8+0xe>
			641: R_X86_64_PLT32	rt_mutarray_get-0x4
     645:	test   rax,rax
     648:	jne    656 <botlish_fn_8+0x1f>
     64e:	xor    rax,rax
     651:	mov    rsp,rbp
     654:	pop    rbp
     655:	ret
     656:	mov    rsp,rbp
     659:	pop    rbp
     65a:	ret

000000000000065b <botlish_entry_8: ht_controls<mutarray>>:
     65b:	push   rbp
     65c:	mov    rbp,rsp
     65f:	mov    rsi,QWORD PTR [rdx]
     662:	call   667 <botlish_entry_8+0xc>
			663: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     667:	mov    rsp,rbp
     66a:	pop    rbp
     66b:	ret

000000000000066c <botlish_fn_9: ht_keys<mutarray>>:
     66c:	push   rbp
     66d:	mov    rbp,rsp
     670:	mov    edx,0x3
     675:	call   67a <botlish_fn_9+0xe>
			676: R_X86_64_PLT32	rt_mutarray_get-0x4
     67a:	test   rax,rax
     67d:	jne    68b <botlish_fn_9+0x1f>
     683:	xor    rax,rax
     686:	mov    rsp,rbp
     689:	pop    rbp
     68a:	ret
     68b:	mov    rsp,rbp
     68e:	pop    rbp
     68f:	ret

0000000000000690 <botlish_entry_9: ht_keys<mutarray>>:
     690:	push   rbp
     691:	mov    rbp,rsp
     694:	mov    rsi,QWORD PTR [rdx]
     697:	call   69c <botlish_entry_9+0xc>
			698: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     69c:	mov    rsp,rbp
     69f:	pop    rbp
     6a0:	ret

00000000000006a1 <botlish_fn_10: ht_values<mutarray>>:
     6a1:	push   rbp
     6a2:	mov    rbp,rsp
     6a5:	mov    edx,0x5
     6aa:	call   6af <botlish_fn_10+0xe>
			6ab: R_X86_64_PLT32	rt_mutarray_get-0x4
     6af:	test   rax,rax
     6b2:	jne    6c0 <botlish_fn_10+0x1f>
     6b8:	xor    rax,rax
     6bb:	mov    rsp,rbp
     6be:	pop    rbp
     6bf:	ret
     6c0:	mov    rsp,rbp
     6c3:	pop    rbp
     6c4:	ret

00000000000006c5 <botlish_entry_10: ht_values<mutarray>>:
     6c5:	push   rbp
     6c6:	mov    rbp,rsp
     6c9:	mov    rsi,QWORD PTR [rdx]
     6cc:	call   6d1 <botlish_entry_10+0xc>
			6cd: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     6d1:	mov    rsp,rbp
     6d4:	pop    rbp
     6d5:	ret

00000000000006d6 <botlish_fn_11: ht_size<mutarray>>:
     6d6:	push   rbp
     6d7:	mov    rbp,rsp
     6da:	mov    edx,0x7
     6df:	call   6e4 <botlish_fn_11+0xe>
			6e0: R_X86_64_PLT32	rt_mutarray_get-0x4
     6e4:	test   rax,rax
     6e7:	jne    6f5 <botlish_fn_11+0x1f>
     6ed:	xor    rax,rax
     6f0:	mov    rsp,rbp
     6f3:	pop    rbp
     6f4:	ret
     6f5:	mov    rsp,rbp
     6f8:	pop    rbp
     6f9:	ret

00000000000006fa <botlish_entry_11: ht_size<mutarray>>:
     6fa:	push   rbp
     6fb:	mov    rbp,rsp
     6fe:	mov    rsi,QWORD PTR [rdx]
     701:	call   706 <botlish_entry_11+0xc>
			702: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     706:	mov    rsp,rbp
     709:	pop    rbp
     70a:	ret

000000000000070b <botlish_fn_12: ht_tombstones<mutarray>>:
     70b:	push   rbp
     70c:	mov    rbp,rsp
     70f:	mov    edx,0x9
     714:	call   719 <botlish_fn_12+0xe>
			715: R_X86_64_PLT32	rt_mutarray_get-0x4
     719:	test   rax,rax
     71c:	jne    72a <botlish_fn_12+0x1f>
     722:	xor    rax,rax
     725:	mov    rsp,rbp
     728:	pop    rbp
     729:	ret
     72a:	mov    rsp,rbp
     72d:	pop    rbp
     72e:	ret

000000000000072f <botlish_entry_12: ht_tombstones<mutarray>>:
     72f:	push   rbp
     730:	mov    rbp,rsp
     733:	mov    rsi,QWORD PTR [rdx]
     736:	call   73b <botlish_entry_12+0xc>
			737: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     73b:	mov    rsp,rbp
     73e:	pop    rbp
     73f:	ret

0000000000000740 <botlish_fn_13: ht_capacity<mutarray>>:
     740:	push   rbp
     741:	mov    rbp,rsp
     744:	sub    rsp,0x10
     748:	mov    QWORD PTR [rsp],rbx
     74c:	mov    QWORD PTR [rsp+0x8],r12
     751:	mov    rbx,QWORD PTR [rdi]
     754:	mov    rax,QWORD PTR [rdi+0x8]
     758:	lea    rcx,[rbx+0x8]
     75c:	cmp    rcx,rax
     75f:	ja     809 <botlish_fn_13+0xc9>
     765:	lea    rax,[rbx+0x8]
     769:	mov    QWORD PTR [rdi],rax
     76c:	mov    r12,rdi
     76f:	mov    QWORD PTR [rbx],rsi
     772:	mov    rdi,r12
     775:	call   77a <botlish_fn_13+0x3a>
			776: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     77a:	test   rax,rax
     77d:	jne    78b <botlish_fn_13+0x4b>
     783:	mov    rdi,r12
     786:	jmp    7ce <botlish_fn_13+0x8e>
     78b:	xor    ecx,ecx
     78d:	test   rax,0x7
     793:	je     7a1 <botlish_fn_13+0x61>
     799:	mov    rsi,rax
     79c:	jmp    7af <botlish_fn_13+0x6f>
     7a1:	movzx  rcx,BYTE PTR [rax]
     7a5:	mov    rsi,rax
     7a8:	rex cmp cl,0x8
     7ac:	sete   cl
     7af:	test   cl,cl
     7b1:	jne    7e9 <botlish_fn_13+0xa9>
     7b7:	mov    rdi,r12
     7ba:	mov    rax,QWORD PTR [rdi+0x10]
     7be:	mov    rcx,QWORD PTR [rax]
     7c1:	mov    edx,0x8
     7c6:	call   7cb <botlish_fn_13+0x8b>
			7c7: R_X86_64_PLT32	rt_type_error-0x4
     7cb:	mov    rdi,r12
     7ce:	mov    rdi,r12
     7d1:	mov    QWORD PTR [rdi],rbx
     7d4:	xor    rax,rax
     7d7:	mov    rbx,QWORD PTR [rsp]
     7db:	mov    r12,QWORD PTR [rsp+0x8]
     7e0:	add    rsp,0x10
     7e4:	mov    rsp,rbp
     7e7:	pop    rbp
     7e8:	ret
     7e9:	mov    rdi,r12
     7ec:	call   7f1 <botlish_fn_13+0xb1>
			7ed: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     7f1:	mov    rdi,r12
     7f4:	mov    QWORD PTR [rdi],rbx
     7f7:	mov    rbx,QWORD PTR [rsp]
     7fb:	mov    r12,QWORD PTR [rsp+0x8]
     800:	add    rsp,0x10
     804:	mov    rsp,rbp
     807:	pop    rbp
     808:	ret
     809:	mov    r12,rdi
     80c:	call   811 <botlish_fn_13+0xd1>
			80d: R_X86_64_PLT32	rt_stack_overflow-0x4
     811:	xor    rax,rax
     814:	mov    rbx,QWORD PTR [rsp]
     818:	mov    r12,QWORD PTR [rsp+0x8]
     81d:	add    rsp,0x10
     821:	mov    rsp,rbp
     824:	pop    rbp
     825:	ret

0000000000000826 <botlish_entry_13: ht_capacity<mutarray>>:
     826:	push   rbp
     827:	mov    rbp,rsp
     82a:	mov    rsi,QWORD PTR [rdx]
     82d:	call   832 <botlish_entry_13+0xc>
			82e: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     832:	mov    rsp,rbp
     835:	pop    rbp
     836:	ret

0000000000000837 <botlish_fn_14: ht_probe_start<mutarray, str>>:
     837:	push   rbp
     838:	mov    rbp,rsp
     83b:	sub    rsp,0x20
     83f:	mov    QWORD PTR [rsp],rbx
     843:	mov    QWORD PTR [rsp+0x8],r12
     848:	mov    QWORD PTR [rsp+0x10],r15
     84d:	mov    r15,QWORD PTR [rdi]
     850:	mov    rax,QWORD PTR [rdi+0x8]
     854:	lea    rcx,[r15+0x10]
     858:	cmp    rcx,rax
     85b:	ja     907 <botlish_fn_14+0xd0>
     861:	lea    rax,[r15+0x10]
     865:	mov    QWORD PTR [rdi],rax
     868:	mov    rbx,rdi
     86b:	mov    QWORD PTR [r15],rsi
     86e:	mov    r12,rsi
     871:	mov    rsi,rdx
     874:	mov    rdi,rbx
     877:	call   87c <botlish_fn_14+0x45>
			878: R_X86_64_PLT32	rt_hash-0x4
     87c:	test   rax,rax
     87f:	jne    88d <botlish_fn_14+0x56>
     885:	mov    rdi,rbx
     888:	jmp    8ca <botlish_fn_14+0x93>
     88d:	mov    QWORD PTR [r15+0x8],rax
     891:	mov    rsi,r12
     894:	mov    r12,rax
     897:	mov    rdi,rbx
     89a:	call   89f <botlish_fn_14+0x68>
			89b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     89f:	test   rax,rax
     8a2:	mov    rdx,rax
     8a5:	jne    8b3 <botlish_fn_14+0x7c>
     8ab:	mov    rdi,rbx
     8ae:	jmp    8ca <botlish_fn_14+0x93>
     8b3:	mov    rsi,r12
     8b6:	mov    rdi,rbx
     8b9:	call   8be <botlish_fn_14+0x87>
			8ba: R_X86_64_PLT32	rt_int_mod-0x4
     8be:	test   rax,rax
     8c1:	jne    8ea <botlish_fn_14+0xb3>
     8c7:	mov    rdi,rbx
     8ca:	mov    rdi,rbx
     8cd:	mov    QWORD PTR [rdi],r15
     8d0:	xor    rax,rax
     8d3:	mov    rbx,QWORD PTR [rsp]
     8d7:	mov    r12,QWORD PTR [rsp+0x8]
     8dc:	mov    r15,QWORD PTR [rsp+0x10]
     8e1:	add    rsp,0x20
     8e5:	mov    rsp,rbp
     8e8:	pop    rbp
     8e9:	ret
     8ea:	mov    rdi,rbx
     8ed:	mov    QWORD PTR [rdi],r15
     8f0:	mov    rbx,QWORD PTR [rsp]
     8f4:	mov    r12,QWORD PTR [rsp+0x8]
     8f9:	mov    r15,QWORD PTR [rsp+0x10]
     8fe:	add    rsp,0x20
     902:	mov    rsp,rbp
     905:	pop    rbp
     906:	ret
     907:	mov    rbx,rdi
     90a:	call   90f <botlish_fn_14+0xd8>
			90b: R_X86_64_PLT32	rt_stack_overflow-0x4
     90f:	xor    rax,rax
     912:	mov    rbx,QWORD PTR [rsp]
     916:	mov    r12,QWORD PTR [rsp+0x8]
     91b:	mov    r15,QWORD PTR [rsp+0x10]
     920:	add    rsp,0x20
     924:	mov    rsp,rbp
     927:	pop    rbp
     928:	ret

0000000000000929 <botlish_entry_14: ht_probe_start<mutarray, str>>:
     929:	push   rbp
     92a:	mov    rbp,rsp
     92d:	mov    rsi,QWORD PTR [rdx]
     930:	mov    rdx,QWORD PTR [rdx+0x8]
     934:	call   939 <botlish_entry_14+0x10>
			935: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     939:	mov    rsp,rbp
     93c:	pop    rbp
     93d:	ret

000000000000093e <botlish_fn_15: ht_probe_next<mutarray, int>>:
     93e:	push   rbp
     93f:	mov    rbp,rsp
     942:	sub    rsp,0x20
     946:	mov    QWORD PTR [rsp],rbx
     94a:	mov    QWORD PTR [rsp+0x8],r12
     94f:	mov    QWORD PTR [rsp+0x10],r13
     954:	mov    rbx,QWORD PTR [rdi]
     957:	mov    rax,QWORD PTR [rdi+0x8]
     95b:	lea    rcx,[rbx+0x18]
     95f:	cmp    rcx,rax
     962:	ja     a3e <botlish_fn_15+0x100>
     968:	lea    rax,[rbx+0x18]
     96c:	mov    QWORD PTR [rdi],rax
     96f:	mov    r12,rdi
     972:	mov    QWORD PTR [rbx],rsi
     975:	mov    r13,rsi
     978:	mov    QWORD PTR [rbx+0x8],rdx
     97c:	mov    QWORD PTR [rbx+0x10],0x3
     984:	test   rdx,0x1
     98b:	jne    999 <botlish_fn_15+0x5b>
     991:	mov    rcx,rdx
     994:	jmp    9ae <botlish_fn_15+0x70>
     999:	mov    rsi,rdx
     99c:	add    rsi,0x2
     9a0:	mov    rcx,rdx
     9a3:	seto   al
     9a6:	test   al,al
     9a8:	je     9c1 <botlish_fn_15+0x83>
     9ae:	mov    edx,0x3
     9b3:	mov    rsi,rcx
     9b6:	mov    rdi,r12
     9b9:	call   9be <botlish_fn_15+0x80>
			9ba: R_X86_64_PLT32	rt_int_add-0x4
     9be:	mov    rsi,rax
     9c1:	mov    QWORD PTR [rbx+0x8],rsi
     9c5:	mov    rax,rsi
     9c8:	mov    rsi,r13
     9cb:	mov    r13,rax
     9ce:	mov    rdi,r12
     9d1:	call   9d6 <botlish_fn_15+0x98>
			9d2: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     9d6:	test   rax,rax
     9d9:	mov    rdx,rax
     9dc:	jne    9ea <botlish_fn_15+0xac>
     9e2:	mov    rdi,r12
     9e5:	jmp    a01 <botlish_fn_15+0xc3>
     9ea:	mov    rsi,r13
     9ed:	mov    rdi,r12
     9f0:	call   9f5 <botlish_fn_15+0xb7>
			9f1: R_X86_64_PLT32	rt_int_mod-0x4
     9f5:	test   rax,rax
     9f8:	jne    a21 <botlish_fn_15+0xe3>
     9fe:	mov    rdi,r12
     a01:	mov    rdi,r12
     a04:	mov    QWORD PTR [rdi],rbx
     a07:	xor    rax,rax
     a0a:	mov    rbx,QWORD PTR [rsp]
     a0e:	mov    r12,QWORD PTR [rsp+0x8]
     a13:	mov    r13,QWORD PTR [rsp+0x10]
     a18:	add    rsp,0x20
     a1c:	mov    rsp,rbp
     a1f:	pop    rbp
     a20:	ret
     a21:	mov    rdi,r12
     a24:	mov    QWORD PTR [rdi],rbx
     a27:	mov    rbx,QWORD PTR [rsp]
     a2b:	mov    r12,QWORD PTR [rsp+0x8]
     a30:	mov    r13,QWORD PTR [rsp+0x10]
     a35:	add    rsp,0x20
     a39:	mov    rsp,rbp
     a3c:	pop    rbp
     a3d:	ret
     a3e:	mov    r12,rdi
     a41:	call   a46 <botlish_fn_15+0x108>
			a42: R_X86_64_PLT32	rt_stack_overflow-0x4
     a46:	xor    rax,rax
     a49:	mov    rbx,QWORD PTR [rsp]
     a4d:	mov    r12,QWORD PTR [rsp+0x8]
     a52:	mov    r13,QWORD PTR [rsp+0x10]
     a57:	add    rsp,0x20
     a5b:	mov    rsp,rbp
     a5e:	pop    rbp
     a5f:	ret

0000000000000a60 <botlish_entry_15: ht_probe_next<mutarray, int>>:
     a60:	push   rbp
     a61:	mov    rbp,rsp
     a64:	mov    rsi,QWORD PTR [rdx]
     a67:	mov    rdx,QWORD PTR [rdx+0x8]
     a6b:	call   a70 <botlish_entry_15+0x10>
			a6c: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     a70:	mov    rsp,rbp
     a73:	pop    rbp
     a74:	ret
     a75:	add    BYTE PTR [rax],al
	...

0000000000000a78 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     a78:	push   rbp
     a79:	mov    rbp,rsp
     a7c:	sub    rsp,0x40
     a80:	mov    QWORD PTR [rsp+0x10],rbx
     a85:	mov    QWORD PTR [rsp+0x18],r12
     a8a:	mov    QWORD PTR [rsp+0x20],r13
     a8f:	mov    QWORD PTR [rsp+0x28],r14
     a94:	mov    QWORD PTR [rsp+0x30],r15
     a99:	mov    r13,QWORD PTR [rdi]
     a9c:	mov    rax,QWORD PTR [rdi+0x8]
     aa0:	lea    r8,[r13+0x20]
     aa4:	cmp    r8,rax
     aa7:	ja     de9 <botlish_fn_16+0x371>
     aad:	lea    rax,[r13+0x20]
     ab1:	mov    QWORD PTR [rdi],rax
     ab4:	mov    r14,rdi
     ab7:	mov    QWORD PTR [r13+0x18],0x0
     abf:	mov    QWORD PTR [r13+0x0],rsi
     ac3:	mov    QWORD PTR [r13+0x8],rdx
     ac7:	mov    QWORD PTR [rsp],rdx
     acb:	mov    QWORD PTR [r13+0x10],rcx
     acf:	mov    r15,rsi
     ad2:	mov    QWORD PTR [rsp+0x8],rcx
     ad7:	mov    rsi,r15
     ada:	mov    rdi,r14
     add:	call   ae2 <botlish_fn_16+0x6a>
			ade: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     ae2:	test   rax,rax
     ae5:	jne    af3 <botlish_fn_16+0x7b>
     aeb:	mov    rdi,r14
     aee:	jmp    d48 <botlish_fn_16+0x2d0>
     af3:	xor    ecx,ecx
     af5:	test   rax,0x7
     afb:	je     b09 <botlish_fn_16+0x91>
     b01:	mov    rsi,rax
     b04:	jmp    b17 <botlish_fn_16+0x9f>
     b09:	movzx  r11,BYTE PTR [rax]
     b0d:	mov    rsi,rax
     b10:	cmp    r11b,0x8
     b14:	sete   cl
     b17:	test   cl,cl
     b19:	jne    b3c <botlish_fn_16+0xc4>
     b1f:	mov    rdi,r14
     b22:	mov    rax,QWORD PTR [rdi+0x10]
     b26:	mov    rcx,QWORD PTR [rax+0x8]
     b2a:	mov    edx,0x8
     b2f:	call   b34 <botlish_fn_16+0xbc>
			b30: R_X86_64_PLT32	rt_type_error-0x4
     b34:	mov    rdi,r14
     b37:	jmp    d48 <botlish_fn_16+0x2d0>
     b3c:	mov    rdx,QWORD PTR [rsp+0x8]
     b41:	mov    rdi,r14
     b44:	call   b49 <botlish_fn_16+0xd1>
			b45: R_X86_64_PLT32	rt_mutarray_get-0x4
     b49:	mov    rcx,rax
     b4c:	mov    r12,rax
     b4f:	test   rax,rcx
     b52:	jne    b60 <botlish_fn_16+0xe8>
     b58:	mov    rdi,r14
     b5b:	jmp    d48 <botlish_fn_16+0x2d0>
     b60:	mov    rax,r12
     b63:	mov    QWORD PTR [r13+0x18],rax
     b67:	mov    rdi,r14
     b6a:	call   b6f <botlish_fn_16+0xf7>
			b6b: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     b6f:	test   rax,rax
     b72:	jne    b80 <botlish_fn_16+0x108>
     b78:	mov    rdi,r14
     b7b:	jmp    d48 <botlish_fn_16+0x2d0>
     b80:	mov    rsi,r12
     b83:	mov    rcx,rsi
     b86:	and    rcx,rax
     b89:	mov    rdx,rax
     b8c:	test   rcx,0x1
     b93:	jne    bb5 <botlish_fn_16+0x13d>
     b99:	mov    rsi,r12
     b9c:	mov    rdi,r14
     b9f:	call   ba4 <botlish_fn_16+0x12c>
			ba0: R_X86_64_PLT32	rt_value_eq-0x4
     ba4:	test   rax,rax
     ba7:	jne    bc5 <botlish_fn_16+0x14d>
     bad:	mov    rdi,r14
     bb0:	jmp    d48 <botlish_fn_16+0x2d0>
     bb5:	mov    eax,0x2
     bba:	cmp    r12,rdx
     bbd:	cmove  rax,QWORD PTR [rip+0x253]        # e18 <botlish_fn_16+0x3a0>
     bc5:	mov    ebx,0x6
     bca:	cmp    rax,0x6
     bce:	je     dba <botlish_fn_16+0x342>
     bd4:	mov    rdi,r14
     bd7:	call   bdc <botlish_fn_16+0x164>
			bd8: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     bdc:	test   rax,rax
     bdf:	jne    bed <botlish_fn_16+0x175>
     be5:	mov    rdi,r14
     be8:	jmp    d48 <botlish_fn_16+0x2d0>
     bed:	mov    rcx,r12
     bf0:	and    rcx,rax
     bf3:	mov    rdx,rax
     bf6:	test   rcx,0x1
     bfd:	jne    c1f <botlish_fn_16+0x1a7>
     c03:	mov    rsi,r12
     c06:	mov    rdi,r14
     c09:	call   c0e <botlish_fn_16+0x196>
			c0a: R_X86_64_PLT32	rt_value_eq-0x4
     c0e:	test   rax,rax
     c11:	jne    c32 <botlish_fn_16+0x1ba>
     c17:	mov    rdi,r14
     c1a:	jmp    d48 <botlish_fn_16+0x2d0>
     c1f:	mov    rsi,r12
     c22:	mov    eax,0x2
     c27:	cmp    rsi,rdx
     c2a:	cmove  rax,QWORD PTR [rip+0x1e6]        # e18 <botlish_fn_16+0x3a0>
     c32:	cmp    rax,0x6
     c36:	je     c4a <botlish_fn_16+0x1d2>
     c3c:	mov    ebx,0x2
     c41:	mov    r12,QWORD PTR [rsp]
     c45:	jmp    d22 <botlish_fn_16+0x2aa>
     c4a:	mov    rsi,r15
     c4d:	mov    rdi,r14
     c50:	call   c55 <botlish_fn_16+0x1dd>
			c51: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     c55:	test   rax,rax
     c58:	jne    c66 <botlish_fn_16+0x1ee>
     c5e:	mov    rdi,r14
     c61:	jmp    d48 <botlish_fn_16+0x2d0>
     c66:	xor    ecx,ecx
     c68:	test   rax,0x7
     c6e:	je     c7c <botlish_fn_16+0x204>
     c74:	mov    rsi,rax
     c77:	jmp    c8a <botlish_fn_16+0x212>
     c7c:	movzx  rcx,BYTE PTR [rax]
     c80:	mov    rsi,rax
     c83:	rex cmp cl,0x8
     c87:	sete   cl
     c8a:	test   cl,cl
     c8c:	jne    caf <botlish_fn_16+0x237>
     c92:	mov    rdi,r14
     c95:	mov    rax,QWORD PTR [rdi+0x10]
     c99:	mov    rcx,QWORD PTR [rax+0x8]
     c9d:	mov    edx,0x8
     ca2:	call   ca7 <botlish_fn_16+0x22f>
			ca3: R_X86_64_PLT32	rt_type_error-0x4
     ca7:	mov    rdi,r14
     caa:	jmp    d48 <botlish_fn_16+0x2d0>
     caf:	mov    rdx,QWORD PTR [rsp+0x8]
     cb4:	mov    rdi,r14
     cb7:	call   cbc <botlish_fn_16+0x244>
			cb8: R_X86_64_PLT32	rt_mutarray_get-0x4
     cbc:	test   rax,rax
     cbf:	jne    ccd <botlish_fn_16+0x255>
     cc5:	mov    rdi,r14
     cc8:	jmp    d48 <botlish_fn_16+0x2d0>
     ccd:	mov    r12,QWORD PTR [rsp]
     cd1:	mov    rcx,rax
     cd4:	and    rcx,r12
     cd7:	mov    rsi,rax
     cda:	test   rcx,0x1
     ce1:	jne    d03 <botlish_fn_16+0x28b>
     ce7:	mov    rdx,r12
     cea:	mov    rdi,r14
     ced:	call   cf2 <botlish_fn_16+0x27a>
			cee: R_X86_64_PLT32	rt_value_eq-0x4
     cf2:	test   rax,rax
     cf5:	jne    d13 <botlish_fn_16+0x29b>
     cfb:	mov    rdi,r14
     cfe:	jmp    d48 <botlish_fn_16+0x2d0>
     d03:	mov    eax,0x2
     d08:	cmp    rsi,r12
     d0b:	cmove  rax,QWORD PTR [rip+0x105]        # e18 <botlish_fn_16+0x3a0>
     d13:	cmp    rax,0x6
     d17:	je     d22 <botlish_fn_16+0x2aa>
     d1d:	mov    ebx,0x2
     d22:	cmp    rbx,0x6
     d26:	je     d8d <botlish_fn_16+0x315>
     d2c:	mov    rdx,QWORD PTR [rsp+0x8]
     d31:	mov    rsi,r15
     d34:	mov    rdi,r14
     d37:	call   d3c <botlish_fn_16+0x2c4>
			d38: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     d3c:	test   rax,rax
     d3f:	jne    d73 <botlish_fn_16+0x2fb>
     d45:	mov    rdi,r14
     d48:	mov    rdi,r14
     d4b:	mov    QWORD PTR [rdi],r13
     d4e:	xor    rax,rax
     d51:	mov    rbx,QWORD PTR [rsp+0x10]
     d56:	mov    r12,QWORD PTR [rsp+0x18]
     d5b:	mov    r13,QWORD PTR [rsp+0x20]
     d60:	mov    r14,QWORD PTR [rsp+0x28]
     d65:	mov    r15,QWORD PTR [rsp+0x30]
     d6a:	add    rsp,0x40
     d6e:	mov    rsp,rbp
     d71:	pop    rbp
     d72:	ret
     d73:	mov    QWORD PTR [r13+0x0],r15
     d77:	mov    QWORD PTR [r13+0x8],r12
     d7b:	mov    QWORD PTR [r13+0x10],rax
     d7f:	mov    QWORD PTR [rsp],r12
     d83:	mov    QWORD PTR [rsp+0x8],rax
     d88:	jmp    ad7 <botlish_fn_16+0x5f>
     d8d:	mov    rdi,r14
     d90:	mov    QWORD PTR [rdi],r13
     d93:	mov    rax,QWORD PTR [rsp+0x8]
     d98:	mov    rbx,QWORD PTR [rsp+0x10]
     d9d:	mov    r12,QWORD PTR [rsp+0x18]
     da2:	mov    r13,QWORD PTR [rsp+0x20]
     da7:	mov    r14,QWORD PTR [rsp+0x28]
     dac:	mov    r15,QWORD PTR [rsp+0x30]
     db1:	add    rsp,0x40
     db5:	mov    rsp,rbp
     db8:	pop    rbp
     db9:	ret
     dba:	mov    rdi,r14
     dbd:	mov    QWORD PTR [rdi],r13
     dc0:	mov    rax,0xffffffffffffffff
     dc7:	mov    rbx,QWORD PTR [rsp+0x10]
     dcc:	mov    r12,QWORD PTR [rsp+0x18]
     dd1:	mov    r13,QWORD PTR [rsp+0x20]
     dd6:	mov    r14,QWORD PTR [rsp+0x28]
     ddb:	mov    r15,QWORD PTR [rsp+0x30]
     de0:	add    rsp,0x40
     de4:	mov    rsp,rbp
     de7:	pop    rbp
     de8:	ret
     de9:	mov    r14,rdi
     dec:	call   df1 <botlish_fn_16+0x379>
			ded: R_X86_64_PLT32	rt_stack_overflow-0x4
     df1:	xor    rax,rax
     df4:	mov    rbx,QWORD PTR [rsp+0x10]
     df9:	mov    r12,QWORD PTR [rsp+0x18]
     dfe:	mov    r13,QWORD PTR [rsp+0x20]
     e03:	mov    r14,QWORD PTR [rsp+0x28]
     e08:	mov    r15,QWORD PTR [rsp+0x30]
     e0d:	add    rsp,0x40
     e11:	mov    rsp,rbp
     e14:	pop    rbp
     e15:	ret
     e16:	add    BYTE PTR [rax],al
     e18:	(bad)
     e19:	add    BYTE PTR [rax],al
     e1b:	add    BYTE PTR [rax],al
     e1d:	add    BYTE PTR [rax],al
	...

0000000000000e20 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
     e20:	push   rbp
     e21:	mov    rbp,rsp
     e24:	mov    rsi,QWORD PTR [rdx]
     e27:	mov    r8,QWORD PTR [rdx+0x8]
     e2b:	mov    rcx,QWORD PTR [rdx+0x10]
     e2f:	mov    rdx,r8
     e32:	call   e37 <botlish_entry_16+0x17>
			e33: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
     e37:	mov    rsp,rbp
     e3a:	pop    rbp
     e3b:	ret
     e3c:	add    BYTE PTR [rax],al
	...

0000000000000e40 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
     e40:	push   rbp
     e41:	mov    rbp,rsp
     e44:	sub    rsp,0x50
     e48:	mov    QWORD PTR [rsp+0x20],rbx
     e4d:	mov    QWORD PTR [rsp+0x28],r12
     e52:	mov    QWORD PTR [rsp+0x30],r13
     e57:	mov    QWORD PTR [rsp+0x38],r14
     e5c:	mov    QWORD PTR [rsp+0x40],r15
     e61:	mov    r13,QWORD PTR [rdi]
     e64:	mov    rax,QWORD PTR [rdi+0x8]
     e68:	lea    r9,[r13+0x28]
     e6c:	cmp    r9,rax
     e6f:	ja     1390 <botlish_fn_17+0x550>
     e75:	lea    rax,[r13+0x28]
     e79:	mov    QWORD PTR [rdi],rax
     e7c:	mov    QWORD PTR [rsp],rdi
     e80:	mov    QWORD PTR [r13+0x20],0x0
     e88:	mov    QWORD PTR [r13+0x0],rsi
     e8c:	mov    QWORD PTR [r13+0x8],rdx
     e90:	mov    r14,rdx
     e93:	mov    QWORD PTR [r13+0x10],rcx
     e97:	mov    QWORD PTR [r13+0x18],r8
     e9b:	mov    rbx,rsi
     e9e:	mov    r15,r8
     ea1:	mov    QWORD PTR [rsp+0x8],rcx
     ea6:	mov    rsi,rbx
     ea9:	mov    rdi,QWORD PTR [rsp]
     ead:	call   eb2 <botlish_fn_17+0x72>
			eae: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     eb2:	test   rax,rax
     eb5:	jne    ec4 <botlish_fn_17+0x84>
     ebb:	mov    rdi,QWORD PTR [rsp]
     ebf:	jmp    1263 <botlish_fn_17+0x423>
     ec4:	xor    ecx,ecx
     ec6:	test   rax,0x7
     ecc:	je     eda <botlish_fn_17+0x9a>
     ed2:	mov    rsi,rax
     ed5:	jmp    ee8 <botlish_fn_17+0xa8>
     eda:	movzx  rcx,BYTE PTR [rax]
     ede:	mov    rsi,rax
     ee1:	rex cmp cl,0x8
     ee5:	sete   cl
     ee8:	test   cl,cl
     eea:	jne    f0f <botlish_fn_17+0xcf>
     ef0:	mov    rdi,QWORD PTR [rsp]
     ef4:	mov    rax,QWORD PTR [rdi+0x10]
     ef8:	mov    rcx,QWORD PTR [rax+0x8]
     efc:	mov    edx,0x8
     f01:	call   f06 <botlish_fn_17+0xc6>
			f02: R_X86_64_PLT32	rt_type_error-0x4
     f06:	mov    rdi,QWORD PTR [rsp]
     f0a:	jmp    1263 <botlish_fn_17+0x423>
     f0f:	mov    rdx,QWORD PTR [rsp+0x8]
     f14:	mov    rdi,QWORD PTR [rsp]
     f18:	call   f1d <botlish_fn_17+0xdd>
			f19: R_X86_64_PLT32	rt_mutarray_get-0x4
     f1d:	mov    rcx,rax
     f20:	mov    QWORD PTR [rsp+0x10],rax
     f25:	test   rax,rcx
     f28:	jne    f37 <botlish_fn_17+0xf7>
     f2e:	mov    rdi,QWORD PTR [rsp]
     f32:	jmp    1263 <botlish_fn_17+0x423>
     f37:	mov    rax,QWORD PTR [rsp+0x10]
     f3c:	mov    QWORD PTR [r13+0x20],rax
     f40:	mov    rdi,QWORD PTR [rsp]
     f44:	call   f49 <botlish_fn_17+0x109>
			f45: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     f49:	test   rax,rax
     f4c:	jne    f5b <botlish_fn_17+0x11b>
     f52:	mov    rdi,QWORD PTR [rsp]
     f56:	jmp    1263 <botlish_fn_17+0x423>
     f5b:	mov    rcx,QWORD PTR [rsp+0x10]
     f60:	and    rcx,rax
     f63:	mov    rdx,rax
     f66:	test   rcx,0x1
     f6d:	jne    f93 <botlish_fn_17+0x153>
     f73:	mov    rsi,QWORD PTR [rsp+0x10]
     f78:	mov    rdi,QWORD PTR [rsp]
     f7c:	call   f81 <botlish_fn_17+0x141>
			f7d: R_X86_64_PLT32	rt_value_eq-0x4
     f81:	test   rax,rax
     f84:	jne    fa8 <botlish_fn_17+0x168>
     f8a:	mov    rdi,QWORD PTR [rsp]
     f8e:	jmp    1263 <botlish_fn_17+0x423>
     f93:	mov    eax,0x2
     f98:	mov    rcx,QWORD PTR [rsp+0x10]
     f9d:	cmp    rcx,rdx
     fa0:	cmove  rax,QWORD PTR [rip+0x418]        # 13c0 <botlish_fn_17+0x580>
     fa8:	mov    r12d,0x6
     fae:	cmp    rax,0x6
     fb2:	je     12e1 <botlish_fn_17+0x4a1>
     fb8:	mov    rdi,QWORD PTR [rsp]
     fbc:	call   fc1 <botlish_fn_17+0x181>
			fbd: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     fc1:	test   rax,rax
     fc4:	jne    fd3 <botlish_fn_17+0x193>
     fca:	mov    rdi,QWORD PTR [rsp]
     fce:	jmp    1263 <botlish_fn_17+0x423>
     fd3:	mov    rcx,QWORD PTR [rsp+0x10]
     fd8:	and    rcx,rax
     fdb:	mov    rdx,rax
     fde:	test   rcx,0x1
     fe5:	jne    100b <botlish_fn_17+0x1cb>
     feb:	mov    rsi,QWORD PTR [rsp+0x10]
     ff0:	mov    rdi,QWORD PTR [rsp]
     ff4:	call   ff9 <botlish_fn_17+0x1b9>
			ff5: R_X86_64_PLT32	rt_value_eq-0x4
     ff9:	test   rax,rax
     ffc:	jne    1020 <botlish_fn_17+0x1e0>
    1002:	mov    rdi,QWORD PTR [rsp]
    1006:	jmp    1263 <botlish_fn_17+0x423>
    100b:	mov    eax,0x2
    1010:	mov    rsi,QWORD PTR [rsp+0x10]
    1015:	cmp    rsi,rdx
    1018:	cmove  rax,QWORD PTR [rip+0x3a0]        # 13c0 <botlish_fn_17+0x580>
    1020:	cmp    rax,0x6
    1024:	je     1034 <botlish_fn_17+0x1f4>
    102a:	mov    eax,0x2
    102f:	jmp    1118 <botlish_fn_17+0x2d8>
    1034:	mov    rsi,rbx
    1037:	mov    rdi,QWORD PTR [rsp]
    103b:	call   1040 <botlish_fn_17+0x200>
			103c: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    1040:	test   rax,rax
    1043:	jne    1052 <botlish_fn_17+0x212>
    1049:	mov    rdi,QWORD PTR [rsp]
    104d:	jmp    1263 <botlish_fn_17+0x423>
    1052:	xor    ecx,ecx
    1054:	test   rax,0x7
    105a:	je     1068 <botlish_fn_17+0x228>
    1060:	mov    rsi,rax
    1063:	jmp    1076 <botlish_fn_17+0x236>
    1068:	movzx  rcx,BYTE PTR [rax]
    106c:	mov    rsi,rax
    106f:	rex cmp cl,0x8
    1073:	sete   cl
    1076:	test   cl,cl
    1078:	jne    109d <botlish_fn_17+0x25d>
    107e:	mov    rdi,QWORD PTR [rsp]
    1082:	mov    rax,QWORD PTR [rdi+0x10]
    1086:	mov    rcx,QWORD PTR [rax+0x8]
    108a:	mov    edx,0x8
    108f:	call   1094 <botlish_fn_17+0x254>
			1090: R_X86_64_PLT32	rt_type_error-0x4
    1094:	mov    rdi,QWORD PTR [rsp]
    1098:	jmp    1263 <botlish_fn_17+0x423>
    109d:	mov    rdx,QWORD PTR [rsp+0x8]
    10a2:	mov    rdi,QWORD PTR [rsp]
    10a6:	call   10ab <botlish_fn_17+0x26b>
			10a7: R_X86_64_PLT32	rt_mutarray_get-0x4
    10ab:	test   rax,rax
    10ae:	jne    10bd <botlish_fn_17+0x27d>
    10b4:	mov    rdi,QWORD PTR [rsp]
    10b8:	jmp    1263 <botlish_fn_17+0x423>
    10bd:	mov    rcx,rax
    10c0:	and    rcx,r14
    10c3:	mov    rsi,rax
    10c6:	test   rcx,0x1
    10cd:	jne    10f1 <botlish_fn_17+0x2b1>
    10d3:	mov    rdx,r14
    10d6:	mov    rdi,QWORD PTR [rsp]
    10da:	call   10df <botlish_fn_17+0x29f>
			10db: R_X86_64_PLT32	rt_value_eq-0x4
    10df:	test   rax,rax
    10e2:	jne    1101 <botlish_fn_17+0x2c1>
    10e8:	mov    rdi,QWORD PTR [rsp]
    10ec:	jmp    1263 <botlish_fn_17+0x423>
    10f1:	mov    eax,0x2
    10f6:	cmp    rsi,r14
    10f9:	cmove  rax,QWORD PTR [rip+0x2bf]        # 13c0 <botlish_fn_17+0x580>
    1101:	cmp    rax,0x6
    1105:	je     1115 <botlish_fn_17+0x2d5>
    110b:	mov    eax,0x2
    1110:	jmp    1118 <botlish_fn_17+0x2d8>
    1115:	mov    rax,r12
    1118:	cmp    rax,0x6
    111c:	je     12b3 <botlish_fn_17+0x473>
    1122:	mov    rdi,QWORD PTR [rsp]
    1126:	call   112b <botlish_fn_17+0x2eb>
			1127: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    112b:	test   rax,rax
    112e:	jne    113d <botlish_fn_17+0x2fd>
    1134:	mov    rdi,QWORD PTR [rsp]
    1138:	jmp    1263 <botlish_fn_17+0x423>
    113d:	mov    rcx,QWORD PTR [rsp+0x10]
    1142:	mov    rdx,rcx
    1145:	and    rdx,rax
    1148:	mov    r11,rax
    114b:	test   rdx,0x1
    1152:	jne    117b <botlish_fn_17+0x33b>
    1158:	mov    rdx,r11
    115b:	mov    rsi,QWORD PTR [rsp+0x10]
    1160:	mov    rdi,QWORD PTR [rsp]
    1164:	call   1169 <botlish_fn_17+0x329>
			1165: R_X86_64_PLT32	rt_value_eq-0x4
    1169:	test   rax,rax
    116c:	jne    1193 <botlish_fn_17+0x353>
    1172:	mov    rdi,QWORD PTR [rsp]
    1176:	jmp    1263 <botlish_fn_17+0x423>
    117b:	mov    rdx,r11
    117e:	mov    rsi,QWORD PTR [rsp+0x10]
    1183:	mov    eax,0x2
    1188:	cmp    rsi,rdx
    118b:	cmove  rax,QWORD PTR [rip+0x22d]        # 13c0 <botlish_fn_17+0x580>
    1193:	cmp    rax,0x6
    1197:	je     11a8 <botlish_fn_17+0x368>
    119d:	mov    r12d,0x2
    11a3:	jmp    11fb <botlish_fn_17+0x3bb>
    11a8:	test   r15,0x1
    11af:	jne    11db <botlish_fn_17+0x39b>
    11b5:	mov    edx,0x1
    11ba:	mov    rsi,r15
    11bd:	mov    rdi,QWORD PTR [rsp]
    11c1:	call   11c6 <botlish_fn_17+0x386>
			11c2: R_X86_64_PLT32	rt_int_cmp-0x4
    11c6:	mov    ecx,0x2
    11cb:	test   rax,rax
    11ce:	cmovl  rcx,QWORD PTR [rip+0x1ea]        # 13c0 <botlish_fn_17+0x580>
    11d6:	jmp    11eb <botlish_fn_17+0x3ab>
    11db:	mov    ecx,0x2
    11e0:	test   r15,r15
    11e3:	cmovle rcx,QWORD PTR [rip+0x1d5]        # 13c0 <botlish_fn_17+0x580>
    11eb:	cmp    rcx,0x6
    11ef:	je     11fb <botlish_fn_17+0x3bb>
    11f5:	mov    r12d,0x2
    11fb:	cmp    r12,0x6
    11ff:	je     1245 <botlish_fn_17+0x405>
    1205:	mov    rdx,QWORD PTR [rsp+0x8]
    120a:	mov    rsi,rbx
    120d:	mov    rdi,QWORD PTR [rsp]
    1211:	call   1216 <botlish_fn_17+0x3d6>
			1212: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    1216:	test   rax,rax
    1219:	jne    1228 <botlish_fn_17+0x3e8>
    121f:	mov    rdi,QWORD PTR [rsp]
    1223:	jmp    1263 <botlish_fn_17+0x423>
    1228:	mov    QWORD PTR [r13+0x0],rbx
    122c:	mov    QWORD PTR [r13+0x8],r14
    1230:	mov    QWORD PTR [r13+0x10],rax
    1234:	mov    rcx,r15
    1237:	mov    QWORD PTR [r13+0x18],rcx
    123b:	mov    QWORD PTR [rsp+0x8],rax
    1240:	jmp    ea6 <botlish_fn_17+0x66>
    1245:	mov    rdx,QWORD PTR [rsp+0x8]
    124a:	mov    rsi,rbx
    124d:	mov    rdi,QWORD PTR [rsp]
    1251:	call   1256 <botlish_fn_17+0x416>
			1252: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    1256:	test   rax,rax
    1259:	jne    128f <botlish_fn_17+0x44f>
    125f:	mov    rdi,QWORD PTR [rsp]
    1263:	mov    rdi,QWORD PTR [rsp]
    1267:	mov    QWORD PTR [rdi],r13
    126a:	xor    rax,rax
    126d:	mov    rbx,QWORD PTR [rsp+0x20]
    1272:	mov    r12,QWORD PTR [rsp+0x28]
    1277:	mov    r13,QWORD PTR [rsp+0x30]
    127c:	mov    r14,QWORD PTR [rsp+0x38]
    1281:	mov    r15,QWORD PTR [rsp+0x40]
    1286:	add    rsp,0x50
    128a:	mov    rsp,rbp
    128d:	pop    rbp
    128e:	ret
    128f:	mov    QWORD PTR [r13+0x0],rbx
    1293:	mov    QWORD PTR [r13+0x8],r14
    1297:	mov    QWORD PTR [r13+0x10],rax
    129b:	mov    rdx,QWORD PTR [rsp+0x8]
    12a0:	mov    QWORD PTR [r13+0x18],rdx
    12a4:	mov    r15,QWORD PTR [rsp+0x8]
    12a9:	mov    QWORD PTR [rsp+0x8],rax
    12ae:	jmp    ea6 <botlish_fn_17+0x66>
    12b3:	mov    rdi,QWORD PTR [rsp]
    12b7:	mov    QWORD PTR [rdi],r13
    12ba:	mov    rax,QWORD PTR [rsp+0x8]
    12bf:	mov    rbx,QWORD PTR [rsp+0x20]
    12c4:	mov    r12,QWORD PTR [rsp+0x28]
    12c9:	mov    r13,QWORD PTR [rsp+0x30]
    12ce:	mov    r14,QWORD PTR [rsp+0x38]
    12d3:	mov    r15,QWORD PTR [rsp+0x40]
    12d8:	add    rsp,0x50
    12dc:	mov    rsp,rbp
    12df:	pop    rbp
    12e0:	ret
    12e1:	mov    rax,r15
    12e4:	test   rax,0x1
    12ea:	jne    1316 <botlish_fn_17+0x4d6>
    12f0:	mov    edx,0x1
    12f5:	mov    rsi,r15
    12f8:	mov    rdi,QWORD PTR [rsp]
    12fc:	call   1301 <botlish_fn_17+0x4c1>
			12fd: R_X86_64_PLT32	rt_int_cmp-0x4
    1301:	mov    ecx,0x2
    1306:	test   rax,rax
    1309:	cmovge rcx,QWORD PTR [rip+0xaf]        # 13c0 <botlish_fn_17+0x580>
    1311:	jmp    132c <botlish_fn_17+0x4ec>
    1316:	mov    ecx,0x2
    131b:	mov    rax,r15
    131e:	mov    r10,r15
    1321:	test   rax,r10
    1324:	cmovg  rcx,QWORD PTR [rip+0x94]        # 13c0 <botlish_fn_17+0x580>
    132c:	cmp    rcx,0x6
    1330:	je     1364 <botlish_fn_17+0x524>
    1336:	mov    rdi,QWORD PTR [rsp]
    133a:	mov    QWORD PTR [rdi],r13
    133d:	mov    rax,QWORD PTR [rsp+0x8]
    1342:	mov    rbx,QWORD PTR [rsp+0x20]
    1347:	mov    r12,QWORD PTR [rsp+0x28]
    134c:	mov    r13,QWORD PTR [rsp+0x30]
    1351:	mov    r14,QWORD PTR [rsp+0x38]
    1356:	mov    r15,QWORD PTR [rsp+0x40]
    135b:	add    rsp,0x50
    135f:	mov    rsp,rbp
    1362:	pop    rbp
    1363:	ret
    1364:	mov    rdi,QWORD PTR [rsp]
    1368:	mov    QWORD PTR [rdi],r13
    136b:	mov    rax,r15
    136e:	mov    rbx,QWORD PTR [rsp+0x20]
    1373:	mov    r12,QWORD PTR [rsp+0x28]
    1378:	mov    r13,QWORD PTR [rsp+0x30]
    137d:	mov    r14,QWORD PTR [rsp+0x38]
    1382:	mov    r15,QWORD PTR [rsp+0x40]
    1387:	add    rsp,0x50
    138b:	mov    rsp,rbp
    138e:	pop    rbp
    138f:	ret
    1390:	mov    QWORD PTR [rsp],rdi
    1394:	call   1399 <botlish_fn_17+0x559>
			1395: R_X86_64_PLT32	rt_stack_overflow-0x4
    1399:	xor    rax,rax
    139c:	mov    rbx,QWORD PTR [rsp+0x20]
    13a1:	mov    r12,QWORD PTR [rsp+0x28]
    13a6:	mov    r13,QWORD PTR [rsp+0x30]
    13ab:	mov    r14,QWORD PTR [rsp+0x38]
    13b0:	mov    r15,QWORD PTR [rsp+0x40]
    13b5:	add    rsp,0x50
    13b9:	mov    rsp,rbp
    13bc:	pop    rbp
    13bd:	ret
    13be:	add    BYTE PTR [rax],al
    13c0:	(bad)
    13c1:	add    BYTE PTR [rax],al
    13c3:	add    BYTE PTR [rax],al
    13c5:	add    BYTE PTR [rax],al
	...

00000000000013c8 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
    13c8:	push   rbp
    13c9:	mov    rbp,rsp
    13cc:	mov    rsi,QWORD PTR [rdx]
    13cf:	mov    r9,QWORD PTR [rdx+0x8]
    13d3:	mov    rcx,QWORD PTR [rdx+0x10]
    13d7:	mov    r8,QWORD PTR [rdx+0x18]
    13db:	mov    rdx,r9
    13de:	call   13e3 <botlish_entry_17+0x1b>
			13df: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    13e3:	mov    rsp,rbp
    13e6:	pop    rbp
    13e7:	ret

00000000000013e8 <botlish_fn_18: ht_get<mutarray, str>>:
    13e8:	push   rbp
    13e9:	mov    rbp,rsp
    13ec:	sub    rsp,0x20
    13f0:	mov    QWORD PTR [rsp],rbx
    13f4:	mov    QWORD PTR [rsp+0x8],r12
    13f9:	mov    QWORD PTR [rsp+0x10],r13
    13fe:	mov    QWORD PTR [rsp+0x18],r14
    1403:	mov    rbx,QWORD PTR [rdi]
    1406:	mov    rax,QWORD PTR [rdi+0x8]
    140a:	lea    rcx,[rbx+0x18]
    140e:	cmp    rcx,rax
    1411:	ja     15bb <botlish_fn_18+0x1d3>
    1417:	lea    rax,[rbx+0x18]
    141b:	mov    QWORD PTR [rdi],rax
    141e:	mov    r12,rdi
    1421:	mov    QWORD PTR [rbx+0x10],0x0
    1429:	mov    QWORD PTR [rbx],rsi
    142c:	mov    r13,rsi
    142f:	mov    QWORD PTR [rbx+0x8],rdx
    1433:	mov    r14,rdx
    1436:	mov    rdx,r14
    1439:	mov    rsi,r13
    143c:	mov    rdi,r12
    143f:	call   1444 <botlish_fn_18+0x5c>
			1440: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    1444:	test   rax,rax
    1447:	jne    1455 <botlish_fn_18+0x6d>
    144d:	mov    rdi,r12
    1450:	jmp    154d <botlish_fn_18+0x165>
    1455:	mov    QWORD PTR [rbx+0x10],rax
    1459:	mov    rcx,rax
    145c:	mov    rdx,r14
    145f:	mov    rsi,r13
    1462:	mov    rdi,r12
    1465:	call   146a <botlish_fn_18+0x82>
			1466: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    146a:	mov    r10,rax
    146d:	mov    r14,rax
    1470:	test   rax,r10
    1473:	jne    1481 <botlish_fn_18+0x99>
    1479:	mov    rdi,r12
    147c:	jmp    154d <botlish_fn_18+0x165>
    1481:	mov    rax,r14
    1484:	mov    QWORD PTR [rbx+0x8],rax
    1488:	test   rax,0x1
    148e:	jne    14b9 <botlish_fn_18+0xd1>
    1494:	mov    edx,0x1
    1499:	mov    rsi,r14
    149c:	mov    rdi,r12
    149f:	call   14a4 <botlish_fn_18+0xbc>
			14a0: R_X86_64_PLT32	rt_int_cmp-0x4
    14a4:	mov    ecx,0x2
    14a9:	test   rax,rax
    14ac:	cmovl  rcx,QWORD PTR [rip+0x134]        # 15e8 <botlish_fn_18+0x200>
    14b4:	jmp    14cc <botlish_fn_18+0xe4>
    14b9:	mov    ecx,0x2
    14be:	mov    rax,r14
    14c1:	test   rax,rax
    14c4:	cmovle rcx,QWORD PTR [rip+0x11c]        # 15e8 <botlish_fn_18+0x200>
    14cc:	cmp    rcx,0x6
    14d0:	je     1594 <botlish_fn_18+0x1ac>
    14d6:	mov    rsi,r13
    14d9:	mov    rdi,r12
    14dc:	call   14e1 <botlish_fn_18+0xf9>
			14dd: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    14e1:	test   rax,rax
    14e4:	jne    14f2 <botlish_fn_18+0x10a>
    14ea:	mov    rdi,r12
    14ed:	jmp    154d <botlish_fn_18+0x165>
    14f2:	xor    ecx,ecx
    14f4:	test   rax,0x7
    14fa:	jne    150b <botlish_fn_18+0x123>
    1500:	movzx  rcx,BYTE PTR [rax]
    1504:	rex cmp cl,0x8
    1508:	sete   cl
    150b:	test   cl,cl
    150d:	jne    1533 <botlish_fn_18+0x14b>
    1513:	mov    rdi,r12
    1516:	mov    rsi,QWORD PTR [rdi+0x10]
    151a:	mov    rcx,QWORD PTR [rsi+0x8]
    151e:	mov    edx,0x8
    1523:	mov    rsi,rax
    1526:	call   152b <botlish_fn_18+0x143>
			1527: R_X86_64_PLT32	rt_type_error-0x4
    152b:	mov    rdi,r12
    152e:	jmp    154d <botlish_fn_18+0x165>
    1533:	mov    rdx,r14
    1536:	mov    rsi,rax
    1539:	mov    rdi,r12
    153c:	call   1541 <botlish_fn_18+0x159>
			153d: R_X86_64_PLT32	rt_mutarray_get-0x4
    1541:	test   rax,rax
    1544:	jne    1572 <botlish_fn_18+0x18a>
    154a:	mov    rdi,r12
    154d:	mov    rdi,r12
    1550:	mov    QWORD PTR [rdi],rbx
    1553:	xor    rax,rax
    1556:	mov    rbx,QWORD PTR [rsp]
    155a:	mov    r12,QWORD PTR [rsp+0x8]
    155f:	mov    r13,QWORD PTR [rsp+0x10]
    1564:	mov    r14,QWORD PTR [rsp+0x18]
    1569:	add    rsp,0x20
    156d:	mov    rsp,rbp
    1570:	pop    rbp
    1571:	ret
    1572:	mov    rdi,r12
    1575:	mov    QWORD PTR [rdi],rbx
    1578:	mov    rbx,QWORD PTR [rsp]
    157c:	mov    r12,QWORD PTR [rsp+0x8]
    1581:	mov    r13,QWORD PTR [rsp+0x10]
    1586:	mov    r14,QWORD PTR [rsp+0x18]
    158b:	add    rsp,0x20
    158f:	mov    rsp,rbp
    1592:	pop    rbp
    1593:	ret
    1594:	mov    rdi,r12
    1597:	mov    QWORD PTR [rdi],rbx
    159a:	mov    eax,0xa
    159f:	mov    rbx,QWORD PTR [rsp]
    15a3:	mov    r12,QWORD PTR [rsp+0x8]
    15a8:	mov    r13,QWORD PTR [rsp+0x10]
    15ad:	mov    r14,QWORD PTR [rsp+0x18]
    15b2:	add    rsp,0x20
    15b6:	mov    rsp,rbp
    15b9:	pop    rbp
    15ba:	ret
    15bb:	mov    r12,rdi
    15be:	call   15c3 <botlish_fn_18+0x1db>
			15bf: R_X86_64_PLT32	rt_stack_overflow-0x4
    15c3:	xor    rax,rax
    15c6:	mov    rbx,QWORD PTR [rsp]
    15ca:	mov    r12,QWORD PTR [rsp+0x8]
    15cf:	mov    r13,QWORD PTR [rsp+0x10]
    15d4:	mov    r14,QWORD PTR [rsp+0x18]
    15d9:	add    rsp,0x20
    15dd:	mov    rsp,rbp
    15e0:	pop    rbp
    15e1:	ret
    15e2:	add    BYTE PTR [rax],al
    15e4:	add    BYTE PTR [rax],al
    15e6:	add    BYTE PTR [rax],al
    15e8:	(bad)
    15e9:	add    BYTE PTR [rax],al
    15eb:	add    BYTE PTR [rax],al
    15ed:	add    BYTE PTR [rax],al
	...

00000000000015f0 <botlish_entry_18: ht_get<mutarray, str>>:
    15f0:	push   rbp
    15f1:	mov    rbp,rsp
    15f4:	mov    rsi,QWORD PTR [rdx]
    15f7:	mov    rdx,QWORD PTR [rdx+0x8]
    15fb:	call   1600 <botlish_entry_18+0x10>
			15fc: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    1600:	mov    rsp,rbp
    1603:	pop    rbp
    1604:	ret
    1605:	add    BYTE PTR [rax],al
	...

0000000000001608 <botlish_fn_19: ht_contains<mutarray, str>>:
    1608:	push   rbp
    1609:	mov    rbp,rsp
    160c:	sub    rsp,0x20
    1610:	mov    QWORD PTR [rsp],rbx
    1614:	mov    QWORD PTR [rsp+0x8],r12
    1619:	mov    QWORD PTR [rsp+0x10],r13
    161e:	mov    QWORD PTR [rsp+0x18],r14
    1623:	mov    rbx,QWORD PTR [rdi]
    1626:	mov    rax,QWORD PTR [rdi+0x8]
    162a:	lea    rcx,[rbx+0x18]
    162e:	cmp    rcx,rax
    1631:	ja     1727 <botlish_fn_19+0x11f>
    1637:	lea    rax,[rbx+0x18]
    163b:	mov    QWORD PTR [rdi],rax
    163e:	mov    r12,rdi
    1641:	mov    QWORD PTR [rbx+0x10],0x0
    1649:	mov    QWORD PTR [rbx],rsi
    164c:	mov    r14,rsi
    164f:	mov    QWORD PTR [rbx+0x8],rdx
    1653:	mov    r13,rdx
    1656:	mov    rdx,r13
    1659:	mov    rsi,r14
    165c:	mov    rdi,r12
    165f:	call   1664 <botlish_fn_19+0x5c>
			1660: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    1664:	test   rax,rax
    1667:	jne    1675 <botlish_fn_19+0x6d>
    166d:	mov    rdi,r12
    1670:	jmp    1696 <botlish_fn_19+0x8e>
    1675:	mov    QWORD PTR [rbx+0x10],rax
    1679:	mov    rcx,rax
    167c:	mov    rdx,r13
    167f:	mov    rsi,r14
    1682:	mov    rdi,r12
    1685:	call   168a <botlish_fn_19+0x82>
			1686: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    168a:	test   rax,rax
    168d:	jne    16bb <botlish_fn_19+0xb3>
    1693:	mov    rdi,r12
    1696:	mov    rdi,r12
    1699:	mov    QWORD PTR [rdi],rbx
    169c:	xor    rax,rax
    169f:	mov    rbx,QWORD PTR [rsp]
    16a3:	mov    r12,QWORD PTR [rsp+0x8]
    16a8:	mov    r13,QWORD PTR [rsp+0x10]
    16ad:	mov    r14,QWORD PTR [rsp+0x18]
    16b2:	add    rsp,0x20
    16b6:	mov    rsp,rbp
    16b9:	pop    rbp
    16ba:	ret
    16bb:	test   rax,0x1
    16c1:	mov    rsi,rax
    16c4:	jne    16f2 <botlish_fn_19+0xea>
    16ca:	mov    edx,0x1
    16cf:	mov    rdi,r12
    16d2:	call   16d7 <botlish_fn_19+0xcf>
			16d3: R_X86_64_PLT32	rt_int_cmp-0x4
    16d7:	mov    ecx,0x2
    16dc:	test   rax,rax
    16df:	mov    rax,rcx
    16e2:	cmovge rax,QWORD PTR [rip+0x66]        # 1750 <botlish_fn_19+0x148>
    16ea:	mov    rdi,r12
    16ed:	jmp    1705 <botlish_fn_19+0xfd>
    16f2:	mov    eax,0x2
    16f7:	test   rsi,rsi
    16fa:	cmovg  rax,QWORD PTR [rip+0x4e]        # 1750 <botlish_fn_19+0x148>
    1702:	mov    rdi,r12
    1705:	mov    rdi,r12
    1708:	mov    QWORD PTR [rdi],rbx
    170b:	mov    rbx,QWORD PTR [rsp]
    170f:	mov    r12,QWORD PTR [rsp+0x8]
    1714:	mov    r13,QWORD PTR [rsp+0x10]
    1719:	mov    r14,QWORD PTR [rsp+0x18]
    171e:	add    rsp,0x20
    1722:	mov    rsp,rbp
    1725:	pop    rbp
    1726:	ret
    1727:	mov    r12,rdi
    172a:	call   172f <botlish_fn_19+0x127>
			172b: R_X86_64_PLT32	rt_stack_overflow-0x4
    172f:	xor    rax,rax
    1732:	mov    rbx,QWORD PTR [rsp]
    1736:	mov    r12,QWORD PTR [rsp+0x8]
    173b:	mov    r13,QWORD PTR [rsp+0x10]
    1740:	mov    r14,QWORD PTR [rsp+0x18]
    1745:	add    rsp,0x20
    1749:	mov    rsp,rbp
    174c:	pop    rbp
    174d:	ret
    174e:	add    BYTE PTR [rax],al
    1750:	(bad)
    1751:	add    BYTE PTR [rax],al
    1753:	add    BYTE PTR [rax],al
    1755:	add    BYTE PTR [rax],al
	...

0000000000001758 <botlish_entry_19: ht_contains<mutarray, str>>:
    1758:	push   rbp
    1759:	mov    rbp,rsp
    175c:	mov    rsi,QWORD PTR [rdx]
    175f:	mov    rdx,QWORD PTR [rdx+0x8]
    1763:	call   1768 <botlish_entry_19+0x10>
			1764: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    1768:	mov    rsp,rbp
    176b:	pop    rbp
    176c:	ret
    176d:	add    BYTE PTR [rax],al
	...

0000000000001770 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    1770:	push   rbp
    1771:	mov    rbp,rsp
    1774:	sub    rsp,0x40
    1778:	mov    QWORD PTR [rsp+0x10],rbx
    177d:	mov    QWORD PTR [rsp+0x18],r12
    1782:	mov    QWORD PTR [rsp+0x20],r13
    1787:	mov    QWORD PTR [rsp+0x28],r14
    178c:	mov    QWORD PTR [rsp+0x30],r15
    1791:	mov    r12,QWORD PTR [rdi]
    1794:	mov    rax,QWORD PTR [rdi+0x8]
    1798:	lea    r8,[r12+0x20]
    179d:	cmp    r8,rax
    17a0:	ja     191f <botlish_fn_20+0x1af>
    17a6:	lea    rax,[r12+0x20]
    17ab:	mov    QWORD PTR [rdi],rax
    17ae:	mov    r13,rdi
    17b1:	mov    QWORD PTR [r12],rsi
    17b5:	mov    QWORD PTR [r12+0x8],rdx
    17ba:	mov    QWORD PTR [r12+0x10],rcx
    17bf:	mov    r15,rcx
    17c2:	mov    rbx,rsi
    17c5:	mov    r14,rdx
    17c8:	mov    rdx,r14
    17cb:	mov    rsi,rbx
    17ce:	mov    rdi,r13
    17d1:	call   17d6 <botlish_fn_20+0x66>
			17d2: R_X86_64_PLT32	rt_mutarray_get-0x4
    17d6:	test   rax,rax
    17d9:	jne    17e7 <botlish_fn_20+0x77>
    17df:	mov    rdi,r13
    17e2:	jmp    18b3 <botlish_fn_20+0x143>
    17e7:	mov    QWORD PTR [r12+0x18],rax
    17ec:	mov    QWORD PTR [rsp],rax
    17f0:	mov    rdi,r13
    17f3:	call   17f8 <botlish_fn_20+0x88>
			17f4: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    17f8:	test   rax,rax
    17fb:	jne    1809 <botlish_fn_20+0x99>
    1801:	mov    rdi,r13
    1804:	jmp    18b3 <botlish_fn_20+0x143>
    1809:	mov    rsi,QWORD PTR [rsp]
    180d:	mov    rcx,rsi
    1810:	and    rcx,rax
    1813:	mov    rdx,rax
    1816:	test   rcx,0x1
    181d:	jne    1840 <botlish_fn_20+0xd0>
    1823:	mov    rsi,QWORD PTR [rsp]
    1827:	mov    rdi,r13
    182a:	call   182f <botlish_fn_20+0xbf>
			182b: R_X86_64_PLT32	rt_value_eq-0x4
    182f:	test   rax,rax
    1832:	jne    1854 <botlish_fn_20+0xe4>
    1838:	mov    rdi,r13
    183b:	jmp    18b3 <botlish_fn_20+0x143>
    1840:	mov    rsi,QWORD PTR [rsp]
    1844:	mov    eax,0x2
    1849:	cmp    rsi,rdx
    184c:	cmove  rax,QWORD PTR [rip+0xfc]        # 1950 <botlish_fn_20+0x1e0>
    1854:	cmp    rax,0x6
    1858:	je     18f4 <botlish_fn_20+0x184>
    185e:	mov    QWORD PTR [r12+0x18],0x3
    1867:	mov    rsi,r14
    186a:	test   rsi,0x1
    1871:	je     1889 <botlish_fn_20+0x119>
    1877:	mov    rsi,r14
    187a:	add    rsi,0x2
    187e:	seto   al
    1881:	test   al,al
    1883:	je     189c <botlish_fn_20+0x12c>
    1889:	mov    edx,0x3
    188e:	mov    rsi,r14
    1891:	mov    rdi,r13
    1894:	call   1899 <botlish_fn_20+0x129>
			1895: R_X86_64_PLT32	rt_int_add-0x4
    1899:	mov    rsi,rax
    189c:	mov    rdx,r15
    189f:	mov    rdi,r13
    18a2:	call   18a7 <botlish_fn_20+0x137>
			18a3: R_X86_64_PLT32	rt_int_mod-0x4
    18a7:	test   rax,rax
    18aa:	jne    18de <botlish_fn_20+0x16e>
    18b0:	mov    rdi,r13
    18b3:	mov    rdi,r13
    18b6:	mov    QWORD PTR [rdi],r12
    18b9:	xor    rax,rax
    18bc:	mov    rbx,QWORD PTR [rsp+0x10]
    18c1:	mov    r12,QWORD PTR [rsp+0x18]
    18c6:	mov    r13,QWORD PTR [rsp+0x20]
    18cb:	mov    r14,QWORD PTR [rsp+0x28]
    18d0:	mov    r15,QWORD PTR [rsp+0x30]
    18d5:	add    rsp,0x40
    18d9:	mov    rsp,rbp
    18dc:	pop    rbp
    18dd:	ret
    18de:	mov    QWORD PTR [r12],rbx
    18e2:	mov    QWORD PTR [r12+0x8],rax
    18e7:	mov    QWORD PTR [r12+0x10],r15
    18ec:	mov    r14,rax
    18ef:	jmp    17c8 <botlish_fn_20+0x58>
    18f4:	mov    rdi,r13
    18f7:	mov    QWORD PTR [rdi],r12
    18fa:	mov    rax,r14
    18fd:	mov    rbx,QWORD PTR [rsp+0x10]
    1902:	mov    r12,QWORD PTR [rsp+0x18]
    1907:	mov    r13,QWORD PTR [rsp+0x20]
    190c:	mov    r14,QWORD PTR [rsp+0x28]
    1911:	mov    r15,QWORD PTR [rsp+0x30]
    1916:	add    rsp,0x40
    191a:	mov    rsp,rbp
    191d:	pop    rbp
    191e:	ret
    191f:	mov    r13,rdi
    1922:	call   1927 <botlish_fn_20+0x1b7>
			1923: R_X86_64_PLT32	rt_stack_overflow-0x4
    1927:	xor    rax,rax
    192a:	mov    rbx,QWORD PTR [rsp+0x10]
    192f:	mov    r12,QWORD PTR [rsp+0x18]
    1934:	mov    r13,QWORD PTR [rsp+0x20]
    1939:	mov    r14,QWORD PTR [rsp+0x28]
    193e:	mov    r15,QWORD PTR [rsp+0x30]
    1943:	add    rsp,0x40
    1947:	mov    rsp,rbp
    194a:	pop    rbp
    194b:	ret
    194c:	add    BYTE PTR [rax],al
    194e:	add    BYTE PTR [rax],al
    1950:	(bad)
    1951:	add    BYTE PTR [rax],al
    1953:	add    BYTE PTR [rax],al
    1955:	add    BYTE PTR [rax],al
	...

0000000000001958 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    1958:	push   rbp
    1959:	mov    rbp,rsp
    195c:	mov    rsi,QWORD PTR [rdx]
    195f:	mov    r8,QWORD PTR [rdx+0x8]
    1963:	mov    rcx,QWORD PTR [rdx+0x10]
    1967:	mov    rdx,r8
    196a:	call   196f <botlish_entry_20+0x17>
			196b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    196f:	mov    rsp,rbp
    1972:	pop    rbp
    1973:	ret

0000000000001974 <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1974:	push   rbp
    1975:	mov    rbp,rsp
    1978:	sub    rsp,0x50
    197c:	mov    QWORD PTR [rsp+0x20],rbx
    1981:	mov    QWORD PTR [rsp+0x28],r12
    1986:	mov    QWORD PTR [rsp+0x30],r13
    198b:	mov    QWORD PTR [rsp+0x38],r14
    1990:	mov    QWORD PTR [rsp+0x40],r15
    1995:	mov    r10,QWORD PTR [rbp+0x10]
    1999:	mov    rbx,QWORD PTR [rdi]
    199c:	mov    rax,QWORD PTR [rdi+0x8]
    19a0:	lea    r11,[rbx+0x38]
    19a4:	cmp    r11,rax
    19a7:	ja     1b2f <botlish_fn_21+0x1bb>
    19ad:	lea    rax,[rbx+0x38]
    19b1:	mov    QWORD PTR [rdi],rax
    19b4:	mov    r12,rdi
    19b7:	mov    QWORD PTR [rbx],rsi
    19ba:	mov    QWORD PTR [rsp],rsi
    19be:	mov    QWORD PTR [rbx+0x8],rdx
    19c2:	mov    QWORD PTR [rsp+0x8],rdx
    19c7:	mov    QWORD PTR [rbx+0x10],rcx
    19cb:	mov    r13,rcx
    19ce:	mov    QWORD PTR [rbx+0x18],r8
    19d2:	mov    QWORD PTR [rsp+0x10],r8
    19d7:	mov    QWORD PTR [rbx+0x20],r9
    19db:	mov    r15,r9
    19de:	mov    QWORD PTR [rbx+0x28],r10
    19e2:	mov    r14,r10
    19e5:	mov    rsi,r15
    19e8:	mov    rdi,r12
    19eb:	call   19f0 <botlish_fn_21+0x7c>
			19ec: R_X86_64_PLT32	rt_hash-0x4
    19f0:	test   rax,rax
    19f3:	mov    rsi,rax
    19f6:	jne    1a04 <botlish_fn_21+0x90>
    19fc:	mov    rdi,r12
    19ff:	jmp    1ad7 <botlish_fn_21+0x163>
    1a04:	mov    rdx,QWORD PTR [rsp+0x10]
    1a09:	mov    rdi,r12
    1a0c:	call   1a11 <botlish_fn_21+0x9d>
			1a0d: R_X86_64_PLT32	rt_int_mod-0x4
    1a11:	test   rax,rax
    1a14:	jne    1a22 <botlish_fn_21+0xae>
    1a1a:	mov    rdi,r12
    1a1d:	jmp    1ad7 <botlish_fn_21+0x163>
    1a22:	mov    QWORD PTR [rbx+0x30],rax
    1a26:	mov    rcx,QWORD PTR [rsp+0x10]
    1a2b:	mov    rdx,rax
    1a2e:	mov    rsi,QWORD PTR [rsp]
    1a32:	mov    rdi,r12
    1a35:	call   1a3a <botlish_fn_21+0xc6>
			1a36: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1a3a:	test   rax,rax
    1a3d:	jne    1a4b <botlish_fn_21+0xd7>
    1a43:	mov    rdi,r12
    1a46:	jmp    1ad7 <botlish_fn_21+0x163>
    1a4b:	mov    QWORD PTR [rbx+0x18],rax
    1a4f:	mov    QWORD PTR [rsp+0x10],rax
    1a54:	mov    rdi,r12
    1a57:	call   1a5c <botlish_fn_21+0xe8>
			1a58: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1a5c:	test   rax,rax
    1a5f:	mov    rcx,rax
    1a62:	jne    1a70 <botlish_fn_21+0xfc>
    1a68:	mov    rdi,r12
    1a6b:	jmp    1ad7 <botlish_fn_21+0x163>
    1a70:	mov    rsi,QWORD PTR [rsp]
    1a74:	mov    rdx,QWORD PTR [rsp+0x10]
    1a79:	mov    rdi,r12
    1a7c:	call   1a81 <botlish_fn_21+0x10d>
			1a7d: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a81:	test   rax,rax
    1a84:	jne    1a92 <botlish_fn_21+0x11e>
    1a8a:	mov    rdi,r12
    1a8d:	jmp    1ad7 <botlish_fn_21+0x163>
    1a92:	mov    rcx,r15
    1a95:	mov    rsi,QWORD PTR [rsp+0x8]
    1a9a:	mov    rdx,QWORD PTR [rsp+0x10]
    1a9f:	mov    rdi,r12
    1aa2:	call   1aa7 <botlish_fn_21+0x133>
			1aa3: R_X86_64_PLT32	rt_mutarray_set-0x4
    1aa7:	test   rax,rax
    1aaa:	jne    1ab8 <botlish_fn_21+0x144>
    1ab0:	mov    rdi,r12
    1ab3:	jmp    1ad7 <botlish_fn_21+0x163>
    1ab8:	mov    rcx,r14
    1abb:	mov    rdx,QWORD PTR [rsp+0x10]
    1ac0:	mov    rsi,r13
    1ac3:	mov    rdi,r12
    1ac6:	call   1acb <botlish_fn_21+0x157>
			1ac7: R_X86_64_PLT32	rt_mutarray_set-0x4
    1acb:	test   rax,rax
    1ace:	jne    1b02 <botlish_fn_21+0x18e>
    1ad4:	mov    rdi,r12
    1ad7:	mov    rdi,r12
    1ada:	mov    QWORD PTR [rdi],rbx
    1add:	xor    rax,rax
    1ae0:	mov    rbx,QWORD PTR [rsp+0x20]
    1ae5:	mov    r12,QWORD PTR [rsp+0x28]
    1aea:	mov    r13,QWORD PTR [rsp+0x30]
    1aef:	mov    r14,QWORD PTR [rsp+0x38]
    1af4:	mov    r15,QWORD PTR [rsp+0x40]
    1af9:	add    rsp,0x50
    1afd:	mov    rsp,rbp
    1b00:	pop    rbp
    1b01:	ret
    1b02:	mov    rdi,r12
    1b05:	mov    QWORD PTR [rdi],rbx
    1b08:	mov    eax,0xa
    1b0d:	mov    rbx,QWORD PTR [rsp+0x20]
    1b12:	mov    r12,QWORD PTR [rsp+0x28]
    1b17:	mov    r13,QWORD PTR [rsp+0x30]
    1b1c:	mov    r14,QWORD PTR [rsp+0x38]
    1b21:	mov    r15,QWORD PTR [rsp+0x40]
    1b26:	add    rsp,0x50
    1b2a:	mov    rsp,rbp
    1b2d:	pop    rbp
    1b2e:	ret
    1b2f:	mov    r12,rdi
    1b32:	call   1b37 <botlish_fn_21+0x1c3>
			1b33: R_X86_64_PLT32	rt_stack_overflow-0x4
    1b37:	xor    rax,rax
    1b3a:	mov    rbx,QWORD PTR [rsp+0x20]
    1b3f:	mov    r12,QWORD PTR [rsp+0x28]
    1b44:	mov    r13,QWORD PTR [rsp+0x30]
    1b49:	mov    r14,QWORD PTR [rsp+0x38]
    1b4e:	mov    r15,QWORD PTR [rsp+0x40]
    1b53:	add    rsp,0x50
    1b57:	mov    rsp,rbp
    1b5a:	pop    rbp
    1b5b:	ret

0000000000001b5c <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1b5c:	push   rbp
    1b5d:	mov    rbp,rsp
    1b60:	sub    rsp,0x10
    1b64:	mov    rsi,QWORD PTR [rdx]
    1b67:	mov    r10,QWORD PTR [rdx+0x8]
    1b6b:	mov    rcx,QWORD PTR [rdx+0x10]
    1b6f:	mov    r8,QWORD PTR [rdx+0x18]
    1b73:	mov    r9,QWORD PTR [rdx+0x20]
    1b77:	mov    r11,QWORD PTR [rdx+0x28]
    1b7b:	mov    QWORD PTR [rsp],r11
    1b7f:	mov    rdx,r10
    1b82:	call   1b87 <botlish_entry_21+0x2b>
			1b83: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    1b87:	add    rsp,0x10
    1b8b:	mov    rsp,rbp
    1b8e:	pop    rbp
    1b8f:	ret

0000000000001b90 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1b90:	push   rbp
    1b91:	mov    rbp,rsp
    1b94:	sub    rsp,0x80
    1b9b:	mov    QWORD PTR [rsp+0x50],rbx
    1ba0:	mov    QWORD PTR [rsp+0x58],r12
    1ba5:	mov    QWORD PTR [rsp+0x60],r13
    1baa:	mov    QWORD PTR [rsp+0x68],r14
    1baf:	mov    QWORD PTR [rsp+0x70],r15
    1bb4:	mov    r13,QWORD PTR [rbp+0x10]
    1bb8:	mov    r14,QWORD PTR [rbp+0x18]
    1bbc:	mov    r15,QWORD PTR [rbp+0x20]
    1bc0:	mov    r12,QWORD PTR [rbp+0x28]
    1bc4:	mov    QWORD PTR [rsp+0x38],r12
    1bc9:	mov    r12,QWORD PTR [rdi]
    1bcc:	mov    r11,QWORD PTR [rdi+0x8]
    1bd0:	lea    rax,[r12+0x58]
    1bd5:	cmp    rax,r11
    1bd8:	ja     1ff6 <botlish_fn_22+0x466>
    1bde:	lea    rax,[r12+0x58]
    1be3:	mov    QWORD PTR [rdi],rax
    1be6:	mov    QWORD PTR [rsp+0x10],rdi
    1beb:	mov    QWORD PTR [r12+0x50],0x0
    1bf4:	mov    QWORD PTR [r12],rsi
    1bf8:	mov    QWORD PTR [rsp+0x18],rsi
    1bfd:	mov    QWORD PTR [r12+0x8],rdx
    1c02:	mov    QWORD PTR [rsp+0x20],rdx
    1c07:	mov    QWORD PTR [r12+0x10],rcx
    1c0c:	mov    QWORD PTR [rsp+0x28],rcx
    1c11:	mov    QWORD PTR [r12+0x18],r8
    1c16:	mov    QWORD PTR [r12+0x20],r9
    1c1b:	mov    QWORD PTR [rsp+0x30],r9
    1c20:	mov    QWORD PTR [r12+0x28],r13
    1c25:	mov    QWORD PTR [r12+0x30],r14
    1c2a:	mov    QWORD PTR [r12+0x38],r15
    1c2f:	mov    rax,QWORD PTR [rsp+0x38]
    1c34:	mov    QWORD PTR [r12+0x40],rax
    1c39:	mov    rbx,QWORD PTR [rsp+0x30]
    1c3e:	mov    rsi,r8
    1c41:	mov    rax,rsi
    1c44:	and    rax,rbx
    1c47:	mov    QWORD PTR [rsp+0x40],rsi
    1c4c:	test   rax,0x1
    1c52:	jne    1c84 <botlish_fn_22+0xf4>
    1c58:	mov    rdx,rbx
    1c5b:	mov    rsi,QWORD PTR [rsp+0x40]
    1c60:	mov    rdi,QWORD PTR [rsp+0x10]
    1c65:	call   1c6a <botlish_fn_22+0xda>
			1c66: R_X86_64_PLT32	rt_int_cmp-0x4
    1c6a:	mov    QWORD PTR [rsp+0x30],rbx
    1c6f:	mov    ecx,0x2
    1c74:	test   rax,rax
    1c77:	cmovge rcx,QWORD PTR [rip+0x3a9]        # 2028 <botlish_fn_22+0x498>
    1c7f:	jmp    1ca3 <botlish_fn_22+0x113>
    1c84:	mov    QWORD PTR [rsp+0x30],rbx
    1c89:	mov    ecx,0x2
    1c8e:	mov    rsi,QWORD PTR [rsp+0x40]
    1c93:	mov    r9,QWORD PTR [rsp+0x30]
    1c98:	cmp    rsi,r9
    1c9b:	cmovge rcx,QWORD PTR [rip+0x385]        # 2028 <botlish_fn_22+0x498>
    1ca3:	cmp    rcx,0x6
    1ca7:	je     1fc4 <botlish_fn_22+0x434>
    1cad:	xor    eax,eax
    1caf:	mov    rsi,QWORD PTR [rsp+0x18]
    1cb4:	test   rsi,0x7
    1cbb:	jne    1cca <botlish_fn_22+0x13a>
    1cc1:	movzx  rax,BYTE PTR [rsi]
    1cc5:	cmp    al,0x8
    1cc7:	sete   al
    1cca:	test   al,al
    1ccc:	jne    1cf3 <botlish_fn_22+0x163>
    1cd2:	mov    rdi,QWORD PTR [rsp+0x10]
    1cd7:	mov    rax,QWORD PTR [rdi+0x10]
    1cdb:	mov    rcx,QWORD PTR [rax+0x8]
    1cdf:	mov    edx,0x8
    1ce4:	call   1ce9 <botlish_fn_22+0x159>
			1ce5: R_X86_64_PLT32	rt_type_error-0x4
    1ce9:	mov    rdi,QWORD PTR [rsp+0x10]
    1cee:	jmp    1ee1 <botlish_fn_22+0x351>
    1cf3:	mov    QWORD PTR [rsp+0x18],rsi
    1cf8:	mov    rdx,QWORD PTR [rsp+0x40]
    1cfd:	mov    rdi,QWORD PTR [rsp+0x10]
    1d02:	call   1d07 <botlish_fn_22+0x177>
			1d03: R_X86_64_PLT32	rt_mutarray_get-0x4
    1d07:	test   rax,rax
    1d0a:	jne    1d1a <botlish_fn_22+0x18a>
    1d10:	mov    rdi,QWORD PTR [rsp+0x10]
    1d15:	jmp    1ee1 <botlish_fn_22+0x351>
    1d1a:	mov    QWORD PTR [r12+0x48],rax
    1d1f:	mov    rbx,rax
    1d22:	mov    rdi,QWORD PTR [rsp+0x10]
    1d27:	call   1d2c <botlish_fn_22+0x19c>
			1d28: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1d2c:	test   rax,rax
    1d2f:	jne    1d3f <botlish_fn_22+0x1af>
    1d35:	mov    rdi,QWORD PTR [rsp+0x10]
    1d3a:	jmp    1ee1 <botlish_fn_22+0x351>
    1d3f:	mov    rcx,rbx
    1d42:	mov    rdx,rcx
    1d45:	and    rdx,rax
    1d48:	test   rdx,0x1
    1d4f:	jne    1d78 <botlish_fn_22+0x1e8>
    1d55:	mov    rdx,rax
    1d58:	mov    rsi,rbx
    1d5b:	mov    rdi,QWORD PTR [rsp+0x10]
    1d60:	call   1d65 <botlish_fn_22+0x1d5>
			1d61: R_X86_64_PLT32	rt_value_eq-0x4
    1d65:	test   rax,rax
    1d68:	jne    1d8e <botlish_fn_22+0x1fe>
    1d6e:	mov    rdi,QWORD PTR [rsp+0x10]
    1d73:	jmp    1ee1 <botlish_fn_22+0x351>
    1d78:	mov    rdx,rax
    1d7b:	mov    rsi,rbx
    1d7e:	mov    eax,0x2
    1d83:	cmp    rsi,rdx
    1d86:	cmove  rax,QWORD PTR [rip+0x29a]        # 2028 <botlish_fn_22+0x498>
    1d8e:	cmp    rax,0x6
    1d92:	je     1da2 <botlish_fn_22+0x212>
    1d98:	mov    rbx,QWORD PTR [rsp+0x38]
    1d9d:	jmp    1f11 <botlish_fn_22+0x381>
    1da2:	xor    eax,eax
    1da4:	mov    rdx,QWORD PTR [rsp+0x20]
    1da9:	test   rdx,0x7
    1db0:	je     1dc0 <botlish_fn_22+0x230>
    1db6:	mov    QWORD PTR [rsp+0x20],rdx
    1dbb:	jmp    1dce <botlish_fn_22+0x23e>
    1dc0:	movzx  rax,BYTE PTR [rdx]
    1dc4:	mov    QWORD PTR [rsp+0x20],rdx
    1dc9:	cmp    al,0x8
    1dcb:	sete   al
    1dce:	test   al,al
    1dd0:	jne    1dfc <botlish_fn_22+0x26c>
    1dd6:	mov    rdi,QWORD PTR [rsp+0x10]
    1ddb:	mov    rsi,QWORD PTR [rdi+0x10]
    1ddf:	mov    rcx,QWORD PTR [rsi+0x8]
    1de3:	mov    edx,0x8
    1de8:	mov    rsi,QWORD PTR [rsp+0x20]
    1ded:	call   1df2 <botlish_fn_22+0x262>
			1dee: R_X86_64_PLT32	rt_type_error-0x4
    1df2:	mov    rdi,QWORD PTR [rsp+0x10]
    1df7:	jmp    1ee1 <botlish_fn_22+0x351>
    1dfc:	mov    rdx,QWORD PTR [rsp+0x40]
    1e01:	mov    rsi,QWORD PTR [rsp+0x20]
    1e06:	mov    rdi,QWORD PTR [rsp+0x10]
    1e0b:	call   1e10 <botlish_fn_22+0x280>
			1e0c: R_X86_64_PLT32	rt_mutarray_get-0x4
    1e10:	test   rax,rax
    1e13:	jne    1e23 <botlish_fn_22+0x293>
    1e19:	mov    rdi,QWORD PTR [rsp+0x10]
    1e1e:	jmp    1ee1 <botlish_fn_22+0x351>
    1e23:	mov    QWORD PTR [r12+0x48],rax
    1e28:	mov    rbx,rax
    1e2b:	xor    eax,eax
    1e2d:	mov    rcx,QWORD PTR [rsp+0x28]
    1e32:	test   rcx,0x7
    1e39:	je     1e49 <botlish_fn_22+0x2b9>
    1e3f:	mov    QWORD PTR [rsp+0x28],rcx
    1e44:	jmp    1e57 <botlish_fn_22+0x2c7>
    1e49:	movzx  rax,BYTE PTR [rcx]
    1e4d:	mov    QWORD PTR [rsp+0x28],rcx
    1e52:	cmp    al,0x8
    1e54:	sete   al
    1e57:	test   al,al
    1e59:	jne    1e85 <botlish_fn_22+0x2f5>
    1e5f:	mov    rdi,QWORD PTR [rsp+0x10]
    1e64:	mov    rax,QWORD PTR [rdi+0x10]
    1e68:	mov    rcx,QWORD PTR [rax+0x8]
    1e6c:	mov    edx,0x8
    1e71:	mov    rsi,QWORD PTR [rsp+0x28]
    1e76:	call   1e7b <botlish_fn_22+0x2eb>
			1e77: R_X86_64_PLT32	rt_type_error-0x4
    1e7b:	mov    rdi,QWORD PTR [rsp+0x10]
    1e80:	jmp    1ee1 <botlish_fn_22+0x351>
    1e85:	mov    rdx,QWORD PTR [rsp+0x40]
    1e8a:	mov    rsi,QWORD PTR [rsp+0x28]
    1e8f:	mov    rdi,QWORD PTR [rsp+0x10]
    1e94:	call   1e99 <botlish_fn_22+0x309>
			1e95: R_X86_64_PLT32	rt_mutarray_get-0x4
    1e99:	test   rax,rax
    1e9c:	jne    1eac <botlish_fn_22+0x31c>
    1ea2:	mov    rdi,QWORD PTR [rsp+0x10]
    1ea7:	jmp    1ee1 <botlish_fn_22+0x351>
    1eac:	mov    QWORD PTR [r12+0x50],rax
    1eb1:	mov    QWORD PTR [rsp],rax
    1eb5:	mov    r9,rbx
    1eb8:	mov    rbx,QWORD PTR [rsp+0x38]
    1ebd:	mov    rcx,r15
    1ec0:	mov    rdx,r14
    1ec3:	mov    rsi,r13
    1ec6:	mov    rdi,QWORD PTR [rsp+0x10]
    1ecb:	mov    r8,rbx
    1ece:	call   1ed3 <botlish_fn_22+0x343>
			1ecf: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    1ed3:	test   rax,rax
    1ed6:	jne    1f11 <botlish_fn_22+0x381>
    1edc:	mov    rdi,QWORD PTR [rsp+0x10]
    1ee1:	mov    rdi,QWORD PTR [rsp+0x10]
    1ee6:	mov    QWORD PTR [rdi],r12
    1ee9:	xor    rax,rax
    1eec:	mov    rbx,QWORD PTR [rsp+0x50]
    1ef1:	mov    r12,QWORD PTR [rsp+0x58]
    1ef6:	mov    r13,QWORD PTR [rsp+0x60]
    1efb:	mov    r14,QWORD PTR [rsp+0x68]
    1f00:	mov    r15,QWORD PTR [rsp+0x70]
    1f05:	add    rsp,0x80
    1f0c:	mov    rsp,rbp
    1f0f:	pop    rbp
    1f10:	ret
    1f11:	mov    QWORD PTR [r12+0x48],0x3
    1f1a:	mov    rsi,QWORD PTR [rsp+0x40]
    1f1f:	test   rsi,0x1
    1f26:	je     1f52 <botlish_fn_22+0x3c2>
    1f2c:	mov    rsi,QWORD PTR [rsp+0x40]
    1f31:	mov    rcx,rsi
    1f34:	add    rcx,0x2
    1f38:	seto   al
    1f3b:	test   al,al
    1f3d:	jne    1f52 <botlish_fn_22+0x3c2>
    1f43:	mov    rsi,QWORD PTR [rsp+0x18]
    1f48:	mov    QWORD PTR [rsp+0x40],rcx
    1f4d:	jmp    1f70 <botlish_fn_22+0x3e0>
    1f52:	mov    edx,0x3
    1f57:	mov    rsi,QWORD PTR [rsp+0x40]
    1f5c:	mov    rdi,QWORD PTR [rsp+0x10]
    1f61:	call   1f66 <botlish_fn_22+0x3d6>
			1f62: R_X86_64_PLT32	rt_int_add-0x4
    1f66:	mov    rsi,QWORD PTR [rsp+0x18]
    1f6b:	mov    QWORD PTR [rsp+0x40],rax
    1f70:	mov    rsi,QWORD PTR [rsp+0x18]
    1f75:	mov    QWORD PTR [r12],rsi
    1f79:	mov    rsi,QWORD PTR [rsp+0x20]
    1f7e:	mov    QWORD PTR [r12+0x8],rsi
    1f83:	mov    rsi,QWORD PTR [rsp+0x28]
    1f88:	mov    QWORD PTR [r12+0x10],rsi
    1f8d:	mov    rsi,QWORD PTR [rsp+0x40]
    1f92:	mov    QWORD PTR [r12+0x18],rsi
    1f97:	mov    r9,QWORD PTR [rsp+0x30]
    1f9c:	mov    QWORD PTR [r12+0x20],r9
    1fa1:	mov    QWORD PTR [r12+0x28],r13
    1fa6:	mov    QWORD PTR [r12+0x30],r14
    1fab:	mov    QWORD PTR [r12+0x38],r15
    1fb0:	mov    QWORD PTR [r12+0x40],rbx
    1fb5:	mov    QWORD PTR [rsp+0x38],rbx
    1fba:	mov    rbx,QWORD PTR [rsp+0x30]
    1fbf:	jmp    1c41 <botlish_fn_22+0xb1>
    1fc4:	mov    rdi,QWORD PTR [rsp+0x10]
    1fc9:	mov    QWORD PTR [rdi],r12
    1fcc:	mov    eax,0xa
    1fd1:	mov    rbx,QWORD PTR [rsp+0x50]
    1fd6:	mov    r12,QWORD PTR [rsp+0x58]
    1fdb:	mov    r13,QWORD PTR [rsp+0x60]
    1fe0:	mov    r14,QWORD PTR [rsp+0x68]
    1fe5:	mov    r15,QWORD PTR [rsp+0x70]
    1fea:	add    rsp,0x80
    1ff1:	mov    rsp,rbp
    1ff4:	pop    rbp
    1ff5:	ret
    1ff6:	mov    QWORD PTR [rsp+0x10],rdi
    1ffb:	call   2000 <botlish_fn_22+0x470>
			1ffc: R_X86_64_PLT32	rt_stack_overflow-0x4
    2000:	xor    rax,rax
    2003:	mov    rbx,QWORD PTR [rsp+0x50]
    2008:	mov    r12,QWORD PTR [rsp+0x58]
    200d:	mov    r13,QWORD PTR [rsp+0x60]
    2012:	mov    r14,QWORD PTR [rsp+0x68]
    2017:	mov    r15,QWORD PTR [rsp+0x70]
    201c:	add    rsp,0x80
    2023:	mov    rsp,rbp
    2026:	pop    rbp
    2027:	ret
    2028:	(bad)
    2029:	add    BYTE PTR [rax],al
    202b:	add    BYTE PTR [rax],al
    202d:	add    BYTE PTR [rax],al
	...

0000000000002030 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    2030:	push   rbp
    2031:	mov    rbp,rsp
    2034:	sub    rsp,0x30
    2038:	mov    QWORD PTR [rsp+0x20],r12
    203d:	mov    rsi,QWORD PTR [rdx]
    2040:	mov    rax,QWORD PTR [rdx+0x8]
    2044:	mov    rcx,QWORD PTR [rdx+0x10]
    2048:	mov    r8,QWORD PTR [rdx+0x18]
    204c:	mov    r9,QWORD PTR [rdx+0x20]
    2050:	mov    r10,QWORD PTR [rdx+0x28]
    2054:	mov    r11,QWORD PTR [rdx+0x30]
    2058:	mov    r12,QWORD PTR [rdx+0x38]
    205c:	mov    rdx,QWORD PTR [rdx+0x40]
    2060:	mov    QWORD PTR [rsp],r10
    2064:	mov    QWORD PTR [rsp+0x8],r11
    2069:	mov    QWORD PTR [rsp+0x10],r12
    206e:	mov    QWORD PTR [rsp+0x18],rdx
    2073:	mov    rdx,rax
    2076:	call   207b <botlish_entry_22+0x4b>
			2077: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    207b:	mov    r12,QWORD PTR [rsp+0x20]
    2080:	add    rsp,0x30
    2084:	mov    rsp,rbp
    2087:	pop    rbp
    2088:	ret

0000000000002089 <botlish_fn_23: ht_rehash<mutarray, int>>:
    2089:	push   rbp
    208a:	mov    rbp,rsp
    208d:	sub    rsp,0x80
    2094:	mov    QWORD PTR [rsp+0x50],rbx
    2099:	mov    QWORD PTR [rsp+0x58],r12
    209e:	mov    QWORD PTR [rsp+0x60],r13
    20a3:	mov    QWORD PTR [rsp+0x68],r14
    20a8:	mov    QWORD PTR [rsp+0x70],r15
    20ad:	mov    r12,QWORD PTR [rdi]
    20b0:	mov    rax,QWORD PTR [rdi+0x8]
    20b4:	lea    rcx,[r12+0x50]
    20b9:	cmp    rcx,rax
    20bc:	ja     23ab <botlish_fn_23+0x322>
    20c2:	lea    rax,[r12+0x50]
    20c7:	mov    QWORD PTR [rdi],rax
    20ca:	mov    r13,rdi
    20cd:	mov    QWORD PTR [r12+0x10],0x0
    20d6:	mov    QWORD PTR [r12+0x18],0x0
    20df:	mov    QWORD PTR [r12+0x20],0x0
    20e8:	mov    QWORD PTR [r12+0x28],0x0
    20f1:	mov    QWORD PTR [r12+0x30],0x0
    20fa:	mov    QWORD PTR [r12+0x38],0x0
    2103:	mov    QWORD PTR [r12+0x40],0x0
    210c:	mov    QWORD PTR [r12+0x48],0x0
    2115:	mov    QWORD PTR [r12],rsi
    2119:	mov    r14,rsi
    211c:	mov    QWORD PTR [r12+0x8],rdx
    2121:	mov    rbx,rdx
    2124:	mov    rsi,r14
    2127:	mov    rdi,r13
    212a:	call   212f <botlish_fn_23+0xa6>
			212b: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    212f:	test   rax,rax
    2132:	jne    2140 <botlish_fn_23+0xb7>
    2138:	mov    rdi,r13
    213b:	jmp    234d <botlish_fn_23+0x2c4>
    2140:	mov    QWORD PTR [r12+0x10],rax
    2145:	mov    r15,rax
    2148:	mov    rsi,r14
    214b:	mov    rdi,r13
    214e:	call   2153 <botlish_fn_23+0xca>
			214f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2153:	test   rax,rax
    2156:	jne    2164 <botlish_fn_23+0xdb>
    215c:	mov    rdi,r13
    215f:	jmp    234d <botlish_fn_23+0x2c4>
    2164:	mov    QWORD PTR [r12+0x18],rax
    2169:	mov    QWORD PTR [rsp+0x48],rax
    216e:	mov    rsi,r14
    2171:	mov    rdi,r13
    2174:	call   2179 <botlish_fn_23+0xf0>
			2175: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2179:	test   rax,rax
    217c:	jne    218a <botlish_fn_23+0x101>
    2182:	mov    rdi,r13
    2185:	jmp    234d <botlish_fn_23+0x2c4>
    218a:	mov    QWORD PTR [r12+0x20],rax
    218f:	mov    QWORD PTR [rsp+0x40],rax
    2194:	mov    rsi,r14
    2197:	mov    rdi,r13
    219a:	call   219f <botlish_fn_23+0x116>
			219b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    219f:	test   rax,rax
    21a2:	jne    21b0 <botlish_fn_23+0x127>
    21a8:	mov    rdi,r13
    21ab:	jmp    234d <botlish_fn_23+0x2c4>
    21b0:	mov    QWORD PTR [r12+0x28],rax
    21b5:	mov    QWORD PTR [rsp+0x38],rax
    21ba:	mov    rsi,rbx
    21bd:	mov    rdi,r13
    21c0:	call   21c5 <botlish_fn_23+0x13c>
			21c1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    21c5:	mov    rcx,rax
    21c8:	mov    QWORD PTR [rsp+0x30],rax
    21cd:	test   rax,rcx
    21d0:	jne    21de <botlish_fn_23+0x155>
    21d6:	mov    rdi,r13
    21d9:	jmp    234d <botlish_fn_23+0x2c4>
    21de:	mov    rax,QWORD PTR [rsp+0x30]
    21e3:	mov    QWORD PTR [r12+0x30],rax
    21e8:	mov    edx,0x1
    21ed:	mov    QWORD PTR [r12+0x38],0x1
    21f6:	mov    rcx,rbx
    21f9:	mov    rsi,QWORD PTR [rsp+0x30]
    21fe:	mov    rdi,r13
    2201:	call   2206 <botlish_fn_23+0x17d>
			2202: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    2206:	test   rax,rax
    2209:	jne    2217 <botlish_fn_23+0x18e>
    220f:	mov    rdi,r13
    2212:	jmp    234d <botlish_fn_23+0x2c4>
    2217:	mov    rsi,rbx
    221a:	mov    rdi,r13
    221d:	call   2222 <botlish_fn_23+0x199>
			221e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2222:	test   rax,rax
    2225:	jne    2233 <botlish_fn_23+0x1aa>
    222b:	mov    rdi,r13
    222e:	jmp    234d <botlish_fn_23+0x2c4>
    2233:	mov    QWORD PTR [r12+0x38],rax
    2238:	mov    QWORD PTR [rsp+0x28],rax
    223d:	mov    rsi,rbx
    2240:	mov    rdi,r13
    2243:	call   2248 <botlish_fn_23+0x1bf>
			2244: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2248:	test   rax,rax
    224b:	jne    2259 <botlish_fn_23+0x1d0>
    2251:	mov    rdi,r13
    2254:	jmp    234d <botlish_fn_23+0x2c4>
    2259:	mov    QWORD PTR [r12+0x40],rax
    225e:	mov    r8d,0x1
    2264:	mov    QWORD PTR [r12+0x48],0x1
    226d:	mov    rcx,QWORD PTR [rsp+0x30]
    2272:	mov    QWORD PTR [rsp],rcx
    2276:	mov    rcx,QWORD PTR [rsp+0x28]
    227b:	mov    QWORD PTR [rsp+0x8],rcx
    2280:	mov    QWORD PTR [rsp+0x10],rax
    2285:	mov    QWORD PTR [rsp+0x20],rax
    228a:	mov    QWORD PTR [rsp+0x18],rbx
    228f:	mov    rcx,QWORD PTR [rsp+0x40]
    2294:	mov    rdx,QWORD PTR [rsp+0x48]
    2299:	mov    rsi,r15
    229c:	mov    r9,QWORD PTR [rsp+0x38]
    22a1:	mov    rdi,r13
    22a4:	call   22a9 <botlish_fn_23+0x220>
			22a5: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    22a9:	test   rax,rax
    22ac:	jne    22ba <botlish_fn_23+0x231>
    22b2:	mov    rdi,r13
    22b5:	jmp    234d <botlish_fn_23+0x2c4>
    22ba:	mov    edx,0x1
    22bf:	mov    rcx,QWORD PTR [rsp+0x30]
    22c4:	mov    rsi,r14
    22c7:	mov    rdi,r13
    22ca:	call   22cf <botlish_fn_23+0x246>
			22cb: R_X86_64_PLT32	rt_mutarray_set-0x4
    22cf:	test   rax,rax
    22d2:	jne    22e0 <botlish_fn_23+0x257>
    22d8:	mov    rdi,r13
    22db:	jmp    234d <botlish_fn_23+0x2c4>
    22e0:	mov    edx,0x3
    22e5:	mov    rcx,QWORD PTR [rsp+0x28]
    22ea:	mov    rsi,r14
    22ed:	mov    rdi,r13
    22f0:	call   22f5 <botlish_fn_23+0x26c>
			22f1: R_X86_64_PLT32	rt_mutarray_set-0x4
    22f5:	test   rax,rax
    22f8:	jne    2306 <botlish_fn_23+0x27d>
    22fe:	mov    rdi,r13
    2301:	jmp    234d <botlish_fn_23+0x2c4>
    2306:	mov    edx,0x5
    230b:	mov    rcx,QWORD PTR [rsp+0x20]
    2310:	mov    rsi,r14
    2313:	mov    rdi,r13
    2316:	call   231b <botlish_fn_23+0x292>
			2317: R_X86_64_PLT32	rt_mutarray_set-0x4
    231b:	test   rax,rax
    231e:	jne    232c <botlish_fn_23+0x2a3>
    2324:	mov    rdi,r13
    2327:	jmp    234d <botlish_fn_23+0x2c4>
    232c:	mov    edx,0x9
    2331:	mov    ecx,0x1
    2336:	mov    rsi,r14
    2339:	mov    rdi,r13
    233c:	call   2341 <botlish_fn_23+0x2b8>
			233d: R_X86_64_PLT32	rt_mutarray_set-0x4
    2341:	test   rax,rax
    2344:	jne    237b <botlish_fn_23+0x2f2>
    234a:	mov    rdi,r13
    234d:	mov    rdi,r13
    2350:	mov    QWORD PTR [rdi],r12
    2353:	xor    rax,rax
    2356:	mov    rbx,QWORD PTR [rsp+0x50]
    235b:	mov    r12,QWORD PTR [rsp+0x58]
    2360:	mov    r13,QWORD PTR [rsp+0x60]
    2365:	mov    r14,QWORD PTR [rsp+0x68]
    236a:	mov    r15,QWORD PTR [rsp+0x70]
    236f:	add    rsp,0x80
    2376:	mov    rsp,rbp
    2379:	pop    rbp
    237a:	ret
    237b:	mov    rdi,r13
    237e:	mov    QWORD PTR [rdi],r12
    2381:	mov    eax,0xa
    2386:	mov    rbx,QWORD PTR [rsp+0x50]
    238b:	mov    r12,QWORD PTR [rsp+0x58]
    2390:	mov    r13,QWORD PTR [rsp+0x60]
    2395:	mov    r14,QWORD PTR [rsp+0x68]
    239a:	mov    r15,QWORD PTR [rsp+0x70]
    239f:	add    rsp,0x80
    23a6:	mov    rsp,rbp
    23a9:	pop    rbp
    23aa:	ret
    23ab:	mov    r13,rdi
    23ae:	call   23b3 <botlish_fn_23+0x32a>
			23af: R_X86_64_PLT32	rt_stack_overflow-0x4
    23b3:	xor    rax,rax
    23b6:	mov    rbx,QWORD PTR [rsp+0x50]
    23bb:	mov    r12,QWORD PTR [rsp+0x58]
    23c0:	mov    r13,QWORD PTR [rsp+0x60]
    23c5:	mov    r14,QWORD PTR [rsp+0x68]
    23ca:	mov    r15,QWORD PTR [rsp+0x70]
    23cf:	add    rsp,0x80
    23d6:	mov    rsp,rbp
    23d9:	pop    rbp
    23da:	ret

00000000000023db <botlish_entry_23: ht_rehash<mutarray, int>>:
    23db:	push   rbp
    23dc:	mov    rbp,rsp
    23df:	mov    rsi,QWORD PTR [rdx]
    23e2:	mov    rdx,QWORD PTR [rdx+0x8]
    23e6:	call   23eb <botlish_entry_23+0x10>
			23e7: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    23eb:	mov    rsp,rbp
    23ee:	pop    rbp
    23ef:	ret

00000000000023f0 <botlish_fn_24: ht_should_grow<mutarray>>:
    23f0:	push   rbp
    23f1:	mov    rbp,rsp
    23f4:	sub    rsp,0x20
    23f8:	mov    QWORD PTR [rsp],rbx
    23fc:	mov    QWORD PTR [rsp+0x8],r12
    2401:	mov    QWORD PTR [rsp+0x10],r13
    2406:	mov    QWORD PTR [rsp+0x18],r14
    240b:	mov    r12,QWORD PTR [rdi]
    240e:	mov    r8,QWORD PTR [rdi+0x8]
    2412:	lea    r9,[r12+0x18]
    2417:	cmp    r9,r8
    241a:	ja     274b <botlish_fn_24+0x35b>
    2420:	lea    r9,[r12+0x18]
    2425:	mov    QWORD PTR [rdi],r9
    2428:	mov    r13,rdi
    242b:	mov    QWORD PTR [r12+0x8],0x0
    2434:	mov    QWORD PTR [r12+0x10],0x0
    243d:	mov    QWORD PTR [r12],rsi
    2441:	mov    rbx,rsi
    2444:	mov    rsi,rbx
    2447:	mov    rdi,r13
    244a:	call   244f <botlish_fn_24+0x5f>
			244b: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    244f:	mov    rcx,rax
    2452:	mov    r14,rax
    2455:	test   rax,rcx
    2458:	jne    2466 <botlish_fn_24+0x76>
    245e:	mov    rdi,r13
    2461:	jmp    2663 <botlish_fn_24+0x273>
    2466:	mov    rax,r14
    2469:	mov    QWORD PTR [r12+0x8],rax
    246e:	mov    rsi,rbx
    2471:	mov    rdi,r13
    2474:	call   2479 <botlish_fn_24+0x89>
			2475: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2479:	mov    rcx,rax
    247c:	test   rcx,rcx
    247f:	jne    248d <botlish_fn_24+0x9d>
    2485:	mov    rdi,r13
    2488:	jmp    2663 <botlish_fn_24+0x273>
    248d:	mov    QWORD PTR [r12+0x10],rcx
    2492:	mov    edx,0x1
    2497:	mov    rax,r14
    249a:	test   rax,0x1
    24a0:	jne    24c3 <botlish_fn_24+0xd3>
    24a6:	xor    edx,edx
    24a8:	mov    rax,r14
    24ab:	test   rax,0x7
    24b1:	jne    24c3 <botlish_fn_24+0xd3>
    24b7:	mov    rax,r14
    24ba:	movzx  rax,BYTE PTR [rax]
    24be:	cmp    al,0x1
    24c0:	sete   dl
    24c3:	test   dl,dl
    24c5:	jne    24e9 <botlish_fn_24+0xf9>
    24cb:	mov    rdi,r13
    24ce:	mov    rax,QWORD PTR [rdi+0x10]
    24d2:	mov    rcx,QWORD PTR [rax+0x10]
    24d6:	xor    rdx,rdx
    24d9:	mov    rsi,r14
    24dc:	call   24e1 <botlish_fn_24+0xf1>
			24dd: R_X86_64_PLT32	rt_type_error-0x4
    24e1:	mov    rdi,r13
    24e4:	jmp    2663 <botlish_fn_24+0x273>
    24e9:	mov    eax,0x1
    24ee:	test   rcx,0x1
    24f5:	je     2503 <botlish_fn_24+0x113>
    24fb:	mov    r8,rcx
    24fe:	jmp    2526 <botlish_fn_24+0x136>
    2503:	xor    eax,eax
    2505:	test   rcx,0x7
    250c:	je     251a <botlish_fn_24+0x12a>
    2512:	mov    r8,rcx
    2515:	jmp    2526 <botlish_fn_24+0x136>
    251a:	movzx  rax,BYTE PTR [rcx]
    251e:	mov    r8,rcx
    2521:	cmp    al,0x1
    2523:	sete   al
    2526:	test   al,al
    2528:	jne    254c <botlish_fn_24+0x15c>
    252e:	mov    rdi,r13
    2531:	mov    rax,QWORD PTR [rdi+0x10]
    2535:	mov    rcx,QWORD PTR [rax+0x10]
    2539:	xor    rdx,rdx
    253c:	mov    rsi,r8
    253f:	call   2544 <botlish_fn_24+0x154>
			2540: R_X86_64_PLT32	rt_type_error-0x4
    2544:	mov    rdi,r13
    2547:	jmp    2663 <botlish_fn_24+0x273>
    254c:	mov    rcx,r8
    254f:	mov    rsi,r14
    2552:	mov    rax,rsi
    2555:	and    rax,rcx
    2558:	test   rax,0x1
    255e:	jne    256f <botlish_fn_24+0x17f>
    2564:	mov    rdx,r8
    2567:	mov    rsi,r14
    256a:	jmp    258d <botlish_fn_24+0x19d>
    256f:	mov    rcx,r8
    2572:	lea    rax,[rcx-0x1]
    2576:	mov    rsi,r14
    2579:	add    rsi,rax
    257c:	seto   al
    257f:	test   al,al
    2581:	je     2598 <botlish_fn_24+0x1a8>
    2587:	mov    rdx,r8
    258a:	mov    rsi,r14
    258d:	mov    rdi,r13
    2590:	call   2595 <botlish_fn_24+0x1a5>
			2591: R_X86_64_PLT32	rt_int_add-0x4
    2595:	mov    rsi,rax
    2598:	mov    QWORD PTR [r12+0x8],rsi
    259d:	mov    QWORD PTR [r12+0x10],0x3
    25a6:	test   rsi,0x1
    25ad:	je     25d0 <botlish_fn_24+0x1e0>
    25b3:	mov    rax,rsi
    25b6:	add    rax,0x2
    25ba:	mov    rcx,rax
    25bd:	seto   al
    25c0:	test   al,al
    25c2:	jne    25d0 <botlish_fn_24+0x1e0>
    25c8:	mov    rsi,rcx
    25cb:	jmp    25e0 <botlish_fn_24+0x1f0>
    25d0:	mov    edx,0x3
    25d5:	mov    rdi,r13
    25d8:	call   25dd <botlish_fn_24+0x1ed>
			25d9: R_X86_64_PLT32	rt_int_add-0x4
    25dd:	mov    rsi,rax
    25e0:	mov    QWORD PTR [r12+0x8],rsi
    25e5:	mov    edx,0x7
    25ea:	mov    rcx,rdx
    25ed:	mov    QWORD PTR [r12+0x10],0x7
    25f6:	test   rsi,0x1
    25fd:	jne    260b <botlish_fn_24+0x21b>
    2603:	mov    rdx,rcx
    2606:	jmp    2639 <botlish_fn_24+0x249>
    260b:	mov    rax,rsi
    260e:	sar    rax,1
    2611:	imul   QWORD PTR [rip+0x160]        # 2778 <botlish_fn_24+0x388>
    2618:	seto   dil
    261c:	or     rax,0x1
    2620:	test   dil,dil
    2623:	je     2631 <botlish_fn_24+0x241>
    2629:	mov    rdx,rcx
    262c:	jmp    2639 <botlish_fn_24+0x249>
    2631:	mov    rsi,rax
    2634:	jmp    2644 <botlish_fn_24+0x254>
    2639:	mov    rdi,r13
    263c:	call   2641 <botlish_fn_24+0x251>
			263d: R_X86_64_PLT32	rt_int_mul-0x4
    2641:	mov    rsi,rax
    2644:	mov    QWORD PTR [r12+0x8],rsi
    2649:	mov    r14,rsi
    264c:	mov    rsi,rbx
    264f:	mov    rdi,r13
    2652:	call   2657 <botlish_fn_24+0x267>
			2653: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2657:	test   rax,rax
    265a:	jne    2688 <botlish_fn_24+0x298>
    2660:	mov    rdi,r13
    2663:	mov    rdi,r13
    2666:	mov    QWORD PTR [rdi],r12
    2669:	xor    rax,rax
    266c:	mov    rbx,QWORD PTR [rsp]
    2670:	mov    r12,QWORD PTR [rsp+0x8]
    2675:	mov    r13,QWORD PTR [rsp+0x10]
    267a:	mov    r14,QWORD PTR [rsp+0x18]
    267f:	add    rsp,0x20
    2683:	mov    rsp,rbp
    2686:	pop    rbp
    2687:	ret
    2688:	mov    QWORD PTR [r12],rax
    268c:	mov    QWORD PTR [r12+0x10],0x5
    2695:	test   rax,0x1
    269b:	mov    rsi,rax
    269e:	je     26ce <botlish_fn_24+0x2de>
    26a4:	mov    rcx,rsi
    26a7:	mov    rax,rcx
    26aa:	sar    rax,1
    26ad:	imul   QWORD PTR [rip+0xcc]        # 2780 <botlish_fn_24+0x390>
    26b4:	seto   cl
    26b7:	or     rax,0x1
    26bb:	test   cl,cl
    26bd:	jne    26ce <botlish_fn_24+0x2de>
    26c3:	mov    rdx,rax
    26c6:	mov    rsi,r14
    26c9:	jmp    26e1 <botlish_fn_24+0x2f1>
    26ce:	mov    edx,0x5
    26d3:	mov    rdi,r13
    26d6:	call   26db <botlish_fn_24+0x2eb>
			26d7: R_X86_64_PLT32	rt_int_mul-0x4
    26db:	mov    rdx,rax
    26de:	mov    rsi,r14
    26e1:	mov    rax,rsi
    26e4:	and    rax,rdx
    26e7:	test   rax,0x1
    26ed:	jne    2716 <botlish_fn_24+0x326>
    26f3:	mov    rdi,r13
    26f6:	call   26fb <botlish_fn_24+0x30b>
			26f7: R_X86_64_PLT32	rt_int_cmp-0x4
    26fb:	mov    ecx,0x2
    2700:	test   rax,rax
    2703:	mov    rax,rcx
    2706:	cmovg  rax,QWORD PTR [rip+0x6a]        # 2778 <botlish_fn_24+0x388>
    270e:	mov    rdi,r13
    2711:	jmp    2729 <botlish_fn_24+0x339>
    2716:	mov    eax,0x2
    271b:	cmp    rsi,rdx
    271e:	cmovg  rax,QWORD PTR [rip+0x52]        # 2778 <botlish_fn_24+0x388>
    2726:	mov    rdi,r13
    2729:	mov    rdi,r13
    272c:	mov    QWORD PTR [rdi],r12
    272f:	mov    rbx,QWORD PTR [rsp]
    2733:	mov    r12,QWORD PTR [rsp+0x8]
    2738:	mov    r13,QWORD PTR [rsp+0x10]
    273d:	mov    r14,QWORD PTR [rsp+0x18]
    2742:	add    rsp,0x20
    2746:	mov    rsp,rbp
    2749:	pop    rbp
    274a:	ret
    274b:	mov    r13,rdi
    274e:	call   2753 <botlish_fn_24+0x363>
			274f: R_X86_64_PLT32	rt_stack_overflow-0x4
    2753:	xor    rax,rax
    2756:	mov    rbx,QWORD PTR [rsp]
    275a:	mov    r12,QWORD PTR [rsp+0x8]
    275f:	mov    r13,QWORD PTR [rsp+0x10]
    2764:	mov    r14,QWORD PTR [rsp+0x18]
    2769:	add    rsp,0x20
    276d:	mov    rsp,rbp
    2770:	pop    rbp
    2771:	ret
    2772:	add    BYTE PTR [rax],al
    2774:	add    BYTE PTR [rax],al
    2776:	add    BYTE PTR [rax],al
    2778:	(bad)
    2779:	add    BYTE PTR [rax],al
    277b:	add    BYTE PTR [rax],al
    277d:	add    BYTE PTR [rax],al
    277f:	add    BYTE PTR [rax+rax*1],al
    2782:	add    BYTE PTR [rax],al
    2784:	add    BYTE PTR [rax],al
	...

0000000000002788 <botlish_entry_24: ht_should_grow<mutarray>>:
    2788:	push   rbp
    2789:	mov    rbp,rsp
    278c:	mov    rsi,QWORD PTR [rdx]
    278f:	call   2794 <botlish_entry_24+0xc>
			2790: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2794:	mov    rsp,rbp
    2797:	pop    rbp
    2798:	ret
    2799:	add    BYTE PTR [rax],al
    279b:	add    BYTE PTR [rax],al
    279d:	add    BYTE PTR [rax],al
	...

00000000000027a0 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    27a0:	push   rbp
    27a1:	mov    rbp,rsp
    27a4:	sub    rsp,0x20
    27a8:	mov    QWORD PTR [rsp],rbx
    27ac:	mov    QWORD PTR [rsp+0x8],r12
    27b1:	mov    QWORD PTR [rsp+0x10],r13
    27b6:	mov    QWORD PTR [rsp+0x18],r14
    27bb:	mov    rbx,QWORD PTR [rdi]
    27be:	mov    rax,QWORD PTR [rdi+0x8]
    27c2:	lea    rcx,[rbx+0x18]
    27c6:	cmp    rcx,rax
    27c9:	ja     2a6b <botlish_fn_25+0x2cb>
    27cf:	lea    rax,[rbx+0x18]
    27d3:	mov    QWORD PTR [rdi],rax
    27d6:	mov    r12,rdi
    27d9:	mov    QWORD PTR [rbx+0x8],0x0
    27e1:	mov    QWORD PTR [rbx+0x10],0x0
    27e9:	mov    QWORD PTR [rbx],rsi
    27ec:	mov    r13,rsi
    27ef:	mov    rsi,r13
    27f2:	mov    rdi,r12
    27f5:	call   27fa <botlish_fn_25+0x5a>
			27f6: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    27fa:	test   rax,rax
    27fd:	jne    280b <botlish_fn_25+0x6b>
    2803:	mov    rdi,r12
    2806:	jmp    2a21 <botlish_fn_25+0x281>
    280b:	mov    QWORD PTR [rbx+0x8],rax
    280f:	mov    r14,rax
    2812:	mov    rsi,r13
    2815:	mov    rdi,r12
    2818:	call   281d <botlish_fn_25+0x7d>
			2819: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    281d:	mov    rcx,rax
    2820:	test   rcx,rcx
    2823:	jne    2831 <botlish_fn_25+0x91>
    2829:	mov    rdi,r12
    282c:	jmp    2a21 <botlish_fn_25+0x281>
    2831:	mov    edx,0x1
    2836:	mov    rax,r14
    2839:	test   rax,0x1
    283f:	je     284d <botlish_fn_25+0xad>
    2845:	mov    r14,rax
    2848:	jmp    2871 <botlish_fn_25+0xd1>
    284d:	xor    edx,edx
    284f:	test   rax,0x7
    2855:	je     2863 <botlish_fn_25+0xc3>
    285b:	mov    r14,rax
    285e:	jmp    2871 <botlish_fn_25+0xd1>
    2863:	movzx  rdx,BYTE PTR [rax]
    2867:	mov    r14,rax
    286a:	rex cmp dl,0x1
    286e:	sete   dl
    2871:	test   dl,dl
    2873:	jne    2897 <botlish_fn_25+0xf7>
    2879:	mov    rdi,r12
    287c:	mov    rax,QWORD PTR [rdi+0x10]
    2880:	mov    rcx,QWORD PTR [rax+0x18]
    2884:	xor    rdx,rdx
    2887:	mov    rsi,r14
    288a:	call   288f <botlish_fn_25+0xef>
			288b: R_X86_64_PLT32	rt_type_error-0x4
    288f:	mov    rdi,r12
    2892:	jmp    2a21 <botlish_fn_25+0x281>
    2897:	mov    rsi,r14
    289a:	mov    eax,0x1
    289f:	test   rcx,0x1
    28a6:	je     28b4 <botlish_fn_25+0x114>
    28ac:	mov    r9,rcx
    28af:	jmp    28d7 <botlish_fn_25+0x137>
    28b4:	xor    eax,eax
    28b6:	test   rcx,0x7
    28bd:	je     28cb <botlish_fn_25+0x12b>
    28c3:	mov    r9,rcx
    28c6:	jmp    28d7 <botlish_fn_25+0x137>
    28cb:	movzx  rax,BYTE PTR [rcx]
    28cf:	mov    r9,rcx
    28d2:	cmp    al,0x1
    28d4:	sete   al
    28d7:	test   al,al
    28d9:	jne    28fd <botlish_fn_25+0x15d>
    28df:	mov    rdi,r12
    28e2:	mov    rax,QWORD PTR [rdi+0x10]
    28e6:	mov    rcx,QWORD PTR [rax+0x18]
    28ea:	xor    rdx,rdx
    28ed:	mov    rsi,r9
    28f0:	call   28f5 <botlish_fn_25+0x155>
			28f1: R_X86_64_PLT32	rt_type_error-0x4
    28f5:	mov    rdi,r12
    28f8:	jmp    2a21 <botlish_fn_25+0x281>
    28fd:	mov    rcx,r9
    2900:	mov    rax,rsi
    2903:	and    rax,rcx
    2906:	test   rax,0x1
    290c:	jne    2933 <botlish_fn_25+0x193>
    2912:	mov    rdx,r9
    2915:	mov    rdi,r12
    2918:	call   291d <botlish_fn_25+0x17d>
			2919: R_X86_64_PLT32	rt_int_cmp-0x4
    291d:	mov    r8d,0x2
    2923:	test   rax,rax
    2926:	cmovg  r8,QWORD PTR [rip+0x16a]        # 2a98 <botlish_fn_25+0x2f8>
    292e:	jmp    2947 <botlish_fn_25+0x1a7>
    2933:	mov    r8d,0x2
    2939:	mov    rcx,r9
    293c:	cmp    rsi,rcx
    293f:	cmovg  r8,QWORD PTR [rip+0x151]        # 2a98 <botlish_fn_25+0x2f8>
    2947:	cmp    r8,0x6
    294b:	je     29e7 <botlish_fn_25+0x247>
    2951:	mov    rsi,r13
    2954:	mov    rdi,r12
    2957:	call   295c <botlish_fn_25+0x1bc>
			2958: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    295c:	test   rax,rax
    295f:	jne    296d <botlish_fn_25+0x1cd>
    2965:	mov    rdi,r12
    2968:	jmp    2a21 <botlish_fn_25+0x281>
    296d:	mov    QWORD PTR [rbx+0x8],rax
    2971:	mov    QWORD PTR [rbx+0x10],0x5
    2979:	test   rax,0x1
    297f:	mov    rsi,rax
    2982:	je     29af <botlish_fn_25+0x20f>
    2988:	mov    rcx,rsi
    298b:	mov    rax,rcx
    298e:	sar    rax,1
    2991:	imul   QWORD PTR [rip+0x108]        # 2aa0 <botlish_fn_25+0x300>
    2998:	seto   cl
    299b:	or     rax,0x1
    299f:	test   cl,cl
    29a1:	jne    29af <botlish_fn_25+0x20f>
    29a7:	mov    rdx,rax
    29aa:	jmp    29bf <botlish_fn_25+0x21f>
    29af:	mov    edx,0x5
    29b4:	mov    rdi,r12
    29b7:	call   29bc <botlish_fn_25+0x21c>
			29b8: R_X86_64_PLT32	rt_int_mul-0x4
    29bc:	mov    rdx,rax
    29bf:	mov    QWORD PTR [rbx+0x8],rdx
    29c3:	mov    rsi,r13
    29c6:	mov    rdi,r12
    29c9:	call   29ce <botlish_fn_25+0x22e>
			29ca: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    29ce:	test   rax,rax
    29d1:	jne    29df <botlish_fn_25+0x23f>
    29d7:	mov    rdi,r12
    29da:	jmp    2a21 <botlish_fn_25+0x281>
    29df:	mov    rdi,r12
    29e2:	jmp    2a49 <botlish_fn_25+0x2a9>
    29e7:	mov    rsi,r13
    29ea:	mov    rdi,r12
    29ed:	call   29f2 <botlish_fn_25+0x252>
			29ee: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    29f2:	test   rax,rax
    29f5:	jne    2a03 <botlish_fn_25+0x263>
    29fb:	mov    rdi,r12
    29fe:	jmp    2a21 <botlish_fn_25+0x281>
    2a03:	mov    QWORD PTR [rbx+0x8],rax
    2a07:	mov    rdx,rax
    2a0a:	mov    rsi,r13
    2a0d:	mov    rdi,r12
    2a10:	call   2a15 <botlish_fn_25+0x275>
			2a11: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2a15:	test   rax,rax
    2a18:	jne    2a46 <botlish_fn_25+0x2a6>
    2a1e:	mov    rdi,r12
    2a21:	mov    rdi,r12
    2a24:	mov    QWORD PTR [rdi],rbx
    2a27:	xor    rax,rax
    2a2a:	mov    rbx,QWORD PTR [rsp]
    2a2e:	mov    r12,QWORD PTR [rsp+0x8]
    2a33:	mov    r13,QWORD PTR [rsp+0x10]
    2a38:	mov    r14,QWORD PTR [rsp+0x18]
    2a3d:	add    rsp,0x20
    2a41:	mov    rsp,rbp
    2a44:	pop    rbp
    2a45:	ret
    2a46:	mov    rdi,r12
    2a49:	mov    rdi,r12
    2a4c:	mov    QWORD PTR [rdi],rbx
    2a4f:	mov    rbx,QWORD PTR [rsp]
    2a53:	mov    r12,QWORD PTR [rsp+0x8]
    2a58:	mov    r13,QWORD PTR [rsp+0x10]
    2a5d:	mov    r14,QWORD PTR [rsp+0x18]
    2a62:	add    rsp,0x20
    2a66:	mov    rsp,rbp
    2a69:	pop    rbp
    2a6a:	ret
    2a6b:	mov    r12,rdi
    2a6e:	call   2a73 <botlish_fn_25+0x2d3>
			2a6f: R_X86_64_PLT32	rt_stack_overflow-0x4
    2a73:	xor    rax,rax
    2a76:	mov    rbx,QWORD PTR [rsp]
    2a7a:	mov    r12,QWORD PTR [rsp+0x8]
    2a7f:	mov    r13,QWORD PTR [rsp+0x10]
    2a84:	mov    r14,QWORD PTR [rsp+0x18]
    2a89:	add    rsp,0x20
    2a8d:	mov    rsp,rbp
    2a90:	pop    rbp
    2a91:	ret
    2a92:	add    BYTE PTR [rax],al
    2a94:	add    BYTE PTR [rax],al
    2a96:	add    BYTE PTR [rax],al
    2a98:	(bad)
    2a99:	add    BYTE PTR [rax],al
    2a9b:	add    BYTE PTR [rax],al
    2a9d:	add    BYTE PTR [rax],al
    2a9f:	add    BYTE PTR [rax+rax*1],al
    2aa2:	add    BYTE PTR [rax],al
    2aa4:	add    BYTE PTR [rax],al
	...

0000000000002aa8 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    2aa8:	push   rbp
    2aa9:	mov    rbp,rsp
    2aac:	mov    rsi,QWORD PTR [rdx]
    2aaf:	call   2ab4 <botlish_entry_25+0xc>
			2ab0: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    2ab4:	mov    rsp,rbp
    2ab7:	pop    rbp
    2ab8:	ret
    2ab9:	add    BYTE PTR [rax],al
    2abb:	add    BYTE PTR [rax],al
    2abd:	add    BYTE PTR [rax],al
	...

0000000000002ac0 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    2ac0:	push   rbp
    2ac1:	mov    rbp,rsp
    2ac4:	sub    rsp,0x50
    2ac8:	mov    QWORD PTR [rsp+0x20],rbx
    2acd:	mov    QWORD PTR [rsp+0x28],r12
    2ad2:	mov    QWORD PTR [rsp+0x30],r13
    2ad7:	mov    QWORD PTR [rsp+0x38],r14
    2adc:	mov    QWORD PTR [rsp+0x40],r15
    2ae1:	mov    r12,QWORD PTR [rdi]
    2ae4:	mov    rax,QWORD PTR [rdi+0x8]
    2ae8:	lea    r9,[r12+0x30]
    2aed:	cmp    r9,rax
    2af0:	ja     2fb2 <botlish_fn_26+0x4f2>
    2af6:	lea    rax,[r12+0x30]
    2afb:	mov    QWORD PTR [rdi],rax
    2afe:	mov    r13,rdi
    2b01:	mov    QWORD PTR [r12+0x20],0x0
    2b0a:	mov    QWORD PTR [r12+0x28],0x0
    2b13:	mov    QWORD PTR [r12],rsi
    2b17:	mov    r14,rsi
    2b1a:	mov    QWORD PTR [r12+0x8],rdx
    2b1f:	mov    QWORD PTR [rsp],rdx
    2b23:	mov    QWORD PTR [r12+0x10],rcx
    2b28:	mov    QWORD PTR [rsp+0x8],rcx
    2b2d:	mov    QWORD PTR [r12+0x18],r8
    2b32:	mov    r15,r8
    2b35:	mov    rsi,r14
    2b38:	mov    rdi,r13
    2b3b:	call   2b40 <botlish_fn_26+0x80>
			2b3c: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    2b40:	test   rax,rax
    2b43:	jne    2b51 <botlish_fn_26+0x91>
    2b49:	mov    rdi,r13
    2b4c:	jmp    2f57 <botlish_fn_26+0x497>
    2b51:	mov    QWORD PTR [r12+0x20],rax
    2b56:	xor    ecx,ecx
    2b58:	test   rax,0x7
    2b5e:	je     2b6e <botlish_fn_26+0xae>
    2b64:	mov    QWORD PTR [rsp+0x10],rax
    2b69:	jmp    2b7e <botlish_fn_26+0xbe>
    2b6e:	movzx  rcx,BYTE PTR [rax]
    2b72:	mov    QWORD PTR [rsp+0x10],rax
    2b77:	rex cmp cl,0x8
    2b7b:	sete   cl
    2b7e:	test   cl,cl
    2b80:	jne    2ba8 <botlish_fn_26+0xe8>
    2b86:	mov    rdi,r13
    2b89:	mov    rax,QWORD PTR [rdi+0x10]
    2b8d:	mov    rcx,QWORD PTR [rax+0x8]
    2b91:	mov    edx,0x8
    2b96:	mov    rsi,QWORD PTR [rsp+0x10]
    2b9b:	call   2ba0 <botlish_fn_26+0xe0>
			2b9c: R_X86_64_PLT32	rt_type_error-0x4
    2ba0:	mov    rdi,r13
    2ba3:	jmp    2f57 <botlish_fn_26+0x497>
    2ba8:	mov    rdx,QWORD PTR [rsp]
    2bac:	mov    rsi,QWORD PTR [rsp+0x10]
    2bb1:	mov    rdi,r13
    2bb4:	call   2bb9 <botlish_fn_26+0xf9>
			2bb5: R_X86_64_PLT32	rt_mutarray_get-0x4
    2bb9:	mov    rbx,rax
    2bbc:	test   rbx,rbx
    2bbf:	jne    2bcd <botlish_fn_26+0x10d>
    2bc5:	mov    rdi,r13
    2bc8:	jmp    2f57 <botlish_fn_26+0x497>
    2bcd:	mov    QWORD PTR [r12+0x28],rbx
    2bd2:	mov    rdi,r13
    2bd5:	call   2bda <botlish_fn_26+0x11a>
			2bd6: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    2bda:	test   rax,rax
    2bdd:	mov    rcx,rax
    2be0:	jne    2bee <botlish_fn_26+0x12e>
    2be6:	mov    rdi,r13
    2be9:	jmp    2f57 <botlish_fn_26+0x497>
    2bee:	mov    rsi,QWORD PTR [rsp+0x10]
    2bf3:	mov    rdx,QWORD PTR [rsp]
    2bf7:	mov    rdi,r13
    2bfa:	call   2bff <botlish_fn_26+0x13f>
			2bfb: R_X86_64_PLT32	rt_mutarray_set-0x4
    2bff:	test   rax,rax
    2c02:	jne    2c10 <botlish_fn_26+0x150>
    2c08:	mov    rdi,r13
    2c0b:	jmp    2f57 <botlish_fn_26+0x497>
    2c10:	mov    rsi,r14
    2c13:	mov    rdi,r13
    2c16:	call   2c1b <botlish_fn_26+0x15b>
			2c17: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2c1b:	test   rax,rax
    2c1e:	jne    2c2c <botlish_fn_26+0x16c>
    2c24:	mov    rdi,r13
    2c27:	jmp    2f57 <botlish_fn_26+0x497>
    2c2c:	xor    ecx,ecx
    2c2e:	test   rax,0x7
    2c34:	je     2c42 <botlish_fn_26+0x182>
    2c3a:	mov    rsi,rax
    2c3d:	jmp    2c50 <botlish_fn_26+0x190>
    2c42:	movzx  rdi,BYTE PTR [rax]
    2c46:	mov    rsi,rax
    2c49:	cmp    dil,0x8
    2c4d:	sete   cl
    2c50:	test   cl,cl
    2c52:	jne    2c75 <botlish_fn_26+0x1b5>
    2c58:	mov    rdi,r13
    2c5b:	mov    r11,QWORD PTR [rdi+0x10]
    2c5f:	mov    rcx,QWORD PTR [r11+0x20]
    2c63:	mov    edx,0x8
    2c68:	call   2c6d <botlish_fn_26+0x1ad>
			2c69: R_X86_64_PLT32	rt_type_error-0x4
    2c6d:	mov    rdi,r13
    2c70:	jmp    2f57 <botlish_fn_26+0x497>
    2c75:	mov    rcx,QWORD PTR [rsp+0x8]
    2c7a:	mov    rdx,QWORD PTR [rsp]
    2c7e:	mov    rdi,r13
    2c81:	call   2c86 <botlish_fn_26+0x1c6>
			2c82: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c86:	test   rax,rax
    2c89:	jne    2c97 <botlish_fn_26+0x1d7>
    2c8f:	mov    rdi,r13
    2c92:	jmp    2f57 <botlish_fn_26+0x497>
    2c97:	mov    rsi,r14
    2c9a:	mov    rdi,r13
    2c9d:	call   2ca2 <botlish_fn_26+0x1e2>
			2c9e: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2ca2:	test   rax,rax
    2ca5:	jne    2cb3 <botlish_fn_26+0x1f3>
    2cab:	mov    rdi,r13
    2cae:	jmp    2f57 <botlish_fn_26+0x497>
    2cb3:	xor    ecx,ecx
    2cb5:	test   rax,0x7
    2cbb:	je     2cc9 <botlish_fn_26+0x209>
    2cc1:	mov    rsi,rax
    2cc4:	jmp    2cd7 <botlish_fn_26+0x217>
    2cc9:	movzx  rcx,BYTE PTR [rax]
    2ccd:	mov    rsi,rax
    2cd0:	rex cmp cl,0x8
    2cd4:	sete   cl
    2cd7:	test   cl,cl
    2cd9:	jne    2cfc <botlish_fn_26+0x23c>
    2cdf:	mov    rdi,r13
    2ce2:	mov    rax,QWORD PTR [rdi+0x10]
    2ce6:	mov    rcx,QWORD PTR [rax+0x20]
    2cea:	mov    edx,0x8
    2cef:	call   2cf4 <botlish_fn_26+0x234>
			2cf0: R_X86_64_PLT32	rt_type_error-0x4
    2cf4:	mov    rdi,r13
    2cf7:	jmp    2f57 <botlish_fn_26+0x497>
    2cfc:	mov    rcx,r15
    2cff:	mov    rdx,QWORD PTR [rsp]
    2d03:	mov    rdi,r13
    2d06:	call   2d0b <botlish_fn_26+0x24b>
			2d07: R_X86_64_PLT32	rt_mutarray_set-0x4
    2d0b:	test   rax,rax
    2d0e:	jne    2d1c <botlish_fn_26+0x25c>
    2d14:	mov    rdi,r13
    2d17:	jmp    2f57 <botlish_fn_26+0x497>
    2d1c:	mov    QWORD PTR [r12+0x8],0x7
    2d25:	mov    rsi,r14
    2d28:	mov    rdi,r13
    2d2b:	call   2d30 <botlish_fn_26+0x270>
			2d2c: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2d30:	test   rax,rax
    2d33:	jne    2d41 <botlish_fn_26+0x281>
    2d39:	mov    rdi,r13
    2d3c:	jmp    2f57 <botlish_fn_26+0x497>
    2d41:	mov    QWORD PTR [r12+0x10],rax
    2d46:	mov    QWORD PTR [r12+0x18],0x3
    2d4f:	mov    ecx,0x1
    2d54:	test   rax,0x1
    2d5a:	je     2d68 <botlish_fn_26+0x2a8>
    2d60:	mov    rsi,rax
    2d63:	jmp    2d8c <botlish_fn_26+0x2cc>
    2d68:	xor    ecx,ecx
    2d6a:	test   rax,0x7
    2d70:	je     2d7e <botlish_fn_26+0x2be>
    2d76:	mov    rsi,rax
    2d79:	jmp    2d8c <botlish_fn_26+0x2cc>
    2d7e:	movzx  rcx,BYTE PTR [rax]
    2d82:	mov    rsi,rax
    2d85:	rex cmp cl,0x1
    2d89:	sete   cl
    2d8c:	test   cl,cl
    2d8e:	jne    2daf <botlish_fn_26+0x2ef>
    2d94:	mov    rdi,r13
    2d97:	mov    rax,QWORD PTR [rdi+0x10]
    2d9b:	mov    rcx,QWORD PTR [rax+0x10]
    2d9f:	xor    rdx,rdx
    2da2:	call   2da7 <botlish_fn_26+0x2e7>
			2da3: R_X86_64_PLT32	rt_type_error-0x4
    2da7:	mov    rdi,r13
    2daa:	jmp    2f57 <botlish_fn_26+0x497>
    2daf:	test   rsi,0x1
    2db6:	je     2dce <botlish_fn_26+0x30e>
    2dbc:	mov    rcx,rsi
    2dbf:	add    rcx,0x2
    2dc3:	seto   al
    2dc6:	test   al,al
    2dc8:	je     2dde <botlish_fn_26+0x31e>
    2dce:	mov    edx,0x3
    2dd3:	mov    rdi,r13
    2dd6:	call   2ddb <botlish_fn_26+0x31b>
			2dd7: R_X86_64_PLT32	rt_int_add-0x4
    2ddb:	mov    rcx,rax
    2dde:	mov    edx,0x7
    2de3:	mov    rsi,r14
    2de6:	mov    rdi,r13
    2de9:	call   2dee <botlish_fn_26+0x32e>
			2dea: R_X86_64_PLT32	rt_mutarray_set-0x4
    2dee:	test   rax,rax
    2df1:	jne    2dff <botlish_fn_26+0x33f>
    2df7:	mov    rdi,r13
    2dfa:	jmp    2f57 <botlish_fn_26+0x497>
    2dff:	mov    rdi,r13
    2e02:	call   2e07 <botlish_fn_26+0x347>
			2e03: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    2e07:	test   rax,rax
    2e0a:	jne    2e18 <botlish_fn_26+0x358>
    2e10:	mov    rdi,r13
    2e13:	jmp    2f57 <botlish_fn_26+0x497>
    2e18:	mov    rcx,rbx
    2e1b:	and    rcx,rax
    2e1e:	mov    rdx,rax
    2e21:	mov    rax,rbx
    2e24:	test   rcx,0x1
    2e2b:	jne    2e4d <botlish_fn_26+0x38d>
    2e31:	mov    rsi,rax
    2e34:	mov    rdi,r13
    2e37:	call   2e3c <botlish_fn_26+0x37c>
			2e38: R_X86_64_PLT32	rt_value_eq-0x4
    2e3c:	test   rax,rax
    2e3f:	jne    2e60 <botlish_fn_26+0x3a0>
    2e45:	mov    rdi,r13
    2e48:	jmp    2f57 <botlish_fn_26+0x497>
    2e4d:	mov    rsi,rax
    2e50:	mov    eax,0x2
    2e55:	cmp    rsi,rdx
    2e58:	cmove  rax,QWORD PTR [rip+0x180]        # 2fe0 <botlish_fn_26+0x520>
    2e60:	cmp    rax,0x6
    2e64:	je     2e72 <botlish_fn_26+0x3b2>
    2e6a:	mov    rdi,r13
    2e6d:	jmp    2f85 <botlish_fn_26+0x4c5>
    2e72:	mov    QWORD PTR [r12+0x8],0x9
    2e7b:	mov    rsi,r14
    2e7e:	mov    rdi,r13
    2e81:	call   2e86 <botlish_fn_26+0x3c6>
			2e82: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2e86:	test   rax,rax
    2e89:	jne    2e97 <botlish_fn_26+0x3d7>
    2e8f:	mov    rdi,r13
    2e92:	jmp    2f57 <botlish_fn_26+0x497>
    2e97:	mov    QWORD PTR [r12+0x10],rax
    2e9c:	mov    QWORD PTR [r12+0x18],0x3
    2ea5:	mov    ecx,0x1
    2eaa:	test   rax,0x1
    2eb0:	je     2ebe <botlish_fn_26+0x3fe>
    2eb6:	mov    rsi,rax
    2eb9:	jmp    2ee2 <botlish_fn_26+0x422>
    2ebe:	xor    ecx,ecx
    2ec0:	test   rax,0x7
    2ec6:	je     2ed4 <botlish_fn_26+0x414>
    2ecc:	mov    rsi,rax
    2ecf:	jmp    2ee2 <botlish_fn_26+0x422>
    2ed4:	movzx  rcx,BYTE PTR [rax]
    2ed8:	mov    rsi,rax
    2edb:	rex cmp cl,0x1
    2edf:	sete   cl
    2ee2:	test   cl,cl
    2ee4:	jne    2f05 <botlish_fn_26+0x445>
    2eea:	mov    rdi,r13
    2eed:	mov    rax,QWORD PTR [rdi+0x10]
    2ef1:	mov    rcx,QWORD PTR [rax+0x28]
    2ef5:	xor    rdx,rdx
    2ef8:	call   2efd <botlish_fn_26+0x43d>
			2ef9: R_X86_64_PLT32	rt_type_error-0x4
    2efd:	mov    rdi,r13
    2f00:	jmp    2f57 <botlish_fn_26+0x497>
    2f05:	test   rsi,0x1
    2f0c:	je     2f2b <botlish_fn_26+0x46b>
    2f12:	mov    rcx,rsi
    2f15:	sub    rcx,0x3
    2f19:	seto   al
    2f1c:	add    rcx,0x1
    2f23:	test   al,al
    2f25:	je     2f3b <botlish_fn_26+0x47b>
    2f2b:	mov    edx,0x3
    2f30:	mov    rdi,r13
    2f33:	call   2f38 <botlish_fn_26+0x478>
			2f34: R_X86_64_PLT32	rt_int_sub-0x4
    2f38:	mov    rcx,rax
    2f3b:	mov    edx,0x9
    2f40:	mov    rsi,r14
    2f43:	mov    rdi,r13
    2f46:	call   2f4b <botlish_fn_26+0x48b>
			2f47: R_X86_64_PLT32	rt_mutarray_set-0x4
    2f4b:	test   rax,rax
    2f4e:	jne    2f82 <botlish_fn_26+0x4c2>
    2f54:	mov    rdi,r13
    2f57:	mov    rdi,r13
    2f5a:	mov    QWORD PTR [rdi],r12
    2f5d:	xor    rax,rax
    2f60:	mov    rbx,QWORD PTR [rsp+0x20]
    2f65:	mov    r12,QWORD PTR [rsp+0x28]
    2f6a:	mov    r13,QWORD PTR [rsp+0x30]
    2f6f:	mov    r14,QWORD PTR [rsp+0x38]
    2f74:	mov    r15,QWORD PTR [rsp+0x40]
    2f79:	add    rsp,0x50
    2f7d:	mov    rsp,rbp
    2f80:	pop    rbp
    2f81:	ret
    2f82:	mov    rdi,r13
    2f85:	mov    rdi,r13
    2f88:	mov    QWORD PTR [rdi],r12
    2f8b:	mov    eax,0xa
    2f90:	mov    rbx,QWORD PTR [rsp+0x20]
    2f95:	mov    r12,QWORD PTR [rsp+0x28]
    2f9a:	mov    r13,QWORD PTR [rsp+0x30]
    2f9f:	mov    r14,QWORD PTR [rsp+0x38]
    2fa4:	mov    r15,QWORD PTR [rsp+0x40]
    2fa9:	add    rsp,0x50
    2fad:	mov    rsp,rbp
    2fb0:	pop    rbp
    2fb1:	ret
    2fb2:	mov    r13,rdi
    2fb5:	call   2fba <botlish_fn_26+0x4fa>
			2fb6: R_X86_64_PLT32	rt_stack_overflow-0x4
    2fba:	xor    rax,rax
    2fbd:	mov    rbx,QWORD PTR [rsp+0x20]
    2fc2:	mov    r12,QWORD PTR [rsp+0x28]
    2fc7:	mov    r13,QWORD PTR [rsp+0x30]
    2fcc:	mov    r14,QWORD PTR [rsp+0x38]
    2fd1:	mov    r15,QWORD PTR [rsp+0x40]
    2fd6:	add    rsp,0x50
    2fda:	mov    rsp,rbp
    2fdd:	pop    rbp
    2fde:	ret
    2fdf:	add    BYTE PTR [rsi],al
    2fe1:	add    BYTE PTR [rax],al
    2fe3:	add    BYTE PTR [rax],al
    2fe5:	add    BYTE PTR [rax],al
	...

0000000000002fe8 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    2fe8:	push   rbp
    2fe9:	mov    rbp,rsp
    2fec:	mov    rsi,QWORD PTR [rdx]
    2fef:	mov    r9,QWORD PTR [rdx+0x8]
    2ff3:	mov    rcx,QWORD PTR [rdx+0x10]
    2ff7:	mov    r8,QWORD PTR [rdx+0x18]
    2ffb:	mov    rdx,r9
    2ffe:	call   3003 <botlish_entry_26+0x1b>
			2fff: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    3003:	mov    rsp,rbp
    3006:	pop    rbp
    3007:	ret

0000000000003008 <botlish_fn_27: ht_set<mutarray, str, str>>:
    3008:	push   rbp
    3009:	mov    rbp,rsp
    300c:	sub    rsp,0x50
    3010:	mov    QWORD PTR [rsp+0x20],rbx
    3015:	mov    QWORD PTR [rsp+0x28],r12
    301a:	mov    QWORD PTR [rsp+0x30],r13
    301f:	mov    QWORD PTR [rsp+0x38],r14
    3024:	mov    QWORD PTR [rsp+0x40],r15
    3029:	mov    rbx,QWORD PTR [rdi]
    302c:	mov    rax,QWORD PTR [rdi+0x8]
    3030:	lea    r8,[rbx+0x28]
    3034:	cmp    r8,rax
    3037:	ja     33d9 <botlish_fn_27+0x3d1>
    303d:	lea    rax,[rbx+0x28]
    3041:	mov    QWORD PTR [rdi],rax
    3044:	mov    r12,rdi
    3047:	mov    QWORD PTR [rbx+0x18],0x0
    304f:	mov    QWORD PTR [rbx+0x20],0x0
    3057:	mov    QWORD PTR [rbx],rsi
    305a:	mov    r15,rsi
    305d:	mov    QWORD PTR [rbx+0x8],rdx
    3061:	mov    r14,rdx
    3064:	mov    QWORD PTR [rbx+0x10],rcx
    3068:	mov    r13,rcx
    306b:	mov    rdx,r14
    306e:	mov    rsi,r15
    3071:	mov    rdi,r12
    3074:	call   3079 <botlish_fn_27+0x71>
			3075: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3079:	test   rax,rax
    307c:	jne    308a <botlish_fn_27+0x82>
    3082:	mov    rdi,r12
    3085:	jmp    3381 <botlish_fn_27+0x379>
    308a:	mov    QWORD PTR [rbx+0x18],rax
    308e:	mov    rcx,rax
    3091:	mov    r8,0xffffffffffffffff
    3098:	mov    QWORD PTR [rsp+0x10],r8
    309d:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    30a5:	mov    rdx,r14
    30a8:	mov    rsi,r15
    30ab:	mov    rdi,r12
    30ae:	call   30b3 <botlish_fn_27+0xab>
			30af: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    30b3:	mov    rcx,rax
    30b6:	mov    QWORD PTR [rsp+0x8],rax
    30bb:	test   rax,rcx
    30be:	jne    30cc <botlish_fn_27+0xc4>
    30c4:	mov    rdi,r12
    30c7:	jmp    3381 <botlish_fn_27+0x379>
    30cc:	mov    rax,QWORD PTR [rsp+0x8]
    30d1:	mov    QWORD PTR [rbx+0x18],rax
    30d5:	mov    rsi,r15
    30d8:	mov    rdi,r12
    30db:	call   30e0 <botlish_fn_27+0xd8>
			30dc: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    30e0:	test   rax,rax
    30e3:	jne    30f1 <botlish_fn_27+0xe9>
    30e9:	mov    rdi,r12
    30ec:	jmp    3381 <botlish_fn_27+0x379>
    30f1:	xor    ecx,ecx
    30f3:	test   rax,0x7
    30f9:	je     3107 <botlish_fn_27+0xff>
    30ff:	mov    rsi,rax
    3102:	jmp    3115 <botlish_fn_27+0x10d>
    3107:	movzx  rcx,BYTE PTR [rax]
    310b:	mov    rsi,rax
    310e:	rex cmp cl,0x8
    3112:	sete   cl
    3115:	test   cl,cl
    3117:	jne    313a <botlish_fn_27+0x132>
    311d:	mov    rdi,r12
    3120:	mov    rax,QWORD PTR [rdi+0x10]
    3124:	mov    rcx,QWORD PTR [rax+0x8]
    3128:	mov    edx,0x8
    312d:	call   3132 <botlish_fn_27+0x12a>
			312e: R_X86_64_PLT32	rt_type_error-0x4
    3132:	mov    rdi,r12
    3135:	jmp    3381 <botlish_fn_27+0x379>
    313a:	mov    rdx,QWORD PTR [rsp+0x8]
    313f:	mov    rdi,r12
    3142:	call   3147 <botlish_fn_27+0x13f>
			3143: R_X86_64_PLT32	rt_mutarray_get-0x4
    3147:	test   rax,rax
    314a:	jne    3158 <botlish_fn_27+0x150>
    3150:	mov    rdi,r12
    3153:	jmp    3381 <botlish_fn_27+0x379>
    3158:	mov    QWORD PTR [rbx+0x20],rax
    315c:	mov    QWORD PTR [rsp],rax
    3160:	mov    rdi,r12
    3163:	call   3168 <botlish_fn_27+0x160>
			3164: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    3168:	test   rax,rax
    316b:	jne    3179 <botlish_fn_27+0x171>
    3171:	mov    rdi,r12
    3174:	jmp    3381 <botlish_fn_27+0x379>
    3179:	mov    rcx,QWORD PTR [rsp]
    317d:	mov    rdx,rcx
    3180:	and    rdx,rax
    3183:	test   rdx,0x1
    318a:	jne    31b0 <botlish_fn_27+0x1a8>
    3190:	mov    rdx,rax
    3193:	mov    rsi,QWORD PTR [rsp]
    3197:	mov    rdi,r12
    319a:	call   319f <botlish_fn_27+0x197>
			319b: R_X86_64_PLT32	rt_value_eq-0x4
    319f:	test   rax,rax
    31a2:	jne    31c7 <botlish_fn_27+0x1bf>
    31a8:	mov    rdi,r12
    31ab:	jmp    3381 <botlish_fn_27+0x379>
    31b0:	mov    rdx,rax
    31b3:	mov    rsi,QWORD PTR [rsp]
    31b7:	mov    eax,0x2
    31bc:	cmp    rsi,rdx
    31bf:	cmove  rax,QWORD PTR [rip+0x241]        # 3408 <botlish_fn_27+0x400>
    31c7:	cmp    rax,0x6
    31cb:	je     3305 <botlish_fn_27+0x2fd>
    31d1:	mov    rsi,r15
    31d4:	mov    rdi,r12
    31d7:	call   31dc <botlish_fn_27+0x1d4>
			31d8: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    31dc:	test   rax,rax
    31df:	jne    31ed <botlish_fn_27+0x1e5>
    31e5:	mov    rdi,r12
    31e8:	jmp    3381 <botlish_fn_27+0x379>
    31ed:	cmp    rax,0x6
    31f1:	je     3246 <botlish_fn_27+0x23e>
    31f7:	mov    rcx,r14
    31fa:	mov    rdx,QWORD PTR [rsp+0x8]
    31ff:	mov    rsi,r15
    3202:	mov    r8,r13
    3205:	mov    rdi,r12
    3208:	call   320d <botlish_fn_27+0x205>
			3209: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    320d:	test   rax,rax
    3210:	jne    321e <botlish_fn_27+0x216>
    3216:	mov    rdi,r12
    3219:	jmp    3381 <botlish_fn_27+0x379>
    321e:	mov    rdi,r12
    3221:	mov    QWORD PTR [rdi],rbx
    3224:	mov    rbx,QWORD PTR [rsp+0x20]
    3229:	mov    r12,QWORD PTR [rsp+0x28]
    322e:	mov    r13,QWORD PTR [rsp+0x30]
    3233:	mov    r14,QWORD PTR [rsp+0x38]
    3238:	mov    r15,QWORD PTR [rsp+0x40]
    323d:	add    rsp,0x50
    3241:	mov    rsp,rbp
    3244:	pop    rbp
    3245:	ret
    3246:	mov    rsi,r15
    3249:	mov    rdi,r12
    324c:	call   3251 <botlish_fn_27+0x249>
			324d: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    3251:	test   rax,rax
    3254:	jne    3262 <botlish_fn_27+0x25a>
    325a:	mov    rdi,r12
    325d:	jmp    3381 <botlish_fn_27+0x379>
    3262:	mov    rdx,r14
    3265:	mov    rsi,r15
    3268:	mov    rdi,r12
    326b:	call   3270 <botlish_fn_27+0x268>
			326c: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3270:	test   rax,rax
    3273:	jne    3281 <botlish_fn_27+0x279>
    3279:	mov    rdi,r12
    327c:	jmp    3381 <botlish_fn_27+0x379>
    3281:	mov    QWORD PTR [rbx+0x18],rax
    3285:	mov    rcx,rax
    3288:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    3290:	mov    r8,QWORD PTR [rsp+0x10]
    3295:	mov    rdx,r14
    3298:	mov    rsi,r15
    329b:	mov    rdi,r12
    329e:	call   32a3 <botlish_fn_27+0x29b>
			329f: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    32a3:	test   rax,rax
    32a6:	jne    32b4 <botlish_fn_27+0x2ac>
    32ac:	mov    rdi,r12
    32af:	jmp    3381 <botlish_fn_27+0x379>
    32b4:	mov    QWORD PTR [rbx+0x18],rax
    32b8:	mov    rcx,r14
    32bb:	mov    rdx,rax
    32be:	mov    rsi,r15
    32c1:	mov    r8,r13
    32c4:	mov    rdi,r12
    32c7:	call   32cc <botlish_fn_27+0x2c4>
			32c8: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    32cc:	test   rax,rax
    32cf:	jne    32dd <botlish_fn_27+0x2d5>
    32d5:	mov    rdi,r12
    32d8:	jmp    3381 <botlish_fn_27+0x379>
    32dd:	mov    rdi,r12
    32e0:	mov    QWORD PTR [rdi],rbx
    32e3:	mov    rbx,QWORD PTR [rsp+0x20]
    32e8:	mov    r12,QWORD PTR [rsp+0x28]
    32ed:	mov    r13,QWORD PTR [rsp+0x30]
    32f2:	mov    r14,QWORD PTR [rsp+0x38]
    32f7:	mov    r15,QWORD PTR [rsp+0x40]
    32fc:	add    rsp,0x50
    3300:	mov    rsp,rbp
    3303:	pop    rbp
    3304:	ret
    3305:	mov    rsi,r15
    3308:	mov    rdi,r12
    330b:	call   3310 <botlish_fn_27+0x308>
			330c: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3310:	test   rax,rax
    3313:	jne    3321 <botlish_fn_27+0x319>
    3319:	mov    rdi,r12
    331c:	jmp    3381 <botlish_fn_27+0x379>
    3321:	xor    ecx,ecx
    3323:	test   rax,0x7
    3329:	jne    333a <botlish_fn_27+0x332>
    332f:	movzx  rsi,BYTE PTR [rax]
    3333:	cmp    sil,0x8
    3337:	sete   cl
    333a:	test   cl,cl
    333c:	jne    3362 <botlish_fn_27+0x35a>
    3342:	mov    rdi,r12
    3345:	mov    r10,QWORD PTR [rdi+0x10]
    3349:	mov    rcx,QWORD PTR [r10+0x20]
    334d:	mov    edx,0x8
    3352:	mov    rsi,rax
    3355:	call   335a <botlish_fn_27+0x352>
			3356: R_X86_64_PLT32	rt_type_error-0x4
    335a:	mov    rdi,r12
    335d:	jmp    3381 <botlish_fn_27+0x379>
    3362:	mov    rcx,r13
    3365:	mov    rdx,QWORD PTR [rsp+0x8]
    336a:	mov    rsi,rax
    336d:	mov    rdi,r12
    3370:	call   3375 <botlish_fn_27+0x36d>
			3371: R_X86_64_PLT32	rt_mutarray_set-0x4
    3375:	test   rax,rax
    3378:	jne    33ac <botlish_fn_27+0x3a4>
    337e:	mov    rdi,r12
    3381:	mov    rdi,r12
    3384:	mov    QWORD PTR [rdi],rbx
    3387:	xor    rax,rax
    338a:	mov    rbx,QWORD PTR [rsp+0x20]
    338f:	mov    r12,QWORD PTR [rsp+0x28]
    3394:	mov    r13,QWORD PTR [rsp+0x30]
    3399:	mov    r14,QWORD PTR [rsp+0x38]
    339e:	mov    r15,QWORD PTR [rsp+0x40]
    33a3:	add    rsp,0x50
    33a7:	mov    rsp,rbp
    33aa:	pop    rbp
    33ab:	ret
    33ac:	mov    rdi,r12
    33af:	mov    QWORD PTR [rdi],rbx
    33b2:	mov    eax,0xa
    33b7:	mov    rbx,QWORD PTR [rsp+0x20]
    33bc:	mov    r12,QWORD PTR [rsp+0x28]
    33c1:	mov    r13,QWORD PTR [rsp+0x30]
    33c6:	mov    r14,QWORD PTR [rsp+0x38]
    33cb:	mov    r15,QWORD PTR [rsp+0x40]
    33d0:	add    rsp,0x50
    33d4:	mov    rsp,rbp
    33d7:	pop    rbp
    33d8:	ret
    33d9:	mov    r12,rdi
    33dc:	call   33e1 <botlish_fn_27+0x3d9>
			33dd: R_X86_64_PLT32	rt_stack_overflow-0x4
    33e1:	xor    rax,rax
    33e4:	mov    rbx,QWORD PTR [rsp+0x20]
    33e9:	mov    r12,QWORD PTR [rsp+0x28]
    33ee:	mov    r13,QWORD PTR [rsp+0x30]
    33f3:	mov    r14,QWORD PTR [rsp+0x38]
    33f8:	mov    r15,QWORD PTR [rsp+0x40]
    33fd:	add    rsp,0x50
    3401:	mov    rsp,rbp
    3404:	pop    rbp
    3405:	ret
    3406:	add    BYTE PTR [rax],al
    3408:	(bad)
    3409:	add    BYTE PTR [rax],al
    340b:	add    BYTE PTR [rax],al
    340d:	add    BYTE PTR [rax],al
	...

0000000000003410 <botlish_entry_27: ht_set<mutarray, str, str>>:
    3410:	push   rbp
    3411:	mov    rbp,rsp
    3414:	mov    rsi,QWORD PTR [rdx]
    3417:	mov    r8,QWORD PTR [rdx+0x8]
    341b:	mov    rcx,QWORD PTR [rdx+0x10]
    341f:	mov    rdx,r8
    3422:	call   3427 <botlish_entry_27+0x17>
			3423: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3427:	mov    rsp,rbp
    342a:	pop    rbp
    342b:	ret
    342c:	add    BYTE PTR [rax],al
	...

0000000000003430 <botlish_fn_28: ht_delete<mutarray, str>>:
    3430:	push   rbp
    3431:	mov    rbp,rsp
    3434:	sub    rsp,0x30
    3438:	mov    QWORD PTR [rsp],rbx
    343c:	mov    QWORD PTR [rsp+0x8],r12
    3441:	mov    QWORD PTR [rsp+0x10],r13
    3446:	mov    QWORD PTR [rsp+0x18],r14
    344b:	mov    QWORD PTR [rsp+0x20],r15
    3450:	mov    rbx,QWORD PTR [rdi]
    3453:	mov    rax,QWORD PTR [rdi+0x8]
    3457:	lea    rcx,[rbx+0x20]
    345b:	cmp    rcx,rax
    345e:	ja     3933 <botlish_fn_28+0x503>
    3464:	lea    rax,[rbx+0x20]
    3468:	mov    QWORD PTR [rdi],rax
    346b:	mov    r12,rdi
    346e:	mov    QWORD PTR [rbx+0x10],0x0
    3476:	mov    QWORD PTR [rbx+0x18],0x0
    347e:	mov    QWORD PTR [rbx],rsi
    3481:	mov    r13,rsi
    3484:	mov    QWORD PTR [rbx+0x8],rdx
    3488:	mov    r14,rdx
    348b:	mov    rdx,r14
    348e:	mov    rsi,r13
    3491:	mov    rdi,r12
    3494:	call   3499 <botlish_fn_28+0x69>
			3495: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3499:	test   rax,rax
    349c:	jne    34aa <botlish_fn_28+0x7a>
    34a2:	mov    rdi,r12
    34a5:	jmp    38b1 <botlish_fn_28+0x481>
    34aa:	mov    QWORD PTR [rbx+0x10],rax
    34ae:	mov    rcx,rax
    34b1:	mov    rdx,r14
    34b4:	mov    rsi,r13
    34b7:	mov    rdi,r12
    34ba:	call   34bf <botlish_fn_28+0x8f>
			34bb: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    34bf:	mov    rcx,rax
    34c2:	mov    r14,rax
    34c5:	test   rax,rcx
    34c8:	jne    34d6 <botlish_fn_28+0xa6>
    34ce:	mov    rdi,r12
    34d1:	jmp    38b1 <botlish_fn_28+0x481>
    34d6:	mov    rax,r14
    34d9:	mov    QWORD PTR [rbx+0x8],rax
    34dd:	test   rax,0x1
    34e3:	jne    350e <botlish_fn_28+0xde>
    34e9:	mov    edx,0x1
    34ee:	mov    rsi,r14
    34f1:	mov    rdi,r12
    34f4:	call   34f9 <botlish_fn_28+0xc9>
			34f5: R_X86_64_PLT32	rt_int_cmp-0x4
    34f9:	mov    ecx,0x2
    34fe:	test   rax,rax
    3501:	cmovl  rcx,QWORD PTR [rip+0x457]        # 3960 <botlish_fn_28+0x530>
    3509:	jmp    3524 <botlish_fn_28+0xf4>
    350e:	mov    ecx,0x2
    3513:	mov    rax,r14
    3516:	mov    rdx,r14
    3519:	test   rax,rdx
    351c:	cmovle rcx,QWORD PTR [rip+0x43c]        # 3960 <botlish_fn_28+0x530>
    3524:	cmp    rcx,0x6
    3528:	je     3907 <botlish_fn_28+0x4d7>
    352e:	mov    rsi,r13
    3531:	mov    rdi,r12
    3534:	call   3539 <botlish_fn_28+0x109>
			3535: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    3539:	test   rax,rax
    353c:	jne    354a <botlish_fn_28+0x11a>
    3542:	mov    rdi,r12
    3545:	jmp    38b1 <botlish_fn_28+0x481>
    354a:	mov    QWORD PTR [rbx+0x10],rax
    354e:	mov    r15,rax
    3551:	mov    rdi,r12
    3554:	call   3559 <botlish_fn_28+0x129>
			3555: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    3559:	test   rax,rax
    355c:	mov    rsi,rax
    355f:	jne    356d <botlish_fn_28+0x13d>
    3565:	mov    rdi,r12
    3568:	jmp    38b1 <botlish_fn_28+0x481>
    356d:	xor    ecx,ecx
    356f:	mov    rax,r15
    3572:	test   rax,0x7
    3578:	je     3586 <botlish_fn_28+0x156>
    357e:	mov    r15,rax
    3581:	jmp    3594 <botlish_fn_28+0x164>
    3586:	movzx  rdi,BYTE PTR [rax]
    358a:	mov    r15,rax
    358d:	cmp    dil,0x8
    3591:	sete   cl
    3594:	test   cl,cl
    3596:	jne    35bc <botlish_fn_28+0x18c>
    359c:	mov    rdi,r12
    359f:	mov    r11,QWORD PTR [rdi+0x10]
    35a3:	mov    rcx,QWORD PTR [r11+0x20]
    35a7:	mov    edx,0x8
    35ac:	mov    rsi,r15
    35af:	call   35b4 <botlish_fn_28+0x184>
			35b0: R_X86_64_PLT32	rt_type_error-0x4
    35b4:	mov    rdi,r12
    35b7:	jmp    38b1 <botlish_fn_28+0x481>
    35bc:	mov    rcx,rsi
    35bf:	mov    rsi,r15
    35c2:	mov    rdx,r14
    35c5:	mov    rdi,r12
    35c8:	call   35cd <botlish_fn_28+0x19d>
			35c9: R_X86_64_PLT32	rt_mutarray_set-0x4
    35cd:	test   rax,rax
    35d0:	jne    35de <botlish_fn_28+0x1ae>
    35d6:	mov    rdi,r12
    35d9:	jmp    38b1 <botlish_fn_28+0x481>
    35de:	mov    rsi,r13
    35e1:	mov    rdi,r12
    35e4:	call   35e9 <botlish_fn_28+0x1b9>
			35e5: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    35e9:	test   rax,rax
    35ec:	jne    35fa <botlish_fn_28+0x1ca>
    35f2:	mov    rdi,r12
    35f5:	jmp    38b1 <botlish_fn_28+0x481>
    35fa:	xor    ecx,ecx
    35fc:	test   rax,0x7
    3602:	je     3610 <botlish_fn_28+0x1e0>
    3608:	mov    rsi,rax
    360b:	jmp    361e <botlish_fn_28+0x1ee>
    3610:	movzx  rcx,BYTE PTR [rax]
    3614:	mov    rsi,rax
    3617:	rex cmp cl,0x8
    361b:	sete   cl
    361e:	test   cl,cl
    3620:	jne    3643 <botlish_fn_28+0x213>
    3626:	mov    rdi,r12
    3629:	mov    rax,QWORD PTR [rdi+0x10]
    362d:	mov    rcx,QWORD PTR [rax+0x20]
    3631:	mov    edx,0x8
    3636:	call   363b <botlish_fn_28+0x20b>
			3637: R_X86_64_PLT32	rt_type_error-0x4
    363b:	mov    rdi,r12
    363e:	jmp    38b1 <botlish_fn_28+0x481>
    3643:	mov    ecx,0xa
    3648:	mov    rdx,r14
    364b:	mov    rdi,r12
    364e:	call   3653 <botlish_fn_28+0x223>
			364f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3653:	test   rax,rax
    3656:	jne    3664 <botlish_fn_28+0x234>
    365c:	mov    rdi,r12
    365f:	jmp    38b1 <botlish_fn_28+0x481>
    3664:	mov    rsi,r13
    3667:	mov    rdi,r12
    366a:	call   366f <botlish_fn_28+0x23f>
			366b: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    366f:	test   rax,rax
    3672:	jne    3680 <botlish_fn_28+0x250>
    3678:	mov    rdi,r12
    367b:	jmp    38b1 <botlish_fn_28+0x481>
    3680:	xor    ecx,ecx
    3682:	test   rax,0x7
    3688:	je     3696 <botlish_fn_28+0x266>
    368e:	mov    rsi,rax
    3691:	jmp    36a4 <botlish_fn_28+0x274>
    3696:	movzx  rcx,BYTE PTR [rax]
    369a:	mov    rsi,rax
    369d:	rex cmp cl,0x8
    36a1:	sete   cl
    36a4:	test   cl,cl
    36a6:	jne    36c9 <botlish_fn_28+0x299>
    36ac:	mov    rdi,r12
    36af:	mov    rax,QWORD PTR [rdi+0x10]
    36b3:	mov    rcx,QWORD PTR [rax+0x20]
    36b7:	mov    edx,0x8
    36bc:	call   36c1 <botlish_fn_28+0x291>
			36bd: R_X86_64_PLT32	rt_type_error-0x4
    36c1:	mov    rdi,r12
    36c4:	jmp    38b1 <botlish_fn_28+0x481>
    36c9:	mov    ecx,0xa
    36ce:	mov    rdx,r14
    36d1:	mov    rdi,r12
    36d4:	call   36d9 <botlish_fn_28+0x2a9>
			36d5: R_X86_64_PLT32	rt_mutarray_set-0x4
    36d9:	test   rax,rax
    36dc:	jne    36ea <botlish_fn_28+0x2ba>
    36e2:	mov    rdi,r12
    36e5:	jmp    38b1 <botlish_fn_28+0x481>
    36ea:	mov    QWORD PTR [rbx+0x8],0x7
    36f2:	mov    rsi,r13
    36f5:	mov    rdi,r12
    36f8:	call   36fd <botlish_fn_28+0x2cd>
			36f9: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    36fd:	test   rax,rax
    3700:	jne    370e <botlish_fn_28+0x2de>
    3706:	mov    rdi,r12
    3709:	jmp    38b1 <botlish_fn_28+0x481>
    370e:	mov    QWORD PTR [rbx+0x10],rax
    3712:	mov    QWORD PTR [rbx+0x18],0x3
    371a:	mov    esi,0x1
    371f:	test   rax,0x1
    3725:	je     3733 <botlish_fn_28+0x303>
    372b:	mov    r8,rax
    372e:	jmp    3758 <botlish_fn_28+0x328>
    3733:	xor    esi,esi
    3735:	test   rax,0x7
    373b:	je     3749 <botlish_fn_28+0x319>
    3741:	mov    r8,rax
    3744:	jmp    3758 <botlish_fn_28+0x328>
    3749:	movzx  rcx,BYTE PTR [rax]
    374d:	mov    r8,rax
    3750:	rex cmp cl,0x1
    3754:	sete   sil
    3758:	test   sil,sil
    375b:	jne    377f <botlish_fn_28+0x34f>
    3761:	mov    rdi,r12
    3764:	mov    rax,QWORD PTR [rdi+0x10]
    3768:	mov    rcx,QWORD PTR [rax+0x28]
    376c:	xor    rdx,rdx
    376f:	mov    rsi,r8
    3772:	call   3777 <botlish_fn_28+0x347>
			3773: R_X86_64_PLT32	rt_type_error-0x4
    3777:	mov    rdi,r12
    377a:	jmp    38b1 <botlish_fn_28+0x481>
    377f:	mov    rsi,r8
    3782:	test   rsi,0x1
    3789:	je     37a5 <botlish_fn_28+0x375>
    378f:	mov    rax,rsi
    3792:	sub    rax,0x3
    3796:	seto   dl
    3799:	lea    rcx,[rax+0x1]
    379d:	test   dl,dl
    379f:	je     37b5 <botlish_fn_28+0x385>
    37a5:	mov    edx,0x3
    37aa:	mov    rdi,r12
    37ad:	call   37b2 <botlish_fn_28+0x382>
			37ae: R_X86_64_PLT32	rt_int_sub-0x4
    37b2:	mov    rcx,rax
    37b5:	mov    edx,0x7
    37ba:	mov    rsi,r13
    37bd:	mov    rdi,r12
    37c0:	call   37c5 <botlish_fn_28+0x395>
			37c1: R_X86_64_PLT32	rt_mutarray_set-0x4
    37c5:	test   rax,rax
    37c8:	jne    37d6 <botlish_fn_28+0x3a6>
    37ce:	mov    rdi,r12
    37d1:	jmp    38b1 <botlish_fn_28+0x481>
    37d6:	mov    QWORD PTR [rbx+0x8],0x9
    37de:	mov    rsi,r13
    37e1:	mov    rdi,r12
    37e4:	call   37e9 <botlish_fn_28+0x3b9>
			37e5: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    37e9:	test   rax,rax
    37ec:	jne    37fa <botlish_fn_28+0x3ca>
    37f2:	mov    rdi,r12
    37f5:	jmp    38b1 <botlish_fn_28+0x481>
    37fa:	mov    QWORD PTR [rbx+0x10],rax
    37fe:	mov    QWORD PTR [rbx+0x18],0x3
    3806:	mov    ecx,0x1
    380b:	test   rax,0x1
    3811:	je     381f <botlish_fn_28+0x3ef>
    3817:	mov    rsi,rax
    381a:	jmp    3843 <botlish_fn_28+0x413>
    381f:	xor    ecx,ecx
    3821:	test   rax,0x7
    3827:	je     3835 <botlish_fn_28+0x405>
    382d:	mov    rsi,rax
    3830:	jmp    3843 <botlish_fn_28+0x413>
    3835:	movzx  rcx,BYTE PTR [rax]
    3839:	mov    rsi,rax
    383c:	rex cmp cl,0x1
    3840:	sete   cl
    3843:	test   cl,cl
    3845:	jne    3866 <botlish_fn_28+0x436>
    384b:	mov    rdi,r12
    384e:	mov    rax,QWORD PTR [rdi+0x10]
    3852:	mov    rcx,QWORD PTR [rax+0x10]
    3856:	xor    rdx,rdx
    3859:	call   385e <botlish_fn_28+0x42e>
			385a: R_X86_64_PLT32	rt_type_error-0x4
    385e:	mov    rdi,r12
    3861:	jmp    38b1 <botlish_fn_28+0x481>
    3866:	test   rsi,0x1
    386d:	je     3885 <botlish_fn_28+0x455>
    3873:	mov    rcx,rsi
    3876:	add    rcx,0x2
    387a:	seto   al
    387d:	test   al,al
    387f:	je     3895 <botlish_fn_28+0x465>
    3885:	mov    edx,0x3
    388a:	mov    rdi,r12
    388d:	call   3892 <botlish_fn_28+0x462>
			388e: R_X86_64_PLT32	rt_int_add-0x4
    3892:	mov    rcx,rax
    3895:	mov    edx,0x9
    389a:	mov    rsi,r13
    389d:	mov    rdi,r12
    38a0:	call   38a5 <botlish_fn_28+0x475>
			38a1: R_X86_64_PLT32	rt_mutarray_set-0x4
    38a5:	test   rax,rax
    38a8:	jne    38db <botlish_fn_28+0x4ab>
    38ae:	mov    rdi,r12
    38b1:	mov    rdi,r12
    38b4:	mov    QWORD PTR [rdi],rbx
    38b7:	xor    rax,rax
    38ba:	mov    rbx,QWORD PTR [rsp]
    38be:	mov    r12,QWORD PTR [rsp+0x8]
    38c3:	mov    r13,QWORD PTR [rsp+0x10]
    38c8:	mov    r14,QWORD PTR [rsp+0x18]
    38cd:	mov    r15,QWORD PTR [rsp+0x20]
    38d2:	add    rsp,0x30
    38d6:	mov    rsp,rbp
    38d9:	pop    rbp
    38da:	ret
    38db:	mov    rdi,r12
    38de:	mov    QWORD PTR [rdi],rbx
    38e1:	mov    eax,0xa
    38e6:	mov    rbx,QWORD PTR [rsp]
    38ea:	mov    r12,QWORD PTR [rsp+0x8]
    38ef:	mov    r13,QWORD PTR [rsp+0x10]
    38f4:	mov    r14,QWORD PTR [rsp+0x18]
    38f9:	mov    r15,QWORD PTR [rsp+0x20]
    38fe:	add    rsp,0x30
    3902:	mov    rsp,rbp
    3905:	pop    rbp
    3906:	ret
    3907:	mov    rdi,r12
    390a:	mov    QWORD PTR [rdi],rbx
    390d:	mov    eax,0xa
    3912:	mov    rbx,QWORD PTR [rsp]
    3916:	mov    r12,QWORD PTR [rsp+0x8]
    391b:	mov    r13,QWORD PTR [rsp+0x10]
    3920:	mov    r14,QWORD PTR [rsp+0x18]
    3925:	mov    r15,QWORD PTR [rsp+0x20]
    392a:	add    rsp,0x30
    392e:	mov    rsp,rbp
    3931:	pop    rbp
    3932:	ret
    3933:	mov    r12,rdi
    3936:	call   393b <botlish_fn_28+0x50b>
			3937: R_X86_64_PLT32	rt_stack_overflow-0x4
    393b:	xor    rax,rax
    393e:	mov    rbx,QWORD PTR [rsp]
    3942:	mov    r12,QWORD PTR [rsp+0x8]
    3947:	mov    r13,QWORD PTR [rsp+0x10]
    394c:	mov    r14,QWORD PTR [rsp+0x18]
    3951:	mov    r15,QWORD PTR [rsp+0x20]
    3956:	add    rsp,0x30
    395a:	mov    rsp,rbp
    395d:	pop    rbp
    395e:	ret
    395f:	add    BYTE PTR [rsi],al
    3961:	add    BYTE PTR [rax],al
    3963:	add    BYTE PTR [rax],al
    3965:	add    BYTE PTR [rax],al
	...

0000000000003968 <botlish_entry_28: ht_delete<mutarray, str>>:
    3968:	push   rbp
    3969:	mov    rbp,rsp
    396c:	mov    rsi,QWORD PTR [rdx]
    396f:	mov    rdx,QWORD PTR [rdx+0x8]
    3973:	call   3978 <botlish_entry_28+0x10>
			3974: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3978:	mov    rsp,rbp
    397b:	pop    rbp
    397c:	ret
    397d:	add    BYTE PTR [rax],al
	...

0000000000003980 <botlish_fn_29: sample<generic>>:
    3980:	push   rbp
    3981:	mov    rbp,rsp
    3984:	sub    rsp,0x70
    3988:	mov    QWORD PTR [rsp+0x40],rbx
    398d:	mov    QWORD PTR [rsp+0x48],r12
    3992:	mov    QWORD PTR [rsp+0x50],r13
    3997:	mov    QWORD PTR [rsp+0x58],r14
    399c:	mov    QWORD PTR [rsp+0x60],r15
    39a1:	mov    r12,QWORD PTR [rdi]
    39a4:	mov    rax,QWORD PTR [rdi+0x8]
    39a8:	lea    rcx,[r12+0x30]
    39ad:	cmp    rcx,rax
    39b0:	ja     3d3c <botlish_fn_29+0x3bc>
    39b6:	lea    rax,[r12+0x30]
    39bb:	mov    QWORD PTR [rdi],rax
    39be:	mov    QWORD PTR [rsp+0x30],rdi
    39c3:	mov    QWORD PTR [r12],0x0
    39cb:	mov    QWORD PTR [r12+0x8],0x0
    39d4:	mov    QWORD PTR [r12+0x10],0x0
    39dd:	mov    QWORD PTR [r12+0x18],0x0
    39e6:	mov    QWORD PTR [r12+0x20],0x0
    39ef:	mov    QWORD PTR [r12+0x28],0x0
    39f8:	mov    rdi,QWORD PTR [rsp+0x30]
    39fd:	call   3a02 <botlish_fn_29+0x82>
			39fe: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    3a02:	mov    rbx,rax
    3a05:	test   rbx,rbx
    3a08:	jne    3a18 <botlish_fn_29+0x98>
    3a0e:	mov    rdi,QWORD PTR [rsp+0x30]
    3a13:	jmp    3ce5 <botlish_fn_29+0x365>
    3a18:	mov    QWORD PTR [r12],rbx
    3a1c:	mov    rdi,QWORD PTR [rsp+0x30]
    3a21:	mov    r9,QWORD PTR [rdi+0x10]
    3a25:	mov    rdx,QWORD PTR [r9+0x30]
    3a29:	mov    QWORD PTR [r12+0x8],rdx
    3a2e:	mov    r10,QWORD PTR [rdi+0x10]
    3a32:	mov    rcx,QWORD PTR [r10+0x38]
    3a36:	mov    QWORD PTR [r12+0x10],rcx
    3a3b:	mov    rsi,rbx
    3a3e:	call   3a43 <botlish_fn_29+0xc3>
			3a3f: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3a43:	test   rax,rax
    3a46:	jne    3a56 <botlish_fn_29+0xd6>
    3a4c:	mov    rdi,QWORD PTR [rsp+0x30]
    3a51:	jmp    3ce5 <botlish_fn_29+0x365>
    3a56:	mov    rdi,QWORD PTR [rsp+0x30]
    3a5b:	mov    rax,QWORD PTR [rdi+0x10]
    3a5f:	mov    rdx,QWORD PTR [rax+0x40]
    3a63:	mov    QWORD PTR [r12+0x8],rdx
    3a68:	mov    rax,QWORD PTR [rdi+0x10]
    3a6c:	mov    rcx,QWORD PTR [rax+0x48]
    3a70:	mov    QWORD PTR [r12+0x10],rcx
    3a75:	mov    rsi,rbx
    3a78:	call   3a7d <botlish_fn_29+0xfd>
			3a79: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3a7d:	test   rax,rax
    3a80:	jne    3a90 <botlish_fn_29+0x110>
    3a86:	mov    rdi,QWORD PTR [rsp+0x30]
    3a8b:	jmp    3ce5 <botlish_fn_29+0x365>
    3a90:	mov    rdi,QWORD PTR [rsp+0x30]
    3a95:	mov    rax,QWORD PTR [rdi+0x10]
    3a99:	mov    rdx,QWORD PTR [rax+0x30]
    3a9d:	mov    QWORD PTR [r12+0x8],rdx
    3aa2:	mov    rax,QWORD PTR [rdi+0x10]
    3aa6:	mov    rcx,QWORD PTR [rax+0x50]
    3aaa:	mov    QWORD PTR [r12+0x10],rcx
    3aaf:	mov    rsi,rbx
    3ab2:	call   3ab7 <botlish_fn_29+0x137>
			3ab3: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3ab7:	test   rax,rax
    3aba:	jne    3aca <botlish_fn_29+0x14a>
    3ac0:	mov    rdi,QWORD PTR [rsp+0x30]
    3ac5:	jmp    3ce5 <botlish_fn_29+0x365>
    3aca:	mov    rdi,QWORD PTR [rsp+0x30]
    3acf:	mov    rax,QWORD PTR [rdi+0x10]
    3ad3:	mov    rdx,QWORD PTR [rax+0x40]
    3ad7:	mov    QWORD PTR [r12+0x8],rdx
    3adc:	mov    rsi,rbx
    3adf:	call   3ae4 <botlish_fn_29+0x164>
			3ae0: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3ae4:	mov    r8,rax
    3ae7:	test   r8,r8
    3aea:	jne    3afa <botlish_fn_29+0x17a>
    3af0:	mov    rdi,QWORD PTR [rsp+0x30]
    3af5:	jmp    3ce5 <botlish_fn_29+0x365>
    3afa:	mov    QWORD PTR [r12+0x8],r8
    3aff:	mov    rdi,QWORD PTR [rsp+0x30]
    3b04:	mov    QWORD PTR [rsp+0x38],r8
    3b09:	mov    rax,QWORD PTR [rdi+0x10]
    3b0d:	mov    rdx,QWORD PTR [rax+0x40]
    3b11:	mov    QWORD PTR [r12+0x10],rdx
    3b16:	mov    rsi,rbx
    3b19:	call   3b1e <botlish_fn_29+0x19e>
			3b1a: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3b1e:	test   rax,rax
    3b21:	jne    3b31 <botlish_fn_29+0x1b1>
    3b27:	mov    rdi,QWORD PTR [rsp+0x30]
    3b2c:	jmp    3ce5 <botlish_fn_29+0x365>
    3b31:	mov    rdi,QWORD PTR [rsp+0x30]
    3b36:	mov    rax,QWORD PTR [rdi+0x10]
    3b3a:	mov    rdx,QWORD PTR [rax+0x30]
    3b3e:	mov    QWORD PTR [r12+0x10],rdx
    3b43:	mov    rsi,rbx
    3b46:	call   3b4b <botlish_fn_29+0x1cb>
			3b47: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    3b4b:	test   rax,rax
    3b4e:	jne    3b5e <botlish_fn_29+0x1de>
    3b54:	mov    rdi,QWORD PTR [rsp+0x30]
    3b59:	jmp    3ce5 <botlish_fn_29+0x365>
    3b5e:	mov    rdi,QWORD PTR [rsp+0x30]
    3b63:	mov    rcx,QWORD PTR [rdi+0x10]
    3b67:	mov    rdx,QWORD PTR [rcx+0x50]
    3b6b:	mov    rcx,rax
    3b6e:	and    rcx,rdx
    3b71:	mov    rsi,rax
    3b74:	test   rcx,0x1
    3b7b:	jne    3ba1 <botlish_fn_29+0x221>
    3b81:	mov    rdi,QWORD PTR [rsp+0x30]
    3b86:	call   3b8b <botlish_fn_29+0x20b>
			3b87: R_X86_64_PLT32	rt_value_eq-0x4
    3b8b:	mov    r13,rax
    3b8e:	test   r13,r13
    3b91:	jne    3bb2 <botlish_fn_29+0x232>
    3b97:	mov    rdi,QWORD PTR [rsp+0x30]
    3b9c:	jmp    3ce5 <botlish_fn_29+0x365>
    3ba1:	mov    r13d,0x2
    3ba7:	cmp    rsi,rdx
    3baa:	cmove  r13,QWORD PTR [rip+0x1be]        # 3d70 <botlish_fn_29+0x3f0>
    3bb2:	mov    QWORD PTR [r12+0x10],r13
    3bb7:	mov    rdi,QWORD PTR [rsp+0x30]
    3bbc:	mov    rax,QWORD PTR [rdi+0x10]
    3bc0:	mov    rdx,QWORD PTR [rax+0x40]
    3bc4:	mov    QWORD PTR [r12+0x18],rdx
    3bc9:	mov    rsi,rbx
    3bcc:	call   3bd1 <botlish_fn_29+0x251>
			3bcd: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3bd1:	mov    r14,rax
    3bd4:	test   r14,r14
    3bd7:	jne    3be7 <botlish_fn_29+0x267>
    3bdd:	mov    rdi,QWORD PTR [rsp+0x30]
    3be2:	jmp    3ce5 <botlish_fn_29+0x365>
    3be7:	mov    QWORD PTR [r12+0x18],r14
    3bec:	mov    rdi,QWORD PTR [rsp+0x30]
    3bf1:	mov    rax,QWORD PTR [rdi+0x10]
    3bf5:	mov    rdx,QWORD PTR [rax+0x58]
    3bf9:	mov    QWORD PTR [r12+0x20],rdx
    3bfe:	mov    rsi,rbx
    3c01:	call   3c06 <botlish_fn_29+0x286>
			3c02: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3c06:	mov    r15,rax
    3c09:	test   r15,r15
    3c0c:	jne    3c1c <botlish_fn_29+0x29c>
    3c12:	mov    rdi,QWORD PTR [rsp+0x30]
    3c17:	jmp    3ce5 <botlish_fn_29+0x365>
    3c1c:	mov    QWORD PTR [r12+0x20],r15
    3c21:	mov    rdi,QWORD PTR [rsp+0x30]
    3c26:	mov    rax,QWORD PTR [rdi+0x10]
    3c2a:	mov    rdx,QWORD PTR [rax+0x58]
    3c2e:	mov    QWORD PTR [r12+0x28],rdx
    3c33:	mov    rsi,rbx
    3c36:	call   3c3b <botlish_fn_29+0x2bb>
			3c37: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    3c3b:	test   rax,rax
    3c3e:	mov    rsi,rax
    3c41:	jne    3c51 <botlish_fn_29+0x2d1>
    3c47:	mov    rdi,QWORD PTR [rsp+0x30]
    3c4c:	jmp    3ce5 <botlish_fn_29+0x365>
    3c51:	mov    edx,0xa
    3c56:	mov    rdi,QWORD PTR [rsp+0x30]
    3c5b:	call   3c60 <botlish_fn_29+0x2e0>
			3c5c: R_X86_64_PLT32	rt_value_eq-0x4
    3c60:	test   rax,rax
    3c63:	jne    3c73 <botlish_fn_29+0x2f3>
    3c69:	mov    rdi,QWORD PTR [rsp+0x30]
    3c6e:	jmp    3ce5 <botlish_fn_29+0x365>
    3c73:	mov    QWORD PTR [r12+0x28],rax
    3c78:	mov    rsi,rbx
    3c7b:	mov    rbx,rax
    3c7e:	mov    rdi,QWORD PTR [rsp+0x30]
    3c83:	call   3c88 <botlish_fn_29+0x308>
			3c84: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3c88:	test   rax,rax
    3c8b:	jne    3c9b <botlish_fn_29+0x31b>
    3c91:	mov    rdi,QWORD PTR [rsp+0x30]
    3c96:	jmp    3ce5 <botlish_fn_29+0x365>
    3c9b:	mov    QWORD PTR [r12],rax
    3c9f:	lea    rdx,[rsp]
    3ca3:	mov    QWORD PTR [rsp],r13
    3ca7:	mov    r8,QWORD PTR [rsp+0x38]
    3cac:	mov    QWORD PTR [rsp+0x8],r8
    3cb1:	mov    QWORD PTR [rsp+0x10],r14
    3cb6:	mov    QWORD PTR [rsp+0x18],r15
    3cbb:	mov    rcx,rbx
    3cbe:	mov    QWORD PTR [rsp+0x20],rcx
    3cc3:	mov    QWORD PTR [rsp+0x28],rax
    3cc8:	mov    esi,0x6
    3ccd:	mov    rdi,QWORD PTR [rsp+0x30]
    3cd2:	call   3cd7 <botlish_fn_29+0x357>
			3cd3: R_X86_64_PLT32	rt_list_new-0x4
    3cd7:	test   rax,rax
    3cda:	jne    3d12 <botlish_fn_29+0x392>
    3ce0:	mov    rdi,QWORD PTR [rsp+0x30]
    3ce5:	mov    rdi,QWORD PTR [rsp+0x30]
    3cea:	mov    QWORD PTR [rdi],r12
    3ced:	xor    rax,rax
    3cf0:	mov    rbx,QWORD PTR [rsp+0x40]
    3cf5:	mov    r12,QWORD PTR [rsp+0x48]
    3cfa:	mov    r13,QWORD PTR [rsp+0x50]
    3cff:	mov    r14,QWORD PTR [rsp+0x58]
    3d04:	mov    r15,QWORD PTR [rsp+0x60]
    3d09:	add    rsp,0x70
    3d0d:	mov    rsp,rbp
    3d10:	pop    rbp
    3d11:	ret
    3d12:	mov    rdi,QWORD PTR [rsp+0x30]
    3d17:	mov    QWORD PTR [rdi],r12
    3d1a:	mov    rbx,QWORD PTR [rsp+0x40]
    3d1f:	mov    r12,QWORD PTR [rsp+0x48]
    3d24:	mov    r13,QWORD PTR [rsp+0x50]
    3d29:	mov    r14,QWORD PTR [rsp+0x58]
    3d2e:	mov    r15,QWORD PTR [rsp+0x60]
    3d33:	add    rsp,0x70
    3d37:	mov    rsp,rbp
    3d3a:	pop    rbp
    3d3b:	ret
    3d3c:	mov    QWORD PTR [rsp+0x30],rdi
    3d41:	call   3d46 <botlish_fn_29+0x3c6>
			3d42: R_X86_64_PLT32	rt_stack_overflow-0x4
    3d46:	xor    rax,rax
    3d49:	mov    rbx,QWORD PTR [rsp+0x40]
    3d4e:	mov    r12,QWORD PTR [rsp+0x48]
    3d53:	mov    r13,QWORD PTR [rsp+0x50]
    3d58:	mov    r14,QWORD PTR [rsp+0x58]
    3d5d:	mov    r15,QWORD PTR [rsp+0x60]
    3d62:	add    rsp,0x70
    3d66:	mov    rsp,rbp
    3d69:	pop    rbp
    3d6a:	ret
    3d6b:	add    BYTE PTR [rax],al
    3d6d:	add    BYTE PTR [rax],al
    3d6f:	add    BYTE PTR [rsi],al
    3d71:	add    BYTE PTR [rax],al
    3d73:	add    BYTE PTR [rax],al
    3d75:	add    BYTE PTR [rax],al
	...

0000000000003d78 <botlish_entry_29: sample<generic>>:
    3d78:	push   rbp
    3d79:	mov    rbp,rsp
    3d7c:	call   3d81 <botlish_entry_29+0x9>
			3d7d: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    3d81:	mov    rsp,rbp
    3d84:	pop    rbp
    3d85:	ret

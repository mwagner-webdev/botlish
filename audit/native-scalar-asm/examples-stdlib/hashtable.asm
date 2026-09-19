; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 17432  (per function: 172 71 71 71 71 524 689 208 177 177 177 177 177 268 284 332 1020 1536 565 373 556 582 1353 928 953 825 1472 1108 1461 1054)
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
      a9:	mov    r8,QWORD PTR [rdi]
      ac:	mov    r9,QWORD PTR [rdi+0x8]
      b0:	lea    r10,[r8+0x8]
      b4:	cmp    r10,r9
      b7:	ja     ca <botlish_fn_1+0x25>
      bd:	mov    QWORD PTR [rdi],r8
      c0:	mov    eax,0x11
      c5:	mov    rsp,rbp
      c8:	pop    rbp
      c9:	ret
      ca:	call   cf <botlish_fn_1+0x2a>
			cb: R_X86_64_PLT32	rt_stack_overflow-0x4
      cf:	xor    rax,rax
      d2:	mov    rsp,rbp
      d5:	pop    rbp
      d6:	ret

00000000000000d7 <botlish_entry_1: ht_min_capacity<generic>>:
      d7:	push   rbp
      d8:	mov    rbp,rsp
      db:	call   e0 <botlish_entry_1+0x9>
			dc: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
      e0:	mov    rsp,rbp
      e3:	pop    rbp
      e4:	ret

00000000000000e5 <botlish_fn_2: ht_empty_state<generic>>:
      e5:	push   rbp
      e6:	mov    rbp,rsp
      e9:	mov    r8,QWORD PTR [rdi]
      ec:	mov    r9,QWORD PTR [rdi+0x8]
      f0:	lea    r10,[r8+0x8]
      f4:	cmp    r10,r9
      f7:	ja     10a <botlish_fn_2+0x25>
      fd:	mov    QWORD PTR [rdi],r8
     100:	mov    eax,0x1
     105:	mov    rsp,rbp
     108:	pop    rbp
     109:	ret
     10a:	call   10f <botlish_fn_2+0x2a>
			10b: R_X86_64_PLT32	rt_stack_overflow-0x4
     10f:	xor    rax,rax
     112:	mov    rsp,rbp
     115:	pop    rbp
     116:	ret

0000000000000117 <botlish_entry_2: ht_empty_state<generic>>:
     117:	push   rbp
     118:	mov    rbp,rsp
     11b:	call   120 <botlish_entry_2+0x9>
			11c: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     120:	mov    rsp,rbp
     123:	pop    rbp
     124:	ret

0000000000000125 <botlish_fn_3: ht_occupied_state<generic>>:
     125:	push   rbp
     126:	mov    rbp,rsp
     129:	mov    r8,QWORD PTR [rdi]
     12c:	mov    r9,QWORD PTR [rdi+0x8]
     130:	lea    r10,[r8+0x8]
     134:	cmp    r10,r9
     137:	ja     14a <botlish_fn_3+0x25>
     13d:	mov    QWORD PTR [rdi],r8
     140:	mov    eax,0x3
     145:	mov    rsp,rbp
     148:	pop    rbp
     149:	ret
     14a:	call   14f <botlish_fn_3+0x2a>
			14b: R_X86_64_PLT32	rt_stack_overflow-0x4
     14f:	xor    rax,rax
     152:	mov    rsp,rbp
     155:	pop    rbp
     156:	ret

0000000000000157 <botlish_entry_3: ht_occupied_state<generic>>:
     157:	push   rbp
     158:	mov    rbp,rsp
     15b:	call   160 <botlish_entry_3+0x9>
			15c: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     160:	mov    rsp,rbp
     163:	pop    rbp
     164:	ret

0000000000000165 <botlish_fn_4: ht_tombstone_state<generic>>:
     165:	push   rbp
     166:	mov    rbp,rsp
     169:	mov    r8,QWORD PTR [rdi]
     16c:	mov    r9,QWORD PTR [rdi+0x8]
     170:	lea    r10,[r8+0x8]
     174:	cmp    r10,r9
     177:	ja     18a <botlish_fn_4+0x25>
     17d:	mov    QWORD PTR [rdi],r8
     180:	mov    eax,0x5
     185:	mov    rsp,rbp
     188:	pop    rbp
     189:	ret
     18a:	call   18f <botlish_fn_4+0x2a>
			18b: R_X86_64_PLT32	rt_stack_overflow-0x4
     18f:	xor    rax,rax
     192:	mov    rsp,rbp
     195:	pop    rbp
     196:	ret

0000000000000197 <botlish_entry_4: ht_tombstone_state<generic>>:
     197:	push   rbp
     198:	mov    rbp,rsp
     19b:	call   1a0 <botlish_entry_4+0x9>
			19c: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
     1a0:	mov    rsp,rbp
     1a3:	pop    rbp
     1a4:	ret
     1a5:	add    BYTE PTR [rax],al
	...

00000000000001a8 <botlish_fn_5: ht_fill_empty<mutarray, int, int>>:
     1a8:	push   rbp
     1a9:	mov    rbp,rsp
     1ac:	sub    rsp,0x30
     1b0:	mov    QWORD PTR [rsp],rbx
     1b4:	mov    QWORD PTR [rsp+0x8],r12
     1b9:	mov    QWORD PTR [rsp+0x10],r13
     1be:	mov    QWORD PTR [rsp+0x18],r14
     1c3:	mov    QWORD PTR [rsp+0x20],r15
     1c8:	mov    r13,QWORD PTR [rdi]
     1cb:	mov    r8,QWORD PTR [rdi+0x8]
     1cf:	lea    rax,[r13+0x20]
     1d3:	cmp    rax,r8
     1d6:	ja     340 <botlish_fn_5+0x198>
     1dc:	lea    rax,[r13+0x20]
     1e0:	mov    QWORD PTR [rdi],rax
     1e3:	mov    r14,rdi
     1e6:	mov    QWORD PTR [r13+0x18],0x0
     1ee:	mov    QWORD PTR [r13+0x0],rsi
     1f2:	mov    r12,rsi
     1f5:	mov    QWORD PTR [r13+0x8],rdx
     1f9:	mov    QWORD PTR [r13+0x10],rcx
     1fd:	mov    rbx,rcx
     200:	mov    rsi,rdx
     203:	mov    rax,rsi
     206:	and    rax,rbx
     209:	mov    r15,rsi
     20c:	test   rax,0x1
     212:	jne    23b <botlish_fn_5+0x93>
     218:	mov    rdx,rbx
     21b:	mov    rsi,r15
     21e:	mov    rdi,r14
     221:	call   226 <botlish_fn_5+0x7e>
			222: R_X86_64_PLT32	rt_int_cmp-0x4
     226:	mov    ecx,0x2
     22b:	test   rax,rax
     22e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 370 <botlish_fn_5+0x1c8>
     236:	jmp    24e <botlish_fn_5+0xa6>
     23b:	mov    ecx,0x2
     240:	mov    rsi,r15
     243:	cmp    rsi,rbx
     246:	cmovge rcx,QWORD PTR [rip+0x122]        # 370 <botlish_fn_5+0x1c8>
     24e:	cmp    rcx,0x6
     252:	je     314 <botlish_fn_5+0x16c>
     258:	mov    rdi,r14
     25b:	call   260 <botlish_fn_5+0xb8>
			25c: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     260:	test   rax,rax
     263:	mov    rcx,rax
     266:	jne    274 <botlish_fn_5+0xcc>
     26c:	mov    rdi,r14
     26f:	jmp    28e <botlish_fn_5+0xe6>
     274:	mov    rdx,r15
     277:	mov    rsi,r12
     27a:	mov    rdi,r14
     27d:	call   282 <botlish_fn_5+0xda>
			27e: R_X86_64_PLT32	rt_mutarray_set-0x4
     282:	test   rax,rax
     285:	jne    2b8 <botlish_fn_5+0x110>
     28b:	mov    rdi,r14
     28e:	mov    rdi,r14
     291:	mov    QWORD PTR [rdi],r13
     294:	xor    rax,rax
     297:	mov    rbx,QWORD PTR [rsp]
     29b:	mov    r12,QWORD PTR [rsp+0x8]
     2a0:	mov    r13,QWORD PTR [rsp+0x10]
     2a5:	mov    r14,QWORD PTR [rsp+0x18]
     2aa:	mov    r15,QWORD PTR [rsp+0x20]
     2af:	add    rsp,0x30
     2b3:	mov    rsp,rbp
     2b6:	pop    rbp
     2b7:	ret
     2b8:	mov    QWORD PTR [r13+0x18],0x3
     2c0:	mov    rsi,r15
     2c3:	test   rsi,0x1
     2ca:	je     2ed <botlish_fn_5+0x145>
     2d0:	mov    rsi,r15
     2d3:	mov    rcx,rsi
     2d6:	add    rcx,0x2
     2da:	seto   al
     2dd:	test   al,al
     2df:	jne    2ed <botlish_fn_5+0x145>
     2e5:	mov    r15,rcx
     2e8:	jmp    300 <botlish_fn_5+0x158>
     2ed:	mov    edx,0x3
     2f2:	mov    rsi,r15
     2f5:	mov    rdi,r14
     2f8:	call   2fd <botlish_fn_5+0x155>
			2f9: R_X86_64_PLT32	rt_int_add-0x4
     2fd:	mov    r15,rax
     300:	mov    QWORD PTR [r13+0x0],r12
     304:	mov    rsi,r15
     307:	mov    QWORD PTR [r13+0x8],rsi
     30b:	mov    QWORD PTR [r13+0x10],rbx
     30f:	jmp    203 <botlish_fn_5+0x5b>
     314:	mov    rdi,r14
     317:	mov    QWORD PTR [rdi],r13
     31a:	mov    eax,0xa
     31f:	mov    rbx,QWORD PTR [rsp]
     323:	mov    r12,QWORD PTR [rsp+0x8]
     328:	mov    r13,QWORD PTR [rsp+0x10]
     32d:	mov    r14,QWORD PTR [rsp+0x18]
     332:	mov    r15,QWORD PTR [rsp+0x20]
     337:	add    rsp,0x30
     33b:	mov    rsp,rbp
     33e:	pop    rbp
     33f:	ret
     340:	mov    r14,rdi
     343:	call   348 <botlish_fn_5+0x1a0>
			344: R_X86_64_PLT32	rt_stack_overflow-0x4
     348:	xor    rax,rax
     34b:	mov    rbx,QWORD PTR [rsp]
     34f:	mov    r12,QWORD PTR [rsp+0x8]
     354:	mov    r13,QWORD PTR [rsp+0x10]
     359:	mov    r14,QWORD PTR [rsp+0x18]
     35e:	mov    r15,QWORD PTR [rsp+0x20]
     363:	add    rsp,0x30
     367:	mov    rsp,rbp
     36a:	pop    rbp
     36b:	ret
     36c:	add    BYTE PTR [rax],al
     36e:	add    BYTE PTR [rax],al
     370:	(bad)
     371:	add    BYTE PTR [rax],al
     373:	add    BYTE PTR [rax],al
     375:	add    BYTE PTR [rax],al
	...

0000000000000378 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     378:	push   rbp
     379:	mov    rbp,rsp
     37c:	mov    rsi,QWORD PTR [rdx]
     37f:	mov    r8,QWORD PTR [rdx+0x8]
     383:	mov    rcx,QWORD PTR [rdx+0x10]
     387:	mov    rdx,r8
     38a:	call   38f <botlish_entry_5+0x17>
			38b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     38f:	mov    rsp,rbp
     392:	pop    rbp
     393:	ret

0000000000000394 <botlish_fn_6: ht_alloc<int>>:
     394:	push   rbp
     395:	mov    rbp,rsp
     398:	sub    rsp,0x40
     39c:	mov    QWORD PTR [rsp+0x10],rbx
     3a1:	mov    QWORD PTR [rsp+0x18],r12
     3a6:	mov    QWORD PTR [rsp+0x20],r13
     3ab:	mov    QWORD PTR [rsp+0x28],r14
     3b0:	mov    QWORD PTR [rsp+0x30],r15
     3b5:	mov    rbx,QWORD PTR [rdi]
     3b8:	mov    rax,QWORD PTR [rdi+0x8]
     3bc:	lea    rcx,[rbx+0x20]
     3c0:	cmp    rcx,rax
     3c3:	ja     5be <botlish_fn_6+0x22a>
     3c9:	lea    rax,[rbx+0x20]
     3cd:	mov    QWORD PTR [rdi],rax
     3d0:	mov    r12,rdi
     3d3:	mov    QWORD PTR [rbx+0x8],0x0
     3db:	mov    QWORD PTR [rbx+0x10],0x0
     3e3:	mov    QWORD PTR [rbx+0x18],0x0
     3eb:	mov    QWORD PTR [rbx],rsi
     3ee:	mov    r13,rsi
     3f1:	mov    rsi,r13
     3f4:	mov    rdi,r12
     3f7:	call   3fc <botlish_fn_6+0x68>
			3f8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3fc:	test   rax,rax
     3ff:	jne    40d <botlish_fn_6+0x79>
     405:	mov    rdi,r12
     408:	jmp    567 <botlish_fn_6+0x1d3>
     40d:	mov    QWORD PTR [rbx+0x8],rax
     411:	mov    r14,rax
     414:	mov    edx,0x1
     419:	mov    QWORD PTR [rbx+0x10],0x1
     421:	mov    rcx,r13
     424:	mov    rsi,r14
     427:	mov    rdi,r12
     42a:	call   42f <botlish_fn_6+0x9b>
			42b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     42f:	test   rax,rax
     432:	jne    440 <botlish_fn_6+0xac>
     438:	mov    rdi,r12
     43b:	jmp    567 <botlish_fn_6+0x1d3>
     440:	mov    rsi,r13
     443:	mov    rdi,r12
     446:	call   44b <botlish_fn_6+0xb7>
			447: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     44b:	test   rax,rax
     44e:	jne    45c <botlish_fn_6+0xc8>
     454:	mov    rdi,r12
     457:	jmp    567 <botlish_fn_6+0x1d3>
     45c:	mov    QWORD PTR [rbx+0x10],rax
     460:	mov    rsi,r13
     463:	mov    r15,rax
     466:	mov    rdi,r12
     469:	call   46e <botlish_fn_6+0xda>
			46a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     46e:	test   rax,rax
     471:	jne    47f <botlish_fn_6+0xeb>
     477:	mov    rdi,r12
     47a:	jmp    567 <botlish_fn_6+0x1d3>
     47f:	mov    QWORD PTR [rbx],rax
     482:	mov    r13,rax
     485:	mov    esi,0xb
     48a:	mov    QWORD PTR [rbx+0x18],0xb
     492:	mov    rdi,r12
     495:	call   49a <botlish_fn_6+0x106>
			496: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     49a:	test   rax,rax
     49d:	mov    QWORD PTR [rsp],rax
     4a1:	jne    4af <botlish_fn_6+0x11b>
     4a7:	mov    rdi,r12
     4aa:	jmp    567 <botlish_fn_6+0x1d3>
     4af:	mov    edx,0x1
     4b4:	mov    rcx,r14
     4b7:	mov    rsi,QWORD PTR [rsp]
     4bb:	mov    rdi,r12
     4be:	call   4c3 <botlish_fn_6+0x12f>
			4bf: R_X86_64_PLT32	rt_mutarray_set-0x4
     4c3:	test   rax,rax
     4c6:	jne    4d4 <botlish_fn_6+0x140>
     4cc:	mov    rdi,r12
     4cf:	jmp    567 <botlish_fn_6+0x1d3>
     4d4:	mov    edx,0x3
     4d9:	mov    rcx,r15
     4dc:	mov    rsi,QWORD PTR [rsp]
     4e0:	mov    rdi,r12
     4e3:	call   4e8 <botlish_fn_6+0x154>
			4e4: R_X86_64_PLT32	rt_mutarray_set-0x4
     4e8:	test   rax,rax
     4eb:	jne    4f9 <botlish_fn_6+0x165>
     4f1:	mov    rdi,r12
     4f4:	jmp    567 <botlish_fn_6+0x1d3>
     4f9:	mov    edx,0x5
     4fe:	mov    rcx,r13
     501:	mov    rsi,QWORD PTR [rsp]
     505:	mov    rdi,r12
     508:	call   50d <botlish_fn_6+0x179>
			509: R_X86_64_PLT32	rt_mutarray_set-0x4
     50d:	test   rax,rax
     510:	jne    51e <botlish_fn_6+0x18a>
     516:	mov    rdi,r12
     519:	jmp    567 <botlish_fn_6+0x1d3>
     51e:	mov    edx,0x7
     523:	mov    ecx,0x1
     528:	mov    rsi,QWORD PTR [rsp]
     52c:	mov    rdi,r12
     52f:	call   534 <botlish_fn_6+0x1a0>
			530: R_X86_64_PLT32	rt_mutarray_set-0x4
     534:	test   rax,rax
     537:	jne    545 <botlish_fn_6+0x1b1>
     53d:	mov    rdi,r12
     540:	jmp    567 <botlish_fn_6+0x1d3>
     545:	mov    edx,0x9
     54a:	mov    ecx,0x1
     54f:	mov    rsi,QWORD PTR [rsp]
     553:	mov    rdi,r12
     556:	call   55b <botlish_fn_6+0x1c7>
			557: R_X86_64_PLT32	rt_mutarray_set-0x4
     55b:	test   rax,rax
     55e:	jne    592 <botlish_fn_6+0x1fe>
     564:	mov    rdi,r12
     567:	mov    rdi,r12
     56a:	mov    QWORD PTR [rdi],rbx
     56d:	xor    rax,rax
     570:	mov    rbx,QWORD PTR [rsp+0x10]
     575:	mov    r12,QWORD PTR [rsp+0x18]
     57a:	mov    r13,QWORD PTR [rsp+0x20]
     57f:	mov    r14,QWORD PTR [rsp+0x28]
     584:	mov    r15,QWORD PTR [rsp+0x30]
     589:	add    rsp,0x40
     58d:	mov    rsp,rbp
     590:	pop    rbp
     591:	ret
     592:	mov    rdi,r12
     595:	mov    QWORD PTR [rdi],rbx
     598:	mov    rax,QWORD PTR [rsp]
     59c:	mov    rbx,QWORD PTR [rsp+0x10]
     5a1:	mov    r12,QWORD PTR [rsp+0x18]
     5a6:	mov    r13,QWORD PTR [rsp+0x20]
     5ab:	mov    r14,QWORD PTR [rsp+0x28]
     5b0:	mov    r15,QWORD PTR [rsp+0x30]
     5b5:	add    rsp,0x40
     5b9:	mov    rsp,rbp
     5bc:	pop    rbp
     5bd:	ret
     5be:	mov    r12,rdi
     5c1:	call   5c6 <botlish_fn_6+0x232>
			5c2: R_X86_64_PLT32	rt_stack_overflow-0x4
     5c6:	xor    rax,rax
     5c9:	mov    rbx,QWORD PTR [rsp+0x10]
     5ce:	mov    r12,QWORD PTR [rsp+0x18]
     5d3:	mov    r13,QWORD PTR [rsp+0x20]
     5d8:	mov    r14,QWORD PTR [rsp+0x28]
     5dd:	mov    r15,QWORD PTR [rsp+0x30]
     5e2:	add    rsp,0x40
     5e6:	mov    rsp,rbp
     5e9:	pop    rbp
     5ea:	ret

00000000000005eb <botlish_entry_6: ht_alloc<int>>:
     5eb:	push   rbp
     5ec:	mov    rbp,rsp
     5ef:	mov    rsi,QWORD PTR [rdx]
     5f2:	call   5f7 <botlish_entry_6+0xc>
			5f3: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     5f7:	mov    rsp,rbp
     5fa:	pop    rbp
     5fb:	ret

00000000000005fc <botlish_fn_7: ht_new<generic>>:
     5fc:	push   rbp
     5fd:	mov    rbp,rsp
     600:	sub    rsp,0x10
     604:	mov    QWORD PTR [rsp],r12
     608:	mov    QWORD PTR [rsp+0x8],r13
     60d:	mov    r12,QWORD PTR [rdi]
     610:	mov    rax,QWORD PTR [rdi+0x8]
     614:	lea    rcx,[r12+0x8]
     619:	cmp    rcx,rax
     61c:	ja     69c <botlish_fn_7+0xa0>
     622:	lea    rax,[r12+0x8]
     627:	mov    QWORD PTR [rdi],rax
     62a:	mov    r13,rdi
     62d:	mov    QWORD PTR [r12],0x0
     635:	mov    rdi,r13
     638:	call   63d <botlish_fn_7+0x41>
			639: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     63d:	test   rax,rax
     640:	jne    64e <botlish_fn_7+0x52>
     646:	mov    rdi,r13
     649:	jmp    669 <botlish_fn_7+0x6d>
     64e:	mov    QWORD PTR [r12],rax
     652:	mov    rsi,rax
     655:	mov    rdi,r13
     658:	call   65d <botlish_fn_7+0x61>
			659: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     65d:	test   rax,rax
     660:	jne    684 <botlish_fn_7+0x88>
     666:	mov    rdi,r13
     669:	mov    rdi,r13
     66c:	mov    QWORD PTR [rdi],r12
     66f:	xor    rax,rax
     672:	mov    r12,QWORD PTR [rsp]
     676:	mov    r13,QWORD PTR [rsp+0x8]
     67b:	add    rsp,0x10
     67f:	mov    rsp,rbp
     682:	pop    rbp
     683:	ret
     684:	mov    rdi,r13
     687:	mov    QWORD PTR [rdi],r12
     68a:	mov    r12,QWORD PTR [rsp]
     68e:	mov    r13,QWORD PTR [rsp+0x8]
     693:	add    rsp,0x10
     697:	mov    rsp,rbp
     69a:	pop    rbp
     69b:	ret
     69c:	mov    r13,rdi
     69f:	call   6a4 <botlish_fn_7+0xa8>
			6a0: R_X86_64_PLT32	rt_stack_overflow-0x4
     6a4:	xor    rax,rax
     6a7:	mov    r12,QWORD PTR [rsp]
     6ab:	mov    r13,QWORD PTR [rsp+0x8]
     6b0:	add    rsp,0x10
     6b4:	mov    rsp,rbp
     6b7:	pop    rbp
     6b8:	ret

00000000000006b9 <botlish_entry_7: ht_new<generic>>:
     6b9:	push   rbp
     6ba:	mov    rbp,rsp
     6bd:	call   6c2 <botlish_entry_7+0x9>
			6be: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     6c2:	mov    rsp,rbp
     6c5:	pop    rbp
     6c6:	ret

00000000000006c7 <botlish_fn_8: ht_controls<mutarray>>:
     6c7:	push   rbp
     6c8:	mov    rbp,rsp
     6cb:	sub    rsp,0x10
     6cf:	mov    QWORD PTR [rsp],r13
     6d3:	mov    QWORD PTR [rsp+0x8],r14
     6d8:	mov    r13,QWORD PTR [rdi]
     6db:	mov    rax,QWORD PTR [rdi+0x8]
     6df:	lea    rcx,[r13+0x8]
     6e3:	cmp    rcx,rax
     6e6:	ja     73f <botlish_fn_8+0x78>
     6ec:	lea    rax,[r13+0x8]
     6f0:	mov    QWORD PTR [rdi],rax
     6f3:	mov    r14,rdi
     6f6:	mov    edx,0x1
     6fb:	mov    rdi,r14
     6fe:	call   703 <botlish_fn_8+0x3c>
			6ff: R_X86_64_PLT32	rt_mutarray_get-0x4
     703:	test   rax,rax
     706:	jne    727 <botlish_fn_8+0x60>
     70c:	mov    rdi,r14
     70f:	mov    QWORD PTR [rdi],r13
     712:	xor    rax,rax
     715:	mov    r13,QWORD PTR [rsp]
     719:	mov    r14,QWORD PTR [rsp+0x8]
     71e:	add    rsp,0x10
     722:	mov    rsp,rbp
     725:	pop    rbp
     726:	ret
     727:	mov    rdi,r14
     72a:	mov    QWORD PTR [rdi],r13
     72d:	mov    r13,QWORD PTR [rsp]
     731:	mov    r14,QWORD PTR [rsp+0x8]
     736:	add    rsp,0x10
     73a:	mov    rsp,rbp
     73d:	pop    rbp
     73e:	ret
     73f:	call   744 <botlish_fn_8+0x7d>
			740: R_X86_64_PLT32	rt_stack_overflow-0x4
     744:	xor    rax,rax
     747:	mov    r13,QWORD PTR [rsp]
     74b:	mov    r14,QWORD PTR [rsp+0x8]
     750:	add    rsp,0x10
     754:	mov    rsp,rbp
     757:	pop    rbp
     758:	ret

0000000000000759 <botlish_entry_8: ht_controls<mutarray>>:
     759:	push   rbp
     75a:	mov    rbp,rsp
     75d:	mov    rsi,QWORD PTR [rdx]
     760:	call   765 <botlish_entry_8+0xc>
			761: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     765:	mov    rsp,rbp
     768:	pop    rbp
     769:	ret

000000000000076a <botlish_fn_9: ht_keys<mutarray>>:
     76a:	push   rbp
     76b:	mov    rbp,rsp
     76e:	sub    rsp,0x10
     772:	mov    QWORD PTR [rsp],r13
     776:	mov    QWORD PTR [rsp+0x8],r14
     77b:	mov    r13,QWORD PTR [rdi]
     77e:	mov    rax,QWORD PTR [rdi+0x8]
     782:	lea    rcx,[r13+0x8]
     786:	cmp    rcx,rax
     789:	ja     7e2 <botlish_fn_9+0x78>
     78f:	lea    rax,[r13+0x8]
     793:	mov    QWORD PTR [rdi],rax
     796:	mov    r14,rdi
     799:	mov    edx,0x3
     79e:	mov    rdi,r14
     7a1:	call   7a6 <botlish_fn_9+0x3c>
			7a2: R_X86_64_PLT32	rt_mutarray_get-0x4
     7a6:	test   rax,rax
     7a9:	jne    7ca <botlish_fn_9+0x60>
     7af:	mov    rdi,r14
     7b2:	mov    QWORD PTR [rdi],r13
     7b5:	xor    rax,rax
     7b8:	mov    r13,QWORD PTR [rsp]
     7bc:	mov    r14,QWORD PTR [rsp+0x8]
     7c1:	add    rsp,0x10
     7c5:	mov    rsp,rbp
     7c8:	pop    rbp
     7c9:	ret
     7ca:	mov    rdi,r14
     7cd:	mov    QWORD PTR [rdi],r13
     7d0:	mov    r13,QWORD PTR [rsp]
     7d4:	mov    r14,QWORD PTR [rsp+0x8]
     7d9:	add    rsp,0x10
     7dd:	mov    rsp,rbp
     7e0:	pop    rbp
     7e1:	ret
     7e2:	call   7e7 <botlish_fn_9+0x7d>
			7e3: R_X86_64_PLT32	rt_stack_overflow-0x4
     7e7:	xor    rax,rax
     7ea:	mov    r13,QWORD PTR [rsp]
     7ee:	mov    r14,QWORD PTR [rsp+0x8]
     7f3:	add    rsp,0x10
     7f7:	mov    rsp,rbp
     7fa:	pop    rbp
     7fb:	ret

00000000000007fc <botlish_entry_9: ht_keys<mutarray>>:
     7fc:	push   rbp
     7fd:	mov    rbp,rsp
     800:	mov    rsi,QWORD PTR [rdx]
     803:	call   808 <botlish_entry_9+0xc>
			804: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     808:	mov    rsp,rbp
     80b:	pop    rbp
     80c:	ret

000000000000080d <botlish_fn_10: ht_values<mutarray>>:
     80d:	push   rbp
     80e:	mov    rbp,rsp
     811:	sub    rsp,0x10
     815:	mov    QWORD PTR [rsp],r13
     819:	mov    QWORD PTR [rsp+0x8],r14
     81e:	mov    r13,QWORD PTR [rdi]
     821:	mov    rax,QWORD PTR [rdi+0x8]
     825:	lea    rcx,[r13+0x8]
     829:	cmp    rcx,rax
     82c:	ja     885 <botlish_fn_10+0x78>
     832:	lea    rax,[r13+0x8]
     836:	mov    QWORD PTR [rdi],rax
     839:	mov    r14,rdi
     83c:	mov    edx,0x5
     841:	mov    rdi,r14
     844:	call   849 <botlish_fn_10+0x3c>
			845: R_X86_64_PLT32	rt_mutarray_get-0x4
     849:	test   rax,rax
     84c:	jne    86d <botlish_fn_10+0x60>
     852:	mov    rdi,r14
     855:	mov    QWORD PTR [rdi],r13
     858:	xor    rax,rax
     85b:	mov    r13,QWORD PTR [rsp]
     85f:	mov    r14,QWORD PTR [rsp+0x8]
     864:	add    rsp,0x10
     868:	mov    rsp,rbp
     86b:	pop    rbp
     86c:	ret
     86d:	mov    rdi,r14
     870:	mov    QWORD PTR [rdi],r13
     873:	mov    r13,QWORD PTR [rsp]
     877:	mov    r14,QWORD PTR [rsp+0x8]
     87c:	add    rsp,0x10
     880:	mov    rsp,rbp
     883:	pop    rbp
     884:	ret
     885:	call   88a <botlish_fn_10+0x7d>
			886: R_X86_64_PLT32	rt_stack_overflow-0x4
     88a:	xor    rax,rax
     88d:	mov    r13,QWORD PTR [rsp]
     891:	mov    r14,QWORD PTR [rsp+0x8]
     896:	add    rsp,0x10
     89a:	mov    rsp,rbp
     89d:	pop    rbp
     89e:	ret

000000000000089f <botlish_entry_10: ht_values<mutarray>>:
     89f:	push   rbp
     8a0:	mov    rbp,rsp
     8a3:	mov    rsi,QWORD PTR [rdx]
     8a6:	call   8ab <botlish_entry_10+0xc>
			8a7: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     8ab:	mov    rsp,rbp
     8ae:	pop    rbp
     8af:	ret

00000000000008b0 <botlish_fn_11: ht_size<mutarray>>:
     8b0:	push   rbp
     8b1:	mov    rbp,rsp
     8b4:	sub    rsp,0x10
     8b8:	mov    QWORD PTR [rsp],r13
     8bc:	mov    QWORD PTR [rsp+0x8],r14
     8c1:	mov    r13,QWORD PTR [rdi]
     8c4:	mov    rax,QWORD PTR [rdi+0x8]
     8c8:	lea    rcx,[r13+0x8]
     8cc:	cmp    rcx,rax
     8cf:	ja     928 <botlish_fn_11+0x78>
     8d5:	lea    rax,[r13+0x8]
     8d9:	mov    QWORD PTR [rdi],rax
     8dc:	mov    r14,rdi
     8df:	mov    edx,0x7
     8e4:	mov    rdi,r14
     8e7:	call   8ec <botlish_fn_11+0x3c>
			8e8: R_X86_64_PLT32	rt_mutarray_get-0x4
     8ec:	test   rax,rax
     8ef:	jne    910 <botlish_fn_11+0x60>
     8f5:	mov    rdi,r14
     8f8:	mov    QWORD PTR [rdi],r13
     8fb:	xor    rax,rax
     8fe:	mov    r13,QWORD PTR [rsp]
     902:	mov    r14,QWORD PTR [rsp+0x8]
     907:	add    rsp,0x10
     90b:	mov    rsp,rbp
     90e:	pop    rbp
     90f:	ret
     910:	mov    rdi,r14
     913:	mov    QWORD PTR [rdi],r13
     916:	mov    r13,QWORD PTR [rsp]
     91a:	mov    r14,QWORD PTR [rsp+0x8]
     91f:	add    rsp,0x10
     923:	mov    rsp,rbp
     926:	pop    rbp
     927:	ret
     928:	call   92d <botlish_fn_11+0x7d>
			929: R_X86_64_PLT32	rt_stack_overflow-0x4
     92d:	xor    rax,rax
     930:	mov    r13,QWORD PTR [rsp]
     934:	mov    r14,QWORD PTR [rsp+0x8]
     939:	add    rsp,0x10
     93d:	mov    rsp,rbp
     940:	pop    rbp
     941:	ret

0000000000000942 <botlish_entry_11: ht_size<mutarray>>:
     942:	push   rbp
     943:	mov    rbp,rsp
     946:	mov    rsi,QWORD PTR [rdx]
     949:	call   94e <botlish_entry_11+0xc>
			94a: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     94e:	mov    rsp,rbp
     951:	pop    rbp
     952:	ret

0000000000000953 <botlish_fn_12: ht_tombstones<mutarray>>:
     953:	push   rbp
     954:	mov    rbp,rsp
     957:	sub    rsp,0x10
     95b:	mov    QWORD PTR [rsp],r13
     95f:	mov    QWORD PTR [rsp+0x8],r14
     964:	mov    r13,QWORD PTR [rdi]
     967:	mov    rax,QWORD PTR [rdi+0x8]
     96b:	lea    rcx,[r13+0x8]
     96f:	cmp    rcx,rax
     972:	ja     9cb <botlish_fn_12+0x78>
     978:	lea    rax,[r13+0x8]
     97c:	mov    QWORD PTR [rdi],rax
     97f:	mov    r14,rdi
     982:	mov    edx,0x9
     987:	mov    rdi,r14
     98a:	call   98f <botlish_fn_12+0x3c>
			98b: R_X86_64_PLT32	rt_mutarray_get-0x4
     98f:	test   rax,rax
     992:	jne    9b3 <botlish_fn_12+0x60>
     998:	mov    rdi,r14
     99b:	mov    QWORD PTR [rdi],r13
     99e:	xor    rax,rax
     9a1:	mov    r13,QWORD PTR [rsp]
     9a5:	mov    r14,QWORD PTR [rsp+0x8]
     9aa:	add    rsp,0x10
     9ae:	mov    rsp,rbp
     9b1:	pop    rbp
     9b2:	ret
     9b3:	mov    rdi,r14
     9b6:	mov    QWORD PTR [rdi],r13
     9b9:	mov    r13,QWORD PTR [rsp]
     9bd:	mov    r14,QWORD PTR [rsp+0x8]
     9c2:	add    rsp,0x10
     9c6:	mov    rsp,rbp
     9c9:	pop    rbp
     9ca:	ret
     9cb:	call   9d0 <botlish_fn_12+0x7d>
			9cc: R_X86_64_PLT32	rt_stack_overflow-0x4
     9d0:	xor    rax,rax
     9d3:	mov    r13,QWORD PTR [rsp]
     9d7:	mov    r14,QWORD PTR [rsp+0x8]
     9dc:	add    rsp,0x10
     9e0:	mov    rsp,rbp
     9e3:	pop    rbp
     9e4:	ret

00000000000009e5 <botlish_entry_12: ht_tombstones<mutarray>>:
     9e5:	push   rbp
     9e6:	mov    rbp,rsp
     9e9:	mov    rsi,QWORD PTR [rdx]
     9ec:	call   9f1 <botlish_entry_12+0xc>
			9ed: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     9f1:	mov    rsp,rbp
     9f4:	pop    rbp
     9f5:	ret

00000000000009f6 <botlish_fn_13: ht_capacity<mutarray>>:
     9f6:	push   rbp
     9f7:	mov    rbp,rsp
     9fa:	sub    rsp,0x10
     9fe:	mov    QWORD PTR [rsp],rbx
     a02:	mov    QWORD PTR [rsp+0x8],r12
     a07:	mov    rbx,QWORD PTR [rdi]
     a0a:	mov    rax,QWORD PTR [rdi+0x8]
     a0e:	lea    rcx,[rbx+0x8]
     a12:	cmp    rcx,rax
     a15:	ja     abf <botlish_fn_13+0xc9>
     a1b:	lea    rax,[rbx+0x8]
     a1f:	mov    QWORD PTR [rdi],rax
     a22:	mov    r12,rdi
     a25:	mov    QWORD PTR [rbx],rsi
     a28:	mov    rdi,r12
     a2b:	call   a30 <botlish_fn_13+0x3a>
			a2c: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     a30:	test   rax,rax
     a33:	jne    a41 <botlish_fn_13+0x4b>
     a39:	mov    rdi,r12
     a3c:	jmp    a84 <botlish_fn_13+0x8e>
     a41:	xor    ecx,ecx
     a43:	test   rax,0x7
     a49:	je     a57 <botlish_fn_13+0x61>
     a4f:	mov    rsi,rax
     a52:	jmp    a65 <botlish_fn_13+0x6f>
     a57:	movzx  rcx,BYTE PTR [rax]
     a5b:	mov    rsi,rax
     a5e:	rex cmp cl,0x8
     a62:	sete   cl
     a65:	test   cl,cl
     a67:	jne    a9f <botlish_fn_13+0xa9>
     a6d:	mov    rdi,r12
     a70:	mov    rax,QWORD PTR [rdi+0x10]
     a74:	mov    rcx,QWORD PTR [rax]
     a77:	mov    edx,0x8
     a7c:	call   a81 <botlish_fn_13+0x8b>
			a7d: R_X86_64_PLT32	rt_type_error-0x4
     a81:	mov    rdi,r12
     a84:	mov    rdi,r12
     a87:	mov    QWORD PTR [rdi],rbx
     a8a:	xor    rax,rax
     a8d:	mov    rbx,QWORD PTR [rsp]
     a91:	mov    r12,QWORD PTR [rsp+0x8]
     a96:	add    rsp,0x10
     a9a:	mov    rsp,rbp
     a9d:	pop    rbp
     a9e:	ret
     a9f:	mov    rdi,r12
     aa2:	call   aa7 <botlish_fn_13+0xb1>
			aa3: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     aa7:	mov    rdi,r12
     aaa:	mov    QWORD PTR [rdi],rbx
     aad:	mov    rbx,QWORD PTR [rsp]
     ab1:	mov    r12,QWORD PTR [rsp+0x8]
     ab6:	add    rsp,0x10
     aba:	mov    rsp,rbp
     abd:	pop    rbp
     abe:	ret
     abf:	mov    r12,rdi
     ac2:	call   ac7 <botlish_fn_13+0xd1>
			ac3: R_X86_64_PLT32	rt_stack_overflow-0x4
     ac7:	xor    rax,rax
     aca:	mov    rbx,QWORD PTR [rsp]
     ace:	mov    r12,QWORD PTR [rsp+0x8]
     ad3:	add    rsp,0x10
     ad7:	mov    rsp,rbp
     ada:	pop    rbp
     adb:	ret

0000000000000adc <botlish_entry_13: ht_capacity<mutarray>>:
     adc:	push   rbp
     add:	mov    rbp,rsp
     ae0:	mov    rsi,QWORD PTR [rdx]
     ae3:	call   ae8 <botlish_entry_13+0xc>
			ae4: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     ae8:	mov    rsp,rbp
     aeb:	pop    rbp
     aec:	ret

0000000000000aed <botlish_fn_14: ht_probe_start<mutarray, str>>:
     aed:	push   rbp
     aee:	mov    rbp,rsp
     af1:	sub    rsp,0x20
     af5:	mov    QWORD PTR [rsp],rbx
     af9:	mov    QWORD PTR [rsp+0x8],r12
     afe:	mov    QWORD PTR [rsp+0x10],r15
     b03:	mov    r15,QWORD PTR [rdi]
     b06:	mov    rax,QWORD PTR [rdi+0x8]
     b0a:	lea    rcx,[r15+0x10]
     b0e:	cmp    rcx,rax
     b11:	ja     bbd <botlish_fn_14+0xd0>
     b17:	lea    rax,[r15+0x10]
     b1b:	mov    QWORD PTR [rdi],rax
     b1e:	mov    rbx,rdi
     b21:	mov    QWORD PTR [r15],rsi
     b24:	mov    r12,rsi
     b27:	mov    rsi,rdx
     b2a:	mov    rdi,rbx
     b2d:	call   b32 <botlish_fn_14+0x45>
			b2e: R_X86_64_PLT32	rt_hash-0x4
     b32:	test   rax,rax
     b35:	jne    b43 <botlish_fn_14+0x56>
     b3b:	mov    rdi,rbx
     b3e:	jmp    b80 <botlish_fn_14+0x93>
     b43:	mov    QWORD PTR [r15+0x8],rax
     b47:	mov    rsi,r12
     b4a:	mov    r12,rax
     b4d:	mov    rdi,rbx
     b50:	call   b55 <botlish_fn_14+0x68>
			b51: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     b55:	test   rax,rax
     b58:	mov    rdx,rax
     b5b:	jne    b69 <botlish_fn_14+0x7c>
     b61:	mov    rdi,rbx
     b64:	jmp    b80 <botlish_fn_14+0x93>
     b69:	mov    rsi,r12
     b6c:	mov    rdi,rbx
     b6f:	call   b74 <botlish_fn_14+0x87>
			b70: R_X86_64_PLT32	rt_int_mod-0x4
     b74:	test   rax,rax
     b77:	jne    ba0 <botlish_fn_14+0xb3>
     b7d:	mov    rdi,rbx
     b80:	mov    rdi,rbx
     b83:	mov    QWORD PTR [rdi],r15
     b86:	xor    rax,rax
     b89:	mov    rbx,QWORD PTR [rsp]
     b8d:	mov    r12,QWORD PTR [rsp+0x8]
     b92:	mov    r15,QWORD PTR [rsp+0x10]
     b97:	add    rsp,0x20
     b9b:	mov    rsp,rbp
     b9e:	pop    rbp
     b9f:	ret
     ba0:	mov    rdi,rbx
     ba3:	mov    QWORD PTR [rdi],r15
     ba6:	mov    rbx,QWORD PTR [rsp]
     baa:	mov    r12,QWORD PTR [rsp+0x8]
     baf:	mov    r15,QWORD PTR [rsp+0x10]
     bb4:	add    rsp,0x20
     bb8:	mov    rsp,rbp
     bbb:	pop    rbp
     bbc:	ret
     bbd:	mov    rbx,rdi
     bc0:	call   bc5 <botlish_fn_14+0xd8>
			bc1: R_X86_64_PLT32	rt_stack_overflow-0x4
     bc5:	xor    rax,rax
     bc8:	mov    rbx,QWORD PTR [rsp]
     bcc:	mov    r12,QWORD PTR [rsp+0x8]
     bd1:	mov    r15,QWORD PTR [rsp+0x10]
     bd6:	add    rsp,0x20
     bda:	mov    rsp,rbp
     bdd:	pop    rbp
     bde:	ret

0000000000000bdf <botlish_entry_14: ht_probe_start<mutarray, str>>:
     bdf:	push   rbp
     be0:	mov    rbp,rsp
     be3:	mov    rsi,QWORD PTR [rdx]
     be6:	mov    rdx,QWORD PTR [rdx+0x8]
     bea:	call   bef <botlish_entry_14+0x10>
			beb: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     bef:	mov    rsp,rbp
     bf2:	pop    rbp
     bf3:	ret

0000000000000bf4 <botlish_fn_15: ht_probe_next<mutarray, int>>:
     bf4:	push   rbp
     bf5:	mov    rbp,rsp
     bf8:	sub    rsp,0x20
     bfc:	mov    QWORD PTR [rsp],rbx
     c00:	mov    QWORD PTR [rsp+0x8],r12
     c05:	mov    QWORD PTR [rsp+0x10],r13
     c0a:	mov    rbx,QWORD PTR [rdi]
     c0d:	mov    rax,QWORD PTR [rdi+0x8]
     c11:	lea    rcx,[rbx+0x18]
     c15:	cmp    rcx,rax
     c18:	ja     cf4 <botlish_fn_15+0x100>
     c1e:	lea    rax,[rbx+0x18]
     c22:	mov    QWORD PTR [rdi],rax
     c25:	mov    r12,rdi
     c28:	mov    QWORD PTR [rbx],rsi
     c2b:	mov    r13,rsi
     c2e:	mov    QWORD PTR [rbx+0x8],rdx
     c32:	mov    QWORD PTR [rbx+0x10],0x3
     c3a:	test   rdx,0x1
     c41:	jne    c4f <botlish_fn_15+0x5b>
     c47:	mov    rcx,rdx
     c4a:	jmp    c64 <botlish_fn_15+0x70>
     c4f:	mov    rsi,rdx
     c52:	add    rsi,0x2
     c56:	mov    rcx,rdx
     c59:	seto   al
     c5c:	test   al,al
     c5e:	je     c77 <botlish_fn_15+0x83>
     c64:	mov    edx,0x3
     c69:	mov    rsi,rcx
     c6c:	mov    rdi,r12
     c6f:	call   c74 <botlish_fn_15+0x80>
			c70: R_X86_64_PLT32	rt_int_add-0x4
     c74:	mov    rsi,rax
     c77:	mov    QWORD PTR [rbx+0x8],rsi
     c7b:	mov    rax,rsi
     c7e:	mov    rsi,r13
     c81:	mov    r13,rax
     c84:	mov    rdi,r12
     c87:	call   c8c <botlish_fn_15+0x98>
			c88: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     c8c:	test   rax,rax
     c8f:	mov    rdx,rax
     c92:	jne    ca0 <botlish_fn_15+0xac>
     c98:	mov    rdi,r12
     c9b:	jmp    cb7 <botlish_fn_15+0xc3>
     ca0:	mov    rsi,r13
     ca3:	mov    rdi,r12
     ca6:	call   cab <botlish_fn_15+0xb7>
			ca7: R_X86_64_PLT32	rt_int_mod-0x4
     cab:	test   rax,rax
     cae:	jne    cd7 <botlish_fn_15+0xe3>
     cb4:	mov    rdi,r12
     cb7:	mov    rdi,r12
     cba:	mov    QWORD PTR [rdi],rbx
     cbd:	xor    rax,rax
     cc0:	mov    rbx,QWORD PTR [rsp]
     cc4:	mov    r12,QWORD PTR [rsp+0x8]
     cc9:	mov    r13,QWORD PTR [rsp+0x10]
     cce:	add    rsp,0x20
     cd2:	mov    rsp,rbp
     cd5:	pop    rbp
     cd6:	ret
     cd7:	mov    rdi,r12
     cda:	mov    QWORD PTR [rdi],rbx
     cdd:	mov    rbx,QWORD PTR [rsp]
     ce1:	mov    r12,QWORD PTR [rsp+0x8]
     ce6:	mov    r13,QWORD PTR [rsp+0x10]
     ceb:	add    rsp,0x20
     cef:	mov    rsp,rbp
     cf2:	pop    rbp
     cf3:	ret
     cf4:	mov    r12,rdi
     cf7:	call   cfc <botlish_fn_15+0x108>
			cf8: R_X86_64_PLT32	rt_stack_overflow-0x4
     cfc:	xor    rax,rax
     cff:	mov    rbx,QWORD PTR [rsp]
     d03:	mov    r12,QWORD PTR [rsp+0x8]
     d08:	mov    r13,QWORD PTR [rsp+0x10]
     d0d:	add    rsp,0x20
     d11:	mov    rsp,rbp
     d14:	pop    rbp
     d15:	ret

0000000000000d16 <botlish_entry_15: ht_probe_next<mutarray, int>>:
     d16:	push   rbp
     d17:	mov    rbp,rsp
     d1a:	mov    rsi,QWORD PTR [rdx]
     d1d:	mov    rdx,QWORD PTR [rdx+0x8]
     d21:	call   d26 <botlish_entry_15+0x10>
			d22: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     d26:	mov    rsp,rbp
     d29:	pop    rbp
     d2a:	ret
     d2b:	add    BYTE PTR [rax],al
     d2d:	add    BYTE PTR [rax],al
	...

0000000000000d30 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     d30:	push   rbp
     d31:	mov    rbp,rsp
     d34:	sub    rsp,0x40
     d38:	mov    QWORD PTR [rsp+0x10],rbx
     d3d:	mov    QWORD PTR [rsp+0x18],r12
     d42:	mov    QWORD PTR [rsp+0x20],r13
     d47:	mov    QWORD PTR [rsp+0x28],r14
     d4c:	mov    QWORD PTR [rsp+0x30],r15
     d51:	mov    r13,QWORD PTR [rdi]
     d54:	mov    rax,QWORD PTR [rdi+0x8]
     d58:	lea    r8,[r13+0x20]
     d5c:	cmp    r8,rax
     d5f:	ja     10a1 <botlish_fn_16+0x371>
     d65:	lea    rax,[r13+0x20]
     d69:	mov    QWORD PTR [rdi],rax
     d6c:	mov    r14,rdi
     d6f:	mov    QWORD PTR [r13+0x18],0x0
     d77:	mov    QWORD PTR [r13+0x0],rsi
     d7b:	mov    QWORD PTR [r13+0x8],rdx
     d7f:	mov    QWORD PTR [rsp],rdx
     d83:	mov    QWORD PTR [r13+0x10],rcx
     d87:	mov    r15,rsi
     d8a:	mov    QWORD PTR [rsp+0x8],rcx
     d8f:	mov    rsi,r15
     d92:	mov    rdi,r14
     d95:	call   d9a <botlish_fn_16+0x6a>
			d96: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     d9a:	test   rax,rax
     d9d:	jne    dab <botlish_fn_16+0x7b>
     da3:	mov    rdi,r14
     da6:	jmp    1000 <botlish_fn_16+0x2d0>
     dab:	xor    ecx,ecx
     dad:	test   rax,0x7
     db3:	je     dc1 <botlish_fn_16+0x91>
     db9:	mov    rsi,rax
     dbc:	jmp    dcf <botlish_fn_16+0x9f>
     dc1:	movzx  r11,BYTE PTR [rax]
     dc5:	mov    rsi,rax
     dc8:	cmp    r11b,0x8
     dcc:	sete   cl
     dcf:	test   cl,cl
     dd1:	jne    df4 <botlish_fn_16+0xc4>
     dd7:	mov    rdi,r14
     dda:	mov    rax,QWORD PTR [rdi+0x10]
     dde:	mov    rcx,QWORD PTR [rax+0x8]
     de2:	mov    edx,0x8
     de7:	call   dec <botlish_fn_16+0xbc>
			de8: R_X86_64_PLT32	rt_type_error-0x4
     dec:	mov    rdi,r14
     def:	jmp    1000 <botlish_fn_16+0x2d0>
     df4:	mov    rdx,QWORD PTR [rsp+0x8]
     df9:	mov    rdi,r14
     dfc:	call   e01 <botlish_fn_16+0xd1>
			dfd: R_X86_64_PLT32	rt_mutarray_get-0x4
     e01:	mov    rcx,rax
     e04:	mov    r12,rax
     e07:	test   rax,rcx
     e0a:	jne    e18 <botlish_fn_16+0xe8>
     e10:	mov    rdi,r14
     e13:	jmp    1000 <botlish_fn_16+0x2d0>
     e18:	mov    rax,r12
     e1b:	mov    QWORD PTR [r13+0x18],rax
     e1f:	mov    rdi,r14
     e22:	call   e27 <botlish_fn_16+0xf7>
			e23: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     e27:	test   rax,rax
     e2a:	jne    e38 <botlish_fn_16+0x108>
     e30:	mov    rdi,r14
     e33:	jmp    1000 <botlish_fn_16+0x2d0>
     e38:	mov    rsi,r12
     e3b:	mov    rcx,rsi
     e3e:	and    rcx,rax
     e41:	mov    rdx,rax
     e44:	test   rcx,0x1
     e4b:	jne    e6d <botlish_fn_16+0x13d>
     e51:	mov    rsi,r12
     e54:	mov    rdi,r14
     e57:	call   e5c <botlish_fn_16+0x12c>
			e58: R_X86_64_PLT32	rt_value_eq-0x4
     e5c:	test   rax,rax
     e5f:	jne    e7d <botlish_fn_16+0x14d>
     e65:	mov    rdi,r14
     e68:	jmp    1000 <botlish_fn_16+0x2d0>
     e6d:	mov    eax,0x2
     e72:	cmp    r12,rdx
     e75:	cmove  rax,QWORD PTR [rip+0x253]        # 10d0 <botlish_fn_16+0x3a0>
     e7d:	mov    ebx,0x6
     e82:	cmp    rax,0x6
     e86:	je     1072 <botlish_fn_16+0x342>
     e8c:	mov    rdi,r14
     e8f:	call   e94 <botlish_fn_16+0x164>
			e90: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     e94:	test   rax,rax
     e97:	jne    ea5 <botlish_fn_16+0x175>
     e9d:	mov    rdi,r14
     ea0:	jmp    1000 <botlish_fn_16+0x2d0>
     ea5:	mov    rcx,r12
     ea8:	and    rcx,rax
     eab:	mov    rdx,rax
     eae:	test   rcx,0x1
     eb5:	jne    ed7 <botlish_fn_16+0x1a7>
     ebb:	mov    rsi,r12
     ebe:	mov    rdi,r14
     ec1:	call   ec6 <botlish_fn_16+0x196>
			ec2: R_X86_64_PLT32	rt_value_eq-0x4
     ec6:	test   rax,rax
     ec9:	jne    eea <botlish_fn_16+0x1ba>
     ecf:	mov    rdi,r14
     ed2:	jmp    1000 <botlish_fn_16+0x2d0>
     ed7:	mov    rsi,r12
     eda:	mov    eax,0x2
     edf:	cmp    rsi,rdx
     ee2:	cmove  rax,QWORD PTR [rip+0x1e6]        # 10d0 <botlish_fn_16+0x3a0>
     eea:	cmp    rax,0x6
     eee:	je     f02 <botlish_fn_16+0x1d2>
     ef4:	mov    ebx,0x2
     ef9:	mov    r12,QWORD PTR [rsp]
     efd:	jmp    fda <botlish_fn_16+0x2aa>
     f02:	mov    rsi,r15
     f05:	mov    rdi,r14
     f08:	call   f0d <botlish_fn_16+0x1dd>
			f09: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     f0d:	test   rax,rax
     f10:	jne    f1e <botlish_fn_16+0x1ee>
     f16:	mov    rdi,r14
     f19:	jmp    1000 <botlish_fn_16+0x2d0>
     f1e:	xor    ecx,ecx
     f20:	test   rax,0x7
     f26:	je     f34 <botlish_fn_16+0x204>
     f2c:	mov    rsi,rax
     f2f:	jmp    f42 <botlish_fn_16+0x212>
     f34:	movzx  rcx,BYTE PTR [rax]
     f38:	mov    rsi,rax
     f3b:	rex cmp cl,0x8
     f3f:	sete   cl
     f42:	test   cl,cl
     f44:	jne    f67 <botlish_fn_16+0x237>
     f4a:	mov    rdi,r14
     f4d:	mov    rax,QWORD PTR [rdi+0x10]
     f51:	mov    rcx,QWORD PTR [rax+0x8]
     f55:	mov    edx,0x8
     f5a:	call   f5f <botlish_fn_16+0x22f>
			f5b: R_X86_64_PLT32	rt_type_error-0x4
     f5f:	mov    rdi,r14
     f62:	jmp    1000 <botlish_fn_16+0x2d0>
     f67:	mov    rdx,QWORD PTR [rsp+0x8]
     f6c:	mov    rdi,r14
     f6f:	call   f74 <botlish_fn_16+0x244>
			f70: R_X86_64_PLT32	rt_mutarray_get-0x4
     f74:	test   rax,rax
     f77:	jne    f85 <botlish_fn_16+0x255>
     f7d:	mov    rdi,r14
     f80:	jmp    1000 <botlish_fn_16+0x2d0>
     f85:	mov    r12,QWORD PTR [rsp]
     f89:	mov    rcx,rax
     f8c:	and    rcx,r12
     f8f:	mov    rsi,rax
     f92:	test   rcx,0x1
     f99:	jne    fbb <botlish_fn_16+0x28b>
     f9f:	mov    rdx,r12
     fa2:	mov    rdi,r14
     fa5:	call   faa <botlish_fn_16+0x27a>
			fa6: R_X86_64_PLT32	rt_value_eq-0x4
     faa:	test   rax,rax
     fad:	jne    fcb <botlish_fn_16+0x29b>
     fb3:	mov    rdi,r14
     fb6:	jmp    1000 <botlish_fn_16+0x2d0>
     fbb:	mov    eax,0x2
     fc0:	cmp    rsi,r12
     fc3:	cmove  rax,QWORD PTR [rip+0x105]        # 10d0 <botlish_fn_16+0x3a0>
     fcb:	cmp    rax,0x6
     fcf:	je     fda <botlish_fn_16+0x2aa>
     fd5:	mov    ebx,0x2
     fda:	cmp    rbx,0x6
     fde:	je     1045 <botlish_fn_16+0x315>
     fe4:	mov    rdx,QWORD PTR [rsp+0x8]
     fe9:	mov    rsi,r15
     fec:	mov    rdi,r14
     fef:	call   ff4 <botlish_fn_16+0x2c4>
			ff0: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     ff4:	test   rax,rax
     ff7:	jne    102b <botlish_fn_16+0x2fb>
     ffd:	mov    rdi,r14
    1000:	mov    rdi,r14
    1003:	mov    QWORD PTR [rdi],r13
    1006:	xor    rax,rax
    1009:	mov    rbx,QWORD PTR [rsp+0x10]
    100e:	mov    r12,QWORD PTR [rsp+0x18]
    1013:	mov    r13,QWORD PTR [rsp+0x20]
    1018:	mov    r14,QWORD PTR [rsp+0x28]
    101d:	mov    r15,QWORD PTR [rsp+0x30]
    1022:	add    rsp,0x40
    1026:	mov    rsp,rbp
    1029:	pop    rbp
    102a:	ret
    102b:	mov    QWORD PTR [r13+0x0],r15
    102f:	mov    QWORD PTR [r13+0x8],r12
    1033:	mov    QWORD PTR [r13+0x10],rax
    1037:	mov    QWORD PTR [rsp],r12
    103b:	mov    QWORD PTR [rsp+0x8],rax
    1040:	jmp    d8f <botlish_fn_16+0x5f>
    1045:	mov    rdi,r14
    1048:	mov    QWORD PTR [rdi],r13
    104b:	mov    rax,QWORD PTR [rsp+0x8]
    1050:	mov    rbx,QWORD PTR [rsp+0x10]
    1055:	mov    r12,QWORD PTR [rsp+0x18]
    105a:	mov    r13,QWORD PTR [rsp+0x20]
    105f:	mov    r14,QWORD PTR [rsp+0x28]
    1064:	mov    r15,QWORD PTR [rsp+0x30]
    1069:	add    rsp,0x40
    106d:	mov    rsp,rbp
    1070:	pop    rbp
    1071:	ret
    1072:	mov    rdi,r14
    1075:	mov    QWORD PTR [rdi],r13
    1078:	mov    rax,0xffffffffffffffff
    107f:	mov    rbx,QWORD PTR [rsp+0x10]
    1084:	mov    r12,QWORD PTR [rsp+0x18]
    1089:	mov    r13,QWORD PTR [rsp+0x20]
    108e:	mov    r14,QWORD PTR [rsp+0x28]
    1093:	mov    r15,QWORD PTR [rsp+0x30]
    1098:	add    rsp,0x40
    109c:	mov    rsp,rbp
    109f:	pop    rbp
    10a0:	ret
    10a1:	mov    r14,rdi
    10a4:	call   10a9 <botlish_fn_16+0x379>
			10a5: R_X86_64_PLT32	rt_stack_overflow-0x4
    10a9:	xor    rax,rax
    10ac:	mov    rbx,QWORD PTR [rsp+0x10]
    10b1:	mov    r12,QWORD PTR [rsp+0x18]
    10b6:	mov    r13,QWORD PTR [rsp+0x20]
    10bb:	mov    r14,QWORD PTR [rsp+0x28]
    10c0:	mov    r15,QWORD PTR [rsp+0x30]
    10c5:	add    rsp,0x40
    10c9:	mov    rsp,rbp
    10cc:	pop    rbp
    10cd:	ret
    10ce:	add    BYTE PTR [rax],al
    10d0:	(bad)
    10d1:	add    BYTE PTR [rax],al
    10d3:	add    BYTE PTR [rax],al
    10d5:	add    BYTE PTR [rax],al
	...

00000000000010d8 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
    10d8:	push   rbp
    10d9:	mov    rbp,rsp
    10dc:	mov    rsi,QWORD PTR [rdx]
    10df:	mov    r8,QWORD PTR [rdx+0x8]
    10e3:	mov    rcx,QWORD PTR [rdx+0x10]
    10e7:	mov    rdx,r8
    10ea:	call   10ef <botlish_entry_16+0x17>
			10eb: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    10ef:	mov    rsp,rbp
    10f2:	pop    rbp
    10f3:	ret
    10f4:	add    BYTE PTR [rax],al
	...

00000000000010f8 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
    10f8:	push   rbp
    10f9:	mov    rbp,rsp
    10fc:	sub    rsp,0x50
    1100:	mov    QWORD PTR [rsp+0x20],rbx
    1105:	mov    QWORD PTR [rsp+0x28],r12
    110a:	mov    QWORD PTR [rsp+0x30],r13
    110f:	mov    QWORD PTR [rsp+0x38],r14
    1114:	mov    QWORD PTR [rsp+0x40],r15
    1119:	mov    r13,QWORD PTR [rdi]
    111c:	mov    rax,QWORD PTR [rdi+0x8]
    1120:	lea    r9,[r13+0x28]
    1124:	cmp    r9,rax
    1127:	ja     1648 <botlish_fn_17+0x550>
    112d:	lea    rax,[r13+0x28]
    1131:	mov    QWORD PTR [rdi],rax
    1134:	mov    QWORD PTR [rsp],rdi
    1138:	mov    QWORD PTR [r13+0x20],0x0
    1140:	mov    QWORD PTR [r13+0x0],rsi
    1144:	mov    QWORD PTR [r13+0x8],rdx
    1148:	mov    r14,rdx
    114b:	mov    QWORD PTR [r13+0x10],rcx
    114f:	mov    QWORD PTR [r13+0x18],r8
    1153:	mov    rbx,rsi
    1156:	mov    r15,r8
    1159:	mov    QWORD PTR [rsp+0x8],rcx
    115e:	mov    rsi,rbx
    1161:	mov    rdi,QWORD PTR [rsp]
    1165:	call   116a <botlish_fn_17+0x72>
			1166: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    116a:	test   rax,rax
    116d:	jne    117c <botlish_fn_17+0x84>
    1173:	mov    rdi,QWORD PTR [rsp]
    1177:	jmp    151b <botlish_fn_17+0x423>
    117c:	xor    ecx,ecx
    117e:	test   rax,0x7
    1184:	je     1192 <botlish_fn_17+0x9a>
    118a:	mov    rsi,rax
    118d:	jmp    11a0 <botlish_fn_17+0xa8>
    1192:	movzx  rcx,BYTE PTR [rax]
    1196:	mov    rsi,rax
    1199:	rex cmp cl,0x8
    119d:	sete   cl
    11a0:	test   cl,cl
    11a2:	jne    11c7 <botlish_fn_17+0xcf>
    11a8:	mov    rdi,QWORD PTR [rsp]
    11ac:	mov    rax,QWORD PTR [rdi+0x10]
    11b0:	mov    rcx,QWORD PTR [rax+0x8]
    11b4:	mov    edx,0x8
    11b9:	call   11be <botlish_fn_17+0xc6>
			11ba: R_X86_64_PLT32	rt_type_error-0x4
    11be:	mov    rdi,QWORD PTR [rsp]
    11c2:	jmp    151b <botlish_fn_17+0x423>
    11c7:	mov    rdx,QWORD PTR [rsp+0x8]
    11cc:	mov    rdi,QWORD PTR [rsp]
    11d0:	call   11d5 <botlish_fn_17+0xdd>
			11d1: R_X86_64_PLT32	rt_mutarray_get-0x4
    11d5:	mov    rcx,rax
    11d8:	mov    QWORD PTR [rsp+0x10],rax
    11dd:	test   rax,rcx
    11e0:	jne    11ef <botlish_fn_17+0xf7>
    11e6:	mov    rdi,QWORD PTR [rsp]
    11ea:	jmp    151b <botlish_fn_17+0x423>
    11ef:	mov    rax,QWORD PTR [rsp+0x10]
    11f4:	mov    QWORD PTR [r13+0x20],rax
    11f8:	mov    rdi,QWORD PTR [rsp]
    11fc:	call   1201 <botlish_fn_17+0x109>
			11fd: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    1201:	test   rax,rax
    1204:	jne    1213 <botlish_fn_17+0x11b>
    120a:	mov    rdi,QWORD PTR [rsp]
    120e:	jmp    151b <botlish_fn_17+0x423>
    1213:	mov    rcx,QWORD PTR [rsp+0x10]
    1218:	and    rcx,rax
    121b:	mov    rdx,rax
    121e:	test   rcx,0x1
    1225:	jne    124b <botlish_fn_17+0x153>
    122b:	mov    rsi,QWORD PTR [rsp+0x10]
    1230:	mov    rdi,QWORD PTR [rsp]
    1234:	call   1239 <botlish_fn_17+0x141>
			1235: R_X86_64_PLT32	rt_value_eq-0x4
    1239:	test   rax,rax
    123c:	jne    1260 <botlish_fn_17+0x168>
    1242:	mov    rdi,QWORD PTR [rsp]
    1246:	jmp    151b <botlish_fn_17+0x423>
    124b:	mov    eax,0x2
    1250:	mov    rcx,QWORD PTR [rsp+0x10]
    1255:	cmp    rcx,rdx
    1258:	cmove  rax,QWORD PTR [rip+0x418]        # 1678 <botlish_fn_17+0x580>
    1260:	mov    r12d,0x6
    1266:	cmp    rax,0x6
    126a:	je     1599 <botlish_fn_17+0x4a1>
    1270:	mov    rdi,QWORD PTR [rsp]
    1274:	call   1279 <botlish_fn_17+0x181>
			1275: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1279:	test   rax,rax
    127c:	jne    128b <botlish_fn_17+0x193>
    1282:	mov    rdi,QWORD PTR [rsp]
    1286:	jmp    151b <botlish_fn_17+0x423>
    128b:	mov    rcx,QWORD PTR [rsp+0x10]
    1290:	and    rcx,rax
    1293:	mov    rdx,rax
    1296:	test   rcx,0x1
    129d:	jne    12c3 <botlish_fn_17+0x1cb>
    12a3:	mov    rsi,QWORD PTR [rsp+0x10]
    12a8:	mov    rdi,QWORD PTR [rsp]
    12ac:	call   12b1 <botlish_fn_17+0x1b9>
			12ad: R_X86_64_PLT32	rt_value_eq-0x4
    12b1:	test   rax,rax
    12b4:	jne    12d8 <botlish_fn_17+0x1e0>
    12ba:	mov    rdi,QWORD PTR [rsp]
    12be:	jmp    151b <botlish_fn_17+0x423>
    12c3:	mov    eax,0x2
    12c8:	mov    rsi,QWORD PTR [rsp+0x10]
    12cd:	cmp    rsi,rdx
    12d0:	cmove  rax,QWORD PTR [rip+0x3a0]        # 1678 <botlish_fn_17+0x580>
    12d8:	cmp    rax,0x6
    12dc:	je     12ec <botlish_fn_17+0x1f4>
    12e2:	mov    eax,0x2
    12e7:	jmp    13d0 <botlish_fn_17+0x2d8>
    12ec:	mov    rsi,rbx
    12ef:	mov    rdi,QWORD PTR [rsp]
    12f3:	call   12f8 <botlish_fn_17+0x200>
			12f4: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    12f8:	test   rax,rax
    12fb:	jne    130a <botlish_fn_17+0x212>
    1301:	mov    rdi,QWORD PTR [rsp]
    1305:	jmp    151b <botlish_fn_17+0x423>
    130a:	xor    ecx,ecx
    130c:	test   rax,0x7
    1312:	je     1320 <botlish_fn_17+0x228>
    1318:	mov    rsi,rax
    131b:	jmp    132e <botlish_fn_17+0x236>
    1320:	movzx  rcx,BYTE PTR [rax]
    1324:	mov    rsi,rax
    1327:	rex cmp cl,0x8
    132b:	sete   cl
    132e:	test   cl,cl
    1330:	jne    1355 <botlish_fn_17+0x25d>
    1336:	mov    rdi,QWORD PTR [rsp]
    133a:	mov    rax,QWORD PTR [rdi+0x10]
    133e:	mov    rcx,QWORD PTR [rax+0x8]
    1342:	mov    edx,0x8
    1347:	call   134c <botlish_fn_17+0x254>
			1348: R_X86_64_PLT32	rt_type_error-0x4
    134c:	mov    rdi,QWORD PTR [rsp]
    1350:	jmp    151b <botlish_fn_17+0x423>
    1355:	mov    rdx,QWORD PTR [rsp+0x8]
    135a:	mov    rdi,QWORD PTR [rsp]
    135e:	call   1363 <botlish_fn_17+0x26b>
			135f: R_X86_64_PLT32	rt_mutarray_get-0x4
    1363:	test   rax,rax
    1366:	jne    1375 <botlish_fn_17+0x27d>
    136c:	mov    rdi,QWORD PTR [rsp]
    1370:	jmp    151b <botlish_fn_17+0x423>
    1375:	mov    rcx,rax
    1378:	and    rcx,r14
    137b:	mov    rsi,rax
    137e:	test   rcx,0x1
    1385:	jne    13a9 <botlish_fn_17+0x2b1>
    138b:	mov    rdx,r14
    138e:	mov    rdi,QWORD PTR [rsp]
    1392:	call   1397 <botlish_fn_17+0x29f>
			1393: R_X86_64_PLT32	rt_value_eq-0x4
    1397:	test   rax,rax
    139a:	jne    13b9 <botlish_fn_17+0x2c1>
    13a0:	mov    rdi,QWORD PTR [rsp]
    13a4:	jmp    151b <botlish_fn_17+0x423>
    13a9:	mov    eax,0x2
    13ae:	cmp    rsi,r14
    13b1:	cmove  rax,QWORD PTR [rip+0x2bf]        # 1678 <botlish_fn_17+0x580>
    13b9:	cmp    rax,0x6
    13bd:	je     13cd <botlish_fn_17+0x2d5>
    13c3:	mov    eax,0x2
    13c8:	jmp    13d0 <botlish_fn_17+0x2d8>
    13cd:	mov    rax,r12
    13d0:	cmp    rax,0x6
    13d4:	je     156b <botlish_fn_17+0x473>
    13da:	mov    rdi,QWORD PTR [rsp]
    13de:	call   13e3 <botlish_fn_17+0x2eb>
			13df: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    13e3:	test   rax,rax
    13e6:	jne    13f5 <botlish_fn_17+0x2fd>
    13ec:	mov    rdi,QWORD PTR [rsp]
    13f0:	jmp    151b <botlish_fn_17+0x423>
    13f5:	mov    rcx,QWORD PTR [rsp+0x10]
    13fa:	mov    rdx,rcx
    13fd:	and    rdx,rax
    1400:	mov    r11,rax
    1403:	test   rdx,0x1
    140a:	jne    1433 <botlish_fn_17+0x33b>
    1410:	mov    rdx,r11
    1413:	mov    rsi,QWORD PTR [rsp+0x10]
    1418:	mov    rdi,QWORD PTR [rsp]
    141c:	call   1421 <botlish_fn_17+0x329>
			141d: R_X86_64_PLT32	rt_value_eq-0x4
    1421:	test   rax,rax
    1424:	jne    144b <botlish_fn_17+0x353>
    142a:	mov    rdi,QWORD PTR [rsp]
    142e:	jmp    151b <botlish_fn_17+0x423>
    1433:	mov    rdx,r11
    1436:	mov    rsi,QWORD PTR [rsp+0x10]
    143b:	mov    eax,0x2
    1440:	cmp    rsi,rdx
    1443:	cmove  rax,QWORD PTR [rip+0x22d]        # 1678 <botlish_fn_17+0x580>
    144b:	cmp    rax,0x6
    144f:	je     1460 <botlish_fn_17+0x368>
    1455:	mov    r12d,0x2
    145b:	jmp    14b3 <botlish_fn_17+0x3bb>
    1460:	test   r15,0x1
    1467:	jne    1493 <botlish_fn_17+0x39b>
    146d:	mov    edx,0x1
    1472:	mov    rsi,r15
    1475:	mov    rdi,QWORD PTR [rsp]
    1479:	call   147e <botlish_fn_17+0x386>
			147a: R_X86_64_PLT32	rt_int_cmp-0x4
    147e:	mov    ecx,0x2
    1483:	test   rax,rax
    1486:	cmovl  rcx,QWORD PTR [rip+0x1ea]        # 1678 <botlish_fn_17+0x580>
    148e:	jmp    14a3 <botlish_fn_17+0x3ab>
    1493:	mov    ecx,0x2
    1498:	test   r15,r15
    149b:	cmovle rcx,QWORD PTR [rip+0x1d5]        # 1678 <botlish_fn_17+0x580>
    14a3:	cmp    rcx,0x6
    14a7:	je     14b3 <botlish_fn_17+0x3bb>
    14ad:	mov    r12d,0x2
    14b3:	cmp    r12,0x6
    14b7:	je     14fd <botlish_fn_17+0x405>
    14bd:	mov    rdx,QWORD PTR [rsp+0x8]
    14c2:	mov    rsi,rbx
    14c5:	mov    rdi,QWORD PTR [rsp]
    14c9:	call   14ce <botlish_fn_17+0x3d6>
			14ca: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    14ce:	test   rax,rax
    14d1:	jne    14e0 <botlish_fn_17+0x3e8>
    14d7:	mov    rdi,QWORD PTR [rsp]
    14db:	jmp    151b <botlish_fn_17+0x423>
    14e0:	mov    QWORD PTR [r13+0x0],rbx
    14e4:	mov    QWORD PTR [r13+0x8],r14
    14e8:	mov    QWORD PTR [r13+0x10],rax
    14ec:	mov    rcx,r15
    14ef:	mov    QWORD PTR [r13+0x18],rcx
    14f3:	mov    QWORD PTR [rsp+0x8],rax
    14f8:	jmp    115e <botlish_fn_17+0x66>
    14fd:	mov    rdx,QWORD PTR [rsp+0x8]
    1502:	mov    rsi,rbx
    1505:	mov    rdi,QWORD PTR [rsp]
    1509:	call   150e <botlish_fn_17+0x416>
			150a: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    150e:	test   rax,rax
    1511:	jne    1547 <botlish_fn_17+0x44f>
    1517:	mov    rdi,QWORD PTR [rsp]
    151b:	mov    rdi,QWORD PTR [rsp]
    151f:	mov    QWORD PTR [rdi],r13
    1522:	xor    rax,rax
    1525:	mov    rbx,QWORD PTR [rsp+0x20]
    152a:	mov    r12,QWORD PTR [rsp+0x28]
    152f:	mov    r13,QWORD PTR [rsp+0x30]
    1534:	mov    r14,QWORD PTR [rsp+0x38]
    1539:	mov    r15,QWORD PTR [rsp+0x40]
    153e:	add    rsp,0x50
    1542:	mov    rsp,rbp
    1545:	pop    rbp
    1546:	ret
    1547:	mov    QWORD PTR [r13+0x0],rbx
    154b:	mov    QWORD PTR [r13+0x8],r14
    154f:	mov    QWORD PTR [r13+0x10],rax
    1553:	mov    rdx,QWORD PTR [rsp+0x8]
    1558:	mov    QWORD PTR [r13+0x18],rdx
    155c:	mov    r15,QWORD PTR [rsp+0x8]
    1561:	mov    QWORD PTR [rsp+0x8],rax
    1566:	jmp    115e <botlish_fn_17+0x66>
    156b:	mov    rdi,QWORD PTR [rsp]
    156f:	mov    QWORD PTR [rdi],r13
    1572:	mov    rax,QWORD PTR [rsp+0x8]
    1577:	mov    rbx,QWORD PTR [rsp+0x20]
    157c:	mov    r12,QWORD PTR [rsp+0x28]
    1581:	mov    r13,QWORD PTR [rsp+0x30]
    1586:	mov    r14,QWORD PTR [rsp+0x38]
    158b:	mov    r15,QWORD PTR [rsp+0x40]
    1590:	add    rsp,0x50
    1594:	mov    rsp,rbp
    1597:	pop    rbp
    1598:	ret
    1599:	mov    rax,r15
    159c:	test   rax,0x1
    15a2:	jne    15ce <botlish_fn_17+0x4d6>
    15a8:	mov    edx,0x1
    15ad:	mov    rsi,r15
    15b0:	mov    rdi,QWORD PTR [rsp]
    15b4:	call   15b9 <botlish_fn_17+0x4c1>
			15b5: R_X86_64_PLT32	rt_int_cmp-0x4
    15b9:	mov    ecx,0x2
    15be:	test   rax,rax
    15c1:	cmovge rcx,QWORD PTR [rip+0xaf]        # 1678 <botlish_fn_17+0x580>
    15c9:	jmp    15e4 <botlish_fn_17+0x4ec>
    15ce:	mov    ecx,0x2
    15d3:	mov    rax,r15
    15d6:	mov    r10,r15
    15d9:	test   rax,r10
    15dc:	cmovg  rcx,QWORD PTR [rip+0x94]        # 1678 <botlish_fn_17+0x580>
    15e4:	cmp    rcx,0x6
    15e8:	je     161c <botlish_fn_17+0x524>
    15ee:	mov    rdi,QWORD PTR [rsp]
    15f2:	mov    QWORD PTR [rdi],r13
    15f5:	mov    rax,QWORD PTR [rsp+0x8]
    15fa:	mov    rbx,QWORD PTR [rsp+0x20]
    15ff:	mov    r12,QWORD PTR [rsp+0x28]
    1604:	mov    r13,QWORD PTR [rsp+0x30]
    1609:	mov    r14,QWORD PTR [rsp+0x38]
    160e:	mov    r15,QWORD PTR [rsp+0x40]
    1613:	add    rsp,0x50
    1617:	mov    rsp,rbp
    161a:	pop    rbp
    161b:	ret
    161c:	mov    rdi,QWORD PTR [rsp]
    1620:	mov    QWORD PTR [rdi],r13
    1623:	mov    rax,r15
    1626:	mov    rbx,QWORD PTR [rsp+0x20]
    162b:	mov    r12,QWORD PTR [rsp+0x28]
    1630:	mov    r13,QWORD PTR [rsp+0x30]
    1635:	mov    r14,QWORD PTR [rsp+0x38]
    163a:	mov    r15,QWORD PTR [rsp+0x40]
    163f:	add    rsp,0x50
    1643:	mov    rsp,rbp
    1646:	pop    rbp
    1647:	ret
    1648:	mov    QWORD PTR [rsp],rdi
    164c:	call   1651 <botlish_fn_17+0x559>
			164d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1651:	xor    rax,rax
    1654:	mov    rbx,QWORD PTR [rsp+0x20]
    1659:	mov    r12,QWORD PTR [rsp+0x28]
    165e:	mov    r13,QWORD PTR [rsp+0x30]
    1663:	mov    r14,QWORD PTR [rsp+0x38]
    1668:	mov    r15,QWORD PTR [rsp+0x40]
    166d:	add    rsp,0x50
    1671:	mov    rsp,rbp
    1674:	pop    rbp
    1675:	ret
    1676:	add    BYTE PTR [rax],al
    1678:	(bad)
    1679:	add    BYTE PTR [rax],al
    167b:	add    BYTE PTR [rax],al
    167d:	add    BYTE PTR [rax],al
	...

0000000000001680 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
    1680:	push   rbp
    1681:	mov    rbp,rsp
    1684:	mov    rsi,QWORD PTR [rdx]
    1687:	mov    r9,QWORD PTR [rdx+0x8]
    168b:	mov    rcx,QWORD PTR [rdx+0x10]
    168f:	mov    r8,QWORD PTR [rdx+0x18]
    1693:	mov    rdx,r9
    1696:	call   169b <botlish_entry_17+0x1b>
			1697: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    169b:	mov    rsp,rbp
    169e:	pop    rbp
    169f:	ret

00000000000016a0 <botlish_fn_18: ht_get<mutarray, str>>:
    16a0:	push   rbp
    16a1:	mov    rbp,rsp
    16a4:	sub    rsp,0x20
    16a8:	mov    QWORD PTR [rsp],rbx
    16ac:	mov    QWORD PTR [rsp+0x8],r12
    16b1:	mov    QWORD PTR [rsp+0x10],r13
    16b6:	mov    QWORD PTR [rsp+0x18],r14
    16bb:	mov    rbx,QWORD PTR [rdi]
    16be:	mov    rax,QWORD PTR [rdi+0x8]
    16c2:	lea    rcx,[rbx+0x18]
    16c6:	cmp    rcx,rax
    16c9:	ja     1873 <botlish_fn_18+0x1d3>
    16cf:	lea    rax,[rbx+0x18]
    16d3:	mov    QWORD PTR [rdi],rax
    16d6:	mov    r12,rdi
    16d9:	mov    QWORD PTR [rbx+0x10],0x0
    16e1:	mov    QWORD PTR [rbx],rsi
    16e4:	mov    r13,rsi
    16e7:	mov    QWORD PTR [rbx+0x8],rdx
    16eb:	mov    r14,rdx
    16ee:	mov    rdx,r14
    16f1:	mov    rsi,r13
    16f4:	mov    rdi,r12
    16f7:	call   16fc <botlish_fn_18+0x5c>
			16f8: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    16fc:	test   rax,rax
    16ff:	jne    170d <botlish_fn_18+0x6d>
    1705:	mov    rdi,r12
    1708:	jmp    1805 <botlish_fn_18+0x165>
    170d:	mov    QWORD PTR [rbx+0x10],rax
    1711:	mov    rcx,rax
    1714:	mov    rdx,r14
    1717:	mov    rsi,r13
    171a:	mov    rdi,r12
    171d:	call   1722 <botlish_fn_18+0x82>
			171e: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1722:	mov    r10,rax
    1725:	mov    r14,rax
    1728:	test   rax,r10
    172b:	jne    1739 <botlish_fn_18+0x99>
    1731:	mov    rdi,r12
    1734:	jmp    1805 <botlish_fn_18+0x165>
    1739:	mov    rax,r14
    173c:	mov    QWORD PTR [rbx+0x8],rax
    1740:	test   rax,0x1
    1746:	jne    1771 <botlish_fn_18+0xd1>
    174c:	mov    edx,0x1
    1751:	mov    rsi,r14
    1754:	mov    rdi,r12
    1757:	call   175c <botlish_fn_18+0xbc>
			1758: R_X86_64_PLT32	rt_int_cmp-0x4
    175c:	mov    ecx,0x2
    1761:	test   rax,rax
    1764:	cmovl  rcx,QWORD PTR [rip+0x134]        # 18a0 <botlish_fn_18+0x200>
    176c:	jmp    1784 <botlish_fn_18+0xe4>
    1771:	mov    ecx,0x2
    1776:	mov    rax,r14
    1779:	test   rax,rax
    177c:	cmovle rcx,QWORD PTR [rip+0x11c]        # 18a0 <botlish_fn_18+0x200>
    1784:	cmp    rcx,0x6
    1788:	je     184c <botlish_fn_18+0x1ac>
    178e:	mov    rsi,r13
    1791:	mov    rdi,r12
    1794:	call   1799 <botlish_fn_18+0xf9>
			1795: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    1799:	test   rax,rax
    179c:	jne    17aa <botlish_fn_18+0x10a>
    17a2:	mov    rdi,r12
    17a5:	jmp    1805 <botlish_fn_18+0x165>
    17aa:	xor    ecx,ecx
    17ac:	test   rax,0x7
    17b2:	jne    17c3 <botlish_fn_18+0x123>
    17b8:	movzx  rcx,BYTE PTR [rax]
    17bc:	rex cmp cl,0x8
    17c0:	sete   cl
    17c3:	test   cl,cl
    17c5:	jne    17eb <botlish_fn_18+0x14b>
    17cb:	mov    rdi,r12
    17ce:	mov    rsi,QWORD PTR [rdi+0x10]
    17d2:	mov    rcx,QWORD PTR [rsi+0x8]
    17d6:	mov    edx,0x8
    17db:	mov    rsi,rax
    17de:	call   17e3 <botlish_fn_18+0x143>
			17df: R_X86_64_PLT32	rt_type_error-0x4
    17e3:	mov    rdi,r12
    17e6:	jmp    1805 <botlish_fn_18+0x165>
    17eb:	mov    rdx,r14
    17ee:	mov    rsi,rax
    17f1:	mov    rdi,r12
    17f4:	call   17f9 <botlish_fn_18+0x159>
			17f5: R_X86_64_PLT32	rt_mutarray_get-0x4
    17f9:	test   rax,rax
    17fc:	jne    182a <botlish_fn_18+0x18a>
    1802:	mov    rdi,r12
    1805:	mov    rdi,r12
    1808:	mov    QWORD PTR [rdi],rbx
    180b:	xor    rax,rax
    180e:	mov    rbx,QWORD PTR [rsp]
    1812:	mov    r12,QWORD PTR [rsp+0x8]
    1817:	mov    r13,QWORD PTR [rsp+0x10]
    181c:	mov    r14,QWORD PTR [rsp+0x18]
    1821:	add    rsp,0x20
    1825:	mov    rsp,rbp
    1828:	pop    rbp
    1829:	ret
    182a:	mov    rdi,r12
    182d:	mov    QWORD PTR [rdi],rbx
    1830:	mov    rbx,QWORD PTR [rsp]
    1834:	mov    r12,QWORD PTR [rsp+0x8]
    1839:	mov    r13,QWORD PTR [rsp+0x10]
    183e:	mov    r14,QWORD PTR [rsp+0x18]
    1843:	add    rsp,0x20
    1847:	mov    rsp,rbp
    184a:	pop    rbp
    184b:	ret
    184c:	mov    rdi,r12
    184f:	mov    QWORD PTR [rdi],rbx
    1852:	mov    eax,0xa
    1857:	mov    rbx,QWORD PTR [rsp]
    185b:	mov    r12,QWORD PTR [rsp+0x8]
    1860:	mov    r13,QWORD PTR [rsp+0x10]
    1865:	mov    r14,QWORD PTR [rsp+0x18]
    186a:	add    rsp,0x20
    186e:	mov    rsp,rbp
    1871:	pop    rbp
    1872:	ret
    1873:	mov    r12,rdi
    1876:	call   187b <botlish_fn_18+0x1db>
			1877: R_X86_64_PLT32	rt_stack_overflow-0x4
    187b:	xor    rax,rax
    187e:	mov    rbx,QWORD PTR [rsp]
    1882:	mov    r12,QWORD PTR [rsp+0x8]
    1887:	mov    r13,QWORD PTR [rsp+0x10]
    188c:	mov    r14,QWORD PTR [rsp+0x18]
    1891:	add    rsp,0x20
    1895:	mov    rsp,rbp
    1898:	pop    rbp
    1899:	ret
    189a:	add    BYTE PTR [rax],al
    189c:	add    BYTE PTR [rax],al
    189e:	add    BYTE PTR [rax],al
    18a0:	(bad)
    18a1:	add    BYTE PTR [rax],al
    18a3:	add    BYTE PTR [rax],al
    18a5:	add    BYTE PTR [rax],al
	...

00000000000018a8 <botlish_entry_18: ht_get<mutarray, str>>:
    18a8:	push   rbp
    18a9:	mov    rbp,rsp
    18ac:	mov    rsi,QWORD PTR [rdx]
    18af:	mov    rdx,QWORD PTR [rdx+0x8]
    18b3:	call   18b8 <botlish_entry_18+0x10>
			18b4: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    18b8:	mov    rsp,rbp
    18bb:	pop    rbp
    18bc:	ret
    18bd:	add    BYTE PTR [rax],al
	...

00000000000018c0 <botlish_fn_19: ht_contains<mutarray, str>>:
    18c0:	push   rbp
    18c1:	mov    rbp,rsp
    18c4:	sub    rsp,0x20
    18c8:	mov    QWORD PTR [rsp],rbx
    18cc:	mov    QWORD PTR [rsp+0x8],r12
    18d1:	mov    QWORD PTR [rsp+0x10],r13
    18d6:	mov    QWORD PTR [rsp+0x18],r14
    18db:	mov    rbx,QWORD PTR [rdi]
    18de:	mov    rax,QWORD PTR [rdi+0x8]
    18e2:	lea    rcx,[rbx+0x18]
    18e6:	cmp    rcx,rax
    18e9:	ja     19df <botlish_fn_19+0x11f>
    18ef:	lea    rax,[rbx+0x18]
    18f3:	mov    QWORD PTR [rdi],rax
    18f6:	mov    r12,rdi
    18f9:	mov    QWORD PTR [rbx+0x10],0x0
    1901:	mov    QWORD PTR [rbx],rsi
    1904:	mov    r14,rsi
    1907:	mov    QWORD PTR [rbx+0x8],rdx
    190b:	mov    r13,rdx
    190e:	mov    rdx,r13
    1911:	mov    rsi,r14
    1914:	mov    rdi,r12
    1917:	call   191c <botlish_fn_19+0x5c>
			1918: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    191c:	test   rax,rax
    191f:	jne    192d <botlish_fn_19+0x6d>
    1925:	mov    rdi,r12
    1928:	jmp    194e <botlish_fn_19+0x8e>
    192d:	mov    QWORD PTR [rbx+0x10],rax
    1931:	mov    rcx,rax
    1934:	mov    rdx,r13
    1937:	mov    rsi,r14
    193a:	mov    rdi,r12
    193d:	call   1942 <botlish_fn_19+0x82>
			193e: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1942:	test   rax,rax
    1945:	jne    1973 <botlish_fn_19+0xb3>
    194b:	mov    rdi,r12
    194e:	mov    rdi,r12
    1951:	mov    QWORD PTR [rdi],rbx
    1954:	xor    rax,rax
    1957:	mov    rbx,QWORD PTR [rsp]
    195b:	mov    r12,QWORD PTR [rsp+0x8]
    1960:	mov    r13,QWORD PTR [rsp+0x10]
    1965:	mov    r14,QWORD PTR [rsp+0x18]
    196a:	add    rsp,0x20
    196e:	mov    rsp,rbp
    1971:	pop    rbp
    1972:	ret
    1973:	test   rax,0x1
    1979:	mov    rsi,rax
    197c:	jne    19aa <botlish_fn_19+0xea>
    1982:	mov    edx,0x1
    1987:	mov    rdi,r12
    198a:	call   198f <botlish_fn_19+0xcf>
			198b: R_X86_64_PLT32	rt_int_cmp-0x4
    198f:	mov    ecx,0x2
    1994:	test   rax,rax
    1997:	mov    rax,rcx
    199a:	cmovge rax,QWORD PTR [rip+0x66]        # 1a08 <botlish_fn_19+0x148>
    19a2:	mov    rdi,r12
    19a5:	jmp    19bd <botlish_fn_19+0xfd>
    19aa:	mov    eax,0x2
    19af:	test   rsi,rsi
    19b2:	cmovg  rax,QWORD PTR [rip+0x4e]        # 1a08 <botlish_fn_19+0x148>
    19ba:	mov    rdi,r12
    19bd:	mov    rdi,r12
    19c0:	mov    QWORD PTR [rdi],rbx
    19c3:	mov    rbx,QWORD PTR [rsp]
    19c7:	mov    r12,QWORD PTR [rsp+0x8]
    19cc:	mov    r13,QWORD PTR [rsp+0x10]
    19d1:	mov    r14,QWORD PTR [rsp+0x18]
    19d6:	add    rsp,0x20
    19da:	mov    rsp,rbp
    19dd:	pop    rbp
    19de:	ret
    19df:	mov    r12,rdi
    19e2:	call   19e7 <botlish_fn_19+0x127>
			19e3: R_X86_64_PLT32	rt_stack_overflow-0x4
    19e7:	xor    rax,rax
    19ea:	mov    rbx,QWORD PTR [rsp]
    19ee:	mov    r12,QWORD PTR [rsp+0x8]
    19f3:	mov    r13,QWORD PTR [rsp+0x10]
    19f8:	mov    r14,QWORD PTR [rsp+0x18]
    19fd:	add    rsp,0x20
    1a01:	mov    rsp,rbp
    1a04:	pop    rbp
    1a05:	ret
    1a06:	add    BYTE PTR [rax],al
    1a08:	(bad)
    1a09:	add    BYTE PTR [rax],al
    1a0b:	add    BYTE PTR [rax],al
    1a0d:	add    BYTE PTR [rax],al
	...

0000000000001a10 <botlish_entry_19: ht_contains<mutarray, str>>:
    1a10:	push   rbp
    1a11:	mov    rbp,rsp
    1a14:	mov    rsi,QWORD PTR [rdx]
    1a17:	mov    rdx,QWORD PTR [rdx+0x8]
    1a1b:	call   1a20 <botlish_entry_19+0x10>
			1a1c: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    1a20:	mov    rsp,rbp
    1a23:	pop    rbp
    1a24:	ret
    1a25:	add    BYTE PTR [rax],al
	...

0000000000001a28 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    1a28:	push   rbp
    1a29:	mov    rbp,rsp
    1a2c:	sub    rsp,0x40
    1a30:	mov    QWORD PTR [rsp+0x10],rbx
    1a35:	mov    QWORD PTR [rsp+0x18],r12
    1a3a:	mov    QWORD PTR [rsp+0x20],r13
    1a3f:	mov    QWORD PTR [rsp+0x28],r14
    1a44:	mov    QWORD PTR [rsp+0x30],r15
    1a49:	mov    r12,QWORD PTR [rdi]
    1a4c:	mov    rax,QWORD PTR [rdi+0x8]
    1a50:	lea    r8,[r12+0x20]
    1a55:	cmp    r8,rax
    1a58:	ja     1bd7 <botlish_fn_20+0x1af>
    1a5e:	lea    rax,[r12+0x20]
    1a63:	mov    QWORD PTR [rdi],rax
    1a66:	mov    r13,rdi
    1a69:	mov    QWORD PTR [r12],rsi
    1a6d:	mov    QWORD PTR [r12+0x8],rdx
    1a72:	mov    QWORD PTR [r12+0x10],rcx
    1a77:	mov    r15,rcx
    1a7a:	mov    rbx,rsi
    1a7d:	mov    r14,rdx
    1a80:	mov    rdx,r14
    1a83:	mov    rsi,rbx
    1a86:	mov    rdi,r13
    1a89:	call   1a8e <botlish_fn_20+0x66>
			1a8a: R_X86_64_PLT32	rt_mutarray_get-0x4
    1a8e:	test   rax,rax
    1a91:	jne    1a9f <botlish_fn_20+0x77>
    1a97:	mov    rdi,r13
    1a9a:	jmp    1b6b <botlish_fn_20+0x143>
    1a9f:	mov    QWORD PTR [r12+0x18],rax
    1aa4:	mov    QWORD PTR [rsp],rax
    1aa8:	mov    rdi,r13
    1aab:	call   1ab0 <botlish_fn_20+0x88>
			1aac: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    1ab0:	test   rax,rax
    1ab3:	jne    1ac1 <botlish_fn_20+0x99>
    1ab9:	mov    rdi,r13
    1abc:	jmp    1b6b <botlish_fn_20+0x143>
    1ac1:	mov    rsi,QWORD PTR [rsp]
    1ac5:	mov    rcx,rsi
    1ac8:	and    rcx,rax
    1acb:	mov    rdx,rax
    1ace:	test   rcx,0x1
    1ad5:	jne    1af8 <botlish_fn_20+0xd0>
    1adb:	mov    rsi,QWORD PTR [rsp]
    1adf:	mov    rdi,r13
    1ae2:	call   1ae7 <botlish_fn_20+0xbf>
			1ae3: R_X86_64_PLT32	rt_value_eq-0x4
    1ae7:	test   rax,rax
    1aea:	jne    1b0c <botlish_fn_20+0xe4>
    1af0:	mov    rdi,r13
    1af3:	jmp    1b6b <botlish_fn_20+0x143>
    1af8:	mov    rsi,QWORD PTR [rsp]
    1afc:	mov    eax,0x2
    1b01:	cmp    rsi,rdx
    1b04:	cmove  rax,QWORD PTR [rip+0xfc]        # 1c08 <botlish_fn_20+0x1e0>
    1b0c:	cmp    rax,0x6
    1b10:	je     1bac <botlish_fn_20+0x184>
    1b16:	mov    QWORD PTR [r12+0x18],0x3
    1b1f:	mov    rsi,r14
    1b22:	test   rsi,0x1
    1b29:	je     1b41 <botlish_fn_20+0x119>
    1b2f:	mov    rsi,r14
    1b32:	add    rsi,0x2
    1b36:	seto   al
    1b39:	test   al,al
    1b3b:	je     1b54 <botlish_fn_20+0x12c>
    1b41:	mov    edx,0x3
    1b46:	mov    rsi,r14
    1b49:	mov    rdi,r13
    1b4c:	call   1b51 <botlish_fn_20+0x129>
			1b4d: R_X86_64_PLT32	rt_int_add-0x4
    1b51:	mov    rsi,rax
    1b54:	mov    rdx,r15
    1b57:	mov    rdi,r13
    1b5a:	call   1b5f <botlish_fn_20+0x137>
			1b5b: R_X86_64_PLT32	rt_int_mod-0x4
    1b5f:	test   rax,rax
    1b62:	jne    1b96 <botlish_fn_20+0x16e>
    1b68:	mov    rdi,r13
    1b6b:	mov    rdi,r13
    1b6e:	mov    QWORD PTR [rdi],r12
    1b71:	xor    rax,rax
    1b74:	mov    rbx,QWORD PTR [rsp+0x10]
    1b79:	mov    r12,QWORD PTR [rsp+0x18]
    1b7e:	mov    r13,QWORD PTR [rsp+0x20]
    1b83:	mov    r14,QWORD PTR [rsp+0x28]
    1b88:	mov    r15,QWORD PTR [rsp+0x30]
    1b8d:	add    rsp,0x40
    1b91:	mov    rsp,rbp
    1b94:	pop    rbp
    1b95:	ret
    1b96:	mov    QWORD PTR [r12],rbx
    1b9a:	mov    QWORD PTR [r12+0x8],rax
    1b9f:	mov    QWORD PTR [r12+0x10],r15
    1ba4:	mov    r14,rax
    1ba7:	jmp    1a80 <botlish_fn_20+0x58>
    1bac:	mov    rdi,r13
    1baf:	mov    QWORD PTR [rdi],r12
    1bb2:	mov    rax,r14
    1bb5:	mov    rbx,QWORD PTR [rsp+0x10]
    1bba:	mov    r12,QWORD PTR [rsp+0x18]
    1bbf:	mov    r13,QWORD PTR [rsp+0x20]
    1bc4:	mov    r14,QWORD PTR [rsp+0x28]
    1bc9:	mov    r15,QWORD PTR [rsp+0x30]
    1bce:	add    rsp,0x40
    1bd2:	mov    rsp,rbp
    1bd5:	pop    rbp
    1bd6:	ret
    1bd7:	mov    r13,rdi
    1bda:	call   1bdf <botlish_fn_20+0x1b7>
			1bdb: R_X86_64_PLT32	rt_stack_overflow-0x4
    1bdf:	xor    rax,rax
    1be2:	mov    rbx,QWORD PTR [rsp+0x10]
    1be7:	mov    r12,QWORD PTR [rsp+0x18]
    1bec:	mov    r13,QWORD PTR [rsp+0x20]
    1bf1:	mov    r14,QWORD PTR [rsp+0x28]
    1bf6:	mov    r15,QWORD PTR [rsp+0x30]
    1bfb:	add    rsp,0x40
    1bff:	mov    rsp,rbp
    1c02:	pop    rbp
    1c03:	ret
    1c04:	add    BYTE PTR [rax],al
    1c06:	add    BYTE PTR [rax],al
    1c08:	(bad)
    1c09:	add    BYTE PTR [rax],al
    1c0b:	add    BYTE PTR [rax],al
    1c0d:	add    BYTE PTR [rax],al
	...

0000000000001c10 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    1c10:	push   rbp
    1c11:	mov    rbp,rsp
    1c14:	mov    rsi,QWORD PTR [rdx]
    1c17:	mov    r8,QWORD PTR [rdx+0x8]
    1c1b:	mov    rcx,QWORD PTR [rdx+0x10]
    1c1f:	mov    rdx,r8
    1c22:	call   1c27 <botlish_entry_20+0x17>
			1c23: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1c27:	mov    rsp,rbp
    1c2a:	pop    rbp
    1c2b:	ret

0000000000001c2c <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1c2c:	push   rbp
    1c2d:	mov    rbp,rsp
    1c30:	sub    rsp,0x50
    1c34:	mov    QWORD PTR [rsp+0x20],rbx
    1c39:	mov    QWORD PTR [rsp+0x28],r12
    1c3e:	mov    QWORD PTR [rsp+0x30],r13
    1c43:	mov    QWORD PTR [rsp+0x38],r14
    1c48:	mov    QWORD PTR [rsp+0x40],r15
    1c4d:	mov    r10,QWORD PTR [rbp+0x10]
    1c51:	mov    rbx,QWORD PTR [rdi]
    1c54:	mov    rax,QWORD PTR [rdi+0x8]
    1c58:	lea    r11,[rbx+0x38]
    1c5c:	cmp    r11,rax
    1c5f:	ja     1de7 <botlish_fn_21+0x1bb>
    1c65:	lea    rax,[rbx+0x38]
    1c69:	mov    QWORD PTR [rdi],rax
    1c6c:	mov    r12,rdi
    1c6f:	mov    QWORD PTR [rbx],rsi
    1c72:	mov    QWORD PTR [rsp],rsi
    1c76:	mov    QWORD PTR [rbx+0x8],rdx
    1c7a:	mov    QWORD PTR [rsp+0x8],rdx
    1c7f:	mov    QWORD PTR [rbx+0x10],rcx
    1c83:	mov    r13,rcx
    1c86:	mov    QWORD PTR [rbx+0x18],r8
    1c8a:	mov    QWORD PTR [rsp+0x10],r8
    1c8f:	mov    QWORD PTR [rbx+0x20],r9
    1c93:	mov    r15,r9
    1c96:	mov    QWORD PTR [rbx+0x28],r10
    1c9a:	mov    r14,r10
    1c9d:	mov    rsi,r15
    1ca0:	mov    rdi,r12
    1ca3:	call   1ca8 <botlish_fn_21+0x7c>
			1ca4: R_X86_64_PLT32	rt_hash-0x4
    1ca8:	test   rax,rax
    1cab:	mov    rsi,rax
    1cae:	jne    1cbc <botlish_fn_21+0x90>
    1cb4:	mov    rdi,r12
    1cb7:	jmp    1d8f <botlish_fn_21+0x163>
    1cbc:	mov    rdx,QWORD PTR [rsp+0x10]
    1cc1:	mov    rdi,r12
    1cc4:	call   1cc9 <botlish_fn_21+0x9d>
			1cc5: R_X86_64_PLT32	rt_int_mod-0x4
    1cc9:	test   rax,rax
    1ccc:	jne    1cda <botlish_fn_21+0xae>
    1cd2:	mov    rdi,r12
    1cd5:	jmp    1d8f <botlish_fn_21+0x163>
    1cda:	mov    QWORD PTR [rbx+0x30],rax
    1cde:	mov    rcx,QWORD PTR [rsp+0x10]
    1ce3:	mov    rdx,rax
    1ce6:	mov    rsi,QWORD PTR [rsp]
    1cea:	mov    rdi,r12
    1ced:	call   1cf2 <botlish_fn_21+0xc6>
			1cee: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1cf2:	test   rax,rax
    1cf5:	jne    1d03 <botlish_fn_21+0xd7>
    1cfb:	mov    rdi,r12
    1cfe:	jmp    1d8f <botlish_fn_21+0x163>
    1d03:	mov    QWORD PTR [rbx+0x18],rax
    1d07:	mov    QWORD PTR [rsp+0x10],rax
    1d0c:	mov    rdi,r12
    1d0f:	call   1d14 <botlish_fn_21+0xe8>
			1d10: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1d14:	test   rax,rax
    1d17:	mov    rcx,rax
    1d1a:	jne    1d28 <botlish_fn_21+0xfc>
    1d20:	mov    rdi,r12
    1d23:	jmp    1d8f <botlish_fn_21+0x163>
    1d28:	mov    rsi,QWORD PTR [rsp]
    1d2c:	mov    rdx,QWORD PTR [rsp+0x10]
    1d31:	mov    rdi,r12
    1d34:	call   1d39 <botlish_fn_21+0x10d>
			1d35: R_X86_64_PLT32	rt_mutarray_set-0x4
    1d39:	test   rax,rax
    1d3c:	jne    1d4a <botlish_fn_21+0x11e>
    1d42:	mov    rdi,r12
    1d45:	jmp    1d8f <botlish_fn_21+0x163>
    1d4a:	mov    rcx,r15
    1d4d:	mov    rsi,QWORD PTR [rsp+0x8]
    1d52:	mov    rdx,QWORD PTR [rsp+0x10]
    1d57:	mov    rdi,r12
    1d5a:	call   1d5f <botlish_fn_21+0x133>
			1d5b: R_X86_64_PLT32	rt_mutarray_set-0x4
    1d5f:	test   rax,rax
    1d62:	jne    1d70 <botlish_fn_21+0x144>
    1d68:	mov    rdi,r12
    1d6b:	jmp    1d8f <botlish_fn_21+0x163>
    1d70:	mov    rcx,r14
    1d73:	mov    rdx,QWORD PTR [rsp+0x10]
    1d78:	mov    rsi,r13
    1d7b:	mov    rdi,r12
    1d7e:	call   1d83 <botlish_fn_21+0x157>
			1d7f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1d83:	test   rax,rax
    1d86:	jne    1dba <botlish_fn_21+0x18e>
    1d8c:	mov    rdi,r12
    1d8f:	mov    rdi,r12
    1d92:	mov    QWORD PTR [rdi],rbx
    1d95:	xor    rax,rax
    1d98:	mov    rbx,QWORD PTR [rsp+0x20]
    1d9d:	mov    r12,QWORD PTR [rsp+0x28]
    1da2:	mov    r13,QWORD PTR [rsp+0x30]
    1da7:	mov    r14,QWORD PTR [rsp+0x38]
    1dac:	mov    r15,QWORD PTR [rsp+0x40]
    1db1:	add    rsp,0x50
    1db5:	mov    rsp,rbp
    1db8:	pop    rbp
    1db9:	ret
    1dba:	mov    rdi,r12
    1dbd:	mov    QWORD PTR [rdi],rbx
    1dc0:	mov    eax,0xa
    1dc5:	mov    rbx,QWORD PTR [rsp+0x20]
    1dca:	mov    r12,QWORD PTR [rsp+0x28]
    1dcf:	mov    r13,QWORD PTR [rsp+0x30]
    1dd4:	mov    r14,QWORD PTR [rsp+0x38]
    1dd9:	mov    r15,QWORD PTR [rsp+0x40]
    1dde:	add    rsp,0x50
    1de2:	mov    rsp,rbp
    1de5:	pop    rbp
    1de6:	ret
    1de7:	mov    r12,rdi
    1dea:	call   1def <botlish_fn_21+0x1c3>
			1deb: R_X86_64_PLT32	rt_stack_overflow-0x4
    1def:	xor    rax,rax
    1df2:	mov    rbx,QWORD PTR [rsp+0x20]
    1df7:	mov    r12,QWORD PTR [rsp+0x28]
    1dfc:	mov    r13,QWORD PTR [rsp+0x30]
    1e01:	mov    r14,QWORD PTR [rsp+0x38]
    1e06:	mov    r15,QWORD PTR [rsp+0x40]
    1e0b:	add    rsp,0x50
    1e0f:	mov    rsp,rbp
    1e12:	pop    rbp
    1e13:	ret

0000000000001e14 <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1e14:	push   rbp
    1e15:	mov    rbp,rsp
    1e18:	sub    rsp,0x10
    1e1c:	mov    rsi,QWORD PTR [rdx]
    1e1f:	mov    r10,QWORD PTR [rdx+0x8]
    1e23:	mov    rcx,QWORD PTR [rdx+0x10]
    1e27:	mov    r8,QWORD PTR [rdx+0x18]
    1e2b:	mov    r9,QWORD PTR [rdx+0x20]
    1e2f:	mov    r11,QWORD PTR [rdx+0x28]
    1e33:	mov    QWORD PTR [rsp],r11
    1e37:	mov    rdx,r10
    1e3a:	call   1e3f <botlish_entry_21+0x2b>
			1e3b: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    1e3f:	add    rsp,0x10
    1e43:	mov    rsp,rbp
    1e46:	pop    rbp
    1e47:	ret

0000000000001e48 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1e48:	push   rbp
    1e49:	mov    rbp,rsp
    1e4c:	sub    rsp,0x80
    1e53:	mov    QWORD PTR [rsp+0x50],rbx
    1e58:	mov    QWORD PTR [rsp+0x58],r12
    1e5d:	mov    QWORD PTR [rsp+0x60],r13
    1e62:	mov    QWORD PTR [rsp+0x68],r14
    1e67:	mov    QWORD PTR [rsp+0x70],r15
    1e6c:	mov    r13,QWORD PTR [rbp+0x10]
    1e70:	mov    r14,QWORD PTR [rbp+0x18]
    1e74:	mov    r15,QWORD PTR [rbp+0x20]
    1e78:	mov    r12,QWORD PTR [rbp+0x28]
    1e7c:	mov    QWORD PTR [rsp+0x38],r12
    1e81:	mov    r12,QWORD PTR [rdi]
    1e84:	mov    r11,QWORD PTR [rdi+0x8]
    1e88:	lea    rax,[r12+0x58]
    1e8d:	cmp    rax,r11
    1e90:	ja     22ae <botlish_fn_22+0x466>
    1e96:	lea    rax,[r12+0x58]
    1e9b:	mov    QWORD PTR [rdi],rax
    1e9e:	mov    QWORD PTR [rsp+0x10],rdi
    1ea3:	mov    QWORD PTR [r12+0x50],0x0
    1eac:	mov    QWORD PTR [r12],rsi
    1eb0:	mov    QWORD PTR [rsp+0x18],rsi
    1eb5:	mov    QWORD PTR [r12+0x8],rdx
    1eba:	mov    QWORD PTR [rsp+0x20],rdx
    1ebf:	mov    QWORD PTR [r12+0x10],rcx
    1ec4:	mov    QWORD PTR [rsp+0x28],rcx
    1ec9:	mov    QWORD PTR [r12+0x18],r8
    1ece:	mov    QWORD PTR [r12+0x20],r9
    1ed3:	mov    QWORD PTR [rsp+0x30],r9
    1ed8:	mov    QWORD PTR [r12+0x28],r13
    1edd:	mov    QWORD PTR [r12+0x30],r14
    1ee2:	mov    QWORD PTR [r12+0x38],r15
    1ee7:	mov    rax,QWORD PTR [rsp+0x38]
    1eec:	mov    QWORD PTR [r12+0x40],rax
    1ef1:	mov    rbx,QWORD PTR [rsp+0x30]
    1ef6:	mov    rsi,r8
    1ef9:	mov    rax,rsi
    1efc:	and    rax,rbx
    1eff:	mov    QWORD PTR [rsp+0x40],rsi
    1f04:	test   rax,0x1
    1f0a:	jne    1f3c <botlish_fn_22+0xf4>
    1f10:	mov    rdx,rbx
    1f13:	mov    rsi,QWORD PTR [rsp+0x40]
    1f18:	mov    rdi,QWORD PTR [rsp+0x10]
    1f1d:	call   1f22 <botlish_fn_22+0xda>
			1f1e: R_X86_64_PLT32	rt_int_cmp-0x4
    1f22:	mov    QWORD PTR [rsp+0x30],rbx
    1f27:	mov    ecx,0x2
    1f2c:	test   rax,rax
    1f2f:	cmovge rcx,QWORD PTR [rip+0x3a9]        # 22e0 <botlish_fn_22+0x498>
    1f37:	jmp    1f5b <botlish_fn_22+0x113>
    1f3c:	mov    QWORD PTR [rsp+0x30],rbx
    1f41:	mov    ecx,0x2
    1f46:	mov    rsi,QWORD PTR [rsp+0x40]
    1f4b:	mov    r9,QWORD PTR [rsp+0x30]
    1f50:	cmp    rsi,r9
    1f53:	cmovge rcx,QWORD PTR [rip+0x385]        # 22e0 <botlish_fn_22+0x498>
    1f5b:	cmp    rcx,0x6
    1f5f:	je     227c <botlish_fn_22+0x434>
    1f65:	xor    eax,eax
    1f67:	mov    rsi,QWORD PTR [rsp+0x18]
    1f6c:	test   rsi,0x7
    1f73:	jne    1f82 <botlish_fn_22+0x13a>
    1f79:	movzx  rax,BYTE PTR [rsi]
    1f7d:	cmp    al,0x8
    1f7f:	sete   al
    1f82:	test   al,al
    1f84:	jne    1fab <botlish_fn_22+0x163>
    1f8a:	mov    rdi,QWORD PTR [rsp+0x10]
    1f8f:	mov    rax,QWORD PTR [rdi+0x10]
    1f93:	mov    rcx,QWORD PTR [rax+0x8]
    1f97:	mov    edx,0x8
    1f9c:	call   1fa1 <botlish_fn_22+0x159>
			1f9d: R_X86_64_PLT32	rt_type_error-0x4
    1fa1:	mov    rdi,QWORD PTR [rsp+0x10]
    1fa6:	jmp    2199 <botlish_fn_22+0x351>
    1fab:	mov    QWORD PTR [rsp+0x18],rsi
    1fb0:	mov    rdx,QWORD PTR [rsp+0x40]
    1fb5:	mov    rdi,QWORD PTR [rsp+0x10]
    1fba:	call   1fbf <botlish_fn_22+0x177>
			1fbb: R_X86_64_PLT32	rt_mutarray_get-0x4
    1fbf:	test   rax,rax
    1fc2:	jne    1fd2 <botlish_fn_22+0x18a>
    1fc8:	mov    rdi,QWORD PTR [rsp+0x10]
    1fcd:	jmp    2199 <botlish_fn_22+0x351>
    1fd2:	mov    QWORD PTR [r12+0x48],rax
    1fd7:	mov    rbx,rax
    1fda:	mov    rdi,QWORD PTR [rsp+0x10]
    1fdf:	call   1fe4 <botlish_fn_22+0x19c>
			1fe0: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1fe4:	test   rax,rax
    1fe7:	jne    1ff7 <botlish_fn_22+0x1af>
    1fed:	mov    rdi,QWORD PTR [rsp+0x10]
    1ff2:	jmp    2199 <botlish_fn_22+0x351>
    1ff7:	mov    rcx,rbx
    1ffa:	mov    rdx,rcx
    1ffd:	and    rdx,rax
    2000:	test   rdx,0x1
    2007:	jne    2030 <botlish_fn_22+0x1e8>
    200d:	mov    rdx,rax
    2010:	mov    rsi,rbx
    2013:	mov    rdi,QWORD PTR [rsp+0x10]
    2018:	call   201d <botlish_fn_22+0x1d5>
			2019: R_X86_64_PLT32	rt_value_eq-0x4
    201d:	test   rax,rax
    2020:	jne    2046 <botlish_fn_22+0x1fe>
    2026:	mov    rdi,QWORD PTR [rsp+0x10]
    202b:	jmp    2199 <botlish_fn_22+0x351>
    2030:	mov    rdx,rax
    2033:	mov    rsi,rbx
    2036:	mov    eax,0x2
    203b:	cmp    rsi,rdx
    203e:	cmove  rax,QWORD PTR [rip+0x29a]        # 22e0 <botlish_fn_22+0x498>
    2046:	cmp    rax,0x6
    204a:	je     205a <botlish_fn_22+0x212>
    2050:	mov    rbx,QWORD PTR [rsp+0x38]
    2055:	jmp    21c9 <botlish_fn_22+0x381>
    205a:	xor    eax,eax
    205c:	mov    rdx,QWORD PTR [rsp+0x20]
    2061:	test   rdx,0x7
    2068:	je     2078 <botlish_fn_22+0x230>
    206e:	mov    QWORD PTR [rsp+0x20],rdx
    2073:	jmp    2086 <botlish_fn_22+0x23e>
    2078:	movzx  rax,BYTE PTR [rdx]
    207c:	mov    QWORD PTR [rsp+0x20],rdx
    2081:	cmp    al,0x8
    2083:	sete   al
    2086:	test   al,al
    2088:	jne    20b4 <botlish_fn_22+0x26c>
    208e:	mov    rdi,QWORD PTR [rsp+0x10]
    2093:	mov    rsi,QWORD PTR [rdi+0x10]
    2097:	mov    rcx,QWORD PTR [rsi+0x8]
    209b:	mov    edx,0x8
    20a0:	mov    rsi,QWORD PTR [rsp+0x20]
    20a5:	call   20aa <botlish_fn_22+0x262>
			20a6: R_X86_64_PLT32	rt_type_error-0x4
    20aa:	mov    rdi,QWORD PTR [rsp+0x10]
    20af:	jmp    2199 <botlish_fn_22+0x351>
    20b4:	mov    rdx,QWORD PTR [rsp+0x40]
    20b9:	mov    rsi,QWORD PTR [rsp+0x20]
    20be:	mov    rdi,QWORD PTR [rsp+0x10]
    20c3:	call   20c8 <botlish_fn_22+0x280>
			20c4: R_X86_64_PLT32	rt_mutarray_get-0x4
    20c8:	test   rax,rax
    20cb:	jne    20db <botlish_fn_22+0x293>
    20d1:	mov    rdi,QWORD PTR [rsp+0x10]
    20d6:	jmp    2199 <botlish_fn_22+0x351>
    20db:	mov    QWORD PTR [r12+0x48],rax
    20e0:	mov    rbx,rax
    20e3:	xor    eax,eax
    20e5:	mov    rcx,QWORD PTR [rsp+0x28]
    20ea:	test   rcx,0x7
    20f1:	je     2101 <botlish_fn_22+0x2b9>
    20f7:	mov    QWORD PTR [rsp+0x28],rcx
    20fc:	jmp    210f <botlish_fn_22+0x2c7>
    2101:	movzx  rax,BYTE PTR [rcx]
    2105:	mov    QWORD PTR [rsp+0x28],rcx
    210a:	cmp    al,0x8
    210c:	sete   al
    210f:	test   al,al
    2111:	jne    213d <botlish_fn_22+0x2f5>
    2117:	mov    rdi,QWORD PTR [rsp+0x10]
    211c:	mov    rax,QWORD PTR [rdi+0x10]
    2120:	mov    rcx,QWORD PTR [rax+0x8]
    2124:	mov    edx,0x8
    2129:	mov    rsi,QWORD PTR [rsp+0x28]
    212e:	call   2133 <botlish_fn_22+0x2eb>
			212f: R_X86_64_PLT32	rt_type_error-0x4
    2133:	mov    rdi,QWORD PTR [rsp+0x10]
    2138:	jmp    2199 <botlish_fn_22+0x351>
    213d:	mov    rdx,QWORD PTR [rsp+0x40]
    2142:	mov    rsi,QWORD PTR [rsp+0x28]
    2147:	mov    rdi,QWORD PTR [rsp+0x10]
    214c:	call   2151 <botlish_fn_22+0x309>
			214d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2151:	test   rax,rax
    2154:	jne    2164 <botlish_fn_22+0x31c>
    215a:	mov    rdi,QWORD PTR [rsp+0x10]
    215f:	jmp    2199 <botlish_fn_22+0x351>
    2164:	mov    QWORD PTR [r12+0x50],rax
    2169:	mov    QWORD PTR [rsp],rax
    216d:	mov    r9,rbx
    2170:	mov    rbx,QWORD PTR [rsp+0x38]
    2175:	mov    rcx,r15
    2178:	mov    rdx,r14
    217b:	mov    rsi,r13
    217e:	mov    rdi,QWORD PTR [rsp+0x10]
    2183:	mov    r8,rbx
    2186:	call   218b <botlish_fn_22+0x343>
			2187: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    218b:	test   rax,rax
    218e:	jne    21c9 <botlish_fn_22+0x381>
    2194:	mov    rdi,QWORD PTR [rsp+0x10]
    2199:	mov    rdi,QWORD PTR [rsp+0x10]
    219e:	mov    QWORD PTR [rdi],r12
    21a1:	xor    rax,rax
    21a4:	mov    rbx,QWORD PTR [rsp+0x50]
    21a9:	mov    r12,QWORD PTR [rsp+0x58]
    21ae:	mov    r13,QWORD PTR [rsp+0x60]
    21b3:	mov    r14,QWORD PTR [rsp+0x68]
    21b8:	mov    r15,QWORD PTR [rsp+0x70]
    21bd:	add    rsp,0x80
    21c4:	mov    rsp,rbp
    21c7:	pop    rbp
    21c8:	ret
    21c9:	mov    QWORD PTR [r12+0x48],0x3
    21d2:	mov    rsi,QWORD PTR [rsp+0x40]
    21d7:	test   rsi,0x1
    21de:	je     220a <botlish_fn_22+0x3c2>
    21e4:	mov    rsi,QWORD PTR [rsp+0x40]
    21e9:	mov    rcx,rsi
    21ec:	add    rcx,0x2
    21f0:	seto   al
    21f3:	test   al,al
    21f5:	jne    220a <botlish_fn_22+0x3c2>
    21fb:	mov    rsi,QWORD PTR [rsp+0x18]
    2200:	mov    QWORD PTR [rsp+0x40],rcx
    2205:	jmp    2228 <botlish_fn_22+0x3e0>
    220a:	mov    edx,0x3
    220f:	mov    rsi,QWORD PTR [rsp+0x40]
    2214:	mov    rdi,QWORD PTR [rsp+0x10]
    2219:	call   221e <botlish_fn_22+0x3d6>
			221a: R_X86_64_PLT32	rt_int_add-0x4
    221e:	mov    rsi,QWORD PTR [rsp+0x18]
    2223:	mov    QWORD PTR [rsp+0x40],rax
    2228:	mov    rsi,QWORD PTR [rsp+0x18]
    222d:	mov    QWORD PTR [r12],rsi
    2231:	mov    rsi,QWORD PTR [rsp+0x20]
    2236:	mov    QWORD PTR [r12+0x8],rsi
    223b:	mov    rsi,QWORD PTR [rsp+0x28]
    2240:	mov    QWORD PTR [r12+0x10],rsi
    2245:	mov    rsi,QWORD PTR [rsp+0x40]
    224a:	mov    QWORD PTR [r12+0x18],rsi
    224f:	mov    r9,QWORD PTR [rsp+0x30]
    2254:	mov    QWORD PTR [r12+0x20],r9
    2259:	mov    QWORD PTR [r12+0x28],r13
    225e:	mov    QWORD PTR [r12+0x30],r14
    2263:	mov    QWORD PTR [r12+0x38],r15
    2268:	mov    QWORD PTR [r12+0x40],rbx
    226d:	mov    QWORD PTR [rsp+0x38],rbx
    2272:	mov    rbx,QWORD PTR [rsp+0x30]
    2277:	jmp    1ef9 <botlish_fn_22+0xb1>
    227c:	mov    rdi,QWORD PTR [rsp+0x10]
    2281:	mov    QWORD PTR [rdi],r12
    2284:	mov    eax,0xa
    2289:	mov    rbx,QWORD PTR [rsp+0x50]
    228e:	mov    r12,QWORD PTR [rsp+0x58]
    2293:	mov    r13,QWORD PTR [rsp+0x60]
    2298:	mov    r14,QWORD PTR [rsp+0x68]
    229d:	mov    r15,QWORD PTR [rsp+0x70]
    22a2:	add    rsp,0x80
    22a9:	mov    rsp,rbp
    22ac:	pop    rbp
    22ad:	ret
    22ae:	mov    QWORD PTR [rsp+0x10],rdi
    22b3:	call   22b8 <botlish_fn_22+0x470>
			22b4: R_X86_64_PLT32	rt_stack_overflow-0x4
    22b8:	xor    rax,rax
    22bb:	mov    rbx,QWORD PTR [rsp+0x50]
    22c0:	mov    r12,QWORD PTR [rsp+0x58]
    22c5:	mov    r13,QWORD PTR [rsp+0x60]
    22ca:	mov    r14,QWORD PTR [rsp+0x68]
    22cf:	mov    r15,QWORD PTR [rsp+0x70]
    22d4:	add    rsp,0x80
    22db:	mov    rsp,rbp
    22de:	pop    rbp
    22df:	ret
    22e0:	(bad)
    22e1:	add    BYTE PTR [rax],al
    22e3:	add    BYTE PTR [rax],al
    22e5:	add    BYTE PTR [rax],al
	...

00000000000022e8 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    22e8:	push   rbp
    22e9:	mov    rbp,rsp
    22ec:	sub    rsp,0x30
    22f0:	mov    QWORD PTR [rsp+0x20],r12
    22f5:	mov    rsi,QWORD PTR [rdx]
    22f8:	mov    rax,QWORD PTR [rdx+0x8]
    22fc:	mov    rcx,QWORD PTR [rdx+0x10]
    2300:	mov    r8,QWORD PTR [rdx+0x18]
    2304:	mov    r9,QWORD PTR [rdx+0x20]
    2308:	mov    r10,QWORD PTR [rdx+0x28]
    230c:	mov    r11,QWORD PTR [rdx+0x30]
    2310:	mov    r12,QWORD PTR [rdx+0x38]
    2314:	mov    rdx,QWORD PTR [rdx+0x40]
    2318:	mov    QWORD PTR [rsp],r10
    231c:	mov    QWORD PTR [rsp+0x8],r11
    2321:	mov    QWORD PTR [rsp+0x10],r12
    2326:	mov    QWORD PTR [rsp+0x18],rdx
    232b:	mov    rdx,rax
    232e:	call   2333 <botlish_entry_22+0x4b>
			232f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    2333:	mov    r12,QWORD PTR [rsp+0x20]
    2338:	add    rsp,0x30
    233c:	mov    rsp,rbp
    233f:	pop    rbp
    2340:	ret

0000000000002341 <botlish_fn_23: ht_rehash<mutarray, int>>:
    2341:	push   rbp
    2342:	mov    rbp,rsp
    2345:	sub    rsp,0x80
    234c:	mov    QWORD PTR [rsp+0x50],rbx
    2351:	mov    QWORD PTR [rsp+0x58],r12
    2356:	mov    QWORD PTR [rsp+0x60],r13
    235b:	mov    QWORD PTR [rsp+0x68],r14
    2360:	mov    QWORD PTR [rsp+0x70],r15
    2365:	mov    r12,QWORD PTR [rdi]
    2368:	mov    rax,QWORD PTR [rdi+0x8]
    236c:	lea    rcx,[r12+0x50]
    2371:	cmp    rcx,rax
    2374:	ja     2663 <botlish_fn_23+0x322>
    237a:	lea    rax,[r12+0x50]
    237f:	mov    QWORD PTR [rdi],rax
    2382:	mov    r13,rdi
    2385:	mov    QWORD PTR [r12+0x10],0x0
    238e:	mov    QWORD PTR [r12+0x18],0x0
    2397:	mov    QWORD PTR [r12+0x20],0x0
    23a0:	mov    QWORD PTR [r12+0x28],0x0
    23a9:	mov    QWORD PTR [r12+0x30],0x0
    23b2:	mov    QWORD PTR [r12+0x38],0x0
    23bb:	mov    QWORD PTR [r12+0x40],0x0
    23c4:	mov    QWORD PTR [r12+0x48],0x0
    23cd:	mov    QWORD PTR [r12],rsi
    23d1:	mov    r14,rsi
    23d4:	mov    QWORD PTR [r12+0x8],rdx
    23d9:	mov    rbx,rdx
    23dc:	mov    rsi,r14
    23df:	mov    rdi,r13
    23e2:	call   23e7 <botlish_fn_23+0xa6>
			23e3: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    23e7:	test   rax,rax
    23ea:	jne    23f8 <botlish_fn_23+0xb7>
    23f0:	mov    rdi,r13
    23f3:	jmp    2605 <botlish_fn_23+0x2c4>
    23f8:	mov    QWORD PTR [r12+0x10],rax
    23fd:	mov    r15,rax
    2400:	mov    rsi,r14
    2403:	mov    rdi,r13
    2406:	call   240b <botlish_fn_23+0xca>
			2407: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    240b:	test   rax,rax
    240e:	jne    241c <botlish_fn_23+0xdb>
    2414:	mov    rdi,r13
    2417:	jmp    2605 <botlish_fn_23+0x2c4>
    241c:	mov    QWORD PTR [r12+0x18],rax
    2421:	mov    QWORD PTR [rsp+0x48],rax
    2426:	mov    rsi,r14
    2429:	mov    rdi,r13
    242c:	call   2431 <botlish_fn_23+0xf0>
			242d: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2431:	test   rax,rax
    2434:	jne    2442 <botlish_fn_23+0x101>
    243a:	mov    rdi,r13
    243d:	jmp    2605 <botlish_fn_23+0x2c4>
    2442:	mov    QWORD PTR [r12+0x20],rax
    2447:	mov    QWORD PTR [rsp+0x40],rax
    244c:	mov    rsi,r14
    244f:	mov    rdi,r13
    2452:	call   2457 <botlish_fn_23+0x116>
			2453: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2457:	test   rax,rax
    245a:	jne    2468 <botlish_fn_23+0x127>
    2460:	mov    rdi,r13
    2463:	jmp    2605 <botlish_fn_23+0x2c4>
    2468:	mov    QWORD PTR [r12+0x28],rax
    246d:	mov    QWORD PTR [rsp+0x38],rax
    2472:	mov    rsi,rbx
    2475:	mov    rdi,r13
    2478:	call   247d <botlish_fn_23+0x13c>
			2479: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    247d:	mov    rcx,rax
    2480:	mov    QWORD PTR [rsp+0x30],rax
    2485:	test   rax,rcx
    2488:	jne    2496 <botlish_fn_23+0x155>
    248e:	mov    rdi,r13
    2491:	jmp    2605 <botlish_fn_23+0x2c4>
    2496:	mov    rax,QWORD PTR [rsp+0x30]
    249b:	mov    QWORD PTR [r12+0x30],rax
    24a0:	mov    edx,0x1
    24a5:	mov    QWORD PTR [r12+0x38],0x1
    24ae:	mov    rcx,rbx
    24b1:	mov    rsi,QWORD PTR [rsp+0x30]
    24b6:	mov    rdi,r13
    24b9:	call   24be <botlish_fn_23+0x17d>
			24ba: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    24be:	test   rax,rax
    24c1:	jne    24cf <botlish_fn_23+0x18e>
    24c7:	mov    rdi,r13
    24ca:	jmp    2605 <botlish_fn_23+0x2c4>
    24cf:	mov    rsi,rbx
    24d2:	mov    rdi,r13
    24d5:	call   24da <botlish_fn_23+0x199>
			24d6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    24da:	test   rax,rax
    24dd:	jne    24eb <botlish_fn_23+0x1aa>
    24e3:	mov    rdi,r13
    24e6:	jmp    2605 <botlish_fn_23+0x2c4>
    24eb:	mov    QWORD PTR [r12+0x38],rax
    24f0:	mov    QWORD PTR [rsp+0x28],rax
    24f5:	mov    rsi,rbx
    24f8:	mov    rdi,r13
    24fb:	call   2500 <botlish_fn_23+0x1bf>
			24fc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2500:	test   rax,rax
    2503:	jne    2511 <botlish_fn_23+0x1d0>
    2509:	mov    rdi,r13
    250c:	jmp    2605 <botlish_fn_23+0x2c4>
    2511:	mov    QWORD PTR [r12+0x40],rax
    2516:	mov    r8d,0x1
    251c:	mov    QWORD PTR [r12+0x48],0x1
    2525:	mov    rcx,QWORD PTR [rsp+0x30]
    252a:	mov    QWORD PTR [rsp],rcx
    252e:	mov    rcx,QWORD PTR [rsp+0x28]
    2533:	mov    QWORD PTR [rsp+0x8],rcx
    2538:	mov    QWORD PTR [rsp+0x10],rax
    253d:	mov    QWORD PTR [rsp+0x20],rax
    2542:	mov    QWORD PTR [rsp+0x18],rbx
    2547:	mov    rcx,QWORD PTR [rsp+0x40]
    254c:	mov    rdx,QWORD PTR [rsp+0x48]
    2551:	mov    rsi,r15
    2554:	mov    r9,QWORD PTR [rsp+0x38]
    2559:	mov    rdi,r13
    255c:	call   2561 <botlish_fn_23+0x220>
			255d: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    2561:	test   rax,rax
    2564:	jne    2572 <botlish_fn_23+0x231>
    256a:	mov    rdi,r13
    256d:	jmp    2605 <botlish_fn_23+0x2c4>
    2572:	mov    edx,0x1
    2577:	mov    rcx,QWORD PTR [rsp+0x30]
    257c:	mov    rsi,r14
    257f:	mov    rdi,r13
    2582:	call   2587 <botlish_fn_23+0x246>
			2583: R_X86_64_PLT32	rt_mutarray_set-0x4
    2587:	test   rax,rax
    258a:	jne    2598 <botlish_fn_23+0x257>
    2590:	mov    rdi,r13
    2593:	jmp    2605 <botlish_fn_23+0x2c4>
    2598:	mov    edx,0x3
    259d:	mov    rcx,QWORD PTR [rsp+0x28]
    25a2:	mov    rsi,r14
    25a5:	mov    rdi,r13
    25a8:	call   25ad <botlish_fn_23+0x26c>
			25a9: R_X86_64_PLT32	rt_mutarray_set-0x4
    25ad:	test   rax,rax
    25b0:	jne    25be <botlish_fn_23+0x27d>
    25b6:	mov    rdi,r13
    25b9:	jmp    2605 <botlish_fn_23+0x2c4>
    25be:	mov    edx,0x5
    25c3:	mov    rcx,QWORD PTR [rsp+0x20]
    25c8:	mov    rsi,r14
    25cb:	mov    rdi,r13
    25ce:	call   25d3 <botlish_fn_23+0x292>
			25cf: R_X86_64_PLT32	rt_mutarray_set-0x4
    25d3:	test   rax,rax
    25d6:	jne    25e4 <botlish_fn_23+0x2a3>
    25dc:	mov    rdi,r13
    25df:	jmp    2605 <botlish_fn_23+0x2c4>
    25e4:	mov    edx,0x9
    25e9:	mov    ecx,0x1
    25ee:	mov    rsi,r14
    25f1:	mov    rdi,r13
    25f4:	call   25f9 <botlish_fn_23+0x2b8>
			25f5: R_X86_64_PLT32	rt_mutarray_set-0x4
    25f9:	test   rax,rax
    25fc:	jne    2633 <botlish_fn_23+0x2f2>
    2602:	mov    rdi,r13
    2605:	mov    rdi,r13
    2608:	mov    QWORD PTR [rdi],r12
    260b:	xor    rax,rax
    260e:	mov    rbx,QWORD PTR [rsp+0x50]
    2613:	mov    r12,QWORD PTR [rsp+0x58]
    2618:	mov    r13,QWORD PTR [rsp+0x60]
    261d:	mov    r14,QWORD PTR [rsp+0x68]
    2622:	mov    r15,QWORD PTR [rsp+0x70]
    2627:	add    rsp,0x80
    262e:	mov    rsp,rbp
    2631:	pop    rbp
    2632:	ret
    2633:	mov    rdi,r13
    2636:	mov    QWORD PTR [rdi],r12
    2639:	mov    eax,0xa
    263e:	mov    rbx,QWORD PTR [rsp+0x50]
    2643:	mov    r12,QWORD PTR [rsp+0x58]
    2648:	mov    r13,QWORD PTR [rsp+0x60]
    264d:	mov    r14,QWORD PTR [rsp+0x68]
    2652:	mov    r15,QWORD PTR [rsp+0x70]
    2657:	add    rsp,0x80
    265e:	mov    rsp,rbp
    2661:	pop    rbp
    2662:	ret
    2663:	mov    r13,rdi
    2666:	call   266b <botlish_fn_23+0x32a>
			2667: R_X86_64_PLT32	rt_stack_overflow-0x4
    266b:	xor    rax,rax
    266e:	mov    rbx,QWORD PTR [rsp+0x50]
    2673:	mov    r12,QWORD PTR [rsp+0x58]
    2678:	mov    r13,QWORD PTR [rsp+0x60]
    267d:	mov    r14,QWORD PTR [rsp+0x68]
    2682:	mov    r15,QWORD PTR [rsp+0x70]
    2687:	add    rsp,0x80
    268e:	mov    rsp,rbp
    2691:	pop    rbp
    2692:	ret

0000000000002693 <botlish_entry_23: ht_rehash<mutarray, int>>:
    2693:	push   rbp
    2694:	mov    rbp,rsp
    2697:	mov    rsi,QWORD PTR [rdx]
    269a:	mov    rdx,QWORD PTR [rdx+0x8]
    269e:	call   26a3 <botlish_entry_23+0x10>
			269f: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    26a3:	mov    rsp,rbp
    26a6:	pop    rbp
    26a7:	ret

00000000000026a8 <botlish_fn_24: ht_should_grow<mutarray>>:
    26a8:	push   rbp
    26a9:	mov    rbp,rsp
    26ac:	sub    rsp,0x20
    26b0:	mov    QWORD PTR [rsp],rbx
    26b4:	mov    QWORD PTR [rsp+0x8],r12
    26b9:	mov    QWORD PTR [rsp+0x10],r13
    26be:	mov    QWORD PTR [rsp+0x18],r14
    26c3:	mov    r12,QWORD PTR [rdi]
    26c6:	mov    r8,QWORD PTR [rdi+0x8]
    26ca:	lea    r9,[r12+0x18]
    26cf:	cmp    r9,r8
    26d2:	ja     2a03 <botlish_fn_24+0x35b>
    26d8:	lea    r9,[r12+0x18]
    26dd:	mov    QWORD PTR [rdi],r9
    26e0:	mov    r13,rdi
    26e3:	mov    QWORD PTR [r12+0x8],0x0
    26ec:	mov    QWORD PTR [r12+0x10],0x0
    26f5:	mov    QWORD PTR [r12],rsi
    26f9:	mov    rbx,rsi
    26fc:	mov    rsi,rbx
    26ff:	mov    rdi,r13
    2702:	call   2707 <botlish_fn_24+0x5f>
			2703: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2707:	mov    rcx,rax
    270a:	mov    r14,rax
    270d:	test   rax,rcx
    2710:	jne    271e <botlish_fn_24+0x76>
    2716:	mov    rdi,r13
    2719:	jmp    291b <botlish_fn_24+0x273>
    271e:	mov    rax,r14
    2721:	mov    QWORD PTR [r12+0x8],rax
    2726:	mov    rsi,rbx
    2729:	mov    rdi,r13
    272c:	call   2731 <botlish_fn_24+0x89>
			272d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2731:	mov    rcx,rax
    2734:	test   rcx,rcx
    2737:	jne    2745 <botlish_fn_24+0x9d>
    273d:	mov    rdi,r13
    2740:	jmp    291b <botlish_fn_24+0x273>
    2745:	mov    QWORD PTR [r12+0x10],rcx
    274a:	mov    edx,0x1
    274f:	mov    rax,r14
    2752:	test   rax,0x1
    2758:	jne    277b <botlish_fn_24+0xd3>
    275e:	xor    edx,edx
    2760:	mov    rax,r14
    2763:	test   rax,0x7
    2769:	jne    277b <botlish_fn_24+0xd3>
    276f:	mov    rax,r14
    2772:	movzx  rax,BYTE PTR [rax]
    2776:	cmp    al,0x1
    2778:	sete   dl
    277b:	test   dl,dl
    277d:	jne    27a1 <botlish_fn_24+0xf9>
    2783:	mov    rdi,r13
    2786:	mov    rax,QWORD PTR [rdi+0x10]
    278a:	mov    rcx,QWORD PTR [rax+0x10]
    278e:	xor    rdx,rdx
    2791:	mov    rsi,r14
    2794:	call   2799 <botlish_fn_24+0xf1>
			2795: R_X86_64_PLT32	rt_type_error-0x4
    2799:	mov    rdi,r13
    279c:	jmp    291b <botlish_fn_24+0x273>
    27a1:	mov    eax,0x1
    27a6:	test   rcx,0x1
    27ad:	je     27bb <botlish_fn_24+0x113>
    27b3:	mov    r8,rcx
    27b6:	jmp    27de <botlish_fn_24+0x136>
    27bb:	xor    eax,eax
    27bd:	test   rcx,0x7
    27c4:	je     27d2 <botlish_fn_24+0x12a>
    27ca:	mov    r8,rcx
    27cd:	jmp    27de <botlish_fn_24+0x136>
    27d2:	movzx  rax,BYTE PTR [rcx]
    27d6:	mov    r8,rcx
    27d9:	cmp    al,0x1
    27db:	sete   al
    27de:	test   al,al
    27e0:	jne    2804 <botlish_fn_24+0x15c>
    27e6:	mov    rdi,r13
    27e9:	mov    rax,QWORD PTR [rdi+0x10]
    27ed:	mov    rcx,QWORD PTR [rax+0x10]
    27f1:	xor    rdx,rdx
    27f4:	mov    rsi,r8
    27f7:	call   27fc <botlish_fn_24+0x154>
			27f8: R_X86_64_PLT32	rt_type_error-0x4
    27fc:	mov    rdi,r13
    27ff:	jmp    291b <botlish_fn_24+0x273>
    2804:	mov    rcx,r8
    2807:	mov    rsi,r14
    280a:	mov    rax,rsi
    280d:	and    rax,rcx
    2810:	test   rax,0x1
    2816:	jne    2827 <botlish_fn_24+0x17f>
    281c:	mov    rdx,r8
    281f:	mov    rsi,r14
    2822:	jmp    2845 <botlish_fn_24+0x19d>
    2827:	mov    rcx,r8
    282a:	lea    rax,[rcx-0x1]
    282e:	mov    rsi,r14
    2831:	add    rsi,rax
    2834:	seto   al
    2837:	test   al,al
    2839:	je     2850 <botlish_fn_24+0x1a8>
    283f:	mov    rdx,r8
    2842:	mov    rsi,r14
    2845:	mov    rdi,r13
    2848:	call   284d <botlish_fn_24+0x1a5>
			2849: R_X86_64_PLT32	rt_int_add-0x4
    284d:	mov    rsi,rax
    2850:	mov    QWORD PTR [r12+0x8],rsi
    2855:	mov    QWORD PTR [r12+0x10],0x3
    285e:	test   rsi,0x1
    2865:	je     2888 <botlish_fn_24+0x1e0>
    286b:	mov    rax,rsi
    286e:	add    rax,0x2
    2872:	mov    rcx,rax
    2875:	seto   al
    2878:	test   al,al
    287a:	jne    2888 <botlish_fn_24+0x1e0>
    2880:	mov    rsi,rcx
    2883:	jmp    2898 <botlish_fn_24+0x1f0>
    2888:	mov    edx,0x3
    288d:	mov    rdi,r13
    2890:	call   2895 <botlish_fn_24+0x1ed>
			2891: R_X86_64_PLT32	rt_int_add-0x4
    2895:	mov    rsi,rax
    2898:	mov    QWORD PTR [r12+0x8],rsi
    289d:	mov    edx,0x7
    28a2:	mov    rcx,rdx
    28a5:	mov    QWORD PTR [r12+0x10],0x7
    28ae:	test   rsi,0x1
    28b5:	jne    28c3 <botlish_fn_24+0x21b>
    28bb:	mov    rdx,rcx
    28be:	jmp    28f1 <botlish_fn_24+0x249>
    28c3:	mov    rax,rsi
    28c6:	sar    rax,1
    28c9:	imul   QWORD PTR [rip+0x160]        # 2a30 <botlish_fn_24+0x388>
    28d0:	seto   dil
    28d4:	or     rax,0x1
    28d8:	test   dil,dil
    28db:	je     28e9 <botlish_fn_24+0x241>
    28e1:	mov    rdx,rcx
    28e4:	jmp    28f1 <botlish_fn_24+0x249>
    28e9:	mov    rsi,rax
    28ec:	jmp    28fc <botlish_fn_24+0x254>
    28f1:	mov    rdi,r13
    28f4:	call   28f9 <botlish_fn_24+0x251>
			28f5: R_X86_64_PLT32	rt_int_mul-0x4
    28f9:	mov    rsi,rax
    28fc:	mov    QWORD PTR [r12+0x8],rsi
    2901:	mov    r14,rsi
    2904:	mov    rsi,rbx
    2907:	mov    rdi,r13
    290a:	call   290f <botlish_fn_24+0x267>
			290b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    290f:	test   rax,rax
    2912:	jne    2940 <botlish_fn_24+0x298>
    2918:	mov    rdi,r13
    291b:	mov    rdi,r13
    291e:	mov    QWORD PTR [rdi],r12
    2921:	xor    rax,rax
    2924:	mov    rbx,QWORD PTR [rsp]
    2928:	mov    r12,QWORD PTR [rsp+0x8]
    292d:	mov    r13,QWORD PTR [rsp+0x10]
    2932:	mov    r14,QWORD PTR [rsp+0x18]
    2937:	add    rsp,0x20
    293b:	mov    rsp,rbp
    293e:	pop    rbp
    293f:	ret
    2940:	mov    QWORD PTR [r12],rax
    2944:	mov    QWORD PTR [r12+0x10],0x5
    294d:	test   rax,0x1
    2953:	mov    rsi,rax
    2956:	je     2986 <botlish_fn_24+0x2de>
    295c:	mov    rcx,rsi
    295f:	mov    rax,rcx
    2962:	sar    rax,1
    2965:	imul   QWORD PTR [rip+0xcc]        # 2a38 <botlish_fn_24+0x390>
    296c:	seto   cl
    296f:	or     rax,0x1
    2973:	test   cl,cl
    2975:	jne    2986 <botlish_fn_24+0x2de>
    297b:	mov    rdx,rax
    297e:	mov    rsi,r14
    2981:	jmp    2999 <botlish_fn_24+0x2f1>
    2986:	mov    edx,0x5
    298b:	mov    rdi,r13
    298e:	call   2993 <botlish_fn_24+0x2eb>
			298f: R_X86_64_PLT32	rt_int_mul-0x4
    2993:	mov    rdx,rax
    2996:	mov    rsi,r14
    2999:	mov    rax,rsi
    299c:	and    rax,rdx
    299f:	test   rax,0x1
    29a5:	jne    29ce <botlish_fn_24+0x326>
    29ab:	mov    rdi,r13
    29ae:	call   29b3 <botlish_fn_24+0x30b>
			29af: R_X86_64_PLT32	rt_int_cmp-0x4
    29b3:	mov    ecx,0x2
    29b8:	test   rax,rax
    29bb:	mov    rax,rcx
    29be:	cmovg  rax,QWORD PTR [rip+0x6a]        # 2a30 <botlish_fn_24+0x388>
    29c6:	mov    rdi,r13
    29c9:	jmp    29e1 <botlish_fn_24+0x339>
    29ce:	mov    eax,0x2
    29d3:	cmp    rsi,rdx
    29d6:	cmovg  rax,QWORD PTR [rip+0x52]        # 2a30 <botlish_fn_24+0x388>
    29de:	mov    rdi,r13
    29e1:	mov    rdi,r13
    29e4:	mov    QWORD PTR [rdi],r12
    29e7:	mov    rbx,QWORD PTR [rsp]
    29eb:	mov    r12,QWORD PTR [rsp+0x8]
    29f0:	mov    r13,QWORD PTR [rsp+0x10]
    29f5:	mov    r14,QWORD PTR [rsp+0x18]
    29fa:	add    rsp,0x20
    29fe:	mov    rsp,rbp
    2a01:	pop    rbp
    2a02:	ret
    2a03:	mov    r13,rdi
    2a06:	call   2a0b <botlish_fn_24+0x363>
			2a07: R_X86_64_PLT32	rt_stack_overflow-0x4
    2a0b:	xor    rax,rax
    2a0e:	mov    rbx,QWORD PTR [rsp]
    2a12:	mov    r12,QWORD PTR [rsp+0x8]
    2a17:	mov    r13,QWORD PTR [rsp+0x10]
    2a1c:	mov    r14,QWORD PTR [rsp+0x18]
    2a21:	add    rsp,0x20
    2a25:	mov    rsp,rbp
    2a28:	pop    rbp
    2a29:	ret
    2a2a:	add    BYTE PTR [rax],al
    2a2c:	add    BYTE PTR [rax],al
    2a2e:	add    BYTE PTR [rax],al
    2a30:	(bad)
    2a31:	add    BYTE PTR [rax],al
    2a33:	add    BYTE PTR [rax],al
    2a35:	add    BYTE PTR [rax],al
    2a37:	add    BYTE PTR [rax+rax*1],al
    2a3a:	add    BYTE PTR [rax],al
    2a3c:	add    BYTE PTR [rax],al
	...

0000000000002a40 <botlish_entry_24: ht_should_grow<mutarray>>:
    2a40:	push   rbp
    2a41:	mov    rbp,rsp
    2a44:	mov    rsi,QWORD PTR [rdx]
    2a47:	call   2a4c <botlish_entry_24+0xc>
			2a48: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2a4c:	mov    rsp,rbp
    2a4f:	pop    rbp
    2a50:	ret
    2a51:	add    BYTE PTR [rax],al
    2a53:	add    BYTE PTR [rax],al
    2a55:	add    BYTE PTR [rax],al
	...

0000000000002a58 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    2a58:	push   rbp
    2a59:	mov    rbp,rsp
    2a5c:	sub    rsp,0x20
    2a60:	mov    QWORD PTR [rsp],rbx
    2a64:	mov    QWORD PTR [rsp+0x8],r12
    2a69:	mov    QWORD PTR [rsp+0x10],r13
    2a6e:	mov    QWORD PTR [rsp+0x18],r14
    2a73:	mov    rbx,QWORD PTR [rdi]
    2a76:	mov    rax,QWORD PTR [rdi+0x8]
    2a7a:	lea    rcx,[rbx+0x18]
    2a7e:	cmp    rcx,rax
    2a81:	ja     2d23 <botlish_fn_25+0x2cb>
    2a87:	lea    rax,[rbx+0x18]
    2a8b:	mov    QWORD PTR [rdi],rax
    2a8e:	mov    r12,rdi
    2a91:	mov    QWORD PTR [rbx+0x8],0x0
    2a99:	mov    QWORD PTR [rbx+0x10],0x0
    2aa1:	mov    QWORD PTR [rbx],rsi
    2aa4:	mov    r13,rsi
    2aa7:	mov    rsi,r13
    2aaa:	mov    rdi,r12
    2aad:	call   2ab2 <botlish_fn_25+0x5a>
			2aae: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2ab2:	test   rax,rax
    2ab5:	jne    2ac3 <botlish_fn_25+0x6b>
    2abb:	mov    rdi,r12
    2abe:	jmp    2cd9 <botlish_fn_25+0x281>
    2ac3:	mov    QWORD PTR [rbx+0x8],rax
    2ac7:	mov    r14,rax
    2aca:	mov    rsi,r13
    2acd:	mov    rdi,r12
    2ad0:	call   2ad5 <botlish_fn_25+0x7d>
			2ad1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2ad5:	mov    rcx,rax
    2ad8:	test   rcx,rcx
    2adb:	jne    2ae9 <botlish_fn_25+0x91>
    2ae1:	mov    rdi,r12
    2ae4:	jmp    2cd9 <botlish_fn_25+0x281>
    2ae9:	mov    edx,0x1
    2aee:	mov    rax,r14
    2af1:	test   rax,0x1
    2af7:	je     2b05 <botlish_fn_25+0xad>
    2afd:	mov    r14,rax
    2b00:	jmp    2b29 <botlish_fn_25+0xd1>
    2b05:	xor    edx,edx
    2b07:	test   rax,0x7
    2b0d:	je     2b1b <botlish_fn_25+0xc3>
    2b13:	mov    r14,rax
    2b16:	jmp    2b29 <botlish_fn_25+0xd1>
    2b1b:	movzx  rdx,BYTE PTR [rax]
    2b1f:	mov    r14,rax
    2b22:	rex cmp dl,0x1
    2b26:	sete   dl
    2b29:	test   dl,dl
    2b2b:	jne    2b4f <botlish_fn_25+0xf7>
    2b31:	mov    rdi,r12
    2b34:	mov    rax,QWORD PTR [rdi+0x10]
    2b38:	mov    rcx,QWORD PTR [rax+0x18]
    2b3c:	xor    rdx,rdx
    2b3f:	mov    rsi,r14
    2b42:	call   2b47 <botlish_fn_25+0xef>
			2b43: R_X86_64_PLT32	rt_type_error-0x4
    2b47:	mov    rdi,r12
    2b4a:	jmp    2cd9 <botlish_fn_25+0x281>
    2b4f:	mov    rsi,r14
    2b52:	mov    eax,0x1
    2b57:	test   rcx,0x1
    2b5e:	je     2b6c <botlish_fn_25+0x114>
    2b64:	mov    r9,rcx
    2b67:	jmp    2b8f <botlish_fn_25+0x137>
    2b6c:	xor    eax,eax
    2b6e:	test   rcx,0x7
    2b75:	je     2b83 <botlish_fn_25+0x12b>
    2b7b:	mov    r9,rcx
    2b7e:	jmp    2b8f <botlish_fn_25+0x137>
    2b83:	movzx  rax,BYTE PTR [rcx]
    2b87:	mov    r9,rcx
    2b8a:	cmp    al,0x1
    2b8c:	sete   al
    2b8f:	test   al,al
    2b91:	jne    2bb5 <botlish_fn_25+0x15d>
    2b97:	mov    rdi,r12
    2b9a:	mov    rax,QWORD PTR [rdi+0x10]
    2b9e:	mov    rcx,QWORD PTR [rax+0x18]
    2ba2:	xor    rdx,rdx
    2ba5:	mov    rsi,r9
    2ba8:	call   2bad <botlish_fn_25+0x155>
			2ba9: R_X86_64_PLT32	rt_type_error-0x4
    2bad:	mov    rdi,r12
    2bb0:	jmp    2cd9 <botlish_fn_25+0x281>
    2bb5:	mov    rcx,r9
    2bb8:	mov    rax,rsi
    2bbb:	and    rax,rcx
    2bbe:	test   rax,0x1
    2bc4:	jne    2beb <botlish_fn_25+0x193>
    2bca:	mov    rdx,r9
    2bcd:	mov    rdi,r12
    2bd0:	call   2bd5 <botlish_fn_25+0x17d>
			2bd1: R_X86_64_PLT32	rt_int_cmp-0x4
    2bd5:	mov    r8d,0x2
    2bdb:	test   rax,rax
    2bde:	cmovg  r8,QWORD PTR [rip+0x16a]        # 2d50 <botlish_fn_25+0x2f8>
    2be6:	jmp    2bff <botlish_fn_25+0x1a7>
    2beb:	mov    r8d,0x2
    2bf1:	mov    rcx,r9
    2bf4:	cmp    rsi,rcx
    2bf7:	cmovg  r8,QWORD PTR [rip+0x151]        # 2d50 <botlish_fn_25+0x2f8>
    2bff:	cmp    r8,0x6
    2c03:	je     2c9f <botlish_fn_25+0x247>
    2c09:	mov    rsi,r13
    2c0c:	mov    rdi,r12
    2c0f:	call   2c14 <botlish_fn_25+0x1bc>
			2c10: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2c14:	test   rax,rax
    2c17:	jne    2c25 <botlish_fn_25+0x1cd>
    2c1d:	mov    rdi,r12
    2c20:	jmp    2cd9 <botlish_fn_25+0x281>
    2c25:	mov    QWORD PTR [rbx+0x8],rax
    2c29:	mov    QWORD PTR [rbx+0x10],0x5
    2c31:	test   rax,0x1
    2c37:	mov    rsi,rax
    2c3a:	je     2c67 <botlish_fn_25+0x20f>
    2c40:	mov    rcx,rsi
    2c43:	mov    rax,rcx
    2c46:	sar    rax,1
    2c49:	imul   QWORD PTR [rip+0x108]        # 2d58 <botlish_fn_25+0x300>
    2c50:	seto   cl
    2c53:	or     rax,0x1
    2c57:	test   cl,cl
    2c59:	jne    2c67 <botlish_fn_25+0x20f>
    2c5f:	mov    rdx,rax
    2c62:	jmp    2c77 <botlish_fn_25+0x21f>
    2c67:	mov    edx,0x5
    2c6c:	mov    rdi,r12
    2c6f:	call   2c74 <botlish_fn_25+0x21c>
			2c70: R_X86_64_PLT32	rt_int_mul-0x4
    2c74:	mov    rdx,rax
    2c77:	mov    QWORD PTR [rbx+0x8],rdx
    2c7b:	mov    rsi,r13
    2c7e:	mov    rdi,r12
    2c81:	call   2c86 <botlish_fn_25+0x22e>
			2c82: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2c86:	test   rax,rax
    2c89:	jne    2c97 <botlish_fn_25+0x23f>
    2c8f:	mov    rdi,r12
    2c92:	jmp    2cd9 <botlish_fn_25+0x281>
    2c97:	mov    rdi,r12
    2c9a:	jmp    2d01 <botlish_fn_25+0x2a9>
    2c9f:	mov    rsi,r13
    2ca2:	mov    rdi,r12
    2ca5:	call   2caa <botlish_fn_25+0x252>
			2ca6: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2caa:	test   rax,rax
    2cad:	jne    2cbb <botlish_fn_25+0x263>
    2cb3:	mov    rdi,r12
    2cb6:	jmp    2cd9 <botlish_fn_25+0x281>
    2cbb:	mov    QWORD PTR [rbx+0x8],rax
    2cbf:	mov    rdx,rax
    2cc2:	mov    rsi,r13
    2cc5:	mov    rdi,r12
    2cc8:	call   2ccd <botlish_fn_25+0x275>
			2cc9: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2ccd:	test   rax,rax
    2cd0:	jne    2cfe <botlish_fn_25+0x2a6>
    2cd6:	mov    rdi,r12
    2cd9:	mov    rdi,r12
    2cdc:	mov    QWORD PTR [rdi],rbx
    2cdf:	xor    rax,rax
    2ce2:	mov    rbx,QWORD PTR [rsp]
    2ce6:	mov    r12,QWORD PTR [rsp+0x8]
    2ceb:	mov    r13,QWORD PTR [rsp+0x10]
    2cf0:	mov    r14,QWORD PTR [rsp+0x18]
    2cf5:	add    rsp,0x20
    2cf9:	mov    rsp,rbp
    2cfc:	pop    rbp
    2cfd:	ret
    2cfe:	mov    rdi,r12
    2d01:	mov    rdi,r12
    2d04:	mov    QWORD PTR [rdi],rbx
    2d07:	mov    rbx,QWORD PTR [rsp]
    2d0b:	mov    r12,QWORD PTR [rsp+0x8]
    2d10:	mov    r13,QWORD PTR [rsp+0x10]
    2d15:	mov    r14,QWORD PTR [rsp+0x18]
    2d1a:	add    rsp,0x20
    2d1e:	mov    rsp,rbp
    2d21:	pop    rbp
    2d22:	ret
    2d23:	mov    r12,rdi
    2d26:	call   2d2b <botlish_fn_25+0x2d3>
			2d27: R_X86_64_PLT32	rt_stack_overflow-0x4
    2d2b:	xor    rax,rax
    2d2e:	mov    rbx,QWORD PTR [rsp]
    2d32:	mov    r12,QWORD PTR [rsp+0x8]
    2d37:	mov    r13,QWORD PTR [rsp+0x10]
    2d3c:	mov    r14,QWORD PTR [rsp+0x18]
    2d41:	add    rsp,0x20
    2d45:	mov    rsp,rbp
    2d48:	pop    rbp
    2d49:	ret
    2d4a:	add    BYTE PTR [rax],al
    2d4c:	add    BYTE PTR [rax],al
    2d4e:	add    BYTE PTR [rax],al
    2d50:	(bad)
    2d51:	add    BYTE PTR [rax],al
    2d53:	add    BYTE PTR [rax],al
    2d55:	add    BYTE PTR [rax],al
    2d57:	add    BYTE PTR [rax+rax*1],al
    2d5a:	add    BYTE PTR [rax],al
    2d5c:	add    BYTE PTR [rax],al
	...

0000000000002d60 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    2d60:	push   rbp
    2d61:	mov    rbp,rsp
    2d64:	mov    rsi,QWORD PTR [rdx]
    2d67:	call   2d6c <botlish_entry_25+0xc>
			2d68: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    2d6c:	mov    rsp,rbp
    2d6f:	pop    rbp
    2d70:	ret
    2d71:	add    BYTE PTR [rax],al
    2d73:	add    BYTE PTR [rax],al
    2d75:	add    BYTE PTR [rax],al
	...

0000000000002d78 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    2d78:	push   rbp
    2d79:	mov    rbp,rsp
    2d7c:	sub    rsp,0x50
    2d80:	mov    QWORD PTR [rsp+0x20],rbx
    2d85:	mov    QWORD PTR [rsp+0x28],r12
    2d8a:	mov    QWORD PTR [rsp+0x30],r13
    2d8f:	mov    QWORD PTR [rsp+0x38],r14
    2d94:	mov    QWORD PTR [rsp+0x40],r15
    2d99:	mov    r12,QWORD PTR [rdi]
    2d9c:	mov    rax,QWORD PTR [rdi+0x8]
    2da0:	lea    r9,[r12+0x30]
    2da5:	cmp    r9,rax
    2da8:	ja     326a <botlish_fn_26+0x4f2>
    2dae:	lea    rax,[r12+0x30]
    2db3:	mov    QWORD PTR [rdi],rax
    2db6:	mov    r13,rdi
    2db9:	mov    QWORD PTR [r12+0x20],0x0
    2dc2:	mov    QWORD PTR [r12+0x28],0x0
    2dcb:	mov    QWORD PTR [r12],rsi
    2dcf:	mov    r14,rsi
    2dd2:	mov    QWORD PTR [r12+0x8],rdx
    2dd7:	mov    QWORD PTR [rsp],rdx
    2ddb:	mov    QWORD PTR [r12+0x10],rcx
    2de0:	mov    QWORD PTR [rsp+0x8],rcx
    2de5:	mov    QWORD PTR [r12+0x18],r8
    2dea:	mov    r15,r8
    2ded:	mov    rsi,r14
    2df0:	mov    rdi,r13
    2df3:	call   2df8 <botlish_fn_26+0x80>
			2df4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    2df8:	test   rax,rax
    2dfb:	jne    2e09 <botlish_fn_26+0x91>
    2e01:	mov    rdi,r13
    2e04:	jmp    320f <botlish_fn_26+0x497>
    2e09:	mov    QWORD PTR [r12+0x20],rax
    2e0e:	xor    ecx,ecx
    2e10:	test   rax,0x7
    2e16:	je     2e26 <botlish_fn_26+0xae>
    2e1c:	mov    QWORD PTR [rsp+0x10],rax
    2e21:	jmp    2e36 <botlish_fn_26+0xbe>
    2e26:	movzx  rcx,BYTE PTR [rax]
    2e2a:	mov    QWORD PTR [rsp+0x10],rax
    2e2f:	rex cmp cl,0x8
    2e33:	sete   cl
    2e36:	test   cl,cl
    2e38:	jne    2e60 <botlish_fn_26+0xe8>
    2e3e:	mov    rdi,r13
    2e41:	mov    rax,QWORD PTR [rdi+0x10]
    2e45:	mov    rcx,QWORD PTR [rax+0x8]
    2e49:	mov    edx,0x8
    2e4e:	mov    rsi,QWORD PTR [rsp+0x10]
    2e53:	call   2e58 <botlish_fn_26+0xe0>
			2e54: R_X86_64_PLT32	rt_type_error-0x4
    2e58:	mov    rdi,r13
    2e5b:	jmp    320f <botlish_fn_26+0x497>
    2e60:	mov    rdx,QWORD PTR [rsp]
    2e64:	mov    rsi,QWORD PTR [rsp+0x10]
    2e69:	mov    rdi,r13
    2e6c:	call   2e71 <botlish_fn_26+0xf9>
			2e6d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2e71:	mov    rbx,rax
    2e74:	test   rbx,rbx
    2e77:	jne    2e85 <botlish_fn_26+0x10d>
    2e7d:	mov    rdi,r13
    2e80:	jmp    320f <botlish_fn_26+0x497>
    2e85:	mov    QWORD PTR [r12+0x28],rbx
    2e8a:	mov    rdi,r13
    2e8d:	call   2e92 <botlish_fn_26+0x11a>
			2e8e: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    2e92:	test   rax,rax
    2e95:	mov    rcx,rax
    2e98:	jne    2ea6 <botlish_fn_26+0x12e>
    2e9e:	mov    rdi,r13
    2ea1:	jmp    320f <botlish_fn_26+0x497>
    2ea6:	mov    rsi,QWORD PTR [rsp+0x10]
    2eab:	mov    rdx,QWORD PTR [rsp]
    2eaf:	mov    rdi,r13
    2eb2:	call   2eb7 <botlish_fn_26+0x13f>
			2eb3: R_X86_64_PLT32	rt_mutarray_set-0x4
    2eb7:	test   rax,rax
    2eba:	jne    2ec8 <botlish_fn_26+0x150>
    2ec0:	mov    rdi,r13
    2ec3:	jmp    320f <botlish_fn_26+0x497>
    2ec8:	mov    rsi,r14
    2ecb:	mov    rdi,r13
    2ece:	call   2ed3 <botlish_fn_26+0x15b>
			2ecf: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2ed3:	test   rax,rax
    2ed6:	jne    2ee4 <botlish_fn_26+0x16c>
    2edc:	mov    rdi,r13
    2edf:	jmp    320f <botlish_fn_26+0x497>
    2ee4:	xor    ecx,ecx
    2ee6:	test   rax,0x7
    2eec:	je     2efa <botlish_fn_26+0x182>
    2ef2:	mov    rsi,rax
    2ef5:	jmp    2f08 <botlish_fn_26+0x190>
    2efa:	movzx  rdi,BYTE PTR [rax]
    2efe:	mov    rsi,rax
    2f01:	cmp    dil,0x8
    2f05:	sete   cl
    2f08:	test   cl,cl
    2f0a:	jne    2f2d <botlish_fn_26+0x1b5>
    2f10:	mov    rdi,r13
    2f13:	mov    r11,QWORD PTR [rdi+0x10]
    2f17:	mov    rcx,QWORD PTR [r11+0x20]
    2f1b:	mov    edx,0x8
    2f20:	call   2f25 <botlish_fn_26+0x1ad>
			2f21: R_X86_64_PLT32	rt_type_error-0x4
    2f25:	mov    rdi,r13
    2f28:	jmp    320f <botlish_fn_26+0x497>
    2f2d:	mov    rcx,QWORD PTR [rsp+0x8]
    2f32:	mov    rdx,QWORD PTR [rsp]
    2f36:	mov    rdi,r13
    2f39:	call   2f3e <botlish_fn_26+0x1c6>
			2f3a: R_X86_64_PLT32	rt_mutarray_set-0x4
    2f3e:	test   rax,rax
    2f41:	jne    2f4f <botlish_fn_26+0x1d7>
    2f47:	mov    rdi,r13
    2f4a:	jmp    320f <botlish_fn_26+0x497>
    2f4f:	mov    rsi,r14
    2f52:	mov    rdi,r13
    2f55:	call   2f5a <botlish_fn_26+0x1e2>
			2f56: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2f5a:	test   rax,rax
    2f5d:	jne    2f6b <botlish_fn_26+0x1f3>
    2f63:	mov    rdi,r13
    2f66:	jmp    320f <botlish_fn_26+0x497>
    2f6b:	xor    ecx,ecx
    2f6d:	test   rax,0x7
    2f73:	je     2f81 <botlish_fn_26+0x209>
    2f79:	mov    rsi,rax
    2f7c:	jmp    2f8f <botlish_fn_26+0x217>
    2f81:	movzx  rcx,BYTE PTR [rax]
    2f85:	mov    rsi,rax
    2f88:	rex cmp cl,0x8
    2f8c:	sete   cl
    2f8f:	test   cl,cl
    2f91:	jne    2fb4 <botlish_fn_26+0x23c>
    2f97:	mov    rdi,r13
    2f9a:	mov    rax,QWORD PTR [rdi+0x10]
    2f9e:	mov    rcx,QWORD PTR [rax+0x20]
    2fa2:	mov    edx,0x8
    2fa7:	call   2fac <botlish_fn_26+0x234>
			2fa8: R_X86_64_PLT32	rt_type_error-0x4
    2fac:	mov    rdi,r13
    2faf:	jmp    320f <botlish_fn_26+0x497>
    2fb4:	mov    rcx,r15
    2fb7:	mov    rdx,QWORD PTR [rsp]
    2fbb:	mov    rdi,r13
    2fbe:	call   2fc3 <botlish_fn_26+0x24b>
			2fbf: R_X86_64_PLT32	rt_mutarray_set-0x4
    2fc3:	test   rax,rax
    2fc6:	jne    2fd4 <botlish_fn_26+0x25c>
    2fcc:	mov    rdi,r13
    2fcf:	jmp    320f <botlish_fn_26+0x497>
    2fd4:	mov    QWORD PTR [r12+0x8],0x7
    2fdd:	mov    rsi,r14
    2fe0:	mov    rdi,r13
    2fe3:	call   2fe8 <botlish_fn_26+0x270>
			2fe4: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2fe8:	test   rax,rax
    2feb:	jne    2ff9 <botlish_fn_26+0x281>
    2ff1:	mov    rdi,r13
    2ff4:	jmp    320f <botlish_fn_26+0x497>
    2ff9:	mov    QWORD PTR [r12+0x10],rax
    2ffe:	mov    QWORD PTR [r12+0x18],0x3
    3007:	mov    ecx,0x1
    300c:	test   rax,0x1
    3012:	je     3020 <botlish_fn_26+0x2a8>
    3018:	mov    rsi,rax
    301b:	jmp    3044 <botlish_fn_26+0x2cc>
    3020:	xor    ecx,ecx
    3022:	test   rax,0x7
    3028:	je     3036 <botlish_fn_26+0x2be>
    302e:	mov    rsi,rax
    3031:	jmp    3044 <botlish_fn_26+0x2cc>
    3036:	movzx  rcx,BYTE PTR [rax]
    303a:	mov    rsi,rax
    303d:	rex cmp cl,0x1
    3041:	sete   cl
    3044:	test   cl,cl
    3046:	jne    3067 <botlish_fn_26+0x2ef>
    304c:	mov    rdi,r13
    304f:	mov    rax,QWORD PTR [rdi+0x10]
    3053:	mov    rcx,QWORD PTR [rax+0x10]
    3057:	xor    rdx,rdx
    305a:	call   305f <botlish_fn_26+0x2e7>
			305b: R_X86_64_PLT32	rt_type_error-0x4
    305f:	mov    rdi,r13
    3062:	jmp    320f <botlish_fn_26+0x497>
    3067:	test   rsi,0x1
    306e:	je     3086 <botlish_fn_26+0x30e>
    3074:	mov    rcx,rsi
    3077:	add    rcx,0x2
    307b:	seto   al
    307e:	test   al,al
    3080:	je     3096 <botlish_fn_26+0x31e>
    3086:	mov    edx,0x3
    308b:	mov    rdi,r13
    308e:	call   3093 <botlish_fn_26+0x31b>
			308f: R_X86_64_PLT32	rt_int_add-0x4
    3093:	mov    rcx,rax
    3096:	mov    edx,0x7
    309b:	mov    rsi,r14
    309e:	mov    rdi,r13
    30a1:	call   30a6 <botlish_fn_26+0x32e>
			30a2: R_X86_64_PLT32	rt_mutarray_set-0x4
    30a6:	test   rax,rax
    30a9:	jne    30b7 <botlish_fn_26+0x33f>
    30af:	mov    rdi,r13
    30b2:	jmp    320f <botlish_fn_26+0x497>
    30b7:	mov    rdi,r13
    30ba:	call   30bf <botlish_fn_26+0x347>
			30bb: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    30bf:	test   rax,rax
    30c2:	jne    30d0 <botlish_fn_26+0x358>
    30c8:	mov    rdi,r13
    30cb:	jmp    320f <botlish_fn_26+0x497>
    30d0:	mov    rcx,rbx
    30d3:	and    rcx,rax
    30d6:	mov    rdx,rax
    30d9:	mov    rax,rbx
    30dc:	test   rcx,0x1
    30e3:	jne    3105 <botlish_fn_26+0x38d>
    30e9:	mov    rsi,rax
    30ec:	mov    rdi,r13
    30ef:	call   30f4 <botlish_fn_26+0x37c>
			30f0: R_X86_64_PLT32	rt_value_eq-0x4
    30f4:	test   rax,rax
    30f7:	jne    3118 <botlish_fn_26+0x3a0>
    30fd:	mov    rdi,r13
    3100:	jmp    320f <botlish_fn_26+0x497>
    3105:	mov    rsi,rax
    3108:	mov    eax,0x2
    310d:	cmp    rsi,rdx
    3110:	cmove  rax,QWORD PTR [rip+0x180]        # 3298 <botlish_fn_26+0x520>
    3118:	cmp    rax,0x6
    311c:	je     312a <botlish_fn_26+0x3b2>
    3122:	mov    rdi,r13
    3125:	jmp    323d <botlish_fn_26+0x4c5>
    312a:	mov    QWORD PTR [r12+0x8],0x9
    3133:	mov    rsi,r14
    3136:	mov    rdi,r13
    3139:	call   313e <botlish_fn_26+0x3c6>
			313a: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    313e:	test   rax,rax
    3141:	jne    314f <botlish_fn_26+0x3d7>
    3147:	mov    rdi,r13
    314a:	jmp    320f <botlish_fn_26+0x497>
    314f:	mov    QWORD PTR [r12+0x10],rax
    3154:	mov    QWORD PTR [r12+0x18],0x3
    315d:	mov    ecx,0x1
    3162:	test   rax,0x1
    3168:	je     3176 <botlish_fn_26+0x3fe>
    316e:	mov    rsi,rax
    3171:	jmp    319a <botlish_fn_26+0x422>
    3176:	xor    ecx,ecx
    3178:	test   rax,0x7
    317e:	je     318c <botlish_fn_26+0x414>
    3184:	mov    rsi,rax
    3187:	jmp    319a <botlish_fn_26+0x422>
    318c:	movzx  rcx,BYTE PTR [rax]
    3190:	mov    rsi,rax
    3193:	rex cmp cl,0x1
    3197:	sete   cl
    319a:	test   cl,cl
    319c:	jne    31bd <botlish_fn_26+0x445>
    31a2:	mov    rdi,r13
    31a5:	mov    rax,QWORD PTR [rdi+0x10]
    31a9:	mov    rcx,QWORD PTR [rax+0x28]
    31ad:	xor    rdx,rdx
    31b0:	call   31b5 <botlish_fn_26+0x43d>
			31b1: R_X86_64_PLT32	rt_type_error-0x4
    31b5:	mov    rdi,r13
    31b8:	jmp    320f <botlish_fn_26+0x497>
    31bd:	test   rsi,0x1
    31c4:	je     31e3 <botlish_fn_26+0x46b>
    31ca:	mov    rcx,rsi
    31cd:	sub    rcx,0x3
    31d1:	seto   al
    31d4:	add    rcx,0x1
    31db:	test   al,al
    31dd:	je     31f3 <botlish_fn_26+0x47b>
    31e3:	mov    edx,0x3
    31e8:	mov    rdi,r13
    31eb:	call   31f0 <botlish_fn_26+0x478>
			31ec: R_X86_64_PLT32	rt_int_sub-0x4
    31f0:	mov    rcx,rax
    31f3:	mov    edx,0x9
    31f8:	mov    rsi,r14
    31fb:	mov    rdi,r13
    31fe:	call   3203 <botlish_fn_26+0x48b>
			31ff: R_X86_64_PLT32	rt_mutarray_set-0x4
    3203:	test   rax,rax
    3206:	jne    323a <botlish_fn_26+0x4c2>
    320c:	mov    rdi,r13
    320f:	mov    rdi,r13
    3212:	mov    QWORD PTR [rdi],r12
    3215:	xor    rax,rax
    3218:	mov    rbx,QWORD PTR [rsp+0x20]
    321d:	mov    r12,QWORD PTR [rsp+0x28]
    3222:	mov    r13,QWORD PTR [rsp+0x30]
    3227:	mov    r14,QWORD PTR [rsp+0x38]
    322c:	mov    r15,QWORD PTR [rsp+0x40]
    3231:	add    rsp,0x50
    3235:	mov    rsp,rbp
    3238:	pop    rbp
    3239:	ret
    323a:	mov    rdi,r13
    323d:	mov    rdi,r13
    3240:	mov    QWORD PTR [rdi],r12
    3243:	mov    eax,0xa
    3248:	mov    rbx,QWORD PTR [rsp+0x20]
    324d:	mov    r12,QWORD PTR [rsp+0x28]
    3252:	mov    r13,QWORD PTR [rsp+0x30]
    3257:	mov    r14,QWORD PTR [rsp+0x38]
    325c:	mov    r15,QWORD PTR [rsp+0x40]
    3261:	add    rsp,0x50
    3265:	mov    rsp,rbp
    3268:	pop    rbp
    3269:	ret
    326a:	mov    r13,rdi
    326d:	call   3272 <botlish_fn_26+0x4fa>
			326e: R_X86_64_PLT32	rt_stack_overflow-0x4
    3272:	xor    rax,rax
    3275:	mov    rbx,QWORD PTR [rsp+0x20]
    327a:	mov    r12,QWORD PTR [rsp+0x28]
    327f:	mov    r13,QWORD PTR [rsp+0x30]
    3284:	mov    r14,QWORD PTR [rsp+0x38]
    3289:	mov    r15,QWORD PTR [rsp+0x40]
    328e:	add    rsp,0x50
    3292:	mov    rsp,rbp
    3295:	pop    rbp
    3296:	ret
    3297:	add    BYTE PTR [rsi],al
    3299:	add    BYTE PTR [rax],al
    329b:	add    BYTE PTR [rax],al
    329d:	add    BYTE PTR [rax],al
	...

00000000000032a0 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    32a0:	push   rbp
    32a1:	mov    rbp,rsp
    32a4:	mov    rsi,QWORD PTR [rdx]
    32a7:	mov    r9,QWORD PTR [rdx+0x8]
    32ab:	mov    rcx,QWORD PTR [rdx+0x10]
    32af:	mov    r8,QWORD PTR [rdx+0x18]
    32b3:	mov    rdx,r9
    32b6:	call   32bb <botlish_entry_26+0x1b>
			32b7: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    32bb:	mov    rsp,rbp
    32be:	pop    rbp
    32bf:	ret

00000000000032c0 <botlish_fn_27: ht_set<mutarray, str, str>>:
    32c0:	push   rbp
    32c1:	mov    rbp,rsp
    32c4:	sub    rsp,0x50
    32c8:	mov    QWORD PTR [rsp+0x20],rbx
    32cd:	mov    QWORD PTR [rsp+0x28],r12
    32d2:	mov    QWORD PTR [rsp+0x30],r13
    32d7:	mov    QWORD PTR [rsp+0x38],r14
    32dc:	mov    QWORD PTR [rsp+0x40],r15
    32e1:	mov    rbx,QWORD PTR [rdi]
    32e4:	mov    rax,QWORD PTR [rdi+0x8]
    32e8:	lea    r8,[rbx+0x28]
    32ec:	cmp    r8,rax
    32ef:	ja     3691 <botlish_fn_27+0x3d1>
    32f5:	lea    rax,[rbx+0x28]
    32f9:	mov    QWORD PTR [rdi],rax
    32fc:	mov    r12,rdi
    32ff:	mov    QWORD PTR [rbx+0x18],0x0
    3307:	mov    QWORD PTR [rbx+0x20],0x0
    330f:	mov    QWORD PTR [rbx],rsi
    3312:	mov    r15,rsi
    3315:	mov    QWORD PTR [rbx+0x8],rdx
    3319:	mov    r14,rdx
    331c:	mov    QWORD PTR [rbx+0x10],rcx
    3320:	mov    r13,rcx
    3323:	mov    rdx,r14
    3326:	mov    rsi,r15
    3329:	mov    rdi,r12
    332c:	call   3331 <botlish_fn_27+0x71>
			332d: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3331:	test   rax,rax
    3334:	jne    3342 <botlish_fn_27+0x82>
    333a:	mov    rdi,r12
    333d:	jmp    3639 <botlish_fn_27+0x379>
    3342:	mov    QWORD PTR [rbx+0x18],rax
    3346:	mov    rcx,rax
    3349:	mov    r8,0xffffffffffffffff
    3350:	mov    QWORD PTR [rsp+0x10],r8
    3355:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    335d:	mov    rdx,r14
    3360:	mov    rsi,r15
    3363:	mov    rdi,r12
    3366:	call   336b <botlish_fn_27+0xab>
			3367: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    336b:	mov    rcx,rax
    336e:	mov    QWORD PTR [rsp+0x8],rax
    3373:	test   rax,rcx
    3376:	jne    3384 <botlish_fn_27+0xc4>
    337c:	mov    rdi,r12
    337f:	jmp    3639 <botlish_fn_27+0x379>
    3384:	mov    rax,QWORD PTR [rsp+0x8]
    3389:	mov    QWORD PTR [rbx+0x18],rax
    338d:	mov    rsi,r15
    3390:	mov    rdi,r12
    3393:	call   3398 <botlish_fn_27+0xd8>
			3394: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    3398:	test   rax,rax
    339b:	jne    33a9 <botlish_fn_27+0xe9>
    33a1:	mov    rdi,r12
    33a4:	jmp    3639 <botlish_fn_27+0x379>
    33a9:	xor    ecx,ecx
    33ab:	test   rax,0x7
    33b1:	je     33bf <botlish_fn_27+0xff>
    33b7:	mov    rsi,rax
    33ba:	jmp    33cd <botlish_fn_27+0x10d>
    33bf:	movzx  rcx,BYTE PTR [rax]
    33c3:	mov    rsi,rax
    33c6:	rex cmp cl,0x8
    33ca:	sete   cl
    33cd:	test   cl,cl
    33cf:	jne    33f2 <botlish_fn_27+0x132>
    33d5:	mov    rdi,r12
    33d8:	mov    rax,QWORD PTR [rdi+0x10]
    33dc:	mov    rcx,QWORD PTR [rax+0x8]
    33e0:	mov    edx,0x8
    33e5:	call   33ea <botlish_fn_27+0x12a>
			33e6: R_X86_64_PLT32	rt_type_error-0x4
    33ea:	mov    rdi,r12
    33ed:	jmp    3639 <botlish_fn_27+0x379>
    33f2:	mov    rdx,QWORD PTR [rsp+0x8]
    33f7:	mov    rdi,r12
    33fa:	call   33ff <botlish_fn_27+0x13f>
			33fb: R_X86_64_PLT32	rt_mutarray_get-0x4
    33ff:	test   rax,rax
    3402:	jne    3410 <botlish_fn_27+0x150>
    3408:	mov    rdi,r12
    340b:	jmp    3639 <botlish_fn_27+0x379>
    3410:	mov    QWORD PTR [rbx+0x20],rax
    3414:	mov    QWORD PTR [rsp],rax
    3418:	mov    rdi,r12
    341b:	call   3420 <botlish_fn_27+0x160>
			341c: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    3420:	test   rax,rax
    3423:	jne    3431 <botlish_fn_27+0x171>
    3429:	mov    rdi,r12
    342c:	jmp    3639 <botlish_fn_27+0x379>
    3431:	mov    rcx,QWORD PTR [rsp]
    3435:	mov    rdx,rcx
    3438:	and    rdx,rax
    343b:	test   rdx,0x1
    3442:	jne    3468 <botlish_fn_27+0x1a8>
    3448:	mov    rdx,rax
    344b:	mov    rsi,QWORD PTR [rsp]
    344f:	mov    rdi,r12
    3452:	call   3457 <botlish_fn_27+0x197>
			3453: R_X86_64_PLT32	rt_value_eq-0x4
    3457:	test   rax,rax
    345a:	jne    347f <botlish_fn_27+0x1bf>
    3460:	mov    rdi,r12
    3463:	jmp    3639 <botlish_fn_27+0x379>
    3468:	mov    rdx,rax
    346b:	mov    rsi,QWORD PTR [rsp]
    346f:	mov    eax,0x2
    3474:	cmp    rsi,rdx
    3477:	cmove  rax,QWORD PTR [rip+0x241]        # 36c0 <botlish_fn_27+0x400>
    347f:	cmp    rax,0x6
    3483:	je     35bd <botlish_fn_27+0x2fd>
    3489:	mov    rsi,r15
    348c:	mov    rdi,r12
    348f:	call   3494 <botlish_fn_27+0x1d4>
			3490: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    3494:	test   rax,rax
    3497:	jne    34a5 <botlish_fn_27+0x1e5>
    349d:	mov    rdi,r12
    34a0:	jmp    3639 <botlish_fn_27+0x379>
    34a5:	cmp    rax,0x6
    34a9:	je     34fe <botlish_fn_27+0x23e>
    34af:	mov    rcx,r14
    34b2:	mov    rdx,QWORD PTR [rsp+0x8]
    34b7:	mov    rsi,r15
    34ba:	mov    r8,r13
    34bd:	mov    rdi,r12
    34c0:	call   34c5 <botlish_fn_27+0x205>
			34c1: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    34c5:	test   rax,rax
    34c8:	jne    34d6 <botlish_fn_27+0x216>
    34ce:	mov    rdi,r12
    34d1:	jmp    3639 <botlish_fn_27+0x379>
    34d6:	mov    rdi,r12
    34d9:	mov    QWORD PTR [rdi],rbx
    34dc:	mov    rbx,QWORD PTR [rsp+0x20]
    34e1:	mov    r12,QWORD PTR [rsp+0x28]
    34e6:	mov    r13,QWORD PTR [rsp+0x30]
    34eb:	mov    r14,QWORD PTR [rsp+0x38]
    34f0:	mov    r15,QWORD PTR [rsp+0x40]
    34f5:	add    rsp,0x50
    34f9:	mov    rsp,rbp
    34fc:	pop    rbp
    34fd:	ret
    34fe:	mov    rsi,r15
    3501:	mov    rdi,r12
    3504:	call   3509 <botlish_fn_27+0x249>
			3505: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    3509:	test   rax,rax
    350c:	jne    351a <botlish_fn_27+0x25a>
    3512:	mov    rdi,r12
    3515:	jmp    3639 <botlish_fn_27+0x379>
    351a:	mov    rdx,r14
    351d:	mov    rsi,r15
    3520:	mov    rdi,r12
    3523:	call   3528 <botlish_fn_27+0x268>
			3524: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3528:	test   rax,rax
    352b:	jne    3539 <botlish_fn_27+0x279>
    3531:	mov    rdi,r12
    3534:	jmp    3639 <botlish_fn_27+0x379>
    3539:	mov    QWORD PTR [rbx+0x18],rax
    353d:	mov    rcx,rax
    3540:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    3548:	mov    r8,QWORD PTR [rsp+0x10]
    354d:	mov    rdx,r14
    3550:	mov    rsi,r15
    3553:	mov    rdi,r12
    3556:	call   355b <botlish_fn_27+0x29b>
			3557: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    355b:	test   rax,rax
    355e:	jne    356c <botlish_fn_27+0x2ac>
    3564:	mov    rdi,r12
    3567:	jmp    3639 <botlish_fn_27+0x379>
    356c:	mov    QWORD PTR [rbx+0x18],rax
    3570:	mov    rcx,r14
    3573:	mov    rdx,rax
    3576:	mov    rsi,r15
    3579:	mov    r8,r13
    357c:	mov    rdi,r12
    357f:	call   3584 <botlish_fn_27+0x2c4>
			3580: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    3584:	test   rax,rax
    3587:	jne    3595 <botlish_fn_27+0x2d5>
    358d:	mov    rdi,r12
    3590:	jmp    3639 <botlish_fn_27+0x379>
    3595:	mov    rdi,r12
    3598:	mov    QWORD PTR [rdi],rbx
    359b:	mov    rbx,QWORD PTR [rsp+0x20]
    35a0:	mov    r12,QWORD PTR [rsp+0x28]
    35a5:	mov    r13,QWORD PTR [rsp+0x30]
    35aa:	mov    r14,QWORD PTR [rsp+0x38]
    35af:	mov    r15,QWORD PTR [rsp+0x40]
    35b4:	add    rsp,0x50
    35b8:	mov    rsp,rbp
    35bb:	pop    rbp
    35bc:	ret
    35bd:	mov    rsi,r15
    35c0:	mov    rdi,r12
    35c3:	call   35c8 <botlish_fn_27+0x308>
			35c4: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    35c8:	test   rax,rax
    35cb:	jne    35d9 <botlish_fn_27+0x319>
    35d1:	mov    rdi,r12
    35d4:	jmp    3639 <botlish_fn_27+0x379>
    35d9:	xor    ecx,ecx
    35db:	test   rax,0x7
    35e1:	jne    35f2 <botlish_fn_27+0x332>
    35e7:	movzx  rsi,BYTE PTR [rax]
    35eb:	cmp    sil,0x8
    35ef:	sete   cl
    35f2:	test   cl,cl
    35f4:	jne    361a <botlish_fn_27+0x35a>
    35fa:	mov    rdi,r12
    35fd:	mov    r10,QWORD PTR [rdi+0x10]
    3601:	mov    rcx,QWORD PTR [r10+0x20]
    3605:	mov    edx,0x8
    360a:	mov    rsi,rax
    360d:	call   3612 <botlish_fn_27+0x352>
			360e: R_X86_64_PLT32	rt_type_error-0x4
    3612:	mov    rdi,r12
    3615:	jmp    3639 <botlish_fn_27+0x379>
    361a:	mov    rcx,r13
    361d:	mov    rdx,QWORD PTR [rsp+0x8]
    3622:	mov    rsi,rax
    3625:	mov    rdi,r12
    3628:	call   362d <botlish_fn_27+0x36d>
			3629: R_X86_64_PLT32	rt_mutarray_set-0x4
    362d:	test   rax,rax
    3630:	jne    3664 <botlish_fn_27+0x3a4>
    3636:	mov    rdi,r12
    3639:	mov    rdi,r12
    363c:	mov    QWORD PTR [rdi],rbx
    363f:	xor    rax,rax
    3642:	mov    rbx,QWORD PTR [rsp+0x20]
    3647:	mov    r12,QWORD PTR [rsp+0x28]
    364c:	mov    r13,QWORD PTR [rsp+0x30]
    3651:	mov    r14,QWORD PTR [rsp+0x38]
    3656:	mov    r15,QWORD PTR [rsp+0x40]
    365b:	add    rsp,0x50
    365f:	mov    rsp,rbp
    3662:	pop    rbp
    3663:	ret
    3664:	mov    rdi,r12
    3667:	mov    QWORD PTR [rdi],rbx
    366a:	mov    eax,0xa
    366f:	mov    rbx,QWORD PTR [rsp+0x20]
    3674:	mov    r12,QWORD PTR [rsp+0x28]
    3679:	mov    r13,QWORD PTR [rsp+0x30]
    367e:	mov    r14,QWORD PTR [rsp+0x38]
    3683:	mov    r15,QWORD PTR [rsp+0x40]
    3688:	add    rsp,0x50
    368c:	mov    rsp,rbp
    368f:	pop    rbp
    3690:	ret
    3691:	mov    r12,rdi
    3694:	call   3699 <botlish_fn_27+0x3d9>
			3695: R_X86_64_PLT32	rt_stack_overflow-0x4
    3699:	xor    rax,rax
    369c:	mov    rbx,QWORD PTR [rsp+0x20]
    36a1:	mov    r12,QWORD PTR [rsp+0x28]
    36a6:	mov    r13,QWORD PTR [rsp+0x30]
    36ab:	mov    r14,QWORD PTR [rsp+0x38]
    36b0:	mov    r15,QWORD PTR [rsp+0x40]
    36b5:	add    rsp,0x50
    36b9:	mov    rsp,rbp
    36bc:	pop    rbp
    36bd:	ret
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
    36ec:	sub    rsp,0x30
    36f0:	mov    QWORD PTR [rsp],rbx
    36f4:	mov    QWORD PTR [rsp+0x8],r12
    36f9:	mov    QWORD PTR [rsp+0x10],r13
    36fe:	mov    QWORD PTR [rsp+0x18],r14
    3703:	mov    QWORD PTR [rsp+0x20],r15
    3708:	mov    rbx,QWORD PTR [rdi]
    370b:	mov    rax,QWORD PTR [rdi+0x8]
    370f:	lea    rcx,[rbx+0x20]
    3713:	cmp    rcx,rax
    3716:	ja     3beb <botlish_fn_28+0x503>
    371c:	lea    rax,[rbx+0x20]
    3720:	mov    QWORD PTR [rdi],rax
    3723:	mov    r12,rdi
    3726:	mov    QWORD PTR [rbx+0x10],0x0
    372e:	mov    QWORD PTR [rbx+0x18],0x0
    3736:	mov    QWORD PTR [rbx],rsi
    3739:	mov    r13,rsi
    373c:	mov    QWORD PTR [rbx+0x8],rdx
    3740:	mov    r14,rdx
    3743:	mov    rdx,r14
    3746:	mov    rsi,r13
    3749:	mov    rdi,r12
    374c:	call   3751 <botlish_fn_28+0x69>
			374d: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3751:	test   rax,rax
    3754:	jne    3762 <botlish_fn_28+0x7a>
    375a:	mov    rdi,r12
    375d:	jmp    3b69 <botlish_fn_28+0x481>
    3762:	mov    QWORD PTR [rbx+0x10],rax
    3766:	mov    rcx,rax
    3769:	mov    rdx,r14
    376c:	mov    rsi,r13
    376f:	mov    rdi,r12
    3772:	call   3777 <botlish_fn_28+0x8f>
			3773: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    3777:	mov    rcx,rax
    377a:	mov    r14,rax
    377d:	test   rax,rcx
    3780:	jne    378e <botlish_fn_28+0xa6>
    3786:	mov    rdi,r12
    3789:	jmp    3b69 <botlish_fn_28+0x481>
    378e:	mov    rax,r14
    3791:	mov    QWORD PTR [rbx+0x8],rax
    3795:	test   rax,0x1
    379b:	jne    37c6 <botlish_fn_28+0xde>
    37a1:	mov    edx,0x1
    37a6:	mov    rsi,r14
    37a9:	mov    rdi,r12
    37ac:	call   37b1 <botlish_fn_28+0xc9>
			37ad: R_X86_64_PLT32	rt_int_cmp-0x4
    37b1:	mov    ecx,0x2
    37b6:	test   rax,rax
    37b9:	cmovl  rcx,QWORD PTR [rip+0x457]        # 3c18 <botlish_fn_28+0x530>
    37c1:	jmp    37dc <botlish_fn_28+0xf4>
    37c6:	mov    ecx,0x2
    37cb:	mov    rax,r14
    37ce:	mov    rdx,r14
    37d1:	test   rax,rdx
    37d4:	cmovle rcx,QWORD PTR [rip+0x43c]        # 3c18 <botlish_fn_28+0x530>
    37dc:	cmp    rcx,0x6
    37e0:	je     3bbf <botlish_fn_28+0x4d7>
    37e6:	mov    rsi,r13
    37e9:	mov    rdi,r12
    37ec:	call   37f1 <botlish_fn_28+0x109>
			37ed: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    37f1:	test   rax,rax
    37f4:	jne    3802 <botlish_fn_28+0x11a>
    37fa:	mov    rdi,r12
    37fd:	jmp    3b69 <botlish_fn_28+0x481>
    3802:	mov    QWORD PTR [rbx+0x10],rax
    3806:	mov    r15,rax
    3809:	mov    rdi,r12
    380c:	call   3811 <botlish_fn_28+0x129>
			380d: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    3811:	test   rax,rax
    3814:	mov    rsi,rax
    3817:	jne    3825 <botlish_fn_28+0x13d>
    381d:	mov    rdi,r12
    3820:	jmp    3b69 <botlish_fn_28+0x481>
    3825:	xor    ecx,ecx
    3827:	mov    rax,r15
    382a:	test   rax,0x7
    3830:	je     383e <botlish_fn_28+0x156>
    3836:	mov    r15,rax
    3839:	jmp    384c <botlish_fn_28+0x164>
    383e:	movzx  rdi,BYTE PTR [rax]
    3842:	mov    r15,rax
    3845:	cmp    dil,0x8
    3849:	sete   cl
    384c:	test   cl,cl
    384e:	jne    3874 <botlish_fn_28+0x18c>
    3854:	mov    rdi,r12
    3857:	mov    r11,QWORD PTR [rdi+0x10]
    385b:	mov    rcx,QWORD PTR [r11+0x20]
    385f:	mov    edx,0x8
    3864:	mov    rsi,r15
    3867:	call   386c <botlish_fn_28+0x184>
			3868: R_X86_64_PLT32	rt_type_error-0x4
    386c:	mov    rdi,r12
    386f:	jmp    3b69 <botlish_fn_28+0x481>
    3874:	mov    rcx,rsi
    3877:	mov    rsi,r15
    387a:	mov    rdx,r14
    387d:	mov    rdi,r12
    3880:	call   3885 <botlish_fn_28+0x19d>
			3881: R_X86_64_PLT32	rt_mutarray_set-0x4
    3885:	test   rax,rax
    3888:	jne    3896 <botlish_fn_28+0x1ae>
    388e:	mov    rdi,r12
    3891:	jmp    3b69 <botlish_fn_28+0x481>
    3896:	mov    rsi,r13
    3899:	mov    rdi,r12
    389c:	call   38a1 <botlish_fn_28+0x1b9>
			389d: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    38a1:	test   rax,rax
    38a4:	jne    38b2 <botlish_fn_28+0x1ca>
    38aa:	mov    rdi,r12
    38ad:	jmp    3b69 <botlish_fn_28+0x481>
    38b2:	xor    ecx,ecx
    38b4:	test   rax,0x7
    38ba:	je     38c8 <botlish_fn_28+0x1e0>
    38c0:	mov    rsi,rax
    38c3:	jmp    38d6 <botlish_fn_28+0x1ee>
    38c8:	movzx  rcx,BYTE PTR [rax]
    38cc:	mov    rsi,rax
    38cf:	rex cmp cl,0x8
    38d3:	sete   cl
    38d6:	test   cl,cl
    38d8:	jne    38fb <botlish_fn_28+0x213>
    38de:	mov    rdi,r12
    38e1:	mov    rax,QWORD PTR [rdi+0x10]
    38e5:	mov    rcx,QWORD PTR [rax+0x20]
    38e9:	mov    edx,0x8
    38ee:	call   38f3 <botlish_fn_28+0x20b>
			38ef: R_X86_64_PLT32	rt_type_error-0x4
    38f3:	mov    rdi,r12
    38f6:	jmp    3b69 <botlish_fn_28+0x481>
    38fb:	mov    ecx,0xa
    3900:	mov    rdx,r14
    3903:	mov    rdi,r12
    3906:	call   390b <botlish_fn_28+0x223>
			3907: R_X86_64_PLT32	rt_mutarray_set-0x4
    390b:	test   rax,rax
    390e:	jne    391c <botlish_fn_28+0x234>
    3914:	mov    rdi,r12
    3917:	jmp    3b69 <botlish_fn_28+0x481>
    391c:	mov    rsi,r13
    391f:	mov    rdi,r12
    3922:	call   3927 <botlish_fn_28+0x23f>
			3923: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3927:	test   rax,rax
    392a:	jne    3938 <botlish_fn_28+0x250>
    3930:	mov    rdi,r12
    3933:	jmp    3b69 <botlish_fn_28+0x481>
    3938:	xor    ecx,ecx
    393a:	test   rax,0x7
    3940:	je     394e <botlish_fn_28+0x266>
    3946:	mov    rsi,rax
    3949:	jmp    395c <botlish_fn_28+0x274>
    394e:	movzx  rcx,BYTE PTR [rax]
    3952:	mov    rsi,rax
    3955:	rex cmp cl,0x8
    3959:	sete   cl
    395c:	test   cl,cl
    395e:	jne    3981 <botlish_fn_28+0x299>
    3964:	mov    rdi,r12
    3967:	mov    rax,QWORD PTR [rdi+0x10]
    396b:	mov    rcx,QWORD PTR [rax+0x20]
    396f:	mov    edx,0x8
    3974:	call   3979 <botlish_fn_28+0x291>
			3975: R_X86_64_PLT32	rt_type_error-0x4
    3979:	mov    rdi,r12
    397c:	jmp    3b69 <botlish_fn_28+0x481>
    3981:	mov    ecx,0xa
    3986:	mov    rdx,r14
    3989:	mov    rdi,r12
    398c:	call   3991 <botlish_fn_28+0x2a9>
			398d: R_X86_64_PLT32	rt_mutarray_set-0x4
    3991:	test   rax,rax
    3994:	jne    39a2 <botlish_fn_28+0x2ba>
    399a:	mov    rdi,r12
    399d:	jmp    3b69 <botlish_fn_28+0x481>
    39a2:	mov    QWORD PTR [rbx+0x8],0x7
    39aa:	mov    rsi,r13
    39ad:	mov    rdi,r12
    39b0:	call   39b5 <botlish_fn_28+0x2cd>
			39b1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    39b5:	test   rax,rax
    39b8:	jne    39c6 <botlish_fn_28+0x2de>
    39be:	mov    rdi,r12
    39c1:	jmp    3b69 <botlish_fn_28+0x481>
    39c6:	mov    QWORD PTR [rbx+0x10],rax
    39ca:	mov    QWORD PTR [rbx+0x18],0x3
    39d2:	mov    esi,0x1
    39d7:	test   rax,0x1
    39dd:	je     39eb <botlish_fn_28+0x303>
    39e3:	mov    r8,rax
    39e6:	jmp    3a10 <botlish_fn_28+0x328>
    39eb:	xor    esi,esi
    39ed:	test   rax,0x7
    39f3:	je     3a01 <botlish_fn_28+0x319>
    39f9:	mov    r8,rax
    39fc:	jmp    3a10 <botlish_fn_28+0x328>
    3a01:	movzx  rcx,BYTE PTR [rax]
    3a05:	mov    r8,rax
    3a08:	rex cmp cl,0x1
    3a0c:	sete   sil
    3a10:	test   sil,sil
    3a13:	jne    3a37 <botlish_fn_28+0x34f>
    3a19:	mov    rdi,r12
    3a1c:	mov    rax,QWORD PTR [rdi+0x10]
    3a20:	mov    rcx,QWORD PTR [rax+0x28]
    3a24:	xor    rdx,rdx
    3a27:	mov    rsi,r8
    3a2a:	call   3a2f <botlish_fn_28+0x347>
			3a2b: R_X86_64_PLT32	rt_type_error-0x4
    3a2f:	mov    rdi,r12
    3a32:	jmp    3b69 <botlish_fn_28+0x481>
    3a37:	mov    rsi,r8
    3a3a:	test   rsi,0x1
    3a41:	je     3a5d <botlish_fn_28+0x375>
    3a47:	mov    rax,rsi
    3a4a:	sub    rax,0x3
    3a4e:	seto   dl
    3a51:	lea    rcx,[rax+0x1]
    3a55:	test   dl,dl
    3a57:	je     3a6d <botlish_fn_28+0x385>
    3a5d:	mov    edx,0x3
    3a62:	mov    rdi,r12
    3a65:	call   3a6a <botlish_fn_28+0x382>
			3a66: R_X86_64_PLT32	rt_int_sub-0x4
    3a6a:	mov    rcx,rax
    3a6d:	mov    edx,0x7
    3a72:	mov    rsi,r13
    3a75:	mov    rdi,r12
    3a78:	call   3a7d <botlish_fn_28+0x395>
			3a79: R_X86_64_PLT32	rt_mutarray_set-0x4
    3a7d:	test   rax,rax
    3a80:	jne    3a8e <botlish_fn_28+0x3a6>
    3a86:	mov    rdi,r12
    3a89:	jmp    3b69 <botlish_fn_28+0x481>
    3a8e:	mov    QWORD PTR [rbx+0x8],0x9
    3a96:	mov    rsi,r13
    3a99:	mov    rdi,r12
    3a9c:	call   3aa1 <botlish_fn_28+0x3b9>
			3a9d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3aa1:	test   rax,rax
    3aa4:	jne    3ab2 <botlish_fn_28+0x3ca>
    3aaa:	mov    rdi,r12
    3aad:	jmp    3b69 <botlish_fn_28+0x481>
    3ab2:	mov    QWORD PTR [rbx+0x10],rax
    3ab6:	mov    QWORD PTR [rbx+0x18],0x3
    3abe:	mov    ecx,0x1
    3ac3:	test   rax,0x1
    3ac9:	je     3ad7 <botlish_fn_28+0x3ef>
    3acf:	mov    rsi,rax
    3ad2:	jmp    3afb <botlish_fn_28+0x413>
    3ad7:	xor    ecx,ecx
    3ad9:	test   rax,0x7
    3adf:	je     3aed <botlish_fn_28+0x405>
    3ae5:	mov    rsi,rax
    3ae8:	jmp    3afb <botlish_fn_28+0x413>
    3aed:	movzx  rcx,BYTE PTR [rax]
    3af1:	mov    rsi,rax
    3af4:	rex cmp cl,0x1
    3af8:	sete   cl
    3afb:	test   cl,cl
    3afd:	jne    3b1e <botlish_fn_28+0x436>
    3b03:	mov    rdi,r12
    3b06:	mov    rax,QWORD PTR [rdi+0x10]
    3b0a:	mov    rcx,QWORD PTR [rax+0x10]
    3b0e:	xor    rdx,rdx
    3b11:	call   3b16 <botlish_fn_28+0x42e>
			3b12: R_X86_64_PLT32	rt_type_error-0x4
    3b16:	mov    rdi,r12
    3b19:	jmp    3b69 <botlish_fn_28+0x481>
    3b1e:	test   rsi,0x1
    3b25:	je     3b3d <botlish_fn_28+0x455>
    3b2b:	mov    rcx,rsi
    3b2e:	add    rcx,0x2
    3b32:	seto   al
    3b35:	test   al,al
    3b37:	je     3b4d <botlish_fn_28+0x465>
    3b3d:	mov    edx,0x3
    3b42:	mov    rdi,r12
    3b45:	call   3b4a <botlish_fn_28+0x462>
			3b46: R_X86_64_PLT32	rt_int_add-0x4
    3b4a:	mov    rcx,rax
    3b4d:	mov    edx,0x9
    3b52:	mov    rsi,r13
    3b55:	mov    rdi,r12
    3b58:	call   3b5d <botlish_fn_28+0x475>
			3b59: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b5d:	test   rax,rax
    3b60:	jne    3b93 <botlish_fn_28+0x4ab>
    3b66:	mov    rdi,r12
    3b69:	mov    rdi,r12
    3b6c:	mov    QWORD PTR [rdi],rbx
    3b6f:	xor    rax,rax
    3b72:	mov    rbx,QWORD PTR [rsp]
    3b76:	mov    r12,QWORD PTR [rsp+0x8]
    3b7b:	mov    r13,QWORD PTR [rsp+0x10]
    3b80:	mov    r14,QWORD PTR [rsp+0x18]
    3b85:	mov    r15,QWORD PTR [rsp+0x20]
    3b8a:	add    rsp,0x30
    3b8e:	mov    rsp,rbp
    3b91:	pop    rbp
    3b92:	ret
    3b93:	mov    rdi,r12
    3b96:	mov    QWORD PTR [rdi],rbx
    3b99:	mov    eax,0xa
    3b9e:	mov    rbx,QWORD PTR [rsp]
    3ba2:	mov    r12,QWORD PTR [rsp+0x8]
    3ba7:	mov    r13,QWORD PTR [rsp+0x10]
    3bac:	mov    r14,QWORD PTR [rsp+0x18]
    3bb1:	mov    r15,QWORD PTR [rsp+0x20]
    3bb6:	add    rsp,0x30
    3bba:	mov    rsp,rbp
    3bbd:	pop    rbp
    3bbe:	ret
    3bbf:	mov    rdi,r12
    3bc2:	mov    QWORD PTR [rdi],rbx
    3bc5:	mov    eax,0xa
    3bca:	mov    rbx,QWORD PTR [rsp]
    3bce:	mov    r12,QWORD PTR [rsp+0x8]
    3bd3:	mov    r13,QWORD PTR [rsp+0x10]
    3bd8:	mov    r14,QWORD PTR [rsp+0x18]
    3bdd:	mov    r15,QWORD PTR [rsp+0x20]
    3be2:	add    rsp,0x30
    3be6:	mov    rsp,rbp
    3be9:	pop    rbp
    3bea:	ret
    3beb:	mov    r12,rdi
    3bee:	call   3bf3 <botlish_fn_28+0x50b>
			3bef: R_X86_64_PLT32	rt_stack_overflow-0x4
    3bf3:	xor    rax,rax
    3bf6:	mov    rbx,QWORD PTR [rsp]
    3bfa:	mov    r12,QWORD PTR [rsp+0x8]
    3bff:	mov    r13,QWORD PTR [rsp+0x10]
    3c04:	mov    r14,QWORD PTR [rsp+0x18]
    3c09:	mov    r15,QWORD PTR [rsp+0x20]
    3c0e:	add    rsp,0x30
    3c12:	mov    rsp,rbp
    3c15:	pop    rbp
    3c16:	ret
    3c17:	add    BYTE PTR [rsi],al
    3c19:	add    BYTE PTR [rax],al
    3c1b:	add    BYTE PTR [rax],al
    3c1d:	add    BYTE PTR [rax],al
	...

0000000000003c20 <botlish_entry_28: ht_delete<mutarray, str>>:
    3c20:	push   rbp
    3c21:	mov    rbp,rsp
    3c24:	mov    rsi,QWORD PTR [rdx]
    3c27:	mov    rdx,QWORD PTR [rdx+0x8]
    3c2b:	call   3c30 <botlish_entry_28+0x10>
			3c2c: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3c30:	mov    rsp,rbp
    3c33:	pop    rbp
    3c34:	ret
    3c35:	add    BYTE PTR [rax],al
	...

0000000000003c38 <botlish_fn_29: sample<generic>>:
    3c38:	push   rbp
    3c39:	mov    rbp,rsp
    3c3c:	sub    rsp,0x70
    3c40:	mov    QWORD PTR [rsp+0x40],rbx
    3c45:	mov    QWORD PTR [rsp+0x48],r12
    3c4a:	mov    QWORD PTR [rsp+0x50],r13
    3c4f:	mov    QWORD PTR [rsp+0x58],r14
    3c54:	mov    QWORD PTR [rsp+0x60],r15
    3c59:	mov    r12,QWORD PTR [rdi]
    3c5c:	mov    rax,QWORD PTR [rdi+0x8]
    3c60:	lea    rcx,[r12+0x30]
    3c65:	cmp    rcx,rax
    3c68:	ja     3ff4 <botlish_fn_29+0x3bc>
    3c6e:	lea    rax,[r12+0x30]
    3c73:	mov    QWORD PTR [rdi],rax
    3c76:	mov    QWORD PTR [rsp+0x30],rdi
    3c7b:	mov    QWORD PTR [r12],0x0
    3c83:	mov    QWORD PTR [r12+0x8],0x0
    3c8c:	mov    QWORD PTR [r12+0x10],0x0
    3c95:	mov    QWORD PTR [r12+0x18],0x0
    3c9e:	mov    QWORD PTR [r12+0x20],0x0
    3ca7:	mov    QWORD PTR [r12+0x28],0x0
    3cb0:	mov    rdi,QWORD PTR [rsp+0x30]
    3cb5:	call   3cba <botlish_fn_29+0x82>
			3cb6: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    3cba:	mov    rbx,rax
    3cbd:	test   rbx,rbx
    3cc0:	jne    3cd0 <botlish_fn_29+0x98>
    3cc6:	mov    rdi,QWORD PTR [rsp+0x30]
    3ccb:	jmp    3f9d <botlish_fn_29+0x365>
    3cd0:	mov    QWORD PTR [r12],rbx
    3cd4:	mov    rdi,QWORD PTR [rsp+0x30]
    3cd9:	mov    r9,QWORD PTR [rdi+0x10]
    3cdd:	mov    rdx,QWORD PTR [r9+0x30]
    3ce1:	mov    QWORD PTR [r12+0x8],rdx
    3ce6:	mov    r10,QWORD PTR [rdi+0x10]
    3cea:	mov    rcx,QWORD PTR [r10+0x38]
    3cee:	mov    QWORD PTR [r12+0x10],rcx
    3cf3:	mov    rsi,rbx
    3cf6:	call   3cfb <botlish_fn_29+0xc3>
			3cf7: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3cfb:	test   rax,rax
    3cfe:	jne    3d0e <botlish_fn_29+0xd6>
    3d04:	mov    rdi,QWORD PTR [rsp+0x30]
    3d09:	jmp    3f9d <botlish_fn_29+0x365>
    3d0e:	mov    rdi,QWORD PTR [rsp+0x30]
    3d13:	mov    rax,QWORD PTR [rdi+0x10]
    3d17:	mov    rdx,QWORD PTR [rax+0x40]
    3d1b:	mov    QWORD PTR [r12+0x8],rdx
    3d20:	mov    rax,QWORD PTR [rdi+0x10]
    3d24:	mov    rcx,QWORD PTR [rax+0x48]
    3d28:	mov    QWORD PTR [r12+0x10],rcx
    3d2d:	mov    rsi,rbx
    3d30:	call   3d35 <botlish_fn_29+0xfd>
			3d31: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3d35:	test   rax,rax
    3d38:	jne    3d48 <botlish_fn_29+0x110>
    3d3e:	mov    rdi,QWORD PTR [rsp+0x30]
    3d43:	jmp    3f9d <botlish_fn_29+0x365>
    3d48:	mov    rdi,QWORD PTR [rsp+0x30]
    3d4d:	mov    rax,QWORD PTR [rdi+0x10]
    3d51:	mov    rdx,QWORD PTR [rax+0x30]
    3d55:	mov    QWORD PTR [r12+0x8],rdx
    3d5a:	mov    rax,QWORD PTR [rdi+0x10]
    3d5e:	mov    rcx,QWORD PTR [rax+0x50]
    3d62:	mov    QWORD PTR [r12+0x10],rcx
    3d67:	mov    rsi,rbx
    3d6a:	call   3d6f <botlish_fn_29+0x137>
			3d6b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3d6f:	test   rax,rax
    3d72:	jne    3d82 <botlish_fn_29+0x14a>
    3d78:	mov    rdi,QWORD PTR [rsp+0x30]
    3d7d:	jmp    3f9d <botlish_fn_29+0x365>
    3d82:	mov    rdi,QWORD PTR [rsp+0x30]
    3d87:	mov    rax,QWORD PTR [rdi+0x10]
    3d8b:	mov    rdx,QWORD PTR [rax+0x40]
    3d8f:	mov    QWORD PTR [r12+0x8],rdx
    3d94:	mov    rsi,rbx
    3d97:	call   3d9c <botlish_fn_29+0x164>
			3d98: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3d9c:	mov    r8,rax
    3d9f:	test   r8,r8
    3da2:	jne    3db2 <botlish_fn_29+0x17a>
    3da8:	mov    rdi,QWORD PTR [rsp+0x30]
    3dad:	jmp    3f9d <botlish_fn_29+0x365>
    3db2:	mov    QWORD PTR [r12+0x8],r8
    3db7:	mov    rdi,QWORD PTR [rsp+0x30]
    3dbc:	mov    QWORD PTR [rsp+0x38],r8
    3dc1:	mov    rax,QWORD PTR [rdi+0x10]
    3dc5:	mov    rdx,QWORD PTR [rax+0x40]
    3dc9:	mov    QWORD PTR [r12+0x10],rdx
    3dce:	mov    rsi,rbx
    3dd1:	call   3dd6 <botlish_fn_29+0x19e>
			3dd2: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3dd6:	test   rax,rax
    3dd9:	jne    3de9 <botlish_fn_29+0x1b1>
    3ddf:	mov    rdi,QWORD PTR [rsp+0x30]
    3de4:	jmp    3f9d <botlish_fn_29+0x365>
    3de9:	mov    rdi,QWORD PTR [rsp+0x30]
    3dee:	mov    rax,QWORD PTR [rdi+0x10]
    3df2:	mov    rdx,QWORD PTR [rax+0x30]
    3df6:	mov    QWORD PTR [r12+0x10],rdx
    3dfb:	mov    rsi,rbx
    3dfe:	call   3e03 <botlish_fn_29+0x1cb>
			3dff: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    3e03:	test   rax,rax
    3e06:	jne    3e16 <botlish_fn_29+0x1de>
    3e0c:	mov    rdi,QWORD PTR [rsp+0x30]
    3e11:	jmp    3f9d <botlish_fn_29+0x365>
    3e16:	mov    rdi,QWORD PTR [rsp+0x30]
    3e1b:	mov    rcx,QWORD PTR [rdi+0x10]
    3e1f:	mov    rdx,QWORD PTR [rcx+0x50]
    3e23:	mov    rcx,rax
    3e26:	and    rcx,rdx
    3e29:	mov    rsi,rax
    3e2c:	test   rcx,0x1
    3e33:	jne    3e59 <botlish_fn_29+0x221>
    3e39:	mov    rdi,QWORD PTR [rsp+0x30]
    3e3e:	call   3e43 <botlish_fn_29+0x20b>
			3e3f: R_X86_64_PLT32	rt_value_eq-0x4
    3e43:	mov    r13,rax
    3e46:	test   r13,r13
    3e49:	jne    3e6a <botlish_fn_29+0x232>
    3e4f:	mov    rdi,QWORD PTR [rsp+0x30]
    3e54:	jmp    3f9d <botlish_fn_29+0x365>
    3e59:	mov    r13d,0x2
    3e5f:	cmp    rsi,rdx
    3e62:	cmove  r13,QWORD PTR [rip+0x1be]        # 4028 <botlish_fn_29+0x3f0>
    3e6a:	mov    QWORD PTR [r12+0x10],r13
    3e6f:	mov    rdi,QWORD PTR [rsp+0x30]
    3e74:	mov    rax,QWORD PTR [rdi+0x10]
    3e78:	mov    rdx,QWORD PTR [rax+0x40]
    3e7c:	mov    QWORD PTR [r12+0x18],rdx
    3e81:	mov    rsi,rbx
    3e84:	call   3e89 <botlish_fn_29+0x251>
			3e85: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3e89:	mov    r14,rax
    3e8c:	test   r14,r14
    3e8f:	jne    3e9f <botlish_fn_29+0x267>
    3e95:	mov    rdi,QWORD PTR [rsp+0x30]
    3e9a:	jmp    3f9d <botlish_fn_29+0x365>
    3e9f:	mov    QWORD PTR [r12+0x18],r14
    3ea4:	mov    rdi,QWORD PTR [rsp+0x30]
    3ea9:	mov    rax,QWORD PTR [rdi+0x10]
    3ead:	mov    rdx,QWORD PTR [rax+0x58]
    3eb1:	mov    QWORD PTR [r12+0x20],rdx
    3eb6:	mov    rsi,rbx
    3eb9:	call   3ebe <botlish_fn_29+0x286>
			3eba: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3ebe:	mov    r15,rax
    3ec1:	test   r15,r15
    3ec4:	jne    3ed4 <botlish_fn_29+0x29c>
    3eca:	mov    rdi,QWORD PTR [rsp+0x30]
    3ecf:	jmp    3f9d <botlish_fn_29+0x365>
    3ed4:	mov    QWORD PTR [r12+0x20],r15
    3ed9:	mov    rdi,QWORD PTR [rsp+0x30]
    3ede:	mov    rax,QWORD PTR [rdi+0x10]
    3ee2:	mov    rdx,QWORD PTR [rax+0x58]
    3ee6:	mov    QWORD PTR [r12+0x28],rdx
    3eeb:	mov    rsi,rbx
    3eee:	call   3ef3 <botlish_fn_29+0x2bb>
			3eef: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    3ef3:	test   rax,rax
    3ef6:	mov    rsi,rax
    3ef9:	jne    3f09 <botlish_fn_29+0x2d1>
    3eff:	mov    rdi,QWORD PTR [rsp+0x30]
    3f04:	jmp    3f9d <botlish_fn_29+0x365>
    3f09:	mov    edx,0xa
    3f0e:	mov    rdi,QWORD PTR [rsp+0x30]
    3f13:	call   3f18 <botlish_fn_29+0x2e0>
			3f14: R_X86_64_PLT32	rt_value_eq-0x4
    3f18:	test   rax,rax
    3f1b:	jne    3f2b <botlish_fn_29+0x2f3>
    3f21:	mov    rdi,QWORD PTR [rsp+0x30]
    3f26:	jmp    3f9d <botlish_fn_29+0x365>
    3f2b:	mov    QWORD PTR [r12+0x28],rax
    3f30:	mov    rsi,rbx
    3f33:	mov    rbx,rax
    3f36:	mov    rdi,QWORD PTR [rsp+0x30]
    3f3b:	call   3f40 <botlish_fn_29+0x308>
			3f3c: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3f40:	test   rax,rax
    3f43:	jne    3f53 <botlish_fn_29+0x31b>
    3f49:	mov    rdi,QWORD PTR [rsp+0x30]
    3f4e:	jmp    3f9d <botlish_fn_29+0x365>
    3f53:	mov    QWORD PTR [r12],rax
    3f57:	lea    rdx,[rsp]
    3f5b:	mov    QWORD PTR [rsp],r13
    3f5f:	mov    r8,QWORD PTR [rsp+0x38]
    3f64:	mov    QWORD PTR [rsp+0x8],r8
    3f69:	mov    QWORD PTR [rsp+0x10],r14
    3f6e:	mov    QWORD PTR [rsp+0x18],r15
    3f73:	mov    rcx,rbx
    3f76:	mov    QWORD PTR [rsp+0x20],rcx
    3f7b:	mov    QWORD PTR [rsp+0x28],rax
    3f80:	mov    esi,0x6
    3f85:	mov    rdi,QWORD PTR [rsp+0x30]
    3f8a:	call   3f8f <botlish_fn_29+0x357>
			3f8b: R_X86_64_PLT32	rt_list_new-0x4
    3f8f:	test   rax,rax
    3f92:	jne    3fca <botlish_fn_29+0x392>
    3f98:	mov    rdi,QWORD PTR [rsp+0x30]
    3f9d:	mov    rdi,QWORD PTR [rsp+0x30]
    3fa2:	mov    QWORD PTR [rdi],r12
    3fa5:	xor    rax,rax
    3fa8:	mov    rbx,QWORD PTR [rsp+0x40]
    3fad:	mov    r12,QWORD PTR [rsp+0x48]
    3fb2:	mov    r13,QWORD PTR [rsp+0x50]
    3fb7:	mov    r14,QWORD PTR [rsp+0x58]
    3fbc:	mov    r15,QWORD PTR [rsp+0x60]
    3fc1:	add    rsp,0x70
    3fc5:	mov    rsp,rbp
    3fc8:	pop    rbp
    3fc9:	ret
    3fca:	mov    rdi,QWORD PTR [rsp+0x30]
    3fcf:	mov    QWORD PTR [rdi],r12
    3fd2:	mov    rbx,QWORD PTR [rsp+0x40]
    3fd7:	mov    r12,QWORD PTR [rsp+0x48]
    3fdc:	mov    r13,QWORD PTR [rsp+0x50]
    3fe1:	mov    r14,QWORD PTR [rsp+0x58]
    3fe6:	mov    r15,QWORD PTR [rsp+0x60]
    3feb:	add    rsp,0x70
    3fef:	mov    rsp,rbp
    3ff2:	pop    rbp
    3ff3:	ret
    3ff4:	mov    QWORD PTR [rsp+0x30],rdi
    3ff9:	call   3ffe <botlish_fn_29+0x3c6>
			3ffa: R_X86_64_PLT32	rt_stack_overflow-0x4
    3ffe:	xor    rax,rax
    4001:	mov    rbx,QWORD PTR [rsp+0x40]
    4006:	mov    r12,QWORD PTR [rsp+0x48]
    400b:	mov    r13,QWORD PTR [rsp+0x50]
    4010:	mov    r14,QWORD PTR [rsp+0x58]
    4015:	mov    r15,QWORD PTR [rsp+0x60]
    401a:	add    rsp,0x70
    401e:	mov    rsp,rbp
    4021:	pop    rbp
    4022:	ret
    4023:	add    BYTE PTR [rax],al
    4025:	add    BYTE PTR [rax],al
    4027:	add    BYTE PTR [rsi],al
    4029:	add    BYTE PTR [rax],al
    402b:	add    BYTE PTR [rax],al
    402d:	add    BYTE PTR [rax],al
	...

0000000000004030 <botlish_entry_29: sample<generic>>:
    4030:	push   rbp
    4031:	mov    rbp,rsp
    4034:	call   4039 <botlish_entry_29+0x9>
			4035: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    4039:	mov    rsp,rbp
    403c:	pop    rbp
    403d:	ret

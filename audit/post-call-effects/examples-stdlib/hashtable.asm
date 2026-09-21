; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 13166  (per function: 45 28 28 28 28 396 524 99 61 61 61 61 61 167 179 245 820 1264 429 253 412 444 1129 766 817 665 1176 860 1221 838)
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
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
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

000000000000002d <botlish_fn_1: ht_min_capacity<generic>>:
      2d:	push   rbp
      2e:	mov    rbp,rsp
      31:	mov    eax,0x11
      36:	mov    rsp,rbp
      39:	pop    rbp
      3a:	ret

000000000000003b <botlish_entry_1: ht_min_capacity<generic>>:
      3b:	push   rbp
      3c:	mov    rbp,rsp
      3f:	call   44 <botlish_entry_1+0x9>
			40: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
      44:	mov    rsp,rbp
      47:	pop    rbp
      48:	ret

0000000000000049 <botlish_fn_2: ht_empty_state<generic>>:
      49:	push   rbp
      4a:	mov    rbp,rsp
      4d:	mov    eax,0x1
      52:	mov    rsp,rbp
      55:	pop    rbp
      56:	ret

0000000000000057 <botlish_entry_2: ht_empty_state<generic>>:
      57:	push   rbp
      58:	mov    rbp,rsp
      5b:	call   60 <botlish_entry_2+0x9>
			5c: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
      60:	mov    rsp,rbp
      63:	pop    rbp
      64:	ret

0000000000000065 <botlish_fn_3: ht_occupied_state<generic>>:
      65:	push   rbp
      66:	mov    rbp,rsp
      69:	mov    eax,0x3
      6e:	mov    rsp,rbp
      71:	pop    rbp
      72:	ret

0000000000000073 <botlish_entry_3: ht_occupied_state<generic>>:
      73:	push   rbp
      74:	mov    rbp,rsp
      77:	call   7c <botlish_entry_3+0x9>
			78: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
      7c:	mov    rsp,rbp
      7f:	pop    rbp
      80:	ret

0000000000000081 <botlish_fn_4: ht_tombstone_state<generic>>:
      81:	push   rbp
      82:	mov    rbp,rsp
      85:	mov    eax,0x5
      8a:	mov    rsp,rbp
      8d:	pop    rbp
      8e:	ret

000000000000008f <botlish_entry_4: ht_tombstone_state<generic>>:
      8f:	push   rbp
      90:	mov    rbp,rsp
      93:	call   98 <botlish_entry_4+0x9>
			94: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
      98:	mov    rsp,rbp
      9b:	pop    rbp
      9c:	ret
      9d:	add    BYTE PTR [rax],al
	...

00000000000000a0 <botlish_fn_5: ht_fill_empty<mutarray, int, int>>:
      a0:	push   rbp
      a1:	mov    rbp,rsp
      a4:	sub    rsp,0x40
      a8:	mov    QWORD PTR [rsp+0x20],rbx
      ad:	mov    QWORD PTR [rsp+0x28],r12
      b2:	mov    QWORD PTR [rsp+0x30],r13
      b7:	mov    QWORD PTR [rsp+0x38],r14
      bc:	mov    r13,rdi
      bf:	mov    QWORD PTR [rsp],rsi
      c3:	mov    rbx,rsi
      c6:	mov    QWORD PTR [rsp+0x8],rdx
      cb:	mov    QWORD PTR [rsp+0x10],rcx
      d0:	mov    r12,rcx
      d3:	mov    rsi,rdx
      d6:	mov    rax,rsi
      d9:	and    rax,r12
      dc:	mov    r14,rsi
      df:	test   rax,0x1
      e5:	jne    10e <botlish_fn_5+0x6e>
      eb:	mov    rdx,r12
      ee:	mov    rsi,r14
      f1:	mov    rdi,r13
      f4:	call   f9 <botlish_fn_5+0x59>
			f5: R_X86_64_PLT32	rt_int_cmp-0x4
      f9:	mov    ecx,0x2
      fe:	test   rax,rax
     101:	cmovge rcx,QWORD PTR [rip+0xe7]        # 1f0 <botlish_fn_5+0x150>
     109:	jmp    121 <botlish_fn_5+0x81>
     10e:	mov    ecx,0x2
     113:	mov    rsi,r14
     116:	cmp    rsi,r12
     119:	cmovge rcx,QWORD PTR [rip+0xcf]        # 1f0 <botlish_fn_5+0x150>
     121:	cmp    rcx,0x6
     125:	je     1ce <botlish_fn_5+0x12e>
     12b:	mov    rdi,r13
     12e:	call   133 <botlish_fn_5+0x93>
			12f: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     133:	mov    ecx,0x1
     138:	mov    rdx,r14
     13b:	mov    rsi,rbx
     13e:	mov    rdi,r13
     141:	call   146 <botlish_fn_5+0xa6>
			142: R_X86_64_PLT32	rt_mutarray_set-0x4
     146:	test   rax,rax
     149:	jne    16f <botlish_fn_5+0xcf>
     14f:	xor    rax,rax
     152:	mov    rbx,QWORD PTR [rsp+0x20]
     157:	mov    r12,QWORD PTR [rsp+0x28]
     15c:	mov    r13,QWORD PTR [rsp+0x30]
     161:	mov    r14,QWORD PTR [rsp+0x38]
     166:	add    rsp,0x40
     16a:	mov    rsp,rbp
     16d:	pop    rbp
     16e:	ret
     16f:	mov    QWORD PTR [rsp+0x18],0x3
     178:	mov    rsi,r14
     17b:	test   rsi,0x1
     182:	je     1a5 <botlish_fn_5+0x105>
     188:	mov    rsi,r14
     18b:	mov    rcx,rsi
     18e:	add    rcx,0x2
     192:	seto   al
     195:	test   al,al
     197:	jne    1a5 <botlish_fn_5+0x105>
     19d:	mov    r14,rcx
     1a0:	jmp    1b8 <botlish_fn_5+0x118>
     1a5:	mov    edx,0x3
     1aa:	mov    rsi,r14
     1ad:	mov    rdi,r13
     1b0:	call   1b5 <botlish_fn_5+0x115>
			1b1: R_X86_64_PLT32	rt_int_add-0x4
     1b5:	mov    r14,rax
     1b8:	mov    QWORD PTR [rsp],rbx
     1bc:	mov    rsi,r14
     1bf:	mov    QWORD PTR [rsp+0x8],rsi
     1c4:	mov    QWORD PTR [rsp+0x10],r12
     1c9:	jmp    d6 <botlish_fn_5+0x36>
     1ce:	mov    eax,0xa
     1d3:	mov    rbx,QWORD PTR [rsp+0x20]
     1d8:	mov    r12,QWORD PTR [rsp+0x28]
     1dd:	mov    r13,QWORD PTR [rsp+0x30]
     1e2:	mov    r14,QWORD PTR [rsp+0x38]
     1e7:	add    rsp,0x40
     1eb:	mov    rsp,rbp
     1ee:	pop    rbp
     1ef:	ret
     1f0:	(bad)
     1f1:	add    BYTE PTR [rax],al
     1f3:	add    BYTE PTR [rax],al
     1f5:	add    BYTE PTR [rax],al
	...

00000000000001f8 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     1f8:	push   rbp
     1f9:	mov    rbp,rsp
     1fc:	mov    rsi,QWORD PTR [rdx]
     1ff:	mov    r8,QWORD PTR [rdx+0x8]
     203:	mov    rcx,QWORD PTR [rdx+0x10]
     207:	mov    rdx,r8
     20a:	call   20f <botlish_entry_5+0x17>
			20b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     20f:	mov    rsp,rbp
     212:	pop    rbp
     213:	ret

0000000000000214 <botlish_fn_6: ht_alloc<int>>:
     214:	push   rbp
     215:	mov    rbp,rsp
     218:	sub    rsp,0x50
     21c:	mov    QWORD PTR [rsp+0x20],rbx
     221:	mov    QWORD PTR [rsp+0x28],r12
     226:	mov    QWORD PTR [rsp+0x30],r13
     22b:	mov    QWORD PTR [rsp+0x38],r14
     230:	mov    QWORD PTR [rsp+0x40],r15
     235:	mov    rbx,rdi
     238:	mov    QWORD PTR [rsp+0x8],0x0
     241:	mov    QWORD PTR [rsp+0x10],0x0
     24a:	mov    QWORD PTR [rsp+0x18],0x0
     253:	mov    QWORD PTR [rsp],rsi
     257:	mov    r13,rsi
     25a:	mov    rsi,r13
     25d:	mov    rdi,rbx
     260:	call   265 <botlish_fn_6+0x51>
			261: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     265:	test   rax,rax
     268:	je     384 <botlish_fn_6+0x170>
     26e:	mov    QWORD PTR [rsp+0x8],rax
     273:	mov    r12,rax
     276:	mov    edx,0x1
     27b:	mov    QWORD PTR [rsp+0x10],0x1
     284:	mov    rcx,r13
     287:	mov    rsi,r12
     28a:	mov    rdi,rbx
     28d:	call   292 <botlish_fn_6+0x7e>
			28e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     292:	test   rax,rax
     295:	je     384 <botlish_fn_6+0x170>
     29b:	mov    rsi,r13
     29e:	mov    rdi,rbx
     2a1:	call   2a6 <botlish_fn_6+0x92>
			2a2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2a6:	test   rax,rax
     2a9:	je     384 <botlish_fn_6+0x170>
     2af:	mov    QWORD PTR [rsp+0x10],rax
     2b4:	mov    rsi,r13
     2b7:	mov    r14,rax
     2ba:	mov    rdi,rbx
     2bd:	call   2c2 <botlish_fn_6+0xae>
			2be: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2c2:	test   rax,rax
     2c5:	je     384 <botlish_fn_6+0x170>
     2cb:	mov    QWORD PTR [rsp],rax
     2cf:	mov    r13,rax
     2d2:	mov    esi,0xb
     2d7:	mov    QWORD PTR [rsp+0x18],0xb
     2e0:	mov    rdi,rbx
     2e3:	call   2e8 <botlish_fn_6+0xd4>
			2e4: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2e8:	test   rax,rax
     2eb:	mov    r15,rax
     2ee:	je     384 <botlish_fn_6+0x170>
     2f4:	mov    edx,0x1
     2f9:	mov    rcx,r12
     2fc:	mov    rsi,r15
     2ff:	mov    rdi,rbx
     302:	call   307 <botlish_fn_6+0xf3>
			303: R_X86_64_PLT32	rt_mutarray_set-0x4
     307:	test   rax,rax
     30a:	je     384 <botlish_fn_6+0x170>
     310:	mov    edx,0x3
     315:	mov    rcx,r14
     318:	mov    rsi,r15
     31b:	mov    rdi,rbx
     31e:	call   323 <botlish_fn_6+0x10f>
			31f: R_X86_64_PLT32	rt_mutarray_set-0x4
     323:	test   rax,rax
     326:	je     384 <botlish_fn_6+0x170>
     32c:	mov    edx,0x5
     331:	mov    rcx,r13
     334:	mov    rsi,r15
     337:	mov    rdi,rbx
     33a:	call   33f <botlish_fn_6+0x12b>
			33b: R_X86_64_PLT32	rt_mutarray_set-0x4
     33f:	test   rax,rax
     342:	je     384 <botlish_fn_6+0x170>
     348:	mov    edx,0x7
     34d:	mov    ecx,0x1
     352:	mov    rsi,r15
     355:	mov    rdi,rbx
     358:	call   35d <botlish_fn_6+0x149>
			359: R_X86_64_PLT32	rt_mutarray_set-0x4
     35d:	test   rax,rax
     360:	je     384 <botlish_fn_6+0x170>
     366:	mov    edx,0x9
     36b:	mov    ecx,0x1
     370:	mov    rdi,rbx
     373:	mov    rsi,r15
     376:	call   37b <botlish_fn_6+0x167>
			377: R_X86_64_PLT32	rt_mutarray_set-0x4
     37b:	test   rax,rax
     37e:	jne    3a9 <botlish_fn_6+0x195>
     384:	xor    rax,rax
     387:	mov    rbx,QWORD PTR [rsp+0x20]
     38c:	mov    r12,QWORD PTR [rsp+0x28]
     391:	mov    r13,QWORD PTR [rsp+0x30]
     396:	mov    r14,QWORD PTR [rsp+0x38]
     39b:	mov    r15,QWORD PTR [rsp+0x40]
     3a0:	add    rsp,0x50
     3a4:	mov    rsp,rbp
     3a7:	pop    rbp
     3a8:	ret
     3a9:	mov    rax,r15
     3ac:	mov    rbx,QWORD PTR [rsp+0x20]
     3b1:	mov    r12,QWORD PTR [rsp+0x28]
     3b6:	mov    r13,QWORD PTR [rsp+0x30]
     3bb:	mov    r14,QWORD PTR [rsp+0x38]
     3c0:	mov    r15,QWORD PTR [rsp+0x40]
     3c5:	add    rsp,0x50
     3c9:	mov    rsp,rbp
     3cc:	pop    rbp
     3cd:	ret

00000000000003ce <botlish_entry_6: ht_alloc<int>>:
     3ce:	push   rbp
     3cf:	mov    rbp,rsp
     3d2:	mov    rsi,QWORD PTR [rdx]
     3d5:	call   3da <botlish_entry_6+0xc>
			3d6: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     3da:	mov    rsp,rbp
     3dd:	pop    rbp
     3de:	ret

00000000000003df <botlish_fn_7: ht_new<generic>>:
     3df:	push   rbp
     3e0:	mov    rbp,rsp
     3e3:	sub    rsp,0x20
     3e7:	mov    QWORD PTR [rsp+0x10],r12
     3ec:	mov    r12,rdi
     3ef:	mov    rdi,r12
     3f2:	call   3f7 <botlish_fn_7+0x18>
			3f3: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     3f7:	mov    esi,0x11
     3fc:	mov    QWORD PTR [rsp],0x11
     404:	mov    rdi,r12
     407:	call   40c <botlish_fn_7+0x2d>
			408: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     40c:	test   rax,rax
     40f:	jne    426 <botlish_fn_7+0x47>
     415:	xor    rax,rax
     418:	mov    r12,QWORD PTR [rsp+0x10]
     41d:	add    rsp,0x20
     421:	mov    rsp,rbp
     424:	pop    rbp
     425:	ret
     426:	mov    r12,QWORD PTR [rsp+0x10]
     42b:	add    rsp,0x20
     42f:	mov    rsp,rbp
     432:	pop    rbp
     433:	ret

0000000000000434 <botlish_entry_7: ht_new<generic>>:
     434:	push   rbp
     435:	mov    rbp,rsp
     438:	call   43d <botlish_entry_7+0x9>
			439: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     43d:	mov    rsp,rbp
     440:	pop    rbp
     441:	ret

0000000000000442 <botlish_fn_8: ht_controls<mutarray>>:
     442:	push   rbp
     443:	mov    rbp,rsp
     446:	mov    edx,0x1
     44b:	call   450 <botlish_fn_8+0xe>
			44c: R_X86_64_PLT32	rt_mutarray_get-0x4
     450:	test   rax,rax
     453:	jne    461 <botlish_fn_8+0x1f>
     459:	xor    rax,rax
     45c:	mov    rsp,rbp
     45f:	pop    rbp
     460:	ret
     461:	mov    rsp,rbp
     464:	pop    rbp
     465:	ret

0000000000000466 <botlish_entry_8: ht_controls<mutarray>>:
     466:	push   rbp
     467:	mov    rbp,rsp
     46a:	mov    rsi,QWORD PTR [rdx]
     46d:	call   472 <botlish_entry_8+0xc>
			46e: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     472:	mov    rsp,rbp
     475:	pop    rbp
     476:	ret

0000000000000477 <botlish_fn_9: ht_keys<mutarray>>:
     477:	push   rbp
     478:	mov    rbp,rsp
     47b:	mov    edx,0x3
     480:	call   485 <botlish_fn_9+0xe>
			481: R_X86_64_PLT32	rt_mutarray_get-0x4
     485:	test   rax,rax
     488:	jne    496 <botlish_fn_9+0x1f>
     48e:	xor    rax,rax
     491:	mov    rsp,rbp
     494:	pop    rbp
     495:	ret
     496:	mov    rsp,rbp
     499:	pop    rbp
     49a:	ret

000000000000049b <botlish_entry_9: ht_keys<mutarray>>:
     49b:	push   rbp
     49c:	mov    rbp,rsp
     49f:	mov    rsi,QWORD PTR [rdx]
     4a2:	call   4a7 <botlish_entry_9+0xc>
			4a3: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     4a7:	mov    rsp,rbp
     4aa:	pop    rbp
     4ab:	ret

00000000000004ac <botlish_fn_10: ht_values<mutarray>>:
     4ac:	push   rbp
     4ad:	mov    rbp,rsp
     4b0:	mov    edx,0x5
     4b5:	call   4ba <botlish_fn_10+0xe>
			4b6: R_X86_64_PLT32	rt_mutarray_get-0x4
     4ba:	test   rax,rax
     4bd:	jne    4cb <botlish_fn_10+0x1f>
     4c3:	xor    rax,rax
     4c6:	mov    rsp,rbp
     4c9:	pop    rbp
     4ca:	ret
     4cb:	mov    rsp,rbp
     4ce:	pop    rbp
     4cf:	ret

00000000000004d0 <botlish_entry_10: ht_values<mutarray>>:
     4d0:	push   rbp
     4d1:	mov    rbp,rsp
     4d4:	mov    rsi,QWORD PTR [rdx]
     4d7:	call   4dc <botlish_entry_10+0xc>
			4d8: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     4dc:	mov    rsp,rbp
     4df:	pop    rbp
     4e0:	ret

00000000000004e1 <botlish_fn_11: ht_size<mutarray>>:
     4e1:	push   rbp
     4e2:	mov    rbp,rsp
     4e5:	mov    edx,0x7
     4ea:	call   4ef <botlish_fn_11+0xe>
			4eb: R_X86_64_PLT32	rt_mutarray_get-0x4
     4ef:	test   rax,rax
     4f2:	jne    500 <botlish_fn_11+0x1f>
     4f8:	xor    rax,rax
     4fb:	mov    rsp,rbp
     4fe:	pop    rbp
     4ff:	ret
     500:	mov    rsp,rbp
     503:	pop    rbp
     504:	ret

0000000000000505 <botlish_entry_11: ht_size<mutarray>>:
     505:	push   rbp
     506:	mov    rbp,rsp
     509:	mov    rsi,QWORD PTR [rdx]
     50c:	call   511 <botlish_entry_11+0xc>
			50d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     511:	mov    rsp,rbp
     514:	pop    rbp
     515:	ret

0000000000000516 <botlish_fn_12: ht_tombstones<mutarray>>:
     516:	push   rbp
     517:	mov    rbp,rsp
     51a:	mov    edx,0x9
     51f:	call   524 <botlish_fn_12+0xe>
			520: R_X86_64_PLT32	rt_mutarray_get-0x4
     524:	test   rax,rax
     527:	jne    535 <botlish_fn_12+0x1f>
     52d:	xor    rax,rax
     530:	mov    rsp,rbp
     533:	pop    rbp
     534:	ret
     535:	mov    rsp,rbp
     538:	pop    rbp
     539:	ret

000000000000053a <botlish_entry_12: ht_tombstones<mutarray>>:
     53a:	push   rbp
     53b:	mov    rbp,rsp
     53e:	mov    rsi,QWORD PTR [rdx]
     541:	call   546 <botlish_entry_12+0xc>
			542: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     546:	mov    rsp,rbp
     549:	pop    rbp
     54a:	ret

000000000000054b <botlish_fn_13: ht_capacity<mutarray>>:
     54b:	push   rbp
     54c:	mov    rbp,rsp
     54f:	sub    rsp,0x10
     553:	mov    QWORD PTR [rsp],rbx
     557:	mov    rbx,rdi
     55a:	mov    rdi,rbx
     55d:	call   562 <botlish_fn_13+0x17>
			55e: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     562:	test   rax,rax
     565:	je     5ae <botlish_fn_13+0x63>
     56b:	xor    r8d,r8d
     56e:	test   rax,0x7
     574:	je     582 <botlish_fn_13+0x37>
     57a:	mov    rsi,rax
     57d:	jmp    591 <botlish_fn_13+0x46>
     582:	movzx  rcx,BYTE PTR [rax]
     586:	mov    rsi,rax
     589:	rex cmp cl,0x8
     58d:	sete   r8b
     591:	test   r8b,r8b
     594:	jne    5be <botlish_fn_13+0x73>
     59a:	mov    rdi,rbx
     59d:	mov    rax,QWORD PTR [rdi+0x10]
     5a1:	mov    rcx,QWORD PTR [rax]
     5a4:	mov    edx,0x8
     5a9:	call   5ae <botlish_fn_13+0x63>
			5aa: R_X86_64_PLT32	rt_type_error-0x4
     5ae:	xor    rax,rax
     5b1:	mov    rbx,QWORD PTR [rsp]
     5b5:	add    rsp,0x10
     5b9:	mov    rsp,rbp
     5bc:	pop    rbp
     5bd:	ret
     5be:	mov    rdi,rbx
     5c1:	call   5c6 <botlish_fn_13+0x7b>
			5c2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     5c6:	mov    rbx,QWORD PTR [rsp]
     5ca:	add    rsp,0x10
     5ce:	mov    rsp,rbp
     5d1:	pop    rbp
     5d2:	ret

00000000000005d3 <botlish_entry_13: ht_capacity<mutarray>>:
     5d3:	push   rbp
     5d4:	mov    rbp,rsp
     5d7:	mov    rsi,QWORD PTR [rdx]
     5da:	call   5df <botlish_entry_13+0xc>
			5db: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     5df:	mov    rsp,rbp
     5e2:	pop    rbp
     5e3:	ret

00000000000005e4 <botlish_fn_14: ht_probe_start<mutarray, str>>:
     5e4:	push   rbp
     5e5:	mov    rbp,rsp
     5e8:	sub    rsp,0x20
     5ec:	mov    QWORD PTR [rsp],r12
     5f0:	mov    QWORD PTR [rsp+0x8],r13
     5f5:	mov    QWORD PTR [rsp+0x10],r14
     5fa:	mov    r12,rdi
     5fd:	mov    r14,rsi
     600:	mov    rsi,rdx
     603:	mov    rdi,r12
     606:	call   60b <botlish_fn_14+0x27>
			607: R_X86_64_PLT32	rt_hash-0x4
     60b:	test   rax,rax
     60e:	mov    r13,rax
     611:	je     642 <botlish_fn_14+0x5e>
     617:	mov    rsi,r14
     61a:	mov    rdi,r12
     61d:	call   622 <botlish_fn_14+0x3e>
			61e: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     622:	test   rax,rax
     625:	mov    rdx,rax
     628:	je     642 <botlish_fn_14+0x5e>
     62e:	mov    rsi,r13
     631:	mov    rdi,r12
     634:	call   639 <botlish_fn_14+0x55>
			635: R_X86_64_PLT32	rt_int_mod-0x4
     639:	test   rax,rax
     63c:	jne    65c <botlish_fn_14+0x78>
     642:	xor    rax,rax
     645:	mov    r12,QWORD PTR [rsp]
     649:	mov    r13,QWORD PTR [rsp+0x8]
     64e:	mov    r14,QWORD PTR [rsp+0x10]
     653:	add    rsp,0x20
     657:	mov    rsp,rbp
     65a:	pop    rbp
     65b:	ret
     65c:	mov    r12,QWORD PTR [rsp]
     660:	mov    r13,QWORD PTR [rsp+0x8]
     665:	mov    r14,QWORD PTR [rsp+0x10]
     66a:	add    rsp,0x20
     66e:	mov    rsp,rbp
     671:	pop    rbp
     672:	ret

0000000000000673 <botlish_entry_14: ht_probe_start<mutarray, str>>:
     673:	push   rbp
     674:	mov    rbp,rsp
     677:	mov    rsi,QWORD PTR [rdx]
     67a:	mov    rdx,QWORD PTR [rdx+0x8]
     67e:	call   683 <botlish_entry_14+0x10>
			67f: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     683:	mov    rsp,rbp
     686:	pop    rbp
     687:	ret

0000000000000688 <botlish_fn_15: ht_probe_next<mutarray, int>>:
     688:	push   rbp
     689:	mov    rbp,rsp
     68c:	sub    rsp,0x40
     690:	mov    QWORD PTR [rsp+0x20],rbx
     695:	mov    QWORD PTR [rsp+0x28],r12
     69a:	mov    QWORD PTR [rsp+0x30],r13
     69f:	mov    r13,rdi
     6a2:	mov    QWORD PTR [rsp],rsi
     6a6:	mov    rbx,rsi
     6a9:	mov    QWORD PTR [rsp+0x8],rdx
     6ae:	mov    QWORD PTR [rsp+0x10],0x3
     6b7:	test   rdx,0x1
     6be:	jne    6cc <botlish_fn_15+0x44>
     6c4:	mov    rsi,rdx
     6c7:	jmp    6ec <botlish_fn_15+0x64>
     6cc:	mov    rsi,rdx
     6cf:	add    rsi,0x2
     6d3:	mov    r12,rsi
     6d6:	mov    rsi,rdx
     6d9:	seto   al
     6dc:	test   al,al
     6de:	jne    6ec <botlish_fn_15+0x64>
     6e4:	mov    rsi,rbx
     6e7:	jmp    6ff <botlish_fn_15+0x77>
     6ec:	mov    edx,0x3
     6f1:	mov    rdi,r13
     6f4:	call   6f9 <botlish_fn_15+0x71>
			6f5: R_X86_64_PLT32	rt_int_add-0x4
     6f9:	mov    rsi,rbx
     6fc:	mov    r12,rax
     6ff:	mov    rdi,r13
     702:	call   707 <botlish_fn_15+0x7f>
			703: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     707:	test   rax,rax
     70a:	mov    rdx,rax
     70d:	je     727 <botlish_fn_15+0x9f>
     713:	mov    rsi,r12
     716:	mov    rdi,r13
     719:	call   71e <botlish_fn_15+0x96>
			71a: R_X86_64_PLT32	rt_int_mod-0x4
     71e:	test   rax,rax
     721:	jne    742 <botlish_fn_15+0xba>
     727:	xor    rax,rax
     72a:	mov    rbx,QWORD PTR [rsp+0x20]
     72f:	mov    r12,QWORD PTR [rsp+0x28]
     734:	mov    r13,QWORD PTR [rsp+0x30]
     739:	add    rsp,0x40
     73d:	mov    rsp,rbp
     740:	pop    rbp
     741:	ret
     742:	mov    rbx,QWORD PTR [rsp+0x20]
     747:	mov    r12,QWORD PTR [rsp+0x28]
     74c:	mov    r13,QWORD PTR [rsp+0x30]
     751:	add    rsp,0x40
     755:	mov    rsp,rbp
     758:	pop    rbp
     759:	ret

000000000000075a <botlish_entry_15: ht_probe_next<mutarray, int>>:
     75a:	push   rbp
     75b:	mov    rbp,rsp
     75e:	mov    rsi,QWORD PTR [rdx]
     761:	mov    rdx,QWORD PTR [rdx+0x8]
     765:	call   76a <botlish_entry_15+0x10>
			766: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     76a:	mov    rsp,rbp
     76d:	pop    rbp
     76e:	ret
	...

0000000000000770 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     770:	push   rbp
     771:	mov    rbp,rsp
     774:	sub    rsp,0x50
     778:	mov    QWORD PTR [rsp+0x20],rbx
     77d:	mov    QWORD PTR [rsp+0x28],r12
     782:	mov    QWORD PTR [rsp+0x30],r13
     787:	mov    QWORD PTR [rsp+0x38],r14
     78c:	mov    QWORD PTR [rsp+0x40],r15
     791:	mov    r14,rdi
     794:	mov    QWORD PTR [rsp],rsi
     798:	mov    QWORD PTR [rsp+0x8],rdx
     79d:	mov    r15,rdx
     7a0:	mov    QWORD PTR [rsp+0x10],rcx
     7a5:	mov    r13,rsi
     7a8:	mov    QWORD PTR [rsp+0x18],rcx
     7ad:	mov    rsi,r13
     7b0:	mov    rdi,r14
     7b3:	call   7b8 <botlish_fn_16+0x48>
			7b4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     7b8:	test   rax,rax
     7bb:	je     9c0 <botlish_fn_16+0x250>
     7c1:	xor    ecx,ecx
     7c3:	test   rax,0x7
     7c9:	je     7d7 <botlish_fn_16+0x67>
     7cf:	mov    r8,rax
     7d2:	jmp    7e5 <botlish_fn_16+0x75>
     7d7:	movzx  rcx,BYTE PTR [rax]
     7db:	mov    r8,rax
     7de:	rex cmp cl,0x8
     7e2:	sete   cl
     7e5:	test   cl,cl
     7e7:	jne    80a <botlish_fn_16+0x9a>
     7ed:	mov    rdi,r14
     7f0:	mov    rsi,QWORD PTR [rdi+0x10]
     7f4:	mov    rcx,QWORD PTR [rsi+0x8]
     7f8:	mov    edx,0x8
     7fd:	mov    rsi,r8
     800:	call   805 <botlish_fn_16+0x95>
			801: R_X86_64_PLT32	rt_type_error-0x4
     805:	jmp    9c0 <botlish_fn_16+0x250>
     80a:	mov    rsi,r8
     80d:	mov    rdx,QWORD PTR [rsp+0x18]
     812:	mov    rdi,r14
     815:	call   81a <botlish_fn_16+0xaa>
			816: R_X86_64_PLT32	rt_mutarray_get-0x4
     81a:	mov    rcx,rax
     81d:	mov    r12,rax
     820:	test   rax,rcx
     823:	je     9c0 <botlish_fn_16+0x250>
     829:	mov    rdi,r14
     82c:	call   831 <botlish_fn_16+0xc1>
			82d: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     831:	mov    rax,r12
     834:	test   rax,0x1
     83a:	jne    85e <botlish_fn_16+0xee>
     840:	mov    edx,0x1
     845:	mov    rsi,r12
     848:	mov    rdi,r14
     84b:	call   850 <botlish_fn_16+0xe0>
			84c: R_X86_64_PLT32	rt_value_eq-0x4
     850:	test   rax,rax
     853:	je     9c0 <botlish_fn_16+0x250>
     859:	jmp    86f <botlish_fn_16+0xff>
     85e:	mov    eax,0x2
     863:	cmp    r12,0x1
     867:	cmove  rax,QWORD PTR [rip+0x1e1]        # a50 <botlish_fn_16+0x2e0>
     86f:	mov    ebx,0x6
     874:	cmp    rax,0x6
     878:	je     a27 <botlish_fn_16+0x2b7>
     87e:	mov    rdi,r14
     881:	call   886 <botlish_fn_16+0x116>
			882: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     886:	test   r12,0x1
     88d:	jne    8b1 <botlish_fn_16+0x141>
     893:	mov    edx,0x3
     898:	mov    rsi,r12
     89b:	mov    rdi,r14
     89e:	call   8a3 <botlish_fn_16+0x133>
			89f: R_X86_64_PLT32	rt_value_eq-0x4
     8a3:	test   rax,rax
     8a6:	je     9c0 <botlish_fn_16+0x250>
     8ac:	jmp    8c5 <botlish_fn_16+0x155>
     8b1:	mov    rsi,r12
     8b4:	mov    eax,0x2
     8b9:	cmp    rsi,0x3
     8bd:	cmove  rax,QWORD PTR [rip+0x18b]        # a50 <botlish_fn_16+0x2e0>
     8c5:	cmp    rax,0x6
     8c9:	je     8dc <botlish_fn_16+0x16c>
     8cf:	mov    ebx,0x2
     8d4:	mov    r12,r15
     8d7:	jmp    99d <botlish_fn_16+0x22d>
     8dc:	mov    rsi,r13
     8df:	mov    rdi,r14
     8e2:	call   8e7 <botlish_fn_16+0x177>
			8e3: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     8e7:	test   rax,rax
     8ea:	je     9c0 <botlish_fn_16+0x250>
     8f0:	xor    ecx,ecx
     8f2:	test   rax,0x7
     8f8:	je     906 <botlish_fn_16+0x196>
     8fe:	mov    rsi,rax
     901:	jmp    914 <botlish_fn_16+0x1a4>
     906:	movzx  rcx,BYTE PTR [rax]
     90a:	mov    rsi,rax
     90d:	rex cmp cl,0x8
     911:	sete   cl
     914:	test   cl,cl
     916:	jne    936 <botlish_fn_16+0x1c6>
     91c:	mov    rdi,r14
     91f:	mov    rax,QWORD PTR [rdi+0x10]
     923:	mov    rcx,QWORD PTR [rax+0x8]
     927:	mov    edx,0x8
     92c:	call   931 <botlish_fn_16+0x1c1>
			92d: R_X86_64_PLT32	rt_type_error-0x4
     931:	jmp    9c0 <botlish_fn_16+0x250>
     936:	mov    rdx,QWORD PTR [rsp+0x18]
     93b:	mov    rdi,r14
     93e:	call   943 <botlish_fn_16+0x1d3>
			93f: R_X86_64_PLT32	rt_mutarray_get-0x4
     943:	test   rax,rax
     946:	je     9c0 <botlish_fn_16+0x250>
     94c:	mov    r12,r15
     94f:	mov    rcx,rax
     952:	and    rcx,r12
     955:	mov    rsi,rax
     958:	test   rcx,0x1
     95f:	jne    97e <botlish_fn_16+0x20e>
     965:	mov    rdx,r12
     968:	mov    rdi,r14
     96b:	call   970 <botlish_fn_16+0x200>
			96c: R_X86_64_PLT32	rt_value_eq-0x4
     970:	test   rax,rax
     973:	je     9c0 <botlish_fn_16+0x250>
     979:	jmp    98e <botlish_fn_16+0x21e>
     97e:	mov    eax,0x2
     983:	cmp    rsi,r12
     986:	cmove  rax,QWORD PTR [rip+0xc2]        # a50 <botlish_fn_16+0x2e0>
     98e:	cmp    rax,0x6
     992:	je     99d <botlish_fn_16+0x22d>
     998:	mov    ebx,0x2
     99d:	cmp    rbx,0x6
     9a1:	je     a00 <botlish_fn_16+0x290>
     9a7:	mov    rdx,QWORD PTR [rsp+0x18]
     9ac:	mov    rsi,r13
     9af:	mov    rdi,r14
     9b2:	call   9b7 <botlish_fn_16+0x247>
			9b3: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     9b7:	test   rax,rax
     9ba:	jne    9e5 <botlish_fn_16+0x275>
     9c0:	xor    rax,rax
     9c3:	mov    rbx,QWORD PTR [rsp+0x20]
     9c8:	mov    r12,QWORD PTR [rsp+0x28]
     9cd:	mov    r13,QWORD PTR [rsp+0x30]
     9d2:	mov    r14,QWORD PTR [rsp+0x38]
     9d7:	mov    r15,QWORD PTR [rsp+0x40]
     9dc:	add    rsp,0x50
     9e0:	mov    rsp,rbp
     9e3:	pop    rbp
     9e4:	ret
     9e5:	mov    QWORD PTR [rsp],r13
     9e9:	mov    QWORD PTR [rsp+0x8],r12
     9ee:	mov    QWORD PTR [rsp+0x10],rax
     9f3:	mov    r15,r12
     9f6:	mov    QWORD PTR [rsp+0x18],rax
     9fb:	jmp    7ad <botlish_fn_16+0x3d>
     a00:	mov    rax,QWORD PTR [rsp+0x18]
     a05:	mov    rbx,QWORD PTR [rsp+0x20]
     a0a:	mov    r12,QWORD PTR [rsp+0x28]
     a0f:	mov    r13,QWORD PTR [rsp+0x30]
     a14:	mov    r14,QWORD PTR [rsp+0x38]
     a19:	mov    r15,QWORD PTR [rsp+0x40]
     a1e:	add    rsp,0x50
     a22:	mov    rsp,rbp
     a25:	pop    rbp
     a26:	ret
     a27:	mov    rax,0xffffffffffffffff
     a2e:	mov    rbx,QWORD PTR [rsp+0x20]
     a33:	mov    r12,QWORD PTR [rsp+0x28]
     a38:	mov    r13,QWORD PTR [rsp+0x30]
     a3d:	mov    r14,QWORD PTR [rsp+0x38]
     a42:	mov    r15,QWORD PTR [rsp+0x40]
     a47:	add    rsp,0x50
     a4b:	mov    rsp,rbp
     a4e:	pop    rbp
     a4f:	ret
     a50:	(bad)
     a51:	add    BYTE PTR [rax],al
     a53:	add    BYTE PTR [rax],al
     a55:	add    BYTE PTR [rax],al
	...

0000000000000a58 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
     a58:	push   rbp
     a59:	mov    rbp,rsp
     a5c:	mov    rsi,QWORD PTR [rdx]
     a5f:	mov    r8,QWORD PTR [rdx+0x8]
     a63:	mov    rcx,QWORD PTR [rdx+0x10]
     a67:	mov    rdx,r8
     a6a:	call   a6f <botlish_entry_16+0x17>
			a6b: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
     a6f:	mov    rsp,rbp
     a72:	pop    rbp
     a73:	ret
     a74:	add    BYTE PTR [rax],al
	...

0000000000000a78 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
     a78:	push   rbp
     a79:	mov    rbp,rsp
     a7c:	sub    rsp,0x60
     a80:	mov    QWORD PTR [rsp+0x30],rbx
     a85:	mov    QWORD PTR [rsp+0x38],r12
     a8a:	mov    QWORD PTR [rsp+0x40],r13
     a8f:	mov    QWORD PTR [rsp+0x48],r14
     a94:	mov    QWORD PTR [rsp+0x50],r15
     a99:	mov    r15,rdi
     a9c:	mov    QWORD PTR [rsp],rsi
     aa0:	mov    QWORD PTR [rsp+0x8],rdx
     aa5:	mov    r13,rdx
     aa8:	mov    QWORD PTR [rsp+0x10],rcx
     aad:	mov    QWORD PTR [rsp+0x18],r8
     ab2:	mov    rbx,rsi
     ab5:	mov    QWORD PTR [rsp+0x20],rcx
     aba:	mov    QWORD PTR [rsp+0x28],r8
     abf:	mov    rsi,rbx
     ac2:	mov    rdi,r15
     ac5:	call   aca <botlish_fn_17+0x52>
			ac6: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     aca:	test   rax,rax
     acd:	je     dd3 <botlish_fn_17+0x35b>
     ad3:	xor    ecx,ecx
     ad5:	test   rax,0x7
     adb:	je     ae9 <botlish_fn_17+0x71>
     ae1:	mov    rsi,rax
     ae4:	jmp    af7 <botlish_fn_17+0x7f>
     ae9:	movzx  rcx,BYTE PTR [rax]
     aed:	mov    rsi,rax
     af0:	rex cmp cl,0x8
     af4:	sete   cl
     af7:	test   cl,cl
     af9:	jne    b19 <botlish_fn_17+0xa1>
     aff:	mov    rdi,r15
     b02:	mov    rax,QWORD PTR [rdi+0x10]
     b06:	mov    rcx,QWORD PTR [rax+0x8]
     b0a:	mov    edx,0x8
     b0f:	call   b14 <botlish_fn_17+0x9c>
			b10: R_X86_64_PLT32	rt_type_error-0x4
     b14:	jmp    dd3 <botlish_fn_17+0x35b>
     b19:	mov    rdx,QWORD PTR [rsp+0x20]
     b1e:	mov    rdi,r15
     b21:	call   b26 <botlish_fn_17+0xae>
			b22: R_X86_64_PLT32	rt_mutarray_get-0x4
     b26:	mov    r9,rax
     b29:	mov    r14,rax
     b2c:	test   rax,r9
     b2f:	je     dd3 <botlish_fn_17+0x35b>
     b35:	mov    rdi,r15
     b38:	call   b3d <botlish_fn_17+0xc5>
			b39: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     b3d:	mov    rax,r14
     b40:	test   rax,0x1
     b46:	jne    b6a <botlish_fn_17+0xf2>
     b4c:	mov    edx,0x1
     b51:	mov    rsi,r14
     b54:	mov    rdi,r15
     b57:	call   b5c <botlish_fn_17+0xe4>
			b58: R_X86_64_PLT32	rt_value_eq-0x4
     b5c:	test   rax,rax
     b5f:	je     dd3 <botlish_fn_17+0x35b>
     b65:	jmp    b7e <botlish_fn_17+0x106>
     b6a:	mov    eax,0x2
     b6f:	mov    rcx,r14
     b72:	cmp    rcx,0x1
     b76:	cmove  rax,QWORD PTR [rip+0x37a]        # ef8 <botlish_fn_17+0x480>
     b7e:	mov    r12d,0x6
     b84:	cmp    rax,0x6
     b88:	je     e4b <botlish_fn_17+0x3d3>
     b8e:	mov    rdi,r15
     b91:	call   b96 <botlish_fn_17+0x11e>
			b92: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     b96:	mov    rax,r14
     b99:	test   rax,0x1
     b9f:	jne    bc3 <botlish_fn_17+0x14b>
     ba5:	mov    edx,0x3
     baa:	mov    rsi,r14
     bad:	mov    rdi,r15
     bb0:	call   bb5 <botlish_fn_17+0x13d>
			bb1: R_X86_64_PLT32	rt_value_eq-0x4
     bb5:	test   rax,rax
     bb8:	je     dd3 <botlish_fn_17+0x35b>
     bbe:	jmp    bd7 <botlish_fn_17+0x15f>
     bc3:	mov    eax,0x2
     bc8:	mov    rcx,r14
     bcb:	cmp    rcx,0x3
     bcf:	cmove  rax,QWORD PTR [rip+0x321]        # ef8 <botlish_fn_17+0x480>
     bd7:	cmp    rax,0x6
     bdb:	je     beb <botlish_fn_17+0x173>
     be1:	mov    eax,0x2
     be6:	jmp    cac <botlish_fn_17+0x234>
     beb:	mov    rsi,rbx
     bee:	mov    rdi,r15
     bf1:	call   bf6 <botlish_fn_17+0x17e>
			bf2: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     bf6:	test   rax,rax
     bf9:	je     dd3 <botlish_fn_17+0x35b>
     bff:	xor    ecx,ecx
     c01:	test   rax,0x7
     c07:	jne    c18 <botlish_fn_17+0x1a0>
     c0d:	movzx  rcx,BYTE PTR [rax]
     c11:	rex cmp cl,0x8
     c15:	sete   cl
     c18:	test   cl,cl
     c1a:	jne    c3d <botlish_fn_17+0x1c5>
     c20:	mov    rdi,r15
     c23:	mov    rsi,QWORD PTR [rdi+0x10]
     c27:	mov    rcx,QWORD PTR [rsi+0x8]
     c2b:	mov    edx,0x8
     c30:	mov    rsi,rax
     c33:	call   c38 <botlish_fn_17+0x1c0>
			c34: R_X86_64_PLT32	rt_type_error-0x4
     c38:	jmp    dd3 <botlish_fn_17+0x35b>
     c3d:	mov    rsi,rax
     c40:	mov    rdx,QWORD PTR [rsp+0x20]
     c45:	mov    rdi,r15
     c48:	call   c4d <botlish_fn_17+0x1d5>
			c49: R_X86_64_PLT32	rt_mutarray_get-0x4
     c4d:	test   rax,rax
     c50:	je     dd3 <botlish_fn_17+0x35b>
     c56:	mov    r8,rax
     c59:	and    r8,r13
     c5c:	mov    rsi,rax
     c5f:	test   r8,0x1
     c66:	jne    c85 <botlish_fn_17+0x20d>
     c6c:	mov    rdx,r13
     c6f:	mov    rdi,r15
     c72:	call   c77 <botlish_fn_17+0x1ff>
			c73: R_X86_64_PLT32	rt_value_eq-0x4
     c77:	test   rax,rax
     c7a:	je     dd3 <botlish_fn_17+0x35b>
     c80:	jmp    c95 <botlish_fn_17+0x21d>
     c85:	mov    eax,0x2
     c8a:	cmp    rsi,r13
     c8d:	cmove  rax,QWORD PTR [rip+0x263]        # ef8 <botlish_fn_17+0x480>
     c95:	cmp    rax,0x6
     c99:	je     ca9 <botlish_fn_17+0x231>
     c9f:	mov    eax,0x2
     ca4:	jmp    cac <botlish_fn_17+0x234>
     ca9:	mov    rax,r12
     cac:	cmp    rax,0x6
     cb0:	je     e24 <botlish_fn_17+0x3ac>
     cb6:	mov    rdi,r15
     cb9:	call   cbe <botlish_fn_17+0x246>
			cba: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
     cbe:	mov    rax,r14
     cc1:	test   rax,0x1
     cc7:	jne    ceb <botlish_fn_17+0x273>
     ccd:	mov    edx,0x5
     cd2:	mov    rsi,r14
     cd5:	mov    rdi,r15
     cd8:	call   cdd <botlish_fn_17+0x265>
			cd9: R_X86_64_PLT32	rt_value_eq-0x4
     cdd:	test   rax,rax
     ce0:	je     dd3 <botlish_fn_17+0x35b>
     ce6:	jmp    cff <botlish_fn_17+0x287>
     ceb:	mov    rsi,r14
     cee:	mov    eax,0x2
     cf3:	cmp    rsi,0x5
     cf7:	cmove  rax,QWORD PTR [rip+0x1f9]        # ef8 <botlish_fn_17+0x480>
     cff:	cmp    rax,0x6
     d03:	je     d14 <botlish_fn_17+0x29c>
     d09:	mov    r12d,0x2
     d0f:	jmp    d75 <botlish_fn_17+0x2fd>
     d14:	mov    r14,QWORD PTR [rsp+0x28]
     d19:	test   r14,0x1
     d20:	jne    d50 <botlish_fn_17+0x2d8>
     d26:	mov    edx,0x1
     d2b:	mov    rsi,r14
     d2e:	mov    rdi,r15
     d31:	call   d36 <botlish_fn_17+0x2be>
			d32: R_X86_64_PLT32	rt_int_cmp-0x4
     d36:	mov    ecx,0x2
     d3b:	test   rax,rax
     d3e:	cmovl  rcx,QWORD PTR [rip+0x1b2]        # ef8 <botlish_fn_17+0x480>
     d46:	mov    QWORD PTR [rsp+0x28],r14
     d4b:	jmp    d65 <botlish_fn_17+0x2ed>
     d50:	mov    ecx,0x2
     d55:	test   r14,r14
     d58:	mov    QWORD PTR [rsp+0x28],r14
     d5d:	cmovle rcx,QWORD PTR [rip+0x193]        # ef8 <botlish_fn_17+0x480>
     d65:	cmp    rcx,0x6
     d69:	je     d75 <botlish_fn_17+0x2fd>
     d6f:	mov    r12d,0x2
     d75:	cmp    r12,0x6
     d79:	je     dba <botlish_fn_17+0x342>
     d7f:	mov    rdx,QWORD PTR [rsp+0x20]
     d84:	mov    rsi,rbx
     d87:	mov    rdi,r15
     d8a:	call   d8f <botlish_fn_17+0x317>
			d8b: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     d8f:	test   rax,rax
     d92:	je     dd3 <botlish_fn_17+0x35b>
     d98:	mov    QWORD PTR [rsp],rbx
     d9c:	mov    QWORD PTR [rsp+0x8],r13
     da1:	mov    QWORD PTR [rsp+0x10],rax
     da6:	mov    rcx,QWORD PTR [rsp+0x28]
     dab:	mov    QWORD PTR [rsp+0x18],rcx
     db0:	mov    QWORD PTR [rsp+0x20],rax
     db5:	jmp    abf <botlish_fn_17+0x47>
     dba:	mov    rdx,QWORD PTR [rsp+0x20]
     dbf:	mov    rsi,rbx
     dc2:	mov    rdi,r15
     dc5:	call   dca <botlish_fn_17+0x352>
			dc6: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     dca:	test   rax,rax
     dcd:	jne    df8 <botlish_fn_17+0x380>
     dd3:	xor    rax,rax
     dd6:	mov    rbx,QWORD PTR [rsp+0x30]
     ddb:	mov    r12,QWORD PTR [rsp+0x38]
     de0:	mov    r13,QWORD PTR [rsp+0x40]
     de5:	mov    r14,QWORD PTR [rsp+0x48]
     dea:	mov    r15,QWORD PTR [rsp+0x50]
     def:	add    rsp,0x60
     df3:	mov    rsp,rbp
     df6:	pop    rbp
     df7:	ret
     df8:	mov    QWORD PTR [rsp],rbx
     dfc:	mov    QWORD PTR [rsp+0x8],r13
     e01:	mov    QWORD PTR [rsp+0x10],rax
     e06:	mov    rdx,QWORD PTR [rsp+0x20]
     e0b:	mov    QWORD PTR [rsp+0x18],rdx
     e10:	mov    rcx,QWORD PTR [rsp+0x20]
     e15:	mov    QWORD PTR [rsp+0x28],rcx
     e1a:	mov    QWORD PTR [rsp+0x20],rax
     e1f:	jmp    abf <botlish_fn_17+0x47>
     e24:	mov    rax,QWORD PTR [rsp+0x20]
     e29:	mov    rbx,QWORD PTR [rsp+0x30]
     e2e:	mov    r12,QWORD PTR [rsp+0x38]
     e33:	mov    r13,QWORD PTR [rsp+0x40]
     e38:	mov    r14,QWORD PTR [rsp+0x48]
     e3d:	mov    r15,QWORD PTR [rsp+0x50]
     e42:	add    rsp,0x60
     e46:	mov    rsp,rbp
     e49:	pop    rbp
     e4a:	ret
     e4b:	mov    rax,QWORD PTR [rsp+0x28]
     e50:	test   rax,0x1
     e56:	jne    e83 <botlish_fn_17+0x40b>
     e5c:	mov    edx,0x1
     e61:	mov    rdi,r15
     e64:	mov    rsi,QWORD PTR [rsp+0x28]
     e69:	call   e6e <botlish_fn_17+0x3f6>
			e6a: R_X86_64_PLT32	rt_int_cmp-0x4
     e6e:	mov    ecx,0x2
     e73:	test   rax,rax
     e76:	cmovge rcx,QWORD PTR [rip+0x7a]        # ef8 <botlish_fn_17+0x480>
     e7e:	jmp    e9d <botlish_fn_17+0x425>
     e83:	mov    ecx,0x2
     e88:	mov    rax,QWORD PTR [rsp+0x28]
     e8d:	mov    rdx,QWORD PTR [rsp+0x28]
     e92:	test   rax,rdx
     e95:	cmovg  rcx,QWORD PTR [rip+0x5b]        # ef8 <botlish_fn_17+0x480>
     e9d:	cmp    rcx,0x6
     ea1:	je     ece <botlish_fn_17+0x456>
     ea7:	mov    rax,QWORD PTR [rsp+0x20]
     eac:	mov    rbx,QWORD PTR [rsp+0x30]
     eb1:	mov    r12,QWORD PTR [rsp+0x38]
     eb6:	mov    r13,QWORD PTR [rsp+0x40]
     ebb:	mov    r14,QWORD PTR [rsp+0x48]
     ec0:	mov    r15,QWORD PTR [rsp+0x50]
     ec5:	add    rsp,0x60
     ec9:	mov    rsp,rbp
     ecc:	pop    rbp
     ecd:	ret
     ece:	mov    rax,QWORD PTR [rsp+0x28]
     ed3:	mov    rbx,QWORD PTR [rsp+0x30]
     ed8:	mov    r12,QWORD PTR [rsp+0x38]
     edd:	mov    r13,QWORD PTR [rsp+0x40]
     ee2:	mov    r14,QWORD PTR [rsp+0x48]
     ee7:	mov    r15,QWORD PTR [rsp+0x50]
     eec:	add    rsp,0x60
     ef0:	mov    rsp,rbp
     ef3:	pop    rbp
     ef4:	ret
     ef5:	add    BYTE PTR [rax],al
     ef7:	add    BYTE PTR [rsi],al
     ef9:	add    BYTE PTR [rax],al
     efb:	add    BYTE PTR [rax],al
     efd:	add    BYTE PTR [rax],al
	...

0000000000000f00 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
     f00:	push   rbp
     f01:	mov    rbp,rsp
     f04:	mov    rsi,QWORD PTR [rdx]
     f07:	mov    r9,QWORD PTR [rdx+0x8]
     f0b:	mov    rcx,QWORD PTR [rdx+0x10]
     f0f:	mov    r8,QWORD PTR [rdx+0x18]
     f13:	mov    rdx,r9
     f16:	call   f1b <botlish_entry_17+0x1b>
			f17: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
     f1b:	mov    rsp,rbp
     f1e:	pop    rbp
     f1f:	ret

0000000000000f20 <botlish_fn_18: ht_get<mutarray, str>>:
     f20:	push   rbp
     f21:	mov    rbp,rsp
     f24:	sub    rsp,0x40
     f28:	mov    QWORD PTR [rsp+0x20],rbx
     f2d:	mov    QWORD PTR [rsp+0x28],r12
     f32:	mov    QWORD PTR [rsp+0x30],r13
     f37:	mov    rbx,rdi
     f3a:	mov    QWORD PTR [rsp],rsi
     f3e:	mov    r13,rsi
     f41:	mov    QWORD PTR [rsp+0x8],rdx
     f46:	mov    r12,rdx
     f49:	mov    rdx,r12
     f4c:	mov    rsi,r13
     f4f:	mov    rdi,rbx
     f52:	call   f57 <botlish_fn_18+0x37>
			f53: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     f57:	test   rax,rax
     f5a:	je     1044 <botlish_fn_18+0x124>
     f60:	mov    QWORD PTR [rsp+0x10],rax
     f65:	mov    rcx,rax
     f68:	mov    rdx,r12
     f6b:	mov    rsi,r13
     f6e:	mov    rdi,rbx
     f71:	call   f76 <botlish_fn_18+0x56>
			f72: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
     f76:	mov    rcx,rax
     f79:	mov    r12,rax
     f7c:	test   rax,rcx
     f7f:	je     1044 <botlish_fn_18+0x124>
     f85:	mov    rax,r12
     f88:	test   rax,0x1
     f8e:	jne    fb9 <botlish_fn_18+0x99>
     f94:	mov    edx,0x1
     f99:	mov    rsi,r12
     f9c:	mov    rdi,rbx
     f9f:	call   fa4 <botlish_fn_18+0x84>
			fa0: R_X86_64_PLT32	rt_int_cmp-0x4
     fa4:	mov    ecx,0x2
     fa9:	test   rax,rax
     fac:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 1098 <botlish_fn_18+0x178>
     fb4:	jmp    fcc <botlish_fn_18+0xac>
     fb9:	mov    ecx,0x2
     fbe:	mov    rax,r12
     fc1:	test   rax,rax
     fc4:	cmovle rcx,QWORD PTR [rip+0xcc]        # 1098 <botlish_fn_18+0x178>
     fcc:	cmp    rcx,0x6
     fd0:	je     1077 <botlish_fn_18+0x157>
     fd6:	mov    rsi,r13
     fd9:	mov    rdi,rbx
     fdc:	call   fe1 <botlish_fn_18+0xc1>
			fdd: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     fe1:	test   rax,rax
     fe4:	je     1044 <botlish_fn_18+0x124>
     fea:	xor    ecx,ecx
     fec:	test   rax,0x7
     ff2:	je     1000 <botlish_fn_18+0xe0>
     ff8:	mov    rsi,rax
     ffb:	jmp    100e <botlish_fn_18+0xee>
    1000:	movzx  rcx,BYTE PTR [rax]
    1004:	mov    rsi,rax
    1007:	rex cmp cl,0x8
    100b:	sete   cl
    100e:	test   cl,cl
    1010:	jne    1030 <botlish_fn_18+0x110>
    1016:	mov    rdi,rbx
    1019:	mov    rax,QWORD PTR [rdi+0x10]
    101d:	mov    rcx,QWORD PTR [rax+0x8]
    1021:	mov    edx,0x8
    1026:	call   102b <botlish_fn_18+0x10b>
			1027: R_X86_64_PLT32	rt_type_error-0x4
    102b:	jmp    1044 <botlish_fn_18+0x124>
    1030:	mov    rdx,r12
    1033:	mov    rdi,rbx
    1036:	call   103b <botlish_fn_18+0x11b>
			1037: R_X86_64_PLT32	rt_mutarray_get-0x4
    103b:	test   rax,rax
    103e:	jne    105f <botlish_fn_18+0x13f>
    1044:	xor    rax,rax
    1047:	mov    rbx,QWORD PTR [rsp+0x20]
    104c:	mov    r12,QWORD PTR [rsp+0x28]
    1051:	mov    r13,QWORD PTR [rsp+0x30]
    1056:	add    rsp,0x40
    105a:	mov    rsp,rbp
    105d:	pop    rbp
    105e:	ret
    105f:	mov    rbx,QWORD PTR [rsp+0x20]
    1064:	mov    r12,QWORD PTR [rsp+0x28]
    1069:	mov    r13,QWORD PTR [rsp+0x30]
    106e:	add    rsp,0x40
    1072:	mov    rsp,rbp
    1075:	pop    rbp
    1076:	ret
    1077:	mov    eax,0xa
    107c:	mov    rbx,QWORD PTR [rsp+0x20]
    1081:	mov    r12,QWORD PTR [rsp+0x28]
    1086:	mov    r13,QWORD PTR [rsp+0x30]
    108b:	add    rsp,0x40
    108f:	mov    rsp,rbp
    1092:	pop    rbp
    1093:	ret
    1094:	add    BYTE PTR [rax],al
    1096:	add    BYTE PTR [rax],al
    1098:	(bad)
    1099:	add    BYTE PTR [rax],al
    109b:	add    BYTE PTR [rax],al
    109d:	add    BYTE PTR [rax],al
	...

00000000000010a0 <botlish_entry_18: ht_get<mutarray, str>>:
    10a0:	push   rbp
    10a1:	mov    rbp,rsp
    10a4:	mov    rsi,QWORD PTR [rdx]
    10a7:	mov    rdx,QWORD PTR [rdx+0x8]
    10ab:	call   10b0 <botlish_entry_18+0x10>
			10ac: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    10b0:	mov    rsp,rbp
    10b3:	pop    rbp
    10b4:	ret
    10b5:	add    BYTE PTR [rax],al
	...

00000000000010b8 <botlish_fn_19: ht_contains<mutarray, str>>:
    10b8:	push   rbp
    10b9:	mov    rbp,rsp
    10bc:	sub    rsp,0x40
    10c0:	mov    QWORD PTR [rsp+0x20],rbx
    10c5:	mov    QWORD PTR [rsp+0x28],r12
    10ca:	mov    QWORD PTR [rsp+0x30],r15
    10cf:	mov    r15,rdi
    10d2:	mov    QWORD PTR [rsp],rsi
    10d6:	mov    r12,rsi
    10d9:	mov    QWORD PTR [rsp+0x8],rdx
    10de:	mov    rbx,rdx
    10e1:	mov    rdx,rbx
    10e4:	mov    rsi,r12
    10e7:	mov    rdi,r15
    10ea:	call   10ef <botlish_fn_19+0x37>
			10eb: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    10ef:	test   rax,rax
    10f2:	je     1117 <botlish_fn_19+0x5f>
    10f8:	mov    QWORD PTR [rsp+0x10],rax
    10fd:	mov    rcx,rax
    1100:	mov    rdx,rbx
    1103:	mov    rsi,r12
    1106:	mov    rdi,r15
    1109:	call   110e <botlish_fn_19+0x56>
			110a: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    110e:	test   rax,rax
    1111:	jne    1132 <botlish_fn_19+0x7a>
    1117:	xor    rax,rax
    111a:	mov    rbx,QWORD PTR [rsp+0x20]
    111f:	mov    r12,QWORD PTR [rsp+0x28]
    1124:	mov    r15,QWORD PTR [rsp+0x30]
    1129:	add    rsp,0x40
    112d:	mov    rsp,rbp
    1130:	pop    rbp
    1131:	ret
    1132:	test   rax,0x1
    1138:	mov    rsi,rax
    113b:	jne    1166 <botlish_fn_19+0xae>
    1141:	mov    edx,0x1
    1146:	mov    rdi,r15
    1149:	call   114e <botlish_fn_19+0x96>
			114a: R_X86_64_PLT32	rt_int_cmp-0x4
    114e:	mov    ecx,0x2
    1153:	test   rax,rax
    1156:	mov    rax,rcx
    1159:	cmovge rax,QWORD PTR [rip+0x2f]        # 1190 <botlish_fn_19+0xd8>
    1161:	jmp    1176 <botlish_fn_19+0xbe>
    1166:	mov    eax,0x2
    116b:	test   rsi,rsi
    116e:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1190 <botlish_fn_19+0xd8>
    1176:	mov    rbx,QWORD PTR [rsp+0x20]
    117b:	mov    r12,QWORD PTR [rsp+0x28]
    1180:	mov    r15,QWORD PTR [rsp+0x30]
    1185:	add    rsp,0x40
    1189:	mov    rsp,rbp
    118c:	pop    rbp
    118d:	ret
    118e:	add    BYTE PTR [rax],al
    1190:	(bad)
    1191:	add    BYTE PTR [rax],al
    1193:	add    BYTE PTR [rax],al
    1195:	add    BYTE PTR [rax],al
	...

0000000000001198 <botlish_entry_19: ht_contains<mutarray, str>>:
    1198:	push   rbp
    1199:	mov    rbp,rsp
    119c:	mov    rsi,QWORD PTR [rdx]
    119f:	mov    rdx,QWORD PTR [rdx+0x8]
    11a3:	call   11a8 <botlish_entry_19+0x10>
			11a4: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    11a8:	mov    rsp,rbp
    11ab:	pop    rbp
    11ac:	ret
    11ad:	add    BYTE PTR [rax],al
	...

00000000000011b0 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    11b0:	push   rbp
    11b1:	mov    rbp,rsp
    11b4:	sub    rsp,0x50
    11b8:	mov    QWORD PTR [rsp+0x20],rbx
    11bd:	mov    QWORD PTR [rsp+0x28],r12
    11c2:	mov    QWORD PTR [rsp+0x30],r13
    11c7:	mov    QWORD PTR [rsp+0x38],r14
    11cc:	mov    QWORD PTR [rsp+0x40],r15
    11d1:	mov    r13,rdi
    11d4:	mov    QWORD PTR [rsp],rsi
    11d8:	mov    QWORD PTR [rsp+0x8],rdx
    11dd:	mov    QWORD PTR [rsp+0x10],rcx
    11e2:	mov    r12,rcx
    11e5:	mov    rbx,rsi
    11e8:	mov    r14,rdx
    11eb:	mov    rdx,r14
    11ee:	mov    rsi,rbx
    11f1:	mov    rdi,r13
    11f4:	call   11f9 <botlish_fn_20+0x49>
			11f5: R_X86_64_PLT32	rt_mutarray_get-0x4
    11f9:	test   rax,rax
    11fc:	mov    r15,rax
    11ff:	je     12aa <botlish_fn_20+0xfa>
    1205:	mov    rdi,r13
    1208:	call   120d <botlish_fn_20+0x5d>
			1209: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    120d:	mov    rax,r15
    1210:	test   rax,0x1
    1216:	jne    123a <botlish_fn_20+0x8a>
    121c:	mov    edx,0x1
    1221:	mov    rsi,r15
    1224:	mov    rdi,r13
    1227:	call   122c <botlish_fn_20+0x7c>
			1228: R_X86_64_PLT32	rt_value_eq-0x4
    122c:	test   rax,rax
    122f:	je     12aa <botlish_fn_20+0xfa>
    1235:	jmp    124e <botlish_fn_20+0x9e>
    123a:	mov    rsi,r15
    123d:	mov    eax,0x2
    1242:	cmp    rsi,0x1
    1246:	cmove  rax,QWORD PTR [rip+0xc2]        # 1310 <botlish_fn_20+0x160>
    124e:	cmp    rax,0x6
    1252:	je     12e5 <botlish_fn_20+0x135>
    1258:	mov    QWORD PTR [rsp+0x18],0x3
    1261:	mov    rsi,r14
    1264:	test   rsi,0x1
    126b:	je     1283 <botlish_fn_20+0xd3>
    1271:	mov    rsi,r14
    1274:	add    rsi,0x2
    1278:	seto   al
    127b:	test   al,al
    127d:	je     1296 <botlish_fn_20+0xe6>
    1283:	mov    edx,0x3
    1288:	mov    rsi,r14
    128b:	mov    rdi,r13
    128e:	call   1293 <botlish_fn_20+0xe3>
			128f: R_X86_64_PLT32	rt_int_add-0x4
    1293:	mov    rsi,rax
    1296:	mov    rdx,r12
    1299:	mov    rdi,r13
    129c:	call   12a1 <botlish_fn_20+0xf1>
			129d: R_X86_64_PLT32	rt_int_mod-0x4
    12a1:	test   rax,rax
    12a4:	jne    12cf <botlish_fn_20+0x11f>
    12aa:	xor    rax,rax
    12ad:	mov    rbx,QWORD PTR [rsp+0x20]
    12b2:	mov    r12,QWORD PTR [rsp+0x28]
    12b7:	mov    r13,QWORD PTR [rsp+0x30]
    12bc:	mov    r14,QWORD PTR [rsp+0x38]
    12c1:	mov    r15,QWORD PTR [rsp+0x40]
    12c6:	add    rsp,0x50
    12ca:	mov    rsp,rbp
    12cd:	pop    rbp
    12ce:	ret
    12cf:	mov    QWORD PTR [rsp],rbx
    12d3:	mov    QWORD PTR [rsp+0x8],rax
    12d8:	mov    QWORD PTR [rsp+0x10],r12
    12dd:	mov    r14,rax
    12e0:	jmp    11eb <botlish_fn_20+0x3b>
    12e5:	mov    rax,r14
    12e8:	mov    rbx,QWORD PTR [rsp+0x20]
    12ed:	mov    r12,QWORD PTR [rsp+0x28]
    12f2:	mov    r13,QWORD PTR [rsp+0x30]
    12f7:	mov    r14,QWORD PTR [rsp+0x38]
    12fc:	mov    r15,QWORD PTR [rsp+0x40]
    1301:	add    rsp,0x50
    1305:	mov    rsp,rbp
    1308:	pop    rbp
    1309:	ret
    130a:	add    BYTE PTR [rax],al
    130c:	add    BYTE PTR [rax],al
    130e:	add    BYTE PTR [rax],al
    1310:	(bad)
    1311:	add    BYTE PTR [rax],al
    1313:	add    BYTE PTR [rax],al
    1315:	add    BYTE PTR [rax],al
	...

0000000000001318 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    1318:	push   rbp
    1319:	mov    rbp,rsp
    131c:	mov    rsi,QWORD PTR [rdx]
    131f:	mov    r8,QWORD PTR [rdx+0x8]
    1323:	mov    rcx,QWORD PTR [rdx+0x10]
    1327:	mov    rdx,r8
    132a:	call   132f <botlish_entry_20+0x17>
			132b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    132f:	mov    rsp,rbp
    1332:	pop    rbp
    1333:	ret

0000000000001334 <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1334:	push   rbp
    1335:	mov    rbp,rsp
    1338:	sub    rsp,0x80
    133f:	mov    QWORD PTR [rsp+0x50],rbx
    1344:	mov    QWORD PTR [rsp+0x58],r12
    1349:	mov    QWORD PTR [rsp+0x60],r13
    134e:	mov    QWORD PTR [rsp+0x68],r14
    1353:	mov    QWORD PTR [rsp+0x70],r15
    1358:	mov    r12,rdi
    135b:	mov    rdi,QWORD PTR [rbp+0x10]
    135f:	mov    QWORD PTR [rsp],rsi
    1363:	mov    QWORD PTR [rsp+0x38],rsi
    1368:	mov    QWORD PTR [rsp+0x8],rdx
    136d:	mov    r15,rdx
    1370:	mov    QWORD PTR [rsp+0x10],rcx
    1375:	mov    rbx,rcx
    1378:	mov    QWORD PTR [rsp+0x18],r8
    137d:	mov    QWORD PTR [rsp+0x40],r8
    1382:	mov    QWORD PTR [rsp+0x20],r9
    1387:	mov    r14,r9
    138a:	mov    QWORD PTR [rsp+0x28],rdi
    138f:	mov    r13,rdi
    1392:	mov    rsi,r14
    1395:	mov    rdi,r12
    1398:	call   139d <botlish_fn_21+0x69>
			1399: R_X86_64_PLT32	rt_hash-0x4
    139d:	test   rax,rax
    13a0:	mov    rsi,rax
    13a3:	je     1447 <botlish_fn_21+0x113>
    13a9:	mov    rdx,QWORD PTR [rsp+0x40]
    13ae:	mov    rdi,r12
    13b1:	call   13b6 <botlish_fn_21+0x82>
			13b2: R_X86_64_PLT32	rt_int_mod-0x4
    13b6:	test   rax,rax
    13b9:	je     1447 <botlish_fn_21+0x113>
    13bf:	mov    QWORD PTR [rsp+0x30],rax
    13c4:	mov    rcx,QWORD PTR [rsp+0x40]
    13c9:	mov    rdx,rax
    13cc:	mov    rsi,QWORD PTR [rsp+0x38]
    13d1:	mov    rdi,r12
    13d4:	call   13d9 <botlish_fn_21+0xa5>
			13d5: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    13d9:	test   rax,rax
    13dc:	mov    QWORD PTR [rsp+0x40],rax
    13e1:	je     1447 <botlish_fn_21+0x113>
    13e7:	mov    rdi,r12
    13ea:	call   13ef <botlish_fn_21+0xbb>
			13eb: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    13ef:	mov    ecx,0x3
    13f4:	mov    rsi,QWORD PTR [rsp+0x38]
    13f9:	mov    rdx,QWORD PTR [rsp+0x40]
    13fe:	mov    rdi,r12
    1401:	call   1406 <botlish_fn_21+0xd2>
			1402: R_X86_64_PLT32	rt_mutarray_set-0x4
    1406:	test   rax,rax
    1409:	je     1447 <botlish_fn_21+0x113>
    140f:	mov    rcx,r14
    1412:	mov    rsi,r15
    1415:	mov    rdx,QWORD PTR [rsp+0x40]
    141a:	mov    rdi,r12
    141d:	call   1422 <botlish_fn_21+0xee>
			141e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1422:	test   rax,rax
    1425:	je     1447 <botlish_fn_21+0x113>
    142b:	mov    rcx,r13
    142e:	mov    rdx,QWORD PTR [rsp+0x40]
    1433:	mov    rsi,rbx
    1436:	mov    rdi,r12
    1439:	call   143e <botlish_fn_21+0x10a>
			143a: R_X86_64_PLT32	rt_mutarray_set-0x4
    143e:	test   rax,rax
    1441:	jne    146f <botlish_fn_21+0x13b>
    1447:	xor    rax,rax
    144a:	mov    rbx,QWORD PTR [rsp+0x50]
    144f:	mov    r12,QWORD PTR [rsp+0x58]
    1454:	mov    r13,QWORD PTR [rsp+0x60]
    1459:	mov    r14,QWORD PTR [rsp+0x68]
    145e:	mov    r15,QWORD PTR [rsp+0x70]
    1463:	add    rsp,0x80
    146a:	mov    rsp,rbp
    146d:	pop    rbp
    146e:	ret
    146f:	mov    eax,0xa
    1474:	mov    rbx,QWORD PTR [rsp+0x50]
    1479:	mov    r12,QWORD PTR [rsp+0x58]
    147e:	mov    r13,QWORD PTR [rsp+0x60]
    1483:	mov    r14,QWORD PTR [rsp+0x68]
    1488:	mov    r15,QWORD PTR [rsp+0x70]
    148d:	add    rsp,0x80
    1494:	mov    rsp,rbp
    1497:	pop    rbp
    1498:	ret

0000000000001499 <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1499:	push   rbp
    149a:	mov    rbp,rsp
    149d:	sub    rsp,0x10
    14a1:	mov    rsi,QWORD PTR [rdx]
    14a4:	mov    r10,QWORD PTR [rdx+0x8]
    14a8:	mov    rcx,QWORD PTR [rdx+0x10]
    14ac:	mov    r8,QWORD PTR [rdx+0x18]
    14b0:	mov    r9,QWORD PTR [rdx+0x20]
    14b4:	mov    r11,QWORD PTR [rdx+0x28]
    14b8:	mov    QWORD PTR [rsp],r11
    14bc:	mov    rdx,r10
    14bf:	call   14c4 <botlish_entry_21+0x2b>
			14c0: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    14c4:	add    rsp,0x10
    14c8:	mov    rsp,rbp
    14cb:	pop    rbp
    14cc:	ret
    14cd:	add    BYTE PTR [rax],al
	...

00000000000014d0 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    14d0:	push   rbp
    14d1:	mov    rbp,rsp
    14d4:	sub    rsp,0xc0
    14db:	mov    QWORD PTR [rsp+0x90],rbx
    14e3:	mov    QWORD PTR [rsp+0x98],r12
    14eb:	mov    QWORD PTR [rsp+0xa0],r13
    14f3:	mov    QWORD PTR [rsp+0xa8],r14
    14fb:	mov    QWORD PTR [rsp+0xb0],r15
    1503:	mov    QWORD PTR [rsp+0x60],rdi
    1508:	mov    QWORD PTR [rsp+0x80],r9
    1510:	mov    r12,QWORD PTR [rbp+0x10]
    1514:	mov    r13,QWORD PTR [rbp+0x18]
    1518:	mov    r14,QWORD PTR [rbp+0x20]
    151c:	mov    rdi,QWORD PTR [rbp+0x28]
    1520:	mov    QWORD PTR [rsp+0x10],rsi
    1525:	mov    QWORD PTR [rsp+0x68],rsi
    152a:	mov    QWORD PTR [rsp+0x18],rdx
    152f:	mov    QWORD PTR [rsp+0x70],rdx
    1534:	mov    QWORD PTR [rsp+0x20],rcx
    1539:	mov    QWORD PTR [rsp+0x78],rcx
    153e:	mov    QWORD PTR [rsp+0x28],r8
    1543:	mov    rax,r12
    1546:	mov    QWORD PTR [rsp+0x30],rax
    154b:	mov    QWORD PTR [rsp+0x38],r13
    1550:	mov    QWORD PTR [rsp+0x40],r14
    1555:	mov    QWORD PTR [rsp+0x48],rdi
    155a:	mov    QWORD PTR [rsp+0x88],rdi
    1562:	mov    rsi,QWORD PTR [rsp+0x80]
    156a:	mov    rax,rsi
    156d:	or     rax,0x1
    1571:	mov    r15,r8
    1574:	mov    rcx,r15
    1577:	and    rcx,rax
    157a:	test   rcx,0x1
    1581:	jne    15b8 <botlish_fn_22+0xe8>
    1587:	mov    rdx,rsi
    158a:	or     rdx,0x1
    158e:	mov    QWORD PTR [rsp+0x80],rsi
    1596:	mov    rsi,r15
    1599:	mov    rdi,QWORD PTR [rsp+0x60]
    159e:	call   15a3 <botlish_fn_22+0xd3>
			159f: R_X86_64_PLT32	rt_int_cmp-0x4
    15a3:	mov    ecx,0x2
    15a8:	test   rax,rax
    15ab:	cmovge rcx,QWORD PTR [rip+0x2ed]        # 18a0 <botlish_fn_22+0x3d0>
    15b3:	jmp    15da <botlish_fn_22+0x10a>
    15b8:	mov    rdi,rsi
    15bb:	mov    QWORD PTR [rsp+0x80],rsi
    15c3:	mov    rax,rdi
    15c6:	or     rax,0x1
    15ca:	mov    ecx,0x2
    15cf:	cmp    r15,rax
    15d2:	cmovge rcx,QWORD PTR [rip+0x2c6]        # 18a0 <botlish_fn_22+0x3d0>
    15da:	cmp    rcx,0x6
    15de:	je     1863 <botlish_fn_22+0x393>
    15e4:	xor    eax,eax
    15e6:	mov    rsi,QWORD PTR [rsp+0x68]
    15eb:	test   rsi,0x7
    15f2:	jne    1601 <botlish_fn_22+0x131>
    15f8:	movzx  rax,BYTE PTR [rsi]
    15fc:	cmp    al,0x8
    15fe:	sete   al
    1601:	test   al,al
    1603:	jne    1625 <botlish_fn_22+0x155>
    1609:	mov    rdi,QWORD PTR [rsp+0x60]
    160e:	mov    rax,QWORD PTR [rdi+0x10]
    1612:	mov    rcx,QWORD PTR [rax+0x8]
    1616:	mov    edx,0x8
    161b:	call   1620 <botlish_fn_22+0x150>
			161c: R_X86_64_PLT32	rt_type_error-0x4
    1620:	jmp    17c7 <botlish_fn_22+0x2f7>
    1625:	mov    QWORD PTR [rsp+0x68],rsi
    162a:	mov    rdx,r15
    162d:	mov    rdi,QWORD PTR [rsp+0x60]
    1632:	call   1637 <botlish_fn_22+0x167>
			1633: R_X86_64_PLT32	rt_mutarray_get-0x4
    1637:	test   rax,rax
    163a:	mov    rbx,rax
    163d:	je     17c7 <botlish_fn_22+0x2f7>
    1643:	mov    rdi,QWORD PTR [rsp+0x60]
    1648:	call   164d <botlish_fn_22+0x17d>
			1649: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    164d:	mov    rax,rbx
    1650:	test   rax,0x1
    1656:	jne    167c <botlish_fn_22+0x1ac>
    165c:	mov    edx,0x3
    1661:	mov    rsi,rbx
    1664:	mov    rdi,QWORD PTR [rsp+0x60]
    1669:	call   166e <botlish_fn_22+0x19e>
			166a: R_X86_64_PLT32	rt_value_eq-0x4
    166e:	test   rax,rax
    1671:	je     17c7 <botlish_fn_22+0x2f7>
    1677:	jmp    1690 <botlish_fn_22+0x1c0>
    167c:	mov    rsi,rbx
    167f:	mov    eax,0x2
    1684:	cmp    rsi,0x3
    1688:	cmove  rax,QWORD PTR [rip+0x210]        # 18a0 <botlish_fn_22+0x3d0>
    1690:	cmp    rax,0x6
    1694:	je     16ac <botlish_fn_22+0x1dc>
    169a:	mov    rbx,QWORD PTR [rsp+0x88]
    16a2:	mov    rsi,QWORD PTR [rsp+0x68]
    16a7:	jmp    1803 <botlish_fn_22+0x333>
    16ac:	xor    eax,eax
    16ae:	mov    rdx,QWORD PTR [rsp+0x70]
    16b3:	test   rdx,0x7
    16ba:	je     16ca <botlish_fn_22+0x1fa>
    16c0:	mov    QWORD PTR [rsp+0x70],rdx
    16c5:	jmp    16d8 <botlish_fn_22+0x208>
    16ca:	movzx  rax,BYTE PTR [rdx]
    16ce:	mov    QWORD PTR [rsp+0x70],rdx
    16d3:	cmp    al,0x8
    16d5:	sete   al
    16d8:	test   al,al
    16da:	jne    1701 <botlish_fn_22+0x231>
    16e0:	mov    rdi,QWORD PTR [rsp+0x60]
    16e5:	mov    rax,QWORD PTR [rdi+0x10]
    16e9:	mov    rcx,QWORD PTR [rax+0x8]
    16ed:	mov    edx,0x8
    16f2:	mov    rsi,QWORD PTR [rsp+0x70]
    16f7:	call   16fc <botlish_fn_22+0x22c>
			16f8: R_X86_64_PLT32	rt_type_error-0x4
    16fc:	jmp    17c7 <botlish_fn_22+0x2f7>
    1701:	mov    rdx,r15
    1704:	mov    rsi,QWORD PTR [rsp+0x70]
    1709:	mov    rdi,QWORD PTR [rsp+0x60]
    170e:	call   1713 <botlish_fn_22+0x243>
			170f: R_X86_64_PLT32	rt_mutarray_get-0x4
    1713:	test   rax,rax
    1716:	je     17c7 <botlish_fn_22+0x2f7>
    171c:	mov    QWORD PTR [rsp+0x50],rax
    1721:	mov    rbx,rax
    1724:	xor    eax,eax
    1726:	mov    rcx,QWORD PTR [rsp+0x78]
    172b:	test   rcx,0x7
    1732:	je     1742 <botlish_fn_22+0x272>
    1738:	mov    QWORD PTR [rsp+0x78],rcx
    173d:	jmp    1750 <botlish_fn_22+0x280>
    1742:	movzx  rax,BYTE PTR [rcx]
    1746:	mov    QWORD PTR [rsp+0x78],rcx
    174b:	cmp    al,0x8
    174d:	sete   al
    1750:	test   al,al
    1752:	jne    1779 <botlish_fn_22+0x2a9>
    1758:	mov    rdi,QWORD PTR [rsp+0x60]
    175d:	mov    rdx,QWORD PTR [rdi+0x10]
    1761:	mov    rcx,QWORD PTR [rdx+0x8]
    1765:	mov    edx,0x8
    176a:	mov    rsi,QWORD PTR [rsp+0x78]
    176f:	call   1774 <botlish_fn_22+0x2a4>
			1770: R_X86_64_PLT32	rt_type_error-0x4
    1774:	jmp    17c7 <botlish_fn_22+0x2f7>
    1779:	mov    rdx,r15
    177c:	mov    rsi,QWORD PTR [rsp+0x78]
    1781:	mov    rdi,QWORD PTR [rsp+0x60]
    1786:	call   178b <botlish_fn_22+0x2bb>
			1787: R_X86_64_PLT32	rt_mutarray_get-0x4
    178b:	test   rax,rax
    178e:	je     17c7 <botlish_fn_22+0x2f7>
    1794:	mov    QWORD PTR [rsp+0x58],rax
    1799:	mov    QWORD PTR [rsp],rax
    179d:	mov    r9,rbx
    17a0:	mov    rbx,QWORD PTR [rsp+0x88]
    17a8:	mov    rcx,r14
    17ab:	mov    rdx,r13
    17ae:	mov    rsi,r12
    17b1:	mov    rdi,QWORD PTR [rsp+0x60]
    17b6:	mov    r8,rbx
    17b9:	call   17be <botlish_fn_22+0x2ee>
			17ba: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    17be:	test   rax,rax
    17c1:	jne    17fe <botlish_fn_22+0x32e>
    17c7:	xor    rax,rax
    17ca:	mov    rbx,QWORD PTR [rsp+0x90]
    17d2:	mov    r12,QWORD PTR [rsp+0x98]
    17da:	mov    r13,QWORD PTR [rsp+0xa0]
    17e2:	mov    r14,QWORD PTR [rsp+0xa8]
    17ea:	mov    r15,QWORD PTR [rsp+0xb0]
    17f2:	add    rsp,0xc0
    17f9:	mov    rsp,rbp
    17fc:	pop    rbp
    17fd:	ret
    17fe:	mov    rsi,QWORD PTR [rsp+0x68]
    1803:	mov    rsi,QWORD PTR [rsp+0x68]
    1808:	mov    QWORD PTR [rsp+0x10],rsi
    180d:	mov    rsi,QWORD PTR [rsp+0x70]
    1812:	mov    QWORD PTR [rsp+0x18],rsi
    1817:	mov    rsi,QWORD PTR [rsp+0x78]
    181c:	mov    QWORD PTR [rsp+0x20],rsi
    1821:	sar    r15,1
    1824:	add    r15,0x1
    182b:	shl    r15,1
    182e:	or     r15,0x1
    1832:	mov    QWORD PTR [rsp+0x28],r15
    1837:	mov    QWORD PTR [rsp+0x30],r12
    183c:	mov    QWORD PTR [rsp+0x38],r13
    1841:	mov    QWORD PTR [rsp+0x40],r14
    1846:	mov    QWORD PTR [rsp+0x48],rbx
    184b:	mov    rsi,QWORD PTR [rsp+0x80]
    1853:	mov    r8,r15
    1856:	mov    QWORD PTR [rsp+0x88],rbx
    185e:	jmp    156a <botlish_fn_22+0x9a>
    1863:	mov    eax,0xa
    1868:	mov    rbx,QWORD PTR [rsp+0x90]
    1870:	mov    r12,QWORD PTR [rsp+0x98]
    1878:	mov    r13,QWORD PTR [rsp+0xa0]
    1880:	mov    r14,QWORD PTR [rsp+0xa8]
    1888:	mov    r15,QWORD PTR [rsp+0xb0]
    1890:	add    rsp,0xc0
    1897:	mov    rsp,rbp
    189a:	pop    rbp
    189b:	ret
    189c:	add    BYTE PTR [rax],al
    189e:	add    BYTE PTR [rax],al
    18a0:	(bad)
    18a1:	add    BYTE PTR [rax],al
    18a3:	add    BYTE PTR [rax],al
    18a5:	add    BYTE PTR [rax],al
	...

00000000000018a8 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    18a8:	push   rbp
    18a9:	mov    rbp,rsp
    18ac:	sub    rsp,0x30
    18b0:	mov    QWORD PTR [rsp+0x20],r12
    18b5:	mov    rsi,QWORD PTR [rdx]
    18b8:	mov    rax,QWORD PTR [rdx+0x8]
    18bc:	mov    rcx,QWORD PTR [rdx+0x10]
    18c0:	mov    r8,QWORD PTR [rdx+0x18]
    18c4:	mov    r9,QWORD PTR [rdx+0x20]
    18c8:	mov    r10,QWORD PTR [rdx+0x28]
    18cc:	mov    r11,QWORD PTR [rdx+0x30]
    18d0:	mov    r12,QWORD PTR [rdx+0x38]
    18d4:	mov    rdx,QWORD PTR [rdx+0x40]
    18d8:	mov    QWORD PTR [rsp],r10
    18dc:	mov    QWORD PTR [rsp+0x8],r11
    18e1:	mov    QWORD PTR [rsp+0x10],r12
    18e6:	mov    QWORD PTR [rsp+0x18],rdx
    18eb:	mov    rdx,rax
    18ee:	call   18f3 <botlish_entry_22+0x4b>
			18ef: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    18f3:	mov    r12,QWORD PTR [rsp+0x20]
    18f8:	add    rsp,0x30
    18fc:	mov    rsp,rbp
    18ff:	pop    rbp
    1900:	ret

0000000000001901 <botlish_fn_23: ht_rehash<mutarray, int>>:
    1901:	push   rbp
    1902:	mov    rbp,rsp
    1905:	sub    rsp,0xd0
    190c:	mov    QWORD PTR [rsp+0xa0],rbx
    1914:	mov    QWORD PTR [rsp+0xa8],r12
    191c:	mov    QWORD PTR [rsp+0xb0],r13
    1924:	mov    QWORD PTR [rsp+0xb8],r14
    192c:	mov    QWORD PTR [rsp+0xc0],r15
    1934:	mov    r13,rdi
    1937:	mov    QWORD PTR [rsp+0x50],0x0
    1940:	mov    QWORD PTR [rsp+0x58],0x0
    1949:	mov    QWORD PTR [rsp+0x60],0x0
    1952:	mov    QWORD PTR [rsp+0x68],0x0
    195b:	mov    QWORD PTR [rsp+0x20],rsi
    1960:	mov    r12,rsi
    1963:	mov    QWORD PTR [rsp+0x28],rdx
    1968:	mov    rbx,rdx
    196b:	mov    rsi,r12
    196e:	mov    rdi,r13
    1971:	call   1976 <botlish_fn_23+0x75>
			1972: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    1976:	test   rax,rax
    1979:	je     1b48 <botlish_fn_23+0x247>
    197f:	mov    QWORD PTR [rsp+0x30],rax
    1984:	mov    r14,rax
    1987:	mov    rsi,r12
    198a:	mov    rdi,r13
    198d:	call   1992 <botlish_fn_23+0x91>
			198e: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    1992:	test   rax,rax
    1995:	je     1b48 <botlish_fn_23+0x247>
    199b:	mov    QWORD PTR [rsp+0x38],rax
    19a0:	mov    r15,rax
    19a3:	mov    rsi,r12
    19a6:	mov    rdi,r13
    19a9:	call   19ae <botlish_fn_23+0xad>
			19aa: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    19ae:	test   rax,rax
    19b1:	je     1b48 <botlish_fn_23+0x247>
    19b7:	mov    QWORD PTR [rsp+0x40],rax
    19bc:	mov    QWORD PTR [rsp+0x90],rax
    19c4:	mov    rsi,r12
    19c7:	mov    rdi,r13
    19ca:	call   19cf <botlish_fn_23+0xce>
			19cb: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    19cf:	test   rax,rax
    19d2:	je     1b48 <botlish_fn_23+0x247>
    19d8:	mov    QWORD PTR [rsp+0x48],rax
    19dd:	mov    QWORD PTR [rsp+0x88],rax
    19e5:	mov    rsi,rbx
    19e8:	mov    rdi,r13
    19eb:	call   19f0 <botlish_fn_23+0xef>
			19ec: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    19f0:	mov    rcx,rax
    19f3:	mov    QWORD PTR [rsp+0x80],rax
    19fb:	test   rax,rcx
    19fe:	je     1b48 <botlish_fn_23+0x247>
    1a04:	mov    rax,QWORD PTR [rsp+0x80]
    1a0c:	mov    QWORD PTR [rsp+0x50],rax
    1a11:	mov    edx,0x1
    1a16:	mov    QWORD PTR [rsp+0x58],0x1
    1a1f:	mov    rcx,rbx
    1a22:	mov    rsi,QWORD PTR [rsp+0x80]
    1a2a:	mov    rdi,r13
    1a2d:	call   1a32 <botlish_fn_23+0x131>
			1a2e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    1a32:	test   rax,rax
    1a35:	je     1b48 <botlish_fn_23+0x247>
    1a3b:	mov    rsi,rbx
    1a3e:	mov    rdi,r13
    1a41:	call   1a46 <botlish_fn_23+0x145>
			1a42: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a46:	test   rax,rax
    1a49:	je     1b48 <botlish_fn_23+0x247>
    1a4f:	mov    QWORD PTR [rsp+0x58],rax
    1a54:	mov    QWORD PTR [rsp+0x78],rax
    1a59:	mov    rsi,rbx
    1a5c:	mov    rdi,r13
    1a5f:	call   1a64 <botlish_fn_23+0x163>
			1a60: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a64:	test   rax,rax
    1a67:	je     1b48 <botlish_fn_23+0x247>
    1a6d:	mov    QWORD PTR [rsp+0x60],rax
    1a72:	mov    r8d,0x1
    1a78:	mov    QWORD PTR [rsp+0x68],0x1
    1a81:	mov    rcx,QWORD PTR [rsp+0x80]
    1a89:	mov    QWORD PTR [rsp],rcx
    1a8d:	mov    rcx,QWORD PTR [rsp+0x78]
    1a92:	mov    QWORD PTR [rsp+0x8],rcx
    1a97:	mov    QWORD PTR [rsp+0x10],rax
    1a9c:	mov    QWORD PTR [rsp+0x70],rax
    1aa1:	mov    QWORD PTR [rsp+0x18],rbx
    1aa6:	mov    rcx,QWORD PTR [rsp+0x90]
    1aae:	mov    rdx,r15
    1ab1:	mov    rsi,r14
    1ab4:	mov    r9,QWORD PTR [rsp+0x88]
    1abc:	mov    rdi,r13
    1abf:	call   1ac4 <botlish_fn_23+0x1c3>
			1ac0: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    1ac4:	test   rax,rax
    1ac7:	je     1b48 <botlish_fn_23+0x247>
    1acd:	mov    edx,0x1
    1ad2:	mov    rcx,QWORD PTR [rsp+0x80]
    1ada:	mov    rsi,r12
    1add:	mov    rdi,r13
    1ae0:	call   1ae5 <botlish_fn_23+0x1e4>
			1ae1: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ae5:	test   rax,rax
    1ae8:	je     1b48 <botlish_fn_23+0x247>
    1aee:	mov    edx,0x3
    1af3:	mov    rcx,QWORD PTR [rsp+0x78]
    1af8:	mov    rsi,r12
    1afb:	mov    rdi,r13
    1afe:	call   1b03 <botlish_fn_23+0x202>
			1aff: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b03:	test   rax,rax
    1b06:	je     1b48 <botlish_fn_23+0x247>
    1b0c:	mov    edx,0x5
    1b11:	mov    rcx,QWORD PTR [rsp+0x70]
    1b16:	mov    rsi,r12
    1b19:	mov    rdi,r13
    1b1c:	call   1b21 <botlish_fn_23+0x220>
			1b1d: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b21:	test   rax,rax
    1b24:	je     1b48 <botlish_fn_23+0x247>
    1b2a:	mov    edx,0x9
    1b2f:	mov    ecx,0x1
    1b34:	mov    rsi,r12
    1b37:	mov    rdi,r13
    1b3a:	call   1b3f <botlish_fn_23+0x23e>
			1b3b: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b3f:	test   rax,rax
    1b42:	jne    1b7f <botlish_fn_23+0x27e>
    1b48:	xor    rax,rax
    1b4b:	mov    rbx,QWORD PTR [rsp+0xa0]
    1b53:	mov    r12,QWORD PTR [rsp+0xa8]
    1b5b:	mov    r13,QWORD PTR [rsp+0xb0]
    1b63:	mov    r14,QWORD PTR [rsp+0xb8]
    1b6b:	mov    r15,QWORD PTR [rsp+0xc0]
    1b73:	add    rsp,0xd0
    1b7a:	mov    rsp,rbp
    1b7d:	pop    rbp
    1b7e:	ret
    1b7f:	mov    eax,0xa
    1b84:	mov    rbx,QWORD PTR [rsp+0xa0]
    1b8c:	mov    r12,QWORD PTR [rsp+0xa8]
    1b94:	mov    r13,QWORD PTR [rsp+0xb0]
    1b9c:	mov    r14,QWORD PTR [rsp+0xb8]
    1ba4:	mov    r15,QWORD PTR [rsp+0xc0]
    1bac:	add    rsp,0xd0
    1bb3:	mov    rsp,rbp
    1bb6:	pop    rbp
    1bb7:	ret

0000000000001bb8 <botlish_entry_23: ht_rehash<mutarray, int>>:
    1bb8:	push   rbp
    1bb9:	mov    rbp,rsp
    1bbc:	mov    rsi,QWORD PTR [rdx]
    1bbf:	mov    rdx,QWORD PTR [rdx+0x8]
    1bc3:	call   1bc8 <botlish_entry_23+0x10>
			1bc4: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    1bc8:	mov    rsp,rbp
    1bcb:	pop    rbp
    1bcc:	ret
    1bcd:	add    BYTE PTR [rax],al
	...

0000000000001bd0 <botlish_fn_24: ht_should_grow<mutarray>>:
    1bd0:	push   rbp
    1bd1:	mov    rbp,rsp
    1bd4:	sub    rsp,0x40
    1bd8:	mov    QWORD PTR [rsp+0x20],rbx
    1bdd:	mov    QWORD PTR [rsp+0x28],r12
    1be2:	mov    QWORD PTR [rsp+0x30],r13
    1be7:	mov    rbx,rdi
    1bea:	mov    QWORD PTR [rsp],rsi
    1bee:	mov    r12,rsi
    1bf1:	mov    rsi,r12
    1bf4:	mov    rdi,rbx
    1bf7:	call   1bfc <botlish_fn_24+0x2c>
			1bf8: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    1bfc:	mov    rcx,rax
    1bff:	mov    r13,rax
    1c02:	test   rax,rcx
    1c05:	je     1df4 <botlish_fn_24+0x224>
    1c0b:	mov    rax,r13
    1c0e:	mov    QWORD PTR [rsp+0x8],rax
    1c13:	mov    rsi,r12
    1c16:	mov    rdi,rbx
    1c19:	call   1c1e <botlish_fn_24+0x4e>
			1c1a: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    1c1e:	mov    rcx,rax
    1c21:	test   rcx,rcx
    1c24:	je     1df4 <botlish_fn_24+0x224>
    1c2a:	mov    QWORD PTR [rsp+0x10],rcx
    1c2f:	mov    edx,0x1
    1c34:	mov    rax,r13
    1c37:	test   rax,0x1
    1c3d:	jne    1c60 <botlish_fn_24+0x90>
    1c43:	xor    edx,edx
    1c45:	mov    rax,r13
    1c48:	test   rax,0x7
    1c4e:	jne    1c60 <botlish_fn_24+0x90>
    1c54:	mov    rax,r13
    1c57:	movzx  rax,BYTE PTR [rax]
    1c5b:	cmp    al,0x1
    1c5d:	sete   dl
    1c60:	test   dl,dl
    1c62:	jne    1c83 <botlish_fn_24+0xb3>
    1c68:	mov    rdi,rbx
    1c6b:	mov    rax,QWORD PTR [rdi+0x10]
    1c6f:	mov    rcx,QWORD PTR [rax+0x10]
    1c73:	xor    rdx,rdx
    1c76:	mov    rsi,r13
    1c79:	call   1c7e <botlish_fn_24+0xae>
			1c7a: R_X86_64_PLT32	rt_type_error-0x4
    1c7e:	jmp    1df4 <botlish_fn_24+0x224>
    1c83:	mov    eax,0x1
    1c88:	test   rcx,0x1
    1c8f:	je     1c9d <botlish_fn_24+0xcd>
    1c95:	mov    r8,rcx
    1c98:	jmp    1cc0 <botlish_fn_24+0xf0>
    1c9d:	xor    eax,eax
    1c9f:	test   rcx,0x7
    1ca6:	je     1cb4 <botlish_fn_24+0xe4>
    1cac:	mov    r8,rcx
    1caf:	jmp    1cc0 <botlish_fn_24+0xf0>
    1cb4:	movzx  rax,BYTE PTR [rcx]
    1cb8:	mov    r8,rcx
    1cbb:	cmp    al,0x1
    1cbd:	sete   al
    1cc0:	test   al,al
    1cc2:	jne    1ce3 <botlish_fn_24+0x113>
    1cc8:	mov    rdi,rbx
    1ccb:	mov    rax,QWORD PTR [rdi+0x10]
    1ccf:	mov    rcx,QWORD PTR [rax+0x10]
    1cd3:	xor    rdx,rdx
    1cd6:	mov    rsi,r8
    1cd9:	call   1cde <botlish_fn_24+0x10e>
			1cda: R_X86_64_PLT32	rt_type_error-0x4
    1cde:	jmp    1df4 <botlish_fn_24+0x224>
    1ce3:	mov    rcx,r8
    1ce6:	mov    rsi,r13
    1ce9:	mov    rax,rsi
    1cec:	and    rax,rcx
    1cef:	test   rax,0x1
    1cf5:	jne    1d06 <botlish_fn_24+0x136>
    1cfb:	mov    rdx,r8
    1cfe:	mov    rsi,r13
    1d01:	jmp    1d24 <botlish_fn_24+0x154>
    1d06:	mov    rcx,r8
    1d09:	lea    rax,[rcx-0x1]
    1d0d:	mov    rsi,r13
    1d10:	add    rsi,rax
    1d13:	seto   al
    1d16:	test   al,al
    1d18:	je     1d2f <botlish_fn_24+0x15f>
    1d1e:	mov    rdx,r8
    1d21:	mov    rsi,r13
    1d24:	mov    rdi,rbx
    1d27:	call   1d2c <botlish_fn_24+0x15c>
			1d28: R_X86_64_PLT32	rt_int_add-0x4
    1d2c:	mov    rsi,rax
    1d2f:	mov    QWORD PTR [rsp+0x8],rsi
    1d34:	mov    QWORD PTR [rsp+0x10],0x3
    1d3d:	test   rsi,0x1
    1d44:	je     1d67 <botlish_fn_24+0x197>
    1d4a:	mov    rax,rsi
    1d4d:	add    rax,0x2
    1d51:	mov    rcx,rax
    1d54:	seto   al
    1d57:	test   al,al
    1d59:	jne    1d67 <botlish_fn_24+0x197>
    1d5f:	mov    rsi,rcx
    1d62:	jmp    1d77 <botlish_fn_24+0x1a7>
    1d67:	mov    edx,0x3
    1d6c:	mov    rdi,rbx
    1d6f:	call   1d74 <botlish_fn_24+0x1a4>
			1d70: R_X86_64_PLT32	rt_int_add-0x4
    1d74:	mov    rsi,rax
    1d77:	mov    QWORD PTR [rsp+0x8],rsi
    1d7c:	mov    edx,0x7
    1d81:	mov    rdi,rdx
    1d84:	mov    QWORD PTR [rsp+0x10],0x7
    1d8d:	test   rsi,0x1
    1d94:	jne    1da2 <botlish_fn_24+0x1d2>
    1d9a:	mov    rdx,rdi
    1d9d:	jmp    1dce <botlish_fn_24+0x1fe>
    1da2:	mov    rax,rsi
    1da5:	sar    rax,1
    1da8:	imul   QWORD PTR [rip+0x119]        # 1ec8 <botlish_fn_24+0x2f8>
    1daf:	seto   cl
    1db2:	or     rax,0x1
    1db6:	test   cl,cl
    1db8:	je     1dc6 <botlish_fn_24+0x1f6>
    1dbe:	mov    rdx,rdi
    1dc1:	jmp    1dce <botlish_fn_24+0x1fe>
    1dc6:	mov    rsi,rax
    1dc9:	jmp    1dd9 <botlish_fn_24+0x209>
    1dce:	mov    rdi,rbx
    1dd1:	call   1dd6 <botlish_fn_24+0x206>
			1dd2: R_X86_64_PLT32	rt_int_mul-0x4
    1dd6:	mov    rsi,rax
    1dd9:	mov    QWORD PTR [rsp],rsi
    1ddd:	mov    r13,rsi
    1de0:	mov    rsi,r12
    1de3:	mov    rdi,rbx
    1de6:	call   1deb <botlish_fn_24+0x21b>
			1de7: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    1deb:	test   rax,rax
    1dee:	jne    1e0f <botlish_fn_24+0x23f>
    1df4:	xor    rax,rax
    1df7:	mov    rbx,QWORD PTR [rsp+0x20]
    1dfc:	mov    r12,QWORD PTR [rsp+0x28]
    1e01:	mov    r13,QWORD PTR [rsp+0x30]
    1e06:	add    rsp,0x40
    1e0a:	mov    rsp,rbp
    1e0d:	pop    rbp
    1e0e:	ret
    1e0f:	mov    QWORD PTR [rsp+0x8],rax
    1e14:	mov    QWORD PTR [rsp+0x10],0x5
    1e1d:	test   rax,0x1
    1e23:	mov    rsi,rax
    1e26:	je     1e58 <botlish_fn_24+0x288>
    1e2c:	mov    rcx,rsi
    1e2f:	mov    rax,rcx
    1e32:	sar    rax,1
    1e35:	imul   QWORD PTR [rip+0x94]        # 1ed0 <botlish_fn_24+0x300>
    1e3c:	seto   dil
    1e40:	or     rax,0x1
    1e44:	test   dil,dil
    1e47:	jne    1e58 <botlish_fn_24+0x288>
    1e4d:	mov    rdx,rax
    1e50:	mov    rsi,r13
    1e53:	jmp    1e6b <botlish_fn_24+0x29b>
    1e58:	mov    edx,0x5
    1e5d:	mov    rdi,rbx
    1e60:	call   1e65 <botlish_fn_24+0x295>
			1e61: R_X86_64_PLT32	rt_int_mul-0x4
    1e65:	mov    rdx,rax
    1e68:	mov    rsi,r13
    1e6b:	mov    r10,rsi
    1e6e:	and    r10,rdx
    1e71:	test   r10,0x1
    1e78:	jne    1e9f <botlish_fn_24+0x2cf>
    1e7e:	mov    rdi,rbx
    1e81:	call   1e86 <botlish_fn_24+0x2b6>
			1e82: R_X86_64_PLT32	rt_int_cmp-0x4
    1e86:	mov    r8d,0x2
    1e8c:	test   rax,rax
    1e8f:	mov    rax,r8
    1e92:	cmovg  rax,QWORD PTR [rip+0x2e]        # 1ec8 <botlish_fn_24+0x2f8>
    1e9a:	jmp    1eaf <botlish_fn_24+0x2df>
    1e9f:	mov    eax,0x2
    1ea4:	cmp    rsi,rdx
    1ea7:	cmovg  rax,QWORD PTR [rip+0x19]        # 1ec8 <botlish_fn_24+0x2f8>
    1eaf:	mov    rbx,QWORD PTR [rsp+0x20]
    1eb4:	mov    r12,QWORD PTR [rsp+0x28]
    1eb9:	mov    r13,QWORD PTR [rsp+0x30]
    1ebe:	add    rsp,0x40
    1ec2:	mov    rsp,rbp
    1ec5:	pop    rbp
    1ec6:	ret
    1ec7:	add    BYTE PTR [rsi],al
    1ec9:	add    BYTE PTR [rax],al
    1ecb:	add    BYTE PTR [rax],al
    1ecd:	add    BYTE PTR [rax],al
    1ecf:	add    BYTE PTR [rax+rax*1],al
    1ed2:	add    BYTE PTR [rax],al
    1ed4:	add    BYTE PTR [rax],al
	...

0000000000001ed8 <botlish_entry_24: ht_should_grow<mutarray>>:
    1ed8:	push   rbp
    1ed9:	mov    rbp,rsp
    1edc:	mov    rsi,QWORD PTR [rdx]
    1edf:	call   1ee4 <botlish_entry_24+0xc>
			1ee0: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    1ee4:	mov    rsp,rbp
    1ee7:	pop    rbp
    1ee8:	ret
    1ee9:	add    BYTE PTR [rax],al
    1eeb:	add    BYTE PTR [rax],al
    1eed:	add    BYTE PTR [rax],al
	...

0000000000001ef0 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    1ef0:	push   rbp
    1ef1:	mov    rbp,rsp
    1ef4:	sub    rsp,0x40
    1ef8:	mov    QWORD PTR [rsp+0x20],rbx
    1efd:	mov    QWORD PTR [rsp+0x28],r12
    1f02:	mov    QWORD PTR [rsp+0x30],r13
    1f07:	mov    rbx,rdi
    1f0a:	mov    QWORD PTR [rsp+0x10],0x0
    1f13:	mov    QWORD PTR [rsp],rsi
    1f17:	mov    r12,rsi
    1f1a:	mov    rsi,r12
    1f1d:	mov    rdi,rbx
    1f20:	call   1f25 <botlish_fn_25+0x35>
			1f21: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    1f25:	test   rax,rax
    1f28:	mov    r13,rax
    1f2b:	je     2118 <botlish_fn_25+0x228>
    1f31:	mov    rsi,r12
    1f34:	mov    rdi,rbx
    1f37:	call   1f3c <botlish_fn_25+0x4c>
			1f38: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    1f3c:	mov    rcx,rax
    1f3f:	test   rcx,rcx
    1f42:	je     2118 <botlish_fn_25+0x228>
    1f48:	mov    edx,0x1
    1f4d:	mov    rax,r13
    1f50:	test   rax,0x1
    1f56:	je     1f64 <botlish_fn_25+0x74>
    1f5c:	mov    r13,rax
    1f5f:	jmp    1f88 <botlish_fn_25+0x98>
    1f64:	xor    edx,edx
    1f66:	test   rax,0x7
    1f6c:	je     1f7a <botlish_fn_25+0x8a>
    1f72:	mov    r13,rax
    1f75:	jmp    1f88 <botlish_fn_25+0x98>
    1f7a:	movzx  rdx,BYTE PTR [rax]
    1f7e:	mov    r13,rax
    1f81:	rex cmp dl,0x1
    1f85:	sete   dl
    1f88:	test   dl,dl
    1f8a:	jne    1fab <botlish_fn_25+0xbb>
    1f90:	mov    rdi,rbx
    1f93:	mov    rsi,QWORD PTR [rdi+0x10]
    1f97:	mov    rcx,QWORD PTR [rsi+0x18]
    1f9b:	xor    rdx,rdx
    1f9e:	mov    rsi,r13
    1fa1:	call   1fa6 <botlish_fn_25+0xb6>
			1fa2: R_X86_64_PLT32	rt_type_error-0x4
    1fa6:	jmp    2118 <botlish_fn_25+0x228>
    1fab:	mov    rsi,r13
    1fae:	mov    eax,0x1
    1fb3:	test   rcx,0x1
    1fba:	je     1fc8 <botlish_fn_25+0xd8>
    1fc0:	mov    r8,rcx
    1fc3:	jmp    1fed <botlish_fn_25+0xfd>
    1fc8:	xor    eax,eax
    1fca:	test   rcx,0x7
    1fd1:	je     1fdf <botlish_fn_25+0xef>
    1fd7:	mov    r8,rcx
    1fda:	jmp    1fed <botlish_fn_25+0xfd>
    1fdf:	movzx  r11,BYTE PTR [rcx]
    1fe3:	mov    r8,rcx
    1fe6:	cmp    r11b,0x1
    1fea:	sete   al
    1fed:	test   al,al
    1fef:	jne    2010 <botlish_fn_25+0x120>
    1ff5:	mov    rdi,rbx
    1ff8:	mov    rax,QWORD PTR [rdi+0x10]
    1ffc:	mov    rcx,QWORD PTR [rax+0x18]
    2000:	xor    rdx,rdx
    2003:	mov    rsi,r8
    2006:	call   200b <botlish_fn_25+0x11b>
			2007: R_X86_64_PLT32	rt_type_error-0x4
    200b:	jmp    2118 <botlish_fn_25+0x228>
    2010:	mov    rcx,r8
    2013:	mov    rax,rsi
    2016:	and    rax,rcx
    2019:	test   rax,0x1
    201f:	jne    2045 <botlish_fn_25+0x155>
    2025:	mov    rdx,r8
    2028:	mov    rdi,rbx
    202b:	call   2030 <botlish_fn_25+0x140>
			202c: R_X86_64_PLT32	rt_int_cmp-0x4
    2030:	mov    ecx,0x2
    2035:	test   rax,rax
    2038:	cmovg  rcx,QWORD PTR [rip+0x110]        # 2150 <botlish_fn_25+0x260>
    2040:	jmp    2058 <botlish_fn_25+0x168>
    2045:	mov    ecx,0x2
    204a:	mov    r9,r8
    204d:	cmp    rsi,r9
    2050:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 2150 <botlish_fn_25+0x260>
    2058:	cmp    rcx,0x6
    205c:	je     20e8 <botlish_fn_25+0x1f8>
    2062:	mov    rsi,r12
    2065:	mov    rdi,rbx
    2068:	call   206d <botlish_fn_25+0x17d>
			2069: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    206d:	test   rax,rax
    2070:	je     2118 <botlish_fn_25+0x228>
    2076:	mov    QWORD PTR [rsp+0x8],rax
    207b:	mov    QWORD PTR [rsp+0x10],0x5
    2084:	test   rax,0x1
    208a:	mov    rsi,rax
    208d:	je     20ba <botlish_fn_25+0x1ca>
    2093:	mov    rcx,rsi
    2096:	mov    rax,rcx
    2099:	sar    rax,1
    209c:	imul   QWORD PTR [rip+0xb5]        # 2158 <botlish_fn_25+0x268>
    20a3:	seto   cl
    20a6:	or     rax,0x1
    20aa:	test   cl,cl
    20ac:	jne    20ba <botlish_fn_25+0x1ca>
    20b2:	mov    rdx,rax
    20b5:	jmp    20ca <botlish_fn_25+0x1da>
    20ba:	mov    edx,0x5
    20bf:	mov    rdi,rbx
    20c2:	call   20c7 <botlish_fn_25+0x1d7>
			20c3: R_X86_64_PLT32	rt_int_mul-0x4
    20c7:	mov    rdx,rax
    20ca:	mov    QWORD PTR [rsp+0x8],rdx
    20cf:	mov    rsi,r12
    20d2:	mov    rdi,rbx
    20d5:	call   20da <botlish_fn_25+0x1ea>
			20d6: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    20da:	test   rax,rax
    20dd:	je     2118 <botlish_fn_25+0x228>
    20e3:	jmp    2133 <botlish_fn_25+0x243>
    20e8:	mov    rsi,r12
    20eb:	mov    rdi,rbx
    20ee:	call   20f3 <botlish_fn_25+0x203>
			20ef: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    20f3:	test   rax,rax
    20f6:	je     2118 <botlish_fn_25+0x228>
    20fc:	mov    QWORD PTR [rsp+0x8],rax
    2101:	mov    rdx,rax
    2104:	mov    rsi,r12
    2107:	mov    rdi,rbx
    210a:	call   210f <botlish_fn_25+0x21f>
			210b: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    210f:	test   rax,rax
    2112:	jne    2133 <botlish_fn_25+0x243>
    2118:	xor    rax,rax
    211b:	mov    rbx,QWORD PTR [rsp+0x20]
    2120:	mov    r12,QWORD PTR [rsp+0x28]
    2125:	mov    r13,QWORD PTR [rsp+0x30]
    212a:	add    rsp,0x40
    212e:	mov    rsp,rbp
    2131:	pop    rbp
    2132:	ret
    2133:	mov    rbx,QWORD PTR [rsp+0x20]
    2138:	mov    r12,QWORD PTR [rsp+0x28]
    213d:	mov    r13,QWORD PTR [rsp+0x30]
    2142:	add    rsp,0x40
    2146:	mov    rsp,rbp
    2149:	pop    rbp
    214a:	ret
    214b:	add    BYTE PTR [rax],al
    214d:	add    BYTE PTR [rax],al
    214f:	add    BYTE PTR [rsi],al
    2151:	add    BYTE PTR [rax],al
    2153:	add    BYTE PTR [rax],al
    2155:	add    BYTE PTR [rax],al
    2157:	add    BYTE PTR [rax+rax*1],al
    215a:	add    BYTE PTR [rax],al
    215c:	add    BYTE PTR [rax],al
	...

0000000000002160 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    2160:	push   rbp
    2161:	mov    rbp,rsp
    2164:	mov    rsi,QWORD PTR [rdx]
    2167:	call   216c <botlish_entry_25+0xc>
			2168: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    216c:	mov    rsp,rbp
    216f:	pop    rbp
    2170:	ret
    2171:	add    BYTE PTR [rax],al
    2173:	add    BYTE PTR [rax],al
    2175:	add    BYTE PTR [rax],al
	...

0000000000002178 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    2178:	push   rbp
    2179:	mov    rbp,rsp
    217c:	sub    rsp,0x70
    2180:	mov    QWORD PTR [rsp+0x40],rbx
    2185:	mov    QWORD PTR [rsp+0x48],r12
    218a:	mov    QWORD PTR [rsp+0x50],r13
    218f:	mov    QWORD PTR [rsp+0x58],r14
    2194:	mov    QWORD PTR [rsp+0x60],r15
    2199:	mov    rbx,rdi
    219c:	mov    r14,r8
    219f:	mov    r15,rdx
    21a2:	mov    QWORD PTR [rsp+0x28],rcx
    21a7:	mov    QWORD PTR [rsp],rsi
    21ab:	mov    r12,rsi
    21ae:	mov    rsi,r12
    21b1:	mov    rdi,rbx
    21b4:	call   21b9 <botlish_fn_26+0x41>
			21b5: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    21b9:	test   rax,rax
    21bc:	je     2528 <botlish_fn_26+0x3b0>
    21c2:	xor    ecx,ecx
    21c4:	test   rax,0x7
    21ca:	je     21da <botlish_fn_26+0x62>
    21d0:	mov    QWORD PTR [rsp+0x30],rax
    21d5:	jmp    21ea <botlish_fn_26+0x72>
    21da:	movzx  rcx,BYTE PTR [rax]
    21de:	mov    QWORD PTR [rsp+0x30],rax
    21e3:	rex cmp cl,0x8
    21e7:	sete   cl
    21ea:	test   cl,cl
    21ec:	jne    2211 <botlish_fn_26+0x99>
    21f2:	mov    rdi,rbx
    21f5:	mov    rax,QWORD PTR [rdi+0x10]
    21f9:	mov    rcx,QWORD PTR [rax+0x8]
    21fd:	mov    edx,0x8
    2202:	mov    rsi,QWORD PTR [rsp+0x30]
    2207:	call   220c <botlish_fn_26+0x94>
			2208: R_X86_64_PLT32	rt_type_error-0x4
    220c:	jmp    2528 <botlish_fn_26+0x3b0>
    2211:	mov    rdx,r15
    2214:	mov    rsi,QWORD PTR [rsp+0x30]
    2219:	mov    rdi,rbx
    221c:	call   2221 <botlish_fn_26+0xa9>
			221d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2221:	test   rax,rax
    2224:	je     2528 <botlish_fn_26+0x3b0>
    222a:	mov    QWORD PTR [rsp+0x8],rax
    222f:	mov    r13,rax
    2232:	mov    rdi,rbx
    2235:	call   223a <botlish_fn_26+0xc2>
			2236: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    223a:	mov    ecx,0x3
    223f:	mov    rsi,QWORD PTR [rsp+0x30]
    2244:	mov    rdx,r15
    2247:	mov    rdi,rbx
    224a:	call   224f <botlish_fn_26+0xd7>
			224b: R_X86_64_PLT32	rt_mutarray_set-0x4
    224f:	test   rax,rax
    2252:	je     2528 <botlish_fn_26+0x3b0>
    2258:	mov    rsi,r12
    225b:	mov    rdi,rbx
    225e:	call   2263 <botlish_fn_26+0xeb>
			225f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2263:	test   rax,rax
    2266:	je     2528 <botlish_fn_26+0x3b0>
    226c:	xor    ecx,ecx
    226e:	test   rax,0x7
    2274:	je     2282 <botlish_fn_26+0x10a>
    227a:	mov    rsi,rax
    227d:	jmp    2290 <botlish_fn_26+0x118>
    2282:	movzx  rcx,BYTE PTR [rax]
    2286:	mov    rsi,rax
    2289:	rex cmp cl,0x8
    228d:	sete   cl
    2290:	test   cl,cl
    2292:	jne    22b2 <botlish_fn_26+0x13a>
    2298:	mov    rdi,rbx
    229b:	mov    rax,QWORD PTR [rdi+0x10]
    229f:	mov    rcx,QWORD PTR [rax+0x20]
    22a3:	mov    edx,0x8
    22a8:	call   22ad <botlish_fn_26+0x135>
			22a9: R_X86_64_PLT32	rt_type_error-0x4
    22ad:	jmp    2528 <botlish_fn_26+0x3b0>
    22b2:	mov    rcx,QWORD PTR [rsp+0x28]
    22b7:	mov    rdx,r15
    22ba:	mov    rdi,rbx
    22bd:	call   22c2 <botlish_fn_26+0x14a>
			22be: R_X86_64_PLT32	rt_mutarray_set-0x4
    22c2:	test   rax,rax
    22c5:	je     2528 <botlish_fn_26+0x3b0>
    22cb:	mov    rsi,r12
    22ce:	mov    rdi,rbx
    22d1:	call   22d6 <botlish_fn_26+0x15e>
			22d2: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    22d6:	test   rax,rax
    22d9:	je     2528 <botlish_fn_26+0x3b0>
    22df:	xor    esi,esi
    22e1:	test   rax,0x7
    22e7:	jne    22f9 <botlish_fn_26+0x181>
    22ed:	movzx  rsi,BYTE PTR [rax]
    22f1:	cmp    sil,0x8
    22f5:	sete   sil
    22f9:	test   sil,sil
    22fc:	jne    2322 <botlish_fn_26+0x1aa>
    2302:	mov    rdi,rbx
    2305:	mov    rdi,QWORD PTR [rdi+0x10]
    2309:	mov    rcx,QWORD PTR [rdi+0x20]
    230d:	mov    edx,0x8
    2312:	mov    rsi,rax
    2315:	mov    rdi,rbx
    2318:	call   231d <botlish_fn_26+0x1a5>
			2319: R_X86_64_PLT32	rt_type_error-0x4
    231d:	jmp    2528 <botlish_fn_26+0x3b0>
    2322:	mov    rcx,r14
    2325:	mov    rdx,r15
    2328:	mov    rsi,rax
    232b:	mov    rdi,rbx
    232e:	call   2333 <botlish_fn_26+0x1bb>
			232f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2333:	test   rax,rax
    2336:	je     2528 <botlish_fn_26+0x3b0>
    233c:	mov    QWORD PTR [rsp+0x10],0x7
    2345:	mov    rsi,r12
    2348:	mov    rdi,rbx
    234b:	call   2350 <botlish_fn_26+0x1d8>
			234c: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2350:	test   rax,rax
    2353:	je     2528 <botlish_fn_26+0x3b0>
    2359:	mov    QWORD PTR [rsp+0x18],rax
    235e:	mov    QWORD PTR [rsp+0x20],0x3
    2367:	mov    ecx,0x1
    236c:	test   rax,0x1
    2372:	je     2380 <botlish_fn_26+0x208>
    2378:	mov    rsi,rax
    237b:	jmp    23a4 <botlish_fn_26+0x22c>
    2380:	xor    ecx,ecx
    2382:	test   rax,0x7
    2388:	je     2396 <botlish_fn_26+0x21e>
    238e:	mov    rsi,rax
    2391:	jmp    23a4 <botlish_fn_26+0x22c>
    2396:	movzx  rcx,BYTE PTR [rax]
    239a:	mov    rsi,rax
    239d:	rex cmp cl,0x1
    23a1:	sete   cl
    23a4:	test   cl,cl
    23a6:	jne    23c4 <botlish_fn_26+0x24c>
    23ac:	mov    rdi,rbx
    23af:	mov    rax,QWORD PTR [rdi+0x10]
    23b3:	mov    rcx,QWORD PTR [rax+0x10]
    23b7:	xor    rdx,rdx
    23ba:	call   23bf <botlish_fn_26+0x247>
			23bb: R_X86_64_PLT32	rt_type_error-0x4
    23bf:	jmp    2528 <botlish_fn_26+0x3b0>
    23c4:	test   rsi,0x1
    23cb:	je     23e3 <botlish_fn_26+0x26b>
    23d1:	mov    rcx,rsi
    23d4:	add    rcx,0x2
    23d8:	seto   al
    23db:	test   al,al
    23dd:	je     23f3 <botlish_fn_26+0x27b>
    23e3:	mov    edx,0x3
    23e8:	mov    rdi,rbx
    23eb:	call   23f0 <botlish_fn_26+0x278>
			23ec: R_X86_64_PLT32	rt_int_add-0x4
    23f0:	mov    rcx,rax
    23f3:	mov    edx,0x7
    23f8:	mov    rsi,r12
    23fb:	mov    rdi,rbx
    23fe:	call   2403 <botlish_fn_26+0x28b>
			23ff: R_X86_64_PLT32	rt_mutarray_set-0x4
    2403:	test   rax,rax
    2406:	je     2528 <botlish_fn_26+0x3b0>
    240c:	mov    rdi,rbx
    240f:	call   2414 <botlish_fn_26+0x29c>
			2410: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    2414:	mov    rax,r13
    2417:	test   rax,0x1
    241d:	jne    2441 <botlish_fn_26+0x2c9>
    2423:	mov    edx,0x5
    2428:	mov    rsi,r13
    242b:	mov    rdi,rbx
    242e:	call   2433 <botlish_fn_26+0x2bb>
			242f: R_X86_64_PLT32	rt_value_eq-0x4
    2433:	test   rax,rax
    2436:	je     2528 <botlish_fn_26+0x3b0>
    243c:	jmp    2455 <botlish_fn_26+0x2dd>
    2441:	mov    rsi,r13
    2444:	mov    eax,0x2
    2449:	cmp    rsi,0x5
    244d:	cmove  rax,QWORD PTR [rip+0x123]        # 2578 <botlish_fn_26+0x400>
    2455:	cmp    rax,0x6
    2459:	jne    254d <botlish_fn_26+0x3d5>
    245f:	mov    QWORD PTR [rsp+0x8],0x9
    2468:	mov    rsi,r12
    246b:	mov    rdi,rbx
    246e:	call   2473 <botlish_fn_26+0x2fb>
			246f: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2473:	test   rax,rax
    2476:	je     2528 <botlish_fn_26+0x3b0>
    247c:	mov    QWORD PTR [rsp+0x10],rax
    2481:	mov    QWORD PTR [rsp+0x18],0x3
    248a:	mov    ecx,0x1
    248f:	test   rax,0x1
    2495:	jne    24b4 <botlish_fn_26+0x33c>
    249b:	xor    ecx,ecx
    249d:	test   rax,0x7
    24a3:	jne    24b4 <botlish_fn_26+0x33c>
    24a9:	movzx  rcx,BYTE PTR [rax]
    24ad:	rex cmp cl,0x1
    24b1:	sete   cl
    24b4:	test   cl,cl
    24b6:	jne    24d7 <botlish_fn_26+0x35f>
    24bc:	mov    rdi,rbx
    24bf:	mov    rsi,QWORD PTR [rdi+0x10]
    24c3:	mov    rcx,QWORD PTR [rsi+0x28]
    24c7:	xor    rdx,rdx
    24ca:	mov    rsi,rax
    24cd:	call   24d2 <botlish_fn_26+0x35a>
			24ce: R_X86_64_PLT32	rt_type_error-0x4
    24d2:	jmp    2528 <botlish_fn_26+0x3b0>
    24d7:	mov    rsi,rax
    24da:	test   rsi,0x1
    24e1:	je     24ff <botlish_fn_26+0x387>
    24e7:	mov    rdi,rsi
    24ea:	sub    rdi,0x3
    24ee:	seto   r8b
    24f2:	lea    rcx,[rdi+0x1]
    24f6:	test   r8b,r8b
    24f9:	je     250f <botlish_fn_26+0x397>
    24ff:	mov    edx,0x3
    2504:	mov    rdi,rbx
    2507:	call   250c <botlish_fn_26+0x394>
			2508: R_X86_64_PLT32	rt_int_sub-0x4
    250c:	mov    rcx,rax
    250f:	mov    edx,0x9
    2514:	mov    rsi,r12
    2517:	mov    rdi,rbx
    251a:	call   251f <botlish_fn_26+0x3a7>
			251b: R_X86_64_PLT32	rt_mutarray_set-0x4
    251f:	test   rax,rax
    2522:	jne    254d <botlish_fn_26+0x3d5>
    2528:	xor    rax,rax
    252b:	mov    rbx,QWORD PTR [rsp+0x40]
    2530:	mov    r12,QWORD PTR [rsp+0x48]
    2535:	mov    r13,QWORD PTR [rsp+0x50]
    253a:	mov    r14,QWORD PTR [rsp+0x58]
    253f:	mov    r15,QWORD PTR [rsp+0x60]
    2544:	add    rsp,0x70
    2548:	mov    rsp,rbp
    254b:	pop    rbp
    254c:	ret
    254d:	mov    eax,0xa
    2552:	mov    rbx,QWORD PTR [rsp+0x40]
    2557:	mov    r12,QWORD PTR [rsp+0x48]
    255c:	mov    r13,QWORD PTR [rsp+0x50]
    2561:	mov    r14,QWORD PTR [rsp+0x58]
    2566:	mov    r15,QWORD PTR [rsp+0x60]
    256b:	add    rsp,0x70
    256f:	mov    rsp,rbp
    2572:	pop    rbp
    2573:	ret
    2574:	add    BYTE PTR [rax],al
    2576:	add    BYTE PTR [rax],al
    2578:	(bad)
    2579:	add    BYTE PTR [rax],al
    257b:	add    BYTE PTR [rax],al
    257d:	add    BYTE PTR [rax],al
	...

0000000000002580 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    2580:	push   rbp
    2581:	mov    rbp,rsp
    2584:	mov    rsi,QWORD PTR [rdx]
    2587:	mov    r9,QWORD PTR [rdx+0x8]
    258b:	mov    rcx,QWORD PTR [rdx+0x10]
    258f:	mov    r8,QWORD PTR [rdx+0x18]
    2593:	mov    rdx,r9
    2596:	call   259b <botlish_entry_26+0x1b>
			2597: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    259b:	mov    rsp,rbp
    259e:	pop    rbp
    259f:	ret

00000000000025a0 <botlish_fn_27: ht_set<mutarray, str, str>>:
    25a0:	push   rbp
    25a1:	mov    rbp,rsp
    25a4:	sub    rsp,0x70
    25a8:	mov    QWORD PTR [rsp+0x40],rbx
    25ad:	mov    QWORD PTR [rsp+0x48],r12
    25b2:	mov    QWORD PTR [rsp+0x50],r13
    25b7:	mov    QWORD PTR [rsp+0x58],r14
    25bc:	mov    QWORD PTR [rsp+0x60],r15
    25c1:	mov    rbx,rdi
    25c4:	mov    r13,rdx
    25c7:	mov    QWORD PTR [rsp],rsi
    25cb:	mov    r14,rsi
    25ce:	mov    QWORD PTR [rsp+0x8],rdx
    25d3:	mov    QWORD PTR [rsp+0x10],rcx
    25d8:	mov    r12,rcx
    25db:	mov    rdx,r13
    25de:	mov    rsi,r14
    25e1:	mov    rdi,rbx
    25e4:	call   25e9 <botlish_fn_27+0x49>
			25e5: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    25e9:	test   rax,rax
    25ec:	je     2870 <botlish_fn_27+0x2d0>
    25f2:	mov    QWORD PTR [rsp+0x18],rax
    25f7:	mov    rcx,rax
    25fa:	mov    r8,0xffffffffffffffff
    2601:	mov    QWORD PTR [rsp+0x30],r8
    2606:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    260f:	mov    rdx,r13
    2612:	mov    rsi,r14
    2615:	mov    rdi,rbx
    2618:	call   261d <botlish_fn_27+0x7d>
			2619: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    261d:	mov    rcx,rax
    2620:	mov    r15,rax
    2623:	test   rax,rcx
    2626:	je     2870 <botlish_fn_27+0x2d0>
    262c:	mov    rax,r15
    262f:	mov    QWORD PTR [rsp+0x18],rax
    2634:	mov    rsi,r14
    2637:	mov    rdi,rbx
    263a:	call   263f <botlish_fn_27+0x9f>
			263b: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    263f:	test   rax,rax
    2642:	je     2870 <botlish_fn_27+0x2d0>
    2648:	xor    ecx,ecx
    264a:	test   rax,0x7
    2650:	je     265e <botlish_fn_27+0xbe>
    2656:	mov    r8,rax
    2659:	jmp    266c <botlish_fn_27+0xcc>
    265e:	movzx  rcx,BYTE PTR [rax]
    2662:	mov    r8,rax
    2665:	rex cmp cl,0x8
    2669:	sete   cl
    266c:	test   cl,cl
    266e:	jne    2691 <botlish_fn_27+0xf1>
    2674:	mov    rdi,rbx
    2677:	mov    rsi,QWORD PTR [rdi+0x10]
    267b:	mov    rcx,QWORD PTR [rsi+0x8]
    267f:	mov    edx,0x8
    2684:	mov    rsi,r8
    2687:	call   268c <botlish_fn_27+0xec>
			2688: R_X86_64_PLT32	rt_type_error-0x4
    268c:	jmp    2870 <botlish_fn_27+0x2d0>
    2691:	mov    rsi,r8
    2694:	mov    rdx,r15
    2697:	mov    rdi,rbx
    269a:	call   269f <botlish_fn_27+0xff>
			269b: R_X86_64_PLT32	rt_mutarray_get-0x4
    269f:	test   rax,rax
    26a2:	mov    QWORD PTR [rsp+0x28],rax
    26a7:	je     2870 <botlish_fn_27+0x2d0>
    26ad:	mov    rdi,rbx
    26b0:	call   26b5 <botlish_fn_27+0x115>
			26b1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    26b5:	mov    rax,QWORD PTR [rsp+0x28]
    26ba:	test   rax,0x1
    26c0:	jne    26e6 <botlish_fn_27+0x146>
    26c6:	mov    edx,0x3
    26cb:	mov    rsi,QWORD PTR [rsp+0x28]
    26d0:	mov    rdi,rbx
    26d3:	call   26d8 <botlish_fn_27+0x138>
			26d4: R_X86_64_PLT32	rt_value_eq-0x4
    26d8:	test   rax,rax
    26db:	je     2870 <botlish_fn_27+0x2d0>
    26e1:	jmp    26fc <botlish_fn_27+0x15c>
    26e6:	mov    rsi,QWORD PTR [rsp+0x28]
    26eb:	mov    eax,0x2
    26f0:	cmp    rsi,0x3
    26f4:	cmove  rax,QWORD PTR [rip+0x1c4]        # 28c0 <botlish_fn_27+0x320>
    26fc:	cmp    rax,0x6
    2700:	je     27ff <botlish_fn_27+0x25f>
    2706:	mov    rsi,r14
    2709:	mov    rdi,rbx
    270c:	call   2711 <botlish_fn_27+0x171>
			270d: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2711:	test   rax,rax
    2714:	je     2870 <botlish_fn_27+0x2d0>
    271a:	cmp    rax,0x6
    271e:	je     2763 <botlish_fn_27+0x1c3>
    2724:	mov    rcx,r13
    2727:	mov    rdx,r15
    272a:	mov    rsi,r14
    272d:	mov    rdi,rbx
    2730:	mov    r8,r12
    2733:	call   2738 <botlish_fn_27+0x198>
			2734: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    2738:	test   rax,rax
    273b:	je     2870 <botlish_fn_27+0x2d0>
    2741:	mov    rbx,QWORD PTR [rsp+0x40]
    2746:	mov    r12,QWORD PTR [rsp+0x48]
    274b:	mov    r13,QWORD PTR [rsp+0x50]
    2750:	mov    r14,QWORD PTR [rsp+0x58]
    2755:	mov    r15,QWORD PTR [rsp+0x60]
    275a:	add    rsp,0x70
    275e:	mov    rsp,rbp
    2761:	pop    rbp
    2762:	ret
    2763:	mov    rsi,r14
    2766:	mov    rdi,rbx
    2769:	call   276e <botlish_fn_27+0x1ce>
			276a: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    276e:	test   rax,rax
    2771:	je     2870 <botlish_fn_27+0x2d0>
    2777:	mov    rdx,r13
    277a:	mov    rsi,r14
    277d:	mov    rdi,rbx
    2780:	call   2785 <botlish_fn_27+0x1e5>
			2781: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    2785:	test   rax,rax
    2788:	je     2870 <botlish_fn_27+0x2d0>
    278e:	mov    QWORD PTR [rsp+0x18],rax
    2793:	mov    rcx,rax
    2796:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    279f:	mov    r8,QWORD PTR [rsp+0x30]
    27a4:	mov    rdx,r13
    27a7:	mov    rsi,r14
    27aa:	mov    rdi,rbx
    27ad:	call   27b2 <botlish_fn_27+0x212>
			27ae: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    27b2:	test   rax,rax
    27b5:	je     2870 <botlish_fn_27+0x2d0>
    27bb:	mov    QWORD PTR [rsp+0x18],rax
    27c0:	mov    rcx,r13
    27c3:	mov    rdx,rax
    27c6:	mov    rsi,r14
    27c9:	mov    rdi,rbx
    27cc:	mov    r8,r12
    27cf:	call   27d4 <botlish_fn_27+0x234>
			27d0: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    27d4:	test   rax,rax
    27d7:	je     2870 <botlish_fn_27+0x2d0>
    27dd:	mov    rbx,QWORD PTR [rsp+0x40]
    27e2:	mov    r12,QWORD PTR [rsp+0x48]
    27e7:	mov    r13,QWORD PTR [rsp+0x50]
    27ec:	mov    r14,QWORD PTR [rsp+0x58]
    27f1:	mov    r15,QWORD PTR [rsp+0x60]
    27f6:	add    rsp,0x70
    27fa:	mov    rsp,rbp
    27fd:	pop    rbp
    27fe:	ret
    27ff:	mov    rsi,r14
    2802:	mov    rdi,rbx
    2805:	call   280a <botlish_fn_27+0x26a>
			2806: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    280a:	test   rax,rax
    280d:	je     2870 <botlish_fn_27+0x2d0>
    2813:	xor    ecx,ecx
    2815:	test   rax,0x7
    281b:	je     2829 <botlish_fn_27+0x289>
    2821:	mov    rsi,rax
    2824:	jmp    2837 <botlish_fn_27+0x297>
    2829:	movzx  rcx,BYTE PTR [rax]
    282d:	mov    rsi,rax
    2830:	rex cmp cl,0x8
    2834:	sete   cl
    2837:	test   cl,cl
    2839:	jne    2859 <botlish_fn_27+0x2b9>
    283f:	mov    rdi,rbx
    2842:	mov    rax,QWORD PTR [rdi+0x10]
    2846:	mov    rcx,QWORD PTR [rax+0x20]
    284a:	mov    edx,0x8
    284f:	call   2854 <botlish_fn_27+0x2b4>
			2850: R_X86_64_PLT32	rt_type_error-0x4
    2854:	jmp    2870 <botlish_fn_27+0x2d0>
    2859:	mov    rcx,r12
    285c:	mov    rdx,r15
    285f:	mov    rdi,rbx
    2862:	call   2867 <botlish_fn_27+0x2c7>
			2863: R_X86_64_PLT32	rt_mutarray_set-0x4
    2867:	test   rax,rax
    286a:	jne    2895 <botlish_fn_27+0x2f5>
    2870:	xor    rax,rax
    2873:	mov    rbx,QWORD PTR [rsp+0x40]
    2878:	mov    r12,QWORD PTR [rsp+0x48]
    287d:	mov    r13,QWORD PTR [rsp+0x50]
    2882:	mov    r14,QWORD PTR [rsp+0x58]
    2887:	mov    r15,QWORD PTR [rsp+0x60]
    288c:	add    rsp,0x70
    2890:	mov    rsp,rbp
    2893:	pop    rbp
    2894:	ret
    2895:	mov    eax,0xa
    289a:	mov    rbx,QWORD PTR [rsp+0x40]
    289f:	mov    r12,QWORD PTR [rsp+0x48]
    28a4:	mov    r13,QWORD PTR [rsp+0x50]
    28a9:	mov    r14,QWORD PTR [rsp+0x58]
    28ae:	mov    r15,QWORD PTR [rsp+0x60]
    28b3:	add    rsp,0x70
    28b7:	mov    rsp,rbp
    28ba:	pop    rbp
    28bb:	ret
    28bc:	add    BYTE PTR [rax],al
    28be:	add    BYTE PTR [rax],al
    28c0:	(bad)
    28c1:	add    BYTE PTR [rax],al
    28c3:	add    BYTE PTR [rax],al
    28c5:	add    BYTE PTR [rax],al
	...

00000000000028c8 <botlish_entry_27: ht_set<mutarray, str, str>>:
    28c8:	push   rbp
    28c9:	mov    rbp,rsp
    28cc:	mov    rsi,QWORD PTR [rdx]
    28cf:	mov    r8,QWORD PTR [rdx+0x8]
    28d3:	mov    rcx,QWORD PTR [rdx+0x10]
    28d7:	mov    rdx,r8
    28da:	call   28df <botlish_entry_27+0x17>
			28db: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    28df:	mov    rsp,rbp
    28e2:	pop    rbp
    28e3:	ret
    28e4:	add    BYTE PTR [rax],al
	...

00000000000028e8 <botlish_fn_28: ht_delete<mutarray, str>>:
    28e8:	push   rbp
    28e9:	mov    rbp,rsp
    28ec:	sub    rsp,0x40
    28f0:	mov    QWORD PTR [rsp+0x20],rbx
    28f5:	mov    QWORD PTR [rsp+0x28],r12
    28fa:	mov    QWORD PTR [rsp+0x30],r13
    28ff:	mov    QWORD PTR [rsp+0x38],r14
    2904:	mov    rbx,rdi
    2907:	mov    QWORD PTR [rsp+0x18],0x0
    2910:	mov    QWORD PTR [rsp],rsi
    2914:	mov    r12,rsi
    2917:	mov    QWORD PTR [rsp+0x8],rdx
    291c:	mov    r13,rdx
    291f:	mov    rdx,r13
    2922:	mov    rsi,r12
    2925:	mov    rdi,rbx
    2928:	call   292d <botlish_fn_28+0x45>
			2929: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    292d:	test   rax,rax
    2930:	je     2cb1 <botlish_fn_28+0x3c9>
    2936:	mov    QWORD PTR [rsp+0x10],rax
    293b:	mov    rcx,rax
    293e:	mov    rdx,r13
    2941:	mov    rsi,r12
    2944:	mov    rdi,rbx
    2947:	call   294c <botlish_fn_28+0x64>
			2948: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    294c:	mov    rcx,rax
    294f:	mov    r13,rax
    2952:	test   rax,rcx
    2955:	je     2cb1 <botlish_fn_28+0x3c9>
    295b:	mov    rax,r13
    295e:	test   rax,0x1
    2964:	jne    298f <botlish_fn_28+0xa7>
    296a:	mov    edx,0x1
    296f:	mov    rsi,r13
    2972:	mov    rdi,rbx
    2975:	call   297a <botlish_fn_28+0x92>
			2976: R_X86_64_PLT32	rt_int_cmp-0x4
    297a:	mov    ecx,0x2
    297f:	test   rax,rax
    2982:	cmovl  rcx,QWORD PTR [rip+0x38e]        # 2d18 <botlish_fn_28+0x430>
    298a:	jmp    29a5 <botlish_fn_28+0xbd>
    298f:	mov    ecx,0x2
    2994:	mov    rax,r13
    2997:	mov    rdx,r13
    299a:	test   rax,rdx
    299d:	cmovle rcx,QWORD PTR [rip+0x373]        # 2d18 <botlish_fn_28+0x430>
    29a5:	cmp    rcx,0x6
    29a9:	je     2cf3 <botlish_fn_28+0x40b>
    29af:	mov    rsi,r12
    29b2:	mov    rdi,rbx
    29b5:	call   29ba <botlish_fn_28+0xd2>
			29b6: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    29ba:	test   rax,rax
    29bd:	mov    r14,rax
    29c0:	je     2cb1 <botlish_fn_28+0x3c9>
    29c6:	mov    rdi,rbx
    29c9:	call   29ce <botlish_fn_28+0xe6>
			29ca: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    29ce:	xor    ecx,ecx
    29d0:	mov    rax,r14
    29d3:	test   rax,0x7
    29d9:	je     29e7 <botlish_fn_28+0xff>
    29df:	mov    r14,rax
    29e2:	jmp    29f5 <botlish_fn_28+0x10d>
    29e7:	movzx  rcx,BYTE PTR [rax]
    29eb:	mov    r14,rax
    29ee:	rex cmp cl,0x8
    29f2:	sete   cl
    29f5:	test   cl,cl
    29f7:	jne    2a1a <botlish_fn_28+0x132>
    29fd:	mov    rdi,rbx
    2a00:	mov    rax,QWORD PTR [rdi+0x10]
    2a04:	mov    rcx,QWORD PTR [rax+0x20]
    2a08:	mov    edx,0x8
    2a0d:	mov    rsi,r14
    2a10:	call   2a15 <botlish_fn_28+0x12d>
			2a11: R_X86_64_PLT32	rt_type_error-0x4
    2a15:	jmp    2cb1 <botlish_fn_28+0x3c9>
    2a1a:	mov    rsi,r14
    2a1d:	mov    ecx,0x5
    2a22:	mov    rdx,r13
    2a25:	mov    rdi,rbx
    2a28:	call   2a2d <botlish_fn_28+0x145>
			2a29: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a2d:	test   rax,rax
    2a30:	je     2cb1 <botlish_fn_28+0x3c9>
    2a36:	mov    rsi,r12
    2a39:	mov    rdi,rbx
    2a3c:	call   2a41 <botlish_fn_28+0x159>
			2a3d: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2a41:	test   rax,rax
    2a44:	je     2cb1 <botlish_fn_28+0x3c9>
    2a4a:	xor    ecx,ecx
    2a4c:	test   rax,0x7
    2a52:	jne    2a63 <botlish_fn_28+0x17b>
    2a58:	movzx  rsi,BYTE PTR [rax]
    2a5c:	cmp    sil,0x8
    2a60:	sete   cl
    2a63:	test   cl,cl
    2a65:	jne    2a88 <botlish_fn_28+0x1a0>
    2a6b:	mov    rdi,rbx
    2a6e:	mov    r10,QWORD PTR [rdi+0x10]
    2a72:	mov    rcx,QWORD PTR [r10+0x20]
    2a76:	mov    edx,0x8
    2a7b:	mov    rsi,rax
    2a7e:	call   2a83 <botlish_fn_28+0x19b>
			2a7f: R_X86_64_PLT32	rt_type_error-0x4
    2a83:	jmp    2cb1 <botlish_fn_28+0x3c9>
    2a88:	mov    rsi,rax
    2a8b:	mov    ecx,0xa
    2a90:	mov    rdx,r13
    2a93:	mov    rdi,rbx
    2a96:	call   2a9b <botlish_fn_28+0x1b3>
			2a97: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a9b:	test   rax,rax
    2a9e:	je     2cb1 <botlish_fn_28+0x3c9>
    2aa4:	mov    rsi,r12
    2aa7:	mov    rdi,rbx
    2aaa:	call   2aaf <botlish_fn_28+0x1c7>
			2aab: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2aaf:	test   rax,rax
    2ab2:	je     2cb1 <botlish_fn_28+0x3c9>
    2ab8:	xor    ecx,ecx
    2aba:	test   rax,0x7
    2ac0:	je     2ace <botlish_fn_28+0x1e6>
    2ac6:	mov    rsi,rax
    2ac9:	jmp    2adc <botlish_fn_28+0x1f4>
    2ace:	movzx  rcx,BYTE PTR [rax]
    2ad2:	mov    rsi,rax
    2ad5:	rex cmp cl,0x8
    2ad9:	sete   cl
    2adc:	test   cl,cl
    2ade:	jne    2afe <botlish_fn_28+0x216>
    2ae4:	mov    rdi,rbx
    2ae7:	mov    rax,QWORD PTR [rdi+0x10]
    2aeb:	mov    rcx,QWORD PTR [rax+0x20]
    2aef:	mov    edx,0x8
    2af4:	call   2af9 <botlish_fn_28+0x211>
			2af5: R_X86_64_PLT32	rt_type_error-0x4
    2af9:	jmp    2cb1 <botlish_fn_28+0x3c9>
    2afe:	mov    ecx,0xa
    2b03:	mov    rdx,r13
    2b06:	mov    rdi,rbx
    2b09:	call   2b0e <botlish_fn_28+0x226>
			2b0a: R_X86_64_PLT32	rt_mutarray_set-0x4
    2b0e:	test   rax,rax
    2b11:	je     2cb1 <botlish_fn_28+0x3c9>
    2b17:	mov    QWORD PTR [rsp+0x8],0x7
    2b20:	mov    rsi,r12
    2b23:	mov    rdi,rbx
    2b26:	call   2b2b <botlish_fn_28+0x243>
			2b27: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2b2b:	test   rax,rax
    2b2e:	je     2cb1 <botlish_fn_28+0x3c9>
    2b34:	mov    QWORD PTR [rsp+0x10],rax
    2b39:	mov    QWORD PTR [rsp+0x18],0x3
    2b42:	mov    ecx,0x1
    2b47:	test   rax,0x1
    2b4d:	je     2b5b <botlish_fn_28+0x273>
    2b53:	mov    rsi,rax
    2b56:	jmp    2b7f <botlish_fn_28+0x297>
    2b5b:	xor    ecx,ecx
    2b5d:	test   rax,0x7
    2b63:	je     2b71 <botlish_fn_28+0x289>
    2b69:	mov    rsi,rax
    2b6c:	jmp    2b7f <botlish_fn_28+0x297>
    2b71:	movzx  rcx,BYTE PTR [rax]
    2b75:	mov    rsi,rax
    2b78:	rex cmp cl,0x1
    2b7c:	sete   cl
    2b7f:	test   cl,cl
    2b81:	jne    2b9f <botlish_fn_28+0x2b7>
    2b87:	mov    rdi,rbx
    2b8a:	mov    rax,QWORD PTR [rdi+0x10]
    2b8e:	mov    rcx,QWORD PTR [rax+0x28]
    2b92:	xor    rdx,rdx
    2b95:	call   2b9a <botlish_fn_28+0x2b2>
			2b96: R_X86_64_PLT32	rt_type_error-0x4
    2b9a:	jmp    2cb1 <botlish_fn_28+0x3c9>
    2b9f:	test   rsi,0x1
    2ba6:	je     2bc5 <botlish_fn_28+0x2dd>
    2bac:	mov    rcx,rsi
    2baf:	sub    rcx,0x3
    2bb3:	seto   al
    2bb6:	add    rcx,0x1
    2bbd:	test   al,al
    2bbf:	je     2bd5 <botlish_fn_28+0x2ed>
    2bc5:	mov    edx,0x3
    2bca:	mov    rdi,rbx
    2bcd:	call   2bd2 <botlish_fn_28+0x2ea>
			2bce: R_X86_64_PLT32	rt_int_sub-0x4
    2bd2:	mov    rcx,rax
    2bd5:	mov    edx,0x7
    2bda:	mov    rsi,r12
    2bdd:	mov    rdi,rbx
    2be0:	call   2be5 <botlish_fn_28+0x2fd>
			2be1: R_X86_64_PLT32	rt_mutarray_set-0x4
    2be5:	test   rax,rax
    2be8:	je     2cb1 <botlish_fn_28+0x3c9>
    2bee:	mov    QWORD PTR [rsp+0x8],0x9
    2bf7:	mov    rsi,r12
    2bfa:	mov    rdi,rbx
    2bfd:	call   2c02 <botlish_fn_28+0x31a>
			2bfe: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2c02:	test   rax,rax
    2c05:	je     2cb1 <botlish_fn_28+0x3c9>
    2c0b:	mov    QWORD PTR [rsp+0x10],rax
    2c10:	mov    QWORD PTR [rsp+0x18],0x3
    2c19:	mov    ecx,0x1
    2c1e:	test   rax,0x1
    2c24:	jne    2c43 <botlish_fn_28+0x35b>
    2c2a:	xor    ecx,ecx
    2c2c:	test   rax,0x7
    2c32:	jne    2c43 <botlish_fn_28+0x35b>
    2c38:	movzx  rsi,BYTE PTR [rax]
    2c3c:	cmp    sil,0x1
    2c40:	sete   cl
    2c43:	test   cl,cl
    2c45:	jne    2c66 <botlish_fn_28+0x37e>
    2c4b:	mov    rdi,rbx
    2c4e:	mov    r9,QWORD PTR [rdi+0x10]
    2c52:	mov    rcx,QWORD PTR [r9+0x10]
    2c56:	xor    rdx,rdx
    2c59:	mov    rsi,rax
    2c5c:	call   2c61 <botlish_fn_28+0x379>
			2c5d: R_X86_64_PLT32	rt_type_error-0x4
    2c61:	jmp    2cb1 <botlish_fn_28+0x3c9>
    2c66:	mov    rsi,rax
    2c69:	test   rsi,0x1
    2c70:	je     2c88 <botlish_fn_28+0x3a0>
    2c76:	mov    rcx,rsi
    2c79:	add    rcx,0x2
    2c7d:	seto   al
    2c80:	test   al,al
    2c82:	je     2c98 <botlish_fn_28+0x3b0>
    2c88:	mov    edx,0x3
    2c8d:	mov    rdi,rbx
    2c90:	call   2c95 <botlish_fn_28+0x3ad>
			2c91: R_X86_64_PLT32	rt_int_add-0x4
    2c95:	mov    rcx,rax
    2c98:	mov    edx,0x9
    2c9d:	mov    rsi,r12
    2ca0:	mov    rdi,rbx
    2ca3:	call   2ca8 <botlish_fn_28+0x3c0>
			2ca4: R_X86_64_PLT32	rt_mutarray_set-0x4
    2ca8:	test   rax,rax
    2cab:	jne    2cd1 <botlish_fn_28+0x3e9>
    2cb1:	xor    rax,rax
    2cb4:	mov    rbx,QWORD PTR [rsp+0x20]
    2cb9:	mov    r12,QWORD PTR [rsp+0x28]
    2cbe:	mov    r13,QWORD PTR [rsp+0x30]
    2cc3:	mov    r14,QWORD PTR [rsp+0x38]
    2cc8:	add    rsp,0x40
    2ccc:	mov    rsp,rbp
    2ccf:	pop    rbp
    2cd0:	ret
    2cd1:	mov    eax,0xa
    2cd6:	mov    rbx,QWORD PTR [rsp+0x20]
    2cdb:	mov    r12,QWORD PTR [rsp+0x28]
    2ce0:	mov    r13,QWORD PTR [rsp+0x30]
    2ce5:	mov    r14,QWORD PTR [rsp+0x38]
    2cea:	add    rsp,0x40
    2cee:	mov    rsp,rbp
    2cf1:	pop    rbp
    2cf2:	ret
    2cf3:	mov    eax,0xa
    2cf8:	mov    rbx,QWORD PTR [rsp+0x20]
    2cfd:	mov    r12,QWORD PTR [rsp+0x28]
    2d02:	mov    r13,QWORD PTR [rsp+0x30]
    2d07:	mov    r14,QWORD PTR [rsp+0x38]
    2d0c:	add    rsp,0x40
    2d10:	mov    rsp,rbp
    2d13:	pop    rbp
    2d14:	ret
    2d15:	add    BYTE PTR [rax],al
    2d17:	add    BYTE PTR [rsi],al
    2d19:	add    BYTE PTR [rax],al
    2d1b:	add    BYTE PTR [rax],al
    2d1d:	add    BYTE PTR [rax],al
	...

0000000000002d20 <botlish_entry_28: ht_delete<mutarray, str>>:
    2d20:	push   rbp
    2d21:	mov    rbp,rsp
    2d24:	mov    rsi,QWORD PTR [rdx]
    2d27:	mov    rdx,QWORD PTR [rdx+0x8]
    2d2b:	call   2d30 <botlish_entry_28+0x10>
			2d2c: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    2d30:	mov    rsp,rbp
    2d33:	pop    rbp
    2d34:	ret
    2d35:	add    BYTE PTR [rax],al
	...

0000000000002d38 <botlish_fn_29: sample<generic>>:
    2d38:	push   rbp
    2d39:	mov    rbp,rsp
    2d3c:	sub    rsp,0xa0
    2d43:	mov    QWORD PTR [rsp+0x70],rbx
    2d48:	mov    QWORD PTR [rsp+0x78],r12
    2d4d:	mov    QWORD PTR [rsp+0x80],r13
    2d55:	mov    QWORD PTR [rsp+0x88],r14
    2d5d:	mov    QWORD PTR [rsp+0x90],r15
    2d65:	mov    r14,rdi
    2d68:	mov    QWORD PTR [rsp],0x0
    2d70:	mov    QWORD PTR [rsp+0x8],0x0
    2d79:	mov    QWORD PTR [rsp+0x10],0x0
    2d82:	mov    QWORD PTR [rsp+0x18],0x0
    2d8b:	mov    QWORD PTR [rsp+0x20],0x0
    2d94:	mov    QWORD PTR [rsp+0x28],0x0
    2d9d:	mov    rdi,r14
    2da0:	call   2da5 <botlish_fn_29+0x6d>
			2da1: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    2da5:	mov    rcx,rax
    2da8:	mov    r15,rax
    2dab:	test   rax,rcx
    2dae:	je     2fee <botlish_fn_29+0x2b6>
    2db4:	mov    rax,r15
    2db7:	mov    QWORD PTR [rsp],rax
    2dbb:	mov    rdi,r14
    2dbe:	mov    rax,QWORD PTR [rdi+0x10]
    2dc2:	mov    rdx,QWORD PTR [rax+0x30]
    2dc6:	mov    QWORD PTR [rsp+0x8],rdx
    2dcb:	mov    rax,QWORD PTR [rdi+0x10]
    2dcf:	mov    rcx,QWORD PTR [rax+0x38]
    2dd3:	mov    QWORD PTR [rsp+0x10],rcx
    2dd8:	mov    rsi,r15
    2ddb:	call   2de0 <botlish_fn_29+0xa8>
			2ddc: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2de0:	test   rax,rax
    2de3:	je     2fee <botlish_fn_29+0x2b6>
    2de9:	mov    rdi,r14
    2dec:	mov    rsi,QWORD PTR [rdi+0x10]
    2df0:	mov    rdx,QWORD PTR [rsi+0x40]
    2df4:	mov    QWORD PTR [rsp+0x8],rdx
    2df9:	mov    rsi,QWORD PTR [rdi+0x10]
    2dfd:	mov    rcx,QWORD PTR [rsi+0x48]
    2e01:	mov    QWORD PTR [rsp+0x10],rcx
    2e06:	mov    rsi,r15
    2e09:	call   2e0e <botlish_fn_29+0xd6>
			2e0a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2e0e:	test   rax,rax
    2e11:	je     2fee <botlish_fn_29+0x2b6>
    2e17:	mov    rdi,r14
    2e1a:	mov    r9,QWORD PTR [rdi+0x10]
    2e1e:	mov    rdx,QWORD PTR [r9+0x30]
    2e22:	mov    QWORD PTR [rsp+0x8],rdx
    2e27:	mov    r10,QWORD PTR [rdi+0x10]
    2e2b:	mov    rcx,QWORD PTR [r10+0x50]
    2e2f:	mov    QWORD PTR [rsp+0x10],rcx
    2e34:	mov    rsi,r15
    2e37:	call   2e3c <botlish_fn_29+0x104>
			2e38: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2e3c:	test   rax,rax
    2e3f:	je     2fee <botlish_fn_29+0x2b6>
    2e45:	mov    rdi,r14
    2e48:	mov    rax,QWORD PTR [rdi+0x10]
    2e4c:	mov    rdx,QWORD PTR [rax+0x40]
    2e50:	mov    QWORD PTR [rsp+0x8],rdx
    2e55:	mov    rsi,r15
    2e58:	call   2e5d <botlish_fn_29+0x125>
			2e59: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    2e5d:	mov    rbx,rax
    2e60:	test   rbx,rbx
    2e63:	je     2fee <botlish_fn_29+0x2b6>
    2e69:	mov    QWORD PTR [rsp+0x8],rbx
    2e6e:	mov    rdi,r14
    2e71:	mov    rax,QWORD PTR [rdi+0x10]
    2e75:	mov    rdx,QWORD PTR [rax+0x40]
    2e79:	mov    QWORD PTR [rsp+0x10],rdx
    2e7e:	mov    rsi,r15
    2e81:	call   2e86 <botlish_fn_29+0x14e>
			2e82: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    2e86:	test   rax,rax
    2e89:	je     2fee <botlish_fn_29+0x2b6>
    2e8f:	mov    rdi,r14
    2e92:	mov    rax,QWORD PTR [rdi+0x10]
    2e96:	mov    rdx,QWORD PTR [rax+0x30]
    2e9a:	mov    QWORD PTR [rsp+0x10],rdx
    2e9f:	mov    rsi,r15
    2ea2:	call   2ea7 <botlish_fn_29+0x16f>
			2ea3: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    2ea7:	test   rax,rax
    2eaa:	je     2fee <botlish_fn_29+0x2b6>
    2eb0:	mov    rdi,r14
    2eb3:	mov    rcx,QWORD PTR [rdi+0x10]
    2eb7:	mov    rdx,QWORD PTR [rcx+0x50]
    2ebb:	mov    rcx,rax
    2ebe:	and    rcx,rdx
    2ec1:	mov    rsi,rax
    2ec4:	test   rcx,0x1
    2ecb:	jne    2ee7 <botlish_fn_29+0x1af>
    2ed1:	mov    rdi,r14
    2ed4:	call   2ed9 <botlish_fn_29+0x1a1>
			2ed5: R_X86_64_PLT32	rt_value_eq-0x4
    2ed9:	test   rax,rax
    2edc:	je     2fee <botlish_fn_29+0x2b6>
    2ee2:	jmp    2ef7 <botlish_fn_29+0x1bf>
    2ee7:	mov    eax,0x2
    2eec:	cmp    rsi,rdx
    2eef:	cmove  rax,QWORD PTR [rip+0x159]        # 3050 <botlish_fn_29+0x318>
    2ef7:	mov    QWORD PTR [rsp+0x10],rax
    2efc:	mov    rdi,r14
    2eff:	mov    QWORD PTR [rsp+0x60],rax
    2f04:	mov    rax,QWORD PTR [rdi+0x10]
    2f08:	mov    rdx,QWORD PTR [rax+0x40]
    2f0c:	mov    QWORD PTR [rsp+0x18],rdx
    2f11:	mov    rsi,r15
    2f14:	call   2f19 <botlish_fn_29+0x1e1>
			2f15: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    2f19:	mov    r12,rax
    2f1c:	test   r12,r12
    2f1f:	je     2fee <botlish_fn_29+0x2b6>
    2f25:	mov    QWORD PTR [rsp+0x18],r12
    2f2a:	mov    rdi,r14
    2f2d:	mov    rax,QWORD PTR [rdi+0x10]
    2f31:	mov    rdx,QWORD PTR [rax+0x58]
    2f35:	mov    QWORD PTR [rsp+0x20],rdx
    2f3a:	mov    rsi,r15
    2f3d:	call   2f42 <botlish_fn_29+0x20a>
			2f3e: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    2f42:	mov    r13,rax
    2f45:	test   r13,r13
    2f48:	je     2fee <botlish_fn_29+0x2b6>
    2f4e:	mov    QWORD PTR [rsp+0x20],r13
    2f53:	mov    rdi,r14
    2f56:	mov    rax,QWORD PTR [rdi+0x10]
    2f5a:	mov    rdx,QWORD PTR [rax+0x58]
    2f5e:	mov    QWORD PTR [rsp+0x28],rdx
    2f63:	mov    rsi,r15
    2f66:	call   2f6b <botlish_fn_29+0x233>
			2f67: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    2f6b:	test   rax,rax
    2f6e:	mov    rsi,rax
    2f71:	je     2fee <botlish_fn_29+0x2b6>
    2f77:	mov    edx,0xa
    2f7c:	mov    rdi,r14
    2f7f:	call   2f84 <botlish_fn_29+0x24c>
			2f80: R_X86_64_PLT32	rt_value_eq-0x4
    2f84:	test   rax,rax
    2f87:	je     2fee <botlish_fn_29+0x2b6>
    2f8d:	mov    QWORD PTR [rsp],rax
    2f91:	mov    rsi,r15
    2f94:	mov    r15,rax
    2f97:	mov    rdi,r14
    2f9a:	call   2f9f <botlish_fn_29+0x267>
			2f9b: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2f9f:	test   rax,rax
    2fa2:	je     2fee <botlish_fn_29+0x2b6>
    2fa8:	mov    QWORD PTR [rsp+0x28],rax
    2fad:	lea    rdx,[rsp+0x30]
    2fb2:	mov    rsi,QWORD PTR [rsp+0x60]
    2fb7:	mov    QWORD PTR [rsp+0x30],rsi
    2fbc:	mov    QWORD PTR [rsp+0x38],rbx
    2fc1:	mov    QWORD PTR [rsp+0x40],r12
    2fc6:	mov    QWORD PTR [rsp+0x48],r13
    2fcb:	mov    r8,r15
    2fce:	mov    QWORD PTR [rsp+0x50],r8
    2fd3:	mov    QWORD PTR [rsp+0x58],rax
    2fd8:	mov    esi,0x6
    2fdd:	mov    rdi,r14
    2fe0:	call   2fe5 <botlish_fn_29+0x2ad>
			2fe1: R_X86_64_PLT32	rt_list_new-0x4
    2fe5:	test   rax,rax
    2fe8:	jne    301f <botlish_fn_29+0x2e7>
    2fee:	xor    rax,rax
    2ff1:	mov    rbx,QWORD PTR [rsp+0x70]
    2ff6:	mov    r12,QWORD PTR [rsp+0x78]
    2ffb:	mov    r13,QWORD PTR [rsp+0x80]
    3003:	mov    r14,QWORD PTR [rsp+0x88]
    300b:	mov    r15,QWORD PTR [rsp+0x90]
    3013:	add    rsp,0xa0
    301a:	mov    rsp,rbp
    301d:	pop    rbp
    301e:	ret
    301f:	mov    rbx,QWORD PTR [rsp+0x70]
    3024:	mov    r12,QWORD PTR [rsp+0x78]
    3029:	mov    r13,QWORD PTR [rsp+0x80]
    3031:	mov    r14,QWORD PTR [rsp+0x88]
    3039:	mov    r15,QWORD PTR [rsp+0x90]
    3041:	add    rsp,0xa0
    3048:	mov    rsp,rbp
    304b:	pop    rbp
    304c:	ret
    304d:	add    BYTE PTR [rax],al
    304f:	add    BYTE PTR [rsi],al
    3051:	add    BYTE PTR [rax],al
    3053:	add    BYTE PTR [rax],al
    3055:	add    BYTE PTR [rax],al
	...

0000000000003058 <botlish_entry_29: sample<generic>>:
    3058:	push   rbp
    3059:	mov    rbp,rsp
    305c:	call   3061 <botlish_entry_29+0x9>
			305d: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    3061:	mov    rsp,rbp
    3064:	pop    rbp
    3065:	ret

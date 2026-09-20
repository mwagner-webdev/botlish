; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 13704  (per function: 45 28 28 28 28 412 524 110 61 61 61 61 61 174 190 233 860 1328 437 261 436 456 1257 803 841 681 1240 908 1253 838)
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
      bf:	mov    QWORD PTR [rsp+0x18],0x0
      c8:	mov    QWORD PTR [rsp],rsi
      cc:	mov    rbx,rsi
      cf:	mov    QWORD PTR [rsp+0x8],rdx
      d4:	mov    QWORD PTR [rsp+0x10],rcx
      d9:	mov    r12,rcx
      dc:	mov    rsi,rdx
      df:	mov    rax,rsi
      e2:	and    rax,r12
      e5:	mov    r14,rsi
      e8:	test   rax,0x1
      ee:	jne    117 <botlish_fn_5+0x77>
      f4:	mov    rdx,r12
      f7:	mov    rsi,r14
      fa:	mov    rdi,r13
      fd:	call   102 <botlish_fn_5+0x62>
			fe: R_X86_64_PLT32	rt_int_cmp-0x4
     102:	mov    ecx,0x2
     107:	test   rax,rax
     10a:	cmovge rcx,QWORD PTR [rip+0xee]        # 200 <botlish_fn_5+0x160>
     112:	jmp    12a <botlish_fn_5+0x8a>
     117:	mov    ecx,0x2
     11c:	mov    rsi,r14
     11f:	cmp    rsi,r12
     122:	cmovge rcx,QWORD PTR [rip+0xd6]        # 200 <botlish_fn_5+0x160>
     12a:	cmp    rcx,0x6
     12e:	je     1de <botlish_fn_5+0x13e>
     134:	mov    rdi,r13
     137:	call   13c <botlish_fn_5+0x9c>
			138: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     13c:	test   rax,rax
     13f:	mov    rcx,rax
     142:	je     15f <botlish_fn_5+0xbf>
     148:	mov    rdx,r14
     14b:	mov    rsi,rbx
     14e:	mov    rdi,r13
     151:	call   156 <botlish_fn_5+0xb6>
			152: R_X86_64_PLT32	rt_mutarray_set-0x4
     156:	test   rax,rax
     159:	jne    17f <botlish_fn_5+0xdf>
     15f:	xor    rax,rax
     162:	mov    rbx,QWORD PTR [rsp+0x20]
     167:	mov    r12,QWORD PTR [rsp+0x28]
     16c:	mov    r13,QWORD PTR [rsp+0x30]
     171:	mov    r14,QWORD PTR [rsp+0x38]
     176:	add    rsp,0x40
     17a:	mov    rsp,rbp
     17d:	pop    rbp
     17e:	ret
     17f:	mov    QWORD PTR [rsp+0x18],0x3
     188:	mov    rsi,r14
     18b:	test   rsi,0x1
     192:	je     1b5 <botlish_fn_5+0x115>
     198:	mov    rsi,r14
     19b:	mov    rcx,rsi
     19e:	add    rcx,0x2
     1a2:	seto   al
     1a5:	test   al,al
     1a7:	jne    1b5 <botlish_fn_5+0x115>
     1ad:	mov    r14,rcx
     1b0:	jmp    1c8 <botlish_fn_5+0x128>
     1b5:	mov    edx,0x3
     1ba:	mov    rsi,r14
     1bd:	mov    rdi,r13
     1c0:	call   1c5 <botlish_fn_5+0x125>
			1c1: R_X86_64_PLT32	rt_int_add-0x4
     1c5:	mov    r14,rax
     1c8:	mov    QWORD PTR [rsp],rbx
     1cc:	mov    rsi,r14
     1cf:	mov    QWORD PTR [rsp+0x8],rsi
     1d4:	mov    QWORD PTR [rsp+0x10],r12
     1d9:	jmp    df <botlish_fn_5+0x3f>
     1de:	mov    eax,0xa
     1e3:	mov    rbx,QWORD PTR [rsp+0x20]
     1e8:	mov    r12,QWORD PTR [rsp+0x28]
     1ed:	mov    r13,QWORD PTR [rsp+0x30]
     1f2:	mov    r14,QWORD PTR [rsp+0x38]
     1f7:	add    rsp,0x40
     1fb:	mov    rsp,rbp
     1fe:	pop    rbp
     1ff:	ret
     200:	(bad)
     201:	add    BYTE PTR [rax],al
     203:	add    BYTE PTR [rax],al
     205:	add    BYTE PTR [rax],al
	...

0000000000000208 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     208:	push   rbp
     209:	mov    rbp,rsp
     20c:	mov    rsi,QWORD PTR [rdx]
     20f:	mov    r8,QWORD PTR [rdx+0x8]
     213:	mov    rcx,QWORD PTR [rdx+0x10]
     217:	mov    rdx,r8
     21a:	call   21f <botlish_entry_5+0x17>
			21b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     21f:	mov    rsp,rbp
     222:	pop    rbp
     223:	ret

0000000000000224 <botlish_fn_6: ht_alloc<int>>:
     224:	push   rbp
     225:	mov    rbp,rsp
     228:	sub    rsp,0x50
     22c:	mov    QWORD PTR [rsp+0x20],rbx
     231:	mov    QWORD PTR [rsp+0x28],r12
     236:	mov    QWORD PTR [rsp+0x30],r13
     23b:	mov    QWORD PTR [rsp+0x38],r14
     240:	mov    QWORD PTR [rsp+0x40],r15
     245:	mov    rbx,rdi
     248:	mov    QWORD PTR [rsp+0x8],0x0
     251:	mov    QWORD PTR [rsp+0x10],0x0
     25a:	mov    QWORD PTR [rsp+0x18],0x0
     263:	mov    QWORD PTR [rsp],rsi
     267:	mov    r13,rsi
     26a:	mov    rsi,r13
     26d:	mov    rdi,rbx
     270:	call   275 <botlish_fn_6+0x51>
			271: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     275:	test   rax,rax
     278:	je     394 <botlish_fn_6+0x170>
     27e:	mov    QWORD PTR [rsp+0x8],rax
     283:	mov    r12,rax
     286:	mov    edx,0x1
     28b:	mov    QWORD PTR [rsp+0x10],0x1
     294:	mov    rcx,r13
     297:	mov    rsi,r12
     29a:	mov    rdi,rbx
     29d:	call   2a2 <botlish_fn_6+0x7e>
			29e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     2a2:	test   rax,rax
     2a5:	je     394 <botlish_fn_6+0x170>
     2ab:	mov    rsi,r13
     2ae:	mov    rdi,rbx
     2b1:	call   2b6 <botlish_fn_6+0x92>
			2b2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2b6:	test   rax,rax
     2b9:	je     394 <botlish_fn_6+0x170>
     2bf:	mov    QWORD PTR [rsp+0x10],rax
     2c4:	mov    rsi,r13
     2c7:	mov    r14,rax
     2ca:	mov    rdi,rbx
     2cd:	call   2d2 <botlish_fn_6+0xae>
			2ce: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2d2:	test   rax,rax
     2d5:	je     394 <botlish_fn_6+0x170>
     2db:	mov    QWORD PTR [rsp],rax
     2df:	mov    r13,rax
     2e2:	mov    esi,0xb
     2e7:	mov    QWORD PTR [rsp+0x18],0xb
     2f0:	mov    rdi,rbx
     2f3:	call   2f8 <botlish_fn_6+0xd4>
			2f4: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2f8:	test   rax,rax
     2fb:	mov    r15,rax
     2fe:	je     394 <botlish_fn_6+0x170>
     304:	mov    edx,0x1
     309:	mov    rcx,r12
     30c:	mov    rsi,r15
     30f:	mov    rdi,rbx
     312:	call   317 <botlish_fn_6+0xf3>
			313: R_X86_64_PLT32	rt_mutarray_set-0x4
     317:	test   rax,rax
     31a:	je     394 <botlish_fn_6+0x170>
     320:	mov    edx,0x3
     325:	mov    rcx,r14
     328:	mov    rsi,r15
     32b:	mov    rdi,rbx
     32e:	call   333 <botlish_fn_6+0x10f>
			32f: R_X86_64_PLT32	rt_mutarray_set-0x4
     333:	test   rax,rax
     336:	je     394 <botlish_fn_6+0x170>
     33c:	mov    edx,0x5
     341:	mov    rcx,r13
     344:	mov    rsi,r15
     347:	mov    rdi,rbx
     34a:	call   34f <botlish_fn_6+0x12b>
			34b: R_X86_64_PLT32	rt_mutarray_set-0x4
     34f:	test   rax,rax
     352:	je     394 <botlish_fn_6+0x170>
     358:	mov    edx,0x7
     35d:	mov    ecx,0x1
     362:	mov    rsi,r15
     365:	mov    rdi,rbx
     368:	call   36d <botlish_fn_6+0x149>
			369: R_X86_64_PLT32	rt_mutarray_set-0x4
     36d:	test   rax,rax
     370:	je     394 <botlish_fn_6+0x170>
     376:	mov    edx,0x9
     37b:	mov    ecx,0x1
     380:	mov    rdi,rbx
     383:	mov    rsi,r15
     386:	call   38b <botlish_fn_6+0x167>
			387: R_X86_64_PLT32	rt_mutarray_set-0x4
     38b:	test   rax,rax
     38e:	jne    3b9 <botlish_fn_6+0x195>
     394:	xor    rax,rax
     397:	mov    rbx,QWORD PTR [rsp+0x20]
     39c:	mov    r12,QWORD PTR [rsp+0x28]
     3a1:	mov    r13,QWORD PTR [rsp+0x30]
     3a6:	mov    r14,QWORD PTR [rsp+0x38]
     3ab:	mov    r15,QWORD PTR [rsp+0x40]
     3b0:	add    rsp,0x50
     3b4:	mov    rsp,rbp
     3b7:	pop    rbp
     3b8:	ret
     3b9:	mov    rax,r15
     3bc:	mov    rbx,QWORD PTR [rsp+0x20]
     3c1:	mov    r12,QWORD PTR [rsp+0x28]
     3c6:	mov    r13,QWORD PTR [rsp+0x30]
     3cb:	mov    r14,QWORD PTR [rsp+0x38]
     3d0:	mov    r15,QWORD PTR [rsp+0x40]
     3d5:	add    rsp,0x50
     3d9:	mov    rsp,rbp
     3dc:	pop    rbp
     3dd:	ret

00000000000003de <botlish_entry_6: ht_alloc<int>>:
     3de:	push   rbp
     3df:	mov    rbp,rsp
     3e2:	mov    rsi,QWORD PTR [rdx]
     3e5:	call   3ea <botlish_entry_6+0xc>
			3e6: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     3ea:	mov    rsp,rbp
     3ed:	pop    rbp
     3ee:	ret

00000000000003ef <botlish_fn_7: ht_new<generic>>:
     3ef:	push   rbp
     3f0:	mov    rbp,rsp
     3f3:	sub    rsp,0x20
     3f7:	mov    QWORD PTR [rsp+0x10],r12
     3fc:	mov    r12,rdi
     3ff:	mov    QWORD PTR [rsp],0x0
     407:	mov    rdi,r12
     40a:	call   40f <botlish_fn_7+0x20>
			40b: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     40f:	test   rax,rax
     412:	je     430 <botlish_fn_7+0x41>
     418:	mov    QWORD PTR [rsp],rax
     41c:	mov    rsi,rax
     41f:	mov    rdi,r12
     422:	call   427 <botlish_fn_7+0x38>
			423: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     427:	test   rax,rax
     42a:	jne    441 <botlish_fn_7+0x52>
     430:	xor    rax,rax
     433:	mov    r12,QWORD PTR [rsp+0x10]
     438:	add    rsp,0x20
     43c:	mov    rsp,rbp
     43f:	pop    rbp
     440:	ret
     441:	mov    r12,QWORD PTR [rsp+0x10]
     446:	add    rsp,0x20
     44a:	mov    rsp,rbp
     44d:	pop    rbp
     44e:	ret

000000000000044f <botlish_entry_7: ht_new<generic>>:
     44f:	push   rbp
     450:	mov    rbp,rsp
     453:	call   458 <botlish_entry_7+0x9>
			454: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     458:	mov    rsp,rbp
     45b:	pop    rbp
     45c:	ret

000000000000045d <botlish_fn_8: ht_controls<mutarray>>:
     45d:	push   rbp
     45e:	mov    rbp,rsp
     461:	mov    edx,0x1
     466:	call   46b <botlish_fn_8+0xe>
			467: R_X86_64_PLT32	rt_mutarray_get-0x4
     46b:	test   rax,rax
     46e:	jne    47c <botlish_fn_8+0x1f>
     474:	xor    rax,rax
     477:	mov    rsp,rbp
     47a:	pop    rbp
     47b:	ret
     47c:	mov    rsp,rbp
     47f:	pop    rbp
     480:	ret

0000000000000481 <botlish_entry_8: ht_controls<mutarray>>:
     481:	push   rbp
     482:	mov    rbp,rsp
     485:	mov    rsi,QWORD PTR [rdx]
     488:	call   48d <botlish_entry_8+0xc>
			489: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     48d:	mov    rsp,rbp
     490:	pop    rbp
     491:	ret

0000000000000492 <botlish_fn_9: ht_keys<mutarray>>:
     492:	push   rbp
     493:	mov    rbp,rsp
     496:	mov    edx,0x3
     49b:	call   4a0 <botlish_fn_9+0xe>
			49c: R_X86_64_PLT32	rt_mutarray_get-0x4
     4a0:	test   rax,rax
     4a3:	jne    4b1 <botlish_fn_9+0x1f>
     4a9:	xor    rax,rax
     4ac:	mov    rsp,rbp
     4af:	pop    rbp
     4b0:	ret
     4b1:	mov    rsp,rbp
     4b4:	pop    rbp
     4b5:	ret

00000000000004b6 <botlish_entry_9: ht_keys<mutarray>>:
     4b6:	push   rbp
     4b7:	mov    rbp,rsp
     4ba:	mov    rsi,QWORD PTR [rdx]
     4bd:	call   4c2 <botlish_entry_9+0xc>
			4be: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     4c2:	mov    rsp,rbp
     4c5:	pop    rbp
     4c6:	ret

00000000000004c7 <botlish_fn_10: ht_values<mutarray>>:
     4c7:	push   rbp
     4c8:	mov    rbp,rsp
     4cb:	mov    edx,0x5
     4d0:	call   4d5 <botlish_fn_10+0xe>
			4d1: R_X86_64_PLT32	rt_mutarray_get-0x4
     4d5:	test   rax,rax
     4d8:	jne    4e6 <botlish_fn_10+0x1f>
     4de:	xor    rax,rax
     4e1:	mov    rsp,rbp
     4e4:	pop    rbp
     4e5:	ret
     4e6:	mov    rsp,rbp
     4e9:	pop    rbp
     4ea:	ret

00000000000004eb <botlish_entry_10: ht_values<mutarray>>:
     4eb:	push   rbp
     4ec:	mov    rbp,rsp
     4ef:	mov    rsi,QWORD PTR [rdx]
     4f2:	call   4f7 <botlish_entry_10+0xc>
			4f3: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     4f7:	mov    rsp,rbp
     4fa:	pop    rbp
     4fb:	ret

00000000000004fc <botlish_fn_11: ht_size<mutarray>>:
     4fc:	push   rbp
     4fd:	mov    rbp,rsp
     500:	mov    edx,0x7
     505:	call   50a <botlish_fn_11+0xe>
			506: R_X86_64_PLT32	rt_mutarray_get-0x4
     50a:	test   rax,rax
     50d:	jne    51b <botlish_fn_11+0x1f>
     513:	xor    rax,rax
     516:	mov    rsp,rbp
     519:	pop    rbp
     51a:	ret
     51b:	mov    rsp,rbp
     51e:	pop    rbp
     51f:	ret

0000000000000520 <botlish_entry_11: ht_size<mutarray>>:
     520:	push   rbp
     521:	mov    rbp,rsp
     524:	mov    rsi,QWORD PTR [rdx]
     527:	call   52c <botlish_entry_11+0xc>
			528: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     52c:	mov    rsp,rbp
     52f:	pop    rbp
     530:	ret

0000000000000531 <botlish_fn_12: ht_tombstones<mutarray>>:
     531:	push   rbp
     532:	mov    rbp,rsp
     535:	mov    edx,0x9
     53a:	call   53f <botlish_fn_12+0xe>
			53b: R_X86_64_PLT32	rt_mutarray_get-0x4
     53f:	test   rax,rax
     542:	jne    550 <botlish_fn_12+0x1f>
     548:	xor    rax,rax
     54b:	mov    rsp,rbp
     54e:	pop    rbp
     54f:	ret
     550:	mov    rsp,rbp
     553:	pop    rbp
     554:	ret

0000000000000555 <botlish_entry_12: ht_tombstones<mutarray>>:
     555:	push   rbp
     556:	mov    rbp,rsp
     559:	mov    rsi,QWORD PTR [rdx]
     55c:	call   561 <botlish_entry_12+0xc>
			55d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     561:	mov    rsp,rbp
     564:	pop    rbp
     565:	ret

0000000000000566 <botlish_fn_13: ht_capacity<mutarray>>:
     566:	push   rbp
     567:	mov    rbp,rsp
     56a:	sub    rsp,0x20
     56e:	mov    QWORD PTR [rsp+0x10],rbx
     573:	mov    rbx,rdi
     576:	mov    QWORD PTR [rsp],rsi
     57a:	mov    rdi,rbx
     57d:	call   582 <botlish_fn_13+0x1c>
			57e: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     582:	test   rax,rax
     585:	je     5ce <botlish_fn_13+0x68>
     58b:	xor    r9d,r9d
     58e:	test   rax,0x7
     594:	je     5a2 <botlish_fn_13+0x3c>
     59a:	mov    rsi,rax
     59d:	jmp    5b1 <botlish_fn_13+0x4b>
     5a2:	movzx  rcx,BYTE PTR [rax]
     5a6:	mov    rsi,rax
     5a9:	rex cmp cl,0x8
     5ad:	sete   r9b
     5b1:	test   r9b,r9b
     5b4:	jne    5df <botlish_fn_13+0x79>
     5ba:	mov    rdi,rbx
     5bd:	mov    rax,QWORD PTR [rdi+0x10]
     5c1:	mov    rcx,QWORD PTR [rax]
     5c4:	mov    edx,0x8
     5c9:	call   5ce <botlish_fn_13+0x68>
			5ca: R_X86_64_PLT32	rt_type_error-0x4
     5ce:	xor    rax,rax
     5d1:	mov    rbx,QWORD PTR [rsp+0x10]
     5d6:	add    rsp,0x20
     5da:	mov    rsp,rbp
     5dd:	pop    rbp
     5de:	ret
     5df:	mov    rdi,rbx
     5e2:	call   5e7 <botlish_fn_13+0x81>
			5e3: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     5e7:	mov    rbx,QWORD PTR [rsp+0x10]
     5ec:	add    rsp,0x20
     5f0:	mov    rsp,rbp
     5f3:	pop    rbp
     5f4:	ret

00000000000005f5 <botlish_entry_13: ht_capacity<mutarray>>:
     5f5:	push   rbp
     5f6:	mov    rbp,rsp
     5f9:	mov    rsi,QWORD PTR [rdx]
     5fc:	call   601 <botlish_entry_13+0xc>
			5fd: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     601:	mov    rsp,rbp
     604:	pop    rbp
     605:	ret

0000000000000606 <botlish_fn_14: ht_probe_start<mutarray, str>>:
     606:	push   rbp
     607:	mov    rbp,rsp
     60a:	sub    rsp,0x30
     60e:	mov    QWORD PTR [rsp+0x10],r12
     613:	mov    QWORD PTR [rsp+0x18],r13
     618:	mov    QWORD PTR [rsp+0x20],r14
     61d:	mov    r12,rdi
     620:	mov    QWORD PTR [rsp],rsi
     624:	mov    r14,rsi
     627:	mov    rsi,rdx
     62a:	mov    rdi,r12
     62d:	call   632 <botlish_fn_14+0x2c>
			62e: R_X86_64_PLT32	rt_hash-0x4
     632:	test   rax,rax
     635:	je     66e <botlish_fn_14+0x68>
     63b:	mov    QWORD PTR [rsp+0x8],rax
     640:	mov    rsi,r14
     643:	mov    r13,rax
     646:	mov    rdi,r12
     649:	call   64e <botlish_fn_14+0x48>
			64a: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     64e:	test   rax,rax
     651:	mov    rdx,rax
     654:	je     66e <botlish_fn_14+0x68>
     65a:	mov    rsi,r13
     65d:	mov    rdi,r12
     660:	call   665 <botlish_fn_14+0x5f>
			661: R_X86_64_PLT32	rt_int_mod-0x4
     665:	test   rax,rax
     668:	jne    689 <botlish_fn_14+0x83>
     66e:	xor    rax,rax
     671:	mov    r12,QWORD PTR [rsp+0x10]
     676:	mov    r13,QWORD PTR [rsp+0x18]
     67b:	mov    r14,QWORD PTR [rsp+0x20]
     680:	add    rsp,0x30
     684:	mov    rsp,rbp
     687:	pop    rbp
     688:	ret
     689:	mov    r12,QWORD PTR [rsp+0x10]
     68e:	mov    r13,QWORD PTR [rsp+0x18]
     693:	mov    r14,QWORD PTR [rsp+0x20]
     698:	add    rsp,0x30
     69c:	mov    rsp,rbp
     69f:	pop    rbp
     6a0:	ret

00000000000006a1 <botlish_entry_14: ht_probe_start<mutarray, str>>:
     6a1:	push   rbp
     6a2:	mov    rbp,rsp
     6a5:	mov    rsi,QWORD PTR [rdx]
     6a8:	mov    rdx,QWORD PTR [rdx+0x8]
     6ac:	call   6b1 <botlish_entry_14+0x10>
			6ad: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     6b1:	mov    rsp,rbp
     6b4:	pop    rbp
     6b5:	ret

00000000000006b6 <botlish_fn_15: ht_probe_next<mutarray, int>>:
     6b6:	push   rbp
     6b7:	mov    rbp,rsp
     6ba:	sub    rsp,0x30
     6be:	mov    QWORD PTR [rsp+0x20],rbx
     6c3:	mov    QWORD PTR [rsp+0x28],r13
     6c8:	mov    r13,rdi
     6cb:	mov    QWORD PTR [rsp],rsi
     6cf:	mov    rbx,rsi
     6d2:	mov    QWORD PTR [rsp+0x8],rdx
     6d7:	mov    QWORD PTR [rsp+0x10],0x3
     6e0:	test   rdx,0x1
     6e7:	jne    6f5 <botlish_fn_15+0x3f>
     6ed:	mov    rcx,rdx
     6f0:	jmp    70a <botlish_fn_15+0x54>
     6f5:	mov    rsi,rdx
     6f8:	add    rsi,0x2
     6fc:	mov    rcx,rdx
     6ff:	seto   al
     702:	test   al,al
     704:	je     71d <botlish_fn_15+0x67>
     70a:	mov    edx,0x3
     70f:	mov    rsi,rcx
     712:	mov    rdi,r13
     715:	call   71a <botlish_fn_15+0x64>
			716: R_X86_64_PLT32	rt_int_add-0x4
     71a:	mov    rsi,rax
     71d:	mov    QWORD PTR [rsp+0x8],rsi
     722:	mov    rax,rbx
     725:	mov    rbx,rsi
     728:	mov    rsi,rax
     72b:	mov    rdi,r13
     72e:	call   733 <botlish_fn_15+0x7d>
			72f: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     733:	test   rax,rax
     736:	mov    rdx,rax
     739:	je     753 <botlish_fn_15+0x9d>
     73f:	mov    rsi,rbx
     742:	mov    rdi,r13
     745:	call   74a <botlish_fn_15+0x94>
			746: R_X86_64_PLT32	rt_int_mod-0x4
     74a:	test   rax,rax
     74d:	jne    769 <botlish_fn_15+0xb3>
     753:	xor    rax,rax
     756:	mov    rbx,QWORD PTR [rsp+0x20]
     75b:	mov    r13,QWORD PTR [rsp+0x28]
     760:	add    rsp,0x30
     764:	mov    rsp,rbp
     767:	pop    rbp
     768:	ret
     769:	mov    rbx,QWORD PTR [rsp+0x20]
     76e:	mov    r13,QWORD PTR [rsp+0x28]
     773:	add    rsp,0x30
     777:	mov    rsp,rbp
     77a:	pop    rbp
     77b:	ret

000000000000077c <botlish_entry_15: ht_probe_next<mutarray, int>>:
     77c:	push   rbp
     77d:	mov    rbp,rsp
     780:	mov    rsi,QWORD PTR [rdx]
     783:	mov    rdx,QWORD PTR [rdx+0x8]
     787:	call   78c <botlish_entry_15+0x10>
			788: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     78c:	mov    rsp,rbp
     78f:	pop    rbp
     790:	ret
     791:	add    BYTE PTR [rax],al
     793:	add    BYTE PTR [rax],al
     795:	add    BYTE PTR [rax],al
	...

0000000000000798 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     798:	push   rbp
     799:	mov    rbp,rsp
     79c:	sub    rsp,0x60
     7a0:	mov    QWORD PTR [rsp+0x30],rbx
     7a5:	mov    QWORD PTR [rsp+0x38],r12
     7aa:	mov    QWORD PTR [rsp+0x40],r13
     7af:	mov    QWORD PTR [rsp+0x48],r14
     7b4:	mov    QWORD PTR [rsp+0x50],r15
     7b9:	mov    r14,rdi
     7bc:	mov    QWORD PTR [rsp+0x18],0x0
     7c5:	mov    QWORD PTR [rsp],rsi
     7c9:	mov    QWORD PTR [rsp+0x8],rdx
     7ce:	mov    r15,rdx
     7d1:	mov    QWORD PTR [rsp+0x10],rcx
     7d6:	mov    r13,rsi
     7d9:	mov    QWORD PTR [rsp+0x20],rcx
     7de:	mov    rsi,r13
     7e1:	mov    rdi,r14
     7e4:	call   7e9 <botlish_fn_16+0x51>
			7e5: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     7e9:	test   rax,rax
     7ec:	je     a0f <botlish_fn_16+0x277>
     7f2:	xor    ecx,ecx
     7f4:	test   rax,0x7
     7fa:	je     808 <botlish_fn_16+0x70>
     800:	mov    r8,rax
     803:	jmp    816 <botlish_fn_16+0x7e>
     808:	movzx  rcx,BYTE PTR [rax]
     80c:	mov    r8,rax
     80f:	rex cmp cl,0x8
     813:	sete   cl
     816:	test   cl,cl
     818:	jne    83b <botlish_fn_16+0xa3>
     81e:	mov    rdi,r14
     821:	mov    rsi,QWORD PTR [rdi+0x10]
     825:	mov    rcx,QWORD PTR [rsi+0x8]
     829:	mov    edx,0x8
     82e:	mov    rsi,r8
     831:	call   836 <botlish_fn_16+0x9e>
			832: R_X86_64_PLT32	rt_type_error-0x4
     836:	jmp    a0f <botlish_fn_16+0x277>
     83b:	mov    rsi,r8
     83e:	mov    rdx,QWORD PTR [rsp+0x20]
     843:	mov    rdi,r14
     846:	call   84b <botlish_fn_16+0xb3>
			847: R_X86_64_PLT32	rt_mutarray_get-0x4
     84b:	mov    rcx,rax
     84e:	mov    r12,rax
     851:	test   rax,rcx
     854:	je     a0f <botlish_fn_16+0x277>
     85a:	mov    rax,r12
     85d:	mov    QWORD PTR [rsp+0x18],rax
     862:	mov    rdi,r14
     865:	call   86a <botlish_fn_16+0xd2>
			866: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     86a:	test   rax,rax
     86d:	je     a0f <botlish_fn_16+0x277>
     873:	mov    rcx,r12
     876:	and    rcx,rax
     879:	mov    rdx,rax
     87c:	test   rcx,0x1
     883:	jne    8a2 <botlish_fn_16+0x10a>
     889:	mov    rsi,r12
     88c:	mov    rdi,r14
     88f:	call   894 <botlish_fn_16+0xfc>
			890: R_X86_64_PLT32	rt_value_eq-0x4
     894:	test   rax,rax
     897:	je     a0f <botlish_fn_16+0x277>
     89d:	jmp    8b2 <botlish_fn_16+0x11a>
     8a2:	mov    eax,0x2
     8a7:	cmp    r12,rdx
     8aa:	cmove  rax,QWORD PTR [rip+0x1ee]        # aa0 <botlish_fn_16+0x308>
     8b2:	mov    ebx,0x6
     8b7:	cmp    rax,0x6
     8bb:	je     a76 <botlish_fn_16+0x2de>
     8c1:	mov    rdi,r14
     8c4:	call   8c9 <botlish_fn_16+0x131>
			8c5: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     8c9:	test   rax,rax
     8cc:	je     a0f <botlish_fn_16+0x277>
     8d2:	mov    rcx,r12
     8d5:	and    rcx,rax
     8d8:	mov    rdx,rax
     8db:	test   rcx,0x1
     8e2:	jne    901 <botlish_fn_16+0x169>
     8e8:	mov    rsi,r12
     8eb:	mov    rdi,r14
     8ee:	call   8f3 <botlish_fn_16+0x15b>
			8ef: R_X86_64_PLT32	rt_value_eq-0x4
     8f3:	test   rax,rax
     8f6:	je     a0f <botlish_fn_16+0x277>
     8fc:	jmp    914 <botlish_fn_16+0x17c>
     901:	mov    rsi,r12
     904:	mov    eax,0x2
     909:	cmp    rsi,rdx
     90c:	cmove  rax,QWORD PTR [rip+0x18c]        # aa0 <botlish_fn_16+0x308>
     914:	cmp    rax,0x6
     918:	je     92b <botlish_fn_16+0x193>
     91e:	mov    ebx,0x2
     923:	mov    r12,r15
     926:	jmp    9ec <botlish_fn_16+0x254>
     92b:	mov    rsi,r13
     92e:	mov    rdi,r14
     931:	call   936 <botlish_fn_16+0x19e>
			932: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     936:	test   rax,rax
     939:	je     a0f <botlish_fn_16+0x277>
     93f:	xor    ecx,ecx
     941:	test   rax,0x7
     947:	je     955 <botlish_fn_16+0x1bd>
     94d:	mov    rsi,rax
     950:	jmp    963 <botlish_fn_16+0x1cb>
     955:	movzx  rcx,BYTE PTR [rax]
     959:	mov    rsi,rax
     95c:	rex cmp cl,0x8
     960:	sete   cl
     963:	test   cl,cl
     965:	jne    985 <botlish_fn_16+0x1ed>
     96b:	mov    rdi,r14
     96e:	mov    rax,QWORD PTR [rdi+0x10]
     972:	mov    rcx,QWORD PTR [rax+0x8]
     976:	mov    edx,0x8
     97b:	call   980 <botlish_fn_16+0x1e8>
			97c: R_X86_64_PLT32	rt_type_error-0x4
     980:	jmp    a0f <botlish_fn_16+0x277>
     985:	mov    rdx,QWORD PTR [rsp+0x20]
     98a:	mov    rdi,r14
     98d:	call   992 <botlish_fn_16+0x1fa>
			98e: R_X86_64_PLT32	rt_mutarray_get-0x4
     992:	test   rax,rax
     995:	je     a0f <botlish_fn_16+0x277>
     99b:	mov    r12,r15
     99e:	mov    rcx,rax
     9a1:	and    rcx,r12
     9a4:	mov    rsi,rax
     9a7:	test   rcx,0x1
     9ae:	jne    9cd <botlish_fn_16+0x235>
     9b4:	mov    rdx,r12
     9b7:	mov    rdi,r14
     9ba:	call   9bf <botlish_fn_16+0x227>
			9bb: R_X86_64_PLT32	rt_value_eq-0x4
     9bf:	test   rax,rax
     9c2:	je     a0f <botlish_fn_16+0x277>
     9c8:	jmp    9dd <botlish_fn_16+0x245>
     9cd:	mov    eax,0x2
     9d2:	cmp    rsi,r12
     9d5:	cmove  rax,QWORD PTR [rip+0xc3]        # aa0 <botlish_fn_16+0x308>
     9dd:	cmp    rax,0x6
     9e1:	je     9ec <botlish_fn_16+0x254>
     9e7:	mov    ebx,0x2
     9ec:	cmp    rbx,0x6
     9f0:	je     a4f <botlish_fn_16+0x2b7>
     9f6:	mov    rdx,QWORD PTR [rsp+0x20]
     9fb:	mov    rsi,r13
     9fe:	mov    rdi,r14
     a01:	call   a06 <botlish_fn_16+0x26e>
			a02: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     a06:	test   rax,rax
     a09:	jne    a34 <botlish_fn_16+0x29c>
     a0f:	xor    rax,rax
     a12:	mov    rbx,QWORD PTR [rsp+0x30]
     a17:	mov    r12,QWORD PTR [rsp+0x38]
     a1c:	mov    r13,QWORD PTR [rsp+0x40]
     a21:	mov    r14,QWORD PTR [rsp+0x48]
     a26:	mov    r15,QWORD PTR [rsp+0x50]
     a2b:	add    rsp,0x60
     a2f:	mov    rsp,rbp
     a32:	pop    rbp
     a33:	ret
     a34:	mov    QWORD PTR [rsp],r13
     a38:	mov    QWORD PTR [rsp+0x8],r12
     a3d:	mov    QWORD PTR [rsp+0x10],rax
     a42:	mov    r15,r12
     a45:	mov    QWORD PTR [rsp+0x20],rax
     a4a:	jmp    7de <botlish_fn_16+0x46>
     a4f:	mov    rax,QWORD PTR [rsp+0x20]
     a54:	mov    rbx,QWORD PTR [rsp+0x30]
     a59:	mov    r12,QWORD PTR [rsp+0x38]
     a5e:	mov    r13,QWORD PTR [rsp+0x40]
     a63:	mov    r14,QWORD PTR [rsp+0x48]
     a68:	mov    r15,QWORD PTR [rsp+0x50]
     a6d:	add    rsp,0x60
     a71:	mov    rsp,rbp
     a74:	pop    rbp
     a75:	ret
     a76:	mov    rax,0xffffffffffffffff
     a7d:	mov    rbx,QWORD PTR [rsp+0x30]
     a82:	mov    r12,QWORD PTR [rsp+0x38]
     a87:	mov    r13,QWORD PTR [rsp+0x40]
     a8c:	mov    r14,QWORD PTR [rsp+0x48]
     a91:	mov    r15,QWORD PTR [rsp+0x50]
     a96:	add    rsp,0x60
     a9a:	mov    rsp,rbp
     a9d:	pop    rbp
     a9e:	ret
     a9f:	add    BYTE PTR [rsi],al
     aa1:	add    BYTE PTR [rax],al
     aa3:	add    BYTE PTR [rax],al
     aa5:	add    BYTE PTR [rax],al
	...

0000000000000aa8 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
     aa8:	push   rbp
     aa9:	mov    rbp,rsp
     aac:	mov    rsi,QWORD PTR [rdx]
     aaf:	mov    r8,QWORD PTR [rdx+0x8]
     ab3:	mov    rcx,QWORD PTR [rdx+0x10]
     ab7:	mov    rdx,r8
     aba:	call   abf <botlish_entry_16+0x17>
			abb: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
     abf:	mov    rsp,rbp
     ac2:	pop    rbp
     ac3:	ret
     ac4:	add    BYTE PTR [rax],al
	...

0000000000000ac8 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
     ac8:	push   rbp
     ac9:	mov    rbp,rsp
     acc:	sub    rsp,0x70
     ad0:	mov    QWORD PTR [rsp+0x40],rbx
     ad5:	mov    QWORD PTR [rsp+0x48],r12
     ada:	mov    QWORD PTR [rsp+0x50],r13
     adf:	mov    QWORD PTR [rsp+0x58],r14
     ae4:	mov    QWORD PTR [rsp+0x60],r15
     ae9:	mov    r15,rdi
     aec:	mov    QWORD PTR [rsp+0x20],0x0
     af5:	mov    QWORD PTR [rsp],rsi
     af9:	mov    QWORD PTR [rsp+0x8],rdx
     afe:	mov    r13,rdx
     b01:	mov    QWORD PTR [rsp+0x10],rcx
     b06:	mov    QWORD PTR [rsp+0x18],r8
     b0b:	mov    rbx,rsi
     b0e:	mov    QWORD PTR [rsp+0x28],rcx
     b13:	mov    QWORD PTR [rsp+0x30],r8
     b18:	mov    rsi,rbx
     b1b:	mov    rdi,r15
     b1e:	call   b23 <botlish_fn_17+0x5b>
			b1f: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     b23:	test   rax,rax
     b26:	je     e60 <botlish_fn_17+0x398>
     b2c:	xor    ecx,ecx
     b2e:	test   rax,0x7
     b34:	je     b42 <botlish_fn_17+0x7a>
     b3a:	mov    rsi,rax
     b3d:	jmp    b50 <botlish_fn_17+0x88>
     b42:	movzx  rcx,BYTE PTR [rax]
     b46:	mov    rsi,rax
     b49:	rex cmp cl,0x8
     b4d:	sete   cl
     b50:	test   cl,cl
     b52:	jne    b72 <botlish_fn_17+0xaa>
     b58:	mov    rdi,r15
     b5b:	mov    rax,QWORD PTR [rdi+0x10]
     b5f:	mov    rcx,QWORD PTR [rax+0x8]
     b63:	mov    edx,0x8
     b68:	call   b6d <botlish_fn_17+0xa5>
			b69: R_X86_64_PLT32	rt_type_error-0x4
     b6d:	jmp    e60 <botlish_fn_17+0x398>
     b72:	mov    rdx,QWORD PTR [rsp+0x28]
     b77:	mov    rdi,r15
     b7a:	call   b7f <botlish_fn_17+0xb7>
			b7b: R_X86_64_PLT32	rt_mutarray_get-0x4
     b7f:	mov    r10,rax
     b82:	mov    r14,rax
     b85:	test   rax,r10
     b88:	je     e60 <botlish_fn_17+0x398>
     b8e:	mov    rax,r14
     b91:	mov    QWORD PTR [rsp+0x20],rax
     b96:	mov    rdi,r15
     b99:	call   b9e <botlish_fn_17+0xd6>
			b9a: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     b9e:	test   rax,rax
     ba1:	je     e60 <botlish_fn_17+0x398>
     ba7:	mov    rcx,r14
     baa:	and    rcx,rax
     bad:	mov    rdx,rax
     bb0:	test   rcx,0x1
     bb7:	jne    bd6 <botlish_fn_17+0x10e>
     bbd:	mov    rsi,r14
     bc0:	mov    rdi,r15
     bc3:	call   bc8 <botlish_fn_17+0x100>
			bc4: R_X86_64_PLT32	rt_value_eq-0x4
     bc8:	test   rax,rax
     bcb:	je     e60 <botlish_fn_17+0x398>
     bd1:	jmp    be9 <botlish_fn_17+0x121>
     bd6:	mov    eax,0x2
     bdb:	mov    rcx,r14
     bde:	cmp    rcx,rdx
     be1:	cmove  rax,QWORD PTR [rip+0x39f]        # f88 <botlish_fn_17+0x4c0>
     be9:	mov    r12d,0x6
     bef:	cmp    rax,0x6
     bf3:	je     ed8 <botlish_fn_17+0x410>
     bf9:	mov    rdi,r15
     bfc:	call   c01 <botlish_fn_17+0x139>
			bfd: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     c01:	test   rax,rax
     c04:	je     e60 <botlish_fn_17+0x398>
     c0a:	mov    rcx,r14
     c0d:	and    rcx,rax
     c10:	mov    rdx,rax
     c13:	test   rcx,0x1
     c1a:	jne    c39 <botlish_fn_17+0x171>
     c20:	mov    rsi,r14
     c23:	mov    rdi,r15
     c26:	call   c2b <botlish_fn_17+0x163>
			c27: R_X86_64_PLT32	rt_value_eq-0x4
     c2b:	test   rax,rax
     c2e:	je     e60 <botlish_fn_17+0x398>
     c34:	jmp    c4c <botlish_fn_17+0x184>
     c39:	mov    eax,0x2
     c3e:	mov    rcx,r14
     c41:	cmp    rcx,rdx
     c44:	cmove  rax,QWORD PTR [rip+0x33c]        # f88 <botlish_fn_17+0x4c0>
     c4c:	cmp    rax,0x6
     c50:	je     c60 <botlish_fn_17+0x198>
     c56:	mov    eax,0x2
     c5b:	jmp    d26 <botlish_fn_17+0x25e>
     c60:	mov    rsi,rbx
     c63:	mov    rdi,r15
     c66:	call   c6b <botlish_fn_17+0x1a3>
			c67: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     c6b:	test   rax,rax
     c6e:	je     e60 <botlish_fn_17+0x398>
     c74:	xor    ecx,ecx
     c76:	test   rax,0x7
     c7c:	je     c8a <botlish_fn_17+0x1c2>
     c82:	mov    rsi,rax
     c85:	jmp    c98 <botlish_fn_17+0x1d0>
     c8a:	movzx  r8,BYTE PTR [rax]
     c8e:	mov    rsi,rax
     c91:	cmp    r8b,0x8
     c95:	sete   cl
     c98:	test   cl,cl
     c9a:	jne    cba <botlish_fn_17+0x1f2>
     ca0:	mov    rdi,r15
     ca3:	mov    rax,QWORD PTR [rdi+0x10]
     ca7:	mov    rcx,QWORD PTR [rax+0x8]
     cab:	mov    edx,0x8
     cb0:	call   cb5 <botlish_fn_17+0x1ed>
			cb1: R_X86_64_PLT32	rt_type_error-0x4
     cb5:	jmp    e60 <botlish_fn_17+0x398>
     cba:	mov    rdx,QWORD PTR [rsp+0x28]
     cbf:	mov    rdi,r15
     cc2:	call   cc7 <botlish_fn_17+0x1ff>
			cc3: R_X86_64_PLT32	rt_mutarray_get-0x4
     cc7:	test   rax,rax
     cca:	je     e60 <botlish_fn_17+0x398>
     cd0:	mov    rcx,rax
     cd3:	and    rcx,r13
     cd6:	mov    rsi,rax
     cd9:	test   rcx,0x1
     ce0:	jne    cff <botlish_fn_17+0x237>
     ce6:	mov    rdx,r13
     ce9:	mov    rdi,r15
     cec:	call   cf1 <botlish_fn_17+0x229>
			ced: R_X86_64_PLT32	rt_value_eq-0x4
     cf1:	test   rax,rax
     cf4:	je     e60 <botlish_fn_17+0x398>
     cfa:	jmp    d0f <botlish_fn_17+0x247>
     cff:	mov    eax,0x2
     d04:	cmp    rsi,r13
     d07:	cmove  rax,QWORD PTR [rip+0x279]        # f88 <botlish_fn_17+0x4c0>
     d0f:	cmp    rax,0x6
     d13:	je     d23 <botlish_fn_17+0x25b>
     d19:	mov    eax,0x2
     d1e:	jmp    d26 <botlish_fn_17+0x25e>
     d23:	mov    rax,r12
     d26:	cmp    rax,0x6
     d2a:	je     eb1 <botlish_fn_17+0x3e9>
     d30:	mov    rdi,r15
     d33:	call   d38 <botlish_fn_17+0x270>
			d34: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
     d38:	test   rax,rax
     d3b:	je     e60 <botlish_fn_17+0x398>
     d41:	mov    rcx,r14
     d44:	mov    rdx,rcx
     d47:	and    rdx,rax
     d4a:	mov    rsi,rax
     d4d:	test   rdx,0x1
     d54:	jne    d76 <botlish_fn_17+0x2ae>
     d5a:	mov    rdx,rsi
     d5d:	mov    rsi,r14
     d60:	mov    rdi,r15
     d63:	call   d68 <botlish_fn_17+0x2a0>
			d64: R_X86_64_PLT32	rt_value_eq-0x4
     d68:	test   rax,rax
     d6b:	je     e60 <botlish_fn_17+0x398>
     d71:	jmp    d8c <botlish_fn_17+0x2c4>
     d76:	mov    rdx,rsi
     d79:	mov    rsi,r14
     d7c:	mov    eax,0x2
     d81:	cmp    rsi,rdx
     d84:	cmove  rax,QWORD PTR [rip+0x1fc]        # f88 <botlish_fn_17+0x4c0>
     d8c:	cmp    rax,0x6
     d90:	je     da1 <botlish_fn_17+0x2d9>
     d96:	mov    r12d,0x2
     d9c:	jmp    e02 <botlish_fn_17+0x33a>
     da1:	mov    r14,QWORD PTR [rsp+0x30]
     da6:	test   r14,0x1
     dad:	jne    ddd <botlish_fn_17+0x315>
     db3:	mov    edx,0x1
     db8:	mov    rsi,r14
     dbb:	mov    rdi,r15
     dbe:	call   dc3 <botlish_fn_17+0x2fb>
			dbf: R_X86_64_PLT32	rt_int_cmp-0x4
     dc3:	mov    ecx,0x2
     dc8:	test   rax,rax
     dcb:	cmovl  rcx,QWORD PTR [rip+0x1b5]        # f88 <botlish_fn_17+0x4c0>
     dd3:	mov    QWORD PTR [rsp+0x30],r14
     dd8:	jmp    df2 <botlish_fn_17+0x32a>
     ddd:	mov    ecx,0x2
     de2:	test   r14,r14
     de5:	mov    QWORD PTR [rsp+0x30],r14
     dea:	cmovle rcx,QWORD PTR [rip+0x196]        # f88 <botlish_fn_17+0x4c0>
     df2:	cmp    rcx,0x6
     df6:	je     e02 <botlish_fn_17+0x33a>
     dfc:	mov    r12d,0x2
     e02:	cmp    r12,0x6
     e06:	je     e47 <botlish_fn_17+0x37f>
     e0c:	mov    rdx,QWORD PTR [rsp+0x28]
     e11:	mov    rsi,rbx
     e14:	mov    rdi,r15
     e17:	call   e1c <botlish_fn_17+0x354>
			e18: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     e1c:	test   rax,rax
     e1f:	je     e60 <botlish_fn_17+0x398>
     e25:	mov    QWORD PTR [rsp],rbx
     e29:	mov    QWORD PTR [rsp+0x8],r13
     e2e:	mov    QWORD PTR [rsp+0x10],rax
     e33:	mov    rcx,QWORD PTR [rsp+0x30]
     e38:	mov    QWORD PTR [rsp+0x18],rcx
     e3d:	mov    QWORD PTR [rsp+0x28],rax
     e42:	jmp    b18 <botlish_fn_17+0x50>
     e47:	mov    rdx,QWORD PTR [rsp+0x28]
     e4c:	mov    rsi,rbx
     e4f:	mov    rdi,r15
     e52:	call   e57 <botlish_fn_17+0x38f>
			e53: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     e57:	test   rax,rax
     e5a:	jne    e85 <botlish_fn_17+0x3bd>
     e60:	xor    rax,rax
     e63:	mov    rbx,QWORD PTR [rsp+0x40]
     e68:	mov    r12,QWORD PTR [rsp+0x48]
     e6d:	mov    r13,QWORD PTR [rsp+0x50]
     e72:	mov    r14,QWORD PTR [rsp+0x58]
     e77:	mov    r15,QWORD PTR [rsp+0x60]
     e7c:	add    rsp,0x70
     e80:	mov    rsp,rbp
     e83:	pop    rbp
     e84:	ret
     e85:	mov    QWORD PTR [rsp],rbx
     e89:	mov    QWORD PTR [rsp+0x8],r13
     e8e:	mov    QWORD PTR [rsp+0x10],rax
     e93:	mov    rdx,QWORD PTR [rsp+0x28]
     e98:	mov    QWORD PTR [rsp+0x18],rdx
     e9d:	mov    rcx,QWORD PTR [rsp+0x28]
     ea2:	mov    QWORD PTR [rsp+0x30],rcx
     ea7:	mov    QWORD PTR [rsp+0x28],rax
     eac:	jmp    b18 <botlish_fn_17+0x50>
     eb1:	mov    rax,QWORD PTR [rsp+0x28]
     eb6:	mov    rbx,QWORD PTR [rsp+0x40]
     ebb:	mov    r12,QWORD PTR [rsp+0x48]
     ec0:	mov    r13,QWORD PTR [rsp+0x50]
     ec5:	mov    r14,QWORD PTR [rsp+0x58]
     eca:	mov    r15,QWORD PTR [rsp+0x60]
     ecf:	add    rsp,0x70
     ed3:	mov    rsp,rbp
     ed6:	pop    rbp
     ed7:	ret
     ed8:	mov    rax,QWORD PTR [rsp+0x30]
     edd:	test   rax,0x1
     ee3:	jne    f10 <botlish_fn_17+0x448>
     ee9:	mov    edx,0x1
     eee:	mov    rdi,r15
     ef1:	mov    rsi,QWORD PTR [rsp+0x30]
     ef6:	call   efb <botlish_fn_17+0x433>
			ef7: R_X86_64_PLT32	rt_int_cmp-0x4
     efb:	mov    esi,0x2
     f00:	test   rax,rax
     f03:	cmovge rsi,QWORD PTR [rip+0x7d]        # f88 <botlish_fn_17+0x4c0>
     f0b:	jmp    f2a <botlish_fn_17+0x462>
     f10:	mov    esi,0x2
     f15:	mov    rax,QWORD PTR [rsp+0x30]
     f1a:	mov    rcx,QWORD PTR [rsp+0x30]
     f1f:	test   rax,rcx
     f22:	cmovg  rsi,QWORD PTR [rip+0x5e]        # f88 <botlish_fn_17+0x4c0>
     f2a:	cmp    rsi,0x6
     f2e:	je     f5b <botlish_fn_17+0x493>
     f34:	mov    rax,QWORD PTR [rsp+0x28]
     f39:	mov    rbx,QWORD PTR [rsp+0x40]
     f3e:	mov    r12,QWORD PTR [rsp+0x48]
     f43:	mov    r13,QWORD PTR [rsp+0x50]
     f48:	mov    r14,QWORD PTR [rsp+0x58]
     f4d:	mov    r15,QWORD PTR [rsp+0x60]
     f52:	add    rsp,0x70
     f56:	mov    rsp,rbp
     f59:	pop    rbp
     f5a:	ret
     f5b:	mov    rax,QWORD PTR [rsp+0x30]
     f60:	mov    rbx,QWORD PTR [rsp+0x40]
     f65:	mov    r12,QWORD PTR [rsp+0x48]
     f6a:	mov    r13,QWORD PTR [rsp+0x50]
     f6f:	mov    r14,QWORD PTR [rsp+0x58]
     f74:	mov    r15,QWORD PTR [rsp+0x60]
     f79:	add    rsp,0x70
     f7d:	mov    rsp,rbp
     f80:	pop    rbp
     f81:	ret
     f82:	add    BYTE PTR [rax],al
     f84:	add    BYTE PTR [rax],al
     f86:	add    BYTE PTR [rax],al
     f88:	(bad)
     f89:	add    BYTE PTR [rax],al
     f8b:	add    BYTE PTR [rax],al
     f8d:	add    BYTE PTR [rax],al
	...

0000000000000f90 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
     f90:	push   rbp
     f91:	mov    rbp,rsp
     f94:	mov    rsi,QWORD PTR [rdx]
     f97:	mov    r9,QWORD PTR [rdx+0x8]
     f9b:	mov    rcx,QWORD PTR [rdx+0x10]
     f9f:	mov    r8,QWORD PTR [rdx+0x18]
     fa3:	mov    rdx,r9
     fa6:	call   fab <botlish_entry_17+0x1b>
			fa7: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
     fab:	mov    rsp,rbp
     fae:	pop    rbp
     faf:	ret

0000000000000fb0 <botlish_fn_18: ht_get<mutarray, str>>:
     fb0:	push   rbp
     fb1:	mov    rbp,rsp
     fb4:	sub    rsp,0x40
     fb8:	mov    QWORD PTR [rsp+0x20],rbx
     fbd:	mov    QWORD PTR [rsp+0x28],r12
     fc2:	mov    QWORD PTR [rsp+0x30],r13
     fc7:	mov    rbx,rdi
     fca:	mov    QWORD PTR [rsp+0x10],0x0
     fd3:	mov    QWORD PTR [rsp],rsi
     fd7:	mov    r13,rsi
     fda:	mov    QWORD PTR [rsp+0x8],rdx
     fdf:	mov    r12,rdx
     fe2:	mov    rdx,r12
     fe5:	mov    rsi,r13
     fe8:	mov    rdi,rbx
     feb:	call   ff0 <botlish_fn_18+0x40>
			fec: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     ff0:	test   rax,rax
     ff3:	je     10e2 <botlish_fn_18+0x132>
     ff9:	mov    QWORD PTR [rsp+0x10],rax
     ffe:	mov    rcx,rax
    1001:	mov    rdx,r12
    1004:	mov    rsi,r13
    1007:	mov    rdi,rbx
    100a:	call   100f <botlish_fn_18+0x5f>
			100b: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    100f:	mov    rcx,rax
    1012:	mov    r12,rax
    1015:	test   rax,rcx
    1018:	je     10e2 <botlish_fn_18+0x132>
    101e:	mov    rax,r12
    1021:	mov    QWORD PTR [rsp+0x8],rax
    1026:	test   rax,0x1
    102c:	jne    1057 <botlish_fn_18+0xa7>
    1032:	mov    edx,0x1
    1037:	mov    rsi,r12
    103a:	mov    rdi,rbx
    103d:	call   1042 <botlish_fn_18+0x92>
			103e: R_X86_64_PLT32	rt_int_cmp-0x4
    1042:	mov    ecx,0x2
    1047:	test   rax,rax
    104a:	cmovl  rcx,QWORD PTR [rip+0xe6]        # 1138 <botlish_fn_18+0x188>
    1052:	jmp    106a <botlish_fn_18+0xba>
    1057:	mov    ecx,0x2
    105c:	mov    rax,r12
    105f:	test   rax,rax
    1062:	cmovle rcx,QWORD PTR [rip+0xce]        # 1138 <botlish_fn_18+0x188>
    106a:	cmp    rcx,0x6
    106e:	je     1115 <botlish_fn_18+0x165>
    1074:	mov    rsi,r13
    1077:	mov    rdi,rbx
    107a:	call   107f <botlish_fn_18+0xcf>
			107b: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    107f:	test   rax,rax
    1082:	je     10e2 <botlish_fn_18+0x132>
    1088:	xor    ecx,ecx
    108a:	test   rax,0x7
    1090:	je     109e <botlish_fn_18+0xee>
    1096:	mov    rsi,rax
    1099:	jmp    10ac <botlish_fn_18+0xfc>
    109e:	movzx  rcx,BYTE PTR [rax]
    10a2:	mov    rsi,rax
    10a5:	rex cmp cl,0x8
    10a9:	sete   cl
    10ac:	test   cl,cl
    10ae:	jne    10ce <botlish_fn_18+0x11e>
    10b4:	mov    rdi,rbx
    10b7:	mov    rax,QWORD PTR [rdi+0x10]
    10bb:	mov    rcx,QWORD PTR [rax+0x8]
    10bf:	mov    edx,0x8
    10c4:	call   10c9 <botlish_fn_18+0x119>
			10c5: R_X86_64_PLT32	rt_type_error-0x4
    10c9:	jmp    10e2 <botlish_fn_18+0x132>
    10ce:	mov    rdx,r12
    10d1:	mov    rdi,rbx
    10d4:	call   10d9 <botlish_fn_18+0x129>
			10d5: R_X86_64_PLT32	rt_mutarray_get-0x4
    10d9:	test   rax,rax
    10dc:	jne    10fd <botlish_fn_18+0x14d>
    10e2:	xor    rax,rax
    10e5:	mov    rbx,QWORD PTR [rsp+0x20]
    10ea:	mov    r12,QWORD PTR [rsp+0x28]
    10ef:	mov    r13,QWORD PTR [rsp+0x30]
    10f4:	add    rsp,0x40
    10f8:	mov    rsp,rbp
    10fb:	pop    rbp
    10fc:	ret
    10fd:	mov    rbx,QWORD PTR [rsp+0x20]
    1102:	mov    r12,QWORD PTR [rsp+0x28]
    1107:	mov    r13,QWORD PTR [rsp+0x30]
    110c:	add    rsp,0x40
    1110:	mov    rsp,rbp
    1113:	pop    rbp
    1114:	ret
    1115:	mov    eax,0xa
    111a:	mov    rbx,QWORD PTR [rsp+0x20]
    111f:	mov    r12,QWORD PTR [rsp+0x28]
    1124:	mov    r13,QWORD PTR [rsp+0x30]
    1129:	add    rsp,0x40
    112d:	mov    rsp,rbp
    1130:	pop    rbp
    1131:	ret
    1132:	add    BYTE PTR [rax],al
    1134:	add    BYTE PTR [rax],al
    1136:	add    BYTE PTR [rax],al
    1138:	(bad)
    1139:	add    BYTE PTR [rax],al
    113b:	add    BYTE PTR [rax],al
    113d:	add    BYTE PTR [rax],al
	...

0000000000001140 <botlish_entry_18: ht_get<mutarray, str>>:
    1140:	push   rbp
    1141:	mov    rbp,rsp
    1144:	mov    rsi,QWORD PTR [rdx]
    1147:	mov    rdx,QWORD PTR [rdx+0x8]
    114b:	call   1150 <botlish_entry_18+0x10>
			114c: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    1150:	mov    rsp,rbp
    1153:	pop    rbp
    1154:	ret
    1155:	add    BYTE PTR [rax],al
	...

0000000000001158 <botlish_fn_19: ht_contains<mutarray, str>>:
    1158:	push   rbp
    1159:	mov    rbp,rsp
    115c:	sub    rsp,0x40
    1160:	mov    QWORD PTR [rsp+0x20],rbx
    1165:	mov    QWORD PTR [rsp+0x28],r12
    116a:	mov    QWORD PTR [rsp+0x30],r15
    116f:	mov    r15,rdi
    1172:	mov    QWORD PTR [rsp+0x10],0x0
    117b:	mov    QWORD PTR [rsp],rsi
    117f:	mov    r12,rsi
    1182:	mov    QWORD PTR [rsp+0x8],rdx
    1187:	mov    rbx,rdx
    118a:	mov    rdx,rbx
    118d:	mov    rsi,r12
    1190:	mov    rdi,r15
    1193:	call   1198 <botlish_fn_19+0x40>
			1194: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    1198:	test   rax,rax
    119b:	je     11c0 <botlish_fn_19+0x68>
    11a1:	mov    QWORD PTR [rsp+0x10],rax
    11a6:	mov    rcx,rax
    11a9:	mov    rdx,rbx
    11ac:	mov    rsi,r12
    11af:	mov    rdi,r15
    11b2:	call   11b7 <botlish_fn_19+0x5f>
			11b3: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    11b7:	test   rax,rax
    11ba:	jne    11db <botlish_fn_19+0x83>
    11c0:	xor    rax,rax
    11c3:	mov    rbx,QWORD PTR [rsp+0x20]
    11c8:	mov    r12,QWORD PTR [rsp+0x28]
    11cd:	mov    r15,QWORD PTR [rsp+0x30]
    11d2:	add    rsp,0x40
    11d6:	mov    rsp,rbp
    11d9:	pop    rbp
    11da:	ret
    11db:	test   rax,0x1
    11e1:	mov    rsi,rax
    11e4:	jne    120f <botlish_fn_19+0xb7>
    11ea:	mov    edx,0x1
    11ef:	mov    rdi,r15
    11f2:	call   11f7 <botlish_fn_19+0x9f>
			11f3: R_X86_64_PLT32	rt_int_cmp-0x4
    11f7:	mov    ecx,0x2
    11fc:	test   rax,rax
    11ff:	mov    rax,rcx
    1202:	cmovge rax,QWORD PTR [rip+0x2e]        # 1238 <botlish_fn_19+0xe0>
    120a:	jmp    121f <botlish_fn_19+0xc7>
    120f:	mov    eax,0x2
    1214:	test   rsi,rsi
    1217:	cmovg  rax,QWORD PTR [rip+0x19]        # 1238 <botlish_fn_19+0xe0>
    121f:	mov    rbx,QWORD PTR [rsp+0x20]
    1224:	mov    r12,QWORD PTR [rsp+0x28]
    1229:	mov    r15,QWORD PTR [rsp+0x30]
    122e:	add    rsp,0x40
    1232:	mov    rsp,rbp
    1235:	pop    rbp
    1236:	ret
    1237:	add    BYTE PTR [rsi],al
    1239:	add    BYTE PTR [rax],al
    123b:	add    BYTE PTR [rax],al
    123d:	add    BYTE PTR [rax],al
	...

0000000000001240 <botlish_entry_19: ht_contains<mutarray, str>>:
    1240:	push   rbp
    1241:	mov    rbp,rsp
    1244:	mov    rsi,QWORD PTR [rdx]
    1247:	mov    rdx,QWORD PTR [rdx+0x8]
    124b:	call   1250 <botlish_entry_19+0x10>
			124c: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    1250:	mov    rsp,rbp
    1253:	pop    rbp
    1254:	ret
    1255:	add    BYTE PTR [rax],al
	...

0000000000001258 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    1258:	push   rbp
    1259:	mov    rbp,rsp
    125c:	sub    rsp,0x50
    1260:	mov    QWORD PTR [rsp+0x20],rbx
    1265:	mov    QWORD PTR [rsp+0x28],r12
    126a:	mov    QWORD PTR [rsp+0x30],r13
    126f:	mov    QWORD PTR [rsp+0x38],r14
    1274:	mov    QWORD PTR [rsp+0x40],r15
    1279:	mov    r13,rdi
    127c:	mov    QWORD PTR [rsp],rsi
    1280:	mov    QWORD PTR [rsp+0x8],rdx
    1285:	mov    QWORD PTR [rsp+0x10],rcx
    128a:	mov    r12,rcx
    128d:	mov    rbx,rsi
    1290:	mov    r14,rdx
    1293:	mov    rdx,r14
    1296:	mov    rsi,rbx
    1299:	mov    rdi,r13
    129c:	call   12a1 <botlish_fn_20+0x49>
			129d: R_X86_64_PLT32	rt_mutarray_get-0x4
    12a1:	test   rax,rax
    12a4:	je     1367 <botlish_fn_20+0x10f>
    12aa:	mov    QWORD PTR [rsp+0x18],rax
    12af:	mov    r15,rax
    12b2:	mov    rdi,r13
    12b5:	call   12ba <botlish_fn_20+0x62>
			12b6: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    12ba:	test   rax,rax
    12bd:	je     1367 <botlish_fn_20+0x10f>
    12c3:	mov    rcx,r15
    12c6:	mov    rdx,rcx
    12c9:	and    rdx,rax
    12cc:	test   rdx,0x1
    12d3:	jne    12f5 <botlish_fn_20+0x9d>
    12d9:	mov    rdx,rax
    12dc:	mov    rsi,r15
    12df:	mov    rdi,r13
    12e2:	call   12e7 <botlish_fn_20+0x8f>
			12e3: R_X86_64_PLT32	rt_value_eq-0x4
    12e7:	test   rax,rax
    12ea:	je     1367 <botlish_fn_20+0x10f>
    12f0:	jmp    130b <botlish_fn_20+0xb3>
    12f5:	mov    rdx,rax
    12f8:	mov    rsi,r15
    12fb:	mov    eax,0x2
    1300:	cmp    rsi,rdx
    1303:	cmove  rax,QWORD PTR [rip+0xbd]        # 13c8 <botlish_fn_20+0x170>
    130b:	cmp    rax,0x6
    130f:	je     13a2 <botlish_fn_20+0x14a>
    1315:	mov    QWORD PTR [rsp+0x18],0x3
    131e:	mov    rsi,r14
    1321:	test   rsi,0x1
    1328:	je     1340 <botlish_fn_20+0xe8>
    132e:	mov    rsi,r14
    1331:	add    rsi,0x2
    1335:	seto   al
    1338:	test   al,al
    133a:	je     1353 <botlish_fn_20+0xfb>
    1340:	mov    edx,0x3
    1345:	mov    rsi,r14
    1348:	mov    rdi,r13
    134b:	call   1350 <botlish_fn_20+0xf8>
			134c: R_X86_64_PLT32	rt_int_add-0x4
    1350:	mov    rsi,rax
    1353:	mov    rdx,r12
    1356:	mov    rdi,r13
    1359:	call   135e <botlish_fn_20+0x106>
			135a: R_X86_64_PLT32	rt_int_mod-0x4
    135e:	test   rax,rax
    1361:	jne    138c <botlish_fn_20+0x134>
    1367:	xor    rax,rax
    136a:	mov    rbx,QWORD PTR [rsp+0x20]
    136f:	mov    r12,QWORD PTR [rsp+0x28]
    1374:	mov    r13,QWORD PTR [rsp+0x30]
    1379:	mov    r14,QWORD PTR [rsp+0x38]
    137e:	mov    r15,QWORD PTR [rsp+0x40]
    1383:	add    rsp,0x50
    1387:	mov    rsp,rbp
    138a:	pop    rbp
    138b:	ret
    138c:	mov    QWORD PTR [rsp],rbx
    1390:	mov    QWORD PTR [rsp+0x8],rax
    1395:	mov    QWORD PTR [rsp+0x10],r12
    139a:	mov    r14,rax
    139d:	jmp    1293 <botlish_fn_20+0x3b>
    13a2:	mov    rax,r14
    13a5:	mov    rbx,QWORD PTR [rsp+0x20]
    13aa:	mov    r12,QWORD PTR [rsp+0x28]
    13af:	mov    r13,QWORD PTR [rsp+0x30]
    13b4:	mov    r14,QWORD PTR [rsp+0x38]
    13b9:	mov    r15,QWORD PTR [rsp+0x40]
    13be:	add    rsp,0x50
    13c2:	mov    rsp,rbp
    13c5:	pop    rbp
    13c6:	ret
    13c7:	add    BYTE PTR [rsi],al
    13c9:	add    BYTE PTR [rax],al
    13cb:	add    BYTE PTR [rax],al
    13cd:	add    BYTE PTR [rax],al
	...

00000000000013d0 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    13d0:	push   rbp
    13d1:	mov    rbp,rsp
    13d4:	mov    rsi,QWORD PTR [rdx]
    13d7:	mov    r8,QWORD PTR [rdx+0x8]
    13db:	mov    rcx,QWORD PTR [rdx+0x10]
    13df:	mov    rdx,r8
    13e2:	call   13e7 <botlish_entry_20+0x17>
			13e3: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    13e7:	mov    rsp,rbp
    13ea:	pop    rbp
    13eb:	ret

00000000000013ec <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    13ec:	push   rbp
    13ed:	mov    rbp,rsp
    13f0:	sub    rsp,0x80
    13f7:	mov    QWORD PTR [rsp+0x50],rbx
    13fc:	mov    QWORD PTR [rsp+0x58],r12
    1401:	mov    QWORD PTR [rsp+0x60],r13
    1406:	mov    QWORD PTR [rsp+0x68],r14
    140b:	mov    QWORD PTR [rsp+0x70],r15
    1410:	mov    r12,rdi
    1413:	mov    rdi,QWORD PTR [rbp+0x10]
    1417:	mov    QWORD PTR [rsp],rsi
    141b:	mov    QWORD PTR [rsp+0x38],rsi
    1420:	mov    QWORD PTR [rsp+0x8],rdx
    1425:	mov    r15,rdx
    1428:	mov    QWORD PTR [rsp+0x10],rcx
    142d:	mov    rbx,rcx
    1430:	mov    QWORD PTR [rsp+0x18],r8
    1435:	mov    QWORD PTR [rsp+0x40],r8
    143a:	mov    QWORD PTR [rsp+0x20],r9
    143f:	mov    r14,r9
    1442:	mov    QWORD PTR [rsp+0x28],rdi
    1447:	mov    r13,rdi
    144a:	mov    rsi,r14
    144d:	mov    rdi,r12
    1450:	call   1455 <botlish_fn_21+0x69>
			1451: R_X86_64_PLT32	rt_hash-0x4
    1455:	test   rax,rax
    1458:	mov    rsi,rax
    145b:	je     150b <botlish_fn_21+0x11f>
    1461:	mov    rdx,QWORD PTR [rsp+0x40]
    1466:	mov    rdi,r12
    1469:	call   146e <botlish_fn_21+0x82>
			146a: R_X86_64_PLT32	rt_int_mod-0x4
    146e:	test   rax,rax
    1471:	je     150b <botlish_fn_21+0x11f>
    1477:	mov    QWORD PTR [rsp+0x30],rax
    147c:	mov    rcx,QWORD PTR [rsp+0x40]
    1481:	mov    rdx,rax
    1484:	mov    rsi,QWORD PTR [rsp+0x38]
    1489:	mov    rdi,r12
    148c:	call   1491 <botlish_fn_21+0xa5>
			148d: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1491:	test   rax,rax
    1494:	je     150b <botlish_fn_21+0x11f>
    149a:	mov    QWORD PTR [rsp+0x18],rax
    149f:	mov    QWORD PTR [rsp+0x40],rax
    14a4:	mov    rdi,r12
    14a7:	call   14ac <botlish_fn_21+0xc0>
			14a8: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    14ac:	test   rax,rax
    14af:	mov    rcx,rax
    14b2:	je     150b <botlish_fn_21+0x11f>
    14b8:	mov    rsi,QWORD PTR [rsp+0x38]
    14bd:	mov    rdx,QWORD PTR [rsp+0x40]
    14c2:	mov    rdi,r12
    14c5:	call   14ca <botlish_fn_21+0xde>
			14c6: R_X86_64_PLT32	rt_mutarray_set-0x4
    14ca:	test   rax,rax
    14cd:	je     150b <botlish_fn_21+0x11f>
    14d3:	mov    rcx,r14
    14d6:	mov    rsi,r15
    14d9:	mov    rdx,QWORD PTR [rsp+0x40]
    14de:	mov    rdi,r12
    14e1:	call   14e6 <botlish_fn_21+0xfa>
			14e2: R_X86_64_PLT32	rt_mutarray_set-0x4
    14e6:	test   rax,rax
    14e9:	je     150b <botlish_fn_21+0x11f>
    14ef:	mov    rcx,r13
    14f2:	mov    rdx,QWORD PTR [rsp+0x40]
    14f7:	mov    rsi,rbx
    14fa:	mov    rdi,r12
    14fd:	call   1502 <botlish_fn_21+0x116>
			14fe: R_X86_64_PLT32	rt_mutarray_set-0x4
    1502:	test   rax,rax
    1505:	jne    1533 <botlish_fn_21+0x147>
    150b:	xor    rax,rax
    150e:	mov    rbx,QWORD PTR [rsp+0x50]
    1513:	mov    r12,QWORD PTR [rsp+0x58]
    1518:	mov    r13,QWORD PTR [rsp+0x60]
    151d:	mov    r14,QWORD PTR [rsp+0x68]
    1522:	mov    r15,QWORD PTR [rsp+0x70]
    1527:	add    rsp,0x80
    152e:	mov    rsp,rbp
    1531:	pop    rbp
    1532:	ret
    1533:	mov    eax,0xa
    1538:	mov    rbx,QWORD PTR [rsp+0x50]
    153d:	mov    r12,QWORD PTR [rsp+0x58]
    1542:	mov    r13,QWORD PTR [rsp+0x60]
    1547:	mov    r14,QWORD PTR [rsp+0x68]
    154c:	mov    r15,QWORD PTR [rsp+0x70]
    1551:	add    rsp,0x80
    1558:	mov    rsp,rbp
    155b:	pop    rbp
    155c:	ret

000000000000155d <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    155d:	push   rbp
    155e:	mov    rbp,rsp
    1561:	sub    rsp,0x10
    1565:	mov    rsi,QWORD PTR [rdx]
    1568:	mov    r10,QWORD PTR [rdx+0x8]
    156c:	mov    rcx,QWORD PTR [rdx+0x10]
    1570:	mov    r8,QWORD PTR [rdx+0x18]
    1574:	mov    r9,QWORD PTR [rdx+0x20]
    1578:	mov    r11,QWORD PTR [rdx+0x28]
    157c:	mov    QWORD PTR [rsp],r11
    1580:	mov    rdx,r10
    1583:	call   1588 <botlish_entry_21+0x2b>
			1584: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    1588:	add    rsp,0x10
    158c:	mov    rsp,rbp
    158f:	pop    rbp
    1590:	ret
    1591:	add    BYTE PTR [rax],al
    1593:	add    BYTE PTR [rax],al
    1595:	add    BYTE PTR [rax],al
	...

0000000000001598 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1598:	push   rbp
    1599:	mov    rbp,rsp
    159c:	sub    rsp,0xd0
    15a3:	mov    QWORD PTR [rsp+0xa0],rbx
    15ab:	mov    QWORD PTR [rsp+0xa8],r12
    15b3:	mov    QWORD PTR [rsp+0xb0],r13
    15bb:	mov    QWORD PTR [rsp+0xb8],r14
    15c3:	mov    QWORD PTR [rsp+0xc0],r15
    15cb:	mov    QWORD PTR [rsp+0x68],rdi
    15d0:	mov    r15,QWORD PTR [rbp+0x10]
    15d4:	mov    r12,QWORD PTR [rbp+0x18]
    15d8:	mov    r13,QWORD PTR [rbp+0x20]
    15dc:	mov    r14,QWORD PTR [rbp+0x28]
    15e0:	mov    QWORD PTR [rsp+0x60],0x0
    15e9:	mov    QWORD PTR [rsp+0x10],rsi
    15ee:	mov    QWORD PTR [rsp+0x70],rsi
    15f3:	mov    QWORD PTR [rsp+0x18],rdx
    15f8:	mov    QWORD PTR [rsp+0x78],rdx
    15fd:	mov    QWORD PTR [rsp+0x20],rcx
    1602:	mov    QWORD PTR [rsp+0x80],rcx
    160a:	mov    QWORD PTR [rsp+0x28],r8
    160f:	mov    QWORD PTR [rsp+0x30],r9
    1614:	mov    QWORD PTR [rsp+0x38],r15
    1619:	mov    QWORD PTR [rsp+0x40],r12
    161e:	mov    QWORD PTR [rsp+0x48],r13
    1623:	mov    QWORD PTR [rsp+0x50],r14
    1628:	mov    rbx,r9
    162b:	mov    rsi,r8
    162e:	mov    rax,rsi
    1631:	and    rax,rbx
    1634:	mov    QWORD PTR [rsp+0x88],rsi
    163c:	test   rax,0x1
    1642:	jne    1672 <botlish_fn_22+0xda>
    1648:	mov    rdx,rbx
    164b:	mov    rsi,QWORD PTR [rsp+0x88]
    1653:	mov    rdi,QWORD PTR [rsp+0x68]
    1658:	call   165d <botlish_fn_22+0xc5>
			1659: R_X86_64_PLT32	rt_int_cmp-0x4
    165d:	mov    ecx,0x2
    1662:	test   rax,rax
    1665:	cmovge rcx,QWORD PTR [rip+0x373]        # 19e0 <botlish_fn_22+0x448>
    166d:	jmp    168a <botlish_fn_22+0xf2>
    1672:	mov    ecx,0x2
    1677:	mov    rsi,QWORD PTR [rsp+0x88]
    167f:	cmp    rsi,rbx
    1682:	cmovge rcx,QWORD PTR [rip+0x356]        # 19e0 <botlish_fn_22+0x448>
    168a:	cmp    rcx,0x6
    168e:	je     19a1 <botlish_fn_22+0x409>
    1694:	xor    eax,eax
    1696:	mov    rsi,QWORD PTR [rsp+0x70]
    169b:	test   rsi,0x7
    16a2:	jne    16b1 <botlish_fn_22+0x119>
    16a8:	movzx  rax,BYTE PTR [rsi]
    16ac:	cmp    al,0x8
    16ae:	sete   al
    16b1:	test   al,al
    16b3:	jne    16d5 <botlish_fn_22+0x13d>
    16b9:	mov    rdi,QWORD PTR [rsp+0x68]
    16be:	mov    rax,QWORD PTR [rdi+0x10]
    16c2:	mov    rcx,QWORD PTR [rax+0x8]
    16c6:	mov    edx,0x8
    16cb:	call   16d0 <botlish_fn_22+0x138>
			16cc: R_X86_64_PLT32	rt_type_error-0x4
    16d0:	jmp    18b0 <botlish_fn_22+0x318>
    16d5:	mov    QWORD PTR [rsp+0x70],rsi
    16da:	mov    rdx,QWORD PTR [rsp+0x88]
    16e2:	mov    rdi,QWORD PTR [rsp+0x68]
    16e7:	call   16ec <botlish_fn_22+0x154>
			16e8: R_X86_64_PLT32	rt_mutarray_get-0x4
    16ec:	test   rax,rax
    16ef:	je     18b0 <botlish_fn_22+0x318>
    16f5:	mov    QWORD PTR [rsp+0x58],rax
    16fa:	mov    QWORD PTR [rsp+0x90],rax
    1702:	mov    rdi,QWORD PTR [rsp+0x68]
    1707:	call   170c <botlish_fn_22+0x174>
			1708: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    170c:	test   rax,rax
    170f:	je     18b0 <botlish_fn_22+0x318>
    1715:	mov    rcx,QWORD PTR [rsp+0x90]
    171d:	mov    rdx,rcx
    1720:	and    rdx,rax
    1723:	test   rdx,0x1
    172a:	jne    1753 <botlish_fn_22+0x1bb>
    1730:	mov    rdx,rax
    1733:	mov    rsi,QWORD PTR [rsp+0x90]
    173b:	mov    rdi,QWORD PTR [rsp+0x68]
    1740:	call   1745 <botlish_fn_22+0x1ad>
			1741: R_X86_64_PLT32	rt_value_eq-0x4
    1745:	test   rax,rax
    1748:	je     18b0 <botlish_fn_22+0x318>
    174e:	jmp    176e <botlish_fn_22+0x1d6>
    1753:	mov    rdx,rax
    1756:	mov    rsi,QWORD PTR [rsp+0x90]
    175e:	mov    eax,0x2
    1763:	cmp    rsi,rdx
    1766:	cmove  rax,QWORD PTR [rip+0x272]        # 19e0 <botlish_fn_22+0x448>
    176e:	cmp    rax,0x6
    1772:	jne    18e7 <botlish_fn_22+0x34f>
    1778:	xor    eax,eax
    177a:	mov    rdx,QWORD PTR [rsp+0x78]
    177f:	test   rdx,0x7
    1786:	je     1796 <botlish_fn_22+0x1fe>
    178c:	mov    QWORD PTR [rsp+0x78],rdx
    1791:	jmp    17a4 <botlish_fn_22+0x20c>
    1796:	movzx  rax,BYTE PTR [rdx]
    179a:	mov    QWORD PTR [rsp+0x78],rdx
    179f:	cmp    al,0x8
    17a1:	sete   al
    17a4:	test   al,al
    17a6:	jne    17cd <botlish_fn_22+0x235>
    17ac:	mov    rdi,QWORD PTR [rsp+0x68]
    17b1:	mov    rax,QWORD PTR [rdi+0x10]
    17b5:	mov    rcx,QWORD PTR [rax+0x8]
    17b9:	mov    edx,0x8
    17be:	mov    rsi,QWORD PTR [rsp+0x78]
    17c3:	call   17c8 <botlish_fn_22+0x230>
			17c4: R_X86_64_PLT32	rt_type_error-0x4
    17c8:	jmp    18b0 <botlish_fn_22+0x318>
    17cd:	mov    rdx,QWORD PTR [rsp+0x88]
    17d5:	mov    rsi,QWORD PTR [rsp+0x78]
    17da:	mov    rdi,QWORD PTR [rsp+0x68]
    17df:	call   17e4 <botlish_fn_22+0x24c>
			17e0: R_X86_64_PLT32	rt_mutarray_get-0x4
    17e4:	test   rax,rax
    17e7:	je     18b0 <botlish_fn_22+0x318>
    17ed:	mov    QWORD PTR [rsp+0x58],rax
    17f2:	mov    QWORD PTR [rsp+0x90],rax
    17fa:	xor    eax,eax
    17fc:	mov    rcx,QWORD PTR [rsp+0x80]
    1804:	test   rcx,0x7
    180b:	je     181e <botlish_fn_22+0x286>
    1811:	mov    QWORD PTR [rsp+0x80],rcx
    1819:	jmp    1831 <botlish_fn_22+0x299>
    181e:	movzx  rdx,BYTE PTR [rcx]
    1822:	mov    QWORD PTR [rsp+0x80],rcx
    182a:	rex cmp dl,0x8
    182e:	sete   al
    1831:	test   al,al
    1833:	jne    185d <botlish_fn_22+0x2c5>
    1839:	mov    rdi,QWORD PTR [rsp+0x68]
    183e:	mov    rsi,QWORD PTR [rdi+0x10]
    1842:	mov    rcx,QWORD PTR [rsi+0x8]
    1846:	mov    edx,0x8
    184b:	mov    rsi,QWORD PTR [rsp+0x80]
    1853:	call   1858 <botlish_fn_22+0x2c0>
			1854: R_X86_64_PLT32	rt_type_error-0x4
    1858:	jmp    18b0 <botlish_fn_22+0x318>
    185d:	mov    rdx,QWORD PTR [rsp+0x88]
    1865:	mov    rsi,QWORD PTR [rsp+0x80]
    186d:	mov    rdi,QWORD PTR [rsp+0x68]
    1872:	call   1877 <botlish_fn_22+0x2df>
			1873: R_X86_64_PLT32	rt_mutarray_get-0x4
    1877:	test   rax,rax
    187a:	je     18b0 <botlish_fn_22+0x318>
    1880:	mov    QWORD PTR [rsp+0x60],rax
    1885:	mov    QWORD PTR [rsp],rax
    1889:	mov    r9,QWORD PTR [rsp+0x90]
    1891:	mov    rcx,r13
    1894:	mov    rdx,r12
    1897:	mov    rsi,r15
    189a:	mov    rdi,QWORD PTR [rsp+0x68]
    189f:	mov    r8,r14
    18a2:	call   18a7 <botlish_fn_22+0x30f>
			18a3: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    18a7:	test   rax,rax
    18aa:	jne    18e7 <botlish_fn_22+0x34f>
    18b0:	xor    rax,rax
    18b3:	mov    rbx,QWORD PTR [rsp+0xa0]
    18bb:	mov    r12,QWORD PTR [rsp+0xa8]
    18c3:	mov    r13,QWORD PTR [rsp+0xb0]
    18cb:	mov    r14,QWORD PTR [rsp+0xb8]
    18d3:	mov    r15,QWORD PTR [rsp+0xc0]
    18db:	add    rsp,0xd0
    18e2:	mov    rsp,rbp
    18e5:	pop    rbp
    18e6:	ret
    18e7:	mov    QWORD PTR [rsp+0x58],0x3
    18f0:	mov    rsi,QWORD PTR [rsp+0x88]
    18f8:	test   rsi,0x1
    18ff:	je     1931 <botlish_fn_22+0x399>
    1905:	mov    rsi,QWORD PTR [rsp+0x88]
    190d:	mov    rax,rsi
    1910:	add    rax,0x2
    1914:	seto   cl
    1917:	test   cl,cl
    1919:	jne    1931 <botlish_fn_22+0x399>
    191f:	mov    rsi,QWORD PTR [rsp+0x70]
    1924:	mov    QWORD PTR [rsp+0x88],rax
    192c:	jmp    1955 <botlish_fn_22+0x3bd>
    1931:	mov    edx,0x3
    1936:	mov    rsi,QWORD PTR [rsp+0x88]
    193e:	mov    rdi,QWORD PTR [rsp+0x68]
    1943:	call   1948 <botlish_fn_22+0x3b0>
			1944: R_X86_64_PLT32	rt_int_add-0x4
    1948:	mov    rsi,QWORD PTR [rsp+0x70]
    194d:	mov    QWORD PTR [rsp+0x88],rax
    1955:	mov    rsi,QWORD PTR [rsp+0x70]
    195a:	mov    QWORD PTR [rsp+0x10],rsi
    195f:	mov    rsi,QWORD PTR [rsp+0x78]
    1964:	mov    QWORD PTR [rsp+0x18],rsi
    1969:	mov    rsi,QWORD PTR [rsp+0x80]
    1971:	mov    QWORD PTR [rsp+0x20],rsi
    1976:	mov    rsi,QWORD PTR [rsp+0x88]
    197e:	mov    QWORD PTR [rsp+0x28],rsi
    1983:	mov    QWORD PTR [rsp+0x30],rbx
    1988:	mov    QWORD PTR [rsp+0x38],r15
    198d:	mov    QWORD PTR [rsp+0x40],r12
    1992:	mov    QWORD PTR [rsp+0x48],r13
    1997:	mov    QWORD PTR [rsp+0x50],r14
    199c:	jmp    162e <botlish_fn_22+0x96>
    19a1:	mov    eax,0xa
    19a6:	mov    rbx,QWORD PTR [rsp+0xa0]
    19ae:	mov    r12,QWORD PTR [rsp+0xa8]
    19b6:	mov    r13,QWORD PTR [rsp+0xb0]
    19be:	mov    r14,QWORD PTR [rsp+0xb8]
    19c6:	mov    r15,QWORD PTR [rsp+0xc0]
    19ce:	add    rsp,0xd0
    19d5:	mov    rsp,rbp
    19d8:	pop    rbp
    19d9:	ret
    19da:	add    BYTE PTR [rax],al
    19dc:	add    BYTE PTR [rax],al
    19de:	add    BYTE PTR [rax],al
    19e0:	(bad)
    19e1:	add    BYTE PTR [rax],al
    19e3:	add    BYTE PTR [rax],al
    19e5:	add    BYTE PTR [rax],al
	...

00000000000019e8 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    19e8:	push   rbp
    19e9:	mov    rbp,rsp
    19ec:	sub    rsp,0x30
    19f0:	mov    QWORD PTR [rsp+0x20],r12
    19f5:	mov    rsi,QWORD PTR [rdx]
    19f8:	mov    rax,QWORD PTR [rdx+0x8]
    19fc:	mov    rcx,QWORD PTR [rdx+0x10]
    1a00:	mov    r8,QWORD PTR [rdx+0x18]
    1a04:	mov    r9,QWORD PTR [rdx+0x20]
    1a08:	mov    r10,QWORD PTR [rdx+0x28]
    1a0c:	mov    r11,QWORD PTR [rdx+0x30]
    1a10:	mov    r12,QWORD PTR [rdx+0x38]
    1a14:	mov    rdx,QWORD PTR [rdx+0x40]
    1a18:	mov    QWORD PTR [rsp],r10
    1a1c:	mov    QWORD PTR [rsp+0x8],r11
    1a21:	mov    QWORD PTR [rsp+0x10],r12
    1a26:	mov    QWORD PTR [rsp+0x18],rdx
    1a2b:	mov    rdx,rax
    1a2e:	call   1a33 <botlish_entry_22+0x4b>
			1a2f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    1a33:	mov    r12,QWORD PTR [rsp+0x20]
    1a38:	add    rsp,0x30
    1a3c:	mov    rsp,rbp
    1a3f:	pop    rbp
    1a40:	ret

0000000000001a41 <botlish_fn_23: ht_rehash<mutarray, int>>:
    1a41:	push   rbp
    1a42:	mov    rbp,rsp
    1a45:	sub    rsp,0xd0
    1a4c:	mov    QWORD PTR [rsp+0xa0],rbx
    1a54:	mov    QWORD PTR [rsp+0xa8],r12
    1a5c:	mov    QWORD PTR [rsp+0xb0],r13
    1a64:	mov    QWORD PTR [rsp+0xb8],r14
    1a6c:	mov    QWORD PTR [rsp+0xc0],r15
    1a74:	mov    r13,rdi
    1a77:	mov    QWORD PTR [rsp+0x30],0x0
    1a80:	mov    QWORD PTR [rsp+0x38],0x0
    1a89:	mov    QWORD PTR [rsp+0x40],0x0
    1a92:	mov    QWORD PTR [rsp+0x48],0x0
    1a9b:	mov    QWORD PTR [rsp+0x50],0x0
    1aa4:	mov    QWORD PTR [rsp+0x58],0x0
    1aad:	mov    QWORD PTR [rsp+0x60],0x0
    1ab6:	mov    QWORD PTR [rsp+0x68],0x0
    1abf:	mov    QWORD PTR [rsp+0x20],rsi
    1ac4:	mov    r12,rsi
    1ac7:	mov    QWORD PTR [rsp+0x28],rdx
    1acc:	mov    rbx,rdx
    1acf:	mov    rsi,r12
    1ad2:	mov    rdi,r13
    1ad5:	call   1ada <botlish_fn_23+0x99>
			1ad6: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    1ada:	test   rax,rax
    1add:	je     1cac <botlish_fn_23+0x26b>
    1ae3:	mov    QWORD PTR [rsp+0x30],rax
    1ae8:	mov    r14,rax
    1aeb:	mov    rsi,r12
    1aee:	mov    rdi,r13
    1af1:	call   1af6 <botlish_fn_23+0xb5>
			1af2: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    1af6:	test   rax,rax
    1af9:	je     1cac <botlish_fn_23+0x26b>
    1aff:	mov    QWORD PTR [rsp+0x38],rax
    1b04:	mov    r15,rax
    1b07:	mov    rsi,r12
    1b0a:	mov    rdi,r13
    1b0d:	call   1b12 <botlish_fn_23+0xd1>
			1b0e: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    1b12:	test   rax,rax
    1b15:	je     1cac <botlish_fn_23+0x26b>
    1b1b:	mov    QWORD PTR [rsp+0x40],rax
    1b20:	mov    QWORD PTR [rsp+0x90],rax
    1b28:	mov    rsi,r12
    1b2b:	mov    rdi,r13
    1b2e:	call   1b33 <botlish_fn_23+0xf2>
			1b2f: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    1b33:	test   rax,rax
    1b36:	je     1cac <botlish_fn_23+0x26b>
    1b3c:	mov    QWORD PTR [rsp+0x48],rax
    1b41:	mov    QWORD PTR [rsp+0x88],rax
    1b49:	mov    rsi,rbx
    1b4c:	mov    rdi,r13
    1b4f:	call   1b54 <botlish_fn_23+0x113>
			1b50: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b54:	mov    rcx,rax
    1b57:	mov    QWORD PTR [rsp+0x80],rax
    1b5f:	test   rax,rcx
    1b62:	je     1cac <botlish_fn_23+0x26b>
    1b68:	mov    rax,QWORD PTR [rsp+0x80]
    1b70:	mov    QWORD PTR [rsp+0x50],rax
    1b75:	mov    edx,0x1
    1b7a:	mov    QWORD PTR [rsp+0x58],0x1
    1b83:	mov    rcx,rbx
    1b86:	mov    rsi,QWORD PTR [rsp+0x80]
    1b8e:	mov    rdi,r13
    1b91:	call   1b96 <botlish_fn_23+0x155>
			1b92: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    1b96:	test   rax,rax
    1b99:	je     1cac <botlish_fn_23+0x26b>
    1b9f:	mov    rsi,rbx
    1ba2:	mov    rdi,r13
    1ba5:	call   1baa <botlish_fn_23+0x169>
			1ba6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1baa:	test   rax,rax
    1bad:	je     1cac <botlish_fn_23+0x26b>
    1bb3:	mov    QWORD PTR [rsp+0x58],rax
    1bb8:	mov    QWORD PTR [rsp+0x78],rax
    1bbd:	mov    rsi,rbx
    1bc0:	mov    rdi,r13
    1bc3:	call   1bc8 <botlish_fn_23+0x187>
			1bc4: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1bc8:	test   rax,rax
    1bcb:	je     1cac <botlish_fn_23+0x26b>
    1bd1:	mov    QWORD PTR [rsp+0x60],rax
    1bd6:	mov    r8d,0x1
    1bdc:	mov    QWORD PTR [rsp+0x68],0x1
    1be5:	mov    rcx,QWORD PTR [rsp+0x80]
    1bed:	mov    QWORD PTR [rsp],rcx
    1bf1:	mov    rcx,QWORD PTR [rsp+0x78]
    1bf6:	mov    QWORD PTR [rsp+0x8],rcx
    1bfb:	mov    QWORD PTR [rsp+0x10],rax
    1c00:	mov    QWORD PTR [rsp+0x70],rax
    1c05:	mov    QWORD PTR [rsp+0x18],rbx
    1c0a:	mov    rcx,QWORD PTR [rsp+0x90]
    1c12:	mov    rdx,r15
    1c15:	mov    rsi,r14
    1c18:	mov    r9,QWORD PTR [rsp+0x88]
    1c20:	mov    rdi,r13
    1c23:	call   1c28 <botlish_fn_23+0x1e7>
			1c24: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    1c28:	test   rax,rax
    1c2b:	je     1cac <botlish_fn_23+0x26b>
    1c31:	mov    edx,0x1
    1c36:	mov    rcx,QWORD PTR [rsp+0x80]
    1c3e:	mov    rsi,r12
    1c41:	mov    rdi,r13
    1c44:	call   1c49 <botlish_fn_23+0x208>
			1c45: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c49:	test   rax,rax
    1c4c:	je     1cac <botlish_fn_23+0x26b>
    1c52:	mov    edx,0x3
    1c57:	mov    rcx,QWORD PTR [rsp+0x78]
    1c5c:	mov    rsi,r12
    1c5f:	mov    rdi,r13
    1c62:	call   1c67 <botlish_fn_23+0x226>
			1c63: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c67:	test   rax,rax
    1c6a:	je     1cac <botlish_fn_23+0x26b>
    1c70:	mov    edx,0x5
    1c75:	mov    rcx,QWORD PTR [rsp+0x70]
    1c7a:	mov    rsi,r12
    1c7d:	mov    rdi,r13
    1c80:	call   1c85 <botlish_fn_23+0x244>
			1c81: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c85:	test   rax,rax
    1c88:	je     1cac <botlish_fn_23+0x26b>
    1c8e:	mov    edx,0x9
    1c93:	mov    ecx,0x1
    1c98:	mov    rsi,r12
    1c9b:	mov    rdi,r13
    1c9e:	call   1ca3 <botlish_fn_23+0x262>
			1c9f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ca3:	test   rax,rax
    1ca6:	jne    1ce3 <botlish_fn_23+0x2a2>
    1cac:	xor    rax,rax
    1caf:	mov    rbx,QWORD PTR [rsp+0xa0]
    1cb7:	mov    r12,QWORD PTR [rsp+0xa8]
    1cbf:	mov    r13,QWORD PTR [rsp+0xb0]
    1cc7:	mov    r14,QWORD PTR [rsp+0xb8]
    1ccf:	mov    r15,QWORD PTR [rsp+0xc0]
    1cd7:	add    rsp,0xd0
    1cde:	mov    rsp,rbp
    1ce1:	pop    rbp
    1ce2:	ret
    1ce3:	mov    eax,0xa
    1ce8:	mov    rbx,QWORD PTR [rsp+0xa0]
    1cf0:	mov    r12,QWORD PTR [rsp+0xa8]
    1cf8:	mov    r13,QWORD PTR [rsp+0xb0]
    1d00:	mov    r14,QWORD PTR [rsp+0xb8]
    1d08:	mov    r15,QWORD PTR [rsp+0xc0]
    1d10:	add    rsp,0xd0
    1d17:	mov    rsp,rbp
    1d1a:	pop    rbp
    1d1b:	ret

0000000000001d1c <botlish_entry_23: ht_rehash<mutarray, int>>:
    1d1c:	push   rbp
    1d1d:	mov    rbp,rsp
    1d20:	mov    rsi,QWORD PTR [rdx]
    1d23:	mov    rdx,QWORD PTR [rdx+0x8]
    1d27:	call   1d2c <botlish_entry_23+0x10>
			1d28: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    1d2c:	mov    rsp,rbp
    1d2f:	pop    rbp
    1d30:	ret
    1d31:	add    BYTE PTR [rax],al
    1d33:	add    BYTE PTR [rax],al
    1d35:	add    BYTE PTR [rax],al
	...

0000000000001d38 <botlish_fn_24: ht_should_grow<mutarray>>:
    1d38:	push   rbp
    1d39:	mov    rbp,rsp
    1d3c:	sub    rsp,0x40
    1d40:	mov    QWORD PTR [rsp+0x20],rbx
    1d45:	mov    QWORD PTR [rsp+0x28],r12
    1d4a:	mov    QWORD PTR [rsp+0x30],r13
    1d4f:	mov    rbx,rdi
    1d52:	mov    QWORD PTR [rsp+0x8],0x0
    1d5b:	mov    QWORD PTR [rsp+0x10],0x0
    1d64:	mov    QWORD PTR [rsp],rsi
    1d68:	mov    r12,rsi
    1d6b:	mov    rsi,r12
    1d6e:	mov    rdi,rbx
    1d71:	call   1d76 <botlish_fn_24+0x3e>
			1d72: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    1d76:	mov    rcx,rax
    1d79:	mov    r13,rax
    1d7c:	test   rax,rcx
    1d7f:	je     1f6f <botlish_fn_24+0x237>
    1d85:	mov    rax,r13
    1d88:	mov    QWORD PTR [rsp+0x8],rax
    1d8d:	mov    rsi,r12
    1d90:	mov    rdi,rbx
    1d93:	call   1d98 <botlish_fn_24+0x60>
			1d94: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    1d98:	mov    rcx,rax
    1d9b:	test   rcx,rcx
    1d9e:	je     1f6f <botlish_fn_24+0x237>
    1da4:	mov    QWORD PTR [rsp+0x10],rcx
    1da9:	mov    edx,0x1
    1dae:	mov    rax,r13
    1db1:	test   rax,0x1
    1db7:	jne    1dda <botlish_fn_24+0xa2>
    1dbd:	xor    edx,edx
    1dbf:	mov    rax,r13
    1dc2:	test   rax,0x7
    1dc8:	jne    1dda <botlish_fn_24+0xa2>
    1dce:	mov    rax,r13
    1dd1:	movzx  rax,BYTE PTR [rax]
    1dd5:	cmp    al,0x1
    1dd7:	sete   dl
    1dda:	test   dl,dl
    1ddc:	jne    1dfd <botlish_fn_24+0xc5>
    1de2:	mov    rdi,rbx
    1de5:	mov    rax,QWORD PTR [rdi+0x10]
    1de9:	mov    rcx,QWORD PTR [rax+0x10]
    1ded:	xor    rdx,rdx
    1df0:	mov    rsi,r13
    1df3:	call   1df8 <botlish_fn_24+0xc0>
			1df4: R_X86_64_PLT32	rt_type_error-0x4
    1df8:	jmp    1f6f <botlish_fn_24+0x237>
    1dfd:	mov    eax,0x1
    1e02:	test   rcx,0x1
    1e09:	je     1e17 <botlish_fn_24+0xdf>
    1e0f:	mov    r8,rcx
    1e12:	jmp    1e3a <botlish_fn_24+0x102>
    1e17:	xor    eax,eax
    1e19:	test   rcx,0x7
    1e20:	je     1e2e <botlish_fn_24+0xf6>
    1e26:	mov    r8,rcx
    1e29:	jmp    1e3a <botlish_fn_24+0x102>
    1e2e:	movzx  rax,BYTE PTR [rcx]
    1e32:	mov    r8,rcx
    1e35:	cmp    al,0x1
    1e37:	sete   al
    1e3a:	test   al,al
    1e3c:	jne    1e5d <botlish_fn_24+0x125>
    1e42:	mov    rdi,rbx
    1e45:	mov    rax,QWORD PTR [rdi+0x10]
    1e49:	mov    rcx,QWORD PTR [rax+0x10]
    1e4d:	xor    rdx,rdx
    1e50:	mov    rsi,r8
    1e53:	call   1e58 <botlish_fn_24+0x120>
			1e54: R_X86_64_PLT32	rt_type_error-0x4
    1e58:	jmp    1f6f <botlish_fn_24+0x237>
    1e5d:	mov    rcx,r8
    1e60:	mov    rsi,r13
    1e63:	mov    rax,rsi
    1e66:	and    rax,rcx
    1e69:	test   rax,0x1
    1e6f:	jne    1e80 <botlish_fn_24+0x148>
    1e75:	mov    rdx,r8
    1e78:	mov    rsi,r13
    1e7b:	jmp    1e9e <botlish_fn_24+0x166>
    1e80:	mov    rcx,r8
    1e83:	lea    rax,[rcx-0x1]
    1e87:	mov    rsi,r13
    1e8a:	add    rsi,rax
    1e8d:	seto   al
    1e90:	test   al,al
    1e92:	je     1ea9 <botlish_fn_24+0x171>
    1e98:	mov    rdx,r8
    1e9b:	mov    rsi,r13
    1e9e:	mov    rdi,rbx
    1ea1:	call   1ea6 <botlish_fn_24+0x16e>
			1ea2: R_X86_64_PLT32	rt_int_add-0x4
    1ea6:	mov    rsi,rax
    1ea9:	mov    QWORD PTR [rsp+0x8],rsi
    1eae:	mov    QWORD PTR [rsp+0x10],0x3
    1eb7:	test   rsi,0x1
    1ebe:	je     1ee1 <botlish_fn_24+0x1a9>
    1ec4:	mov    rax,rsi
    1ec7:	add    rax,0x2
    1ecb:	mov    rcx,rax
    1ece:	seto   al
    1ed1:	test   al,al
    1ed3:	jne    1ee1 <botlish_fn_24+0x1a9>
    1ed9:	mov    rsi,rcx
    1edc:	jmp    1ef1 <botlish_fn_24+0x1b9>
    1ee1:	mov    edx,0x3
    1ee6:	mov    rdi,rbx
    1ee9:	call   1eee <botlish_fn_24+0x1b6>
			1eea: R_X86_64_PLT32	rt_int_add-0x4
    1eee:	mov    rsi,rax
    1ef1:	mov    QWORD PTR [rsp+0x8],rsi
    1ef6:	mov    edx,0x7
    1efb:	mov    rdi,rdx
    1efe:	mov    QWORD PTR [rsp+0x10],0x7
    1f07:	test   rsi,0x1
    1f0e:	jne    1f1c <botlish_fn_24+0x1e4>
    1f14:	mov    rdx,rdi
    1f17:	jmp    1f48 <botlish_fn_24+0x210>
    1f1c:	mov    rax,rsi
    1f1f:	sar    rax,1
    1f22:	imul   QWORD PTR [rip+0x117]        # 2040 <botlish_fn_24+0x308>
    1f29:	seto   cl
    1f2c:	or     rax,0x1
    1f30:	test   cl,cl
    1f32:	je     1f40 <botlish_fn_24+0x208>
    1f38:	mov    rdx,rdi
    1f3b:	jmp    1f48 <botlish_fn_24+0x210>
    1f40:	mov    rsi,rax
    1f43:	jmp    1f53 <botlish_fn_24+0x21b>
    1f48:	mov    rdi,rbx
    1f4b:	call   1f50 <botlish_fn_24+0x218>
			1f4c: R_X86_64_PLT32	rt_int_mul-0x4
    1f50:	mov    rsi,rax
    1f53:	mov    QWORD PTR [rsp+0x8],rsi
    1f58:	mov    r13,rsi
    1f5b:	mov    rsi,r12
    1f5e:	mov    rdi,rbx
    1f61:	call   1f66 <botlish_fn_24+0x22e>
			1f62: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    1f66:	test   rax,rax
    1f69:	jne    1f8a <botlish_fn_24+0x252>
    1f6f:	xor    rax,rax
    1f72:	mov    rbx,QWORD PTR [rsp+0x20]
    1f77:	mov    r12,QWORD PTR [rsp+0x28]
    1f7c:	mov    r13,QWORD PTR [rsp+0x30]
    1f81:	add    rsp,0x40
    1f85:	mov    rsp,rbp
    1f88:	pop    rbp
    1f89:	ret
    1f8a:	mov    QWORD PTR [rsp],rax
    1f8e:	mov    QWORD PTR [rsp+0x10],0x5
    1f97:	test   rax,0x1
    1f9d:	mov    rsi,rax
    1fa0:	je     1fd2 <botlish_fn_24+0x29a>
    1fa6:	mov    rcx,rsi
    1fa9:	mov    rax,rcx
    1fac:	sar    rax,1
    1faf:	imul   QWORD PTR [rip+0x92]        # 2048 <botlish_fn_24+0x310>
    1fb6:	seto   r9b
    1fba:	or     rax,0x1
    1fbe:	test   r9b,r9b
    1fc1:	jne    1fd2 <botlish_fn_24+0x29a>
    1fc7:	mov    rdx,rax
    1fca:	mov    rsi,r13
    1fcd:	jmp    1fe5 <botlish_fn_24+0x2ad>
    1fd2:	mov    edx,0x5
    1fd7:	mov    rdi,rbx
    1fda:	call   1fdf <botlish_fn_24+0x2a7>
			1fdb: R_X86_64_PLT32	rt_int_mul-0x4
    1fdf:	mov    rdx,rax
    1fe2:	mov    rsi,r13
    1fe5:	mov    rax,rsi
    1fe8:	and    rax,rdx
    1feb:	test   rax,0x1
    1ff1:	jne    2018 <botlish_fn_24+0x2e0>
    1ff7:	mov    rdi,rbx
    1ffa:	call   1fff <botlish_fn_24+0x2c7>
			1ffb: R_X86_64_PLT32	rt_int_cmp-0x4
    1fff:	mov    r10d,0x2
    2005:	test   rax,rax
    2008:	mov    rax,r10
    200b:	cmovg  rax,QWORD PTR [rip+0x2d]        # 2040 <botlish_fn_24+0x308>
    2013:	jmp    2028 <botlish_fn_24+0x2f0>
    2018:	mov    eax,0x2
    201d:	cmp    rsi,rdx
    2020:	cmovg  rax,QWORD PTR [rip+0x18]        # 2040 <botlish_fn_24+0x308>
    2028:	mov    rbx,QWORD PTR [rsp+0x20]
    202d:	mov    r12,QWORD PTR [rsp+0x28]
    2032:	mov    r13,QWORD PTR [rsp+0x30]
    2037:	add    rsp,0x40
    203b:	mov    rsp,rbp
    203e:	pop    rbp
    203f:	ret
    2040:	(bad)
    2041:	add    BYTE PTR [rax],al
    2043:	add    BYTE PTR [rax],al
    2045:	add    BYTE PTR [rax],al
    2047:	add    BYTE PTR [rax+rax*1],al
    204a:	add    BYTE PTR [rax],al
    204c:	add    BYTE PTR [rax],al
	...

0000000000002050 <botlish_entry_24: ht_should_grow<mutarray>>:
    2050:	push   rbp
    2051:	mov    rbp,rsp
    2054:	mov    rsi,QWORD PTR [rdx]
    2057:	call   205c <botlish_entry_24+0xc>
			2058: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    205c:	mov    rsp,rbp
    205f:	pop    rbp
    2060:	ret
    2061:	add    BYTE PTR [rax],al
    2063:	add    BYTE PTR [rax],al
    2065:	add    BYTE PTR [rax],al
	...

0000000000002068 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    2068:	push   rbp
    2069:	mov    rbp,rsp
    206c:	sub    rsp,0x40
    2070:	mov    QWORD PTR [rsp+0x20],rbx
    2075:	mov    QWORD PTR [rsp+0x28],r12
    207a:	mov    QWORD PTR [rsp+0x30],r13
    207f:	mov    rbx,rdi
    2082:	mov    QWORD PTR [rsp+0x8],0x0
    208b:	mov    QWORD PTR [rsp+0x10],0x0
    2094:	mov    QWORD PTR [rsp],rsi
    2098:	mov    r12,rsi
    209b:	mov    rsi,r12
    209e:	mov    rdi,rbx
    20a1:	call   20a6 <botlish_fn_25+0x3e>
			20a2: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    20a6:	test   rax,rax
    20a9:	je     229c <botlish_fn_25+0x234>
    20af:	mov    QWORD PTR [rsp+0x8],rax
    20b4:	mov    r13,rax
    20b7:	mov    rsi,r12
    20ba:	mov    rdi,rbx
    20bd:	call   20c2 <botlish_fn_25+0x5a>
			20be: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    20c2:	mov    rcx,rax
    20c5:	test   rcx,rcx
    20c8:	je     229c <botlish_fn_25+0x234>
    20ce:	mov    edx,0x1
    20d3:	mov    rax,r13
    20d6:	test   rax,0x1
    20dc:	je     20ea <botlish_fn_25+0x82>
    20e2:	mov    r13,rax
    20e5:	jmp    210e <botlish_fn_25+0xa6>
    20ea:	xor    edx,edx
    20ec:	test   rax,0x7
    20f2:	je     2100 <botlish_fn_25+0x98>
    20f8:	mov    r13,rax
    20fb:	jmp    210e <botlish_fn_25+0xa6>
    2100:	movzx  rdx,BYTE PTR [rax]
    2104:	mov    r13,rax
    2107:	rex cmp dl,0x1
    210b:	sete   dl
    210e:	test   dl,dl
    2110:	jne    2131 <botlish_fn_25+0xc9>
    2116:	mov    rdi,rbx
    2119:	mov    rsi,QWORD PTR [rdi+0x10]
    211d:	mov    rcx,QWORD PTR [rsi+0x18]
    2121:	xor    rdx,rdx
    2124:	mov    rsi,r13
    2127:	call   212c <botlish_fn_25+0xc4>
			2128: R_X86_64_PLT32	rt_type_error-0x4
    212c:	jmp    229c <botlish_fn_25+0x234>
    2131:	mov    rsi,r13
    2134:	mov    eax,0x1
    2139:	test   rcx,0x1
    2140:	je     214e <botlish_fn_25+0xe6>
    2146:	mov    r8,rcx
    2149:	jmp    2171 <botlish_fn_25+0x109>
    214e:	xor    eax,eax
    2150:	test   rcx,0x7
    2157:	je     2165 <botlish_fn_25+0xfd>
    215d:	mov    r8,rcx
    2160:	jmp    2171 <botlish_fn_25+0x109>
    2165:	movzx  rax,BYTE PTR [rcx]
    2169:	mov    r8,rcx
    216c:	cmp    al,0x1
    216e:	sete   al
    2171:	test   al,al
    2173:	jne    2194 <botlish_fn_25+0x12c>
    2179:	mov    rdi,rbx
    217c:	mov    rax,QWORD PTR [rdi+0x10]
    2180:	mov    rcx,QWORD PTR [rax+0x18]
    2184:	xor    rdx,rdx
    2187:	mov    rsi,r8
    218a:	call   218f <botlish_fn_25+0x127>
			218b: R_X86_64_PLT32	rt_type_error-0x4
    218f:	jmp    229c <botlish_fn_25+0x234>
    2194:	mov    rcx,r8
    2197:	mov    rax,rsi
    219a:	and    rax,rcx
    219d:	test   rax,0x1
    21a3:	jne    21c9 <botlish_fn_25+0x161>
    21a9:	mov    rdx,r8
    21ac:	mov    rdi,rbx
    21af:	call   21b4 <botlish_fn_25+0x14c>
			21b0: R_X86_64_PLT32	rt_int_cmp-0x4
    21b4:	mov    ecx,0x2
    21b9:	test   rax,rax
    21bc:	cmovg  rcx,QWORD PTR [rip+0x10c]        # 22d0 <botlish_fn_25+0x268>
    21c4:	jmp    21dc <botlish_fn_25+0x174>
    21c9:	mov    ecx,0x2
    21ce:	mov    r11,r8
    21d1:	cmp    rsi,r11
    21d4:	cmovg  rcx,QWORD PTR [rip+0xf4]        # 22d0 <botlish_fn_25+0x268>
    21dc:	cmp    rcx,0x6
    21e0:	je     226c <botlish_fn_25+0x204>
    21e6:	mov    rsi,r12
    21e9:	mov    rdi,rbx
    21ec:	call   21f1 <botlish_fn_25+0x189>
			21ed: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    21f1:	test   rax,rax
    21f4:	je     229c <botlish_fn_25+0x234>
    21fa:	mov    QWORD PTR [rsp+0x8],rax
    21ff:	mov    QWORD PTR [rsp+0x10],0x5
    2208:	test   rax,0x1
    220e:	mov    rsi,rax
    2211:	je     223e <botlish_fn_25+0x1d6>
    2217:	mov    rcx,rsi
    221a:	mov    rax,rcx
    221d:	sar    rax,1
    2220:	imul   QWORD PTR [rip+0xb1]        # 22d8 <botlish_fn_25+0x270>
    2227:	seto   cl
    222a:	or     rax,0x1
    222e:	test   cl,cl
    2230:	jne    223e <botlish_fn_25+0x1d6>
    2236:	mov    rdx,rax
    2239:	jmp    224e <botlish_fn_25+0x1e6>
    223e:	mov    edx,0x5
    2243:	mov    rdi,rbx
    2246:	call   224b <botlish_fn_25+0x1e3>
			2247: R_X86_64_PLT32	rt_int_mul-0x4
    224b:	mov    rdx,rax
    224e:	mov    QWORD PTR [rsp+0x8],rdx
    2253:	mov    rsi,r12
    2256:	mov    rdi,rbx
    2259:	call   225e <botlish_fn_25+0x1f6>
			225a: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    225e:	test   rax,rax
    2261:	je     229c <botlish_fn_25+0x234>
    2267:	jmp    22b7 <botlish_fn_25+0x24f>
    226c:	mov    rsi,r12
    226f:	mov    rdi,rbx
    2272:	call   2277 <botlish_fn_25+0x20f>
			2273: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2277:	test   rax,rax
    227a:	je     229c <botlish_fn_25+0x234>
    2280:	mov    QWORD PTR [rsp+0x8],rax
    2285:	mov    rdx,rax
    2288:	mov    rsi,r12
    228b:	mov    rdi,rbx
    228e:	call   2293 <botlish_fn_25+0x22b>
			228f: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2293:	test   rax,rax
    2296:	jne    22b7 <botlish_fn_25+0x24f>
    229c:	xor    rax,rax
    229f:	mov    rbx,QWORD PTR [rsp+0x20]
    22a4:	mov    r12,QWORD PTR [rsp+0x28]
    22a9:	mov    r13,QWORD PTR [rsp+0x30]
    22ae:	add    rsp,0x40
    22b2:	mov    rsp,rbp
    22b5:	pop    rbp
    22b6:	ret
    22b7:	mov    rbx,QWORD PTR [rsp+0x20]
    22bc:	mov    r12,QWORD PTR [rsp+0x28]
    22c1:	mov    r13,QWORD PTR [rsp+0x30]
    22c6:	add    rsp,0x40
    22ca:	mov    rsp,rbp
    22cd:	pop    rbp
    22ce:	ret
    22cf:	add    BYTE PTR [rsi],al
    22d1:	add    BYTE PTR [rax],al
    22d3:	add    BYTE PTR [rax],al
    22d5:	add    BYTE PTR [rax],al
    22d7:	add    BYTE PTR [rax+rax*1],al
    22da:	add    BYTE PTR [rax],al
    22dc:	add    BYTE PTR [rax],al
	...

00000000000022e0 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    22e0:	push   rbp
    22e1:	mov    rbp,rsp
    22e4:	mov    rsi,QWORD PTR [rdx]
    22e7:	call   22ec <botlish_entry_25+0xc>
			22e8: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    22ec:	mov    rsp,rbp
    22ef:	pop    rbp
    22f0:	ret
    22f1:	add    BYTE PTR [rax],al
    22f3:	add    BYTE PTR [rax],al
    22f5:	add    BYTE PTR [rax],al
	...

00000000000022f8 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    22f8:	push   rbp
    22f9:	mov    rbp,rsp
    22fc:	sub    rsp,0x70
    2300:	mov    QWORD PTR [rsp+0x40],rbx
    2305:	mov    QWORD PTR [rsp+0x48],r12
    230a:	mov    QWORD PTR [rsp+0x50],r13
    230f:	mov    QWORD PTR [rsp+0x58],r14
    2314:	mov    QWORD PTR [rsp+0x60],r15
    2319:	mov    rbx,rdi
    231c:	mov    QWORD PTR [rsp+0x20],0x0
    2325:	mov    QWORD PTR [rsp+0x28],0x0
    232e:	mov    QWORD PTR [rsp],rsi
    2332:	mov    r12,rsi
    2335:	mov    QWORD PTR [rsp+0x8],rdx
    233a:	mov    r15,rdx
    233d:	mov    QWORD PTR [rsp+0x10],rcx
    2342:	mov    QWORD PTR [rsp+0x30],rcx
    2347:	mov    QWORD PTR [rsp+0x18],r8
    234c:	mov    r14,r8
    234f:	mov    rsi,r12
    2352:	mov    rdi,rbx
    2355:	call   235a <botlish_fn_26+0x62>
			2356: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    235a:	test   rax,rax
    235d:	je     26f6 <botlish_fn_26+0x3fe>
    2363:	mov    QWORD PTR [rsp+0x20],rax
    2368:	xor    ecx,ecx
    236a:	test   rax,0x7
    2370:	je     2380 <botlish_fn_26+0x88>
    2376:	mov    QWORD PTR [rsp+0x38],rax
    237b:	jmp    2390 <botlish_fn_26+0x98>
    2380:	movzx  rcx,BYTE PTR [rax]
    2384:	mov    QWORD PTR [rsp+0x38],rax
    2389:	rex cmp cl,0x8
    238d:	sete   cl
    2390:	test   cl,cl
    2392:	jne    23b7 <botlish_fn_26+0xbf>
    2398:	mov    rdi,rbx
    239b:	mov    rax,QWORD PTR [rdi+0x10]
    239f:	mov    rcx,QWORD PTR [rax+0x8]
    23a3:	mov    edx,0x8
    23a8:	mov    rsi,QWORD PTR [rsp+0x38]
    23ad:	call   23b2 <botlish_fn_26+0xba>
			23ae: R_X86_64_PLT32	rt_type_error-0x4
    23b2:	jmp    26f6 <botlish_fn_26+0x3fe>
    23b7:	mov    rdx,r15
    23ba:	mov    rsi,QWORD PTR [rsp+0x38]
    23bf:	mov    rdi,rbx
    23c2:	call   23c7 <botlish_fn_26+0xcf>
			23c3: R_X86_64_PLT32	rt_mutarray_get-0x4
    23c7:	test   rax,rax
    23ca:	je     26f6 <botlish_fn_26+0x3fe>
    23d0:	mov    QWORD PTR [rsp+0x28],rax
    23d5:	mov    r13,rax
    23d8:	mov    rdi,rbx
    23db:	call   23e0 <botlish_fn_26+0xe8>
			23dc: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    23e0:	test   rax,rax
    23e3:	mov    rcx,rax
    23e6:	je     26f6 <botlish_fn_26+0x3fe>
    23ec:	mov    rsi,QWORD PTR [rsp+0x38]
    23f1:	mov    rdx,r15
    23f4:	mov    rdi,rbx
    23f7:	call   23fc <botlish_fn_26+0x104>
			23f8: R_X86_64_PLT32	rt_mutarray_set-0x4
    23fc:	test   rax,rax
    23ff:	je     26f6 <botlish_fn_26+0x3fe>
    2405:	mov    rsi,r12
    2408:	mov    rdi,rbx
    240b:	call   2410 <botlish_fn_26+0x118>
			240c: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2410:	test   rax,rax
    2413:	je     26f6 <botlish_fn_26+0x3fe>
    2419:	xor    ecx,ecx
    241b:	test   rax,0x7
    2421:	je     242f <botlish_fn_26+0x137>
    2427:	mov    rsi,rax
    242a:	jmp    243d <botlish_fn_26+0x145>
    242f:	movzx  rcx,BYTE PTR [rax]
    2433:	mov    rsi,rax
    2436:	rex cmp cl,0x8
    243a:	sete   cl
    243d:	test   cl,cl
    243f:	jne    245f <botlish_fn_26+0x167>
    2445:	mov    rdi,rbx
    2448:	mov    rcx,QWORD PTR [rdi+0x10]
    244c:	mov    rcx,QWORD PTR [rcx+0x20]
    2450:	mov    edx,0x8
    2455:	call   245a <botlish_fn_26+0x162>
			2456: R_X86_64_PLT32	rt_type_error-0x4
    245a:	jmp    26f6 <botlish_fn_26+0x3fe>
    245f:	mov    rcx,QWORD PTR [rsp+0x30]
    2464:	mov    rdx,r15
    2467:	mov    rdi,rbx
    246a:	call   246f <botlish_fn_26+0x177>
			246b: R_X86_64_PLT32	rt_mutarray_set-0x4
    246f:	test   rax,rax
    2472:	je     26f6 <botlish_fn_26+0x3fe>
    2478:	mov    rsi,r12
    247b:	mov    rdi,rbx
    247e:	call   2483 <botlish_fn_26+0x18b>
			247f: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2483:	test   rax,rax
    2486:	je     26f6 <botlish_fn_26+0x3fe>
    248c:	xor    ecx,ecx
    248e:	test   rax,0x7
    2494:	je     24a2 <botlish_fn_26+0x1aa>
    249a:	mov    rsi,rax
    249d:	jmp    24b0 <botlish_fn_26+0x1b8>
    24a2:	movzx  r11,BYTE PTR [rax]
    24a6:	mov    rsi,rax
    24a9:	cmp    r11b,0x8
    24ad:	sete   cl
    24b0:	test   cl,cl
    24b2:	jne    24d2 <botlish_fn_26+0x1da>
    24b8:	mov    rdi,rbx
    24bb:	mov    rax,QWORD PTR [rdi+0x10]
    24bf:	mov    rcx,QWORD PTR [rax+0x20]
    24c3:	mov    edx,0x8
    24c8:	call   24cd <botlish_fn_26+0x1d5>
			24c9: R_X86_64_PLT32	rt_type_error-0x4
    24cd:	jmp    26f6 <botlish_fn_26+0x3fe>
    24d2:	mov    rcx,r14
    24d5:	mov    rdx,r15
    24d8:	mov    rdi,rbx
    24db:	call   24e0 <botlish_fn_26+0x1e8>
			24dc: R_X86_64_PLT32	rt_mutarray_set-0x4
    24e0:	test   rax,rax
    24e3:	je     26f6 <botlish_fn_26+0x3fe>
    24e9:	mov    QWORD PTR [rsp+0x8],0x7
    24f2:	mov    rsi,r12
    24f5:	mov    rdi,rbx
    24f8:	call   24fd <botlish_fn_26+0x205>
			24f9: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    24fd:	test   rax,rax
    2500:	je     26f6 <botlish_fn_26+0x3fe>
    2506:	mov    QWORD PTR [rsp+0x10],rax
    250b:	mov    QWORD PTR [rsp+0x18],0x3
    2514:	mov    ecx,0x1
    2519:	test   rax,0x1
    251f:	je     252d <botlish_fn_26+0x235>
    2525:	mov    rsi,rax
    2528:	jmp    2551 <botlish_fn_26+0x259>
    252d:	xor    ecx,ecx
    252f:	test   rax,0x7
    2535:	je     2543 <botlish_fn_26+0x24b>
    253b:	mov    rsi,rax
    253e:	jmp    2551 <botlish_fn_26+0x259>
    2543:	movzx  rcx,BYTE PTR [rax]
    2547:	mov    rsi,rax
    254a:	rex cmp cl,0x1
    254e:	sete   cl
    2551:	test   cl,cl
    2553:	jne    2571 <botlish_fn_26+0x279>
    2559:	mov    rdi,rbx
    255c:	mov    rax,QWORD PTR [rdi+0x10]
    2560:	mov    rcx,QWORD PTR [rax+0x10]
    2564:	xor    rdx,rdx
    2567:	call   256c <botlish_fn_26+0x274>
			2568: R_X86_64_PLT32	rt_type_error-0x4
    256c:	jmp    26f6 <botlish_fn_26+0x3fe>
    2571:	test   rsi,0x1
    2578:	je     2590 <botlish_fn_26+0x298>
    257e:	mov    rcx,rsi
    2581:	add    rcx,0x2
    2585:	seto   al
    2588:	test   al,al
    258a:	je     25a0 <botlish_fn_26+0x2a8>
    2590:	mov    edx,0x3
    2595:	mov    rdi,rbx
    2598:	call   259d <botlish_fn_26+0x2a5>
			2599: R_X86_64_PLT32	rt_int_add-0x4
    259d:	mov    rcx,rax
    25a0:	mov    edx,0x7
    25a5:	mov    rsi,r12
    25a8:	mov    rdi,rbx
    25ab:	call   25b0 <botlish_fn_26+0x2b8>
			25ac: R_X86_64_PLT32	rt_mutarray_set-0x4
    25b0:	test   rax,rax
    25b3:	je     26f6 <botlish_fn_26+0x3fe>
    25b9:	mov    rdi,rbx
    25bc:	call   25c1 <botlish_fn_26+0x2c9>
			25bd: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    25c1:	test   rax,rax
    25c4:	je     26f6 <botlish_fn_26+0x3fe>
    25ca:	mov    rcx,r13
    25cd:	mov    rdx,rcx
    25d0:	and    rdx,rax
    25d3:	mov    rsi,rax
    25d6:	test   rdx,0x1
    25dd:	jne    25ff <botlish_fn_26+0x307>
    25e3:	mov    rdx,rsi
    25e6:	mov    rsi,r13
    25e9:	mov    rdi,rbx
    25ec:	call   25f1 <botlish_fn_26+0x2f9>
			25ed: R_X86_64_PLT32	rt_value_eq-0x4
    25f1:	test   rax,rax
    25f4:	je     26f6 <botlish_fn_26+0x3fe>
    25fa:	jmp    2615 <botlish_fn_26+0x31d>
    25ff:	mov    rdx,rsi
    2602:	mov    rsi,r13
    2605:	mov    eax,0x2
    260a:	cmp    rsi,rdx
    260d:	cmove  rax,QWORD PTR [rip+0x133]        # 2748 <botlish_fn_26+0x450>
    2615:	cmp    rax,0x6
    2619:	jne    271b <botlish_fn_26+0x423>
    261f:	mov    QWORD PTR [rsp+0x8],0x9
    2628:	mov    rsi,r12
    262b:	mov    rdi,rbx
    262e:	call   2633 <botlish_fn_26+0x33b>
			262f: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2633:	test   rax,rax
    2636:	je     26f6 <botlish_fn_26+0x3fe>
    263c:	mov    QWORD PTR [rsp+0x10],rax
    2641:	mov    QWORD PTR [rsp+0x18],0x3
    264a:	mov    ecx,0x1
    264f:	test   rax,0x1
    2655:	je     2663 <botlish_fn_26+0x36b>
    265b:	mov    rsi,rax
    265e:	jmp    2687 <botlish_fn_26+0x38f>
    2663:	xor    ecx,ecx
    2665:	test   rax,0x7
    266b:	je     2679 <botlish_fn_26+0x381>
    2671:	mov    rsi,rax
    2674:	jmp    2687 <botlish_fn_26+0x38f>
    2679:	movzx  r10,BYTE PTR [rax]
    267d:	mov    rsi,rax
    2680:	cmp    r10b,0x1
    2684:	sete   cl
    2687:	test   cl,cl
    2689:	jne    26a7 <botlish_fn_26+0x3af>
    268f:	mov    rdi,rbx
    2692:	mov    rax,QWORD PTR [rdi+0x10]
    2696:	mov    rcx,QWORD PTR [rax+0x28]
    269a:	xor    rdx,rdx
    269d:	call   26a2 <botlish_fn_26+0x3aa>
			269e: R_X86_64_PLT32	rt_type_error-0x4
    26a2:	jmp    26f6 <botlish_fn_26+0x3fe>
    26a7:	test   rsi,0x1
    26ae:	je     26cd <botlish_fn_26+0x3d5>
    26b4:	mov    rcx,rsi
    26b7:	sub    rcx,0x3
    26bb:	seto   al
    26be:	add    rcx,0x1
    26c5:	test   al,al
    26c7:	je     26dd <botlish_fn_26+0x3e5>
    26cd:	mov    edx,0x3
    26d2:	mov    rdi,rbx
    26d5:	call   26da <botlish_fn_26+0x3e2>
			26d6: R_X86_64_PLT32	rt_int_sub-0x4
    26da:	mov    rcx,rax
    26dd:	mov    edx,0x9
    26e2:	mov    rsi,r12
    26e5:	mov    rdi,rbx
    26e8:	call   26ed <botlish_fn_26+0x3f5>
			26e9: R_X86_64_PLT32	rt_mutarray_set-0x4
    26ed:	test   rax,rax
    26f0:	jne    271b <botlish_fn_26+0x423>
    26f6:	xor    rax,rax
    26f9:	mov    rbx,QWORD PTR [rsp+0x40]
    26fe:	mov    r12,QWORD PTR [rsp+0x48]
    2703:	mov    r13,QWORD PTR [rsp+0x50]
    2708:	mov    r14,QWORD PTR [rsp+0x58]
    270d:	mov    r15,QWORD PTR [rsp+0x60]
    2712:	add    rsp,0x70
    2716:	mov    rsp,rbp
    2719:	pop    rbp
    271a:	ret
    271b:	mov    eax,0xa
    2720:	mov    rbx,QWORD PTR [rsp+0x40]
    2725:	mov    r12,QWORD PTR [rsp+0x48]
    272a:	mov    r13,QWORD PTR [rsp+0x50]
    272f:	mov    r14,QWORD PTR [rsp+0x58]
    2734:	mov    r15,QWORD PTR [rsp+0x60]
    2739:	add    rsp,0x70
    273d:	mov    rsp,rbp
    2740:	pop    rbp
    2741:	ret
    2742:	add    BYTE PTR [rax],al
    2744:	add    BYTE PTR [rax],al
    2746:	add    BYTE PTR [rax],al
    2748:	(bad)
    2749:	add    BYTE PTR [rax],al
    274b:	add    BYTE PTR [rax],al
    274d:	add    BYTE PTR [rax],al
	...

0000000000002750 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    2750:	push   rbp
    2751:	mov    rbp,rsp
    2754:	mov    rsi,QWORD PTR [rdx]
    2757:	mov    r9,QWORD PTR [rdx+0x8]
    275b:	mov    rcx,QWORD PTR [rdx+0x10]
    275f:	mov    r8,QWORD PTR [rdx+0x18]
    2763:	mov    rdx,r9
    2766:	call   276b <botlish_entry_26+0x1b>
			2767: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    276b:	mov    rsp,rbp
    276e:	pop    rbp
    276f:	ret

0000000000002770 <botlish_fn_27: ht_set<mutarray, str, str>>:
    2770:	push   rbp
    2771:	mov    rbp,rsp
    2774:	sub    rsp,0x70
    2778:	mov    QWORD PTR [rsp+0x40],rbx
    277d:	mov    QWORD PTR [rsp+0x48],r12
    2782:	mov    QWORD PTR [rsp+0x50],r13
    2787:	mov    QWORD PTR [rsp+0x58],r14
    278c:	mov    QWORD PTR [rsp+0x60],r15
    2791:	mov    rbx,rdi
    2794:	mov    QWORD PTR [rsp+0x18],0x0
    279d:	mov    QWORD PTR [rsp+0x20],0x0
    27a6:	mov    QWORD PTR [rsp],rsi
    27aa:	mov    r14,rsi
    27ad:	mov    QWORD PTR [rsp+0x8],rdx
    27b2:	mov    r13,rdx
    27b5:	mov    QWORD PTR [rsp+0x10],rcx
    27ba:	mov    r12,rcx
    27bd:	mov    rdx,r13
    27c0:	mov    rsi,r14
    27c3:	mov    rdi,rbx
    27c6:	call   27cb <botlish_fn_27+0x5b>
			27c7: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    27cb:	test   rax,rax
    27ce:	je     2a67 <botlish_fn_27+0x2f7>
    27d4:	mov    QWORD PTR [rsp+0x18],rax
    27d9:	mov    rcx,rax
    27dc:	mov    r8,0xffffffffffffffff
    27e3:	mov    QWORD PTR [rsp+0x30],r8
    27e8:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    27f1:	mov    rdx,r13
    27f4:	mov    rsi,r14
    27f7:	mov    rdi,rbx
    27fa:	call   27ff <botlish_fn_27+0x8f>
			27fb: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    27ff:	mov    rcx,rax
    2802:	mov    r15,rax
    2805:	test   rax,rcx
    2808:	je     2a67 <botlish_fn_27+0x2f7>
    280e:	mov    rax,r15
    2811:	mov    QWORD PTR [rsp+0x18],rax
    2816:	mov    rsi,r14
    2819:	mov    rdi,rbx
    281c:	call   2821 <botlish_fn_27+0xb1>
			281d: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    2821:	test   rax,rax
    2824:	je     2a67 <botlish_fn_27+0x2f7>
    282a:	xor    ecx,ecx
    282c:	test   rax,0x7
    2832:	je     2840 <botlish_fn_27+0xd0>
    2838:	mov    r8,rax
    283b:	jmp    284e <botlish_fn_27+0xde>
    2840:	movzx  rdx,BYTE PTR [rax]
    2844:	mov    r8,rax
    2847:	rex cmp dl,0x8
    284b:	sete   cl
    284e:	test   cl,cl
    2850:	jne    2873 <botlish_fn_27+0x103>
    2856:	mov    rdi,rbx
    2859:	mov    rsi,QWORD PTR [rdi+0x10]
    285d:	mov    rcx,QWORD PTR [rsi+0x8]
    2861:	mov    edx,0x8
    2866:	mov    rsi,r8
    2869:	call   286e <botlish_fn_27+0xfe>
			286a: R_X86_64_PLT32	rt_type_error-0x4
    286e:	jmp    2a67 <botlish_fn_27+0x2f7>
    2873:	mov    rsi,r8
    2876:	mov    rdx,r15
    2879:	mov    rdi,rbx
    287c:	call   2881 <botlish_fn_27+0x111>
			287d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2881:	test   rax,rax
    2884:	je     2a67 <botlish_fn_27+0x2f7>
    288a:	mov    QWORD PTR [rsp+0x20],rax
    288f:	mov    QWORD PTR [rsp+0x28],rax
    2894:	mov    rdi,rbx
    2897:	call   289c <botlish_fn_27+0x12c>
			2898: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    289c:	test   rax,rax
    289f:	je     2a67 <botlish_fn_27+0x2f7>
    28a5:	mov    rcx,QWORD PTR [rsp+0x28]
    28aa:	mov    rdx,rcx
    28ad:	and    rdx,rax
    28b0:	test   rdx,0x1
    28b7:	jne    28db <botlish_fn_27+0x16b>
    28bd:	mov    rdx,rax
    28c0:	mov    rsi,QWORD PTR [rsp+0x28]
    28c5:	mov    rdi,rbx
    28c8:	call   28cd <botlish_fn_27+0x15d>
			28c9: R_X86_64_PLT32	rt_value_eq-0x4
    28cd:	test   rax,rax
    28d0:	je     2a67 <botlish_fn_27+0x2f7>
    28d6:	jmp    28f3 <botlish_fn_27+0x183>
    28db:	mov    rdx,rax
    28de:	mov    rsi,QWORD PTR [rsp+0x28]
    28e3:	mov    eax,0x2
    28e8:	cmp    rsi,rdx
    28eb:	cmove  rax,QWORD PTR [rip+0x1c5]        # 2ab8 <botlish_fn_27+0x348>
    28f3:	cmp    rax,0x6
    28f7:	je     29f6 <botlish_fn_27+0x286>
    28fd:	mov    rsi,r14
    2900:	mov    rdi,rbx
    2903:	call   2908 <botlish_fn_27+0x198>
			2904: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2908:	test   rax,rax
    290b:	je     2a67 <botlish_fn_27+0x2f7>
    2911:	cmp    rax,0x6
    2915:	je     295a <botlish_fn_27+0x1ea>
    291b:	mov    rcx,r13
    291e:	mov    rdx,r15
    2921:	mov    rsi,r14
    2924:	mov    rdi,rbx
    2927:	mov    r8,r12
    292a:	call   292f <botlish_fn_27+0x1bf>
			292b: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    292f:	test   rax,rax
    2932:	je     2a67 <botlish_fn_27+0x2f7>
    2938:	mov    rbx,QWORD PTR [rsp+0x40]
    293d:	mov    r12,QWORD PTR [rsp+0x48]
    2942:	mov    r13,QWORD PTR [rsp+0x50]
    2947:	mov    r14,QWORD PTR [rsp+0x58]
    294c:	mov    r15,QWORD PTR [rsp+0x60]
    2951:	add    rsp,0x70
    2955:	mov    rsp,rbp
    2958:	pop    rbp
    2959:	ret
    295a:	mov    rsi,r14
    295d:	mov    rdi,rbx
    2960:	call   2965 <botlish_fn_27+0x1f5>
			2961: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    2965:	test   rax,rax
    2968:	je     2a67 <botlish_fn_27+0x2f7>
    296e:	mov    rdx,r13
    2971:	mov    rsi,r14
    2974:	mov    rdi,rbx
    2977:	call   297c <botlish_fn_27+0x20c>
			2978: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    297c:	test   rax,rax
    297f:	je     2a67 <botlish_fn_27+0x2f7>
    2985:	mov    QWORD PTR [rsp+0x18],rax
    298a:	mov    rcx,rax
    298d:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    2996:	mov    r8,QWORD PTR [rsp+0x30]
    299b:	mov    rdx,r13
    299e:	mov    rsi,r14
    29a1:	mov    rdi,rbx
    29a4:	call   29a9 <botlish_fn_27+0x239>
			29a5: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    29a9:	test   rax,rax
    29ac:	je     2a67 <botlish_fn_27+0x2f7>
    29b2:	mov    QWORD PTR [rsp+0x18],rax
    29b7:	mov    rcx,r13
    29ba:	mov    rdx,rax
    29bd:	mov    rsi,r14
    29c0:	mov    rdi,rbx
    29c3:	mov    r8,r12
    29c6:	call   29cb <botlish_fn_27+0x25b>
			29c7: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    29cb:	test   rax,rax
    29ce:	je     2a67 <botlish_fn_27+0x2f7>
    29d4:	mov    rbx,QWORD PTR [rsp+0x40]
    29d9:	mov    r12,QWORD PTR [rsp+0x48]
    29de:	mov    r13,QWORD PTR [rsp+0x50]
    29e3:	mov    r14,QWORD PTR [rsp+0x58]
    29e8:	mov    r15,QWORD PTR [rsp+0x60]
    29ed:	add    rsp,0x70
    29f1:	mov    rsp,rbp
    29f4:	pop    rbp
    29f5:	ret
    29f6:	mov    rsi,r14
    29f9:	mov    rdi,rbx
    29fc:	call   2a01 <botlish_fn_27+0x291>
			29fd: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2a01:	test   rax,rax
    2a04:	je     2a67 <botlish_fn_27+0x2f7>
    2a0a:	xor    ecx,ecx
    2a0c:	test   rax,0x7
    2a12:	je     2a20 <botlish_fn_27+0x2b0>
    2a18:	mov    rsi,rax
    2a1b:	jmp    2a2e <botlish_fn_27+0x2be>
    2a20:	movzx  rcx,BYTE PTR [rax]
    2a24:	mov    rsi,rax
    2a27:	rex cmp cl,0x8
    2a2b:	sete   cl
    2a2e:	test   cl,cl
    2a30:	jne    2a50 <botlish_fn_27+0x2e0>
    2a36:	mov    rdi,rbx
    2a39:	mov    rax,QWORD PTR [rdi+0x10]
    2a3d:	mov    rcx,QWORD PTR [rax+0x20]
    2a41:	mov    edx,0x8
    2a46:	call   2a4b <botlish_fn_27+0x2db>
			2a47: R_X86_64_PLT32	rt_type_error-0x4
    2a4b:	jmp    2a67 <botlish_fn_27+0x2f7>
    2a50:	mov    rcx,r12
    2a53:	mov    rdx,r15
    2a56:	mov    rdi,rbx
    2a59:	call   2a5e <botlish_fn_27+0x2ee>
			2a5a: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a5e:	test   rax,rax
    2a61:	jne    2a8c <botlish_fn_27+0x31c>
    2a67:	xor    rax,rax
    2a6a:	mov    rbx,QWORD PTR [rsp+0x40]
    2a6f:	mov    r12,QWORD PTR [rsp+0x48]
    2a74:	mov    r13,QWORD PTR [rsp+0x50]
    2a79:	mov    r14,QWORD PTR [rsp+0x58]
    2a7e:	mov    r15,QWORD PTR [rsp+0x60]
    2a83:	add    rsp,0x70
    2a87:	mov    rsp,rbp
    2a8a:	pop    rbp
    2a8b:	ret
    2a8c:	mov    eax,0xa
    2a91:	mov    rbx,QWORD PTR [rsp+0x40]
    2a96:	mov    r12,QWORD PTR [rsp+0x48]
    2a9b:	mov    r13,QWORD PTR [rsp+0x50]
    2aa0:	mov    r14,QWORD PTR [rsp+0x58]
    2aa5:	mov    r15,QWORD PTR [rsp+0x60]
    2aaa:	add    rsp,0x70
    2aae:	mov    rsp,rbp
    2ab1:	pop    rbp
    2ab2:	ret
    2ab3:	add    BYTE PTR [rax],al
    2ab5:	add    BYTE PTR [rax],al
    2ab7:	add    BYTE PTR [rsi],al
    2ab9:	add    BYTE PTR [rax],al
    2abb:	add    BYTE PTR [rax],al
    2abd:	add    BYTE PTR [rax],al
	...

0000000000002ac0 <botlish_entry_27: ht_set<mutarray, str, str>>:
    2ac0:	push   rbp
    2ac1:	mov    rbp,rsp
    2ac4:	mov    rsi,QWORD PTR [rdx]
    2ac7:	mov    r8,QWORD PTR [rdx+0x8]
    2acb:	mov    rcx,QWORD PTR [rdx+0x10]
    2acf:	mov    rdx,r8
    2ad2:	call   2ad7 <botlish_entry_27+0x17>
			2ad3: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2ad7:	mov    rsp,rbp
    2ada:	pop    rbp
    2adb:	ret
    2adc:	add    BYTE PTR [rax],al
	...

0000000000002ae0 <botlish_fn_28: ht_delete<mutarray, str>>:
    2ae0:	push   rbp
    2ae1:	mov    rbp,rsp
    2ae4:	sub    rsp,0x40
    2ae8:	mov    QWORD PTR [rsp+0x20],rbx
    2aed:	mov    QWORD PTR [rsp+0x28],r12
    2af2:	mov    QWORD PTR [rsp+0x30],r13
    2af7:	mov    QWORD PTR [rsp+0x38],r14
    2afc:	mov    rbx,rdi
    2aff:	mov    QWORD PTR [rsp+0x10],0x0
    2b08:	mov    QWORD PTR [rsp+0x18],0x0
    2b11:	mov    QWORD PTR [rsp],rsi
    2b15:	mov    r12,rsi
    2b18:	mov    QWORD PTR [rsp+0x8],rdx
    2b1d:	mov    r13,rdx
    2b20:	mov    rdx,r13
    2b23:	mov    rsi,r12
    2b26:	mov    rdi,rbx
    2b29:	call   2b2e <botlish_fn_28+0x4e>
			2b2a: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    2b2e:	test   rax,rax
    2b31:	je     2ee0 <botlish_fn_28+0x400>
    2b37:	mov    QWORD PTR [rsp+0x10],rax
    2b3c:	mov    rcx,rax
    2b3f:	mov    rdx,r13
    2b42:	mov    rsi,r12
    2b45:	mov    rdi,rbx
    2b48:	call   2b4d <botlish_fn_28+0x6d>
			2b49: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    2b4d:	mov    rcx,rax
    2b50:	mov    r13,rax
    2b53:	test   rax,rcx
    2b56:	je     2ee0 <botlish_fn_28+0x400>
    2b5c:	mov    rax,r13
    2b5f:	mov    QWORD PTR [rsp+0x8],rax
    2b64:	test   rax,0x1
    2b6a:	jne    2b95 <botlish_fn_28+0xb5>
    2b70:	mov    edx,0x1
    2b75:	mov    rsi,r13
    2b78:	mov    rdi,rbx
    2b7b:	call   2b80 <botlish_fn_28+0xa0>
			2b7c: R_X86_64_PLT32	rt_int_cmp-0x4
    2b80:	mov    ecx,0x2
    2b85:	test   rax,rax
    2b88:	cmovl  rcx,QWORD PTR [rip+0x3b8]        # 2f48 <botlish_fn_28+0x468>
    2b90:	jmp    2bab <botlish_fn_28+0xcb>
    2b95:	mov    ecx,0x2
    2b9a:	mov    rax,r13
    2b9d:	mov    rdx,r13
    2ba0:	test   rax,rdx
    2ba3:	cmovle rcx,QWORD PTR [rip+0x39d]        # 2f48 <botlish_fn_28+0x468>
    2bab:	cmp    rcx,0x6
    2baf:	je     2f22 <botlish_fn_28+0x442>
    2bb5:	mov    rsi,r12
    2bb8:	mov    rdi,rbx
    2bbb:	call   2bc0 <botlish_fn_28+0xe0>
			2bbc: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    2bc0:	test   rax,rax
    2bc3:	je     2ee0 <botlish_fn_28+0x400>
    2bc9:	mov    QWORD PTR [rsp+0x10],rax
    2bce:	mov    r14,rax
    2bd1:	mov    rdi,rbx
    2bd4:	call   2bd9 <botlish_fn_28+0xf9>
			2bd5: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    2bd9:	test   rax,rax
    2bdc:	mov    rdx,rax
    2bdf:	je     2ee0 <botlish_fn_28+0x400>
    2be5:	xor    ecx,ecx
    2be7:	mov    rax,r14
    2bea:	test   rax,0x7
    2bf0:	je     2bfe <botlish_fn_28+0x11e>
    2bf6:	mov    r14,rax
    2bf9:	jmp    2c0c <botlish_fn_28+0x12c>
    2bfe:	movzx  rcx,BYTE PTR [rax]
    2c02:	mov    r14,rax
    2c05:	rex cmp cl,0x8
    2c09:	sete   cl
    2c0c:	test   cl,cl
    2c0e:	jne    2c31 <botlish_fn_28+0x151>
    2c14:	mov    rdi,rbx
    2c17:	mov    rcx,QWORD PTR [rdi+0x10]
    2c1b:	mov    rcx,QWORD PTR [rcx+0x20]
    2c1f:	mov    edx,0x8
    2c24:	mov    rsi,r14
    2c27:	call   2c2c <botlish_fn_28+0x14c>
			2c28: R_X86_64_PLT32	rt_type_error-0x4
    2c2c:	jmp    2ee0 <botlish_fn_28+0x400>
    2c31:	mov    rcx,rdx
    2c34:	mov    rsi,r14
    2c37:	mov    rdx,r13
    2c3a:	mov    rdi,rbx
    2c3d:	call   2c42 <botlish_fn_28+0x162>
			2c3e: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c42:	test   rax,rax
    2c45:	je     2ee0 <botlish_fn_28+0x400>
    2c4b:	mov    rsi,r12
    2c4e:	mov    rdi,rbx
    2c51:	call   2c56 <botlish_fn_28+0x176>
			2c52: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2c56:	test   rax,rax
    2c59:	je     2ee0 <botlish_fn_28+0x400>
    2c5f:	xor    esi,esi
    2c61:	test   rax,0x7
    2c67:	je     2c75 <botlish_fn_28+0x195>
    2c6d:	mov    r8,rax
    2c70:	jmp    2c84 <botlish_fn_28+0x1a4>
    2c75:	movzx  r11,BYTE PTR [rax]
    2c79:	mov    r8,rax
    2c7c:	cmp    r11b,0x8
    2c80:	sete   sil
    2c84:	test   sil,sil
    2c87:	jne    2caa <botlish_fn_28+0x1ca>
    2c8d:	mov    rdi,rbx
    2c90:	mov    rax,QWORD PTR [rdi+0x10]
    2c94:	mov    rcx,QWORD PTR [rax+0x20]
    2c98:	mov    edx,0x8
    2c9d:	mov    rsi,r8
    2ca0:	call   2ca5 <botlish_fn_28+0x1c5>
			2ca1: R_X86_64_PLT32	rt_type_error-0x4
    2ca5:	jmp    2ee0 <botlish_fn_28+0x400>
    2caa:	mov    rsi,r8
    2cad:	mov    ecx,0xa
    2cb2:	mov    rdx,r13
    2cb5:	mov    rdi,rbx
    2cb8:	call   2cbd <botlish_fn_28+0x1dd>
			2cb9: R_X86_64_PLT32	rt_mutarray_set-0x4
    2cbd:	test   rax,rax
    2cc0:	je     2ee0 <botlish_fn_28+0x400>
    2cc6:	mov    rsi,r12
    2cc9:	mov    rdi,rbx
    2ccc:	call   2cd1 <botlish_fn_28+0x1f1>
			2ccd: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2cd1:	test   rax,rax
    2cd4:	je     2ee0 <botlish_fn_28+0x400>
    2cda:	xor    ecx,ecx
    2cdc:	test   rax,0x7
    2ce2:	je     2cf0 <botlish_fn_28+0x210>
    2ce8:	mov    rsi,rax
    2ceb:	jmp    2cfe <botlish_fn_28+0x21e>
    2cf0:	movzx  rcx,BYTE PTR [rax]
    2cf4:	mov    rsi,rax
    2cf7:	rex cmp cl,0x8
    2cfb:	sete   cl
    2cfe:	test   cl,cl
    2d00:	jne    2d20 <botlish_fn_28+0x240>
    2d06:	mov    rdi,rbx
    2d09:	mov    rax,QWORD PTR [rdi+0x10]
    2d0d:	mov    rcx,QWORD PTR [rax+0x20]
    2d11:	mov    edx,0x8
    2d16:	call   2d1b <botlish_fn_28+0x23b>
			2d17: R_X86_64_PLT32	rt_type_error-0x4
    2d1b:	jmp    2ee0 <botlish_fn_28+0x400>
    2d20:	mov    ecx,0xa
    2d25:	mov    rdx,r13
    2d28:	mov    rdi,rbx
    2d2b:	call   2d30 <botlish_fn_28+0x250>
			2d2c: R_X86_64_PLT32	rt_mutarray_set-0x4
    2d30:	test   rax,rax
    2d33:	je     2ee0 <botlish_fn_28+0x400>
    2d39:	mov    QWORD PTR [rsp+0x8],0x7
    2d42:	mov    rsi,r12
    2d45:	mov    rdi,rbx
    2d48:	call   2d4d <botlish_fn_28+0x26d>
			2d49: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2d4d:	test   rax,rax
    2d50:	je     2ee0 <botlish_fn_28+0x400>
    2d56:	mov    QWORD PTR [rsp+0x10],rax
    2d5b:	mov    QWORD PTR [rsp+0x18],0x3
    2d64:	mov    ecx,0x1
    2d69:	test   rax,0x1
    2d6f:	je     2d7d <botlish_fn_28+0x29d>
    2d75:	mov    rsi,rax
    2d78:	jmp    2da1 <botlish_fn_28+0x2c1>
    2d7d:	xor    ecx,ecx
    2d7f:	test   rax,0x7
    2d85:	je     2d93 <botlish_fn_28+0x2b3>
    2d8b:	mov    rsi,rax
    2d8e:	jmp    2da1 <botlish_fn_28+0x2c1>
    2d93:	movzx  rcx,BYTE PTR [rax]
    2d97:	mov    rsi,rax
    2d9a:	rex cmp cl,0x1
    2d9e:	sete   cl
    2da1:	test   cl,cl
    2da3:	jne    2dc1 <botlish_fn_28+0x2e1>
    2da9:	mov    rdi,rbx
    2dac:	mov    rax,QWORD PTR [rdi+0x10]
    2db0:	mov    rcx,QWORD PTR [rax+0x28]
    2db4:	xor    rdx,rdx
    2db7:	call   2dbc <botlish_fn_28+0x2dc>
			2db8: R_X86_64_PLT32	rt_type_error-0x4
    2dbc:	jmp    2ee0 <botlish_fn_28+0x400>
    2dc1:	test   rsi,0x1
    2dc8:	je     2de7 <botlish_fn_28+0x307>
    2dce:	mov    rcx,rsi
    2dd1:	sub    rcx,0x3
    2dd5:	seto   al
    2dd8:	add    rcx,0x1
    2ddf:	test   al,al
    2de1:	je     2df7 <botlish_fn_28+0x317>
    2de7:	mov    edx,0x3
    2dec:	mov    rdi,rbx
    2def:	call   2df4 <botlish_fn_28+0x314>
			2df0: R_X86_64_PLT32	rt_int_sub-0x4
    2df4:	mov    rcx,rax
    2df7:	mov    edx,0x7
    2dfc:	mov    rsi,r12
    2dff:	mov    rdi,rbx
    2e02:	call   2e07 <botlish_fn_28+0x327>
			2e03: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e07:	test   rax,rax
    2e0a:	je     2ee0 <botlish_fn_28+0x400>
    2e10:	mov    QWORD PTR [rsp+0x8],0x9
    2e19:	mov    rsi,r12
    2e1c:	mov    rdi,rbx
    2e1f:	call   2e24 <botlish_fn_28+0x344>
			2e20: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2e24:	test   rax,rax
    2e27:	je     2ee0 <botlish_fn_28+0x400>
    2e2d:	mov    QWORD PTR [rsp+0x10],rax
    2e32:	mov    QWORD PTR [rsp+0x18],0x3
    2e3b:	mov    ecx,0x1
    2e40:	test   rax,0x1
    2e46:	je     2e54 <botlish_fn_28+0x374>
    2e4c:	mov    rsi,rax
    2e4f:	jmp    2e78 <botlish_fn_28+0x398>
    2e54:	xor    ecx,ecx
    2e56:	test   rax,0x7
    2e5c:	je     2e6a <botlish_fn_28+0x38a>
    2e62:	mov    rsi,rax
    2e65:	jmp    2e78 <botlish_fn_28+0x398>
    2e6a:	movzx  r10,BYTE PTR [rax]
    2e6e:	mov    rsi,rax
    2e71:	cmp    r10b,0x1
    2e75:	sete   cl
    2e78:	test   cl,cl
    2e7a:	jne    2e98 <botlish_fn_28+0x3b8>
    2e80:	mov    rdi,rbx
    2e83:	mov    rax,QWORD PTR [rdi+0x10]
    2e87:	mov    rcx,QWORD PTR [rax+0x10]
    2e8b:	xor    rdx,rdx
    2e8e:	call   2e93 <botlish_fn_28+0x3b3>
			2e8f: R_X86_64_PLT32	rt_type_error-0x4
    2e93:	jmp    2ee0 <botlish_fn_28+0x400>
    2e98:	test   rsi,0x1
    2e9f:	je     2eb7 <botlish_fn_28+0x3d7>
    2ea5:	mov    rcx,rsi
    2ea8:	add    rcx,0x2
    2eac:	seto   al
    2eaf:	test   al,al
    2eb1:	je     2ec7 <botlish_fn_28+0x3e7>
    2eb7:	mov    edx,0x3
    2ebc:	mov    rdi,rbx
    2ebf:	call   2ec4 <botlish_fn_28+0x3e4>
			2ec0: R_X86_64_PLT32	rt_int_add-0x4
    2ec4:	mov    rcx,rax
    2ec7:	mov    edx,0x9
    2ecc:	mov    rsi,r12
    2ecf:	mov    rdi,rbx
    2ed2:	call   2ed7 <botlish_fn_28+0x3f7>
			2ed3: R_X86_64_PLT32	rt_mutarray_set-0x4
    2ed7:	test   rax,rax
    2eda:	jne    2f00 <botlish_fn_28+0x420>
    2ee0:	xor    rax,rax
    2ee3:	mov    rbx,QWORD PTR [rsp+0x20]
    2ee8:	mov    r12,QWORD PTR [rsp+0x28]
    2eed:	mov    r13,QWORD PTR [rsp+0x30]
    2ef2:	mov    r14,QWORD PTR [rsp+0x38]
    2ef7:	add    rsp,0x40
    2efb:	mov    rsp,rbp
    2efe:	pop    rbp
    2eff:	ret
    2f00:	mov    eax,0xa
    2f05:	mov    rbx,QWORD PTR [rsp+0x20]
    2f0a:	mov    r12,QWORD PTR [rsp+0x28]
    2f0f:	mov    r13,QWORD PTR [rsp+0x30]
    2f14:	mov    r14,QWORD PTR [rsp+0x38]
    2f19:	add    rsp,0x40
    2f1d:	mov    rsp,rbp
    2f20:	pop    rbp
    2f21:	ret
    2f22:	mov    eax,0xa
    2f27:	mov    rbx,QWORD PTR [rsp+0x20]
    2f2c:	mov    r12,QWORD PTR [rsp+0x28]
    2f31:	mov    r13,QWORD PTR [rsp+0x30]
    2f36:	mov    r14,QWORD PTR [rsp+0x38]
    2f3b:	add    rsp,0x40
    2f3f:	mov    rsp,rbp
    2f42:	pop    rbp
    2f43:	ret
    2f44:	add    BYTE PTR [rax],al
    2f46:	add    BYTE PTR [rax],al
    2f48:	(bad)
    2f49:	add    BYTE PTR [rax],al
    2f4b:	add    BYTE PTR [rax],al
    2f4d:	add    BYTE PTR [rax],al
	...

0000000000002f50 <botlish_entry_28: ht_delete<mutarray, str>>:
    2f50:	push   rbp
    2f51:	mov    rbp,rsp
    2f54:	mov    rsi,QWORD PTR [rdx]
    2f57:	mov    rdx,QWORD PTR [rdx+0x8]
    2f5b:	call   2f60 <botlish_entry_28+0x10>
			2f5c: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    2f60:	mov    rsp,rbp
    2f63:	pop    rbp
    2f64:	ret
    2f65:	add    BYTE PTR [rax],al
	...

0000000000002f68 <botlish_fn_29: sample<generic>>:
    2f68:	push   rbp
    2f69:	mov    rbp,rsp
    2f6c:	sub    rsp,0xa0
    2f73:	mov    QWORD PTR [rsp+0x70],rbx
    2f78:	mov    QWORD PTR [rsp+0x78],r12
    2f7d:	mov    QWORD PTR [rsp+0x80],r13
    2f85:	mov    QWORD PTR [rsp+0x88],r14
    2f8d:	mov    QWORD PTR [rsp+0x90],r15
    2f95:	mov    r14,rdi
    2f98:	mov    QWORD PTR [rsp],0x0
    2fa0:	mov    QWORD PTR [rsp+0x8],0x0
    2fa9:	mov    QWORD PTR [rsp+0x10],0x0
    2fb2:	mov    QWORD PTR [rsp+0x18],0x0
    2fbb:	mov    QWORD PTR [rsp+0x20],0x0
    2fc4:	mov    QWORD PTR [rsp+0x28],0x0
    2fcd:	mov    rdi,r14
    2fd0:	call   2fd5 <botlish_fn_29+0x6d>
			2fd1: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    2fd5:	mov    rcx,rax
    2fd8:	mov    r15,rax
    2fdb:	test   rax,rcx
    2fde:	je     321e <botlish_fn_29+0x2b6>
    2fe4:	mov    rax,r15
    2fe7:	mov    QWORD PTR [rsp],rax
    2feb:	mov    rdi,r14
    2fee:	mov    rax,QWORD PTR [rdi+0x10]
    2ff2:	mov    rdx,QWORD PTR [rax+0x30]
    2ff6:	mov    QWORD PTR [rsp+0x8],rdx
    2ffb:	mov    rax,QWORD PTR [rdi+0x10]
    2fff:	mov    rcx,QWORD PTR [rax+0x38]
    3003:	mov    QWORD PTR [rsp+0x10],rcx
    3008:	mov    rsi,r15
    300b:	call   3010 <botlish_fn_29+0xa8>
			300c: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3010:	test   rax,rax
    3013:	je     321e <botlish_fn_29+0x2b6>
    3019:	mov    rdi,r14
    301c:	mov    rsi,QWORD PTR [rdi+0x10]
    3020:	mov    rdx,QWORD PTR [rsi+0x40]
    3024:	mov    QWORD PTR [rsp+0x8],rdx
    3029:	mov    rsi,QWORD PTR [rdi+0x10]
    302d:	mov    rcx,QWORD PTR [rsi+0x48]
    3031:	mov    QWORD PTR [rsp+0x10],rcx
    3036:	mov    rsi,r15
    3039:	call   303e <botlish_fn_29+0xd6>
			303a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    303e:	test   rax,rax
    3041:	je     321e <botlish_fn_29+0x2b6>
    3047:	mov    rdi,r14
    304a:	mov    r9,QWORD PTR [rdi+0x10]
    304e:	mov    rdx,QWORD PTR [r9+0x30]
    3052:	mov    QWORD PTR [rsp+0x8],rdx
    3057:	mov    r10,QWORD PTR [rdi+0x10]
    305b:	mov    rcx,QWORD PTR [r10+0x50]
    305f:	mov    QWORD PTR [rsp+0x10],rcx
    3064:	mov    rsi,r15
    3067:	call   306c <botlish_fn_29+0x104>
			3068: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    306c:	test   rax,rax
    306f:	je     321e <botlish_fn_29+0x2b6>
    3075:	mov    rdi,r14
    3078:	mov    rax,QWORD PTR [rdi+0x10]
    307c:	mov    rdx,QWORD PTR [rax+0x40]
    3080:	mov    QWORD PTR [rsp+0x8],rdx
    3085:	mov    rsi,r15
    3088:	call   308d <botlish_fn_29+0x125>
			3089: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    308d:	mov    rbx,rax
    3090:	test   rbx,rbx
    3093:	je     321e <botlish_fn_29+0x2b6>
    3099:	mov    QWORD PTR [rsp+0x8],rbx
    309e:	mov    rdi,r14
    30a1:	mov    rax,QWORD PTR [rdi+0x10]
    30a5:	mov    rdx,QWORD PTR [rax+0x40]
    30a9:	mov    QWORD PTR [rsp+0x10],rdx
    30ae:	mov    rsi,r15
    30b1:	call   30b6 <botlish_fn_29+0x14e>
			30b2: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    30b6:	test   rax,rax
    30b9:	je     321e <botlish_fn_29+0x2b6>
    30bf:	mov    rdi,r14
    30c2:	mov    rax,QWORD PTR [rdi+0x10]
    30c6:	mov    rdx,QWORD PTR [rax+0x30]
    30ca:	mov    QWORD PTR [rsp+0x10],rdx
    30cf:	mov    rsi,r15
    30d2:	call   30d7 <botlish_fn_29+0x16f>
			30d3: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    30d7:	test   rax,rax
    30da:	je     321e <botlish_fn_29+0x2b6>
    30e0:	mov    rdi,r14
    30e3:	mov    rcx,QWORD PTR [rdi+0x10]
    30e7:	mov    rdx,QWORD PTR [rcx+0x50]
    30eb:	mov    rcx,rax
    30ee:	and    rcx,rdx
    30f1:	mov    rsi,rax
    30f4:	test   rcx,0x1
    30fb:	jne    3117 <botlish_fn_29+0x1af>
    3101:	mov    rdi,r14
    3104:	call   3109 <botlish_fn_29+0x1a1>
			3105: R_X86_64_PLT32	rt_value_eq-0x4
    3109:	test   rax,rax
    310c:	je     321e <botlish_fn_29+0x2b6>
    3112:	jmp    3127 <botlish_fn_29+0x1bf>
    3117:	mov    eax,0x2
    311c:	cmp    rsi,rdx
    311f:	cmove  rax,QWORD PTR [rip+0x159]        # 3280 <botlish_fn_29+0x318>
    3127:	mov    QWORD PTR [rsp+0x10],rax
    312c:	mov    rdi,r14
    312f:	mov    QWORD PTR [rsp+0x60],rax
    3134:	mov    rax,QWORD PTR [rdi+0x10]
    3138:	mov    rdx,QWORD PTR [rax+0x40]
    313c:	mov    QWORD PTR [rsp+0x18],rdx
    3141:	mov    rsi,r15
    3144:	call   3149 <botlish_fn_29+0x1e1>
			3145: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3149:	mov    r12,rax
    314c:	test   r12,r12
    314f:	je     321e <botlish_fn_29+0x2b6>
    3155:	mov    QWORD PTR [rsp+0x18],r12
    315a:	mov    rdi,r14
    315d:	mov    rax,QWORD PTR [rdi+0x10]
    3161:	mov    rdx,QWORD PTR [rax+0x58]
    3165:	mov    QWORD PTR [rsp+0x20],rdx
    316a:	mov    rsi,r15
    316d:	call   3172 <botlish_fn_29+0x20a>
			316e: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3172:	mov    r13,rax
    3175:	test   r13,r13
    3178:	je     321e <botlish_fn_29+0x2b6>
    317e:	mov    QWORD PTR [rsp+0x20],r13
    3183:	mov    rdi,r14
    3186:	mov    rax,QWORD PTR [rdi+0x10]
    318a:	mov    rdx,QWORD PTR [rax+0x58]
    318e:	mov    QWORD PTR [rsp+0x28],rdx
    3193:	mov    rsi,r15
    3196:	call   319b <botlish_fn_29+0x233>
			3197: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    319b:	test   rax,rax
    319e:	mov    rsi,rax
    31a1:	je     321e <botlish_fn_29+0x2b6>
    31a7:	mov    edx,0xa
    31ac:	mov    rdi,r14
    31af:	call   31b4 <botlish_fn_29+0x24c>
			31b0: R_X86_64_PLT32	rt_value_eq-0x4
    31b4:	test   rax,rax
    31b7:	je     321e <botlish_fn_29+0x2b6>
    31bd:	mov    QWORD PTR [rsp+0x28],rax
    31c2:	mov    rsi,r15
    31c5:	mov    r15,rax
    31c8:	mov    rdi,r14
    31cb:	call   31d0 <botlish_fn_29+0x268>
			31cc: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    31d0:	test   rax,rax
    31d3:	je     321e <botlish_fn_29+0x2b6>
    31d9:	mov    QWORD PTR [rsp],rax
    31dd:	lea    rdx,[rsp+0x30]
    31e2:	mov    rsi,QWORD PTR [rsp+0x60]
    31e7:	mov    QWORD PTR [rsp+0x30],rsi
    31ec:	mov    QWORD PTR [rsp+0x38],rbx
    31f1:	mov    QWORD PTR [rsp+0x40],r12
    31f6:	mov    QWORD PTR [rsp+0x48],r13
    31fb:	mov    r8,r15
    31fe:	mov    QWORD PTR [rsp+0x50],r8
    3203:	mov    QWORD PTR [rsp+0x58],rax
    3208:	mov    esi,0x6
    320d:	mov    rdi,r14
    3210:	call   3215 <botlish_fn_29+0x2ad>
			3211: R_X86_64_PLT32	rt_list_new-0x4
    3215:	test   rax,rax
    3218:	jne    324f <botlish_fn_29+0x2e7>
    321e:	xor    rax,rax
    3221:	mov    rbx,QWORD PTR [rsp+0x70]
    3226:	mov    r12,QWORD PTR [rsp+0x78]
    322b:	mov    r13,QWORD PTR [rsp+0x80]
    3233:	mov    r14,QWORD PTR [rsp+0x88]
    323b:	mov    r15,QWORD PTR [rsp+0x90]
    3243:	add    rsp,0xa0
    324a:	mov    rsp,rbp
    324d:	pop    rbp
    324e:	ret
    324f:	mov    rbx,QWORD PTR [rsp+0x70]
    3254:	mov    r12,QWORD PTR [rsp+0x78]
    3259:	mov    r13,QWORD PTR [rsp+0x80]
    3261:	mov    r14,QWORD PTR [rsp+0x88]
    3269:	mov    r15,QWORD PTR [rsp+0x90]
    3271:	add    rsp,0xa0
    3278:	mov    rsp,rbp
    327b:	pop    rbp
    327c:	ret
    327d:	add    BYTE PTR [rax],al
    327f:	add    BYTE PTR [rsi],al
    3281:	add    BYTE PTR [rax],al
    3283:	add    BYTE PTR [rax],al
    3285:	add    BYTE PTR [rax],al
	...

0000000000003288 <botlish_entry_29: sample<generic>>:
    3288:	push   rbp
    3289:	mov    rbp,rsp
    328c:	call   3291 <botlish_entry_29+0x9>
			328d: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    3291:	mov    rsp,rbp
    3294:	pop    rbp
    3295:	ret

; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 13552  (per function: 45 28 28 28 28 412 524 116 61 61 61 61 61 174 190 233 852 1312 437 261 428 458 1153 803 841 681 1232 892 1253 838)
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
     10a:	cmovge rcx,QWORD PTR [rip+0xf6]        # 208 <botlish_fn_5+0x168>
     112:	jmp    12a <botlish_fn_5+0x8a>
     117:	mov    ecx,0x2
     11c:	mov    rsi,r14
     11f:	cmp    rsi,r12
     122:	cmovge rcx,QWORD PTR [rip+0xde]        # 208 <botlish_fn_5+0x168>
     12a:	cmp    rcx,0x6
     12e:	je     1e0 <botlish_fn_5+0x140>
     134:	mov    rdi,r13
     137:	call   13c <botlish_fn_5+0x9c>
			138: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     13c:	test   rax,rax
     13f:	je     161 <botlish_fn_5+0xc1>
     145:	mov    ecx,0x1
     14a:	mov    rdx,r14
     14d:	mov    rsi,rbx
     150:	mov    rdi,r13
     153:	call   158 <botlish_fn_5+0xb8>
			154: R_X86_64_PLT32	rt_mutarray_set-0x4
     158:	test   rax,rax
     15b:	jne    181 <botlish_fn_5+0xe1>
     161:	xor    rax,rax
     164:	mov    rbx,QWORD PTR [rsp+0x20]
     169:	mov    r12,QWORD PTR [rsp+0x28]
     16e:	mov    r13,QWORD PTR [rsp+0x30]
     173:	mov    r14,QWORD PTR [rsp+0x38]
     178:	add    rsp,0x40
     17c:	mov    rsp,rbp
     17f:	pop    rbp
     180:	ret
     181:	mov    QWORD PTR [rsp+0x18],0x3
     18a:	mov    rsi,r14
     18d:	test   rsi,0x1
     194:	je     1b7 <botlish_fn_5+0x117>
     19a:	mov    rsi,r14
     19d:	mov    rcx,rsi
     1a0:	add    rcx,0x2
     1a4:	seto   al
     1a7:	test   al,al
     1a9:	jne    1b7 <botlish_fn_5+0x117>
     1af:	mov    r14,rcx
     1b2:	jmp    1ca <botlish_fn_5+0x12a>
     1b7:	mov    edx,0x3
     1bc:	mov    rsi,r14
     1bf:	mov    rdi,r13
     1c2:	call   1c7 <botlish_fn_5+0x127>
			1c3: R_X86_64_PLT32	rt_int_add-0x4
     1c7:	mov    r14,rax
     1ca:	mov    QWORD PTR [rsp],rbx
     1ce:	mov    rsi,r14
     1d1:	mov    QWORD PTR [rsp+0x8],rsi
     1d6:	mov    QWORD PTR [rsp+0x10],r12
     1db:	jmp    df <botlish_fn_5+0x3f>
     1e0:	mov    eax,0xa
     1e5:	mov    rbx,QWORD PTR [rsp+0x20]
     1ea:	mov    r12,QWORD PTR [rsp+0x28]
     1ef:	mov    r13,QWORD PTR [rsp+0x30]
     1f4:	mov    r14,QWORD PTR [rsp+0x38]
     1f9:	add    rsp,0x40
     1fd:	mov    rsp,rbp
     200:	pop    rbp
     201:	ret
     202:	add    BYTE PTR [rax],al
     204:	add    BYTE PTR [rax],al
     206:	add    BYTE PTR [rax],al
     208:	(bad)
     209:	add    BYTE PTR [rax],al
     20b:	add    BYTE PTR [rax],al
     20d:	add    BYTE PTR [rax],al
	...

0000000000000210 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     210:	push   rbp
     211:	mov    rbp,rsp
     214:	mov    rsi,QWORD PTR [rdx]
     217:	mov    r8,QWORD PTR [rdx+0x8]
     21b:	mov    rcx,QWORD PTR [rdx+0x10]
     21f:	mov    rdx,r8
     222:	call   227 <botlish_entry_5+0x17>
			223: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     227:	mov    rsp,rbp
     22a:	pop    rbp
     22b:	ret

000000000000022c <botlish_fn_6: ht_alloc<int>>:
     22c:	push   rbp
     22d:	mov    rbp,rsp
     230:	sub    rsp,0x50
     234:	mov    QWORD PTR [rsp+0x20],rbx
     239:	mov    QWORD PTR [rsp+0x28],r12
     23e:	mov    QWORD PTR [rsp+0x30],r13
     243:	mov    QWORD PTR [rsp+0x38],r14
     248:	mov    QWORD PTR [rsp+0x40],r15
     24d:	mov    rbx,rdi
     250:	mov    QWORD PTR [rsp+0x8],0x0
     259:	mov    QWORD PTR [rsp+0x10],0x0
     262:	mov    QWORD PTR [rsp+0x18],0x0
     26b:	mov    QWORD PTR [rsp],rsi
     26f:	mov    r13,rsi
     272:	mov    rsi,r13
     275:	mov    rdi,rbx
     278:	call   27d <botlish_fn_6+0x51>
			279: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     27d:	test   rax,rax
     280:	je     39c <botlish_fn_6+0x170>
     286:	mov    QWORD PTR [rsp+0x8],rax
     28b:	mov    r12,rax
     28e:	mov    edx,0x1
     293:	mov    QWORD PTR [rsp+0x10],0x1
     29c:	mov    rcx,r13
     29f:	mov    rsi,r12
     2a2:	mov    rdi,rbx
     2a5:	call   2aa <botlish_fn_6+0x7e>
			2a6: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     2aa:	test   rax,rax
     2ad:	je     39c <botlish_fn_6+0x170>
     2b3:	mov    rsi,r13
     2b6:	mov    rdi,rbx
     2b9:	call   2be <botlish_fn_6+0x92>
			2ba: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2be:	test   rax,rax
     2c1:	je     39c <botlish_fn_6+0x170>
     2c7:	mov    QWORD PTR [rsp+0x10],rax
     2cc:	mov    rsi,r13
     2cf:	mov    r14,rax
     2d2:	mov    rdi,rbx
     2d5:	call   2da <botlish_fn_6+0xae>
			2d6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2da:	test   rax,rax
     2dd:	je     39c <botlish_fn_6+0x170>
     2e3:	mov    QWORD PTR [rsp],rax
     2e7:	mov    r13,rax
     2ea:	mov    esi,0xb
     2ef:	mov    QWORD PTR [rsp+0x18],0xb
     2f8:	mov    rdi,rbx
     2fb:	call   300 <botlish_fn_6+0xd4>
			2fc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     300:	test   rax,rax
     303:	mov    r15,rax
     306:	je     39c <botlish_fn_6+0x170>
     30c:	mov    edx,0x1
     311:	mov    rcx,r12
     314:	mov    rsi,r15
     317:	mov    rdi,rbx
     31a:	call   31f <botlish_fn_6+0xf3>
			31b: R_X86_64_PLT32	rt_mutarray_set-0x4
     31f:	test   rax,rax
     322:	je     39c <botlish_fn_6+0x170>
     328:	mov    edx,0x3
     32d:	mov    rcx,r14
     330:	mov    rsi,r15
     333:	mov    rdi,rbx
     336:	call   33b <botlish_fn_6+0x10f>
			337: R_X86_64_PLT32	rt_mutarray_set-0x4
     33b:	test   rax,rax
     33e:	je     39c <botlish_fn_6+0x170>
     344:	mov    edx,0x5
     349:	mov    rcx,r13
     34c:	mov    rsi,r15
     34f:	mov    rdi,rbx
     352:	call   357 <botlish_fn_6+0x12b>
			353: R_X86_64_PLT32	rt_mutarray_set-0x4
     357:	test   rax,rax
     35a:	je     39c <botlish_fn_6+0x170>
     360:	mov    edx,0x7
     365:	mov    ecx,0x1
     36a:	mov    rsi,r15
     36d:	mov    rdi,rbx
     370:	call   375 <botlish_fn_6+0x149>
			371: R_X86_64_PLT32	rt_mutarray_set-0x4
     375:	test   rax,rax
     378:	je     39c <botlish_fn_6+0x170>
     37e:	mov    edx,0x9
     383:	mov    ecx,0x1
     388:	mov    rdi,rbx
     38b:	mov    rsi,r15
     38e:	call   393 <botlish_fn_6+0x167>
			38f: R_X86_64_PLT32	rt_mutarray_set-0x4
     393:	test   rax,rax
     396:	jne    3c1 <botlish_fn_6+0x195>
     39c:	xor    rax,rax
     39f:	mov    rbx,QWORD PTR [rsp+0x20]
     3a4:	mov    r12,QWORD PTR [rsp+0x28]
     3a9:	mov    r13,QWORD PTR [rsp+0x30]
     3ae:	mov    r14,QWORD PTR [rsp+0x38]
     3b3:	mov    r15,QWORD PTR [rsp+0x40]
     3b8:	add    rsp,0x50
     3bc:	mov    rsp,rbp
     3bf:	pop    rbp
     3c0:	ret
     3c1:	mov    rax,r15
     3c4:	mov    rbx,QWORD PTR [rsp+0x20]
     3c9:	mov    r12,QWORD PTR [rsp+0x28]
     3ce:	mov    r13,QWORD PTR [rsp+0x30]
     3d3:	mov    r14,QWORD PTR [rsp+0x38]
     3d8:	mov    r15,QWORD PTR [rsp+0x40]
     3dd:	add    rsp,0x50
     3e1:	mov    rsp,rbp
     3e4:	pop    rbp
     3e5:	ret

00000000000003e6 <botlish_entry_6: ht_alloc<int>>:
     3e6:	push   rbp
     3e7:	mov    rbp,rsp
     3ea:	mov    rsi,QWORD PTR [rdx]
     3ed:	call   3f2 <botlish_entry_6+0xc>
			3ee: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     3f2:	mov    rsp,rbp
     3f5:	pop    rbp
     3f6:	ret

00000000000003f7 <botlish_fn_7: ht_new<generic>>:
     3f7:	push   rbp
     3f8:	mov    rbp,rsp
     3fb:	sub    rsp,0x20
     3ff:	mov    QWORD PTR [rsp+0x10],r12
     404:	mov    r12,rdi
     407:	mov    QWORD PTR [rsp],0x0
     40f:	mov    rdi,r12
     412:	call   417 <botlish_fn_7+0x20>
			413: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     417:	test   rax,rax
     41a:	je     43e <botlish_fn_7+0x47>
     420:	mov    esi,0x11
     425:	mov    QWORD PTR [rsp],0x11
     42d:	mov    rdi,r12
     430:	call   435 <botlish_fn_7+0x3e>
			431: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     435:	test   rax,rax
     438:	jne    44f <botlish_fn_7+0x58>
     43e:	xor    rax,rax
     441:	mov    r12,QWORD PTR [rsp+0x10]
     446:	add    rsp,0x20
     44a:	mov    rsp,rbp
     44d:	pop    rbp
     44e:	ret
     44f:	mov    r12,QWORD PTR [rsp+0x10]
     454:	add    rsp,0x20
     458:	mov    rsp,rbp
     45b:	pop    rbp
     45c:	ret

000000000000045d <botlish_entry_7: ht_new<generic>>:
     45d:	push   rbp
     45e:	mov    rbp,rsp
     461:	call   466 <botlish_entry_7+0x9>
			462: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     466:	mov    rsp,rbp
     469:	pop    rbp
     46a:	ret

000000000000046b <botlish_fn_8: ht_controls<mutarray>>:
     46b:	push   rbp
     46c:	mov    rbp,rsp
     46f:	mov    edx,0x1
     474:	call   479 <botlish_fn_8+0xe>
			475: R_X86_64_PLT32	rt_mutarray_get-0x4
     479:	test   rax,rax
     47c:	jne    48a <botlish_fn_8+0x1f>
     482:	xor    rax,rax
     485:	mov    rsp,rbp
     488:	pop    rbp
     489:	ret
     48a:	mov    rsp,rbp
     48d:	pop    rbp
     48e:	ret

000000000000048f <botlish_entry_8: ht_controls<mutarray>>:
     48f:	push   rbp
     490:	mov    rbp,rsp
     493:	mov    rsi,QWORD PTR [rdx]
     496:	call   49b <botlish_entry_8+0xc>
			497: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     49b:	mov    rsp,rbp
     49e:	pop    rbp
     49f:	ret

00000000000004a0 <botlish_fn_9: ht_keys<mutarray>>:
     4a0:	push   rbp
     4a1:	mov    rbp,rsp
     4a4:	mov    edx,0x3
     4a9:	call   4ae <botlish_fn_9+0xe>
			4aa: R_X86_64_PLT32	rt_mutarray_get-0x4
     4ae:	test   rax,rax
     4b1:	jne    4bf <botlish_fn_9+0x1f>
     4b7:	xor    rax,rax
     4ba:	mov    rsp,rbp
     4bd:	pop    rbp
     4be:	ret
     4bf:	mov    rsp,rbp
     4c2:	pop    rbp
     4c3:	ret

00000000000004c4 <botlish_entry_9: ht_keys<mutarray>>:
     4c4:	push   rbp
     4c5:	mov    rbp,rsp
     4c8:	mov    rsi,QWORD PTR [rdx]
     4cb:	call   4d0 <botlish_entry_9+0xc>
			4cc: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     4d0:	mov    rsp,rbp
     4d3:	pop    rbp
     4d4:	ret

00000000000004d5 <botlish_fn_10: ht_values<mutarray>>:
     4d5:	push   rbp
     4d6:	mov    rbp,rsp
     4d9:	mov    edx,0x5
     4de:	call   4e3 <botlish_fn_10+0xe>
			4df: R_X86_64_PLT32	rt_mutarray_get-0x4
     4e3:	test   rax,rax
     4e6:	jne    4f4 <botlish_fn_10+0x1f>
     4ec:	xor    rax,rax
     4ef:	mov    rsp,rbp
     4f2:	pop    rbp
     4f3:	ret
     4f4:	mov    rsp,rbp
     4f7:	pop    rbp
     4f8:	ret

00000000000004f9 <botlish_entry_10: ht_values<mutarray>>:
     4f9:	push   rbp
     4fa:	mov    rbp,rsp
     4fd:	mov    rsi,QWORD PTR [rdx]
     500:	call   505 <botlish_entry_10+0xc>
			501: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     505:	mov    rsp,rbp
     508:	pop    rbp
     509:	ret

000000000000050a <botlish_fn_11: ht_size<mutarray>>:
     50a:	push   rbp
     50b:	mov    rbp,rsp
     50e:	mov    edx,0x7
     513:	call   518 <botlish_fn_11+0xe>
			514: R_X86_64_PLT32	rt_mutarray_get-0x4
     518:	test   rax,rax
     51b:	jne    529 <botlish_fn_11+0x1f>
     521:	xor    rax,rax
     524:	mov    rsp,rbp
     527:	pop    rbp
     528:	ret
     529:	mov    rsp,rbp
     52c:	pop    rbp
     52d:	ret

000000000000052e <botlish_entry_11: ht_size<mutarray>>:
     52e:	push   rbp
     52f:	mov    rbp,rsp
     532:	mov    rsi,QWORD PTR [rdx]
     535:	call   53a <botlish_entry_11+0xc>
			536: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     53a:	mov    rsp,rbp
     53d:	pop    rbp
     53e:	ret

000000000000053f <botlish_fn_12: ht_tombstones<mutarray>>:
     53f:	push   rbp
     540:	mov    rbp,rsp
     543:	mov    edx,0x9
     548:	call   54d <botlish_fn_12+0xe>
			549: R_X86_64_PLT32	rt_mutarray_get-0x4
     54d:	test   rax,rax
     550:	jne    55e <botlish_fn_12+0x1f>
     556:	xor    rax,rax
     559:	mov    rsp,rbp
     55c:	pop    rbp
     55d:	ret
     55e:	mov    rsp,rbp
     561:	pop    rbp
     562:	ret

0000000000000563 <botlish_entry_12: ht_tombstones<mutarray>>:
     563:	push   rbp
     564:	mov    rbp,rsp
     567:	mov    rsi,QWORD PTR [rdx]
     56a:	call   56f <botlish_entry_12+0xc>
			56b: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     56f:	mov    rsp,rbp
     572:	pop    rbp
     573:	ret

0000000000000574 <botlish_fn_13: ht_capacity<mutarray>>:
     574:	push   rbp
     575:	mov    rbp,rsp
     578:	sub    rsp,0x20
     57c:	mov    QWORD PTR [rsp+0x10],rbx
     581:	mov    rbx,rdi
     584:	mov    QWORD PTR [rsp],rsi
     588:	mov    rdi,rbx
     58b:	call   590 <botlish_fn_13+0x1c>
			58c: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     590:	test   rax,rax
     593:	je     5dc <botlish_fn_13+0x68>
     599:	xor    r9d,r9d
     59c:	test   rax,0x7
     5a2:	je     5b0 <botlish_fn_13+0x3c>
     5a8:	mov    rsi,rax
     5ab:	jmp    5bf <botlish_fn_13+0x4b>
     5b0:	movzx  rcx,BYTE PTR [rax]
     5b4:	mov    rsi,rax
     5b7:	rex cmp cl,0x8
     5bb:	sete   r9b
     5bf:	test   r9b,r9b
     5c2:	jne    5ed <botlish_fn_13+0x79>
     5c8:	mov    rdi,rbx
     5cb:	mov    rax,QWORD PTR [rdi+0x10]
     5cf:	mov    rcx,QWORD PTR [rax]
     5d2:	mov    edx,0x8
     5d7:	call   5dc <botlish_fn_13+0x68>
			5d8: R_X86_64_PLT32	rt_type_error-0x4
     5dc:	xor    rax,rax
     5df:	mov    rbx,QWORD PTR [rsp+0x10]
     5e4:	add    rsp,0x20
     5e8:	mov    rsp,rbp
     5eb:	pop    rbp
     5ec:	ret
     5ed:	mov    rdi,rbx
     5f0:	call   5f5 <botlish_fn_13+0x81>
			5f1: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     5f5:	mov    rbx,QWORD PTR [rsp+0x10]
     5fa:	add    rsp,0x20
     5fe:	mov    rsp,rbp
     601:	pop    rbp
     602:	ret

0000000000000603 <botlish_entry_13: ht_capacity<mutarray>>:
     603:	push   rbp
     604:	mov    rbp,rsp
     607:	mov    rsi,QWORD PTR [rdx]
     60a:	call   60f <botlish_entry_13+0xc>
			60b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     60f:	mov    rsp,rbp
     612:	pop    rbp
     613:	ret

0000000000000614 <botlish_fn_14: ht_probe_start<mutarray, str>>:
     614:	push   rbp
     615:	mov    rbp,rsp
     618:	sub    rsp,0x30
     61c:	mov    QWORD PTR [rsp+0x10],r12
     621:	mov    QWORD PTR [rsp+0x18],r13
     626:	mov    QWORD PTR [rsp+0x20],r14
     62b:	mov    r12,rdi
     62e:	mov    QWORD PTR [rsp],rsi
     632:	mov    r14,rsi
     635:	mov    rsi,rdx
     638:	mov    rdi,r12
     63b:	call   640 <botlish_fn_14+0x2c>
			63c: R_X86_64_PLT32	rt_hash-0x4
     640:	test   rax,rax
     643:	je     67c <botlish_fn_14+0x68>
     649:	mov    QWORD PTR [rsp+0x8],rax
     64e:	mov    rsi,r14
     651:	mov    r13,rax
     654:	mov    rdi,r12
     657:	call   65c <botlish_fn_14+0x48>
			658: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     65c:	test   rax,rax
     65f:	mov    rdx,rax
     662:	je     67c <botlish_fn_14+0x68>
     668:	mov    rsi,r13
     66b:	mov    rdi,r12
     66e:	call   673 <botlish_fn_14+0x5f>
			66f: R_X86_64_PLT32	rt_int_mod-0x4
     673:	test   rax,rax
     676:	jne    697 <botlish_fn_14+0x83>
     67c:	xor    rax,rax
     67f:	mov    r12,QWORD PTR [rsp+0x10]
     684:	mov    r13,QWORD PTR [rsp+0x18]
     689:	mov    r14,QWORD PTR [rsp+0x20]
     68e:	add    rsp,0x30
     692:	mov    rsp,rbp
     695:	pop    rbp
     696:	ret
     697:	mov    r12,QWORD PTR [rsp+0x10]
     69c:	mov    r13,QWORD PTR [rsp+0x18]
     6a1:	mov    r14,QWORD PTR [rsp+0x20]
     6a6:	add    rsp,0x30
     6aa:	mov    rsp,rbp
     6ad:	pop    rbp
     6ae:	ret

00000000000006af <botlish_entry_14: ht_probe_start<mutarray, str>>:
     6af:	push   rbp
     6b0:	mov    rbp,rsp
     6b3:	mov    rsi,QWORD PTR [rdx]
     6b6:	mov    rdx,QWORD PTR [rdx+0x8]
     6ba:	call   6bf <botlish_entry_14+0x10>
			6bb: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     6bf:	mov    rsp,rbp
     6c2:	pop    rbp
     6c3:	ret

00000000000006c4 <botlish_fn_15: ht_probe_next<mutarray, int>>:
     6c4:	push   rbp
     6c5:	mov    rbp,rsp
     6c8:	sub    rsp,0x30
     6cc:	mov    QWORD PTR [rsp+0x20],rbx
     6d1:	mov    QWORD PTR [rsp+0x28],r13
     6d6:	mov    r13,rdi
     6d9:	mov    QWORD PTR [rsp],rsi
     6dd:	mov    rbx,rsi
     6e0:	mov    QWORD PTR [rsp+0x8],rdx
     6e5:	mov    QWORD PTR [rsp+0x10],0x3
     6ee:	test   rdx,0x1
     6f5:	jne    703 <botlish_fn_15+0x3f>
     6fb:	mov    rcx,rdx
     6fe:	jmp    718 <botlish_fn_15+0x54>
     703:	mov    rsi,rdx
     706:	add    rsi,0x2
     70a:	mov    rcx,rdx
     70d:	seto   al
     710:	test   al,al
     712:	je     72b <botlish_fn_15+0x67>
     718:	mov    edx,0x3
     71d:	mov    rsi,rcx
     720:	mov    rdi,r13
     723:	call   728 <botlish_fn_15+0x64>
			724: R_X86_64_PLT32	rt_int_add-0x4
     728:	mov    rsi,rax
     72b:	mov    QWORD PTR [rsp+0x8],rsi
     730:	mov    rax,rbx
     733:	mov    rbx,rsi
     736:	mov    rsi,rax
     739:	mov    rdi,r13
     73c:	call   741 <botlish_fn_15+0x7d>
			73d: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     741:	test   rax,rax
     744:	mov    rdx,rax
     747:	je     761 <botlish_fn_15+0x9d>
     74d:	mov    rsi,rbx
     750:	mov    rdi,r13
     753:	call   758 <botlish_fn_15+0x94>
			754: R_X86_64_PLT32	rt_int_mod-0x4
     758:	test   rax,rax
     75b:	jne    777 <botlish_fn_15+0xb3>
     761:	xor    rax,rax
     764:	mov    rbx,QWORD PTR [rsp+0x20]
     769:	mov    r13,QWORD PTR [rsp+0x28]
     76e:	add    rsp,0x30
     772:	mov    rsp,rbp
     775:	pop    rbp
     776:	ret
     777:	mov    rbx,QWORD PTR [rsp+0x20]
     77c:	mov    r13,QWORD PTR [rsp+0x28]
     781:	add    rsp,0x30
     785:	mov    rsp,rbp
     788:	pop    rbp
     789:	ret

000000000000078a <botlish_entry_15: ht_probe_next<mutarray, int>>:
     78a:	push   rbp
     78b:	mov    rbp,rsp
     78e:	mov    rsi,QWORD PTR [rdx]
     791:	mov    rdx,QWORD PTR [rdx+0x8]
     795:	call   79a <botlish_entry_15+0x10>
			796: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     79a:	mov    rsp,rbp
     79d:	pop    rbp
     79e:	ret
	...

00000000000007a0 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     7a0:	push   rbp
     7a1:	mov    rbp,rsp
     7a4:	sub    rsp,0x60
     7a8:	mov    QWORD PTR [rsp+0x30],rbx
     7ad:	mov    QWORD PTR [rsp+0x38],r12
     7b2:	mov    QWORD PTR [rsp+0x40],r13
     7b7:	mov    QWORD PTR [rsp+0x48],r14
     7bc:	mov    QWORD PTR [rsp+0x50],r15
     7c1:	mov    r14,rdi
     7c4:	mov    QWORD PTR [rsp+0x18],0x0
     7cd:	mov    QWORD PTR [rsp],rsi
     7d1:	mov    QWORD PTR [rsp+0x8],rdx
     7d6:	mov    r15,rdx
     7d9:	mov    QWORD PTR [rsp+0x10],rcx
     7de:	mov    r13,rsi
     7e1:	mov    QWORD PTR [rsp+0x20],rcx
     7e6:	mov    rsi,r13
     7e9:	mov    rdi,r14
     7ec:	call   7f1 <botlish_fn_16+0x51>
			7ed: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     7f1:	test   rax,rax
     7f4:	je     a13 <botlish_fn_16+0x273>
     7fa:	xor    ecx,ecx
     7fc:	test   rax,0x7
     802:	je     810 <botlish_fn_16+0x70>
     808:	mov    r8,rax
     80b:	jmp    81e <botlish_fn_16+0x7e>
     810:	movzx  rcx,BYTE PTR [rax]
     814:	mov    r8,rax
     817:	rex cmp cl,0x8
     81b:	sete   cl
     81e:	test   cl,cl
     820:	jne    843 <botlish_fn_16+0xa3>
     826:	mov    rdi,r14
     829:	mov    rsi,QWORD PTR [rdi+0x10]
     82d:	mov    rcx,QWORD PTR [rsi+0x8]
     831:	mov    edx,0x8
     836:	mov    rsi,r8
     839:	call   83e <botlish_fn_16+0x9e>
			83a: R_X86_64_PLT32	rt_type_error-0x4
     83e:	jmp    a13 <botlish_fn_16+0x273>
     843:	mov    rsi,r8
     846:	mov    rdx,QWORD PTR [rsp+0x20]
     84b:	mov    rdi,r14
     84e:	call   853 <botlish_fn_16+0xb3>
			84f: R_X86_64_PLT32	rt_mutarray_get-0x4
     853:	mov    rcx,rax
     856:	mov    r12,rax
     859:	test   rax,rcx
     85c:	je     a13 <botlish_fn_16+0x273>
     862:	mov    rax,r12
     865:	mov    QWORD PTR [rsp+0x18],rax
     86a:	mov    rdi,r14
     86d:	call   872 <botlish_fn_16+0xd2>
			86e: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     872:	test   rax,rax
     875:	je     a13 <botlish_fn_16+0x273>
     87b:	mov    rax,r12
     87e:	test   rax,0x1
     884:	jne    8a8 <botlish_fn_16+0x108>
     88a:	mov    edx,0x1
     88f:	mov    rsi,r12
     892:	mov    rdi,r14
     895:	call   89a <botlish_fn_16+0xfa>
			896: R_X86_64_PLT32	rt_value_eq-0x4
     89a:	test   rax,rax
     89d:	je     a13 <botlish_fn_16+0x273>
     8a3:	jmp    8b9 <botlish_fn_16+0x119>
     8a8:	mov    eax,0x2
     8ad:	cmp    r12,0x1
     8b1:	cmove  rax,QWORD PTR [rip+0x1ef]        # aa8 <botlish_fn_16+0x308>
     8b9:	mov    ebx,0x6
     8be:	cmp    rax,0x6
     8c2:	je     a7a <botlish_fn_16+0x2da>
     8c8:	mov    rdi,r14
     8cb:	call   8d0 <botlish_fn_16+0x130>
			8cc: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     8d0:	test   rax,rax
     8d3:	je     a13 <botlish_fn_16+0x273>
     8d9:	test   r12,0x1
     8e0:	jne    904 <botlish_fn_16+0x164>
     8e6:	mov    edx,0x3
     8eb:	mov    rsi,r12
     8ee:	mov    rdi,r14
     8f1:	call   8f6 <botlish_fn_16+0x156>
			8f2: R_X86_64_PLT32	rt_value_eq-0x4
     8f6:	test   rax,rax
     8f9:	je     a13 <botlish_fn_16+0x273>
     8ff:	jmp    918 <botlish_fn_16+0x178>
     904:	mov    rsi,r12
     907:	mov    eax,0x2
     90c:	cmp    rsi,0x3
     910:	cmove  rax,QWORD PTR [rip+0x190]        # aa8 <botlish_fn_16+0x308>
     918:	cmp    rax,0x6
     91c:	je     92f <botlish_fn_16+0x18f>
     922:	mov    ebx,0x2
     927:	mov    r12,r15
     92a:	jmp    9f0 <botlish_fn_16+0x250>
     92f:	mov    rsi,r13
     932:	mov    rdi,r14
     935:	call   93a <botlish_fn_16+0x19a>
			936: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     93a:	test   rax,rax
     93d:	je     a13 <botlish_fn_16+0x273>
     943:	xor    ecx,ecx
     945:	test   rax,0x7
     94b:	je     959 <botlish_fn_16+0x1b9>
     951:	mov    rsi,rax
     954:	jmp    967 <botlish_fn_16+0x1c7>
     959:	movzx  rcx,BYTE PTR [rax]
     95d:	mov    rsi,rax
     960:	rex cmp cl,0x8
     964:	sete   cl
     967:	test   cl,cl
     969:	jne    989 <botlish_fn_16+0x1e9>
     96f:	mov    rdi,r14
     972:	mov    rax,QWORD PTR [rdi+0x10]
     976:	mov    rcx,QWORD PTR [rax+0x8]
     97a:	mov    edx,0x8
     97f:	call   984 <botlish_fn_16+0x1e4>
			980: R_X86_64_PLT32	rt_type_error-0x4
     984:	jmp    a13 <botlish_fn_16+0x273>
     989:	mov    rdx,QWORD PTR [rsp+0x20]
     98e:	mov    rdi,r14
     991:	call   996 <botlish_fn_16+0x1f6>
			992: R_X86_64_PLT32	rt_mutarray_get-0x4
     996:	test   rax,rax
     999:	je     a13 <botlish_fn_16+0x273>
     99f:	mov    r12,r15
     9a2:	mov    rcx,rax
     9a5:	and    rcx,r12
     9a8:	mov    rsi,rax
     9ab:	test   rcx,0x1
     9b2:	jne    9d1 <botlish_fn_16+0x231>
     9b8:	mov    rdx,r12
     9bb:	mov    rdi,r14
     9be:	call   9c3 <botlish_fn_16+0x223>
			9bf: R_X86_64_PLT32	rt_value_eq-0x4
     9c3:	test   rax,rax
     9c6:	je     a13 <botlish_fn_16+0x273>
     9cc:	jmp    9e1 <botlish_fn_16+0x241>
     9d1:	mov    eax,0x2
     9d6:	cmp    rsi,r12
     9d9:	cmove  rax,QWORD PTR [rip+0xc7]        # aa8 <botlish_fn_16+0x308>
     9e1:	cmp    rax,0x6
     9e5:	je     9f0 <botlish_fn_16+0x250>
     9eb:	mov    ebx,0x2
     9f0:	cmp    rbx,0x6
     9f4:	je     a53 <botlish_fn_16+0x2b3>
     9fa:	mov    rdx,QWORD PTR [rsp+0x20]
     9ff:	mov    rsi,r13
     a02:	mov    rdi,r14
     a05:	call   a0a <botlish_fn_16+0x26a>
			a06: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     a0a:	test   rax,rax
     a0d:	jne    a38 <botlish_fn_16+0x298>
     a13:	xor    rax,rax
     a16:	mov    rbx,QWORD PTR [rsp+0x30]
     a1b:	mov    r12,QWORD PTR [rsp+0x38]
     a20:	mov    r13,QWORD PTR [rsp+0x40]
     a25:	mov    r14,QWORD PTR [rsp+0x48]
     a2a:	mov    r15,QWORD PTR [rsp+0x50]
     a2f:	add    rsp,0x60
     a33:	mov    rsp,rbp
     a36:	pop    rbp
     a37:	ret
     a38:	mov    QWORD PTR [rsp],r13
     a3c:	mov    QWORD PTR [rsp+0x8],r12
     a41:	mov    QWORD PTR [rsp+0x10],rax
     a46:	mov    r15,r12
     a49:	mov    QWORD PTR [rsp+0x20],rax
     a4e:	jmp    7e6 <botlish_fn_16+0x46>
     a53:	mov    rax,QWORD PTR [rsp+0x20]
     a58:	mov    rbx,QWORD PTR [rsp+0x30]
     a5d:	mov    r12,QWORD PTR [rsp+0x38]
     a62:	mov    r13,QWORD PTR [rsp+0x40]
     a67:	mov    r14,QWORD PTR [rsp+0x48]
     a6c:	mov    r15,QWORD PTR [rsp+0x50]
     a71:	add    rsp,0x60
     a75:	mov    rsp,rbp
     a78:	pop    rbp
     a79:	ret
     a7a:	mov    rax,0xffffffffffffffff
     a81:	mov    rbx,QWORD PTR [rsp+0x30]
     a86:	mov    r12,QWORD PTR [rsp+0x38]
     a8b:	mov    r13,QWORD PTR [rsp+0x40]
     a90:	mov    r14,QWORD PTR [rsp+0x48]
     a95:	mov    r15,QWORD PTR [rsp+0x50]
     a9a:	add    rsp,0x60
     a9e:	mov    rsp,rbp
     aa1:	pop    rbp
     aa2:	ret
     aa3:	add    BYTE PTR [rax],al
     aa5:	add    BYTE PTR [rax],al
     aa7:	add    BYTE PTR [rsi],al
     aa9:	add    BYTE PTR [rax],al
     aab:	add    BYTE PTR [rax],al
     aad:	add    BYTE PTR [rax],al
	...

0000000000000ab0 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
     ab0:	push   rbp
     ab1:	mov    rbp,rsp
     ab4:	mov    rsi,QWORD PTR [rdx]
     ab7:	mov    r8,QWORD PTR [rdx+0x8]
     abb:	mov    rcx,QWORD PTR [rdx+0x10]
     abf:	mov    rdx,r8
     ac2:	call   ac7 <botlish_entry_16+0x17>
			ac3: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
     ac7:	mov    rsp,rbp
     aca:	pop    rbp
     acb:	ret
     acc:	add    BYTE PTR [rax],al
	...

0000000000000ad0 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
     ad0:	push   rbp
     ad1:	mov    rbp,rsp
     ad4:	sub    rsp,0x70
     ad8:	mov    QWORD PTR [rsp+0x40],rbx
     add:	mov    QWORD PTR [rsp+0x48],r12
     ae2:	mov    QWORD PTR [rsp+0x50],r13
     ae7:	mov    QWORD PTR [rsp+0x58],r14
     aec:	mov    QWORD PTR [rsp+0x60],r15
     af1:	mov    r15,rdi
     af4:	mov    QWORD PTR [rsp+0x20],0x0
     afd:	mov    QWORD PTR [rsp],rsi
     b01:	mov    QWORD PTR [rsp+0x8],rdx
     b06:	mov    r13,rdx
     b09:	mov    QWORD PTR [rsp+0x10],rcx
     b0e:	mov    QWORD PTR [rsp+0x18],r8
     b13:	mov    rbx,rsi
     b16:	mov    QWORD PTR [rsp+0x28],rcx
     b1b:	mov    QWORD PTR [rsp+0x30],r8
     b20:	mov    rsi,rbx
     b23:	mov    rdi,r15
     b26:	call   b2b <botlish_fn_17+0x5b>
			b27: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     b2b:	test   rax,rax
     b2e:	je     e5c <botlish_fn_17+0x38c>
     b34:	xor    ecx,ecx
     b36:	test   rax,0x7
     b3c:	je     b4a <botlish_fn_17+0x7a>
     b42:	mov    rsi,rax
     b45:	jmp    b58 <botlish_fn_17+0x88>
     b4a:	movzx  rcx,BYTE PTR [rax]
     b4e:	mov    rsi,rax
     b51:	rex cmp cl,0x8
     b55:	sete   cl
     b58:	test   cl,cl
     b5a:	jne    b7a <botlish_fn_17+0xaa>
     b60:	mov    rdi,r15
     b63:	mov    rax,QWORD PTR [rdi+0x10]
     b67:	mov    rcx,QWORD PTR [rax+0x8]
     b6b:	mov    edx,0x8
     b70:	call   b75 <botlish_fn_17+0xa5>
			b71: R_X86_64_PLT32	rt_type_error-0x4
     b75:	jmp    e5c <botlish_fn_17+0x38c>
     b7a:	mov    rdx,QWORD PTR [rsp+0x28]
     b7f:	mov    rdi,r15
     b82:	call   b87 <botlish_fn_17+0xb7>
			b83: R_X86_64_PLT32	rt_mutarray_get-0x4
     b87:	mov    r10,rax
     b8a:	mov    r14,rax
     b8d:	test   rax,r10
     b90:	je     e5c <botlish_fn_17+0x38c>
     b96:	mov    rax,r14
     b99:	mov    QWORD PTR [rsp+0x20],rax
     b9e:	mov    rdi,r15
     ba1:	call   ba6 <botlish_fn_17+0xd6>
			ba2: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     ba6:	test   rax,rax
     ba9:	je     e5c <botlish_fn_17+0x38c>
     baf:	mov    rax,r14
     bb2:	test   rax,0x1
     bb8:	jne    bdc <botlish_fn_17+0x10c>
     bbe:	mov    edx,0x1
     bc3:	mov    rsi,r14
     bc6:	mov    rdi,r15
     bc9:	call   bce <botlish_fn_17+0xfe>
			bca: R_X86_64_PLT32	rt_value_eq-0x4
     bce:	test   rax,rax
     bd1:	je     e5c <botlish_fn_17+0x38c>
     bd7:	jmp    bf0 <botlish_fn_17+0x120>
     bdc:	mov    eax,0x2
     be1:	mov    rcx,r14
     be4:	cmp    rcx,0x1
     be8:	cmove  rax,QWORD PTR [rip+0x390]        # f80 <botlish_fn_17+0x4b0>
     bf0:	mov    r12d,0x6
     bf6:	cmp    rax,0x6
     bfa:	je     ed4 <botlish_fn_17+0x404>
     c00:	mov    rdi,r15
     c03:	call   c08 <botlish_fn_17+0x138>
			c04: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     c08:	test   rax,rax
     c0b:	je     e5c <botlish_fn_17+0x38c>
     c11:	mov    rax,r14
     c14:	test   rax,0x1
     c1a:	jne    c3e <botlish_fn_17+0x16e>
     c20:	mov    edx,0x3
     c25:	mov    rsi,r14
     c28:	mov    rdi,r15
     c2b:	call   c30 <botlish_fn_17+0x160>
			c2c: R_X86_64_PLT32	rt_value_eq-0x4
     c30:	test   rax,rax
     c33:	je     e5c <botlish_fn_17+0x38c>
     c39:	jmp    c52 <botlish_fn_17+0x182>
     c3e:	mov    eax,0x2
     c43:	mov    rcx,r14
     c46:	cmp    rcx,0x3
     c4a:	cmove  rax,QWORD PTR [rip+0x32e]        # f80 <botlish_fn_17+0x4b0>
     c52:	cmp    rax,0x6
     c56:	je     c66 <botlish_fn_17+0x196>
     c5c:	mov    eax,0x2
     c61:	jmp    d2c <botlish_fn_17+0x25c>
     c66:	mov    rsi,rbx
     c69:	mov    rdi,r15
     c6c:	call   c71 <botlish_fn_17+0x1a1>
			c6d: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     c71:	test   rax,rax
     c74:	je     e5c <botlish_fn_17+0x38c>
     c7a:	xor    ecx,ecx
     c7c:	test   rax,0x7
     c82:	je     c90 <botlish_fn_17+0x1c0>
     c88:	mov    rsi,rax
     c8b:	jmp    c9e <botlish_fn_17+0x1ce>
     c90:	movzx  r8,BYTE PTR [rax]
     c94:	mov    rsi,rax
     c97:	cmp    r8b,0x8
     c9b:	sete   cl
     c9e:	test   cl,cl
     ca0:	jne    cc0 <botlish_fn_17+0x1f0>
     ca6:	mov    rdi,r15
     ca9:	mov    rax,QWORD PTR [rdi+0x10]
     cad:	mov    rcx,QWORD PTR [rax+0x8]
     cb1:	mov    edx,0x8
     cb6:	call   cbb <botlish_fn_17+0x1eb>
			cb7: R_X86_64_PLT32	rt_type_error-0x4
     cbb:	jmp    e5c <botlish_fn_17+0x38c>
     cc0:	mov    rdx,QWORD PTR [rsp+0x28]
     cc5:	mov    rdi,r15
     cc8:	call   ccd <botlish_fn_17+0x1fd>
			cc9: R_X86_64_PLT32	rt_mutarray_get-0x4
     ccd:	test   rax,rax
     cd0:	je     e5c <botlish_fn_17+0x38c>
     cd6:	mov    rcx,rax
     cd9:	and    rcx,r13
     cdc:	mov    rsi,rax
     cdf:	test   rcx,0x1
     ce6:	jne    d05 <botlish_fn_17+0x235>
     cec:	mov    rdx,r13
     cef:	mov    rdi,r15
     cf2:	call   cf7 <botlish_fn_17+0x227>
			cf3: R_X86_64_PLT32	rt_value_eq-0x4
     cf7:	test   rax,rax
     cfa:	je     e5c <botlish_fn_17+0x38c>
     d00:	jmp    d15 <botlish_fn_17+0x245>
     d05:	mov    eax,0x2
     d0a:	cmp    rsi,r13
     d0d:	cmove  rax,QWORD PTR [rip+0x26b]        # f80 <botlish_fn_17+0x4b0>
     d15:	cmp    rax,0x6
     d19:	je     d29 <botlish_fn_17+0x259>
     d1f:	mov    eax,0x2
     d24:	jmp    d2c <botlish_fn_17+0x25c>
     d29:	mov    rax,r12
     d2c:	cmp    rax,0x6
     d30:	je     ead <botlish_fn_17+0x3dd>
     d36:	mov    rdi,r15
     d39:	call   d3e <botlish_fn_17+0x26e>
			d3a: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
     d3e:	test   rax,rax
     d41:	je     e5c <botlish_fn_17+0x38c>
     d47:	mov    rax,r14
     d4a:	test   rax,0x1
     d50:	jne    d74 <botlish_fn_17+0x2a4>
     d56:	mov    edx,0x5
     d5b:	mov    rsi,r14
     d5e:	mov    rdi,r15
     d61:	call   d66 <botlish_fn_17+0x296>
			d62: R_X86_64_PLT32	rt_value_eq-0x4
     d66:	test   rax,rax
     d69:	je     e5c <botlish_fn_17+0x38c>
     d6f:	jmp    d88 <botlish_fn_17+0x2b8>
     d74:	mov    rsi,r14
     d77:	mov    eax,0x2
     d7c:	cmp    rsi,0x5
     d80:	cmove  rax,QWORD PTR [rip+0x1f8]        # f80 <botlish_fn_17+0x4b0>
     d88:	cmp    rax,0x6
     d8c:	je     d9d <botlish_fn_17+0x2cd>
     d92:	mov    r12d,0x2
     d98:	jmp    dfe <botlish_fn_17+0x32e>
     d9d:	mov    r14,QWORD PTR [rsp+0x30]
     da2:	test   r14,0x1
     da9:	jne    dd9 <botlish_fn_17+0x309>
     daf:	mov    edx,0x1
     db4:	mov    rsi,r14
     db7:	mov    rdi,r15
     dba:	call   dbf <botlish_fn_17+0x2ef>
			dbb: R_X86_64_PLT32	rt_int_cmp-0x4
     dbf:	mov    ecx,0x2
     dc4:	test   rax,rax
     dc7:	cmovl  rcx,QWORD PTR [rip+0x1b1]        # f80 <botlish_fn_17+0x4b0>
     dcf:	mov    QWORD PTR [rsp+0x30],r14
     dd4:	jmp    dee <botlish_fn_17+0x31e>
     dd9:	mov    ecx,0x2
     dde:	test   r14,r14
     de1:	mov    QWORD PTR [rsp+0x30],r14
     de6:	cmovle rcx,QWORD PTR [rip+0x192]        # f80 <botlish_fn_17+0x4b0>
     dee:	cmp    rcx,0x6
     df2:	je     dfe <botlish_fn_17+0x32e>
     df8:	mov    r12d,0x2
     dfe:	cmp    r12,0x6
     e02:	je     e43 <botlish_fn_17+0x373>
     e08:	mov    rdx,QWORD PTR [rsp+0x28]
     e0d:	mov    rsi,rbx
     e10:	mov    rdi,r15
     e13:	call   e18 <botlish_fn_17+0x348>
			e14: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     e18:	test   rax,rax
     e1b:	je     e5c <botlish_fn_17+0x38c>
     e21:	mov    QWORD PTR [rsp],rbx
     e25:	mov    QWORD PTR [rsp+0x8],r13
     e2a:	mov    QWORD PTR [rsp+0x10],rax
     e2f:	mov    rcx,QWORD PTR [rsp+0x30]
     e34:	mov    QWORD PTR [rsp+0x18],rcx
     e39:	mov    QWORD PTR [rsp+0x28],rax
     e3e:	jmp    b20 <botlish_fn_17+0x50>
     e43:	mov    rdx,QWORD PTR [rsp+0x28]
     e48:	mov    rsi,rbx
     e4b:	mov    rdi,r15
     e4e:	call   e53 <botlish_fn_17+0x383>
			e4f: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     e53:	test   rax,rax
     e56:	jne    e81 <botlish_fn_17+0x3b1>
     e5c:	xor    rax,rax
     e5f:	mov    rbx,QWORD PTR [rsp+0x40]
     e64:	mov    r12,QWORD PTR [rsp+0x48]
     e69:	mov    r13,QWORD PTR [rsp+0x50]
     e6e:	mov    r14,QWORD PTR [rsp+0x58]
     e73:	mov    r15,QWORD PTR [rsp+0x60]
     e78:	add    rsp,0x70
     e7c:	mov    rsp,rbp
     e7f:	pop    rbp
     e80:	ret
     e81:	mov    QWORD PTR [rsp],rbx
     e85:	mov    QWORD PTR [rsp+0x8],r13
     e8a:	mov    QWORD PTR [rsp+0x10],rax
     e8f:	mov    rdx,QWORD PTR [rsp+0x28]
     e94:	mov    QWORD PTR [rsp+0x18],rdx
     e99:	mov    rcx,QWORD PTR [rsp+0x28]
     e9e:	mov    QWORD PTR [rsp+0x30],rcx
     ea3:	mov    QWORD PTR [rsp+0x28],rax
     ea8:	jmp    b20 <botlish_fn_17+0x50>
     ead:	mov    rax,QWORD PTR [rsp+0x28]
     eb2:	mov    rbx,QWORD PTR [rsp+0x40]
     eb7:	mov    r12,QWORD PTR [rsp+0x48]
     ebc:	mov    r13,QWORD PTR [rsp+0x50]
     ec1:	mov    r14,QWORD PTR [rsp+0x58]
     ec6:	mov    r15,QWORD PTR [rsp+0x60]
     ecb:	add    rsp,0x70
     ecf:	mov    rsp,rbp
     ed2:	pop    rbp
     ed3:	ret
     ed4:	mov    rax,QWORD PTR [rsp+0x30]
     ed9:	test   rax,0x1
     edf:	jne    f0c <botlish_fn_17+0x43c>
     ee5:	mov    edx,0x1
     eea:	mov    rdi,r15
     eed:	mov    rsi,QWORD PTR [rsp+0x30]
     ef2:	call   ef7 <botlish_fn_17+0x427>
			ef3: R_X86_64_PLT32	rt_int_cmp-0x4
     ef7:	mov    esi,0x2
     efc:	test   rax,rax
     eff:	cmovge rsi,QWORD PTR [rip+0x79]        # f80 <botlish_fn_17+0x4b0>
     f07:	jmp    f26 <botlish_fn_17+0x456>
     f0c:	mov    esi,0x2
     f11:	mov    rax,QWORD PTR [rsp+0x30]
     f16:	mov    rcx,QWORD PTR [rsp+0x30]
     f1b:	test   rax,rcx
     f1e:	cmovg  rsi,QWORD PTR [rip+0x5a]        # f80 <botlish_fn_17+0x4b0>
     f26:	cmp    rsi,0x6
     f2a:	je     f57 <botlish_fn_17+0x487>
     f30:	mov    rax,QWORD PTR [rsp+0x28]
     f35:	mov    rbx,QWORD PTR [rsp+0x40]
     f3a:	mov    r12,QWORD PTR [rsp+0x48]
     f3f:	mov    r13,QWORD PTR [rsp+0x50]
     f44:	mov    r14,QWORD PTR [rsp+0x58]
     f49:	mov    r15,QWORD PTR [rsp+0x60]
     f4e:	add    rsp,0x70
     f52:	mov    rsp,rbp
     f55:	pop    rbp
     f56:	ret
     f57:	mov    rax,QWORD PTR [rsp+0x30]
     f5c:	mov    rbx,QWORD PTR [rsp+0x40]
     f61:	mov    r12,QWORD PTR [rsp+0x48]
     f66:	mov    r13,QWORD PTR [rsp+0x50]
     f6b:	mov    r14,QWORD PTR [rsp+0x58]
     f70:	mov    r15,QWORD PTR [rsp+0x60]
     f75:	add    rsp,0x70
     f79:	mov    rsp,rbp
     f7c:	pop    rbp
     f7d:	ret
     f7e:	add    BYTE PTR [rax],al
     f80:	(bad)
     f81:	add    BYTE PTR [rax],al
     f83:	add    BYTE PTR [rax],al
     f85:	add    BYTE PTR [rax],al
	...

0000000000000f88 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
     f88:	push   rbp
     f89:	mov    rbp,rsp
     f8c:	mov    rsi,QWORD PTR [rdx]
     f8f:	mov    r9,QWORD PTR [rdx+0x8]
     f93:	mov    rcx,QWORD PTR [rdx+0x10]
     f97:	mov    r8,QWORD PTR [rdx+0x18]
     f9b:	mov    rdx,r9
     f9e:	call   fa3 <botlish_entry_17+0x1b>
			f9f: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
     fa3:	mov    rsp,rbp
     fa6:	pop    rbp
     fa7:	ret

0000000000000fa8 <botlish_fn_18: ht_get<mutarray, str>>:
     fa8:	push   rbp
     fa9:	mov    rbp,rsp
     fac:	sub    rsp,0x40
     fb0:	mov    QWORD PTR [rsp+0x20],rbx
     fb5:	mov    QWORD PTR [rsp+0x28],r12
     fba:	mov    QWORD PTR [rsp+0x30],r13
     fbf:	mov    rbx,rdi
     fc2:	mov    QWORD PTR [rsp+0x10],0x0
     fcb:	mov    QWORD PTR [rsp],rsi
     fcf:	mov    r13,rsi
     fd2:	mov    QWORD PTR [rsp+0x8],rdx
     fd7:	mov    r12,rdx
     fda:	mov    rdx,r12
     fdd:	mov    rsi,r13
     fe0:	mov    rdi,rbx
     fe3:	call   fe8 <botlish_fn_18+0x40>
			fe4: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     fe8:	test   rax,rax
     feb:	je     10da <botlish_fn_18+0x132>
     ff1:	mov    QWORD PTR [rsp+0x10],rax
     ff6:	mov    rcx,rax
     ff9:	mov    rdx,r12
     ffc:	mov    rsi,r13
     fff:	mov    rdi,rbx
    1002:	call   1007 <botlish_fn_18+0x5f>
			1003: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1007:	mov    rcx,rax
    100a:	mov    r12,rax
    100d:	test   rax,rcx
    1010:	je     10da <botlish_fn_18+0x132>
    1016:	mov    rax,r12
    1019:	mov    QWORD PTR [rsp+0x8],rax
    101e:	test   rax,0x1
    1024:	jne    104f <botlish_fn_18+0xa7>
    102a:	mov    edx,0x1
    102f:	mov    rsi,r12
    1032:	mov    rdi,rbx
    1035:	call   103a <botlish_fn_18+0x92>
			1036: R_X86_64_PLT32	rt_int_cmp-0x4
    103a:	mov    ecx,0x2
    103f:	test   rax,rax
    1042:	cmovl  rcx,QWORD PTR [rip+0xe6]        # 1130 <botlish_fn_18+0x188>
    104a:	jmp    1062 <botlish_fn_18+0xba>
    104f:	mov    ecx,0x2
    1054:	mov    rax,r12
    1057:	test   rax,rax
    105a:	cmovle rcx,QWORD PTR [rip+0xce]        # 1130 <botlish_fn_18+0x188>
    1062:	cmp    rcx,0x6
    1066:	je     110d <botlish_fn_18+0x165>
    106c:	mov    rsi,r13
    106f:	mov    rdi,rbx
    1072:	call   1077 <botlish_fn_18+0xcf>
			1073: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    1077:	test   rax,rax
    107a:	je     10da <botlish_fn_18+0x132>
    1080:	xor    ecx,ecx
    1082:	test   rax,0x7
    1088:	je     1096 <botlish_fn_18+0xee>
    108e:	mov    rsi,rax
    1091:	jmp    10a4 <botlish_fn_18+0xfc>
    1096:	movzx  rcx,BYTE PTR [rax]
    109a:	mov    rsi,rax
    109d:	rex cmp cl,0x8
    10a1:	sete   cl
    10a4:	test   cl,cl
    10a6:	jne    10c6 <botlish_fn_18+0x11e>
    10ac:	mov    rdi,rbx
    10af:	mov    rax,QWORD PTR [rdi+0x10]
    10b3:	mov    rcx,QWORD PTR [rax+0x8]
    10b7:	mov    edx,0x8
    10bc:	call   10c1 <botlish_fn_18+0x119>
			10bd: R_X86_64_PLT32	rt_type_error-0x4
    10c1:	jmp    10da <botlish_fn_18+0x132>
    10c6:	mov    rdx,r12
    10c9:	mov    rdi,rbx
    10cc:	call   10d1 <botlish_fn_18+0x129>
			10cd: R_X86_64_PLT32	rt_mutarray_get-0x4
    10d1:	test   rax,rax
    10d4:	jne    10f5 <botlish_fn_18+0x14d>
    10da:	xor    rax,rax
    10dd:	mov    rbx,QWORD PTR [rsp+0x20]
    10e2:	mov    r12,QWORD PTR [rsp+0x28]
    10e7:	mov    r13,QWORD PTR [rsp+0x30]
    10ec:	add    rsp,0x40
    10f0:	mov    rsp,rbp
    10f3:	pop    rbp
    10f4:	ret
    10f5:	mov    rbx,QWORD PTR [rsp+0x20]
    10fa:	mov    r12,QWORD PTR [rsp+0x28]
    10ff:	mov    r13,QWORD PTR [rsp+0x30]
    1104:	add    rsp,0x40
    1108:	mov    rsp,rbp
    110b:	pop    rbp
    110c:	ret
    110d:	mov    eax,0xa
    1112:	mov    rbx,QWORD PTR [rsp+0x20]
    1117:	mov    r12,QWORD PTR [rsp+0x28]
    111c:	mov    r13,QWORD PTR [rsp+0x30]
    1121:	add    rsp,0x40
    1125:	mov    rsp,rbp
    1128:	pop    rbp
    1129:	ret
    112a:	add    BYTE PTR [rax],al
    112c:	add    BYTE PTR [rax],al
    112e:	add    BYTE PTR [rax],al
    1130:	(bad)
    1131:	add    BYTE PTR [rax],al
    1133:	add    BYTE PTR [rax],al
    1135:	add    BYTE PTR [rax],al
	...

0000000000001138 <botlish_entry_18: ht_get<mutarray, str>>:
    1138:	push   rbp
    1139:	mov    rbp,rsp
    113c:	mov    rsi,QWORD PTR [rdx]
    113f:	mov    rdx,QWORD PTR [rdx+0x8]
    1143:	call   1148 <botlish_entry_18+0x10>
			1144: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    1148:	mov    rsp,rbp
    114b:	pop    rbp
    114c:	ret
    114d:	add    BYTE PTR [rax],al
	...

0000000000001150 <botlish_fn_19: ht_contains<mutarray, str>>:
    1150:	push   rbp
    1151:	mov    rbp,rsp
    1154:	sub    rsp,0x40
    1158:	mov    QWORD PTR [rsp+0x20],rbx
    115d:	mov    QWORD PTR [rsp+0x28],r12
    1162:	mov    QWORD PTR [rsp+0x30],r15
    1167:	mov    r15,rdi
    116a:	mov    QWORD PTR [rsp+0x10],0x0
    1173:	mov    QWORD PTR [rsp],rsi
    1177:	mov    r12,rsi
    117a:	mov    QWORD PTR [rsp+0x8],rdx
    117f:	mov    rbx,rdx
    1182:	mov    rdx,rbx
    1185:	mov    rsi,r12
    1188:	mov    rdi,r15
    118b:	call   1190 <botlish_fn_19+0x40>
			118c: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    1190:	test   rax,rax
    1193:	je     11b8 <botlish_fn_19+0x68>
    1199:	mov    QWORD PTR [rsp+0x10],rax
    119e:	mov    rcx,rax
    11a1:	mov    rdx,rbx
    11a4:	mov    rsi,r12
    11a7:	mov    rdi,r15
    11aa:	call   11af <botlish_fn_19+0x5f>
			11ab: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    11af:	test   rax,rax
    11b2:	jne    11d3 <botlish_fn_19+0x83>
    11b8:	xor    rax,rax
    11bb:	mov    rbx,QWORD PTR [rsp+0x20]
    11c0:	mov    r12,QWORD PTR [rsp+0x28]
    11c5:	mov    r15,QWORD PTR [rsp+0x30]
    11ca:	add    rsp,0x40
    11ce:	mov    rsp,rbp
    11d1:	pop    rbp
    11d2:	ret
    11d3:	test   rax,0x1
    11d9:	mov    rsi,rax
    11dc:	jne    1207 <botlish_fn_19+0xb7>
    11e2:	mov    edx,0x1
    11e7:	mov    rdi,r15
    11ea:	call   11ef <botlish_fn_19+0x9f>
			11eb: R_X86_64_PLT32	rt_int_cmp-0x4
    11ef:	mov    ecx,0x2
    11f4:	test   rax,rax
    11f7:	mov    rax,rcx
    11fa:	cmovge rax,QWORD PTR [rip+0x2e]        # 1230 <botlish_fn_19+0xe0>
    1202:	jmp    1217 <botlish_fn_19+0xc7>
    1207:	mov    eax,0x2
    120c:	test   rsi,rsi
    120f:	cmovg  rax,QWORD PTR [rip+0x19]        # 1230 <botlish_fn_19+0xe0>
    1217:	mov    rbx,QWORD PTR [rsp+0x20]
    121c:	mov    r12,QWORD PTR [rsp+0x28]
    1221:	mov    r15,QWORD PTR [rsp+0x30]
    1226:	add    rsp,0x40
    122a:	mov    rsp,rbp
    122d:	pop    rbp
    122e:	ret
    122f:	add    BYTE PTR [rsi],al
    1231:	add    BYTE PTR [rax],al
    1233:	add    BYTE PTR [rax],al
    1235:	add    BYTE PTR [rax],al
	...

0000000000001238 <botlish_entry_19: ht_contains<mutarray, str>>:
    1238:	push   rbp
    1239:	mov    rbp,rsp
    123c:	mov    rsi,QWORD PTR [rdx]
    123f:	mov    rdx,QWORD PTR [rdx+0x8]
    1243:	call   1248 <botlish_entry_19+0x10>
			1244: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    1248:	mov    rsp,rbp
    124b:	pop    rbp
    124c:	ret
    124d:	add    BYTE PTR [rax],al
	...

0000000000001250 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    1250:	push   rbp
    1251:	mov    rbp,rsp
    1254:	sub    rsp,0x50
    1258:	mov    QWORD PTR [rsp+0x20],rbx
    125d:	mov    QWORD PTR [rsp+0x28],r12
    1262:	mov    QWORD PTR [rsp+0x30],r13
    1267:	mov    QWORD PTR [rsp+0x38],r14
    126c:	mov    QWORD PTR [rsp+0x40],r15
    1271:	mov    r13,rdi
    1274:	mov    QWORD PTR [rsp],rsi
    1278:	mov    QWORD PTR [rsp+0x8],rdx
    127d:	mov    QWORD PTR [rsp+0x10],rcx
    1282:	mov    r12,rcx
    1285:	mov    rbx,rsi
    1288:	mov    r14,rdx
    128b:	mov    rdx,r14
    128e:	mov    rsi,rbx
    1291:	mov    rdi,r13
    1294:	call   1299 <botlish_fn_20+0x49>
			1295: R_X86_64_PLT32	rt_mutarray_get-0x4
    1299:	test   rax,rax
    129c:	je     1358 <botlish_fn_20+0x108>
    12a2:	mov    QWORD PTR [rsp+0x18],rax
    12a7:	mov    r15,rax
    12aa:	mov    rdi,r13
    12ad:	call   12b2 <botlish_fn_20+0x62>
			12ae: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    12b2:	test   rax,rax
    12b5:	je     1358 <botlish_fn_20+0x108>
    12bb:	mov    rax,r15
    12be:	test   rax,0x1
    12c4:	jne    12e8 <botlish_fn_20+0x98>
    12ca:	mov    edx,0x1
    12cf:	mov    rsi,r15
    12d2:	mov    rdi,r13
    12d5:	call   12da <botlish_fn_20+0x8a>
			12d6: R_X86_64_PLT32	rt_value_eq-0x4
    12da:	test   rax,rax
    12dd:	je     1358 <botlish_fn_20+0x108>
    12e3:	jmp    12fc <botlish_fn_20+0xac>
    12e8:	mov    rsi,r15
    12eb:	mov    eax,0x2
    12f0:	cmp    rsi,0x1
    12f4:	cmove  rax,QWORD PTR [rip+0xbc]        # 13b8 <botlish_fn_20+0x168>
    12fc:	cmp    rax,0x6
    1300:	je     1393 <botlish_fn_20+0x143>
    1306:	mov    QWORD PTR [rsp+0x18],0x3
    130f:	mov    rsi,r14
    1312:	test   rsi,0x1
    1319:	je     1331 <botlish_fn_20+0xe1>
    131f:	mov    rsi,r14
    1322:	add    rsi,0x2
    1326:	seto   al
    1329:	test   al,al
    132b:	je     1344 <botlish_fn_20+0xf4>
    1331:	mov    edx,0x3
    1336:	mov    rsi,r14
    1339:	mov    rdi,r13
    133c:	call   1341 <botlish_fn_20+0xf1>
			133d: R_X86_64_PLT32	rt_int_add-0x4
    1341:	mov    rsi,rax
    1344:	mov    rdx,r12
    1347:	mov    rdi,r13
    134a:	call   134f <botlish_fn_20+0xff>
			134b: R_X86_64_PLT32	rt_int_mod-0x4
    134f:	test   rax,rax
    1352:	jne    137d <botlish_fn_20+0x12d>
    1358:	xor    rax,rax
    135b:	mov    rbx,QWORD PTR [rsp+0x20]
    1360:	mov    r12,QWORD PTR [rsp+0x28]
    1365:	mov    r13,QWORD PTR [rsp+0x30]
    136a:	mov    r14,QWORD PTR [rsp+0x38]
    136f:	mov    r15,QWORD PTR [rsp+0x40]
    1374:	add    rsp,0x50
    1378:	mov    rsp,rbp
    137b:	pop    rbp
    137c:	ret
    137d:	mov    QWORD PTR [rsp],rbx
    1381:	mov    QWORD PTR [rsp+0x8],rax
    1386:	mov    QWORD PTR [rsp+0x10],r12
    138b:	mov    r14,rax
    138e:	jmp    128b <botlish_fn_20+0x3b>
    1393:	mov    rax,r14
    1396:	mov    rbx,QWORD PTR [rsp+0x20]
    139b:	mov    r12,QWORD PTR [rsp+0x28]
    13a0:	mov    r13,QWORD PTR [rsp+0x30]
    13a5:	mov    r14,QWORD PTR [rsp+0x38]
    13aa:	mov    r15,QWORD PTR [rsp+0x40]
    13af:	add    rsp,0x50
    13b3:	mov    rsp,rbp
    13b6:	pop    rbp
    13b7:	ret
    13b8:	(bad)
    13b9:	add    BYTE PTR [rax],al
    13bb:	add    BYTE PTR [rax],al
    13bd:	add    BYTE PTR [rax],al
	...

00000000000013c0 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    13c0:	push   rbp
    13c1:	mov    rbp,rsp
    13c4:	mov    rsi,QWORD PTR [rdx]
    13c7:	mov    r8,QWORD PTR [rdx+0x8]
    13cb:	mov    rcx,QWORD PTR [rdx+0x10]
    13cf:	mov    rdx,r8
    13d2:	call   13d7 <botlish_entry_20+0x17>
			13d3: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    13d7:	mov    rsp,rbp
    13da:	pop    rbp
    13db:	ret

00000000000013dc <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    13dc:	push   rbp
    13dd:	mov    rbp,rsp
    13e0:	sub    rsp,0x80
    13e7:	mov    QWORD PTR [rsp+0x50],rbx
    13ec:	mov    QWORD PTR [rsp+0x58],r12
    13f1:	mov    QWORD PTR [rsp+0x60],r13
    13f6:	mov    QWORD PTR [rsp+0x68],r14
    13fb:	mov    QWORD PTR [rsp+0x70],r15
    1400:	mov    r12,rdi
    1403:	mov    rdi,QWORD PTR [rbp+0x10]
    1407:	mov    QWORD PTR [rsp],rsi
    140b:	mov    QWORD PTR [rsp+0x38],rsi
    1410:	mov    QWORD PTR [rsp+0x8],rdx
    1415:	mov    r15,rdx
    1418:	mov    QWORD PTR [rsp+0x10],rcx
    141d:	mov    rbx,rcx
    1420:	mov    QWORD PTR [rsp+0x18],r8
    1425:	mov    QWORD PTR [rsp+0x40],r8
    142a:	mov    QWORD PTR [rsp+0x20],r9
    142f:	mov    r14,r9
    1432:	mov    QWORD PTR [rsp+0x28],rdi
    1437:	mov    r13,rdi
    143a:	mov    rsi,r14
    143d:	mov    rdi,r12
    1440:	call   1445 <botlish_fn_21+0x69>
			1441: R_X86_64_PLT32	rt_hash-0x4
    1445:	test   rax,rax
    1448:	mov    rsi,rax
    144b:	je     14fd <botlish_fn_21+0x121>
    1451:	mov    rdx,QWORD PTR [rsp+0x40]
    1456:	mov    rdi,r12
    1459:	call   145e <botlish_fn_21+0x82>
			145a: R_X86_64_PLT32	rt_int_mod-0x4
    145e:	test   rax,rax
    1461:	je     14fd <botlish_fn_21+0x121>
    1467:	mov    QWORD PTR [rsp+0x30],rax
    146c:	mov    rcx,QWORD PTR [rsp+0x40]
    1471:	mov    rdx,rax
    1474:	mov    rsi,QWORD PTR [rsp+0x38]
    1479:	mov    rdi,r12
    147c:	call   1481 <botlish_fn_21+0xa5>
			147d: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1481:	test   rax,rax
    1484:	je     14fd <botlish_fn_21+0x121>
    148a:	mov    QWORD PTR [rsp+0x18],rax
    148f:	mov    QWORD PTR [rsp+0x40],rax
    1494:	mov    rdi,r12
    1497:	call   149c <botlish_fn_21+0xc0>
			1498: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    149c:	test   rax,rax
    149f:	je     14fd <botlish_fn_21+0x121>
    14a5:	mov    ecx,0x3
    14aa:	mov    rsi,QWORD PTR [rsp+0x38]
    14af:	mov    rdx,QWORD PTR [rsp+0x40]
    14b4:	mov    rdi,r12
    14b7:	call   14bc <botlish_fn_21+0xe0>
			14b8: R_X86_64_PLT32	rt_mutarray_set-0x4
    14bc:	test   rax,rax
    14bf:	je     14fd <botlish_fn_21+0x121>
    14c5:	mov    rcx,r14
    14c8:	mov    rsi,r15
    14cb:	mov    rdx,QWORD PTR [rsp+0x40]
    14d0:	mov    rdi,r12
    14d3:	call   14d8 <botlish_fn_21+0xfc>
			14d4: R_X86_64_PLT32	rt_mutarray_set-0x4
    14d8:	test   rax,rax
    14db:	je     14fd <botlish_fn_21+0x121>
    14e1:	mov    rcx,r13
    14e4:	mov    rdx,QWORD PTR [rsp+0x40]
    14e9:	mov    rsi,rbx
    14ec:	mov    rdi,r12
    14ef:	call   14f4 <botlish_fn_21+0x118>
			14f0: R_X86_64_PLT32	rt_mutarray_set-0x4
    14f4:	test   rax,rax
    14f7:	jne    1525 <botlish_fn_21+0x149>
    14fd:	xor    rax,rax
    1500:	mov    rbx,QWORD PTR [rsp+0x50]
    1505:	mov    r12,QWORD PTR [rsp+0x58]
    150a:	mov    r13,QWORD PTR [rsp+0x60]
    150f:	mov    r14,QWORD PTR [rsp+0x68]
    1514:	mov    r15,QWORD PTR [rsp+0x70]
    1519:	add    rsp,0x80
    1520:	mov    rsp,rbp
    1523:	pop    rbp
    1524:	ret
    1525:	mov    eax,0xa
    152a:	mov    rbx,QWORD PTR [rsp+0x50]
    152f:	mov    r12,QWORD PTR [rsp+0x58]
    1534:	mov    r13,QWORD PTR [rsp+0x60]
    1539:	mov    r14,QWORD PTR [rsp+0x68]
    153e:	mov    r15,QWORD PTR [rsp+0x70]
    1543:	add    rsp,0x80
    154a:	mov    rsp,rbp
    154d:	pop    rbp
    154e:	ret

000000000000154f <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    154f:	push   rbp
    1550:	mov    rbp,rsp
    1553:	sub    rsp,0x10
    1557:	mov    rsi,QWORD PTR [rdx]
    155a:	mov    r10,QWORD PTR [rdx+0x8]
    155e:	mov    rcx,QWORD PTR [rdx+0x10]
    1562:	mov    r8,QWORD PTR [rdx+0x18]
    1566:	mov    r9,QWORD PTR [rdx+0x20]
    156a:	mov    r11,QWORD PTR [rdx+0x28]
    156e:	mov    QWORD PTR [rsp],r11
    1572:	mov    rdx,r10
    1575:	call   157a <botlish_entry_21+0x2b>
			1576: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    157a:	add    rsp,0x10
    157e:	mov    rsp,rbp
    1581:	pop    rbp
    1582:	ret
    1583:	add    BYTE PTR [rax],al
    1585:	add    BYTE PTR [rax],al
	...

0000000000001588 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1588:	push   rbp
    1589:	mov    rbp,rsp
    158c:	sub    rsp,0xc0
    1593:	mov    QWORD PTR [rsp+0x90],rbx
    159b:	mov    QWORD PTR [rsp+0x98],r12
    15a3:	mov    QWORD PTR [rsp+0xa0],r13
    15ab:	mov    QWORD PTR [rsp+0xa8],r14
    15b3:	mov    QWORD PTR [rsp+0xb0],r15
    15bb:	mov    QWORD PTR [rsp+0x60],rdi
    15c0:	mov    QWORD PTR [rsp+0x80],r9
    15c8:	mov    r12,QWORD PTR [rbp+0x10]
    15cc:	mov    r13,QWORD PTR [rbp+0x18]
    15d0:	mov    r14,QWORD PTR [rbp+0x20]
    15d4:	mov    rdi,QWORD PTR [rbp+0x28]
    15d8:	mov    QWORD PTR [rsp+0x58],0x0
    15e1:	mov    QWORD PTR [rsp+0x10],rsi
    15e6:	mov    QWORD PTR [rsp+0x68],rsi
    15eb:	mov    QWORD PTR [rsp+0x18],rdx
    15f0:	mov    QWORD PTR [rsp+0x70],rdx
    15f5:	mov    QWORD PTR [rsp+0x20],rcx
    15fa:	mov    QWORD PTR [rsp+0x78],rcx
    15ff:	mov    QWORD PTR [rsp+0x28],r8
    1604:	mov    rax,r12
    1607:	mov    QWORD PTR [rsp+0x30],rax
    160c:	mov    QWORD PTR [rsp+0x38],r13
    1611:	mov    QWORD PTR [rsp+0x40],r14
    1616:	mov    QWORD PTR [rsp+0x48],rdi
    161b:	mov    QWORD PTR [rsp+0x88],rdi
    1623:	mov    rsi,QWORD PTR [rsp+0x80]
    162b:	mov    rax,rsi
    162e:	or     rax,0x1
    1632:	mov    r15,r8
    1635:	mov    rcx,r15
    1638:	and    rcx,rax
    163b:	test   rcx,0x1
    1642:	jne    1679 <botlish_fn_22+0xf1>
    1648:	mov    rdx,rsi
    164b:	or     rdx,0x1
    164f:	mov    QWORD PTR [rsp+0x80],rsi
    1657:	mov    rsi,r15
    165a:	mov    rdi,QWORD PTR [rsp+0x60]
    165f:	call   1664 <botlish_fn_22+0xdc>
			1660: R_X86_64_PLT32	rt_int_cmp-0x4
    1664:	mov    ecx,0x2
    1669:	test   rax,rax
    166c:	cmovge rcx,QWORD PTR [rip+0x304]        # 1978 <botlish_fn_22+0x3f0>
    1674:	jmp    169b <botlish_fn_22+0x113>
    1679:	mov    rdi,rsi
    167c:	mov    QWORD PTR [rsp+0x80],rsi
    1684:	mov    rax,rdi
    1687:	or     rax,0x1
    168b:	mov    ecx,0x2
    1690:	cmp    r15,rax
    1693:	cmovge rcx,QWORD PTR [rip+0x2dd]        # 1978 <botlish_fn_22+0x3f0>
    169b:	cmp    rcx,0x6
    169f:	je     1939 <botlish_fn_22+0x3b1>
    16a5:	xor    eax,eax
    16a7:	mov    rsi,QWORD PTR [rsp+0x68]
    16ac:	test   rsi,0x7
    16b3:	jne    16c2 <botlish_fn_22+0x13a>
    16b9:	movzx  rax,BYTE PTR [rsi]
    16bd:	cmp    al,0x8
    16bf:	sete   al
    16c2:	test   al,al
    16c4:	jne    16e6 <botlish_fn_22+0x15e>
    16ca:	mov    rdi,QWORD PTR [rsp+0x60]
    16cf:	mov    rax,QWORD PTR [rdi+0x10]
    16d3:	mov    rcx,QWORD PTR [rax+0x8]
    16d7:	mov    edx,0x8
    16dc:	call   16e1 <botlish_fn_22+0x159>
			16dd: R_X86_64_PLT32	rt_type_error-0x4
    16e1:	jmp    189d <botlish_fn_22+0x315>
    16e6:	mov    QWORD PTR [rsp+0x68],rsi
    16eb:	mov    rdx,r15
    16ee:	mov    rdi,QWORD PTR [rsp+0x60]
    16f3:	call   16f8 <botlish_fn_22+0x170>
			16f4: R_X86_64_PLT32	rt_mutarray_get-0x4
    16f8:	test   rax,rax
    16fb:	je     189d <botlish_fn_22+0x315>
    1701:	mov    QWORD PTR [rsp+0x50],rax
    1706:	mov    rbx,rax
    1709:	mov    rdi,QWORD PTR [rsp+0x60]
    170e:	call   1713 <botlish_fn_22+0x18b>
			170f: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1713:	test   rax,rax
    1716:	je     189d <botlish_fn_22+0x315>
    171c:	mov    rax,rbx
    171f:	test   rax,0x1
    1725:	jne    174b <botlish_fn_22+0x1c3>
    172b:	mov    edx,0x3
    1730:	mov    rsi,rbx
    1733:	mov    rdi,QWORD PTR [rsp+0x60]
    1738:	call   173d <botlish_fn_22+0x1b5>
			1739: R_X86_64_PLT32	rt_value_eq-0x4
    173d:	test   rax,rax
    1740:	je     189d <botlish_fn_22+0x315>
    1746:	jmp    175f <botlish_fn_22+0x1d7>
    174b:	mov    rsi,rbx
    174e:	mov    eax,0x2
    1753:	cmp    rsi,0x3
    1757:	cmove  rax,QWORD PTR [rip+0x219]        # 1978 <botlish_fn_22+0x3f0>
    175f:	cmp    rax,0x6
    1763:	je     177b <botlish_fn_22+0x1f3>
    1769:	mov    rbx,QWORD PTR [rsp+0x88]
    1771:	mov    rsi,QWORD PTR [rsp+0x68]
    1776:	jmp    18d9 <botlish_fn_22+0x351>
    177b:	xor    eax,eax
    177d:	mov    rdx,QWORD PTR [rsp+0x70]
    1782:	test   rdx,0x7
    1789:	je     1799 <botlish_fn_22+0x211>
    178f:	mov    QWORD PTR [rsp+0x70],rdx
    1794:	jmp    17a7 <botlish_fn_22+0x21f>
    1799:	movzx  rax,BYTE PTR [rdx]
    179d:	mov    QWORD PTR [rsp+0x70],rdx
    17a2:	cmp    al,0x8
    17a4:	sete   al
    17a7:	test   al,al
    17a9:	jne    17d0 <botlish_fn_22+0x248>
    17af:	mov    rdi,QWORD PTR [rsp+0x60]
    17b4:	mov    rax,QWORD PTR [rdi+0x10]
    17b8:	mov    rcx,QWORD PTR [rax+0x8]
    17bc:	mov    edx,0x8
    17c1:	mov    rsi,QWORD PTR [rsp+0x70]
    17c6:	call   17cb <botlish_fn_22+0x243>
			17c7: R_X86_64_PLT32	rt_type_error-0x4
    17cb:	jmp    189d <botlish_fn_22+0x315>
    17d0:	mov    rdx,r15
    17d3:	mov    rsi,QWORD PTR [rsp+0x70]
    17d8:	mov    rdi,QWORD PTR [rsp+0x60]
    17dd:	call   17e2 <botlish_fn_22+0x25a>
			17de: R_X86_64_PLT32	rt_mutarray_get-0x4
    17e2:	test   rax,rax
    17e5:	je     189d <botlish_fn_22+0x315>
    17eb:	mov    QWORD PTR [rsp+0x50],rax
    17f0:	mov    rbx,rax
    17f3:	xor    eax,eax
    17f5:	mov    rcx,QWORD PTR [rsp+0x78]
    17fa:	test   rcx,0x7
    1801:	je     1811 <botlish_fn_22+0x289>
    1807:	mov    QWORD PTR [rsp+0x78],rcx
    180c:	jmp    1821 <botlish_fn_22+0x299>
    1811:	movzx  rsi,BYTE PTR [rcx]
    1815:	mov    QWORD PTR [rsp+0x78],rcx
    181a:	cmp    sil,0x8
    181e:	sete   al
    1821:	test   al,al
    1823:	jne    184f <botlish_fn_22+0x2c7>
    1829:	mov    rdi,QWORD PTR [rsp+0x60]
    182e:	mov    rdi,QWORD PTR [rdi+0x10]
    1832:	mov    rcx,QWORD PTR [rdi+0x8]
    1836:	mov    edx,0x8
    183b:	mov    rsi,QWORD PTR [rsp+0x78]
    1840:	mov    rdi,QWORD PTR [rsp+0x60]
    1845:	call   184a <botlish_fn_22+0x2c2>
			1846: R_X86_64_PLT32	rt_type_error-0x4
    184a:	jmp    189d <botlish_fn_22+0x315>
    184f:	mov    rdx,r15
    1852:	mov    rsi,QWORD PTR [rsp+0x78]
    1857:	mov    rdi,QWORD PTR [rsp+0x60]
    185c:	call   1861 <botlish_fn_22+0x2d9>
			185d: R_X86_64_PLT32	rt_mutarray_get-0x4
    1861:	test   rax,rax
    1864:	je     189d <botlish_fn_22+0x315>
    186a:	mov    QWORD PTR [rsp+0x58],rax
    186f:	mov    QWORD PTR [rsp],rax
    1873:	mov    r9,rbx
    1876:	mov    rbx,QWORD PTR [rsp+0x88]
    187e:	mov    rcx,r14
    1881:	mov    rdx,r13
    1884:	mov    rsi,r12
    1887:	mov    rdi,QWORD PTR [rsp+0x60]
    188c:	mov    r8,rbx
    188f:	call   1894 <botlish_fn_22+0x30c>
			1890: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    1894:	test   rax,rax
    1897:	jne    18d4 <botlish_fn_22+0x34c>
    189d:	xor    rax,rax
    18a0:	mov    rbx,QWORD PTR [rsp+0x90]
    18a8:	mov    r12,QWORD PTR [rsp+0x98]
    18b0:	mov    r13,QWORD PTR [rsp+0xa0]
    18b8:	mov    r14,QWORD PTR [rsp+0xa8]
    18c0:	mov    r15,QWORD PTR [rsp+0xb0]
    18c8:	add    rsp,0xc0
    18cf:	mov    rsp,rbp
    18d2:	pop    rbp
    18d3:	ret
    18d4:	mov    rsi,QWORD PTR [rsp+0x68]
    18d9:	mov    rsi,QWORD PTR [rsp+0x68]
    18de:	mov    QWORD PTR [rsp+0x10],rsi
    18e3:	mov    rsi,QWORD PTR [rsp+0x70]
    18e8:	mov    QWORD PTR [rsp+0x18],rsi
    18ed:	mov    rsi,QWORD PTR [rsp+0x78]
    18f2:	mov    QWORD PTR [rsp+0x20],rsi
    18f7:	sar    r15,1
    18fa:	add    r15,0x1
    1901:	shl    r15,1
    1904:	or     r15,0x1
    1908:	mov    QWORD PTR [rsp+0x28],r15
    190d:	mov    QWORD PTR [rsp+0x30],r12
    1912:	mov    QWORD PTR [rsp+0x38],r13
    1917:	mov    QWORD PTR [rsp+0x40],r14
    191c:	mov    QWORD PTR [rsp+0x48],rbx
    1921:	mov    rsi,QWORD PTR [rsp+0x80]
    1929:	mov    r8,r15
    192c:	mov    QWORD PTR [rsp+0x88],rbx
    1934:	jmp    162b <botlish_fn_22+0xa3>
    1939:	mov    eax,0xa
    193e:	mov    rbx,QWORD PTR [rsp+0x90]
    1946:	mov    r12,QWORD PTR [rsp+0x98]
    194e:	mov    r13,QWORD PTR [rsp+0xa0]
    1956:	mov    r14,QWORD PTR [rsp+0xa8]
    195e:	mov    r15,QWORD PTR [rsp+0xb0]
    1966:	add    rsp,0xc0
    196d:	mov    rsp,rbp
    1970:	pop    rbp
    1971:	ret
    1972:	add    BYTE PTR [rax],al
    1974:	add    BYTE PTR [rax],al
    1976:	add    BYTE PTR [rax],al
    1978:	(bad)
    1979:	add    BYTE PTR [rax],al
    197b:	add    BYTE PTR [rax],al
    197d:	add    BYTE PTR [rax],al
	...

0000000000001980 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1980:	push   rbp
    1981:	mov    rbp,rsp
    1984:	sub    rsp,0x30
    1988:	mov    QWORD PTR [rsp+0x20],r12
    198d:	mov    rsi,QWORD PTR [rdx]
    1990:	mov    rax,QWORD PTR [rdx+0x8]
    1994:	mov    rcx,QWORD PTR [rdx+0x10]
    1998:	mov    r8,QWORD PTR [rdx+0x18]
    199c:	mov    r9,QWORD PTR [rdx+0x20]
    19a0:	mov    r10,QWORD PTR [rdx+0x28]
    19a4:	mov    r11,QWORD PTR [rdx+0x30]
    19a8:	mov    r12,QWORD PTR [rdx+0x38]
    19ac:	mov    rdx,QWORD PTR [rdx+0x40]
    19b0:	mov    QWORD PTR [rsp],r10
    19b4:	mov    QWORD PTR [rsp+0x8],r11
    19b9:	mov    QWORD PTR [rsp+0x10],r12
    19be:	mov    QWORD PTR [rsp+0x18],rdx
    19c3:	mov    rdx,rax
    19c6:	call   19cb <botlish_entry_22+0x4b>
			19c7: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    19cb:	mov    r12,QWORD PTR [rsp+0x20]
    19d0:	add    rsp,0x30
    19d4:	mov    rsp,rbp
    19d7:	pop    rbp
    19d8:	ret

00000000000019d9 <botlish_fn_23: ht_rehash<mutarray, int>>:
    19d9:	push   rbp
    19da:	mov    rbp,rsp
    19dd:	sub    rsp,0xd0
    19e4:	mov    QWORD PTR [rsp+0xa0],rbx
    19ec:	mov    QWORD PTR [rsp+0xa8],r12
    19f4:	mov    QWORD PTR [rsp+0xb0],r13
    19fc:	mov    QWORD PTR [rsp+0xb8],r14
    1a04:	mov    QWORD PTR [rsp+0xc0],r15
    1a0c:	mov    r13,rdi
    1a0f:	mov    QWORD PTR [rsp+0x30],0x0
    1a18:	mov    QWORD PTR [rsp+0x38],0x0
    1a21:	mov    QWORD PTR [rsp+0x40],0x0
    1a2a:	mov    QWORD PTR [rsp+0x48],0x0
    1a33:	mov    QWORD PTR [rsp+0x50],0x0
    1a3c:	mov    QWORD PTR [rsp+0x58],0x0
    1a45:	mov    QWORD PTR [rsp+0x60],0x0
    1a4e:	mov    QWORD PTR [rsp+0x68],0x0
    1a57:	mov    QWORD PTR [rsp+0x20],rsi
    1a5c:	mov    r12,rsi
    1a5f:	mov    QWORD PTR [rsp+0x28],rdx
    1a64:	mov    rbx,rdx
    1a67:	mov    rsi,r12
    1a6a:	mov    rdi,r13
    1a6d:	call   1a72 <botlish_fn_23+0x99>
			1a6e: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    1a72:	test   rax,rax
    1a75:	je     1c44 <botlish_fn_23+0x26b>
    1a7b:	mov    QWORD PTR [rsp+0x30],rax
    1a80:	mov    r14,rax
    1a83:	mov    rsi,r12
    1a86:	mov    rdi,r13
    1a89:	call   1a8e <botlish_fn_23+0xb5>
			1a8a: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    1a8e:	test   rax,rax
    1a91:	je     1c44 <botlish_fn_23+0x26b>
    1a97:	mov    QWORD PTR [rsp+0x38],rax
    1a9c:	mov    r15,rax
    1a9f:	mov    rsi,r12
    1aa2:	mov    rdi,r13
    1aa5:	call   1aaa <botlish_fn_23+0xd1>
			1aa6: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    1aaa:	test   rax,rax
    1aad:	je     1c44 <botlish_fn_23+0x26b>
    1ab3:	mov    QWORD PTR [rsp+0x40],rax
    1ab8:	mov    QWORD PTR [rsp+0x90],rax
    1ac0:	mov    rsi,r12
    1ac3:	mov    rdi,r13
    1ac6:	call   1acb <botlish_fn_23+0xf2>
			1ac7: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    1acb:	test   rax,rax
    1ace:	je     1c44 <botlish_fn_23+0x26b>
    1ad4:	mov    QWORD PTR [rsp+0x48],rax
    1ad9:	mov    QWORD PTR [rsp+0x88],rax
    1ae1:	mov    rsi,rbx
    1ae4:	mov    rdi,r13
    1ae7:	call   1aec <botlish_fn_23+0x113>
			1ae8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1aec:	mov    rcx,rax
    1aef:	mov    QWORD PTR [rsp+0x80],rax
    1af7:	test   rax,rcx
    1afa:	je     1c44 <botlish_fn_23+0x26b>
    1b00:	mov    rax,QWORD PTR [rsp+0x80]
    1b08:	mov    QWORD PTR [rsp+0x50],rax
    1b0d:	mov    edx,0x1
    1b12:	mov    QWORD PTR [rsp+0x58],0x1
    1b1b:	mov    rcx,rbx
    1b1e:	mov    rsi,QWORD PTR [rsp+0x80]
    1b26:	mov    rdi,r13
    1b29:	call   1b2e <botlish_fn_23+0x155>
			1b2a: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    1b2e:	test   rax,rax
    1b31:	je     1c44 <botlish_fn_23+0x26b>
    1b37:	mov    rsi,rbx
    1b3a:	mov    rdi,r13
    1b3d:	call   1b42 <botlish_fn_23+0x169>
			1b3e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b42:	test   rax,rax
    1b45:	je     1c44 <botlish_fn_23+0x26b>
    1b4b:	mov    QWORD PTR [rsp+0x58],rax
    1b50:	mov    QWORD PTR [rsp+0x78],rax
    1b55:	mov    rsi,rbx
    1b58:	mov    rdi,r13
    1b5b:	call   1b60 <botlish_fn_23+0x187>
			1b5c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b60:	test   rax,rax
    1b63:	je     1c44 <botlish_fn_23+0x26b>
    1b69:	mov    QWORD PTR [rsp+0x60],rax
    1b6e:	mov    r8d,0x1
    1b74:	mov    QWORD PTR [rsp+0x68],0x1
    1b7d:	mov    rcx,QWORD PTR [rsp+0x80]
    1b85:	mov    QWORD PTR [rsp],rcx
    1b89:	mov    rcx,QWORD PTR [rsp+0x78]
    1b8e:	mov    QWORD PTR [rsp+0x8],rcx
    1b93:	mov    QWORD PTR [rsp+0x10],rax
    1b98:	mov    QWORD PTR [rsp+0x70],rax
    1b9d:	mov    QWORD PTR [rsp+0x18],rbx
    1ba2:	mov    rcx,QWORD PTR [rsp+0x90]
    1baa:	mov    rdx,r15
    1bad:	mov    rsi,r14
    1bb0:	mov    r9,QWORD PTR [rsp+0x88]
    1bb8:	mov    rdi,r13
    1bbb:	call   1bc0 <botlish_fn_23+0x1e7>
			1bbc: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    1bc0:	test   rax,rax
    1bc3:	je     1c44 <botlish_fn_23+0x26b>
    1bc9:	mov    edx,0x1
    1bce:	mov    rcx,QWORD PTR [rsp+0x80]
    1bd6:	mov    rsi,r12
    1bd9:	mov    rdi,r13
    1bdc:	call   1be1 <botlish_fn_23+0x208>
			1bdd: R_X86_64_PLT32	rt_mutarray_set-0x4
    1be1:	test   rax,rax
    1be4:	je     1c44 <botlish_fn_23+0x26b>
    1bea:	mov    edx,0x3
    1bef:	mov    rcx,QWORD PTR [rsp+0x78]
    1bf4:	mov    rsi,r12
    1bf7:	mov    rdi,r13
    1bfa:	call   1bff <botlish_fn_23+0x226>
			1bfb: R_X86_64_PLT32	rt_mutarray_set-0x4
    1bff:	test   rax,rax
    1c02:	je     1c44 <botlish_fn_23+0x26b>
    1c08:	mov    edx,0x5
    1c0d:	mov    rcx,QWORD PTR [rsp+0x70]
    1c12:	mov    rsi,r12
    1c15:	mov    rdi,r13
    1c18:	call   1c1d <botlish_fn_23+0x244>
			1c19: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c1d:	test   rax,rax
    1c20:	je     1c44 <botlish_fn_23+0x26b>
    1c26:	mov    edx,0x9
    1c2b:	mov    ecx,0x1
    1c30:	mov    rsi,r12
    1c33:	mov    rdi,r13
    1c36:	call   1c3b <botlish_fn_23+0x262>
			1c37: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c3b:	test   rax,rax
    1c3e:	jne    1c7b <botlish_fn_23+0x2a2>
    1c44:	xor    rax,rax
    1c47:	mov    rbx,QWORD PTR [rsp+0xa0]
    1c4f:	mov    r12,QWORD PTR [rsp+0xa8]
    1c57:	mov    r13,QWORD PTR [rsp+0xb0]
    1c5f:	mov    r14,QWORD PTR [rsp+0xb8]
    1c67:	mov    r15,QWORD PTR [rsp+0xc0]
    1c6f:	add    rsp,0xd0
    1c76:	mov    rsp,rbp
    1c79:	pop    rbp
    1c7a:	ret
    1c7b:	mov    eax,0xa
    1c80:	mov    rbx,QWORD PTR [rsp+0xa0]
    1c88:	mov    r12,QWORD PTR [rsp+0xa8]
    1c90:	mov    r13,QWORD PTR [rsp+0xb0]
    1c98:	mov    r14,QWORD PTR [rsp+0xb8]
    1ca0:	mov    r15,QWORD PTR [rsp+0xc0]
    1ca8:	add    rsp,0xd0
    1caf:	mov    rsp,rbp
    1cb2:	pop    rbp
    1cb3:	ret

0000000000001cb4 <botlish_entry_23: ht_rehash<mutarray, int>>:
    1cb4:	push   rbp
    1cb5:	mov    rbp,rsp
    1cb8:	mov    rsi,QWORD PTR [rdx]
    1cbb:	mov    rdx,QWORD PTR [rdx+0x8]
    1cbf:	call   1cc4 <botlish_entry_23+0x10>
			1cc0: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    1cc4:	mov    rsp,rbp
    1cc7:	pop    rbp
    1cc8:	ret
    1cc9:	add    BYTE PTR [rax],al
    1ccb:	add    BYTE PTR [rax],al
    1ccd:	add    BYTE PTR [rax],al
	...

0000000000001cd0 <botlish_fn_24: ht_should_grow<mutarray>>:
    1cd0:	push   rbp
    1cd1:	mov    rbp,rsp
    1cd4:	sub    rsp,0x40
    1cd8:	mov    QWORD PTR [rsp+0x20],rbx
    1cdd:	mov    QWORD PTR [rsp+0x28],r12
    1ce2:	mov    QWORD PTR [rsp+0x30],r13
    1ce7:	mov    rbx,rdi
    1cea:	mov    QWORD PTR [rsp+0x8],0x0
    1cf3:	mov    QWORD PTR [rsp+0x10],0x0
    1cfc:	mov    QWORD PTR [rsp],rsi
    1d00:	mov    r12,rsi
    1d03:	mov    rsi,r12
    1d06:	mov    rdi,rbx
    1d09:	call   1d0e <botlish_fn_24+0x3e>
			1d0a: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    1d0e:	mov    rcx,rax
    1d11:	mov    r13,rax
    1d14:	test   rax,rcx
    1d17:	je     1f07 <botlish_fn_24+0x237>
    1d1d:	mov    rax,r13
    1d20:	mov    QWORD PTR [rsp+0x8],rax
    1d25:	mov    rsi,r12
    1d28:	mov    rdi,rbx
    1d2b:	call   1d30 <botlish_fn_24+0x60>
			1d2c: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    1d30:	mov    rcx,rax
    1d33:	test   rcx,rcx
    1d36:	je     1f07 <botlish_fn_24+0x237>
    1d3c:	mov    QWORD PTR [rsp+0x10],rcx
    1d41:	mov    edx,0x1
    1d46:	mov    rax,r13
    1d49:	test   rax,0x1
    1d4f:	jne    1d72 <botlish_fn_24+0xa2>
    1d55:	xor    edx,edx
    1d57:	mov    rax,r13
    1d5a:	test   rax,0x7
    1d60:	jne    1d72 <botlish_fn_24+0xa2>
    1d66:	mov    rax,r13
    1d69:	movzx  rax,BYTE PTR [rax]
    1d6d:	cmp    al,0x1
    1d6f:	sete   dl
    1d72:	test   dl,dl
    1d74:	jne    1d95 <botlish_fn_24+0xc5>
    1d7a:	mov    rdi,rbx
    1d7d:	mov    rax,QWORD PTR [rdi+0x10]
    1d81:	mov    rcx,QWORD PTR [rax+0x10]
    1d85:	xor    rdx,rdx
    1d88:	mov    rsi,r13
    1d8b:	call   1d90 <botlish_fn_24+0xc0>
			1d8c: R_X86_64_PLT32	rt_type_error-0x4
    1d90:	jmp    1f07 <botlish_fn_24+0x237>
    1d95:	mov    eax,0x1
    1d9a:	test   rcx,0x1
    1da1:	je     1daf <botlish_fn_24+0xdf>
    1da7:	mov    r8,rcx
    1daa:	jmp    1dd2 <botlish_fn_24+0x102>
    1daf:	xor    eax,eax
    1db1:	test   rcx,0x7
    1db8:	je     1dc6 <botlish_fn_24+0xf6>
    1dbe:	mov    r8,rcx
    1dc1:	jmp    1dd2 <botlish_fn_24+0x102>
    1dc6:	movzx  rax,BYTE PTR [rcx]
    1dca:	mov    r8,rcx
    1dcd:	cmp    al,0x1
    1dcf:	sete   al
    1dd2:	test   al,al
    1dd4:	jne    1df5 <botlish_fn_24+0x125>
    1dda:	mov    rdi,rbx
    1ddd:	mov    rax,QWORD PTR [rdi+0x10]
    1de1:	mov    rcx,QWORD PTR [rax+0x10]
    1de5:	xor    rdx,rdx
    1de8:	mov    rsi,r8
    1deb:	call   1df0 <botlish_fn_24+0x120>
			1dec: R_X86_64_PLT32	rt_type_error-0x4
    1df0:	jmp    1f07 <botlish_fn_24+0x237>
    1df5:	mov    rcx,r8
    1df8:	mov    rsi,r13
    1dfb:	mov    rax,rsi
    1dfe:	and    rax,rcx
    1e01:	test   rax,0x1
    1e07:	jne    1e18 <botlish_fn_24+0x148>
    1e0d:	mov    rdx,r8
    1e10:	mov    rsi,r13
    1e13:	jmp    1e36 <botlish_fn_24+0x166>
    1e18:	mov    rcx,r8
    1e1b:	lea    rax,[rcx-0x1]
    1e1f:	mov    rsi,r13
    1e22:	add    rsi,rax
    1e25:	seto   al
    1e28:	test   al,al
    1e2a:	je     1e41 <botlish_fn_24+0x171>
    1e30:	mov    rdx,r8
    1e33:	mov    rsi,r13
    1e36:	mov    rdi,rbx
    1e39:	call   1e3e <botlish_fn_24+0x16e>
			1e3a: R_X86_64_PLT32	rt_int_add-0x4
    1e3e:	mov    rsi,rax
    1e41:	mov    QWORD PTR [rsp+0x8],rsi
    1e46:	mov    QWORD PTR [rsp+0x10],0x3
    1e4f:	test   rsi,0x1
    1e56:	je     1e79 <botlish_fn_24+0x1a9>
    1e5c:	mov    rax,rsi
    1e5f:	add    rax,0x2
    1e63:	mov    rcx,rax
    1e66:	seto   al
    1e69:	test   al,al
    1e6b:	jne    1e79 <botlish_fn_24+0x1a9>
    1e71:	mov    rsi,rcx
    1e74:	jmp    1e89 <botlish_fn_24+0x1b9>
    1e79:	mov    edx,0x3
    1e7e:	mov    rdi,rbx
    1e81:	call   1e86 <botlish_fn_24+0x1b6>
			1e82: R_X86_64_PLT32	rt_int_add-0x4
    1e86:	mov    rsi,rax
    1e89:	mov    QWORD PTR [rsp+0x8],rsi
    1e8e:	mov    edx,0x7
    1e93:	mov    rdi,rdx
    1e96:	mov    QWORD PTR [rsp+0x10],0x7
    1e9f:	test   rsi,0x1
    1ea6:	jne    1eb4 <botlish_fn_24+0x1e4>
    1eac:	mov    rdx,rdi
    1eaf:	jmp    1ee0 <botlish_fn_24+0x210>
    1eb4:	mov    rax,rsi
    1eb7:	sar    rax,1
    1eba:	imul   QWORD PTR [rip+0x117]        # 1fd8 <botlish_fn_24+0x308>
    1ec1:	seto   cl
    1ec4:	or     rax,0x1
    1ec8:	test   cl,cl
    1eca:	je     1ed8 <botlish_fn_24+0x208>
    1ed0:	mov    rdx,rdi
    1ed3:	jmp    1ee0 <botlish_fn_24+0x210>
    1ed8:	mov    rsi,rax
    1edb:	jmp    1eeb <botlish_fn_24+0x21b>
    1ee0:	mov    rdi,rbx
    1ee3:	call   1ee8 <botlish_fn_24+0x218>
			1ee4: R_X86_64_PLT32	rt_int_mul-0x4
    1ee8:	mov    rsi,rax
    1eeb:	mov    QWORD PTR [rsp+0x8],rsi
    1ef0:	mov    r13,rsi
    1ef3:	mov    rsi,r12
    1ef6:	mov    rdi,rbx
    1ef9:	call   1efe <botlish_fn_24+0x22e>
			1efa: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    1efe:	test   rax,rax
    1f01:	jne    1f22 <botlish_fn_24+0x252>
    1f07:	xor    rax,rax
    1f0a:	mov    rbx,QWORD PTR [rsp+0x20]
    1f0f:	mov    r12,QWORD PTR [rsp+0x28]
    1f14:	mov    r13,QWORD PTR [rsp+0x30]
    1f19:	add    rsp,0x40
    1f1d:	mov    rsp,rbp
    1f20:	pop    rbp
    1f21:	ret
    1f22:	mov    QWORD PTR [rsp],rax
    1f26:	mov    QWORD PTR [rsp+0x10],0x5
    1f2f:	test   rax,0x1
    1f35:	mov    rsi,rax
    1f38:	je     1f6a <botlish_fn_24+0x29a>
    1f3e:	mov    rcx,rsi
    1f41:	mov    rax,rcx
    1f44:	sar    rax,1
    1f47:	imul   QWORD PTR [rip+0x92]        # 1fe0 <botlish_fn_24+0x310>
    1f4e:	seto   r9b
    1f52:	or     rax,0x1
    1f56:	test   r9b,r9b
    1f59:	jne    1f6a <botlish_fn_24+0x29a>
    1f5f:	mov    rdx,rax
    1f62:	mov    rsi,r13
    1f65:	jmp    1f7d <botlish_fn_24+0x2ad>
    1f6a:	mov    edx,0x5
    1f6f:	mov    rdi,rbx
    1f72:	call   1f77 <botlish_fn_24+0x2a7>
			1f73: R_X86_64_PLT32	rt_int_mul-0x4
    1f77:	mov    rdx,rax
    1f7a:	mov    rsi,r13
    1f7d:	mov    rax,rsi
    1f80:	and    rax,rdx
    1f83:	test   rax,0x1
    1f89:	jne    1fb0 <botlish_fn_24+0x2e0>
    1f8f:	mov    rdi,rbx
    1f92:	call   1f97 <botlish_fn_24+0x2c7>
			1f93: R_X86_64_PLT32	rt_int_cmp-0x4
    1f97:	mov    r10d,0x2
    1f9d:	test   rax,rax
    1fa0:	mov    rax,r10
    1fa3:	cmovg  rax,QWORD PTR [rip+0x2d]        # 1fd8 <botlish_fn_24+0x308>
    1fab:	jmp    1fc0 <botlish_fn_24+0x2f0>
    1fb0:	mov    eax,0x2
    1fb5:	cmp    rsi,rdx
    1fb8:	cmovg  rax,QWORD PTR [rip+0x18]        # 1fd8 <botlish_fn_24+0x308>
    1fc0:	mov    rbx,QWORD PTR [rsp+0x20]
    1fc5:	mov    r12,QWORD PTR [rsp+0x28]
    1fca:	mov    r13,QWORD PTR [rsp+0x30]
    1fcf:	add    rsp,0x40
    1fd3:	mov    rsp,rbp
    1fd6:	pop    rbp
    1fd7:	ret
    1fd8:	(bad)
    1fd9:	add    BYTE PTR [rax],al
    1fdb:	add    BYTE PTR [rax],al
    1fdd:	add    BYTE PTR [rax],al
    1fdf:	add    BYTE PTR [rax+rax*1],al
    1fe2:	add    BYTE PTR [rax],al
    1fe4:	add    BYTE PTR [rax],al
	...

0000000000001fe8 <botlish_entry_24: ht_should_grow<mutarray>>:
    1fe8:	push   rbp
    1fe9:	mov    rbp,rsp
    1fec:	mov    rsi,QWORD PTR [rdx]
    1fef:	call   1ff4 <botlish_entry_24+0xc>
			1ff0: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    1ff4:	mov    rsp,rbp
    1ff7:	pop    rbp
    1ff8:	ret
    1ff9:	add    BYTE PTR [rax],al
    1ffb:	add    BYTE PTR [rax],al
    1ffd:	add    BYTE PTR [rax],al
	...

0000000000002000 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    2000:	push   rbp
    2001:	mov    rbp,rsp
    2004:	sub    rsp,0x40
    2008:	mov    QWORD PTR [rsp+0x20],rbx
    200d:	mov    QWORD PTR [rsp+0x28],r12
    2012:	mov    QWORD PTR [rsp+0x30],r13
    2017:	mov    rbx,rdi
    201a:	mov    QWORD PTR [rsp+0x8],0x0
    2023:	mov    QWORD PTR [rsp+0x10],0x0
    202c:	mov    QWORD PTR [rsp],rsi
    2030:	mov    r12,rsi
    2033:	mov    rsi,r12
    2036:	mov    rdi,rbx
    2039:	call   203e <botlish_fn_25+0x3e>
			203a: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    203e:	test   rax,rax
    2041:	je     2234 <botlish_fn_25+0x234>
    2047:	mov    QWORD PTR [rsp+0x8],rax
    204c:	mov    r13,rax
    204f:	mov    rsi,r12
    2052:	mov    rdi,rbx
    2055:	call   205a <botlish_fn_25+0x5a>
			2056: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    205a:	mov    rcx,rax
    205d:	test   rcx,rcx
    2060:	je     2234 <botlish_fn_25+0x234>
    2066:	mov    edx,0x1
    206b:	mov    rax,r13
    206e:	test   rax,0x1
    2074:	je     2082 <botlish_fn_25+0x82>
    207a:	mov    r13,rax
    207d:	jmp    20a6 <botlish_fn_25+0xa6>
    2082:	xor    edx,edx
    2084:	test   rax,0x7
    208a:	je     2098 <botlish_fn_25+0x98>
    2090:	mov    r13,rax
    2093:	jmp    20a6 <botlish_fn_25+0xa6>
    2098:	movzx  rdx,BYTE PTR [rax]
    209c:	mov    r13,rax
    209f:	rex cmp dl,0x1
    20a3:	sete   dl
    20a6:	test   dl,dl
    20a8:	jne    20c9 <botlish_fn_25+0xc9>
    20ae:	mov    rdi,rbx
    20b1:	mov    rsi,QWORD PTR [rdi+0x10]
    20b5:	mov    rcx,QWORD PTR [rsi+0x18]
    20b9:	xor    rdx,rdx
    20bc:	mov    rsi,r13
    20bf:	call   20c4 <botlish_fn_25+0xc4>
			20c0: R_X86_64_PLT32	rt_type_error-0x4
    20c4:	jmp    2234 <botlish_fn_25+0x234>
    20c9:	mov    rsi,r13
    20cc:	mov    eax,0x1
    20d1:	test   rcx,0x1
    20d8:	je     20e6 <botlish_fn_25+0xe6>
    20de:	mov    r8,rcx
    20e1:	jmp    2109 <botlish_fn_25+0x109>
    20e6:	xor    eax,eax
    20e8:	test   rcx,0x7
    20ef:	je     20fd <botlish_fn_25+0xfd>
    20f5:	mov    r8,rcx
    20f8:	jmp    2109 <botlish_fn_25+0x109>
    20fd:	movzx  rax,BYTE PTR [rcx]
    2101:	mov    r8,rcx
    2104:	cmp    al,0x1
    2106:	sete   al
    2109:	test   al,al
    210b:	jne    212c <botlish_fn_25+0x12c>
    2111:	mov    rdi,rbx
    2114:	mov    rax,QWORD PTR [rdi+0x10]
    2118:	mov    rcx,QWORD PTR [rax+0x18]
    211c:	xor    rdx,rdx
    211f:	mov    rsi,r8
    2122:	call   2127 <botlish_fn_25+0x127>
			2123: R_X86_64_PLT32	rt_type_error-0x4
    2127:	jmp    2234 <botlish_fn_25+0x234>
    212c:	mov    rcx,r8
    212f:	mov    rax,rsi
    2132:	and    rax,rcx
    2135:	test   rax,0x1
    213b:	jne    2161 <botlish_fn_25+0x161>
    2141:	mov    rdx,r8
    2144:	mov    rdi,rbx
    2147:	call   214c <botlish_fn_25+0x14c>
			2148: R_X86_64_PLT32	rt_int_cmp-0x4
    214c:	mov    ecx,0x2
    2151:	test   rax,rax
    2154:	cmovg  rcx,QWORD PTR [rip+0x10c]        # 2268 <botlish_fn_25+0x268>
    215c:	jmp    2174 <botlish_fn_25+0x174>
    2161:	mov    ecx,0x2
    2166:	mov    r11,r8
    2169:	cmp    rsi,r11
    216c:	cmovg  rcx,QWORD PTR [rip+0xf4]        # 2268 <botlish_fn_25+0x268>
    2174:	cmp    rcx,0x6
    2178:	je     2204 <botlish_fn_25+0x204>
    217e:	mov    rsi,r12
    2181:	mov    rdi,rbx
    2184:	call   2189 <botlish_fn_25+0x189>
			2185: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2189:	test   rax,rax
    218c:	je     2234 <botlish_fn_25+0x234>
    2192:	mov    QWORD PTR [rsp+0x8],rax
    2197:	mov    QWORD PTR [rsp+0x10],0x5
    21a0:	test   rax,0x1
    21a6:	mov    rsi,rax
    21a9:	je     21d6 <botlish_fn_25+0x1d6>
    21af:	mov    rcx,rsi
    21b2:	mov    rax,rcx
    21b5:	sar    rax,1
    21b8:	imul   QWORD PTR [rip+0xb1]        # 2270 <botlish_fn_25+0x270>
    21bf:	seto   cl
    21c2:	or     rax,0x1
    21c6:	test   cl,cl
    21c8:	jne    21d6 <botlish_fn_25+0x1d6>
    21ce:	mov    rdx,rax
    21d1:	jmp    21e6 <botlish_fn_25+0x1e6>
    21d6:	mov    edx,0x5
    21db:	mov    rdi,rbx
    21de:	call   21e3 <botlish_fn_25+0x1e3>
			21df: R_X86_64_PLT32	rt_int_mul-0x4
    21e3:	mov    rdx,rax
    21e6:	mov    QWORD PTR [rsp+0x8],rdx
    21eb:	mov    rsi,r12
    21ee:	mov    rdi,rbx
    21f1:	call   21f6 <botlish_fn_25+0x1f6>
			21f2: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    21f6:	test   rax,rax
    21f9:	je     2234 <botlish_fn_25+0x234>
    21ff:	jmp    224f <botlish_fn_25+0x24f>
    2204:	mov    rsi,r12
    2207:	mov    rdi,rbx
    220a:	call   220f <botlish_fn_25+0x20f>
			220b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    220f:	test   rax,rax
    2212:	je     2234 <botlish_fn_25+0x234>
    2218:	mov    QWORD PTR [rsp+0x8],rax
    221d:	mov    rdx,rax
    2220:	mov    rsi,r12
    2223:	mov    rdi,rbx
    2226:	call   222b <botlish_fn_25+0x22b>
			2227: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    222b:	test   rax,rax
    222e:	jne    224f <botlish_fn_25+0x24f>
    2234:	xor    rax,rax
    2237:	mov    rbx,QWORD PTR [rsp+0x20]
    223c:	mov    r12,QWORD PTR [rsp+0x28]
    2241:	mov    r13,QWORD PTR [rsp+0x30]
    2246:	add    rsp,0x40
    224a:	mov    rsp,rbp
    224d:	pop    rbp
    224e:	ret
    224f:	mov    rbx,QWORD PTR [rsp+0x20]
    2254:	mov    r12,QWORD PTR [rsp+0x28]
    2259:	mov    r13,QWORD PTR [rsp+0x30]
    225e:	add    rsp,0x40
    2262:	mov    rsp,rbp
    2265:	pop    rbp
    2266:	ret
    2267:	add    BYTE PTR [rsi],al
    2269:	add    BYTE PTR [rax],al
    226b:	add    BYTE PTR [rax],al
    226d:	add    BYTE PTR [rax],al
    226f:	add    BYTE PTR [rax+rax*1],al
    2272:	add    BYTE PTR [rax],al
    2274:	add    BYTE PTR [rax],al
	...

0000000000002278 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    2278:	push   rbp
    2279:	mov    rbp,rsp
    227c:	mov    rsi,QWORD PTR [rdx]
    227f:	call   2284 <botlish_entry_25+0xc>
			2280: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    2284:	mov    rsp,rbp
    2287:	pop    rbp
    2288:	ret
    2289:	add    BYTE PTR [rax],al
    228b:	add    BYTE PTR [rax],al
    228d:	add    BYTE PTR [rax],al
	...

0000000000002290 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    2290:	push   rbp
    2291:	mov    rbp,rsp
    2294:	sub    rsp,0x70
    2298:	mov    QWORD PTR [rsp+0x40],rbx
    229d:	mov    QWORD PTR [rsp+0x48],r12
    22a2:	mov    QWORD PTR [rsp+0x50],r13
    22a7:	mov    QWORD PTR [rsp+0x58],r14
    22ac:	mov    QWORD PTR [rsp+0x60],r15
    22b1:	mov    rbx,rdi
    22b4:	mov    QWORD PTR [rsp+0x20],0x0
    22bd:	mov    QWORD PTR [rsp+0x28],0x0
    22c6:	mov    QWORD PTR [rsp],rsi
    22ca:	mov    r12,rsi
    22cd:	mov    QWORD PTR [rsp+0x8],rdx
    22d2:	mov    r15,rdx
    22d5:	mov    QWORD PTR [rsp+0x10],rcx
    22da:	mov    QWORD PTR [rsp+0x30],rcx
    22df:	mov    QWORD PTR [rsp+0x18],r8
    22e4:	mov    r14,r8
    22e7:	mov    rsi,r12
    22ea:	mov    rdi,rbx
    22ed:	call   22f2 <botlish_fn_26+0x62>
			22ee: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    22f2:	test   rax,rax
    22f5:	je     2686 <botlish_fn_26+0x3f6>
    22fb:	mov    QWORD PTR [rsp+0x20],rax
    2300:	xor    ecx,ecx
    2302:	test   rax,0x7
    2308:	je     2318 <botlish_fn_26+0x88>
    230e:	mov    QWORD PTR [rsp+0x38],rax
    2313:	jmp    2328 <botlish_fn_26+0x98>
    2318:	movzx  rcx,BYTE PTR [rax]
    231c:	mov    QWORD PTR [rsp+0x38],rax
    2321:	rex cmp cl,0x8
    2325:	sete   cl
    2328:	test   cl,cl
    232a:	jne    234f <botlish_fn_26+0xbf>
    2330:	mov    rdi,rbx
    2333:	mov    rax,QWORD PTR [rdi+0x10]
    2337:	mov    rcx,QWORD PTR [rax+0x8]
    233b:	mov    edx,0x8
    2340:	mov    rsi,QWORD PTR [rsp+0x38]
    2345:	call   234a <botlish_fn_26+0xba>
			2346: R_X86_64_PLT32	rt_type_error-0x4
    234a:	jmp    2686 <botlish_fn_26+0x3f6>
    234f:	mov    rdx,r15
    2352:	mov    rsi,QWORD PTR [rsp+0x38]
    2357:	mov    rdi,rbx
    235a:	call   235f <botlish_fn_26+0xcf>
			235b: R_X86_64_PLT32	rt_mutarray_get-0x4
    235f:	test   rax,rax
    2362:	je     2686 <botlish_fn_26+0x3f6>
    2368:	mov    QWORD PTR [rsp+0x28],rax
    236d:	mov    r13,rax
    2370:	mov    rdi,rbx
    2373:	call   2378 <botlish_fn_26+0xe8>
			2374: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    2378:	test   rax,rax
    237b:	je     2686 <botlish_fn_26+0x3f6>
    2381:	mov    ecx,0x3
    2386:	mov    rsi,QWORD PTR [rsp+0x38]
    238b:	mov    rdx,r15
    238e:	mov    rdi,rbx
    2391:	call   2396 <botlish_fn_26+0x106>
			2392: R_X86_64_PLT32	rt_mutarray_set-0x4
    2396:	test   rax,rax
    2399:	je     2686 <botlish_fn_26+0x3f6>
    239f:	mov    rsi,r12
    23a2:	mov    rdi,rbx
    23a5:	call   23aa <botlish_fn_26+0x11a>
			23a6: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    23aa:	test   rax,rax
    23ad:	je     2686 <botlish_fn_26+0x3f6>
    23b3:	xor    ecx,ecx
    23b5:	test   rax,0x7
    23bb:	je     23c9 <botlish_fn_26+0x139>
    23c1:	mov    rsi,rax
    23c4:	jmp    23d7 <botlish_fn_26+0x147>
    23c9:	movzx  rcx,BYTE PTR [rax]
    23cd:	mov    rsi,rax
    23d0:	rex cmp cl,0x8
    23d4:	sete   cl
    23d7:	test   cl,cl
    23d9:	jne    23f9 <botlish_fn_26+0x169>
    23df:	mov    rdi,rbx
    23e2:	mov    rdx,QWORD PTR [rdi+0x10]
    23e6:	mov    rcx,QWORD PTR [rdx+0x20]
    23ea:	mov    edx,0x8
    23ef:	call   23f4 <botlish_fn_26+0x164>
			23f0: R_X86_64_PLT32	rt_type_error-0x4
    23f4:	jmp    2686 <botlish_fn_26+0x3f6>
    23f9:	mov    rcx,QWORD PTR [rsp+0x30]
    23fe:	mov    rdx,r15
    2401:	mov    rdi,rbx
    2404:	call   2409 <botlish_fn_26+0x179>
			2405: R_X86_64_PLT32	rt_mutarray_set-0x4
    2409:	test   rax,rax
    240c:	je     2686 <botlish_fn_26+0x3f6>
    2412:	mov    rsi,r12
    2415:	mov    rdi,rbx
    2418:	call   241d <botlish_fn_26+0x18d>
			2419: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    241d:	test   rax,rax
    2420:	je     2686 <botlish_fn_26+0x3f6>
    2426:	xor    ecx,ecx
    2428:	test   rax,0x7
    242e:	je     243c <botlish_fn_26+0x1ac>
    2434:	mov    rsi,rax
    2437:	jmp    244a <botlish_fn_26+0x1ba>
    243c:	movzx  rcx,BYTE PTR [rax]
    2440:	mov    rsi,rax
    2443:	rex cmp cl,0x8
    2447:	sete   cl
    244a:	test   cl,cl
    244c:	jne    246c <botlish_fn_26+0x1dc>
    2452:	mov    rdi,rbx
    2455:	mov    rax,QWORD PTR [rdi+0x10]
    2459:	mov    rcx,QWORD PTR [rax+0x20]
    245d:	mov    edx,0x8
    2462:	call   2467 <botlish_fn_26+0x1d7>
			2463: R_X86_64_PLT32	rt_type_error-0x4
    2467:	jmp    2686 <botlish_fn_26+0x3f6>
    246c:	mov    rcx,r14
    246f:	mov    rdx,r15
    2472:	mov    rdi,rbx
    2475:	call   247a <botlish_fn_26+0x1ea>
			2476: R_X86_64_PLT32	rt_mutarray_set-0x4
    247a:	test   rax,rax
    247d:	je     2686 <botlish_fn_26+0x3f6>
    2483:	mov    QWORD PTR [rsp+0x8],0x7
    248c:	mov    rsi,r12
    248f:	mov    rdi,rbx
    2492:	call   2497 <botlish_fn_26+0x207>
			2493: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2497:	test   rax,rax
    249a:	je     2686 <botlish_fn_26+0x3f6>
    24a0:	mov    QWORD PTR [rsp+0x10],rax
    24a5:	mov    QWORD PTR [rsp+0x18],0x3
    24ae:	mov    ecx,0x1
    24b3:	test   rax,0x1
    24b9:	je     24c7 <botlish_fn_26+0x237>
    24bf:	mov    rsi,rax
    24c2:	jmp    24eb <botlish_fn_26+0x25b>
    24c7:	xor    ecx,ecx
    24c9:	test   rax,0x7
    24cf:	je     24dd <botlish_fn_26+0x24d>
    24d5:	mov    rsi,rax
    24d8:	jmp    24eb <botlish_fn_26+0x25b>
    24dd:	movzx  rcx,BYTE PTR [rax]
    24e1:	mov    rsi,rax
    24e4:	rex cmp cl,0x1
    24e8:	sete   cl
    24eb:	test   cl,cl
    24ed:	jne    250b <botlish_fn_26+0x27b>
    24f3:	mov    rdi,rbx
    24f6:	mov    rax,QWORD PTR [rdi+0x10]
    24fa:	mov    rcx,QWORD PTR [rax+0x10]
    24fe:	xor    rdx,rdx
    2501:	call   2506 <botlish_fn_26+0x276>
			2502: R_X86_64_PLT32	rt_type_error-0x4
    2506:	jmp    2686 <botlish_fn_26+0x3f6>
    250b:	test   rsi,0x1
    2512:	je     252a <botlish_fn_26+0x29a>
    2518:	mov    rcx,rsi
    251b:	add    rcx,0x2
    251f:	seto   al
    2522:	test   al,al
    2524:	je     253a <botlish_fn_26+0x2aa>
    252a:	mov    edx,0x3
    252f:	mov    rdi,rbx
    2532:	call   2537 <botlish_fn_26+0x2a7>
			2533: R_X86_64_PLT32	rt_int_add-0x4
    2537:	mov    rcx,rax
    253a:	mov    edx,0x7
    253f:	mov    rsi,r12
    2542:	mov    rdi,rbx
    2545:	call   254a <botlish_fn_26+0x2ba>
			2546: R_X86_64_PLT32	rt_mutarray_set-0x4
    254a:	test   rax,rax
    254d:	je     2686 <botlish_fn_26+0x3f6>
    2553:	mov    rdi,rbx
    2556:	call   255b <botlish_fn_26+0x2cb>
			2557: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    255b:	test   rax,rax
    255e:	je     2686 <botlish_fn_26+0x3f6>
    2564:	mov    rax,r13
    2567:	test   rax,0x1
    256d:	jne    2591 <botlish_fn_26+0x301>
    2573:	mov    edx,0x5
    2578:	mov    rsi,r13
    257b:	mov    rdi,rbx
    257e:	call   2583 <botlish_fn_26+0x2f3>
			257f: R_X86_64_PLT32	rt_value_eq-0x4
    2583:	test   rax,rax
    2586:	je     2686 <botlish_fn_26+0x3f6>
    258c:	jmp    25a5 <botlish_fn_26+0x315>
    2591:	mov    rsi,r13
    2594:	mov    eax,0x2
    2599:	cmp    rsi,0x5
    259d:	cmove  rax,QWORD PTR [rip+0x133]        # 26d8 <botlish_fn_26+0x448>
    25a5:	cmp    rax,0x6
    25a9:	jne    26ab <botlish_fn_26+0x41b>
    25af:	mov    QWORD PTR [rsp+0x8],0x9
    25b8:	mov    rsi,r12
    25bb:	mov    rdi,rbx
    25be:	call   25c3 <botlish_fn_26+0x333>
			25bf: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    25c3:	test   rax,rax
    25c6:	je     2686 <botlish_fn_26+0x3f6>
    25cc:	mov    QWORD PTR [rsp+0x10],rax
    25d1:	mov    QWORD PTR [rsp+0x18],0x3
    25da:	mov    ecx,0x1
    25df:	test   rax,0x1
    25e5:	je     25f3 <botlish_fn_26+0x363>
    25eb:	mov    rsi,rax
    25ee:	jmp    2617 <botlish_fn_26+0x387>
    25f3:	xor    ecx,ecx
    25f5:	test   rax,0x7
    25fb:	je     2609 <botlish_fn_26+0x379>
    2601:	mov    rsi,rax
    2604:	jmp    2617 <botlish_fn_26+0x387>
    2609:	movzx  r11,BYTE PTR [rax]
    260d:	mov    rsi,rax
    2610:	cmp    r11b,0x1
    2614:	sete   cl
    2617:	test   cl,cl
    2619:	jne    2637 <botlish_fn_26+0x3a7>
    261f:	mov    rdi,rbx
    2622:	mov    rax,QWORD PTR [rdi+0x10]
    2626:	mov    rcx,QWORD PTR [rax+0x28]
    262a:	xor    rdx,rdx
    262d:	call   2632 <botlish_fn_26+0x3a2>
			262e: R_X86_64_PLT32	rt_type_error-0x4
    2632:	jmp    2686 <botlish_fn_26+0x3f6>
    2637:	test   rsi,0x1
    263e:	je     265d <botlish_fn_26+0x3cd>
    2644:	mov    rcx,rsi
    2647:	sub    rcx,0x3
    264b:	seto   al
    264e:	add    rcx,0x1
    2655:	test   al,al
    2657:	je     266d <botlish_fn_26+0x3dd>
    265d:	mov    edx,0x3
    2662:	mov    rdi,rbx
    2665:	call   266a <botlish_fn_26+0x3da>
			2666: R_X86_64_PLT32	rt_int_sub-0x4
    266a:	mov    rcx,rax
    266d:	mov    edx,0x9
    2672:	mov    rsi,r12
    2675:	mov    rdi,rbx
    2678:	call   267d <botlish_fn_26+0x3ed>
			2679: R_X86_64_PLT32	rt_mutarray_set-0x4
    267d:	test   rax,rax
    2680:	jne    26ab <botlish_fn_26+0x41b>
    2686:	xor    rax,rax
    2689:	mov    rbx,QWORD PTR [rsp+0x40]
    268e:	mov    r12,QWORD PTR [rsp+0x48]
    2693:	mov    r13,QWORD PTR [rsp+0x50]
    2698:	mov    r14,QWORD PTR [rsp+0x58]
    269d:	mov    r15,QWORD PTR [rsp+0x60]
    26a2:	add    rsp,0x70
    26a6:	mov    rsp,rbp
    26a9:	pop    rbp
    26aa:	ret
    26ab:	mov    eax,0xa
    26b0:	mov    rbx,QWORD PTR [rsp+0x40]
    26b5:	mov    r12,QWORD PTR [rsp+0x48]
    26ba:	mov    r13,QWORD PTR [rsp+0x50]
    26bf:	mov    r14,QWORD PTR [rsp+0x58]
    26c4:	mov    r15,QWORD PTR [rsp+0x60]
    26c9:	add    rsp,0x70
    26cd:	mov    rsp,rbp
    26d0:	pop    rbp
    26d1:	ret
    26d2:	add    BYTE PTR [rax],al
    26d4:	add    BYTE PTR [rax],al
    26d6:	add    BYTE PTR [rax],al
    26d8:	(bad)
    26d9:	add    BYTE PTR [rax],al
    26db:	add    BYTE PTR [rax],al
    26dd:	add    BYTE PTR [rax],al
	...

00000000000026e0 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    26e0:	push   rbp
    26e1:	mov    rbp,rsp
    26e4:	mov    rsi,QWORD PTR [rdx]
    26e7:	mov    r9,QWORD PTR [rdx+0x8]
    26eb:	mov    rcx,QWORD PTR [rdx+0x10]
    26ef:	mov    r8,QWORD PTR [rdx+0x18]
    26f3:	mov    rdx,r9
    26f6:	call   26fb <botlish_entry_26+0x1b>
			26f7: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    26fb:	mov    rsp,rbp
    26fe:	pop    rbp
    26ff:	ret

0000000000002700 <botlish_fn_27: ht_set<mutarray, str, str>>:
    2700:	push   rbp
    2701:	mov    rbp,rsp
    2704:	sub    rsp,0x70
    2708:	mov    QWORD PTR [rsp+0x40],rbx
    270d:	mov    QWORD PTR [rsp+0x48],r12
    2712:	mov    QWORD PTR [rsp+0x50],r13
    2717:	mov    QWORD PTR [rsp+0x58],r14
    271c:	mov    QWORD PTR [rsp+0x60],r15
    2721:	mov    rbx,rdi
    2724:	mov    QWORD PTR [rsp+0x18],0x0
    272d:	mov    QWORD PTR [rsp+0x20],0x0
    2736:	mov    QWORD PTR [rsp],rsi
    273a:	mov    r14,rsi
    273d:	mov    QWORD PTR [rsp+0x8],rdx
    2742:	mov    r13,rdx
    2745:	mov    QWORD PTR [rsp+0x10],rcx
    274a:	mov    r12,rcx
    274d:	mov    rdx,r13
    2750:	mov    rsi,r14
    2753:	mov    rdi,rbx
    2756:	call   275b <botlish_fn_27+0x5b>
			2757: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    275b:	test   rax,rax
    275e:	je     29f0 <botlish_fn_27+0x2f0>
    2764:	mov    QWORD PTR [rsp+0x18],rax
    2769:	mov    rcx,rax
    276c:	mov    r8,0xffffffffffffffff
    2773:	mov    QWORD PTR [rsp+0x30],r8
    2778:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    2781:	mov    rdx,r13
    2784:	mov    rsi,r14
    2787:	mov    rdi,rbx
    278a:	call   278f <botlish_fn_27+0x8f>
			278b: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    278f:	mov    rcx,rax
    2792:	mov    r15,rax
    2795:	test   rax,rcx
    2798:	je     29f0 <botlish_fn_27+0x2f0>
    279e:	mov    rax,r15
    27a1:	mov    QWORD PTR [rsp+0x18],rax
    27a6:	mov    rsi,r14
    27a9:	mov    rdi,rbx
    27ac:	call   27b1 <botlish_fn_27+0xb1>
			27ad: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    27b1:	test   rax,rax
    27b4:	je     29f0 <botlish_fn_27+0x2f0>
    27ba:	xor    ecx,ecx
    27bc:	test   rax,0x7
    27c2:	je     27d0 <botlish_fn_27+0xd0>
    27c8:	mov    r8,rax
    27cb:	jmp    27de <botlish_fn_27+0xde>
    27d0:	movzx  rdx,BYTE PTR [rax]
    27d4:	mov    r8,rax
    27d7:	rex cmp dl,0x8
    27db:	sete   cl
    27de:	test   cl,cl
    27e0:	jne    2803 <botlish_fn_27+0x103>
    27e6:	mov    rdi,rbx
    27e9:	mov    rsi,QWORD PTR [rdi+0x10]
    27ed:	mov    rcx,QWORD PTR [rsi+0x8]
    27f1:	mov    edx,0x8
    27f6:	mov    rsi,r8
    27f9:	call   27fe <botlish_fn_27+0xfe>
			27fa: R_X86_64_PLT32	rt_type_error-0x4
    27fe:	jmp    29f0 <botlish_fn_27+0x2f0>
    2803:	mov    rsi,r8
    2806:	mov    rdx,r15
    2809:	mov    rdi,rbx
    280c:	call   2811 <botlish_fn_27+0x111>
			280d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2811:	test   rax,rax
    2814:	je     29f0 <botlish_fn_27+0x2f0>
    281a:	mov    QWORD PTR [rsp+0x20],rax
    281f:	mov    QWORD PTR [rsp+0x28],rax
    2824:	mov    rdi,rbx
    2827:	call   282c <botlish_fn_27+0x12c>
			2828: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    282c:	test   rax,rax
    282f:	je     29f0 <botlish_fn_27+0x2f0>
    2835:	mov    rax,QWORD PTR [rsp+0x28]
    283a:	test   rax,0x1
    2840:	jne    2866 <botlish_fn_27+0x166>
    2846:	mov    edx,0x3
    284b:	mov    rsi,QWORD PTR [rsp+0x28]
    2850:	mov    rdi,rbx
    2853:	call   2858 <botlish_fn_27+0x158>
			2854: R_X86_64_PLT32	rt_value_eq-0x4
    2858:	test   rax,rax
    285b:	je     29f0 <botlish_fn_27+0x2f0>
    2861:	jmp    287c <botlish_fn_27+0x17c>
    2866:	mov    rsi,QWORD PTR [rsp+0x28]
    286b:	mov    eax,0x2
    2870:	cmp    rsi,0x3
    2874:	cmove  rax,QWORD PTR [rip+0x1c4]        # 2a40 <botlish_fn_27+0x340>
    287c:	cmp    rax,0x6
    2880:	je     297f <botlish_fn_27+0x27f>
    2886:	mov    rsi,r14
    2889:	mov    rdi,rbx
    288c:	call   2891 <botlish_fn_27+0x191>
			288d: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2891:	test   rax,rax
    2894:	je     29f0 <botlish_fn_27+0x2f0>
    289a:	cmp    rax,0x6
    289e:	je     28e3 <botlish_fn_27+0x1e3>
    28a4:	mov    rcx,r13
    28a7:	mov    rdx,r15
    28aa:	mov    rsi,r14
    28ad:	mov    rdi,rbx
    28b0:	mov    r8,r12
    28b3:	call   28b8 <botlish_fn_27+0x1b8>
			28b4: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    28b8:	test   rax,rax
    28bb:	je     29f0 <botlish_fn_27+0x2f0>
    28c1:	mov    rbx,QWORD PTR [rsp+0x40]
    28c6:	mov    r12,QWORD PTR [rsp+0x48]
    28cb:	mov    r13,QWORD PTR [rsp+0x50]
    28d0:	mov    r14,QWORD PTR [rsp+0x58]
    28d5:	mov    r15,QWORD PTR [rsp+0x60]
    28da:	add    rsp,0x70
    28de:	mov    rsp,rbp
    28e1:	pop    rbp
    28e2:	ret
    28e3:	mov    rsi,r14
    28e6:	mov    rdi,rbx
    28e9:	call   28ee <botlish_fn_27+0x1ee>
			28ea: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    28ee:	test   rax,rax
    28f1:	je     29f0 <botlish_fn_27+0x2f0>
    28f7:	mov    rdx,r13
    28fa:	mov    rsi,r14
    28fd:	mov    rdi,rbx
    2900:	call   2905 <botlish_fn_27+0x205>
			2901: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    2905:	test   rax,rax
    2908:	je     29f0 <botlish_fn_27+0x2f0>
    290e:	mov    QWORD PTR [rsp+0x18],rax
    2913:	mov    rcx,rax
    2916:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    291f:	mov    r8,QWORD PTR [rsp+0x30]
    2924:	mov    rdx,r13
    2927:	mov    rsi,r14
    292a:	mov    rdi,rbx
    292d:	call   2932 <botlish_fn_27+0x232>
			292e: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    2932:	test   rax,rax
    2935:	je     29f0 <botlish_fn_27+0x2f0>
    293b:	mov    QWORD PTR [rsp+0x18],rax
    2940:	mov    rcx,r13
    2943:	mov    rdx,rax
    2946:	mov    rsi,r14
    2949:	mov    rdi,rbx
    294c:	mov    r8,r12
    294f:	call   2954 <botlish_fn_27+0x254>
			2950: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    2954:	test   rax,rax
    2957:	je     29f0 <botlish_fn_27+0x2f0>
    295d:	mov    rbx,QWORD PTR [rsp+0x40]
    2962:	mov    r12,QWORD PTR [rsp+0x48]
    2967:	mov    r13,QWORD PTR [rsp+0x50]
    296c:	mov    r14,QWORD PTR [rsp+0x58]
    2971:	mov    r15,QWORD PTR [rsp+0x60]
    2976:	add    rsp,0x70
    297a:	mov    rsp,rbp
    297d:	pop    rbp
    297e:	ret
    297f:	mov    rsi,r14
    2982:	mov    rdi,rbx
    2985:	call   298a <botlish_fn_27+0x28a>
			2986: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    298a:	test   rax,rax
    298d:	je     29f0 <botlish_fn_27+0x2f0>
    2993:	xor    ecx,ecx
    2995:	test   rax,0x7
    299b:	je     29a9 <botlish_fn_27+0x2a9>
    29a1:	mov    rsi,rax
    29a4:	jmp    29b7 <botlish_fn_27+0x2b7>
    29a9:	movzx  rcx,BYTE PTR [rax]
    29ad:	mov    rsi,rax
    29b0:	rex cmp cl,0x8
    29b4:	sete   cl
    29b7:	test   cl,cl
    29b9:	jne    29d9 <botlish_fn_27+0x2d9>
    29bf:	mov    rdi,rbx
    29c2:	mov    rax,QWORD PTR [rdi+0x10]
    29c6:	mov    rcx,QWORD PTR [rax+0x20]
    29ca:	mov    edx,0x8
    29cf:	call   29d4 <botlish_fn_27+0x2d4>
			29d0: R_X86_64_PLT32	rt_type_error-0x4
    29d4:	jmp    29f0 <botlish_fn_27+0x2f0>
    29d9:	mov    rcx,r12
    29dc:	mov    rdx,r15
    29df:	mov    rdi,rbx
    29e2:	call   29e7 <botlish_fn_27+0x2e7>
			29e3: R_X86_64_PLT32	rt_mutarray_set-0x4
    29e7:	test   rax,rax
    29ea:	jne    2a15 <botlish_fn_27+0x315>
    29f0:	xor    rax,rax
    29f3:	mov    rbx,QWORD PTR [rsp+0x40]
    29f8:	mov    r12,QWORD PTR [rsp+0x48]
    29fd:	mov    r13,QWORD PTR [rsp+0x50]
    2a02:	mov    r14,QWORD PTR [rsp+0x58]
    2a07:	mov    r15,QWORD PTR [rsp+0x60]
    2a0c:	add    rsp,0x70
    2a10:	mov    rsp,rbp
    2a13:	pop    rbp
    2a14:	ret
    2a15:	mov    eax,0xa
    2a1a:	mov    rbx,QWORD PTR [rsp+0x40]
    2a1f:	mov    r12,QWORD PTR [rsp+0x48]
    2a24:	mov    r13,QWORD PTR [rsp+0x50]
    2a29:	mov    r14,QWORD PTR [rsp+0x58]
    2a2e:	mov    r15,QWORD PTR [rsp+0x60]
    2a33:	add    rsp,0x70
    2a37:	mov    rsp,rbp
    2a3a:	pop    rbp
    2a3b:	ret
    2a3c:	add    BYTE PTR [rax],al
    2a3e:	add    BYTE PTR [rax],al
    2a40:	(bad)
    2a41:	add    BYTE PTR [rax],al
    2a43:	add    BYTE PTR [rax],al
    2a45:	add    BYTE PTR [rax],al
	...

0000000000002a48 <botlish_entry_27: ht_set<mutarray, str, str>>:
    2a48:	push   rbp
    2a49:	mov    rbp,rsp
    2a4c:	mov    rsi,QWORD PTR [rdx]
    2a4f:	mov    r8,QWORD PTR [rdx+0x8]
    2a53:	mov    rcx,QWORD PTR [rdx+0x10]
    2a57:	mov    rdx,r8
    2a5a:	call   2a5f <botlish_entry_27+0x17>
			2a5b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2a5f:	mov    rsp,rbp
    2a62:	pop    rbp
    2a63:	ret
    2a64:	add    BYTE PTR [rax],al
	...

0000000000002a68 <botlish_fn_28: ht_delete<mutarray, str>>:
    2a68:	push   rbp
    2a69:	mov    rbp,rsp
    2a6c:	sub    rsp,0x40
    2a70:	mov    QWORD PTR [rsp+0x20],rbx
    2a75:	mov    QWORD PTR [rsp+0x28],r12
    2a7a:	mov    QWORD PTR [rsp+0x30],r13
    2a7f:	mov    QWORD PTR [rsp+0x38],r14
    2a84:	mov    rbx,rdi
    2a87:	mov    QWORD PTR [rsp+0x10],0x0
    2a90:	mov    QWORD PTR [rsp+0x18],0x0
    2a99:	mov    QWORD PTR [rsp],rsi
    2a9d:	mov    r12,rsi
    2aa0:	mov    QWORD PTR [rsp+0x8],rdx
    2aa5:	mov    r13,rdx
    2aa8:	mov    rdx,r13
    2aab:	mov    rsi,r12
    2aae:	mov    rdi,rbx
    2ab1:	call   2ab6 <botlish_fn_28+0x4e>
			2ab2: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    2ab6:	test   rax,rax
    2ab9:	je     2e61 <botlish_fn_28+0x3f9>
    2abf:	mov    QWORD PTR [rsp+0x10],rax
    2ac4:	mov    rcx,rax
    2ac7:	mov    rdx,r13
    2aca:	mov    rsi,r12
    2acd:	mov    rdi,rbx
    2ad0:	call   2ad5 <botlish_fn_28+0x6d>
			2ad1: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    2ad5:	mov    rcx,rax
    2ad8:	mov    r13,rax
    2adb:	test   rax,rcx
    2ade:	je     2e61 <botlish_fn_28+0x3f9>
    2ae4:	mov    rax,r13
    2ae7:	mov    QWORD PTR [rsp+0x8],rax
    2aec:	test   rax,0x1
    2af2:	jne    2b1d <botlish_fn_28+0xb5>
    2af8:	mov    edx,0x1
    2afd:	mov    rsi,r13
    2b00:	mov    rdi,rbx
    2b03:	call   2b08 <botlish_fn_28+0xa0>
			2b04: R_X86_64_PLT32	rt_int_cmp-0x4
    2b08:	mov    ecx,0x2
    2b0d:	test   rax,rax
    2b10:	cmovl  rcx,QWORD PTR [rip+0x3b0]        # 2ec8 <botlish_fn_28+0x460>
    2b18:	jmp    2b33 <botlish_fn_28+0xcb>
    2b1d:	mov    ecx,0x2
    2b22:	mov    rax,r13
    2b25:	mov    rdx,r13
    2b28:	test   rax,rdx
    2b2b:	cmovle rcx,QWORD PTR [rip+0x395]        # 2ec8 <botlish_fn_28+0x460>
    2b33:	cmp    rcx,0x6
    2b37:	je     2ea3 <botlish_fn_28+0x43b>
    2b3d:	mov    rsi,r12
    2b40:	mov    rdi,rbx
    2b43:	call   2b48 <botlish_fn_28+0xe0>
			2b44: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    2b48:	test   rax,rax
    2b4b:	je     2e61 <botlish_fn_28+0x3f9>
    2b51:	mov    QWORD PTR [rsp+0x10],rax
    2b56:	mov    r14,rax
    2b59:	mov    rdi,rbx
    2b5c:	call   2b61 <botlish_fn_28+0xf9>
			2b5d: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    2b61:	test   rax,rax
    2b64:	je     2e61 <botlish_fn_28+0x3f9>
    2b6a:	xor    ecx,ecx
    2b6c:	mov    rax,r14
    2b6f:	test   rax,0x7
    2b75:	je     2b83 <botlish_fn_28+0x11b>
    2b7b:	mov    r14,rax
    2b7e:	jmp    2b91 <botlish_fn_28+0x129>
    2b83:	movzx  rcx,BYTE PTR [rax]
    2b87:	mov    r14,rax
    2b8a:	rex cmp cl,0x8
    2b8e:	sete   cl
    2b91:	test   cl,cl
    2b93:	jne    2bb6 <botlish_fn_28+0x14e>
    2b99:	mov    rdi,rbx
    2b9c:	mov    rdx,QWORD PTR [rdi+0x10]
    2ba0:	mov    rcx,QWORD PTR [rdx+0x20]
    2ba4:	mov    edx,0x8
    2ba9:	mov    rsi,r14
    2bac:	call   2bb1 <botlish_fn_28+0x149>
			2bad: R_X86_64_PLT32	rt_type_error-0x4
    2bb1:	jmp    2e61 <botlish_fn_28+0x3f9>
    2bb6:	mov    rsi,r14
    2bb9:	mov    ecx,0x5
    2bbe:	mov    rdx,r13
    2bc1:	mov    rdi,rbx
    2bc4:	call   2bc9 <botlish_fn_28+0x161>
			2bc5: R_X86_64_PLT32	rt_mutarray_set-0x4
    2bc9:	test   rax,rax
    2bcc:	je     2e61 <botlish_fn_28+0x3f9>
    2bd2:	mov    rsi,r12
    2bd5:	mov    rdi,rbx
    2bd8:	call   2bdd <botlish_fn_28+0x175>
			2bd9: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    2bdd:	test   rax,rax
    2be0:	je     2e61 <botlish_fn_28+0x3f9>
    2be6:	xor    edi,edi
    2be8:	test   rax,0x7
    2bee:	je     2bfc <botlish_fn_28+0x194>
    2bf4:	mov    rsi,rax
    2bf7:	jmp    2c0b <botlish_fn_28+0x1a3>
    2bfc:	movzx  rcx,BYTE PTR [rax]
    2c00:	mov    rsi,rax
    2c03:	rex cmp cl,0x8
    2c07:	sete   dil
    2c0b:	test   dil,dil
    2c0e:	jne    2c2e <botlish_fn_28+0x1c6>
    2c14:	mov    rdi,rbx
    2c17:	mov    rax,QWORD PTR [rdi+0x10]
    2c1b:	mov    rcx,QWORD PTR [rax+0x20]
    2c1f:	mov    edx,0x8
    2c24:	call   2c29 <botlish_fn_28+0x1c1>
			2c25: R_X86_64_PLT32	rt_type_error-0x4
    2c29:	jmp    2e61 <botlish_fn_28+0x3f9>
    2c2e:	mov    ecx,0xa
    2c33:	mov    rdx,r13
    2c36:	mov    rdi,rbx
    2c39:	call   2c3e <botlish_fn_28+0x1d6>
			2c3a: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c3e:	test   rax,rax
    2c41:	je     2e61 <botlish_fn_28+0x3f9>
    2c47:	mov    rsi,r12
    2c4a:	mov    rdi,rbx
    2c4d:	call   2c52 <botlish_fn_28+0x1ea>
			2c4e: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2c52:	test   rax,rax
    2c55:	je     2e61 <botlish_fn_28+0x3f9>
    2c5b:	xor    ecx,ecx
    2c5d:	test   rax,0x7
    2c63:	je     2c71 <botlish_fn_28+0x209>
    2c69:	mov    rsi,rax
    2c6c:	jmp    2c7f <botlish_fn_28+0x217>
    2c71:	movzx  rcx,BYTE PTR [rax]
    2c75:	mov    rsi,rax
    2c78:	rex cmp cl,0x8
    2c7c:	sete   cl
    2c7f:	test   cl,cl
    2c81:	jne    2ca1 <botlish_fn_28+0x239>
    2c87:	mov    rdi,rbx
    2c8a:	mov    rax,QWORD PTR [rdi+0x10]
    2c8e:	mov    rcx,QWORD PTR [rax+0x20]
    2c92:	mov    edx,0x8
    2c97:	call   2c9c <botlish_fn_28+0x234>
			2c98: R_X86_64_PLT32	rt_type_error-0x4
    2c9c:	jmp    2e61 <botlish_fn_28+0x3f9>
    2ca1:	mov    ecx,0xa
    2ca6:	mov    rdx,r13
    2ca9:	mov    rdi,rbx
    2cac:	call   2cb1 <botlish_fn_28+0x249>
			2cad: R_X86_64_PLT32	rt_mutarray_set-0x4
    2cb1:	test   rax,rax
    2cb4:	je     2e61 <botlish_fn_28+0x3f9>
    2cba:	mov    QWORD PTR [rsp+0x8],0x7
    2cc3:	mov    rsi,r12
    2cc6:	mov    rdi,rbx
    2cc9:	call   2cce <botlish_fn_28+0x266>
			2cca: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2cce:	test   rax,rax
    2cd1:	je     2e61 <botlish_fn_28+0x3f9>
    2cd7:	mov    QWORD PTR [rsp+0x10],rax
    2cdc:	mov    QWORD PTR [rsp+0x18],0x3
    2ce5:	mov    ecx,0x1
    2cea:	test   rax,0x1
    2cf0:	je     2cfe <botlish_fn_28+0x296>
    2cf6:	mov    rsi,rax
    2cf9:	jmp    2d22 <botlish_fn_28+0x2ba>
    2cfe:	xor    ecx,ecx
    2d00:	test   rax,0x7
    2d06:	je     2d14 <botlish_fn_28+0x2ac>
    2d0c:	mov    rsi,rax
    2d0f:	jmp    2d22 <botlish_fn_28+0x2ba>
    2d14:	movzx  rcx,BYTE PTR [rax]
    2d18:	mov    rsi,rax
    2d1b:	rex cmp cl,0x1
    2d1f:	sete   cl
    2d22:	test   cl,cl
    2d24:	jne    2d42 <botlish_fn_28+0x2da>
    2d2a:	mov    rdi,rbx
    2d2d:	mov    rax,QWORD PTR [rdi+0x10]
    2d31:	mov    rcx,QWORD PTR [rax+0x28]
    2d35:	xor    rdx,rdx
    2d38:	call   2d3d <botlish_fn_28+0x2d5>
			2d39: R_X86_64_PLT32	rt_type_error-0x4
    2d3d:	jmp    2e61 <botlish_fn_28+0x3f9>
    2d42:	test   rsi,0x1
    2d49:	je     2d68 <botlish_fn_28+0x300>
    2d4f:	mov    rcx,rsi
    2d52:	sub    rcx,0x3
    2d56:	seto   al
    2d59:	add    rcx,0x1
    2d60:	test   al,al
    2d62:	je     2d78 <botlish_fn_28+0x310>
    2d68:	mov    edx,0x3
    2d6d:	mov    rdi,rbx
    2d70:	call   2d75 <botlish_fn_28+0x30d>
			2d71: R_X86_64_PLT32	rt_int_sub-0x4
    2d75:	mov    rcx,rax
    2d78:	mov    edx,0x7
    2d7d:	mov    rsi,r12
    2d80:	mov    rdi,rbx
    2d83:	call   2d88 <botlish_fn_28+0x320>
			2d84: R_X86_64_PLT32	rt_mutarray_set-0x4
    2d88:	test   rax,rax
    2d8b:	je     2e61 <botlish_fn_28+0x3f9>
    2d91:	mov    QWORD PTR [rsp+0x8],0x9
    2d9a:	mov    rsi,r12
    2d9d:	mov    rdi,rbx
    2da0:	call   2da5 <botlish_fn_28+0x33d>
			2da1: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2da5:	test   rax,rax
    2da8:	je     2e61 <botlish_fn_28+0x3f9>
    2dae:	mov    QWORD PTR [rsp+0x10],rax
    2db3:	mov    QWORD PTR [rsp+0x18],0x3
    2dbc:	mov    ecx,0x1
    2dc1:	test   rax,0x1
    2dc7:	je     2dd5 <botlish_fn_28+0x36d>
    2dcd:	mov    rsi,rax
    2dd0:	jmp    2df9 <botlish_fn_28+0x391>
    2dd5:	xor    ecx,ecx
    2dd7:	test   rax,0x7
    2ddd:	je     2deb <botlish_fn_28+0x383>
    2de3:	mov    rsi,rax
    2de6:	jmp    2df9 <botlish_fn_28+0x391>
    2deb:	movzx  r11,BYTE PTR [rax]
    2def:	mov    rsi,rax
    2df2:	cmp    r11b,0x1
    2df6:	sete   cl
    2df9:	test   cl,cl
    2dfb:	jne    2e19 <botlish_fn_28+0x3b1>
    2e01:	mov    rdi,rbx
    2e04:	mov    rax,QWORD PTR [rdi+0x10]
    2e08:	mov    rcx,QWORD PTR [rax+0x10]
    2e0c:	xor    rdx,rdx
    2e0f:	call   2e14 <botlish_fn_28+0x3ac>
			2e10: R_X86_64_PLT32	rt_type_error-0x4
    2e14:	jmp    2e61 <botlish_fn_28+0x3f9>
    2e19:	test   rsi,0x1
    2e20:	je     2e38 <botlish_fn_28+0x3d0>
    2e26:	mov    rcx,rsi
    2e29:	add    rcx,0x2
    2e2d:	seto   al
    2e30:	test   al,al
    2e32:	je     2e48 <botlish_fn_28+0x3e0>
    2e38:	mov    edx,0x3
    2e3d:	mov    rdi,rbx
    2e40:	call   2e45 <botlish_fn_28+0x3dd>
			2e41: R_X86_64_PLT32	rt_int_add-0x4
    2e45:	mov    rcx,rax
    2e48:	mov    edx,0x9
    2e4d:	mov    rsi,r12
    2e50:	mov    rdi,rbx
    2e53:	call   2e58 <botlish_fn_28+0x3f0>
			2e54: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e58:	test   rax,rax
    2e5b:	jne    2e81 <botlish_fn_28+0x419>
    2e61:	xor    rax,rax
    2e64:	mov    rbx,QWORD PTR [rsp+0x20]
    2e69:	mov    r12,QWORD PTR [rsp+0x28]
    2e6e:	mov    r13,QWORD PTR [rsp+0x30]
    2e73:	mov    r14,QWORD PTR [rsp+0x38]
    2e78:	add    rsp,0x40
    2e7c:	mov    rsp,rbp
    2e7f:	pop    rbp
    2e80:	ret
    2e81:	mov    eax,0xa
    2e86:	mov    rbx,QWORD PTR [rsp+0x20]
    2e8b:	mov    r12,QWORD PTR [rsp+0x28]
    2e90:	mov    r13,QWORD PTR [rsp+0x30]
    2e95:	mov    r14,QWORD PTR [rsp+0x38]
    2e9a:	add    rsp,0x40
    2e9e:	mov    rsp,rbp
    2ea1:	pop    rbp
    2ea2:	ret
    2ea3:	mov    eax,0xa
    2ea8:	mov    rbx,QWORD PTR [rsp+0x20]
    2ead:	mov    r12,QWORD PTR [rsp+0x28]
    2eb2:	mov    r13,QWORD PTR [rsp+0x30]
    2eb7:	mov    r14,QWORD PTR [rsp+0x38]
    2ebc:	add    rsp,0x40
    2ec0:	mov    rsp,rbp
    2ec3:	pop    rbp
    2ec4:	ret
    2ec5:	add    BYTE PTR [rax],al
    2ec7:	add    BYTE PTR [rsi],al
    2ec9:	add    BYTE PTR [rax],al
    2ecb:	add    BYTE PTR [rax],al
    2ecd:	add    BYTE PTR [rax],al
	...

0000000000002ed0 <botlish_entry_28: ht_delete<mutarray, str>>:
    2ed0:	push   rbp
    2ed1:	mov    rbp,rsp
    2ed4:	mov    rsi,QWORD PTR [rdx]
    2ed7:	mov    rdx,QWORD PTR [rdx+0x8]
    2edb:	call   2ee0 <botlish_entry_28+0x10>
			2edc: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    2ee0:	mov    rsp,rbp
    2ee3:	pop    rbp
    2ee4:	ret
    2ee5:	add    BYTE PTR [rax],al
	...

0000000000002ee8 <botlish_fn_29: sample<generic>>:
    2ee8:	push   rbp
    2ee9:	mov    rbp,rsp
    2eec:	sub    rsp,0xa0
    2ef3:	mov    QWORD PTR [rsp+0x70],rbx
    2ef8:	mov    QWORD PTR [rsp+0x78],r12
    2efd:	mov    QWORD PTR [rsp+0x80],r13
    2f05:	mov    QWORD PTR [rsp+0x88],r14
    2f0d:	mov    QWORD PTR [rsp+0x90],r15
    2f15:	mov    r14,rdi
    2f18:	mov    QWORD PTR [rsp],0x0
    2f20:	mov    QWORD PTR [rsp+0x8],0x0
    2f29:	mov    QWORD PTR [rsp+0x10],0x0
    2f32:	mov    QWORD PTR [rsp+0x18],0x0
    2f3b:	mov    QWORD PTR [rsp+0x20],0x0
    2f44:	mov    QWORD PTR [rsp+0x28],0x0
    2f4d:	mov    rdi,r14
    2f50:	call   2f55 <botlish_fn_29+0x6d>
			2f51: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    2f55:	mov    rcx,rax
    2f58:	mov    r15,rax
    2f5b:	test   rax,rcx
    2f5e:	je     319e <botlish_fn_29+0x2b6>
    2f64:	mov    rax,r15
    2f67:	mov    QWORD PTR [rsp],rax
    2f6b:	mov    rdi,r14
    2f6e:	mov    rax,QWORD PTR [rdi+0x10]
    2f72:	mov    rdx,QWORD PTR [rax+0x30]
    2f76:	mov    QWORD PTR [rsp+0x8],rdx
    2f7b:	mov    rax,QWORD PTR [rdi+0x10]
    2f7f:	mov    rcx,QWORD PTR [rax+0x38]
    2f83:	mov    QWORD PTR [rsp+0x10],rcx
    2f88:	mov    rsi,r15
    2f8b:	call   2f90 <botlish_fn_29+0xa8>
			2f8c: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2f90:	test   rax,rax
    2f93:	je     319e <botlish_fn_29+0x2b6>
    2f99:	mov    rdi,r14
    2f9c:	mov    rsi,QWORD PTR [rdi+0x10]
    2fa0:	mov    rdx,QWORD PTR [rsi+0x40]
    2fa4:	mov    QWORD PTR [rsp+0x8],rdx
    2fa9:	mov    rsi,QWORD PTR [rdi+0x10]
    2fad:	mov    rcx,QWORD PTR [rsi+0x48]
    2fb1:	mov    QWORD PTR [rsp+0x10],rcx
    2fb6:	mov    rsi,r15
    2fb9:	call   2fbe <botlish_fn_29+0xd6>
			2fba: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2fbe:	test   rax,rax
    2fc1:	je     319e <botlish_fn_29+0x2b6>
    2fc7:	mov    rdi,r14
    2fca:	mov    r9,QWORD PTR [rdi+0x10]
    2fce:	mov    rdx,QWORD PTR [r9+0x30]
    2fd2:	mov    QWORD PTR [rsp+0x8],rdx
    2fd7:	mov    r10,QWORD PTR [rdi+0x10]
    2fdb:	mov    rcx,QWORD PTR [r10+0x50]
    2fdf:	mov    QWORD PTR [rsp+0x10],rcx
    2fe4:	mov    rsi,r15
    2fe7:	call   2fec <botlish_fn_29+0x104>
			2fe8: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    2fec:	test   rax,rax
    2fef:	je     319e <botlish_fn_29+0x2b6>
    2ff5:	mov    rdi,r14
    2ff8:	mov    rax,QWORD PTR [rdi+0x10]
    2ffc:	mov    rdx,QWORD PTR [rax+0x40]
    3000:	mov    QWORD PTR [rsp+0x8],rdx
    3005:	mov    rsi,r15
    3008:	call   300d <botlish_fn_29+0x125>
			3009: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    300d:	mov    rbx,rax
    3010:	test   rbx,rbx
    3013:	je     319e <botlish_fn_29+0x2b6>
    3019:	mov    QWORD PTR [rsp+0x8],rbx
    301e:	mov    rdi,r14
    3021:	mov    rax,QWORD PTR [rdi+0x10]
    3025:	mov    rdx,QWORD PTR [rax+0x40]
    3029:	mov    QWORD PTR [rsp+0x10],rdx
    302e:	mov    rsi,r15
    3031:	call   3036 <botlish_fn_29+0x14e>
			3032: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3036:	test   rax,rax
    3039:	je     319e <botlish_fn_29+0x2b6>
    303f:	mov    rdi,r14
    3042:	mov    rax,QWORD PTR [rdi+0x10]
    3046:	mov    rdx,QWORD PTR [rax+0x30]
    304a:	mov    QWORD PTR [rsp+0x10],rdx
    304f:	mov    rsi,r15
    3052:	call   3057 <botlish_fn_29+0x16f>
			3053: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    3057:	test   rax,rax
    305a:	je     319e <botlish_fn_29+0x2b6>
    3060:	mov    rdi,r14
    3063:	mov    rcx,QWORD PTR [rdi+0x10]
    3067:	mov    rdx,QWORD PTR [rcx+0x50]
    306b:	mov    rcx,rax
    306e:	and    rcx,rdx
    3071:	mov    rsi,rax
    3074:	test   rcx,0x1
    307b:	jne    3097 <botlish_fn_29+0x1af>
    3081:	mov    rdi,r14
    3084:	call   3089 <botlish_fn_29+0x1a1>
			3085: R_X86_64_PLT32	rt_value_eq-0x4
    3089:	test   rax,rax
    308c:	je     319e <botlish_fn_29+0x2b6>
    3092:	jmp    30a7 <botlish_fn_29+0x1bf>
    3097:	mov    eax,0x2
    309c:	cmp    rsi,rdx
    309f:	cmove  rax,QWORD PTR [rip+0x159]        # 3200 <botlish_fn_29+0x318>
    30a7:	mov    QWORD PTR [rsp+0x10],rax
    30ac:	mov    rdi,r14
    30af:	mov    QWORD PTR [rsp+0x60],rax
    30b4:	mov    rax,QWORD PTR [rdi+0x10]
    30b8:	mov    rdx,QWORD PTR [rax+0x40]
    30bc:	mov    QWORD PTR [rsp+0x18],rdx
    30c1:	mov    rsi,r15
    30c4:	call   30c9 <botlish_fn_29+0x1e1>
			30c5: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    30c9:	mov    r12,rax
    30cc:	test   r12,r12
    30cf:	je     319e <botlish_fn_29+0x2b6>
    30d5:	mov    QWORD PTR [rsp+0x18],r12
    30da:	mov    rdi,r14
    30dd:	mov    rax,QWORD PTR [rdi+0x10]
    30e1:	mov    rdx,QWORD PTR [rax+0x58]
    30e5:	mov    QWORD PTR [rsp+0x20],rdx
    30ea:	mov    rsi,r15
    30ed:	call   30f2 <botlish_fn_29+0x20a>
			30ee: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    30f2:	mov    r13,rax
    30f5:	test   r13,r13
    30f8:	je     319e <botlish_fn_29+0x2b6>
    30fe:	mov    QWORD PTR [rsp+0x20],r13
    3103:	mov    rdi,r14
    3106:	mov    rax,QWORD PTR [rdi+0x10]
    310a:	mov    rdx,QWORD PTR [rax+0x58]
    310e:	mov    QWORD PTR [rsp+0x28],rdx
    3113:	mov    rsi,r15
    3116:	call   311b <botlish_fn_29+0x233>
			3117: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    311b:	test   rax,rax
    311e:	mov    rsi,rax
    3121:	je     319e <botlish_fn_29+0x2b6>
    3127:	mov    edx,0xa
    312c:	mov    rdi,r14
    312f:	call   3134 <botlish_fn_29+0x24c>
			3130: R_X86_64_PLT32	rt_value_eq-0x4
    3134:	test   rax,rax
    3137:	je     319e <botlish_fn_29+0x2b6>
    313d:	mov    QWORD PTR [rsp+0x28],rax
    3142:	mov    rsi,r15
    3145:	mov    r15,rax
    3148:	mov    rdi,r14
    314b:	call   3150 <botlish_fn_29+0x268>
			314c: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3150:	test   rax,rax
    3153:	je     319e <botlish_fn_29+0x2b6>
    3159:	mov    QWORD PTR [rsp],rax
    315d:	lea    rdx,[rsp+0x30]
    3162:	mov    rsi,QWORD PTR [rsp+0x60]
    3167:	mov    QWORD PTR [rsp+0x30],rsi
    316c:	mov    QWORD PTR [rsp+0x38],rbx
    3171:	mov    QWORD PTR [rsp+0x40],r12
    3176:	mov    QWORD PTR [rsp+0x48],r13
    317b:	mov    r8,r15
    317e:	mov    QWORD PTR [rsp+0x50],r8
    3183:	mov    QWORD PTR [rsp+0x58],rax
    3188:	mov    esi,0x6
    318d:	mov    rdi,r14
    3190:	call   3195 <botlish_fn_29+0x2ad>
			3191: R_X86_64_PLT32	rt_list_new-0x4
    3195:	test   rax,rax
    3198:	jne    31cf <botlish_fn_29+0x2e7>
    319e:	xor    rax,rax
    31a1:	mov    rbx,QWORD PTR [rsp+0x70]
    31a6:	mov    r12,QWORD PTR [rsp+0x78]
    31ab:	mov    r13,QWORD PTR [rsp+0x80]
    31b3:	mov    r14,QWORD PTR [rsp+0x88]
    31bb:	mov    r15,QWORD PTR [rsp+0x90]
    31c3:	add    rsp,0xa0
    31ca:	mov    rsp,rbp
    31cd:	pop    rbp
    31ce:	ret
    31cf:	mov    rbx,QWORD PTR [rsp+0x70]
    31d4:	mov    r12,QWORD PTR [rsp+0x78]
    31d9:	mov    r13,QWORD PTR [rsp+0x80]
    31e1:	mov    r14,QWORD PTR [rsp+0x88]
    31e9:	mov    r15,QWORD PTR [rsp+0x90]
    31f1:	add    rsp,0xa0
    31f8:	mov    rsp,rbp
    31fb:	pop    rbp
    31fc:	ret
    31fd:	add    BYTE PTR [rax],al
    31ff:	add    BYTE PTR [rsi],al
    3201:	add    BYTE PTR [rax],al
    3203:	add    BYTE PTR [rax],al
    3205:	add    BYTE PTR [rax],al
	...

0000000000003208 <botlish_entry_29: sample<generic>>:
    3208:	push   rbp
    3209:	mov    rbp,rsp
    320c:	call   3211 <botlish_entry_29+0x9>
			320d: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    3211:	mov    rsp,rbp
    3214:	pop    rbp
    3215:	ret

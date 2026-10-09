; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10843  (per function: 45 427 385 70 69 69 46 170 236 636 1040 333 253 380 402 616 654 801 673 920 684 925 862 147)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> ht_alloc<int>
;   botlish_fn_2 / botlish_entry_2 -> ht_alloc<int>
;   botlish_fn_3 / botlish_entry_3 -> ht_new<generic>
;   botlish_fn_4 / botlish_entry_4 -> ht_size<HashTable>
;   botlish_fn_5 / botlish_entry_5 -> ht_tombstones<HashTable>
;   botlish_fn_6 / botlish_entry_6 -> ht_capacity<HashTable>
;   botlish_fn_7 / botlish_entry_7 -> ht_probe_start<HashTable, str>
;   botlish_fn_8 / botlish_entry_8 -> ht_probe_next<HashTable, int>
;   botlish_fn_9 / botlish_entry_9 -> ht_find_get<HashTable, str, int>
;   botlish_fn_10 / botlish_entry_10 -> ht_find_insert<HashTable, str, int, int>
;   botlish_fn_11 / botlish_entry_11 -> ht_get<HashTable, str>
;   botlish_fn_12 / botlish_entry_12 -> ht_contains<HashTable, str>
;   botlish_fn_13 / botlish_entry_13 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_14 / botlish_entry_14 -> ht_rehash_insert<HashTable, int, any, any>
;   botlish_fn_15 / botlish_entry_15 -> ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
;   botlish_fn_16 / botlish_entry_16 -> ht_rehash<HashTable, int>
;   botlish_fn_17 / botlish_entry_17 -> ht_should_grow<HashTable>
;   botlish_fn_18 / botlish_entry_18 -> ht_grow_or_clean<HashTable>
;   botlish_fn_19 / botlish_entry_19 -> ht_place<HashTable, int, str, str>
;   botlish_fn_20 / botlish_entry_20 -> ht_set<HashTable, str, str>
;   botlish_fn_21 / botlish_entry_21 -> ht_delete<HashTable, str>
;   botlish_fn_22 / botlish_entry_22 -> sample_checks<generic>
;   botlish_fn_23 / botlish_entry_23 -> sample<generic>


hashtable.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
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

000000000000002d <botlish_fn_1: ht_alloc<int>>:
      2d:	push   rbp
      2e:	mov    rbp,rsp
      31:	sub    rsp,0x70
      35:	mov    QWORD PTR [rsp+0x40],rbx
      3a:	mov    QWORD PTR [rsp+0x48],r12
      3f:	mov    QWORD PTR [rsp+0x50],r13
      44:	mov    QWORD PTR [rsp+0x58],r14
      49:	mov    QWORD PTR [rsp+0x60],r15
      4e:	mov    r12,rdi
      51:	mov    QWORD PTR [rsp+0x10],0x0
      5a:	mov    QWORD PTR [rsp+0x18],0x0
      63:	mov    QWORD PTR [rsp],rsi
      67:	mov    r13,rsi
      6a:	mov    esi,0x5
      6f:	mov    QWORD PTR [rsp+0x8],0x5
      78:	mov    rdi,r12
      7b:	call   80 <botlish_fn_1+0x53>
			7c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      80:	mov    rcx,rax
      83:	mov    r14,rax
      86:	test   rax,rcx
      89:	je     118 <botlish_fn_1+0xeb>
      8f:	mov    rax,r14
      92:	mov    QWORD PTR [rsp+0x8],rax
      97:	mov    ebx,0x1
      9c:	mov    rcx,rbx
      9f:	mov    rdx,rbx
      a2:	mov    rsi,r14
      a5:	mov    rdi,r12
      a8:	call   ad <botlish_fn_1+0x80>
			a9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
      ad:	mov    edx,0x3
      b2:	mov    rcx,rbx
      b5:	mov    rsi,r14
      b8:	mov    rdi,r12
      bb:	call   c0 <botlish_fn_1+0x93>
			bc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
      c0:	mov    QWORD PTR [rsp+0x10],0x1
      c9:	mov    rdx,rbx
      cc:	mov    rsi,r13
      cf:	mov    rdi,r12
      d2:	call   d7 <botlish_fn_1+0xaa>
			d3: R_X86_64_PLT32	rt_mutarray_create-0x4
      d7:	test   rax,rax
      da:	je     118 <botlish_fn_1+0xeb>
      e0:	mov    QWORD PTR [rsp+0x10],rax
      e5:	mov    rbx,rax
      e8:	mov    rsi,r13
      eb:	mov    rdi,r12
      ee:	call   f3 <botlish_fn_1+0xc6>
			ef: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      f3:	test   rax,rax
      f6:	je     118 <botlish_fn_1+0xeb>
      fc:	mov    QWORD PTR [rsp+0x18],rax
     101:	mov    rsi,r13
     104:	mov    r15,rax
     107:	mov    rdi,r12
     10a:	call   10f <botlish_fn_1+0xe2>
			10b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     10f:	test   rax,rax
     112:	jne    13d <botlish_fn_1+0x110>
     118:	xor    rax,rax
     11b:	mov    rbx,QWORD PTR [rsp+0x40]
     120:	mov    r12,QWORD PTR [rsp+0x48]
     125:	mov    r13,QWORD PTR [rsp+0x50]
     12a:	mov    r14,QWORD PTR [rsp+0x58]
     12f:	mov    r15,QWORD PTR [rsp+0x60]
     134:	add    rsp,0x70
     138:	mov    rsp,rbp
     13b:	pop    rbp
     13c:	ret
     13d:	mov    QWORD PTR [rsp],rax
     141:	lea    rcx,[rsp+0x20]
     146:	mov    rdx,rbx
     149:	mov    QWORD PTR [rsp+0x20],rdx
     14e:	mov    rsi,r15
     151:	mov    QWORD PTR [rsp+0x28],rsi
     156:	mov    QWORD PTR [rsp+0x30],rax
     15b:	mov    rax,r14
     15e:	mov    QWORD PTR [rsp+0x38],rax
     163:	xor    rsi,rsi
     166:	mov    edx,0x4
     16b:	mov    rdi,r12
     16e:	call   173 <botlish_fn_1+0x146>
			16f: R_X86_64_PLT32	rt_struct_new-0x4
     173:	mov    rbx,QWORD PTR [rsp+0x40]
     178:	mov    r12,QWORD PTR [rsp+0x48]
     17d:	mov    r13,QWORD PTR [rsp+0x50]
     182:	mov    r14,QWORD PTR [rsp+0x58]
     187:	mov    r15,QWORD PTR [rsp+0x60]
     18c:	add    rsp,0x70
     190:	mov    rsp,rbp
     193:	pop    rbp
     194:	ret

0000000000000195 <botlish_entry_1: ht_alloc<int>>:
     195:	push   rbp
     196:	mov    rbp,rsp
     199:	mov    rsi,QWORD PTR [rdx]
     19c:	call   1a1 <botlish_entry_1+0xc>
			19d: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     1a1:	mov    rsp,rbp
     1a4:	pop    rbp
     1a5:	ret

00000000000001a6 <botlish_fn_2: ht_alloc<int>>:
     1a6:	push   rbp
     1a7:	mov    rbp,rsp
     1aa:	sub    rsp,0x60
     1ae:	mov    QWORD PTR [rsp+0x30],rbx
     1b3:	mov    QWORD PTR [rsp+0x38],r12
     1b8:	mov    QWORD PTR [rsp+0x40],r13
     1bd:	mov    QWORD PTR [rsp+0x48],r14
     1c2:	mov    QWORD PTR [rsp+0x50],r15
     1c7:	mov    r13,rdi
     1ca:	mov    r15,rdx
     1cd:	mov    QWORD PTR [rsp+0x10],0x0
     1d6:	mov    QWORD PTR [rsp+0x18],0x0
     1df:	mov    QWORD PTR [rsp],rsi
     1e3:	mov    r12,rsi
     1e6:	mov    esi,0x5
     1eb:	mov    QWORD PTR [rsp+0x8],0x5
     1f4:	mov    rdi,r13
     1f7:	call   1fc <botlish_fn_2+0x56>
			1f8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     1fc:	mov    rcx,rax
     1ff:	mov    r14,rax
     202:	test   rax,rcx
     205:	je     296 <botlish_fn_2+0xf0>
     20b:	mov    rax,r14
     20e:	mov    QWORD PTR [rsp+0x8],rax
     213:	mov    ebx,0x1
     218:	mov    rcx,rbx
     21b:	mov    rdx,rbx
     21e:	mov    rsi,r14
     221:	mov    rdi,r13
     224:	call   229 <botlish_fn_2+0x83>
			225: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     229:	mov    edx,0x3
     22e:	mov    rcx,rbx
     231:	mov    rsi,r14
     234:	mov    rdi,r13
     237:	call   23c <botlish_fn_2+0x96>
			238: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     23c:	mov    QWORD PTR [rsp+0x10],0x1
     245:	mov    rdx,rbx
     248:	mov    rsi,r12
     24b:	mov    rdi,r13
     24e:	call   253 <botlish_fn_2+0xad>
			24f: R_X86_64_PLT32	rt_mutarray_create-0x4
     253:	test   rax,rax
     256:	je     296 <botlish_fn_2+0xf0>
     25c:	mov    QWORD PTR [rsp+0x10],rax
     261:	mov    rbx,rax
     264:	mov    rsi,r12
     267:	mov    rdi,r13
     26a:	call   26f <botlish_fn_2+0xc9>
			26b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     26f:	test   rax,rax
     272:	je     296 <botlish_fn_2+0xf0>
     278:	mov    QWORD PTR [rsp+0x18],rax
     27d:	mov    rsi,r12
     280:	mov    rdi,r13
     283:	mov    QWORD PTR [rsp+0x20],rax
     288:	call   28d <botlish_fn_2+0xe7>
			289: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     28d:	test   rax,rax
     290:	jne    2bb <botlish_fn_2+0x115>
     296:	xor    rax,rax
     299:	mov    rbx,QWORD PTR [rsp+0x30]
     29e:	mov    r12,QWORD PTR [rsp+0x38]
     2a3:	mov    r13,QWORD PTR [rsp+0x40]
     2a8:	mov    r14,QWORD PTR [rsp+0x48]
     2ad:	mov    r15,QWORD PTR [rsp+0x50]
     2b2:	add    rsp,0x60
     2b6:	mov    rsp,rbp
     2b9:	pop    rbp
     2ba:	ret
     2bb:	mov    rcx,QWORD PTR [rsp+0x20]
     2c0:	mov    rdx,r15
     2c3:	mov    QWORD PTR [rdx],rcx
     2c6:	mov    QWORD PTR [rdx+0x8],rax
     2ca:	mov    rax,r14
     2cd:	mov    QWORD PTR [rdx+0x10],rax
     2d1:	mov    rax,rbx
     2d4:	mov    rbx,QWORD PTR [rsp+0x30]
     2d9:	mov    r12,QWORD PTR [rsp+0x38]
     2de:	mov    r13,QWORD PTR [rsp+0x40]
     2e3:	mov    r14,QWORD PTR [rsp+0x48]
     2e8:	mov    r15,QWORD PTR [rsp+0x50]
     2ed:	add    rsp,0x60
     2f1:	mov    rsp,rbp
     2f4:	pop    rbp
     2f5:	ret

00000000000002f6 <botlish_entry_2: ht_alloc<int>>:
     2f6:	push   rbp
     2f7:	mov    rbp,rsp
     2fa:	ud2

00000000000002fc <botlish_fn_3: ht_new<generic>>:
     2fc:	push   rbp
     2fd:	mov    rbp,rsp
     300:	sub    rsp,0x10
     304:	mov    esi,0x11
     309:	mov    QWORD PTR [rsp],0x11
     311:	call   316 <botlish_fn_3+0x1a>
			312: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     316:	test   rax,rax
     319:	jne    32b <botlish_fn_3+0x2f>
     31f:	xor    rax,rax
     322:	add    rsp,0x10
     326:	mov    rsp,rbp
     329:	pop    rbp
     32a:	ret
     32b:	add    rsp,0x10
     32f:	mov    rsp,rbp
     332:	pop    rbp
     333:	ret

0000000000000334 <botlish_entry_3: ht_new<generic>>:
     334:	push   rbp
     335:	mov    rbp,rsp
     338:	call   33d <botlish_entry_3+0x9>
			339: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
     33d:	mov    rsp,rbp
     340:	pop    rbp
     341:	ret

0000000000000342 <botlish_fn_4: ht_size<HashTable>>:
     342:	push   rbp
     343:	mov    rbp,rsp
     346:	mov    r9,QWORD PTR [rsi+0x18]
     34a:	mov    rsi,QWORD PTR [r9+0x18]
     34e:	mov    edx,0x1
     353:	call   358 <botlish_fn_4+0x16>
			354: R_X86_64_PLT32	rt_mutarray_get-0x4
     358:	test   rax,rax
     35b:	jne    369 <botlish_fn_4+0x27>
     361:	xor    rax,rax
     364:	mov    rsp,rbp
     367:	pop    rbp
     368:	ret
     369:	mov    rsp,rbp
     36c:	pop    rbp
     36d:	ret

000000000000036e <botlish_entry_4: ht_size<HashTable>>:
     36e:	push   rbp
     36f:	mov    rbp,rsp
     372:	mov    rsi,QWORD PTR [rdx]
     375:	call   37a <botlish_entry_4+0xc>
			376: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
     37a:	mov    rsp,rbp
     37d:	pop    rbp
     37e:	ret

000000000000037f <botlish_fn_5: ht_tombstones<HashTable>>:
     37f:	push   rbp
     380:	mov    rbp,rsp
     383:	mov    r9,QWORD PTR [rsi+0x18]
     387:	mov    rsi,QWORD PTR [r9+0x18]
     38b:	mov    edx,0x3
     390:	call   395 <botlish_fn_5+0x16>
			391: R_X86_64_PLT32	rt_mutarray_get-0x4
     395:	test   rax,rax
     398:	jne    3a6 <botlish_fn_5+0x27>
     39e:	xor    rax,rax
     3a1:	mov    rsp,rbp
     3a4:	pop    rbp
     3a5:	ret
     3a6:	mov    rsp,rbp
     3a9:	pop    rbp
     3aa:	ret

00000000000003ab <botlish_entry_5: ht_tombstones<HashTable>>:
     3ab:	push   rbp
     3ac:	mov    rbp,rsp
     3af:	mov    rsi,QWORD PTR [rdx]
     3b2:	call   3b7 <botlish_entry_5+0xc>
			3b3: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
     3b7:	mov    rsp,rbp
     3ba:	pop    rbp
     3bb:	ret

00000000000003bc <botlish_fn_6: ht_capacity<HashTable>>:
     3bc:	push   rbp
     3bd:	mov    rbp,rsp
     3c0:	mov    rsi,QWORD PTR [rsi+0x18]
     3c4:	mov    rsi,QWORD PTR [rsi]
     3c7:	call   3cc <botlish_fn_6+0x10>
			3c8: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     3cc:	mov    rsp,rbp
     3cf:	pop    rbp
     3d0:	ret

00000000000003d1 <botlish_entry_6: ht_capacity<HashTable>>:
     3d1:	push   rbp
     3d2:	mov    rbp,rsp
     3d5:	mov    rsi,QWORD PTR [rdx]
     3d8:	call   3dd <botlish_entry_6+0xc>
			3d9: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     3dd:	mov    rsp,rbp
     3e0:	pop    rbp
     3e1:	ret

00000000000003e2 <botlish_fn_7: ht_probe_start<HashTable, str>>:
     3e2:	push   rbp
     3e3:	mov    rbp,rsp
     3e6:	sub    rsp,0x20
     3ea:	mov    QWORD PTR [rsp],r12
     3ee:	mov    QWORD PTR [rsp+0x8],r13
     3f3:	mov    QWORD PTR [rsp+0x10],r14
     3f8:	mov    r12,rdi
     3fb:	mov    r13,rsi
     3fe:	mov    rsi,rdx
     401:	mov    rdi,r12
     404:	call   409 <botlish_fn_7+0x27>
			405: R_X86_64_PLT32	rt_hash-0x4
     409:	test   rax,rax
     40c:	mov    r14,rax
     40f:	je     437 <botlish_fn_7+0x55>
     415:	mov    rsi,r13
     418:	mov    rdi,r12
     41b:	call   420 <botlish_fn_7+0x3e>
			41c: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     420:	mov    rdx,rax
     423:	mov    rsi,r14
     426:	mov    rdi,r12
     429:	call   42e <botlish_fn_7+0x4c>
			42a: R_X86_64_PLT32	rt_int_mod-0x4
     42e:	test   rax,rax
     431:	jne    451 <botlish_fn_7+0x6f>
     437:	xor    rax,rax
     43a:	mov    r12,QWORD PTR [rsp]
     43e:	mov    r13,QWORD PTR [rsp+0x8]
     443:	mov    r14,QWORD PTR [rsp+0x10]
     448:	add    rsp,0x20
     44c:	mov    rsp,rbp
     44f:	pop    rbp
     450:	ret
     451:	mov    r12,QWORD PTR [rsp]
     455:	mov    r13,QWORD PTR [rsp+0x8]
     45a:	mov    r14,QWORD PTR [rsp+0x10]
     45f:	add    rsp,0x20
     463:	mov    rsp,rbp
     466:	pop    rbp
     467:	ret

0000000000000468 <botlish_entry_7: ht_probe_start<HashTable, str>>:
     468:	push   rbp
     469:	mov    rbp,rsp
     46c:	mov    rsi,QWORD PTR [rdx]
     46f:	mov    rdx,QWORD PTR [rdx+0x8]
     473:	call   478 <botlish_entry_7+0x10>
			474: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     478:	mov    rsp,rbp
     47b:	pop    rbp
     47c:	ret

000000000000047d <botlish_fn_8: ht_probe_next<HashTable, int>>:
     47d:	push   rbp
     47e:	mov    rbp,rsp
     481:	sub    rsp,0x40
     485:	mov    QWORD PTR [rsp+0x20],rbx
     48a:	mov    QWORD PTR [rsp+0x28],r12
     48f:	mov    QWORD PTR [rsp+0x30],r14
     494:	mov    r14,rdi
     497:	mov    QWORD PTR [rsp],rsi
     49b:	mov    rbx,rsi
     49e:	mov    QWORD PTR [rsp+0x8],rdx
     4a3:	mov    QWORD PTR [rsp+0x10],0x3
     4ac:	test   rdx,0x1
     4b3:	jne    4c1 <botlish_fn_8+0x44>
     4b9:	mov    rsi,rdx
     4bc:	jmp    4e1 <botlish_fn_8+0x64>
     4c1:	mov    rsi,rdx
     4c4:	add    rsi,0x2
     4c8:	mov    r12,rsi
     4cb:	mov    rsi,rdx
     4ce:	seto   al
     4d1:	test   al,al
     4d3:	jne    4e1 <botlish_fn_8+0x64>
     4d9:	mov    rsi,rbx
     4dc:	jmp    4f4 <botlish_fn_8+0x77>
     4e1:	mov    edx,0x3
     4e6:	mov    rdi,r14
     4e9:	call   4ee <botlish_fn_8+0x71>
			4ea: R_X86_64_PLT32	rt_int_add-0x4
     4ee:	mov    rsi,rbx
     4f1:	mov    r12,rax
     4f4:	mov    rdi,r14
     4f7:	call   4fc <botlish_fn_8+0x7f>
			4f8: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     4fc:	mov    rdx,rax
     4ff:	mov    rsi,r12
     502:	mov    rdi,r14
     505:	call   50a <botlish_fn_8+0x8d>
			506: R_X86_64_PLT32	rt_int_mod-0x4
     50a:	test   rax,rax
     50d:	jne    52e <botlish_fn_8+0xb1>
     513:	xor    rax,rax
     516:	mov    rbx,QWORD PTR [rsp+0x20]
     51b:	mov    r12,QWORD PTR [rsp+0x28]
     520:	mov    r14,QWORD PTR [rsp+0x30]
     525:	add    rsp,0x40
     529:	mov    rsp,rbp
     52c:	pop    rbp
     52d:	ret
     52e:	mov    rbx,QWORD PTR [rsp+0x20]
     533:	mov    r12,QWORD PTR [rsp+0x28]
     538:	mov    r14,QWORD PTR [rsp+0x30]
     53d:	add    rsp,0x40
     541:	mov    rsp,rbp
     544:	pop    rbp
     545:	ret

0000000000000546 <botlish_entry_8: ht_probe_next<HashTable, int>>:
     546:	push   rbp
     547:	mov    rbp,rsp
     54a:	mov    rsi,QWORD PTR [rdx]
     54d:	mov    rdx,QWORD PTR [rdx+0x8]
     551:	call   556 <botlish_entry_8+0x10>
			552: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     556:	mov    rsp,rbp
     559:	pop    rbp
     55a:	ret
     55b:	add    BYTE PTR [rax],al
     55d:	add    BYTE PTR [rax],al
	...

0000000000000560 <botlish_fn_9: ht_find_get<HashTable, str, int>>:
     560:	push   rbp
     561:	mov    rbp,rsp
     564:	sub    rsp,0x50
     568:	mov    QWORD PTR [rsp+0x20],rbx
     56d:	mov    QWORD PTR [rsp+0x28],r12
     572:	mov    QWORD PTR [rsp+0x30],r13
     577:	mov    QWORD PTR [rsp+0x38],r14
     57c:	mov    QWORD PTR [rsp+0x40],r15
     581:	mov    r13,rdi
     584:	mov    QWORD PTR [rsp],rsi
     588:	mov    QWORD PTR [rsp+0x8],rdx
     58d:	mov    rbx,rdx
     590:	mov    QWORD PTR [rsp+0x10],rcx
     595:	mov    r12,rsi
     598:	mov    r14,rcx
     59b:	mov    rax,QWORD PTR [r12+0x18]
     5a0:	mov    rsi,QWORD PTR [rax]
     5a3:	mov    rdx,r14
     5a6:	mov    rdi,r13
     5a9:	call   5ae <botlish_fn_9+0x4e>
			5aa: R_X86_64_PLT32	rt_mutarray_get-0x4
     5ae:	mov    rcx,rax
     5b1:	mov    r15,rax
     5b4:	test   rax,rcx
     5b7:	je     707 <botlish_fn_9+0x1a7>
     5bd:	mov    rax,r15
     5c0:	test   rax,0x1
     5c6:	jne    5f4 <botlish_fn_9+0x94>
     5cc:	mov    edx,0x1
     5d1:	mov    rsi,r15
     5d4:	mov    rdi,r13
     5d7:	call   5dc <botlish_fn_9+0x7c>
			5d8: R_X86_64_PLT32	rt_int_cmp-0x4
     5dc:	mov    ecx,0x2
     5e1:	test   rax,rax
     5e4:	cmove  rcx,QWORD PTR [rip+0x1a4]        # 790 <botlish_fn_9+0x230>
     5ec:	mov    rax,r15
     5ef:	jmp    608 <botlish_fn_9+0xa8>
     5f4:	mov    ecx,0x2
     5f9:	mov    rax,r15
     5fc:	cmp    rax,0x1
     600:	cmove  rcx,QWORD PTR [rip+0x188]        # 790 <botlish_fn_9+0x230>
     608:	cmp    rcx,0x6
     60c:	je     767 <botlish_fn_9+0x207>
     612:	test   rax,0x1
     618:	mov    r15,rax
     61b:	jne    646 <botlish_fn_9+0xe6>
     621:	mov    edx,0x3
     626:	mov    rsi,r15
     629:	mov    rdi,r13
     62c:	call   631 <botlish_fn_9+0xd1>
			62d: R_X86_64_PLT32	rt_int_cmp-0x4
     631:	mov    ecx,0x2
     636:	test   rax,rax
     639:	cmove  rcx,QWORD PTR [rip+0x14f]        # 790 <botlish_fn_9+0x230>
     641:	jmp    65a <botlish_fn_9+0xfa>
     646:	mov    rsi,r15
     649:	mov    ecx,0x2
     64e:	cmp    rsi,0x3
     652:	cmove  rcx,QWORD PTR [rip+0x136]        # 790 <botlish_fn_9+0x230>
     65a:	cmp    rcx,0x6
     65e:	je     66e <botlish_fn_9+0x10e>
     664:	mov    eax,0x2
     669:	jmp    6e6 <botlish_fn_9+0x186>
     66e:	mov    rcx,QWORD PTR [r12+0x18]
     673:	mov    rsi,QWORD PTR [rcx+0x8]
     677:	mov    rdx,r14
     67a:	mov    rdi,r13
     67d:	call   682 <botlish_fn_9+0x122>
			67e: R_X86_64_PLT32	rt_mutarray_get-0x4
     682:	test   rax,rax
     685:	je     707 <botlish_fn_9+0x1a7>
     68b:	mov    rsi,rax
     68e:	and    rsi,rbx
     691:	test   rsi,0x1
     698:	jne    6ba <botlish_fn_9+0x15a>
     69e:	mov    rsi,rax
     6a1:	mov    rdx,rbx
     6a4:	mov    rdi,r13
     6a7:	call   6ac <botlish_fn_9+0x14c>
			6a8: R_X86_64_PLT32	rt_value_eq-0x4
     6ac:	test   rax,rax
     6af:	je     707 <botlish_fn_9+0x1a7>
     6b5:	jmp    6cd <botlish_fn_9+0x16d>
     6ba:	mov    rsi,rax
     6bd:	mov    eax,0x2
     6c2:	cmp    rsi,rbx
     6c5:	cmove  rax,QWORD PTR [rip+0xc3]        # 790 <botlish_fn_9+0x230>
     6cd:	cmp    rax,0x6
     6d1:	je     6e1 <botlish_fn_9+0x181>
     6d7:	mov    eax,0x2
     6dc:	jmp    6e6 <botlish_fn_9+0x186>
     6e1:	mov    eax,0x6
     6e6:	cmp    rax,0x6
     6ea:	je     742 <botlish_fn_9+0x1e2>
     6f0:	mov    rdx,r14
     6f3:	mov    rsi,r12
     6f6:	mov    rdi,r13
     6f9:	call   6fe <botlish_fn_9+0x19e>
			6fa: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     6fe:	test   rax,rax
     701:	jne    72c <botlish_fn_9+0x1cc>
     707:	xor    rax,rax
     70a:	mov    rbx,QWORD PTR [rsp+0x20]
     70f:	mov    r12,QWORD PTR [rsp+0x28]
     714:	mov    r13,QWORD PTR [rsp+0x30]
     719:	mov    r14,QWORD PTR [rsp+0x38]
     71e:	mov    r15,QWORD PTR [rsp+0x40]
     723:	add    rsp,0x50
     727:	mov    rsp,rbp
     72a:	pop    rbp
     72b:	ret
     72c:	mov    QWORD PTR [rsp],r12
     730:	mov    QWORD PTR [rsp+0x8],rbx
     735:	mov    QWORD PTR [rsp+0x10],rax
     73a:	mov    r14,rax
     73d:	jmp    59b <botlish_fn_9+0x3b>
     742:	mov    rax,r14
     745:	mov    rbx,QWORD PTR [rsp+0x20]
     74a:	mov    r12,QWORD PTR [rsp+0x28]
     74f:	mov    r13,QWORD PTR [rsp+0x30]
     754:	mov    r14,QWORD PTR [rsp+0x38]
     759:	mov    r15,QWORD PTR [rsp+0x40]
     75e:	add    rsp,0x50
     762:	mov    rsp,rbp
     765:	pop    rbp
     766:	ret
     767:	mov    rax,0xffffffffffffffff
     76e:	mov    rbx,QWORD PTR [rsp+0x20]
     773:	mov    r12,QWORD PTR [rsp+0x28]
     778:	mov    r13,QWORD PTR [rsp+0x30]
     77d:	mov    r14,QWORD PTR [rsp+0x38]
     782:	mov    r15,QWORD PTR [rsp+0x40]
     787:	add    rsp,0x50
     78b:	mov    rsp,rbp
     78e:	pop    rbp
     78f:	ret
     790:	(bad)
     791:	add    BYTE PTR [rax],al
     793:	add    BYTE PTR [rax],al
     795:	add    BYTE PTR [rax],al
	...

0000000000000798 <botlish_entry_9: ht_find_get<HashTable, str, int>>:
     798:	push   rbp
     799:	mov    rbp,rsp
     79c:	mov    rsi,QWORD PTR [rdx]
     79f:	mov    r8,QWORD PTR [rdx+0x8]
     7a3:	mov    rcx,QWORD PTR [rdx+0x10]
     7a7:	mov    rdx,r8
     7aa:	call   7af <botlish_entry_9+0x17>
			7ab: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     7af:	mov    rsp,rbp
     7b2:	pop    rbp
     7b3:	ret
     7b4:	add    BYTE PTR [rax],al
	...

00000000000007b8 <botlish_fn_10: ht_find_insert<HashTable, str, int, int>>:
     7b8:	push   rbp
     7b9:	mov    rbp,rsp
     7bc:	sub    rsp,0x60
     7c0:	mov    QWORD PTR [rsp+0x30],rbx
     7c5:	mov    QWORD PTR [rsp+0x38],r12
     7ca:	mov    QWORD PTR [rsp+0x40],r13
     7cf:	mov    QWORD PTR [rsp+0x48],r14
     7d4:	mov    QWORD PTR [rsp+0x50],r15
     7d9:	mov    r15,rdi
     7dc:	mov    QWORD PTR [rsp],rsi
     7e0:	mov    QWORD PTR [rsp+0x8],rdx
     7e5:	mov    r12,rdx
     7e8:	mov    QWORD PTR [rsp+0x10],rcx
     7ed:	mov    QWORD PTR [rsp+0x18],r8
     7f2:	mov    rbx,rsi
     7f5:	mov    r14,rcx
     7f8:	mov    QWORD PTR [rsp+0x20],r8
     7fd:	mov    r10,QWORD PTR [rbx+0x18]
     801:	mov    rsi,QWORD PTR [r10]
     804:	mov    rdx,r14
     807:	mov    rdi,r15
     80a:	call   80f <botlish_fn_10+0x57>
			80b: R_X86_64_PLT32	rt_mutarray_get-0x4
     80f:	mov    rcx,rax
     812:	mov    r13,rax
     815:	test   rax,rcx
     818:	je     a68 <botlish_fn_10+0x2b0>
     81e:	mov    rax,r13
     821:	test   rax,0x1
     827:	jne    852 <botlish_fn_10+0x9a>
     82d:	mov    edx,0x1
     832:	mov    rsi,r13
     835:	mov    rdi,r15
     838:	call   83d <botlish_fn_10+0x85>
			839: R_X86_64_PLT32	rt_int_cmp-0x4
     83d:	mov    ecx,0x2
     842:	test   rax,rax
     845:	cmove  rcx,QWORD PTR [rip+0x313]        # b60 <botlish_fn_10+0x3a8>
     84d:	jmp    866 <botlish_fn_10+0xae>
     852:	mov    ecx,0x2
     857:	mov    rax,r13
     85a:	cmp    rax,0x1
     85e:	cmove  rcx,QWORD PTR [rip+0x2fa]        # b60 <botlish_fn_10+0x3a8>
     866:	cmp    rcx,0x6
     86a:	je     ab8 <botlish_fn_10+0x300>
     870:	mov    rax,r13
     873:	test   rax,0x1
     879:	jne    8a4 <botlish_fn_10+0xec>
     87f:	mov    edx,0x3
     884:	mov    rsi,r13
     887:	mov    rdi,r15
     88a:	call   88f <botlish_fn_10+0xd7>
			88b: R_X86_64_PLT32	rt_int_cmp-0x4
     88f:	mov    ecx,0x2
     894:	test   rax,rax
     897:	cmove  rcx,QWORD PTR [rip+0x2c1]        # b60 <botlish_fn_10+0x3a8>
     89f:	jmp    8b8 <botlish_fn_10+0x100>
     8a4:	mov    ecx,0x2
     8a9:	mov    rax,r13
     8ac:	cmp    rax,0x3
     8b0:	cmove  rcx,QWORD PTR [rip+0x2a8]        # b60 <botlish_fn_10+0x3a8>
     8b8:	cmp    rcx,0x6
     8bc:	je     8cc <botlish_fn_10+0x114>
     8c2:	mov    eax,0x2
     8c7:	jmp    940 <botlish_fn_10+0x188>
     8cc:	mov    rax,QWORD PTR [rbx+0x18]
     8d0:	mov    rsi,QWORD PTR [rax+0x8]
     8d4:	mov    rdx,r14
     8d7:	mov    rdi,r15
     8da:	call   8df <botlish_fn_10+0x127>
			8db: R_X86_64_PLT32	rt_mutarray_get-0x4
     8df:	test   rax,rax
     8e2:	je     a68 <botlish_fn_10+0x2b0>
     8e8:	mov    rcx,rax
     8eb:	and    rcx,r12
     8ee:	mov    rsi,rax
     8f1:	test   rcx,0x1
     8f8:	jne    917 <botlish_fn_10+0x15f>
     8fe:	mov    rdx,r12
     901:	mov    rdi,r15
     904:	call   909 <botlish_fn_10+0x151>
			905: R_X86_64_PLT32	rt_value_eq-0x4
     909:	test   rax,rax
     90c:	je     a68 <botlish_fn_10+0x2b0>
     912:	jmp    927 <botlish_fn_10+0x16f>
     917:	mov    eax,0x2
     91c:	cmp    rsi,r12
     91f:	cmove  rax,QWORD PTR [rip+0x239]        # b60 <botlish_fn_10+0x3a8>
     927:	cmp    rax,0x6
     92b:	je     93b <botlish_fn_10+0x183>
     931:	mov    eax,0x2
     936:	jmp    940 <botlish_fn_10+0x188>
     93b:	mov    eax,0x6
     940:	cmp    rax,0x6
     944:	je     ab0 <botlish_fn_10+0x2f8>
     94a:	mov    rax,r13
     94d:	test   rax,0x1
     953:	jne    97e <botlish_fn_10+0x1c6>
     959:	mov    edx,0x5
     95e:	mov    rsi,r13
     961:	mov    rdi,r15
     964:	call   969 <botlish_fn_10+0x1b1>
			965: R_X86_64_PLT32	rt_int_cmp-0x4
     969:	mov    ecx,0x2
     96e:	test   rax,rax
     971:	cmove  rcx,QWORD PTR [rip+0x1e7]        # b60 <botlish_fn_10+0x3a8>
     979:	jmp    992 <botlish_fn_10+0x1da>
     97e:	mov    rsi,r13
     981:	mov    ecx,0x2
     986:	cmp    rsi,0x5
     98a:	cmove  rcx,QWORD PTR [rip+0x1ce]        # b60 <botlish_fn_10+0x3a8>
     992:	cmp    rcx,0x6
     996:	je     9a6 <botlish_fn_10+0x1ee>
     99c:	mov    eax,0x2
     9a1:	jmp    a10 <botlish_fn_10+0x258>
     9a6:	mov    r13,QWORD PTR [rsp+0x20]
     9ab:	test   r13,0x1
     9b2:	jne    9e2 <botlish_fn_10+0x22a>
     9b8:	mov    edx,0x1
     9bd:	mov    rsi,r13
     9c0:	mov    rdi,r15
     9c3:	call   9c8 <botlish_fn_10+0x210>
			9c4: R_X86_64_PLT32	rt_int_cmp-0x4
     9c8:	mov    ecx,0x2
     9cd:	test   rax,rax
     9d0:	cmovl  rcx,QWORD PTR [rip+0x188]        # b60 <botlish_fn_10+0x3a8>
     9d8:	mov    QWORD PTR [rsp+0x20],r13
     9dd:	jmp    9f7 <botlish_fn_10+0x23f>
     9e2:	mov    ecx,0x2
     9e7:	test   r13,r13
     9ea:	mov    QWORD PTR [rsp+0x20],r13
     9ef:	cmovle rcx,QWORD PTR [rip+0x169]        # b60 <botlish_fn_10+0x3a8>
     9f7:	cmp    rcx,0x6
     9fb:	je     a0b <botlish_fn_10+0x253>
     a01:	mov    eax,0x2
     a06:	jmp    a10 <botlish_fn_10+0x258>
     a0b:	mov    eax,0x6
     a10:	cmp    rax,0x6
     a14:	je     a51 <botlish_fn_10+0x299>
     a1a:	mov    rdx,r14
     a1d:	mov    rsi,rbx
     a20:	mov    rdi,r15
     a23:	call   a28 <botlish_fn_10+0x270>
			a24: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a28:	test   rax,rax
     a2b:	je     a68 <botlish_fn_10+0x2b0>
     a31:	mov    QWORD PTR [rsp],rbx
     a35:	mov    QWORD PTR [rsp+0x8],r12
     a3a:	mov    QWORD PTR [rsp+0x10],rax
     a3f:	mov    r10,QWORD PTR [rsp+0x20]
     a44:	mov    QWORD PTR [rsp+0x18],r10
     a49:	mov    r14,rax
     a4c:	jmp    7fd <botlish_fn_10+0x45>
     a51:	mov    rdx,r14
     a54:	mov    rsi,rbx
     a57:	mov    rdi,r15
     a5a:	call   a5f <botlish_fn_10+0x2a7>
			a5b: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a5f:	test   rax,rax
     a62:	jne    a8d <botlish_fn_10+0x2d5>
     a68:	xor    rax,rax
     a6b:	mov    rbx,QWORD PTR [rsp+0x30]
     a70:	mov    r12,QWORD PTR [rsp+0x38]
     a75:	mov    r13,QWORD PTR [rsp+0x40]
     a7a:	mov    r14,QWORD PTR [rsp+0x48]
     a7f:	mov    r15,QWORD PTR [rsp+0x50]
     a84:	add    rsp,0x60
     a88:	mov    rsp,rbp
     a8b:	pop    rbp
     a8c:	ret
     a8d:	mov    QWORD PTR [rsp],rbx
     a91:	mov    QWORD PTR [rsp+0x8],r12
     a96:	mov    QWORD PTR [rsp+0x10],rax
     a9b:	mov    rdx,r14
     a9e:	mov    QWORD PTR [rsp+0x18],rdx
     aa3:	mov    QWORD PTR [rsp+0x20],r14
     aa8:	mov    r14,rax
     aab:	jmp    7fd <botlish_fn_10+0x45>
     ab0:	mov    rax,r14
     ab3:	jmp    b17 <botlish_fn_10+0x35f>
     ab8:	mov    rax,QWORD PTR [rsp+0x20]
     abd:	test   rax,0x1
     ac3:	jne    af0 <botlish_fn_10+0x338>
     ac9:	mov    edx,0x1
     ace:	mov    rdi,r15
     ad1:	mov    rsi,QWORD PTR [rsp+0x20]
     ad6:	call   adb <botlish_fn_10+0x323>
			ad7: R_X86_64_PLT32	rt_int_cmp-0x4
     adb:	mov    ecx,0x2
     ae0:	test   rax,rax
     ae3:	cmovge rcx,QWORD PTR [rip+0x75]        # b60 <botlish_fn_10+0x3a8>
     aeb:	jmp    b0a <botlish_fn_10+0x352>
     af0:	mov    ecx,0x2
     af5:	mov    rax,QWORD PTR [rsp+0x20]
     afa:	mov    rdx,QWORD PTR [rsp+0x20]
     aff:	test   rax,rdx
     b02:	cmovg  rcx,QWORD PTR [rip+0x56]        # b60 <botlish_fn_10+0x3a8>
     b0a:	cmp    rcx,0x6
     b0e:	je     b39 <botlish_fn_10+0x381>
     b14:	mov    rax,r14
     b17:	mov    rbx,QWORD PTR [rsp+0x30]
     b1c:	mov    r12,QWORD PTR [rsp+0x38]
     b21:	mov    r13,QWORD PTR [rsp+0x40]
     b26:	mov    r14,QWORD PTR [rsp+0x48]
     b2b:	mov    r15,QWORD PTR [rsp+0x50]
     b30:	add    rsp,0x60
     b34:	mov    rsp,rbp
     b37:	pop    rbp
     b38:	ret
     b39:	mov    rax,QWORD PTR [rsp+0x20]
     b3e:	mov    rbx,QWORD PTR [rsp+0x30]
     b43:	mov    r12,QWORD PTR [rsp+0x38]
     b48:	mov    r13,QWORD PTR [rsp+0x40]
     b4d:	mov    r14,QWORD PTR [rsp+0x48]
     b52:	mov    r15,QWORD PTR [rsp+0x50]
     b57:	add    rsp,0x60
     b5b:	mov    rsp,rbp
     b5e:	pop    rbp
     b5f:	ret
     b60:	(bad)
     b61:	add    BYTE PTR [rax],al
     b63:	add    BYTE PTR [rax],al
     b65:	add    BYTE PTR [rax],al
	...

0000000000000b68 <botlish_entry_10: ht_find_insert<HashTable, str, int, int>>:
     b68:	push   rbp
     b69:	mov    rbp,rsp
     b6c:	mov    rsi,QWORD PTR [rdx]
     b6f:	mov    r9,QWORD PTR [rdx+0x8]
     b73:	mov    rcx,QWORD PTR [rdx+0x10]
     b77:	mov    r8,QWORD PTR [rdx+0x18]
     b7b:	mov    rdx,r9
     b7e:	call   b83 <botlish_entry_10+0x1b>
			b7f: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
     b83:	mov    rsp,rbp
     b86:	pop    rbp
     b87:	ret

0000000000000b88 <botlish_fn_11: ht_get<HashTable, str>>:
     b88:	push   rbp
     b89:	mov    rbp,rsp
     b8c:	sub    rsp,0x40
     b90:	mov    QWORD PTR [rsp+0x20],rbx
     b95:	mov    QWORD PTR [rsp+0x28],r12
     b9a:	mov    QWORD PTR [rsp+0x30],r13
     b9f:	mov    r12,rdi
     ba2:	mov    QWORD PTR [rsp],rsi
     ba6:	mov    QWORD PTR [rsp+0x8],rdx
     bab:	mov    r13,rdx
     bae:	mov    rbx,rsi
     bb1:	mov    rdx,r13
     bb4:	mov    rdi,r12
     bb7:	call   bbc <botlish_fn_11+0x34>
			bb8: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     bbc:	test   rax,rax
     bbf:	je     c57 <botlish_fn_11+0xcf>
     bc5:	mov    QWORD PTR [rsp+0x10],rax
     bca:	mov    rcx,rax
     bcd:	mov    rdx,r13
     bd0:	mov    rsi,rbx
     bd3:	mov    rdi,r12
     bd6:	call   bdb <botlish_fn_11+0x53>
			bd7: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     bdb:	mov    rcx,rax
     bde:	mov    r13,rax
     be1:	test   rax,rcx
     be4:	je     c57 <botlish_fn_11+0xcf>
     bea:	mov    rax,r13
     bed:	test   rax,0x1
     bf3:	jne    c1e <botlish_fn_11+0x96>
     bf9:	mov    edx,0x1
     bfe:	mov    rsi,r13
     c01:	mov    rdi,r12
     c04:	call   c09 <botlish_fn_11+0x81>
			c05: R_X86_64_PLT32	rt_int_cmp-0x4
     c09:	mov    ecx,0x2
     c0e:	test   rax,rax
     c11:	cmovl  rcx,QWORD PTR [rip+0x8f]        # ca8 <botlish_fn_11+0x120>
     c19:	jmp    c31 <botlish_fn_11+0xa9>
     c1e:	mov    ecx,0x2
     c23:	mov    rax,r13
     c26:	test   rax,rax
     c29:	cmovle rcx,QWORD PTR [rip+0x77]        # ca8 <botlish_fn_11+0x120>
     c31:	cmp    rcx,0x6
     c35:	je     c8a <botlish_fn_11+0x102>
     c3b:	mov    rax,QWORD PTR [rbx+0x18]
     c3f:	mov    rsi,QWORD PTR [rax+0x10]
     c43:	mov    rdx,r13
     c46:	mov    rdi,r12
     c49:	call   c4e <botlish_fn_11+0xc6>
			c4a: R_X86_64_PLT32	rt_mutarray_get-0x4
     c4e:	test   rax,rax
     c51:	jne    c72 <botlish_fn_11+0xea>
     c57:	xor    rax,rax
     c5a:	mov    rbx,QWORD PTR [rsp+0x20]
     c5f:	mov    r12,QWORD PTR [rsp+0x28]
     c64:	mov    r13,QWORD PTR [rsp+0x30]
     c69:	add    rsp,0x40
     c6d:	mov    rsp,rbp
     c70:	pop    rbp
     c71:	ret
     c72:	mov    rbx,QWORD PTR [rsp+0x20]
     c77:	mov    r12,QWORD PTR [rsp+0x28]
     c7c:	mov    r13,QWORD PTR [rsp+0x30]
     c81:	add    rsp,0x40
     c85:	mov    rsp,rbp
     c88:	pop    rbp
     c89:	ret
     c8a:	mov    eax,0xa
     c8f:	mov    rbx,QWORD PTR [rsp+0x20]
     c94:	mov    r12,QWORD PTR [rsp+0x28]
     c99:	mov    r13,QWORD PTR [rsp+0x30]
     c9e:	add    rsp,0x40
     ca2:	mov    rsp,rbp
     ca5:	pop    rbp
     ca6:	ret
     ca7:	add    BYTE PTR [rsi],al
     ca9:	add    BYTE PTR [rax],al
     cab:	add    BYTE PTR [rax],al
     cad:	add    BYTE PTR [rax],al
	...

0000000000000cb0 <botlish_entry_11: ht_get<HashTable, str>>:
     cb0:	push   rbp
     cb1:	mov    rbp,rsp
     cb4:	mov    rsi,QWORD PTR [rdx]
     cb7:	mov    rdx,QWORD PTR [rdx+0x8]
     cbb:	call   cc0 <botlish_entry_11+0x10>
			cbc: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
     cc0:	mov    rsp,rbp
     cc3:	pop    rbp
     cc4:	ret
     cc5:	add    BYTE PTR [rax],al
	...

0000000000000cc8 <botlish_fn_12: ht_contains<HashTable, str>>:
     cc8:	push   rbp
     cc9:	mov    rbp,rsp
     ccc:	sub    rsp,0x40
     cd0:	mov    QWORD PTR [rsp+0x20],rbx
     cd5:	mov    QWORD PTR [rsp+0x28],r12
     cda:	mov    QWORD PTR [rsp+0x30],r15
     cdf:	mov    r15,rdi
     ce2:	mov    QWORD PTR [rsp],rsi
     ce6:	mov    r12,rsi
     ce9:	mov    QWORD PTR [rsp+0x8],rdx
     cee:	mov    rbx,rdx
     cf1:	mov    rdx,rbx
     cf4:	mov    rsi,r12
     cf7:	mov    rdi,r15
     cfa:	call   cff <botlish_fn_12+0x37>
			cfb: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     cff:	test   rax,rax
     d02:	je     d27 <botlish_fn_12+0x5f>
     d08:	mov    QWORD PTR [rsp+0x10],rax
     d0d:	mov    rcx,rax
     d10:	mov    rdx,rbx
     d13:	mov    rsi,r12
     d16:	mov    rdi,r15
     d19:	call   d1e <botlish_fn_12+0x56>
			d1a: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     d1e:	test   rax,rax
     d21:	jne    d42 <botlish_fn_12+0x7a>
     d27:	xor    rax,rax
     d2a:	mov    rbx,QWORD PTR [rsp+0x20]
     d2f:	mov    r12,QWORD PTR [rsp+0x28]
     d34:	mov    r15,QWORD PTR [rsp+0x30]
     d39:	add    rsp,0x40
     d3d:	mov    rsp,rbp
     d40:	pop    rbp
     d41:	ret
     d42:	test   rax,0x1
     d48:	mov    rsi,rax
     d4b:	jne    d76 <botlish_fn_12+0xae>
     d51:	mov    edx,0x1
     d56:	mov    rdi,r15
     d59:	call   d5e <botlish_fn_12+0x96>
			d5a: R_X86_64_PLT32	rt_int_cmp-0x4
     d5e:	mov    ecx,0x2
     d63:	test   rax,rax
     d66:	mov    rax,rcx
     d69:	cmovge rax,QWORD PTR [rip+0x2f]        # da0 <botlish_fn_12+0xd8>
     d71:	jmp    d86 <botlish_fn_12+0xbe>
     d76:	mov    eax,0x2
     d7b:	test   rsi,rsi
     d7e:	cmovg  rax,QWORD PTR [rip+0x1a]        # da0 <botlish_fn_12+0xd8>
     d86:	mov    rbx,QWORD PTR [rsp+0x20]
     d8b:	mov    r12,QWORD PTR [rsp+0x28]
     d90:	mov    r15,QWORD PTR [rsp+0x30]
     d95:	add    rsp,0x40
     d99:	mov    rsp,rbp
     d9c:	pop    rbp
     d9d:	ret
     d9e:	add    BYTE PTR [rax],al
     da0:	(bad)
     da1:	add    BYTE PTR [rax],al
     da3:	add    BYTE PTR [rax],al
     da5:	add    BYTE PTR [rax],al
	...

0000000000000da8 <botlish_entry_12: ht_contains<HashTable, str>>:
     da8:	push   rbp
     da9:	mov    rbp,rsp
     dac:	mov    rsi,QWORD PTR [rdx]
     daf:	mov    rdx,QWORD PTR [rdx+0x8]
     db3:	call   db8 <botlish_entry_12+0x10>
			db4: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
     db8:	mov    rsp,rbp
     dbb:	pop    rbp
     dbc:	ret
     dbd:	add    BYTE PTR [rax],al
	...

0000000000000dc0 <botlish_fn_13: ht_rehash_probe<mutarray, int, int>>:
     dc0:	push   rbp
     dc1:	mov    rbp,rsp
     dc4:	sub    rsp,0x40
     dc8:	mov    QWORD PTR [rsp+0x20],rbx
     dcd:	mov    QWORD PTR [rsp+0x28],r12
     dd2:	mov    QWORD PTR [rsp+0x30],r13
     dd7:	mov    QWORD PTR [rsp+0x38],r14
     ddc:	mov    r13,rdi
     ddf:	mov    QWORD PTR [rsp],rsi
     de3:	mov    QWORD PTR [rsp+0x8],rdx
     de8:	mov    QWORD PTR [rsp+0x10],rcx
     ded:	mov    r12,rcx
     df0:	mov    rbx,rsi
     df3:	mov    r14,rdx
     df6:	mov    rdx,r14
     df9:	mov    rsi,rbx
     dfc:	mov    rdi,r13
     dff:	call   e04 <botlish_fn_13+0x44>
			e00: R_X86_64_PLT32	rt_mutarray_get-0x4
     e04:	test   rax,rax
     e07:	je     ea4 <botlish_fn_13+0xe4>
     e0d:	test   rax,0x1
     e13:	mov    rsi,rax
     e16:	jne    e37 <botlish_fn_13+0x77>
     e1c:	mov    edx,0x1
     e21:	mov    rdi,r13
     e24:	call   e29 <botlish_fn_13+0x69>
			e25: R_X86_64_PLT32	rt_value_eq-0x4
     e29:	test   rax,rax
     e2c:	je     ea4 <botlish_fn_13+0xe4>
     e32:	jmp    e48 <botlish_fn_13+0x88>
     e37:	mov    eax,0x2
     e3c:	cmp    rsi,0x1
     e40:	cmove  rax,QWORD PTR [rip+0xb8]        # f00 <botlish_fn_13+0x140>
     e48:	cmp    rax,0x6
     e4c:	je     eda <botlish_fn_13+0x11a>
     e52:	mov    QWORD PTR [rsp+0x18],0x3
     e5b:	mov    rsi,r14
     e5e:	test   rsi,0x1
     e65:	je     e7d <botlish_fn_13+0xbd>
     e6b:	mov    rsi,r14
     e6e:	add    rsi,0x2
     e72:	seto   al
     e75:	test   al,al
     e77:	je     e90 <botlish_fn_13+0xd0>
     e7d:	mov    edx,0x3
     e82:	mov    rsi,r14
     e85:	mov    rdi,r13
     e88:	call   e8d <botlish_fn_13+0xcd>
			e89: R_X86_64_PLT32	rt_int_add-0x4
     e8d:	mov    rsi,rax
     e90:	mov    rdx,r12
     e93:	mov    rdi,r13
     e96:	call   e9b <botlish_fn_13+0xdb>
			e97: R_X86_64_PLT32	rt_int_mod-0x4
     e9b:	test   rax,rax
     e9e:	jne    ec4 <botlish_fn_13+0x104>
     ea4:	xor    rax,rax
     ea7:	mov    rbx,QWORD PTR [rsp+0x20]
     eac:	mov    r12,QWORD PTR [rsp+0x28]
     eb1:	mov    r13,QWORD PTR [rsp+0x30]
     eb6:	mov    r14,QWORD PTR [rsp+0x38]
     ebb:	add    rsp,0x40
     ebf:	mov    rsp,rbp
     ec2:	pop    rbp
     ec3:	ret
     ec4:	mov    QWORD PTR [rsp],rbx
     ec8:	mov    QWORD PTR [rsp+0x8],rax
     ecd:	mov    QWORD PTR [rsp+0x10],r12
     ed2:	mov    r14,rax
     ed5:	jmp    df6 <botlish_fn_13+0x36>
     eda:	mov    rax,r14
     edd:	mov    rbx,QWORD PTR [rsp+0x20]
     ee2:	mov    r12,QWORD PTR [rsp+0x28]
     ee7:	mov    r13,QWORD PTR [rsp+0x30]
     eec:	mov    r14,QWORD PTR [rsp+0x38]
     ef1:	add    rsp,0x40
     ef5:	mov    rsp,rbp
     ef8:	pop    rbp
     ef9:	ret
     efa:	add    BYTE PTR [rax],al
     efc:	add    BYTE PTR [rax],al
     efe:	add    BYTE PTR [rax],al
     f00:	(bad)
     f01:	add    BYTE PTR [rax],al
     f03:	add    BYTE PTR [rax],al
     f05:	add    BYTE PTR [rax],al
	...

0000000000000f08 <botlish_entry_13: ht_rehash_probe<mutarray, int, int>>:
     f08:	push   rbp
     f09:	mov    rbp,rsp
     f0c:	mov    rsi,QWORD PTR [rdx]
     f0f:	mov    r8,QWORD PTR [rdx+0x8]
     f13:	mov    rcx,QWORD PTR [rdx+0x10]
     f17:	mov    rdx,r8
     f1a:	call   f1f <botlish_entry_13+0x17>
			f1b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     f1f:	mov    rsp,rbp
     f22:	pop    rbp
     f23:	ret

0000000000000f24 <botlish_fn_14: ht_rehash_insert<HashTable, int, any, any>>:
     f24:	push   rbp
     f25:	mov    rbp,rsp
     f28:	sub    rsp,0x70
     f2c:	mov    QWORD PTR [rsp+0x40],rbx
     f31:	mov    QWORD PTR [rsp+0x48],r12
     f36:	mov    QWORD PTR [rsp+0x50],r13
     f3b:	mov    QWORD PTR [rsp+0x58],r14
     f40:	mov    QWORD PTR [rsp+0x60],r15
     f45:	mov    r13,rdi
     f48:	mov    QWORD PTR [rsp],rsi
     f4c:	mov    QWORD PTR [rsp+0x8],rdx
     f51:	mov    r15,rdx
     f54:	mov    QWORD PTR [rsp+0x10],rcx
     f59:	mov    r14,rcx
     f5c:	mov    QWORD PTR [rsp+0x18],r8
     f61:	mov    r12,r8
     f64:	mov    rax,QWORD PTR [rsi+0x18]
     f68:	mov    rbx,rsi
     f6b:	mov    rsi,QWORD PTR [rax]
     f6e:	mov    QWORD PTR [rsp+0x20],rsi
     f73:	mov    QWORD PTR [rsp+0x30],rsi
     f78:	mov    rsi,r14
     f7b:	mov    rdi,r13
     f7e:	call   f83 <botlish_fn_14+0x5f>
			f7f: R_X86_64_PLT32	rt_hash-0x4
     f83:	test   rax,rax
     f86:	mov    rsi,rax
     f89:	je     1028 <botlish_fn_14+0x104>
     f8f:	mov    rdx,r15
     f92:	mov    rdi,r13
     f95:	call   f9a <botlish_fn_14+0x76>
			f96: R_X86_64_PLT32	rt_int_mod-0x4
     f9a:	test   rax,rax
     f9d:	je     1028 <botlish_fn_14+0x104>
     fa3:	mov    QWORD PTR [rsp+0x28],rax
     fa8:	mov    rcx,r15
     fab:	mov    rdx,rax
     fae:	mov    rsi,QWORD PTR [rsp+0x30]
     fb3:	mov    rdi,r13
     fb6:	call   fbb <botlish_fn_14+0x97>
			fb7: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     fbb:	mov    rdx,rax
     fbe:	mov    r15,rax
     fc1:	test   rax,rdx
     fc4:	je     1028 <botlish_fn_14+0x104>
     fca:	mov    rcx,QWORD PTR [rbx+0x18]
     fce:	mov    rsi,QWORD PTR [rcx]
     fd1:	mov    ecx,0x3
     fd6:	mov    rdx,r15
     fd9:	mov    rdi,r13
     fdc:	call   fe1 <botlish_fn_14+0xbd>
			fdd: R_X86_64_PLT32	rt_mutarray_set-0x4
     fe1:	test   rax,rax
     fe4:	je     1028 <botlish_fn_14+0x104>
     fea:	mov    rax,QWORD PTR [rbx+0x18]
     fee:	mov    rsi,QWORD PTR [rax+0x8]
     ff2:	mov    rcx,r14
     ff5:	mov    rdx,r15
     ff8:	mov    rdi,r13
     ffb:	call   1000 <botlish_fn_14+0xdc>
			ffc: R_X86_64_PLT32	rt_mutarray_set-0x4
    1000:	test   rax,rax
    1003:	je     1028 <botlish_fn_14+0x104>
    1009:	mov    rax,QWORD PTR [rbx+0x18]
    100d:	mov    rsi,QWORD PTR [rax+0x10]
    1011:	mov    rcx,r12
    1014:	mov    rdx,r15
    1017:	mov    rdi,r13
    101a:	call   101f <botlish_fn_14+0xfb>
			101b: R_X86_64_PLT32	rt_mutarray_set-0x4
    101f:	test   rax,rax
    1022:	jne    104d <botlish_fn_14+0x129>
    1028:	xor    rax,rax
    102b:	mov    rbx,QWORD PTR [rsp+0x40]
    1030:	mov    r12,QWORD PTR [rsp+0x48]
    1035:	mov    r13,QWORD PTR [rsp+0x50]
    103a:	mov    r14,QWORD PTR [rsp+0x58]
    103f:	mov    r15,QWORD PTR [rsp+0x60]
    1044:	add    rsp,0x70
    1048:	mov    rsp,rbp
    104b:	pop    rbp
    104c:	ret
    104d:	mov    rax,rbx
    1050:	mov    rbx,QWORD PTR [rsp+0x40]
    1055:	mov    r12,QWORD PTR [rsp+0x48]
    105a:	mov    r13,QWORD PTR [rsp+0x50]
    105f:	mov    r14,QWORD PTR [rsp+0x58]
    1064:	mov    r15,QWORD PTR [rsp+0x60]
    1069:	add    rsp,0x70
    106d:	mov    rsp,rbp
    1070:	pop    rbp
    1071:	ret

0000000000001072 <botlish_entry_14: ht_rehash_insert<HashTable, int, any, any>>:
    1072:	push   rbp
    1073:	mov    rbp,rsp
    1076:	mov    rsi,QWORD PTR [rdx]
    1079:	mov    r9,QWORD PTR [rdx+0x8]
    107d:	mov    rcx,QWORD PTR [rdx+0x10]
    1081:	mov    r8,QWORD PTR [rdx+0x18]
    1085:	mov    rdx,r9
    1088:	call   108d <botlish_entry_14+0x1b>
			1089: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    108d:	mov    rsp,rbp
    1090:	pop    rbp
    1091:	ret
    1092:	add    BYTE PTR [rax],al
    1094:	add    BYTE PTR [rax],al
	...

0000000000001098 <botlish_fn_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    1098:	push   rbp
    1099:	mov    rbp,rsp
    109c:	sub    rsp,0x90
    10a3:	mov    QWORD PTR [rsp+0x60],rbx
    10a8:	mov    QWORD PTR [rsp+0x68],r12
    10ad:	mov    QWORD PTR [rsp+0x70],r13
    10b2:	mov    QWORD PTR [rsp+0x78],r14
    10b7:	mov    QWORD PTR [rsp+0x80],r15
    10bf:	mov    QWORD PTR [rsp+0x38],rdi
    10c4:	mov    QWORD PTR [rsp+0x40],r9
    10c9:	mov    rdi,QWORD PTR [rbp+0x10]
    10cd:	mov    rbx,QWORD PTR [rbp+0x18]
    10d1:	mov    QWORD PTR [rsp],rsi
    10d5:	mov    QWORD PTR [rsp+0x8],rdx
    10da:	mov    r14,rdx
    10dd:	mov    QWORD PTR [rsp+0x10],rcx
    10e2:	mov    r15,rcx
    10e5:	mov    QWORD PTR [rsp+0x18],rdi
    10ea:	mov    QWORD PTR [rsp+0x20],rbx
    10ef:	sar    r8,1
    10f2:	mov    rcx,QWORD PTR [rsp+0x40]
    10f7:	mov    r12,r8
    10fa:	mov    QWORD PTR [rsp+0x48],rdi
    10ff:	cmp    r12,rcx
    1102:	mov    QWORD PTR [rsp+0x40],rcx
    1107:	jge    126e <botlish_fn_15+0x1d6>
    110d:	mov    rdx,r12
    1110:	shl    rdx,1
    1113:	or     rdx,0x1
    1117:	mov    r13,rsi
    111a:	mov    QWORD PTR [rsp+0x58],rdx
    111f:	mov    rdi,QWORD PTR [rsp+0x38]
    1124:	call   1129 <botlish_fn_15+0x91>
			1125: R_X86_64_PLT32	rt_mutarray_get-0x4
    1129:	test   rax,rax
    112c:	je     1212 <botlish_fn_15+0x17a>
    1132:	test   rax,0x1
    1138:	mov    rsi,rax
    113b:	jne    115e <botlish_fn_15+0xc6>
    1141:	mov    edx,0x3
    1146:	mov    rdi,QWORD PTR [rsp+0x38]
    114b:	call   1150 <botlish_fn_15+0xb8>
			114c: R_X86_64_PLT32	rt_value_eq-0x4
    1150:	test   rax,rax
    1153:	je     1212 <botlish_fn_15+0x17a>
    1159:	jmp    116f <botlish_fn_15+0xd7>
    115e:	mov    eax,0x2
    1163:	cmp    rsi,0x3
    1167:	cmove  rax,QWORD PTR [rip+0x131]        # 12a0 <botlish_fn_15+0x208>
    116f:	cmp    rax,0x6
    1173:	je     11aa <botlish_fn_15+0x112>
    1179:	mov    QWORD PTR [rsp],r13
    117d:	mov    QWORD PTR [rsp+0x8],r14
    1182:	mov    QWORD PTR [rsp+0x10],r15
    1187:	mov    rsi,QWORD PTR [rsp+0x48]
    118c:	mov    QWORD PTR [rsp+0x18],rsi
    1191:	mov    QWORD PTR [rsp+0x20],rbx
    1196:	add    r12,0x1
    119d:	mov    rcx,QWORD PTR [rsp+0x40]
    11a2:	mov    rsi,r13
    11a5:	jmp    10ff <botlish_fn_15+0x67>
    11aa:	mov    rdx,QWORD PTR [rsp+0x58]
    11af:	mov    rsi,r14
    11b2:	mov    rdi,QWORD PTR [rsp+0x38]
    11b7:	call   11bc <botlish_fn_15+0x124>
			11b8: R_X86_64_PLT32	rt_mutarray_get-0x4
    11bc:	test   rax,rax
    11bf:	je     1212 <botlish_fn_15+0x17a>
    11c5:	mov    QWORD PTR [rsp+0x28],rax
    11ca:	mov    rdx,QWORD PTR [rsp+0x58]
    11cf:	mov    QWORD PTR [rsp+0x50],rax
    11d4:	mov    rsi,r15
    11d7:	mov    rdi,QWORD PTR [rsp+0x38]
    11dc:	call   11e1 <botlish_fn_15+0x149>
			11dd: R_X86_64_PLT32	rt_mutarray_get-0x4
    11e1:	test   rax,rax
    11e4:	je     1212 <botlish_fn_15+0x17a>
    11ea:	mov    QWORD PTR [rsp+0x30],rax
    11ef:	mov    rcx,QWORD PTR [rsp+0x50]
    11f4:	mov    rsi,QWORD PTR [rsp+0x48]
    11f9:	mov    r8,rax
    11fc:	mov    rdx,rbx
    11ff:	mov    rdi,QWORD PTR [rsp+0x38]
    1204:	call   1209 <botlish_fn_15+0x171>
			1205: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    1209:	test   rax,rax
    120c:	jne    123d <botlish_fn_15+0x1a5>
    1212:	xor    rax,rax
    1215:	mov    rbx,QWORD PTR [rsp+0x60]
    121a:	mov    r12,QWORD PTR [rsp+0x68]
    121f:	mov    r13,QWORD PTR [rsp+0x70]
    1224:	mov    r14,QWORD PTR [rsp+0x78]
    1229:	mov    r15,QWORD PTR [rsp+0x80]
    1231:	add    rsp,0x90
    1238:	mov    rsp,rbp
    123b:	pop    rbp
    123c:	ret
    123d:	mov    QWORD PTR [rsp],r13
    1241:	mov    QWORD PTR [rsp+0x8],r14
    1246:	mov    QWORD PTR [rsp+0x10],r15
    124b:	mov    QWORD PTR [rsp+0x18],rax
    1250:	mov    QWORD PTR [rsp+0x20],rbx
    1255:	add    r12,0x1
    125c:	mov    rcx,QWORD PTR [rsp+0x40]
    1261:	mov    rsi,r13
    1264:	mov    QWORD PTR [rsp+0x48],rax
    1269:	jmp    10ff <botlish_fn_15+0x67>
    126e:	mov    rax,QWORD PTR [rsp+0x48]
    1273:	mov    rbx,QWORD PTR [rsp+0x60]
    1278:	mov    r12,QWORD PTR [rsp+0x68]
    127d:	mov    r13,QWORD PTR [rsp+0x70]
    1282:	mov    r14,QWORD PTR [rsp+0x78]
    1287:	mov    r15,QWORD PTR [rsp+0x80]
    128f:	add    rsp,0x90
    1296:	mov    rsp,rbp
    1299:	pop    rbp
    129a:	ret
    129b:	add    BYTE PTR [rax],al
    129d:	add    BYTE PTR [rax],al
    129f:	add    BYTE PTR [rsi],al
    12a1:	add    BYTE PTR [rax],al
    12a3:	add    BYTE PTR [rax],al
    12a5:	add    BYTE PTR [rax],al
	...

00000000000012a8 <botlish_entry_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    12a8:	push   rbp
    12a9:	mov    rbp,rsp
    12ac:	sub    rsp,0x10
    12b0:	mov    rsi,QWORD PTR [rdx]
    12b3:	mov    r11,QWORD PTR [rdx+0x8]
    12b7:	mov    rcx,QWORD PTR [rdx+0x10]
    12bb:	mov    r8,QWORD PTR [rdx+0x18]
    12bf:	mov    r9,QWORD PTR [rdx+0x20]
    12c3:	mov    rax,QWORD PTR [rdx+0x28]
    12c7:	mov    rdx,QWORD PTR [rdx+0x30]
    12cb:	sar    r9,1
    12ce:	mov    QWORD PTR [rsp],rax
    12d2:	mov    QWORD PTR [rsp+0x8],rdx
    12d7:	mov    rdx,r11
    12da:	call   12df <botlish_entry_15+0x37>
			12db: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    12df:	add    rsp,0x10
    12e3:	mov    rsp,rbp
    12e6:	pop    rbp
    12e7:	ret

00000000000012e8 <botlish_fn_16: ht_rehash<HashTable, int>>:
    12e8:	push   rbp
    12e9:	mov    rbp,rsp
    12ec:	sub    rsp,0xf0
    12f3:	mov    QWORD PTR [rsp+0xc0],rbx
    12fb:	mov    QWORD PTR [rsp+0xc8],r12
    1303:	mov    QWORD PTR [rsp+0xd0],r13
    130b:	mov    QWORD PTR [rsp+0xd8],r14
    1313:	mov    QWORD PTR [rsp+0xe0],r15
    131b:	mov    QWORD PTR [rsp+0x90],rdi
    1323:	mov    QWORD PTR [rsp+0x20],0x0
    132c:	mov    QWORD PTR [rsp+0x28],0x0
    1335:	mov    QWORD PTR [rsp+0x30],0x0
    133e:	mov    QWORD PTR [rsp+0x38],0x0
    1347:	mov    QWORD PTR [rsp+0x40],0x0
    1350:	mov    QWORD PTR [rsp+0x48],0x0
    1359:	mov    QWORD PTR [rsp+0x50],0x0
    1362:	mov    QWORD PTR [rsp+0x10],rsi
    1367:	mov    r14,rsi
    136a:	mov    QWORD PTR [rsp+0x18],rdx
    136f:	mov    QWORD PTR [rsp+0x98],rdx
    1377:	lea    rdx,[rsp+0x58]
    137c:	mov    rsi,QWORD PTR [rsp+0x98]
    1384:	mov    rdi,QWORD PTR [rsp+0x90]
    138c:	call   1391 <botlish_fn_16+0xa9>
			138d: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    1391:	test   rax,rax
    1394:	je     14e8 <botlish_fn_16+0x200>
    139a:	mov    QWORD PTR [rsp+0x10],rax
    139f:	mov    QWORD PTR [rsp+0xb8],rax
    13a7:	mov    rbx,QWORD PTR [rsp+0x58]
    13ac:	mov    QWORD PTR [rsp+0x20],rbx
    13b1:	mov    r12,QWORD PTR [rsp+0x60]
    13b6:	mov    QWORD PTR [rsp+0x28],r12
    13bb:	mov    r13,QWORD PTR [rsp+0x68]
    13c0:	mov    QWORD PTR [rsp+0x30],r13
    13c5:	mov    rsi,r14
    13c8:	mov    rdi,QWORD PTR [rsp+0x90]
    13d0:	call   13d5 <botlish_fn_16+0xed>
			13d1: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    13d5:	test   rax,rax
    13d8:	mov    rcx,rax
    13db:	je     14e8 <botlish_fn_16+0x200>
    13e1:	mov    edx,0x1
    13e6:	mov    rsi,r13
    13e9:	mov    rdi,QWORD PTR [rsp+0x90]
    13f1:	call   13f6 <botlish_fn_16+0x10e>
			13f2: R_X86_64_PLT32	rt_mutarray_set-0x4
    13f6:	test   rax,rax
    13f9:	je     14e8 <botlish_fn_16+0x200>
    13ff:	mov    rsi,r14
    1402:	mov    rax,QWORD PTR [rsi+0x18]
    1406:	mov    rcx,QWORD PTR [rax]
    1409:	mov    QWORD PTR [rsp+0x38],rcx
    140e:	mov    QWORD PTR [rsp+0xb0],rcx
    1416:	mov    rax,QWORD PTR [rsi+0x18]
    141a:	mov    r15,QWORD PTR [rax+0x8]
    141e:	mov    QWORD PTR [rsp+0x40],r15
    1423:	mov    rax,QWORD PTR [rsi+0x18]
    1427:	mov    r14,QWORD PTR [rax+0x10]
    142b:	mov    QWORD PTR [rsp+0x48],r14
    1430:	mov    r8d,0x1
    1436:	mov    QWORD PTR [rsp+0xa8],r8
    143e:	mov    QWORD PTR [rsp+0x50],0x1
    1447:	mov    rdi,QWORD PTR [rsp+0x90]
    144f:	call   1454 <botlish_fn_16+0x16c>
			1450: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1454:	mov    QWORD PTR [rsp+0xa0],rax
    145c:	lea    rcx,[rsp+0x70]
    1461:	mov    rax,QWORD PTR [rsp+0xb8]
    1469:	mov    QWORD PTR [rsp+0x70],rax
    146e:	mov    QWORD PTR [rsp+0x78],rbx
    1473:	mov    QWORD PTR [rsp+0x80],r12
    147b:	mov    QWORD PTR [rsp+0x88],r13
    1483:	xor    rsi,rsi
    1486:	mov    edx,0x4
    148b:	mov    rdi,QWORD PTR [rsp+0x90]
    1493:	call   1498 <botlish_fn_16+0x1b0>
			1494: R_X86_64_PLT32	rt_struct_new-0x4
    1498:	mov    QWORD PTR [rsp+0x10],rax
    149d:	mov    rcx,QWORD PTR [rsp+0xa0]
    14a5:	mov    r9,rcx
    14a8:	sar    r9,1
    14ab:	mov    QWORD PTR [rsp],rax
    14af:	mov    rdx,QWORD PTR [rsp+0x98]
    14b7:	mov    QWORD PTR [rsp+0x8],rdx
    14bc:	mov    rcx,r14
    14bf:	mov    rdx,r15
    14c2:	mov    rsi,QWORD PTR [rsp+0xb0]
    14ca:	mov    rdi,QWORD PTR [rsp+0x90]
    14d2:	mov    r8,QWORD PTR [rsp+0xa8]
    14da:	call   14df <botlish_fn_16+0x1f7>
			14db: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    14df:	test   rax,rax
    14e2:	jne    151f <botlish_fn_16+0x237>
    14e8:	xor    rax,rax
    14eb:	mov    rbx,QWORD PTR [rsp+0xc0]
    14f3:	mov    r12,QWORD PTR [rsp+0xc8]
    14fb:	mov    r13,QWORD PTR [rsp+0xd0]
    1503:	mov    r14,QWORD PTR [rsp+0xd8]
    150b:	mov    r15,QWORD PTR [rsp+0xe0]
    1513:	add    rsp,0xf0
    151a:	mov    rsp,rbp
    151d:	pop    rbp
    151e:	ret
    151f:	mov    rbx,QWORD PTR [rsp+0xc0]
    1527:	mov    r12,QWORD PTR [rsp+0xc8]
    152f:	mov    r13,QWORD PTR [rsp+0xd0]
    1537:	mov    r14,QWORD PTR [rsp+0xd8]
    153f:	mov    r15,QWORD PTR [rsp+0xe0]
    1547:	add    rsp,0xf0
    154e:	mov    rsp,rbp
    1551:	pop    rbp
    1552:	ret

0000000000001553 <botlish_entry_16: ht_rehash<HashTable, int>>:
    1553:	push   rbp
    1554:	mov    rbp,rsp
    1557:	mov    rsi,QWORD PTR [rdx]
    155a:	mov    rdx,QWORD PTR [rdx+0x8]
    155e:	call   1563 <botlish_entry_16+0x10>
			155f: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1563:	mov    rsp,rbp
    1566:	pop    rbp
    1567:	ret

0000000000001568 <botlish_fn_17: ht_should_grow<HashTable>>:
    1568:	push   rbp
    1569:	mov    rbp,rsp
    156c:	sub    rsp,0x40
    1570:	mov    QWORD PTR [rsp+0x20],rbx
    1575:	mov    QWORD PTR [rsp+0x28],r12
    157a:	mov    QWORD PTR [rsp+0x30],r13
    157f:	mov    rbx,rdi
    1582:	mov    QWORD PTR [rsp],rsi
    1586:	mov    r12,rsi
    1589:	mov    rsi,r12
    158c:	mov    rdi,rbx
    158f:	call   1594 <botlish_fn_17+0x2c>
			1590: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1594:	mov    rcx,rax
    1597:	mov    r13,rax
    159a:	test   rax,rcx
    159d:	je     1674 <botlish_fn_17+0x10c>
    15a3:	mov    rax,r13
    15a6:	mov    QWORD PTR [rsp+0x8],rax
    15ab:	mov    rsi,r12
    15ae:	mov    rdi,rbx
    15b1:	call   15b6 <botlish_fn_17+0x4e>
			15b2: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    15b6:	mov    rcx,rax
    15b9:	test   rcx,rcx
    15bc:	je     1674 <botlish_fn_17+0x10c>
    15c2:	mov    QWORD PTR [rsp+0x10],rcx
    15c7:	mov    edx,0x1
    15cc:	mov    rax,r13
    15cf:	test   rax,0x1
    15d5:	jne    15f8 <botlish_fn_17+0x90>
    15db:	xor    edx,edx
    15dd:	mov    rax,r13
    15e0:	test   rax,0x7
    15e6:	jne    15f8 <botlish_fn_17+0x90>
    15ec:	mov    rax,r13
    15ef:	movzx  rax,BYTE PTR [rax]
    15f3:	cmp    al,0x1
    15f5:	sete   dl
    15f8:	test   dl,dl
    15fa:	jne    161a <botlish_fn_17+0xb2>
    1600:	mov    rdi,rbx
    1603:	mov    rax,QWORD PTR [rdi+0x10]
    1607:	mov    rcx,QWORD PTR [rax]
    160a:	xor    rdx,rdx
    160d:	mov    rsi,r13
    1610:	call   1615 <botlish_fn_17+0xad>
			1611: R_X86_64_PLT32	rt_type_error-0x4
    1615:	jmp    1674 <botlish_fn_17+0x10c>
    161a:	mov    eax,0x1
    161f:	test   rcx,0x1
    1626:	je     1634 <botlish_fn_17+0xcc>
    162c:	mov    r8,rcx
    162f:	jmp    1657 <botlish_fn_17+0xef>
    1634:	xor    eax,eax
    1636:	test   rcx,0x7
    163d:	je     164b <botlish_fn_17+0xe3>
    1643:	mov    r8,rcx
    1646:	jmp    1657 <botlish_fn_17+0xef>
    164b:	movzx  rax,BYTE PTR [rcx]
    164f:	mov    r8,rcx
    1652:	cmp    al,0x1
    1654:	sete   al
    1657:	test   al,al
    1659:	jne    168f <botlish_fn_17+0x127>
    165f:	mov    rdi,rbx
    1662:	mov    rax,QWORD PTR [rdi+0x10]
    1666:	mov    rcx,QWORD PTR [rax]
    1669:	xor    rdx,rdx
    166c:	mov    rsi,r8
    166f:	call   1674 <botlish_fn_17+0x10c>
			1670: R_X86_64_PLT32	rt_type_error-0x4
    1674:	xor    rax,rax
    1677:	mov    rbx,QWORD PTR [rsp+0x20]
    167c:	mov    r12,QWORD PTR [rsp+0x28]
    1681:	mov    r13,QWORD PTR [rsp+0x30]
    1686:	add    rsp,0x40
    168a:	mov    rsp,rbp
    168d:	pop    rbp
    168e:	ret
    168f:	mov    rcx,r8
    1692:	mov    rsi,r13
    1695:	mov    rax,rsi
    1698:	and    rax,rcx
    169b:	test   rax,0x1
    16a1:	jne    16b2 <botlish_fn_17+0x14a>
    16a7:	mov    rdx,r8
    16aa:	mov    rsi,r13
    16ad:	jmp    16d0 <botlish_fn_17+0x168>
    16b2:	mov    rcx,r8
    16b5:	lea    rax,[rcx-0x1]
    16b9:	mov    rsi,r13
    16bc:	add    rsi,rax
    16bf:	seto   al
    16c2:	test   al,al
    16c4:	je     16db <botlish_fn_17+0x173>
    16ca:	mov    rdx,r8
    16cd:	mov    rsi,r13
    16d0:	mov    rdi,rbx
    16d3:	call   16d8 <botlish_fn_17+0x170>
			16d4: R_X86_64_PLT32	rt_int_add-0x4
    16d8:	mov    rsi,rax
    16db:	mov    QWORD PTR [rsp+0x8],rsi
    16e0:	mov    QWORD PTR [rsp+0x10],0x3
    16e9:	test   rsi,0x1
    16f0:	je     1713 <botlish_fn_17+0x1ab>
    16f6:	mov    rax,rsi
    16f9:	add    rax,0x2
    16fd:	mov    rcx,rax
    1700:	seto   al
    1703:	test   al,al
    1705:	jne    1713 <botlish_fn_17+0x1ab>
    170b:	mov    rsi,rcx
    170e:	jmp    1723 <botlish_fn_17+0x1bb>
    1713:	mov    edx,0x3
    1718:	mov    rdi,rbx
    171b:	call   1720 <botlish_fn_17+0x1b8>
			171c: R_X86_64_PLT32	rt_int_add-0x4
    1720:	mov    rsi,rax
    1723:	mov    QWORD PTR [rsp+0x8],rsi
    1728:	mov    edx,0x7
    172d:	mov    rdi,rdx
    1730:	mov    QWORD PTR [rsp+0x10],0x7
    1739:	test   rsi,0x1
    1740:	jne    174e <botlish_fn_17+0x1e6>
    1746:	mov    rdx,rdi
    1749:	jmp    177a <botlish_fn_17+0x212>
    174e:	mov    rax,rsi
    1751:	sar    rax,1
    1754:	imul   QWORD PTR [rip+0xf5]        # 1850 <botlish_fn_17+0x2e8>
    175b:	seto   cl
    175e:	or     rax,0x1
    1762:	test   cl,cl
    1764:	je     1772 <botlish_fn_17+0x20a>
    176a:	mov    rdx,rdi
    176d:	jmp    177a <botlish_fn_17+0x212>
    1772:	mov    rsi,rax
    1775:	jmp    1785 <botlish_fn_17+0x21d>
    177a:	mov    rdi,rbx
    177d:	call   1782 <botlish_fn_17+0x21a>
			177e: R_X86_64_PLT32	rt_int_mul-0x4
    1782:	mov    rsi,rax
    1785:	mov    QWORD PTR [rsp],rsi
    1789:	mov    r13,rsi
    178c:	mov    rsi,r12
    178f:	mov    rdi,rbx
    1792:	call   1797 <botlish_fn_17+0x22f>
			1793: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1797:	mov    QWORD PTR [rsp+0x8],rax
    179c:	mov    QWORD PTR [rsp+0x10],0x5
    17a5:	test   rax,0x1
    17ab:	mov    rcx,rax
    17ae:	je     17dd <botlish_fn_17+0x275>
    17b4:	mov    rax,rcx
    17b7:	sar    rax,1
    17ba:	imul   QWORD PTR [rip+0x97]        # 1858 <botlish_fn_17+0x2f0>
    17c1:	seto   sil
    17c5:	or     rax,0x1
    17c9:	test   sil,sil
    17cc:	jne    17dd <botlish_fn_17+0x275>
    17d2:	mov    rdx,rax
    17d5:	mov    rsi,r13
    17d8:	jmp    17f3 <botlish_fn_17+0x28b>
    17dd:	mov    edx,0x5
    17e2:	mov    rsi,rcx
    17e5:	mov    rdi,rbx
    17e8:	call   17ed <botlish_fn_17+0x285>
			17e9: R_X86_64_PLT32	rt_int_mul-0x4
    17ed:	mov    rdx,rax
    17f0:	mov    rsi,r13
    17f3:	mov    rdi,rsi
    17f6:	and    rdi,rdx
    17f9:	test   rdi,0x1
    1800:	jne    1826 <botlish_fn_17+0x2be>
    1806:	mov    rdi,rbx
    1809:	call   180e <botlish_fn_17+0x2a6>
			180a: R_X86_64_PLT32	rt_int_cmp-0x4
    180e:	mov    esi,0x2
    1813:	test   rax,rax
    1816:	mov    rax,rsi
    1819:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1850 <botlish_fn_17+0x2e8>
    1821:	jmp    1836 <botlish_fn_17+0x2ce>
    1826:	mov    eax,0x2
    182b:	cmp    rsi,rdx
    182e:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1850 <botlish_fn_17+0x2e8>
    1836:	mov    rbx,QWORD PTR [rsp+0x20]
    183b:	mov    r12,QWORD PTR [rsp+0x28]
    1840:	mov    r13,QWORD PTR [rsp+0x30]
    1845:	add    rsp,0x40
    1849:	mov    rsp,rbp
    184c:	pop    rbp
    184d:	ret
    184e:	add    BYTE PTR [rax],al
    1850:	(bad)
    1851:	add    BYTE PTR [rax],al
    1853:	add    BYTE PTR [rax],al
    1855:	add    BYTE PTR [rax],al
    1857:	add    BYTE PTR [rax+rax*1],al
    185a:	add    BYTE PTR [rax],al
    185c:	add    BYTE PTR [rax],al
	...

0000000000001860 <botlish_entry_17: ht_should_grow<HashTable>>:
    1860:	push   rbp
    1861:	mov    rbp,rsp
    1864:	mov    rsi,QWORD PTR [rdx]
    1867:	call   186c <botlish_entry_17+0xc>
			1868: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    186c:	mov    rsp,rbp
    186f:	pop    rbp
    1870:	ret
    1871:	add    BYTE PTR [rax],al
    1873:	add    BYTE PTR [rax],al
    1875:	add    BYTE PTR [rax],al
	...

0000000000001878 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1878:	push   rbp
    1879:	mov    rbp,rsp
    187c:	sub    rsp,0x40
    1880:	mov    QWORD PTR [rsp+0x20],rbx
    1885:	mov    QWORD PTR [rsp+0x28],r12
    188a:	mov    QWORD PTR [rsp+0x30],r13
    188f:	mov    rbx,rdi
    1892:	mov    QWORD PTR [rsp+0x10],0x0
    189b:	mov    QWORD PTR [rsp],rsi
    189f:	mov    r12,rsi
    18a2:	mov    rsi,r12
    18a5:	mov    rdi,rbx
    18a8:	call   18ad <botlish_fn_18+0x35>
			18a9: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    18ad:	test   rax,rax
    18b0:	mov    r13,rax
    18b3:	je     1aa1 <botlish_fn_18+0x229>
    18b9:	mov    rsi,r12
    18bc:	mov    rdi,rbx
    18bf:	call   18c4 <botlish_fn_18+0x4c>
			18c0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    18c4:	mov    r11,rax
    18c7:	test   r11,r11
    18ca:	je     1aa1 <botlish_fn_18+0x229>
    18d0:	mov    ecx,0x1
    18d5:	mov    rax,r13
    18d8:	test   rax,0x1
    18de:	je     18ec <botlish_fn_18+0x74>
    18e4:	mov    r13,rax
    18e7:	jmp    1910 <botlish_fn_18+0x98>
    18ec:	xor    ecx,ecx
    18ee:	test   rax,0x7
    18f4:	je     1902 <botlish_fn_18+0x8a>
    18fa:	mov    r13,rax
    18fd:	jmp    1910 <botlish_fn_18+0x98>
    1902:	movzx  rcx,BYTE PTR [rax]
    1906:	mov    r13,rax
    1909:	rex cmp cl,0x1
    190d:	sete   cl
    1910:	test   cl,cl
    1912:	jne    1933 <botlish_fn_18+0xbb>
    1918:	mov    rdi,rbx
    191b:	mov    rsi,QWORD PTR [rdi+0x10]
    191f:	mov    rcx,QWORD PTR [rsi+0x8]
    1923:	xor    rdx,rdx
    1926:	mov    rsi,r13
    1929:	call   192e <botlish_fn_18+0xb6>
			192a: R_X86_64_PLT32	rt_type_error-0x4
    192e:	jmp    1aa1 <botlish_fn_18+0x229>
    1933:	mov    rsi,r13
    1936:	mov    eax,0x1
    193b:	test   r11,0x1
    1942:	je     1950 <botlish_fn_18+0xd8>
    1948:	mov    r8,r11
    194b:	jmp    1975 <botlish_fn_18+0xfd>
    1950:	xor    eax,eax
    1952:	test   r11,0x7
    1959:	je     1967 <botlish_fn_18+0xef>
    195f:	mov    r8,r11
    1962:	jmp    1975 <botlish_fn_18+0xfd>
    1967:	movzx  r10,BYTE PTR [r11]
    196b:	mov    r8,r11
    196e:	cmp    r10b,0x1
    1972:	sete   al
    1975:	test   al,al
    1977:	jne    1998 <botlish_fn_18+0x120>
    197d:	mov    rdi,rbx
    1980:	mov    rax,QWORD PTR [rdi+0x10]
    1984:	mov    rcx,QWORD PTR [rax+0x8]
    1988:	xor    rdx,rdx
    198b:	mov    rsi,r8
    198e:	call   1993 <botlish_fn_18+0x11b>
			198f: R_X86_64_PLT32	rt_type_error-0x4
    1993:	jmp    1aa1 <botlish_fn_18+0x229>
    1998:	mov    r11,r8
    199b:	mov    rax,rsi
    199e:	and    rax,r11
    19a1:	test   rax,0x1
    19a7:	jne    19cd <botlish_fn_18+0x155>
    19ad:	mov    rdx,r8
    19b0:	mov    rdi,rbx
    19b3:	call   19b8 <botlish_fn_18+0x140>
			19b4: R_X86_64_PLT32	rt_int_cmp-0x4
    19b8:	mov    ecx,0x2
    19bd:	test   rax,rax
    19c0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1ad8 <botlish_fn_18+0x260>
    19c8:	jmp    19e0 <botlish_fn_18+0x168>
    19cd:	mov    ecx,0x2
    19d2:	mov    r11,r8
    19d5:	cmp    rsi,r11
    19d8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1ad8 <botlish_fn_18+0x260>
    19e0:	cmp    rcx,0x6
    19e4:	je     1a7a <botlish_fn_18+0x202>
    19ea:	mov    rsi,r12
    19ed:	mov    rdi,rbx
    19f0:	call   19f5 <botlish_fn_18+0x17d>
			19f1: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    19f5:	mov    QWORD PTR [rsp+0x8],rax
    19fa:	mov    QWORD PTR [rsp+0x10],0x5
    1a03:	test   rax,0x1
    1a09:	mov    rsi,rax
    1a0c:	je     1a39 <botlish_fn_18+0x1c1>
    1a12:	mov    rcx,rsi
    1a15:	mov    rax,rcx
    1a18:	sar    rax,1
    1a1b:	imul   QWORD PTR [rip+0xbe]        # 1ae0 <botlish_fn_18+0x268>
    1a22:	seto   cl
    1a25:	or     rax,0x1
    1a29:	test   cl,cl
    1a2b:	jne    1a39 <botlish_fn_18+0x1c1>
    1a31:	mov    rdx,rax
    1a34:	jmp    1a49 <botlish_fn_18+0x1d1>
    1a39:	mov    edx,0x5
    1a3e:	mov    rdi,rbx
    1a41:	call   1a46 <botlish_fn_18+0x1ce>
			1a42: R_X86_64_PLT32	rt_int_mul-0x4
    1a46:	mov    rdx,rax
    1a49:	mov    QWORD PTR [rsp+0x8],rdx
    1a4e:	mov    rsi,r12
    1a51:	mov    rdi,rbx
    1a54:	call   1a59 <botlish_fn_18+0x1e1>
			1a55: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a59:	test   rax,rax
    1a5c:	je     1aa1 <botlish_fn_18+0x229>
    1a62:	mov    rbx,QWORD PTR [rsp+0x20]
    1a67:	mov    r12,QWORD PTR [rsp+0x28]
    1a6c:	mov    r13,QWORD PTR [rsp+0x30]
    1a71:	add    rsp,0x40
    1a75:	mov    rsp,rbp
    1a78:	pop    rbp
    1a79:	ret
    1a7a:	mov    rsi,r12
    1a7d:	mov    rdi,rbx
    1a80:	call   1a85 <botlish_fn_18+0x20d>
			1a81: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1a85:	mov    QWORD PTR [rsp+0x8],rax
    1a8a:	mov    rdx,rax
    1a8d:	mov    rsi,r12
    1a90:	mov    rdi,rbx
    1a93:	call   1a98 <botlish_fn_18+0x220>
			1a94: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a98:	test   rax,rax
    1a9b:	jne    1abc <botlish_fn_18+0x244>
    1aa1:	xor    rax,rax
    1aa4:	mov    rbx,QWORD PTR [rsp+0x20]
    1aa9:	mov    r12,QWORD PTR [rsp+0x28]
    1aae:	mov    r13,QWORD PTR [rsp+0x30]
    1ab3:	add    rsp,0x40
    1ab7:	mov    rsp,rbp
    1aba:	pop    rbp
    1abb:	ret
    1abc:	mov    rbx,QWORD PTR [rsp+0x20]
    1ac1:	mov    r12,QWORD PTR [rsp+0x28]
    1ac6:	mov    r13,QWORD PTR [rsp+0x30]
    1acb:	add    rsp,0x40
    1acf:	mov    rsp,rbp
    1ad2:	pop    rbp
    1ad3:	ret
    1ad4:	add    BYTE PTR [rax],al
    1ad6:	add    BYTE PTR [rax],al
    1ad8:	(bad)
    1ad9:	add    BYTE PTR [rax],al
    1adb:	add    BYTE PTR [rax],al
    1add:	add    BYTE PTR [rax],al
    1adf:	add    BYTE PTR [rax+rax*1],al
    1ae2:	add    BYTE PTR [rax],al
    1ae4:	add    BYTE PTR [rax],al
	...

0000000000001ae8 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1ae8:	push   rbp
    1ae9:	mov    rbp,rsp
    1aec:	mov    rsi,QWORD PTR [rdx]
    1aef:	call   1af4 <botlish_entry_18+0xc>
			1af0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1af4:	mov    rsp,rbp
    1af7:	pop    rbp
    1af8:	ret
    1af9:	add    BYTE PTR [rax],al
    1afb:	add    BYTE PTR [rax],al
    1afd:	add    BYTE PTR [rax],al
	...

0000000000001b00 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    1b00:	push   rbp
    1b01:	mov    rbp,rsp
    1b04:	sub    rsp,0x70
    1b08:	mov    QWORD PTR [rsp+0x40],rbx
    1b0d:	mov    QWORD PTR [rsp+0x48],r12
    1b12:	mov    QWORD PTR [rsp+0x50],r13
    1b17:	mov    QWORD PTR [rsp+0x58],r14
    1b1c:	mov    QWORD PTR [rsp+0x60],r15
    1b21:	mov    r12,rdi
    1b24:	mov    r14,r8
    1b27:	mov    r15,rdx
    1b2a:	mov    QWORD PTR [rsp+0x30],rcx
    1b2f:	mov    QWORD PTR [rsp],rsi
    1b33:	mov    r9,QWORD PTR [rsi+0x18]
    1b37:	mov    r13,rsi
    1b3a:	mov    rsi,QWORD PTR [r9]
    1b3d:	mov    rdx,r15
    1b40:	mov    rdi,r12
    1b43:	call   1b48 <botlish_fn_19+0x48>
			1b44: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b48:	test   rax,rax
    1b4b:	je     1ddf <botlish_fn_19+0x2df>
    1b51:	mov    QWORD PTR [rsp+0x8],rax
    1b56:	mov    rbx,r13
    1b59:	mov    r13,rax
    1b5c:	mov    rax,QWORD PTR [rbx+0x18]
    1b60:	mov    rsi,QWORD PTR [rax]
    1b63:	mov    ecx,0x3
    1b68:	mov    rdx,r15
    1b6b:	mov    rdi,r12
    1b6e:	call   1b73 <botlish_fn_19+0x73>
			1b6f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b73:	test   rax,rax
    1b76:	je     1ddf <botlish_fn_19+0x2df>
    1b7c:	mov    rax,QWORD PTR [rbx+0x18]
    1b80:	mov    rsi,QWORD PTR [rax+0x8]
    1b84:	mov    rcx,QWORD PTR [rsp+0x30]
    1b89:	mov    rdx,r15
    1b8c:	mov    rdi,r12
    1b8f:	call   1b94 <botlish_fn_19+0x94>
			1b90: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b94:	test   rax,rax
    1b97:	je     1ddf <botlish_fn_19+0x2df>
    1b9d:	mov    rax,QWORD PTR [rbx+0x18]
    1ba1:	mov    rsi,QWORD PTR [rax+0x10]
    1ba5:	mov    rcx,r14
    1ba8:	mov    rdx,r15
    1bab:	mov    rdi,r12
    1bae:	call   1bb3 <botlish_fn_19+0xb3>
			1baf: R_X86_64_PLT32	rt_mutarray_set-0x4
    1bb3:	test   rax,rax
    1bb6:	je     1ddf <botlish_fn_19+0x2df>
    1bbc:	mov    rax,QWORD PTR [rbx+0x18]
    1bc0:	mov    rsi,QWORD PTR [rax+0x18]
    1bc4:	mov    QWORD PTR [rsp+0x10],rsi
    1bc9:	mov    r14,rsi
    1bcc:	mov    QWORD PTR [rsp+0x18],0x1
    1bd5:	mov    rsi,rbx
    1bd8:	mov    rdi,r12
    1bdb:	call   1be0 <botlish_fn_19+0xe0>
			1bdc: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1be0:	test   rax,rax
    1be3:	je     1ddf <botlish_fn_19+0x2df>
    1be9:	mov    QWORD PTR [rsp+0x20],rax
    1bee:	mov    QWORD PTR [rsp+0x28],0x3
    1bf7:	mov    ecx,0x1
    1bfc:	test   rax,0x1
    1c02:	je     1c10 <botlish_fn_19+0x110>
    1c08:	mov    rsi,rax
    1c0b:	jmp    1c34 <botlish_fn_19+0x134>
    1c10:	xor    ecx,ecx
    1c12:	test   rax,0x7
    1c18:	je     1c26 <botlish_fn_19+0x126>
    1c1e:	mov    rsi,rax
    1c21:	jmp    1c34 <botlish_fn_19+0x134>
    1c26:	movzx  rcx,BYTE PTR [rax]
    1c2a:	mov    rsi,rax
    1c2d:	rex cmp cl,0x1
    1c31:	sete   cl
    1c34:	test   cl,cl
    1c36:	jne    1c53 <botlish_fn_19+0x153>
    1c3c:	mov    rdi,r12
    1c3f:	mov    rax,QWORD PTR [rdi+0x10]
    1c43:	mov    rcx,QWORD PTR [rax]
    1c46:	xor    rdx,rdx
    1c49:	call   1c4e <botlish_fn_19+0x14e>
			1c4a: R_X86_64_PLT32	rt_type_error-0x4
    1c4e:	jmp    1ddf <botlish_fn_19+0x2df>
    1c53:	test   rsi,0x1
    1c5a:	je     1c72 <botlish_fn_19+0x172>
    1c60:	mov    rcx,rsi
    1c63:	add    rcx,0x2
    1c67:	seto   al
    1c6a:	test   al,al
    1c6c:	je     1c82 <botlish_fn_19+0x182>
    1c72:	mov    edx,0x3
    1c77:	mov    rdi,r12
    1c7a:	call   1c7f <botlish_fn_19+0x17f>
			1c7b: R_X86_64_PLT32	rt_int_add-0x4
    1c7f:	mov    rcx,rax
    1c82:	mov    edx,0x1
    1c87:	mov    rsi,r14
    1c8a:	mov    rdi,r12
    1c8d:	call   1c92 <botlish_fn_19+0x192>
			1c8e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c92:	test   rax,rax
    1c95:	je     1ddf <botlish_fn_19+0x2df>
    1c9b:	mov    rax,r13
    1c9e:	test   rax,0x1
    1ca4:	jne    1ccf <botlish_fn_19+0x1cf>
    1caa:	mov    edx,0x5
    1caf:	mov    rsi,r13
    1cb2:	mov    rdi,r12
    1cb5:	call   1cba <botlish_fn_19+0x1ba>
			1cb6: R_X86_64_PLT32	rt_int_cmp-0x4
    1cba:	mov    ecx,0x2
    1cbf:	test   rax,rax
    1cc2:	cmove  rcx,QWORD PTR [rip+0x166]        # 1e30 <botlish_fn_19+0x330>
    1cca:	jmp    1ce3 <botlish_fn_19+0x1e3>
    1ccf:	mov    rsi,r13
    1cd2:	mov    ecx,0x2
    1cd7:	cmp    rsi,0x5
    1cdb:	cmove  rcx,QWORD PTR [rip+0x14d]        # 1e30 <botlish_fn_19+0x330>
    1ce3:	cmp    rcx,0x6
    1ce7:	je     1cf5 <botlish_fn_19+0x1f5>
    1ced:	mov    rax,rbx
    1cf0:	jmp    1e07 <botlish_fn_19+0x307>
    1cf5:	mov    rax,QWORD PTR [rbx+0x18]
    1cf9:	mov    rsi,QWORD PTR [rax+0x18]
    1cfd:	mov    QWORD PTR [rsp+0x8],rsi
    1d02:	mov    r14,rsi
    1d05:	mov    QWORD PTR [rsp+0x10],0x3
    1d0e:	mov    rsi,rbx
    1d11:	mov    rdi,r12
    1d14:	call   1d19 <botlish_fn_19+0x219>
			1d15: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1d19:	mov    r13,rbx
    1d1c:	test   rax,rax
    1d1f:	je     1ddf <botlish_fn_19+0x2df>
    1d25:	mov    QWORD PTR [rsp+0x18],rax
    1d2a:	mov    QWORD PTR [rsp+0x20],0x3
    1d33:	mov    ecx,0x1
    1d38:	test   rax,0x1
    1d3e:	je     1d4c <botlish_fn_19+0x24c>
    1d44:	mov    rsi,rax
    1d47:	jmp    1d70 <botlish_fn_19+0x270>
    1d4c:	xor    ecx,ecx
    1d4e:	test   rax,0x7
    1d54:	je     1d62 <botlish_fn_19+0x262>
    1d5a:	mov    rsi,rax
    1d5d:	jmp    1d70 <botlish_fn_19+0x270>
    1d62:	movzx  r10,BYTE PTR [rax]
    1d66:	mov    rsi,rax
    1d69:	cmp    r10b,0x1
    1d6d:	sete   cl
    1d70:	test   cl,cl
    1d72:	jne    1d90 <botlish_fn_19+0x290>
    1d78:	mov    rdi,r12
    1d7b:	mov    rax,QWORD PTR [rdi+0x10]
    1d7f:	mov    rcx,QWORD PTR [rax+0x10]
    1d83:	xor    rdx,rdx
    1d86:	call   1d8b <botlish_fn_19+0x28b>
			1d87: R_X86_64_PLT32	rt_type_error-0x4
    1d8b:	jmp    1ddf <botlish_fn_19+0x2df>
    1d90:	test   rsi,0x1
    1d97:	je     1db6 <botlish_fn_19+0x2b6>
    1d9d:	mov    rcx,rsi
    1da0:	sub    rcx,0x3
    1da4:	seto   al
    1da7:	add    rcx,0x1
    1dae:	test   al,al
    1db0:	je     1dc6 <botlish_fn_19+0x2c6>
    1db6:	mov    edx,0x3
    1dbb:	mov    rdi,r12
    1dbe:	call   1dc3 <botlish_fn_19+0x2c3>
			1dbf: R_X86_64_PLT32	rt_int_sub-0x4
    1dc3:	mov    rcx,rax
    1dc6:	mov    edx,0x3
    1dcb:	mov    rsi,r14
    1dce:	mov    rdi,r12
    1dd1:	call   1dd6 <botlish_fn_19+0x2d6>
			1dd2: R_X86_64_PLT32	rt_mutarray_set-0x4
    1dd6:	test   rax,rax
    1dd9:	jne    1e04 <botlish_fn_19+0x304>
    1ddf:	xor    rax,rax
    1de2:	mov    rbx,QWORD PTR [rsp+0x40]
    1de7:	mov    r12,QWORD PTR [rsp+0x48]
    1dec:	mov    r13,QWORD PTR [rsp+0x50]
    1df1:	mov    r14,QWORD PTR [rsp+0x58]
    1df6:	mov    r15,QWORD PTR [rsp+0x60]
    1dfb:	add    rsp,0x70
    1dff:	mov    rsp,rbp
    1e02:	pop    rbp
    1e03:	ret
    1e04:	mov    rax,r13
    1e07:	mov    rbx,QWORD PTR [rsp+0x40]
    1e0c:	mov    r12,QWORD PTR [rsp+0x48]
    1e11:	mov    r13,QWORD PTR [rsp+0x50]
    1e16:	mov    r14,QWORD PTR [rsp+0x58]
    1e1b:	mov    r15,QWORD PTR [rsp+0x60]
    1e20:	add    rsp,0x70
    1e24:	mov    rsp,rbp
    1e27:	pop    rbp
    1e28:	ret
    1e29:	add    BYTE PTR [rax],al
    1e2b:	add    BYTE PTR [rax],al
    1e2d:	add    BYTE PTR [rax],al
    1e2f:	add    BYTE PTR [rsi],al
    1e31:	add    BYTE PTR [rax],al
    1e33:	add    BYTE PTR [rax],al
    1e35:	add    BYTE PTR [rax],al
	...

0000000000001e38 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    1e38:	push   rbp
    1e39:	mov    rbp,rsp
    1e3c:	mov    rsi,QWORD PTR [rdx]
    1e3f:	mov    r9,QWORD PTR [rdx+0x8]
    1e43:	mov    rcx,QWORD PTR [rdx+0x10]
    1e47:	mov    r8,QWORD PTR [rdx+0x18]
    1e4b:	mov    rdx,r9
    1e4e:	call   1e53 <botlish_entry_19+0x1b>
			1e4f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1e53:	mov    rsp,rbp
    1e56:	pop    rbp
    1e57:	ret

0000000000001e58 <botlish_fn_20: ht_set<HashTable, str, str>>:
    1e58:	push   rbp
    1e59:	mov    rbp,rsp
    1e5c:	sub    rsp,0x60
    1e60:	mov    QWORD PTR [rsp+0x30],rbx
    1e65:	mov    QWORD PTR [rsp+0x38],r12
    1e6a:	mov    QWORD PTR [rsp+0x40],r13
    1e6f:	mov    QWORD PTR [rsp+0x48],r14
    1e74:	mov    QWORD PTR [rsp+0x50],r15
    1e79:	mov    r12,rdi
    1e7c:	mov    r13,rdx
    1e7f:	mov    QWORD PTR [rsp],rsi
    1e83:	mov    r14,rsi
    1e86:	mov    QWORD PTR [rsp+0x8],rdx
    1e8b:	mov    QWORD PTR [rsp+0x10],rcx
    1e90:	mov    rbx,rcx
    1e93:	mov    rdx,r13
    1e96:	mov    rsi,r14
    1e99:	mov    rdi,r12
    1e9c:	call   1ea1 <botlish_fn_20+0x49>
			1e9d: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1ea1:	test   rax,rax
    1ea4:	je     207c <botlish_fn_20+0x224>
    1eaa:	mov    QWORD PTR [rsp+0x18],rax
    1eaf:	mov    rcx,rax
    1eb2:	mov    r8,0xffffffffffffffff
    1eb9:	mov    r15,r8
    1ebc:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1ec5:	mov    rdx,r13
    1ec8:	mov    rsi,r14
    1ecb:	mov    rdi,r12
    1ece:	call   1ed3 <botlish_fn_20+0x7b>
			1ecf: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1ed3:	test   rax,rax
    1ed6:	je     207c <botlish_fn_20+0x224>
    1edc:	mov    QWORD PTR [rsp+0x18],rax
    1ee1:	mov    rsi,r14
    1ee4:	mov    QWORD PTR [rsp+0x28],rax
    1ee9:	mov    rax,QWORD PTR [rsi+0x18]
    1eed:	mov    rsi,QWORD PTR [rax]
    1ef0:	mov    rdx,QWORD PTR [rsp+0x28]
    1ef5:	mov    rdi,r12
    1ef8:	call   1efd <botlish_fn_20+0xa5>
			1ef9: R_X86_64_PLT32	rt_mutarray_get-0x4
    1efd:	test   rax,rax
    1f00:	je     207c <botlish_fn_20+0x224>
    1f06:	test   rax,0x1
    1f0c:	mov    rsi,rax
    1f0f:	jne    1f37 <botlish_fn_20+0xdf>
    1f15:	mov    edx,0x3
    1f1a:	mov    rdi,r12
    1f1d:	call   1f22 <botlish_fn_20+0xca>
			1f1e: R_X86_64_PLT32	rt_int_cmp-0x4
    1f22:	mov    ecx,0x2
    1f27:	test   rax,rax
    1f2a:	cmove  rcx,QWORD PTR [rip+0x196]        # 20c8 <botlish_fn_20+0x270>
    1f32:	jmp    1f48 <botlish_fn_20+0xf0>
    1f37:	mov    ecx,0x2
    1f3c:	cmp    rsi,0x3
    1f40:	cmove  rcx,QWORD PTR [rip+0x180]        # 20c8 <botlish_fn_20+0x270>
    1f48:	cmp    rcx,0x6
    1f4c:	je     2058 <botlish_fn_20+0x200>
    1f52:	mov    rsi,r14
    1f55:	mov    rdi,r12
    1f58:	call   1f5d <botlish_fn_20+0x105>
			1f59: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1f5d:	test   rax,rax
    1f60:	je     207c <botlish_fn_20+0x224>
    1f66:	cmp    rax,0x6
    1f6a:	je     1fb1 <botlish_fn_20+0x159>
    1f70:	mov    rcx,r13
    1f73:	mov    rdx,QWORD PTR [rsp+0x28]
    1f78:	mov    rsi,r14
    1f7b:	mov    rdi,r12
    1f7e:	mov    r8,rbx
    1f81:	call   1f86 <botlish_fn_20+0x12e>
			1f82: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1f86:	test   rax,rax
    1f89:	je     207c <botlish_fn_20+0x224>
    1f8f:	mov    rbx,QWORD PTR [rsp+0x30]
    1f94:	mov    r12,QWORD PTR [rsp+0x38]
    1f99:	mov    r13,QWORD PTR [rsp+0x40]
    1f9e:	mov    r14,QWORD PTR [rsp+0x48]
    1fa3:	mov    r15,QWORD PTR [rsp+0x50]
    1fa8:	add    rsp,0x60
    1fac:	mov    rsp,rbp
    1faf:	pop    rbp
    1fb0:	ret
    1fb1:	mov    rsi,r14
    1fb4:	mov    rdi,r12
    1fb7:	call   1fbc <botlish_fn_20+0x164>
			1fb8: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1fbc:	mov    rcx,rax
    1fbf:	mov    r14,rax
    1fc2:	test   rax,rcx
    1fc5:	je     207c <botlish_fn_20+0x224>
    1fcb:	mov    rax,r14
    1fce:	mov    QWORD PTR [rsp],rax
    1fd2:	mov    rdx,r13
    1fd5:	mov    rsi,r14
    1fd8:	mov    rdi,r12
    1fdb:	call   1fe0 <botlish_fn_20+0x188>
			1fdc: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1fe0:	test   rax,rax
    1fe3:	je     207c <botlish_fn_20+0x224>
    1fe9:	mov    QWORD PTR [rsp+0x18],rax
    1fee:	mov    rcx,rax
    1ff1:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1ffa:	mov    r8,r15
    1ffd:	mov    rdx,r13
    2000:	mov    rsi,r14
    2003:	mov    rdi,r12
    2006:	call   200b <botlish_fn_20+0x1b3>
			2007: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    200b:	test   rax,rax
    200e:	je     207c <botlish_fn_20+0x224>
    2014:	mov    QWORD PTR [rsp+0x18],rax
    2019:	mov    rcx,r13
    201c:	mov    rdx,rax
    201f:	mov    rsi,r14
    2022:	mov    rdi,r12
    2025:	mov    r8,rbx
    2028:	call   202d <botlish_fn_20+0x1d5>
			2029: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    202d:	test   rax,rax
    2030:	je     207c <botlish_fn_20+0x224>
    2036:	mov    rbx,QWORD PTR [rsp+0x30]
    203b:	mov    r12,QWORD PTR [rsp+0x38]
    2040:	mov    r13,QWORD PTR [rsp+0x40]
    2045:	mov    r14,QWORD PTR [rsp+0x48]
    204a:	mov    r15,QWORD PTR [rsp+0x50]
    204f:	add    rsp,0x60
    2053:	mov    rsp,rbp
    2056:	pop    rbp
    2057:	ret
    2058:	mov    rdx,QWORD PTR [rsp+0x28]
    205d:	mov    rsi,r14
    2060:	mov    rax,QWORD PTR [rsi+0x18]
    2064:	mov    rsi,QWORD PTR [rax+0x10]
    2068:	mov    rcx,rbx
    206b:	mov    rdi,r12
    206e:	call   2073 <botlish_fn_20+0x21b>
			206f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2073:	test   rax,rax
    2076:	jne    20a1 <botlish_fn_20+0x249>
    207c:	xor    rax,rax
    207f:	mov    rbx,QWORD PTR [rsp+0x30]
    2084:	mov    r12,QWORD PTR [rsp+0x38]
    2089:	mov    r13,QWORD PTR [rsp+0x40]
    208e:	mov    r14,QWORD PTR [rsp+0x48]
    2093:	mov    r15,QWORD PTR [rsp+0x50]
    2098:	add    rsp,0x60
    209c:	mov    rsp,rbp
    209f:	pop    rbp
    20a0:	ret
    20a1:	mov    rax,r14
    20a4:	mov    rbx,QWORD PTR [rsp+0x30]
    20a9:	mov    r12,QWORD PTR [rsp+0x38]
    20ae:	mov    r13,QWORD PTR [rsp+0x40]
    20b3:	mov    r14,QWORD PTR [rsp+0x48]
    20b8:	mov    r15,QWORD PTR [rsp+0x50]
    20bd:	add    rsp,0x60
    20c1:	mov    rsp,rbp
    20c4:	pop    rbp
    20c5:	ret
    20c6:	add    BYTE PTR [rax],al
    20c8:	(bad)
    20c9:	add    BYTE PTR [rax],al
    20cb:	add    BYTE PTR [rax],al
    20cd:	add    BYTE PTR [rax],al
	...

00000000000020d0 <botlish_entry_20: ht_set<HashTable, str, str>>:
    20d0:	push   rbp
    20d1:	mov    rbp,rsp
    20d4:	mov    rsi,QWORD PTR [rdx]
    20d7:	mov    r8,QWORD PTR [rdx+0x8]
    20db:	mov    rcx,QWORD PTR [rdx+0x10]
    20df:	mov    rdx,r8
    20e2:	call   20e7 <botlish_entry_20+0x17>
			20e3: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    20e7:	mov    rsp,rbp
    20ea:	pop    rbp
    20eb:	ret
    20ec:	add    BYTE PTR [rax],al
	...

00000000000020f0 <botlish_fn_21: ht_delete<HashTable, str>>:
    20f0:	push   rbp
    20f1:	mov    rbp,rsp
    20f4:	sub    rsp,0x50
    20f8:	mov    QWORD PTR [rsp+0x30],rbx
    20fd:	mov    QWORD PTR [rsp+0x38],r12
    2102:	mov    QWORD PTR [rsp+0x40],r13
    2107:	mov    QWORD PTR [rsp+0x48],r14
    210c:	mov    r13,rdi
    210f:	mov    QWORD PTR [rsp+0x18],0x0
    2118:	mov    QWORD PTR [rsp+0x20],0x0
    2121:	mov    QWORD PTR [rsp],rsi
    2125:	mov    r12,rsi
    2128:	mov    QWORD PTR [rsp+0x8],rdx
    212d:	mov    r14,rdx
    2130:	mov    rbx,r12
    2133:	mov    rdx,r14
    2136:	mov    rsi,rbx
    2139:	mov    rdi,r13
    213c:	call   2141 <botlish_fn_21+0x51>
			213d: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2141:	test   rax,rax
    2144:	je     23f0 <botlish_fn_21+0x300>
    214a:	mov    QWORD PTR [rsp+0x10],rax
    214f:	mov    rcx,rax
    2152:	mov    rdx,r14
    2155:	mov    rsi,rbx
    2158:	mov    rdi,r13
    215b:	call   2160 <botlish_fn_21+0x70>
			215c: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2160:	mov    rcx,rax
    2163:	mov    r12,rax
    2166:	test   rax,rcx
    2169:	je     23f0 <botlish_fn_21+0x300>
    216f:	mov    rax,r12
    2172:	test   rax,0x1
    2178:	jne    21a3 <botlish_fn_21+0xb3>
    217e:	mov    edx,0x1
    2183:	mov    rsi,r12
    2186:	mov    rdi,r13
    2189:	call   218e <botlish_fn_21+0x9e>
			218a: R_X86_64_PLT32	rt_int_cmp-0x4
    218e:	mov    ecx,0x2
    2193:	test   rax,rax
    2196:	cmovge rcx,QWORD PTR [rip+0x292]        # 2430 <botlish_fn_21+0x340>
    219e:	jmp    21b3 <botlish_fn_21+0xc3>
    21a3:	mov    ecx,0x2
    21a8:	test   r12,r12
    21ab:	cmovg  rcx,QWORD PTR [rip+0x27d]        # 2430 <botlish_fn_21+0x340>
    21b3:	cmp    rcx,0x6
    21b7:	je     21c5 <botlish_fn_21+0xd5>
    21bd:	mov    rax,rbx
    21c0:	jmp    2413 <botlish_fn_21+0x323>
    21c5:	mov    rcx,QWORD PTR [rbx+0x18]
    21c9:	mov    rsi,QWORD PTR [rcx]
    21cc:	mov    ecx,0x5
    21d1:	mov    rdx,r12
    21d4:	mov    rdi,r13
    21d7:	call   21dc <botlish_fn_21+0xec>
			21d8: R_X86_64_PLT32	rt_mutarray_set-0x4
    21dc:	test   rax,rax
    21df:	je     23f0 <botlish_fn_21+0x300>
    21e5:	mov    rax,QWORD PTR [rbx+0x18]
    21e9:	mov    rsi,QWORD PTR [rax+0x8]
    21ed:	mov    ecx,0xa
    21f2:	mov    rdx,r12
    21f5:	mov    rdi,r13
    21f8:	call   21fd <botlish_fn_21+0x10d>
			21f9: R_X86_64_PLT32	rt_mutarray_set-0x4
    21fd:	test   rax,rax
    2200:	je     23f0 <botlish_fn_21+0x300>
    2206:	mov    rax,QWORD PTR [rbx+0x18]
    220a:	mov    rsi,QWORD PTR [rax+0x10]
    220e:	mov    ecx,0xa
    2213:	mov    rdx,r12
    2216:	mov    rdi,r13
    2219:	call   221e <botlish_fn_21+0x12e>
			221a: R_X86_64_PLT32	rt_mutarray_set-0x4
    221e:	test   rax,rax
    2221:	je     23f0 <botlish_fn_21+0x300>
    2227:	mov    rax,QWORD PTR [rbx+0x18]
    222b:	mov    rsi,QWORD PTR [rax+0x18]
    222f:	mov    QWORD PTR [rsp+0x8],rsi
    2234:	mov    r12,rsi
    2237:	mov    QWORD PTR [rsp+0x10],0x1
    2240:	mov    rsi,rbx
    2243:	mov    rdi,r13
    2246:	call   224b <botlish_fn_21+0x15b>
			2247: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    224b:	test   rax,rax
    224e:	je     23f0 <botlish_fn_21+0x300>
    2254:	mov    QWORD PTR [rsp+0x18],rax
    2259:	mov    QWORD PTR [rsp+0x20],0x3
    2262:	mov    edx,0x1
    2267:	test   rax,0x1
    226d:	je     227b <botlish_fn_21+0x18b>
    2273:	mov    rsi,rax
    2276:	jmp    229f <botlish_fn_21+0x1af>
    227b:	xor    edx,edx
    227d:	test   rax,0x7
    2283:	je     2291 <botlish_fn_21+0x1a1>
    2289:	mov    rsi,rax
    228c:	jmp    229f <botlish_fn_21+0x1af>
    2291:	movzx  rcx,BYTE PTR [rax]
    2295:	mov    rsi,rax
    2298:	rex cmp cl,0x1
    229c:	sete   dl
    229f:	test   dl,dl
    22a1:	jne    22bf <botlish_fn_21+0x1cf>
    22a7:	mov    rdi,r13
    22aa:	mov    rax,QWORD PTR [rdi+0x10]
    22ae:	mov    rcx,QWORD PTR [rax+0x10]
    22b2:	xor    rdx,rdx
    22b5:	call   22ba <botlish_fn_21+0x1ca>
			22b6: R_X86_64_PLT32	rt_type_error-0x4
    22ba:	jmp    23f0 <botlish_fn_21+0x300>
    22bf:	test   rsi,0x1
    22c6:	je     22e5 <botlish_fn_21+0x1f5>
    22cc:	mov    rcx,rsi
    22cf:	sub    rcx,0x3
    22d3:	seto   al
    22d6:	add    rcx,0x1
    22dd:	test   al,al
    22df:	je     22f5 <botlish_fn_21+0x205>
    22e5:	mov    edx,0x3
    22ea:	mov    rdi,r13
    22ed:	call   22f2 <botlish_fn_21+0x202>
			22ee: R_X86_64_PLT32	rt_int_sub-0x4
    22f2:	mov    rcx,rax
    22f5:	mov    edx,0x1
    22fa:	mov    rsi,r12
    22fd:	mov    rdi,r13
    2300:	call   2305 <botlish_fn_21+0x215>
			2301: R_X86_64_PLT32	rt_mutarray_set-0x4
    2305:	test   rax,rax
    2308:	je     23f0 <botlish_fn_21+0x300>
    230e:	mov    rdx,QWORD PTR [rbx+0x18]
    2312:	mov    rsi,QWORD PTR [rdx+0x18]
    2316:	mov    QWORD PTR [rsp+0x8],rsi
    231b:	mov    r14,rsi
    231e:	mov    QWORD PTR [rsp+0x10],0x3
    2327:	mov    rsi,rbx
    232a:	mov    rdi,r13
    232d:	call   2332 <botlish_fn_21+0x242>
			232e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    2332:	mov    r12,rbx
    2335:	test   rax,rax
    2338:	je     23f0 <botlish_fn_21+0x300>
    233e:	mov    QWORD PTR [rsp+0x18],rax
    2343:	mov    QWORD PTR [rsp+0x20],0x3
    234c:	mov    ecx,0x1
    2351:	test   rax,0x1
    2357:	je     2365 <botlish_fn_21+0x275>
    235d:	mov    rsi,rax
    2360:	jmp    2389 <botlish_fn_21+0x299>
    2365:	xor    ecx,ecx
    2367:	test   rax,0x7
    236d:	je     237b <botlish_fn_21+0x28b>
    2373:	mov    rsi,rax
    2376:	jmp    2389 <botlish_fn_21+0x299>
    237b:	movzx  rcx,BYTE PTR [rax]
    237f:	mov    rsi,rax
    2382:	rex cmp cl,0x1
    2386:	sete   cl
    2389:	test   cl,cl
    238b:	jne    23a8 <botlish_fn_21+0x2b8>
    2391:	mov    rdi,r13
    2394:	mov    rax,QWORD PTR [rdi+0x10]
    2398:	mov    rcx,QWORD PTR [rax]
    239b:	xor    rdx,rdx
    239e:	call   23a3 <botlish_fn_21+0x2b3>
			239f: R_X86_64_PLT32	rt_type_error-0x4
    23a3:	jmp    23f0 <botlish_fn_21+0x300>
    23a8:	test   rsi,0x1
    23af:	je     23c7 <botlish_fn_21+0x2d7>
    23b5:	mov    rcx,rsi
    23b8:	add    rcx,0x2
    23bc:	seto   al
    23bf:	test   al,al
    23c1:	je     23d7 <botlish_fn_21+0x2e7>
    23c7:	mov    edx,0x3
    23cc:	mov    rdi,r13
    23cf:	call   23d4 <botlish_fn_21+0x2e4>
			23d0: R_X86_64_PLT32	rt_int_add-0x4
    23d4:	mov    rcx,rax
    23d7:	mov    edx,0x3
    23dc:	mov    rsi,r14
    23df:	mov    rdi,r13
    23e2:	call   23e7 <botlish_fn_21+0x2f7>
			23e3: R_X86_64_PLT32	rt_mutarray_set-0x4
    23e7:	test   rax,rax
    23ea:	jne    2410 <botlish_fn_21+0x320>
    23f0:	xor    rax,rax
    23f3:	mov    rbx,QWORD PTR [rsp+0x30]
    23f8:	mov    r12,QWORD PTR [rsp+0x38]
    23fd:	mov    r13,QWORD PTR [rsp+0x40]
    2402:	mov    r14,QWORD PTR [rsp+0x48]
    2407:	add    rsp,0x50
    240b:	mov    rsp,rbp
    240e:	pop    rbp
    240f:	ret
    2410:	mov    rax,r12
    2413:	mov    rbx,QWORD PTR [rsp+0x30]
    2418:	mov    r12,QWORD PTR [rsp+0x38]
    241d:	mov    r13,QWORD PTR [rsp+0x40]
    2422:	mov    r14,QWORD PTR [rsp+0x48]
    2427:	add    rsp,0x50
    242b:	mov    rsp,rbp
    242e:	pop    rbp
    242f:	ret
    2430:	(bad)
    2431:	add    BYTE PTR [rax],al
    2433:	add    BYTE PTR [rax],al
    2435:	add    BYTE PTR [rax],al
	...

0000000000002438 <botlish_entry_21: ht_delete<HashTable, str>>:
    2438:	push   rbp
    2439:	mov    rbp,rsp
    243c:	mov    rsi,QWORD PTR [rdx]
    243f:	mov    rdx,QWORD PTR [rdx+0x8]
    2443:	call   2448 <botlish_entry_21+0x10>
			2444: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2448:	mov    rsp,rbp
    244b:	pop    rbp
    244c:	ret
    244d:	add    BYTE PTR [rax],al
	...

0000000000002450 <botlish_fn_22: sample_checks<generic>>:
    2450:	push   rbp
    2451:	mov    rbp,rsp
    2454:	sub    rsp,0xa0
    245b:	mov    QWORD PTR [rsp+0x70],rbx
    2460:	mov    QWORD PTR [rsp+0x78],r12
    2465:	mov    QWORD PTR [rsp+0x80],r13
    246d:	mov    QWORD PTR [rsp+0x88],r14
    2475:	mov    QWORD PTR [rsp+0x90],r15
    247d:	mov    r13,rdi
    2480:	mov    QWORD PTR [rsp],0x0
    2488:	mov    QWORD PTR [rsp+0x8],0x0
    2491:	mov    QWORD PTR [rsp+0x10],0x0
    249a:	mov    QWORD PTR [rsp+0x18],0x0
    24a3:	mov    QWORD PTR [rsp+0x20],0x0
    24ac:	mov    QWORD PTR [rsp+0x28],0x0
    24b5:	mov    rdi,r13
    24b8:	call   24bd <botlish_fn_22+0x6d>
			24b9: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    24bd:	test   rax,rax
    24c0:	je     271c <botlish_fn_22+0x2cc>
    24c6:	mov    QWORD PTR [rsp],rax
    24ca:	mov    rsi,rax
    24cd:	mov    rdi,r13
    24d0:	mov    rax,QWORD PTR [rdi+0x10]
    24d4:	mov    rdx,QWORD PTR [rax+0x18]
    24d8:	mov    QWORD PTR [rsp+0x8],rdx
    24dd:	mov    rax,QWORD PTR [rdi+0x10]
    24e1:	mov    rcx,QWORD PTR [rax+0x20]
    24e5:	mov    QWORD PTR [rsp+0x10],rcx
    24ea:	call   24ef <botlish_fn_22+0x9f>
			24eb: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    24ef:	test   rax,rax
    24f2:	je     271c <botlish_fn_22+0x2cc>
    24f8:	mov    QWORD PTR [rsp],rax
    24fc:	mov    rdi,r13
    24ff:	mov    rsi,QWORD PTR [rdi+0x10]
    2503:	mov    rdx,QWORD PTR [rsi+0x28]
    2507:	mov    QWORD PTR [rsp+0x8],rdx
    250c:	mov    rsi,QWORD PTR [rdi+0x10]
    2510:	mov    rcx,QWORD PTR [rsi+0x30]
    2514:	mov    QWORD PTR [rsp+0x10],rcx
    2519:	mov    rsi,rax
    251c:	call   2521 <botlish_fn_22+0xd1>
			251d: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2521:	test   rax,rax
    2524:	je     271c <botlish_fn_22+0x2cc>
    252a:	mov    QWORD PTR [rsp],rax
    252e:	mov    rsi,rax
    2531:	mov    rdi,r13
    2534:	mov    r11,QWORD PTR [rdi+0x10]
    2538:	mov    rdx,QWORD PTR [r11+0x18]
    253c:	mov    QWORD PTR [rsp+0x8],rdx
    2541:	mov    rax,QWORD PTR [rdi+0x10]
    2545:	mov    rcx,QWORD PTR [rax+0x38]
    2549:	mov    QWORD PTR [rsp+0x10],rcx
    254e:	call   2553 <botlish_fn_22+0x103>
			254f: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2553:	test   rax,rax
    2556:	je     271c <botlish_fn_22+0x2cc>
    255c:	mov    QWORD PTR [rsp],rax
    2560:	mov    rdi,r13
    2563:	mov    r14,rax
    2566:	mov    rax,QWORD PTR [rdi+0x10]
    256a:	mov    rdx,QWORD PTR [rax+0x28]
    256e:	mov    QWORD PTR [rsp+0x8],rdx
    2573:	mov    rsi,r14
    2576:	call   257b <botlish_fn_22+0x12b>
			2577: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    257b:	test   rax,rax
    257e:	je     271c <botlish_fn_22+0x2cc>
    2584:	mov    QWORD PTR [rsp+0x8],rax
    2589:	mov    rdi,r13
    258c:	mov    r15,rax
    258f:	mov    rax,QWORD PTR [rdi+0x10]
    2593:	mov    rdx,QWORD PTR [rax+0x28]
    2597:	mov    QWORD PTR [rsp+0x10],rdx
    259c:	mov    rsi,r14
    259f:	call   25a4 <botlish_fn_22+0x154>
			25a0: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    25a4:	mov    rcx,rax
    25a7:	mov    r14,rax
    25aa:	test   rax,rcx
    25ad:	je     271c <botlish_fn_22+0x2cc>
    25b3:	mov    rax,r14
    25b6:	mov    QWORD PTR [rsp],rax
    25ba:	mov    rdi,r13
    25bd:	mov    rax,QWORD PTR [rdi+0x10]
    25c1:	mov    rdx,QWORD PTR [rax+0x18]
    25c5:	mov    QWORD PTR [rsp+0x10],rdx
    25ca:	mov    rsi,r14
    25cd:	call   25d2 <botlish_fn_22+0x182>
			25ce: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    25d2:	test   rax,rax
    25d5:	je     271c <botlish_fn_22+0x2cc>
    25db:	mov    rdi,r13
    25de:	mov    rcx,QWORD PTR [rdi+0x10]
    25e2:	mov    rdx,QWORD PTR [rcx+0x38]
    25e6:	mov    rcx,rax
    25e9:	and    rcx,rdx
    25ec:	mov    rsi,rax
    25ef:	test   rcx,0x1
    25f6:	jne    2612 <botlish_fn_22+0x1c2>
    25fc:	mov    rdi,r13
    25ff:	call   2604 <botlish_fn_22+0x1b4>
			2600: R_X86_64_PLT32	rt_value_eq-0x4
    2604:	test   rax,rax
    2607:	je     271c <botlish_fn_22+0x2cc>
    260d:	jmp    2622 <botlish_fn_22+0x1d2>
    2612:	mov    eax,0x2
    2617:	cmp    rsi,rdx
    261a:	cmove  rax,QWORD PTR [rip+0x15e]        # 2780 <botlish_fn_22+0x330>
    2622:	mov    QWORD PTR [rsp+0x10],rax
    2627:	mov    rdi,r13
    262a:	mov    QWORD PTR [rsp+0x60],rax
    262f:	mov    rax,QWORD PTR [rdi+0x10]
    2633:	mov    rdx,QWORD PTR [rax+0x28]
    2637:	mov    QWORD PTR [rsp+0x18],rdx
    263c:	mov    rsi,r14
    263f:	call   2644 <botlish_fn_22+0x1f4>
			2640: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2644:	mov    rbx,rax
    2647:	test   rbx,rbx
    264a:	je     271c <botlish_fn_22+0x2cc>
    2650:	mov    QWORD PTR [rsp+0x18],rbx
    2655:	mov    rdi,r13
    2658:	mov    rax,QWORD PTR [rdi+0x10]
    265c:	mov    rdx,QWORD PTR [rax+0x40]
    2660:	mov    QWORD PTR [rsp+0x20],rdx
    2665:	mov    rsi,r14
    2668:	call   266d <botlish_fn_22+0x21d>
			2669: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    266d:	mov    r12,rax
    2670:	test   r12,r12
    2673:	je     271c <botlish_fn_22+0x2cc>
    2679:	mov    QWORD PTR [rsp+0x20],r12
    267e:	mov    rdi,r13
    2681:	mov    rax,QWORD PTR [rdi+0x10]
    2685:	mov    rdx,QWORD PTR [rax+0x40]
    2689:	mov    QWORD PTR [rsp+0x28],rdx
    268e:	mov    rsi,r14
    2691:	call   2696 <botlish_fn_22+0x246>
			2692: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    2696:	test   rax,rax
    2699:	mov    rsi,rax
    269c:	je     271c <botlish_fn_22+0x2cc>
    26a2:	mov    edx,0xa
    26a7:	mov    rdi,r13
    26aa:	call   26af <botlish_fn_22+0x25f>
			26ab: R_X86_64_PLT32	rt_value_eq-0x4
    26af:	test   rax,rax
    26b2:	je     271c <botlish_fn_22+0x2cc>
    26b8:	mov    QWORD PTR [rsp],rax
    26bc:	mov    rsi,r14
    26bf:	mov    r14,rax
    26c2:	mov    rdi,r13
    26c5:	call   26ca <botlish_fn_22+0x27a>
			26c6: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    26ca:	test   rax,rax
    26cd:	je     271c <botlish_fn_22+0x2cc>
    26d3:	mov    QWORD PTR [rsp+0x28],rax
    26d8:	lea    rdx,[rsp+0x30]
    26dd:	mov    r9,QWORD PTR [rsp+0x60]
    26e2:	mov    QWORD PTR [rsp+0x30],r9
    26e7:	mov    rsi,r15
    26ea:	mov    QWORD PTR [rsp+0x38],rsi
    26ef:	mov    QWORD PTR [rsp+0x40],rbx
    26f4:	mov    QWORD PTR [rsp+0x48],r12
    26f9:	mov    rcx,r14
    26fc:	mov    QWORD PTR [rsp+0x50],rcx
    2701:	mov    QWORD PTR [rsp+0x58],rax
    2706:	mov    esi,0x6
    270b:	mov    rdi,r13
    270e:	call   2713 <botlish_fn_22+0x2c3>
			270f: R_X86_64_PLT32	rt_list_new-0x4
    2713:	test   rax,rax
    2716:	jne    274d <botlish_fn_22+0x2fd>
    271c:	xor    rax,rax
    271f:	mov    rbx,QWORD PTR [rsp+0x70]
    2724:	mov    r12,QWORD PTR [rsp+0x78]
    2729:	mov    r13,QWORD PTR [rsp+0x80]
    2731:	mov    r14,QWORD PTR [rsp+0x88]
    2739:	mov    r15,QWORD PTR [rsp+0x90]
    2741:	add    rsp,0xa0
    2748:	mov    rsp,rbp
    274b:	pop    rbp
    274c:	ret
    274d:	mov    rbx,QWORD PTR [rsp+0x70]
    2752:	mov    r12,QWORD PTR [rsp+0x78]
    2757:	mov    r13,QWORD PTR [rsp+0x80]
    275f:	mov    r14,QWORD PTR [rsp+0x88]
    2767:	mov    r15,QWORD PTR [rsp+0x90]
    276f:	add    rsp,0xa0
    2776:	mov    rsp,rbp
    2779:	pop    rbp
    277a:	ret
    277b:	add    BYTE PTR [rax],al
    277d:	add    BYTE PTR [rax],al
    277f:	add    BYTE PTR [rsi],al
    2781:	add    BYTE PTR [rax],al
    2783:	add    BYTE PTR [rax],al
    2785:	add    BYTE PTR [rax],al
	...

0000000000002788 <botlish_entry_22: sample_checks<generic>>:
    2788:	push   rbp
    2789:	mov    rbp,rsp
    278c:	call   2791 <botlish_entry_22+0x9>
			278d: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    2791:	mov    rsp,rbp
    2794:	pop    rbp
    2795:	ret

0000000000002796 <botlish_fn_23: sample<generic>>:
    2796:	push   rbp
    2797:	mov    rbp,rsp
    279a:	sub    rsp,0x10
    279e:	mov    QWORD PTR [rsp],r12
    27a2:	mov    r12,rdi
    27a5:	mov    rdi,r12
    27a8:	call   27ad <botlish_fn_23+0x17>
			27a9: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27ad:	test   rax,rax
    27b0:	jne    27f9 <botlish_fn_23+0x63>
    27b6:	mov    rdi,r12
    27b9:	call   27be <botlish_fn_23+0x28>
			27ba: R_X86_64_PLT32	rt_declared_error-0x4
    27be:	cmp    rax,0x40000001
    27c4:	jne    27e9 <botlish_fn_23+0x53>
    27ca:	mov    rdi,r12
    27cd:	call   27d2 <botlish_fn_23+0x3c>
			27ce: R_X86_64_PLT32	rt_clear_declared_error-0x4
    27d2:	xor    rdx,rdx
    27d5:	mov    rdi,r12
    27d8:	mov    rsi,rdx
    27db:	call   27e0 <botlish_fn_23+0x4a>
			27dc: R_X86_64_PLT32	rt_list_new-0x4
    27e0:	test   rax,rax
    27e3:	jne    27f9 <botlish_fn_23+0x63>
    27e9:	xor    rax,rax
    27ec:	mov    r12,QWORD PTR [rsp]
    27f0:	add    rsp,0x10
    27f4:	mov    rsp,rbp
    27f7:	pop    rbp
    27f8:	ret
    27f9:	mov    r12,QWORD PTR [rsp]
    27fd:	add    rsp,0x10
    2801:	mov    rsp,rbp
    2804:	pop    rbp
    2805:	ret

0000000000002806 <botlish_entry_23: sample<generic>>:
    2806:	push   rbp
    2807:	mov    rbp,rsp
    280a:	call   280f <botlish_entry_23+0x9>
			280b: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    280f:	mov    rsp,rbp
    2812:	pop    rbp
    2813:	ret

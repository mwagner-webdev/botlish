; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10883  (per function: 45 427 385 70 69 69 46 170 236 636 1064 333 253 380 402 616 654 801 673 920 684 941 862 147)
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
     7d9:	mov    r14,rdi
     7dc:	mov    QWORD PTR [rsp],rsi
     7e0:	mov    QWORD PTR [rsp+0x8],rdx
     7e5:	mov    r12,rdx
     7e8:	mov    QWORD PTR [rsp+0x10],rcx
     7ed:	mov    QWORD PTR [rsp+0x18],r8
     7f2:	mov    rbx,rsi
     7f5:	mov    r15,rcx
     7f8:	mov    QWORD PTR [rsp+0x20],r8
     7fd:	mov    r9,QWORD PTR [rbx+0x18]
     801:	mov    rsi,QWORD PTR [r9]
     804:	mov    rdx,r15
     807:	mov    rdi,r14
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
     835:	mov    rdi,r14
     838:	call   83d <botlish_fn_10+0x85>
			839: R_X86_64_PLT32	rt_int_cmp-0x4
     83d:	mov    ecx,0x2
     842:	test   rax,rax
     845:	cmove  rcx,QWORD PTR [rip+0x333]        # b80 <botlish_fn_10+0x3c8>
     84d:	jmp    866 <botlish_fn_10+0xae>
     852:	mov    ecx,0x2
     857:	mov    rax,r13
     85a:	cmp    rax,0x1
     85e:	cmove  rcx,QWORD PTR [rip+0x31a]        # b80 <botlish_fn_10+0x3c8>
     866:	cmp    rcx,0x6
     86a:	je     ad5 <botlish_fn_10+0x31d>
     870:	mov    rax,r13
     873:	test   rax,0x1
     879:	jne    8a4 <botlish_fn_10+0xec>
     87f:	mov    edx,0x3
     884:	mov    rsi,r13
     887:	mov    rdi,r14
     88a:	call   88f <botlish_fn_10+0xd7>
			88b: R_X86_64_PLT32	rt_int_cmp-0x4
     88f:	mov    ecx,0x2
     894:	test   rax,rax
     897:	cmove  rcx,QWORD PTR [rip+0x2e1]        # b80 <botlish_fn_10+0x3c8>
     89f:	jmp    8b8 <botlish_fn_10+0x100>
     8a4:	mov    ecx,0x2
     8a9:	mov    rax,r13
     8ac:	cmp    rax,0x3
     8b0:	cmove  rcx,QWORD PTR [rip+0x2c8]        # b80 <botlish_fn_10+0x3c8>
     8b8:	cmp    rcx,0x6
     8bc:	je     8cc <botlish_fn_10+0x114>
     8c2:	mov    eax,0x2
     8c7:	jmp    940 <botlish_fn_10+0x188>
     8cc:	mov    rax,QWORD PTR [rbx+0x18]
     8d0:	mov    rsi,QWORD PTR [rax+0x8]
     8d4:	mov    rdx,r15
     8d7:	mov    rdi,r14
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
     901:	mov    rdi,r14
     904:	call   909 <botlish_fn_10+0x151>
			905: R_X86_64_PLT32	rt_value_eq-0x4
     909:	test   rax,rax
     90c:	je     a68 <botlish_fn_10+0x2b0>
     912:	jmp    927 <botlish_fn_10+0x16f>
     917:	mov    eax,0x2
     91c:	cmp    rsi,r12
     91f:	cmove  rax,QWORD PTR [rip+0x259]        # b80 <botlish_fn_10+0x3c8>
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
     961:	mov    rdi,r14
     964:	call   969 <botlish_fn_10+0x1b1>
			965: R_X86_64_PLT32	rt_int_cmp-0x4
     969:	mov    ecx,0x2
     96e:	test   rax,rax
     971:	cmove  rcx,QWORD PTR [rip+0x207]        # b80 <botlish_fn_10+0x3c8>
     979:	jmp    992 <botlish_fn_10+0x1da>
     97e:	mov    rsi,r13
     981:	mov    ecx,0x2
     986:	cmp    rsi,0x5
     98a:	cmove  rcx,QWORD PTR [rip+0x1ee]        # b80 <botlish_fn_10+0x3c8>
     992:	cmp    rcx,0x6
     996:	je     9a6 <botlish_fn_10+0x1ee>
     99c:	mov    eax,0x2
     9a1:	jmp    a10 <botlish_fn_10+0x258>
     9a6:	mov    r13,QWORD PTR [rsp+0x20]
     9ab:	test   r13,0x1
     9b2:	jne    9e2 <botlish_fn_10+0x22a>
     9b8:	mov    edx,0x1
     9bd:	mov    rsi,r13
     9c0:	mov    rdi,r14
     9c3:	call   9c8 <botlish_fn_10+0x210>
			9c4: R_X86_64_PLT32	rt_int_cmp-0x4
     9c8:	mov    ecx,0x2
     9cd:	test   rax,rax
     9d0:	cmovl  rcx,QWORD PTR [rip+0x1a8]        # b80 <botlish_fn_10+0x3c8>
     9d8:	mov    QWORD PTR [rsp+0x20],r13
     9dd:	jmp    9f7 <botlish_fn_10+0x23f>
     9e2:	mov    ecx,0x2
     9e7:	test   r13,r13
     9ea:	mov    QWORD PTR [rsp+0x20],r13
     9ef:	cmovle rcx,QWORD PTR [rip+0x189]        # b80 <botlish_fn_10+0x3c8>
     9f7:	cmp    rcx,0x6
     9fb:	je     a0b <botlish_fn_10+0x253>
     a01:	mov    eax,0x2
     a06:	jmp    a10 <botlish_fn_10+0x258>
     a0b:	mov    eax,0x6
     a10:	cmp    rax,0x6
     a14:	je     a51 <botlish_fn_10+0x299>
     a1a:	mov    rdx,r15
     a1d:	mov    rsi,rbx
     a20:	mov    rdi,r14
     a23:	call   a28 <botlish_fn_10+0x270>
			a24: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a28:	test   rax,rax
     a2b:	je     a68 <botlish_fn_10+0x2b0>
     a31:	mov    QWORD PTR [rsp],rbx
     a35:	mov    QWORD PTR [rsp+0x8],r12
     a3a:	mov    QWORD PTR [rsp+0x10],rax
     a3f:	mov    rcx,QWORD PTR [rsp+0x20]
     a44:	mov    QWORD PTR [rsp+0x18],rcx
     a49:	mov    r15,rax
     a4c:	jmp    7fd <botlish_fn_10+0x45>
     a51:	mov    rdx,r15
     a54:	mov    rsi,rbx
     a57:	mov    rdi,r14
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
     a9b:	mov    rdx,r15
     a9e:	mov    QWORD PTR [rsp+0x18],rdx
     aa3:	mov    QWORD PTR [rsp+0x20],r15
     aa8:	mov    r15,rax
     aab:	jmp    7fd <botlish_fn_10+0x45>
     ab0:	mov    rax,r15
     ab3:	mov    rbx,QWORD PTR [rsp+0x30]
     ab8:	mov    r12,QWORD PTR [rsp+0x38]
     abd:	mov    r13,QWORD PTR [rsp+0x40]
     ac2:	mov    r14,QWORD PTR [rsp+0x48]
     ac7:	mov    r15,QWORD PTR [rsp+0x50]
     acc:	add    rsp,0x60
     ad0:	mov    rsp,rbp
     ad3:	pop    rbp
     ad4:	ret
     ad5:	mov    rax,QWORD PTR [rsp+0x20]
     ada:	test   rax,0x1
     ae0:	jne    b0d <botlish_fn_10+0x355>
     ae6:	mov    edx,0x1
     aeb:	mov    rdi,r14
     aee:	mov    rsi,QWORD PTR [rsp+0x20]
     af3:	call   af8 <botlish_fn_10+0x340>
			af4: R_X86_64_PLT32	rt_int_cmp-0x4
     af8:	mov    ecx,0x2
     afd:	test   rax,rax
     b00:	cmovge rcx,QWORD PTR [rip+0x78]        # b80 <botlish_fn_10+0x3c8>
     b08:	jmp    b27 <botlish_fn_10+0x36f>
     b0d:	mov    ecx,0x2
     b12:	mov    rax,QWORD PTR [rsp+0x20]
     b17:	mov    rdx,QWORD PTR [rsp+0x20]
     b1c:	test   rax,rdx
     b1f:	cmovg  rcx,QWORD PTR [rip+0x59]        # b80 <botlish_fn_10+0x3c8>
     b27:	cmp    rcx,0x6
     b2b:	je     b56 <botlish_fn_10+0x39e>
     b31:	mov    rax,r15
     b34:	mov    rbx,QWORD PTR [rsp+0x30]
     b39:	mov    r12,QWORD PTR [rsp+0x38]
     b3e:	mov    r13,QWORD PTR [rsp+0x40]
     b43:	mov    r14,QWORD PTR [rsp+0x48]
     b48:	mov    r15,QWORD PTR [rsp+0x50]
     b4d:	add    rsp,0x60
     b51:	mov    rsp,rbp
     b54:	pop    rbp
     b55:	ret
     b56:	mov    rax,QWORD PTR [rsp+0x20]
     b5b:	mov    rbx,QWORD PTR [rsp+0x30]
     b60:	mov    r12,QWORD PTR [rsp+0x38]
     b65:	mov    r13,QWORD PTR [rsp+0x40]
     b6a:	mov    r14,QWORD PTR [rsp+0x48]
     b6f:	mov    r15,QWORD PTR [rsp+0x50]
     b74:	add    rsp,0x60
     b78:	mov    rsp,rbp
     b7b:	pop    rbp
     b7c:	ret
     b7d:	add    BYTE PTR [rax],al
     b7f:	add    BYTE PTR [rsi],al
     b81:	add    BYTE PTR [rax],al
     b83:	add    BYTE PTR [rax],al
     b85:	add    BYTE PTR [rax],al
	...

0000000000000b88 <botlish_entry_10: ht_find_insert<HashTable, str, int, int>>:
     b88:	push   rbp
     b89:	mov    rbp,rsp
     b8c:	mov    rsi,QWORD PTR [rdx]
     b8f:	mov    r9,QWORD PTR [rdx+0x8]
     b93:	mov    rcx,QWORD PTR [rdx+0x10]
     b97:	mov    r8,QWORD PTR [rdx+0x18]
     b9b:	mov    rdx,r9
     b9e:	call   ba3 <botlish_entry_10+0x1b>
			b9f: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
     ba3:	mov    rsp,rbp
     ba6:	pop    rbp
     ba7:	ret

0000000000000ba8 <botlish_fn_11: ht_get<HashTable, str>>:
     ba8:	push   rbp
     ba9:	mov    rbp,rsp
     bac:	sub    rsp,0x40
     bb0:	mov    QWORD PTR [rsp+0x20],rbx
     bb5:	mov    QWORD PTR [rsp+0x28],r12
     bba:	mov    QWORD PTR [rsp+0x30],r13
     bbf:	mov    r12,rdi
     bc2:	mov    QWORD PTR [rsp],rsi
     bc6:	mov    QWORD PTR [rsp+0x8],rdx
     bcb:	mov    r13,rdx
     bce:	mov    rbx,rsi
     bd1:	mov    rdx,r13
     bd4:	mov    rdi,r12
     bd7:	call   bdc <botlish_fn_11+0x34>
			bd8: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     bdc:	test   rax,rax
     bdf:	je     c77 <botlish_fn_11+0xcf>
     be5:	mov    QWORD PTR [rsp+0x10],rax
     bea:	mov    rcx,rax
     bed:	mov    rdx,r13
     bf0:	mov    rsi,rbx
     bf3:	mov    rdi,r12
     bf6:	call   bfb <botlish_fn_11+0x53>
			bf7: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     bfb:	mov    rcx,rax
     bfe:	mov    r13,rax
     c01:	test   rax,rcx
     c04:	je     c77 <botlish_fn_11+0xcf>
     c0a:	mov    rax,r13
     c0d:	test   rax,0x1
     c13:	jne    c3e <botlish_fn_11+0x96>
     c19:	mov    edx,0x1
     c1e:	mov    rsi,r13
     c21:	mov    rdi,r12
     c24:	call   c29 <botlish_fn_11+0x81>
			c25: R_X86_64_PLT32	rt_int_cmp-0x4
     c29:	mov    ecx,0x2
     c2e:	test   rax,rax
     c31:	cmovl  rcx,QWORD PTR [rip+0x8f]        # cc8 <botlish_fn_11+0x120>
     c39:	jmp    c51 <botlish_fn_11+0xa9>
     c3e:	mov    ecx,0x2
     c43:	mov    rax,r13
     c46:	test   rax,rax
     c49:	cmovle rcx,QWORD PTR [rip+0x77]        # cc8 <botlish_fn_11+0x120>
     c51:	cmp    rcx,0x6
     c55:	je     caa <botlish_fn_11+0x102>
     c5b:	mov    rax,QWORD PTR [rbx+0x18]
     c5f:	mov    rsi,QWORD PTR [rax+0x10]
     c63:	mov    rdx,r13
     c66:	mov    rdi,r12
     c69:	call   c6e <botlish_fn_11+0xc6>
			c6a: R_X86_64_PLT32	rt_mutarray_get-0x4
     c6e:	test   rax,rax
     c71:	jne    c92 <botlish_fn_11+0xea>
     c77:	xor    rax,rax
     c7a:	mov    rbx,QWORD PTR [rsp+0x20]
     c7f:	mov    r12,QWORD PTR [rsp+0x28]
     c84:	mov    r13,QWORD PTR [rsp+0x30]
     c89:	add    rsp,0x40
     c8d:	mov    rsp,rbp
     c90:	pop    rbp
     c91:	ret
     c92:	mov    rbx,QWORD PTR [rsp+0x20]
     c97:	mov    r12,QWORD PTR [rsp+0x28]
     c9c:	mov    r13,QWORD PTR [rsp+0x30]
     ca1:	add    rsp,0x40
     ca5:	mov    rsp,rbp
     ca8:	pop    rbp
     ca9:	ret
     caa:	mov    eax,0xa
     caf:	mov    rbx,QWORD PTR [rsp+0x20]
     cb4:	mov    r12,QWORD PTR [rsp+0x28]
     cb9:	mov    r13,QWORD PTR [rsp+0x30]
     cbe:	add    rsp,0x40
     cc2:	mov    rsp,rbp
     cc5:	pop    rbp
     cc6:	ret
     cc7:	add    BYTE PTR [rsi],al
     cc9:	add    BYTE PTR [rax],al
     ccb:	add    BYTE PTR [rax],al
     ccd:	add    BYTE PTR [rax],al
	...

0000000000000cd0 <botlish_entry_11: ht_get<HashTable, str>>:
     cd0:	push   rbp
     cd1:	mov    rbp,rsp
     cd4:	mov    rsi,QWORD PTR [rdx]
     cd7:	mov    rdx,QWORD PTR [rdx+0x8]
     cdb:	call   ce0 <botlish_entry_11+0x10>
			cdc: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
     ce0:	mov    rsp,rbp
     ce3:	pop    rbp
     ce4:	ret
     ce5:	add    BYTE PTR [rax],al
	...

0000000000000ce8 <botlish_fn_12: ht_contains<HashTable, str>>:
     ce8:	push   rbp
     ce9:	mov    rbp,rsp
     cec:	sub    rsp,0x40
     cf0:	mov    QWORD PTR [rsp+0x20],rbx
     cf5:	mov    QWORD PTR [rsp+0x28],r12
     cfa:	mov    QWORD PTR [rsp+0x30],r15
     cff:	mov    r15,rdi
     d02:	mov    QWORD PTR [rsp],rsi
     d06:	mov    r12,rsi
     d09:	mov    QWORD PTR [rsp+0x8],rdx
     d0e:	mov    rbx,rdx
     d11:	mov    rdx,rbx
     d14:	mov    rsi,r12
     d17:	mov    rdi,r15
     d1a:	call   d1f <botlish_fn_12+0x37>
			d1b: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     d1f:	test   rax,rax
     d22:	je     d47 <botlish_fn_12+0x5f>
     d28:	mov    QWORD PTR [rsp+0x10],rax
     d2d:	mov    rcx,rax
     d30:	mov    rdx,rbx
     d33:	mov    rsi,r12
     d36:	mov    rdi,r15
     d39:	call   d3e <botlish_fn_12+0x56>
			d3a: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     d3e:	test   rax,rax
     d41:	jne    d62 <botlish_fn_12+0x7a>
     d47:	xor    rax,rax
     d4a:	mov    rbx,QWORD PTR [rsp+0x20]
     d4f:	mov    r12,QWORD PTR [rsp+0x28]
     d54:	mov    r15,QWORD PTR [rsp+0x30]
     d59:	add    rsp,0x40
     d5d:	mov    rsp,rbp
     d60:	pop    rbp
     d61:	ret
     d62:	test   rax,0x1
     d68:	mov    rsi,rax
     d6b:	jne    d96 <botlish_fn_12+0xae>
     d71:	mov    edx,0x1
     d76:	mov    rdi,r15
     d79:	call   d7e <botlish_fn_12+0x96>
			d7a: R_X86_64_PLT32	rt_int_cmp-0x4
     d7e:	mov    ecx,0x2
     d83:	test   rax,rax
     d86:	mov    rax,rcx
     d89:	cmovge rax,QWORD PTR [rip+0x2f]        # dc0 <botlish_fn_12+0xd8>
     d91:	jmp    da6 <botlish_fn_12+0xbe>
     d96:	mov    eax,0x2
     d9b:	test   rsi,rsi
     d9e:	cmovg  rax,QWORD PTR [rip+0x1a]        # dc0 <botlish_fn_12+0xd8>
     da6:	mov    rbx,QWORD PTR [rsp+0x20]
     dab:	mov    r12,QWORD PTR [rsp+0x28]
     db0:	mov    r15,QWORD PTR [rsp+0x30]
     db5:	add    rsp,0x40
     db9:	mov    rsp,rbp
     dbc:	pop    rbp
     dbd:	ret
     dbe:	add    BYTE PTR [rax],al
     dc0:	(bad)
     dc1:	add    BYTE PTR [rax],al
     dc3:	add    BYTE PTR [rax],al
     dc5:	add    BYTE PTR [rax],al
	...

0000000000000dc8 <botlish_entry_12: ht_contains<HashTable, str>>:
     dc8:	push   rbp
     dc9:	mov    rbp,rsp
     dcc:	mov    rsi,QWORD PTR [rdx]
     dcf:	mov    rdx,QWORD PTR [rdx+0x8]
     dd3:	call   dd8 <botlish_entry_12+0x10>
			dd4: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
     dd8:	mov    rsp,rbp
     ddb:	pop    rbp
     ddc:	ret
     ddd:	add    BYTE PTR [rax],al
	...

0000000000000de0 <botlish_fn_13: ht_rehash_probe<mutarray, int, int>>:
     de0:	push   rbp
     de1:	mov    rbp,rsp
     de4:	sub    rsp,0x40
     de8:	mov    QWORD PTR [rsp+0x20],rbx
     ded:	mov    QWORD PTR [rsp+0x28],r12
     df2:	mov    QWORD PTR [rsp+0x30],r13
     df7:	mov    QWORD PTR [rsp+0x38],r14
     dfc:	mov    r13,rdi
     dff:	mov    QWORD PTR [rsp],rsi
     e03:	mov    QWORD PTR [rsp+0x8],rdx
     e08:	mov    QWORD PTR [rsp+0x10],rcx
     e0d:	mov    r12,rcx
     e10:	mov    rbx,rsi
     e13:	mov    r14,rdx
     e16:	mov    rdx,r14
     e19:	mov    rsi,rbx
     e1c:	mov    rdi,r13
     e1f:	call   e24 <botlish_fn_13+0x44>
			e20: R_X86_64_PLT32	rt_mutarray_get-0x4
     e24:	test   rax,rax
     e27:	je     ec4 <botlish_fn_13+0xe4>
     e2d:	test   rax,0x1
     e33:	mov    rsi,rax
     e36:	jne    e57 <botlish_fn_13+0x77>
     e3c:	mov    edx,0x1
     e41:	mov    rdi,r13
     e44:	call   e49 <botlish_fn_13+0x69>
			e45: R_X86_64_PLT32	rt_value_eq-0x4
     e49:	test   rax,rax
     e4c:	je     ec4 <botlish_fn_13+0xe4>
     e52:	jmp    e68 <botlish_fn_13+0x88>
     e57:	mov    eax,0x2
     e5c:	cmp    rsi,0x1
     e60:	cmove  rax,QWORD PTR [rip+0xb8]        # f20 <botlish_fn_13+0x140>
     e68:	cmp    rax,0x6
     e6c:	je     efa <botlish_fn_13+0x11a>
     e72:	mov    QWORD PTR [rsp+0x18],0x3
     e7b:	mov    rsi,r14
     e7e:	test   rsi,0x1
     e85:	je     e9d <botlish_fn_13+0xbd>
     e8b:	mov    rsi,r14
     e8e:	add    rsi,0x2
     e92:	seto   al
     e95:	test   al,al
     e97:	je     eb0 <botlish_fn_13+0xd0>
     e9d:	mov    edx,0x3
     ea2:	mov    rsi,r14
     ea5:	mov    rdi,r13
     ea8:	call   ead <botlish_fn_13+0xcd>
			ea9: R_X86_64_PLT32	rt_int_add-0x4
     ead:	mov    rsi,rax
     eb0:	mov    rdx,r12
     eb3:	mov    rdi,r13
     eb6:	call   ebb <botlish_fn_13+0xdb>
			eb7: R_X86_64_PLT32	rt_int_mod-0x4
     ebb:	test   rax,rax
     ebe:	jne    ee4 <botlish_fn_13+0x104>
     ec4:	xor    rax,rax
     ec7:	mov    rbx,QWORD PTR [rsp+0x20]
     ecc:	mov    r12,QWORD PTR [rsp+0x28]
     ed1:	mov    r13,QWORD PTR [rsp+0x30]
     ed6:	mov    r14,QWORD PTR [rsp+0x38]
     edb:	add    rsp,0x40
     edf:	mov    rsp,rbp
     ee2:	pop    rbp
     ee3:	ret
     ee4:	mov    QWORD PTR [rsp],rbx
     ee8:	mov    QWORD PTR [rsp+0x8],rax
     eed:	mov    QWORD PTR [rsp+0x10],r12
     ef2:	mov    r14,rax
     ef5:	jmp    e16 <botlish_fn_13+0x36>
     efa:	mov    rax,r14
     efd:	mov    rbx,QWORD PTR [rsp+0x20]
     f02:	mov    r12,QWORD PTR [rsp+0x28]
     f07:	mov    r13,QWORD PTR [rsp+0x30]
     f0c:	mov    r14,QWORD PTR [rsp+0x38]
     f11:	add    rsp,0x40
     f15:	mov    rsp,rbp
     f18:	pop    rbp
     f19:	ret
     f1a:	add    BYTE PTR [rax],al
     f1c:	add    BYTE PTR [rax],al
     f1e:	add    BYTE PTR [rax],al
     f20:	(bad)
     f21:	add    BYTE PTR [rax],al
     f23:	add    BYTE PTR [rax],al
     f25:	add    BYTE PTR [rax],al
	...

0000000000000f28 <botlish_entry_13: ht_rehash_probe<mutarray, int, int>>:
     f28:	push   rbp
     f29:	mov    rbp,rsp
     f2c:	mov    rsi,QWORD PTR [rdx]
     f2f:	mov    r8,QWORD PTR [rdx+0x8]
     f33:	mov    rcx,QWORD PTR [rdx+0x10]
     f37:	mov    rdx,r8
     f3a:	call   f3f <botlish_entry_13+0x17>
			f3b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     f3f:	mov    rsp,rbp
     f42:	pop    rbp
     f43:	ret

0000000000000f44 <botlish_fn_14: ht_rehash_insert<HashTable, int, any, any>>:
     f44:	push   rbp
     f45:	mov    rbp,rsp
     f48:	sub    rsp,0x70
     f4c:	mov    QWORD PTR [rsp+0x40],rbx
     f51:	mov    QWORD PTR [rsp+0x48],r12
     f56:	mov    QWORD PTR [rsp+0x50],r13
     f5b:	mov    QWORD PTR [rsp+0x58],r14
     f60:	mov    QWORD PTR [rsp+0x60],r15
     f65:	mov    r13,rdi
     f68:	mov    QWORD PTR [rsp],rsi
     f6c:	mov    QWORD PTR [rsp+0x8],rdx
     f71:	mov    r15,rdx
     f74:	mov    QWORD PTR [rsp+0x10],rcx
     f79:	mov    r14,rcx
     f7c:	mov    QWORD PTR [rsp+0x18],r8
     f81:	mov    r12,r8
     f84:	mov    rax,QWORD PTR [rsi+0x18]
     f88:	mov    rbx,rsi
     f8b:	mov    rsi,QWORD PTR [rax]
     f8e:	mov    QWORD PTR [rsp+0x20],rsi
     f93:	mov    QWORD PTR [rsp+0x30],rsi
     f98:	mov    rsi,r14
     f9b:	mov    rdi,r13
     f9e:	call   fa3 <botlish_fn_14+0x5f>
			f9f: R_X86_64_PLT32	rt_hash-0x4
     fa3:	test   rax,rax
     fa6:	mov    rsi,rax
     fa9:	je     1048 <botlish_fn_14+0x104>
     faf:	mov    rdx,r15
     fb2:	mov    rdi,r13
     fb5:	call   fba <botlish_fn_14+0x76>
			fb6: R_X86_64_PLT32	rt_int_mod-0x4
     fba:	test   rax,rax
     fbd:	je     1048 <botlish_fn_14+0x104>
     fc3:	mov    QWORD PTR [rsp+0x28],rax
     fc8:	mov    rcx,r15
     fcb:	mov    rdx,rax
     fce:	mov    rsi,QWORD PTR [rsp+0x30]
     fd3:	mov    rdi,r13
     fd6:	call   fdb <botlish_fn_14+0x97>
			fd7: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     fdb:	mov    rdx,rax
     fde:	mov    r15,rax
     fe1:	test   rax,rdx
     fe4:	je     1048 <botlish_fn_14+0x104>
     fea:	mov    rcx,QWORD PTR [rbx+0x18]
     fee:	mov    rsi,QWORD PTR [rcx]
     ff1:	mov    ecx,0x3
     ff6:	mov    rdx,r15
     ff9:	mov    rdi,r13
     ffc:	call   1001 <botlish_fn_14+0xbd>
			ffd: R_X86_64_PLT32	rt_mutarray_set-0x4
    1001:	test   rax,rax
    1004:	je     1048 <botlish_fn_14+0x104>
    100a:	mov    rax,QWORD PTR [rbx+0x18]
    100e:	mov    rsi,QWORD PTR [rax+0x8]
    1012:	mov    rcx,r14
    1015:	mov    rdx,r15
    1018:	mov    rdi,r13
    101b:	call   1020 <botlish_fn_14+0xdc>
			101c: R_X86_64_PLT32	rt_mutarray_set-0x4
    1020:	test   rax,rax
    1023:	je     1048 <botlish_fn_14+0x104>
    1029:	mov    rax,QWORD PTR [rbx+0x18]
    102d:	mov    rsi,QWORD PTR [rax+0x10]
    1031:	mov    rcx,r12
    1034:	mov    rdx,r15
    1037:	mov    rdi,r13
    103a:	call   103f <botlish_fn_14+0xfb>
			103b: R_X86_64_PLT32	rt_mutarray_set-0x4
    103f:	test   rax,rax
    1042:	jne    106d <botlish_fn_14+0x129>
    1048:	xor    rax,rax
    104b:	mov    rbx,QWORD PTR [rsp+0x40]
    1050:	mov    r12,QWORD PTR [rsp+0x48]
    1055:	mov    r13,QWORD PTR [rsp+0x50]
    105a:	mov    r14,QWORD PTR [rsp+0x58]
    105f:	mov    r15,QWORD PTR [rsp+0x60]
    1064:	add    rsp,0x70
    1068:	mov    rsp,rbp
    106b:	pop    rbp
    106c:	ret
    106d:	mov    rax,rbx
    1070:	mov    rbx,QWORD PTR [rsp+0x40]
    1075:	mov    r12,QWORD PTR [rsp+0x48]
    107a:	mov    r13,QWORD PTR [rsp+0x50]
    107f:	mov    r14,QWORD PTR [rsp+0x58]
    1084:	mov    r15,QWORD PTR [rsp+0x60]
    1089:	add    rsp,0x70
    108d:	mov    rsp,rbp
    1090:	pop    rbp
    1091:	ret

0000000000001092 <botlish_entry_14: ht_rehash_insert<HashTable, int, any, any>>:
    1092:	push   rbp
    1093:	mov    rbp,rsp
    1096:	mov    rsi,QWORD PTR [rdx]
    1099:	mov    r9,QWORD PTR [rdx+0x8]
    109d:	mov    rcx,QWORD PTR [rdx+0x10]
    10a1:	mov    r8,QWORD PTR [rdx+0x18]
    10a5:	mov    rdx,r9
    10a8:	call   10ad <botlish_entry_14+0x1b>
			10a9: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    10ad:	mov    rsp,rbp
    10b0:	pop    rbp
    10b1:	ret
    10b2:	add    BYTE PTR [rax],al
    10b4:	add    BYTE PTR [rax],al
	...

00000000000010b8 <botlish_fn_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    10b8:	push   rbp
    10b9:	mov    rbp,rsp
    10bc:	sub    rsp,0x90
    10c3:	mov    QWORD PTR [rsp+0x60],rbx
    10c8:	mov    QWORD PTR [rsp+0x68],r12
    10cd:	mov    QWORD PTR [rsp+0x70],r13
    10d2:	mov    QWORD PTR [rsp+0x78],r14
    10d7:	mov    QWORD PTR [rsp+0x80],r15
    10df:	mov    QWORD PTR [rsp+0x38],rdi
    10e4:	mov    QWORD PTR [rsp+0x40],r9
    10e9:	mov    rdi,QWORD PTR [rbp+0x10]
    10ed:	mov    rbx,QWORD PTR [rbp+0x18]
    10f1:	mov    QWORD PTR [rsp],rsi
    10f5:	mov    QWORD PTR [rsp+0x8],rdx
    10fa:	mov    r14,rdx
    10fd:	mov    QWORD PTR [rsp+0x10],rcx
    1102:	mov    r15,rcx
    1105:	mov    QWORD PTR [rsp+0x18],rdi
    110a:	mov    QWORD PTR [rsp+0x20],rbx
    110f:	sar    r8,1
    1112:	mov    rcx,QWORD PTR [rsp+0x40]
    1117:	mov    r12,r8
    111a:	mov    QWORD PTR [rsp+0x48],rdi
    111f:	cmp    r12,rcx
    1122:	mov    QWORD PTR [rsp+0x40],rcx
    1127:	jge    128e <botlish_fn_15+0x1d6>
    112d:	mov    rdx,r12
    1130:	shl    rdx,1
    1133:	or     rdx,0x1
    1137:	mov    r13,rsi
    113a:	mov    QWORD PTR [rsp+0x58],rdx
    113f:	mov    rdi,QWORD PTR [rsp+0x38]
    1144:	call   1149 <botlish_fn_15+0x91>
			1145: R_X86_64_PLT32	rt_mutarray_get-0x4
    1149:	test   rax,rax
    114c:	je     1232 <botlish_fn_15+0x17a>
    1152:	test   rax,0x1
    1158:	mov    rsi,rax
    115b:	jne    117e <botlish_fn_15+0xc6>
    1161:	mov    edx,0x3
    1166:	mov    rdi,QWORD PTR [rsp+0x38]
    116b:	call   1170 <botlish_fn_15+0xb8>
			116c: R_X86_64_PLT32	rt_value_eq-0x4
    1170:	test   rax,rax
    1173:	je     1232 <botlish_fn_15+0x17a>
    1179:	jmp    118f <botlish_fn_15+0xd7>
    117e:	mov    eax,0x2
    1183:	cmp    rsi,0x3
    1187:	cmove  rax,QWORD PTR [rip+0x131]        # 12c0 <botlish_fn_15+0x208>
    118f:	cmp    rax,0x6
    1193:	je     11ca <botlish_fn_15+0x112>
    1199:	mov    QWORD PTR [rsp],r13
    119d:	mov    QWORD PTR [rsp+0x8],r14
    11a2:	mov    QWORD PTR [rsp+0x10],r15
    11a7:	mov    rsi,QWORD PTR [rsp+0x48]
    11ac:	mov    QWORD PTR [rsp+0x18],rsi
    11b1:	mov    QWORD PTR [rsp+0x20],rbx
    11b6:	add    r12,0x1
    11bd:	mov    rcx,QWORD PTR [rsp+0x40]
    11c2:	mov    rsi,r13
    11c5:	jmp    111f <botlish_fn_15+0x67>
    11ca:	mov    rdx,QWORD PTR [rsp+0x58]
    11cf:	mov    rsi,r14
    11d2:	mov    rdi,QWORD PTR [rsp+0x38]
    11d7:	call   11dc <botlish_fn_15+0x124>
			11d8: R_X86_64_PLT32	rt_mutarray_get-0x4
    11dc:	test   rax,rax
    11df:	je     1232 <botlish_fn_15+0x17a>
    11e5:	mov    QWORD PTR [rsp+0x28],rax
    11ea:	mov    rdx,QWORD PTR [rsp+0x58]
    11ef:	mov    QWORD PTR [rsp+0x50],rax
    11f4:	mov    rsi,r15
    11f7:	mov    rdi,QWORD PTR [rsp+0x38]
    11fc:	call   1201 <botlish_fn_15+0x149>
			11fd: R_X86_64_PLT32	rt_mutarray_get-0x4
    1201:	test   rax,rax
    1204:	je     1232 <botlish_fn_15+0x17a>
    120a:	mov    QWORD PTR [rsp+0x30],rax
    120f:	mov    rcx,QWORD PTR [rsp+0x50]
    1214:	mov    rsi,QWORD PTR [rsp+0x48]
    1219:	mov    r8,rax
    121c:	mov    rdx,rbx
    121f:	mov    rdi,QWORD PTR [rsp+0x38]
    1224:	call   1229 <botlish_fn_15+0x171>
			1225: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    1229:	test   rax,rax
    122c:	jne    125d <botlish_fn_15+0x1a5>
    1232:	xor    rax,rax
    1235:	mov    rbx,QWORD PTR [rsp+0x60]
    123a:	mov    r12,QWORD PTR [rsp+0x68]
    123f:	mov    r13,QWORD PTR [rsp+0x70]
    1244:	mov    r14,QWORD PTR [rsp+0x78]
    1249:	mov    r15,QWORD PTR [rsp+0x80]
    1251:	add    rsp,0x90
    1258:	mov    rsp,rbp
    125b:	pop    rbp
    125c:	ret
    125d:	mov    QWORD PTR [rsp],r13
    1261:	mov    QWORD PTR [rsp+0x8],r14
    1266:	mov    QWORD PTR [rsp+0x10],r15
    126b:	mov    QWORD PTR [rsp+0x18],rax
    1270:	mov    QWORD PTR [rsp+0x20],rbx
    1275:	add    r12,0x1
    127c:	mov    rcx,QWORD PTR [rsp+0x40]
    1281:	mov    rsi,r13
    1284:	mov    QWORD PTR [rsp+0x48],rax
    1289:	jmp    111f <botlish_fn_15+0x67>
    128e:	mov    rax,QWORD PTR [rsp+0x48]
    1293:	mov    rbx,QWORD PTR [rsp+0x60]
    1298:	mov    r12,QWORD PTR [rsp+0x68]
    129d:	mov    r13,QWORD PTR [rsp+0x70]
    12a2:	mov    r14,QWORD PTR [rsp+0x78]
    12a7:	mov    r15,QWORD PTR [rsp+0x80]
    12af:	add    rsp,0x90
    12b6:	mov    rsp,rbp
    12b9:	pop    rbp
    12ba:	ret
    12bb:	add    BYTE PTR [rax],al
    12bd:	add    BYTE PTR [rax],al
    12bf:	add    BYTE PTR [rsi],al
    12c1:	add    BYTE PTR [rax],al
    12c3:	add    BYTE PTR [rax],al
    12c5:	add    BYTE PTR [rax],al
	...

00000000000012c8 <botlish_entry_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    12c8:	push   rbp
    12c9:	mov    rbp,rsp
    12cc:	sub    rsp,0x10
    12d0:	mov    rsi,QWORD PTR [rdx]
    12d3:	mov    r11,QWORD PTR [rdx+0x8]
    12d7:	mov    rcx,QWORD PTR [rdx+0x10]
    12db:	mov    r8,QWORD PTR [rdx+0x18]
    12df:	mov    r9,QWORD PTR [rdx+0x20]
    12e3:	mov    rax,QWORD PTR [rdx+0x28]
    12e7:	mov    rdx,QWORD PTR [rdx+0x30]
    12eb:	sar    r9,1
    12ee:	mov    QWORD PTR [rsp],rax
    12f2:	mov    QWORD PTR [rsp+0x8],rdx
    12f7:	mov    rdx,r11
    12fa:	call   12ff <botlish_entry_15+0x37>
			12fb: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    12ff:	add    rsp,0x10
    1303:	mov    rsp,rbp
    1306:	pop    rbp
    1307:	ret

0000000000001308 <botlish_fn_16: ht_rehash<HashTable, int>>:
    1308:	push   rbp
    1309:	mov    rbp,rsp
    130c:	sub    rsp,0xf0
    1313:	mov    QWORD PTR [rsp+0xc0],rbx
    131b:	mov    QWORD PTR [rsp+0xc8],r12
    1323:	mov    QWORD PTR [rsp+0xd0],r13
    132b:	mov    QWORD PTR [rsp+0xd8],r14
    1333:	mov    QWORD PTR [rsp+0xe0],r15
    133b:	mov    QWORD PTR [rsp+0x90],rdi
    1343:	mov    QWORD PTR [rsp+0x20],0x0
    134c:	mov    QWORD PTR [rsp+0x28],0x0
    1355:	mov    QWORD PTR [rsp+0x30],0x0
    135e:	mov    QWORD PTR [rsp+0x38],0x0
    1367:	mov    QWORD PTR [rsp+0x40],0x0
    1370:	mov    QWORD PTR [rsp+0x48],0x0
    1379:	mov    QWORD PTR [rsp+0x50],0x0
    1382:	mov    QWORD PTR [rsp+0x10],rsi
    1387:	mov    r14,rsi
    138a:	mov    QWORD PTR [rsp+0x18],rdx
    138f:	mov    QWORD PTR [rsp+0x98],rdx
    1397:	lea    rdx,[rsp+0x58]
    139c:	mov    rsi,QWORD PTR [rsp+0x98]
    13a4:	mov    rdi,QWORD PTR [rsp+0x90]
    13ac:	call   13b1 <botlish_fn_16+0xa9>
			13ad: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    13b1:	test   rax,rax
    13b4:	je     1508 <botlish_fn_16+0x200>
    13ba:	mov    QWORD PTR [rsp+0x10],rax
    13bf:	mov    QWORD PTR [rsp+0xb8],rax
    13c7:	mov    rbx,QWORD PTR [rsp+0x58]
    13cc:	mov    QWORD PTR [rsp+0x20],rbx
    13d1:	mov    r12,QWORD PTR [rsp+0x60]
    13d6:	mov    QWORD PTR [rsp+0x28],r12
    13db:	mov    r13,QWORD PTR [rsp+0x68]
    13e0:	mov    QWORD PTR [rsp+0x30],r13
    13e5:	mov    rsi,r14
    13e8:	mov    rdi,QWORD PTR [rsp+0x90]
    13f0:	call   13f5 <botlish_fn_16+0xed>
			13f1: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    13f5:	test   rax,rax
    13f8:	mov    rcx,rax
    13fb:	je     1508 <botlish_fn_16+0x200>
    1401:	mov    edx,0x1
    1406:	mov    rsi,r13
    1409:	mov    rdi,QWORD PTR [rsp+0x90]
    1411:	call   1416 <botlish_fn_16+0x10e>
			1412: R_X86_64_PLT32	rt_mutarray_set-0x4
    1416:	test   rax,rax
    1419:	je     1508 <botlish_fn_16+0x200>
    141f:	mov    rsi,r14
    1422:	mov    rax,QWORD PTR [rsi+0x18]
    1426:	mov    rcx,QWORD PTR [rax]
    1429:	mov    QWORD PTR [rsp+0x38],rcx
    142e:	mov    QWORD PTR [rsp+0xb0],rcx
    1436:	mov    rax,QWORD PTR [rsi+0x18]
    143a:	mov    r15,QWORD PTR [rax+0x8]
    143e:	mov    QWORD PTR [rsp+0x40],r15
    1443:	mov    rax,QWORD PTR [rsi+0x18]
    1447:	mov    r14,QWORD PTR [rax+0x10]
    144b:	mov    QWORD PTR [rsp+0x48],r14
    1450:	mov    r8d,0x1
    1456:	mov    QWORD PTR [rsp+0xa8],r8
    145e:	mov    QWORD PTR [rsp+0x50],0x1
    1467:	mov    rdi,QWORD PTR [rsp+0x90]
    146f:	call   1474 <botlish_fn_16+0x16c>
			1470: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1474:	mov    QWORD PTR [rsp+0xa0],rax
    147c:	lea    rcx,[rsp+0x70]
    1481:	mov    rax,QWORD PTR [rsp+0xb8]
    1489:	mov    QWORD PTR [rsp+0x70],rax
    148e:	mov    QWORD PTR [rsp+0x78],rbx
    1493:	mov    QWORD PTR [rsp+0x80],r12
    149b:	mov    QWORD PTR [rsp+0x88],r13
    14a3:	xor    rsi,rsi
    14a6:	mov    edx,0x4
    14ab:	mov    rdi,QWORD PTR [rsp+0x90]
    14b3:	call   14b8 <botlish_fn_16+0x1b0>
			14b4: R_X86_64_PLT32	rt_struct_new-0x4
    14b8:	mov    QWORD PTR [rsp+0x10],rax
    14bd:	mov    rcx,QWORD PTR [rsp+0xa0]
    14c5:	mov    r9,rcx
    14c8:	sar    r9,1
    14cb:	mov    QWORD PTR [rsp],rax
    14cf:	mov    rdx,QWORD PTR [rsp+0x98]
    14d7:	mov    QWORD PTR [rsp+0x8],rdx
    14dc:	mov    rcx,r14
    14df:	mov    rdx,r15
    14e2:	mov    rsi,QWORD PTR [rsp+0xb0]
    14ea:	mov    rdi,QWORD PTR [rsp+0x90]
    14f2:	mov    r8,QWORD PTR [rsp+0xa8]
    14fa:	call   14ff <botlish_fn_16+0x1f7>
			14fb: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    14ff:	test   rax,rax
    1502:	jne    153f <botlish_fn_16+0x237>
    1508:	xor    rax,rax
    150b:	mov    rbx,QWORD PTR [rsp+0xc0]
    1513:	mov    r12,QWORD PTR [rsp+0xc8]
    151b:	mov    r13,QWORD PTR [rsp+0xd0]
    1523:	mov    r14,QWORD PTR [rsp+0xd8]
    152b:	mov    r15,QWORD PTR [rsp+0xe0]
    1533:	add    rsp,0xf0
    153a:	mov    rsp,rbp
    153d:	pop    rbp
    153e:	ret
    153f:	mov    rbx,QWORD PTR [rsp+0xc0]
    1547:	mov    r12,QWORD PTR [rsp+0xc8]
    154f:	mov    r13,QWORD PTR [rsp+0xd0]
    1557:	mov    r14,QWORD PTR [rsp+0xd8]
    155f:	mov    r15,QWORD PTR [rsp+0xe0]
    1567:	add    rsp,0xf0
    156e:	mov    rsp,rbp
    1571:	pop    rbp
    1572:	ret

0000000000001573 <botlish_entry_16: ht_rehash<HashTable, int>>:
    1573:	push   rbp
    1574:	mov    rbp,rsp
    1577:	mov    rsi,QWORD PTR [rdx]
    157a:	mov    rdx,QWORD PTR [rdx+0x8]
    157e:	call   1583 <botlish_entry_16+0x10>
			157f: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1583:	mov    rsp,rbp
    1586:	pop    rbp
    1587:	ret

0000000000001588 <botlish_fn_17: ht_should_grow<HashTable>>:
    1588:	push   rbp
    1589:	mov    rbp,rsp
    158c:	sub    rsp,0x40
    1590:	mov    QWORD PTR [rsp+0x20],rbx
    1595:	mov    QWORD PTR [rsp+0x28],r12
    159a:	mov    QWORD PTR [rsp+0x30],r13
    159f:	mov    rbx,rdi
    15a2:	mov    QWORD PTR [rsp],rsi
    15a6:	mov    r12,rsi
    15a9:	mov    rsi,r12
    15ac:	mov    rdi,rbx
    15af:	call   15b4 <botlish_fn_17+0x2c>
			15b0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    15b4:	mov    rcx,rax
    15b7:	mov    r13,rax
    15ba:	test   rax,rcx
    15bd:	je     1694 <botlish_fn_17+0x10c>
    15c3:	mov    rax,r13
    15c6:	mov    QWORD PTR [rsp+0x8],rax
    15cb:	mov    rsi,r12
    15ce:	mov    rdi,rbx
    15d1:	call   15d6 <botlish_fn_17+0x4e>
			15d2: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    15d6:	mov    rcx,rax
    15d9:	test   rcx,rcx
    15dc:	je     1694 <botlish_fn_17+0x10c>
    15e2:	mov    QWORD PTR [rsp+0x10],rcx
    15e7:	mov    edx,0x1
    15ec:	mov    rax,r13
    15ef:	test   rax,0x1
    15f5:	jne    1618 <botlish_fn_17+0x90>
    15fb:	xor    edx,edx
    15fd:	mov    rax,r13
    1600:	test   rax,0x7
    1606:	jne    1618 <botlish_fn_17+0x90>
    160c:	mov    rax,r13
    160f:	movzx  rax,BYTE PTR [rax]
    1613:	cmp    al,0x1
    1615:	sete   dl
    1618:	test   dl,dl
    161a:	jne    163a <botlish_fn_17+0xb2>
    1620:	mov    rdi,rbx
    1623:	mov    rax,QWORD PTR [rdi+0x10]
    1627:	mov    rcx,QWORD PTR [rax]
    162a:	xor    rdx,rdx
    162d:	mov    rsi,r13
    1630:	call   1635 <botlish_fn_17+0xad>
			1631: R_X86_64_PLT32	rt_type_error-0x4
    1635:	jmp    1694 <botlish_fn_17+0x10c>
    163a:	mov    eax,0x1
    163f:	test   rcx,0x1
    1646:	je     1654 <botlish_fn_17+0xcc>
    164c:	mov    r8,rcx
    164f:	jmp    1677 <botlish_fn_17+0xef>
    1654:	xor    eax,eax
    1656:	test   rcx,0x7
    165d:	je     166b <botlish_fn_17+0xe3>
    1663:	mov    r8,rcx
    1666:	jmp    1677 <botlish_fn_17+0xef>
    166b:	movzx  rax,BYTE PTR [rcx]
    166f:	mov    r8,rcx
    1672:	cmp    al,0x1
    1674:	sete   al
    1677:	test   al,al
    1679:	jne    16af <botlish_fn_17+0x127>
    167f:	mov    rdi,rbx
    1682:	mov    rax,QWORD PTR [rdi+0x10]
    1686:	mov    rcx,QWORD PTR [rax]
    1689:	xor    rdx,rdx
    168c:	mov    rsi,r8
    168f:	call   1694 <botlish_fn_17+0x10c>
			1690: R_X86_64_PLT32	rt_type_error-0x4
    1694:	xor    rax,rax
    1697:	mov    rbx,QWORD PTR [rsp+0x20]
    169c:	mov    r12,QWORD PTR [rsp+0x28]
    16a1:	mov    r13,QWORD PTR [rsp+0x30]
    16a6:	add    rsp,0x40
    16aa:	mov    rsp,rbp
    16ad:	pop    rbp
    16ae:	ret
    16af:	mov    rcx,r8
    16b2:	mov    rsi,r13
    16b5:	mov    rax,rsi
    16b8:	and    rax,rcx
    16bb:	test   rax,0x1
    16c1:	jne    16d2 <botlish_fn_17+0x14a>
    16c7:	mov    rdx,r8
    16ca:	mov    rsi,r13
    16cd:	jmp    16f0 <botlish_fn_17+0x168>
    16d2:	mov    rcx,r8
    16d5:	lea    rax,[rcx-0x1]
    16d9:	mov    rsi,r13
    16dc:	add    rsi,rax
    16df:	seto   al
    16e2:	test   al,al
    16e4:	je     16fb <botlish_fn_17+0x173>
    16ea:	mov    rdx,r8
    16ed:	mov    rsi,r13
    16f0:	mov    rdi,rbx
    16f3:	call   16f8 <botlish_fn_17+0x170>
			16f4: R_X86_64_PLT32	rt_int_add-0x4
    16f8:	mov    rsi,rax
    16fb:	mov    QWORD PTR [rsp+0x8],rsi
    1700:	mov    QWORD PTR [rsp+0x10],0x3
    1709:	test   rsi,0x1
    1710:	je     1733 <botlish_fn_17+0x1ab>
    1716:	mov    rax,rsi
    1719:	add    rax,0x2
    171d:	mov    rcx,rax
    1720:	seto   al
    1723:	test   al,al
    1725:	jne    1733 <botlish_fn_17+0x1ab>
    172b:	mov    rsi,rcx
    172e:	jmp    1743 <botlish_fn_17+0x1bb>
    1733:	mov    edx,0x3
    1738:	mov    rdi,rbx
    173b:	call   1740 <botlish_fn_17+0x1b8>
			173c: R_X86_64_PLT32	rt_int_add-0x4
    1740:	mov    rsi,rax
    1743:	mov    QWORD PTR [rsp+0x8],rsi
    1748:	mov    edx,0x7
    174d:	mov    rdi,rdx
    1750:	mov    QWORD PTR [rsp+0x10],0x7
    1759:	test   rsi,0x1
    1760:	jne    176e <botlish_fn_17+0x1e6>
    1766:	mov    rdx,rdi
    1769:	jmp    179a <botlish_fn_17+0x212>
    176e:	mov    rax,rsi
    1771:	sar    rax,1
    1774:	imul   QWORD PTR [rip+0xf5]        # 1870 <botlish_fn_17+0x2e8>
    177b:	seto   cl
    177e:	or     rax,0x1
    1782:	test   cl,cl
    1784:	je     1792 <botlish_fn_17+0x20a>
    178a:	mov    rdx,rdi
    178d:	jmp    179a <botlish_fn_17+0x212>
    1792:	mov    rsi,rax
    1795:	jmp    17a5 <botlish_fn_17+0x21d>
    179a:	mov    rdi,rbx
    179d:	call   17a2 <botlish_fn_17+0x21a>
			179e: R_X86_64_PLT32	rt_int_mul-0x4
    17a2:	mov    rsi,rax
    17a5:	mov    QWORD PTR [rsp],rsi
    17a9:	mov    r13,rsi
    17ac:	mov    rsi,r12
    17af:	mov    rdi,rbx
    17b2:	call   17b7 <botlish_fn_17+0x22f>
			17b3: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    17b7:	mov    QWORD PTR [rsp+0x8],rax
    17bc:	mov    QWORD PTR [rsp+0x10],0x5
    17c5:	test   rax,0x1
    17cb:	mov    rcx,rax
    17ce:	je     17fd <botlish_fn_17+0x275>
    17d4:	mov    rax,rcx
    17d7:	sar    rax,1
    17da:	imul   QWORD PTR [rip+0x97]        # 1878 <botlish_fn_17+0x2f0>
    17e1:	seto   sil
    17e5:	or     rax,0x1
    17e9:	test   sil,sil
    17ec:	jne    17fd <botlish_fn_17+0x275>
    17f2:	mov    rdx,rax
    17f5:	mov    rsi,r13
    17f8:	jmp    1813 <botlish_fn_17+0x28b>
    17fd:	mov    edx,0x5
    1802:	mov    rsi,rcx
    1805:	mov    rdi,rbx
    1808:	call   180d <botlish_fn_17+0x285>
			1809: R_X86_64_PLT32	rt_int_mul-0x4
    180d:	mov    rdx,rax
    1810:	mov    rsi,r13
    1813:	mov    rdi,rsi
    1816:	and    rdi,rdx
    1819:	test   rdi,0x1
    1820:	jne    1846 <botlish_fn_17+0x2be>
    1826:	mov    rdi,rbx
    1829:	call   182e <botlish_fn_17+0x2a6>
			182a: R_X86_64_PLT32	rt_int_cmp-0x4
    182e:	mov    esi,0x2
    1833:	test   rax,rax
    1836:	mov    rax,rsi
    1839:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1870 <botlish_fn_17+0x2e8>
    1841:	jmp    1856 <botlish_fn_17+0x2ce>
    1846:	mov    eax,0x2
    184b:	cmp    rsi,rdx
    184e:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1870 <botlish_fn_17+0x2e8>
    1856:	mov    rbx,QWORD PTR [rsp+0x20]
    185b:	mov    r12,QWORD PTR [rsp+0x28]
    1860:	mov    r13,QWORD PTR [rsp+0x30]
    1865:	add    rsp,0x40
    1869:	mov    rsp,rbp
    186c:	pop    rbp
    186d:	ret
    186e:	add    BYTE PTR [rax],al
    1870:	(bad)
    1871:	add    BYTE PTR [rax],al
    1873:	add    BYTE PTR [rax],al
    1875:	add    BYTE PTR [rax],al
    1877:	add    BYTE PTR [rax+rax*1],al
    187a:	add    BYTE PTR [rax],al
    187c:	add    BYTE PTR [rax],al
	...

0000000000001880 <botlish_entry_17: ht_should_grow<HashTable>>:
    1880:	push   rbp
    1881:	mov    rbp,rsp
    1884:	mov    rsi,QWORD PTR [rdx]
    1887:	call   188c <botlish_entry_17+0xc>
			1888: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    188c:	mov    rsp,rbp
    188f:	pop    rbp
    1890:	ret
    1891:	add    BYTE PTR [rax],al
    1893:	add    BYTE PTR [rax],al
    1895:	add    BYTE PTR [rax],al
	...

0000000000001898 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1898:	push   rbp
    1899:	mov    rbp,rsp
    189c:	sub    rsp,0x40
    18a0:	mov    QWORD PTR [rsp+0x20],rbx
    18a5:	mov    QWORD PTR [rsp+0x28],r12
    18aa:	mov    QWORD PTR [rsp+0x30],r13
    18af:	mov    rbx,rdi
    18b2:	mov    QWORD PTR [rsp+0x10],0x0
    18bb:	mov    QWORD PTR [rsp],rsi
    18bf:	mov    r12,rsi
    18c2:	mov    rsi,r12
    18c5:	mov    rdi,rbx
    18c8:	call   18cd <botlish_fn_18+0x35>
			18c9: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    18cd:	test   rax,rax
    18d0:	mov    r13,rax
    18d3:	je     1ac1 <botlish_fn_18+0x229>
    18d9:	mov    rsi,r12
    18dc:	mov    rdi,rbx
    18df:	call   18e4 <botlish_fn_18+0x4c>
			18e0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    18e4:	mov    r11,rax
    18e7:	test   r11,r11
    18ea:	je     1ac1 <botlish_fn_18+0x229>
    18f0:	mov    ecx,0x1
    18f5:	mov    rax,r13
    18f8:	test   rax,0x1
    18fe:	je     190c <botlish_fn_18+0x74>
    1904:	mov    r13,rax
    1907:	jmp    1930 <botlish_fn_18+0x98>
    190c:	xor    ecx,ecx
    190e:	test   rax,0x7
    1914:	je     1922 <botlish_fn_18+0x8a>
    191a:	mov    r13,rax
    191d:	jmp    1930 <botlish_fn_18+0x98>
    1922:	movzx  rcx,BYTE PTR [rax]
    1926:	mov    r13,rax
    1929:	rex cmp cl,0x1
    192d:	sete   cl
    1930:	test   cl,cl
    1932:	jne    1953 <botlish_fn_18+0xbb>
    1938:	mov    rdi,rbx
    193b:	mov    rsi,QWORD PTR [rdi+0x10]
    193f:	mov    rcx,QWORD PTR [rsi+0x8]
    1943:	xor    rdx,rdx
    1946:	mov    rsi,r13
    1949:	call   194e <botlish_fn_18+0xb6>
			194a: R_X86_64_PLT32	rt_type_error-0x4
    194e:	jmp    1ac1 <botlish_fn_18+0x229>
    1953:	mov    rsi,r13
    1956:	mov    eax,0x1
    195b:	test   r11,0x1
    1962:	je     1970 <botlish_fn_18+0xd8>
    1968:	mov    r8,r11
    196b:	jmp    1995 <botlish_fn_18+0xfd>
    1970:	xor    eax,eax
    1972:	test   r11,0x7
    1979:	je     1987 <botlish_fn_18+0xef>
    197f:	mov    r8,r11
    1982:	jmp    1995 <botlish_fn_18+0xfd>
    1987:	movzx  r10,BYTE PTR [r11]
    198b:	mov    r8,r11
    198e:	cmp    r10b,0x1
    1992:	sete   al
    1995:	test   al,al
    1997:	jne    19b8 <botlish_fn_18+0x120>
    199d:	mov    rdi,rbx
    19a0:	mov    rax,QWORD PTR [rdi+0x10]
    19a4:	mov    rcx,QWORD PTR [rax+0x8]
    19a8:	xor    rdx,rdx
    19ab:	mov    rsi,r8
    19ae:	call   19b3 <botlish_fn_18+0x11b>
			19af: R_X86_64_PLT32	rt_type_error-0x4
    19b3:	jmp    1ac1 <botlish_fn_18+0x229>
    19b8:	mov    r11,r8
    19bb:	mov    rax,rsi
    19be:	and    rax,r11
    19c1:	test   rax,0x1
    19c7:	jne    19ed <botlish_fn_18+0x155>
    19cd:	mov    rdx,r8
    19d0:	mov    rdi,rbx
    19d3:	call   19d8 <botlish_fn_18+0x140>
			19d4: R_X86_64_PLT32	rt_int_cmp-0x4
    19d8:	mov    ecx,0x2
    19dd:	test   rax,rax
    19e0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1af8 <botlish_fn_18+0x260>
    19e8:	jmp    1a00 <botlish_fn_18+0x168>
    19ed:	mov    ecx,0x2
    19f2:	mov    r11,r8
    19f5:	cmp    rsi,r11
    19f8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1af8 <botlish_fn_18+0x260>
    1a00:	cmp    rcx,0x6
    1a04:	je     1a9a <botlish_fn_18+0x202>
    1a0a:	mov    rsi,r12
    1a0d:	mov    rdi,rbx
    1a10:	call   1a15 <botlish_fn_18+0x17d>
			1a11: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1a15:	mov    QWORD PTR [rsp+0x8],rax
    1a1a:	mov    QWORD PTR [rsp+0x10],0x5
    1a23:	test   rax,0x1
    1a29:	mov    rsi,rax
    1a2c:	je     1a59 <botlish_fn_18+0x1c1>
    1a32:	mov    rcx,rsi
    1a35:	mov    rax,rcx
    1a38:	sar    rax,1
    1a3b:	imul   QWORD PTR [rip+0xbe]        # 1b00 <botlish_fn_18+0x268>
    1a42:	seto   cl
    1a45:	or     rax,0x1
    1a49:	test   cl,cl
    1a4b:	jne    1a59 <botlish_fn_18+0x1c1>
    1a51:	mov    rdx,rax
    1a54:	jmp    1a69 <botlish_fn_18+0x1d1>
    1a59:	mov    edx,0x5
    1a5e:	mov    rdi,rbx
    1a61:	call   1a66 <botlish_fn_18+0x1ce>
			1a62: R_X86_64_PLT32	rt_int_mul-0x4
    1a66:	mov    rdx,rax
    1a69:	mov    QWORD PTR [rsp+0x8],rdx
    1a6e:	mov    rsi,r12
    1a71:	mov    rdi,rbx
    1a74:	call   1a79 <botlish_fn_18+0x1e1>
			1a75: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a79:	test   rax,rax
    1a7c:	je     1ac1 <botlish_fn_18+0x229>
    1a82:	mov    rbx,QWORD PTR [rsp+0x20]
    1a87:	mov    r12,QWORD PTR [rsp+0x28]
    1a8c:	mov    r13,QWORD PTR [rsp+0x30]
    1a91:	add    rsp,0x40
    1a95:	mov    rsp,rbp
    1a98:	pop    rbp
    1a99:	ret
    1a9a:	mov    rsi,r12
    1a9d:	mov    rdi,rbx
    1aa0:	call   1aa5 <botlish_fn_18+0x20d>
			1aa1: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1aa5:	mov    QWORD PTR [rsp+0x8],rax
    1aaa:	mov    rdx,rax
    1aad:	mov    rsi,r12
    1ab0:	mov    rdi,rbx
    1ab3:	call   1ab8 <botlish_fn_18+0x220>
			1ab4: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1ab8:	test   rax,rax
    1abb:	jne    1adc <botlish_fn_18+0x244>
    1ac1:	xor    rax,rax
    1ac4:	mov    rbx,QWORD PTR [rsp+0x20]
    1ac9:	mov    r12,QWORD PTR [rsp+0x28]
    1ace:	mov    r13,QWORD PTR [rsp+0x30]
    1ad3:	add    rsp,0x40
    1ad7:	mov    rsp,rbp
    1ada:	pop    rbp
    1adb:	ret
    1adc:	mov    rbx,QWORD PTR [rsp+0x20]
    1ae1:	mov    r12,QWORD PTR [rsp+0x28]
    1ae6:	mov    r13,QWORD PTR [rsp+0x30]
    1aeb:	add    rsp,0x40
    1aef:	mov    rsp,rbp
    1af2:	pop    rbp
    1af3:	ret
    1af4:	add    BYTE PTR [rax],al
    1af6:	add    BYTE PTR [rax],al
    1af8:	(bad)
    1af9:	add    BYTE PTR [rax],al
    1afb:	add    BYTE PTR [rax],al
    1afd:	add    BYTE PTR [rax],al
    1aff:	add    BYTE PTR [rax+rax*1],al
    1b02:	add    BYTE PTR [rax],al
    1b04:	add    BYTE PTR [rax],al
	...

0000000000001b08 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1b08:	push   rbp
    1b09:	mov    rbp,rsp
    1b0c:	mov    rsi,QWORD PTR [rdx]
    1b0f:	call   1b14 <botlish_entry_18+0xc>
			1b10: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1b14:	mov    rsp,rbp
    1b17:	pop    rbp
    1b18:	ret
    1b19:	add    BYTE PTR [rax],al
    1b1b:	add    BYTE PTR [rax],al
    1b1d:	add    BYTE PTR [rax],al
	...

0000000000001b20 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    1b20:	push   rbp
    1b21:	mov    rbp,rsp
    1b24:	sub    rsp,0x70
    1b28:	mov    QWORD PTR [rsp+0x40],rbx
    1b2d:	mov    QWORD PTR [rsp+0x48],r12
    1b32:	mov    QWORD PTR [rsp+0x50],r13
    1b37:	mov    QWORD PTR [rsp+0x58],r14
    1b3c:	mov    QWORD PTR [rsp+0x60],r15
    1b41:	mov    r12,rdi
    1b44:	mov    r14,r8
    1b47:	mov    r15,rdx
    1b4a:	mov    QWORD PTR [rsp+0x30],rcx
    1b4f:	mov    QWORD PTR [rsp],rsi
    1b53:	mov    r9,QWORD PTR [rsi+0x18]
    1b57:	mov    r13,rsi
    1b5a:	mov    rsi,QWORD PTR [r9]
    1b5d:	mov    rdx,r15
    1b60:	mov    rdi,r12
    1b63:	call   1b68 <botlish_fn_19+0x48>
			1b64: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b68:	test   rax,rax
    1b6b:	je     1dff <botlish_fn_19+0x2df>
    1b71:	mov    QWORD PTR [rsp+0x8],rax
    1b76:	mov    rbx,r13
    1b79:	mov    r13,rax
    1b7c:	mov    rax,QWORD PTR [rbx+0x18]
    1b80:	mov    rsi,QWORD PTR [rax]
    1b83:	mov    ecx,0x3
    1b88:	mov    rdx,r15
    1b8b:	mov    rdi,r12
    1b8e:	call   1b93 <botlish_fn_19+0x73>
			1b8f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b93:	test   rax,rax
    1b96:	je     1dff <botlish_fn_19+0x2df>
    1b9c:	mov    rax,QWORD PTR [rbx+0x18]
    1ba0:	mov    rsi,QWORD PTR [rax+0x8]
    1ba4:	mov    rcx,QWORD PTR [rsp+0x30]
    1ba9:	mov    rdx,r15
    1bac:	mov    rdi,r12
    1baf:	call   1bb4 <botlish_fn_19+0x94>
			1bb0: R_X86_64_PLT32	rt_mutarray_set-0x4
    1bb4:	test   rax,rax
    1bb7:	je     1dff <botlish_fn_19+0x2df>
    1bbd:	mov    rax,QWORD PTR [rbx+0x18]
    1bc1:	mov    rsi,QWORD PTR [rax+0x10]
    1bc5:	mov    rcx,r14
    1bc8:	mov    rdx,r15
    1bcb:	mov    rdi,r12
    1bce:	call   1bd3 <botlish_fn_19+0xb3>
			1bcf: R_X86_64_PLT32	rt_mutarray_set-0x4
    1bd3:	test   rax,rax
    1bd6:	je     1dff <botlish_fn_19+0x2df>
    1bdc:	mov    rax,QWORD PTR [rbx+0x18]
    1be0:	mov    rsi,QWORD PTR [rax+0x18]
    1be4:	mov    QWORD PTR [rsp+0x10],rsi
    1be9:	mov    r14,rsi
    1bec:	mov    QWORD PTR [rsp+0x18],0x1
    1bf5:	mov    rsi,rbx
    1bf8:	mov    rdi,r12
    1bfb:	call   1c00 <botlish_fn_19+0xe0>
			1bfc: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1c00:	test   rax,rax
    1c03:	je     1dff <botlish_fn_19+0x2df>
    1c09:	mov    QWORD PTR [rsp+0x20],rax
    1c0e:	mov    QWORD PTR [rsp+0x28],0x3
    1c17:	mov    ecx,0x1
    1c1c:	test   rax,0x1
    1c22:	je     1c30 <botlish_fn_19+0x110>
    1c28:	mov    rsi,rax
    1c2b:	jmp    1c54 <botlish_fn_19+0x134>
    1c30:	xor    ecx,ecx
    1c32:	test   rax,0x7
    1c38:	je     1c46 <botlish_fn_19+0x126>
    1c3e:	mov    rsi,rax
    1c41:	jmp    1c54 <botlish_fn_19+0x134>
    1c46:	movzx  rcx,BYTE PTR [rax]
    1c4a:	mov    rsi,rax
    1c4d:	rex cmp cl,0x1
    1c51:	sete   cl
    1c54:	test   cl,cl
    1c56:	jne    1c73 <botlish_fn_19+0x153>
    1c5c:	mov    rdi,r12
    1c5f:	mov    rax,QWORD PTR [rdi+0x10]
    1c63:	mov    rcx,QWORD PTR [rax]
    1c66:	xor    rdx,rdx
    1c69:	call   1c6e <botlish_fn_19+0x14e>
			1c6a: R_X86_64_PLT32	rt_type_error-0x4
    1c6e:	jmp    1dff <botlish_fn_19+0x2df>
    1c73:	test   rsi,0x1
    1c7a:	je     1c92 <botlish_fn_19+0x172>
    1c80:	mov    rcx,rsi
    1c83:	add    rcx,0x2
    1c87:	seto   al
    1c8a:	test   al,al
    1c8c:	je     1ca2 <botlish_fn_19+0x182>
    1c92:	mov    edx,0x3
    1c97:	mov    rdi,r12
    1c9a:	call   1c9f <botlish_fn_19+0x17f>
			1c9b: R_X86_64_PLT32	rt_int_add-0x4
    1c9f:	mov    rcx,rax
    1ca2:	mov    edx,0x1
    1ca7:	mov    rsi,r14
    1caa:	mov    rdi,r12
    1cad:	call   1cb2 <botlish_fn_19+0x192>
			1cae: R_X86_64_PLT32	rt_mutarray_set-0x4
    1cb2:	test   rax,rax
    1cb5:	je     1dff <botlish_fn_19+0x2df>
    1cbb:	mov    rax,r13
    1cbe:	test   rax,0x1
    1cc4:	jne    1cef <botlish_fn_19+0x1cf>
    1cca:	mov    edx,0x5
    1ccf:	mov    rsi,r13
    1cd2:	mov    rdi,r12
    1cd5:	call   1cda <botlish_fn_19+0x1ba>
			1cd6: R_X86_64_PLT32	rt_int_cmp-0x4
    1cda:	mov    ecx,0x2
    1cdf:	test   rax,rax
    1ce2:	cmove  rcx,QWORD PTR [rip+0x166]        # 1e50 <botlish_fn_19+0x330>
    1cea:	jmp    1d03 <botlish_fn_19+0x1e3>
    1cef:	mov    rsi,r13
    1cf2:	mov    ecx,0x2
    1cf7:	cmp    rsi,0x5
    1cfb:	cmove  rcx,QWORD PTR [rip+0x14d]        # 1e50 <botlish_fn_19+0x330>
    1d03:	cmp    rcx,0x6
    1d07:	je     1d15 <botlish_fn_19+0x1f5>
    1d0d:	mov    rax,rbx
    1d10:	jmp    1e27 <botlish_fn_19+0x307>
    1d15:	mov    rax,QWORD PTR [rbx+0x18]
    1d19:	mov    rsi,QWORD PTR [rax+0x18]
    1d1d:	mov    QWORD PTR [rsp+0x8],rsi
    1d22:	mov    r14,rsi
    1d25:	mov    QWORD PTR [rsp+0x10],0x3
    1d2e:	mov    rsi,rbx
    1d31:	mov    rdi,r12
    1d34:	call   1d39 <botlish_fn_19+0x219>
			1d35: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1d39:	mov    r13,rbx
    1d3c:	test   rax,rax
    1d3f:	je     1dff <botlish_fn_19+0x2df>
    1d45:	mov    QWORD PTR [rsp+0x18],rax
    1d4a:	mov    QWORD PTR [rsp+0x20],0x3
    1d53:	mov    ecx,0x1
    1d58:	test   rax,0x1
    1d5e:	je     1d6c <botlish_fn_19+0x24c>
    1d64:	mov    rsi,rax
    1d67:	jmp    1d90 <botlish_fn_19+0x270>
    1d6c:	xor    ecx,ecx
    1d6e:	test   rax,0x7
    1d74:	je     1d82 <botlish_fn_19+0x262>
    1d7a:	mov    rsi,rax
    1d7d:	jmp    1d90 <botlish_fn_19+0x270>
    1d82:	movzx  r10,BYTE PTR [rax]
    1d86:	mov    rsi,rax
    1d89:	cmp    r10b,0x1
    1d8d:	sete   cl
    1d90:	test   cl,cl
    1d92:	jne    1db0 <botlish_fn_19+0x290>
    1d98:	mov    rdi,r12
    1d9b:	mov    rax,QWORD PTR [rdi+0x10]
    1d9f:	mov    rcx,QWORD PTR [rax+0x10]
    1da3:	xor    rdx,rdx
    1da6:	call   1dab <botlish_fn_19+0x28b>
			1da7: R_X86_64_PLT32	rt_type_error-0x4
    1dab:	jmp    1dff <botlish_fn_19+0x2df>
    1db0:	test   rsi,0x1
    1db7:	je     1dd6 <botlish_fn_19+0x2b6>
    1dbd:	mov    rcx,rsi
    1dc0:	sub    rcx,0x3
    1dc4:	seto   al
    1dc7:	add    rcx,0x1
    1dce:	test   al,al
    1dd0:	je     1de6 <botlish_fn_19+0x2c6>
    1dd6:	mov    edx,0x3
    1ddb:	mov    rdi,r12
    1dde:	call   1de3 <botlish_fn_19+0x2c3>
			1ddf: R_X86_64_PLT32	rt_int_sub-0x4
    1de3:	mov    rcx,rax
    1de6:	mov    edx,0x3
    1deb:	mov    rsi,r14
    1dee:	mov    rdi,r12
    1df1:	call   1df6 <botlish_fn_19+0x2d6>
			1df2: R_X86_64_PLT32	rt_mutarray_set-0x4
    1df6:	test   rax,rax
    1df9:	jne    1e24 <botlish_fn_19+0x304>
    1dff:	xor    rax,rax
    1e02:	mov    rbx,QWORD PTR [rsp+0x40]
    1e07:	mov    r12,QWORD PTR [rsp+0x48]
    1e0c:	mov    r13,QWORD PTR [rsp+0x50]
    1e11:	mov    r14,QWORD PTR [rsp+0x58]
    1e16:	mov    r15,QWORD PTR [rsp+0x60]
    1e1b:	add    rsp,0x70
    1e1f:	mov    rsp,rbp
    1e22:	pop    rbp
    1e23:	ret
    1e24:	mov    rax,r13
    1e27:	mov    rbx,QWORD PTR [rsp+0x40]
    1e2c:	mov    r12,QWORD PTR [rsp+0x48]
    1e31:	mov    r13,QWORD PTR [rsp+0x50]
    1e36:	mov    r14,QWORD PTR [rsp+0x58]
    1e3b:	mov    r15,QWORD PTR [rsp+0x60]
    1e40:	add    rsp,0x70
    1e44:	mov    rsp,rbp
    1e47:	pop    rbp
    1e48:	ret
    1e49:	add    BYTE PTR [rax],al
    1e4b:	add    BYTE PTR [rax],al
    1e4d:	add    BYTE PTR [rax],al
    1e4f:	add    BYTE PTR [rsi],al
    1e51:	add    BYTE PTR [rax],al
    1e53:	add    BYTE PTR [rax],al
    1e55:	add    BYTE PTR [rax],al
	...

0000000000001e58 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    1e58:	push   rbp
    1e59:	mov    rbp,rsp
    1e5c:	mov    rsi,QWORD PTR [rdx]
    1e5f:	mov    r9,QWORD PTR [rdx+0x8]
    1e63:	mov    rcx,QWORD PTR [rdx+0x10]
    1e67:	mov    r8,QWORD PTR [rdx+0x18]
    1e6b:	mov    rdx,r9
    1e6e:	call   1e73 <botlish_entry_19+0x1b>
			1e6f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1e73:	mov    rsp,rbp
    1e76:	pop    rbp
    1e77:	ret

0000000000001e78 <botlish_fn_20: ht_set<HashTable, str, str>>:
    1e78:	push   rbp
    1e79:	mov    rbp,rsp
    1e7c:	sub    rsp,0x60
    1e80:	mov    QWORD PTR [rsp+0x30],rbx
    1e85:	mov    QWORD PTR [rsp+0x38],r12
    1e8a:	mov    QWORD PTR [rsp+0x40],r13
    1e8f:	mov    QWORD PTR [rsp+0x48],r14
    1e94:	mov    QWORD PTR [rsp+0x50],r15
    1e99:	mov    r12,rdi
    1e9c:	mov    r13,rdx
    1e9f:	mov    QWORD PTR [rsp],rsi
    1ea3:	mov    r14,rsi
    1ea6:	mov    QWORD PTR [rsp+0x8],rdx
    1eab:	mov    QWORD PTR [rsp+0x10],rcx
    1eb0:	mov    rbx,rcx
    1eb3:	mov    rdx,r13
    1eb6:	mov    rsi,r14
    1eb9:	mov    rdi,r12
    1ebc:	call   1ec1 <botlish_fn_20+0x49>
			1ebd: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1ec1:	test   rax,rax
    1ec4:	je     209c <botlish_fn_20+0x224>
    1eca:	mov    QWORD PTR [rsp+0x18],rax
    1ecf:	mov    rcx,rax
    1ed2:	mov    r8,0xffffffffffffffff
    1ed9:	mov    r15,r8
    1edc:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1ee5:	mov    rdx,r13
    1ee8:	mov    rsi,r14
    1eeb:	mov    rdi,r12
    1eee:	call   1ef3 <botlish_fn_20+0x7b>
			1eef: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1ef3:	test   rax,rax
    1ef6:	je     209c <botlish_fn_20+0x224>
    1efc:	mov    QWORD PTR [rsp+0x18],rax
    1f01:	mov    rsi,r14
    1f04:	mov    QWORD PTR [rsp+0x28],rax
    1f09:	mov    rax,QWORD PTR [rsi+0x18]
    1f0d:	mov    rsi,QWORD PTR [rax]
    1f10:	mov    rdx,QWORD PTR [rsp+0x28]
    1f15:	mov    rdi,r12
    1f18:	call   1f1d <botlish_fn_20+0xa5>
			1f19: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f1d:	test   rax,rax
    1f20:	je     209c <botlish_fn_20+0x224>
    1f26:	test   rax,0x1
    1f2c:	mov    rsi,rax
    1f2f:	jne    1f57 <botlish_fn_20+0xdf>
    1f35:	mov    edx,0x3
    1f3a:	mov    rdi,r12
    1f3d:	call   1f42 <botlish_fn_20+0xca>
			1f3e: R_X86_64_PLT32	rt_int_cmp-0x4
    1f42:	mov    ecx,0x2
    1f47:	test   rax,rax
    1f4a:	cmove  rcx,QWORD PTR [rip+0x196]        # 20e8 <botlish_fn_20+0x270>
    1f52:	jmp    1f68 <botlish_fn_20+0xf0>
    1f57:	mov    ecx,0x2
    1f5c:	cmp    rsi,0x3
    1f60:	cmove  rcx,QWORD PTR [rip+0x180]        # 20e8 <botlish_fn_20+0x270>
    1f68:	cmp    rcx,0x6
    1f6c:	je     2078 <botlish_fn_20+0x200>
    1f72:	mov    rsi,r14
    1f75:	mov    rdi,r12
    1f78:	call   1f7d <botlish_fn_20+0x105>
			1f79: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1f7d:	test   rax,rax
    1f80:	je     209c <botlish_fn_20+0x224>
    1f86:	cmp    rax,0x6
    1f8a:	je     1fd1 <botlish_fn_20+0x159>
    1f90:	mov    rcx,r13
    1f93:	mov    rdx,QWORD PTR [rsp+0x28]
    1f98:	mov    rsi,r14
    1f9b:	mov    rdi,r12
    1f9e:	mov    r8,rbx
    1fa1:	call   1fa6 <botlish_fn_20+0x12e>
			1fa2: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1fa6:	test   rax,rax
    1fa9:	je     209c <botlish_fn_20+0x224>
    1faf:	mov    rbx,QWORD PTR [rsp+0x30]
    1fb4:	mov    r12,QWORD PTR [rsp+0x38]
    1fb9:	mov    r13,QWORD PTR [rsp+0x40]
    1fbe:	mov    r14,QWORD PTR [rsp+0x48]
    1fc3:	mov    r15,QWORD PTR [rsp+0x50]
    1fc8:	add    rsp,0x60
    1fcc:	mov    rsp,rbp
    1fcf:	pop    rbp
    1fd0:	ret
    1fd1:	mov    rsi,r14
    1fd4:	mov    rdi,r12
    1fd7:	call   1fdc <botlish_fn_20+0x164>
			1fd8: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1fdc:	mov    rcx,rax
    1fdf:	mov    r14,rax
    1fe2:	test   rax,rcx
    1fe5:	je     209c <botlish_fn_20+0x224>
    1feb:	mov    rax,r14
    1fee:	mov    QWORD PTR [rsp],rax
    1ff2:	mov    rdx,r13
    1ff5:	mov    rsi,r14
    1ff8:	mov    rdi,r12
    1ffb:	call   2000 <botlish_fn_20+0x188>
			1ffc: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2000:	test   rax,rax
    2003:	je     209c <botlish_fn_20+0x224>
    2009:	mov    QWORD PTR [rsp+0x18],rax
    200e:	mov    rcx,rax
    2011:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    201a:	mov    r8,r15
    201d:	mov    rdx,r13
    2020:	mov    rsi,r14
    2023:	mov    rdi,r12
    2026:	call   202b <botlish_fn_20+0x1b3>
			2027: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    202b:	test   rax,rax
    202e:	je     209c <botlish_fn_20+0x224>
    2034:	mov    QWORD PTR [rsp+0x18],rax
    2039:	mov    rcx,r13
    203c:	mov    rdx,rax
    203f:	mov    rsi,r14
    2042:	mov    rdi,r12
    2045:	mov    r8,rbx
    2048:	call   204d <botlish_fn_20+0x1d5>
			2049: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    204d:	test   rax,rax
    2050:	je     209c <botlish_fn_20+0x224>
    2056:	mov    rbx,QWORD PTR [rsp+0x30]
    205b:	mov    r12,QWORD PTR [rsp+0x38]
    2060:	mov    r13,QWORD PTR [rsp+0x40]
    2065:	mov    r14,QWORD PTR [rsp+0x48]
    206a:	mov    r15,QWORD PTR [rsp+0x50]
    206f:	add    rsp,0x60
    2073:	mov    rsp,rbp
    2076:	pop    rbp
    2077:	ret
    2078:	mov    rdx,QWORD PTR [rsp+0x28]
    207d:	mov    rsi,r14
    2080:	mov    rax,QWORD PTR [rsi+0x18]
    2084:	mov    rsi,QWORD PTR [rax+0x10]
    2088:	mov    rcx,rbx
    208b:	mov    rdi,r12
    208e:	call   2093 <botlish_fn_20+0x21b>
			208f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2093:	test   rax,rax
    2096:	jne    20c1 <botlish_fn_20+0x249>
    209c:	xor    rax,rax
    209f:	mov    rbx,QWORD PTR [rsp+0x30]
    20a4:	mov    r12,QWORD PTR [rsp+0x38]
    20a9:	mov    r13,QWORD PTR [rsp+0x40]
    20ae:	mov    r14,QWORD PTR [rsp+0x48]
    20b3:	mov    r15,QWORD PTR [rsp+0x50]
    20b8:	add    rsp,0x60
    20bc:	mov    rsp,rbp
    20bf:	pop    rbp
    20c0:	ret
    20c1:	mov    rax,r14
    20c4:	mov    rbx,QWORD PTR [rsp+0x30]
    20c9:	mov    r12,QWORD PTR [rsp+0x38]
    20ce:	mov    r13,QWORD PTR [rsp+0x40]
    20d3:	mov    r14,QWORD PTR [rsp+0x48]
    20d8:	mov    r15,QWORD PTR [rsp+0x50]
    20dd:	add    rsp,0x60
    20e1:	mov    rsp,rbp
    20e4:	pop    rbp
    20e5:	ret
    20e6:	add    BYTE PTR [rax],al
    20e8:	(bad)
    20e9:	add    BYTE PTR [rax],al
    20eb:	add    BYTE PTR [rax],al
    20ed:	add    BYTE PTR [rax],al
	...

00000000000020f0 <botlish_entry_20: ht_set<HashTable, str, str>>:
    20f0:	push   rbp
    20f1:	mov    rbp,rsp
    20f4:	mov    rsi,QWORD PTR [rdx]
    20f7:	mov    r8,QWORD PTR [rdx+0x8]
    20fb:	mov    rcx,QWORD PTR [rdx+0x10]
    20ff:	mov    rdx,r8
    2102:	call   2107 <botlish_entry_20+0x17>
			2103: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2107:	mov    rsp,rbp
    210a:	pop    rbp
    210b:	ret
    210c:	add    BYTE PTR [rax],al
	...

0000000000002110 <botlish_fn_21: ht_delete<HashTable, str>>:
    2110:	push   rbp
    2111:	mov    rbp,rsp
    2114:	sub    rsp,0x50
    2118:	mov    QWORD PTR [rsp+0x30],rbx
    211d:	mov    QWORD PTR [rsp+0x38],r12
    2122:	mov    QWORD PTR [rsp+0x40],r13
    2127:	mov    QWORD PTR [rsp+0x48],r14
    212c:	mov    r13,rdi
    212f:	mov    QWORD PTR [rsp+0x18],0x0
    2138:	mov    QWORD PTR [rsp+0x20],0x0
    2141:	mov    QWORD PTR [rsp],rsi
    2145:	mov    r12,rsi
    2148:	mov    QWORD PTR [rsp+0x8],rdx
    214d:	mov    r14,rdx
    2150:	mov    rbx,r12
    2153:	mov    rdx,r14
    2156:	mov    rsi,rbx
    2159:	mov    rdi,r13
    215c:	call   2161 <botlish_fn_21+0x51>
			215d: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2161:	test   rax,rax
    2164:	je     2408 <botlish_fn_21+0x2f8>
    216a:	mov    QWORD PTR [rsp+0x10],rax
    216f:	mov    rcx,rax
    2172:	mov    rdx,r14
    2175:	mov    rsi,rbx
    2178:	mov    rdi,r13
    217b:	call   2180 <botlish_fn_21+0x70>
			217c: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2180:	mov    rcx,rax
    2183:	mov    r12,rax
    2186:	test   rax,rcx
    2189:	je     2408 <botlish_fn_21+0x2f8>
    218f:	mov    rax,r12
    2192:	test   rax,0x1
    2198:	jne    21c3 <botlish_fn_21+0xb3>
    219e:	mov    edx,0x1
    21a3:	mov    rsi,r12
    21a6:	mov    rdi,r13
    21a9:	call   21ae <botlish_fn_21+0x9e>
			21aa: R_X86_64_PLT32	rt_int_cmp-0x4
    21ae:	mov    ecx,0x2
    21b3:	test   rax,rax
    21b6:	cmovl  rcx,QWORD PTR [rip+0x2aa]        # 2468 <botlish_fn_21+0x358>
    21be:	jmp    21d3 <botlish_fn_21+0xc3>
    21c3:	mov    ecx,0x2
    21c8:	test   r12,r12
    21cb:	cmovle rcx,QWORD PTR [rip+0x295]        # 2468 <botlish_fn_21+0x358>
    21d3:	cmp    rcx,0x6
    21d7:	je     2448 <botlish_fn_21+0x338>
    21dd:	mov    rcx,QWORD PTR [rbx+0x18]
    21e1:	mov    rsi,QWORD PTR [rcx]
    21e4:	mov    ecx,0x5
    21e9:	mov    rdx,r12
    21ec:	mov    rdi,r13
    21ef:	call   21f4 <botlish_fn_21+0xe4>
			21f0: R_X86_64_PLT32	rt_mutarray_set-0x4
    21f4:	test   rax,rax
    21f7:	je     2408 <botlish_fn_21+0x2f8>
    21fd:	mov    rax,QWORD PTR [rbx+0x18]
    2201:	mov    rsi,QWORD PTR [rax+0x8]
    2205:	mov    ecx,0xa
    220a:	mov    rdx,r12
    220d:	mov    rdi,r13
    2210:	call   2215 <botlish_fn_21+0x105>
			2211: R_X86_64_PLT32	rt_mutarray_set-0x4
    2215:	test   rax,rax
    2218:	je     2408 <botlish_fn_21+0x2f8>
    221e:	mov    rax,QWORD PTR [rbx+0x18]
    2222:	mov    rsi,QWORD PTR [rax+0x10]
    2226:	mov    ecx,0xa
    222b:	mov    rdx,r12
    222e:	mov    rdi,r13
    2231:	call   2236 <botlish_fn_21+0x126>
			2232: R_X86_64_PLT32	rt_mutarray_set-0x4
    2236:	test   rax,rax
    2239:	je     2408 <botlish_fn_21+0x2f8>
    223f:	mov    rax,QWORD PTR [rbx+0x18]
    2243:	mov    rsi,QWORD PTR [rax+0x18]
    2247:	mov    QWORD PTR [rsp+0x8],rsi
    224c:	mov    r12,rsi
    224f:	mov    QWORD PTR [rsp+0x10],0x1
    2258:	mov    rsi,rbx
    225b:	mov    rdi,r13
    225e:	call   2263 <botlish_fn_21+0x153>
			225f: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2263:	test   rax,rax
    2266:	je     2408 <botlish_fn_21+0x2f8>
    226c:	mov    QWORD PTR [rsp+0x18],rax
    2271:	mov    QWORD PTR [rsp+0x20],0x3
    227a:	mov    edx,0x1
    227f:	test   rax,0x1
    2285:	je     2293 <botlish_fn_21+0x183>
    228b:	mov    rsi,rax
    228e:	jmp    22b7 <botlish_fn_21+0x1a7>
    2293:	xor    edx,edx
    2295:	test   rax,0x7
    229b:	je     22a9 <botlish_fn_21+0x199>
    22a1:	mov    rsi,rax
    22a4:	jmp    22b7 <botlish_fn_21+0x1a7>
    22a9:	movzx  rcx,BYTE PTR [rax]
    22ad:	mov    rsi,rax
    22b0:	rex cmp cl,0x1
    22b4:	sete   dl
    22b7:	test   dl,dl
    22b9:	jne    22d7 <botlish_fn_21+0x1c7>
    22bf:	mov    rdi,r13
    22c2:	mov    rax,QWORD PTR [rdi+0x10]
    22c6:	mov    rcx,QWORD PTR [rax+0x10]
    22ca:	xor    rdx,rdx
    22cd:	call   22d2 <botlish_fn_21+0x1c2>
			22ce: R_X86_64_PLT32	rt_type_error-0x4
    22d2:	jmp    2408 <botlish_fn_21+0x2f8>
    22d7:	test   rsi,0x1
    22de:	je     22fd <botlish_fn_21+0x1ed>
    22e4:	mov    rcx,rsi
    22e7:	sub    rcx,0x3
    22eb:	seto   al
    22ee:	add    rcx,0x1
    22f5:	test   al,al
    22f7:	je     230d <botlish_fn_21+0x1fd>
    22fd:	mov    edx,0x3
    2302:	mov    rdi,r13
    2305:	call   230a <botlish_fn_21+0x1fa>
			2306: R_X86_64_PLT32	rt_int_sub-0x4
    230a:	mov    rcx,rax
    230d:	mov    edx,0x1
    2312:	mov    rsi,r12
    2315:	mov    rdi,r13
    2318:	call   231d <botlish_fn_21+0x20d>
			2319: R_X86_64_PLT32	rt_mutarray_set-0x4
    231d:	test   rax,rax
    2320:	je     2408 <botlish_fn_21+0x2f8>
    2326:	mov    rdx,QWORD PTR [rbx+0x18]
    232a:	mov    rsi,QWORD PTR [rdx+0x18]
    232e:	mov    QWORD PTR [rsp+0x8],rsi
    2333:	mov    r14,rsi
    2336:	mov    QWORD PTR [rsp+0x10],0x3
    233f:	mov    rsi,rbx
    2342:	mov    rdi,r13
    2345:	call   234a <botlish_fn_21+0x23a>
			2346: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    234a:	mov    r12,rbx
    234d:	test   rax,rax
    2350:	je     2408 <botlish_fn_21+0x2f8>
    2356:	mov    QWORD PTR [rsp+0x18],rax
    235b:	mov    QWORD PTR [rsp+0x20],0x3
    2364:	mov    ecx,0x1
    2369:	test   rax,0x1
    236f:	je     237d <botlish_fn_21+0x26d>
    2375:	mov    rsi,rax
    2378:	jmp    23a1 <botlish_fn_21+0x291>
    237d:	xor    ecx,ecx
    237f:	test   rax,0x7
    2385:	je     2393 <botlish_fn_21+0x283>
    238b:	mov    rsi,rax
    238e:	jmp    23a1 <botlish_fn_21+0x291>
    2393:	movzx  rcx,BYTE PTR [rax]
    2397:	mov    rsi,rax
    239a:	rex cmp cl,0x1
    239e:	sete   cl
    23a1:	test   cl,cl
    23a3:	jne    23c0 <botlish_fn_21+0x2b0>
    23a9:	mov    rdi,r13
    23ac:	mov    rax,QWORD PTR [rdi+0x10]
    23b0:	mov    rcx,QWORD PTR [rax]
    23b3:	xor    rdx,rdx
    23b6:	call   23bb <botlish_fn_21+0x2ab>
			23b7: R_X86_64_PLT32	rt_type_error-0x4
    23bb:	jmp    2408 <botlish_fn_21+0x2f8>
    23c0:	test   rsi,0x1
    23c7:	je     23df <botlish_fn_21+0x2cf>
    23cd:	mov    rcx,rsi
    23d0:	add    rcx,0x2
    23d4:	seto   al
    23d7:	test   al,al
    23d9:	je     23ef <botlish_fn_21+0x2df>
    23df:	mov    edx,0x3
    23e4:	mov    rdi,r13
    23e7:	call   23ec <botlish_fn_21+0x2dc>
			23e8: R_X86_64_PLT32	rt_int_add-0x4
    23ec:	mov    rcx,rax
    23ef:	mov    edx,0x3
    23f4:	mov    rsi,r14
    23f7:	mov    rdi,r13
    23fa:	call   23ff <botlish_fn_21+0x2ef>
			23fb: R_X86_64_PLT32	rt_mutarray_set-0x4
    23ff:	test   rax,rax
    2402:	jne    2428 <botlish_fn_21+0x318>
    2408:	xor    rax,rax
    240b:	mov    rbx,QWORD PTR [rsp+0x30]
    2410:	mov    r12,QWORD PTR [rsp+0x38]
    2415:	mov    r13,QWORD PTR [rsp+0x40]
    241a:	mov    r14,QWORD PTR [rsp+0x48]
    241f:	add    rsp,0x50
    2423:	mov    rsp,rbp
    2426:	pop    rbp
    2427:	ret
    2428:	mov    rax,r12
    242b:	mov    rbx,QWORD PTR [rsp+0x30]
    2430:	mov    r12,QWORD PTR [rsp+0x38]
    2435:	mov    r13,QWORD PTR [rsp+0x40]
    243a:	mov    r14,QWORD PTR [rsp+0x48]
    243f:	add    rsp,0x50
    2443:	mov    rsp,rbp
    2446:	pop    rbp
    2447:	ret
    2448:	mov    rax,rbx
    244b:	mov    rbx,QWORD PTR [rsp+0x30]
    2450:	mov    r12,QWORD PTR [rsp+0x38]
    2455:	mov    r13,QWORD PTR [rsp+0x40]
    245a:	mov    r14,QWORD PTR [rsp+0x48]
    245f:	add    rsp,0x50
    2463:	mov    rsp,rbp
    2466:	pop    rbp
    2467:	ret
    2468:	(bad)
    2469:	add    BYTE PTR [rax],al
    246b:	add    BYTE PTR [rax],al
    246d:	add    BYTE PTR [rax],al
	...

0000000000002470 <botlish_entry_21: ht_delete<HashTable, str>>:
    2470:	push   rbp
    2471:	mov    rbp,rsp
    2474:	mov    rsi,QWORD PTR [rdx]
    2477:	mov    rdx,QWORD PTR [rdx+0x8]
    247b:	call   2480 <botlish_entry_21+0x10>
			247c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2480:	mov    rsp,rbp
    2483:	pop    rbp
    2484:	ret
    2485:	add    BYTE PTR [rax],al
	...

0000000000002488 <botlish_fn_22: sample_checks<generic>>:
    2488:	push   rbp
    2489:	mov    rbp,rsp
    248c:	sub    rsp,0xa0
    2493:	mov    QWORD PTR [rsp+0x70],rbx
    2498:	mov    QWORD PTR [rsp+0x78],r12
    249d:	mov    QWORD PTR [rsp+0x80],r13
    24a5:	mov    QWORD PTR [rsp+0x88],r14
    24ad:	mov    QWORD PTR [rsp+0x90],r15
    24b5:	mov    r13,rdi
    24b8:	mov    QWORD PTR [rsp],0x0
    24c0:	mov    QWORD PTR [rsp+0x8],0x0
    24c9:	mov    QWORD PTR [rsp+0x10],0x0
    24d2:	mov    QWORD PTR [rsp+0x18],0x0
    24db:	mov    QWORD PTR [rsp+0x20],0x0
    24e4:	mov    QWORD PTR [rsp+0x28],0x0
    24ed:	mov    rdi,r13
    24f0:	call   24f5 <botlish_fn_22+0x6d>
			24f1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    24f5:	test   rax,rax
    24f8:	je     2754 <botlish_fn_22+0x2cc>
    24fe:	mov    QWORD PTR [rsp],rax
    2502:	mov    rsi,rax
    2505:	mov    rdi,r13
    2508:	mov    rax,QWORD PTR [rdi+0x10]
    250c:	mov    rdx,QWORD PTR [rax+0x18]
    2510:	mov    QWORD PTR [rsp+0x8],rdx
    2515:	mov    rax,QWORD PTR [rdi+0x10]
    2519:	mov    rcx,QWORD PTR [rax+0x20]
    251d:	mov    QWORD PTR [rsp+0x10],rcx
    2522:	call   2527 <botlish_fn_22+0x9f>
			2523: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2527:	test   rax,rax
    252a:	je     2754 <botlish_fn_22+0x2cc>
    2530:	mov    QWORD PTR [rsp],rax
    2534:	mov    rdi,r13
    2537:	mov    rsi,QWORD PTR [rdi+0x10]
    253b:	mov    rdx,QWORD PTR [rsi+0x28]
    253f:	mov    QWORD PTR [rsp+0x8],rdx
    2544:	mov    rsi,QWORD PTR [rdi+0x10]
    2548:	mov    rcx,QWORD PTR [rsi+0x30]
    254c:	mov    QWORD PTR [rsp+0x10],rcx
    2551:	mov    rsi,rax
    2554:	call   2559 <botlish_fn_22+0xd1>
			2555: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2559:	test   rax,rax
    255c:	je     2754 <botlish_fn_22+0x2cc>
    2562:	mov    QWORD PTR [rsp],rax
    2566:	mov    rsi,rax
    2569:	mov    rdi,r13
    256c:	mov    r11,QWORD PTR [rdi+0x10]
    2570:	mov    rdx,QWORD PTR [r11+0x18]
    2574:	mov    QWORD PTR [rsp+0x8],rdx
    2579:	mov    rax,QWORD PTR [rdi+0x10]
    257d:	mov    rcx,QWORD PTR [rax+0x38]
    2581:	mov    QWORD PTR [rsp+0x10],rcx
    2586:	call   258b <botlish_fn_22+0x103>
			2587: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    258b:	test   rax,rax
    258e:	je     2754 <botlish_fn_22+0x2cc>
    2594:	mov    QWORD PTR [rsp],rax
    2598:	mov    rdi,r13
    259b:	mov    r14,rax
    259e:	mov    rax,QWORD PTR [rdi+0x10]
    25a2:	mov    rdx,QWORD PTR [rax+0x28]
    25a6:	mov    QWORD PTR [rsp+0x8],rdx
    25ab:	mov    rsi,r14
    25ae:	call   25b3 <botlish_fn_22+0x12b>
			25af: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    25b3:	test   rax,rax
    25b6:	je     2754 <botlish_fn_22+0x2cc>
    25bc:	mov    QWORD PTR [rsp+0x8],rax
    25c1:	mov    rdi,r13
    25c4:	mov    r15,rax
    25c7:	mov    rax,QWORD PTR [rdi+0x10]
    25cb:	mov    rdx,QWORD PTR [rax+0x28]
    25cf:	mov    QWORD PTR [rsp+0x10],rdx
    25d4:	mov    rsi,r14
    25d7:	call   25dc <botlish_fn_22+0x154>
			25d8: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    25dc:	mov    rcx,rax
    25df:	mov    r14,rax
    25e2:	test   rax,rcx
    25e5:	je     2754 <botlish_fn_22+0x2cc>
    25eb:	mov    rax,r14
    25ee:	mov    QWORD PTR [rsp],rax
    25f2:	mov    rdi,r13
    25f5:	mov    rax,QWORD PTR [rdi+0x10]
    25f9:	mov    rdx,QWORD PTR [rax+0x18]
    25fd:	mov    QWORD PTR [rsp+0x10],rdx
    2602:	mov    rsi,r14
    2605:	call   260a <botlish_fn_22+0x182>
			2606: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    260a:	test   rax,rax
    260d:	je     2754 <botlish_fn_22+0x2cc>
    2613:	mov    rdi,r13
    2616:	mov    rcx,QWORD PTR [rdi+0x10]
    261a:	mov    rdx,QWORD PTR [rcx+0x38]
    261e:	mov    rcx,rax
    2621:	and    rcx,rdx
    2624:	mov    rsi,rax
    2627:	test   rcx,0x1
    262e:	jne    264a <botlish_fn_22+0x1c2>
    2634:	mov    rdi,r13
    2637:	call   263c <botlish_fn_22+0x1b4>
			2638: R_X86_64_PLT32	rt_value_eq-0x4
    263c:	test   rax,rax
    263f:	je     2754 <botlish_fn_22+0x2cc>
    2645:	jmp    265a <botlish_fn_22+0x1d2>
    264a:	mov    eax,0x2
    264f:	cmp    rsi,rdx
    2652:	cmove  rax,QWORD PTR [rip+0x15e]        # 27b8 <botlish_fn_22+0x330>
    265a:	mov    QWORD PTR [rsp+0x10],rax
    265f:	mov    rdi,r13
    2662:	mov    QWORD PTR [rsp+0x60],rax
    2667:	mov    rax,QWORD PTR [rdi+0x10]
    266b:	mov    rdx,QWORD PTR [rax+0x28]
    266f:	mov    QWORD PTR [rsp+0x18],rdx
    2674:	mov    rsi,r14
    2677:	call   267c <botlish_fn_22+0x1f4>
			2678: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    267c:	mov    rbx,rax
    267f:	test   rbx,rbx
    2682:	je     2754 <botlish_fn_22+0x2cc>
    2688:	mov    QWORD PTR [rsp+0x18],rbx
    268d:	mov    rdi,r13
    2690:	mov    rax,QWORD PTR [rdi+0x10]
    2694:	mov    rdx,QWORD PTR [rax+0x40]
    2698:	mov    QWORD PTR [rsp+0x20],rdx
    269d:	mov    rsi,r14
    26a0:	call   26a5 <botlish_fn_22+0x21d>
			26a1: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    26a5:	mov    r12,rax
    26a8:	test   r12,r12
    26ab:	je     2754 <botlish_fn_22+0x2cc>
    26b1:	mov    QWORD PTR [rsp+0x20],r12
    26b6:	mov    rdi,r13
    26b9:	mov    rax,QWORD PTR [rdi+0x10]
    26bd:	mov    rdx,QWORD PTR [rax+0x40]
    26c1:	mov    QWORD PTR [rsp+0x28],rdx
    26c6:	mov    rsi,r14
    26c9:	call   26ce <botlish_fn_22+0x246>
			26ca: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    26ce:	test   rax,rax
    26d1:	mov    rsi,rax
    26d4:	je     2754 <botlish_fn_22+0x2cc>
    26da:	mov    edx,0xa
    26df:	mov    rdi,r13
    26e2:	call   26e7 <botlish_fn_22+0x25f>
			26e3: R_X86_64_PLT32	rt_value_eq-0x4
    26e7:	test   rax,rax
    26ea:	je     2754 <botlish_fn_22+0x2cc>
    26f0:	mov    QWORD PTR [rsp],rax
    26f4:	mov    rsi,r14
    26f7:	mov    r14,rax
    26fa:	mov    rdi,r13
    26fd:	call   2702 <botlish_fn_22+0x27a>
			26fe: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2702:	test   rax,rax
    2705:	je     2754 <botlish_fn_22+0x2cc>
    270b:	mov    QWORD PTR [rsp+0x28],rax
    2710:	lea    rdx,[rsp+0x30]
    2715:	mov    r9,QWORD PTR [rsp+0x60]
    271a:	mov    QWORD PTR [rsp+0x30],r9
    271f:	mov    rsi,r15
    2722:	mov    QWORD PTR [rsp+0x38],rsi
    2727:	mov    QWORD PTR [rsp+0x40],rbx
    272c:	mov    QWORD PTR [rsp+0x48],r12
    2731:	mov    rcx,r14
    2734:	mov    QWORD PTR [rsp+0x50],rcx
    2739:	mov    QWORD PTR [rsp+0x58],rax
    273e:	mov    esi,0x6
    2743:	mov    rdi,r13
    2746:	call   274b <botlish_fn_22+0x2c3>
			2747: R_X86_64_PLT32	rt_list_new-0x4
    274b:	test   rax,rax
    274e:	jne    2785 <botlish_fn_22+0x2fd>
    2754:	xor    rax,rax
    2757:	mov    rbx,QWORD PTR [rsp+0x70]
    275c:	mov    r12,QWORD PTR [rsp+0x78]
    2761:	mov    r13,QWORD PTR [rsp+0x80]
    2769:	mov    r14,QWORD PTR [rsp+0x88]
    2771:	mov    r15,QWORD PTR [rsp+0x90]
    2779:	add    rsp,0xa0
    2780:	mov    rsp,rbp
    2783:	pop    rbp
    2784:	ret
    2785:	mov    rbx,QWORD PTR [rsp+0x70]
    278a:	mov    r12,QWORD PTR [rsp+0x78]
    278f:	mov    r13,QWORD PTR [rsp+0x80]
    2797:	mov    r14,QWORD PTR [rsp+0x88]
    279f:	mov    r15,QWORD PTR [rsp+0x90]
    27a7:	add    rsp,0xa0
    27ae:	mov    rsp,rbp
    27b1:	pop    rbp
    27b2:	ret
    27b3:	add    BYTE PTR [rax],al
    27b5:	add    BYTE PTR [rax],al
    27b7:	add    BYTE PTR [rsi],al
    27b9:	add    BYTE PTR [rax],al
    27bb:	add    BYTE PTR [rax],al
    27bd:	add    BYTE PTR [rax],al
	...

00000000000027c0 <botlish_entry_22: sample_checks<generic>>:
    27c0:	push   rbp
    27c1:	mov    rbp,rsp
    27c4:	call   27c9 <botlish_entry_22+0x9>
			27c5: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27c9:	mov    rsp,rbp
    27cc:	pop    rbp
    27cd:	ret

00000000000027ce <botlish_fn_23: sample<generic>>:
    27ce:	push   rbp
    27cf:	mov    rbp,rsp
    27d2:	sub    rsp,0x10
    27d6:	mov    QWORD PTR [rsp],r12
    27da:	mov    r12,rdi
    27dd:	mov    rdi,r12
    27e0:	call   27e5 <botlish_fn_23+0x17>
			27e1: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27e5:	test   rax,rax
    27e8:	jne    2831 <botlish_fn_23+0x63>
    27ee:	mov    rdi,r12
    27f1:	call   27f6 <botlish_fn_23+0x28>
			27f2: R_X86_64_PLT32	rt_declared_error-0x4
    27f6:	cmp    rax,0x40000001
    27fc:	jne    2821 <botlish_fn_23+0x53>
    2802:	mov    rdi,r12
    2805:	call   280a <botlish_fn_23+0x3c>
			2806: R_X86_64_PLT32	rt_clear_declared_error-0x4
    280a:	xor    rdx,rdx
    280d:	mov    rdi,r12
    2810:	mov    rsi,rdx
    2813:	call   2818 <botlish_fn_23+0x4a>
			2814: R_X86_64_PLT32	rt_list_new-0x4
    2818:	test   rax,rax
    281b:	jne    2831 <botlish_fn_23+0x63>
    2821:	xor    rax,rax
    2824:	mov    r12,QWORD PTR [rsp]
    2828:	add    rsp,0x10
    282c:	mov    rsp,rbp
    282f:	pop    rbp
    2830:	ret
    2831:	mov    r12,QWORD PTR [rsp]
    2835:	add    rsp,0x10
    2839:	mov    rsp,rbp
    283c:	pop    rbp
    283d:	ret

000000000000283e <botlish_entry_23: sample<generic>>:
    283e:	push   rbp
    283f:	mov    rbp,rsp
    2842:	call   2847 <botlish_entry_23+0x9>
			2843: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    2847:	mov    rsp,rbp
    284a:	pop    rbp
    284b:	ret

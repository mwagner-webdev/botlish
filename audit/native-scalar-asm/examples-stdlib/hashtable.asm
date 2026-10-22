; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12723  (per function: 45 489 446 70 103 105 44 231 243 692 1096 381 237 588 730 784 723 801 673 1304 780 1181 830 147)
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
      83:	mov    rbx,rax
      86:	test   rax,rcx
      89:	je     122 <botlish_fn_1+0xf5>
      8f:	mov    rax,rbx
      92:	mov    QWORD PTR [rsp+0x8],rax
      97:	mov    rcx,QWORD PTR [rax+0x18]
      9b:	test   rcx,rcx
      9e:	je     19f <botlish_fn_1+0x172>
      a4:	mov    rcx,QWORD PTR [rbx+0x10]
      a8:	mov    QWORD PTR [rcx],0x1
      af:	mov    rcx,QWORD PTR [rbx+0x18]
      b3:	test   rcx,rcx
      b6:	je     1b7 <botlish_fn_1+0x18a>
      bc:	mov    rax,QWORD PTR [rbx+0x10]
      c0:	mov    QWORD PTR [rax+0x8],0x1
      c8:	mov    edx,0x1
      cd:	mov    QWORD PTR [rsp+0x10],0x1
      d6:	mov    rsi,r13
      d9:	mov    rdi,r12
      dc:	call   e1 <botlish_fn_1+0xb4>
			dd: R_X86_64_PLT32	rt_mutarray_create-0x4
      e1:	test   rax,rax
      e4:	je     122 <botlish_fn_1+0xf5>
      ea:	mov    QWORD PTR [rsp+0x10],rax
      ef:	mov    r14,rax
      f2:	mov    rsi,r13
      f5:	mov    rdi,r12
      f8:	call   fd <botlish_fn_1+0xd0>
			f9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      fd:	test   rax,rax
     100:	je     122 <botlish_fn_1+0xf5>
     106:	mov    QWORD PTR [rsp+0x18],rax
     10b:	mov    rsi,r13
     10e:	mov    r15,rax
     111:	mov    rdi,r12
     114:	call   119 <botlish_fn_1+0xec>
			115: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     119:	test   rax,rax
     11c:	jne    147 <botlish_fn_1+0x11a>
     122:	xor    rax,rax
     125:	mov    rbx,QWORD PTR [rsp+0x40]
     12a:	mov    r12,QWORD PTR [rsp+0x48]
     12f:	mov    r13,QWORD PTR [rsp+0x50]
     134:	mov    r14,QWORD PTR [rsp+0x58]
     139:	mov    r15,QWORD PTR [rsp+0x60]
     13e:	add    rsp,0x70
     142:	mov    rsp,rbp
     145:	pop    rbp
     146:	ret
     147:	mov    QWORD PTR [rsp],rax
     14b:	lea    rcx,[rsp+0x20]
     150:	mov    rdx,r14
     153:	mov    QWORD PTR [rsp+0x20],rdx
     158:	mov    rdx,r15
     15b:	mov    QWORD PTR [rsp+0x28],rdx
     160:	mov    QWORD PTR [rsp+0x30],rax
     165:	mov    rax,rbx
     168:	mov    QWORD PTR [rsp+0x38],rax
     16d:	xor    rsi,rsi
     170:	mov    edx,0x4
     175:	mov    rdi,r12
     178:	call   17d <botlish_fn_1+0x150>
			179: R_X86_64_PLT32	rt_struct_new-0x4
     17d:	mov    rbx,QWORD PTR [rsp+0x40]
     182:	mov    r12,QWORD PTR [rsp+0x48]
     187:	mov    r13,QWORD PTR [rsp+0x50]
     18c:	mov    r14,QWORD PTR [rsp+0x58]
     191:	mov    r15,QWORD PTR [rsp+0x60]
     196:	add    rsp,0x70
     19a:	mov    rsp,rbp
     19d:	pop    rbp
     19e:	ret
     19f:	mov    ecx,0x1
     1a4:	mov    rsi,rbx
     1a7:	mov    rdi,r12
     1aa:	mov    rdx,rcx
     1ad:	call   1b2 <botlish_fn_1+0x185>
			1ae: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     1b2:	jmp    af <botlish_fn_1+0x82>
     1b7:	mov    edx,0x3
     1bc:	mov    ecx,0x1
     1c1:	mov    rsi,rbx
     1c4:	mov    rdi,r12
     1c7:	call   1cc <botlish_fn_1+0x19f>
			1c8: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     1cc:	jmp    c8 <botlish_fn_1+0x9b>

00000000000001d1 <botlish_entry_1: ht_alloc<int>>:
     1d1:	push   rbp
     1d2:	mov    rbp,rsp
     1d5:	mov    rsi,QWORD PTR [rdx]
     1d8:	call   1dd <botlish_entry_1+0xc>
			1d9: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     1dd:	mov    rsp,rbp
     1e0:	pop    rbp
     1e1:	ret

00000000000001e2 <botlish_fn_2: ht_alloc<int>>:
     1e2:	push   rbp
     1e3:	mov    rbp,rsp
     1e6:	sub    rsp,0x60
     1ea:	mov    QWORD PTR [rsp+0x30],rbx
     1ef:	mov    QWORD PTR [rsp+0x38],r12
     1f4:	mov    QWORD PTR [rsp+0x40],r13
     1f9:	mov    QWORD PTR [rsp+0x48],r14
     1fe:	mov    QWORD PTR [rsp+0x50],r15
     203:	mov    r12,rdx
     206:	mov    r14,rdi
     209:	mov    QWORD PTR [rsp+0x10],0x0
     212:	mov    QWORD PTR [rsp+0x18],0x0
     21b:	mov    QWORD PTR [rsp],rsi
     21f:	mov    r13,rsi
     222:	mov    esi,0x5
     227:	mov    QWORD PTR [rsp+0x8],0x5
     230:	mov    rdi,r14
     233:	call   238 <botlish_fn_2+0x56>
			234: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     238:	mov    rcx,rax
     23b:	mov    rbx,rax
     23e:	test   rax,rcx
     241:	je     2dc <botlish_fn_2+0xfa>
     247:	mov    rax,rbx
     24a:	mov    QWORD PTR [rsp+0x8],rax
     24f:	mov    rcx,QWORD PTR [rax+0x18]
     253:	test   rcx,rcx
     256:	je     33c <botlish_fn_2+0x15a>
     25c:	mov    rcx,QWORD PTR [rbx+0x10]
     260:	mov    QWORD PTR [rcx],0x1
     267:	mov    rcx,QWORD PTR [rbx+0x18]
     26b:	test   rcx,rcx
     26e:	je     354 <botlish_fn_2+0x172>
     274:	mov    rax,QWORD PTR [rbx+0x10]
     278:	mov    QWORD PTR [rax+0x8],0x1
     280:	mov    edx,0x1
     285:	mov    QWORD PTR [rsp+0x10],0x1
     28e:	mov    rsi,r13
     291:	mov    rdi,r14
     294:	call   299 <botlish_fn_2+0xb7>
			295: R_X86_64_PLT32	rt_mutarray_create-0x4
     299:	test   rax,rax
     29c:	je     2dc <botlish_fn_2+0xfa>
     2a2:	mov    QWORD PTR [rsp+0x10],rax
     2a7:	mov    r15,rax
     2aa:	mov    rsi,r13
     2ad:	mov    rdi,r14
     2b0:	call   2b5 <botlish_fn_2+0xd3>
			2b1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2b5:	test   rax,rax
     2b8:	je     2dc <botlish_fn_2+0xfa>
     2be:	mov    QWORD PTR [rsp+0x18],rax
     2c3:	mov    rsi,r13
     2c6:	mov    rdi,r14
     2c9:	mov    QWORD PTR [rsp+0x20],rax
     2ce:	call   2d3 <botlish_fn_2+0xf1>
			2cf: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2d3:	test   rax,rax
     2d6:	jne    301 <botlish_fn_2+0x11f>
     2dc:	xor    rax,rax
     2df:	mov    rbx,QWORD PTR [rsp+0x30]
     2e4:	mov    r12,QWORD PTR [rsp+0x38]
     2e9:	mov    r13,QWORD PTR [rsp+0x40]
     2ee:	mov    r14,QWORD PTR [rsp+0x48]
     2f3:	mov    r15,QWORD PTR [rsp+0x50]
     2f8:	add    rsp,0x60
     2fc:	mov    rsp,rbp
     2ff:	pop    rbp
     300:	ret
     301:	mov    rcx,QWORD PTR [rsp+0x20]
     306:	mov    rdx,r12
     309:	mov    QWORD PTR [rdx],rcx
     30c:	mov    QWORD PTR [rdx+0x8],rax
     310:	mov    rax,rbx
     313:	mov    QWORD PTR [rdx+0x10],rax
     317:	mov    rax,r15
     31a:	mov    rbx,QWORD PTR [rsp+0x30]
     31f:	mov    r12,QWORD PTR [rsp+0x38]
     324:	mov    r13,QWORD PTR [rsp+0x40]
     329:	mov    r14,QWORD PTR [rsp+0x48]
     32e:	mov    r15,QWORD PTR [rsp+0x50]
     333:	add    rsp,0x60
     337:	mov    rsp,rbp
     33a:	pop    rbp
     33b:	ret
     33c:	mov    ecx,0x1
     341:	mov    rsi,rbx
     344:	mov    rdi,r14
     347:	mov    rdx,rcx
     34a:	call   34f <botlish_fn_2+0x16d>
			34b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     34f:	jmp    267 <botlish_fn_2+0x85>
     354:	mov    edx,0x3
     359:	mov    ecx,0x1
     35e:	mov    rsi,rbx
     361:	mov    rdi,r14
     364:	call   369 <botlish_fn_2+0x187>
			365: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     369:	jmp    280 <botlish_fn_2+0x9e>

000000000000036e <botlish_entry_2: ht_alloc<int>>:
     36e:	push   rbp
     36f:	mov    rbp,rsp
     372:	ud2

0000000000000374 <botlish_fn_3: ht_new<generic>>:
     374:	push   rbp
     375:	mov    rbp,rsp
     378:	sub    rsp,0x10
     37c:	mov    esi,0x11
     381:	mov    QWORD PTR [rsp],0x11
     389:	call   38e <botlish_fn_3+0x1a>
			38a: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     38e:	test   rax,rax
     391:	jne    3a3 <botlish_fn_3+0x2f>
     397:	xor    rax,rax
     39a:	add    rsp,0x10
     39e:	mov    rsp,rbp
     3a1:	pop    rbp
     3a2:	ret
     3a3:	add    rsp,0x10
     3a7:	mov    rsp,rbp
     3aa:	pop    rbp
     3ab:	ret

00000000000003ac <botlish_entry_3: ht_new<generic>>:
     3ac:	push   rbp
     3ad:	mov    rbp,rsp
     3b0:	call   3b5 <botlish_entry_3+0x9>
			3b1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
     3b5:	mov    rsp,rbp
     3b8:	pop    rbp
     3b9:	ret

00000000000003ba <botlish_fn_4: ht_size<HashTable>>:
     3ba:	push   rbp
     3bb:	mov    rbp,rsp
     3be:	mov    rax,QWORD PTR [rsi+0x18]
     3c2:	mov    rsi,QWORD PTR [rax+0x18]
     3c6:	mov    rax,QWORD PTR [rsi+0x8]
     3ca:	test   rax,rax
     3cd:	jne    3e5 <botlish_fn_4+0x2b>
     3d3:	jmp    3f1 <botlish_fn_4+0x37>
     3d8:	xor    rax,rax
     3db:	mov    rsp,rbp
     3de:	pop    rbp
     3df:	ret
     3e0:	jmp    3ec <botlish_fn_4+0x32>
     3e5:	mov    rax,QWORD PTR [rsi+0x10]
     3e9:	mov    rax,QWORD PTR [rax]
     3ec:	mov    rsp,rbp
     3ef:	pop    rbp
     3f0:	ret
     3f1:	mov    edx,0x1
     3f6:	call   3fb <botlish_fn_4+0x41>
			3f7: R_X86_64_PLT32	rt_mutarray_get-0x4
     3fb:	test   rax,rax
     3fe:	jne    3ec <botlish_fn_4+0x32>
     404:	jmp    3d8 <botlish_fn_4+0x1e>

0000000000000409 <botlish_entry_4: ht_size<HashTable>>:
     409:	push   rbp
     40a:	mov    rbp,rsp
     40d:	mov    rsi,QWORD PTR [rdx]
     410:	call   415 <botlish_entry_4+0xc>
			411: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
     415:	mov    rsp,rbp
     418:	pop    rbp
     419:	ret

000000000000041a <botlish_fn_5: ht_tombstones<HashTable>>:
     41a:	push   rbp
     41b:	mov    rbp,rsp
     41e:	mov    rax,QWORD PTR [rsi+0x18]
     422:	mov    rsi,QWORD PTR [rax+0x18]
     426:	mov    rax,QWORD PTR [rsi+0x8]
     42a:	cmp    rax,0x1
     42e:	ja     446 <botlish_fn_5+0x2c>
     434:	jmp    453 <botlish_fn_5+0x39>
     439:	xor    rax,rax
     43c:	mov    rsp,rbp
     43f:	pop    rbp
     440:	ret
     441:	jmp    44e <botlish_fn_5+0x34>
     446:	mov    rax,QWORD PTR [rsi+0x10]
     44a:	mov    rax,QWORD PTR [rax+0x8]
     44e:	mov    rsp,rbp
     451:	pop    rbp
     452:	ret
     453:	mov    edx,0x3
     458:	call   45d <botlish_fn_5+0x43>
			459: R_X86_64_PLT32	rt_mutarray_get-0x4
     45d:	test   rax,rax
     460:	jne    44e <botlish_fn_5+0x34>
     466:	jmp    439 <botlish_fn_5+0x1f>

000000000000046b <botlish_entry_5: ht_tombstones<HashTable>>:
     46b:	push   rbp
     46c:	mov    rbp,rsp
     46f:	mov    rsi,QWORD PTR [rdx]
     472:	call   477 <botlish_entry_5+0xc>
			473: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
     477:	mov    rsp,rbp
     47a:	pop    rbp
     47b:	ret

000000000000047c <botlish_fn_6: ht_capacity<HashTable>>:
     47c:	push   rbp
     47d:	mov    rbp,rsp
     480:	mov    rdi,QWORD PTR [rsi+0x18]
     484:	mov    rdi,QWORD PTR [rdi]
     487:	mov    rax,QWORD PTR [rdi+0x8]
     48b:	shl    rax,1
     48e:	or     rax,0x1
     492:	mov    rsp,rbp
     495:	pop    rbp
     496:	ret

0000000000000497 <botlish_entry_6: ht_capacity<HashTable>>:
     497:	push   rbp
     498:	mov    rbp,rsp
     49b:	mov    rsi,QWORD PTR [rdx]
     49e:	call   4a3 <botlish_entry_6+0xc>
			49f: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     4a3:	mov    rsp,rbp
     4a6:	pop    rbp
     4a7:	ret

00000000000004a8 <botlish_fn_7: ht_probe_start<HashTable, str>>:
     4a8:	push   rbp
     4a9:	mov    rbp,rsp
     4ac:	sub    rsp,0x10
     4b0:	mov    QWORD PTR [rsp],rbx
     4b4:	mov    QWORD PTR [rsp+0x8],r12
     4b9:	mov    rbx,rdi
     4bc:	mov    r12,rsi
     4bf:	mov    rsi,rdx
     4c2:	mov    rdi,rbx
     4c5:	call   4ca <botlish_fn_7+0x22>
			4c6: R_X86_64_PLT32	rt_hash-0x4
     4ca:	mov    rsi,r12
     4cd:	mov    r12,rax
     4d0:	mov    rdi,rbx
     4d3:	call   4d8 <botlish_fn_7+0x30>
			4d4: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     4d8:	sar    rax,1
     4db:	test   rax,rax
     4de:	mov    rcx,rax
     4e1:	jne    501 <botlish_fn_7+0x59>
     4e7:	jmp    550 <botlish_fn_7+0xa8>
     4ec:	xor    rax,rax
     4ef:	mov    rbx,QWORD PTR [rsp]
     4f3:	mov    r12,QWORD PTR [rsp+0x8]
     4f8:	add    rsp,0x10
     4fc:	mov    rsp,rbp
     4ff:	pop    rbp
     500:	ret
     501:	mov    rax,r12
     504:	sar    rax,1
     507:	cqo
     509:	cmp    rcx,0xffffffffffffffff
     50d:	jne    51d <botlish_fn_7+0x75>
     513:	mov    edx,0x0
     518:	jmp    520 <botlish_fn_7+0x78>
     51d:	idiv   rcx
     520:	mov    rax,rcx
     523:	neg    rax
     526:	cmovs  rax,rcx
     52a:	add    rax,rdx
     52d:	test   rdx,rdx
     530:	cmovl  rdx,rax
     534:	shl    rdx,1
     537:	mov    rax,rdx
     53a:	or     rax,0x1
     53e:	mov    rbx,QWORD PTR [rsp]
     542:	mov    r12,QWORD PTR [rsp+0x8]
     547:	add    rsp,0x10
     54b:	mov    rsp,rbp
     54e:	pop    rbp
     54f:	ret
     550:	mov    edx,0x1
     555:	mov    rax,r12
     558:	mov    rsi,rax
     55b:	or     rsi,0x1
     55f:	mov    rdi,rbx
     562:	call   567 <botlish_fn_7+0xbf>
			563: R_X86_64_PLT32	rt_int_mod-0x4
     567:	jmp    4ec <botlish_fn_7+0x44>

000000000000056c <botlish_entry_7: ht_probe_start<HashTable, str>>:
     56c:	push   rbp
     56d:	mov    rbp,rsp
     570:	mov    rsi,QWORD PTR [rdx]
     573:	mov    rdx,QWORD PTR [rdx+0x8]
     577:	call   57c <botlish_entry_7+0x10>
			578: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     57c:	mov    rsp,rbp
     57f:	pop    rbp
     580:	ret

0000000000000581 <botlish_fn_8: ht_probe_next<HashTable, int>>:
     581:	push   rbp
     582:	mov    rbp,rsp
     585:	sub    rsp,0x10
     589:	mov    QWORD PTR [rsp],rbx
     58d:	mov    QWORD PTR [rsp+0x8],r12
     592:	mov    rbx,rdi
     595:	mov    r12,rdx
     598:	mov    rdi,rbx
     59b:	call   5a0 <botlish_fn_8+0x1f>
			59c: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     5a0:	sar    rax,1
     5a3:	test   rax,rax
     5a6:	mov    rsi,rax
     5a9:	jne    5cc <botlish_fn_8+0x4b>
     5af:	jmp    621 <botlish_fn_8+0xa0>
     5b4:	xor    rdx,rdx
     5b7:	mov    rax,rdx
     5ba:	mov    rbx,QWORD PTR [rsp]
     5be:	mov    r12,QWORD PTR [rsp+0x8]
     5c3:	add    rsp,0x10
     5c7:	mov    rsp,rbp
     5ca:	pop    rbp
     5cb:	ret
     5cc:	mov    rax,r12
     5cf:	mov    ecx,0x1
     5d4:	add    rax,0x1
     5db:	cqo
     5dd:	cmp    rsi,0xffffffffffffffff
     5e1:	jne    5f1 <botlish_fn_8+0x70>
     5e7:	mov    edx,0x0
     5ec:	jmp    5f4 <botlish_fn_8+0x73>
     5f1:	idiv   rsi
     5f4:	mov    rax,rsi
     5f7:	neg    rax
     5fa:	cmovs  rax,rsi
     5fe:	lea    rsi,[rdx+rax*1]
     602:	test   rdx,rdx
     605:	mov    rax,rdx
     608:	cmovl  rax,rsi
     60c:	mov    rdx,rcx
     60f:	mov    rbx,QWORD PTR [rsp]
     613:	mov    r12,QWORD PTR [rsp+0x8]
     618:	add    rsp,0x10
     61c:	mov    rsp,rbp
     61f:	pop    rbp
     620:	ret
     621:	mov    edx,0x1
     626:	mov    rax,r12
     629:	lea    rsi,[rax+0x1]
     62d:	shl    rsi,1
     630:	or     rsi,0x1
     634:	mov    rdi,rbx
     637:	call   63c <botlish_fn_8+0xbb>
			638: R_X86_64_PLT32	rt_int_mod-0x4
     63c:	jmp    5b4 <botlish_fn_8+0x33>

0000000000000641 <botlish_entry_8: ht_probe_next<HashTable, int>>:
     641:	push   rbp
     642:	mov    rbp,rsp
     645:	mov    rsi,QWORD PTR [rdx]
     648:	mov    rdx,QWORD PTR [rdx+0x8]
     64c:	sar    rdx,1
     64f:	call   654 <botlish_entry_8+0x13>
			650: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     654:	shl    rax,1
     657:	or     rax,0x1
     65b:	mov    rcx,rax
     65e:	xor    rax,rax
     661:	test   rdx,rdx
     664:	cmovne rax,rcx
     668:	mov    rsp,rbp
     66b:	pop    rbp
     66c:	ret
     66d:	add    BYTE PTR [rax],al
	...

0000000000000670 <botlish_fn_9: ht_find_get<HashTable, str, int>>:
     670:	push   rbp
     671:	mov    rbp,rsp
     674:	sub    rsp,0x30
     678:	mov    QWORD PTR [rsp],rbx
     67c:	mov    QWORD PTR [rsp+0x8],r12
     681:	mov    QWORD PTR [rsp+0x10],r13
     686:	mov    QWORD PTR [rsp+0x18],r14
     68b:	mov    QWORD PTR [rsp+0x20],r15
     690:	mov    rbx,rdx
     693:	mov    r13,rdi
     696:	sar    rcx,1
     699:	mov    rdi,rcx
     69c:	mov    r12,rsi
     69f:	mov    rax,QWORD PTR [r12+0x18]
     6a4:	mov    rsi,QWORD PTR [rax]
     6a7:	mov    rcx,QWORD PTR [rsi+0x8]
     6ab:	mov    rax,rdi
     6ae:	shl    rax,1
     6b1:	or     rax,0x1
     6b5:	sar    rax,1
     6b8:	cmp    rax,rcx
     6bb:	jb     6ce <botlish_fn_9+0x5e>
     6c1:	jmp    895 <botlish_fn_9+0x225>
     6c6:	mov    rsi,rax
     6c9:	jmp    6d9 <botlish_fn_9+0x69>
     6ce:	mov    r14,rdi
     6d1:	mov    rcx,QWORD PTR [rsi+0x10]
     6d5:	mov    rsi,QWORD PTR [rcx+rax*8]
     6d9:	test   rsi,0x1
     6e0:	mov    r15,rsi
     6e3:	jne    711 <botlish_fn_9+0xa1>
     6e9:	mov    edx,0x1
     6ee:	mov    rsi,r15
     6f1:	mov    rdi,r13
     6f4:	call   6f9 <botlish_fn_9+0x89>
			6f5: R_X86_64_PLT32	rt_int_cmp-0x4
     6f9:	mov    ecx,0x2
     6fe:	test   rax,rax
     701:	cmove  rcx,QWORD PTR [rip+0x1d7]        # 8e0 <botlish_fn_9+0x270>
     709:	mov    rsi,r15
     70c:	jmp    725 <botlish_fn_9+0xb5>
     711:	mov    ecx,0x2
     716:	mov    rsi,r15
     719:	cmp    rsi,0x1
     71d:	cmove  rcx,QWORD PTR [rip+0x1bb]        # 8e0 <botlish_fn_9+0x270>
     725:	cmp    rcx,0x6
     729:	je     86d <botlish_fn_9+0x1fd>
     72f:	test   rsi,0x1
     736:	jne    75e <botlish_fn_9+0xee>
     73c:	mov    edx,0x3
     741:	mov    rdi,r13
     744:	call   749 <botlish_fn_9+0xd9>
			745: R_X86_64_PLT32	rt_int_cmp-0x4
     749:	mov    ecx,0x2
     74e:	test   rax,rax
     751:	cmove  rcx,QWORD PTR [rip+0x187]        # 8e0 <botlish_fn_9+0x270>
     759:	jmp    76f <botlish_fn_9+0xff>
     75e:	mov    ecx,0x2
     763:	cmp    rsi,0x3
     767:	cmove  rcx,QWORD PTR [rip+0x171]        # 8e0 <botlish_fn_9+0x270>
     76f:	cmp    rcx,0x6
     773:	jne    7fc <botlish_fn_9+0x18c>
     779:	mov    rax,QWORD PTR [r12+0x18]
     77e:	mov    rsi,QWORD PTR [rax+0x8]
     782:	mov    rcx,QWORD PTR [rsi+0x8]
     786:	mov    rdi,r14
     789:	mov    rax,rdi
     78c:	shl    rax,1
     78f:	or     rax,0x1
     793:	sar    rax,1
     796:	cmp    rax,rcx
     799:	jb     7ac <botlish_fn_9+0x13c>
     79f:	jmp    8b8 <botlish_fn_9+0x248>
     7a4:	mov    rsi,rax
     7a7:	jmp    7b7 <botlish_fn_9+0x147>
     7ac:	mov    r14,rdi
     7af:	mov    rcx,QWORD PTR [rsi+0x10]
     7b3:	mov    rsi,QWORD PTR [rcx+rax*8]
     7b7:	mov    rax,rsi
     7ba:	and    rax,rbx
     7bd:	test   rax,0x1
     7c3:	jne    7e2 <botlish_fn_9+0x172>
     7c9:	mov    rdx,rbx
     7cc:	mov    rdi,r13
     7cf:	call   7d4 <botlish_fn_9+0x164>
			7d0: R_X86_64_PLT32	rt_value_eq-0x4
     7d4:	test   rax,rax
     7d7:	je     813 <botlish_fn_9+0x1a3>
     7dd:	jmp    7f2 <botlish_fn_9+0x182>
     7e2:	mov    eax,0x2
     7e7:	cmp    rsi,rbx
     7ea:	cmove  rax,QWORD PTR [rip+0xee]        # 8e0 <botlish_fn_9+0x270>
     7f2:	cmp    rax,0x6
     7f6:	je     83f <botlish_fn_9+0x1cf>
     7fc:	mov    rdx,r14
     7ff:	mov    rsi,r12
     802:	mov    rdi,r13
     805:	call   80a <botlish_fn_9+0x19a>
			806: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     80a:	test   rdx,rdx
     80d:	jne    837 <botlish_fn_9+0x1c7>
     813:	xor    rax,rax
     816:	mov    rbx,QWORD PTR [rsp]
     81a:	mov    r12,QWORD PTR [rsp+0x8]
     81f:	mov    r13,QWORD PTR [rsp+0x10]
     824:	mov    r14,QWORD PTR [rsp+0x18]
     829:	mov    r15,QWORD PTR [rsp+0x20]
     82e:	add    rsp,0x30
     832:	mov    rsp,rbp
     835:	pop    rbp
     836:	ret
     837:	mov    rdi,rax
     83a:	jmp    69f <botlish_fn_9+0x2f>
     83f:	mov    rdx,r14
     842:	shl    rdx,1
     845:	mov    rax,rdx
     848:	or     rax,0x1
     84c:	mov    rbx,QWORD PTR [rsp]
     850:	mov    r12,QWORD PTR [rsp+0x8]
     855:	mov    r13,QWORD PTR [rsp+0x10]
     85a:	mov    r14,QWORD PTR [rsp+0x18]
     85f:	mov    r15,QWORD PTR [rsp+0x20]
     864:	add    rsp,0x30
     868:	mov    rsp,rbp
     86b:	pop    rbp
     86c:	ret
     86d:	mov    rax,0xffffffffffffffff
     874:	mov    rbx,QWORD PTR [rsp]
     878:	mov    r12,QWORD PTR [rsp+0x8]
     87d:	mov    r13,QWORD PTR [rsp+0x10]
     882:	mov    r14,QWORD PTR [rsp+0x18]
     887:	mov    r15,QWORD PTR [rsp+0x20]
     88c:	add    rsp,0x30
     890:	mov    rsp,rbp
     893:	pop    rbp
     894:	ret
     895:	mov    rdx,rdi
     898:	shl    rdx,1
     89b:	mov    r14,rdi
     89e:	or     rdx,0x1
     8a2:	mov    rdi,r13
     8a5:	call   8aa <botlish_fn_9+0x23a>
			8a6: R_X86_64_PLT32	rt_mutarray_get-0x4
     8aa:	test   rax,rax
     8ad:	jne    6c6 <botlish_fn_9+0x56>
     8b3:	jmp    813 <botlish_fn_9+0x1a3>
     8b8:	mov    rdx,rdi
     8bb:	shl    rdx,1
     8be:	mov    r14,rdi
     8c1:	or     rdx,0x1
     8c5:	mov    rdi,r13
     8c8:	call   8cd <botlish_fn_9+0x25d>
			8c9: R_X86_64_PLT32	rt_mutarray_get-0x4
     8cd:	test   rax,rax
     8d0:	jne    7a4 <botlish_fn_9+0x134>
     8d6:	jmp    813 <botlish_fn_9+0x1a3>
     8db:	add    BYTE PTR [rax],al
     8dd:	add    BYTE PTR [rax],al
     8df:	add    BYTE PTR [rsi],al
     8e1:	add    BYTE PTR [rax],al
     8e3:	add    BYTE PTR [rax],al
     8e5:	add    BYTE PTR [rax],al
	...

00000000000008e8 <botlish_entry_9: ht_find_get<HashTable, str, int>>:
     8e8:	push   rbp
     8e9:	mov    rbp,rsp
     8ec:	mov    rsi,QWORD PTR [rdx]
     8ef:	mov    r8,QWORD PTR [rdx+0x8]
     8f3:	mov    rcx,QWORD PTR [rdx+0x10]
     8f7:	mov    rdx,r8
     8fa:	call   8ff <botlish_entry_9+0x17>
			8fb: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     8ff:	mov    rsp,rbp
     902:	pop    rbp
     903:	ret
     904:	add    BYTE PTR [rax],al
	...

0000000000000908 <botlish_fn_10: ht_find_insert<HashTable, str, int, int>>:
     908:	push   rbp
     909:	mov    rbp,rsp
     90c:	sub    rsp,0x40
     910:	mov    QWORD PTR [rsp+0x10],rbx
     915:	mov    QWORD PTR [rsp+0x18],r12
     91a:	mov    QWORD PTR [rsp+0x20],r13
     91f:	mov    QWORD PTR [rsp+0x28],r14
     924:	mov    QWORD PTR [rsp+0x30],r15
     929:	mov    r14,rdi
     92c:	mov    r15,rdx
     92f:	sar    rcx,1
     932:	mov    rbx,rsi
     935:	mov    r12,rcx
     938:	mov    r13,r8
     93b:	mov    rax,QWORD PTR [rbx+0x18]
     93f:	mov    rsi,QWORD PTR [rax]
     942:	mov    rdx,QWORD PTR [rsi+0x8]
     946:	mov    rcx,r12
     949:	shl    rcx,1
     94c:	or     rcx,0x1
     950:	sar    rcx,1
     953:	cmp    rcx,rdx
     956:	jb     969 <botlish_fn_10+0x61>
     95c:	jmp    ca9 <botlish_fn_10+0x3a1>
     961:	mov    rsi,rax
     964:	jmp    971 <botlish_fn_10+0x69>
     969:	mov    rax,QWORD PTR [rsi+0x10]
     96d:	mov    rsi,QWORD PTR [rax+rcx*8]
     971:	test   rsi,0x1
     978:	mov    QWORD PTR [rsp],rsi
     97c:	jne    9a8 <botlish_fn_10+0xa0>
     982:	mov    edx,0x1
     987:	mov    rsi,QWORD PTR [rsp]
     98b:	mov    rdi,r14
     98e:	call   993 <botlish_fn_10+0x8b>
			98f: R_X86_64_PLT32	rt_int_cmp-0x4
     993:	mov    ecx,0x2
     998:	test   rax,rax
     99b:	cmove  rcx,QWORD PTR [rip+0x34d]        # cf0 <botlish_fn_10+0x3e8>
     9a3:	jmp    9bd <botlish_fn_10+0xb5>
     9a8:	mov    ecx,0x2
     9ad:	mov    rsi,QWORD PTR [rsp]
     9b1:	cmp    rsi,0x1
     9b5:	cmove  rcx,QWORD PTR [rip+0x333]        # cf0 <botlish_fn_10+0x3e8>
     9bd:	cmp    rcx,0x6
     9c1:	je     bfd <botlish_fn_10+0x2f5>
     9c7:	mov    rsi,QWORD PTR [rsp]
     9cb:	test   rsi,0x1
     9d2:	jne    9fe <botlish_fn_10+0xf6>
     9d8:	mov    edx,0x3
     9dd:	mov    rsi,QWORD PTR [rsp]
     9e1:	mov    rdi,r14
     9e4:	call   9e9 <botlish_fn_10+0xe1>
			9e5: R_X86_64_PLT32	rt_int_cmp-0x4
     9e9:	mov    ecx,0x2
     9ee:	test   rax,rax
     9f1:	cmove  rcx,QWORD PTR [rip+0x2f7]        # cf0 <botlish_fn_10+0x3e8>
     9f9:	jmp    a13 <botlish_fn_10+0x10b>
     9fe:	mov    ecx,0x2
     a03:	mov    rsi,QWORD PTR [rsp]
     a07:	cmp    rsi,0x3
     a0b:	cmove  rcx,QWORD PTR [rip+0x2dd]        # cf0 <botlish_fn_10+0x3e8>
     a13:	cmp    rcx,0x6
     a17:	je     a2e <botlish_fn_10+0x126>
     a1d:	mov    QWORD PTR [rsp+0x8],r12
     a22:	mov    r12,r15
     a25:	mov    rsi,QWORD PTR [rsp]
     a29:	jmp    ab9 <botlish_fn_10+0x1b1>
     a2e:	mov    rax,QWORD PTR [rbx+0x18]
     a32:	mov    rsi,QWORD PTR [rax+0x8]
     a36:	mov    rax,QWORD PTR [rsi+0x8]
     a3a:	mov    rcx,r12
     a3d:	shl    rcx,1
     a40:	or     rcx,0x1
     a44:	sar    rcx,1
     a47:	cmp    rcx,rax
     a4a:	jb     a60 <botlish_fn_10+0x158>
     a50:	jmp    cc9 <botlish_fn_10+0x3c1>
     a55:	mov    rsi,rax
     a58:	mov    r12,r15
     a5b:	jmp    a70 <botlish_fn_10+0x168>
     a60:	mov    QWORD PTR [rsp+0x8],r12
     a65:	mov    rax,QWORD PTR [rsi+0x10]
     a69:	mov    rsi,QWORD PTR [rax+rcx*8]
     a6d:	mov    r12,r15
     a70:	mov    rax,rsi
     a73:	and    rax,r12
     a76:	test   rax,0x1
     a7c:	jne    a9b <botlish_fn_10+0x193>
     a82:	mov    rdx,r12
     a85:	mov    rdi,r14
     a88:	call   a8d <botlish_fn_10+0x185>
			a89: R_X86_64_PLT32	rt_value_eq-0x4
     a8d:	test   rax,rax
     a90:	je     ba8 <botlish_fn_10+0x2a0>
     a96:	jmp    aab <botlish_fn_10+0x1a3>
     a9b:	mov    eax,0x2
     aa0:	cmp    rsi,r12
     aa3:	cmove  rax,QWORD PTR [rip+0x245]        # cf0 <botlish_fn_10+0x3e8>
     aab:	cmp    rax,0x6
     aaf:	je     bf3 <botlish_fn_10+0x2eb>
     ab5:	mov    rsi,QWORD PTR [rsp]
     ab9:	test   rsi,0x1
     ac0:	jne    aec <botlish_fn_10+0x1e4>
     ac6:	mov    edx,0x5
     acb:	mov    rsi,QWORD PTR [rsp]
     acf:	mov    rdi,r14
     ad2:	call   ad7 <botlish_fn_10+0x1cf>
			ad3: R_X86_64_PLT32	rt_int_cmp-0x4
     ad7:	mov    ecx,0x2
     adc:	test   rax,rax
     adf:	cmove  rcx,QWORD PTR [rip+0x209]        # cf0 <botlish_fn_10+0x3e8>
     ae7:	jmp    b01 <botlish_fn_10+0x1f9>
     aec:	mov    ecx,0x2
     af1:	mov    rsi,QWORD PTR [rsp]
     af5:	cmp    rsi,0x5
     af9:	cmove  rcx,QWORD PTR [rip+0x1ef]        # cf0 <botlish_fn_10+0x3e8>
     b01:	cmp    rcx,0x6
     b05:	je     b15 <botlish_fn_10+0x20d>
     b0b:	mov    rdx,QWORD PTR [rsp+0x8]
     b10:	jmp    b66 <botlish_fn_10+0x25e>
     b15:	test   r13,0x1
     b1c:	jne    b47 <botlish_fn_10+0x23f>
     b22:	mov    edx,0x1
     b27:	mov    rsi,r13
     b2a:	mov    rdi,r14
     b2d:	call   b32 <botlish_fn_10+0x22a>
			b2e: R_X86_64_PLT32	rt_int_cmp-0x4
     b32:	mov    ecx,0x2
     b37:	test   rax,rax
     b3a:	cmovl  rcx,QWORD PTR [rip+0x1ae]        # cf0 <botlish_fn_10+0x3e8>
     b42:	jmp    b57 <botlish_fn_10+0x24f>
     b47:	mov    ecx,0x2
     b4c:	test   r13,r13
     b4f:	cmovle rcx,QWORD PTR [rip+0x199]        # cf0 <botlish_fn_10+0x3e8>
     b57:	cmp    rcx,0x6
     b5b:	je     b8c <botlish_fn_10+0x284>
     b61:	mov    rdx,QWORD PTR [rsp+0x8]
     b66:	mov    rsi,rbx
     b69:	mov    rdi,r14
     b6c:	call   b71 <botlish_fn_10+0x269>
			b6d: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     b71:	mov    QWORD PTR [rsp+0x8],rax
     b76:	test   rdx,rdx
     b79:	je     ba8 <botlish_fn_10+0x2a0>
     b7f:	mov    r15,r12
     b82:	mov    r12,QWORD PTR [rsp+0x8]
     b87:	jmp    93b <botlish_fn_10+0x33>
     b8c:	mov    rdx,QWORD PTR [rsp+0x8]
     b91:	mov    rsi,rbx
     b94:	mov    rdi,r14
     b97:	call   b9c <botlish_fn_10+0x294>
			b98: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     b9c:	mov    rcx,rax
     b9f:	test   rdx,rdx
     ba2:	jne    bcd <botlish_fn_10+0x2c5>
     ba8:	xor    rax,rax
     bab:	mov    rbx,QWORD PTR [rsp+0x10]
     bb0:	mov    r12,QWORD PTR [rsp+0x18]
     bb5:	mov    r13,QWORD PTR [rsp+0x20]
     bba:	mov    r14,QWORD PTR [rsp+0x28]
     bbf:	mov    r15,QWORD PTR [rsp+0x30]
     bc4:	add    rsp,0x40
     bc8:	mov    rsp,rbp
     bcb:	pop    rbp
     bcc:	ret
     bcd:	mov    rax,QWORD PTR [rsp+0x8]
     bd2:	shl    rax,1
     bd5:	mov    QWORD PTR [rsp+0x8],rax
     bda:	or     rax,0x1
     bde:	mov    QWORD PTR [rsp+0x8],rax
     be3:	mov    r15,r12
     be6:	mov    r13,QWORD PTR [rsp+0x8]
     beb:	mov    r12,rcx
     bee:	jmp    93b <botlish_fn_10+0x33>
     bf3:	mov    rax,QWORD PTR [rsp+0x8]
     bf8:	jmp    c5b <botlish_fn_10+0x353>
     bfd:	mov    rax,r13
     c00:	mov    QWORD PTR [rsp+0x8],r12
     c05:	test   rax,0x1
     c0b:	jne    c36 <botlish_fn_10+0x32e>
     c11:	mov    edx,0x1
     c16:	mov    rdi,r14
     c19:	mov    rsi,r13
     c1c:	call   c21 <botlish_fn_10+0x319>
			c1d: R_X86_64_PLT32	rt_int_cmp-0x4
     c21:	mov    ecx,0x2
     c26:	test   rax,rax
     c29:	cmovge rcx,QWORD PTR [rip+0xbf]        # cf0 <botlish_fn_10+0x3e8>
     c31:	jmp    c4c <botlish_fn_10+0x344>
     c36:	mov    ecx,0x2
     c3b:	mov    rax,r13
     c3e:	mov    rdx,r13
     c41:	test   rax,rdx
     c44:	cmovg  rcx,QWORD PTR [rip+0xa4]        # cf0 <botlish_fn_10+0x3e8>
     c4c:	cmp    rcx,0x6
     c50:	je     c84 <botlish_fn_10+0x37c>
     c56:	mov    rax,QWORD PTR [rsp+0x8]
     c5b:	shl    rax,1
     c5e:	or     rax,0x1
     c62:	mov    rbx,QWORD PTR [rsp+0x10]
     c67:	mov    r12,QWORD PTR [rsp+0x18]
     c6c:	mov    r13,QWORD PTR [rsp+0x20]
     c71:	mov    r14,QWORD PTR [rsp+0x28]
     c76:	mov    r15,QWORD PTR [rsp+0x30]
     c7b:	add    rsp,0x40
     c7f:	mov    rsp,rbp
     c82:	pop    rbp
     c83:	ret
     c84:	mov    rax,r13
     c87:	mov    rbx,QWORD PTR [rsp+0x10]
     c8c:	mov    r12,QWORD PTR [rsp+0x18]
     c91:	mov    r13,QWORD PTR [rsp+0x20]
     c96:	mov    r14,QWORD PTR [rsp+0x28]
     c9b:	mov    r15,QWORD PTR [rsp+0x30]
     ca0:	add    rsp,0x40
     ca4:	mov    rsp,rbp
     ca7:	pop    rbp
     ca8:	ret
     ca9:	mov    rdx,r12
     cac:	shl    rdx,1
     caf:	or     rdx,0x1
     cb3:	mov    rdi,r14
     cb6:	call   cbb <botlish_fn_10+0x3b3>
			cb7: R_X86_64_PLT32	rt_mutarray_get-0x4
     cbb:	test   rax,rax
     cbe:	jne    961 <botlish_fn_10+0x59>
     cc4:	jmp    ba8 <botlish_fn_10+0x2a0>
     cc9:	mov    rdx,r12
     ccc:	shl    rdx,1
     ccf:	mov    QWORD PTR [rsp+0x8],r12
     cd4:	or     rdx,0x1
     cd8:	mov    rdi,r14
     cdb:	call   ce0 <botlish_fn_10+0x3d8>
			cdc: R_X86_64_PLT32	rt_mutarray_get-0x4
     ce0:	test   rax,rax
     ce3:	jne    a55 <botlish_fn_10+0x14d>
     ce9:	jmp    ba8 <botlish_fn_10+0x2a0>
     cee:	add    BYTE PTR [rax],al
     cf0:	(bad)
     cf1:	add    BYTE PTR [rax],al
     cf3:	add    BYTE PTR [rax],al
     cf5:	add    BYTE PTR [rax],al
	...

0000000000000cf8 <botlish_entry_10: ht_find_insert<HashTable, str, int, int>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	mov    rsi,QWORD PTR [rdx]
     cff:	mov    r9,QWORD PTR [rdx+0x8]
     d03:	mov    rcx,QWORD PTR [rdx+0x10]
     d07:	mov    r8,QWORD PTR [rdx+0x18]
     d0b:	mov    rdx,r9
     d0e:	call   d13 <botlish_entry_10+0x1b>
			d0f: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
     d13:	mov    rsp,rbp
     d16:	pop    rbp
     d17:	ret

0000000000000d18 <botlish_fn_11: ht_get<HashTable, str>>:
     d18:	push   rbp
     d19:	mov    rbp,rsp
     d1c:	sub    rsp,0x20
     d20:	mov    QWORD PTR [rsp],rbx
     d24:	mov    QWORD PTR [rsp+0x8],r12
     d29:	mov    QWORD PTR [rsp+0x10],r13
     d2e:	mov    r12,rdi
     d31:	mov    r13,rdx
     d34:	mov    rbx,rsi
     d37:	mov    rdx,r13
     d3a:	mov    rdi,r12
     d3d:	call   d42 <botlish_fn_11+0x2a>
			d3e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     d42:	test   rax,rax
     d45:	mov    rcx,rax
     d48:	je     dee <botlish_fn_11+0xd6>
     d4e:	mov    rdx,r13
     d51:	mov    rsi,rbx
     d54:	mov    rdi,r12
     d57:	call   d5c <botlish_fn_11+0x44>
			d58: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     d5c:	mov    rcx,rax
     d5f:	mov    r13,rax
     d62:	test   rax,rcx
     d65:	je     dee <botlish_fn_11+0xd6>
     d6b:	mov    rax,r13
     d6e:	test   rax,0x1
     d74:	jne    da2 <botlish_fn_11+0x8a>
     d7a:	mov    edx,0x1
     d7f:	mov    rsi,r13
     d82:	mov    rdi,r12
     d85:	call   d8a <botlish_fn_11+0x72>
			d86: R_X86_64_PLT32	rt_int_cmp-0x4
     d8a:	mov    ecx,0x2
     d8f:	test   rax,rax
     d92:	cmovl  rcx,QWORD PTR [rip+0xd6]        # e70 <botlish_fn_11+0x158>
     d9a:	mov    rax,r13
     d9d:	jmp    db5 <botlish_fn_11+0x9d>
     da2:	mov    ecx,0x2
     da7:	mov    rax,r13
     daa:	test   rax,rax
     dad:	cmovle rcx,QWORD PTR [rip+0xbb]        # e70 <botlish_fn_11+0x158>
     db5:	cmp    rcx,0x6
     db9:	je     e2c <botlish_fn_11+0x114>
     dbf:	mov    rcx,QWORD PTR [rbx+0x18]
     dc3:	mov    rsi,QWORD PTR [rcx+0x10]
     dc7:	test   rax,0x1
     dcd:	je     e48 <botlish_fn_11+0x130>
     dd3:	mov    rdx,QWORD PTR [rsi+0x8]
     dd7:	mov    rcx,rax
     dda:	sar    rcx,1
     ddd:	mov    r13,rax
     de0:	cmp    rcx,rdx
     de3:	jb     e0d <botlish_fn_11+0xf5>
     de9:	jmp    e53 <botlish_fn_11+0x13b>
     dee:	xor    rax,rax
     df1:	mov    rbx,QWORD PTR [rsp]
     df5:	mov    r12,QWORD PTR [rsp+0x8]
     dfa:	mov    r13,QWORD PTR [rsp+0x10]
     dff:	add    rsp,0x20
     e03:	mov    rsp,rbp
     e06:	pop    rbp
     e07:	ret
     e08:	jmp    e15 <botlish_fn_11+0xfd>
     e0d:	mov    rax,QWORD PTR [rsi+0x10]
     e11:	mov    rax,QWORD PTR [rax+rcx*8]
     e15:	mov    rbx,QWORD PTR [rsp]
     e19:	mov    r12,QWORD PTR [rsp+0x8]
     e1e:	mov    r13,QWORD PTR [rsp+0x10]
     e23:	add    rsp,0x20
     e27:	mov    rsp,rbp
     e2a:	pop    rbp
     e2b:	ret
     e2c:	mov    eax,0xa
     e31:	mov    rbx,QWORD PTR [rsp]
     e35:	mov    r12,QWORD PTR [rsp+0x8]
     e3a:	mov    r13,QWORD PTR [rsp+0x10]
     e3f:	add    rsp,0x20
     e43:	mov    rsp,rbp
     e46:	pop    rbp
     e47:	ret
     e48:	mov    rdx,rax
     e4b:	mov    rdi,r12
     e4e:	jmp    e59 <botlish_fn_11+0x141>
     e53:	mov    rdx,r13
     e56:	mov    rdi,r12
     e59:	mov    rdi,r12
     e5c:	call   e61 <botlish_fn_11+0x149>
			e5d: R_X86_64_PLT32	rt_mutarray_get-0x4
     e61:	test   rax,rax
     e64:	jne    e15 <botlish_fn_11+0xfd>
     e6a:	jmp    dee <botlish_fn_11+0xd6>
     e6f:	add    BYTE PTR [rsi],al
     e71:	add    BYTE PTR [rax],al
     e73:	add    BYTE PTR [rax],al
     e75:	add    BYTE PTR [rax],al
	...

0000000000000e78 <botlish_entry_11: ht_get<HashTable, str>>:
     e78:	push   rbp
     e79:	mov    rbp,rsp
     e7c:	mov    rsi,QWORD PTR [rdx]
     e7f:	mov    rdx,QWORD PTR [rdx+0x8]
     e83:	call   e88 <botlish_entry_11+0x10>
			e84: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
     e88:	mov    rsp,rbp
     e8b:	pop    rbp
     e8c:	ret
     e8d:	add    BYTE PTR [rax],al
	...

0000000000000e90 <botlish_fn_12: ht_contains<HashTable, str>>:
     e90:	push   rbp
     e91:	mov    rbp,rsp
     e94:	sub    rsp,0x20
     e98:	mov    QWORD PTR [rsp],rbx
     e9c:	mov    QWORD PTR [rsp+0x8],r12
     ea1:	mov    QWORD PTR [rsp+0x10],r15
     ea6:	mov    rbx,rdx
     ea9:	mov    r12,rsi
     eac:	mov    r15,rdi
     eaf:	mov    rdx,rbx
     eb2:	mov    rsi,r12
     eb5:	mov    rdi,r15
     eb8:	call   ebd <botlish_fn_12+0x2d>
			eb9: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     ebd:	test   rax,rax
     ec0:	mov    rcx,rax
     ec3:	je     ee0 <botlish_fn_12+0x50>
     ec9:	mov    rdx,rbx
     ecc:	mov    rsi,r12
     ecf:	mov    rdi,r15
     ed2:	call   ed7 <botlish_fn_12+0x47>
			ed3: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     ed7:	test   rax,rax
     eda:	jne    efa <botlish_fn_12+0x6a>
     ee0:	xor    rax,rax
     ee3:	mov    rbx,QWORD PTR [rsp]
     ee7:	mov    r12,QWORD PTR [rsp+0x8]
     eec:	mov    r15,QWORD PTR [rsp+0x10]
     ef1:	add    rsp,0x20
     ef5:	mov    rsp,rbp
     ef8:	pop    rbp
     ef9:	ret
     efa:	test   rax,0x1
     f00:	mov    rsi,rax
     f03:	jne    f2e <botlish_fn_12+0x9e>
     f09:	mov    edx,0x1
     f0e:	mov    rdi,r15
     f11:	call   f16 <botlish_fn_12+0x86>
			f12: R_X86_64_PLT32	rt_int_cmp-0x4
     f16:	mov    ecx,0x2
     f1b:	test   rax,rax
     f1e:	mov    rax,rcx
     f21:	cmovge rax,QWORD PTR [rip+0x2f]        # f58 <botlish_fn_12+0xc8>
     f29:	jmp    f3e <botlish_fn_12+0xae>
     f2e:	mov    eax,0x2
     f33:	test   rsi,rsi
     f36:	cmovg  rax,QWORD PTR [rip+0x1a]        # f58 <botlish_fn_12+0xc8>
     f3e:	mov    rbx,QWORD PTR [rsp]
     f42:	mov    r12,QWORD PTR [rsp+0x8]
     f47:	mov    r15,QWORD PTR [rsp+0x10]
     f4c:	add    rsp,0x20
     f50:	mov    rsp,rbp
     f53:	pop    rbp
     f54:	ret
     f55:	add    BYTE PTR [rax],al
     f57:	add    BYTE PTR [rsi],al
     f59:	add    BYTE PTR [rax],al
     f5b:	add    BYTE PTR [rax],al
     f5d:	add    BYTE PTR [rax],al
	...

0000000000000f60 <botlish_entry_12: ht_contains<HashTable, str>>:
     f60:	push   rbp
     f61:	mov    rbp,rsp
     f64:	mov    rsi,QWORD PTR [rdx]
     f67:	mov    rdx,QWORD PTR [rdx+0x8]
     f6b:	call   f70 <botlish_entry_12+0x10>
			f6c: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
     f70:	mov    rsp,rbp
     f73:	pop    rbp
     f74:	ret
     f75:	add    BYTE PTR [rax],al
	...

0000000000000f78 <botlish_fn_13: ht_rehash_probe<mutarray, int, int>>:
     f78:	push   rbp
     f79:	mov    rbp,rsp
     f7c:	sub    rsp,0x60
     f80:	mov    QWORD PTR [rsp+0x30],rbx
     f85:	mov    QWORD PTR [rsp+0x38],r12
     f8a:	mov    QWORD PTR [rsp+0x40],r13
     f8f:	mov    QWORD PTR [rsp+0x48],r14
     f94:	mov    QWORD PTR [rsp+0x50],r15
     f99:	mov    r15,rdi
     f9c:	mov    QWORD PTR [rsp],rsi
     fa0:	mov    rax,rsi
     fa3:	mov    QWORD PTR [rsp+0x8],rdx
     fa8:	mov    QWORD PTR [rsp+0x10],rcx
     fad:	mov    r14,rcx
     fb0:	sar    r14,1
     fb3:	mov    r13,rcx
     fb6:	mov    rbx,r14
     fb9:	neg    rbx
     fbc:	cmovs  rbx,r14
     fc0:	mov    rsi,rdx
     fc3:	test   rsi,0x1
     fca:	je     115f <botlish_fn_13+0x1e7>
     fd0:	mov    r12,rax
     fd3:	mov    rcx,QWORD PTR [r12+0x8]
     fd8:	mov    rax,rsi
     fdb:	sar    rax,1
     fde:	mov    QWORD PTR [rsp+0x20],rsi
     fe3:	cmp    rax,rcx
     fe6:	jb     ff9 <botlish_fn_13+0x81>
     fec:	jmp    1167 <botlish_fn_13+0x1ef>
     ff1:	mov    rsi,rax
     ff4:	jmp    1002 <botlish_fn_13+0x8a>
     ff9:	mov    rcx,QWORD PTR [r12+0x10]
     ffe:	mov    rsi,QWORD PTR [rcx+rax*8]
    1002:	test   rsi,0x1
    1009:	jne    102a <botlish_fn_13+0xb2>
    100f:	mov    edx,0x1
    1014:	mov    rdi,r15
    1017:	call   101c <botlish_fn_13+0xa4>
			1018: R_X86_64_PLT32	rt_value_eq-0x4
    101c:	test   rax,rax
    101f:	je     10fa <botlish_fn_13+0x182>
    1025:	jmp    103b <botlish_fn_13+0xc3>
    102a:	mov    eax,0x2
    102f:	cmp    rsi,0x1
    1033:	cmove  rax,QWORD PTR [rip+0x14d]        # 1188 <botlish_fn_13+0x210>
    103b:	cmp    rax,0x6
    103f:	je     1138 <botlish_fn_13+0x1c0>
    1045:	mov    QWORD PTR [rsp+0x18],0x3
    104e:	mov    rsi,QWORD PTR [rsp+0x20]
    1053:	test   rsi,0x1
    105a:	je     1076 <botlish_fn_13+0xfe>
    1060:	mov    rsi,QWORD PTR [rsp+0x20]
    1065:	add    rsi,0x2
    1069:	seto   dil
    106d:	test   dil,dil
    1070:	je     108b <botlish_fn_13+0x113>
    1076:	mov    edx,0x3
    107b:	mov    rsi,QWORD PTR [rsp+0x20]
    1080:	mov    rdi,r15
    1083:	call   1088 <botlish_fn_13+0x110>
			1084: R_X86_64_PLT32	rt_int_add-0x4
    1088:	mov    rsi,rax
    108b:	mov    QWORD PTR [rsp+0x8],rsi
    1090:	mov    r10,rsi
    1093:	and    r10,r13
    1096:	test   r10,0x1
    109d:	je     10e6 <botlish_fn_13+0x16e>
    10a3:	cmp    r13,0x1
    10a7:	je     10e6 <botlish_fn_13+0x16e>
    10ad:	mov    rax,rsi
    10b0:	sar    rax,1
    10b3:	cqo
    10b5:	cmp    r14,0xffffffffffffffff
    10b9:	jne    10c9 <botlish_fn_13+0x151>
    10bf:	mov    edx,0x0
    10c4:	jmp    10cc <botlish_fn_13+0x154>
    10c9:	idiv   r14
    10cc:	lea    rax,[rdx+rbx*1]
    10d0:	test   rdx,rdx
    10d3:	cmovl  rdx,rax
    10d7:	shl    rdx,1
    10da:	or     rdx,0x1
    10de:	mov    rax,rdx
    10e1:	jmp    111f <botlish_fn_13+0x1a7>
    10e6:	mov    rdx,r13
    10e9:	mov    rdi,r15
    10ec:	call   10f1 <botlish_fn_13+0x179>
			10ed: R_X86_64_PLT32	rt_int_mod-0x4
    10f1:	test   rax,rax
    10f4:	jne    111f <botlish_fn_13+0x1a7>
    10fa:	xor    rax,rax
    10fd:	mov    rbx,QWORD PTR [rsp+0x30]
    1102:	mov    r12,QWORD PTR [rsp+0x38]
    1107:	mov    r13,QWORD PTR [rsp+0x40]
    110c:	mov    r14,QWORD PTR [rsp+0x48]
    1111:	mov    r15,QWORD PTR [rsp+0x50]
    1116:	add    rsp,0x60
    111a:	mov    rsp,rbp
    111d:	pop    rbp
    111e:	ret
    111f:	mov    QWORD PTR [rsp],r12
    1123:	mov    QWORD PTR [rsp+0x8],rax
    1128:	mov    QWORD PTR [rsp+0x10],r13
    112d:	mov    rsi,rax
    1130:	mov    rax,r12
    1133:	jmp    fc3 <botlish_fn_13+0x4b>
    1138:	mov    rax,QWORD PTR [rsp+0x20]
    113d:	mov    rbx,QWORD PTR [rsp+0x30]
    1142:	mov    r12,QWORD PTR [rsp+0x38]
    1147:	mov    r13,QWORD PTR [rsp+0x40]
    114c:	mov    r14,QWORD PTR [rsp+0x48]
    1151:	mov    r15,QWORD PTR [rsp+0x50]
    1156:	add    rsp,0x60
    115a:	mov    rsp,rbp
    115d:	pop    rbp
    115e:	ret
    115f:	mov    r12,rax
    1162:	mov    QWORD PTR [rsp+0x20],rsi
    1167:	mov    rdx,QWORD PTR [rsp+0x20]
    116c:	mov    rsi,r12
    116f:	mov    rdi,r15
    1172:	call   1177 <botlish_fn_13+0x1ff>
			1173: R_X86_64_PLT32	rt_mutarray_get-0x4
    1177:	test   rax,rax
    117a:	jne    ff1 <botlish_fn_13+0x79>
    1180:	jmp    10fa <botlish_fn_13+0x182>
    1185:	add    BYTE PTR [rax],al
    1187:	add    BYTE PTR [rsi],al
    1189:	add    BYTE PTR [rax],al
    118b:	add    BYTE PTR [rax],al
    118d:	add    BYTE PTR [rax],al
	...

0000000000001190 <botlish_entry_13: ht_rehash_probe<mutarray, int, int>>:
    1190:	push   rbp
    1191:	mov    rbp,rsp
    1194:	mov    rsi,QWORD PTR [rdx]
    1197:	mov    r8,QWORD PTR [rdx+0x8]
    119b:	mov    rcx,QWORD PTR [rdx+0x10]
    119f:	mov    rdx,r8
    11a2:	call   11a7 <botlish_entry_13+0x17>
			11a3: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
    11a7:	mov    rsp,rbp
    11aa:	pop    rbp
    11ab:	ret

00000000000011ac <botlish_fn_14: ht_rehash_insert<HashTable, int, any, any>>:
    11ac:	push   rbp
    11ad:	mov    rbp,rsp
    11b0:	sub    rsp,0x70
    11b4:	mov    QWORD PTR [rsp+0x40],rbx
    11b9:	mov    QWORD PTR [rsp+0x48],r12
    11be:	mov    QWORD PTR [rsp+0x50],r13
    11c3:	mov    QWORD PTR [rsp+0x58],r14
    11c8:	mov    QWORD PTR [rsp+0x60],r15
    11cd:	mov    r15,rdi
    11d0:	mov    QWORD PTR [rsp],rsi
    11d4:	mov    QWORD PTR [rsp+0x8],rdx
    11d9:	mov    r12,rdx
    11dc:	mov    QWORD PTR [rsp+0x10],rcx
    11e1:	mov    QWORD PTR [rsp+0x30],rcx
    11e6:	mov    QWORD PTR [rsp+0x18],r8
    11eb:	mov    r14,r8
    11ee:	mov    rax,QWORD PTR [rsi+0x18]
    11f2:	mov    rbx,rsi
    11f5:	mov    rsi,QWORD PTR [rax]
    11f8:	mov    QWORD PTR [rsp+0x20],rsi
    11fd:	mov    QWORD PTR [rsp+0x38],rsi
    1202:	mov    rsi,QWORD PTR [rsp+0x30]
    1207:	mov    rdi,r15
    120a:	call   120f <botlish_fn_14+0x63>
			120b: R_X86_64_PLT32	rt_hash-0x4
    120f:	test   rax,rax
    1212:	je     1391 <botlish_fn_14+0x1e5>
    1218:	mov    QWORD PTR [rsp+0x28],rax
    121d:	mov    r13,r12
    1220:	mov    rcx,rax
    1223:	and    rcx,r13
    1226:	test   rcx,0x1
    122d:	jne    123b <botlish_fn_14+0x8f>
    1233:	mov    rsi,rax
    1236:	jmp    1292 <botlish_fn_14+0xe6>
    123b:	cmp    r13,0x1
    123f:	jne    124d <botlish_fn_14+0xa1>
    1245:	mov    rsi,rax
    1248:	jmp    1292 <botlish_fn_14+0xe6>
    124d:	sar    rax,1
    1250:	mov    rcx,r13
    1253:	sar    rcx,1
    1256:	cqo
    1258:	cmp    rcx,0xffffffffffffffff
    125c:	jne    126c <botlish_fn_14+0xc0>
    1262:	mov    edx,0x0
    1267:	jmp    126f <botlish_fn_14+0xc3>
    126c:	idiv   rcx
    126f:	mov    rax,rcx
    1272:	neg    rax
    1275:	cmovs  rax,rcx
    1279:	add    rax,rdx
    127c:	test   rdx,rdx
    127f:	cmovl  rdx,rax
    1283:	shl    rdx,1
    1286:	or     rdx,0x1
    128a:	mov    r12,r13
    128d:	jmp    12ac <botlish_fn_14+0x100>
    1292:	mov    rdx,r13
    1295:	mov    rdi,r15
    1298:	call   129d <botlish_fn_14+0xf1>
			1299: R_X86_64_PLT32	rt_int_mod-0x4
    129d:	mov    r12,r13
    12a0:	test   rax,rax
    12a3:	je     1391 <botlish_fn_14+0x1e5>
    12a9:	mov    rdx,rax
    12ac:	mov    QWORD PTR [rsp+0x28],rdx
    12b1:	mov    rcx,r12
    12b4:	mov    rsi,QWORD PTR [rsp+0x38]
    12b9:	mov    rdi,r15
    12bc:	call   12c1 <botlish_fn_14+0x115>
			12bd: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
    12c1:	mov    rcx,rax
    12c4:	mov    r12,rax
    12c7:	test   rax,rcx
    12ca:	je     1391 <botlish_fn_14+0x1e5>
    12d0:	mov    r9,QWORD PTR [rbx+0x18]
    12d4:	mov    rsi,QWORD PTR [r9]
    12d7:	mov    rax,r12
    12da:	test   rax,0x1
    12e0:	je     13ee <botlish_fn_14+0x242>
    12e6:	mov    rdx,QWORD PTR [rsi+0x8]
    12ea:	mov    rax,r12
    12ed:	mov    rcx,rax
    12f0:	sar    rcx,1
    12f3:	cmp    rcx,rdx
    12f6:	jae    13ee <botlish_fn_14+0x242>
    12fc:	mov    rdx,QWORD PTR [rsi+0x18]
    1300:	test   rdx,rdx
    1303:	je     13ee <botlish_fn_14+0x242>
    1309:	mov    rax,QWORD PTR [rsi+0x10]
    130d:	mov    QWORD PTR [rax+rcx*8],0x3
    1315:	mov    rax,QWORD PTR [rbx+0x18]
    1319:	mov    rsi,QWORD PTR [rax+0x8]
    131d:	test   r12,0x1
    1324:	je     140c <botlish_fn_14+0x260>
    132a:	mov    rdx,QWORD PTR [rsi+0x8]
    132e:	mov    rdi,r12
    1331:	sar    rdi,1
    1334:	cmp    rdi,rdx
    1337:	jae    1416 <botlish_fn_14+0x26a>
    133d:	mov    rcx,QWORD PTR [rsi+0x18]
    1341:	test   rcx,rcx
    1344:	je     1420 <botlish_fn_14+0x274>
    134a:	mov    rcx,QWORD PTR [rsp+0x30]
    134f:	mov    rax,QWORD PTR [rsi+0x10]
    1353:	mov    QWORD PTR [rax+rdi*8],rcx
    1357:	mov    rax,QWORD PTR [rbx+0x18]
    135b:	mov    rsi,QWORD PTR [rax+0x10]
    135f:	test   r12,0x1
    1366:	je     143e <botlish_fn_14+0x292>
    136c:	mov    rdx,QWORD PTR [rsi+0x8]
    1370:	mov    rdi,r12
    1373:	sar    rdi,1
    1376:	cmp    rdi,rdx
    1379:	jae    144c <botlish_fn_14+0x2a0>
    137f:	mov    rax,QWORD PTR [rsi+0x18]
    1383:	test   rax,rax
    1386:	jne    13be <botlish_fn_14+0x212>
    138c:	jmp    145a <botlish_fn_14+0x2ae>
    1391:	xor    rax,rax
    1394:	mov    rbx,QWORD PTR [rsp+0x40]
    1399:	mov    r12,QWORD PTR [rsp+0x48]
    139e:	mov    r13,QWORD PTR [rsp+0x50]
    13a3:	mov    r14,QWORD PTR [rsp+0x58]
    13a8:	mov    r15,QWORD PTR [rsp+0x60]
    13ad:	add    rsp,0x70
    13b1:	mov    rsp,rbp
    13b4:	pop    rbp
    13b5:	ret
    13b6:	mov    rax,rbx
    13b9:	jmp    13cc <botlish_fn_14+0x220>
    13be:	mov    rcx,r14
    13c1:	mov    rax,QWORD PTR [rsi+0x10]
    13c5:	mov    QWORD PTR [rax+rdi*8],rcx
    13c9:	mov    rax,rbx
    13cc:	mov    rbx,QWORD PTR [rsp+0x40]
    13d1:	mov    r12,QWORD PTR [rsp+0x48]
    13d6:	mov    r13,QWORD PTR [rsp+0x50]
    13db:	mov    r14,QWORD PTR [rsp+0x58]
    13e0:	mov    r15,QWORD PTR [rsp+0x60]
    13e5:	add    rsp,0x70
    13e9:	mov    rsp,rbp
    13ec:	pop    rbp
    13ed:	ret
    13ee:	mov    ecx,0x3
    13f3:	mov    rdx,r12
    13f6:	mov    rdi,r15
    13f9:	call   13fe <botlish_fn_14+0x252>
			13fa: R_X86_64_PLT32	rt_mutarray_set-0x4
    13fe:	test   rax,rax
    1401:	jne    1315 <botlish_fn_14+0x169>
    1407:	jmp    1391 <botlish_fn_14+0x1e5>
    140c:	mov    rcx,QWORD PTR [rsp+0x30]
    1411:	jmp    1425 <botlish_fn_14+0x279>
    1416:	mov    rcx,QWORD PTR [rsp+0x30]
    141b:	jmp    1425 <botlish_fn_14+0x279>
    1420:	mov    rcx,QWORD PTR [rsp+0x30]
    1425:	mov    rdx,r12
    1428:	mov    rdi,r15
    142b:	call   1430 <botlish_fn_14+0x284>
			142c: R_X86_64_PLT32	rt_mutarray_set-0x4
    1430:	test   rax,rax
    1433:	jne    1357 <botlish_fn_14+0x1ab>
    1439:	jmp    1391 <botlish_fn_14+0x1e5>
    143e:	mov    rcx,r14
    1441:	mov    rdx,r12
    1444:	mov    rdi,r15
    1447:	jmp    1463 <botlish_fn_14+0x2b7>
    144c:	mov    rcx,r14
    144f:	mov    rdx,r12
    1452:	mov    rdi,r15
    1455:	jmp    1463 <botlish_fn_14+0x2b7>
    145a:	mov    rcx,r14
    145d:	mov    rdx,r12
    1460:	mov    rdi,r15
    1463:	mov    rdi,r15
    1466:	call   146b <botlish_fn_14+0x2bf>
			1467: R_X86_64_PLT32	rt_mutarray_set-0x4
    146b:	test   rax,rax
    146e:	jne    13b6 <botlish_fn_14+0x20a>
    1474:	jmp    1391 <botlish_fn_14+0x1e5>

0000000000001479 <botlish_entry_14: ht_rehash_insert<HashTable, int, any, any>>:
    1479:	push   rbp
    147a:	mov    rbp,rsp
    147d:	mov    rsi,QWORD PTR [rdx]
    1480:	mov    r9,QWORD PTR [rdx+0x8]
    1484:	mov    rcx,QWORD PTR [rdx+0x10]
    1488:	mov    r8,QWORD PTR [rdx+0x18]
    148c:	mov    rdx,r9
    148f:	call   1494 <botlish_entry_14+0x1b>
			1490: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    1494:	mov    rsp,rbp
    1497:	pop    rbp
    1498:	ret
    1499:	add    BYTE PTR [rax],al
    149b:	add    BYTE PTR [rax],al
    149d:	add    BYTE PTR [rax],al
	...

00000000000014a0 <botlish_fn_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    14a0:	push   rbp
    14a1:	mov    rbp,rsp
    14a4:	sub    rsp,0x90
    14ab:	mov    QWORD PTR [rsp+0x60],rbx
    14b0:	mov    QWORD PTR [rsp+0x68],r12
    14b5:	mov    QWORD PTR [rsp+0x70],r13
    14ba:	mov    QWORD PTR [rsp+0x78],r14
    14bf:	mov    QWORD PTR [rsp+0x80],r15
    14c7:	mov    QWORD PTR [rsp+0x38],rdi
    14cc:	mov    QWORD PTR [rsp+0x40],r9
    14d1:	mov    rax,QWORD PTR [rbp+0x10]
    14d5:	mov    r12,QWORD PTR [rbp+0x18]
    14d9:	mov    QWORD PTR [rsp],rsi
    14dd:	mov    QWORD PTR [rsp+0x8],rdx
    14e2:	mov    r15,rdx
    14e5:	mov    QWORD PTR [rsp+0x10],rcx
    14ea:	mov    rbx,rcx
    14ed:	mov    QWORD PTR [rsp+0x18],rax
    14f2:	mov    QWORD PTR [rsp+0x48],rax
    14f7:	mov    QWORD PTR [rsp+0x20],r12
    14fc:	sar    r8,1
    14ff:	mov    rdx,QWORD PTR [rsp+0x40]
    1504:	mov    r13,r8
    1507:	cmp    r13,rdx
    150a:	mov    QWORD PTR [rsp+0x40],rdx
    150f:	jge    16ab <botlish_fn_15+0x20b>
    1515:	mov    r14,rsi
    1518:	mov    rdx,QWORD PTR [r14+0x8]
    151c:	mov    rax,r13
    151f:	shl    rax,1
    1522:	or     rax,0x1
    1526:	sar    rax,1
    1529:	cmp    rax,rdx
    152c:	jb     153f <botlish_fn_15+0x9f>
    1532:	jmp    16d8 <botlish_fn_15+0x238>
    1537:	mov    rsi,rax
    153a:	jmp    1547 <botlish_fn_15+0xa7>
    153f:	mov    r8,QWORD PTR [r14+0x10]
    1543:	mov    rsi,QWORD PTR [r8+rax*8]
    1547:	test   rsi,0x1
    154e:	jne    1571 <botlish_fn_15+0xd1>
    1554:	mov    edx,0x3
    1559:	mov    rdi,QWORD PTR [rsp+0x38]
    155e:	call   1563 <botlish_fn_15+0xc3>
			155f: R_X86_64_PLT32	rt_value_eq-0x4
    1563:	test   rax,rax
    1566:	je     164f <botlish_fn_15+0x1af>
    156c:	jmp    1582 <botlish_fn_15+0xe2>
    1571:	mov    eax,0x2
    1576:	cmp    rsi,0x3
    157a:	cmove  rax,QWORD PTR [rip+0x1c6]        # 1748 <botlish_fn_15+0x2a8>
    1582:	cmp    rax,0x6
    1586:	je     15bd <botlish_fn_15+0x11d>
    158c:	mov    QWORD PTR [rsp],r14
    1590:	mov    QWORD PTR [rsp+0x8],r15
    1595:	mov    QWORD PTR [rsp+0x10],rbx
    159a:	mov    rax,QWORD PTR [rsp+0x48]
    159f:	mov    QWORD PTR [rsp+0x18],rax
    15a4:	mov    QWORD PTR [rsp+0x20],r12
    15a9:	add    r13,0x1
    15b0:	mov    rdx,QWORD PTR [rsp+0x40]
    15b5:	mov    rsi,r14
    15b8:	jmp    1507 <botlish_fn_15+0x67>
    15bd:	mov    rdx,QWORD PTR [r15+0x8]
    15c1:	mov    rcx,r13
    15c4:	shl    rcx,1
    15c7:	or     rcx,0x1
    15cb:	sar    rcx,1
    15ce:	cmp    rcx,rdx
    15d1:	jb     15e4 <botlish_fn_15+0x144>
    15d7:	jmp    16fd <botlish_fn_15+0x25d>
    15dc:	mov    rcx,rax
    15df:	jmp    15ec <botlish_fn_15+0x14c>
    15e4:	mov    rax,QWORD PTR [r15+0x10]
    15e8:	mov    rcx,QWORD PTR [rax+rcx*8]
    15ec:	mov    QWORD PTR [rsp+0x28],rcx
    15f1:	mov    QWORD PTR [rsp+0x50],rcx
    15f6:	mov    rax,QWORD PTR [rbx+0x8]
    15fa:	mov    rcx,r13
    15fd:	shl    rcx,1
    1600:	or     rcx,0x1
    1604:	sar    rcx,1
    1607:	cmp    rcx,rax
    160a:	jb     1622 <botlish_fn_15+0x182>
    1610:	jmp    1722 <botlish_fn_15+0x282>
    1615:	mov    rsi,QWORD PTR [rsp+0x48]
    161a:	mov    r8,rax
    161d:	jmp    162f <botlish_fn_15+0x18f>
    1622:	mov    rax,QWORD PTR [rbx+0x10]
    1626:	mov    r8,QWORD PTR [rax+rcx*8]
    162a:	mov    rsi,QWORD PTR [rsp+0x48]
    162f:	mov    QWORD PTR [rsp+0x30],r8
    1634:	mov    rcx,QWORD PTR [rsp+0x50]
    1639:	mov    rdx,r12
    163c:	mov    rdi,QWORD PTR [rsp+0x38]
    1641:	call   1646 <botlish_fn_15+0x1a6>
			1642: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    1646:	test   rax,rax
    1649:	jne    167a <botlish_fn_15+0x1da>
    164f:	xor    rax,rax
    1652:	mov    rbx,QWORD PTR [rsp+0x60]
    1657:	mov    r12,QWORD PTR [rsp+0x68]
    165c:	mov    r13,QWORD PTR [rsp+0x70]
    1661:	mov    r14,QWORD PTR [rsp+0x78]
    1666:	mov    r15,QWORD PTR [rsp+0x80]
    166e:	add    rsp,0x90
    1675:	mov    rsp,rbp
    1678:	pop    rbp
    1679:	ret
    167a:	mov    QWORD PTR [rsp],r14
    167e:	mov    QWORD PTR [rsp+0x8],r15
    1683:	mov    QWORD PTR [rsp+0x10],rbx
    1688:	mov    QWORD PTR [rsp+0x18],rax
    168d:	mov    QWORD PTR [rsp+0x20],r12
    1692:	add    r13,0x1
    1699:	mov    rdx,QWORD PTR [rsp+0x40]
    169e:	mov    rsi,r14
    16a1:	mov    QWORD PTR [rsp+0x48],rax
    16a6:	jmp    1507 <botlish_fn_15+0x67>
    16ab:	mov    rax,QWORD PTR [rsp+0x48]
    16b0:	mov    rbx,QWORD PTR [rsp+0x60]
    16b5:	mov    r12,QWORD PTR [rsp+0x68]
    16ba:	mov    r13,QWORD PTR [rsp+0x70]
    16bf:	mov    r14,QWORD PTR [rsp+0x78]
    16c4:	mov    r15,QWORD PTR [rsp+0x80]
    16cc:	add    rsp,0x90
    16d3:	mov    rsp,rbp
    16d6:	pop    rbp
    16d7:	ret
    16d8:	mov    rdx,r13
    16db:	shl    rdx,1
    16de:	or     rdx,0x1
    16e2:	mov    rsi,r14
    16e5:	mov    rdi,QWORD PTR [rsp+0x38]
    16ea:	call   16ef <botlish_fn_15+0x24f>
			16eb: R_X86_64_PLT32	rt_mutarray_get-0x4
    16ef:	test   rax,rax
    16f2:	jne    1537 <botlish_fn_15+0x97>
    16f8:	jmp    164f <botlish_fn_15+0x1af>
    16fd:	mov    rdx,r13
    1700:	shl    rdx,1
    1703:	or     rdx,0x1
    1707:	mov    rsi,r15
    170a:	mov    rdi,QWORD PTR [rsp+0x38]
    170f:	call   1714 <botlish_fn_15+0x274>
			1710: R_X86_64_PLT32	rt_mutarray_get-0x4
    1714:	test   rax,rax
    1717:	jne    15dc <botlish_fn_15+0x13c>
    171d:	jmp    164f <botlish_fn_15+0x1af>
    1722:	mov    rdx,r13
    1725:	shl    rdx,1
    1728:	or     rdx,0x1
    172c:	mov    rsi,rbx
    172f:	mov    rdi,QWORD PTR [rsp+0x38]
    1734:	call   1739 <botlish_fn_15+0x299>
			1735: R_X86_64_PLT32	rt_mutarray_get-0x4
    1739:	test   rax,rax
    173c:	jne    1615 <botlish_fn_15+0x175>
    1742:	jmp    164f <botlish_fn_15+0x1af>
    1747:	add    BYTE PTR [rsi],al
    1749:	add    BYTE PTR [rax],al
    174b:	add    BYTE PTR [rax],al
    174d:	add    BYTE PTR [rax],al
	...

0000000000001750 <botlish_entry_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    1750:	push   rbp
    1751:	mov    rbp,rsp
    1754:	sub    rsp,0x10
    1758:	mov    rsi,QWORD PTR [rdx]
    175b:	mov    r11,QWORD PTR [rdx+0x8]
    175f:	mov    rcx,QWORD PTR [rdx+0x10]
    1763:	mov    r8,QWORD PTR [rdx+0x18]
    1767:	mov    r9,QWORD PTR [rdx+0x20]
    176b:	mov    rax,QWORD PTR [rdx+0x28]
    176f:	mov    rdx,QWORD PTR [rdx+0x30]
    1773:	sar    r9,1
    1776:	mov    QWORD PTR [rsp],rax
    177a:	mov    QWORD PTR [rsp+0x8],rdx
    177f:	mov    rdx,r11
    1782:	call   1787 <botlish_entry_15+0x37>
			1783: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    1787:	add    rsp,0x10
    178b:	mov    rsp,rbp
    178e:	pop    rbp
    178f:	ret

0000000000001790 <botlish_fn_16: ht_rehash<HashTable, int>>:
    1790:	push   rbp
    1791:	mov    rbp,rsp
    1794:	sub    rsp,0x100
    179b:	mov    QWORD PTR [rsp+0xd0],rbx
    17a3:	mov    QWORD PTR [rsp+0xd8],r12
    17ab:	mov    QWORD PTR [rsp+0xe0],r13
    17b3:	mov    QWORD PTR [rsp+0xe8],r14
    17bb:	mov    QWORD PTR [rsp+0xf0],r15
    17c3:	mov    QWORD PTR [rsp+0x98],rdi
    17cb:	mov    QWORD PTR [rsp+0x20],0x0
    17d4:	mov    QWORD PTR [rsp+0x28],0x0
    17dd:	mov    QWORD PTR [rsp+0x30],0x0
    17e6:	mov    QWORD PTR [rsp+0x38],0x0
    17ef:	mov    QWORD PTR [rsp+0x40],0x0
    17f8:	mov    QWORD PTR [rsp+0x48],0x0
    1801:	mov    QWORD PTR [rsp+0x50],0x0
    180a:	mov    QWORD PTR [rsp+0x58],0x0
    1813:	mov    QWORD PTR [rsp+0x10],rsi
    1818:	mov    rbx,rsi
    181b:	mov    QWORD PTR [rsp+0x18],rdx
    1820:	mov    QWORD PTR [rsp+0xa0],rdx
    1828:	lea    rdx,[rsp+0x60]
    182d:	mov    rsi,QWORD PTR [rsp+0xa0]
    1835:	mov    rdi,QWORD PTR [rsp+0x98]
    183d:	call   1842 <botlish_fn_16+0xb2>
			183e: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    1842:	test   rax,rax
    1845:	je     19b2 <botlish_fn_16+0x222>
    184b:	mov    QWORD PTR [rsp+0x20],rax
    1850:	mov    QWORD PTR [rsp+0xc0],rax
    1858:	mov    rcx,QWORD PTR [rsp+0x60]
    185d:	mov    QWORD PTR [rsp+0x28],rcx
    1862:	mov    QWORD PTR [rsp+0xb8],rcx
    186a:	mov    rcx,QWORD PTR [rsp+0x68]
    186f:	mov    QWORD PTR [rsp+0x30],rcx
    1874:	mov    QWORD PTR [rsp+0xb0],rcx
    187c:	mov    r13,QWORD PTR [rsp+0x70]
    1881:	mov    QWORD PTR [rsp+0x38],r13
    1886:	mov    rsi,rbx
    1889:	mov    rdi,QWORD PTR [rsp+0x98]
    1891:	call   1896 <botlish_fn_16+0x106>
			1892: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1896:	test   rax,rax
    1899:	mov    rcx,rax
    189c:	je     19b2 <botlish_fn_16+0x222>
    18a2:	mov    rax,QWORD PTR [r13+0x8]
    18a6:	test   rax,rax
    18a9:	je     1a1d <botlish_fn_16+0x28d>
    18af:	mov    rax,QWORD PTR [r13+0x18]
    18b3:	test   rax,rax
    18b6:	jne    18c9 <botlish_fn_16+0x139>
    18bc:	jmp    1a1d <botlish_fn_16+0x28d>
    18c1:	mov    rsi,rbx
    18c4:	jmp    18d3 <botlish_fn_16+0x143>
    18c9:	mov    rax,QWORD PTR [r13+0x10]
    18cd:	mov    QWORD PTR [rax],rcx
    18d0:	mov    rsi,rbx
    18d3:	mov    rdx,QWORD PTR [rsi+0x18]
    18d7:	mov    r14,QWORD PTR [rdx]
    18da:	mov    QWORD PTR [rsp+0x40],r14
    18df:	mov    rdi,QWORD PTR [rsi+0x18]
    18e3:	mov    r15,QWORD PTR [rdi+0x8]
    18e7:	mov    QWORD PTR [rsp+0x48],r15
    18ec:	mov    rdi,QWORD PTR [rsi+0x18]
    18f0:	mov    rbx,QWORD PTR [rdi+0x10]
    18f4:	mov    QWORD PTR [rsp+0x50],rbx
    18f9:	mov    r12d,0x1
    18ff:	mov    QWORD PTR [rsp+0x58],0x1
    1908:	mov    rdi,QWORD PTR [rsp+0x98]
    1910:	call   1915 <botlish_fn_16+0x185>
			1911: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1915:	mov    QWORD PTR [rsp+0xa8],rax
    191d:	lea    rcx,[rsp+0x78]
    1922:	mov    rax,QWORD PTR [rsp+0xc0]
    192a:	mov    QWORD PTR [rsp+0x78],rax
    192f:	mov    rax,QWORD PTR [rsp+0xb8]
    1937:	mov    QWORD PTR [rsp+0x80],rax
    193f:	mov    rax,QWORD PTR [rsp+0xb0]
    1947:	mov    QWORD PTR [rsp+0x88],rax
    194f:	mov    QWORD PTR [rsp+0x90],r13
    1957:	xor    rsi,rsi
    195a:	mov    edx,0x4
    195f:	mov    rdi,QWORD PTR [rsp+0x98]
    1967:	call   196c <botlish_fn_16+0x1dc>
			1968: R_X86_64_PLT32	rt_struct_new-0x4
    196c:	mov    QWORD PTR [rsp+0x10],rax
    1971:	mov    rcx,QWORD PTR [rsp+0xa8]
    1979:	mov    r9,rcx
    197c:	sar    r9,1
    197f:	mov    QWORD PTR [rsp],rax
    1983:	mov    rdx,QWORD PTR [rsp+0xa0]
    198b:	mov    QWORD PTR [rsp+0x8],rdx
    1990:	mov    rcx,rbx
    1993:	mov    rdx,r15
    1996:	mov    rsi,r14
    1999:	mov    rdi,QWORD PTR [rsp+0x98]
    19a1:	mov    r8,r12
    19a4:	call   19a9 <botlish_fn_16+0x219>
			19a5: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    19a9:	test   rax,rax
    19ac:	jne    19e9 <botlish_fn_16+0x259>
    19b2:	xor    rax,rax
    19b5:	mov    rbx,QWORD PTR [rsp+0xd0]
    19bd:	mov    r12,QWORD PTR [rsp+0xd8]
    19c5:	mov    r13,QWORD PTR [rsp+0xe0]
    19cd:	mov    r14,QWORD PTR [rsp+0xe8]
    19d5:	mov    r15,QWORD PTR [rsp+0xf0]
    19dd:	add    rsp,0x100
    19e4:	mov    rsp,rbp
    19e7:	pop    rbp
    19e8:	ret
    19e9:	mov    rbx,QWORD PTR [rsp+0xd0]
    19f1:	mov    r12,QWORD PTR [rsp+0xd8]
    19f9:	mov    r13,QWORD PTR [rsp+0xe0]
    1a01:	mov    r14,QWORD PTR [rsp+0xe8]
    1a09:	mov    r15,QWORD PTR [rsp+0xf0]
    1a11:	add    rsp,0x100
    1a18:	mov    rsp,rbp
    1a1b:	pop    rbp
    1a1c:	ret
    1a1d:	mov    edx,0x1
    1a22:	mov    rsi,r13
    1a25:	mov    rdi,QWORD PTR [rsp+0x98]
    1a2d:	call   1a32 <botlish_fn_16+0x2a2>
			1a2e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a32:	test   rax,rax
    1a35:	jne    18c1 <botlish_fn_16+0x131>
    1a3b:	jmp    19b2 <botlish_fn_16+0x222>

0000000000001a40 <botlish_entry_16: ht_rehash<HashTable, int>>:
    1a40:	push   rbp
    1a41:	mov    rbp,rsp
    1a44:	mov    rsi,QWORD PTR [rdx]
    1a47:	mov    rdx,QWORD PTR [rdx+0x8]
    1a4b:	call   1a50 <botlish_entry_16+0x10>
			1a4c: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a50:	mov    rsp,rbp
    1a53:	pop    rbp
    1a54:	ret
    1a55:	add    BYTE PTR [rax],al
	...

0000000000001a58 <botlish_fn_17: ht_should_grow<HashTable>>:
    1a58:	push   rbp
    1a59:	mov    rbp,rsp
    1a5c:	sub    rsp,0x40
    1a60:	mov    QWORD PTR [rsp+0x20],rbx
    1a65:	mov    QWORD PTR [rsp+0x28],r12
    1a6a:	mov    QWORD PTR [rsp+0x30],r13
    1a6f:	mov    rbx,rdi
    1a72:	mov    QWORD PTR [rsp],rsi
    1a76:	mov    r12,rsi
    1a79:	mov    rsi,r12
    1a7c:	mov    rdi,rbx
    1a7f:	call   1a84 <botlish_fn_17+0x2c>
			1a80: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1a84:	mov    rcx,rax
    1a87:	mov    r13,rax
    1a8a:	test   rax,rcx
    1a8d:	je     1b64 <botlish_fn_17+0x10c>
    1a93:	mov    rax,r13
    1a96:	mov    QWORD PTR [rsp+0x8],rax
    1a9b:	mov    rsi,r12
    1a9e:	mov    rdi,rbx
    1aa1:	call   1aa6 <botlish_fn_17+0x4e>
			1aa2: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1aa6:	mov    rcx,rax
    1aa9:	test   rcx,rcx
    1aac:	je     1b64 <botlish_fn_17+0x10c>
    1ab2:	mov    QWORD PTR [rsp+0x10],rcx
    1ab7:	mov    edx,0x1
    1abc:	mov    rax,r13
    1abf:	test   rax,0x1
    1ac5:	jne    1ae8 <botlish_fn_17+0x90>
    1acb:	xor    edx,edx
    1acd:	mov    rax,r13
    1ad0:	test   rax,0x7
    1ad6:	jne    1ae8 <botlish_fn_17+0x90>
    1adc:	mov    rax,r13
    1adf:	movzx  rax,BYTE PTR [rax]
    1ae3:	cmp    al,0x1
    1ae5:	sete   dl
    1ae8:	test   dl,dl
    1aea:	jne    1b0a <botlish_fn_17+0xb2>
    1af0:	mov    rdi,rbx
    1af3:	mov    rax,QWORD PTR [rdi+0x10]
    1af7:	mov    rcx,QWORD PTR [rax]
    1afa:	xor    rdx,rdx
    1afd:	mov    rsi,r13
    1b00:	call   1b05 <botlish_fn_17+0xad>
			1b01: R_X86_64_PLT32	rt_type_error-0x4
    1b05:	jmp    1b64 <botlish_fn_17+0x10c>
    1b0a:	mov    eax,0x1
    1b0f:	test   rcx,0x1
    1b16:	je     1b24 <botlish_fn_17+0xcc>
    1b1c:	mov    r8,rcx
    1b1f:	jmp    1b47 <botlish_fn_17+0xef>
    1b24:	xor    eax,eax
    1b26:	test   rcx,0x7
    1b2d:	je     1b3b <botlish_fn_17+0xe3>
    1b33:	mov    r8,rcx
    1b36:	jmp    1b47 <botlish_fn_17+0xef>
    1b3b:	movzx  rax,BYTE PTR [rcx]
    1b3f:	mov    r8,rcx
    1b42:	cmp    al,0x1
    1b44:	sete   al
    1b47:	test   al,al
    1b49:	jne    1b7f <botlish_fn_17+0x127>
    1b4f:	mov    rdi,rbx
    1b52:	mov    rax,QWORD PTR [rdi+0x10]
    1b56:	mov    rcx,QWORD PTR [rax]
    1b59:	xor    rdx,rdx
    1b5c:	mov    rsi,r8
    1b5f:	call   1b64 <botlish_fn_17+0x10c>
			1b60: R_X86_64_PLT32	rt_type_error-0x4
    1b64:	xor    rax,rax
    1b67:	mov    rbx,QWORD PTR [rsp+0x20]
    1b6c:	mov    r12,QWORD PTR [rsp+0x28]
    1b71:	mov    r13,QWORD PTR [rsp+0x30]
    1b76:	add    rsp,0x40
    1b7a:	mov    rsp,rbp
    1b7d:	pop    rbp
    1b7e:	ret
    1b7f:	mov    rcx,r8
    1b82:	mov    rsi,r13
    1b85:	mov    rax,rsi
    1b88:	and    rax,rcx
    1b8b:	test   rax,0x1
    1b91:	jne    1ba2 <botlish_fn_17+0x14a>
    1b97:	mov    rdx,r8
    1b9a:	mov    rsi,r13
    1b9d:	jmp    1bc0 <botlish_fn_17+0x168>
    1ba2:	mov    rcx,r8
    1ba5:	lea    rax,[rcx-0x1]
    1ba9:	mov    rsi,r13
    1bac:	add    rsi,rax
    1baf:	seto   al
    1bb2:	test   al,al
    1bb4:	je     1bcb <botlish_fn_17+0x173>
    1bba:	mov    rdx,r8
    1bbd:	mov    rsi,r13
    1bc0:	mov    rdi,rbx
    1bc3:	call   1bc8 <botlish_fn_17+0x170>
			1bc4: R_X86_64_PLT32	rt_int_add-0x4
    1bc8:	mov    rsi,rax
    1bcb:	mov    QWORD PTR [rsp+0x8],rsi
    1bd0:	mov    QWORD PTR [rsp+0x10],0x3
    1bd9:	test   rsi,0x1
    1be0:	je     1c03 <botlish_fn_17+0x1ab>
    1be6:	mov    rax,rsi
    1be9:	add    rax,0x2
    1bed:	mov    rcx,rax
    1bf0:	seto   al
    1bf3:	test   al,al
    1bf5:	jne    1c03 <botlish_fn_17+0x1ab>
    1bfb:	mov    rsi,rcx
    1bfe:	jmp    1c13 <botlish_fn_17+0x1bb>
    1c03:	mov    edx,0x3
    1c08:	mov    rdi,rbx
    1c0b:	call   1c10 <botlish_fn_17+0x1b8>
			1c0c: R_X86_64_PLT32	rt_int_add-0x4
    1c10:	mov    rsi,rax
    1c13:	mov    QWORD PTR [rsp+0x8],rsi
    1c18:	mov    edx,0x7
    1c1d:	mov    rdi,rdx
    1c20:	mov    QWORD PTR [rsp+0x10],0x7
    1c29:	test   rsi,0x1
    1c30:	jne    1c3e <botlish_fn_17+0x1e6>
    1c36:	mov    rdx,rdi
    1c39:	jmp    1c6a <botlish_fn_17+0x212>
    1c3e:	mov    rax,rsi
    1c41:	sar    rax,1
    1c44:	imul   QWORD PTR [rip+0xf5]        # 1d40 <botlish_fn_17+0x2e8>
    1c4b:	seto   cl
    1c4e:	or     rax,0x1
    1c52:	test   cl,cl
    1c54:	je     1c62 <botlish_fn_17+0x20a>
    1c5a:	mov    rdx,rdi
    1c5d:	jmp    1c6a <botlish_fn_17+0x212>
    1c62:	mov    rsi,rax
    1c65:	jmp    1c75 <botlish_fn_17+0x21d>
    1c6a:	mov    rdi,rbx
    1c6d:	call   1c72 <botlish_fn_17+0x21a>
			1c6e: R_X86_64_PLT32	rt_int_mul-0x4
    1c72:	mov    rsi,rax
    1c75:	mov    QWORD PTR [rsp+0x8],rsi
    1c7a:	mov    r13,rsi
    1c7d:	mov    rsi,r12
    1c80:	mov    rdi,rbx
    1c83:	call   1c88 <botlish_fn_17+0x230>
			1c84: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1c88:	mov    QWORD PTR [rsp],rax
    1c8c:	mov    QWORD PTR [rsp+0x10],0x5
    1c95:	test   rax,0x1
    1c9b:	mov    rcx,rax
    1c9e:	je     1ccd <botlish_fn_17+0x275>
    1ca4:	mov    rax,rcx
    1ca7:	sar    rax,1
    1caa:	imul   QWORD PTR [rip+0x97]        # 1d48 <botlish_fn_17+0x2f0>
    1cb1:	seto   sil
    1cb5:	or     rax,0x1
    1cb9:	test   sil,sil
    1cbc:	jne    1ccd <botlish_fn_17+0x275>
    1cc2:	mov    rdx,rax
    1cc5:	mov    rsi,r13
    1cc8:	jmp    1ce3 <botlish_fn_17+0x28b>
    1ccd:	mov    edx,0x5
    1cd2:	mov    rsi,rcx
    1cd5:	mov    rdi,rbx
    1cd8:	call   1cdd <botlish_fn_17+0x285>
			1cd9: R_X86_64_PLT32	rt_int_mul-0x4
    1cdd:	mov    rdx,rax
    1ce0:	mov    rsi,r13
    1ce3:	mov    rdi,rsi
    1ce6:	and    rdi,rdx
    1ce9:	test   rdi,0x1
    1cf0:	jne    1d16 <botlish_fn_17+0x2be>
    1cf6:	mov    rdi,rbx
    1cf9:	call   1cfe <botlish_fn_17+0x2a6>
			1cfa: R_X86_64_PLT32	rt_int_cmp-0x4
    1cfe:	mov    esi,0x2
    1d03:	test   rax,rax
    1d06:	mov    rax,rsi
    1d09:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1d40 <botlish_fn_17+0x2e8>
    1d11:	jmp    1d26 <botlish_fn_17+0x2ce>
    1d16:	mov    eax,0x2
    1d1b:	cmp    rsi,rdx
    1d1e:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1d40 <botlish_fn_17+0x2e8>
    1d26:	mov    rbx,QWORD PTR [rsp+0x20]
    1d2b:	mov    r12,QWORD PTR [rsp+0x28]
    1d30:	mov    r13,QWORD PTR [rsp+0x30]
    1d35:	add    rsp,0x40
    1d39:	mov    rsp,rbp
    1d3c:	pop    rbp
    1d3d:	ret
    1d3e:	add    BYTE PTR [rax],al
    1d40:	(bad)
    1d41:	add    BYTE PTR [rax],al
    1d43:	add    BYTE PTR [rax],al
    1d45:	add    BYTE PTR [rax],al
    1d47:	add    BYTE PTR [rax+rax*1],al
    1d4a:	add    BYTE PTR [rax],al
    1d4c:	add    BYTE PTR [rax],al
	...

0000000000001d50 <botlish_entry_17: ht_should_grow<HashTable>>:
    1d50:	push   rbp
    1d51:	mov    rbp,rsp
    1d54:	mov    rsi,QWORD PTR [rdx]
    1d57:	call   1d5c <botlish_entry_17+0xc>
			1d58: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1d5c:	mov    rsp,rbp
    1d5f:	pop    rbp
    1d60:	ret
    1d61:	add    BYTE PTR [rax],al
    1d63:	add    BYTE PTR [rax],al
    1d65:	add    BYTE PTR [rax],al
	...

0000000000001d68 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1d68:	push   rbp
    1d69:	mov    rbp,rsp
    1d6c:	sub    rsp,0x40
    1d70:	mov    QWORD PTR [rsp+0x20],rbx
    1d75:	mov    QWORD PTR [rsp+0x28],r12
    1d7a:	mov    QWORD PTR [rsp+0x30],r13
    1d7f:	mov    rbx,rdi
    1d82:	mov    QWORD PTR [rsp+0x10],0x0
    1d8b:	mov    QWORD PTR [rsp],rsi
    1d8f:	mov    r12,rsi
    1d92:	mov    rsi,r12
    1d95:	mov    rdi,rbx
    1d98:	call   1d9d <botlish_fn_18+0x35>
			1d99: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1d9d:	test   rax,rax
    1da0:	mov    r13,rax
    1da3:	je     1f91 <botlish_fn_18+0x229>
    1da9:	mov    rsi,r12
    1dac:	mov    rdi,rbx
    1daf:	call   1db4 <botlish_fn_18+0x4c>
			1db0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1db4:	mov    r11,rax
    1db7:	test   r11,r11
    1dba:	je     1f91 <botlish_fn_18+0x229>
    1dc0:	mov    ecx,0x1
    1dc5:	mov    rax,r13
    1dc8:	test   rax,0x1
    1dce:	je     1ddc <botlish_fn_18+0x74>
    1dd4:	mov    r13,rax
    1dd7:	jmp    1e00 <botlish_fn_18+0x98>
    1ddc:	xor    ecx,ecx
    1dde:	test   rax,0x7
    1de4:	je     1df2 <botlish_fn_18+0x8a>
    1dea:	mov    r13,rax
    1ded:	jmp    1e00 <botlish_fn_18+0x98>
    1df2:	movzx  rcx,BYTE PTR [rax]
    1df6:	mov    r13,rax
    1df9:	rex cmp cl,0x1
    1dfd:	sete   cl
    1e00:	test   cl,cl
    1e02:	jne    1e23 <botlish_fn_18+0xbb>
    1e08:	mov    rdi,rbx
    1e0b:	mov    rsi,QWORD PTR [rdi+0x10]
    1e0f:	mov    rcx,QWORD PTR [rsi+0x8]
    1e13:	xor    rdx,rdx
    1e16:	mov    rsi,r13
    1e19:	call   1e1e <botlish_fn_18+0xb6>
			1e1a: R_X86_64_PLT32	rt_type_error-0x4
    1e1e:	jmp    1f91 <botlish_fn_18+0x229>
    1e23:	mov    rsi,r13
    1e26:	mov    eax,0x1
    1e2b:	test   r11,0x1
    1e32:	je     1e40 <botlish_fn_18+0xd8>
    1e38:	mov    r8,r11
    1e3b:	jmp    1e65 <botlish_fn_18+0xfd>
    1e40:	xor    eax,eax
    1e42:	test   r11,0x7
    1e49:	je     1e57 <botlish_fn_18+0xef>
    1e4f:	mov    r8,r11
    1e52:	jmp    1e65 <botlish_fn_18+0xfd>
    1e57:	movzx  r10,BYTE PTR [r11]
    1e5b:	mov    r8,r11
    1e5e:	cmp    r10b,0x1
    1e62:	sete   al
    1e65:	test   al,al
    1e67:	jne    1e88 <botlish_fn_18+0x120>
    1e6d:	mov    rdi,rbx
    1e70:	mov    rax,QWORD PTR [rdi+0x10]
    1e74:	mov    rcx,QWORD PTR [rax+0x8]
    1e78:	xor    rdx,rdx
    1e7b:	mov    rsi,r8
    1e7e:	call   1e83 <botlish_fn_18+0x11b>
			1e7f: R_X86_64_PLT32	rt_type_error-0x4
    1e83:	jmp    1f91 <botlish_fn_18+0x229>
    1e88:	mov    r11,r8
    1e8b:	mov    rax,rsi
    1e8e:	and    rax,r11
    1e91:	test   rax,0x1
    1e97:	jne    1ebd <botlish_fn_18+0x155>
    1e9d:	mov    rdx,r8
    1ea0:	mov    rdi,rbx
    1ea3:	call   1ea8 <botlish_fn_18+0x140>
			1ea4: R_X86_64_PLT32	rt_int_cmp-0x4
    1ea8:	mov    ecx,0x2
    1ead:	test   rax,rax
    1eb0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1fc8 <botlish_fn_18+0x260>
    1eb8:	jmp    1ed0 <botlish_fn_18+0x168>
    1ebd:	mov    ecx,0x2
    1ec2:	mov    r11,r8
    1ec5:	cmp    rsi,r11
    1ec8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1fc8 <botlish_fn_18+0x260>
    1ed0:	cmp    rcx,0x6
    1ed4:	je     1f6a <botlish_fn_18+0x202>
    1eda:	mov    rsi,r12
    1edd:	mov    rdi,rbx
    1ee0:	call   1ee5 <botlish_fn_18+0x17d>
			1ee1: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1ee5:	mov    QWORD PTR [rsp+0x8],rax
    1eea:	mov    QWORD PTR [rsp+0x10],0x5
    1ef3:	test   rax,0x1
    1ef9:	mov    rsi,rax
    1efc:	je     1f29 <botlish_fn_18+0x1c1>
    1f02:	mov    rcx,rsi
    1f05:	mov    rax,rcx
    1f08:	sar    rax,1
    1f0b:	imul   QWORD PTR [rip+0xbe]        # 1fd0 <botlish_fn_18+0x268>
    1f12:	seto   cl
    1f15:	or     rax,0x1
    1f19:	test   cl,cl
    1f1b:	jne    1f29 <botlish_fn_18+0x1c1>
    1f21:	mov    rdx,rax
    1f24:	jmp    1f39 <botlish_fn_18+0x1d1>
    1f29:	mov    edx,0x5
    1f2e:	mov    rdi,rbx
    1f31:	call   1f36 <botlish_fn_18+0x1ce>
			1f32: R_X86_64_PLT32	rt_int_mul-0x4
    1f36:	mov    rdx,rax
    1f39:	mov    QWORD PTR [rsp+0x8],rdx
    1f3e:	mov    rsi,r12
    1f41:	mov    rdi,rbx
    1f44:	call   1f49 <botlish_fn_18+0x1e1>
			1f45: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1f49:	test   rax,rax
    1f4c:	je     1f91 <botlish_fn_18+0x229>
    1f52:	mov    rbx,QWORD PTR [rsp+0x20]
    1f57:	mov    r12,QWORD PTR [rsp+0x28]
    1f5c:	mov    r13,QWORD PTR [rsp+0x30]
    1f61:	add    rsp,0x40
    1f65:	mov    rsp,rbp
    1f68:	pop    rbp
    1f69:	ret
    1f6a:	mov    rsi,r12
    1f6d:	mov    rdi,rbx
    1f70:	call   1f75 <botlish_fn_18+0x20d>
			1f71: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1f75:	mov    QWORD PTR [rsp+0x8],rax
    1f7a:	mov    rdx,rax
    1f7d:	mov    rsi,r12
    1f80:	mov    rdi,rbx
    1f83:	call   1f88 <botlish_fn_18+0x220>
			1f84: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1f88:	test   rax,rax
    1f8b:	jne    1fac <botlish_fn_18+0x244>
    1f91:	xor    rax,rax
    1f94:	mov    rbx,QWORD PTR [rsp+0x20]
    1f99:	mov    r12,QWORD PTR [rsp+0x28]
    1f9e:	mov    r13,QWORD PTR [rsp+0x30]
    1fa3:	add    rsp,0x40
    1fa7:	mov    rsp,rbp
    1faa:	pop    rbp
    1fab:	ret
    1fac:	mov    rbx,QWORD PTR [rsp+0x20]
    1fb1:	mov    r12,QWORD PTR [rsp+0x28]
    1fb6:	mov    r13,QWORD PTR [rsp+0x30]
    1fbb:	add    rsp,0x40
    1fbf:	mov    rsp,rbp
    1fc2:	pop    rbp
    1fc3:	ret
    1fc4:	add    BYTE PTR [rax],al
    1fc6:	add    BYTE PTR [rax],al
    1fc8:	(bad)
    1fc9:	add    BYTE PTR [rax],al
    1fcb:	add    BYTE PTR [rax],al
    1fcd:	add    BYTE PTR [rax],al
    1fcf:	add    BYTE PTR [rax+rax*1],al
    1fd2:	add    BYTE PTR [rax],al
    1fd4:	add    BYTE PTR [rax],al
	...

0000000000001fd8 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1fd8:	push   rbp
    1fd9:	mov    rbp,rsp
    1fdc:	mov    rsi,QWORD PTR [rdx]
    1fdf:	call   1fe4 <botlish_entry_18+0xc>
			1fe0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1fe4:	mov    rsp,rbp
    1fe7:	pop    rbp
    1fe8:	ret
    1fe9:	add    BYTE PTR [rax],al
    1feb:	add    BYTE PTR [rax],al
    1fed:	add    BYTE PTR [rax],al
	...

0000000000001ff0 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    1ff0:	push   rbp
    1ff1:	mov    rbp,rsp
    1ff4:	sub    rsp,0x70
    1ff8:	mov    QWORD PTR [rsp+0x40],rbx
    1ffd:	mov    QWORD PTR [rsp+0x48],r12
    2002:	mov    QWORD PTR [rsp+0x50],r13
    2007:	mov    QWORD PTR [rsp+0x58],r14
    200c:	mov    QWORD PTR [rsp+0x60],r15
    2011:	mov    r12,rdi
    2014:	mov    r14,r8
    2017:	mov    QWORD PTR [rsp+0x30],rcx
    201c:	mov    QWORD PTR [rsp],rsi
    2020:	mov    rax,QWORD PTR [rsi+0x18]
    2024:	mov    rbx,rsi
    2027:	mov    rsi,QWORD PTR [rax]
    202a:	test   rdx,0x1
    2031:	je     23d6 <botlish_fn_19+0x3e6>
    2037:	mov    rcx,QWORD PTR [rsi+0x8]
    203b:	mov    rax,rdx
    203e:	sar    rax,1
    2041:	mov    r15,rdx
    2044:	cmp    rax,rcx
    2047:	jb     205a <botlish_fn_19+0x6a>
    204d:	jmp    23d9 <botlish_fn_19+0x3e9>
    2052:	mov    rsi,rax
    2055:	jmp    2062 <botlish_fn_19+0x72>
    205a:	mov    rcx,QWORD PTR [rsi+0x10]
    205e:	mov    rsi,QWORD PTR [rcx+rax*8]
    2062:	mov    QWORD PTR [rsp+0x8],rsi
    2067:	mov    r13,rsi
    206a:	mov    rax,QWORD PTR [rbx+0x18]
    206e:	mov    rsi,QWORD PTR [rax]
    2071:	mov    rdx,r15
    2074:	test   rdx,0x1
    207b:	je     23f2 <botlish_fn_19+0x402>
    2081:	mov    rcx,QWORD PTR [rsi+0x8]
    2085:	mov    rdx,r15
    2088:	mov    rax,rdx
    208b:	sar    rax,1
    208e:	cmp    rax,rcx
    2091:	jae    23f2 <botlish_fn_19+0x402>
    2097:	mov    rcx,QWORD PTR [rsi+0x18]
    209b:	test   rcx,rcx
    209e:	je     23f2 <botlish_fn_19+0x402>
    20a4:	mov    rcx,QWORD PTR [rsi+0x10]
    20a8:	mov    QWORD PTR [rcx+rax*8],0x3
    20b0:	mov    rax,QWORD PTR [rbx+0x18]
    20b4:	mov    rsi,QWORD PTR [rax+0x8]
    20b8:	mov    rdx,r15
    20bb:	test   rdx,0x1
    20c2:	je     2410 <botlish_fn_19+0x420>
    20c8:	mov    rcx,QWORD PTR [rsi+0x8]
    20cc:	mov    rdx,r15
    20cf:	mov    rax,rdx
    20d2:	sar    rax,1
    20d5:	cmp    rax,rcx
    20d8:	jae    241a <botlish_fn_19+0x42a>
    20de:	mov    rcx,QWORD PTR [rsi+0x18]
    20e2:	test   rcx,rcx
    20e5:	je     2424 <botlish_fn_19+0x434>
    20eb:	mov    rcx,QWORD PTR [rsp+0x30]
    20f0:	mov    r8,QWORD PTR [rsi+0x10]
    20f4:	mov    QWORD PTR [r8+rax*8],rcx
    20f8:	mov    r10,QWORD PTR [rbx+0x18]
    20fc:	mov    rsi,QWORD PTR [r10+0x10]
    2100:	mov    rdx,r15
    2103:	test   rdx,0x1
    210a:	je     2442 <botlish_fn_19+0x452>
    2110:	mov    rcx,QWORD PTR [rsi+0x8]
    2114:	mov    rdx,r15
    2117:	mov    rax,rdx
    211a:	sar    rax,1
    211d:	cmp    rax,rcx
    2120:	jae    244d <botlish_fn_19+0x45d>
    2126:	mov    rcx,QWORD PTR [rsi+0x18]
    212a:	test   rcx,rcx
    212d:	je     2458 <botlish_fn_19+0x468>
    2133:	mov    rcx,r14
    2136:	mov    rdx,QWORD PTR [rsi+0x10]
    213a:	mov    QWORD PTR [rdx+rax*8],rcx
    213e:	mov    rax,QWORD PTR [rbx+0x18]
    2142:	mov    rsi,QWORD PTR [rax+0x18]
    2146:	mov    QWORD PTR [rsp+0x10],rsi
    214b:	mov    r15,rsi
    214e:	mov    QWORD PTR [rsp+0x18],0x1
    2157:	mov    rsi,rbx
    215a:	mov    rdi,r12
    215d:	call   2162 <botlish_fn_19+0x172>
			215e: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2162:	test   rax,rax
    2165:	je     237f <botlish_fn_19+0x38f>
    216b:	mov    QWORD PTR [rsp+0x20],rax
    2170:	mov    edx,0x3
    2175:	mov    r14,rdx
    2178:	mov    QWORD PTR [rsp+0x28],0x3
    2181:	mov    ecx,0x1
    2186:	test   rax,0x1
    218c:	je     219a <botlish_fn_19+0x1aa>
    2192:	mov    rsi,rax
    2195:	jmp    21be <botlish_fn_19+0x1ce>
    219a:	xor    ecx,ecx
    219c:	test   rax,0x7
    21a2:	je     21b0 <botlish_fn_19+0x1c0>
    21a8:	mov    rsi,rax
    21ab:	jmp    21be <botlish_fn_19+0x1ce>
    21b0:	movzx  rcx,BYTE PTR [rax]
    21b4:	mov    rsi,rax
    21b7:	rex cmp cl,0x1
    21bb:	sete   cl
    21be:	test   cl,cl
    21c0:	jne    21dd <botlish_fn_19+0x1ed>
    21c6:	mov    rdi,r12
    21c9:	mov    rax,QWORD PTR [rdi+0x10]
    21cd:	mov    rcx,QWORD PTR [rax]
    21d0:	xor    rdx,rdx
    21d3:	call   21d8 <botlish_fn_19+0x1e8>
			21d4: R_X86_64_PLT32	rt_type_error-0x4
    21d8:	jmp    237f <botlish_fn_19+0x38f>
    21dd:	test   rsi,0x1
    21e4:	je     21fc <botlish_fn_19+0x20c>
    21ea:	mov    rcx,rsi
    21ed:	add    rcx,0x2
    21f1:	seto   al
    21f4:	test   al,al
    21f6:	je     220a <botlish_fn_19+0x21a>
    21fc:	mov    rdx,r14
    21ff:	mov    rdi,r12
    2202:	call   2207 <botlish_fn_19+0x217>
			2203: R_X86_64_PLT32	rt_int_add-0x4
    2207:	mov    rcx,rax
    220a:	mov    rsi,r15
    220d:	mov    rax,QWORD PTR [rsi+0x8]
    2211:	test   rax,rax
    2214:	je     2477 <botlish_fn_19+0x487>
    221a:	mov    rax,QWORD PTR [rsi+0x18]
    221e:	test   rax,rax
    2221:	jne    2234 <botlish_fn_19+0x244>
    2227:	jmp    2477 <botlish_fn_19+0x487>
    222c:	mov    rsi,r13
    222f:	jmp    223e <botlish_fn_19+0x24e>
    2234:	mov    rax,QWORD PTR [rsi+0x10]
    2238:	mov    QWORD PTR [rax],rcx
    223b:	mov    rsi,r13
    223e:	test   rsi,0x1
    2245:	jne    226d <botlish_fn_19+0x27d>
    224b:	mov    edx,0x5
    2250:	mov    rdi,r12
    2253:	call   2258 <botlish_fn_19+0x268>
			2254: R_X86_64_PLT32	rt_int_cmp-0x4
    2258:	mov    ecx,0x2
    225d:	test   rax,rax
    2260:	cmove  rcx,QWORD PTR [rip+0x258]        # 24c0 <botlish_fn_19+0x4d0>
    2268:	jmp    227e <botlish_fn_19+0x28e>
    226d:	mov    ecx,0x2
    2272:	cmp    rsi,0x5
    2276:	cmove  rcx,QWORD PTR [rip+0x242]        # 24c0 <botlish_fn_19+0x4d0>
    227e:	cmp    rcx,0x6
    2282:	je     2290 <botlish_fn_19+0x2a0>
    2288:	mov    rax,rbx
    228b:	jmp    23b4 <botlish_fn_19+0x3c4>
    2290:	mov    r10,QWORD PTR [rbx+0x18]
    2294:	mov    rsi,QWORD PTR [r10+0x18]
    2298:	mov    QWORD PTR [rsp+0x8],rsi
    229d:	mov    r13,rsi
    22a0:	mov    QWORD PTR [rsp+0x10],0x3
    22a9:	mov    rsi,rbx
    22ac:	mov    rdi,r12
    22af:	call   22b4 <botlish_fn_19+0x2c4>
			22b0: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    22b4:	test   rax,rax
    22b7:	je     237f <botlish_fn_19+0x38f>
    22bd:	mov    QWORD PTR [rsp+0x18],rax
    22c2:	mov    QWORD PTR [rsp+0x20],0x3
    22cb:	mov    ecx,0x1
    22d0:	test   rax,0x1
    22d6:	je     22e4 <botlish_fn_19+0x2f4>
    22dc:	mov    rsi,rax
    22df:	jmp    2308 <botlish_fn_19+0x318>
    22e4:	xor    ecx,ecx
    22e6:	test   rax,0x7
    22ec:	je     22fa <botlish_fn_19+0x30a>
    22f2:	mov    rsi,rax
    22f5:	jmp    2308 <botlish_fn_19+0x318>
    22fa:	movzx  rcx,BYTE PTR [rax]
    22fe:	mov    rsi,rax
    2301:	rex cmp cl,0x1
    2305:	sete   cl
    2308:	test   cl,cl
    230a:	jne    2328 <botlish_fn_19+0x338>
    2310:	mov    rdi,r12
    2313:	mov    rax,QWORD PTR [rdi+0x10]
    2317:	mov    rcx,QWORD PTR [rax+0x10]
    231b:	xor    rdx,rdx
    231e:	call   2323 <botlish_fn_19+0x333>
			231f: R_X86_64_PLT32	rt_type_error-0x4
    2323:	jmp    237f <botlish_fn_19+0x38f>
    2328:	test   rsi,0x1
    232f:	je     234e <botlish_fn_19+0x35e>
    2335:	mov    rcx,rsi
    2338:	sub    rcx,0x3
    233c:	seto   al
    233f:	add    rcx,0x1
    2346:	test   al,al
    2348:	je     235c <botlish_fn_19+0x36c>
    234e:	mov    rdx,r14
    2351:	mov    rdi,r12
    2354:	call   2359 <botlish_fn_19+0x369>
			2355: R_X86_64_PLT32	rt_int_sub-0x4
    2359:	mov    rcx,rax
    235c:	mov    rsi,r13
    235f:	mov    rax,QWORD PTR [rsi+0x8]
    2363:	cmp    rax,0x1
    2367:	jbe    2492 <botlish_fn_19+0x4a2>
    236d:	mov    rax,QWORD PTR [rsi+0x18]
    2371:	test   rax,rax
    2374:	jne    23a9 <botlish_fn_19+0x3b9>
    237a:	jmp    249d <botlish_fn_19+0x4ad>
    237f:	xor    rax,rax
    2382:	mov    rbx,QWORD PTR [rsp+0x40]
    2387:	mov    r12,QWORD PTR [rsp+0x48]
    238c:	mov    r13,QWORD PTR [rsp+0x50]
    2391:	mov    r14,QWORD PTR [rsp+0x58]
    2396:	mov    r15,QWORD PTR [rsp+0x60]
    239b:	add    rsp,0x70
    239f:	mov    rsp,rbp
    23a2:	pop    rbp
    23a3:	ret
    23a4:	jmp    23b1 <botlish_fn_19+0x3c1>
    23a9:	mov    rax,QWORD PTR [rsi+0x10]
    23ad:	mov    QWORD PTR [rax+0x8],rcx
    23b1:	mov    rax,rbx
    23b4:	mov    rbx,QWORD PTR [rsp+0x40]
    23b9:	mov    r12,QWORD PTR [rsp+0x48]
    23be:	mov    r13,QWORD PTR [rsp+0x50]
    23c3:	mov    r14,QWORD PTR [rsp+0x58]
    23c8:	mov    r15,QWORD PTR [rsp+0x60]
    23cd:	add    rsp,0x70
    23d1:	mov    rsp,rbp
    23d4:	pop    rbp
    23d5:	ret
    23d6:	mov    r15,rdx
    23d9:	mov    rdx,r15
    23dc:	mov    rdi,r12
    23df:	call   23e4 <botlish_fn_19+0x3f4>
			23e0: R_X86_64_PLT32	rt_mutarray_get-0x4
    23e4:	test   rax,rax
    23e7:	jne    2052 <botlish_fn_19+0x62>
    23ed:	jmp    237f <botlish_fn_19+0x38f>
    23f2:	mov    ecx,0x3
    23f7:	mov    rdx,r15
    23fa:	mov    rdi,r12
    23fd:	call   2402 <botlish_fn_19+0x412>
			23fe: R_X86_64_PLT32	rt_mutarray_set-0x4
    2402:	test   rax,rax
    2405:	jne    20b0 <botlish_fn_19+0xc0>
    240b:	jmp    237f <botlish_fn_19+0x38f>
    2410:	mov    rcx,QWORD PTR [rsp+0x30]
    2415:	jmp    2429 <botlish_fn_19+0x439>
    241a:	mov    rcx,QWORD PTR [rsp+0x30]
    241f:	jmp    2429 <botlish_fn_19+0x439>
    2424:	mov    rcx,QWORD PTR [rsp+0x30]
    2429:	mov    rdx,r15
    242c:	mov    rdi,r12
    242f:	call   2434 <botlish_fn_19+0x444>
			2430: R_X86_64_PLT32	rt_mutarray_set-0x4
    2434:	test   rax,rax
    2437:	jne    20f8 <botlish_fn_19+0x108>
    243d:	jmp    237f <botlish_fn_19+0x38f>
    2442:	mov    rcx,r14
    2445:	mov    rdx,r15
    2448:	jmp    245e <botlish_fn_19+0x46e>
    244d:	mov    rcx,r14
    2450:	mov    rdx,r15
    2453:	jmp    245e <botlish_fn_19+0x46e>
    2458:	mov    rcx,r14
    245b:	mov    rdx,r15
    245e:	mov    rdx,r15
    2461:	mov    rdi,r12
    2464:	call   2469 <botlish_fn_19+0x479>
			2465: R_X86_64_PLT32	rt_mutarray_set-0x4
    2469:	test   rax,rax
    246c:	jne    213e <botlish_fn_19+0x14e>
    2472:	jmp    237f <botlish_fn_19+0x38f>
    2477:	mov    edx,0x1
    247c:	mov    rdi,r12
    247f:	call   2484 <botlish_fn_19+0x494>
			2480: R_X86_64_PLT32	rt_mutarray_set-0x4
    2484:	test   rax,rax
    2487:	jne    222c <botlish_fn_19+0x23c>
    248d:	jmp    237f <botlish_fn_19+0x38f>
    2492:	mov    rdx,r14
    2495:	mov    rdi,r12
    2498:	jmp    24a3 <botlish_fn_19+0x4b3>
    249d:	mov    rdx,r14
    24a0:	mov    rdi,r12
    24a3:	mov    rdx,r14
    24a6:	mov    rdi,r12
    24a9:	call   24ae <botlish_fn_19+0x4be>
			24aa: R_X86_64_PLT32	rt_mutarray_set-0x4
    24ae:	test   rax,rax
    24b1:	jne    23b1 <botlish_fn_19+0x3c1>
    24b7:	jmp    237f <botlish_fn_19+0x38f>
    24bc:	add    BYTE PTR [rax],al
    24be:	add    BYTE PTR [rax],al
    24c0:	(bad)
    24c1:	add    BYTE PTR [rax],al
    24c3:	add    BYTE PTR [rax],al
    24c5:	add    BYTE PTR [rax],al
	...

00000000000024c8 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    24c8:	push   rbp
    24c9:	mov    rbp,rsp
    24cc:	mov    rsi,QWORD PTR [rdx]
    24cf:	mov    r9,QWORD PTR [rdx+0x8]
    24d3:	mov    rcx,QWORD PTR [rdx+0x10]
    24d7:	mov    r8,QWORD PTR [rdx+0x18]
    24db:	mov    rdx,r9
    24de:	call   24e3 <botlish_entry_19+0x1b>
			24df: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    24e3:	mov    rsp,rbp
    24e6:	pop    rbp
    24e7:	ret

00000000000024e8 <botlish_fn_20: ht_set<HashTable, str, str>>:
    24e8:	push   rbp
    24e9:	mov    rbp,rsp
    24ec:	sub    rsp,0x60
    24f0:	mov    QWORD PTR [rsp+0x30],rbx
    24f5:	mov    QWORD PTR [rsp+0x38],r12
    24fa:	mov    QWORD PTR [rsp+0x40],r13
    24ff:	mov    QWORD PTR [rsp+0x48],r14
    2504:	mov    QWORD PTR [rsp+0x50],r15
    2509:	mov    r12,rdi
    250c:	mov    r14,rdx
    250f:	mov    QWORD PTR [rsp],rsi
    2513:	mov    r13,rsi
    2516:	mov    QWORD PTR [rsp+0x8],rdx
    251b:	mov    QWORD PTR [rsp+0x10],rcx
    2520:	mov    rbx,rcx
    2523:	mov    rdx,r14
    2526:	mov    rsi,r13
    2529:	mov    rdi,r12
    252c:	call   2531 <botlish_fn_20+0x49>
			252d: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2531:	test   rax,rax
    2534:	mov    rcx,rax
    2537:	je     2728 <botlish_fn_20+0x240>
    253d:	mov    r8,0xffffffffffffffff
    2544:	mov    QWORD PTR [rsp+0x20],r8
    2549:	mov    rdx,r14
    254c:	mov    rsi,r13
    254f:	mov    rdi,r12
    2552:	call   2557 <botlish_fn_20+0x6f>
			2553: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    2557:	test   rax,rax
    255a:	je     2728 <botlish_fn_20+0x240>
    2560:	mov    QWORD PTR [rsp+0x18],rax
    2565:	mov    rsi,r13
    2568:	mov    rcx,QWORD PTR [rsi+0x18]
    256c:	mov    rsi,QWORD PTR [rcx]
    256f:	test   rax,0x1
    2575:	je     2785 <botlish_fn_20+0x29d>
    257b:	mov    rdx,QWORD PTR [rsi+0x8]
    257f:	mov    rcx,rax
    2582:	sar    rcx,1
    2585:	mov    r15,rax
    2588:	cmp    rcx,rdx
    258b:	jb     259e <botlish_fn_20+0xb6>
    2591:	jmp    2788 <botlish_fn_20+0x2a0>
    2596:	mov    rsi,rax
    2599:	jmp    25a6 <botlish_fn_20+0xbe>
    259e:	mov    rax,QWORD PTR [rsi+0x10]
    25a2:	mov    rsi,QWORD PTR [rax+rcx*8]
    25a6:	test   rsi,0x1
    25ad:	jne    25d5 <botlish_fn_20+0xed>
    25b3:	mov    edx,0x3
    25b8:	mov    rdi,r12
    25bb:	call   25c0 <botlish_fn_20+0xd8>
			25bc: R_X86_64_PLT32	rt_int_cmp-0x4
    25c0:	mov    ecx,0x2
    25c5:	test   rax,rax
    25c8:	cmove  rcx,QWORD PTR [rip+0x208]        # 27d8 <botlish_fn_20+0x2f0>
    25d0:	jmp    25e6 <botlish_fn_20+0xfe>
    25d5:	mov    ecx,0x2
    25da:	cmp    rsi,0x3
    25de:	cmove  rcx,QWORD PTR [rip+0x1f2]        # 27d8 <botlish_fn_20+0x2f0>
    25e6:	cmp    rcx,0x6
    25ea:	je     26e8 <botlish_fn_20+0x200>
    25f0:	mov    rsi,r13
    25f3:	mov    rdi,r12
    25f6:	call   25fb <botlish_fn_20+0x113>
			25f7: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    25fb:	test   rax,rax
    25fe:	je     2728 <botlish_fn_20+0x240>
    2604:	cmp    rax,0x6
    2608:	je     264d <botlish_fn_20+0x165>
    260e:	mov    rcx,r14
    2611:	mov    rdx,r15
    2614:	mov    rsi,r13
    2617:	mov    rdi,r12
    261a:	mov    r8,rbx
    261d:	call   2622 <botlish_fn_20+0x13a>
			261e: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    2622:	test   rax,rax
    2625:	je     2728 <botlish_fn_20+0x240>
    262b:	mov    rbx,QWORD PTR [rsp+0x30]
    2630:	mov    r12,QWORD PTR [rsp+0x38]
    2635:	mov    r13,QWORD PTR [rsp+0x40]
    263a:	mov    r14,QWORD PTR [rsp+0x48]
    263f:	mov    r15,QWORD PTR [rsp+0x50]
    2644:	add    rsp,0x60
    2648:	mov    rsp,rbp
    264b:	pop    rbp
    264c:	ret
    264d:	mov    rsi,r13
    2650:	mov    rdi,r12
    2653:	call   2658 <botlish_fn_20+0x170>
			2654: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    2658:	mov    r11,rax
    265b:	mov    r13,rax
    265e:	test   rax,r11
    2661:	je     2728 <botlish_fn_20+0x240>
    2667:	mov    rax,r13
    266a:	mov    QWORD PTR [rsp],rax
    266e:	mov    rdx,r14
    2671:	mov    rsi,r13
    2674:	mov    rdi,r12
    2677:	call   267c <botlish_fn_20+0x194>
			2678: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    267c:	test   rax,rax
    267f:	mov    rcx,rax
    2682:	je     2728 <botlish_fn_20+0x240>
    2688:	mov    r8,QWORD PTR [rsp+0x20]
    268d:	mov    rdx,r14
    2690:	mov    rsi,r13
    2693:	mov    rdi,r12
    2696:	call   269b <botlish_fn_20+0x1b3>
			2697: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    269b:	test   rax,rax
    269e:	je     2728 <botlish_fn_20+0x240>
    26a4:	mov    QWORD PTR [rsp+0x18],rax
    26a9:	mov    rcx,r14
    26ac:	mov    rdx,rax
    26af:	mov    rsi,r13
    26b2:	mov    rdi,r12
    26b5:	mov    r8,rbx
    26b8:	call   26bd <botlish_fn_20+0x1d5>
			26b9: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    26bd:	test   rax,rax
    26c0:	je     2728 <botlish_fn_20+0x240>
    26c6:	mov    rbx,QWORD PTR [rsp+0x30]
    26cb:	mov    r12,QWORD PTR [rsp+0x38]
    26d0:	mov    r13,QWORD PTR [rsp+0x40]
    26d5:	mov    r14,QWORD PTR [rsp+0x48]
    26da:	mov    r15,QWORD PTR [rsp+0x50]
    26df:	add    rsp,0x60
    26e3:	mov    rsp,rbp
    26e6:	pop    rbp
    26e7:	ret
    26e8:	mov    rdx,r15
    26eb:	mov    rsi,r13
    26ee:	mov    rax,QWORD PTR [rsi+0x18]
    26f2:	mov    rsi,QWORD PTR [rax+0x10]
    26f6:	test   rdx,0x1
    26fd:	je     27a1 <botlish_fn_20+0x2b9>
    2703:	mov    rcx,QWORD PTR [rsi+0x8]
    2707:	mov    rax,rdx
    270a:	sar    rax,1
    270d:	cmp    rax,rcx
    2710:	jae    27ac <botlish_fn_20+0x2c4>
    2716:	mov    rcx,QWORD PTR [rsi+0x18]
    271a:	test   rcx,rcx
    271d:	jne    2755 <botlish_fn_20+0x26d>
    2723:	jmp    27b7 <botlish_fn_20+0x2cf>
    2728:	xor    rax,rax
    272b:	mov    rbx,QWORD PTR [rsp+0x30]
    2730:	mov    r12,QWORD PTR [rsp+0x38]
    2735:	mov    r13,QWORD PTR [rsp+0x40]
    273a:	mov    r14,QWORD PTR [rsp+0x48]
    273f:	mov    r15,QWORD PTR [rsp+0x50]
    2744:	add    rsp,0x60
    2748:	mov    rsp,rbp
    274b:	pop    rbp
    274c:	ret
    274d:	mov    rax,r13
    2750:	jmp    2763 <botlish_fn_20+0x27b>
    2755:	mov    rcx,rbx
    2758:	mov    rdx,QWORD PTR [rsi+0x10]
    275c:	mov    QWORD PTR [rdx+rax*8],rcx
    2760:	mov    rax,r13
    2763:	mov    rbx,QWORD PTR [rsp+0x30]
    2768:	mov    r12,QWORD PTR [rsp+0x38]
    276d:	mov    r13,QWORD PTR [rsp+0x40]
    2772:	mov    r14,QWORD PTR [rsp+0x48]
    2777:	mov    r15,QWORD PTR [rsp+0x50]
    277c:	add    rsp,0x60
    2780:	mov    rsp,rbp
    2783:	pop    rbp
    2784:	ret
    2785:	mov    r15,rax
    2788:	mov    rdx,r15
    278b:	mov    rdi,r12
    278e:	call   2793 <botlish_fn_20+0x2ab>
			278f: R_X86_64_PLT32	rt_mutarray_get-0x4
    2793:	test   rax,rax
    2796:	jne    2596 <botlish_fn_20+0xae>
    279c:	jmp    2728 <botlish_fn_20+0x240>
    27a1:	mov    rcx,rbx
    27a4:	mov    rdi,r12
    27a7:	jmp    27bd <botlish_fn_20+0x2d5>
    27ac:	mov    rcx,rbx
    27af:	mov    rdi,r12
    27b2:	jmp    27bd <botlish_fn_20+0x2d5>
    27b7:	mov    rcx,rbx
    27ba:	mov    rdi,r12
    27bd:	mov    rdi,r12
    27c0:	call   27c5 <botlish_fn_20+0x2dd>
			27c1: R_X86_64_PLT32	rt_mutarray_set-0x4
    27c5:	test   rax,rax
    27c8:	jne    274d <botlish_fn_20+0x265>
    27ce:	jmp    2728 <botlish_fn_20+0x240>
    27d3:	add    BYTE PTR [rax],al
    27d5:	add    BYTE PTR [rax],al
    27d7:	add    BYTE PTR [rsi],al
    27d9:	add    BYTE PTR [rax],al
    27db:	add    BYTE PTR [rax],al
    27dd:	add    BYTE PTR [rax],al
	...

00000000000027e0 <botlish_entry_20: ht_set<HashTable, str, str>>:
    27e0:	push   rbp
    27e1:	mov    rbp,rsp
    27e4:	mov    rsi,QWORD PTR [rdx]
    27e7:	mov    r8,QWORD PTR [rdx+0x8]
    27eb:	mov    rcx,QWORD PTR [rdx+0x10]
    27ef:	mov    rdx,r8
    27f2:	call   27f7 <botlish_entry_20+0x17>
			27f3: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    27f7:	mov    rsp,rbp
    27fa:	pop    rbp
    27fb:	ret
    27fc:	add    BYTE PTR [rax],al
	...

0000000000002800 <botlish_fn_21: ht_delete<HashTable, str>>:
    2800:	push   rbp
    2801:	mov    rbp,rsp
    2804:	sub    rsp,0x50
    2808:	mov    QWORD PTR [rsp+0x30],rbx
    280d:	mov    QWORD PTR [rsp+0x38],r12
    2812:	mov    QWORD PTR [rsp+0x40],r13
    2817:	mov    QWORD PTR [rsp+0x48],r14
    281c:	mov    r12,rdx
    281f:	mov    r13,rdi
    2822:	mov    QWORD PTR [rsp],rsi
    2826:	mov    rbx,rsi
    2829:	mov    rdx,r12
    282c:	mov    rsi,rbx
    282f:	mov    rdi,r13
    2832:	call   2837 <botlish_fn_21+0x37>
			2833: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2837:	test   rax,rax
    283a:	mov    rcx,rax
    283d:	je     2b57 <botlish_fn_21+0x357>
    2843:	mov    rdx,r12
    2846:	mov    rsi,rbx
    2849:	mov    rdi,r13
    284c:	call   2851 <botlish_fn_21+0x51>
			284d: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2851:	mov    rcx,rax
    2854:	mov    r12,rax
    2857:	test   rax,rcx
    285a:	je     2b57 <botlish_fn_21+0x357>
    2860:	mov    rax,r12
    2863:	test   rax,0x1
    2869:	jne    2894 <botlish_fn_21+0x94>
    286f:	mov    edx,0x1
    2874:	mov    rsi,r12
    2877:	mov    rdi,r13
    287a:	call   287f <botlish_fn_21+0x7f>
			287b: R_X86_64_PLT32	rt_int_cmp-0x4
    287f:	mov    ecx,0x2
    2884:	test   rax,rax
    2887:	cmovge rcx,QWORD PTR [rip+0x3b9]        # 2c48 <botlish_fn_21+0x448>
    288f:	jmp    28a4 <botlish_fn_21+0xa4>
    2894:	mov    ecx,0x2
    2899:	test   r12,r12
    289c:	cmovg  rcx,QWORD PTR [rip+0x3a4]        # 2c48 <botlish_fn_21+0x448>
    28a4:	cmp    rcx,0x6
    28a8:	je     28b6 <botlish_fn_21+0xb6>
    28ae:	mov    rax,rbx
    28b1:	jmp    2b87 <botlish_fn_21+0x387>
    28b6:	mov    rcx,QWORD PTR [rbx+0x18]
    28ba:	mov    rsi,QWORD PTR [rcx]
    28bd:	test   r12,0x1
    28c4:	je     2ba4 <botlish_fn_21+0x3a4>
    28ca:	mov    rdx,QWORD PTR [rsi+0x8]
    28ce:	mov    rcx,r12
    28d1:	sar    rcx,1
    28d4:	cmp    rcx,rdx
    28d7:	jae    2ba4 <botlish_fn_21+0x3a4>
    28dd:	mov    rdx,QWORD PTR [rsi+0x18]
    28e1:	test   rdx,rdx
    28e4:	je     2ba4 <botlish_fn_21+0x3a4>
    28ea:	mov    rax,QWORD PTR [rsi+0x10]
    28ee:	mov    QWORD PTR [rax+rcx*8],0x5
    28f6:	mov    rax,QWORD PTR [rbx+0x18]
    28fa:	mov    rsi,QWORD PTR [rax+0x8]
    28fe:	test   r12,0x1
    2905:	je     2bc2 <botlish_fn_21+0x3c2>
    290b:	mov    rdx,QWORD PTR [rsi+0x8]
    290f:	mov    rcx,r12
    2912:	sar    rcx,1
    2915:	cmp    rcx,rdx
    2918:	jae    2bc2 <botlish_fn_21+0x3c2>
    291e:	mov    rax,QWORD PTR [rsi+0x18]
    2922:	test   rax,rax
    2925:	je     2bc2 <botlish_fn_21+0x3c2>
    292b:	mov    rsi,QWORD PTR [rsi+0x10]
    292f:	mov    QWORD PTR [rsi+rcx*8],0xa
    2937:	mov    rsi,QWORD PTR [rbx+0x18]
    293b:	mov    rsi,QWORD PTR [rsi+0x10]
    293f:	test   r12,0x1
    2946:	je     2be0 <botlish_fn_21+0x3e0>
    294c:	mov    r10,QWORD PTR [rsi+0x8]
    2950:	mov    r9,r12
    2953:	sar    r9,1
    2956:	cmp    r9,r10
    2959:	jae    2be0 <botlish_fn_21+0x3e0>
    295f:	mov    rax,QWORD PTR [rsi+0x18]
    2963:	test   rax,rax
    2966:	je     2be0 <botlish_fn_21+0x3e0>
    296c:	mov    rax,QWORD PTR [rsi+0x10]
    2970:	mov    QWORD PTR [rax+r9*8],0xa
    2978:	mov    rax,QWORD PTR [rbx+0x18]
    297c:	mov    rsi,QWORD PTR [rax+0x18]
    2980:	mov    QWORD PTR [rsp+0x8],rsi
    2985:	mov    r14,rsi
    2988:	mov    QWORD PTR [rsp+0x10],0x1
    2991:	mov    rsi,rbx
    2994:	mov    rdi,r13
    2997:	call   299c <botlish_fn_21+0x19c>
			2998: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    299c:	test   rax,rax
    299f:	je     2b57 <botlish_fn_21+0x357>
    29a5:	mov    QWORD PTR [rsp+0x18],rax
    29aa:	mov    edx,0x3
    29af:	mov    r12,rdx
    29b2:	mov    QWORD PTR [rsp+0x20],0x3
    29bb:	mov    ecx,0x1
    29c0:	test   rax,0x1
    29c6:	je     29d4 <botlish_fn_21+0x1d4>
    29cc:	mov    rsi,rax
    29cf:	jmp    29f8 <botlish_fn_21+0x1f8>
    29d4:	xor    ecx,ecx
    29d6:	test   rax,0x7
    29dc:	je     29ea <botlish_fn_21+0x1ea>
    29e2:	mov    rsi,rax
    29e5:	jmp    29f8 <botlish_fn_21+0x1f8>
    29ea:	movzx  rcx,BYTE PTR [rax]
    29ee:	mov    rsi,rax
    29f1:	rex cmp cl,0x1
    29f5:	sete   cl
    29f8:	test   cl,cl
    29fa:	jne    2a18 <botlish_fn_21+0x218>
    2a00:	mov    rdi,r13
    2a03:	mov    rax,QWORD PTR [rdi+0x10]
    2a07:	mov    rcx,QWORD PTR [rax+0x10]
    2a0b:	xor    rdx,rdx
    2a0e:	call   2a13 <botlish_fn_21+0x213>
			2a0f: R_X86_64_PLT32	rt_type_error-0x4
    2a13:	jmp    2b57 <botlish_fn_21+0x357>
    2a18:	test   rsi,0x1
    2a1f:	je     2a3e <botlish_fn_21+0x23e>
    2a25:	mov    rcx,rsi
    2a28:	sub    rcx,0x3
    2a2c:	seto   al
    2a2f:	add    rcx,0x1
    2a36:	test   al,al
    2a38:	je     2a4c <botlish_fn_21+0x24c>
    2a3e:	mov    rdx,r12
    2a41:	mov    rdi,r13
    2a44:	call   2a49 <botlish_fn_21+0x249>
			2a45: R_X86_64_PLT32	rt_int_sub-0x4
    2a49:	mov    rcx,rax
    2a4c:	mov    rsi,r14
    2a4f:	mov    rax,QWORD PTR [rsi+0x8]
    2a53:	test   rax,rax
    2a56:	je     2bfe <botlish_fn_21+0x3fe>
    2a5c:	mov    rax,QWORD PTR [rsi+0x18]
    2a60:	test   rax,rax
    2a63:	je     2bfe <botlish_fn_21+0x3fe>
    2a69:	mov    rax,QWORD PTR [rsi+0x10]
    2a6d:	mov    QWORD PTR [rax],rcx
    2a70:	mov    rax,QWORD PTR [rbx+0x18]
    2a74:	mov    rsi,QWORD PTR [rax+0x18]
    2a78:	mov    QWORD PTR [rsp+0x8],rsi
    2a7d:	mov    r14,rsi
    2a80:	mov    QWORD PTR [rsp+0x10],0x3
    2a89:	mov    rsi,rbx
    2a8c:	mov    rdi,r13
    2a8f:	call   2a94 <botlish_fn_21+0x294>
			2a90: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    2a94:	test   rax,rax
    2a97:	je     2b57 <botlish_fn_21+0x357>
    2a9d:	mov    QWORD PTR [rsp+0x18],rax
    2aa2:	mov    QWORD PTR [rsp+0x20],0x3
    2aab:	mov    ecx,0x1
    2ab0:	test   rax,0x1
    2ab6:	je     2ac4 <botlish_fn_21+0x2c4>
    2abc:	mov    rsi,rax
    2abf:	jmp    2ae8 <botlish_fn_21+0x2e8>
    2ac4:	xor    ecx,ecx
    2ac6:	test   rax,0x7
    2acc:	je     2ada <botlish_fn_21+0x2da>
    2ad2:	mov    rsi,rax
    2ad5:	jmp    2ae8 <botlish_fn_21+0x2e8>
    2ada:	movzx  r10,BYTE PTR [rax]
    2ade:	mov    rsi,rax
    2ae1:	cmp    r10b,0x1
    2ae5:	sete   cl
    2ae8:	test   cl,cl
    2aea:	jne    2b07 <botlish_fn_21+0x307>
    2af0:	mov    rdi,r13
    2af3:	mov    rax,QWORD PTR [rdi+0x10]
    2af7:	mov    rcx,QWORD PTR [rax]
    2afa:	xor    rdx,rdx
    2afd:	call   2b02 <botlish_fn_21+0x302>
			2afe: R_X86_64_PLT32	rt_type_error-0x4
    2b02:	jmp    2b57 <botlish_fn_21+0x357>
    2b07:	test   rsi,0x1
    2b0e:	je     2b26 <botlish_fn_21+0x326>
    2b14:	mov    rcx,rsi
    2b17:	add    rcx,0x2
    2b1b:	seto   al
    2b1e:	test   al,al
    2b20:	je     2b34 <botlish_fn_21+0x334>
    2b26:	mov    rdx,r12
    2b29:	mov    rdi,r13
    2b2c:	call   2b31 <botlish_fn_21+0x331>
			2b2d: R_X86_64_PLT32	rt_int_add-0x4
    2b31:	mov    rcx,rax
    2b34:	mov    rsi,r14
    2b37:	mov    rax,QWORD PTR [rsi+0x8]
    2b3b:	cmp    rax,0x1
    2b3f:	jbe    2c19 <botlish_fn_21+0x419>
    2b45:	mov    rax,QWORD PTR [rsi+0x18]
    2b49:	test   rax,rax
    2b4c:	jne    2b7c <botlish_fn_21+0x37c>
    2b52:	jmp    2c24 <botlish_fn_21+0x424>
    2b57:	xor    rax,rax
    2b5a:	mov    rbx,QWORD PTR [rsp+0x30]
    2b5f:	mov    r12,QWORD PTR [rsp+0x38]
    2b64:	mov    r13,QWORD PTR [rsp+0x40]
    2b69:	mov    r14,QWORD PTR [rsp+0x48]
    2b6e:	add    rsp,0x50
    2b72:	mov    rsp,rbp
    2b75:	pop    rbp
    2b76:	ret
    2b77:	jmp    2b84 <botlish_fn_21+0x384>
    2b7c:	mov    rax,QWORD PTR [rsi+0x10]
    2b80:	mov    QWORD PTR [rax+0x8],rcx
    2b84:	mov    rax,rbx
    2b87:	mov    rbx,QWORD PTR [rsp+0x30]
    2b8c:	mov    r12,QWORD PTR [rsp+0x38]
    2b91:	mov    r13,QWORD PTR [rsp+0x40]
    2b96:	mov    r14,QWORD PTR [rsp+0x48]
    2b9b:	add    rsp,0x50
    2b9f:	mov    rsp,rbp
    2ba2:	pop    rbp
    2ba3:	ret
    2ba4:	mov    ecx,0x5
    2ba9:	mov    rdx,r12
    2bac:	mov    rdi,r13
    2baf:	call   2bb4 <botlish_fn_21+0x3b4>
			2bb0: R_X86_64_PLT32	rt_mutarray_set-0x4
    2bb4:	test   rax,rax
    2bb7:	jne    28f6 <botlish_fn_21+0xf6>
    2bbd:	jmp    2b57 <botlish_fn_21+0x357>
    2bc2:	mov    ecx,0xa
    2bc7:	mov    rdx,r12
    2bca:	mov    rdi,r13
    2bcd:	call   2bd2 <botlish_fn_21+0x3d2>
			2bce: R_X86_64_PLT32	rt_mutarray_set-0x4
    2bd2:	test   rax,rax
    2bd5:	jne    2937 <botlish_fn_21+0x137>
    2bdb:	jmp    2b57 <botlish_fn_21+0x357>
    2be0:	mov    ecx,0xa
    2be5:	mov    rdx,r12
    2be8:	mov    rdi,r13
    2beb:	call   2bf0 <botlish_fn_21+0x3f0>
			2bec: R_X86_64_PLT32	rt_mutarray_set-0x4
    2bf0:	test   rax,rax
    2bf3:	jne    2978 <botlish_fn_21+0x178>
    2bf9:	jmp    2b57 <botlish_fn_21+0x357>
    2bfe:	mov    edx,0x1
    2c03:	mov    rdi,r13
    2c06:	call   2c0b <botlish_fn_21+0x40b>
			2c07: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c0b:	test   rax,rax
    2c0e:	jne    2a70 <botlish_fn_21+0x270>
    2c14:	jmp    2b57 <botlish_fn_21+0x357>
    2c19:	mov    rdx,r12
    2c1c:	mov    rdi,r13
    2c1f:	jmp    2c2a <botlish_fn_21+0x42a>
    2c24:	mov    rdx,r12
    2c27:	mov    rdi,r13
    2c2a:	mov    rdx,r12
    2c2d:	mov    rdi,r13
    2c30:	call   2c35 <botlish_fn_21+0x435>
			2c31: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c35:	test   rax,rax
    2c38:	jne    2b84 <botlish_fn_21+0x384>
    2c3e:	jmp    2b57 <botlish_fn_21+0x357>
    2c43:	add    BYTE PTR [rax],al
    2c45:	add    BYTE PTR [rax],al
    2c47:	add    BYTE PTR [rsi],al
    2c49:	add    BYTE PTR [rax],al
    2c4b:	add    BYTE PTR [rax],al
    2c4d:	add    BYTE PTR [rax],al
	...

0000000000002c50 <botlish_entry_21: ht_delete<HashTable, str>>:
    2c50:	push   rbp
    2c51:	mov    rbp,rsp
    2c54:	mov    rsi,QWORD PTR [rdx]
    2c57:	mov    rdx,QWORD PTR [rdx+0x8]
    2c5b:	call   2c60 <botlish_entry_21+0x10>
			2c5c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2c60:	mov    rsp,rbp
    2c63:	pop    rbp
    2c64:	ret
    2c65:	add    BYTE PTR [rax],al
	...

0000000000002c68 <botlish_fn_22: sample_checks<generic>>:
    2c68:	push   rbp
    2c69:	mov    rbp,rsp
    2c6c:	sub    rsp,0xa0
    2c73:	mov    QWORD PTR [rsp+0x70],rbx
    2c78:	mov    QWORD PTR [rsp+0x78],r12
    2c7d:	mov    QWORD PTR [rsp+0x80],r13
    2c85:	mov    QWORD PTR [rsp+0x88],r14
    2c8d:	mov    QWORD PTR [rsp+0x90],r15
    2c95:	mov    r13,rdi
    2c98:	mov    QWORD PTR [rsp],0x0
    2ca0:	mov    QWORD PTR [rsp+0x8],0x0
    2ca9:	mov    QWORD PTR [rsp+0x10],0x0
    2cb2:	mov    QWORD PTR [rsp+0x18],0x0
    2cbb:	mov    QWORD PTR [rsp+0x20],0x0
    2cc4:	mov    QWORD PTR [rsp+0x28],0x0
    2ccd:	mov    rdi,r13
    2cd0:	call   2cd5 <botlish_fn_22+0x6d>
			2cd1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    2cd5:	test   rax,rax
    2cd8:	je     2f14 <botlish_fn_22+0x2ac>
    2cde:	mov    QWORD PTR [rsp],rax
    2ce2:	mov    rsi,rax
    2ce5:	mov    rdi,r13
    2ce8:	mov    rax,QWORD PTR [rdi+0x10]
    2cec:	mov    rdx,QWORD PTR [rax+0x18]
    2cf0:	mov    QWORD PTR [rsp+0x8],rdx
    2cf5:	mov    rax,QWORD PTR [rdi+0x10]
    2cf9:	mov    rcx,QWORD PTR [rax+0x20]
    2cfd:	mov    QWORD PTR [rsp+0x10],rcx
    2d02:	call   2d07 <botlish_fn_22+0x9f>
			2d03: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2d07:	test   rax,rax
    2d0a:	je     2f14 <botlish_fn_22+0x2ac>
    2d10:	mov    QWORD PTR [rsp],rax
    2d14:	mov    rdi,r13
    2d17:	mov    rsi,QWORD PTR [rdi+0x10]
    2d1b:	mov    rdx,QWORD PTR [rsi+0x28]
    2d1f:	mov    QWORD PTR [rsp+0x8],rdx
    2d24:	mov    rsi,QWORD PTR [rdi+0x10]
    2d28:	mov    rcx,QWORD PTR [rsi+0x30]
    2d2c:	mov    QWORD PTR [rsp+0x10],rcx
    2d31:	mov    rsi,rax
    2d34:	call   2d39 <botlish_fn_22+0xd1>
			2d35: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2d39:	test   rax,rax
    2d3c:	je     2f14 <botlish_fn_22+0x2ac>
    2d42:	mov    QWORD PTR [rsp],rax
    2d46:	mov    rsi,rax
    2d49:	mov    rdi,r13
    2d4c:	mov    r11,QWORD PTR [rdi+0x10]
    2d50:	mov    rdx,QWORD PTR [r11+0x18]
    2d54:	mov    QWORD PTR [rsp+0x8],rdx
    2d59:	mov    rax,QWORD PTR [rdi+0x10]
    2d5d:	mov    rcx,QWORD PTR [rax+0x38]
    2d61:	mov    QWORD PTR [rsp+0x10],rcx
    2d66:	call   2d6b <botlish_fn_22+0x103>
			2d67: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2d6b:	test   rax,rax
    2d6e:	je     2f14 <botlish_fn_22+0x2ac>
    2d74:	mov    QWORD PTR [rsp],rax
    2d78:	mov    rbx,rax
    2d7b:	mov    rdi,r13
    2d7e:	mov    rax,QWORD PTR [rdi+0x10]
    2d82:	mov    rdx,QWORD PTR [rax+0x28]
    2d86:	mov    rsi,rbx
    2d89:	call   2d8e <botlish_fn_22+0x126>
			2d8a: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2d8e:	test   rax,rax
    2d91:	je     2f14 <botlish_fn_22+0x2ac>
    2d97:	mov    QWORD PTR [rsp+0x8],rax
    2d9c:	mov    rdi,r13
    2d9f:	mov    r15,rax
    2da2:	mov    rax,QWORD PTR [rdi+0x10]
    2da6:	mov    rdx,QWORD PTR [rax+0x28]
    2daa:	mov    QWORD PTR [rsp+0x10],rdx
    2daf:	mov    rsi,rbx
    2db2:	call   2db7 <botlish_fn_22+0x14f>
			2db3: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2db7:	mov    rcx,rax
    2dba:	mov    r14,rax
    2dbd:	test   rax,rcx
    2dc0:	je     2f14 <botlish_fn_22+0x2ac>
    2dc6:	mov    rdi,r13
    2dc9:	mov    rax,QWORD PTR [rdi+0x10]
    2dcd:	mov    rdx,QWORD PTR [rax+0x18]
    2dd1:	mov    rsi,r14
    2dd4:	call   2dd9 <botlish_fn_22+0x171>
			2dd5: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    2dd9:	test   rax,rax
    2ddc:	je     2f14 <botlish_fn_22+0x2ac>
    2de2:	mov    rdi,r13
    2de5:	mov    rcx,QWORD PTR [rdi+0x10]
    2de9:	mov    rdx,QWORD PTR [rcx+0x38]
    2ded:	mov    rcx,rax
    2df0:	and    rcx,rdx
    2df3:	mov    rsi,rax
    2df6:	test   rcx,0x1
    2dfd:	jne    2e19 <botlish_fn_22+0x1b1>
    2e03:	mov    rdi,r13
    2e06:	call   2e0b <botlish_fn_22+0x1a3>
			2e07: R_X86_64_PLT32	rt_value_eq-0x4
    2e0b:	test   rax,rax
    2e0e:	je     2f14 <botlish_fn_22+0x2ac>
    2e14:	jmp    2e29 <botlish_fn_22+0x1c1>
    2e19:	mov    eax,0x2
    2e1e:	cmp    rsi,rdx
    2e21:	cmove  rax,QWORD PTR [rip+0x14f]        # 2f78 <botlish_fn_22+0x310>
    2e29:	mov    QWORD PTR [rsp],rax
    2e2d:	mov    rdi,r13
    2e30:	mov    QWORD PTR [rsp+0x60],rax
    2e35:	mov    rax,QWORD PTR [rdi+0x10]
    2e39:	mov    rdx,QWORD PTR [rax+0x28]
    2e3d:	mov    rsi,r14
    2e40:	call   2e45 <botlish_fn_22+0x1dd>
			2e41: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2e45:	mov    rbx,rax
    2e48:	test   rbx,rbx
    2e4b:	je     2f14 <botlish_fn_22+0x2ac>
    2e51:	mov    QWORD PTR [rsp+0x10],rbx
    2e56:	mov    rdi,r13
    2e59:	mov    rax,QWORD PTR [rdi+0x10]
    2e5d:	mov    rdx,QWORD PTR [rax+0x40]
    2e61:	mov    rsi,r14
    2e64:	call   2e69 <botlish_fn_22+0x201>
			2e65: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2e69:	mov    r12,rax
    2e6c:	test   r12,r12
    2e6f:	je     2f14 <botlish_fn_22+0x2ac>
    2e75:	mov    QWORD PTR [rsp+0x18],r12
    2e7a:	mov    rdi,r13
    2e7d:	mov    rax,QWORD PTR [rdi+0x10]
    2e81:	mov    rdx,QWORD PTR [rax+0x40]
    2e85:	mov    rsi,r14
    2e88:	call   2e8d <botlish_fn_22+0x225>
			2e89: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    2e8d:	test   rax,rax
    2e90:	mov    rsi,rax
    2e93:	je     2f14 <botlish_fn_22+0x2ac>
    2e99:	mov    edx,0xa
    2e9e:	mov    rdi,r13
    2ea1:	call   2ea6 <botlish_fn_22+0x23e>
			2ea2: R_X86_64_PLT32	rt_value_eq-0x4
    2ea6:	test   rax,rax
    2ea9:	je     2f14 <botlish_fn_22+0x2ac>
    2eaf:	mov    QWORD PTR [rsp+0x20],rax
    2eb4:	mov    rsi,r14
    2eb7:	mov    r14,rax
    2eba:	mov    rdi,r13
    2ebd:	call   2ec2 <botlish_fn_22+0x25a>
			2ebe: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2ec2:	test   rax,rax
    2ec5:	je     2f14 <botlish_fn_22+0x2ac>
    2ecb:	mov    QWORD PTR [rsp+0x28],rax
    2ed0:	lea    rdx,[rsp+0x30]
    2ed5:	mov    rcx,QWORD PTR [rsp+0x60]
    2eda:	mov    QWORD PTR [rsp+0x30],rcx
    2edf:	mov    rcx,r15
    2ee2:	mov    QWORD PTR [rsp+0x38],rcx
    2ee7:	mov    QWORD PTR [rsp+0x40],rbx
    2eec:	mov    QWORD PTR [rsp+0x48],r12
    2ef1:	mov    rcx,r14
    2ef4:	mov    QWORD PTR [rsp+0x50],rcx
    2ef9:	mov    QWORD PTR [rsp+0x58],rax
    2efe:	mov    esi,0x6
    2f03:	mov    rdi,r13
    2f06:	call   2f0b <botlish_fn_22+0x2a3>
			2f07: R_X86_64_PLT32	rt_list_new-0x4
    2f0b:	test   rax,rax
    2f0e:	jne    2f45 <botlish_fn_22+0x2dd>
    2f14:	xor    rax,rax
    2f17:	mov    rbx,QWORD PTR [rsp+0x70]
    2f1c:	mov    r12,QWORD PTR [rsp+0x78]
    2f21:	mov    r13,QWORD PTR [rsp+0x80]
    2f29:	mov    r14,QWORD PTR [rsp+0x88]
    2f31:	mov    r15,QWORD PTR [rsp+0x90]
    2f39:	add    rsp,0xa0
    2f40:	mov    rsp,rbp
    2f43:	pop    rbp
    2f44:	ret
    2f45:	mov    rbx,QWORD PTR [rsp+0x70]
    2f4a:	mov    r12,QWORD PTR [rsp+0x78]
    2f4f:	mov    r13,QWORD PTR [rsp+0x80]
    2f57:	mov    r14,QWORD PTR [rsp+0x88]
    2f5f:	mov    r15,QWORD PTR [rsp+0x90]
    2f67:	add    rsp,0xa0
    2f6e:	mov    rsp,rbp
    2f71:	pop    rbp
    2f72:	ret
    2f73:	add    BYTE PTR [rax],al
    2f75:	add    BYTE PTR [rax],al
    2f77:	add    BYTE PTR [rsi],al
    2f79:	add    BYTE PTR [rax],al
    2f7b:	add    BYTE PTR [rax],al
    2f7d:	add    BYTE PTR [rax],al
	...

0000000000002f80 <botlish_entry_22: sample_checks<generic>>:
    2f80:	push   rbp
    2f81:	mov    rbp,rsp
    2f84:	call   2f89 <botlish_entry_22+0x9>
			2f85: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    2f89:	mov    rsp,rbp
    2f8c:	pop    rbp
    2f8d:	ret

0000000000002f8e <botlish_fn_23: sample<generic>>:
    2f8e:	push   rbp
    2f8f:	mov    rbp,rsp
    2f92:	sub    rsp,0x10
    2f96:	mov    QWORD PTR [rsp],r12
    2f9a:	mov    r12,rdi
    2f9d:	mov    rdi,r12
    2fa0:	call   2fa5 <botlish_fn_23+0x17>
			2fa1: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    2fa5:	test   rax,rax
    2fa8:	jne    2ff1 <botlish_fn_23+0x63>
    2fae:	mov    rdi,r12
    2fb1:	call   2fb6 <botlish_fn_23+0x28>
			2fb2: R_X86_64_PLT32	rt_declared_error-0x4
    2fb6:	cmp    rax,0x40000001
    2fbc:	jne    2fe1 <botlish_fn_23+0x53>
    2fc2:	mov    rdi,r12
    2fc5:	call   2fca <botlish_fn_23+0x3c>
			2fc6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    2fca:	xor    rdx,rdx
    2fcd:	mov    rdi,r12
    2fd0:	mov    rsi,rdx
    2fd3:	call   2fd8 <botlish_fn_23+0x4a>
			2fd4: R_X86_64_PLT32	rt_list_new-0x4
    2fd8:	test   rax,rax
    2fdb:	jne    2ff1 <botlish_fn_23+0x63>
    2fe1:	xor    rax,rax
    2fe4:	mov    r12,QWORD PTR [rsp]
    2fe8:	add    rsp,0x10
    2fec:	mov    rsp,rbp
    2fef:	pop    rbp
    2ff0:	ret
    2ff1:	mov    r12,QWORD PTR [rsp]
    2ff5:	add    rsp,0x10
    2ff9:	mov    rsp,rbp
    2ffc:	pop    rbp
    2ffd:	ret

0000000000002ffe <botlish_entry_23: sample<generic>>:
    2ffe:	push   rbp
    2fff:	mov    rbp,rsp
    3002:	call   3007 <botlish_entry_23+0x9>
			3003: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    3007:	mov    rsp,rbp
    300a:	pop    rbp
    300b:	ret

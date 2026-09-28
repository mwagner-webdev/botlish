; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12732  (per function: 45 388 524 70 61 61 61 61 61 167 179 245 804 1248 429 253 380 439 977 766 817 665 1168 836 1189 838)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> ht_fill_empty<mutarray, int, int>
;   botlish_fn_2 / botlish_entry_2 -> ht_alloc<int>
;   botlish_fn_3 / botlish_entry_3 -> ht_new<generic>
;   botlish_fn_4 / botlish_entry_4 -> ht_controls<mutarray>
;   botlish_fn_5 / botlish_entry_5 -> ht_keys<mutarray>
;   botlish_fn_6 / botlish_entry_6 -> ht_values<mutarray>
;   botlish_fn_7 / botlish_entry_7 -> ht_size<mutarray>
;   botlish_fn_8 / botlish_entry_8 -> ht_tombstones<mutarray>
;   botlish_fn_9 / botlish_entry_9 -> ht_capacity<mutarray>
;   botlish_fn_10 / botlish_entry_10 -> ht_probe_start<mutarray, str>
;   botlish_fn_11 / botlish_entry_11 -> ht_probe_next<mutarray, int>
;   botlish_fn_12 / botlish_entry_12 -> ht_find_get<mutarray, str, int>
;   botlish_fn_13 / botlish_entry_13 -> ht_find_insert<mutarray, str, int, int>
;   botlish_fn_14 / botlish_entry_14 -> ht_get<mutarray, str>
;   botlish_fn_15 / botlish_entry_15 -> ht_contains<mutarray, str>
;   botlish_fn_16 / botlish_entry_16 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_17 / botlish_entry_17 -> ht_rehash_insert<List[mutarray], int, any, any>
;   botlish_fn_18 / botlish_entry_18 -> ht_rehash_scan<list, int, int, List[mutarray], int>
;   botlish_fn_19 / botlish_entry_19 -> ht_rehash<mutarray, int>
;   botlish_fn_20 / botlish_entry_20 -> ht_should_grow<mutarray>
;   botlish_fn_21 / botlish_entry_21 -> ht_grow_or_clean<mutarray>
;   botlish_fn_22 / botlish_entry_22 -> ht_place<mutarray, int, str, str>
;   botlish_fn_23 / botlish_entry_23 -> ht_set<mutarray, str, str>
;   botlish_fn_24 / botlish_entry_24 -> ht_delete<mutarray, str>
;   botlish_fn_25 / botlish_entry_25 -> sample<generic>


hashtable.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_25-0x4 ; sample<generic>
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
      2d:	add    BYTE PTR [rax],al
	...

0000000000000030 <botlish_fn_1: ht_fill_empty<mutarray, int, int>>:
      30:	push   rbp
      31:	mov    rbp,rsp
      34:	sub    rsp,0x40
      38:	mov    QWORD PTR [rsp+0x20],rbx
      3d:	mov    QWORD PTR [rsp+0x28],r12
      42:	mov    QWORD PTR [rsp+0x30],r13
      47:	mov    QWORD PTR [rsp+0x38],r14
      4c:	mov    r13,rdi
      4f:	mov    QWORD PTR [rsp],rsi
      53:	mov    rbx,rsi
      56:	mov    QWORD PTR [rsp+0x8],rdx
      5b:	mov    QWORD PTR [rsp+0x10],rcx
      60:	mov    r12,rcx
      63:	mov    rsi,rdx
      66:	mov    rax,rsi
      69:	and    rax,r12
      6c:	mov    r14,rsi
      6f:	test   rax,0x1
      75:	jne    9e <botlish_fn_1+0x6e>
      7b:	mov    rdx,r12
      7e:	mov    rsi,r14
      81:	mov    rdi,r13
      84:	call   89 <botlish_fn_1+0x59>
			85: R_X86_64_PLT32	rt_int_cmp-0x4
      89:	mov    ecx,0x2
      8e:	test   rax,rax
      91:	cmovge rcx,QWORD PTR [rip+0xdf]        # 178 <botlish_fn_1+0x148>
      99:	jmp    b1 <botlish_fn_1+0x81>
      9e:	mov    ecx,0x2
      a3:	mov    rsi,r14
      a6:	cmp    rsi,r12
      a9:	cmovge rcx,QWORD PTR [rip+0xc7]        # 178 <botlish_fn_1+0x148>
      b1:	cmp    rcx,0x6
      b5:	je     156 <botlish_fn_1+0x126>
      bb:	mov    ecx,0x1
      c0:	mov    rdx,r14
      c3:	mov    rsi,rbx
      c6:	mov    rdi,r13
      c9:	call   ce <botlish_fn_1+0x9e>
			ca: R_X86_64_PLT32	rt_mutarray_set-0x4
      ce:	test   rax,rax
      d1:	jne    f7 <botlish_fn_1+0xc7>
      d7:	xor    rax,rax
      da:	mov    rbx,QWORD PTR [rsp+0x20]
      df:	mov    r12,QWORD PTR [rsp+0x28]
      e4:	mov    r13,QWORD PTR [rsp+0x30]
      e9:	mov    r14,QWORD PTR [rsp+0x38]
      ee:	add    rsp,0x40
      f2:	mov    rsp,rbp
      f5:	pop    rbp
      f6:	ret
      f7:	mov    QWORD PTR [rsp+0x18],0x3
     100:	mov    rsi,r14
     103:	test   rsi,0x1
     10a:	je     12d <botlish_fn_1+0xfd>
     110:	mov    rsi,r14
     113:	mov    rcx,rsi
     116:	add    rcx,0x2
     11a:	seto   al
     11d:	test   al,al
     11f:	jne    12d <botlish_fn_1+0xfd>
     125:	mov    r14,rcx
     128:	jmp    140 <botlish_fn_1+0x110>
     12d:	mov    edx,0x3
     132:	mov    rsi,r14
     135:	mov    rdi,r13
     138:	call   13d <botlish_fn_1+0x10d>
			139: R_X86_64_PLT32	rt_int_add-0x4
     13d:	mov    r14,rax
     140:	mov    QWORD PTR [rsp],rbx
     144:	mov    rsi,r14
     147:	mov    QWORD PTR [rsp+0x8],rsi
     14c:	mov    QWORD PTR [rsp+0x10],r12
     151:	jmp    66 <botlish_fn_1+0x36>
     156:	mov    eax,0xa
     15b:	mov    rbx,QWORD PTR [rsp+0x20]
     160:	mov    r12,QWORD PTR [rsp+0x28]
     165:	mov    r13,QWORD PTR [rsp+0x30]
     16a:	mov    r14,QWORD PTR [rsp+0x38]
     16f:	add    rsp,0x40
     173:	mov    rsp,rbp
     176:	pop    rbp
     177:	ret
     178:	(bad)
     179:	add    BYTE PTR [rax],al
     17b:	add    BYTE PTR [rax],al
     17d:	add    BYTE PTR [rax],al
	...

0000000000000180 <botlish_entry_1: ht_fill_empty<mutarray, int, int>>:
     180:	push   rbp
     181:	mov    rbp,rsp
     184:	mov    rsi,QWORD PTR [rdx]
     187:	mov    r8,QWORD PTR [rdx+0x8]
     18b:	mov    rcx,QWORD PTR [rdx+0x10]
     18f:	mov    rdx,r8
     192:	call   197 <botlish_entry_1+0x17>
			193: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
     197:	mov    rsp,rbp
     19a:	pop    rbp
     19b:	ret

000000000000019c <botlish_fn_2: ht_alloc<int>>:
     19c:	push   rbp
     19d:	mov    rbp,rsp
     1a0:	sub    rsp,0x50
     1a4:	mov    QWORD PTR [rsp+0x20],rbx
     1a9:	mov    QWORD PTR [rsp+0x28],r12
     1ae:	mov    QWORD PTR [rsp+0x30],r13
     1b3:	mov    QWORD PTR [rsp+0x38],r14
     1b8:	mov    QWORD PTR [rsp+0x40],r15
     1bd:	mov    rbx,rdi
     1c0:	mov    QWORD PTR [rsp+0x8],0x0
     1c9:	mov    QWORD PTR [rsp+0x10],0x0
     1d2:	mov    QWORD PTR [rsp+0x18],0x0
     1db:	mov    QWORD PTR [rsp],rsi
     1df:	mov    r13,rsi
     1e2:	mov    rsi,r13
     1e5:	mov    rdi,rbx
     1e8:	call   1ed <botlish_fn_2+0x51>
			1e9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     1ed:	test   rax,rax
     1f0:	je     30c <botlish_fn_2+0x170>
     1f6:	mov    QWORD PTR [rsp+0x8],rax
     1fb:	mov    r12,rax
     1fe:	mov    edx,0x1
     203:	mov    QWORD PTR [rsp+0x10],0x1
     20c:	mov    rcx,r13
     20f:	mov    rsi,r12
     212:	mov    rdi,rbx
     215:	call   21a <botlish_fn_2+0x7e>
			216: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
     21a:	test   rax,rax
     21d:	je     30c <botlish_fn_2+0x170>
     223:	mov    rsi,r13
     226:	mov    rdi,rbx
     229:	call   22e <botlish_fn_2+0x92>
			22a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     22e:	test   rax,rax
     231:	je     30c <botlish_fn_2+0x170>
     237:	mov    QWORD PTR [rsp+0x10],rax
     23c:	mov    rsi,r13
     23f:	mov    r14,rax
     242:	mov    rdi,rbx
     245:	call   24a <botlish_fn_2+0xae>
			246: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     24a:	test   rax,rax
     24d:	je     30c <botlish_fn_2+0x170>
     253:	mov    QWORD PTR [rsp],rax
     257:	mov    r13,rax
     25a:	mov    esi,0xb
     25f:	mov    QWORD PTR [rsp+0x18],0xb
     268:	mov    rdi,rbx
     26b:	call   270 <botlish_fn_2+0xd4>
			26c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     270:	test   rax,rax
     273:	mov    r15,rax
     276:	je     30c <botlish_fn_2+0x170>
     27c:	mov    edx,0x1
     281:	mov    rcx,r12
     284:	mov    rsi,r15
     287:	mov    rdi,rbx
     28a:	call   28f <botlish_fn_2+0xf3>
			28b: R_X86_64_PLT32	rt_mutarray_set-0x4
     28f:	test   rax,rax
     292:	je     30c <botlish_fn_2+0x170>
     298:	mov    edx,0x3
     29d:	mov    rcx,r14
     2a0:	mov    rsi,r15
     2a3:	mov    rdi,rbx
     2a6:	call   2ab <botlish_fn_2+0x10f>
			2a7: R_X86_64_PLT32	rt_mutarray_set-0x4
     2ab:	test   rax,rax
     2ae:	je     30c <botlish_fn_2+0x170>
     2b4:	mov    edx,0x5
     2b9:	mov    rcx,r13
     2bc:	mov    rsi,r15
     2bf:	mov    rdi,rbx
     2c2:	call   2c7 <botlish_fn_2+0x12b>
			2c3: R_X86_64_PLT32	rt_mutarray_set-0x4
     2c7:	test   rax,rax
     2ca:	je     30c <botlish_fn_2+0x170>
     2d0:	mov    edx,0x7
     2d5:	mov    ecx,0x1
     2da:	mov    rsi,r15
     2dd:	mov    rdi,rbx
     2e0:	call   2e5 <botlish_fn_2+0x149>
			2e1: R_X86_64_PLT32	rt_mutarray_set-0x4
     2e5:	test   rax,rax
     2e8:	je     30c <botlish_fn_2+0x170>
     2ee:	mov    edx,0x9
     2f3:	mov    ecx,0x1
     2f8:	mov    rdi,rbx
     2fb:	mov    rsi,r15
     2fe:	call   303 <botlish_fn_2+0x167>
			2ff: R_X86_64_PLT32	rt_mutarray_set-0x4
     303:	test   rax,rax
     306:	jne    331 <botlish_fn_2+0x195>
     30c:	xor    rax,rax
     30f:	mov    rbx,QWORD PTR [rsp+0x20]
     314:	mov    r12,QWORD PTR [rsp+0x28]
     319:	mov    r13,QWORD PTR [rsp+0x30]
     31e:	mov    r14,QWORD PTR [rsp+0x38]
     323:	mov    r15,QWORD PTR [rsp+0x40]
     328:	add    rsp,0x50
     32c:	mov    rsp,rbp
     32f:	pop    rbp
     330:	ret
     331:	mov    rax,r15
     334:	mov    rbx,QWORD PTR [rsp+0x20]
     339:	mov    r12,QWORD PTR [rsp+0x28]
     33e:	mov    r13,QWORD PTR [rsp+0x30]
     343:	mov    r14,QWORD PTR [rsp+0x38]
     348:	mov    r15,QWORD PTR [rsp+0x40]
     34d:	add    rsp,0x50
     351:	mov    rsp,rbp
     354:	pop    rbp
     355:	ret

0000000000000356 <botlish_entry_2: ht_alloc<int>>:
     356:	push   rbp
     357:	mov    rbp,rsp
     35a:	mov    rsi,QWORD PTR [rdx]
     35d:	call   362 <botlish_entry_2+0xc>
			35e: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
     362:	mov    rsp,rbp
     365:	pop    rbp
     366:	ret

0000000000000367 <botlish_fn_3: ht_new<generic>>:
     367:	push   rbp
     368:	mov    rbp,rsp
     36b:	sub    rsp,0x10
     36f:	mov    esi,0x11
     374:	mov    QWORD PTR [rsp],0x11
     37c:	call   381 <botlish_fn_3+0x1a>
			37d: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
     381:	test   rax,rax
     384:	jne    396 <botlish_fn_3+0x2f>
     38a:	xor    rax,rax
     38d:	add    rsp,0x10
     391:	mov    rsp,rbp
     394:	pop    rbp
     395:	ret
     396:	add    rsp,0x10
     39a:	mov    rsp,rbp
     39d:	pop    rbp
     39e:	ret

000000000000039f <botlish_entry_3: ht_new<generic>>:
     39f:	push   rbp
     3a0:	mov    rbp,rsp
     3a3:	call   3a8 <botlish_entry_3+0x9>
			3a4: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
     3a8:	mov    rsp,rbp
     3ab:	pop    rbp
     3ac:	ret

00000000000003ad <botlish_fn_4: ht_controls<mutarray>>:
     3ad:	push   rbp
     3ae:	mov    rbp,rsp
     3b1:	mov    edx,0x1
     3b6:	call   3bb <botlish_fn_4+0xe>
			3b7: R_X86_64_PLT32	rt_mutarray_get-0x4
     3bb:	test   rax,rax
     3be:	jne    3cc <botlish_fn_4+0x1f>
     3c4:	xor    rax,rax
     3c7:	mov    rsp,rbp
     3ca:	pop    rbp
     3cb:	ret
     3cc:	mov    rsp,rbp
     3cf:	pop    rbp
     3d0:	ret

00000000000003d1 <botlish_entry_4: ht_controls<mutarray>>:
     3d1:	push   rbp
     3d2:	mov    rbp,rsp
     3d5:	mov    rsi,QWORD PTR [rdx]
     3d8:	call   3dd <botlish_entry_4+0xc>
			3d9: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     3dd:	mov    rsp,rbp
     3e0:	pop    rbp
     3e1:	ret

00000000000003e2 <botlish_fn_5: ht_keys<mutarray>>:
     3e2:	push   rbp
     3e3:	mov    rbp,rsp
     3e6:	mov    edx,0x3
     3eb:	call   3f0 <botlish_fn_5+0xe>
			3ec: R_X86_64_PLT32	rt_mutarray_get-0x4
     3f0:	test   rax,rax
     3f3:	jne    401 <botlish_fn_5+0x1f>
     3f9:	xor    rax,rax
     3fc:	mov    rsp,rbp
     3ff:	pop    rbp
     400:	ret
     401:	mov    rsp,rbp
     404:	pop    rbp
     405:	ret

0000000000000406 <botlish_entry_5: ht_keys<mutarray>>:
     406:	push   rbp
     407:	mov    rbp,rsp
     40a:	mov    rsi,QWORD PTR [rdx]
     40d:	call   412 <botlish_entry_5+0xc>
			40e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     412:	mov    rsp,rbp
     415:	pop    rbp
     416:	ret

0000000000000417 <botlish_fn_6: ht_values<mutarray>>:
     417:	push   rbp
     418:	mov    rbp,rsp
     41b:	mov    edx,0x5
     420:	call   425 <botlish_fn_6+0xe>
			421: R_X86_64_PLT32	rt_mutarray_get-0x4
     425:	test   rax,rax
     428:	jne    436 <botlish_fn_6+0x1f>
     42e:	xor    rax,rax
     431:	mov    rsp,rbp
     434:	pop    rbp
     435:	ret
     436:	mov    rsp,rbp
     439:	pop    rbp
     43a:	ret

000000000000043b <botlish_entry_6: ht_values<mutarray>>:
     43b:	push   rbp
     43c:	mov    rbp,rsp
     43f:	mov    rsi,QWORD PTR [rdx]
     442:	call   447 <botlish_entry_6+0xc>
			443: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
     447:	mov    rsp,rbp
     44a:	pop    rbp
     44b:	ret

000000000000044c <botlish_fn_7: ht_size<mutarray>>:
     44c:	push   rbp
     44d:	mov    rbp,rsp
     450:	mov    edx,0x7
     455:	call   45a <botlish_fn_7+0xe>
			456: R_X86_64_PLT32	rt_mutarray_get-0x4
     45a:	test   rax,rax
     45d:	jne    46b <botlish_fn_7+0x1f>
     463:	xor    rax,rax
     466:	mov    rsp,rbp
     469:	pop    rbp
     46a:	ret
     46b:	mov    rsp,rbp
     46e:	pop    rbp
     46f:	ret

0000000000000470 <botlish_entry_7: ht_size<mutarray>>:
     470:	push   rbp
     471:	mov    rbp,rsp
     474:	mov    rsi,QWORD PTR [rdx]
     477:	call   47c <botlish_entry_7+0xc>
			478: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
     47c:	mov    rsp,rbp
     47f:	pop    rbp
     480:	ret

0000000000000481 <botlish_fn_8: ht_tombstones<mutarray>>:
     481:	push   rbp
     482:	mov    rbp,rsp
     485:	mov    edx,0x9
     48a:	call   48f <botlish_fn_8+0xe>
			48b: R_X86_64_PLT32	rt_mutarray_get-0x4
     48f:	test   rax,rax
     492:	jne    4a0 <botlish_fn_8+0x1f>
     498:	xor    rax,rax
     49b:	mov    rsp,rbp
     49e:	pop    rbp
     49f:	ret
     4a0:	mov    rsp,rbp
     4a3:	pop    rbp
     4a4:	ret

00000000000004a5 <botlish_entry_8: ht_tombstones<mutarray>>:
     4a5:	push   rbp
     4a6:	mov    rbp,rsp
     4a9:	mov    rsi,QWORD PTR [rdx]
     4ac:	call   4b1 <botlish_entry_8+0xc>
			4ad: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
     4b1:	mov    rsp,rbp
     4b4:	pop    rbp
     4b5:	ret

00000000000004b6 <botlish_fn_9: ht_capacity<mutarray>>:
     4b6:	push   rbp
     4b7:	mov    rbp,rsp
     4ba:	sub    rsp,0x10
     4be:	mov    QWORD PTR [rsp],rbx
     4c2:	mov    rbx,rdi
     4c5:	mov    rdi,rbx
     4c8:	call   4cd <botlish_fn_9+0x17>
			4c9: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     4cd:	test   rax,rax
     4d0:	je     519 <botlish_fn_9+0x63>
     4d6:	xor    r8d,r8d
     4d9:	test   rax,0x7
     4df:	je     4ed <botlish_fn_9+0x37>
     4e5:	mov    rsi,rax
     4e8:	jmp    4fc <botlish_fn_9+0x46>
     4ed:	movzx  rcx,BYTE PTR [rax]
     4f1:	mov    rsi,rax
     4f4:	rex cmp cl,0x8
     4f8:	sete   r8b
     4fc:	test   r8b,r8b
     4ff:	jne    529 <botlish_fn_9+0x73>
     505:	mov    rdi,rbx
     508:	mov    rax,QWORD PTR [rdi+0x10]
     50c:	mov    rcx,QWORD PTR [rax]
     50f:	mov    edx,0x8
     514:	call   519 <botlish_fn_9+0x63>
			515: R_X86_64_PLT32	rt_type_error-0x4
     519:	xor    rax,rax
     51c:	mov    rbx,QWORD PTR [rsp]
     520:	add    rsp,0x10
     524:	mov    rsp,rbp
     527:	pop    rbp
     528:	ret
     529:	mov    rdi,rbx
     52c:	call   531 <botlish_fn_9+0x7b>
			52d: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     531:	mov    rbx,QWORD PTR [rsp]
     535:	add    rsp,0x10
     539:	mov    rsp,rbp
     53c:	pop    rbp
     53d:	ret

000000000000053e <botlish_entry_9: ht_capacity<mutarray>>:
     53e:	push   rbp
     53f:	mov    rbp,rsp
     542:	mov    rsi,QWORD PTR [rdx]
     545:	call   54a <botlish_entry_9+0xc>
			546: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     54a:	mov    rsp,rbp
     54d:	pop    rbp
     54e:	ret

000000000000054f <botlish_fn_10: ht_probe_start<mutarray, str>>:
     54f:	push   rbp
     550:	mov    rbp,rsp
     553:	sub    rsp,0x20
     557:	mov    QWORD PTR [rsp],r12
     55b:	mov    QWORD PTR [rsp+0x8],r13
     560:	mov    QWORD PTR [rsp+0x10],r14
     565:	mov    r12,rdi
     568:	mov    r14,rsi
     56b:	mov    rsi,rdx
     56e:	mov    rdi,r12
     571:	call   576 <botlish_fn_10+0x27>
			572: R_X86_64_PLT32	rt_hash-0x4
     576:	test   rax,rax
     579:	mov    r13,rax
     57c:	je     5ad <botlish_fn_10+0x5e>
     582:	mov    rsi,r14
     585:	mov    rdi,r12
     588:	call   58d <botlish_fn_10+0x3e>
			589: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     58d:	test   rax,rax
     590:	mov    rdx,rax
     593:	je     5ad <botlish_fn_10+0x5e>
     599:	mov    rsi,r13
     59c:	mov    rdi,r12
     59f:	call   5a4 <botlish_fn_10+0x55>
			5a0: R_X86_64_PLT32	rt_int_mod-0x4
     5a4:	test   rax,rax
     5a7:	jne    5c7 <botlish_fn_10+0x78>
     5ad:	xor    rax,rax
     5b0:	mov    r12,QWORD PTR [rsp]
     5b4:	mov    r13,QWORD PTR [rsp+0x8]
     5b9:	mov    r14,QWORD PTR [rsp+0x10]
     5be:	add    rsp,0x20
     5c2:	mov    rsp,rbp
     5c5:	pop    rbp
     5c6:	ret
     5c7:	mov    r12,QWORD PTR [rsp]
     5cb:	mov    r13,QWORD PTR [rsp+0x8]
     5d0:	mov    r14,QWORD PTR [rsp+0x10]
     5d5:	add    rsp,0x20
     5d9:	mov    rsp,rbp
     5dc:	pop    rbp
     5dd:	ret

00000000000005de <botlish_entry_10: ht_probe_start<mutarray, str>>:
     5de:	push   rbp
     5df:	mov    rbp,rsp
     5e2:	mov    rsi,QWORD PTR [rdx]
     5e5:	mov    rdx,QWORD PTR [rdx+0x8]
     5e9:	call   5ee <botlish_entry_10+0x10>
			5ea: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
     5ee:	mov    rsp,rbp
     5f1:	pop    rbp
     5f2:	ret

00000000000005f3 <botlish_fn_11: ht_probe_next<mutarray, int>>:
     5f3:	push   rbp
     5f4:	mov    rbp,rsp
     5f7:	sub    rsp,0x40
     5fb:	mov    QWORD PTR [rsp+0x20],rbx
     600:	mov    QWORD PTR [rsp+0x28],r12
     605:	mov    QWORD PTR [rsp+0x30],r13
     60a:	mov    r13,rdi
     60d:	mov    QWORD PTR [rsp],rsi
     611:	mov    rbx,rsi
     614:	mov    QWORD PTR [rsp+0x8],rdx
     619:	mov    QWORD PTR [rsp+0x10],0x3
     622:	test   rdx,0x1
     629:	jne    637 <botlish_fn_11+0x44>
     62f:	mov    rsi,rdx
     632:	jmp    657 <botlish_fn_11+0x64>
     637:	mov    rsi,rdx
     63a:	add    rsi,0x2
     63e:	mov    r12,rsi
     641:	mov    rsi,rdx
     644:	seto   al
     647:	test   al,al
     649:	jne    657 <botlish_fn_11+0x64>
     64f:	mov    rsi,rbx
     652:	jmp    66a <botlish_fn_11+0x77>
     657:	mov    edx,0x3
     65c:	mov    rdi,r13
     65f:	call   664 <botlish_fn_11+0x71>
			660: R_X86_64_PLT32	rt_int_add-0x4
     664:	mov    rsi,rbx
     667:	mov    r12,rax
     66a:	mov    rdi,r13
     66d:	call   672 <botlish_fn_11+0x7f>
			66e: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     672:	test   rax,rax
     675:	mov    rdx,rax
     678:	je     692 <botlish_fn_11+0x9f>
     67e:	mov    rsi,r12
     681:	mov    rdi,r13
     684:	call   689 <botlish_fn_11+0x96>
			685: R_X86_64_PLT32	rt_int_mod-0x4
     689:	test   rax,rax
     68c:	jne    6ad <botlish_fn_11+0xba>
     692:	xor    rax,rax
     695:	mov    rbx,QWORD PTR [rsp+0x20]
     69a:	mov    r12,QWORD PTR [rsp+0x28]
     69f:	mov    r13,QWORD PTR [rsp+0x30]
     6a4:	add    rsp,0x40
     6a8:	mov    rsp,rbp
     6ab:	pop    rbp
     6ac:	ret
     6ad:	mov    rbx,QWORD PTR [rsp+0x20]
     6b2:	mov    r12,QWORD PTR [rsp+0x28]
     6b7:	mov    r13,QWORD PTR [rsp+0x30]
     6bc:	add    rsp,0x40
     6c0:	mov    rsp,rbp
     6c3:	pop    rbp
     6c4:	ret

00000000000006c5 <botlish_entry_11: ht_probe_next<mutarray, int>>:
     6c5:	push   rbp
     6c6:	mov    rbp,rsp
     6c9:	mov    rsi,QWORD PTR [rdx]
     6cc:	mov    rdx,QWORD PTR [rdx+0x8]
     6d0:	call   6d5 <botlish_entry_11+0x10>
			6d1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     6d5:	mov    rsp,rbp
     6d8:	pop    rbp
     6d9:	ret
     6da:	add    BYTE PTR [rax],al
     6dc:	add    BYTE PTR [rax],al
	...

00000000000006e0 <botlish_fn_12: ht_find_get<mutarray, str, int>>:
     6e0:	push   rbp
     6e1:	mov    rbp,rsp
     6e4:	sub    rsp,0x50
     6e8:	mov    QWORD PTR [rsp+0x20],rbx
     6ed:	mov    QWORD PTR [rsp+0x28],r12
     6f2:	mov    QWORD PTR [rsp+0x30],r13
     6f7:	mov    QWORD PTR [rsp+0x38],r14
     6fc:	mov    QWORD PTR [rsp+0x40],r15
     701:	mov    r14,rdi
     704:	mov    QWORD PTR [rsp],rsi
     708:	mov    QWORD PTR [rsp+0x8],rdx
     70d:	mov    r13,rdx
     710:	mov    QWORD PTR [rsp+0x10],rcx
     715:	mov    r12,rsi
     718:	mov    r15,rcx
     71b:	mov    rsi,r12
     71e:	mov    rdi,r14
     721:	call   726 <botlish_fn_12+0x46>
			722: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     726:	test   rax,rax
     729:	je     928 <botlish_fn_12+0x248>
     72f:	xor    ecx,ecx
     731:	test   rax,0x7
     737:	je     745 <botlish_fn_12+0x65>
     73d:	mov    rsi,rax
     740:	jmp    753 <botlish_fn_12+0x73>
     745:	movzx  rcx,BYTE PTR [rax]
     749:	mov    rsi,rax
     74c:	rex cmp cl,0x8
     750:	sete   cl
     753:	test   cl,cl
     755:	jne    775 <botlish_fn_12+0x95>
     75b:	mov    rdi,r14
     75e:	mov    rdx,QWORD PTR [rdi+0x10]
     762:	mov    rcx,QWORD PTR [rdx+0x8]
     766:	mov    edx,0x8
     76b:	call   770 <botlish_fn_12+0x90>
			76c: R_X86_64_PLT32	rt_type_error-0x4
     770:	jmp    928 <botlish_fn_12+0x248>
     775:	mov    rdx,r15
     778:	mov    rdi,r14
     77b:	call   780 <botlish_fn_12+0xa0>
			77c: R_X86_64_PLT32	rt_mutarray_get-0x4
     780:	mov    rcx,rax
     783:	mov    QWORD PTR [rsp+0x18],rax
     788:	test   rax,rcx
     78b:	je     928 <botlish_fn_12+0x248>
     791:	mov    rax,QWORD PTR [rsp+0x18]
     796:	test   rax,0x1
     79c:	jne    7c7 <botlish_fn_12+0xe7>
     7a2:	mov    edx,0x1
     7a7:	mov    rsi,QWORD PTR [rsp+0x18]
     7ac:	mov    rdi,r14
     7af:	call   7b4 <botlish_fn_12+0xd4>
			7b0: R_X86_64_PLT32	rt_value_eq-0x4
     7b4:	test   rax,rax
     7b7:	je     928 <botlish_fn_12+0x248>
     7bd:	mov    rcx,QWORD PTR [rsp+0x18]
     7c2:	jmp    7dd <botlish_fn_12+0xfd>
     7c7:	mov    eax,0x2
     7cc:	mov    rcx,QWORD PTR [rsp+0x18]
     7d1:	cmp    rcx,0x1
     7d5:	cmove  rax,QWORD PTR [rip+0x1db]        # 9b8 <botlish_fn_12+0x2d8>
     7dd:	mov    ebx,0x6
     7e2:	cmp    rax,0x6
     7e6:	je     988 <botlish_fn_12+0x2a8>
     7ec:	test   rcx,0x1
     7f3:	mov    QWORD PTR [rsp+0x18],rcx
     7f8:	jne    81e <botlish_fn_12+0x13e>
     7fe:	mov    edx,0x3
     803:	mov    rsi,QWORD PTR [rsp+0x18]
     808:	mov    rdi,r14
     80b:	call   810 <botlish_fn_12+0x130>
			80c: R_X86_64_PLT32	rt_value_eq-0x4
     810:	test   rax,rax
     813:	je     928 <botlish_fn_12+0x248>
     819:	jmp    834 <botlish_fn_12+0x154>
     81e:	mov    rsi,QWORD PTR [rsp+0x18]
     823:	mov    eax,0x2
     828:	cmp    rsi,0x3
     82c:	cmove  rax,QWORD PTR [rip+0x184]        # 9b8 <botlish_fn_12+0x2d8>
     834:	cmp    rax,0x6
     838:	je     848 <botlish_fn_12+0x168>
     83e:	mov    ebx,0x2
     843:	jmp    907 <botlish_fn_12+0x227>
     848:	mov    rsi,r12
     84b:	mov    rdi,r14
     84e:	call   853 <botlish_fn_12+0x173>
			84f: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     853:	test   rax,rax
     856:	je     928 <botlish_fn_12+0x248>
     85c:	xor    r10d,r10d
     85f:	test   rax,0x7
     865:	je     873 <botlish_fn_12+0x193>
     86b:	mov    rsi,rax
     86e:	jmp    882 <botlish_fn_12+0x1a2>
     873:	movzx  rcx,BYTE PTR [rax]
     877:	mov    rsi,rax
     87a:	rex cmp cl,0x8
     87e:	sete   r10b
     882:	test   r10b,r10b
     885:	jne    8a5 <botlish_fn_12+0x1c5>
     88b:	mov    rdi,r14
     88e:	mov    rax,QWORD PTR [rdi+0x10]
     892:	mov    rcx,QWORD PTR [rax+0x8]
     896:	mov    edx,0x8
     89b:	call   8a0 <botlish_fn_12+0x1c0>
			89c: R_X86_64_PLT32	rt_type_error-0x4
     8a0:	jmp    928 <botlish_fn_12+0x248>
     8a5:	mov    rdx,r15
     8a8:	mov    rdi,r14
     8ab:	call   8b0 <botlish_fn_12+0x1d0>
			8ac: R_X86_64_PLT32	rt_mutarray_get-0x4
     8b0:	test   rax,rax
     8b3:	je     928 <botlish_fn_12+0x248>
     8b9:	mov    rcx,rax
     8bc:	and    rcx,r13
     8bf:	mov    rsi,rax
     8c2:	test   rcx,0x1
     8c9:	jne    8e8 <botlish_fn_12+0x208>
     8cf:	mov    rdx,r13
     8d2:	mov    rdi,r14
     8d5:	call   8da <botlish_fn_12+0x1fa>
			8d6: R_X86_64_PLT32	rt_value_eq-0x4
     8da:	test   rax,rax
     8dd:	je     928 <botlish_fn_12+0x248>
     8e3:	jmp    8f8 <botlish_fn_12+0x218>
     8e8:	mov    eax,0x2
     8ed:	cmp    rsi,r13
     8f0:	cmove  rax,QWORD PTR [rip+0xc0]        # 9b8 <botlish_fn_12+0x2d8>
     8f8:	cmp    rax,0x6
     8fc:	je     907 <botlish_fn_12+0x227>
     902:	mov    ebx,0x2
     907:	cmp    rbx,0x6
     90b:	je     963 <botlish_fn_12+0x283>
     911:	mov    rdx,r15
     914:	mov    rsi,r12
     917:	mov    rdi,r14
     91a:	call   91f <botlish_fn_12+0x23f>
			91b: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     91f:	test   rax,rax
     922:	jne    94d <botlish_fn_12+0x26d>
     928:	xor    rax,rax
     92b:	mov    rbx,QWORD PTR [rsp+0x20]
     930:	mov    r12,QWORD PTR [rsp+0x28]
     935:	mov    r13,QWORD PTR [rsp+0x30]
     93a:	mov    r14,QWORD PTR [rsp+0x38]
     93f:	mov    r15,QWORD PTR [rsp+0x40]
     944:	add    rsp,0x50
     948:	mov    rsp,rbp
     94b:	pop    rbp
     94c:	ret
     94d:	mov    QWORD PTR [rsp],r12
     951:	mov    QWORD PTR [rsp+0x8],r13
     956:	mov    QWORD PTR [rsp+0x10],rax
     95b:	mov    r15,rax
     95e:	jmp    71b <botlish_fn_12+0x3b>
     963:	mov    rax,r15
     966:	mov    rbx,QWORD PTR [rsp+0x20]
     96b:	mov    r12,QWORD PTR [rsp+0x28]
     970:	mov    r13,QWORD PTR [rsp+0x30]
     975:	mov    r14,QWORD PTR [rsp+0x38]
     97a:	mov    r15,QWORD PTR [rsp+0x40]
     97f:	add    rsp,0x50
     983:	mov    rsp,rbp
     986:	pop    rbp
     987:	ret
     988:	mov    rax,0xffffffffffffffff
     98f:	mov    rbx,QWORD PTR [rsp+0x20]
     994:	mov    r12,QWORD PTR [rsp+0x28]
     999:	mov    r13,QWORD PTR [rsp+0x30]
     99e:	mov    r14,QWORD PTR [rsp+0x38]
     9a3:	mov    r15,QWORD PTR [rsp+0x40]
     9a8:	add    rsp,0x50
     9ac:	mov    rsp,rbp
     9af:	pop    rbp
     9b0:	ret
     9b1:	add    BYTE PTR [rax],al
     9b3:	add    BYTE PTR [rax],al
     9b5:	add    BYTE PTR [rax],al
     9b7:	add    BYTE PTR [rsi],al
     9b9:	add    BYTE PTR [rax],al
     9bb:	add    BYTE PTR [rax],al
     9bd:	add    BYTE PTR [rax],al
	...

00000000000009c0 <botlish_entry_12: ht_find_get<mutarray, str, int>>:
     9c0:	push   rbp
     9c1:	mov    rbp,rsp
     9c4:	mov    rsi,QWORD PTR [rdx]
     9c7:	mov    r8,QWORD PTR [rdx+0x8]
     9cb:	mov    rcx,QWORD PTR [rdx+0x10]
     9cf:	mov    rdx,r8
     9d2:	call   9d7 <botlish_entry_12+0x17>
			9d3: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
     9d7:	mov    rsp,rbp
     9da:	pop    rbp
     9db:	ret
     9dc:	add    BYTE PTR [rax],al
	...

00000000000009e0 <botlish_fn_13: ht_find_insert<mutarray, str, int, int>>:
     9e0:	push   rbp
     9e1:	mov    rbp,rsp
     9e4:	sub    rsp,0x60
     9e8:	mov    QWORD PTR [rsp+0x30],rbx
     9ed:	mov    QWORD PTR [rsp+0x38],r12
     9f2:	mov    QWORD PTR [rsp+0x40],r13
     9f7:	mov    QWORD PTR [rsp+0x48],r14
     9fc:	mov    QWORD PTR [rsp+0x50],r15
     a01:	mov    r15,rdi
     a04:	mov    QWORD PTR [rsp],rsi
     a08:	mov    QWORD PTR [rsp+0x8],rdx
     a0d:	mov    r13,rdx
     a10:	mov    QWORD PTR [rsp+0x10],rcx
     a15:	mov    QWORD PTR [rsp+0x18],r8
     a1a:	mov    rbx,rsi
     a1d:	mov    QWORD PTR [rsp+0x20],rcx
     a22:	mov    QWORD PTR [rsp+0x28],r8
     a27:	mov    rsi,rbx
     a2a:	mov    rdi,r15
     a2d:	call   a32 <botlish_fn_13+0x52>
			a2e: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     a32:	test   rax,rax
     a35:	je     d2d <botlish_fn_13+0x34d>
     a3b:	xor    ecx,ecx
     a3d:	test   rax,0x7
     a43:	je     a51 <botlish_fn_13+0x71>
     a49:	mov    rsi,rax
     a4c:	jmp    a5f <botlish_fn_13+0x7f>
     a51:	movzx  rcx,BYTE PTR [rax]
     a55:	mov    rsi,rax
     a58:	rex cmp cl,0x8
     a5c:	sete   cl
     a5f:	test   cl,cl
     a61:	jne    a81 <botlish_fn_13+0xa1>
     a67:	mov    rdi,r15
     a6a:	mov    rax,QWORD PTR [rdi+0x10]
     a6e:	mov    rcx,QWORD PTR [rax+0x8]
     a72:	mov    edx,0x8
     a77:	call   a7c <botlish_fn_13+0x9c>
			a78: R_X86_64_PLT32	rt_type_error-0x4
     a7c:	jmp    d2d <botlish_fn_13+0x34d>
     a81:	mov    rdx,QWORD PTR [rsp+0x20]
     a86:	mov    rdi,r15
     a89:	call   a8e <botlish_fn_13+0xae>
			a8a: R_X86_64_PLT32	rt_mutarray_get-0x4
     a8e:	mov    rsi,rax
     a91:	mov    r14,rax
     a94:	test   rax,rsi
     a97:	je     d2d <botlish_fn_13+0x34d>
     a9d:	mov    rax,r14
     aa0:	test   rax,0x1
     aa6:	jne    aca <botlish_fn_13+0xea>
     aac:	mov    edx,0x1
     ab1:	mov    rsi,r14
     ab4:	mov    rdi,r15
     ab7:	call   abc <botlish_fn_13+0xdc>
			ab8: R_X86_64_PLT32	rt_value_eq-0x4
     abc:	test   rax,rax
     abf:	je     d2d <botlish_fn_13+0x34d>
     ac5:	jmp    ade <botlish_fn_13+0xfe>
     aca:	mov    eax,0x2
     acf:	mov    rcx,r14
     ad2:	cmp    rcx,0x1
     ad6:	cmove  rax,QWORD PTR [rip+0x372]        # e50 <botlish_fn_13+0x470>
     ade:	mov    r12d,0x6
     ae4:	cmp    rax,0x6
     ae8:	je     da5 <botlish_fn_13+0x3c5>
     aee:	mov    rax,r14
     af1:	test   rax,0x1
     af7:	jne    b1b <botlish_fn_13+0x13b>
     afd:	mov    edx,0x3
     b02:	mov    rsi,r14
     b05:	mov    rdi,r15
     b08:	call   b0d <botlish_fn_13+0x12d>
			b09: R_X86_64_PLT32	rt_value_eq-0x4
     b0d:	test   rax,rax
     b10:	je     d2d <botlish_fn_13+0x34d>
     b16:	jmp    b2f <botlish_fn_13+0x14f>
     b1b:	mov    eax,0x2
     b20:	mov    rcx,r14
     b23:	cmp    rcx,0x3
     b27:	cmove  rax,QWORD PTR [rip+0x321]        # e50 <botlish_fn_13+0x470>
     b2f:	cmp    rax,0x6
     b33:	je     b44 <botlish_fn_13+0x164>
     b39:	mov    r11d,0x2
     b3f:	jmp    c0e <botlish_fn_13+0x22e>
     b44:	mov    rsi,rbx
     b47:	mov    rdi,r15
     b4a:	call   b4f <botlish_fn_13+0x16f>
			b4b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     b4f:	test   rax,rax
     b52:	je     d2d <botlish_fn_13+0x34d>
     b58:	xor    ecx,ecx
     b5a:	test   rax,0x7
     b60:	je     b6e <botlish_fn_13+0x18e>
     b66:	mov    rsi,rax
     b69:	jmp    b7c <botlish_fn_13+0x19c>
     b6e:	movzx  rcx,BYTE PTR [rax]
     b72:	mov    rsi,rax
     b75:	rex cmp cl,0x8
     b79:	sete   cl
     b7c:	test   cl,cl
     b7e:	jne    b9e <botlish_fn_13+0x1be>
     b84:	mov    rdi,r15
     b87:	mov    rcx,QWORD PTR [rdi+0x10]
     b8b:	mov    rcx,QWORD PTR [rcx+0x8]
     b8f:	mov    edx,0x8
     b94:	call   b99 <botlish_fn_13+0x1b9>
			b95: R_X86_64_PLT32	rt_type_error-0x4
     b99:	jmp    d2d <botlish_fn_13+0x34d>
     b9e:	mov    rdx,QWORD PTR [rsp+0x20]
     ba3:	mov    rdi,r15
     ba6:	call   bab <botlish_fn_13+0x1cb>
			ba7: R_X86_64_PLT32	rt_mutarray_get-0x4
     bab:	test   rax,rax
     bae:	je     d2d <botlish_fn_13+0x34d>
     bb4:	mov    rsi,rax
     bb7:	and    rsi,r13
     bba:	test   rsi,0x1
     bc1:	jne    be3 <botlish_fn_13+0x203>
     bc7:	mov    rsi,rax
     bca:	mov    rdx,r13
     bcd:	mov    rdi,r15
     bd0:	call   bd5 <botlish_fn_13+0x1f5>
			bd1: R_X86_64_PLT32	rt_value_eq-0x4
     bd5:	test   rax,rax
     bd8:	je     d2d <botlish_fn_13+0x34d>
     bde:	jmp    bf6 <botlish_fn_13+0x216>
     be3:	mov    rsi,rax
     be6:	mov    eax,0x2
     beb:	cmp    rsi,r13
     bee:	cmove  rax,QWORD PTR [rip+0x25a]        # e50 <botlish_fn_13+0x470>
     bf6:	cmp    rax,0x6
     bfa:	je     c0b <botlish_fn_13+0x22b>
     c00:	mov    r11d,0x2
     c06:	jmp    c0e <botlish_fn_13+0x22e>
     c0b:	mov    r11,r12
     c0e:	cmp    r11,0x6
     c12:	je     d7e <botlish_fn_13+0x39e>
     c18:	mov    rax,r14
     c1b:	test   rax,0x1
     c21:	jne    c45 <botlish_fn_13+0x265>
     c27:	mov    edx,0x5
     c2c:	mov    rsi,r14
     c2f:	mov    rdi,r15
     c32:	call   c37 <botlish_fn_13+0x257>
			c33: R_X86_64_PLT32	rt_value_eq-0x4
     c37:	test   rax,rax
     c3a:	je     d2d <botlish_fn_13+0x34d>
     c40:	jmp    c59 <botlish_fn_13+0x279>
     c45:	mov    rsi,r14
     c48:	mov    eax,0x2
     c4d:	cmp    rsi,0x5
     c51:	cmove  rax,QWORD PTR [rip+0x1f7]        # e50 <botlish_fn_13+0x470>
     c59:	cmp    rax,0x6
     c5d:	je     c6e <botlish_fn_13+0x28e>
     c63:	mov    r12d,0x2
     c69:	jmp    ccf <botlish_fn_13+0x2ef>
     c6e:	mov    r14,QWORD PTR [rsp+0x28]
     c73:	test   r14,0x1
     c7a:	jne    caa <botlish_fn_13+0x2ca>
     c80:	mov    edx,0x1
     c85:	mov    rsi,r14
     c88:	mov    rdi,r15
     c8b:	call   c90 <botlish_fn_13+0x2b0>
			c8c: R_X86_64_PLT32	rt_int_cmp-0x4
     c90:	mov    ecx,0x2
     c95:	test   rax,rax
     c98:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # e50 <botlish_fn_13+0x470>
     ca0:	mov    QWORD PTR [rsp+0x28],r14
     ca5:	jmp    cbf <botlish_fn_13+0x2df>
     caa:	mov    ecx,0x2
     caf:	test   r14,r14
     cb2:	mov    QWORD PTR [rsp+0x28],r14
     cb7:	cmovle rcx,QWORD PTR [rip+0x191]        # e50 <botlish_fn_13+0x470>
     cbf:	cmp    rcx,0x6
     cc3:	je     ccf <botlish_fn_13+0x2ef>
     cc9:	mov    r12d,0x2
     ccf:	cmp    r12,0x6
     cd3:	je     d14 <botlish_fn_13+0x334>
     cd9:	mov    rdx,QWORD PTR [rsp+0x20]
     cde:	mov    rsi,rbx
     ce1:	mov    rdi,r15
     ce4:	call   ce9 <botlish_fn_13+0x309>
			ce5: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     ce9:	test   rax,rax
     cec:	je     d2d <botlish_fn_13+0x34d>
     cf2:	mov    QWORD PTR [rsp],rbx
     cf6:	mov    QWORD PTR [rsp+0x8],r13
     cfb:	mov    QWORD PTR [rsp+0x10],rax
     d00:	mov    r11,QWORD PTR [rsp+0x28]
     d05:	mov    QWORD PTR [rsp+0x18],r11
     d0a:	mov    QWORD PTR [rsp+0x20],rax
     d0f:	jmp    a27 <botlish_fn_13+0x47>
     d14:	mov    rdx,QWORD PTR [rsp+0x20]
     d19:	mov    rsi,rbx
     d1c:	mov    rdi,r15
     d1f:	call   d24 <botlish_fn_13+0x344>
			d20: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     d24:	test   rax,rax
     d27:	jne    d52 <botlish_fn_13+0x372>
     d2d:	xor    rax,rax
     d30:	mov    rbx,QWORD PTR [rsp+0x30]
     d35:	mov    r12,QWORD PTR [rsp+0x38]
     d3a:	mov    r13,QWORD PTR [rsp+0x40]
     d3f:	mov    r14,QWORD PTR [rsp+0x48]
     d44:	mov    r15,QWORD PTR [rsp+0x50]
     d49:	add    rsp,0x60
     d4d:	mov    rsp,rbp
     d50:	pop    rbp
     d51:	ret
     d52:	mov    QWORD PTR [rsp],rbx
     d56:	mov    QWORD PTR [rsp+0x8],r13
     d5b:	mov    QWORD PTR [rsp+0x10],rax
     d60:	mov    rdx,QWORD PTR [rsp+0x20]
     d65:	mov    QWORD PTR [rsp+0x18],rdx
     d6a:	mov    rcx,QWORD PTR [rsp+0x20]
     d6f:	mov    QWORD PTR [rsp+0x28],rcx
     d74:	mov    QWORD PTR [rsp+0x20],rax
     d79:	jmp    a27 <botlish_fn_13+0x47>
     d7e:	mov    rax,QWORD PTR [rsp+0x20]
     d83:	mov    rbx,QWORD PTR [rsp+0x30]
     d88:	mov    r12,QWORD PTR [rsp+0x38]
     d8d:	mov    r13,QWORD PTR [rsp+0x40]
     d92:	mov    r14,QWORD PTR [rsp+0x48]
     d97:	mov    r15,QWORD PTR [rsp+0x50]
     d9c:	add    rsp,0x60
     da0:	mov    rsp,rbp
     da3:	pop    rbp
     da4:	ret
     da5:	mov    rax,QWORD PTR [rsp+0x28]
     daa:	test   rax,0x1
     db0:	jne    ddd <botlish_fn_13+0x3fd>
     db6:	mov    edx,0x1
     dbb:	mov    rdi,r15
     dbe:	mov    rsi,QWORD PTR [rsp+0x28]
     dc3:	call   dc8 <botlish_fn_13+0x3e8>
			dc4: R_X86_64_PLT32	rt_int_cmp-0x4
     dc8:	mov    ecx,0x2
     dcd:	test   rax,rax
     dd0:	cmovge rcx,QWORD PTR [rip+0x78]        # e50 <botlish_fn_13+0x470>
     dd8:	jmp    df7 <botlish_fn_13+0x417>
     ddd:	mov    ecx,0x2
     de2:	mov    rax,QWORD PTR [rsp+0x28]
     de7:	mov    rdx,QWORD PTR [rsp+0x28]
     dec:	test   rax,rdx
     def:	cmovg  rcx,QWORD PTR [rip+0x59]        # e50 <botlish_fn_13+0x470>
     df7:	cmp    rcx,0x6
     dfb:	je     e28 <botlish_fn_13+0x448>
     e01:	mov    rax,QWORD PTR [rsp+0x20]
     e06:	mov    rbx,QWORD PTR [rsp+0x30]
     e0b:	mov    r12,QWORD PTR [rsp+0x38]
     e10:	mov    r13,QWORD PTR [rsp+0x40]
     e15:	mov    r14,QWORD PTR [rsp+0x48]
     e1a:	mov    r15,QWORD PTR [rsp+0x50]
     e1f:	add    rsp,0x60
     e23:	mov    rsp,rbp
     e26:	pop    rbp
     e27:	ret
     e28:	mov    rax,QWORD PTR [rsp+0x28]
     e2d:	mov    rbx,QWORD PTR [rsp+0x30]
     e32:	mov    r12,QWORD PTR [rsp+0x38]
     e37:	mov    r13,QWORD PTR [rsp+0x40]
     e3c:	mov    r14,QWORD PTR [rsp+0x48]
     e41:	mov    r15,QWORD PTR [rsp+0x50]
     e46:	add    rsp,0x60
     e4a:	mov    rsp,rbp
     e4d:	pop    rbp
     e4e:	ret
     e4f:	add    BYTE PTR [rsi],al
     e51:	add    BYTE PTR [rax],al
     e53:	add    BYTE PTR [rax],al
     e55:	add    BYTE PTR [rax],al
	...

0000000000000e58 <botlish_entry_13: ht_find_insert<mutarray, str, int, int>>:
     e58:	push   rbp
     e59:	mov    rbp,rsp
     e5c:	mov    rsi,QWORD PTR [rdx]
     e5f:	mov    r9,QWORD PTR [rdx+0x8]
     e63:	mov    rcx,QWORD PTR [rdx+0x10]
     e67:	mov    r8,QWORD PTR [rdx+0x18]
     e6b:	mov    rdx,r9
     e6e:	call   e73 <botlish_entry_13+0x1b>
			e6f: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
     e73:	mov    rsp,rbp
     e76:	pop    rbp
     e77:	ret

0000000000000e78 <botlish_fn_14: ht_get<mutarray, str>>:
     e78:	push   rbp
     e79:	mov    rbp,rsp
     e7c:	sub    rsp,0x40
     e80:	mov    QWORD PTR [rsp+0x20],rbx
     e85:	mov    QWORD PTR [rsp+0x28],r12
     e8a:	mov    QWORD PTR [rsp+0x30],r13
     e8f:	mov    rbx,rdi
     e92:	mov    QWORD PTR [rsp],rsi
     e96:	mov    r13,rsi
     e99:	mov    QWORD PTR [rsp+0x8],rdx
     e9e:	mov    r12,rdx
     ea1:	mov    rdx,r12
     ea4:	mov    rsi,r13
     ea7:	mov    rdi,rbx
     eaa:	call   eaf <botlish_fn_14+0x37>
			eab: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
     eaf:	test   rax,rax
     eb2:	je     f9c <botlish_fn_14+0x124>
     eb8:	mov    QWORD PTR [rsp+0x10],rax
     ebd:	mov    rcx,rax
     ec0:	mov    rdx,r12
     ec3:	mov    rsi,r13
     ec6:	mov    rdi,rbx
     ec9:	call   ece <botlish_fn_14+0x56>
			eca: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
     ece:	mov    rcx,rax
     ed1:	mov    r12,rax
     ed4:	test   rax,rcx
     ed7:	je     f9c <botlish_fn_14+0x124>
     edd:	mov    rax,r12
     ee0:	test   rax,0x1
     ee6:	jne    f11 <botlish_fn_14+0x99>
     eec:	mov    edx,0x1
     ef1:	mov    rsi,r12
     ef4:	mov    rdi,rbx
     ef7:	call   efc <botlish_fn_14+0x84>
			ef8: R_X86_64_PLT32	rt_int_cmp-0x4
     efc:	mov    ecx,0x2
     f01:	test   rax,rax
     f04:	cmovl  rcx,QWORD PTR [rip+0xe4]        # ff0 <botlish_fn_14+0x178>
     f0c:	jmp    f24 <botlish_fn_14+0xac>
     f11:	mov    ecx,0x2
     f16:	mov    rax,r12
     f19:	test   rax,rax
     f1c:	cmovle rcx,QWORD PTR [rip+0xcc]        # ff0 <botlish_fn_14+0x178>
     f24:	cmp    rcx,0x6
     f28:	je     fcf <botlish_fn_14+0x157>
     f2e:	mov    rsi,r13
     f31:	mov    rdi,rbx
     f34:	call   f39 <botlish_fn_14+0xc1>
			f35: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
     f39:	test   rax,rax
     f3c:	je     f9c <botlish_fn_14+0x124>
     f42:	xor    ecx,ecx
     f44:	test   rax,0x7
     f4a:	je     f58 <botlish_fn_14+0xe0>
     f50:	mov    rsi,rax
     f53:	jmp    f66 <botlish_fn_14+0xee>
     f58:	movzx  rcx,BYTE PTR [rax]
     f5c:	mov    rsi,rax
     f5f:	rex cmp cl,0x8
     f63:	sete   cl
     f66:	test   cl,cl
     f68:	jne    f88 <botlish_fn_14+0x110>
     f6e:	mov    rdi,rbx
     f71:	mov    rax,QWORD PTR [rdi+0x10]
     f75:	mov    rcx,QWORD PTR [rax+0x8]
     f79:	mov    edx,0x8
     f7e:	call   f83 <botlish_fn_14+0x10b>
			f7f: R_X86_64_PLT32	rt_type_error-0x4
     f83:	jmp    f9c <botlish_fn_14+0x124>
     f88:	mov    rdx,r12
     f8b:	mov    rdi,rbx
     f8e:	call   f93 <botlish_fn_14+0x11b>
			f8f: R_X86_64_PLT32	rt_mutarray_get-0x4
     f93:	test   rax,rax
     f96:	jne    fb7 <botlish_fn_14+0x13f>
     f9c:	xor    rax,rax
     f9f:	mov    rbx,QWORD PTR [rsp+0x20]
     fa4:	mov    r12,QWORD PTR [rsp+0x28]
     fa9:	mov    r13,QWORD PTR [rsp+0x30]
     fae:	add    rsp,0x40
     fb2:	mov    rsp,rbp
     fb5:	pop    rbp
     fb6:	ret
     fb7:	mov    rbx,QWORD PTR [rsp+0x20]
     fbc:	mov    r12,QWORD PTR [rsp+0x28]
     fc1:	mov    r13,QWORD PTR [rsp+0x30]
     fc6:	add    rsp,0x40
     fca:	mov    rsp,rbp
     fcd:	pop    rbp
     fce:	ret
     fcf:	mov    eax,0xa
     fd4:	mov    rbx,QWORD PTR [rsp+0x20]
     fd9:	mov    r12,QWORD PTR [rsp+0x28]
     fde:	mov    r13,QWORD PTR [rsp+0x30]
     fe3:	add    rsp,0x40
     fe7:	mov    rsp,rbp
     fea:	pop    rbp
     feb:	ret
     fec:	add    BYTE PTR [rax],al
     fee:	add    BYTE PTR [rax],al
     ff0:	(bad)
     ff1:	add    BYTE PTR [rax],al
     ff3:	add    BYTE PTR [rax],al
     ff5:	add    BYTE PTR [rax],al
	...

0000000000000ff8 <botlish_entry_14: ht_get<mutarray, str>>:
     ff8:	push   rbp
     ff9:	mov    rbp,rsp
     ffc:	mov    rsi,QWORD PTR [rdx]
     fff:	mov    rdx,QWORD PTR [rdx+0x8]
    1003:	call   1008 <botlish_entry_14+0x10>
			1004: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    1008:	mov    rsp,rbp
    100b:	pop    rbp
    100c:	ret
    100d:	add    BYTE PTR [rax],al
	...

0000000000001010 <botlish_fn_15: ht_contains<mutarray, str>>:
    1010:	push   rbp
    1011:	mov    rbp,rsp
    1014:	sub    rsp,0x40
    1018:	mov    QWORD PTR [rsp+0x20],rbx
    101d:	mov    QWORD PTR [rsp+0x28],r12
    1022:	mov    QWORD PTR [rsp+0x30],r15
    1027:	mov    r15,rdi
    102a:	mov    QWORD PTR [rsp],rsi
    102e:	mov    r12,rsi
    1031:	mov    QWORD PTR [rsp+0x8],rdx
    1036:	mov    rbx,rdx
    1039:	mov    rdx,rbx
    103c:	mov    rsi,r12
    103f:	mov    rdi,r15
    1042:	call   1047 <botlish_fn_15+0x37>
			1043: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    1047:	test   rax,rax
    104a:	je     106f <botlish_fn_15+0x5f>
    1050:	mov    QWORD PTR [rsp+0x10],rax
    1055:	mov    rcx,rax
    1058:	mov    rdx,rbx
    105b:	mov    rsi,r12
    105e:	mov    rdi,r15
    1061:	call   1066 <botlish_fn_15+0x56>
			1062: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    1066:	test   rax,rax
    1069:	jne    108a <botlish_fn_15+0x7a>
    106f:	xor    rax,rax
    1072:	mov    rbx,QWORD PTR [rsp+0x20]
    1077:	mov    r12,QWORD PTR [rsp+0x28]
    107c:	mov    r15,QWORD PTR [rsp+0x30]
    1081:	add    rsp,0x40
    1085:	mov    rsp,rbp
    1088:	pop    rbp
    1089:	ret
    108a:	test   rax,0x1
    1090:	mov    rsi,rax
    1093:	jne    10be <botlish_fn_15+0xae>
    1099:	mov    edx,0x1
    109e:	mov    rdi,r15
    10a1:	call   10a6 <botlish_fn_15+0x96>
			10a2: R_X86_64_PLT32	rt_int_cmp-0x4
    10a6:	mov    ecx,0x2
    10ab:	test   rax,rax
    10ae:	mov    rax,rcx
    10b1:	cmovge rax,QWORD PTR [rip+0x2f]        # 10e8 <botlish_fn_15+0xd8>
    10b9:	jmp    10ce <botlish_fn_15+0xbe>
    10be:	mov    eax,0x2
    10c3:	test   rsi,rsi
    10c6:	cmovg  rax,QWORD PTR [rip+0x1a]        # 10e8 <botlish_fn_15+0xd8>
    10ce:	mov    rbx,QWORD PTR [rsp+0x20]
    10d3:	mov    r12,QWORD PTR [rsp+0x28]
    10d8:	mov    r15,QWORD PTR [rsp+0x30]
    10dd:	add    rsp,0x40
    10e1:	mov    rsp,rbp
    10e4:	pop    rbp
    10e5:	ret
    10e6:	add    BYTE PTR [rax],al
    10e8:	(bad)
    10e9:	add    BYTE PTR [rax],al
    10eb:	add    BYTE PTR [rax],al
    10ed:	add    BYTE PTR [rax],al
	...

00000000000010f0 <botlish_entry_15: ht_contains<mutarray, str>>:
    10f0:	push   rbp
    10f1:	mov    rbp,rsp
    10f4:	mov    rsi,QWORD PTR [rdx]
    10f7:	mov    rdx,QWORD PTR [rdx+0x8]
    10fb:	call   1100 <botlish_entry_15+0x10>
			10fc: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    1100:	mov    rsp,rbp
    1103:	pop    rbp
    1104:	ret
    1105:	add    BYTE PTR [rax],al
	...

0000000000001108 <botlish_fn_16: ht_rehash_probe<mutarray, int, int>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	sub    rsp,0x40
    1110:	mov    QWORD PTR [rsp+0x20],rbx
    1115:	mov    QWORD PTR [rsp+0x28],r12
    111a:	mov    QWORD PTR [rsp+0x30],r13
    111f:	mov    QWORD PTR [rsp+0x38],r14
    1124:	mov    r13,rdi
    1127:	mov    QWORD PTR [rsp],rsi
    112b:	mov    QWORD PTR [rsp+0x8],rdx
    1130:	mov    QWORD PTR [rsp+0x10],rcx
    1135:	mov    r12,rcx
    1138:	mov    rbx,rsi
    113b:	mov    r14,rdx
    113e:	mov    rdx,r14
    1141:	mov    rsi,rbx
    1144:	mov    rdi,r13
    1147:	call   114c <botlish_fn_16+0x44>
			1148: R_X86_64_PLT32	rt_mutarray_get-0x4
    114c:	test   rax,rax
    114f:	je     11ec <botlish_fn_16+0xe4>
    1155:	test   rax,0x1
    115b:	mov    rsi,rax
    115e:	jne    117f <botlish_fn_16+0x77>
    1164:	mov    edx,0x1
    1169:	mov    rdi,r13
    116c:	call   1171 <botlish_fn_16+0x69>
			116d: R_X86_64_PLT32	rt_value_eq-0x4
    1171:	test   rax,rax
    1174:	je     11ec <botlish_fn_16+0xe4>
    117a:	jmp    1190 <botlish_fn_16+0x88>
    117f:	mov    eax,0x2
    1184:	cmp    rsi,0x1
    1188:	cmove  rax,QWORD PTR [rip+0xb8]        # 1248 <botlish_fn_16+0x140>
    1190:	cmp    rax,0x6
    1194:	je     1222 <botlish_fn_16+0x11a>
    119a:	mov    QWORD PTR [rsp+0x18],0x3
    11a3:	mov    rsi,r14
    11a6:	test   rsi,0x1
    11ad:	je     11c5 <botlish_fn_16+0xbd>
    11b3:	mov    rsi,r14
    11b6:	add    rsi,0x2
    11ba:	seto   al
    11bd:	test   al,al
    11bf:	je     11d8 <botlish_fn_16+0xd0>
    11c5:	mov    edx,0x3
    11ca:	mov    rsi,r14
    11cd:	mov    rdi,r13
    11d0:	call   11d5 <botlish_fn_16+0xcd>
			11d1: R_X86_64_PLT32	rt_int_add-0x4
    11d5:	mov    rsi,rax
    11d8:	mov    rdx,r12
    11db:	mov    rdi,r13
    11de:	call   11e3 <botlish_fn_16+0xdb>
			11df: R_X86_64_PLT32	rt_int_mod-0x4
    11e3:	test   rax,rax
    11e6:	jne    120c <botlish_fn_16+0x104>
    11ec:	xor    rax,rax
    11ef:	mov    rbx,QWORD PTR [rsp+0x20]
    11f4:	mov    r12,QWORD PTR [rsp+0x28]
    11f9:	mov    r13,QWORD PTR [rsp+0x30]
    11fe:	mov    r14,QWORD PTR [rsp+0x38]
    1203:	add    rsp,0x40
    1207:	mov    rsp,rbp
    120a:	pop    rbp
    120b:	ret
    120c:	mov    QWORD PTR [rsp],rbx
    1210:	mov    QWORD PTR [rsp+0x8],rax
    1215:	mov    QWORD PTR [rsp+0x10],r12
    121a:	mov    r14,rax
    121d:	jmp    113e <botlish_fn_16+0x36>
    1222:	mov    rax,r14
    1225:	mov    rbx,QWORD PTR [rsp+0x20]
    122a:	mov    r12,QWORD PTR [rsp+0x28]
    122f:	mov    r13,QWORD PTR [rsp+0x30]
    1234:	mov    r14,QWORD PTR [rsp+0x38]
    1239:	add    rsp,0x40
    123d:	mov    rsp,rbp
    1240:	pop    rbp
    1241:	ret
    1242:	add    BYTE PTR [rax],al
    1244:	add    BYTE PTR [rax],al
    1246:	add    BYTE PTR [rax],al
    1248:	(bad)
    1249:	add    BYTE PTR [rax],al
    124b:	add    BYTE PTR [rax],al
    124d:	add    BYTE PTR [rax],al
	...

0000000000001250 <botlish_entry_16: ht_rehash_probe<mutarray, int, int>>:
    1250:	push   rbp
    1251:	mov    rbp,rsp
    1254:	mov    rsi,QWORD PTR [rdx]
    1257:	mov    r8,QWORD PTR [rdx+0x8]
    125b:	mov    rcx,QWORD PTR [rdx+0x10]
    125f:	mov    rdx,r8
    1262:	call   1267 <botlish_entry_16+0x17>
			1263: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash_probe<mutarray, int, int>
    1267:	mov    rsp,rbp
    126a:	pop    rbp
    126b:	ret

000000000000126c <botlish_fn_17: ht_rehash_insert<List[mutarray], int, any, any>>:
    126c:	push   rbp
    126d:	mov    rbp,rsp
    1270:	sub    rsp,0x80
    1277:	mov    QWORD PTR [rsp+0x50],rbx
    127c:	mov    QWORD PTR [rsp+0x58],r12
    1281:	mov    QWORD PTR [rsp+0x60],r13
    1286:	mov    QWORD PTR [rsp+0x68],r14
    128b:	mov    QWORD PTR [rsp+0x70],r15
    1290:	mov    r12,rdi
    1293:	mov    rdi,QWORD PTR [rbp+0x10]
    1297:	mov    QWORD PTR [rsp],rsi
    129b:	mov    QWORD PTR [rsp+0x38],rsi
    12a0:	mov    QWORD PTR [rsp+0x8],rdx
    12a5:	mov    r15,rdx
    12a8:	mov    QWORD PTR [rsp+0x10],rcx
    12ad:	mov    rbx,rcx
    12b0:	mov    QWORD PTR [rsp+0x18],r8
    12b5:	mov    QWORD PTR [rsp+0x40],r8
    12ba:	mov    QWORD PTR [rsp+0x20],r9
    12bf:	mov    r14,r9
    12c2:	mov    QWORD PTR [rsp+0x28],rdi
    12c7:	mov    r13,rdi
    12ca:	mov    rsi,r14
    12cd:	mov    rdi,r12
    12d0:	call   12d5 <botlish_fn_17+0x69>
			12d1: R_X86_64_PLT32	rt_hash-0x4
    12d5:	test   rax,rax
    12d8:	mov    rsi,rax
    12db:	je     137a <botlish_fn_17+0x10e>
    12e1:	mov    rdx,QWORD PTR [rsp+0x40]
    12e6:	mov    rdi,r12
    12e9:	call   12ee <botlish_fn_17+0x82>
			12ea: R_X86_64_PLT32	rt_int_mod-0x4
    12ee:	test   rax,rax
    12f1:	je     137a <botlish_fn_17+0x10e>
    12f7:	mov    QWORD PTR [rsp+0x30],rax
    12fc:	mov    rcx,QWORD PTR [rsp+0x40]
    1301:	mov    rdx,rax
    1304:	mov    rsi,QWORD PTR [rsp+0x38]
    1309:	mov    rdi,r12
    130c:	call   1311 <botlish_fn_17+0xa5>
			130d: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash_probe<mutarray, int, int>
    1311:	mov    rcx,rax
    1314:	mov    QWORD PTR [rsp+0x40],rax
    1319:	test   rax,rcx
    131c:	je     137a <botlish_fn_17+0x10e>
    1322:	mov    ecx,0x3
    1327:	mov    rsi,QWORD PTR [rsp+0x38]
    132c:	mov    rdx,QWORD PTR [rsp+0x40]
    1331:	mov    rdi,r12
    1334:	call   1339 <botlish_fn_17+0xcd>
			1335: R_X86_64_PLT32	rt_mutarray_set-0x4
    1339:	test   rax,rax
    133c:	je     137a <botlish_fn_17+0x10e>
    1342:	mov    rcx,r14
    1345:	mov    rsi,r15
    1348:	mov    rdx,QWORD PTR [rsp+0x40]
    134d:	mov    rdi,r12
    1350:	call   1355 <botlish_fn_17+0xe9>
			1351: R_X86_64_PLT32	rt_mutarray_set-0x4
    1355:	test   rax,rax
    1358:	je     137a <botlish_fn_17+0x10e>
    135e:	mov    rcx,r13
    1361:	mov    rdx,QWORD PTR [rsp+0x40]
    1366:	mov    rsi,rbx
    1369:	mov    rdi,r12
    136c:	call   1371 <botlish_fn_17+0x105>
			136d: R_X86_64_PLT32	rt_mutarray_set-0x4
    1371:	test   rax,rax
    1374:	jne    13a2 <botlish_fn_17+0x136>
    137a:	xor    rax,rax
    137d:	mov    rbx,QWORD PTR [rsp+0x50]
    1382:	mov    r12,QWORD PTR [rsp+0x58]
    1387:	mov    r13,QWORD PTR [rsp+0x60]
    138c:	mov    r14,QWORD PTR [rsp+0x68]
    1391:	mov    r15,QWORD PTR [rsp+0x70]
    1396:	add    rsp,0x80
    139d:	mov    rsp,rbp
    13a0:	pop    rbp
    13a1:	ret
    13a2:	mov    eax,0xa
    13a7:	mov    rbx,QWORD PTR [rsp+0x50]
    13ac:	mov    r12,QWORD PTR [rsp+0x58]
    13b1:	mov    r13,QWORD PTR [rsp+0x60]
    13b6:	mov    r14,QWORD PTR [rsp+0x68]
    13bb:	mov    r15,QWORD PTR [rsp+0x70]
    13c0:	add    rsp,0x80
    13c7:	mov    rsp,rbp
    13ca:	pop    rbp
    13cb:	ret

00000000000013cc <botlish_entry_17: ht_rehash_insert<List[mutarray], int, any, any>>:
    13cc:	push   rbp
    13cd:	mov    rbp,rsp
    13d0:	sub    rsp,0x10
    13d4:	mov    rsi,QWORD PTR [rdx]
    13d7:	mov    r10,QWORD PTR [rdx+0x8]
    13db:	mov    rcx,QWORD PTR [rdx+0x10]
    13df:	mov    r8,QWORD PTR [rdx+0x18]
    13e3:	mov    r9,QWORD PTR [rdx+0x20]
    13e7:	mov    r11,QWORD PTR [rdx+0x28]
    13eb:	mov    QWORD PTR [rsp],r11
    13ef:	mov    rdx,r10
    13f2:	call   13f7 <botlish_entry_17+0x2b>
			13f3: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<List[mutarray], int, any, any>
    13f7:	add    rsp,0x10
    13fb:	mov    rsp,rbp
    13fe:	pop    rbp
    13ff:	ret

0000000000001400 <botlish_fn_18: ht_rehash_scan<list, int, int, List[mutarray], int>>:
    1400:	push   rbp
    1401:	mov    rbp,rsp
    1404:	sub    rsp,0xc0
    140b:	mov    QWORD PTR [rsp+0x90],rbx
    1413:	mov    QWORD PTR [rsp+0x98],r12
    141b:	mov    QWORD PTR [rsp+0xa0],r13
    1423:	mov    QWORD PTR [rsp+0xa8],r14
    142b:	mov    QWORD PTR [rsp+0xb0],r15
    1433:	mov    QWORD PTR [rsp+0x58],rdi
    1438:	mov    r15,QWORD PTR [rbp+0x10]
    143c:	mov    r12,QWORD PTR [rbp+0x18]
    1440:	mov    r13,QWORD PTR [rbp+0x20]
    1444:	mov    r14,QWORD PTR [rbp+0x28]
    1448:	mov    QWORD PTR [rsp+0x10],rsi
    144d:	mov    QWORD PTR [rsp+0x60],rsi
    1452:	mov    QWORD PTR [rsp+0x18],rdx
    1457:	mov    QWORD PTR [rsp+0x68],rdx
    145c:	mov    QWORD PTR [rsp+0x20],rcx
    1461:	mov    QWORD PTR [rsp+0x70],rcx
    1466:	mov    QWORD PTR [rsp+0x28],r15
    146b:	mov    QWORD PTR [rsp+0x30],r12
    1470:	mov    QWORD PTR [rsp+0x38],r13
    1475:	mov    QWORD PTR [rsp+0x40],r14
    147a:	sar    r8,1
    147d:	sar    r9,1
    1480:	mov    QWORD PTR [rsp+0x88],r9
    1488:	mov    rcx,QWORD PTR [rsp+0x88]
    1490:	mov    rbx,r8
    1493:	cmp    rbx,rcx
    1496:	mov    QWORD PTR [rsp+0x88],rcx
    149e:	jge    1707 <botlish_fn_18+0x307>
    14a4:	xor    eax,eax
    14a6:	mov    rsi,QWORD PTR [rsp+0x60]
    14ab:	test   rsi,0x7
    14b2:	jne    14c3 <botlish_fn_18+0xc3>
    14b8:	movzx  r10,BYTE PTR [rsi]
    14bc:	cmp    r10b,0x8
    14c0:	sete   al
    14c3:	test   al,al
    14c5:	jne    14e7 <botlish_fn_18+0xe7>
    14cb:	mov    rdi,QWORD PTR [rsp+0x58]
    14d0:	mov    rax,QWORD PTR [rdi+0x10]
    14d4:	mov    rcx,QWORD PTR [rax+0x8]
    14d8:	mov    edx,0x8
    14dd:	call   14e2 <botlish_fn_18+0xe2>
			14de: R_X86_64_PLT32	rt_type_error-0x4
    14e2:	jmp    1685 <botlish_fn_18+0x285>
    14e7:	mov    QWORD PTR [rsp+0x60],rsi
    14ec:	mov    rdx,rbx
    14ef:	shl    rdx,1
    14f2:	or     rdx,0x1
    14f6:	mov    QWORD PTR [rsp+0x80],rdx
    14fe:	mov    rdi,QWORD PTR [rsp+0x58]
    1503:	call   1508 <botlish_fn_18+0x108>
			1504: R_X86_64_PLT32	rt_mutarray_get-0x4
    1508:	test   rax,rax
    150b:	je     1685 <botlish_fn_18+0x285>
    1511:	test   rax,0x1
    1517:	mov    rsi,rax
    151a:	jne    153d <botlish_fn_18+0x13d>
    1520:	mov    edx,0x3
    1525:	mov    rdi,QWORD PTR [rsp+0x58]
    152a:	call   152f <botlish_fn_18+0x12f>
			152b: R_X86_64_PLT32	rt_value_eq-0x4
    152f:	test   rax,rax
    1532:	je     1685 <botlish_fn_18+0x285>
    1538:	jmp    154e <botlish_fn_18+0x14e>
    153d:	mov    eax,0x2
    1542:	cmp    rsi,0x3
    1546:	cmove  rax,QWORD PTR [rip+0x1f2]        # 1740 <botlish_fn_18+0x340>
    154e:	cmp    rax,0x6
    1552:	je     1562 <botlish_fn_18+0x162>
    1558:	mov    rsi,QWORD PTR [rsp+0x60]
    155d:	jmp    16c1 <botlish_fn_18+0x2c1>
    1562:	xor    esi,esi
    1564:	mov    rdx,QWORD PTR [rsp+0x68]
    1569:	test   rdx,0x7
    1570:	je     1580 <botlish_fn_18+0x180>
    1576:	mov    QWORD PTR [rsp+0x68],rdx
    157b:	jmp    158f <botlish_fn_18+0x18f>
    1580:	movzx  rax,BYTE PTR [rdx]
    1584:	mov    QWORD PTR [rsp+0x68],rdx
    1589:	cmp    al,0x8
    158b:	sete   sil
    158f:	test   sil,sil
    1592:	jne    15b9 <botlish_fn_18+0x1b9>
    1598:	mov    rdi,QWORD PTR [rsp+0x58]
    159d:	mov    rax,QWORD PTR [rdi+0x10]
    15a1:	mov    rcx,QWORD PTR [rax+0x8]
    15a5:	mov    edx,0x8
    15aa:	mov    rsi,QWORD PTR [rsp+0x68]
    15af:	call   15b4 <botlish_fn_18+0x1b4>
			15b0: R_X86_64_PLT32	rt_type_error-0x4
    15b4:	jmp    1685 <botlish_fn_18+0x285>
    15b9:	mov    rdx,QWORD PTR [rsp+0x80]
    15c1:	mov    rsi,QWORD PTR [rsp+0x68]
    15c6:	mov    rdi,QWORD PTR [rsp+0x58]
    15cb:	call   15d0 <botlish_fn_18+0x1d0>
			15cc: R_X86_64_PLT32	rt_mutarray_get-0x4
    15d0:	test   rax,rax
    15d3:	je     1685 <botlish_fn_18+0x285>
    15d9:	mov    QWORD PTR [rsp+0x48],rax
    15de:	mov    QWORD PTR [rsp+0x78],rax
    15e3:	xor    eax,eax
    15e5:	mov    rcx,QWORD PTR [rsp+0x70]
    15ea:	test   rcx,0x7
    15f1:	je     1601 <botlish_fn_18+0x201>
    15f7:	mov    QWORD PTR [rsp+0x70],rcx
    15fc:	jmp    160f <botlish_fn_18+0x20f>
    1601:	movzx  rax,BYTE PTR [rcx]
    1605:	mov    QWORD PTR [rsp+0x70],rcx
    160a:	cmp    al,0x8
    160c:	sete   al
    160f:	test   al,al
    1611:	jne    1638 <botlish_fn_18+0x238>
    1617:	mov    rdi,QWORD PTR [rsp+0x58]
    161c:	mov    rax,QWORD PTR [rdi+0x10]
    1620:	mov    rcx,QWORD PTR [rax+0x8]
    1624:	mov    edx,0x8
    1629:	mov    rsi,QWORD PTR [rsp+0x70]
    162e:	call   1633 <botlish_fn_18+0x233>
			162f: R_X86_64_PLT32	rt_type_error-0x4
    1633:	jmp    1685 <botlish_fn_18+0x285>
    1638:	mov    rdx,QWORD PTR [rsp+0x80]
    1640:	mov    rsi,QWORD PTR [rsp+0x70]
    1645:	mov    rdi,QWORD PTR [rsp+0x58]
    164a:	call   164f <botlish_fn_18+0x24f>
			164b: R_X86_64_PLT32	rt_mutarray_get-0x4
    164f:	test   rax,rax
    1652:	je     1685 <botlish_fn_18+0x285>
    1658:	mov    QWORD PTR [rsp+0x50],rax
    165d:	mov    QWORD PTR [rsp],rax
    1661:	mov    r9,QWORD PTR [rsp+0x78]
    1666:	mov    rcx,r13
    1669:	mov    rdx,r12
    166c:	mov    rsi,r15
    166f:	mov    rdi,QWORD PTR [rsp+0x58]
    1674:	mov    r8,r14
    1677:	call   167c <botlish_fn_18+0x27c>
			1678: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<List[mutarray], int, any, any>
    167c:	test   rax,rax
    167f:	jne    16bc <botlish_fn_18+0x2bc>
    1685:	xor    rax,rax
    1688:	mov    rbx,QWORD PTR [rsp+0x90]
    1690:	mov    r12,QWORD PTR [rsp+0x98]
    1698:	mov    r13,QWORD PTR [rsp+0xa0]
    16a0:	mov    r14,QWORD PTR [rsp+0xa8]
    16a8:	mov    r15,QWORD PTR [rsp+0xb0]
    16b0:	add    rsp,0xc0
    16b7:	mov    rsp,rbp
    16ba:	pop    rbp
    16bb:	ret
    16bc:	mov    rsi,QWORD PTR [rsp+0x60]
    16c1:	mov    rsi,QWORD PTR [rsp+0x60]
    16c6:	mov    QWORD PTR [rsp+0x10],rsi
    16cb:	mov    rsi,QWORD PTR [rsp+0x68]
    16d0:	mov    QWORD PTR [rsp+0x18],rsi
    16d5:	mov    rsi,QWORD PTR [rsp+0x70]
    16da:	mov    QWORD PTR [rsp+0x20],rsi
    16df:	mov    QWORD PTR [rsp+0x28],r15
    16e4:	mov    QWORD PTR [rsp+0x30],r12
    16e9:	mov    QWORD PTR [rsp+0x38],r13
    16ee:	mov    QWORD PTR [rsp+0x40],r14
    16f3:	add    rbx,0x1
    16fa:	mov    rcx,QWORD PTR [rsp+0x88]
    1702:	jmp    1493 <botlish_fn_18+0x93>
    1707:	mov    eax,0xa
    170c:	mov    rbx,QWORD PTR [rsp+0x90]
    1714:	mov    r12,QWORD PTR [rsp+0x98]
    171c:	mov    r13,QWORD PTR [rsp+0xa0]
    1724:	mov    r14,QWORD PTR [rsp+0xa8]
    172c:	mov    r15,QWORD PTR [rsp+0xb0]
    1734:	add    rsp,0xc0
    173b:	mov    rsp,rbp
    173e:	pop    rbp
    173f:	ret
    1740:	(bad)
    1741:	add    BYTE PTR [rax],al
    1743:	add    BYTE PTR [rax],al
    1745:	add    BYTE PTR [rax],al
	...

0000000000001748 <botlish_entry_18: ht_rehash_scan<list, int, int, List[mutarray], int>>:
    1748:	push   rbp
    1749:	mov    rbp,rsp
    174c:	sub    rsp,0x30
    1750:	mov    QWORD PTR [rsp+0x20],r12
    1755:	mov    rsi,QWORD PTR [rdx]
    1758:	mov    rax,QWORD PTR [rdx+0x8]
    175c:	mov    rcx,QWORD PTR [rdx+0x10]
    1760:	mov    r8,QWORD PTR [rdx+0x18]
    1764:	mov    r9,QWORD PTR [rdx+0x20]
    1768:	mov    r10,QWORD PTR [rdx+0x28]
    176c:	mov    r11,QWORD PTR [rdx+0x30]
    1770:	mov    r12,QWORD PTR [rdx+0x38]
    1774:	mov    rdx,QWORD PTR [rdx+0x40]
    1778:	mov    QWORD PTR [rsp],r10
    177c:	mov    QWORD PTR [rsp+0x8],r11
    1781:	mov    QWORD PTR [rsp+0x10],r12
    1786:	mov    QWORD PTR [rsp+0x18],rdx
    178b:	mov    rdx,rax
    178e:	call   1793 <botlish_entry_18+0x4b>
			178f: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    1793:	mov    r12,QWORD PTR [rsp+0x20]
    1798:	add    rsp,0x30
    179c:	mov    rsp,rbp
    179f:	pop    rbp
    17a0:	ret

00000000000017a1 <botlish_fn_19: ht_rehash<mutarray, int>>:
    17a1:	push   rbp
    17a2:	mov    rbp,rsp
    17a5:	sub    rsp,0xd0
    17ac:	mov    QWORD PTR [rsp+0xa0],rbx
    17b4:	mov    QWORD PTR [rsp+0xa8],r12
    17bc:	mov    QWORD PTR [rsp+0xb0],r13
    17c4:	mov    QWORD PTR [rsp+0xb8],r14
    17cc:	mov    QWORD PTR [rsp+0xc0],r15
    17d4:	mov    r13,rdi
    17d7:	mov    QWORD PTR [rsp+0x50],0x0
    17e0:	mov    QWORD PTR [rsp+0x58],0x0
    17e9:	mov    QWORD PTR [rsp+0x60],0x0
    17f2:	mov    QWORD PTR [rsp+0x68],0x0
    17fb:	mov    QWORD PTR [rsp+0x20],rsi
    1800:	mov    r12,rsi
    1803:	mov    QWORD PTR [rsp+0x28],rdx
    1808:	mov    rbx,rdx
    180b:	mov    rsi,r12
    180e:	mov    rdi,r13
    1811:	call   1816 <botlish_fn_19+0x75>
			1812: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    1816:	test   rax,rax
    1819:	je     19e8 <botlish_fn_19+0x247>
    181f:	mov    QWORD PTR [rsp+0x30],rax
    1824:	mov    r14,rax
    1827:	mov    rsi,r12
    182a:	mov    rdi,r13
    182d:	call   1832 <botlish_fn_19+0x91>
			182e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    1832:	test   rax,rax
    1835:	je     19e8 <botlish_fn_19+0x247>
    183b:	mov    QWORD PTR [rsp+0x38],rax
    1840:	mov    r15,rax
    1843:	mov    rsi,r12
    1846:	mov    rdi,r13
    1849:	call   184e <botlish_fn_19+0xad>
			184a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    184e:	test   rax,rax
    1851:	je     19e8 <botlish_fn_19+0x247>
    1857:	mov    QWORD PTR [rsp+0x40],rax
    185c:	mov    QWORD PTR [rsp+0x90],rax
    1864:	mov    rsi,r12
    1867:	mov    rdi,r13
    186a:	call   186f <botlish_fn_19+0xce>
			186b: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    186f:	test   rax,rax
    1872:	je     19e8 <botlish_fn_19+0x247>
    1878:	mov    QWORD PTR [rsp+0x48],rax
    187d:	mov    QWORD PTR [rsp+0x88],rax
    1885:	mov    rsi,rbx
    1888:	mov    rdi,r13
    188b:	call   1890 <botlish_fn_19+0xef>
			188c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1890:	mov    rcx,rax
    1893:	mov    QWORD PTR [rsp+0x80],rax
    189b:	test   rax,rcx
    189e:	je     19e8 <botlish_fn_19+0x247>
    18a4:	mov    rax,QWORD PTR [rsp+0x80]
    18ac:	mov    QWORD PTR [rsp+0x50],rax
    18b1:	mov    edx,0x1
    18b6:	mov    QWORD PTR [rsp+0x58],0x1
    18bf:	mov    rcx,rbx
    18c2:	mov    rsi,QWORD PTR [rsp+0x80]
    18ca:	mov    rdi,r13
    18cd:	call   18d2 <botlish_fn_19+0x131>
			18ce: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
    18d2:	test   rax,rax
    18d5:	je     19e8 <botlish_fn_19+0x247>
    18db:	mov    rsi,rbx
    18de:	mov    rdi,r13
    18e1:	call   18e6 <botlish_fn_19+0x145>
			18e2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    18e6:	test   rax,rax
    18e9:	je     19e8 <botlish_fn_19+0x247>
    18ef:	mov    QWORD PTR [rsp+0x58],rax
    18f4:	mov    QWORD PTR [rsp+0x78],rax
    18f9:	mov    rsi,rbx
    18fc:	mov    rdi,r13
    18ff:	call   1904 <botlish_fn_19+0x163>
			1900: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1904:	test   rax,rax
    1907:	je     19e8 <botlish_fn_19+0x247>
    190d:	mov    QWORD PTR [rsp+0x60],rax
    1912:	mov    r8d,0x1
    1918:	mov    QWORD PTR [rsp+0x68],0x1
    1921:	mov    rcx,QWORD PTR [rsp+0x80]
    1929:	mov    QWORD PTR [rsp],rcx
    192d:	mov    rcx,QWORD PTR [rsp+0x78]
    1932:	mov    QWORD PTR [rsp+0x8],rcx
    1937:	mov    QWORD PTR [rsp+0x10],rax
    193c:	mov    QWORD PTR [rsp+0x70],rax
    1941:	mov    QWORD PTR [rsp+0x18],rbx
    1946:	mov    rcx,QWORD PTR [rsp+0x90]
    194e:	mov    rdx,r15
    1951:	mov    rsi,r14
    1954:	mov    r9,QWORD PTR [rsp+0x88]
    195c:	mov    rdi,r13
    195f:	call   1964 <botlish_fn_19+0x1c3>
			1960: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<list, int, int, List[mutarray], int>
    1964:	test   rax,rax
    1967:	je     19e8 <botlish_fn_19+0x247>
    196d:	mov    edx,0x1
    1972:	mov    rcx,QWORD PTR [rsp+0x80]
    197a:	mov    rsi,r12
    197d:	mov    rdi,r13
    1980:	call   1985 <botlish_fn_19+0x1e4>
			1981: R_X86_64_PLT32	rt_mutarray_set-0x4
    1985:	test   rax,rax
    1988:	je     19e8 <botlish_fn_19+0x247>
    198e:	mov    edx,0x3
    1993:	mov    rcx,QWORD PTR [rsp+0x78]
    1998:	mov    rsi,r12
    199b:	mov    rdi,r13
    199e:	call   19a3 <botlish_fn_19+0x202>
			199f: R_X86_64_PLT32	rt_mutarray_set-0x4
    19a3:	test   rax,rax
    19a6:	je     19e8 <botlish_fn_19+0x247>
    19ac:	mov    edx,0x5
    19b1:	mov    rcx,QWORD PTR [rsp+0x70]
    19b6:	mov    rsi,r12
    19b9:	mov    rdi,r13
    19bc:	call   19c1 <botlish_fn_19+0x220>
			19bd: R_X86_64_PLT32	rt_mutarray_set-0x4
    19c1:	test   rax,rax
    19c4:	je     19e8 <botlish_fn_19+0x247>
    19ca:	mov    edx,0x9
    19cf:	mov    ecx,0x1
    19d4:	mov    rsi,r12
    19d7:	mov    rdi,r13
    19da:	call   19df <botlish_fn_19+0x23e>
			19db: R_X86_64_PLT32	rt_mutarray_set-0x4
    19df:	test   rax,rax
    19e2:	jne    1a1f <botlish_fn_19+0x27e>
    19e8:	xor    rax,rax
    19eb:	mov    rbx,QWORD PTR [rsp+0xa0]
    19f3:	mov    r12,QWORD PTR [rsp+0xa8]
    19fb:	mov    r13,QWORD PTR [rsp+0xb0]
    1a03:	mov    r14,QWORD PTR [rsp+0xb8]
    1a0b:	mov    r15,QWORD PTR [rsp+0xc0]
    1a13:	add    rsp,0xd0
    1a1a:	mov    rsp,rbp
    1a1d:	pop    rbp
    1a1e:	ret
    1a1f:	mov    eax,0xa
    1a24:	mov    rbx,QWORD PTR [rsp+0xa0]
    1a2c:	mov    r12,QWORD PTR [rsp+0xa8]
    1a34:	mov    r13,QWORD PTR [rsp+0xb0]
    1a3c:	mov    r14,QWORD PTR [rsp+0xb8]
    1a44:	mov    r15,QWORD PTR [rsp+0xc0]
    1a4c:	add    rsp,0xd0
    1a53:	mov    rsp,rbp
    1a56:	pop    rbp
    1a57:	ret

0000000000001a58 <botlish_entry_19: ht_rehash<mutarray, int>>:
    1a58:	push   rbp
    1a59:	mov    rbp,rsp
    1a5c:	mov    rsi,QWORD PTR [rdx]
    1a5f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a63:	call   1a68 <botlish_entry_19+0x10>
			1a64: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1a68:	mov    rsp,rbp
    1a6b:	pop    rbp
    1a6c:	ret
    1a6d:	add    BYTE PTR [rax],al
	...

0000000000001a70 <botlish_fn_20: ht_should_grow<mutarray>>:
    1a70:	push   rbp
    1a71:	mov    rbp,rsp
    1a74:	sub    rsp,0x40
    1a78:	mov    QWORD PTR [rsp+0x20],rbx
    1a7d:	mov    QWORD PTR [rsp+0x28],r12
    1a82:	mov    QWORD PTR [rsp+0x30],r13
    1a87:	mov    rbx,rdi
    1a8a:	mov    QWORD PTR [rsp],rsi
    1a8e:	mov    r12,rsi
    1a91:	mov    rsi,r12
    1a94:	mov    rdi,rbx
    1a97:	call   1a9c <botlish_fn_20+0x2c>
			1a98: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1a9c:	mov    rcx,rax
    1a9f:	mov    r13,rax
    1aa2:	test   rax,rcx
    1aa5:	je     1c94 <botlish_fn_20+0x224>
    1aab:	mov    rax,r13
    1aae:	mov    QWORD PTR [rsp+0x8],rax
    1ab3:	mov    rsi,r12
    1ab6:	mov    rdi,rbx
    1ab9:	call   1abe <botlish_fn_20+0x4e>
			1aba: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1abe:	mov    rcx,rax
    1ac1:	test   rcx,rcx
    1ac4:	je     1c94 <botlish_fn_20+0x224>
    1aca:	mov    QWORD PTR [rsp+0x10],rcx
    1acf:	mov    edx,0x1
    1ad4:	mov    rax,r13
    1ad7:	test   rax,0x1
    1add:	jne    1b00 <botlish_fn_20+0x90>
    1ae3:	xor    edx,edx
    1ae5:	mov    rax,r13
    1ae8:	test   rax,0x7
    1aee:	jne    1b00 <botlish_fn_20+0x90>
    1af4:	mov    rax,r13
    1af7:	movzx  rax,BYTE PTR [rax]
    1afb:	cmp    al,0x1
    1afd:	sete   dl
    1b00:	test   dl,dl
    1b02:	jne    1b23 <botlish_fn_20+0xb3>
    1b08:	mov    rdi,rbx
    1b0b:	mov    rax,QWORD PTR [rdi+0x10]
    1b0f:	mov    rcx,QWORD PTR [rax+0x10]
    1b13:	xor    rdx,rdx
    1b16:	mov    rsi,r13
    1b19:	call   1b1e <botlish_fn_20+0xae>
			1b1a: R_X86_64_PLT32	rt_type_error-0x4
    1b1e:	jmp    1c94 <botlish_fn_20+0x224>
    1b23:	mov    eax,0x1
    1b28:	test   rcx,0x1
    1b2f:	je     1b3d <botlish_fn_20+0xcd>
    1b35:	mov    r8,rcx
    1b38:	jmp    1b60 <botlish_fn_20+0xf0>
    1b3d:	xor    eax,eax
    1b3f:	test   rcx,0x7
    1b46:	je     1b54 <botlish_fn_20+0xe4>
    1b4c:	mov    r8,rcx
    1b4f:	jmp    1b60 <botlish_fn_20+0xf0>
    1b54:	movzx  rax,BYTE PTR [rcx]
    1b58:	mov    r8,rcx
    1b5b:	cmp    al,0x1
    1b5d:	sete   al
    1b60:	test   al,al
    1b62:	jne    1b83 <botlish_fn_20+0x113>
    1b68:	mov    rdi,rbx
    1b6b:	mov    rax,QWORD PTR [rdi+0x10]
    1b6f:	mov    rcx,QWORD PTR [rax+0x10]
    1b73:	xor    rdx,rdx
    1b76:	mov    rsi,r8
    1b79:	call   1b7e <botlish_fn_20+0x10e>
			1b7a: R_X86_64_PLT32	rt_type_error-0x4
    1b7e:	jmp    1c94 <botlish_fn_20+0x224>
    1b83:	mov    rcx,r8
    1b86:	mov    rsi,r13
    1b89:	mov    rax,rsi
    1b8c:	and    rax,rcx
    1b8f:	test   rax,0x1
    1b95:	jne    1ba6 <botlish_fn_20+0x136>
    1b9b:	mov    rdx,r8
    1b9e:	mov    rsi,r13
    1ba1:	jmp    1bc4 <botlish_fn_20+0x154>
    1ba6:	mov    rcx,r8
    1ba9:	lea    rax,[rcx-0x1]
    1bad:	mov    rsi,r13
    1bb0:	add    rsi,rax
    1bb3:	seto   al
    1bb6:	test   al,al
    1bb8:	je     1bcf <botlish_fn_20+0x15f>
    1bbe:	mov    rdx,r8
    1bc1:	mov    rsi,r13
    1bc4:	mov    rdi,rbx
    1bc7:	call   1bcc <botlish_fn_20+0x15c>
			1bc8: R_X86_64_PLT32	rt_int_add-0x4
    1bcc:	mov    rsi,rax
    1bcf:	mov    QWORD PTR [rsp+0x8],rsi
    1bd4:	mov    QWORD PTR [rsp+0x10],0x3
    1bdd:	test   rsi,0x1
    1be4:	je     1c07 <botlish_fn_20+0x197>
    1bea:	mov    rax,rsi
    1bed:	add    rax,0x2
    1bf1:	mov    rcx,rax
    1bf4:	seto   al
    1bf7:	test   al,al
    1bf9:	jne    1c07 <botlish_fn_20+0x197>
    1bff:	mov    rsi,rcx
    1c02:	jmp    1c17 <botlish_fn_20+0x1a7>
    1c07:	mov    edx,0x3
    1c0c:	mov    rdi,rbx
    1c0f:	call   1c14 <botlish_fn_20+0x1a4>
			1c10: R_X86_64_PLT32	rt_int_add-0x4
    1c14:	mov    rsi,rax
    1c17:	mov    QWORD PTR [rsp+0x8],rsi
    1c1c:	mov    edx,0x7
    1c21:	mov    rdi,rdx
    1c24:	mov    QWORD PTR [rsp+0x10],0x7
    1c2d:	test   rsi,0x1
    1c34:	jne    1c42 <botlish_fn_20+0x1d2>
    1c3a:	mov    rdx,rdi
    1c3d:	jmp    1c6e <botlish_fn_20+0x1fe>
    1c42:	mov    rax,rsi
    1c45:	sar    rax,1
    1c48:	imul   QWORD PTR [rip+0x119]        # 1d68 <botlish_fn_20+0x2f8>
    1c4f:	seto   cl
    1c52:	or     rax,0x1
    1c56:	test   cl,cl
    1c58:	je     1c66 <botlish_fn_20+0x1f6>
    1c5e:	mov    rdx,rdi
    1c61:	jmp    1c6e <botlish_fn_20+0x1fe>
    1c66:	mov    rsi,rax
    1c69:	jmp    1c79 <botlish_fn_20+0x209>
    1c6e:	mov    rdi,rbx
    1c71:	call   1c76 <botlish_fn_20+0x206>
			1c72: R_X86_64_PLT32	rt_int_mul-0x4
    1c76:	mov    rsi,rax
    1c79:	mov    QWORD PTR [rsp],rsi
    1c7d:	mov    r13,rsi
    1c80:	mov    rsi,r12
    1c83:	mov    rdi,rbx
    1c86:	call   1c8b <botlish_fn_20+0x21b>
			1c87: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1c8b:	test   rax,rax
    1c8e:	jne    1caf <botlish_fn_20+0x23f>
    1c94:	xor    rax,rax
    1c97:	mov    rbx,QWORD PTR [rsp+0x20]
    1c9c:	mov    r12,QWORD PTR [rsp+0x28]
    1ca1:	mov    r13,QWORD PTR [rsp+0x30]
    1ca6:	add    rsp,0x40
    1caa:	mov    rsp,rbp
    1cad:	pop    rbp
    1cae:	ret
    1caf:	mov    QWORD PTR [rsp+0x8],rax
    1cb4:	mov    QWORD PTR [rsp+0x10],0x5
    1cbd:	test   rax,0x1
    1cc3:	mov    rsi,rax
    1cc6:	je     1cf8 <botlish_fn_20+0x288>
    1ccc:	mov    rcx,rsi
    1ccf:	mov    rax,rcx
    1cd2:	sar    rax,1
    1cd5:	imul   QWORD PTR [rip+0x94]        # 1d70 <botlish_fn_20+0x300>
    1cdc:	seto   dil
    1ce0:	or     rax,0x1
    1ce4:	test   dil,dil
    1ce7:	jne    1cf8 <botlish_fn_20+0x288>
    1ced:	mov    rdx,rax
    1cf0:	mov    rsi,r13
    1cf3:	jmp    1d0b <botlish_fn_20+0x29b>
    1cf8:	mov    edx,0x5
    1cfd:	mov    rdi,rbx
    1d00:	call   1d05 <botlish_fn_20+0x295>
			1d01: R_X86_64_PLT32	rt_int_mul-0x4
    1d05:	mov    rdx,rax
    1d08:	mov    rsi,r13
    1d0b:	mov    r10,rsi
    1d0e:	and    r10,rdx
    1d11:	test   r10,0x1
    1d18:	jne    1d3f <botlish_fn_20+0x2cf>
    1d1e:	mov    rdi,rbx
    1d21:	call   1d26 <botlish_fn_20+0x2b6>
			1d22: R_X86_64_PLT32	rt_int_cmp-0x4
    1d26:	mov    r8d,0x2
    1d2c:	test   rax,rax
    1d2f:	mov    rax,r8
    1d32:	cmovg  rax,QWORD PTR [rip+0x2e]        # 1d68 <botlish_fn_20+0x2f8>
    1d3a:	jmp    1d4f <botlish_fn_20+0x2df>
    1d3f:	mov    eax,0x2
    1d44:	cmp    rsi,rdx
    1d47:	cmovg  rax,QWORD PTR [rip+0x19]        # 1d68 <botlish_fn_20+0x2f8>
    1d4f:	mov    rbx,QWORD PTR [rsp+0x20]
    1d54:	mov    r12,QWORD PTR [rsp+0x28]
    1d59:	mov    r13,QWORD PTR [rsp+0x30]
    1d5e:	add    rsp,0x40
    1d62:	mov    rsp,rbp
    1d65:	pop    rbp
    1d66:	ret
    1d67:	add    BYTE PTR [rsi],al
    1d69:	add    BYTE PTR [rax],al
    1d6b:	add    BYTE PTR [rax],al
    1d6d:	add    BYTE PTR [rax],al
    1d6f:	add    BYTE PTR [rax+rax*1],al
    1d72:	add    BYTE PTR [rax],al
    1d74:	add    BYTE PTR [rax],al
	...

0000000000001d78 <botlish_entry_20: ht_should_grow<mutarray>>:
    1d78:	push   rbp
    1d79:	mov    rbp,rsp
    1d7c:	mov    rsi,QWORD PTR [rdx]
    1d7f:	call   1d84 <botlish_entry_20+0xc>
			1d80: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    1d84:	mov    rsp,rbp
    1d87:	pop    rbp
    1d88:	ret
    1d89:	add    BYTE PTR [rax],al
    1d8b:	add    BYTE PTR [rax],al
    1d8d:	add    BYTE PTR [rax],al
	...

0000000000001d90 <botlish_fn_21: ht_grow_or_clean<mutarray>>:
    1d90:	push   rbp
    1d91:	mov    rbp,rsp
    1d94:	sub    rsp,0x40
    1d98:	mov    QWORD PTR [rsp+0x20],rbx
    1d9d:	mov    QWORD PTR [rsp+0x28],r12
    1da2:	mov    QWORD PTR [rsp+0x30],r13
    1da7:	mov    rbx,rdi
    1daa:	mov    QWORD PTR [rsp+0x10],0x0
    1db3:	mov    QWORD PTR [rsp],rsi
    1db7:	mov    r12,rsi
    1dba:	mov    rsi,r12
    1dbd:	mov    rdi,rbx
    1dc0:	call   1dc5 <botlish_fn_21+0x35>
			1dc1: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1dc5:	test   rax,rax
    1dc8:	mov    r13,rax
    1dcb:	je     1fb8 <botlish_fn_21+0x228>
    1dd1:	mov    rsi,r12
    1dd4:	mov    rdi,rbx
    1dd7:	call   1ddc <botlish_fn_21+0x4c>
			1dd8: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1ddc:	mov    rcx,rax
    1ddf:	test   rcx,rcx
    1de2:	je     1fb8 <botlish_fn_21+0x228>
    1de8:	mov    edx,0x1
    1ded:	mov    rax,r13
    1df0:	test   rax,0x1
    1df6:	je     1e04 <botlish_fn_21+0x74>
    1dfc:	mov    r13,rax
    1dff:	jmp    1e28 <botlish_fn_21+0x98>
    1e04:	xor    edx,edx
    1e06:	test   rax,0x7
    1e0c:	je     1e1a <botlish_fn_21+0x8a>
    1e12:	mov    r13,rax
    1e15:	jmp    1e28 <botlish_fn_21+0x98>
    1e1a:	movzx  rdx,BYTE PTR [rax]
    1e1e:	mov    r13,rax
    1e21:	rex cmp dl,0x1
    1e25:	sete   dl
    1e28:	test   dl,dl
    1e2a:	jne    1e4b <botlish_fn_21+0xbb>
    1e30:	mov    rdi,rbx
    1e33:	mov    rsi,QWORD PTR [rdi+0x10]
    1e37:	mov    rcx,QWORD PTR [rsi+0x18]
    1e3b:	xor    rdx,rdx
    1e3e:	mov    rsi,r13
    1e41:	call   1e46 <botlish_fn_21+0xb6>
			1e42: R_X86_64_PLT32	rt_type_error-0x4
    1e46:	jmp    1fb8 <botlish_fn_21+0x228>
    1e4b:	mov    rsi,r13
    1e4e:	mov    eax,0x1
    1e53:	test   rcx,0x1
    1e5a:	je     1e68 <botlish_fn_21+0xd8>
    1e60:	mov    r8,rcx
    1e63:	jmp    1e8d <botlish_fn_21+0xfd>
    1e68:	xor    eax,eax
    1e6a:	test   rcx,0x7
    1e71:	je     1e7f <botlish_fn_21+0xef>
    1e77:	mov    r8,rcx
    1e7a:	jmp    1e8d <botlish_fn_21+0xfd>
    1e7f:	movzx  r11,BYTE PTR [rcx]
    1e83:	mov    r8,rcx
    1e86:	cmp    r11b,0x1
    1e8a:	sete   al
    1e8d:	test   al,al
    1e8f:	jne    1eb0 <botlish_fn_21+0x120>
    1e95:	mov    rdi,rbx
    1e98:	mov    rax,QWORD PTR [rdi+0x10]
    1e9c:	mov    rcx,QWORD PTR [rax+0x18]
    1ea0:	xor    rdx,rdx
    1ea3:	mov    rsi,r8
    1ea6:	call   1eab <botlish_fn_21+0x11b>
			1ea7: R_X86_64_PLT32	rt_type_error-0x4
    1eab:	jmp    1fb8 <botlish_fn_21+0x228>
    1eb0:	mov    rcx,r8
    1eb3:	mov    rax,rsi
    1eb6:	and    rax,rcx
    1eb9:	test   rax,0x1
    1ebf:	jne    1ee5 <botlish_fn_21+0x155>
    1ec5:	mov    rdx,r8
    1ec8:	mov    rdi,rbx
    1ecb:	call   1ed0 <botlish_fn_21+0x140>
			1ecc: R_X86_64_PLT32	rt_int_cmp-0x4
    1ed0:	mov    ecx,0x2
    1ed5:	test   rax,rax
    1ed8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1ff0 <botlish_fn_21+0x260>
    1ee0:	jmp    1ef8 <botlish_fn_21+0x168>
    1ee5:	mov    ecx,0x2
    1eea:	mov    r9,r8
    1eed:	cmp    rsi,r9
    1ef0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1ff0 <botlish_fn_21+0x260>
    1ef8:	cmp    rcx,0x6
    1efc:	je     1f88 <botlish_fn_21+0x1f8>
    1f02:	mov    rsi,r12
    1f05:	mov    rdi,rbx
    1f08:	call   1f0d <botlish_fn_21+0x17d>
			1f09: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1f0d:	test   rax,rax
    1f10:	je     1fb8 <botlish_fn_21+0x228>
    1f16:	mov    QWORD PTR [rsp+0x8],rax
    1f1b:	mov    QWORD PTR [rsp+0x10],0x5
    1f24:	test   rax,0x1
    1f2a:	mov    rsi,rax
    1f2d:	je     1f5a <botlish_fn_21+0x1ca>
    1f33:	mov    rcx,rsi
    1f36:	mov    rax,rcx
    1f39:	sar    rax,1
    1f3c:	imul   QWORD PTR [rip+0xb5]        # 1ff8 <botlish_fn_21+0x268>
    1f43:	seto   cl
    1f46:	or     rax,0x1
    1f4a:	test   cl,cl
    1f4c:	jne    1f5a <botlish_fn_21+0x1ca>
    1f52:	mov    rdx,rax
    1f55:	jmp    1f6a <botlish_fn_21+0x1da>
    1f5a:	mov    edx,0x5
    1f5f:	mov    rdi,rbx
    1f62:	call   1f67 <botlish_fn_21+0x1d7>
			1f63: R_X86_64_PLT32	rt_int_mul-0x4
    1f67:	mov    rdx,rax
    1f6a:	mov    QWORD PTR [rsp+0x8],rdx
    1f6f:	mov    rsi,r12
    1f72:	mov    rdi,rbx
    1f75:	call   1f7a <botlish_fn_21+0x1ea>
			1f76: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1f7a:	test   rax,rax
    1f7d:	je     1fb8 <botlish_fn_21+0x228>
    1f83:	jmp    1fd3 <botlish_fn_21+0x243>
    1f88:	mov    rsi,r12
    1f8b:	mov    rdi,rbx
    1f8e:	call   1f93 <botlish_fn_21+0x203>
			1f8f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1f93:	test   rax,rax
    1f96:	je     1fb8 <botlish_fn_21+0x228>
    1f9c:	mov    QWORD PTR [rsp+0x8],rax
    1fa1:	mov    rdx,rax
    1fa4:	mov    rsi,r12
    1fa7:	mov    rdi,rbx
    1faa:	call   1faf <botlish_fn_21+0x21f>
			1fab: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1faf:	test   rax,rax
    1fb2:	jne    1fd3 <botlish_fn_21+0x243>
    1fb8:	xor    rax,rax
    1fbb:	mov    rbx,QWORD PTR [rsp+0x20]
    1fc0:	mov    r12,QWORD PTR [rsp+0x28]
    1fc5:	mov    r13,QWORD PTR [rsp+0x30]
    1fca:	add    rsp,0x40
    1fce:	mov    rsp,rbp
    1fd1:	pop    rbp
    1fd2:	ret
    1fd3:	mov    rbx,QWORD PTR [rsp+0x20]
    1fd8:	mov    r12,QWORD PTR [rsp+0x28]
    1fdd:	mov    r13,QWORD PTR [rsp+0x30]
    1fe2:	add    rsp,0x40
    1fe6:	mov    rsp,rbp
    1fe9:	pop    rbp
    1fea:	ret
    1feb:	add    BYTE PTR [rax],al
    1fed:	add    BYTE PTR [rax],al
    1fef:	add    BYTE PTR [rsi],al
    1ff1:	add    BYTE PTR [rax],al
    1ff3:	add    BYTE PTR [rax],al
    1ff5:	add    BYTE PTR [rax],al
    1ff7:	add    BYTE PTR [rax+rax*1],al
    1ffa:	add    BYTE PTR [rax],al
    1ffc:	add    BYTE PTR [rax],al
	...

0000000000002000 <botlish_entry_21: ht_grow_or_clean<mutarray>>:
    2000:	push   rbp
    2001:	mov    rbp,rsp
    2004:	mov    rsi,QWORD PTR [rdx]
    2007:	call   200c <botlish_entry_21+0xc>
			2008: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    200c:	mov    rsp,rbp
    200f:	pop    rbp
    2010:	ret
    2011:	add    BYTE PTR [rax],al
    2013:	add    BYTE PTR [rax],al
    2015:	add    BYTE PTR [rax],al
	...

0000000000002018 <botlish_fn_22: ht_place<mutarray, int, str, str>>:
    2018:	push   rbp
    2019:	mov    rbp,rsp
    201c:	sub    rsp,0x70
    2020:	mov    QWORD PTR [rsp+0x40],rbx
    2025:	mov    QWORD PTR [rsp+0x48],r12
    202a:	mov    QWORD PTR [rsp+0x50],r13
    202f:	mov    QWORD PTR [rsp+0x58],r14
    2034:	mov    QWORD PTR [rsp+0x60],r15
    2039:	mov    rbx,rdi
    203c:	mov    r14,r8
    203f:	mov    r15,rdx
    2042:	mov    QWORD PTR [rsp+0x28],rcx
    2047:	mov    QWORD PTR [rsp],rsi
    204b:	mov    r12,rsi
    204e:	mov    rsi,r12
    2051:	mov    rdi,rbx
    2054:	call   2059 <botlish_fn_22+0x41>
			2055: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    2059:	test   rax,rax
    205c:	je     23c2 <botlish_fn_22+0x3aa>
    2062:	xor    ecx,ecx
    2064:	test   rax,0x7
    206a:	je     207a <botlish_fn_22+0x62>
    2070:	mov    QWORD PTR [rsp+0x30],rax
    2075:	jmp    208a <botlish_fn_22+0x72>
    207a:	movzx  rcx,BYTE PTR [rax]
    207e:	mov    QWORD PTR [rsp+0x30],rax
    2083:	rex cmp cl,0x8
    2087:	sete   cl
    208a:	test   cl,cl
    208c:	jne    20b1 <botlish_fn_22+0x99>
    2092:	mov    rdi,rbx
    2095:	mov    rax,QWORD PTR [rdi+0x10]
    2099:	mov    rcx,QWORD PTR [rax+0x8]
    209d:	mov    edx,0x8
    20a2:	mov    rsi,QWORD PTR [rsp+0x30]
    20a7:	call   20ac <botlish_fn_22+0x94>
			20a8: R_X86_64_PLT32	rt_type_error-0x4
    20ac:	jmp    23c2 <botlish_fn_22+0x3aa>
    20b1:	mov    rdx,r15
    20b4:	mov    rsi,QWORD PTR [rsp+0x30]
    20b9:	mov    rdi,rbx
    20bc:	call   20c1 <botlish_fn_22+0xa9>
			20bd: R_X86_64_PLT32	rt_mutarray_get-0x4
    20c1:	test   rax,rax
    20c4:	je     23c2 <botlish_fn_22+0x3aa>
    20ca:	mov    QWORD PTR [rsp+0x8],rax
    20cf:	mov    r13,rax
    20d2:	mov    ecx,0x3
    20d7:	mov    rsi,QWORD PTR [rsp+0x30]
    20dc:	mov    rdx,r15
    20df:	mov    rdi,rbx
    20e2:	call   20e7 <botlish_fn_22+0xcf>
			20e3: R_X86_64_PLT32	rt_mutarray_set-0x4
    20e7:	test   rax,rax
    20ea:	je     23c2 <botlish_fn_22+0x3aa>
    20f0:	mov    rsi,r12
    20f3:	mov    rdi,rbx
    20f6:	call   20fb <botlish_fn_22+0xe3>
			20f7: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    20fb:	test   rax,rax
    20fe:	je     23c2 <botlish_fn_22+0x3aa>
    2104:	xor    ecx,ecx
    2106:	test   rax,0x7
    210c:	je     211a <botlish_fn_22+0x102>
    2112:	mov    rsi,rax
    2115:	jmp    2128 <botlish_fn_22+0x110>
    211a:	movzx  rcx,BYTE PTR [rax]
    211e:	mov    rsi,rax
    2121:	rex cmp cl,0x8
    2125:	sete   cl
    2128:	test   cl,cl
    212a:	jne    214a <botlish_fn_22+0x132>
    2130:	mov    rdi,rbx
    2133:	mov    rax,QWORD PTR [rdi+0x10]
    2137:	mov    rcx,QWORD PTR [rax+0x20]
    213b:	mov    edx,0x8
    2140:	call   2145 <botlish_fn_22+0x12d>
			2141: R_X86_64_PLT32	rt_type_error-0x4
    2145:	jmp    23c2 <botlish_fn_22+0x3aa>
    214a:	mov    rcx,QWORD PTR [rsp+0x28]
    214f:	mov    rdx,r15
    2152:	mov    rdi,rbx
    2155:	call   215a <botlish_fn_22+0x142>
			2156: R_X86_64_PLT32	rt_mutarray_set-0x4
    215a:	test   rax,rax
    215d:	je     23c2 <botlish_fn_22+0x3aa>
    2163:	mov    rsi,r12
    2166:	mov    rdi,rbx
    2169:	call   216e <botlish_fn_22+0x156>
			216a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    216e:	test   rax,rax
    2171:	je     23c2 <botlish_fn_22+0x3aa>
    2177:	xor    esi,esi
    2179:	test   rax,0x7
    217f:	jne    2191 <botlish_fn_22+0x179>
    2185:	movzx  rcx,BYTE PTR [rax]
    2189:	rex cmp cl,0x8
    218d:	sete   sil
    2191:	test   sil,sil
    2194:	jne    21b7 <botlish_fn_22+0x19f>
    219a:	mov    rdi,rbx
    219d:	mov    rsi,QWORD PTR [rdi+0x10]
    21a1:	mov    rcx,QWORD PTR [rsi+0x20]
    21a5:	mov    edx,0x8
    21aa:	mov    rsi,rax
    21ad:	call   21b2 <botlish_fn_22+0x19a>
			21ae: R_X86_64_PLT32	rt_type_error-0x4
    21b2:	jmp    23c2 <botlish_fn_22+0x3aa>
    21b7:	mov    rcx,r14
    21ba:	mov    rdx,r15
    21bd:	mov    rsi,rax
    21c0:	mov    rdi,rbx
    21c3:	call   21c8 <botlish_fn_22+0x1b0>
			21c4: R_X86_64_PLT32	rt_mutarray_set-0x4
    21c8:	test   rax,rax
    21cb:	je     23c2 <botlish_fn_22+0x3aa>
    21d1:	mov    QWORD PTR [rsp+0x10],0x7
    21da:	mov    rsi,r12
    21dd:	mov    rdi,rbx
    21e0:	call   21e5 <botlish_fn_22+0x1cd>
			21e1: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    21e5:	test   rax,rax
    21e8:	je     23c2 <botlish_fn_22+0x3aa>
    21ee:	mov    QWORD PTR [rsp+0x18],rax
    21f3:	mov    QWORD PTR [rsp+0x20],0x3
    21fc:	mov    ecx,0x1
    2201:	test   rax,0x1
    2207:	je     2215 <botlish_fn_22+0x1fd>
    220d:	mov    rsi,rax
    2210:	jmp    2239 <botlish_fn_22+0x221>
    2215:	xor    ecx,ecx
    2217:	test   rax,0x7
    221d:	je     222b <botlish_fn_22+0x213>
    2223:	mov    rsi,rax
    2226:	jmp    2239 <botlish_fn_22+0x221>
    222b:	movzx  rcx,BYTE PTR [rax]
    222f:	mov    rsi,rax
    2232:	rex cmp cl,0x1
    2236:	sete   cl
    2239:	test   cl,cl
    223b:	jne    2259 <botlish_fn_22+0x241>
    2241:	mov    rdi,rbx
    2244:	mov    rax,QWORD PTR [rdi+0x10]
    2248:	mov    rcx,QWORD PTR [rax+0x10]
    224c:	xor    rdx,rdx
    224f:	call   2254 <botlish_fn_22+0x23c>
			2250: R_X86_64_PLT32	rt_type_error-0x4
    2254:	jmp    23c2 <botlish_fn_22+0x3aa>
    2259:	test   rsi,0x1
    2260:	je     2278 <botlish_fn_22+0x260>
    2266:	mov    rcx,rsi
    2269:	add    rcx,0x2
    226d:	seto   al
    2270:	test   al,al
    2272:	je     2288 <botlish_fn_22+0x270>
    2278:	mov    edx,0x3
    227d:	mov    rdi,rbx
    2280:	call   2285 <botlish_fn_22+0x26d>
			2281: R_X86_64_PLT32	rt_int_add-0x4
    2285:	mov    rcx,rax
    2288:	mov    edx,0x7
    228d:	mov    rsi,r12
    2290:	mov    rdi,rbx
    2293:	call   2298 <botlish_fn_22+0x280>
			2294: R_X86_64_PLT32	rt_mutarray_set-0x4
    2298:	test   rax,rax
    229b:	je     23c2 <botlish_fn_22+0x3aa>
    22a1:	mov    rax,r13
    22a4:	test   rax,0x1
    22aa:	jne    22ce <botlish_fn_22+0x2b6>
    22b0:	mov    edx,0x5
    22b5:	mov    rsi,r13
    22b8:	mov    rdi,rbx
    22bb:	call   22c0 <botlish_fn_22+0x2a8>
			22bc: R_X86_64_PLT32	rt_value_eq-0x4
    22c0:	test   rax,rax
    22c3:	je     23c2 <botlish_fn_22+0x3aa>
    22c9:	jmp    22e2 <botlish_fn_22+0x2ca>
    22ce:	mov    rsi,r13
    22d1:	mov    eax,0x2
    22d6:	cmp    rsi,0x5
    22da:	cmove  rax,QWORD PTR [rip+0x12e]        # 2410 <botlish_fn_22+0x3f8>
    22e2:	cmp    rax,0x6
    22e6:	jne    23e7 <botlish_fn_22+0x3cf>
    22ec:	mov    QWORD PTR [rsp+0x8],0x9
    22f5:	mov    rsi,r12
    22f8:	mov    rdi,rbx
    22fb:	call   2300 <botlish_fn_22+0x2e8>
			22fc: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2300:	test   rax,rax
    2303:	je     23c2 <botlish_fn_22+0x3aa>
    2309:	mov    QWORD PTR [rsp+0x10],rax
    230e:	mov    QWORD PTR [rsp+0x18],0x3
    2317:	mov    ecx,0x1
    231c:	test   rax,0x1
    2322:	je     2330 <botlish_fn_22+0x318>
    2328:	mov    rsi,rax
    232b:	jmp    2354 <botlish_fn_22+0x33c>
    2330:	xor    ecx,ecx
    2332:	test   rax,0x7
    2338:	je     2346 <botlish_fn_22+0x32e>
    233e:	mov    rsi,rax
    2341:	jmp    2354 <botlish_fn_22+0x33c>
    2346:	movzx  rcx,BYTE PTR [rax]
    234a:	mov    rsi,rax
    234d:	rex cmp cl,0x1
    2351:	sete   cl
    2354:	test   cl,cl
    2356:	jne    2374 <botlish_fn_22+0x35c>
    235c:	mov    rdi,rbx
    235f:	mov    rcx,QWORD PTR [rdi+0x10]
    2363:	mov    rcx,QWORD PTR [rcx+0x28]
    2367:	xor    rdx,rdx
    236a:	call   236f <botlish_fn_22+0x357>
			236b: R_X86_64_PLT32	rt_type_error-0x4
    236f:	jmp    23c2 <botlish_fn_22+0x3aa>
    2374:	test   rsi,0x1
    237b:	je     2399 <botlish_fn_22+0x381>
    2381:	mov    r8,rsi
    2384:	sub    r8,0x3
    2388:	seto   dil
    238c:	lea    rcx,[r8+0x1]
    2390:	test   dil,dil
    2393:	je     23a9 <botlish_fn_22+0x391>
    2399:	mov    edx,0x3
    239e:	mov    rdi,rbx
    23a1:	call   23a6 <botlish_fn_22+0x38e>
			23a2: R_X86_64_PLT32	rt_int_sub-0x4
    23a6:	mov    rcx,rax
    23a9:	mov    edx,0x9
    23ae:	mov    rsi,r12
    23b1:	mov    rdi,rbx
    23b4:	call   23b9 <botlish_fn_22+0x3a1>
			23b5: R_X86_64_PLT32	rt_mutarray_set-0x4
    23b9:	test   rax,rax
    23bc:	jne    23e7 <botlish_fn_22+0x3cf>
    23c2:	xor    rax,rax
    23c5:	mov    rbx,QWORD PTR [rsp+0x40]
    23ca:	mov    r12,QWORD PTR [rsp+0x48]
    23cf:	mov    r13,QWORD PTR [rsp+0x50]
    23d4:	mov    r14,QWORD PTR [rsp+0x58]
    23d9:	mov    r15,QWORD PTR [rsp+0x60]
    23de:	add    rsp,0x70
    23e2:	mov    rsp,rbp
    23e5:	pop    rbp
    23e6:	ret
    23e7:	mov    eax,0xa
    23ec:	mov    rbx,QWORD PTR [rsp+0x40]
    23f1:	mov    r12,QWORD PTR [rsp+0x48]
    23f6:	mov    r13,QWORD PTR [rsp+0x50]
    23fb:	mov    r14,QWORD PTR [rsp+0x58]
    2400:	mov    r15,QWORD PTR [rsp+0x60]
    2405:	add    rsp,0x70
    2409:	mov    rsp,rbp
    240c:	pop    rbp
    240d:	ret
    240e:	add    BYTE PTR [rax],al
    2410:	(bad)
    2411:	add    BYTE PTR [rax],al
    2413:	add    BYTE PTR [rax],al
    2415:	add    BYTE PTR [rax],al
	...

0000000000002418 <botlish_entry_22: ht_place<mutarray, int, str, str>>:
    2418:	push   rbp
    2419:	mov    rbp,rsp
    241c:	mov    rsi,QWORD PTR [rdx]
    241f:	mov    r9,QWORD PTR [rdx+0x8]
    2423:	mov    rcx,QWORD PTR [rdx+0x10]
    2427:	mov    r8,QWORD PTR [rdx+0x18]
    242b:	mov    rdx,r9
    242e:	call   2433 <botlish_entry_22+0x1b>
			242f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    2433:	mov    rsp,rbp
    2436:	pop    rbp
    2437:	ret

0000000000002438 <botlish_fn_23: ht_set<mutarray, str, str>>:
    2438:	push   rbp
    2439:	mov    rbp,rsp
    243c:	sub    rsp,0x60
    2440:	mov    QWORD PTR [rsp+0x30],rbx
    2445:	mov    QWORD PTR [rsp+0x38],r12
    244a:	mov    QWORD PTR [rsp+0x40],r13
    244f:	mov    QWORD PTR [rsp+0x48],r14
    2454:	mov    QWORD PTR [rsp+0x50],r15
    2459:	mov    rbx,rdi
    245c:	mov    r13,rdx
    245f:	mov    QWORD PTR [rsp],rsi
    2463:	mov    r14,rsi
    2466:	mov    QWORD PTR [rsp+0x8],rdx
    246b:	mov    QWORD PTR [rsp+0x10],rcx
    2470:	mov    r12,rcx
    2473:	mov    rdx,r13
    2476:	mov    rsi,r14
    2479:	mov    rdi,rbx
    247c:	call   2481 <botlish_fn_23+0x49>
			247d: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2481:	test   rax,rax
    2484:	je     26ef <botlish_fn_23+0x2b7>
    248a:	mov    QWORD PTR [rsp+0x18],rax
    248f:	mov    rcx,rax
    2492:	mov    r8,0xffffffffffffffff
    2499:	mov    QWORD PTR [rsp+0x28],r8
    249e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    24a7:	mov    rdx,r13
    24aa:	mov    rsi,r14
    24ad:	mov    rdi,rbx
    24b0:	call   24b5 <botlish_fn_23+0x7d>
			24b1: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    24b5:	mov    rcx,rax
    24b8:	mov    r15,rax
    24bb:	test   rax,rcx
    24be:	je     26ef <botlish_fn_23+0x2b7>
    24c4:	mov    rax,r15
    24c7:	mov    QWORD PTR [rsp+0x18],rax
    24cc:	mov    rsi,r14
    24cf:	mov    rdi,rbx
    24d2:	call   24d7 <botlish_fn_23+0x9f>
			24d3: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    24d7:	test   rax,rax
    24da:	je     26ef <botlish_fn_23+0x2b7>
    24e0:	xor    ecx,ecx
    24e2:	test   rax,0x7
    24e8:	je     24f6 <botlish_fn_23+0xbe>
    24ee:	mov    r8,rax
    24f1:	jmp    2504 <botlish_fn_23+0xcc>
    24f6:	movzx  rcx,BYTE PTR [rax]
    24fa:	mov    r8,rax
    24fd:	rex cmp cl,0x8
    2501:	sete   cl
    2504:	test   cl,cl
    2506:	jne    2529 <botlish_fn_23+0xf1>
    250c:	mov    rdi,rbx
    250f:	mov    rsi,QWORD PTR [rdi+0x10]
    2513:	mov    rcx,QWORD PTR [rsi+0x8]
    2517:	mov    edx,0x8
    251c:	mov    rsi,r8
    251f:	call   2524 <botlish_fn_23+0xec>
			2520: R_X86_64_PLT32	rt_type_error-0x4
    2524:	jmp    26ef <botlish_fn_23+0x2b7>
    2529:	mov    rsi,r8
    252c:	mov    rdx,r15
    252f:	mov    rdi,rbx
    2532:	call   2537 <botlish_fn_23+0xff>
			2533: R_X86_64_PLT32	rt_mutarray_get-0x4
    2537:	test   rax,rax
    253a:	je     26ef <botlish_fn_23+0x2b7>
    2540:	test   rax,0x1
    2546:	mov    rsi,rax
    2549:	jne    256a <botlish_fn_23+0x132>
    254f:	mov    edx,0x3
    2554:	mov    rdi,rbx
    2557:	call   255c <botlish_fn_23+0x124>
			2558: R_X86_64_PLT32	rt_value_eq-0x4
    255c:	test   rax,rax
    255f:	je     26ef <botlish_fn_23+0x2b7>
    2565:	jmp    257b <botlish_fn_23+0x143>
    256a:	mov    eax,0x2
    256f:	cmp    rsi,0x3
    2573:	cmove  rax,QWORD PTR [rip+0x1c5]        # 2740 <botlish_fn_23+0x308>
    257b:	cmp    rax,0x6
    257f:	je     267e <botlish_fn_23+0x246>
    2585:	mov    rsi,r14
    2588:	mov    rdi,rbx
    258b:	call   2590 <botlish_fn_23+0x158>
			258c: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    2590:	test   rax,rax
    2593:	je     26ef <botlish_fn_23+0x2b7>
    2599:	cmp    rax,0x6
    259d:	je     25e2 <botlish_fn_23+0x1aa>
    25a3:	mov    rcx,r13
    25a6:	mov    rdx,r15
    25a9:	mov    rsi,r14
    25ac:	mov    rdi,rbx
    25af:	mov    r8,r12
    25b2:	call   25b7 <botlish_fn_23+0x17f>
			25b3: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    25b7:	test   rax,rax
    25ba:	je     26ef <botlish_fn_23+0x2b7>
    25c0:	mov    rbx,QWORD PTR [rsp+0x30]
    25c5:	mov    r12,QWORD PTR [rsp+0x38]
    25ca:	mov    r13,QWORD PTR [rsp+0x40]
    25cf:	mov    r14,QWORD PTR [rsp+0x48]
    25d4:	mov    r15,QWORD PTR [rsp+0x50]
    25d9:	add    rsp,0x60
    25dd:	mov    rsp,rbp
    25e0:	pop    rbp
    25e1:	ret
    25e2:	mov    rsi,r14
    25e5:	mov    rdi,rbx
    25e8:	call   25ed <botlish_fn_23+0x1b5>
			25e9: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    25ed:	test   rax,rax
    25f0:	je     26ef <botlish_fn_23+0x2b7>
    25f6:	mov    rdx,r13
    25f9:	mov    rsi,r14
    25fc:	mov    rdi,rbx
    25ff:	call   2604 <botlish_fn_23+0x1cc>
			2600: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2604:	test   rax,rax
    2607:	je     26ef <botlish_fn_23+0x2b7>
    260d:	mov    QWORD PTR [rsp+0x18],rax
    2612:	mov    rcx,rax
    2615:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    261e:	mov    r8,QWORD PTR [rsp+0x28]
    2623:	mov    rdx,r13
    2626:	mov    rsi,r14
    2629:	mov    rdi,rbx
    262c:	call   2631 <botlish_fn_23+0x1f9>
			262d: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    2631:	test   rax,rax
    2634:	je     26ef <botlish_fn_23+0x2b7>
    263a:	mov    QWORD PTR [rsp+0x18],rax
    263f:	mov    rcx,r13
    2642:	mov    rdx,rax
    2645:	mov    rsi,r14
    2648:	mov    rdi,rbx
    264b:	mov    r8,r12
    264e:	call   2653 <botlish_fn_23+0x21b>
			264f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    2653:	test   rax,rax
    2656:	je     26ef <botlish_fn_23+0x2b7>
    265c:	mov    rbx,QWORD PTR [rsp+0x30]
    2661:	mov    r12,QWORD PTR [rsp+0x38]
    2666:	mov    r13,QWORD PTR [rsp+0x40]
    266b:	mov    r14,QWORD PTR [rsp+0x48]
    2670:	mov    r15,QWORD PTR [rsp+0x50]
    2675:	add    rsp,0x60
    2679:	mov    rsp,rbp
    267c:	pop    rbp
    267d:	ret
    267e:	mov    rsi,r14
    2681:	mov    rdi,rbx
    2684:	call   2689 <botlish_fn_23+0x251>
			2685: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    2689:	test   rax,rax
    268c:	je     26ef <botlish_fn_23+0x2b7>
    2692:	xor    ecx,ecx
    2694:	test   rax,0x7
    269a:	je     26a8 <botlish_fn_23+0x270>
    26a0:	mov    rsi,rax
    26a3:	jmp    26b6 <botlish_fn_23+0x27e>
    26a8:	movzx  rcx,BYTE PTR [rax]
    26ac:	mov    rsi,rax
    26af:	rex cmp cl,0x8
    26b3:	sete   cl
    26b6:	test   cl,cl
    26b8:	jne    26d8 <botlish_fn_23+0x2a0>
    26be:	mov    rdi,rbx
    26c1:	mov    rax,QWORD PTR [rdi+0x10]
    26c5:	mov    rcx,QWORD PTR [rax+0x20]
    26c9:	mov    edx,0x8
    26ce:	call   26d3 <botlish_fn_23+0x29b>
			26cf: R_X86_64_PLT32	rt_type_error-0x4
    26d3:	jmp    26ef <botlish_fn_23+0x2b7>
    26d8:	mov    rcx,r12
    26db:	mov    rdx,r15
    26de:	mov    rdi,rbx
    26e1:	call   26e6 <botlish_fn_23+0x2ae>
			26e2: R_X86_64_PLT32	rt_mutarray_set-0x4
    26e6:	test   rax,rax
    26e9:	jne    2714 <botlish_fn_23+0x2dc>
    26ef:	xor    rax,rax
    26f2:	mov    rbx,QWORD PTR [rsp+0x30]
    26f7:	mov    r12,QWORD PTR [rsp+0x38]
    26fc:	mov    r13,QWORD PTR [rsp+0x40]
    2701:	mov    r14,QWORD PTR [rsp+0x48]
    2706:	mov    r15,QWORD PTR [rsp+0x50]
    270b:	add    rsp,0x60
    270f:	mov    rsp,rbp
    2712:	pop    rbp
    2713:	ret
    2714:	mov    eax,0xa
    2719:	mov    rbx,QWORD PTR [rsp+0x30]
    271e:	mov    r12,QWORD PTR [rsp+0x38]
    2723:	mov    r13,QWORD PTR [rsp+0x40]
    2728:	mov    r14,QWORD PTR [rsp+0x48]
    272d:	mov    r15,QWORD PTR [rsp+0x50]
    2732:	add    rsp,0x60
    2736:	mov    rsp,rbp
    2739:	pop    rbp
    273a:	ret
    273b:	add    BYTE PTR [rax],al
    273d:	add    BYTE PTR [rax],al
    273f:	add    BYTE PTR [rsi],al
    2741:	add    BYTE PTR [rax],al
    2743:	add    BYTE PTR [rax],al
    2745:	add    BYTE PTR [rax],al
	...

0000000000002748 <botlish_entry_23: ht_set<mutarray, str, str>>:
    2748:	push   rbp
    2749:	mov    rbp,rsp
    274c:	mov    rsi,QWORD PTR [rdx]
    274f:	mov    r8,QWORD PTR [rdx+0x8]
    2753:	mov    rcx,QWORD PTR [rdx+0x10]
    2757:	mov    rdx,r8
    275a:	call   275f <botlish_entry_23+0x17>
			275b: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    275f:	mov    rsp,rbp
    2762:	pop    rbp
    2763:	ret
    2764:	add    BYTE PTR [rax],al
	...

0000000000002768 <botlish_fn_24: ht_delete<mutarray, str>>:
    2768:	push   rbp
    2769:	mov    rbp,rsp
    276c:	sub    rsp,0x40
    2770:	mov    QWORD PTR [rsp+0x20],rbx
    2775:	mov    QWORD PTR [rsp+0x28],r12
    277a:	mov    QWORD PTR [rsp+0x30],r13
    277f:	mov    rbx,rdi
    2782:	mov    QWORD PTR [rsp+0x18],0x0
    278b:	mov    QWORD PTR [rsp],rsi
    278f:	mov    r12,rsi
    2792:	mov    QWORD PTR [rsp+0x8],rdx
    2797:	mov    r13,rdx
    279a:	mov    rdx,r13
    279d:	mov    rsi,r12
    27a0:	mov    rdi,rbx
    27a3:	call   27a8 <botlish_fn_24+0x40>
			27a4: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    27a8:	test   rax,rax
    27ab:	je     2b18 <botlish_fn_24+0x3b0>
    27b1:	mov    QWORD PTR [rsp+0x10],rax
    27b6:	mov    rcx,rax
    27b9:	mov    rdx,r13
    27bc:	mov    rsi,r12
    27bf:	mov    rdi,rbx
    27c2:	call   27c7 <botlish_fn_24+0x5f>
			27c3: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    27c7:	mov    rcx,rax
    27ca:	mov    r13,rax
    27cd:	test   rax,rcx
    27d0:	je     2b18 <botlish_fn_24+0x3b0>
    27d6:	mov    rax,r13
    27d9:	test   rax,0x1
    27df:	jne    280a <botlish_fn_24+0xa2>
    27e5:	mov    edx,0x1
    27ea:	mov    rsi,r13
    27ed:	mov    rdi,rbx
    27f0:	call   27f5 <botlish_fn_24+0x8d>
			27f1: R_X86_64_PLT32	rt_int_cmp-0x4
    27f5:	mov    ecx,0x2
    27fa:	test   rax,rax
    27fd:	cmovl  rcx,QWORD PTR [rip+0x36b]        # 2b70 <botlish_fn_24+0x408>
    2805:	jmp    2820 <botlish_fn_24+0xb8>
    280a:	mov    ecx,0x2
    280f:	mov    rax,r13
    2812:	mov    rdx,r13
    2815:	test   rax,rdx
    2818:	cmovle rcx,QWORD PTR [rip+0x350]        # 2b70 <botlish_fn_24+0x408>
    2820:	cmp    rcx,0x6
    2824:	je     2b50 <botlish_fn_24+0x3e8>
    282a:	mov    rsi,r12
    282d:	mov    rdi,rbx
    2830:	call   2835 <botlish_fn_24+0xcd>
			2831: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    2835:	test   rax,rax
    2838:	je     2b18 <botlish_fn_24+0x3b0>
    283e:	xor    ecx,ecx
    2840:	test   rax,0x7
    2846:	je     2854 <botlish_fn_24+0xec>
    284c:	mov    rsi,rax
    284f:	jmp    2862 <botlish_fn_24+0xfa>
    2854:	movzx  rcx,BYTE PTR [rax]
    2858:	mov    rsi,rax
    285b:	rex cmp cl,0x8
    285f:	sete   cl
    2862:	test   cl,cl
    2864:	jne    2884 <botlish_fn_24+0x11c>
    286a:	mov    rdi,rbx
    286d:	mov    rax,QWORD PTR [rdi+0x10]
    2871:	mov    rcx,QWORD PTR [rax+0x20]
    2875:	mov    edx,0x8
    287a:	call   287f <botlish_fn_24+0x117>
			287b: R_X86_64_PLT32	rt_type_error-0x4
    287f:	jmp    2b18 <botlish_fn_24+0x3b0>
    2884:	mov    ecx,0x5
    2889:	mov    rdx,r13
    288c:	mov    rdi,rbx
    288f:	call   2894 <botlish_fn_24+0x12c>
			2890: R_X86_64_PLT32	rt_mutarray_set-0x4
    2894:	test   rax,rax
    2897:	je     2b18 <botlish_fn_24+0x3b0>
    289d:	mov    rsi,r12
    28a0:	mov    rdi,rbx
    28a3:	call   28a8 <botlish_fn_24+0x140>
			28a4: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    28a8:	test   rax,rax
    28ab:	je     2b18 <botlish_fn_24+0x3b0>
    28b1:	xor    ecx,ecx
    28b3:	test   rax,0x7
    28b9:	jne    28ca <botlish_fn_24+0x162>
    28bf:	movzx  rsi,BYTE PTR [rax]
    28c3:	cmp    sil,0x8
    28c7:	sete   cl
    28ca:	test   cl,cl
    28cc:	jne    28ef <botlish_fn_24+0x187>
    28d2:	mov    rdi,rbx
    28d5:	mov    r9,QWORD PTR [rdi+0x10]
    28d9:	mov    rcx,QWORD PTR [r9+0x20]
    28dd:	mov    edx,0x8
    28e2:	mov    rsi,rax
    28e5:	call   28ea <botlish_fn_24+0x182>
			28e6: R_X86_64_PLT32	rt_type_error-0x4
    28ea:	jmp    2b18 <botlish_fn_24+0x3b0>
    28ef:	mov    rsi,rax
    28f2:	mov    ecx,0xa
    28f7:	mov    rdx,r13
    28fa:	mov    rdi,rbx
    28fd:	call   2902 <botlish_fn_24+0x19a>
			28fe: R_X86_64_PLT32	rt_mutarray_set-0x4
    2902:	test   rax,rax
    2905:	je     2b18 <botlish_fn_24+0x3b0>
    290b:	mov    rsi,r12
    290e:	mov    rdi,rbx
    2911:	call   2916 <botlish_fn_24+0x1ae>
			2912: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    2916:	test   rax,rax
    2919:	je     2b18 <botlish_fn_24+0x3b0>
    291f:	xor    ecx,ecx
    2921:	test   rax,0x7
    2927:	je     2935 <botlish_fn_24+0x1cd>
    292d:	mov    rsi,rax
    2930:	jmp    2943 <botlish_fn_24+0x1db>
    2935:	movzx  rcx,BYTE PTR [rax]
    2939:	mov    rsi,rax
    293c:	rex cmp cl,0x8
    2940:	sete   cl
    2943:	test   cl,cl
    2945:	jne    2965 <botlish_fn_24+0x1fd>
    294b:	mov    rdi,rbx
    294e:	mov    rax,QWORD PTR [rdi+0x10]
    2952:	mov    rcx,QWORD PTR [rax+0x20]
    2956:	mov    edx,0x8
    295b:	call   2960 <botlish_fn_24+0x1f8>
			295c: R_X86_64_PLT32	rt_type_error-0x4
    2960:	jmp    2b18 <botlish_fn_24+0x3b0>
    2965:	mov    ecx,0xa
    296a:	mov    rdx,r13
    296d:	mov    rdi,rbx
    2970:	call   2975 <botlish_fn_24+0x20d>
			2971: R_X86_64_PLT32	rt_mutarray_set-0x4
    2975:	test   rax,rax
    2978:	je     2b18 <botlish_fn_24+0x3b0>
    297e:	mov    QWORD PTR [rsp+0x8],0x7
    2987:	mov    rsi,r12
    298a:	mov    rdi,rbx
    298d:	call   2992 <botlish_fn_24+0x22a>
			298e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2992:	test   rax,rax
    2995:	je     2b18 <botlish_fn_24+0x3b0>
    299b:	mov    QWORD PTR [rsp+0x10],rax
    29a0:	mov    QWORD PTR [rsp+0x18],0x3
    29a9:	mov    ecx,0x1
    29ae:	test   rax,0x1
    29b4:	je     29c2 <botlish_fn_24+0x25a>
    29ba:	mov    rsi,rax
    29bd:	jmp    29e6 <botlish_fn_24+0x27e>
    29c2:	xor    ecx,ecx
    29c4:	test   rax,0x7
    29ca:	je     29d8 <botlish_fn_24+0x270>
    29d0:	mov    rsi,rax
    29d3:	jmp    29e6 <botlish_fn_24+0x27e>
    29d8:	movzx  rcx,BYTE PTR [rax]
    29dc:	mov    rsi,rax
    29df:	rex cmp cl,0x1
    29e3:	sete   cl
    29e6:	test   cl,cl
    29e8:	jne    2a06 <botlish_fn_24+0x29e>
    29ee:	mov    rdi,rbx
    29f1:	mov    rax,QWORD PTR [rdi+0x10]
    29f5:	mov    rcx,QWORD PTR [rax+0x28]
    29f9:	xor    rdx,rdx
    29fc:	call   2a01 <botlish_fn_24+0x299>
			29fd: R_X86_64_PLT32	rt_type_error-0x4
    2a01:	jmp    2b18 <botlish_fn_24+0x3b0>
    2a06:	test   rsi,0x1
    2a0d:	je     2a2c <botlish_fn_24+0x2c4>
    2a13:	mov    rcx,rsi
    2a16:	sub    rcx,0x3
    2a1a:	seto   al
    2a1d:	add    rcx,0x1
    2a24:	test   al,al
    2a26:	je     2a3c <botlish_fn_24+0x2d4>
    2a2c:	mov    edx,0x3
    2a31:	mov    rdi,rbx
    2a34:	call   2a39 <botlish_fn_24+0x2d1>
			2a35: R_X86_64_PLT32	rt_int_sub-0x4
    2a39:	mov    rcx,rax
    2a3c:	mov    edx,0x7
    2a41:	mov    rsi,r12
    2a44:	mov    rdi,rbx
    2a47:	call   2a4c <botlish_fn_24+0x2e4>
			2a48: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a4c:	test   rax,rax
    2a4f:	je     2b18 <botlish_fn_24+0x3b0>
    2a55:	mov    QWORD PTR [rsp+0x8],0x9
    2a5e:	mov    rsi,r12
    2a61:	mov    rdi,rbx
    2a64:	call   2a69 <botlish_fn_24+0x301>
			2a65: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2a69:	test   rax,rax
    2a6c:	je     2b18 <botlish_fn_24+0x3b0>
    2a72:	mov    QWORD PTR [rsp+0x10],rax
    2a77:	mov    QWORD PTR [rsp+0x18],0x3
    2a80:	mov    ecx,0x1
    2a85:	test   rax,0x1
    2a8b:	jne    2aaa <botlish_fn_24+0x342>
    2a91:	xor    ecx,ecx
    2a93:	test   rax,0x7
    2a99:	jne    2aaa <botlish_fn_24+0x342>
    2a9f:	movzx  rsi,BYTE PTR [rax]
    2aa3:	cmp    sil,0x1
    2aa7:	sete   cl
    2aaa:	test   cl,cl
    2aac:	jne    2acd <botlish_fn_24+0x365>
    2ab2:	mov    rdi,rbx
    2ab5:	mov    r8,QWORD PTR [rdi+0x10]
    2ab9:	mov    rcx,QWORD PTR [r8+0x10]
    2abd:	xor    rdx,rdx
    2ac0:	mov    rsi,rax
    2ac3:	call   2ac8 <botlish_fn_24+0x360>
			2ac4: R_X86_64_PLT32	rt_type_error-0x4
    2ac8:	jmp    2b18 <botlish_fn_24+0x3b0>
    2acd:	mov    rsi,rax
    2ad0:	test   rsi,0x1
    2ad7:	je     2aef <botlish_fn_24+0x387>
    2add:	mov    rcx,rsi
    2ae0:	add    rcx,0x2
    2ae4:	seto   al
    2ae7:	test   al,al
    2ae9:	je     2aff <botlish_fn_24+0x397>
    2aef:	mov    edx,0x3
    2af4:	mov    rdi,rbx
    2af7:	call   2afc <botlish_fn_24+0x394>
			2af8: R_X86_64_PLT32	rt_int_add-0x4
    2afc:	mov    rcx,rax
    2aff:	mov    edx,0x9
    2b04:	mov    rsi,r12
    2b07:	mov    rdi,rbx
    2b0a:	call   2b0f <botlish_fn_24+0x3a7>
			2b0b: R_X86_64_PLT32	rt_mutarray_set-0x4
    2b0f:	test   rax,rax
    2b12:	jne    2b33 <botlish_fn_24+0x3cb>
    2b18:	xor    rax,rax
    2b1b:	mov    rbx,QWORD PTR [rsp+0x20]
    2b20:	mov    r12,QWORD PTR [rsp+0x28]
    2b25:	mov    r13,QWORD PTR [rsp+0x30]
    2b2a:	add    rsp,0x40
    2b2e:	mov    rsp,rbp
    2b31:	pop    rbp
    2b32:	ret
    2b33:	mov    eax,0xa
    2b38:	mov    rbx,QWORD PTR [rsp+0x20]
    2b3d:	mov    r12,QWORD PTR [rsp+0x28]
    2b42:	mov    r13,QWORD PTR [rsp+0x30]
    2b47:	add    rsp,0x40
    2b4b:	mov    rsp,rbp
    2b4e:	pop    rbp
    2b4f:	ret
    2b50:	mov    eax,0xa
    2b55:	mov    rbx,QWORD PTR [rsp+0x20]
    2b5a:	mov    r12,QWORD PTR [rsp+0x28]
    2b5f:	mov    r13,QWORD PTR [rsp+0x30]
    2b64:	add    rsp,0x40
    2b68:	mov    rsp,rbp
    2b6b:	pop    rbp
    2b6c:	ret
    2b6d:	add    BYTE PTR [rax],al
    2b6f:	add    BYTE PTR [rsi],al
    2b71:	add    BYTE PTR [rax],al
    2b73:	add    BYTE PTR [rax],al
    2b75:	add    BYTE PTR [rax],al
	...

0000000000002b78 <botlish_entry_24: ht_delete<mutarray, str>>:
    2b78:	push   rbp
    2b79:	mov    rbp,rsp
    2b7c:	mov    rsi,QWORD PTR [rdx]
    2b7f:	mov    rdx,QWORD PTR [rdx+0x8]
    2b83:	call   2b88 <botlish_entry_24+0x10>
			2b84: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2b88:	mov    rsp,rbp
    2b8b:	pop    rbp
    2b8c:	ret
    2b8d:	add    BYTE PTR [rax],al
	...

0000000000002b90 <botlish_fn_25: sample<generic>>:
    2b90:	push   rbp
    2b91:	mov    rbp,rsp
    2b94:	sub    rsp,0xa0
    2b9b:	mov    QWORD PTR [rsp+0x70],rbx
    2ba0:	mov    QWORD PTR [rsp+0x78],r12
    2ba5:	mov    QWORD PTR [rsp+0x80],r13
    2bad:	mov    QWORD PTR [rsp+0x88],r14
    2bb5:	mov    QWORD PTR [rsp+0x90],r15
    2bbd:	mov    r14,rdi
    2bc0:	mov    QWORD PTR [rsp],0x0
    2bc8:	mov    QWORD PTR [rsp+0x8],0x0
    2bd1:	mov    QWORD PTR [rsp+0x10],0x0
    2bda:	mov    QWORD PTR [rsp+0x18],0x0
    2be3:	mov    QWORD PTR [rsp+0x20],0x0
    2bec:	mov    QWORD PTR [rsp+0x28],0x0
    2bf5:	mov    rdi,r14
    2bf8:	call   2bfd <botlish_fn_25+0x6d>
			2bf9: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    2bfd:	mov    rcx,rax
    2c00:	mov    r15,rax
    2c03:	test   rax,rcx
    2c06:	je     2e46 <botlish_fn_25+0x2b6>
    2c0c:	mov    rax,r15
    2c0f:	mov    QWORD PTR [rsp],rax
    2c13:	mov    rdi,r14
    2c16:	mov    rax,QWORD PTR [rdi+0x10]
    2c1a:	mov    rdx,QWORD PTR [rax+0x30]
    2c1e:	mov    QWORD PTR [rsp+0x8],rdx
    2c23:	mov    rax,QWORD PTR [rdi+0x10]
    2c27:	mov    rcx,QWORD PTR [rax+0x38]
    2c2b:	mov    QWORD PTR [rsp+0x10],rcx
    2c30:	mov    rsi,r15
    2c33:	call   2c38 <botlish_fn_25+0xa8>
			2c34: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c38:	test   rax,rax
    2c3b:	je     2e46 <botlish_fn_25+0x2b6>
    2c41:	mov    rdi,r14
    2c44:	mov    rsi,QWORD PTR [rdi+0x10]
    2c48:	mov    rdx,QWORD PTR [rsi+0x40]
    2c4c:	mov    QWORD PTR [rsp+0x8],rdx
    2c51:	mov    rsi,QWORD PTR [rdi+0x10]
    2c55:	mov    rcx,QWORD PTR [rsi+0x48]
    2c59:	mov    QWORD PTR [rsp+0x10],rcx
    2c5e:	mov    rsi,r15
    2c61:	call   2c66 <botlish_fn_25+0xd6>
			2c62: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c66:	test   rax,rax
    2c69:	je     2e46 <botlish_fn_25+0x2b6>
    2c6f:	mov    rdi,r14
    2c72:	mov    r9,QWORD PTR [rdi+0x10]
    2c76:	mov    rdx,QWORD PTR [r9+0x30]
    2c7a:	mov    QWORD PTR [rsp+0x8],rdx
    2c7f:	mov    r10,QWORD PTR [rdi+0x10]
    2c83:	mov    rcx,QWORD PTR [r10+0x50]
    2c87:	mov    QWORD PTR [rsp+0x10],rcx
    2c8c:	mov    rsi,r15
    2c8f:	call   2c94 <botlish_fn_25+0x104>
			2c90: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c94:	test   rax,rax
    2c97:	je     2e46 <botlish_fn_25+0x2b6>
    2c9d:	mov    rdi,r14
    2ca0:	mov    rax,QWORD PTR [rdi+0x10]
    2ca4:	mov    rdx,QWORD PTR [rax+0x40]
    2ca8:	mov    QWORD PTR [rsp+0x8],rdx
    2cad:	mov    rsi,r15
    2cb0:	call   2cb5 <botlish_fn_25+0x125>
			2cb1: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2cb5:	mov    rbx,rax
    2cb8:	test   rbx,rbx
    2cbb:	je     2e46 <botlish_fn_25+0x2b6>
    2cc1:	mov    QWORD PTR [rsp+0x8],rbx
    2cc6:	mov    rdi,r14
    2cc9:	mov    rax,QWORD PTR [rdi+0x10]
    2ccd:	mov    rdx,QWORD PTR [rax+0x40]
    2cd1:	mov    QWORD PTR [rsp+0x10],rdx
    2cd6:	mov    rsi,r15
    2cd9:	call   2cde <botlish_fn_25+0x14e>
			2cda: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2cde:	test   rax,rax
    2ce1:	je     2e46 <botlish_fn_25+0x2b6>
    2ce7:	mov    rdi,r14
    2cea:	mov    rax,QWORD PTR [rdi+0x10]
    2cee:	mov    rdx,QWORD PTR [rax+0x30]
    2cf2:	mov    QWORD PTR [rsp+0x10],rdx
    2cf7:	mov    rsi,r15
    2cfa:	call   2cff <botlish_fn_25+0x16f>
			2cfb: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2cff:	test   rax,rax
    2d02:	je     2e46 <botlish_fn_25+0x2b6>
    2d08:	mov    rdi,r14
    2d0b:	mov    rcx,QWORD PTR [rdi+0x10]
    2d0f:	mov    rdx,QWORD PTR [rcx+0x50]
    2d13:	mov    rcx,rax
    2d16:	and    rcx,rdx
    2d19:	mov    rsi,rax
    2d1c:	test   rcx,0x1
    2d23:	jne    2d3f <botlish_fn_25+0x1af>
    2d29:	mov    rdi,r14
    2d2c:	call   2d31 <botlish_fn_25+0x1a1>
			2d2d: R_X86_64_PLT32	rt_value_eq-0x4
    2d31:	test   rax,rax
    2d34:	je     2e46 <botlish_fn_25+0x2b6>
    2d3a:	jmp    2d4f <botlish_fn_25+0x1bf>
    2d3f:	mov    eax,0x2
    2d44:	cmp    rsi,rdx
    2d47:	cmove  rax,QWORD PTR [rip+0x159]        # 2ea8 <botlish_fn_25+0x318>
    2d4f:	mov    QWORD PTR [rsp+0x10],rax
    2d54:	mov    rdi,r14
    2d57:	mov    QWORD PTR [rsp+0x60],rax
    2d5c:	mov    rax,QWORD PTR [rdi+0x10]
    2d60:	mov    rdx,QWORD PTR [rax+0x40]
    2d64:	mov    QWORD PTR [rsp+0x18],rdx
    2d69:	mov    rsi,r15
    2d6c:	call   2d71 <botlish_fn_25+0x1e1>
			2d6d: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2d71:	mov    r12,rax
    2d74:	test   r12,r12
    2d77:	je     2e46 <botlish_fn_25+0x2b6>
    2d7d:	mov    QWORD PTR [rsp+0x18],r12
    2d82:	mov    rdi,r14
    2d85:	mov    rax,QWORD PTR [rdi+0x10]
    2d89:	mov    rdx,QWORD PTR [rax+0x58]
    2d8d:	mov    QWORD PTR [rsp+0x20],rdx
    2d92:	mov    rsi,r15
    2d95:	call   2d9a <botlish_fn_25+0x20a>
			2d96: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2d9a:	mov    r13,rax
    2d9d:	test   r13,r13
    2da0:	je     2e46 <botlish_fn_25+0x2b6>
    2da6:	mov    QWORD PTR [rsp+0x20],r13
    2dab:	mov    rdi,r14
    2dae:	mov    rax,QWORD PTR [rdi+0x10]
    2db2:	mov    rdx,QWORD PTR [rax+0x58]
    2db6:	mov    QWORD PTR [rsp+0x28],rdx
    2dbb:	mov    rsi,r15
    2dbe:	call   2dc3 <botlish_fn_25+0x233>
			2dbf: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2dc3:	test   rax,rax
    2dc6:	mov    rsi,rax
    2dc9:	je     2e46 <botlish_fn_25+0x2b6>
    2dcf:	mov    edx,0xa
    2dd4:	mov    rdi,r14
    2dd7:	call   2ddc <botlish_fn_25+0x24c>
			2dd8: R_X86_64_PLT32	rt_value_eq-0x4
    2ddc:	test   rax,rax
    2ddf:	je     2e46 <botlish_fn_25+0x2b6>
    2de5:	mov    QWORD PTR [rsp],rax
    2de9:	mov    rsi,r15
    2dec:	mov    r15,rax
    2def:	mov    rdi,r14
    2df2:	call   2df7 <botlish_fn_25+0x267>
			2df3: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2df7:	test   rax,rax
    2dfa:	je     2e46 <botlish_fn_25+0x2b6>
    2e00:	mov    QWORD PTR [rsp+0x28],rax
    2e05:	lea    rdx,[rsp+0x30]
    2e0a:	mov    rsi,QWORD PTR [rsp+0x60]
    2e0f:	mov    QWORD PTR [rsp+0x30],rsi
    2e14:	mov    QWORD PTR [rsp+0x38],rbx
    2e19:	mov    QWORD PTR [rsp+0x40],r12
    2e1e:	mov    QWORD PTR [rsp+0x48],r13
    2e23:	mov    r8,r15
    2e26:	mov    QWORD PTR [rsp+0x50],r8
    2e2b:	mov    QWORD PTR [rsp+0x58],rax
    2e30:	mov    esi,0x6
    2e35:	mov    rdi,r14
    2e38:	call   2e3d <botlish_fn_25+0x2ad>
			2e39: R_X86_64_PLT32	rt_list_new-0x4
    2e3d:	test   rax,rax
    2e40:	jne    2e77 <botlish_fn_25+0x2e7>
    2e46:	xor    rax,rax
    2e49:	mov    rbx,QWORD PTR [rsp+0x70]
    2e4e:	mov    r12,QWORD PTR [rsp+0x78]
    2e53:	mov    r13,QWORD PTR [rsp+0x80]
    2e5b:	mov    r14,QWORD PTR [rsp+0x88]
    2e63:	mov    r15,QWORD PTR [rsp+0x90]
    2e6b:	add    rsp,0xa0
    2e72:	mov    rsp,rbp
    2e75:	pop    rbp
    2e76:	ret
    2e77:	mov    rbx,QWORD PTR [rsp+0x70]
    2e7c:	mov    r12,QWORD PTR [rsp+0x78]
    2e81:	mov    r13,QWORD PTR [rsp+0x80]
    2e89:	mov    r14,QWORD PTR [rsp+0x88]
    2e91:	mov    r15,QWORD PTR [rsp+0x90]
    2e99:	add    rsp,0xa0
    2ea0:	mov    rsp,rbp
    2ea3:	pop    rbp
    2ea4:	ret
    2ea5:	add    BYTE PTR [rax],al
    2ea7:	add    BYTE PTR [rsi],al
    2ea9:	add    BYTE PTR [rax],al
    2eab:	add    BYTE PTR [rax],al
    2ead:	add    BYTE PTR [rax],al
	...

0000000000002eb0 <botlish_entry_25: sample<generic>>:
    2eb0:	push   rbp
    2eb1:	mov    rbp,rsp
    2eb4:	call   2eb9 <botlish_entry_25+0x9>
			2eb5: R_X86_64_PLT32	botlish_fn_25-0x4 ; sample<generic>
    2eb9:	mov    rsp,rbp
    2ebc:	pop    rbp
    2ebd:	ret

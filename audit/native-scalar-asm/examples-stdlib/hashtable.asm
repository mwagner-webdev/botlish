; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12868  (per function: 45 388 524 70 61 61 61 61 61 167 179 245 804 1248 429 253 380 439 1113 766 817 665 1168 836 1189 838)
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
;   botlish_fn_17 / botlish_entry_17 -> ht_rehash_insert<list<mutarray>, int, any, any>
;   botlish_fn_18 / botlish_entry_18 -> ht_rehash_scan<list, int, int, list<mutarray>, int>
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

000000000000126c <botlish_fn_17: ht_rehash_insert<list<mutarray>, int, any, any>>:
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

00000000000013cc <botlish_entry_17: ht_rehash_insert<list<mutarray>, int, any, any>>:
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
			13f3: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    13f7:	add    rsp,0x10
    13fb:	mov    rsp,rbp
    13fe:	pop    rbp
    13ff:	ret

0000000000001400 <botlish_fn_18: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1400:	push   rbp
    1401:	mov    rbp,rsp
    1404:	sub    rsp,0xc0
    140b:	mov    QWORD PTR [rsp+0x90],rbx
    1413:	mov    QWORD PTR [rsp+0x98],r12
    141b:	mov    QWORD PTR [rsp+0xa0],r13
    1423:	mov    QWORD PTR [rsp+0xa8],r14
    142b:	mov    QWORD PTR [rsp+0xb0],r15
    1433:	mov    QWORD PTR [rsp+0x60],rdi
    1438:	mov    QWORD PTR [rsp+0x80],r9
    1440:	mov    r12,QWORD PTR [rbp+0x10]
    1444:	mov    r13,QWORD PTR [rbp+0x18]
    1448:	mov    r14,QWORD PTR [rbp+0x20]
    144c:	mov    rdi,QWORD PTR [rbp+0x28]
    1450:	mov    QWORD PTR [rsp+0x10],rsi
    1455:	mov    QWORD PTR [rsp+0x68],rsi
    145a:	mov    QWORD PTR [rsp+0x18],rdx
    145f:	mov    QWORD PTR [rsp+0x70],rdx
    1464:	mov    QWORD PTR [rsp+0x20],rcx
    1469:	mov    QWORD PTR [rsp+0x78],rcx
    146e:	mov    QWORD PTR [rsp+0x28],r8
    1473:	mov    rax,r12
    1476:	mov    QWORD PTR [rsp+0x30],rax
    147b:	mov    QWORD PTR [rsp+0x38],r13
    1480:	mov    QWORD PTR [rsp+0x40],r14
    1485:	mov    QWORD PTR [rsp+0x48],rdi
    148a:	mov    QWORD PTR [rsp+0x88],rdi
    1492:	mov    rsi,QWORD PTR [rsp+0x80]
    149a:	mov    rax,rsi
    149d:	or     rax,0x1
    14a1:	mov    r15,r8
    14a4:	mov    rcx,r15
    14a7:	and    rcx,rax
    14aa:	test   rcx,0x1
    14b1:	jne    14e8 <botlish_fn_18+0xe8>
    14b7:	mov    rdx,rsi
    14ba:	or     rdx,0x1
    14be:	mov    QWORD PTR [rsp+0x80],rsi
    14c6:	mov    rsi,r15
    14c9:	mov    rdi,QWORD PTR [rsp+0x60]
    14ce:	call   14d3 <botlish_fn_18+0xd3>
			14cf: R_X86_64_PLT32	rt_int_cmp-0x4
    14d3:	mov    ecx,0x2
    14d8:	test   rax,rax
    14db:	cmovge rcx,QWORD PTR [rip+0x2dd]        # 17c0 <botlish_fn_18+0x3c0>
    14e3:	jmp    150a <botlish_fn_18+0x10a>
    14e8:	mov    rdi,rsi
    14eb:	mov    QWORD PTR [rsp+0x80],rsi
    14f3:	mov    rax,rdi
    14f6:	or     rax,0x1
    14fa:	mov    ecx,0x2
    14ff:	cmp    r15,rax
    1502:	cmovge rcx,QWORD PTR [rip+0x2b6]        # 17c0 <botlish_fn_18+0x3c0>
    150a:	cmp    rcx,0x6
    150e:	je     1780 <botlish_fn_18+0x380>
    1514:	xor    eax,eax
    1516:	mov    rsi,QWORD PTR [rsp+0x68]
    151b:	test   rsi,0x7
    1522:	jne    1531 <botlish_fn_18+0x131>
    1528:	movzx  rax,BYTE PTR [rsi]
    152c:	cmp    al,0x8
    152e:	sete   al
    1531:	test   al,al
    1533:	jne    1555 <botlish_fn_18+0x155>
    1539:	mov    rdi,QWORD PTR [rsp+0x60]
    153e:	mov    rax,QWORD PTR [rdi+0x10]
    1542:	mov    rcx,QWORD PTR [rax+0x8]
    1546:	mov    edx,0x8
    154b:	call   1550 <botlish_fn_18+0x150>
			154c: R_X86_64_PLT32	rt_type_error-0x4
    1550:	jmp    16e4 <botlish_fn_18+0x2e4>
    1555:	mov    QWORD PTR [rsp+0x68],rsi
    155a:	mov    rdx,r15
    155d:	mov    rdi,QWORD PTR [rsp+0x60]
    1562:	call   1567 <botlish_fn_18+0x167>
			1563: R_X86_64_PLT32	rt_mutarray_get-0x4
    1567:	test   rax,rax
    156a:	je     16e4 <botlish_fn_18+0x2e4>
    1570:	test   rax,0x1
    1576:	mov    rsi,rax
    1579:	jne    159c <botlish_fn_18+0x19c>
    157f:	mov    edx,0x3
    1584:	mov    rdi,QWORD PTR [rsp+0x60]
    1589:	call   158e <botlish_fn_18+0x18e>
			158a: R_X86_64_PLT32	rt_value_eq-0x4
    158e:	test   rax,rax
    1591:	je     16e4 <botlish_fn_18+0x2e4>
    1597:	jmp    15ad <botlish_fn_18+0x1ad>
    159c:	mov    eax,0x2
    15a1:	cmp    rsi,0x3
    15a5:	cmove  rax,QWORD PTR [rip+0x213]        # 17c0 <botlish_fn_18+0x3c0>
    15ad:	cmp    rax,0x6
    15b1:	je     15c9 <botlish_fn_18+0x1c9>
    15b7:	mov    rbx,QWORD PTR [rsp+0x88]
    15bf:	mov    rsi,QWORD PTR [rsp+0x68]
    15c4:	jmp    1720 <botlish_fn_18+0x320>
    15c9:	xor    eax,eax
    15cb:	mov    rdx,QWORD PTR [rsp+0x70]
    15d0:	test   rdx,0x7
    15d7:	je     15e7 <botlish_fn_18+0x1e7>
    15dd:	mov    QWORD PTR [rsp+0x70],rdx
    15e2:	jmp    15f5 <botlish_fn_18+0x1f5>
    15e7:	movzx  rax,BYTE PTR [rdx]
    15eb:	mov    QWORD PTR [rsp+0x70],rdx
    15f0:	cmp    al,0x8
    15f2:	sete   al
    15f5:	test   al,al
    15f7:	jne    161e <botlish_fn_18+0x21e>
    15fd:	mov    rdi,QWORD PTR [rsp+0x60]
    1602:	mov    rax,QWORD PTR [rdi+0x10]
    1606:	mov    rcx,QWORD PTR [rax+0x8]
    160a:	mov    edx,0x8
    160f:	mov    rsi,QWORD PTR [rsp+0x70]
    1614:	call   1619 <botlish_fn_18+0x219>
			1615: R_X86_64_PLT32	rt_type_error-0x4
    1619:	jmp    16e4 <botlish_fn_18+0x2e4>
    161e:	mov    rdx,r15
    1621:	mov    rsi,QWORD PTR [rsp+0x70]
    1626:	mov    rdi,QWORD PTR [rsp+0x60]
    162b:	call   1630 <botlish_fn_18+0x230>
			162c: R_X86_64_PLT32	rt_mutarray_get-0x4
    1630:	test   rax,rax
    1633:	je     16e4 <botlish_fn_18+0x2e4>
    1639:	mov    QWORD PTR [rsp+0x50],rax
    163e:	mov    rbx,rax
    1641:	xor    eax,eax
    1643:	mov    rcx,QWORD PTR [rsp+0x78]
    1648:	test   rcx,0x7
    164f:	je     165f <botlish_fn_18+0x25f>
    1655:	mov    QWORD PTR [rsp+0x78],rcx
    165a:	jmp    166d <botlish_fn_18+0x26d>
    165f:	movzx  rax,BYTE PTR [rcx]
    1663:	mov    QWORD PTR [rsp+0x78],rcx
    1668:	cmp    al,0x8
    166a:	sete   al
    166d:	test   al,al
    166f:	jne    1696 <botlish_fn_18+0x296>
    1675:	mov    rdi,QWORD PTR [rsp+0x60]
    167a:	mov    rcx,QWORD PTR [rdi+0x10]
    167e:	mov    rcx,QWORD PTR [rcx+0x8]
    1682:	mov    edx,0x8
    1687:	mov    rsi,QWORD PTR [rsp+0x78]
    168c:	call   1691 <botlish_fn_18+0x291>
			168d: R_X86_64_PLT32	rt_type_error-0x4
    1691:	jmp    16e4 <botlish_fn_18+0x2e4>
    1696:	mov    rdx,r15
    1699:	mov    rsi,QWORD PTR [rsp+0x78]
    169e:	mov    rdi,QWORD PTR [rsp+0x60]
    16a3:	call   16a8 <botlish_fn_18+0x2a8>
			16a4: R_X86_64_PLT32	rt_mutarray_get-0x4
    16a8:	test   rax,rax
    16ab:	je     16e4 <botlish_fn_18+0x2e4>
    16b1:	mov    QWORD PTR [rsp+0x58],rax
    16b6:	mov    QWORD PTR [rsp],rax
    16ba:	mov    r9,rbx
    16bd:	mov    rbx,QWORD PTR [rsp+0x88]
    16c5:	mov    rcx,r14
    16c8:	mov    rdx,r13
    16cb:	mov    rsi,r12
    16ce:	mov    rdi,QWORD PTR [rsp+0x60]
    16d3:	mov    r8,rbx
    16d6:	call   16db <botlish_fn_18+0x2db>
			16d7: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    16db:	test   rax,rax
    16de:	jne    171b <botlish_fn_18+0x31b>
    16e4:	xor    rax,rax
    16e7:	mov    rbx,QWORD PTR [rsp+0x90]
    16ef:	mov    r12,QWORD PTR [rsp+0x98]
    16f7:	mov    r13,QWORD PTR [rsp+0xa0]
    16ff:	mov    r14,QWORD PTR [rsp+0xa8]
    1707:	mov    r15,QWORD PTR [rsp+0xb0]
    170f:	add    rsp,0xc0
    1716:	mov    rsp,rbp
    1719:	pop    rbp
    171a:	ret
    171b:	mov    rsi,QWORD PTR [rsp+0x68]
    1720:	mov    rsi,QWORD PTR [rsp+0x68]
    1725:	mov    QWORD PTR [rsp+0x10],rsi
    172a:	mov    rsi,QWORD PTR [rsp+0x70]
    172f:	mov    QWORD PTR [rsp+0x18],rsi
    1734:	mov    rsi,QWORD PTR [rsp+0x78]
    1739:	mov    QWORD PTR [rsp+0x20],rsi
    173e:	sar    r15,1
    1741:	add    r15,0x1
    1748:	shl    r15,1
    174b:	or     r15,0x1
    174f:	mov    QWORD PTR [rsp+0x28],r15
    1754:	mov    QWORD PTR [rsp+0x30],r12
    1759:	mov    QWORD PTR [rsp+0x38],r13
    175e:	mov    QWORD PTR [rsp+0x40],r14
    1763:	mov    QWORD PTR [rsp+0x48],rbx
    1768:	mov    rsi,QWORD PTR [rsp+0x80]
    1770:	mov    r8,r15
    1773:	mov    QWORD PTR [rsp+0x88],rbx
    177b:	jmp    149a <botlish_fn_18+0x9a>
    1780:	mov    eax,0xa
    1785:	mov    rbx,QWORD PTR [rsp+0x90]
    178d:	mov    r12,QWORD PTR [rsp+0x98]
    1795:	mov    r13,QWORD PTR [rsp+0xa0]
    179d:	mov    r14,QWORD PTR [rsp+0xa8]
    17a5:	mov    r15,QWORD PTR [rsp+0xb0]
    17ad:	add    rsp,0xc0
    17b4:	mov    rsp,rbp
    17b7:	pop    rbp
    17b8:	ret
    17b9:	add    BYTE PTR [rax],al
    17bb:	add    BYTE PTR [rax],al
    17bd:	add    BYTE PTR [rax],al
    17bf:	add    BYTE PTR [rsi],al
    17c1:	add    BYTE PTR [rax],al
    17c3:	add    BYTE PTR [rax],al
    17c5:	add    BYTE PTR [rax],al
	...

00000000000017c8 <botlish_entry_18: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    17c8:	push   rbp
    17c9:	mov    rbp,rsp
    17cc:	sub    rsp,0x30
    17d0:	mov    QWORD PTR [rsp+0x20],r12
    17d5:	mov    rsi,QWORD PTR [rdx]
    17d8:	mov    rax,QWORD PTR [rdx+0x8]
    17dc:	mov    rcx,QWORD PTR [rdx+0x10]
    17e0:	mov    r8,QWORD PTR [rdx+0x18]
    17e4:	mov    r9,QWORD PTR [rdx+0x20]
    17e8:	mov    r10,QWORD PTR [rdx+0x28]
    17ec:	mov    r11,QWORD PTR [rdx+0x30]
    17f0:	mov    r12,QWORD PTR [rdx+0x38]
    17f4:	mov    rdx,QWORD PTR [rdx+0x40]
    17f8:	mov    QWORD PTR [rsp],r10
    17fc:	mov    QWORD PTR [rsp+0x8],r11
    1801:	mov    QWORD PTR [rsp+0x10],r12
    1806:	mov    QWORD PTR [rsp+0x18],rdx
    180b:	mov    rdx,rax
    180e:	call   1813 <botlish_entry_18+0x4b>
			180f: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    1813:	mov    r12,QWORD PTR [rsp+0x20]
    1818:	add    rsp,0x30
    181c:	mov    rsp,rbp
    181f:	pop    rbp
    1820:	ret

0000000000001821 <botlish_fn_19: ht_rehash<mutarray, int>>:
    1821:	push   rbp
    1822:	mov    rbp,rsp
    1825:	sub    rsp,0xd0
    182c:	mov    QWORD PTR [rsp+0xa0],rbx
    1834:	mov    QWORD PTR [rsp+0xa8],r12
    183c:	mov    QWORD PTR [rsp+0xb0],r13
    1844:	mov    QWORD PTR [rsp+0xb8],r14
    184c:	mov    QWORD PTR [rsp+0xc0],r15
    1854:	mov    r13,rdi
    1857:	mov    QWORD PTR [rsp+0x50],0x0
    1860:	mov    QWORD PTR [rsp+0x58],0x0
    1869:	mov    QWORD PTR [rsp+0x60],0x0
    1872:	mov    QWORD PTR [rsp+0x68],0x0
    187b:	mov    QWORD PTR [rsp+0x20],rsi
    1880:	mov    r12,rsi
    1883:	mov    QWORD PTR [rsp+0x28],rdx
    1888:	mov    rbx,rdx
    188b:	mov    rsi,r12
    188e:	mov    rdi,r13
    1891:	call   1896 <botlish_fn_19+0x75>
			1892: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    1896:	test   rax,rax
    1899:	je     1a68 <botlish_fn_19+0x247>
    189f:	mov    QWORD PTR [rsp+0x30],rax
    18a4:	mov    r14,rax
    18a7:	mov    rsi,r12
    18aa:	mov    rdi,r13
    18ad:	call   18b2 <botlish_fn_19+0x91>
			18ae: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    18b2:	test   rax,rax
    18b5:	je     1a68 <botlish_fn_19+0x247>
    18bb:	mov    QWORD PTR [rsp+0x38],rax
    18c0:	mov    r15,rax
    18c3:	mov    rsi,r12
    18c6:	mov    rdi,r13
    18c9:	call   18ce <botlish_fn_19+0xad>
			18ca: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    18ce:	test   rax,rax
    18d1:	je     1a68 <botlish_fn_19+0x247>
    18d7:	mov    QWORD PTR [rsp+0x40],rax
    18dc:	mov    QWORD PTR [rsp+0x90],rax
    18e4:	mov    rsi,r12
    18e7:	mov    rdi,r13
    18ea:	call   18ef <botlish_fn_19+0xce>
			18eb: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    18ef:	test   rax,rax
    18f2:	je     1a68 <botlish_fn_19+0x247>
    18f8:	mov    QWORD PTR [rsp+0x48],rax
    18fd:	mov    QWORD PTR [rsp+0x88],rax
    1905:	mov    rsi,rbx
    1908:	mov    rdi,r13
    190b:	call   1910 <botlish_fn_19+0xef>
			190c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1910:	mov    rcx,rax
    1913:	mov    QWORD PTR [rsp+0x80],rax
    191b:	test   rax,rcx
    191e:	je     1a68 <botlish_fn_19+0x247>
    1924:	mov    rax,QWORD PTR [rsp+0x80]
    192c:	mov    QWORD PTR [rsp+0x50],rax
    1931:	mov    edx,0x1
    1936:	mov    QWORD PTR [rsp+0x58],0x1
    193f:	mov    rcx,rbx
    1942:	mov    rsi,QWORD PTR [rsp+0x80]
    194a:	mov    rdi,r13
    194d:	call   1952 <botlish_fn_19+0x131>
			194e: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
    1952:	test   rax,rax
    1955:	je     1a68 <botlish_fn_19+0x247>
    195b:	mov    rsi,rbx
    195e:	mov    rdi,r13
    1961:	call   1966 <botlish_fn_19+0x145>
			1962: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1966:	test   rax,rax
    1969:	je     1a68 <botlish_fn_19+0x247>
    196f:	mov    QWORD PTR [rsp+0x58],rax
    1974:	mov    QWORD PTR [rsp+0x78],rax
    1979:	mov    rsi,rbx
    197c:	mov    rdi,r13
    197f:	call   1984 <botlish_fn_19+0x163>
			1980: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1984:	test   rax,rax
    1987:	je     1a68 <botlish_fn_19+0x247>
    198d:	mov    QWORD PTR [rsp+0x60],rax
    1992:	mov    r8d,0x1
    1998:	mov    QWORD PTR [rsp+0x68],0x1
    19a1:	mov    rcx,QWORD PTR [rsp+0x80]
    19a9:	mov    QWORD PTR [rsp],rcx
    19ad:	mov    rcx,QWORD PTR [rsp+0x78]
    19b2:	mov    QWORD PTR [rsp+0x8],rcx
    19b7:	mov    QWORD PTR [rsp+0x10],rax
    19bc:	mov    QWORD PTR [rsp+0x70],rax
    19c1:	mov    QWORD PTR [rsp+0x18],rbx
    19c6:	mov    rcx,QWORD PTR [rsp+0x90]
    19ce:	mov    rdx,r15
    19d1:	mov    rsi,r14
    19d4:	mov    r9,QWORD PTR [rsp+0x88]
    19dc:	mov    rdi,r13
    19df:	call   19e4 <botlish_fn_19+0x1c3>
			19e0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    19e4:	test   rax,rax
    19e7:	je     1a68 <botlish_fn_19+0x247>
    19ed:	mov    edx,0x1
    19f2:	mov    rcx,QWORD PTR [rsp+0x80]
    19fa:	mov    rsi,r12
    19fd:	mov    rdi,r13
    1a00:	call   1a05 <botlish_fn_19+0x1e4>
			1a01: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a05:	test   rax,rax
    1a08:	je     1a68 <botlish_fn_19+0x247>
    1a0e:	mov    edx,0x3
    1a13:	mov    rcx,QWORD PTR [rsp+0x78]
    1a18:	mov    rsi,r12
    1a1b:	mov    rdi,r13
    1a1e:	call   1a23 <botlish_fn_19+0x202>
			1a1f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a23:	test   rax,rax
    1a26:	je     1a68 <botlish_fn_19+0x247>
    1a2c:	mov    edx,0x5
    1a31:	mov    rcx,QWORD PTR [rsp+0x70]
    1a36:	mov    rsi,r12
    1a39:	mov    rdi,r13
    1a3c:	call   1a41 <botlish_fn_19+0x220>
			1a3d: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a41:	test   rax,rax
    1a44:	je     1a68 <botlish_fn_19+0x247>
    1a4a:	mov    edx,0x9
    1a4f:	mov    ecx,0x1
    1a54:	mov    rsi,r12
    1a57:	mov    rdi,r13
    1a5a:	call   1a5f <botlish_fn_19+0x23e>
			1a5b: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a5f:	test   rax,rax
    1a62:	jne    1a9f <botlish_fn_19+0x27e>
    1a68:	xor    rax,rax
    1a6b:	mov    rbx,QWORD PTR [rsp+0xa0]
    1a73:	mov    r12,QWORD PTR [rsp+0xa8]
    1a7b:	mov    r13,QWORD PTR [rsp+0xb0]
    1a83:	mov    r14,QWORD PTR [rsp+0xb8]
    1a8b:	mov    r15,QWORD PTR [rsp+0xc0]
    1a93:	add    rsp,0xd0
    1a9a:	mov    rsp,rbp
    1a9d:	pop    rbp
    1a9e:	ret
    1a9f:	mov    eax,0xa
    1aa4:	mov    rbx,QWORD PTR [rsp+0xa0]
    1aac:	mov    r12,QWORD PTR [rsp+0xa8]
    1ab4:	mov    r13,QWORD PTR [rsp+0xb0]
    1abc:	mov    r14,QWORD PTR [rsp+0xb8]
    1ac4:	mov    r15,QWORD PTR [rsp+0xc0]
    1acc:	add    rsp,0xd0
    1ad3:	mov    rsp,rbp
    1ad6:	pop    rbp
    1ad7:	ret

0000000000001ad8 <botlish_entry_19: ht_rehash<mutarray, int>>:
    1ad8:	push   rbp
    1ad9:	mov    rbp,rsp
    1adc:	mov    rsi,QWORD PTR [rdx]
    1adf:	mov    rdx,QWORD PTR [rdx+0x8]
    1ae3:	call   1ae8 <botlish_entry_19+0x10>
			1ae4: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1ae8:	mov    rsp,rbp
    1aeb:	pop    rbp
    1aec:	ret
    1aed:	add    BYTE PTR [rax],al
	...

0000000000001af0 <botlish_fn_20: ht_should_grow<mutarray>>:
    1af0:	push   rbp
    1af1:	mov    rbp,rsp
    1af4:	sub    rsp,0x40
    1af8:	mov    QWORD PTR [rsp+0x20],rbx
    1afd:	mov    QWORD PTR [rsp+0x28],r12
    1b02:	mov    QWORD PTR [rsp+0x30],r13
    1b07:	mov    rbx,rdi
    1b0a:	mov    QWORD PTR [rsp],rsi
    1b0e:	mov    r12,rsi
    1b11:	mov    rsi,r12
    1b14:	mov    rdi,rbx
    1b17:	call   1b1c <botlish_fn_20+0x2c>
			1b18: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1b1c:	mov    rcx,rax
    1b1f:	mov    r13,rax
    1b22:	test   rax,rcx
    1b25:	je     1d14 <botlish_fn_20+0x224>
    1b2b:	mov    rax,r13
    1b2e:	mov    QWORD PTR [rsp+0x8],rax
    1b33:	mov    rsi,r12
    1b36:	mov    rdi,rbx
    1b39:	call   1b3e <botlish_fn_20+0x4e>
			1b3a: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1b3e:	mov    rcx,rax
    1b41:	test   rcx,rcx
    1b44:	je     1d14 <botlish_fn_20+0x224>
    1b4a:	mov    QWORD PTR [rsp+0x10],rcx
    1b4f:	mov    edx,0x1
    1b54:	mov    rax,r13
    1b57:	test   rax,0x1
    1b5d:	jne    1b80 <botlish_fn_20+0x90>
    1b63:	xor    edx,edx
    1b65:	mov    rax,r13
    1b68:	test   rax,0x7
    1b6e:	jne    1b80 <botlish_fn_20+0x90>
    1b74:	mov    rax,r13
    1b77:	movzx  rax,BYTE PTR [rax]
    1b7b:	cmp    al,0x1
    1b7d:	sete   dl
    1b80:	test   dl,dl
    1b82:	jne    1ba3 <botlish_fn_20+0xb3>
    1b88:	mov    rdi,rbx
    1b8b:	mov    rax,QWORD PTR [rdi+0x10]
    1b8f:	mov    rcx,QWORD PTR [rax+0x10]
    1b93:	xor    rdx,rdx
    1b96:	mov    rsi,r13
    1b99:	call   1b9e <botlish_fn_20+0xae>
			1b9a: R_X86_64_PLT32	rt_type_error-0x4
    1b9e:	jmp    1d14 <botlish_fn_20+0x224>
    1ba3:	mov    eax,0x1
    1ba8:	test   rcx,0x1
    1baf:	je     1bbd <botlish_fn_20+0xcd>
    1bb5:	mov    r8,rcx
    1bb8:	jmp    1be0 <botlish_fn_20+0xf0>
    1bbd:	xor    eax,eax
    1bbf:	test   rcx,0x7
    1bc6:	je     1bd4 <botlish_fn_20+0xe4>
    1bcc:	mov    r8,rcx
    1bcf:	jmp    1be0 <botlish_fn_20+0xf0>
    1bd4:	movzx  rax,BYTE PTR [rcx]
    1bd8:	mov    r8,rcx
    1bdb:	cmp    al,0x1
    1bdd:	sete   al
    1be0:	test   al,al
    1be2:	jne    1c03 <botlish_fn_20+0x113>
    1be8:	mov    rdi,rbx
    1beb:	mov    rax,QWORD PTR [rdi+0x10]
    1bef:	mov    rcx,QWORD PTR [rax+0x10]
    1bf3:	xor    rdx,rdx
    1bf6:	mov    rsi,r8
    1bf9:	call   1bfe <botlish_fn_20+0x10e>
			1bfa: R_X86_64_PLT32	rt_type_error-0x4
    1bfe:	jmp    1d14 <botlish_fn_20+0x224>
    1c03:	mov    rcx,r8
    1c06:	mov    rsi,r13
    1c09:	mov    rax,rsi
    1c0c:	and    rax,rcx
    1c0f:	test   rax,0x1
    1c15:	jne    1c26 <botlish_fn_20+0x136>
    1c1b:	mov    rdx,r8
    1c1e:	mov    rsi,r13
    1c21:	jmp    1c44 <botlish_fn_20+0x154>
    1c26:	mov    rcx,r8
    1c29:	lea    rax,[rcx-0x1]
    1c2d:	mov    rsi,r13
    1c30:	add    rsi,rax
    1c33:	seto   al
    1c36:	test   al,al
    1c38:	je     1c4f <botlish_fn_20+0x15f>
    1c3e:	mov    rdx,r8
    1c41:	mov    rsi,r13
    1c44:	mov    rdi,rbx
    1c47:	call   1c4c <botlish_fn_20+0x15c>
			1c48: R_X86_64_PLT32	rt_int_add-0x4
    1c4c:	mov    rsi,rax
    1c4f:	mov    QWORD PTR [rsp+0x8],rsi
    1c54:	mov    QWORD PTR [rsp+0x10],0x3
    1c5d:	test   rsi,0x1
    1c64:	je     1c87 <botlish_fn_20+0x197>
    1c6a:	mov    rax,rsi
    1c6d:	add    rax,0x2
    1c71:	mov    rcx,rax
    1c74:	seto   al
    1c77:	test   al,al
    1c79:	jne    1c87 <botlish_fn_20+0x197>
    1c7f:	mov    rsi,rcx
    1c82:	jmp    1c97 <botlish_fn_20+0x1a7>
    1c87:	mov    edx,0x3
    1c8c:	mov    rdi,rbx
    1c8f:	call   1c94 <botlish_fn_20+0x1a4>
			1c90: R_X86_64_PLT32	rt_int_add-0x4
    1c94:	mov    rsi,rax
    1c97:	mov    QWORD PTR [rsp+0x8],rsi
    1c9c:	mov    edx,0x7
    1ca1:	mov    rdi,rdx
    1ca4:	mov    QWORD PTR [rsp+0x10],0x7
    1cad:	test   rsi,0x1
    1cb4:	jne    1cc2 <botlish_fn_20+0x1d2>
    1cba:	mov    rdx,rdi
    1cbd:	jmp    1cee <botlish_fn_20+0x1fe>
    1cc2:	mov    rax,rsi
    1cc5:	sar    rax,1
    1cc8:	imul   QWORD PTR [rip+0x119]        # 1de8 <botlish_fn_20+0x2f8>
    1ccf:	seto   cl
    1cd2:	or     rax,0x1
    1cd6:	test   cl,cl
    1cd8:	je     1ce6 <botlish_fn_20+0x1f6>
    1cde:	mov    rdx,rdi
    1ce1:	jmp    1cee <botlish_fn_20+0x1fe>
    1ce6:	mov    rsi,rax
    1ce9:	jmp    1cf9 <botlish_fn_20+0x209>
    1cee:	mov    rdi,rbx
    1cf1:	call   1cf6 <botlish_fn_20+0x206>
			1cf2: R_X86_64_PLT32	rt_int_mul-0x4
    1cf6:	mov    rsi,rax
    1cf9:	mov    QWORD PTR [rsp],rsi
    1cfd:	mov    r13,rsi
    1d00:	mov    rsi,r12
    1d03:	mov    rdi,rbx
    1d06:	call   1d0b <botlish_fn_20+0x21b>
			1d07: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1d0b:	test   rax,rax
    1d0e:	jne    1d2f <botlish_fn_20+0x23f>
    1d14:	xor    rax,rax
    1d17:	mov    rbx,QWORD PTR [rsp+0x20]
    1d1c:	mov    r12,QWORD PTR [rsp+0x28]
    1d21:	mov    r13,QWORD PTR [rsp+0x30]
    1d26:	add    rsp,0x40
    1d2a:	mov    rsp,rbp
    1d2d:	pop    rbp
    1d2e:	ret
    1d2f:	mov    QWORD PTR [rsp+0x8],rax
    1d34:	mov    QWORD PTR [rsp+0x10],0x5
    1d3d:	test   rax,0x1
    1d43:	mov    rsi,rax
    1d46:	je     1d78 <botlish_fn_20+0x288>
    1d4c:	mov    rcx,rsi
    1d4f:	mov    rax,rcx
    1d52:	sar    rax,1
    1d55:	imul   QWORD PTR [rip+0x94]        # 1df0 <botlish_fn_20+0x300>
    1d5c:	seto   dil
    1d60:	or     rax,0x1
    1d64:	test   dil,dil
    1d67:	jne    1d78 <botlish_fn_20+0x288>
    1d6d:	mov    rdx,rax
    1d70:	mov    rsi,r13
    1d73:	jmp    1d8b <botlish_fn_20+0x29b>
    1d78:	mov    edx,0x5
    1d7d:	mov    rdi,rbx
    1d80:	call   1d85 <botlish_fn_20+0x295>
			1d81: R_X86_64_PLT32	rt_int_mul-0x4
    1d85:	mov    rdx,rax
    1d88:	mov    rsi,r13
    1d8b:	mov    r10,rsi
    1d8e:	and    r10,rdx
    1d91:	test   r10,0x1
    1d98:	jne    1dbf <botlish_fn_20+0x2cf>
    1d9e:	mov    rdi,rbx
    1da1:	call   1da6 <botlish_fn_20+0x2b6>
			1da2: R_X86_64_PLT32	rt_int_cmp-0x4
    1da6:	mov    r8d,0x2
    1dac:	test   rax,rax
    1daf:	mov    rax,r8
    1db2:	cmovg  rax,QWORD PTR [rip+0x2e]        # 1de8 <botlish_fn_20+0x2f8>
    1dba:	jmp    1dcf <botlish_fn_20+0x2df>
    1dbf:	mov    eax,0x2
    1dc4:	cmp    rsi,rdx
    1dc7:	cmovg  rax,QWORD PTR [rip+0x19]        # 1de8 <botlish_fn_20+0x2f8>
    1dcf:	mov    rbx,QWORD PTR [rsp+0x20]
    1dd4:	mov    r12,QWORD PTR [rsp+0x28]
    1dd9:	mov    r13,QWORD PTR [rsp+0x30]
    1dde:	add    rsp,0x40
    1de2:	mov    rsp,rbp
    1de5:	pop    rbp
    1de6:	ret
    1de7:	add    BYTE PTR [rsi],al
    1de9:	add    BYTE PTR [rax],al
    1deb:	add    BYTE PTR [rax],al
    1ded:	add    BYTE PTR [rax],al
    1def:	add    BYTE PTR [rax+rax*1],al
    1df2:	add    BYTE PTR [rax],al
    1df4:	add    BYTE PTR [rax],al
	...

0000000000001df8 <botlish_entry_20: ht_should_grow<mutarray>>:
    1df8:	push   rbp
    1df9:	mov    rbp,rsp
    1dfc:	mov    rsi,QWORD PTR [rdx]
    1dff:	call   1e04 <botlish_entry_20+0xc>
			1e00: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    1e04:	mov    rsp,rbp
    1e07:	pop    rbp
    1e08:	ret
    1e09:	add    BYTE PTR [rax],al
    1e0b:	add    BYTE PTR [rax],al
    1e0d:	add    BYTE PTR [rax],al
	...

0000000000001e10 <botlish_fn_21: ht_grow_or_clean<mutarray>>:
    1e10:	push   rbp
    1e11:	mov    rbp,rsp
    1e14:	sub    rsp,0x40
    1e18:	mov    QWORD PTR [rsp+0x20],rbx
    1e1d:	mov    QWORD PTR [rsp+0x28],r12
    1e22:	mov    QWORD PTR [rsp+0x30],r13
    1e27:	mov    rbx,rdi
    1e2a:	mov    QWORD PTR [rsp+0x10],0x0
    1e33:	mov    QWORD PTR [rsp],rsi
    1e37:	mov    r12,rsi
    1e3a:	mov    rsi,r12
    1e3d:	mov    rdi,rbx
    1e40:	call   1e45 <botlish_fn_21+0x35>
			1e41: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1e45:	test   rax,rax
    1e48:	mov    r13,rax
    1e4b:	je     2038 <botlish_fn_21+0x228>
    1e51:	mov    rsi,r12
    1e54:	mov    rdi,rbx
    1e57:	call   1e5c <botlish_fn_21+0x4c>
			1e58: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1e5c:	mov    rcx,rax
    1e5f:	test   rcx,rcx
    1e62:	je     2038 <botlish_fn_21+0x228>
    1e68:	mov    edx,0x1
    1e6d:	mov    rax,r13
    1e70:	test   rax,0x1
    1e76:	je     1e84 <botlish_fn_21+0x74>
    1e7c:	mov    r13,rax
    1e7f:	jmp    1ea8 <botlish_fn_21+0x98>
    1e84:	xor    edx,edx
    1e86:	test   rax,0x7
    1e8c:	je     1e9a <botlish_fn_21+0x8a>
    1e92:	mov    r13,rax
    1e95:	jmp    1ea8 <botlish_fn_21+0x98>
    1e9a:	movzx  rdx,BYTE PTR [rax]
    1e9e:	mov    r13,rax
    1ea1:	rex cmp dl,0x1
    1ea5:	sete   dl
    1ea8:	test   dl,dl
    1eaa:	jne    1ecb <botlish_fn_21+0xbb>
    1eb0:	mov    rdi,rbx
    1eb3:	mov    rsi,QWORD PTR [rdi+0x10]
    1eb7:	mov    rcx,QWORD PTR [rsi+0x18]
    1ebb:	xor    rdx,rdx
    1ebe:	mov    rsi,r13
    1ec1:	call   1ec6 <botlish_fn_21+0xb6>
			1ec2: R_X86_64_PLT32	rt_type_error-0x4
    1ec6:	jmp    2038 <botlish_fn_21+0x228>
    1ecb:	mov    rsi,r13
    1ece:	mov    eax,0x1
    1ed3:	test   rcx,0x1
    1eda:	je     1ee8 <botlish_fn_21+0xd8>
    1ee0:	mov    r8,rcx
    1ee3:	jmp    1f0d <botlish_fn_21+0xfd>
    1ee8:	xor    eax,eax
    1eea:	test   rcx,0x7
    1ef1:	je     1eff <botlish_fn_21+0xef>
    1ef7:	mov    r8,rcx
    1efa:	jmp    1f0d <botlish_fn_21+0xfd>
    1eff:	movzx  r11,BYTE PTR [rcx]
    1f03:	mov    r8,rcx
    1f06:	cmp    r11b,0x1
    1f0a:	sete   al
    1f0d:	test   al,al
    1f0f:	jne    1f30 <botlish_fn_21+0x120>
    1f15:	mov    rdi,rbx
    1f18:	mov    rax,QWORD PTR [rdi+0x10]
    1f1c:	mov    rcx,QWORD PTR [rax+0x18]
    1f20:	xor    rdx,rdx
    1f23:	mov    rsi,r8
    1f26:	call   1f2b <botlish_fn_21+0x11b>
			1f27: R_X86_64_PLT32	rt_type_error-0x4
    1f2b:	jmp    2038 <botlish_fn_21+0x228>
    1f30:	mov    rcx,r8
    1f33:	mov    rax,rsi
    1f36:	and    rax,rcx
    1f39:	test   rax,0x1
    1f3f:	jne    1f65 <botlish_fn_21+0x155>
    1f45:	mov    rdx,r8
    1f48:	mov    rdi,rbx
    1f4b:	call   1f50 <botlish_fn_21+0x140>
			1f4c: R_X86_64_PLT32	rt_int_cmp-0x4
    1f50:	mov    ecx,0x2
    1f55:	test   rax,rax
    1f58:	cmovg  rcx,QWORD PTR [rip+0x110]        # 2070 <botlish_fn_21+0x260>
    1f60:	jmp    1f78 <botlish_fn_21+0x168>
    1f65:	mov    ecx,0x2
    1f6a:	mov    r9,r8
    1f6d:	cmp    rsi,r9
    1f70:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 2070 <botlish_fn_21+0x260>
    1f78:	cmp    rcx,0x6
    1f7c:	je     2008 <botlish_fn_21+0x1f8>
    1f82:	mov    rsi,r12
    1f85:	mov    rdi,rbx
    1f88:	call   1f8d <botlish_fn_21+0x17d>
			1f89: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1f8d:	test   rax,rax
    1f90:	je     2038 <botlish_fn_21+0x228>
    1f96:	mov    QWORD PTR [rsp+0x8],rax
    1f9b:	mov    QWORD PTR [rsp+0x10],0x5
    1fa4:	test   rax,0x1
    1faa:	mov    rsi,rax
    1fad:	je     1fda <botlish_fn_21+0x1ca>
    1fb3:	mov    rcx,rsi
    1fb6:	mov    rax,rcx
    1fb9:	sar    rax,1
    1fbc:	imul   QWORD PTR [rip+0xb5]        # 2078 <botlish_fn_21+0x268>
    1fc3:	seto   cl
    1fc6:	or     rax,0x1
    1fca:	test   cl,cl
    1fcc:	jne    1fda <botlish_fn_21+0x1ca>
    1fd2:	mov    rdx,rax
    1fd5:	jmp    1fea <botlish_fn_21+0x1da>
    1fda:	mov    edx,0x5
    1fdf:	mov    rdi,rbx
    1fe2:	call   1fe7 <botlish_fn_21+0x1d7>
			1fe3: R_X86_64_PLT32	rt_int_mul-0x4
    1fe7:	mov    rdx,rax
    1fea:	mov    QWORD PTR [rsp+0x8],rdx
    1fef:	mov    rsi,r12
    1ff2:	mov    rdi,rbx
    1ff5:	call   1ffa <botlish_fn_21+0x1ea>
			1ff6: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1ffa:	test   rax,rax
    1ffd:	je     2038 <botlish_fn_21+0x228>
    2003:	jmp    2053 <botlish_fn_21+0x243>
    2008:	mov    rsi,r12
    200b:	mov    rdi,rbx
    200e:	call   2013 <botlish_fn_21+0x203>
			200f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    2013:	test   rax,rax
    2016:	je     2038 <botlish_fn_21+0x228>
    201c:	mov    QWORD PTR [rsp+0x8],rax
    2021:	mov    rdx,rax
    2024:	mov    rsi,r12
    2027:	mov    rdi,rbx
    202a:	call   202f <botlish_fn_21+0x21f>
			202b: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    202f:	test   rax,rax
    2032:	jne    2053 <botlish_fn_21+0x243>
    2038:	xor    rax,rax
    203b:	mov    rbx,QWORD PTR [rsp+0x20]
    2040:	mov    r12,QWORD PTR [rsp+0x28]
    2045:	mov    r13,QWORD PTR [rsp+0x30]
    204a:	add    rsp,0x40
    204e:	mov    rsp,rbp
    2051:	pop    rbp
    2052:	ret
    2053:	mov    rbx,QWORD PTR [rsp+0x20]
    2058:	mov    r12,QWORD PTR [rsp+0x28]
    205d:	mov    r13,QWORD PTR [rsp+0x30]
    2062:	add    rsp,0x40
    2066:	mov    rsp,rbp
    2069:	pop    rbp
    206a:	ret
    206b:	add    BYTE PTR [rax],al
    206d:	add    BYTE PTR [rax],al
    206f:	add    BYTE PTR [rsi],al
    2071:	add    BYTE PTR [rax],al
    2073:	add    BYTE PTR [rax],al
    2075:	add    BYTE PTR [rax],al
    2077:	add    BYTE PTR [rax+rax*1],al
    207a:	add    BYTE PTR [rax],al
    207c:	add    BYTE PTR [rax],al
	...

0000000000002080 <botlish_entry_21: ht_grow_or_clean<mutarray>>:
    2080:	push   rbp
    2081:	mov    rbp,rsp
    2084:	mov    rsi,QWORD PTR [rdx]
    2087:	call   208c <botlish_entry_21+0xc>
			2088: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    208c:	mov    rsp,rbp
    208f:	pop    rbp
    2090:	ret
    2091:	add    BYTE PTR [rax],al
    2093:	add    BYTE PTR [rax],al
    2095:	add    BYTE PTR [rax],al
	...

0000000000002098 <botlish_fn_22: ht_place<mutarray, int, str, str>>:
    2098:	push   rbp
    2099:	mov    rbp,rsp
    209c:	sub    rsp,0x70
    20a0:	mov    QWORD PTR [rsp+0x40],rbx
    20a5:	mov    QWORD PTR [rsp+0x48],r12
    20aa:	mov    QWORD PTR [rsp+0x50],r13
    20af:	mov    QWORD PTR [rsp+0x58],r14
    20b4:	mov    QWORD PTR [rsp+0x60],r15
    20b9:	mov    rbx,rdi
    20bc:	mov    r14,r8
    20bf:	mov    r15,rdx
    20c2:	mov    QWORD PTR [rsp+0x28],rcx
    20c7:	mov    QWORD PTR [rsp],rsi
    20cb:	mov    r12,rsi
    20ce:	mov    rsi,r12
    20d1:	mov    rdi,rbx
    20d4:	call   20d9 <botlish_fn_22+0x41>
			20d5: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    20d9:	test   rax,rax
    20dc:	je     2442 <botlish_fn_22+0x3aa>
    20e2:	xor    ecx,ecx
    20e4:	test   rax,0x7
    20ea:	je     20fa <botlish_fn_22+0x62>
    20f0:	mov    QWORD PTR [rsp+0x30],rax
    20f5:	jmp    210a <botlish_fn_22+0x72>
    20fa:	movzx  rcx,BYTE PTR [rax]
    20fe:	mov    QWORD PTR [rsp+0x30],rax
    2103:	rex cmp cl,0x8
    2107:	sete   cl
    210a:	test   cl,cl
    210c:	jne    2131 <botlish_fn_22+0x99>
    2112:	mov    rdi,rbx
    2115:	mov    rax,QWORD PTR [rdi+0x10]
    2119:	mov    rcx,QWORD PTR [rax+0x8]
    211d:	mov    edx,0x8
    2122:	mov    rsi,QWORD PTR [rsp+0x30]
    2127:	call   212c <botlish_fn_22+0x94>
			2128: R_X86_64_PLT32	rt_type_error-0x4
    212c:	jmp    2442 <botlish_fn_22+0x3aa>
    2131:	mov    rdx,r15
    2134:	mov    rsi,QWORD PTR [rsp+0x30]
    2139:	mov    rdi,rbx
    213c:	call   2141 <botlish_fn_22+0xa9>
			213d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2141:	test   rax,rax
    2144:	je     2442 <botlish_fn_22+0x3aa>
    214a:	mov    QWORD PTR [rsp+0x8],rax
    214f:	mov    r13,rax
    2152:	mov    ecx,0x3
    2157:	mov    rsi,QWORD PTR [rsp+0x30]
    215c:	mov    rdx,r15
    215f:	mov    rdi,rbx
    2162:	call   2167 <botlish_fn_22+0xcf>
			2163: R_X86_64_PLT32	rt_mutarray_set-0x4
    2167:	test   rax,rax
    216a:	je     2442 <botlish_fn_22+0x3aa>
    2170:	mov    rsi,r12
    2173:	mov    rdi,rbx
    2176:	call   217b <botlish_fn_22+0xe3>
			2177: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    217b:	test   rax,rax
    217e:	je     2442 <botlish_fn_22+0x3aa>
    2184:	xor    ecx,ecx
    2186:	test   rax,0x7
    218c:	je     219a <botlish_fn_22+0x102>
    2192:	mov    rsi,rax
    2195:	jmp    21a8 <botlish_fn_22+0x110>
    219a:	movzx  rcx,BYTE PTR [rax]
    219e:	mov    rsi,rax
    21a1:	rex cmp cl,0x8
    21a5:	sete   cl
    21a8:	test   cl,cl
    21aa:	jne    21ca <botlish_fn_22+0x132>
    21b0:	mov    rdi,rbx
    21b3:	mov    rax,QWORD PTR [rdi+0x10]
    21b7:	mov    rcx,QWORD PTR [rax+0x20]
    21bb:	mov    edx,0x8
    21c0:	call   21c5 <botlish_fn_22+0x12d>
			21c1: R_X86_64_PLT32	rt_type_error-0x4
    21c5:	jmp    2442 <botlish_fn_22+0x3aa>
    21ca:	mov    rcx,QWORD PTR [rsp+0x28]
    21cf:	mov    rdx,r15
    21d2:	mov    rdi,rbx
    21d5:	call   21da <botlish_fn_22+0x142>
			21d6: R_X86_64_PLT32	rt_mutarray_set-0x4
    21da:	test   rax,rax
    21dd:	je     2442 <botlish_fn_22+0x3aa>
    21e3:	mov    rsi,r12
    21e6:	mov    rdi,rbx
    21e9:	call   21ee <botlish_fn_22+0x156>
			21ea: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    21ee:	test   rax,rax
    21f1:	je     2442 <botlish_fn_22+0x3aa>
    21f7:	xor    esi,esi
    21f9:	test   rax,0x7
    21ff:	jne    2211 <botlish_fn_22+0x179>
    2205:	movzx  rcx,BYTE PTR [rax]
    2209:	rex cmp cl,0x8
    220d:	sete   sil
    2211:	test   sil,sil
    2214:	jne    2237 <botlish_fn_22+0x19f>
    221a:	mov    rdi,rbx
    221d:	mov    rsi,QWORD PTR [rdi+0x10]
    2221:	mov    rcx,QWORD PTR [rsi+0x20]
    2225:	mov    edx,0x8
    222a:	mov    rsi,rax
    222d:	call   2232 <botlish_fn_22+0x19a>
			222e: R_X86_64_PLT32	rt_type_error-0x4
    2232:	jmp    2442 <botlish_fn_22+0x3aa>
    2237:	mov    rcx,r14
    223a:	mov    rdx,r15
    223d:	mov    rsi,rax
    2240:	mov    rdi,rbx
    2243:	call   2248 <botlish_fn_22+0x1b0>
			2244: R_X86_64_PLT32	rt_mutarray_set-0x4
    2248:	test   rax,rax
    224b:	je     2442 <botlish_fn_22+0x3aa>
    2251:	mov    QWORD PTR [rsp+0x10],0x7
    225a:	mov    rsi,r12
    225d:	mov    rdi,rbx
    2260:	call   2265 <botlish_fn_22+0x1cd>
			2261: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2265:	test   rax,rax
    2268:	je     2442 <botlish_fn_22+0x3aa>
    226e:	mov    QWORD PTR [rsp+0x18],rax
    2273:	mov    QWORD PTR [rsp+0x20],0x3
    227c:	mov    ecx,0x1
    2281:	test   rax,0x1
    2287:	je     2295 <botlish_fn_22+0x1fd>
    228d:	mov    rsi,rax
    2290:	jmp    22b9 <botlish_fn_22+0x221>
    2295:	xor    ecx,ecx
    2297:	test   rax,0x7
    229d:	je     22ab <botlish_fn_22+0x213>
    22a3:	mov    rsi,rax
    22a6:	jmp    22b9 <botlish_fn_22+0x221>
    22ab:	movzx  rcx,BYTE PTR [rax]
    22af:	mov    rsi,rax
    22b2:	rex cmp cl,0x1
    22b6:	sete   cl
    22b9:	test   cl,cl
    22bb:	jne    22d9 <botlish_fn_22+0x241>
    22c1:	mov    rdi,rbx
    22c4:	mov    rax,QWORD PTR [rdi+0x10]
    22c8:	mov    rcx,QWORD PTR [rax+0x10]
    22cc:	xor    rdx,rdx
    22cf:	call   22d4 <botlish_fn_22+0x23c>
			22d0: R_X86_64_PLT32	rt_type_error-0x4
    22d4:	jmp    2442 <botlish_fn_22+0x3aa>
    22d9:	test   rsi,0x1
    22e0:	je     22f8 <botlish_fn_22+0x260>
    22e6:	mov    rcx,rsi
    22e9:	add    rcx,0x2
    22ed:	seto   al
    22f0:	test   al,al
    22f2:	je     2308 <botlish_fn_22+0x270>
    22f8:	mov    edx,0x3
    22fd:	mov    rdi,rbx
    2300:	call   2305 <botlish_fn_22+0x26d>
			2301: R_X86_64_PLT32	rt_int_add-0x4
    2305:	mov    rcx,rax
    2308:	mov    edx,0x7
    230d:	mov    rsi,r12
    2310:	mov    rdi,rbx
    2313:	call   2318 <botlish_fn_22+0x280>
			2314: R_X86_64_PLT32	rt_mutarray_set-0x4
    2318:	test   rax,rax
    231b:	je     2442 <botlish_fn_22+0x3aa>
    2321:	mov    rax,r13
    2324:	test   rax,0x1
    232a:	jne    234e <botlish_fn_22+0x2b6>
    2330:	mov    edx,0x5
    2335:	mov    rsi,r13
    2338:	mov    rdi,rbx
    233b:	call   2340 <botlish_fn_22+0x2a8>
			233c: R_X86_64_PLT32	rt_value_eq-0x4
    2340:	test   rax,rax
    2343:	je     2442 <botlish_fn_22+0x3aa>
    2349:	jmp    2362 <botlish_fn_22+0x2ca>
    234e:	mov    rsi,r13
    2351:	mov    eax,0x2
    2356:	cmp    rsi,0x5
    235a:	cmove  rax,QWORD PTR [rip+0x12e]        # 2490 <botlish_fn_22+0x3f8>
    2362:	cmp    rax,0x6
    2366:	jne    2467 <botlish_fn_22+0x3cf>
    236c:	mov    QWORD PTR [rsp+0x8],0x9
    2375:	mov    rsi,r12
    2378:	mov    rdi,rbx
    237b:	call   2380 <botlish_fn_22+0x2e8>
			237c: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2380:	test   rax,rax
    2383:	je     2442 <botlish_fn_22+0x3aa>
    2389:	mov    QWORD PTR [rsp+0x10],rax
    238e:	mov    QWORD PTR [rsp+0x18],0x3
    2397:	mov    ecx,0x1
    239c:	test   rax,0x1
    23a2:	je     23b0 <botlish_fn_22+0x318>
    23a8:	mov    rsi,rax
    23ab:	jmp    23d4 <botlish_fn_22+0x33c>
    23b0:	xor    ecx,ecx
    23b2:	test   rax,0x7
    23b8:	je     23c6 <botlish_fn_22+0x32e>
    23be:	mov    rsi,rax
    23c1:	jmp    23d4 <botlish_fn_22+0x33c>
    23c6:	movzx  rcx,BYTE PTR [rax]
    23ca:	mov    rsi,rax
    23cd:	rex cmp cl,0x1
    23d1:	sete   cl
    23d4:	test   cl,cl
    23d6:	jne    23f4 <botlish_fn_22+0x35c>
    23dc:	mov    rdi,rbx
    23df:	mov    rcx,QWORD PTR [rdi+0x10]
    23e3:	mov    rcx,QWORD PTR [rcx+0x28]
    23e7:	xor    rdx,rdx
    23ea:	call   23ef <botlish_fn_22+0x357>
			23eb: R_X86_64_PLT32	rt_type_error-0x4
    23ef:	jmp    2442 <botlish_fn_22+0x3aa>
    23f4:	test   rsi,0x1
    23fb:	je     2419 <botlish_fn_22+0x381>
    2401:	mov    r8,rsi
    2404:	sub    r8,0x3
    2408:	seto   dil
    240c:	lea    rcx,[r8+0x1]
    2410:	test   dil,dil
    2413:	je     2429 <botlish_fn_22+0x391>
    2419:	mov    edx,0x3
    241e:	mov    rdi,rbx
    2421:	call   2426 <botlish_fn_22+0x38e>
			2422: R_X86_64_PLT32	rt_int_sub-0x4
    2426:	mov    rcx,rax
    2429:	mov    edx,0x9
    242e:	mov    rsi,r12
    2431:	mov    rdi,rbx
    2434:	call   2439 <botlish_fn_22+0x3a1>
			2435: R_X86_64_PLT32	rt_mutarray_set-0x4
    2439:	test   rax,rax
    243c:	jne    2467 <botlish_fn_22+0x3cf>
    2442:	xor    rax,rax
    2445:	mov    rbx,QWORD PTR [rsp+0x40]
    244a:	mov    r12,QWORD PTR [rsp+0x48]
    244f:	mov    r13,QWORD PTR [rsp+0x50]
    2454:	mov    r14,QWORD PTR [rsp+0x58]
    2459:	mov    r15,QWORD PTR [rsp+0x60]
    245e:	add    rsp,0x70
    2462:	mov    rsp,rbp
    2465:	pop    rbp
    2466:	ret
    2467:	mov    eax,0xa
    246c:	mov    rbx,QWORD PTR [rsp+0x40]
    2471:	mov    r12,QWORD PTR [rsp+0x48]
    2476:	mov    r13,QWORD PTR [rsp+0x50]
    247b:	mov    r14,QWORD PTR [rsp+0x58]
    2480:	mov    r15,QWORD PTR [rsp+0x60]
    2485:	add    rsp,0x70
    2489:	mov    rsp,rbp
    248c:	pop    rbp
    248d:	ret
    248e:	add    BYTE PTR [rax],al
    2490:	(bad)
    2491:	add    BYTE PTR [rax],al
    2493:	add    BYTE PTR [rax],al
    2495:	add    BYTE PTR [rax],al
	...

0000000000002498 <botlish_entry_22: ht_place<mutarray, int, str, str>>:
    2498:	push   rbp
    2499:	mov    rbp,rsp
    249c:	mov    rsi,QWORD PTR [rdx]
    249f:	mov    r9,QWORD PTR [rdx+0x8]
    24a3:	mov    rcx,QWORD PTR [rdx+0x10]
    24a7:	mov    r8,QWORD PTR [rdx+0x18]
    24ab:	mov    rdx,r9
    24ae:	call   24b3 <botlish_entry_22+0x1b>
			24af: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    24b3:	mov    rsp,rbp
    24b6:	pop    rbp
    24b7:	ret

00000000000024b8 <botlish_fn_23: ht_set<mutarray, str, str>>:
    24b8:	push   rbp
    24b9:	mov    rbp,rsp
    24bc:	sub    rsp,0x60
    24c0:	mov    QWORD PTR [rsp+0x30],rbx
    24c5:	mov    QWORD PTR [rsp+0x38],r12
    24ca:	mov    QWORD PTR [rsp+0x40],r13
    24cf:	mov    QWORD PTR [rsp+0x48],r14
    24d4:	mov    QWORD PTR [rsp+0x50],r15
    24d9:	mov    rbx,rdi
    24dc:	mov    r13,rdx
    24df:	mov    QWORD PTR [rsp],rsi
    24e3:	mov    r14,rsi
    24e6:	mov    QWORD PTR [rsp+0x8],rdx
    24eb:	mov    QWORD PTR [rsp+0x10],rcx
    24f0:	mov    r12,rcx
    24f3:	mov    rdx,r13
    24f6:	mov    rsi,r14
    24f9:	mov    rdi,rbx
    24fc:	call   2501 <botlish_fn_23+0x49>
			24fd: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2501:	test   rax,rax
    2504:	je     276f <botlish_fn_23+0x2b7>
    250a:	mov    QWORD PTR [rsp+0x18],rax
    250f:	mov    rcx,rax
    2512:	mov    r8,0xffffffffffffffff
    2519:	mov    QWORD PTR [rsp+0x28],r8
    251e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    2527:	mov    rdx,r13
    252a:	mov    rsi,r14
    252d:	mov    rdi,rbx
    2530:	call   2535 <botlish_fn_23+0x7d>
			2531: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    2535:	mov    rcx,rax
    2538:	mov    r15,rax
    253b:	test   rax,rcx
    253e:	je     276f <botlish_fn_23+0x2b7>
    2544:	mov    rax,r15
    2547:	mov    QWORD PTR [rsp+0x18],rax
    254c:	mov    rsi,r14
    254f:	mov    rdi,rbx
    2552:	call   2557 <botlish_fn_23+0x9f>
			2553: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    2557:	test   rax,rax
    255a:	je     276f <botlish_fn_23+0x2b7>
    2560:	xor    ecx,ecx
    2562:	test   rax,0x7
    2568:	je     2576 <botlish_fn_23+0xbe>
    256e:	mov    r8,rax
    2571:	jmp    2584 <botlish_fn_23+0xcc>
    2576:	movzx  rcx,BYTE PTR [rax]
    257a:	mov    r8,rax
    257d:	rex cmp cl,0x8
    2581:	sete   cl
    2584:	test   cl,cl
    2586:	jne    25a9 <botlish_fn_23+0xf1>
    258c:	mov    rdi,rbx
    258f:	mov    rsi,QWORD PTR [rdi+0x10]
    2593:	mov    rcx,QWORD PTR [rsi+0x8]
    2597:	mov    edx,0x8
    259c:	mov    rsi,r8
    259f:	call   25a4 <botlish_fn_23+0xec>
			25a0: R_X86_64_PLT32	rt_type_error-0x4
    25a4:	jmp    276f <botlish_fn_23+0x2b7>
    25a9:	mov    rsi,r8
    25ac:	mov    rdx,r15
    25af:	mov    rdi,rbx
    25b2:	call   25b7 <botlish_fn_23+0xff>
			25b3: R_X86_64_PLT32	rt_mutarray_get-0x4
    25b7:	test   rax,rax
    25ba:	je     276f <botlish_fn_23+0x2b7>
    25c0:	test   rax,0x1
    25c6:	mov    rsi,rax
    25c9:	jne    25ea <botlish_fn_23+0x132>
    25cf:	mov    edx,0x3
    25d4:	mov    rdi,rbx
    25d7:	call   25dc <botlish_fn_23+0x124>
			25d8: R_X86_64_PLT32	rt_value_eq-0x4
    25dc:	test   rax,rax
    25df:	je     276f <botlish_fn_23+0x2b7>
    25e5:	jmp    25fb <botlish_fn_23+0x143>
    25ea:	mov    eax,0x2
    25ef:	cmp    rsi,0x3
    25f3:	cmove  rax,QWORD PTR [rip+0x1c5]        # 27c0 <botlish_fn_23+0x308>
    25fb:	cmp    rax,0x6
    25ff:	je     26fe <botlish_fn_23+0x246>
    2605:	mov    rsi,r14
    2608:	mov    rdi,rbx
    260b:	call   2610 <botlish_fn_23+0x158>
			260c: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    2610:	test   rax,rax
    2613:	je     276f <botlish_fn_23+0x2b7>
    2619:	cmp    rax,0x6
    261d:	je     2662 <botlish_fn_23+0x1aa>
    2623:	mov    rcx,r13
    2626:	mov    rdx,r15
    2629:	mov    rsi,r14
    262c:	mov    rdi,rbx
    262f:	mov    r8,r12
    2632:	call   2637 <botlish_fn_23+0x17f>
			2633: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    2637:	test   rax,rax
    263a:	je     276f <botlish_fn_23+0x2b7>
    2640:	mov    rbx,QWORD PTR [rsp+0x30]
    2645:	mov    r12,QWORD PTR [rsp+0x38]
    264a:	mov    r13,QWORD PTR [rsp+0x40]
    264f:	mov    r14,QWORD PTR [rsp+0x48]
    2654:	mov    r15,QWORD PTR [rsp+0x50]
    2659:	add    rsp,0x60
    265d:	mov    rsp,rbp
    2660:	pop    rbp
    2661:	ret
    2662:	mov    rsi,r14
    2665:	mov    rdi,rbx
    2668:	call   266d <botlish_fn_23+0x1b5>
			2669: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    266d:	test   rax,rax
    2670:	je     276f <botlish_fn_23+0x2b7>
    2676:	mov    rdx,r13
    2679:	mov    rsi,r14
    267c:	mov    rdi,rbx
    267f:	call   2684 <botlish_fn_23+0x1cc>
			2680: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2684:	test   rax,rax
    2687:	je     276f <botlish_fn_23+0x2b7>
    268d:	mov    QWORD PTR [rsp+0x18],rax
    2692:	mov    rcx,rax
    2695:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    269e:	mov    r8,QWORD PTR [rsp+0x28]
    26a3:	mov    rdx,r13
    26a6:	mov    rsi,r14
    26a9:	mov    rdi,rbx
    26ac:	call   26b1 <botlish_fn_23+0x1f9>
			26ad: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    26b1:	test   rax,rax
    26b4:	je     276f <botlish_fn_23+0x2b7>
    26ba:	mov    QWORD PTR [rsp+0x18],rax
    26bf:	mov    rcx,r13
    26c2:	mov    rdx,rax
    26c5:	mov    rsi,r14
    26c8:	mov    rdi,rbx
    26cb:	mov    r8,r12
    26ce:	call   26d3 <botlish_fn_23+0x21b>
			26cf: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    26d3:	test   rax,rax
    26d6:	je     276f <botlish_fn_23+0x2b7>
    26dc:	mov    rbx,QWORD PTR [rsp+0x30]
    26e1:	mov    r12,QWORD PTR [rsp+0x38]
    26e6:	mov    r13,QWORD PTR [rsp+0x40]
    26eb:	mov    r14,QWORD PTR [rsp+0x48]
    26f0:	mov    r15,QWORD PTR [rsp+0x50]
    26f5:	add    rsp,0x60
    26f9:	mov    rsp,rbp
    26fc:	pop    rbp
    26fd:	ret
    26fe:	mov    rsi,r14
    2701:	mov    rdi,rbx
    2704:	call   2709 <botlish_fn_23+0x251>
			2705: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    2709:	test   rax,rax
    270c:	je     276f <botlish_fn_23+0x2b7>
    2712:	xor    ecx,ecx
    2714:	test   rax,0x7
    271a:	je     2728 <botlish_fn_23+0x270>
    2720:	mov    rsi,rax
    2723:	jmp    2736 <botlish_fn_23+0x27e>
    2728:	movzx  rcx,BYTE PTR [rax]
    272c:	mov    rsi,rax
    272f:	rex cmp cl,0x8
    2733:	sete   cl
    2736:	test   cl,cl
    2738:	jne    2758 <botlish_fn_23+0x2a0>
    273e:	mov    rdi,rbx
    2741:	mov    rax,QWORD PTR [rdi+0x10]
    2745:	mov    rcx,QWORD PTR [rax+0x20]
    2749:	mov    edx,0x8
    274e:	call   2753 <botlish_fn_23+0x29b>
			274f: R_X86_64_PLT32	rt_type_error-0x4
    2753:	jmp    276f <botlish_fn_23+0x2b7>
    2758:	mov    rcx,r12
    275b:	mov    rdx,r15
    275e:	mov    rdi,rbx
    2761:	call   2766 <botlish_fn_23+0x2ae>
			2762: R_X86_64_PLT32	rt_mutarray_set-0x4
    2766:	test   rax,rax
    2769:	jne    2794 <botlish_fn_23+0x2dc>
    276f:	xor    rax,rax
    2772:	mov    rbx,QWORD PTR [rsp+0x30]
    2777:	mov    r12,QWORD PTR [rsp+0x38]
    277c:	mov    r13,QWORD PTR [rsp+0x40]
    2781:	mov    r14,QWORD PTR [rsp+0x48]
    2786:	mov    r15,QWORD PTR [rsp+0x50]
    278b:	add    rsp,0x60
    278f:	mov    rsp,rbp
    2792:	pop    rbp
    2793:	ret
    2794:	mov    eax,0xa
    2799:	mov    rbx,QWORD PTR [rsp+0x30]
    279e:	mov    r12,QWORD PTR [rsp+0x38]
    27a3:	mov    r13,QWORD PTR [rsp+0x40]
    27a8:	mov    r14,QWORD PTR [rsp+0x48]
    27ad:	mov    r15,QWORD PTR [rsp+0x50]
    27b2:	add    rsp,0x60
    27b6:	mov    rsp,rbp
    27b9:	pop    rbp
    27ba:	ret
    27bb:	add    BYTE PTR [rax],al
    27bd:	add    BYTE PTR [rax],al
    27bf:	add    BYTE PTR [rsi],al
    27c1:	add    BYTE PTR [rax],al
    27c3:	add    BYTE PTR [rax],al
    27c5:	add    BYTE PTR [rax],al
	...

00000000000027c8 <botlish_entry_23: ht_set<mutarray, str, str>>:
    27c8:	push   rbp
    27c9:	mov    rbp,rsp
    27cc:	mov    rsi,QWORD PTR [rdx]
    27cf:	mov    r8,QWORD PTR [rdx+0x8]
    27d3:	mov    rcx,QWORD PTR [rdx+0x10]
    27d7:	mov    rdx,r8
    27da:	call   27df <botlish_entry_23+0x17>
			27db: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    27df:	mov    rsp,rbp
    27e2:	pop    rbp
    27e3:	ret
    27e4:	add    BYTE PTR [rax],al
	...

00000000000027e8 <botlish_fn_24: ht_delete<mutarray, str>>:
    27e8:	push   rbp
    27e9:	mov    rbp,rsp
    27ec:	sub    rsp,0x40
    27f0:	mov    QWORD PTR [rsp+0x20],rbx
    27f5:	mov    QWORD PTR [rsp+0x28],r12
    27fa:	mov    QWORD PTR [rsp+0x30],r13
    27ff:	mov    rbx,rdi
    2802:	mov    QWORD PTR [rsp+0x18],0x0
    280b:	mov    QWORD PTR [rsp],rsi
    280f:	mov    r12,rsi
    2812:	mov    QWORD PTR [rsp+0x8],rdx
    2817:	mov    r13,rdx
    281a:	mov    rdx,r13
    281d:	mov    rsi,r12
    2820:	mov    rdi,rbx
    2823:	call   2828 <botlish_fn_24+0x40>
			2824: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2828:	test   rax,rax
    282b:	je     2b98 <botlish_fn_24+0x3b0>
    2831:	mov    QWORD PTR [rsp+0x10],rax
    2836:	mov    rcx,rax
    2839:	mov    rdx,r13
    283c:	mov    rsi,r12
    283f:	mov    rdi,rbx
    2842:	call   2847 <botlish_fn_24+0x5f>
			2843: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    2847:	mov    rcx,rax
    284a:	mov    r13,rax
    284d:	test   rax,rcx
    2850:	je     2b98 <botlish_fn_24+0x3b0>
    2856:	mov    rax,r13
    2859:	test   rax,0x1
    285f:	jne    288a <botlish_fn_24+0xa2>
    2865:	mov    edx,0x1
    286a:	mov    rsi,r13
    286d:	mov    rdi,rbx
    2870:	call   2875 <botlish_fn_24+0x8d>
			2871: R_X86_64_PLT32	rt_int_cmp-0x4
    2875:	mov    ecx,0x2
    287a:	test   rax,rax
    287d:	cmovl  rcx,QWORD PTR [rip+0x36b]        # 2bf0 <botlish_fn_24+0x408>
    2885:	jmp    28a0 <botlish_fn_24+0xb8>
    288a:	mov    ecx,0x2
    288f:	mov    rax,r13
    2892:	mov    rdx,r13
    2895:	test   rax,rdx
    2898:	cmovle rcx,QWORD PTR [rip+0x350]        # 2bf0 <botlish_fn_24+0x408>
    28a0:	cmp    rcx,0x6
    28a4:	je     2bd0 <botlish_fn_24+0x3e8>
    28aa:	mov    rsi,r12
    28ad:	mov    rdi,rbx
    28b0:	call   28b5 <botlish_fn_24+0xcd>
			28b1: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    28b5:	test   rax,rax
    28b8:	je     2b98 <botlish_fn_24+0x3b0>
    28be:	xor    ecx,ecx
    28c0:	test   rax,0x7
    28c6:	je     28d4 <botlish_fn_24+0xec>
    28cc:	mov    rsi,rax
    28cf:	jmp    28e2 <botlish_fn_24+0xfa>
    28d4:	movzx  rcx,BYTE PTR [rax]
    28d8:	mov    rsi,rax
    28db:	rex cmp cl,0x8
    28df:	sete   cl
    28e2:	test   cl,cl
    28e4:	jne    2904 <botlish_fn_24+0x11c>
    28ea:	mov    rdi,rbx
    28ed:	mov    rax,QWORD PTR [rdi+0x10]
    28f1:	mov    rcx,QWORD PTR [rax+0x20]
    28f5:	mov    edx,0x8
    28fa:	call   28ff <botlish_fn_24+0x117>
			28fb: R_X86_64_PLT32	rt_type_error-0x4
    28ff:	jmp    2b98 <botlish_fn_24+0x3b0>
    2904:	mov    ecx,0x5
    2909:	mov    rdx,r13
    290c:	mov    rdi,rbx
    290f:	call   2914 <botlish_fn_24+0x12c>
			2910: R_X86_64_PLT32	rt_mutarray_set-0x4
    2914:	test   rax,rax
    2917:	je     2b98 <botlish_fn_24+0x3b0>
    291d:	mov    rsi,r12
    2920:	mov    rdi,rbx
    2923:	call   2928 <botlish_fn_24+0x140>
			2924: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    2928:	test   rax,rax
    292b:	je     2b98 <botlish_fn_24+0x3b0>
    2931:	xor    ecx,ecx
    2933:	test   rax,0x7
    2939:	jne    294a <botlish_fn_24+0x162>
    293f:	movzx  rsi,BYTE PTR [rax]
    2943:	cmp    sil,0x8
    2947:	sete   cl
    294a:	test   cl,cl
    294c:	jne    296f <botlish_fn_24+0x187>
    2952:	mov    rdi,rbx
    2955:	mov    r9,QWORD PTR [rdi+0x10]
    2959:	mov    rcx,QWORD PTR [r9+0x20]
    295d:	mov    edx,0x8
    2962:	mov    rsi,rax
    2965:	call   296a <botlish_fn_24+0x182>
			2966: R_X86_64_PLT32	rt_type_error-0x4
    296a:	jmp    2b98 <botlish_fn_24+0x3b0>
    296f:	mov    rsi,rax
    2972:	mov    ecx,0xa
    2977:	mov    rdx,r13
    297a:	mov    rdi,rbx
    297d:	call   2982 <botlish_fn_24+0x19a>
			297e: R_X86_64_PLT32	rt_mutarray_set-0x4
    2982:	test   rax,rax
    2985:	je     2b98 <botlish_fn_24+0x3b0>
    298b:	mov    rsi,r12
    298e:	mov    rdi,rbx
    2991:	call   2996 <botlish_fn_24+0x1ae>
			2992: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    2996:	test   rax,rax
    2999:	je     2b98 <botlish_fn_24+0x3b0>
    299f:	xor    ecx,ecx
    29a1:	test   rax,0x7
    29a7:	je     29b5 <botlish_fn_24+0x1cd>
    29ad:	mov    rsi,rax
    29b0:	jmp    29c3 <botlish_fn_24+0x1db>
    29b5:	movzx  rcx,BYTE PTR [rax]
    29b9:	mov    rsi,rax
    29bc:	rex cmp cl,0x8
    29c0:	sete   cl
    29c3:	test   cl,cl
    29c5:	jne    29e5 <botlish_fn_24+0x1fd>
    29cb:	mov    rdi,rbx
    29ce:	mov    rax,QWORD PTR [rdi+0x10]
    29d2:	mov    rcx,QWORD PTR [rax+0x20]
    29d6:	mov    edx,0x8
    29db:	call   29e0 <botlish_fn_24+0x1f8>
			29dc: R_X86_64_PLT32	rt_type_error-0x4
    29e0:	jmp    2b98 <botlish_fn_24+0x3b0>
    29e5:	mov    ecx,0xa
    29ea:	mov    rdx,r13
    29ed:	mov    rdi,rbx
    29f0:	call   29f5 <botlish_fn_24+0x20d>
			29f1: R_X86_64_PLT32	rt_mutarray_set-0x4
    29f5:	test   rax,rax
    29f8:	je     2b98 <botlish_fn_24+0x3b0>
    29fe:	mov    QWORD PTR [rsp+0x8],0x7
    2a07:	mov    rsi,r12
    2a0a:	mov    rdi,rbx
    2a0d:	call   2a12 <botlish_fn_24+0x22a>
			2a0e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2a12:	test   rax,rax
    2a15:	je     2b98 <botlish_fn_24+0x3b0>
    2a1b:	mov    QWORD PTR [rsp+0x10],rax
    2a20:	mov    QWORD PTR [rsp+0x18],0x3
    2a29:	mov    ecx,0x1
    2a2e:	test   rax,0x1
    2a34:	je     2a42 <botlish_fn_24+0x25a>
    2a3a:	mov    rsi,rax
    2a3d:	jmp    2a66 <botlish_fn_24+0x27e>
    2a42:	xor    ecx,ecx
    2a44:	test   rax,0x7
    2a4a:	je     2a58 <botlish_fn_24+0x270>
    2a50:	mov    rsi,rax
    2a53:	jmp    2a66 <botlish_fn_24+0x27e>
    2a58:	movzx  rcx,BYTE PTR [rax]
    2a5c:	mov    rsi,rax
    2a5f:	rex cmp cl,0x1
    2a63:	sete   cl
    2a66:	test   cl,cl
    2a68:	jne    2a86 <botlish_fn_24+0x29e>
    2a6e:	mov    rdi,rbx
    2a71:	mov    rax,QWORD PTR [rdi+0x10]
    2a75:	mov    rcx,QWORD PTR [rax+0x28]
    2a79:	xor    rdx,rdx
    2a7c:	call   2a81 <botlish_fn_24+0x299>
			2a7d: R_X86_64_PLT32	rt_type_error-0x4
    2a81:	jmp    2b98 <botlish_fn_24+0x3b0>
    2a86:	test   rsi,0x1
    2a8d:	je     2aac <botlish_fn_24+0x2c4>
    2a93:	mov    rcx,rsi
    2a96:	sub    rcx,0x3
    2a9a:	seto   al
    2a9d:	add    rcx,0x1
    2aa4:	test   al,al
    2aa6:	je     2abc <botlish_fn_24+0x2d4>
    2aac:	mov    edx,0x3
    2ab1:	mov    rdi,rbx
    2ab4:	call   2ab9 <botlish_fn_24+0x2d1>
			2ab5: R_X86_64_PLT32	rt_int_sub-0x4
    2ab9:	mov    rcx,rax
    2abc:	mov    edx,0x7
    2ac1:	mov    rsi,r12
    2ac4:	mov    rdi,rbx
    2ac7:	call   2acc <botlish_fn_24+0x2e4>
			2ac8: R_X86_64_PLT32	rt_mutarray_set-0x4
    2acc:	test   rax,rax
    2acf:	je     2b98 <botlish_fn_24+0x3b0>
    2ad5:	mov    QWORD PTR [rsp+0x8],0x9
    2ade:	mov    rsi,r12
    2ae1:	mov    rdi,rbx
    2ae4:	call   2ae9 <botlish_fn_24+0x301>
			2ae5: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2ae9:	test   rax,rax
    2aec:	je     2b98 <botlish_fn_24+0x3b0>
    2af2:	mov    QWORD PTR [rsp+0x10],rax
    2af7:	mov    QWORD PTR [rsp+0x18],0x3
    2b00:	mov    ecx,0x1
    2b05:	test   rax,0x1
    2b0b:	jne    2b2a <botlish_fn_24+0x342>
    2b11:	xor    ecx,ecx
    2b13:	test   rax,0x7
    2b19:	jne    2b2a <botlish_fn_24+0x342>
    2b1f:	movzx  rsi,BYTE PTR [rax]
    2b23:	cmp    sil,0x1
    2b27:	sete   cl
    2b2a:	test   cl,cl
    2b2c:	jne    2b4d <botlish_fn_24+0x365>
    2b32:	mov    rdi,rbx
    2b35:	mov    r8,QWORD PTR [rdi+0x10]
    2b39:	mov    rcx,QWORD PTR [r8+0x10]
    2b3d:	xor    rdx,rdx
    2b40:	mov    rsi,rax
    2b43:	call   2b48 <botlish_fn_24+0x360>
			2b44: R_X86_64_PLT32	rt_type_error-0x4
    2b48:	jmp    2b98 <botlish_fn_24+0x3b0>
    2b4d:	mov    rsi,rax
    2b50:	test   rsi,0x1
    2b57:	je     2b6f <botlish_fn_24+0x387>
    2b5d:	mov    rcx,rsi
    2b60:	add    rcx,0x2
    2b64:	seto   al
    2b67:	test   al,al
    2b69:	je     2b7f <botlish_fn_24+0x397>
    2b6f:	mov    edx,0x3
    2b74:	mov    rdi,rbx
    2b77:	call   2b7c <botlish_fn_24+0x394>
			2b78: R_X86_64_PLT32	rt_int_add-0x4
    2b7c:	mov    rcx,rax
    2b7f:	mov    edx,0x9
    2b84:	mov    rsi,r12
    2b87:	mov    rdi,rbx
    2b8a:	call   2b8f <botlish_fn_24+0x3a7>
			2b8b: R_X86_64_PLT32	rt_mutarray_set-0x4
    2b8f:	test   rax,rax
    2b92:	jne    2bb3 <botlish_fn_24+0x3cb>
    2b98:	xor    rax,rax
    2b9b:	mov    rbx,QWORD PTR [rsp+0x20]
    2ba0:	mov    r12,QWORD PTR [rsp+0x28]
    2ba5:	mov    r13,QWORD PTR [rsp+0x30]
    2baa:	add    rsp,0x40
    2bae:	mov    rsp,rbp
    2bb1:	pop    rbp
    2bb2:	ret
    2bb3:	mov    eax,0xa
    2bb8:	mov    rbx,QWORD PTR [rsp+0x20]
    2bbd:	mov    r12,QWORD PTR [rsp+0x28]
    2bc2:	mov    r13,QWORD PTR [rsp+0x30]
    2bc7:	add    rsp,0x40
    2bcb:	mov    rsp,rbp
    2bce:	pop    rbp
    2bcf:	ret
    2bd0:	mov    eax,0xa
    2bd5:	mov    rbx,QWORD PTR [rsp+0x20]
    2bda:	mov    r12,QWORD PTR [rsp+0x28]
    2bdf:	mov    r13,QWORD PTR [rsp+0x30]
    2be4:	add    rsp,0x40
    2be8:	mov    rsp,rbp
    2beb:	pop    rbp
    2bec:	ret
    2bed:	add    BYTE PTR [rax],al
    2bef:	add    BYTE PTR [rsi],al
    2bf1:	add    BYTE PTR [rax],al
    2bf3:	add    BYTE PTR [rax],al
    2bf5:	add    BYTE PTR [rax],al
	...

0000000000002bf8 <botlish_entry_24: ht_delete<mutarray, str>>:
    2bf8:	push   rbp
    2bf9:	mov    rbp,rsp
    2bfc:	mov    rsi,QWORD PTR [rdx]
    2bff:	mov    rdx,QWORD PTR [rdx+0x8]
    2c03:	call   2c08 <botlish_entry_24+0x10>
			2c04: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2c08:	mov    rsp,rbp
    2c0b:	pop    rbp
    2c0c:	ret
    2c0d:	add    BYTE PTR [rax],al
	...

0000000000002c10 <botlish_fn_25: sample<generic>>:
    2c10:	push   rbp
    2c11:	mov    rbp,rsp
    2c14:	sub    rsp,0xa0
    2c1b:	mov    QWORD PTR [rsp+0x70],rbx
    2c20:	mov    QWORD PTR [rsp+0x78],r12
    2c25:	mov    QWORD PTR [rsp+0x80],r13
    2c2d:	mov    QWORD PTR [rsp+0x88],r14
    2c35:	mov    QWORD PTR [rsp+0x90],r15
    2c3d:	mov    r14,rdi
    2c40:	mov    QWORD PTR [rsp],0x0
    2c48:	mov    QWORD PTR [rsp+0x8],0x0
    2c51:	mov    QWORD PTR [rsp+0x10],0x0
    2c5a:	mov    QWORD PTR [rsp+0x18],0x0
    2c63:	mov    QWORD PTR [rsp+0x20],0x0
    2c6c:	mov    QWORD PTR [rsp+0x28],0x0
    2c75:	mov    rdi,r14
    2c78:	call   2c7d <botlish_fn_25+0x6d>
			2c79: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    2c7d:	mov    rcx,rax
    2c80:	mov    r15,rax
    2c83:	test   rax,rcx
    2c86:	je     2ec6 <botlish_fn_25+0x2b6>
    2c8c:	mov    rax,r15
    2c8f:	mov    QWORD PTR [rsp],rax
    2c93:	mov    rdi,r14
    2c96:	mov    rax,QWORD PTR [rdi+0x10]
    2c9a:	mov    rdx,QWORD PTR [rax+0x30]
    2c9e:	mov    QWORD PTR [rsp+0x8],rdx
    2ca3:	mov    rax,QWORD PTR [rdi+0x10]
    2ca7:	mov    rcx,QWORD PTR [rax+0x38]
    2cab:	mov    QWORD PTR [rsp+0x10],rcx
    2cb0:	mov    rsi,r15
    2cb3:	call   2cb8 <botlish_fn_25+0xa8>
			2cb4: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2cb8:	test   rax,rax
    2cbb:	je     2ec6 <botlish_fn_25+0x2b6>
    2cc1:	mov    rdi,r14
    2cc4:	mov    rsi,QWORD PTR [rdi+0x10]
    2cc8:	mov    rdx,QWORD PTR [rsi+0x40]
    2ccc:	mov    QWORD PTR [rsp+0x8],rdx
    2cd1:	mov    rsi,QWORD PTR [rdi+0x10]
    2cd5:	mov    rcx,QWORD PTR [rsi+0x48]
    2cd9:	mov    QWORD PTR [rsp+0x10],rcx
    2cde:	mov    rsi,r15
    2ce1:	call   2ce6 <botlish_fn_25+0xd6>
			2ce2: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2ce6:	test   rax,rax
    2ce9:	je     2ec6 <botlish_fn_25+0x2b6>
    2cef:	mov    rdi,r14
    2cf2:	mov    r9,QWORD PTR [rdi+0x10]
    2cf6:	mov    rdx,QWORD PTR [r9+0x30]
    2cfa:	mov    QWORD PTR [rsp+0x8],rdx
    2cff:	mov    r10,QWORD PTR [rdi+0x10]
    2d03:	mov    rcx,QWORD PTR [r10+0x50]
    2d07:	mov    QWORD PTR [rsp+0x10],rcx
    2d0c:	mov    rsi,r15
    2d0f:	call   2d14 <botlish_fn_25+0x104>
			2d10: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2d14:	test   rax,rax
    2d17:	je     2ec6 <botlish_fn_25+0x2b6>
    2d1d:	mov    rdi,r14
    2d20:	mov    rax,QWORD PTR [rdi+0x10]
    2d24:	mov    rdx,QWORD PTR [rax+0x40]
    2d28:	mov    QWORD PTR [rsp+0x8],rdx
    2d2d:	mov    rsi,r15
    2d30:	call   2d35 <botlish_fn_25+0x125>
			2d31: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2d35:	mov    rbx,rax
    2d38:	test   rbx,rbx
    2d3b:	je     2ec6 <botlish_fn_25+0x2b6>
    2d41:	mov    QWORD PTR [rsp+0x8],rbx
    2d46:	mov    rdi,r14
    2d49:	mov    rax,QWORD PTR [rdi+0x10]
    2d4d:	mov    rdx,QWORD PTR [rax+0x40]
    2d51:	mov    QWORD PTR [rsp+0x10],rdx
    2d56:	mov    rsi,r15
    2d59:	call   2d5e <botlish_fn_25+0x14e>
			2d5a: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2d5e:	test   rax,rax
    2d61:	je     2ec6 <botlish_fn_25+0x2b6>
    2d67:	mov    rdi,r14
    2d6a:	mov    rax,QWORD PTR [rdi+0x10]
    2d6e:	mov    rdx,QWORD PTR [rax+0x30]
    2d72:	mov    QWORD PTR [rsp+0x10],rdx
    2d77:	mov    rsi,r15
    2d7a:	call   2d7f <botlish_fn_25+0x16f>
			2d7b: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2d7f:	test   rax,rax
    2d82:	je     2ec6 <botlish_fn_25+0x2b6>
    2d88:	mov    rdi,r14
    2d8b:	mov    rcx,QWORD PTR [rdi+0x10]
    2d8f:	mov    rdx,QWORD PTR [rcx+0x50]
    2d93:	mov    rcx,rax
    2d96:	and    rcx,rdx
    2d99:	mov    rsi,rax
    2d9c:	test   rcx,0x1
    2da3:	jne    2dbf <botlish_fn_25+0x1af>
    2da9:	mov    rdi,r14
    2dac:	call   2db1 <botlish_fn_25+0x1a1>
			2dad: R_X86_64_PLT32	rt_value_eq-0x4
    2db1:	test   rax,rax
    2db4:	je     2ec6 <botlish_fn_25+0x2b6>
    2dba:	jmp    2dcf <botlish_fn_25+0x1bf>
    2dbf:	mov    eax,0x2
    2dc4:	cmp    rsi,rdx
    2dc7:	cmove  rax,QWORD PTR [rip+0x159]        # 2f28 <botlish_fn_25+0x318>
    2dcf:	mov    QWORD PTR [rsp+0x10],rax
    2dd4:	mov    rdi,r14
    2dd7:	mov    QWORD PTR [rsp+0x60],rax
    2ddc:	mov    rax,QWORD PTR [rdi+0x10]
    2de0:	mov    rdx,QWORD PTR [rax+0x40]
    2de4:	mov    QWORD PTR [rsp+0x18],rdx
    2de9:	mov    rsi,r15
    2dec:	call   2df1 <botlish_fn_25+0x1e1>
			2ded: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2df1:	mov    r12,rax
    2df4:	test   r12,r12
    2df7:	je     2ec6 <botlish_fn_25+0x2b6>
    2dfd:	mov    QWORD PTR [rsp+0x18],r12
    2e02:	mov    rdi,r14
    2e05:	mov    rax,QWORD PTR [rdi+0x10]
    2e09:	mov    rdx,QWORD PTR [rax+0x58]
    2e0d:	mov    QWORD PTR [rsp+0x20],rdx
    2e12:	mov    rsi,r15
    2e15:	call   2e1a <botlish_fn_25+0x20a>
			2e16: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2e1a:	mov    r13,rax
    2e1d:	test   r13,r13
    2e20:	je     2ec6 <botlish_fn_25+0x2b6>
    2e26:	mov    QWORD PTR [rsp+0x20],r13
    2e2b:	mov    rdi,r14
    2e2e:	mov    rax,QWORD PTR [rdi+0x10]
    2e32:	mov    rdx,QWORD PTR [rax+0x58]
    2e36:	mov    QWORD PTR [rsp+0x28],rdx
    2e3b:	mov    rsi,r15
    2e3e:	call   2e43 <botlish_fn_25+0x233>
			2e3f: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2e43:	test   rax,rax
    2e46:	mov    rsi,rax
    2e49:	je     2ec6 <botlish_fn_25+0x2b6>
    2e4f:	mov    edx,0xa
    2e54:	mov    rdi,r14
    2e57:	call   2e5c <botlish_fn_25+0x24c>
			2e58: R_X86_64_PLT32	rt_value_eq-0x4
    2e5c:	test   rax,rax
    2e5f:	je     2ec6 <botlish_fn_25+0x2b6>
    2e65:	mov    QWORD PTR [rsp],rax
    2e69:	mov    rsi,r15
    2e6c:	mov    r15,rax
    2e6f:	mov    rdi,r14
    2e72:	call   2e77 <botlish_fn_25+0x267>
			2e73: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2e77:	test   rax,rax
    2e7a:	je     2ec6 <botlish_fn_25+0x2b6>
    2e80:	mov    QWORD PTR [rsp+0x28],rax
    2e85:	lea    rdx,[rsp+0x30]
    2e8a:	mov    rsi,QWORD PTR [rsp+0x60]
    2e8f:	mov    QWORD PTR [rsp+0x30],rsi
    2e94:	mov    QWORD PTR [rsp+0x38],rbx
    2e99:	mov    QWORD PTR [rsp+0x40],r12
    2e9e:	mov    QWORD PTR [rsp+0x48],r13
    2ea3:	mov    r8,r15
    2ea6:	mov    QWORD PTR [rsp+0x50],r8
    2eab:	mov    QWORD PTR [rsp+0x58],rax
    2eb0:	mov    esi,0x6
    2eb5:	mov    rdi,r14
    2eb8:	call   2ebd <botlish_fn_25+0x2ad>
			2eb9: R_X86_64_PLT32	rt_list_new-0x4
    2ebd:	test   rax,rax
    2ec0:	jne    2ef7 <botlish_fn_25+0x2e7>
    2ec6:	xor    rax,rax
    2ec9:	mov    rbx,QWORD PTR [rsp+0x70]
    2ece:	mov    r12,QWORD PTR [rsp+0x78]
    2ed3:	mov    r13,QWORD PTR [rsp+0x80]
    2edb:	mov    r14,QWORD PTR [rsp+0x88]
    2ee3:	mov    r15,QWORD PTR [rsp+0x90]
    2eeb:	add    rsp,0xa0
    2ef2:	mov    rsp,rbp
    2ef5:	pop    rbp
    2ef6:	ret
    2ef7:	mov    rbx,QWORD PTR [rsp+0x70]
    2efc:	mov    r12,QWORD PTR [rsp+0x78]
    2f01:	mov    r13,QWORD PTR [rsp+0x80]
    2f09:	mov    r14,QWORD PTR [rsp+0x88]
    2f11:	mov    r15,QWORD PTR [rsp+0x90]
    2f19:	add    rsp,0xa0
    2f20:	mov    rsp,rbp
    2f23:	pop    rbp
    2f24:	ret
    2f25:	add    BYTE PTR [rax],al
    2f27:	add    BYTE PTR [rsi],al
    2f29:	add    BYTE PTR [rax],al
    2f2b:	add    BYTE PTR [rax],al
    2f2d:	add    BYTE PTR [rax],al
	...

0000000000002f30 <botlish_entry_25: sample<generic>>:
    2f30:	push   rbp
    2f31:	mov    rbp,rsp
    2f34:	call   2f39 <botlish_entry_25+0x9>
			2f35: R_X86_64_PLT32	botlish_fn_25-0x4 ; sample<generic>
    2f39:	mov    rsp,rbp
    2f3c:	pop    rbp
    2f3d:	ret

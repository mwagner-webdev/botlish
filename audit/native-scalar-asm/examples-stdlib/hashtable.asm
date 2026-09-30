; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12477  (per function: 45 388 524 70 61 61 61 61 61 167 179 245 804 1248 429 253 380 401 724 802 817 665 1168 836 1189 838)
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
;   botlish_fn_17 / botlish_entry_17 -> ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
;   botlish_fn_18 / botlish_entry_18 -> ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
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

000000000000126c <botlish_fn_17: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    126c:	push   rbp
    126d:	mov    rbp,rsp
    1270:	sub    rsp,0x70
    1274:	mov    QWORD PTR [rsp+0x40],rbx
    1279:	mov    QWORD PTR [rsp+0x48],r12
    127e:	mov    QWORD PTR [rsp+0x50],r13
    1283:	mov    QWORD PTR [rsp+0x58],r14
    1288:	mov    QWORD PTR [rsp+0x60],r15
    128d:	mov    r13,rdi
    1290:	mov    QWORD PTR [rsp],rsi
    1294:	mov    QWORD PTR [rsp+0x8],rdx
    1299:	mov    r15,rdx
    129c:	mov    QWORD PTR [rsp+0x10],rcx
    12a1:	mov    r14,rcx
    12a4:	mov    QWORD PTR [rsp+0x18],r8
    12a9:	mov    r12,r8
    12ac:	mov    rax,QWORD PTR [rsi+0x18]
    12b0:	mov    rbx,rsi
    12b3:	mov    rsi,QWORD PTR [rax]
    12b6:	mov    QWORD PTR [rsp+0x20],rsi
    12bb:	mov    QWORD PTR [rsp+0x30],rsi
    12c0:	mov    rsi,r14
    12c3:	mov    rdi,r13
    12c6:	call   12cb <botlish_fn_17+0x5f>
			12c7: R_X86_64_PLT32	rt_hash-0x4
    12cb:	test   rax,rax
    12ce:	mov    rsi,rax
    12d1:	je     136e <botlish_fn_17+0x102>
    12d7:	mov    rdx,r15
    12da:	mov    rdi,r13
    12dd:	call   12e2 <botlish_fn_17+0x76>
			12de: R_X86_64_PLT32	rt_int_mod-0x4
    12e2:	test   rax,rax
    12e5:	je     136e <botlish_fn_17+0x102>
    12eb:	mov    QWORD PTR [rsp+0x28],rax
    12f0:	mov    rcx,r15
    12f3:	mov    rdx,rax
    12f6:	mov    rsi,QWORD PTR [rsp+0x30]
    12fb:	mov    rdi,r13
    12fe:	call   1303 <botlish_fn_17+0x97>
			12ff: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash_probe<mutarray, int, int>
    1303:	mov    rcx,rax
    1306:	mov    r15,rax
    1309:	test   rax,rcx
    130c:	je     136e <botlish_fn_17+0x102>
    1312:	mov    ecx,0x3
    1317:	mov    rsi,QWORD PTR [rsp+0x30]
    131c:	mov    rdx,r15
    131f:	mov    rdi,r13
    1322:	call   1327 <botlish_fn_17+0xbb>
			1323: R_X86_64_PLT32	rt_mutarray_set-0x4
    1327:	test   rax,rax
    132a:	je     136e <botlish_fn_17+0x102>
    1330:	mov    rax,QWORD PTR [rbx+0x18]
    1334:	mov    rsi,QWORD PTR [rax+0x8]
    1338:	mov    rcx,r14
    133b:	mov    rdx,r15
    133e:	mov    rdi,r13
    1341:	call   1346 <botlish_fn_17+0xda>
			1342: R_X86_64_PLT32	rt_mutarray_set-0x4
    1346:	test   rax,rax
    1349:	je     136e <botlish_fn_17+0x102>
    134f:	mov    rax,QWORD PTR [rbx+0x18]
    1353:	mov    rsi,QWORD PTR [rax+0x10]
    1357:	mov    rcx,r12
    135a:	mov    rdx,r15
    135d:	mov    rdi,r13
    1360:	call   1365 <botlish_fn_17+0xf9>
			1361: R_X86_64_PLT32	rt_mutarray_set-0x4
    1365:	test   rax,rax
    1368:	jne    1393 <botlish_fn_17+0x127>
    136e:	xor    rax,rax
    1371:	mov    rbx,QWORD PTR [rsp+0x40]
    1376:	mov    r12,QWORD PTR [rsp+0x48]
    137b:	mov    r13,QWORD PTR [rsp+0x50]
    1380:	mov    r14,QWORD PTR [rsp+0x58]
    1385:	mov    r15,QWORD PTR [rsp+0x60]
    138a:	add    rsp,0x70
    138e:	mov    rsp,rbp
    1391:	pop    rbp
    1392:	ret
    1393:	mov    eax,0xa
    1398:	mov    rbx,QWORD PTR [rsp+0x40]
    139d:	mov    r12,QWORD PTR [rsp+0x48]
    13a2:	mov    r13,QWORD PTR [rsp+0x50]
    13a7:	mov    r14,QWORD PTR [rsp+0x58]
    13ac:	mov    r15,QWORD PTR [rsp+0x60]
    13b1:	add    rsp,0x70
    13b5:	mov    rsp,rbp
    13b8:	pop    rbp
    13b9:	ret

00000000000013ba <botlish_entry_17: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    13ba:	push   rbp
    13bb:	mov    rbp,rsp
    13be:	mov    rsi,QWORD PTR [rdx]
    13c1:	mov    r9,QWORD PTR [rdx+0x8]
    13c5:	mov    rcx,QWORD PTR [rdx+0x10]
    13c9:	mov    r8,QWORD PTR [rdx+0x18]
    13cd:	mov    rdx,r9
    13d0:	call   13d5 <botlish_entry_17+0x1b>
			13d1: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    13d5:	mov    rsp,rbp
    13d8:	pop    rbp
    13d9:	ret
    13da:	add    BYTE PTR [rax],al
    13dc:	add    BYTE PTR [rax],al
	...

00000000000013e0 <botlish_fn_18: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    13e0:	push   rbp
    13e1:	mov    rbp,rsp
    13e4:	sub    rsp,0x70
    13e8:	mov    QWORD PTR [rsp+0x40],rbx
    13ed:	mov    QWORD PTR [rsp+0x48],r12
    13f2:	mov    QWORD PTR [rsp+0x50],r13
    13f7:	mov    QWORD PTR [rsp+0x58],r14
    13fc:	mov    QWORD PTR [rsp+0x60],r15
    1401:	mov    QWORD PTR [rsp+0x28],rdi
    1406:	mov    QWORD PTR [rsp],rsi
    140a:	mov    QWORD PTR [rsp+0x8],r8
    140f:	mov    r13,r8
    1412:	mov    QWORD PTR [rsp+0x10],r9
    1417:	mov    r12,r9
    141a:	sar    rdx,1
    141d:	sar    rcx,1
    1420:	mov    rbx,rcx
    1423:	mov    r15,rdx
    1426:	cmp    r15,rbx
    1429:	jge    162a <botlish_fn_18+0x24a>
    142f:	mov    r14,rsi
    1432:	mov    rcx,QWORD PTR [r14+0x18]
    1436:	mov    rsi,QWORD PTR [rcx]
    1439:	xor    eax,eax
    143b:	test   rsi,0x7
    1442:	jne    1453 <botlish_fn_18+0x73>
    1448:	movzx  rdi,BYTE PTR [rsi]
    144c:	cmp    dil,0x8
    1450:	sete   al
    1453:	test   al,al
    1455:	jne    1477 <botlish_fn_18+0x97>
    145b:	mov    rdi,QWORD PTR [rsp+0x28]
    1460:	mov    r8,QWORD PTR [rdi+0x10]
    1464:	mov    rcx,QWORD PTR [r8+0x8]
    1468:	mov    edx,0x8
    146d:	call   1472 <botlish_fn_18+0x92>
			146e: R_X86_64_PLT32	rt_type_error-0x4
    1472:	jmp    15df <botlish_fn_18+0x1ff>
    1477:	mov    rdx,r15
    147a:	shl    rdx,1
    147d:	or     rdx,0x1
    1481:	mov    QWORD PTR [rsp+0x38],rdx
    1486:	mov    rdi,QWORD PTR [rsp+0x28]
    148b:	call   1490 <botlish_fn_18+0xb0>
			148c: R_X86_64_PLT32	rt_mutarray_get-0x4
    1490:	test   rax,rax
    1493:	je     15df <botlish_fn_18+0x1ff>
    1499:	test   rax,0x1
    149f:	mov    rsi,rax
    14a2:	jne    14c5 <botlish_fn_18+0xe5>
    14a8:	mov    edx,0x3
    14ad:	mov    rdi,QWORD PTR [rsp+0x28]
    14b2:	call   14b7 <botlish_fn_18+0xd7>
			14b3: R_X86_64_PLT32	rt_value_eq-0x4
    14b7:	test   rax,rax
    14ba:	je     15df <botlish_fn_18+0x1ff>
    14c0:	jmp    14d6 <botlish_fn_18+0xf6>
    14c5:	mov    eax,0x2
    14ca:	cmp    rsi,0x3
    14ce:	cmove  rax,QWORD PTR [rip+0x182]        # 1658 <botlish_fn_18+0x278>
    14d6:	cmp    rax,0x6
    14da:	je     14ee <botlish_fn_18+0x10e>
    14e0:	mov    rax,r12
    14e3:	mov    r12,r13
    14e6:	mov    r13,rax
    14e9:	jmp    1604 <botlish_fn_18+0x224>
    14ee:	mov    rax,QWORD PTR [r14+0x18]
    14f2:	mov    rsi,QWORD PTR [rax+0x8]
    14f6:	xor    eax,eax
    14f8:	test   rsi,0x7
    14ff:	jne    150e <botlish_fn_18+0x12e>
    1505:	movzx  rax,BYTE PTR [rsi]
    1509:	cmp    al,0x8
    150b:	sete   al
    150e:	test   al,al
    1510:	jne    1532 <botlish_fn_18+0x152>
    1516:	mov    rdi,QWORD PTR [rsp+0x28]
    151b:	mov    rax,QWORD PTR [rdi+0x10]
    151f:	mov    rcx,QWORD PTR [rax+0x8]
    1523:	mov    edx,0x8
    1528:	call   152d <botlish_fn_18+0x14d>
			1529: R_X86_64_PLT32	rt_type_error-0x4
    152d:	jmp    15df <botlish_fn_18+0x1ff>
    1532:	mov    rdx,QWORD PTR [rsp+0x38]
    1537:	mov    rdi,QWORD PTR [rsp+0x28]
    153c:	call   1541 <botlish_fn_18+0x161>
			153d: R_X86_64_PLT32	rt_mutarray_get-0x4
    1541:	test   rax,rax
    1544:	je     15df <botlish_fn_18+0x1ff>
    154a:	mov    QWORD PTR [rsp+0x18],rax
    154f:	mov    QWORD PTR [rsp+0x30],rax
    1554:	mov    rax,QWORD PTR [r14+0x18]
    1558:	mov    rsi,QWORD PTR [rax+0x10]
    155c:	xor    eax,eax
    155e:	test   rsi,0x7
    1565:	jne    1574 <botlish_fn_18+0x194>
    156b:	movzx  rax,BYTE PTR [rsi]
    156f:	cmp    al,0x8
    1571:	sete   al
    1574:	test   al,al
    1576:	jne    1598 <botlish_fn_18+0x1b8>
    157c:	mov    rdi,QWORD PTR [rsp+0x28]
    1581:	mov    rax,QWORD PTR [rdi+0x10]
    1585:	mov    rcx,QWORD PTR [rax+0x8]
    1589:	mov    edx,0x8
    158e:	call   1593 <botlish_fn_18+0x1b3>
			158f: R_X86_64_PLT32	rt_type_error-0x4
    1593:	jmp    15df <botlish_fn_18+0x1ff>
    1598:	mov    rdx,QWORD PTR [rsp+0x38]
    159d:	mov    rdi,QWORD PTR [rsp+0x28]
    15a2:	call   15a7 <botlish_fn_18+0x1c7>
			15a3: R_X86_64_PLT32	rt_mutarray_get-0x4
    15a7:	test   rax,rax
    15aa:	je     15df <botlish_fn_18+0x1ff>
    15b0:	mov    QWORD PTR [rsp+0x20],rax
    15b5:	mov    r9,r12
    15b8:	mov    r12,r13
    15bb:	mov    r13,r9
    15be:	mov    r8,rax
    15c1:	mov    rcx,QWORD PTR [rsp+0x30]
    15c6:	mov    rdx,r13
    15c9:	mov    rsi,r12
    15cc:	mov    rdi,QWORD PTR [rsp+0x28]
    15d1:	call   15d6 <botlish_fn_18+0x1f6>
			15d2: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    15d6:	test   rax,rax
    15d9:	jne    1604 <botlish_fn_18+0x224>
    15df:	xor    rax,rax
    15e2:	mov    rbx,QWORD PTR [rsp+0x40]
    15e7:	mov    r12,QWORD PTR [rsp+0x48]
    15ec:	mov    r13,QWORD PTR [rsp+0x50]
    15f1:	mov    r14,QWORD PTR [rsp+0x58]
    15f6:	mov    r15,QWORD PTR [rsp+0x60]
    15fb:	add    rsp,0x70
    15ff:	mov    rsp,rbp
    1602:	pop    rbp
    1603:	ret
    1604:	mov    QWORD PTR [rsp],r14
    1608:	mov    QWORD PTR [rsp+0x8],r12
    160d:	mov    QWORD PTR [rsp+0x10],r13
    1612:	add    r15,0x1
    1619:	mov    rax,r12
    161c:	mov    r12,r13
    161f:	mov    r13,rax
    1622:	mov    rsi,r14
    1625:	jmp    1426 <botlish_fn_18+0x46>
    162a:	mov    eax,0xa
    162f:	mov    rbx,QWORD PTR [rsp+0x40]
    1634:	mov    r12,QWORD PTR [rsp+0x48]
    1639:	mov    r13,QWORD PTR [rsp+0x50]
    163e:	mov    r14,QWORD PTR [rsp+0x58]
    1643:	mov    r15,QWORD PTR [rsp+0x60]
    1648:	add    rsp,0x70
    164c:	mov    rsp,rbp
    164f:	pop    rbp
    1650:	ret
    1651:	add    BYTE PTR [rax],al
    1653:	add    BYTE PTR [rax],al
    1655:	add    BYTE PTR [rax],al
    1657:	add    BYTE PTR [rsi],al
    1659:	add    BYTE PTR [rax],al
    165b:	add    BYTE PTR [rax],al
    165d:	add    BYTE PTR [rax],al
	...

0000000000001660 <botlish_entry_18: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    1660:	push   rbp
    1661:	mov    rbp,rsp
    1664:	mov    rsi,QWORD PTR [rdx]
    1667:	mov    r10,QWORD PTR [rdx+0x8]
    166b:	mov    rcx,QWORD PTR [rdx+0x10]
    166f:	mov    r8,QWORD PTR [rdx+0x18]
    1673:	mov    r9,QWORD PTR [rdx+0x20]
    1677:	mov    rdx,r10
    167a:	call   167f <botlish_entry_18+0x1f>
			167b: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    167f:	mov    rsp,rbp
    1682:	pop    rbp
    1683:	ret

0000000000001684 <botlish_fn_19: ht_rehash<mutarray, int>>:
    1684:	push   rbp
    1685:	mov    rbp,rsp
    1688:	sub    rsp,0xb0
    168f:	mov    QWORD PTR [rsp+0x80],rbx
    1697:	mov    QWORD PTR [rsp+0x88],r12
    169f:	mov    QWORD PTR [rsp+0x90],r13
    16a7:	mov    QWORD PTR [rsp+0x98],r14
    16af:	mov    QWORD PTR [rsp+0xa0],r15
    16b7:	mov    r13,rdi
    16ba:	mov    QWORD PTR [rsp+0x28],0x0
    16c3:	mov    QWORD PTR [rsp+0x30],0x0
    16cc:	mov    QWORD PTR [rsp],rsi
    16d0:	mov    rbx,rsi
    16d3:	mov    QWORD PTR [rsp+0x8],rdx
    16d8:	mov    r12,rdx
    16db:	mov    rsi,rbx
    16de:	mov    rdi,r13
    16e1:	call   16e6 <botlish_fn_19+0x62>
			16e2: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    16e6:	test   rax,rax
    16e9:	je     18e3 <botlish_fn_19+0x25f>
    16ef:	mov    QWORD PTR [rsp+0x10],rax
    16f4:	mov    r14,rax
    16f7:	mov    rsi,rbx
    16fa:	mov    rdi,r13
    16fd:	call   1702 <botlish_fn_19+0x7e>
			16fe: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    1702:	test   rax,rax
    1705:	je     18e3 <botlish_fn_19+0x25f>
    170b:	mov    QWORD PTR [rsp+0x18],rax
    1710:	mov    r15,rax
    1713:	mov    rsi,rbx
    1716:	mov    rdi,r13
    1719:	call   171e <botlish_fn_19+0x9a>
			171a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    171e:	test   rax,rax
    1721:	je     18e3 <botlish_fn_19+0x25f>
    1727:	mov    QWORD PTR [rsp+0x20],rax
    172c:	lea    rcx,[rsp+0x38]
    1731:	mov    rdx,r14
    1734:	mov    QWORD PTR [rsp+0x38],rdx
    1739:	mov    rdx,r15
    173c:	mov    QWORD PTR [rsp+0x40],rdx
    1741:	mov    QWORD PTR [rsp+0x48],rax
    1746:	xor    rsi,rsi
    1749:	mov    edx,0x3
    174e:	mov    rdi,r13
    1751:	call   1756 <botlish_fn_19+0xd2>
			1752: R_X86_64_PLT32	rt_struct_new-0x4
    1756:	mov    QWORD PTR [rsp+0x10],rax
    175b:	mov    r14,rax
    175e:	mov    rsi,rbx
    1761:	mov    rdi,r13
    1764:	call   1769 <botlish_fn_19+0xe5>
			1765: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1769:	test   rax,rax
    176c:	je     18e3 <botlish_fn_19+0x25f>
    1772:	mov    QWORD PTR [rsp+0x18],rax
    1777:	mov    r15,rax
    177a:	mov    rsi,r12
    177d:	mov    rdi,r13
    1780:	call   1785 <botlish_fn_19+0x101>
			1781: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1785:	test   rax,rax
    1788:	je     18e3 <botlish_fn_19+0x25f>
    178e:	mov    QWORD PTR [rsp+0x20],rax
    1793:	mov    QWORD PTR [rsp+0x70],rax
    1798:	mov    edx,0x1
    179d:	mov    QWORD PTR [rsp+0x28],0x1
    17a6:	mov    rcx,r12
    17a9:	mov    rsi,QWORD PTR [rsp+0x70]
    17ae:	mov    rdi,r13
    17b1:	call   17b6 <botlish_fn_19+0x132>
			17b2: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
    17b6:	test   rax,rax
    17b9:	je     18e3 <botlish_fn_19+0x25f>
    17bf:	mov    rsi,r12
    17c2:	mov    rdi,r13
    17c5:	call   17ca <botlish_fn_19+0x146>
			17c6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    17ca:	test   rax,rax
    17cd:	je     18e3 <botlish_fn_19+0x25f>
    17d3:	mov    QWORD PTR [rsp+0x28],rax
    17d8:	mov    QWORD PTR [rsp+0x68],rax
    17dd:	mov    rsi,r12
    17e0:	mov    rdi,r13
    17e3:	call   17e8 <botlish_fn_19+0x164>
			17e4: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    17e8:	test   rax,rax
    17eb:	je     18e3 <botlish_fn_19+0x25f>
    17f1:	mov    QWORD PTR [rsp+0x30],rax
    17f6:	lea    rcx,[rsp+0x50]
    17fb:	mov    rdx,QWORD PTR [rsp+0x70]
    1800:	mov    QWORD PTR [rsp+0x50],rdx
    1805:	mov    rdx,QWORD PTR [rsp+0x68]
    180a:	mov    QWORD PTR [rsp+0x58],rdx
    180f:	mov    QWORD PTR [rsp+0x60],rax
    1814:	xor    rsi,rsi
    1817:	mov    edx,0x3
    181c:	mov    rdi,r13
    181f:	call   1824 <botlish_fn_19+0x1a0>
			1820: R_X86_64_PLT32	rt_struct_new-0x4
    1824:	mov    QWORD PTR [rsp+0x20],rax
    1829:	mov    QWORD PTR [rsp+0x68],rax
    182e:	mov    edx,0x1
    1833:	mov    QWORD PTR [rsp+0x28],0x1
    183c:	mov    rcx,r15
    183f:	mov    rsi,r14
    1842:	mov    r9,r12
    1845:	mov    rdi,r13
    1848:	mov    r8,QWORD PTR [rsp+0x68]
    184d:	call   1852 <botlish_fn_19+0x1ce>
			184e: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    1852:	test   rax,rax
    1855:	je     18e3 <botlish_fn_19+0x25f>
    185b:	mov    r12,QWORD PTR [rsp+0x68]
    1860:	mov    rcx,QWORD PTR [r12+0x18]
    1865:	mov    rcx,QWORD PTR [rcx]
    1868:	mov    edx,0x1
    186d:	mov    rsi,rbx
    1870:	mov    rdi,r13
    1873:	call   1878 <botlish_fn_19+0x1f4>
			1874: R_X86_64_PLT32	rt_mutarray_set-0x4
    1878:	test   rax,rax
    187b:	je     18e3 <botlish_fn_19+0x25f>
    1881:	mov    rax,QWORD PTR [r12+0x18]
    1886:	mov    rcx,QWORD PTR [rax+0x8]
    188a:	mov    edx,0x3
    188f:	mov    rsi,rbx
    1892:	mov    rdi,r13
    1895:	call   189a <botlish_fn_19+0x216>
			1896: R_X86_64_PLT32	rt_mutarray_set-0x4
    189a:	test   rax,rax
    189d:	je     18e3 <botlish_fn_19+0x25f>
    18a3:	mov    rax,QWORD PTR [r12+0x18]
    18a8:	mov    rcx,QWORD PTR [rax+0x10]
    18ac:	mov    edx,0x5
    18b1:	mov    rsi,rbx
    18b4:	mov    rdi,r13
    18b7:	call   18bc <botlish_fn_19+0x238>
			18b8: R_X86_64_PLT32	rt_mutarray_set-0x4
    18bc:	test   rax,rax
    18bf:	je     18e3 <botlish_fn_19+0x25f>
    18c5:	mov    edx,0x9
    18ca:	mov    ecx,0x1
    18cf:	mov    rsi,rbx
    18d2:	mov    rdi,r13
    18d5:	call   18da <botlish_fn_19+0x256>
			18d6: R_X86_64_PLT32	rt_mutarray_set-0x4
    18da:	test   rax,rax
    18dd:	jne    191a <botlish_fn_19+0x296>
    18e3:	xor    rax,rax
    18e6:	mov    rbx,QWORD PTR [rsp+0x80]
    18ee:	mov    r12,QWORD PTR [rsp+0x88]
    18f6:	mov    r13,QWORD PTR [rsp+0x90]
    18fe:	mov    r14,QWORD PTR [rsp+0x98]
    1906:	mov    r15,QWORD PTR [rsp+0xa0]
    190e:	add    rsp,0xb0
    1915:	mov    rsp,rbp
    1918:	pop    rbp
    1919:	ret
    191a:	mov    eax,0xa
    191f:	mov    rbx,QWORD PTR [rsp+0x80]
    1927:	mov    r12,QWORD PTR [rsp+0x88]
    192f:	mov    r13,QWORD PTR [rsp+0x90]
    1937:	mov    r14,QWORD PTR [rsp+0x98]
    193f:	mov    r15,QWORD PTR [rsp+0xa0]
    1947:	add    rsp,0xb0
    194e:	mov    rsp,rbp
    1951:	pop    rbp
    1952:	ret

0000000000001953 <botlish_entry_19: ht_rehash<mutarray, int>>:
    1953:	push   rbp
    1954:	mov    rbp,rsp
    1957:	mov    rsi,QWORD PTR [rdx]
    195a:	mov    rdx,QWORD PTR [rdx+0x8]
    195e:	call   1963 <botlish_entry_19+0x10>
			195f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1963:	mov    rsp,rbp
    1966:	pop    rbp
    1967:	ret

0000000000001968 <botlish_fn_20: ht_should_grow<mutarray>>:
    1968:	push   rbp
    1969:	mov    rbp,rsp
    196c:	sub    rsp,0x40
    1970:	mov    QWORD PTR [rsp+0x20],rbx
    1975:	mov    QWORD PTR [rsp+0x28],r12
    197a:	mov    QWORD PTR [rsp+0x30],r13
    197f:	mov    rbx,rdi
    1982:	mov    QWORD PTR [rsp],rsi
    1986:	mov    r12,rsi
    1989:	mov    rsi,r12
    198c:	mov    rdi,rbx
    198f:	call   1994 <botlish_fn_20+0x2c>
			1990: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1994:	mov    rcx,rax
    1997:	mov    r13,rax
    199a:	test   rax,rcx
    199d:	je     1b8c <botlish_fn_20+0x224>
    19a3:	mov    rax,r13
    19a6:	mov    QWORD PTR [rsp+0x8],rax
    19ab:	mov    rsi,r12
    19ae:	mov    rdi,rbx
    19b1:	call   19b6 <botlish_fn_20+0x4e>
			19b2: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    19b6:	mov    rcx,rax
    19b9:	test   rcx,rcx
    19bc:	je     1b8c <botlish_fn_20+0x224>
    19c2:	mov    QWORD PTR [rsp+0x10],rcx
    19c7:	mov    edx,0x1
    19cc:	mov    rax,r13
    19cf:	test   rax,0x1
    19d5:	jne    19f8 <botlish_fn_20+0x90>
    19db:	xor    edx,edx
    19dd:	mov    rax,r13
    19e0:	test   rax,0x7
    19e6:	jne    19f8 <botlish_fn_20+0x90>
    19ec:	mov    rax,r13
    19ef:	movzx  rax,BYTE PTR [rax]
    19f3:	cmp    al,0x1
    19f5:	sete   dl
    19f8:	test   dl,dl
    19fa:	jne    1a1b <botlish_fn_20+0xb3>
    1a00:	mov    rdi,rbx
    1a03:	mov    rax,QWORD PTR [rdi+0x10]
    1a07:	mov    rcx,QWORD PTR [rax+0x10]
    1a0b:	xor    rdx,rdx
    1a0e:	mov    rsi,r13
    1a11:	call   1a16 <botlish_fn_20+0xae>
			1a12: R_X86_64_PLT32	rt_type_error-0x4
    1a16:	jmp    1b8c <botlish_fn_20+0x224>
    1a1b:	mov    eax,0x1
    1a20:	test   rcx,0x1
    1a27:	je     1a35 <botlish_fn_20+0xcd>
    1a2d:	mov    r8,rcx
    1a30:	jmp    1a58 <botlish_fn_20+0xf0>
    1a35:	xor    eax,eax
    1a37:	test   rcx,0x7
    1a3e:	je     1a4c <botlish_fn_20+0xe4>
    1a44:	mov    r8,rcx
    1a47:	jmp    1a58 <botlish_fn_20+0xf0>
    1a4c:	movzx  rax,BYTE PTR [rcx]
    1a50:	mov    r8,rcx
    1a53:	cmp    al,0x1
    1a55:	sete   al
    1a58:	test   al,al
    1a5a:	jne    1a7b <botlish_fn_20+0x113>
    1a60:	mov    rdi,rbx
    1a63:	mov    rax,QWORD PTR [rdi+0x10]
    1a67:	mov    rcx,QWORD PTR [rax+0x10]
    1a6b:	xor    rdx,rdx
    1a6e:	mov    rsi,r8
    1a71:	call   1a76 <botlish_fn_20+0x10e>
			1a72: R_X86_64_PLT32	rt_type_error-0x4
    1a76:	jmp    1b8c <botlish_fn_20+0x224>
    1a7b:	mov    rcx,r8
    1a7e:	mov    rsi,r13
    1a81:	mov    rax,rsi
    1a84:	and    rax,rcx
    1a87:	test   rax,0x1
    1a8d:	jne    1a9e <botlish_fn_20+0x136>
    1a93:	mov    rdx,r8
    1a96:	mov    rsi,r13
    1a99:	jmp    1abc <botlish_fn_20+0x154>
    1a9e:	mov    rcx,r8
    1aa1:	lea    rax,[rcx-0x1]
    1aa5:	mov    rsi,r13
    1aa8:	add    rsi,rax
    1aab:	seto   al
    1aae:	test   al,al
    1ab0:	je     1ac7 <botlish_fn_20+0x15f>
    1ab6:	mov    rdx,r8
    1ab9:	mov    rsi,r13
    1abc:	mov    rdi,rbx
    1abf:	call   1ac4 <botlish_fn_20+0x15c>
			1ac0: R_X86_64_PLT32	rt_int_add-0x4
    1ac4:	mov    rsi,rax
    1ac7:	mov    QWORD PTR [rsp+0x8],rsi
    1acc:	mov    QWORD PTR [rsp+0x10],0x3
    1ad5:	test   rsi,0x1
    1adc:	je     1aff <botlish_fn_20+0x197>
    1ae2:	mov    rax,rsi
    1ae5:	add    rax,0x2
    1ae9:	mov    rcx,rax
    1aec:	seto   al
    1aef:	test   al,al
    1af1:	jne    1aff <botlish_fn_20+0x197>
    1af7:	mov    rsi,rcx
    1afa:	jmp    1b0f <botlish_fn_20+0x1a7>
    1aff:	mov    edx,0x3
    1b04:	mov    rdi,rbx
    1b07:	call   1b0c <botlish_fn_20+0x1a4>
			1b08: R_X86_64_PLT32	rt_int_add-0x4
    1b0c:	mov    rsi,rax
    1b0f:	mov    QWORD PTR [rsp+0x8],rsi
    1b14:	mov    edx,0x7
    1b19:	mov    rdi,rdx
    1b1c:	mov    QWORD PTR [rsp+0x10],0x7
    1b25:	test   rsi,0x1
    1b2c:	jne    1b3a <botlish_fn_20+0x1d2>
    1b32:	mov    rdx,rdi
    1b35:	jmp    1b66 <botlish_fn_20+0x1fe>
    1b3a:	mov    rax,rsi
    1b3d:	sar    rax,1
    1b40:	imul   QWORD PTR [rip+0x119]        # 1c60 <botlish_fn_20+0x2f8>
    1b47:	seto   cl
    1b4a:	or     rax,0x1
    1b4e:	test   cl,cl
    1b50:	je     1b5e <botlish_fn_20+0x1f6>
    1b56:	mov    rdx,rdi
    1b59:	jmp    1b66 <botlish_fn_20+0x1fe>
    1b5e:	mov    rsi,rax
    1b61:	jmp    1b71 <botlish_fn_20+0x209>
    1b66:	mov    rdi,rbx
    1b69:	call   1b6e <botlish_fn_20+0x206>
			1b6a: R_X86_64_PLT32	rt_int_mul-0x4
    1b6e:	mov    rsi,rax
    1b71:	mov    QWORD PTR [rsp],rsi
    1b75:	mov    r13,rsi
    1b78:	mov    rsi,r12
    1b7b:	mov    rdi,rbx
    1b7e:	call   1b83 <botlish_fn_20+0x21b>
			1b7f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1b83:	test   rax,rax
    1b86:	jne    1ba7 <botlish_fn_20+0x23f>
    1b8c:	xor    rax,rax
    1b8f:	mov    rbx,QWORD PTR [rsp+0x20]
    1b94:	mov    r12,QWORD PTR [rsp+0x28]
    1b99:	mov    r13,QWORD PTR [rsp+0x30]
    1b9e:	add    rsp,0x40
    1ba2:	mov    rsp,rbp
    1ba5:	pop    rbp
    1ba6:	ret
    1ba7:	mov    QWORD PTR [rsp+0x8],rax
    1bac:	mov    QWORD PTR [rsp+0x10],0x5
    1bb5:	test   rax,0x1
    1bbb:	mov    rsi,rax
    1bbe:	je     1bf0 <botlish_fn_20+0x288>
    1bc4:	mov    rcx,rsi
    1bc7:	mov    rax,rcx
    1bca:	sar    rax,1
    1bcd:	imul   QWORD PTR [rip+0x94]        # 1c68 <botlish_fn_20+0x300>
    1bd4:	seto   dil
    1bd8:	or     rax,0x1
    1bdc:	test   dil,dil
    1bdf:	jne    1bf0 <botlish_fn_20+0x288>
    1be5:	mov    rdx,rax
    1be8:	mov    rsi,r13
    1beb:	jmp    1c03 <botlish_fn_20+0x29b>
    1bf0:	mov    edx,0x5
    1bf5:	mov    rdi,rbx
    1bf8:	call   1bfd <botlish_fn_20+0x295>
			1bf9: R_X86_64_PLT32	rt_int_mul-0x4
    1bfd:	mov    rdx,rax
    1c00:	mov    rsi,r13
    1c03:	mov    r10,rsi
    1c06:	and    r10,rdx
    1c09:	test   r10,0x1
    1c10:	jne    1c37 <botlish_fn_20+0x2cf>
    1c16:	mov    rdi,rbx
    1c19:	call   1c1e <botlish_fn_20+0x2b6>
			1c1a: R_X86_64_PLT32	rt_int_cmp-0x4
    1c1e:	mov    r8d,0x2
    1c24:	test   rax,rax
    1c27:	mov    rax,r8
    1c2a:	cmovg  rax,QWORD PTR [rip+0x2e]        # 1c60 <botlish_fn_20+0x2f8>
    1c32:	jmp    1c47 <botlish_fn_20+0x2df>
    1c37:	mov    eax,0x2
    1c3c:	cmp    rsi,rdx
    1c3f:	cmovg  rax,QWORD PTR [rip+0x19]        # 1c60 <botlish_fn_20+0x2f8>
    1c47:	mov    rbx,QWORD PTR [rsp+0x20]
    1c4c:	mov    r12,QWORD PTR [rsp+0x28]
    1c51:	mov    r13,QWORD PTR [rsp+0x30]
    1c56:	add    rsp,0x40
    1c5a:	mov    rsp,rbp
    1c5d:	pop    rbp
    1c5e:	ret
    1c5f:	add    BYTE PTR [rsi],al
    1c61:	add    BYTE PTR [rax],al
    1c63:	add    BYTE PTR [rax],al
    1c65:	add    BYTE PTR [rax],al
    1c67:	add    BYTE PTR [rax+rax*1],al
    1c6a:	add    BYTE PTR [rax],al
    1c6c:	add    BYTE PTR [rax],al
	...

0000000000001c70 <botlish_entry_20: ht_should_grow<mutarray>>:
    1c70:	push   rbp
    1c71:	mov    rbp,rsp
    1c74:	mov    rsi,QWORD PTR [rdx]
    1c77:	call   1c7c <botlish_entry_20+0xc>
			1c78: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    1c7c:	mov    rsp,rbp
    1c7f:	pop    rbp
    1c80:	ret
    1c81:	add    BYTE PTR [rax],al
    1c83:	add    BYTE PTR [rax],al
    1c85:	add    BYTE PTR [rax],al
	...

0000000000001c88 <botlish_fn_21: ht_grow_or_clean<mutarray>>:
    1c88:	push   rbp
    1c89:	mov    rbp,rsp
    1c8c:	sub    rsp,0x40
    1c90:	mov    QWORD PTR [rsp+0x20],rbx
    1c95:	mov    QWORD PTR [rsp+0x28],r12
    1c9a:	mov    QWORD PTR [rsp+0x30],r13
    1c9f:	mov    rbx,rdi
    1ca2:	mov    QWORD PTR [rsp+0x10],0x0
    1cab:	mov    QWORD PTR [rsp],rsi
    1caf:	mov    r12,rsi
    1cb2:	mov    rsi,r12
    1cb5:	mov    rdi,rbx
    1cb8:	call   1cbd <botlish_fn_21+0x35>
			1cb9: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1cbd:	test   rax,rax
    1cc0:	mov    r13,rax
    1cc3:	je     1eb0 <botlish_fn_21+0x228>
    1cc9:	mov    rsi,r12
    1ccc:	mov    rdi,rbx
    1ccf:	call   1cd4 <botlish_fn_21+0x4c>
			1cd0: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1cd4:	mov    rcx,rax
    1cd7:	test   rcx,rcx
    1cda:	je     1eb0 <botlish_fn_21+0x228>
    1ce0:	mov    edx,0x1
    1ce5:	mov    rax,r13
    1ce8:	test   rax,0x1
    1cee:	je     1cfc <botlish_fn_21+0x74>
    1cf4:	mov    r13,rax
    1cf7:	jmp    1d20 <botlish_fn_21+0x98>
    1cfc:	xor    edx,edx
    1cfe:	test   rax,0x7
    1d04:	je     1d12 <botlish_fn_21+0x8a>
    1d0a:	mov    r13,rax
    1d0d:	jmp    1d20 <botlish_fn_21+0x98>
    1d12:	movzx  rdx,BYTE PTR [rax]
    1d16:	mov    r13,rax
    1d19:	rex cmp dl,0x1
    1d1d:	sete   dl
    1d20:	test   dl,dl
    1d22:	jne    1d43 <botlish_fn_21+0xbb>
    1d28:	mov    rdi,rbx
    1d2b:	mov    rsi,QWORD PTR [rdi+0x10]
    1d2f:	mov    rcx,QWORD PTR [rsi+0x18]
    1d33:	xor    rdx,rdx
    1d36:	mov    rsi,r13
    1d39:	call   1d3e <botlish_fn_21+0xb6>
			1d3a: R_X86_64_PLT32	rt_type_error-0x4
    1d3e:	jmp    1eb0 <botlish_fn_21+0x228>
    1d43:	mov    rsi,r13
    1d46:	mov    eax,0x1
    1d4b:	test   rcx,0x1
    1d52:	je     1d60 <botlish_fn_21+0xd8>
    1d58:	mov    r8,rcx
    1d5b:	jmp    1d85 <botlish_fn_21+0xfd>
    1d60:	xor    eax,eax
    1d62:	test   rcx,0x7
    1d69:	je     1d77 <botlish_fn_21+0xef>
    1d6f:	mov    r8,rcx
    1d72:	jmp    1d85 <botlish_fn_21+0xfd>
    1d77:	movzx  r11,BYTE PTR [rcx]
    1d7b:	mov    r8,rcx
    1d7e:	cmp    r11b,0x1
    1d82:	sete   al
    1d85:	test   al,al
    1d87:	jne    1da8 <botlish_fn_21+0x120>
    1d8d:	mov    rdi,rbx
    1d90:	mov    rax,QWORD PTR [rdi+0x10]
    1d94:	mov    rcx,QWORD PTR [rax+0x18]
    1d98:	xor    rdx,rdx
    1d9b:	mov    rsi,r8
    1d9e:	call   1da3 <botlish_fn_21+0x11b>
			1d9f: R_X86_64_PLT32	rt_type_error-0x4
    1da3:	jmp    1eb0 <botlish_fn_21+0x228>
    1da8:	mov    rcx,r8
    1dab:	mov    rax,rsi
    1dae:	and    rax,rcx
    1db1:	test   rax,0x1
    1db7:	jne    1ddd <botlish_fn_21+0x155>
    1dbd:	mov    rdx,r8
    1dc0:	mov    rdi,rbx
    1dc3:	call   1dc8 <botlish_fn_21+0x140>
			1dc4: R_X86_64_PLT32	rt_int_cmp-0x4
    1dc8:	mov    ecx,0x2
    1dcd:	test   rax,rax
    1dd0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1ee8 <botlish_fn_21+0x260>
    1dd8:	jmp    1df0 <botlish_fn_21+0x168>
    1ddd:	mov    ecx,0x2
    1de2:	mov    r9,r8
    1de5:	cmp    rsi,r9
    1de8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1ee8 <botlish_fn_21+0x260>
    1df0:	cmp    rcx,0x6
    1df4:	je     1e80 <botlish_fn_21+0x1f8>
    1dfa:	mov    rsi,r12
    1dfd:	mov    rdi,rbx
    1e00:	call   1e05 <botlish_fn_21+0x17d>
			1e01: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1e05:	test   rax,rax
    1e08:	je     1eb0 <botlish_fn_21+0x228>
    1e0e:	mov    QWORD PTR [rsp+0x8],rax
    1e13:	mov    QWORD PTR [rsp+0x10],0x5
    1e1c:	test   rax,0x1
    1e22:	mov    rsi,rax
    1e25:	je     1e52 <botlish_fn_21+0x1ca>
    1e2b:	mov    rcx,rsi
    1e2e:	mov    rax,rcx
    1e31:	sar    rax,1
    1e34:	imul   QWORD PTR [rip+0xb5]        # 1ef0 <botlish_fn_21+0x268>
    1e3b:	seto   cl
    1e3e:	or     rax,0x1
    1e42:	test   cl,cl
    1e44:	jne    1e52 <botlish_fn_21+0x1ca>
    1e4a:	mov    rdx,rax
    1e4d:	jmp    1e62 <botlish_fn_21+0x1da>
    1e52:	mov    edx,0x5
    1e57:	mov    rdi,rbx
    1e5a:	call   1e5f <botlish_fn_21+0x1d7>
			1e5b: R_X86_64_PLT32	rt_int_mul-0x4
    1e5f:	mov    rdx,rax
    1e62:	mov    QWORD PTR [rsp+0x8],rdx
    1e67:	mov    rsi,r12
    1e6a:	mov    rdi,rbx
    1e6d:	call   1e72 <botlish_fn_21+0x1ea>
			1e6e: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1e72:	test   rax,rax
    1e75:	je     1eb0 <botlish_fn_21+0x228>
    1e7b:	jmp    1ecb <botlish_fn_21+0x243>
    1e80:	mov    rsi,r12
    1e83:	mov    rdi,rbx
    1e86:	call   1e8b <botlish_fn_21+0x203>
			1e87: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1e8b:	test   rax,rax
    1e8e:	je     1eb0 <botlish_fn_21+0x228>
    1e94:	mov    QWORD PTR [rsp+0x8],rax
    1e99:	mov    rdx,rax
    1e9c:	mov    rsi,r12
    1e9f:	mov    rdi,rbx
    1ea2:	call   1ea7 <botlish_fn_21+0x21f>
			1ea3: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1ea7:	test   rax,rax
    1eaa:	jne    1ecb <botlish_fn_21+0x243>
    1eb0:	xor    rax,rax
    1eb3:	mov    rbx,QWORD PTR [rsp+0x20]
    1eb8:	mov    r12,QWORD PTR [rsp+0x28]
    1ebd:	mov    r13,QWORD PTR [rsp+0x30]
    1ec2:	add    rsp,0x40
    1ec6:	mov    rsp,rbp
    1ec9:	pop    rbp
    1eca:	ret
    1ecb:	mov    rbx,QWORD PTR [rsp+0x20]
    1ed0:	mov    r12,QWORD PTR [rsp+0x28]
    1ed5:	mov    r13,QWORD PTR [rsp+0x30]
    1eda:	add    rsp,0x40
    1ede:	mov    rsp,rbp
    1ee1:	pop    rbp
    1ee2:	ret
    1ee3:	add    BYTE PTR [rax],al
    1ee5:	add    BYTE PTR [rax],al
    1ee7:	add    BYTE PTR [rsi],al
    1ee9:	add    BYTE PTR [rax],al
    1eeb:	add    BYTE PTR [rax],al
    1eed:	add    BYTE PTR [rax],al
    1eef:	add    BYTE PTR [rax+rax*1],al
    1ef2:	add    BYTE PTR [rax],al
    1ef4:	add    BYTE PTR [rax],al
	...

0000000000001ef8 <botlish_entry_21: ht_grow_or_clean<mutarray>>:
    1ef8:	push   rbp
    1ef9:	mov    rbp,rsp
    1efc:	mov    rsi,QWORD PTR [rdx]
    1eff:	call   1f04 <botlish_entry_21+0xc>
			1f00: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    1f04:	mov    rsp,rbp
    1f07:	pop    rbp
    1f08:	ret
    1f09:	add    BYTE PTR [rax],al
    1f0b:	add    BYTE PTR [rax],al
    1f0d:	add    BYTE PTR [rax],al
	...

0000000000001f10 <botlish_fn_22: ht_place<mutarray, int, str, str>>:
    1f10:	push   rbp
    1f11:	mov    rbp,rsp
    1f14:	sub    rsp,0x70
    1f18:	mov    QWORD PTR [rsp+0x40],rbx
    1f1d:	mov    QWORD PTR [rsp+0x48],r12
    1f22:	mov    QWORD PTR [rsp+0x50],r13
    1f27:	mov    QWORD PTR [rsp+0x58],r14
    1f2c:	mov    QWORD PTR [rsp+0x60],r15
    1f31:	mov    rbx,rdi
    1f34:	mov    r14,r8
    1f37:	mov    r15,rdx
    1f3a:	mov    QWORD PTR [rsp+0x28],rcx
    1f3f:	mov    QWORD PTR [rsp],rsi
    1f43:	mov    r12,rsi
    1f46:	mov    rsi,r12
    1f49:	mov    rdi,rbx
    1f4c:	call   1f51 <botlish_fn_22+0x41>
			1f4d: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    1f51:	test   rax,rax
    1f54:	je     22ba <botlish_fn_22+0x3aa>
    1f5a:	xor    ecx,ecx
    1f5c:	test   rax,0x7
    1f62:	je     1f72 <botlish_fn_22+0x62>
    1f68:	mov    QWORD PTR [rsp+0x30],rax
    1f6d:	jmp    1f82 <botlish_fn_22+0x72>
    1f72:	movzx  rcx,BYTE PTR [rax]
    1f76:	mov    QWORD PTR [rsp+0x30],rax
    1f7b:	rex cmp cl,0x8
    1f7f:	sete   cl
    1f82:	test   cl,cl
    1f84:	jne    1fa9 <botlish_fn_22+0x99>
    1f8a:	mov    rdi,rbx
    1f8d:	mov    rax,QWORD PTR [rdi+0x10]
    1f91:	mov    rcx,QWORD PTR [rax+0x8]
    1f95:	mov    edx,0x8
    1f9a:	mov    rsi,QWORD PTR [rsp+0x30]
    1f9f:	call   1fa4 <botlish_fn_22+0x94>
			1fa0: R_X86_64_PLT32	rt_type_error-0x4
    1fa4:	jmp    22ba <botlish_fn_22+0x3aa>
    1fa9:	mov    rdx,r15
    1fac:	mov    rsi,QWORD PTR [rsp+0x30]
    1fb1:	mov    rdi,rbx
    1fb4:	call   1fb9 <botlish_fn_22+0xa9>
			1fb5: R_X86_64_PLT32	rt_mutarray_get-0x4
    1fb9:	test   rax,rax
    1fbc:	je     22ba <botlish_fn_22+0x3aa>
    1fc2:	mov    QWORD PTR [rsp+0x8],rax
    1fc7:	mov    r13,rax
    1fca:	mov    ecx,0x3
    1fcf:	mov    rsi,QWORD PTR [rsp+0x30]
    1fd4:	mov    rdx,r15
    1fd7:	mov    rdi,rbx
    1fda:	call   1fdf <botlish_fn_22+0xcf>
			1fdb: R_X86_64_PLT32	rt_mutarray_set-0x4
    1fdf:	test   rax,rax
    1fe2:	je     22ba <botlish_fn_22+0x3aa>
    1fe8:	mov    rsi,r12
    1feb:	mov    rdi,rbx
    1fee:	call   1ff3 <botlish_fn_22+0xe3>
			1fef: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    1ff3:	test   rax,rax
    1ff6:	je     22ba <botlish_fn_22+0x3aa>
    1ffc:	xor    ecx,ecx
    1ffe:	test   rax,0x7
    2004:	je     2012 <botlish_fn_22+0x102>
    200a:	mov    rsi,rax
    200d:	jmp    2020 <botlish_fn_22+0x110>
    2012:	movzx  rcx,BYTE PTR [rax]
    2016:	mov    rsi,rax
    2019:	rex cmp cl,0x8
    201d:	sete   cl
    2020:	test   cl,cl
    2022:	jne    2042 <botlish_fn_22+0x132>
    2028:	mov    rdi,rbx
    202b:	mov    rax,QWORD PTR [rdi+0x10]
    202f:	mov    rcx,QWORD PTR [rax+0x20]
    2033:	mov    edx,0x8
    2038:	call   203d <botlish_fn_22+0x12d>
			2039: R_X86_64_PLT32	rt_type_error-0x4
    203d:	jmp    22ba <botlish_fn_22+0x3aa>
    2042:	mov    rcx,QWORD PTR [rsp+0x28]
    2047:	mov    rdx,r15
    204a:	mov    rdi,rbx
    204d:	call   2052 <botlish_fn_22+0x142>
			204e: R_X86_64_PLT32	rt_mutarray_set-0x4
    2052:	test   rax,rax
    2055:	je     22ba <botlish_fn_22+0x3aa>
    205b:	mov    rsi,r12
    205e:	mov    rdi,rbx
    2061:	call   2066 <botlish_fn_22+0x156>
			2062: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    2066:	test   rax,rax
    2069:	je     22ba <botlish_fn_22+0x3aa>
    206f:	xor    esi,esi
    2071:	test   rax,0x7
    2077:	jne    2089 <botlish_fn_22+0x179>
    207d:	movzx  rcx,BYTE PTR [rax]
    2081:	rex cmp cl,0x8
    2085:	sete   sil
    2089:	test   sil,sil
    208c:	jne    20af <botlish_fn_22+0x19f>
    2092:	mov    rdi,rbx
    2095:	mov    rsi,QWORD PTR [rdi+0x10]
    2099:	mov    rcx,QWORD PTR [rsi+0x20]
    209d:	mov    edx,0x8
    20a2:	mov    rsi,rax
    20a5:	call   20aa <botlish_fn_22+0x19a>
			20a6: R_X86_64_PLT32	rt_type_error-0x4
    20aa:	jmp    22ba <botlish_fn_22+0x3aa>
    20af:	mov    rcx,r14
    20b2:	mov    rdx,r15
    20b5:	mov    rsi,rax
    20b8:	mov    rdi,rbx
    20bb:	call   20c0 <botlish_fn_22+0x1b0>
			20bc: R_X86_64_PLT32	rt_mutarray_set-0x4
    20c0:	test   rax,rax
    20c3:	je     22ba <botlish_fn_22+0x3aa>
    20c9:	mov    QWORD PTR [rsp+0x10],0x7
    20d2:	mov    rsi,r12
    20d5:	mov    rdi,rbx
    20d8:	call   20dd <botlish_fn_22+0x1cd>
			20d9: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    20dd:	test   rax,rax
    20e0:	je     22ba <botlish_fn_22+0x3aa>
    20e6:	mov    QWORD PTR [rsp+0x18],rax
    20eb:	mov    QWORD PTR [rsp+0x20],0x3
    20f4:	mov    ecx,0x1
    20f9:	test   rax,0x1
    20ff:	je     210d <botlish_fn_22+0x1fd>
    2105:	mov    rsi,rax
    2108:	jmp    2131 <botlish_fn_22+0x221>
    210d:	xor    ecx,ecx
    210f:	test   rax,0x7
    2115:	je     2123 <botlish_fn_22+0x213>
    211b:	mov    rsi,rax
    211e:	jmp    2131 <botlish_fn_22+0x221>
    2123:	movzx  rcx,BYTE PTR [rax]
    2127:	mov    rsi,rax
    212a:	rex cmp cl,0x1
    212e:	sete   cl
    2131:	test   cl,cl
    2133:	jne    2151 <botlish_fn_22+0x241>
    2139:	mov    rdi,rbx
    213c:	mov    rax,QWORD PTR [rdi+0x10]
    2140:	mov    rcx,QWORD PTR [rax+0x10]
    2144:	xor    rdx,rdx
    2147:	call   214c <botlish_fn_22+0x23c>
			2148: R_X86_64_PLT32	rt_type_error-0x4
    214c:	jmp    22ba <botlish_fn_22+0x3aa>
    2151:	test   rsi,0x1
    2158:	je     2170 <botlish_fn_22+0x260>
    215e:	mov    rcx,rsi
    2161:	add    rcx,0x2
    2165:	seto   al
    2168:	test   al,al
    216a:	je     2180 <botlish_fn_22+0x270>
    2170:	mov    edx,0x3
    2175:	mov    rdi,rbx
    2178:	call   217d <botlish_fn_22+0x26d>
			2179: R_X86_64_PLT32	rt_int_add-0x4
    217d:	mov    rcx,rax
    2180:	mov    edx,0x7
    2185:	mov    rsi,r12
    2188:	mov    rdi,rbx
    218b:	call   2190 <botlish_fn_22+0x280>
			218c: R_X86_64_PLT32	rt_mutarray_set-0x4
    2190:	test   rax,rax
    2193:	je     22ba <botlish_fn_22+0x3aa>
    2199:	mov    rax,r13
    219c:	test   rax,0x1
    21a2:	jne    21c6 <botlish_fn_22+0x2b6>
    21a8:	mov    edx,0x5
    21ad:	mov    rsi,r13
    21b0:	mov    rdi,rbx
    21b3:	call   21b8 <botlish_fn_22+0x2a8>
			21b4: R_X86_64_PLT32	rt_value_eq-0x4
    21b8:	test   rax,rax
    21bb:	je     22ba <botlish_fn_22+0x3aa>
    21c1:	jmp    21da <botlish_fn_22+0x2ca>
    21c6:	mov    rsi,r13
    21c9:	mov    eax,0x2
    21ce:	cmp    rsi,0x5
    21d2:	cmove  rax,QWORD PTR [rip+0x12e]        # 2308 <botlish_fn_22+0x3f8>
    21da:	cmp    rax,0x6
    21de:	jne    22df <botlish_fn_22+0x3cf>
    21e4:	mov    QWORD PTR [rsp+0x8],0x9
    21ed:	mov    rsi,r12
    21f0:	mov    rdi,rbx
    21f3:	call   21f8 <botlish_fn_22+0x2e8>
			21f4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    21f8:	test   rax,rax
    21fb:	je     22ba <botlish_fn_22+0x3aa>
    2201:	mov    QWORD PTR [rsp+0x10],rax
    2206:	mov    QWORD PTR [rsp+0x18],0x3
    220f:	mov    ecx,0x1
    2214:	test   rax,0x1
    221a:	je     2228 <botlish_fn_22+0x318>
    2220:	mov    rsi,rax
    2223:	jmp    224c <botlish_fn_22+0x33c>
    2228:	xor    ecx,ecx
    222a:	test   rax,0x7
    2230:	je     223e <botlish_fn_22+0x32e>
    2236:	mov    rsi,rax
    2239:	jmp    224c <botlish_fn_22+0x33c>
    223e:	movzx  rcx,BYTE PTR [rax]
    2242:	mov    rsi,rax
    2245:	rex cmp cl,0x1
    2249:	sete   cl
    224c:	test   cl,cl
    224e:	jne    226c <botlish_fn_22+0x35c>
    2254:	mov    rdi,rbx
    2257:	mov    rcx,QWORD PTR [rdi+0x10]
    225b:	mov    rcx,QWORD PTR [rcx+0x28]
    225f:	xor    rdx,rdx
    2262:	call   2267 <botlish_fn_22+0x357>
			2263: R_X86_64_PLT32	rt_type_error-0x4
    2267:	jmp    22ba <botlish_fn_22+0x3aa>
    226c:	test   rsi,0x1
    2273:	je     2291 <botlish_fn_22+0x381>
    2279:	mov    r8,rsi
    227c:	sub    r8,0x3
    2280:	seto   dil
    2284:	lea    rcx,[r8+0x1]
    2288:	test   dil,dil
    228b:	je     22a1 <botlish_fn_22+0x391>
    2291:	mov    edx,0x3
    2296:	mov    rdi,rbx
    2299:	call   229e <botlish_fn_22+0x38e>
			229a: R_X86_64_PLT32	rt_int_sub-0x4
    229e:	mov    rcx,rax
    22a1:	mov    edx,0x9
    22a6:	mov    rsi,r12
    22a9:	mov    rdi,rbx
    22ac:	call   22b1 <botlish_fn_22+0x3a1>
			22ad: R_X86_64_PLT32	rt_mutarray_set-0x4
    22b1:	test   rax,rax
    22b4:	jne    22df <botlish_fn_22+0x3cf>
    22ba:	xor    rax,rax
    22bd:	mov    rbx,QWORD PTR [rsp+0x40]
    22c2:	mov    r12,QWORD PTR [rsp+0x48]
    22c7:	mov    r13,QWORD PTR [rsp+0x50]
    22cc:	mov    r14,QWORD PTR [rsp+0x58]
    22d1:	mov    r15,QWORD PTR [rsp+0x60]
    22d6:	add    rsp,0x70
    22da:	mov    rsp,rbp
    22dd:	pop    rbp
    22de:	ret
    22df:	mov    eax,0xa
    22e4:	mov    rbx,QWORD PTR [rsp+0x40]
    22e9:	mov    r12,QWORD PTR [rsp+0x48]
    22ee:	mov    r13,QWORD PTR [rsp+0x50]
    22f3:	mov    r14,QWORD PTR [rsp+0x58]
    22f8:	mov    r15,QWORD PTR [rsp+0x60]
    22fd:	add    rsp,0x70
    2301:	mov    rsp,rbp
    2304:	pop    rbp
    2305:	ret
    2306:	add    BYTE PTR [rax],al
    2308:	(bad)
    2309:	add    BYTE PTR [rax],al
    230b:	add    BYTE PTR [rax],al
    230d:	add    BYTE PTR [rax],al
	...

0000000000002310 <botlish_entry_22: ht_place<mutarray, int, str, str>>:
    2310:	push   rbp
    2311:	mov    rbp,rsp
    2314:	mov    rsi,QWORD PTR [rdx]
    2317:	mov    r9,QWORD PTR [rdx+0x8]
    231b:	mov    rcx,QWORD PTR [rdx+0x10]
    231f:	mov    r8,QWORD PTR [rdx+0x18]
    2323:	mov    rdx,r9
    2326:	call   232b <botlish_entry_22+0x1b>
			2327: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    232b:	mov    rsp,rbp
    232e:	pop    rbp
    232f:	ret

0000000000002330 <botlish_fn_23: ht_set<mutarray, str, str>>:
    2330:	push   rbp
    2331:	mov    rbp,rsp
    2334:	sub    rsp,0x60
    2338:	mov    QWORD PTR [rsp+0x30],rbx
    233d:	mov    QWORD PTR [rsp+0x38],r12
    2342:	mov    QWORD PTR [rsp+0x40],r13
    2347:	mov    QWORD PTR [rsp+0x48],r14
    234c:	mov    QWORD PTR [rsp+0x50],r15
    2351:	mov    rbx,rdi
    2354:	mov    r13,rdx
    2357:	mov    QWORD PTR [rsp],rsi
    235b:	mov    r14,rsi
    235e:	mov    QWORD PTR [rsp+0x8],rdx
    2363:	mov    QWORD PTR [rsp+0x10],rcx
    2368:	mov    r12,rcx
    236b:	mov    rdx,r13
    236e:	mov    rsi,r14
    2371:	mov    rdi,rbx
    2374:	call   2379 <botlish_fn_23+0x49>
			2375: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2379:	test   rax,rax
    237c:	je     25e7 <botlish_fn_23+0x2b7>
    2382:	mov    QWORD PTR [rsp+0x18],rax
    2387:	mov    rcx,rax
    238a:	mov    r8,0xffffffffffffffff
    2391:	mov    QWORD PTR [rsp+0x28],r8
    2396:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    239f:	mov    rdx,r13
    23a2:	mov    rsi,r14
    23a5:	mov    rdi,rbx
    23a8:	call   23ad <botlish_fn_23+0x7d>
			23a9: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    23ad:	mov    rcx,rax
    23b0:	mov    r15,rax
    23b3:	test   rax,rcx
    23b6:	je     25e7 <botlish_fn_23+0x2b7>
    23bc:	mov    rax,r15
    23bf:	mov    QWORD PTR [rsp+0x18],rax
    23c4:	mov    rsi,r14
    23c7:	mov    rdi,rbx
    23ca:	call   23cf <botlish_fn_23+0x9f>
			23cb: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    23cf:	test   rax,rax
    23d2:	je     25e7 <botlish_fn_23+0x2b7>
    23d8:	xor    ecx,ecx
    23da:	test   rax,0x7
    23e0:	je     23ee <botlish_fn_23+0xbe>
    23e6:	mov    r8,rax
    23e9:	jmp    23fc <botlish_fn_23+0xcc>
    23ee:	movzx  rcx,BYTE PTR [rax]
    23f2:	mov    r8,rax
    23f5:	rex cmp cl,0x8
    23f9:	sete   cl
    23fc:	test   cl,cl
    23fe:	jne    2421 <botlish_fn_23+0xf1>
    2404:	mov    rdi,rbx
    2407:	mov    rsi,QWORD PTR [rdi+0x10]
    240b:	mov    rcx,QWORD PTR [rsi+0x8]
    240f:	mov    edx,0x8
    2414:	mov    rsi,r8
    2417:	call   241c <botlish_fn_23+0xec>
			2418: R_X86_64_PLT32	rt_type_error-0x4
    241c:	jmp    25e7 <botlish_fn_23+0x2b7>
    2421:	mov    rsi,r8
    2424:	mov    rdx,r15
    2427:	mov    rdi,rbx
    242a:	call   242f <botlish_fn_23+0xff>
			242b: R_X86_64_PLT32	rt_mutarray_get-0x4
    242f:	test   rax,rax
    2432:	je     25e7 <botlish_fn_23+0x2b7>
    2438:	test   rax,0x1
    243e:	mov    rsi,rax
    2441:	jne    2462 <botlish_fn_23+0x132>
    2447:	mov    edx,0x3
    244c:	mov    rdi,rbx
    244f:	call   2454 <botlish_fn_23+0x124>
			2450: R_X86_64_PLT32	rt_value_eq-0x4
    2454:	test   rax,rax
    2457:	je     25e7 <botlish_fn_23+0x2b7>
    245d:	jmp    2473 <botlish_fn_23+0x143>
    2462:	mov    eax,0x2
    2467:	cmp    rsi,0x3
    246b:	cmove  rax,QWORD PTR [rip+0x1c5]        # 2638 <botlish_fn_23+0x308>
    2473:	cmp    rax,0x6
    2477:	je     2576 <botlish_fn_23+0x246>
    247d:	mov    rsi,r14
    2480:	mov    rdi,rbx
    2483:	call   2488 <botlish_fn_23+0x158>
			2484: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    2488:	test   rax,rax
    248b:	je     25e7 <botlish_fn_23+0x2b7>
    2491:	cmp    rax,0x6
    2495:	je     24da <botlish_fn_23+0x1aa>
    249b:	mov    rcx,r13
    249e:	mov    rdx,r15
    24a1:	mov    rsi,r14
    24a4:	mov    rdi,rbx
    24a7:	mov    r8,r12
    24aa:	call   24af <botlish_fn_23+0x17f>
			24ab: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    24af:	test   rax,rax
    24b2:	je     25e7 <botlish_fn_23+0x2b7>
    24b8:	mov    rbx,QWORD PTR [rsp+0x30]
    24bd:	mov    r12,QWORD PTR [rsp+0x38]
    24c2:	mov    r13,QWORD PTR [rsp+0x40]
    24c7:	mov    r14,QWORD PTR [rsp+0x48]
    24cc:	mov    r15,QWORD PTR [rsp+0x50]
    24d1:	add    rsp,0x60
    24d5:	mov    rsp,rbp
    24d8:	pop    rbp
    24d9:	ret
    24da:	mov    rsi,r14
    24dd:	mov    rdi,rbx
    24e0:	call   24e5 <botlish_fn_23+0x1b5>
			24e1: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    24e5:	test   rax,rax
    24e8:	je     25e7 <botlish_fn_23+0x2b7>
    24ee:	mov    rdx,r13
    24f1:	mov    rsi,r14
    24f4:	mov    rdi,rbx
    24f7:	call   24fc <botlish_fn_23+0x1cc>
			24f8: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    24fc:	test   rax,rax
    24ff:	je     25e7 <botlish_fn_23+0x2b7>
    2505:	mov    QWORD PTR [rsp+0x18],rax
    250a:	mov    rcx,rax
    250d:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    2516:	mov    r8,QWORD PTR [rsp+0x28]
    251b:	mov    rdx,r13
    251e:	mov    rsi,r14
    2521:	mov    rdi,rbx
    2524:	call   2529 <botlish_fn_23+0x1f9>
			2525: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    2529:	test   rax,rax
    252c:	je     25e7 <botlish_fn_23+0x2b7>
    2532:	mov    QWORD PTR [rsp+0x18],rax
    2537:	mov    rcx,r13
    253a:	mov    rdx,rax
    253d:	mov    rsi,r14
    2540:	mov    rdi,rbx
    2543:	mov    r8,r12
    2546:	call   254b <botlish_fn_23+0x21b>
			2547: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    254b:	test   rax,rax
    254e:	je     25e7 <botlish_fn_23+0x2b7>
    2554:	mov    rbx,QWORD PTR [rsp+0x30]
    2559:	mov    r12,QWORD PTR [rsp+0x38]
    255e:	mov    r13,QWORD PTR [rsp+0x40]
    2563:	mov    r14,QWORD PTR [rsp+0x48]
    2568:	mov    r15,QWORD PTR [rsp+0x50]
    256d:	add    rsp,0x60
    2571:	mov    rsp,rbp
    2574:	pop    rbp
    2575:	ret
    2576:	mov    rsi,r14
    2579:	mov    rdi,rbx
    257c:	call   2581 <botlish_fn_23+0x251>
			257d: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    2581:	test   rax,rax
    2584:	je     25e7 <botlish_fn_23+0x2b7>
    258a:	xor    ecx,ecx
    258c:	test   rax,0x7
    2592:	je     25a0 <botlish_fn_23+0x270>
    2598:	mov    rsi,rax
    259b:	jmp    25ae <botlish_fn_23+0x27e>
    25a0:	movzx  rcx,BYTE PTR [rax]
    25a4:	mov    rsi,rax
    25a7:	rex cmp cl,0x8
    25ab:	sete   cl
    25ae:	test   cl,cl
    25b0:	jne    25d0 <botlish_fn_23+0x2a0>
    25b6:	mov    rdi,rbx
    25b9:	mov    rax,QWORD PTR [rdi+0x10]
    25bd:	mov    rcx,QWORD PTR [rax+0x20]
    25c1:	mov    edx,0x8
    25c6:	call   25cb <botlish_fn_23+0x29b>
			25c7: R_X86_64_PLT32	rt_type_error-0x4
    25cb:	jmp    25e7 <botlish_fn_23+0x2b7>
    25d0:	mov    rcx,r12
    25d3:	mov    rdx,r15
    25d6:	mov    rdi,rbx
    25d9:	call   25de <botlish_fn_23+0x2ae>
			25da: R_X86_64_PLT32	rt_mutarray_set-0x4
    25de:	test   rax,rax
    25e1:	jne    260c <botlish_fn_23+0x2dc>
    25e7:	xor    rax,rax
    25ea:	mov    rbx,QWORD PTR [rsp+0x30]
    25ef:	mov    r12,QWORD PTR [rsp+0x38]
    25f4:	mov    r13,QWORD PTR [rsp+0x40]
    25f9:	mov    r14,QWORD PTR [rsp+0x48]
    25fe:	mov    r15,QWORD PTR [rsp+0x50]
    2603:	add    rsp,0x60
    2607:	mov    rsp,rbp
    260a:	pop    rbp
    260b:	ret
    260c:	mov    eax,0xa
    2611:	mov    rbx,QWORD PTR [rsp+0x30]
    2616:	mov    r12,QWORD PTR [rsp+0x38]
    261b:	mov    r13,QWORD PTR [rsp+0x40]
    2620:	mov    r14,QWORD PTR [rsp+0x48]
    2625:	mov    r15,QWORD PTR [rsp+0x50]
    262a:	add    rsp,0x60
    262e:	mov    rsp,rbp
    2631:	pop    rbp
    2632:	ret
    2633:	add    BYTE PTR [rax],al
    2635:	add    BYTE PTR [rax],al
    2637:	add    BYTE PTR [rsi],al
    2639:	add    BYTE PTR [rax],al
    263b:	add    BYTE PTR [rax],al
    263d:	add    BYTE PTR [rax],al
	...

0000000000002640 <botlish_entry_23: ht_set<mutarray, str, str>>:
    2640:	push   rbp
    2641:	mov    rbp,rsp
    2644:	mov    rsi,QWORD PTR [rdx]
    2647:	mov    r8,QWORD PTR [rdx+0x8]
    264b:	mov    rcx,QWORD PTR [rdx+0x10]
    264f:	mov    rdx,r8
    2652:	call   2657 <botlish_entry_23+0x17>
			2653: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2657:	mov    rsp,rbp
    265a:	pop    rbp
    265b:	ret
    265c:	add    BYTE PTR [rax],al
	...

0000000000002660 <botlish_fn_24: ht_delete<mutarray, str>>:
    2660:	push   rbp
    2661:	mov    rbp,rsp
    2664:	sub    rsp,0x40
    2668:	mov    QWORD PTR [rsp+0x20],rbx
    266d:	mov    QWORD PTR [rsp+0x28],r12
    2672:	mov    QWORD PTR [rsp+0x30],r13
    2677:	mov    rbx,rdi
    267a:	mov    QWORD PTR [rsp+0x18],0x0
    2683:	mov    QWORD PTR [rsp],rsi
    2687:	mov    r12,rsi
    268a:	mov    QWORD PTR [rsp+0x8],rdx
    268f:	mov    r13,rdx
    2692:	mov    rdx,r13
    2695:	mov    rsi,r12
    2698:	mov    rdi,rbx
    269b:	call   26a0 <botlish_fn_24+0x40>
			269c: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    26a0:	test   rax,rax
    26a3:	je     2a10 <botlish_fn_24+0x3b0>
    26a9:	mov    QWORD PTR [rsp+0x10],rax
    26ae:	mov    rcx,rax
    26b1:	mov    rdx,r13
    26b4:	mov    rsi,r12
    26b7:	mov    rdi,rbx
    26ba:	call   26bf <botlish_fn_24+0x5f>
			26bb: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    26bf:	mov    rcx,rax
    26c2:	mov    r13,rax
    26c5:	test   rax,rcx
    26c8:	je     2a10 <botlish_fn_24+0x3b0>
    26ce:	mov    rax,r13
    26d1:	test   rax,0x1
    26d7:	jne    2702 <botlish_fn_24+0xa2>
    26dd:	mov    edx,0x1
    26e2:	mov    rsi,r13
    26e5:	mov    rdi,rbx
    26e8:	call   26ed <botlish_fn_24+0x8d>
			26e9: R_X86_64_PLT32	rt_int_cmp-0x4
    26ed:	mov    ecx,0x2
    26f2:	test   rax,rax
    26f5:	cmovl  rcx,QWORD PTR [rip+0x36b]        # 2a68 <botlish_fn_24+0x408>
    26fd:	jmp    2718 <botlish_fn_24+0xb8>
    2702:	mov    ecx,0x2
    2707:	mov    rax,r13
    270a:	mov    rdx,r13
    270d:	test   rax,rdx
    2710:	cmovle rcx,QWORD PTR [rip+0x350]        # 2a68 <botlish_fn_24+0x408>
    2718:	cmp    rcx,0x6
    271c:	je     2a48 <botlish_fn_24+0x3e8>
    2722:	mov    rsi,r12
    2725:	mov    rdi,rbx
    2728:	call   272d <botlish_fn_24+0xcd>
			2729: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    272d:	test   rax,rax
    2730:	je     2a10 <botlish_fn_24+0x3b0>
    2736:	xor    ecx,ecx
    2738:	test   rax,0x7
    273e:	je     274c <botlish_fn_24+0xec>
    2744:	mov    rsi,rax
    2747:	jmp    275a <botlish_fn_24+0xfa>
    274c:	movzx  rcx,BYTE PTR [rax]
    2750:	mov    rsi,rax
    2753:	rex cmp cl,0x8
    2757:	sete   cl
    275a:	test   cl,cl
    275c:	jne    277c <botlish_fn_24+0x11c>
    2762:	mov    rdi,rbx
    2765:	mov    rax,QWORD PTR [rdi+0x10]
    2769:	mov    rcx,QWORD PTR [rax+0x20]
    276d:	mov    edx,0x8
    2772:	call   2777 <botlish_fn_24+0x117>
			2773: R_X86_64_PLT32	rt_type_error-0x4
    2777:	jmp    2a10 <botlish_fn_24+0x3b0>
    277c:	mov    ecx,0x5
    2781:	mov    rdx,r13
    2784:	mov    rdi,rbx
    2787:	call   278c <botlish_fn_24+0x12c>
			2788: R_X86_64_PLT32	rt_mutarray_set-0x4
    278c:	test   rax,rax
    278f:	je     2a10 <botlish_fn_24+0x3b0>
    2795:	mov    rsi,r12
    2798:	mov    rdi,rbx
    279b:	call   27a0 <botlish_fn_24+0x140>
			279c: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    27a0:	test   rax,rax
    27a3:	je     2a10 <botlish_fn_24+0x3b0>
    27a9:	xor    ecx,ecx
    27ab:	test   rax,0x7
    27b1:	jne    27c2 <botlish_fn_24+0x162>
    27b7:	movzx  rsi,BYTE PTR [rax]
    27bb:	cmp    sil,0x8
    27bf:	sete   cl
    27c2:	test   cl,cl
    27c4:	jne    27e7 <botlish_fn_24+0x187>
    27ca:	mov    rdi,rbx
    27cd:	mov    r9,QWORD PTR [rdi+0x10]
    27d1:	mov    rcx,QWORD PTR [r9+0x20]
    27d5:	mov    edx,0x8
    27da:	mov    rsi,rax
    27dd:	call   27e2 <botlish_fn_24+0x182>
			27de: R_X86_64_PLT32	rt_type_error-0x4
    27e2:	jmp    2a10 <botlish_fn_24+0x3b0>
    27e7:	mov    rsi,rax
    27ea:	mov    ecx,0xa
    27ef:	mov    rdx,r13
    27f2:	mov    rdi,rbx
    27f5:	call   27fa <botlish_fn_24+0x19a>
			27f6: R_X86_64_PLT32	rt_mutarray_set-0x4
    27fa:	test   rax,rax
    27fd:	je     2a10 <botlish_fn_24+0x3b0>
    2803:	mov    rsi,r12
    2806:	mov    rdi,rbx
    2809:	call   280e <botlish_fn_24+0x1ae>
			280a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    280e:	test   rax,rax
    2811:	je     2a10 <botlish_fn_24+0x3b0>
    2817:	xor    ecx,ecx
    2819:	test   rax,0x7
    281f:	je     282d <botlish_fn_24+0x1cd>
    2825:	mov    rsi,rax
    2828:	jmp    283b <botlish_fn_24+0x1db>
    282d:	movzx  rcx,BYTE PTR [rax]
    2831:	mov    rsi,rax
    2834:	rex cmp cl,0x8
    2838:	sete   cl
    283b:	test   cl,cl
    283d:	jne    285d <botlish_fn_24+0x1fd>
    2843:	mov    rdi,rbx
    2846:	mov    rax,QWORD PTR [rdi+0x10]
    284a:	mov    rcx,QWORD PTR [rax+0x20]
    284e:	mov    edx,0x8
    2853:	call   2858 <botlish_fn_24+0x1f8>
			2854: R_X86_64_PLT32	rt_type_error-0x4
    2858:	jmp    2a10 <botlish_fn_24+0x3b0>
    285d:	mov    ecx,0xa
    2862:	mov    rdx,r13
    2865:	mov    rdi,rbx
    2868:	call   286d <botlish_fn_24+0x20d>
			2869: R_X86_64_PLT32	rt_mutarray_set-0x4
    286d:	test   rax,rax
    2870:	je     2a10 <botlish_fn_24+0x3b0>
    2876:	mov    QWORD PTR [rsp+0x8],0x7
    287f:	mov    rsi,r12
    2882:	mov    rdi,rbx
    2885:	call   288a <botlish_fn_24+0x22a>
			2886: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    288a:	test   rax,rax
    288d:	je     2a10 <botlish_fn_24+0x3b0>
    2893:	mov    QWORD PTR [rsp+0x10],rax
    2898:	mov    QWORD PTR [rsp+0x18],0x3
    28a1:	mov    ecx,0x1
    28a6:	test   rax,0x1
    28ac:	je     28ba <botlish_fn_24+0x25a>
    28b2:	mov    rsi,rax
    28b5:	jmp    28de <botlish_fn_24+0x27e>
    28ba:	xor    ecx,ecx
    28bc:	test   rax,0x7
    28c2:	je     28d0 <botlish_fn_24+0x270>
    28c8:	mov    rsi,rax
    28cb:	jmp    28de <botlish_fn_24+0x27e>
    28d0:	movzx  rcx,BYTE PTR [rax]
    28d4:	mov    rsi,rax
    28d7:	rex cmp cl,0x1
    28db:	sete   cl
    28de:	test   cl,cl
    28e0:	jne    28fe <botlish_fn_24+0x29e>
    28e6:	mov    rdi,rbx
    28e9:	mov    rax,QWORD PTR [rdi+0x10]
    28ed:	mov    rcx,QWORD PTR [rax+0x28]
    28f1:	xor    rdx,rdx
    28f4:	call   28f9 <botlish_fn_24+0x299>
			28f5: R_X86_64_PLT32	rt_type_error-0x4
    28f9:	jmp    2a10 <botlish_fn_24+0x3b0>
    28fe:	test   rsi,0x1
    2905:	je     2924 <botlish_fn_24+0x2c4>
    290b:	mov    rcx,rsi
    290e:	sub    rcx,0x3
    2912:	seto   al
    2915:	add    rcx,0x1
    291c:	test   al,al
    291e:	je     2934 <botlish_fn_24+0x2d4>
    2924:	mov    edx,0x3
    2929:	mov    rdi,rbx
    292c:	call   2931 <botlish_fn_24+0x2d1>
			292d: R_X86_64_PLT32	rt_int_sub-0x4
    2931:	mov    rcx,rax
    2934:	mov    edx,0x7
    2939:	mov    rsi,r12
    293c:	mov    rdi,rbx
    293f:	call   2944 <botlish_fn_24+0x2e4>
			2940: R_X86_64_PLT32	rt_mutarray_set-0x4
    2944:	test   rax,rax
    2947:	je     2a10 <botlish_fn_24+0x3b0>
    294d:	mov    QWORD PTR [rsp+0x8],0x9
    2956:	mov    rsi,r12
    2959:	mov    rdi,rbx
    295c:	call   2961 <botlish_fn_24+0x301>
			295d: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2961:	test   rax,rax
    2964:	je     2a10 <botlish_fn_24+0x3b0>
    296a:	mov    QWORD PTR [rsp+0x10],rax
    296f:	mov    QWORD PTR [rsp+0x18],0x3
    2978:	mov    ecx,0x1
    297d:	test   rax,0x1
    2983:	jne    29a2 <botlish_fn_24+0x342>
    2989:	xor    ecx,ecx
    298b:	test   rax,0x7
    2991:	jne    29a2 <botlish_fn_24+0x342>
    2997:	movzx  rsi,BYTE PTR [rax]
    299b:	cmp    sil,0x1
    299f:	sete   cl
    29a2:	test   cl,cl
    29a4:	jne    29c5 <botlish_fn_24+0x365>
    29aa:	mov    rdi,rbx
    29ad:	mov    r8,QWORD PTR [rdi+0x10]
    29b1:	mov    rcx,QWORD PTR [r8+0x10]
    29b5:	xor    rdx,rdx
    29b8:	mov    rsi,rax
    29bb:	call   29c0 <botlish_fn_24+0x360>
			29bc: R_X86_64_PLT32	rt_type_error-0x4
    29c0:	jmp    2a10 <botlish_fn_24+0x3b0>
    29c5:	mov    rsi,rax
    29c8:	test   rsi,0x1
    29cf:	je     29e7 <botlish_fn_24+0x387>
    29d5:	mov    rcx,rsi
    29d8:	add    rcx,0x2
    29dc:	seto   al
    29df:	test   al,al
    29e1:	je     29f7 <botlish_fn_24+0x397>
    29e7:	mov    edx,0x3
    29ec:	mov    rdi,rbx
    29ef:	call   29f4 <botlish_fn_24+0x394>
			29f0: R_X86_64_PLT32	rt_int_add-0x4
    29f4:	mov    rcx,rax
    29f7:	mov    edx,0x9
    29fc:	mov    rsi,r12
    29ff:	mov    rdi,rbx
    2a02:	call   2a07 <botlish_fn_24+0x3a7>
			2a03: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a07:	test   rax,rax
    2a0a:	jne    2a2b <botlish_fn_24+0x3cb>
    2a10:	xor    rax,rax
    2a13:	mov    rbx,QWORD PTR [rsp+0x20]
    2a18:	mov    r12,QWORD PTR [rsp+0x28]
    2a1d:	mov    r13,QWORD PTR [rsp+0x30]
    2a22:	add    rsp,0x40
    2a26:	mov    rsp,rbp
    2a29:	pop    rbp
    2a2a:	ret
    2a2b:	mov    eax,0xa
    2a30:	mov    rbx,QWORD PTR [rsp+0x20]
    2a35:	mov    r12,QWORD PTR [rsp+0x28]
    2a3a:	mov    r13,QWORD PTR [rsp+0x30]
    2a3f:	add    rsp,0x40
    2a43:	mov    rsp,rbp
    2a46:	pop    rbp
    2a47:	ret
    2a48:	mov    eax,0xa
    2a4d:	mov    rbx,QWORD PTR [rsp+0x20]
    2a52:	mov    r12,QWORD PTR [rsp+0x28]
    2a57:	mov    r13,QWORD PTR [rsp+0x30]
    2a5c:	add    rsp,0x40
    2a60:	mov    rsp,rbp
    2a63:	pop    rbp
    2a64:	ret
    2a65:	add    BYTE PTR [rax],al
    2a67:	add    BYTE PTR [rsi],al
    2a69:	add    BYTE PTR [rax],al
    2a6b:	add    BYTE PTR [rax],al
    2a6d:	add    BYTE PTR [rax],al
	...

0000000000002a70 <botlish_entry_24: ht_delete<mutarray, str>>:
    2a70:	push   rbp
    2a71:	mov    rbp,rsp
    2a74:	mov    rsi,QWORD PTR [rdx]
    2a77:	mov    rdx,QWORD PTR [rdx+0x8]
    2a7b:	call   2a80 <botlish_entry_24+0x10>
			2a7c: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2a80:	mov    rsp,rbp
    2a83:	pop    rbp
    2a84:	ret
    2a85:	add    BYTE PTR [rax],al
	...

0000000000002a88 <botlish_fn_25: sample<generic>>:
    2a88:	push   rbp
    2a89:	mov    rbp,rsp
    2a8c:	sub    rsp,0xa0
    2a93:	mov    QWORD PTR [rsp+0x70],rbx
    2a98:	mov    QWORD PTR [rsp+0x78],r12
    2a9d:	mov    QWORD PTR [rsp+0x80],r13
    2aa5:	mov    QWORD PTR [rsp+0x88],r14
    2aad:	mov    QWORD PTR [rsp+0x90],r15
    2ab5:	mov    r14,rdi
    2ab8:	mov    QWORD PTR [rsp],0x0
    2ac0:	mov    QWORD PTR [rsp+0x8],0x0
    2ac9:	mov    QWORD PTR [rsp+0x10],0x0
    2ad2:	mov    QWORD PTR [rsp+0x18],0x0
    2adb:	mov    QWORD PTR [rsp+0x20],0x0
    2ae4:	mov    QWORD PTR [rsp+0x28],0x0
    2aed:	mov    rdi,r14
    2af0:	call   2af5 <botlish_fn_25+0x6d>
			2af1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    2af5:	mov    rcx,rax
    2af8:	mov    r15,rax
    2afb:	test   rax,rcx
    2afe:	je     2d3e <botlish_fn_25+0x2b6>
    2b04:	mov    rax,r15
    2b07:	mov    QWORD PTR [rsp],rax
    2b0b:	mov    rdi,r14
    2b0e:	mov    rax,QWORD PTR [rdi+0x10]
    2b12:	mov    rdx,QWORD PTR [rax+0x30]
    2b16:	mov    QWORD PTR [rsp+0x8],rdx
    2b1b:	mov    rax,QWORD PTR [rdi+0x10]
    2b1f:	mov    rcx,QWORD PTR [rax+0x38]
    2b23:	mov    QWORD PTR [rsp+0x10],rcx
    2b28:	mov    rsi,r15
    2b2b:	call   2b30 <botlish_fn_25+0xa8>
			2b2c: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2b30:	test   rax,rax
    2b33:	je     2d3e <botlish_fn_25+0x2b6>
    2b39:	mov    rdi,r14
    2b3c:	mov    rsi,QWORD PTR [rdi+0x10]
    2b40:	mov    rdx,QWORD PTR [rsi+0x40]
    2b44:	mov    QWORD PTR [rsp+0x8],rdx
    2b49:	mov    rsi,QWORD PTR [rdi+0x10]
    2b4d:	mov    rcx,QWORD PTR [rsi+0x48]
    2b51:	mov    QWORD PTR [rsp+0x10],rcx
    2b56:	mov    rsi,r15
    2b59:	call   2b5e <botlish_fn_25+0xd6>
			2b5a: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2b5e:	test   rax,rax
    2b61:	je     2d3e <botlish_fn_25+0x2b6>
    2b67:	mov    rdi,r14
    2b6a:	mov    r9,QWORD PTR [rdi+0x10]
    2b6e:	mov    rdx,QWORD PTR [r9+0x30]
    2b72:	mov    QWORD PTR [rsp+0x8],rdx
    2b77:	mov    r10,QWORD PTR [rdi+0x10]
    2b7b:	mov    rcx,QWORD PTR [r10+0x50]
    2b7f:	mov    QWORD PTR [rsp+0x10],rcx
    2b84:	mov    rsi,r15
    2b87:	call   2b8c <botlish_fn_25+0x104>
			2b88: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2b8c:	test   rax,rax
    2b8f:	je     2d3e <botlish_fn_25+0x2b6>
    2b95:	mov    rdi,r14
    2b98:	mov    rax,QWORD PTR [rdi+0x10]
    2b9c:	mov    rdx,QWORD PTR [rax+0x40]
    2ba0:	mov    QWORD PTR [rsp+0x8],rdx
    2ba5:	mov    rsi,r15
    2ba8:	call   2bad <botlish_fn_25+0x125>
			2ba9: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2bad:	mov    rbx,rax
    2bb0:	test   rbx,rbx
    2bb3:	je     2d3e <botlish_fn_25+0x2b6>
    2bb9:	mov    QWORD PTR [rsp+0x8],rbx
    2bbe:	mov    rdi,r14
    2bc1:	mov    rax,QWORD PTR [rdi+0x10]
    2bc5:	mov    rdx,QWORD PTR [rax+0x40]
    2bc9:	mov    QWORD PTR [rsp+0x10],rdx
    2bce:	mov    rsi,r15
    2bd1:	call   2bd6 <botlish_fn_25+0x14e>
			2bd2: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2bd6:	test   rax,rax
    2bd9:	je     2d3e <botlish_fn_25+0x2b6>
    2bdf:	mov    rdi,r14
    2be2:	mov    rax,QWORD PTR [rdi+0x10]
    2be6:	mov    rdx,QWORD PTR [rax+0x30]
    2bea:	mov    QWORD PTR [rsp+0x10],rdx
    2bef:	mov    rsi,r15
    2bf2:	call   2bf7 <botlish_fn_25+0x16f>
			2bf3: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2bf7:	test   rax,rax
    2bfa:	je     2d3e <botlish_fn_25+0x2b6>
    2c00:	mov    rdi,r14
    2c03:	mov    rcx,QWORD PTR [rdi+0x10]
    2c07:	mov    rdx,QWORD PTR [rcx+0x50]
    2c0b:	mov    rcx,rax
    2c0e:	and    rcx,rdx
    2c11:	mov    rsi,rax
    2c14:	test   rcx,0x1
    2c1b:	jne    2c37 <botlish_fn_25+0x1af>
    2c21:	mov    rdi,r14
    2c24:	call   2c29 <botlish_fn_25+0x1a1>
			2c25: R_X86_64_PLT32	rt_value_eq-0x4
    2c29:	test   rax,rax
    2c2c:	je     2d3e <botlish_fn_25+0x2b6>
    2c32:	jmp    2c47 <botlish_fn_25+0x1bf>
    2c37:	mov    eax,0x2
    2c3c:	cmp    rsi,rdx
    2c3f:	cmove  rax,QWORD PTR [rip+0x159]        # 2da0 <botlish_fn_25+0x318>
    2c47:	mov    QWORD PTR [rsp+0x10],rax
    2c4c:	mov    rdi,r14
    2c4f:	mov    QWORD PTR [rsp+0x60],rax
    2c54:	mov    rax,QWORD PTR [rdi+0x10]
    2c58:	mov    rdx,QWORD PTR [rax+0x40]
    2c5c:	mov    QWORD PTR [rsp+0x18],rdx
    2c61:	mov    rsi,r15
    2c64:	call   2c69 <botlish_fn_25+0x1e1>
			2c65: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2c69:	mov    r12,rax
    2c6c:	test   r12,r12
    2c6f:	je     2d3e <botlish_fn_25+0x2b6>
    2c75:	mov    QWORD PTR [rsp+0x18],r12
    2c7a:	mov    rdi,r14
    2c7d:	mov    rax,QWORD PTR [rdi+0x10]
    2c81:	mov    rdx,QWORD PTR [rax+0x58]
    2c85:	mov    QWORD PTR [rsp+0x20],rdx
    2c8a:	mov    rsi,r15
    2c8d:	call   2c92 <botlish_fn_25+0x20a>
			2c8e: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2c92:	mov    r13,rax
    2c95:	test   r13,r13
    2c98:	je     2d3e <botlish_fn_25+0x2b6>
    2c9e:	mov    QWORD PTR [rsp+0x20],r13
    2ca3:	mov    rdi,r14
    2ca6:	mov    rax,QWORD PTR [rdi+0x10]
    2caa:	mov    rdx,QWORD PTR [rax+0x58]
    2cae:	mov    QWORD PTR [rsp+0x28],rdx
    2cb3:	mov    rsi,r15
    2cb6:	call   2cbb <botlish_fn_25+0x233>
			2cb7: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2cbb:	test   rax,rax
    2cbe:	mov    rsi,rax
    2cc1:	je     2d3e <botlish_fn_25+0x2b6>
    2cc7:	mov    edx,0xa
    2ccc:	mov    rdi,r14
    2ccf:	call   2cd4 <botlish_fn_25+0x24c>
			2cd0: R_X86_64_PLT32	rt_value_eq-0x4
    2cd4:	test   rax,rax
    2cd7:	je     2d3e <botlish_fn_25+0x2b6>
    2cdd:	mov    QWORD PTR [rsp],rax
    2ce1:	mov    rsi,r15
    2ce4:	mov    r15,rax
    2ce7:	mov    rdi,r14
    2cea:	call   2cef <botlish_fn_25+0x267>
			2ceb: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2cef:	test   rax,rax
    2cf2:	je     2d3e <botlish_fn_25+0x2b6>
    2cf8:	mov    QWORD PTR [rsp+0x28],rax
    2cfd:	lea    rdx,[rsp+0x30]
    2d02:	mov    rsi,QWORD PTR [rsp+0x60]
    2d07:	mov    QWORD PTR [rsp+0x30],rsi
    2d0c:	mov    QWORD PTR [rsp+0x38],rbx
    2d11:	mov    QWORD PTR [rsp+0x40],r12
    2d16:	mov    QWORD PTR [rsp+0x48],r13
    2d1b:	mov    r8,r15
    2d1e:	mov    QWORD PTR [rsp+0x50],r8
    2d23:	mov    QWORD PTR [rsp+0x58],rax
    2d28:	mov    esi,0x6
    2d2d:	mov    rdi,r14
    2d30:	call   2d35 <botlish_fn_25+0x2ad>
			2d31: R_X86_64_PLT32	rt_list_new-0x4
    2d35:	test   rax,rax
    2d38:	jne    2d6f <botlish_fn_25+0x2e7>
    2d3e:	xor    rax,rax
    2d41:	mov    rbx,QWORD PTR [rsp+0x70]
    2d46:	mov    r12,QWORD PTR [rsp+0x78]
    2d4b:	mov    r13,QWORD PTR [rsp+0x80]
    2d53:	mov    r14,QWORD PTR [rsp+0x88]
    2d5b:	mov    r15,QWORD PTR [rsp+0x90]
    2d63:	add    rsp,0xa0
    2d6a:	mov    rsp,rbp
    2d6d:	pop    rbp
    2d6e:	ret
    2d6f:	mov    rbx,QWORD PTR [rsp+0x70]
    2d74:	mov    r12,QWORD PTR [rsp+0x78]
    2d79:	mov    r13,QWORD PTR [rsp+0x80]
    2d81:	mov    r14,QWORD PTR [rsp+0x88]
    2d89:	mov    r15,QWORD PTR [rsp+0x90]
    2d91:	add    rsp,0xa0
    2d98:	mov    rsp,rbp
    2d9b:	pop    rbp
    2d9c:	ret
    2d9d:	add    BYTE PTR [rax],al
    2d9f:	add    BYTE PTR [rsi],al
    2da1:	add    BYTE PTR [rax],al
    2da3:	add    BYTE PTR [rax],al
    2da5:	add    BYTE PTR [rax],al
	...

0000000000002da8 <botlish_entry_25: sample<generic>>:
    2da8:	push   rbp
    2da9:	mov    rbp,rsp
    2dac:	call   2db1 <botlish_entry_25+0x9>
			2dad: R_X86_64_PLT32	botlish_fn_25-0x4 ; sample<generic>
    2db1:	mov    rsp,rbp
    2db4:	pop    rbp
    2db5:	ret

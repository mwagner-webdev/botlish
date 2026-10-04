; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12845  (per function: 45 388 490 70 61 61 61 61 61 167 179 245 804 1248 429 253 380 439 977 766 817 665 1168 836 1189 838 147)
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
;   botlish_fn_25 / botlish_entry_25 -> sample_checks<generic>
;   botlish_fn_26 / botlish_entry_26 -> sample<generic>


hashtable.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_26-0x4 ; sample<generic>
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
     1a0:	sub    rsp,0x60
     1a4:	mov    QWORD PTR [rsp+0x30],rbx
     1a9:	mov    QWORD PTR [rsp+0x38],r12
     1ae:	mov    QWORD PTR [rsp+0x40],r13
     1b3:	mov    QWORD PTR [rsp+0x48],r14
     1b8:	mov    QWORD PTR [rsp+0x50],r15
     1bd:	mov    r12,rdi
     1c0:	mov    QWORD PTR [rsp+0x8],0x0
     1c9:	mov    QWORD PTR [rsp+0x10],0x0
     1d2:	mov    QWORD PTR [rsp+0x18],0x0
     1db:	mov    QWORD PTR [rsp],rsi
     1df:	mov    rbx,rsi
     1e2:	mov    rsi,rbx
     1e5:	mov    rdi,r12
     1e8:	call   1ed <botlish_fn_2+0x51>
			1e9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     1ed:	test   rax,rax
     1f0:	je     27e <botlish_fn_2+0xe2>
     1f6:	mov    QWORD PTR [rsp+0x8],rax
     1fb:	mov    r13,rax
     1fe:	mov    edx,0x1
     203:	mov    QWORD PTR [rsp+0x10],0x1
     20c:	mov    rcx,rbx
     20f:	mov    rsi,r13
     212:	mov    rdi,r12
     215:	call   21a <botlish_fn_2+0x7e>
			216: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
     21a:	test   rax,rax
     21d:	je     27e <botlish_fn_2+0xe2>
     223:	mov    rsi,rbx
     226:	mov    rdi,r12
     229:	call   22e <botlish_fn_2+0x92>
			22a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     22e:	test   rax,rax
     231:	je     27e <botlish_fn_2+0xe2>
     237:	mov    QWORD PTR [rsp+0x10],rax
     23c:	mov    rsi,rbx
     23f:	mov    r14,rax
     242:	mov    rdi,r12
     245:	call   24a <botlish_fn_2+0xae>
			246: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     24a:	test   rax,rax
     24d:	je     27e <botlish_fn_2+0xe2>
     253:	mov    QWORD PTR [rsp],rax
     257:	mov    r15,rax
     25a:	mov    esi,0xb
     25f:	mov    QWORD PTR [rsp+0x18],0xb
     268:	mov    rdi,r12
     26b:	call   270 <botlish_fn_2+0xd4>
			26c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     270:	test   rax,rax
     273:	mov    QWORD PTR [rsp+0x20],rax
     278:	jne    2a3 <botlish_fn_2+0x107>
     27e:	xor    rax,rax
     281:	mov    rbx,QWORD PTR [rsp+0x30]
     286:	mov    r12,QWORD PTR [rsp+0x38]
     28b:	mov    r13,QWORD PTR [rsp+0x40]
     290:	mov    r14,QWORD PTR [rsp+0x48]
     295:	mov    r15,QWORD PTR [rsp+0x50]
     29a:	add    rsp,0x60
     29e:	mov    rsp,rbp
     2a1:	pop    rbp
     2a2:	ret
     2a3:	mov    ebx,0x1
     2a8:	mov    rcx,r13
     2ab:	mov    rdx,rbx
     2ae:	mov    rsi,QWORD PTR [rsp+0x20]
     2b3:	mov    rdi,r12
     2b6:	call   2bb <botlish_fn_2+0x11f>
			2b7: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     2bb:	mov    edx,0x3
     2c0:	mov    rcx,r14
     2c3:	mov    rsi,QWORD PTR [rsp+0x20]
     2c8:	mov    rdi,r12
     2cb:	call   2d0 <botlish_fn_2+0x134>
			2cc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     2d0:	mov    edx,0x5
     2d5:	mov    rcx,r15
     2d8:	mov    rsi,QWORD PTR [rsp+0x20]
     2dd:	mov    rdi,r12
     2e0:	call   2e5 <botlish_fn_2+0x149>
			2e1: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     2e5:	mov    edx,0x7
     2ea:	mov    rcx,rbx
     2ed:	mov    rsi,QWORD PTR [rsp+0x20]
     2f2:	mov    rdi,r12
     2f5:	call   2fa <botlish_fn_2+0x15e>
			2f6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     2fa:	mov    edx,0x9
     2ff:	mov    rcx,rbx
     302:	mov    rdi,r12
     305:	mov    rsi,QWORD PTR [rsp+0x20]
     30a:	call   30f <botlish_fn_2+0x173>
			30b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     30f:	mov    rax,QWORD PTR [rsp+0x20]
     314:	mov    rbx,QWORD PTR [rsp+0x30]
     319:	mov    r12,QWORD PTR [rsp+0x38]
     31e:	mov    r13,QWORD PTR [rsp+0x40]
     323:	mov    r14,QWORD PTR [rsp+0x48]
     328:	mov    r15,QWORD PTR [rsp+0x50]
     32d:	add    rsp,0x60
     331:	mov    rsp,rbp
     334:	pop    rbp
     335:	ret

0000000000000336 <botlish_entry_2: ht_alloc<int>>:
     336:	push   rbp
     337:	mov    rbp,rsp
     33a:	mov    rsi,QWORD PTR [rdx]
     33d:	call   342 <botlish_entry_2+0xc>
			33e: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
     342:	mov    rsp,rbp
     345:	pop    rbp
     346:	ret

0000000000000347 <botlish_fn_3: ht_new<generic>>:
     347:	push   rbp
     348:	mov    rbp,rsp
     34b:	sub    rsp,0x10
     34f:	mov    esi,0x11
     354:	mov    QWORD PTR [rsp],0x11
     35c:	call   361 <botlish_fn_3+0x1a>
			35d: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
     361:	test   rax,rax
     364:	jne    376 <botlish_fn_3+0x2f>
     36a:	xor    rax,rax
     36d:	add    rsp,0x10
     371:	mov    rsp,rbp
     374:	pop    rbp
     375:	ret
     376:	add    rsp,0x10
     37a:	mov    rsp,rbp
     37d:	pop    rbp
     37e:	ret

000000000000037f <botlish_entry_3: ht_new<generic>>:
     37f:	push   rbp
     380:	mov    rbp,rsp
     383:	call   388 <botlish_entry_3+0x9>
			384: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
     388:	mov    rsp,rbp
     38b:	pop    rbp
     38c:	ret

000000000000038d <botlish_fn_4: ht_controls<mutarray>>:
     38d:	push   rbp
     38e:	mov    rbp,rsp
     391:	mov    edx,0x1
     396:	call   39b <botlish_fn_4+0xe>
			397: R_X86_64_PLT32	rt_mutarray_get-0x4
     39b:	test   rax,rax
     39e:	jne    3ac <botlish_fn_4+0x1f>
     3a4:	xor    rax,rax
     3a7:	mov    rsp,rbp
     3aa:	pop    rbp
     3ab:	ret
     3ac:	mov    rsp,rbp
     3af:	pop    rbp
     3b0:	ret

00000000000003b1 <botlish_entry_4: ht_controls<mutarray>>:
     3b1:	push   rbp
     3b2:	mov    rbp,rsp
     3b5:	mov    rsi,QWORD PTR [rdx]
     3b8:	call   3bd <botlish_entry_4+0xc>
			3b9: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     3bd:	mov    rsp,rbp
     3c0:	pop    rbp
     3c1:	ret

00000000000003c2 <botlish_fn_5: ht_keys<mutarray>>:
     3c2:	push   rbp
     3c3:	mov    rbp,rsp
     3c6:	mov    edx,0x3
     3cb:	call   3d0 <botlish_fn_5+0xe>
			3cc: R_X86_64_PLT32	rt_mutarray_get-0x4
     3d0:	test   rax,rax
     3d3:	jne    3e1 <botlish_fn_5+0x1f>
     3d9:	xor    rax,rax
     3dc:	mov    rsp,rbp
     3df:	pop    rbp
     3e0:	ret
     3e1:	mov    rsp,rbp
     3e4:	pop    rbp
     3e5:	ret

00000000000003e6 <botlish_entry_5: ht_keys<mutarray>>:
     3e6:	push   rbp
     3e7:	mov    rbp,rsp
     3ea:	mov    rsi,QWORD PTR [rdx]
     3ed:	call   3f2 <botlish_entry_5+0xc>
			3ee: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     3f2:	mov    rsp,rbp
     3f5:	pop    rbp
     3f6:	ret

00000000000003f7 <botlish_fn_6: ht_values<mutarray>>:
     3f7:	push   rbp
     3f8:	mov    rbp,rsp
     3fb:	mov    edx,0x5
     400:	call   405 <botlish_fn_6+0xe>
			401: R_X86_64_PLT32	rt_mutarray_get-0x4
     405:	test   rax,rax
     408:	jne    416 <botlish_fn_6+0x1f>
     40e:	xor    rax,rax
     411:	mov    rsp,rbp
     414:	pop    rbp
     415:	ret
     416:	mov    rsp,rbp
     419:	pop    rbp
     41a:	ret

000000000000041b <botlish_entry_6: ht_values<mutarray>>:
     41b:	push   rbp
     41c:	mov    rbp,rsp
     41f:	mov    rsi,QWORD PTR [rdx]
     422:	call   427 <botlish_entry_6+0xc>
			423: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
     427:	mov    rsp,rbp
     42a:	pop    rbp
     42b:	ret

000000000000042c <botlish_fn_7: ht_size<mutarray>>:
     42c:	push   rbp
     42d:	mov    rbp,rsp
     430:	mov    edx,0x7
     435:	call   43a <botlish_fn_7+0xe>
			436: R_X86_64_PLT32	rt_mutarray_get-0x4
     43a:	test   rax,rax
     43d:	jne    44b <botlish_fn_7+0x1f>
     443:	xor    rax,rax
     446:	mov    rsp,rbp
     449:	pop    rbp
     44a:	ret
     44b:	mov    rsp,rbp
     44e:	pop    rbp
     44f:	ret

0000000000000450 <botlish_entry_7: ht_size<mutarray>>:
     450:	push   rbp
     451:	mov    rbp,rsp
     454:	mov    rsi,QWORD PTR [rdx]
     457:	call   45c <botlish_entry_7+0xc>
			458: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
     45c:	mov    rsp,rbp
     45f:	pop    rbp
     460:	ret

0000000000000461 <botlish_fn_8: ht_tombstones<mutarray>>:
     461:	push   rbp
     462:	mov    rbp,rsp
     465:	mov    edx,0x9
     46a:	call   46f <botlish_fn_8+0xe>
			46b: R_X86_64_PLT32	rt_mutarray_get-0x4
     46f:	test   rax,rax
     472:	jne    480 <botlish_fn_8+0x1f>
     478:	xor    rax,rax
     47b:	mov    rsp,rbp
     47e:	pop    rbp
     47f:	ret
     480:	mov    rsp,rbp
     483:	pop    rbp
     484:	ret

0000000000000485 <botlish_entry_8: ht_tombstones<mutarray>>:
     485:	push   rbp
     486:	mov    rbp,rsp
     489:	mov    rsi,QWORD PTR [rdx]
     48c:	call   491 <botlish_entry_8+0xc>
			48d: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
     491:	mov    rsp,rbp
     494:	pop    rbp
     495:	ret

0000000000000496 <botlish_fn_9: ht_capacity<mutarray>>:
     496:	push   rbp
     497:	mov    rbp,rsp
     49a:	sub    rsp,0x10
     49e:	mov    QWORD PTR [rsp],rbx
     4a2:	mov    rbx,rdi
     4a5:	mov    rdi,rbx
     4a8:	call   4ad <botlish_fn_9+0x17>
			4a9: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     4ad:	test   rax,rax
     4b0:	je     4f9 <botlish_fn_9+0x63>
     4b6:	xor    r8d,r8d
     4b9:	test   rax,0x7
     4bf:	je     4cd <botlish_fn_9+0x37>
     4c5:	mov    rsi,rax
     4c8:	jmp    4dc <botlish_fn_9+0x46>
     4cd:	movzx  rcx,BYTE PTR [rax]
     4d1:	mov    rsi,rax
     4d4:	rex cmp cl,0x8
     4d8:	sete   r8b
     4dc:	test   r8b,r8b
     4df:	jne    509 <botlish_fn_9+0x73>
     4e5:	mov    rdi,rbx
     4e8:	mov    rax,QWORD PTR [rdi+0x10]
     4ec:	mov    rcx,QWORD PTR [rax]
     4ef:	mov    edx,0x8
     4f4:	call   4f9 <botlish_fn_9+0x63>
			4f5: R_X86_64_PLT32	rt_type_error-0x4
     4f9:	xor    rax,rax
     4fc:	mov    rbx,QWORD PTR [rsp]
     500:	add    rsp,0x10
     504:	mov    rsp,rbp
     507:	pop    rbp
     508:	ret
     509:	mov    rdi,rbx
     50c:	call   511 <botlish_fn_9+0x7b>
			50d: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     511:	mov    rbx,QWORD PTR [rsp]
     515:	add    rsp,0x10
     519:	mov    rsp,rbp
     51c:	pop    rbp
     51d:	ret

000000000000051e <botlish_entry_9: ht_capacity<mutarray>>:
     51e:	push   rbp
     51f:	mov    rbp,rsp
     522:	mov    rsi,QWORD PTR [rdx]
     525:	call   52a <botlish_entry_9+0xc>
			526: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     52a:	mov    rsp,rbp
     52d:	pop    rbp
     52e:	ret

000000000000052f <botlish_fn_10: ht_probe_start<mutarray, str>>:
     52f:	push   rbp
     530:	mov    rbp,rsp
     533:	sub    rsp,0x20
     537:	mov    QWORD PTR [rsp],r12
     53b:	mov    QWORD PTR [rsp+0x8],r13
     540:	mov    QWORD PTR [rsp+0x10],r14
     545:	mov    r12,rdi
     548:	mov    r14,rsi
     54b:	mov    rsi,rdx
     54e:	mov    rdi,r12
     551:	call   556 <botlish_fn_10+0x27>
			552: R_X86_64_PLT32	rt_hash-0x4
     556:	test   rax,rax
     559:	mov    r13,rax
     55c:	je     58d <botlish_fn_10+0x5e>
     562:	mov    rsi,r14
     565:	mov    rdi,r12
     568:	call   56d <botlish_fn_10+0x3e>
			569: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     56d:	test   rax,rax
     570:	mov    rdx,rax
     573:	je     58d <botlish_fn_10+0x5e>
     579:	mov    rsi,r13
     57c:	mov    rdi,r12
     57f:	call   584 <botlish_fn_10+0x55>
			580: R_X86_64_PLT32	rt_int_mod-0x4
     584:	test   rax,rax
     587:	jne    5a7 <botlish_fn_10+0x78>
     58d:	xor    rax,rax
     590:	mov    r12,QWORD PTR [rsp]
     594:	mov    r13,QWORD PTR [rsp+0x8]
     599:	mov    r14,QWORD PTR [rsp+0x10]
     59e:	add    rsp,0x20
     5a2:	mov    rsp,rbp
     5a5:	pop    rbp
     5a6:	ret
     5a7:	mov    r12,QWORD PTR [rsp]
     5ab:	mov    r13,QWORD PTR [rsp+0x8]
     5b0:	mov    r14,QWORD PTR [rsp+0x10]
     5b5:	add    rsp,0x20
     5b9:	mov    rsp,rbp
     5bc:	pop    rbp
     5bd:	ret

00000000000005be <botlish_entry_10: ht_probe_start<mutarray, str>>:
     5be:	push   rbp
     5bf:	mov    rbp,rsp
     5c2:	mov    rsi,QWORD PTR [rdx]
     5c5:	mov    rdx,QWORD PTR [rdx+0x8]
     5c9:	call   5ce <botlish_entry_10+0x10>
			5ca: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
     5ce:	mov    rsp,rbp
     5d1:	pop    rbp
     5d2:	ret

00000000000005d3 <botlish_fn_11: ht_probe_next<mutarray, int>>:
     5d3:	push   rbp
     5d4:	mov    rbp,rsp
     5d7:	sub    rsp,0x40
     5db:	mov    QWORD PTR [rsp+0x20],rbx
     5e0:	mov    QWORD PTR [rsp+0x28],r12
     5e5:	mov    QWORD PTR [rsp+0x30],r13
     5ea:	mov    r13,rdi
     5ed:	mov    QWORD PTR [rsp],rsi
     5f1:	mov    rbx,rsi
     5f4:	mov    QWORD PTR [rsp+0x8],rdx
     5f9:	mov    QWORD PTR [rsp+0x10],0x3
     602:	test   rdx,0x1
     609:	jne    617 <botlish_fn_11+0x44>
     60f:	mov    rsi,rdx
     612:	jmp    637 <botlish_fn_11+0x64>
     617:	mov    rsi,rdx
     61a:	add    rsi,0x2
     61e:	mov    r12,rsi
     621:	mov    rsi,rdx
     624:	seto   al
     627:	test   al,al
     629:	jne    637 <botlish_fn_11+0x64>
     62f:	mov    rsi,rbx
     632:	jmp    64a <botlish_fn_11+0x77>
     637:	mov    edx,0x3
     63c:	mov    rdi,r13
     63f:	call   644 <botlish_fn_11+0x71>
			640: R_X86_64_PLT32	rt_int_add-0x4
     644:	mov    rsi,rbx
     647:	mov    r12,rax
     64a:	mov    rdi,r13
     64d:	call   652 <botlish_fn_11+0x7f>
			64e: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     652:	test   rax,rax
     655:	mov    rdx,rax
     658:	je     672 <botlish_fn_11+0x9f>
     65e:	mov    rsi,r12
     661:	mov    rdi,r13
     664:	call   669 <botlish_fn_11+0x96>
			665: R_X86_64_PLT32	rt_int_mod-0x4
     669:	test   rax,rax
     66c:	jne    68d <botlish_fn_11+0xba>
     672:	xor    rax,rax
     675:	mov    rbx,QWORD PTR [rsp+0x20]
     67a:	mov    r12,QWORD PTR [rsp+0x28]
     67f:	mov    r13,QWORD PTR [rsp+0x30]
     684:	add    rsp,0x40
     688:	mov    rsp,rbp
     68b:	pop    rbp
     68c:	ret
     68d:	mov    rbx,QWORD PTR [rsp+0x20]
     692:	mov    r12,QWORD PTR [rsp+0x28]
     697:	mov    r13,QWORD PTR [rsp+0x30]
     69c:	add    rsp,0x40
     6a0:	mov    rsp,rbp
     6a3:	pop    rbp
     6a4:	ret

00000000000006a5 <botlish_entry_11: ht_probe_next<mutarray, int>>:
     6a5:	push   rbp
     6a6:	mov    rbp,rsp
     6a9:	mov    rsi,QWORD PTR [rdx]
     6ac:	mov    rdx,QWORD PTR [rdx+0x8]
     6b0:	call   6b5 <botlish_entry_11+0x10>
			6b1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     6b5:	mov    rsp,rbp
     6b8:	pop    rbp
     6b9:	ret
     6ba:	add    BYTE PTR [rax],al
     6bc:	add    BYTE PTR [rax],al
	...

00000000000006c0 <botlish_fn_12: ht_find_get<mutarray, str, int>>:
     6c0:	push   rbp
     6c1:	mov    rbp,rsp
     6c4:	sub    rsp,0x50
     6c8:	mov    QWORD PTR [rsp+0x20],rbx
     6cd:	mov    QWORD PTR [rsp+0x28],r12
     6d2:	mov    QWORD PTR [rsp+0x30],r13
     6d7:	mov    QWORD PTR [rsp+0x38],r14
     6dc:	mov    QWORD PTR [rsp+0x40],r15
     6e1:	mov    r14,rdi
     6e4:	mov    QWORD PTR [rsp],rsi
     6e8:	mov    QWORD PTR [rsp+0x8],rdx
     6ed:	mov    r13,rdx
     6f0:	mov    QWORD PTR [rsp+0x10],rcx
     6f5:	mov    r12,rsi
     6f8:	mov    r15,rcx
     6fb:	mov    rsi,r12
     6fe:	mov    rdi,r14
     701:	call   706 <botlish_fn_12+0x46>
			702: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     706:	test   rax,rax
     709:	je     908 <botlish_fn_12+0x248>
     70f:	xor    ecx,ecx
     711:	test   rax,0x7
     717:	je     725 <botlish_fn_12+0x65>
     71d:	mov    rsi,rax
     720:	jmp    733 <botlish_fn_12+0x73>
     725:	movzx  rcx,BYTE PTR [rax]
     729:	mov    rsi,rax
     72c:	rex cmp cl,0x8
     730:	sete   cl
     733:	test   cl,cl
     735:	jne    755 <botlish_fn_12+0x95>
     73b:	mov    rdi,r14
     73e:	mov    rdx,QWORD PTR [rdi+0x10]
     742:	mov    rcx,QWORD PTR [rdx+0x8]
     746:	mov    edx,0x8
     74b:	call   750 <botlish_fn_12+0x90>
			74c: R_X86_64_PLT32	rt_type_error-0x4
     750:	jmp    908 <botlish_fn_12+0x248>
     755:	mov    rdx,r15
     758:	mov    rdi,r14
     75b:	call   760 <botlish_fn_12+0xa0>
			75c: R_X86_64_PLT32	rt_mutarray_get-0x4
     760:	mov    rcx,rax
     763:	mov    QWORD PTR [rsp+0x18],rax
     768:	test   rax,rcx
     76b:	je     908 <botlish_fn_12+0x248>
     771:	mov    rax,QWORD PTR [rsp+0x18]
     776:	test   rax,0x1
     77c:	jne    7a7 <botlish_fn_12+0xe7>
     782:	mov    edx,0x1
     787:	mov    rsi,QWORD PTR [rsp+0x18]
     78c:	mov    rdi,r14
     78f:	call   794 <botlish_fn_12+0xd4>
			790: R_X86_64_PLT32	rt_value_eq-0x4
     794:	test   rax,rax
     797:	je     908 <botlish_fn_12+0x248>
     79d:	mov    rcx,QWORD PTR [rsp+0x18]
     7a2:	jmp    7bd <botlish_fn_12+0xfd>
     7a7:	mov    eax,0x2
     7ac:	mov    rcx,QWORD PTR [rsp+0x18]
     7b1:	cmp    rcx,0x1
     7b5:	cmove  rax,QWORD PTR [rip+0x1db]        # 998 <botlish_fn_12+0x2d8>
     7bd:	mov    ebx,0x6
     7c2:	cmp    rax,0x6
     7c6:	je     968 <botlish_fn_12+0x2a8>
     7cc:	test   rcx,0x1
     7d3:	mov    QWORD PTR [rsp+0x18],rcx
     7d8:	jne    7fe <botlish_fn_12+0x13e>
     7de:	mov    edx,0x3
     7e3:	mov    rsi,QWORD PTR [rsp+0x18]
     7e8:	mov    rdi,r14
     7eb:	call   7f0 <botlish_fn_12+0x130>
			7ec: R_X86_64_PLT32	rt_value_eq-0x4
     7f0:	test   rax,rax
     7f3:	je     908 <botlish_fn_12+0x248>
     7f9:	jmp    814 <botlish_fn_12+0x154>
     7fe:	mov    rsi,QWORD PTR [rsp+0x18]
     803:	mov    eax,0x2
     808:	cmp    rsi,0x3
     80c:	cmove  rax,QWORD PTR [rip+0x184]        # 998 <botlish_fn_12+0x2d8>
     814:	cmp    rax,0x6
     818:	je     828 <botlish_fn_12+0x168>
     81e:	mov    ebx,0x2
     823:	jmp    8e7 <botlish_fn_12+0x227>
     828:	mov    rsi,r12
     82b:	mov    rdi,r14
     82e:	call   833 <botlish_fn_12+0x173>
			82f: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     833:	test   rax,rax
     836:	je     908 <botlish_fn_12+0x248>
     83c:	xor    r10d,r10d
     83f:	test   rax,0x7
     845:	je     853 <botlish_fn_12+0x193>
     84b:	mov    rsi,rax
     84e:	jmp    862 <botlish_fn_12+0x1a2>
     853:	movzx  rcx,BYTE PTR [rax]
     857:	mov    rsi,rax
     85a:	rex cmp cl,0x8
     85e:	sete   r10b
     862:	test   r10b,r10b
     865:	jne    885 <botlish_fn_12+0x1c5>
     86b:	mov    rdi,r14
     86e:	mov    rax,QWORD PTR [rdi+0x10]
     872:	mov    rcx,QWORD PTR [rax+0x8]
     876:	mov    edx,0x8
     87b:	call   880 <botlish_fn_12+0x1c0>
			87c: R_X86_64_PLT32	rt_type_error-0x4
     880:	jmp    908 <botlish_fn_12+0x248>
     885:	mov    rdx,r15
     888:	mov    rdi,r14
     88b:	call   890 <botlish_fn_12+0x1d0>
			88c: R_X86_64_PLT32	rt_mutarray_get-0x4
     890:	test   rax,rax
     893:	je     908 <botlish_fn_12+0x248>
     899:	mov    rcx,rax
     89c:	and    rcx,r13
     89f:	mov    rsi,rax
     8a2:	test   rcx,0x1
     8a9:	jne    8c8 <botlish_fn_12+0x208>
     8af:	mov    rdx,r13
     8b2:	mov    rdi,r14
     8b5:	call   8ba <botlish_fn_12+0x1fa>
			8b6: R_X86_64_PLT32	rt_value_eq-0x4
     8ba:	test   rax,rax
     8bd:	je     908 <botlish_fn_12+0x248>
     8c3:	jmp    8d8 <botlish_fn_12+0x218>
     8c8:	mov    eax,0x2
     8cd:	cmp    rsi,r13
     8d0:	cmove  rax,QWORD PTR [rip+0xc0]        # 998 <botlish_fn_12+0x2d8>
     8d8:	cmp    rax,0x6
     8dc:	je     8e7 <botlish_fn_12+0x227>
     8e2:	mov    ebx,0x2
     8e7:	cmp    rbx,0x6
     8eb:	je     943 <botlish_fn_12+0x283>
     8f1:	mov    rdx,r15
     8f4:	mov    rsi,r12
     8f7:	mov    rdi,r14
     8fa:	call   8ff <botlish_fn_12+0x23f>
			8fb: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     8ff:	test   rax,rax
     902:	jne    92d <botlish_fn_12+0x26d>
     908:	xor    rax,rax
     90b:	mov    rbx,QWORD PTR [rsp+0x20]
     910:	mov    r12,QWORD PTR [rsp+0x28]
     915:	mov    r13,QWORD PTR [rsp+0x30]
     91a:	mov    r14,QWORD PTR [rsp+0x38]
     91f:	mov    r15,QWORD PTR [rsp+0x40]
     924:	add    rsp,0x50
     928:	mov    rsp,rbp
     92b:	pop    rbp
     92c:	ret
     92d:	mov    QWORD PTR [rsp],r12
     931:	mov    QWORD PTR [rsp+0x8],r13
     936:	mov    QWORD PTR [rsp+0x10],rax
     93b:	mov    r15,rax
     93e:	jmp    6fb <botlish_fn_12+0x3b>
     943:	mov    rax,r15
     946:	mov    rbx,QWORD PTR [rsp+0x20]
     94b:	mov    r12,QWORD PTR [rsp+0x28]
     950:	mov    r13,QWORD PTR [rsp+0x30]
     955:	mov    r14,QWORD PTR [rsp+0x38]
     95a:	mov    r15,QWORD PTR [rsp+0x40]
     95f:	add    rsp,0x50
     963:	mov    rsp,rbp
     966:	pop    rbp
     967:	ret
     968:	mov    rax,0xffffffffffffffff
     96f:	mov    rbx,QWORD PTR [rsp+0x20]
     974:	mov    r12,QWORD PTR [rsp+0x28]
     979:	mov    r13,QWORD PTR [rsp+0x30]
     97e:	mov    r14,QWORD PTR [rsp+0x38]
     983:	mov    r15,QWORD PTR [rsp+0x40]
     988:	add    rsp,0x50
     98c:	mov    rsp,rbp
     98f:	pop    rbp
     990:	ret
     991:	add    BYTE PTR [rax],al
     993:	add    BYTE PTR [rax],al
     995:	add    BYTE PTR [rax],al
     997:	add    BYTE PTR [rsi],al
     999:	add    BYTE PTR [rax],al
     99b:	add    BYTE PTR [rax],al
     99d:	add    BYTE PTR [rax],al
	...

00000000000009a0 <botlish_entry_12: ht_find_get<mutarray, str, int>>:
     9a0:	push   rbp
     9a1:	mov    rbp,rsp
     9a4:	mov    rsi,QWORD PTR [rdx]
     9a7:	mov    r8,QWORD PTR [rdx+0x8]
     9ab:	mov    rcx,QWORD PTR [rdx+0x10]
     9af:	mov    rdx,r8
     9b2:	call   9b7 <botlish_entry_12+0x17>
			9b3: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
     9b7:	mov    rsp,rbp
     9ba:	pop    rbp
     9bb:	ret
     9bc:	add    BYTE PTR [rax],al
	...

00000000000009c0 <botlish_fn_13: ht_find_insert<mutarray, str, int, int>>:
     9c0:	push   rbp
     9c1:	mov    rbp,rsp
     9c4:	sub    rsp,0x60
     9c8:	mov    QWORD PTR [rsp+0x30],rbx
     9cd:	mov    QWORD PTR [rsp+0x38],r12
     9d2:	mov    QWORD PTR [rsp+0x40],r13
     9d7:	mov    QWORD PTR [rsp+0x48],r14
     9dc:	mov    QWORD PTR [rsp+0x50],r15
     9e1:	mov    r15,rdi
     9e4:	mov    QWORD PTR [rsp],rsi
     9e8:	mov    QWORD PTR [rsp+0x8],rdx
     9ed:	mov    r13,rdx
     9f0:	mov    QWORD PTR [rsp+0x10],rcx
     9f5:	mov    QWORD PTR [rsp+0x18],r8
     9fa:	mov    rbx,rsi
     9fd:	mov    QWORD PTR [rsp+0x20],rcx
     a02:	mov    QWORD PTR [rsp+0x28],r8
     a07:	mov    rsi,rbx
     a0a:	mov    rdi,r15
     a0d:	call   a12 <botlish_fn_13+0x52>
			a0e: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     a12:	test   rax,rax
     a15:	je     d0d <botlish_fn_13+0x34d>
     a1b:	xor    ecx,ecx
     a1d:	test   rax,0x7
     a23:	je     a31 <botlish_fn_13+0x71>
     a29:	mov    rsi,rax
     a2c:	jmp    a3f <botlish_fn_13+0x7f>
     a31:	movzx  rcx,BYTE PTR [rax]
     a35:	mov    rsi,rax
     a38:	rex cmp cl,0x8
     a3c:	sete   cl
     a3f:	test   cl,cl
     a41:	jne    a61 <botlish_fn_13+0xa1>
     a47:	mov    rdi,r15
     a4a:	mov    rax,QWORD PTR [rdi+0x10]
     a4e:	mov    rcx,QWORD PTR [rax+0x8]
     a52:	mov    edx,0x8
     a57:	call   a5c <botlish_fn_13+0x9c>
			a58: R_X86_64_PLT32	rt_type_error-0x4
     a5c:	jmp    d0d <botlish_fn_13+0x34d>
     a61:	mov    rdx,QWORD PTR [rsp+0x20]
     a66:	mov    rdi,r15
     a69:	call   a6e <botlish_fn_13+0xae>
			a6a: R_X86_64_PLT32	rt_mutarray_get-0x4
     a6e:	mov    rsi,rax
     a71:	mov    r14,rax
     a74:	test   rax,rsi
     a77:	je     d0d <botlish_fn_13+0x34d>
     a7d:	mov    rax,r14
     a80:	test   rax,0x1
     a86:	jne    aaa <botlish_fn_13+0xea>
     a8c:	mov    edx,0x1
     a91:	mov    rsi,r14
     a94:	mov    rdi,r15
     a97:	call   a9c <botlish_fn_13+0xdc>
			a98: R_X86_64_PLT32	rt_value_eq-0x4
     a9c:	test   rax,rax
     a9f:	je     d0d <botlish_fn_13+0x34d>
     aa5:	jmp    abe <botlish_fn_13+0xfe>
     aaa:	mov    eax,0x2
     aaf:	mov    rcx,r14
     ab2:	cmp    rcx,0x1
     ab6:	cmove  rax,QWORD PTR [rip+0x372]        # e30 <botlish_fn_13+0x470>
     abe:	mov    r12d,0x6
     ac4:	cmp    rax,0x6
     ac8:	je     d85 <botlish_fn_13+0x3c5>
     ace:	mov    rax,r14
     ad1:	test   rax,0x1
     ad7:	jne    afb <botlish_fn_13+0x13b>
     add:	mov    edx,0x3
     ae2:	mov    rsi,r14
     ae5:	mov    rdi,r15
     ae8:	call   aed <botlish_fn_13+0x12d>
			ae9: R_X86_64_PLT32	rt_value_eq-0x4
     aed:	test   rax,rax
     af0:	je     d0d <botlish_fn_13+0x34d>
     af6:	jmp    b0f <botlish_fn_13+0x14f>
     afb:	mov    eax,0x2
     b00:	mov    rcx,r14
     b03:	cmp    rcx,0x3
     b07:	cmove  rax,QWORD PTR [rip+0x321]        # e30 <botlish_fn_13+0x470>
     b0f:	cmp    rax,0x6
     b13:	je     b24 <botlish_fn_13+0x164>
     b19:	mov    r11d,0x2
     b1f:	jmp    bee <botlish_fn_13+0x22e>
     b24:	mov    rsi,rbx
     b27:	mov    rdi,r15
     b2a:	call   b2f <botlish_fn_13+0x16f>
			b2b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     b2f:	test   rax,rax
     b32:	je     d0d <botlish_fn_13+0x34d>
     b38:	xor    ecx,ecx
     b3a:	test   rax,0x7
     b40:	je     b4e <botlish_fn_13+0x18e>
     b46:	mov    rsi,rax
     b49:	jmp    b5c <botlish_fn_13+0x19c>
     b4e:	movzx  rcx,BYTE PTR [rax]
     b52:	mov    rsi,rax
     b55:	rex cmp cl,0x8
     b59:	sete   cl
     b5c:	test   cl,cl
     b5e:	jne    b7e <botlish_fn_13+0x1be>
     b64:	mov    rdi,r15
     b67:	mov    rcx,QWORD PTR [rdi+0x10]
     b6b:	mov    rcx,QWORD PTR [rcx+0x8]
     b6f:	mov    edx,0x8
     b74:	call   b79 <botlish_fn_13+0x1b9>
			b75: R_X86_64_PLT32	rt_type_error-0x4
     b79:	jmp    d0d <botlish_fn_13+0x34d>
     b7e:	mov    rdx,QWORD PTR [rsp+0x20]
     b83:	mov    rdi,r15
     b86:	call   b8b <botlish_fn_13+0x1cb>
			b87: R_X86_64_PLT32	rt_mutarray_get-0x4
     b8b:	test   rax,rax
     b8e:	je     d0d <botlish_fn_13+0x34d>
     b94:	mov    rsi,rax
     b97:	and    rsi,r13
     b9a:	test   rsi,0x1
     ba1:	jne    bc3 <botlish_fn_13+0x203>
     ba7:	mov    rsi,rax
     baa:	mov    rdx,r13
     bad:	mov    rdi,r15
     bb0:	call   bb5 <botlish_fn_13+0x1f5>
			bb1: R_X86_64_PLT32	rt_value_eq-0x4
     bb5:	test   rax,rax
     bb8:	je     d0d <botlish_fn_13+0x34d>
     bbe:	jmp    bd6 <botlish_fn_13+0x216>
     bc3:	mov    rsi,rax
     bc6:	mov    eax,0x2
     bcb:	cmp    rsi,r13
     bce:	cmove  rax,QWORD PTR [rip+0x25a]        # e30 <botlish_fn_13+0x470>
     bd6:	cmp    rax,0x6
     bda:	je     beb <botlish_fn_13+0x22b>
     be0:	mov    r11d,0x2
     be6:	jmp    bee <botlish_fn_13+0x22e>
     beb:	mov    r11,r12
     bee:	cmp    r11,0x6
     bf2:	je     d5e <botlish_fn_13+0x39e>
     bf8:	mov    rax,r14
     bfb:	test   rax,0x1
     c01:	jne    c25 <botlish_fn_13+0x265>
     c07:	mov    edx,0x5
     c0c:	mov    rsi,r14
     c0f:	mov    rdi,r15
     c12:	call   c17 <botlish_fn_13+0x257>
			c13: R_X86_64_PLT32	rt_value_eq-0x4
     c17:	test   rax,rax
     c1a:	je     d0d <botlish_fn_13+0x34d>
     c20:	jmp    c39 <botlish_fn_13+0x279>
     c25:	mov    rsi,r14
     c28:	mov    eax,0x2
     c2d:	cmp    rsi,0x5
     c31:	cmove  rax,QWORD PTR [rip+0x1f7]        # e30 <botlish_fn_13+0x470>
     c39:	cmp    rax,0x6
     c3d:	je     c4e <botlish_fn_13+0x28e>
     c43:	mov    r12d,0x2
     c49:	jmp    caf <botlish_fn_13+0x2ef>
     c4e:	mov    r14,QWORD PTR [rsp+0x28]
     c53:	test   r14,0x1
     c5a:	jne    c8a <botlish_fn_13+0x2ca>
     c60:	mov    edx,0x1
     c65:	mov    rsi,r14
     c68:	mov    rdi,r15
     c6b:	call   c70 <botlish_fn_13+0x2b0>
			c6c: R_X86_64_PLT32	rt_int_cmp-0x4
     c70:	mov    ecx,0x2
     c75:	test   rax,rax
     c78:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # e30 <botlish_fn_13+0x470>
     c80:	mov    QWORD PTR [rsp+0x28],r14
     c85:	jmp    c9f <botlish_fn_13+0x2df>
     c8a:	mov    ecx,0x2
     c8f:	test   r14,r14
     c92:	mov    QWORD PTR [rsp+0x28],r14
     c97:	cmovle rcx,QWORD PTR [rip+0x191]        # e30 <botlish_fn_13+0x470>
     c9f:	cmp    rcx,0x6
     ca3:	je     caf <botlish_fn_13+0x2ef>
     ca9:	mov    r12d,0x2
     caf:	cmp    r12,0x6
     cb3:	je     cf4 <botlish_fn_13+0x334>
     cb9:	mov    rdx,QWORD PTR [rsp+0x20]
     cbe:	mov    rsi,rbx
     cc1:	mov    rdi,r15
     cc4:	call   cc9 <botlish_fn_13+0x309>
			cc5: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     cc9:	test   rax,rax
     ccc:	je     d0d <botlish_fn_13+0x34d>
     cd2:	mov    QWORD PTR [rsp],rbx
     cd6:	mov    QWORD PTR [rsp+0x8],r13
     cdb:	mov    QWORD PTR [rsp+0x10],rax
     ce0:	mov    r11,QWORD PTR [rsp+0x28]
     ce5:	mov    QWORD PTR [rsp+0x18],r11
     cea:	mov    QWORD PTR [rsp+0x20],rax
     cef:	jmp    a07 <botlish_fn_13+0x47>
     cf4:	mov    rdx,QWORD PTR [rsp+0x20]
     cf9:	mov    rsi,rbx
     cfc:	mov    rdi,r15
     cff:	call   d04 <botlish_fn_13+0x344>
			d00: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     d04:	test   rax,rax
     d07:	jne    d32 <botlish_fn_13+0x372>
     d0d:	xor    rax,rax
     d10:	mov    rbx,QWORD PTR [rsp+0x30]
     d15:	mov    r12,QWORD PTR [rsp+0x38]
     d1a:	mov    r13,QWORD PTR [rsp+0x40]
     d1f:	mov    r14,QWORD PTR [rsp+0x48]
     d24:	mov    r15,QWORD PTR [rsp+0x50]
     d29:	add    rsp,0x60
     d2d:	mov    rsp,rbp
     d30:	pop    rbp
     d31:	ret
     d32:	mov    QWORD PTR [rsp],rbx
     d36:	mov    QWORD PTR [rsp+0x8],r13
     d3b:	mov    QWORD PTR [rsp+0x10],rax
     d40:	mov    rdx,QWORD PTR [rsp+0x20]
     d45:	mov    QWORD PTR [rsp+0x18],rdx
     d4a:	mov    rcx,QWORD PTR [rsp+0x20]
     d4f:	mov    QWORD PTR [rsp+0x28],rcx
     d54:	mov    QWORD PTR [rsp+0x20],rax
     d59:	jmp    a07 <botlish_fn_13+0x47>
     d5e:	mov    rax,QWORD PTR [rsp+0x20]
     d63:	mov    rbx,QWORD PTR [rsp+0x30]
     d68:	mov    r12,QWORD PTR [rsp+0x38]
     d6d:	mov    r13,QWORD PTR [rsp+0x40]
     d72:	mov    r14,QWORD PTR [rsp+0x48]
     d77:	mov    r15,QWORD PTR [rsp+0x50]
     d7c:	add    rsp,0x60
     d80:	mov    rsp,rbp
     d83:	pop    rbp
     d84:	ret
     d85:	mov    rax,QWORD PTR [rsp+0x28]
     d8a:	test   rax,0x1
     d90:	jne    dbd <botlish_fn_13+0x3fd>
     d96:	mov    edx,0x1
     d9b:	mov    rdi,r15
     d9e:	mov    rsi,QWORD PTR [rsp+0x28]
     da3:	call   da8 <botlish_fn_13+0x3e8>
			da4: R_X86_64_PLT32	rt_int_cmp-0x4
     da8:	mov    ecx,0x2
     dad:	test   rax,rax
     db0:	cmovge rcx,QWORD PTR [rip+0x78]        # e30 <botlish_fn_13+0x470>
     db8:	jmp    dd7 <botlish_fn_13+0x417>
     dbd:	mov    ecx,0x2
     dc2:	mov    rax,QWORD PTR [rsp+0x28]
     dc7:	mov    rdx,QWORD PTR [rsp+0x28]
     dcc:	test   rax,rdx
     dcf:	cmovg  rcx,QWORD PTR [rip+0x59]        # e30 <botlish_fn_13+0x470>
     dd7:	cmp    rcx,0x6
     ddb:	je     e08 <botlish_fn_13+0x448>
     de1:	mov    rax,QWORD PTR [rsp+0x20]
     de6:	mov    rbx,QWORD PTR [rsp+0x30]
     deb:	mov    r12,QWORD PTR [rsp+0x38]
     df0:	mov    r13,QWORD PTR [rsp+0x40]
     df5:	mov    r14,QWORD PTR [rsp+0x48]
     dfa:	mov    r15,QWORD PTR [rsp+0x50]
     dff:	add    rsp,0x60
     e03:	mov    rsp,rbp
     e06:	pop    rbp
     e07:	ret
     e08:	mov    rax,QWORD PTR [rsp+0x28]
     e0d:	mov    rbx,QWORD PTR [rsp+0x30]
     e12:	mov    r12,QWORD PTR [rsp+0x38]
     e17:	mov    r13,QWORD PTR [rsp+0x40]
     e1c:	mov    r14,QWORD PTR [rsp+0x48]
     e21:	mov    r15,QWORD PTR [rsp+0x50]
     e26:	add    rsp,0x60
     e2a:	mov    rsp,rbp
     e2d:	pop    rbp
     e2e:	ret
     e2f:	add    BYTE PTR [rsi],al
     e31:	add    BYTE PTR [rax],al
     e33:	add    BYTE PTR [rax],al
     e35:	add    BYTE PTR [rax],al
	...

0000000000000e38 <botlish_entry_13: ht_find_insert<mutarray, str, int, int>>:
     e38:	push   rbp
     e39:	mov    rbp,rsp
     e3c:	mov    rsi,QWORD PTR [rdx]
     e3f:	mov    r9,QWORD PTR [rdx+0x8]
     e43:	mov    rcx,QWORD PTR [rdx+0x10]
     e47:	mov    r8,QWORD PTR [rdx+0x18]
     e4b:	mov    rdx,r9
     e4e:	call   e53 <botlish_entry_13+0x1b>
			e4f: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
     e53:	mov    rsp,rbp
     e56:	pop    rbp
     e57:	ret

0000000000000e58 <botlish_fn_14: ht_get<mutarray, str>>:
     e58:	push   rbp
     e59:	mov    rbp,rsp
     e5c:	sub    rsp,0x40
     e60:	mov    QWORD PTR [rsp+0x20],rbx
     e65:	mov    QWORD PTR [rsp+0x28],r12
     e6a:	mov    QWORD PTR [rsp+0x30],r13
     e6f:	mov    rbx,rdi
     e72:	mov    QWORD PTR [rsp],rsi
     e76:	mov    r13,rsi
     e79:	mov    QWORD PTR [rsp+0x8],rdx
     e7e:	mov    r12,rdx
     e81:	mov    rdx,r12
     e84:	mov    rsi,r13
     e87:	mov    rdi,rbx
     e8a:	call   e8f <botlish_fn_14+0x37>
			e8b: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
     e8f:	test   rax,rax
     e92:	je     f7c <botlish_fn_14+0x124>
     e98:	mov    QWORD PTR [rsp+0x10],rax
     e9d:	mov    rcx,rax
     ea0:	mov    rdx,r12
     ea3:	mov    rsi,r13
     ea6:	mov    rdi,rbx
     ea9:	call   eae <botlish_fn_14+0x56>
			eaa: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
     eae:	mov    rcx,rax
     eb1:	mov    r12,rax
     eb4:	test   rax,rcx
     eb7:	je     f7c <botlish_fn_14+0x124>
     ebd:	mov    rax,r12
     ec0:	test   rax,0x1
     ec6:	jne    ef1 <botlish_fn_14+0x99>
     ecc:	mov    edx,0x1
     ed1:	mov    rsi,r12
     ed4:	mov    rdi,rbx
     ed7:	call   edc <botlish_fn_14+0x84>
			ed8: R_X86_64_PLT32	rt_int_cmp-0x4
     edc:	mov    ecx,0x2
     ee1:	test   rax,rax
     ee4:	cmovl  rcx,QWORD PTR [rip+0xe4]        # fd0 <botlish_fn_14+0x178>
     eec:	jmp    f04 <botlish_fn_14+0xac>
     ef1:	mov    ecx,0x2
     ef6:	mov    rax,r12
     ef9:	test   rax,rax
     efc:	cmovle rcx,QWORD PTR [rip+0xcc]        # fd0 <botlish_fn_14+0x178>
     f04:	cmp    rcx,0x6
     f08:	je     faf <botlish_fn_14+0x157>
     f0e:	mov    rsi,r13
     f11:	mov    rdi,rbx
     f14:	call   f19 <botlish_fn_14+0xc1>
			f15: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
     f19:	test   rax,rax
     f1c:	je     f7c <botlish_fn_14+0x124>
     f22:	xor    ecx,ecx
     f24:	test   rax,0x7
     f2a:	je     f38 <botlish_fn_14+0xe0>
     f30:	mov    rsi,rax
     f33:	jmp    f46 <botlish_fn_14+0xee>
     f38:	movzx  rcx,BYTE PTR [rax]
     f3c:	mov    rsi,rax
     f3f:	rex cmp cl,0x8
     f43:	sete   cl
     f46:	test   cl,cl
     f48:	jne    f68 <botlish_fn_14+0x110>
     f4e:	mov    rdi,rbx
     f51:	mov    rax,QWORD PTR [rdi+0x10]
     f55:	mov    rcx,QWORD PTR [rax+0x8]
     f59:	mov    edx,0x8
     f5e:	call   f63 <botlish_fn_14+0x10b>
			f5f: R_X86_64_PLT32	rt_type_error-0x4
     f63:	jmp    f7c <botlish_fn_14+0x124>
     f68:	mov    rdx,r12
     f6b:	mov    rdi,rbx
     f6e:	call   f73 <botlish_fn_14+0x11b>
			f6f: R_X86_64_PLT32	rt_mutarray_get-0x4
     f73:	test   rax,rax
     f76:	jne    f97 <botlish_fn_14+0x13f>
     f7c:	xor    rax,rax
     f7f:	mov    rbx,QWORD PTR [rsp+0x20]
     f84:	mov    r12,QWORD PTR [rsp+0x28]
     f89:	mov    r13,QWORD PTR [rsp+0x30]
     f8e:	add    rsp,0x40
     f92:	mov    rsp,rbp
     f95:	pop    rbp
     f96:	ret
     f97:	mov    rbx,QWORD PTR [rsp+0x20]
     f9c:	mov    r12,QWORD PTR [rsp+0x28]
     fa1:	mov    r13,QWORD PTR [rsp+0x30]
     fa6:	add    rsp,0x40
     faa:	mov    rsp,rbp
     fad:	pop    rbp
     fae:	ret
     faf:	mov    eax,0xa
     fb4:	mov    rbx,QWORD PTR [rsp+0x20]
     fb9:	mov    r12,QWORD PTR [rsp+0x28]
     fbe:	mov    r13,QWORD PTR [rsp+0x30]
     fc3:	add    rsp,0x40
     fc7:	mov    rsp,rbp
     fca:	pop    rbp
     fcb:	ret
     fcc:	add    BYTE PTR [rax],al
     fce:	add    BYTE PTR [rax],al
     fd0:	(bad)
     fd1:	add    BYTE PTR [rax],al
     fd3:	add    BYTE PTR [rax],al
     fd5:	add    BYTE PTR [rax],al
	...

0000000000000fd8 <botlish_entry_14: ht_get<mutarray, str>>:
     fd8:	push   rbp
     fd9:	mov    rbp,rsp
     fdc:	mov    rsi,QWORD PTR [rdx]
     fdf:	mov    rdx,QWORD PTR [rdx+0x8]
     fe3:	call   fe8 <botlish_entry_14+0x10>
			fe4: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
     fe8:	mov    rsp,rbp
     feb:	pop    rbp
     fec:	ret
     fed:	add    BYTE PTR [rax],al
	...

0000000000000ff0 <botlish_fn_15: ht_contains<mutarray, str>>:
     ff0:	push   rbp
     ff1:	mov    rbp,rsp
     ff4:	sub    rsp,0x40
     ff8:	mov    QWORD PTR [rsp+0x20],rbx
     ffd:	mov    QWORD PTR [rsp+0x28],r12
    1002:	mov    QWORD PTR [rsp+0x30],r15
    1007:	mov    r15,rdi
    100a:	mov    QWORD PTR [rsp],rsi
    100e:	mov    r12,rsi
    1011:	mov    QWORD PTR [rsp+0x8],rdx
    1016:	mov    rbx,rdx
    1019:	mov    rdx,rbx
    101c:	mov    rsi,r12
    101f:	mov    rdi,r15
    1022:	call   1027 <botlish_fn_15+0x37>
			1023: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    1027:	test   rax,rax
    102a:	je     104f <botlish_fn_15+0x5f>
    1030:	mov    QWORD PTR [rsp+0x10],rax
    1035:	mov    rcx,rax
    1038:	mov    rdx,rbx
    103b:	mov    rsi,r12
    103e:	mov    rdi,r15
    1041:	call   1046 <botlish_fn_15+0x56>
			1042: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    1046:	test   rax,rax
    1049:	jne    106a <botlish_fn_15+0x7a>
    104f:	xor    rax,rax
    1052:	mov    rbx,QWORD PTR [rsp+0x20]
    1057:	mov    r12,QWORD PTR [rsp+0x28]
    105c:	mov    r15,QWORD PTR [rsp+0x30]
    1061:	add    rsp,0x40
    1065:	mov    rsp,rbp
    1068:	pop    rbp
    1069:	ret
    106a:	test   rax,0x1
    1070:	mov    rsi,rax
    1073:	jne    109e <botlish_fn_15+0xae>
    1079:	mov    edx,0x1
    107e:	mov    rdi,r15
    1081:	call   1086 <botlish_fn_15+0x96>
			1082: R_X86_64_PLT32	rt_int_cmp-0x4
    1086:	mov    ecx,0x2
    108b:	test   rax,rax
    108e:	mov    rax,rcx
    1091:	cmovge rax,QWORD PTR [rip+0x2f]        # 10c8 <botlish_fn_15+0xd8>
    1099:	jmp    10ae <botlish_fn_15+0xbe>
    109e:	mov    eax,0x2
    10a3:	test   rsi,rsi
    10a6:	cmovg  rax,QWORD PTR [rip+0x1a]        # 10c8 <botlish_fn_15+0xd8>
    10ae:	mov    rbx,QWORD PTR [rsp+0x20]
    10b3:	mov    r12,QWORD PTR [rsp+0x28]
    10b8:	mov    r15,QWORD PTR [rsp+0x30]
    10bd:	add    rsp,0x40
    10c1:	mov    rsp,rbp
    10c4:	pop    rbp
    10c5:	ret
    10c6:	add    BYTE PTR [rax],al
    10c8:	(bad)
    10c9:	add    BYTE PTR [rax],al
    10cb:	add    BYTE PTR [rax],al
    10cd:	add    BYTE PTR [rax],al
	...

00000000000010d0 <botlish_entry_15: ht_contains<mutarray, str>>:
    10d0:	push   rbp
    10d1:	mov    rbp,rsp
    10d4:	mov    rsi,QWORD PTR [rdx]
    10d7:	mov    rdx,QWORD PTR [rdx+0x8]
    10db:	call   10e0 <botlish_entry_15+0x10>
			10dc: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    10e0:	mov    rsp,rbp
    10e3:	pop    rbp
    10e4:	ret
    10e5:	add    BYTE PTR [rax],al
	...

00000000000010e8 <botlish_fn_16: ht_rehash_probe<mutarray, int, int>>:
    10e8:	push   rbp
    10e9:	mov    rbp,rsp
    10ec:	sub    rsp,0x40
    10f0:	mov    QWORD PTR [rsp+0x20],rbx
    10f5:	mov    QWORD PTR [rsp+0x28],r12
    10fa:	mov    QWORD PTR [rsp+0x30],r13
    10ff:	mov    QWORD PTR [rsp+0x38],r14
    1104:	mov    r13,rdi
    1107:	mov    QWORD PTR [rsp],rsi
    110b:	mov    QWORD PTR [rsp+0x8],rdx
    1110:	mov    QWORD PTR [rsp+0x10],rcx
    1115:	mov    r12,rcx
    1118:	mov    rbx,rsi
    111b:	mov    r14,rdx
    111e:	mov    rdx,r14
    1121:	mov    rsi,rbx
    1124:	mov    rdi,r13
    1127:	call   112c <botlish_fn_16+0x44>
			1128: R_X86_64_PLT32	rt_mutarray_get-0x4
    112c:	test   rax,rax
    112f:	je     11cc <botlish_fn_16+0xe4>
    1135:	test   rax,0x1
    113b:	mov    rsi,rax
    113e:	jne    115f <botlish_fn_16+0x77>
    1144:	mov    edx,0x1
    1149:	mov    rdi,r13
    114c:	call   1151 <botlish_fn_16+0x69>
			114d: R_X86_64_PLT32	rt_value_eq-0x4
    1151:	test   rax,rax
    1154:	je     11cc <botlish_fn_16+0xe4>
    115a:	jmp    1170 <botlish_fn_16+0x88>
    115f:	mov    eax,0x2
    1164:	cmp    rsi,0x1
    1168:	cmove  rax,QWORD PTR [rip+0xb8]        # 1228 <botlish_fn_16+0x140>
    1170:	cmp    rax,0x6
    1174:	je     1202 <botlish_fn_16+0x11a>
    117a:	mov    QWORD PTR [rsp+0x18],0x3
    1183:	mov    rsi,r14
    1186:	test   rsi,0x1
    118d:	je     11a5 <botlish_fn_16+0xbd>
    1193:	mov    rsi,r14
    1196:	add    rsi,0x2
    119a:	seto   al
    119d:	test   al,al
    119f:	je     11b8 <botlish_fn_16+0xd0>
    11a5:	mov    edx,0x3
    11aa:	mov    rsi,r14
    11ad:	mov    rdi,r13
    11b0:	call   11b5 <botlish_fn_16+0xcd>
			11b1: R_X86_64_PLT32	rt_int_add-0x4
    11b5:	mov    rsi,rax
    11b8:	mov    rdx,r12
    11bb:	mov    rdi,r13
    11be:	call   11c3 <botlish_fn_16+0xdb>
			11bf: R_X86_64_PLT32	rt_int_mod-0x4
    11c3:	test   rax,rax
    11c6:	jne    11ec <botlish_fn_16+0x104>
    11cc:	xor    rax,rax
    11cf:	mov    rbx,QWORD PTR [rsp+0x20]
    11d4:	mov    r12,QWORD PTR [rsp+0x28]
    11d9:	mov    r13,QWORD PTR [rsp+0x30]
    11de:	mov    r14,QWORD PTR [rsp+0x38]
    11e3:	add    rsp,0x40
    11e7:	mov    rsp,rbp
    11ea:	pop    rbp
    11eb:	ret
    11ec:	mov    QWORD PTR [rsp],rbx
    11f0:	mov    QWORD PTR [rsp+0x8],rax
    11f5:	mov    QWORD PTR [rsp+0x10],r12
    11fa:	mov    r14,rax
    11fd:	jmp    111e <botlish_fn_16+0x36>
    1202:	mov    rax,r14
    1205:	mov    rbx,QWORD PTR [rsp+0x20]
    120a:	mov    r12,QWORD PTR [rsp+0x28]
    120f:	mov    r13,QWORD PTR [rsp+0x30]
    1214:	mov    r14,QWORD PTR [rsp+0x38]
    1219:	add    rsp,0x40
    121d:	mov    rsp,rbp
    1220:	pop    rbp
    1221:	ret
    1222:	add    BYTE PTR [rax],al
    1224:	add    BYTE PTR [rax],al
    1226:	add    BYTE PTR [rax],al
    1228:	(bad)
    1229:	add    BYTE PTR [rax],al
    122b:	add    BYTE PTR [rax],al
    122d:	add    BYTE PTR [rax],al
	...

0000000000001230 <botlish_entry_16: ht_rehash_probe<mutarray, int, int>>:
    1230:	push   rbp
    1231:	mov    rbp,rsp
    1234:	mov    rsi,QWORD PTR [rdx]
    1237:	mov    r8,QWORD PTR [rdx+0x8]
    123b:	mov    rcx,QWORD PTR [rdx+0x10]
    123f:	mov    rdx,r8
    1242:	call   1247 <botlish_entry_16+0x17>
			1243: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash_probe<mutarray, int, int>
    1247:	mov    rsp,rbp
    124a:	pop    rbp
    124b:	ret

000000000000124c <botlish_fn_17: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    124c:	push   rbp
    124d:	mov    rbp,rsp
    1250:	sub    rsp,0x80
    1257:	mov    QWORD PTR [rsp+0x50],rbx
    125c:	mov    QWORD PTR [rsp+0x58],r12
    1261:	mov    QWORD PTR [rsp+0x60],r13
    1266:	mov    QWORD PTR [rsp+0x68],r14
    126b:	mov    QWORD PTR [rsp+0x70],r15
    1270:	mov    r12,rdi
    1273:	mov    rdi,QWORD PTR [rbp+0x10]
    1277:	mov    QWORD PTR [rsp],rsi
    127b:	mov    QWORD PTR [rsp+0x38],rsi
    1280:	mov    QWORD PTR [rsp+0x8],rdx
    1285:	mov    r15,rdx
    1288:	mov    QWORD PTR [rsp+0x10],rcx
    128d:	mov    rbx,rcx
    1290:	mov    QWORD PTR [rsp+0x18],r8
    1295:	mov    QWORD PTR [rsp+0x40],r8
    129a:	mov    QWORD PTR [rsp+0x20],r9
    129f:	mov    r14,r9
    12a2:	mov    QWORD PTR [rsp+0x28],rdi
    12a7:	mov    r13,rdi
    12aa:	mov    rsi,r14
    12ad:	mov    rdi,r12
    12b0:	call   12b5 <botlish_fn_17+0x69>
			12b1: R_X86_64_PLT32	rt_hash-0x4
    12b5:	test   rax,rax
    12b8:	mov    rsi,rax
    12bb:	je     135a <botlish_fn_17+0x10e>
    12c1:	mov    rdx,QWORD PTR [rsp+0x40]
    12c6:	mov    rdi,r12
    12c9:	call   12ce <botlish_fn_17+0x82>
			12ca: R_X86_64_PLT32	rt_int_mod-0x4
    12ce:	test   rax,rax
    12d1:	je     135a <botlish_fn_17+0x10e>
    12d7:	mov    QWORD PTR [rsp+0x30],rax
    12dc:	mov    rcx,QWORD PTR [rsp+0x40]
    12e1:	mov    rdx,rax
    12e4:	mov    rsi,QWORD PTR [rsp+0x38]
    12e9:	mov    rdi,r12
    12ec:	call   12f1 <botlish_fn_17+0xa5>
			12ed: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash_probe<mutarray, int, int>
    12f1:	mov    rcx,rax
    12f4:	mov    QWORD PTR [rsp+0x40],rax
    12f9:	test   rax,rcx
    12fc:	je     135a <botlish_fn_17+0x10e>
    1302:	mov    ecx,0x3
    1307:	mov    rsi,QWORD PTR [rsp+0x38]
    130c:	mov    rdx,QWORD PTR [rsp+0x40]
    1311:	mov    rdi,r12
    1314:	call   1319 <botlish_fn_17+0xcd>
			1315: R_X86_64_PLT32	rt_mutarray_set-0x4
    1319:	test   rax,rax
    131c:	je     135a <botlish_fn_17+0x10e>
    1322:	mov    rcx,r14
    1325:	mov    rsi,r15
    1328:	mov    rdx,QWORD PTR [rsp+0x40]
    132d:	mov    rdi,r12
    1330:	call   1335 <botlish_fn_17+0xe9>
			1331: R_X86_64_PLT32	rt_mutarray_set-0x4
    1335:	test   rax,rax
    1338:	je     135a <botlish_fn_17+0x10e>
    133e:	mov    rcx,r13
    1341:	mov    rdx,QWORD PTR [rsp+0x40]
    1346:	mov    rsi,rbx
    1349:	mov    rdi,r12
    134c:	call   1351 <botlish_fn_17+0x105>
			134d: R_X86_64_PLT32	rt_mutarray_set-0x4
    1351:	test   rax,rax
    1354:	jne    1382 <botlish_fn_17+0x136>
    135a:	xor    rax,rax
    135d:	mov    rbx,QWORD PTR [rsp+0x50]
    1362:	mov    r12,QWORD PTR [rsp+0x58]
    1367:	mov    r13,QWORD PTR [rsp+0x60]
    136c:	mov    r14,QWORD PTR [rsp+0x68]
    1371:	mov    r15,QWORD PTR [rsp+0x70]
    1376:	add    rsp,0x80
    137d:	mov    rsp,rbp
    1380:	pop    rbp
    1381:	ret
    1382:	mov    eax,0xa
    1387:	mov    rbx,QWORD PTR [rsp+0x50]
    138c:	mov    r12,QWORD PTR [rsp+0x58]
    1391:	mov    r13,QWORD PTR [rsp+0x60]
    1396:	mov    r14,QWORD PTR [rsp+0x68]
    139b:	mov    r15,QWORD PTR [rsp+0x70]
    13a0:	add    rsp,0x80
    13a7:	mov    rsp,rbp
    13aa:	pop    rbp
    13ab:	ret

00000000000013ac <botlish_entry_17: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    13ac:	push   rbp
    13ad:	mov    rbp,rsp
    13b0:	sub    rsp,0x10
    13b4:	mov    rsi,QWORD PTR [rdx]
    13b7:	mov    r10,QWORD PTR [rdx+0x8]
    13bb:	mov    rcx,QWORD PTR [rdx+0x10]
    13bf:	mov    r8,QWORD PTR [rdx+0x18]
    13c3:	mov    r9,QWORD PTR [rdx+0x20]
    13c7:	mov    r11,QWORD PTR [rdx+0x28]
    13cb:	mov    QWORD PTR [rsp],r11
    13cf:	mov    rdx,r10
    13d2:	call   13d7 <botlish_entry_17+0x2b>
			13d3: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    13d7:	add    rsp,0x10
    13db:	mov    rsp,rbp
    13de:	pop    rbp
    13df:	ret

00000000000013e0 <botlish_fn_18: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    13e0:	push   rbp
    13e1:	mov    rbp,rsp
    13e4:	sub    rsp,0xc0
    13eb:	mov    QWORD PTR [rsp+0x90],rbx
    13f3:	mov    QWORD PTR [rsp+0x98],r12
    13fb:	mov    QWORD PTR [rsp+0xa0],r13
    1403:	mov    QWORD PTR [rsp+0xa8],r14
    140b:	mov    QWORD PTR [rsp+0xb0],r15
    1413:	mov    QWORD PTR [rsp+0x58],rdi
    1418:	mov    r15,QWORD PTR [rbp+0x10]
    141c:	mov    r12,QWORD PTR [rbp+0x18]
    1420:	mov    r13,QWORD PTR [rbp+0x20]
    1424:	mov    r14,QWORD PTR [rbp+0x28]
    1428:	mov    QWORD PTR [rsp+0x10],rsi
    142d:	mov    QWORD PTR [rsp+0x60],rsi
    1432:	mov    QWORD PTR [rsp+0x18],rdx
    1437:	mov    QWORD PTR [rsp+0x68],rdx
    143c:	mov    QWORD PTR [rsp+0x20],rcx
    1441:	mov    QWORD PTR [rsp+0x70],rcx
    1446:	mov    QWORD PTR [rsp+0x28],r15
    144b:	mov    QWORD PTR [rsp+0x30],r12
    1450:	mov    QWORD PTR [rsp+0x38],r13
    1455:	mov    QWORD PTR [rsp+0x40],r14
    145a:	sar    r8,1
    145d:	sar    r9,1
    1460:	mov    QWORD PTR [rsp+0x88],r9
    1468:	mov    rcx,QWORD PTR [rsp+0x88]
    1470:	mov    rbx,r8
    1473:	cmp    rbx,rcx
    1476:	mov    QWORD PTR [rsp+0x88],rcx
    147e:	jge    16e7 <botlish_fn_18+0x307>
    1484:	xor    eax,eax
    1486:	mov    rsi,QWORD PTR [rsp+0x60]
    148b:	test   rsi,0x7
    1492:	jne    14a3 <botlish_fn_18+0xc3>
    1498:	movzx  r10,BYTE PTR [rsi]
    149c:	cmp    r10b,0x8
    14a0:	sete   al
    14a3:	test   al,al
    14a5:	jne    14c7 <botlish_fn_18+0xe7>
    14ab:	mov    rdi,QWORD PTR [rsp+0x58]
    14b0:	mov    rax,QWORD PTR [rdi+0x10]
    14b4:	mov    rcx,QWORD PTR [rax+0x8]
    14b8:	mov    edx,0x8
    14bd:	call   14c2 <botlish_fn_18+0xe2>
			14be: R_X86_64_PLT32	rt_type_error-0x4
    14c2:	jmp    1665 <botlish_fn_18+0x285>
    14c7:	mov    QWORD PTR [rsp+0x60],rsi
    14cc:	mov    rdx,rbx
    14cf:	shl    rdx,1
    14d2:	or     rdx,0x1
    14d6:	mov    QWORD PTR [rsp+0x80],rdx
    14de:	mov    rdi,QWORD PTR [rsp+0x58]
    14e3:	call   14e8 <botlish_fn_18+0x108>
			14e4: R_X86_64_PLT32	rt_mutarray_get-0x4
    14e8:	test   rax,rax
    14eb:	je     1665 <botlish_fn_18+0x285>
    14f1:	test   rax,0x1
    14f7:	mov    rsi,rax
    14fa:	jne    151d <botlish_fn_18+0x13d>
    1500:	mov    edx,0x3
    1505:	mov    rdi,QWORD PTR [rsp+0x58]
    150a:	call   150f <botlish_fn_18+0x12f>
			150b: R_X86_64_PLT32	rt_value_eq-0x4
    150f:	test   rax,rax
    1512:	je     1665 <botlish_fn_18+0x285>
    1518:	jmp    152e <botlish_fn_18+0x14e>
    151d:	mov    eax,0x2
    1522:	cmp    rsi,0x3
    1526:	cmove  rax,QWORD PTR [rip+0x1f2]        # 1720 <botlish_fn_18+0x340>
    152e:	cmp    rax,0x6
    1532:	je     1542 <botlish_fn_18+0x162>
    1538:	mov    rsi,QWORD PTR [rsp+0x60]
    153d:	jmp    16a1 <botlish_fn_18+0x2c1>
    1542:	xor    esi,esi
    1544:	mov    rdx,QWORD PTR [rsp+0x68]
    1549:	test   rdx,0x7
    1550:	je     1560 <botlish_fn_18+0x180>
    1556:	mov    QWORD PTR [rsp+0x68],rdx
    155b:	jmp    156f <botlish_fn_18+0x18f>
    1560:	movzx  rax,BYTE PTR [rdx]
    1564:	mov    QWORD PTR [rsp+0x68],rdx
    1569:	cmp    al,0x8
    156b:	sete   sil
    156f:	test   sil,sil
    1572:	jne    1599 <botlish_fn_18+0x1b9>
    1578:	mov    rdi,QWORD PTR [rsp+0x58]
    157d:	mov    rax,QWORD PTR [rdi+0x10]
    1581:	mov    rcx,QWORD PTR [rax+0x8]
    1585:	mov    edx,0x8
    158a:	mov    rsi,QWORD PTR [rsp+0x68]
    158f:	call   1594 <botlish_fn_18+0x1b4>
			1590: R_X86_64_PLT32	rt_type_error-0x4
    1594:	jmp    1665 <botlish_fn_18+0x285>
    1599:	mov    rdx,QWORD PTR [rsp+0x80]
    15a1:	mov    rsi,QWORD PTR [rsp+0x68]
    15a6:	mov    rdi,QWORD PTR [rsp+0x58]
    15ab:	call   15b0 <botlish_fn_18+0x1d0>
			15ac: R_X86_64_PLT32	rt_mutarray_get-0x4
    15b0:	test   rax,rax
    15b3:	je     1665 <botlish_fn_18+0x285>
    15b9:	mov    QWORD PTR [rsp+0x48],rax
    15be:	mov    QWORD PTR [rsp+0x78],rax
    15c3:	xor    eax,eax
    15c5:	mov    rcx,QWORD PTR [rsp+0x70]
    15ca:	test   rcx,0x7
    15d1:	je     15e1 <botlish_fn_18+0x201>
    15d7:	mov    QWORD PTR [rsp+0x70],rcx
    15dc:	jmp    15ef <botlish_fn_18+0x20f>
    15e1:	movzx  rax,BYTE PTR [rcx]
    15e5:	mov    QWORD PTR [rsp+0x70],rcx
    15ea:	cmp    al,0x8
    15ec:	sete   al
    15ef:	test   al,al
    15f1:	jne    1618 <botlish_fn_18+0x238>
    15f7:	mov    rdi,QWORD PTR [rsp+0x58]
    15fc:	mov    rax,QWORD PTR [rdi+0x10]
    1600:	mov    rcx,QWORD PTR [rax+0x8]
    1604:	mov    edx,0x8
    1609:	mov    rsi,QWORD PTR [rsp+0x70]
    160e:	call   1613 <botlish_fn_18+0x233>
			160f: R_X86_64_PLT32	rt_type_error-0x4
    1613:	jmp    1665 <botlish_fn_18+0x285>
    1618:	mov    rdx,QWORD PTR [rsp+0x80]
    1620:	mov    rsi,QWORD PTR [rsp+0x70]
    1625:	mov    rdi,QWORD PTR [rsp+0x58]
    162a:	call   162f <botlish_fn_18+0x24f>
			162b: R_X86_64_PLT32	rt_mutarray_get-0x4
    162f:	test   rax,rax
    1632:	je     1665 <botlish_fn_18+0x285>
    1638:	mov    QWORD PTR [rsp+0x50],rax
    163d:	mov    QWORD PTR [rsp],rax
    1641:	mov    r9,QWORD PTR [rsp+0x78]
    1646:	mov    rcx,r13
    1649:	mov    rdx,r12
    164c:	mov    rsi,r15
    164f:	mov    rdi,QWORD PTR [rsp+0x58]
    1654:	mov    r8,r14
    1657:	call   165c <botlish_fn_18+0x27c>
			1658: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    165c:	test   rax,rax
    165f:	jne    169c <botlish_fn_18+0x2bc>
    1665:	xor    rax,rax
    1668:	mov    rbx,QWORD PTR [rsp+0x90]
    1670:	mov    r12,QWORD PTR [rsp+0x98]
    1678:	mov    r13,QWORD PTR [rsp+0xa0]
    1680:	mov    r14,QWORD PTR [rsp+0xa8]
    1688:	mov    r15,QWORD PTR [rsp+0xb0]
    1690:	add    rsp,0xc0
    1697:	mov    rsp,rbp
    169a:	pop    rbp
    169b:	ret
    169c:	mov    rsi,QWORD PTR [rsp+0x60]
    16a1:	mov    rsi,QWORD PTR [rsp+0x60]
    16a6:	mov    QWORD PTR [rsp+0x10],rsi
    16ab:	mov    rsi,QWORD PTR [rsp+0x68]
    16b0:	mov    QWORD PTR [rsp+0x18],rsi
    16b5:	mov    rsi,QWORD PTR [rsp+0x70]
    16ba:	mov    QWORD PTR [rsp+0x20],rsi
    16bf:	mov    QWORD PTR [rsp+0x28],r15
    16c4:	mov    QWORD PTR [rsp+0x30],r12
    16c9:	mov    QWORD PTR [rsp+0x38],r13
    16ce:	mov    QWORD PTR [rsp+0x40],r14
    16d3:	add    rbx,0x1
    16da:	mov    rcx,QWORD PTR [rsp+0x88]
    16e2:	jmp    1473 <botlish_fn_18+0x93>
    16e7:	mov    eax,0xa
    16ec:	mov    rbx,QWORD PTR [rsp+0x90]
    16f4:	mov    r12,QWORD PTR [rsp+0x98]
    16fc:	mov    r13,QWORD PTR [rsp+0xa0]
    1704:	mov    r14,QWORD PTR [rsp+0xa8]
    170c:	mov    r15,QWORD PTR [rsp+0xb0]
    1714:	add    rsp,0xc0
    171b:	mov    rsp,rbp
    171e:	pop    rbp
    171f:	ret
    1720:	(bad)
    1721:	add    BYTE PTR [rax],al
    1723:	add    BYTE PTR [rax],al
    1725:	add    BYTE PTR [rax],al
	...

0000000000001728 <botlish_entry_18: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    1728:	push   rbp
    1729:	mov    rbp,rsp
    172c:	sub    rsp,0x30
    1730:	mov    QWORD PTR [rsp+0x20],r12
    1735:	mov    rsi,QWORD PTR [rdx]
    1738:	mov    rax,QWORD PTR [rdx+0x8]
    173c:	mov    rcx,QWORD PTR [rdx+0x10]
    1740:	mov    r8,QWORD PTR [rdx+0x18]
    1744:	mov    r9,QWORD PTR [rdx+0x20]
    1748:	mov    r10,QWORD PTR [rdx+0x28]
    174c:	mov    r11,QWORD PTR [rdx+0x30]
    1750:	mov    r12,QWORD PTR [rdx+0x38]
    1754:	mov    rdx,QWORD PTR [rdx+0x40]
    1758:	mov    QWORD PTR [rsp],r10
    175c:	mov    QWORD PTR [rsp+0x8],r11
    1761:	mov    QWORD PTR [rsp+0x10],r12
    1766:	mov    QWORD PTR [rsp+0x18],rdx
    176b:	mov    rdx,rax
    176e:	call   1773 <botlish_entry_18+0x4b>
			176f: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    1773:	mov    r12,QWORD PTR [rsp+0x20]
    1778:	add    rsp,0x30
    177c:	mov    rsp,rbp
    177f:	pop    rbp
    1780:	ret

0000000000001781 <botlish_fn_19: ht_rehash<mutarray, int>>:
    1781:	push   rbp
    1782:	mov    rbp,rsp
    1785:	sub    rsp,0xd0
    178c:	mov    QWORD PTR [rsp+0xa0],rbx
    1794:	mov    QWORD PTR [rsp+0xa8],r12
    179c:	mov    QWORD PTR [rsp+0xb0],r13
    17a4:	mov    QWORD PTR [rsp+0xb8],r14
    17ac:	mov    QWORD PTR [rsp+0xc0],r15
    17b4:	mov    r13,rdi
    17b7:	mov    QWORD PTR [rsp+0x50],0x0
    17c0:	mov    QWORD PTR [rsp+0x58],0x0
    17c9:	mov    QWORD PTR [rsp+0x60],0x0
    17d2:	mov    QWORD PTR [rsp+0x68],0x0
    17db:	mov    QWORD PTR [rsp+0x20],rsi
    17e0:	mov    r12,rsi
    17e3:	mov    QWORD PTR [rsp+0x28],rdx
    17e8:	mov    rbx,rdx
    17eb:	mov    rsi,r12
    17ee:	mov    rdi,r13
    17f1:	call   17f6 <botlish_fn_19+0x75>
			17f2: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    17f6:	test   rax,rax
    17f9:	je     19c8 <botlish_fn_19+0x247>
    17ff:	mov    QWORD PTR [rsp+0x30],rax
    1804:	mov    r14,rax
    1807:	mov    rsi,r12
    180a:	mov    rdi,r13
    180d:	call   1812 <botlish_fn_19+0x91>
			180e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    1812:	test   rax,rax
    1815:	je     19c8 <botlish_fn_19+0x247>
    181b:	mov    QWORD PTR [rsp+0x38],rax
    1820:	mov    r15,rax
    1823:	mov    rsi,r12
    1826:	mov    rdi,r13
    1829:	call   182e <botlish_fn_19+0xad>
			182a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    182e:	test   rax,rax
    1831:	je     19c8 <botlish_fn_19+0x247>
    1837:	mov    QWORD PTR [rsp+0x40],rax
    183c:	mov    QWORD PTR [rsp+0x90],rax
    1844:	mov    rsi,r12
    1847:	mov    rdi,r13
    184a:	call   184f <botlish_fn_19+0xce>
			184b: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    184f:	test   rax,rax
    1852:	je     19c8 <botlish_fn_19+0x247>
    1858:	mov    QWORD PTR [rsp+0x48],rax
    185d:	mov    QWORD PTR [rsp+0x88],rax
    1865:	mov    rsi,rbx
    1868:	mov    rdi,r13
    186b:	call   1870 <botlish_fn_19+0xef>
			186c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1870:	mov    rcx,rax
    1873:	mov    QWORD PTR [rsp+0x80],rax
    187b:	test   rax,rcx
    187e:	je     19c8 <botlish_fn_19+0x247>
    1884:	mov    rax,QWORD PTR [rsp+0x80]
    188c:	mov    QWORD PTR [rsp+0x50],rax
    1891:	mov    edx,0x1
    1896:	mov    QWORD PTR [rsp+0x58],0x1
    189f:	mov    rcx,rbx
    18a2:	mov    rsi,QWORD PTR [rsp+0x80]
    18aa:	mov    rdi,r13
    18ad:	call   18b2 <botlish_fn_19+0x131>
			18ae: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
    18b2:	test   rax,rax
    18b5:	je     19c8 <botlish_fn_19+0x247>
    18bb:	mov    rsi,rbx
    18be:	mov    rdi,r13
    18c1:	call   18c6 <botlish_fn_19+0x145>
			18c2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    18c6:	test   rax,rax
    18c9:	je     19c8 <botlish_fn_19+0x247>
    18cf:	mov    QWORD PTR [rsp+0x58],rax
    18d4:	mov    QWORD PTR [rsp+0x78],rax
    18d9:	mov    rsi,rbx
    18dc:	mov    rdi,r13
    18df:	call   18e4 <botlish_fn_19+0x163>
			18e0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    18e4:	test   rax,rax
    18e7:	je     19c8 <botlish_fn_19+0x247>
    18ed:	mov    QWORD PTR [rsp+0x60],rax
    18f2:	mov    r8d,0x1
    18f8:	mov    QWORD PTR [rsp+0x68],0x1
    1901:	mov    rcx,QWORD PTR [rsp+0x80]
    1909:	mov    QWORD PTR [rsp],rcx
    190d:	mov    rcx,QWORD PTR [rsp+0x78]
    1912:	mov    QWORD PTR [rsp+0x8],rcx
    1917:	mov    QWORD PTR [rsp+0x10],rax
    191c:	mov    QWORD PTR [rsp+0x70],rax
    1921:	mov    QWORD PTR [rsp+0x18],rbx
    1926:	mov    rcx,QWORD PTR [rsp+0x90]
    192e:	mov    rdx,r15
    1931:	mov    rsi,r14
    1934:	mov    r9,QWORD PTR [rsp+0x88]
    193c:	mov    rdi,r13
    193f:	call   1944 <botlish_fn_19+0x1c3>
			1940: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    1944:	test   rax,rax
    1947:	je     19c8 <botlish_fn_19+0x247>
    194d:	mov    edx,0x1
    1952:	mov    rcx,QWORD PTR [rsp+0x80]
    195a:	mov    rsi,r12
    195d:	mov    rdi,r13
    1960:	call   1965 <botlish_fn_19+0x1e4>
			1961: R_X86_64_PLT32	rt_mutarray_set-0x4
    1965:	test   rax,rax
    1968:	je     19c8 <botlish_fn_19+0x247>
    196e:	mov    edx,0x3
    1973:	mov    rcx,QWORD PTR [rsp+0x78]
    1978:	mov    rsi,r12
    197b:	mov    rdi,r13
    197e:	call   1983 <botlish_fn_19+0x202>
			197f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1983:	test   rax,rax
    1986:	je     19c8 <botlish_fn_19+0x247>
    198c:	mov    edx,0x5
    1991:	mov    rcx,QWORD PTR [rsp+0x70]
    1996:	mov    rsi,r12
    1999:	mov    rdi,r13
    199c:	call   19a1 <botlish_fn_19+0x220>
			199d: R_X86_64_PLT32	rt_mutarray_set-0x4
    19a1:	test   rax,rax
    19a4:	je     19c8 <botlish_fn_19+0x247>
    19aa:	mov    edx,0x9
    19af:	mov    ecx,0x1
    19b4:	mov    rsi,r12
    19b7:	mov    rdi,r13
    19ba:	call   19bf <botlish_fn_19+0x23e>
			19bb: R_X86_64_PLT32	rt_mutarray_set-0x4
    19bf:	test   rax,rax
    19c2:	jne    19ff <botlish_fn_19+0x27e>
    19c8:	xor    rax,rax
    19cb:	mov    rbx,QWORD PTR [rsp+0xa0]
    19d3:	mov    r12,QWORD PTR [rsp+0xa8]
    19db:	mov    r13,QWORD PTR [rsp+0xb0]
    19e3:	mov    r14,QWORD PTR [rsp+0xb8]
    19eb:	mov    r15,QWORD PTR [rsp+0xc0]
    19f3:	add    rsp,0xd0
    19fa:	mov    rsp,rbp
    19fd:	pop    rbp
    19fe:	ret
    19ff:	mov    eax,0xa
    1a04:	mov    rbx,QWORD PTR [rsp+0xa0]
    1a0c:	mov    r12,QWORD PTR [rsp+0xa8]
    1a14:	mov    r13,QWORD PTR [rsp+0xb0]
    1a1c:	mov    r14,QWORD PTR [rsp+0xb8]
    1a24:	mov    r15,QWORD PTR [rsp+0xc0]
    1a2c:	add    rsp,0xd0
    1a33:	mov    rsp,rbp
    1a36:	pop    rbp
    1a37:	ret

0000000000001a38 <botlish_entry_19: ht_rehash<mutarray, int>>:
    1a38:	push   rbp
    1a39:	mov    rbp,rsp
    1a3c:	mov    rsi,QWORD PTR [rdx]
    1a3f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a43:	call   1a48 <botlish_entry_19+0x10>
			1a44: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1a48:	mov    rsp,rbp
    1a4b:	pop    rbp
    1a4c:	ret
    1a4d:	add    BYTE PTR [rax],al
	...

0000000000001a50 <botlish_fn_20: ht_should_grow<mutarray>>:
    1a50:	push   rbp
    1a51:	mov    rbp,rsp
    1a54:	sub    rsp,0x40
    1a58:	mov    QWORD PTR [rsp+0x20],rbx
    1a5d:	mov    QWORD PTR [rsp+0x28],r12
    1a62:	mov    QWORD PTR [rsp+0x30],r13
    1a67:	mov    rbx,rdi
    1a6a:	mov    QWORD PTR [rsp],rsi
    1a6e:	mov    r12,rsi
    1a71:	mov    rsi,r12
    1a74:	mov    rdi,rbx
    1a77:	call   1a7c <botlish_fn_20+0x2c>
			1a78: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1a7c:	mov    rcx,rax
    1a7f:	mov    r13,rax
    1a82:	test   rax,rcx
    1a85:	je     1c74 <botlish_fn_20+0x224>
    1a8b:	mov    rax,r13
    1a8e:	mov    QWORD PTR [rsp+0x8],rax
    1a93:	mov    rsi,r12
    1a96:	mov    rdi,rbx
    1a99:	call   1a9e <botlish_fn_20+0x4e>
			1a9a: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1a9e:	mov    rcx,rax
    1aa1:	test   rcx,rcx
    1aa4:	je     1c74 <botlish_fn_20+0x224>
    1aaa:	mov    QWORD PTR [rsp+0x10],rcx
    1aaf:	mov    edx,0x1
    1ab4:	mov    rax,r13
    1ab7:	test   rax,0x1
    1abd:	jne    1ae0 <botlish_fn_20+0x90>
    1ac3:	xor    edx,edx
    1ac5:	mov    rax,r13
    1ac8:	test   rax,0x7
    1ace:	jne    1ae0 <botlish_fn_20+0x90>
    1ad4:	mov    rax,r13
    1ad7:	movzx  rax,BYTE PTR [rax]
    1adb:	cmp    al,0x1
    1add:	sete   dl
    1ae0:	test   dl,dl
    1ae2:	jne    1b03 <botlish_fn_20+0xb3>
    1ae8:	mov    rdi,rbx
    1aeb:	mov    rax,QWORD PTR [rdi+0x10]
    1aef:	mov    rcx,QWORD PTR [rax+0x10]
    1af3:	xor    rdx,rdx
    1af6:	mov    rsi,r13
    1af9:	call   1afe <botlish_fn_20+0xae>
			1afa: R_X86_64_PLT32	rt_type_error-0x4
    1afe:	jmp    1c74 <botlish_fn_20+0x224>
    1b03:	mov    eax,0x1
    1b08:	test   rcx,0x1
    1b0f:	je     1b1d <botlish_fn_20+0xcd>
    1b15:	mov    r8,rcx
    1b18:	jmp    1b40 <botlish_fn_20+0xf0>
    1b1d:	xor    eax,eax
    1b1f:	test   rcx,0x7
    1b26:	je     1b34 <botlish_fn_20+0xe4>
    1b2c:	mov    r8,rcx
    1b2f:	jmp    1b40 <botlish_fn_20+0xf0>
    1b34:	movzx  rax,BYTE PTR [rcx]
    1b38:	mov    r8,rcx
    1b3b:	cmp    al,0x1
    1b3d:	sete   al
    1b40:	test   al,al
    1b42:	jne    1b63 <botlish_fn_20+0x113>
    1b48:	mov    rdi,rbx
    1b4b:	mov    rax,QWORD PTR [rdi+0x10]
    1b4f:	mov    rcx,QWORD PTR [rax+0x10]
    1b53:	xor    rdx,rdx
    1b56:	mov    rsi,r8
    1b59:	call   1b5e <botlish_fn_20+0x10e>
			1b5a: R_X86_64_PLT32	rt_type_error-0x4
    1b5e:	jmp    1c74 <botlish_fn_20+0x224>
    1b63:	mov    rcx,r8
    1b66:	mov    rsi,r13
    1b69:	mov    rax,rsi
    1b6c:	and    rax,rcx
    1b6f:	test   rax,0x1
    1b75:	jne    1b86 <botlish_fn_20+0x136>
    1b7b:	mov    rdx,r8
    1b7e:	mov    rsi,r13
    1b81:	jmp    1ba4 <botlish_fn_20+0x154>
    1b86:	mov    rcx,r8
    1b89:	lea    rax,[rcx-0x1]
    1b8d:	mov    rsi,r13
    1b90:	add    rsi,rax
    1b93:	seto   al
    1b96:	test   al,al
    1b98:	je     1baf <botlish_fn_20+0x15f>
    1b9e:	mov    rdx,r8
    1ba1:	mov    rsi,r13
    1ba4:	mov    rdi,rbx
    1ba7:	call   1bac <botlish_fn_20+0x15c>
			1ba8: R_X86_64_PLT32	rt_int_add-0x4
    1bac:	mov    rsi,rax
    1baf:	mov    QWORD PTR [rsp+0x8],rsi
    1bb4:	mov    QWORD PTR [rsp+0x10],0x3
    1bbd:	test   rsi,0x1
    1bc4:	je     1be7 <botlish_fn_20+0x197>
    1bca:	mov    rax,rsi
    1bcd:	add    rax,0x2
    1bd1:	mov    rcx,rax
    1bd4:	seto   al
    1bd7:	test   al,al
    1bd9:	jne    1be7 <botlish_fn_20+0x197>
    1bdf:	mov    rsi,rcx
    1be2:	jmp    1bf7 <botlish_fn_20+0x1a7>
    1be7:	mov    edx,0x3
    1bec:	mov    rdi,rbx
    1bef:	call   1bf4 <botlish_fn_20+0x1a4>
			1bf0: R_X86_64_PLT32	rt_int_add-0x4
    1bf4:	mov    rsi,rax
    1bf7:	mov    QWORD PTR [rsp+0x8],rsi
    1bfc:	mov    edx,0x7
    1c01:	mov    rdi,rdx
    1c04:	mov    QWORD PTR [rsp+0x10],0x7
    1c0d:	test   rsi,0x1
    1c14:	jne    1c22 <botlish_fn_20+0x1d2>
    1c1a:	mov    rdx,rdi
    1c1d:	jmp    1c4e <botlish_fn_20+0x1fe>
    1c22:	mov    rax,rsi
    1c25:	sar    rax,1
    1c28:	imul   QWORD PTR [rip+0x119]        # 1d48 <botlish_fn_20+0x2f8>
    1c2f:	seto   cl
    1c32:	or     rax,0x1
    1c36:	test   cl,cl
    1c38:	je     1c46 <botlish_fn_20+0x1f6>
    1c3e:	mov    rdx,rdi
    1c41:	jmp    1c4e <botlish_fn_20+0x1fe>
    1c46:	mov    rsi,rax
    1c49:	jmp    1c59 <botlish_fn_20+0x209>
    1c4e:	mov    rdi,rbx
    1c51:	call   1c56 <botlish_fn_20+0x206>
			1c52: R_X86_64_PLT32	rt_int_mul-0x4
    1c56:	mov    rsi,rax
    1c59:	mov    QWORD PTR [rsp],rsi
    1c5d:	mov    r13,rsi
    1c60:	mov    rsi,r12
    1c63:	mov    rdi,rbx
    1c66:	call   1c6b <botlish_fn_20+0x21b>
			1c67: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1c6b:	test   rax,rax
    1c6e:	jne    1c8f <botlish_fn_20+0x23f>
    1c74:	xor    rax,rax
    1c77:	mov    rbx,QWORD PTR [rsp+0x20]
    1c7c:	mov    r12,QWORD PTR [rsp+0x28]
    1c81:	mov    r13,QWORD PTR [rsp+0x30]
    1c86:	add    rsp,0x40
    1c8a:	mov    rsp,rbp
    1c8d:	pop    rbp
    1c8e:	ret
    1c8f:	mov    QWORD PTR [rsp+0x8],rax
    1c94:	mov    QWORD PTR [rsp+0x10],0x5
    1c9d:	test   rax,0x1
    1ca3:	mov    rsi,rax
    1ca6:	je     1cd8 <botlish_fn_20+0x288>
    1cac:	mov    rcx,rsi
    1caf:	mov    rax,rcx
    1cb2:	sar    rax,1
    1cb5:	imul   QWORD PTR [rip+0x94]        # 1d50 <botlish_fn_20+0x300>
    1cbc:	seto   dil
    1cc0:	or     rax,0x1
    1cc4:	test   dil,dil
    1cc7:	jne    1cd8 <botlish_fn_20+0x288>
    1ccd:	mov    rdx,rax
    1cd0:	mov    rsi,r13
    1cd3:	jmp    1ceb <botlish_fn_20+0x29b>
    1cd8:	mov    edx,0x5
    1cdd:	mov    rdi,rbx
    1ce0:	call   1ce5 <botlish_fn_20+0x295>
			1ce1: R_X86_64_PLT32	rt_int_mul-0x4
    1ce5:	mov    rdx,rax
    1ce8:	mov    rsi,r13
    1ceb:	mov    r10,rsi
    1cee:	and    r10,rdx
    1cf1:	test   r10,0x1
    1cf8:	jne    1d1f <botlish_fn_20+0x2cf>
    1cfe:	mov    rdi,rbx
    1d01:	call   1d06 <botlish_fn_20+0x2b6>
			1d02: R_X86_64_PLT32	rt_int_cmp-0x4
    1d06:	mov    r8d,0x2
    1d0c:	test   rax,rax
    1d0f:	mov    rax,r8
    1d12:	cmovg  rax,QWORD PTR [rip+0x2e]        # 1d48 <botlish_fn_20+0x2f8>
    1d1a:	jmp    1d2f <botlish_fn_20+0x2df>
    1d1f:	mov    eax,0x2
    1d24:	cmp    rsi,rdx
    1d27:	cmovg  rax,QWORD PTR [rip+0x19]        # 1d48 <botlish_fn_20+0x2f8>
    1d2f:	mov    rbx,QWORD PTR [rsp+0x20]
    1d34:	mov    r12,QWORD PTR [rsp+0x28]
    1d39:	mov    r13,QWORD PTR [rsp+0x30]
    1d3e:	add    rsp,0x40
    1d42:	mov    rsp,rbp
    1d45:	pop    rbp
    1d46:	ret
    1d47:	add    BYTE PTR [rsi],al
    1d49:	add    BYTE PTR [rax],al
    1d4b:	add    BYTE PTR [rax],al
    1d4d:	add    BYTE PTR [rax],al
    1d4f:	add    BYTE PTR [rax+rax*1],al
    1d52:	add    BYTE PTR [rax],al
    1d54:	add    BYTE PTR [rax],al
	...

0000000000001d58 <botlish_entry_20: ht_should_grow<mutarray>>:
    1d58:	push   rbp
    1d59:	mov    rbp,rsp
    1d5c:	mov    rsi,QWORD PTR [rdx]
    1d5f:	call   1d64 <botlish_entry_20+0xc>
			1d60: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    1d64:	mov    rsp,rbp
    1d67:	pop    rbp
    1d68:	ret
    1d69:	add    BYTE PTR [rax],al
    1d6b:	add    BYTE PTR [rax],al
    1d6d:	add    BYTE PTR [rax],al
	...

0000000000001d70 <botlish_fn_21: ht_grow_or_clean<mutarray>>:
    1d70:	push   rbp
    1d71:	mov    rbp,rsp
    1d74:	sub    rsp,0x40
    1d78:	mov    QWORD PTR [rsp+0x20],rbx
    1d7d:	mov    QWORD PTR [rsp+0x28],r12
    1d82:	mov    QWORD PTR [rsp+0x30],r13
    1d87:	mov    rbx,rdi
    1d8a:	mov    QWORD PTR [rsp+0x10],0x0
    1d93:	mov    QWORD PTR [rsp],rsi
    1d97:	mov    r12,rsi
    1d9a:	mov    rsi,r12
    1d9d:	mov    rdi,rbx
    1da0:	call   1da5 <botlish_fn_21+0x35>
			1da1: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1da5:	test   rax,rax
    1da8:	mov    r13,rax
    1dab:	je     1f98 <botlish_fn_21+0x228>
    1db1:	mov    rsi,r12
    1db4:	mov    rdi,rbx
    1db7:	call   1dbc <botlish_fn_21+0x4c>
			1db8: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1dbc:	mov    rcx,rax
    1dbf:	test   rcx,rcx
    1dc2:	je     1f98 <botlish_fn_21+0x228>
    1dc8:	mov    edx,0x1
    1dcd:	mov    rax,r13
    1dd0:	test   rax,0x1
    1dd6:	je     1de4 <botlish_fn_21+0x74>
    1ddc:	mov    r13,rax
    1ddf:	jmp    1e08 <botlish_fn_21+0x98>
    1de4:	xor    edx,edx
    1de6:	test   rax,0x7
    1dec:	je     1dfa <botlish_fn_21+0x8a>
    1df2:	mov    r13,rax
    1df5:	jmp    1e08 <botlish_fn_21+0x98>
    1dfa:	movzx  rdx,BYTE PTR [rax]
    1dfe:	mov    r13,rax
    1e01:	rex cmp dl,0x1
    1e05:	sete   dl
    1e08:	test   dl,dl
    1e0a:	jne    1e2b <botlish_fn_21+0xbb>
    1e10:	mov    rdi,rbx
    1e13:	mov    rsi,QWORD PTR [rdi+0x10]
    1e17:	mov    rcx,QWORD PTR [rsi+0x18]
    1e1b:	xor    rdx,rdx
    1e1e:	mov    rsi,r13
    1e21:	call   1e26 <botlish_fn_21+0xb6>
			1e22: R_X86_64_PLT32	rt_type_error-0x4
    1e26:	jmp    1f98 <botlish_fn_21+0x228>
    1e2b:	mov    rsi,r13
    1e2e:	mov    eax,0x1
    1e33:	test   rcx,0x1
    1e3a:	je     1e48 <botlish_fn_21+0xd8>
    1e40:	mov    r8,rcx
    1e43:	jmp    1e6d <botlish_fn_21+0xfd>
    1e48:	xor    eax,eax
    1e4a:	test   rcx,0x7
    1e51:	je     1e5f <botlish_fn_21+0xef>
    1e57:	mov    r8,rcx
    1e5a:	jmp    1e6d <botlish_fn_21+0xfd>
    1e5f:	movzx  r11,BYTE PTR [rcx]
    1e63:	mov    r8,rcx
    1e66:	cmp    r11b,0x1
    1e6a:	sete   al
    1e6d:	test   al,al
    1e6f:	jne    1e90 <botlish_fn_21+0x120>
    1e75:	mov    rdi,rbx
    1e78:	mov    rax,QWORD PTR [rdi+0x10]
    1e7c:	mov    rcx,QWORD PTR [rax+0x18]
    1e80:	xor    rdx,rdx
    1e83:	mov    rsi,r8
    1e86:	call   1e8b <botlish_fn_21+0x11b>
			1e87: R_X86_64_PLT32	rt_type_error-0x4
    1e8b:	jmp    1f98 <botlish_fn_21+0x228>
    1e90:	mov    rcx,r8
    1e93:	mov    rax,rsi
    1e96:	and    rax,rcx
    1e99:	test   rax,0x1
    1e9f:	jne    1ec5 <botlish_fn_21+0x155>
    1ea5:	mov    rdx,r8
    1ea8:	mov    rdi,rbx
    1eab:	call   1eb0 <botlish_fn_21+0x140>
			1eac: R_X86_64_PLT32	rt_int_cmp-0x4
    1eb0:	mov    ecx,0x2
    1eb5:	test   rax,rax
    1eb8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1fd0 <botlish_fn_21+0x260>
    1ec0:	jmp    1ed8 <botlish_fn_21+0x168>
    1ec5:	mov    ecx,0x2
    1eca:	mov    r9,r8
    1ecd:	cmp    rsi,r9
    1ed0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1fd0 <botlish_fn_21+0x260>
    1ed8:	cmp    rcx,0x6
    1edc:	je     1f68 <botlish_fn_21+0x1f8>
    1ee2:	mov    rsi,r12
    1ee5:	mov    rdi,rbx
    1ee8:	call   1eed <botlish_fn_21+0x17d>
			1ee9: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1eed:	test   rax,rax
    1ef0:	je     1f98 <botlish_fn_21+0x228>
    1ef6:	mov    QWORD PTR [rsp+0x8],rax
    1efb:	mov    QWORD PTR [rsp+0x10],0x5
    1f04:	test   rax,0x1
    1f0a:	mov    rsi,rax
    1f0d:	je     1f3a <botlish_fn_21+0x1ca>
    1f13:	mov    rcx,rsi
    1f16:	mov    rax,rcx
    1f19:	sar    rax,1
    1f1c:	imul   QWORD PTR [rip+0xb5]        # 1fd8 <botlish_fn_21+0x268>
    1f23:	seto   cl
    1f26:	or     rax,0x1
    1f2a:	test   cl,cl
    1f2c:	jne    1f3a <botlish_fn_21+0x1ca>
    1f32:	mov    rdx,rax
    1f35:	jmp    1f4a <botlish_fn_21+0x1da>
    1f3a:	mov    edx,0x5
    1f3f:	mov    rdi,rbx
    1f42:	call   1f47 <botlish_fn_21+0x1d7>
			1f43: R_X86_64_PLT32	rt_int_mul-0x4
    1f47:	mov    rdx,rax
    1f4a:	mov    QWORD PTR [rsp+0x8],rdx
    1f4f:	mov    rsi,r12
    1f52:	mov    rdi,rbx
    1f55:	call   1f5a <botlish_fn_21+0x1ea>
			1f56: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1f5a:	test   rax,rax
    1f5d:	je     1f98 <botlish_fn_21+0x228>
    1f63:	jmp    1fb3 <botlish_fn_21+0x243>
    1f68:	mov    rsi,r12
    1f6b:	mov    rdi,rbx
    1f6e:	call   1f73 <botlish_fn_21+0x203>
			1f6f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1f73:	test   rax,rax
    1f76:	je     1f98 <botlish_fn_21+0x228>
    1f7c:	mov    QWORD PTR [rsp+0x8],rax
    1f81:	mov    rdx,rax
    1f84:	mov    rsi,r12
    1f87:	mov    rdi,rbx
    1f8a:	call   1f8f <botlish_fn_21+0x21f>
			1f8b: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1f8f:	test   rax,rax
    1f92:	jne    1fb3 <botlish_fn_21+0x243>
    1f98:	xor    rax,rax
    1f9b:	mov    rbx,QWORD PTR [rsp+0x20]
    1fa0:	mov    r12,QWORD PTR [rsp+0x28]
    1fa5:	mov    r13,QWORD PTR [rsp+0x30]
    1faa:	add    rsp,0x40
    1fae:	mov    rsp,rbp
    1fb1:	pop    rbp
    1fb2:	ret
    1fb3:	mov    rbx,QWORD PTR [rsp+0x20]
    1fb8:	mov    r12,QWORD PTR [rsp+0x28]
    1fbd:	mov    r13,QWORD PTR [rsp+0x30]
    1fc2:	add    rsp,0x40
    1fc6:	mov    rsp,rbp
    1fc9:	pop    rbp
    1fca:	ret
    1fcb:	add    BYTE PTR [rax],al
    1fcd:	add    BYTE PTR [rax],al
    1fcf:	add    BYTE PTR [rsi],al
    1fd1:	add    BYTE PTR [rax],al
    1fd3:	add    BYTE PTR [rax],al
    1fd5:	add    BYTE PTR [rax],al
    1fd7:	add    BYTE PTR [rax+rax*1],al
    1fda:	add    BYTE PTR [rax],al
    1fdc:	add    BYTE PTR [rax],al
	...

0000000000001fe0 <botlish_entry_21: ht_grow_or_clean<mutarray>>:
    1fe0:	push   rbp
    1fe1:	mov    rbp,rsp
    1fe4:	mov    rsi,QWORD PTR [rdx]
    1fe7:	call   1fec <botlish_entry_21+0xc>
			1fe8: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    1fec:	mov    rsp,rbp
    1fef:	pop    rbp
    1ff0:	ret
    1ff1:	add    BYTE PTR [rax],al
    1ff3:	add    BYTE PTR [rax],al
    1ff5:	add    BYTE PTR [rax],al
	...

0000000000001ff8 <botlish_fn_22: ht_place<mutarray, int, str, str>>:
    1ff8:	push   rbp
    1ff9:	mov    rbp,rsp
    1ffc:	sub    rsp,0x70
    2000:	mov    QWORD PTR [rsp+0x40],rbx
    2005:	mov    QWORD PTR [rsp+0x48],r12
    200a:	mov    QWORD PTR [rsp+0x50],r13
    200f:	mov    QWORD PTR [rsp+0x58],r14
    2014:	mov    QWORD PTR [rsp+0x60],r15
    2019:	mov    rbx,rdi
    201c:	mov    r14,r8
    201f:	mov    r15,rdx
    2022:	mov    QWORD PTR [rsp+0x28],rcx
    2027:	mov    QWORD PTR [rsp],rsi
    202b:	mov    r12,rsi
    202e:	mov    rsi,r12
    2031:	mov    rdi,rbx
    2034:	call   2039 <botlish_fn_22+0x41>
			2035: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    2039:	test   rax,rax
    203c:	je     23a2 <botlish_fn_22+0x3aa>
    2042:	xor    ecx,ecx
    2044:	test   rax,0x7
    204a:	je     205a <botlish_fn_22+0x62>
    2050:	mov    QWORD PTR [rsp+0x30],rax
    2055:	jmp    206a <botlish_fn_22+0x72>
    205a:	movzx  rcx,BYTE PTR [rax]
    205e:	mov    QWORD PTR [rsp+0x30],rax
    2063:	rex cmp cl,0x8
    2067:	sete   cl
    206a:	test   cl,cl
    206c:	jne    2091 <botlish_fn_22+0x99>
    2072:	mov    rdi,rbx
    2075:	mov    rax,QWORD PTR [rdi+0x10]
    2079:	mov    rcx,QWORD PTR [rax+0x8]
    207d:	mov    edx,0x8
    2082:	mov    rsi,QWORD PTR [rsp+0x30]
    2087:	call   208c <botlish_fn_22+0x94>
			2088: R_X86_64_PLT32	rt_type_error-0x4
    208c:	jmp    23a2 <botlish_fn_22+0x3aa>
    2091:	mov    rdx,r15
    2094:	mov    rsi,QWORD PTR [rsp+0x30]
    2099:	mov    rdi,rbx
    209c:	call   20a1 <botlish_fn_22+0xa9>
			209d: R_X86_64_PLT32	rt_mutarray_get-0x4
    20a1:	test   rax,rax
    20a4:	je     23a2 <botlish_fn_22+0x3aa>
    20aa:	mov    QWORD PTR [rsp+0x8],rax
    20af:	mov    r13,rax
    20b2:	mov    ecx,0x3
    20b7:	mov    rsi,QWORD PTR [rsp+0x30]
    20bc:	mov    rdx,r15
    20bf:	mov    rdi,rbx
    20c2:	call   20c7 <botlish_fn_22+0xcf>
			20c3: R_X86_64_PLT32	rt_mutarray_set-0x4
    20c7:	test   rax,rax
    20ca:	je     23a2 <botlish_fn_22+0x3aa>
    20d0:	mov    rsi,r12
    20d3:	mov    rdi,rbx
    20d6:	call   20db <botlish_fn_22+0xe3>
			20d7: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    20db:	test   rax,rax
    20de:	je     23a2 <botlish_fn_22+0x3aa>
    20e4:	xor    ecx,ecx
    20e6:	test   rax,0x7
    20ec:	je     20fa <botlish_fn_22+0x102>
    20f2:	mov    rsi,rax
    20f5:	jmp    2108 <botlish_fn_22+0x110>
    20fa:	movzx  rcx,BYTE PTR [rax]
    20fe:	mov    rsi,rax
    2101:	rex cmp cl,0x8
    2105:	sete   cl
    2108:	test   cl,cl
    210a:	jne    212a <botlish_fn_22+0x132>
    2110:	mov    rdi,rbx
    2113:	mov    rax,QWORD PTR [rdi+0x10]
    2117:	mov    rcx,QWORD PTR [rax+0x20]
    211b:	mov    edx,0x8
    2120:	call   2125 <botlish_fn_22+0x12d>
			2121: R_X86_64_PLT32	rt_type_error-0x4
    2125:	jmp    23a2 <botlish_fn_22+0x3aa>
    212a:	mov    rcx,QWORD PTR [rsp+0x28]
    212f:	mov    rdx,r15
    2132:	mov    rdi,rbx
    2135:	call   213a <botlish_fn_22+0x142>
			2136: R_X86_64_PLT32	rt_mutarray_set-0x4
    213a:	test   rax,rax
    213d:	je     23a2 <botlish_fn_22+0x3aa>
    2143:	mov    rsi,r12
    2146:	mov    rdi,rbx
    2149:	call   214e <botlish_fn_22+0x156>
			214a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    214e:	test   rax,rax
    2151:	je     23a2 <botlish_fn_22+0x3aa>
    2157:	xor    esi,esi
    2159:	test   rax,0x7
    215f:	jne    2171 <botlish_fn_22+0x179>
    2165:	movzx  rcx,BYTE PTR [rax]
    2169:	rex cmp cl,0x8
    216d:	sete   sil
    2171:	test   sil,sil
    2174:	jne    2197 <botlish_fn_22+0x19f>
    217a:	mov    rdi,rbx
    217d:	mov    rsi,QWORD PTR [rdi+0x10]
    2181:	mov    rcx,QWORD PTR [rsi+0x20]
    2185:	mov    edx,0x8
    218a:	mov    rsi,rax
    218d:	call   2192 <botlish_fn_22+0x19a>
			218e: R_X86_64_PLT32	rt_type_error-0x4
    2192:	jmp    23a2 <botlish_fn_22+0x3aa>
    2197:	mov    rcx,r14
    219a:	mov    rdx,r15
    219d:	mov    rsi,rax
    21a0:	mov    rdi,rbx
    21a3:	call   21a8 <botlish_fn_22+0x1b0>
			21a4: R_X86_64_PLT32	rt_mutarray_set-0x4
    21a8:	test   rax,rax
    21ab:	je     23a2 <botlish_fn_22+0x3aa>
    21b1:	mov    QWORD PTR [rsp+0x10],0x7
    21ba:	mov    rsi,r12
    21bd:	mov    rdi,rbx
    21c0:	call   21c5 <botlish_fn_22+0x1cd>
			21c1: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    21c5:	test   rax,rax
    21c8:	je     23a2 <botlish_fn_22+0x3aa>
    21ce:	mov    QWORD PTR [rsp+0x18],rax
    21d3:	mov    QWORD PTR [rsp+0x20],0x3
    21dc:	mov    ecx,0x1
    21e1:	test   rax,0x1
    21e7:	je     21f5 <botlish_fn_22+0x1fd>
    21ed:	mov    rsi,rax
    21f0:	jmp    2219 <botlish_fn_22+0x221>
    21f5:	xor    ecx,ecx
    21f7:	test   rax,0x7
    21fd:	je     220b <botlish_fn_22+0x213>
    2203:	mov    rsi,rax
    2206:	jmp    2219 <botlish_fn_22+0x221>
    220b:	movzx  rcx,BYTE PTR [rax]
    220f:	mov    rsi,rax
    2212:	rex cmp cl,0x1
    2216:	sete   cl
    2219:	test   cl,cl
    221b:	jne    2239 <botlish_fn_22+0x241>
    2221:	mov    rdi,rbx
    2224:	mov    rax,QWORD PTR [rdi+0x10]
    2228:	mov    rcx,QWORD PTR [rax+0x10]
    222c:	xor    rdx,rdx
    222f:	call   2234 <botlish_fn_22+0x23c>
			2230: R_X86_64_PLT32	rt_type_error-0x4
    2234:	jmp    23a2 <botlish_fn_22+0x3aa>
    2239:	test   rsi,0x1
    2240:	je     2258 <botlish_fn_22+0x260>
    2246:	mov    rcx,rsi
    2249:	add    rcx,0x2
    224d:	seto   al
    2250:	test   al,al
    2252:	je     2268 <botlish_fn_22+0x270>
    2258:	mov    edx,0x3
    225d:	mov    rdi,rbx
    2260:	call   2265 <botlish_fn_22+0x26d>
			2261: R_X86_64_PLT32	rt_int_add-0x4
    2265:	mov    rcx,rax
    2268:	mov    edx,0x7
    226d:	mov    rsi,r12
    2270:	mov    rdi,rbx
    2273:	call   2278 <botlish_fn_22+0x280>
			2274: R_X86_64_PLT32	rt_mutarray_set-0x4
    2278:	test   rax,rax
    227b:	je     23a2 <botlish_fn_22+0x3aa>
    2281:	mov    rax,r13
    2284:	test   rax,0x1
    228a:	jne    22ae <botlish_fn_22+0x2b6>
    2290:	mov    edx,0x5
    2295:	mov    rsi,r13
    2298:	mov    rdi,rbx
    229b:	call   22a0 <botlish_fn_22+0x2a8>
			229c: R_X86_64_PLT32	rt_value_eq-0x4
    22a0:	test   rax,rax
    22a3:	je     23a2 <botlish_fn_22+0x3aa>
    22a9:	jmp    22c2 <botlish_fn_22+0x2ca>
    22ae:	mov    rsi,r13
    22b1:	mov    eax,0x2
    22b6:	cmp    rsi,0x5
    22ba:	cmove  rax,QWORD PTR [rip+0x12e]        # 23f0 <botlish_fn_22+0x3f8>
    22c2:	cmp    rax,0x6
    22c6:	jne    23c7 <botlish_fn_22+0x3cf>
    22cc:	mov    QWORD PTR [rsp+0x8],0x9
    22d5:	mov    rsi,r12
    22d8:	mov    rdi,rbx
    22db:	call   22e0 <botlish_fn_22+0x2e8>
			22dc: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    22e0:	test   rax,rax
    22e3:	je     23a2 <botlish_fn_22+0x3aa>
    22e9:	mov    QWORD PTR [rsp+0x10],rax
    22ee:	mov    QWORD PTR [rsp+0x18],0x3
    22f7:	mov    ecx,0x1
    22fc:	test   rax,0x1
    2302:	je     2310 <botlish_fn_22+0x318>
    2308:	mov    rsi,rax
    230b:	jmp    2334 <botlish_fn_22+0x33c>
    2310:	xor    ecx,ecx
    2312:	test   rax,0x7
    2318:	je     2326 <botlish_fn_22+0x32e>
    231e:	mov    rsi,rax
    2321:	jmp    2334 <botlish_fn_22+0x33c>
    2326:	movzx  rcx,BYTE PTR [rax]
    232a:	mov    rsi,rax
    232d:	rex cmp cl,0x1
    2331:	sete   cl
    2334:	test   cl,cl
    2336:	jne    2354 <botlish_fn_22+0x35c>
    233c:	mov    rdi,rbx
    233f:	mov    rcx,QWORD PTR [rdi+0x10]
    2343:	mov    rcx,QWORD PTR [rcx+0x28]
    2347:	xor    rdx,rdx
    234a:	call   234f <botlish_fn_22+0x357>
			234b: R_X86_64_PLT32	rt_type_error-0x4
    234f:	jmp    23a2 <botlish_fn_22+0x3aa>
    2354:	test   rsi,0x1
    235b:	je     2379 <botlish_fn_22+0x381>
    2361:	mov    r8,rsi
    2364:	sub    r8,0x3
    2368:	seto   dil
    236c:	lea    rcx,[r8+0x1]
    2370:	test   dil,dil
    2373:	je     2389 <botlish_fn_22+0x391>
    2379:	mov    edx,0x3
    237e:	mov    rdi,rbx
    2381:	call   2386 <botlish_fn_22+0x38e>
			2382: R_X86_64_PLT32	rt_int_sub-0x4
    2386:	mov    rcx,rax
    2389:	mov    edx,0x9
    238e:	mov    rsi,r12
    2391:	mov    rdi,rbx
    2394:	call   2399 <botlish_fn_22+0x3a1>
			2395: R_X86_64_PLT32	rt_mutarray_set-0x4
    2399:	test   rax,rax
    239c:	jne    23c7 <botlish_fn_22+0x3cf>
    23a2:	xor    rax,rax
    23a5:	mov    rbx,QWORD PTR [rsp+0x40]
    23aa:	mov    r12,QWORD PTR [rsp+0x48]
    23af:	mov    r13,QWORD PTR [rsp+0x50]
    23b4:	mov    r14,QWORD PTR [rsp+0x58]
    23b9:	mov    r15,QWORD PTR [rsp+0x60]
    23be:	add    rsp,0x70
    23c2:	mov    rsp,rbp
    23c5:	pop    rbp
    23c6:	ret
    23c7:	mov    eax,0xa
    23cc:	mov    rbx,QWORD PTR [rsp+0x40]
    23d1:	mov    r12,QWORD PTR [rsp+0x48]
    23d6:	mov    r13,QWORD PTR [rsp+0x50]
    23db:	mov    r14,QWORD PTR [rsp+0x58]
    23e0:	mov    r15,QWORD PTR [rsp+0x60]
    23e5:	add    rsp,0x70
    23e9:	mov    rsp,rbp
    23ec:	pop    rbp
    23ed:	ret
    23ee:	add    BYTE PTR [rax],al
    23f0:	(bad)
    23f1:	add    BYTE PTR [rax],al
    23f3:	add    BYTE PTR [rax],al
    23f5:	add    BYTE PTR [rax],al
	...

00000000000023f8 <botlish_entry_22: ht_place<mutarray, int, str, str>>:
    23f8:	push   rbp
    23f9:	mov    rbp,rsp
    23fc:	mov    rsi,QWORD PTR [rdx]
    23ff:	mov    r9,QWORD PTR [rdx+0x8]
    2403:	mov    rcx,QWORD PTR [rdx+0x10]
    2407:	mov    r8,QWORD PTR [rdx+0x18]
    240b:	mov    rdx,r9
    240e:	call   2413 <botlish_entry_22+0x1b>
			240f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    2413:	mov    rsp,rbp
    2416:	pop    rbp
    2417:	ret

0000000000002418 <botlish_fn_23: ht_set<mutarray, str, str>>:
    2418:	push   rbp
    2419:	mov    rbp,rsp
    241c:	sub    rsp,0x60
    2420:	mov    QWORD PTR [rsp+0x30],rbx
    2425:	mov    QWORD PTR [rsp+0x38],r12
    242a:	mov    QWORD PTR [rsp+0x40],r13
    242f:	mov    QWORD PTR [rsp+0x48],r14
    2434:	mov    QWORD PTR [rsp+0x50],r15
    2439:	mov    rbx,rdi
    243c:	mov    r13,rdx
    243f:	mov    QWORD PTR [rsp],rsi
    2443:	mov    r14,rsi
    2446:	mov    QWORD PTR [rsp+0x8],rdx
    244b:	mov    QWORD PTR [rsp+0x10],rcx
    2450:	mov    r12,rcx
    2453:	mov    rdx,r13
    2456:	mov    rsi,r14
    2459:	mov    rdi,rbx
    245c:	call   2461 <botlish_fn_23+0x49>
			245d: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2461:	test   rax,rax
    2464:	je     26cf <botlish_fn_23+0x2b7>
    246a:	mov    QWORD PTR [rsp+0x18],rax
    246f:	mov    rcx,rax
    2472:	mov    r8,0xffffffffffffffff
    2479:	mov    QWORD PTR [rsp+0x28],r8
    247e:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    2487:	mov    rdx,r13
    248a:	mov    rsi,r14
    248d:	mov    rdi,rbx
    2490:	call   2495 <botlish_fn_23+0x7d>
			2491: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    2495:	mov    rcx,rax
    2498:	mov    r15,rax
    249b:	test   rax,rcx
    249e:	je     26cf <botlish_fn_23+0x2b7>
    24a4:	mov    rax,r15
    24a7:	mov    QWORD PTR [rsp+0x18],rax
    24ac:	mov    rsi,r14
    24af:	mov    rdi,rbx
    24b2:	call   24b7 <botlish_fn_23+0x9f>
			24b3: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    24b7:	test   rax,rax
    24ba:	je     26cf <botlish_fn_23+0x2b7>
    24c0:	xor    ecx,ecx
    24c2:	test   rax,0x7
    24c8:	je     24d6 <botlish_fn_23+0xbe>
    24ce:	mov    r8,rax
    24d1:	jmp    24e4 <botlish_fn_23+0xcc>
    24d6:	movzx  rcx,BYTE PTR [rax]
    24da:	mov    r8,rax
    24dd:	rex cmp cl,0x8
    24e1:	sete   cl
    24e4:	test   cl,cl
    24e6:	jne    2509 <botlish_fn_23+0xf1>
    24ec:	mov    rdi,rbx
    24ef:	mov    rsi,QWORD PTR [rdi+0x10]
    24f3:	mov    rcx,QWORD PTR [rsi+0x8]
    24f7:	mov    edx,0x8
    24fc:	mov    rsi,r8
    24ff:	call   2504 <botlish_fn_23+0xec>
			2500: R_X86_64_PLT32	rt_type_error-0x4
    2504:	jmp    26cf <botlish_fn_23+0x2b7>
    2509:	mov    rsi,r8
    250c:	mov    rdx,r15
    250f:	mov    rdi,rbx
    2512:	call   2517 <botlish_fn_23+0xff>
			2513: R_X86_64_PLT32	rt_mutarray_get-0x4
    2517:	test   rax,rax
    251a:	je     26cf <botlish_fn_23+0x2b7>
    2520:	test   rax,0x1
    2526:	mov    rsi,rax
    2529:	jne    254a <botlish_fn_23+0x132>
    252f:	mov    edx,0x3
    2534:	mov    rdi,rbx
    2537:	call   253c <botlish_fn_23+0x124>
			2538: R_X86_64_PLT32	rt_value_eq-0x4
    253c:	test   rax,rax
    253f:	je     26cf <botlish_fn_23+0x2b7>
    2545:	jmp    255b <botlish_fn_23+0x143>
    254a:	mov    eax,0x2
    254f:	cmp    rsi,0x3
    2553:	cmove  rax,QWORD PTR [rip+0x1c5]        # 2720 <botlish_fn_23+0x308>
    255b:	cmp    rax,0x6
    255f:	je     265e <botlish_fn_23+0x246>
    2565:	mov    rsi,r14
    2568:	mov    rdi,rbx
    256b:	call   2570 <botlish_fn_23+0x158>
			256c: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    2570:	test   rax,rax
    2573:	je     26cf <botlish_fn_23+0x2b7>
    2579:	cmp    rax,0x6
    257d:	je     25c2 <botlish_fn_23+0x1aa>
    2583:	mov    rcx,r13
    2586:	mov    rdx,r15
    2589:	mov    rsi,r14
    258c:	mov    rdi,rbx
    258f:	mov    r8,r12
    2592:	call   2597 <botlish_fn_23+0x17f>
			2593: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    2597:	test   rax,rax
    259a:	je     26cf <botlish_fn_23+0x2b7>
    25a0:	mov    rbx,QWORD PTR [rsp+0x30]
    25a5:	mov    r12,QWORD PTR [rsp+0x38]
    25aa:	mov    r13,QWORD PTR [rsp+0x40]
    25af:	mov    r14,QWORD PTR [rsp+0x48]
    25b4:	mov    r15,QWORD PTR [rsp+0x50]
    25b9:	add    rsp,0x60
    25bd:	mov    rsp,rbp
    25c0:	pop    rbp
    25c1:	ret
    25c2:	mov    rsi,r14
    25c5:	mov    rdi,rbx
    25c8:	call   25cd <botlish_fn_23+0x1b5>
			25c9: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    25cd:	test   rax,rax
    25d0:	je     26cf <botlish_fn_23+0x2b7>
    25d6:	mov    rdx,r13
    25d9:	mov    rsi,r14
    25dc:	mov    rdi,rbx
    25df:	call   25e4 <botlish_fn_23+0x1cc>
			25e0: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    25e4:	test   rax,rax
    25e7:	je     26cf <botlish_fn_23+0x2b7>
    25ed:	mov    QWORD PTR [rsp+0x18],rax
    25f2:	mov    rcx,rax
    25f5:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    25fe:	mov    r8,QWORD PTR [rsp+0x28]
    2603:	mov    rdx,r13
    2606:	mov    rsi,r14
    2609:	mov    rdi,rbx
    260c:	call   2611 <botlish_fn_23+0x1f9>
			260d: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    2611:	test   rax,rax
    2614:	je     26cf <botlish_fn_23+0x2b7>
    261a:	mov    QWORD PTR [rsp+0x18],rax
    261f:	mov    rcx,r13
    2622:	mov    rdx,rax
    2625:	mov    rsi,r14
    2628:	mov    rdi,rbx
    262b:	mov    r8,r12
    262e:	call   2633 <botlish_fn_23+0x21b>
			262f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    2633:	test   rax,rax
    2636:	je     26cf <botlish_fn_23+0x2b7>
    263c:	mov    rbx,QWORD PTR [rsp+0x30]
    2641:	mov    r12,QWORD PTR [rsp+0x38]
    2646:	mov    r13,QWORD PTR [rsp+0x40]
    264b:	mov    r14,QWORD PTR [rsp+0x48]
    2650:	mov    r15,QWORD PTR [rsp+0x50]
    2655:	add    rsp,0x60
    2659:	mov    rsp,rbp
    265c:	pop    rbp
    265d:	ret
    265e:	mov    rsi,r14
    2661:	mov    rdi,rbx
    2664:	call   2669 <botlish_fn_23+0x251>
			2665: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    2669:	test   rax,rax
    266c:	je     26cf <botlish_fn_23+0x2b7>
    2672:	xor    ecx,ecx
    2674:	test   rax,0x7
    267a:	je     2688 <botlish_fn_23+0x270>
    2680:	mov    rsi,rax
    2683:	jmp    2696 <botlish_fn_23+0x27e>
    2688:	movzx  rcx,BYTE PTR [rax]
    268c:	mov    rsi,rax
    268f:	rex cmp cl,0x8
    2693:	sete   cl
    2696:	test   cl,cl
    2698:	jne    26b8 <botlish_fn_23+0x2a0>
    269e:	mov    rdi,rbx
    26a1:	mov    rax,QWORD PTR [rdi+0x10]
    26a5:	mov    rcx,QWORD PTR [rax+0x20]
    26a9:	mov    edx,0x8
    26ae:	call   26b3 <botlish_fn_23+0x29b>
			26af: R_X86_64_PLT32	rt_type_error-0x4
    26b3:	jmp    26cf <botlish_fn_23+0x2b7>
    26b8:	mov    rcx,r12
    26bb:	mov    rdx,r15
    26be:	mov    rdi,rbx
    26c1:	call   26c6 <botlish_fn_23+0x2ae>
			26c2: R_X86_64_PLT32	rt_mutarray_set-0x4
    26c6:	test   rax,rax
    26c9:	jne    26f4 <botlish_fn_23+0x2dc>
    26cf:	xor    rax,rax
    26d2:	mov    rbx,QWORD PTR [rsp+0x30]
    26d7:	mov    r12,QWORD PTR [rsp+0x38]
    26dc:	mov    r13,QWORD PTR [rsp+0x40]
    26e1:	mov    r14,QWORD PTR [rsp+0x48]
    26e6:	mov    r15,QWORD PTR [rsp+0x50]
    26eb:	add    rsp,0x60
    26ef:	mov    rsp,rbp
    26f2:	pop    rbp
    26f3:	ret
    26f4:	mov    eax,0xa
    26f9:	mov    rbx,QWORD PTR [rsp+0x30]
    26fe:	mov    r12,QWORD PTR [rsp+0x38]
    2703:	mov    r13,QWORD PTR [rsp+0x40]
    2708:	mov    r14,QWORD PTR [rsp+0x48]
    270d:	mov    r15,QWORD PTR [rsp+0x50]
    2712:	add    rsp,0x60
    2716:	mov    rsp,rbp
    2719:	pop    rbp
    271a:	ret
    271b:	add    BYTE PTR [rax],al
    271d:	add    BYTE PTR [rax],al
    271f:	add    BYTE PTR [rsi],al
    2721:	add    BYTE PTR [rax],al
    2723:	add    BYTE PTR [rax],al
    2725:	add    BYTE PTR [rax],al
	...

0000000000002728 <botlish_entry_23: ht_set<mutarray, str, str>>:
    2728:	push   rbp
    2729:	mov    rbp,rsp
    272c:	mov    rsi,QWORD PTR [rdx]
    272f:	mov    r8,QWORD PTR [rdx+0x8]
    2733:	mov    rcx,QWORD PTR [rdx+0x10]
    2737:	mov    rdx,r8
    273a:	call   273f <botlish_entry_23+0x17>
			273b: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    273f:	mov    rsp,rbp
    2742:	pop    rbp
    2743:	ret
    2744:	add    BYTE PTR [rax],al
	...

0000000000002748 <botlish_fn_24: ht_delete<mutarray, str>>:
    2748:	push   rbp
    2749:	mov    rbp,rsp
    274c:	sub    rsp,0x40
    2750:	mov    QWORD PTR [rsp+0x20],rbx
    2755:	mov    QWORD PTR [rsp+0x28],r12
    275a:	mov    QWORD PTR [rsp+0x30],r13
    275f:	mov    rbx,rdi
    2762:	mov    QWORD PTR [rsp+0x18],0x0
    276b:	mov    QWORD PTR [rsp],rsi
    276f:	mov    r12,rsi
    2772:	mov    QWORD PTR [rsp+0x8],rdx
    2777:	mov    r13,rdx
    277a:	mov    rdx,r13
    277d:	mov    rsi,r12
    2780:	mov    rdi,rbx
    2783:	call   2788 <botlish_fn_24+0x40>
			2784: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    2788:	test   rax,rax
    278b:	je     2af8 <botlish_fn_24+0x3b0>
    2791:	mov    QWORD PTR [rsp+0x10],rax
    2796:	mov    rcx,rax
    2799:	mov    rdx,r13
    279c:	mov    rsi,r12
    279f:	mov    rdi,rbx
    27a2:	call   27a7 <botlish_fn_24+0x5f>
			27a3: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    27a7:	mov    rcx,rax
    27aa:	mov    r13,rax
    27ad:	test   rax,rcx
    27b0:	je     2af8 <botlish_fn_24+0x3b0>
    27b6:	mov    rax,r13
    27b9:	test   rax,0x1
    27bf:	jne    27ea <botlish_fn_24+0xa2>
    27c5:	mov    edx,0x1
    27ca:	mov    rsi,r13
    27cd:	mov    rdi,rbx
    27d0:	call   27d5 <botlish_fn_24+0x8d>
			27d1: R_X86_64_PLT32	rt_int_cmp-0x4
    27d5:	mov    ecx,0x2
    27da:	test   rax,rax
    27dd:	cmovl  rcx,QWORD PTR [rip+0x36b]        # 2b50 <botlish_fn_24+0x408>
    27e5:	jmp    2800 <botlish_fn_24+0xb8>
    27ea:	mov    ecx,0x2
    27ef:	mov    rax,r13
    27f2:	mov    rdx,r13
    27f5:	test   rax,rdx
    27f8:	cmovle rcx,QWORD PTR [rip+0x350]        # 2b50 <botlish_fn_24+0x408>
    2800:	cmp    rcx,0x6
    2804:	je     2b30 <botlish_fn_24+0x3e8>
    280a:	mov    rsi,r12
    280d:	mov    rdi,rbx
    2810:	call   2815 <botlish_fn_24+0xcd>
			2811: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    2815:	test   rax,rax
    2818:	je     2af8 <botlish_fn_24+0x3b0>
    281e:	xor    ecx,ecx
    2820:	test   rax,0x7
    2826:	je     2834 <botlish_fn_24+0xec>
    282c:	mov    rsi,rax
    282f:	jmp    2842 <botlish_fn_24+0xfa>
    2834:	movzx  rcx,BYTE PTR [rax]
    2838:	mov    rsi,rax
    283b:	rex cmp cl,0x8
    283f:	sete   cl
    2842:	test   cl,cl
    2844:	jne    2864 <botlish_fn_24+0x11c>
    284a:	mov    rdi,rbx
    284d:	mov    rax,QWORD PTR [rdi+0x10]
    2851:	mov    rcx,QWORD PTR [rax+0x20]
    2855:	mov    edx,0x8
    285a:	call   285f <botlish_fn_24+0x117>
			285b: R_X86_64_PLT32	rt_type_error-0x4
    285f:	jmp    2af8 <botlish_fn_24+0x3b0>
    2864:	mov    ecx,0x5
    2869:	mov    rdx,r13
    286c:	mov    rdi,rbx
    286f:	call   2874 <botlish_fn_24+0x12c>
			2870: R_X86_64_PLT32	rt_mutarray_set-0x4
    2874:	test   rax,rax
    2877:	je     2af8 <botlish_fn_24+0x3b0>
    287d:	mov    rsi,r12
    2880:	mov    rdi,rbx
    2883:	call   2888 <botlish_fn_24+0x140>
			2884: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    2888:	test   rax,rax
    288b:	je     2af8 <botlish_fn_24+0x3b0>
    2891:	xor    ecx,ecx
    2893:	test   rax,0x7
    2899:	jne    28aa <botlish_fn_24+0x162>
    289f:	movzx  rsi,BYTE PTR [rax]
    28a3:	cmp    sil,0x8
    28a7:	sete   cl
    28aa:	test   cl,cl
    28ac:	jne    28cf <botlish_fn_24+0x187>
    28b2:	mov    rdi,rbx
    28b5:	mov    r9,QWORD PTR [rdi+0x10]
    28b9:	mov    rcx,QWORD PTR [r9+0x20]
    28bd:	mov    edx,0x8
    28c2:	mov    rsi,rax
    28c5:	call   28ca <botlish_fn_24+0x182>
			28c6: R_X86_64_PLT32	rt_type_error-0x4
    28ca:	jmp    2af8 <botlish_fn_24+0x3b0>
    28cf:	mov    rsi,rax
    28d2:	mov    ecx,0xa
    28d7:	mov    rdx,r13
    28da:	mov    rdi,rbx
    28dd:	call   28e2 <botlish_fn_24+0x19a>
			28de: R_X86_64_PLT32	rt_mutarray_set-0x4
    28e2:	test   rax,rax
    28e5:	je     2af8 <botlish_fn_24+0x3b0>
    28eb:	mov    rsi,r12
    28ee:	mov    rdi,rbx
    28f1:	call   28f6 <botlish_fn_24+0x1ae>
			28f2: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    28f6:	test   rax,rax
    28f9:	je     2af8 <botlish_fn_24+0x3b0>
    28ff:	xor    ecx,ecx
    2901:	test   rax,0x7
    2907:	je     2915 <botlish_fn_24+0x1cd>
    290d:	mov    rsi,rax
    2910:	jmp    2923 <botlish_fn_24+0x1db>
    2915:	movzx  rcx,BYTE PTR [rax]
    2919:	mov    rsi,rax
    291c:	rex cmp cl,0x8
    2920:	sete   cl
    2923:	test   cl,cl
    2925:	jne    2945 <botlish_fn_24+0x1fd>
    292b:	mov    rdi,rbx
    292e:	mov    rax,QWORD PTR [rdi+0x10]
    2932:	mov    rcx,QWORD PTR [rax+0x20]
    2936:	mov    edx,0x8
    293b:	call   2940 <botlish_fn_24+0x1f8>
			293c: R_X86_64_PLT32	rt_type_error-0x4
    2940:	jmp    2af8 <botlish_fn_24+0x3b0>
    2945:	mov    ecx,0xa
    294a:	mov    rdx,r13
    294d:	mov    rdi,rbx
    2950:	call   2955 <botlish_fn_24+0x20d>
			2951: R_X86_64_PLT32	rt_mutarray_set-0x4
    2955:	test   rax,rax
    2958:	je     2af8 <botlish_fn_24+0x3b0>
    295e:	mov    QWORD PTR [rsp+0x8],0x7
    2967:	mov    rsi,r12
    296a:	mov    rdi,rbx
    296d:	call   2972 <botlish_fn_24+0x22a>
			296e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2972:	test   rax,rax
    2975:	je     2af8 <botlish_fn_24+0x3b0>
    297b:	mov    QWORD PTR [rsp+0x10],rax
    2980:	mov    QWORD PTR [rsp+0x18],0x3
    2989:	mov    ecx,0x1
    298e:	test   rax,0x1
    2994:	je     29a2 <botlish_fn_24+0x25a>
    299a:	mov    rsi,rax
    299d:	jmp    29c6 <botlish_fn_24+0x27e>
    29a2:	xor    ecx,ecx
    29a4:	test   rax,0x7
    29aa:	je     29b8 <botlish_fn_24+0x270>
    29b0:	mov    rsi,rax
    29b3:	jmp    29c6 <botlish_fn_24+0x27e>
    29b8:	movzx  rcx,BYTE PTR [rax]
    29bc:	mov    rsi,rax
    29bf:	rex cmp cl,0x1
    29c3:	sete   cl
    29c6:	test   cl,cl
    29c8:	jne    29e6 <botlish_fn_24+0x29e>
    29ce:	mov    rdi,rbx
    29d1:	mov    rax,QWORD PTR [rdi+0x10]
    29d5:	mov    rcx,QWORD PTR [rax+0x28]
    29d9:	xor    rdx,rdx
    29dc:	call   29e1 <botlish_fn_24+0x299>
			29dd: R_X86_64_PLT32	rt_type_error-0x4
    29e1:	jmp    2af8 <botlish_fn_24+0x3b0>
    29e6:	test   rsi,0x1
    29ed:	je     2a0c <botlish_fn_24+0x2c4>
    29f3:	mov    rcx,rsi
    29f6:	sub    rcx,0x3
    29fa:	seto   al
    29fd:	add    rcx,0x1
    2a04:	test   al,al
    2a06:	je     2a1c <botlish_fn_24+0x2d4>
    2a0c:	mov    edx,0x3
    2a11:	mov    rdi,rbx
    2a14:	call   2a19 <botlish_fn_24+0x2d1>
			2a15: R_X86_64_PLT32	rt_int_sub-0x4
    2a19:	mov    rcx,rax
    2a1c:	mov    edx,0x7
    2a21:	mov    rsi,r12
    2a24:	mov    rdi,rbx
    2a27:	call   2a2c <botlish_fn_24+0x2e4>
			2a28: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a2c:	test   rax,rax
    2a2f:	je     2af8 <botlish_fn_24+0x3b0>
    2a35:	mov    QWORD PTR [rsp+0x8],0x9
    2a3e:	mov    rsi,r12
    2a41:	mov    rdi,rbx
    2a44:	call   2a49 <botlish_fn_24+0x301>
			2a45: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2a49:	test   rax,rax
    2a4c:	je     2af8 <botlish_fn_24+0x3b0>
    2a52:	mov    QWORD PTR [rsp+0x10],rax
    2a57:	mov    QWORD PTR [rsp+0x18],0x3
    2a60:	mov    ecx,0x1
    2a65:	test   rax,0x1
    2a6b:	jne    2a8a <botlish_fn_24+0x342>
    2a71:	xor    ecx,ecx
    2a73:	test   rax,0x7
    2a79:	jne    2a8a <botlish_fn_24+0x342>
    2a7f:	movzx  rsi,BYTE PTR [rax]
    2a83:	cmp    sil,0x1
    2a87:	sete   cl
    2a8a:	test   cl,cl
    2a8c:	jne    2aad <botlish_fn_24+0x365>
    2a92:	mov    rdi,rbx
    2a95:	mov    r8,QWORD PTR [rdi+0x10]
    2a99:	mov    rcx,QWORD PTR [r8+0x10]
    2a9d:	xor    rdx,rdx
    2aa0:	mov    rsi,rax
    2aa3:	call   2aa8 <botlish_fn_24+0x360>
			2aa4: R_X86_64_PLT32	rt_type_error-0x4
    2aa8:	jmp    2af8 <botlish_fn_24+0x3b0>
    2aad:	mov    rsi,rax
    2ab0:	test   rsi,0x1
    2ab7:	je     2acf <botlish_fn_24+0x387>
    2abd:	mov    rcx,rsi
    2ac0:	add    rcx,0x2
    2ac4:	seto   al
    2ac7:	test   al,al
    2ac9:	je     2adf <botlish_fn_24+0x397>
    2acf:	mov    edx,0x3
    2ad4:	mov    rdi,rbx
    2ad7:	call   2adc <botlish_fn_24+0x394>
			2ad8: R_X86_64_PLT32	rt_int_add-0x4
    2adc:	mov    rcx,rax
    2adf:	mov    edx,0x9
    2ae4:	mov    rsi,r12
    2ae7:	mov    rdi,rbx
    2aea:	call   2aef <botlish_fn_24+0x3a7>
			2aeb: R_X86_64_PLT32	rt_mutarray_set-0x4
    2aef:	test   rax,rax
    2af2:	jne    2b13 <botlish_fn_24+0x3cb>
    2af8:	xor    rax,rax
    2afb:	mov    rbx,QWORD PTR [rsp+0x20]
    2b00:	mov    r12,QWORD PTR [rsp+0x28]
    2b05:	mov    r13,QWORD PTR [rsp+0x30]
    2b0a:	add    rsp,0x40
    2b0e:	mov    rsp,rbp
    2b11:	pop    rbp
    2b12:	ret
    2b13:	mov    eax,0xa
    2b18:	mov    rbx,QWORD PTR [rsp+0x20]
    2b1d:	mov    r12,QWORD PTR [rsp+0x28]
    2b22:	mov    r13,QWORD PTR [rsp+0x30]
    2b27:	add    rsp,0x40
    2b2b:	mov    rsp,rbp
    2b2e:	pop    rbp
    2b2f:	ret
    2b30:	mov    eax,0xa
    2b35:	mov    rbx,QWORD PTR [rsp+0x20]
    2b3a:	mov    r12,QWORD PTR [rsp+0x28]
    2b3f:	mov    r13,QWORD PTR [rsp+0x30]
    2b44:	add    rsp,0x40
    2b48:	mov    rsp,rbp
    2b4b:	pop    rbp
    2b4c:	ret
    2b4d:	add    BYTE PTR [rax],al
    2b4f:	add    BYTE PTR [rsi],al
    2b51:	add    BYTE PTR [rax],al
    2b53:	add    BYTE PTR [rax],al
    2b55:	add    BYTE PTR [rax],al
	...

0000000000002b58 <botlish_entry_24: ht_delete<mutarray, str>>:
    2b58:	push   rbp
    2b59:	mov    rbp,rsp
    2b5c:	mov    rsi,QWORD PTR [rdx]
    2b5f:	mov    rdx,QWORD PTR [rdx+0x8]
    2b63:	call   2b68 <botlish_entry_24+0x10>
			2b64: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2b68:	mov    rsp,rbp
    2b6b:	pop    rbp
    2b6c:	ret
    2b6d:	add    BYTE PTR [rax],al
	...

0000000000002b70 <botlish_fn_25: sample_checks<generic>>:
    2b70:	push   rbp
    2b71:	mov    rbp,rsp
    2b74:	sub    rsp,0xa0
    2b7b:	mov    QWORD PTR [rsp+0x70],rbx
    2b80:	mov    QWORD PTR [rsp+0x78],r12
    2b85:	mov    QWORD PTR [rsp+0x80],r13
    2b8d:	mov    QWORD PTR [rsp+0x88],r14
    2b95:	mov    QWORD PTR [rsp+0x90],r15
    2b9d:	mov    r14,rdi
    2ba0:	mov    QWORD PTR [rsp],0x0
    2ba8:	mov    QWORD PTR [rsp+0x8],0x0
    2bb1:	mov    QWORD PTR [rsp+0x10],0x0
    2bba:	mov    QWORD PTR [rsp+0x18],0x0
    2bc3:	mov    QWORD PTR [rsp+0x20],0x0
    2bcc:	mov    QWORD PTR [rsp+0x28],0x0
    2bd5:	mov    rdi,r14
    2bd8:	call   2bdd <botlish_fn_25+0x6d>
			2bd9: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    2bdd:	mov    rcx,rax
    2be0:	mov    r15,rax
    2be3:	test   rax,rcx
    2be6:	je     2e26 <botlish_fn_25+0x2b6>
    2bec:	mov    rax,r15
    2bef:	mov    QWORD PTR [rsp],rax
    2bf3:	mov    rdi,r14
    2bf6:	mov    rax,QWORD PTR [rdi+0x10]
    2bfa:	mov    rdx,QWORD PTR [rax+0x30]
    2bfe:	mov    QWORD PTR [rsp+0x8],rdx
    2c03:	mov    rax,QWORD PTR [rdi+0x10]
    2c07:	mov    rcx,QWORD PTR [rax+0x38]
    2c0b:	mov    QWORD PTR [rsp+0x10],rcx
    2c10:	mov    rsi,r15
    2c13:	call   2c18 <botlish_fn_25+0xa8>
			2c14: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c18:	test   rax,rax
    2c1b:	je     2e26 <botlish_fn_25+0x2b6>
    2c21:	mov    rdi,r14
    2c24:	mov    rsi,QWORD PTR [rdi+0x10]
    2c28:	mov    rdx,QWORD PTR [rsi+0x40]
    2c2c:	mov    QWORD PTR [rsp+0x8],rdx
    2c31:	mov    rsi,QWORD PTR [rdi+0x10]
    2c35:	mov    rcx,QWORD PTR [rsi+0x48]
    2c39:	mov    QWORD PTR [rsp+0x10],rcx
    2c3e:	mov    rsi,r15
    2c41:	call   2c46 <botlish_fn_25+0xd6>
			2c42: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c46:	test   rax,rax
    2c49:	je     2e26 <botlish_fn_25+0x2b6>
    2c4f:	mov    rdi,r14
    2c52:	mov    r9,QWORD PTR [rdi+0x10]
    2c56:	mov    rdx,QWORD PTR [r9+0x30]
    2c5a:	mov    QWORD PTR [rsp+0x8],rdx
    2c5f:	mov    r10,QWORD PTR [rdi+0x10]
    2c63:	mov    rcx,QWORD PTR [r10+0x50]
    2c67:	mov    QWORD PTR [rsp+0x10],rcx
    2c6c:	mov    rsi,r15
    2c6f:	call   2c74 <botlish_fn_25+0x104>
			2c70: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c74:	test   rax,rax
    2c77:	je     2e26 <botlish_fn_25+0x2b6>
    2c7d:	mov    rdi,r14
    2c80:	mov    rax,QWORD PTR [rdi+0x10]
    2c84:	mov    rdx,QWORD PTR [rax+0x40]
    2c88:	mov    QWORD PTR [rsp+0x8],rdx
    2c8d:	mov    rsi,r15
    2c90:	call   2c95 <botlish_fn_25+0x125>
			2c91: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2c95:	mov    rbx,rax
    2c98:	test   rbx,rbx
    2c9b:	je     2e26 <botlish_fn_25+0x2b6>
    2ca1:	mov    QWORD PTR [rsp+0x8],rbx
    2ca6:	mov    rdi,r14
    2ca9:	mov    rax,QWORD PTR [rdi+0x10]
    2cad:	mov    rdx,QWORD PTR [rax+0x40]
    2cb1:	mov    QWORD PTR [rsp+0x10],rdx
    2cb6:	mov    rsi,r15
    2cb9:	call   2cbe <botlish_fn_25+0x14e>
			2cba: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2cbe:	test   rax,rax
    2cc1:	je     2e26 <botlish_fn_25+0x2b6>
    2cc7:	mov    rdi,r14
    2cca:	mov    rax,QWORD PTR [rdi+0x10]
    2cce:	mov    rdx,QWORD PTR [rax+0x30]
    2cd2:	mov    QWORD PTR [rsp+0x10],rdx
    2cd7:	mov    rsi,r15
    2cda:	call   2cdf <botlish_fn_25+0x16f>
			2cdb: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2cdf:	test   rax,rax
    2ce2:	je     2e26 <botlish_fn_25+0x2b6>
    2ce8:	mov    rdi,r14
    2ceb:	mov    rcx,QWORD PTR [rdi+0x10]
    2cef:	mov    rdx,QWORD PTR [rcx+0x50]
    2cf3:	mov    rcx,rax
    2cf6:	and    rcx,rdx
    2cf9:	mov    rsi,rax
    2cfc:	test   rcx,0x1
    2d03:	jne    2d1f <botlish_fn_25+0x1af>
    2d09:	mov    rdi,r14
    2d0c:	call   2d11 <botlish_fn_25+0x1a1>
			2d0d: R_X86_64_PLT32	rt_value_eq-0x4
    2d11:	test   rax,rax
    2d14:	je     2e26 <botlish_fn_25+0x2b6>
    2d1a:	jmp    2d2f <botlish_fn_25+0x1bf>
    2d1f:	mov    eax,0x2
    2d24:	cmp    rsi,rdx
    2d27:	cmove  rax,QWORD PTR [rip+0x159]        # 2e88 <botlish_fn_25+0x318>
    2d2f:	mov    QWORD PTR [rsp+0x10],rax
    2d34:	mov    rdi,r14
    2d37:	mov    QWORD PTR [rsp+0x60],rax
    2d3c:	mov    rax,QWORD PTR [rdi+0x10]
    2d40:	mov    rdx,QWORD PTR [rax+0x40]
    2d44:	mov    QWORD PTR [rsp+0x18],rdx
    2d49:	mov    rsi,r15
    2d4c:	call   2d51 <botlish_fn_25+0x1e1>
			2d4d: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2d51:	mov    r12,rax
    2d54:	test   r12,r12
    2d57:	je     2e26 <botlish_fn_25+0x2b6>
    2d5d:	mov    QWORD PTR [rsp+0x18],r12
    2d62:	mov    rdi,r14
    2d65:	mov    rax,QWORD PTR [rdi+0x10]
    2d69:	mov    rdx,QWORD PTR [rax+0x58]
    2d6d:	mov    QWORD PTR [rsp+0x20],rdx
    2d72:	mov    rsi,r15
    2d75:	call   2d7a <botlish_fn_25+0x20a>
			2d76: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2d7a:	mov    r13,rax
    2d7d:	test   r13,r13
    2d80:	je     2e26 <botlish_fn_25+0x2b6>
    2d86:	mov    QWORD PTR [rsp+0x20],r13
    2d8b:	mov    rdi,r14
    2d8e:	mov    rax,QWORD PTR [rdi+0x10]
    2d92:	mov    rdx,QWORD PTR [rax+0x58]
    2d96:	mov    QWORD PTR [rsp+0x28],rdx
    2d9b:	mov    rsi,r15
    2d9e:	call   2da3 <botlish_fn_25+0x233>
			2d9f: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2da3:	test   rax,rax
    2da6:	mov    rsi,rax
    2da9:	je     2e26 <botlish_fn_25+0x2b6>
    2daf:	mov    edx,0xa
    2db4:	mov    rdi,r14
    2db7:	call   2dbc <botlish_fn_25+0x24c>
			2db8: R_X86_64_PLT32	rt_value_eq-0x4
    2dbc:	test   rax,rax
    2dbf:	je     2e26 <botlish_fn_25+0x2b6>
    2dc5:	mov    QWORD PTR [rsp],rax
    2dc9:	mov    rsi,r15
    2dcc:	mov    r15,rax
    2dcf:	mov    rdi,r14
    2dd2:	call   2dd7 <botlish_fn_25+0x267>
			2dd3: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2dd7:	test   rax,rax
    2dda:	je     2e26 <botlish_fn_25+0x2b6>
    2de0:	mov    QWORD PTR [rsp+0x28],rax
    2de5:	lea    rdx,[rsp+0x30]
    2dea:	mov    rsi,QWORD PTR [rsp+0x60]
    2def:	mov    QWORD PTR [rsp+0x30],rsi
    2df4:	mov    QWORD PTR [rsp+0x38],rbx
    2df9:	mov    QWORD PTR [rsp+0x40],r12
    2dfe:	mov    QWORD PTR [rsp+0x48],r13
    2e03:	mov    r8,r15
    2e06:	mov    QWORD PTR [rsp+0x50],r8
    2e0b:	mov    QWORD PTR [rsp+0x58],rax
    2e10:	mov    esi,0x6
    2e15:	mov    rdi,r14
    2e18:	call   2e1d <botlish_fn_25+0x2ad>
			2e19: R_X86_64_PLT32	rt_list_new-0x4
    2e1d:	test   rax,rax
    2e20:	jne    2e57 <botlish_fn_25+0x2e7>
    2e26:	xor    rax,rax
    2e29:	mov    rbx,QWORD PTR [rsp+0x70]
    2e2e:	mov    r12,QWORD PTR [rsp+0x78]
    2e33:	mov    r13,QWORD PTR [rsp+0x80]
    2e3b:	mov    r14,QWORD PTR [rsp+0x88]
    2e43:	mov    r15,QWORD PTR [rsp+0x90]
    2e4b:	add    rsp,0xa0
    2e52:	mov    rsp,rbp
    2e55:	pop    rbp
    2e56:	ret
    2e57:	mov    rbx,QWORD PTR [rsp+0x70]
    2e5c:	mov    r12,QWORD PTR [rsp+0x78]
    2e61:	mov    r13,QWORD PTR [rsp+0x80]
    2e69:	mov    r14,QWORD PTR [rsp+0x88]
    2e71:	mov    r15,QWORD PTR [rsp+0x90]
    2e79:	add    rsp,0xa0
    2e80:	mov    rsp,rbp
    2e83:	pop    rbp
    2e84:	ret
    2e85:	add    BYTE PTR [rax],al
    2e87:	add    BYTE PTR [rsi],al
    2e89:	add    BYTE PTR [rax],al
    2e8b:	add    BYTE PTR [rax],al
    2e8d:	add    BYTE PTR [rax],al
	...

0000000000002e90 <botlish_entry_25: sample_checks<generic>>:
    2e90:	push   rbp
    2e91:	mov    rbp,rsp
    2e94:	call   2e99 <botlish_entry_25+0x9>
			2e95: R_X86_64_PLT32	botlish_fn_25-0x4 ; sample_checks<generic>
    2e99:	mov    rsp,rbp
    2e9c:	pop    rbp
    2e9d:	ret

0000000000002e9e <botlish_fn_26: sample<generic>>:
    2e9e:	push   rbp
    2e9f:	mov    rbp,rsp
    2ea2:	sub    rsp,0x10
    2ea6:	mov    QWORD PTR [rsp],r12
    2eaa:	mov    r12,rdi
    2ead:	mov    rdi,r12
    2eb0:	call   2eb5 <botlish_fn_26+0x17>
			2eb1: R_X86_64_PLT32	botlish_fn_25-0x4 ; sample_checks<generic>
    2eb5:	test   rax,rax
    2eb8:	jne    2f01 <botlish_fn_26+0x63>
    2ebe:	mov    rdi,r12
    2ec1:	call   2ec6 <botlish_fn_26+0x28>
			2ec2: R_X86_64_PLT32	rt_declared_error-0x4
    2ec6:	cmp    rax,0x40000001
    2ecc:	jne    2ef1 <botlish_fn_26+0x53>
    2ed2:	mov    rdi,r12
    2ed5:	call   2eda <botlish_fn_26+0x3c>
			2ed6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    2eda:	xor    rdx,rdx
    2edd:	mov    rdi,r12
    2ee0:	mov    rsi,rdx
    2ee3:	call   2ee8 <botlish_fn_26+0x4a>
			2ee4: R_X86_64_PLT32	rt_list_new-0x4
    2ee8:	test   rax,rax
    2eeb:	jne    2f01 <botlish_fn_26+0x63>
    2ef1:	xor    rax,rax
    2ef4:	mov    r12,QWORD PTR [rsp]
    2ef8:	add    rsp,0x10
    2efc:	mov    rsp,rbp
    2eff:	pop    rbp
    2f00:	ret
    2f01:	mov    r12,QWORD PTR [rsp]
    2f05:	add    rsp,0x10
    2f09:	mov    rsp,rbp
    2f0c:	pop    rbp
    2f0d:	ret

0000000000002f0e <botlish_entry_26: sample<generic>>:
    2f0e:	push   rbp
    2f0f:	mov    rbp,rsp
    2f12:	call   2f17 <botlish_entry_26+0x9>
			2f13: R_X86_64_PLT32	botlish_fn_26-0x4 ; sample<generic>
    2f17:	mov    rsp,rbp
    2f1a:	pop    rbp
    2f1b:	ret

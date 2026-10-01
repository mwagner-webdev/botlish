; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12799  (per function: 45 388 557 50 61 61 61 61 61 198 185 252 804 1248 429 253 380 439 977 784 809 665 1168 836 1189 838)
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
     1c0:	mov    r13,rsi
     1c3:	mov    QWORD PTR [rsp+0x8],0x0
     1cc:	mov    QWORD PTR [rsp+0x10],0x0
     1d5:	mov    QWORD PTR [rsp+0x18],0x0
     1de:	mov    rsi,r13
     1e1:	shl    rsi,1
     1e4:	mov    r13,rsi
     1e7:	or     rsi,0x1
     1eb:	mov    QWORD PTR [rsp],rsi
     1ef:	mov    rdi,rbx
     1f2:	call   1f7 <botlish_fn_2+0x5b>
			1f3: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     1f7:	test   rax,rax
     1fa:	je     328 <botlish_fn_2+0x18c>
     200:	mov    QWORD PTR [rsp+0x8],rax
     205:	mov    r12,rax
     208:	mov    edx,0x1
     20d:	mov    QWORD PTR [rsp+0x10],0x1
     216:	mov    rsi,r13
     219:	mov    rcx,rsi
     21c:	or     rcx,0x1
     220:	mov    rsi,r12
     223:	mov    rdi,rbx
     226:	call   22b <botlish_fn_2+0x8f>
			227: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
     22b:	test   rax,rax
     22e:	je     328 <botlish_fn_2+0x18c>
     234:	mov    rsi,r13
     237:	or     rsi,0x1
     23b:	mov    rdi,rbx
     23e:	call   243 <botlish_fn_2+0xa7>
			23f: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     243:	test   rax,rax
     246:	je     328 <botlish_fn_2+0x18c>
     24c:	mov    QWORD PTR [rsp+0x10],rax
     251:	mov    rsi,r13
     254:	mov    r14,rax
     257:	or     rsi,0x1
     25b:	mov    r13,rsi
     25e:	mov    rdi,rbx
     261:	call   266 <botlish_fn_2+0xca>
			262: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     266:	test   rax,rax
     269:	je     328 <botlish_fn_2+0x18c>
     26f:	mov    QWORD PTR [rsp],rax
     273:	mov    r13,rax
     276:	mov    esi,0xb
     27b:	mov    QWORD PTR [rsp+0x18],0xb
     284:	mov    rdi,rbx
     287:	call   28c <botlish_fn_2+0xf0>
			288: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     28c:	test   rax,rax
     28f:	mov    r15,rax
     292:	je     328 <botlish_fn_2+0x18c>
     298:	mov    edx,0x1
     29d:	mov    rcx,r12
     2a0:	mov    rsi,r15
     2a3:	mov    rdi,rbx
     2a6:	call   2ab <botlish_fn_2+0x10f>
			2a7: R_X86_64_PLT32	rt_mutarray_set-0x4
     2ab:	test   rax,rax
     2ae:	je     328 <botlish_fn_2+0x18c>
     2b4:	mov    edx,0x3
     2b9:	mov    rcx,r14
     2bc:	mov    rsi,r15
     2bf:	mov    rdi,rbx
     2c2:	call   2c7 <botlish_fn_2+0x12b>
			2c3: R_X86_64_PLT32	rt_mutarray_set-0x4
     2c7:	test   rax,rax
     2ca:	je     328 <botlish_fn_2+0x18c>
     2d0:	mov    edx,0x5
     2d5:	mov    rcx,r13
     2d8:	mov    rsi,r15
     2db:	mov    rdi,rbx
     2de:	call   2e3 <botlish_fn_2+0x147>
			2df: R_X86_64_PLT32	rt_mutarray_set-0x4
     2e3:	test   rax,rax
     2e6:	je     328 <botlish_fn_2+0x18c>
     2ec:	mov    edx,0x7
     2f1:	mov    ecx,0x1
     2f6:	mov    rsi,r15
     2f9:	mov    rdi,rbx
     2fc:	call   301 <botlish_fn_2+0x165>
			2fd: R_X86_64_PLT32	rt_mutarray_set-0x4
     301:	test   rax,rax
     304:	je     328 <botlish_fn_2+0x18c>
     30a:	mov    edx,0x9
     30f:	mov    ecx,0x1
     314:	mov    rdi,rbx
     317:	mov    rsi,r15
     31a:	call   31f <botlish_fn_2+0x183>
			31b: R_X86_64_PLT32	rt_mutarray_set-0x4
     31f:	test   rax,rax
     322:	jne    34d <botlish_fn_2+0x1b1>
     328:	xor    rax,rax
     32b:	mov    rbx,QWORD PTR [rsp+0x20]
     330:	mov    r12,QWORD PTR [rsp+0x28]
     335:	mov    r13,QWORD PTR [rsp+0x30]
     33a:	mov    r14,QWORD PTR [rsp+0x38]
     33f:	mov    r15,QWORD PTR [rsp+0x40]
     344:	add    rsp,0x50
     348:	mov    rsp,rbp
     34b:	pop    rbp
     34c:	ret
     34d:	mov    rax,r15
     350:	mov    rbx,QWORD PTR [rsp+0x20]
     355:	mov    r12,QWORD PTR [rsp+0x28]
     35a:	mov    r13,QWORD PTR [rsp+0x30]
     35f:	mov    r14,QWORD PTR [rsp+0x38]
     364:	mov    r15,QWORD PTR [rsp+0x40]
     369:	add    rsp,0x50
     36d:	mov    rsp,rbp
     370:	pop    rbp
     371:	ret

0000000000000372 <botlish_entry_2: ht_alloc<int>>:
     372:	push   rbp
     373:	mov    rbp,rsp
     376:	mov    rsi,QWORD PTR [rdx]
     379:	sar    rsi,1
     37c:	call   381 <botlish_entry_2+0xf>
			37d: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
     381:	mov    rsp,rbp
     384:	pop    rbp
     385:	ret

0000000000000386 <botlish_fn_3: ht_new<generic>>:
     386:	push   rbp
     387:	mov    rbp,rsp
     38a:	mov    esi,0x8
     38f:	call   394 <botlish_fn_3+0xe>
			390: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
     394:	test   rax,rax
     397:	jne    3a5 <botlish_fn_3+0x1f>
     39d:	xor    rax,rax
     3a0:	mov    rsp,rbp
     3a3:	pop    rbp
     3a4:	ret
     3a5:	mov    rsp,rbp
     3a8:	pop    rbp
     3a9:	ret

00000000000003aa <botlish_entry_3: ht_new<generic>>:
     3aa:	push   rbp
     3ab:	mov    rbp,rsp
     3ae:	call   3b3 <botlish_entry_3+0x9>
			3af: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
     3b3:	mov    rsp,rbp
     3b6:	pop    rbp
     3b7:	ret

00000000000003b8 <botlish_fn_4: ht_controls<mutarray>>:
     3b8:	push   rbp
     3b9:	mov    rbp,rsp
     3bc:	mov    edx,0x1
     3c1:	call   3c6 <botlish_fn_4+0xe>
			3c2: R_X86_64_PLT32	rt_mutarray_get-0x4
     3c6:	test   rax,rax
     3c9:	jne    3d7 <botlish_fn_4+0x1f>
     3cf:	xor    rax,rax
     3d2:	mov    rsp,rbp
     3d5:	pop    rbp
     3d6:	ret
     3d7:	mov    rsp,rbp
     3da:	pop    rbp
     3db:	ret

00000000000003dc <botlish_entry_4: ht_controls<mutarray>>:
     3dc:	push   rbp
     3dd:	mov    rbp,rsp
     3e0:	mov    rsi,QWORD PTR [rdx]
     3e3:	call   3e8 <botlish_entry_4+0xc>
			3e4: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     3e8:	mov    rsp,rbp
     3eb:	pop    rbp
     3ec:	ret

00000000000003ed <botlish_fn_5: ht_keys<mutarray>>:
     3ed:	push   rbp
     3ee:	mov    rbp,rsp
     3f1:	mov    edx,0x3
     3f6:	call   3fb <botlish_fn_5+0xe>
			3f7: R_X86_64_PLT32	rt_mutarray_get-0x4
     3fb:	test   rax,rax
     3fe:	jne    40c <botlish_fn_5+0x1f>
     404:	xor    rax,rax
     407:	mov    rsp,rbp
     40a:	pop    rbp
     40b:	ret
     40c:	mov    rsp,rbp
     40f:	pop    rbp
     410:	ret

0000000000000411 <botlish_entry_5: ht_keys<mutarray>>:
     411:	push   rbp
     412:	mov    rbp,rsp
     415:	mov    rsi,QWORD PTR [rdx]
     418:	call   41d <botlish_entry_5+0xc>
			419: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     41d:	mov    rsp,rbp
     420:	pop    rbp
     421:	ret

0000000000000422 <botlish_fn_6: ht_values<mutarray>>:
     422:	push   rbp
     423:	mov    rbp,rsp
     426:	mov    edx,0x5
     42b:	call   430 <botlish_fn_6+0xe>
			42c: R_X86_64_PLT32	rt_mutarray_get-0x4
     430:	test   rax,rax
     433:	jne    441 <botlish_fn_6+0x1f>
     439:	xor    rax,rax
     43c:	mov    rsp,rbp
     43f:	pop    rbp
     440:	ret
     441:	mov    rsp,rbp
     444:	pop    rbp
     445:	ret

0000000000000446 <botlish_entry_6: ht_values<mutarray>>:
     446:	push   rbp
     447:	mov    rbp,rsp
     44a:	mov    rsi,QWORD PTR [rdx]
     44d:	call   452 <botlish_entry_6+0xc>
			44e: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
     452:	mov    rsp,rbp
     455:	pop    rbp
     456:	ret

0000000000000457 <botlish_fn_7: ht_size<mutarray>>:
     457:	push   rbp
     458:	mov    rbp,rsp
     45b:	mov    edx,0x7
     460:	call   465 <botlish_fn_7+0xe>
			461: R_X86_64_PLT32	rt_mutarray_get-0x4
     465:	test   rax,rax
     468:	jne    476 <botlish_fn_7+0x1f>
     46e:	xor    rax,rax
     471:	mov    rsp,rbp
     474:	pop    rbp
     475:	ret
     476:	mov    rsp,rbp
     479:	pop    rbp
     47a:	ret

000000000000047b <botlish_entry_7: ht_size<mutarray>>:
     47b:	push   rbp
     47c:	mov    rbp,rsp
     47f:	mov    rsi,QWORD PTR [rdx]
     482:	call   487 <botlish_entry_7+0xc>
			483: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
     487:	mov    rsp,rbp
     48a:	pop    rbp
     48b:	ret

000000000000048c <botlish_fn_8: ht_tombstones<mutarray>>:
     48c:	push   rbp
     48d:	mov    rbp,rsp
     490:	mov    edx,0x9
     495:	call   49a <botlish_fn_8+0xe>
			496: R_X86_64_PLT32	rt_mutarray_get-0x4
     49a:	test   rax,rax
     49d:	jne    4ab <botlish_fn_8+0x1f>
     4a3:	xor    rax,rax
     4a6:	mov    rsp,rbp
     4a9:	pop    rbp
     4aa:	ret
     4ab:	mov    rsp,rbp
     4ae:	pop    rbp
     4af:	ret

00000000000004b0 <botlish_entry_8: ht_tombstones<mutarray>>:
     4b0:	push   rbp
     4b1:	mov    rbp,rsp
     4b4:	mov    rsi,QWORD PTR [rdx]
     4b7:	call   4bc <botlish_entry_8+0xc>
			4b8: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
     4bc:	mov    rsp,rbp
     4bf:	pop    rbp
     4c0:	ret

00000000000004c1 <botlish_fn_9: ht_capacity<mutarray>>:
     4c1:	push   rbp
     4c2:	mov    rbp,rsp
     4c5:	sub    rsp,0x10
     4c9:	mov    QWORD PTR [rsp],rbx
     4cd:	mov    rbx,rdi
     4d0:	mov    rdi,rbx
     4d3:	call   4d8 <botlish_fn_9+0x17>
			4d4: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     4d8:	test   rax,rax
     4db:	je     524 <botlish_fn_9+0x63>
     4e1:	xor    r8d,r8d
     4e4:	test   rax,0x7
     4ea:	je     4f8 <botlish_fn_9+0x37>
     4f0:	mov    rsi,rax
     4f3:	jmp    507 <botlish_fn_9+0x46>
     4f8:	movzx  rcx,BYTE PTR [rax]
     4fc:	mov    rsi,rax
     4ff:	rex cmp cl,0x8
     503:	sete   r8b
     507:	test   r8b,r8b
     50a:	jne    537 <botlish_fn_9+0x76>
     510:	mov    rdi,rbx
     513:	mov    rax,QWORD PTR [rdi+0x10]
     517:	mov    rcx,QWORD PTR [rax]
     51a:	mov    edx,0x8
     51f:	call   524 <botlish_fn_9+0x63>
			520: R_X86_64_PLT32	rt_type_error-0x4
     524:	xor    rdx,rdx
     527:	mov    rax,rdx
     52a:	mov    rbx,QWORD PTR [rsp]
     52e:	add    rsp,0x10
     532:	mov    rsp,rbp
     535:	pop    rbp
     536:	ret
     537:	mov    rdi,rbx
     53a:	call   53f <botlish_fn_9+0x7e>
			53b: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     53f:	mov    edx,0x1
     544:	sar    rax,1
     547:	mov    rbx,QWORD PTR [rsp]
     54b:	add    rsp,0x10
     54f:	mov    rsp,rbp
     552:	pop    rbp
     553:	ret

0000000000000554 <botlish_entry_9: ht_capacity<mutarray>>:
     554:	push   rbp
     555:	mov    rbp,rsp
     558:	mov    rsi,QWORD PTR [rdx]
     55b:	call   560 <botlish_entry_9+0xc>
			55c: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     560:	shl    rax,1
     563:	or     rax,0x1
     567:	mov    rcx,rax
     56a:	xor    rax,rax
     56d:	test   rdx,rdx
     570:	cmovne rax,rcx
     574:	mov    rsp,rbp
     577:	pop    rbp
     578:	ret

0000000000000579 <botlish_fn_10: ht_probe_start<mutarray, str>>:
     579:	push   rbp
     57a:	mov    rbp,rsp
     57d:	sub    rsp,0x20
     581:	mov    QWORD PTR [rsp],rbx
     585:	mov    QWORD PTR [rsp+0x8],r12
     58a:	mov    QWORD PTR [rsp+0x10],r15
     58f:	mov    rbx,rsi
     592:	mov    r12,rdi
     595:	mov    rsi,rdx
     598:	mov    rdi,r12
     59b:	call   5a0 <botlish_fn_10+0x27>
			59c: R_X86_64_PLT32	rt_hash-0x4
     5a0:	test   rax,rax
     5a3:	mov    r15,rax
     5a6:	je     5de <botlish_fn_10+0x65>
     5ac:	mov    rsi,rbx
     5af:	mov    rdi,r12
     5b2:	call   5b7 <botlish_fn_10+0x3e>
			5b3: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     5b7:	test   rdx,rdx
     5ba:	je     5de <botlish_fn_10+0x65>
     5c0:	shl    rax,1
     5c3:	mov    rdx,rax
     5c6:	or     rdx,0x1
     5ca:	mov    rsi,r15
     5cd:	mov    rdi,r12
     5d0:	call   5d5 <botlish_fn_10+0x5c>
			5d1: R_X86_64_PLT32	rt_int_mod-0x4
     5d5:	test   rax,rax
     5d8:	jne    5f8 <botlish_fn_10+0x7f>
     5de:	xor    rax,rax
     5e1:	mov    rbx,QWORD PTR [rsp]
     5e5:	mov    r12,QWORD PTR [rsp+0x8]
     5ea:	mov    r15,QWORD PTR [rsp+0x10]
     5ef:	add    rsp,0x20
     5f3:	mov    rsp,rbp
     5f6:	pop    rbp
     5f7:	ret
     5f8:	mov    rbx,QWORD PTR [rsp]
     5fc:	mov    r12,QWORD PTR [rsp+0x8]
     601:	mov    r15,QWORD PTR [rsp+0x10]
     606:	add    rsp,0x20
     60a:	mov    rsp,rbp
     60d:	pop    rbp
     60e:	ret

000000000000060f <botlish_entry_10: ht_probe_start<mutarray, str>>:
     60f:	push   rbp
     610:	mov    rbp,rsp
     613:	mov    rsi,QWORD PTR [rdx]
     616:	mov    rdx,QWORD PTR [rdx+0x8]
     61a:	call   61f <botlish_entry_10+0x10>
			61b: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
     61f:	mov    rsp,rbp
     622:	pop    rbp
     623:	ret

0000000000000624 <botlish_fn_11: ht_probe_next<mutarray, int>>:
     624:	push   rbp
     625:	mov    rbp,rsp
     628:	sub    rsp,0x40
     62c:	mov    QWORD PTR [rsp+0x20],rbx
     631:	mov    QWORD PTR [rsp+0x28],r12
     636:	mov    QWORD PTR [rsp+0x30],r13
     63b:	mov    rbx,rdi
     63e:	mov    QWORD PTR [rsp],rsi
     642:	mov    r12,rsi
     645:	mov    QWORD PTR [rsp+0x8],rdx
     64a:	mov    QWORD PTR [rsp+0x10],0x3
     653:	test   rdx,0x1
     65a:	jne    668 <botlish_fn_11+0x44>
     660:	mov    rsi,rdx
     663:	jmp    688 <botlish_fn_11+0x64>
     668:	mov    rsi,rdx
     66b:	add    rsi,0x2
     66f:	mov    r13,rsi
     672:	mov    rsi,rdx
     675:	seto   al
     678:	test   al,al
     67a:	jne    688 <botlish_fn_11+0x64>
     680:	mov    rsi,r12
     683:	jmp    69b <botlish_fn_11+0x77>
     688:	mov    edx,0x3
     68d:	mov    rdi,rbx
     690:	call   695 <botlish_fn_11+0x71>
			691: R_X86_64_PLT32	rt_int_add-0x4
     695:	mov    rsi,r12
     698:	mov    r13,rax
     69b:	mov    rdi,rbx
     69e:	call   6a3 <botlish_fn_11+0x7f>
			69f: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
     6a3:	test   rdx,rdx
     6a6:	je     6ca <botlish_fn_11+0xa6>
     6ac:	shl    rax,1
     6af:	mov    rdx,rax
     6b2:	or     rdx,0x1
     6b6:	mov    rsi,r13
     6b9:	mov    rdi,rbx
     6bc:	call   6c1 <botlish_fn_11+0x9d>
			6bd: R_X86_64_PLT32	rt_int_mod-0x4
     6c1:	test   rax,rax
     6c4:	jne    6e5 <botlish_fn_11+0xc1>
     6ca:	xor    rax,rax
     6cd:	mov    rbx,QWORD PTR [rsp+0x20]
     6d2:	mov    r12,QWORD PTR [rsp+0x28]
     6d7:	mov    r13,QWORD PTR [rsp+0x30]
     6dc:	add    rsp,0x40
     6e0:	mov    rsp,rbp
     6e3:	pop    rbp
     6e4:	ret
     6e5:	mov    rbx,QWORD PTR [rsp+0x20]
     6ea:	mov    r12,QWORD PTR [rsp+0x28]
     6ef:	mov    r13,QWORD PTR [rsp+0x30]
     6f4:	add    rsp,0x40
     6f8:	mov    rsp,rbp
     6fb:	pop    rbp
     6fc:	ret

00000000000006fd <botlish_entry_11: ht_probe_next<mutarray, int>>:
     6fd:	push   rbp
     6fe:	mov    rbp,rsp
     701:	mov    rsi,QWORD PTR [rdx]
     704:	mov    rdx,QWORD PTR [rdx+0x8]
     708:	call   70d <botlish_entry_11+0x10>
			709: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     70d:	mov    rsp,rbp
     710:	pop    rbp
     711:	ret
     712:	add    BYTE PTR [rax],al
     714:	add    BYTE PTR [rax],al
	...

0000000000000718 <botlish_fn_12: ht_find_get<mutarray, str, int>>:
     718:	push   rbp
     719:	mov    rbp,rsp
     71c:	sub    rsp,0x50
     720:	mov    QWORD PTR [rsp+0x20],rbx
     725:	mov    QWORD PTR [rsp+0x28],r12
     72a:	mov    QWORD PTR [rsp+0x30],r13
     72f:	mov    QWORD PTR [rsp+0x38],r14
     734:	mov    QWORD PTR [rsp+0x40],r15
     739:	mov    r14,rdi
     73c:	mov    QWORD PTR [rsp],rsi
     740:	mov    QWORD PTR [rsp+0x8],rdx
     745:	mov    r13,rdx
     748:	mov    QWORD PTR [rsp+0x10],rcx
     74d:	mov    r12,rsi
     750:	mov    r15,rcx
     753:	mov    rsi,r12
     756:	mov    rdi,r14
     759:	call   75e <botlish_fn_12+0x46>
			75a: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     75e:	test   rax,rax
     761:	je     960 <botlish_fn_12+0x248>
     767:	xor    ecx,ecx
     769:	test   rax,0x7
     76f:	je     77d <botlish_fn_12+0x65>
     775:	mov    rsi,rax
     778:	jmp    78b <botlish_fn_12+0x73>
     77d:	movzx  rcx,BYTE PTR [rax]
     781:	mov    rsi,rax
     784:	rex cmp cl,0x8
     788:	sete   cl
     78b:	test   cl,cl
     78d:	jne    7ad <botlish_fn_12+0x95>
     793:	mov    rdi,r14
     796:	mov    rdx,QWORD PTR [rdi+0x10]
     79a:	mov    rcx,QWORD PTR [rdx+0x8]
     79e:	mov    edx,0x8
     7a3:	call   7a8 <botlish_fn_12+0x90>
			7a4: R_X86_64_PLT32	rt_type_error-0x4
     7a8:	jmp    960 <botlish_fn_12+0x248>
     7ad:	mov    rdx,r15
     7b0:	mov    rdi,r14
     7b3:	call   7b8 <botlish_fn_12+0xa0>
			7b4: R_X86_64_PLT32	rt_mutarray_get-0x4
     7b8:	mov    rcx,rax
     7bb:	mov    QWORD PTR [rsp+0x18],rax
     7c0:	test   rax,rcx
     7c3:	je     960 <botlish_fn_12+0x248>
     7c9:	mov    rax,QWORD PTR [rsp+0x18]
     7ce:	test   rax,0x1
     7d4:	jne    7ff <botlish_fn_12+0xe7>
     7da:	mov    edx,0x1
     7df:	mov    rsi,QWORD PTR [rsp+0x18]
     7e4:	mov    rdi,r14
     7e7:	call   7ec <botlish_fn_12+0xd4>
			7e8: R_X86_64_PLT32	rt_value_eq-0x4
     7ec:	test   rax,rax
     7ef:	je     960 <botlish_fn_12+0x248>
     7f5:	mov    rcx,QWORD PTR [rsp+0x18]
     7fa:	jmp    815 <botlish_fn_12+0xfd>
     7ff:	mov    eax,0x2
     804:	mov    rcx,QWORD PTR [rsp+0x18]
     809:	cmp    rcx,0x1
     80d:	cmove  rax,QWORD PTR [rip+0x1db]        # 9f0 <botlish_fn_12+0x2d8>
     815:	mov    ebx,0x6
     81a:	cmp    rax,0x6
     81e:	je     9c0 <botlish_fn_12+0x2a8>
     824:	test   rcx,0x1
     82b:	mov    QWORD PTR [rsp+0x18],rcx
     830:	jne    856 <botlish_fn_12+0x13e>
     836:	mov    edx,0x3
     83b:	mov    rsi,QWORD PTR [rsp+0x18]
     840:	mov    rdi,r14
     843:	call   848 <botlish_fn_12+0x130>
			844: R_X86_64_PLT32	rt_value_eq-0x4
     848:	test   rax,rax
     84b:	je     960 <botlish_fn_12+0x248>
     851:	jmp    86c <botlish_fn_12+0x154>
     856:	mov    rsi,QWORD PTR [rsp+0x18]
     85b:	mov    eax,0x2
     860:	cmp    rsi,0x3
     864:	cmove  rax,QWORD PTR [rip+0x184]        # 9f0 <botlish_fn_12+0x2d8>
     86c:	cmp    rax,0x6
     870:	je     880 <botlish_fn_12+0x168>
     876:	mov    ebx,0x2
     87b:	jmp    93f <botlish_fn_12+0x227>
     880:	mov    rsi,r12
     883:	mov    rdi,r14
     886:	call   88b <botlish_fn_12+0x173>
			887: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     88b:	test   rax,rax
     88e:	je     960 <botlish_fn_12+0x248>
     894:	xor    r10d,r10d
     897:	test   rax,0x7
     89d:	je     8ab <botlish_fn_12+0x193>
     8a3:	mov    rsi,rax
     8a6:	jmp    8ba <botlish_fn_12+0x1a2>
     8ab:	movzx  rcx,BYTE PTR [rax]
     8af:	mov    rsi,rax
     8b2:	rex cmp cl,0x8
     8b6:	sete   r10b
     8ba:	test   r10b,r10b
     8bd:	jne    8dd <botlish_fn_12+0x1c5>
     8c3:	mov    rdi,r14
     8c6:	mov    rax,QWORD PTR [rdi+0x10]
     8ca:	mov    rcx,QWORD PTR [rax+0x8]
     8ce:	mov    edx,0x8
     8d3:	call   8d8 <botlish_fn_12+0x1c0>
			8d4: R_X86_64_PLT32	rt_type_error-0x4
     8d8:	jmp    960 <botlish_fn_12+0x248>
     8dd:	mov    rdx,r15
     8e0:	mov    rdi,r14
     8e3:	call   8e8 <botlish_fn_12+0x1d0>
			8e4: R_X86_64_PLT32	rt_mutarray_get-0x4
     8e8:	test   rax,rax
     8eb:	je     960 <botlish_fn_12+0x248>
     8f1:	mov    rcx,rax
     8f4:	and    rcx,r13
     8f7:	mov    rsi,rax
     8fa:	test   rcx,0x1
     901:	jne    920 <botlish_fn_12+0x208>
     907:	mov    rdx,r13
     90a:	mov    rdi,r14
     90d:	call   912 <botlish_fn_12+0x1fa>
			90e: R_X86_64_PLT32	rt_value_eq-0x4
     912:	test   rax,rax
     915:	je     960 <botlish_fn_12+0x248>
     91b:	jmp    930 <botlish_fn_12+0x218>
     920:	mov    eax,0x2
     925:	cmp    rsi,r13
     928:	cmove  rax,QWORD PTR [rip+0xc0]        # 9f0 <botlish_fn_12+0x2d8>
     930:	cmp    rax,0x6
     934:	je     93f <botlish_fn_12+0x227>
     93a:	mov    ebx,0x2
     93f:	cmp    rbx,0x6
     943:	je     99b <botlish_fn_12+0x283>
     949:	mov    rdx,r15
     94c:	mov    rsi,r12
     94f:	mov    rdi,r14
     952:	call   957 <botlish_fn_12+0x23f>
			953: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     957:	test   rax,rax
     95a:	jne    985 <botlish_fn_12+0x26d>
     960:	xor    rax,rax
     963:	mov    rbx,QWORD PTR [rsp+0x20]
     968:	mov    r12,QWORD PTR [rsp+0x28]
     96d:	mov    r13,QWORD PTR [rsp+0x30]
     972:	mov    r14,QWORD PTR [rsp+0x38]
     977:	mov    r15,QWORD PTR [rsp+0x40]
     97c:	add    rsp,0x50
     980:	mov    rsp,rbp
     983:	pop    rbp
     984:	ret
     985:	mov    QWORD PTR [rsp],r12
     989:	mov    QWORD PTR [rsp+0x8],r13
     98e:	mov    QWORD PTR [rsp+0x10],rax
     993:	mov    r15,rax
     996:	jmp    753 <botlish_fn_12+0x3b>
     99b:	mov    rax,r15
     99e:	mov    rbx,QWORD PTR [rsp+0x20]
     9a3:	mov    r12,QWORD PTR [rsp+0x28]
     9a8:	mov    r13,QWORD PTR [rsp+0x30]
     9ad:	mov    r14,QWORD PTR [rsp+0x38]
     9b2:	mov    r15,QWORD PTR [rsp+0x40]
     9b7:	add    rsp,0x50
     9bb:	mov    rsp,rbp
     9be:	pop    rbp
     9bf:	ret
     9c0:	mov    rax,0xffffffffffffffff
     9c7:	mov    rbx,QWORD PTR [rsp+0x20]
     9cc:	mov    r12,QWORD PTR [rsp+0x28]
     9d1:	mov    r13,QWORD PTR [rsp+0x30]
     9d6:	mov    r14,QWORD PTR [rsp+0x38]
     9db:	mov    r15,QWORD PTR [rsp+0x40]
     9e0:	add    rsp,0x50
     9e4:	mov    rsp,rbp
     9e7:	pop    rbp
     9e8:	ret
     9e9:	add    BYTE PTR [rax],al
     9eb:	add    BYTE PTR [rax],al
     9ed:	add    BYTE PTR [rax],al
     9ef:	add    BYTE PTR [rsi],al
     9f1:	add    BYTE PTR [rax],al
     9f3:	add    BYTE PTR [rax],al
     9f5:	add    BYTE PTR [rax],al
	...

00000000000009f8 <botlish_entry_12: ht_find_get<mutarray, str, int>>:
     9f8:	push   rbp
     9f9:	mov    rbp,rsp
     9fc:	mov    rsi,QWORD PTR [rdx]
     9ff:	mov    r8,QWORD PTR [rdx+0x8]
     a03:	mov    rcx,QWORD PTR [rdx+0x10]
     a07:	mov    rdx,r8
     a0a:	call   a0f <botlish_entry_12+0x17>
			a0b: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
     a0f:	mov    rsp,rbp
     a12:	pop    rbp
     a13:	ret
     a14:	add    BYTE PTR [rax],al
	...

0000000000000a18 <botlish_fn_13: ht_find_insert<mutarray, str, int, int>>:
     a18:	push   rbp
     a19:	mov    rbp,rsp
     a1c:	sub    rsp,0x60
     a20:	mov    QWORD PTR [rsp+0x30],rbx
     a25:	mov    QWORD PTR [rsp+0x38],r12
     a2a:	mov    QWORD PTR [rsp+0x40],r13
     a2f:	mov    QWORD PTR [rsp+0x48],r14
     a34:	mov    QWORD PTR [rsp+0x50],r15
     a39:	mov    r15,rdi
     a3c:	mov    QWORD PTR [rsp],rsi
     a40:	mov    QWORD PTR [rsp+0x8],rdx
     a45:	mov    r13,rdx
     a48:	mov    QWORD PTR [rsp+0x10],rcx
     a4d:	mov    QWORD PTR [rsp+0x18],r8
     a52:	mov    rbx,rsi
     a55:	mov    QWORD PTR [rsp+0x20],rcx
     a5a:	mov    QWORD PTR [rsp+0x28],r8
     a5f:	mov    rsi,rbx
     a62:	mov    rdi,r15
     a65:	call   a6a <botlish_fn_13+0x52>
			a66: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
     a6a:	test   rax,rax
     a6d:	je     d65 <botlish_fn_13+0x34d>
     a73:	xor    ecx,ecx
     a75:	test   rax,0x7
     a7b:	je     a89 <botlish_fn_13+0x71>
     a81:	mov    rsi,rax
     a84:	jmp    a97 <botlish_fn_13+0x7f>
     a89:	movzx  rcx,BYTE PTR [rax]
     a8d:	mov    rsi,rax
     a90:	rex cmp cl,0x8
     a94:	sete   cl
     a97:	test   cl,cl
     a99:	jne    ab9 <botlish_fn_13+0xa1>
     a9f:	mov    rdi,r15
     aa2:	mov    rax,QWORD PTR [rdi+0x10]
     aa6:	mov    rcx,QWORD PTR [rax+0x8]
     aaa:	mov    edx,0x8
     aaf:	call   ab4 <botlish_fn_13+0x9c>
			ab0: R_X86_64_PLT32	rt_type_error-0x4
     ab4:	jmp    d65 <botlish_fn_13+0x34d>
     ab9:	mov    rdx,QWORD PTR [rsp+0x20]
     abe:	mov    rdi,r15
     ac1:	call   ac6 <botlish_fn_13+0xae>
			ac2: R_X86_64_PLT32	rt_mutarray_get-0x4
     ac6:	mov    rsi,rax
     ac9:	mov    r14,rax
     acc:	test   rax,rsi
     acf:	je     d65 <botlish_fn_13+0x34d>
     ad5:	mov    rax,r14
     ad8:	test   rax,0x1
     ade:	jne    b02 <botlish_fn_13+0xea>
     ae4:	mov    edx,0x1
     ae9:	mov    rsi,r14
     aec:	mov    rdi,r15
     aef:	call   af4 <botlish_fn_13+0xdc>
			af0: R_X86_64_PLT32	rt_value_eq-0x4
     af4:	test   rax,rax
     af7:	je     d65 <botlish_fn_13+0x34d>
     afd:	jmp    b16 <botlish_fn_13+0xfe>
     b02:	mov    eax,0x2
     b07:	mov    rcx,r14
     b0a:	cmp    rcx,0x1
     b0e:	cmove  rax,QWORD PTR [rip+0x372]        # e88 <botlish_fn_13+0x470>
     b16:	mov    r12d,0x6
     b1c:	cmp    rax,0x6
     b20:	je     ddd <botlish_fn_13+0x3c5>
     b26:	mov    rax,r14
     b29:	test   rax,0x1
     b2f:	jne    b53 <botlish_fn_13+0x13b>
     b35:	mov    edx,0x3
     b3a:	mov    rsi,r14
     b3d:	mov    rdi,r15
     b40:	call   b45 <botlish_fn_13+0x12d>
			b41: R_X86_64_PLT32	rt_value_eq-0x4
     b45:	test   rax,rax
     b48:	je     d65 <botlish_fn_13+0x34d>
     b4e:	jmp    b67 <botlish_fn_13+0x14f>
     b53:	mov    eax,0x2
     b58:	mov    rcx,r14
     b5b:	cmp    rcx,0x3
     b5f:	cmove  rax,QWORD PTR [rip+0x321]        # e88 <botlish_fn_13+0x470>
     b67:	cmp    rax,0x6
     b6b:	je     b7c <botlish_fn_13+0x164>
     b71:	mov    r11d,0x2
     b77:	jmp    c46 <botlish_fn_13+0x22e>
     b7c:	mov    rsi,rbx
     b7f:	mov    rdi,r15
     b82:	call   b87 <botlish_fn_13+0x16f>
			b83: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
     b87:	test   rax,rax
     b8a:	je     d65 <botlish_fn_13+0x34d>
     b90:	xor    ecx,ecx
     b92:	test   rax,0x7
     b98:	je     ba6 <botlish_fn_13+0x18e>
     b9e:	mov    rsi,rax
     ba1:	jmp    bb4 <botlish_fn_13+0x19c>
     ba6:	movzx  rcx,BYTE PTR [rax]
     baa:	mov    rsi,rax
     bad:	rex cmp cl,0x8
     bb1:	sete   cl
     bb4:	test   cl,cl
     bb6:	jne    bd6 <botlish_fn_13+0x1be>
     bbc:	mov    rdi,r15
     bbf:	mov    rcx,QWORD PTR [rdi+0x10]
     bc3:	mov    rcx,QWORD PTR [rcx+0x8]
     bc7:	mov    edx,0x8
     bcc:	call   bd1 <botlish_fn_13+0x1b9>
			bcd: R_X86_64_PLT32	rt_type_error-0x4
     bd1:	jmp    d65 <botlish_fn_13+0x34d>
     bd6:	mov    rdx,QWORD PTR [rsp+0x20]
     bdb:	mov    rdi,r15
     bde:	call   be3 <botlish_fn_13+0x1cb>
			bdf: R_X86_64_PLT32	rt_mutarray_get-0x4
     be3:	test   rax,rax
     be6:	je     d65 <botlish_fn_13+0x34d>
     bec:	mov    rsi,rax
     bef:	and    rsi,r13
     bf2:	test   rsi,0x1
     bf9:	jne    c1b <botlish_fn_13+0x203>
     bff:	mov    rsi,rax
     c02:	mov    rdx,r13
     c05:	mov    rdi,r15
     c08:	call   c0d <botlish_fn_13+0x1f5>
			c09: R_X86_64_PLT32	rt_value_eq-0x4
     c0d:	test   rax,rax
     c10:	je     d65 <botlish_fn_13+0x34d>
     c16:	jmp    c2e <botlish_fn_13+0x216>
     c1b:	mov    rsi,rax
     c1e:	mov    eax,0x2
     c23:	cmp    rsi,r13
     c26:	cmove  rax,QWORD PTR [rip+0x25a]        # e88 <botlish_fn_13+0x470>
     c2e:	cmp    rax,0x6
     c32:	je     c43 <botlish_fn_13+0x22b>
     c38:	mov    r11d,0x2
     c3e:	jmp    c46 <botlish_fn_13+0x22e>
     c43:	mov    r11,r12
     c46:	cmp    r11,0x6
     c4a:	je     db6 <botlish_fn_13+0x39e>
     c50:	mov    rax,r14
     c53:	test   rax,0x1
     c59:	jne    c7d <botlish_fn_13+0x265>
     c5f:	mov    edx,0x5
     c64:	mov    rsi,r14
     c67:	mov    rdi,r15
     c6a:	call   c6f <botlish_fn_13+0x257>
			c6b: R_X86_64_PLT32	rt_value_eq-0x4
     c6f:	test   rax,rax
     c72:	je     d65 <botlish_fn_13+0x34d>
     c78:	jmp    c91 <botlish_fn_13+0x279>
     c7d:	mov    rsi,r14
     c80:	mov    eax,0x2
     c85:	cmp    rsi,0x5
     c89:	cmove  rax,QWORD PTR [rip+0x1f7]        # e88 <botlish_fn_13+0x470>
     c91:	cmp    rax,0x6
     c95:	je     ca6 <botlish_fn_13+0x28e>
     c9b:	mov    r12d,0x2
     ca1:	jmp    d07 <botlish_fn_13+0x2ef>
     ca6:	mov    r14,QWORD PTR [rsp+0x28]
     cab:	test   r14,0x1
     cb2:	jne    ce2 <botlish_fn_13+0x2ca>
     cb8:	mov    edx,0x1
     cbd:	mov    rsi,r14
     cc0:	mov    rdi,r15
     cc3:	call   cc8 <botlish_fn_13+0x2b0>
			cc4: R_X86_64_PLT32	rt_int_cmp-0x4
     cc8:	mov    ecx,0x2
     ccd:	test   rax,rax
     cd0:	cmovl  rcx,QWORD PTR [rip+0x1b0]        # e88 <botlish_fn_13+0x470>
     cd8:	mov    QWORD PTR [rsp+0x28],r14
     cdd:	jmp    cf7 <botlish_fn_13+0x2df>
     ce2:	mov    ecx,0x2
     ce7:	test   r14,r14
     cea:	mov    QWORD PTR [rsp+0x28],r14
     cef:	cmovle rcx,QWORD PTR [rip+0x191]        # e88 <botlish_fn_13+0x470>
     cf7:	cmp    rcx,0x6
     cfb:	je     d07 <botlish_fn_13+0x2ef>
     d01:	mov    r12d,0x2
     d07:	cmp    r12,0x6
     d0b:	je     d4c <botlish_fn_13+0x334>
     d11:	mov    rdx,QWORD PTR [rsp+0x20]
     d16:	mov    rsi,rbx
     d19:	mov    rdi,r15
     d1c:	call   d21 <botlish_fn_13+0x309>
			d1d: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     d21:	test   rax,rax
     d24:	je     d65 <botlish_fn_13+0x34d>
     d2a:	mov    QWORD PTR [rsp],rbx
     d2e:	mov    QWORD PTR [rsp+0x8],r13
     d33:	mov    QWORD PTR [rsp+0x10],rax
     d38:	mov    r11,QWORD PTR [rsp+0x28]
     d3d:	mov    QWORD PTR [rsp+0x18],r11
     d42:	mov    QWORD PTR [rsp+0x20],rax
     d47:	jmp    a5f <botlish_fn_13+0x47>
     d4c:	mov    rdx,QWORD PTR [rsp+0x20]
     d51:	mov    rsi,rbx
     d54:	mov    rdi,r15
     d57:	call   d5c <botlish_fn_13+0x344>
			d58: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_probe_next<mutarray, int>
     d5c:	test   rax,rax
     d5f:	jne    d8a <botlish_fn_13+0x372>
     d65:	xor    rax,rax
     d68:	mov    rbx,QWORD PTR [rsp+0x30]
     d6d:	mov    r12,QWORD PTR [rsp+0x38]
     d72:	mov    r13,QWORD PTR [rsp+0x40]
     d77:	mov    r14,QWORD PTR [rsp+0x48]
     d7c:	mov    r15,QWORD PTR [rsp+0x50]
     d81:	add    rsp,0x60
     d85:	mov    rsp,rbp
     d88:	pop    rbp
     d89:	ret
     d8a:	mov    QWORD PTR [rsp],rbx
     d8e:	mov    QWORD PTR [rsp+0x8],r13
     d93:	mov    QWORD PTR [rsp+0x10],rax
     d98:	mov    rdx,QWORD PTR [rsp+0x20]
     d9d:	mov    QWORD PTR [rsp+0x18],rdx
     da2:	mov    rcx,QWORD PTR [rsp+0x20]
     da7:	mov    QWORD PTR [rsp+0x28],rcx
     dac:	mov    QWORD PTR [rsp+0x20],rax
     db1:	jmp    a5f <botlish_fn_13+0x47>
     db6:	mov    rax,QWORD PTR [rsp+0x20]
     dbb:	mov    rbx,QWORD PTR [rsp+0x30]
     dc0:	mov    r12,QWORD PTR [rsp+0x38]
     dc5:	mov    r13,QWORD PTR [rsp+0x40]
     dca:	mov    r14,QWORD PTR [rsp+0x48]
     dcf:	mov    r15,QWORD PTR [rsp+0x50]
     dd4:	add    rsp,0x60
     dd8:	mov    rsp,rbp
     ddb:	pop    rbp
     ddc:	ret
     ddd:	mov    rax,QWORD PTR [rsp+0x28]
     de2:	test   rax,0x1
     de8:	jne    e15 <botlish_fn_13+0x3fd>
     dee:	mov    edx,0x1
     df3:	mov    rdi,r15
     df6:	mov    rsi,QWORD PTR [rsp+0x28]
     dfb:	call   e00 <botlish_fn_13+0x3e8>
			dfc: R_X86_64_PLT32	rt_int_cmp-0x4
     e00:	mov    ecx,0x2
     e05:	test   rax,rax
     e08:	cmovge rcx,QWORD PTR [rip+0x78]        # e88 <botlish_fn_13+0x470>
     e10:	jmp    e2f <botlish_fn_13+0x417>
     e15:	mov    ecx,0x2
     e1a:	mov    rax,QWORD PTR [rsp+0x28]
     e1f:	mov    rdx,QWORD PTR [rsp+0x28]
     e24:	test   rax,rdx
     e27:	cmovg  rcx,QWORD PTR [rip+0x59]        # e88 <botlish_fn_13+0x470>
     e2f:	cmp    rcx,0x6
     e33:	je     e60 <botlish_fn_13+0x448>
     e39:	mov    rax,QWORD PTR [rsp+0x20]
     e3e:	mov    rbx,QWORD PTR [rsp+0x30]
     e43:	mov    r12,QWORD PTR [rsp+0x38]
     e48:	mov    r13,QWORD PTR [rsp+0x40]
     e4d:	mov    r14,QWORD PTR [rsp+0x48]
     e52:	mov    r15,QWORD PTR [rsp+0x50]
     e57:	add    rsp,0x60
     e5b:	mov    rsp,rbp
     e5e:	pop    rbp
     e5f:	ret
     e60:	mov    rax,QWORD PTR [rsp+0x28]
     e65:	mov    rbx,QWORD PTR [rsp+0x30]
     e6a:	mov    r12,QWORD PTR [rsp+0x38]
     e6f:	mov    r13,QWORD PTR [rsp+0x40]
     e74:	mov    r14,QWORD PTR [rsp+0x48]
     e79:	mov    r15,QWORD PTR [rsp+0x50]
     e7e:	add    rsp,0x60
     e82:	mov    rsp,rbp
     e85:	pop    rbp
     e86:	ret
     e87:	add    BYTE PTR [rsi],al
     e89:	add    BYTE PTR [rax],al
     e8b:	add    BYTE PTR [rax],al
     e8d:	add    BYTE PTR [rax],al
	...

0000000000000e90 <botlish_entry_13: ht_find_insert<mutarray, str, int, int>>:
     e90:	push   rbp
     e91:	mov    rbp,rsp
     e94:	mov    rsi,QWORD PTR [rdx]
     e97:	mov    r9,QWORD PTR [rdx+0x8]
     e9b:	mov    rcx,QWORD PTR [rdx+0x10]
     e9f:	mov    r8,QWORD PTR [rdx+0x18]
     ea3:	mov    rdx,r9
     ea6:	call   eab <botlish_entry_13+0x1b>
			ea7: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
     eab:	mov    rsp,rbp
     eae:	pop    rbp
     eaf:	ret

0000000000000eb0 <botlish_fn_14: ht_get<mutarray, str>>:
     eb0:	push   rbp
     eb1:	mov    rbp,rsp
     eb4:	sub    rsp,0x40
     eb8:	mov    QWORD PTR [rsp+0x20],rbx
     ebd:	mov    QWORD PTR [rsp+0x28],r12
     ec2:	mov    QWORD PTR [rsp+0x30],r13
     ec7:	mov    rbx,rdi
     eca:	mov    QWORD PTR [rsp],rsi
     ece:	mov    r13,rsi
     ed1:	mov    QWORD PTR [rsp+0x8],rdx
     ed6:	mov    r12,rdx
     ed9:	mov    rdx,r12
     edc:	mov    rsi,r13
     edf:	mov    rdi,rbx
     ee2:	call   ee7 <botlish_fn_14+0x37>
			ee3: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
     ee7:	test   rax,rax
     eea:	je     fd4 <botlish_fn_14+0x124>
     ef0:	mov    QWORD PTR [rsp+0x10],rax
     ef5:	mov    rcx,rax
     ef8:	mov    rdx,r12
     efb:	mov    rsi,r13
     efe:	mov    rdi,rbx
     f01:	call   f06 <botlish_fn_14+0x56>
			f02: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
     f06:	mov    rcx,rax
     f09:	mov    r12,rax
     f0c:	test   rax,rcx
     f0f:	je     fd4 <botlish_fn_14+0x124>
     f15:	mov    rax,r12
     f18:	test   rax,0x1
     f1e:	jne    f49 <botlish_fn_14+0x99>
     f24:	mov    edx,0x1
     f29:	mov    rsi,r12
     f2c:	mov    rdi,rbx
     f2f:	call   f34 <botlish_fn_14+0x84>
			f30: R_X86_64_PLT32	rt_int_cmp-0x4
     f34:	mov    ecx,0x2
     f39:	test   rax,rax
     f3c:	cmovl  rcx,QWORD PTR [rip+0xe4]        # 1028 <botlish_fn_14+0x178>
     f44:	jmp    f5c <botlish_fn_14+0xac>
     f49:	mov    ecx,0x2
     f4e:	mov    rax,r12
     f51:	test   rax,rax
     f54:	cmovle rcx,QWORD PTR [rip+0xcc]        # 1028 <botlish_fn_14+0x178>
     f5c:	cmp    rcx,0x6
     f60:	je     1007 <botlish_fn_14+0x157>
     f66:	mov    rsi,r13
     f69:	mov    rdi,rbx
     f6c:	call   f71 <botlish_fn_14+0xc1>
			f6d: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
     f71:	test   rax,rax
     f74:	je     fd4 <botlish_fn_14+0x124>
     f7a:	xor    ecx,ecx
     f7c:	test   rax,0x7
     f82:	je     f90 <botlish_fn_14+0xe0>
     f88:	mov    rsi,rax
     f8b:	jmp    f9e <botlish_fn_14+0xee>
     f90:	movzx  rcx,BYTE PTR [rax]
     f94:	mov    rsi,rax
     f97:	rex cmp cl,0x8
     f9b:	sete   cl
     f9e:	test   cl,cl
     fa0:	jne    fc0 <botlish_fn_14+0x110>
     fa6:	mov    rdi,rbx
     fa9:	mov    rax,QWORD PTR [rdi+0x10]
     fad:	mov    rcx,QWORD PTR [rax+0x8]
     fb1:	mov    edx,0x8
     fb6:	call   fbb <botlish_fn_14+0x10b>
			fb7: R_X86_64_PLT32	rt_type_error-0x4
     fbb:	jmp    fd4 <botlish_fn_14+0x124>
     fc0:	mov    rdx,r12
     fc3:	mov    rdi,rbx
     fc6:	call   fcb <botlish_fn_14+0x11b>
			fc7: R_X86_64_PLT32	rt_mutarray_get-0x4
     fcb:	test   rax,rax
     fce:	jne    fef <botlish_fn_14+0x13f>
     fd4:	xor    rax,rax
     fd7:	mov    rbx,QWORD PTR [rsp+0x20]
     fdc:	mov    r12,QWORD PTR [rsp+0x28]
     fe1:	mov    r13,QWORD PTR [rsp+0x30]
     fe6:	add    rsp,0x40
     fea:	mov    rsp,rbp
     fed:	pop    rbp
     fee:	ret
     fef:	mov    rbx,QWORD PTR [rsp+0x20]
     ff4:	mov    r12,QWORD PTR [rsp+0x28]
     ff9:	mov    r13,QWORD PTR [rsp+0x30]
     ffe:	add    rsp,0x40
    1002:	mov    rsp,rbp
    1005:	pop    rbp
    1006:	ret
    1007:	mov    eax,0xa
    100c:	mov    rbx,QWORD PTR [rsp+0x20]
    1011:	mov    r12,QWORD PTR [rsp+0x28]
    1016:	mov    r13,QWORD PTR [rsp+0x30]
    101b:	add    rsp,0x40
    101f:	mov    rsp,rbp
    1022:	pop    rbp
    1023:	ret
    1024:	add    BYTE PTR [rax],al
    1026:	add    BYTE PTR [rax],al
    1028:	(bad)
    1029:	add    BYTE PTR [rax],al
    102b:	add    BYTE PTR [rax],al
    102d:	add    BYTE PTR [rax],al
	...

0000000000001030 <botlish_entry_14: ht_get<mutarray, str>>:
    1030:	push   rbp
    1031:	mov    rbp,rsp
    1034:	mov    rsi,QWORD PTR [rdx]
    1037:	mov    rdx,QWORD PTR [rdx+0x8]
    103b:	call   1040 <botlish_entry_14+0x10>
			103c: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    1040:	mov    rsp,rbp
    1043:	pop    rbp
    1044:	ret
    1045:	add    BYTE PTR [rax],al
	...

0000000000001048 <botlish_fn_15: ht_contains<mutarray, str>>:
    1048:	push   rbp
    1049:	mov    rbp,rsp
    104c:	sub    rsp,0x40
    1050:	mov    QWORD PTR [rsp+0x20],rbx
    1055:	mov    QWORD PTR [rsp+0x28],r12
    105a:	mov    QWORD PTR [rsp+0x30],r15
    105f:	mov    r15,rdi
    1062:	mov    QWORD PTR [rsp],rsi
    1066:	mov    r12,rsi
    1069:	mov    QWORD PTR [rsp+0x8],rdx
    106e:	mov    rbx,rdx
    1071:	mov    rdx,rbx
    1074:	mov    rsi,r12
    1077:	mov    rdi,r15
    107a:	call   107f <botlish_fn_15+0x37>
			107b: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    107f:	test   rax,rax
    1082:	je     10a7 <botlish_fn_15+0x5f>
    1088:	mov    QWORD PTR [rsp+0x10],rax
    108d:	mov    rcx,rax
    1090:	mov    rdx,rbx
    1093:	mov    rsi,r12
    1096:	mov    rdi,r15
    1099:	call   109e <botlish_fn_15+0x56>
			109a: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    109e:	test   rax,rax
    10a1:	jne    10c2 <botlish_fn_15+0x7a>
    10a7:	xor    rax,rax
    10aa:	mov    rbx,QWORD PTR [rsp+0x20]
    10af:	mov    r12,QWORD PTR [rsp+0x28]
    10b4:	mov    r15,QWORD PTR [rsp+0x30]
    10b9:	add    rsp,0x40
    10bd:	mov    rsp,rbp
    10c0:	pop    rbp
    10c1:	ret
    10c2:	test   rax,0x1
    10c8:	mov    rsi,rax
    10cb:	jne    10f6 <botlish_fn_15+0xae>
    10d1:	mov    edx,0x1
    10d6:	mov    rdi,r15
    10d9:	call   10de <botlish_fn_15+0x96>
			10da: R_X86_64_PLT32	rt_int_cmp-0x4
    10de:	mov    ecx,0x2
    10e3:	test   rax,rax
    10e6:	mov    rax,rcx
    10e9:	cmovge rax,QWORD PTR [rip+0x2f]        # 1120 <botlish_fn_15+0xd8>
    10f1:	jmp    1106 <botlish_fn_15+0xbe>
    10f6:	mov    eax,0x2
    10fb:	test   rsi,rsi
    10fe:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1120 <botlish_fn_15+0xd8>
    1106:	mov    rbx,QWORD PTR [rsp+0x20]
    110b:	mov    r12,QWORD PTR [rsp+0x28]
    1110:	mov    r15,QWORD PTR [rsp+0x30]
    1115:	add    rsp,0x40
    1119:	mov    rsp,rbp
    111c:	pop    rbp
    111d:	ret
    111e:	add    BYTE PTR [rax],al
    1120:	(bad)
    1121:	add    BYTE PTR [rax],al
    1123:	add    BYTE PTR [rax],al
    1125:	add    BYTE PTR [rax],al
	...

0000000000001128 <botlish_entry_15: ht_contains<mutarray, str>>:
    1128:	push   rbp
    1129:	mov    rbp,rsp
    112c:	mov    rsi,QWORD PTR [rdx]
    112f:	mov    rdx,QWORD PTR [rdx+0x8]
    1133:	call   1138 <botlish_entry_15+0x10>
			1134: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    1138:	mov    rsp,rbp
    113b:	pop    rbp
    113c:	ret
    113d:	add    BYTE PTR [rax],al
	...

0000000000001140 <botlish_fn_16: ht_rehash_probe<mutarray, int, int>>:
    1140:	push   rbp
    1141:	mov    rbp,rsp
    1144:	sub    rsp,0x40
    1148:	mov    QWORD PTR [rsp+0x20],rbx
    114d:	mov    QWORD PTR [rsp+0x28],r12
    1152:	mov    QWORD PTR [rsp+0x30],r13
    1157:	mov    QWORD PTR [rsp+0x38],r14
    115c:	mov    r13,rdi
    115f:	mov    QWORD PTR [rsp],rsi
    1163:	mov    QWORD PTR [rsp+0x8],rdx
    1168:	mov    QWORD PTR [rsp+0x10],rcx
    116d:	mov    r12,rcx
    1170:	mov    rbx,rsi
    1173:	mov    r14,rdx
    1176:	mov    rdx,r14
    1179:	mov    rsi,rbx
    117c:	mov    rdi,r13
    117f:	call   1184 <botlish_fn_16+0x44>
			1180: R_X86_64_PLT32	rt_mutarray_get-0x4
    1184:	test   rax,rax
    1187:	je     1224 <botlish_fn_16+0xe4>
    118d:	test   rax,0x1
    1193:	mov    rsi,rax
    1196:	jne    11b7 <botlish_fn_16+0x77>
    119c:	mov    edx,0x1
    11a1:	mov    rdi,r13
    11a4:	call   11a9 <botlish_fn_16+0x69>
			11a5: R_X86_64_PLT32	rt_value_eq-0x4
    11a9:	test   rax,rax
    11ac:	je     1224 <botlish_fn_16+0xe4>
    11b2:	jmp    11c8 <botlish_fn_16+0x88>
    11b7:	mov    eax,0x2
    11bc:	cmp    rsi,0x1
    11c0:	cmove  rax,QWORD PTR [rip+0xb8]        # 1280 <botlish_fn_16+0x140>
    11c8:	cmp    rax,0x6
    11cc:	je     125a <botlish_fn_16+0x11a>
    11d2:	mov    QWORD PTR [rsp+0x18],0x3
    11db:	mov    rsi,r14
    11de:	test   rsi,0x1
    11e5:	je     11fd <botlish_fn_16+0xbd>
    11eb:	mov    rsi,r14
    11ee:	add    rsi,0x2
    11f2:	seto   al
    11f5:	test   al,al
    11f7:	je     1210 <botlish_fn_16+0xd0>
    11fd:	mov    edx,0x3
    1202:	mov    rsi,r14
    1205:	mov    rdi,r13
    1208:	call   120d <botlish_fn_16+0xcd>
			1209: R_X86_64_PLT32	rt_int_add-0x4
    120d:	mov    rsi,rax
    1210:	mov    rdx,r12
    1213:	mov    rdi,r13
    1216:	call   121b <botlish_fn_16+0xdb>
			1217: R_X86_64_PLT32	rt_int_mod-0x4
    121b:	test   rax,rax
    121e:	jne    1244 <botlish_fn_16+0x104>
    1224:	xor    rax,rax
    1227:	mov    rbx,QWORD PTR [rsp+0x20]
    122c:	mov    r12,QWORD PTR [rsp+0x28]
    1231:	mov    r13,QWORD PTR [rsp+0x30]
    1236:	mov    r14,QWORD PTR [rsp+0x38]
    123b:	add    rsp,0x40
    123f:	mov    rsp,rbp
    1242:	pop    rbp
    1243:	ret
    1244:	mov    QWORD PTR [rsp],rbx
    1248:	mov    QWORD PTR [rsp+0x8],rax
    124d:	mov    QWORD PTR [rsp+0x10],r12
    1252:	mov    r14,rax
    1255:	jmp    1176 <botlish_fn_16+0x36>
    125a:	mov    rax,r14
    125d:	mov    rbx,QWORD PTR [rsp+0x20]
    1262:	mov    r12,QWORD PTR [rsp+0x28]
    1267:	mov    r13,QWORD PTR [rsp+0x30]
    126c:	mov    r14,QWORD PTR [rsp+0x38]
    1271:	add    rsp,0x40
    1275:	mov    rsp,rbp
    1278:	pop    rbp
    1279:	ret
    127a:	add    BYTE PTR [rax],al
    127c:	add    BYTE PTR [rax],al
    127e:	add    BYTE PTR [rax],al
    1280:	(bad)
    1281:	add    BYTE PTR [rax],al
    1283:	add    BYTE PTR [rax],al
    1285:	add    BYTE PTR [rax],al
	...

0000000000001288 <botlish_entry_16: ht_rehash_probe<mutarray, int, int>>:
    1288:	push   rbp
    1289:	mov    rbp,rsp
    128c:	mov    rsi,QWORD PTR [rdx]
    128f:	mov    r8,QWORD PTR [rdx+0x8]
    1293:	mov    rcx,QWORD PTR [rdx+0x10]
    1297:	mov    rdx,r8
    129a:	call   129f <botlish_entry_16+0x17>
			129b: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash_probe<mutarray, int, int>
    129f:	mov    rsp,rbp
    12a2:	pop    rbp
    12a3:	ret

00000000000012a4 <botlish_fn_17: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    12a4:	push   rbp
    12a5:	mov    rbp,rsp
    12a8:	sub    rsp,0x80
    12af:	mov    QWORD PTR [rsp+0x50],rbx
    12b4:	mov    QWORD PTR [rsp+0x58],r12
    12b9:	mov    QWORD PTR [rsp+0x60],r13
    12be:	mov    QWORD PTR [rsp+0x68],r14
    12c3:	mov    QWORD PTR [rsp+0x70],r15
    12c8:	mov    r12,rdi
    12cb:	mov    rdi,QWORD PTR [rbp+0x10]
    12cf:	mov    QWORD PTR [rsp],rsi
    12d3:	mov    QWORD PTR [rsp+0x38],rsi
    12d8:	mov    QWORD PTR [rsp+0x8],rdx
    12dd:	mov    r15,rdx
    12e0:	mov    QWORD PTR [rsp+0x10],rcx
    12e5:	mov    rbx,rcx
    12e8:	mov    QWORD PTR [rsp+0x18],r8
    12ed:	mov    QWORD PTR [rsp+0x40],r8
    12f2:	mov    QWORD PTR [rsp+0x20],r9
    12f7:	mov    r14,r9
    12fa:	mov    QWORD PTR [rsp+0x28],rdi
    12ff:	mov    r13,rdi
    1302:	mov    rsi,r14
    1305:	mov    rdi,r12
    1308:	call   130d <botlish_fn_17+0x69>
			1309: R_X86_64_PLT32	rt_hash-0x4
    130d:	test   rax,rax
    1310:	mov    rsi,rax
    1313:	je     13b2 <botlish_fn_17+0x10e>
    1319:	mov    rdx,QWORD PTR [rsp+0x40]
    131e:	mov    rdi,r12
    1321:	call   1326 <botlish_fn_17+0x82>
			1322: R_X86_64_PLT32	rt_int_mod-0x4
    1326:	test   rax,rax
    1329:	je     13b2 <botlish_fn_17+0x10e>
    132f:	mov    QWORD PTR [rsp+0x30],rax
    1334:	mov    rcx,QWORD PTR [rsp+0x40]
    1339:	mov    rdx,rax
    133c:	mov    rsi,QWORD PTR [rsp+0x38]
    1341:	mov    rdi,r12
    1344:	call   1349 <botlish_fn_17+0xa5>
			1345: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash_probe<mutarray, int, int>
    1349:	mov    rcx,rax
    134c:	mov    QWORD PTR [rsp+0x40],rax
    1351:	test   rax,rcx
    1354:	je     13b2 <botlish_fn_17+0x10e>
    135a:	mov    ecx,0x3
    135f:	mov    rsi,QWORD PTR [rsp+0x38]
    1364:	mov    rdx,QWORD PTR [rsp+0x40]
    1369:	mov    rdi,r12
    136c:	call   1371 <botlish_fn_17+0xcd>
			136d: R_X86_64_PLT32	rt_mutarray_set-0x4
    1371:	test   rax,rax
    1374:	je     13b2 <botlish_fn_17+0x10e>
    137a:	mov    rcx,r14
    137d:	mov    rsi,r15
    1380:	mov    rdx,QWORD PTR [rsp+0x40]
    1385:	mov    rdi,r12
    1388:	call   138d <botlish_fn_17+0xe9>
			1389: R_X86_64_PLT32	rt_mutarray_set-0x4
    138d:	test   rax,rax
    1390:	je     13b2 <botlish_fn_17+0x10e>
    1396:	mov    rcx,r13
    1399:	mov    rdx,QWORD PTR [rsp+0x40]
    139e:	mov    rsi,rbx
    13a1:	mov    rdi,r12
    13a4:	call   13a9 <botlish_fn_17+0x105>
			13a5: R_X86_64_PLT32	rt_mutarray_set-0x4
    13a9:	test   rax,rax
    13ac:	jne    13da <botlish_fn_17+0x136>
    13b2:	xor    rax,rax
    13b5:	mov    rbx,QWORD PTR [rsp+0x50]
    13ba:	mov    r12,QWORD PTR [rsp+0x58]
    13bf:	mov    r13,QWORD PTR [rsp+0x60]
    13c4:	mov    r14,QWORD PTR [rsp+0x68]
    13c9:	mov    r15,QWORD PTR [rsp+0x70]
    13ce:	add    rsp,0x80
    13d5:	mov    rsp,rbp
    13d8:	pop    rbp
    13d9:	ret
    13da:	mov    eax,0xa
    13df:	mov    rbx,QWORD PTR [rsp+0x50]
    13e4:	mov    r12,QWORD PTR [rsp+0x58]
    13e9:	mov    r13,QWORD PTR [rsp+0x60]
    13ee:	mov    r14,QWORD PTR [rsp+0x68]
    13f3:	mov    r15,QWORD PTR [rsp+0x70]
    13f8:	add    rsp,0x80
    13ff:	mov    rsp,rbp
    1402:	pop    rbp
    1403:	ret

0000000000001404 <botlish_entry_17: ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>>:
    1404:	push   rbp
    1405:	mov    rbp,rsp
    1408:	sub    rsp,0x10
    140c:	mov    rsi,QWORD PTR [rdx]
    140f:	mov    r10,QWORD PTR [rdx+0x8]
    1413:	mov    rcx,QWORD PTR [rdx+0x10]
    1417:	mov    r8,QWORD PTR [rdx+0x18]
    141b:	mov    r9,QWORD PTR [rdx+0x20]
    141f:	mov    r11,QWORD PTR [rdx+0x28]
    1423:	mov    QWORD PTR [rsp],r11
    1427:	mov    rdx,r10
    142a:	call   142f <botlish_entry_17+0x2b>
			142b: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    142f:	add    rsp,0x10
    1433:	mov    rsp,rbp
    1436:	pop    rbp
    1437:	ret

0000000000001438 <botlish_fn_18: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    1438:	push   rbp
    1439:	mov    rbp,rsp
    143c:	sub    rsp,0xc0
    1443:	mov    QWORD PTR [rsp+0x90],rbx
    144b:	mov    QWORD PTR [rsp+0x98],r12
    1453:	mov    QWORD PTR [rsp+0xa0],r13
    145b:	mov    QWORD PTR [rsp+0xa8],r14
    1463:	mov    QWORD PTR [rsp+0xb0],r15
    146b:	mov    QWORD PTR [rsp+0x58],rdi
    1470:	mov    r15,QWORD PTR [rbp+0x10]
    1474:	mov    r12,QWORD PTR [rbp+0x18]
    1478:	mov    r13,QWORD PTR [rbp+0x20]
    147c:	mov    r14,QWORD PTR [rbp+0x28]
    1480:	mov    QWORD PTR [rsp+0x10],rsi
    1485:	mov    QWORD PTR [rsp+0x60],rsi
    148a:	mov    QWORD PTR [rsp+0x18],rdx
    148f:	mov    QWORD PTR [rsp+0x68],rdx
    1494:	mov    QWORD PTR [rsp+0x20],rcx
    1499:	mov    QWORD PTR [rsp+0x70],rcx
    149e:	mov    QWORD PTR [rsp+0x28],r15
    14a3:	mov    QWORD PTR [rsp+0x30],r12
    14a8:	mov    QWORD PTR [rsp+0x38],r13
    14ad:	mov    QWORD PTR [rsp+0x40],r14
    14b2:	sar    r8,1
    14b5:	sar    r9,1
    14b8:	mov    QWORD PTR [rsp+0x88],r9
    14c0:	mov    rcx,QWORD PTR [rsp+0x88]
    14c8:	mov    rbx,r8
    14cb:	cmp    rbx,rcx
    14ce:	mov    QWORD PTR [rsp+0x88],rcx
    14d6:	jge    173f <botlish_fn_18+0x307>
    14dc:	xor    eax,eax
    14de:	mov    rsi,QWORD PTR [rsp+0x60]
    14e3:	test   rsi,0x7
    14ea:	jne    14fb <botlish_fn_18+0xc3>
    14f0:	movzx  r10,BYTE PTR [rsi]
    14f4:	cmp    r10b,0x8
    14f8:	sete   al
    14fb:	test   al,al
    14fd:	jne    151f <botlish_fn_18+0xe7>
    1503:	mov    rdi,QWORD PTR [rsp+0x58]
    1508:	mov    rax,QWORD PTR [rdi+0x10]
    150c:	mov    rcx,QWORD PTR [rax+0x8]
    1510:	mov    edx,0x8
    1515:	call   151a <botlish_fn_18+0xe2>
			1516: R_X86_64_PLT32	rt_type_error-0x4
    151a:	jmp    16bd <botlish_fn_18+0x285>
    151f:	mov    QWORD PTR [rsp+0x60],rsi
    1524:	mov    rdx,rbx
    1527:	shl    rdx,1
    152a:	or     rdx,0x1
    152e:	mov    QWORD PTR [rsp+0x80],rdx
    1536:	mov    rdi,QWORD PTR [rsp+0x58]
    153b:	call   1540 <botlish_fn_18+0x108>
			153c: R_X86_64_PLT32	rt_mutarray_get-0x4
    1540:	test   rax,rax
    1543:	je     16bd <botlish_fn_18+0x285>
    1549:	test   rax,0x1
    154f:	mov    rsi,rax
    1552:	jne    1575 <botlish_fn_18+0x13d>
    1558:	mov    edx,0x3
    155d:	mov    rdi,QWORD PTR [rsp+0x58]
    1562:	call   1567 <botlish_fn_18+0x12f>
			1563: R_X86_64_PLT32	rt_value_eq-0x4
    1567:	test   rax,rax
    156a:	je     16bd <botlish_fn_18+0x285>
    1570:	jmp    1586 <botlish_fn_18+0x14e>
    1575:	mov    eax,0x2
    157a:	cmp    rsi,0x3
    157e:	cmove  rax,QWORD PTR [rip+0x1f2]        # 1778 <botlish_fn_18+0x340>
    1586:	cmp    rax,0x6
    158a:	je     159a <botlish_fn_18+0x162>
    1590:	mov    rsi,QWORD PTR [rsp+0x60]
    1595:	jmp    16f9 <botlish_fn_18+0x2c1>
    159a:	xor    esi,esi
    159c:	mov    rdx,QWORD PTR [rsp+0x68]
    15a1:	test   rdx,0x7
    15a8:	je     15b8 <botlish_fn_18+0x180>
    15ae:	mov    QWORD PTR [rsp+0x68],rdx
    15b3:	jmp    15c7 <botlish_fn_18+0x18f>
    15b8:	movzx  rax,BYTE PTR [rdx]
    15bc:	mov    QWORD PTR [rsp+0x68],rdx
    15c1:	cmp    al,0x8
    15c3:	sete   sil
    15c7:	test   sil,sil
    15ca:	jne    15f1 <botlish_fn_18+0x1b9>
    15d0:	mov    rdi,QWORD PTR [rsp+0x58]
    15d5:	mov    rax,QWORD PTR [rdi+0x10]
    15d9:	mov    rcx,QWORD PTR [rax+0x8]
    15dd:	mov    edx,0x8
    15e2:	mov    rsi,QWORD PTR [rsp+0x68]
    15e7:	call   15ec <botlish_fn_18+0x1b4>
			15e8: R_X86_64_PLT32	rt_type_error-0x4
    15ec:	jmp    16bd <botlish_fn_18+0x285>
    15f1:	mov    rdx,QWORD PTR [rsp+0x80]
    15f9:	mov    rsi,QWORD PTR [rsp+0x68]
    15fe:	mov    rdi,QWORD PTR [rsp+0x58]
    1603:	call   1608 <botlish_fn_18+0x1d0>
			1604: R_X86_64_PLT32	rt_mutarray_get-0x4
    1608:	test   rax,rax
    160b:	je     16bd <botlish_fn_18+0x285>
    1611:	mov    QWORD PTR [rsp+0x48],rax
    1616:	mov    QWORD PTR [rsp+0x78],rax
    161b:	xor    eax,eax
    161d:	mov    rcx,QWORD PTR [rsp+0x70]
    1622:	test   rcx,0x7
    1629:	je     1639 <botlish_fn_18+0x201>
    162f:	mov    QWORD PTR [rsp+0x70],rcx
    1634:	jmp    1647 <botlish_fn_18+0x20f>
    1639:	movzx  rax,BYTE PTR [rcx]
    163d:	mov    QWORD PTR [rsp+0x70],rcx
    1642:	cmp    al,0x8
    1644:	sete   al
    1647:	test   al,al
    1649:	jne    1670 <botlish_fn_18+0x238>
    164f:	mov    rdi,QWORD PTR [rsp+0x58]
    1654:	mov    rax,QWORD PTR [rdi+0x10]
    1658:	mov    rcx,QWORD PTR [rax+0x8]
    165c:	mov    edx,0x8
    1661:	mov    rsi,QWORD PTR [rsp+0x70]
    1666:	call   166b <botlish_fn_18+0x233>
			1667: R_X86_64_PLT32	rt_type_error-0x4
    166b:	jmp    16bd <botlish_fn_18+0x285>
    1670:	mov    rdx,QWORD PTR [rsp+0x80]
    1678:	mov    rsi,QWORD PTR [rsp+0x70]
    167d:	mov    rdi,QWORD PTR [rsp+0x58]
    1682:	call   1687 <botlish_fn_18+0x24f>
			1683: R_X86_64_PLT32	rt_mutarray_get-0x4
    1687:	test   rax,rax
    168a:	je     16bd <botlish_fn_18+0x285>
    1690:	mov    QWORD PTR [rsp+0x50],rax
    1695:	mov    QWORD PTR [rsp],rax
    1699:	mov    r9,QWORD PTR [rsp+0x78]
    169e:	mov    rcx,r13
    16a1:	mov    rdx,r12
    16a4:	mov    rsi,r15
    16a7:	mov    rdi,QWORD PTR [rsp+0x58]
    16ac:	mov    r8,r14
    16af:	call   16b4 <botlish_fn_18+0x27c>
			16b0: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_rehash_insert<struct{controls: mutarray, keys: mutarray, values: mutarray}, int, any, any>
    16b4:	test   rax,rax
    16b7:	jne    16f4 <botlish_fn_18+0x2bc>
    16bd:	xor    rax,rax
    16c0:	mov    rbx,QWORD PTR [rsp+0x90]
    16c8:	mov    r12,QWORD PTR [rsp+0x98]
    16d0:	mov    r13,QWORD PTR [rsp+0xa0]
    16d8:	mov    r14,QWORD PTR [rsp+0xa8]
    16e0:	mov    r15,QWORD PTR [rsp+0xb0]
    16e8:	add    rsp,0xc0
    16ef:	mov    rsp,rbp
    16f2:	pop    rbp
    16f3:	ret
    16f4:	mov    rsi,QWORD PTR [rsp+0x60]
    16f9:	mov    rsi,QWORD PTR [rsp+0x60]
    16fe:	mov    QWORD PTR [rsp+0x10],rsi
    1703:	mov    rsi,QWORD PTR [rsp+0x68]
    1708:	mov    QWORD PTR [rsp+0x18],rsi
    170d:	mov    rsi,QWORD PTR [rsp+0x70]
    1712:	mov    QWORD PTR [rsp+0x20],rsi
    1717:	mov    QWORD PTR [rsp+0x28],r15
    171c:	mov    QWORD PTR [rsp+0x30],r12
    1721:	mov    QWORD PTR [rsp+0x38],r13
    1726:	mov    QWORD PTR [rsp+0x40],r14
    172b:	add    rbx,0x1
    1732:	mov    rcx,QWORD PTR [rsp+0x88]
    173a:	jmp    14cb <botlish_fn_18+0x93>
    173f:	mov    eax,0xa
    1744:	mov    rbx,QWORD PTR [rsp+0x90]
    174c:	mov    r12,QWORD PTR [rsp+0x98]
    1754:	mov    r13,QWORD PTR [rsp+0xa0]
    175c:	mov    r14,QWORD PTR [rsp+0xa8]
    1764:	mov    r15,QWORD PTR [rsp+0xb0]
    176c:	add    rsp,0xc0
    1773:	mov    rsp,rbp
    1776:	pop    rbp
    1777:	ret
    1778:	(bad)
    1779:	add    BYTE PTR [rax],al
    177b:	add    BYTE PTR [rax],al
    177d:	add    BYTE PTR [rax],al
	...

0000000000001780 <botlish_entry_18: ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>>:
    1780:	push   rbp
    1781:	mov    rbp,rsp
    1784:	sub    rsp,0x30
    1788:	mov    QWORD PTR [rsp+0x20],r12
    178d:	mov    rsi,QWORD PTR [rdx]
    1790:	mov    rax,QWORD PTR [rdx+0x8]
    1794:	mov    rcx,QWORD PTR [rdx+0x10]
    1798:	mov    r8,QWORD PTR [rdx+0x18]
    179c:	mov    r9,QWORD PTR [rdx+0x20]
    17a0:	mov    r10,QWORD PTR [rdx+0x28]
    17a4:	mov    r11,QWORD PTR [rdx+0x30]
    17a8:	mov    r12,QWORD PTR [rdx+0x38]
    17ac:	mov    rdx,QWORD PTR [rdx+0x40]
    17b0:	mov    QWORD PTR [rsp],r10
    17b4:	mov    QWORD PTR [rsp+0x8],r11
    17b9:	mov    QWORD PTR [rsp+0x10],r12
    17be:	mov    QWORD PTR [rsp+0x18],rdx
    17c3:	mov    rdx,rax
    17c6:	call   17cb <botlish_entry_18+0x4b>
			17c7: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    17cb:	mov    r12,QWORD PTR [rsp+0x20]
    17d0:	add    rsp,0x30
    17d4:	mov    rsp,rbp
    17d7:	pop    rbp
    17d8:	ret

00000000000017d9 <botlish_fn_19: ht_rehash<mutarray, int>>:
    17d9:	push   rbp
    17da:	mov    rbp,rsp
    17dd:	sub    rsp,0xd0
    17e4:	mov    QWORD PTR [rsp+0xa0],rbx
    17ec:	mov    QWORD PTR [rsp+0xa8],r12
    17f4:	mov    QWORD PTR [rsp+0xb0],r13
    17fc:	mov    QWORD PTR [rsp+0xb8],r14
    1804:	mov    QWORD PTR [rsp+0xc0],r15
    180c:	mov    r13,rdi
    180f:	mov    QWORD PTR [rsp+0x50],0x0
    1818:	mov    QWORD PTR [rsp+0x58],0x0
    1821:	mov    QWORD PTR [rsp+0x60],0x0
    182a:	mov    QWORD PTR [rsp+0x68],0x0
    1833:	mov    QWORD PTR [rsp+0x20],rsi
    1838:	mov    rbx,rsi
    183b:	mov    QWORD PTR [rsp+0x28],rdx
    1840:	mov    r12,rdx
    1843:	mov    rsi,rbx
    1846:	mov    rdi,r13
    1849:	call   184e <botlish_fn_19+0x75>
			184a: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    184e:	test   rax,rax
    1851:	je     1a31 <botlish_fn_19+0x258>
    1857:	mov    QWORD PTR [rsp+0x30],rax
    185c:	mov    r14,rax
    185f:	mov    rsi,rbx
    1862:	mov    rdi,r13
    1865:	call   186a <botlish_fn_19+0x91>
			1866: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    186a:	test   rax,rax
    186d:	je     1a31 <botlish_fn_19+0x258>
    1873:	mov    QWORD PTR [rsp+0x38],rax
    1878:	mov    r15,rax
    187b:	mov    rsi,rbx
    187e:	mov    rdi,r13
    1881:	call   1886 <botlish_fn_19+0xad>
			1882: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    1886:	test   rax,rax
    1889:	je     1a31 <botlish_fn_19+0x258>
    188f:	mov    QWORD PTR [rsp+0x40],rax
    1894:	mov    QWORD PTR [rsp+0x90],rax
    189c:	mov    rsi,rbx
    189f:	mov    rdi,r13
    18a2:	call   18a7 <botlish_fn_19+0xce>
			18a3: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    18a7:	test   rdx,rdx
    18aa:	je     1a31 <botlish_fn_19+0x258>
    18b0:	shl    rax,1
    18b3:	mov    rcx,rax
    18b6:	or     rcx,0x1
    18ba:	mov    QWORD PTR [rsp+0x88],rax
    18c2:	mov    QWORD PTR [rsp+0x48],rcx
    18c7:	mov    rsi,r12
    18ca:	mov    rdi,r13
    18cd:	call   18d2 <botlish_fn_19+0xf9>
			18ce: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    18d2:	mov    rcx,rax
    18d5:	mov    QWORD PTR [rsp+0x80],rax
    18dd:	test   rax,rcx
    18e0:	je     1a31 <botlish_fn_19+0x258>
    18e6:	mov    rax,QWORD PTR [rsp+0x80]
    18ee:	mov    QWORD PTR [rsp+0x50],rax
    18f3:	mov    edx,0x1
    18f8:	mov    QWORD PTR [rsp+0x58],0x1
    1901:	mov    rcx,r12
    1904:	mov    rsi,QWORD PTR [rsp+0x80]
    190c:	mov    rdi,r13
    190f:	call   1914 <botlish_fn_19+0x13b>
			1910: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_fill_empty<mutarray, int, int>
    1914:	test   rax,rax
    1917:	je     1a31 <botlish_fn_19+0x258>
    191d:	mov    rsi,r12
    1920:	mov    rdi,r13
    1923:	call   1928 <botlish_fn_19+0x14f>
			1924: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1928:	test   rax,rax
    192b:	je     1a31 <botlish_fn_19+0x258>
    1931:	mov    QWORD PTR [rsp+0x58],rax
    1936:	mov    QWORD PTR [rsp+0x78],rax
    193b:	mov    rsi,r12
    193e:	mov    rdi,r13
    1941:	call   1946 <botlish_fn_19+0x16d>
			1942: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1946:	test   rax,rax
    1949:	je     1a31 <botlish_fn_19+0x258>
    194f:	mov    QWORD PTR [rsp+0x60],rax
    1954:	mov    r8d,0x1
    195a:	mov    QWORD PTR [rsp+0x68],0x1
    1963:	mov    rcx,QWORD PTR [rsp+0x88]
    196b:	mov    r9,rcx
    196e:	or     r9,0x1
    1972:	mov    rcx,QWORD PTR [rsp+0x80]
    197a:	mov    QWORD PTR [rsp],rcx
    197e:	mov    rcx,QWORD PTR [rsp+0x78]
    1983:	mov    QWORD PTR [rsp+0x8],rcx
    1988:	mov    QWORD PTR [rsp+0x10],rax
    198d:	mov    QWORD PTR [rsp+0x70],rax
    1992:	mov    QWORD PTR [rsp+0x18],r12
    1997:	mov    rcx,QWORD PTR [rsp+0x90]
    199f:	mov    rdx,r15
    19a2:	mov    rsi,r14
    19a5:	mov    rdi,r13
    19a8:	call   19ad <botlish_fn_19+0x1d4>
			19a9: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_rehash_scan<struct{controls: any, keys: any, values: any}, int, int, struct{controls: mutarray, keys: mutarray, values: mutarray}, int>
    19ad:	test   rax,rax
    19b0:	je     1a31 <botlish_fn_19+0x258>
    19b6:	mov    edx,0x1
    19bb:	mov    rcx,QWORD PTR [rsp+0x80]
    19c3:	mov    rsi,rbx
    19c6:	mov    rdi,r13
    19c9:	call   19ce <botlish_fn_19+0x1f5>
			19ca: R_X86_64_PLT32	rt_mutarray_set-0x4
    19ce:	test   rax,rax
    19d1:	je     1a31 <botlish_fn_19+0x258>
    19d7:	mov    edx,0x3
    19dc:	mov    rcx,QWORD PTR [rsp+0x78]
    19e1:	mov    rsi,rbx
    19e4:	mov    rdi,r13
    19e7:	call   19ec <botlish_fn_19+0x213>
			19e8: R_X86_64_PLT32	rt_mutarray_set-0x4
    19ec:	test   rax,rax
    19ef:	je     1a31 <botlish_fn_19+0x258>
    19f5:	mov    edx,0x5
    19fa:	mov    rcx,QWORD PTR [rsp+0x70]
    19ff:	mov    rsi,rbx
    1a02:	mov    rdi,r13
    1a05:	call   1a0a <botlish_fn_19+0x231>
			1a06: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a0a:	test   rax,rax
    1a0d:	je     1a31 <botlish_fn_19+0x258>
    1a13:	mov    edx,0x9
    1a18:	mov    ecx,0x1
    1a1d:	mov    rsi,rbx
    1a20:	mov    rdi,r13
    1a23:	call   1a28 <botlish_fn_19+0x24f>
			1a24: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a28:	test   rax,rax
    1a2b:	jne    1a68 <botlish_fn_19+0x28f>
    1a31:	xor    rax,rax
    1a34:	mov    rbx,QWORD PTR [rsp+0xa0]
    1a3c:	mov    r12,QWORD PTR [rsp+0xa8]
    1a44:	mov    r13,QWORD PTR [rsp+0xb0]
    1a4c:	mov    r14,QWORD PTR [rsp+0xb8]
    1a54:	mov    r15,QWORD PTR [rsp+0xc0]
    1a5c:	add    rsp,0xd0
    1a63:	mov    rsp,rbp
    1a66:	pop    rbp
    1a67:	ret
    1a68:	mov    eax,0xa
    1a6d:	mov    rbx,QWORD PTR [rsp+0xa0]
    1a75:	mov    r12,QWORD PTR [rsp+0xa8]
    1a7d:	mov    r13,QWORD PTR [rsp+0xb0]
    1a85:	mov    r14,QWORD PTR [rsp+0xb8]
    1a8d:	mov    r15,QWORD PTR [rsp+0xc0]
    1a95:	add    rsp,0xd0
    1a9c:	mov    rsp,rbp
    1a9f:	pop    rbp
    1aa0:	ret

0000000000001aa1 <botlish_entry_19: ht_rehash<mutarray, int>>:
    1aa1:	push   rbp
    1aa2:	mov    rbp,rsp
    1aa5:	mov    rsi,QWORD PTR [rdx]
    1aa8:	mov    rdx,QWORD PTR [rdx+0x8]
    1aac:	call   1ab1 <botlish_entry_19+0x10>
			1aad: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1ab1:	mov    rsp,rbp
    1ab4:	pop    rbp
    1ab5:	ret
	...

0000000000001ab8 <botlish_fn_20: ht_should_grow<mutarray>>:
    1ab8:	push   rbp
    1ab9:	mov    rbp,rsp
    1abc:	sub    rsp,0x40
    1ac0:	mov    QWORD PTR [rsp+0x20],rbx
    1ac5:	mov    QWORD PTR [rsp+0x28],r12
    1aca:	mov    QWORD PTR [rsp+0x30],r13
    1acf:	mov    r12,rdi
    1ad2:	mov    QWORD PTR [rsp],rsi
    1ad6:	mov    r13,rsi
    1ad9:	mov    rsi,r13
    1adc:	mov    rdi,r12
    1adf:	call   1ae4 <botlish_fn_20+0x2c>
			1ae0: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1ae4:	mov    rcx,rax
    1ae7:	mov    rbx,rax
    1aea:	test   rax,rcx
    1aed:	je     1cdc <botlish_fn_20+0x224>
    1af3:	mov    rax,rbx
    1af6:	mov    QWORD PTR [rsp+0x8],rax
    1afb:	mov    rsi,r13
    1afe:	mov    rdi,r12
    1b01:	call   1b06 <botlish_fn_20+0x4e>
			1b02: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1b06:	mov    rcx,rax
    1b09:	test   rcx,rcx
    1b0c:	je     1cdc <botlish_fn_20+0x224>
    1b12:	mov    QWORD PTR [rsp+0x10],rcx
    1b17:	mov    edx,0x1
    1b1c:	mov    rax,rbx
    1b1f:	test   rax,0x1
    1b25:	jne    1b48 <botlish_fn_20+0x90>
    1b2b:	xor    edx,edx
    1b2d:	mov    rax,rbx
    1b30:	test   rax,0x7
    1b36:	jne    1b48 <botlish_fn_20+0x90>
    1b3c:	mov    rax,rbx
    1b3f:	movzx  rax,BYTE PTR [rax]
    1b43:	cmp    al,0x1
    1b45:	sete   dl
    1b48:	test   dl,dl
    1b4a:	jne    1b6b <botlish_fn_20+0xb3>
    1b50:	mov    rdi,r12
    1b53:	mov    rax,QWORD PTR [rdi+0x10]
    1b57:	mov    rcx,QWORD PTR [rax+0x10]
    1b5b:	xor    rdx,rdx
    1b5e:	mov    rsi,rbx
    1b61:	call   1b66 <botlish_fn_20+0xae>
			1b62: R_X86_64_PLT32	rt_type_error-0x4
    1b66:	jmp    1cdc <botlish_fn_20+0x224>
    1b6b:	mov    eax,0x1
    1b70:	test   rcx,0x1
    1b77:	je     1b85 <botlish_fn_20+0xcd>
    1b7d:	mov    r8,rcx
    1b80:	jmp    1ba8 <botlish_fn_20+0xf0>
    1b85:	xor    eax,eax
    1b87:	test   rcx,0x7
    1b8e:	je     1b9c <botlish_fn_20+0xe4>
    1b94:	mov    r8,rcx
    1b97:	jmp    1ba8 <botlish_fn_20+0xf0>
    1b9c:	movzx  rax,BYTE PTR [rcx]
    1ba0:	mov    r8,rcx
    1ba3:	cmp    al,0x1
    1ba5:	sete   al
    1ba8:	test   al,al
    1baa:	jne    1bcb <botlish_fn_20+0x113>
    1bb0:	mov    rdi,r12
    1bb3:	mov    rax,QWORD PTR [rdi+0x10]
    1bb7:	mov    rcx,QWORD PTR [rax+0x10]
    1bbb:	xor    rdx,rdx
    1bbe:	mov    rsi,r8
    1bc1:	call   1bc6 <botlish_fn_20+0x10e>
			1bc2: R_X86_64_PLT32	rt_type_error-0x4
    1bc6:	jmp    1cdc <botlish_fn_20+0x224>
    1bcb:	mov    rcx,r8
    1bce:	mov    rsi,rbx
    1bd1:	mov    rax,rsi
    1bd4:	and    rax,rcx
    1bd7:	test   rax,0x1
    1bdd:	jne    1bee <botlish_fn_20+0x136>
    1be3:	mov    rdx,r8
    1be6:	mov    rsi,rbx
    1be9:	jmp    1c0c <botlish_fn_20+0x154>
    1bee:	mov    rcx,r8
    1bf1:	lea    rax,[rcx-0x1]
    1bf5:	mov    rsi,rbx
    1bf8:	add    rsi,rax
    1bfb:	seto   al
    1bfe:	test   al,al
    1c00:	je     1c17 <botlish_fn_20+0x15f>
    1c06:	mov    rdx,r8
    1c09:	mov    rsi,rbx
    1c0c:	mov    rdi,r12
    1c0f:	call   1c14 <botlish_fn_20+0x15c>
			1c10: R_X86_64_PLT32	rt_int_add-0x4
    1c14:	mov    rsi,rax
    1c17:	mov    QWORD PTR [rsp+0x8],rsi
    1c1c:	mov    QWORD PTR [rsp+0x10],0x3
    1c25:	test   rsi,0x1
    1c2c:	je     1c4f <botlish_fn_20+0x197>
    1c32:	mov    rax,rsi
    1c35:	add    rax,0x2
    1c39:	mov    rcx,rax
    1c3c:	seto   al
    1c3f:	test   al,al
    1c41:	jne    1c4f <botlish_fn_20+0x197>
    1c47:	mov    rsi,rcx
    1c4a:	jmp    1c5f <botlish_fn_20+0x1a7>
    1c4f:	mov    edx,0x3
    1c54:	mov    rdi,r12
    1c57:	call   1c5c <botlish_fn_20+0x1a4>
			1c58: R_X86_64_PLT32	rt_int_add-0x4
    1c5c:	mov    rsi,rax
    1c5f:	mov    QWORD PTR [rsp+0x8],rsi
    1c64:	mov    edx,0x7
    1c69:	mov    rdi,rdx
    1c6c:	mov    QWORD PTR [rsp+0x10],0x7
    1c75:	test   rsi,0x1
    1c7c:	jne    1c8a <botlish_fn_20+0x1d2>
    1c82:	mov    rdx,rdi
    1c85:	jmp    1cb6 <botlish_fn_20+0x1fe>
    1c8a:	mov    rax,rsi
    1c8d:	sar    rax,1
    1c90:	imul   QWORD PTR [rip+0x111]        # 1da8 <botlish_fn_20+0x2f0>
    1c97:	seto   cl
    1c9a:	or     rax,0x1
    1c9e:	test   cl,cl
    1ca0:	je     1cae <botlish_fn_20+0x1f6>
    1ca6:	mov    rdx,rdi
    1ca9:	jmp    1cb6 <botlish_fn_20+0x1fe>
    1cae:	mov    rsi,rax
    1cb1:	jmp    1cc1 <botlish_fn_20+0x209>
    1cb6:	mov    rdi,r12
    1cb9:	call   1cbe <botlish_fn_20+0x206>
			1cba: R_X86_64_PLT32	rt_int_mul-0x4
    1cbe:	mov    rsi,rax
    1cc1:	mov    QWORD PTR [rsp],rsi
    1cc5:	mov    rbx,rsi
    1cc8:	mov    rsi,r13
    1ccb:	mov    rdi,r12
    1cce:	call   1cd3 <botlish_fn_20+0x21b>
			1ccf: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1cd3:	test   rdx,rdx
    1cd6:	jne    1cf7 <botlish_fn_20+0x23f>
    1cdc:	xor    rax,rax
    1cdf:	mov    rbx,QWORD PTR [rsp+0x20]
    1ce4:	mov    r12,QWORD PTR [rsp+0x28]
    1ce9:	mov    r13,QWORD PTR [rsp+0x30]
    1cee:	add    rsp,0x40
    1cf2:	mov    rsp,rbp
    1cf5:	pop    rbp
    1cf6:	ret
    1cf7:	shl    rax,1
    1cfa:	mov    rsi,rax
    1cfd:	or     rsi,0x1
    1d01:	mov    QWORD PTR [rsp+0x8],rsi
    1d06:	mov    QWORD PTR [rsp+0x10],0x5
    1d0f:	mov    rax,rsi
    1d12:	sar    rax,1
    1d15:	imul   QWORD PTR [rip+0x94]        # 1db0 <botlish_fn_20+0x2f8>
    1d1c:	seto   dil
    1d20:	or     rax,0x1
    1d24:	test   dil,dil
    1d27:	jne    1d38 <botlish_fn_20+0x280>
    1d2d:	mov    rdx,rax
    1d30:	mov    rsi,rbx
    1d33:	jmp    1d4b <botlish_fn_20+0x293>
    1d38:	mov    edx,0x5
    1d3d:	mov    rdi,r12
    1d40:	call   1d45 <botlish_fn_20+0x28d>
			1d41: R_X86_64_PLT32	rt_int_mul-0x4
    1d45:	mov    rdx,rax
    1d48:	mov    rsi,rbx
    1d4b:	mov    r9,rsi
    1d4e:	and    r9,rdx
    1d51:	test   r9,0x1
    1d58:	jne    1d7e <botlish_fn_20+0x2c6>
    1d5e:	mov    rdi,r12
    1d61:	call   1d66 <botlish_fn_20+0x2ae>
			1d62: R_X86_64_PLT32	rt_int_cmp-0x4
    1d66:	mov    edi,0x2
    1d6b:	test   rax,rax
    1d6e:	mov    rax,rdi
    1d71:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1da8 <botlish_fn_20+0x2f0>
    1d79:	jmp    1d8e <botlish_fn_20+0x2d6>
    1d7e:	mov    eax,0x2
    1d83:	cmp    rsi,rdx
    1d86:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1da8 <botlish_fn_20+0x2f0>
    1d8e:	mov    rbx,QWORD PTR [rsp+0x20]
    1d93:	mov    r12,QWORD PTR [rsp+0x28]
    1d98:	mov    r13,QWORD PTR [rsp+0x30]
    1d9d:	add    rsp,0x40
    1da1:	mov    rsp,rbp
    1da4:	pop    rbp
    1da5:	ret
    1da6:	add    BYTE PTR [rax],al
    1da8:	(bad)
    1da9:	add    BYTE PTR [rax],al
    1dab:	add    BYTE PTR [rax],al
    1dad:	add    BYTE PTR [rax],al
    1daf:	add    BYTE PTR [rax+rax*1],al
    1db2:	add    BYTE PTR [rax],al
    1db4:	add    BYTE PTR [rax],al
	...

0000000000001db8 <botlish_entry_20: ht_should_grow<mutarray>>:
    1db8:	push   rbp
    1db9:	mov    rbp,rsp
    1dbc:	mov    rsi,QWORD PTR [rdx]
    1dbf:	call   1dc4 <botlish_entry_20+0xc>
			1dc0: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    1dc4:	mov    rsp,rbp
    1dc7:	pop    rbp
    1dc8:	ret
    1dc9:	add    BYTE PTR [rax],al
    1dcb:	add    BYTE PTR [rax],al
    1dcd:	add    BYTE PTR [rax],al
	...

0000000000001dd0 <botlish_fn_21: ht_grow_or_clean<mutarray>>:
    1dd0:	push   rbp
    1dd1:	mov    rbp,rsp
    1dd4:	sub    rsp,0x40
    1dd8:	mov    QWORD PTR [rsp+0x20],rbx
    1ddd:	mov    QWORD PTR [rsp+0x28],r12
    1de2:	mov    QWORD PTR [rsp+0x30],r13
    1de7:	mov    rbx,rdi
    1dea:	mov    QWORD PTR [rsp+0x10],0x0
    1df3:	mov    QWORD PTR [rsp],rsi
    1df7:	mov    r12,rsi
    1dfa:	mov    rsi,r12
    1dfd:	mov    rdi,rbx
    1e00:	call   1e05 <botlish_fn_21+0x35>
			1e01: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    1e05:	test   rax,rax
    1e08:	mov    r13,rax
    1e0b:	je     1ff5 <botlish_fn_21+0x225>
    1e11:	mov    rsi,r12
    1e14:	mov    rdi,rbx
    1e17:	call   1e1c <botlish_fn_21+0x4c>
			1e18: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    1e1c:	mov    rcx,rax
    1e1f:	test   rcx,rcx
    1e22:	je     1ff5 <botlish_fn_21+0x225>
    1e28:	mov    edx,0x1
    1e2d:	mov    rax,r13
    1e30:	test   rax,0x1
    1e36:	je     1e44 <botlish_fn_21+0x74>
    1e3c:	mov    r13,rax
    1e3f:	jmp    1e68 <botlish_fn_21+0x98>
    1e44:	xor    edx,edx
    1e46:	test   rax,0x7
    1e4c:	je     1e5a <botlish_fn_21+0x8a>
    1e52:	mov    r13,rax
    1e55:	jmp    1e68 <botlish_fn_21+0x98>
    1e5a:	movzx  rsi,BYTE PTR [rax]
    1e5e:	mov    r13,rax
    1e61:	cmp    sil,0x1
    1e65:	sete   dl
    1e68:	test   dl,dl
    1e6a:	jne    1e8b <botlish_fn_21+0xbb>
    1e70:	mov    rdi,rbx
    1e73:	mov    r10,QWORD PTR [rdi+0x10]
    1e77:	mov    rcx,QWORD PTR [r10+0x18]
    1e7b:	xor    rdx,rdx
    1e7e:	mov    rsi,r13
    1e81:	call   1e86 <botlish_fn_21+0xb6>
			1e82: R_X86_64_PLT32	rt_type_error-0x4
    1e86:	jmp    1ff5 <botlish_fn_21+0x225>
    1e8b:	mov    rsi,r13
    1e8e:	mov    eax,0x1
    1e93:	test   rcx,0x1
    1e9a:	je     1ea8 <botlish_fn_21+0xd8>
    1ea0:	mov    r8,rcx
    1ea3:	jmp    1ecb <botlish_fn_21+0xfb>
    1ea8:	xor    eax,eax
    1eaa:	test   rcx,0x7
    1eb1:	je     1ebf <botlish_fn_21+0xef>
    1eb7:	mov    r8,rcx
    1eba:	jmp    1ecb <botlish_fn_21+0xfb>
    1ebf:	movzx  rax,BYTE PTR [rcx]
    1ec3:	mov    r8,rcx
    1ec6:	cmp    al,0x1
    1ec8:	sete   al
    1ecb:	test   al,al
    1ecd:	jne    1eee <botlish_fn_21+0x11e>
    1ed3:	mov    rdi,rbx
    1ed6:	mov    rax,QWORD PTR [rdi+0x10]
    1eda:	mov    rcx,QWORD PTR [rax+0x18]
    1ede:	xor    rdx,rdx
    1ee1:	mov    rsi,r8
    1ee4:	call   1ee9 <botlish_fn_21+0x119>
			1ee5: R_X86_64_PLT32	rt_type_error-0x4
    1ee9:	jmp    1ff5 <botlish_fn_21+0x225>
    1eee:	mov    rcx,r8
    1ef1:	mov    rax,rsi
    1ef4:	and    rax,rcx
    1ef7:	test   rax,0x1
    1efd:	jne    1f23 <botlish_fn_21+0x153>
    1f03:	mov    rdx,r8
    1f06:	mov    rdi,rbx
    1f09:	call   1f0e <botlish_fn_21+0x13e>
			1f0a: R_X86_64_PLT32	rt_int_cmp-0x4
    1f0e:	mov    ecx,0x2
    1f13:	test   rax,rax
    1f16:	cmovg  rcx,QWORD PTR [rip+0x10a]        # 2028 <botlish_fn_21+0x258>
    1f1e:	jmp    1f36 <botlish_fn_21+0x166>
    1f23:	mov    ecx,0x2
    1f28:	mov    rax,r8
    1f2b:	cmp    rsi,rax
    1f2e:	cmovg  rcx,QWORD PTR [rip+0xf2]        # 2028 <botlish_fn_21+0x258>
    1f36:	cmp    rcx,0x6
    1f3a:	je     1fbe <botlish_fn_21+0x1ee>
    1f40:	mov    rsi,r12
    1f43:	mov    rdi,rbx
    1f46:	call   1f4b <botlish_fn_21+0x17b>
			1f47: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1f4b:	test   rdx,rdx
    1f4e:	je     1ff5 <botlish_fn_21+0x225>
    1f54:	shl    rax,1
    1f57:	mov    rsi,rax
    1f5a:	or     rsi,0x1
    1f5e:	mov    QWORD PTR [rsp+0x8],rsi
    1f63:	mov    QWORD PTR [rsp+0x10],0x5
    1f6c:	mov    rax,rsi
    1f6f:	sar    rax,1
    1f72:	imul   QWORD PTR [rip+0xb7]        # 2030 <botlish_fn_21+0x260>
    1f79:	seto   cl
    1f7c:	or     rax,0x1
    1f80:	test   cl,cl
    1f82:	jne    1f90 <botlish_fn_21+0x1c0>
    1f88:	mov    rdx,rax
    1f8b:	jmp    1fa0 <botlish_fn_21+0x1d0>
    1f90:	mov    edx,0x5
    1f95:	mov    rdi,rbx
    1f98:	call   1f9d <botlish_fn_21+0x1cd>
			1f99: R_X86_64_PLT32	rt_int_mul-0x4
    1f9d:	mov    rdx,rax
    1fa0:	mov    QWORD PTR [rsp+0x8],rdx
    1fa5:	mov    rsi,r12
    1fa8:	mov    rdi,rbx
    1fab:	call   1fb0 <botlish_fn_21+0x1e0>
			1fac: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1fb0:	test   rax,rax
    1fb3:	je     1ff5 <botlish_fn_21+0x225>
    1fb9:	jmp    2010 <botlish_fn_21+0x240>
    1fbe:	mov    rsi,r12
    1fc1:	mov    rdi,rbx
    1fc4:	call   1fc9 <botlish_fn_21+0x1f9>
			1fc5: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_capacity<mutarray>
    1fc9:	test   rdx,rdx
    1fcc:	je     1ff5 <botlish_fn_21+0x225>
    1fd2:	shl    rax,1
    1fd5:	mov    rdx,rax
    1fd8:	or     rdx,0x1
    1fdc:	mov    QWORD PTR [rsp+0x8],rdx
    1fe1:	mov    rsi,r12
    1fe4:	mov    rdi,rbx
    1fe7:	call   1fec <botlish_fn_21+0x21c>
			1fe8: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_rehash<mutarray, int>
    1fec:	test   rax,rax
    1fef:	jne    2010 <botlish_fn_21+0x240>
    1ff5:	xor    rax,rax
    1ff8:	mov    rbx,QWORD PTR [rsp+0x20]
    1ffd:	mov    r12,QWORD PTR [rsp+0x28]
    2002:	mov    r13,QWORD PTR [rsp+0x30]
    2007:	add    rsp,0x40
    200b:	mov    rsp,rbp
    200e:	pop    rbp
    200f:	ret
    2010:	mov    rbx,QWORD PTR [rsp+0x20]
    2015:	mov    r12,QWORD PTR [rsp+0x28]
    201a:	mov    r13,QWORD PTR [rsp+0x30]
    201f:	add    rsp,0x40
    2023:	mov    rsp,rbp
    2026:	pop    rbp
    2027:	ret
    2028:	(bad)
    2029:	add    BYTE PTR [rax],al
    202b:	add    BYTE PTR [rax],al
    202d:	add    BYTE PTR [rax],al
    202f:	add    BYTE PTR [rax+rax*1],al
    2032:	add    BYTE PTR [rax],al
    2034:	add    BYTE PTR [rax],al
	...

0000000000002038 <botlish_entry_21: ht_grow_or_clean<mutarray>>:
    2038:	push   rbp
    2039:	mov    rbp,rsp
    203c:	mov    rsi,QWORD PTR [rdx]
    203f:	call   2044 <botlish_entry_21+0xc>
			2040: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    2044:	mov    rsp,rbp
    2047:	pop    rbp
    2048:	ret
    2049:	add    BYTE PTR [rax],al
    204b:	add    BYTE PTR [rax],al
    204d:	add    BYTE PTR [rax],al
	...

0000000000002050 <botlish_fn_22: ht_place<mutarray, int, str, str>>:
    2050:	push   rbp
    2051:	mov    rbp,rsp
    2054:	sub    rsp,0x70
    2058:	mov    QWORD PTR [rsp+0x40],rbx
    205d:	mov    QWORD PTR [rsp+0x48],r12
    2062:	mov    QWORD PTR [rsp+0x50],r13
    2067:	mov    QWORD PTR [rsp+0x58],r14
    206c:	mov    QWORD PTR [rsp+0x60],r15
    2071:	mov    rbx,rdi
    2074:	mov    r14,r8
    2077:	mov    r15,rdx
    207a:	mov    QWORD PTR [rsp+0x28],rcx
    207f:	mov    QWORD PTR [rsp],rsi
    2083:	mov    r12,rsi
    2086:	mov    rsi,r12
    2089:	mov    rdi,rbx
    208c:	call   2091 <botlish_fn_22+0x41>
			208d: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    2091:	test   rax,rax
    2094:	je     23fa <botlish_fn_22+0x3aa>
    209a:	xor    ecx,ecx
    209c:	test   rax,0x7
    20a2:	je     20b2 <botlish_fn_22+0x62>
    20a8:	mov    QWORD PTR [rsp+0x30],rax
    20ad:	jmp    20c2 <botlish_fn_22+0x72>
    20b2:	movzx  rcx,BYTE PTR [rax]
    20b6:	mov    QWORD PTR [rsp+0x30],rax
    20bb:	rex cmp cl,0x8
    20bf:	sete   cl
    20c2:	test   cl,cl
    20c4:	jne    20e9 <botlish_fn_22+0x99>
    20ca:	mov    rdi,rbx
    20cd:	mov    rax,QWORD PTR [rdi+0x10]
    20d1:	mov    rcx,QWORD PTR [rax+0x8]
    20d5:	mov    edx,0x8
    20da:	mov    rsi,QWORD PTR [rsp+0x30]
    20df:	call   20e4 <botlish_fn_22+0x94>
			20e0: R_X86_64_PLT32	rt_type_error-0x4
    20e4:	jmp    23fa <botlish_fn_22+0x3aa>
    20e9:	mov    rdx,r15
    20ec:	mov    rsi,QWORD PTR [rsp+0x30]
    20f1:	mov    rdi,rbx
    20f4:	call   20f9 <botlish_fn_22+0xa9>
			20f5: R_X86_64_PLT32	rt_mutarray_get-0x4
    20f9:	test   rax,rax
    20fc:	je     23fa <botlish_fn_22+0x3aa>
    2102:	mov    QWORD PTR [rsp+0x8],rax
    2107:	mov    r13,rax
    210a:	mov    ecx,0x3
    210f:	mov    rsi,QWORD PTR [rsp+0x30]
    2114:	mov    rdx,r15
    2117:	mov    rdi,rbx
    211a:	call   211f <botlish_fn_22+0xcf>
			211b: R_X86_64_PLT32	rt_mutarray_set-0x4
    211f:	test   rax,rax
    2122:	je     23fa <botlish_fn_22+0x3aa>
    2128:	mov    rsi,r12
    212b:	mov    rdi,rbx
    212e:	call   2133 <botlish_fn_22+0xe3>
			212f: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    2133:	test   rax,rax
    2136:	je     23fa <botlish_fn_22+0x3aa>
    213c:	xor    ecx,ecx
    213e:	test   rax,0x7
    2144:	je     2152 <botlish_fn_22+0x102>
    214a:	mov    rsi,rax
    214d:	jmp    2160 <botlish_fn_22+0x110>
    2152:	movzx  rcx,BYTE PTR [rax]
    2156:	mov    rsi,rax
    2159:	rex cmp cl,0x8
    215d:	sete   cl
    2160:	test   cl,cl
    2162:	jne    2182 <botlish_fn_22+0x132>
    2168:	mov    rdi,rbx
    216b:	mov    rax,QWORD PTR [rdi+0x10]
    216f:	mov    rcx,QWORD PTR [rax+0x20]
    2173:	mov    edx,0x8
    2178:	call   217d <botlish_fn_22+0x12d>
			2179: R_X86_64_PLT32	rt_type_error-0x4
    217d:	jmp    23fa <botlish_fn_22+0x3aa>
    2182:	mov    rcx,QWORD PTR [rsp+0x28]
    2187:	mov    rdx,r15
    218a:	mov    rdi,rbx
    218d:	call   2192 <botlish_fn_22+0x142>
			218e: R_X86_64_PLT32	rt_mutarray_set-0x4
    2192:	test   rax,rax
    2195:	je     23fa <botlish_fn_22+0x3aa>
    219b:	mov    rsi,r12
    219e:	mov    rdi,rbx
    21a1:	call   21a6 <botlish_fn_22+0x156>
			21a2: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    21a6:	test   rax,rax
    21a9:	je     23fa <botlish_fn_22+0x3aa>
    21af:	xor    esi,esi
    21b1:	test   rax,0x7
    21b7:	jne    21c9 <botlish_fn_22+0x179>
    21bd:	movzx  rcx,BYTE PTR [rax]
    21c1:	rex cmp cl,0x8
    21c5:	sete   sil
    21c9:	test   sil,sil
    21cc:	jne    21ef <botlish_fn_22+0x19f>
    21d2:	mov    rdi,rbx
    21d5:	mov    rsi,QWORD PTR [rdi+0x10]
    21d9:	mov    rcx,QWORD PTR [rsi+0x20]
    21dd:	mov    edx,0x8
    21e2:	mov    rsi,rax
    21e5:	call   21ea <botlish_fn_22+0x19a>
			21e6: R_X86_64_PLT32	rt_type_error-0x4
    21ea:	jmp    23fa <botlish_fn_22+0x3aa>
    21ef:	mov    rcx,r14
    21f2:	mov    rdx,r15
    21f5:	mov    rsi,rax
    21f8:	mov    rdi,rbx
    21fb:	call   2200 <botlish_fn_22+0x1b0>
			21fc: R_X86_64_PLT32	rt_mutarray_set-0x4
    2200:	test   rax,rax
    2203:	je     23fa <botlish_fn_22+0x3aa>
    2209:	mov    QWORD PTR [rsp+0x10],0x7
    2212:	mov    rsi,r12
    2215:	mov    rdi,rbx
    2218:	call   221d <botlish_fn_22+0x1cd>
			2219: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    221d:	test   rax,rax
    2220:	je     23fa <botlish_fn_22+0x3aa>
    2226:	mov    QWORD PTR [rsp+0x18],rax
    222b:	mov    QWORD PTR [rsp+0x20],0x3
    2234:	mov    ecx,0x1
    2239:	test   rax,0x1
    223f:	je     224d <botlish_fn_22+0x1fd>
    2245:	mov    rsi,rax
    2248:	jmp    2271 <botlish_fn_22+0x221>
    224d:	xor    ecx,ecx
    224f:	test   rax,0x7
    2255:	je     2263 <botlish_fn_22+0x213>
    225b:	mov    rsi,rax
    225e:	jmp    2271 <botlish_fn_22+0x221>
    2263:	movzx  rcx,BYTE PTR [rax]
    2267:	mov    rsi,rax
    226a:	rex cmp cl,0x1
    226e:	sete   cl
    2271:	test   cl,cl
    2273:	jne    2291 <botlish_fn_22+0x241>
    2279:	mov    rdi,rbx
    227c:	mov    rax,QWORD PTR [rdi+0x10]
    2280:	mov    rcx,QWORD PTR [rax+0x10]
    2284:	xor    rdx,rdx
    2287:	call   228c <botlish_fn_22+0x23c>
			2288: R_X86_64_PLT32	rt_type_error-0x4
    228c:	jmp    23fa <botlish_fn_22+0x3aa>
    2291:	test   rsi,0x1
    2298:	je     22b0 <botlish_fn_22+0x260>
    229e:	mov    rcx,rsi
    22a1:	add    rcx,0x2
    22a5:	seto   al
    22a8:	test   al,al
    22aa:	je     22c0 <botlish_fn_22+0x270>
    22b0:	mov    edx,0x3
    22b5:	mov    rdi,rbx
    22b8:	call   22bd <botlish_fn_22+0x26d>
			22b9: R_X86_64_PLT32	rt_int_add-0x4
    22bd:	mov    rcx,rax
    22c0:	mov    edx,0x7
    22c5:	mov    rsi,r12
    22c8:	mov    rdi,rbx
    22cb:	call   22d0 <botlish_fn_22+0x280>
			22cc: R_X86_64_PLT32	rt_mutarray_set-0x4
    22d0:	test   rax,rax
    22d3:	je     23fa <botlish_fn_22+0x3aa>
    22d9:	mov    rax,r13
    22dc:	test   rax,0x1
    22e2:	jne    2306 <botlish_fn_22+0x2b6>
    22e8:	mov    edx,0x5
    22ed:	mov    rsi,r13
    22f0:	mov    rdi,rbx
    22f3:	call   22f8 <botlish_fn_22+0x2a8>
			22f4: R_X86_64_PLT32	rt_value_eq-0x4
    22f8:	test   rax,rax
    22fb:	je     23fa <botlish_fn_22+0x3aa>
    2301:	jmp    231a <botlish_fn_22+0x2ca>
    2306:	mov    rsi,r13
    2309:	mov    eax,0x2
    230e:	cmp    rsi,0x5
    2312:	cmove  rax,QWORD PTR [rip+0x12e]        # 2448 <botlish_fn_22+0x3f8>
    231a:	cmp    rax,0x6
    231e:	jne    241f <botlish_fn_22+0x3cf>
    2324:	mov    QWORD PTR [rsp+0x8],0x9
    232d:	mov    rsi,r12
    2330:	mov    rdi,rbx
    2333:	call   2338 <botlish_fn_22+0x2e8>
			2334: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2338:	test   rax,rax
    233b:	je     23fa <botlish_fn_22+0x3aa>
    2341:	mov    QWORD PTR [rsp+0x10],rax
    2346:	mov    QWORD PTR [rsp+0x18],0x3
    234f:	mov    ecx,0x1
    2354:	test   rax,0x1
    235a:	je     2368 <botlish_fn_22+0x318>
    2360:	mov    rsi,rax
    2363:	jmp    238c <botlish_fn_22+0x33c>
    2368:	xor    ecx,ecx
    236a:	test   rax,0x7
    2370:	je     237e <botlish_fn_22+0x32e>
    2376:	mov    rsi,rax
    2379:	jmp    238c <botlish_fn_22+0x33c>
    237e:	movzx  rcx,BYTE PTR [rax]
    2382:	mov    rsi,rax
    2385:	rex cmp cl,0x1
    2389:	sete   cl
    238c:	test   cl,cl
    238e:	jne    23ac <botlish_fn_22+0x35c>
    2394:	mov    rdi,rbx
    2397:	mov    rcx,QWORD PTR [rdi+0x10]
    239b:	mov    rcx,QWORD PTR [rcx+0x28]
    239f:	xor    rdx,rdx
    23a2:	call   23a7 <botlish_fn_22+0x357>
			23a3: R_X86_64_PLT32	rt_type_error-0x4
    23a7:	jmp    23fa <botlish_fn_22+0x3aa>
    23ac:	test   rsi,0x1
    23b3:	je     23d1 <botlish_fn_22+0x381>
    23b9:	mov    r8,rsi
    23bc:	sub    r8,0x3
    23c0:	seto   dil
    23c4:	lea    rcx,[r8+0x1]
    23c8:	test   dil,dil
    23cb:	je     23e1 <botlish_fn_22+0x391>
    23d1:	mov    edx,0x3
    23d6:	mov    rdi,rbx
    23d9:	call   23de <botlish_fn_22+0x38e>
			23da: R_X86_64_PLT32	rt_int_sub-0x4
    23de:	mov    rcx,rax
    23e1:	mov    edx,0x9
    23e6:	mov    rsi,r12
    23e9:	mov    rdi,rbx
    23ec:	call   23f1 <botlish_fn_22+0x3a1>
			23ed: R_X86_64_PLT32	rt_mutarray_set-0x4
    23f1:	test   rax,rax
    23f4:	jne    241f <botlish_fn_22+0x3cf>
    23fa:	xor    rax,rax
    23fd:	mov    rbx,QWORD PTR [rsp+0x40]
    2402:	mov    r12,QWORD PTR [rsp+0x48]
    2407:	mov    r13,QWORD PTR [rsp+0x50]
    240c:	mov    r14,QWORD PTR [rsp+0x58]
    2411:	mov    r15,QWORD PTR [rsp+0x60]
    2416:	add    rsp,0x70
    241a:	mov    rsp,rbp
    241d:	pop    rbp
    241e:	ret
    241f:	mov    eax,0xa
    2424:	mov    rbx,QWORD PTR [rsp+0x40]
    2429:	mov    r12,QWORD PTR [rsp+0x48]
    242e:	mov    r13,QWORD PTR [rsp+0x50]
    2433:	mov    r14,QWORD PTR [rsp+0x58]
    2438:	mov    r15,QWORD PTR [rsp+0x60]
    243d:	add    rsp,0x70
    2441:	mov    rsp,rbp
    2444:	pop    rbp
    2445:	ret
    2446:	add    BYTE PTR [rax],al
    2448:	(bad)
    2449:	add    BYTE PTR [rax],al
    244b:	add    BYTE PTR [rax],al
    244d:	add    BYTE PTR [rax],al
	...

0000000000002450 <botlish_entry_22: ht_place<mutarray, int, str, str>>:
    2450:	push   rbp
    2451:	mov    rbp,rsp
    2454:	mov    rsi,QWORD PTR [rdx]
    2457:	mov    r9,QWORD PTR [rdx+0x8]
    245b:	mov    rcx,QWORD PTR [rdx+0x10]
    245f:	mov    r8,QWORD PTR [rdx+0x18]
    2463:	mov    rdx,r9
    2466:	call   246b <botlish_entry_22+0x1b>
			2467: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    246b:	mov    rsp,rbp
    246e:	pop    rbp
    246f:	ret

0000000000002470 <botlish_fn_23: ht_set<mutarray, str, str>>:
    2470:	push   rbp
    2471:	mov    rbp,rsp
    2474:	sub    rsp,0x60
    2478:	mov    QWORD PTR [rsp+0x30],rbx
    247d:	mov    QWORD PTR [rsp+0x38],r12
    2482:	mov    QWORD PTR [rsp+0x40],r13
    2487:	mov    QWORD PTR [rsp+0x48],r14
    248c:	mov    QWORD PTR [rsp+0x50],r15
    2491:	mov    rbx,rdi
    2494:	mov    r13,rdx
    2497:	mov    QWORD PTR [rsp],rsi
    249b:	mov    r14,rsi
    249e:	mov    QWORD PTR [rsp+0x8],rdx
    24a3:	mov    QWORD PTR [rsp+0x10],rcx
    24a8:	mov    r12,rcx
    24ab:	mov    rdx,r13
    24ae:	mov    rsi,r14
    24b1:	mov    rdi,rbx
    24b4:	call   24b9 <botlish_fn_23+0x49>
			24b5: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    24b9:	test   rax,rax
    24bc:	je     2727 <botlish_fn_23+0x2b7>
    24c2:	mov    QWORD PTR [rsp+0x18],rax
    24c7:	mov    rcx,rax
    24ca:	mov    r8,0xffffffffffffffff
    24d1:	mov    QWORD PTR [rsp+0x28],r8
    24d6:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    24df:	mov    rdx,r13
    24e2:	mov    rsi,r14
    24e5:	mov    rdi,rbx
    24e8:	call   24ed <botlish_fn_23+0x7d>
			24e9: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    24ed:	mov    rcx,rax
    24f0:	mov    r15,rax
    24f3:	test   rax,rcx
    24f6:	je     2727 <botlish_fn_23+0x2b7>
    24fc:	mov    rax,r15
    24ff:	mov    QWORD PTR [rsp+0x18],rax
    2504:	mov    rsi,r14
    2507:	mov    rdi,rbx
    250a:	call   250f <botlish_fn_23+0x9f>
			250b: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    250f:	test   rax,rax
    2512:	je     2727 <botlish_fn_23+0x2b7>
    2518:	xor    ecx,ecx
    251a:	test   rax,0x7
    2520:	je     252e <botlish_fn_23+0xbe>
    2526:	mov    r8,rax
    2529:	jmp    253c <botlish_fn_23+0xcc>
    252e:	movzx  rcx,BYTE PTR [rax]
    2532:	mov    r8,rax
    2535:	rex cmp cl,0x8
    2539:	sete   cl
    253c:	test   cl,cl
    253e:	jne    2561 <botlish_fn_23+0xf1>
    2544:	mov    rdi,rbx
    2547:	mov    rsi,QWORD PTR [rdi+0x10]
    254b:	mov    rcx,QWORD PTR [rsi+0x8]
    254f:	mov    edx,0x8
    2554:	mov    rsi,r8
    2557:	call   255c <botlish_fn_23+0xec>
			2558: R_X86_64_PLT32	rt_type_error-0x4
    255c:	jmp    2727 <botlish_fn_23+0x2b7>
    2561:	mov    rsi,r8
    2564:	mov    rdx,r15
    2567:	mov    rdi,rbx
    256a:	call   256f <botlish_fn_23+0xff>
			256b: R_X86_64_PLT32	rt_mutarray_get-0x4
    256f:	test   rax,rax
    2572:	je     2727 <botlish_fn_23+0x2b7>
    2578:	test   rax,0x1
    257e:	mov    rsi,rax
    2581:	jne    25a2 <botlish_fn_23+0x132>
    2587:	mov    edx,0x3
    258c:	mov    rdi,rbx
    258f:	call   2594 <botlish_fn_23+0x124>
			2590: R_X86_64_PLT32	rt_value_eq-0x4
    2594:	test   rax,rax
    2597:	je     2727 <botlish_fn_23+0x2b7>
    259d:	jmp    25b3 <botlish_fn_23+0x143>
    25a2:	mov    eax,0x2
    25a7:	cmp    rsi,0x3
    25ab:	cmove  rax,QWORD PTR [rip+0x1c5]        # 2778 <botlish_fn_23+0x308>
    25b3:	cmp    rax,0x6
    25b7:	je     26b6 <botlish_fn_23+0x246>
    25bd:	mov    rsi,r14
    25c0:	mov    rdi,rbx
    25c3:	call   25c8 <botlish_fn_23+0x158>
			25c4: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_should_grow<mutarray>
    25c8:	test   rax,rax
    25cb:	je     2727 <botlish_fn_23+0x2b7>
    25d1:	cmp    rax,0x6
    25d5:	je     261a <botlish_fn_23+0x1aa>
    25db:	mov    rcx,r13
    25de:	mov    rdx,r15
    25e1:	mov    rsi,r14
    25e4:	mov    rdi,rbx
    25e7:	mov    r8,r12
    25ea:	call   25ef <botlish_fn_23+0x17f>
			25eb: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    25ef:	test   rax,rax
    25f2:	je     2727 <botlish_fn_23+0x2b7>
    25f8:	mov    rbx,QWORD PTR [rsp+0x30]
    25fd:	mov    r12,QWORD PTR [rsp+0x38]
    2602:	mov    r13,QWORD PTR [rsp+0x40]
    2607:	mov    r14,QWORD PTR [rsp+0x48]
    260c:	mov    r15,QWORD PTR [rsp+0x50]
    2611:	add    rsp,0x60
    2615:	mov    rsp,rbp
    2618:	pop    rbp
    2619:	ret
    261a:	mov    rsi,r14
    261d:	mov    rdi,rbx
    2620:	call   2625 <botlish_fn_23+0x1b5>
			2621: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_grow_or_clean<mutarray>
    2625:	test   rax,rax
    2628:	je     2727 <botlish_fn_23+0x2b7>
    262e:	mov    rdx,r13
    2631:	mov    rsi,r14
    2634:	mov    rdi,rbx
    2637:	call   263c <botlish_fn_23+0x1cc>
			2638: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    263c:	test   rax,rax
    263f:	je     2727 <botlish_fn_23+0x2b7>
    2645:	mov    QWORD PTR [rsp+0x18],rax
    264a:	mov    rcx,rax
    264d:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    2656:	mov    r8,QWORD PTR [rsp+0x28]
    265b:	mov    rdx,r13
    265e:	mov    rsi,r14
    2661:	mov    rdi,rbx
    2664:	call   2669 <botlish_fn_23+0x1f9>
			2665: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_find_insert<mutarray, str, int, int>
    2669:	test   rax,rax
    266c:	je     2727 <botlish_fn_23+0x2b7>
    2672:	mov    QWORD PTR [rsp+0x18],rax
    2677:	mov    rcx,r13
    267a:	mov    rdx,rax
    267d:	mov    rsi,r14
    2680:	mov    rdi,rbx
    2683:	mov    r8,r12
    2686:	call   268b <botlish_fn_23+0x21b>
			2687: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_place<mutarray, int, str, str>
    268b:	test   rax,rax
    268e:	je     2727 <botlish_fn_23+0x2b7>
    2694:	mov    rbx,QWORD PTR [rsp+0x30]
    2699:	mov    r12,QWORD PTR [rsp+0x38]
    269e:	mov    r13,QWORD PTR [rsp+0x40]
    26a3:	mov    r14,QWORD PTR [rsp+0x48]
    26a8:	mov    r15,QWORD PTR [rsp+0x50]
    26ad:	add    rsp,0x60
    26b1:	mov    rsp,rbp
    26b4:	pop    rbp
    26b5:	ret
    26b6:	mov    rsi,r14
    26b9:	mov    rdi,rbx
    26bc:	call   26c1 <botlish_fn_23+0x251>
			26bd: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    26c1:	test   rax,rax
    26c4:	je     2727 <botlish_fn_23+0x2b7>
    26ca:	xor    ecx,ecx
    26cc:	test   rax,0x7
    26d2:	je     26e0 <botlish_fn_23+0x270>
    26d8:	mov    rsi,rax
    26db:	jmp    26ee <botlish_fn_23+0x27e>
    26e0:	movzx  rcx,BYTE PTR [rax]
    26e4:	mov    rsi,rax
    26e7:	rex cmp cl,0x8
    26eb:	sete   cl
    26ee:	test   cl,cl
    26f0:	jne    2710 <botlish_fn_23+0x2a0>
    26f6:	mov    rdi,rbx
    26f9:	mov    rax,QWORD PTR [rdi+0x10]
    26fd:	mov    rcx,QWORD PTR [rax+0x20]
    2701:	mov    edx,0x8
    2706:	call   270b <botlish_fn_23+0x29b>
			2707: R_X86_64_PLT32	rt_type_error-0x4
    270b:	jmp    2727 <botlish_fn_23+0x2b7>
    2710:	mov    rcx,r12
    2713:	mov    rdx,r15
    2716:	mov    rdi,rbx
    2719:	call   271e <botlish_fn_23+0x2ae>
			271a: R_X86_64_PLT32	rt_mutarray_set-0x4
    271e:	test   rax,rax
    2721:	jne    274c <botlish_fn_23+0x2dc>
    2727:	xor    rax,rax
    272a:	mov    rbx,QWORD PTR [rsp+0x30]
    272f:	mov    r12,QWORD PTR [rsp+0x38]
    2734:	mov    r13,QWORD PTR [rsp+0x40]
    2739:	mov    r14,QWORD PTR [rsp+0x48]
    273e:	mov    r15,QWORD PTR [rsp+0x50]
    2743:	add    rsp,0x60
    2747:	mov    rsp,rbp
    274a:	pop    rbp
    274b:	ret
    274c:	mov    eax,0xa
    2751:	mov    rbx,QWORD PTR [rsp+0x30]
    2756:	mov    r12,QWORD PTR [rsp+0x38]
    275b:	mov    r13,QWORD PTR [rsp+0x40]
    2760:	mov    r14,QWORD PTR [rsp+0x48]
    2765:	mov    r15,QWORD PTR [rsp+0x50]
    276a:	add    rsp,0x60
    276e:	mov    rsp,rbp
    2771:	pop    rbp
    2772:	ret
    2773:	add    BYTE PTR [rax],al
    2775:	add    BYTE PTR [rax],al
    2777:	add    BYTE PTR [rsi],al
    2779:	add    BYTE PTR [rax],al
    277b:	add    BYTE PTR [rax],al
    277d:	add    BYTE PTR [rax],al
	...

0000000000002780 <botlish_entry_23: ht_set<mutarray, str, str>>:
    2780:	push   rbp
    2781:	mov    rbp,rsp
    2784:	mov    rsi,QWORD PTR [rdx]
    2787:	mov    r8,QWORD PTR [rdx+0x8]
    278b:	mov    rcx,QWORD PTR [rdx+0x10]
    278f:	mov    rdx,r8
    2792:	call   2797 <botlish_entry_23+0x17>
			2793: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2797:	mov    rsp,rbp
    279a:	pop    rbp
    279b:	ret
    279c:	add    BYTE PTR [rax],al
	...

00000000000027a0 <botlish_fn_24: ht_delete<mutarray, str>>:
    27a0:	push   rbp
    27a1:	mov    rbp,rsp
    27a4:	sub    rsp,0x40
    27a8:	mov    QWORD PTR [rsp+0x20],rbx
    27ad:	mov    QWORD PTR [rsp+0x28],r12
    27b2:	mov    QWORD PTR [rsp+0x30],r13
    27b7:	mov    rbx,rdi
    27ba:	mov    QWORD PTR [rsp+0x18],0x0
    27c3:	mov    QWORD PTR [rsp],rsi
    27c7:	mov    r12,rsi
    27ca:	mov    QWORD PTR [rsp+0x8],rdx
    27cf:	mov    r13,rdx
    27d2:	mov    rdx,r13
    27d5:	mov    rsi,r12
    27d8:	mov    rdi,rbx
    27db:	call   27e0 <botlish_fn_24+0x40>
			27dc: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_probe_start<mutarray, str>
    27e0:	test   rax,rax
    27e3:	je     2b50 <botlish_fn_24+0x3b0>
    27e9:	mov    QWORD PTR [rsp+0x10],rax
    27ee:	mov    rcx,rax
    27f1:	mov    rdx,r13
    27f4:	mov    rsi,r12
    27f7:	mov    rdi,rbx
    27fa:	call   27ff <botlish_fn_24+0x5f>
			27fb: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_find_get<mutarray, str, int>
    27ff:	mov    rcx,rax
    2802:	mov    r13,rax
    2805:	test   rax,rcx
    2808:	je     2b50 <botlish_fn_24+0x3b0>
    280e:	mov    rax,r13
    2811:	test   rax,0x1
    2817:	jne    2842 <botlish_fn_24+0xa2>
    281d:	mov    edx,0x1
    2822:	mov    rsi,r13
    2825:	mov    rdi,rbx
    2828:	call   282d <botlish_fn_24+0x8d>
			2829: R_X86_64_PLT32	rt_int_cmp-0x4
    282d:	mov    ecx,0x2
    2832:	test   rax,rax
    2835:	cmovl  rcx,QWORD PTR [rip+0x36b]        # 2ba8 <botlish_fn_24+0x408>
    283d:	jmp    2858 <botlish_fn_24+0xb8>
    2842:	mov    ecx,0x2
    2847:	mov    rax,r13
    284a:	mov    rdx,r13
    284d:	test   rax,rdx
    2850:	cmovle rcx,QWORD PTR [rip+0x350]        # 2ba8 <botlish_fn_24+0x408>
    2858:	cmp    rcx,0x6
    285c:	je     2b88 <botlish_fn_24+0x3e8>
    2862:	mov    rsi,r12
    2865:	mov    rdi,rbx
    2868:	call   286d <botlish_fn_24+0xcd>
			2869: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_controls<mutarray>
    286d:	test   rax,rax
    2870:	je     2b50 <botlish_fn_24+0x3b0>
    2876:	xor    ecx,ecx
    2878:	test   rax,0x7
    287e:	je     288c <botlish_fn_24+0xec>
    2884:	mov    rsi,rax
    2887:	jmp    289a <botlish_fn_24+0xfa>
    288c:	movzx  rcx,BYTE PTR [rax]
    2890:	mov    rsi,rax
    2893:	rex cmp cl,0x8
    2897:	sete   cl
    289a:	test   cl,cl
    289c:	jne    28bc <botlish_fn_24+0x11c>
    28a2:	mov    rdi,rbx
    28a5:	mov    rax,QWORD PTR [rdi+0x10]
    28a9:	mov    rcx,QWORD PTR [rax+0x20]
    28ad:	mov    edx,0x8
    28b2:	call   28b7 <botlish_fn_24+0x117>
			28b3: R_X86_64_PLT32	rt_type_error-0x4
    28b7:	jmp    2b50 <botlish_fn_24+0x3b0>
    28bc:	mov    ecx,0x5
    28c1:	mov    rdx,r13
    28c4:	mov    rdi,rbx
    28c7:	call   28cc <botlish_fn_24+0x12c>
			28c8: R_X86_64_PLT32	rt_mutarray_set-0x4
    28cc:	test   rax,rax
    28cf:	je     2b50 <botlish_fn_24+0x3b0>
    28d5:	mov    rsi,r12
    28d8:	mov    rdi,rbx
    28db:	call   28e0 <botlish_fn_24+0x140>
			28dc: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_keys<mutarray>
    28e0:	test   rax,rax
    28e3:	je     2b50 <botlish_fn_24+0x3b0>
    28e9:	xor    ecx,ecx
    28eb:	test   rax,0x7
    28f1:	jne    2902 <botlish_fn_24+0x162>
    28f7:	movzx  rsi,BYTE PTR [rax]
    28fb:	cmp    sil,0x8
    28ff:	sete   cl
    2902:	test   cl,cl
    2904:	jne    2927 <botlish_fn_24+0x187>
    290a:	mov    rdi,rbx
    290d:	mov    r9,QWORD PTR [rdi+0x10]
    2911:	mov    rcx,QWORD PTR [r9+0x20]
    2915:	mov    edx,0x8
    291a:	mov    rsi,rax
    291d:	call   2922 <botlish_fn_24+0x182>
			291e: R_X86_64_PLT32	rt_type_error-0x4
    2922:	jmp    2b50 <botlish_fn_24+0x3b0>
    2927:	mov    rsi,rax
    292a:	mov    ecx,0xa
    292f:	mov    rdx,r13
    2932:	mov    rdi,rbx
    2935:	call   293a <botlish_fn_24+0x19a>
			2936: R_X86_64_PLT32	rt_mutarray_set-0x4
    293a:	test   rax,rax
    293d:	je     2b50 <botlish_fn_24+0x3b0>
    2943:	mov    rsi,r12
    2946:	mov    rdi,rbx
    2949:	call   294e <botlish_fn_24+0x1ae>
			294a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_values<mutarray>
    294e:	test   rax,rax
    2951:	je     2b50 <botlish_fn_24+0x3b0>
    2957:	xor    ecx,ecx
    2959:	test   rax,0x7
    295f:	je     296d <botlish_fn_24+0x1cd>
    2965:	mov    rsi,rax
    2968:	jmp    297b <botlish_fn_24+0x1db>
    296d:	movzx  rcx,BYTE PTR [rax]
    2971:	mov    rsi,rax
    2974:	rex cmp cl,0x8
    2978:	sete   cl
    297b:	test   cl,cl
    297d:	jne    299d <botlish_fn_24+0x1fd>
    2983:	mov    rdi,rbx
    2986:	mov    rax,QWORD PTR [rdi+0x10]
    298a:	mov    rcx,QWORD PTR [rax+0x20]
    298e:	mov    edx,0x8
    2993:	call   2998 <botlish_fn_24+0x1f8>
			2994: R_X86_64_PLT32	rt_type_error-0x4
    2998:	jmp    2b50 <botlish_fn_24+0x3b0>
    299d:	mov    ecx,0xa
    29a2:	mov    rdx,r13
    29a5:	mov    rdi,rbx
    29a8:	call   29ad <botlish_fn_24+0x20d>
			29a9: R_X86_64_PLT32	rt_mutarray_set-0x4
    29ad:	test   rax,rax
    29b0:	je     2b50 <botlish_fn_24+0x3b0>
    29b6:	mov    QWORD PTR [rsp+0x8],0x7
    29bf:	mov    rsi,r12
    29c2:	mov    rdi,rbx
    29c5:	call   29ca <botlish_fn_24+0x22a>
			29c6: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    29ca:	test   rax,rax
    29cd:	je     2b50 <botlish_fn_24+0x3b0>
    29d3:	mov    QWORD PTR [rsp+0x10],rax
    29d8:	mov    QWORD PTR [rsp+0x18],0x3
    29e1:	mov    ecx,0x1
    29e6:	test   rax,0x1
    29ec:	je     29fa <botlish_fn_24+0x25a>
    29f2:	mov    rsi,rax
    29f5:	jmp    2a1e <botlish_fn_24+0x27e>
    29fa:	xor    ecx,ecx
    29fc:	test   rax,0x7
    2a02:	je     2a10 <botlish_fn_24+0x270>
    2a08:	mov    rsi,rax
    2a0b:	jmp    2a1e <botlish_fn_24+0x27e>
    2a10:	movzx  rcx,BYTE PTR [rax]
    2a14:	mov    rsi,rax
    2a17:	rex cmp cl,0x1
    2a1b:	sete   cl
    2a1e:	test   cl,cl
    2a20:	jne    2a3e <botlish_fn_24+0x29e>
    2a26:	mov    rdi,rbx
    2a29:	mov    rax,QWORD PTR [rdi+0x10]
    2a2d:	mov    rcx,QWORD PTR [rax+0x28]
    2a31:	xor    rdx,rdx
    2a34:	call   2a39 <botlish_fn_24+0x299>
			2a35: R_X86_64_PLT32	rt_type_error-0x4
    2a39:	jmp    2b50 <botlish_fn_24+0x3b0>
    2a3e:	test   rsi,0x1
    2a45:	je     2a64 <botlish_fn_24+0x2c4>
    2a4b:	mov    rcx,rsi
    2a4e:	sub    rcx,0x3
    2a52:	seto   al
    2a55:	add    rcx,0x1
    2a5c:	test   al,al
    2a5e:	je     2a74 <botlish_fn_24+0x2d4>
    2a64:	mov    edx,0x3
    2a69:	mov    rdi,rbx
    2a6c:	call   2a71 <botlish_fn_24+0x2d1>
			2a6d: R_X86_64_PLT32	rt_int_sub-0x4
    2a71:	mov    rcx,rax
    2a74:	mov    edx,0x7
    2a79:	mov    rsi,r12
    2a7c:	mov    rdi,rbx
    2a7f:	call   2a84 <botlish_fn_24+0x2e4>
			2a80: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a84:	test   rax,rax
    2a87:	je     2b50 <botlish_fn_24+0x3b0>
    2a8d:	mov    QWORD PTR [rsp+0x8],0x9
    2a96:	mov    rsi,r12
    2a99:	mov    rdi,rbx
    2a9c:	call   2aa1 <botlish_fn_24+0x301>
			2a9d: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_tombstones<mutarray>
    2aa1:	test   rax,rax
    2aa4:	je     2b50 <botlish_fn_24+0x3b0>
    2aaa:	mov    QWORD PTR [rsp+0x10],rax
    2aaf:	mov    QWORD PTR [rsp+0x18],0x3
    2ab8:	mov    ecx,0x1
    2abd:	test   rax,0x1
    2ac3:	jne    2ae2 <botlish_fn_24+0x342>
    2ac9:	xor    ecx,ecx
    2acb:	test   rax,0x7
    2ad1:	jne    2ae2 <botlish_fn_24+0x342>
    2ad7:	movzx  rsi,BYTE PTR [rax]
    2adb:	cmp    sil,0x1
    2adf:	sete   cl
    2ae2:	test   cl,cl
    2ae4:	jne    2b05 <botlish_fn_24+0x365>
    2aea:	mov    rdi,rbx
    2aed:	mov    r8,QWORD PTR [rdi+0x10]
    2af1:	mov    rcx,QWORD PTR [r8+0x10]
    2af5:	xor    rdx,rdx
    2af8:	mov    rsi,rax
    2afb:	call   2b00 <botlish_fn_24+0x360>
			2afc: R_X86_64_PLT32	rt_type_error-0x4
    2b00:	jmp    2b50 <botlish_fn_24+0x3b0>
    2b05:	mov    rsi,rax
    2b08:	test   rsi,0x1
    2b0f:	je     2b27 <botlish_fn_24+0x387>
    2b15:	mov    rcx,rsi
    2b18:	add    rcx,0x2
    2b1c:	seto   al
    2b1f:	test   al,al
    2b21:	je     2b37 <botlish_fn_24+0x397>
    2b27:	mov    edx,0x3
    2b2c:	mov    rdi,rbx
    2b2f:	call   2b34 <botlish_fn_24+0x394>
			2b30: R_X86_64_PLT32	rt_int_add-0x4
    2b34:	mov    rcx,rax
    2b37:	mov    edx,0x9
    2b3c:	mov    rsi,r12
    2b3f:	mov    rdi,rbx
    2b42:	call   2b47 <botlish_fn_24+0x3a7>
			2b43: R_X86_64_PLT32	rt_mutarray_set-0x4
    2b47:	test   rax,rax
    2b4a:	jne    2b6b <botlish_fn_24+0x3cb>
    2b50:	xor    rax,rax
    2b53:	mov    rbx,QWORD PTR [rsp+0x20]
    2b58:	mov    r12,QWORD PTR [rsp+0x28]
    2b5d:	mov    r13,QWORD PTR [rsp+0x30]
    2b62:	add    rsp,0x40
    2b66:	mov    rsp,rbp
    2b69:	pop    rbp
    2b6a:	ret
    2b6b:	mov    eax,0xa
    2b70:	mov    rbx,QWORD PTR [rsp+0x20]
    2b75:	mov    r12,QWORD PTR [rsp+0x28]
    2b7a:	mov    r13,QWORD PTR [rsp+0x30]
    2b7f:	add    rsp,0x40
    2b83:	mov    rsp,rbp
    2b86:	pop    rbp
    2b87:	ret
    2b88:	mov    eax,0xa
    2b8d:	mov    rbx,QWORD PTR [rsp+0x20]
    2b92:	mov    r12,QWORD PTR [rsp+0x28]
    2b97:	mov    r13,QWORD PTR [rsp+0x30]
    2b9c:	add    rsp,0x40
    2ba0:	mov    rsp,rbp
    2ba3:	pop    rbp
    2ba4:	ret
    2ba5:	add    BYTE PTR [rax],al
    2ba7:	add    BYTE PTR [rsi],al
    2ba9:	add    BYTE PTR [rax],al
    2bab:	add    BYTE PTR [rax],al
    2bad:	add    BYTE PTR [rax],al
	...

0000000000002bb0 <botlish_entry_24: ht_delete<mutarray, str>>:
    2bb0:	push   rbp
    2bb1:	mov    rbp,rsp
    2bb4:	mov    rsi,QWORD PTR [rdx]
    2bb7:	mov    rdx,QWORD PTR [rdx+0x8]
    2bbb:	call   2bc0 <botlish_entry_24+0x10>
			2bbc: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2bc0:	mov    rsp,rbp
    2bc3:	pop    rbp
    2bc4:	ret
    2bc5:	add    BYTE PTR [rax],al
	...

0000000000002bc8 <botlish_fn_25: sample<generic>>:
    2bc8:	push   rbp
    2bc9:	mov    rbp,rsp
    2bcc:	sub    rsp,0xa0
    2bd3:	mov    QWORD PTR [rsp+0x70],rbx
    2bd8:	mov    QWORD PTR [rsp+0x78],r12
    2bdd:	mov    QWORD PTR [rsp+0x80],r13
    2be5:	mov    QWORD PTR [rsp+0x88],r14
    2bed:	mov    QWORD PTR [rsp+0x90],r15
    2bf5:	mov    r14,rdi
    2bf8:	mov    QWORD PTR [rsp],0x0
    2c00:	mov    QWORD PTR [rsp+0x8],0x0
    2c09:	mov    QWORD PTR [rsp+0x10],0x0
    2c12:	mov    QWORD PTR [rsp+0x18],0x0
    2c1b:	mov    QWORD PTR [rsp+0x20],0x0
    2c24:	mov    QWORD PTR [rsp+0x28],0x0
    2c2d:	mov    rdi,r14
    2c30:	call   2c35 <botlish_fn_25+0x6d>
			2c31: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    2c35:	mov    rcx,rax
    2c38:	mov    r15,rax
    2c3b:	test   rax,rcx
    2c3e:	je     2e7e <botlish_fn_25+0x2b6>
    2c44:	mov    rax,r15
    2c47:	mov    QWORD PTR [rsp],rax
    2c4b:	mov    rdi,r14
    2c4e:	mov    rax,QWORD PTR [rdi+0x10]
    2c52:	mov    rdx,QWORD PTR [rax+0x30]
    2c56:	mov    QWORD PTR [rsp+0x8],rdx
    2c5b:	mov    rax,QWORD PTR [rdi+0x10]
    2c5f:	mov    rcx,QWORD PTR [rax+0x38]
    2c63:	mov    QWORD PTR [rsp+0x10],rcx
    2c68:	mov    rsi,r15
    2c6b:	call   2c70 <botlish_fn_25+0xa8>
			2c6c: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c70:	test   rax,rax
    2c73:	je     2e7e <botlish_fn_25+0x2b6>
    2c79:	mov    rdi,r14
    2c7c:	mov    rsi,QWORD PTR [rdi+0x10]
    2c80:	mov    rdx,QWORD PTR [rsi+0x40]
    2c84:	mov    QWORD PTR [rsp+0x8],rdx
    2c89:	mov    rsi,QWORD PTR [rdi+0x10]
    2c8d:	mov    rcx,QWORD PTR [rsi+0x48]
    2c91:	mov    QWORD PTR [rsp+0x10],rcx
    2c96:	mov    rsi,r15
    2c99:	call   2c9e <botlish_fn_25+0xd6>
			2c9a: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2c9e:	test   rax,rax
    2ca1:	je     2e7e <botlish_fn_25+0x2b6>
    2ca7:	mov    rdi,r14
    2caa:	mov    r9,QWORD PTR [rdi+0x10]
    2cae:	mov    rdx,QWORD PTR [r9+0x30]
    2cb2:	mov    QWORD PTR [rsp+0x8],rdx
    2cb7:	mov    r10,QWORD PTR [rdi+0x10]
    2cbb:	mov    rcx,QWORD PTR [r10+0x50]
    2cbf:	mov    QWORD PTR [rsp+0x10],rcx
    2cc4:	mov    rsi,r15
    2cc7:	call   2ccc <botlish_fn_25+0x104>
			2cc8: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_set<mutarray, str, str>
    2ccc:	test   rax,rax
    2ccf:	je     2e7e <botlish_fn_25+0x2b6>
    2cd5:	mov    rdi,r14
    2cd8:	mov    rax,QWORD PTR [rdi+0x10]
    2cdc:	mov    rdx,QWORD PTR [rax+0x40]
    2ce0:	mov    QWORD PTR [rsp+0x8],rdx
    2ce5:	mov    rsi,r15
    2ce8:	call   2ced <botlish_fn_25+0x125>
			2ce9: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2ced:	mov    rbx,rax
    2cf0:	test   rbx,rbx
    2cf3:	je     2e7e <botlish_fn_25+0x2b6>
    2cf9:	mov    QWORD PTR [rsp+0x8],rbx
    2cfe:	mov    rdi,r14
    2d01:	mov    rax,QWORD PTR [rdi+0x10]
    2d05:	mov    rdx,QWORD PTR [rax+0x40]
    2d09:	mov    QWORD PTR [rsp+0x10],rdx
    2d0e:	mov    rsi,r15
    2d11:	call   2d16 <botlish_fn_25+0x14e>
			2d12: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_delete<mutarray, str>
    2d16:	test   rax,rax
    2d19:	je     2e7e <botlish_fn_25+0x2b6>
    2d1f:	mov    rdi,r14
    2d22:	mov    rax,QWORD PTR [rdi+0x10]
    2d26:	mov    rdx,QWORD PTR [rax+0x30]
    2d2a:	mov    QWORD PTR [rsp+0x10],rdx
    2d2f:	mov    rsi,r15
    2d32:	call   2d37 <botlish_fn_25+0x16f>
			2d33: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2d37:	test   rax,rax
    2d3a:	je     2e7e <botlish_fn_25+0x2b6>
    2d40:	mov    rdi,r14
    2d43:	mov    rcx,QWORD PTR [rdi+0x10]
    2d47:	mov    rdx,QWORD PTR [rcx+0x50]
    2d4b:	mov    rcx,rax
    2d4e:	and    rcx,rdx
    2d51:	mov    rsi,rax
    2d54:	test   rcx,0x1
    2d5b:	jne    2d77 <botlish_fn_25+0x1af>
    2d61:	mov    rdi,r14
    2d64:	call   2d69 <botlish_fn_25+0x1a1>
			2d65: R_X86_64_PLT32	rt_value_eq-0x4
    2d69:	test   rax,rax
    2d6c:	je     2e7e <botlish_fn_25+0x2b6>
    2d72:	jmp    2d87 <botlish_fn_25+0x1bf>
    2d77:	mov    eax,0x2
    2d7c:	cmp    rsi,rdx
    2d7f:	cmove  rax,QWORD PTR [rip+0x159]        # 2ee0 <botlish_fn_25+0x318>
    2d87:	mov    QWORD PTR [rsp+0x10],rax
    2d8c:	mov    rdi,r14
    2d8f:	mov    QWORD PTR [rsp+0x60],rax
    2d94:	mov    rax,QWORD PTR [rdi+0x10]
    2d98:	mov    rdx,QWORD PTR [rax+0x40]
    2d9c:	mov    QWORD PTR [rsp+0x18],rdx
    2da1:	mov    rsi,r15
    2da4:	call   2da9 <botlish_fn_25+0x1e1>
			2da5: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2da9:	mov    r12,rax
    2dac:	test   r12,r12
    2daf:	je     2e7e <botlish_fn_25+0x2b6>
    2db5:	mov    QWORD PTR [rsp+0x18],r12
    2dba:	mov    rdi,r14
    2dbd:	mov    rax,QWORD PTR [rdi+0x10]
    2dc1:	mov    rdx,QWORD PTR [rax+0x58]
    2dc5:	mov    QWORD PTR [rsp+0x20],rdx
    2dca:	mov    rsi,r15
    2dcd:	call   2dd2 <botlish_fn_25+0x20a>
			2dce: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_contains<mutarray, str>
    2dd2:	mov    r13,rax
    2dd5:	test   r13,r13
    2dd8:	je     2e7e <botlish_fn_25+0x2b6>
    2dde:	mov    QWORD PTR [rsp+0x20],r13
    2de3:	mov    rdi,r14
    2de6:	mov    rax,QWORD PTR [rdi+0x10]
    2dea:	mov    rdx,QWORD PTR [rax+0x58]
    2dee:	mov    QWORD PTR [rsp+0x28],rdx
    2df3:	mov    rsi,r15
    2df6:	call   2dfb <botlish_fn_25+0x233>
			2df7: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_get<mutarray, str>
    2dfb:	test   rax,rax
    2dfe:	mov    rsi,rax
    2e01:	je     2e7e <botlish_fn_25+0x2b6>
    2e07:	mov    edx,0xa
    2e0c:	mov    rdi,r14
    2e0f:	call   2e14 <botlish_fn_25+0x24c>
			2e10: R_X86_64_PLT32	rt_value_eq-0x4
    2e14:	test   rax,rax
    2e17:	je     2e7e <botlish_fn_25+0x2b6>
    2e1d:	mov    QWORD PTR [rsp],rax
    2e21:	mov    rsi,r15
    2e24:	mov    r15,rax
    2e27:	mov    rdi,r14
    2e2a:	call   2e2f <botlish_fn_25+0x267>
			2e2b: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_size<mutarray>
    2e2f:	test   rax,rax
    2e32:	je     2e7e <botlish_fn_25+0x2b6>
    2e38:	mov    QWORD PTR [rsp+0x28],rax
    2e3d:	lea    rdx,[rsp+0x30]
    2e42:	mov    rsi,QWORD PTR [rsp+0x60]
    2e47:	mov    QWORD PTR [rsp+0x30],rsi
    2e4c:	mov    QWORD PTR [rsp+0x38],rbx
    2e51:	mov    QWORD PTR [rsp+0x40],r12
    2e56:	mov    QWORD PTR [rsp+0x48],r13
    2e5b:	mov    r8,r15
    2e5e:	mov    QWORD PTR [rsp+0x50],r8
    2e63:	mov    QWORD PTR [rsp+0x58],rax
    2e68:	mov    esi,0x6
    2e6d:	mov    rdi,r14
    2e70:	call   2e75 <botlish_fn_25+0x2ad>
			2e71: R_X86_64_PLT32	rt_list_new-0x4
    2e75:	test   rax,rax
    2e78:	jne    2eaf <botlish_fn_25+0x2e7>
    2e7e:	xor    rax,rax
    2e81:	mov    rbx,QWORD PTR [rsp+0x70]
    2e86:	mov    r12,QWORD PTR [rsp+0x78]
    2e8b:	mov    r13,QWORD PTR [rsp+0x80]
    2e93:	mov    r14,QWORD PTR [rsp+0x88]
    2e9b:	mov    r15,QWORD PTR [rsp+0x90]
    2ea3:	add    rsp,0xa0
    2eaa:	mov    rsp,rbp
    2ead:	pop    rbp
    2eae:	ret
    2eaf:	mov    rbx,QWORD PTR [rsp+0x70]
    2eb4:	mov    r12,QWORD PTR [rsp+0x78]
    2eb9:	mov    r13,QWORD PTR [rsp+0x80]
    2ec1:	mov    r14,QWORD PTR [rsp+0x88]
    2ec9:	mov    r15,QWORD PTR [rsp+0x90]
    2ed1:	add    rsp,0xa0
    2ed8:	mov    rsp,rbp
    2edb:	pop    rbp
    2edc:	ret
    2edd:	add    BYTE PTR [rax],al
    2edf:	add    BYTE PTR [rsi],al
    2ee1:	add    BYTE PTR [rax],al
    2ee3:	add    BYTE PTR [rax],al
    2ee5:	add    BYTE PTR [rax],al
	...

0000000000002ee8 <botlish_entry_25: sample<generic>>:
    2ee8:	push   rbp
    2ee9:	mov    rbp,rsp
    2eec:	call   2ef1 <botlish_entry_25+0x9>
			2eed: R_X86_64_PLT32	botlish_fn_25-0x4 ; sample<generic>
    2ef1:	mov    rsp,rbp
    2ef4:	pop    rbp
    2ef5:	ret

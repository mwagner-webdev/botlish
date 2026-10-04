; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7884  (per function: 312 453 453 81 81 357 412 412 279 279 81 365 430 585 1141 352 783 215 488 325)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> mutable_array::create<int, str>
;   botlish_fn_2 / botlish_entry_2 -> mutable_array::create<int, List[str]>
;   botlish_fn_3 / botlish_entry_3 -> geo_new<str>
;   botlish_fn_4 / botlish_entry_4 -> geo_new<List[str]>
;   botlish_fn_5 / botlish_entry_5 -> geo_new_capacity<int, int>
;   botlish_fn_6 / botlish_entry_6 -> geo_grow<mutarray, int, str>
;   botlish_fn_7 / botlish_entry_7 -> geo_grow<mutarray, int, List[str]>
;   botlish_fn_8 / botlish_entry_8 -> geo_append<mutarray, int, str>
;   botlish_fn_9 / botlish_entry_9 -> geo_append<mutarray, int, List[str]>
;   botlish_fn_10 / botlish_entry_10 -> geo_finish<mutarray, int>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_unquoted<str, int, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_quoted<str, int, str>
;   botlish_fn_15 / botlish_entry_15 -> scan_field<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_record_rest<str, int, mutarray, int>
;   botlish_fn_17 / botlish_entry_17 -> scan_record<str, int>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, mutarray, int>
;   botlish_fn_19 / botlish_entry_19 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x20
       8:	mov    QWORD PTR [rsp+0x10],rbx
       d:	mov    rax,QWORD PTR [rdi+0x10]
      11:	mov    rbx,rdi
      14:	mov    rsi,QWORD PTR [rax]
      17:	mov    QWORD PTR [rsp],rsi
      1b:	call   20 <botlish_fn_0+0x20>
			1c: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
      20:	test   rax,rax
      23:	jne    dd <botlish_fn_0+0xdd>
      29:	mov    rdi,rbx
      2c:	call   31 <botlish_fn_0+0x31>
			2d: R_X86_64_PLT32	rt_declared_error-0x4
      31:	cmp    rax,0x40000001
      37:	je     ad <botlish_fn_0+0xad>
      3d:	mov    rdi,rbx
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	rt_declared_error-0x4
      45:	cmp    rax,0x40000002
      4b:	je     89 <botlish_fn_0+0x89>
      51:	mov    rdi,rbx
      54:	call   59 <botlish_fn_0+0x59>
			55: R_X86_64_PLT32	rt_declared_error-0x4
      59:	cmp    rax,0x40000003
      5f:	jne    cc <botlish_fn_0+0xcc>
      65:	mov    rdi,rbx
      68:	call   6d <botlish_fn_0+0x6d>
			69: R_X86_64_PLT32	rt_clear_declared_error-0x4
      6d:	xor    rdx,rdx
      70:	mov    rdi,rbx
      73:	mov    rsi,rdx
      76:	call   7b <botlish_fn_0+0x7b>
			77: R_X86_64_PLT32	rt_list_new-0x4
      7b:	test   rax,rax
      7e:	je     cc <botlish_fn_0+0xcc>
      84:	jmp    dd <botlish_fn_0+0xdd>
      89:	mov    rdi,rbx
      8c:	call   91 <botlish_fn_0+0x91>
			8d: R_X86_64_PLT32	rt_clear_declared_error-0x4
      91:	xor    rdx,rdx
      94:	mov    rdi,rbx
      97:	mov    rsi,rdx
      9a:	call   9f <botlish_fn_0+0x9f>
			9b: R_X86_64_PLT32	rt_list_new-0x4
      9f:	test   rax,rax
      a2:	je     cc <botlish_fn_0+0xcc>
      a8:	jmp    dd <botlish_fn_0+0xdd>
      ad:	mov    rdi,rbx
      b0:	call   b5 <botlish_fn_0+0xb5>
			b1: R_X86_64_PLT32	rt_clear_declared_error-0x4
      b5:	xor    rdx,rdx
      b8:	mov    rdi,rbx
      bb:	mov    rsi,rdx
      be:	call   c3 <botlish_fn_0+0xc3>
			bf: R_X86_64_PLT32	rt_list_new-0x4
      c3:	test   rax,rax
      c6:	jne    dd <botlish_fn_0+0xdd>
      cc:	xor    rax,rax
      cf:	mov    rbx,QWORD PTR [rsp+0x10]
      d4:	add    rsp,0x20
      d8:	mov    rsp,rbp
      db:	pop    rbp
      dc:	ret
      dd:	mov    rbx,QWORD PTR [rsp+0x10]
      e2:	add    rsp,0x20
      e6:	mov    rsp,rbp
      e9:	pop    rbp
      ea:	ret

00000000000000eb <botlish_entry_0: <program entry>>:
      eb:	push   rbp
      ec:	mov    rbp,rsp
      ef:	call   f4 <botlish_entry_0+0x9>
			f0: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      f4:	mov    rsp,rbp
      f7:	pop    rbp
      f8:	ret
      f9:	add    BYTE PTR [rax],al
      fb:	add    BYTE PTR [rax],al
      fd:	add    BYTE PTR [rax],al
	...

0000000000000100 <botlish_fn_1: mutable_array::create<int, str>>:
     100:	push   rbp
     101:	mov    rbp,rsp
     104:	sub    rsp,0x60
     108:	mov    QWORD PTR [rsp+0x30],rbx
     10d:	mov    QWORD PTR [rsp+0x38],r12
     112:	mov    QWORD PTR [rsp+0x40],r13
     117:	mov    QWORD PTR [rsp+0x48],r14
     11c:	mov    QWORD PTR [rsp+0x50],r15
     121:	mov    r13,rdi
     124:	mov    QWORD PTR [rsp+0x10],0x0
     12d:	mov    QWORD PTR [rsp+0x18],0x0
     136:	mov    QWORD PTR [rsp+0x20],0x0
     13f:	mov    QWORD PTR [rsp],rsi
     143:	mov    QWORD PTR [rsp+0x8],rdx
     148:	mov    r12,rdx
     14b:	mov    rbx,rsi
     14e:	mov    rdi,r13
     151:	call   156 <botlish_fn_1+0x56>
			152: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     156:	test   rax,rax
     159:	jne    184 <botlish_fn_1+0x84>
     15f:	xor    rax,rax
     162:	mov    rbx,QWORD PTR [rsp+0x30]
     167:	mov    r12,QWORD PTR [rsp+0x38]
     16c:	mov    r13,QWORD PTR [rsp+0x40]
     171:	mov    r14,QWORD PTR [rsp+0x48]
     176:	mov    r15,QWORD PTR [rsp+0x50]
     17b:	add    rsp,0x60
     17f:	mov    rsp,rbp
     182:	pop    rbp
     183:	ret
     184:	mov    QWORD PTR [rsp+0x10],rax
     189:	mov    r15,rax
     18c:	mov    esi,0x1
     191:	mov    r14,rsi
     194:	mov    QWORD PTR [rsp+0x18],0x1
     19d:	mov    rax,rsi
     1a0:	and    rax,rbx
     1a3:	mov    r14,rsi
     1a6:	test   rax,0x1
     1ac:	jne    1d5 <botlish_fn_1+0xd5>
     1b2:	mov    rdx,rbx
     1b5:	mov    rsi,r14
     1b8:	mov    rdi,r13
     1bb:	call   1c0 <botlish_fn_1+0xc0>
			1bc: R_X86_64_PLT32	rt_int_cmp-0x4
     1c0:	mov    ecx,0x2
     1c5:	test   rax,rax
     1c8:	cmovl  rcx,QWORD PTR [rip+0xb8]        # 288 <botlish_fn_1+0x188>
     1d0:	jmp    1e8 <botlish_fn_1+0xe8>
     1d5:	mov    ecx,0x2
     1da:	mov    rsi,r14
     1dd:	cmp    rsi,rbx
     1e0:	cmovl  rcx,QWORD PTR [rip+0xa0]        # 288 <botlish_fn_1+0x188>
     1e8:	cmp    rcx,0x6
     1ec:	je     217 <botlish_fn_1+0x117>
     1f2:	mov    rax,r15
     1f5:	mov    rbx,QWORD PTR [rsp+0x30]
     1fa:	mov    r12,QWORD PTR [rsp+0x38]
     1ff:	mov    r13,QWORD PTR [rsp+0x40]
     204:	mov    r14,QWORD PTR [rsp+0x48]
     209:	mov    r15,QWORD PTR [rsp+0x50]
     20e:	add    rsp,0x60
     212:	mov    rsp,rbp
     215:	pop    rbp
     216:	ret
     217:	mov    rcx,r12
     21a:	mov    rdx,r14
     21d:	mov    rsi,r15
     220:	mov    rdi,r13
     223:	call   228 <botlish_fn_1+0x128>
			224: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     228:	mov    QWORD PTR [rsp+0x20],0x3
     231:	mov    rsi,r14
     234:	test   rsi,0x1
     23b:	je     261 <botlish_fn_1+0x161>
     241:	mov    rsi,r14
     244:	mov    rcx,rsi
     247:	add    rcx,0x2
     24b:	seto   al
     24e:	test   al,al
     250:	jne    261 <botlish_fn_1+0x161>
     256:	mov    rsi,rcx
     259:	mov    r14,rcx
     25c:	jmp    277 <botlish_fn_1+0x177>
     261:	mov    edx,0x3
     266:	mov    rsi,r14
     269:	mov    rdi,r13
     26c:	call   271 <botlish_fn_1+0x171>
			26d: R_X86_64_PLT32	rt_int_add-0x4
     271:	mov    rsi,rax
     274:	mov    r14,rax
     277:	mov    QWORD PTR [rsp+0x18],rsi
     27c:	mov    rsi,r14
     27f:	jmp    19d <botlish_fn_1+0x9d>
     284:	add    BYTE PTR [rax],al
     286:	add    BYTE PTR [rax],al
     288:	(bad)
     289:	add    BYTE PTR [rax],al
     28b:	add    BYTE PTR [rax],al
     28d:	add    BYTE PTR [rax],al
	...

0000000000000290 <botlish_entry_1: mutable_array::create<int, str>>:
     290:	push   rbp
     291:	mov    rbp,rsp
     294:	mov    rsi,QWORD PTR [rdx]
     297:	mov    rdx,QWORD PTR [rdx+0x8]
     29b:	call   2a0 <botlish_entry_1+0x10>
			29c: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     2a0:	mov    rsp,rbp
     2a3:	pop    rbp
     2a4:	ret
     2a5:	add    BYTE PTR [rax],al
	...

00000000000002a8 <botlish_fn_2: mutable_array::create<int, List[str]>>:
     2a8:	push   rbp
     2a9:	mov    rbp,rsp
     2ac:	sub    rsp,0x60
     2b0:	mov    QWORD PTR [rsp+0x30],rbx
     2b5:	mov    QWORD PTR [rsp+0x38],r12
     2ba:	mov    QWORD PTR [rsp+0x40],r13
     2bf:	mov    QWORD PTR [rsp+0x48],r14
     2c4:	mov    QWORD PTR [rsp+0x50],r15
     2c9:	mov    r13,rdi
     2cc:	mov    QWORD PTR [rsp+0x10],0x0
     2d5:	mov    QWORD PTR [rsp+0x18],0x0
     2de:	mov    QWORD PTR [rsp+0x20],0x0
     2e7:	mov    QWORD PTR [rsp],rsi
     2eb:	mov    QWORD PTR [rsp+0x8],rdx
     2f0:	mov    r12,rdx
     2f3:	mov    rbx,rsi
     2f6:	mov    rdi,r13
     2f9:	call   2fe <botlish_fn_2+0x56>
			2fa: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2fe:	test   rax,rax
     301:	jne    32c <botlish_fn_2+0x84>
     307:	xor    rax,rax
     30a:	mov    rbx,QWORD PTR [rsp+0x30]
     30f:	mov    r12,QWORD PTR [rsp+0x38]
     314:	mov    r13,QWORD PTR [rsp+0x40]
     319:	mov    r14,QWORD PTR [rsp+0x48]
     31e:	mov    r15,QWORD PTR [rsp+0x50]
     323:	add    rsp,0x60
     327:	mov    rsp,rbp
     32a:	pop    rbp
     32b:	ret
     32c:	mov    QWORD PTR [rsp+0x10],rax
     331:	mov    r15,rax
     334:	mov    esi,0x1
     339:	mov    r14,rsi
     33c:	mov    QWORD PTR [rsp+0x18],0x1
     345:	mov    rax,rsi
     348:	and    rax,rbx
     34b:	mov    r14,rsi
     34e:	test   rax,0x1
     354:	jne    37d <botlish_fn_2+0xd5>
     35a:	mov    rdx,rbx
     35d:	mov    rsi,r14
     360:	mov    rdi,r13
     363:	call   368 <botlish_fn_2+0xc0>
			364: R_X86_64_PLT32	rt_int_cmp-0x4
     368:	mov    ecx,0x2
     36d:	test   rax,rax
     370:	cmovl  rcx,QWORD PTR [rip+0xb8]        # 430 <botlish_fn_2+0x188>
     378:	jmp    390 <botlish_fn_2+0xe8>
     37d:	mov    ecx,0x2
     382:	mov    rsi,r14
     385:	cmp    rsi,rbx
     388:	cmovl  rcx,QWORD PTR [rip+0xa0]        # 430 <botlish_fn_2+0x188>
     390:	cmp    rcx,0x6
     394:	je     3bf <botlish_fn_2+0x117>
     39a:	mov    rax,r15
     39d:	mov    rbx,QWORD PTR [rsp+0x30]
     3a2:	mov    r12,QWORD PTR [rsp+0x38]
     3a7:	mov    r13,QWORD PTR [rsp+0x40]
     3ac:	mov    r14,QWORD PTR [rsp+0x48]
     3b1:	mov    r15,QWORD PTR [rsp+0x50]
     3b6:	add    rsp,0x60
     3ba:	mov    rsp,rbp
     3bd:	pop    rbp
     3be:	ret
     3bf:	mov    rcx,r12
     3c2:	mov    rdx,r14
     3c5:	mov    rsi,r15
     3c8:	mov    rdi,r13
     3cb:	call   3d0 <botlish_fn_2+0x128>
			3cc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     3d0:	mov    QWORD PTR [rsp+0x20],0x3
     3d9:	mov    rsi,r14
     3dc:	test   rsi,0x1
     3e3:	je     409 <botlish_fn_2+0x161>
     3e9:	mov    rsi,r14
     3ec:	mov    rcx,rsi
     3ef:	add    rcx,0x2
     3f3:	seto   al
     3f6:	test   al,al
     3f8:	jne    409 <botlish_fn_2+0x161>
     3fe:	mov    rsi,rcx
     401:	mov    r14,rcx
     404:	jmp    41f <botlish_fn_2+0x177>
     409:	mov    edx,0x3
     40e:	mov    rsi,r14
     411:	mov    rdi,r13
     414:	call   419 <botlish_fn_2+0x171>
			415: R_X86_64_PLT32	rt_int_add-0x4
     419:	mov    rsi,rax
     41c:	mov    r14,rax
     41f:	mov    QWORD PTR [rsp+0x18],rsi
     424:	mov    rsi,r14
     427:	jmp    345 <botlish_fn_2+0x9d>
     42c:	add    BYTE PTR [rax],al
     42e:	add    BYTE PTR [rax],al
     430:	(bad)
     431:	add    BYTE PTR [rax],al
     433:	add    BYTE PTR [rax],al
     435:	add    BYTE PTR [rax],al
	...

0000000000000438 <botlish_entry_2: mutable_array::create<int, List[str]>>:
     438:	push   rbp
     439:	mov    rbp,rsp
     43c:	mov    rsi,QWORD PTR [rdx]
     43f:	mov    rdx,QWORD PTR [rdx+0x8]
     443:	call   448 <botlish_entry_2+0x10>
			444: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     448:	mov    rsp,rbp
     44b:	pop    rbp
     44c:	ret

000000000000044d <botlish_fn_3: geo_new<str>>:
     44d:	push   rbp
     44e:	mov    rbp,rsp
     451:	sub    rsp,0x10
     455:	mov    QWORD PTR [rsp],rsi
     459:	mov    rdx,rsi
     45c:	mov    esi,0x3
     461:	mov    QWORD PTR [rsp+0x8],0x3
     46a:	call   46f <botlish_fn_3+0x22>
			46b: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     46f:	test   rax,rax
     472:	jne    484 <botlish_fn_3+0x37>
     478:	xor    rax,rax
     47b:	add    rsp,0x10
     47f:	mov    rsp,rbp
     482:	pop    rbp
     483:	ret
     484:	add    rsp,0x10
     488:	mov    rsp,rbp
     48b:	pop    rbp
     48c:	ret

000000000000048d <botlish_entry_3: geo_new<str>>:
     48d:	push   rbp
     48e:	mov    rbp,rsp
     491:	mov    rsi,QWORD PTR [rdx]
     494:	call   499 <botlish_entry_3+0xc>
			495: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
     499:	mov    rsp,rbp
     49c:	pop    rbp
     49d:	ret

000000000000049e <botlish_fn_4: geo_new<List[str]>>:
     49e:	push   rbp
     49f:	mov    rbp,rsp
     4a2:	sub    rsp,0x10
     4a6:	mov    QWORD PTR [rsp],rsi
     4aa:	mov    rdx,rsi
     4ad:	mov    esi,0x3
     4b2:	mov    QWORD PTR [rsp+0x8],0x3
     4bb:	call   4c0 <botlish_fn_4+0x22>
			4bc: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     4c0:	test   rax,rax
     4c3:	jne    4d5 <botlish_fn_4+0x37>
     4c9:	xor    rax,rax
     4cc:	add    rsp,0x10
     4d0:	mov    rsp,rbp
     4d3:	pop    rbp
     4d4:	ret
     4d5:	add    rsp,0x10
     4d9:	mov    rsp,rbp
     4dc:	pop    rbp
     4dd:	ret

00000000000004de <botlish_entry_4: geo_new<List[str]>>:
     4de:	push   rbp
     4df:	mov    rbp,rsp
     4e2:	mov    rsi,QWORD PTR [rdx]
     4e5:	call   4ea <botlish_entry_4+0xc>
			4e6: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
     4ea:	mov    rsp,rbp
     4ed:	pop    rbp
     4ee:	ret
	...

00000000000004f0 <botlish_fn_5: geo_new_capacity<int, int>>:
     4f0:	push   rbp
     4f1:	mov    rbp,rsp
     4f4:	sub    rsp,0x40
     4f8:	mov    QWORD PTR [rsp+0x20],rbx
     4fd:	mov    QWORD PTR [rsp+0x28],r12
     502:	mov    QWORD PTR [rsp+0x30],r13
     507:	mov    r12,rdi
     50a:	mov    QWORD PTR [rsp],rsi
     50e:	mov    QWORD PTR [rsp+0x8],rdx
     513:	mov    rbx,rdx
     516:	mov    QWORD PTR [rsp+0x10],0x5
     51f:	test   rsi,0x1
     526:	je     548 <botlish_fn_5+0x58>
     52c:	mov    rax,rsi
     52f:	sar    rax,1
     532:	imul   QWORD PTR [rip+0xdf]        # 618 <botlish_fn_5+0x128>
     539:	seto   cl
     53c:	or     rax,0x1
     540:	test   cl,cl
     542:	je     555 <botlish_fn_5+0x65>
     548:	mov    edx,0x5
     54d:	mov    rdi,r12
     550:	call   555 <botlish_fn_5+0x65>
			551: R_X86_64_PLT32	rt_int_mul-0x4
     555:	mov    rcx,rax
     558:	and    rcx,rbx
     55b:	mov    r13,rax
     55e:	test   rcx,0x1
     565:	jne    591 <botlish_fn_5+0xa1>
     56b:	mov    rdx,rbx
     56e:	mov    rsi,r13
     571:	mov    rdi,r12
     574:	call   579 <botlish_fn_5+0x89>
			575: R_X86_64_PLT32	rt_int_cmp-0x4
     579:	mov    ecx,0x2
     57e:	test   rax,rax
     581:	cmovle rcx,QWORD PTR [rip+0x97]        # 620 <botlish_fn_5+0x130>
     589:	mov    rax,r13
     58c:	jmp    5a4 <botlish_fn_5+0xb4>
     591:	mov    ecx,0x2
     596:	mov    rax,r13
     599:	cmp    rax,rbx
     59c:	cmovle rcx,QWORD PTR [rip+0x7c]        # 620 <botlish_fn_5+0x130>
     5a4:	cmp    rcx,0x6
     5a8:	je     5c6 <botlish_fn_5+0xd6>
     5ae:	mov    rbx,QWORD PTR [rsp+0x20]
     5b3:	mov    r12,QWORD PTR [rsp+0x28]
     5b8:	mov    r13,QWORD PTR [rsp+0x30]
     5bd:	add    rsp,0x40
     5c1:	mov    rsp,rbp
     5c4:	pop    rbp
     5c5:	ret
     5c6:	mov    QWORD PTR [rsp],0x3
     5ce:	test   rbx,0x1
     5d5:	je     5ed <botlish_fn_5+0xfd>
     5db:	mov    rax,rbx
     5de:	add    rax,0x2
     5e2:	seto   cl
     5e5:	test   cl,cl
     5e7:	je     5fd <botlish_fn_5+0x10d>
     5ed:	mov    edx,0x3
     5f2:	mov    rsi,rbx
     5f5:	mov    rdi,r12
     5f8:	call   5fd <botlish_fn_5+0x10d>
			5f9: R_X86_64_PLT32	rt_int_add-0x4
     5fd:	mov    rbx,QWORD PTR [rsp+0x20]
     602:	mov    r12,QWORD PTR [rsp+0x28]
     607:	mov    r13,QWORD PTR [rsp+0x30]
     60c:	add    rsp,0x40
     610:	mov    rsp,rbp
     613:	pop    rbp
     614:	ret
     615:	add    BYTE PTR [rax],al
     617:	add    BYTE PTR [rax+rax*1],al
     61a:	add    BYTE PTR [rax],al
     61c:	add    BYTE PTR [rax],al
     61e:	add    BYTE PTR [rax],al
     620:	(bad)
     621:	add    BYTE PTR [rax],al
     623:	add    BYTE PTR [rax],al
     625:	add    BYTE PTR [rax],al
	...

0000000000000628 <botlish_entry_5: geo_new_capacity<int, int>>:
     628:	push   rbp
     629:	mov    rbp,rsp
     62c:	mov    rsi,QWORD PTR [rdx]
     62f:	mov    rdx,QWORD PTR [rdx+0x8]
     633:	call   638 <botlish_entry_5+0x10>
			634: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     638:	mov    rsp,rbp
     63b:	pop    rbp
     63c:	ret
     63d:	add    BYTE PTR [rax],al
	...

0000000000000640 <botlish_fn_6: geo_grow<mutarray, int, str>>:
     640:	push   rbp
     641:	mov    rbp,rsp
     644:	sub    rsp,0x50
     648:	mov    QWORD PTR [rsp+0x20],rbx
     64d:	mov    QWORD PTR [rsp+0x28],r12
     652:	mov    QWORD PTR [rsp+0x30],r13
     657:	mov    QWORD PTR [rsp+0x38],r14
     65c:	mov    QWORD PTR [rsp+0x40],r15
     661:	mov    r13,rdi
     664:	mov    QWORD PTR [rsp],rsi
     668:	mov    r12,rsi
     66b:	mov    QWORD PTR [rsp+0x8],rdx
     670:	mov    rbx,rdx
     673:	mov    QWORD PTR [rsp+0x10],rcx
     678:	mov    r14,rcx
     67b:	mov    rsi,r12
     67e:	mov    rdi,r13
     681:	call   686 <botlish_fn_6+0x46>
			682: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     686:	mov    r15,rax
     689:	mov    QWORD PTR [rsp+0x18],rax
     68e:	mov    rcx,rbx
     691:	and    rcx,rax
     694:	test   rcx,0x1
     69b:	jne    6c7 <botlish_fn_6+0x87>
     6a1:	mov    rdx,r15
     6a4:	mov    rsi,rbx
     6a7:	mov    rdi,r13
     6aa:	call   6af <botlish_fn_6+0x6f>
			6ab: R_X86_64_PLT32	rt_int_cmp-0x4
     6af:	mov    ecx,0x2
     6b4:	test   rax,rax
     6b7:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 7a8 <botlish_fn_6+0x168>
     6bf:	mov    rax,r15
     6c2:	jmp    6da <botlish_fn_6+0x9a>
     6c7:	mov    ecx,0x2
     6cc:	mov    rax,r15
     6cf:	cmp    rbx,rax
     6d2:	cmovl  rcx,QWORD PTR [rip+0xce]        # 7a8 <botlish_fn_6+0x168>
     6da:	cmp    rcx,0x6
     6de:	je     77e <botlish_fn_6+0x13e>
     6e4:	mov    rsi,rax
     6e7:	mov    rdx,rbx
     6ea:	mov    rdi,r13
     6ed:	call   6f2 <botlish_fn_6+0xb2>
			6ee: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     6f2:	mov    QWORD PTR [rsp+0x18],rax
     6f7:	mov    rdx,r14
     6fa:	mov    rsi,rax
     6fd:	mov    rdi,r13
     700:	call   705 <botlish_fn_6+0xc5>
			701: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     705:	test   rax,rax
     708:	mov    r14,rax
     70b:	je     734 <botlish_fn_6+0xf4>
     711:	mov    r8d,0x1
     717:	mov    rcx,r12
     71a:	mov    rdi,r13
     71d:	mov    r9,rbx
     720:	mov    rsi,r14
     723:	mov    rdx,r8
     726:	call   72b <botlish_fn_6+0xeb>
			727: R_X86_64_PLT32	rt_mutarray_copy-0x4
     72b:	test   rax,rax
     72e:	jne    759 <botlish_fn_6+0x119>
     734:	xor    rax,rax
     737:	mov    rbx,QWORD PTR [rsp+0x20]
     73c:	mov    r12,QWORD PTR [rsp+0x28]
     741:	mov    r13,QWORD PTR [rsp+0x30]
     746:	mov    r14,QWORD PTR [rsp+0x38]
     74b:	mov    r15,QWORD PTR [rsp+0x40]
     750:	add    rsp,0x50
     754:	mov    rsp,rbp
     757:	pop    rbp
     758:	ret
     759:	mov    rax,r14
     75c:	mov    rbx,QWORD PTR [rsp+0x20]
     761:	mov    r12,QWORD PTR [rsp+0x28]
     766:	mov    r13,QWORD PTR [rsp+0x30]
     76b:	mov    r14,QWORD PTR [rsp+0x38]
     770:	mov    r15,QWORD PTR [rsp+0x40]
     775:	add    rsp,0x50
     779:	mov    rsp,rbp
     77c:	pop    rbp
     77d:	ret
     77e:	mov    rax,r12
     781:	mov    rbx,QWORD PTR [rsp+0x20]
     786:	mov    r12,QWORD PTR [rsp+0x28]
     78b:	mov    r13,QWORD PTR [rsp+0x30]
     790:	mov    r14,QWORD PTR [rsp+0x38]
     795:	mov    r15,QWORD PTR [rsp+0x40]
     79a:	add    rsp,0x50
     79e:	mov    rsp,rbp
     7a1:	pop    rbp
     7a2:	ret
     7a3:	add    BYTE PTR [rax],al
     7a5:	add    BYTE PTR [rax],al
     7a7:	add    BYTE PTR [rsi],al
     7a9:	add    BYTE PTR [rax],al
     7ab:	add    BYTE PTR [rax],al
     7ad:	add    BYTE PTR [rax],al
	...

00000000000007b0 <botlish_entry_6: geo_grow<mutarray, int, str>>:
     7b0:	push   rbp
     7b1:	mov    rbp,rsp
     7b4:	mov    rsi,QWORD PTR [rdx]
     7b7:	mov    r8,QWORD PTR [rdx+0x8]
     7bb:	mov    rcx,QWORD PTR [rdx+0x10]
     7bf:	mov    rdx,r8
     7c2:	call   7c7 <botlish_entry_6+0x17>
			7c3: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     7c7:	mov    rsp,rbp
     7ca:	pop    rbp
     7cb:	ret
     7cc:	add    BYTE PTR [rax],al
	...

00000000000007d0 <botlish_fn_7: geo_grow<mutarray, int, List[str]>>:
     7d0:	push   rbp
     7d1:	mov    rbp,rsp
     7d4:	sub    rsp,0x50
     7d8:	mov    QWORD PTR [rsp+0x20],rbx
     7dd:	mov    QWORD PTR [rsp+0x28],r12
     7e2:	mov    QWORD PTR [rsp+0x30],r13
     7e7:	mov    QWORD PTR [rsp+0x38],r14
     7ec:	mov    QWORD PTR [rsp+0x40],r15
     7f1:	mov    r13,rdi
     7f4:	mov    QWORD PTR [rsp],rsi
     7f8:	mov    r12,rsi
     7fb:	mov    QWORD PTR [rsp+0x8],rdx
     800:	mov    rbx,rdx
     803:	mov    QWORD PTR [rsp+0x10],rcx
     808:	mov    r14,rcx
     80b:	mov    rsi,r12
     80e:	mov    rdi,r13
     811:	call   816 <botlish_fn_7+0x46>
			812: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     816:	mov    r15,rax
     819:	mov    QWORD PTR [rsp+0x18],rax
     81e:	mov    rcx,rbx
     821:	and    rcx,rax
     824:	test   rcx,0x1
     82b:	jne    857 <botlish_fn_7+0x87>
     831:	mov    rdx,r15
     834:	mov    rsi,rbx
     837:	mov    rdi,r13
     83a:	call   83f <botlish_fn_7+0x6f>
			83b: R_X86_64_PLT32	rt_int_cmp-0x4
     83f:	mov    ecx,0x2
     844:	test   rax,rax
     847:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 938 <botlish_fn_7+0x168>
     84f:	mov    rax,r15
     852:	jmp    86a <botlish_fn_7+0x9a>
     857:	mov    ecx,0x2
     85c:	mov    rax,r15
     85f:	cmp    rbx,rax
     862:	cmovl  rcx,QWORD PTR [rip+0xce]        # 938 <botlish_fn_7+0x168>
     86a:	cmp    rcx,0x6
     86e:	je     90e <botlish_fn_7+0x13e>
     874:	mov    rsi,rax
     877:	mov    rdx,rbx
     87a:	mov    rdi,r13
     87d:	call   882 <botlish_fn_7+0xb2>
			87e: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     882:	mov    QWORD PTR [rsp+0x18],rax
     887:	mov    rdx,r14
     88a:	mov    rsi,rax
     88d:	mov    rdi,r13
     890:	call   895 <botlish_fn_7+0xc5>
			891: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     895:	test   rax,rax
     898:	mov    r14,rax
     89b:	je     8c4 <botlish_fn_7+0xf4>
     8a1:	mov    r8d,0x1
     8a7:	mov    rcx,r12
     8aa:	mov    rdi,r13
     8ad:	mov    r9,rbx
     8b0:	mov    rsi,r14
     8b3:	mov    rdx,r8
     8b6:	call   8bb <botlish_fn_7+0xeb>
			8b7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     8bb:	test   rax,rax
     8be:	jne    8e9 <botlish_fn_7+0x119>
     8c4:	xor    rax,rax
     8c7:	mov    rbx,QWORD PTR [rsp+0x20]
     8cc:	mov    r12,QWORD PTR [rsp+0x28]
     8d1:	mov    r13,QWORD PTR [rsp+0x30]
     8d6:	mov    r14,QWORD PTR [rsp+0x38]
     8db:	mov    r15,QWORD PTR [rsp+0x40]
     8e0:	add    rsp,0x50
     8e4:	mov    rsp,rbp
     8e7:	pop    rbp
     8e8:	ret
     8e9:	mov    rax,r14
     8ec:	mov    rbx,QWORD PTR [rsp+0x20]
     8f1:	mov    r12,QWORD PTR [rsp+0x28]
     8f6:	mov    r13,QWORD PTR [rsp+0x30]
     8fb:	mov    r14,QWORD PTR [rsp+0x38]
     900:	mov    r15,QWORD PTR [rsp+0x40]
     905:	add    rsp,0x50
     909:	mov    rsp,rbp
     90c:	pop    rbp
     90d:	ret
     90e:	mov    rax,r12
     911:	mov    rbx,QWORD PTR [rsp+0x20]
     916:	mov    r12,QWORD PTR [rsp+0x28]
     91b:	mov    r13,QWORD PTR [rsp+0x30]
     920:	mov    r14,QWORD PTR [rsp+0x38]
     925:	mov    r15,QWORD PTR [rsp+0x40]
     92a:	add    rsp,0x50
     92e:	mov    rsp,rbp
     931:	pop    rbp
     932:	ret
     933:	add    BYTE PTR [rax],al
     935:	add    BYTE PTR [rax],al
     937:	add    BYTE PTR [rsi],al
     939:	add    BYTE PTR [rax],al
     93b:	add    BYTE PTR [rax],al
     93d:	add    BYTE PTR [rax],al
	...

0000000000000940 <botlish_entry_7: geo_grow<mutarray, int, List[str]>>:
     940:	push   rbp
     941:	mov    rbp,rsp
     944:	mov    rsi,QWORD PTR [rdx]
     947:	mov    r8,QWORD PTR [rdx+0x8]
     94b:	mov    rcx,QWORD PTR [rdx+0x10]
     94f:	mov    rdx,r8
     952:	call   957 <botlish_entry_7+0x17>
			953: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     957:	mov    rsp,rbp
     95a:	pop    rbp
     95b:	ret

000000000000095c <botlish_fn_8: geo_append<mutarray, int, str>>:
     95c:	push   rbp
     95d:	mov    rbp,rsp
     960:	sub    rsp,0x40
     964:	mov    QWORD PTR [rsp+0x20],rbx
     969:	mov    QWORD PTR [rsp+0x28],r12
     96e:	mov    QWORD PTR [rsp+0x30],r13
     973:	mov    QWORD PTR [rsp+0x38],r14
     978:	mov    rbx,rdi
     97b:	mov    QWORD PTR [rsp],rsi
     97f:	mov    QWORD PTR [rsp+0x8],rdx
     984:	mov    r14,rdx
     987:	mov    QWORD PTR [rsp+0x10],rcx
     98c:	mov    r13,rcx
     98f:	mov    rcx,r13
     992:	mov    rdx,r14
     995:	mov    rdi,rbx
     998:	call   99d <botlish_fn_8+0x41>
			999: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     99d:	test   rax,rax
     9a0:	je     a09 <botlish_fn_8+0xad>
     9a6:	xor    ecx,ecx
     9a8:	test   rax,0x7
     9ae:	je     9bc <botlish_fn_8+0x60>
     9b4:	mov    r12,rax
     9b7:	jmp    9ca <botlish_fn_8+0x6e>
     9bc:	movzx  rcx,BYTE PTR [rax]
     9c0:	mov    r12,rax
     9c3:	rex cmp cl,0x8
     9c7:	sete   cl
     9ca:	test   cl,cl
     9cc:	jne    9ef <botlish_fn_8+0x93>
     9d2:	mov    rdi,rbx
     9d5:	mov    rax,QWORD PTR [rdi+0x10]
     9d9:	mov    rcx,QWORD PTR [rax+0x8]
     9dd:	mov    edx,0x8
     9e2:	mov    rsi,r12
     9e5:	call   9ea <botlish_fn_8+0x8e>
			9e6: R_X86_64_PLT32	rt_type_error-0x4
     9ea:	jmp    a09 <botlish_fn_8+0xad>
     9ef:	mov    rcx,r13
     9f2:	mov    rdx,r14
     9f5:	mov    rdi,rbx
     9f8:	mov    rsi,r12
     9fb:	call   a00 <botlish_fn_8+0xa4>
			9fc: R_X86_64_PLT32	rt_mutarray_set-0x4
     a00:	test   rax,rax
     a03:	jne    a29 <botlish_fn_8+0xcd>
     a09:	xor    rax,rax
     a0c:	mov    rbx,QWORD PTR [rsp+0x20]
     a11:	mov    r12,QWORD PTR [rsp+0x28]
     a16:	mov    r13,QWORD PTR [rsp+0x30]
     a1b:	mov    r14,QWORD PTR [rsp+0x38]
     a20:	add    rsp,0x40
     a24:	mov    rsp,rbp
     a27:	pop    rbp
     a28:	ret
     a29:	mov    rax,r12
     a2c:	mov    rbx,QWORD PTR [rsp+0x20]
     a31:	mov    r12,QWORD PTR [rsp+0x28]
     a36:	mov    r13,QWORD PTR [rsp+0x30]
     a3b:	mov    r14,QWORD PTR [rsp+0x38]
     a40:	add    rsp,0x40
     a44:	mov    rsp,rbp
     a47:	pop    rbp
     a48:	ret

0000000000000a49 <botlish_entry_8: geo_append<mutarray, int, str>>:
     a49:	push   rbp
     a4a:	mov    rbp,rsp
     a4d:	mov    rsi,QWORD PTR [rdx]
     a50:	mov    r8,QWORD PTR [rdx+0x8]
     a54:	mov    rcx,QWORD PTR [rdx+0x10]
     a58:	mov    rdx,r8
     a5b:	call   a60 <botlish_entry_8+0x17>
			a5c: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     a60:	mov    rsp,rbp
     a63:	pop    rbp
     a64:	ret

0000000000000a65 <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     a65:	push   rbp
     a66:	mov    rbp,rsp
     a69:	sub    rsp,0x40
     a6d:	mov    QWORD PTR [rsp+0x20],rbx
     a72:	mov    QWORD PTR [rsp+0x28],r12
     a77:	mov    QWORD PTR [rsp+0x30],r13
     a7c:	mov    QWORD PTR [rsp+0x38],r14
     a81:	mov    rbx,rdi
     a84:	mov    QWORD PTR [rsp],rsi
     a88:	mov    QWORD PTR [rsp+0x8],rdx
     a8d:	mov    r14,rdx
     a90:	mov    QWORD PTR [rsp+0x10],rcx
     a95:	mov    r13,rcx
     a98:	mov    rcx,r13
     a9b:	mov    rdx,r14
     a9e:	mov    rdi,rbx
     aa1:	call   aa6 <botlish_fn_9+0x41>
			aa2: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     aa6:	test   rax,rax
     aa9:	je     b12 <botlish_fn_9+0xad>
     aaf:	xor    ecx,ecx
     ab1:	test   rax,0x7
     ab7:	je     ac5 <botlish_fn_9+0x60>
     abd:	mov    r12,rax
     ac0:	jmp    ad3 <botlish_fn_9+0x6e>
     ac5:	movzx  rcx,BYTE PTR [rax]
     ac9:	mov    r12,rax
     acc:	rex cmp cl,0x8
     ad0:	sete   cl
     ad3:	test   cl,cl
     ad5:	jne    af8 <botlish_fn_9+0x93>
     adb:	mov    rdi,rbx
     ade:	mov    rax,QWORD PTR [rdi+0x10]
     ae2:	mov    rcx,QWORD PTR [rax+0x8]
     ae6:	mov    edx,0x8
     aeb:	mov    rsi,r12
     aee:	call   af3 <botlish_fn_9+0x8e>
			aef: R_X86_64_PLT32	rt_type_error-0x4
     af3:	jmp    b12 <botlish_fn_9+0xad>
     af8:	mov    rcx,r13
     afb:	mov    rdx,r14
     afe:	mov    rdi,rbx
     b01:	mov    rsi,r12
     b04:	call   b09 <botlish_fn_9+0xa4>
			b05: R_X86_64_PLT32	rt_mutarray_set-0x4
     b09:	test   rax,rax
     b0c:	jne    b32 <botlish_fn_9+0xcd>
     b12:	xor    rax,rax
     b15:	mov    rbx,QWORD PTR [rsp+0x20]
     b1a:	mov    r12,QWORD PTR [rsp+0x28]
     b1f:	mov    r13,QWORD PTR [rsp+0x30]
     b24:	mov    r14,QWORD PTR [rsp+0x38]
     b29:	add    rsp,0x40
     b2d:	mov    rsp,rbp
     b30:	pop    rbp
     b31:	ret
     b32:	mov    rax,r12
     b35:	mov    rbx,QWORD PTR [rsp+0x20]
     b3a:	mov    r12,QWORD PTR [rsp+0x28]
     b3f:	mov    r13,QWORD PTR [rsp+0x30]
     b44:	mov    r14,QWORD PTR [rsp+0x38]
     b49:	add    rsp,0x40
     b4d:	mov    rsp,rbp
     b50:	pop    rbp
     b51:	ret

0000000000000b52 <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     b52:	push   rbp
     b53:	mov    rbp,rsp
     b56:	mov    rsi,QWORD PTR [rdx]
     b59:	mov    r8,QWORD PTR [rdx+0x8]
     b5d:	mov    rcx,QWORD PTR [rdx+0x10]
     b61:	mov    rdx,r8
     b64:	call   b69 <botlish_entry_9+0x17>
			b65: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     b69:	mov    rsp,rbp
     b6c:	pop    rbp
     b6d:	ret

0000000000000b6e <botlish_fn_10: geo_finish<mutarray, int>>:
     b6e:	push   rbp
     b6f:	mov    rbp,rsp
     b72:	sub    rsp,0x10
     b76:	mov    QWORD PTR [rsp],rsi
     b7a:	mov    QWORD PTR [rsp+0x8],rdx
     b7f:	call   b84 <botlish_fn_10+0x16>
			b80: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     b84:	test   rax,rax
     b87:	jne    b99 <botlish_fn_10+0x2b>
     b8d:	xor    rax,rax
     b90:	add    rsp,0x10
     b94:	mov    rsp,rbp
     b97:	pop    rbp
     b98:	ret
     b99:	add    rsp,0x10
     b9d:	mov    rsp,rbp
     ba0:	pop    rbp
     ba1:	ret

0000000000000ba2 <botlish_entry_10: geo_finish<mutarray, int>>:
     ba2:	push   rbp
     ba3:	mov    rbp,rsp
     ba6:	mov    rsi,QWORD PTR [rdx]
     ba9:	mov    rdx,QWORD PTR [rdx+0x8]
     bad:	call   bb2 <botlish_entry_10+0x10>
			bae: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
     bb2:	mov    rsp,rbp
     bb5:	pop    rbp
     bb6:	ret
	...

0000000000000bb8 <botlish_fn_11: peek<str, int>>:
     bb8:	push   rbp
     bb9:	mov    rbp,rsp
     bbc:	sub    rsp,0x40
     bc0:	mov    QWORD PTR [rsp+0x20],rbx
     bc5:	mov    QWORD PTR [rsp+0x28],r12
     bca:	mov    QWORD PTR [rsp+0x30],r13
     bcf:	mov    r13,rdi
     bd2:	mov    QWORD PTR [rsp],rsi
     bd6:	mov    r12,rsi
     bd9:	mov    QWORD PTR [rsp+0x8],rdx
     bde:	mov    rbx,rdx
     be1:	mov    rsi,r12
     be4:	mov    rdi,r13
     be7:	call   bec <botlish_fn_11+0x34>
			be8: R_X86_64_PLT32	rt_str_len-0x4
     bec:	mov    rcx,rbx
     bef:	and    rcx,rax
     bf2:	mov    rdx,rax
     bf5:	test   rcx,0x1
     bfc:	jne    c22 <botlish_fn_11+0x6a>
     c02:	mov    rsi,rbx
     c05:	mov    rdi,r13
     c08:	call   c0d <botlish_fn_11+0x55>
			c09: R_X86_64_PLT32	rt_int_cmp-0x4
     c0d:	mov    ecx,0x2
     c12:	test   rax,rax
     c15:	cmovge rcx,QWORD PTR [rip+0xd3]        # cf0 <botlish_fn_11+0x138>
     c1d:	jmp    c32 <botlish_fn_11+0x7a>
     c22:	mov    ecx,0x2
     c27:	cmp    rbx,rdx
     c2a:	cmovge rcx,QWORD PTR [rip+0xbe]        # cf0 <botlish_fn_11+0x138>
     c32:	cmp    rcx,0x6
     c36:	je     cc6 <botlish_fn_11+0x10e>
     c3c:	mov    QWORD PTR [rsp+0x10],0x3
     c45:	test   rbx,0x1
     c4c:	je     c64 <botlish_fn_11+0xac>
     c52:	mov    rcx,rbx
     c55:	add    rcx,0x2
     c59:	seto   al
     c5c:	test   al,al
     c5e:	je     c77 <botlish_fn_11+0xbf>
     c64:	mov    edx,0x3
     c69:	mov    rsi,rbx
     c6c:	mov    rdi,r13
     c6f:	call   c74 <botlish_fn_11+0xbc>
			c70: R_X86_64_PLT32	rt_int_add-0x4
     c74:	mov    rcx,rax
     c77:	mov    QWORD PTR [rsp+0x10],rcx
     c7c:	mov    rdx,rbx
     c7f:	mov    rsi,r12
     c82:	mov    rdi,r13
     c85:	call   c8a <botlish_fn_11+0xd2>
			c86: R_X86_64_PLT32	rt_substr-0x4
     c8a:	test   rax,rax
     c8d:	jne    cae <botlish_fn_11+0xf6>
     c93:	xor    rax,rax
     c96:	mov    rbx,QWORD PTR [rsp+0x20]
     c9b:	mov    r12,QWORD PTR [rsp+0x28]
     ca0:	mov    r13,QWORD PTR [rsp+0x30]
     ca5:	add    rsp,0x40
     ca9:	mov    rsp,rbp
     cac:	pop    rbp
     cad:	ret
     cae:	mov    rbx,QWORD PTR [rsp+0x20]
     cb3:	mov    r12,QWORD PTR [rsp+0x28]
     cb8:	mov    r13,QWORD PTR [rsp+0x30]
     cbd:	add    rsp,0x40
     cc1:	mov    rsp,rbp
     cc4:	pop    rbp
     cc5:	ret
     cc6:	mov    rdi,r13
     cc9:	mov    rax,QWORD PTR [rdi+0x10]
     ccd:	mov    rax,QWORD PTR [rax+0x10]
     cd1:	mov    rbx,QWORD PTR [rsp+0x20]
     cd6:	mov    r12,QWORD PTR [rsp+0x28]
     cdb:	mov    r13,QWORD PTR [rsp+0x30]
     ce0:	add    rsp,0x40
     ce4:	mov    rsp,rbp
     ce7:	pop    rbp
     ce8:	ret
     ce9:	add    BYTE PTR [rax],al
     ceb:	add    BYTE PTR [rax],al
     ced:	add    BYTE PTR [rax],al
     cef:	add    BYTE PTR [rsi],al
     cf1:	add    BYTE PTR [rax],al
     cf3:	add    BYTE PTR [rax],al
     cf5:	add    BYTE PTR [rax],al
	...

0000000000000cf8 <botlish_entry_11: peek<str, int>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	mov    rsi,QWORD PTR [rdx]
     cff:	mov    rdx,QWORD PTR [rdx+0x8]
     d03:	call   d08 <botlish_entry_11+0x10>
			d04: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
     d08:	mov    rsp,rbp
     d0b:	pop    rbp
     d0c:	ret
     d0d:	add    BYTE PTR [rax],al
	...

0000000000000d10 <botlish_fn_12: peek<str, int>>:
     d10:	push   rbp
     d11:	mov    rbp,rsp
     d14:	sub    rsp,0x50
     d18:	mov    QWORD PTR [rsp+0x20],rbx
     d1d:	mov    QWORD PTR [rsp+0x28],r12
     d22:	mov    QWORD PTR [rsp+0x30],r13
     d27:	mov    QWORD PTR [rsp+0x38],r14
     d2c:	mov    QWORD PTR [rsp+0x40],r15
     d31:	mov    r12,rcx
     d34:	mov    r14,rdi
     d37:	mov    QWORD PTR [rsp],rsi
     d3b:	mov    r13,rsi
     d3e:	mov    QWORD PTR [rsp+0x8],rdx
     d43:	mov    rbx,rdx
     d46:	mov    rsi,r13
     d49:	mov    rdi,r14
     d4c:	call   d51 <botlish_fn_12+0x41>
			d4d: R_X86_64_PLT32	rt_str_len-0x4
     d51:	mov    rcx,rbx
     d54:	and    rcx,rax
     d57:	mov    rdx,rax
     d5a:	test   rcx,0x1
     d61:	jne    d87 <botlish_fn_12+0x77>
     d67:	mov    rsi,rbx
     d6a:	mov    rdi,r14
     d6d:	call   d72 <botlish_fn_12+0x62>
			d6e: R_X86_64_PLT32	rt_int_cmp-0x4
     d72:	mov    ecx,0x2
     d77:	test   rax,rax
     d7a:	cmovge rcx,QWORD PTR [rip+0x11e]        # ea0 <botlish_fn_12+0x190>
     d82:	jmp    d97 <botlish_fn_12+0x87>
     d87:	mov    ecx,0x2
     d8c:	cmp    rbx,rdx
     d8f:	cmovge rcx,QWORD PTR [rip+0x109]        # ea0 <botlish_fn_12+0x190>
     d97:	cmp    rcx,0x6
     d9b:	je     e5b <botlish_fn_12+0x14b>
     da1:	mov    QWORD PTR [rsp+0x10],0x3
     daa:	test   rbx,0x1
     db1:	je     dd4 <botlish_fn_12+0xc4>
     db7:	mov    rax,rbx
     dba:	add    rax,0x2
     dbe:	seto   cl
     dc1:	test   cl,cl
     dc3:	jne    dd4 <botlish_fn_12+0xc4>
     dc9:	mov    rdi,r14
     dcc:	mov    r15,rax
     dcf:	jmp    dea <botlish_fn_12+0xda>
     dd4:	mov    edx,0x3
     dd9:	mov    rsi,rbx
     ddc:	mov    rdi,r14
     ddf:	call   de4 <botlish_fn_12+0xd4>
			de0: R_X86_64_PLT32	rt_int_add-0x4
     de4:	mov    r15,rax
     de7:	mov    rdi,r14
     dea:	mov    rdi,r14
     ded:	mov    rcx,r15
     df0:	mov    rdx,rbx
     df3:	mov    rsi,r13
     df6:	call   dfb <botlish_fn_12+0xeb>
			df7: R_X86_64_PLT32	rt_str_region_check-0x4
     dfb:	test   rax,rax
     dfe:	jne    e29 <botlish_fn_12+0x119>
     e04:	xor    rax,rax
     e07:	mov    rbx,QWORD PTR [rsp+0x20]
     e0c:	mov    r12,QWORD PTR [rsp+0x28]
     e11:	mov    r13,QWORD PTR [rsp+0x30]
     e16:	mov    r14,QWORD PTR [rsp+0x38]
     e1b:	mov    r15,QWORD PTR [rsp+0x40]
     e20:	add    rsp,0x50
     e24:	mov    rsp,rbp
     e27:	pop    rbp
     e28:	ret
     e29:	mov    rcx,r12
     e2c:	mov    QWORD PTR [rcx],rbx
     e2f:	mov    rax,r15
     e32:	mov    QWORD PTR [rcx+0x8],rax
     e36:	mov    rax,r13
     e39:	mov    rbx,QWORD PTR [rsp+0x20]
     e3e:	mov    r12,QWORD PTR [rsp+0x28]
     e43:	mov    r13,QWORD PTR [rsp+0x30]
     e48:	mov    r14,QWORD PTR [rsp+0x38]
     e4d:	mov    r15,QWORD PTR [rsp+0x40]
     e52:	add    rsp,0x50
     e56:	mov    rsp,rbp
     e59:	pop    rbp
     e5a:	ret
     e5b:	mov    rcx,r12
     e5e:	mov    rdi,r14
     e61:	mov    rax,QWORD PTR [rdi+0x10]
     e65:	mov    rax,QWORD PTR [rax+0x10]
     e69:	mov    QWORD PTR [rcx],0x1
     e70:	mov    QWORD PTR [rcx+0x8],0x1
     e78:	mov    rbx,QWORD PTR [rsp+0x20]
     e7d:	mov    r12,QWORD PTR [rsp+0x28]
     e82:	mov    r13,QWORD PTR [rsp+0x30]
     e87:	mov    r14,QWORD PTR [rsp+0x38]
     e8c:	mov    r15,QWORD PTR [rsp+0x40]
     e91:	add    rsp,0x50
     e95:	mov    rsp,rbp
     e98:	pop    rbp
     e99:	ret
     e9a:	add    BYTE PTR [rax],al
     e9c:	add    BYTE PTR [rax],al
     e9e:	add    BYTE PTR [rax],al
     ea0:	(bad)
     ea1:	add    BYTE PTR [rax],al
     ea3:	add    BYTE PTR [rax],al
     ea5:	add    BYTE PTR [rax],al
	...

0000000000000ea8 <botlish_entry_12: peek<str, int>>:
     ea8:	push   rbp
     ea9:	mov    rbp,rsp
     eac:	ud2

0000000000000eae <botlish_fn_13: scan_unquoted<str, int, int>>:
     eae:	push   rbp
     eaf:	mov    rbp,rsp
     eb2:	sub    rsp,0x80
     eb9:	mov    QWORD PTR [rsp+0x50],rbx
     ebe:	mov    QWORD PTR [rsp+0x58],r12
     ec3:	mov    QWORD PTR [rsp+0x60],r13
     ec8:	mov    QWORD PTR [rsp+0x68],r14
     ecd:	mov    QWORD PTR [rsp+0x70],r15
     ed2:	mov    QWORD PTR [rsp+0x30],rdi
     ed7:	mov    QWORD PTR [rsp+0x18],0x0
     ee0:	mov    QWORD PTR [rsp],rsi
     ee4:	mov    r15,rsi
     ee7:	mov    QWORD PTR [rsp+0x8],rdx
     eec:	mov    r14,rdx
     eef:	mov    QWORD PTR [rsp+0x10],rcx
     ef4:	lea    r13,[rsp+0x20]
     ef9:	mov    QWORD PTR [rsp+0x38],rcx
     efe:	mov    rcx,r13
     f01:	mov    rdx,QWORD PTR [rsp+0x38]
     f06:	mov    rsi,r15
     f09:	mov    rdi,QWORD PTR [rsp+0x30]
     f0e:	call   f13 <botlish_fn_13+0x65>
			f0f: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     f13:	mov    rsi,rax
     f16:	mov    QWORD PTR [rsp+0x40],rax
     f1b:	test   rax,rsi
     f1e:	je     1078 <botlish_fn_13+0x1ca>
     f24:	mov    rbx,QWORD PTR [rsp+0x20]
     f29:	mov    r12,QWORD PTR [rsp+0x28]
     f2e:	mov    rdi,QWORD PTR [rsp+0x30]
     f33:	mov    rcx,QWORD PTR [rdi+0x10]
     f37:	mov    r8,QWORD PTR [rcx+0x10]
     f3b:	mov    rcx,r12
     f3e:	mov    rdx,rbx
     f41:	mov    rsi,QWORD PTR [rsp+0x40]
     f46:	call   f4b <botlish_fn_13+0x9d>
			f47: R_X86_64_PLT32	rt_str_region_eq-0x4
     f4b:	cmp    rax,0x6
     f4f:	je     f90 <botlish_fn_13+0xe2>
     f55:	mov    rdi,QWORD PTR [rsp+0x30]
     f5a:	mov    rax,QWORD PTR [rdi+0x10]
     f5e:	mov    r8,QWORD PTR [rax+0x18]
     f62:	mov    rcx,r12
     f65:	mov    rdx,rbx
     f68:	mov    rsi,QWORD PTR [rsp+0x40]
     f6d:	call   f72 <botlish_fn_13+0xc4>
			f6e: R_X86_64_PLT32	rt_str_region_eq-0x4
     f72:	cmp    rax,0x6
     f76:	je     f86 <botlish_fn_13+0xd8>
     f7c:	mov    eax,0x2
     f81:	jmp    f95 <botlish_fn_13+0xe7>
     f86:	mov    eax,0x6
     f8b:	jmp    f95 <botlish_fn_13+0xe7>
     f90:	mov    eax,0x6
     f95:	cmp    rax,0x6
     f99:	je     fda <botlish_fn_13+0x12c>
     f9f:	mov    rdi,QWORD PTR [rsp+0x30]
     fa4:	mov    rax,QWORD PTR [rdi+0x10]
     fa8:	mov    r8,QWORD PTR [rax+0x20]
     fac:	mov    rcx,r12
     faf:	mov    rdx,rbx
     fb2:	mov    rsi,QWORD PTR [rsp+0x40]
     fb7:	call   fbc <botlish_fn_13+0x10e>
			fb8: R_X86_64_PLT32	rt_str_region_eq-0x4
     fbc:	cmp    rax,0x6
     fc0:	je     fd0 <botlish_fn_13+0x122>
     fc6:	mov    eax,0x2
     fcb:	jmp    fdf <botlish_fn_13+0x131>
     fd0:	mov    eax,0x6
     fd5:	jmp    fdf <botlish_fn_13+0x131>
     fda:	mov    eax,0x6
     fdf:	cmp    rax,0x6
     fe3:	je     105a <botlish_fn_13+0x1ac>
     fe9:	mov    QWORD PTR [rsp+0x18],0x3
     ff2:	mov    rsi,QWORD PTR [rsp+0x38]
     ff7:	test   rsi,0x1
     ffe:	je     1025 <botlish_fn_13+0x177>
    1004:	mov    rsi,QWORD PTR [rsp+0x38]
    1009:	mov    rax,rsi
    100c:	add    rax,0x2
    1010:	seto   sil
    1014:	test   sil,sil
    1017:	jne    1025 <botlish_fn_13+0x177>
    101d:	mov    rsi,r15
    1020:	jmp    103c <botlish_fn_13+0x18e>
    1025:	mov    edx,0x3
    102a:	mov    rsi,QWORD PTR [rsp+0x38]
    102f:	mov    rdi,QWORD PTR [rsp+0x30]
    1034:	call   1039 <botlish_fn_13+0x18b>
			1035: R_X86_64_PLT32	rt_int_add-0x4
    1039:	mov    rsi,r15
    103c:	mov    QWORD PTR [rsp],rsi
    1040:	mov    rdx,r14
    1043:	mov    QWORD PTR [rsp+0x8],rdx
    1048:	mov    QWORD PTR [rsp+0x10],rax
    104d:	mov    r15,rsi
    1050:	mov    QWORD PTR [rsp+0x38],rax
    1055:	jmp    efe <botlish_fn_13+0x50>
    105a:	mov    rdx,r14
    105d:	mov    rsi,r15
    1060:	mov    rdi,QWORD PTR [rsp+0x30]
    1065:	mov    rcx,QWORD PTR [rsp+0x38]
    106a:	call   106f <botlish_fn_13+0x1c1>
			106b: R_X86_64_PLT32	rt_substr-0x4
    106f:	test   rax,rax
    1072:	jne    10a3 <botlish_fn_13+0x1f5>
    1078:	xor    rdx,rdx
    107b:	mov    rax,rdx
    107e:	mov    rbx,QWORD PTR [rsp+0x50]
    1083:	mov    r12,QWORD PTR [rsp+0x58]
    1088:	mov    r13,QWORD PTR [rsp+0x60]
    108d:	mov    r14,QWORD PTR [rsp+0x68]
    1092:	mov    r15,QWORD PTR [rsp+0x70]
    1097:	add    rsp,0x80
    109e:	mov    rsp,rbp
    10a1:	pop    rbp
    10a2:	ret
    10a3:	mov    rdx,QWORD PTR [rsp+0x38]
    10a8:	mov    rbx,QWORD PTR [rsp+0x50]
    10ad:	mov    r12,QWORD PTR [rsp+0x58]
    10b2:	mov    r13,QWORD PTR [rsp+0x60]
    10b7:	mov    r14,QWORD PTR [rsp+0x68]
    10bc:	mov    r15,QWORD PTR [rsp+0x70]
    10c1:	add    rsp,0x80
    10c8:	mov    rsp,rbp
    10cb:	pop    rbp
    10cc:	ret

00000000000010cd <botlish_entry_13: scan_unquoted<str, int, int>>:
    10cd:	push   rbp
    10ce:	mov    rbp,rsp
    10d1:	ud2

00000000000010d3 <botlish_fn_14: scan_quoted<str, int, str>>:
    10d3:	push   rbp
    10d4:	mov    rbp,rsp
    10d7:	sub    rsp,0xd0
    10de:	mov    QWORD PTR [rsp+0xa0],rbx
    10e6:	mov    QWORD PTR [rsp+0xa8],r12
    10ee:	mov    QWORD PTR [rsp+0xb0],r13
    10f6:	mov    QWORD PTR [rsp+0xb8],r14
    10fe:	mov    QWORD PTR [rsp+0xc0],r15
    1106:	mov    QWORD PTR [rsp+0x88],rdi
    110e:	mov    QWORD PTR [rsp+0x18],0x0
    1117:	mov    QWORD PTR [rsp+0x20],0x0
    1120:	mov    QWORD PTR [rsp],rsi
    1124:	mov    QWORD PTR [rsp+0x8],rdx
    1129:	mov    QWORD PTR [rsp+0x10],rcx
    112e:	mov    r13,rcx
    1131:	lea    r14,[rsp+0x68]
    1136:	lea    rbx,[rsp+0x28]
    113b:	mov    r12,rsi
    113e:	mov    QWORD PTR [rsp+0x90],rdx
    1146:	mov    rdx,QWORD PTR [rsp+0x90]
    114e:	mov    rsi,r12
    1151:	mov    rdi,QWORD PTR [rsp+0x88]
    1159:	call   115e <botlish_fn_14+0x8b>
			115a: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    115e:	test   rax,rax
    1161:	je     14aa <botlish_fn_14+0x3d7>
    1167:	mov    QWORD PTR [rsp+0x18],rax
    116c:	mov    rsi,QWORD PTR [rax+0x8]
    1170:	mov    rcx,rax
    1173:	mov    rax,0xffffffffffffffff
    117a:	test   rsi,rsi
    117d:	jne    118b <botlish_fn_14+0xb8>
    1183:	mov    r15,rcx
    1186:	jmp    11b6 <botlish_fn_14+0xe3>
    118b:	mov    r15,rcx
    118e:	movzx  rdi,BYTE PTR [r15+0x18]
    1193:	test   rdi,rdi
    1196:	jne    11b1 <botlish_fn_14+0xde>
    119c:	mov    rsi,r15
    119f:	mov    rdi,QWORD PTR [rsp+0x88]
    11a7:	call   11ac <botlish_fn_14+0xd9>
			11a8: R_X86_64_PLT32	rt_str_to_short-0x4
    11ac:	jmp    11b6 <botlish_fn_14+0xe3>
    11b1:	movzx  rax,BYTE PTR [r15+0x19]
    11b6:	cmp    rax,0x22
    11ba:	je     127a <botlish_fn_14+0x1a7>
    11c0:	mov    QWORD PTR [rsp+0x20],0x3
    11c9:	mov    rsi,QWORD PTR [rsp+0x90]
    11d1:	test   rsi,0x1
    11d8:	je     11f8 <botlish_fn_14+0x125>
    11de:	mov    rax,rsi
    11e1:	add    rax,0x2
    11e5:	seto   cl
    11e8:	test   cl,cl
    11ea:	jne    11f8 <botlish_fn_14+0x125>
    11f0:	mov    rsi,rax
    11f3:	jmp    120d <botlish_fn_14+0x13a>
    11f8:	mov    edx,0x3
    11fd:	mov    rdi,QWORD PTR [rsp+0x88]
    1205:	call   120a <botlish_fn_14+0x137>
			1206: R_X86_64_PLT32	rt_int_add-0x4
    120a:	mov    rsi,rax
    120d:	mov    QWORD PTR [rsp+0x8],rsi
    1212:	mov    QWORD PTR [rsp+0x90],rsi
    121a:	mov    QWORD PTR [rsp+0x68],0x0
    1223:	mov    QWORD PTR [rsp+0x70],r13
    1228:	mov    QWORD PTR [rsp+0x78],0x0
    1231:	mov    QWORD PTR [rsp+0x80],r15
    1239:	mov    esi,0x2
    123e:	mov    edx,0x4
    1243:	mov    rcx,r14
    1246:	mov    rdi,QWORD PTR [rsp+0x88]
    124e:	call   1253 <botlish_fn_14+0x180>
			124f: R_X86_64_PLT32	rt_construct-0x4
    1253:	test   rax,rax
    1256:	je     14aa <botlish_fn_14+0x3d7>
    125c:	mov    QWORD PTR [rsp],r12
    1260:	mov    rsi,QWORD PTR [rsp+0x90]
    1268:	mov    QWORD PTR [rsp+0x8],rsi
    126d:	mov    QWORD PTR [rsp+0x10],rax
    1272:	mov    r13,rax
    1275:	jmp    1146 <botlish_fn_14+0x73>
    127a:	mov    QWORD PTR [rsp+0x18],0x3
    1283:	mov    rsi,QWORD PTR [rsp+0x90]
    128b:	test   rsi,0x1
    1292:	je     12b2 <botlish_fn_14+0x1df>
    1298:	mov    rsi,QWORD PTR [rsp+0x90]
    12a0:	mov    rdx,rsi
    12a3:	add    rdx,0x2
    12a7:	seto   al
    12aa:	test   al,al
    12ac:	je     12cf <botlish_fn_14+0x1fc>
    12b2:	mov    edx,0x3
    12b7:	mov    rsi,QWORD PTR [rsp+0x90]
    12bf:	mov    rdi,QWORD PTR [rsp+0x88]
    12c7:	call   12cc <botlish_fn_14+0x1f9>
			12c8: R_X86_64_PLT32	rt_int_add-0x4
    12cc:	mov    rdx,rax
    12cf:	mov    QWORD PTR [rsp+0x18],rdx
    12d4:	mov    rcx,rbx
    12d7:	mov    rsi,r12
    12da:	mov    rdi,QWORD PTR [rsp+0x88]
    12e2:	call   12e7 <botlish_fn_14+0x214>
			12e3: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    12e7:	test   rax,rax
    12ea:	mov    rsi,rax
    12ed:	je     14aa <botlish_fn_14+0x3d7>
    12f3:	mov    rdx,QWORD PTR [rsp+0x28]
    12f8:	mov    rcx,QWORD PTR [rsp+0x30]
    12fd:	mov    rdi,QWORD PTR [rsp+0x88]
    1305:	mov    rax,QWORD PTR [rdi+0x10]
    1309:	mov    r8,QWORD PTR [rax+0x28]
    130d:	call   1312 <botlish_fn_14+0x23f>
			130e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1312:	cmp    rax,0x6
    1316:	je     13e8 <botlish_fn_14+0x315>
    131c:	xor    rsi,rsi
    131f:	lea    rcx,[rsp+0x58]
    1324:	mov    QWORD PTR [rsp+0x58],0x0
    132d:	mov    QWORD PTR [rsp+0x60],r13
    1332:	mov    edx,0x2
    1337:	mov    rdi,QWORD PTR [rsp+0x88]
    133f:	call   1344 <botlish_fn_14+0x271>
			1340: R_X86_64_PLT32	rt_construct-0x4
    1344:	test   rax,rax
    1347:	je     14aa <botlish_fn_14+0x3d7>
    134d:	mov    QWORD PTR [rsp],rax
    1351:	mov    rbx,rax
    1354:	mov    QWORD PTR [rsp+0x10],0x3
    135d:	mov    rsi,QWORD PTR [rsp+0x90]
    1365:	test   rsi,0x1
    136c:	je     1394 <botlish_fn_14+0x2c1>
    1372:	mov    rsi,QWORD PTR [rsp+0x90]
    137a:	mov    rdx,rsi
    137d:	add    rdx,0x2
    1381:	seto   al
    1384:	test   al,al
    1386:	jne    1394 <botlish_fn_14+0x2c1>
    138c:	mov    rax,rbx
    138f:	jmp    13b4 <botlish_fn_14+0x2e1>
    1394:	mov    edx,0x3
    1399:	mov    rsi,QWORD PTR [rsp+0x90]
    13a1:	mov    rdi,QWORD PTR [rsp+0x88]
    13a9:	call   13ae <botlish_fn_14+0x2db>
			13aa: R_X86_64_PLT32	rt_int_add-0x4
    13ae:	mov    rdx,rax
    13b1:	mov    rax,rbx
    13b4:	mov    rbx,QWORD PTR [rsp+0xa0]
    13bc:	mov    r12,QWORD PTR [rsp+0xa8]
    13c4:	mov    r13,QWORD PTR [rsp+0xb0]
    13cc:	mov    r14,QWORD PTR [rsp+0xb8]
    13d4:	mov    r15,QWORD PTR [rsp+0xc0]
    13dc:	add    rsp,0xd0
    13e3:	mov    rsp,rbp
    13e6:	pop    rbp
    13e7:	ret
    13e8:	mov    QWORD PTR [rsp+0x18],0x5
    13f1:	mov    rsi,QWORD PTR [rsp+0x90]
    13f9:	test   rsi,0x1
    1400:	je     1432 <botlish_fn_14+0x35f>
    1406:	mov    rsi,QWORD PTR [rsp+0x90]
    140e:	mov    rdi,rsi
    1411:	add    rdi,0x4
    1415:	seto   r9b
    1419:	test   r9b,r9b
    141c:	jne    1432 <botlish_fn_14+0x35f>
    1422:	mov    rsi,rdi
    1425:	mov    QWORD PTR [rsp+0x90],rdi
    142d:	jmp    1457 <botlish_fn_14+0x384>
    1432:	mov    edx,0x5
    1437:	mov    rsi,QWORD PTR [rsp+0x90]
    143f:	mov    rdi,QWORD PTR [rsp+0x88]
    1447:	call   144c <botlish_fn_14+0x379>
			1448: R_X86_64_PLT32	rt_int_add-0x4
    144c:	mov    rsi,rax
    144f:	mov    QWORD PTR [rsp+0x90],rax
    1457:	mov    QWORD PTR [rsp+0x8],rsi
    145c:	mov    rdi,QWORD PTR [rsp+0x88]
    1464:	mov    rax,QWORD PTR [rdi+0x10]
    1468:	mov    rax,QWORD PTR [rax+0x28]
    146c:	mov    QWORD PTR [rsp+0x18],rax
    1471:	lea    rcx,[rsp+0x38]
    1476:	mov    QWORD PTR [rsp+0x38],0x0
    147f:	mov    QWORD PTR [rsp+0x40],r13
    1484:	mov    QWORD PTR [rsp+0x48],0x0
    148d:	mov    QWORD PTR [rsp+0x50],rax
    1492:	mov    esi,0x2
    1497:	mov    edx,0x4
    149c:	call   14a1 <botlish_fn_14+0x3ce>
			149d: R_X86_64_PLT32	rt_construct-0x4
    14a1:	test   rax,rax
    14a4:	jne    14e4 <botlish_fn_14+0x411>
    14aa:	xor    rdx,rdx
    14ad:	mov    rax,rdx
    14b0:	mov    rbx,QWORD PTR [rsp+0xa0]
    14b8:	mov    r12,QWORD PTR [rsp+0xa8]
    14c0:	mov    r13,QWORD PTR [rsp+0xb0]
    14c8:	mov    r14,QWORD PTR [rsp+0xb8]
    14d0:	mov    r15,QWORD PTR [rsp+0xc0]
    14d8:	add    rsp,0xd0
    14df:	mov    rsp,rbp
    14e2:	pop    rbp
    14e3:	ret
    14e4:	mov    QWORD PTR [rsp],r12
    14e8:	mov    rsi,QWORD PTR [rsp+0x90]
    14f0:	mov    QWORD PTR [rsp+0x8],rsi
    14f5:	mov    QWORD PTR [rsp+0x10],rax
    14fa:	mov    r13,rax
    14fd:	jmp    1146 <botlish_fn_14+0x73>

0000000000001502 <botlish_entry_14: scan_quoted<str, int, str>>:
    1502:	push   rbp
    1503:	mov    rbp,rsp
    1506:	ud2

0000000000001508 <botlish_fn_15: scan_field<str, int>>:
    1508:	push   rbp
    1509:	mov    rbp,rsp
    150c:	sub    rsp,0x50
    1510:	mov    QWORD PTR [rsp+0x30],rbx
    1515:	mov    QWORD PTR [rsp+0x38],r12
    151a:	mov    QWORD PTR [rsp+0x40],r13
    151f:	mov    r12,rdi
    1522:	mov    r13,rdx
    1525:	mov    QWORD PTR [rsp+0x10],0x0
    152e:	mov    QWORD PTR [rsp],rsi
    1532:	mov    rbx,rsi
    1535:	mov    QWORD PTR [rsp+0x8],rdx
    153a:	lea    rcx,[rsp+0x18]
    153f:	mov    rdx,r13
    1542:	mov    rsi,rbx
    1545:	mov    rdi,r12
    1548:	call   154d <botlish_fn_15+0x45>
			1549: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    154d:	test   rax,rax
    1550:	mov    rsi,rax
    1553:	je     161e <botlish_fn_15+0x116>
    1559:	mov    rdx,QWORD PTR [rsp+0x18]
    155e:	mov    rcx,QWORD PTR [rsp+0x20]
    1563:	mov    rdi,r12
    1566:	mov    rax,QWORD PTR [rdi+0x10]
    156a:	mov    r8,QWORD PTR [rax+0x28]
    156e:	call   1573 <botlish_fn_15+0x6b>
			156f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1573:	cmp    rax,0x6
    1577:	je     15af <botlish_fn_15+0xa7>
    157d:	mov    rcx,r13
    1580:	mov    rsi,rbx
    1583:	mov    rdi,r12
    1586:	mov    rdx,rcx
    1589:	call   158e <botlish_fn_15+0x86>
			158a: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    158e:	test   rax,rax
    1591:	je     161e <botlish_fn_15+0x116>
    1597:	mov    rbx,QWORD PTR [rsp+0x30]
    159c:	mov    r12,QWORD PTR [rsp+0x38]
    15a1:	mov    r13,QWORD PTR [rsp+0x40]
    15a6:	add    rsp,0x50
    15aa:	mov    rsp,rbp
    15ad:	pop    rbp
    15ae:	ret
    15af:	mov    rcx,r13
    15b2:	mov    QWORD PTR [rsp+0x10],0x3
    15bb:	test   rcx,0x1
    15c2:	jne    15d0 <botlish_fn_15+0xc8>
    15c8:	mov    r13,rcx
    15cb:	jmp    15e5 <botlish_fn_15+0xdd>
    15d0:	mov    rdx,rcx
    15d3:	add    rdx,0x2
    15d7:	mov    r13,rcx
    15da:	seto   al
    15dd:	test   al,al
    15df:	je     15f8 <botlish_fn_15+0xf0>
    15e5:	mov    edx,0x3
    15ea:	mov    rsi,r13
    15ed:	mov    rdi,r12
    15f0:	call   15f5 <botlish_fn_15+0xed>
			15f1: R_X86_64_PLT32	rt_int_add-0x4
    15f5:	mov    rdx,rax
    15f8:	mov    QWORD PTR [rsp+0x8],rdx
    15fd:	mov    rdi,r12
    1600:	mov    rax,QWORD PTR [rdi+0x10]
    1604:	mov    rcx,QWORD PTR [rax+0x10]
    1608:	mov    QWORD PTR [rsp+0x10],rcx
    160d:	mov    rsi,rbx
    1610:	call   1615 <botlish_fn_15+0x10d>
			1611: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1615:	test   rax,rax
    1618:	jne    163c <botlish_fn_15+0x134>
    161e:	xor    rdx,rdx
    1621:	mov    rax,rdx
    1624:	mov    rbx,QWORD PTR [rsp+0x30]
    1629:	mov    r12,QWORD PTR [rsp+0x38]
    162e:	mov    r13,QWORD PTR [rsp+0x40]
    1633:	add    rsp,0x50
    1637:	mov    rsp,rbp
    163a:	pop    rbp
    163b:	ret
    163c:	mov    rbx,QWORD PTR [rsp+0x30]
    1641:	mov    r12,QWORD PTR [rsp+0x38]
    1646:	mov    r13,QWORD PTR [rsp+0x40]
    164b:	add    rsp,0x50
    164f:	mov    rsp,rbp
    1652:	pop    rbp
    1653:	ret

0000000000001654 <botlish_entry_15: scan_field<str, int>>:
    1654:	push   rbp
    1655:	mov    rbp,rsp
    1658:	ud2

000000000000165a <botlish_fn_16: scan_record_rest<str, int, mutarray, int>>:
    165a:	push   rbp
    165b:	mov    rbp,rsp
    165e:	sub    rsp,0x90
    1665:	mov    QWORD PTR [rsp+0x60],rbx
    166a:	mov    QWORD PTR [rsp+0x68],r12
    166f:	mov    QWORD PTR [rsp+0x70],r13
    1674:	mov    QWORD PTR [rsp+0x78],r14
    1679:	mov    QWORD PTR [rsp+0x80],r15
    1681:	mov    r15,rdi
    1684:	mov    QWORD PTR [rsp+0x20],0x0
    168d:	mov    QWORD PTR [rsp],rsi
    1691:	mov    QWORD PTR [rsp+0x8],rdx
    1696:	mov    QWORD PTR [rsp+0x10],rcx
    169b:	mov    QWORD PTR [rsp+0x18],r8
    16a0:	lea    r12,[rsp+0x28]
    16a5:	mov    rbx,rsi
    16a8:	mov    QWORD PTR [rsp+0x38],rdx
    16ad:	mov    QWORD PTR [rsp+0x40],rcx
    16b2:	mov    QWORD PTR [rsp+0x48],r8
    16b7:	mov    rcx,r12
    16ba:	mov    rdx,QWORD PTR [rsp+0x38]
    16bf:	mov    rsi,rbx
    16c2:	mov    rdi,r15
    16c5:	call   16ca <botlish_fn_16+0x70>
			16c6: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    16ca:	test   rax,rax
    16cd:	mov    QWORD PTR [rsp+0x50],rax
    16d2:	je     1896 <botlish_fn_16+0x23c>
    16d8:	mov    r14,QWORD PTR [rsp+0x28]
    16dd:	mov    r13,QWORD PTR [rsp+0x30]
    16e2:	mov    rdi,r15
    16e5:	mov    rcx,QWORD PTR [rdi+0x10]
    16e9:	mov    r8,QWORD PTR [rcx+0x18]
    16ed:	mov    rcx,r13
    16f0:	mov    rdx,r14
    16f3:	mov    rsi,QWORD PTR [rsp+0x50]
    16f8:	call   16fd <botlish_fn_16+0xa3>
			16f9: R_X86_64_PLT32	rt_str_region_eq-0x4
    16fd:	cmp    rax,0x6
    1701:	je     180f <botlish_fn_16+0x1b5>
    1707:	mov    rdi,r15
    170a:	mov    rax,QWORD PTR [rdi+0x10]
    170e:	mov    r8,QWORD PTR [rax+0x20]
    1712:	mov    rcx,r13
    1715:	mov    rdx,r14
    1718:	mov    rsi,QWORD PTR [rsp+0x50]
    171d:	call   1722 <botlish_fn_16+0xc8>
			171e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1722:	cmp    rax,0x6
    1726:	je     1774 <botlish_fn_16+0x11a>
    172c:	mov    rdx,QWORD PTR [rsp+0x48]
    1731:	mov    rsi,QWORD PTR [rsp+0x40]
    1736:	mov    rdi,r15
    1739:	call   173e <botlish_fn_16+0xe4>
			173a: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    173e:	test   rax,rax
    1741:	je     1896 <botlish_fn_16+0x23c>
    1747:	mov    rdx,QWORD PTR [rsp+0x38]
    174c:	mov    rbx,QWORD PTR [rsp+0x60]
    1751:	mov    r12,QWORD PTR [rsp+0x68]
    1756:	mov    r13,QWORD PTR [rsp+0x70]
    175b:	mov    r14,QWORD PTR [rsp+0x78]
    1760:	mov    r15,QWORD PTR [rsp+0x80]
    1768:	add    rsp,0x90
    176f:	mov    rsp,rbp
    1772:	pop    rbp
    1773:	ret
    1774:	mov    rdx,QWORD PTR [rsp+0x48]
    1779:	mov    rsi,QWORD PTR [rsp+0x40]
    177e:	mov    rdi,r15
    1781:	call   1786 <botlish_fn_16+0x12c>
			1782: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1786:	test   rax,rax
    1789:	je     1896 <botlish_fn_16+0x23c>
    178f:	mov    QWORD PTR [rsp],rax
    1793:	mov    rbx,rax
    1796:	mov    QWORD PTR [rsp+0x10],0x3
    179f:	mov    rdx,QWORD PTR [rsp+0x38]
    17a4:	test   rdx,0x1
    17ab:	je     17cf <botlish_fn_16+0x175>
    17b1:	mov    rdx,QWORD PTR [rsp+0x38]
    17b6:	add    rdx,0x2
    17ba:	seto   sil
    17be:	test   sil,sil
    17c1:	jne    17cf <botlish_fn_16+0x175>
    17c7:	mov    rax,rbx
    17ca:	jmp    17e7 <botlish_fn_16+0x18d>
    17cf:	mov    edx,0x3
    17d4:	mov    rsi,QWORD PTR [rsp+0x38]
    17d9:	mov    rdi,r15
    17dc:	call   17e1 <botlish_fn_16+0x187>
			17dd: R_X86_64_PLT32	rt_int_add-0x4
    17e1:	mov    rdx,rax
    17e4:	mov    rax,rbx
    17e7:	mov    rbx,QWORD PTR [rsp+0x60]
    17ec:	mov    r12,QWORD PTR [rsp+0x68]
    17f1:	mov    r13,QWORD PTR [rsp+0x70]
    17f6:	mov    r14,QWORD PTR [rsp+0x78]
    17fb:	mov    r15,QWORD PTR [rsp+0x80]
    1803:	add    rsp,0x90
    180a:	mov    rsp,rbp
    180d:	pop    rbp
    180e:	ret
    180f:	mov    rsi,QWORD PTR [rsp+0x38]
    1814:	mov    edx,0x3
    1819:	mov    r13,rdx
    181c:	mov    QWORD PTR [rsp+0x20],0x3
    1825:	test   rsi,0x1
    182c:	je     1844 <botlish_fn_16+0x1ea>
    1832:	mov    rdx,rsi
    1835:	add    rdx,0x2
    1839:	seto   al
    183c:	test   al,al
    183e:	je     1852 <botlish_fn_16+0x1f8>
    1844:	mov    rdx,r13
    1847:	mov    rdi,r15
    184a:	call   184f <botlish_fn_16+0x1f5>
			184b: R_X86_64_PLT32	rt_int_add-0x4
    184f:	mov    rdx,rax
    1852:	mov    QWORD PTR [rsp+0x8],rdx
    1857:	mov    rsi,rbx
    185a:	mov    rdi,r15
    185d:	call   1862 <botlish_fn_16+0x208>
			185e: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1862:	test   rax,rax
    1865:	je     1896 <botlish_fn_16+0x23c>
    186b:	mov    QWORD PTR [rsp+0x8],rax
    1870:	mov    rcx,rax
    1873:	mov    QWORD PTR [rsp+0x20],rdx
    1878:	mov    rsi,QWORD PTR [rsp+0x40]
    187d:	mov    r14,rdx
    1880:	mov    rdx,QWORD PTR [rsp+0x48]
    1885:	mov    rdi,r15
    1888:	call   188d <botlish_fn_16+0x233>
			1889: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    188d:	test   rax,rax
    1890:	jne    18c4 <botlish_fn_16+0x26a>
    1896:	xor    rdx,rdx
    1899:	mov    rax,rdx
    189c:	mov    rbx,QWORD PTR [rsp+0x60]
    18a1:	mov    r12,QWORD PTR [rsp+0x68]
    18a6:	mov    r13,QWORD PTR [rsp+0x70]
    18ab:	mov    r14,QWORD PTR [rsp+0x78]
    18b0:	mov    r15,QWORD PTR [rsp+0x80]
    18b8:	add    rsp,0x90
    18bf:	mov    rsp,rbp
    18c2:	pop    rbp
    18c3:	ret
    18c4:	mov    QWORD PTR [rsp+0x8],rax
    18c9:	mov    QWORD PTR [rsp+0x38],rax
    18ce:	mov    QWORD PTR [rsp+0x10],0x3
    18d7:	mov    rdx,QWORD PTR [rsp+0x48]
    18dc:	test   rdx,0x1
    18e3:	jne    18f6 <botlish_fn_16+0x29c>
    18e9:	mov    rdx,r13
    18ec:	mov    rsi,QWORD PTR [rsp+0x48]
    18f1:	jmp    1915 <botlish_fn_16+0x2bb>
    18f6:	mov    rdx,QWORD PTR [rsp+0x48]
    18fb:	mov    rax,rdx
    18fe:	add    rax,0x2
    1902:	seto   cl
    1905:	test   cl,cl
    1907:	je     191d <botlish_fn_16+0x2c3>
    190d:	mov    rdx,r13
    1910:	mov    rsi,QWORD PTR [rsp+0x48]
    1915:	mov    rdi,r15
    1918:	call   191d <botlish_fn_16+0x2c3>
			1919: R_X86_64_PLT32	rt_int_add-0x4
    191d:	mov    QWORD PTR [rsp],rbx
    1921:	mov    rdx,r14
    1924:	mov    QWORD PTR [rsp+0x8],rdx
    1929:	mov    rcx,QWORD PTR [rsp+0x38]
    192e:	mov    QWORD PTR [rsp+0x10],rcx
    1933:	mov    QWORD PTR [rsp+0x18],rax
    1938:	mov    QWORD PTR [rsp+0x38],rdx
    193d:	mov    QWORD PTR [rsp+0x40],rcx
    1942:	mov    QWORD PTR [rsp+0x48],rax
    1947:	jmp    16b7 <botlish_fn_16+0x5d>

000000000000194c <botlish_entry_16: scan_record_rest<str, int, mutarray, int>>:
    194c:	push   rbp
    194d:	mov    rbp,rsp
    1950:	ud2

0000000000001952 <botlish_fn_17: scan_record<str, int>>:
    1952:	push   rbp
    1953:	mov    rbp,rsp
    1956:	sub    rsp,0x40
    195a:	mov    QWORD PTR [rsp+0x20],rbx
    195f:	mov    QWORD PTR [rsp+0x28],r12
    1964:	mov    QWORD PTR [rsp+0x30],r14
    1969:	mov    r14,rdi
    196c:	mov    QWORD PTR [rsp+0x10],0x0
    1975:	mov    QWORD PTR [rsp+0x18],0x0
    197e:	mov    QWORD PTR [rsp],rsi
    1982:	mov    r12,rsi
    1985:	mov    QWORD PTR [rsp+0x8],rdx
    198a:	mov    rsi,r12
    198d:	mov    rdi,r14
    1990:	call   1995 <botlish_fn_17+0x43>
			1991: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1995:	test   rax,rax
    1998:	je     19ed <botlish_fn_17+0x9b>
    199e:	mov    QWORD PTR [rsp+0x8],rax
    19a3:	mov    rsi,rax
    19a6:	mov    QWORD PTR [rsp+0x10],rdx
    19ab:	mov    rbx,rdx
    19ae:	mov    rdi,r14
    19b1:	call   19b6 <botlish_fn_17+0x64>
			19b2: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
    19b6:	test   rax,rax
    19b9:	je     19ed <botlish_fn_17+0x9b>
    19bf:	mov    QWORD PTR [rsp+0x8],rax
    19c4:	mov    rcx,rax
    19c7:	mov    r8d,0x3
    19cd:	mov    QWORD PTR [rsp+0x18],0x3
    19d6:	mov    rdx,rbx
    19d9:	mov    rsi,r12
    19dc:	mov    rdi,r14
    19df:	call   19e4 <botlish_fn_17+0x92>
			19e0: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    19e4:	test   rax,rax
    19e7:	jne    1a0b <botlish_fn_17+0xb9>
    19ed:	xor    rdx,rdx
    19f0:	mov    rax,rdx
    19f3:	mov    rbx,QWORD PTR [rsp+0x20]
    19f8:	mov    r12,QWORD PTR [rsp+0x28]
    19fd:	mov    r14,QWORD PTR [rsp+0x30]
    1a02:	add    rsp,0x40
    1a06:	mov    rsp,rbp
    1a09:	pop    rbp
    1a0a:	ret
    1a0b:	mov    rbx,QWORD PTR [rsp+0x20]
    1a10:	mov    r12,QWORD PTR [rsp+0x28]
    1a15:	mov    r14,QWORD PTR [rsp+0x30]
    1a1a:	add    rsp,0x40
    1a1e:	mov    rsp,rbp
    1a21:	pop    rbp
    1a22:	ret

0000000000001a23 <botlish_entry_17: scan_record<str, int>>:
    1a23:	push   rbp
    1a24:	mov    rbp,rsp
    1a27:	ud2
    1a29:	add    BYTE PTR [rax],al
    1a2b:	add    BYTE PTR [rax],al
    1a2d:	add    BYTE PTR [rax],al
	...

0000000000001a30 <botlish_fn_18: scan_records<str, int, mutarray, int>>:
    1a30:	push   rbp
    1a31:	mov    rbp,rsp
    1a34:	sub    rsp,0x60
    1a38:	mov    QWORD PTR [rsp+0x30],rbx
    1a3d:	mov    QWORD PTR [rsp+0x38],r12
    1a42:	mov    QWORD PTR [rsp+0x40],r13
    1a47:	mov    QWORD PTR [rsp+0x48],r14
    1a4c:	mov    QWORD PTR [rsp+0x50],r15
    1a51:	mov    r13,rdi
    1a54:	mov    QWORD PTR [rsp+0x20],0x0
    1a5d:	mov    QWORD PTR [rsp],rsi
    1a61:	mov    QWORD PTR [rsp+0x8],rdx
    1a66:	mov    r12,rdx
    1a69:	mov    QWORD PTR [rsp+0x10],rcx
    1a6e:	mov    QWORD PTR [rsp+0x18],r8
    1a73:	mov    rbx,rsi
    1a76:	mov    r14,r8
    1a79:	mov    r15,rcx
    1a7c:	mov    rsi,rbx
    1a7f:	mov    rdi,r13
    1a82:	call   1a87 <botlish_fn_18+0x57>
			1a83: R_X86_64_PLT32	rt_str_len-0x4
    1a87:	mov    rcx,r12
    1a8a:	and    rcx,rax
    1a8d:	mov    rdx,rax
    1a90:	test   rcx,0x1
    1a97:	jne    1abd <botlish_fn_18+0x8d>
    1a9d:	mov    rsi,r12
    1aa0:	mov    rdi,r13
    1aa3:	call   1aa8 <botlish_fn_18+0x78>
			1aa4: R_X86_64_PLT32	rt_int_cmp-0x4
    1aa8:	mov    ecx,0x2
    1aad:	test   rax,rax
    1ab0:	cmovge rcx,QWORD PTR [rip+0x128]        # 1be0 <botlish_fn_18+0x1b0>
    1ab8:	jmp    1acd <botlish_fn_18+0x9d>
    1abd:	mov    ecx,0x2
    1ac2:	cmp    r12,rdx
    1ac5:	cmovge rcx,QWORD PTR [rip+0x113]        # 1be0 <botlish_fn_18+0x1b0>
    1acd:	cmp    rcx,0x6
    1ad1:	je     1b7c <botlish_fn_18+0x14c>
    1ad7:	mov    rdx,r12
    1ada:	mov    rsi,rbx
    1add:	mov    rdi,r13
    1ae0:	call   1ae5 <botlish_fn_18+0xb5>
			1ae1: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1ae5:	test   rax,rax
    1ae8:	je     1b93 <botlish_fn_18+0x163>
    1aee:	mov    QWORD PTR [rsp+0x8],rax
    1af3:	mov    rcx,rax
    1af6:	mov    QWORD PTR [rsp+0x20],rdx
    1afb:	mov    rsi,r15
    1afe:	mov    r12,rdx
    1b01:	mov    rdx,r14
    1b04:	mov    rdi,r13
    1b07:	call   1b0c <botlish_fn_18+0xdc>
			1b08: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1b0c:	test   rax,rax
    1b0f:	je     1b93 <botlish_fn_18+0x163>
    1b15:	mov    QWORD PTR [rsp+0x8],rax
    1b1a:	mov    r15,rax
    1b1d:	mov    QWORD PTR [rsp+0x10],0x3
    1b26:	mov    rsi,r14
    1b29:	test   rsi,0x1
    1b30:	je     1b4b <botlish_fn_18+0x11b>
    1b36:	mov    rsi,r14
    1b39:	mov    rax,rsi
    1b3c:	add    rax,0x2
    1b40:	seto   cl
    1b43:	test   cl,cl
    1b45:	je     1b5b <botlish_fn_18+0x12b>
    1b4b:	mov    edx,0x3
    1b50:	mov    rsi,r14
    1b53:	mov    rdi,r13
    1b56:	call   1b5b <botlish_fn_18+0x12b>
			1b57: R_X86_64_PLT32	rt_int_add-0x4
    1b5b:	mov    QWORD PTR [rsp],rbx
    1b5f:	mov    rdx,r12
    1b62:	mov    QWORD PTR [rsp+0x8],rdx
    1b67:	mov    rcx,r15
    1b6a:	mov    QWORD PTR [rsp+0x10],rcx
    1b6f:	mov    QWORD PTR [rsp+0x18],rax
    1b74:	mov    r14,rax
    1b77:	jmp    1a7c <botlish_fn_18+0x4c>
    1b7c:	mov    rdx,r14
    1b7f:	mov    rsi,r15
    1b82:	mov    rdi,r13
    1b85:	call   1b8a <botlish_fn_18+0x15a>
			1b86: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1b8a:	test   rax,rax
    1b8d:	jne    1bb8 <botlish_fn_18+0x188>
    1b93:	xor    rax,rax
    1b96:	mov    rbx,QWORD PTR [rsp+0x30]
    1b9b:	mov    r12,QWORD PTR [rsp+0x38]
    1ba0:	mov    r13,QWORD PTR [rsp+0x40]
    1ba5:	mov    r14,QWORD PTR [rsp+0x48]
    1baa:	mov    r15,QWORD PTR [rsp+0x50]
    1baf:	add    rsp,0x60
    1bb3:	mov    rsp,rbp
    1bb6:	pop    rbp
    1bb7:	ret
    1bb8:	mov    rbx,QWORD PTR [rsp+0x30]
    1bbd:	mov    r12,QWORD PTR [rsp+0x38]
    1bc2:	mov    r13,QWORD PTR [rsp+0x40]
    1bc7:	mov    r14,QWORD PTR [rsp+0x48]
    1bcc:	mov    r15,QWORD PTR [rsp+0x50]
    1bd1:	add    rsp,0x60
    1bd5:	mov    rsp,rbp
    1bd8:	pop    rbp
    1bd9:	ret
    1bda:	add    BYTE PTR [rax],al
    1bdc:	add    BYTE PTR [rax],al
    1bde:	add    BYTE PTR [rax],al
    1be0:	(bad)
    1be1:	add    BYTE PTR [rax],al
    1be3:	add    BYTE PTR [rax],al
    1be5:	add    BYTE PTR [rax],al
	...

0000000000001be8 <botlish_entry_18: scan_records<str, int, mutarray, int>>:
    1be8:	push   rbp
    1be9:	mov    rbp,rsp
    1bec:	mov    rsi,QWORD PTR [rdx]
    1bef:	mov    r9,QWORD PTR [rdx+0x8]
    1bf3:	mov    rcx,QWORD PTR [rdx+0x10]
    1bf7:	mov    r8,QWORD PTR [rdx+0x18]
    1bfb:	mov    rdx,r9
    1bfe:	call   1c03 <botlish_entry_18+0x1b>
			1bff: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1c03:	mov    rsp,rbp
    1c06:	pop    rbp
    1c07:	ret

0000000000001c08 <botlish_fn_19: csv_parse<str>>:
    1c08:	push   rbp
    1c09:	mov    rbp,rsp
    1c0c:	sub    rsp,0x40
    1c10:	mov    QWORD PTR [rsp+0x20],rbx
    1c15:	mov    QWORD PTR [rsp+0x28],r12
    1c1a:	mov    QWORD PTR [rsp+0x30],r13
    1c1f:	mov    rbx,rdi
    1c22:	mov    QWORD PTR [rsp+0x8],0x0
    1c2b:	mov    QWORD PTR [rsp+0x10],0x0
    1c34:	mov    QWORD PTR [rsp+0x18],0x0
    1c3d:	mov    QWORD PTR [rsp],rsi
    1c41:	mov    r12,rsi
    1c44:	mov    rsi,r12
    1c47:	mov    rdi,rbx
    1c4a:	call   1c4f <botlish_fn_19+0x47>
			1c4b: R_X86_64_PLT32	rt_str_len-0x4
    1c4f:	sar    rax,1
    1c52:	test   rax,rax
    1c55:	je     1ce4 <botlish_fn_19+0xdc>
    1c5b:	mov    edx,0x1
    1c60:	mov    QWORD PTR [rsp+0x8],0x1
    1c69:	mov    rsi,r12
    1c6c:	mov    rdi,rbx
    1c6f:	call   1c74 <botlish_fn_19+0x6c>
			1c70: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1c74:	test   rax,rax
    1c77:	je     1cfb <botlish_fn_19+0xf3>
    1c7d:	mov    QWORD PTR [rsp+0x8],rax
    1c82:	mov    rsi,rax
    1c85:	mov    QWORD PTR [rsp+0x10],rdx
    1c8a:	mov    r13,rdx
    1c8d:	mov    rdi,rbx
    1c90:	call   1c95 <botlish_fn_19+0x8d>
			1c91: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
    1c95:	test   rax,rax
    1c98:	je     1cfb <botlish_fn_19+0xf3>
    1c9e:	mov    QWORD PTR [rsp+0x8],rax
    1ca3:	mov    rcx,rax
    1ca6:	mov    r8d,0x3
    1cac:	mov    QWORD PTR [rsp+0x18],0x3
    1cb5:	mov    rdx,r13
    1cb8:	mov    rsi,r12
    1cbb:	mov    rdi,rbx
    1cbe:	call   1cc3 <botlish_fn_19+0xbb>
			1cbf: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1cc3:	test   rax,rax
    1cc6:	je     1cfb <botlish_fn_19+0xf3>
    1ccc:	mov    rbx,QWORD PTR [rsp+0x20]
    1cd1:	mov    r12,QWORD PTR [rsp+0x28]
    1cd6:	mov    r13,QWORD PTR [rsp+0x30]
    1cdb:	add    rsp,0x40
    1cdf:	mov    rsp,rbp
    1ce2:	pop    rbp
    1ce3:	ret
    1ce4:	xor    rdx,rdx
    1ce7:	mov    rdi,rbx
    1cea:	mov    rsi,rdx
    1ced:	call   1cf2 <botlish_fn_19+0xea>
			1cee: R_X86_64_PLT32	rt_list_new-0x4
    1cf2:	test   rax,rax
    1cf5:	jne    1d16 <botlish_fn_19+0x10e>
    1cfb:	xor    rax,rax
    1cfe:	mov    rbx,QWORD PTR [rsp+0x20]
    1d03:	mov    r12,QWORD PTR [rsp+0x28]
    1d08:	mov    r13,QWORD PTR [rsp+0x30]
    1d0d:	add    rsp,0x40
    1d11:	mov    rsp,rbp
    1d14:	pop    rbp
    1d15:	ret
    1d16:	mov    rbx,QWORD PTR [rsp+0x20]
    1d1b:	mov    r12,QWORD PTR [rsp+0x28]
    1d20:	mov    r13,QWORD PTR [rsp+0x30]
    1d25:	add    rsp,0x40
    1d29:	mov    rsp,rbp
    1d2c:	pop    rbp
    1d2d:	ret

0000000000001d2e <botlish_entry_19: csv_parse<str>>:
    1d2e:	push   rbp
    1d2f:	mov    rbp,rsp
    1d32:	mov    rsi,QWORD PTR [rdx]
    1d35:	call   1d3a <botlish_entry_19+0xc>
			1d36: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    1d3a:	mov    rsp,rbp
    1d3d:	pop    rbp
    1d3e:	ret

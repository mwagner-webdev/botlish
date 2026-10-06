; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7877  (per function: 312 453 453 81 81 357 412 412 279 279 81 365 438 585 1141 352 783 215 480 318)
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
     bcf:	mov    rbx,rdx
     bd2:	mov    r13,rdi
     bd5:	mov    QWORD PTR [rsp],rsi
     bd9:	mov    QWORD PTR [rsp+0x8],rdx
     bde:	mov    rdx,QWORD PTR [rsi+0x8]
     be2:	mov    r12,rsi
     be5:	shl    rdx,1
     be8:	mov    rax,rdx
     beb:	or     rax,0x1
     bef:	mov    rcx,rbx
     bf2:	and    rcx,rax
     bf5:	test   rcx,0x1
     bfc:	jne    c26 <botlish_fn_11+0x6e>
     c02:	or     rdx,0x1
     c06:	mov    rsi,rbx
     c09:	mov    rdi,r13
     c0c:	call   c11 <botlish_fn_11+0x59>
			c0d: R_X86_64_PLT32	rt_int_cmp-0x4
     c11:	mov    ecx,0x2
     c16:	test   rax,rax
     c19:	cmovge rcx,QWORD PTR [rip+0xd7]        # cf8 <botlish_fn_11+0x140>
     c21:	jmp    c3a <botlish_fn_11+0x82>
     c26:	or     rdx,0x1
     c2a:	mov    ecx,0x2
     c2f:	cmp    rbx,rdx
     c32:	cmovge rcx,QWORD PTR [rip+0xbe]        # cf8 <botlish_fn_11+0x140>
     c3a:	cmp    rcx,0x6
     c3e:	je     cce <botlish_fn_11+0x116>
     c44:	mov    QWORD PTR [rsp+0x10],0x3
     c4d:	test   rbx,0x1
     c54:	je     c6c <botlish_fn_11+0xb4>
     c5a:	mov    rcx,rbx
     c5d:	add    rcx,0x2
     c61:	seto   al
     c64:	test   al,al
     c66:	je     c7f <botlish_fn_11+0xc7>
     c6c:	mov    edx,0x3
     c71:	mov    rsi,rbx
     c74:	mov    rdi,r13
     c77:	call   c7c <botlish_fn_11+0xc4>
			c78: R_X86_64_PLT32	rt_int_add-0x4
     c7c:	mov    rcx,rax
     c7f:	mov    QWORD PTR [rsp+0x10],rcx
     c84:	mov    rdx,rbx
     c87:	mov    rsi,r12
     c8a:	mov    rdi,r13
     c8d:	call   c92 <botlish_fn_11+0xda>
			c8e: R_X86_64_PLT32	rt_substr-0x4
     c92:	test   rax,rax
     c95:	jne    cb6 <botlish_fn_11+0xfe>
     c9b:	xor    rax,rax
     c9e:	mov    rbx,QWORD PTR [rsp+0x20]
     ca3:	mov    r12,QWORD PTR [rsp+0x28]
     ca8:	mov    r13,QWORD PTR [rsp+0x30]
     cad:	add    rsp,0x40
     cb1:	mov    rsp,rbp
     cb4:	pop    rbp
     cb5:	ret
     cb6:	mov    rbx,QWORD PTR [rsp+0x20]
     cbb:	mov    r12,QWORD PTR [rsp+0x28]
     cc0:	mov    r13,QWORD PTR [rsp+0x30]
     cc5:	add    rsp,0x40
     cc9:	mov    rsp,rbp
     ccc:	pop    rbp
     ccd:	ret
     cce:	mov    rdi,r13
     cd1:	mov    rax,QWORD PTR [rdi+0x10]
     cd5:	mov    rax,QWORD PTR [rax+0x10]
     cd9:	mov    rbx,QWORD PTR [rsp+0x20]
     cde:	mov    r12,QWORD PTR [rsp+0x28]
     ce3:	mov    r13,QWORD PTR [rsp+0x30]
     ce8:	add    rsp,0x40
     cec:	mov    rsp,rbp
     cef:	pop    rbp
     cf0:	ret
     cf1:	add    BYTE PTR [rax],al
     cf3:	add    BYTE PTR [rax],al
     cf5:	add    BYTE PTR [rax],al
     cf7:	add    BYTE PTR [rsi],al
     cf9:	add    BYTE PTR [rax],al
     cfb:	add    BYTE PTR [rax],al
     cfd:	add    BYTE PTR [rax],al
	...

0000000000000d00 <botlish_entry_11: peek<str, int>>:
     d00:	push   rbp
     d01:	mov    rbp,rsp
     d04:	mov    rsi,QWORD PTR [rdx]
     d07:	mov    rdx,QWORD PTR [rdx+0x8]
     d0b:	call   d10 <botlish_entry_11+0x10>
			d0c: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
     d10:	mov    rsp,rbp
     d13:	pop    rbp
     d14:	ret
     d15:	add    BYTE PTR [rax],al
	...

0000000000000d18 <botlish_fn_12: peek<str, int>>:
     d18:	push   rbp
     d19:	mov    rbp,rsp
     d1c:	sub    rsp,0x50
     d20:	mov    QWORD PTR [rsp+0x20],rbx
     d25:	mov    QWORD PTR [rsp+0x28],r12
     d2a:	mov    QWORD PTR [rsp+0x30],r13
     d2f:	mov    QWORD PTR [rsp+0x38],r14
     d34:	mov    QWORD PTR [rsp+0x40],r15
     d39:	mov    rbx,rdx
     d3c:	mov    r12,rcx
     d3f:	mov    r14,rdi
     d42:	mov    QWORD PTR [rsp],rsi
     d46:	mov    QWORD PTR [rsp+0x8],rdx
     d4b:	mov    rdx,QWORD PTR [rsi+0x8]
     d4f:	mov    r13,rsi
     d52:	shl    rdx,1
     d55:	mov    rax,rdx
     d58:	or     rax,0x1
     d5c:	mov    rcx,rbx
     d5f:	and    rcx,rax
     d62:	test   rcx,0x1
     d69:	jne    d93 <botlish_fn_12+0x7b>
     d6f:	or     rdx,0x1
     d73:	mov    rsi,rbx
     d76:	mov    rdi,r14
     d79:	call   d7e <botlish_fn_12+0x66>
			d7a: R_X86_64_PLT32	rt_int_cmp-0x4
     d7e:	mov    ecx,0x2
     d83:	test   rax,rax
     d86:	cmovge rcx,QWORD PTR [rip+0x122]        # eb0 <botlish_fn_12+0x198>
     d8e:	jmp    da7 <botlish_fn_12+0x8f>
     d93:	or     rdx,0x1
     d97:	mov    ecx,0x2
     d9c:	cmp    rbx,rdx
     d9f:	cmovge rcx,QWORD PTR [rip+0x109]        # eb0 <botlish_fn_12+0x198>
     da7:	cmp    rcx,0x6
     dab:	je     e6b <botlish_fn_12+0x153>
     db1:	mov    QWORD PTR [rsp+0x10],0x3
     dba:	test   rbx,0x1
     dc1:	je     de4 <botlish_fn_12+0xcc>
     dc7:	mov    rax,rbx
     dca:	add    rax,0x2
     dce:	seto   cl
     dd1:	test   cl,cl
     dd3:	jne    de4 <botlish_fn_12+0xcc>
     dd9:	mov    rdi,r14
     ddc:	mov    r15,rax
     ddf:	jmp    dfa <botlish_fn_12+0xe2>
     de4:	mov    edx,0x3
     de9:	mov    rsi,rbx
     dec:	mov    rdi,r14
     def:	call   df4 <botlish_fn_12+0xdc>
			df0: R_X86_64_PLT32	rt_int_add-0x4
     df4:	mov    r15,rax
     df7:	mov    rdi,r14
     dfa:	mov    rdi,r14
     dfd:	mov    rcx,r15
     e00:	mov    rdx,rbx
     e03:	mov    rsi,r13
     e06:	call   e0b <botlish_fn_12+0xf3>
			e07: R_X86_64_PLT32	rt_str_region_check-0x4
     e0b:	test   rax,rax
     e0e:	jne    e39 <botlish_fn_12+0x121>
     e14:	xor    rax,rax
     e17:	mov    rbx,QWORD PTR [rsp+0x20]
     e1c:	mov    r12,QWORD PTR [rsp+0x28]
     e21:	mov    r13,QWORD PTR [rsp+0x30]
     e26:	mov    r14,QWORD PTR [rsp+0x38]
     e2b:	mov    r15,QWORD PTR [rsp+0x40]
     e30:	add    rsp,0x50
     e34:	mov    rsp,rbp
     e37:	pop    rbp
     e38:	ret
     e39:	mov    rcx,r12
     e3c:	mov    QWORD PTR [rcx],rbx
     e3f:	mov    rax,r15
     e42:	mov    QWORD PTR [rcx+0x8],rax
     e46:	mov    rax,r13
     e49:	mov    rbx,QWORD PTR [rsp+0x20]
     e4e:	mov    r12,QWORD PTR [rsp+0x28]
     e53:	mov    r13,QWORD PTR [rsp+0x30]
     e58:	mov    r14,QWORD PTR [rsp+0x38]
     e5d:	mov    r15,QWORD PTR [rsp+0x40]
     e62:	add    rsp,0x50
     e66:	mov    rsp,rbp
     e69:	pop    rbp
     e6a:	ret
     e6b:	mov    rcx,r12
     e6e:	mov    rdi,r14
     e71:	mov    rax,QWORD PTR [rdi+0x10]
     e75:	mov    rax,QWORD PTR [rax+0x10]
     e79:	mov    QWORD PTR [rcx],0x1
     e80:	mov    QWORD PTR [rcx+0x8],0x1
     e88:	mov    rbx,QWORD PTR [rsp+0x20]
     e8d:	mov    r12,QWORD PTR [rsp+0x28]
     e92:	mov    r13,QWORD PTR [rsp+0x30]
     e97:	mov    r14,QWORD PTR [rsp+0x38]
     e9c:	mov    r15,QWORD PTR [rsp+0x40]
     ea1:	add    rsp,0x50
     ea5:	mov    rsp,rbp
     ea8:	pop    rbp
     ea9:	ret
     eaa:	add    BYTE PTR [rax],al
     eac:	add    BYTE PTR [rax],al
     eae:	add    BYTE PTR [rax],al
     eb0:	(bad)
     eb1:	add    BYTE PTR [rax],al
     eb3:	add    BYTE PTR [rax],al
     eb5:	add    BYTE PTR [rax],al
	...

0000000000000eb8 <botlish_entry_12: peek<str, int>>:
     eb8:	push   rbp
     eb9:	mov    rbp,rsp
     ebc:	ud2

0000000000000ebe <botlish_fn_13: scan_unquoted<str, int, int>>:
     ebe:	push   rbp
     ebf:	mov    rbp,rsp
     ec2:	sub    rsp,0x80
     ec9:	mov    QWORD PTR [rsp+0x50],rbx
     ece:	mov    QWORD PTR [rsp+0x58],r12
     ed3:	mov    QWORD PTR [rsp+0x60],r13
     ed8:	mov    QWORD PTR [rsp+0x68],r14
     edd:	mov    QWORD PTR [rsp+0x70],r15
     ee2:	mov    QWORD PTR [rsp+0x30],rdi
     ee7:	mov    QWORD PTR [rsp+0x18],0x0
     ef0:	mov    QWORD PTR [rsp],rsi
     ef4:	mov    r15,rsi
     ef7:	mov    QWORD PTR [rsp+0x8],rdx
     efc:	mov    r14,rdx
     eff:	mov    QWORD PTR [rsp+0x10],rcx
     f04:	lea    r13,[rsp+0x20]
     f09:	mov    QWORD PTR [rsp+0x38],rcx
     f0e:	mov    rcx,r13
     f11:	mov    rdx,QWORD PTR [rsp+0x38]
     f16:	mov    rsi,r15
     f19:	mov    rdi,QWORD PTR [rsp+0x30]
     f1e:	call   f23 <botlish_fn_13+0x65>
			f1f: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     f23:	mov    rsi,rax
     f26:	mov    QWORD PTR [rsp+0x40],rax
     f2b:	test   rax,rsi
     f2e:	je     1088 <botlish_fn_13+0x1ca>
     f34:	mov    rbx,QWORD PTR [rsp+0x20]
     f39:	mov    r12,QWORD PTR [rsp+0x28]
     f3e:	mov    rdi,QWORD PTR [rsp+0x30]
     f43:	mov    rcx,QWORD PTR [rdi+0x10]
     f47:	mov    r8,QWORD PTR [rcx+0x10]
     f4b:	mov    rcx,r12
     f4e:	mov    rdx,rbx
     f51:	mov    rsi,QWORD PTR [rsp+0x40]
     f56:	call   f5b <botlish_fn_13+0x9d>
			f57: R_X86_64_PLT32	rt_str_region_eq-0x4
     f5b:	cmp    rax,0x6
     f5f:	je     fa0 <botlish_fn_13+0xe2>
     f65:	mov    rdi,QWORD PTR [rsp+0x30]
     f6a:	mov    rax,QWORD PTR [rdi+0x10]
     f6e:	mov    r8,QWORD PTR [rax+0x18]
     f72:	mov    rcx,r12
     f75:	mov    rdx,rbx
     f78:	mov    rsi,QWORD PTR [rsp+0x40]
     f7d:	call   f82 <botlish_fn_13+0xc4>
			f7e: R_X86_64_PLT32	rt_str_region_eq-0x4
     f82:	cmp    rax,0x6
     f86:	je     f96 <botlish_fn_13+0xd8>
     f8c:	mov    eax,0x2
     f91:	jmp    fa5 <botlish_fn_13+0xe7>
     f96:	mov    eax,0x6
     f9b:	jmp    fa5 <botlish_fn_13+0xe7>
     fa0:	mov    eax,0x6
     fa5:	cmp    rax,0x6
     fa9:	je     fea <botlish_fn_13+0x12c>
     faf:	mov    rdi,QWORD PTR [rsp+0x30]
     fb4:	mov    rax,QWORD PTR [rdi+0x10]
     fb8:	mov    r8,QWORD PTR [rax+0x20]
     fbc:	mov    rcx,r12
     fbf:	mov    rdx,rbx
     fc2:	mov    rsi,QWORD PTR [rsp+0x40]
     fc7:	call   fcc <botlish_fn_13+0x10e>
			fc8: R_X86_64_PLT32	rt_str_region_eq-0x4
     fcc:	cmp    rax,0x6
     fd0:	je     fe0 <botlish_fn_13+0x122>
     fd6:	mov    eax,0x2
     fdb:	jmp    fef <botlish_fn_13+0x131>
     fe0:	mov    eax,0x6
     fe5:	jmp    fef <botlish_fn_13+0x131>
     fea:	mov    eax,0x6
     fef:	cmp    rax,0x6
     ff3:	je     106a <botlish_fn_13+0x1ac>
     ff9:	mov    QWORD PTR [rsp+0x18],0x3
    1002:	mov    rsi,QWORD PTR [rsp+0x38]
    1007:	test   rsi,0x1
    100e:	je     1035 <botlish_fn_13+0x177>
    1014:	mov    rsi,QWORD PTR [rsp+0x38]
    1019:	mov    rax,rsi
    101c:	add    rax,0x2
    1020:	seto   sil
    1024:	test   sil,sil
    1027:	jne    1035 <botlish_fn_13+0x177>
    102d:	mov    rsi,r15
    1030:	jmp    104c <botlish_fn_13+0x18e>
    1035:	mov    edx,0x3
    103a:	mov    rsi,QWORD PTR [rsp+0x38]
    103f:	mov    rdi,QWORD PTR [rsp+0x30]
    1044:	call   1049 <botlish_fn_13+0x18b>
			1045: R_X86_64_PLT32	rt_int_add-0x4
    1049:	mov    rsi,r15
    104c:	mov    QWORD PTR [rsp],rsi
    1050:	mov    rdx,r14
    1053:	mov    QWORD PTR [rsp+0x8],rdx
    1058:	mov    QWORD PTR [rsp+0x10],rax
    105d:	mov    r15,rsi
    1060:	mov    QWORD PTR [rsp+0x38],rax
    1065:	jmp    f0e <botlish_fn_13+0x50>
    106a:	mov    rdx,r14
    106d:	mov    rsi,r15
    1070:	mov    rdi,QWORD PTR [rsp+0x30]
    1075:	mov    rcx,QWORD PTR [rsp+0x38]
    107a:	call   107f <botlish_fn_13+0x1c1>
			107b: R_X86_64_PLT32	rt_substr-0x4
    107f:	test   rax,rax
    1082:	jne    10b3 <botlish_fn_13+0x1f5>
    1088:	xor    rdx,rdx
    108b:	mov    rax,rdx
    108e:	mov    rbx,QWORD PTR [rsp+0x50]
    1093:	mov    r12,QWORD PTR [rsp+0x58]
    1098:	mov    r13,QWORD PTR [rsp+0x60]
    109d:	mov    r14,QWORD PTR [rsp+0x68]
    10a2:	mov    r15,QWORD PTR [rsp+0x70]
    10a7:	add    rsp,0x80
    10ae:	mov    rsp,rbp
    10b1:	pop    rbp
    10b2:	ret
    10b3:	mov    rdx,QWORD PTR [rsp+0x38]
    10b8:	mov    rbx,QWORD PTR [rsp+0x50]
    10bd:	mov    r12,QWORD PTR [rsp+0x58]
    10c2:	mov    r13,QWORD PTR [rsp+0x60]
    10c7:	mov    r14,QWORD PTR [rsp+0x68]
    10cc:	mov    r15,QWORD PTR [rsp+0x70]
    10d1:	add    rsp,0x80
    10d8:	mov    rsp,rbp
    10db:	pop    rbp
    10dc:	ret

00000000000010dd <botlish_entry_13: scan_unquoted<str, int, int>>:
    10dd:	push   rbp
    10de:	mov    rbp,rsp
    10e1:	ud2

00000000000010e3 <botlish_fn_14: scan_quoted<str, int, str>>:
    10e3:	push   rbp
    10e4:	mov    rbp,rsp
    10e7:	sub    rsp,0xd0
    10ee:	mov    QWORD PTR [rsp+0xa0],rbx
    10f6:	mov    QWORD PTR [rsp+0xa8],r12
    10fe:	mov    QWORD PTR [rsp+0xb0],r13
    1106:	mov    QWORD PTR [rsp+0xb8],r14
    110e:	mov    QWORD PTR [rsp+0xc0],r15
    1116:	mov    QWORD PTR [rsp+0x88],rdi
    111e:	mov    QWORD PTR [rsp+0x18],0x0
    1127:	mov    QWORD PTR [rsp+0x20],0x0
    1130:	mov    QWORD PTR [rsp],rsi
    1134:	mov    QWORD PTR [rsp+0x8],rdx
    1139:	mov    QWORD PTR [rsp+0x10],rcx
    113e:	mov    r13,rcx
    1141:	lea    r14,[rsp+0x68]
    1146:	lea    rbx,[rsp+0x28]
    114b:	mov    r12,rsi
    114e:	mov    QWORD PTR [rsp+0x90],rdx
    1156:	mov    rdx,QWORD PTR [rsp+0x90]
    115e:	mov    rsi,r12
    1161:	mov    rdi,QWORD PTR [rsp+0x88]
    1169:	call   116e <botlish_fn_14+0x8b>
			116a: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    116e:	test   rax,rax
    1171:	je     14ba <botlish_fn_14+0x3d7>
    1177:	mov    QWORD PTR [rsp+0x18],rax
    117c:	mov    rsi,QWORD PTR [rax+0x8]
    1180:	mov    rcx,rax
    1183:	mov    rax,0xffffffffffffffff
    118a:	test   rsi,rsi
    118d:	jne    119b <botlish_fn_14+0xb8>
    1193:	mov    r15,rcx
    1196:	jmp    11c6 <botlish_fn_14+0xe3>
    119b:	mov    r15,rcx
    119e:	movzx  rdi,BYTE PTR [r15+0x18]
    11a3:	test   rdi,rdi
    11a6:	jne    11c1 <botlish_fn_14+0xde>
    11ac:	mov    rsi,r15
    11af:	mov    rdi,QWORD PTR [rsp+0x88]
    11b7:	call   11bc <botlish_fn_14+0xd9>
			11b8: R_X86_64_PLT32	rt_str_to_short-0x4
    11bc:	jmp    11c6 <botlish_fn_14+0xe3>
    11c1:	movzx  rax,BYTE PTR [r15+0x19]
    11c6:	cmp    rax,0x22
    11ca:	je     128a <botlish_fn_14+0x1a7>
    11d0:	mov    QWORD PTR [rsp+0x20],0x3
    11d9:	mov    rsi,QWORD PTR [rsp+0x90]
    11e1:	test   rsi,0x1
    11e8:	je     1208 <botlish_fn_14+0x125>
    11ee:	mov    rax,rsi
    11f1:	add    rax,0x2
    11f5:	seto   cl
    11f8:	test   cl,cl
    11fa:	jne    1208 <botlish_fn_14+0x125>
    1200:	mov    rsi,rax
    1203:	jmp    121d <botlish_fn_14+0x13a>
    1208:	mov    edx,0x3
    120d:	mov    rdi,QWORD PTR [rsp+0x88]
    1215:	call   121a <botlish_fn_14+0x137>
			1216: R_X86_64_PLT32	rt_int_add-0x4
    121a:	mov    rsi,rax
    121d:	mov    QWORD PTR [rsp+0x8],rsi
    1222:	mov    QWORD PTR [rsp+0x90],rsi
    122a:	mov    QWORD PTR [rsp+0x68],0x0
    1233:	mov    QWORD PTR [rsp+0x70],r13
    1238:	mov    QWORD PTR [rsp+0x78],0x0
    1241:	mov    QWORD PTR [rsp+0x80],r15
    1249:	mov    esi,0x2
    124e:	mov    edx,0x4
    1253:	mov    rcx,r14
    1256:	mov    rdi,QWORD PTR [rsp+0x88]
    125e:	call   1263 <botlish_fn_14+0x180>
			125f: R_X86_64_PLT32	rt_construct-0x4
    1263:	test   rax,rax
    1266:	je     14ba <botlish_fn_14+0x3d7>
    126c:	mov    QWORD PTR [rsp],r12
    1270:	mov    rsi,QWORD PTR [rsp+0x90]
    1278:	mov    QWORD PTR [rsp+0x8],rsi
    127d:	mov    QWORD PTR [rsp+0x10],rax
    1282:	mov    r13,rax
    1285:	jmp    1156 <botlish_fn_14+0x73>
    128a:	mov    QWORD PTR [rsp+0x18],0x3
    1293:	mov    rsi,QWORD PTR [rsp+0x90]
    129b:	test   rsi,0x1
    12a2:	je     12c2 <botlish_fn_14+0x1df>
    12a8:	mov    rsi,QWORD PTR [rsp+0x90]
    12b0:	mov    rdx,rsi
    12b3:	add    rdx,0x2
    12b7:	seto   al
    12ba:	test   al,al
    12bc:	je     12df <botlish_fn_14+0x1fc>
    12c2:	mov    edx,0x3
    12c7:	mov    rsi,QWORD PTR [rsp+0x90]
    12cf:	mov    rdi,QWORD PTR [rsp+0x88]
    12d7:	call   12dc <botlish_fn_14+0x1f9>
			12d8: R_X86_64_PLT32	rt_int_add-0x4
    12dc:	mov    rdx,rax
    12df:	mov    QWORD PTR [rsp+0x18],rdx
    12e4:	mov    rcx,rbx
    12e7:	mov    rsi,r12
    12ea:	mov    rdi,QWORD PTR [rsp+0x88]
    12f2:	call   12f7 <botlish_fn_14+0x214>
			12f3: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    12f7:	test   rax,rax
    12fa:	mov    rsi,rax
    12fd:	je     14ba <botlish_fn_14+0x3d7>
    1303:	mov    rdx,QWORD PTR [rsp+0x28]
    1308:	mov    rcx,QWORD PTR [rsp+0x30]
    130d:	mov    rdi,QWORD PTR [rsp+0x88]
    1315:	mov    rax,QWORD PTR [rdi+0x10]
    1319:	mov    r8,QWORD PTR [rax+0x28]
    131d:	call   1322 <botlish_fn_14+0x23f>
			131e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1322:	cmp    rax,0x6
    1326:	je     13f8 <botlish_fn_14+0x315>
    132c:	xor    rsi,rsi
    132f:	lea    rcx,[rsp+0x58]
    1334:	mov    QWORD PTR [rsp+0x58],0x0
    133d:	mov    QWORD PTR [rsp+0x60],r13
    1342:	mov    edx,0x2
    1347:	mov    rdi,QWORD PTR [rsp+0x88]
    134f:	call   1354 <botlish_fn_14+0x271>
			1350: R_X86_64_PLT32	rt_construct-0x4
    1354:	test   rax,rax
    1357:	je     14ba <botlish_fn_14+0x3d7>
    135d:	mov    QWORD PTR [rsp],rax
    1361:	mov    rbx,rax
    1364:	mov    QWORD PTR [rsp+0x10],0x3
    136d:	mov    rsi,QWORD PTR [rsp+0x90]
    1375:	test   rsi,0x1
    137c:	je     13a4 <botlish_fn_14+0x2c1>
    1382:	mov    rsi,QWORD PTR [rsp+0x90]
    138a:	mov    rdx,rsi
    138d:	add    rdx,0x2
    1391:	seto   al
    1394:	test   al,al
    1396:	jne    13a4 <botlish_fn_14+0x2c1>
    139c:	mov    rax,rbx
    139f:	jmp    13c4 <botlish_fn_14+0x2e1>
    13a4:	mov    edx,0x3
    13a9:	mov    rsi,QWORD PTR [rsp+0x90]
    13b1:	mov    rdi,QWORD PTR [rsp+0x88]
    13b9:	call   13be <botlish_fn_14+0x2db>
			13ba: R_X86_64_PLT32	rt_int_add-0x4
    13be:	mov    rdx,rax
    13c1:	mov    rax,rbx
    13c4:	mov    rbx,QWORD PTR [rsp+0xa0]
    13cc:	mov    r12,QWORD PTR [rsp+0xa8]
    13d4:	mov    r13,QWORD PTR [rsp+0xb0]
    13dc:	mov    r14,QWORD PTR [rsp+0xb8]
    13e4:	mov    r15,QWORD PTR [rsp+0xc0]
    13ec:	add    rsp,0xd0
    13f3:	mov    rsp,rbp
    13f6:	pop    rbp
    13f7:	ret
    13f8:	mov    QWORD PTR [rsp+0x18],0x5
    1401:	mov    rsi,QWORD PTR [rsp+0x90]
    1409:	test   rsi,0x1
    1410:	je     1442 <botlish_fn_14+0x35f>
    1416:	mov    rsi,QWORD PTR [rsp+0x90]
    141e:	mov    rdi,rsi
    1421:	add    rdi,0x4
    1425:	seto   r9b
    1429:	test   r9b,r9b
    142c:	jne    1442 <botlish_fn_14+0x35f>
    1432:	mov    rsi,rdi
    1435:	mov    QWORD PTR [rsp+0x90],rdi
    143d:	jmp    1467 <botlish_fn_14+0x384>
    1442:	mov    edx,0x5
    1447:	mov    rsi,QWORD PTR [rsp+0x90]
    144f:	mov    rdi,QWORD PTR [rsp+0x88]
    1457:	call   145c <botlish_fn_14+0x379>
			1458: R_X86_64_PLT32	rt_int_add-0x4
    145c:	mov    rsi,rax
    145f:	mov    QWORD PTR [rsp+0x90],rax
    1467:	mov    QWORD PTR [rsp+0x8],rsi
    146c:	mov    rdi,QWORD PTR [rsp+0x88]
    1474:	mov    rax,QWORD PTR [rdi+0x10]
    1478:	mov    rax,QWORD PTR [rax+0x28]
    147c:	mov    QWORD PTR [rsp+0x18],rax
    1481:	lea    rcx,[rsp+0x38]
    1486:	mov    QWORD PTR [rsp+0x38],0x0
    148f:	mov    QWORD PTR [rsp+0x40],r13
    1494:	mov    QWORD PTR [rsp+0x48],0x0
    149d:	mov    QWORD PTR [rsp+0x50],rax
    14a2:	mov    esi,0x2
    14a7:	mov    edx,0x4
    14ac:	call   14b1 <botlish_fn_14+0x3ce>
			14ad: R_X86_64_PLT32	rt_construct-0x4
    14b1:	test   rax,rax
    14b4:	jne    14f4 <botlish_fn_14+0x411>
    14ba:	xor    rdx,rdx
    14bd:	mov    rax,rdx
    14c0:	mov    rbx,QWORD PTR [rsp+0xa0]
    14c8:	mov    r12,QWORD PTR [rsp+0xa8]
    14d0:	mov    r13,QWORD PTR [rsp+0xb0]
    14d8:	mov    r14,QWORD PTR [rsp+0xb8]
    14e0:	mov    r15,QWORD PTR [rsp+0xc0]
    14e8:	add    rsp,0xd0
    14ef:	mov    rsp,rbp
    14f2:	pop    rbp
    14f3:	ret
    14f4:	mov    QWORD PTR [rsp],r12
    14f8:	mov    rsi,QWORD PTR [rsp+0x90]
    1500:	mov    QWORD PTR [rsp+0x8],rsi
    1505:	mov    QWORD PTR [rsp+0x10],rax
    150a:	mov    r13,rax
    150d:	jmp    1156 <botlish_fn_14+0x73>

0000000000001512 <botlish_entry_14: scan_quoted<str, int, str>>:
    1512:	push   rbp
    1513:	mov    rbp,rsp
    1516:	ud2

0000000000001518 <botlish_fn_15: scan_field<str, int>>:
    1518:	push   rbp
    1519:	mov    rbp,rsp
    151c:	sub    rsp,0x50
    1520:	mov    QWORD PTR [rsp+0x30],rbx
    1525:	mov    QWORD PTR [rsp+0x38],r12
    152a:	mov    QWORD PTR [rsp+0x40],r13
    152f:	mov    r12,rdi
    1532:	mov    r13,rdx
    1535:	mov    QWORD PTR [rsp+0x10],0x0
    153e:	mov    QWORD PTR [rsp],rsi
    1542:	mov    rbx,rsi
    1545:	mov    QWORD PTR [rsp+0x8],rdx
    154a:	lea    rcx,[rsp+0x18]
    154f:	mov    rdx,r13
    1552:	mov    rsi,rbx
    1555:	mov    rdi,r12
    1558:	call   155d <botlish_fn_15+0x45>
			1559: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    155d:	test   rax,rax
    1560:	mov    rsi,rax
    1563:	je     162e <botlish_fn_15+0x116>
    1569:	mov    rdx,QWORD PTR [rsp+0x18]
    156e:	mov    rcx,QWORD PTR [rsp+0x20]
    1573:	mov    rdi,r12
    1576:	mov    rax,QWORD PTR [rdi+0x10]
    157a:	mov    r8,QWORD PTR [rax+0x28]
    157e:	call   1583 <botlish_fn_15+0x6b>
			157f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1583:	cmp    rax,0x6
    1587:	je     15bf <botlish_fn_15+0xa7>
    158d:	mov    rcx,r13
    1590:	mov    rsi,rbx
    1593:	mov    rdi,r12
    1596:	mov    rdx,rcx
    1599:	call   159e <botlish_fn_15+0x86>
			159a: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    159e:	test   rax,rax
    15a1:	je     162e <botlish_fn_15+0x116>
    15a7:	mov    rbx,QWORD PTR [rsp+0x30]
    15ac:	mov    r12,QWORD PTR [rsp+0x38]
    15b1:	mov    r13,QWORD PTR [rsp+0x40]
    15b6:	add    rsp,0x50
    15ba:	mov    rsp,rbp
    15bd:	pop    rbp
    15be:	ret
    15bf:	mov    rcx,r13
    15c2:	mov    QWORD PTR [rsp+0x10],0x3
    15cb:	test   rcx,0x1
    15d2:	jne    15e0 <botlish_fn_15+0xc8>
    15d8:	mov    r13,rcx
    15db:	jmp    15f5 <botlish_fn_15+0xdd>
    15e0:	mov    rdx,rcx
    15e3:	add    rdx,0x2
    15e7:	mov    r13,rcx
    15ea:	seto   al
    15ed:	test   al,al
    15ef:	je     1608 <botlish_fn_15+0xf0>
    15f5:	mov    edx,0x3
    15fa:	mov    rsi,r13
    15fd:	mov    rdi,r12
    1600:	call   1605 <botlish_fn_15+0xed>
			1601: R_X86_64_PLT32	rt_int_add-0x4
    1605:	mov    rdx,rax
    1608:	mov    QWORD PTR [rsp+0x8],rdx
    160d:	mov    rdi,r12
    1610:	mov    rax,QWORD PTR [rdi+0x10]
    1614:	mov    rcx,QWORD PTR [rax+0x10]
    1618:	mov    QWORD PTR [rsp+0x10],rcx
    161d:	mov    rsi,rbx
    1620:	call   1625 <botlish_fn_15+0x10d>
			1621: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1625:	test   rax,rax
    1628:	jne    164c <botlish_fn_15+0x134>
    162e:	xor    rdx,rdx
    1631:	mov    rax,rdx
    1634:	mov    rbx,QWORD PTR [rsp+0x30]
    1639:	mov    r12,QWORD PTR [rsp+0x38]
    163e:	mov    r13,QWORD PTR [rsp+0x40]
    1643:	add    rsp,0x50
    1647:	mov    rsp,rbp
    164a:	pop    rbp
    164b:	ret
    164c:	mov    rbx,QWORD PTR [rsp+0x30]
    1651:	mov    r12,QWORD PTR [rsp+0x38]
    1656:	mov    r13,QWORD PTR [rsp+0x40]
    165b:	add    rsp,0x50
    165f:	mov    rsp,rbp
    1662:	pop    rbp
    1663:	ret

0000000000001664 <botlish_entry_15: scan_field<str, int>>:
    1664:	push   rbp
    1665:	mov    rbp,rsp
    1668:	ud2

000000000000166a <botlish_fn_16: scan_record_rest<str, int, mutarray, int>>:
    166a:	push   rbp
    166b:	mov    rbp,rsp
    166e:	sub    rsp,0x90
    1675:	mov    QWORD PTR [rsp+0x60],rbx
    167a:	mov    QWORD PTR [rsp+0x68],r12
    167f:	mov    QWORD PTR [rsp+0x70],r13
    1684:	mov    QWORD PTR [rsp+0x78],r14
    1689:	mov    QWORD PTR [rsp+0x80],r15
    1691:	mov    r15,rdi
    1694:	mov    QWORD PTR [rsp+0x20],0x0
    169d:	mov    QWORD PTR [rsp],rsi
    16a1:	mov    QWORD PTR [rsp+0x8],rdx
    16a6:	mov    QWORD PTR [rsp+0x10],rcx
    16ab:	mov    QWORD PTR [rsp+0x18],r8
    16b0:	lea    r12,[rsp+0x28]
    16b5:	mov    rbx,rsi
    16b8:	mov    QWORD PTR [rsp+0x38],rdx
    16bd:	mov    QWORD PTR [rsp+0x40],rcx
    16c2:	mov    QWORD PTR [rsp+0x48],r8
    16c7:	mov    rcx,r12
    16ca:	mov    rdx,QWORD PTR [rsp+0x38]
    16cf:	mov    rsi,rbx
    16d2:	mov    rdi,r15
    16d5:	call   16da <botlish_fn_16+0x70>
			16d6: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    16da:	test   rax,rax
    16dd:	mov    QWORD PTR [rsp+0x50],rax
    16e2:	je     18a6 <botlish_fn_16+0x23c>
    16e8:	mov    r14,QWORD PTR [rsp+0x28]
    16ed:	mov    r13,QWORD PTR [rsp+0x30]
    16f2:	mov    rdi,r15
    16f5:	mov    rcx,QWORD PTR [rdi+0x10]
    16f9:	mov    r8,QWORD PTR [rcx+0x18]
    16fd:	mov    rcx,r13
    1700:	mov    rdx,r14
    1703:	mov    rsi,QWORD PTR [rsp+0x50]
    1708:	call   170d <botlish_fn_16+0xa3>
			1709: R_X86_64_PLT32	rt_str_region_eq-0x4
    170d:	cmp    rax,0x6
    1711:	je     181f <botlish_fn_16+0x1b5>
    1717:	mov    rdi,r15
    171a:	mov    rax,QWORD PTR [rdi+0x10]
    171e:	mov    r8,QWORD PTR [rax+0x20]
    1722:	mov    rcx,r13
    1725:	mov    rdx,r14
    1728:	mov    rsi,QWORD PTR [rsp+0x50]
    172d:	call   1732 <botlish_fn_16+0xc8>
			172e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1732:	cmp    rax,0x6
    1736:	je     1784 <botlish_fn_16+0x11a>
    173c:	mov    rdx,QWORD PTR [rsp+0x48]
    1741:	mov    rsi,QWORD PTR [rsp+0x40]
    1746:	mov    rdi,r15
    1749:	call   174e <botlish_fn_16+0xe4>
			174a: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    174e:	test   rax,rax
    1751:	je     18a6 <botlish_fn_16+0x23c>
    1757:	mov    rdx,QWORD PTR [rsp+0x38]
    175c:	mov    rbx,QWORD PTR [rsp+0x60]
    1761:	mov    r12,QWORD PTR [rsp+0x68]
    1766:	mov    r13,QWORD PTR [rsp+0x70]
    176b:	mov    r14,QWORD PTR [rsp+0x78]
    1770:	mov    r15,QWORD PTR [rsp+0x80]
    1778:	add    rsp,0x90
    177f:	mov    rsp,rbp
    1782:	pop    rbp
    1783:	ret
    1784:	mov    rdx,QWORD PTR [rsp+0x48]
    1789:	mov    rsi,QWORD PTR [rsp+0x40]
    178e:	mov    rdi,r15
    1791:	call   1796 <botlish_fn_16+0x12c>
			1792: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1796:	test   rax,rax
    1799:	je     18a6 <botlish_fn_16+0x23c>
    179f:	mov    QWORD PTR [rsp],rax
    17a3:	mov    rbx,rax
    17a6:	mov    QWORD PTR [rsp+0x10],0x3
    17af:	mov    rdx,QWORD PTR [rsp+0x38]
    17b4:	test   rdx,0x1
    17bb:	je     17df <botlish_fn_16+0x175>
    17c1:	mov    rdx,QWORD PTR [rsp+0x38]
    17c6:	add    rdx,0x2
    17ca:	seto   sil
    17ce:	test   sil,sil
    17d1:	jne    17df <botlish_fn_16+0x175>
    17d7:	mov    rax,rbx
    17da:	jmp    17f7 <botlish_fn_16+0x18d>
    17df:	mov    edx,0x3
    17e4:	mov    rsi,QWORD PTR [rsp+0x38]
    17e9:	mov    rdi,r15
    17ec:	call   17f1 <botlish_fn_16+0x187>
			17ed: R_X86_64_PLT32	rt_int_add-0x4
    17f1:	mov    rdx,rax
    17f4:	mov    rax,rbx
    17f7:	mov    rbx,QWORD PTR [rsp+0x60]
    17fc:	mov    r12,QWORD PTR [rsp+0x68]
    1801:	mov    r13,QWORD PTR [rsp+0x70]
    1806:	mov    r14,QWORD PTR [rsp+0x78]
    180b:	mov    r15,QWORD PTR [rsp+0x80]
    1813:	add    rsp,0x90
    181a:	mov    rsp,rbp
    181d:	pop    rbp
    181e:	ret
    181f:	mov    rsi,QWORD PTR [rsp+0x38]
    1824:	mov    edx,0x3
    1829:	mov    r13,rdx
    182c:	mov    QWORD PTR [rsp+0x20],0x3
    1835:	test   rsi,0x1
    183c:	je     1854 <botlish_fn_16+0x1ea>
    1842:	mov    rdx,rsi
    1845:	add    rdx,0x2
    1849:	seto   al
    184c:	test   al,al
    184e:	je     1862 <botlish_fn_16+0x1f8>
    1854:	mov    rdx,r13
    1857:	mov    rdi,r15
    185a:	call   185f <botlish_fn_16+0x1f5>
			185b: R_X86_64_PLT32	rt_int_add-0x4
    185f:	mov    rdx,rax
    1862:	mov    QWORD PTR [rsp+0x8],rdx
    1867:	mov    rsi,rbx
    186a:	mov    rdi,r15
    186d:	call   1872 <botlish_fn_16+0x208>
			186e: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1872:	test   rax,rax
    1875:	je     18a6 <botlish_fn_16+0x23c>
    187b:	mov    QWORD PTR [rsp+0x8],rax
    1880:	mov    rcx,rax
    1883:	mov    QWORD PTR [rsp+0x20],rdx
    1888:	mov    rsi,QWORD PTR [rsp+0x40]
    188d:	mov    r14,rdx
    1890:	mov    rdx,QWORD PTR [rsp+0x48]
    1895:	mov    rdi,r15
    1898:	call   189d <botlish_fn_16+0x233>
			1899: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    189d:	test   rax,rax
    18a0:	jne    18d4 <botlish_fn_16+0x26a>
    18a6:	xor    rdx,rdx
    18a9:	mov    rax,rdx
    18ac:	mov    rbx,QWORD PTR [rsp+0x60]
    18b1:	mov    r12,QWORD PTR [rsp+0x68]
    18b6:	mov    r13,QWORD PTR [rsp+0x70]
    18bb:	mov    r14,QWORD PTR [rsp+0x78]
    18c0:	mov    r15,QWORD PTR [rsp+0x80]
    18c8:	add    rsp,0x90
    18cf:	mov    rsp,rbp
    18d2:	pop    rbp
    18d3:	ret
    18d4:	mov    QWORD PTR [rsp+0x8],rax
    18d9:	mov    QWORD PTR [rsp+0x38],rax
    18de:	mov    QWORD PTR [rsp+0x10],0x3
    18e7:	mov    rdx,QWORD PTR [rsp+0x48]
    18ec:	test   rdx,0x1
    18f3:	jne    1906 <botlish_fn_16+0x29c>
    18f9:	mov    rdx,r13
    18fc:	mov    rsi,QWORD PTR [rsp+0x48]
    1901:	jmp    1925 <botlish_fn_16+0x2bb>
    1906:	mov    rdx,QWORD PTR [rsp+0x48]
    190b:	mov    rax,rdx
    190e:	add    rax,0x2
    1912:	seto   cl
    1915:	test   cl,cl
    1917:	je     192d <botlish_fn_16+0x2c3>
    191d:	mov    rdx,r13
    1920:	mov    rsi,QWORD PTR [rsp+0x48]
    1925:	mov    rdi,r15
    1928:	call   192d <botlish_fn_16+0x2c3>
			1929: R_X86_64_PLT32	rt_int_add-0x4
    192d:	mov    QWORD PTR [rsp],rbx
    1931:	mov    rdx,r14
    1934:	mov    QWORD PTR [rsp+0x8],rdx
    1939:	mov    rcx,QWORD PTR [rsp+0x38]
    193e:	mov    QWORD PTR [rsp+0x10],rcx
    1943:	mov    QWORD PTR [rsp+0x18],rax
    1948:	mov    QWORD PTR [rsp+0x38],rdx
    194d:	mov    QWORD PTR [rsp+0x40],rcx
    1952:	mov    QWORD PTR [rsp+0x48],rax
    1957:	jmp    16c7 <botlish_fn_16+0x5d>

000000000000195c <botlish_entry_16: scan_record_rest<str, int, mutarray, int>>:
    195c:	push   rbp
    195d:	mov    rbp,rsp
    1960:	ud2

0000000000001962 <botlish_fn_17: scan_record<str, int>>:
    1962:	push   rbp
    1963:	mov    rbp,rsp
    1966:	sub    rsp,0x40
    196a:	mov    QWORD PTR [rsp+0x20],rbx
    196f:	mov    QWORD PTR [rsp+0x28],r12
    1974:	mov    QWORD PTR [rsp+0x30],r14
    1979:	mov    r14,rdi
    197c:	mov    QWORD PTR [rsp+0x10],0x0
    1985:	mov    QWORD PTR [rsp+0x18],0x0
    198e:	mov    QWORD PTR [rsp],rsi
    1992:	mov    r12,rsi
    1995:	mov    QWORD PTR [rsp+0x8],rdx
    199a:	mov    rsi,r12
    199d:	mov    rdi,r14
    19a0:	call   19a5 <botlish_fn_17+0x43>
			19a1: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    19a5:	test   rax,rax
    19a8:	je     19fd <botlish_fn_17+0x9b>
    19ae:	mov    QWORD PTR [rsp+0x8],rax
    19b3:	mov    rsi,rax
    19b6:	mov    QWORD PTR [rsp+0x10],rdx
    19bb:	mov    rbx,rdx
    19be:	mov    rdi,r14
    19c1:	call   19c6 <botlish_fn_17+0x64>
			19c2: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
    19c6:	test   rax,rax
    19c9:	je     19fd <botlish_fn_17+0x9b>
    19cf:	mov    QWORD PTR [rsp+0x8],rax
    19d4:	mov    rcx,rax
    19d7:	mov    r8d,0x3
    19dd:	mov    QWORD PTR [rsp+0x18],0x3
    19e6:	mov    rdx,rbx
    19e9:	mov    rsi,r12
    19ec:	mov    rdi,r14
    19ef:	call   19f4 <botlish_fn_17+0x92>
			19f0: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    19f4:	test   rax,rax
    19f7:	jne    1a1b <botlish_fn_17+0xb9>
    19fd:	xor    rdx,rdx
    1a00:	mov    rax,rdx
    1a03:	mov    rbx,QWORD PTR [rsp+0x20]
    1a08:	mov    r12,QWORD PTR [rsp+0x28]
    1a0d:	mov    r14,QWORD PTR [rsp+0x30]
    1a12:	add    rsp,0x40
    1a16:	mov    rsp,rbp
    1a19:	pop    rbp
    1a1a:	ret
    1a1b:	mov    rbx,QWORD PTR [rsp+0x20]
    1a20:	mov    r12,QWORD PTR [rsp+0x28]
    1a25:	mov    r14,QWORD PTR [rsp+0x30]
    1a2a:	add    rsp,0x40
    1a2e:	mov    rsp,rbp
    1a31:	pop    rbp
    1a32:	ret

0000000000001a33 <botlish_entry_17: scan_record<str, int>>:
    1a33:	push   rbp
    1a34:	mov    rbp,rsp
    1a37:	ud2
    1a39:	add    BYTE PTR [rax],al
    1a3b:	add    BYTE PTR [rax],al
    1a3d:	add    BYTE PTR [rax],al
	...

0000000000001a40 <botlish_fn_18: scan_records<str, int, mutarray, int>>:
    1a40:	push   rbp
    1a41:	mov    rbp,rsp
    1a44:	sub    rsp,0x60
    1a48:	mov    QWORD PTR [rsp+0x30],rbx
    1a4d:	mov    QWORD PTR [rsp+0x38],r12
    1a52:	mov    QWORD PTR [rsp+0x40],r13
    1a57:	mov    QWORD PTR [rsp+0x48],r14
    1a5c:	mov    QWORD PTR [rsp+0x50],r15
    1a61:	mov    r13,rdi
    1a64:	mov    QWORD PTR [rsp+0x20],0x0
    1a6d:	mov    QWORD PTR [rsp],rsi
    1a71:	mov    QWORD PTR [rsp+0x8],rdx
    1a76:	mov    rax,rdx
    1a79:	mov    QWORD PTR [rsp+0x10],rcx
    1a7e:	mov    QWORD PTR [rsp+0x18],r8
    1a83:	mov    rbx,rsi
    1a86:	mov    r14,r8
    1a89:	mov    r15,rcx
    1a8c:	mov    rdx,QWORD PTR [rbx+0x8]
    1a90:	shl    rdx,1
    1a93:	or     rdx,0x1
    1a97:	mov    r12,rax
    1a9a:	and    rax,rdx
    1a9d:	test   rax,0x1
    1aa3:	jne    1ac9 <botlish_fn_18+0x89>
    1aa9:	mov    rsi,r12
    1aac:	mov    rdi,r13
    1aaf:	call   1ab4 <botlish_fn_18+0x74>
			1ab0: R_X86_64_PLT32	rt_int_cmp-0x4
    1ab4:	mov    ecx,0x2
    1ab9:	test   rax,rax
    1abc:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1bf0 <botlish_fn_18+0x1b0>
    1ac4:	jmp    1ad9 <botlish_fn_18+0x99>
    1ac9:	mov    ecx,0x2
    1ace:	cmp    r12,rdx
    1ad1:	cmovge rcx,QWORD PTR [rip+0x117]        # 1bf0 <botlish_fn_18+0x1b0>
    1ad9:	cmp    rcx,0x6
    1add:	je     1b8b <botlish_fn_18+0x14b>
    1ae3:	mov    rdx,r12
    1ae6:	mov    rsi,rbx
    1ae9:	mov    rdi,r13
    1aec:	call   1af1 <botlish_fn_18+0xb1>
			1aed: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1af1:	test   rax,rax
    1af4:	je     1ba2 <botlish_fn_18+0x162>
    1afa:	mov    QWORD PTR [rsp+0x8],rax
    1aff:	mov    rcx,rax
    1b02:	mov    QWORD PTR [rsp+0x20],rdx
    1b07:	mov    rsi,r15
    1b0a:	mov    r12,rdx
    1b0d:	mov    rdx,r14
    1b10:	mov    rdi,r13
    1b13:	call   1b18 <botlish_fn_18+0xd8>
			1b14: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1b18:	test   rax,rax
    1b1b:	je     1ba2 <botlish_fn_18+0x162>
    1b21:	mov    QWORD PTR [rsp+0x8],rax
    1b26:	mov    r15,rax
    1b29:	mov    QWORD PTR [rsp+0x10],0x3
    1b32:	mov    rsi,r14
    1b35:	test   rsi,0x1
    1b3c:	je     1b57 <botlish_fn_18+0x117>
    1b42:	mov    rsi,r14
    1b45:	mov    rax,rsi
    1b48:	add    rax,0x2
    1b4c:	seto   cl
    1b4f:	test   cl,cl
    1b51:	je     1b67 <botlish_fn_18+0x127>
    1b57:	mov    edx,0x3
    1b5c:	mov    rsi,r14
    1b5f:	mov    rdi,r13
    1b62:	call   1b67 <botlish_fn_18+0x127>
			1b63: R_X86_64_PLT32	rt_int_add-0x4
    1b67:	mov    QWORD PTR [rsp],rbx
    1b6b:	mov    rdx,r12
    1b6e:	mov    QWORD PTR [rsp+0x8],rdx
    1b73:	mov    rcx,r15
    1b76:	mov    QWORD PTR [rsp+0x10],rcx
    1b7b:	mov    QWORD PTR [rsp+0x18],rax
    1b80:	mov    r14,rax
    1b83:	mov    rax,rdx
    1b86:	jmp    1a8c <botlish_fn_18+0x4c>
    1b8b:	mov    rdx,r14
    1b8e:	mov    rsi,r15
    1b91:	mov    rdi,r13
    1b94:	call   1b99 <botlish_fn_18+0x159>
			1b95: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1b99:	test   rax,rax
    1b9c:	jne    1bc7 <botlish_fn_18+0x187>
    1ba2:	xor    rax,rax
    1ba5:	mov    rbx,QWORD PTR [rsp+0x30]
    1baa:	mov    r12,QWORD PTR [rsp+0x38]
    1baf:	mov    r13,QWORD PTR [rsp+0x40]
    1bb4:	mov    r14,QWORD PTR [rsp+0x48]
    1bb9:	mov    r15,QWORD PTR [rsp+0x50]
    1bbe:	add    rsp,0x60
    1bc2:	mov    rsp,rbp
    1bc5:	pop    rbp
    1bc6:	ret
    1bc7:	mov    rbx,QWORD PTR [rsp+0x30]
    1bcc:	mov    r12,QWORD PTR [rsp+0x38]
    1bd1:	mov    r13,QWORD PTR [rsp+0x40]
    1bd6:	mov    r14,QWORD PTR [rsp+0x48]
    1bdb:	mov    r15,QWORD PTR [rsp+0x50]
    1be0:	add    rsp,0x60
    1be4:	mov    rsp,rbp
    1be7:	pop    rbp
    1be8:	ret
    1be9:	add    BYTE PTR [rax],al
    1beb:	add    BYTE PTR [rax],al
    1bed:	add    BYTE PTR [rax],al
    1bef:	add    BYTE PTR [rsi],al
    1bf1:	add    BYTE PTR [rax],al
    1bf3:	add    BYTE PTR [rax],al
    1bf5:	add    BYTE PTR [rax],al
	...

0000000000001bf8 <botlish_entry_18: scan_records<str, int, mutarray, int>>:
    1bf8:	push   rbp
    1bf9:	mov    rbp,rsp
    1bfc:	mov    rsi,QWORD PTR [rdx]
    1bff:	mov    r9,QWORD PTR [rdx+0x8]
    1c03:	mov    rcx,QWORD PTR [rdx+0x10]
    1c07:	mov    r8,QWORD PTR [rdx+0x18]
    1c0b:	mov    rdx,r9
    1c0e:	call   1c13 <botlish_entry_18+0x1b>
			1c0f: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1c13:	mov    rsp,rbp
    1c16:	pop    rbp
    1c17:	ret

0000000000001c18 <botlish_fn_19: csv_parse<str>>:
    1c18:	push   rbp
    1c19:	mov    rbp,rsp
    1c1c:	sub    rsp,0x40
    1c20:	mov    QWORD PTR [rsp+0x20],rbx
    1c25:	mov    QWORD PTR [rsp+0x28],r12
    1c2a:	mov    QWORD PTR [rsp+0x30],r13
    1c2f:	mov    rbx,rdi
    1c32:	mov    QWORD PTR [rsp+0x8],0x0
    1c3b:	mov    QWORD PTR [rsp+0x10],0x0
    1c44:	mov    QWORD PTR [rsp+0x18],0x0
    1c4d:	mov    QWORD PTR [rsp],rsi
    1c51:	mov    rax,QWORD PTR [rsi+0x8]
    1c55:	mov    r12,rsi
    1c58:	shl    rax,1
    1c5b:	or     rax,0x1
    1c5f:	sar    rax,1
    1c62:	test   rax,rax
    1c65:	je     1cf4 <botlish_fn_19+0xdc>
    1c6b:	mov    edx,0x1
    1c70:	mov    QWORD PTR [rsp+0x8],0x1
    1c79:	mov    rsi,r12
    1c7c:	mov    rdi,rbx
    1c7f:	call   1c84 <botlish_fn_19+0x6c>
			1c80: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1c84:	test   rax,rax
    1c87:	je     1d0b <botlish_fn_19+0xf3>
    1c8d:	mov    QWORD PTR [rsp+0x8],rax
    1c92:	mov    rsi,rax
    1c95:	mov    QWORD PTR [rsp+0x10],rdx
    1c9a:	mov    r13,rdx
    1c9d:	mov    rdi,rbx
    1ca0:	call   1ca5 <botlish_fn_19+0x8d>
			1ca1: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
    1ca5:	test   rax,rax
    1ca8:	je     1d0b <botlish_fn_19+0xf3>
    1cae:	mov    QWORD PTR [rsp+0x8],rax
    1cb3:	mov    rcx,rax
    1cb6:	mov    r8d,0x3
    1cbc:	mov    QWORD PTR [rsp+0x18],0x3
    1cc5:	mov    rdx,r13
    1cc8:	mov    rsi,r12
    1ccb:	mov    rdi,rbx
    1cce:	call   1cd3 <botlish_fn_19+0xbb>
			1ccf: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1cd3:	test   rax,rax
    1cd6:	je     1d0b <botlish_fn_19+0xf3>
    1cdc:	mov    rbx,QWORD PTR [rsp+0x20]
    1ce1:	mov    r12,QWORD PTR [rsp+0x28]
    1ce6:	mov    r13,QWORD PTR [rsp+0x30]
    1ceb:	add    rsp,0x40
    1cef:	mov    rsp,rbp
    1cf2:	pop    rbp
    1cf3:	ret
    1cf4:	xor    rdx,rdx
    1cf7:	mov    rdi,rbx
    1cfa:	mov    rsi,rdx
    1cfd:	call   1d02 <botlish_fn_19+0xea>
			1cfe: R_X86_64_PLT32	rt_list_new-0x4
    1d02:	test   rax,rax
    1d05:	jne    1d26 <botlish_fn_19+0x10e>
    1d0b:	xor    rax,rax
    1d0e:	mov    rbx,QWORD PTR [rsp+0x20]
    1d13:	mov    r12,QWORD PTR [rsp+0x28]
    1d18:	mov    r13,QWORD PTR [rsp+0x30]
    1d1d:	add    rsp,0x40
    1d21:	mov    rsp,rbp
    1d24:	pop    rbp
    1d25:	ret
    1d26:	mov    rbx,QWORD PTR [rsp+0x20]
    1d2b:	mov    r12,QWORD PTR [rsp+0x28]
    1d30:	mov    r13,QWORD PTR [rsp+0x30]
    1d35:	add    rsp,0x40
    1d39:	mov    rsp,rbp
    1d3c:	pop    rbp
    1d3d:	ret

0000000000001d3e <botlish_entry_19: csv_parse<str>>:
    1d3e:	push   rbp
    1d3f:	mov    rbp,rsp
    1d42:	mov    rsi,QWORD PTR [rdx]
    1d45:	call   1d4a <botlish_entry_19+0xc>
			1d46: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    1d4a:	mov    rsp,rbp
    1d4d:	pop    rbp
    1d4e:	ret
